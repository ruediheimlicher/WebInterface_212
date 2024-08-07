//
//  rEEPROMbalken.m
//  SndCalcII
//
//  Created by Sysadmin on 13.02.08.
//  Copyright 2008 Ruedi Heimlicher. All rights reserved.
//

#import "rEEPROMbalken.h"

@implementation rEEPROMbalken

- (id)initWithFrame:(NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) 
	{
      //  typ=0;
		RandL=100;
		RandR=20;
		RandU=2;
		aktiv=1;
		changed=0;
		TagbalkenTyp=0;
		if (StundenArray==NULL)
		{
			StundenArray=[[NSMutableArray alloc]initWithCapacity:0];
		}
		
	}
    return self;
	
	
   
}

- (void)BalkenAnlegen
{
	
	Nullpunkt=[self convertPoint:NSMakePoint(0.0,0.0) toView:NULL];
	//NSLog(@"Tagbalken init  Nullpunkt: x: %2.2f y: %2.2f", Nullpunkt.x,Nullpunkt.y);
	int i=0;
	
	NSPoint Ecke=NSMakePoint(8.0,4.0);
	
	Titel=@"Objekt";
	ObjektString=@"Objekt";
	RaumString=@"Raum";
	WochentagString=@"Tag";
	
	//NSLog(@"Tagbalken init: frame.height: %2.2f",[self frame].size.height);
/*
	

	rTaste* WriteTaste=[[[rTaste alloc]initWithFrame:WriteFeld]retain];
	//	[WriteTaste setButtonType:NSMomentaryLightButton];
	[WriteTaste setButtonType:NSMomentaryLight];
	[WriteTaste setTarget:self];
	[WriteTaste setBordered:YES];
	[[WriteTaste cell]setBackgroundColor:[NSColor yellowColor]];
	[[WriteTaste cell]setShowsStateBy:NSPushInCellMask];
	[WriteTaste setTitle:@""];
	[WriteTaste setTag:Objekt];
	[WriteTaste setAction:@selector(WriteTasteAktion:)];
	[self addSubview:WriteTaste];
	*/
	
		Ecke.x+=RandL;
	//Ecke.y+=RandU;
	Ecke.y=1;
	//	Elementhoehe: Block mit Halbstundenfeldern und AllTaste
	Elementbreite=([self frame].size.width-RandL-RandR)/24;
	Elementhoehe=[self frame].size.height-1;
	//Elementhoehe=35;
	//NSLog(@"Elementbreite: %d Elementhoehe: %d ",Elementbreite, Elementhoehe);
	for (i=0;i<24;i++)
	{
		NSMutableDictionary* tempElementDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		NSRect Elementfeld=NSMakeRect(Ecke.x+i*Elementbreite,Ecke.y,Elementbreite-3, Elementhoehe-2);
		//NSLog(@"WS SetTagPlan i: %d Eckex: %2.2f b: %2.2f",i,Elementfeld.origin.x,Elementfeld.size.width);
		NSView* ElementView=[[NSView alloc] initWithFrame:Elementfeld];
		[ElementView setAutoresizesSubviews:NO];
		[self addSubview:ElementView];
		//NSLog(@"ElementView: x: %2.2f y: %2.2f",[ElementView frame].origin.x,[ElementView bounds].origin.y);
		[tempElementDic setObject:ElementView forKey:@"elementrahmen"];
		[tempElementDic setObject:[NSNumber numberWithInt:i] forKey:@"elementnummer"];
		
//		[tempElementDic setObject:[NSNumber numberWithInt:i%4] forKey:@"code"];
		[StundenArray addObject:tempElementDic];
		//	NSLog(@"Tagplanbalken init i: %d ElementDic: %@",i,[tempElementDic description]);
		
		NSRect StdFeldU=[[[StundenArray objectAtIndex:i]objectForKey:@"elementrahmen"]frame];
		/*
		StdFeldU.size.height = 6;
		//StdFeldU.origin.y+=8;
		rTaste* StundenTaste=[[[rTaste alloc]initWithFrame:StdFeldU]retain];
		[StundenTaste setButtonType:NSMomentaryLight];
		[StundenTaste setTag:i];

		[StundenTaste setTarget:self];
		[StundenTaste setBordered:YES];
		[[StundenTaste cell]setBackgroundColor:[NSColor grayColor]];
		[[StundenTaste cell]setShowsStateBy:NSPushInCellMask];
		[StundenTaste setTitle:@""];
		[StundenTaste setAction:@selector(StundenTasteAktion:)];
//		[self addSubview:StundenTaste];
		*/
	}//for i
	
	/*
	NSRect AllFeld=[[[StundenArray objectAtIndex:23]objectForKey:@"elementrahmen"]frame];
	AllFeld.origin.x+=Elementbreite+2;
	//AllFeld.origin.y+=8;
	AllFeld.size.height-=8;
	AllFeld.size.width/=1.8;
	rTaste* AllTaste=[[[rTaste alloc]initWithFrame:AllFeld]retain];
	//	[AllTaste setButtonType:NSMomentaryLightButton];
	[AllTaste setButtonType:NSMomentaryLight];
	[AllTaste setTarget:self];
	[AllTaste setBordered:YES];
	[[AllTaste cell]setBackgroundColor:[NSColor lightGrayColor]];
	[[AllTaste cell]setShowsStateBy:NSPushInCellMask];
	[AllTaste setTitle:@""];
	[AllTaste setAction:@selector(AllTasteAktion:)];
//	[self addSubview:AllTaste];
	//NSLog(@"Tagplanbalken end init");
	*/
}

