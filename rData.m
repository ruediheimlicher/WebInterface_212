//
//  rData.m
//  WebInterface
//
//  Created by Sysadmin on 05.02.09.
//  Copyright 2008 Ruedi Heimlicher. All rights reserved.
//
#include <netdb.h>
#include <arpa/inet.h>

#import "rData.h"
#import "rHeizungplan.h"

#define MO 0
#define DI 1

// http://stackoverflow.com/questions/111928/is-there-a-printf-converter-to-print-in-binary-format?page=1&tab=votes#tab-top

const char *byte_to_binary_a(int x)
{
   static char b[9];
   b[0] = '\0';
   
   int z;
   for (z = 128; z > 0; z >>= 1)
   {
      strcat(b, ((x & z) == z) ? "1" : "0");
   }
   
   return b;
}

const char *byte_to_binary(int x)
{
   static char b[9];
   b[0] = '\0';
   
   int z;
   char *p = b;
   for (z = 128; z > 0; z >>= 1)
   {
      *p++ = (x & z) ? '1' : '0';
   }
   return b;
}

int bit_to_binary(int x,int anz)
{
   static char b[9];
   b[0] = '\0';
   
   int z;
   char *p = b;
   for (z = 128; z > 0; z >>= 1)
   {
      *p++ = (x & z) ? '1' : '0';
   }
   int c =  (int)b;
   c &= 0x04;

   return b;
}





const char bit_rep[16] =
{
   [ 0] = '0000', [ 1] = '0001', [ 2] = '0010', [ 3] = '0011',
   [ 4] = '0100', [ 5] = '0101', [ 6] = '0110', [ 7] = '0111',
   [ 8] = '1000', [ 9] = '1001', [10] = '1010', [11] = '1011',
   [12] = '1100', [13] = '1101', [14] = '1110', [15] = '1111',
};


extern NSMutableArray* DatenplanTabelle;

@implementation rData
- (void) logRect:(NSRect)r
{
	NSLog(@"logRect: origin.x %2.2f origin.y %2.2f size.heigt %2.2f size.width %2.2f",r.origin.x, r.origin.y, r.size.height, r.size.width);
}

- (void)Alert:(NSString*)derFehler
{
	
   NSAlert * DebugAlert=[[NSAlert alloc]init];
   DebugAlert.messageText= @"Debugger!";
   DebugAlert.informativeText = [NSString stringWithFormat:@"Mitteilung: \n%@",derFehler];
   
   [DebugAlert runModal];
	
}

- (NSString*)IntToBin:(int)dieZahl
{
	int rest=0;
	int zahl=dieZahl;
	NSString* BinString=[NSString string];;
	while (zahl)
	{
		rest=zahl%2;
		if (rest)
		{
			BinString=[@"1" stringByAppendingString:BinString];
		}
		else
		{
			BinString=[@"0" stringByAppendingString:BinString];
		}
		zahl/=2;
		//NSLog(@"BinString: %@",BinString);
	}
	return BinString;
}

- (int)HexStringZuInt:(NSString*) derHexString
{
	uint returnInt=-1;
	NSScanner* theScanner = [NSScanner scannerWithString:derHexString];
	
	if ([theScanner scanHexInt:&returnInt])
	{
		//NSLog(@"HexStringZuInt string: %@ int: %d	",derHexString,returnInt);
		return returnInt;
	}
	
	return returnInt;
}

- (NSDateComponents*) heute
{
   NSDate *now = [[NSDate alloc] init];
   NSCalendar *kalender = [NSCalendar currentCalendar];
   [kalender setFirstWeekday:2];
   NSDateComponents *components = [kalender components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:now];
   components.weekday = components.weekday-1;
   return components;
   
}

- (NSDate*)DatumvonJahr:(int)jahr Monat:(int)monat Tag:(int)tag
{
   // http://stackoverflow.com/questions/7664786/generate-nsdate-from-day-month-and-year
   NSCalendar *tagcalendar = [NSCalendar currentCalendar];
   [tagcalendar setTimeZone:[NSTimeZone localTimeZone]];
   [tagcalendar setLocale:[NSLocale currentLocale]];
   
   NSDateComponents *components = [[NSDateComponents alloc] init];
   [components setDay:tag];
   [components setMonth:monat];
   [components setYear:jahr];
   NSDate *tagdatum = [tagcalendar dateFromComponents:components];
   //NSLog(@"tagdatum: %@",[tagdatum description]);
   //  NSCalendar *gregorian =[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   // int dayOfYear =(int)[gregorian ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:tagdatum];
   return tagdatum;
}

- (NSDate*)DateVonString:(NSString*)datumstring
{
   NSMutableArray* datumstringarray= (NSMutableArray*)[datumstring componentsSeparatedByString:@" "];
   if ([[datumstringarray objectAtIndex:0]length] ==0)
   {
      NSLog(@"erstes Element 0");
      [datumstringarray removeObjectAtIndex:0];
   }
   NSArray* datumarray=[[datumstringarray objectAtIndex:0] componentsSeparatedByString:@"-"];
   // Datum
   int jahr = [[datumarray objectAtIndex:0]intValue];
   int monat = [[datumarray objectAtIndex:1]intValue];
   int tag = [[datumarray objectAtIndex:2]intValue];
   
   // Zeit
   NSArray* zeitarray = [[datumstringarray objectAtIndex:1] componentsSeparatedByString:@":"];
   int stunde = [[zeitarray objectAtIndex:0]intValue];
   int minute = [[zeitarray objectAtIndex:1]intValue];
   int sekunde = [[zeitarray objectAtIndex:2]intValue];
   
   
   
   // http://stackoverflow.com/questions/7664786/generate-nsdate-from-day-month-and-year
   NSCalendar *tagcalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
   [tagcalendar setTimeZone:[NSTimeZone localTimeZone]];
   [tagcalendar setLocale:[NSLocale currentLocale]];
   
   NSDateComponents *components = [[NSDateComponents alloc] init];
   [components setDay:tag];
   [components setMonth:monat];
   [components setYear:jahr];
   
   [components setHour:stunde];
   [components setMinute:minute];
   [components setSecond:sekunde];
   
   NSDate *tagdatum = [tagcalendar dateFromComponents:components];
   //NSLog(@"tagdatum: %@",[tagdatum description]);
   //  NSCalendar *gregorian =[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   // int dayOfYear =(int)[gregorian ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:tagdatum];
   return tagdatum;
    
}




- (int)tagdesjahresvonJahr:(int)jahr Monat:(int)monat Tag: (int)tagdesmonats
{
   // http://stackoverflow.com/questions/7664786/generate-nsdate-from-day-month-and-year
   NSCalendar *tagcalendar = [NSCalendar currentCalendar];
   NSDateComponents *components = [[NSDateComponents alloc] init];
   [components setDay:tagdesmonats];
   [components setMonth:monat];
   [components setMonth:jahr];
   NSDate *tagdatum = [tagcalendar dateFromComponents:components];
   
   NSCalendar *gregorian =[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   
   
   int dayOfYear =[gregorian ordinalityOfUnit:NSCalendarUnitDay
                        inUnit:NSCalendarUnitYear forDate:tagdatum];
      return dayOfYear;
}


- (NSDate*)Datumvonheute
{
   // http://stackoverflow.com/questions/7664786/generate-nsdate-from-day-month-and-year
   NSDate *now = [[NSDate alloc] init];
   NSCalendar *tagcalendar = [NSCalendar currentCalendar];
    [tagcalendar setFirstWeekday:2];
   NSDateComponents *components = [tagcalendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:now];
   NSDate *tagdatum = [tagcalendar dateFromComponents:components];
   //NSLog(@"tagdatum: %@",[tagdatum description]);
   return tagdatum;
}

- (id) init
{
    //if ((self = [super init]))
	//[self Alert:@"Data init vor super"];
	
	self = [super initWithWindowNibName:@"Data"];
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
		   selector:@selector(ReadAktion:)
			   name:@"read"
			 object:nil];
	
	
	[nc addObserver:self
		   selector:@selector(IOWAktion:)
			   name:@"iow"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(BrenndauerAktion:)
			   name:@"Brenndauer"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(ReadStartAktion:)
			   name:@"ReadStart"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(ExterneDatenAktion:)
			   name:@"externedaten"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(LastDatenAktion:)
			   name:@"lasthomedata"
			 object:nil];
	
	[nc addObserver:self
		   selector:@selector(ErrStringAktion:)
			   name:@"errstring"
			 object:nil];
	
	[nc addObserver:self
			 selector:@selector(HomeDataDownloadAktion:) // Loadmark aktivieren
				  name:@"HomeDataDownload"
				object:nil];

	[nc addObserver:self
		   selector:@selector(LastSolarDatenAktion:)
			   name:@"lastsolardata"
			 object:nil];


	[nc addObserver:self
			 selector:@selector(SolarDataDownloadAktion:) // Loadmark aktivieren
				  name:@"SolarDataDownload"
				object:nil];

	[nc addObserver:self
		   selector:@selector(ExterneSolarDatenAktion:)
			   name:@"externesolardaten"
			 object:nil];
	
	
   

	
	Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt",@"WoZi",@"Buero",@"Labor",@"OG 1",@"OG 2",@"Estrich",NULL];
	Eingangsdaten=[[NSMutableArray alloc]initWithCapacity:0];
	TemperaturDaten=[[NSMutableDictionary alloc]initWithCapacity:0];
	TemperaturZeilenString=[[NSMutableString alloc]init];
	DumpArray=[[NSMutableArray alloc]initWithCapacity:0];

	HeizungKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[HeizungKanalArray setArray:[NSArray arrayWithObjects:@"1",@"1",@"1",@"0" ,@"0",@"0",@"0",@"1",@"1",@"1",@"0",@"0",nil]];


	BrennerKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[BrennerKanalArray setArray:[NSArray arrayWithObjects:@"1",@"1",@"0",@"1" ,@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil]];

	BrennerStatistikKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[BrennerStatistikKanalArray setArray:[NSArray arrayWithObjects:@"1",@"0",@"0",@"0" ,@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil]];

	BrennerStatistikTemperaturKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[BrennerStatistikTemperaturKanalArray setArray:[NSArray arrayWithObjects:@"1",@"0",@"0",@"0" ,@"0",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil]];
	

	SolarTemperaturKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[SolarTemperaturKanalArray setArray:[NSArray arrayWithObjects:@"0",@"1",@"1",@"1" ,@"0",@"0",@"0",@"0",nil]];

   SolarStatistikTemperaturKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[SolarStatistikTemperaturKanalArray setArray:[NSArray arrayWithObjects:@"0",@"1",@"1",@"1" ,@"0",@"0",@"0",@"0",nil]];


	SolarStatistikElektroKanalArray=[[NSMutableArray alloc]initWithCapacity:0];
	[SolarStatistikElektroKanalArray setArray:[NSArray arrayWithObjects:@"0",@"1",@"1",@"1" ,@"0",@"0",@"0",@"0",nil]];
	
	
	n=0;
	aktuellerTag=0;
	IOW_busy=0;
	AnzReports=0;
	ReportErrIndex=-1;
	ErrZuLang=0;
	ErrZuKurz=0;
	TemperaturNullpunkt=0;
	SimRun=0;
	simDaySaved=0;
	SerieSize=8;
	par=0; // Paritaet
	Quelle=0; // Herkunft der Daten. 0: IOW		1: Datei
	//if (self)
	//NSLog(@"Data OK");
	NSRect DruckViewRect=NSMakeRect(0,0,200,800);
	DruckDatenView=[[NSTextView alloc]initWithFrame:DruckViewRect];
	Scrollermass=15;
	Kalenderblocker=0;
	SolarKalenderblocker=0;
	Heuteblocker=0;
	SolarHeuteblocker=0;
	return self;
}	//init

- (void)awakeFromNib
{
   int currentDay;
   NSDateFormatter*dateFormatter = [[NSDateFormatter alloc] init];
   [dateFormatter setDateFormat:@"D"];
   NSDate* date = [NSDate date];
   currentDay = [[dateFormatter stringFromDate:date] intValue];

	[SolaranlageBild setImage: [NSImage imageNamed: @"Solar.jpg"]];
	//oldHour=[[NSCalendarDate date]hourOfDay];
	Data_DS=[[rData_DS alloc]init];
	[DatenplanTable setDelegate:Data_DS];
	[DatenplanTable setDataSource:Data_DS];
	//	[[[self window]contentView] addSubview:DatenplanTable];
	//NSSegmentedCell* StdCell=[[NSSegmentedCell alloc]init];
	
	[DatenplanTab setDelegate:self];
	int anzTabs=[DatenplanTab numberOfTabViewItems];
	int tabindex=0;
	for (tabindex=0;tabindex<anzTabs;tabindex++)
	{
		[[DatenplanTab tabViewItemAtIndex:tabindex]setIdentifier:[NSNumber numberWithInt:tabindex]];
	}
	
	NSRect scRect=NSMakeRect(0,0,10,10);
	NSSegmentedControl* SC=[[NSSegmentedControl alloc]initWithFrame:scRect];
	[[SC cell]setSegmentCount:2];
	
	//[StdCell selectSegmentWithTag:1];
	//NSRect r=[[StdCell contentView] frame];
   NSDate* heute = [NSDate date];
	DatenserieStartZeit=[NSDate date];
   //[NSCalendarDate date] > [NSCalendar currentCalendar]
	SimDatenserieStartZeit=[NSDate date];
	
	[Kalender setCalendar:[NSCalendar currentCalendar]];
	[Kalender setDateValue: [NSDate date]];

	[SolarKalender setCalendar:[NSCalendar currentCalendar]];
	[SolarKalender setDateValue: [NSDate date]];
	
   [SolarStatistikJahrPop removeAllItems];
    NSArray *itemarray = [[NSArray alloc]initWithObjects:@"2010",@"2011",@"2012",@"2013",@"2014",@"2015",@"2016", @"2017", @"2018", @"2019", @"2020", @"2021", @"2022", nil];
    [SolarStatistikJahrPop addItemsWithTitles:itemarray];
   for (int i=0;i<itemarray.count;i++)
   {
      int itemtag = [[itemarray objectAtIndex:i]intValue];
      [[SolarStatistikJahrPop itemAtIndex:i]setTag:itemtag];
   }
   
   
   NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
   
   [SolarStatistikJahrPop selectItemWithTag:[components year]];
   
   
   [StatistikJahrPop selectItemWithTag:[components year]];
   

	
	//NSString* PickDate=[[Kalender dateValue]description];
	//NSLog(@"PickDate: %@",PickDate);
	//NSDate* KalenderDatum=[Kalender dateValue];
	//NSLog(@"Kalenderdatum: %@",KalenderDatum);
	//NSArray* DatumStringArray=[PickDate componentsSeparatedByString:@" "];
	//NSLog(@"DatumStringArray: %@",[DatumStringArray description]);
	
	//NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
	//NSString* SuffixString=[NSString stringWithFormat:@"/HomeDaten/HomeDaten%@%@%@",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
	//NSLog(@"DatumArray: %@",[DatumArray description]);
	//NSLog(@"SuffixString: %@",SuffixString);
	//NSLog(@"tag: %d jahr: %d",tag,jahr);
	
	
	[TemperaturDaten setObject:[NSDate date] forKey:@"datenseriestartzeit"];
	
	NSMutableArray* tempStartWerteArray=[[NSMutableArray alloc]initWithCapacity:8];
	int i;
	for (i=0;i<8;i++)
	{
		//float y=(float)random() / RAND_MAX * (255);
		float starty=127.0;
		[tempStartWerteArray addObject:[NSNumber numberWithInt:(int)starty]];
	}
	//		[TemperaturMKDiagramm setStartWerteArray:tempStartWerteArray];
	
	
	
	GesamtDatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	Datenplan=[[NSMutableArray alloc]initWithCapacity:0];
   [DatenplanTab setDelegate:self];
	
	//	NSRect DatenplanTabRect=[DatenplanTab bounds];
	//NSLog(@"Data awake: x: %2.2f y: %2.2f",[DatenplanTab bounds].size.height,[DatenplanTab bounds].size.width);
	ZeitKompression=[[ZeitKompressionTaste titleOfSelectedItem]floatValue];
	
	//int k;
	//for (k=0;k<25; k++)
	//{
		//NSLog(@"Zahl: %d BinString: %@",k, [self IntToBin:k]); 
	//}
	
#pragma mark awake TemperaturDiagrammScroller
	[TemperaturDiagrammScroller setHasHorizontalScroller:YES];
	[TemperaturDiagrammScroller setDrawsBackground:YES];
	TemperaturDiagrammScroller.autoresizingMask=NSViewWidthSizable;
	//[TemperaturDiagrammScroller setBackgroundColor:[NSColor blueColor]];
	[TemperaturDiagrammScroller setHorizontalLineScroll:1.0];
	//[TemperaturDiagrammScroller setAutohidesScrollers:NO];
	//[TemperaturDiagrammScroller setBorderType:NSLineBorder];
	//[[TemperaturDiagrammScroller horizontalScroller]setFloatValue:1.0];
	//[[TemperaturDiagrammScroller documentView] setFlipped:YES];
	
	NSRect TemperaturScrollerRect=[[TemperaturDiagrammScroller contentView]frame];
	
	NSView* ScrollerView=[[NSView alloc]initWithFrame:TemperaturScrollerRect];
	
	[ScrollerView setAutoresizesSubviews:YES];
	[TemperaturDiagrammScroller setDocumentView:ScrollerView];
	[TemperaturDiagrammScroller setAutoresizesSubviews:YES];
	//NSRect TestRect=[[TemperaturDiagrammScroller documentView]frame];
	//[self logRect:TestRect];
	
	float Brennerlage=236; // Abstand des Brennerdiagramms mit den Einschaltbalken von unteren Rand des Temperaturdiagrammes
	
	NSRect MKDiagrammFeld=TemperaturScrollerRect;
	MKDiagrammFeld.origin.x += 0.1;
	MKDiagrammFeld.size.width -= 2;
	
	//MKDiagrammFeld.origin.y +=16;
	MKDiagrammFeld.size.height=220;
   
	TemperaturMKDiagramm= [[rTemperaturMKDiagramm alloc]initWithFrame:MKDiagrammFeld];
	[TemperaturMKDiagramm  setPostsFrameChangedNotifications:YES];
	[TemperaturMKDiagramm setTag:100];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor greenColor] forKanal:2];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
   [TemperaturMKDiagramm setGraphFarbe:[NSColor orangeColor] forKanal:7];
	[[TemperaturDiagrammScroller documentView]addSubview:TemperaturMKDiagramm];
	[TemperaturDiagrammScroller  setPostsFrameChangedNotifications:YES];
/*
	NSRect EKDiagrammFeld=MKDiagrammFeld;
	EKDiagrammFeld.origin.y+=220;
	EKDiagrammFeld.size.height=20;
	NSTextView* EKDiagrammView =[[NSTextView alloc] initWithFrame: EKDiagrammFeld];
	[EKDiagrammView setDrawsBackground:YES];
	[EKDiagrammView setBackgroundColor:[NSColor redColor]];
	//	[[TemperaturDiagrammScroller documentView]addSubview:EKDiagrammView];
*/	
	
	NSRect BrennerDiagrammFeld=MKDiagrammFeld;
	BrennerDiagrammFeld.origin.y+=Brennerlage;
	BrennerDiagrammFeld.size.height=50;
	BrennerDiagramm =[[rEinschaltDiagramm alloc] initWithFrame: BrennerDiagrammFeld];
	[BrennerDiagramm setAnzahlBalken:5];
	[[TemperaturDiagrammScroller documentView]addSubview:BrennerDiagramm];
	
	
	NSRect GitterlinienFeld=TemperaturScrollerRect;
	GitterlinienFeld.origin.x += 0.1;
	
	
	Gitterlinien =[[rDiagrammGitterlinien alloc] initWithFrame: GitterlinienFeld];
	[[TemperaturDiagrammScroller documentView]addSubview:Gitterlinien positioned:NSWindowBelow relativeTo:BrennerDiagramm];
	
	
	// History
	/*
	[HistoryScroller setHasHorizontalScroller:YES];
	[HistoryScroller setDrawsBackground:YES];
	[HistoryScroller setAutoresizingMask:NSViewWidthSizable];
	//[HistoryScroller setBackgroundColor:[NSColor blueColor]];
	[HistoryScroller setHorizontalLineScroll:1.0];
	//[HistoryScroller setAutohidesScrollers:NO];
	//[HistoryScroller setBorderType:NSLineBorder];
	//[[HistoryScroller horizontalScroller]setFloatValue:1.0];
	//[[HistoryScroller documentView] setFlipped:YES];
	
	NSRect HistoryScrollerRect=[[HistoryScroller contentView]frame];
	
	NSView* HistoryScrollerView=[[NSView alloc]initWithFrame:HistoryScrollerRect];
	
	[HistoryScroller setAutoresizesSubviews:YES];
	[HistoryScroller setDocumentView:ScrollerView];
	[HistoryScroller setAutoresizesSubviews:YES];
	//NSRect TestRect=[[TemperaturDiagrammScroller documentView]frame];
	//[self logRect:TestRect];
	
	float HistoryBrennerlage=220;
	
	NSRect HistoryDiagrammFeld=HistoryScrollerRect;
	HistoryDiagrammFeld.origin.x += 0.1;
	HistoryDiagrammFeld.size.width -= 2;
	
	//MKDiagrammFeld.origin.y +=16;
	HistoryDiagrammFeld.size.height=220;
	HistoryTemperaturMKDiagramm= [[rTemperaturMKDiagramm alloc]initWithFrame:HistoryDiagrammFeld];
	[HistoryTemperaturMKDiagramm  setPostsFrameChangedNotifications:YES];
	[HistoryTemperaturMKDiagramm setTag:100];
	[HistoryTemperaturMKDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[HistoryTemperaturMKDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[HistoryTemperaturMKDiagramm setGraphFarbe:[NSColor blackColor] forKanal:2];
	[HistoryTemperaturMKDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
	[[HistoryScroller documentView]addSubview:HistoryTemperaturMKDiagramm];
	[HistoryScroller  setPostsFrameChangedNotifications:YES];
	NSRect EKHistoryDiagrammFeld=HistoryDiagrammFeld;
	EKHistoryDiagrammFeld.origin.y+=220;
	EKHistoryDiagrammFeld.size.height=20;
	NSTextView* EKHistoryDiagrammView =[[NSTextView alloc] initWithFrame: EKHistoryDiagrammFeld];
	[EKHistoryDiagrammView setDrawsBackground:YES];
	[EKHistoryDiagrammView setBackgroundColor:[NSColor redColor]];
	//	[[TemperaturDiagrammScroller documentView]addSubview:EKDiagrammView];
	
	
	NSRect BrennerHistoryDiagrammFeld=HistoryDiagrammFeld;
	BrennerHistoryDiagrammFeld.origin.y+=HistoryBrennerlage;
	BrennerHistoryDiagrammFeld.size.height=50;
	HistoryBrennerDiagramm =[[rEinschaltDiagramm alloc] initWithFrame: BrennerHistoryDiagrammFeld];
	[HistoryBrennerDiagramm setAnzahlBalken:4];
	[[HistoryScroller documentView]addSubview:HistoryBrennerDiagramm];
	
	
	NSRect HistoryGitterlinienFeld=HistoryScrollerRect;
	HistoryGitterlinienFeld.origin.x += 0.1;
	
	
	HistoryGitterlinien =[[rDiagrammGitterlinien alloc] initWithFrame: HistoryGitterlinienFeld];
	[[HistoryScroller documentView]addSubview:HistoryGitterlinien positioned:NSWindowBelow relativeTo:HistoryBrennerDiagramm];
	
	
	
	
	// end History
	*/
	
	
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
			 selector:@selector(FrameDidChangeAktion:)
				  name:@"NSWindowDidResizeNotification"
				object:nil];
	
		
	//[TemperaturDiagrammScroller addSubview:ScrollerView];
	//NSLog(@"Data awake GesamtDatenArray: %@",[GesamtDatenArray description]);
	NSPoint DiagrammEcke=[TemperaturMKDiagramm frame].origin;
	
	//DiagrammEcke.x+=100;
	[TemperaturMKDiagramm setFrameOrigin:DiagrammEcke];
	
	float wert1tab=60;
	float wert2tab=100;
	int Textschnitt=12;
	
	NSFont* TextFont;
	TextFont=[NSFont fontWithName:@"Helvetica" size: Textschnitt];
	
	NSMutableParagraphStyle* TabellenKopfStil=[[NSMutableParagraphStyle alloc]init];
	[TabellenKopfStil setTabStops:[NSArray array]];
	NSTextTab* TabellenkopfWert1Tab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:wert1tab];
	[TabellenKopfStil addTabStop:TabellenkopfWert1Tab];
	NSTextTab* TabellenkopfWert2Tab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:wert2tab];
	[TabellenKopfStil addTabStop:TabellenkopfWert2Tab];
	NSMutableParagraphStyle* TabelleStil=[[NSMutableParagraphStyle alloc]init];
	[TabelleStil setTabStops:[NSArray array]];
	//	[self Alert:@"ADWandler awake: nach TabelleStil setTabStops"];
	NSMutableString* TabellenkopfString=[NSMutableString stringWithCapacity:0];
	NSArray* TabellenkopfArray=[NSArray arrayWithObjects:@"Zeit",@"Wert",nil];
	int index;
	for (index=0;index<[TabellenkopfArray count];index++)
	{
		NSString* tempKopfString=[TabellenkopfArray objectAtIndex:index];
		//NSLog(@"tempKopfString: %@",tempKopfString);
		//Kommentar als Array von Zeilen
		[TabellenkopfString appendFormat:@"\t%@",tempKopfString];
		//NSLog(@"KommentarString: %@  index:%d",KommentarString,index);
		
	}
	//	[self Alert:@"ADWandler awake: vor TabellenkopfString appendStrin"];
	//[TabellenkopfString appendString:@"\n"];
	
	NSMutableAttributedString* attrKopfString=[[NSMutableAttributedString alloc] initWithString:TabellenkopfString];
	[attrKopfString addAttribute:NSParagraphStyleAttributeName value:TabellenKopfStil range:NSMakeRange(0,[TabellenkopfString length])];
	[attrKopfString addAttribute:NSFontAttributeName value:TextFont range:NSMakeRange(0,[TabellenkopfString length])];
	//[[TemperaturDatenFeld textStorage]appendAttributedString:attrKopfString];
	//[TemperaturDatenFeld setString:TabellenkopfString];
	
	float zeittab=50;
	float werttab=25;
	
	int MKTextschnitt=11;
	NSFont* MKTextFont;
	MKTextFont=[NSFont fontWithName:@"Helvetica" size: MKTextschnitt];
	NSMutableString* MKTabellenkopfString=[NSMutableString stringWithCapacity:0];
	NSMutableParagraphStyle* MKTabellenKopfStil=[[NSMutableParagraphStyle alloc]init];
	[MKTabellenKopfStil setTabStops:[NSArray array]];
	NSTextTab* TabellenkopfZeitTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab];
	[MKTabellenKopfStil addTabStop:TabellenkopfZeitTab];
	
	[MKTabellenkopfString appendFormat:@"\t%@",@"Zeit"];// Zusätzlicher Tab fuer erste Zahl
	
   /*
   for (i=0;i<8;i++)
	{
		NSTextTab* TabellenkopfWertTab=[[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(i+1)*werttab]autorelease];
		[MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
		[MKTabellenkopfString appendFormat:@"\t%@",[[NSNumber numberWithInt:i]stringValue]];
	}
    */
   NSTextTab* TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(1)*werttab];
   //[TabellenkopfWertTab addToolTip:@"Temperatur*2"];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tVL"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(2)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tRL"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(3)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tA"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(4)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tCd"];

   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(5)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tstd"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(6)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tmin"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(7)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\t"]; // Abstand
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(8)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\tI"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(9)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\ts0"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(10)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\ts1"];
   TabellenkopfWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(11)*werttab];
   [MKTabellenKopfStil addTabStop:TabellenkopfWertTab];
   [MKTabellenkopfString appendFormat:@"\ts2"];

  
   
   
	NSMutableParagraphStyle* MKTabelleStil=[[NSMutableParagraphStyle alloc]init];
	[MKTabelleStil setTabStops:[NSArray array]];
	
	[MKTabellenkopfString appendString:@"\n"];
	NSMutableAttributedString* MKTabellenKopfString=[[NSMutableAttributedString alloc] initWithString:MKTabellenkopfString];
	
	[MKTabellenKopfString addAttribute:NSParagraphStyleAttributeName value:MKTabellenKopfStil range:NSMakeRange(0,[MKTabellenkopfString length])];
	[MKTabellenKopfString addAttribute:NSFontAttributeName value:MKTextFont range:NSMakeRange(0,[MKTabellenkopfString length])];
	
	[[TemperaturWertFeld textStorage]appendAttributedString:MKTabellenKopfString];
	
	
	//
	NSMutableString* MKTabellenString=[NSMutableString stringWithCapacity:0];
	NSMutableParagraphStyle* MKTabellenStil=[[NSMutableParagraphStyle alloc]init];
	[MKTabellenStil setTabStops:[NSArray array]];
	//NSTextTab* TabellenZeitTab=[[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab]autorelease];
	[MKTabellenStil addTabStop:TabellenkopfZeitTab];
	
	[MKTabellenString appendFormat:@"\t"];// Zusätzlicher Tab fuer erste Zahl
	for (i=0;i<12;i++) 
	{
		NSTextTab* TabellenWertTab=[[NSTextTab alloc]initWithType:NSRightTabStopType location:zeittab+(i+1)*werttab];
		[MKTabellenStil addTabStop:TabellenWertTab];
		[MKTabellenString appendFormat:@"\t"];
	}
	[MKTabelleStil setTabStops:[NSArray array]];
	
	//[MKTabellenString appendString:@"\n"];
	NSMutableAttributedString* MKattrString=[[NSMutableAttributedString alloc] initWithString:MKTabellenString];
	
	[MKattrString addAttribute:NSParagraphStyleAttributeName value:MKTabellenStil range:NSMakeRange(0,[MKTabellenString length])];
	[MKattrString addAttribute:NSFontAttributeName value:MKTextFont range:NSMakeRange(0,[MKTabellenString length])];

	[[TemperaturDatenFeld textStorage]appendAttributedString:MKattrString];
	//	[TemperaturDatenFeld setString:MKTabellenkopfString];
	//	[TemperaturWertFeld setString:MKTabellenkopfString];
	
	NSRect TemperaturOrdinatenFeld=[TemperaturDiagrammScroller frame];
	TemperaturOrdinatenFeld.size.width=30;
	TemperaturOrdinatenFeld.size.height=[TemperaturMKDiagramm frame].size.height;
	
	TemperaturOrdinatenFeld.origin.x-=30;
	TemperaturOrdinatenFeld.origin.y+=Scrollermass+1;
	TemperaturOrdinate=[[rOrdinate alloc]initWithFrame:TemperaturOrdinatenFeld];
	[TemperaturOrdinate setTag:101];
	[TemperaturOrdinate setGrundlinienOffset:4.1];
	//int MehrkanalTabIndex=[DatenplanTab indexOfTabViewItemWithIdentifier:@"mehrkanal"];
	//	NSLog(@"MehrkanalTabIndex: %d",MehrkanalTabIndex);
	[[[DatenplanTab tabViewItemAtIndex:0]view]addSubview:TemperaturOrdinate];
	[TemperaturMKDiagramm setOrdinate:TemperaturOrdinate];
	
	NSRect BrennerLegendeFeld=[TemperaturDiagrammScroller frame];
	BrennerLegendeFeld.size.width=60;
	BrennerLegendeFeld.size.height=[BrennerDiagramm frame].size.height;
	BrennerLegendeFeld.origin.x-=60;
	BrennerLegendeFeld.origin.y+=Brennerlage;
	BrennerLegendeFeld.origin.y+=Scrollermass;
	//[self logRect:BrennerLegendeFeld];
	
	BrennerLegende=[[rLegende alloc]initWithFrame:BrennerLegendeFeld];
	[[[DatenplanTab tabViewItemAtIndex:0]view]addSubview:BrennerLegende];
	[BrennerLegende setAnzahlBalken:5];
	NSArray* BrennerInhaltArray=[NSArray arrayWithObjects:@"Brenner",@"Uhr",@"Stufe", @"Rinne", @"",nil];
	[BrennerLegende setInhaltArray:BrennerInhaltArray];
	[BrennerDiagramm setLegende:BrennerLegende];
	
	
	NSMutableDictionary* TemperaturEinheitenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[TemperaturEinheitenDic setObject:[NSNumber numberWithInt:2]forKey:@"minorteile"];
	[TemperaturEinheitenDic setObject:[NSNumber numberWithInt:7]forKey:@"majorteile"];
	[TemperaturEinheitenDic setObject:[NSNumber numberWithInt:10]forKey:@"nullpunkt"];
	[TemperaturEinheitenDic setObject:[NSNumber numberWithInt:60]forKey:@"maxy"];
	[TemperaturEinheitenDic setObject:[NSNumber numberWithInt:-10]forKey:@"miny"];
	[TemperaturEinheitenDic setObject:[NSNumber numberWithFloat:[[ZeitKompressionTaste titleOfSelectedItem]floatValue]]forKey:@"zeitkompression"];
	[TemperaturEinheitenDic setObject:@" C"forKey:@"einheit"];
	
	[TemperaturMKDiagramm setEinheitenDicY: TemperaturEinheitenDic];
	[BrennerDiagramm setEinheitenDicY: TemperaturEinheitenDic];
	[Gitterlinien setEinheitenDicY: TemperaturEinheitenDic];
	[self setZeitKompression];
	
	
	errString= [NSString string];
	errPfad= [NSString string];
   
   /*
    NSTimeZone *cetTimeZone = [NSTimeZone timeZoneWithName:@"CET"];
    
    NSCalendar *startcalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    startcalendar.firstWeekday = 2;
    [startcalendar setTimeZone:cetTimeZone];
    NSDateComponents *components = [startcalendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:DatenserieStartZeit];

    
    */
    NSTimeZone *cetTimeZone = [NSTimeZone timeZoneWithName:@"CET"];
   NSCalendar *awakecalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   awakecalendar.firstWeekday = 2;
   [awakecalendar setTimeZone:cetTimeZone];


   //NSDateComponents *heutecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
   NSDateComponents *heutecomponents = [awakecalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];  
   
   NSInteger tagdesmonats = [heutecomponents day];
   NSInteger monat = [heutecomponents month];
   NSInteger jahr = [heutecomponents year];
    NSInteger stunde = [heutecomponents hour];
    NSInteger minute = [heutecomponents minute];
   NSInteger sekunde = [heutecomponents second];
   jahr-=2000;
   NSString* StartZeit = [NSString stringWithFormat:@"%02ld.%02ld.%02ld",(long)tagdesmonats,(long)monat,(long)jahr];

   
   NSString* StartZeitFull = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld:%02ld",(long)tagdesmonats,(long)monat,(long)jahr,(long)stunde,(long)minute,(long)sekunde];

   NSLog(@"awake StartZeit: %@ StartZeitFull: %@",StartZeit, StartZeitFull);
   
   
