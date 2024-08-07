//
//  rHomeData.m
//  Downloader
//
//  Copyright (c) 2003 Apple Computer, Inc. Alldownloadpause rights reserved.
//

#import "rHomeData.h"

//enum downloadflag{downloadpause, heute, last, datum}homedownloadFlag;
enum downloadflag{downloadpause, heute, last, datum}downloadFlag;


@implementation rHomeData

- (void)setErrString:(nonnull NSString*)derErrString
{
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:derErrString forKey:@"err"];
	//NSLog(@"setErrString: errString: %@",derErrString);
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"errstring" object:self userInfo:NotificationDic];
}

- (id)init
{
 	self = [super initWithWindowNibName:@"HomeData"];
	//NSLog(@"HomeData init");
	DownloadPfad = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/TempDaten"];
	
   ServerPfad =@"https://www.ruediheimlicher.ch/Data";
//   ServerPfad =@"https://www.ruediheimlicher.ch/Data";
	
   
   
	DataSuffix=[NSString string];
	prevDataString=[NSString string];
	downloadFlag=downloadpause;
	lastDataZeit=0;
	HomeCentralData = [[NSMutableData alloc]initWithCapacity:0];
	
	// Solar
	lastSolarDataZeit=0;
	SolarDataSuffix=[NSString string];
	prevSolarDataString=[NSString string];

   // Strom
   lastStromDataZeit=0;
   StromDataSuffix=[NSString string];
   prevStromDataString=[NSString string];
  
   
	NSNotificationCenter * nc;
	nc=[NSNotificationCenter defaultCenter];
	
	[nc addObserver:self
			 selector:@selector(DatenVonHeuteAktion:)
				  name:@"datenvonheute"
				object:nil];
	
	[nc addObserver:self
			 selector:@selector(EEPROMUpdateAktion:)
				  name:@"EEPROMUpdate"
				object:nil];
	
   [nc addObserver:self
          selector:@selector(LocalStatusAktion:)
              name:@"localstatus"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(TestStatusAktion:)
              name:@"teststatus"
            object:nil];

   

	
	return self;
}

- (int)tagdesjahresvonJahr:(int)jahr Monat:(int)monat Tag:(int)tag
{
   // http://stackoverflow.com/questions/7664786/generate-nsdate-from-day-month-and-year
   NSCalendar *tagcalendar = [NSCalendar currentCalendar];
   NSDateComponents *components = [[NSDateComponents alloc] init];
   [components setDay:tag];
   [components setMonth:monat];
   [components setYear:jahr];
   NSDate *tagdatum = [tagcalendar dateFromComponents:components];
   //NSLog(@"tagdatum: %@",[tagdatum description]);
   NSCalendar *gregorian =[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   int dayOfYear =(int)[gregorian ordinalityOfUnit:NSCalendarUnitDay
                                       inUnit:NSCalendarUnitYear forDate:tagdatum];
   
   return dayOfYear;
}

- (NSDate*)DatumvonJahr:(int)jahr Monat:(int)monat Tag:(int)tag
{
   // http://stackoverflow.com/questions/7664786/generate-nsdate-from-day-month-and-year
   NSCalendar *tagcalendar = [NSCalendar currentCalendar];
   NSDateComponents *components = [[NSDateComponents alloc] init];
   [components setDay:tag];
   [components setMonth:monat];
   [components setYear:jahr];
   NSDate *tagdatum = [tagcalendar dateFromComponents:components];
   //NSLog(@"tagdatum: %@",[tagdatum description]);
   NSCalendar *gregorian =[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   int dayOfYear =(int)[gregorian ordinalityOfUnit:NSCalendarUnitDay
                                            inUnit:NSCalendarUnitYear forDate:tagdatum];
   return tagdatum;
}

NSUInteger dayOfYearForDate(NSDate *dasDatum)
{
   NSTimeZone *gmtTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
   NSCalendar *calendar = [[NSCalendar alloc]
                           initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
   [calendar setTimeZone:gmtTimeZone];
   
   NSUInteger day = [calendar ordinalityOfUnit:NSCalendarUnitDay
                                        inUnit:NSCalendarUnitYear forDate:dasDatum];
   return day;
}



-(void)awakeFromNib
{
//NSLog(@"HomeData awake");
//DownloadPfad = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/TempDaten"]retain];
//[ServerPfad retain];
//NSLog(@"DownloadPfad: %@",DownloadPfad);

/*
//[Kalender setCalendar:[NSCalendar currentCalendar]];
[Kalender setDateValue: [NSDate date]];
NSString* PickDate=[[Kalender dateValue]description];
//NSLog(@"PickDate: %@",PickDate);
NSDate* KalenderDatum=[Kalender dateValue];
//NSLog(@"Kalenderdatum: %@",KalenderDatum);
NSArray* DatumStringArray=[PickDate componentsSeparatedByString:@" "];
//NSLog(@"DatumStringArray: %@",[DatumStringArray description]);

NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
NSString* SuffixString=[NSString stringWithFormat:@"/HomeDaten/HomeDaten%@%@%@",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
//NSLog(@"DatumArray: %@",[DatumArray description]);
//NSLog(@"SuffixString: %@",SuffixString);
//NSLog(@"tag: %d jahr: %d",tag,jahr);
NSString* tempURLString= [[[URLPop itemAtIndex:0]title]stringByAppendingString:SuffixString];
tempURLString= [tempURLString stringByAppendingString:@".txt"];

//NSLog(@"tempURLString: %@",tempURLString);
//NSLog(@"DatumSuffixVonDate: %@",[self DatumSuffixVonDate:[Kalender dateValue]]);

[URLField setStringValue: tempURLString];

//NSString* AktuelleDaten=[self DataVonHeute];

//NSLog(@"AktuelleDaten: \n%@",AktuelleDaten);
//NSString* LastDaten=[self LastData];
*/




}


- (NSString*)DatumSuffixVonDate:(nonnull NSDate*)dasDatum
{
	NSArray* DatumStringArray=[[dasDatum description]componentsSeparatedByString:@" "];
	//NSLog(@"DatumStringArray: %@",[DatumStringArray description]);
	NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
	NSString* SuffixString=[NSString stringWithFormat:@"%@%@%@",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
	//NSLog(@"DatumArray: %@",[DatumArray description]);
	//NSLog(@"SuffixString: %@",SuffixString);
	return SuffixString;
}

- (int)lastDataZeitVon:(NSString*)derDatenString
{
	int lastZeit=0;
	//NSLog(@"DataString: %@",derDatenString);
	
	NSArray* DataArray=[derDatenString componentsSeparatedByString:@"\n"];
	if ([[DataArray lastObject]isEqualToString:@""])
	{
		DataArray=[DataArray subarrayWithRange:NSMakeRange(0,[DataArray count]-1)];
	}
	//NSLog(@"DataArray: %@",[DataArray description]);
	
	//NSLog(@"lastDataZeitVon: letzte Zeile: %@",[DataArray lastObject]);
	NSArray* lastZeilenArray=[[DataArray lastObject]componentsSeparatedByString:@"\t"];
	lastZeit = [[lastZeilenArray objectAtIndex:0]intValue];
	
	return lastZeit;
}


- (void)DatenVonHeuteAktion:(NSNotification*)note
{
	NSLog(@"HomeData DatenVonHeuteAktion");
	//[self DataVonHeute];

}


- (NSString*)DataVonHeute
{
	NSString* returnString=[NSString string];
	if (isDownloading) 
	{
		[self cancel];
	} 
	else 
	{
 
		//NSArray* BrennerdatenArray = [self BrennerStatistikVonJahr:2010 Monat:0];
		//NSLog(@"BrennerdatenArray: %@",[BrennerdatenArray description]);
		
      //NSString *ipString = [NSString localizedStringWithFormat:@"do shell script \"ping -c 2 www.apple.com\""];
     NSString *ipString = [NSString localizedStringWithFormat:@"do shell script \"ping -c 2 8.8.8.8\""];
      
      NSAppleScript *ipscript = [[NSAppleScript alloc] initWithSource:ipString];
      NSDictionary *iperrorMessage = nil;
      //NSLog(@"HomeData DataVonHeute  vor execute");
      NSAppleEventDescriptor *ipresult = [ipscript executeAndReturnError:&iperrorMessage];
      //NSLog(@"HomeData DataVonHeute  nach execute");
      NSLog(@"mount: %@",ipresult);
      NSString *scriptReturn = [ipresult stringValue];
      NSLog(@"HomeData DataVonHeute Found ping string: %@",scriptReturn);

      if (scriptReturn == nil)
      {
         NSAlert *Warnung = [[NSAlert alloc] init];
         [Warnung addButtonWithTitle:@"OK"];
         NSString* MessageText= NSLocalizedString(@"Netz-Zugang",@"Verbindung misslungen");
         [Warnung setMessageText:[NSString stringWithFormat:@"%@ \n%@",@"DataVonHeute:",MessageText]];
         
         
         NSString* s1=@"Kein Web. Lokals Netz";
         NSString* InformationString=[NSString stringWithFormat:@"Comment: %@",s1];
         [Warnung setInformativeText:InformationString];
         [Warnung setAlertStyle:NSAlertStyleWarning];

         long antwort=[Warnung runModal];

         return returnString;
      }
      
      //NSString * localipString = [NSString localizedStringWithFormat:@"do shell script \"ping -c 2 192.168.1.212\""];
      
      
		DataSuffix=@"HomeDaten.txt";
		
      //NSString* URLPfad=[[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]]path];
		//NSLog(@"DataVonHeute URLPfad: %@",URLPfad);
		//NSLog(@"DataVonHeute  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
      //NSLog(@"awake DataVonHeute URL: %@",URL);
		NSStringEncoding *  enc=0;
		NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
		NSError* WebFehler=NULL;
      
      if (localNetz == YES)
         {
 //           return returnString;
         }
		NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
		//NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
		if (WebFehler)
		{
			//NSLog(@"WebFehler: :%@",[[WebFehler userInfo]description]);
			
			//NSLog(@"WebFehler in DataForHeute: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
			//ERROR: 503
			NSArray* ErrorArray=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]componentsSeparatedByString:@" "];
         NSString* ErrString =[ErrorArray componentsJoinedByString:@" "];
      //   NSLog(@"ErrString: %@",ErrString);
         NSRange  ErrRange = [ErrString rangeOfString:@"offline" options:NSCaseInsensitiveSearch];
         
			//NSLog(@"DataVonHeute ErrorArray: %lu",(unsigned long)ErrRange.location);
        // if ([ErrorArray containsObject:@"offline.\""])
         if (ErrRange.location < NSNotFound)
         {
            NSLog(@"offline");
         }
         
			NSAlert *Warnung = [[NSAlert alloc] init];
			[Warnung addButtonWithTitle:@"OK"];
			//	[Warnung addButtonWithTitle:@""];
			//	[Warnung addButtonWithTitle:@""];
			//	[Warnung addButtonWithTitle:@"Abbrechen"];
			NSString* MessageText= NSLocalizedString(@"HomeData Error in Download",@"Download misslungen");
			[Warnung setMessageText:[NSString stringWithFormat:@"%@ \n%@",@"DataVonHeute ",MessageText]];
			
			NSString* s1=[NSString stringWithFormat:@"URL: \n%@",URL];
         
			NSString* s2=[ErrorArray objectAtIndex:2];
			int AnfIndex=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]rangeOfString:@"\""].location;
			NSString* s3=@"Offline";//[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]substringFromIndex:AnfIndex];
         //NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
			NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
			[Warnung setInformativeText:InformationString];
         [Warnung setAlertStyle:NSAlertStyleWarning];
			
	//		int antwort=[Warnung runModal];
   //      NSLog(@"DataVonHeute antwort: %d",antwort);
			return returnString;
         
		}
      
		if ([DataString length])
		{
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				//NSLog(@"DataVonHeute: String korrigieren");
				DataString=[DataString substringFromIndex:1];
			}
         
         
         
			//NSLog(@"DataVonHeute DataString: \n%@",DataString);
			lastDataZeit=[self lastDataZeitVon:DataString];
			//NSLog(@"DataVonHeute lastDataZeit: %d",lastDataZeit);
         
         
 
         
			
			// Auf WindowController Timer auslösen
			downloadFlag=heute;
			//NSLog(@"DataVonHeute downloadFlag: %d",downloadFlag);
			NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
         [NotificationDic setObject:[NSNumber numberWithInt:0] forKey:@"quelle"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
         //NSLog(@"DataVonHeute NotificationDic: %@",NotificationDic);
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
			//NSLog(@"Daten OK");
			
			return DataString;
			
		}
		else
		{
			NSLog(@"Keine Daten");
			[self setErrString:@"DataVonHeute: keine Daten"];
		}
		
		/*
		 NSLog(@"DataVon URL: %@ DataString: %@",URL,DataString);
		 if (URL) 
		 {
		 download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
		 downloadFlag=heute;
		 
		 }
		 if (!download) 
		 {
		 
		 NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
		 @"The entered URL is either invalid or unsupported.");
		 }
		 */
	}
	return returnString;
}