/*
- (void)setTag:(int)tagwert
{
//tag=tagwert;
mark=tagwert;
}
 */
- (void)setTitel:(NSString*)derTitel
{
	//NSLog(@"Titel: %@ derTitel: %@",Titel, derTitel);

	Titel=[derTitel copy];
		//[derTitel release];
	//[Titelfeld setStringValue:Titel];
	
}


- (void)setObjekt:(NSNumber*)dieObjektNumber
{
	objekt=[dieObjektNumber intValue];
}

- (void)setObjektString:(NSString*)derObjektString
{
	ObjektString=[derObjektString copy];
   
}


- (void)setRaum:(int)derRaum
{
	raum = derRaum;
	
}

- (void)setRaumString:(NSString*)derRaumString
{
	RaumString=[derRaumString copy];
}



- (void)setTagbalkenTyp:(int)derTyp
{
	TagbalkenTyp=derTyp;
	
}


- (void)setWochentag:(int)derWochentag
{
	//tag=derWochentag;
	wochentag=derWochentag;
	
}

- (void)setWochentagString:(NSString*)derWochentagString
{
	WochentagString=[derWochentagString copy];
	
}



- (void)setAktiv:(int)derStatus
{
aktiv=derStatus;
}

- (void)setTagplan:(NSArray*)derStundenArray forTag:(int)derTag
{
NSLog(@"EEPROMbalken setTagplan Tag: %d StundenArray: %@",derTag, [[StundenArray valueForKey:@"code"] description]);
	if (StundenArray==NULL)
	{
		StundenArray=[[NSMutableArray alloc]initWithCapacity:0];
	}
		//tag=derTag;
		wochentag=derTag;
	
	//NSLog(@"setTagplan Tag: %d StundenArray: %@",derTag, [StundenArray description]);
	
	int i;
	for (i=0;i<24;i++)
	{
		//NSLog(@"setTagplan index: %d: werkstatt: %d",i,[[[derStundenArray objectAtIndex:i]objectForKey:@"werkstatt"]intValue]);
		if ([StundenArray objectAtIndex:i])
		{
			NSMutableDictionary* tempElementDic=[StundenArray objectAtIndex:i];
			//NSLog(@"Dic schon da fuer index: %d",i);
			
			[tempElementDic setObject:[[derStundenArray objectAtIndex:i]objectForKey:@"code"] forKey:@"code"];
		}
		else
		{
			NSLog(@"setTagplan neuer Dic index: %d",i);
			NSMutableDictionary* tempElementDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[tempElementDic setObject:[[derStundenArray objectAtIndex:i]objectForKey:@"code"] forKey:@"code"];
			[StundenArray addObject:tempElementDic];
				
		}
	}//for i
	lastONArray=[[StundenArray valueForKey:@"code"]copy];//Speicherung IST-Zustand
	//NSLog(@"StundenArray: %2.2f",[[[StundenArray objectAtIndex:0]objectForKey:@"elementrahmen"]frame].origin.x);
	//NSLog(@"setBrennerTagplan end: Tag: %d StundenArray: %@",derTag, [StundenArray description]);
	[self setNeedsDisplay:YES];
}




- (int)StundenarraywertVonStunde:(int)dieStunde forKey:(NSString*)derKey
{
	NSDictionary* tempDic=[StundenArray objectAtIndex:dieStunde];
	if (tempDic && [tempDic objectForKey:derKey])
	{
		return [[tempDic objectForKey:derKey]intValue];
	}
	else
	{
		return -1;
	}
}

- (void)setStundenarraywert:(int)derWert vonStunde:(int)dieStunde forKey:(NSString*)derKey
{
//NSLog(@"setStundenarraywert: %d Stunde: %d Key: %@",derWert, dieStunde, derKey);
//NSLog(@"Stundenarray vor : %@",[StundenArray description]);
NSMutableDictionary* tempDic=(NSMutableDictionary*)[StundenArray objectAtIndex:dieStunde];
[tempDic setObject:[NSNumber numberWithInt:derWert] forKey:derKey];
//NSLog(@"Stundenarray nach : %@",[StundenArray description]);
//lastONArray=[[StundenArray valueForKey:@"werkstatt"]copy];
[self setNeedsDisplay:YES];

}

