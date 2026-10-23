//+------------------------------------------------------------------+
//|                                            Hamyar.mq4            |
//|                                        Copyright © 2010, Farshad |
//|                                           http://www.vizhish.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Farshad Saremifar"
#property link      "farshad.saremifar@gmail.com"
#define TITLE		0
#define COUNTRY		1
#define DATE		2
#define TIME		3
#define IMPACT		4
#define FORECAST	5
#define PREVIOUS	6

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1  Snow
#property indicator_style1 STYLE_DASH

#property indicator_width1 1
#property indicator_color2  Red
#property indicator_width2 4
#property indicator_color3  DodgerBlue
#property indicator_width3 4
#property indicator_color4  Crimson
#property indicator_width4 1
#property indicator_style4 STYLE_DOT
#property indicator_color5  SteelBlue
#property indicator_width5 1
#property indicator_style5 STYLE_DOT
#property indicator_color6  Magenta
#property indicator_style6 STYLE_DASHDOTDOT
#property indicator_width6 1
#property indicator_color7  Aqua
#property indicator_style7 STYLE_DASHDOTDOT
#property indicator_width7 1

extern int NumberOfDays=10;
extern int ATR_Period=25;
extern int ATRTimeframe=5;
extern bool English=true;
extern bool alert=false;
extern bool Email_Alert=false;
extern int LocalTimeZone = 0;  
extern bool Display=true; 
 
extern bool ShowPivots = false;
extern bool ShowFibos= false;
extern bool ShowYesterdayHighLow = false;
extern bool ShowMidPitvot = false;
extern bool ShowCamarilla = false;
extern string Part1        ="Sessions";
extern bool ShowSessions=false;
  
 extern string SydneyBegin    = "00:00";  
extern string SydneyEnd      = "06:00";    
 color  SydneyColor    = Gray;
   
extern string AsiaBegin    = "01:00";  
extern string AsiaEnd      = "07:00";   
color  AsiaColor    = Yellow;
extern string EurBegin     = "06:00";   
extern string EurEnd       = "14:00";  
 color  EurColor     = Crimson;   
extern string LondonBegin     = "07:00";   
extern string LondonEnd       = "15:00";  
color  LondonColor     = Lime;    
extern string USABegin     = "12:00";   
extern string USAEnd       = "20:00";   
color  USAColor     = Sienna; 

extern string Part2        ="News";
extern bool ShowNews=false;

extern bool 	ShowHigh 		= true;
extern bool 	ShowMedium 		= true;
extern bool 	ShowLow 			= true;
extern bool 	ShowSpeaks 		= true; 		// news items with "Speaks" in them have different characteristics
 bool		IsEA_Call			= false;
int		OffsetHours			= 0;
bool		AllowWebUpdates		= true;			// Set this to false when using in another EA or Chart, so that the multiple instances of the indicator dont fight with each other
 int		Alert1MinsBefore	= -1;			// Set to -1 for no Alert
 int		Alert2MinsBefore	= -1;			// Set to -1 for no Alert
 bool		ReportAllForUSD		= false;
 bool 	EnableLogging 		= false; 		// Perhaps remove this from externs once its working well
 bool		ShowNextTwoEvents	= true;
 bool		ShowVertNews		= true;
int 		TxtSize 			= 10;
color 	TxtColorTitle 		= Yellow;
color 	TxtColorNews 		= Yellow;
 color 	TxtColorImpact 		= Red;
 color 	TxtColorPrevious 	= Peru;
 color 	TxtColorForecast 	= Lime;
 int		VertTxtShift 		= 21;			// How far away below the ask line we want to place our vertical news text
 int		VertLeftLineShift 	= 900;			// How far away to the left of the line we want to place our vertical news text
 int		VertRightLineShift 	= 200;			// How far away to the left of the line we want to place our vertical news text
 color	VertLineColor 		= Peru;	// Color of our vertical news line
 color	VertTxtColor 		= Peru;		// Color of our vertical text color 
 int		VertTxtSize 		= 8;
 extern bool ShowNewsOnChart=true;
 int     NewsWindow        =0;			// Color of our vertical text
 int		NewsCorner 			= 0;			// Choose which corner to place headlines 0=Upper Left, 1=Upper Right, 2=lower left , 3=lower right
 bool		SaveXmlFiles		= false;		// If true, this will keep the daily XML files

int		DebugLevel = 5;
 string noteBox = "Box Parameters";
 bool Newsbox_on = true;
color BoxColor = DimGray;
color BoxColor2 = C'35,35,35';

double 	ExtMapBuffer0[];	// Contains (minutes until) each news event
double 	ExtMapBuffer1[];	// Contains only most recent and next news event ([0] & [1])
double 	ExtMapBuffer2[];	// Contains impact value for most recent and next news event


string	sUrl = "http://cdn.forexfactory.com/ffcal_week_this.xml";
int 	xmlHandle;
int 	logHandle = -1;
int 	BoEvent, finalend, end, i;
int		begin;
string 	mainData[100][7];
int 	minsTillNews;
string 	sData, csvoutput;
string	commentStr;
int		tmpMins;
int		idxOfNext;
int		dispMinutes[2];
string 	dispTitle[2], 
		dispCountry[2], 
		dispImpact[2], 
		dispForecast[2], 
		dispPrevious[2];
string 	sTags[7] = { "<title>", "<country>", "<date>", "<time>", "<impact>", "<forecast>", "<previous>" };
string 	eTags[7] = { "</title>", "</country>", "</date>", "</time>", "</impact>", "</forecast>", "</previous>" };

static bool NeedToGetFile = false;
static int	PrevMinute = -1;
static int	RefreshMin = 0;
static int	RefreshHour = 0;

datetime 	LastTimeAlert1 = 0;	// Used to make sure we only draw something once per annoucement. Added by MN
string 		xmlFileName;  		// Made global. added by MN

 int BarForLabels= 10;    

double Res3[], Res2[], Res1[], Pivot[], Sup1[], Sup2[], Sup3[];
double thresholdBuffer[];
double vol_m[];
double vol_t[];
double ind_c[];
double PDayHigh, PDayLow;
string ThisSymbol;
datetime BarTime, PivotDayStartTime;
  string txtv;
static datetime LastTradeBarTime;
int VisibleBars, DayStartBar, LeftMostBar, RightMostBar;
int multiply;
int MyPoint;
int pip,pip2,pip3,pipd;
 int shiftx = 1;
 int shifty = 1;
 string NAME= "Hamyar System Version 2.0";
string BS1, BS2, BS3, TpB1, TpB2, TpB3, StB1, StB2, StB3;
string SS1, SS2, SS3, TpS1, TpS2, TpS3, StS1, StS2, StS3;
string Tp1, Tp2, Tp3, Tp4, St1, St2, St3, St4, PRICE;
color PriceColor;
//--------------------------------------------------------------------
// Initialization
//--------------------------------------------------------------------
int init()
{
if( ShowNewsOnChart)
{
  NewsWindow        =0;			// Color of our vertical text
	NewsCorner 			= 0;		
 
 }
else
{
NewsWindow        =1;			// Color of our vertical text
	NewsCorner 			= 3;		

} 
 
 
 
  DeleteObjects();
  for (int i=0; i<NumberOfDays; i++) {
  
  CreateObjects("SY"+i, SydneyColor);
    CreateObjects("AS"+i, AsiaColor);
    CreateObjects("EU"+i, EurColor);
    CreateObjects("LO"+i, LondonColor);
    CreateObjects("US"+i, USAColor);
  }
  Comment("");
  
 	if (DebugLevel > 0)
		Print("In Init()...\n");
			MathSrand(TimeLocal());
	RefreshMin  = (MathRand() % 60);
	RefreshHour = (MathRand() % 6);

	if (DebugLevel > 0)
	{
		Print("RefreshMin  == ", RefreshMin);
		Print("RefreshHour == ", RefreshHour);
	}
	 
   SetIndexBuffer( 0, Pivot);
   SetIndexBuffer( 1, Sup1);
   SetIndexBuffer( 2, Res1);
   SetIndexBuffer( 3, Sup2);
   SetIndexBuffer( 4, Res2);
   SetIndexBuffer( 5, Sup3);
   SetIndexBuffer( 6, Res3);

  
  SetIndexStyle(0, DRAW_LINE);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexStyle(5, DRAW_LINE,STYLE_DASH);
   SetIndexStyle(6, DRAW_LINE,STYLE_DASH);

   
   SetIndexEmptyValue( 0, EMPTY_VALUE );
   SetIndexEmptyValue( 1, EMPTY_VALUE );
   SetIndexEmptyValue( 2, EMPTY_VALUE );
   SetIndexEmptyValue( 3, EMPTY_VALUE );
   SetIndexEmptyValue( 4, EMPTY_VALUE );
   SetIndexEmptyValue( 5, EMPTY_VALUE );
   SetIndexEmptyValue( 6, EMPTY_VALUE );

   SetIndexLabel( 0, "Pivot" );
   SetIndexLabel( 1, "SellZone" );
   SetIndexLabel( 2, "BuyZone" );
   SetIndexLabel( 3, "SellTP1" );
   SetIndexLabel( 4, "BuyTP1" );
   SetIndexLabel( 5, "SellTP2" );
   SetIndexLabel( 6, "BuyTP2" );
if(Digits==3||Digits==5)MyPoint=10; else MyPoint=1; 
 if(Digits==3)multiply=100;
   if(Digits==2)multiply=100;
   if(Digits==5)multiply=10000;
   if(Digits==4)multiply=10000;
  
   

   ThisSymbol = Symbol();
   PivotDayStartTime = 0; 
         
     
ArrayResize(vol_m,Bars);
ArrayResize(vol_t,Bars);
ArrayResize(thresholdBuffer,Bars);
 
              
ArrayResize(ind_c,Bars);
   ArrayInitialize(ind_c,0.0);   
ArrayInitialize(vol_m,0.0); 
  ArrayInitialize(vol_t,0.0); 
   ArrayInitialize(thresholdBuffer,0.0); 
LastTradeBarTime = Time[1];

   return(0);
}

//--------------------------------------------------------------------
//| De-initialization                                                |
//--------------------------------------------------------------------
int deinit()
{  DeleteObjects();
  	int i;
  Comment("");
ObjectDelete ("xAlarm_label4");
	ObjectDelete ("xAlarm_label3");
	ObjectDelete ("bNewsBox");
	ObjectDelete ("bNewsBox2");
	ObjectDelete ("aNewsBoxb");
	ObjectDelete ("bNewsBox2b");
	ObjectDelete ("xAlarm_label");
	ObjectDelete ("xAlarm_label2");
	ObjectDelete("Sponsor"); 

	ObjectDelete("Minutes"); 
	ObjectDelete("Impact");
	ObjectDelete("Previous"); 
	ObjectDelete("Forecast");

	ObjectDelete("Minutes2"); 
	ObjectDelete("Impact2");
	ObjectDelete("Previous2"); 
	ObjectDelete("Forecast2");
	ObjectDelete("aNewsBox");
	// Cycle through all the Objects looking for the Vertical Line. //added by MN
	for(i=ObjectsTotal()-1; i >= 0; i--)
	{
		string VerticalLineName = ObjectName(i);
		if (StringSubstr(VerticalLineName, 0, 5) != "vLine")
			continue;
      
		ObjectDelete(VerticalLineName);   
	}

	// Cycle through all the Objects looking for the HeadLine text. //added by MN
	for (i=ObjectsTotal()-1; i >= 0; i--)
	{
		string HeadlineName = ObjectName(i);
		if (StringSubstr(HeadlineName, 0, 8) != "Headline")
			continue;
      
		ObjectDelete(HeadlineName);   
	}
   
   
	// Fixed one case of divide by zero where multiple charts 
	// indicator is on was trying to overwrite the same file
	xmlFileName = GetXmlFileName();
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ|FILE_WRITE);

	// File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
	if (xmlHandle >= 0)
	{
		// Since file exists, Close what we just opened
		FileClose(xmlHandle);
		
		// Delete our news file and redownload a new one to prevent a remainder from zero divide error
		if (!SaveXmlFiles)
			FileDelete(xmlFileName);
	}
   ObjectDelete("BUYAREAARROW");
   ObjectDelete("SELLAREAARROW");

   int obj_total= ObjectsTotal();
   
   for (i= obj_total; i>=0; i--) {
      string name= ObjectName(i);
    
      if (StringSubstr(name,0,7)=="[PIVOT]") 
         ObjectDelete(name);
   }
   
    obj_total= ObjectsTotal();
   
   for ( i= obj_total; i>=0; i--) {
      name= ObjectName(i);
    
      if (StringSubstr(name,0,4)=="info") 
         ObjectDelete(name);
   }
   
    obj_total= ObjectsTotal();
   
   
   ObjectDelete("YesterdayStart"); 
   ObjectDelete("YesterdayEnd"); 

   ObjectDelete("YesterdayStart Label"); 
   ObjectDelete("YesterdayEnd Label"); 
   
   ObjectDelete("BackGroundA01"); 
   ObjectDelete("BackGroundA02"); 
      ObjectDelete("BackGroundA03"); 
         ObjectDelete("BackGroundA04"); 
   
    ObjectDelete("BackGroundB01"); 
   ObjectDelete("BackGroundB02"); 
      ObjectDelete("BackGroundB03"); 
         ObjectDelete("BackGroundB04"); 
   
   
   
   ObjectDelete("Pivot Label");
   ObjectDelete("Pivot Line");

   string types= "RSHLM"; 
   
   for ( i= 0; i<StringLen(types); i++) {
      for (int j= 0; j<6; j++) {   
         ObjectDelete(StringSubstr(types, i, 1) + j +" Line");
         ObjectDelete(StringSubstr(types, i, 1) + j +" Label");
      }
   }
   for ( i= obj_total; i>=0; i--) {
      name= ObjectName(i);
    
    if (StringSubstr(name,0,2)=="h2") 
         ObjectDelete(name);
   }



/*
string BS1, BS2, BS3, TpB1, TpB2, TpB3, StB1, StB2, StB3;
string SS1, SS2, SS3, TpS1, TpS2, TpS3, StS1, StS2, StS3;
  */ 


   return(0);
}