- (NSString*)DataVon:(NSDate*)dasDatum
{
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	if (isDownloading) 
	{
		[self cancel];
	} 
	else 
	{
		
		NSArray* DatumStringArray=[[dasDatum description]componentsSeparatedByString:@" "];
		// NSArray* DatumStringArray=[[[NSDate date] description]componentsSeparatedByString:@" "];
		//NSLog(@"DataVon DatumStringArray: %@",[DatumStringArray description]);
		
		NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
		//NSString* SuffixString=[NSString stringWithFormat:@"/HomeDaten/HomeDaten%@%@%@.txt",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
		NSLog(@"DataVon DatumArray: %@",[DatumArray description]);
		//NSLog(@"DataVon SuffixString: %@",SuffixString);
		
		DataSuffix=[NSString stringWithFormat:@"/HomeDaten/%@/HomeDaten%@%@%@.txt",[DatumArray objectAtIndex:0],[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
		NSLog(@"DataSuffix: %@",DataSuffix);
		//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:@"HomeDaten.txt"]];
		//NSLog(@"DataVon URLPfad: %@",URLPfad);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSLog(@"DataVon 1");
		
		NSString* DataString=[NSString stringWithContentsOfURL:URL encoding:NSMacOSRomanStringEncoding error:NULL];
		NSLog(@"DataVon... laden von URL: %@",URL);
		//NSLog(@"DataVon... laden von URL: %@ DataString: %@",URL,DataString);
		
		if (DataString)
		{
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				DataString=[DataString substringFromIndex:1];
			}
			NSLog(@"DataVon DataString: %@",DataString);
			lastDataZeit=[self lastDataZeitVon:DataString];
			//NSLog(@"downloadDidFinish lastDataZeit: %d",lastDataZeit);
			//NSLog(@"downloadDidFinish downloadFlag: %d",downloadFlag);
			
			downloadFlag=datum;
			
			//NSLog(@"Data von: %@ OK",DataString);
			// Auf WindowController Timer stoppen, Diagramm leeren 
			NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
			
			return DataString;
			
			
		}
		else
		{
			DataString=@"Error";
			NSLog(@"DataVon: DataSuffix: %@",URL);
			[self setErrString:[NSString stringWithFormat:@"%@ %@ %@",[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2],@"DataVon: keine Daten"]];
			return DataString;

		}

		if (URL)
		{
			NSURLRequest* URLReq=[NSURLRequest requestWithURL:URL ];
			if (URLReq)
			{
             
				//download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
				
            
            download = [[WebDownload alloc] initWithRequest:URLReq delegate:self];
				//NSLog(@"DataVon 2");
				
				
				downloadFlag=datum;
				
			}
			else
			{
				NSLog(@"NSURLReq nicht korrekt.");
			}
			
		}
		if (!download) 
		{
			
			NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
									@"The entered URL is either invalid or unsupported.");
		}
	}
	return NULL;

}



// substringFrom pruefen:
- (NSString*)LastData
{
	//NSLog(@"LastData");
	NSString* returnString = [NSString string];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	DataSuffix=@"LastData.txt";
	downloadFlag=last;
	
	if (isDownloading) 
	{
		[NotificationDic setObject:@"busy" forKey:@"erfolg"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
		[self cancel];
	} 
	else 
	{
		[[NSURLCache sharedURLCache] setMemoryCapacity:0]; 
		[[NSURLCache sharedURLCache] setDiskCapacity:0]; 
		//	WebPreferences *prefs = [webView preferences]; 
		//[prefs setUsesPageCache:NO]; 
		//[prefs setCacheModel:WebCacheModelDocumentViewer];
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSLog(@"LastData: URL: %@",URL);
		[NotificationDic setObject:@"ready" forKey:@"erfolg"];
		NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
		
		//NSURLRequestUseProtocolCachePolicy
		NSDate* ZeitVor=[NSDate date]; // Beginn markieren
		NSError* WebFehler;
		int NSURLRequestReloadIgnoringLocalCacheData = 1;
		int NSURLRequestReloadIgnoringLocalAndRemoteCacheData=4;
		//		NSString* URLString = [NSString stringWithFormat:@"%@/HomeCentralPrefs.txt",ServerPfad];
		
		
		
      
      
//      NSURL *lastTimeURL = [NSURL URLWithString:@"https://www.ruediheimlicher.ch/Data/HomeCentralPrefs.txt"];
		NSURL *lastTimeURL = [NSURL URLWithString:@"https://www.ruediheimlicher.ch/Data/HomeCentralPrefs.txt"];
      
      
		//NSURLRequest* lastTimeRequest=[ [NSURLRequest alloc] initWithURL: lastTimeURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
		NSMutableURLRequest* lastTimeRequest=[ [NSMutableURLRequest alloc] initWithURL: lastTimeURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5.0];
      NSURLResponse* responseRequest;
		//NSLog(@"Cache mem: %d",[[NSURLCache sharedURLCache]memoryCapacity]);
		
	
		//[[NSURLCache sharedURLCache] removeCachedResponseForRequest:lastTimeRequest];

		NSError* syncErr=NULL;
		NSData* lastTimeData=[ NSURLConnection sendSynchronousRequest:lastTimeRequest returningResponse: &responseRequest error: &syncErr ];
      
      
      
//      NSLog(@"responseRequest: *%@*",responseRequest.URL);
		if (syncErr)
		{
			NSLog(@"LastData syncErr: :%@",syncErr);
			//ERROR: 503
		}
		NSString *lastTimeString = [[NSString alloc] initWithBytes: [lastTimeData bytes] length:[lastTimeData length] encoding: NSUTF8StringEncoding];
		//NSLog(@"lastTimeString: %@",lastTimeString);
		NSStringEncoding *  enc=0;//NSUTF8StringEncoding;
		//NSString* lastTimeString=[NSString stringWithContentsOfURL:lastTimeURL usedEncoding: enc error:NULL];
		//[lastTimeString retain];
		//NSString* newlastTimeString=[NSString stringWithContentsOfURL:lastTimeURL usedEncoding: enc error:NULL];
		//NSLog(@"newlastTimeString: %@",newlastTimeString);
		//if ([newlastTimeString length] < 7)
		//{
		//	NSLog(@"newlastTimestring zu kurz");
		//	
		//}
		
		if ([lastTimeString length] < 7)
		{
			NSLog(@"LastData lastTimestring zu kurz: %@",lastTimeString);
			return returnString;
		}
		
		NSString* lastDatumString = [lastTimeString substringFromIndex:7];
	//	NSLog(@"lastData: lastDatumString: %@",lastDatumString);
		[NotificationDic setObject:lastDatumString forKey:@"lasttimestring"];
		
				
		
		//NSString* aStr;
		//aStr = [[NSString alloc] initWithData:aData encoding:NSASCIIStringEncoding];

		
		HomeCentralRequest = [ [NSURLRequest alloc] initWithURL: URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
		int delta=[[NSDate date] timeIntervalSinceDate:ZeitVor];
		//NSLog(@"Delta: %2.4F", delta);
		[NotificationDic setObject:[NSNumber numberWithFloat:delta] forKey:@"delta"];
		
		//HomeCentralData = [[NSURLConnection alloc] initWithRequest:HomeCentralRequest delegate:self];
		HomeCentralData = (NSMutableData*)[ NSURLConnection sendSynchronousRequest:HomeCentralRequest returningResponse: &responseRequest error: nil ];
		
		if (HomeCentralData==NULL)
		{
			NSLog(@"LastData: Fehler beim Download:_ Data ist NULL");
			[NotificationDic setObject:@"Fehler beim Download" forKey:@"err"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
			return NULL;
		}
		NSString *DataString = [[NSString alloc] initWithBytes: [HomeCentralData bytes] length:[HomeCentralData length] encoding: NSUTF8StringEncoding];
		
		
		//		NSString* DataString= [NSString stringWithContentsOfURL:URL];
		
		if ([DataString length])
		{
			//NSLog(@"LastData: DataString: %@",DataString);
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				DataString=[DataString substringFromIndex:1];
			}
			//NSLog(@"LastData DataString: %@", DataString);
         
         
			NSMutableArray* tempDataArray = (NSMutableArray*)[DataString componentsSeparatedByString:@"\t"];
  //       NSLog(@"LastData tempDataArray vor: %@", tempDataArray);
	//		NSLog(@"lastData tempDataArray 9: %d",[[tempDataArray objectAtIndex:9 ]intValue]);
         int wert9 = [[tempDataArray objectAtIndex:9 ]intValue];
         [tempDataArray replaceObjectAtIndex:9 withObject:[NSNumber numberWithInt:wert9/2]];
         int wert10 = [[tempDataArray objectAtIndex:10 ]intValue];
         [tempDataArray replaceObjectAtIndex:10 withObject:[NSNumber numberWithInt:wert10/2]];
         int wert11 = [[tempDataArray objectAtIndex:11 ]intValue];
         [tempDataArray replaceObjectAtIndex:11 withObject:[NSNumber numberWithInt:wert11/2]];
          
         DataString = [tempDataArray  componentsJoinedByString:@"\t"];
          
 //        NSLog(@"LastData tempDataArray nach: %@", tempDataArray);
			NSArray* prevDataArray = [prevDataString componentsSeparatedByString:@"\t"];
         uint8_t checksum = 0;
         for (int i=0;i<[prevDataArray count];i++)
         {
            checksum += ([[prevDataArray objectAtIndex:i]intValue] & 0xFF);
         }
    //     NSLog(@"checksum: %d", checksum);
			if ([prevDataArray count]>3)
			{
				float prevVorlauf=[[prevDataArray objectAtIndex:1]floatValue];
				float prevRuecklauf=[[prevDataArray objectAtIndex:2]floatValue];

				float lastVorlauf=[[tempDataArray objectAtIndex:1]floatValue];
				float lastRuecklauf=[[tempDataArray objectAtIndex:2]floatValue];
				float VorlaufQuotient=lastVorlauf/prevVorlauf;
				float RuecklaufQuotient=lastRuecklauf/prevRuecklauf;
									
								
				//NSLog(@"LastData prevVorlauf: %2.2f lastVorlauf: %2.2f \tprevRuecklauf: %2.2f lastRuecklauf: %2.2f",prevVorlauf, lastVorlauf, prevRuecklauf, lastRuecklauf);

				//NSLog(@"\nVorlaufQuotient: %2.3f \nRuecklaufQuotient: %2.3f\n",VorlaufQuotient,RuecklaufQuotient);
				if (VorlaufQuotient < 0.75 || RuecklaufQuotient < 0.75)
				{	
					NSLog(@"** Differenz **");
					NSLog(@"LastData: prevDataString: %@ lastDataString: %@ ",prevDataString,DataString);
					//NSLog(@"LastData: lastDataString: %@",DataString);
					NSLog(@"LastData \nprevVorlauf: %2.2f lastVorlauf: %2.2f \nprevRuecklauf: %2.2f lastRuecklauf: %2.2f\n",prevVorlauf, lastVorlauf, prevRuecklauf, lastRuecklauf);
					NSLog(@"\nVorlaufQuotient: %2.3f   RuecklaufQuotient: %2.3f\n",VorlaufQuotient,RuecklaufQuotient);
					lastVorlauf = prevVorlauf;
					lastRuecklauf=prevRuecklauf;
					int i=0;
					// Alle Objekte ausser Zeit durch Elemente von prevDataArray ersetzen
					for (i=1;i< [tempDataArray count];i++) 
					{
						[tempDataArray replaceObjectAtIndex:i withObject:[prevDataArray objectAtIndex:i]];
						
						DataString = [tempDataArray componentsJoinedByString:@"\t"];
						
					}
					//NSLog(@"tempDataArray: %@ DataString: %@",[tempDataArray description],DataString);
					//DataString=prevDataString;
				}
			
			}


			prevDataString= [DataString copy];
			
			lastDataZeit=[self lastDataZeitVon:DataString];
			//NSLog(@"lastDataZeit: %d",lastDataZeit);
   //      NSLog(@"LastData DataString: %@", DataString);
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
			[NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"quelle"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
			
			HomeCentralRequest = NULL;
			return DataString;
		}
		else
		{
			//NSLog(@"lastData: kein String");
			[self setErrString:@"lastData: kein String"];
			
		}
		//NSLog(@"LastData: ");
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
		

	}
	
	return returnString;
}


-(void)setPumpeLeistungsfaktor:(float)faktor
{
   pumpeleistungsfaktor = faktor;
   
}

-(void)setElektroLeistungsfaktor:(float)faktor
{
   elektroleistungsfaktor = faktor;
   
}


-(void)setFluidLeistungsfaktor:(float)faktor
{
   fluidleistungsfaktor = faktor;
   
}

- (void)LocalStatusAktion:(NSNotification*)note
{
   NSLog(@"HomeData LocalStatusAktion note: %@",[[note userInfo]description]);
   localNetz = YES;
}

- (void)TestStatusAktion:(NSNotification*)note
{
   NSLog(@"HomeData TestStatusAktion note: %@",[[note userInfo]description]);
   
   if ([[note userInfo]objectForKey:@"test"] && [[[note userInfo]objectForKey:@"test"]intValue]==1) // URL umschalten
   {
      //    HomeCentralURL = @"http://192.168.1.212:5000";
      //NSLog(@"TestStatusAktion local: HomeCentralURL: %@",HomeCentralURL);
   }
   else
   {
 //     HomeCentralURL = @"http://ruediheimlicher.dyndns.org";
      //NSLog(@"TestStatusAktion global: HomeCentralURL: %@",HomeCentralURL);
   }
 //  NSLog(@"TestStatusAktion HomeCentralURL: %@",HomeCentralURL);
}


- (NSString*)Router_IP
{
   
//   NSString* extip = curl ifconfig.me/ip
	NSMutableArray* ErtragdatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSLog(@"Router_IP");
	NSString*IP_DataSuffix=@"ip.txt";
   NSString* dataURLString=[@"https://ruediheimlicher.ch/Data" stringByAppendingPathComponent:IP_DataSuffix];

  // NSURL* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:IP_DataSuffix]];
   NSURL* ipURL=[NSURL URLWithString:[dataURLString stringByAppendingPathComponent:IP_DataSuffix]];
                        
	//NSLog(@"Router_IP URLPfad: %@",URLPfad);
   //NSLog(@"Router_IP ServerPfad: %@",ServerPfad);
   NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:IP_DataSuffix]];
	//NSLog(@"Router_IP URL: %@",URL );
   //NSLog(@"Router_IP URL Pfad: %@",[URL path]);
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
   
   NSURL* dataURL =   [NSURL URLWithString:dataURLString];
   
	NSString* DataString=[NSString stringWithContentsOfURL:dataURL usedEncoding: enc error:NULL];
	//NSLog(@"IP von Server: %@",DataString);
   NSArray* IP_Array = [DataString componentsSeparatedByString:@"\r\n"];
   //NSLog(@"IP von Server IP_Array: %@",IP_Array);
   
   NSString *ipString = [NSString localizedStringWithFormat:@"do shell script \"curl -4 ident.me\""];
   
   NSAppleScript *ipscript = [[NSAppleScript alloc] initWithSource:ipString];
   NSDictionary *iperrorMessage = nil;
   NSAppleEventDescriptor *ipresult = [ipscript executeAndReturnError:&iperrorMessage];
   //NSLog(@"mount: %@",ipresult);
   NSString *scriptReturn = [ipresult stringValue];
   //NSLog(@"HomeData Found utxt string: %@",scriptReturn);
   if (scriptReturn == NULL)
   {
      NSAlert *Warnung = [[NSAlert alloc] init];
      [Warnung addButtonWithTitle:@"OK"];
      //   [Warnung addButtonWithTitle:@""];
      //   [Warnung addButtonWithTitle:@""];
      //   [Warnung addButtonWithTitle:@"Abbrechen"];
      NSString* MessageText= NSLocalizedString(@"No IP",@"Verbindung misslungen");
      [Warnung setMessageText:[NSString stringWithFormat:@"%@ \n%@",@"AVR awake",MessageText]];
      
      
      NSString* s1=@"Kein Netz";
      NSString* InformationString=[NSString stringWithFormat:@"Fehler: %@",s1];
      [Warnung setInformativeText:InformationString];
      [Warnung setAlertStyle: NSAlertStyleWarning];
      
      int antwort=[Warnung runModal];
      NSLog(@"Connection: %d",antwort);
      return 0;
   }
   NSError* err;
   /*
    NSString *ipString = [NSString localizedStringWithFormat:@"do shell script \"curl ident.me\""];
    
    NSAppleScript *ipscript = [[NSAppleScript alloc] initWithSource:ipString];
    NSDictionary *iperrorMessage = nil;
    
    NSAppleEventDescriptor *ipresult = [ipscript executeAndReturnError:&iperrorMessage];
    NSLog(@"mount: %@",ipresult);
    NSString *scriptReturn = [ipresult stringValue];
    NSLog(@"IP: %@",scriptReturn);
    
    if (scriptReturn == NULL)
    {
    NSAlert *Warnung = [[NSAlert alloc] init];
    [Warnung addButtonWithTitle:@"OK"];
    //   [Warnung addButtonWithTitle:@""];
    //   [Warnung addButtonWithTitle:@""];
    //   [Warnung addButtonWithTitle:@"Abbrechen"];
    NSString* MessageText= NSLocalizedString(@"No IP",@"Verbindung misslungen");
    [Warnung setMessageText:[NSString stringWithFormat:@"%@ \n%@",@"AVR awake",MessageText]];
    
    
    NSString* s1=@"Kein Netz";
    NSString* InformationString=[NSString stringWithFormat:@"Fehler: %@",s1];
    [Warnung setInformativeText:InformationString];
    [Warnung setAlertStyle:NSWarningAlertStyle];
    
    int antwort=[Warnung runModal];
    NSLog(@"Connection: %d",antwort);
    [LocalTaste setEnabled:YES];
    [TWIStatusTaste setEnabled:YES];
    NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
    NSMutableDictionary* localStatusDic=[[NSMutableDictionary alloc]initWithCapacity:0];
    [localStatusDic setObject:[NSNumber numberWithInt:1]forKey:@"status"];
    [nc postNotificationName:@"localstatus" object:self userInfo:localStatusDic];
    
    
    }
    
    */
   
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   //[NotificationDic setObject:DataString forKey:@"routerip"];
   if (scriptReturn)
   {
      [NotificationDic setObject:scriptReturn forKey:@"routerip"];
   }
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"routerIP" object:self userInfo:NotificationDic];
   
   return scriptReturn;
}


