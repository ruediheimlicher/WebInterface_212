//
//  AVR.m
//  USBInterface
//
//  Created by Sysadmin on 01.02.08.
//  Copyright 2008 Ruedi Heimlicher. All rights reserved.
//

#import "rAVR.h"
//#import "rHeizungTagplanbalken.h"
#define MO 0
#define DI 1

#define TAGPLANBREITE		0x40	// 64 Bytes, 2 page im EEPROM
#define RAUMPLANBREITE		0x200	// 512 Bytes

# define DAYSETTINGTIEFE   8

@implementation rAVR

- (uint8_t) freeDaySettingline
{
   for (int linie = 0;linie < DAYSETTINGTIEFE; linie++)
   {
      uint8_t byte = (const uint8_t )daySettingArray[linie][15];
      uint8_t data = daySettingArray[linie][15];
 //     NSLog(@"linie: %d byte: %hhu data: %s",linie, byte,daySettingArray[linie][15]);
      if ((daySettingArray[linie][15] & 0x03) == 0)
         return linie;
   }
   return 0xFF;
}

- (NSArray*)daySettingDataVon:(uint8_t)raum vonObjekt:(uint8_t)objekt anWochentag:(uint8_t)wochentag
{
   for (int linie = 0;linie < DAYSETTINGTIEFE; linie++)
   {
      if (daySettingArray[linie][15] == 1) // aktuell
      {
         uint8_t dayraum = ((const uint8_t )daySettingArray[linie][0] & 0xF0)>>4;
         if (raum == dayraum) // raum stimmt
         {
            
            uint8_t dayobjekt = ((const uint8_t )daySettingArray[linie][0] & 0x0F);
            if (objekt == dayobjekt) // objekt stimmt
            {
               uint8_t daywochentag= ((const uint8_t )daySettingArray[linie][1] & 0xF0)>>4;
               if (wochentag == daywochentag) // Wochentag stimmt
               {
                  uint8_t code = ((const uint8_t )daySettingArray[linie][1] & 0x0F);
                  uint8_t data[6] = {};
                  NSMutableArray * temparray = [[NSMutableArray alloc] initWithCapacity: 4];
                  for (int i = 0; i < 6; i++) // datapaket hat 6 bytes mit Tagplandaten
                  {
                     uint8_t byte = (const uint8_t )daySettingArray[linie][i+4];
                     //NSLog(@"byte: %02X",byte);
                     data[i] = byte;
                     NSString* tempdatastring = [NSString stringWithFormat:@"%02X", byte];
                     
                     [temparray addObject: [NSString stringWithFormat:@"%02X", byte]];
                  }
                  //NSLog(@"temparray: %@",temparray);
                  return temparray;
               }
            }
         }
         
      }
   }
   return nil;
}
- (void)Alert:(NSString*)derFehler
{
/*
	NSAlert * DebugAlert=[NSAlert alertWithMessageText:@"Debugger!" 
		defaultButton:NULL 
		alternateButton:NULL 
		otherButton:NULL 
		informativeTextWithFormat:@"Mitteilung: \n%@",derFehler];
 */
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
		//NSLog(@"HexStringZuInt string: %@ int: %x	",derHexString,returnInt);
		return returnInt;
	}

return returnInt;
}

void mountVolumeAppleScript (NSString *usr, NSString *pwd, NSString *serv, NSString *freig)
{
   
   // http://www.osxentwicklerforum.de/index.php?page=Thread&threadID=24276
   // http://stackoverflow.com/questions/6804541/getting-applescript-return-value-in-obj-c
   //NSString *mountString = [NSString localizedStringWithFormat:@"if not (exists disk freig)\n display dialog \"mounted\" \nend if\n",freig];
   
   //  NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"WD_TV\") then\nbeep\nelse\nmount volume \"smb://%@:%@@%@/%@\"\nend if\nend tell\n",usr,pwd,serv,freig];
   
   // Pfad aus Informationsfenster
   NSString *mountString = [NSString localizedStringWithFormat:@"tell application \"Finder\"\n if (exists disk \"WD_TV\") then\nbeep\nelse\nmount volume \"smb://WDTVLIVE._smb._tcp.local/WD_TV\"\nend if\nend tell\n"];
   
   //NSLog(@"mountString: %@",mountString);
   NSAppleScript *script = [[NSAppleScript alloc] initWithSource:mountString];
   
   NSDictionary *errorMessage = nil;
   NSAppleEventDescriptor *result = [script executeAndReturnError:&errorMessage];
   //NSLog(@"mountVolumeAppleScript mount result: %@",result);

   NSString *ipString = [NSString localizedStringWithFormat:@"do shell script \"curl ifconfig.me/ip\""];
   NSAppleScript *ipscript = [[NSAppleScript alloc] initWithSource:ipString];
   NSDictionary *iperrorMessage = nil;
   NSAppleEventDescriptor *ipresult = [ipscript executeAndReturnError:&iperrorMessage];
   //NSLog(@"mountVolumeAppleScript ifconfig result: %@",ipresult);

   
}




- (NSArray*)StundenArrayAusByteArray:(NSArray*)derStundenByteArray
{
	//NSLog(@"StundenArrayAusByteArray derStundenByteArray: %@",[derStundenByteArray description]);
	
	NSMutableArray* tempStundenArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSArray* bitnummerArray=[NSArray arrayWithObjects: @"null", @"eins",@"zwei",@"drei",@"vier",@"fuenf",nil];
   
	int i,k;
	for (i=0;i<6;i++)
	{
		
		//NSString* tempString=[[derStundenByteArray objectAtIndex:0]objectForKey:[bitnummerArray objectAtIndex:i]];
		NSString* tempString=[derStundenByteArray objectAtIndex:i];
		unsigned int tempByte=0;
		NSScanner *scanner;
		scanner = [NSScanner scannerWithString:tempString];
		[scanner scanHexInt:&tempByte];
      //NSString* dezString = [NSString stringWithFormat:@"%d",tempByte];
		
		
		//NSLog(@"i: %d tempString: %@ tempByte hex: %2.2X dez: %d dezString: %@",i,tempString,tempByte,tempByte,dezString);
		NSMutableArray* tempStundenCodeArray=[[NSMutableArray alloc]initWithCapacity:4];
		for (k=0;k<4;k++)
		{
			uint8_t tempStundencode = tempByte & 0x03;
			//NSLog(@"k: %d tempStundencode hex: %2.2X dez: %d",k,tempStundencode,tempStundencode);
			[tempStundenCodeArray insertObject:[NSNumber numberWithInt:tempStundencode]atIndex:0];
			//[tempStundenArray addObject:[NSNumber numberWithInt:tempStundencode]];
			tempByte>>=2;
         
		}
		[tempStundenArray addObjectsFromArray:tempStundenCodeArray];
	}//for i
	//NSLog(@"StundenArrayAusByteArray tempStundenArray: %@",[tempStundenArray description]);
	return tempStundenArray ;
}


- (NSArray*)StundenArrayAusDezArray:(NSArray*)derStundenByteArray
{
	//NSLog(@"StundenArrayAusDezArray derStundenByteArray: %@",[derStundenByteArray description]);
	
	NSMutableArray* tempStundenArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSArray* bitnummerArray=[NSArray arrayWithObjects: @"null", @"eins",@"zwei",@"drei",@"vier",@"fuenf",nil];
   
	int i,k;
	for (i=0;i<6;i++)
	{
		
		//NSString* tempString=[[derStundenByteArray objectAtIndex:0]objectForKey:[bitnummerArray objectAtIndex:i]];
		NSString* tempString=[derStundenByteArray objectAtIndex:i];
		unsigned int tempByte=[[derStundenByteArray objectAtIndex:i]intValue];
		//NSLog(@"i: %d tempString: %@ tempByte hex: %2.2X dez: %d dezString: %@",i,tempString,tempByte,tempByte,dezString);
		NSMutableArray* tempStundenCodeArray=[[NSMutableArray alloc]initWithCapacity:4];
		for (k=0;k<4;k++)
		{
			uint8_t tempStundencode = tempByte & 0x03;
			//NSLog(@"k: %d tempStundencode hex: %2.2X dez: %d",k,tempStundencode,tempStundencode);
			[tempStundenCodeArray insertObject:[NSNumber numberWithInt:tempStundencode]atIndex:0];
			//[tempStundenArray addObject:[NSNumber numberWithInt:tempStundencode]];
			tempByte>>=2;
         
		}
		[tempStundenArray addObjectsFromArray:tempStundenCodeArray];
	}//for i
	//NSLog(@"StundenArrayAusDezArray tempStundenArray: %@",[tempStundenArray description]);
	return tempStundenArray ;
}


- (id) init
{
    //if ((self = [super init]))
//	[self Alert:@"ADWandler init vor super"];
	//NSArray* Wochentage=[[NSArray arrayWithObjects:@"MO",@"DI", @"MI", @"DO", @"FR", @"SA", @"SO",nil]retain];
	//NSArray* Raumnamen=[[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil]retain];

	self = [super initWithWindowNibName:@"AVR"];
	
	NSNotificationCenter * nc;
	
	
	
	nc=[NSNotificationCenter defaultCenter];
	
   [nc addObserver:self
          selector:@selector(LocalStatusAktion:)
              name:@"localstatus"
            object:nil];

		[nc addObserver:self
		   selector:@selector(TagplancodeAktion:) // Mausklicks im Tagplanbalken
			   name:@"Tagplancode"
			 object:nil];

	
	[nc addObserver:self
		   selector:@selector(ModifierAktion:)
			   name:@"Modifier"
			 object:nil];

	[nc addObserver:self
		   selector:@selector(ReportHandlerCallbackAktion:)
			   name:@"ReportHandlerCallback"
			 object:nil];

	[nc addObserver:self
		   selector:@selector(I2CAktion:)
			   name:@"i2c"
			 object:nil];
			 
	[nc addObserver:self
		   selector:@selector(WriteStandardAktion:) // in rAVRClient
			   name:@"WriteStandard"
			 object:nil];
			 
	[nc addObserver:self
		   selector:@selector(WriteModifierAktion:)
			   name:@"WriteModifier"
			 object:nil];

/*			 
	[nc addObserver:self
		   selector:@selector(HomeClientWriteModifierAktion:)
			   name:@"HomeClientWriteModifier"
			 object:nil];
*/			 			 
	[nc addObserver:self
		   selector:@selector(FinishLoadAktion:)
			   name:@"FinishLoad"
			 object:nil];
			 
	[nc addObserver:self
		   selector:@selector(LoadFailAktion:)
			   name:@"LoadFail"
			 object:nil];
			 
			[nc addObserver:self
		   selector:@selector(LoadDataAktion:)
			   name:@"LoadData"
			 object:nil];
	
	[nc addObserver:self
			 selector:@selector(FensterSchliessenAktion:)
				  name:@"NSWindowShouldCloseNotification"
				object:nil];
 
 // Blinkanzeige waehrend TWI-OFF
 	[nc addObserver:self
			 selector:@selector(StatusWaitAktion:)
				  name:@"StatusWait"
				object:nil];
   
 	[nc addObserver:self
			 selector:@selector(HomeDataUpdateAktion:)
				  name:@"HomeDataUpdate"
				object:nil];

  	[nc addObserver:self
			 selector:@selector(EEPROMWriteFertigAktion:)
				  name:@"EEPROMUpdateFertig"
				object:nil];

   
  	[nc addObserver:self
			 selector:@selector(EEPROMLadepositionAktion:)
				  name:@"EEPROMLadeposition"
				object:nil];

   [nc addObserver:self
          selector:@selector(EditAktion:)
              name:@"edit"
            object:nil];
   
   [nc addObserver:self
          selector:@selector(saveSettingsAktion:)
              name:@"saveSettings"
            object:nil];
 
   [nc addObserver:self
          selector:@selector(EEPROMbusycountAktion:)
              name:@"EEPROMbusycount"
            object:nil];



	
	WochenplanDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	Eingangsdaten=[[NSMutableArray alloc]initWithCapacity:0];
	EEPROMArray=[[NSMutableArray alloc]initWithCapacity:0];
   EEPROMReadDataArray=[[NSMutableArray alloc]initWithCapacity:0];
   
   
	NSFileManager *Filemanager=[NSFileManager defaultManager];

	HomedataPfad=[NSHomeDirectory() stringByAppendingPathComponent:@"documents/HomeData"];
	//NSLog(@"HomedataPfad: %@",HomedataPfad);
	if (![Filemanager fileExistsAtPath:HomedataPfad])	//noch kein Dataordner
	{
      BOOL HomedataOK =[Filemanager createDirectoryAtPath:HomedataPfad withIntermediateDirectories:NO attributes:NULL error:NULL];

		//BOOL HomedataOK=[Filemanager createDirectoryAtPath:HomedataPfad attributes:NULL];
		if (HomedataOK==NO)
			return 0;
	}
	HomePListPfad=[HomedataPfad stringByAppendingPathComponent:@"HomePList"];
	if ([Filemanager fileExistsAtPath:HomePListPfad])
	{
		HomeDic=[NSMutableDictionary dictionaryWithContentsOfFile:HomePListPfad];
	}
	if (HomeDic)
	{
		if ([HomeDic objectForKey:@"homebusarray"])
		{
			HomebusArray=[HomeDic objectForKey:@"homebusarray"];
			//NSLog(@"init HomebusArray: %@",HomebusArray);
			[self checkHomebus];
		
		}
		else	//Noch kein HomebusArray
		{
			NSLog(@"Neuer Homebusarray");
			[self HomebusAnlegen];
			
		}
	}
	else
	{
		HomeDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		NSLog(@"Neuer Homebus");
		[self HomebusAnlegen];		
		BOOL writeOL=[HomeDic writeToFile:HomePListPfad atomically:YES];
		NSLog(@"Neuer Homebus ok");
	}
	//NSLog(@"HomebusAnlegen 1");
   
   // daySettingArray lesen
	HomeDaySettingPfad = [HomedataPfad stringByAppendingPathComponent:@"daySetting"];
   if ([Filemanager fileExistsAtPath:HomeDaySettingPfad])
   {
      SettingData=[NSMutableData dataWithContentsOfFile:HomeDaySettingPfad];
   
   }

   if (SettingData)
   {
      //NSLog(@"SettingData: %@",SettingData);
   }
   else
   {
      //daySettingArray[8][16]; 
      for (uint8_t pos = 0;pos<8;pos++)
      {
         for (uint8_t byte=0;byte<16;byte++)
         {
            uint8_t code = (pos << 4) | byte;
            NSLog(@"pos: %d byte %d code: %d %02X",pos,byte,code,code);
            
          //  uint8_t p = (code & 0xF0) >>4;
          //  uint8_t b = code & 0x0F;
          //  NSLog(@"p: %d b %d ",p,b);
          //  daySettingArray[pos][byte] = (pos << 4) | byte;
            daySettingArray[pos][byte] = 0;
         }
      }
      //daySettingArray[3][15] = 0;
      int l = 8*16;
      SettingData = [NSMutableData dataWithBytes:daySettingArray length:l];
      [SettingData writeToFile:HomeDaySettingPfad atomically:YES];
   }
   NSData* returndata = [NSData dataWithContentsOfFile:HomeDaySettingPfad];
   //NSLog(@"returndata: %@",returndata);
   NSString* returndatastring = [returndata description];
   //NSLog(@"returndatastring: %@",returndatastring);
   NSArray* returndataarray = [returndatastring componentsSeparatedByString:@" "];
   //NSArray* temparray = [NSArray arrayWithBytes:returndata];
   uint8_t           tempdaySettingArray[8][16]; // 1 Zeile pro Tag, 4 bytes code, 6 bytes Data 
   int l = [returndata length];
    
   NSUInteger size = [returndata length] / sizeof(unsigned char);
    
   
   // https://stackoverflow.com/posts/21489823/edit
   NSMutableString *string = [NSMutableString stringWithCapacity:returndata.length * 3];
   NSMutableArray *zeilenarray = [[NSMutableArray alloc]initWithCapacity:0];
   daySettingStringArray = [[NSMutableArray alloc]initWithCapacity:DAYSETTINGTIEFE];
   for (int zeile=0;zeile<DAYSETTINGTIEFE;zeile++)
   {
      [daySettingStringArray addObject:[[NSMutableArray alloc]initWithCapacity:0]];
   }
   //NSMutableArray* daySettingStringArray = [[NSMutableArray alloc]initWithCapacity:DAYSETTINGTIEFE];
   for (NSUInteger offset = 0; offset < l; ++offset) 
   {
      
      uint8_t byte = ((const uint8_t *)returndata.bytes)[offset];
      uint8_t zeile =  offset/16;
      uint8_t kolonne = offset%16;
      daySettingArray[zeile][kolonne] = byte;
      [[daySettingStringArray objectAtIndex:(offset/16)]addObject: [NSString stringWithFormat:@"%02X", byte]];
      [zeilenarray addObject: [NSString stringWithFormat:@"%02X", byte]];
      
      if (offset && (offset%16 == 0))
      {
        // [daySettingStringArray addObject:[zeilenarray subarrayWithRange:NSMakeRange((offset/16-1)*16,16)]];
         
         [string appendFormat:@"\n"];
      
      }
      [string appendFormat:@"%02X\t", byte];
   }
   
   NSArray* tempArray = [NSArray  arrayWithArray:[string componentsSeparatedByString:@"\n"]];
   //NSLog(@"string: \n%@ \ndaySettingStringArray: %@",string,daySettingStringArray);
   //NSLog(@"string: \n%@ ",string);
   NSDictionary* daySettingDic = [NSDictionary dictionaryWithObject:daySettingStringArray forKey:@"daysettingarray"];
   [nc postNotificationName:@"daysetting" object:self userInfo:daySettingDic];
  
   n=0;
	aktuellerTag=0;
	IOW_busy=0;
	aktuelleMark=NSNotFound;
	//NSLog(@"HomebusAnlegen 2");
	//WebTask=idle; // nichts tun
	Webserver_busy=0;
	return self;
}	//init

