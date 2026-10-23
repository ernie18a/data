//+------------------------------------------------------------------+
//|                                                        MOCHI.mq4 |
//|                                          2018, Edwin Artunduaga. |
//|                           https://www.mql5.com/en/users/edwinhaq |
//+------------------------------------------------------------------+
#property copyright     "2018, Edwin Artunduaga, edwinhaq@gmail.com"
#property link          "https://www.mql5.com/en/users/edwinhaq"
#property description   "Market Open-Close Hours Indicator"
#property version       "1.00"
#property strict

//+------------------------------------------------------------------+
//| Indicator definitions                                                                  |
//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_minimum 0
//#property indicator_maximum 0
#property indicator_buffers 66
#property indicator_color1  clrNONE       // Max
#property indicator_color2  Yellow        // AMS - Euronext Amsterdam
#property indicator_color3  Blue          // ASE - Amman Stock Exchange
#property indicator_color4  Red           // ASX - Australian Securities Exchange
#property indicator_color5  Green         // BCBA - Buenos Aires Stock Exchange
#property indicator_color6  Orange        // BME - Spanish Stock Exchange
#property indicator_color7  Violet        // BMV - Mexican Stock Exchange
#property indicator_color8  Brown         // Bovespa - Bolsa de Valores de São Paulo
#property indicator_color9  White         // BSE - Bombay Stock Exchange[4]
#property indicator_color10 Yellow        // BSE - Beirut Stock Exchange
#property indicator_color11 Blue          // BSE - Budapest Stock Exchange
#property indicator_color12 Red           // BX - Berne eXchange
#property indicator_color13 Green         // CSE - Chittagong Stock Exchange
#property indicator_color14 Orange        // CSE - Colombo Stock Exchange
#property indicator_color15 Violet        // CSE - Casablanca Stock Exchange
#property indicator_color16 Brown         // CSE - Copenhagen Stock Exchange
#property indicator_color17 White         // DSE - Dhaka Stock Exchange
#property indicator_color18 Yellow        // DSE - Dar es Salaam Stock Exchange
#property indicator_color19 Blue          // EPA - Euronext Paris
#property indicator_color20 Red           // EUREX - Eurex Exchange
#property indicator_color21 Green         // FSX - Frankfurt Stock Exchange (Xetra)
#property indicator_color22 Orange        // GPW - Warsaw Stock Exchange
#property indicator_color23 Violet        // HKEX - Hong Kong Stock Exchange
#property indicator_color24 Brown         // HKFE - Hong Kong Futures Exchange
#property indicator_color25 White         // HNX - Hanoi Stock Exchange
#property indicator_color26 Yellow        // HOSE - Hochiminh Stock Exchange
#property indicator_color27 Blue          // IDX - Indonesia Stock Exchange
#property indicator_color28 Red           // ISE - Borsa Istanbul
#property indicator_color29 Green         // ISE - Irish Stock Exchange
#property indicator_color30 Orange        // JSE - Johannesburg Stock Exchange
#property indicator_color31 Violet        // JSE - Jamaica Stock Exchange
#property indicator_color32 Brown         // KRX - Korea Stock Exchange
#property indicator_color33 White         // LSE - London Stock Exchange
#property indicator_color34 Yellow        // LuxSE - Luxembourg Stock Exchange
#property indicator_color35 Blue          // MOEX - Moscow Exchange
#property indicator_color36 Red           // MSE - Malta Stock Exchange
#property indicator_color37 Green         // MTA - Milan Stock Exchange
#property indicator_color38 Orange        // MYX - Bursa Malaysia
#property indicator_color39 Violet        // NASDAQ - NASDAQ
#property indicator_color40 Brown         // NSE - National Stock Exchange of India[5]
#property indicator_color41 White         // NSE - Nairobi Securities Exchange
#property indicator_color42 Yellow        // NSE - Nigerian Stock Exchange
#property indicator_color43 Blue          // NYSE - New York Stock Exchange
#property indicator_color44 Red           // NZSX - New Zealand Stock Market
#property indicator_color45 Green         // OMX - Helsinki Stock Exchange
#property indicator_color46 Orange        // OMX - Stockholm Stock Exchange
#property indicator_color47 Violet        // OMXR - Riga Stock Exchange
#property indicator_color48 Brown         // OMXT - Tallinn Stock Exchange
#property indicator_color49 White         // OMXV - NASDAQ OMX Vilnius
#property indicator_color50 Yellow        // OSE - Oslo Stock Exchange
#property indicator_color51 Blue          // PSE - Philippine Stock Exchange
#property indicator_color52 Red           // PSI - Euronext Lisbon
#property indicator_color53 Green         // PSX - Pakistan Stock Exchange
#property indicator_color54 Orange        // SET - Stock Exchange of Thailand
#property indicator_color55 Violet        // SGX - Singapore Exchange
#property indicator_color56 Brown         // SIX - Swiss Exchange
#property indicator_color57 White         // SSE - Shanghai Stock Exchange
#property indicator_color58 Yellow        // SZSE - Shenzhen Stock Exchange
#property indicator_color59 Blue          // TADAWUL - Saudi Stock Exchange
#property indicator_color60 Red           // TASE - Tel Aviv Stock Exchange
#property indicator_color61 Green         // TSE - Tokyo Stock Exchange
#property indicator_color62 Orange        // TSE - Tehran Stock Exchange
#property indicator_color63 Violet        // TSX - Toronto Stock Exchange
#property indicator_color64 Brown         // TWSE - Taiwan Stock Exchange
#property indicator_color65 White         // UX - Ukrainian Exchange
#property indicator_color66 Yellow        // VSE - Wiener Börse AG