#pragma mark solar


- (NSString*)SolarDataVonHeute
{
   NSString* returnString=[NSString string];
   if (isDownloading)
   {
      [self cancel];
   }
   else
   {
      
      if (localNetz == YES)
      {
 //        return returnString;
      }

      //NSArray* BrennerdatenArray = [self BrennerStatistikVonJahr:2010 Monat:0];
      //NSLog(@"BrennerdatenArray: %@",[BrennerdatenArray description]);
      
      SolarDataSuffix=@"SolarDaten.txt";
      //NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
      //NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:@"SolarDaten.txt"]];
      //NSLog(@"DataVonHeute URLPfad: %@",URLPfad);
      //NSLog(@"SolarDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,SolarDataSuffix);
      
      NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
      //NSLog(@"SolarDataVonHeute URL: %@",URL);
      //NSURL *URL = [NSURL URLWithString:@"http://www.schuleduernten.ch/blatt/cgi-bin/HomeDaten.txt"];
      //www.schuleduernten.ch/blatt/cgi-bin/HomeDaten/HomeDaten090730.txt
      
      if (localNetz == YES)
      {
 //        return returnString;
      }
    
      NSStringEncoding *  enc=0;
      NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
      NSError* WebFehler=NULL;
      NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
      
      //NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
      if (WebFehler)
      {
         //NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
         
         //NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
         //NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
         //ERROR: 503
         NSArray* ErrorArray=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]componentsSeparatedByString:@","];
         NSLog(@"SolarDataVonHeute ErrorArray: %@",[ErrorArray description]);
         NSAlert *Warnung = [[NSAlert alloc] init];
         [Warnung addButtonWithTitle:@"OK"];
         //	[Warnung addButtonWithTitle:@""];
         //	[Warnung addButtonWithTitle:@""];
         //	[Warnung addButtonWithTitle:@"Abbrechen"];
         NSString* MessageText= NSLocalizedString(@"Error in Download",@"SolarDataVonHeute\nDownload misslungen");
         [Warnung setMessageText:[NSString stringWithFormat:@"%@",MessageText]];
         
         NSString* s1=[NSString stringWithFormat:@"URL: \n%@",URL];
         NSString* s2=[ErrorArray objectAtIndex:2];
         int AnfIndex=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]rangeOfString:@"\""].location;
         NSString* s3=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]substringFromIndex:AnfIndex];
         NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
         [Warnung setInformativeText:InformationString];
         [Warnung setAlertStyle: NSAlertStyleWarning];
         
         int antwort=[Warnung runModal];
         return returnString;
      }
      if ([DataString length])
      {
         
         char first=[DataString characterAtIndex:0];
         
         // eventuellen Leerschlag am Anfang entfernen
         
         if (![CharOK characterIsMember:first])
         {
            //NSLog(@"DataVonHeute: String korrigieren");
            DataString=[DataString substringFromIndex:1];
         }
         //NSLog(@"SolarDataVonHeute DataString: \n%@",DataString);
         lastDataZeit=[self lastDataZeitVon:DataString];
         NSLog(@"SolarDataVonHeute lastDataZeit: %d",lastDataZeit);
         
         // Auf WindowController Timer auslösen
         downloadFlag=heute;
         //NSLog(@"DataVonHeute downloadFlag: %d",downloadFlag);
         NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
         [NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
         [NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
         [NotificationDic setObject:DataString forKey:@"datastring"];
         //NSLog(@"SolarDataVonHeute NotificationDic: %@",NotificationDic);
         NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
         [nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
         //NSLog(@"Daten OK");
         
   //      NSArray* StatistikArray=[self SolarErtragVonHeute];
         
         return DataString;
         
      }
      else
      {
         NSLog(@"Keine Daten");
         [self setErrString:@"DataVonHeute: keine Daten"];
      }
      
      /*
       NSLog(@"DataVon URL: %@ DataString: %@",URL,DataString);
       if (URL) 
       {
       download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
       downloadFlag=heute;
       
       }
       if (!download) 
       {
       
       NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
       @"The entered URL is either invalid or unsupported.");
       }
       */
      
   }
   return returnString;
}

#pragma mark testsolar
- (NSString*)TestSolarData
{
	NSString* returnString=[NSString string];
	if (isDownloading) 
	{
		[self cancel];
	} 
	else 
	{
		//NSArray* BrennerdatenArray = [self BrennerStatistikVonJahr:2010 Monat:0];
		//NSLog(@"BrennerdatenArray: %@",[BrennerdatenArray description]);
		
		SolarDataSuffix=@"testsolardaten.txt";
		//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
		//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:@"SolarDaten.txt"]];
		//NSLog(@"DataVonHeute URLPfad: %@",URLPfad);
		//NSLog(@"SolarDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,SolarDataSuffix);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
		//NSLog(@"SolarDataVonHeute URL: %@",URL);
		//NSURL *URL = [NSURL URLWithString:@"http://www.schuleduernten.ch/blatt/cgi-bin/HomeDaten.txt"];
		//www.schuleduernten.ch/blatt/cgi-bin/HomeDaten/HomeDaten090730.txt
		NSStringEncoding *  enc=0;
		NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
		NSError* WebFehler=NULL;
		NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
		
		//NSLog(@"DataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
		if (WebFehler)
		{
			//NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
			
         //NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
//NSLog(@"SolarDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
			//ERROR: 503
			NSArray* ErrorArray=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]componentsSeparatedByString:@","];
			NSLog(@"ErrorArray: %@",[ErrorArray description]);
			NSAlert *Warnung = [[NSAlert alloc] init];
			[Warnung addButtonWithTitle:@"OK"];
			//	[Warnung addButtonWithTitle:@""];
			//	[Warnung addButtonWithTitle:@""];
			//	[Warnung addButtonWithTitle:@"Abbrechen"];
			NSString* MessageText= NSLocalizedString(@"Error in Download",@"TestSolarData Download misslungen");
			[Warnung setMessageText:[NSString stringWithFormat:@"%@",MessageText]];
			
			NSString* s1=[NSString stringWithFormat:@"URL: \n%@",URL];
			NSString* s2=[ErrorArray objectAtIndex:2];
			int AnfIndex=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]rangeOfString:@"\""].location;
			NSString* s3=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]substringFromIndex:AnfIndex];
			NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
			[Warnung setInformativeText:InformationString];
         [Warnung setAlertStyle:NSAlertStyleWarning];
			
			int antwort=[Warnung runModal];
			return returnString;
		}
		if ([DataString length])
		{
			
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				//NSLog(@"DataVonHeute: String korrigieren");
				DataString=[DataString substringFromIndex:1];
			}
			//NSLog(@"SolarDataVonHeute DataString: \n%@",DataString);
			lastDataZeit=[self lastDataZeitVon:DataString];
			//NSLog(@"SolarDataVonHeute lastDataZeit: %d",lastDataZeit);
			
			// Auf WindowController Timer auslösen
			downloadFlag=heute;
			//NSLog(@"DataVonHeute downloadFlag: %d",downloadFlag);
			NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
			//NSLog(@"Daten OK");
			
			 NSArray* StatistikArray=[self SolarErtragVonHeute];
			
			return DataString;
			
		}
		else
		{
			NSLog(@"Keine Daten");
			[self setErrString:@"DataVonHeute: keine Daten"];
		}
		
		/*
		 NSLog(@"DataVon URL: %@ DataString: %@",URL,DataString);
		 if (URL) 
		 {
		 download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
		 downloadFlag=heute;
		 
		 }
		 if (!download) 
		 {
		 
		 NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
		 @"The entered URL is either invalid or unsupported.");
		 }
		 */
		 
		
		 
		 
	}
	return returnString;
}