- (IBAction)reportTakt:(id)sender
{
   //NSLog(@"reportTakt state: %d",[sender state]);
   
      
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [NotificationDic setObject:[NSNumber numberWithInt:[sender state]] forKey:@"takt"];
    [NotificationDic setObject: webHostIP forKey:@"webhostip"];
    [NotificationDic setObject: localHostIP forKey:@"localhostip"];
   [NotificationDic setObject: actualHostIP forKey:@"actualhostip"];
   [NotificationDic setObject:[NSNumber numberWithInt:TAKTDELAY] forKey:@"taktdelay"];
   if ([sender state] == 0)// reset Takt
   {
      [Taktpermanentcheck setState:0];
   }
   if ([Taktpermanentcheck state])
   {
      
   }
   else
   {
      
   }
  // [NotificationDic setObject:[NSNumber numberWithInt:[Taktpermanentcheck state]] forKey:@"taktpermanent"];

   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"TaktTaste" object:self userInfo:NotificationDic];

   
}

- (IBAction)reportTaktpermanent:(id)sender
{
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [NotificationDic setObject:[NSNumber numberWithInt:[sender state]] forKey:@"taktpermanent"];
   [NotificationDic setObject:[NSNumber numberWithInt:TAKTDELAY] forKey:@"taktdelay"];
   [NotificationDic setObject:[NSNumber numberWithInt:[Taktknopf state]] forKey:@"takt"];
   [NotificationDic setObject:[NSNumber numberWithInt:[sender state]] forKey:@"taktpermanent"];
    
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"TaktTaste" object:self userInfo:NotificationDic];

}


- (void)awakeFromNib
{
   NSNotificationCenter * nc =[NSNotificationCenter defaultCenter];
	//NSLog(@"AVR awake");
   char* u="80+f+0+0+7+f0+ff+ff";
   
   
   printf("b: *%x*\n", atoi("17"));

   
   char* a = "F1";
   uint8_t aa = strtol(a,nil,16);
   
   
   printf("a: %s aa: %d\n",a,aa);
   
   char* buffer= malloc(32);
   //lcd_putc('C');
   
   strcpy(buffer, u);
   
   //lcd_putc('D');
   uint8_t outbuffer[8]={};
   uint8_t index=0;
   char* linePtr = malloc(32);
   
   linePtr = strtok(buffer,"+");
   
   while (linePtr !=NULL)								// Datenstring: Bei '+' trennen
   {
      //EEPROMTxDaten[index++] = strtol(linePtr,NULL,16); //http://www.mkssoftware.com/docs/man3/strtol.3.asp
      outbuffer[index++] = strtol(linePtr,NULL,16); //http://www.mkssoftware.com/docs/man3/strtol.3.asp
      linePtr = strtok(NULL,"+");
   }
   free(linePtr);
   free(buffer);
   
     int tg=0;
   int rm=3;
   int obj=0;
   int startadr = rm*RAUMPLANBREITE + tg * TAGPLANBREITE + obj * 0x08;
   //NSLog(@"raum: %d tag: %d obj: %d startadresse: %d",rm, tg, obj, startadr);
  
   uint8_t x = 0xB1;
   uint8_t y = ~x;
   NSLog(@"x: %X y: %X",x,y);
   int newraum = startadr / 0x200;
   //newraum ;
   //NSLog(@"newraum: %d",newraum);
   
   int lb= startadr & 0xFF;
   int hb = startadr;
   hb >>=8;
   //NSLog(@"lb: %d hb: %d ",lb,hb);
   
   int lbyte=startadr%0x100;
   int hbyte=startadr/0x100;
   //NSLog(@"lbyte: %d hbyte: %d ",lbyte,hbyte);
   newraum = hbyte/0x02;
   //NSLog(@"newraum: %d",newraum);
   int status =0;
   
   status |= (1<<hbyte/2);
   //NSLog(@"status: %d",status);
   
	//[self setAktiv:NO forObjekt:4 forRaum:4];
	//[self setAktiv:YES forObjekt:3 forRaum:4];
	
	//[self setAktiv:NO forObjekt:6 forRaum:4];
	//[self setObjektTitel:@"Loetkolben" forObjekt:0 forRaum:4];
	//[self setObjektTitel:@"Oszi" forObjekt:1 forRaum:4];
	
	//[self setAktiv:NO forObjekt:7 forRaum:4];
	
   [self setObjektPopVonRaum:0];
   
   for (int raumnummer=2;raumnummer < 8;raumnummer++)
   {
      //[self setObjektTitelVonRaum:raumnummer];
   }
   
   
	// Alternative Typen setzen
  // NSLog(@"1");
   [self setTagbalkenTyp:2 forObjekt:1 forRaum:0]; // Heizung: Mode
	
   [self setTagbalkenTyp:0 forObjekt:2 forRaum:0]; // Heizung: Servo
	
   [self setTagbalkenTyp:1 forObjekt:1 forRaum:1]; // Werkstatt
	[self setTagbalkenTyp:1 forObjekt:1 forRaum:2]; // WoZi
   [self setTagbalkenTyp:1 forObjekt:1 forRaum:4]; // Labor
	//NSLog(@"2");
	NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI", @"MI", @"DO", @"FR", @"SA", @"SO",nil];
	NSArray* Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil];
	AVR_DS=[[rAVR_DS alloc]init];
	//	[WochenplanTable setDelegate:AVR_DS];
	//	[WochenplanTable setDataSource:AVR_DS];
	int i;
	NSMutableArray* tempArray=[[NSMutableArray alloc]initWithCapacity:0];
	NSArray* bitnummerArray=[NSArray arrayWithObjects: @"null", @"eins",@"zwei",@"drei",@"vier",@"fuenf",nil];
	
	/*
	 for (i=0;i<8;i++)
	 {
	 NSDictionary* tempDic=[NSDictionary dictionaryWithObject:@"AB" forKey:[bitnummerArray objectAtIndex:i%6]];
	 [tempArray addObject:tempDic];
	 }
	 */
	
	NSMutableDictionary* tempDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	for (i=0;i<8;i++)
	{
		NSNumber* Hexint=[NSNumber numberWithInt:4*i];
		NSString* hexString = [NSString stringWithFormat:@"%X", [Hexint intValue]];
		if ([hexString length] <2)
		{
			hexString=[@"0" stringByAppendingString:hexString];
		}
		//NSLog(@"hexString: %@",hexString);
		// Hexadecimal NSString to NSNumber:
		
		NSScanner *scanner;
		unsigned int tempInt;
		
		scanner = [NSScanner scannerWithString:hexString];
		[scanner scanHexInt:&tempInt];
		Hexint = [NSNumber numberWithInt:tempInt];
		
		[tempDic setObject:hexString forKey:[bitnummerArray objectAtIndex:i%6]];
	}
	[tempArray addObject:tempDic];
	//NSLog(@"3");
	
	[AVR_DS setWochenplan:tempArray];
   //NSLog(@"4");
	//	[[[self window]contentView] addSubview:WochenplanTable];
	//NSSegmentedCell* StdCell=[[NSSegmentedCell alloc]init];
	
	NSRect scRect=NSMakeRect(0,0,10,10);
	NSSegmentedControl* SC=[[NSSegmentedControl alloc]initWithFrame:scRect];
	[[SC cell]setSegmentCount:2];
	
	//Sammlung der physischen Wochenplaene
	WochenplanListe=[[NSMutableArray alloc]initWithCapacity:0];
	Wochenplan=[[NSMutableArray alloc]initWithCapacity:0];
	
	NSRect WochenplanTabRect=[WochenplanTab bounds];	// Feld des Tab
	//	NSLog(@"AVR awake WochenplanTabRect: x: %2.2f y: %2.2f",[WochenplanTab bounds].origin.x,[WochenplanTab bounds].origin.y);
	//	NSLog(@"AVR awake WochenplanTabRect: h: %2.2f w: %2.2f",[WochenplanTab bounds].size.height,[WochenplanTab bounds].size.width);
	
  	
	NSRect TagplanFeld=WochenplanTabRect;
	//TagplanFeld.origin.x+=10;
	
	//	Beginn Raum
	int raum;
	NSRect RaumViewFeld = NSMakeRect(0,0,0,0);
	for (raum=0;raum<8;raum++)
	{
      //NSLog(@"5 raum: %d",raum);
		switch (raum)
		{
			case 0:
            RaumViewFeld=[HeizungFeld  frame];
				
				break;
			case 1: //
			{
				RaumViewFeld=[WerkstattFeld  frame];
			}break;
				
			case 2: //
			{
				RaumViewFeld=[WoZiFeld frame];
			}break;
				
			case 3: //
			{
				RaumViewFeld=[BueroFeld frame];
			}break;
				
			case 4: //
			{
				RaumViewFeld=[LaborFeld frame];
			}break;
				
			case 5: //
			{
				RaumViewFeld=[OG1Feld  frame];;
			}break;
				
			case 6: //
			{
				RaumViewFeld=[OG2Feld frame];
			}break;
				
			case 7: //
			{
				RaumViewFeld=[EstrichFeld frame];
			}break;
				
				
				
		}//switch
		
		//	Dic mit den Daten von Raum:
		//	NSMutableDictionary* RaumDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
		int	AnzRaumObjekte=0;
     
      {
      AnzRaumObjekte= [self anzAktivForRaum:raum];
      }
		//NSLog(@"Raum AnzObjekte: %d",AnzRaumObjekte);
		//		NSArray* RaumAktivArray=[self aktivObjekteArrayForRaum:raum];
		
		
		int RaumTitelfeldhoehe=10;
		int RaumTagbalkenhoehe=32;				//Hoehe eines Tagbalkens
		int RaumTagplanhoehe=AnzRaumObjekte*(RaumTagbalkenhoehe)+RaumTitelfeldhoehe;	// Hoehe des Tagplanfeldes mit den (AnzRaumobjekte) Tagbalken
		int RaumTagplanAbstand=RaumTagplanhoehe+10;	// Abstand zwischen den Ecken der Tagplanfelder
		int RaumKopfbereich=50;	// Bereich ueber dem Scroller
		
		NSRect RaumScrollerFeld=RaumViewFeld;	//	Feld fuer Scroller, in dem der RaumView liegt
		// Feld im Scroller ist abhaengig von Anzahl Tagbalken
		RaumViewFeld.size.height=7*(RaumTagplanAbstand +RaumKopfbereich); // Hoehe vergroessern
		//	NSLog(@"RaumTagplanAbstand: %d	",RaumTagplanAbstand);
		
		NSScrollView* RaumScroller = [[NSScrollView alloc] initWithFrame:RaumScrollerFeld];
      
      

		//	RaumView mit rWochenplan anlegen
		rWochenplan* RaumView = [[rWochenplan alloc]initWithFrame:RaumViewFeld];
		
		// Wochenplan mit aktiven Tagplaenen einrichten
		//NSLog(@"AVR awake: Wochenplanarray Raum: %@",[[[HomebusArray objectAtIndex:raum]objectForKey:@"wochenplanarray"]description]);
		NSArray* tempWochenplanArray = [[HomebusArray objectAtIndex:raum]objectForKey:@"wochenplanarray"];
		if (raum==0)
		{
//			NSLog(@"AVR awake: Wochenplanarray Raum: %@",[[[HomebusArray objectAtIndex:raum]objectForKey:@"wochenplanarray"]description]);
			
		}
		//NSLog(@"7 HomebusArray count: %d ",[HomebusArray count]);
      // rWochenplan:
		NSArray*  tempGeometrieArray=[RaumView setWochenplanForRaum:raum mitWochenplanArray:[[HomebusArray objectAtIndex:raum]objectForKey:@"wochenplanarray"]];
      
		[RaumScroller setDocumentView:RaumView];
		[RaumScroller setBorderType:NSLineBorder];
		[RaumScroller setHasVerticalScroller:YES];
		[RaumScroller setHasHorizontalScroller:NO];
		[RaumScroller setLineScroll:10.0];
		[RaumScroller setAutohidesScrollers:NO];
		
		
		[[[WochenplanTab tabViewItemAtIndex:raum]view]addSubview:RaumScroller];
		
		float docH=[[RaumScroller documentView] frame].size.height;
		float contH=[[RaumScroller contentView] frame].size.height;
		NSPoint   newRaumScrollOrigin=NSMakePoint(0.0,docH-contH);
		//NSLog(@"raum: %d docH: %2.2f contH: %2.2f diff: %2.2f",raum, docH,contH,docH-contH);
		//newRaumScrollOrigin.y -=(RaumTagplanAbstand+RaumKopfbereich);
		int aktuellerWochentag=0;
      
		[[RaumScroller documentView] scrollPoint:newRaumScrollOrigin];
		
		
      // SegmentedControl configurieren
      
		NSRect SegFeld=RaumViewFeld;
		SegFeld.origin.y-=40;
		SegFeld.size.height=50;
		NSSegmentedControl* ObjektSeg=[[NSSegmentedControl alloc]initWithFrame:SegFeld];
		[ObjektSeg setSegmentCount:8];
		[[ObjektSeg cell] setTrackingMode:1];
		NSFont* SegFont=[NSFont fontWithName:@"Helvetica" size: 10];
		[[ObjektSeg cell] setFont:SegFont];
      [[ObjektSeg cell] setControlSize:NSControlSizeMini];
		[ObjektSeg setTarget:self];
		[ObjektSeg setAction:@selector(ObjektSegAktion:)];
		[ObjektSeg setTag:(100*raum)];
		for (i=0;i<8;i++)
		{
			[ObjektSeg setWidth:SegFeld.size.width/8-1.5 forSegment:i];
			[[ObjektSeg cell] setTag:(10*raum)+i+RAUMOFFSET forSegment:i];
			NSString* tempTitel=[[[[tempWochenplanArray objectAtIndex:0]objectForKey:@"tagplanarray"]objectAtIndex:i]objectForKey:@"objektname"];
			//NSLog(@"ObjektSeg segment: %d Titel: %@ tag: %d",i,tempTitel,(10*raum)+i+RAUMOFFSET);
			[ObjektSeg setLabel:tempTitel forSegment:i];
			int tempAktiv=[[[[[tempWochenplanArray objectAtIndex:0]objectForKey:@"tagplanarray"]objectAtIndex:i]objectForKey:@"aktiv"]intValue];
			[ObjektSeg setSelected:tempAktiv forSegment:i];
         
 		}
		[ObjektSeg setEnabled:YES];
		
      // daySettingArray init
      /*
       byte 0: raum | objekt
       byte 1: wochentag | code: aktuell: bit0, delete: bit7
       
       
       */
       
      
      for (int wt = 0;wt < 8;wt++)
      {
         for (int objekt = 0;objekt<8;objekt++)
         {
            for (int dataindex = 0;dataindex < 8;dataindex++)
            {
     //          daySettingArray[raum][objekt][wt][dataindex] = 0;
            }
         }
         
      }
         
    
      
		
		[[[WochenplanTab tabViewItemAtIndex:raum]view]addSubview:ObjektSeg];
      
      
      //NSLog(@"** raum: %d raum subviews: %@",raum,[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]description]);
      for (int i=0;i<[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]count];i++)
      {
         if ([[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]objectAtIndex:i] isKindOfClass:[NSScrollView class]])
         {
            //NSLog(@"ScrollViewgefunden: i: %d Scroller: %@",i,[[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]objectAtIndex:i ]description]);
         }
      }
		
	}//	End for Raum
   //
   
   
   NSRect EEPROMScrollerFeld=[EEPROMUpdatefeld frame];
   if (!EEPROMScroller)
   {
      //NSLog(@"neuer EEPROMScroller");
      EEPROMScroller = [[NSScrollView alloc] initWithFrame:EEPROMScrollerFeld];
      [[[WochenplanTab tabViewItemAtIndex:8]view]addSubview:EEPROMScroller];
   }
	
	//EEPROM-Feld oben im Fenster einrichten
	raum=9;
	//NSRect EEPROMFeld=[[[WochenplanTab tabViewItemAtIndex:raum]view] frame];
	NSRect EEPROMFeld=[[[self window]contentView ] frame];
	
	
	//NSLog(@"EEPROMFeld.size.height %2.2F",EEPROMFeld.size.height);
	EEPROMFeld.origin.y +=(EEPROMFeld.size.height - 40);
	EEPROMFeld.origin.x +=10;
	EEPROMFeld.size.height = 30;
	EEPROMFeld.size.width -= 70;
	EEPROMbalken=[[rEEPROMbalken alloc]initWithFrame:EEPROMFeld];
	[EEPROMbalken BalkenAnlegen];
	
	for (i=0;i<48;i++)
	{
		
	}
	//		[[[WochenplanTab tabViewItemAtIndex:raum]view]addSubview:EEPROMbalken];
	[[[self window] contentView] addSubview:EEPROMbalken];
	
	NSMutableArray* tempByteArray=[[NSMutableArray alloc]initWithCapacity:0];
	//NSArray* bitnummerArray=[NSArray arrayWithObjects: @"null", @"eins",@"zwei",@"drei",@"vier",@"fuenf",nil];
	NSString* hexString;
	for (i=0;i<8;i++)
	{
		NSNumber* Hexint=[NSNumber numberWithInt:22*i];
		hexString = [NSString stringWithFormat:@"%02X", [Hexint intValue]];
		if ([hexString length] <2)
		{
			hexString=[@"0" stringByAppendingString:hexString];
		}
		//NSLog(@"hexString: %@",hexString);
		// Hexadecimal NSString to NSNumber:
		
		NSScanner *scanner;
		unsigned int tempInt;
		
		scanner = [NSScanner scannerWithString:hexString];
		[scanner scanHexInt:&tempInt];
		Hexint = [NSNumber numberWithInt:tempInt];
		//NSLog(@"hexString: %@ Hexint: %d",hexString,Hexint);
      
		[tempDic setObject:hexString forKey:[bitnummerArray objectAtIndex:i%6]];
		[tempByteArray addObject:hexString];
	}
	
	
	
	//NSLog(@"EEPROMbalken tempByteArray: %@",[tempByteArray description]);
	//	[EEPROMbalken setStundenArrayAusByteArray:tempByteArray];
	[EEPROMbalken setStundenArrayAusByteArray:tempByteArray];
	
	
	
	//NSLog(@"awake: PListPfad: %@ HomebusArray: %@",HomePListPfad,[HomebusArray description]);
	NSFileManager *Filemanager=[NSFileManager defaultManager];
	
	NSMutableDictionary* tempHomeDic;
	if ([Filemanager fileExistsAtPath:HomePListPfad])
	{
		tempHomeDic=[NSMutableDictionary dictionaryWithContentsOfFile:HomePListPfad];
		//NSLog(@"load homedic: %@",[tempHomeDic description]);
		if (tempHomeDic)
		{
			[tempHomeDic setObject:HomebusArray forKey:@"homebusarray"];
		}
	}
	else
	{
		
		//NSLog(@"kein homedic \nHomebusArray %@",[HomebusArray description]);
		tempHomeDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[tempHomeDic setObject:HomebusArray forKey:@"homebusarray"];
		
		//[tempHomeDic setObject:HomebusArray forKey:@"homebusarray"];
	}
	
	//NSLog(@"save homedic: %@",[tempHomeDic description]);
	BOOL writeOK=[tempHomeDic writeToFile:HomePListPfad atomically:YES];
	//NSLog(@"save PList: writeOK: %d",writeOK);
	[[self window]makeKeyAndOrderFront:self];
	EEPROMTabelle=[[NSMutableArray alloc]initWithCapacity:0];
	[EEPROMTable setDelegate:AVR_DS];
	[EEPROMTable setDataSource:AVR_DS];
	[EEPROMPlan addSubview:EEPROMTextfeld];
   [EEPROMScroller addSubview:EEPROMPlan];
   
	NSString* logString=[NSString string];
	logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x02]];
	logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",161]];
	//NSLog(@"logString: %@",logString);
	
	//I2C einschalten
	//	[self setI2CStatus:1];
	
	uint8_t Data=0xac
	;
	uint8_t StundenCodeA=(Data>>0);	//	erster Balken im char, bit 3, 2
	uint8_t StundenCodeB=(Data>>2);	//	zweiter Balken im char, bits 1, 0
	uint8_t StundenCodeC=(Data>>4);	//	erster Balken im char, bit 3, 2
	uint8_t StundenCodeD=(Data>>6);	//	zweiter Balken im char, bits 1, 0
	
	//NSLog(@"Data: %02X CodeA: %02X CodeB: %02X CodeC: %02X CodeD: %02X",Data, StundenCodeA, StundenCodeB, StundenCodeC, StundenCodeD);
	StundenCodeA &= 0x03;
	StundenCodeB &= 0x03;
	StundenCodeC &= 0x03;
	StundenCodeD &= 0x03;
	//NSLog(@"StundenCodeA: %02X StundenCodeB: %02X CodeC: %02X CodeD: %02X", StundenCodeA, StundenCodeB, StundenCodeC, StundenCodeD);
	
	WEBDATA_DS=[[rWEBDATA_DS alloc]init];
	WEBDATATabelle=[[NSMutableArray alloc]initWithCapacity:0];
	[WEBDATATable setDelegate:WEBDATA_DS];
	[WEBDATATable setDataSource:WEBDATA_DS];
	//NSLog(@"DATUM: %@",DATUM);
	NSString* DatumString = [NSString stringWithFormat:@"RH %@",DATUM];
	
	[DatumFeld setStringValue:DatumString];
	NSString* VersionString = [NSString stringWithFormat:@"Version %@",VERSION];
	[VersionFeld setStringValue:VersionString];
   [WochenplanTab setDelegate:self];

   [WochenplanTab selectTabViewItemAtIndex:0];
   
	/*
    NSMutableDictionary* StartDicA=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
    [StartDicA setObject:@"AAA" forKey:@"art"];
    [StartDicA setObject:[NSNumber numberWithInt:1] forKey:@"wert"];
    [WEBDATATabelle addObject:StartDicA];
    NSMutableDictionary* StartDicB=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
    [StartDicB setObject:@"BBB" forKey:@"art"];
    [StartDicB setObject:[NSNumber numberWithInt:2] forKey:@"wert"];
    [WEBDATATabelle addObject:StartDicB];
    
    //NSLog(@"AVR awake WEBDATATabelle: %@",[WEBDATATabelle description]);
    [WEBDATA_DS setValueKeyArray:WEBDATATabelle];
    [WEBDATATable reloadData];
    */
   //	[self setSegmentLabel:@"Ofen" forSegment:1 forRaum:4];
	//[self setObjektTitel:@"Ofen" forObjekt:1 forRaum:4];