//	NSCalendarDate* StartZeit=[NSCalendarDate calendarDate];
//	[StartZeit setCalendarFormat:@"%d.%m.%y %H:%M"];
	
   //NSLog(@"awake StartZeit A: %@",StartZeit);
   // Pfad fuer Logfile einrichten
	BOOL FileOK=NO;
	BOOL istOrdner;
	NSFileManager *Filemanager = [NSFileManager defaultManager];
	NSString* TempDatenPfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@",@"/Documents",@"/HomeData"];
	FileOK= ([Filemanager fileExistsAtPath:TempDatenPfad isDirectory:&istOrdner]&&istOrdner);
	if (FileOK)
	{
		errPfad=[TempDatenPfad stringByAppendingPathComponent:@"Logs"]; // Ordner fuer LogFiles
		if (![Filemanager fileExistsAtPath:[TempDatenPfad stringByAppendingPathComponent:@"Logs"] isDirectory:&istOrdner]&&istOrdner)
		{
         FileOK=[Filemanager createDirectoryAtPath:[TempDatenPfad stringByAppendingPathComponent:@"Logs"] withIntermediateDirectories:NO attributes:NULL error:NULL];

			//FileOK=[Filemanager createDirectoryAtPath:[TempDatenPfad stringByAppendingPathComponent:@"Logs"] attributes:NULL];
			
		}
		
	}
	if (FileOK)
	{
		//[StartZeit setCalendarFormat:@"%d.%m.%y"];
		//NSLog(@"awake StartZeit: %@",StartZeit);
      
		errPfad=[NSString stringWithFormat:@"%@/errString %@.txt",[TempDatenPfad stringByAppendingPathComponent:@"Logs"],StartZeit];
		
		//NSLog(@"reportStart errPfad: %@",errPfad);
		if ([Filemanager fileExistsAtPath:errPfad])
		{
			errString = [NSString stringWithContentsOfFile:errPfad encoding:NSMacOSRomanStringEncoding error:NULL];
			//NSLog(@"reportStart errString da: %@",errString);
		}
		else
		{
			errString=[NSString stringWithFormat:@"Logfile vom: %@\r",[StartZeit description]];
			//NSLog(@"reportStart neurer errString: %@",errString);
		}
		
	}
	//	[[LoadMark cell] setControlSize:NSMiniControlSize];
	[LoadMark setEnabled:YES];
	
	
	// BrennerTab einrichten
	int BrennerTabIndex=1;
	[[DatenplanTab tabViewItemAtIndex:BrennerTabIndex] setLabel:@"Brenner"];
		
	float StatistikDiagrammLage=20.0;
#pragma mark awake StatistikDiagrammScroller

	[StatistikDiagrammScroller setHasHorizontalScroller:YES];
	[StatistikDiagrammScroller setHasVerticalScroller:NO];
	[StatistikDiagrammScroller setDrawsBackground:YES];
	StatistikDiagrammScroller.autoresizingMask=NSViewWidthSizable;
	//[StatistikDiagrammScroller setBackgroundColor:[NSColor blueColor]];
	[StatistikDiagrammScroller setHorizontalLineScroll:1.0];
	//[StatistikDiagrammScroller setAutohidesScrollers:NO];
	//[StatistikDiagrammScroller setBorderType:NSLineBorder];
	[[StatistikDiagrammScroller horizontalScroller]setFloatValue:1.0];
	//[[StatistikDiagrammScroller documentView] setFlipped:YES];
	
	NSRect StatistikScrollerRect=[[StatistikDiagrammScroller contentView]frame];
//	StatistikScrollerRect.size.width += 4000;
	NSView* StatistikScrollerView=[[NSView alloc]initWithFrame:StatistikScrollerRect];
	
	
	[StatistikScrollerView setAutoresizesSubviews:YES];
	[StatistikDiagrammScroller setDocumentView:StatistikScrollerView];
	[StatistikDiagrammScroller setAutoresizesSubviews:YES];
	
	
	//NSLog(@"[StatistikDiagrammScroller documentView]: w: %2.2f",[[StatistikDiagrammScroller documentView]frame].size.width);
	//NSRect BalkenRahmen=[[StatistikDiagrammScroller documentView]frame];
	//BalkenRahmen.size.width += 2000;
	//[self logRect:[StatistikDiagrammScroller frame]];
	//NSLog(@"[BalkenRahmen: w: %2.2f",BalkenRahmen.size.width);
	//[[StatistikDiagrammScroller documentView]setFrame:BalkenRahmen];
	
   // Brennertab: Temperaturdiagramm einfuegen
	NSRect StatistikFeld=StatistikScrollerRect;
	StatistikFeld.origin.x += 0.1;
	StatistikFeld.origin.y += 0.1;
	StatistikFeld.size.width -= 2;
	StatistikFeld.size.height=250;
	TemperaturStatistikDiagramm= [[rStatistikDiagramm alloc]initWithFrame:StatistikFeld];
	[TemperaturStatistikDiagramm setGrundlinienOffset:10.0];					// Abstand der
	[TemperaturStatistikDiagramm setDiagrammlageY:StatistikDiagrammLage];	// Abstand vom unteren Rand des Scrollviews
	[TemperaturStatistikDiagramm setMaxOrdinate:200];
	//[TemperaturStatistikDiagramm setMaxEingangswert:40];
	[TemperaturStatistikDiagramm  setPostsFrameChangedNotifications:YES];
	[TemperaturStatistikDiagramm setTag:200];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor greenColor] forKanal:2];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
	[[StatistikDiagrammScroller documentView]addSubview:TemperaturStatistikDiagramm];
	
	NSRect StatGitterlinienFeld=StatistikScrollerRect;
	StatGitterlinienFeld.origin.x += 0.1;
	
	rDiagrammGitterlinien* StatGitterlinien =[[rDiagrammGitterlinien alloc] initWithFrame: StatGitterlinienFeld];
	[StatGitterlinien setDiagrammlageY:StatistikDiagrammLage];
	[StatGitterlinien setGrundlinienOffset:10.0];
	
	[[StatistikDiagrammScroller documentView]addSubview:StatGitterlinien];
	
	NSRect TagGitterlinienFeld=StatistikScrollerRect;
	TagGitterlinienFeld.origin.x += 0.1;
	
	TagGitterlinien =[[rTagGitterlinien alloc] initWithFrame: TagGitterlinienFeld];
	[[StatistikDiagrammScroller documentView]addSubview:TagGitterlinien positioned:NSWindowBelow relativeTo:TemperaturStatistikDiagramm];
	
	
	NSRect TemperaturStatistikOrdinatenFeld=[StatistikDiagrammScroller frame];								// Feld des ScrollViews
	TemperaturStatistikOrdinatenFeld.size.width=40;																	// Breite setzen
	TemperaturStatistikOrdinatenFeld.size.height=[TemperaturStatistikDiagramm frame].size.height;	// Hoehe gleich wie StatisikDiagramm
	//TemperaturStatistikOrdinatenFeld.size.height=240;
	TemperaturStatistikOrdinatenFeld.origin.x-=42;																	// Verschiebung nach links
//	TemperaturStatistikOrdinatenFeld.origin.y += Scrollermass;													// Ecke um Scrollerbreite nach oben verschieben // Nicht mehr ab Xcode 7.2
	//NSLog(@"Data TemperaturStatistikOrdinatenFeld");
	//[self logRect:TemperaturStatistikOrdinatenFeld];
	TemperaturStatistikOrdinate=[[rOrdinate alloc]initWithFrame:TemperaturStatistikOrdinatenFeld];
	
	[TemperaturStatistikOrdinate setOrdinatenlageY:StatistikDiagrammLage+16];
	[TemperaturStatistikOrdinate setGrundlinienOffset:10.0];
	[TemperaturStatistikOrdinate setMaxOrdinate:200];
	[TemperaturStatistikOrdinate setTag:201];
	//int MehrkanalTabIndex=[DatenplanTab indexOfTabViewItemWithIdentifier:@"mehrkanal"];
	//	NSLog(@"MehrkanalTabIndex: %d",MehrkanalTabIndex);
	[[[DatenplanTab tabViewItemAtIndex:1]view]addSubview:TemperaturStatistikOrdinate];
	
	[TemperaturStatistikDiagramm setOrdinate:TemperaturStatistikOrdinate];
	
	
	NSMutableDictionary* TempStatistikEinheitenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[TempStatistikEinheitenDic setObject:[NSNumber numberWithInt:2]forKey:@"minorteile"];
	[TempStatistikEinheitenDic setObject:[NSNumber numberWithInt:4]forKey:@"majorteile"];
	[TempStatistikEinheitenDic setObject:[NSNumber numberWithInt:10]forKey:@"nullpunkt"];
	[TempStatistikEinheitenDic setObject:[NSNumber numberWithInt:30]forKey:@"maxy"];
	[TempStatistikEinheitenDic setObject:[NSNumber numberWithInt:-10]forKey:@"miny"];
	//[TempStatistikEinheitenDic setObject:[NSNumber numberWithFloat:[[ZeitKompressionTaste titleOfSelectedItem]floatValue]]forKey:@"zeitkompression"];
	[TempStatistikEinheitenDic setObject:@" °C"forKey:@"einheit"];
	
	[TemperaturStatistikDiagramm setEinheitenDicY: TempStatistikEinheitenDic];
	
	//	[StatGitterlinien setEinheitenDicY: StatistikEinheitenDic];
	
	
	
	float StatistikDiagrammlage=0;
	NSRect StatistikLegendeFeld=[StatistikDiagrammScroller frame];
	StatistikLegendeFeld.size.width=60;
	StatistikLegendeFeld.size.height=[TemperaturStatistikDiagramm frame].size.height;
	StatistikLegendeFeld.origin.x-=60;
	StatistikLegendeFeld.origin.y+=StatistikDiagrammlage;
	StatistikLegendeFeld.origin.y+=16;
	//[self logRect:StatistikLegendeFeld];
	
	
	//	[TemperaturStatistikDiagramm setLegende:StatistikLegende];
	
	float BrennerStatistikDiagrammlage=280;
	
	NSRect BrennerStatistikFeld=StatistikScrollerRect;
	BrennerStatistikFeld.origin.x += 0.1;
	BrennerStatistikFeld.origin.y += 0.1;
	BrennerStatistikFeld.size.width -= 2;
	BrennerStatistikFeld.size.height=140;
	BrennerStatistikDiagramm= [[rBrennerStatistikDiagramm alloc]initWithFrame:BrennerStatistikFeld];
	[BrennerStatistikDiagramm setGrundlinienOffset:5.0];					// Abstand der 
	[BrennerStatistikDiagramm setDiagrammlageY:BrennerStatistikDiagrammlage];	// Abstand vom unteren Rand des Scrollviews
	[BrennerStatistikDiagramm setMaxOrdinate:100]; // Maximale Ordinate in Pixel
	//[TemperaturStatistikDiagramm setMaxEingangswert:40];
	[BrennerStatistikDiagramm  setPostsFrameChangedNotifications:YES];
	[BrennerStatistikDiagramm setTag:300];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor lightGrayColor] forKanal:0];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor blackColor] forKanal:2];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
	[[StatistikDiagrammScroller documentView]addSubview:BrennerStatistikDiagramm];
	
	
	NSMutableDictionary* BrennerStatistikEinheitenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[BrennerStatistikEinheitenDic setObject:[NSNumber numberWithInt:2]forKey:@"minorteile"];
	[BrennerStatistikEinheitenDic setObject:[NSNumber numberWithInt:5]forKey:@"majorteile"];
	[BrennerStatistikEinheitenDic setObject:[NSNumber numberWithInt:0]forKey:@"nullpunkt"];
	[BrennerStatistikEinheitenDic setObject:[NSNumber numberWithInt:10]forKey:@"maxy"];
	[BrennerStatistikEinheitenDic setObject:[NSNumber numberWithInt:0]forKey:@"miny"];
	//[StatistikEinheitenDic setObject:[NSNumber numberWithFloat:[[ZeitKompressionTaste titleOfSelectedItem]floatValue]]forKey:@"zeitkompression"];
	[BrennerStatistikEinheitenDic setObject:@" h"forKey:@"einheit"];
	
	[BrennerStatistikDiagramm setEinheitenDicY: BrennerStatistikEinheitenDic];
	
	NSRect BrennerStatistikOrdinatenFeld=[StatistikDiagrammScroller frame];	// Feld des ScrollViews
	BrennerStatistikOrdinatenFeld.size.width=40;													// Breite setzen
	BrennerStatistikOrdinatenFeld.size.height=[BrennerStatistikDiagramm frame].size.height;	// Hoehe gleich wie StatisikDiagramm
	//BrennerStatistikOrdinatenFeld.size.height=240;
	BrennerStatistikOrdinatenFeld.origin.x-=42;													// Verschiebung nach links
//	BrennerStatistikOrdinatenFeld.origin.y += Scrollermass; // Nicht mehr ab 7.2
   
   BrennerStatistikOrdinatenFeld.origin.y += 16;
   // Ecke um Scrollerbreite nach oben verschieben
	//NSLog(@"Data TemperaturStatistikOrdinatenFeld");
	//[self logRect:TemperaturStatistikOrdinatenFeld];
	BrennerStatistikOrdinate=[[rOrdinate alloc]initWithFrame:BrennerStatistikOrdinatenFeld];
	
	[BrennerStatistikOrdinate setOrdinatenlageY:BrennerStatistikDiagrammlage];
	[BrennerStatistikOrdinate setGrundlinienOffset:5.0];
	[BrennerStatistikOrdinate setMaxOrdinate:100];
	[BrennerStatistikOrdinate setAchsenDic:BrennerStatistikEinheitenDic];
	[BrennerStatistikOrdinate setTag:201];
	//int MehrkanalTabIndex=[DatenplanTab indexOfTabViewItemWithIdentifier:@"mehrkanal"];
	//	NSLog(@"MehrkanalTabIndex: %d",MehrkanalTabIndex);
	[[[DatenplanTab tabViewItemAtIndex:1]view]addSubview:BrennerStatistikOrdinate];
	
	[BrennerStatistikDiagramm setOrdinate:BrennerStatistikOrdinate];
	
	/*
	 NSRect BrennerStatistikLegendeFeld=[StatistikDiagrammScroller frame];
	 BrennerStatistikLegendeFeld.size.width=60;
	 BrennerStatistikLegendeFeld.size.height=[TemperaturStatistikDiagramm frame].size.height;
	 BrennerStatistikLegendeFeld.origin.x-=60;
	 BrennerStatistikLegendeFeld.origin.y+=BrennerStatistikDiagrammlage;
	 BrennerStatistikLegendeFeld.origin.y+=16;
	 [self logRect:StatistikLegendeFeld];
	 BrennerStatistikLegende=[[rLegende alloc]initWithFrame:BrennerStatistikLegendeFeld];
	 
	 [[[DatenplanTab tabViewItemAtIndex:1]view]addSubview:BrennerStatistikLegende];
	 [BrennerStatistikLegende setAnzahlBalken:4];
	 
	 NSArray* BrennerStatistikInhaltArray=[NSArray arrayWithObjects:@"Mittel",@"Tag",@"Nacht", @"",nil];
	 [BrennerStatistikLegende setInhaltArray:BrennerStatistikInhaltArray];
	 */	
	
	//NSLog(@"[StatistikDiagrammScroller documentView]: w: %2.2f",[[StatistikDiagrammScroller documentView]frame].size.width);
	
	
	// Solartab einrichten
	
#pragma mark awake SolarDiagrammScroller

	int SolarTabIndex=2;
	[[DatenplanTab tabViewItemAtIndex:SolarTabIndex] setLabel:@"Solar"];
	SolarZeitKompression=[[SolarZeitKompressionTaste titleOfSelectedItem]floatValue];
	float SolarDiagrammLage=10.0;
	
	[SolarDiagrammScroller setHasHorizontalScroller:YES];
	[SolarDiagrammScroller setHasVerticalScroller:NO];
	[SolarDiagrammScroller setDrawsBackground:YES];
	SolarDiagrammScroller.autoresizingMask=NSViewWidthSizable;
	//[SolarDiagrammScroller setBackgroundColor:[NSColor blueColor]];
	[SolarDiagrammScroller setHorizontalLineScroll:1.0];
	//[SolarDiagrammScroller setAutohidesScrollers:NO];
	//[SolarDiagrammScroller setBorderType:NSLineBorder];
	[[SolarDiagrammScroller horizontalScroller]setFloatValue:1.0];
	//[[SolarDiagrammScroller documentView] setFlipped:YES];
	
	NSRect SolarScrollerRect=[[SolarDiagrammScroller contentView]frame];
//	SolarScrollerRect.size.width += 4000;
	NSView* SolarScrollerView=[[NSView alloc]initWithFrame:SolarScrollerRect];
	
	
	[SolarScrollerView setAutoresizesSubviews:YES];
	[SolarDiagrammScroller setDocumentView:SolarScrollerView];
	[SolarDiagrammScroller setAutoresizesSubviews:YES];
	
	
	//NSLog(@"[SolarDiagrammScroller documentView]: w: %2.2f",[[SolarDiagrammScroller documentView]frame].size.width);
	//NSRect SolarBalkenRahmen=[[SolarDiagrammScroller documentView]frame];
	//SolarBalkenRahmen.size.width += 2000;
	//[self logRect:[SolarDiagrammScroller frame]];
	//NSLog(@"[SolarBalkenRahmen: w: %2.2f",SolarBalkenRahmen.size.width);
	//[[SolarDiagrammScroller documentView]setFrame:SolarBalkenRahmen];
	
	NSRect SolarFeld=SolarScrollerRect;
	SolarFeld.origin.x += 0.1;
	SolarFeld.origin.y += 0.1;
	SolarFeld.size.width -= 2;
	SolarFeld.size.height=220;
	SolarDiagramm= [[rSolarDiagramm alloc]initWithFrame:SolarFeld];
	[SolarDiagramm setGrundlinienOffset:4.1];					// Abstand der 
	[SolarDiagramm setDiagrammlageY:SolarDiagrammLage];	// Abstand vom unteren Rand des Scrollviews
	[SolarDiagramm setMaxOrdinate:200];
	//[SolarDiagramm setMaxEingangswert:40];
	[SolarDiagramm  setPostsFrameChangedNotifications:YES];
	[SolarDiagramm setTag:400];
	[SolarDiagramm setGraphFarbe:[NSColor greenColor] forKanal:0]; // KV
	[SolarDiagramm setGraphFarbe:[NSColor redColor] forKanal:1]; // KR
	[SolarDiagramm setGraphFarbe:[NSColor blueColor] forKanal:2];// BU
	[SolarDiagramm setGraphFarbe:[NSColor lightGrayColor] forKanal:3];// BM
   [SolarDiagramm setGraphFarbe:[NSColor redColor] forKanal:4];// BO
   [SolarDiagramm setGraphFarbe:[NSColor orangeColor] forKanal:5];// KT
   //[SolarDiagramm setGraphFarbe:[NSColor redColor] forKanal:6];//
	[SolarDiagramm setZeitKompression:[[SolarZeitKompressionTaste titleOfSelectedItem]floatValue]];
	
	[[SolarDiagrammScroller documentView]addSubview:SolarDiagramm];


	NSMutableDictionary* SolarEinheitenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[SolarEinheitenDic setObject:[NSNumber numberWithInt:2]forKey:@"minorteile"];
	[SolarEinheitenDic setObject:[NSNumber numberWithInt:8]forKey:@"majorteile"];
	[SolarEinheitenDic setObject:[NSNumber numberWithInt:0]forKey:@"nullpunkt"];
	[SolarEinheitenDic setObject:[NSNumber numberWithInt:160]forKey:@"maxy"];
	//[SolarEinheitenDic setObject:[NSNumber numberWithInt:0]forKey:@"miny"];
	//[SolarEinheitenDic setObject:[NSNumber numberWithFloat:[[SolarZeitKompressionTaste titleOfSelectedItem]floatValue]]forKey:@"zeitkompression"];
	[SolarEinheitenDic setObject:@" C"forKey:@"einheit"];
	
	[SolarDiagramm setEinheitenDicY:SolarEinheitenDic];




	NSRect SolarGitterlinienFeld=SolarScrollerRect;
	SolarGitterlinienFeld.origin.x += 0.1;
	
	
	SolarGitterlinien =[[rDiagrammGitterlinien alloc] initWithFrame: SolarGitterlinienFeld];
	[SolarGitterlinien setZeitKompression:[[SolarZeitKompressionTaste titleOfSelectedItem]floatValue]];
	
	[SolarGitterlinien setEinheitenDicY:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:30] forKey:@"intervall"]];
	[SolarGitterlinien setNeedsDisplay:YES];

	[[SolarDiagrammScroller documentView]addSubview:SolarGitterlinien positioned:NSWindowBelow relativeTo:SolarDiagramm];
	
	// Ordinate
		
	NSRect SolarOrdinatenFeld=[SolarDiagrammScroller frame];
	SolarOrdinatenFeld.size.width=36;
	SolarOrdinatenFeld.size.height=[SolarDiagramm frame].size.height;
	
	SolarOrdinatenFeld.origin.x-=38;
	SolarOrdinatenFeld.origin.y+=Scrollermass;
	SolarOrdinate=[[rOrdinate alloc]initWithFrame:SolarOrdinatenFeld];
	[SolarOrdinate setTag:102];
	
	[SolarOrdinate setGrundlinienOffset:4.1];
	[SolarOrdinate setOrdinatenlageY:SolarDiagrammLage];
	//int MehrkanalTabIndex=[DatenplanTab indexOfTabViewItemWithIdentifier:@"mehrkanal"];
	//	NSLog(@"MehrkanalTabIndex: %d",MehrkanalTabIndex);
	
	[SolarOrdinate setAchsenDic:SolarEinheitenDic];
	[[[DatenplanTab tabViewItemAtIndex:2]view]addSubview:SolarOrdinate];
	int maxord=[SolarDiagramm MaxOrdinate];
	//NSLog(@"Solar maxord: %d",maxord);
	[SolarOrdinate setMaxOrdinate:maxord];

	int GLOffset=[SolarDiagramm GrundlinienOffset];
	//NSLog(@"Solar GLOffset: %d",GLOffset);
	[SolarOrdinate setGrundlinienOffset:GLOffset];
	
	[SolarDiagramm setOrdinate:SolarOrdinate];
	

	
	// end Ordinate
	
	// Beginn SolarEinschaltDiagramm
	float SolarEinschaltlage=SolarFeld.size.height;
	NSRect SolarEinschaltFeld=SolarFeld;
	SolarEinschaltFeld.origin.y+=SolarEinschaltlage+20;
	SolarEinschaltFeld.size.height=50;
	SolarEinschaltDiagramm =[[rSolarEinschaltDiagramm alloc] initWithFrame: SolarEinschaltFeld];
	[SolarEinschaltDiagramm setAnzahlBalken:5];
	[SolarEinschaltDiagramm setZeitKompression:[[SolarZeitKompressionTaste titleOfSelectedItem]floatValue]];
	
	[[SolarDiagrammScroller documentView]addSubview:SolarEinschaltDiagramm];

	// Beginn Einschaltlegende
	
	NSRect EinschaltLegendeFeld=[SolarDiagrammScroller frame];
	EinschaltLegendeFeld.size.width=60;
	EinschaltLegendeFeld.size.height=[BrennerDiagramm frame].size.height;
	EinschaltLegendeFeld.origin.x-=60;
	EinschaltLegendeFeld.origin.y+=SolarEinschaltlage+20;
	EinschaltLegendeFeld.origin.y+=Scrollermass;
	//[self logRect:EinschaltLegendeFeld];
	
	EinschaltLegende=[[rLegende alloc]initWithFrame:EinschaltLegendeFeld];
	[[[DatenplanTab tabViewItemAtIndex:2]view]addSubview:EinschaltLegende];
	[EinschaltLegende setAnzahlBalken:5];
	NSArray* EinschaltInhaltArray=[NSArray arrayWithObjects:@"Pumpe",@"Elektro",@"", @"", @"",nil];
	[EinschaltLegende setInhaltArray:EinschaltInhaltArray];
	[SolarEinschaltDiagramm setLegende:EinschaltLegende];
	// End Einschaltlegende

	// End Solar

#pragma mark awake Solarstatistik
	// Beginn Solarstatisktik
	[SolarStatistikDiagrammScroller setHasHorizontalScroller:YES];
	[SolarStatistikDiagrammScroller setHasVerticalScroller:NO];
	[SolarStatistikDiagrammScroller setDrawsBackground:YES];
	SolarStatistikDiagrammScroller.autoresizingMask=NSViewWidthSizable;
	//[SolarStatistikDiagrammScroller setBackgroundColor:[NSColor blueColor]];
	[SolarStatistikDiagrammScroller setHorizontalLineScroll:1.0];
	//[SolarStatistikDiagrammScroller setAutohidesScrollers:NO];
	//[SolarStatistikDiagrammScroller setBorderType:NSLineBorder];
	[[SolarStatistikDiagrammScroller horizontalScroller]setFloatValue:1.0];
	//[[SolarStatistikDiagrammScroller documentView] setFlipped:YES];
	
	NSRect SolarStatistikScrollerRect=[[SolarStatistikDiagrammScroller contentView]frame];