- (NSString*)SolarDataVon:(NSDate*)dasDatum
{
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	if (isDownloading) 
	{
		[self cancel];
	} 
	else 
	{
		
		NSArray* DatumStringArray=[[dasDatum description]componentsSeparatedByString:@" "];
		// NSArray* DatumStringArray=[[[NSDate date] description]componentsSeparatedByString:@" "];
		//NSLog(@"DataVon DatumStringArray: %@",[DatumStringArray description]);
		
		NSArray* DatumArray=[[DatumStringArray objectAtIndex:0] componentsSeparatedByString:@"-"];
		//NSString* SuffixString=[NSString stringWithFormat:@"/SolarDaten/SolarDaten%@%@%@.txt",[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
		//NSLog(@"SolarDataVon DatumArray: %@",[DatumArray description]);
		//NSLog(@"SolarDataVon SuffixString: %@",SuffixString);
		
		SolarDataSuffix=[NSString stringWithFormat:@"/SolarDaten/%@/SolarDaten%@%@%@.txt",[DatumArray objectAtIndex:0],[[DatumArray objectAtIndex:0]substringFromIndex:2],[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2]];
		//NSLog(@"DataSuffix: %@",SolarDataSuffix);
		//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
		//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:@"HomeDaten.txt"]];
		//NSLog(@"DataVon URLPfad: %@",URLPfad);
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
		//NSLog(@"DataVon 1");
		
		NSString* DataString=[NSString stringWithContentsOfURL:URL encoding:NSMacOSRomanStringEncoding error:NULL];
		NSLog(@"DataVon... laden von URL: %@",URL);
		//NSLog(@"DataVon... laden von URL: %@ DataString: %@",URL,DataString);
		
		if (DataString)
		{
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				DataString=[DataString substringFromIndex:1];
			}
			//NSLog(@"SolarDataVon DataString: %@",DataString);
			lastDataZeit=[self lastDataZeitVon:DataString];
			//NSLog(@"downloadDidFinish lastDataZeit: %d",lastDataZeit);
			//NSLog(@"downloadDidFinish downloadFlag: %d",downloadFlag);
			
			downloadFlag=datum;
			
			//NSLog(@"Data von: %@ OK",DataString);
			// Auf WindowController Timer stoppen, Diagramm leeren 
			NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
			
			return DataString;
			
			
			
			
		}
		else
		{
			DataString=@"Error";
			NSLog(@"DataVon: DataSuffix: %@",URL);
			[self setErrString:[NSString stringWithFormat:@"%@ %@ %@ %@",[DatumArray objectAtIndex:1],[DatumArray objectAtIndex:2],@"DataVon: keine Daten"]];
			return DataString;

		}
		
		
		
		
		
		
		if (URL) 
		{
			NSURLRequest* URLReq=[NSURLRequest requestWithURL:URL ];
			if (URLReq)
			{
				//download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
				download = [[WebDownload alloc] initWithRequest:URLReq delegate:self];
				//NSLog(@"DataVon 2");
				
				
				downloadFlag=datum;
				
			}
			else
			{
				NSLog(@"NSURLReq nicht korrekt.");
			}
			
		}
		if (!download) 
		{
			
			NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
									@"The entered URL is either invalid or unsupported.");
		}
	}
	return NULL;

}



- (NSString*)LastSolarData
{
	//NSLog(@"LastSolarData");
	NSString* returnString = [NSString string];
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	SolarDataSuffix=@"LastSolarData.txt";
	downloadFlag=last;
	
	if (isDownloading) 
	{
		[NotificationDic setObject:@"busy" forKey:@"erfolg"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
		[self cancel];
	} 
	else 
	{
		[[NSURLCache sharedURLCache] setMemoryCapacity:0]; 
		[[NSURLCache sharedURLCache] setDiskCapacity:0]; 
		//	WebPreferences *prefs = [webView preferences]; 
		//[prefs setUsesPageCache:NO]; 
		//[prefs setCacheModel:WebCacheModelDocumentViewer];
		
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
		//NSLog(@"LastSolarData: URL: %@",URL);
		[NotificationDic setObject:@"ready" forKey:@"erfolg"];
		NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
		
		//NSURLRequestUseProtocolCachePolicy
		NSDate* ZeitVor=[NSDate date];
		NSError* WebFehler;
		int NSURLRequestReloadIgnoringLocalCacheData = 1;
		int NSURLRequestReloadIgnoringLocalAndRemoteCacheData=4;
		
		
		//ruediheimlicher
//      NSURL *lastTimeURL = [NSURL URLWithString:@"https://www.ruediheimlicher.ch/Data/HomeCentralPrefs.txt"];
		NSURL *lastTimeURL = [NSURL URLWithString:@"https://www.ruediheimlicher.ch/Data/HomeCentralPrefs.txt"];
	
      
      
      NSMutableURLRequest* lastTimeRequest=[ [NSMutableURLRequest alloc] initWithURL: lastTimeURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
      
      lastTimeRequest.timeoutInterval = 30.0;
      [lastTimeRequest setHTTPMethod:@"GET"];
      NSURLSession *session = [NSURLSession sharedSession];
      NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
      NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];

      NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:lastTimeRequest];
      [dataTask resume];
      

      
      
		//NSLog(@"Cache mem: %d",[[NSURLCache sharedURLCache]memoryCapacity]);
		
	//	[[NSURLCache sharedURLCache] removeCachedResponseForRequest:lastTimeRequest];
		
		NSError* syncErr=NULL;
		NSData* lastTimeData=[ NSURLConnection sendSynchronousRequest:lastTimeRequest returningResponse: nil error: &syncErr ];
		if (syncErr)
		{
			NSLog(@"LastSolarData syncErr: :%@",syncErr);
			//ERROR: 503
		}
		NSString *lastTimeString = [[NSString alloc] initWithBytes: [lastTimeData bytes] length:[lastTimeData length] encoding: NSUTF8StringEncoding];
		
		//NSStringEncoding *  enc=0;//NSUTF8StringEncoding;
		//NSString* lastTimeString=[NSString stringWithContentsOfURL:lastTimeURL usedEncoding: enc error:NULL];
		//[lastTimeString retain];
		//NSString* newlastTimeString=[NSString stringWithContentsOfURL:lastTimeURL usedEncoding: enc error:NULL];
		//NSLog(@"newlastTimeString: %@",newlastTimeString);
		//if ([newlastTimeString length] < 7)
		//{
		//	NSLog(@"newlastTimestring zu kurz");
		//	
		//}
		
		if ([lastTimeString length] < 7)
		{
			NSLog(@"LastSolarData lastTimestring zu kurz");
			return returnString;
		}
		
		NSString* lastDatumString = [lastTimeString substringFromIndex:7];
		//NSLog(@"lastSolarDatumString: %@",lastDatumString);
		[NotificationDic setObject:lastDatumString forKey:@"lasttimestring"];
		
	
		
		
		//NSString* aStr;
		//aStr = [[NSString alloc] initWithData:aData encoding:NSASCIIStringEncoding];
		
		
		SolarCentralRequest = [ [NSURLRequest alloc] initWithURL: URL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
		int delta=[[NSDate date] timeIntervalSinceDate:ZeitVor];
		//NSLog(@"Delta: %2.4F", delta);
		[NotificationDic setObject:[NSNumber numberWithFloat:delta] forKey:@"delta"];
		
		//HomeCentralData = [[NSURLConnection alloc] initWithRequest:HomeCentralRequest delegate:self];
		
		SolarCentralData = (NSMutableData*)[ NSURLConnection sendSynchronousRequest:SolarCentralRequest returningResponse: nil error: nil ];		
		
		if (SolarCentralData==NULL)
		{
			NSLog(@"LastSolarData: Fehler beim Download:_ Data ist NULL");
			[NotificationDic setObject:@"Fehler beim Download" forKey:@"err"];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
			return NULL;
		}
		NSString *DataString = [[NSString alloc] initWithBytes: [SolarCentralData bytes] length:[SolarCentralData length] encoding: NSUTF8StringEncoding];
		
		
		//		NSString* DataString= [NSString stringWithContentsOfURL:URL];
		
		if ([DataString length])
		{
			//NSLog(@"LastSolarData: DataString: %@",DataString);
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				DataString=[DataString substringFromIndex:1];
			}
			
			NSMutableArray* tempDataArray = (NSMutableArray*)[DataString componentsSeparatedByString:@"\t"];
			//NSLog(@"LastSolarData tempDataArray: %@",[tempDataArray description]);
			
			NSArray* prevDataArray = [prevSolarDataString componentsSeparatedByString:@"\t"];
			if ([prevDataArray count]>3)
			{
				float prevVorlauf=[[prevDataArray objectAtIndex:1]floatValue];
				float prevRuecklauf=[[prevDataArray objectAtIndex:2]floatValue];
				
				float lastVorlauf=[[tempDataArray objectAtIndex:1]floatValue];
				float lastRuecklauf=[[tempDataArray objectAtIndex:2]floatValue];
				float VorlaufQuotient=lastVorlauf/prevVorlauf;
				float RuecklaufQuotient=lastRuecklauf/prevRuecklauf;
				
				int KollektortemperaturH=[[tempDataArray objectAtIndex:3]intValue];
				int KollektortemperaturL=[[tempDataArray objectAtIndex:4]intValue];
				KollektortemperaturH -=163;
				int Kollektortemperatur=KollektortemperaturH;
				Kollektortemperatur<<=2;
				Kollektortemperatur += KollektortemperaturL;
            Kollektortemperatur = [[tempDataArray objectAtIndex:6]intValue];
            // 
            
				int Kontrolle=Kollektortemperatur;
				Kontrolle>>=2;
				//NSLog(@"LastSolarData Kollektortemperatur H: %d L: %d T: %d K: %d",KollektortemperaturH,KollektortemperaturL,Kollektortemperatur,Kontrolle);
				//NSLog(@"LastData prevVorlauf: %2.2f lastVorlauf: %2.2f \tprevRuecklauf: %2.2f lastRuecklauf: %2.2f",prevVorlauf, lastVorlauf, prevRuecklauf, lastRuecklauf);
				
				//NSLog(@"\nVorlaufQuotient: %2.3f \nRuecklaufQuotient: %2.3f\n",VorlaufQuotient,RuecklaufQuotient);

/*
				if (VorlaufQuotient < 0.75 || RuecklaufQuotient < 0.75)
				{	
					NSLog(@"** Differenz **");
					NSLog(@"LastSolarData: prevSolarDataString: %@ lastDataString: %@ ",prevSolarDataString,DataString);
					//NSLog(@"LastSolarData: lastDataString: %@",DataString);
					NSLog(@"LastSolarData \nprevVorlauf: %2.2f lastVorlauf: %2.2f \nprevRuecklauf: %2.2f lastRuecklauf: %2.2f\n",prevVorlauf, lastVorlauf, prevRuecklauf, lastRuecklauf);
					NSLog(@"\nVorlaufQuotient: %2.3f   RuecklaufQuotient: %2.3f\n",VorlaufQuotient,RuecklaufQuotient);
					lastVorlauf = prevVorlauf;
					lastRuecklauf=prevRuecklauf;
					int i=0;
					// Alle Objekte ausser Zeit durch Elemente von prevDataArray ersetzen
					for (i=1;i< [tempDataArray count];i++) 
					{
						[tempDataArray replaceObjectAtIndex:i withObject:[prevDataArray objectAtIndex:i]];
						
						DataString = [tempDataArray componentsJoinedByString:@"\t"];
						
					}
					NSLog(@"tempDataArray: %@ DataString: %@",[tempDataArray description],DataString);
					//DataString=prevDataString;
				}
*/				
			}
			
			
			prevSolarDataString= [DataString copy];
			
			lastSolarDataZeit=[self lastDataZeitVon:DataString];
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastSolarDataZeit] forKey:@"lastdatazeit"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
			
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
			
			SolarCentralRequest = NULL;
			return DataString;
		}
		else
		{
			//NSLog(@"LastSolarData: kein String");
			[self setErrString:@"lastData: kein String"];
			
		}
		//NSLog(@"LastSolarData: D");
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
		
		
	}
	
	return returnString;
}



