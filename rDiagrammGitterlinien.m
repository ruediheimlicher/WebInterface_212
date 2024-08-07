//
//  rDiagrammGitterlinien.m
//  WebInterface
//
//  Created by Sysadmin on 11.Februar.09.
//  Copyright 2009 Ruedi Heimlicher. All rights reserved.
//

#import "rDiagrammGitterlinien.h"


@implementation rDiagrammGitterlinien

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
		//NSLog(@"rDiagrammGitterlinien init");
		NSRect Diagrammfeld=frame;
		//		Diagrammfeld.size.width+=400;
		[self setFrame:Diagrammfeld];
		DiagrammEcke=NSMakePoint(2.1,5.1);
		Graph=[NSBezierPath bezierPath];
		[Graph moveToPoint:DiagrammEcke];
		lastPunkt=DiagrammEcke;
		GraphFarbe=[NSColor blueColor]; 
		OffsetY=0.0;
		//NSLog(@"rDiagrammGitterlinien Diagrammfeldhoehe: %2.2f ",(frame.size.height-15));
		GraphArray=[[NSMutableArray alloc]initWithCapacity:0];
		GraphFarbeArray=[[NSMutableArray alloc]initWithCapacity:0];
		
		GraphKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
		//DatenArray=[[NSMutableArray alloc]initWithCapacity:0];
		//[DatenArray retain];
		
		NetzlinienY=[[NSMutableArray alloc]initWithCapacity:0];
		
		int i=0;
		
		NSBezierPath* tempGraph=[NSBezierPath bezierPath];
		float varRed=sin(i+(float)i/10.0)/3.0+0.6;
		float varGreen=sin(2*i+(float)i/10.0)/3.0+0.6;
		float varBlue=sin(3*i+(float)i/10.0)/3.0+0.6;
		//NSLog(@"sinus: %2.2f",varRed);
		NSColor* tempColor=[NSColor colorWithCalibratedRed:varRed green: varGreen blue: varBlue alpha:1.0];
		//NSLog(@"Farbe Kanal: %d Color: %@",i,[tempColor description]);
		tempColor=[NSColor blackColor];
		[GraphFarbeArray addObject:tempColor];
		//NSMutableDictionary* tempGraphDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		//[GraphArray addObject:tempGraphDic];
		[GraphKanalArray addObject:[NSNumber numberWithInt:0]];
		NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
		[DatenArray addObject:tempDatenArray];
		//NSMutableArray* NetzlinienY=[[NSMutableArray alloc]initWithCapacity:0];
		
		
		
		
		
		
		NullpunktY=10.0;
		ZeitKompression=1.0;
		MaxOrdinate= frame.size.height-15;
		Intervall = 2;
		Teile = 2;
		LinieOK=0; // keine Linie zeichnen
		
		DatenserieStartZeit=[NSDate date];
		
		NSNotificationCenter * nc;
		nc=[NSNotificationCenter defaultCenter];
		
		
		[nc addObserver:self
			   selector:@selector(StartAktion:)
				   name:@"data"
				 object:nil];
		
		
    }
    return self;
}