//	SolarStatistikScrollerRect.size.width += 4000;
	NSView* SolarStatistikScrollerView=[[NSView alloc]initWithFrame:SolarStatistikScrollerRect];
	
	[SolarStatistikDiagrammScroller setDocumentView:SolarStatistikScrollerView];
	[SolarStatistikDiagrammScroller setAutoresizesSubviews:YES];

   float SolarStatistikDiagrammhoehe = 180.0;
   
   
	NSRect SolarStatistikFeld = SolarStatistikScrollerRect;
	SolarStatistikFeld.origin.x += 0.1;
	SolarStatistikFeld.origin.y += 0.1;
	SolarStatistikFeld.size.width -= 2;
	SolarStatistikFeld.size.height=SolarStatistikDiagrammhoehe;

   // unteres Diagramm
	SolarStatistikDiagramm= [[rSolarStatistikDiagramm alloc]initWithFrame:StatistikFeld];
	[SolarStatistikDiagramm setGrundlinienOffset:10.0];					// Abstand der 
	[SolarStatistikDiagramm setDiagrammlageY:StatistikDiagrammLage];	// Abstand vom unteren Rand des Scrollviews
	[SolarStatistikDiagramm setMaxOrdinate:SolarStatistikDiagrammhoehe];
	//[TemperaturStatistikDiagramm setMaxEingangswert:40];
	[SolarStatistikDiagramm  setPostsFrameChangedNotifications:YES];
	[SolarStatistikDiagramm setTag:200];
   
	[SolarStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[SolarStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[SolarStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:2];
	[SolarStatistikDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
	[[SolarStatistikDiagrammScroller documentView]addSubview:SolarStatistikDiagramm];

	NSRect SolarStatGitterlinienFeld=SolarStatistikScrollerRect;
	SolarStatGitterlinienFeld.origin.x += 0.1;
	
	rDiagrammGitterlinien* SolarStatGitterlinien =[[rDiagrammGitterlinien alloc] initWithFrame: SolarStatGitterlinienFeld];
	[SolarStatGitterlinien setDiagrammlageY:StatistikDiagrammLage];
	[SolarStatGitterlinien setGrundlinienOffset:10.0];
	
	[[SolarStatistikDiagrammScroller documentView]addSubview:SolarStatGitterlinien];
	
	NSRect SolarTagGitterlinienFeld=SolarStatistikScrollerRect;
	SolarTagGitterlinienFeld.origin.x += 0.1;
	
	SolarTagGitterlinien =[[rTagGitterlinien alloc] initWithFrame: SolarTagGitterlinienFeld];
	[[SolarStatistikDiagrammScroller documentView]addSubview:SolarTagGitterlinien positioned:NSWindowBelow relativeTo:TemperaturStatistikDiagramm];
	
	
	NSRect SolarStatistikOrdinatenFeld=[SolarStatistikDiagrammScroller frame];								// Feld des ScrollViews
	SolarStatistikOrdinatenFeld.size.width=40;																	// Breite setzen
	SolarStatistikOrdinatenFeld.size.height=[TemperaturStatistikDiagramm frame].size.height;	// Hoehe gleich wie StatistikDiagramm
	//SolarStatistikOrdinatenFeld.size.height=240;
	SolarStatistikOrdinatenFeld.origin.x-=42;																	// Verschiebung nach links
	SolarStatistikOrdinatenFeld.origin.y += Scrollermass;													// Ecke um Scrollerbreite nach oben verschieben
	//NSLog(@"Data SolarStatistikOrdinatenFeld");
	//[self logRect:SolarStatistikOrdinatenFeld];
	SolarStatistikOrdinate=[[rOrdinate alloc]initWithFrame:SolarStatistikOrdinatenFeld];
	
	[SolarStatistikOrdinate setOrdinatenlageY:StatistikDiagrammLage];
	[SolarStatistikOrdinate setGrundlinienOffset:12.0];
	[SolarStatistikOrdinate setMaxOrdinate:SolarStatistikDiagrammhoehe];
	[SolarStatistikOrdinate setTag:201];
	//int MehrkanalTabIndex=[DatenplanTab indexOfTabViewItemWithIdentifier:@"mehrkanal"];
	//	NSLog(@"MehrkanalTabIndex: %d",MehrkanalTabIndex);
	[[[DatenplanTab tabViewItemAtIndex:3]view]addSubview:SolarStatistikOrdinate];
	
	[SolarStatistikDiagramm setOrdinate:SolarStatistikOrdinate];
	
	NSMutableDictionary* SolarStatistikEinheitenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[SolarStatistikEinheitenDic setObject:[NSNumber numberWithInt:2]forKey:@"minorteile"];
	[SolarStatistikEinheitenDic setObject:[NSNumber numberWithInt:6]forKey:@"majorteile"];
	[SolarStatistikEinheitenDic setObject:[NSNumber numberWithInt:10]forKey:@"nullpunkt"];
	[SolarStatistikEinheitenDic setObject:[NSNumber numberWithInt:100]forKey:@"maxy"];
	[SolarStatistikEinheitenDic setObject:[NSNumber numberWithInt:-20]forKey:@"miny"];
	//[SolarStatistikEinheitenDic setObject:[NSNumber numberWithFloat:[[ZeitKompressionTaste titleOfSelectedItem]floatValue]]forKey:@"zeitkompression"];
	[SolarStatistikEinheitenDic setObject:@" °C"forKey:@"einheit"];
	
	[SolarStatistikDiagramm setEinheitenDicY: SolarStatistikEinheitenDic];

   
   
// ElektrostatistikDiagramm, oberes Diagramm
   
   float ElektroStatistikDiagrammhoehe = 150;
   float ElektroStatistikDiagrammlage = 220;
   
   NSRect ElektroStatistikDiagrammFeld = SolarStatistikScrollerRect;
	ElektroStatistikDiagrammFeld.origin.x += 0.1;
	ElektroStatistikDiagrammFeld.origin.y += 0.1;
	ElektroStatistikDiagrammFeld.size.width -= 2;
	ElektroStatistikDiagrammFeld.size.height=ElektroStatistikDiagrammhoehe;
   
   //
	ElektroStatistikDiagramm= [[rElektroStatistikDiagramm alloc]initWithFrame:ElektroStatistikDiagrammFeld];
   
	[ElektroStatistikDiagramm setGrundlinienOffset:10.0];					// Abstand der
	[ElektroStatistikDiagramm setDiagrammlageY:ElektroStatistikDiagrammlage];	// Abstand vom unteren Rand des Scrollviews
	[ElektroStatistikDiagramm setMaxOrdinate:ElektroStatistikDiagrammhoehe];
	//[TemperaturStatistikDiagramm setMaxEingangswert:40];
	[ElektroStatistikDiagramm  setPostsFrameChangedNotifications:YES];
	[ElektroStatistikDiagramm setTag:210];
	[ElektroStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[ElektroStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[ElektroStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:2];
	[ElektroStatistikDiagramm setGraphFarbe:[NSColor greenColor] forKanal:3]; // Einschaltdauer ??
   
   
   
	[[SolarStatistikDiagrammScroller documentView]addSubview:ElektroStatistikDiagramm];

	// set Ordinate
   
   NSMutableDictionary* ElektroStatistikEinheitenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[ElektroStatistikEinheitenDic setObject:[NSNumber numberWithInt:2]forKey:@"minorteile"];
	[ElektroStatistikEinheitenDic setObject:[NSNumber numberWithInt:6]forKey:@"majorteile"];
	[ElektroStatistikEinheitenDic setObject:[NSNumber numberWithInt:10]forKey:@"nullpunkt"];
	[ElektroStatistikEinheitenDic setObject:[NSNumber numberWithInt:50000]forKey:@"maxy"];
	[ElektroStatistikEinheitenDic setObject:[NSNumber numberWithInt:0]forKey:@"miny"];
	//[ElektroStatistikEinheitenDic setObject:[NSNumber numberWithFloat:[[ZeitKompressionTaste titleOfSelectedItem]floatValue]]forKey:@"zeitkompression"];
	[ElektroStatistikEinheitenDic setObject:@" °C"forKey:@"einheit"];
	
	[ElektroStatistikDiagramm setEinheitenDicY: ElektroStatistikEinheitenDic];

   
   NSRect SolarstatistikTagGitterlinienFeld=SolarStatistikScrollerRect;
	SolarstatistikTagGitterlinienFeld.origin.x += 0.1;
	//NSLog(@"SolarstatistikTagGitterlinienFeld x: %.2f y: %.2f",SolarstatistikTagGitterlinienFeld.origin.x,SolarstatistikTagGitterlinienFeld.origin.y);
   //NSLog(@"SolarstatistikTagGitterlinienFeld w: %.2f h: %.2f",SolarstatistikTagGitterlinienFeld.size.width,SolarstatistikTagGitterlinienFeld.size.height);

	SolarStatistikTagGitterlinien =[[rTagGitterlinien alloc] initWithFrame: SolarstatistikTagGitterlinienFeld];
	[[SolarStatistikDiagrammScroller documentView]addSubview:SolarStatistikTagGitterlinien positioned:NSWindowBelow relativeTo:SolarStatistikDiagramm];

   
   
   [SolarStatistikKalender setDateValue: [NSDate date]];
	// end Solarstatistik
	
	// Diagrammzeichnen veranlassen
	NSMutableDictionary* BalkendatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   
	[BalkendatenDic setObject:[NSNumber numberWithInt:1]forKey:@"statistikdaten"];
	[BalkendatenDic setObject:[NSNumber numberWithInt:1]forKey:@"aktion"];
	
	//NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];

   
//**   [nc postNotificationName:@"StatistikDaten" object:NULL userInfo:BalkendatenDic];

	
	NSString* DatumString = [NSString stringWithFormat:@"RH %@",DATUM];
	[DatumFeld setStringValue:DatumString];
	NSString* VersionString = [NSString stringWithFormat:@"Version %@",VERSION];
	[VersionFeld setStringValue:VersionString];
	
   [DatenplanTab selectTabViewItemAtIndex:0];

   codeFeld.editable = NO;

}




- (void)FrameDidChangeAktion:(NSNotification*)note
{
	
	//float breite=[[note object]frame].size.width;
	//NSLog(@"Data FrameDidChangeAktion: objekt Breite: %2.2f",breite);
	
	
	return; // Rest abgeschnitten 31.7.09
	
	
	
	NSRect ScrollerRect=[TemperaturDiagrammScroller frame];
	
	float Scrollerbreite =ScrollerRect.size.width;
	
	NSRect SuperViewRect=[[BrennerDiagramm superview]frame];
	SuperViewRect.size.width=Scrollerbreite;
	[[BrennerDiagramm superview]setFrame:SuperViewRect];
	
	//[self logRect:[BrennerDiagramm frame]];
	NSRect BrennerDiagrammRect=[BrennerDiagramm frame];
	//float BrennerDiagrammBreite=BrennerDiagrammRect.size.width;
	
	
	//NSLog(@"Scrollerbreite:%2.2f  BrennerDiagrammBreite: %2.2f",Scrollerbreite,BrennerDiagrammBreite);
	BrennerDiagrammRect.size.width=Scrollerbreite;
	
	[BrennerDiagramm setFrame:BrennerDiagrammRect];
	//[self logRect:[BrennerDiagramm frame]];
	[BrennerDiagramm setNeedsDisplay:YES];
	
	NSRect TemperaturMKDiagrammRect=[TemperaturMKDiagramm frame];
	TemperaturMKDiagrammRect.size.width=Scrollerbreite;
	[TemperaturMKDiagramm setFrame:TemperaturMKDiagrammRect];
	[TemperaturMKDiagramm setNeedsDisplay:YES];
	
	NSRect GitterlinienRect=[Gitterlinien frame];
	GitterlinienRect.size.width=Scrollerbreite;
	[Gitterlinien setFrame:GitterlinienRect];
	[Gitterlinien setNeedsDisplay:YES];
	
	NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
	//NSLog(@"FrameDidChangeAktion tempOrigin: x: %2.2f y: %2.2f",tempOrigin.x, tempOrigin.y);
	NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
	//NSLog(@"FrameDidChangeAktion tempFrame width: x: %2.2f y: %2.2f",tempFrame.size.width);
	NSLog(@"FrameDidChangeAktion  tempOrigin: x: %2.2f  *   tempFrame width: %2.2f",tempOrigin.x,tempFrame.size.width);


	//[TemperaturWertFeld setNeedsDisplay:YES];

}

- (void)setcodeFeldMit:(NSString*)datastring
{
   
   
   // code aufschluesseln:
   /* In TWI_Master:
    outbuffer[0] = (HEIZUNG << 5);					// Bit 5-7: Raumnummer
    outbuffer[0] |= (Zeit.stunde & 0x1F);			//	Bit 0-4: Stunde, 5 bit
    outbuffer[1] = (0x01 << 6);						// Bits 6,7: Art=1
    outbuffer[1] |= Zeit.minute & 0x3F;				// Bits 0-5: Minute, 6 bit
    outbuffer[2] = HeizungRXdaten[0];				//	Vorlauf
    
    outbuffer[3] = HeizungRXdaten[1];				//	Rücklauf
    outbuffer[4] = HeizungRXdaten[2];				//	Aussen
    
    outbuffer[5] = 0;
    outbuffer[5] |= HeizungRXdaten[3];				//	Brennerstatus Bit 2
    outbuffer[5] |= HeizungStundencode;			// Bit 4, 5 gefiltert aus Tagplanwert von Brenner und Mode
    outbuffer[5] |= RinneStundencode;				// Bit 6, 7 gefiltert aus Tagplanwert von Rinne
    
    uebertragen in d5
    */
   
   /*
    aus EinschaltDiagramm:
    int Stundenteil = DatenWert;
    int TagWert = DatenWert;
    TagWert &= 0x03;	// Bits 0, 1
    Stundenteil &= 0x08;	// Bit 3: 0: erste halbe Stunde
    Stundenteil >>=3;		// verschieben an Pos 0

    
    */
   
   NSArray* lastDataArray = [datastring componentsSeparatedByString:@"\t"];
  //  NSLog(@"setcodeFeldMit lastDataArray: %@ anz: %ld",lastDataArray,[lastDataArray count]);
   if (lastDataArray.count <8) // noch keine Daten
   {
      return;
   }
   int minute = ([[lastDataArray objectAtIndex:0]intValue]/60)%60;
  // NSLog(@"minute: %d",minute);
   float vorlauf = [[lastDataArray objectAtIndex:1]intValue]/2;
   float ruecklauf = [[lastDataArray objectAtIndex:2]intValue]/2;
   float aussen = ([[lastDataArray objectAtIndex:3]intValue]-32)/2; // Korrektur, s. TemperaturMKDiagramm l 70
   float innen = [[lastDataArray objectAtIndex:8]intValue]/2;

   float sole0 = [[lastDataArray objectAtIndex:9]intValue]/2;
   float sole1 = [[lastDataArray objectAtIndex:10]intValue]/2;
   float sole2 = [[lastDataArray objectAtIndex:11]intValue]/2;
   
 //if ([[[lastDataArray objectAtIndex:8]stringValue ]length] > 1)
 {
    //float innen = [[[lastDataArray objectAtIndex:8]substringToIndex:2]intValue]/2.0; // \n abschneiden
 }
   int heizungcode = [[lastDataArray objectAtIndex:4]intValue]; // code der Heizung
   NSString* heizungbitstring = [NSString stringWithCString:byte_to_binary(heizungcode) encoding:NSUTF8StringEncoding];
 //  NSLog(@"heizungcode: %d heizungbitstring: %@",heizungcode,heizungbitstring);

   
   int modestundencode = (heizungcode & 0x30)>>4; // bit 4,5
   NSString* modestundencodestring = [[NSString stringWithCString:byte_to_binary(modestundencode) encoding:NSUTF8StringEncoding]substringFromIndex:6];
   int modestufe = modestundencode;
   
   int brennerstundencode = (heizungcode & 0x03); // bit 1,2
  
   //brennerstundencode=32>>4;
   NSString* brennerstundencodestring = [[NSString stringWithCString:byte_to_binary(brennerstundencode) encoding:NSUTF8StringEncoding]substringFromIndex:6];
   //heizungcode = 15;
   
   BOOL brennerstatus = !((heizungcode & (1<<2))>>2); // bit 2
   int b1 = heizungcode & 0x04;
   int b2 = b1 >>2;
   int b3 = !b2;
   
   //NSLog(@"heizungcode: %d b1: %d b2: %d b3: %d heizungcode: %d brennerstatus: %s heizungbitstring: %@",heizungcode,b1,b2,b3,brennerstatus,byte_to_binary(134),heizungbitstring);
   NSString* brennerstatusstring =@"OFF";
   if ( brennerstatus)
   {
      brennerstatusstring =@" ON";
   }
 //  NSLog(@"brennerstundencode: %d brennerstundencodestring: %@ brennerstatusstring: %@",brennerstundencode,brennerstundencodestring,brennerstatusstring);

   
   BOOL        rinnestatus = (heizungcode & ((1<<6)|(1<<7)))>>6; // bit nach rechts schieben
   
  // NSLog(@"brennerstatus: %d rinne: %@",brennerstatus,brennerstatusstring);
   
   int rinnestundencode = (heizungcode & ((1<<6)|(1<<7)))>>6; // bit 6,7
   NSString* rinnestundencodestring = [[NSString stringWithCString:byte_to_binary(rinnestundencode) encoding:NSUTF8StringEncoding]substringFromIndex:6];

   if (minute<30) // erste halbe stunde, bit 6
   {
       rinnestatus = (heizungcode & ((1<<7)))>>7;
   }
   else
   {
      rinnestatus = (heizungcode & ((1<<6)))>>6;
   }
   NSString* rinnestatusstring =@"OFF";
   if ( rinnestatus)
   {
      rinnestatusstring =@" ON";
   }
//   NSLog(@"rinnestundencode: %d rinnestundencodestring: %@ rinnestatusstring: %@",rinnestundencode,rinnestundencodestring,rinnestatusstring);

   
  // NSLog(@"heizungcode  Brenner %d brenner: %d rinne: %d",heizungcode,brennerstatus,rinnestatus);
   
   NSString* tempStringA = [NSString stringWithFormat:@"HZ:\tVorlauf:\t%2.1f\tRuecklauf:\t%2.1f\tAussen:\t%2.1f",vorlauf, ruecklauf ,aussen];
   NSString* tempStringS = [NSString stringWithFormat:@"WP:\tSole VL:\t%2.1f\tSole RL:\t%2.1f",sole0, sole1 ];

   NSString* tempStringB = [NSString stringWithFormat:@"\tcode:\t%@\tbrennercode:\t%@\tstatus: \t%@",heizungbitstring, brennerstundencodestring,brennerstatusstring];
   NSString* tempStringC = [NSString stringWithFormat:@"\t\t\trinnecode:\t%@\tstatus: \t%@",rinnestundencodestring, rinnestatusstring];
   NSString* tempStringD = [NSString stringWithFormat:@"\t\t\tmodecode:\t%@\tposition: \t%d",modestundencodestring, modestufe];
  
   // WS
   int wslampestatus=0.0;
   int wsofenstatus=0.0;
   
   NSString* tempStringE = [NSString stringWithFormat:@"WS:\tLampe:\t%2.1d\tOfen:\t%2.1d\t*\t%2.1d",wslampestatus, wsofenstatus ,0];

   NSString* tempStringF = [NSString stringWithFormat:@"WZ:\tLampe:\t%2.1d\tOfen:\t%2.1d\t*\t%2.1d",wslampestatus, wsofenstatus ,0];

   NSString* tempStringG = [NSString stringWithFormat:@"BR:\tLampe:\t%2.1d\tOfen:\t%2.1d\t*\t%2.1d",wslampestatus, wsofenstatus ,0];

   
   
   NSMutableParagraphStyle *tempMutableParagraphStyle;
   float firstColumnInch = 0.8, otherColumnInch = 0.8, pntPerInch = 72.0;
   NSTextTab *tempTab;
   NSMutableArray *TabArray = [NSMutableArray arrayWithCapacity:14];
   NSMutableAttributedString   *tempAttString;
   tempMutableParagraphStyle = [[NSParagraphStyle defaultParagraphStyle]mutableCopy];
   [tempMutableParagraphStyle setAlignment:NSTextAlignmentLeft];
   
   /*
    possible tab stop types
    NSLeftTabStopType
    NSRightTabStopType
    NSCenterTabStopType
    NSDecimalTabStopType
    */
   float tab0 = 50.0;
   float tab1 = 100.0;
   float tab2 = 120.0;
   float tab3 = 220.0;
   float offset = 30.0;
   float data0tab= 90;  // data fuer text 0, r
   
   float text1tab= 110; // text 1, l
   float data1tab= 200; // data fuer text 1, r
   
   float text2tab= 220;// text 2, l
   float data2tab= 310;// data fuer text 2, r
   
   // offset
   tempTab = [[NSTextTab alloc]
              initWithType:NSLeftTabStopType
              location:offset];
   [TabArray addObject:tempTab];
   
   // data0
   tempTab = [[NSTextTab alloc]
              initWithType:NSRightTabStopType
              location:data0tab+offset];
   [TabArray addObject:tempTab];
   
   // text1, data1
   tempTab = [[NSTextTab alloc]
              initWithType:NSLeftTabStopType
              location:text1tab+offset];
   [TabArray addObject:tempTab];
   
   tempTab = [[NSTextTab alloc]
              initWithType:NSRightTabStopType
              location:data1tab+offset];
   [TabArray addObject:tempTab];
   
   // text2, data2
   tempTab = [[NSTextTab alloc]
              initWithType:NSLeftTabStopType
              location:text2tab+offset];
   [TabArray addObject:tempTab];
   tempTab = [[NSTextTab alloc]
              initWithType:NSRightTabStopType
              location:data2tab+offset];
   [TabArray addObject:tempTab];
   
   
   for(int i=1;i<4;i++)
   {
      tempTab = [[NSTextTab alloc]
                 initWithType:NSRightTabStopType
                 location:(firstColumnInch*pntPerInch)
                 + ((float)i * otherColumnInch * pntPerInch)];
      //        [TabArray addObject:tempTab];
   }
   [tempMutableParagraphStyle setTabStops:TabArray];
   codeString = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@",tempStringA,tempStringS, tempStringB,tempStringC,tempStringD];//,tempStringE,tempStringF,tempStringG];
   
   tempAttString = [[NSMutableAttributedString alloc]
                    initWithString:codeString];
   [tempAttString addAttribute:NSParagraphStyleAttributeName
                         value:tempMutableParagraphStyle
                         range:NSMakeRange(0,[codeString length])];
   
   [[codeFeld textStorage]setAttributedString:tempAttString];
   [codeFeld setNeedsDisplay:YES];
   
   // codeFeld.string = codeString;
 //  DLog(@"HomeDataDownloadAktion codeFeld: %@",[codeFeld string]);
   
}

-(void)HomeDataDownloadAktion:(NSNotification*)note
{
   /*
    Aufgerufen von rHomeData.
    Setzt Feldwerte im Fenster Data.
    
    */
   //NSLog(@"rData HomeDataDownloadAktion note: %@",note);
   [LoadMark performClick:NULL];
   
   if ([[note userInfo]objectForKey:@"err"])
   {
      [LastDataFeld setStringValue:[[note userInfo]objectForKey:@"err"]];
   }
   /*
    if ([[note userInfo]objectForKey:@"erfolg"])
    {
    [LastDataFeld setStringValue:[[note userInfo]objectForKey:@"erfolg"]];
    }
    */
   if ([[note userInfo]objectForKey:@"lasttimestring"])
   {
      [LastDatazeitFeld setStringValue:[[note userInfo]objectForKey:@"lasttimestring"]];
   }
   else
   {
      [LastDatazeitFeld setStringValue:@"keine Zeitangabe"];
   }
   
   anzLoads++;
   [ZaehlerFeld setIntValue:anzLoads];
   
   
   if (anzLoads > 15)
   {
      //NSBeep();
      [self reload:NULL];
   }
   
   //NSLog(@"rData HomeDataDownloadAktion anzLoads: %d",anzLoads);
   [LastDataFeld setStringValue:@"***"];
   
   
   //NSLog(@"rData HomeDataDownloadAktion quelle: %@",[[note userInfo]objectForKey:@"quelle"]);
   if ([[note userInfo]objectForKey:@"datastring"])
   {
      NSString* tempString = [[note userInfo]objectForKey:@"datastring"];
      //tempString= [[[[NSNumber numberWithInt:anzLoads]stringValue]stringByAppendingString:@": "]stringByAppendingString:tempString];
      NSArray *dataArray =  [[[note userInfo]objectForKey:@"datastring"]componentsSeparatedByString:@"\n"];
      //NSLog(@"dataArray: %@",dataArray);
      int anz = [dataArray count];
      if (anz > 2)
      {
         //NSLog(@"dataArray last: %@ anz: %ld",[dataArray objectAtIndex:[dataArray count]-2],[dataArray count]);
         tempString =[dataArray objectAtIndex:[dataArray count]-2];
      }
      if ([dataArray count]>9)
      {
         dataArray = [dataArray subarrayWithRange:NSMakeRange([dataArray count]-9, 9)];
         NSLog(@"dataArray korr: %@",dataArray);
      }
      //  NSLog(@"dataArray korr: %@",dataArray);
      [LastDataFeld setStringValue:tempString];
      
      [self setcodeFeldMit:tempString];
   }
   else
   {
      [LastDataFeld setStringValue:@"-"];
      [LastDataFeld setStringValue:@"--"];
      [LastDataFeld setStringValue:@"---"];
      [LastDataFeld setStringValue:@"----"];
      [LastDataFeld setStringValue:@"-----"];
   }
   
   /*
    if ([[note userInfo]objectForKey:@"lastdatazeit"])
    {
    int tempLastdataZeit=[[[note userInfo]objectForKey:@"lastdatazeit"] intValue];
    NSLog(@"lastdatazeit: %d * LastLoadzeit: %d",tempLastdataZeit,LastLoadzeit );
    
    int	tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];
    //[LastDatazeitFeld setStringValue:[[note userInfo]objectForKey:@"lastdatazeit"]];
    [LastDatazeitFeld setIntValue:tempLastdataZeit-LastLoadzeit];
    }
    */
   if ([[note userInfo]objectForKey:@"delta"])
   {
      NSString* deltaString=[NSString stringWithFormat:@"%2.4F",[[[note userInfo]objectForKey:@"delta"]floatValue]];
      [LoadtimeFeld setStringValue:deltaString];
   }
   
}// HomeDataDownloadAktion

/*
 // Ablauf bei lesen von EEPROM
 
 2012-12-16 20:21:45.112 WebInterface[20669:303] TWIReadStartURL: http://ruediheimlicherhome.dyndns.org/twi?pw=ideur00&radr=0&hb=00&lb=00
 2012-12-16 20:21:45.113 WebInterface[20669:303] didStartProvisionalLoadForFrame: URL: http://ruediheimlicherhome.dyndns.org/twi?pw=ideur00&radr=0&hb=00&lb=00
 2012-12-16 20:21:45.114 WebInterface[20669:303] AVRClient readEthTagplan EEPROMAddresse: 0 startadresse: 0  hbyte: 0 lbyte: 0
 2012-12-16 20:21:45.160 WebInterface[20669:303] didFinishLoadForFrame Antwort:
 HTML_Inhalt: 				<html><head></head><body><p>okcode=radr</p></body></html>
 2012-12-16 20:21:45.161 WebInterface[20669:303] radrok
 2012-12-16 20:21:47.162 WebInterface[20669:303] sendTimer fire  Anzahl: 10
 2012-12-16 20:21:47.162 WebInterface[20669:303] sendTimer fire URL: http://ruediheimlicherhome.dyndns.org/twi?pw=ideur00&rdata=10
 2012-12-16 20:21:47.164 WebInterface[20669:303] didStartProvisionalLoadForFrame: URL: http://ruediheimlicherhome.dyndns.org/twi?pw=ideur00&rdata=10
 2012-12-16 20:21:47.176 WebInterface[20669:303] didFinishLoadForFrame Antwort:
 HTML_Inhalt: 				<html><head></head><body><p>data=0+f+f3+33+ff+fd+ff+ff</p></body></html>
 2012-12-16 20:21:47.176 WebInterface[20669:303] FinishLoadAktion EEPROM lesen: data ist da
 2012-12-16 20:21:47.178 WebInterface[20669:303] TimeoutTimer start
 2012-12-16 20:21:49.379 WebInterface[20669:303] AVRClient reportTWIState: state: 1
 2012-12-16 20:21:49.380 WebInterface[20669:303] didStartProvisionalLoadForFrame: URL: http://ruediheimlicherhome.dyndns.org/twi?pw=ideur00&status=1
 2012-12-16 20:21:49.459 WebInterface[20669:303] didFinishLoadForFrame Antwort:
 HTML_Inhalt: 				<html><head></head><body><p>okcode=status1</p></body></html>

 */



- (void)ExterneDatenAktion:(NSNotification*)note
{
   /* In TWI_Master:
    outbuffer[0] = (HEIZUNG << 5);					// Bit 5-7: Raumnummer
    outbuffer[0] |= (Zeit.stunde & 0x1F);			//	Bit 0-4: Stunde, 5 bit
    outbuffer[1] = (0x01 << 6);						// Bits 6,7: Art=1
    outbuffer[1] |= Zeit.minute & 0x3F;				// Bits 0-5: Minute, 6 bit
    outbuffer[2] = HeizungRXdaten[0];				//	Vorlauf
    
    outbuffer[3] = HeizungRXdaten[1];				//	Rücklauf
    outbuffer[4] = HeizungRXdaten[2];				//	Aussen
    
    outbuffer[5] = 0;
    outbuffer[5] |= HeizungRXdaten[3];				//	Brennerstatus Bit 2
    outbuffer[5] |= HeizungStundencode;			// Bit 4, 5 gefiltert aus Tagplanwert von Brenner und Mode
    outbuffer[5] |= RinneStundencode;				// Bit 6, 7 gefiltert aus Tagplanwert von Rinne
    
    uebertragen in d5
    */

	Quelle=1;
	if ([[note userInfo]objectForKey:@"startzeit"])
	{
		//NSString* StartzeitString = [[note userInfo]objectForKey:@"startzeit"];
		//NSLog(@"ExterneDatenAktion: Startzeit: *%@* StartzeitString: *%@*",[[note userInfo]objectForKey:@"startzeit"],StartzeitString);
		
      // Datenseriestartzeit fuer ausgewaehltes Datum anpassen
      NSString* datumstring = [[note userInfo]objectForKey:@"startzeit"];
      
   //   NSDate* testdate = [self DateVonString:datumstring];
      
      NSMutableArray * startzeitarray = (NSMutableArray *)[datumstring componentsSeparatedByString:@" "];
      if ([[startzeitarray objectAtIndex:0] length ]== 0)
      {
         [startzeitarray removeObjectAtIndex:0];
      }
      //NSString* datumteil = [[datumstring componentsSeparatedByString:@" "]objectAtIndex:0];
      NSString* datumteil = [startzeitarray objectAtIndex:0];
      //NSString* zeitteil = [[datumstring componentsSeparatedByString:@" "]objectAtIndex:1];
      NSString* zeitteil = [startzeitarray objectAtIndex:1];
      int jr = [[[datumteil componentsSeparatedByString:@"-"]objectAtIndex:0]intValue];
      int mon = [[[datumteil componentsSeparatedByString:@"-"]objectAtIndex:1]intValue];
      int tg = [[[datumteil componentsSeparatedByString:@"-"]objectAtIndex:2] intValue];
      
      //DatenserieStartZeit = [self DatumvonJahr:jr Monat:mon Tag: tg];
      DatenserieStartZeit = [self DateVonString:datumstring];
		NSLog(@"ExterneDatenAktion: DatenserieStartZeit: %@",DatenserieStartZeit);
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[NotificationDic setObject:@"datastart"forKey:@"data"];
		[NotificationDic setObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
		
      //NSString * str = @"20160522115200";
      NSString * str = @"2018-01-02 00:00:50";
      NSDateFormatter * d1 = [[NSDateFormatter alloc] init];
      d1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
      NSDate * date = [d1 dateFromString: datumstring];
      d1.dateFormat = @"yyyy-MM-dd hh:mm:ss";
      str = [d1 stringFromDate: date];
      
      //NSCalendarDate* AnzeigeDatum= [DatenserieStartZeit copy];
      //[AnzeigeDatum setCalendarFormat:@"%d.%m.%y %H:%M"];
      
      //NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
      // [dateformat setDateFormat:@"%d.%m.%y %H:%M"];
      //  NSString *AnzeigeDatum  = [dateformat stringFromDate:DatenserieStartZeit];
      //[StartzeitFeld setStringValue:[AnzeigeDatum description]];
      
      /*
       NSTimeZone *cetTimeZone = [NSTimeZone timeZoneWithName:@"CET"];
       
       NSCalendar *startcalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
       startcalendar.firstWeekday = 2;
       [startcalendar setTimeZone:cetTimeZone];
       NSDateComponents *components = [startcalendar components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:DatenserieStartZeit];
       
       
       */

      NSTimeZone *cetTimeZone = [NSTimeZone timeZoneWithName:@"CET"];
      
      NSCalendar *externcalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
      externcalendar.firstWeekday = 2;
      [externcalendar setTimeZone:cetTimeZone];

      
      NSCalendar *tagcalendar = [NSCalendar currentCalendar];
      [tagcalendar setFirstWeekday:2];
 //     NSDateComponents *heutecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:DatenserieStartZeit];
      NSDateComponents *heutecomponents = [externcalendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:DatenserieStartZeit];
      
      
      NSInteger tagdesmonats = [heutecomponents day];
      NSInteger monat = [heutecomponents month];
      NSInteger jahr = [heutecomponents year];
      NSInteger stunde = [heutecomponents hour];
      NSInteger minute = [heutecomponents minute];
      NSInteger sekunde = [heutecomponents second];
      
      jahr-=2000;
      NSString* StartZeit = [NSString stringWithFormat:@"%02ld.%02ld.%02ld",(long)tagdesmonats,(long)monat,(long)jahr];
      
      
      NSString* StartZeitFull = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld:%02ld",(long)tagdesmonats,(long)monat,(long)jahr,(long)stunde,(long)minute,(long)sekunde];
      
      NSString* StartZeitString = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld",(long)tagdesmonats,(long)monat,(long)jahr,(long)stunde,(long)minute];
      
      
      NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
      //[dateformat setDateFormat:@"%d.%m.%y %H:%M"];
      dateformat.dateStyle = NSDateFormatterLongStyle;
      dateformat.timeStyle = NSDateFormatterMediumStyle;
      
      
      NSString *AnzeigeString  = [dateformat stringFromDate:DatenserieStartZeit];
      
     // [StartzeitFeld setStringValue:AnzeigeString];
      
       [StartzeitFeld setStringValue:StartZeitString];
      
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
		
		//NSLog(@"ExterneDatenAktion DatenserieStartZeit: %@ tag: %d",  [DatenserieStartZeit description], tag);
	}
	
		
	if ([[note userInfo]objectForKey:@"datenarray"])
	{
		
		NSArray* TemperaturKanalArray=	[NSArray arrayWithObjects:@"1",@"1",@"1",@"0" ,@"0",@"0",@"0",@"1",@"0",@"1",@"1",@"0",nil];
//		NSArray* BrennerKanalArray=		[NSArray arrayWithObjects:@"1",@"1",@"0",@"0" ,@"0",@"0",@"0",@"0",nil];
		
		NSArray* tempDatenArray = [[note userInfo]objectForKey:@"datenarray"];
		
      
      //NSLog(@"ExterneDatenAktion tempDatenArray last Data:%@",[[tempDatenArray lastObject]description]);
		
		// Zeit des ersten Datensatzes
		int firstZeit = [[[[tempDatenArray objectAtIndex:0] componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue];
		
		
		// Zeit des letzten Datensatzes
		int lastZeit = [[[[tempDatenArray lastObject] componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue];
		//NSLog(@"ExterneDatenAktion firstZeit: %d lastZeit: %d",firstZeit,lastZeit);
      //NSLog(@"lastZeit: %d",lastZeit);
		[LaufzeitFeld setStringValue:[self stringAusZeit:lastZeit]]; 
		
		// Breite des DocumentViews bestimmen
//		lastZeit -= firstZeit;
		lastZeit *= ZeitKompression;
		//NSLog(@"ExterneDatenaktion Zeitkompression: %2f2",ZeitKompression);
		//	Origin des vorhandenen DocumentViews
		NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
		//NSLog(@"ExterneDatenaktion tempOrigin: x: %2.2f y: %2.2f",tempOrigin.x, tempOrigin.y);
		//28.7.09
		tempOrigin.x=0;
		[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
		
		
		//	Frame des vorhandenen DocumentViews
		NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
		//NSLog(@"ExterneDatenaktion  tempOrigin: x: %2.2f  tempFrame width: x: %2.2f y: %2.2f",tempOrigin.x,tempFrame.size.width);
		
		//	Verschiebedistanz des angezeigten Fensters
		
		if (tempFrame.size.width < lastZeit)
		{
			//NSLog(@"tempFrame.size.width < lastZeit width: %2.2f lastZeit: %5d",tempFrame.size.width,lastZeit);
			//float delta=[[TemperaturDiagrammScroller contentView]frame].size.width-150;
			int PlatzRechts = 80;
			float delta=lastZeit- [[TemperaturDiagrammScroller documentView]bounds].size.width+PlatzRechts; // Abstand vom rechten Rand, Platz fuer Datentitel und Wert
			NSPoint scrollPoint=[[TemperaturDiagrammScroller documentView]bounds].origin;
			//NSLog(@"delta: %2.2f",delta);
			//	DocumentView vergroessern
			tempFrame.size.width+=delta;
			
			//	Origin des DocumentView verschieben
			//NSLog(@"tempOrigin.x vor: %2.2f",tempOrigin.x);
			tempOrigin.x-=delta;
			//NSLog(@"tempOrigin.x nach: %2.2f",tempOrigin.x);
			
			//	Origin der Bounds verschieben
			//NSLog(@"scrollPoint.x vor: %2.2f",scrollPoint.x);
			scrollPoint.x += delta;
			//NSLog(@"scrollPoint.x nach: %2.2f",scrollPoint.x);
			
			//NSLog(@"tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			//NSLog(@"tempFrame: neu x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
			
			NSRect MKDiagrammRect=[TemperaturMKDiagramm frame];
			MKDiagrammRect.size.width=tempFrame.size.width;
			//NSLog(@"MKDiagrammRect.size.width: %2.2f",MKDiagrammRect.size.width);
			[TemperaturMKDiagramm setFrame:MKDiagrammRect];
			
			NSRect BrennerRect=[BrennerDiagramm frame];
			BrennerRect.size.width=tempFrame.size.width;
			//NSLog(@"BrennerRect.size.width: %2.2f",BrennerRect.size.width);
			
			[BrennerDiagramm setFrame:BrennerRect];
			
			NSRect GitterlinienRect=[Gitterlinien frame];
			GitterlinienRect.size.width=tempFrame.size.width;
			//NSLog(@"GitterlinienRect.size.width: %2.2f",GitterlinienRect.size.width);
			
			[Gitterlinien setFrame:GitterlinienRect];
			
			NSRect DocRect=[[TemperaturDiagrammScroller documentView]frame];
			//NSLog(@"DocRect.size.width vor: %2.2f",DocRect.size.width);
			DocRect.size.width=tempFrame.size.width;
			//NSLog(@"DocRect.size.width nach: %2.2f",DocRect.size.width);
			
			[[TemperaturDiagrammScroller documentView] setFrame:DocRect];
			//NSLog(@"tempOrigin end  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
			
			//NSLog(@"ExterneDatenaktion  tempOrigin: x: %2.2f  *   DocRect width: %2.2f",tempOrigin.x,DocRect.size.width);
			
			//NSLog(@"scrollPoint end  x: %2.2f y: %2.2f",scrollPoint.x,scrollPoint.y);
			[[TemperaturDiagrammScroller contentView] scrollPoint:scrollPoint];
			[TemperaturDiagrammScroller setNeedsDisplay:YES];
			
		}
		
		NSString* TemperaturDatenString= [NSString string];
		NSEnumerator* DatenEnum = [tempDatenArray objectEnumerator];
		id einDatenString;
		
		while (einDatenString = [DatenEnum nextObject])
		{
			//NSString* tempDatenString=(NSString*)[einDatenString substringWithRange:NSMakeRange(0,[einDatenString length]-1)];
			
			//NSMutableArray* tempZeilenArray= (NSMutableArray*)[einDatenString componentsSeparatedByString:@"\t"];
         
			// Datenstring aufteilen in Komponenten
         
			NSMutableArray* tempZeilenArray= (NSMutableArray*)[einDatenString componentsSeparatedByString:@"\r"];
			
			//NSLog(@"ExterneDatenAktion einDatenString: %@\n tempZeilenArray:%@\n", einDatenString,[tempZeilenArray description]);
			//NSLog(@"ExterneDatenAktion einDatenString: %@ count: %d", einDatenString, [tempZeilenArray count]);
			if ([tempZeilenArray count]>= 9) // Daten vollständig
			{
	//			NSLog(@"ExterneDatenAktion tempZeilenArray:%@",[tempZeilenArray description]);
				// Datenserie auf Startzeit synchronisieren
				int tempZeit=[[tempZeilenArray objectAtIndex:0]intValue];
				
				tempZeit -= firstZeit;
				[tempZeilenArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:tempZeit]];
				
				[TemperaturMKDiagramm setWerteArray:tempZeilenArray mitKanalArray:HeizungKanalArray];
				
				
				[TemperaturMKDiagramm setNeedsDisplay:YES];
				NSMutableDictionary* tempVorgabenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
				[tempVorgabenDic setObject:[NSNumber numberWithInt:5]forKey:@"anzbalken"];
				[tempVorgabenDic setObject:[NSNumber numberWithInt:3]forKey:@"datenindex"];
				

				[BrennerDiagramm setWerteArray:tempZeilenArray mitKanalArray:BrennerKanalArray mitVorgabenDic:tempVorgabenDic];
				
		//		[BrennerDiagramm setWerteArray:tempZeilenArray mitKanalArray:BrennerKanalArray];
				[BrennerDiagramm setNeedsDisplay:YES];
				[Gitterlinien setWerteArray:tempZeilenArray mitKanalArray:BrennerKanalArray];
				[Gitterlinien setNeedsDisplay:YES];
				//TemperaturDatenString=[NSString stringWithFormat:@"%@\r\t%@",TemperaturDatenString,tempDatenString];
				
				// Aus TempZeilenarray einen tab-getrennten String bilden
				NSString* tempZeilenString=[tempZeilenArray componentsJoinedByString:@"\t"];
				//				NSLog(@"tempZeilenString: %@", tempZeilenString);
				TemperaturDatenString=[NSString stringWithFormat:@"%@\r\t%@",TemperaturDatenString,tempZeilenString];
				//				TemperaturDatenString=[NSString stringWithFormat:@"%@\r\t%@",TemperaturDatenString,einDatenString];
				
			}
			
		}	// while
		AnzDaten=[tempDatenArray count];
		//NSLog(@"ExterneDatenAktion AnzDaten: %d",AnzDaten);
		[AnzahlDatenFeld setIntValue:[tempDatenArray count]];
		
		[TemperaturDatenFeld setString:TemperaturDatenString];
		NSRange insertAtEnd=NSMakeRange([[TemperaturDatenFeld textStorage] length],0);
		[TemperaturDatenFeld scrollRangeToVisible:insertAtEnd];

		[ClearTaste setEnabled:YES];
		
// 14.4.10 Doppeltes Laden verhindern.
		NSTimer* KalenderTimer=[NSTimer scheduledTimerWithTimeInterval:1
																			  target:self 
																			selector:@selector(KalenderFunktion:) 
																			userInfo:nil 
																			 repeats:NO];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:KalenderTimer forMode:NSDefaultRunLoopMode];
		

		//Kalenderblocker=0;
	}
	//NSBeep();
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"loaddataok"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"LoadData" object:self userInfo:NotificationDic];
	
   [Kalender setEnabled:YES];
	
	NSMutableDictionary* BalkendatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[BalkendatenDic setObject:[NSNumber numberWithInt:1]forKey:@"aktion"];
	
	//NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	
   
   
   [nc postNotificationName:@"StatistikDaten" object:NULL userInfo:BalkendatenDic];

   
   [TemperaturStatistikDiagramm setNeedsDisplay:YES];
	[TagGitterlinien setNeedsDisplay:YES];
	//NSLog(@"ExterneDatenAktion end");
	
}


- (void)ReadStartAktion:(NSNotification*)note
{
	if ([[note userInfo]objectForKey:@"iowbusy"])
	{
		IOW_busy=[[[note userInfo]objectForKey:@"iowbusy"]intValue];
		
	}
	else
	{
		IOW_busy=0;
	}
}

- (void)KalenderFunktion:(NSTimer*)derTimer
{
   NSLog(@"Kalenderfunktion");
	Kalenderblocker=0;
}

- (void)ReadAktion:(NSNotification*)note
{
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	// specify just positive format
	[numberFormatter setFormat:@"##0.00"];
	
	
	//NSLog(@"ReadAktion note: %@",[[note userInfo]description]);
	NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
	NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
	
	NSArray* DataArray=[[note userInfo]objectForKey:@"datenarray"];
	int Raum=0, Stunde=0,Minuten=0;
	
	//float tempZeit=0;
	int tempZeit=0;
	BOOL Messbeginn=NO;
	
	//NSString* tabSeparator=@"\t";
	//NSString* crSeparator=@"\r";
	
	NSMutableString* tempWertString=(NSMutableString*)[TemperaturWertFeld string];//Vorhandene Daten im Wertfeld
	NSLog(@"TemperaturZeilenString: %@",TemperaturZeilenString);
	
	if ([[TemperaturDaten objectForKey:@"datenarray"]count]==0 && Messbeginn==NO && [DatenpaketArray count]==0) // Messbeginn
	{
		//NSLog(@"								*** Messbeginn");
		Messbeginn=YES;
		//NSLog(@"TemperaturDaten: %@",[TemperaturDaten description]);
		//DatenserieStartZeit=[NSDate date];
		//[TemperaturDaten setObject:[NSDate date] forKey:@"datenseriestartzeit"];
	}
	if (DataArray && ([DataArray count]==4) ) // Es gibt korrekte Daten vom IOW, letztes El ist immer 00
	{
		/*
		Aufbau des Pakets:
		4 Bytes pro Report
		Byte 0:		Mark (Maske 0x03), sonstige Steuerungen
		Byte 1,2:	Data
		Byte 3:			
		
		
		
		
		
		
		*/
		NSMutableArray* tempWerteArray=[[NSMutableArray alloc]initWithCapacity:0];
		
//		NSArray* TemperaturKanalArray=	[NSArray arrayWithObjects:@"1",@"1",@"1",@"0" ,@"0",@"0",@"0",@"0",nil];
//		NSArray* BrennerKanalArray=		[NSArray arrayWithObjects:@"0",@"0",@"0",@"1" ,@"0",@"0",@"0",@"0",nil];
		
		// Mark des Datenpaketes:	0: Schluss, Null-Werte	1: Gueltige Daten
		int mark=([self HexStringZuInt:[DataArray objectAtIndex:0]] & 0x03);			// von PORTC
		//NSLog(@"mark: %d",mark);
		
		Raum= ([self HexStringZuInt:[DataArray objectAtIndex:1]] & 0xE0);				// Bits 5-7	 von PORTB
		
		if (DatenpaketArray==NULL)// Sammelarray fuer Daten eines Pakets
		{
			DatenpaketArray=[[NSMutableArray alloc]initWithCapacity:0];
			
		}
		
		switch (mark)
		{
			case 0: // Pakete der Serie sind fertig gelesen
			{
				IOW_busy=0; 
				//NSLog(@"Paket Ende: mark: %d DataArray: %@",mark,[DataArray description]);
				
				//	Letztes Byte des Terminator-Reports ist immer 0
				if (!([[DataArray objectAtIndex:2]intValue]==0))// && [[DataArray objectAtIndex:1]intValue]==0))
				{
					
					break;
				}
				
				//NSLog(@"Paket Ende: DatenpaketArray: %@",[DatenpaketArray description]);
				if (Messbeginn) // Messbeginn, Erstes Paket empfangen
				{
					NSLog(@"Messbeginn");
					Messbeginn=NO;
					//NSRange r=NSMakeRange(1,[DatenpaketArray count]-1);
					if ([DatenpaketArray count]==7)
					{
						//				[TemperaturMKDiagramm setStartWerteArray:[DatenpaketArray subarrayWithRange:r]];
					}
					// Startzeit bestimmen
					tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
					
				}
				else
				{
					Messbeginn=NO;
					//	Anzahl Datenpakete kontrollieren
					if ([DatenpaketArray count]>7)// Fehler
					{
						NSLog(@"ErrZuLang: %d",ErrZuLang);
						NSLog(@"ErrZuLang: %d DatenpaketArray: %@",ErrZuLang,[DatenpaketArray description] );
						errString =[NSString stringWithFormat:@"%@\rAnzDaten: %d ErrZuLang: %d DatenpaketArray: %@",errString,AnzDaten,ErrZuLang,[DatenpaketArray componentsJoinedByString:@"\t"]];
						[DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
						
						/*
						 if (ReportErrIndex>=0)// Pakete mit 2x 0xFF sind vorgekommen
						 {
						 
						 NSLog(@"Korrektur: ReportErrIndex: %d Data: %@",ReportErrIndex,[DatenpaketArray objectAtIndex:2*ReportErrIndex +1]);
						 [DatenpaketArray removeObjectAtIndex:2*ReportErrIndex +1]; //	Erster Wert des fehlerhaften Reports
						 [DatenpaketArray removeObjectAtIndex:2*ReportErrIndex +1]; //	Zweiter Wert des fehlerhaften Reports (Nachrutschen)
						 }
						 
						 while ([DatenpaketArray count]>7)
						 {
						 NSLog(@"Korrektur: red Anz: %d",[DatenpaketArray count]);
						 [DatenpaketArray removeObjectAtIndex:[DatenpaketArray count]-1];
						 }
						 //NSLog(@"Korrektur: DatenpaketArray: %@",[DatenpaketArray description]);
						 
						 
						 if ([DatenpaketArray count])
						 {
						 [DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
						 }
						 */
						
						ErrZuLang++;
						
						[ErrZuLangFeld setIntValue:ErrZuLang];
						par=0;
						break;
					}
					
					if ([DatenpaketArray count]<7)
					{
						ErrZuKurz++;
						//NSLog(@"ErrZuKurz: %d",ErrZuKurz);
						NSLog(@"ErrZuKurz: %d DatenpaketArray: %@ ",ErrZuKurz,[DatenpaketArray description] );
						errString =[NSString stringWithFormat:@"%@\rAnzDaten: %d ErrZuKurz: %d DatenpaketArray: %@",errString,AnzDaten,ErrZuKurz,[DatenpaketArray  componentsJoinedByString:@"\t"]];
						[ErrZuKurzFeld setIntValue:ErrZuKurz];
						if ([DatenpaketArray count])
						{
							[DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
						}
						par=0;
						break;
					}
					//NSLog(@"[DatenpaketArray count]: %d",[DatenpaketArray count]);
					
					
					if ([DatenpaketArray count]==9)
					{
						
						AnzDaten++;
						//errString =[NSString stringWithFormat:@"%@\rAnzDaten: %d AllOK DatenpaketArray: %@",errString,AnzDaten,[DatenpaketArray description]];
						//[errString retain];
						int iowPar=[[DataArray objectAtIndex:1]intValue];
						//NSLog(@"														***			Last:    par: %X iowPar: %X",par, iowPar);
						if (!(iowPar==par))
						{
							
							int tempPar=[ParFeld intValue];
							tempPar++;
							NSLog(@"ParFehler: %d DatenpaketArray: %@",tempPar, [DatenpaketArray description]);
							[ParFeld setIntValue:tempPar];
							errString =[NSString stringWithFormat:@"%@\rAnzDaten: %d ParFehler: %d DatenpaketArray: %@",errString,AnzDaten,ErrZuLang,[DatenpaketArray  componentsJoinedByString:@"\t"]];
							if ([DatenpaketArray count])
							{
	//	22.3.09					[DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
							}
							par=0;
	// 22.3.09				break;
						}
						else
						{
							//NSLog(@"par OK");
							par=0;
						}
						
						
						[AnzahlDatenFeld setIntValue:AnzDaten];
						//NSLog(@"DatenpaketArray: %@" ,[DatenpaketArray description]);
						//NSLog(@"TemperaturKanalArray: %@" ,[TemperaturKanalArray description]);
						[TemperaturMKDiagramm setWerteArray:DatenpaketArray mitKanalArray:HeizungKanalArray];
						[TemperaturMKDiagramm setNeedsDisplay:YES];
						
						[BrennerDiagramm setWerteArray:DatenpaketArray mitKanalArray:BrennerKanalArray];
						[BrennerDiagramm setNeedsDisplay:YES];
						[Gitterlinien setWerteArray:DatenpaketArray mitKanalArray:BrennerKanalArray];
						[Gitterlinien setNeedsDisplay:YES];
						//NSLog(@"DatenpaketArray: %@",[DatenpaketArray description]);
						
						/*
						 int i;
						 UInt8*	buffer;
						 buffer = malloc ([DatenpaketArray count]);
						 buffer[0]=[[DatenpaketArray objectAtIndex:0]intValue];
						 int min=[[DatenpaketArray objectAtIndex:0]floatValue]*100;
						 buffer[1]= min%100;
						 for (i=2;i<[DatenpaketArray count];i++)
						 {
						 buffer[i]=[[DatenpaketArray objectAtIndex:i]intValue];
						 }
						 NSData* SerieData=[NSData dataWithBytes:buffer length:SerieSize];
						 
						 //NSLog(@"Data aus buffer: %@",[SerieData description]);
						 free (buffer);
						 
						 UInt8*	controlbuffer;
						 controlbuffer = malloc ([DatenpaketArray count]);
						 [SerieData getBytes:controlbuffer];
						 for (i=0;i<[DatenpaketArray count];i++)
						 {
						 //NSLog(@"controlbuffer i: %d Data: %d",i,controlbuffer[i]);
						 }
						 free(controlbuffer);
						 */
						
						AnzReports=0;
						ReportErrIndex=-1;
						//						[TemperaturDaten setObject: [DatenpaketArray copy] forKey:@"datenarray"]; // Dic mit Daten
						NSRange r=NSMakeRange(1,[DatenpaketArray count]-1);
						NSString* TemperaturwerteString=[[DatenpaketArray subarrayWithRange:r] componentsJoinedByString:@"\t"];
						tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
						
						[LaufzeitFeld setStringValue:[self stringAusZeit:tempZeit]]; 
						//NSString* tempWertFeldString=[NSString stringWithFormat:@"\t%2.2f\t%@",tempZeit,TemperaturwerteString];
						NSString* tempWertFeldString=[NSString stringWithFormat:@"\t%d\t%@",tempZeit,TemperaturwerteString];
						//[TemperaturWertFeld setString:tempWertFeldString];
						
						NSString* TemperaturDatenString=[NSString stringWithFormat:@"%@\r%@",[TemperaturDatenFeld string],tempWertFeldString];
						
						[TemperaturDatenFeld setString:TemperaturDatenString];
						
						
						//[DruckDatenView setString:TemperaturDatenString];
						NSRange insertAtEnd=NSMakeRange([[TemperaturDatenFeld textStorage] length],0);
						[TemperaturDatenFeld scrollRangeToVisible:insertAtEnd];
						
						//[TemperaturWertFeld setStringValue:[TemperaturZeilenString copy]];
						//NSLog(@"TemperaturDatenString: %@",TemperaturDatenString);
						[DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
						//					Origin des vorhandenen DocumentViews
						//					NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
						
						//					Frame des vorhandenen DocumentViews
						//					NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
						
						//					Abszisse der Anzeige
						tempZeit*= ZeitKompression; // fuer Anzeige
						
						//NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
						//NSLog(@"tempFrame.size.width: %2.2f tempZeit: %2.2f",tempFrame.size.width,tempZeit);
						
						float rest=tempFrame.size.width-(float)tempZeit;//*ZeitKompression);
						
						
						if ((rest<100)&& (!IOW_busy))
						{
							//NSLog(@"rest zu klein: %2.2f",rest);
							//NSLog(@"tempOrigin alt  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
							//NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
							
							//						Verschiebedistanz des angezeigten Fensters
							float delta=[[TemperaturDiagrammScroller contentView]frame].size.width-150;
							NSPoint scrollPoint=[[TemperaturDiagrammScroller documentView]bounds].origin;
							
							//						DocumentView vergroessern
							tempFrame.size.width+=delta;
							
							//						Origin des DocumentView verschieben
							tempOrigin.x-=delta;
							
							//						Origin der Bounds verschieben
							scrollPoint.x += delta;
							
							//NSLog(@"tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
							//NSLog(@"tempFrame: neu x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
							
							NSRect MKDiagrammRect=[TemperaturMKDiagramm frame];
							MKDiagrammRect.size.width=tempFrame.size.width;
							[TemperaturMKDiagramm setFrame:MKDiagrammRect];
							
							NSRect BrennerRect=[BrennerDiagramm frame];
							BrennerRect.size.width=tempFrame.size.width;
							[BrennerDiagramm setFrame:BrennerRect];
							
							NSRect GitterlinienRect=[Gitterlinien frame];
							GitterlinienRect.size.width=tempFrame.size.width;
							[Gitterlinien setFrame:GitterlinienRect];
							
							NSRect DocRect=	[[TemperaturDiagrammScroller documentView]frame];
							DocRect.size.width=tempFrame.size.width;
							
							[[TemperaturDiagrammScroller documentView] setFrame:DocRect];
							[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
							
							
							[[TemperaturDiagrammScroller contentView] scrollPoint:scrollPoint];
							[TemperaturDiagrammScroller setNeedsDisplay:YES];
							
							Messbeginn=NO;
						}
					}// 7 Daten
					else
					{
						//NSLog(@"Aufraeumen 7 Daten: %@",[DatenpaketArray description]);
						if ([DatenpaketArray count])
						{
							[DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
						}
						
					}
				}// Daten fertig
				
			}	break;
				
			case 1:	// Raum und Stunde, Minuten, Daten
			{
				
				if ([DatenpaketArray count]==0)
				{
					/*
					Erstes Paket schickt Zeit-Daten
					Byte 1:	Stunde, Maske 0x1F, Bits 0-4 von PORTB
					Byte 2:	Minute, Maske 0x3F, Bits 0-5 von PORTD
					*/
					//NSLog(@"\n\n"); // Leerzeile
					//NSLog(@"Paket Start");
					par=0;
					Raum=0;
					//NSLog(@"Paket Start: %X		%X",[[DataArray objectAtIndex:1]intValue] ,[[DataArray objectAtIndex:2]intValue]);
					//NSLog(@"Paket Start: %@		%@",[DataArray objectAtIndex:1] ,[DataArray objectAtIndex:2]);
					tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];//;
					NSString* tempZeitString=[NSString stringWithFormat:@"%2.2f",tempZeit];
					//NSLog(@"abgelaufene Zeit: tempZeit:  %2.2f	tempZeitString: %@",tempZeit,tempZeitString);
					tempWertString=[tempWertString stringByAppendingString:tempZeitString];
					
					if (([self HexStringZuInt:[DataArray objectAtIndex:1]] + [self HexStringZuInt:[DataArray objectAtIndex:2]])%2) //Ungerade
					{
						par |= (1<<0);
						
						//NSLog(@"Zeit Data: %X  %X					par ungerade: %d",[self HexStringZuInt:[DataArray objectAtIndex:1]] ,[self HexStringZuInt:[DataArray objectAtIndex:2]],par);
					}
					else
					{
						//NSLog(@"Zeit Data: %X  %X					par gerade: %d",[self HexStringZuInt:[DataArray objectAtIndex:1]] ,[self HexStringZuInt:[DataArray objectAtIndex:2]],par);
					}
					
					Stunde=([self HexStringZuInt:[DataArray objectAtIndex:1]] & 0x1F);	// Bits 0-4 von PORTB
					Minuten=([self HexStringZuInt:[DataArray objectAtIndex:2]] & 0x3F);			// von PORTD
					//	NSLog(@"Raum: %@ Zeit: %d:%d tempZeit: %d Kompression: %2.2f",[Raumnamen objectAtIndex:Raum],Stunde,Minuten, tempZeit,ZeitKompression);
					[tempWerteArray addObject:[DataArray objectAtIndex:2]];
					
					[DatenpaketArray addObject:[NSNumber numberWithFloat:tempZeit]]; // Zeitstempel
					//[TemperaturWertFeld setStringValue:tempWertString];
				}
				else
				{
				
					/*
					Pakete 2, 3:	Data
					
					*/
					
					//NSLog(@"Report: (Null-basiert): %d		Data: %X	%X",AnzReports,[[DataArray objectAtIndex:1]intValue] ,[[DataArray objectAtIndex:2]intValue]);
					if ([DataArray objectAtIndex:1]==0xFF && [DataArray objectAtIndex:2]==0xFF)	// Wahrscheinlich Fehler
					{
						ReportErrIndex=AnzReports;
						NSLog(@"Fehler: ReportErrIndex: %d",ReportErrIndex);
					}
					else	// 6.3.09
					{
						//NSLog(@"Report: %d D1: %d D2: %d",AnzReports,[self HexStringZuInt:[DataArray objectAtIndex:1]],[self HexStringZuInt:[DataArray objectAtIndex:2]]);
						[tempWerteArray addObject:[DataArray objectAtIndex:1]];			// von PORTB
						
						// Experimente
						NSString* tempWertStringB=[NSString stringWithFormat:@"%2.1f",[self HexStringZuInt:[DataArray objectAtIndex:1]]];
						//NSString* tempWertStringB=[NSString stringWithFormat:@"%d",[self HexStringZuInt:[DataArray objectAtIndex:1]]];
						//NSLog(@"***  tempWertStringB: %@",tempWertStringB);
						tempWertString=[tempWertString stringByAppendingString:tempWertStringB];
						
						//NSString* tempWertStringBB=[NSString stringWithFormat:@"%d",[self HexStringZuInt:[DataArray objectAtIndex:1]]];
						//NSLog(@"++  tempWertStringBB: %@",tempWertStringBB);
						//[TemperaturZeilenString appendFormat:@"\t%@",tempWertStringB];			
						
						[tempWerteArray addObject:[DataArray objectAtIndex:2]];			// von PORTD
						NSString* tempWertStringD=[NSString stringWithFormat:@"%2.1f",[self HexStringZuInt:[DataArray objectAtIndex:2]]];
						//NSLog(@"tempWertStringD: %@",tempWertStringD);
						tempWertString=[tempWertString stringByAppendingString:tempWertStringD];
						//[TemperaturZeilenString appendFormat:@"\t%@",tempWertStringD];				
						
						// end Experimente
						
						// Daten in DatenpaketArray einsetzen
						[DatenpaketArray addObject:[NSNumber numberWithInt:[self HexStringZuInt:[DataArray objectAtIndex:1]]]];
						[DatenpaketArray addObject:[NSNumber numberWithInt:[self HexStringZuInt:[DataArray objectAtIndex:2]]]];
						
						//[TemperaturWertFeld setStringValue:tempWertString];
						//NSLog(@"\n								Data: %X  %X   AnzReports: %d",[[DataArray objectAtIndex:1]intValue],[[DataArray objectAtIndex:2]intValue],AnzReports);
						//NSLog(@"par vor: %x	anzReports: %d",par, AnzReports);
						
						// Paritaet
						if  (AnzReports<3)
						{
							if (([self HexStringZuInt:[DataArray objectAtIndex:1]] + [self HexStringZuInt:[DataArray objectAtIndex:2]])%2) //Ungerade
							{
								par |= (1<<(AnzReports+1));
								//NSLog(@"AnzReports: %d    Data: %X  %X					par ungerade: %d",AnzReports,[self HexStringZuInt:[DataArray objectAtIndex:1]] ,[self HexStringZuInt:[DataArray objectAtIndex:2]],par);
								
								//NSLog(@"AnzReports: %d				par ungerade: %X",AnzReports,par);
							}
							else
							{
								//NSLog(@"AnzReports: %d    Data: %X  %X				par gerade: %d",AnzReports,[self HexStringZuInt:[DataArray objectAtIndex:1]] ,[self HexStringZuInt:[DataArray objectAtIndex:2]],par);
								//NSLog(@"AnzReports: %d				par gerade: %X",AnzReports,par);
							}
							
							
						}
						
						
						
						AnzReports++; // Anzahl Reports ohne Schlussreport darf nicht groesser sein als 4
					}	// 0xFF	6.3.09
				} 				
				
			}break;// case 2
				
				
			case 3: // neue Stunde: Datum
			{
				
			}break;
				
		} // switch mark
		
		
	} // if count
}

- (void)LastDatenAktion:(NSNotification*)note
{
	if (Kalenderblocker)
	{
		NSLog(@"LastDatenAktion	Kalenderblocker");
		return;
	}
	NSString* StartDatenString=[[[TemperaturDatenFeld string]componentsSeparatedByString:@"\r"]objectAtIndex:0];
	
   //NSLog(@"LastDatenAktion StartDatenString: *%@*",StartDatenString);
//	NSString* Kalenderformat=[[NSCalendarDate calendarDate]calendarFormat];
//	NSLog(@"LastDatenaktion note: %@",[[note userInfo]description]);
   
   if ([[note userInfo]objectForKey:@"lastdatenarray"])
   {
      NSArray* temparray =[[note userInfo]objectForKey:@"lastdatenarray"];
     // NSLog(@"LastDatenAktion temparray: %@",temparray);
     // [self setcodeFeldMit:[[[note userInfo]objectForKey:@"lastdatenarray"]componentsJoinedByString:@"\t"]];
   }
	if ([[note userInfo]objectForKey:@"startzeit"])
	{
		//DatenserieStartZeit=[NSCalendarDate dateWithString:[[note userInfo]objectForKey:@"startzeit"] calendarFormat:Kalenderformat];
      DatenserieStartZeit = [[note userInfo]objectForKey:@"startzeit"];
   }
	//int firsttag=[DatenserieStartZeit dayOfMonth];
	int firstZeit=0;
	if (StartDatenString && [StartDatenString length])
	{
		// Zeit des ersten Datensatzes
		firstZeit = [[[StartDatenString componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue];
		//NSLog(@"LastDatenAktion firstZeit: %d",firstZeit);
	}
	
	if ([[note userInfo]objectForKey:@"lastdatazeit"])
	{
		//	[LastDataFeld setStringValue:[[note userInfo]objectForKey:@"lastdatazeit"]];
	}
	anzLoads=0;
	[ZaehlerFeld setIntValue:anzLoads];
 //  codeString = [NSString stringWithFormat:@"anzLoads: %d",anzLoads ];
 //  [codeFeld insertText: codeString];
   
//   NSLog(@"LastDataAktion codeFeld: %@",[codeFeld string]);
   
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	// specify just positive format
	[numberFormatter setFormat:@"##0.00"];
	
	//	[LoadMark  performClick:NULL];
	
	//NSLog(@"LastDatenAktion note: %@",[[note userInfo]description]);
	NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
	NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
	if ([[note userInfo]objectForKey:@"lastdatenarray"])
	{
		NSMutableArray* HomeDatenArray=(NSMutableArray*)[[note userInfo]objectForKey:@"lastdatenarray"];
		//NSLog(@"LastDatenAktion HomeDatenArray: %@",[HomeDatenArray description]);
		//		int Raum=0, Stunde=0,Minuten=0;
		/*
		48476,	Laufzeit
		74,		Vorlauf
		74,		Ruecklauf
		57,		aussen
		7,       code
		13,      std
		91,      min+64
		0,
		38       innen+20
		*/
		//float tempZeit=0;
		int tempZeit=0;
		
		//NSString* tabSeparator=@"\t";
		//NSString* crSeparator=@"\r";
		
		//		NSMutableString* tempWertString=(NSMutableString*)[TemperaturWertFeld string];//Vorhandene Daten im Wertfeld
		//NSLog(@"TemperaturZeilenString: %@",TemperaturZeilenString);
		
		//		NSArray* TemperaturKanalArray=	[NSArray arrayWithObjects:@"1",@"1",@"1",@"0" ,@"0",@"0",@"0",@"1",nil];
		//		NSArray* BrennerKanalArray=		[NSArray arrayWithObjects:@"1",@"1",@"1",@"1" ,@"0",@"0",@"0",@"0",nil];
		
		// Mark des Datenpaketes:	0: Schluss, Null-Werte	1: Gueltige Daten
		//NSLog(@"mark: %d",mark);
		
		
		
		//tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
		
		// 6.2.10	
		
		tempZeit=[[HomeDatenArray objectAtIndex:0]intValue]- firstZeit;
		LastLoadzeit=tempZeit;
		[LastDataFeld setStringValue:[HomeDatenArray objectAtIndex:0]];
		
		//NSLog(@"LastDatenaktion tempZeit: %d ",tempZeit);
		
		
		if ([HomeDatenArray count]>=9)
		{
			
			AnzDaten++;
			//errString =[NSString stringWithFormat:@"%@\rAnzDaten: %d AllOK DatenpaketArray: %@",errString,AnzDaten,[DatenpaketArray description]];
			//[errString retain];
			
			
			[AnzahlDatenFeld setIntValue:AnzDaten];
         
  //       [[HomeDatenArray objectAtIndex:9]intValue] =  [[HomeDatenArray objectAtIndex:9]intValue]/16;
         
			//NSLog(@"DatenpaketArray: %@" ,[DatenpaketArray description]);
			//NSLog(@"HeizungKanalArray: %@" ,[HeizungKanalArray description]);
			[TemperaturMKDiagramm setWerteArray:HomeDatenArray mitKanalArray:HeizungKanalArray];
			[TemperaturMKDiagramm setNeedsDisplay:YES];
			
			NSMutableDictionary* tempVorgabenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
			
			[tempVorgabenDic setObject:[NSNumber numberWithInt:5]forKey:@"anzbalken"];
			[tempVorgabenDic setObject:[NSNumber numberWithInt:3]forKey:@"datenindex"];
			
			//NSLog(@"LastDatenAktion HomeDatenArray: %@",[HomeDatenArray description]);
			[BrennerDiagramm setWerteArray:HomeDatenArray mitKanalArray:BrennerKanalArray mitVorgabenDic:tempVorgabenDic];
			
			//			[BrennerDiagramm setWerteArray:HomeDatenArray mitKanalArray:BrennerKanalArray];
			[BrennerDiagramm setNeedsDisplay:YES];
			[Gitterlinien setWerteArray:HomeDatenArray mitKanalArray:BrennerKanalArray];
			[Gitterlinien setNeedsDisplay:YES];
			//NSLog(@"LastDatenAktion HomeDatenArray: %@",[HomeDatenArray description]);
			
			/*
			 int i;
			 UInt8*	buffer;
			 buffer = malloc ([DatenpaketArray count]);
			 buffer[0]=[[DatenpaketArray objectAtIndex:0]intValue];
			 int min=[[DatenpaketArray objectAtIndex:0]floatValue]*100;
			 buffer[1]= min%100;
			 for (i=2;i<[DatenpaketArray count];i++)
			 {
			 buffer[i]=[[DatenpaketArray objectAtIndex:i]intValue];
			 }
			 NSData* SerieData=[NSData dataWithBytes:buffer length:SerieSize];
			 
			 //NSLog(@"Data aus buffer: %@",[SerieData description]);
			 free (buffer);
			 
			 UInt8*	controlbuffer;
			 controlbuffer = malloc ([DatenpaketArray count]);
			 [SerieData getBytes:controlbuffer];
			 for (i=0;i<[DatenpaketArray count];i++)
			 {
			 //NSLog(@"controlbuffer i: %d Data: %d",i,controlbuffer[i]);
			 }
			 free(controlbuffer);
			 */
			
			AnzReports=0;
			ReportErrIndex=-1;
			NSRange r=NSMakeRange(1,[HomeDatenArray count]-1); // Erster Wert ist Abszisse
			NSString* TemperaturwerteString=[[HomeDatenArray subarrayWithRange:r] componentsJoinedByString:@"\t"];
			
			[LaufzeitFeld setStringValue:[self stringAusZeit:tempZeit]]; 
			//NSString* tempWertFeldString=[NSString stringWithFormat:@"\t%2.2f\t%@",tempZeit,TemperaturwerteString];
			NSString* tempWertFeldString=[NSString stringWithFormat:@"\t%d\t%@",tempZeit,TemperaturwerteString];
			//[TemperaturWertFeld setString:tempWertFeldString];
			
			NSString* TemperaturDatenString=[NSString stringWithFormat:@"%@\r%@",[TemperaturDatenFeld string],tempWertFeldString];
			
			[TemperaturDatenFeld setString:TemperaturDatenString];
			
			//[DruckDatenView setString:TemperaturDatenString];
			NSRange insertAtEnd=NSMakeRange([[TemperaturDatenFeld textStorage] length],0);
			[TemperaturDatenFeld scrollRangeToVisible:insertAtEnd];
			
			//[TemperaturWertFeld setStringValue:[TemperaturZeilenString copy]];
			//NSLog(@"TemperaturDatenString: %@",TemperaturDatenString);
			//					Origin des vorhandenen DocumentViews
			//					NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
			
			//					Frame des vorhandenen DocumentViews
			//					NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
			
			//					Abszisse der Anzeige
			tempZeit*= ZeitKompression; // fuer Anzeige
			
			//NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
			//NSLog(@"HomeDatenAktion tempFrame.size.width: %2.2f tempZeit: %2.2f",tempFrame.size.width,tempZeit);
			
			float rest=tempFrame.size.width-(float)tempZeit;
			
			
			if ((rest<120)&& (!IOW_busy))
			{
				//NSLog(@"rest zu klein: %2.2f",rest);
				//NSLog(@"tempOrigin alt  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
				//NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
				
				//		Verschiebedistanz des angezeigten Fensters
				float delta=[[TemperaturDiagrammScroller contentView]frame].size.width-150;
				NSPoint scrollPoint=[[TemperaturDiagrammScroller documentView]bounds].origin;
				
				//						DocumentView vergroessern
				tempFrame.size.width+=delta;
				
				//						Origin des DocumentView verschieben
				tempOrigin.x-=delta;
				
				//						Origin der Bounds verschieben
				scrollPoint.x += delta;
				
				//NSLog(@"tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
				//NSLog(@"tempFrame: neu x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
				
				NSRect MKDiagrammRect=[TemperaturMKDiagramm frame];
				MKDiagrammRect.size.width=tempFrame.size.width;
				[TemperaturMKDiagramm setFrame:MKDiagrammRect];
				
				NSRect BrennerRect=[BrennerDiagramm frame];
				BrennerRect.size.width=tempFrame.size.width;
				[BrennerDiagramm setFrame:BrennerRect];
				
				NSRect GitterlinienRect=[Gitterlinien frame];
				GitterlinienRect.size.width=tempFrame.size.width;
				[Gitterlinien setFrame:GitterlinienRect];
				
				NSRect DocRect=	[[TemperaturDiagrammScroller documentView]frame];
				DocRect.size.width=tempFrame.size.width;
				
				[[TemperaturDiagrammScroller documentView] setFrame:DocRect];
				[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
				
				[[TemperaturDiagrammScroller contentView] scrollPoint:scrollPoint];
				[TemperaturDiagrammScroller setNeedsDisplay:YES];
				
			}
		}// 7 Daten
		
		
	}// if datenarray
	
}//

#pragma mark Write to Homeserver


- (void)setRouter_IP:(NSString*)dieIP
{
   NSString* IP_String = [NSString stringWithFormat:@"IP_Adresse Router: %@",dieIP];
   [IPFeld setStringValue:IP_String];
}

- (void)setHost_IP:(NSString*)dieIP
{
   NSString* IP_String = [NSString stringWithFormat:@"IP_Adresse Host: %@",dieIP];
   [hostIPFeld setStringValue:IP_String];
}

- (IBAction)reportHostIP:(id)sender
{
   //http://www.binarytides.com/hostname-to-ip-address-c-sockets-linux/
   
   char *findhost = "ruediheimlicher.ch";
   char ip[100];
   struct hostent *he;
   struct in_addr **addr_list;
   int i;
   
   if ( (he = gethostbyname( findhost ) ) == NULL)
   {
      NSLog(@"err");
      // get the host info
      //herror("gethostbyname");
      //return 1;
   }
   
   addr_list = (struct in_addr **) he->h_addr_list;
   
   for(i = 0; addr_list[i] != NULL; i++)
   {
      //Return the first one;
      strcpy(ip , inet_ntoa(*addr_list[i]) );
      //return 0;
   }
   NSLog(@"ip: %s",ip);
  // sprintf("ip: %c\n",ip);
   
   
  /*
   // http://beej.us/guide/bgnet/output/html/multipage/inet_ntopman.html
   struct sockaddr_in sa;
   char ipadresse[INET_ADDRSTRLEN];
   
   // store this IP address in sa:
   //inet_pton(AF_INET, "192.0.2.33", &(sa.sin_addr));
   
   // now get it back and print it
   inet_ntop(AF_INET, &("ruediheimlicher.ch"), ipadresse, INET_ADDRSTRLEN);
   
   printf("ipadresse: %s\n", ipadresse); // prints "192.0.2.33"
   
   //buff = inet_ntoa((host_entry->h_addr_list[0]));
  // printf("buff 2 %s \n",buff);
   char * ipbuf;
   */
   
   // http://stackoverflow.com/questions/6812649/is-there-a-way-to-get-the-ip-address-from-given-url-in-cocoa
   NSString* hostname = @"https://ruediheimlicher.ch";
   NSURL *validURL = [NSURL URLWithString: hostname];
   NSString *host = [validURL host];
   NSString *ipAdress = [[NSHost hostWithName:host]address];
   printf("\n%s IP: %s",[host  UTF8String],[ipAdress  UTF8String]);
   NSString* hostIP_String = [NSString stringWithFormat:@"IP_Adresse Host: %@",ipAdress];

   [hostIPFeld setStringValue: hostIP_String];
   
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   if (ipAdress)
   {
      [NotificationDic setObject:ipAdress forKey:@"hostip"];
   }
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
//   [nc postNotificationName:@"hostIP" object:self userInfo:NotificationDic];

   
}
#pragma mark solar


-(void)SolarDataDownloadAktion:(NSNotification*)note
{
/*
Aufgerufen von rHomeData.
Setzt Feldwerte im Fenster Data.

*/

	//NSLog(@"rData SolarDataDownloadAktion*");
	[SolarLoadMark performClick:NULL];
	
	if ([[note userInfo]objectForKey:@"err"])
	{
	[LastSolarDataFeld setStringValue:[[note userInfo]objectForKey:@"err"]];
	}
/*
	if ([[note userInfo]objectForKey:@"erfolg"])
	{
	[LastSolarDataFeld setStringValue:[[note userInfo]objectForKey:@"erfolg"]];
	}
*/	
if ([[note userInfo]objectForKey:@"lasttimestring"])
	{
		[LastSolarDatazeitFeld setStringValue:[[note userInfo]objectForKey:@"lasttimestring"]];
	}
	else
	{
		[LastSolarDatazeitFeld setStringValue:@"--"];
	}

	anzSolarLoads++;
	[SolarZaehlerFeld setIntValue:anzSolarLoads];
	if (anzSolarLoads > 12)
	{
//		NSBeep();
		[self reload:NULL];
		
	}

	//NSLog(@"anzSolarLoads: %d",anzSolarLoads);
	[LastSolarDataFeld setStringValue:@"***"];

	if ([[note userInfo]objectForKey:@"datastring"])
	{
	NSString* tempString = [[note userInfo]objectForKey:@"datastring"];
   //   NSLog(@"SolarDataDownloadAktion tempString: \n%@",tempString);
	//tempString= [[[[NSNumber numberWithInt:anzSolarLoads]stringValue]stringByAppendingString:@": "]stringByAppendingString:tempString];

	[LastSolarDataFeld setStringValue:tempString];
	}
	else
	{
	[LastSolarDataFeld setStringValue:@"-"];
	[LastSolarDataFeld setStringValue:@"--"];
	[LastSolarDataFeld setStringValue:@"---"];
	[LastSolarDataFeld setStringValue:@"----"];
	[LastSolarDataFeld setStringValue:@"-----"];
	}

/*
	if ([[note userInfo]objectForKey:@"lastdatazeit"])
	{
	int tempLastdataZeit=[[[note userInfo]objectForKey:@"lastdatazeit"] intValue];
	NSLog(@"lastdatazeit: %d * LastLoadzeit: %d",tempLastdataZeit,LastLoadzeit );
	
	int	tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];		
	//[LastDatazeitFeld setStringValue:[[note userInfo]objectForKey:@"lastdatazeit"]];
	[LastDatazeitFeld setIntValue:tempLastdataZeit-LastLoadzeit];
	}
*/
	if ([[note userInfo]objectForKey:@"delta"])
	{
	NSString* deltaString=[NSString stringWithFormat:@"%2.4F",[[[note userInfo]objectForKey:@"delta"]floatValue]];
	[SolarLoadtimeFeld setStringValue:deltaString];
	}

}

- (IBAction)reportSolarClear:(id)sender
{
	NSLog(@"reportSolarClear");
// TODO


	[self clearSolarData];
	NSDate* StartZeit=[NSDate date];
	//[StartZeit setCalendarFormat:@"%d.%m.%y %H:%M"];
	[StartzeitFeld setStringValue:[StartZeit description]];

	[SolarStartzeitFeld setStringValue:@""];

	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"clear"forKey:@"data"];
	SolarDatenserieStartZeit=[NSDate date];
   
	[NotificationDic setObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
//	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
//	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	[StopTaste setEnabled:NO];
	[StartTaste setEnabled:YES];

}

- (void)reportSolarUpdate:(id)sender
{
	NSLog(@"reportSolarUpdate");
	
	[self clearSolarData];
	[SolarStartzeitFeld setStringValue:@""];
	[SolarKalender setDateValue: [NSDate date]];

	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"clear"forKey:@"data"];
	//DatenserieStartZeit=[[NSCalendarDate calendarDate]retain];
	//[NotificationDic setObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"solardatenvonheute" object:NULL userInfo:NotificationDic];
	//[StopTaste setEnabled:NO];
	//[StartTaste setEnabled:YES];
	
}


- (void)ExterneSolarDatenAktion:(NSNotification*)note
{
	Quelle=1;
	if ([[note userInfo]objectForKey:@"startzeit"])
	{
      
      /*
		NSString* StartzeitString = [[note userInfo]objectForKey:@"startzeit"];
		//NSLog(@"ExterneSolarDatenAktion: Startzeit: *%@* StartzeitString: *%@*",[[note userInfo]objectForKey:@"startzeit"],StartzeitString);
      NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
      // @"YYYY-MM-dd\'T\'HH:mm:ssZZZZZ"
      [dateFormat setDateFormat:@"YYYY.MM.dd  HH:mm:ss"];
      
		NSString* Kalenderformat=[[NSCalendarDate calendarDate]calendarFormat];
		SolarDatenserieStartZeit=[NSCalendarDate dateWithString:[[note userInfo]objectForKey:@"startzeit"] calendarFormat:Kalenderformat];
*/
      // Datenseriestartzeit fuer ausgewaehltes Datum anpassen
      NSString* datumstring = [[note userInfo]objectForKey:@"startzeit"];
      NSMutableArray * startzeitarray = (NSMutableArray *)[datumstring componentsSeparatedByString:@" "];
      if ([[startzeitarray objectAtIndex:0] length ]== 0)
      {
         [startzeitarray removeObjectAtIndex:0];
      }
      //NSString* datumteil = [[datumstring componentsSeparatedByString:@" "]objectAtIndex:0];
      NSString* datumteil = [startzeitarray objectAtIndex:0];
      //NSString* zeitteil = [[datumstring componentsSeparatedByString:@" "]objectAtIndex:1];
      NSString* zeitteil = [startzeitarray objectAtIndex:1];
      int jr = [[[datumteil componentsSeparatedByString:@"-"]objectAtIndex:0]intValue];
      int mon = [[[datumteil componentsSeparatedByString:@"-"]objectAtIndex:1]intValue];
      int tg = [[[datumteil componentsSeparatedByString:@"-"]objectAtIndex:2] intValue];
      
      //SolarDatenserieStartZeit = [self DatumvonJahr:jr Monat:mon Tag: tg];
      SolarDatenserieStartZeit = [self DateVonString:datumstring];
      NSLog(@"ExterneSolarDatenAktion: SolarDatenserieStartZeit: %@",SolarDatenserieStartZeit);

      //long tag = [[NSCalendar currentCalendar] component:NSCalendarUnitDay  fromDate:SolarDatenserieStartZeit];
		//long tag=[SolarDatenserieStartZeit dayOfMonth];
      
      NSDateComponents *heutecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:SolarDatenserieStartZeit];
      
      NSInteger tagdesmonats = [heutecomponents day];
      NSInteger monat = [heutecomponents month];
      NSInteger jahr = [heutecomponents year];
      NSInteger stunde = [heutecomponents hour];
      NSInteger minute = [heutecomponents minute];
      NSInteger sekunde = [heutecomponents second];
      jahr-=2000;
      //NSString* StartZeit = [NSString stringWithFormat:@"%02ld.%02ld.%02ld",(long)tagdesmonats,(long)monat,(long)jahr];
      NSString* StartZeitString = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld",(long)tagdesmonats,(long)monat,(long)jahr,(long)stunde,(long)minute];
		
		NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[NotificationDic setObject:@"datastart"forKey:@"data"];
		[NotificationDic setObject:SolarDatenserieStartZeit forKey:@"datenseriestartzeit"];
		
      
      NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
      //[dateformat setDateFormat:@"%d.%m.%y %H:%M"];
      dateformat.dateStyle = NSDateFormatterLongStyle;
      dateformat.timeStyle = NSDateFormatterMediumStyle;
      
      
      //NSString *AnzeigeString  = [dateformat stringFromDate:SolarDatenserieStartZeit];
      [SolarStartzeitFeld setStringValue:StartZeitString];
		//NSCalendarDate* AnzeigeDatum= [SolarDatenserieStartZeit copy];
//		[AnzeigeDatum setCalendarFormat:@"%d.%m.%y %H:%M"];
		
     // [SolarStartzeitFeld setStringValue:[AnzeigeDatum description]];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		
		[nc postNotificationName:@"data" object:NotificationDic userInfo:NotificationDic];
		
		//NSLog(@"ExterneSolarDatenAktion DatenserieStartZeit: %@ tag: %d",  [SolarDatenserieStartZeit description], tag);
	}
	
	if ([[note userInfo]objectForKey:@"datumtag"])
	{
		
	}
	
	
	if ([[note userInfo]objectForKey:@"datenarray"])
	{
      //NSLog(@"ExterneSolarDatenAktion datenarray da");
		NSArray* SolarTemperaturKanalArray=	[NSArray arrayWithObjects:@"1",@"1",@"1",@"1" ,@"1",@"1",@"0",@"0",nil];
      
      //                                  [NSArray arrayWithObjects:@"0",@"1",@"1",@"1" ,@"0",@"0",@"0",@"0",nil]];

		NSArray* EinschaltKanalArray=		[NSArray arrayWithObjects:@"1",@"1",@"0",@"0" ,@"0",@"0",@"0",@"0",nil];
		
		NSArray* tempDatenArray = [[note userInfo]objectForKey:@"datenarray"];
		//NSLog(@"ExterneSolarDatenAktion tempDatenArray last Data:%@",[[tempDatenArray lastObject]description]);
		
		NSArray* tempZeilenArray= (NSArray*)[[tempDatenArray lastObject] componentsSeparatedByString:@"\r"];
      //NSLog(@"tempZeilenArray: \n%@",[tempZeilenArray description]);
		NSString* tempWertString;
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:1]intValue]/2.0];
		[KollektorVorlaufFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:2]intValue]/2.0];
		[KollektorRuecklaufFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:3]intValue]/2.0];
		[BoileruntenFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:4]intValue]/2.0];
		[BoilermitteFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:5]intValue]/2.0];
		[BoilerobenFeld setStringValue:tempWertString];
		
//		tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:6]intValue]/2.0];
// 170818 Korr Kollektortemp aus in solar.pl korrigiertem Wert(kein /2 mehr)
      tempWertString=[NSString stringWithFormat:@"%2.1f",[[tempZeilenArray objectAtIndex:6]intValue]];
      
		[KollektorTemperaturFeld setStringValue:tempWertString];

      
      
      int tempTemperatur = [[tempZeilenArray objectAtIndex:6]intValue];
      /*
      if ([[tempZeilenArray objectAtIndex:7]intValue]&0x01)
      {
         tempTemperatur += 255;
      }
      */
      
      //      tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:6]intValue]/2.0];
//      tempWertString=[NSString stringWithFormat:@"%2.1f",tempTemperatur/2.0];

      // 170818 Korr Kollektortemp aus in solar.pl korrigiertem Wert(kein /2 mehr)
      tempWertString=[NSString stringWithFormat:@"%2.1f",tempTemperatur];
      
      NSLog(@"externeSolarDatenAktion tempWertString: %@",tempWertString);
      
		// Zeit des ersten Datensatzes
		int firstZeit = [[[[tempDatenArray objectAtIndex:0] componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue];
		NSLog(@"ExterneSolarDatenAktion firstZeit: %d",firstZeit);
		
		// Zeit des letzten Datensatzes
		int lastZeit = [[[[tempDatenArray lastObject] componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue];
		//NSLog(@"ExterneSolarDatenAktion lastZeit: %d tempWertString: %@",lastZeit,tempWertString);
		[SolarLaufzeitFeld setStringValue:[self stringAusZeit:lastZeit]]; 
		
		// Breite des DocumentViews bestimmen
		//		lastZeit -= firstZeit;
		lastZeit *= SolarZeitKompression;
		//NSLog(@"ExterneSolarDatenAktion Zeitkompression: %2f2",SolarZeitKompression);
		//	Origin des vorhandenen DocumentViews
		NSPoint tempOrigin=[[SolarDiagrammScroller documentView] frame].origin;
		//NSLog(@"ExterneSolarDatenAktion tempOrigin: x: %2.2f y: %2.2f",tempOrigin.x, tempOrigin.y);
		//28.7.09
		tempOrigin.x=0;
		[[SolarDiagrammScroller documentView] setFrameOrigin:tempOrigin];
		
		
		//	Frame des vorhandenen DocumentViews
		NSRect tempFrame=[[SolarDiagrammScroller documentView] frame];
		//NSLog(@"ExterneSolarDatenAktion  tempOrigin: x: %2.2f  tempFrame width: x: %2.2f lastZeit: %d",tempOrigin.x,tempFrame.size.width, lastZeit);
		
		//	Verschiebedistanz des angezeigten Fensters
		
		if (tempFrame.size.width < lastZeit) // Anzeige hat nicht Platz
		{
			//NSLog(@"Anzeige hat nicht Platz:  width: %2.2f lastZeit: %d",tempFrame.size.width,lastZeit);
			//float delta=[[TemperaturDiagrammScroller contentView]frame].size.width-150;
			int PlatzRechts = 80;
			float delta=lastZeit- [[SolarDiagrammScroller documentView]bounds].size.width+PlatzRechts; // Abstand vom rechten Rand, Platz fuer Datentitel und Wert
			NSPoint scrollPoint=[[SolarDiagrammScroller documentView]bounds].origin;
			//NSLog(@"delta: %2.2f",delta);
			//	DocumentView vergroessern
			tempFrame.size.width+=delta;
			
			//	Origin des DocumentView verschieben
			//NSLog(@"tempOrigin.x vor: %2.2f",tempOrigin.x);
			tempOrigin.x-=delta;
			//NSLog(@"tempOrigin.x nach: %2.2f",tempOrigin.x);
			
			//	Origin der Bounds verschieben
			//NSLog(@"scrollPoint.x vor: %2.2f",scrollPoint.x);
			scrollPoint.x += delta;
			//NSLog(@"scrollPoint.x nach: %2.2f",scrollPoint.x);
			
			//NSLog(@"tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			//NSLog(@"tempFrame: neu x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
			
			
			NSRect MKDiagrammRect=[SolarDiagramm frame];
			MKDiagrammRect.size.width=tempFrame.size.width;
			
			//NSLog(@"MKDiagrammRect.size.width: %2.2f",MKDiagrammRect.size.width);
			[SolarDiagramm setFrame:MKDiagrammRect];
			
			
			NSRect EinschaltRect=[SolarEinschaltDiagramm frame];
			EinschaltRect.size.width=tempFrame.size.width;
			//NSLog(@"EinschaltRect.size.width: %2.2f",EinschaltRect.size.width);
			
			[SolarEinschaltDiagramm setFrame:EinschaltRect];
			
			
			NSRect GitterlinienRect=[SolarGitterlinien frame];
			GitterlinienRect.size.width=tempFrame.size.width;
			//NSLog(@"GitterlinienRect.size.width: %2.2f",GitterlinienRect.size.width);
			
			[SolarGitterlinien setFrame:GitterlinienRect];
			
			NSRect DocRect=[[SolarDiagrammScroller documentView]frame];
			//NSLog(@"DocRect.size.width vor: %2.2f",DocRect.size.width);
			DocRect.size.width=tempFrame.size.width;
			//NSLog(@"DocRect.size.width nach: %2.2f",DocRect.size.width);
			
			[[SolarDiagrammScroller documentView] setFrame:DocRect];
			//NSLog(@"tempOrigin end  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			[[SolarDiagrammScroller documentView] setFrameOrigin:tempOrigin];
			
			//NSLog(@"ExterneSolarDatenAktion  tempOrigin: x: %2.2f  *   DocRect width: %2.2f",tempOrigin.x,DocRect.size.width);
			
			//NSLog(@"scrollPoint end  x: %2.2f y: %2.2f",scrollPoint.x,scrollPoint.y);
			[[SolarDiagrammScroller contentView] scrollPoint:scrollPoint];
			[SolarDiagrammScroller setNeedsDisplay:YES];
		}
		
		NSMutableDictionary* tempVorgabenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
		
		/*
		 derVorgabenDic enthaelt:
		 - anzahl der Balken, die darzustellen sind. key: anzbalken
		 - Index des Wertes im Werterray, der darzustellen ist (nur Daten, erster Wert ist Abszisse. Zaheler beginnt bei Obj 1 mit Index 0)
		 */
		
		[tempVorgabenDic setObject:[NSNumber numberWithInt:4]forKey:@"anzbalken"];
		[tempVorgabenDic setObject:[NSNumber numberWithInt:6]forKey:@"datenindex"];
		
		
		NSString* TemperaturDatenString= [NSString string];
		NSEnumerator* DatenEnum = [tempDatenArray objectEnumerator];
		id einDatenString;
		//NSLog(@"ExterneSolarDatenAktion begin while");
		long lastzeit=0;
		while (einDatenString = [DatenEnum nextObject])
      {
         //NSMutableArray* tempZeilenArray= (NSMutableArray*)[einDatenString componentsSeparatedByString:@"\t"];
         // Datenstring aufteilen in Komponenten
         NSMutableArray* tempZeilenArray= (NSMutableArray*)[einDatenString componentsSeparatedByString:@"\r"];
         
         //NSLog(@"ExterneSolarDatenAktion einDatenString: %@\n tempZeilenArray:%@\n", einDatenString,[tempZeilenArray description]);
         //NSLog(@"ExterneSolarDatenAktion einDatenString: %@ count: %d", einDatenString, [tempZeilenArray count]);
         if ([tempZeilenArray count]== 9) // Daten vollständig
         {
            //NSLog(@"ExterneSolarDatenAktion tempZeilenArray:%@",[tempZeilenArray description]);
            // Datenserie auf Startzeit synchronisieren
            int tempZeit=[[tempZeilenArray objectAtIndex:0]intValue];
            
            if (tempZeit-lastzeit >30) // nicht alle Daten laden
            {
               lastzeit=tempZeit;
               //tempZeit*= SolarZeitKompression;
               //tempZeit -= firstZeit;
               [tempZeilenArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:tempZeit]];
               
               int kollektortemperatur =[[tempZeilenArray objectAtIndex:6]intValue];
               int kollektorcode =[[tempZeilenArray objectAtIndex:7]intValue];
               
               //  [tempZeilenArray replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:kollektortemperatur]];
               
               /*
                if (kollektorcode & 0x01)
                {
                kollektortemperatur += 255;
                [tempZeilenArray replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:kollektortemperatur]];
                }
                */
               //NSLog(@"ExterneSolarDatenAktion kollektortemperatur: %d \ntempZeilenArray\n%@",kollektortemperatur,tempZeilenArray);
               
               
               [SolarDiagramm setWerteArray:tempZeilenArray mitKanalArray:SolarTemperaturKanalArray ];
               
               
               /*
                NSMutableDictionary* tempVorgabenDic = [[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
                [tempVorgabenDic setObject:[NSNumber numberWithInt:5]forKey:@"anzbalken"];
                [tempVorgabenDic setObject:[NSNumber numberWithInt:3]forKey:@"datenindex"];
                */		
               [SolarGitterlinien setWerteArray:tempZeilenArray mitKanalArray:EinschaltKanalArray];
               
               [SolarEinschaltDiagramm setWerteArray:tempZeilenArray mitKanalArray:EinschaltKanalArray  mitVorgabenDic:tempVorgabenDic];
               
               // Aus TempZeilenarray einen tab-getrennten String bilden
               NSString* tempZeilenString=[tempZeilenArray componentsJoinedByString:@"\t"];
               //				NSLog(@"tempZeilenString: %@", tempZeilenString);
               TemperaturDatenString=[NSString stringWithFormat:@"%@\r\t%@",TemperaturDatenString,tempZeilenString];
               //				TemperaturDatenString=[NSString stringWithFormat:@"%@\r\t%@",TemperaturDatenString,einDatenString];
            }	// if Zeitabstand genuegend gross
         }// Daten vollständig
         
      }	// while
		//NSLog(@"ExterneSolarDatenAktion end while");
		
		[SolarDiagramm setNeedsDisplay:YES];
		[SolarGitterlinien setNeedsDisplay:YES];
		[SolarEinschaltDiagramm setNeedsDisplay:YES];
		
		AnzSolarDaten=[tempDatenArray count];
		//NSLog(@"ExterneSolardatenaktion AnzSolarDaten: %d",AnzSolarDaten);
		[AnzahlSolarDatenFeld setIntValue:[tempDatenArray count]];
		
		[SolarDatenFeld setString:TemperaturDatenString];
		NSRange insertAtEnd=NSMakeRange([[SolarDatenFeld textStorage] length],0);
		[SolarDatenFeld scrollRangeToVisible:insertAtEnd];
		
		[ClearTaste setEnabled:YES];
		
		// 14.4.10 Doppeltes Laden verhindern.
		NSTimer* SolarKalenderTimer=[NSTimer scheduledTimerWithTimeInterval:1
																			  target:self 
																			selector:@selector(SolarKalenderFunktion:) 
																			userInfo:nil 
																			 repeats:NO];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:SolarKalenderTimer forMode:NSDefaultRunLoopMode];
		
		//SolarKalenderblocker=0;
		
	}
   else
   {
      NSLog(@"ExterneSolarDatenAktion kein datenarray da");
   }
	//NSBeep();
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"loadsolardataok"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
//	[nc postNotificationName:@"LoadData" object:self userInfo:NotificationDic];
	[SolarKalender setEnabled:YES];
	
	NSMutableDictionary* BalkendatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[BalkendatenDic setObject:[NSNumber numberWithInt:1]forKey:@"aktion"];
	
	//NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	//	[nc postNotificationName:@"StatistikDaten" object:NULL userInfo:BalkendatenDic];
	//[TemperaturStatistikDiagramm setNeedsDisplay:YES];
	[TagGitterlinien setNeedsDisplay:YES];
	//NSLog(@"ExterneDatenAktion end");
	
	
}

- (void)SolarKalenderFunktion:(NSTimer*)derTimer
{
	SolarKalenderblocker=0;
}

- (void)setSolarKalenderBlocker:(int)derStatus
{
	SolarKalenderblocker=derStatus;
}


- (void)LastSolarDatenAktion:(NSNotification*)note
{
   /*
   NSDate *currentDate = [NSDate date];
   NSCalendar* calendar = [NSCalendar currentCalendar];
   NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate]; // Get necessary date components
   
   long monat = [components month]; //gives you month
   long tag = [components day]; //gives you day
   long jahr = [components year]; // gives you year
   
   NSLog(@"tag: %ld monat: %ld jahr: %ld",tag,monat,jahr);
*/
	int firstZeit=0;
   
	if (Kalenderblocker)
	{
		//NSLog(@"LastSolarDatenAktion	Kalenderblocker");
		return;
	}
	
	NSMutableArray* StartDatenArray=(NSMutableArray*)[[SolarDatenFeld string]componentsSeparatedByString:@"\r"];
	if ([StartDatenArray count])
   {
      if (([[StartDatenArray objectAtIndex:0]length]==0))
      {
         [StartDatenArray removeObjectAtIndex:0];
      }
      //NSString* StartDatenString=[[[SolarDatenFeld string]componentsSeparatedByString:@"\r"]objectAtIndex:1];
      NSString* StartDatenString=[StartDatenArray objectAtIndex:0];
      NSLog(@"LastSolarDatenAktion StartDatenString: %@",StartDatenString);
      //NSString* Kalenderformat=[[NSCalendarDate calendarDate]calendarFormat];
      //NSLog(@"LastSolarDatenaktion note: %@",[[note userInfo]description]);
      if ([[note userInfo]objectForKey:@"startzeit"])
      {
         //SolarDatenserieStartZeit=[NSCalendarDate dateWithString:[[note userInfo]objectForKey:@"startzeit"] calendarFormat:Kalenderformat];
         SolarDatenserieStartZeit= [self DateVonString:[[note userInfo]objectForKey:@"startzeit"] ];
      }
      
      
      
      //int firsttag=[SolarDatenserieStartZeit dayOfMonth];
      
      if (StartDatenString && [StartDatenString length])
      {
         // Zeit des ersten Datensatzes
         NSArray*StartDatenArray = [StartDatenString componentsSeparatedByString:@"\t"];
         firstZeit = [[[StartDatenString componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue];
         NSLog(@"LastSolarDatenAktion firstZeit: %d",firstZeit);
      }
   }
	
	if ([[note userInfo]objectForKey:@"lastdatazeit"])
	{
		//	[LastDataFeld setStringValue:[[note userInfo]objectForKey:@"lastdatazeit"]];
	}
	anzSolarLoads=0;
	[SolarZaehlerFeld setIntValue:anzSolarLoads];
	NSNumberFormatter *numberFormatter =[[NSNumberFormatter alloc] init];
	// specify just positive format
	[numberFormatter setFormat:@"##0.00"];
	
	//	[LoadMark  performClick:NULL];
	
	//NSLog(@"LastSolarDatenAktion note: %@",[[note userInfo]description]);
	   /*
		 lastdatenarray =     (
        48849,	Laufzeit
        47,		Kollektor Vorlauf
        46,		Kollektor Ruecklauf
        40,		Boiler unten
        128,	Boiler mitte
        136,	Boiler oben
        82,		Kollektortemperatur
        0,
        255
			);
			Alle Temperaturerte doppelt
	 */
	NSString* tempWertString;
	
	NSPoint tempOrigin=[[SolarDiagrammScroller documentView] frame].origin;
	NSRect tempFrame=[[SolarDiagrammScroller documentView] frame];
	
	if ([[note userInfo]objectForKey:@"lastdatenarray"])
	{
		NSMutableArray* lastDatenArray=(NSMutableArray*)[[note userInfo]objectForKey:@"lastdatenarray"];
      //NSLog(@"LastSolarDatenAktion lastDatenArray: %@",lastDatenArray);
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:1]intValue]/2.0];
		[KollektorVorlaufFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:2]intValue]/2.0];
		[KollektorRuecklaufFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:3]intValue]/2.0];
		[BoileruntenFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:4]intValue]/2.0];
		[BoilermitteFeld setStringValue:tempWertString];
		tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:5]intValue]/2.0];
		[BoilerobenFeld setStringValue:tempWertString];
		
      int tempTemperatur = [[lastDatenArray objectAtIndex:6]intValue];
      /*
      if ([[lastDatenArray objectAtIndex:7]intValue]&0x01)
      {
         tempTemperatur += 255;
         [lastDatenArray replaceObjectAtIndex:6 withObject: [NSNumber numberWithInt:tempTemperatur]];
      }
		*/