#pragma mark Statistik
/*
- (NSArray*)KollektorMittelwerte
{
	//NSLog(@"KollektorMittelwerte");
   NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
   
	NSString* returnString = [NSString string];
	NSMutableArray* KollektorTemperaturArray = [[[NSMutableArray alloc]initWithCapacity:0]autorelease];
   NSMutableDictionary* NotificationDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
	NSString* KollektorDataSuffix=@"SolarTemperaturMittel.txt";
   
	if (isDownloading)
	{
		[NotificationDic setObject:@"busy" forKey:@"erfolg"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
		[self cancel];
	}
	else
	{
		[[NSURLCache sharedURLCache] setMemoryCapacity:0];
		[[NSURLCache sharedURLCache] setDiskCapacity:0];
		//	WebPreferences *prefs = [webView preferences];
		//[prefs setUsesPageCache:NO];
		//[prefs setCacheModel:WebCacheModelDocumentViewer];
		
		NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:KollektorDataSuffix]];
		//NSLog(@"LastSolarData: URL: %@",URL);
      
		NSString* DataString=[NSString stringWithContentsOfURL:URL encoding:NSUTF8StringEncoding error:NULL];
		NSLog(@"DataVon... laden von URL: %@",URL);
		//NSLog(@"DataVon... laden von URL: %@ DataString: %@",URL,DataString);
		
		
		if (DataString && [DataString length])
		{
			//NSLog(@"LastSolarData: DataString: %@",DataString);
         
         NSArray* DataArray = [DataString componentsSeparatedByString:@"\n"];
         
         
         
         for (int i=0;i < [DataArray count];i++)
         {
            if ([[DataArray objectAtIndex:i] length])
            {
               NSArray* tempZeilenarray = [[DataArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
               if ([tempZeilenarray count]>1)
               {
                  NSArray* tempDataArray = [tempZeilenarray subarrayWithRange:NSMakeRange(1, [tempZeilenarray count]-1)];
                  float mittelwert=0;
                  if ([tempDataArray count])
                  {
                     for (int k=0;k<[tempDataArray count];k++)
                     {
                        mittelwert += [[tempDataArray objectAtIndex:k]floatValue];
                     }
                     mittelwert /= [tempDataArray count];
                  }
                  NSDictionary* tempZeilenDic = [NSDictionary dictionaryWithObjectsAndKeys:[tempZeilenarray objectAtIndex:0],@"datum",tempDataArray,@"data", [NSNumber numberWithFloat:mittelwert],@"mittelwert",nil];
                  [KollektorTemperaturArray addObject:tempZeilenDic];
               }
               
            }// if length
            
            
            
         }// for i
         NSLog(@"KollektorTemperaturArray: %@",[[KollektorTemperaturArray valueForKey:@"mittelwert" ]description]);
			char first=[DataString characterAtIndex:0];
			
			// eventuellen Leerschlag am Anfang entfernen
			
			if (![CharOK characterIsMember:first])
			{
				DataString=[DataString substringFromIndex:1];
			}
			
			NSMutableArray* tempDataArray = (NSMutableArray*)[DataString componentsSeparatedByString:@"\t"];
			//NSLog(@"LastSolarData tempDataArray: %@",[tempDataArray description]);
			
			NSArray* prevDataArray = [prevSolarDataString componentsSeparatedByString:@"\t"];
			if ([prevDataArray count]>3)
			{
				float prevVorlauf=[[prevDataArray objectAtIndex:1]floatValue];
				float prevRuecklauf=[[prevDataArray objectAtIndex:2]floatValue];
				
				float lastVorlauf=[[tempDataArray objectAtIndex:1]floatValue];
				float lastRuecklauf=[[tempDataArray objectAtIndex:2]floatValue];
				float VorlaufQuotient=lastVorlauf/prevVorlauf;
				float RuecklaufQuotient=lastRuecklauf/prevRuecklauf;
				
				int KollektortemperaturH=[[tempDataArray objectAtIndex:3]intValue];
				int KollektortemperaturL=[[tempDataArray objectAtIndex:4]intValue];
				KollektortemperaturH -=163;
				int Kollektortemperatur=KollektortemperaturH;
				Kollektortemperatur<<=2;
				Kollektortemperatur += KollektortemperaturL;
				int Kontrolle=Kollektortemperatur;
				Kontrolle>>=2;
				//NSLog(@"LastSolarData Kollektortemperatur H: %d L: %d T: %d K: %d",KollektortemperaturH,KollektortemperaturL,Kollektortemperatur,Kontrolle);
				//NSLog(@"LastData prevVorlauf: %2.2f lastVorlauf: %2.2f \tprevRuecklauf: %2.2f lastRuecklauf: %2.2f",prevVorlauf, lastVorlauf, prevRuecklauf, lastRuecklauf);
				
				//NSLog(@"\nVorlaufQuotient: %2.3f \nRuecklaufQuotient: %2.3f\n",VorlaufQuotient,RuecklaufQuotient);
            
 			}
			
			
			prevSolarDataString= [DataString copy];
			
			lastSolarDataZeit=[self lastDataZeitVon:DataString];
			[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
			[NotificationDic setObject:[NSNumber numberWithInt:lastSolarDataZeit] forKey:@"lastdatazeit"];
			[NotificationDic setObject:DataString forKey:@"datastring"];
			
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
			[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
			
			[SolarCentralRequest release];
			SolarCentralRequest = NULL;
			return DataString;
		}
		else
		{
			//NSLog(@"LastSolarData: kein String");
			[self setErrString:@"lastData: kein String"];
			[SolarCentralRequest release];
			
		}
		//NSLog(@"LastSolarData: D");
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
		
		[DataString release];
		
	}
	
	return KollektorTemperaturArray;
}
*/

- (NSArray*)KollektorMittelwerteVonJahr:(int)jahr
{
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   NSMutableArray* KollektorTemperaturArray = [[NSMutableArray alloc]initWithCapacity:0];
   if (isDownloading)
	{
		[NotificationDic setObject:@"busy" forKey:@"erfolg"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"SolarDataDownload" object:self userInfo:NotificationDic];
		[self cancel];
	}
	else
	{
      
      //NSLog(@"HomeData KollektorMittelwerteVonJahr: %d",jahr);
      NSString* jahrString = [NSString stringWithFormat:@"kollektordaten/%d",jahr];
      
      
      NSString* jahrPfad =[ServerPfad stringByAppendingPathComponent:jahrString];
      //NSLog(@"jahrPfad: %@",[ServerPfad stringByAppendingPathComponent:jahrString]);
      //http://www.ruediheimlicher.ch/Data/kollektordaten/2013/kollektormittelwerte.txt
      
      //NSString* tagsuffix = [NSString stringWithFormat:@"/SolarDaten%d%.2d%.2d.txt",jahrkurz,monat,tag];
      //NSLog(@"tagsuffix: %@",tagsuffix);
      NSString* tagPfad =[jahrPfad stringByAppendingPathComponent:@"kollektormittelwerte.txt"];
      //NSLog(@"tagPfad: %@",tagPfad);
      
      NSURL *tagURL = [NSURL URLWithString:tagPfad];
      
      NSString* DataString=[NSString stringWithContentsOfURL:tagURL encoding:NSUTF8StringEncoding error:NULL];
      
      
      //NSLog(@"jahr: %d   DataString: \n%@",jahr,DataString);
		if (DataString && [DataString length])
		{
         //NSArray* jahrArray =[DataString componentsSeparatedByString:@"\n"];
         // NSLog(@"DataString: %@",DataString);
         //NSLog(@"jahrArray: %@",[jahrArray description]);
         //NSLog(@"HomeData KollektorMittelwerteVonJahr: %d: length von kollektormittelwerte.txt: %d ",jahr,[DataString length]);
         NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
         
         
         
			//NSLog(@"LastSolarData: DataString: %@",DataString);
         
         NSArray* DataArray = [DataString componentsSeparatedByString:@"\n"];
         //NSLog(@"DataArray: %@",[DataArray description]);
         for (int i=0;i < [DataArray count];i++)
         {
            if ([[DataArray objectAtIndex:i] length])
            {
               NSArray* tempZeilenarray = [[DataArray objectAtIndex:i]componentsSeparatedByString:@"\t"];
               if ([tempZeilenarray count]>1)
               {
                  int jahr = [[tempZeilenarray objectAtIndex:0]intValue];
                  int monat = [[tempZeilenarray objectAtIndex:1]intValue];
                  int tagdesmonats = [[tempZeilenarray objectAtIndex:2]intValue];
                  // (int)tagdesjahresvonJahr:(int)jahr Monat:(int)monat Tag: (int)tag
                  
                  int tagdesjahres = [self tagdesjahresvonJahr:jahr Monat:monat Tag:tagdesmonats];
                  //NSLog(@"tagdesjahres\t%d\t%d\t%d\t%d",jahr,monat,tagdesmonats,tagdesjahres);
                  NSDictionary* tempZeilenDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:tagdesjahres],@"tagdesjahres",[tempZeilenarray objectAtIndex:0],@"jahr",[tempZeilenarray objectAtIndex:1],@"monat", [tempZeilenarray objectAtIndex:2],@"tagdesmonats",[tempZeilenarray objectAtIndex:5],@"kollektormittelwert",nil];
                  [KollektorTemperaturArray addObject:tempZeilenDic];
               }
               
            }// if length
            else
            {
               
            }
            
         }// for i
      }
      else
      {
         //NSLog(@"HomeData KollektorMittelwerteVonJahr: %d: kein Inhalt von kollektormittelwerte.txt",jahr);
      }
      
      //NSLog(@"KollektorTemperaturArray: %@",[[KollektorTemperaturArray valueForKey:@"mittelwert" ]description]);
		//NSLog(@"LastSolarData: D");
      [NotificationDic setObject:KollektorTemperaturArray forKey:@"mittelwerte"];
      [NotificationDic setObject:[NSNumber numberWithInt:jahr] forKey:@"jahr"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"Mittelwerte" object:self userInfo:NotificationDic];
	}
	
	return KollektorTemperaturArray;
}

#pragma mark Strom

- (NSString*)StromDataVonHeute
{
   NSString* returnString=[NSString string];
   if (isDownloading)
   {
      [self cancel];
   }
   else
   {
      
      if (localNetz == YES)
      {
 //        return returnString;
      }
      
      
      StromDataSuffix=@"StromDaten.txt";
      //NSLog(@"StromDataVonHeute URLPfad: %@",URLPfad);
      //NSLog(@"StromDataVonHeute  DownloadPfad: %@ DataSuffix: %@",ServerPfad,SolarDataSuffix);
      NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:SolarDataSuffix]];
      //NSLog(@"StromDataVonHeute URL: %@",URL);
      //NSURL *URL = [NSURL URLWithString:@"http://www.schuleduernten.ch/blatt/cgi-bin/HomeDaten.txt"];
      //www.schuleduernten.ch/blatt/cgi-bin/HomeDaten/HomeDaten090730.txt
      
      if (localNetz == YES)
      {
 //        return returnString;
      }
      
      NSStringEncoding *  enc=0;
      NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
      NSError* WebFehler=NULL;
      NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:&WebFehler];
      
      //NSLog(@"StromDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
      if (WebFehler)
      {
         //NSLog(@"StromDataVonHeute WebFehler: :%@",[[WebFehler userInfo]description]);
         
         //NSLog(@"StromDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
         //NSLog(@"StromDataVonHeute WebFehler: :%@",[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]);
         //ERROR: 503
         NSArray* ErrorArray=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]componentsSeparatedByString:@","];
         NSLog(@"StromDataVonHeute ErrorArray: %@",[ErrorArray description]);
         NSAlert *Warnung = [[NSAlert alloc] init];
         [Warnung addButtonWithTitle:@"OK"];
         //   [Warnung addButtonWithTitle:@""];
         //   [Warnung addButtonWithTitle:@""];
         //   [Warnung addButtonWithTitle:@"Abbrechen"];
         NSString* MessageText= NSLocalizedString(@"Error in Download",@"SolarDataVonHeute\nDownload misslungen");
         [Warnung setMessageText:[NSString stringWithFormat:@"%@",MessageText]];
         
         NSString* s1=[NSString stringWithFormat:@"URL: \n%@",URL];
         NSString* s2=[ErrorArray objectAtIndex:2];
         int AnfIndex=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]rangeOfString:@"\""].location;
         NSString* s3=[[[[WebFehler userInfo]objectForKey:@"NSUnderlyingError"]description]substringFromIndex:AnfIndex];
         NSString* InformationString=[NSString stringWithFormat:@"%@\n%@\nFehler: %@",s1,s2,s3];
         [Warnung setInformativeText:InformationString];
         [Warnung setAlertStyle:NSAlertStyleWarning];
         
         int antwort=[Warnung runModal];
         return returnString;
      }
      if ([DataString length])
      {
         
         char first=[DataString characterAtIndex:0];
         
         // eventuellen Leerschlag am Anfang entfernen
         
         if (![CharOK characterIsMember:first])
         {
            //NSLog(@"StromDataVonHeute: String korrigieren");
            DataString=[DataString substringFromIndex:1];
         }
         //NSLog(@"StromDataVonHeute DataString: \n%@",DataString);
         lastDataZeit=[self lastDataZeitVon:DataString];
         //NSLog(@"SolarDataVonHeute lastDataZeit: %d",lastDataZeit);
         
         // Auf WindowController Timer auslösen
         downloadFlag=heute;
         //NSLog(@"StromDataVonHeute downloadFlag: %d",downloadFlag);
         NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
         [NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
         [NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
         [NotificationDic setObject:DataString forKey:@"datastring"];
         NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
         [nc postNotificationName:@"StromDataDownload" object:self userInfo:NotificationDic];
         //NSLog(@"Daten OK");
         
         //      NSArray* StatistikArray=[self SolarErtragVonHeute];
         
         return DataString;
         
      }
      else
      {
         NSLog(@"Keine Daten");
         [self setErrString:@"DataVonHeute: keine Daten"];
      }
      
      /*
       NSLog(@"DataVon URL: %@ DataString: %@",URL,DataString);
       if (URL) 
       {
       download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
       downloadFlag=heute;
       
       }
       if (!download) 
       {
       
       NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
       @"The entered URL is either invalid or unsupported.");
       }
       */
      
   }
   return returnString;
}