//   NSString *host = @"https://www.ruediheimlicher.ch/Data/EEE.txt?myvar=%@";
   /*
   NSString *host = @"http://www.ruediheimlicher.ch/Data/EEE.txt?myvar=%@";
   
   
   NSString *urlString = [NSString stringWithFormat:host, @"texttowritetofile"];
   NSLog(@"EEE urlString: %@",urlString);
   NSURL *url = [NSURL URLWithString:urlString];
   NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
   //[request setHTTPMethod:@"POST"];
     NSURLResponse* responseRequest;
   NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseRequest error:nil];
   NSLog(@"EEE returnData: %@ responseRequest URL: %@",returnData,responseRequest.URL);
   */
   writeEEPROManzeige.intValue = 0;
   //NSLog(@"AVR awake end");
   
   // check freeline in daysettingarray
   uint8_t freielinie = self.freeDaySettingline;
   NSLog(@"freeDaySettingline: %d",freielinie);
   
   NSArray* d = [self daySettingDataVon:0 vonObjekt:1 anWochentag:0];
   if (d)
   {
     
      //NSLog(@"d: %@ stundenparray: %@",d,[self StundenArrayAusByteArray:d]);
      
   }
   else
   {
      NSLog(@"keine Daten");
   }
   
   NSDictionary* daySettingDic = [NSDictionary dictionaryWithObject:daySettingStringArray forKey:@"daysettingarray"];
   [nc postNotificationName:@"daysetting" object:self userInfo:daySettingDic];

}
- (void)LocalStatusAktion:(NSNotification*)note
{
   NSLog(@"AVR LocalStatusAktion note: %@",[[note userInfo]description]);
    localNetz = YES;
}

- (void)setWebHostIP:(NSString*) ip
{
   webHostIP = ip;
}
- (void)setLocalHostIP:(NSString*)ip
{
   localHostIP = ip;
}
   
- (void)setAktuelleHostIP:(NSString*)ip
   {
      actualHostIP = ip;
   }
   
   

- (void)setLocalStatus
{
   [LocalTaste setEnabled:YES];
   //[TWIStatusTaste setEnabled:YES];

}

- (void)setRaum:(int)derRaum
{
	NSRect RaumViewFeld;

		switch (derRaum)
		{
			case 0:
				RaumViewFeld=[HeizungFeld  frame];
				
				break;
			case 1: // 
			{
				RaumViewFeld=[WerkstattFeld  frame];
			}break;
				
			case 2: // 
			{
				RaumViewFeld=[WoZiFeld frame];
			}break;
				
			case 3: // 
			{
				RaumViewFeld=[BueroFeld frame];
			}break;
				
			case 4: // 
			{
				RaumViewFeld=[LaborFeld frame];	
			}break;
				
			case 5: // 
			{
				RaumViewFeld=[OG1Feld  frame];;
			}break;
				
			case 6: // 
			{
				RaumViewFeld=[OG2Feld frame];
			}break;
				
			case 7: // 
			{
				RaumViewFeld=[EstrichFeld frame];
			}break;
				
				
		}//switch
		
		//	Dic mit den Daten von Raum:
		//	NSMutableDictionary* RaumDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];
		int	AnzRaumObjekte= [self anzAktivForRaum:derRaum];
		//NSLog(@"Raum AnzObjekte: %d",AnzRaumObjekte);
		//		NSArray* RaumAktivArray=[self aktivObjekteArrayForRaum:raum];
		
		
		int RaumTitelfeldhoehe=10;
		int RaumTagbalkenhoehe=32;				//Hoehe eines Tagbalkens
		int RaumTagplanhoehe=AnzRaumObjekte*(RaumTagbalkenhoehe)+RaumTitelfeldhoehe;	// Hoehe des Tagplanfeldes mit den (AnzRaumobjekte) Tagbalken
		int RaumTagplanAbstand=RaumTagplanhoehe+10;	// Abstand zwischen den Ecken der Tagplanfelder
		int RaumKopfbereich=50;	// Bereich ueber dem Scroller
		
		NSRect RaumScrollerFeld=RaumViewFeld;	//	Feld fuer Scroller, in dem der RaumView liegt
		// Feld im Scroller ist abhaengig von Anzahl Tagbalken
		RaumViewFeld.size.height=7*(RaumTagplanAbstand +RaumKopfbereich); // Hoehe vergroessern
		//NSLog(@"RaumTagplanAbstand: %d	",RaumTagplanAbstand);
		//NSLog(@"RaumViewFeld.size.height: %2.2f	",RaumViewFeld.size.height);
		NSScrollView* RaumScroller = [[NSScrollView alloc] initWithFrame:RaumScrollerFeld];
		
		
		//	RaumView mit rWochenplan anlegen
		rWochenplan* RaumView = [[rWochenplan alloc]initWithFrame:RaumViewFeld];
		
		// Wochenplan mit aktiven Tagplaenen einrichten
		if (derRaum==0)
		{
		//NSLog(@"AVR awake: Wochenplanarray Raum: %@",[[[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"]description]);
		}
		NSArray* tempWochenplanArray=[[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"];
		
		NSArray*  GeometrieArray=[RaumView setWochenplanForRaum:derRaum mitWochenplanArray:[[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"]];

		// View-Hierarchie 	
				
		[RaumScroller setDocumentView:RaumView];
		[RaumScroller setBorderType:NSLineBorder];
		[RaumScroller setHasVerticalScroller:YES];
		[RaumScroller setHasHorizontalScroller:NO];
		[RaumScroller setLineScroll:10.0];
		[RaumScroller setAutohidesScrollers:NO];
		
		//[RaumTabView addSubview:RaumScroller];
		
		[[[WochenplanTab tabViewItemAtIndex:derRaum]view]addSubview:RaumScroller];
		
		/*
		NSPoint   newRaumScrollOrigin=NSMakePoint(0.0,NSMaxY([[RaumScroller documentView] frame])
												  -NSHeight([[RaumScroller contentView] bounds]));
		NSLog(@"newRaumScrollOrigin.y: %2.2f RaumTagplanAbstand: %d",newRaumScrollOrigin.y, RaumTagplanAbstand);
		newRaumScrollOrigin.y -=(RaumTagplanAbstand+RaumKopfbereich);
		*/
		
		
		float docH=[[RaumScroller documentView] frame].size.height;
		float contH=[[RaumScroller contentView] frame].size.height;
		NSPoint   newRaumScrollOrigin=NSMakePoint(0.0,docH-contH);
//		NSLog(@"raum: %d docH: %2.2f contH: %2.2f diff: %2.2f",raum, docH,contH,docH-contH);
		//newRaumScrollOrigin.y -=(RaumTagplanAbstand+RaumKopfbereich);
		int aktuellerWochentag=4;
		
		if (aktuellerWochentag)
		{
//		newRaumScrollOrigin.y -=	[[GeometrieArray objectAtIndex:aktuellerWochentag-1]floatValue];
		}
		
		[[RaumScroller documentView] scrollPoint:newRaumScrollOrigin];
		
		// SegmentedControl configurieren
   
		NSRect SegFeld=RaumViewFeld;
		SegFeld.origin.y-=40;
		SegFeld.size.height=50;
		NSSegmentedControl* ObjektSeg=[[NSSegmentedControl alloc]initWithFrame:SegFeld];
		[ObjektSeg setSegmentCount:8];
		[[ObjektSeg cell] setTrackingMode:1];
		NSFont* SegFont=[NSFont fontWithName:@"Helvetica" size: 10];
		[[ObjektSeg cell] setFont:SegFont];
   [[ObjektSeg cell] setControlSize:NSControlSizeMini];
		[ObjektSeg setTarget:self];
		[ObjektSeg setAction:@selector(ObjektSegAktion:)];
		int i;
		for (i=0;i<8;i++)
		{
			[ObjektSeg setWidth:SegFeld.size.width/8-1.5 forSegment:i];
			[[ObjektSeg cell] setTag:(10*derRaum)+i+RAUMOFFSET forSegment:i];
			NSString* tempTitel=[[[[tempWochenplanArray objectAtIndex:0]objectForKey:@"tagplanarray"]objectAtIndex:i]objectForKey:@"objektname"];
			NSLog(@"ObjektSeg segment: %d Titel: %@",i,tempTitel);
			[ObjektSeg setLabel:tempTitel forSegment:i];
			int tempAktiv=[[[[[tempWochenplanArray objectAtIndex:0]objectForKey:@"tagplanarray"]objectAtIndex:i]objectForKey:@"aktiv"]intValue];
			[ObjektSeg setSelected:tempAktiv forSegment:i];
		}
		[ObjektSeg setEnabled:YES];
		
		
		[[[WochenplanTab tabViewItemAtIndex:derRaum]view]addSubview:ObjektSeg];
		
		
	}

- (void)checkUpdate
{
   int update=0;
   //Check fuer neue Werte auf eepromupdatedaten.txt
   NSMutableDictionary* NotificationDic=[[NSMutableDictionary alloc]initWithCapacity:0];
   [NotificationDic setObject:[NSNumber numberWithInt:1] forKey:@"update"];
   
   NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
   [nc postNotificationName:@"EEPROMUpdate" object:self userInfo:NotificationDic];

   // Notific mit HomeDataUpdateAktion: auf AVRClient
}


- (void)checkHomebus
{
	//NSLog(@"checkHomebus");
	NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI", @"MI", @"DO", @"FR", @"SA", @"SO",nil];
	NSArray* Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil];
	int i,k,l,s;
	for (i=0;i<[Raumnamen count];i++) // Raumdics kontrollieren
	{
		if ([HomebusArray objectAtIndex:i])	// Raumdic fuer Raum i ist da
		{
			NSMutableDictionary* tempRaumDic=[HomebusArray objectAtIndex:i];
         //NSLog(@"tempRaumDic: %@",tempRaumDic);
			if (![tempRaumDic objectForKey:@"raumname"])
		
         {
				[tempRaumDic setObject:[Raumnamen objectAtIndex:i] forKey:@"raumname"];
			}
			if (![tempRaumDic objectForKey:@"raum"])
			{
				[tempRaumDic setObject:[NSNumber numberWithInt:i] forKey:@"raum"];
			}
			
			if (![tempRaumDic objectForKey:@"anzaktiv"])
			{
				[tempRaumDic setObject:[NSNumber numberWithInt:8] forKey:@"anzaktiv"];	// Anzahl aktivierter Objekte in diesem Raum
			}
			
			if ([tempRaumDic objectForKey:@"wochenplanarray"]) // Wochenplanarray fuer Raum ist da
			{
				for (k=0;k<[Wochentage count];k++) // 7 Tage
				{
					if ([[tempRaumDic objectForKey:@"wochenplanarray"]objectAtIndex:k]) // TagplanDic fuer Wochentag ist da
					{
						// WochenplanDic fuer Wo tag
						NSMutableDictionary* tempWochenplanDic=(NSMutableDictionary*)[[tempRaumDic objectForKey:@"wochenplanarray"]objectAtIndex:k];
						if ([tempWochenplanDic objectForKey:@"tagplanarray"]) // TagplanArray ist da
						{
							// TagplanArray fuer Tag k 
							NSMutableArray* tempTagplanArray=(NSMutableArray*)[tempWochenplanDic objectForKey:@"tagplanarray"];
                     
                     
                     
							for (l=0;l<8;l++) //8 Objekte
							{
                        //NSLog(@"Raum: %d Tag: %d",i,k);
								if ([tempTagplanArray objectAtIndex:l]) // TagplanDic fuer Objekt l ist da
								{
                           //NSLog(@"Object ist da");
									//TagplanDic fuer Woche i, Wochentag k, Objekt l
									NSMutableDictionary* tempTagplanDic=(NSMutableDictionary*)[tempTagplanArray objectAtIndex:l];
                          // NSLog(@"tempTagplanDic: %@",tempTagplanDic);
									if (![tempTagplanDic objectForKey:@"aktiv"])
									{
                              NSLog(@"noch kein Plan aktiv");
                              [tempTagplanDic setObject:[NSNumber numberWithInt:1] forKey:@"aktiv"];
									}
                           
									if (![tempTagplanDic objectForKey:@"objekt"])
									{
                              NSLog(@"noch keine objektnummer");
                              [tempTagplanDic setObject:[NSNumber numberWithInt:l] forKey:@"objekt"];
									}
									if (![tempTagplanDic objectForKey:@"tagbalkentyp"])
									{
                              NSLog(@"noch kein tagbalkentyp");
                              [tempTagplanDic setObject:[NSNumber numberWithInt:0] forKey:@"tagbalkentyp"];
									}
                           
									
									if ([tempTagplanDic objectForKey:@"stundenplanarray"]) // Stundenplanarray ist da
									{
										NSMutableArray* tempStundenplanArray=(NSMutableArray*)[tempTagplanDic objectForKey:@"stundenplanarray"];
										for (s=0;s<24;s++)
										{
											if ([tempStundenplanArray objectAtIndex:s])
											{
												
											}
											else
											{
												NSLog(@"kein Stundencode fuer Raum: %d Tag: %d objekt: %d stunde: %d",i,k,l,s);
												[tempStundenplanArray addObject:[NSNumber numberWithInt:0]];
											}
											
											
										}
									}
									else // kein Stundenplanarray
									{
										NSLog(@"kein Stundenplanarray fuer Raum: %d Tag: %d objekt: %d",i,k,l);
										[tempTagplanDic setObject:[self neuerStundenplan] forKey:@"stundenplanarray"];
									}
									
								}
								else
								{
									NSLog(@"kein TagplanplanDic fuer Raum: %d Tag: %d objekt: %d",i,k,l);
									NSMutableDictionary* tempTagplanDic=[[NSMutableDictionary alloc]initWithCapacity:0];
									[tempTagplanDic setObject:[Raumnamen objectAtIndex:i] forKey:@"raumname"];
									[tempTagplanDic setObject:[NSNumber numberWithInt:i] forKey:@"raum"];
									[tempTagplanDic setObject:[Wochentage objectAtIndex:k] forKey:@"wochentag"];
                           [tempTagplanDic setObject:[NSNumber numberWithInt:k] forKey:@"wt"];
									[tempTagplanDic setObject:[NSString stringWithFormat:@"Objekt %d",l] forKey:@"objektname"];
									[tempTagplanDic setObject:[self neuerStundenplan] forKey:@"stundenplanarray"];
									[tempTagplanDic setObject:[NSNumber numberWithInt:1] forKey:@"aktiv"];
                           
									[tempTagplanArray addObject:tempTagplanDic];
									
								} // tagplanDic
								
							}// for l
						} // Tagplanarray ist da
						else
						{
						NSLog(@"kein TagplanDic fuer Raum: %d Tag: %d",i,k);
						
						}
					}
					else
					{
						NSLog(@"kein Tagplan fuer Raum: %d Tag: %d",i,k);
					}
				}
			}
			else
			{
				NSLog(@"kein Wochenplan fuer Raum: %d ",i);
				NSMutableArray* tempWochenplanplanArray =(NSMutableArray*)[self neuerWochenplanForRaum:i];
				
			}
			
			
		}
		else
		{	
			NSLog(@"Dic fuer fehlenden Raum anlegen");
			// Dic fuer fehlenden Raum anlegen 
			NSMutableDictionary* tempRaumDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			[tempRaumDic setObject:[Raumnamen objectAtIndex:i] forKey:@"raumname"];
			[tempRaumDic setObject:[NSNumber numberWithInt:i] forKey:@"raum"];
			// Array der Wochentage anlegen
			NSMutableArray* tempWochenplanArray =(NSMutableArray*)[self neuerWochenplanForRaum:i];
			
			[tempRaumDic setObject:tempWochenplanArray forKey:@"wochenplanarray"];
			[HomebusArray addObject:tempRaumDic];
		}	
	}
	
	
	
}

- (void)HomebusAnlegen
{
	NSLog(@"HomebusAnlegen");
	NSArray* Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil];

	HomebusArray=[[NSMutableArray alloc]initWithCapacity:8];
	int i;
	for (i=0;i<8;i++)
	{
		// Arrays fuer Raume anlegen 
		
		NSMutableDictionary* tempRaumDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[tempRaumDic setObject:[Raumnamen objectAtIndex:i] forKey:@"raumname"];
		[tempRaumDic setObject:[NSNumber numberWithInt:i] forKey:@"raum"];
		[tempRaumDic setObject:[NSNumber numberWithInt:8] forKey:@"anzaktiv"];	// Anzahl aktivierter Objekte in diesem Raum
		// Array der Wochentage anlegen
		NSMutableArray* tempWochenplanArray =(NSMutableArray*)[self neuerWochenplanForRaum:i];
		//[tempWochenplanArray retain];
		//NSLog(@"i: %d tempWochenplanArray: : %@",i,[tempWochenplanArray description]);
		[tempRaumDic setObject:tempWochenplanArray forKey:@"wochenplanarray"];
		//NSLog(@"i: %d tempRaumDic: : %@",i,[tempRaumDic description]);
		[HomebusArray addObject:tempRaumDic];
	}
	//NSLog(@"HomeDic setObject:HomebusArray ");
	
	[HomeDic setObject:HomebusArray forKey:@"homebusarray"];
	
	
	//NSLog(@"HomebusAnlegen end");
}


- (void)saveSettingsAktion:(NSNotification*)note
{
   //NSLog(@"saveSettingsAktion note: %@",[[note userInfo]description]);
   
   [HomebusArray setArray:[NSMutableArray arrayWithArray:[[note userInfo]objectForKey:@"homebusarray"]]];
   
   for (int raumindex=0;raumindex<8;raumindex++)
   {
      [self setRaum:raumindex];
   }
   NSMutableDictionary* tempHomeDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:HomebusArray,@"homebusarray", nil];
   BOOL writeOK=[tempHomeDic writeToFile:HomePListPfad atomically:YES];
	//NSLog(@"save PList: writeOK: %d",writeOK);
}


- (NSArray*)neuerWochenplanForRaum:(int)derRaum
{
	NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI", @"MI", @"DO", @"FR", @"SA", @"SO",nil];
	NSArray* Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil];
	
	// Array der Wochentage anlegen
	NSMutableArray* tempWochenplanArray =[[NSMutableArray alloc]initWithCapacity:8];
	int k;
	for (k=0;k<7;k++) // Dics fuer die Wochentage anlegen
	{
		NSMutableDictionary* tempWochenplanDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[tempWochenplanDic setObject:[Raumnamen objectAtIndex:derRaum] forKey:@"raumname"];
		[tempWochenplanDic setObject:[NSNumber numberWithInt:derRaum] forKey:@"raum"];
		[tempWochenplanDic setObject:[Wochentage objectAtIndex:k] forKey:@"wochentag"];
      [tempWochenplanDic setObject:[NSNumber numberWithInt:k] forKey:@"wt"];
		
		[tempWochenplanArray addObject:tempWochenplanDic];
		NSMutableArray* tempTagplanArray =(NSMutableArray*)[self neuerTagplanForTag:k forRaum:derRaum];
	//	[tempWochenplanDic setObject:tempTagplanArray forKey:@"tagplanarray"];
	}
	return tempWochenplanArray;
}

- (NSArray*)neuerTagplanForTag:(int)derWochentag forRaum:(int) derRaum
{
	NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI", @"MI", @"DO", @"FR", @"SA", @"SO",nil];
	NSArray* Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil];
	
	// Array der Tagplaene anlegen
	NSMutableArray* tempTagplanArray =[[NSMutableArray alloc]initWithCapacity:8];
	int l,m;
	// Tagplaene fuer die einzelnen Objekte anlegen
	for (l=0;l<8;l++)
	{
		NSMutableDictionary* tempTagplanDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[tempTagplanDic setObject:[Raumnamen objectAtIndex:derRaum] forKey:@"raumname"];
		[tempTagplanDic setObject:[NSNumber numberWithInt:derRaum] forKey:@"raum"];
		[tempTagplanDic setObject:[Wochentage objectAtIndex:derWochentag] forKey:@"wochentag"];
      [tempTagplanDic setObject:[NSNumber numberWithInt:derWochentag] forKey:@"wt"];
		[tempTagplanDic setObject:[NSString stringWithFormat:@"Objekt %d",l] forKey:@"objektname"];
		
		// eingefügt 3.6.09
		[tempTagplanDic setObject:[NSNumber numberWithInt:l] forKey:@"objekt"];
		
		
		[tempTagplanDic setObject:[NSNumber numberWithInt:1] forKey:@"aktiv"];
		[tempTagplanDic setObject:[NSNumber numberWithInt:0] forKey:@"tagbalkentyp"]; // default Typ
		[tempTagplanArray addObject:tempTagplanDic];
		NSMutableArray* tempStundenplanArray =[[NSMutableArray alloc]initWithCapacity:8];
		[tempTagplanDic setObject:tempStundenplanArray forKey:@"stundenplanarray"];
		for (m=0;m<24;m++) //Stundenplaene 
		{
			NSNumber* tempStundencode=[NSNumber numberWithInt:0];
			[tempStundenplanArray addObject:tempStundencode];
		}
	}
	
	
	return tempTagplanArray;
}