#define LINE_WIDTH 6

//+------------------------------------------------------------------+
//| Inputs to enable/disable display markets                         |
//+------------------------------------------------------------------+
input bool AMSEnable1      =  false;         //1  AMS - Euronext Amsterdam
input bool ASEEnable2      =  false;         //2  ASE - Amman Stock Exchange
input bool ASXEnable3      =  false;         //3  ASX - Australian Securities Exchange
input bool BCBAEnable4     =  false;         //4  BCBA - Buenos Aires Stock Exchange
input bool BMEEnable5      =  false;         //5  BME - Spanish Stock Exchange
input bool BMVEnable6      =  false;         //6  BMV - Mexican Stock Exchange
input bool BovespaEnable7  =  false;         //7  Bovespa - Bolsa de Valores de São Paulo
input bool BSEEnable8      =  false;         //8  BSE - Bombay Stock Exchange[4]
input bool BSEEnable9      =  false;         //9  BSE - Beirut Stock Exchange
input bool BSEEnable10     =  false;         //10 BSE - Budapest Stock Exchange
input bool BXEnable11      =  false;         //11 BX - Berne eXchange
input bool CSEEnable12     =  false;         //12 CSE - Chittagong Stock Exchange
input bool CSEEnable13     =  false;         //13 CSE - Colombo Stock Exchange
input bool CSEEnable14     =  false;         //14 CSE - Casablanca Stock Exchange
input bool CSEEnable15     =  false;         //15 CSE - Copenhagen Stock Exchange
input bool DSEEnable16     =  false;         //16 DSE - Dhaka Stock Exchange
input bool DSEEnable17     =  false;         //17 DSE - Dar es Salaam Stock Exchange
input bool EPAEnable18     =  false;         //18 EPA - Euronext Paris
input bool EUREXEnable19   =  false;         //19 EUREX - Eurex Exchange
input bool FSXEnable20     =  false;         //20 FSX - Frankfurt Stock Exchange (Xetra)
input bool GPWEnable21     =  false;         //21 GPW - Warsaw Stock Exchange
input bool HKEXEnable22    =  false;         //22 HKEX - Hong Kong Stock Exchange
input bool HKFEEnable23    =  false;         //23 HKFE - Hong Kong Futures Exchange
input bool HNXEnable24     =  false;         //24 HNX - Hanoi Stock Exchange
input bool HOSEEnable25    =  false;         //25 HOSE - Hochiminh Stock Exchange
input bool IDXEnable26     =  false;         //26 IDX - Indonesia Stock Exchange
input bool ISEEnable27     =  false;         //27 ISE - Borsa Istanbul
input bool ISEEnable28     =  false;         //28 ISE - Irish Stock Exchange
input bool JSEEnable29     =  false;         //29 JSE - Johannesburg Stock Exchange
input bool JSEEnable30     =  false;         //30 JSE - Jamaica Stock Exchange
input bool KRXEnable31     =  false;         //31 KRX - Korea Stock Exchange
input bool LSEEnable32     =  true;          //32 LSE - London Stock Exchange
input bool LuxSEEnable33   =  false;         //33 LuxSE - Luxembourg Stock Exchange
input bool MOEXEnable34    =  false;         //34 MOEX - Moscow Exchange
input bool MSEEnable35     =  false;         //35 MSE - Malta Stock Exchange
input bool MTAEnable36     =  false;         //36 MTA - Milan Stock Exchange
input bool MYXEnable37     =  false;         //37 MYX - Bursa Malaysia
input bool NASDAQEnable38  =  false;         //38 NASDAQ - NASDAQ
input bool NSEEnable39     =  false;         //39 NSE - National Stock Exchange of India
input bool NSEEnable40     =  false;         //40 NSE - Nairobi Securities Exchange
input bool NSEEnable41     =  false;         //41 NSE - Nigerian Stock Exchange
input bool NYSEEnable42    =  true;          //42 NYSE - New York Stock Exchange
input bool NZSXEnable43    =  false;         //43 NZSX - New Zealand Stock Market
input bool OMXEnable44     =  false;         //44 OMX - Helsinki Stock Exchange
input bool OMXEnable45     =  false;         //45 OMX - Stockholm Stock Exchange
input bool OMXREnable46    =  false;         //46 OMXR - Riga Stock Exchange
input bool OMXTEnable47    =  false;         //47 OMXT - Tallinn Stock Exchange
input bool OMXVEnable48    =  false;         //48 OMXV - NASDAQ OMX Vilnius
input bool OSEEnable49     =  false;         //49 OSE - Oslo Stock Exchange
input bool PSEEnable50     =  false;         //50 PSE - Philippine Stock Exchange
input bool PSIEnable51     =  false;         //51 PSI - Euronext Lisbon
input bool PSXEnable52     =  false;         //52 PSX - Pakistan Stock Exchange
input bool SETEnable53     =  false;         //53 SET - Stock Exchange of Thailand
input bool SGXEnable54     =  false;         //54 SGX - Singapore Exchange
input bool SIXEnable55     =  false;         //55 SIX - Swiss Exchange
input bool SSEEnable56     =  false;         //56 SSE - Shanghai Stock Exchange
input bool SZSEEnable57    =  false;         //57 SZSE - Shenzhen Stock Exchange
input bool TADAWULEnable58 =  false;         //58 TADAWUL - Saudi Stock Exchange
input bool TASEEnable59    =  false;         //59 TASE - Tel Aviv Stock Exchange
input bool TSEEnable60     =  true;          //60 TSE - Tokyo Stock Exchange
input bool TSEEnable61     =  false;         //61 TSE - Tehran Stock Exchange
input bool TSXEnable62     =  false;         //62 TSX - Toronto Stock Exchange
input bool TWSEEnable63    =  false;         //63 TWSE - Taiwan Stock Exchange
input bool UXEnable64      =  false;         //64 UX - Ukrainian Exchange
input bool VSEEnable65     =  false;         //65 VSE - Wiener Börse AG