//      tempWertString=[NSString stringWithFormat:@"%2.1f",[[lastDatenArray objectAtIndex:6]intValue]/2.0];
      tempWertString=[NSString stringWithFormat:@"%2.1f",tempTemperatur];
      //NSLog(@"lastSolarDatenAktion tempWertString: %@",tempWertString);

      [KollektorTemperaturFeld setStringValue:tempWertString];
		
		//		int Raum=0, Stunde=0,Minuten=0;
		
		//float tempZeit=0;
		int tempZeit=0;
		
		//NSString* tabSeparator=@"\t";
		//NSString* crSeparator=@"\r";
		
		//		NSMutableString* tempWertString=(NSMutableString*)[TemperaturWertFeld string];//Vorhandene Daten im Wertfeld
		//NSLog(@"TemperaturZeilenString: %@",TemperaturZeilenString);
		
		
		NSArray* TemperaturKanalArray=	[NSArray arrayWithObjects:@"1",@"1",@"1",@"1",@"1",@"1",@"0",@"0",nil];
		NSArray* StatusKanalArray=		[NSArray arrayWithObjects:@"1",@"1",@"0",@"0" ,@"0",@"0",@"0",@"0",nil];
		
		// Mark des Datenpaketes:	0: Schluss, Null-Werte	1: Gueltige Daten
		//NSLog(@"mark: %d",mark);
		
		
		
		//tempZeit=[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
		
		// 6.2.10	
		
		tempZeit=[[lastDatenArray objectAtIndex:0]intValue];//- firstZeit;
		//tempZeit-= firstZeit;
		LastSolarLoadzeit=tempZeit;
		[LastSolarDataFeld setStringValue:[lastDatenArray objectAtIndex:0]];
		
		//NSLog(@"LastSolarDatenaktion tempZeit: %d ",tempZeit);
		
		
		if ([lastDatenArray count]==9) // richtige Anzahl Daten
		{
			
			AnzSolarDaten++;
			//errString =[NSString stringWithFormat:@"%@\rAnzDaten: %d AllOK DatenpaketArray: %@",errString,AnzSolarDaten,[DatenpaketArray description]];
			//[errString retain];
			
			
			[AnzahlSolarDatenFeld setIntValue:AnzSolarDaten];
			//NSLog(@"DatenpaketArray: %@" ,[DatenpaketArray description]);
			//NSLog(@"LastSolarDatenAktion lastDatenArray: %@" ,[lastDatenArray description]);
			
         //NSLog(@"LastSolarDatenAktion lastDatenArray\n%@",lastDatenArray);

			[SolarDiagramm setWerteArray:lastDatenArray mitKanalArray:TemperaturKanalArray];
			[SolarDiagramm setNeedsDisplay:YES];
			
			NSMutableDictionary* tempVorgabenDic = [[NSMutableDictionary alloc]initWithCapacity:0];
			
			/*
			derVorgabenDic enthaelt:
			- anzahl der Balken, die darzustellen sind. key: anzbalken
			- Index des Wertes im Werterray, der darzustellen ist (nur Daten, erster Wert ist Abszisse. Zaheler beginnt bei Obj 1 mit Index 0)
			*/

			[tempVorgabenDic setObject:[NSNumber numberWithInt:4]forKey:@"anzbalken"];
			[tempVorgabenDic setObject:[NSNumber numberWithInt:6]forKey:@"datenindex"];

         


#pragma mark Simulation
// Simulation
/*
			NSNumber* filler=[NSNumber numberWithInt:1];
			NSNumber* ON=[NSNumber numberWithInt:24];
			NSNumber* OFF=[NSNumber numberWithInt:0];
			NSArray* tempArray;
			//NSArray* tempArray=[NSArray arrayWithObjects:[lastDatenArray objectAtIndex:0], [lastDatenArray objectAtIndex:1],[lastDatenArray objectAtIndex:2],filler,filler,,filler,filler,ON,filler,NULL];
			
			if (([[lastDatenArray objectAtIndex:0]intValue]%100)<50)
			{
			tempArray=[NSArray arrayWithObjects:[lastDatenArray objectAtIndex:0],[lastDatenArray objectAtIndex:1],[lastDatenArray objectAtIndex:2],filler,filler,filler,filler,ON,[lastDatenArray lastObject],NULL];
			}
			else 
			{
			tempArray=[NSArray arrayWithObjects:[lastDatenArray objectAtIndex:0],[lastDatenArray objectAtIndex:1],[lastDatenArray objectAtIndex:2],filler,filler,filler,filler,OFF,[lastDatenArray lastObject],NULL];
			}

			
			//NSLog(@"Sim tempArray: %@",[tempArray description]);
			[SolarEinschaltDiagramm setWerteArray:tempArray mitKanalArray:StatusKanalArray mitVorgabenDic:tempVorgabenDic];
*/			
			
			[SolarEinschaltDiagramm setWerteArray:lastDatenArray mitKanalArray:StatusKanalArray mitVorgabenDic:tempVorgabenDic];
			[SolarEinschaltDiagramm setNeedsDisplay:YES];
			
			
			//			[BrennerDiagramm setWerteArray:HomeDatenArray mitKanalArray:BrennerKanalArray];
			//			[BrennerDiagramm setNeedsDisplay:YES];
			[SolarGitterlinien setWerteArray:lastDatenArray mitKanalArray:StatusKanalArray];
			[SolarGitterlinien setNeedsDisplay:YES];
			//NSLog(@"DatenpaketArray: %@",[HomeDatenArray description]);
			
			AnzReports=0;
			ReportErrIndex=-1;
			NSRange r=NSMakeRange(1,[lastDatenArray count]-1); // Erster Wert ist Abszisse
			NSString* TemperaturwerteString=[[lastDatenArray subarrayWithRange:r] componentsJoinedByString:@"\t"];
			
			[SolarLaufzeitFeld setStringValue:[self stringAusZeit:tempZeit]]; 
			//NSString* tempWertFeldString=[NSString stringWithFormat:@"\t%2.2f\t%@",tempZeit,TemperaturwerteString];
			NSString* tempWertFeldString=[NSString stringWithFormat:@"\t%d\t%@",tempZeit,TemperaturwerteString];
			//[TemperaturWertFeld setString:tempWertFeldString];
			
			NSString* TemperaturDatenString=[NSString stringWithFormat:@"%@\r%@",[SolarDatenFeld string],tempWertFeldString];
			
			[SolarDatenFeld setString:TemperaturDatenString];
			
			//[DruckDatenView setString:TemperaturDatenString];
			NSRange insertAtEnd=NSMakeRange([[SolarDatenFeld textStorage] length],0);
			[SolarDatenFeld scrollRangeToVisible:insertAtEnd];
			
			//[TemperaturWertFeld setStringValue:[TemperaturZeilenString copy]];
			//NSLog(@"TemperaturDatenString: %@",TemperaturDatenString);
			//					Origin des vorhandenen DocumentViews
			//					NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
			
			//					Frame des vorhandenen DocumentViews
			//					NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
			
			//					Abszisse der Anzeige
			tempZeit*= SolarZeitKompression; // fuer Anzeige
			
			//NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
			//NSLog(@"SolarDatenAktion tempFrame.size.width: %2.2f   tempZeit: %d",tempFrame.size.width,tempZeit);
			//NSLog(@"SolarDatenAktion tempOrigin alt  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			float rest=tempFrame.size.width-(float)tempZeit; // tempframe von documentView
			//NSLog(@"SolarDatenAktion rest: %2.2f",rest);
			
			//if ((rest<120)&& (!IOW_busy))
			if ((rest<160)) // Platz wird knapp oder neue tempZeit ist groesser als bestehender tempFrame
			{
				//NSLog(@"Solar rest zu klein: %2.2f",rest);
				//NSLog(@"tempOrigin alt  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
				//NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
				
				//						Verschiebedistanz des angezeigten Fensters
				
				float delta=0;
				if (rest && (rest<160))
				{
					delta=[[SolarDiagrammScroller contentView]frame].size.width-120;
				}
				else 
				{
					delta=[[SolarDiagrammScroller contentView]frame].size.width-rest-120;
				}

				//NSLog(@"SolarDatenAktion rest zu klein    rest: %2.2f  delta: %2.2f",rest, delta);
				NSPoint scrollPoint=[[SolarDiagrammScroller documentView]bounds].origin;
				
				//	DocumentView vergroessern
				tempFrame.size.width+=delta;
				
				//	Origin des DocumentView verschieben
				tempOrigin.x-=delta;
				
				//	Origin der Bounds verschieben
				scrollPoint.x += delta;
				
				//NSLog(@"SolarDatenAktion tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
				//NSLog(@"SolarDatenAktion tempFrame: neu x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
				
				NSRect MKDiagrammRect=[SolarDiagramm frame];
				MKDiagrammRect.size.width=tempFrame.size.width;
				[SolarDiagramm setFrame:MKDiagrammRect];
				
				NSRect SolarEinschaltRect=[SolarEinschaltDiagramm frame];
				SolarEinschaltRect.size.width=tempFrame.size.width;
				[SolarEinschaltDiagramm setFrame:SolarEinschaltRect];
				
				NSRect GitterlinienRect=[Gitterlinien frame];
				GitterlinienRect.size.width=tempFrame.size.width;
				[SolarGitterlinien setFrame:GitterlinienRect];
				
				NSRect DocRect=	[[SolarDiagrammScroller documentView]frame];
				DocRect.size.width=tempFrame.size.width;
				
				[[SolarDiagrammScroller documentView] setFrame:DocRect];
				[[SolarDiagrammScroller documentView] setFrameOrigin:tempOrigin];
				
				
				[[SolarDiagrammScroller contentView] scrollPoint:scrollPoint];
				[SolarDiagrammScroller setNeedsDisplay:YES];
				
			}
		}// 7 Daten
		
		
	}// if dataenarray
	
}