#pragma mark EEPROM
- (void)EEPROMUpdateAktion:(NSNotification*)note
{
   //NSLog(@"EEPROMUpdateAktion");
   DataSuffix=@"eepromdaten/eepromupdatedaten.txt";
   NSURL* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
   NSLog(@"EEPROMUpdateAktion URLPfad: %@",URLPfad);
   NSError* err;
   NSString* UpdateString = [NSString stringWithContentsOfURL:URLPfad encoding:NSUTF8StringEncoding error:&err];
   
   //NSLog(@"EEPROMUpdateAktion UpdateString: %@",UpdateString);
   NSArray* UpdateArrayRaw = [UpdateString componentsSeparatedByString:@"\n"];
   //NSLog(@"EEPROMUpdateAktion UpdateArrayRaw: %@",[UpdateArrayRaw description]);
   NSMutableIndexSet* ZeilenIndex = [NSMutableIndexSet indexSet];
   NSMutableArray* UpdateArray = [[NSMutableArray alloc]initWithCapacity:0];

   for (int i=[UpdateArrayRaw count];i>0;i--) // von unten anfangen, neuste zuerst
   {
      NSString* tempZeile = [UpdateArrayRaw objectAtIndex:i-1];
      if ([tempZeile length] && ![ZeilenIndex containsIndex:[[[tempZeile componentsSeparatedByString:@"\t"]objectAtIndex:0]intValue]])
      {
         //$dataadresse\t$raum\t$objekt\t$wochentag\t$hbyte\t$lbyte\t$data                \t$tagbalkentyp\t$permanent\t$zeitstempel\n";
         // 115          2       0        3           04       24    204 0	3 0 2 2 255 255	0        3           130103
         
         NSArray* tempZeilenArray = [tempZeile componentsSeparatedByString:@"\t"];
         NSLog(@"i: %d tempZeilenArray: %@",i,tempZeilenArray);
         int zeilennummer = [[tempZeilenArray objectAtIndex:0]intValue];
         [ZeilenIndex addIndex:zeilennummer]; // Zeilenindex speichern, nur letzter Datensatz pro dataadresse
         if ([tempZeilenArray count] >= (6+8)) // genuegend Daten
         {
            NSArray* tempDataArray = [tempZeilenArray subarrayWithRange:NSMakeRange(6, 8)]; // nur data
            NSDictionary* tempDataDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:zeilennummer],@"zeilennummer",
                                         tempZeile,@"zeile",
                                         tempDataArray,@"data",
                                         /*
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:1]intValue]],@"raum",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:2]intValue]],@"objekt",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:3]intValue]],@"wochentag",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:4]intValue]],@"hbyte",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:5]intValue]],@"lbyte",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:14]intValue]],@"tagbalkentyp",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:15]intValue]],@"perm",
                                          [NSNumber numberWithInt:[[tempZeilenArray objectAtIndex:16]intValue]],@"zeitstempel",
                                          */
                                         nil];
            
            [UpdateArray addObject:tempDataDic];
         }
      }
   }
   NSLog(@"EEPROMUpdateAktion UpdateArray unsortiert: %@",[UpdateArray description]);
  // NSLog(@"EEPROMUpdateAktion UpdateArray vor: %@",[[UpdateArray valueForKey:@"zeilennummer" ] description]);
  
   NSComparator sortByNumber = ^(id dict1, id dict2)
   {
      NSNumber* n1 = [dict1 objectForKey:@"zeilennummer"];
                      NSNumber* n2 = [dict2 objectForKey:@"zeilennummer"];
                                      return (NSComparisonResult)[n1 compare:n2];
                                      };
   [UpdateArray sortUsingComparator: sortByNumber];
   
   //NSLog(@"EEPROMUpdateAktion UpdateArray nach sort  (data): %@",[[UpdateArray valueForKey:@"data" ] description]);
   
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:UpdateArray forKey:@"updatearray"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"HomeDataUpdate" object:self userInfo:NotificationDic]; // -> AVRClient

}


- (NSArray*)BrennerStatistikVonJahr:(int)dasJahr Monat:(int)derMonat
{
	NSMutableArray* BrennerdatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSLog(@"BrennerStatistikVon: %d",dasJahr);
	DataSuffix=@"Brennerzeit.txt";
	//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"BrennerStatistikVon URLPfad: %@",URLPfad);
	//NSLog(@"BrennerStatistikVon  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];

	NSLog(@"BrennerStatistikVon URL: %@",URL);
	
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:NULL];
	//NSLog(@"BrennerStatistik DataString: %@",DataString);
	
	if ([DataString length])
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			//NSLog(@"DataVonHeute: String korrigieren");
			DataString=[DataString substringFromIndex:1];
		}
		//NSLog(@"BrennerStatistikVon DataString: \n%@",DataString);
		NSArray* tempZeilenArray = [DataString componentsSeparatedByString:@"\n"];
		//NSLog(@"BrennerStatistikVon tempZeilenArray: \n%@",[tempZeilenArray description]);
		NSEnumerator* ZeilenEnum =[tempZeilenArray objectEnumerator];
		id eineZeile;
		while (eineZeile=[ZeilenEnum nextObject])
		{
			NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			
			NSArray* tempDatenArray = [eineZeile componentsSeparatedByString:@"\t"];
			NSInteger n=[tempDatenArray count];
			//NSLog(@"tempDatenArray: %@, n %d",[tempDatenArray description], n);
			// calendarFormat:@"%d, %m %y"];
			
			if (n==3) // Daten vorhanden
			{
            
			//	NSCalendarDate* Datum=[NSCalendarDate dateWithString:[tempDatenArray objectAtIndex:0] calendarFormat:@"%d.%m.%y"];
				// [0]   "13.12.09"  
            
            NSArray* DatumArray= [[tempDatenArray objectAtIndex:0]componentsSeparatedByString:@"."];
             NSDateComponents* dateComponents = [[NSDateComponents alloc] init];
            int tagdesmonats = [[DatumArray objectAtIndex:0]intValue];
           // NSLog(@"DatumArray 0: %d tagdesmonats %d",DatumArray[0], tagdesmonats);
            dateComponents.day = tagdesmonats;
           // NSLog(@"dateComponents.day: %ld",(long)dateComponents.day);
            
            dateComponents.month = (long)[[DatumArray objectAtIndex:1] intValue];
           // NSLog(@"dateComponents.month: %ld",(long)dateComponents.month);
            dateComponents.year = (long)[[DatumArray objectAtIndex:2]intValue];
            //NSLog(@"dateComponents.year: %ld",(long)dateComponents.year);
            /*
            if ((dateComponents.year > 19) && (dateComponents.month > 5))
            {
            //   NSLog(@"dateComponents.month: %ld",(long)dateComponents.month);
               NSLog(@"dateComponents.year: %ld",(long)dateComponents.year);
               NSLog(@"Kein Brenner mehr");
               continue;
            }
             */
          //  NSDate* Datum = [NSDate dateFromComponents:dateComponents];
            NSCalendar* Kalender = [NSCalendar currentCalendar];
            NSDate* Datum  = [Kalender dateFromComponents:dateComponents];
            NSRange dayrange = [Kalender rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:Datum];
            NSInteger TagDesJahres = dayrange.length;
            
				int Jahr=(NSInteger)[DatumArray objectAtIndex:2];
            int Monat=(NSInteger)[DatumArray objectAtIndex:1];
        //    NSLog(@"Jahr: %d dasJahr: %d Monat: %d derMonat: %d",Jahr, dasJahr, Monat,derMonat);
				if ((Jahr == dasJahr)&& ((derMonat==0)||(Monat==derMonat)))
            {
   //            NSLog(@"Datum: %@, TagDesJahres: %d",[Datum description],TagDesJahres);
               [tempDic setObject:[NSNumber numberWithInt:TagDesJahres] forKey:@"tagdesjahres"];
               [tempDic setObject:[NSNumber numberWithInt:TagDesJahres] forKey:@"calenderdatum"];
               [tempDic setObject:[tempDatenArray objectAtIndex:0] forKey:@"datum"];
               NSArray* laufzeitArray=[[tempDatenArray objectAtIndex:1]componentsSeparatedByString:@" "];
               [tempDic setObject:[laufzeitArray lastObject] forKey:@"laufzeit"];
               NSArray* zeitArray=[[tempDatenArray objectAtIndex:2]componentsSeparatedByString:@" "];
               
               [tempDic setObject:[zeitArray lastObject] forKey:@"einschaltdauer"];
               
               //[tempDic setObject:[tempDatenArray objectAtIndex:1] forKey:@"laufzeit"];
               
               [BrennerdatenArray addObject:tempDic];
            }
			}
		}//while
		
	}
   else{
      NSLog(@"Brennersatitsikdaten nicht da");
   }
	return BrennerdatenArray;
}


- (NSArray*)TemperaturStatistikVonJahr:(int)dasJahr Monat:(int)derMonat
{
	NSMutableArray* TemperaturdatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSLog(@"TemperaturStatistikVon: %d",dasJahr);
	DataSuffix=@"TemperaturMittel.txt";
	//NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"TemperaturStatistikVon URLPfad: %@",URLPfad);
	//NSLog(@"TemperaturStatistikVon  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSURL *URL = [NSURL URLWithString:@"http://www.schuleduernten.ch/blatt/cgi-bin/HomeDaten.txt"];
	//www.schuleduernten.ch/blatt/cgi-bin/HomeDaten/HomeDaten090730.txt
	//NSLog(@"TemperaturStatistikVon URL: %@",URL);
   
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:NULL];
	//NSLog(@"TemperaturStatistikVon DataString: %@",DataString);
	
	if ([DataString length])
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			//NSLog(@"DataVonHeute: String korrigieren");
			DataString=[DataString substringFromIndex:1];
		}

      //NSLog(@"TemperaturStatistikVon DataString: \n%@",DataString);
		NSArray* tempZeilenArray = [DataString componentsSeparatedByString:@"\n"];
		//NSLog(@"TemperaturStatistikVon tempZeilenArray: \n%@",[tempZeilenArray description]);
		NSEnumerator* ZeilenEnum =[tempZeilenArray objectEnumerator];
		id eineZeile;
		while (eineZeile=[ZeilenEnum nextObject])
		{
			NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			
			NSArray* tempDatenArray = [eineZeile componentsSeparatedByString:@"\t"];
			int n=[tempDatenArray count];
			//NSLog(@"tempDatenArray: %@, n %d",[tempDatenArray description], n);
			if (n==4)
			{
            /*
				NSCalendarDate* Datum=[NSCalendarDate dateWithString:[tempDatenArray objectAtIndex:0] calendarFormat:@"%d.%m.%y"];
				int TagDesJahres = [Datum dayOfYear];
				int Jahr=[Datum yearOfCommonEra];
				int Monat=[Datum monthOfYear];
            */
            NSArray* DatumArray = [[tempDatenArray objectAtIndex:0]componentsSeparatedByString:@"."];
            int Jahr  = [[DatumArray objectAtIndex:2]integerValue] + 2000;
            int Monat = [[DatumArray objectAtIndex:1]integerValue];
            int Tag = [[DatumArray objectAtIndex:0]integerValue];
            int TagDesJahres = [self tagdesjahresvonJahr:Jahr Monat:Monat Tag:Tag];
            
				if ((Jahr == dasJahr)&& ((derMonat==0)||(Monat==derMonat)))
				{
	//			NSLog(@"Datum: %@, TagDesJahres: %d Monat: %d Jahr: %d",[tempDatenArray objectAtIndex:0],TagDesJahres,Monat, Jahr);
				[tempDic setObject:[NSNumber numberWithInt:TagDesJahres] forKey:@"tagdesjahres"];
				[tempDic setObject:[tempDatenArray objectAtIndex:0] forKey:@"calenderdatum"];
				[tempDic setObject:[tempDatenArray objectAtIndex:0] forKey:@"datum"];
				
				NSArray* mittelArray=[[tempDatenArray objectAtIndex:1]componentsSeparatedByString:@" "];
				[tempDic setObject:[mittelArray lastObject] forKey:@"mittel"];
				NSArray* tagArray=[[tempDatenArray objectAtIndex:2]componentsSeparatedByString:@" "];
				[tempDic setObject:[tagArray lastObject] forKey:@"tagmittel"];
				NSArray* nachtArray=[[tempDatenArray objectAtIndex:3]componentsSeparatedByString:@" "];
				[tempDic setObject:[nachtArray lastObject] forKey:@"nachtmittel"];
				[TemperaturdatenArray addObject:tempDic];
				}
			}
		}//while
		//NSLog(@"TemperaturdatenArray: %@",[[TemperaturdatenArray valueForKey:@"tagmittel"]description]);
	}
	
	return TemperaturdatenArray;
}