- (NSMutableArray*)neuerStundenplan
{
	NSMutableArray* tempStundenplanArray =[[NSMutableArray alloc]initWithCapacity:8];
	int l;
	// Code fuer die einzelnen Stunden anlegen
	for (l=0;l<24;l++)
	{
		[tempStundenplanArray addObject:[NSNumber numberWithInt:0]];
	
	}
	return tempStundenplanArray;
}

- (int)anzAktivForRaum:(int)derRaum
{
	int i, anzAktiv=0;
	NSArray* tempWochenplanArray=[[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"];
		//NSLog(@"anzAktivForRaum tempWochenplanArray: %@",[[tempWochenplanArray objectAtIndex:derRaum] description]);

	if (tempWochenplanArray && [tempWochenplanArray count])
	{
		NSArray* tempTagplanArray=[[tempWochenplanArray objectAtIndex:0] objectForKey:@"tagplanarray"];
		if (tempTagplanArray && [tempTagplanArray count])
		{
			for (i=0;i<8;i++)
			{
			NSNumber* aktivNumber=[[tempTagplanArray objectAtIndex:i]objectForKey:@"aktiv"];
			if (aktivNumber && [aktivNumber intValue])
				{
					anzAktiv++;
				}
			}
		}
	}
	//NSLog(@"Raum: %d  anzAktiv: %d",derRaum, anzAktiv);
	return anzAktiv;
}

- (NSArray*)aktivObjekteArrayForRaum:(int)derRaum
{
	NSMutableArray* tempObjektArray=[[NSMutableArray alloc]initWithCapacity:0];

	int i, anzAktiv=0;
	NSArray* tempWochenplanArray=[[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"];
	//NSLog(@"aktivObjekteForRaum: %d tempWochenplanArray: %@",derRaum, [[tempWochenplanArray objectAtIndex:derRaum] description]);

	if (tempWochenplanArray && [tempWochenplanArray count])
	{
		NSArray* tempTagplanArray=[[tempWochenplanArray objectAtIndex:0] objectForKey:@"tagplanarray"];
		if (tempTagplanArray && [tempTagplanArray count])
		{
			for (i=0;i<[tempTagplanArray count];i++)
			{
			NSNumber* aktivNumber=[[tempTagplanArray objectAtIndex:i]objectForKey:@"aktiv"];
			if (aktivNumber && [aktivNumber intValue])
				{
					[tempObjektArray addObject:[tempTagplanArray objectAtIndex:i]];
					anzAktiv++;
				}
			}
		}
	}
	//NSLog(@"Raum: %d anzAktiv: %d tempObjektArray: %@",derRaum,anzAktiv, [[tempObjektArray valueForKey:@"objektname"] description]);
	return tempObjektArray;
}

- (void)setAktiv:(int)derStatus forObjekt:(int)dasObjekt forRaum:(int)derRaum
{
	NSMutableArray* tempWochenplanArray=[HomebusArray valueForKey:@"wochenplanarray"];
	//NSLog(@"setAktiv tempWochenplanArray count: %d",[tempWochenplanArray count]);
	//NSLog(@"setAktiv Raum: %d  Dic: %@",derRaum, [[tempWochenplanArray objectAtIndex:derRaum] description]);
	int wochentag;
	for (wochentag=0;wochentag<7;wochentag++)
	{
		//NSLog(@"setAktiv wochentag: %d",wochentag);
		NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:derRaum]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:dasObjekt];
		[tempTagplanDic setObject:[NSNumber numberWithInt:derStatus]forKey:@"aktiv"];
		//NSLog(@"setAktiv wochentag: %d  tempTagplanDic: %@",wochentag, [tempTagplanDic description]);
	
	}//for wochentag
}

- (void)setTagbalkenTyp:(int)derTyp forObjekt:(int)dasObjekt forRaum:(int)derRaum
{
	NSMutableArray* tempWochenplanArray=[HomebusArray valueForKey:@"wochenplanarray"];
	//NSLog(@"setTagplanTyp tempWochenplanArray count: %d",[tempWochenplanArray count]);
	//NSLog(@"setTagplanTyp Raum: %d  Dic: %@",derRaum, [[tempWochenplanArray objectAtIndex:derRaum] description]);
	int wochentag;
	for (wochentag=0;wochentag<7;wochentag++)
	
	{
		//NSLog(@"setTagplanTyp wochentag: %d",wochentag);
		NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:derRaum]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:dasObjekt];
		[tempTagplanDic setObject:[NSNumber numberWithInt:derTyp]forKey:@"tagbalkentyp"];
		//NSLog(@"setTagplanTyp wochentag: %d  tempTagplanDic: %@",wochentag, [tempTagplanDic description]);
	
	}//for wochentag

}//setTagplanTyp

- (void)setObjektTitelVonRaum:(int)raumnummer
{
   NSLog(@"AVR setObjektTitelVonRaum: %d",raumnummer);
   //  von Einstellungen  [self setObjektnamenVonArray:[[[[[HomebusArray objectAtIndex:raumnummer]objectForKey:@"wochenplanarray"]objectAtIndex:0]objectForKey:@"tagplanarray"]valueForKey:@"objektname"]];
   
   NSArray* tempObjektnamenArray = [[[[[HomebusArray objectAtIndex:raumnummer]objectForKey:@"wochenplanarray"]objectAtIndex:0]objectForKey:@"tagplanarray"]valueForKey:@"objektname"];
   //NSLog(@"tempObjektnamenArray: %@",[tempObjektnamenArray description] );
 	
   int tag=(100*raumnummer);
   for (int objektnummer=0;objektnummer < ([tempObjektnamenArray count]);objektnummer++)
   {
      [[[[WochenplanTab tabViewItemAtIndex:raumnummer]view]viewWithTag:tag]setLabel:[tempObjektnamenArray objectAtIndex:objektnummer] forSegment:objektnummer];
    }



}

- (void)setObjektTitel:(NSString*)derTitel forObjekt:(int)dasObjekt forRaum:(int)derRaum
{
	NSMutableArray* tempWochenplanArray=[HomebusArray valueForKey:@"wochenplanarray"];
	int wochentag;
	for (wochentag=0;wochentag<7;wochentag++)
	{
	//	NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:derRaum]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:dasObjekt];

		NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:derRaum]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:dasObjekt];
		//NSLog(@"Raum: %d Objekt: %d tempTagplanDic: %@",derRaum, dasObjekt, [tempTagplanDic description]);
		[tempTagplanDic setObject:derTitel forKey:@"objektname"];
	
	}//for wochentag
	
	// Label in SegmentedControl setzen
	int tag=(100*derRaum);
	[[[[WochenplanTab tabViewItemAtIndex:derRaum]view]viewWithTag:tag]setLabel: derTitel forSegment:dasObjekt];

	
}

- (void)setSegmentLabel:(NSString*)derTitel forSegment:(int)dasSegment forRaum:(int)derRaum
{
	//int tag=(10*derRaum)+dasSegment+RAUMOFFSET;
	int tag=(100*derRaum);
	//NSLog(@"setSegmentLabel: tag: %d Label: %@",tag, derTitel);
	NSView* tempView = [[[WochenplanTab tabViewItemAtIndex:derRaum]view]viewWithTag:tag];
	//NSLog(@"tempView: %@",tempView );
	//NSLog(@"segment: %@",[[[WochenplanTab tabViewItemAtIndex:derRaum]view]viewWithTag:tag]);
	[[[[WochenplanTab tabViewItemAtIndex:derRaum]view]viewWithTag:tag]setLabel: derTitel forSegment:dasSegment];

}

- (void)setStundenplanArray:(NSMutableArray*)derStundenplanArray forObjekt:(int)dasObjekt forRaum:(int)derRaum
{
	NSMutableArray* tempWochenplanArray=(NSMutableArray*)[HomebusArray valueForKey:@"wochenplanarray"];
	int wochentag;
	for (wochentag=0;wochentag<7;wochentag++)
	{
		NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:derRaum]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:dasObjekt];
		[tempTagplanDic setObject:derStundenplanArray forKey:@"stundenplanarray"];
	
	}//for wochentag

}