- (void)clearSolarData
{
	NSLog(@"clearSolarData");
	[SolarDatenFeld setString:[NSString string]];
	AnzDaten=0;
	SolarDatenserieStartZeit=[NSDate date];
	//NSDictionary* DatumDic=[NSDictionary dictionaryWithObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
	
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"datastart"forKey:@"data"];
	[NotificationDic setObject:SolarDatenserieStartZeit forKey:@"datenseriestartzeit"];
	
//	NSCalendarDate* AnzeigeDatum= [SolarDatenserieStartZeit copy];
   NSString* startzeitstring = [SolarDatenserieStartZeit description];
   NSLog(@"startzeitstring: %@",startzeitstring);
    
// 2020-06-29 15:25:27 +0000
   NSArray* zeitstringarray = [startzeitstring componentsSeparatedByString:@" "];
   NSArray* datumarray = [[zeitstringarray objectAtIndex:0]componentsSeparatedByString:@"-"];
   
   NSString* AnzeigeDatum = [NSString stringWithFormat:@"%@.%@.%@ %@",[datumarray objectAtIndex:2],[datumarray objectAtIndex:1],[datumarray objectAtIndex:0],[zeitstringarray objectAtIndex:1]];
   NSLog(@"AnzeigeDatum: %@",AnzeigeDatum);
	[StartzeitFeld setStringValue:[AnzeigeDatum description]];
	
   
   
   [AnzahlSolarDatenFeld setStringValue:@""];
	[LastSolarDataFeld setStringValue:@""];
	[LastSolarDatazeitFeld setStringValue:@""];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	
	//par=0;
	
	if (DatenpaketArray && [DatenpaketArray count])
	{
		[DatenpaketArray removeAllObjects];
	}
	float Feldbreite=[[SolarDiagrammScroller contentView]frame].size.width;
	float x = [[SolarDiagrammScroller contentView]frame].origin.x;
	[SolarDiagramm clean];
	NSRect SolarDiagrammRect=[SolarDiagramm frame];
	SolarDiagrammRect.size.width = Feldbreite;
	SolarDiagrammRect.origin.x=x;
	[SolarDiagramm setFrame:SolarDiagrammRect];
	[SolarDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[SolarDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[SolarDiagramm setGraphFarbe:[NSColor blackColor] forKanal:2];
	[SolarDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
	[SolarDiagramm setStartZeit:DatenserieStartZeit];
	
	[SolarEinschaltDiagramm clean];
	NSRect EinschaltDiagrammRect=[SolarEinschaltDiagramm frame];
	EinschaltDiagrammRect.size.width = Feldbreite;
	EinschaltDiagrammRect.origin.x=x;
	[SolarEinschaltDiagramm setFrame:EinschaltDiagrammRect];
	[SolarEinschaltDiagramm setStartZeit:DatenserieStartZeit];
	
	[SolarGitterlinien clean];
	NSRect GitterlinienRect=[SolarGitterlinien frame];
	GitterlinienRect.size.width = Feldbreite;
	GitterlinienRect.origin.x=x;
	[SolarGitterlinien setFrame:GitterlinienRect];
	[SolarGitterlinien setStartZeit:DatenserieStartZeit];
	
	NSRect DocRect=	[[SolarDiagrammScroller documentView]frame];
	DocRect.size.width=Feldbreite;
	
	
	[[SolarDiagrammScroller documentView] setFrame:DocRect];
	NSPoint tempOrigin=[[SolarDiagrammScroller documentView] frame].origin;
	
	[[SolarDiagrammScroller documentView] setFrameOrigin:tempOrigin];
	
	NSPoint scrollPoint=[[SolarDiagrammScroller documentView]bounds].origin;
	
	[[SolarDiagrammScroller contentView] scrollPoint:scrollPoint];
	[SolarDiagrammScroller setNeedsDisplay:YES];
	
}
#pragma mark end solar

- (void)reportUpdate:(id)sender
{
	NSLog(@"rData reportUpdate");
	
	[self clearData];
	[StartzeitFeld setStringValue:@""];
	[Kalender setDateValue: [NSDate date]];

	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"clear"forKey:@"data"];
	//DatenserieStartZeit=[[NSCalendarDate calendarDate]retain];
	//[NotificationDic setObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"datenvonheute" object:NULL userInfo:NotificationDic];
	//[StopTaste setEnabled:NO];
	//[StartTaste setEnabled:YES];
	
}

- (void)reportSuchen:(id)sender
{
/*
	NSMutableDictionary* NotificationDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
	//[NotificationDic setObject:[[Kalender dateValue]description] forKey:@"datum"];
	[NotificationDic setObject:[SuchDatumFeld stringValue] forKey:@"datum"];
	
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSLog(@"reportSuchen NotificationDic: %@",[NotificationDic description]);
	
	[nc postNotificationName:@"HomeDataKalender" object:self userInfo:NotificationDic];
*/
}


- (void)reportKalender:(id)sender
{	
	if (Kalenderblocker)
	{
		NSLog(@"reportKalender	Kalenderblocker");
		return;
	}
	Kalenderblocker=1;
	NSLog(@"reportKalender	sender: %@",[sender dateValue]);
	NSString* HeuteDatumString = [[[[NSDate date]description]componentsSeparatedByString:@" "]objectAtIndex:0];
	NSString* KalenderDatumString = [[[[sender dateValue]description]componentsSeparatedByString:@" "]objectAtIndex:0];
	//NSLog(@"sender: heute: %@ Kalender: %@",HeuteDatumString, KalenderDatumString);

	if ([HeuteDatumString isEqualToString:KalenderDatumString])
	{
		NSLog(@"reportKalender Datum=heute");
		if (Heuteblocker)
		{
		Heuteblocker=0;
		[self reportUpdate:NULL];
		}
		return;
	}
	Heuteblocker=1;
	//NSLog(@"\n***   reportKalender: Datum: %@",[sender dateValue]);
	NSString* PickDate=[[Kalender dateValue]description];
	//NSLog(@"PickDate: %@",PickDate);
	//NSDate* KalenderDatum=[Kalender dateValue];
	//NSDate* KalenderDatum=[sender dateValue];
	//NSLog(@"Kalenderdatum: %@",KalenderDatum);
	//NSLog(@"reportKalender Suffix: %@",[self DatumSuffixVonDate:[Kalender dateValue]]);
	NSArray* DatumStringArray=[PickDate componentsSeparatedByString:@" "];
	NSLog(@"DatumStringArray: %@",[DatumStringArray description]);
	
	NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
	NSString* SuffixString=[NSString stringWithFormat:@"/HomeDaten/HomeDaten%@%@%@.txt",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
	//NSLog(@"DatumArray: %@",[DatumArray description]);
	//NSLog(@"reportKalender SuffixString: %@",SuffixString);
	//NSLog(@"tag: %d jahr: %d",tag,jahr);
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:SuffixString forKey:@"suffixstring"];
	//[NotificationDic setObject:[[Kalender dateValue]description] forKey:@"datum"];
	[NotificationDic setObject:[[sender dateValue]description] forKey:@"datum"];
	
	//[SuchDatumFeld setStringValue:[[sender dateValue]description]];
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSLog(@"reportKalender NotificationDic: %@",[NotificationDic description]);
	
	[nc postNotificationName:@"HomeDataKalender" object:self userInfo:NotificationDic];
	
}



- (void)reportSolarKalender:(id)sender
{	
	if (SolarKalenderblocker)
	{
		//NSLog(@"reportSolarKalender	Kalenderblocker");
		return;
	}
	SolarKalenderblocker=1;
	NSLog(@"\n***");
	NSLog(@"reportSolarKalender	sender: %@",[sender dateValue]);
	NSString* HeuteDatumString = [[[[NSDate date]description]componentsSeparatedByString:@" "]objectAtIndex:0];
	NSString* KalenderDatumString = [[[[sender dateValue]description]componentsSeparatedByString:@" "]objectAtIndex:0];
	//NSLog(@"sender: %@ heute: %@",HeuteDatumString, KalenderDatumString);

	if ([HeuteDatumString isEqualToString:KalenderDatumString])
	{
		if (SolarHeuteblocker)
		{
		SolarHeuteblocker=0;
		[self reportSolarUpdate:NULL];
		}
		return;
	}
	SolarHeuteblocker=1;
	//NSLog(@"\n***   reportKalender: Datum: %@",[sender dateValue]);
	NSString* PickDate=[[SolarKalender dateValue]description];
	//NSLog(@"PickDate: %@",PickDate);
	//NSDate* KalenderDatum=[Kalender dateValue];
	//NSDate* KalenderDatum=[sender dateValue];
	//NSLog(@"Kalenderdatum: %@",KalenderDatum);
	//NSLog(@"reportKalender Suffix: %@",[self DatumSuffixVonDate:[Kalender dateValue]]);
	NSArray* DatumStringArray=[PickDate componentsSeparatedByString:@" "];
	//NSLog(@"DatumStringArray: %@",[DatumStringArray description]);
	
	NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
	NSString* SuffixString=[NSString stringWithFormat:@"/SolarDaten/SolarDaten%@%@%@.txt",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
	//NSLog(@"DatumArray: %@",[DatumArray description]);
	//NSLog(@"reportSolarKalender SuffixString: %@",SuffixString);
	//NSLog(@"tag: %d jahr: %d",tag,jahr);
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:SuffixString forKey:@"suffixstring"];
	//[NotificationDic setObject:[[Kalender dateValue]description] forKey:@"datum"];
	[NotificationDic setObject:[[sender dateValue]description] forKey:@"datum"];
	
	//[SuchDatumFeld setStringValue:[[sender dateValue]description]];
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	//NSLog(@"reportSolarKalender NotificationDic: %@",[NotificationDic description]);
	
	[nc postNotificationName:@"SolarDataKalender" object:self userInfo:NotificationDic];
	
}

- (NSString*)DatumSuffixVonDate:(NSDate*)dasDatum
{
	NSArray* DatumStringArray=[[dasDatum description]componentsSeparatedByString:@" "];
	//NSLog(@"DatumStringArray: %@",[DatumStringArray description]);
	NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
	NSString* SuffixString=[NSString stringWithFormat:@"%@%@%@",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
	NSLog(@"DatumArray: %@",[DatumArray description]);
	NSLog(@"SuffixString: %@",SuffixString);
	return SuffixString;
}

- (void)setKalenderBlocker:(int)derStatus;
{
	Kalenderblocker=derStatus;
}



- (int)StatistikJahr
{
	int jahr=[[StatistikJahrPop selectedItem]tag];
	return jahr;
}
- (int)StatistikMonat
{
	int monat=[[StatistikMonatPop selectedItem]tag];
	return monat;

}


- (int)SolarStatistikJahr
{
	int jahr=[[SolarStatistikJahrPop selectedItem]tag];
	return jahr;
}

- (int)SolarStatistikMonat
{
	int monat=[[SolarStatistikMonatPop selectedItem]tag];
	return monat;
   
}


- (NSDictionary*)SolarStatistikDatum
{
	NSMutableDictionary* tempDatumDic = [[NSMutableDictionary alloc]initWithCapacity:0];
	
	return tempDatumDic;

}

- (void)reportSolarStatistikKalender:(id)sender
{	
	NSLog(@"\n***");
	NSLog(@"reportSolarStatistikKalender	sender: %@",[sender dateValue]);
	NSString* HeuteDatumString = [[[[NSDate date]description]componentsSeparatedByString:@" "]objectAtIndex:0];
	NSString* KalenderDatumString = [[[[sender dateValue]description]componentsSeparatedByString:@" "]objectAtIndex:0];
	//NSLog(@"sender: %@ heute: %@",HeuteDatumString, KalenderDatumString);

	if ([HeuteDatumString isEqualToString:KalenderDatumString])
	{
		if (SolarHeuteblocker)
		{
		SolarHeuteblocker=0;
		[self reportSolarUpdate:NULL];
		}
		return;
	}
		
	NSArray* DatumArray=[KalenderDatumString componentsSeparatedByString:@"-"];
	//NSString* SuffixString=[NSString stringWithFormat:@"/SolarDaten/SolarDaten%@%@%@.txt",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
	NSLog(@"DatumArray: %@",[DatumArray description]);
	//NSLog(@"reportSolarKalender SuffixString: %@",SuffixString);
	//NSLog(@"tag: %d jahr: %d",tag,jahr);
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:HeuteDatumString forKey:@"heute"];
	[NotificationDic setObject:KalenderDatumString forKey:@"kalenderdatum"];
	[NotificationDic setObject:[DatumArray objectAtIndex:0] forKey:@"kalenderjahr"];
	[NotificationDic setObject:[DatumArray objectAtIndex:1] forKey:@"kalendermonat"];
	[NotificationDic setObject:[DatumArray objectAtIndex:2] forKey:@"kalendertag"];
	//[SuchDatumFeld setStringValue:[[sender dateValue]description]];
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSLog(@"reportSolarStatistikKalender NotificationDic: %@",[NotificationDic description]);
	
	[nc postNotificationName:@"SolarStatistikKalender" object:self userInfo:NotificationDic];
	
}

- (NSTextView*)DruckDatenView
{
   //NSLog(@"Data DruckDatenView");
 //  NSCalendarDate* SaveDatum=[NSCalendarDate date];
  /* 
   int jahr=[SaveDatum yearOfCommonEra];
   NSRange jahrRange=NSMakeRange(2,2);
   NSString* jahrString=[[[NSNumber numberWithInt:jahr]stringValue]substringWithRange:jahrRange];
   int monat=[SaveDatum monthOfYear];
   NSString* monatString;
   if (monat<10)
   {
      monatString=[NSString stringWithFormat:@"0%d",monat];;
   }
   else
   {
      monatString=[NSString stringWithFormat:@"%d",monat];;
   }
   int tag=[SaveDatum dayOfMonth];
   
   NSString* tagString;
   if (tag<10)
   {
      tagString=[NSString stringWithFormat:@"0%d",tag];
   }
   else
   {
      tagString=[NSString stringWithFormat:@"%d",tag];
   }
   
   int stunde=[SaveDatum hourOfDay];
   NSString* stundeString;
   if (stunde<10)
   {
      stundeString=[NSString stringWithFormat:@"0%d",stunde];
   }
   else
   {
      stundeString=[NSString stringWithFormat:@"%d",stunde];
   }
   
   
   int minute=[SaveDatum minuteOfHour];
   NSString* minuteString;
   if (minute<10)
   {
      minuteString=[NSString stringWithFormat:@"0%d",minute];
   }
   else
   {
      minuteString=[NSString stringWithFormat:@"%d",minute];
   }
   */
   NSDateComponents *heutecomponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear |NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:[NSDate date]];
   
   NSInteger tagdesmonats = [heutecomponents day];
   NSInteger monat = [heutecomponents month];
   NSInteger jahr = [heutecomponents year];
   NSInteger stunde = [heutecomponents hour];
   NSInteger minute = [heutecomponents minute];
   NSInteger sekunde = [heutecomponents second];
   jahr-=2000;
   //NSString* StartZeit = [NSString stringWithFormat:@"%02ld.%02ld.%02ld",(long)tagdesmonats,(long)monat,(long)jahr];
   NSString* DatumString = [NSString stringWithFormat:@"%02ld.%02ld.%02ld %02ld:%02ld",(long)tagdesmonats,(long)monat,(long)jahr,(long)stunde,(long)minute];

   
   NSString* TitelString=@"HomeCentral\rFalkenstrasse 20\r8630 Rueti\rDatum: ";
//   NSString* DatumString=[NSString stringWithFormat:@"%@.%@.%@  %@:%@",tagString,monatString,jahrString,stundeString,minuteString];
   NSArray* tempZeilenArray=[[TemperaturDatenFeld string]componentsSeparatedByString:@"\r"];
   NSMutableArray* tempNeuerZeilenArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   //NSLog(@"tempZeilenArray vor: %@",[tempZeilenArray description]);
   if ([tempZeilenArray count]>1)
   {
      NSEnumerator* tabEnum=[tempZeilenArray objectEnumerator];
      id eineZeile;
      while (eineZeile=[tabEnum nextObject])
      {
         //NSLog(@"eineZeile vor: %@",eineZeile);
         if ([eineZeile length]>1)
         {
            [tempNeuerZeilenArray addObject:[eineZeile substringFromIndex:1]];
         }
         //eineZeile=[eineZeile substringFromIndex:1];
         //NSLog(@"eineZeile nach: %@",eineZeile);
      }//while
      //NSLog(@"tempNeuerZeilenArray nach: %@",[tempNeuerZeilenArray description]);
      
      
      //[DatenserieStartZeit setCalendarFormat:@"%d.%m.%y %H:%M"];
      NSString* TemperaturDatenString=[NSString stringWithFormat:@"%@ %@\r\rStartzeit: %@\r%@",TitelString,DatumString,DatenserieStartZeit,[tempNeuerZeilenArray componentsJoinedByString:@"\r"]];
      //NSLog(@"TemperaturDatenString: %@",TemperaturDatenString);
      [DruckDatenView setString:TemperaturDatenString];
   }//if count
   //NSLog(@"Data DruckDatenView end");
   return DruckDatenView;
}