//+------------------------------------------------------------------+
//| Buffer definitions for each market                               |
//| Note that Maximum is not drawed,                                 |
//| It is used to set maximum value in the indicator chart           |
//+------------------------------------------------------------------+
double Maximum0[];
double AMSBuffer1[];
double ASEBuffer2[];
double ASXBuffer3[];
double BCBABuffer4[];
double BMEBuffer5[];
double BMVBuffer6[];
double BovespaBuffer7[];
double BSEBuffer8[];
double BSEBuffer9[];
double BSEBuffer10[];
double BXBuffer11[];
double CSEBuffer12[];
double CSEBuffer13[];
double CSEBuffer14[];
double CSEBuffer15[];
double DSEBuffer16[];
double DSEBuffer17[];
double EPABuffer18[];
double EUREXBuffer19[];
double FSXBuffer20[];
double GPWBuffer21[];
double HKEXBuffer22[];
double HKFEBuffer23[];
double HNXBuffer24[];
double HOSEBuffer25[];
double IDXBuffer26[];
double ISEBuffer27[];
double ISEBuffer28[];
double JSEBuffer29[];
double JSEBuffer30[];
double KRXBuffer31[];
double LSEBuffer32[];
double LuxSEBuffer33[];
double MOEXBuffer34[];
double MSEBuffer35[];
double MTABuffer36[];
double MYXBuffer37[];
double NASDAQBuffer38[];
double NSEBuffer39[];
double NSEBuffer40[];
double NSEBuffer41[];
double NYSEBuffer42[];
double NZSXBuffer43[];
double OMXBuffer44[];
double OMXBuffer45[];
double OMXRBuffer46[];
double OMXTBuffer47[];
double OMXVBuffer48[];
double OSEBuffer49[];
double PSEBuffer50[];
double PSIBuffer51[];
double PSXBuffer52[];
double SETBuffer53[];
double SGXBuffer54[];
double SIXBuffer55[];
double SSEBuffer56[];
double SZSEBuffer57[];
double TADAWULBuffer58[];
double TASEBuffer59[];
double TSEBuffer60[];
double TSEBuffer61[];
double TSXBuffer62[];
double TWSEBuffer63[];
double UXBuffer64[];
double VSEBuffer65[];
//+------------------------------------------------------------------+
//| Market information struct                                        |
//+------------------------------------------------------------------+
struct MarketData
  {
   int               index;
   string            id;
   string            name;
   string            country;
   string            city;
   string            local_hours;
   string            utc_hours;
   string            dst_months;
   bool              enable;
   bool              isInit;
                     MarketData()
     {
      enable=false;
      isInit=false;
     }
                    ~MarketData()
     {
     }
   void Initialize(
                   int    f_index,
                   string f_id,
                   string f_name,
                   string f_country,
                   string f_city,
                   string f_local_hours,
                   string f_utc_hours,
                   string f_dst_months,
                   double &buffer[],
                   bool   f_enable
                   )
     {
      index=f_index;
      id=f_id;
      name=f_name;
      country=f_country;
      city=f_city;
      local_hours=f_local_hours;
      utc_hours=f_utc_hours;
      dst_months=f_dst_months;
      enable=f_enable;
      isInit=true;
      SetIndexBuffer(index,buffer);
      SetIndexLabel(index,id+" - "+name);
      SetIndexStyle(index,DRAW_LINE,STYLE_DOT,LINE_WIDTH);

     }
   int getUTCOpenHour()
     {
      string open_close[];
      string hour_min[];
      StringSplit(utc_hours,StringGetChar("-",0),open_close);
      StringSplit(open_close[0],StringGetChar(":",0),hour_min);
      return (int)StringToInteger(hour_min[0]);
     }
   int getUTCOpenMinute()
     {
      string open_close[];
      string hour_min[];
      StringSplit(utc_hours,StringGetChar("-",0),open_close);
      StringSplit(open_close[0],StringGetChar(":",0),hour_min);
      return (int)StringToInteger(hour_min[1]);
     }
   int getUTCCloseHour()
     {
      string open_close[];
      string hour_min[];
      StringSplit(utc_hours,StringGetChar("-",0),open_close);
      StringSplit(open_close[1],StringGetChar(":",0),hour_min);
      return (int)StringToInteger(hour_min[0]);
     }
   int getUTCCloseMinute()
     {
      string open_close[];
      string hour_min[];
      StringSplit(utc_hours,StringGetChar("-",0),open_close);
      StringSplit(open_close[1],StringGetChar(":",0),hour_min);
      return (int)StringToInteger(hour_min[1]);
     }
  };