- (void)StartAktion:(NSNotification*)note
{
	[super StartAktion:note];
	//NSLog(@"DiagrammGitterlinien StartAktion note: %@",[[note userInfo]description]);
   //NSLog(@"DiagrammGitterlinien StartAktion DatenserieStartZeit: %@",[DatenserieStartZeit description]);
   /*
   NSDateFormatter* formatter ;
   formatter.dateFormat = @"yyyy";
//   NSString* dateString = [RFC3339DateFormatter dateFromString:string];
   NSArray* startzeitarray = [[DatenserieStartZeit description] componentsSeparatedByString:@" "];
   NSString* startzeitline = [startzeitarray objectAtIndex:1]; 
   StartStunde = [[[startzeitline componentsSeparatedByString:@":"]objectAtIndex:0]intValue];
   StartMinute = [[[startzeitline componentsSeparatedByString:@":"]objectAtIndex:1]intValue];
   
   StartStunde=[[NSCalendar currentCalendar] component:NSCalendarUnitHour  fromDate:DatenserieStartZeit];

   //StartMinute=[[NSCalendar currentCalendar] component:NSCalendarUnitMinute  fromDate:DatenserieStartZeit];

	//NSLog(@"DiagrammGitterlinien StartStunde: %d StartMinute: %d",StartStunde, StartMinute);
	*/
   NSTimeZone *cetTimeZone = [NSTimeZone timeZoneWithName:@"CET"];
   
   NSCalendar *startcalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   startcalendar.firstWeekday = 2;
   [startcalendar setTimeZone:cetTimeZone];
   NSDateComponents *components = [startcalendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:DatenserieStartZeit];
   int wd = components.weekday;
   int stunde = components.hour;
   int minute = components.minute;
   StartStunde = components.hour; //
   StartMinute = components.minute;

	
}





- (void)setEinheitenDicY:(NSDictionary*)derEinheitenDic
{
	[super setEinheitenDicY:derEinheitenDic];
	if ([derEinheitenDic objectForKey:@"intervall"])
	{
		Intervall=[[derEinheitenDic objectForKey:@"intervall"]intValue];
	}
	
}