- (NSArray*)ElektroStatistikVonJahr:(int)dasJahr Monat:(int)derMonat
{
   // Zeile: 29.12.10	tab Elektro-Laufzeit: 1101	tab Pumpe-Laufzeit: 0.0
	NSMutableArray* ElektrodatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSLog(@"ElektroStatistikVon: %d",dasJahr);
	DataSuffix=@"ElektroZeit.txt";
//	NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"ElektroStatistikVonJahr URLPfad: %@",URLPfad);
	//NSLog(@"ElektroStatistikVonJahr  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
   
	//NSLog(@"ElektroStatistikVonJahr URL: %@",URL);
	
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:NULL];
	//NSLog(@"ElektroStatistikVonJahr DataString: %@",DataString);
	
	if ([DataString length])
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			//NSLog(@"DataVonHeute: String korrigieren");
			DataString=[DataString substringFromIndex:1];
		}
		//NSLog(@"ElektroStatistikVonJahr DataString: \n%@",DataString);
		NSArray* tempZeilenArray = [DataString componentsSeparatedByString:@"\n"];
		//NSLog(@"ElektroStatistikVonJahr tempZeilenArray: \n%@",[tempZeilenArray description]);
		NSEnumerator* ZeilenEnum =[tempZeilenArray objectEnumerator];
		id eineZeile;
		while (eineZeile=[ZeilenEnum nextObject])
		{
			NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			
			NSArray* tempDatenArray = [eineZeile componentsSeparatedByString:@"\t"];
			int n=[tempDatenArray count];
			//NSLog(@"ElektroStatistikVonJahr tempDatenArray: %@, n %d",[tempDatenArray description], n);
			// calendarFormat:@"%d, %m %y"];
			
			if (n==3)
			{
            /*
				NSCalendarDate* Datum=[NSCalendarDate dateWithString:[tempDatenArray objectAtIndex:0] calendarFormat:@"%d.%m.%y"];
				int TagDesJahres = [Datum dayOfYear];
				int Jahr=[Datum yearOfCommonEra];
				int Monat=[Datum monthOfYear];
	*/
            NSArray* DatumArray = [[tempDatenArray objectAtIndex:0]componentsSeparatedByString:@"."];
            int Jahr = [[DatumArray objectAtIndex:2]integerValue];
            int Monat = [[DatumArray objectAtIndex:1]integerValue];
            int Tag = [[DatumArray objectAtIndex:0]integerValue];
            int TagDesJahres = [self tagdesjahresvonJahr:Jahr Monat:Monat Tag:Tag];
      
            
            
            if ((Jahr == dasJahr)&& ((derMonat==0)||(Monat==derMonat)))
				{
               //NSLog(@" ElektroStatistikVonJahr Datum: %@, TagDesJahres: %d",[Datum description],TagDesJahres);
               [tempDic setObject:[NSNumber numberWithInt:TagDesJahres] forKey:@"tagdesjahres"];
               [tempDic setObject:[tempDatenArray objectAtIndex:0] forKey:@"calenderdatum"];
               [tempDic setObject:[tempDatenArray objectAtIndex:0] forKey:@"datum"];
               NSArray* laufzeitArray=[[tempDatenArray objectAtIndex:1]componentsSeparatedByString:@" "];
               
               float elektrolaufzeit = [[laufzeitArray lastObject]floatValue];
               elektrolaufzeit *= elektroleistungsfaktor;
               
               [tempDic setObject:[NSNumber numberWithFloat:elektrolaufzeit] forKey:@"elektrolaufzeit"];
              
               
               NSArray* elektroZeitArray=[[tempDatenArray objectAtIndex:2]componentsSeparatedByString:@" "];
               
               float pumpelaufzeit = [[elektroZeitArray lastObject]floatValue];
               pumpelaufzeit *= pumpeleistungsfaktor;
               
               [tempDic setObject:[NSNumber numberWithFloat:pumpelaufzeit] forKey:@"pumpelaufzeit"];
               
               //[tempDic setObject:[tempDatenArray objectAtIndex:1] forKey:@"laufzeit"];
               
               [ElektrodatenArray addObject:tempDic];
				}
			}
		}//while
		
	}
	
	return ElektrodatenArray;
}


- (NSArray*)SolarErtragVonJahr:(int)dasJahr Monat:(int)derMonat Tag:(int)derTag
{
	NSMutableArray* ErtragdatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSLog(@"SolarErtragVonJahr: %d",dasJahr);
	DataSuffix=@"SolarTagErtrag.txt";
//	NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"SolarErtragVonJahr URLPfad: %@",URLPfad);
	//NSLog(@"SolarErtragVonJahr  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:NULL];
	//NSLog(@"SolarErtragVonJahr DataString: %@",DataString);
	NSArray* tempDatenArray = [NSArray array];
	if ([DataString length])
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			//NSLog(@"DataVonHeute: String korrigieren");
			DataString=[DataString substringFromIndex:1];
		}
		//NSLog(@"SolarErtragVonJahr DataString: \n%@",DataString);
		NSArray* tempZeilenArray = [DataString componentsSeparatedByString:@"\n"];
		//NSLog(@"SolarErtragVonJahr tempZeilenArray: \n%@",[tempZeilenArray description]);
		NSEnumerator* ZeilenEnum =[tempZeilenArray objectEnumerator];
		id eineZeile;
		while (eineZeile=[ZeilenEnum nextObject])
		{
			NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			
			tempDatenArray = [eineZeile componentsSeparatedByString:@"\t"];
			int n=[tempDatenArray count];
			if (n>1) // keine Leerzeile
			{
				//NSLog(@"tempDatenArray: %@, n %d",[tempDatenArray description], n);
            
				NSArray* DatumArray = [[tempDatenArray objectAtIndex:0]componentsSeparatedByString:@"."];
				
				//NSLog(@"Zeile : %@ DatumArray: %@",[tempDatenArray objectAtIndex:0],[DatumArray description]);
				/*
             Temperaturdifferenz dT zwischen Ein- und Ausfluss des Kollektors
             Volumenstrom Q  in kg/s der Flüssigkeit
             Wärmekapazität c: kJ/kg*K der Flüssigkeit
             Betriebsdauer T in s
             
             Damit ist die Energie: Summe 0..T(c*dT*Q*)
             */
				int temptag=[[DatumArray objectAtIndex:0]intValue];
				int tempmonat=[[DatumArray objectAtIndex:1]intValue];
				int tempjahr=[[DatumArray objectAtIndex:2]intValue]+2000;
				
				
				if (dasJahr == tempjahr && derMonat == tempmonat && derTag == temptag)
				{
					
					NSRange DatenRange;
               
					DatenRange.location = 1;
					DatenRange.length = [tempDatenArray count]-1;
               
					tempDatenArray = [tempDatenArray subarrayWithRange:DatenRange];
					n=[tempDatenArray count];
					NSEnumerator* DatenEnum=[tempDatenArray objectEnumerator];
					id eineZeile;
					float ErtragSumme=0;
					while (eineZeile=[DatenEnum nextObject])
               {
						ErtragSumme += [eineZeile floatValue];
					}
               
               
					NSLog(@"\nDatum: %d.%d.%d \ntempDatenArray: %@, \nn %d Ertrag: %2.3F",temptag,tempmonat,tempjahr,[tempDatenArray description], n,ErtragSumme);
				}
				
            
            
			}
		}//while
	}
	return tempDatenArray;
}

- (NSArray*)SolarErtragVonJahr:(int)dasJahr vonMonat:(int)monat
{
   
	NSMutableArray* ErtragdatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSLog(@"SolarErtragVonJahr von Monat: %d Jahr: %d",monat,dasJahr);
	DataSuffix=@"SolarTagErtrag.txt";
//	NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"SolarErtragVonJahr URLPfad: %@",URLPfad);
	//NSLog(@"SolarErtragVonJahr  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"SolarErtragVonJahr URL: %@",URL);
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:NULL];
	//NSLog(@"SolarErtragVonJahr DataString: %@",DataString);
	NSArray* tempDatenArray = [NSArray array];
	if ([DataString length])
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			//NSLog(@"DataVonHeute: String korrigieren");
			DataString=[DataString substringFromIndex:1];
		}
		//NSLog(@"SolarErtragVonJahr DataString: \n%@",DataString);
		NSArray* tempZeilenArray = [DataString componentsSeparatedByString:@"\n"];
		//NSLog(@"SolarErtragVonJahr tempZeilenArray: \n%@",[tempZeilenArray description]);
		NSEnumerator* ZeilenEnum =[tempZeilenArray objectEnumerator];
		id eineZeile;
      int index=0;
		while (eineZeile=[ZeilenEnum nextObject])
		{
         //NSLog(@"index: %d",index++);
			NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			//NSLog(@"index: %d eineZeile: %@",index++,eineZeile);
			tempDatenArray = [eineZeile componentsSeparatedByString:@"\t"];
			int n=[tempDatenArray count];
			if (n>2) // keine Leerzeile
			{
				//NSLog(@"tempDatenArray: %@, n %d",[tempDatenArray description], n);

				NSArray* DatumArray = [[tempDatenArray objectAtIndex:0]componentsSeparatedByString:@"."];
				
				//NSLog(@"Zeile : %@ DatumArray: %@",[tempDatenArray objectAtIndex:0],[DatumArray description]);
				
				
				int temptag=[[DatumArray objectAtIndex:0]intValue];
				int tempmonat=[[DatumArray objectAtIndex:1]intValue];
				int tempjahr=[[DatumArray objectAtIndex:2]intValue]+2000;
				
            
				
				if (dasJahr == tempjahr && ((monat==0)||(monat==tempmonat)))
				{
					int tagdesjahres = [self tagdesjahresvonJahr:tempjahr Monat:tempmonat Tag:temptag];
               
               
					NSRange DatenRange;
 
					DatenRange.location = 1;
					DatenRange.length = [tempDatenArray count]-1;
 
					tempDatenArray = [tempDatenArray subarrayWithRange:DatenRange];
					int anzWerte = 0;
					NSEnumerator* DatenEnum=[tempDatenArray objectEnumerator];
					id eineZeile;
					float ErtragSumme=0;
               float maxtagertrag=0;
					while (eineZeile=[DatenEnum nextObject])
					 {
                   float stundenertrag = [eineZeile floatValue];// stundenertrag ist Kelvin pro Minute aufsummiert waehrend einer Stunde
                   if (stundenertrag > maxtagertrag)
                   {
                      maxtagertrag = stundenertrag;
                   }
                   //NSLog(@"wert: %.5f",[eineZeile floatValue]);
                   if (stundenertrag > 0)
                   {
                      anzWerte++;
                   }
                   
						ErtragSumme += stundenertrag;
					}
               // Ertragsumme ist Integral der Differenztemp in K*min
               
               //float ErtragMittelwert = ErtragSumme/anzWerte; // Mittelwert
               
              
               //NSLog(@"fluidleistungsfaktor: %2.5f",fluidleistungsfaktor);
               // Fluidleistungsfaktor in kJ/s*K, fuer 1 Stunde
               float Fluidertrag = (fluidleistungsfaktor *60)* ErtragSumme;
                              
					//NSLog(@"\nDatum: %d.%d.%d \ntagdesjahres: %d\ntempDatenArray: %@, \nanzWerte %d Ertrag: %2.3F",temptag,tempmonat,tempjahr, tagdesjahres,[tempDatenArray description], anzWerte,ErtragSumme);
               NSDictionary* tempZeilenDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [NSNumber numberWithInt:tagdesjahres],@"tagdesjahres",
                                              [NSNumber numberWithFloat:ErtragSumme],@"ertrag",
                                              [NSNumber numberWithFloat:ErtragSumme/anzWerte],@"ertragmittel",
                                              [NSNumber numberWithFloat:maxtagertrag],@"maxtagertrag",
                                              [NSNumber numberWithFloat:Fluidertrag],@"fluidertrag",
                                              [NSNumber numberWithInt:n],@"anzahlertragstunden",
                                              
                                              nil];
               [ErtragdatenArray addObject:tempZeilenDic];
            
            
            }
				
			
			
			}
		}//while
	}
	return ErtragdatenArray;
}