- (void)setStundenplanArray:(NSMutableArray*)derStundenplanArray forWochentag:(int)derWochentag forObjekt:(int)dasObjekt forRaum:(int)derRaum
{
   // in updatePListMitDicArray
   
   //NSLog(@"setStundenplanArray raum: %d objekt: %d wochentag: %d stundenplan: %@",derRaum,dasObjekt, derWochentag,[derStundenplanArray description]);
   
	NSMutableArray* tempWochenplanArray=[HomebusArray valueForKey:@"wochenplanarray"];
	
   NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:derRaum]objectAtIndex:derWochentag]objectForKey:@"tagplanarray"]objectAtIndex:dasObjekt];
 
   //NSLog(@"setStundenplanArray  stundenplanarray vor %@",[[tempTagplanDic objectForKey:@"stundenplanarray" ]description]);
   [tempTagplanDic setObject:derStundenplanArray forKey:@"stundenplanarray"];
   //NSLog(@"setStundenplanArray  stundenplanarray nach %@",[[tempTagplanDic objectForKey:@"stundenplanarray" ]description]);
   
   
}

- (NSDictionary*)StundenplanDicVonRaum:(int)raum vonObjekt:(int)objekt vonWochentag:(int)wochentag
{
	NSDictionary* tempStundenplanDic=[[[[[HomebusArray objectAtIndex:raum]objectForKey:@"wochenplanarray"]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:objekt];
   
	
   //NSLog(@"tempStundenplanArray: %@",[tempStundenplanArray description]);
 		//NSMutableDictionary* tempTagplanDic=[[[[tempWochenplanArray objectAtIndex:raum]objectAtIndex:wochentag]objectForKey:@"tagplanarray"]objectAtIndex:objekt];
      
	
   return tempStundenplanDic;
}




- (NSScrollView*)ScrollerVonRaum:(int)raum
{
   NSScrollView* scroller;
   //NSLog(@"** raum: %d raum subviews: %@",raum,[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]description]);
   int scrollerindex = -1;
   for (int i=0;i<[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]count];i++)
   {
      if ([[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]objectAtIndex:i] isKindOfClass:[NSScrollView class]])
      {
         //NSLog(@"ScrollerVonRaum ScrollViewgefunden: i: %d Scroller: %@",i,[[[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]objectAtIndex:i ]description]);
         scrollerindex = i;
         //scroller = [[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]objectAtIndex:i ];
      }
   }
   
   return [[[[WochenplanTab tabViewItemAtIndex:raum]view]subviews]objectAtIndex:scrollerindex ];
}




- (void)TagplancodeAktion:(NSNotification*)note

   // Mausklicks im Tagplanbalken speichern
{
	//NSLog(@"AVR TagplancodeAktion: %@",[[note userInfo]description]);
	//NSLog(@"AVR TagplancodeAktion: %@",[[note userInfo]objectForKey:@"quelle"]);
	//NSArray* Raumnamen=[[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil]retain];
	//NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA",@"SO",nil];
	
	int Wochentag=[[[note userInfo]objectForKey:@"wochentag"]intValue];
	int Stunde=[[[note userInfo]objectForKey:@"stunde"]intValue];
	int ON=[[[note userInfo]objectForKey:@"on"]intValue];
	int Feld=[[[note userInfo]objectForKey:@"feld"]intValue];
	NSArray* lastONArray=[[note userInfo]objectForKey:@"lastonarray"];
	int Objekt=0;
	
	if ([[note userInfo]objectForKey:@"objekt"])
	{
		Objekt=[[[note userInfo]objectForKey:@"objekt"]intValue];
	}
	
	//NSString* Raumname=[[note userInfo]objectForKey:@"raumname"];
	
	int RaumIndex=[[[note userInfo]objectForKey:@"raum"]intValue];
	//NSLog(@"AVR TagplancodeAktion  RaumIndex: %d Wochentag: %d Objekt: %d Stunde: %d", RaumIndex, Wochentag, Objekt, Stunde);
	//NSLog(@"lastONArray: %@",[lastONArray description]);
	NSMutableArray* tempWochenplanArray;
	
	if ([HomebusArray objectAtIndex:RaumIndex])	// Daten aus PList: Element von HomeDic
	{
		//NSLog(@"TagplancodeAktion Raumdic");
		if ([[HomebusArray objectAtIndex:RaumIndex]objectForKey:@"wochenplanarray"])
		{
			
			tempWochenplanArray=(NSMutableArray*)[[HomebusArray objectAtIndex:RaumIndex]objectForKey:@"wochenplanarray"];
			//NSLog(@"tempWochenplanArray");
//			NSLog(@"tempWochenplanArray: %@", [tempWochenplanArray description]);
			NSMutableArray* tempTagplanArray=(NSMutableArray*)[[tempWochenplanArray objectAtIndex:Wochentag]objectForKey:@"tagplanarray"];
			if (tempTagplanArray)
			{
				//NSLog(@"TagplancodeAktion tempTagplanArray");
				NSMutableArray* tempStundenplanArray=(NSMutableArray*)[[tempTagplanArray objectAtIndex:Objekt]objectForKey:@"stundenplanarray"];
				//NSLog(@"TagplancodeAktion tempStundenplanArray: %@",[tempStundenplanArray description]);
            if (tempStundenplanArray)
				{
					if ((Stunde==99) || (Stunde==98) ) // All-taste
					{
						//NSLog(@"TagplancodeAktion  Stunde=99: on: %d",[[[note userInfo]objectForKey:@"on"]intValue]);
						
						{//alle auf ON setzen
							int a;
							for (a=0;a<24;a++)
							{
								//NSLog(@"TagplancodeAktion Mutable"); 
								if (ON==9) // Wert ersetzen
								{
								[tempStundenplanArray replaceObjectAtIndex:a withObject:[lastONArray objectAtIndex:a]];
								}
								else // alle auf ON
								{
								[tempStundenplanArray replaceObjectAtIndex:a withObject:[NSNumber numberWithInt:ON]];
								}
								
							}
							//NSLog(@"TagplancodeAktion  Stunde=99: tempStundenplanArray: %@",[tempStundenplanArray description]);
						}
					}
 					else if (Stunde==97) // Datenbalken All-taste
					{
                  //NSLog(@"TagplancodeAktion  Stunde=97 note: %@",[[note userInfo]description]);
                  for (int i=0;i<24;i++)
                  {
                     [tempStundenplanArray replaceObjectAtIndex:i withObject:[[[note  userInfo]objectForKey:@"lastonarray"] objectAtIndex:i]];
                  }
                  
               }
					else
					{
						//NSLog(@"TagplancodeAktion tempStundenplanArray vor: %@",[tempStundenplanArray description]);
						//NSLog(@"TagplancodeAktion Mutable vor"); 
						
                  [tempStundenplanArray replaceObjectAtIndex:Stunde withObject:[NSNumber numberWithInt:ON]];
						//NSLog(@"TagplancodeAktion Mutable nach"); 
						//NSLog(@"TagplancodeAktion tempStundenplanArray nach: %@",[tempStundenplanArray description]);
					}
					//NSLog(@"tempStundenplanArray vor saveOK: %@",[tempStundenplanArray description]);
					
               
               int saveOK=[self saveHomeDic];
					
               
               //NSLog(@"tempStundenplanArray nach saveOK: %d",saveOK);
				}
				//NSLog(@"tempTagplanArray nach: %@", [tempTagplanArray description]);
			}
         else
         {
            NSLog(@"kein tempTagplanArray");
         }
			//NSLog(@"tempWochenplanArray nach: %@", [tempWochenplanArray description]);
		}
	}
}


- (void)ModifierAktion:(NSNotification*)note
{
	NSLog(@"AVR ModifierAktion: %@",[[note userInfo]description]);
	//NSLog(@"AVR TagplancodeAktion: %@",[[note userInfo]objectForKey:@"quelle"]);
	//NSArray* Raumnamen=[[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil]retain];
	//NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI",@"MI",@"DO",@"FR",@"SA",@"SO",nil];
	
	int Wochentag=[[[note userInfo]objectForKey:@"wochentag"]intValue];
	int Stunde=[[[note userInfo]objectForKey:@"stunde"]intValue];
	//int ON=[[[note userInfo]objectForKey:@"on"]intValue];
	//int feld=[[[note userInfo]objectForKey:@"feld"]intValue];
	int Objekt=0;
	
	if ([[note userInfo]objectForKey:@"objekt"])
	{
		Objekt=[[[note userInfo]objectForKey:@"objekt"]intValue];
	}
	
	NSString* Raumname=[[note userInfo]objectForKey:@"raumname"];
	
	int RaumIndex=[[[note userInfo]objectForKey:@"raum"]intValue];
		
	NSLog(@"AVR ModifierAktion  RaumIndex: %d Wochentag: %d Objekt: %d Stunde: %d", RaumIndex, Wochentag, Objekt, Stunde);
	//NSLog(@"HomebusArray: %@",[HomebusArray description]);
   
   
   return;
   
	NSMutableArray* tempWochenplanArray;
	if ([HomebusArray objectAtIndex:RaumIndex])	
	{
		//NSLog(@"AVR ModifierAktion Raumdic");
		if ([[HomebusArray objectAtIndex:RaumIndex]objectForKey:@"wochenplanarray"])
		{
			
			tempWochenplanArray=[[HomebusArray objectAtIndex:RaumIndex]objectForKey:@"wochenplanarray"];
			//NSLog(@"tempWochenplanArray: %@", [tempWochenplanArray description]);
			
			int wochentag;
			
			//Gegebene Daten in allen Tagen einsetzen
			for (wochentag=0;wochentag<7;wochentag++)
			{
				
				NSMutableArray* tempTagplanArray=[[tempWochenplanArray objectAtIndex:wochentag]objectForKey:@"tagplanarray"];
				if (tempTagplanArray)
				{
					//NSLog(@"AVR ModifierAktion tempTagplanArray");
					NSMutableArray* tempStundenplanArray=[[tempTagplanArray objectAtIndex:Objekt]objectForKey:@"stundenplanarray"];
					if (tempStundenplanArray)
					{
						if (Stunde==99) // All-taste
						{
							if ([[note userInfo]objectForKey:@"lastonarray"])							
							{
								
								[tempStundenplanArray setArray:[[note userInfo]objectForKey:@"lastonarray"]];
								
							}
							
						}
                  else if (Stunde==98) // ctrl-taste
						{
							if ([[note userInfo]objectForKey:@"lastonarray"])
							{
								
								//[tempStundenplanArray setArray:[[note userInfo]objectForKey:@"lastonarray"]];
								
							}
							
						}

						else
						{
							//NSLog(@"tempStundenplanArray vor: %@",[tempStundenplanArray description]);
							[tempStundenplanArray replaceObjectAtIndex:Stunde withObject:[[note userInfo]objectForKey:@"on"]];
						}
						//NSLog(@"tempStundenplanArray vor saveOK: %@",[tempStundenplanArray description]);
						
						//NSLog(@"tempStundenplanArray nach saveOK: %d",saveOK);
					}
					//NSLog(@"tempTagplanArray nach: %@", [tempTagplanArray description]);
				}
				//NSLog(@"tempWochenplanArray nach: %@", [tempWochenplanArray description]);
			} // for wochentag
		}
		int saveOK=[self saveHomeDic];
		//NSLog(@"AVR ModifierAktion nach saveOK: %d",saveOK);
	}
	//NSLog(@"AVR ModifierAktion Schluss");
	return;

	
}
- (void)EditAktion:(NSNotification*)note
{
   //NSLog(@"EditAktion");
   [[self window]makeFirstResponder:WriteWocheFeld];
   //[WriteWocheFeld performClick:NULL];
}


- (IBAction)ObjektSegAktion:(id)sender
{
   // SegmentedControl wurde angeklickt: Tagplanbalken einfuegen oder loeschen
   int clickedSegment = [sender selectedSegment];
	int Status=[sender isSelectedForSegment:clickedSegment];
	
   int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
   
   //NSLog(@"clickedSegmentTag: %d Status: %d ",clickedSegmentTag,Status);
	//NSLog(@"aus superview: %@",[[sender superview]viewWithTag:clickedSegmentTag]);
	//NSLog(@"origin.x %2.2f size.width: %2.2f",[sender frame].origin.x,[sender frame].size.width);
	int Raum=(clickedSegmentTag-RAUMOFFSET)/10;
	int Segment=(clickedSegmentTag-RAUMOFFSET)%10;
	
	//NSLog(@"Raum: %d Segment: %d",Raum, Segment);
   if(([[NSApp currentEvent] modifierFlags] & NSEventModifierFlagOption)  != 0)
	{
		NSTextField* LabelTextFeld;
		//NSLog(@"ObjektSegAktion Alt");
		
		if ([[sender superview]viewWithTag:clickedSegmentTag]) // Es hat ein Textfeld fuer CickedSegmentTag
		{
			LabelTextFeld=[[sender superview]viewWithTag:clickedSegmentTag];
			//NSLog(@"LabelTextFeld ist da: %@",[LabelTextFeld stringValue]);
			[sender setLabel:[LabelTextFeld stringValue] forSegment:clickedSegment];
			if ([HomebusArray objectAtIndex:Raum])
			{
				NSLog(@"TagplancodeAktion Raumdic");
				if ([[HomebusArray objectAtIndex:Raum]objectForKey:@"wochenplanarray"])
				{
					NSView* tempTabview=[[WochenplanTab tabViewItemAtIndex:Raum]view];
					
					NSMutableArray* tempWochenplanArray=(NSMutableArray*)[[HomebusArray objectAtIndex:Raum]objectForKey:@"wochenplanarray"];
					//NSLog(@"tempWochenplanArray");
					//NSLog(@"tempWochenplanArray: %@", [tempWochenplanArray description]);
					int wd;
					for (wd=0;wd<7;wd++) // Titel im Tagplanbalken 'clickedSegment' an jedem Tag einsetzen
					{
						NSMutableArray* tempTagplanArray=(NSMutableArray*)[[tempWochenplanArray objectAtIndex:wd]objectForKey:@"tagplanarray"];
						if (tempTagplanArray)
						{
							
							//NSLog(@"tempTagplanArray Objekt: %d Titel: %@",clickedSegment,[[tempTagplanArray objectAtIndex:clickedSegment]objectForKey:@"objektname"]);
							[[tempTagplanArray objectAtIndex:clickedSegment]setObject:[LabelTextFeld stringValue] forKey:@"objektname"];
							//NSLog(@"Objekt: %d",wd);
							int TagplanMark=100*Raum + 10*wd+ clickedSegment + WOCHENPLANOFFSET;
							//NSLog(@"Wochentag: %d Objekt: %d TagplanMark %d",wd,clickedSegment,TagplanMark);
							if ([tempTabview viewWithTag:TagplanMark])
							{
								//NSLog(@"Mark: %d Tagplanbalken %d ist da. Titel: %@",TagplanMark,wd, [LabelTextFeld stringValue]);
								[[tempTabview viewWithTag:TagplanMark]setTitel:[LabelTextFeld stringValue]];
								//[[[sender superview] viewWithTag:TagplanMark]setTitel:[LabelTextFeld stringValue]];
								[[tempTabview viewWithTag:TagplanMark]setNeedsDisplay:YES];
							}
							
						}
						
					} // for wd
				}
				
			}
			int saveOK=[self saveHomeDic];
			[LabelTextFeld removeFromSuperview];
			int erfolg=[[self window]makeFirstResponder:[self window]];
			//[LabelTextFeld release];
			aktuelleMark=NSNotFound;
		}
		else
		{
			if ((aktuelleMark<NSNotFound)&&[[sender superview]viewWithTag:aktuelleMark])
			{
            NSString* tempLabel=[[[sender superview]viewWithTag:aktuelleMark]stringValue];
            
            int lastSegment=(aktuelleMark-RAUMOFFSET)%10;;
            NSLog(@"neues LabelTextFeld  aktuelleMark: %dlastLabel: %@ ",aktuelleMark,tempLabel);
            [self saveLabel:tempLabel forRaum:Raum forSegment:lastSegment];
            [[[sender superview]viewWithTag:aktuelleMark]removeFromSuperview];
			}
			//NSLog(@"neues LabelTextFeld");
			[sender setSelected:YES forSegment:clickedSegment];
			NSRect LabelFeld=[sender frame];
			LabelFeld.origin.y -=20;
			LabelFeld.origin.x += clickedSegment*(LabelFeld.size.width/8);
			LabelFeld.size.height =20;
			LabelFeld.size.width =80;
			LabelTextFeld=[[NSTextField alloc]initWithFrame:LabelFeld];
			[[sender superview]addSubview:LabelTextFeld];
         
			int erfolg=[[self window]makeFirstResponder:LabelTextFeld];
			[LabelTextFeld setStringValue:[sender labelForSegment:clickedSegment]];
			[LabelTextFeld setAction:@selector(saveLabeltext:)];
			//[LabelTextFeld selectText:nil];
			[LabelTextFeld setTag:clickedSegmentTag];
			aktuelleMark=clickedSegmentTag;
			
		}
		
	}
	else
	{
		NSLog(@"");
		NSLog(@"ObjektSegAktion Standard aktuelleMark: %ld",aktuelleMark);
		if ((aktuelleMark < NSNotFound)&&[[sender superview]viewWithTag:aktuelleMark])
      {
			NSString* tempLabel=[[[sender superview]viewWithTag:aktuelleMark]stringValue];
			
			int lastSegment=(aktuelleMark-RAUMOFFSET)%10;;
			NSLog(@"Standard:aktuelleMark: %d lastLabel: %@",aktuelleMark,tempLabel);
			[self saveLabel:tempLabel forRaum:Raum forSegment:lastSegment];
			[[[sender superview]viewWithTag:aktuelleMark]removeFromSuperview];
      }
      
		//NSLog(@"TagplancodeAktion Raumdic");
		if ([[HomebusArray objectAtIndex:Raum]objectForKey:@"wochenplanarray"])
		{
			//NSLog(@"ObjetSegAktion WochenplanArray da");
			NSMutableArray* tempWochenplanArray=(NSMutableArray*)[[HomebusArray objectAtIndex:Raum]objectForKey:@"wochenplanarray"];
			
			int wd;
			for (wd=0;wd<7;wd++) // Titel im Tagplanbalken 'clickedSegment' an jedem Tag einsetzen
			{
				NSMutableArray* tempTagplanArray=(NSMutableArray*)[[tempWochenplanArray objectAtIndex:wd]objectForKey:@"tagplanarray"];
				if (tempTagplanArray)
				{
					
					//NSLog(@"tempTagplanArray Objekt: %d Titel: %@",clickedSegment,[[tempTagplanArray objectAtIndex:clickedSegment]objectForKey:@"objektname"]);
					[[tempTagplanArray objectAtIndex:clickedSegment]setObject:[NSNumber numberWithInt:Status] forKey:@"aktiv"];
					
				}
			}
			[self setRaum:Raum];
			int saveOK=[self saveHomeDic];
		}
	}
	
}