- (int)Datenquelle
{
	return Quelle;
}

- (NSDate*)DatenserieStartZeit
{
	return DatenserieStartZeit;
}

- (void)ErrStringAktion:(NSNotification*)note
{
   if ([[note userInfo]objectForKey:@"err"])
   {
      NSString* tempErrString=[[note userInfo]objectForKey:@"err"];
      NSDate *errdate         = [NSDate date];
      NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
      [dateformat setDateFormat:@"%H:%M"];
      NSString *dateString  = [dateformat stringFromDate:errdate];
      
      errString =[NSString stringWithFormat:@"%@\n%@: %@",errString,dateString,tempErrString];
      
   }
}

- (BOOL)saveErrString
{
	
	//NSLog(@"saveErrString");
	//NSLog(@"saveErrString errPfad: %@",errPfad);
	if (errString)
	{
		//NSLog(@"saveErrString da");
		//NSLog(@"saveErrString errString: %@" ,errString);
		
		BOOL errWriteOK=[errString writeToFile:errPfad atomically:YES];
		
		//NSLog(@"saveErrString errWriteOK: %d",errWriteOK);
		return errWriteOK;
	}
	else
	{
		//NSLog(@"saveErrString kein errString");
	}
	return 0;
}

- (IBAction)reportClearData:(id)sender
{
	NSLog(@"reportClearData");
	[TemperaturDatenFeld setString:[NSString string]];
	
}

- (void)clearData
{
	NSLog(@"clearData");
	[TemperaturDatenFeld setString:[NSString string]];
	AnzDaten=0;
	ErrZuLang=0;
	ErrZuKurz=0;
   
	DatenserieStartZeit=[NSDate date];
	//NSDictionary* DatumDic=[NSDictionary dictionaryWithObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
	
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"datastart"forKey:@"data"];
	[NotificationDic setObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
	
	
   
   NSString* startzeitstring = [DatenserieStartZeit description];
   NSLog(@"startzeitstring: %@",startzeitstring);
   
   // 2020-06-29 15:25:27 +0000
   NSArray* zeitstringarray = [startzeitstring componentsSeparatedByString:@" "];
   NSArray* datumarray = [[zeitstringarray objectAtIndex:0]componentsSeparatedByString:@"-"];
   
   NSString* AnzeigeDatum = [NSString stringWithFormat:@"%@.%@.%@ %@",[datumarray objectAtIndex:2],[datumarray objectAtIndex:1],[datumarray objectAtIndex:0],[zeitstringarray objectAtIndex:1]];
   NSLog(@"AnzeigeDatum: %@",AnzeigeDatum);
   [StartzeitFeld setStringValue:[AnzeigeDatum description]];

   
   [StartzeitFeld setStringValue:AnzeigeDatum ];
	[BrenndauerFeld setStringValue:@"0:00:00"];
	[AnzahlDatenFeld setStringValue:@""];
	//[StartzeitFeld setStringValue:@""];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	
	//par=0;
	
	if (DatenpaketArray && [DatenpaketArray count])
	{
		[DatenpaketArray removeAllObjects];
	}
	float Feldbreite=[[TemperaturDiagrammScroller contentView]frame].size.width;
	float x = [[TemperaturDiagrammScroller contentView]frame].origin.x;
	[TemperaturMKDiagramm clean];
	NSRect TemperaturDiagrammRect=[TemperaturMKDiagramm frame];
	TemperaturDiagrammRect.size.width = Feldbreite;
	TemperaturDiagrammRect.origin.x=x;
	[TemperaturMKDiagramm setFrame:TemperaturDiagrammRect];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor blackColor] forKanal:2];
	[TemperaturMKDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];
	[TemperaturMKDiagramm setStartZeit:DatenserieStartZeit];
	
	[BrennerDiagramm clean];
	NSRect BrennerDiagrammRect=[BrennerDiagramm frame];
	BrennerDiagrammRect.size.width = Feldbreite;
	BrennerDiagrammRect.origin.x=x;
	[BrennerDiagramm setFrame:BrennerDiagrammRect];
	[BrennerDiagramm setStartZeit:DatenserieStartZeit];
	
	[Gitterlinien clean];
	NSRect GitterlinienRect=[Gitterlinien frame];
	GitterlinienRect.size.width = Feldbreite;
	GitterlinienRect.origin.x=x;
	[Gitterlinien setFrame:GitterlinienRect];
	[Gitterlinien setStartZeit:DatenserieStartZeit];
	
	NSRect DocRect=	[[TemperaturDiagrammScroller documentView]frame];
	DocRect.size.width=Feldbreite;
	
	
	[[TemperaturDiagrammScroller documentView] setFrame:DocRect];
	NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
	
	[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
	
	NSPoint scrollPoint=[[TemperaturDiagrammScroller documentView]bounds].origin;
	
	[[TemperaturDiagrammScroller contentView] scrollPoint:scrollPoint];
	[TemperaturDiagrammScroller setNeedsDisplay:YES];
	
}



/*
- (NSString*)DruckDatenString
{
	NSCalendarDate* SaveDatum=[NSCalendarDate date];
	int jahr=[SaveDatum yearOfCommonEra];
	NSRange jahrRange=NSMakeRange(2,2);
	NSString* jahrString=[[[NSNumber numberWithInt:jahr]stringValue]substringWithRange:jahrRange];
	int monat=[SaveDatum monthOfYear];
	NSString* monatString=[[NSNumber numberWithInt:monat]stringValue];
	int wtag=[SaveDatum dayOfMonth];
	NSString* tagString=[[NSNumber numberWithInt:wtag]stringValue];
	int stunde=[SaveDatum hourOfDay];
	NSString* stundeString=[[NSNumber numberWithInt:stunde]stringValue];
	int minute=[SaveDatum minuteOfHour];
	NSString* minuteString=[[NSNumber numberWithInt:minute]stringValue];
	NSString* TitelString=@"HomeCentral\rFalkenstrasse 20\r8630 Rueti\rDaten vom: ";
	NSString* DatumString=[NSString stringWithFormat:@"%@.%@.%@  %@:%@",tagString,monatString,jahrString,stundeString,minuteString];
	
	NSString* TemperaturDatenString=[NSString stringWithFormat:@"%@ %@\r\r%@",TitelString,DatumString,[TemperaturDatenFeld string]];
	return TemperaturDatenString;
	
}
*/
- (void)BrenndauerAktion:(NSNotification*)note
{
	//NSLog(@"BrenndauerAktion note: %@",[[note userInfo]description]);
	if ([[note userInfo]objectForKey:@"brenndauerstring"])
	{
		[BrenndauerFeld setStringValue: [[note userInfo]objectForKey:@"brenndauerstring"]];
		
	}
	
}

- (void)setBrennerStatistik:(NSDictionary*)derDatenDic
{
	/*
	 derDatenDic enthaelt Arrays der Brennerstatistik und der Temperaturstatistik
	 Jedes Objekt der Arrays enthaelt das Datum und den TagDesJahres
	 */
   //return;
	
	//NSLog(@"[StatistikDiagrammScroller documentView]: w: %2.2f",[[StatistikDiagrammScroller documentView]frame].size.width);
   [BrennerStatistikDiagramm setGraphFarbe:[NSColor lightGrayColor] forKanal:0];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor blackColor] forKanal:2];
	[BrennerStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:3];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor greenColor] forKanal:2];
	[TemperaturStatistikDiagramm setGraphFarbe:[NSColor grayColor] forKanal:3];

	
	//NSLog(@"Data setBrennerStatstik: %@",[derDatenDic description]);
	NSArray* TemperaturdatenArray =[NSArray array];
	NSArray* BrennerdatenArray =[NSArray array];
//	NSArray* TemperaturKanalArray =[NSArray array];
//	NSArray* BrennerKanalArray =[NSArray array];
	if ([derDatenDic objectForKey:@"temperaturkanalarray"])
	{
//		TemperaturKanalArray=[derDatenDic objectForKey:@"temperaturkanalarray"];
	}
	else
	{
//		TemperaturKanalArray=[NSArray arrayWithObjects:@"1",@"0",@"0",@"0" ,@"0",@"0",@"0",@"0",nil];
	}
	
	
	if ([derDatenDic objectForKey:@"temperaturdatenarray"])
	{
		//NSLog(@"Data setBrennerStatstik: BrennerdatenArray %@",[[derDatenDic objectForKey:@"temperaturdatenarray"] description]);
		NSSortDescriptor* tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagdesjahres"
																							ascending:YES];
		NSArray* sortDescriptors = [NSArray arrayWithObject:tagDescriptor];
		TemperaturdatenArray = [[derDatenDic objectForKey:@"temperaturdatenarray"] sortedArrayUsingDescriptors:sortDescriptors];
		
	}
	//NSLog(@"Data setBrennerStatstik: A");
	if ([derDatenDic objectForKey:@"brennerkanalarray"])
	{
//		BrennerKanalArray=[derDatenDic objectForKey:@"brennerkanalarray"];
//		NSLog(@"Data setBrennerStatstik: BrennerKanalArray %@",[[derDatenDic objectForKey:@"brennerkanalarray"] description]);
	}
	else
	{
//		BrennerKanalArray=[NSArray arrayWithObjects:@"1",@"0",@"0",@"0" ,@"0",@"0",@"0",@"0",nil];
	}
	
	//NSLog(@"Data setBrennerStatstik: B");
	
	if ([derDatenDic objectForKey:@"brennerdatenarray"])
	{
		//NSLog(@"Data setBrennerStatstik: BrennerdatenArray %@",[[derDatenDic objectForKey:@"brennerdatenarray"] description]);
		NSSortDescriptor* tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagdesjahres"
																							ascending:YES];
		NSArray* sortDescriptors = [NSArray arrayWithObject:tagDescriptor];
		BrennerdatenArray = [[derDatenDic objectForKey:@"brennerdatenarray"] sortedArrayUsingDescriptors:sortDescriptors];

		
		
		//BrennerdatenArray=[derDatenDic objectForKey:@"brennerdatenarray"]:
		//NSLog(@"Data setBrennerStatstik: BrennerdatenArray sortiert%@",[BrennerdatenArray description]);
	}
	//NSLog(@"Data setBrennerStatstik: C");
	// Temperatur- und Brennerdaten des gleichen Tages zusammenfuehren
	//NSLog(@"setBrennerStatstik 2");
	NSArray* BrennertagArray=[BrennerdatenArray valueForKey:@"tagdesjahres"];
	NSArray* TemperaturtagArray=[TemperaturdatenArray valueForKey:@"tagdesjahres"];
	
	
	NSMutableArray* StatistikArray=[[NSMutableArray alloc]initWithCapacity:0];
	int index=0;
	
	for (index=0;index<366;index++)
	{
		
		int anz=0;
		NSNumber* indexNumber = [NSNumber numberWithInt:index];
		NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		NSUInteger TempIndex=[TemperaturtagArray indexOfObject:indexNumber];
		if (TempIndex < NSNotFound) // Es gibt einen Eintrag
		{
			anz++;
			[tempDic addEntriesFromDictionary:[TemperaturdatenArray objectAtIndex:TempIndex]];
		}
		
		NSUInteger BrennerIndex=[BrennertagArray indexOfObject:indexNumber];
		if (BrennerIndex < NSNotFound) // Es gibt einen Eintrag
		{
			anz++;
			[tempDic addEntriesFromDictionary:[BrennerdatenArray objectAtIndex:BrennerIndex]];
		}
		
		
		//		NSLog(@"index: %d tagindex: %d anz: %d tempDic: %@",index, tagindex, anz, [tempDic description]);
		
		if (anz)
		{
			[StatistikArray addObject:tempDic];
		}
	}
   
	//NSLog(@"Data setBrennerStatstik: D");
	//NSLog(@"Data setBrennerStatstik: StatistikArray: %@",[StatistikArray description]);
	int i=0;
	[TemperaturStatistikDiagramm setOffsetX:[[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]]; // Startwert der Abszisse setzen
   //NSLog(@"Data setBrennerStatstik: offsetX: %d",[[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]);

	[TagGitterlinien setOffsetX:[[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]];
	
   
   [BrennerStatistikDiagramm setOffsetX:[[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]]; // Startwert der Abszisse setzen
	int tagdesjahresMin=[[[StatistikArray objectAtIndex:0]objectForKey:@"tagdesjahres"]intValue];
	int tagdesjahresMax=[[[StatistikArray objectAtIndex:[StatistikArray count]-1]objectForKey:@"tagdesjahres"]intValue];
	//NSLog(@"tagdesjahresMin: %d tagdesjahresMax: %d ",tagdesjahresMin,tagdesjahresMax);
	
	// Breite des Diagramms anpassen
	float AnzeigeBreite=[StatistikDiagrammScroller  frame].size.width;
	//NSLog(@"AnzeigeBreite: %2.2f",AnzeigeBreite);
	NSPoint tempOrigin=[[StatistikDiagrammScroller documentView] frame].origin;
	NSRect tempFrame=[[StatistikDiagrammScroller documentView] frame];
	//NSLog(@"	tempFrame w vor: %2.2f",tempFrame.size.width);
	float maxZeit=(tagdesjahresMax-tagdesjahresMin) * 10;//ZeitKompression;
		//		tempZeit=[[HomeDatenArray objectAtIndex:0]intValue]- firstZeit;
	float newWidth=maxZeit+20;
	tempFrame.size.width=newWidth;
	//NSLog(@"	tempFrame w nach: %2.2f",tempFrame.size.width);
	[[StatistikDiagrammScroller documentView]setFrame:tempFrame];
	
	NSRect tempBrennerFrame=[BrennerStatistikDiagramm frame];
	tempBrennerFrame.size.width=newWidth;
	[BrennerStatistikDiagramm setFrame:tempBrennerFrame];
	
	NSRect tempTemperaturFrame=[TemperaturStatistikDiagramm frame];
	tempTemperaturFrame.size.width=newWidth;
	[TemperaturStatistikDiagramm setFrame:tempTemperaturFrame];
	
	NSRect tempTagGitterFrame=[TagGitterlinien frame];
	tempTagGitterFrame.size.width=newWidth;
	[TagGitterlinien setFrame:tempTagGitterFrame];
	AnzeigeBreite+=100.0;
	float delta=maxZeit-AnzeigeBreite;
	//NSLog(@"delta: %2.2f",delta);
	tempOrigin.x -=delta;
	[[StatistikDiagrammScroller documentView] setFrameOrigin:tempOrigin];
	//NSLog(@"Data setBrennerStatstik: E");
	//NSLog(@"Data setBrennerStatstik: [StatistikArray count]: %d",[StatistikArray count]);
	for (i=0;i<[StatistikArray count];i++)
	{
		NSMutableArray* tempWerteArray=[[NSMutableArray alloc]initWithCapacity:0];
		// Abszisse: tag des Jahres
		[tempWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]];
		if ([[StatistikArray objectAtIndex:i]objectForKey:@"mittel"])
		{
			[tempWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"mittel"]];
		}
		if ([[StatistikArray objectAtIndex:i]objectForKey:@"tagmittel"])
		{
			[tempWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"tagmittel"]];
		}
		if ([[StatistikArray objectAtIndex:i]objectForKey:@"nachtmittel"])
		{
			[tempWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"nachtmittel"]];
		}
		
			//NSLog(@"setBrennerStatstik i: %d",i);
		[TemperaturStatistikDiagramm setWerteArray:tempWerteArray mitKanalArray:BrennerStatistikTemperaturKanalArray];
		
		
		
		// Brennerstatistikdaten
		
		NSMutableArray* tempBrennerWerteArray=[[NSMutableArray alloc]initWithCapacity:0];
		// Abszisse: tag des Jahres
		[tempBrennerWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]];
		
		if ([[StatistikArray objectAtIndex:i]objectForKey:@"einschaltdauer"])
		{
			[tempBrennerWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"einschaltdauer"]];
		}
		
		if ([[StatistikArray objectAtIndex:i]objectForKey:@"laufzeit"])
		{
			[tempBrennerWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"laufzeit"]];
		}
		/*
		// Breite des Diagramms anpassen
		NSPoint tempOrigin=[[StatistikDiagrammScroller documentView] frame].origin;
		NSRect tempFrame=[[StatistikDiagrammScroller documentView] frame];
		
		int tempZeit=0;
		//		tempZeit=[[HomeDatenArray objectAtIndex:0]intValue]- firstZeit;
		
		*/
		//NSLog(@"setBrennerStatstik i: %d tempBrennerWerteArray: %@",i,[tempBrennerWerteArray description]);
		//NSLog(@"setBrennerStatstik i: %d BrennerKanalArray: %@",i,[BrennerStatistikKanalArray description]);
		
		[BrennerStatistikDiagramm setWerteArray:tempBrennerWerteArray mitKanalArray:BrennerStatistikKanalArray];
		
		// Taglinien
		
		NSMutableArray* tempDatumArray=[[NSMutableArray alloc]initWithCapacity:0];
		// Abszisse: tag des Jahres
		[tempDatumArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]];
		
		if ([[StatistikArray objectAtIndex:i]objectForKey:@"calenderdatum"])
		{
			[tempDatumArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"calenderdatum"]];
		}
		//NSLog(@"Data setBrennerStatstik: i: %d tempDatumArray: %@",i,[tempDatumArray description]);
		[TagGitterlinien setWerteArray:tempDatumArray mitKanalArray:BrennerStatistikTemperaturKanalArray];
		//[TagGitterlinien  setNeedsDisplay:YES];
	}
//NSLog(@"Data setBrennerStatstik: F");

}


- (IBAction)reportStatistikJahr:(id)sender
{
	//NSLog(@"reportStatistikJahr: %d",[[sender selectedItem]tag]);
	[TemperaturStatistikDiagramm clean];
	[TagGitterlinien clean];
	NSMutableDictionary* tempDatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[tempDatenDic setObject:[NSNumber numberWithInt:1]forKey:@"aktion"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"StatistikDaten" object:NULL userInfo:tempDatenDic];
   [TagGitterlinien setNeedsDisplay:YES];

	
}

- (IBAction)reportSolarStatistikJahr:(id)sender
{
	NSLog(@"reportSolarStatistikJahr: %d",[[sender selectedItem]tag]);
	[SolarStatistikDiagramm clean];
	[SolarTagGitterlinien clean];
	NSMutableDictionary* tempDatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[tempDatenDic setObject:[NSNumber numberWithInt:1]forKey:@"aktion"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"SolarStatistikDaten" object:NULL userInfo:tempDatenDic];
   [SolarTagGitterlinien setNeedsDisplay:YES];
   
	
}




- (IBAction)reportStatistikMonat:(id)sender
{
//NSLog(@"reportStatistikMonat: %d",[[sender selectedItem]tag]);


}