- (void)setWerteArray:(NSArray*)derWerteArray mitKanalArray:(NSArray*)derKanalArray
{
	{
		//NSLog(@"rDiagrammGitterlinien setWerteArray WerteArray: %@",[derWerteArray description]);//,[derKanalArray description]);
		int i;
		
		for (i=0;i<[derWerteArray count]-1;i++) // erster Wert ist Abszisse
		{
			if ([[derKanalArray objectAtIndex:i]intValue]) // der Kanal soll gezeigt werden
			{
				
				
				//NSLog(@"***			Gitterlinien setWerteArray:	x: %d",[[derWerteArray objectAtIndex:0]intValue]);
				NSPoint neuerPunkt=DiagrammEcke;
				int Zeitwert=[[derWerteArray objectAtIndex:0]intValue]; //Sekunden seit Start
				int Minute=0;
				int AnzeigeMinute=0;
				//int laufendeMinute=(Zeitwert / 60); // Zeit ab Start
				
				if (StartMinute + Zeitwert / 60 >= 60) // erste Stunde voll
				{
					//StartMinute=0;
					//LinieOK=0;
				}
				
				Minute = StartMinute  + (Zeitwert / 60); // laufende Minute
				AnzeigeMinute = (StartMinute  + (Zeitwert / 60))%60;
				
				int Stunde = (StartStunde+ Minute / 60) % 24; // Stunde des Tages
				//int AnzeigeStunde=
				
            //NSLog(@"***	  Gitterlinien Zeitwert (min): %d AnzeigeMinute: %d Startstunde: %d StartMinute: %d Minute: %d LinieOK: %d zeichnen: %d",Zeitwert/60,AnzeigeMinute,StartStunde,StartMinute,Minute,LinieOK,Minute % Intervall);

				int Art=0;	// Linie fuer Intervall
				
				if (Intervall < 60)
				{
				if (AnzeigeMinute % Intervall==0) 
				{	
					if (LinieOK==0) // Linie zeichnen
					{
						LinieOK=1;
						//NSLog(@"Gitterlinien  Intervall: %d  AnzeigeMinute: %d",Intervall, AnzeigeMinute);
						neuerPunkt.x=Zeitwert*ZeitKompression;	//	aktuelle Zeit, x-Wert, erster Wert im Array
						// GraphArray	Array mit Dics fuer die senkrechten Zeitlinien
						
						NSString* ZeitString;
						
						if (StartStunde+ Minute / 60 >= 24) // Tag fertig
						{
							//StartStunde=0;
						}
						
						// 
						
						if (AnzeigeMinute<10)
						{
							
							ZeitString=[NSString stringWithFormat:@"0%d",AnzeigeMinute];
						}
						else
						{
							ZeitString=[NSString stringWithFormat:@"%d",AnzeigeMinute];
						}
						NSString* tempStundenString;
						
						if (Stunde<10)
						{
							
							tempStundenString=[NSString stringWithFormat:@"0%d",Stunde];
						}
						else
						{
							tempStundenString=[NSString stringWithFormat:@"%d",Stunde];
						}
						
						ZeitString = [NSString stringWithFormat:@"%@:%@",tempStundenString,ZeitString];
						
						if (Minute % 60 ==0)	// neue Stunde
						{
							Art = 1; // Stundenlinie
						}
						
						//NSLog(@"Gitterlinien ZeitString: %@",ZeitString);
						
						//NSLog(@"GraphArray: %@",[GraphArray description]);
						NSMutableDictionary* tempLinienDic=[[NSMutableDictionary alloc]initWithCapacity:0];
						[tempLinienDic setObject:[NSNumber numberWithInt:neuerPunkt.x] forKey:@"x"];
						[tempLinienDic setObject:[NSNumber numberWithInt:Art] forKey:@"art"];
						
						[tempLinienDic setObject:ZeitString forKey:@"zeitstring"];
						//NSMutableDictionary* tempLinienDic=[NSMutableDictionary dictionaryWithObjects:tempDatenArray forKeys:[NSArray arrayWithObjects:@"start",@"x",@"y",nil]];
						//NSLog(@"Gitterlinien tempLinienDic: %@",tempLinienDic);				
						[GraphArray addObject:tempLinienDic];
						
						
						
						
						
					}// LinieOK
				} // %60
				else
				{
					LinieOK = 0;
				}
				
				}// Intervall<60
				else
				{
					if (AnzeigeMinute == 0) // ganze Stunde
					{	
						int geradeStunde= (Stunde%2)==0;
						
						if ((Intervall == 120)&& ((Stunde%2)==1)) // Nur in geraden  Stunden zeichnen
						{
							LinieOK=1;
						}
						
						if (LinieOK==0) // Linie zeichnen
						{
							LinieOK=1;
							//NSLog(@"Gitterlinien  Intervall: %d  AnzeigeMinute: %d",Intervall, AnzeigeMinute);
							neuerPunkt.x=Zeitwert*ZeitKompression;	//	aktuelle Zeit, x-Wert, erster Wert im Array
							// GraphArray	Array mit Dics fuer die senkrechten Zeitlinien
							
							NSString* ZeitString = @"00";
							NSString* tempStundenString;
							
							if (Stunde<10)
							{
								
								tempStundenString=[NSString stringWithFormat:@"0%d",Stunde];
							}
							else
							{
								tempStundenString=[NSString stringWithFormat:@"%d",Stunde];
							}
							
							ZeitString = [NSString stringWithFormat:@"%@:%@",tempStundenString,ZeitString];
							
							{
								Art = 1; // Stundenlinie
							}
							
							//NSLog(@"Gitterlinien ZeitString: %@",ZeitString);
							
							//NSLog(@"GraphArray: %@",[GraphArray description]);
							NSMutableDictionary* tempLinienDic=[[NSMutableDictionary alloc]initWithCapacity:0];
							[tempLinienDic setObject:[NSNumber numberWithInt:neuerPunkt.x] forKey:@"x"];
							[tempLinienDic setObject:[NSNumber numberWithInt:Art] forKey:@"art"];
							
							[tempLinienDic setObject:ZeitString forKey:@"zeitstring"];
							//NSMutableDictionary* tempLinienDic=[NSMutableDictionary dictionaryWithObjects:tempDatenArray forKeys:[NSArray arrayWithObjects:@"start",@"x",@"y",nil]];
							//NSLog(@"Gitterlinien tempLinienDic: %@",tempLinienDic);				
							[GraphArray addObject:tempLinienDic];
							
							
							
							
							
						}// LinieOK
					} // %60
					else
					{
						LinieOK = 0;
					}				
					
				}// Intervall>=60

				
				
				
				
				// GraphArray	Array mit Dics fuer die senkrechten Zeitlinien
				
				//NSLog(@"GraphArray: %@",[GraphArray description]);
				
				
				
				
				//		neuerPunkt.y+=([[derWerteArray objectAtIndex:i+1]floatValue])*FaktorY;//	Data, y-Wert
				//		NSLog(@"setWerteArray: Kanal: %d x: %2.2f y: %2.2f",i,neuerPunkt.x,neuerPunkt.y);
				
				
			}// if Kanal
		}	// for i
		
		[GraphKanalArray setArray:derKanalArray];
		
		//[GraphKanalArray retain];
		//		[self setNeedsDisplay:YES];
		//NSLog(@"rDiagrammGitterlinien DatenArray: %@",[DatenArray description]);
	}
	
}