/*
- (IBAction)saveLabeltext:(id)sender
{
	int labelmark=(int)[sender tag];
	NSLog(@"saveLabeltext: labelmark:%d",labelmark);
	NSString* tempLabel=[sender stringValue];
	int tempRaum=(labelmark-RAUMOFFSET)/10;
	int tempSegment=(labelmark-RAUMOFFSET)%10;
	[self saveLabel:tempLabel forRaum:tempRaum forSegment:tempSegment];
	[sender removeFromSuperview];
}
*/

- (void)saveLabel:(NSString*)dasLabel forRaum:(int)derRaum forSegment:(int)dasSegment
{
	NSLog(@"saveLabel: %@  Raum: %d Segment: %d",dasLabel, derRaum, dasSegment);
	if ([[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"])
	{
		NSView* tempTabview=[[WochenplanTab tabViewItemAtIndex:derRaum]view];
		
		NSMutableArray* tempWochenplanArray=(NSMutableArray*)[[HomebusArray objectAtIndex:derRaum]objectForKey:@"wochenplanarray"];
		//NSLog(@"tempWochenplanArray");
		//NSLog(@"tempWochenplanArray: %@", [tempWochenplanArray description]);
		int wd;
		for (wd=0;wd<7;wd++) // Titel im Tagplanbalken 'clickedSegment' an jedem Tag einsetzen
		{
			NSMutableArray* tempTagplanArray=(NSMutableArray*)[[tempWochenplanArray objectAtIndex:wd]objectForKey:@"tagplanarray"];
			if (tempTagplanArray)
			{
				
				//NSLog(@"tempTagplanArray Objekt: %d Titel: %@",clickedSegment,[[tempTagplanArray objectAtIndex:clickedSegment]objectForKey:@"objektname"]);
				[[tempTagplanArray objectAtIndex:dasSegment]setObject:dasLabel forKey:@"objektname"];
				//NSLog(@"Objekt: %d",wd);
				int TagplanMark=100*derRaum + 10*wd+ dasSegment + WOCHENPLANOFFSET;
				//NSLog(@"Wochentag: %d Objekt: %d TagplanMark %d",wd,clickedSegment,TagplanMark);
				//if ([tempTabview viewWithTag:TagplanMark])
				if ([tempTabview viewWithTag:TagplanMark])
					//if ([[sender superview] viewWithTag:TagplanMark])
				{
					//NSLog(@"Mark: %d Tagplanbalken %d ist da. Titel: %@",TagplanMark,wd, [LabelTextFeld stringValue]);
					[[tempTabview viewWithTag:TagplanMark]setTitel:dasLabel];
					//[[[sender superview] viewWithTag:TagplanMark]setTitel:[LabelTextFeld stringValue]];
					[[tempTabview viewWithTag:TagplanMark]setNeedsDisplay:YES];
					//[[[sender superview] viewWithTag:TagplanMark]setNeedsDisplay:YES];
				}
			}
			
		} // for wd
		[self setRaum:derRaum];
		
	}
	
}

- (IBAction)reportRaumPop:(id)sender
{
   
   NSLog(@"reportRaumPop");
   [self setObjektPopVonRaum:[sender indexOfSelectedItem]];
}
- (IBAction)reportObjektPop:(id)sender
{
   NSLog(@"reportObjektPop");
}


- (void)setObjektPopVonRaum:(int)raumnummer
{
   //NSLog(@"AVR setObjektPopVonRaum: %d",raumnummer);
   //  von Einstellungen  [self setObjektnamenVonArray:[[[[[HomebusArray objectAtIndex:raumnummer]objectForKey:@"wochenplanarray"]objectAtIndex:0]objectForKey:@"tagplanarray"]valueForKey:@"objektname"]];
   [ObjektPop removeAllItems];
   NSArray* tempObjektnamenArray = [[[[[HomebusArray objectAtIndex:raumnummer]objectForKey:@"wochenplanarray"]objectAtIndex:0]objectForKey:@"tagplanarray"]valueForKey:@"objektname"];
   //NSLog(@"tempObjektnamenArray: %@",[tempObjektnamenArray description] );
   [ObjektPop addItemsWithTitles:tempObjektnamenArray];
}




- (void)ReportHandlerCallbackAktion:(NSNotification*)note
{
	NSLog(@"ReportHandlerCallbackAktion note: %@",[[note userInfo]description]);
	if ([[note userInfo]objectForKey:@"datenarray"]&&[[[note userInfo]objectForKey:@"datenarray"] count])
	{
		NSArray* Wochentage=[NSArray arrayWithObjects:@"MO",@"DI", @"MI", @"DO", @"FR", @"SA", @"SO",nil];
		NSArray* Raumnamen=[NSArray arrayWithObjects:@"Heizung", @"Werkstatt", @"WoZi", @"Buero", @"Labor", @"OG1", @"OG2", @"Estrich", nil];
		
		NSArray* Datenarray=[[note userInfo]objectForKey:@"datenarray"];//Array der Reports
		NSString* byte0=[Datenarray objectAtIndex:0]; // ReportID
		NSString* byte1=[Datenarray objectAtIndex:1];
		
		NSLog(@"byte0: %@ byte1: %@",byte0,byte1);
		NSScanner* ErrScanner = [NSScanner scannerWithString:byte1];
		unsigned int scanWert=0;
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
		switch ([byte0 intValue]) // Report ID 
		{
			case 1: // Callback wird nicht angesprochen
			{
				//NSLog(@"Report ID: %d",[byte0 intValue]);
				
			}break;
			case 2:		//	write-Report
				[Eingangsdaten removeAllObjects];
				//NSLog(@"write Report");
				break;
				
			case 3:		//	read-Report		
				anzBytes=[byte1 intValue];	//Anz Daten im Report
				//NSLog(@"read Report: anzBytes: %d",anzBytes);
				for (i=0;i<anzBytes;i++)
				{
					
					[Eingangsdaten addObject:[Datenarray objectAtIndex:i+2]];
					
				}
				
				break;
				
		}//byte0
		
		
		
		if ([Eingangsdaten count])//&&[Eingangsdaten count]==AnzahlDaten)
		{
			
			NSArray* bitnummerArray=[NSArray arrayWithObjects: @"null", @"eins",@"zwei",@"drei",@"vier",@"fuenf",@"++",@"++",nil];
			NSLog(@"CallBackAktion Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
			
			// EEPROMbalken der letzten Zeile anzeigen. Meist ist nur eine Zeile vorhanden.
			NSMutableArray* tempEEPROMArray=[[NSMutableArray alloc]initWithCapacity:0];
			
			
			int k,bit;
			bit=0;
			//		for (k=0;k<[Eingangsdaten count]/6+1;k++)
			for (k=0;k<[Eingangsdaten count]/6;k++)
			{
				NSMutableDictionary* tempReportDic=[[NSMutableDictionary alloc]initWithCapacity:0];
				[tempReportDic setObject:[Datenarray objectAtIndex:0] forKey:@"report"];
				[tempEEPROMArray removeAllObjects];
				for (bit=0;bit<6;bit++)
				{
					if (k*6+bit<[Eingangsdaten count])
					{
						[tempReportDic setObject:[Eingangsdaten objectAtIndex:k*6+bit] forKey:[bitnummerArray objectAtIndex:bit]];
						[tempEEPROMArray addObject:[Eingangsdaten objectAtIndex:k*6+bit]];
					}
					else//Auffüllen
					{
						
					}
				}
				NSLog(@"k: %d tempReportDic: %@",k,[tempReportDic description]);
				[EEPROMArray addObject:tempReportDic];
				
			}
			//NSLog(@"ReportHandlerCallbackAktion EEPROMArray: %@",[EEPROMArray description]);
			
			
			
			[AVR_DS setWochenplan:EEPROMArray];
			
			[EEPROMTable reloadData];
			
			
			for (k=0;k<6;k++)
			{
				//[tempEEPROMArray addObject:
			}
			NSTabView* tempTabview= WochenplanTab;
			int Raum=[(NSPopUpButton*)[tempTabview viewWithTag:10090]indexOfSelectedItem];
			int Objekt=[(NSPopUpButton*)[tempTabview viewWithTag:10091]indexOfSelectedItem];
			int Wochentag=[(NSPopUpButton*)[tempTabview viewWithTag:10092]indexOfSelectedItem];
			NSLog(@"ReportHandlerCallbackAktion: Raum: %d Objekt: %d Wochentag: %d",Raum, Objekt, Wochentag);
			NSLog(@"ReportHandlerCallbackAktion tempEEPROMArray: %@",[tempEEPROMArray description]);
			[EEPROMbalken setStundenArrayAusByteArray:tempEEPROMArray];
			[EEPROMbalken setRaumString:[Raumnamen objectAtIndex:Raum]];
			[EEPROMbalken setObjektString:[[NSNumber numberWithInt:Objekt]stringValue]];
			[EEPROMbalken setWochentagString:[Wochentage objectAtIndex:Wochentag]];
			IOW_busy=0;
		}
		
	}
	NSLog(@"ReportHandlerCallbackAktion end");
}

- (int)saveHomeDic
{
	//NSLog(@"saveHomeDic: HomePListPfad: %@",HomePListPfad);
	//NSLog(@"saveHomeDic: HomeDic: %@",[HomeDic description]);
	BOOL writeOK=[HomeDic writeToFile:HomePListPfad atomically:YES];
	//NSLog(@"saveHomeDic: writeOK: %d",writeOK);
	return writeOK;
}

- (NSArray*)HomebusArray
{
   return HomebusArray;
}

- (void)setHomebusStatus: (int)derStatus
{
	// TWI des Homebus während der Uebertragung vom IOWarrior aussetzen
	NSLog(@"setHomebusStatus: Status: %d",derStatus);
	switch (derStatus)
	{
	case 0:
	
	break;
	case 1:
	
	break;
	
	}//switch derStatus
}

- (void)I2CAktion:(NSNotification*)note
{
	//NSLog(@"I2CAktion note: %@",[[note userInfo]description]);
	if ([[note userInfo]objectForKey:@"fertig"])
	{
	NSLog(@"I2CAktion Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
	}

}

/* In AVR-Client verschoben
- (void)WriteStandardAktion:(NSNotification*)note
{
	if ([TWIStatusTaste state])
	{
	//NSLog(@"TWIStatustaste: %d",[TWIStatusTaste state]);
	NSAlert *Warnung = [[[NSAlert alloc] init] autorelease];
	[Warnung addButtonWithTitle:@"OK"];
//	[Warnung addButtonWithTitle:@""];
//	[Warnung addButtonWithTitle:@""];
//	[Warnung addButtonWithTitle:@"Abbrechen"];
	[Warnung setMessageText:[NSString stringWithFormat:@"%@",@"Homebus aktiv!"]];
	
	NSString* s1=@"Der Homebus muss deaktiviert sein, um auf das EEPROM zu schreiben.";
	NSString* s2=@"";
	NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s1,s2];
	[Warnung setInformativeText:InformationString];
	[Warnung setAlertStyle:NSWarningAlertStyle];
	
	int antwort=[Warnung runModal];

	}
//	else
	{
	//NSLog(@"WriteStandardAktion note: %@",[[note userInfo]description]);
	int Raum=[[[note userInfo]objectForKey:@"raum"]intValue];
	int Wochentag=[[[note userInfo]objectForKey:@"wochentag"]intValue];
	int Objekt=[[[note userInfo]objectForKey:@"objekt"]intValue];
	NSArray* DatenArray=[[note userInfo]objectForKey:@"stundenbytearray"];
	
	NSMutableDictionary* HomeClientDic=[[[NSMutableDictionary alloc]initWithDictionary:[note userInfo]]autorelease];
	
	int I2CIndex=[I2CPop indexOfSelectedItem];
	
	NSString* EEPROM_i2cAdresseString=[I2CPop itemTitleAtIndex:I2CIndex];
	
	[HomeClientDic setObject:EEPROM_i2cAdresseString forKey:@"eepromadressestring"];
	
	[HomeClientDic setObject:[NSNumber numberWithInt:[I2CPop indexOfSelectedItem]] forKey:@"eepromadressezusatz"];
	AnzahlDaten=0x20; //32 Bytes, TAGPLANBREITE;
	unsigned int EEPROM_i2cAdresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresseString];
	int ScannerErfolg=[theScanner scanHexInt:&EEPROM_i2cAdresse];
	[HomeClientDic setObject:[NSNumber numberWithInt:EEPROM_i2cAdresse] forKey:@"eepromadresse"];
	
	
	uint16_t i2cStartadresse=Raum*RAUMPLANBREITE + Objekt*TAGPLANBREITE+ Wochentag*0x08;
	//NSLog(@"i2cStartadresse: %04X",i2cStartadresse);
	uint8_t lb = i2cStartadresse & 0x00FF;
	[HomeClientDic setObject:[NSNumber numberWithInt:lb] forKey:@"lbyte"];
	uint8_t hb = i2cStartadresse >> 8;
	[HomeClientDic setObject:[NSNumber numberWithInt:hb] forKey:@"hbyte"];
	[HomeClientDic setObject:DatenArray forKey:@"stundenbytearray"];
	NSLog(@"WriteStandardAktion Raum: %d wochentag: %d Objekt: %d EEPROM: %02X lb: 0x%02X hb: 0x%02X ",Raum, Wochentag, Objekt,EEPROM_i2cAdresse,lb, hb);
	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	[nc postNotificationName:@"HomeClientWriteStandard" object:self userInfo:HomeClientDic];
	
//	[self writeEEPROM:EEPROM_i2cAdresse anAdresse:i2cStartadresse mitDaten:DatenArray];
	}
}
*/


/* In AVRCLient verschoben
- (void)WriteModifierAktion:(NSNotification*)note
{
	if ([TWIStatusTaste state])
	{
		NSLog(@"TWIStatustaste: %d",[TWIStatusTaste state]);
		NSAlert *Warnung = [[[NSAlert alloc] init] autorelease];
		[Warnung addButtonWithTitle:@"OK"];
		//	[Warnung addButtonWithTitle:@""];
		//	[Warnung addButtonWithTitle:@""];
		//	[Warnung addButtonWithTitle:@"Abbrechen"];
		[Warnung setMessageText:[NSString stringWithFormat:@"%@",@"Homebus aktiv!"]];
		
		NSString* s1=@"Der Homebus muss deaktiviert sein, um auf das EEPROM zu schreiben.";
		NSString* s2=@"";
		NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s1,s2];
		[Warnung setInformativeText:InformationString];
		[Warnung setAlertStyle:NSWarningAlertStyle];
		
		int antwort=[Warnung runModal];
		
	}
	else
	{
		
		int Raum=[[[note userInfo]objectForKey:@"raum"]intValue];
		int Objekt=[[[note userInfo]objectForKey:@"objekt"]intValue];
		NSArray* DatenArray=[[note userInfo]objectForKey:@"modifierstundenbytearray"];
		int I2CIndex=[I2CPop indexOfSelectedItem];
		NSString* EEPROM_i2cAdresseString=[I2CPop itemTitleAtIndex:I2CIndex];
		AnzahlDaten=0x20; //32 Bytes, TAGPLANBREITE;
		unsigned int EEPROM_i2cAdresse;
		NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresseString];
		int ScannerErfog=[theScanner scanHexInt:&EEPROM_i2cAdresse];
		
		
		//2.7.08
		uint16_t i2cStartadresse=Raum*RAUMPLANBREITE + Objekt*TAGPLANBREITE;
		
		
		int i;
		NSString* logString=[NSString string];
		for(i=0;i<[DatenArray count];i++)
		{
			if ( (i%8==0))
			{
				logString=[logString stringByAppendingString:@"\n        "];
			}
			
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",[[DatenArray objectAtIndex:i]intValue]]];
		}
		
		//NSLog(@"logString: %@",logString);
		//NSLog(@"WriteModifierAktion Raum: %d  EEPROM: %02X i2cStartadresse: 0x%04X Laenge: %d logString: %@",Raum, EEPROM_i2cAdresse, i2cStartadresse,[DatenArray count],logString);
		
		{
			[self writeEEPROM:EEPROM_i2cAdresse anAdresse:i2cStartadresse mitDaten:DatenArray];
			
		}
		
	} // Homebus aktiv
}
*/

/*
- (IBAction)readTagplan:(id)sender
{
	NSLog(@"AVR readTagplan");
	
	

	int tagIndex=[TagPop indexOfSelectedItem];
	NSString* Tag=[TagPop itemTitleAtIndex:tagIndex];
	int I2CIndex=[I2CPop indexOfSelectedItem];
	NSString* EEPROM_i2cAdresse=[I2CPop itemTitleAtIndex:I2CIndex];
	AnzahlDaten=0x20; //32 Bytes, TAGPLANBREITE
	unsigned int i2cadresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresse];
	
	if ([theScanner scanHexInt:&i2cadresse])
	{
		//NSLog(@"readTagplan: EEPROM_i2cAdresse string: %@ int: %x	",EEPROM_i2cAdresse,i2cadresse);
		
	}
	
   NSLog(@"PList Homebusarray: %@",[[HomebusArray objectAtIndex:0]description]);
	[self readEthTagplan:i2cadresse vonAdresse:tagIndex*TAGPLANBREITE anz:0x20];//32 Bytes, TAGPLANBREITE	return;
	
   return;
	
//	[self setI2CStatus:1];
//	[self readTagplan:i2cadresse vonAdresse:tagIndex*TAGPLANBREITE anz:0x20];//32 Bytes, TAGPLANBREITE
//	[self setI2CStatus:0];

}
*/
- (IBAction)readWochenplan:(id)sender
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



- (IBAction)writeWochenplan:(id)sender
{
//	if ([IOWTimer isValid])
//		[IOWTimer invalidate];
	aktuellerTag=0;
	NSLog(@"writeWochenplan");
	NSMutableDictionary* infoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[infoDic setObject:[NSNumber numberWithInt:0] forKey:@"tag"];
	int TabIndex=[WochenplanTab indexOfTabViewItem:[WochenplanTab selectedTabViewItem]];
	
	NSLog(@"writeWochenplan selected Item: %d",TabIndex);
	
	[infoDic setObject:[NSNumber numberWithInt:TabIndex] forKey:@"raum"];
	
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
	AnzahlDaten=0x20; //32 Bytes, TAGPLANBREITE;
	int i2cadresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresse];
	
	if ([theScanner scanHexInt:&i2cadresse])
	{
		//NSLog(@"readTagplan: EEPROM_i2cAdresse string: %@ int: %x	",EEPROM_i2cAdresse,i2cadresse);
		
	}
	//NSLog(@"readWoche: EEPROM_i2cAdresse: %x tagIndex: %d MemAdresse: %x",i2cadresse, aktuellerTag,aktuellerTag*TAGPLANBREITE);
	IOW_busy=1;
	[self readTagplan:i2cadresse vonAdresse:aktuellerTag*TAGPLANBREITE anz:0x20];//32 Bytes, TAGPLANBREITE
	
	
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


// Aktion mit USBWarrior
- (void)setI2CStatus:(int)derStatus 
{
	[readTagTaste setEnabled:NO];
   [readWocheTaste setEnabled:NO];
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* i2cStatusDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	[i2cStatusDic setObject:[NSNumber numberWithInt:derStatus]forKey:@"status"];
	NSLog(@"AVR  setI2CStatus: Status: %d",derStatus);
	[nc postNotificationName:@"i2cstatus" object:self userInfo:i2cStatusDic];

}


- (void)readTagplan:(int)i2cAdresse vonAdresse:(int)startAdresse anz:(int)anzDaten
{
   NSLog(@"rAVR readTagplan ");
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* readEEPROMDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	NSMutableArray* i2cAdressArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Adressierung EEPROM
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x02]];						// write-Report
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x83]];						// Startbit 3 bytes ohne Stopbit
	[i2cAdressArray addObject:[NSNumber numberWithInt:i2cAdresse]];					// I2C-Adresse EEPROM mit WRITE
	int lbyte=startAdresse%0x100;
	int hbyte=startAdresse/0x100;
	
	[i2cAdressArray addObject:[NSNumber numberWithInt:hbyte]];						// Hi-Bit der Adresse
	[i2cAdressArray addObject:[NSNumber numberWithInt:lbyte]];						// Lo-Bit der Adresse
	//NSLog(@"readTagplan i2cAdressArray: %@",[i2cAdressArray description]);
	[Adresse setStringValue:[i2cAdressArray componentsJoinedByString:@" "]];		// Adresse in String umwandeln
	[readEEPROMDic setObject:i2cAdressArray forKey:@"adressarray"];					// Adress-Array in Dic setzen
	
	NSMutableArray* i2cCmdArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Anforderung Daten
	[i2cCmdArray addObject:[NSNumber numberWithInt:0x03]];							// Code fuer read-Report
	[i2cCmdArray addObject:[NSNumber numberWithInt:anzDaten]];						// Anzahl Daten	angeben
	[i2cCmdArray addObject:[NSNumber numberWithInt:i2cAdresse+1]];					// I2C-Adresse EEPROM mit READ-Bit
	//	[i2cCmdArray addObject:[NSString stringWithFormat:@"% 02X",[[NSNumber numberWithInt:i2cAdresse+1]stringValue]]]; // I2C-Adresse EEPROM mit READ
	[readEEPROMDic setObject:i2cCmdArray forKey:@"cmdarray"];						// Cmd-Array in Dic setzen
	
	[Cmd setStringValue:[i2cCmdArray componentsJoinedByString:@" "]];				// Befehl in Feld einsetzen
	
	NSLog(@"readTagplan: readEEPROMDic: %@",[readEEPROMDic description]);
	[nc postNotificationName:@"i2ceepromread" object:self userInfo:readEEPROMDic];	// Notification an IOWarriorController abschicken
	

	//NSLog(@"readTagplan Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
}

- (IBAction)readEEPROM:(id)sender
{
	NSView* tempTabview=[sender superview];
	NSString* EEPROMAdresseString=[(NSPopUpButton*)[tempTabview viewWithTag:10093]titleOfSelectedItem];
	NSLog(@"readEEPROM: EEPROMAdresseString: %@",EEPROMAdresseString);
	NSScanner* sc=[NSScanner scannerWithString:EEPROMAdresseString];
	unsigned int EEPROMAdresse = -1;
	if ([sc scanHexInt:&EEPROMAdresse])
	{
		if (EEPROMAdresse)
		{
			NSLog(@"readEEPROM: EEPROMAdresseString: %@ EEPROMAdresse: %d",EEPROMAdresseString, EEPROMAdresse);

			int Raum=[(NSPopUpButton*)[tempTabview viewWithTag:10090]indexOfSelectedItem];
			int Objekt=[(NSPopUpButton*)[tempTabview viewWithTag:10091]indexOfSelectedItem];
			int Wochentag=[(NSPopUpButton*)[tempTabview viewWithTag:10092]indexOfSelectedItem];
			NSLog(@"raum: %d objekt: %d Wochentag: %d",Raum, Objekt,Wochentag);
			uint16_t startAdresse=Raum*RAUMPLANBREITE + Objekt*TAGPLANBREITE+ Wochentag*0x08;
			NSLog(@"raum: %d objekt: %d Wochentag: %d startAdresse: %d",Raum, Objekt, Wochentag, startAdresse);
			[self setI2CStatus:1];
			[self readEEPROM:EEPROMAdresse vonAdresse: startAdresse anz:6];
			[self setI2CStatus:0];
		}//if EEPROMAdresse
	}
	
}

- (void)readEEPROM:(int)i2cAdresse vonAdresse:(int)startAdresse anz:(int)anzDaten
{
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* readEEPROMDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	NSMutableArray* i2cAdressArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Adressierung EEPROM
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x02]];						// write-Report
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x83]];						// Startbit 3 bytes ohne Stopbit
	[i2cAdressArray addObject:[NSNumber numberWithInt:i2cAdresse]];					// I2C-Adresse EEPROM mit WRITE
	int lbyte=startAdresse%0x100;
	int hbyte=startAdresse/0x100;
	
	[i2cAdressArray addObject:[NSNumber numberWithInt:hbyte]];						// Hi-Bit der Adresse
	[i2cAdressArray addObject:[NSNumber numberWithInt:lbyte]];						// Lo-Bit der Adresse
	//NSLog(@"readTagplan i2cAdressArray: %@",[i2cAdressArray description]);
	[Adresse setStringValue:[i2cAdressArray componentsJoinedByString:@" "]];		// Adresse in String umwandeln
	[readEEPROMDic setObject:i2cAdressArray forKey:@"adressarray"];					// Adress-Array in Dic setzen
	
	NSMutableArray* i2cCmdArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Anforderung Daten
	[i2cCmdArray addObject:[NSNumber numberWithInt:0x03]];							// Code fuer read-Report
	[i2cCmdArray addObject:[NSNumber numberWithInt:anzDaten]];						// Anzahl Daten	angeben
	[i2cCmdArray addObject:[NSNumber numberWithInt:i2cAdresse+1]];					// I2C-Adresse EEPROM mit READ-Bit
	//	[i2cCmdArray addObject:[NSString stringWithFormat:@"% 02X",[[NSNumber numberWithInt:i2cAdresse+1]stringValue]]]; // I2C-Adresse EEPROM mit READ
	[readEEPROMDic setObject:i2cCmdArray forKey:@"cmdarray"];						// Cmd-Array in Dic setzen
	
	[Cmd setStringValue:[i2cCmdArray componentsJoinedByString:@" "]];				// Befehl in Feld einsetzen
	
	//NSLog(@"readTagplan: readEEPROMDic: %@",[readEEPROMDic description]);
	[nc postNotificationName:@"i2ceepromread" object:self userInfo:readEEPROMDic];	// Notification an IOWarriorWindowController abschicken
	

	//NSLog(@"readTagplan Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
}