MarketData AMSMarketData1;
MarketData ASEMarketData2;
MarketData ASXMarketData3;
MarketData BCBAMarketData4;
MarketData BMEMarketData5;
MarketData BMVMarketData6;
MarketData BovespaMarketData7;
MarketData BSEMarketData8;
MarketData BSEMarketData9;
MarketData BSEMarketData10;
MarketData BXMarketData11;
MarketData CSEMarketData12;
MarketData CSEMarketData13;
MarketData CSEMarketData14;
MarketData CSEMarketData15;
MarketData DSEMarketData16;
MarketData DSEMarketData17;
MarketData EPAMarketData18;
MarketData EUREXMarketData19;
MarketData FSXMarketData20;
MarketData GPWMarketData21;
MarketData HKEXMarketData22;
MarketData HKFEMarketData23;
MarketData HNXMarketData24;
MarketData HOSEMarketData25;
MarketData IDXMarketData26;
MarketData ISEMarketData27;
MarketData ISEMarketData28;
MarketData JSEMarketData29;
MarketData JSEMarketData30;
MarketData KRXMarketData31;
MarketData LSEMarketData32;
MarketData LuxSEMarketData33;
MarketData MOEXMarketData34;
MarketData MSEMarketData35;
MarketData MTAMarketData36;
MarketData MYXMarketData37;
MarketData NASDAQMarketData38;
MarketData NSEMarketData39;
MarketData NSEMarketData40;
MarketData NSEMarketData41;
MarketData NYSEMarketData42;
MarketData NZSXMarketData43;
MarketData OMXMarketData44;
MarketData OMXMarketData45;
MarketData OMXRMarketData46;
MarketData OMXTMarketData47;
MarketData OMXVMarketData48;
MarketData OSEMarketData49;
MarketData PSEMarketData50;
MarketData PSIMarketData51;
MarketData PSXMarketData52;
MarketData SETMarketData53;
MarketData SGXMarketData54;
MarketData SIXMarketData55;
MarketData SSEMarketData56;
MarketData SZSEMarketData57;
MarketData TADAWULMarketData58;
MarketData TASEMarketData59;
MarketData TSEMarketData60;
MarketData TSEMarketData61;
MarketData TSXMarketData62;
MarketData TWSEMarketData63;
MarketData UXMarketData64;
MarketData VSEMarketData65;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Only periods lower than H4
   if(Period()>PERIOD_H4)
     {
      Print("Only this periods: M1,M5,M15,M30,H1,H4");
      return(INIT_FAILED);
     }
//--- This is to send data to future xD
   int shift=1440/Period();
//Comment("shift: " + IntegerToString(shift) + "\nPeriod(): " + IntegerToString(Period()));

   IndicatorDigits(0);
   SetIndexBuffer(0,Maximum0);SetIndexLabel(0,"Maximum");SetIndexStyle(0,DRAW_LINE,STYLE_DOT,0);
