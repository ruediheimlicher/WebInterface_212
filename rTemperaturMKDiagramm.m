//
//  rTemperaturMKDiagramm.m
//  WebInterface
//
//  Created by Sysadmin on 11.Februar.09.
//  Copyright 2009 Ruedi Heimlicher. All rights reserved.
//

#import "rTemperaturMKDiagramm.h"


@implementation rTemperaturMKDiagramm

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) 
	{
		[DatenTitelArray replaceObjectAtIndex:0 withObject:@"HV"]; // Vorlauf
		[DatenTitelArray replaceObjectAtIndex:1 withObject:@"HR"]; // Ruecklauf
		[DatenTitelArray replaceObjectAtIndex:2 withObject:@"A"];
		[DatenTitelArray replaceObjectAtIndex:7 withObject:@"I"];
      
      [DatenTitelArray replaceObjectAtIndex:8 withObject:@"SV"]; // Sole Vorlauf
      [DatenTitelArray replaceObjectAtIndex:9 withObject:@"SR"]; // Sole Ruecklauf

        // Initialization code here.
    }
    return self;
}
- (void)setOffsetY:(int)y
{
[super setOffsetY:y];
}
- (void)setWert:(NSPoint)derWert  forKanal:(int)derKanal;

{

}
- (void)setEinheitenDicY:(NSDictionary*)derEinheitenDic
{
	[super setEinheitenDicY:derEinheitenDic];
}

- (void)setWertMitX:(float)x mitY:(float)y forKanal:(int)derKanal
{

}
- (void)setStartWerteArray:(NSArray*)Werte
{

}
- (void)setWerteArray:(NSArray*)derWerteArray mitKanalArray:(NSArray*)derKanalArray
{
   // KanalArray: 8 Elemente, 1 wenn Kanal eingeschaltet
   // WerteArray: Werte aus Web. Elemente: Array, 1. Wert ist tagsekunde, 8 Werte aus Messungen
   /*
    2016-12-11 08:16:16.348649 WebInterface[18002:3445796] setWerteArray WerteArray: (
    0,
    66,
    64,
    31,
    4,
    0,
    65,
    0,
    34
    )
    */
   //NSLog(@"Temp MKDiagramm setWerteArray WerteArray: %@ KanalArray: %@",[derWerteArray description],[derKanalArray description]);
   //NSLog(@"TempMKDiagramm setWerteArray KanalArray count: %d",[derKanalArray count]);
	int i;
	
	float	maxSortenwert=127.5;	// Temperatur, 100° entspricht 200
	float	SortenFaktor= 1.0;
	float	maxAnzeigewert=MaxY-MinY;
	float AnzeigeFaktor= maxSortenwert/maxAnzeigewert;
	//NSLog(@"setWerteArray: FaktorY: %2.2f MaxY; %2.2F MinY: %2.2F maxAnzeigewert: %2.2F AnzeigeFaktor: %2.2F",FaktorY,MaxY,MinY,maxAnzeigewert, AnzeigeFaktor);
   //NSLog(@"setWerteArray:SortenFaktor: %2.2f",SortenFaktor);
   //NSLog(@"setWerteArray:count: %lu",(unsigned long)[derWerteArray count]);
   
	for (i=0;i<[derWerteArray count]-1;i++) // erster Wert ist Abszisse
   //for (i=0;i<8;i++) // erster Wert ist Abszisse // nur erste 9 Werte für Homediagramm
      {
		if ((i<[derKanalArray count]-1) && [derKanalArray objectAtIndex:i] && ([[derKanalArray objectAtIndex:i]intValue]))
      {
         //NSLog(@"+++			Temperatur  setWerteArray: Kanal: %d	x: %2.2f",i,[[derWerteArray objectAtIndex:0]floatValue]);
         NSPoint neuerPunkt=DiagrammEcke;
         
         neuerPunkt.x += [[derWerteArray objectAtIndex:0]floatValue]*ZeitKompression;	//	Zeit, x-Wert, erster Wert im WerteArray
         
         float InputZahl=[[derWerteArray objectAtIndex:i+1]floatValue];	// Input vom IOW, 0-255
         
         // Korrektur bei i=2: Aussentemperatur um 16 reduzieren
         if (i==2)
         {
            InputZahl -= 32;
            
         }
         if (i==6)
         {
            //NSLog(@"setWerteArray: Kanal: %d InputZahl: %2.2F",i,InputZahl);
            //		InputZahl=80;
         }
         
         float graphZahl=(InputZahl-2*MinY)*FaktorY;								// Red auf reale Diagrammhoehe
         
         float rawWert=graphZahl*SortenFaktor;							// Wert fuer Anzeige des ganzen Bereichs
         
         float DiagrammWert=(rawWert)*AnzeigeFaktor;
         //NSLog(@"setWerteArray: Kanal: %d InputZahl: %2.2F graphZahl: %2.2F rawWert: %2.2F DiagrammWert: %2.2F",i,InputZahl,graphZahl,rawWert,DiagrammWert);
         
         neuerPunkt.y += DiagrammWert;
         //neuerPunkt.y=InputZahl;
         //NSLog(@"setWerteArray: Kanal: %d MinY: %2.2F FaktorY: %2.2f",i,MinY, FaktorY);
         
         //NSLog(@"setWerteArray: Kanal: %d InputZahl: %2.2F FaktorY: %2.2f graphZahl: %2.2F rawWert: %2.2F DiagrammWert: %2.2F ",i,InputZahl,FaktorY, graphZahl,rawWert,DiagrammWert);
         
         NSString* tempWertString=[NSString stringWithFormat:@"%2.1f",InputZahl/2.0];
         //NSLog(@"neuerPunkt.y: %2.2f tempWertString: %@",neuerPunkt.y,tempWertString);
         
         NSArray* tempDatenArray=[NSArray arrayWithObjects:[NSNumber numberWithFloat:neuerPunkt.x],[NSNumber numberWithFloat:neuerPunkt.y],tempWertString,nil];
         NSDictionary* tempWerteDic=[NSDictionary dictionaryWithObjects:tempDatenArray forKeys:[NSArray arrayWithObjects:@"x",@"y",@"wert",nil]];
         if (i < [DatenArray count])
         {
            [[DatenArray objectAtIndex:i] addObject:tempWerteDic];
         }
         NSBezierPath* neuerGraph=[NSBezierPath bezierPath];
         if (i<[GraphArray count])
         { 
            if ([[GraphArray objectAtIndex:i]isEmpty]) // letzter Punkt ist leer, Anfang eines neuen Linienabschnitts
            {
               neuerPunkt.x=DiagrammEcke.x;
               [neuerGraph moveToPoint:neuerPunkt];
               [[GraphArray objectAtIndex:i]appendBezierPath:neuerGraph];
               
            }
            else
            {
               [neuerGraph moveToPoint:[[GraphArray objectAtIndex:i]currentPoint]];//last Point
               [neuerGraph lineToPoint:neuerPunkt];
               [[GraphArray objectAtIndex:i]appendBezierPath:neuerGraph];
            }
         }
      }// if Kanal
	} // for i
	[GraphKanalArray setArray:derKanalArray];
   //	[self setNeedsDisplay:YES];
}