- (IBAction)clearEEPROMTabelle:(id)sender
{
   [self setTWITaste:1];
	[AVR_DS clearWochenplan];
	[EEPROMArray removeAllObjects];
	[EEPROMTable reloadData];
}


- (int)writeEEPROM:(int)i2cAdresse anAdresse:(int)startAdresse mitDaten:(NSArray*)dieDaten
{
	NSLog(@"writeEEPROM: i2cAdresse:  %02X count: %d dieDaten: %@",i2cAdresse,[dieDaten count], [dieDaten description]);
	int writeErr=0;
	return 0;
	NSMutableArray* tempEEPROMArray=[[NSMutableArray alloc]initWithCapacity:0]; //SammelArray der Pakete fuer IOW

	
	int anzDaten=[dieDaten count];
	
	int lbyte=startAdresse%0x100;
	int hbyte=startAdresse/0x100;


	//NSLog(@"writeEEPROM Adresse: %02X dieDaten: %@  anz: %d",startAdresse,[dieDaten description],[dieDaten count]);
	//Adressierung EEPROM
	//[i2cWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
	
//	NSLog(@"Anz Daten: %d Anz Pages: %d restPage: %d",anzDaten, lines, restdaten);
	NSString* logString=[NSString string];

	if (anzDaten<=3) // nur ein Report mit Start/Stop
	{
		NSMutableArray* i2cWriteArray=[[NSMutableArray alloc]initWithCapacity:0];//Sammelarray fuer die Arrays der Reports
		NSMutableArray* tempWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
		int lbyte=startAdresse%0x100;
		int hbyte=startAdresse/0x100;

		[tempWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
		logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x02]];
		[tempWriteArray addObject:[NSNumber numberWithInt:0xc3 + anzDaten]]; // Startbit, Startadresse, bis 3 bytes,  Stopbit
		logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0xc3 + anzDaten]];
		[tempWriteArray addObject:[NSNumber numberWithInt:i2cAdresse]]; // I2C-Adresse EEPROM mit WRITE
		logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",i2cAdresse]];
		[tempWriteArray addObject:[NSNumber numberWithInt:hbyte]];
		logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",hbyte]];
		[tempWriteArray addObject:[NSNumber numberWithInt:lbyte]];
		logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",lbyte]];
		
		int k;
		for (k=0;k<anzDaten;k++)
		{
			[tempWriteArray addObject:[dieDaten objectAtIndex:k]];
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",[[dieDaten objectAtIndex:k]intValue]]];
		}
		
		[i2cWriteArray addObject:tempWriteArray];//in Sammelarray fuer die Arrays der Reports
		
		//		[writeEEPROMDic setObject:i2cWriteArray forKey:@"i2ceepromarray"];
		//		[nc postNotificationName:@"i2ceepromwrite" object:self userInfo:writeEEPROMDic];
		
	}
	else	// mehr als ein Report
	{
		
		NSLog(@"Mehr als ein Report");

		int pages=anzDaten/32; //pagebreite des EEPROMs
		int restPageDaten=anzDaten%32;// Anzahl ueberzaehliger Daten
		if (anzDaten%32) 
		{
			pages++; //unvollständige Page einfuegen
		}
		int pageIndex=0;
		int firstData=0;
		int breite=0x20;
		
		while (pageIndex<pages)
		{
			NSMutableArray* i2cWriteArray=[[NSMutableArray alloc]initWithCapacity:0];//Sammelarray fuer die Arrays der Reports
			NSMutableArray* tempStartWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
			int lbyte=(pageIndex*0x20 + startAdresse)%0x100;
			int hbyte=(pageIndex*0x20 + startAdresse)/0x100;

			if (pageIndex==pages-1) //letzte page
			{
			breite=anzDaten-(pageIndex)*0x20;
			
			}
			
			//NSLog(@"pagesIndex: %d firstData: %d breite: %d",pageIndex,firstData, breite);
			NSArray* tempByteArray=[dieDaten subarrayWithRange:NSMakeRange(firstData,breite)];
			int anzPageData=[tempByteArray count]; // anz Linien in tempArray, ev weniger als 32
			int lines=(anzPageData)/6; // 
			int lineIndex=0;
			int restData=(anzPageData)%6;// ev ueberzaehlige Linien in tempArray
			//NSLog(@"writeEEPROM pageIndex: %d lines: %d restData: %d",pageIndex, lines, restData);
			
			// Start-Report einfuegen: Write-Report, (Startbit (8) mit 3 Bytes: EEPROM-Adresse mit Write-Bit,  StartadresseH, StartadresseL
			[tempStartWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x02]];
			[tempStartWriteArray addObject:[NSNumber numberWithInt:0x83]]; // Startbit, Startadresse, 3 bytes  
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x83]];
			
			[tempStartWriteArray addObject:[NSNumber numberWithInt:i2cAdresse]]; // I2C-Adresse EEPROM mit WRITE
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",i2cAdresse]];
			
			[tempStartWriteArray addObject:[NSNumber numberWithInt:hbyte]];
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",hbyte]];
			[tempStartWriteArray addObject:[NSNumber numberWithInt:lbyte]];
			logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",lbyte]];
			
			[i2cWriteArray addObject:tempStartWriteArray];//Erster Report in Sammelarray fuer die Arrays der Reports
			//NSLog(@"AVR writeEEPROM Start-Report anz: %d \n				i2cWriteArray: %@",[i2cWriteArray count],logString);
			int k;
			//Reports aufbauen:  Writereport-Flag, Anzahl Bytes, Bytes 
			for (lineIndex=0;lineIndex<lines;lineIndex++)
			{
				
				int zeilenlaenge=6;
				NSMutableArray* tempDataWriteArray=[[NSMutableArray alloc]initWithCapacity:0];
				logString=[logString stringByAppendingString:@"\n   "];
				NSMutableArray* tempWriteArray=[[NSMutableArray alloc]initWithCapacity:0];//Array fuer einen Report
				[tempDataWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
				logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x02]];
				
				if (lineIndex<lines)// || ((lineIndex==lines-1) && restData))	//	noch nicht letzte Zeile, kein Stop-Bit oder 
					// letzte Zeile und noch Restdaten, die einen gesonderten Report erhalten
				{
					if ((lineIndex==lines-1) && (restData==0)) // letzter Report ist vollständig
					{
						//NSLog(@"Report ist vollständig");
						[tempDataWriteArray addObject:[NSNumber numberWithInt:0x46]]; // Stop-Flag, anzDaten
						logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x46]];
						
						
					}
					else // noch nicht letzter Report oder es hat noch restDaten
					{
				
					[tempDataWriteArray addObject:[NSNumber numberWithInt:0x06]]; // keine Flags, anzDaten
					logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x06]];
					}
					
				}
				
				for (k=0;k<zeilenlaenge;k++) // Daten anfuegen
				{
					
					[tempDataWriteArray addObject:[dieDaten objectAtIndex:(pageIndex*0x20)+(lineIndex*6)+k]];
					logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",[[dieDaten objectAtIndex:(pageIndex*0x20)+(lineIndex*6)+k]intValue]]];
				}
				[i2cWriteArray addObject:tempDataWriteArray];//in Sammelarray fuer die Arrays der Reports

				if ((lineIndex==lines-1) && restData) // Restdaten vorhanden, Anzahl anpassen
				{
					//NSLog(@"RestData");
					NSMutableArray* tempRestDataWriteArray=[[NSMutableArray alloc]initWithCapacity:0];

					// Write-Report anfuegen
					[tempRestDataWriteArray addObject:[NSNumber numberWithInt:0x02]];	//write-Report
					logString=[logString stringByAppendingString:[NSString stringWithFormat:@"\n  %02X ",0x02]];
					
					[tempRestDataWriteArray addObject:[NSNumber numberWithInt: 0x40 + restData]];//restdaten und Stopbit
					logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",0x40 + restData]];
					
					zeilenlaenge=restData;
					for (k=0;k<zeilenlaenge;k++)
					{
						
						[tempRestDataWriteArray addObject:[dieDaten objectAtIndex:(pageIndex*0x20)+((lineIndex+1)*6)+k]]; // restData einfuegen
						logString=[logString stringByAppendingString:[NSString stringWithFormat:@"%02X ",[[dieDaten objectAtIndex:(pageIndex*0x20)+((lineIndex+1)*6)+k]intValue]]];
					}
				[i2cWriteArray addObject:tempRestDataWriteArray];//in Sammelarray fuer die Arrays der Reports
				}
					
				// tempWriteArray fertig: 
				
				//NSLog(@"AVR writeEEPROM Report: %d  i2cWriteArray: %@  anz: %d",lineIndex,[i2cWriteArray description],[i2cWriteArray count]);		
				//NSLog(@"AVR writeEEPROM pageIndex: %d   anz: %d  i2cWriteArray: %@",pageIndex,[i2cWriteArray count],logString);		
				
				
			}// for lineIndex
			
			//NSLog(@"AVR writeEEPROM ende while:   pageIndex: %d i2cWriteArray logString: %@",pageIndex, logString);	
			firstData+=0x20;
			pageIndex++;
			[tempEEPROMArray addObject: i2cWriteArray];
			//i2cWriteArray=[NSArray array];
			logString=@"";
		}//while pageIndex
		//NSLog(@"tempEEPROMArray: %@",[tempEEPROMArray description]);
		
		NSMutableDictionary* writeInfoDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[writeInfoDic setObject:tempEEPROMArray forKey:@"pagearray"];
		[writeInfoDic setObject:[NSNumber numberWithInt:0] forKey:@"pagenummer"];
		[writeInfoDic setObject:[NSNumber numberWithInt:0] forKey:@"reportnummer"];
		[writeInfoDic setObject:logString forKey:@"logstring"];
		[writeInfoDic setObject:@"eeprom" forKey:@"target"];
		
		//Timer fuer Pages
		//NSLog(@"WriteEEPROM writeInfoDic vor Page-Timer: %@",[writeInfoDic description]);=K

		// Timer fuer das Senden der Reports
		
		NSDate *now = [[NSDate alloc] init];
		NSTimer* WritePageTimer =[[NSTimer alloc] initWithFireDate:now
													  interval:0.5
														target:self 
													  selector:@selector(WriteEEPROMPageFunktion:) 
													  userInfo:writeInfoDic
													   repeats:YES];
		
		NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
		[runLoop addTimer:WritePageTimer forMode:NSDefaultRunLoopMode];
		
	
		
		
	}//	anz>3
	return writeErr;
}