//--- Initialize all the information for each market
   AMSMarketData1.Initialize(1,"AMS","Euronext Amsterdam","Netherlands","Amsterdam","9:00-17:40","8:00-16:40","Mar–Oct",AMSBuffer1,AMSEnable1);
   ASEMarketData2.Initialize(2,"ASE","Amman Stock Exchange","Jordan","Amman","10:00-12:00","8:00-10:00","Mar–Oct",ASEBuffer2,ASEEnable2);
   ASXMarketData3.Initialize(3,"ASX","Australian Securities Exchange","Australia","Sydney","10:00-16:00","0:00-6:00","Oct–Apr",ASXBuffer3,ASXEnable3);
   BCBAMarketData4.Initialize(4,"BCBA","Buenos Aires Stock Exchange","Argentina","Buenos Aires","11:00-17:00","14:00-20:00","",BCBABuffer4,BCBAEnable4);
   BMEMarketData5.Initialize(5,"BME","Spanish Stock Exchange","Spain","Madrid","9:00-17:30","8:00-16:30","Mar–Oct",BMEBuffer5,BMEEnable5);
   BMVMarketData6.Initialize(6,"BMV","Mexican Stock Exchange","Mexico","Mexico City","8:30-15:00","14:30-21:00","Apr–Oct",BMVBuffer6,BMVEnable6);
   BovespaMarketData7.Initialize(7,"Bovespa","Bolsa de Valores de São Paulo","Brazil","São Paulo","10:00-17:30","13:00-20:00","Oct–Feb",BovespaBuffer7,BovespaEnable7);
   BSEMarketData8.Initialize(8,"BSE","Bombay Stock Exchange[4]","India","Mumbai","9:15-15:30","3:45-10:00","",BSEBuffer8,BSEEnable8);
   BSEMarketData9.Initialize(9,"BSE","Beirut Stock Exchange","Lebanon","Beirut","9:30-12:30","7:30-10:30","Mar–Oct",BSEBuffer9,BSEEnable9);
   BSEMarketData10.Initialize(10,"BSE","Budapest Stock Exchange","Hungary","Budapest","9:00-17:00","8:00-16:00","Mar–Oct",BSEBuffer10,BSEEnable10);
   BXMarketData11.Initialize(11,"BX","Berne eXchange","Switzerland","Berne","9:00-16:30","8:00-15:30","Mar–Oct",BXBuffer11,BXEnable11);
   CSEMarketData12.Initialize(12,"CSE","Chittagong Stock Exchange","Bangladesh","Chittagong","10:30-14:30","4:30-8:30","",CSEBuffer12,CSEEnable12);
   CSEMarketData13.Initialize(13,"CSE","Colombo Stock Exchange","Sri Lanka","Colombo","9:30-14:30","4:00-9:00","",CSEBuffer13,CSEEnable13);
   CSEMarketData14.Initialize(14,"CSE","Casablanca Stock Exchange","Maroc","Casablanca","8:10-15:55","8:10-15:55","Mar–Oct",CSEBuffer14,CSEEnable14);
   CSEMarketData15.Initialize(15,"CSE","Copenhagen Stock Exchange","Denmark","Copenhagen","9:00-17:00","8:00-16:00","Mar–Oct",CSEBuffer15,CSEEnable15);
   DSEMarketData16.Initialize(16,"DSE","Dhaka Stock Exchange","Bangladesh","Dhaka","10:30-14:30","4:30-8:30","",DSEBuffer16,DSEEnable16);
   DSEMarketData17.Initialize(17,"DSE","Dar es Salaam Stock Exchange","Tanzania","Dar es Salaam","8:00-17:00","5:00-14:00","",DSEBuffer17,DSEEnable17);
   EPAMarketData18.Initialize(18,"EPA","Euronext Paris","France","Paris","9:00-17:30","8:00-16:30","Mar–Oct",EPABuffer18,EPAEnable18);
   EUREXMarketData19.Initialize(19,"EUREX","Eurex Exchange","Germany","Eschborn","8:00-22:00","7:00-21:00","Mar–Oct",EUREXBuffer19,EUREXEnable19);
   FSXMarketData20.Initialize(20,"FSX","Frankfurt Stock Exchange (Xetra)","Germany","Frankfurt","8:00-20:00","7:00-19:00","Mar–Oct",FSXBuffer20,FSXEnable20);
   GPWMarketData21.Initialize(21,"GPW","Warsaw Stock Exchange","Poland","Warsaw","9:00-17:00","8:00-16:00","Mar–Oct",GPWBuffer21,GPWEnable21);
   HKEXMarketData22.Initialize(22,"HKEX","Hong Kong Stock Exchange","Hong Kong","Hong Kong","9:30-16:00","1:30-8:00","",HKEXBuffer22,HKEXEnable22);
   HKFEMarketData23.Initialize(23,"HKFE","Hong Kong Futures Exchange","Hong Kong","Hong Kong","9:15-16:00","1:15-8:00","",HKFEBuffer23,HKFEEnable23);
   HNXMarketData24.Initialize(24,"HNX","Hanoi Stock Exchange","Vietnam","Hanoi","9:00-14:45","2:00-7:45","",HNXBuffer24,HNXEnable24);
   HOSEMarketData25.Initialize(25,"HOSE","Hochiminh Stock Exchange","Vietnam","Hochiminh","9:00-14:45","2:00-7:45","",HOSEBuffer25,HOSEEnable25);
   IDXMarketData26.Initialize(26,"IDX","Indonesia Stock Exchange","Indonesia","Jakarta","9:00-16:00","2:00-9:00","",IDXBuffer26,IDXEnable26);
   ISEMarketData27.Initialize(27,"ISE","Borsa Istanbul","Turkey","Istanbul","10:00-18:00","9:00-16:00","",ISEBuffer27,ISEEnable27);
   ISEMarketData28.Initialize(28,"ISE","Irish Stock Exchange","Ireland","Dublin","8:00-16:30","8:00-16:30","Mar–Oct",ISEBuffer28,ISEEnable28);
   JSEMarketData29.Initialize(29,"JSE","Johannesburg Stock Exchange","South Africa","Johannesburg","9:00-17:00","7:00-15:00","",JSEBuffer29,JSEEnable29);
   JSEMarketData30.Initialize(30,"JSE","Jamaica Stock Exchange","Jamaica","Kingston","9:00-13:00","14:00-17:00","",JSEBuffer30,JSEEnable30);
   KRXMarketData31.Initialize(31,"KRX","Korea Stock Exchange","South Korea","Busan & Seoul","9:00-15:30","0:00-6:00","",KRXBuffer31,KRXEnable31);
   LSEMarketData32.Initialize(32,"LSE","London Stock Exchange","United Kingdom","London","8:00-16:30","8:00-16:30","Mar–Oct",LSEBuffer32,LSEEnable32);
   LuxSEMarketData33.Initialize(33,"LuxSE","Luxembourg Stock Exchange","Luxembourg","Luxembourg City","9:00-17:35","8:00-16:35","Mar–Oct",LuxSEBuffer33,LuxSEEnable33);
   MOEXMarketData34.Initialize(34,"MOEX","Moscow Exchange","Russia","Moscow","10:00-18:45","7:00-15:45","",MOEXBuffer34,MOEXEnable34);
   MSEMarketData35.Initialize(35,"MSE","Malta Stock Exchange","Malta","Valletta","9:30-12:30","8:30-11:30","Mar–Oct",MSEBuffer35,MSEEnable35);
   MTAMarketData36.Initialize(36,"MTA","Milan Stock Exchange","Italy","Milan","9:00-17:35","8:00-16:35","Mar–Oct",MTABuffer36,MTAEnable36);
   MYXMarketData37.Initialize(37,"MYX","Bursa Malaysia","Malaysia","Kuala Lumpur","9:00-17:00","1:00-9:00","",MYXBuffer37,MYXEnable37);
   NASDAQMarketData38.Initialize(38,"NASDAQ","NASDAQ","United States","New York","9:30-16:00","14:30-21:00","Mar–Nov",NASDAQBuffer38,NASDAQEnable38);
   NSEMarketData39.Initialize(39,"NSE","National Stock Exchange of India[5]","India","Mumbai","9:15-15:30","3:45-10:00","",NSEBuffer39,NSEEnable39);
   NSEMarketData40.Initialize(40,"NSE","Nairobi Securities Exchange","Kenya","Nairobi","9:30-15:00","6:30-12:00","",NSEBuffer40,NSEEnable40);
   NSEMarketData41.Initialize(41,"NSE","Nigerian Stock Exchange","Nigeria","Lagos","10:00-16:00","9:00-15:00","",NSEBuffer41,NSEEnable41);
   NYSEMarketData42.Initialize(42,"NYSE","New York Stock Exchange","United States","New York","9:30-16:00","14:30-21:00","Mar–Nov",NYSEBuffer42,NYSEEnable42);
   NZSXMarketData43.Initialize(43,"NZSX","New Zealand Stock Market","New Zealand","Wellington","10:00-16:45","22:00-5:00","Sep–Apr",NZSXBuffer43,NZSXEnable43);
   OMXMarketData44.Initialize(44,"OMX","Helsinki Stock Exchange","Finland","Helsinki","10:00-18:30","8:00-16:30","Mar–Oct",OMXBuffer44,OMXEnable44);
   OMXMarketData45.Initialize(45,"OMX","Stockholm Stock Exchange","Sweden","Stockholm","9:00-17:30","8:00-16:30","Mar–Oct",OMXBuffer45,OMXEnable45);
   OMXRMarketData46.Initialize(46,"OMXR","Riga Stock Exchange","Latvia","Riga","10:00-16:00","8:00-14:00","Mar–Oct",OMXRBuffer46,OMXREnable46);
   OMXTMarketData47.Initialize(47,"OMXT","Tallinn Stock Exchange","Estonia","Tallinn","10:00-16:00","8:00-14:00","Mar–Oct",OMXTBuffer47,OMXTEnable47);
   OMXVMarketData48.Initialize(48,"OMXV","NASDAQ OMX Vilnius","Lithuania","Vilnius","10:00-16:00","8:00-14:00","Mar–Oct",OMXVBuffer48,OMXVEnable48);
   OSEMarketData49.Initialize(49,"OSE","Oslo Stock Exchange","Norway","Oslo","9:00-16:30","8:00-15:30","Mar–Oct",OSEBuffer49,OSEEnable49);
   PSEMarketData50.Initialize(50,"PSE","Philippine Stock Exchange","Philippines","Manila","9:30-15:30","1:30-7:30","",PSEBuffer50,PSEEnable50);
   PSIMarketData51.Initialize(51,"PSI","Euronext Lisbon","Portugal","Lisbon","8:00-16:30","8:00-16:30","Mar–Oct",PSIBuffer51,PSIEnable51);
   PSXMarketData52.Initialize(52,"PSX","Pakistan Stock Exchange","Pakistan","Karachi","9:30-15:30","4:30-10:30","",PSXBuffer52,PSXEnable52);
   SETMarketData53.Initialize(53,"SET","Stock Exchange of Thailand","Thailand","Bangkok","10:00-16:30","3:00-9:30","",SETBuffer53,SETEnable53);
   SGXMarketData54.Initialize(54,"SGX","Singapore Exchange","Singapore","Singapore","9:00-17:00","1:00-9:00","",SGXBuffer54,SGXEnable54);
   SIXMarketData55.Initialize(55,"SIX","Swiss Exchange","Switzerland","Zurich","9:00-17:30","8:00-16:30","Mar–Oct",SIXBuffer55,SIXEnable55);
   SSEMarketData56.Initialize(56,"SSE","Shanghai Stock Exchange","China","Shanghai","9:30-15:00","1:30-7:00","",SSEBuffer56,SSEEnable56);
   SZSEMarketData57.Initialize(57,"SZSE","Shenzhen Stock Exchange","China","Shenzhen","9:30-15:00","1:30-7:00","",SZSEBuffer57,SZSEEnable57);
   TADAWULMarketData58.Initialize(58,"TADAWUL","Saudi Stock Exchange","Saudi Arabia","Riyadh","10:00-15:00","7:00-12:00","",TADAWULBuffer58,TADAWULEnable58);
   TASEMarketData59.Initialize(59,"TASE","Tel Aviv Stock Exchange","Israel","Tel Aviv","9:00-17:30","7:00-15:30","Mar–Oct",TASEBuffer59,TASEEnable59);
   TSEMarketData60.Initialize(60,"TSE","Tokyo Stock Exchange","Japan","Tokyo","9:00-15:00","0:00-6:00","",TSEBuffer60,TSEEnable60);
   TSEMarketData61.Initialize(61,"TSE","Tehran Stock Exchange","Iran","Tehran","9:00-12:30","5:30-9:00","",TSEBuffer61,TSEEnable61);
   TSXMarketData62.Initialize(62,"TSX","Toronto Stock Exchange","Canada","Toronto","9:30-16:00","14:30-21:00","Mar–Nov",TSXBuffer62,TSXEnable62);
   TWSEMarketData63.Initialize(63,"TWSE","Taiwan Stock Exchange","Taiwan (Republic of China)","Taipei","9:00-13:30","1:00-5:30","",TWSEBuffer63,TWSEEnable63);
   UXMarketData64.Initialize(64,"UX","Ukrainian Exchange","Ukraine","Kiev","10:00-17:30","8:00-15:30","Mar–Oct",UXBuffer64,UXEnable64);
   VSEMarketData65.Initialize(65,"VSE","Wiener Börse AG","Austria","Vienna","8:55-17:35","7:55-16:35","Mar–Oct",VSEBuffer65,VSEEnable65);