- (void)setSolarStatistik:(NSDictionary*)derDatenDic
{
	/*
    Wird von AVRController aufgerufen
    
    
	 derDatenDic enthaelt Arrays der setSolarStatistik und der Temperaturstatistik
	 Jedes Objekt der Arrays enthaelt das Datum und den TagDesJahres
	 
    kollektortemperaturarray: Mittelwerte der Koll.Temp fuer jeden Tag (Werte sind verdoppelt) 
    
    elektrodatenarray: Einschaltdauer von Pumpe und Elektroeinsatz
    elektrokanalarray: Angabe der Kanaele, die angezeigt weden sollen. Hier kanal 0 und 1

    temperaturdatenarray: Mittelwerte fuer Ganzen Tag, Tag und Nacht
    temperaturkanalarray: Angabe der Kanaele, die angezeigt weden sollen. Hier kanal 0, 1 und 2

    */
   
   
	
   NSArray* TemperaturdatenArray =[NSArray array];
   
   [SolarStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:0];
	[SolarStatistikDiagramm setGraphFarbe:[NSColor blueColor] forKanal:1];
	[SolarStatistikDiagramm setGraphFarbe:[NSColor redColor] forKanal:2];
	[SolarStatistikDiagramm setGraphFarbe:[NSColor orangeColor] forKanal:3];
   
   
	NSArray* ElektrodatenArray =[NSArray array];
   
   NSArray* KollektortemperaturArray =[NSArray array];
   
   NSArray* SolarertragArray =[NSArray array];

   NSArray* TemperaturKanalArray=[NSArray arrayWithObjects:@"1",@"0",@"0",@"0" ,@"0",@"0",@"0",@"0",nil];
   
	//NSLog(@"[StatistikDiagrammScroller documentView]: w: %2.2f",[[StatistikDiagrammScroller documentView]frame].size.width);
	
	//NSLog(@"Data setSolarStatistik DatenDic: %@",[derDatenDic description]);
   
   if ([derDatenDic objectForKey:@"elektrodatenarray"])
	{
      //NSLog(@"Data setSolarStatistik: elektrodatenarray da");
      /*
       NSSet* ElektrodatenSet = [NSSet setWithArray:[derDatenDic objectForKey:@"elektrodatenarray"]]; // entfernt doppelte Werte
      ElektrodatenArray=[ElektrodatenSet allObjects];
     
      
		//NSLog(@"Data setSolarStatstik: TemperaturdatenArray %@",[[derDatenDic objectForKey:@"elektrodatenarray"] description]);
		NSSortDescriptor* tagDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"tagdesjahres"
																							ascending:YES] autorelease];
		NSArray* sortDescriptors = [NSArray arrayWithObject:tagDescriptor];
		ElektrodatenArray = [ElektrodatenArray sortedArrayUsingDescriptors:sortDescriptors];
       */
		ElektrodatenArray = [derDatenDic objectForKey:@"elektrodatenarray"];
      //NSLog(@"Data setSolarStatistik: elektrodatenarray end");
	}
   else
   {
      NSLog(@"Data setSolarStatistik: elektrodatenarray nicht da");
   }

   if ([derDatenDic objectForKey:@"temperaturdatenarray"])
	{
      //NSLog(@"Data setSolarStatistik: temperaturdatenarray da");
      NSSet* TemperaturdatenSet = [NSSet setWithArray:[derDatenDic objectForKey:@"temperaturdatenarray"]]; // entfernt doppelte Werte
      TemperaturdatenArray=[TemperaturdatenSet allObjects];

		//NSLog(@"Data setSolarStatstik: TemperaturdatenArray %@",[[derDatenDic objectForKey:@"temperaturdatenarray"] description]);
		NSSortDescriptor* tagDescriptor = [[NSSortDescriptor alloc] initWithKey:@"tagdesjahres"
																							ascending:YES];
		NSArray* sortDescriptors = [NSArray arrayWithObject:tagDescriptor];
		TemperaturdatenArray = [TemperaturdatenArray sortedArrayUsingDescriptors:sortDescriptors];
		//TemperaturdatenArray = [derDatenDic objectForKey:@"temperaturdatenarray"];
      //NSLog(@"Data setSolarStatistik: temperaturdatenarray end");
	}
   else
   {
       NSLog(@"Data setSolarStatistik: temperaturdatenarray nicht da");
   }
   
   if ([derDatenDic objectForKey:@"kollektortemperaturarray"])
	{
      //NSLog(@"Data setSolarStatistik: kollektortemperaturarray da");
      KollektortemperaturArray= [derDatenDic objectForKey:@"kollektortemperaturarray"];
      for (int i=0;i<5;i++)
      {
         //NSLog(@"Data setSolarStatistik i: %d kollektortemperaturarray: %@",i,[[KollektortemperaturArray objectAtIndex:i]description]);
      }
      //NSLog(@"Data setSolarStatistik: kollektortemperaturarray end");
	}
   else
   {
      NSLog(@"Data setSolarStatistik: kollektortemperaturarray nicht da");
   }
   
   if ([derDatenDic objectForKey:@"solarertragarray"])
	{
      //NSLog(@"Data setSolarStatistik: solarertragarray da");
      
      
      SolarertragArray= [derDatenDic objectForKey:@"solarertragarray"];
      for (int i=0;i<[SolarertragArray count];i++)
      {
         //NSLog(@"Data setSolarStatistik i: %d SolarertragArray: %@",i,[[SolarertragArray objectAtIndex:i]description]);
      }
      //NSLog(@"Data setSolarStatistik: solarertragarray end");
	}
   else
   {
      NSLog(@"Data setSolarStatistik: solarertragarray nicht da");
      
      return;
   }
   
  

   
   NSArray* ElektrotagArray=[ElektrodatenArray valueForKey:@"tagdesjahres"];
   
	NSArray* TemperaturtagArray=[TemperaturdatenArray valueForKey:@"tagdesjahres"];
   
   NSArray* KollektortagArray = [NSArray array];
   
   if ([KollektortemperaturArray count])
   {
      KollektortagArray=[KollektortemperaturArray valueForKey:@"tagdesjahres"];
   }
   
   NSArray* SolarertragtagArray = [NSArray array];
   if ([SolarertragArray count])
   {
      SolarertragtagArray = [SolarertragArray valueForKey:@"tagdesjahres"];
      //NSLog(@"SolarertragtagArray count: %d last: %d array: %@",[SolarertragtagArray count],[[SolarertragtagArray lastObject]intValue],[SolarertragtagArray description]);
   }
   //NSLog(@"SolarertragtagArray: %@",[SolarertragtagArray description]);
	//NSLog(@"TemperaturtagArray count: %d last: %d array: %@",[TemperaturtagArray count],[[TemperaturtagArray lastObject]intValue],[TemperaturtagArray description]);
	
	NSMutableArray* TemperaturStatistikArray=[[NSMutableArray alloc]initWithCapacity:0];

   int index=0;
	
	for (index=0;index<366;index++)
	{
		
		int anz=0;
		NSNumber* indexNumber = [NSNumber numberWithInt:index];
      
     // NSLog(@"index: %d indexNumber: %@ ",index,indexNumber);
		NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
      
		NSUInteger  TempIndex=[TemperaturtagArray indexOfObject:indexNumber];
		if (TempIndex < [TemperaturdatenArray count] && [TemperaturdatenArray objectAtIndex:TempIndex])
      {
         if (TempIndex < NSNotFound) // Es gibt einen Eintrag
         {
            //NSLog(@"index: %d TempIndex: %d TemperaturdatenArray at index: %@",index,TempIndex,[[TemperaturdatenArray objectAtIndex:TempIndex]description]);
            
            anz++;
            
            [tempDic addEntriesFromDictionary:[TemperaturdatenArray objectAtIndex:TempIndex]];
         }
      }
      
		NSUInteger  ElektroIndex=[ElektrotagArray indexOfObject:indexNumber];
		if (ElektroIndex < NSNotFound) // Es gibt einen Eintrag
		{
         //NSLog(@"index: %d TempIndex: %d ElektrotagArray at index: %@",index,TempIndex,[[ElektrodatenArray objectAtIndex:TempIndex]description]);
         
			anz++;
			[tempDic addEntriesFromDictionary:[ElektrodatenArray objectAtIndex:ElektroIndex]];
		}
		//		NSLog(@"index: %d tagindex: %d anz: %d tempDic: %@",index, tagindex, anz, [tempDic description]);

      NSUInteger  KollektorIndex=[KollektortagArray indexOfObject:indexNumber];
		if (KollektorIndex < NSNotFound) // Es gibt einen Eintrag
		{
         //NSLog(@"index: %d TempIndex: %d ElektrotagArray at index: %@",index,TempIndex,[[KollektortemperaturArray objectAtIndex:TempIndex]description]);
			anz++;
         
			[tempDic addEntriesFromDictionary:[KollektortemperaturArray objectAtIndex:KollektorIndex]];
		}
		//		NSLog(@"index: %d tagindex: %d anz: %d tempDic: %@",index, tagindex, anz, [tempDic description]);
		
      //indexOfObjectIdenticalTo
      NSUInteger SolarertragIndex=[SolarertragtagArray indexOfObject:indexNumber];
      //NSLog(@"index: %d SolarertragIndex: %lu ",index,(unsigned long)SolarertragIndex);
      
      //if ((SolarertragIndex >=0) && (SolarertragIndex < NSIntegerMax)) // Es gibt einen Eintrag
      if ((SolarertragIndex < NSIntegerMax)) // Es gibt einen Eintrag
      {
         //NSLog(@"F: %d",SolarertragIndex);
         //NSLog(@"index: %d TempIndex: %d SolarertragArray at index: %@",index,SolarertragIndex,[[SolarertragArray objectAtIndex:SolarertragIndex]description]);
         
         anz++;
         if ([SolarertragArray objectAtIndex:SolarertragIndex])
         {
            [tempDic addEntriesFromDictionary:[SolarertragArray objectAtIndex:SolarertragIndex]];
         }
         //NSLog(@"tempDic passed");
      }
      //		NSLog(@"index: %d tagindex: %d anz: %d tempDic: %@",index, tagindex, anz, [tempDic description]);
      
      
      if (anz)
      {
         [TemperaturStatistikArray addObject:tempDic];
      }

		
      
	}

   
   //NSLog(@"Data setSolarStatstik: TemperaturStatistikArray von 0: %@",[[TemperaturStatistikArray objectAtIndex:0]description]);
   for (int i=0;i<5;i++)
   {
      //NSLog(@"Data setSolarStatstik: TemperaturStatistikArray von %d: %@",i,[[TemperaturStatistikArray objectAtIndex:i]description]);
   }
  
   int i=0;
	[SolarStatistikDiagramm setOffsetX:[[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]]; // Startwert der Abszisse setzen
	[SolarStatistikTagGitterlinien setOffsetX:[[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]];
	
   
 //  [ElektroStatistikDiagramm setOffsetX:[[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]intValue]]; // Startwert der Abszisse setzen
	int tagdesjahresMin=[[[TemperaturStatistikArray objectAtIndex:0]objectForKey:@"tagdesjahres"]intValue];
	int tagdesjahresMax=[[[TemperaturStatistikArray objectAtIndex:[TemperaturStatistikArray count]-1]objectForKey:@"tagdesjahres"]intValue];
	//NSLog(@"tagdesjahresMin: %d tagdesjahresMax: %d ",tagdesjahresMin,tagdesjahresMax);
	
	// Breite des Diagramms anpassen
	float AnzeigeBreite=[SolarStatistikDiagrammScroller  frame].size.width;
	//NSLog(@"AnzeigeBreite: %2.2f",AnzeigeBreite);
	NSPoint tempOrigin=[[SolarStatistikDiagrammScroller documentView] frame].origin;
	NSRect tempFrame=[[SolarStatistikDiagrammScroller documentView] frame];
	//NSLog(@"	tempFrame w vor: %2.2f",tempFrame.size.width);
	float maxZeit=(tagdesjahresMax-tagdesjahresMin) * 10;//ZeitKompression;
   //		tempZeit=[[HomeDatenArray objectAtIndex:0]intValue]- firstZeit;
	float newWidth=maxZeit+20;
	tempFrame.size.width=newWidth;
	//NSLog(@"	tempFrame w nach: %2.2f",tempFrame.size.width);
	[[SolarStatistikDiagrammScroller documentView]setFrame:tempFrame];
	
	
	NSRect tempTemperaturFrame=[SolarStatistikDiagramm frame];
	tempTemperaturFrame.size.width=newWidth;
	[SolarStatistikDiagramm setFrame:tempTemperaturFrame];
	
	NSRect tempTagGitterFrame=[SolarStatistikTagGitterlinien frame];
	tempTagGitterFrame.size.width=newWidth;
	[SolarStatistikTagGitterlinien setFrame:tempTagGitterFrame];
	AnzeigeBreite+=100.0;
	float delta=maxZeit-AnzeigeBreite;
	//NSLog(@"delta: %2.2f",delta);
	tempOrigin.x -=delta;
	[[SolarStatistikDiagrammScroller documentView] setFrameOrigin:tempOrigin];
	//NSLog(@"Data setBrennerStatstik: E");
	//NSLog(@"Data setBrennerStatstik: [StatistikArray count]: %d",[StatistikArray count]);

   for (i=0;i<[TemperaturStatistikArray count];i++)
	{
		NSMutableArray* tempWerteArray=[[NSMutableArray alloc]initWithCapacity:0];
		// Abszisse: tag des Jahres
		[tempWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]];
		
      if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"mittel"])
		{
			[tempWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"mittel"]];
		}
      else
      {
         [tempWerteArray addObject:[NSNumber numberWithFloat:0.0]];
      }
		if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagmittel"])
		{
			[tempWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagmittel"]];
		}
      else
      {
         [tempWerteArray addObject:[NSNumber numberWithFloat:0.0]];
      }

		if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"nachtmittel"])
		{
			[tempWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"nachtmittel"]];
		}
      else
      {
         [tempWerteArray addObject:[NSNumber numberWithFloat:0.0]];
      }


      if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"kollektormittelwert"])
		{
			[tempWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"kollektormittelwert"]];
		}
      else
      {
         [tempWerteArray addObject:[NSNumber numberWithFloat:0.0]];
      }


      
		//		if ([[StatistikArray objectAtIndex:i]objectForKey:@"calenderdatum"])
		{
			//			[tempWerteArray addObject:[[StatistikArray objectAtIndex:i]objectForKey:@"calenderdatum"]];
		}
		//NSLog(@"setBrennerStatstik i: %d",i);
		[SolarStatistikDiagramm setWerteArray:tempWerteArray mitKanalArray:SolarStatistikTemperaturKanalArray];
		
		
		
		// Elektrostatistikdaten
		
		NSMutableArray* tempElektroWerteArray=[[NSMutableArray alloc]initWithCapacity:0];
		// Abszisse: tag des Jahres
		[tempElektroWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]];
		
		if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"pumpelaufzeit"])
		{
			[tempElektroWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"pumpelaufzeit"]];
		}
      else
      {
         [tempElektroWerteArray addObject:[NSNumber numberWithInt:0]];

      }
		
		if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"elektrolaufzeit"])
		{
			[tempElektroWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"elektrolaufzeit"]];
		}
      else
      {
         [tempElektroWerteArray addObject:[NSNumber numberWithInt:0]];
         
      }
      
      /*
      if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"ertrag"])
		{
         float tagertrag = [[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"ertrag"]floatValue];
         
         [tempElektroWerteArray addObject:[NSNumber numberWithFloat:tagertrag]];
			//[tempElektroWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"ertrag"]];
		}
      else
      {
         [tempElektroWerteArray addObject:[NSNumber numberWithInt:0]];
         
      }
*/
     
      if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"fluidertrag"])
		{
         float tagertrag = [[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"fluidertrag"]floatValue];
         
         [tempElektroWerteArray addObject:[NSNumber numberWithFloat:tagertrag]];
			//[tempElektroWerteArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"ertrag"]];
		}
      else
      {
         [tempElektroWerteArray addObject:[NSNumber numberWithInt:0]];
         
      }

		
       // Breite des Diagramms anpassen
      NSRect tempTemperaturFrame=[ElektroStatistikDiagramm frame];
      tempTemperaturFrame.size.width=newWidth;
      [ElektroStatistikDiagramm setFrame:tempTemperaturFrame];

       
      if (i<5)
      {
		 //NSLog(@"setSolarStatstik i: %d tempElektroWerteArray: %@",i,[tempElektroWerteArray description]);
      }
		//NSLog(@"setSolarStatstik i: %d SolarStatistikElektroKanalArray: %@",i,[SolarStatistikElektroKanalArray description]);
		
		[ElektroStatistikDiagramm setWerteArray:tempElektroWerteArray mitKanalArray:SolarStatistikElektroKanalArray];
		
		// Taglinien
		
		NSMutableArray* tempDatumArray=[[NSMutableArray alloc]initWithCapacity:0];
		// Abszisse: tag des Jahres
		[tempDatumArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"tagdesjahres"]];
		
		if ([[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"calenderdatum"])
		{
			[tempDatumArray addObject:[[TemperaturStatistikArray objectAtIndex:i]objectForKey:@"calenderdatum"]];
		}
		//NSLog(@"Data setSolarStatstik: i: %d tempDatumArray: %@",i,[tempDatumArray description]);
      // Kanalarray muss 1 als erstes Objekt haben
		[SolarStatistikTagGitterlinien setWerteArray:tempDatumArray mitKanalArray:TemperaturKanalArray];
		//[TagGitterlinien  setNeedsDisplay:YES];
	} // for i
   
   
   
}

- (NSString*)stringAusZeit:(NSTimeInterval) dieZeit
{
	int ZeitInt=(int)dieZeit;
	int Zeitsekunden = ZeitInt % 60;
	ZeitInt/=60;
	int Zeitminuten = ZeitInt%60;
	int Zeitstunden = ZeitInt/60;
	//NSLog(@"Zeitdauer: %2.2f %d Zeiterzeit: %2d:%2d:%2d",dieZeit, Zeitstunden,Zeitminuten,Zeitsekunden);
	NSString* SekundenString;
	if (Zeitsekunden<10)
	{
		
		SekundenString=[NSString stringWithFormat:@"0%d",Zeitsekunden];
	}
	else
	{
		SekundenString=[NSString stringWithFormat:@"%d",Zeitsekunden];
	}
	
	NSString* MinutenString;
	if (Zeitminuten<10)
	{
		
		MinutenString=[NSString stringWithFormat:@"0%d",Zeitminuten];
	}
	else
	{
		MinutenString=[NSString stringWithFormat:@"%d",Zeitminuten];
	}
	
	NSString* StundenString;
	if (Zeitstunden<10)
	{
		StundenString=[NSString stringWithFormat:@" %d",Zeitstunden];
	}
	else
	{
		StundenString=[NSString stringWithFormat:@"%d",Zeitstunden];
	}
	NSString* ZeitdauerString=[NSString stringWithFormat:@"%@:%@:%@",StundenString,MinutenString,SekundenString];
	//NSLog(@"Zeitdauer: %d ZeitdauerString:%@",(int)dieZeit, ZeitdauerString);
	return ZeitdauerString;
}






- (void)loadURL:(NSURL *)URL
{
	NSLog(@"Data loadURL URL: %@",URL );
    [[webView mainFrame] loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)setURLToLoad:(NSURL *)URL
{
    URLToLoad = URL;
}


- (IBAction)reload:(id)sender 
{
    [webView reload:self];
 }

- (void)SimReadAktion:(NSTimer*) derTimer;
{
	//
	//NSLog(@"SimReadAktion ");
	if (SimRun)
	{
		if (DatenpaketArray==NULL)// Sammelarray fuer Daten eines Pakets
		{
			DatenpaketArray=[[NSMutableArray alloc]initWithCapacity:0];
			
		}
		else
		{
			if ([DatenpaketArray count])
			{
				[DatenpaketArray removeAllObjects]; 
			}
		}
		
		/*		
		 int t=[[NSCalendarDate calendarDate] timeIntervalSinceReferenceDate];
		 
		 int t=10*[[NSDate date] timeIntervalSinceDate:DatenserieStartZeit];// *ZeitKompression;
		 //NSLog(@"t0: %X ",t);
		 t/=60;
		 t &= 0xFFFF;
		 int lb=t;
		 lb <<=8;
		 lb &= 0xFF00;
		 lb >>=8;
		 int hb = t;
		 hb >>= 8;
		 //NSLog(@"hb: %X lb: %X",hb,lb);
		 int e=hb;
		 //NSLog(@"e: %X",e);
		 e <<=8;
		 //NSLog(@"e: %X",e);
		 e |=lb;
		 //NSLog(@"t: %X hb: %X lb: %X e: %X",t,hb,lb,e);
		 */
		//	int tempSimZeit=10*[[NSCalendarDate calendarDate] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
		int tempSimZeit=10*[[NSCalendarDate calendarDate] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
		
		[DatenpaketArray addObject:[NSNumber numberWithInt:tempSimZeit]]; // Zeitstempel
		tempSimZeit*=ZeitKompression;
		srandom(time(NULL));
		float y=(float)random() / RAND_MAX * (100);
		int yy=(int)y;
		//NSLog(@"y: %2.2f yy: %d",y,yy);
		float u=10.0*sin(((int)tempSimZeit)%900/10) +50.0;
		[DatenpaketArray addObject:[NSNumber numberWithInt:10]];
		[DatenpaketArray addObject:[NSNumber numberWithFloat:y]];
		[DatenpaketArray addObject:[NSNumber numberWithFloat:u]];
		[DatenpaketArray addObject:[NSNumber numberWithFloat:10-u]];
		if ((int)tempSimZeit%100 >50)
		{
			[DatenpaketArray addObject:[NSNumber numberWithInt:0]];
		}
		else
		{
			[DatenpaketArray addObject:[NSNumber numberWithInt:1]];
		}
		[DatenpaketArray addObject:[NSNumber numberWithInt:0]];
		[DatenpaketArray addObject:[NSNumber numberWithInt:0]];
		NSArray* TemperaturKanalArray= [NSArray arrayWithObjects:@"1",@"1",@"1",@"1" ,@"1",@"0",@"0",@"0",@"0",@"0",@"0",@"0",nil];
		NSArray* BrennerKanalArray=[NSArray arrayWithObjects:@"0",@"0",@"0",@"1" ,@"0",@"0",@"0",@"0",nil];
		NSLog(@"SimReadAktion DatenpaketArray: %@",[DatenpaketArray description]);
		//
		AnzDaten++;
		[AnzahlDatenFeld setIntValue:AnzDaten];
		[TemperaturMKDiagramm setWerteArray:DatenpaketArray mitKanalArray:HeizungKanalArray];
		[TemperaturMKDiagramm setNeedsDisplay:YES];
		[BrennerDiagramm setWerteArray:DatenpaketArray mitKanalArray:BrennerKanalArray];
		[BrennerDiagramm setNeedsDisplay:YES];
		[Gitterlinien setWerteArray:DatenpaketArray mitKanalArray:BrennerKanalArray];
		[Gitterlinien setNeedsDisplay:YES];
		
		NSString* TemperaturDatenString=[NSString stringWithFormat:@"%@\r\t %d\t%d\t%d",[TemperaturDatenFeld string],AnzDaten,tempSimZeit,yy];
		[TemperaturDatenFeld setString:TemperaturDatenString];
		
		if (AnzDaten %7 == 0)
		{
			simDaySaved=0;
			NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[NotificationDic setObject:@"savepart"forKey:@"data"];
			[NotificationDic setObject:SimDatenserieStartZeit forKey:@"datenseriestartzeit"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
			//NSLog(@"savePart: Tag: %d",[SimDatenserieStartZeit dayOfMonth]);
		}
		
		if ((AnzDaten %23 == 0)&& (simDaySaved==0))
		{
			[DatenserieStartZeit dateByAddingTimeInterval:84600];
			NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[NotificationDic setObject:@"saveganz"forKey:@"data"];
			//[NotificationDic setObject:@"savepart"forKey:@"data"];
			[NotificationDic setObject:SimDatenserieStartZeit forKey:@"datenseriestartzeit"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
			//[DatenserieStartZeit addTimeInterval:84600];
//			NSLog(@"saveGanz: Tag: %d",[SimDatenserieStartZeit dayOfMonth]);
			
			simDaySaved=YES;
		}
		
		//NSLog(@"ReadAktion note: %@",[[note userInfo]description]);
		NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
		//NSRect tempFrame=[TemperaturDiagrammScroller frame];
		NSRect tempFrame=[[TemperaturDiagrammScroller documentView] frame];
		
		float rest=tempFrame.size.width-(tempSimZeit);//*ZeitKompression);
		//NSLog(@"rest: %2.2f",rest);
		if (rest<100)
		{
			//		NSLog(@"rest zu klein: %2.2f",rest);
			//		NSLog(@"tempOrigin alt  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			//		NSLog(@"tempFrame: alt x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
			float delta=[[TemperaturDiagrammScroller contentView]frame].size.width-150;
			NSPoint scrollPoint=[[TemperaturDiagrammScroller documentView]bounds].origin;
			tempFrame.size.width+=delta;
			
			tempOrigin.x-=delta;
			scrollPoint.x += delta;
			
			//		NSLog(@"tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
			//		NSLog(@"tempFrame: neu x %2.2f y %2.2f heigt %2.2f width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
			NSRect MKDiagrammRect=[TemperaturMKDiagramm frame];
			MKDiagrammRect.size.width=tempFrame.size.width;
			[TemperaturMKDiagramm setFrame:MKDiagrammRect];
			
			NSRect BrennerRect=[BrennerDiagramm frame];
			BrennerRect.size.width=tempFrame.size.width;
			[BrennerDiagramm setFrame:BrennerRect];
			
			NSRect GitterlinienRect=[Gitterlinien frame];
			GitterlinienRect.size.width=tempFrame.size.width;
			[Gitterlinien setFrame:GitterlinienRect];
			
			NSRect DocRect=	[[TemperaturDiagrammScroller documentView]frame];
			DocRect.size.width=tempFrame.size.width;
			
			[[TemperaturDiagrammScroller documentView] setFrame:DocRect];
			[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
			
			
			[[TemperaturDiagrammScroller contentView] scrollPoint:scrollPoint];
			[TemperaturDiagrammScroller setNeedsDisplay:YES];
			
			
		}
		
		//NSLog(@"SimReadAktion end");
		
		
		
	} // if SimRun
	
	
}


- (IBAction)reportSimStart:(id)sender 
{
	int Stunde,Minute;
	SimDatenserieStartZeit=[NSCalendarDate calendarDate];
	NSCalendarDate *StartZeit = [NSCalendarDate calendarDate];
	//dateWithString:@"Friday, 1 July 2001, 11:45"
	//calendarFormat:@"%A, %d %B %Y, %I:%M"];
	//NSLog(@"reportSimStart: heute: %@",[StartZeit description]);
	Stunde =[StartZeit hourOfDay];
	Minute =[StartZeit minuteOfHour];
	//NSLog(@"h: %d min: %d",Stunde, Minute);
	[StartZeit setCalendarFormat:@"%d.%m.%y %H:%M"];
	[StartzeitFeld setStringValue:[StartZeit description]];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"datastart"forKey:@"data"];
	[NotificationDic setObject:[NSCalendar  currentCalendar]forKey:@"datenseriestartzeit"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	[StopTaste setEnabled:YES];
	[StartTaste setEnabled:NO];
	
	[DatenpaketArray removeAllObjects]; // Aufräumen fuer naechste Serie
	NSMutableDictionary* infoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	
	NSDate *now = [[NSDate alloc] init];
	SimTimer =[[NSTimer alloc] initWithFireDate:now
									   interval:1.0
										 target:self 
									   selector:@selector(SimReadAktion:) 
									   userInfo:infoDic
										repeats:YES];
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:SimTimer forMode:NSDefaultRunLoopMode];
	
	
	SimRun=1;			
	
	[ClearTaste setEnabled:NO];
}

- (IBAction)reportSimStop:(id)sender 
{
	NSLog(@"reportSimStop");
	SimRun=0;
	[ClearTaste setEnabled:YES];
	if ([SimTimer isValid])
	{
		[SimTimer invalidate];
	}
	
}

- (IBAction)reportSimClear:(id)sender
{
	
	[self clearData];
	
}


- (IBAction)reportStart:(id)sender
{
	/*
	 
	 NSCalendarDate *newDate = [[NSCalendarDate alloc]
	 initWithString:@"03.24.01 22:00 PST"
	 calendarFormat:@"%m.%d.%y %H:%M %Z"];
	 */
	NSLog(@"Data reportStart");
	NSCalendarDate* StartZeit=[NSCalendarDate calendarDate];
	[StartZeit setCalendarFormat:@"%d.%m.%y %H:%M"];
	errString=[NSString stringWithFormat:@"Logfile vom: %@\r",[StartZeit description]];
	[StartzeitFeld setStringValue:[StartZeit description]];
	[StartZeit setCalendarFormat:@"%d%m%y_%H%M"];
	
	// Pfad fuer Logfile einrichten
	BOOL FileOK=NO;
	BOOL istOrdner;
	NSFileManager *Filemanager = [NSFileManager defaultManager];
	NSString* USBPfad=[NSHomeDirectory() stringByAppendingFormat:@"%@%@",@"/Documents",@"/USBInterfaceDaten"];
	FileOK= ([Filemanager fileExistsAtPath:USBPfad isDirectory:&istOrdner]&&istOrdner);
	if (FileOK)
	{
		errPfad=[USBPfad stringByAppendingPathComponent:@"Logs"];
		if (![Filemanager fileExistsAtPath:[USBPfad stringByAppendingPathComponent:@"Logs"] isDirectory:&istOrdner]&&istOrdner)
		{
        FileOK =[Filemanager createDirectoryAtPath:USBPfad withIntermediateDirectories:NO attributes:NULL error:NULL];

			//FileOK=[Filemanager createDirectoryAtPath:[USBPfad stringByAppendingPathComponent:@"Logs"] attributes:NULL];
		
		}
	}
	if (FileOK)
	{
		errPfad=[NSString stringWithFormat:@"%@/errString_%@.txt",[USBPfad stringByAppendingPathComponent:@"Logs"],StartZeit];

		NSLog(@"reportStart errPfad: %@",errPfad);

	}
	
	
	DatenserieStartZeit= [NSCalendarDate calendarDate];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"datastart"forKey:@"data"];
	[NotificationDic setObject:[NSCalendarDate calendarDate]forKey:@"datenseriestartzeit"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	[StopTaste setEnabled:YES];
	[StartTaste setEnabled:NO];
	[ClearTaste setEnabled:NO];
	Quelle=0;
}

- (IBAction)reportStop:(id)sender
{
	NSLog(@"Data reportStop");
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"datastop"forKey:@"data"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	[StartTaste setEnabled:YES];
	[StopTaste setEnabled:NO];
	[ClearTaste setEnabled:YES];
	
}

- (IBAction)reportClear:(id)sender
{
	NSLog(@"reportClear");
	
	[self clearData];
	NSCalendarDate* StartZeit=[NSCalendarDate calendarDate];
	[StartZeit setCalendarFormat:@"%d.%m.%y %H:%M"];
//	[StartzeitFeld setStringValue:[StartZeit description]];

	[StartzeitFeld setStringValue:@""];

	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:@"clear"forKey:@"data"];
	DatenserieStartZeit=[NSCalendarDate calendarDate];
	[NotificationDic setObject:DatenserieStartZeit forKey:@"datenseriestartzeit"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"data" object:NULL userInfo:NotificationDic];
	[StopTaste setEnabled:NO];
	[StartTaste setEnabled:YES];

}




- (IBAction)reportPrint:(id)sender
{
	NSLog(@"reportPrint");
	[[TemperaturDiagrammScroller documentView]print:NULL];
}

- (IBAction)reportHeute:(id)sender
{
	NSLog(@"Data reportHeute");


}

- (void)setZeitKompression
{
	//NSLog(@"setZeitKompression");
	ZeitKompression=[[ZeitKompressionTaste titleOfSelectedItem]floatValue];
	
	[TemperaturMKDiagramm setEinheitenDicY:[NSDictionary dictionaryWithObject:[ZeitKompressionTaste titleOfSelectedItem] forKey:@"zeitkompression"]];
	[TemperaturMKDiagramm setNeedsDisplay:YES];
	[BrennerDiagramm setEinheitenDicY:[NSDictionary dictionaryWithObject:[ZeitKompressionTaste titleOfSelectedItem] forKey:@"zeitkompression"]];
	[BrennerDiagramm setNeedsDisplay:YES];
	[Gitterlinien setEinheitenDicY:[NSDictionary dictionaryWithObject:[ZeitKompressionTaste titleOfSelectedItem] forKey:@"zeitkompression"]];
	[Gitterlinien setNeedsDisplay:YES];
	int tempIntervall=2;
	
	
	//NSLog(@"reportZeitKompression Zeitkompression tag raw: %d tag int: %d",[[ZeitKompressionTaste selectedItem]tag],[[ZeitKompressionTaste selectedItem]tag]);
	
	switch ([[ZeitKompressionTaste selectedItem]tag])
	{
		case 0: // 5
			break;
		case 1: // 2
			break;
		case 2: // 1.0
			break;
			
		case 3: // 0.75
		case 4: // 0.5
			tempIntervall=5;
			break;
			
		case 5: // 0.2
			tempIntervall=10;
			break;
		case 6: // 0.1
			tempIntervall=20;
			break;
		case 7: // 0.05
			tempIntervall=30;
			break;	
	} // switch tag
	
	//if ([[sender titleOfSelectedItem]floatValue] <1.0)
	{
		[Gitterlinien setEinheitenDicY:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:tempIntervall] forKey:@"intervall"]];
		
	}
	
	[[TemperaturDiagrammScroller contentView]setNeedsDisplay:YES];
	
}



- (IBAction)reportZeitKompression:(id)sender
{
	float stretch=[[sender titleOfSelectedItem]floatValue]/ZeitKompression;
	
	NSLog(@"reportZeitKompression: %2.2F stretch: %2.2f",[[sender titleOfSelectedItem]floatValue],stretch);
	
	ZeitKompression=[[sender titleOfSelectedItem]floatValue];
   NSLog(@"reportZeitKompression a1");
   NSLog(@"reportZeitKompression ZeitKompression: %2.2f",ZeitKompression);

	//[TemperaturMKDiagramm setEinheitenDicY:[NSDictionary dictionaryWithObject:[sender titleOfSelectedItem] forKey:@"zeitkompression"]];
	[TemperaturMKDiagramm setZeitKompression:ZeitKompression];
  // NSLog(@"reportZeitKompression a2");
	//[BrennerDiagramm setEinheitenDicY:[NSDictionary dictionaryWithObject:[sender titleOfSelectedItem] forKey:@"zeitkompression"]];
	[BrennerDiagramm setZeitKompression:ZeitKompression];
   //NSLog(@"reportZeitKompression a3");
	//[Gitterlinien setEinheitenDicY:[NSDictionary dictionaryWithObject:[sender titleOfSelectedItem] forKey:@"zeitkompression"]];
	
	int tempIntervall=2;
   //NSLog(@"reportZeitKompression B");
	
	//NSLog(@"reportZeitKompression Zeitkompression tag raw: %d tag int: %d",[[sender selectedItem]tag],[[sender selectedItem]tag]);
	
	switch ([[sender selectedItem]tag])
	{
		case 0: // 5
			break;
		case 1: // 2
			break;
		case 2: // 1.0
			break;
			
		case 3: // 0.75
		case 4: // 0.5
			tempIntervall=5;
			break;
			
		case 5: // 0.2
			tempIntervall=10;
			break;
		case 6: // 0.1
			tempIntervall=20;
			break;
		case 7: // 0.05
			tempIntervall=30;
			break;	
		case 8: // 0.02
			tempIntervall=60;
			break;	
		case 9: // 0.01
			tempIntervall=120;
			break;	

	} // switch tag
	
   // NSLog(@"reportZeitKompression C");
	//if ([[sender titleOfSelectedItem]floatValue] <1.0)
	{
		[Gitterlinien setEinheitenDicY:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:tempIntervall] forKey:@"intervall"]];
		
	}
	// NSLog(@"reportZeitKompression D");
	NSArray* StringArray=[[TemperaturDatenFeld string]componentsSeparatedByString:@"\r"];
	NSMutableArray* AbszissenArray=[[NSMutableArray alloc]initWithCapacity:0];
	int i;
	for (i=0;i<[StringArray count];i++)
	{
		if ([StringArray objectAtIndex:i])
		{
			NSArray* ZeilenArray=[[StringArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
			if ([ZeilenArray count]>1)
			{
				[AbszissenArray addObject:[ZeilenArray objectAtIndex:1]]; // Object 0 ist 
			}
		}
	}
   // NSLog(@"reportZeitKompression F");
	//NSLog(@"Data AbszissenArray: %@",[AbszissenArray description]);
	[Gitterlinien setZeitKompression:ZeitKompression mitAbszissenArray:AbszissenArray];
	// NSLog(@"reportZeitKompression G");
	
	
	
	NSRect DocRect=	[[TemperaturDiagrammScroller documentView]frame];
	NSRect ContRect=[[TemperaturDiagrammScroller contentView]frame];
	if ((DocRect.size.width * stretch) > ContRect.size.width)
	{
      DocRect.size.width *= stretch;
      
      NSRect MKRect=[TemperaturMKDiagramm frame];
      MKRect.size.width = DocRect.size.width;
      [TemperaturMKDiagramm setFrame:MKRect];
      
      NSRect BrennerRect=[BrennerDiagramm frame];
      BrennerRect.size.width = DocRect.size.width;
      [BrennerDiagramm setFrame:BrennerRect];
      
      NSRect GitterRect=[Gitterlinien frame];
      GitterRect.size.width = DocRect.size.width;
      [Gitterlinien setFrame:GitterRect];
      
      
      
      
      [[TemperaturDiagrammScroller documentView] setFrame:DocRect];
      NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
      
      [[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
      
      NSPoint scrollPoint=[[TemperaturDiagrammScroller documentView]bounds].origin;
      
      [[TemperaturDiagrammScroller contentView] scrollPoint:scrollPoint];
      [TemperaturDiagrammScroller setNeedsDisplay:YES];
      
      
      [[TemperaturDiagrammScroller contentView]setNeedsDisplay:YES];
	}
  // NSLog(@"reportSolarZeitKompression end");
}


- (IBAction)reportSolarZeitKompression:(id)sender
{
   
   float stretch=[[sender titleOfSelectedItem]floatValue]/SolarZeitKompression;
	
	//NSLog(@"reportSolarZeitKompression: %2.2F stretch: %2.2f",[[sender titleOfSelectedItem]floatValue],stretch);
	
	SolarZeitKompression=[[sender titleOfSelectedItem]floatValue];
   
   [SolarDiagramm setZeitKompression:SolarZeitKompression];
	[SolarDiagramm setEinheitenDicY:[NSDictionary dictionaryWithObject:[sender titleOfSelectedItem] forKey:@"zeitkompression"]];
   
	[SolarEinschaltDiagramm setZeitKompression:SolarZeitKompression];

   int tempIntervall=2;
   
   switch ([[sender selectedItem]tag])
	{
		case 0: // 5
			break;
		case 1: // 2
			break;
		case 2: // 1.0
			break;
			
		case 3: // 0.75
		case 4: // 0.5
			tempIntervall=5;
			break;
			
		case 5: // 0.2
			tempIntervall=10;
			break;
		case 6: // 0.1
			tempIntervall=20;
			break;
		case 7: // 0.05
			tempIntervall=30;
			break;
		case 8: // 0.02
			tempIntervall=60;
			break;
		case 9: // 0.01
			tempIntervall=120;
			break;
         
	} // switch tag
   
   
   [SolarGitterlinien setEinheitenDicY:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:tempIntervall] forKey:@"intervall"]];
   
   
	NSArray* StringArray=[[SolarDatenFeld string]componentsSeparatedByString:@"\r"];
	NSMutableArray* AbszissenArray=[[NSMutableArray alloc]initWithCapacity:0];
	int i;
	for (i=0;i<[StringArray count];i++)
	{
		if ([StringArray objectAtIndex:i])
		{
			NSArray* ZeilenArray=[[StringArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
			if ([ZeilenArray count]>1)
			{
				[AbszissenArray addObject:[ZeilenArray objectAtIndex:1]]; // Object 0 ist
			}
		}
	}
	//NSLog(@"Data AbszissenArray: %@",[AbszissenArray description]);
	[SolarGitterlinien setZeitKompression:SolarZeitKompression mitAbszissenArray:AbszissenArray];

   [SolarGitterlinien setNeedsDisplay:YES];
   
   //
   
	NSRect DocRect=	[[SolarDiagrammScroller documentView]frame];
	NSRect ContRect=[[SolarDiagrammScroller contentView]frame];
	if ((DocRect.size.width * stretch) > ContRect.size.width)
	{
      DocRect.size.width *= stretch;
      
      NSRect MKRect=[SolarDiagramm frame];
      MKRect.size.width = DocRect.size.width;
      [SolarDiagramm setFrame:MKRect];
      
      NSRect BrennerRect=[SolarEinschaltDiagramm frame];
      BrennerRect.size.width = DocRect.size.width;
      [SolarEinschaltDiagramm setFrame:BrennerRect];
      
      NSRect GitterRect=[SolarGitterlinien frame];
      GitterRect.size.width = DocRect.size.width;
      [SolarGitterlinien setFrame:GitterRect];
      
      
      
      
      [[SolarDiagrammScroller documentView] setFrame:DocRect];
      NSPoint tempOrigin=[[SolarDiagrammScroller documentView] frame].origin;
      
      [[SolarDiagrammScroller documentView] setFrameOrigin:tempOrigin];
      
      NSPoint scrollPoint=[[SolarDiagrammScroller documentView]bounds].origin;
      
      [[SolarDiagrammScroller contentView] scrollPoint:scrollPoint];
      [SolarDiagrammScroller setNeedsDisplay:YES];
      
      
      [[SolarDiagrammScroller contentView]setNeedsDisplay:YES];
   }
   
   //
}


- (void)setTemperaturwerteArray:(NSArray*) derTemperaturwerteArray
{
	NSLog(@"\n\n                    rData   setTemperaturwerteArray");
	//NSView* tempContentView=[MehrkanalDiagrammScroller contentView];
	
	NSPoint tempOrigin=[[TemperaturDiagrammScroller documentView] frame].origin;
	NSRect tempFrame=[TemperaturMKDiagramm frame];
	
	//	NSLog(@"tempFrame: origin.x %2.2f origin.y %2.2f size.heigt %2.2f size.width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
	//	NSLog(@"tempOrigin x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
	
	//Array fuer Zeit und Daten einer Zeile
	NSMutableArray* tempKanalDatenArray=[[NSMutableArray alloc]initWithCapacity:9];
	NSMutableArray* tempKanalSelektionArray=[[NSMutableArray alloc]initWithCapacity:8];
	NSMutableString* tempZeilenString=[NSMutableString stringWithString:[TemperaturDatenFeld string]];//Vorhandene Daten im Wertfeld
	
	
	float tempZeit=0.0;
	
	float ZeitKompression=[[ZeitKompressionTaste titleOfSelectedItem]floatValue];
	NSMutableArray* tempDatenArray=(NSMutableArray*)[TemperaturDaten objectForKey:@"datenarray"];
	
	if ([tempDatenArray count])//schon Daten im Array
	{
		//NSLog(@"ADWandler setEinkanalDaten tempDatenArray: %@",[tempDatenArray description]);
		tempZeit=[[NSCalendarDate calendarDate] timeIntervalSinceDate:DatenserieStartZeit];//*ZeitKompression;
		
	}
	else //Leerer Datenarray
	{
		//NSLog(@"ADWandler setEinkanalDaten                    leer  tempDatenArray: %@",[tempDatenArray description]);
		
		DatenserieStartZeit=[NSCalendarDate calendarDate];
		[TemperaturDaten setObject:[NSDate date] forKey:@"datenseriestartzeit"];
		NSMutableArray* tempStartWerteArray=[[NSMutableArray alloc]initWithCapacity:8];
		
		int i;
		for (i=0;i<8;i++)
		{
			float y=(float)random() / RAND_MAX * (255);
			//y=127.0;
			[tempStartWerteArray addObject:[NSNumber numberWithInt:(int)y]];
		}
		[TemperaturMKDiagramm setStartWerteArray:tempStartWerteArray];
	}
	
	//	NSString* tempZeitString=[ZeitFormatter stringFromNumber:[NSNumber numberWithFloat:tempZeit]];
	NSString* tempZeitString=[NSString stringWithFormat:@"%2.2f",tempZeit];
	
	//	NSLog(@"reportReadRandom8  tempZeitString: %@",tempZeitString);
	//[tempZeilenString appendFormat:@"\t%@",tempZeitString];
	
	
	int i;
	for (i=0;i<8;i++)
	{
		float y=(float)random() / RAND_MAX * (255);
		[tempKanalDatenArray addObject:[NSNumber numberWithInt:(int)y]];
		
		//		NSString* tempWertString=[DatenFormatter stringFromNumber:[NSNumber numberWithFloat:y]];
		NSString* tempWertString=[NSString stringWithFormat:@"%2.0f",y];
		
		//NSLog(@"tempWertString: %@",tempWertString);
		//[tempZeilenString appendFormat:@"\t%@",tempWertString];
		
		//Array der Daten einer Zeile: Element i der Datenleseaktion
		
		if (i==0)
		{	
			float rest=tempFrame.size.width-tempZeit;
			if (rest<100)
			{
				//NSLog(@"rest zu klein",rest);
				if (rest<0)//Wert hat nicht Platz
				{
					tempFrame.size.width=tempZeit+100;
					tempOrigin.x=tempZeit-100;
				}
				else
				{
					tempFrame.size.width+=200;
					tempOrigin.x-=200;
				}
				//NSLog(@"tempFrame: neu origin.x %2.2f origin.y %2.2f size.heigt %2.2f size.width %2.2f",tempFrame.origin.x, tempFrame.origin.y, tempFrame.size.height, tempFrame.size.width);
				//NSLog(@"tempOrigin neu  x: %2.2f y: %2.2f",tempOrigin.x,tempOrigin.y);
				
				[TemperaturMKDiagramm setFrame:tempFrame];	
				[[TemperaturDiagrammScroller documentView] setFrameOrigin:tempOrigin];
				
				
			}
		}//i=0;
		
	}
	
	//NSLog(@"tempZeilenString: %@",tempZeilenString);
	{
		//[tempZeilenString appendFormat:@"\n"];//Zeilenende
	}
	NSArray* ZeilenArray=[tempZeilenString componentsSeparatedByString:@"\n"];
	//NSLog(@"ZeilenArray: %@",[ZeilenArray description]);
	
	NSString* neueZeile=[ZeilenArray objectAtIndex:[ZeilenArray count]-2];
	//	NSLog(@"neueZeile: %@",neueZeile);
	
	//	[TemperaturWertFeld setStringValue: neueZeile];
	
	
	//	[MehrkanalDatenFeld setString:tempZeilenString];
	
	
	//Array der Daten einer Zeile: erstes Element: Zeit der Datenleseaktion
	[tempKanalDatenArray insertObject:[NSNumber numberWithFloat:tempZeit] atIndex:0];
	//	NSArray*tempArray=[NSArray arrayWithObjects:[NSNumber numberWithFloat:tempZeit],[NSNumber numberWithFloat:y],nil];
	[tempDatenArray addObject:tempKanalDatenArray];
	//NSLog(@"tempZeilenString vor: %@",tempZeilenString);
	
	//NSLog(@"Mehrkanal tempZeilenString nach: %@",tempZeilenString);
	
	
	//[MehrkanalDatenFeld setString:tempZeilenString];
	
	
	
	NSLog(@"ADWandler reportRead8RandomKanal       tempZeit: %2.2f  Werte: %@",tempZeit,[tempKanalDatenArray description]);
	
	[TemperaturMKDiagramm setWerteArray:tempKanalDatenArray mitKanalArray:tempKanalSelektionArray];
	
}

- (void)ReportHandlerCallbackAktion:(NSNotification*)note
{
	NSLog(@"EEDatenlesenAktion note: %@",[[note userInfo]description]);
	if ([[note userInfo]objectForKey:@"datenarray"]&&[[[note userInfo]objectForKey:@"datenarray"] count])
	{
		NSArray* Datenarray=[[note userInfo]objectForKey:@"datenarray"];//Array der Reports
		NSString* byte0=[Datenarray objectAtIndex:0];
		NSString* byte1=[Datenarray objectAtIndex:1];
		
		NSLog(@"byte0: %@ byte1: %@",byte0,byte1);
		NSScanner* ErrScanner = [NSScanner scannerWithString:byte1];
		int scanWert=0;
		if ([ErrScanner scanHexInt:&scanWert]) //intwert derDaten
		{
			NSLog(@"byte1: %@ scanWert: %02X",byte0,scanWert);
			if (scanWert&0x80)
			{
				NSLog(@"I2C Fehler");
				
				NSAlert *Warnung = [[NSAlert alloc] init];
				[Warnung addButtonWithTitle:@"OK"];
				//	[Warnung addButtonWithTitle:@""];
				//	[Warnung addButtonWithTitle:@""];
				//	[Warnung addButtonWithTitle:@"Abbrechen"];
				[Warnung setMessageText:[NSString stringWithFormat:@"%@",@"TWI-Fehler"]];
				
				NSString* s1=@"Moeglicherweise ist die Adresse des Slave falsch.";
				NSString* s2=@"Der Slave mit dieser Adresse ist eventuell nicht eingesteckt";
				NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s1,s2];
				[Warnung setInformativeText:InformationString];
				[Warnung setAlertStyle:NSAlertStyleWarning];
				
				int antwort=[Warnung runModal];
				
				return;
			}
			
		}
		
		int anzBytes=0;
		int i=0;
		switch ([byte0 intValue])
		{
			case 2:		//	write-Report
				[Eingangsdaten removeAllObjects];
				NSLog(@"write Report");
				break;
				
			case 3:		//	read-Report		
				anzBytes=[byte1 intValue];	//Anz Daten im Report
				NSLog(@"read Report: anzBytes: %d",anzBytes);
				for (i=0;i<anzBytes;i++)
				{
					
					[Eingangsdaten addObject:[Datenarray objectAtIndex:i+2]];
					
				}
				
				break;
				
		}//byte0
		
	}
	if ([Eingangsdaten count]&&[Eingangsdaten count]==AnzahlDaten)
	{
		
		NSArray* bitnummerArray=[NSArray arrayWithObjects: @"null", @"eins",@"zwei",@"drei",@"vier",@"fuenf",nil];
		//		NSLog(@"Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
		NSMutableArray* tempKesselArray=[[NSMutableArray alloc]initWithCapacity:0];
		
		
		
		
		int k,bit;
		bit=0;
		for (k=0;k<AnzahlDaten/6+1;k++)
		{
			NSMutableDictionary* tempReportDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			for (bit=0;bit<6;bit++)
			{
				if (k*6+bit<AnzahlDaten)
				{
					[tempReportDic setObject:[Eingangsdaten objectAtIndex:k*6+bit] forKey:[bitnummerArray objectAtIndex:bit]];
				}
				else//Auffüllen
				{
					
				}
			}
			//NSLog(@"k: %d tempReportDic: %@",k,[tempReportDic description]);
			[DumpArray addObject:tempReportDic];
			
		}
		//NSLog(@"DumpArray: %@",[DumpArray description]);
		
		int i;
		
		NSScanner* EEScanner;
		
		int KesselCode=0;
		
		for (i=0;i<24;i++)
		{
			//int wert=[[Eingangsdaten objectAtIndex:i]intValue];
			EEScanner = [NSScanner scannerWithString:[Eingangsdaten objectAtIndex:i]];
			uint scanWert=0;
			if ([EEScanner scanHexInt:&scanWert]) //intwert derDaten
			{
				KesselCode=scanWert>>6; //	6 Stellen nach rechts schieben, bleiben bit0 und bit1 
			}
			
			[tempKesselArray addObject:[NSNumber numberWithInt:KesselCode]];
			
		}
		//NSArray* tagArray=[Eingangsdaten subarrayWithRange:NSMakeRange(0,24)];
		
		//NSLog(@"tagArray: %@ \nAnz: %d",[tagArray description],[tagArray count]);
		int TagPopIndex=[TagPop indexOfSelectedItem];
		
		//NSLog(@"ReportHandlerCallbackAktion: Tag: %d",TagPopIndex);
		
		[[[Datenplan objectAtIndex:TagPopIndex]objectForKey:@"Heizung"]setBrennerStundenArray:tempKesselArray forKey:@"kessel"];
		
		IOW_busy=0;
	}
}

- (void)IOWAktion:(NSNotification*)note
{
	NSLog(@"IOWAktion note: %@",[[note userInfo]description]);
	if ([[note userInfo]objectForKey:@"iow"])
	{
		[StartTaste setEnabled:[[[note userInfo]objectForKey:@"iow"]intValue]==1];
		//NSLog(@"Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
	}
	
}


- (void)I2CAktion:(NSNotification*)note
{
	//NSLog(@"I2CAktion note: %@",[[note userInfo]description]);
	if ([[note userInfo]objectForKey:@"fertig"])
	{
		//NSLog(@"Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
	}
	
}
- (void)writeIOWLog:(NSString*)derFehler
{

}

- (IBAction)readTagplan:(id)sender
{
	//NSLog(@"readTagplan");
	
	
	int tagIndex=[TagPop indexOfSelectedItem];
	NSString* Tag=[TagPop itemTitleAtIndex:tagIndex];
	int I2CIndex=[I2CPop indexOfSelectedItem];
	NSString* EEPROM_i2cAdresse=[I2CPop itemTitleAtIndex:I2CIndex];
	AnzahlDaten=0x20;
	int i2cadresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresse];
	
	if ([theScanner scanHexInt:&i2cadresse])
	{
		//NSLog(@"readTagplan: EEPROM_i2cAdresse string: %@ int: %x	",EEPROM_i2cAdresse,i2cadresse);
		
	}
	[self setI2CStatus:1];
	[self readTagplan:i2cadresse vonAdresse:tagIndex*0x20 anz:0x20];
	[self setI2CStatus:0];
	
}

- (IBAction)readDatenplan:(id)sender
{
	
	aktuellerTag=0;
	NSDate *now = [[NSDate alloc] init];
	NSMutableDictionary* infoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[infoDic setObject:[NSNumber numberWithInt:0] forKey:@"tag"];
	
	IOWTimer =[[NSTimer alloc] initWithFireDate:now
									   interval:0.05
										 target:self 
									   selector:@selector(readWocheFunktion:) 
									   userInfo:infoDic
										repeats:YES];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:IOWTimer forMode:NSDefaultRunLoopMode];
	
	
}