//--------------------------------------------------------------------
//| Main iteration                                                   |
//--------------------------------------------------------------------
int start()
{
 datetime dt=CurTime();
if (ShowSessions){
  for (int i=0; i<NumberOfDays; i++) {
  
    DrawObjects(dt, "SY"+i, SydneyBegin, SydneyEnd);
    DrawObjects(dt, "AS"+i, AsiaBegin, AsiaEnd);
    DrawObjects(dt, "EU"+i, EurBegin, EurEnd);
    DrawObjects(dt, "LO"+i, LondonBegin, LondonEnd);
    DrawObjects(dt, "US"+i, USABegin, USAEnd);
    dt=decDateTradeDay(dt);
    while (TimeDayOfWeek(dt)>5) dt=decDateTradeDay(dt);
  }
}

if (ShowNews)shownews();  

datetime startofday=0;
datetime endofday=0;
   int  Count;
   double Range;
int first5,first15,first30,first1h,first4h,second5,second15,second30,second1h,second4h;   
 if (Display){
      ObjectCreate("SELLAREAARROW", OBJ_ARROW, 0, 0, 0);
      ObjectSet("SELLAREAARROW",OBJPROP_ARROWCODE,238);
      ObjectSet("SELLAREAARROW",OBJPROP_COLOR,Red);
      ObjectSet("SELLAREAARROW",OBJPROP_WIDTH,1);
    
      ObjectCreate("BUYAREAARROW", OBJ_ARROW, 0, 0, 0);
      ObjectSet("BUYAREAARROW",OBJPROP_ARROWCODE,236);
      ObjectSet("BUYAREAARROW",OBJPROP_COLOR,DodgerBlue);
      ObjectSet("BUYAREAARROW",OBJPROP_WIDTH,1);
      }
      
   i =NumberOfDays*((60*24)/Period())+1*((60*24)/Period());

startofday=iTime(Symbol(),PERIOD_D1,0)-(LocalTimeZone*60);
  endofday=startofday+1440*60;

   while(i >=0)
   {    
      if( PivotDay( Time[i+1], LocalTimeZone ) != PivotDay( Time[i], LocalTimeZone ) )
      {
         Count = iBarShift( NULL, 0, PivotDayStartTime ) - i;           
         PDayHigh = High[ iHighest( NULL, 0, MODE_HIGH, Count, i+1 ) ]; 
         PDayLow = Low[ iLowest( NULL, 0, MODE_LOW, Count, i+1 ) ]; 
         
         double pip1=iATR(Symbol(),gettimeframe(ATRTimeframe-2),ATR_Period,iBarShift(Symbol(),gettimeframe(ATRTimeframe-2),PivotDayStartTime,false))*multiply;
    
          pip=iATR(Symbol(),gettimeframe(ATRTimeframe-1),ATR_Period,iBarShift(Symbol(),gettimeframe(ATRTimeframe-1),PivotDayStartTime,false))*multiply;
         pip2=iATR(Symbol(),gettimeframe(ATRTimeframe+1),ATR_Period,iBarShift(Symbol(),gettimeframe(ATRTimeframe+1),PivotDayStartTime,false))*multiply;
         pip3=iATR(Symbol(),gettimeframe(ATRTimeframe),ATR_Period,iBarShift(Symbol(),gettimeframe(ATRTimeframe),PivotDayStartTime,false))*multiply;
         
         Pivot[i] = ( PDayHigh + PDayLow + Close[i+1] ) / 3;    
         Range = PDayHigh - PDayLow;
    if(Close[i]>iMA(Symbol(),0,ATR_Period,0,1,0,i))
    {
         Res1[i] =Pivot[i]+ (pip)*Point*MyPoint;                      
         Res2[i] = Res1[i]+ (pip)*Point*MyPoint;                          
         Res3[i] = Pivot[i] + (pip2+pip3-pip1)*Point*MyPoint;                            
         Sup1[i] = Pivot[i] - pip3*Point*MyPoint;                    
         Sup2[i] = Sup1[i] - pip*Point*MyPoint;                            
         Sup3[i] = Pivot[i] - (pip2+pip3)*Point*MyPoint;                            
        }
    if(Close[i]<iMA(Symbol(),0,ATR_Period,0,1,0,i))
    {
         Res1[i] =Pivot[i]+ pip3*Point*MyPoint;                      
         Res2[i] = Res1[i]+ pip*Point*MyPoint;                          
         Res3[i] = Pivot[i] + (pip2+pip3)*Point*MyPoint;                            
         Sup1[i] = Pivot[i] - (pip)*Point*MyPoint;                    
         Sup2[i] = Sup1[i] - (pip)*Point*MyPoint;                            
         Sup3[i] = Pivot[i] - (pip2+pip3-pip1)*Point*MyPoint;                            
        }     
        
        
         Res3[i+1] = Res3[i];
         Res2[i+1] = Res2[i];
         Res1[i+1] = Res1[i];
         Pivot[i+1] = Pivot[i];
         Sup1[i+1] =  Sup1[i];
         Sup2[i+1] =  Sup2[i];
         Sup3[i+1] =  Sup3[i];
         
          Res3[i+2] = EMPTY_VALUE;
         Res2[i+2] = EMPTY_VALUE;
         Res1[i+2] = EMPTY_VALUE;
         Pivot[i+2] = EMPTY_VALUE;
         Sup1[i+2] = EMPTY_VALUE;
         Sup2[i+2] = EMPTY_VALUE;
         Sup3[i+2] = EMPTY_VALUE;
  	
      
         PivotDayStartTime = Time[i];
      }
      else     
      {
        
         Res3[i] = Res3[i+1];
         Res2[i] = Res2[i+1];
         Res1[i] = Res1[i+1];
         Pivot[i] = Pivot[i+1];
         Sup1[i] = Sup1[i+1];
         Sup2[i] = Sup2[i+1];
         Sup3[i] = Sup3[i+1];
     }  
         //------------------------------------------------
   
      VisibleBars = WindowBarsPerChart();
      BarTime = Time[Count];
      
      i--;
   }
ObjectMove("BUYAREAARROW",0,PivotDayStartTime, Res1[0]+ pip*Point*MyPoint);
ObjectMove("SELLAREAARROW",0,PivotDayStartTime,Sup1[0]);        


 
 
//Print(P+","+R1+","+Time[i]+","+Bars+","+limit);

//-Pivots

       double P, Q, D, R1,R2,R3, S1,S2,S3;
        Range = PDayHigh - PDayLow;
         R1 = 2 * Pivot[0] - PDayLow;                     // R1
         R2 = Pivot[0] + Range;                           // R2
         R3 = R1 + Range;                            // R3
         S1 = 2 * Pivot[0] - PDayHigh;                    // S1
         S2 = Pivot [0]- Range;                           // S2
         S3 = S1 - Range;                            // S3
    
   Q =Range;
   P = Pivot[0];
	
	if (ShowPivots==true) {
      SetLevel("R1", R1, Magenta, startofday,endofday);
      SetLevel("R2", R2, Magenta, startofday,endofday);
      SetLevel("R3", R3, Magenta, startofday,endofday);

      SetLevel("S1", S1, PowderBlue, startofday,endofday);
      SetLevel("S2", S2, PowderBlue, startofday,endofday);
      SetLevel("S3", S3, PowderBlue, startofday,endofday);
   }
   
   if (ShowFibos) {
     
      SetLevel("Low - 61.8%", PDayLow - Q*0.618, Yellow, startofday,endofday);
      SetLevel("Low - 38.2%", PDayLow - Q*0.382, Yellow, startofday,endofday);
      SetLevel("Low + 38.2%", PDayLow + Q*0.382, Yellow, startofday,endofday);
      SetLevel("LowHigh 50%", PDayLow + Q*0.5, Yellow, startofday,endofday);
      SetLevel("High - 38.2%", PDayHigh - Q*0.382, Yellow, startofday,endofday);
      SetLevel("High + 38.2%", PDayHigh + Q*0.382, Yellow, startofday,endofday);
      SetLevel("High + 61.8%", PDayHigh +  Q*0.618, Yellow, startofday,endofday);
   
   }

   //----- Camarilla
   if (ShowCamarilla==true) {

           
      double H4,H3,L4,L3;
	   H4 = (Q*0.55)+iClose(Symbol(),PERIOD_D1,1);
	   H3 = (Q*0.27)+iClose(Symbol(),PERIOD_D1,1);
	   L3 = iClose(Symbol(),PERIOD_D1,1)-(Q*0.27);	
	   L4 = iClose(Symbol(),PERIOD_D1,1)-(Q*0.55);	
	   
      SetLevel("H3", H3, Khaki, startofday,endofday);
      SetLevel("H4", H4, Khaki, startofday,endofday);
      SetLevel("L3", L3, Khaki, startofday,endofday);
      SetLevel("L4", L4, Khaki, startofday,endofday);
   }


   //------ Midpoints
   if (ShowMidPitvot==true) {
     
      double M0,M1,M2,M3,M4,M5;
	   M5 = (R2+R3)/2;
	   M4 = (R1+R2)/2;
	   M3 = (P+R1)/2;
	   M2 = (P+S1)/2;
	   M1 = (S1+S2)/2;
	   M0 = (S2+S3)/2;
      SetLevel("M5", M5, LawnGreen, startofday,endofday);
      SetLevel("M4", M4, LawnGreen, startofday,endofday);
      SetLevel("M3", M3, LawnGreen, startofday,endofday);
      SetLevel("M2", M2, LawnGreen, startofday,endofday);
      SetLevel("M1", M1, LawnGreen, startofday,endofday);
      SetLevel("M0", M0, LawnGreen, startofday,endofday);
   }
   if (ShowYesterdayHighLow) {
      SetLevel("Y\'s High", PDayHigh, Orange, startofday,endofday);
      SetLevel("Y\'s Low", PDayLow, Orange, startofday,endofday);
   }
   
//000000000000000000000000000000000000000000000000000000000000000000
//======================Screen   
string trend;
 if (Display){  
int atr=iATR(Symbol(),gettimeframe(ATRTimeframe-1),ATR_Period,0)*multiply;
      int   atr2=iATR(Symbol(),gettimeframe(ATRTimeframe+1),ATR_Period,0)*multiply;
       int  atr3=iATR(Symbol(),gettimeframe(ATRTimeframe),ATR_Period,0)*multiply;
   
              
        
      
         
color colorm30,colorm15,colorh4,colorm5,colorh1;
string trend30,trend15,trend4,trend5,trend60;

  if (English==false)
 {
      if (iCustom(Symbol(),PERIOD_M5,"HamyarTrend",ATR_Period-5,0,0)==10){trend5="ÕÚæÏí";colorm5=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_M5,"HamyarTrend",ATR_Period-5,1,0)==10){trend5="äÒæáí";colorm5=Red;}
      
      if (iCustom(Symbol(),PERIOD_M15,"HamyarTrend",ATR_Period-4,0,0)==10){trend15="ÕÚæÏí";colorm15=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_M15,"HamyarTrend",ATR_Period-4,1,0)==10){trend15="äÒæáí";colorm15=Red;}
      
      if (iCustom(Symbol(),PERIOD_M30,"HamyarTrend",ATR_Period-3,0,0)==10){trend30="ÕÚæÏí";colorm30=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_M30,"HamyarTrend",ATR_Period-3,1,0)==10){trend30="äÒæáí";colorm30=Red;}
      
      if (iCustom(Symbol(),PERIOD_H4,"HamyarTrend",ATR_Period-2,0,0)==10){trend4="ÕÚæÏí";colorh4=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_H4,"HamyarTrend",ATR_Period-2,1,0)==10){trend4="äÒæáí";colorh4=Red;}
     
      if (iCustom(Symbol(),PERIOD_H1,"HamyarTrend",ATR_Period,1,0)==10){trend60="äÒæáí";colorh1=Red;}
      if (iCustom(Symbol(),PERIOD_H1,"HamyarTrend",ATR_Period,0,0)==10){trend60="ÕÚæÏí";colorh1=DeepSkyBlue;}
      
  }
  else 
  {
   if (iCustom(Symbol(),PERIOD_M5,"HamyarTrend",ATR_Period-5,0,0)==10){trend5="Bullish";colorm5=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_M5,"HamyarTrend",ATR_Period-5,1,0)==10){trend5="Bearish";colorm5=Red;}
      
      if (iCustom(Symbol(),PERIOD_M15,"HamyarTrend",ATR_Period-4,0,0)==10){trend15="Bullish";colorm15=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_M15,"HamyarTrend",ATR_Period-4,1,0)==10){trend15="Bearish";colorm15=Red;}
      
      if (iCustom(Symbol(),PERIOD_M30,"HamyarTrend",ATR_Period-3,0,0)==10){trend30="Bullish";colorm30=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_M30,"HamyarTrend",ATR_Period-3,1,0)==10){trend30="Bearish";colorm30=Red;}
      
      if (iCustom(Symbol(),PERIOD_H4,"HamyarTrend",ATR_Period-2,0,0)==10){trend4="Bullish";colorh4=DeepSkyBlue;}
      if (iCustom(Symbol(),PERIOD_H4,"HamyarTrend",ATR_Period-2,1,0)==10){trend4="Bearish";colorh4=Red;}
     
     if (iCustom(Symbol(),PERIOD_H1,"HamyarTrend",ATR_Period,1,0)==10){trend60="Bearish";colorh1=Red;}
      if (iCustom(Symbol(),PERIOD_H1,"HamyarTrend",ATR_Period,0,0)==10){trend60="Bullish";colorh1=DeepSkyBlue;}
       
 
      
  }    
  } 
  
 string sharayet_aval,sharayet_hala;
 string s5,s15,s30,s60,s4,f5,f15,f30,f60,f4;
color cs5,cs15,cs30,cs60,cs4,cf5,cf15,cf30,cf60,cf4;
 
 color aval,dovom;
         second5=volat(3,2,ATR_Period-5);
         second15=volat(2,3,ATR_Period-4);
         second30=volat(1,4,ATR_Period-3);
         second1h=volat(0,5,ATR_Period);
         second4h=volat(0,6,ATR_Period-2);

         
  if (English==false)
  
 {

if(second5==1){s5="ãäÇÓÈ";cs5=Lime;}else {s5="ÓÇä";cs5=Red;}         
if(second15==1){s15="ãäÇÓÈ";cs15=Lime;}else {s15="ÓÇä";cs15=Red;}         
if(second30==1){s30="ãäÇÓÈ";cs30=Lime;}else {s30="ÓÇä";cs30=Red;}         
if(second1h==1){s60="ãäÇÓÈ";cs60=Lime;}else {s60="ÓÇä";cs60=Red;}         
if(second4h==1){s4="ãäÇÓÈ";cs4=Lime;}else {s4="ÓÇä";cs4=Red;}         
 }
 else
 {

if(second5==1){s5="Lucky!!!";cs5=Lime;}else {s5="GameOver";cs5=Red;}         
if(second15==1){s15="Lucky!!!";cs15=Lime;}else {s15="GameOver";cs15=Red;}         
if(second30==1){s30="Lucky!!!";cs30=Lime;}else {s30="GameOver";cs30=Red;}         
if(second1h==1){s60="Lucky!!!";cs60=Lime;}else {s60="GameOver";cs60=Red;}         
if(second4h==1){s4="Lucky!!!";cs4=Lime;}else {s4="GameOver";cs4=Red;}         
 
 }
 
 double   top=WindowPriceMax();
 double   bottom=WindowPriceMin();
 datetime left=Time[WindowFirstVisibleBar()];
 int      right_bound=WindowFirstVisibleBar()-WindowBarsPerChart();
 if(right_bound<0) right_bound=0;
 datetime right=Time[right_bound]+Period()*60;
 
        