- (void)WriteEEPROMPageFunktion:(NSTimer*) derTimer
{
//OK NSLog(@"WriteEEPROMPageFunktion; userInfo: %@",[[derTimer userInfo]description]); OK
	if ([[derTimer userInfo] objectForKey:@"pagearray"])
	{
		NSArray* pageEEPROMArray=[[derTimer userInfo] objectForKey:@"pagearray"];
		int PageNummer=[[[derTimer userInfo] objectForKey:@"pagenummer"]intValue];
		if (PageNummer==0)
		{
			[self setI2CStatus:1];
		}
//OK	NSLog(@"WriteEEPROMPageFunktion: anz Pages: %d pageEEPROMArray: %@",[pageEEPROMArray count],[pageEEPROMArray description]);
		if (PageNummer<[pageEEPROMArray count]) // es hat noch einen Array mit Reports
		{
//			NSLog(@"WriteEEPROMPageFunktion PageNummer: %d",PageNummer);
			NSMutableDictionary* writeEEPROMPageDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			
			// Array mit Reports der Page weitergeben
			[writeEEPROMPageDic setObject:[pageEEPROMArray objectAtIndex:PageNummer]forKey:@"reportarray"];
//			NSLog(@"WriteEEPROMFunktion pagenummer: %d writeEEPROMPageDic: %@",PageNummer,[writeEEPROMPageDic description]);
			[writeEEPROMPageDic setObject:@"eeprom" forKey:@"target"];
			
			//Pagenummer weitergeben
			[writeEEPROMPageDic setObject:[NSNumber numberWithInt:PageNummer] forKey:@"pagenummer"];
			
						//Timer fuer WriteEEPROMFunktion einrichten
			[writeEEPROMPageDic setObject:[NSNumber numberWithInt:0] forKey:@"reportnummer"];
			[writeEEPROMPageDic setObject:[NSNumber numberWithInt:PageNummer] forKey:@"pagenummer"];
			[writeEEPROMPageDic setObject:[[derTimer userInfo] objectForKey:@"logstring"] forKey:@"logstring"];
			[writeEEPROMPageDic setObject:@"eeprom" forKey:@"target"];
			//NSLog(@"WriteEEPROMFunktion writeEEPROMPageDic vor EEPROM-Timer: %@",[writeEEPROMPageDic description]);
			
			PageNummer++;

			if (PageNummer<[pageEEPROMArray count])
			{
				[[derTimer userInfo] setObject:[NSNumber numberWithInt:PageNummer]forKey:@"pagenummer"];
			}
			else
			{
				if ([derTimer isValid])
				{
	//				NSLog(@"WriteEEPROMPageFunktion Page fertig: Timer invalidate");
					
					[derTimer invalidate];
					//				[self setI2CStatus:0];
					//				[derTimer release];				
				}
				
			}
			
//OK			NSLog(@"WriteEEPROMPageFunktion nach Timerabfrage: writeEEPROMPageDicA %@",[writeEEPROMPageDic description]);
			
			
			NSDate *now = [[NSDate alloc] init];
			NSTimer* WriteTimer =[[NSTimer alloc] initWithFireDate:now
														  interval:0.03
															target:self 
														  selector:@selector(WriteEEPROMFunktion:) 
														  userInfo:writeEEPROMPageDic
														   repeats:YES];
			
			NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
			[runLoop addTimer:WriteTimer forMode:NSDefaultRunLoopMode];
			
						
		}// Pagenummer < count
		
	}
	else
	{
		[derTimer invalidate];
		
	}
}


- (void)WriteEEPROMFunktion:(NSTimer*) derTimer;
{
	if ([[derTimer userInfo] objectForKey:@"reportarray"])
	{
		
		NSArray* i2cWriteArray=[[derTimer userInfo] objectForKey:@"reportarray"];
		//OK	NSLog(@"WriteEEPROMFunktion i2cWriteArray : %@",[i2cWriteArray description]);
		int PageNummer=[[[derTimer userInfo] objectForKey:@"pagenummer"]intValue];
		int ReportNummer=[[[derTimer userInfo] objectForKey:@"reportnummer"]intValue];
		
		if (ReportNummer==0)
		{
			[self setI2CStatus:1];
		}
		//	NSLog(@"WriteEEPROMFunktion pagenummer: %d reportnummer: %d",PageNummer,ReportNummer);
		if (ReportNummer<[i2cWriteArray count])
		{
			//NSLog(@"WriteEEPROMFunktion ReportNummer: %d",ReportNummer);
			NSMutableDictionary* writeEEPROMDic=[[NSMutableDictionary alloc]initWithCapacity:0];
			NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];		
			[writeEEPROMDic setObject:[i2cWriteArray objectAtIndex:ReportNummer]forKey:@"i2ceepromarray"];
			//NSLog(@"WriteEEPROMFunktion i2cWriteArray  %@",[[i2cWriteArray objectAtIndex:ReportNummer] description]);
			[writeEEPROMDic setObject:@"eeprom" forKey:@"target"];
			[writeEEPROMDic setObject:[NSNumber numberWithInt:PageNummer] forKey:@"pagenummer"];
			//NSLog(@"WriteEEPROMFunktion writeEEPROMDic  %@",[writeEEPROMDic description]);

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
	//			NSLog(@"WriteEEPROMFunktion Tag fertig: Timer invalidate");

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
	AnzahlDaten=0x20; //32 Bytes, TAGPLANBREITE;
	unsigned int i2cadresse;
	NSScanner* theScanner = [NSScanner scannerWithString:EEPROM_i2cAdresse];
	
	if ([theScanner scanHexInt:&i2cadresse])
	{
		//NSLog(@"writeWocheFunktion: EEPROM_i2cAdresse string: %@ int: %x	",EEPROM_i2cAdresse,i2cadresse);
		
	}
	//NSLog(@"writeWocheFunktion: EEPROM_i2cAdresse: %x tagIndex: %d MemAdresse: %x",i2cadresse, aktuellerTag,aktuellerTag*TAGPLANBREITE);
	IOW_busy=1;
	NSLog(@"Wochenplan: %@" ,[Wochenplan description]);
	// 25.6. start
	
	
	
	
	// 25.6. end
	
	rTagplanbalken* aktuellerTagplan=[[Wochenplan objectAtIndex:aktuellerTag]objectForKey:@"Heizung"];
	NSArray* tempStundenplanArray=[aktuellerTagplan StundenArray];
	
	NSLog(@"writeWocheFunktion Tag: %@: aktuellerStundenplan: %@",[Wochentage objectAtIndex:aktuellerTag],[tempStundenplanArray description]);
	if ([tempStundenplanArray count])
	{
		int i;
		for (i=0;i<24;i++)
		{
			if (i<[tempStundenplanArray count])
			{
				int hexWert=[[tempStundenplanArray objectAtIndex:i]intValue]<<6;//Bit 6,7
				//hexNachtWert &=0x0C;
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
		
		[self writeEEPROM:i2cadresse anAdresse:aktuellerTag*TAGPLANBREITE mitDaten:tempTagplanArray];
		
		
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



- (void)EEPROMbusycountAktion:(NSNotification*)note
{
   NSLog(@"AVR EEPROMbusycountAktion busycount: %d",[[[note userInfo]objectForKey:@"busicount"]intValue]);
}

- (IBAction)sendCmd:(id)sender
{
NSLog(@"sendCmd");

[self sendCmd:@"F1" mitDaten:[NSArray arrayWithObjects:[[NSNumber numberWithInt:n]stringValue],@"02",@"03",nil]];
n++;
if (n==2)
n=0;

}

- (int)sendCmd:(NSString*)derBefehl mitDaten:(NSArray*)dieDaten;
{
	int sendErr=0;
	int anzDaten=[dieDaten count];
	int i;
	if (anzDaten)
	{
		NSMutableArray* tempHexArray=[[NSMutableArray alloc]initWithCapacity:0];
		[tempHexArray addObject:derBefehl];
		for (i=0;i<3;i++)
		{
			if (i<anzDaten)
			{
				[tempHexArray addObject:[dieDaten objectAtIndex:i]];
			}
			else
			{
				[tempHexArray addObject:@"00"];
			}
		}
		NSLog(@"sendCmd tempHexArray: %@",[tempHexArray description]);
		NSMutableDictionary* sendCmdDic=[[NSMutableDictionary alloc]initWithCapacity:0];
		[sendCmdDic setObject:tempHexArray forKey:@"hexstringarray"];
		NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
		[nc postNotificationName:@"sendcmd" object:self userInfo:sendCmdDic];
		
		
		
	}//anzDaten
	else
	{
		return -1;
	}
	
	return sendErr;
}




- (IBAction)readAVRSlave:(id)sender
{
	NSView* tempTabview=[sender superview];
	NSString* AVRAdresseString=[(NSPopUpButton*)[tempTabview viewWithTag:10082]titleOfSelectedItem];
	NSLog(@"readAVRSlave: AVRAdresseString: %@",AVRAdresseString);
	NSScanner* sc=[NSScanner scannerWithString:AVRAdresseString];
	unsigned int AVRSlaveAdresse = -1;
	if ([sc scanHexInt:&AVRSlaveAdresse])
	{
		if (AVRSlaveAdresse)
		{
			NSLog(@"readAVRSlave: AVRAdresseString: %@ AVRSlaveAdresse: %d",AVRAdresseString, AVRSlaveAdresse);
			uint16_t startAdresse=0x00;;
			[self setI2CStatus:1];
			[self readAVRSlave:AVRSlaveAdresse vonAdresse: startAdresse anz:1];
	//		[self setI2CStatus:0];
		}//if AVRSlaveAdresse
	}
	
}



- (void)readAVRSlave:(int)i2cAdresse vonAdresse:(int)startAdresse anz:(int)anzDaten
{
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* readAVRDic=[[NSMutableDictionary alloc]initWithCapacity:0];
	NSMutableArray* i2cAdressArray=[[NSMutableArray alloc]initWithCapacity:0];
	int i;
	//Adressierung AVR Slave
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x02]];						// write-Report
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x81]];						// Startbit 3 bytes ohne Stopbit
	[i2cAdressArray addObject:[NSNumber numberWithInt:i2cAdresse]];		
	for (i=0;i<5;i++)
	{
	[i2cAdressArray addObject:[NSNumber numberWithInt:0x00]];
	}
							// I2C-Adresse EEPROM mit WRITE
//	int lbyte=startAdresse%0x100;
//	int hbyte=startAdresse/0x100;
	
	[i2cAdressArray addObject:[NSNumber numberWithInt:startAdresse]];						// Hi-Bit der Adresse
	//NSLog(@"readAVRSlave i2cAdressArray: %@",[i2cAdressArray description]);
	[Adresse setStringValue:[i2cAdressArray componentsJoinedByString:@" "]];		// Adresse in String umwandeln
	[readAVRDic setObject:i2cAdressArray forKey:@"adressarray"];					// Adress-Array in Dic setzen
	
	NSMutableArray* i2cCmdArray=[[NSMutableArray alloc]initWithCapacity:0];
	
	//Anforderung Daten
	[i2cCmdArray addObject:[NSNumber numberWithInt:0x03]];							// Code fuer read-Report
	[i2cCmdArray addObject:[NSNumber numberWithInt:anzDaten]];						// Anzahl Daten	angeben
	[i2cCmdArray addObject:[NSNumber numberWithInt:i2cAdresse+1]];					// I2C-Adresse EEPROM mit READ-Bit
	//[i2cCmdArray addObject:[NSString stringWithFormat:@"% 02X",[[NSNumber numberWithInt:i2cAdresse+1]stringValue]]]; // I2C-Adresse EEPROM mit READ
	for (i=0;i<5;i++)
	{
	[i2cCmdArray addObject:[NSNumber numberWithInt:0x00]];
	}
	[readAVRDic setObject:i2cCmdArray forKey:@"cmdarray"];						// Cmd-Array in Dic setzen
	NSLog(@"readAVRSlave: readAVRDic: %@",[readAVRDic description]);
	
	//[Cmd setStringValue:[i2cCmdArray componentsJoinedByString:@" "]];				// Befehl in Feld einsetzen
	
	
	[nc postNotificationName:@"i2cavrread" object:self userInfo:readAVRDic];	// Notification an IOWarriorWindowController abschicken
	
	//NSLog(@"readAVRSlave Eingangsdaten: %@ \nAnz: %d",[Eingangsdaten description],[Eingangsdaten count]);
}


- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
   //NSLog(@"didSelectTabViewItem index: %d",[[tabViewItem identifier]intValue] );
   int index = [[tabViewItem identifier]intValue];
  if (index < [RaumPop  numberOfItems])
  {
     [RaumPop selectItemAtIndex:[[tabViewItem identifier]intValue] ];
     [self setObjektPopVonRaum:index];
  }
   writeEEPROManzeige.intValue = 0;
   
}

- (BOOL) FensterSchliessenAktion:(NSNotification*)note
{
	NSLog(@"AVR FensterSchliessenAktion: %@ anz Window: %d",[[note object]description],[[NSApp windows]count]);
	
	if ([self TWIStatus])
	{
	[NSApp terminate:self];
	return YES;
	}
	else 
	{
	return NO;
	}

}


- (BOOL)windowShouldClose:(id)sender
{
	NSLog(@"AVR windowShouldClose");
/*	
	NSNotificationCenter* nc=[NSNotificationCenter defaultCenter];
	NSMutableDictionary* BeendenDic=[[[NSMutableDictionary alloc]initWithCapacity:0]autorelease];

	[nc postNotificationName:@"IOWarriorBeenden" object:self userInfo:BeendenDic];

*/
	if ([self TWIStatus])
	{
	return YES;
	}
	else 
	{
      
      if ([self TWIStatus] == 0) // Homebus noch deaktiviert
      {
			NSAlert *Warnung = [[NSAlert alloc] init];
         [Warnung addButtonWithTitle:@"OK"];
         //	[Warnung addButtonWithTitle:@""];
         //	[Warnung addButtonWithTitle:@""];
         //	[Warnung addButtonWithTitle:@"Abbrechen"];
         [Warnung setMessageText:[NSString stringWithFormat:@"%@",@"Homebus ist deaktiviert!"]];
         
         NSString* s1=@"Der Homebus muss aktiviert sein, um beenden zu koennen.";
         NSString* s2=@"";
         NSString* InformationString=[NSString stringWithFormat:@"%@\n%@",s1,s2];
         [Warnung setInformativeText:InformationString];
         [Warnung setAlertStyle:NSAlertStyleWarning];
         
         int antwort=[Warnung runModal];
         return NO;
         
         
      }

	return NO;
	}

	return YES;
}

@end