- (void)setStundenArray:(NSArray*)derStundenArray forKey:(NSString*)derKey
{
	//NSLog(@"EEPROMBalken setStundenArray StundenArray: %@", [derStundenArray description]);
	
	int i;
	for (i=0;i<[derStundenArray count];i++)
	{
		int w=[[derStundenArray objectAtIndex:i]intValue];
		[self setStundenarraywert:w vonStunde:i forKey:derKey];
	}
		//NSDictionary* tempDic=[StundenArray objectAtIndex:i];			
		//NSLog(@"StundenArray:  %@",[[StundenArray valueForKey:@"kessel"]description]);
		
	
}



- (void)setNullpunkt:(NSPoint)derPunkt;
{
//Nullpunkt=derPunkt;
		Nullpunkt=[self convertPoint:NSMakePoint(0.0,0.0) toView:NULL];
		NSLog(@"setNullpunkt: Nullpunkt: x: %2.2f y: %2.2f",Nullpunkt.x,Nullpunkt.y);

}

- (void)AllTasteAktion:(id)sender
{
	//NSLog(@"AllTasteAktion");
	//NSLog(@"AllTasteAktion: %d", [(rTagplanbalken*)[sender superview]Wochentag]);
	//NSLog(@"AllTasteAktion: %d", [(rTagplanbalken*)[sender superview]Raum]);
	//NSLog(@"AllTasteAktion: %d", [(rTagplanbalken*)[sender superview]Objekt]);
	//NSLog(@"AllTasteAktion: %@", [(rTagplanbalken*)[sender superview]Titel]);
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:wochentag] forKey:@"wochentag"];
	[NotificationDic setObject:lastONArray forKey:@"lastonarray"];
	[NotificationDic setObject:[NSNumber numberWithInt:raum] forKey:@"raum"];
	[NotificationDic setObject:Titel forKey:@"titel"];
	[NotificationDic setObject:[NSNumber numberWithInt:objekt] forKey:@"objekt"];
	int modKey=0;
	int all=-1;
	if(([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)  != 0)
	{
		//NSLog(@"AllTasteAktion Alt");
		modKey=2;
			[NotificationDic setObject:@"alt" forKey:@"mod"];
			[NotificationDic setObject:lastONArray forKey:@"lastonarray"];
			[NotificationDic setObject:[NSNumber numberWithInt:-1] forKey:@"tag"];
			[NotificationDic setObject:[NSNumber numberWithInt:4] forKey:@"feld"];
			[NotificationDic setObject:[NSNumber numberWithInt:99] forKey:@"stunde"];
			
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			//NSLog(@"Tagplanbalken AllTasteAktion modifier AllFeld");
			[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];

	}
	else
	{
		//NSLog(@"AllTasteAktion Standard");
		modKey=0;
		int lastsum=0;
		int sum=0;
		int i;
		for (i=0;i<24;i++)
		{
			sum+=[[[StundenArray valueForKey:@"code"] objectAtIndex:i]intValue];
			lastsum+=[[lastONArray  objectAtIndex:i]intValue];
		}
		//NSLog(@"sum: %d lastsum: %d",sum, lastsum);
		if (sum==0)//alle sind off: IST wiederherstellen
		{
			if (lastsum) // lastOnArray enthält code
			{
				//NSLog(@"IST wiederherstellen");
				all=9;
			}
			else
			{
				all=3; // lastOnArray enthält noch keinen code, alle ON
			}
			
		}
		
		else if (sum==72)//alle sind ON,
		{
			//NSLog(@"Alle OFF");
			all=0;
		}
		else if (sum && sum<72)//mehrere on: alle ON
		{
			//NSLog(@"IST speichern");
			lastONArray=[[StundenArray valueForKey:@"code"]copy];//Speicherung IST-Zustand
			all=3;
		}
		//NSLog(@"sum: %d lastsum: %d all: %d",sum, lastsum,all);
		
		for (i=0;i<24;i++)
		{
			int ON=[[[StundenArray objectAtIndex:i]objectForKey:@"code"]intValue];
			switch (all)
			{
					
					
				case 0://alle OFF schalten
				case 1://alle ON schalten
				case 2://alle ON schalten
				case 3://alle ON schalten
					ON=all;
					break;
				case 9://Wiederherstellen
					//NSLog(@"IST: lastONArray: %@",[lastONArray description]);
					ON=[[lastONArray objectAtIndex:i]intValue];
					break;
			}//switch all		
		[[StundenArray objectAtIndex:i]setObject:[NSNumber numberWithInt:ON]forKey:@"code"];

		}
		
		
		[NotificationDic setObject:[NSNumber numberWithInt:99] forKey:@"stunde"];// All-Feld
		[NotificationDic setObject:[NSNumber numberWithInt:all] forKey:@"on"];	// code fuer All
		[NotificationDic setObject:[NSNumber numberWithInt:4] forKey:@"feld"]; // All-Feld
		[NotificationDic setObject:lastONArray forKey:@"lastonarray"]; //lastONArray uebergeben

		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"Tagplancode" object:self userInfo:NotificationDic];
		//NSLog(@"all: %d code: %@",all, [[StundenArray valueForKey:@"code"]description]);
		if (all<0)//kein Klick auf ALL-Taste, IST-Zustand speichern
		{
			lastONArray=[[StundenArray valueForKey:@"code"]copy];
		}
		[self setNeedsDisplay:YES];
		
	}// Standard
	
}