- (void)setZeitKompression:(float)dieKompression  mitAbszissenArray:(NSArray*)derArray
{
	//NSLog(@"Gitterlinien AbszissenArray: %@",[derArray description]);
	
	// GraphArray	Array mit Dics fuer die senkrechten Zeitlinien
	if ([GraphArray count])
	{
		[GraphArray removeAllObjects];
	}
	
	
	float stretch = dieKompression/ZeitKompression;
	//NSLog(@"Gitterlinien setZeitKompression ZeitKompression: %2.2f dieKompression: %2.2f stretch: %2.2f",ZeitKompression,dieKompression,stretch);
	ZeitKompression=dieKompression;
   
	
	int i;
	
	for (i=0;i<[derArray count];i++)
	{
		
		
		//NSLog(@"***			Gitterlinien setWerteArray:	x: %d",[[derArray objectAtIndex:i]intValue]);
		NSPoint neuerPunkt=DiagrammEcke;
		int Zeitwert=[[derArray objectAtIndex:i]intValue];
		int Minute=0;
		int AnzeigeMinute=0;
		//int laufendeMinute=(Zeitwert / 60); // Zeit ab Start
		
		if (StartMinute + Zeitwert / 60 >= 60) // erste Stunde voll
		{
			//StartMinute=0;
			//LinieOK=0;
		}
		
		Minute = StartMinute  + (Zeitwert / 60);
		AnzeigeMinute = (StartMinute  + (Zeitwert / 60))%60;
		
		//NSLog(@"***	  Gitterlinien Zeitwert (min): %d AnzeigeMinute: %d StartMinute: %d Minute: %d LinieOK: %d zeichnen: %d",Zeitwert/60,AnzeigeMinute,StartMinute,Minute,LinieOK,Minute % Intervall);
		int Art=0;	// Linie fuer Intervall
		if (AnzeigeMinute % Intervall==0) 
		{	
			if (LinieOK==0) // Linie zeichnen
			{
				LinieOK=1;
				//NSLog(@"Gitterlinien  Intervall: %d  AnzeigeMinute: %d",Intervall, AnzeigeMinute);
				neuerPunkt.x=Zeitwert*ZeitKompression;	//	aktuelle Zeit, x-Wert, erster Wert im Array
				// GraphArray	Array mit Dics fuer die senkrechten Zeitlinien
				
				
				
				NSString* ZeitString;
				
				if (StartStunde+ Minute / 60 >= 24) // Tag fertig
				{
					//StartStunde=0;
				}
				int Stunde = (StartStunde+ Minute / 60) % 24;
				//int AnzeigeStunde=
				
				if (AnzeigeMinute<10)
				{
					
					ZeitString=[NSString stringWithFormat:@"0%d",AnzeigeMinute];
				}
				else
				{
					ZeitString=[NSString stringWithFormat:@"%d",AnzeigeMinute];
				}
				NSString* tempStundenString;
				
				if (Stunde<10)
				{
					
					tempStundenString=[NSString stringWithFormat:@"0%d",Stunde];
				}
				else
				{
					tempStundenString=[NSString stringWithFormat:@"%d",Stunde];
				}
				
				ZeitString = [NSString stringWithFormat:@"%@:%@",tempStundenString,ZeitString];
				
				if (Minute % 60 ==0)	// neue Stunde
				{
					Art = 1; // Stundenlinie
				}
				
				//NSLog(@"Gitterlinien ZeitString: %@",ZeitString);
				
				//NSLog(@"GraphArray: %@",[GraphArray description]);
				NSMutableDictionary* tempLinienDic=[[NSMutableDictionary alloc]initWithCapacity:0];
				[tempLinienDic setObject:[NSNumber numberWithInt:neuerPunkt.x] forKey:@"x"];
				[tempLinienDic setObject:[NSNumber numberWithInt:Art] forKey:@"art"];
				
				[tempLinienDic setObject:ZeitString forKey:@"zeitstring"];
				//NSMutableDictionary* tempLinienDic=[NSMutableDictionary dictionaryWithObjects:tempDatenArray forKeys:[NSArray arrayWithObjects:@"start",@"x",@"y",nil]];
				//NSLog(@"Gitterlinien tempLinienDic: %@",tempLinienDic);				
				[GraphArray addObject:tempLinienDic];
				
				
				
				
				
			}// LinieOK
		} // %60
		else
		{
			LinieOK = 0;
		}
		
		// GraphArray	Array mit Dics fuer die senkrechten Zeitlinien
		
		//NSLog(@"GraphArray: %@",[GraphArray description]);
		
		
		
		
		//		neuerPunkt.y+=([[derWerteArray objectAtIndex:i+1]floatValue])*FaktorY;//	Data, y-Wert
		//		NSLog(@"setWerteArray: Kanal: %d x: %2.2f y: %2.2f",i,neuerPunkt.x,neuerPunkt.y);
		
		
	}
	[self setNeedsDisplay:YES];
	/*
	NSRect tempRect=[self frame];
	tempRect.size.width = tempRect.size.width * stretch;
	[self setFrame:tempRect];
	[self setNeedsDisplay:YES];
	*/
}