- (void)setWerteArray:(NSArray*)derWerteArray mitKanalArray:(NSArray*)derKanalArray mitVorgabenDic:(NSDictionary*)dieVorgaben
{

}

- (void)drawRect:(NSRect)rect
{
   NSLog(@"********************");
	NSLog(@"MKDiagramm drawRect");
   NSLog(@"********************");
	NSRect NetzBoxRahmen=[self bounds];//NSMakeRect(NetzEcke.x,NetzEcke.y,200,100);
	NetzBoxRahmen.size.height-=10;
	NetzBoxRahmen.size.width-=15;
	//NetzBoxRahmen.origin.x+=0.2;
	//NSLog(@"NetzBoxRahmen x: %f y: %f h: %f w: %f",NetzBoxRahmen.origin.x,NetzBoxRahmen.origin.y,NetzBoxRahmen.size.height,NetzBoxRahmen.size.width);
	
	[[NSColor greenColor]set];
	//[NSBezierPath strokeRect:NetzBoxRahmen];
	
	NSBezierPath* SenkrechteLinie=[NSBezierPath bezierPath];
	
	NSPoint untenV=DiagrammEcke;
	NSPoint obenV=untenV;
	NSPoint links=untenV;
	obenV.x=untenV.x;
	obenV.y+=NetzBoxRahmen.size.height;
	NSPoint mitteH=DiagrammEcke;
	mitteH.y+=(NetzBoxRahmen.size.height)/256*NullpunktY;
	
	[SenkrechteLinie moveToPoint:untenV];
	[SenkrechteLinie lineToPoint:obenV];
	[SenkrechteLinie stroke];
	
	for (int i=0;i<[NetzlinienX count];i++)
	{
		untenV.x=[[NetzlinienX objectAtIndex:i]floatValue];
		untenV.y=mitteH.y;
		obenV.x=untenV.x;
		obenV.y=[[NetzlinienY objectAtIndex:i]floatValue];
		[SenkrechteLinie moveToPoint:untenV];
		[SenkrechteLinie lineToPoint:obenV];
		[SenkrechteLinie stroke];
	}
	
	NSBezierPath* WaagrechteLinie=[NSBezierPath bezierPath];
	int k;
	NSPoint untenH=DiagrammEcke;
	NSPoint rechtsH=untenH;
	NSPoint linksH=untenH;
	rechtsH.x=untenH.x;
	rechtsH.x+=NetzBoxRahmen.size.width-5;
	/*
	 [WaagrechteLinie moveToPoint:untenH];
	 [WaagrechteLinie lineToPoint:rechtsH];
	 [WaagrechteLinie stroke];
	 */
	
	
	NSBezierPath* WaagrechteMittelLinie=[NSBezierPath bezierPath];
	
	NSPoint mitterechtsH=mitteH;
	mitterechtsH.y=mitteH.y;
	mitterechtsH.x+=NetzBoxRahmen.size.width-5;
	
	[WaagrechteMittelLinie moveToPoint:mitteH];
	[WaagrechteMittelLinie lineToPoint:mitterechtsH];
	//	[WaagrechteMittelLinie stroke];
	
	[self waagrechteLinienZeichnen];
	
	untenH.y=mitteH.y+100;
	rechtsH.y=mitterechtsH.y+100;
	[WaagrechteLinie moveToPoint:untenH];
	[WaagrechteLinie lineToPoint:rechtsH];
	//	[WaagrechteLinie stroke];
	
	untenH.y=mitteH.y-100;
	rechtsH.y=mitterechtsH.y-100;
	[WaagrechteLinie moveToPoint:untenH];
	[WaagrechteLinie lineToPoint:rechtsH];
	//	[WaagrechteLinie stroke];
   
   rDatenlegende* DatenLegende = [[rDatenlegende alloc]init];
   
   /*
    interface rDatenlegende : NSObject
    {
       float randunten, randoben, abstandnach, abstandvor, mindistanz;
       NSMutableArray* LegendeArray;
    }
    - (void)setVorgabenDic:(NSDictionary*)vorgabendic;
    - (void)setLegendeArray:(NSArray*)array;
    - (NSArray*)LegendeArray;

    end

    */
   
   // Datenanschrift ordnen
   
   int schriftgroesse = 9;
   NSMutableDictionary* ZeitAttrs=[[NSMutableDictionary alloc]initWithCapacity:0];
   NSMutableParagraphStyle* ZeitPar=[[NSMutableParagraphStyle alloc]init];
   
   [ZeitPar setAlignment:NSTextAlignmentRight];
	[ZeitAttrs setObject:ZeitPar forKey:NSParagraphStyleAttributeName];
	NSFont* ZeitFont=[NSFont fontWithName:@"Helvetica" size: schriftgroesse];
	
	[ZeitAttrs setObject:ZeitFont forKey:NSFontAttributeName];
   
   float miny = [self frame].size.height;
   float maxy = 0;
   float legendex = 0;
   
   // Abstaende bestimmen
   int abstandy = schriftgroesse+2;
   int grundabstand=schriftgroesse;
   int deltay=0;
   
   NSMutableArray* LegendeArray = [[NSMutableArray alloc]initWithCapacity:0];
   // Ordinaten nach Wert sortiert in IndexSet setzen
   
   for (int i=0;i<12;i++)
   {
       if ([[GraphKanalArray objectAtIndex:i]intValue]) // Kanal ist aktiv
		{
         //aktuellen Punkt bestimmen, index: Nummerierung der vorhandenen Kanaele
         NSPoint cP=[[GraphArray objectAtIndex:i]currentPoint];
         NSDictionary* wertDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:cP.y],@"wert",
                                  [NSNumber numberWithInt:i],@"index",
                                  nil];
         
         [LegendeArray addObject:wertDic];
         
         // Bereich bestimmen
         miny = fmin(miny,cP.y);
         maxy = fmax(maxy,cP.y);
      }
   }
 //  NSLog(@"miny: %.2f maxy: %.2f LegendeArray: %@",miny,maxy,[[LegendeArray valueForKey:@"wert"] description]);
   NSLog(@"miny: %.2f maxy: %.2f LegendeArray: %@",miny,maxy,[LegendeArray  description]);
   
   // Werte sind nicht geordnet nach index > sortieren nach wert: Reihenfolge in y-Richtung, Index ist zuteilung zu Grapharray
   
   NSComparator sortByNumber = ^(id dict1, id dict2)
   {
      NSNumber* n1 = [dict1 objectForKey:@"wert"];
      NSNumber* n2 = [dict2 objectForKey:@"wert"];
      return (NSComparisonResult)[n1 compare:n2];
   };
   [LegendeArray sortUsingComparator: sortByNumber];
   NSLog(@"LegendeArray nach sort wert: %@",[LegendeArray description]);
   //NSLog(@"LegendeArray nach sort wert: %@",[[LegendeArray valueForKey:@"wert"]description]);
   
   [DatenLegende setLegendeArray:LegendeArray]; // in Struktur einetzen
   
   LegendeArray = (NSMutableArray*)[DatenLegende LegendeArray];// vollstaendige LegendeArray zurueckholen
   
   NSLog(@"LegendeArray nach setLegendeArray: %@",[LegendeArray description]);
   
   NSComparator sortByIndex = ^(id dict1, id dict2)
   {
      NSNumber* n1 = [dict1 objectForKey:@"index"];
      NSNumber* n2 = [dict2 objectForKey:@"index"];
      return (NSComparisonResult)[n1 compare:n2];
   };
   
   [LegendeArray sortUsingComparator: sortByIndex];
   //NSLog(@"LegendeArray nach sort index: %@",[[LegendeArray valueForKey:@"index"]description]);
   NSLog(@"LegendeArray nach sort index: %@",[LegendeArray description]);
   
   //NSRect Datalegenderect = NSMakeRect(legendex, miny-2, 20, maxy-miny+8);
   //NSBezierPath* DatalegendeGraph=[NSBezierPath bezierPathWithRect:Datalegenderect];
   //[DatalegendeGraph stroke];
   
   
   int legendeindex=0;
   
   NSArray* LegendeOrdinatenArray = [LegendeArray valueForKey:@"legendeposition"];
   NSLog(@"***LegendeOrdinatenArray: %@",[LegendeOrdinatenArray description]);
   
   
   // [[[GraphArray objectAtIndex:i]objectForKey:@"zeitstring"]drawAtPoint:SchriftPunkt withAttributes:ZeitAttrs];

   for (int i=0;i<12;i++)
	{
      if (i==0)
      {
         //NSLog(@"TempMKDiag. draw DatenTitelArray count: %d DatenFeldArray count: %d DatenWertArray count: %d",[DatenTitelArray count],[DatenFeldArray count],[DatenWertArray count]);
      }

		//NSLog(@"drawRect Farbe Kanal: %d Color: %@",i,[[GraphFarbeArray objectAtIndex:i] description]);
		if ([[GraphKanalArray objectAtIndex:i]intValue])
		{
			[(NSColor*)[GraphFarbeArray objectAtIndex:i]set];
			[[GraphArray objectAtIndex:i]stroke];
         
         
			NSPoint cP=[[GraphArray objectAtIndex:i]currentPoint];
         NSBezierPath* legendeGraph=[NSBezierPath bezierPath];
         [legendeGraph moveToPoint:cP];
         [legendeGraph setLineWidth:0.5];
         
			cP.x+=16;
         cP.y = [[LegendeOrdinatenArray objectAtIndex:legendeindex]floatValue];
         
         legendeindex ++;
			
         [legendeGraph lineToPoint:cP];
         cP.x+=4;
         [legendeGraph lineToPoint:cP];
         [legendeGraph stroke];
         cP.y-=12;
			[[DatenFeldArray objectAtIndex:i]setFrameOrigin:cP];
         
         
         cP.x+=8;
         [[DatenWertArray objectAtIndex:i]setFrameOrigin:cP];
         [[DatenFeldArray objectAtIndex:i]setStringValue:[NSString stringWithFormat:@"%@:",[DatenTitelArray objectAtIndex:i]]];
         [[DatenWertArray objectAtIndex:i]setStringValue:[NSString stringWithFormat:@"%@",[[[DatenArray objectAtIndex:i]lastObject]objectForKey:@"wert"]]];
         
			//NSLog(@"drawRect: %@",[[DatenArray objectAtIndex:i]description]);
			
			//NSString* AnzeigeString=[NSString stringWithFormat:@"%@: %@",[DatenTitelArray objectAtIndex:i],[[[DatenArray objectAtIndex:i]lastObject]objectForKey:@"wert"]];
         
			//[[DatenFeldArray objectAtIndex:i]setStringValue:AnzeigeString];
			//		[[DatenFeldArray objectAtIndex:i]setStringValue:[[[DatenArray objectAtIndex:i]lastObject]objectForKey:@"wert"]];
		}
      
	}
	
	
	
}
@end