- (void)StundenTasteAktion:(NSButton*)sender

{
	//NSLog(@"StundenTasteAktion tag: %d",[sender tag]);
	//NSLog(@"StundenTasteAktion: %d", [(rTagplanbalken*)[sender superview]Wochentag]);
	//NSLog(@"StundenTasteAktion: %d", [(rTagplanbalken*)[sender superview]Raum]);
	//NSLog(@"StundenTasteAktion: %d", [(rTagplanbalken*)[sender superview]Objekt]);
	//NSLog(@"StundenTasteAktion: %@", [(rTagplanbalken*)[sender superview]Titel]);
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:wochentag] forKey:@"wochentag"];
	[NotificationDic setObject:lastONArray forKey:@"lastonarray"];
	
	[NotificationDic setObject:[NSNumber numberWithInt:raum] forKey:@"raum"];
	[NotificationDic setObject:Titel forKey:@"titel"];
	[NotificationDic setObject:[NSNumber numberWithInt:objekt] forKey:@"objekt"];
	//NSLog(@"StundentastenAktion start lastONArray: %@",[lastONArray description]);
	int modKey=0;
	int all=-1;
   if(([[NSApp currentEvent] modifierFlags] & NSEventModifierFlagOption)  != 0)
	{
		NSLog(@"StundenTasteAktion Alt");
		modKey=2;
			[NotificationDic setObject:@"alt" forKey:@"mod"];
		[NotificationDic setObject:[NSNumber numberWithInt:[sender tag]] forKey:@"stunde"];
		//[NotificationDic setObject:[NSNumber numberWithInt:3] forKey:@"on"];
		[NotificationDic setObject:[NSNumber numberWithInt:3] forKey:@"feld"];// Feld U

			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			NSLog(@"StundenTasteAktion Tagplan modifier");
//			[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];
//			modKey=0;
		
		
	}
//	else
	{
		//NSLog(@"StundenTasteAktion Standard");
		
		int ON=[[[StundenArray objectAtIndex:[sender tag]]objectForKey:@"code"]intValue];
		
		//NSLog(@"mouse in Stundentaste:	in Stunde: %d 		ON: %d",[sender tag], ON);
		switch (ON)
		{
			case 0://	ganze Stunde ON setzen
			case 1://	Kessel in der ersten halben Stunde schon ON
			case 2://	Kessel in der zweiten halben Stunde schon ON
				ON=3;//ganze Stunde ON
				break;
				
			case 3:// Kessel in der ganzen Stunde schon ON
				ON=0;//ganze Stunde OFF
				break;
				
		}
		[NotificationDic setObject:[NSNumber numberWithInt:[sender tag]] forKey:@"stunde"];
		[NotificationDic setObject:[NSNumber numberWithInt:ON] forKey:@"on"];
		[NotificationDic setObject:[NSNumber numberWithInt:3] forKey:@"feld"];// Feld U
		
		if (modKey==2)//alt
		{
			[NotificationDic setObject:@"alt" forKey:@"mod"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			//NSLog(@"Tagplan mofdifier StdFeldU");
			[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];
			modKey=0;
			
			//return;
		}
		
		
		
		
		//NSLog(@"Tagplanbalken mouseDow: Stunde: %d code: %d",i,ON);
		[[StundenArray objectAtIndex:[sender tag]]setObject:[NSNumber numberWithInt:ON]forKey:@"code"];
		//NSLog(@"StundenArray: %@",[StundenArray description]);
		//[self setNeedsDisplay:YES];
		
		//NSLog(@"all: %d code: %@",all, [[StundenArray valueForKey:@"code"]description]);
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"Tagplancode" object:self userInfo:NotificationDic];
		
		
		if (all<0)//kein Klick auf ALL-Taste, IST-Zustand speichern
		{
			lastONArray=[[StundenArray valueForKey:@"code"]copy];
		}
		//NSLog(@"StundentastenAktion end  lastONArray: %@",[lastONArray description]);
		
		[self setNeedsDisplay:YES];
		
	}//kein Alt
	
}// 