- (void)drawRect:(NSRect)rect
{
 	NSMutableDictionary* ZeitAttrs=[[NSMutableDictionary alloc]initWithCapacity:0];
	
 	NSMutableParagraphStyle* ZeitPar=[[NSMutableParagraphStyle alloc]init];
	[ZeitPar setAlignment:NSTextAlignmentCenter];
	[ZeitAttrs setObject:ZeitPar forKey:NSParagraphStyleAttributeName];
	NSFont* ZeitFont=[NSFont fontWithName:@"Helvetica" size: 9];
	
	[ZeitAttrs setObject:ZeitFont forKey:NSFontAttributeName];
	
	//NSLog(@"rDiagrammGitterlinien drawRect");
	NSRect NetzBoxRahmen=[self frame];//NSMakeRect(NetzEcke.x,NetzEcke.y,200,100);
	float breite=[[[self superview]superview]frame].size.width;
	//NSLog(@"rDiagrammGitterlinien drawRect Breite alt: %2.2f",breite);
	//NetzBoxRahmen.size.width=breite;
	
	//	[self setFrame:NetzBoxRahmen];
	
	//	NSLog(@"rDiagrammGitterlinien drawRect width neu: %2.2f",[self frame].size.width);
  	
	
	NetzBoxRahmen.size.height-=16;
	NetzBoxRahmen.size.width-=15;
	NetzBoxRahmen.origin.x=0.2;
	NetzBoxRahmen.origin.y=4.1;
	//NSLog(@"rDiagrammGitterlinien NetzBoxRahmen x: %2.2f y: %2.2f h: %2.2f w: %2.2f",NetzBoxRahmen.origin.x,NetzBoxRahmen.origin.y,NetzBoxRahmen.size.height,NetzBoxRahmen.size.width);
	
	[[NSColor greenColor]set];
	//[NSBezierPath fillRect:NetzBoxRahmen];
	
	NSBezierPath* SenkrechteLinie=[NSBezierPath bezierPath];
	int i;
	NSPoint untenV=DiagrammEcke;
	NSPoint obenV=untenV;
	NSPoint links=untenV;
	
	obenV.x=untenV.x;
	obenV.y+=NetzBoxRahmen.size.height;
	NSPoint SchriftPunkt=obenV;
	//SchriftPunkt.y -=10;
	[SenkrechteLinie moveToPoint:untenV];
	[SenkrechteLinie lineToPoint:obenV];
	[SenkrechteLinie stroke];
	//NSLog(@"Gitterlinien [GraphArray count]: %d",[GraphArray count]);
	for (i=0;i<[GraphArray count];i++)
	{
		if ([GraphArray objectAtIndex:i] && [[GraphArray objectAtIndex:i]objectForKey:@"x"]) // Dic vorhanden
		{
			//NSLog(@"Gitterlinien [GraphArray objectAtIndex:i]: %@",[[GraphArray objectAtIndex:i] description]);
			
			untenV.x=[[[GraphArray objectAtIndex:i]objectForKey:@"x"]floatValue];
			obenV.x=untenV.x;
			SchriftPunkt.x = untenV.x-11;
			[SenkrechteLinie moveToPoint:untenV];
			[SenkrechteLinie lineToPoint:obenV];
			int art=0;
			if ([[GraphArray objectAtIndex:i]objectForKey:@"art"])
			{
				art=[[[GraphArray objectAtIndex:i]objectForKey:@"art"]intValue];
			}
			if (art==1)
			{
				[[NSColor redColor]set];
			}
			else
			{
				[[NSColor greenColor]set];
			}
			[SenkrechteLinie stroke];
			if ([[GraphArray objectAtIndex:i]objectForKey:@"zeitstring"]) // ZeitString
			{
				[[[GraphArray objectAtIndex:i]objectForKey:@"zeitstring"]drawAtPoint:SchriftPunkt withAttributes:ZeitAttrs];
			}
			
			
		}
	}
	
	
	
	
}