- (void)writeDatenplan:(id)sender
{
	
	//	if ([IOWTimer isValid])
	//		[IOWTimer invalidate];
	aktuellerTag=0;
	//	[self setI2CStatus:1];
	NSLog(@"writeDatenplan");
	NSMutableDictionary* infoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[infoDic setObject:[NSNumber numberWithInt:0] forKey:@"tag"];
	NSDate *now = [[NSDate alloc] init];
	IOWTimer =[[NSTimer alloc] initWithFireDate:now
									   interval:0.3
										 target:self 
									   selector:@selector(writeWocheFunktion:) 
									   userInfo:infoDic
										repeats:YES];
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:IOWTimer forMode:NSDefaultRunLoopMode];
	

	
}


- (void)readWocheFunktion:(NSTimer*) derTimer;	
{
	
	//NSLog(@"readWoche");
	NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA",@"SO",nil];
	NSMutableDictionary* tempInfoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	
	if ([derTimer userInfo])
	{
		tempInfoDic=(NSMutableDictionary*)[derTimer userInfo];
		aktuellerTag=[[tempInfoDic objectForKey:@"tag"]intValue];
	}
	
	if (aktuellerTag==0)
	{
		[self setI2CStatus:1];
	}
	
	[TagPop selectItemAtIndex:aktuellerTag];
	NSString* Tag=[Wochentage objectAtIndex: aktuellerTag];
	int I2CIndex=0;//					[I2CPop indexOfSelectedItem];
	NSString* EEPROM_i2cAdresse=[I2CPop itemTitleAtIndex:I2CIndex];
	AnzahlDaten=0x20;
	int i2cadresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresse];
	
	if ([theScanner scanHexInt:&i2cadresse])
	{
		//NSLog(@"readTagplan: EEPROM_i2cAdresse string: %@ int: %x	",EEPROM_i2cAdresse,i2cadresse);
		
	}
	//NSLog(@"readWoche: EEPROM_i2cAdresse: %x tagIndex: %d MemAdresse: %x",i2cadresse, aktuellerTag,aktuellerTag*0x20);
	//IOW_busy=1;
	[self readTagplan:i2cadresse vonAdresse:aktuellerTag*0x20 anz:0x20];
	
	
	if (aktuellerTag==6)
	{
		[IOWTimer invalidate];
		[self setI2CStatus:0];
		//[TagPop selectItemAtIndex:0];
	}
	else
	{
		aktuellerTag++;
		[tempInfoDic setObject:[NSNumber numberWithInt:aktuellerTag] forKey:@"tag"];
	}
}


- (void)setI2CStatus:(int)derStatus
{
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* i2cStatusDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[i2cStatusDic setObject:[NSNumber numberWithInt:derStatus]forKey:@"status"];
	//NSLog(@"Data  setI2CStatus: Status: %d",derStatus);
	[nc postNotificationName:@"i2cstatus" object:self userInfo:i2cStatusDic];
	
}


- (void)readTagplan:(int)i2cAdresse vonAdresse:(int)startAdresse anz:(int)anzDaten
{
   NSLog(@"rData readTagplan");
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	
	
	NSMutableDictionary* readEEPROMDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	NSMutableArray* i2cAdressArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Adressierung EEPROM
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x83]]; // Startbit 3 bytes ohne Stopbit
	[i2cAdressArray addObject:[NSNumber numberWithInt:i2cAdresse]]; // I2C-Adresse EEPROM mit WRITE
	int lbyte=startAdresse%0x100;
	int hbyte=startAdresse/0x100;
	
	[i2cAdressArray addObject:[NSNumber numberWithInt:hbyte]];
	[i2cAdressArray addObject:[NSNumber numberWithInt:lbyte]];
	//NSLog(@"readTagplan i2cAdressArray: %@",[i2cAdressArray description]);
	[Adresse setStringValue:[i2cAdressArray componentsJoinedByString:@" "]];
	[readEEPROMDic setObject:i2cAdressArray forKey:@"adressarray"];
	
	NSMutableArray* i2cCmdArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Anforderung Daten
	[i2cCmdArray addObject:[NSNumber numberWithInt:0x03]];	// read-Report
	[i2cCmdArray addObject:[NSNumber numberWithInt:anzDaten]]; // anz Daten
	[i2cCmdArray addObject:[NSNumber numberWithInt:i2cAdresse+1]]; // I2C-Adresse EEPROM mit READ
	//	[i2cCmdArray addObject:[NSString stringWithFormat:@"% 02X",[[NSNumber numberWithInt:i2cAdresse+1]stringValue]]]; // I2C-Adresse EEPROM mit READ
	[readEEPROMDic setObject:i2cCmdArray forKey:@"cmdarray"];
	
	NSString* cmdString=[NSString string];;
	int k=0;
	for(k=0;k<[i2cCmdArray count];k++)
	{
		//	cmdString=[cmdString stringByAppendingString:[NSString stringWithFormat:@"% 02X",[[i2cCmdArray objectAtIndex:k]stringValue]]];
		
	}
	[Cmd setStringValue:[i2cCmdArray componentsJoinedByString:@" "]];
	//	[Cmd setStringValue:cmdString];
	
	//	NSLog(@"readTagplan: readEEPROMDic: %@",[readEEPROMDic description]);
	
	[nc postNotificationName:@"i2ceepromread" object:self userInfo:readEEPROMDic];
	
	
	//NSLog(@"readTagplan Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
}






- (int)writeEEPROM:(int)i2cAdresse anAdresse:(int)startAdresse mitDaten:(NSArray*)dieDaten
{
	//NSLog(@"writeEEPROM: i2cAdresse: %02X dieDaten: %@",i2cAdresse, [dieDaten description]);
	int writeErr=0;
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* writeEEPROMDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	
	NSMutableArray* i2cWriteArray=[[NSMutableArray alloc]initWithCapacity:0];//Sammelarray fuer die Arrays der Reports
	int anzDaten=[dieDaten count];
	//NSLog(@"writeEEPROM Aresse: %02X dieDaten: %@  anz: %d",startAdresse,[dieDaten description],[dieDaten count]);
	//Adressierung EEPROM
	//[i2cWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
	int pages=(anzDaten)/6; // 
	int restdaten=(anzDaten)%6;
	
	//NSLog(@"Anz Pages: %d restPage: %d",pages, restdaten);
	
	if (anzDaten<=3) // nur ein Report mit Start/Stop
	{
		NSMutableArray* tempWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
		[tempWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
		[tempWriteArray addObject:[NSNumber numberWithInt:0xc3 + anzDaten]]; // Startbit, Startadresse, bis 3 bytes,  Stopbit
		[tempWriteArray addObject:[NSNumber numberWithInt:i2cAdresse]]; // I2C-Adresse EEPROM mit WRITE
		int lbyte=startAdresse%0x100;
		int hbyte=startAdresse/0x100;
		[tempWriteArray addObject:[NSNumber numberWithInt:hbyte]];
		[tempWriteArray addObject:[NSNumber numberWithInt:lbyte]];
		
		int k;
		for (k=0;k<anzDaten;k++)
		{
			[tempWriteArray addObject:[dieDaten objectAtIndex:k]];
		}
		
		[i2cWriteArray addObject:tempWriteArray];//in Sammelarray fuer die Arrays der Reports
		
		//		[writeEEPROMDic setObject:i2cWriteArray forKey:@"i2ceepromarray"];
		//		[nc postNotificationName:@"i2ceepromwrite" object:self userInfo:writeEEPROMDic];
		
	}
	else
	{
		NSMutableArray* tempWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
		[tempWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
		[tempWriteArray addObject:[NSNumber numberWithInt:0x83]]; // Startbit, Startadresse, 4 bytes  
		[tempWriteArray addObject:[NSNumber numberWithInt:i2cAdresse]]; // I2C-Adresse EEPROM mit WRITE
		
		int lbyte=startAdresse%0x100;
		int hbyte=startAdresse/0x100;
		[tempWriteArray addObject:[NSNumber numberWithInt:hbyte]];
		[tempWriteArray addObject:[NSNumber numberWithInt:lbyte]];
		int k=0;
		//die 3 ersten Datenbytes
		
		//		for(k=0;k<3;k++)
		{
			//			[i2cWriteArray addObject:[dieDaten objectAtIndex:k]];
		}
		[i2cWriteArray addObject:tempWriteArray];//in Sammelarray fuer die Arrays der Reports
		
		//		[writeEEPROMDic setObject:i2cWriteArray forKey:@"i2ceepromarray"];
		//		[nc postNotificationName:@"i2ceepromwrite" object:self userInfo:writeEEPROMDic];
		//		NSLog(@"Data writeEEPROM Start-Report  i2cWriteArray: %@  anz: %d",[i2cWriteArray description],[i2cWriteArray count]);		
		//		[i2cWriteArray removeAllObjects];
		
		
		
		int pageIndex=0;
		for (pageIndex=0;pageIndex<pages;pageIndex++)
		{
			NSMutableArray* tempWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
			[tempWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
			
			
			if ((pageIndex==pages-1)&&(restdaten==0))// letzter Report, keine Restdaten
			{
				[tempWriteArray addObject:[NSNumber numberWithInt:0x46]]; // Stopflag, anzDaten
			}
			else
			{
				[tempWriteArray addObject:[NSNumber numberWithInt:0x06]]; // keine Flags, anzDaten
			}
			
			
			for (k=0;k<6;k++)
			{
				
				[tempWriteArray addObject:[dieDaten objectAtIndex:(pageIndex*6)+k]];
			}
			
			[i2cWriteArray addObject:tempWriteArray];//in Sammelarray fuer die Arrays der Reports
			
			//			[writeEEPROMDic setObject:i2cWriteArray forKey:@"i2ceepromarray"];
			//			[nc postNotificationName:@"i2ceepromwrite" object:self userInfo:writeEEPROMDic];
			//			NSLog(@"Data writeEEPROM Report: %d  i2cWriteArray: %@  anz: %d",pageIndex,[i2cWriteArray description],[i2cWriteArray count]);		
			
			//			[i2cWriteArray removeAllObjects];
			
		}
		
		
		
		
		if (restdaten)
		{
			NSMutableArray* tempWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
			[tempWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
			[tempWriteArray addObject:[NSNumber numberWithInt: 0x40 + restdaten]];//restdaten und Stopbit
			for (k=0;k<restdaten; k++)
			{
				[tempWriteArray addObject:[dieDaten objectAtIndex:(pages*6)+k]];
			}
			
			[i2cWriteArray addObject:tempWriteArray];//in Sammelarray fuer die Arrays der Reports	
			
			//			[writeEEPROMDic setObject:i2cWriteArray forKey:@"i2ceepromarray"];
			//			[nc postNotificationName:@"i2ceepromwrite" object:self userInfo:writeEEPROMDic];
			NSLog(@"Data writeEEPROM   i2cWriteArray: %@  anz: %d",[i2cWriteArray description],[i2cWriteArray count]);		
			
		}
		
		
		int i;
		for (i=0;i< [i2cWriteArray count];i++)
		{
			//NSLog(@"i2cWriteArray index: %d Object: %@",i,[[i2cWriteArray objectAtIndex:i]description]);
			
		}
		[Adresse setStringValue:[i2cWriteArray componentsJoinedByString:@" "]];
		
		// Dic fuer userInfo: Array und Zaehler
		//[self setI2CStatus:1];
		
		NSMutableDictionary* infoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[infoDic setObject:i2cWriteArray forKey:@"reportarray"];
		[infoDic setObject:[NSNumber numberWithInt:0] forKey:@"reportnummer"];
		//NSLog(@"WriteEEPROM Start Timer:  Anz Reports: %d",[i2cWriteArray count]);
		
		// Timer fuer das Senden der Reports
		
		NSDate *now = [[NSDate alloc] init];
		NSTimer* WriteTimer =[[NSTimer alloc] initWithFireDate:now
													  interval:0.03
														target:self 
													  selector:@selector(WriteEEPROMFunktion:) 
													  userInfo:infoDic
													   repeats:YES];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:WriteTimer forMode:NSDefaultRunLoopMode];
		
			
		
	}//	anz>3
	return writeErr;
}

- (void)WriteEEPROMFunktion:(NSTimer*) derTimer;
{
	if ([[derTimer userInfo] objectForKey:@"reportarray"])
	{
		
		NSArray* i2cWriteArray=[[derTimer userInfo] objectForKey:@"reportarray"];
		//NSLog(@"WriteEEPROMFunktion i2cWriteArray : %@",[i2cWriteArray description]);
		int ReportNummer=[[[derTimer userInfo] objectForKey:@"reportnummer"]intValue];
		if (ReportNummer==0)
		{
			[self setI2CStatus:1];
		}
		
		if (ReportNummer<[i2cWriteArray count])
		{
			//NSLog(@"WriteEEPROMFunktion ReportNummer: %d",ReportNummer);
			NSMutableDictionary* writeEEPROMDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];		
			[writeEEPROMDic setObject:[i2cWriteArray objectAtIndex:ReportNummer]forKey:@"i2ceepromarray"];
			//NSLog(@"WriteEEPROMFunktion [i2cWriteArray objectAtIndex:ReportNummer]: %@",[[i2cWriteArray objectAtIndex:ReportNummer] description]);
			[nc postNotificationName:@"i2ceepromwrite" object:self userInfo:writeEEPROMDic];
			
			ReportNummer++;
			if (ReportNummer<[i2cWriteArray count])
			{
				[[derTimer userInfo] setObject:[NSNumber numberWithInt:ReportNummer]forKey:@"reportnummer"];
			}
			else
			{
				if ([derTimer isValid])
				{
					NSLog(@"WriteEEPROMFunktion Tag fertig: Timer invalidate");
					
					[derTimer invalidate];
					//				[self setI2CStatus:0];
					//				[derTimer release];				
				}
				
			}
		}
		
		
		
	}
	else
	{
		
		[derTimer invalidate];
	}
	
	
}	


- (IBAction)writeTagplan:(id)sender
{
	NSMutableArray* tempTagplanArray=[[NSMutableArray alloc]initWithCapacity:0];
	int TagPopIndex=[TagPop indexOfSelectedItem];
	
	NSLog(@"writeTagplan: Tag: %d",TagPopIndex);
	rHeizungplan* tempTagplan=[[Datenplan objectAtIndex:TagPopIndex]objectForKey:@"Heizung"];
	NSArray* tempKesselStundenplanArray=[tempTagplan BrennerStundenArrayForKey:@"kessel"];
	NSArray* tempTagStundenplanArray=[tempTagplan BrennerStundenArrayForKey:@"modetag"];
	NSArray* tempNachtStundenplanArray=[tempTagplan BrennerStundenArrayForKey:@"modenacht"];
	
	int i;
	for (i=0;i<24;i++)
	{
		int hexKesselWert=[[tempKesselStundenplanArray objectAtIndex:i]intValue]<<6;//Bit 6,7
		int hexTagWert=[[tempTagStundenplanArray objectAtIndex:i]intValue]<<4;// Bit 4,5
		hexTagWert &=0x30;
		int hexNachtWert=[[tempNachtStundenplanArray objectAtIndex:i]intValue]<<2;//Bit 2,3
		hexNachtWert &=0x0C;
		int hexWert= hexKesselWert + hexTagWert + hexNachtWert;
		NSLog(@"writeTagplan i: %d   hexKesselWert: %02X   hesTagWert %02X   hexNachtWert: %02X    hexWert: %02X",i,hexKesselWert, hexTagWert, hexNachtWert, hexWert);
		[tempTagplanArray addObject:[NSNumber numberWithInt:hexWert]];
		
	}
	//NSLog(@"writeTagplan: tempIOWTagplanArray: %@ Anzahl: %d",[tempIOWTagplanArray description],[tempIOWTagplanArray count]);
	//NSLog(@"writeTagplan: tempIOWTagplanArray Anzahl: %d",[tempTagplanArray count]);
	
	//	[self setI2CStatus:1];
	[self writeEEPROM:0xA0 anAdresse:TagPopIndex*0x20 mitDaten: tempTagplanArray];
	[self setI2CStatus:0];
	
	
	
	
}

- (void)writeWocheFunktion:(NSTimer*) derTimer
{
	NSLog(@"writeWocheFunktion");
	NSMutableDictionary* tempInfoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	
	if ([derTimer userInfo])
	{
		tempInfoDic=(NSMutableDictionary*)[derTimer userInfo];
		aktuellerTag=[[tempInfoDic objectForKey:@"tag"]intValue];
	}
	NSLog(@"writeWocheFunktion aktuellerTag: %d",aktuellerTag);
	if (aktuellerTag==0)
	{
		[self setI2CStatus:1];
	}
	NSMutableArray* tempTagplanArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA",@"SO",nil];
	[TagPop selectItemAtIndex:aktuellerTag];
	NSString* Tag=[Wochentage objectAtIndex: aktuellerTag];
	int I2CIndex=0;//					[I2CPop indexOfSelectedItem];
	NSString* EEPROM_i2cAdresse=[I2CPop itemTitleAtIndex:I2CIndex];
	AnzahlDaten=0x20;
	int i2cadresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresse];
	
	if ([theScanner scanHexInt:&i2cadresse])
	{
		//NSLog(@"writeWocheFunktion: EEPROM_i2cAdresse string: %@ int: %x	",EEPROM_i2cAdresse,i2cadresse);
		
	}
	//NSLog(@"writeWocheFunktion: EEPROM_i2cAdresse: %x tagIndex: %d MemAdresse: %x",i2cadresse, aktuellerTag,aktuellerTag*0x20);
	//IOW_busy=1;
	rHeizungplan* aktuellerTagplan=[[Datenplan objectAtIndex:aktuellerTag]objectForKey:@"Heizung"];
	NSArray* tempKesselStundenplanArray=[aktuellerTagplan BrennerStundenArrayForKey:@"kessel"];
	NSArray* tempTagStundenplanArray=[aktuellerTagplan BrennerStundenArrayForKey:@"modetag"];
	NSArray* tempNachtStundenplanArray=[aktuellerTagplan BrennerStundenArrayForKey:@"modenacht"];
	
	//NSLog(@"writeWocheFunktion Tag: %@: aktuellerStundenplan: %@",[Wochentage objectAtIndex:aktuellerTag],[aktuellerStundenplan description]);
	if ([tempKesselStundenplanArray count])
	{
		int i;
		for (i=0;i<24;i++)
		{
			if (i<[tempKesselStundenplanArray count])
			{
				int hexKesselWert=[[tempKesselStundenplanArray objectAtIndex:i]intValue]<<6;//Bit 6,7
				int hexTagWert=[[tempTagStundenplanArray objectAtIndex:i]intValue]<<4;// Bit 4,5
				hexTagWert &=0x30;
				int hexNachtWert=[[tempNachtStundenplanArray objectAtIndex:i]intValue]<<2;//Bit 2,3
				hexNachtWert &=0x0C;
				int hexWert= hexKesselWert + hexTagWert + hexNachtWert;
				//				NSLog(@"writeTagplan i: %d   hexKesselWert: %02X   hesTagWert %02X   hexNachtWert: %02X    hexWert: %02X",i,hexKesselWert, hexTagWert, hexNachtWert, hexWert);
				
				
				[tempTagplanArray addObject:[NSNumber numberWithInt:hexWert]];
				NSLog(@"writeTagplan: i: %d Wert: %02X",i,hexWert);
			}
			else // leere Werte
			{
				//[tempIOWTagplanArray addObject:@"0"];
				[tempTagplanArray addObject:[NSNumber numberWithInt:0x08]];
			}
			
		}//for i
		
		[self writeEEPROM:i2cadresse anAdresse:aktuellerTag*0x20 mitDaten:tempTagplanArray];
		
		
		if (aktuellerTag==6)
		{
			
			[IOWTimer invalidate];
			[self setI2CStatus:0];
			NSLog(@"writeWocheFunktion: Timer Schluss");
			//[TagPop selectItemAtIndex:0];
		}
		else
		{
			aktuellerTag++;
			[tempInfoDic setObject:[NSNumber numberWithInt:aktuellerTag] forKey:@"tag"];
			
		}
		
	}//if count
}


- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
//NSLog(@"shouldSelectTabViewItem: %@ Identifier: %d",[tabViewItem label],[[tabViewItem identifier]intValue]);
if ([[tabViewItem identifier]intValue]==1)
{
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		NSMutableDictionary* BalkendatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[BalkendatenDic setObject:[NSNumber numberWithInt:1]forKey:@"aktion"];
//		[nc postNotificationName:@"StatistikDaten" object:NULL userInfo:BalkendatenDic];

}

if ([[tabViewItem identifier]intValue]==3)
{
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		NSMutableDictionary* BalkendatenDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[BalkendatenDic setObject:[NSNumber numberWithInt:3]forKey:@"aktion"];
//		[nc postNotificationName:@"SolarStatistikDaten" object:NULL userInfo:BalkendatenDic];

}

   

//return YES;
}








-(BOOL)windowShouldClose:(id)sender
{
	//NSLog(@"Data windowShouldClose");
    return YES;
}


@end