//-- Back to the future xD
   for(int i=1; i<=65; i++)
     {
      //SetIndexShift(i,shift);            
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   for(int i=0; i<rates_total-prev_calculated; i++)
     {
      int value=0;
      //--- Set values to display lines for each market
      setValue(AMSBuffer1,i,AMSMarketData1,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(ASEBuffer2,i,ASEMarketData2,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(ASXBuffer3,i,ASXMarketData3,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BCBABuffer4,i,BCBAMarketData4,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BMEBuffer5,i,BMEMarketData5,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BMVBuffer6,i,BMVMarketData6,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BovespaBuffer7,i,BovespaMarketData7,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BSEBuffer8,i,BSEMarketData8,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BSEBuffer9,i,BSEMarketData9,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BSEBuffer10,i,BSEMarketData10,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(BXBuffer11,i,BXMarketData11,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(CSEBuffer12,i,CSEMarketData12,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(CSEBuffer13,i,CSEMarketData13,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(CSEBuffer14,i,CSEMarketData14,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(CSEBuffer15,i,CSEMarketData15,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(DSEBuffer16,i,DSEMarketData16,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(DSEBuffer17,i,DSEMarketData17,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(EPABuffer18,i,EPAMarketData18,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(EUREXBuffer19,i,EUREXMarketData19,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(FSXBuffer20,i,FSXMarketData20,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(GPWBuffer21,i,GPWMarketData21,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(HKEXBuffer22,i,HKEXMarketData22,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(HKFEBuffer23,i,HKFEMarketData23,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(HNXBuffer24,i,HNXMarketData24,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(HOSEBuffer25,i,HOSEMarketData25,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(IDXBuffer26,i,IDXMarketData26,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(ISEBuffer27,i,ISEMarketData27,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(ISEBuffer28,i,ISEMarketData28,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(JSEBuffer29,i,JSEMarketData29,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(JSEBuffer30,i,JSEMarketData30,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(KRXBuffer31,i,KRXMarketData31,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(LSEBuffer32,i,LSEMarketData32,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(LuxSEBuffer33,i,LuxSEMarketData33,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(MOEXBuffer34,i,MOEXMarketData34,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(MSEBuffer35,i,MSEMarketData35,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(MTABuffer36,i,MTAMarketData36,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(MYXBuffer37,i,MYXMarketData37,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(NASDAQBuffer38,i,NASDAQMarketData38,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(NSEBuffer39,i,NSEMarketData39,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(NSEBuffer40,i,NSEMarketData40,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(NSEBuffer41,i,NSEMarketData41,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(NYSEBuffer42,i,NYSEMarketData42,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(NZSXBuffer43,i,NZSXMarketData43,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(OMXBuffer44,i,OMXMarketData44,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(OMXBuffer45,i,OMXMarketData45,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(OMXRBuffer46,i,OMXRMarketData46,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(OMXTBuffer47,i,OMXTMarketData47,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(OMXVBuffer48,i,OMXVMarketData48,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(OSEBuffer49,i,OSEMarketData49,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(PSEBuffer50,i,PSEMarketData50,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(PSIBuffer51,i,PSIMarketData51,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(PSXBuffer52,i,PSXMarketData52,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(SETBuffer53,i,SETMarketData53,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(SGXBuffer54,i,SGXMarketData54,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(SIXBuffer55,i,SIXMarketData55,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(SSEBuffer56,i,SSEMarketData56,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(SZSEBuffer57,i,SZSEMarketData57,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(TADAWULBuffer58,i,TADAWULMarketData58,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(TASEBuffer59,i,TASEMarketData59,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(TSEBuffer60,i,TSEMarketData60,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(TSEBuffer61,i,TSEMarketData61,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(TSXBuffer62,i,TSXMarketData62,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(TWSEBuffer63,i,TWSEMarketData63,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(UXBuffer64,i,UXMarketData64,iTime(Symbol(),PERIOD_CURRENT,i),value);
      setValue(VSEBuffer65,i,VSEMarketData65,iTime(Symbol(),PERIOD_CURRENT,i),value);
      Maximum0[i]=value+1;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void setValue(double &buffer[],int index,MarketData &market,datetime time,int &value)
  {
   double val=EMPTY_VALUE;
   if(market.enable)
     {
      value++;
      int hour    =  TimeHour(time);
      int min     =  TimeMinute(time);
      int hm      =  hour*60+min;
      int open    =  market.getUTCOpenHour()*60+market.getUTCOpenMinute();
      int close   =  market.getUTCCloseHour()*60+market.getUTCCloseMinute();
      if(hm>=open && hm<close)
         val= value;


      string objname=market.name+" Session label";
      ObjectCreate(objname,OBJ_TEXT,WindowFind(WindowExpertName()),time+40*60,value-0.1);
      ObjectSet(objname,OBJPROP_BACK,false);
      ObjectSetText(objname,market.name,8,"Tahoma",clrWhite);
     }
   buffer[index]=val;
  }
//+------------------------------------------------------------------+
// TO DO
//    Add labels to identify each market
//    Add Support for DST (Daylight Saving Time)