- (void)clean
{
	if (GraphArray &&[GraphArray count])
	{
		[GraphArray removeAllObjects];
	}
	
	if (GraphFarbeArray && [GraphFarbeArray count])
	{
		[GraphFarbeArray removeAllObjects];
	}
	
	
	if (GraphKanalArray &&[GraphKanalArray count])
	{
		[GraphKanalArray removeAllObjects];
	}
	
	if (DatenArray &&[DatenArray count])
	{
		[DatenArray removeAllObjects];
	}
	int i=0;
	NSBezierPath* tempGraph=[NSBezierPath bezierPath];
	float varRed=sin(i+(float)i/10.0)/3.0+0.6;
	float varGreen=sin(2*i+(float)i/10.0)/3.0+0.6;
	float varBlue=sin(3*i+(float)i/10.0)/3.0+0.6;
	//NSLog(@"sinus: %2.2f",varRed);
	NSColor* tempColor=[NSColor colorWithCalibratedRed:varRed green: varGreen blue: varBlue alpha:1.0];
	//NSLog(@"Farbe Kanal: %d Color: %@",i,[tempColor description]);
	tempColor=[NSColor blackColor];
	[GraphFarbeArray addObject:tempColor];
	NSMutableDictionary* tempGraphDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	//[GraphArray addObject:tempGraphDic];
	[GraphKanalArray addObject:[NSNumber numberWithInt:0]];
	NSMutableArray* tempDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	[DatenArray addObject:tempDatenArray];
	NSMutableArray* NetzlinienY=[[NSMutableArray alloc]initWithCapacity:0];
	
}



@end