if (English==false)
 {
//      clabel3("info",1,30," ÓíÓÊã åãíÇÑ ÑæÒÇäå Êåíå ÔÏå ÊæÓØ ÝÑÔÇÏ ÕÇÑãí ÝÑ",Lime);
//      clabel3("info2",1,45,"Copyright © 2010, Farshad Saremifar:farshad.saremifar@gmail.com",Lime);   
//      clabel("info3",1,10," ãíÇäíä ÊÛííÑÇÊ ÑæÒÇäå:"+"(ÇÈÊÏÇí ÑæÒ)"+pip2+" (ÝÚáí)"+atr2+"í ",Red);
//      clabel("info4",1,25,"ãíÇäíä ÊÛííÑÇÊ ãíÇä ÑæÒ"+"(ÇÈÊÏÇí ÑæÒ)"+pip3+"(ÝÚáí)"+atr3+"í ",Red);
//      clabel("info5",1,40,"ÍÏÇÞá ÊÛííÑÇÊ ãíÇä ÑæÒ"+"(ÇÈÊÏÇí ÑæÒ)"+pip+"(ÝÚáí)"+atr+"í ",Red);

      if(Display){
         TextLabel( "BackGroundA01", 8, 14,1,  "g", 203, "Webdings",DarkGray );
         TextLabel( "BackGroundA02", 8, 150,1,  "g", 203, "Webdings", DarkGray);
         TextLabel( "BackGroundA03", 8, 229,1,  "g", 203, "Webdings", DarkGray);
         TextLabel( "BackGroundA04", 8, 330,1,  "g", 203, "Webdings", DarkGray);

         TextLabel( "BackGroundB01", 10, 15,1,  "g", 200, "Webdings",DimGray);
         TextLabel( "BackGroundB02", 10, 150,1,  "g", 200, "Webdings", DimGray );
         TextLabel( "BackGroundB03", 10, 260,1,  "g", 200, "Webdings", DimGray);
         TextLabel( "BackGroundB04", 10, 330,1,  "g", 200, "Webdings", DimGray);
         
         BS1 = DoubleToStr (Res1[0],Digits);
         BS2 = DoubleToStr (Res1[0]+(pip/3)*Point*MyPoint,Digits);
         BS3 = DoubleToStr (Res1[0]+(pip/2)*Point*MyPoint,Digits);
         TpB1 = DoubleToStr (Res2[0],Digits);
         TpB2 = DoubleToStr (Res3[0],Digits);
         TpB3 = "   FREE ";
         StB1 = DoubleToStr (Sup1[0],Digits);
         StB2 = DoubleToStr (Sup1[0],Digits);
         StB3 = DoubleToStr (Sup1[0],Digits);

         SS1 = DoubleToStr (Sup1[0],Digits);
         SS2 = DoubleToStr (Sup1[0]-(pip/3)*Point*MyPoint,Digits);
         SS3 = DoubleToStr (Sup1[0]-(pip/2)*Point*MyPoint,Digits);
         TpS1 = DoubleToStr (Sup2[0],Digits);
         TpS2 = DoubleToStr (Sup3[0],Digits);
         TpS3 = "   FREE ";
         StS1 = DoubleToStr (Res1[0],Digits);
         StS2 = DoubleToStr (Res1[0],Digits);
         StS3 = DoubleToStr (Res1[0],Digits);
         
         Tp1 = DoubleToStr (Res1[0],Digits)+"            "+DoubleToStr (Res2[0],Digits);
         Tp2 = DoubleToStr (Res2[0],Digits)+"            "+DoubleToStr (Res3[0],Digits);
         Tp3 = DoubleToStr (Sup1[0],Digits)+"            "+DoubleToStr (Sup2[0],Digits);
         Tp4 = DoubleToStr (Sup2[0],Digits)+"            "+DoubleToStr (Sup3[0],Digits);
         St1 = DoubleToStr (Sup3[0],Digits);
         St2 = DoubleToStr (Sup3[0],Digits);
         St3 = DoubleToStr (Res3[0],Digits);
         St4 = DoubleToStr (Res3[0],Digits);
         PRICE = (DoubleToStr(iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0),Digits));
        
       //ObjectDelete("Titel");
       TextLabel( "h2Titel", 12,22,1,""+ NAME +"", 11, "Arial Bold", Yellow);
       TextLabel( "h2Line1", 12,35,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2BuyZ",  12,50,1, "ãÍÏæÏå ÎÑíÏ", 9, "Tahoma Bold", LightBlue );
       TextLabel( "h2Line2", 12,60,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", White );
       TextLabel( "h2BuySt1",42,75,1, "1#BuyStop@               TP                & SL@    ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2BuySt2",42,90,1, "2#BuyStop@               TP                & SL@    ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2BuySt3",42,105,1, "3#BuyStop@               TP                & SL@    ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2BS1", 157,75, 1, "  "+BS1, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2BS2", 157,90, 1, "  "+BS2, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2BS3", 157,105, 1, "  "+BS3, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2TpB1", 95,75, 1, "  "+TpB1, 9, "Arial Bold", YellowGreen );
       TextLabel( "h2TpB2", 95,90, 1, "  "+TpB2, 9, "Arial Bold", YellowGreen );
       TextLabel( "h2TpB3", 95,105, 1, "  "+TpB3, 9, "Arial Bold", YellowGreen );
       TextLabel( "h2StB1", 11,75, 1, "  "+StB1, 9, "Arial Bold", Yellow );
       TextLabel( "h2StB2", 11,90, 1, "  "+StB2, 9, "Arial Bold", Yellow );
       TextLabel( "h2StB3", 11,105, 1, "  "+StB3, 9, "Arial Bold", Yellow );

       TextLabel( "h2Line3", 12,118,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2SellZ",  12,133,1, "ãÍÏæÏå ÝÑæÔ", 9, "Tahoma Bold", Orange );
       TextLabel( "h2Line4", 12,143,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", White );
       TextLabel( "h2SellSt1",42,158,1, "1#SellStop@               TP                & SL@    ", 9, "Arial Bold", Salmon );
       TextLabel( "h2SellSt2",42,173,1, "2#SellStop@               TP                & SL@    ", 9, "Arial Bold", Salmon );
       TextLabel( "h2SellSt3",42,188,1, "3#SellStop@               TP                & SL@    ", 9, "Arial Bold", Salmon );
       TextLabel( "h2SS1", 157,158, 1, "  "+SS1, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2SS2", 157,173, 1, "  "+SS2, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2SS3", 157,188, 1, "  "+SS3, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2TpS1", 95,158, 1, "  "+TpS1, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2TpS2", 95,173, 1, "  "+TpS2, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2TpS3", 95,188, 1, "  "+TpS3, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2StS1", 11,158, 1, "  "+StS1, 9, "Arial Bold", Yellow );
       TextLabel( "h2StS2", 11,173, 1, "  "+StS2, 9, "Arial Bold", Yellow );
       TextLabel( "h2StS3", 11,188, 1, "  "+StS3, 9, "Arial Bold", Yellow );
       TextLabel( "h2Line5", 12,202,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2Reverse",  12,217,1, "æÒíÔä åÇí ãÚæÓ", 9, "Tahoma Bold", DarkSeaGreen );
       TextLabel( "h2Line6", 12,230,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", White );
       TextLabel( "h2BuySt4",46,260,1,  "Tp1                    TP2                 & SL     ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2BuySt5",46,275,1,  "#Tp1                    TP2                 & SL     ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2SellSt4",46,305,1, "Tp1                    TP2                 & SL     ", 9, "Arial Bold", OrangeRed );
       TextLabel( "h2SellSt5",46,320,1, "#Tp1                    TP2                 & SL     ", 9, "Arial Bold", Salmon );
	    TextLabel( "h2BuyZ2",  12,245,1, "ÎÑíÏ", 9, "Tahoma Bold", DeepSkyBlue );
	    TextLabel( "h2SellZ2",  12,290,1, "ÝÑæÔ", 9, "Tahoma Bold", Orange );
       TextLabel( "h2Tp1", 95,260, 1, "  "+Tp1, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2Tp2", 95,275, 1, "  "+Tp2, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2Tp3", 95,305, 1, "  "+Tp3, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2Tp4", 95,320, 1, "  "+Tp4, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2St1", 11,260, 1, "  "+St1, 9, "Arial Bold", Yellow );
       TextLabel( "h2St2", 11,275, 1, "  "+St2, 9, "Arial Bold", Yellow );
       TextLabel( "h2St3", 11,305, 1, "  "+St3, 9, "Arial Bold", Yellow );
       TextLabel( "h2St4", 11,320, 1, "  "+St4, 9, "Arial Bold", Yellow );
       TextLabel( "h2Line7", 12,333,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2PriceL", 12,355, 1, "ÞíãÊ", 10, "Tahoma Bold", Silver );
	    PriceColor = Silver;
	    if(iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0)>Res1[0]) PriceColor = DeepSkyBlue;
	    if(iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0)<Sup1[0]) PriceColor = OrangeRed;
       TextLabel( "h2Price", 50,350, 1, PRICE , 16, "Arial Bold", PriceColor );
       TextLabel( "h2SPREADL", 150,355, 1, "ÇÓÑÏ", 9, "Tahoma Bold", Silver );
       TextLabel( "h2SPREAD", 200,355, 1, DoubleToStr (MarketInfo(Symbol(),MODE_SPREAD)*Point*multiply,1), 9, "Arial Bold", LawnGreen );
       TextLabel( "h2TAvDRL", 16,375, 1, "ãíÇäíä ÊÛííÑÇÊ ÑæÒÇäå:                 (ÝÚáí)            í" , 8, "Tahoma", Wheat );
       TextLabel( "h2TAvMRL", 16,390, 1, "ãíÇäíä ÊÛííÑÇÊ ãíÇä ÑæÒ:             (ÝÚáí)            í" , 8, "Tahoma", Wheat );
       TextLabel( "h2TMiMRL", 16,405, 1, "ÍÏÇÞá ÊÛííÑÇÊ ãíÇä ÑæÒ:               (ÝÚáí)            í", 8, "Tahoma", Wheat );
       TextLabel( "h2TAvDR", 130,375, 1, atr2+"                    "+pip2, 9, "Arial Bold", OrangeRed );
       TextLabel( "h2TAvMR", 130,390, 1, atr3+"                    "+pip3, 9, "Arial Bold", OrangeRed );
       TextLabel( "h2TMiMR", 130,405, 1, atr+"                    "+pip, 9, "Arial Bold", OrangeRed );
       TextLabel( "h2Line8", 12,418, 1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
       TextLabel( "h2Title1", 12,433, 1, "ÊÇíã ÝÑíã          ÔÑÇíØ ÈÇÒÇÑ          ÑæäÏ ÈÇÒÇÑ", 9, "Tahoma", Silver );
       TextLabel( "h2Title2", 32,448, 1, "H4 ", 9, "Arial Bold", Silver );
       TextLabel( "h2Title3", 32,463, 1, "H1 ", 9, "Arial Bold", Silver );
       TextLabel( "h2Title4", 32,478, 1, "M30", 9, "Arial Bold", Silver );
       TextLabel( "h2Title5", 32,493, 1, "M15", 9, "Arial Bold", Silver );
       TextLabel( "h2Title6", 32,508, 1, "M5 ", 9, "Arial Bold", Silver );

       TextLabel( "h2Cond1", 115,448, 1, s4, 9, "Tahoma Bold", cs4 );
       TextLabel( "h2Cond2", 115,463, 1, s60, 9, "Tahoma Bold", cs60 );
       TextLabel( "h2Cond3", 115,478, 1, s30, 9, "Tahoma Bold", cs30 );
       TextLabel( "h2Cond4", 115,493, 1, s15, 9, "Tahoma Bold", cs15 );
       TextLabel( "h2Cond5", 115,508, 1, s5, 9, "Tahoma Bold", cs5 );

       TextLabel( "h2Trend1", 180,448, 1, trend4+" "+getpower(PERIOD_H4 ,PERIOD_D1,PERIOD_W1 ,trend4), 9, "Tahoma Bold", colorh4 );
      TextLabel( "h2Trend2", 180,463, 1, trend60+" "+getpower(PERIOD_H1 ,PERIOD_H4,PERIOD_D1 ,trend60), 9, "Tahoma Bold", colorh1 );
       TextLabel( "h2Trend3", 180,478, 1, trend30+" "+getpower(PERIOD_M30 ,PERIOD_H1,PERIOD_H4 ,trend30), 9, "Tahoma Bold", colorm30 );
       TextLabel( "h2Trend4", 180,493, 1, trend15+" "+getpower(PERIOD_M15 ,PERIOD_M30,PERIOD_H1 ,trend15), 9, "Tahoma Bold", colorm15 );
       TextLabel( "h2Trend5", 180,508, 1, trend5+" "+getpower(PERIOD_M5 ,PERIOD_M15,PERIOD_M30 ,trend5), 9, "Tahoma Bold", colorm5 );
       
       TextLabel( "h2pish9", 12,525,1, "ÊÍáíá: " +txtv  , 9, "Tahoma Bold", Lime );
       
       TextLabel( "h2Line9", 12,535,1, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
       TextLabel( "h2Title7", 12,550, 1," ÓíÓÊã åãíÇÑ ÑæÒÇäå Êåíå ÔÏå ÊæÓØ ÝÑÔÇÏ ÕÇÑãí ÝÑ", 8, "Tahoma", Snow );
       TextLabel( "h2Title8", 65,565, 1, "Copyright © 2010, Farshad Saremifar:", 9, "Arial", Snow );
       TextLabel( "h2Title9", 102,578, 1, "farshad.saremifar@gmail.com", 9, "Arial", Snow );
       /*
         clabel("info6",1,100," ::::::::::::æÒíÔä åÇí Çæáíå ÈÑ ÇÓÇÓ íÔ Èíäí ÑæÒ::::::::::::",Lime);
         clabel("info28",1,115," ::::::::::::ãÍÏæÏå ÎÑíÏ::::::::::::",DeepSkyBlue);
         clabel("info7",1,130," 1#:"+"BuyStop at:"+DoubleToStr (Res1[0],Digits)+" Tp:"+DoubleToStr (Res2[0],Digits)+" SL:"+DoubleToStr (Sup1[0],Digits),DeepSkyBlue);
         clabel("info8",1,145," 2#:"+"BuyStop at:"+DoubleToStr (Res1[0]+(pip/3)*Point*MyPoint,Digits)+" Tp:"+DoubleToStr (Res3[0],Digits)+" SL:"+DoubleToStr (Sup1[0],Digits),DeepSkyBlue);
         clabel("info9",1,160," 3#:"+"BuyStop at:"+DoubleToStr (Res1[0]+(pip/2)*Point*MyPoint,Digits)+" Tp:Free"+" SL:"+DoubleToStr (Sup1[0],Digits),DeepSkyBlue);
   
         clabel("info10",1,175," --------ãÍÏæÏå ÝÑæÔ--------",Red);
         clabel("info11",1,190," 1#:"+"SellStop at:"+DoubleToStr (Sup1[0],Digits)+" Tp:"+DoubleToStr (Sup2[0],Digits)+" SL:"+DoubleToStr (Res1[0],Digits),Red);
         clabel("info12",1,205," 2#:"+"SellStop at:"+DoubleToStr (Sup1[0]-(pip/3)*Point*MyPoint,Digits)+" Tp:"+DoubleToStr (Sup3[0],Digits)+" SL:"+DoubleToStr (Res1[0],Digits),Red);
         clabel("info13",1,220," 3#:"+"SellStop at:"+DoubleToStr (Sup1[0]-(pip/2)*Point*MyPoint,Digits)+" Tp:Free"+" SL:"+DoubleToStr (Res1[0],Digits),Red);
         clabel("info14",1,235," ::::::::::::æÒíÔä åÇí ãÚæÓ::::::::::::",Lime); 
         clabel("info15",1,250," ---------ÎÑíÏ--------",DeepSkyBlue);
         clabel("info16",1,265," TP1:"+DoubleToStr (Res1[0],Digits)+" TP2:"+DoubleToStr (Res2[0],Digits)+" SL:"+DoubleToStr (Sup3[0],Digits),DeepSkyBlue);
         clabel("info17",1,280," TP#1:"+DoubleToStr (Res2[0],Digits)+" TP#2:"+DoubleToStr (Res3[0],Digits)+" SL:"+DoubleToStr (Sup3[0],Digits),DeepSkyBlue);
         clabel("info18",1,295," ---------ÝÑæÔ--------",Red);
         clabel("info19",1,310," TP1:"+DoubleToStr (Sup1[0],Digits)+" TP2:"+DoubleToStr (Sup2[0],Digits)+" SL:"+DoubleToStr (Res3[0],Digits),Red);
         clabel("info20",1,325," TP#1:"+DoubleToStr (Sup2[0],Digits)+" TP#2:"+DoubleToStr (Sup3[0],Digits)+" SL:"+DoubleToStr (Res3[0],Digits),Red);
         clabel("info40",1,340," ########ÑæäÏ ÏÑ ÊÇíã ÝÑíã åÇí ãÎÊáÝ#######",Lime);
         clabel("info41",1,355,trend4+":H4",colorh4);
         clabel("info42",1,370,trend30+":M30",colorm30);
         clabel("info43",1,385,trend15+":M15",colorm15);
         clabel("info44",1,400,trend5+":M5",colorm5);
   
         clabel2("info50",1,60,"------ÔÑÇíØ ÈÇÒÇÑ ÏÑ ÊÇíã ÝÑíã åÇí ãÎÊáÝ---------",Lime);
 
         clabel2("info51",1,50,"M5:"+s5,cs5);
         clabel2("info52",1,40,"M15:"+s15,cs15);
         clabel2("info53",1,30,"M30:"+s30,cs30);
         clabel2("info54",1,20,"H1:"+s60,cs60);
         clabel2("info55",1,10,"H4:"+s4,cs4);
         */
      }
 } 
 else
   {
//      clabel3("info",1,1,"Hamyar Version 1.5 By Farshad Saremifar",Lime);
//      clabel3("info2",1,10,"Copyright © 2010, Farshad Saremifar:farshad.saremifar@gmail.com",Lime);   
//      clabel("info3",1,10,"Average Daily Range:"+"(at New Day)"+pip2+"(Current)"+atr2+" Pips",Red);
//      clabel("info4",1,20,"Average MidDay Range"+"(at New Day)"+pip3+"(Current)"+atr3+" Pips",Red);
//      clabel("info5",1,30,"Minimum MidDay"+"(at New Day)"+pip+"(Current)"+atr+" Pips",Red);
 
      if(Display){
         TextLabel( "BackGroundA01", 8, 14,4,  "g", 203, "Webdings",DarkGray );
         TextLabel( "BackGroundA02", 8, 150,4,  "g", 203, "Webdings", DarkGray );
         TextLabel( "BackGroundA03", 8, 229,4,  "g", 203, "Webdings", DarkGray);
         TextLabel( "BackGroundA04", 8, 330,4,  "g", 203, "Webdings",DarkGray);

         TextLabel( "BackGroundB01", 10, 15,4,  "g", 200, "Webdings",Gray );
         TextLabel( "BackGroundB02", 10, 150,4,  "g", 200, "Webdings", Gray );
         TextLabel( "BackGroundB03", 10, 260,4,  "g", 200, "Webdings", Gray );
         TextLabel( "BackGroundB04", 10, 330,4,  "g", 200, "Webdings", Gray );
         
         BS1 = DoubleToStr (Res1[0],Digits);
         BS2 = DoubleToStr (Res1[0]+(pip/3)*Point*MyPoint,Digits);
         BS3 = DoubleToStr (Res1[0]+(pip/2)*Point*MyPoint,Digits);
         TpB1 = DoubleToStr (Res2[0],Digits);
         TpB2 = DoubleToStr (Res3[0],Digits);
         TpB3 = "   FREE ";
         StB1 = DoubleToStr (Sup1[0],Digits);
         StB2 = DoubleToStr (Sup1[0],Digits);
         StB3 = DoubleToStr (Sup1[0],Digits);

         SS1 = DoubleToStr (Sup1[0],Digits);
         SS2 = DoubleToStr (Sup1[0]-(pip/3)*Point*MyPoint,Digits);
         SS3 = DoubleToStr (Sup1[0]-(pip/2)*Point*MyPoint,Digits);
         TpS1 = DoubleToStr (Sup2[0],Digits);
         TpS2 = DoubleToStr (Sup3[0],Digits);
         TpS3 = "   FREE ";
         StS1 = DoubleToStr (Res1[0],Digits);
         StS2 = DoubleToStr (Res1[0],Digits);
         StS3 = DoubleToStr (Res1[0],Digits);
         
         Tp1 = DoubleToStr (Res1[0],Digits)+"           "+DoubleToStr (Res2[0],Digits);
         Tp2 = DoubleToStr (Res2[0],Digits)+"           "+DoubleToStr (Res3[0],Digits);
         Tp3 = DoubleToStr (Sup1[0],Digits)+"           "+DoubleToStr (Sup2[0],Digits);
         Tp4 = DoubleToStr (Sup2[0],Digits)+"           "+DoubleToStr (Sup3[0],Digits);
         St1 = DoubleToStr (Sup3[0],Digits);
         St2 = DoubleToStr (Sup3[0],Digits);
         St3 = DoubleToStr (Res3[0],Digits);
         St4 = DoubleToStr (Res3[0],Digits);
         PRICE = (DoubleToStr(iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0),Digits));
        
       //ObjectDelete("Titel");
       TextLabel( "h2Titel", 12,22,4,""+ NAME +"", 11, "Arial Bold", Yellow);
       TextLabel( "h2Line1", 12,35,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2BuyZ",  12,50,4, "BUY ZONE", 9, "Arial Bold", DeepSkyBlue );
       TextLabel( "h2Line2", 12,60,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", White );
       TextLabel( "h2BuySt1",12,75,4, "1#BuyStop@               TP                & SL@    ", 9, "Arial Bold", DodgerBlue );
       TextLabel( "h2BuySt2",12,90,4, "2#BuyStop@               TP                & SL@    ", 9, "Arial Bold", LightSkyBlue );
       TextLabel( "h2BuySt3",12,105,4, "3#BuyStop@               TP                & SL@    ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2BS1", 78,75, 4, "  "+BS1, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2BS2", 78,90, 4, "  "+BS2, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2BS3", 78,105, 4, "  "+BS3, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2TpB1", 140,75, 4, "  "+TpB1, 9, "Arial Bold", YellowGreen );
       TextLabel( "h2TpB2", 140,90, 4, "  "+TpB2, 9, "Arial Bold", YellowGreen );
       TextLabel( "h2TpB3", 140,105, 4, "  "+TpB3, 9, "Arial Bold", YellowGreen );
       TextLabel( "h2StB1", 225,75, 4, "  "+StB1, 9, "Arial Bold", Yellow );
       TextLabel( "h2StB2", 225,90, 4, "  "+StB2, 9, "Arial Bold", Yellow );
       TextLabel( "h2StB3", 225,105, 4, "  "+StB3, 9, "Arial Bold", Yellow );

       TextLabel( "h2Line3", 12,118,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2SellZ",  12,133,4, "SELL ZONE", 9, "Arial Bold", Orange );
       TextLabel( "h2Line4", 12,143,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", White );
       TextLabel( "h2SellSt1",12,158,4, "1#SellStop@               TP                & SL@    ", 9, "Arial Bold", OrangeRed );
       TextLabel( "h2SellSt2",12,173,4, "2#SellStop@               TP                & SL@    ", 9, "Arial Bold", Tomato );
       TextLabel( "h2SellSt3",12,188,4, "3#SellStop@               TP                & SL@    ", 9, "Arial Bold", Salmon );
       TextLabel( "h2SS1", 78,158, 4, "  "+SS1, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2SS2", 78,173, 4, "  "+SS2, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2SS3", 78,188, 4, "  "+SS3, 9, "Arial Bold", DarkOrange );
       TextLabel( "h2TpS1", 140,158, 4, "  "+TpS1, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2TpS2", 140,173, 4, "  "+TpS2, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2TpS3", 140,188, 4, "  "+TpS3, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2StS1", 225,158, 4, "  "+StS1, 9, "Arial Bold", Yellow );
       TextLabel( "h2StS2", 225,173, 4, "  "+StS2, 9, "Arial Bold", Yellow );
       TextLabel( "h2StS3", 225,188, 4, "  "+StS3, 9, "Arial Bold", Yellow );
       TextLabel( "h2Line5", 12,202,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2Reverse",  12,217,4, "Reverse Positions", 9, "Arial Bold", DarkSeaGreen );
       TextLabel( "h2Line6", 12,230,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", White );
       TextLabel( "h2BuySt4",12,260,4, "1#Tp1@               TP2@                & SL@    ", 9, "Arial Bold", DodgerBlue );
       TextLabel( "h2BuySt5",12,275,4, "2#Tp1@               TP2@                & SL@    ", 9, "Arial Bold", LightBlue );
       TextLabel( "h2SellSt4",12,305,4, "1#Tp1@               TP2@                & SL@    ", 9, "Arial Bold", OrangeRed );
       TextLabel( "h2SellSt5",12,320,4, "2#Tp1@               TP2@                & SL@    ", 9, "Arial Bold", Salmon );
	    TextLabel( "h2BuyZ2",  12,245,4, "BUY", 9, "Arial Bold", DeepSkyBlue );
	    TextLabel( "h2SellZ2",  12,290,4, "SELL ", 9, "Arial Bold", Orange );
       TextLabel( "h2Tp1", 53,260, 4, "  "+Tp1, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2Tp2", 53,275, 4, "  "+Tp2, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2Tp3", 53,305, 4, "  "+Tp3, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2Tp4", 53,320, 4, "  "+Tp4, 9, "Arial Bold", LimeGreen );
       TextLabel( "h2St1", 223,260, 4, "  "+St1, 9, "Arial Bold", Yellow );
       TextLabel( "h2St2", 223,275, 4, "  "+St2, 9, "Arial Bold", Yellow );
       TextLabel( "h2St3", 223,305, 4, "  "+St3, 9, "Arial Bold", Yellow );
       TextLabel( "h2St4", 223,320, 4, "  "+St4, 9, "Arial Bold", Yellow );
       TextLabel( "h2Line7", 12,333,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
	    TextLabel( "h2PriceL", 12,355, 4, "Price ", 10, "Arial Bold", Silver );
	    PriceColor = Silver;
	    if(iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0)>Res1[0]) PriceColor = DeepSkyBlue;
	    if(iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0)<Sup1[0]) PriceColor = OrangeRed;
       TextLabel( "h2Price", 50,350, 4, PRICE , 16, "Arial Bold", PriceColor );
       TextLabel( "h2SPREADL", 150,355, 4, "SPREAD ", 9, "Arial Bold", Silver );
       TextLabel( "h2SPREAD", 200,355, 4, DoubleToStr (MarketInfo(Symbol(),MODE_SPREAD)*Point*multiply,1), 9, "Arial Bold", LawnGreen );
       
       TextLabel( "h2TAvDRL", 12,375, 4, "Average Daily Range:          (Current)         Pips", 9, "Arial Bold", Wheat );
       TextLabel( "h2TAvMRL", 12,390, 4, "Average MidDay Range:          (Current)        Pips", 9, "Arial Bold", Wheat );
       TextLabel( "h2TMiMRL", 12,405, 4, "Minimum MidDay:         (Current)         Pips", 9, "Arial Bold", Wheat );
       TextLabel( "h2TAvDR", 140,375, 4, pip2+"                      "+atr2, 9, "Arial Bold", OrangeRed );
       TextLabel( "h2TAvMR", 150,390, 4, pip3+"                      "+atr3, 9, "Arial Bold", OrangeRed );
       TextLabel( "h2TMiMR", 116,405, 4, pip+"                      "+atr, 9, "Arial Bold", OrangeRed );
       TextLabel( "h2Line8", 12,418,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
       TextLabel( "h2Title1", 12,433, 4, "TimeFrame         Condition                Trend", 9, "Arial Bold", Silver );
       TextLabel( "h2Title2", 32,448, 4, "H4 ", 9, "Arial Bold", Silver );
       TextLabel( "h2Title3", 32,463, 4, "H1 ", 9, "Arial Bold", Silver );
       TextLabel( "h2Title4", 32,478, 4, "M30", 9, "Arial Bold", Silver );
       TextLabel( "h2Title5", 32,493, 4, "M15", 9, "Arial Bold", Silver );
       TextLabel( "h2Title6", 32,508, 4, "M5 ", 9, "Arial Bold", Silver );

       TextLabel( "h2Cond1", 105,448, 4, s4, 9, "Arial Bold", cs4 );
       TextLabel( "h2Cond2", 105,463, 4, s60, 9, "Arial Bold", cs60 );
       TextLabel( "h2Cond3", 105,478, 4, s30, 9, "Arial Bold", cs30 );
       TextLabel( "h2Cond4", 105,493, 4, s15, 9, "Arial Bold", cs15 );
       TextLabel( "h2Cond5", 105,508, 4, s5, 9, "Arial Bold", cs5 );

       TextLabel( "h2Trend1", 170,448, 4, trend4+" "+getpower(PERIOD_H4 ,PERIOD_D1,PERIOD_W1 ,trend4), 9, "Arial Bold", colorh4 );
       TextLabel( "h2Trend2", 170,463, 4,  trend60+" "+getpower(PERIOD_H1 ,PERIOD_H4,PERIOD_D1 ,trend60), 9, "Arial Bold", colorh1 );
//       TextLabel( "Trend2", 150,463, 4, "H1 ", 9, "Arial Bold", colorh1 );
       TextLabel( "h2Trend3", 170,478, 4, trend30+" "+getpower(PERIOD_M30 ,PERIOD_H1,PERIOD_H4 ,trend30), 9, "Arial Bold", colorm30 );
       TextLabel( "h2Trend4", 170,493, 4,  trend15+" "+getpower(PERIOD_M15 ,PERIOD_M30,PERIOD_H1 ,trend15), 9, "Arial Bold", colorm15 );
       TextLabel( "h2Trend5", 170,508, 4, trend5+" "+getpower(PERIOD_M5 ,PERIOD_M15,PERIOD_M30 ,trend5), 9, "Arial Bold", colorm5 );
       TextLabel( "h2pish9", 12,525,4, "Analysis:" +txtv  , 9, "Arial Bold", Lime );
       
       TextLabel( "h2Line9", 12,535,4, ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", White );
       TextLabel( "h2Title7", 12,550, 4, "Hamyar Version 2.0 By Farshad Saremifar", 9, "Arial", Snow );
       TextLabel( "h2Title8", 12,565, 4, "Copyright © 2010, Farshad Saremifar:", 9, "Arial", Snow );
       TextLabel( "h2Title9", 12,578, 4, "farshad.saremifar@gmail.com", 9, "Arial", Snow );
           

//         clabel("info10",1,130," ::::::::::in Sell Zone:::::::::::-",Red);
//         clabel("info11",1,140," 1#:"+"SellStop at:"+DoubleToStr (Sup1[0],Digits)+" Tp:"+DoubleToStr (Sup2[0],Digits)+" SL:"+DoubleToStr (Res1[0],Digits),Red);
//         clabel("info12",1,150," 2#:"+"SellStop at:"+DoubleToStr (Sup1[0]-(pip/3)*Point*MyPoint,Digits)+" Tp:"+DoubleToStr (Sup3[0],Digits)+" SL:"+DoubleToStr (Res1[0],Digits),Red);
//         clabel("info13",1,160," 3#:"+"SellStop at:"+DoubleToStr (Sup1[0]-(pip/2)*Point*MyPoint,Digits)+" Tp:Free"+" SL:"+DoubleToStr (Res1[0],Digits),Red);
//         clabel("info14",1,170," ::::::::::::Reverse Positions::::::::::::",Lime); 
//         clabel("info15",1,180," ---------Buy--------",DeepSkyBlue);
//        clabel("info16",1,190," TP1:"+DoubleToStr (Res1[0],Digits)+" TP2:"+DoubleToStr (Res2[0],Digits)+" SL:"+DoubleToStr (Sup3[0],Digits),DeepSkyBlue);
//         clabel("info17",1,200," TP#1:"+DoubleToStr (Res2[0],Digits)+" TP#2:"+DoubleToStr (Res3[0],Digits)+" SL:"+DoubleToStr (Sup3[0],Digits),DeepSkyBlue);
//         clabel("info18",1,210," ---------Sell--------",Red);
 //        clabel("info19",1,220," TP1:"+DoubleToStr (Sup1[0],Digits)+" TP2:"+DoubleToStr (Sup2[0],Digits)+" SL:"+DoubleToStr (Res3[0],Digits),Red);
 //        clabel("info20",1,230," TP#1:"+DoubleToStr (Sup2[0],Digits)+" TP#2:"+DoubleToStr (Sup3[0],Digits)+" SL:"+DoubleToStr (Res3[0],Digits),Red);
  
/*         clabel("info40",1,240," ########Trends On Different TF\'s########",Lime);
         clabel("info41",1,250,"H4:"+trend4,colorh4);
         clabel("info42",1,260,"M30:"+trend30,colorm30);
         clabel("info43",1,270,"M15:"+trend15,colorm15);
         clabel("info44",1,280,"M5:"+trend5,colorm5);
   
         clabel2("info50",1,60,"-------All Timeframes Conditions---------",Lime);
 
         clabel2("info51",1,50,"M5:"+s5,cs5);
         clabel2("info52",1,40,"M15:"+s15,cs15);
         clabel2("info53",1,30,"M30:"+s30,cs30);
         clabel2("info54",1,20,"H1:"+s60,cs60);
         clabel2("info55",1,10,"H4:"+s4,cs4);*/
      }
  }
    
    if ((alert||Email_Alert)&&LastTradeBarTime != Time[0])
  {
     if (alert)
      {
      if (iCustom(Symbol(),0,"HamyarTrend",ATR_Period,0,1)==10&&iCustom(Symbol(),0,"HamyarTrend",ATR_Period,1,2)==10) Alert("ÑæäÏ ÇÒ äÒæáí Èå ÕÚæÏí ÊÈÏíá ÔÏå ÇÓÊ¡æÒíÔä åÇ ÑÇ ÈÓÊå æ æÒíÔä åÇí ãÚæÓ ÑÇ ÈíÑíÏ: "+"Symbol :"+Symbol());
      if (iCustom(Symbol(),0,"HamyarTrend",ATR_Period,0,2)==10&&iCustom(Symbol(),0,"HamyarTrend",ATR_Period,1,1)==10) Alert("ÑæäÏ ÇÒ ÕÚæÏí Èå äÒæáí ÊÈÏíá ÔÏå ÇÓÊ æÒíÔä åÇ ÑÇ ÈÓÊå æ æÒíÔä åÇí ãÚæÓ ÑÇ ÈíÑíÏ: "+"Symbol :"+Symbol());
      }
      if (Email_Alert)
      {
      if (iCustom(Symbol(),0,"HamyarTrend",ATR_Period,0,1)==10&&iCustom(Symbol(),0,"HamyarTrend",ATR_Period,1,2)==10)SendMail("Hamyar","ÑæäÏ ÇÒ äÒæáí Èå ÕÚæÏí ÊÈÏíá ÔÏå ÇÓÊ¡æÒíÔä åÇ ÑÇ ÈÓÊå æ æÒíÔä åÇí ãÚæÓ ÑÇ ÈíÑíÏ: "+"Symbol :"+Symbol());
      if (iCustom(Symbol(),0,"HamyarTrend",ATR_Period,0,2)==10&&iCustom(Symbol(),0,"HamyarTrend",ATR_Period,1,1)==10) SendMail("Hamyar","ÑæäÏ ÇÒ ÕÚæÏí Èå äÒæáí ÊÈÏíá ÔÏå ÇÓÊ æÒíÔä åÇ ÑÇ ÈÓÊå æ æÒíÔä åÇí ãÚæÓ ÑÇ ÈíÑíÏ: "+"Symbol :"+Symbol());
      }
       LastTradeBarTime = Time[0];
   }       
   return(0);
}



int PivotDay( datetime BarTime, datetime LocalTimeZone )
{
   int PDay = TimeDayOfWeek( BarTime - LocalTimeZone * 60 );

      if( PDay == 0 ) PDay = 1;      
      if( PDay == 6 ) PDay = 5;      

   return( PDay );
}
int gettimeframe(int time){

switch(time)
                     {
                     case 0: return(0);break;
                     case 1: return(1);break;                               
                     case 2: return(5);break;                   
                     case 3: return(15);break;                               
                     case 4: return(30);break;                   
                     case 5: return(60);break;                               
                     case 6: return(240);break;
                     case 7: return(1440);break;                   
                     }
}

void SetLevel(string text, double level, color col1, datetime startofday,datetime endofday)
{
   string labelname= "[PIVOT] " + text + " Label";
   string linename= "[PIVOT] " + text + " Line";
   int digits= MarketInfo(Symbol(), MODE_DIGITS);

   if (ObjectFind(labelname) != 0) {
      ObjectCreate(labelname, OBJ_TEXT, 0, MathMin(Time[BarForLabels], startofday), level);
   }
   else {
      ObjectMove(labelname, 0, MathMin(Time[BarForLabels], startofday), level);
   }
   ObjectSetText(labelname, " " + text + ": "+DoubleToStr(level, Digits), 8, "Arial", White);
   
   if (ObjectFind(linename) != 0) {
      ObjectCreate(linename, OBJ_TREND, 0, startofday, level, endofday,level);
      ObjectSet(linename, OBJPROP_STYLE, STYLE_DOT);
      ObjectSet(linename, OBJPROP_COLOR, col1);
      ObjectSet(linename, OBJPROP_RAY, false);
   }
   else {
      ObjectMove(linename, 1, endofday,level);
      ObjectMove(linename, 0, startofday, level);
   }
}
/*
void clabel2(string lblname,int x,int y,string txt,color txtcolor)
{
 if (ObjectFind( lblname)>0) ObjectDelete(lblname);
ObjectCreate(lblname, OBJ_LABEL,0, 0, 0);
ObjectSet(lblname, OBJPROP_CORNER, 2);
ObjectSetText(lblname,txt,9,"Tahoma", txtcolor);
ObjectSet(lblname, OBJPROP_XDISTANCE, x);
ObjectSet(lblname, OBJPROP_CORNER, 2);

ObjectSet(lblname, OBJPROP_YDISTANCE, y);
}

void clabel3(string lblname,int x,int y,string txt,color txtcolor)
{
 if (ObjectFind( lblname)>0) ObjectDelete(lblname);
ObjectCreate(lblname, OBJ_LABEL,0, 0, 0);
ObjectSet(lblname, OBJPROP_CORNER, 2);
ObjectSetText(lblname,txt,9,"Tahoma", txtcolor);
ObjectSet(lblname, OBJPROP_XDISTANCE, x);
ObjectSet(lblname, OBJPROP_CORNER, 0);

ObjectSet(lblname, OBJPROP_YDISTANCE, y);
}

void clabel(string lblname,int x,int y,string txt,color txtcolor)
{
 if (ObjectFind( lblname)>0) ObjectDelete(lblname);
ObjectCreate(lblname, OBJ_LABEL,0, 0, 0);
ObjectSet(lblname, OBJPROP_CORNER, 1);
ObjectSetText(lblname,txt,9,"Tahoma", txtcolor);
ObjectSet(lblname, OBJPROP_XDISTANCE, x);
ObjectSet(lblname, OBJPROP_CORNER, 1);

ObjectSet(lblname, OBJPROP_YDISTANCE, y);
}      
*/
int volat(int i,int timeframe,int period)
{
int signal=-1;
   double vol=0;
        int       Viscosity=MathRound(period/3);
 int       Sedimentation=period;
double    Threshold_level=1.1;
bool      lag_supressor=true;
 double    lag_s_K=0.5;
        double sa=iATR(NULL,gettimeframe(timeframe),Viscosity,i);
      double t1=ind_c[i+1];
      double t3=ind_c[i+3];
      double atr=NormalizeDouble(sa,Digits);
      if(lag_supressor)
         vol= sa/iATR(NULL,0,Sedimentation,i)+lag_s_K*(t1-t3);   
      else
         vol= sa/iATR(NULL,0,Sedimentation,i);   
    
      double anti_thres=iStdDev(NULL,gettimeframe(timeframe),Viscosity,0,MODE_LWMA,PRICE_TYPICAL,i);
      
      anti_thres=anti_thres/   
                 iStdDev(NULL,gettimeframe(timeframe),Sedimentation,0,MODE_LWMA,PRICE_TYPICAL,i);
                        
      double t=Threshold_level;
      t=t-anti_thres;
      
      if (vol>t){vol_t[i]=vol;vol_m[i]=vol;
                  signal=1;}
      else {vol_t[i]=vol;vol_m[i]=EMPTY_VALUE;
              signal=2;}   
      ind_c[i]=vol;
      thresholdBuffer[i]=t;   
      
return(signal);     

}


int TextLabel(string lblname, int xOffset, int yOffset,int iCorner, string Text, int FontSize, string FontName, color txtcolor)  
{      if (ObjectFind( lblname)>0) ObjectDelete(lblname);
   ObjectCreate(lblname,OBJ_LABEL         , 0, 0, 0 );
   ObjectSet   (lblname,OBJPROP_CORNER    , iCorner);
   ObjectSet   (lblname,OBJPROP_XDISTANCE , xOffset); 
   ObjectSet   (lblname,OBJPROP_YDISTANCE , yOffset);
   ObjectSet   (lblname,OBJPROP_BACK      , false );
   ObjectSetText( lblname, Text, FontSize, FontName, txtcolor );   
}


string getpower(int TF1 ,int TF2,int TF3 ,string tr)
{

int maTrendPeriodv_1 = 5;
int maTrendPeriodv_2 = 8;
int maTrendPeriodv_3 = 13;
int maTrendPeriodv_4 = 21;
int maTrendPeriodv_5 = 34;
double MaH11v,  MaH41v, MaD11v, MaH1pr1v, MaH4pr1v, MaD1pr1v;
double MaH12v,  MaH42v, MaD12v, MaH1pr2v, MaH4pr2v, MaD1pr2v;
double MaH13v,  MaH43v, MaD13v, MaH1pr3v, MaH4pr3v, MaD1pr3v;
double MaH14v,  MaH44v, MaD14v, MaH1pr4v, MaH4pr4v, MaD1pr4v;
double MaH15v,  MaH45v, MaD15v, MaH1pr5v, MaH4pr5v, MaD1pr5v;


 string H11v, H41v, D11v;
 string H12v, H42v, D12v;
 string H13v, H43v, D13v;
 string H14v, H44v, D14v;
 string H15v, H45v, D15v;
 color co11v , co41v , co61v;
 color co12v , co42v , co62v;
 color co13v , co43v , co63v;
 color co14v , co44v , co64v;
 color co15v , co45v , co65v;
 
double u1x5v, u1x8v, u1x13v, u1x21v, u1x34v;
double u2x5v, u2x8v, u2x13v, u2x21v, u2x34v;
double u3x5v, u3x8v, u3x13v, u3x21v, u3x34v;
double u1acv, u2acv, u3acv;

double d1x5v, d1x8v, d1x13v, d1x21v, d1x34v;
double d2x5v, d2x8v, d2x13v, d2x21v, d2x34v;
double d3x5v, d3x8v, d3x13v, d3x21v, d3x34v;
double d1acv, d2acv, d3acv;

 MaH11v=iMA(NULL,TF1,maTrendPeriodv_1,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr1v=iMA(NULL,TF1,maTrendPeriodv_1,0,MODE_SMA,PRICE_CLOSE,1);
     MaH12v=iMA(NULL,TF1,maTrendPeriodv_2,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr2v=iMA(NULL,TF1,maTrendPeriodv_2,0,MODE_SMA,PRICE_CLOSE,1);
     MaH13v=iMA(NULL,TF1,maTrendPeriodv_3,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr3v=iMA(NULL,TF1,maTrendPeriodv_3,0,MODE_SMA,PRICE_CLOSE,1);
     MaH14v=iMA(NULL,TF1,maTrendPeriodv_4,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr4v=iMA(NULL,TF1,maTrendPeriodv_4,0,MODE_SMA,PRICE_CLOSE,1);
     MaH15v=iMA(NULL,TF1,maTrendPeriodv_5,0,MODE_SMA,PRICE_CLOSE,0);   MaH1pr5v=iMA(NULL,TF1,maTrendPeriodv_5,0,MODE_SMA,PRICE_CLOSE,1);
    
     MaH41v=iMA(NULL,TF2,maTrendPeriodv_1,0,MODE_SMA,PRICE_CLOSE,0);  MaH4pr1v=iMA(NULL,TF2,maTrendPeriodv_1,0,MODE_SMA,PRICE_CLOSE,1);
     MaH42v=iMA(NULL,TF2,maTrendPeriodv_2,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr2v=iMA(NULL,TF2,maTrendPeriodv_2,0,MODE_SMA,PRICE_CLOSE,1);
     MaH43v=iMA(NULL,TF2,maTrendPeriodv_3,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr3v=iMA(NULL,TF2,maTrendPeriodv_3,0,MODE_SMA,PRICE_CLOSE,1);
     MaH44v=iMA(NULL,TF2,maTrendPeriodv_4,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr4v=iMA(NULL,TF2,maTrendPeriodv_4,0,MODE_SMA,PRICE_CLOSE,1);
     MaH45v=iMA(NULL,TF2,maTrendPeriodv_5,0,MODE_SMA,PRICE_CLOSE,0);   MaH4pr5v=iMA(NULL,TF2,maTrendPeriodv_5,0,MODE_SMA,PRICE_CLOSE,1);
     
     MaD11v=iMA(NULL,TF3,maTrendPeriodv_1,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr1v=iMA(NULL,TF3,maTrendPeriodv_1,0,MODE_SMA,PRICE_CLOSE,1);
     MaD12v=iMA(NULL,TF3,maTrendPeriodv_2,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr2v=iMA(NULL,TF3,maTrendPeriodv_2,0,MODE_SMA,PRICE_CLOSE,1);
     MaD13v=iMA(NULL,TF3,maTrendPeriodv_3,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr3v=iMA(NULL,TF3,maTrendPeriodv_3,0,MODE_SMA,PRICE_CLOSE,1);
     MaD14v=iMA(NULL,TF3,maTrendPeriodv_4,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr4v=iMA(NULL,TF3,maTrendPeriodv_4,0,MODE_SMA,PRICE_CLOSE,1);
     MaD15v=iMA(NULL,TF3,maTrendPeriodv_5,0,MODE_SMA,PRICE_CLOSE,0);   MaD1pr5v=iMA(NULL,TF3,maTrendPeriodv_5,0,MODE_SMA,PRICE_CLOSE,1);
     
 if (MaH11v < MaH1pr1v){H11v = " V ";   co11v = Red;   u1x5v = 0; d1x5v = 1;}
     if (MaH11v > MaH1pr1v){H11v = " /\\ "; co11v = Blue;  u1x5v = 1; d1x5v = 0;} 
     if (MaH11v == MaH1pr1v){H11v = " 0 "; co11v = Green;  u1x5v = 0; d1x5v = 0;}           
     if (MaH41v < MaH4pr1v){H41v = " V "; co41v = Red;     u2x5v = 0; d2x5v = 1;}            
     if (MaH41v > MaH4pr1v){H41v = " /\\ "; co41v = Blue;  u2x5v = 1; d2x5v = 0;}
     if (MaH41v == MaH4pr1v){H41v = " 0 "; co41v = Green;  u2x5v = 0; d2x5v = 0;}            
     if (MaD11v < MaD1pr1v){D11v = " V "; co61v = Red;     u3x5v = 0; d3x5v = 1;}            
     if (MaD11v > MaD1pr1v){D11v = " /\\ "; co61v = Blue;  u3x5v = 1; d3x5v = 0;}
     if (MaD11v == MaD1pr1v){D11v = " 0 "; co61v = Green;  u3x5v = 0; d3x5v = 0;}  
     
     if (MaH12v < MaH1pr2v){H12v = " V "; co12v = Red;     u1x8v = 0; d1x8v = 1;}
     if (MaH12v > MaH1pr2v){H12v = " /\\ "; co12v = Blue;  u1x8v = 1; d1x8v = 0;}
     if (MaH12v == MaH1pr2v){H12v = " 0 "; co12v = Green;  u1x8v = 0; d1x8v = 0;}            
     if (MaH42v < MaH4pr2v){H42v = " V "; co42v = Red;     u2x8v = 0; d2x8v = 1;}            
     if (MaH42v > MaH4pr2v){H42v = " /\\ "; co42v = Blue;   u2x8v = 1; d2x8v = 0;} 
     if (MaH42v == MaH4pr2v){H42v = " 0 "; co42v = Green;   u2x8v = 0; d2x8v = 0;}           
     if (MaD12v < MaD1pr2v){D12v = " V "; co62v = Red;      u3x8v = 0; d3x8v = 1;}             
     if (MaD12v > MaD1pr2v){D12v = " /\\ "; co62v = Blue;   u3x8v = 1; d3x8v = 0;}
     if (MaD12v == MaD1pr2v){D12v = " 0 "; co62v = Green;   u3x8v = 0; d3x8v = 0;} 
     
     if (MaH13v < MaH1pr3v){H13v = " V "; co13v = Red;    u1x13v = 0; d1x13v = 1;}
     if (MaH13v > MaH1pr3v){H13v = " /\\ "; co13v = Blue; u1x13v = 1; d1x13v = 0;}
     if (MaH13v ==MaH1pr3v){H13v = " 0 "; co13v = Green;  u1x13v = 0; d1x13v = 0;}              
     if (MaH43v < MaH4pr3v){H43v = " V "; co43v = Red; u2x13v = 0; d2x13v = 1;}            
     if (MaH43v > MaH4pr3v){H43v = " /\\ "; co43v = Blue; u2x13v = 1; d2x13v = 0;}
     if (MaH43v ==MaH4pr3v){H43v = " 0 "; co43v = Green;  u2x13v = 0; d2x13v = 0;}            
     if (MaD13v < MaD1pr3v){D13v = " V "; co63v = Red; u3x13v = 0; d3x13v = 1;}            
     if (MaD13v > MaD1pr3v){D13v = " /\\ "; co63v = Blue; u3x13v = 1; d3x13v = 0;}
     if (MaD13v ==MaD1pr3v){D13v = " 0 "; co63v = Green;  u3x13v = 0; d3x13v = 0;}
     
     if (MaH14v < MaH1pr4v){H14v = " V "; co14v = Red;    u1x21v = 0; d1x21v = 1;}
     if (MaH14v > MaH1pr4v){H14v = " /\\ "; co14v = Blue; u1x21v = 1; d1x21v = 0;}
     if (MaH14v == MaH1pr4v){H14v = " 0 "; co14v = Green; u1x21v = 0; d1x21v = 0;}              
     if (MaH44v < MaH4pr4v){H44v = " V "; co44v = Red; u2x21v = 0; d2x21v = 1;}            
     if (MaH44v > MaH4pr4v){H44v = " /\\ "; co44v = Blue; u2x21v = 1; d2x21v = 0;}
     if (MaH44v == MaH4pr4v){H44v = " 0 "; co44v = Green; u2x21v = 0; d2x21v = 0;}            
     if (MaD14v < MaD1pr4v){D14v = " V "; co64v = Red; u3x21v = 0; d3x21v = 1;}            
     if (MaD14v > MaD1pr4v){D14v = " /\\ "; co64v = Blue; u3x21v = 1; d3x21v = 0;} 
     if (MaD14v == MaD1pr4v){D14v = " 0 "; co64v = Green; u3x21v = 0; d3x21v = 0;}  
     
     if (MaH15v < MaH1pr5v){H15v = " V "; co15v = Red;    u1x34v = 0; d1x34v = 1;}
     if (MaH15v > MaH1pr5v){H15v = " /\\ "; co15v = Blue; u1x34v = 1; d1x34v = 0;} 
     if (MaH15v == MaH1pr5v){H15v = " 0 "; co15v = Green; u1x34v = 0; d1x34v = 0;}             
     if (MaH45v < MaH4pr5v){H45v = " V "; co45v = Red;    u2x34v = 0; d2x34v = 1;}            
     if (MaH45v > MaH4pr5v){H45v = " /\\ "; co45v = Blue; u2x34v = 1; d2x34v = 0;}
     if (MaH45v == MaH4pr5v){H45v = " 0 "; co45v = Green; u2x34v = 0; d2x34v = 0;}            
     if (MaD15v < MaD1pr5v){D15v = " V "; co65v = Red;    u3x34v = 0; d3x34v = 1;}            
     if (MaD15v > MaD1pr5v){D15v = " /\\ "; co65v = Blue; u3x34v = 1; d3x34v = 0;}
     if (MaD15v == MaD1pr5v){D15v = " 0 "; co65v = Green; u3x34v = 0; d3x34v = 0;}               
double  acv  = iAC(NULL, TF1, 0);
double  ac1v = iAC(NULL, TF1, 1);
double  ac2v = iAC(NULL, TF1, 2);
double  ac3v = iAC(NULL, TF1, 3);
//double  ac4 = iAO(NULL, 0, 4);             
string ach11v;
color acco11v;

if ((ac1v>ac2v && ac2v>ac3v && acv<0 && acv>ac1v) || (acv>ac1v && ac1v>ac2v && acv>0)) 
{ach11v = "/\\ " ; acco11v = Blue; u1acv = 3; d1acv = 0;} 
if ((ac1v<ac2v && ac2v<ac3v && acv>0 && acv<ac1v) || (acv<ac1v && ac1v<ac2v && acv<0)) 
{ach11v = "V " ; acco11v = Red; u1acv = 0; d1acv = 3;}
if ((((ac1v<ac2v || ac2v<ac3v) && acv<0 && acv>ac1v) || (acv>ac1v && ac1v<ac2v && acv>0))||
(((ac1v>ac2v || ac2v>ac3v) && acv>0 && acv<ac1v) || (acv<ac1v && ac1v>ac2v && acv<0)))
{ach11v = "0 " ; acco11v = Green; u1acv = 0; d1acv = 0;}    

double  ac03v  = iAC(NULL, TF3, 0);
double  ac13v = iAC(NULL, TF3, 1);
double  ac23v = iAC(NULL, TF3, 2);
double  ac33v = iAC(NULL, TF3, 3);
//double  ac4 = iAO(NULL, 0, 4);             
string ach13v;
color acco13v;

if ((ac13v>ac23v && ac23v>ac33v && ac03v<0 && ac03v>ac13v) || (ac03v>ac13v && ac13v>ac23v && ac03v>0)) 
{ach13v = "/\\ " ; acco13v = Blue; u3acv = 3; d3acv = 0;}     
if ((ac13v<ac23v && ac23v<ac33v && ac03v>0 && ac03v<ac13v) || (ac03v<ac13v && ac13v<ac23v && ac03v<0)) 
{ach13v = "V " ; acco13v = Red; u3acv = 0; d3acv = 3;}     
if ((((ac13v<ac23v || ac23v<ac33v) && ac03v<0 && ac03v>ac13v) || (ac03v>ac13v && ac13v<ac23v && ac03v>0))||
(((ac13v>ac23v || ac23v>ac33v) && ac03v>0 && ac03v<ac13v) || (ac03v<ac13v && ac13v>ac23v && ac03v<0)))
{ach13v = "0 " ; acco13v = Green; u3acv = 0; d3acv = 0;}
double  ac02v = iAC(NULL, TF2, 0);
double  ac12v = iAC(NULL, TF2, 1);
double  ac22v = iAC(NULL, TF2, 2);
double  ac32v = iAC(NULL, TF2, 3);
//double  ac4 = iAO(NULL, 0, 4);             
string ach12v;
color acco12v;

if ((ac12v>ac22v && ac22v>ac32v && ac02v<0 && ac02v>ac12v) || (ac02v>ac12v && ac12v>ac22v && ac02v>0)) 
{ach12v = "/\\ " ; acco12v = Blue; u2acv = 3; d2acv = 0;}     
if ((ac12v<ac22v && ac22v<ac32v && ac02v>0 && ac02v<ac12v) || (ac02v<ac12v && ac12v<ac22v && ac02v<0)) 
{ach12v = "V " ; acco12v = Red; u2acv = 0; d2acv = 3;}     
if ((((ac12v<ac22v || ac22v<ac32v) && ac02v<0 && ac02v>ac12v) || (ac02v>ac12v && ac12v<ac22v && ac02v>0))||
(((ac12v>ac22v || ac22v>ac32v) && ac02v>0 && ac02v<ac12v) || (ac02v<ac12v && ac12v>ac22v && ac02v<0)))
{ach12v = "0 " ; acco12v = Green; u2acv = 0; d2acv = 0;}

 double uitog1v = (u1x5v + u1x8v + u1x13v + u1x21v + u1x34v + u1acv) * 12.5;
  double uitog2v = (u2x5v + u2x8v + u2x13v + u2x21v + u2x34v + u2acv) * 12.5;
  double uitog3v = (u3x5v + u3x8v + u3x13v + u3x21v + u3x34v + u3acv) * 12.5;
  
  double ditog1v = (d1x5v + d1x8v + d1x13v + d1x21v + d1x34v + d1acv) * 12.5;
  double ditog2v = (d2x5v + d2x8v + d2x13v + d2x21v + d2x34v + d2acv) * 12.5;
  double ditog3v = (d3x5v + d3x8v + d3x13v + d3x21v + d3x34v + d3acv) * 12.5;
  
  string hr1v, hr2v, hr3v, hr4v, hr5v,hr6v;
  string dhr1v, dhr2v, dhr3v, dhr4v, dhr5v, dhr6v;
  if (uitog1v> ditog1v) {hr1v = "Arial Black"; dhr1v = "Arial";}
  if (uitog1v< ditog1v) {hr1v = "Arial"; dhr1v = "Arial Black";}
  if (uitog1v == ditog1v) {hr1v = "Arial"; dhr1v = "Arial";}
  
  if (uitog2v> ditog2v) {hr2v = "Arial Black"; dhr2v = "Arial";}
  if (uitog2v< ditog2v) {hr2v = "Arial"; dhr2v = "Arial Black";}
  if (uitog2v == ditog2v) {hr2v = "Arial"; dhr2v = "Arial";}
  
  if (uitog3v> ditog3v) {hr3v = "Arial Black"; dhr3v = "Arial";}
  if (uitog3v< ditog3v) {hr3v = "Arial"; dhr3v = "Arial Black";}
  if (uitog3v == ditog3v) {hr3v = "Arial"; dhr3v = "Arial";}
  
  if (uitog1v > 50 && uitog2v > 50 && uitog3v > 50)
  
  {if (English)txtv = "Looks Good For BUY";else txtv = "ÊÇ ÍÏæÏí ÈÑÇí ÎÑíÏ ãäÇÓÈ ÇÓÊ"; }
  else
  {if (English)txtv = "WAIT.(Danger!!!)";else txtv = "äÇãÓÇÚÏ .ãæÞÚíÊ ãäÇÓÈ äãíÈÇÔÏ";} 
  
  if (ditog1v > 50 && ditog2v > 50 && ditog3v > 50)
  {if (English)txtv = "Look Good For Sell";else txtv = "ÊÇÍÏæÏí ÈÑÇí ÝÑæÔ ãäÇÓÈ ÇÓÊ";}
  
  if (uitog1v >= 75 && uitog2v >= 75 && uitog3v >= 75)
  {if (English)txtv = "Good Buy";else txtv = "ãæÞÚíÊ ÎÑíÏ ãäÇÓÈ";}
  if (ditog1v >= 75 && ditog2v >= 75 && ditog3v >= 75)
  {if (English)txtv = "Good Sell";else txtv = "ãæÞÚíÊ ÝÑæÔ ãäÇÓÈ";}
  
  
if (tr=="Bullish"||tr=="ÕÚæÏí") return("%"+DoubleToStr(uitog1v,1));
if (tr=="Bearish"||tr=="äÒæáí") return("%"+DoubleToStr(ditog1v,1));

}

void CreateObjects(string no, color cl) {
  ObjectCreate(no, OBJ_RECTANGLE, 0, 0,0, 0,0);
  ObjectSet(no, OBJPROP_STYLE, STYLE_SOLID);
  ObjectSet(no, OBJPROP_COLOR, cl);
  ObjectSet(no, OBJPROP_BACK, false);
}


void DeleteObjects() {
  for (int i=0; i<NumberOfDays; i++) {
   
   ObjectDelete("SY"+i);
    ObjectDelete("AS"+i);
    
    ObjectDelete("EU"+i);
    ObjectDelete("LO"+i);
    ObjectDelete("US"+i);
  }
}

void DrawObjects(datetime dt, string no, string tb, string te) {
  datetime t1, t2;
  double   p1, p2;
  int      b1, b2;

  t1=StrToTime(TimeToStr(dt, TIME_DATE)+" "+tb);
  t2=StrToTime(TimeToStr(dt, TIME_DATE)+" "+te);
  if (t2<t1)t1=t1-1440*60;
  b1=iBarShift(NULL, 0, t1);
  b2=iBarShift(NULL, 0, t2);
  p1=High[iHighest(NULL, 0, MODE_HIGH, b1-b2, b2)];
  p2=Low [iLowest (NULL, 0, MODE_LOW , b1-b2, b2)];
  ObjectSet(no, OBJPROP_TIME1 , t1);
  ObjectSet(no, OBJPROP_PRICE1, p1);
  ObjectSet(no, OBJPROP_TIME2 , t2);
  ObjectSet(no, OBJPROP_PRICE2, p2);
}


datetime decDateTradeDay (datetime dt) {
  int ty=TimeYear(dt);
  int tm=TimeMonth(dt);
  int td=TimeDay(dt);
  int th=TimeHour(dt);
  int ti=TimeMinute(dt);

  td--;
  if (td==0) {
    tm--;
    if (tm==0) {
      ty--;
      tm=12;
    }
    if (tm==1 || tm==3 || tm==5 || tm==7 || tm==8 || tm==10 || tm==12) td=31;
    if (tm==2) if (MathMod(ty, 4)==0) td=29; else td=28;
    if (tm==4 || tm==6 || tm==9 || tm==11) td=30;
  }
  return(StrToTime(ty+"."+tm+"."+td+" "+th+":"+ti));
}
//+------------------------------------------------------------------+

string GetXmlFileName()
{
	return (Month() + "-" + Day() + "-" + Year() + "-" + Symbol() + Period() + "-" + "HamyarNews.xml");
}

void shownews()
{

 
	int 		newsIdx = 0;
	int 		nextNewsIdx = -1;
	int 		next;
	string 		myEvent;
	bool 		skip;
	datetime 	newsTime;
      
	// check to make sure we are connected, otherwise exit. Added by MN
	if (!IsConnected())
	{
		Print("HamyarNews Indicator is disabled because NO CONNECTION to Broker!");
		return(0);
	}
   
	// If we are not logging, then do not output debug statements either
	if (!EnableLogging)
		DebugLevel = 0;
				
	//commentStr = "";
	//NewsBox
	if (Newsbox_on)
	
	ObjectCreate("aNewsBox", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("aNewsBox", "g", 123, "Webdings");
   ObjectSet("aNewsBox", OBJPROP_CORNER, NewsCorner);
   ObjectSet("aNewsBox", OBJPROP_XDISTANCE, shiftx);
   ObjectSet("aNewsBox", OBJPROP_YDISTANCE, shifty);
   ObjectSet("aNewsBox", OBJPROP_COLOR, BoxColor);
   ObjectSet("aNewsBox", OBJPROP_BACK, false);
   
   
   ObjectCreate("bNewsBox2", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("bNewsBox2", "g", 120, "Webdings");
   ObjectSet("bNewsBox2", OBJPROP_CORNER, NewsCorner);
   ObjectSet("bNewsBox2", OBJPROP_XDISTANCE, shiftx+2);
   ObjectSet("bNewsBox2", OBJPROP_YDISTANCE, shifty+2);
   ObjectSet("bNewsBox2", OBJPROP_COLOR, BoxColor2);
   ObjectSet("bNewsBox2", OBJPROP_BACK, false);
   
   ObjectCreate("aNewsBoxb", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("aNewsBoxb", "g", 123, "Webdings");
   ObjectSet("aNewsBoxb", OBJPROP_CORNER, NewsCorner);
   ObjectSet("aNewsBoxb", OBJPROP_XDISTANCE, shiftx+150);
   ObjectSet("aNewsBoxb", OBJPROP_YDISTANCE, shifty);
   ObjectSet("aNewsBoxb", OBJPROP_COLOR, BoxColor);
   ObjectSet("aNewsBoxb", OBJPROP_BACK, false);
   
   
   ObjectCreate("bNewsBox2b", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("bNewsBox2b", "g", 120, "Webdings");
   ObjectSet("bNewsBox2b", OBJPROP_CORNER, NewsCorner);
   ObjectSet("bNewsBox2b", OBJPROP_XDISTANCE, shiftx+152);
   ObjectSet("bNewsBox2b", OBJPROP_YDISTANCE, shifty+2);
   ObjectSet("bNewsBox2b", OBJPROP_COLOR, BoxColor2);
   ObjectSet("bNewsBox2b", OBJPROP_BACK, false);
   
 /*  
   ObjectCreate("xAlarm_label", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("xAlarm_label", "Alarm 1 : "+ Alert1MinsBefore+"M", 9, "Arial");
   ObjectSet("xAlarm_label", OBJPROP_CORNER, NewsCorner);
   ObjectSet("xAlarm_label", OBJPROP_XDISTANCE, shiftx+10);
   ObjectSet("xAlarm_label", OBJPROP_YDISTANCE, shifty+140);
   ObjectSet("xAlarm_label", OBJPROP_COLOR, Gray);
   ObjectSet("xAlarm_label", OBJPROP_BACK, false);
   
 
   ObjectCreate("xAlarm_label2", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("xAlarm_label2", "Alarm 2 :  "+ Alert2MinsBefore+"M", 9, "Arial");
   ObjectSet("xAlarm_label2", OBJPROP_CORNER, NewsCorner);
   ObjectSet("xAlarm_label2", OBJPROP_XDISTANCE, shiftx+130);
   ObjectSet("xAlarm_label2", OBJPROP_YDISTANCE, shifty+140);
   ObjectSet("xAlarm_label2", OBJPROP_COLOR, Gray);
   ObjectSet("xAlarm_label2", OBJPROP_BACK, false);
   
  
   if (Alert1MinsBefore<1 && Alert2MinsBefore<1)
   {
   ObjectCreate("xAlarm_label4", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("xAlarm_label4", "Alarm :  "+ "OFF", 9, "Arial");
   ObjectSet("xAlarm_label4", OBJPROP_CORNER, NewsCorner);
   ObjectSet("xAlarm_label4", OBJPROP_XDISTANCE, shiftx+240);
   ObjectSet("xAlarm_label4", OBJPROP_YDISTANCE, shifty+140);
   ObjectSet("xAlarm_label4", OBJPROP_COLOR, FireBrick);
   ObjectSet("xAlarm_label4", OBJPROP_BACK, false);
   }
   
   if (Alert1MinsBefore>0&& Alert2MinsBefore>0)
   {
   ObjectCreate("xAlarm_label3", OBJ_LABEL, NewsWindow, 0, 0, 0, 0);
   ObjectSetText("xAlarm_label3", "Alarm :  "+ "ON", 9, "Arial");
   ObjectSet("xAlarm_label3", OBJPROP_CORNER, NewsCorner);
   ObjectSet("xAlarm_label3", OBJPROP_XDISTANCE, shiftx+240);
   ObjectSet("xAlarm_label3", OBJPROP_YDISTANCE, shifty+140);
   ObjectSet("xAlarm_label3", OBJPROP_COLOR, Green);
   ObjectSet("xAlarm_label3", OBJPROP_BACK, false);
   }
	//NewsBox
	*/
	
	// Added this section to check if the XML file already exists.  
	// If it does NOT, then we need to set a flag to go get it
	xmlFileName = GetXmlFileName();
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);

	// File does not exist if FileOpen return -1 or if GetLastError = ERR_CANNOT_OPEN_FILE (4103)
	if (xmlHandle >= 0)
	{
		// Since file exists, close what we just opened
		FileClose(xmlHandle);
		NeedToGetFile = false;
	}
	else	
		NeedToGetFile = true;

	
	//added by MN. Set this to false when using in another EA or Chart, so that the multiple 
	//instances of the indicator dont fight with each other
	if (AllowWebUpdates)
	{
		// New method: Use global variables so that when put on multiple charts, it 
		// will not update overly often; only first time and every 4 hours
		if (DebugLevel > 1)
			Print(GlobalVariableGet("LastUpdateTime") + " " + (TimeCurrent() - GlobalVariableGet("LastUpdateTime")));
			
  		if (NeedToGetFile || GlobalVariableCheck("LastUpdateTime") == false || 
  			(TimeCurrent() - GlobalVariableGet("LastUpdateTime")) > 14400)
		{
			if (DebugLevel > 1)
				Print("sUrl == ", sUrl);
		
			if (DebugLevel > 0)
				Print("Grabbing Web, url = ", sUrl);
	
			// THIS CALL WAS DONATED BY PAUL TO HELP FIX THE RESOURCE ERROR
			GrabWeb(sUrl, sData);

			if (DebugLevel > 0)
			{
				Print("Opening XML file...\n");
				Print(sData);
			}

			// Delete existing file
			FileDelete(xmlFileName);
			
			// Write the contents of the ForexFactory page to an .htm file
			// If it is still open from the above FileOpen call, close it.
			xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_WRITE);
			if (xmlHandle < 0)
			{
				if (DebugLevel > 0)
					Print("Can\'t open new xml file, the last error is ", GetLastError());
				return(false);
			}
			FileWriteString(xmlHandle, sData, StringLen(sData));
			FileClose(xmlHandle);

			if (DebugLevel > 0)
				Print("Wrote XML file...\n");

			// THIS BLOCK OF CODE DONATED BY WALLY TO FIX THE RESOURCE ERROR
			//--- Look for the end XML tag to ensure that a complete page was downloaded ---//
			end = StringFind(sData, "</weeklyevents>", 0);

			if (end <= 0)
			{
				Alert("HamyarNews Error - Web page download was not complete!");
				return(false);
			}
			else
			{
				// set global to time of last update
				GlobalVariableSet("LastUpdateTime", TimeCurrent());
			}
			
			//-------------------------------------------------------------------------------//
		}
	} //end of allow web updates

	// = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = =
	// Perform remaining checks once per minute
	if (!IsEA_Call && Minute() == PrevMinute)
		return (true);
	PrevMinute = Minute();
//	Print("FFCal NEW MINUTE...Refreshing News from XML file...");

	// Open the log file (will not open if logging is turned off)
	OpenLog("FFCal");

	// Init the buffer array to zero just in case
	ArrayInitialize(ExtMapBuffer0, 0);
	ArrayInitialize(ExtMapBuffer1, 0);
	
	// Open the XML file
	xmlHandle = FileOpen(xmlFileName, FILE_BIN|FILE_READ);
	if (xmlHandle < 0)
	{
		Print("Can\'t open xml file: ", xmlFileName, ".  The last error is ", GetLastError());
		return(false);
	}
	if (DebugLevel > 0)
		Print("XML file open must be okay");
	
	// Read in the whole XML file
	// Ave file length == ~7K, so 65536 should always read whole file
	sData = FileReadString(xmlHandle, 65536);	
   	if (StringLen(sData) < FileSize(xmlHandle))
	   sData = sData + FileReadString(xmlHandle, FileSize(xmlHandle));	
	
	// Because MT4 build 202 complained about too many files open and MT4 hung. Added by MN
	if (xmlHandle > 0)
		FileClose(xmlHandle);

	// Get the currency pair, and split it into the two countries
	string pair = Symbol();
	string cntry1 = StringSubstr(pair, 0, 3);
	string cntry2 = StringSubstr(pair, 3, 3);
	if (DebugLevel > 0)
		Print("cntry1 = ", cntry1, "    cntry2 = ", cntry2);
	
	if (DebugLevel > 0)
		Log("Weekly calendar for " + pair + "\n\n");

	// -------------------------------------------------
	// Parse the XML file looking for an event to report
	// -------------------------------------------------
	
	tmpMins = 10080;	// (a week)
	BoEvent = 0;

	while (true)
	{
		BoEvent = StringFind(sData, "<event>", BoEvent);
		if (BoEvent == -1)
			break;
			
		BoEvent += 7;	
		next = StringFind(sData, "</event>", BoEvent);
		if (next == -1)
			break;
	
		myEvent = StringSubstr(sData, BoEvent, next - BoEvent);
		BoEvent = next;
		
		begin = 0;
		skip = false;
		for (i=0; i < 7; i++)
		{
			mainData[newsIdx][i] = "";
			next = StringFind(myEvent, sTags[i], begin);
			
			// Within this event, if tag not found, then it must be missing; skip it
			if (next == -1)
				continue;
			else
			{
				// We must have found the sTag okay...
				begin = next + StringLen(sTags[i]);			// Advance past the start tag
				end = StringFind(myEvent, eTags[i], begin);	// Find start of end tag
				if (end > begin && end != -1)
				{
					// Get data between start and end tag
					mainData[newsIdx][i] = StringSubstr(myEvent, begin, end - begin);
				}
			}
		}
		
//		for (i=6; i >= 0; i--)
//			Print(sTags[i], "  =  ", mainData[newsIdx][i]);

		// = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =
		// Test against filters that define whether we want to 
		// skip this particular annoucement
		if (cntry1 != mainData[newsIdx][COUNTRY] && cntry2 != mainData[newsIdx][COUNTRY] &&
			(!ReportAllForUSD || mainData[newsIdx][COUNTRY] != "USD"))
			skip = true;

		if (!ShowHigh && mainData[newsIdx][IMPACT] == "High") 
			skip = true;
		if (!ShowMedium && mainData[newsIdx][IMPACT] == "Medium") 
			skip = true;
		if (!ShowLow && mainData[newsIdx][IMPACT] == "Low") 
			skip = true;
		if (!ShowSpeaks && (StringFind(mainData[newsIdx][TITLE], "speaks") != -1 || 
								StringFind(mainData[newsIdx][TITLE], "Speaks") != -1) ) 
			skip = true;
		if (mainData[newsIdx][TIME] == "All Day" || 
			mainData[newsIdx][TIME] == "Tentative" ||
			mainData[newsIdx][TIME] == "") 
			skip = true;
		// = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =   = - =
	   
		// If not skipping this event, then log it into the draw buffers
		if (!skip)
		{   
			// If we got this far then we need to calc the minutes until this event
			//
			// First, convert the announcement time to seconds (in GMT)
			newsTime = StrToTime(MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]));
			
			// Now calculate the minutes until this announcement (may be negative)
			minsTillNews = (newsTime - TimeGMT()) / 60;
			if (DebugLevel > 0)
			{
				Log("FOREX FACTORY\nTitle: " + mainData[newsIdx][TITLE] + "\n" + minsTillNews + "\n\n");
			}
					
			// This "if" section added by MN
			// If minsTillNews is zero, then it's the time our news is hit
			if ((minsTillNews == 0) && (LastTimeAlert1 != newsTime))
			{
				// draw the 1st news event onto the chart vertically so 
				// we have a visual record of when it occured
				DisplayVerticalNews(dispTitle[0], dispCountry[0], 0); 

				// If there is a 2nd simultaneous news event, 
				// display the 2nd news event
				if (dispMinutes[0] == dispMinutes[1])
					DisplayVerticalNews(dispTitle[1], dispCountry[1], 1); 
				
				// only draw once per announcement
				LastTimeAlert1 = newsTime;
			}

			// This "if" section added by MN
			// Back Draw old news onto the chart. Added by MN
			if (ShowVertNews && !IsEA_Call)  
			{
				// Back draw 1st news headline
				DisplayOldNews(mainData[newsIdx][TITLE], mainData[newsIdx][COUNTRY], 0, StrToTime(MakeDateTime(mainData[newsIdx][DATE], mainData[newsIdx][TIME]))); 
	
				//if there is a 2nd simultaneously occuring news headline, draw that onto the chart as well
				if (mainData[newsIdx][TIME] == mainData[newsIdx+1][TIME])
					DisplayOldNews(mainData[newsIdx+1][TITLE], mainData[newsIdx+1][COUNTRY], 1, 
						StrToTime(MakeDateTime(mainData[newsIdx+1][DATE], mainData[newsIdx+1][TIME]))); 
			}  
			
			// Keep track of the most recent news announcement.
			// Do that by saving each one until we get to the 
			// first annoucement that isn't in the past; i.e.
			// minsTillNews > 0.  Then, keep this one instead for
			// display, but only once the minutes until the next 
			// news is SMALLER than the minutes since the last.
//			Print("Mins till event: ", minsTillNews);
			if (minsTillNews < 0 || MathAbs(tmpMins) > minsTillNews)
			{
				idxOfNext = newsIdx;
				tmpMins	= minsTillNews;
			}
			
			Log("Weekly calendar for " + pair + "\n\n");
			if (DebugLevel > 0)
			{
				Log("FOREX FACTORY\nTitle: " + mainData[newsIdx][TITLE] + 
									"\nCountry: " + mainData[newsIdx][COUNTRY] + 
									"\nDate: " + mainData[newsIdx][DATE] + 
									"\nTime: " + mainData[newsIdx][TIME] + 
									"\nImpact: " + mainData[newsIdx][IMPACT] + 
									"\nForecast: " + mainData[newsIdx][FORECAST] + 
									"\nPrevious: " + mainData[newsIdx][PREVIOUS] + "\n\n");
			}
			
			// Do alert if user has enabled
			if (Alert1MinsBefore != -1 && minsTillNews == Alert1MinsBefore)
				Alert(Alert1MinsBefore, " minutes until news for ", pair, ": ", mainData[newsIdx][TITLE]);
			if (Alert2MinsBefore != -1 && minsTillNews == Alert2MinsBefore)
				Alert(Alert2MinsBefore, " minutes until news for ", pair, ": ", mainData[newsIdx][TITLE]);
				
			// Buffers are set up as so: 
			// ExtMapBuffer0 contains the time UNTIL each announcement (can be negative)
			// e.g. [0] = -372; [1] = 25; [2] = 450; [3] = 1768 (etc.)
			// ExtMapBuffer1[0] has the mintutes since the last annoucement.
			// ExtMapBuffer1[1] has the mintutes until the next annoucement.
			ExtMapBuffer0[newsIdx] = minsTillNews;
			newsIdx++;
		}
	}

	// Cycle through the events array and pick out the most recent 
	// past and the next coming event to put into ExtMapBuffer1. 
	// Put the corresponding impact for these two into ExtMapBuffer2.
	bool first = true;
	ExtMapBuffer1[0] = 99999;
	ExtMapBuffer1[1] = 99999;
	ExtMapBuffer2[0] = 0;
	ExtMapBuffer2[1] = 0;
	string outNews = "Minutes until news events for " + pair + " : ";
	for (i=0; i < newsIdx; i++)	
	{
		outNews = outNews + ExtMapBuffer0[i] + ", ";
		if (ExtMapBuffer0[i] >= 0 && first)
		{
			first = false;
			
			// Put the relevant info into the indicator buffers...

			// Minutes SINCE - - - - - - - - - - - - - - - - - - - - - - - - -
			// (does not apply if the first event of the week has not passed)
			if (i > 0)
			{
				ExtMapBuffer1[0] = MathAbs(ExtMapBuffer0[i-1]);
				ExtMapBuffer2[0] = ImpactToNumber(mainData[i-1][IMPACT]);
			}
			
			// Minutes UNTIL - - - - - - - - - - - - - - - - - - - - - - - - -
			// Check if past the last event.  
			if (ExtMapBuffer0[i] > 0 || (ExtMapBuffer0[i] == 0 && ExtMapBuffer0[i+1] > 0))
			{
				ExtMapBuffer1[1] = ExtMapBuffer0[i];
			}
			ExtMapBuffer2[1] = ImpactToNumber(mainData[i][IMPACT]);
		}
		
		// Also use this loop to set which information to display
		if (i == idxOfNext)
		{
			dispTitle[0]	= mainData[i][TITLE];
			dispCountry[0] 	= mainData[i][COUNTRY];
			dispImpact[0] 	= mainData[i][IMPACT];
			dispForecast[0] = mainData[i][FORECAST];
			dispPrevious[0] = mainData[i][PREVIOUS];
			dispMinutes[0] 	= ExtMapBuffer0[i];
		}
		
		if (i == idxOfNext + 1)
		{
			dispTitle[1]	= mainData[i][TITLE];
			dispCountry[1] 	= mainData[i][COUNTRY];
			dispImpact[1] 	= mainData[i][IMPACT];
			dispForecast[1] = mainData[i][FORECAST];
			dispPrevious[1] = mainData[i][PREVIOUS];
			dispMinutes[1] 	= ExtMapBuffer0[i];
		}
		

	}	
	// If we are past all news events, then neither one will have been 
	// set, so set the past event to the last (negative) minutes
	if (ExtMapBuffer1[0] == 0 && ExtMapBuffer1[1] == 0)
	{
		ExtMapBuffer1[0] = ExtMapBuffer0[i-1];
		ExtMapBuffer1[1] = 999999;

		// Ensures that we clean up so that we get old text 
		// left behind on old news annoumcents. Added by MN
		ObjectDelete("Impact");
		ObjectDelete("Previous"); 
		ObjectDelete("Forecast");

		ObjectDelete("Impact2");
		ObjectDelete("Previous2"); 
		ObjectDelete("Forecast2");
	}      

	
	// For debugging...Print the tines until news events, as a "Comment"
	if (DebugLevel > 0)
	{
		Print(outNews);
		Print("LastMins (ExtMapBuffer1[0]) = ", ExtMapBuffer1[0]);
		Print("NextMins (ExtMapBuffer1[1]) = ", ExtMapBuffer1[1]);
	}

	if (!IsEA_Call)
    	OutputToChart();

	if (logHandle > 0)
	{
		FileClose(logHandle);
		logHandle = -1;
	}
	
	return (0);	

}


void DisplayVerticalNews(string dispTitle, string dispCountry, int shift)
{    
	double	Pivot, Height = 0.0;
	
	// Calculate our pivot point to determine where to place the news text
	Pivot = (iHigh(NULL, 1440, 1) + 
			iLow(NULL, 1440, 1) + 
			iClose(NULL, 1440, 1)) / 3;  
   
	// If Open price is above the Pivot determine our height
	if (Open[0] > Pivot)
		Height = Low[iLowest(NULL,0,MODE_LOW,5,0)] - VertTxtShift*Point;  
	else 
		// Otherwise Open is below Pivot
		Height = High[iHighest(NULL,0,MODE_HIGH,5,0)] + VertTxtShift*Point;          

	if (shift == 0)
	{
		// Draw a vertical line at the time of the news if it hasnt already been drawn
		if (ObjectFind("vLine" + Time[0]) == -1)
		{
			ObjectCreate("vLine" + Time[0], OBJ_TREND, 0, Time[0], 0, Time[0], High[0]); 	// experimental
			ObjectSet("vLine" + Time[0], OBJPROP_COLOR, VertLineColor);
			ObjectSet("vLine" + Time[0], OBJPROP_STYLE, STYLE_DOT);
			
			// Put object in the background behind any other object on the chart
			ObjectSet("vLine" + Time[0], OBJPROP_BACK, true);	
		}

		// Place our news if it hasnt already been placed on our chart
		if (ObjectFind("Headline" + Time[0]) == -1)
		{  
			// For x value use Time[0], for y value find the lowest 
			// bar within the last 10 bars, subtract by VertTxtShift 
			// and used that as our y coordinate
			ObjectCreate("Headline" + Time[0], OBJ_TEXT, 0, 
						Time[0] - VertLeftLineShift, Height); 
			
			// Rotate the text 90 degrees
			ObjectSet("Headline" + Time[0], OBJPROP_ANGLE, 90);
			
			ObjectSetText("Headline" + Time[0], 
							"News: " + dispCountry + " " + dispTitle, 
							VertTxtSize, "Arial", VertTxtColor);
		}
	}
	// Draw second news headline
	else 
	{
		//place our news if it hasnt already been placed on our chart
		if (ObjectFind("Headline" + Time[0]+"s") == -1)
		{
			// For x value use Time[0], for y value find the lowest 
			// bar within the last 10 bars, subtract by VertTxtShift 
			// and used that as our y coordinate
			ObjectCreate("Headline" + Time[0] + "s", OBJ_TEXT, 0, 
						Time[0] + VertRightLineShift, Height); 
			
			// Rotate the text 90 degrees
			ObjectSet("Headline" + Time[0] + "s", OBJPROP_ANGLE, 90);
			
			ObjectSetText("Headline" + Time[0] + "s", 
							"News: " + dispCountry + " " + dispTitle, 
							VertTxtSize, "Arial", VertTxtColor);
		}
	}

	//force a redraw of our chart
	WindowRedraw();

	return(0);
}

// Back Draw Old news veritically on the Chart so that we 
// have a visual reference of when it did occur. Added by MN 
void DisplayOldNews(string dispTitle, string dispCountry, int shift, datetime TheTime)
{     
	int   	BarShift;
	double 	Pivot;
	double	Height = 0.0;

	// We have TheTime, now we need the shift so we can 
	// access this Bar's High/Low/Close information
	BarShift = iBarShift(NULL, 0, TheTime);   

	// Calculate our pivot point to determine where to place the news text
	Pivot = (iHigh(NULL, 1440, BarShift) + 
			iLow(NULL, 1440, BarShift) + 
			iClose(NULL, 1440, BarShift)) / 3;

	// If open price is above the Pivot, determine our height
	if (Open[BarShift] > Pivot)
		Height = Low[iLowest(NULL, 0, MODE_LOW, 5, BarShift)] - VertTxtShift*Point;
		
	// Otherwise Open is below Pivot
	else 
		Height = High[iHighest(NULL, 0, MODE_HIGH, 5, BarShift)] + VertTxtShift*Point;

	//Print("Title recieved : " + dispTitle + " Country Recieved: " + dispCountry + " Date and time Recieved: " + TheTime);

	// We only want to vertically draw the news if it hasnt occured yet
	if (TheTime < Time[0])
	{  
		// Draw the first news headline 
		if (shift == 0)
		{
			// Draw a vertical line at the time of the 
			// news if it hasnt already been drawn
			if (ObjectFind("vLine" + TheTime) == -1)
			{
				ObjectCreate("vLine" + TheTime, OBJ_TREND, 0, TheTime, 0, TheTime, High[0]); //experimental
				ObjectSet("vLine" + TheTime, OBJPROP_COLOR, VertLineColor);
				ObjectSet("vLine" + TheTime, OBJPROP_STYLE, STYLE_DOT);
				   
				// put object in the background behind any other object on the chart
				ObjectSet("vLine" + TheTime, OBJPROP_BACK, true);
			}
  
			// Place our news if it hasnt already been placed on our chart
			if (ObjectFind("Headline" + TheTime) == -1)
			{
				// For x value use Time[0], for y value find the lowest bar within the last 10 bars, subtract by VertTxtShift and used that as our y coordinate
				ObjectCreate("Headline" + TheTime, OBJ_TEXT, 0, TheTime - VertLeftLineShift, Height); 
				
				// rotate the text 90 degrees
				ObjectSet("Headline" + TheTime, OBJPROP_ANGLE, 90);
				ObjectSetText("Headline" + TheTime, "News: " + dispCountry + " " + dispTitle, 
							VertTxtSize, "Arial", VertTxtColor);
			}            
		}
		
		// Draw second news headline
		else 
		{
			//place our news if it hasnt already been placed on our chart
			if (ObjectFind("Headline" + TheTime + "s") == -1)
			{
				// For x value use Time[0], for y value find the lowest bar within the 
				// last 10 bars, subtract by VertTxtShift and used that as our y coordinate
				ObjectCreate("Headline" + TheTime + "s", OBJ_TEXT, 0, 
								TheTime + VertRightLineShift, Height); 
				
				// Rotate the text 90 degrees
				ObjectSet("Headline" + TheTime + "s", OBJPROP_ANGLE, 90);
				ObjectSetText("Headline" + TheTime + "s", "News: " + dispCountry + " " + dispTitle, 
								VertTxtSize, "Arial", VertTxtColor);
			}   
		} // end of "if shift)
	} // end of (TheTime < Time[0])
        
	// Force a redraw of our chart
	WindowRedraw();

	return(0);
}




double ImpactToNumber(string impact)
{
	if (impact == "High")
		return (3);
	if (impact == "Medium")
		return (2);
	if (impact == "Low")
		return (1);
	else
		return (0);
}
   
string MakeDateTime(string strDate, string strTime)
{
	// Print("Converting Forex Factory Time into Metatrader time..."); //added by MN
	// Converts forexfactory time & date into yyyy.mm.dd hh:mm
	int n1stDash = StringFind(strDate, "-");
	int n2ndDash = StringFind(strDate, "-", n1stDash+1);

	string strMonth = StringSubstr(strDate, 0, 2);
	string strDay = StringSubstr(strDate, 3, 2);
	string strYear = StringSubstr(strDate, 6, 4); 
//	strYear = "20" + strYear;
	
	int nTimeColonPos = StringFind(strTime, ":");
	string strHour = StringSubstr(strTime, 0, nTimeColonPos);
	string strMinute = StringSubstr(strTime, nTimeColonPos+1, 2);
	string strAM_PM = StringSubstr(strTime, StringLen(strTime)-2);

	int nHour24 = StrToInteger(strHour);
	if (strAM_PM == "pm" || strAM_PM == "PM" && nHour24 != 12)
	{
		nHour24 += 12;
	}
	if (strAM_PM == "am" || strAM_PM == "AM" && nHour24 == 12)
	{
		nHour24 = 0;
	}
 	string strHourPad = "";
	if (nHour24 < 10) 
		strHourPad = "0";

	return(StringConcatenate(strYear, ".", strMonth, ".", strDay, " ", strHourPad, nHour24, ":", strMinute));
}


//=================================================================================================
//=================================================================================================
//====================================   GrabWeb Functions   ======================================
//=================================================================================================
//=================================================================================================
// Main Webscraping function
// ~~~~~~~~~~~~~~~~~~~~~~~~~
// bool GrabWeb(string strUrl, string& strWebPage)
// returns the text of any webpage. Returns false on timeout or other error
// 
// Parsing functions
// ~~~~~~~~~~~~~~~~~
// string GetData(string strWebPage, int nStart, string strLeftTag, string strRightTag, int& nPos)
// obtains the text between two tags found after nStart, and sets nPos to the end of the second tag
//
// void Goto(string strWebPage, int nStart, string strTag, int& nPos)
// Sets nPos to the end of the first tag found after nStart 

bool bWinInetDebug = false;

int hSession_IEType;
int hSession_Direct;
int Internet_Open_Type_Preconfig = 0;
int Internet_Open_Type_Direct = 1;
int Internet_Open_Type_Proxy = 3;
int Buffer_LEN = 80;

#import "wininet.dll"

#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache. 
#define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.

int InternetOpenA(
	string 	sAgent,
	int		lAccessType,
	string 	sProxyName="",
	string 	sProxyBypass="",
	int 	lFlags=0
);

int InternetOpenUrlA(
	int 	hInternetSession,
	string 	sUrl, 
	string 	sHeaders="",
	int 	lHeadersLength=0,
	int 	lFlags=0,
	int 	lContext=0 
);

int InternetReadFile(
	int 	hFile,
	string 	sBuffer,
	int 	lNumBytesToRead,
	int& 	lNumberOfBytesRead[]
);

int InternetCloseHandle(
	int 	hInet
);
#import


int hSession(bool Direct)
{
	string InternetAgent;
	if (hSession_IEType == 0)
	{
		InternetAgent = "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)";
		hSession_IEType = InternetOpenA(InternetAgent, Internet_Open_Type_Preconfig, "0", "0", 0);
		hSession_Direct = InternetOpenA(InternetAgent, Internet_Open_Type_Direct, "0", "0", 0);
	}
	if (Direct) 
	{ 
		return(hSession_Direct); 
	}
	else 
	{
		return(hSession_IEType); 
	}
}


bool GrabWeb(string strUrl, string& strWebPage)
{
	int 	hInternet;
	int		iResult;
	int 	lReturn[]	= {1};
	string 	sBuffer		= "                                                                                                                                                                                                                                                               ";	// 255 spaces
	int 	bytes;
	
	hInternet = InternetOpenUrlA(hSession(FALSE), strUrl, "0", 0, 
								INTERNET_FLAG_NO_CACHE_WRITE | 
								INTERNET_FLAG_PRAGMA_NOCACHE | 
								INTERNET_FLAG_RELOAD, 0);
								
	if (bWinInetDebug) 
		Log("hInternet: " + hInternet);   
	if (hInternet == 0) 
		return(false);

	Print("Reading URL: " + strUrl);	   //added by MN	
	iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
	
	if (bWinInetDebug) 
		Log("iResult: " + iResult);
	if (bWinInetDebug) 
		Log("lReturn: " + lReturn[0]);
	if (bWinInetDebug) 
		Log("iResult: " + iResult);
	if (bWinInetDebug) 
		Log("sBuffer: " +  sBuffer);
	if (iResult == 0) 
		return(false);
	bytes = lReturn[0];

	strWebPage = StringSubstr(sBuffer, 0, lReturn[0]);
	
	// If there's more data then keep reading it into the buffer
	while (lReturn[0] != 0)
	{
		iResult = InternetReadFile(hInternet, sBuffer, Buffer_LEN, lReturn);
		if (lReturn[0]==0) 
			break;
		bytes = bytes + lReturn[0];
		strWebPage = strWebPage + StringSubstr(sBuffer, 0, lReturn[0]);
	}

	Print("Closing URL web connection");   //added by MN
	iResult = InternetCloseHandle(hInternet);
	if (iResult == 0) 
		return(false);
		
	return(true);
}



//=================================================================================================
//=================================================================================================
//===================================   LogUtils Functions   ======================================
//=================================================================================================
//=================================================================================================

void OpenLog(string strName)
{
	if (!EnableLogging) 
		return;

	if (logHandle <= 0)
	{
		string strMonthPad = "";
 	 	string strDayPad = "";
  		if (Month() < 10) 
  			strMonthPad = "0";
  		if (Day() < 10) 
  			strDayPad = "0";
  			
  		string strFilename = StringConcatenate(strName, "_", Year(), strMonthPad, Month(), strDayPad, Day(), "_log.txt");
  		
		logHandle = FileOpen(strFilename,FILE_CSV|FILE_READ|FILE_WRITE);
		Print("logHandle =================================== ", logHandle);
	}
	if (logHandle > 0)
	{
		FileFlush(logHandle);
		FileSeek(logHandle, 0, SEEK_END);
	}
}


void Log(string msg)
{
	if (!EnableLogging) 
		return;
		
	if (logHandle <= 0) 
		return;
		
	msg = TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES|TIME_SECONDS) + " " + msg;
	FileWrite(logHandle,msg);
}

//=================================================================================================
//=================================================================================================
//===================================   Timezone Functions   ======================================
//=================================================================================================
//=================================================================================================


#import "kernel32.dll"
int  GetTimeZoneInformation(int& TZInfoArray[]);
#import

#define TIME_ZONE_ID_UNKNOWN   0
#define TIME_ZONE_ID_STANDARD  1
#define TIME_ZONE_ID_DAYLIGHT  2

int TZInfoArray[43];	

datetime TimeGMT() 
{
	int DST = GetTimeZoneInformation(TZInfoArray);
	if (DST == 1)
		DST = 3600;
	else 
		DST = 0;

	return( TimeLocal() + DST + (OffsetHours * 3600) + (TZInfoArray[0] + TZInfoArray[42]) * 60 );
}


//=================================================================================================
//=================================================================================================
//=================================   END IMPORTED FUNCTIONS  =====================================
//=================================================================================================

//=================================================================================================
void OutputToChart()
{
	// Added by Robert for using TxtSize and TxtColor for easier reading
	int curY = 12;
	int Days, Hours, Mins; // to display time in days, hours, minutes
	string TimeStr;
	
	if (ObjectFind("Sponsor") == -1)
		ObjectCreate("Sponsor", OBJ_LABEL, NewsWindow, 0, 0);
	ObjectSetText("Sponsor", commentStr, 8, "Arial Bold", Gray);
	ObjectSet("Sponsor", OBJPROP_CORNER, NewsCorner);
	ObjectSet("Sponsor", OBJPROP_XDISTANCE, 10);
	ObjectSet("Sponsor", OBJPROP_YDISTANCE, 6);       
	
	// If the time is 0 or negative, we want to say 
	// "xxx mins SINCE ... news event", else say "UNTIL ... news event"
	string 	sinceUntil = "until ";
	int 	dispMins = dispMinutes[0];
	if (dispMinutes[0] <= 0)
	{
		sinceUntil = "since ";
		dispMins *= -1;
	}
	curY = curY + TxtSize + 4;
	
	// added the following to show hours and days for longer durations
	// this could be enhanced to suppress 0 hours and 0 minutes
	if (dispMins == 999999)
	{
		TimeStr = " (No more events this week)";
	}
	else if (dispMins < 60)
	{
		TimeStr = dispMins + " mins ";
	}
	else // time is 60 minutes or more
	{
		Hours = MathRound(dispMins / 60);
		Mins = dispMins % 60;
		if (Hours < 24) // less than a day: show hours and minutes
		{
			TimeStr = Hours + " hrs " + Mins + " mins ";
		}
		else  // days, hours, and minutes
		{
			Days = MathRound(Hours / 24);
			Hours = Hours % 24;
			TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
		}
	}
	
	if (ObjectFind("Minutes") == -1)
		ObjectCreate("Minutes", OBJ_LABEL, NewsWindow, 0, 0);

	if (dispMins == 999999)
		ObjectSetText("Minutes", TimeStr, TxtSize, "Arial Bold", TxtColorNews);
	else
		ObjectSetText("Minutes", TimeStr + sinceUntil + dispCountry[0] + ": " + dispTitle[0], TxtSize, "Arial Bold", TxtColorNews);

	ObjectSet("Minutes", OBJPROP_CORNER, NewsCorner);
	ObjectSet("Minutes", OBJPROP_XDISTANCE, 10);
	ObjectSet("Minutes", OBJPROP_YDISTANCE, curY);

	curY = curY + TxtSize + 4;
	if (ObjectFind("Impact") == -1)
		ObjectCreate("Impact", OBJ_LABEL, NewsWindow, 0, 0);
	ObjectSetText("Impact", "Impact: " + dispImpact[0], TxtSize, "Arial Bold", TxtColorImpact);
	ObjectSet("Impact", OBJPROP_CORNER, NewsCorner);
	ObjectSet("Impact", OBJPROP_XDISTANCE, 10);
	ObjectSet("Impact", OBJPROP_YDISTANCE, curY);

	if (dispPrevious[0] != "")
	{
		curY = curY + TxtSize + 4;
		if (ObjectFind("Previous") == -1)
			ObjectCreate("Previous", OBJ_LABEL, NewsWindow, 0, 0);
		ObjectSetText("Previous", "Previous: " + dispPrevious[0], TxtSize, "Arial Bold", TxtColorPrevious);
		ObjectSet("Previous", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Previous", OBJPROP_XDISTANCE, 10);
		ObjectSet("Previous", OBJPROP_YDISTANCE, curY);
	}
	
	if (dispForecast[0] != "")
	{
		curY = curY + TxtSize + 4;
		if (ObjectFind("Forecast") == -1)
			ObjectCreate("Forecast", OBJ_LABEL, NewsWindow, 0, 0);
		ObjectSetText("Forecast", "Forecast: " + dispForecast[0], TxtSize, "Arial Bold", TxtColorForecast);
		ObjectSet("Forecast", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Forecast", OBJPROP_XDISTANCE, 10);
		ObjectSet("Forecast", OBJPROP_YDISTANCE, curY); 
	}
	
	
	
	///////////////////////////////////////////////////////////////////////////
	// Do second news event
	if (ShowNextTwoEvents && dispTitle[1] != "")
	{
		sinceUntil = "until ";
		dispMins = dispMinutes[1];
		if (dispMinutes[1] <= 0)
		{
			sinceUntil = "since ";
			dispMins *= -1;
		}

		curY = curY + TxtSize + 20;

		// added the following to show hours and days for longer durations
		// this could be enhanced to suppress 0 hours and 0 minutes
		if (dispMins == 999999)
		{
			TimeStr = " (No more events this week)";
		}
		else if (dispMins < 60)
		{
			TimeStr = dispMins + " mins ";
		}
		else // time is 60 minutes or more
		{
			Hours = MathRound(dispMins / 60);
			Mins = dispMins % 60;
			if (Hours < 24) // less than a day: show hours and minutes 
			{
				TimeStr = Hours + " hrs " + Mins + " mins ";
			}
			else // days, hours, and minutes
			{
				Days = MathRound(Hours / 24);
				Hours = Hours % 24;
				TimeStr = Days + " days " + Hours + " hrs " + Mins + " mins ";
			}
		}
		if (ObjectFind("Minutes2") == -1)
			ObjectCreate("Minutes2", OBJ_LABEL, NewsWindow, 0, 0);

		if (dispMins == 999999)
			ObjectSetText("Minutes", TimeStr, TxtSize, "Arial Bold", TxtColorNews);
		else
			ObjectSetText("Minutes2", TimeStr + "until " + dispCountry[1] + ": " + dispTitle[1], TxtSize, "Arial Bold", TxtColorNews);

		ObjectSet("Minutes2", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Minutes2", OBJPROP_XDISTANCE, 10);
		ObjectSet("Minutes2", OBJPROP_YDISTANCE, curY);

		curY = curY + TxtSize + 4;
		if (ObjectFind("Impact2") == -1)
			ObjectCreate("Impact2", OBJ_LABEL, NewsWindow, 0, 0);
		ObjectSetText("Impact2", "Impact: " + dispImpact[1], TxtSize, "Arial Bold", TxtColorImpact);
		ObjectSet("Impact2", OBJPROP_CORNER, NewsCorner);
		ObjectSet("Impact2", OBJPROP_XDISTANCE, 10);
		ObjectSet("Impact2", OBJPROP_YDISTANCE, curY);

		if (dispPrevious[1] != "")
		{
			curY = curY + TxtSize + 4;
			if (ObjectFind("Previous2") == -1)
				ObjectCreate("Previous2", OBJ_LABEL, NewsWindow, 0, 0);
			ObjectSetText("Previous2", "Previous: " + dispPrevious[1], TxtSize, "Arial Bold", TxtColorPrevious);
			ObjectSet("Previous2", OBJPROP_CORNER, NewsCorner);
			ObjectSet("Previous2", OBJPROP_XDISTANCE, 10);
			ObjectSet("Previous2", OBJPROP_YDISTANCE, curY);
		}
		
		if (dispForecast[1] != "")
		{
			curY = curY + TxtSize + 4;
			if (ObjectFind("Forecast2") == -1)
				ObjectCreate("Forecast2", OBJ_LABEL, NewsWindow, 0, 0);
			ObjectSetText("Forecast2", "Forecast: " + dispForecast[1], TxtSize, "Arial Bold", TxtColorForecast);
			ObjectSet("Forecast2", OBJPROP_CORNER, NewsCorner);
			ObjectSet("Forecast2", OBJPROP_XDISTANCE, 10);
			ObjectSet("Forecast2", OBJPROP_YDISTANCE, curY); 
		}
	}
	
	return (0);
}