- (NSArray*)SolarErtragVonHeute
{
	NSMutableArray* ErtragdatenArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSLog(@"SolarErtragVonHeute");
	DataSuffix=@"SolarTagErtrag.txt";
//	NSString* URLPfad=[NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	//NSLog(@"SolarErtragVonHeute URLPfad: %@",URLPfad);
	//NSLog(@"SolarErtragVonJahr  DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	NSURL *URL = [NSURL URLWithString:[ServerPfad stringByAppendingPathComponent:DataSuffix]];
	
	NSStringEncoding *  enc=0;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	NSString* DataString=[NSString stringWithContentsOfURL:URL usedEncoding: enc error:NULL];
	//NSLog(@"SolarErtragVonJahr DataString: %@",DataString);
	NSArray* tempDatenArray = [NSArray array];
	if ([DataString length])
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			//NSLog(@"DataVonHeute: String korrigieren");
			DataString=[DataString substringFromIndex:1];
		}
		//NSLog(@"SolarErtragVonJahr DataString: \n%@",DataString);
		NSArray* tempZeilenArray = [DataString componentsSeparatedByString:@"\n"];
		int anz=[tempZeilenArray count];
		
		//NSLog(@"SolarErtragVonJahr tempZeilenArray: Anzahl Zeilen: %d\n%@",anz,[tempZeilenArray description]);
		
		NSString* lastZeile = [tempZeilenArray lastObject];
		if ([lastZeile length]==0)
		{
		lastZeile = [tempZeilenArray objectAtIndex:anz-2];
		}
		tempDatenArray = [lastZeile componentsSeparatedByString:@"\t"];
		int n=[tempDatenArray count];
			if (n>1) // keine Leerzeile
			{
				//NSLog(@"tempDatenArray raw: %@, n %d",[tempDatenArray description], n);
				
				NSArray* DatumArray = [[tempDatenArray objectAtIndex:0]componentsSeparatedByString:@"."];
				
				NSRange DatenRange;
				
				DatenRange.location = 1;
				DatenRange.length = [tempDatenArray count]-1;
				
				tempDatenArray = [tempDatenArray subarrayWithRange:DatenRange];
				
				n=[tempDatenArray count];
				NSEnumerator* DatenEnum=[tempDatenArray objectEnumerator];
				id eineZeile;
				float ErtragSumme=0;
				while (eineZeile=[DatenEnum nextObject])
				{
					ErtragSumme += [eineZeile floatValue];
				}
				//NSLog(@"\ntempDatenArray Data: %@, \nn: %d Ertrag: %2.3F",[tempDatenArray description], n,ErtragSumme);
				
				
			}
	}
	return tempDatenArray;
}


- (void)setDownloading:(BOOL)downloading
{
    if (isDownloading != downloading) {
        isDownloading = downloading;
        if (isDownloading) {
            [progressIndicator setIndeterminate:YES];
            [progressIndicator startAnimation:self];
            [downloadCancelButton setKeyEquivalent:@"."];
            [downloadCancelButton setKeyEquivalentModifierMask:NSCommandKeyMask];
            [downloadCancelButton setTitle:@"Cancel"];
            //[self setFileName:nil];
        } else {
            [progressIndicator setIndeterminate:NO];
            [progressIndicator setDoubleValue:0];
            [downloadCancelButton setKeyEquivalent:@"\r"];
            [downloadCancelButton setKeyEquivalentModifierMask:0];
            [downloadCancelButton setTitle:@"Download"];
            download = nil;
            receivedContentLength = 0;
        }
    }
}

- (void)cancel
{
    [download cancel];
    [self setDownloading:NO];
}

- (void)open
{    
  //  if ([openButton state] == NSOnState) {
   //     [[NSWorkspace sharedWorkspace] openFile:[self fileName]];
   // }
}

- (IBAction)reportURLPop:(id)sender
{

}
/*
- (NSWindow *)window
{
  //  NSWindowController *windowController = [[self windowControllers] objectAtIndex:0];
  //  return [windowController window];
  return [self window];
}
*/
- (IBAction)downloadOrCancel:(id)sender
{
    if (isDownloading) 
	 {
        [self cancel];
    } 
	 else 
	 {
        NSURL *URL = [NSURL URLWithString:[URLField stringValue]];
        if (URL) 
		  {
            download = [[WebDownload alloc] initWithRequest:[NSURLRequest requestWithURL:URL] delegate:self];
        }
        if (!download) 
		  {
			NSString* sa=NSLocalizedString(@"Invalid or unsupported URL",@"Ungültige oder nicht unterstützte URL");
			NSString* sb=NSLocalizedString(@"The entered URL is either invalid or unsupported.",@"Die URL ist ungültig oder wird nicht unterstützt");
           			 NSBeginAlertSheet(sa, nil, nil, nil, [self window], nil, nil, nil, nil,sb);

				/*
				 NSBeginAlertSheet(@"Invalid or unsupported URL", nil, nil, nil, [self window], nil, nil, nil, nil,
                              @"The entered URL is either invalid or unsupported.");
				*/
        }
    }
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{    
   if (returnCode == NSModalResponseOK)
    {
       [download setDestination:[[sheet URL] absoluteString] allowOverwrite:YES];
    } else
    {
        [self cancel];
    }
}

// **************************************
#pragma mark NSURLSession Delegate Methods

// NSURLSessionDataDelegate - get continuous status of your request
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
   //NSLog(@" didReceiveResponse");
   receivedData=nil; receivedData=[[NSMutableData alloc] init];
   //[receivedData setLength:0];
   
   completionHandler(NSURLSessionResponseAllow);
}
//NSURLSessionDataDelegate

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data {
   //receivedAnswerString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
   //NSLog(@"didReceiveData: receivedAnswerString: %@",receivedAnswerString);
   NSString * HTML_Inhalt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]; 
   //NSLog(@"didReceiveData: HTML_Inhalt: %@",HTML_Inhalt);
   NSRange CheckRange;
   NSString* Datum_String= @"Datum:";
   CheckRange = [HTML_Inhalt rangeOfString:Datum_String];
   if (CheckRange.location < NSNotFound) // es ist eine Datum-Antwort
   {
      NSString* datum = [[HTML_Inhalt componentsSeparatedByString:@" "]objectAtIndex:1];
      NSString* zeit = [[HTML_Inhalt componentsSeparatedByString:@" "]objectAtIndex:2];
      //NSLog(@"didReceiveData Datum ist da: %@ Zeit: %@",datum, zeit);
   }
   
}

#pragma mark NSURLDownloadDelegate methods

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse 
{
NSLog(@"NSCachedURLResponse");
 return nil;
}

- (void)downloadDidBegin:(NSURLDownload *)download
{
	NSLog(@"downloadDidBegin");
    [self setDownloading:YES];
}

- (NSWindow *)downloadWindowForAuthenticationSheet:(WebDownload *)download
{
    return [self window];
}

- (void)download:(NSURLDownload *)theDownload didReceiveResponse:(NSURLResponse *)response
{
	
	expectedContentLength = [response expectedContentLength];
	//NSLog(@"didReceiveResponse --  expectedContentLength: %d",expectedContentLength);
	if (expectedContentLength > 0) 
	{
		// [progressIndicator setIndeterminate:NO];
      // [progressIndicator setDoubleValue:0];
	}
	[HomeCentralData setLength:0];
}

- (void)download:(NSURLDownload *)theDownload decideDestinationWithSuggestedFilename:(NSString *)filename
{
    if ([[directoryMatrix selectedCell] tag] == 0) {
        //NSString *path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Desktop/TempDaten"] stringByAppendingPathComponent:filename];
        NSString *path = [DownloadPfad  stringByAppendingPathComponent:filename];
       // NSLog(@"++++    decideDestinationWithSuggestedFilename  DownloadPfad: %@",DownloadPfad);
		  [download setDestination:path allowOverwrite:YES];
    } 
	 else 
	 {
        [[NSSavePanel savePanel] beginSheetForDirectory:NSHomeDirectory()
                                                   file:filename
                                         modalForWindow:[self window]
                                          modalDelegate:self
                                         didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:)
                                            contextInfo:nil];
    }
}

- (void)download:(NSURLDownload *)theDownload didReceiveDataOfLength:(unsigned long)length
{

	//NSLog(@"didReceiveResponse --  expectedContentLength: %d length: %ld",expectedContentLength,length);
    if (expectedContentLength > 0) {
        receivedContentLength += length;
        [progressIndicator setDoubleValue:(double)receivedContentLength / (double)expectedContentLength];
    }
}

- (BOOL)download:(NSURLDownload *)download shouldDecodeSourceDataOfMIMEType:(NSString *)encodingType;
{
    return ([decodeButton state] == NSOnState);
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
 //   [self setFileName:path];
}

- (void)URLSession:(NSURLSession *)session 
      downloadTask:(NSURLSessionDownloadTask *)downloadTask 
didFinishDownloadingToURL:(NSURL *)location
{
   NSLog(@"didFinishDownloadingToURL; %@",location);
}

- (void)downloadDidFinish:(NSURLDownload *)theDownload
{
	[self setDownloading:NO];
	
	NSLog(@"downloadDidFinish DownloadPfad: %@ DataSuffix: %@",DownloadPfad,DataSuffix);
	
	//NSString* DataPfad = [DownloadPfad stringByAppendingPathComponent:DataSuffix];
	NSString* DataPfad = [DownloadPfad stringByAppendingPathComponent:[DataSuffix lastPathComponent]];
	//NSLog(@"downloadDidFinish DataPfad: %@",DataPfad);
	//NSString* DataPfad = [DownloadPfad stringByAppendingPathComponent:@"HomeDaten.txt"];
	//NSStringEncoding enc=0;
	NSString* DataString = [NSString string];;
	NSCharacterSet* CharOK=[NSCharacterSet alphanumericCharacterSet];
	if ([[NSFileManager defaultManager]fileExistsAtPath:DataPfad])
	{
		//NSLog(@"File an Pfad da: %@",DataPfad);
		
		DataString=[NSString stringWithContentsOfFile:DataPfad encoding:NSMacOSRomanStringEncoding error:NULL];
		
	}
	else
	{
		NSLog(@"kein File an Pfad : %@",DataPfad);
		return;
		
	}
	NSLog(@"downloadDidFinish DataString: %@",DataString);
	if (DataString)
	{
		char first=[DataString characterAtIndex:0];
		
		// eventuellen Leerschlag am Anfang entfernen
		
		if (![CharOK characterIsMember:first])
		{
			DataString=[DataString substringFromIndex:1];
		}
		NSLog(@"downloadDidFinish DataString: %@",DataString);
		lastDataZeit=[self lastDataZeitVon:DataString];
		NSLog(@"downloadDidFinish lastDataZeit: %d",lastDataZeit);
		//NSLog(@"downloadDidFinish downloadFlag: %d",downloadFlag);
	}
	else
	{
		DataString=@"Error";
		NSLog(@"downloadDidFinish: DataPfad: %@ Error",DataPfad);
	}
	
	NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[NotificationDic setObject:[NSNumber numberWithInt:downloadFlag] forKey:@"downloadflag"];
	[NotificationDic setObject:[NSNumber numberWithInt:lastDataZeit] forKey:@"lastdatazeit"];
	[NotificationDic setObject:DataString forKey:@"datastring"];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"HomeDataDownload" object:self userInfo:NotificationDic];
	
	//[self open];
}

- (void)download:(NSURLDownload *)theDownload didFailWithError:(NSError *)error
{
    [self setDownloading:NO];
        
    NSString *errorDescription = [error localizedDescription];
    if (!errorDescription) {
        errorDescription = @"An error occured during download.";
    }
    
    NSBeginAlertSheet(@"Download misslungen", nil, nil, nil, [self window], nil, nil, nil, nil, errorDescription);
}

#pragma mark NSDocument methods

- (NSString *)windowNibName
{
    return @"HomeData";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)windowController
{
    [progressIndicator setMinValue:0];
    [progressIndicator setMaxValue:1.0];
}

- (void)close
{
    [self cancel];
    [super close];
}
@end