- (void)WriteTasteAktion:(id)sender
{
	//NSLog(@"WriteTasteAktion tag: %d",[sender tag]);
	//NSLog(@"Wochentag: %d", [(rTagplanbalken*)[sender superview]Wochentag]);
	//NSLog(@"Raum: %d", [(rTagplanbalken*)[sender superview]Raum]);
	//NSLog(@"Objekt: %d", [(rTagplanbalken*)[sender superview]Objekt]);
	//NSLog(@"Titel: %@", [(rTagplanbalken*)[sender superview]Titel]);
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	//[NotificationDic setObject:[NSNumber numberWithInt:Raum] forKey:@"raum"];
	//[NotificationDic setObject:[NSNumber numberWithInt:Wochentag] forKey:@"wochentag"];
	//[NotificationDic setObject:[NSNumber numberWithInt:Objekt] forKey:@"objekt"];// 
	
	
	int modKey=0;
	int all=-1;
	if(([[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask)  != 0)
	{
		NSLog(@"WriteTasteAktion Alt");
		modKey=2;
		[NotificationDic setObject:[NSNumber numberWithInt:modKey] forKey:@"mod"];
		[NotificationDic setObject:[NSArray array] forKey:@"stundenarray"];
		NSLog(@"WriteTasteAktion  WriteModifier: %@",[NotificationDic description]);
		
		// Notific an Wochenplan schicken, um Stundenarrays der ganzen Woche fuer das Objekt zu laden
		// Von dort aus anschliessend an EEPROMWrite schicken
		[nc postNotificationName:@"WriteWochenplanModifier" object:self userInfo:NotificationDic];
		modKey=0;
		
		
	}
		else
	{
		
		[NotificationDic setObject:[NSNumber numberWithInt:modKey] forKey:@"mod"];
//		[NotificationDic setObject:[StundenArray valueForKey:@"code"] forKey:@"stundenarray"];
//		[NotificationDic setObject:[self StundenByteArray] forKey:@"stundenbytearray"];
		
		//NSLog(@"WriteTasteAktion  Standard: %@",[NotificationDic description]);
			
		// Notific an Wochenplan  an EEPROMWrite schicken

//		[nc postNotificationName:@"WriteStandard" object:self userInfo:NotificationDic];
	
	}//WriteTasteAktion Standard
	
}


- (int)Wochentag
{
return wochentag;
}

- (int)Raum
{
return raum;
}

- (int)Objekt
{
return objekt;
}

- (int)TagbalkenTyp
{
return TagbalkenTyp;
}



-(NSString*)Titel
{
   return Titel;
}

- (NSArray*)StundenArray
{
return StundenArray;
}

- (NSArray*)StundenByteArray
{
	NSMutableArray* tempByteArray=[[NSMutableArray alloc]initWithCapacity:0];
	int i, k=3;
	uint8_t Stundenbyte=0;
	NSString* StundenbyteString=[NSString string];
	for (i=0;i<[StundenArray count];i++)
	{	
		uint8_t Stundencode=[[[StundenArray objectAtIndex:i] objectForKey:@"code"]intValue];
		//NSLog(@"StundenByteArray Tag: %d Objekt: %d Stundencode: %02X",Wochentag, Objekt, Stundencode);
		Stundencode=(Stundencode << 2*k);
		//NSLog(@"Stundencode <<: %02X",Stundencode);
		Stundenbyte |=Stundencode;
		//NSLog(@"i: %d      Stundenbyte: %02X",i,Stundenbyte);
		if (k==0)
		{
			
			NSString* ByteString=[NSString stringWithFormat:@"%02X ",Stundenbyte];
			//NSLog(@"      Stundenbyte: %02X ByteString: %@",Stundenbyte , ByteString);
			StundenbyteString=[StundenbyteString stringByAppendingString:ByteString] ;
			[tempByteArray addObject:[NSNumber numberWithInt:Stundenbyte]];
			Stundenbyte=0;
			k=3;
		}
		else
		{
			k--;
		}
		
	}// for i
	//NSLog(@"StundenbyteString: %@",StundenbyteString);
	return tempByteArray;
}

/*
- (int)tag
{
//NSLog(@"Tagplanbalken tag: %d",mark);
return mark;
}
 */
- (void)drawRect:(NSRect)dasFeld 
{

    NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA",@"SO",nil];
	[[NSColor blackColor]set];
	//[NSBezierPath strokeRect:dasFeld];
	
	float vargray=0.8;
	//NSLog(@"sinus: %2.2f",varRed);
	NSColor* tempGrayColor=[NSColor colorWithCalibratedRed:vargray green: vargray blue: vargray alpha:0.8];
	[tempGrayColor set];
	[NSBezierPath fillRect:dasFeld];
	NSFont* StundenFont=[NSFont fontWithName:@"Helvetica" size: 9];
	NSDictionary* StundenAttrs=[NSDictionary dictionaryWithObject:StundenFont forKey:NSFontAttributeName];
	NSFont* TagFont=[NSFont fontWithName:@"Helvetica" size: 9];
	NSDictionary* TagAttrs=[NSDictionary dictionaryWithObject:TagFont forKey:NSFontAttributeName];
	NSPoint TagPunkt=NSMakePoint(0.0,0.0);
	NSFont* TitelFont=[NSFont fontWithName:@"Helvetica" size: 10];
	NSDictionary* TitelAttrs=[NSDictionary dictionaryWithObject:TitelFont forKey:NSFontAttributeName];

	//
	TagPunkt.x+=5;
	TagPunkt.y+=Elementhoehe*9/16;
	//NSLog(@"EEPROMbalken drawRect: Titel: %@",Titel);
	[WochentagString drawAtPoint:TagPunkt withAttributes:TitelAttrs];
	
	
	TagPunkt.x +=30;
	[RaumString drawAtPoint:TagPunkt withAttributes:TagAttrs];

	TagPunkt.y -=12;
	[ObjektString drawAtPoint:TagPunkt withAttributes:TagAttrs];
	
	//NSLog(@"Tag: %d Tagpunkt x: %2.2f  y: %2.2f",tag, TagPunkt.x, TagPunkt.y);
//	[[Wochentage objectAtIndex:tag] drawAtPoint:TagPunkt withAttributes:TagAttrs];
	/*
	NSRect AllFeld=[[[StundenArray objectAtIndex:23]objectForKey:@"elementrahmen"]frame];
	AllFeld.origin.x+=Elementbreite+2;
	//AllFeld.origin.y+=8;
	AllFeld.size.height-=8;
	AllFeld.size.width/=1.8;
	[[NSColor grayColor]set];
//	[NSBezierPath fillRect:AllFeld];
//	[NSBezierPath strokeRect:AllFeld];
	*/
	int i;
	for (i=0;i<24;i++)
	{
		//NSLog(@"WS drawRect: y %2.2f",[[[StundenArray objectAtIndex:i]objectForKey:@"elementrahmen"]frame].origin.y);
		NSRect StdFeld=[[[StundenArray objectAtIndex:i]objectForKey:@"elementrahmen"]frame];
		
		NSString* Stunde=[[NSNumber numberWithInt:i]stringValue];
		NSPoint p=StdFeld.origin;
		StdFeld.size.height-=10;
		p.y+=StdFeld.size.height;
		p.x-=4;
		if (i>9)
			p.x-=4;
		[Stunde drawAtPoint:p withAttributes:StundenAttrs];
		if (i==23)
		{
			Stunde=[[NSNumber numberWithInt:24]stringValue];
			p.x+=Elementbreite;
			[Stunde drawAtPoint:p withAttributes:StundenAttrs];
		}
		[[NSColor blueColor]set];
		StdFeld.size.height-=6;
		StdFeld.origin.y+=4;
		//NSLog(@"i: %d Eckex: %2.2f h: %2.2f b: %2.2f",i,StdFeld.origin.x,StdFeld.size.height,StdFeld.size.width);
      //		[NSBezierPath fillRect:StdFeld];
		
		NSRect StdFeldL=StdFeld;
		StdFeldL.size.width/=2;
		StdFeldL.size.width-=2;
		StdFeldL.origin.x+=1;
		
      
		NSRect StdFeldR=StdFeld;
		StdFeldR.origin.x+=(StdFeld.size.width/2)+1;
		StdFeldR.size.width/=2;
		StdFeldR.size.width-=2;
		
		NSRect StdFeldG=StdFeld;
		StdFeldG.origin = StdFeldL.origin;
		StdFeldG.size.width-=2;
		

      if (TagbalkenTyp == 0)
      {
         [[NSColor blueColor]set];
         [NSBezierPath strokeRect:StdFeldL];
         
         
         [[NSColor blueColor]set];
         [NSBezierPath strokeRect:StdFeldR];
      }
      else if (TagbalkenTyp == 1)
      {
         [[NSColor blueColor]set];
         [NSBezierPath strokeRect:StdFeldG];
         
      }
      
		int ON=[[[StundenArray objectAtIndex:i]objectForKey:@"code"]intValue];
      if (TagbalkenTyp == 0)
      {
         
         switch (ON)
         {
               
            case 0://ganze Stunde OFF
               [[NSColor whiteColor]set];
               [NSBezierPath fillRect:StdFeldL];
               [NSBezierPath fillRect:StdFeldR];
               
               break;
            case 2://erste halbe Stunde ON
               [[NSColor redColor]set];
               [NSBezierPath fillRect:StdFeldL];
               [[NSColor whiteColor]set];
               [NSBezierPath fillRect:StdFeldR];
               
               
               break;
            case 1://zweite halbe Stunde ON
               [[NSColor redColor]set];
               [NSBezierPath fillRect:StdFeldR];
               [[NSColor whiteColor]set];
               [NSBezierPath fillRect:StdFeldL];
               
               break;
            case 3://ganze Stunde ON
               [[NSColor redColor]set];
               [NSBezierPath fillRect:StdFeldL];
               [NSBezierPath fillRect:StdFeldR];
               break;
               
         } 
      }// typ 0
      else if (TagbalkenTyp == 1)
      {
         switch (ON)
         {
               
            case 0://ganze Stunde OFF
               [[NSColor whiteColor]set];
               [NSBezierPath fillRect:StdFeldG];
               
               
               break;
            case 2://ganze Stunde ON
            case 1:
            case 3:
               [[NSColor redColor]set];
               [NSBezierPath fillRect:StdFeldG];
                
               
               break;
         } // typ 1
      }
	}//for i
}

- (void)mouseDown:(NSEvent *)theEvent
{
   return;
	//	NSLog(@"Tagplanbalken mouseDown: event: x: %2.2f y: %2.2f",[theEvent locationInWindow].x,[theEvent locationInWindow].y);
	//NSLog(@"mouseDown: Nullpunkt: x: %2.2f y: %2.2f",Nullpunkt.x,Nullpunkt.y);
	//NSLog(@"Bounds: x: %2.2f y: %2.2f h: %2.2f w: %2.2f ",[self frame].origin.x,[self frame].origin.y,[self frame].size.height,[self frame].size.width);
	//NSLog(@"mouseDown: modifierFlags: %",[theEvent modifierFlags]);
	//		NSLog(@"mouseDown Stundenarray: %@",[[StundenArray valueForKey:@"werkstatt"] description]);
	// NSLog(@"mouseDown: objekt: %d",Raum );
	int MausIN=0;
	unsigned int Mods=[theEvent modifierFlags];
	int modKey=0;
   if (Mods & NSEventModifierFlagCommand)
	{
		NSLog(@"mouseDown: Command");
		modKey=1;
	}
   else if (Mods & NSEventModifierFlagControl)
	{
		NSLog(@"mouseDown: Control");
		modKey=3;
	}
	
   else if (Mods & NSEventModifierFlagOption)
	{
		NSLog(@"mouseDown: Alt");
		modKey=2;
		
	}
	
	
	NSRect AllFeld=[[[StundenArray objectAtIndex:23]objectForKey:@"elementrahmen"]frame];
	AllFeld.origin.x+=Elementbreite+2;
	//AllFeld.origin.y+=8;
	AllFeld.size.height-=8;
	AllFeld.size.width/=2;
	
	NSPoint globMaus=[theEvent locationInWindow];
	//NSPoint Ecke=[self bounds].origin;
	NSPoint localMaus;
	localMaus=[self convertPoint:globMaus fromView:NULL];
	//NSLog(@"mouseDown: local: x: %2.2f y: %2.2f",localMaus.x,localMaus.y);
	
	//NSLog(@"lastONArray: %@",[lastONArray description]);
	int i;
	int all=-1;
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:wochentag] forKey:@"wochentag"];
	[NotificationDic setObject:lastONArray forKey:@"lastonarray"];
	[NotificationDic setObject:[NSNumber numberWithInt:raum] forKey:@"raum"];
	[NotificationDic setObject:Titel forKey:@"titel"];
	[NotificationDic setObject:[NSNumber numberWithInt:objekt] forKey:@"objekt"];
	
	
	if ([self mouse:localMaus inRect:AllFeld])
	{
		if (modKey==2)//alt
		{
			//NSLog(@"ALL-Taste mit alt");
			[NotificationDic setObject:@"alt" forKey:@"mod"];
			
			[NotificationDic setObject:lastONArray forKey:@"lastonarray"];
			[NotificationDic setObject:[NSNumber numberWithInt:-1] forKey:@"tag"];
			[NotificationDic setObject:[NSNumber numberWithInt:4] forKey:@"feld"];
			[NotificationDic setObject:[NSNumber numberWithInt:99] forKey:@"stunde"];
			
//			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			NSLog(@"Tagplanbalken mofdifier AllFeld");
			//[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];
			
			return;
		}
		int lastsum=0;
		int sum=0;
		for (i=0;i<24;i++)
		{
			sum+=[[[StundenArray valueForKey:@"code"] objectAtIndex:i]intValue];
			lastsum+=[[lastONArray  objectAtIndex:i]intValue];
		}
		//NSLog(@"sum: %d lastsum: %d",sum, lastsum);
		if (sum==0)//alle sind off: IST wiederherstellen
		{
			if (lastsum) // lastOnArray enthält code
			{
				NSLog(@"IST wiederherstellen");
				all=2;
			}
			else
			{
				all=3; // lastOnArray enthält noch keinen code
			}
			
		}
		
		else if (sum==72)//alle sind ON,
		{
			NSLog(@"Alle OFF");
			all=0;
		}
		else if (sum && sum<72)//mehrere on: alle ON
		{
			NSLog(@"IST speichern");
			lastONArray=[[StundenArray valueForKey:@"code"]copy];//Speicherung IST-Zustand
			all=3;
		}
		
		[NotificationDic setObject:[NSNumber numberWithInt:99] forKey:@"stunde"];// All-Feld
		[NotificationDic setObject:[NSNumber numberWithInt:all] forKey:@"on"];	// code fuer All
		[NotificationDic setObject:[NSNumber numberWithInt:4] forKey:@"feld"]; // All-Feld
		
	
	}
	
	
	
	for (i=0;i<24;i++) // alle Tastenfelder abfragen
	{
		
		NSRect StdFeld=[[[StundenArray objectAtIndex:i]objectForKey:@"elementrahmen"]frame];
		
		StdFeld.size.height-=10;
		StdFeld.size.height-=8;
		StdFeld.origin.y+=8;
		
		NSRect StdFeldL=StdFeld;
		StdFeldL.size.width/=2;
		StdFeldL.size.width-=2;
		StdFeldL.origin.x+=1;
		NSRect StdFeldR=StdFeld;
		StdFeldR.origin.x+=(StdFeld.size.width/2)+1;
		StdFeldR.size.width/=2;
		StdFeldR.size.width-=2;
		
		NSRect StdFeldU=StdFeld;
		StdFeldU.size.height=5;
		StdFeldU.origin.y-=8;
		
		int ON=[[[StundenArray objectAtIndex:i]objectForKey:@"code"]intValue];
		if (modKey==2)//alt
		{
			[NotificationDic setObject:@"alt" forKey:@"mod"];
			//[NotificationDic setObject:Raum forKey:@"quelle"];
			[NotificationDic setObject:[NSNumber numberWithInt:wochentag] forKey:@"tag"];
		}
		if ([self mouse:localMaus inRect:StdFeldL])
		{
			
			
			//NSLog(@"mouse in Stunde: %d in Feld links ON: %d",i, ON);
			
			switch (ON)
			{
				case 0:// werkstatt in der ersten halben Stunde neu einschalten __ > |_
					ON=2;//Bit 2
					break;
					
				case 1:// Kessel in der ersten halbe Stunde neu einschalten _| > ||
					ON=3;
					break;
					
				case 2:// Kessel in der ersten halben Stunde neu ausschalten || > _|
					ON=0;
					break;
					
				case 3: // Kessel in der ersten halben Stunde neu ausschalten || > _|
					ON=1;
					break;
			}//switch ON
			[NotificationDic setObject:[NSNumber numberWithInt:i] forKey:@"stunde"];
			[NotificationDic setObject:[NSNumber numberWithInt:ON] forKey:@"on"];
			[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"feld"];
			
			if (modKey==2)//alt
			{
				NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
				NSLog(@"Tagplanbalken mofdifier StdFeldL");
				[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];
				modKey=0;
				//return;
				
			}
			
		MausIN=1;	
		}
		else if ([self mouse:localMaus inRect:StdFeldR])
		{
			//NSLog(@"mouse in Stunde: %d in Feld rechts ON: %d",i,ON);
			switch (ON)
			{
				case 0:// Kessel in der zweiten halben Stunde neu einschalten
					ON=1;
					break;
				case 1://	Kessel in der zweiten halben Stunde neu ausschalten
					ON=0;
					break;
				case 2:// Kessel in der zweiten halben Stunde neu einschalten
					ON=3;
					break;
				case 3:// Kessel in der zweiten halben Stunde neu ausschalten
					ON=2;
					break;
					
			}
			[NotificationDic setObject:[NSNumber numberWithInt:i] forKey:@"stunde"];
			[NotificationDic setObject:[NSNumber numberWithInt:ON] forKey:@"on"];
			[NotificationDic setObject:[NSNumber numberWithInt:2] forKey:@"feld"];
			
			if (modKey==2)//alt
			{
				[NotificationDic setObject:@"alt" forKey:@"mod"];
				NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
				NSLog(@"Tagplan mofdifier StdFeldR");
				[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];
				modKey=0;
				//return;
			}
			MausIN=1;
		}
		else if ([self mouse:localMaus inRect:StdFeldU])
		{
			//NSLog(@"mouse in Stunde: %d in Feld Unten ON: %d",i, ON);
			switch (ON)
			{
				case 0://ganze Stunde ON
				case 1://	Kessel in der ersten halben Stunde schon ON
				case 2://	Kessel in der zweiten halben Stunde schon ON
					ON=3;//ganze Stunde ON
					break;
					
				case 3:// Kessel in der ganzen Stunde schon ON
					ON=0;//ganze Stunde OFF
					break;
					
			}
			[NotificationDic setObject:[NSNumber numberWithInt:i] forKey:@"stunde"];
			[NotificationDic setObject:[NSNumber numberWithInt:ON] forKey:@"on"];
			[NotificationDic setObject:[NSNumber numberWithInt:3] forKey:@"feld"];// Feld U
			
			if (modKey==2)//alt
			{
				[NotificationDic setObject:@"alt" forKey:@"mod"];
				NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
				//NSLog(@"mousedown Tagplan mofdifier StdFeldU");
				[nc postNotificationName:@"Modifier" object:self userInfo:NotificationDic];
				modKey=0;
				
				//return;
			}
			
		}
		
		switch (all)
		{
			case 0://alle OFF schalten
			case 3://alle ON schalten
				ON=all;
				break;
			case 2://Wiederherstellen
				//NSLog(@"IST: lastONArray: %@",[lastONArray description]);
				ON=[[lastONArray objectAtIndex:i]intValue];
				break;
		}//switch all		
		
		//NSLog(@"Tagplanbalken mouseDow: Stunde: %d code: %d",i,ON);
		[[StundenArray objectAtIndex:i]setObject:[NSNumber numberWithInt:ON]forKey:@"code"];
		//NSLog(@"StundenArray: %@",[StundenArray description]);
		//[self setNeedsDisplay:YES];
		
		
		
	}//for i
	
	if (MausIN)
	{
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"Tagplancode" object:self userInfo:NotificationDic];
	}
	//NSLog(@"all: %d code: %@",all, [[StundenArray valueForKey:@"code"]description]);
	if (all<0)//kein Klick auf ALL-Taste, IST-Zustand speichern
	{
		lastONArray=[[StundenArray valueForKey:@"code"]copy];
	}
	[self setNeedsDisplay:YES];
}


@end
