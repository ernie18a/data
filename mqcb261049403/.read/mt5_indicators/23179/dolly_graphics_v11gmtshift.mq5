//+------------------------------------------------------------------+
//|                                  Dolly_Graphics_v11-GMTShift.mq5 |
//|                      Copyright ꧂ ㈀　　㘀Ⰰ 䴀攀琀愀儀甀漀琀攀猀 匀漀昀琀眀愀爀攀 䌀漀爀瀀⸀ 簀ഀ਀⼀⼀簀                                        栀琀琀瀀㨀⼀⼀眀眀眀⸀洀攀琀愀焀甀漀琀攀猀⸀渀攀琀 簀ഀ਀⼀⼀⬀ⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀⴀ⬀ഀ਀⌀瀀爀漀瀀攀爀琀礀 挀漀瀀礀爀椀最栀琀 ∀䌀漀瀀礀爀椀最栀琀 숀© 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//+------------------------------------------------------------------+
//|                                         Dolly (the famous sheep) |
//|               original indicator is called valasholic13 v2.5.mq4 |
//|                                                                  |
//|                  and the original author is valasholic@yahoo.com |
//|                                                                  |         
//|                        mods and stuff by Linuxser for Forex-TSD  |
//|                      (there is a lot of usefull code inside here)|
//|Credits: hulahula (traslation from original indonesian language)  |
//|ign... in collaboration with Linuxser (with mods and improvments  |
//+------------------------------------------------------------------+
/*
Thanks to the above coders for all their work on the original Dolly 

Dolly Graphics 4: by cja
   - Comments restored to original figures but different layout, kept simple thanks to FxNorth for advise
   - Graphics code cleaned up now can be run on any colour background
   - Pivot points altered to short LINES and Labels can be shifted and LINES extended
   - Pivot M Levels added and Labels can be shifted and LINES extended
   - Dolly Sell Buy Target Labels can be shifted
   - Daily Average Range added above & below Dolly Levels and DAR Labels can be shifted 
Dolly Graphics 5   
   - Dolly coloured panels & Daily Average Range can now be either panels or lines or a combo of both 
   - Daily Average Panels can now be turned on/off  
   - Dolly trading Comments reset to original layout with larger type & can now be turned on/off
   - Pivot points and M pivot levels can now be selected individually
   - Added in Back TEST simply set to # of days and scroll back to the 1st graphic in the line
Dolly Graphics 6
   - Central Pivot _Point and Main Pivots now automatically show in BackTEST if Pivots on.
Dolly Graphics 8
   - Fib Levels added with option to take data back to previous days, Fib Levels on/off & TEXT on/off, 
   - move Fib TEXT & Extend line length if required.
   - Revised code and removed excess objects to increase speed. 
   - Fib Display able to be Short (Cover only the Graphics) or long extend to previous Day or more.
   - Adjustment of Dolly & Daily Average colours in inputs
   - Adjustment of BUY/SELL Levels in inputs 
   - Daily Average labels delete when Daily Graphics are removed.
Dolly Graphics 9
   - Extra Fib levels added to extend range if previous day was Range Bound.
   - Target 2 BUY & SELL have altered the code for the take profit so the Graphics now match the Text 
   - & when the level figure is altered the Text now alters to reflect the change, the old code was target 1 plus 
   - or minus 10. 
Dolly Graphics 10
   - NONE of the ORIGINAL CODE is now being used
   - Rewrote the original Dolly Code as I think that was where the REFRESH UPDATE issue problem existed
   - Rewrote the Pivots & M Pivot levels to speed up the indicator.
   - All Pivots now Backtest if Pivots & M Pivots turned on
   - Added a daily High/Low that is turned off by default - when on this feature will Backtest. 
   - Added Daily OPEN line Default is off, useful for the days that price starts above or below the Targets
   - can be used as a dynamic Pivot.         
Dolly Graphics #10 - by hymns
   - Add Daily Change Value
   - Tweak for using Open Graphics   
Fixed TimeShift - by FiFtHeLeMeNt
   - Fixed Pivots and added GMTshift , but backtest can not be used anymore , I think accurate data for today trade is more important than having backtest feature   
   - Fixed FiboLines and Graphics to be compatible with GMTshift
   - Fixed some bugs causing errors
Dolly Graphics #11 - by cja & thanks to FiFtHeLeMeNt for the GMT shift code
   - Added a pop up window alert when price approaches the Dolly levels 
   - Added an Auto Signals feature which removes the Comments and replaces them with an Auto ObjectsDeleteAll(0,-1,OBJ_TEXT); signal system       
*/
#property copyright ""
#property link      " Dolly Graphics cja"
//----
#property indicator_chart_window
#define IND_NAME "Dolly Graphics #11 GMT Shift"

//---- количество индикаторных буферов
#property indicator_buffers 0 
//---- не использовано всего одно графических построений
#property indicator_plots   0
//----
input int GMTshift=0;
input bool Using_OpenGraphics=true;
input bool Dolly_GRAPHICS=true;
input bool Alert_ON=false;
input bool Auto_Signals=true;
input bool Show_DollyCOMMENTS=true;
input color BUY_Color_2=C'0,0,150';
input color BUY_Color_1=C'0,0,100';
input color SELL_Color_1=C'120,0,0';
input color SELL_Color_2=C'180,0,0';
input int BUY_Target_2 =50;
input int BUY_Target_1 =40;
input int BUY_Area =20;
input int SELL_Area =20;
input int SELL_Target_1 =40;
input int SELL_Target_2 =50;
input int SHIFT_DailyText=0;
//----
input bool Show_DailyAverageGRAPHICS=true;
input bool Daily_AverageGRAPHICS=true;
input color DAILY_Av_UP_Color_150=C'0,110,255';
input color DAILY_Av_UP_Color_125=C'0,70,255';
input color DAILY_Av_UP_Color_100=C'20,20,255';
input color DAILY_Av_UP_Color_75=C'0,0,210';
input color DAILY_Av_DN_Color_75=C'220,0,0';
input color DAILY_Av_DN_Color_100=C'255,0,10';
input color DAILY_Av_DN_Color_125=C'255,70,0';
input color DAILY_Av_DN_Color_150=C'255,110,0';
input int SHIFT_DailyAverageText=28;
//----
input bool Show_PivotLines=false;
input bool Show_M_PivotLines=false;
input int SHIFT_Pivot_PointText=0;
input int Pivot_Point_ExtendLINE=0;
//----
input bool Show_FibLines=false;
input bool Show_EXTRAFibLines=false;
input int SHIFT_FibText=65;
input int FIB_ExtendDISPLAY=1;
//----
input bool Show_Daily_HI_LOW=false;
input int SHIFT_HI_LOW_TEXT=50;
//----
input bool Show_Daily_OPEN=false;
input int SHIFT_Daily_OPEN_TEXT=0;
//Daily OPEN
#define DO "DO"
//Daily HI/LOW
#define DHI "DHI"
#define DLO "DLO"
#define DDHI "DDHI"
#define DDLO "DDLO"
//Dolly Levels
#define DollyBUY3 "DollyBUY3"
#define DollyBUY2 "DollyBUY2"
#define DollyBUY1 "DollyBUY1"
#define DollySELL1 "DollySELL1"
#define DollySELL2 "DollySELL2"
#define DollySELL3 "DollySELL3"
//Daily Average Levels
#define AvBUY150 "AvBUY150"
#define AvBUY125 "AvBUY125"
#define AvBUY100 "AvBUY100"
#define AvBUY75 "AvBUY75"
#define AvSELL75 "AvSELL75"
#define AvSELL100 "AvSELL100"
#define AvSELL125 "AvSELL125"
#define AvSELL150 "AvSELL150"
//Pivot Levels
#define P1 "P1"
#define PP1 "PP1"
#define RR3 "RR3"
#define RR2 "RR2"
#define RR1 "RR1"
#define SS1 "SS1"
#define SS2 "SS2"
#define SS3 "SS3"
//----
#define MM1 "MM1"
#define MM2 "MM2"
#define MM3 "MM3"
#define MM4 "MM4"
#define MM5 "MM5"
#define MM0 "MM0"
//----
#define PPP1 "PPP1"
#define RRR3 "RRR3"
#define RRR2 "RRR2"
#define RRR1 "RRR1"
#define SSS1 "SSS1"
#define SSS2 "SSS2"
#define SSS3 "SSS3"
//FIB Levels
#define FibP100 "FibP100"
#define FibP618 "FibP618"
#define FibP50 "FibP50"
#define FibP382 "FibP382"
#define Fib100 "Fib100"
#define Fib764 "Fib764"
#define Fib618 "Fib618"
#define Fib50 "Fib50"
#define Fib382 "Fib382"
#define Fib236 "Fib236"
#define Fib0 "Fib0"
#define FibM100 "FibM100"
#define FibM618 "FibM618"
#define FibM50 "FibM50"
#define FibM382 "FibM382"
#define FibP236 "FibP236"
#define FibP764 "FibP764"
#define FibM236 "FibM236"
#define FibM764 "FibM764"
#define FibM150 "FibM150"
#define FibP150 "FibP150"
#define FibM200 "FibM200"
#define FibP200 "FibP200"
#define FibM250 "FibM250"
#define FibP250 "FibP250"
#define FibM300 "FibM300"
#define FibP300 "FibP300"
//----
double Bid,Ask;
double day_high;
double day_low;
double yesterday_open;
double today_open;
double cur_day;
double prev_day;
double yesterday_high=0;
double yesterday_low=0;
double yesterday_close=0;
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,-1,OBJ_TEXT);
   ObjectsDeleteAll(0,-1,OBJ_LABEL);
   ObjectsDeleteAll(0,-1,OBJ_RECTANGLE);
   ObjectsDeleteAll(0,-1,OBJ_TRENDBYANGLE);
   ObjectDelete(0,"Pivot");
   ObjectDelete(0,"Open");
   ObjectDelete(0,"Dolly");
   ObjectDelete(0,"Dolly1");  ObjectDelete(0,"Dolly2"); ObjectDelete(0,"Dolly3"); ObjectDelete(0,"Dolly4");
   ObjectDelete(0,"Dolly5");  ObjectDelete(0,"Dolly6"); ObjectDelete(0,"Dolly7"); ObjectDelete(0,"Dolly8");
   ObjectDelete(0,"Dolly9");  ObjectDelete(0,"Dolly10"); ObjectDelete(0,"Dolly11"); ObjectDelete(0,"Dolly12");
   ObjectDelete(0,"Dolly13"); ObjectDelete(0,"Dolly14"); ObjectDelete(0,"Dolly15"); ObjectDelete(0,"Dolly16");
   ObjectDelete(0,"Dolly17"); ObjectDelete(0,"Dolly18"); ObjectDelete(0,"Dolly19"); ObjectDelete(0,"Dolly20");
   ObjectDelete(0,"Dolly21"); ObjectDelete(0,"Dolly22"); ObjectDelete(0,"Dolly23"); ObjectDelete(0,"Dolly24");
   ObjectDelete(0,"Dolly25"); ObjectDelete(0,"Dolly26"); ObjectDelete(0,"Dolly27"); ObjectDelete(0,"Dolly28");
   ObjectDelete(0,"Dolly29"); ObjectDelete(0,"Dolly30"); ObjectDelete(0,"Dolly31"); ObjectDelete(0,"Dolly32");
   ObjectDelete(0,"Dolly33"); ObjectDelete(0,"Dolly34"); ObjectDelete(0,"Dolly35"); ObjectDelete(0,"Dolly36");
   ObjectDelete(0,"Dolly37"); ObjectDelete(0,"Dolly38"); ObjectDelete(0,"Dolly39"); ObjectDelete(0,"Dolly40");
   ObjectDelete(0,"Dolly41"); ObjectDelete(0,"Dolly42"); ObjectDelete(0,"Dolly43"); ObjectDelete(0,"Dolly44");
   ObjectDelete(0,"Dolly45"); ObjectDelete(0,"Dolly46"); ObjectDelete(0,"Dolly47"); ObjectDelete(0,"Dolly48");
   ObjectDelete(0,"Dolly49"); ObjectDelete(0,"Dolly50"); ObjectDelete(0,"Dolly51");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,IND_NAME);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   Bid=close[rates_total-1];
   Ask=Bid+_Point*spread[rates_total-1];
   CreateP();
//----
   ChartRedraw(0);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateP()
  {
   ObjectsDeleteAll(0,-1,OBJ_TRENDBYANGLE);
   DeleteCreatePivots1();
   CreateDL();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteCreatePivots1()
  {
   ObjectDelete(0,P1);
   ObjectDelete(0,DHI);
   ObjectDelete(0,DLO);
   ObjectDelete(0,DO);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateDL()
  {
   ObjectsDeleteAll(0,-1,OBJ_RECTANGLE);
   DeleteDollyGraphics();
   CreateAL();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteDollyGraphics()
  {
   ObjectDelete(0,DollyBUY3);
   ObjectDelete(0,DollyBUY2);
   ObjectDelete(0,DollyBUY1);
   ObjectDelete(0,DollySELL1);
   ObjectDelete(0,DollySELL2);
   ObjectDelete(0,DollySELL3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateAL()
  {
   ObjectsDeleteAll(0,-1,OBJ_RECTANGLE);
   DeleteAvGraphics();
   CreatePP();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAvGraphics()
  {
   ObjectDelete(0,AvBUY150);  ObjectDelete(0,AvBUY125);  ObjectDelete(0,AvBUY100); ObjectDelete(0,AvBUY75);
   ObjectDelete(0,AvSELL75);  ObjectDelete(0,AvSELL100);  ObjectDelete(0,AvSELL125);  ObjectDelete(0,AvSELL150);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePP()
  {
   ObjectsDeleteAll(0,-1,OBJ_TRENDBYANGLE);
   DeleteCreatePivots();
   CreateFIB();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteCreatePivots()
  {
   ObjectDelete(0,PP1); ObjectDelete(0,RR3); ObjectDelete(0,RR2); ObjectDelete(0,RR1);
   ObjectDelete(0,SS1); ObjectDelete(0,SS2); ObjectDelete(0,SS3); ObjectDelete(0,P1);
   ObjectDelete(0,MM1); ObjectDelete(0,MM2); ObjectDelete(0,MM3);
   ObjectDelete(0,MM4); ObjectDelete(0,MM5); ObjectDelete(0,MM0);
   ObjectDelete(0,DDHI); ObjectDelete(0,DDLO);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePivots1(string Pivots1, double start, double end,int w, int s,color clr)
  {
   ObjectCreate(0,Pivots1, OBJ_TRENDBYANGLE, 0, iTime(NULL,PERIOD_D1,0)+GMTshift*3600, start, iTime(NULL,PERIOD_CURRENT,0),w,s, end);
   ObjectSetInteger(0,Pivots1, OBJPROP_COLOR, clr);
   ObjectSetInteger(0,Pivots1,OBJPROP_RAY,false);
   ObjectSetInteger(0,Pivots1,OBJPROP_BACK,true);  
   ObjectSetInteger(0,Pivots1,OBJPROP_WIDTH,w); 
   ObjectSetInteger(0,Pivots1,OBJPROP_STYLE,s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateDollyGraphics(string Dolly, double start, double end, color clr)
  {
   ObjectCreate(0,Dolly, OBJ_RECTANGLE, 0, iTime(NULL,PERIOD_D1,0)+GMTshift*3600, start, iTime(NULL,PERIOD_CURRENT,0), end);
   ObjectSetInteger(0,Dolly, OBJPROP_COLOR, clr);
   ObjectSetInteger(0,Dolly,OBJPROP_BACK,Dolly_GRAPHICS);
   ObjectSetInteger(0,Dolly,OBJPROP_WIDTH,2);
   ObjectSetInteger(0,Dolly,OBJPROP_STYLE,0);
   ObjectSetInteger(0,Dolly,OBJPROP_FILL,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateAvGraphics(string DailyAv, double start, double end, color clr)
  {
   ObjectCreate(0,DailyAv, OBJ_RECTANGLE, 0, iTime(NULL,PERIOD_D1,0)+GMTshift*3600, start, iTime(NULL,PERIOD_CURRENT,0), end);
   ObjectSetInteger(0,DailyAv, OBJPROP_COLOR, clr);
   ObjectSetInteger(0,DailyAv,OBJPROP_BACK,Daily_AverageGRAPHICS);
   ObjectSetInteger(0,DailyAv,OBJPROP_WIDTH,0);
   ObjectSetInteger(0,DailyAv,OBJPROP_STYLE,0);
   ObjectSetInteger(0,DailyAv,OBJPROP_FILL,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreatePivots(string Pivots, double start, double end,int w, int s,color clr)
  {
   ObjectCreate(0,Pivots, OBJ_TRENDBYANGLE, 0, iTime(NULL,PERIOD_D1,Pivot_Point_ExtendLINE+0), start, iTime(NULL,PERIOD_CURRENT,0),w,s, end);
   ObjectSetInteger(0,Pivots, OBJPROP_COLOR, clr);
   ObjectSetInteger(0,Pivots,OBJPROP_RAY,false);
   ObjectSetInteger(0,Pivots,OBJPROP_WIDTH,w);
   ObjectSetInteger(0,Pivots,OBJPROP_STYLE,s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateFibs(string FibLevels, double start, double end,int w, int s,color clr)
  {
   ObjectCreate(0,FibLevels, OBJ_TRENDBYANGLE, 0, iTime(NULL,PERIOD_D1,FIB_ExtendDISPLAY), start, iTime(NULL,PERIOD_CURRENT,0),w,s, end);
   ObjectSetInteger(0,FibLevels, OBJPROP_COLOR, clr);
   ObjectSetInteger(0,FibLevels,OBJPROP_RAY,false);
   ObjectSetInteger(0,FibLevels,OBJPROP_WIDTH,w);
   ObjectSetInteger(0,FibLevels,OBJPROP_STYLE,s);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteCreateFibs()
  {
   ObjectDelete(0,Fib100); ObjectDelete(0,Fib764); ObjectDelete(0,Fib618); ObjectDelete(0,Fib50);
   ObjectDelete(0,Fib236); ObjectDelete(0,Fib0); ObjectDelete(0,Fib382);
   ObjectDelete(0,FibP100); ObjectDelete(0,FibP618); ObjectDelete(0,FibP50); ObjectDelete(0,FibP382);
   ObjectDelete(0,FibM100); ObjectDelete(0,FibM618); ObjectDelete(0,FibM50); ObjectDelete(0,FibM382);
   ObjectDelete(0,FibP236); ObjectDelete(0,FibM236); ObjectDelete(0,FibP764); ObjectDelete(0,FibM764);
   ObjectDelete(0,FibP150); ObjectDelete(0,FibM150); ObjectDelete(0,FibP200); ObjectDelete(0,FibM200);
   ObjectDelete(0,FibP250); ObjectDelete(0,FibM250); ObjectDelete(0,FibP300); ObjectDelete(0,FibM300);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateFIB()
  {
   ObjectsDeleteAll(0,-1,OBJ_TRENDBYANGLE);
   DeleteCreateFibs();
//---- Get new daily prices & calculate pivots
   day_high=0;
   day_low=0;
   yesterday_open=0;
   today_open=0;
   cur_day=0;
   prev_day=0;
//----
   int cnt=720;
   while(cnt!= 0)
     {
      MqlDateTime tm;
      TimeToStruct(iTime(NULL,PERIOD_CURRENT,cnt),tm);
      if (tm.day_of_week==0)
        {
         cur_day=prev_day;
        }
      else
        {
         MqlDateTime tm1;
         TimeToStruct(iTime(NULL,PERIOD_CURRENT,cnt)-GMTshift*3600,tm1);
         cur_day=tm1.day;
        }
      if (prev_day!=cur_day) 
        {
         yesterday_close=iClose(NULL,PERIOD_CURRENT,cnt+1);
         today_open=iOpen(NULL,PERIOD_CURRENT,cnt);
         yesterday_high=day_high;
         yesterday_low=day_low;
         day_high=iHigh(NULL,PERIOD_CURRENT,cnt);
         day_low =iLow(NULL,PERIOD_CURRENT,cnt);
         prev_day=cur_day;
        }
      if (iHigh(NULL,PERIOD_CURRENT,cnt)>day_high)
        {
         day_high=iHigh(NULL,PERIOD_CURRENT,cnt);
        }
      if (iLow(NULL,PERIOD_CURRENT,cnt)<day_low)
        {
         day_low=iLow(NULL,PERIOD_CURRENT,cnt);
        }
      cnt--;
     }
   double P=(yesterday_high + yesterday_low + yesterday_close)/3;//Pivot
   //Pivots & M Pivots
   double r3 =(2 * P)+(yesterday_high -(2 * yesterday_low ));
   double r2=P +(yesterday_high - yesterday_low );
   double r1 =(2 * P)- yesterday_low;
   double s1 =(2 * P)- yesterday_high;
   double s2=P -(yesterday_high- yesterday_low);
   double s3 =(2 * P)-(( 2 * yesterday_high)- yesterday_low );
//----
   double m0=(s2 + s3)/2;
   double m1=(s1 + s2)/2;
   double m2=(P + s1)/2;
   double m3=(P + r1)/2;
   double m4=(r1 + r2)/2;
   double m5=(r2 + r3)/2;
//----
   double OPEN=today_open;
   double HI2=iHigh(NULL,PERIOD_D1,0);
   double LOW2=iLow(NULL,PERIOD_D1,0);
   double HI3=yesterday_high;
   double LOW3=yesterday_low;
   double HI4=iHigh(NULL,PERIOD_D1,0);
   double LOW4=iLow(NULL,PERIOD_D1,0);
   double HI5=iHigh(NULL,PERIOD_D1,2);
   double LOW5=iLow(NULL,PERIOD_D1,2);
   double HI6=iHigh(NULL,PERIOD_D1,3);
   double LOW6=iLow(NULL,PERIOD_D1,3);
   double HI7=iHigh(NULL,PERIOD_D1,4);
   double LOW7=iLow(NULL,PERIOD_D1,4);
   double HI8=iHigh(NULL,PERIOD_D1,5);
   double LOW8=iLow(NULL,PERIOD_D1,5);
   double HI9=iHigh(NULL,PERIOD_D1,6);
   double LOW9=iLow(NULL,PERIOD_D1,6);
   double HI10=iHigh(NULL,PERIOD_D1,7);
   double LOW10=iLow(NULL,PERIOD_D1,7);
   double HI11=iHigh(NULL,PERIOD_D1,8);
   double LOW11=iLow(NULL,PERIOD_D1,8);
   double HI12=iHigh(NULL,PERIOD_D1,9);
   double LOW12=iLow(NULL,PERIOD_D1,9);
   double HI13=iHigh(NULL,PERIOD_D1,10);
   double LOW13=iLow(NULL,PERIOD_D1,10);
   double HI14=iHigh(NULL,PERIOD_D1,11);
   double LOW14=iLow(NULL,PERIOD_D1,11);
   double HI15=iHigh(NULL,PERIOD_D1,12);
   double LOW15=iLow(NULL,PERIOD_D1,12);
   double HI16=iHigh(NULL,PERIOD_D1,13);
   double LOW16=iLow(NULL,PERIOD_D1,13);
   double HI17=iHigh(NULL,PERIOD_D1,14);
   double LOW17=iLow(NULL,PERIOD_D1,14);
   double HI18=iHigh(NULL,PERIOD_D1,15);
   double LOW18=iLow(NULL,PERIOD_D1,15);
   double HI19=iHigh(NULL,PERIOD_D1,16);
   double LOW19=iLow(NULL,PERIOD_D1,16);
   double HI20=iHigh(NULL,PERIOD_D1,17);
   double LOW20=iLow(NULL,PERIOD_D1,17);
   double HI21=iHigh(NULL,PERIOD_D1,18);
   double LOW21=iLow(NULL,PERIOD_D1,18);
   double HI22=iHigh(NULL,PERIOD_D1,19);
   double LOW22=iLow(NULL,PERIOD_D1,19);
   double HI23=iHigh(NULL,PERIOD_D1,20);
   double LOW23=iLow(NULL,PERIOD_D1,20);
//----
   double ONE=(HI3-LOW3);
   double FIVE=((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8))/5;
   double TEN=((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8)+
                 (HI9-LOW9)+(HI10-LOW10)+(HI11-LOW11)+(HI12-LOW12)+(HI13-LOW13))/10;
   double TWENTY=((HI3-LOW3)+(HI5-LOW5)+(HI6-LOW6)+(HI7-LOW7)+(HI8-LOW8)+
              (HI9-LOW9)+(HI10-LOW10)+(HI11-LOW11)+(HI12-LOW12)+(HI13-LOW13)+
              (HI14-LOW14)+(HI15-LOW15)+(HI16-LOW16)+(HI17-LOW17)+(HI18-LOW18)+
              (HI19-LOW19)+(HI20-LOW20)+(HI21-LOW21)+(HI22-LOW22)+(HI23-LOW23))/20;
   double AV=(ONE+FIVE+TEN+TWENTY)/4;// New Setting AV = (FIVE+TEN+TWENTY)/3;
   //Add for Open Graphics - hymns
   double DollyOpenGraphics;
   if (Using_OpenGraphics==true) { DollyOpenGraphics=OPEN; }
   else { DollyOpenGraphics=P; }
   //Tweak for Open Graphics - hymns   
   double AvDN150=DollyOpenGraphics-AV/2*3;
   double AvUP150=DollyOpenGraphics+AV/2*3;
   double AvDN125=DollyOpenGraphics-AV/4*5;
   double AvUP125=DollyOpenGraphics+AV/4*5;
   double AvDN100=DollyOpenGraphics-AV;
   double AvUP100=DollyOpenGraphics+AV;
   double AvDN75=DollyOpenGraphics-AV/4*3;
   double AvUP75=DollyOpenGraphics+AV/4*3;
   double AvDN50=DollyOpenGraphics-AV/2;
   double AvUP50=DollyOpenGraphics+AV/2;
   double AvDN25=DollyOpenGraphics-AV/4;
   double AvUP25=DollyOpenGraphics+AV/4;
//----
   double CLOSE=iClose(NULL,PERIOD_D1,0);
   double F;
   F=(yesterday_high-yesterday_low);
   double FIBP300= yesterday_low + F*4.00;
   double FIBP250= yesterday_low + F*3.5;
   double FIBP200= yesterday_low + F*3.00;
   double FIBP150= yesterday_low + F*2.5;
   double FIBP100= yesterday_low + F*2.00;
   double FIBP764=yesterday_low + F*1.764;
   double FIBP618= yesterday_low + F*1.618;
   double FIBP50=yesterday_low + F*1.5;
   double FIBP382= yesterday_low + F*1.382;
   double FIBP236=yesterday_low + F*1.236;
   double FIB100= yesterday_high;
   double FIB764=yesterday_low + F*0.764;
   double FIB618= yesterday_low + F*0.618;
   double FIB50=yesterday_low + F*0.5;
   double FIB382= yesterday_low + F*0.382;
   double FIB236=yesterday_low + F*0.236;
   double FIB0=yesterday_low + F*0.0;
   double FIBM236=yesterday_low - F*0.236;
   double FIBM382= yesterday_low - F*0.382;
   double FIBM50=yesterday_low - F*0.5;
   double FIBM618= yesterday_low - F*0.618;
   double FIBM764=yesterday_low  - F*0.764;
   double FIBM100= yesterday_low - F*1.00;
   double FIBM150= yesterday_low - F*1.5;
   double FIBM200= yesterday_low - F*2.00;
   double FIBM250= yesterday_low - F*2.5;
   double FIBM300= yesterday_low - F*3.00;
   //Tweak for Open Graphics - hymns  
   double B1=DollyOpenGraphics + BUY_Area * _Point; // Logic to determine Buy Area 
   double S1=DollyOpenGraphics - SELL_Area * _Point; // Logic to determine Sell Area 
   double B2=DollyOpenGraphics + BUY_Target_1 * _Point; // Logic to determine High Break Area 
   double S2=DollyOpenGraphics - SELL_Target_1 * _Point; // Logic to determine Low Break Area )
   double B3=DollyOpenGraphics + BUY_Target_2 * _Point; // Logic to determine High Target Area 
   double S3=DollyOpenGraphics - SELL_Target_2 * _Point; // Logic to determine Low Target Area 
   ChartRedraw(0);
//----
   if (Alert_ON ==true)
     {
      if(Ask>(B1-2*_Point)&&Ask<(B1+2*_Point)){ Alert(Symbol()," M",Period()," : DOLLY : BUY AREA  @  "+(DoubleToString (B1,_Digits))+"");}
      if(Bid<(S1+2*_Point)&&Bid>(S1-2*_Point)){ Alert(Symbol()," M",Period()," : DOLLY : SELL AREA  @  "+(DoubleToString (S1,_Digits))+"" );}
      if(Ask>(B2-2*_Point)&&Ask<(B2+2*_Point)){ Alert(Symbol()," M",Period()," : DOLLY : BUY TARGET #1  @  "+(DoubleToString (B2,_Digits))+"" );}
      if(Bid<(S2+2*_Point)&&Bid>(S2-2*_Point)){ Alert(Symbol()," M",Period()," : DOLLY : SELL TARGET #1  @  "+(DoubleToString (S2,_Digits))+"" );}
      if(Ask>(B3-2*_Point)&&Ask<(B3+2*_Point)){ Alert(Symbol()," M",Period()," : DOLLY : BUY TARGET #2  @  "+(DoubleToString (B3,_Digits))+"" );}
      if(Bid<(S3+2*_Point)&&Bid>(S3-2*_Point)){ Alert(Symbol()," M",Period()," : DOLLY : SELL TARGET #2  @  "+(DoubleToString (S3,_Digits))+"" );}
     }
   string Signal="",Signal2=""; color Dolly_col=clrWhite,Dolly_col2=clrWhite;
   if(Show_DollyCOMMENTS==true )
     {
      if(Auto_Signals==true )
        {
         if (Using_OpenGraphics==true)
           {
            Signal="Currently Signals Pending ................................."; Dolly_col=clrCrimson;
              if(Ask>(B1-3*_Point)&&Ask<(B1+3*_Point)){Signal="OPEN + ["+string(BUY_Area)+"] @ "+DoubleToString(B1,_Digits)+""
               +" - TP @ "+DoubleToString(B1+20*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(B1-40*_Point,_Digits)+"";
               Dolly_col=C'0,250,250';
              }
              if(Ask>(B2-3*_Point)&&Ask<(B2+3*_Point)){Signal="BUY Stop : OPEN + ["+string(BUY_Target_1)+"] @ "+DoubleToString(B2,_Digits)+""
               +" - TP @ "+DoubleToString(B2+10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(B2-20*_Point,_Digits)+"";
               Dolly_col= C'0,250,250';
              }
              if(Ask>(B3-3*_Point)&&Ask<(B3+3*_Point)){Signal="BUY Stop : OPEN + ["+string(BUY_Target_2) +"] @ "+DoubleToString(B3,_Digits)+""
               +" - TP @ "+DoubleToString(B3+10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(B3-20*_Point,_Digits)+"";
               Dolly_col =C'0,250,250' ;
              }
              if(Ask>(AvUP100-3*_Point)&&Ask<(AvUP100+3*_Point)){Signal="Caution approaching Daily Average Range @ "+DoubleToString(AvUP100,_Digits)+"";
               Dolly_col=YellowGreen;
              }
              if(Bid>(AvDN100+3*_Point)&&Bid<(AvDN100-3*_Point)){Signal="Caution approaching Daily Average Range @ "+DoubleToString(AvDN100,_Digits)+"";
               Dolly_col=YellowGreen;
              }
              if(Bid<(S1+3*_Point)&&Bid>(S1-3*_Point)){Signal="OPEN - ["+string(SELL_Area)+"] @ "+DoubleToString(S1,_Digits)+""
               +" - TP @ "+DoubleToString(S1-20*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(S1+40*_Point,_Digits)+"";
               Dolly_col= C'250,150,0';
              }
              if(Bid<(S2+3*_Point)&&Bid>(S2-3*_Point)){Signal="SELL Stop : OPEN - ["+string(SELL_Target_1)+"] @ "+DoubleToString(S2,_Digits)+""
               +" - TP @ "+DoubleToString(S2-10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(S2+20*_Point,_Digits)+"";
               Dolly_col= C'250,150,0';
              }
              if(Bid<(S3+3*_Point)&&Bid>(S3-3*_Point)){Signal="SELL Stop : OPEN - ["+string(SELL_Target_2)+"] @ "+DoubleToString(S3,_Digits)+""
               +" - TP @ "+DoubleToString(S3-10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(S3+20*_Point,_Digits)+"";
               Dolly_col=C'250,150,0';
              }
              if(Bid<(P+3*_Point)&&Bid>(P-3*_Point)){Signal="Caution possible reversal  PIVOT @ "+DoubleToString(P,_Digits)+"";
               Dolly_col=White;
              }
              if(Bid<(OPEN+2*_Point)&&Bid>(OPEN-2*_Point)){Signal="Caution possible reversal  OPEN @ "+DoubleToString(OPEN,_Digits)+"";
               Dolly_col=White;
              }
              if((Bid>S1)&& (Bid<B1)){Signal2="Price Currently between BUY & SELL ZONES";
               Dolly_col2= C'250,230,0';
              }
              if((Bid<=S1)&& (Bid>S2)){Signal2="Price Currently in SELL ZONE #1";
               Dolly_col2= C'250,50,0';
              }
              if((Bid<=S2)&& (Bid>S3)){Signal2="Price Currently in SELL ZONE #2";
               Dolly_col2= C'250,90,0';
              }
              if((Bid>=B1)&& (Bid<B2)){Signal2="Price Currently in BUY ZONE #1";
               Dolly_col2= C'0,120,250';
              }
              if((Bid>=B2)&& (Bid<B3)){Signal2="Price Currently in BUY ZONE #2";
               Dolly_col2=  C'0,180,250';
              }
              if((Bid>=B3)&& (Bid<AvUP100)){Signal2="Price Currently Between BUY ZONE #2 & 100% D/AV";
               Dolly_col2=C'120,250,250';
              }
              if((Bid<=S3)&& (Bid>AvDN100)){Signal2="Price Currently Between SELL ZONE #2 & 100% D/AV";
               Dolly_col2= C'220,250,0';//
              }
           }
         if (Using_OpenGraphics==false)
           {
            Signal="Currently Signals Pending ................................."; Dolly_col= C'250,250,0';
              if(Ask>(B1-3*_Point)&&Ask<(B1+3*_Point)){Signal="PIVOT + ["+string(BUY_Area)+"] @ "+DoubleToString(B1,_Digits)+""
               +" - TP @ "+DoubleToString(B1+20*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(B1-40*_Point,_Digits)+"";
               Dolly_col=C'0,250,250';
              }
              if(Ask>(B2-3*_Point)&&Ask<(B2+3*_Point)){Signal="BUY Stop : PIVOT + ["+string(BUY_Target_1)+"] @ "+DoubleToString(B2,_Digits)+""
               +" - TP @ "+DoubleToString(B2+10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(B2-20*_Point,_Digits)+"";
               Dolly_col= C'0,250,250';
              }
              if(Ask>(B3-3*_Point)&&Ask<(B3+3*_Point)){Signal="BUY Stop : PIVOT + ["+string(BUY_Target_2) +"] @ "+DoubleToString(B3,_Digits)+""
               +" - TP @ "+DoubleToString(B3+10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(B3-20*_Point,_Digits)+"";
               Dolly_col =C'0,250,250' ;
              }
              if(Ask>(AvUP100-3*_Point)&&Ask<(AvUP100+3*_Point)){Signal="Caution approaching Daily Average Range @ "+DoubleToString(AvUP100,_Digits)+"";
               Dolly_col=YellowGreen;
              }
              if(Bid>(AvDN100+3*_Point)&&Bid<(AvDN100-3*_Point)){Signal="Caution approaching Daily Average Range @ "+DoubleToString(AvDN100,_Digits)+"";
               Dolly_col=YellowGreen;
              }
              if(Bid<(S1+3*_Point)&&Bid>(S1-3*_Point)){Signal="PIVOT - ["+string(SELL_Area)+"] @ "+DoubleToString(S1,_Digits)+""
               +" - TP @ "+DoubleToString(S1-20*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(S1+40*_Point,_Digits)+"";
               Dolly_col=C'250,150,0';
              }
              if(Bid<(S2+3*_Point)&&Bid>(S2-3*_Point)){Signal="SELL Stop : PIVOT - ["+string(SELL_Target_1)+"] @ "+DoubleToString(S2,_Digits)+""
               +" - TP @ "+DoubleToString(S2-10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(S2+20*_Point,_Digits)+"";
               Dolly_col= C'250,150,0';
              }
              if(Bid<(S3+3*_Point)&&Bid>(S3-3*_Point)){Signal="SELL Stop : PIVOT - ["+string(SELL_Target_2)+"] @ "+DoubleToString(S3,_Digits)+""
               +" - TP @ "+DoubleToString(S3-10*_Point,_Digits)+""
               +" - SL @ "+DoubleToString(S3+20*_Point,_Digits)+"";
               Dolly_col=C'250,150,0';
              }
              if(Bid<(P+3*_Point)&&Bid>(P-3*_Point)){Signal="Caution possible reversal  PIVOT @ "+DoubleToString(P,_Digits)+"";
               Dolly_col=White;
              }
              if(Bid<(OPEN+2*_Point)&&Bid>(OPEN-2*_Point)){Signal="Caution possible reversal  OPEN @ "+DoubleToString(OPEN,_Digits)+"";
               Dolly_col=White;
              }
              if((Bid>S1)&& (Bid<B1)){Signal2="Price Currently between BUY & SELL ZONES";
               Dolly_col2= C'250,230,0';
              }
              if((Bid<=S1)&& (Bid>S2)){Signal2="Price Currently in SELL ZONE #1";
               Dolly_col2= C'250,50,0';
              }
              if((Bid<=S2)&& (Bid>S3)){Signal2="Price Currently in SELL ZONE #2";
               Dolly_col2= C'250,90,0';
              }
              if((Bid>=B1)&& (Bid<B2)){Signal2="Price Currently in BUY ZONE #1";
               Dolly_col2= C'0,120,250';
              }
              if((Bid>=B2)&& (Bid<B3)){Signal2="Price Currently in BUY ZONE #2";
               Dolly_col2=  C'0,180,250';
              }
              if((Bid>=B3)&& (Bid<AvUP100)){Signal2="Price Currently Between BUY ZONE #2 & 100% D/AV";
               Dolly_col2=C'120,250,250';
              }
              if((Bid<=S3)&& (Bid>AvDN100)){Signal2="Price Currently Between SELL ZONE #2 & 100% D/AV";
               Dolly_col2= C'220,250,0';//
              }
           }
         //{Signal = "Waiting..."; col = Orange;}
         ObjectCreate(0,"Signal", OBJ_LABEL, 0, 0, 0);
         ObjectSetString_(0,"Signal", Signal, 11,"Arial Bold", Dolly_col); 
         ObjectSetInteger(0,"Signal", OBJPROP_CORNER, 0);
         ObjectSetInteger(0,"Signal", OBJPROP_XDISTANCE, 20);
         ObjectSetInteger(0,"Signal", OBJPROP_YDISTANCE, 65);
//----
         ObjectCreate(0,"Signal2", OBJ_LABEL, 0, 0, 0);
         ObjectSetString_(0,"Signal2", Signal2, 11,"Arial Bold", Dolly_col2);
         ObjectSetInteger(0,"Signal2", OBJPROP_CORNER, 0);
         ObjectSetInteger(0,"Signal2", OBJPROP_XDISTANCE, 20);
         ObjectSetInteger(0,"Signal2", OBJPROP_YDISTANCE, 85);
         // Signal = "Currently Signals Pending ................................."; col = Yellow;
         ObjectCreate(0,"Signal1", OBJ_LABEL, 0, 0, 0);
         ObjectSetString_(0,"Signal1","Signal Auto Display", 9, "Arial", Silver);
         ObjectSetInteger(0,"Signal1", OBJPROP_CORNER, 4);
         ObjectSetInteger(0,"Signal1", OBJPROP_XDISTANCE, 20);
         ObjectSetInteger(0,"Signal1", OBJPROP_YDISTANCE, 47);
        }
       }
   // Dolly Colored Levels
   CreateDollyGraphics(DollyBUY3, B3, B3, C'0,0,210' );
   CreateDollyGraphics(DollyBUY2, B2, B3,BUY_Color_2); //C'0,0,150'
   CreateDollyGraphics(DollyBUY1, B1, B2,BUY_Color_1 ); //C'0,0,100'
   CreateDollyGraphics(DollySELL1, S1, S2,SELL_Color_1 ); //C'120,0,0'
   CreateDollyGraphics(DollySELL2, S2, S3,SELL_Color_2 ); //C'180,0,0'
   CreateDollyGraphics(DollySELL3, S3, S3, C'230,0,0');
   //Daily Average Colored Levels   
   if (Show_DailyAverageGRAPHICS==true)
     {
      CreateAvGraphics(AvBUY150,AvUP150,AvUP125, DAILY_Av_UP_Color_150 ); // C'0,110,255'
      CreateAvGraphics(AvBUY125,AvUP125,AvUP100, DAILY_Av_UP_Color_125); //C'0,70,255'
      CreateAvGraphics(AvBUY100,AvUP100,AvUP75,DAILY_Av_UP_Color_100); //C'20,20,255'
      CreateAvGraphics(AvBUY75,AvUP75,B3,DAILY_Av_UP_Color_75 ); //C'0,0,210'
      CreateAvGraphics(AvSELL75,AvDN75,S3,DAILY_Av_DN_Color_75 ); //C'220,0,0'
      CreateAvGraphics(AvSELL100,AvDN100,AvDN75,DAILY_Av_DN_Color_100); // C'255,0,0'
      CreateAvGraphics(AvSELL125,AvDN100,AvDN125,DAILY_Av_DN_Color_125); //C'255,70,0'
      CreateAvGraphics(AvSELL150,AvDN125,AvDN150,DAILY_Av_DN_Color_150); // C'255,110,0'
     }
   //Create Pivot Line   
   CreatePivots1(P1,P,P,2,0, DimGray);
   //Show Pivot Support & Resistance Lines
   if (Show_PivotLines==true)
     {
      CreatePivots(PP1,P,P,2,1, Gray);
      CreatePivots(RR3,r3,r3,1,0, Gray);
      CreatePivots(RR2,r2,r2,1,0, Gray);
      CreatePivots(RR1,r1,r1,1,0, Gray);
      CreatePivots(SS1,s1,s1,1,0, Gray);
      CreatePivots(SS2,s2,s2,1,0, Gray);
      CreatePivots(SS3,s3,s3,1,0, Gray);
     }
   //Show Middle Pivot Lines
   if (Show_M_PivotLines==true)
     {
      CreatePivots(MM5,m5,m5,1,2, Gray);
      CreatePivots(MM4,m4,m4,1,2, Gray);
      CreatePivots(MM3,m3,m3,1,2, Gray);
      CreatePivots(MM2,m2,m2,1,2, Gray);
      CreatePivots(MM1,m1,m1,1,2, Gray);
      CreatePivots(MM0,m0,m0,1,2, Gray);
     }
   //Show Fibo Lines     
   if (Show_FibLines==true)
     {
      CreateFibs(FibP100, FIBP100, FIBP100,1,0,Green );
      CreateFibs(FibP764, FIBP764, FIBP764,1,0, C'0,53,0' );
      CreateFibs(FibP618, FIBP618, FIBP618,1,0, Green);
      CreateFibs(FibP50, FIBP50, FIBP50,1,0, C'0,53,0' );
      CreateFibs(FibP382, FIBP382, FIBP382,1,0, Green );
      CreateFibs(FibP236, FIBP236, FIBP236,1,0, C'0,53,0' );
      CreateFibs(Fib100, FIB100, FIB100,1,0,  C'0,200,0');
      CreateFibs(Fib764, FIB764, FIB764,1,0, C'0,53,0' );
      CreateFibs(Fib618, FIB618, FIB618,1,0, Green );
      CreateFibs(Fib50, FIB50, FIB50,1,0, C'0,53,0' );
      CreateFibs(Fib382, FIB382, FIB382,1,0, Green );
      CreateFibs(Fib236, FIB236, FIB236,1,0, C'0,53,0' );
      CreateFibs(Fib0, FIB0, FIB0,1,0,  C'0,200,0' );
      CreateFibs(FibM236, FIBM236, FIBM236,1,0, C'0,53,0' );
      CreateFibs(FibM382, FIBM382, FIBM382,1,0, Green );
      CreateFibs(FibM50, FIBM50, FIBM50,1,0, C'0,53,0' );
      CreateFibs(FibM618, FIBM618, FIBM618,1,0, Green );
      CreateFibs(FibM764, FIBM764, FIBM764,1,0,C'0,53,0');
      CreateFibs(FibM100, FIBM100, FIBM100,1,0, Green );
     }
   //Show Extra Fibo Lines
   if (Show_EXTRAFibLines==true)
     {
      CreateFibs(FibP300, FIBP300, FIBP300,1,0, Green );
      CreateFibs(FibP250, FIBP250, FIBP250,1,0, Green );
      CreateFibs(FibP200, FIBP200, FIBP200,1,0, Green );
      CreateFibs(FibP150, FIBP150, FIBP150,1,0, Green );
//----
      CreateFibs(FibM150, FIBM150, FIBM150,1,0, Green );
      CreateFibs(FibM200, FIBM200, FIBM200,1,0, Green );
      CreateFibs(FibM250, FIBM250, FIBM250,1,0, Green );
      CreateFibs(FibM300, FIBM300, FIBM300,1,0, Green );
     }
   //Show Daily HI-LOW
   if (Show_Daily_HI_LOW==true)
     {
      CreatePivots1(DHI,HI3,HI3,2,0, Turquoise);
      CreatePivots1(DLO,LOW3,LOW3,2,0, Turquoise);
      CreatePivots(DDHI,HI3,HI3,2,0, Turquoise);
      CreatePivots(DDLO,LOW3,LOW3,2,0, Turquoise);
     }
   //Show Daily Open
   if (Show_Daily_OPEN==true || Using_OpenGraphics==true) //Tweak for Open Graphics - hymns
     {
      CreatePivots1(DO,OPEN,OPEN,2,0, YellowGreen);
     }
   //Buy	  
   if(ObjectFind(0,"B1")!=0)
     {
      ObjectCreate(0,"B1", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), B1);
      ObjectSetString_(0,"B1", "                        BUY AREA", 8, "Arial",DodgerBlue);
      ObjectSetInteger(0,"B1",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"B1", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), B1);
     }
   if(ObjectFind(0,"B2")!=0)
     {
      ObjectCreate(0,"B2", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), B2);
      ObjectSetString_(0,"B2", "                                   1st BUY TARGET ", 8, "Arial",DodgerBlue);
      ObjectSetInteger(0,"B2",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"B2", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText),B2);
     }
   if(ObjectFind(0,"B3")!=0)
     {
      ObjectCreate(0,"B3", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), B3);
      ObjectSetString_(0,"B3", "                             2nd TARGET ", 8, "Arial",DodgerBlue);
      ObjectSetInteger(0,"B3",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"B3", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), B3);
     }
   //Sell
   if(ObjectFind(0,"S1")!=0)
     {
      ObjectCreate(0,"S1", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText),S1);
      ObjectSetString_(0,"S1", "                         SELL AREA", 8, "Arial", Orange);
      ObjectSetInteger(0,"S1",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"S1", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), S1);
     }
   if(ObjectFind(0,"S2")!=0)
     {
      ObjectCreate(0,"S2", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), S2);
      ObjectSetString_(0,"S2", "                                   1st SELL TARGET ", 8, "Arial",Orange);
      ObjectSetInteger(0,"S2",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"S2", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), S2);
     }
   if(ObjectFind(0,"S3")!=0)
     {
      ObjectCreate(0,"S3", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), S3);
      ObjectSetString_(0,"S3", "                             2nd TARGET ", 8, "Arial",Orange);
      ObjectSetInteger(0,"S3",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"S3", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), S3);
     }
   //Pivot
   if(ObjectFind(0,"Pivot")!=0)
     {
      ObjectCreate(0,"Pivot", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), P);
      ObjectSetString_(0,"Pivot", "                             PIVOT "+ DoubleToString(P,_Digits)+"", 8, "Arial",Silver);
      ObjectSetInteger(0,"Pivot",OBJPROP_BACK,true);
     }
     else
     {
      ObjectMove(0,"Pivot", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyText), P);
     }
   //Average Levels
   if (Show_DailyAverageGRAPHICS==true)
     {
      if(ObjectFind(0,"TOP/AV150")!=0)
        {
         ObjectCreate(0,"TOP/AV150", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP150);
         ObjectSetString_(0,"TOP/AV150", "                                    150% ", 8, "Arial", DeepSkyBlue);
         ObjectSetInteger(0,"TOP/AV150",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"TOP/AV150", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP150);
        }
        if(ObjectFind(0,"LOW/AV150")!=0)
        {
         ObjectCreate(0,"LOW/AV150", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN150);
         ObjectSetString_(0,"LOW/AV150", "                                    150% ", 8, "Arial", Green);
         ObjectSetInteger(0,"LOW/AV150",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"LOW/AV150", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN150);
        }
      if(ObjectFind(0,"TOP/AV125")!=0)
        {
         ObjectCreate(0,"TOP/AV125", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP125);
         ObjectSetString_(0,"TOP/AV125", "                                    125% ", 8, "Arial", DeepSkyBlue);
         ObjectSetInteger(0,"TOP/AV125",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"TOP/AV125", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP125);
        }
      if(ObjectFind(0,"LOW/AV125")!=0)
        {
         ObjectCreate(0,"LOW/AV125", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN125);
         ObjectSetString_(0,"LOW/AV125", "                                    125% ", 8, "Arial", Green);
         ObjectSetInteger(0,"LOW/AV125",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"LOW/AV125", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN125);
        }
      if(ObjectFind(0,"TOP/AV100")!=0)
        {
         ObjectCreate(0,"TOP/AV100", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP100);
         ObjectSetString_(0,"TOP/AV100", "                                   100%", 8, "Arial", DeepSkyBlue);
         ObjectSetInteger(0,"TOP/AV100",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"TOP/AV100", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP100);
        }
      if(ObjectFind(0,"LOW/AV100")!=0)
        {
         ObjectCreate(0,"LOW/AV100", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN100);
         ObjectSetString_(0,"LOW/AV100", "                                    100% ", 8, "Arial", Green);
         ObjectSetInteger(0,"LOW/AV100",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"LOW/AV100", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN100);
        }
      if(ObjectFind(0,"TOP/AV75")!=0)
        {
         ObjectCreate(0,"TOP/AV75", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP75);
         ObjectSetString_(0,"TOP/AV75", "                                      75% ", 8, "Arial", DeepSkyBlue);
         ObjectSetInteger(0,"TOP/AV75",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"TOP/AV75", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP75);
        }
      if(ObjectFind(0,"LOW/AV75")!=0)
        {
         ObjectCreate(0,"LOW/AV75", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN75);
         ObjectSetString_(0,"LOW/AV75", "                                     75%", 8, "Arial", Green);
         ObjectSetInteger(0,"LOW/AV75",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"LOW/AV75", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN75);
        }
      if(ObjectFind(0,"LOW/AV50")!=0)
        {
         ObjectCreate(0,"LOW/AV50", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP50);
         ObjectSetString_(0,"LOW/AV50", "                                       50% ", 8, "Arial",DeepSkyBlue );
         ObjectSetInteger(0,"LOW/AV50",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"LOW/AV50", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP50);
        }
      if(ObjectFind(0,"TOP/AV50")!=0)
        {
         ObjectCreate(0,"TOP/AV50", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN50);
         ObjectSetString_(0,"TOP/AV50", "                                      50% ", 8, "Arial",Green );
         ObjectSetInteger(0,"TOP/AV50",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"TOP/AV50", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN50);
        }
      if(ObjectFind(0,"TOP/AV25")!=0)
        {
         ObjectCreate(0,"TOP/AV25", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP25);
         ObjectSetString_(0,"TOP/AV25", "                                      25% ", 8, "Arial", DeepSkyBlue);
         ObjectSetInteger(0,"TOP/AV25",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"TOP/AV25", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvUP25);
        }
        if(ObjectFind(0,"LOW/AV25")!=0)
        {
         ObjectCreate(0,"LOW/AV25", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN25);
         ObjectSetString_(0,"LOW/AV25", "                                      25% ", 8, "Arial", Green);
         ObjectSetInteger(0,"LOW/AV25",OBJPROP_BACK,true);
        }
        else
        {
         ObjectMove(0,"LOW/AV25", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_DailyAverageText), AvDN25);
        }
     } //Average Levels - End
   //Pivots Lines
   if (Show_PivotLines==true)
     {
      if(ObjectFind(0,"C/PIVOT")!=0)
        {
         ObjectCreate(0,"C/PIVOT", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), P);
         ObjectSetString_(0,"C/PIVOT", "P", 8, "Arial", Silver);
        }
        else
        {
         ObjectMove(0,"C/PIVOT", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), P);
        }
      if(ObjectFind(0,"R3")!=0)
        {
         ObjectCreate(0,"R3", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), r3);
         ObjectSetString_(0,"R3", "R3", 8, "Arial", Silver);
        }
        else
        {
         ObjectMove(0,"R3", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), r3);
        }
        if(ObjectFind(0,"R2")!=0)
        {
         ObjectCreate(0,"R2", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), r2);
         ObjectSetString_(0,"R2", "R2", 8, "Arial", Silver);
        }
        else 
        {
         ObjectMove(0,"R2", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), r2);
        }
        if(ObjectFind(0,"R1")!=0)
        {
         ObjectCreate(0,"R1", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), r1);
         ObjectSetString_(0,"R1", "R1", 8, "Arial", Silver);
        }
        else
        {
         ObjectMove(0,"R1", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), r1);
        }
      if(ObjectFind(0,"PS1")!=0)
        {
         ObjectCreate(0,"PS1", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), s1);
         ObjectSetString_(0,"PS1", "S1", 8, "Arial", Silver);
        }
        else
        {
         ObjectMove(0,"PS1", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), s1);
        }
      if(ObjectFind(0,"PS2")!=0)
        {
         ObjectCreate(0,"PS2", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), s2);
         ObjectSetString_(0,"PS2", "S2", 8, "Arial", Silver);
        }
        else
        {
         ObjectMove(0,"PS2", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), s2);
        }
      if(ObjectFind(0,"PS3")!=0)
        {
         ObjectCreate(0,"PS3", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), s3);
         ObjectSetString_(0,"PS3", "S3", 8, "Arial", Silver);
        }
        else
        {
         ObjectMove(0,"PS3", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), s3);
        }
      //M Pivots
      if (Show_M_PivotLines==true)
        {
         if(ObjectFind(0,"M5")!=0)
           {
            ObjectCreate(0,"M5", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m5);
            ObjectSetString_(0,"M5", "M5", 8, "Arial", Silver);
           }
           else
           {
            ObjectMove(0,"M5", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m5);
           }
         if(ObjectFind(0,"M4")!=0)
           {
            ObjectCreate(0,"M4", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m4);
            ObjectSetString_(0,"M4", "M4", 8, "Arial", Silver);
           }
           else
           {
            ObjectMove(0,"M4", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m4);
           }
         if(ObjectFind(0,"M3")!=0)
           {
            ObjectCreate(0,"M3", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m3);
            ObjectSetString_(0,"M3", "M3", 8, "Arial", Silver);
           }
           else
           {
            ObjectMove(0,"M3", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m3);
           }
         if(ObjectFind(0,"M2")!=0)
           {
            ObjectCreate(0,"M2", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m2);
            ObjectSetString_(0,"M2", "M2", 8, "Arial", Silver);
           }
           else
           {
            ObjectMove(0,"M2", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m2);
           }
         if(ObjectFind(0,"M1")!=0)
           {
            ObjectCreate(0,"M1", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m1);
            ObjectSetString_(0,"M1", "M1", 8, "Arial", Silver);
           }
           else
           {
            ObjectMove(0,"M1", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m1);
           }
         if(ObjectFind(0,"M0")!=0)
           {
            ObjectCreate(0,"M0", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m0);
            ObjectSetString_(0,"M0", "M0", 8, "Arial", Silver);
           }
           else
           {
            ObjectMove(0,"M0", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Pivot_PointText), m0);
           }
        } // M Pivot - End
     } // Pivot Lines - End
   //FIBS
   if (Show_FibLines==true)
     {
      if(ObjectFind(0,"FIB")!=0)
        {
         ObjectCreate(0,"FIB", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB100);
         ObjectSetString_(0,"FIB", "FIB 100% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB100);
        }
      if(ObjectFind(0,"FIB2")!=0)
        {
         ObjectCreate(0,"FIB2", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB50);
         ObjectSetString_(0,"FIB2", "FIB 50% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB2", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB50);
        }
      if(ObjectFind(0,"FIB3")!=0)
        {
         ObjectCreate(0,"FIB3", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB0);
         ObjectSetString_(0,"FIB3", "FIB 0.00% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB3", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB0);
        }
      if(ObjectFind(0,"FIB4")!=0)
        {
         ObjectCreate(0,"FIB4", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB382);
         ObjectSetString_(0,"FIB4", "FIB 0.382% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB4", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB382);
        }
        if(ObjectFind(0,"FIB5")!=0)
        {
         ObjectCreate(0,"FIB5", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB618);
         ObjectSetString_(0,"FIB5", "FIB 0.618% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB5", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB618);
        }
      if(ObjectFind(0,"FIB6")!=0)
        {
         ObjectCreate(0,"FIB6", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP50);
         ObjectSetString_(0,"FIB6", "FIB +1.50% ", 8, "Arial",  C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB6", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP50);
        }
      if(ObjectFind(0,"FIB7")!=0)
        {
         ObjectCreate(0,"FIB7", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP100);
         ObjectSetString_(0,"FIB7", "FIB +200% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB7", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP100);
        }
      if(ObjectFind(0,"FIB8")!=0)
        {
         ObjectCreate(0,"FIB8", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM50);
         ObjectSetString_(0,"FIB8", "FIB -1.50% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB8", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM50);
        }
      if(ObjectFind(0,"FIB9")!=0)
        {
         ObjectCreate(0,"FIB9", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM100);
         ObjectSetString_(0,"FIB9", "FIB -200% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB9", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM100);
        }
      if(ObjectFind(0,"FIB10")!=0)
        {
         ObjectCreate(0,"FIB10", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP382);
         ObjectSetString_(0,"FIB10", "FIB +1.382% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB10", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP382);
        }
      if(ObjectFind(0,"FIB11")!=0)
        {
         ObjectCreate(0,"FIB11", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM382);
         ObjectSetString_(0,"FIB11", "FIB -1.382% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB11", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM382);
        }
      if(ObjectFind(0,"FIB12")!=0)
        {
         ObjectCreate(0,"FIB12", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP618);
         ObjectSetString_(0,"FIB12", "FIB +1.618% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB12", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP618);  
        }
      if(ObjectFind(0,"FIB13")!=0)
        {
         ObjectCreate(0,"FIB13", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM618);
         ObjectSetString_(0,"FIB13", "FIB -1.618% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB13", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM618);
        }
      if(ObjectFind(0,"FIB14")!=0)
        {
         ObjectCreate(0,"FIB14", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB764);
         ObjectSetString_(0,"FIB14", "FIB 0.764% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB14", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB764);
        }
      if(ObjectFind(0,"FIB15")!=0)
        {
         ObjectCreate(0,"FIB15", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB236);
         ObjectSetString_(0,"FIB15", "FIB 0.236% ", 8, "Arial", Green);
        }
        else
        {
         ObjectMove(0,"FIB15", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIB236);
        }
      if(ObjectFind(0,"FIB16")!=0)
        {
         ObjectCreate(0,"FIB16", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM236);
         ObjectSetString_(0,"FIB16", "FIB -1.236% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB16", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM236);
        }
      if(ObjectFind(0,"FIB17")!=0)
        {
         ObjectCreate(0,"FIB17", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP236);
         ObjectSetString_(0,"FIB17", "FIB +1.236% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB17", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP236);
        }
      if(ObjectFind(0,"FIB18")!=0)
        {
         ObjectCreate(0,"FIB18", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM764);
         ObjectSetString_(0,"FIB18", "FIB -1.764% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB18", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM764);
        }
      if(ObjectFind(0,"FIB19")!=0)
        {
         ObjectCreate(0,"FIB19", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP764);
         ObjectSetString_(0,"FIB19", "FIB +1.764% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB19", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP764);
        }
     } // Fibs - End
   //Fibs Extra
   if (Show_EXTRAFibLines==true)
     {
      if(ObjectFind(0,"FIB120")!=0)
        {
         ObjectCreate(0,"FIB20", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP150);
         ObjectSetString_(0,"FIB20", "FIB +250% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB20", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP150);
        }
      if(ObjectFind(0,"FIB21")!=0)
        {
         ObjectCreate(0,"FIB21", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM150);
         ObjectSetString_(0,"FIB21", "FIB -250% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB21", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM150);
        }
      if(ObjectFind(0,"FIB122")!=0)
        {
         ObjectCreate(0,"FIB22", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP200);
         ObjectSetString_(0,"FIB22", "FIB +300% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB22", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP200);
        }
      if(ObjectFind(0,"FIB23")!=0)
        {
         ObjectCreate(0,"FIB23", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM200);
         ObjectSetString_(0,"FIB23", "FIB -300% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB23", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM200);
        }
      if(ObjectFind(0,"FIB124")!=0)
        {
         ObjectCreate(0,"FIB24", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP250);
         ObjectSetString_(0,"FIB24", "FIB +350% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB24", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP250);
        }
      if(ObjectFind(0,"FIB25")!=0)
        {
         ObjectCreate(0,"FIB25", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM250);
         ObjectSetString_(0,"FIB25", "FIB -350% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB25", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM250);
        }
      if(ObjectFind(0,"FIB126")!=0)
        {
         ObjectCreate(0,"FIB26", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP300);
         ObjectSetString_(0,"FIB26", "FIB +400% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB26", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBP300);
        }
      if(ObjectFind(0,"FIB27")!=0)
        {
         ObjectCreate(0,"FIB27", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM300);
         ObjectSetString_(0,"FIB27", "FIB -400% ", 8, "Arial", C'0,93,0');
        }
        else
        {
         ObjectMove(0,"FIB27", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_FibText), FIBM300);
        }
     } // Fibs Extra - End
   // Daily HI-LOW
   if (Show_Daily_HI_LOW==true)
     {
      if(ObjectFind(0,"DHIGH")!=0) 
        {
         ObjectCreate(0,"DHIGH", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_HI_LOW_TEXT), HI3);
         ObjectSetString_(0,"DHIGH", "Daily High ", 8, "Arial", Turquoise);
        }
        else
        {
         ObjectMove(0,"DHIGH", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_HI_LOW_TEXT), HI3);
        }
      if(ObjectFind(0,"DLOW")!=0)
        {
         ObjectCreate(0,"DLOW", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_HI_LOW_TEXT), LOW3);
         ObjectSetString_(0,"DLOW", "Daily Low ", 8, "Arial", Turquoise);
        }
        else
        {
         ObjectMove(0,"DLOW", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_HI_LOW_TEXT), LOW3);
        }
     } // Daily HI-LOW - End
   // Daily Open
   if (Show_Daily_OPEN==true || Using_OpenGraphics==true) //Tweak for Open Graphics - hymns
     {
      if(ObjectFind(0,"Open")!=0)
        {
         ObjectCreate(0,"Open", OBJ_TEXT, 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Daily_OPEN_TEXT), OPEN);
         ObjectSetString_(0,"Open", "                            OPEN "+ DoubleToString(OPEN,_Digits)+"", 8, "Arial Bold",YellowGreen);
        }
        else
        {
         ObjectMove(0,"Open", 0, iTime(NULL,PERIOD_CURRENT,SHIFT_Daily_OPEN_TEXT), OPEN);
        }
     } // Daily Open - End
   // Show Comments
   string PRICE,OPEN1,DAR;
   
   if (Show_DollyCOMMENTS==true)
     {
      string  NAME,BUYSTOP,BUYSTOP1,STOP,STOP1,PROFIT,PROFIT1,SELL,SELL1,STOP2,STOP3,PROFIT2,
      PROFIT3,BUYTARGT,PROFIT4,SELLTARGT,PROFIT5,TOTAL,TDR,LDR,TIME,
      TIME2,CHANGE,TDR1,LDR1,STOP4,STOP5;
//----
      double ChangeVal=Bid - iOpen(Symbol(),PERIOD_D1,0);
      NAME=IND_NAME;
      BUYSTOP=(DoubleToString (B1,_Digits));
      BUYSTOP1=(DoubleToString(B2,_Digits));
      STOP=(DoubleToString (S1,_Digits));
      STOP1=(DoubleToString(B1,_Digits));
      PROFIT=(DoubleToString ((B2),_Digits));
      PROFIT1=(DoubleToString (B3,_Digits));//((B2+(10*_Point)),_Digits)); 
      SELL=(DoubleToString (S1,_Digits));
      SELL1=(DoubleToString (S2,_Digits));
      STOP2=(DoubleToString (B1,_Digits));
      STOP3=(DoubleToString(S1,_Digits));
      PROFIT2=(DoubleToString ((S2),_Digits));
      PROFIT3=(DoubleToString (S3,_Digits));//((S2-(10*_Point)),_Digits));
      BUYTARGT=(DoubleToString(S2,_Digits));
      PROFIT4=(DoubleToString(B1,_Digits));
      STOP4=(DoubleToString(S3,_Digits));
      SELLTARGT=(DoubleToString(B2,_Digits));
      PROFIT5=(DoubleToString(S1,_Digits));
      STOP5=(DoubleToString(B3,_Digits));
      OPEN1=(DoubleToString(OPEN,_Digits));
      DAR=(DoubleToString(AV/_Point,0));
      TOTAL=(DoubleToString(HI2-LOW2,_Digits));
      TDR=(DoubleToString(P+AV,_Digits));
      LDR=(DoubleToString(P-AV,_Digits));
      TDR1=(DoubleToString(P+AV/2,_Digits));
      LDR1=(DoubleToString(P-AV/2,_Digits));
      TIME=(TimeToString(TimeLocal(),_Digits-6));
      TIME2=(TimeToString(TimeCurrent(),_Digits-6));
      PRICE=(DoubleToString(PriceSeries(PRICE_CLOSE,0),_Digits));//iMA(Symbol(),0,1,0,MODE_EMA,PRICE_CLOSE,0);        
      CHANGE=(DoubleToString(ChangeVal,_Digits));
//----
      ObjectDelete(0,"Dolly");
      Dolly( "Dolly", 22, 12,4);
      ObjectSetString_(0, "Dolly",""+ NAME +"", 11, "Arial", Red );
 
      ObjectDelete(0,"Dolly1");
      Dolly1( "Dolly1", 35, 12,4);
      ObjectSetString_(0, "Dolly1", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
      if(Auto_Signals==false )
        {
         ObjectDelete(0,"Dolly2");
         Dolly2( "Dolly2", 50, 12,4);
         ObjectSetString_(0, "Dolly2", "BUY ZONE", 9, "Arial", DeepSkyBlue );
         //
         ObjectDelete(0,"Dolly3");
         Dolly3( "Dolly3", 60, 12,4);
         ObjectSetString_(0, "Dolly3",",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,", 8, "Arial", Black );
         //
         ObjectDelete(0,"Dolly4");
         Dolly4( "Dolly4", 75, 12,4);
         ObjectSetString_(0, "Dolly4", "BUY STOP-1  "+Symbol()+ "  @ ", 9, "Arial", DodgerBlue );
         //
         ObjectDelete(0,"Dolly5");
         Dolly5( "Dolly5", 75, 12,4);
         ObjectSetString_(0, "Dolly5"," "+ BUYSTOP +"", 9, "Arial", DarkOrange );
         //
         ObjectDelete(0,"Dolly6");
         Dolly6( "Dolly6", 90, 12,4);
         ObjectSetString_(0, "Dolly6", "TP               and SL @    ", 9, "Arial", DodgerBlue);
         //
         ObjectDelete(0,"Dolly7");
         Dolly7( "Dolly7", 90, 12,4);
         ObjectSetString_(0, "Dolly7"," "+ BUYSTOP1 +"", 9, "Arial", YellowGreen);
         //
         ObjectDelete(0,"Dolly8");
         Dolly8( "Dolly8", 90, 12,4);
         ObjectSetString_(0, "Dolly8"," "+ STOP +"", 9, "Arial", CornflowerBlue );
         //
         ObjectDelete(0,"Dolly9");
         Dolly9( "Dolly9", 110, 12,4);
         ObjectSetString_(0, "Dolly9", "BUY STOP-2  "+Symbol()+ "  @ ",9, "Arial", LightBlue );
         //
         ObjectDelete(0,"Dolly10");
         Dolly10( "Dolly10", 110, 12,4);
         ObjectSetString_(0, "Dolly10"," "+ BUYSTOP1 +"", 9, "Arial", DarkOrange );
         //
         ObjectDelete(0,"Dolly11");
         Dolly11( "Dolly11", 125, 12,4);
         ObjectSetString_(0, "Dolly11",  "TP               and SL @    ", 9, "Arial", LightBlue);
         //
         ObjectDelete(0,"Dolly12");
         Dolly12( "Dolly12", 125, 12,4);
         ObjectSetString_(0, "Dolly12"," "+ PROFIT1 +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly13");
         Dolly13( "Dolly13", 125, 12,4);
         ObjectSetString_(0, "Dolly13", ""+ STOP1 +""  , 9, "Arial", Red );
         //
         ObjectDelete(0,"Dolly14");
         Dolly14( "Dolly14", 140, 12,4);
         ObjectSetString_(0, "Dolly14", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
         //
         ObjectDelete(0,"Dolly15");
         Dolly15( "Dolly15", 155, 12,4);
         ObjectSetString_(0, "Dolly15", "SELL ZONE"  , 9, "Arial",Maroon  );
         //
         ObjectDelete(0,"Dolly16");
         Dolly16( "Dolly16", 165, 12,4);
         ObjectSetString_(0, "Dolly16", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
         // 
         ObjectDelete(0,"Dolly17");
         Dolly17( "Dolly17", 180, 12,4);
         ObjectSetString_(0, "Dolly17", "SELL STOP-1  "+Symbol()+ "  to ", 9, "Arial", OrangeRed );
         //
         ObjectDelete(0,"Dolly18");
         Dolly18( "Dolly18", 180, 12,4);
         ObjectSetString_(0, "Dolly18"," "+ SELL +"", 9, "Arial",DarkOrange);
         //
         ObjectDelete(0,"Dolly19");
         Dolly19( "Dolly19", 195, 12,4);
         ObjectSetString_(0, "Dolly19",  "TP               and SL @    ", 9, "Arial", OrangeRed );
         //
         ObjectDelete(0,"Dolly20");
         Dolly20( "Dolly20", 195, 12,4);
         ObjectSetString_(0, "Dolly20"," "+ PROFIT2  +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly21");
         Dolly21( "Dolly21", 195, 12,4);
         ObjectSetString_(0, "Dolly21"," "+STOP1+ " " , 9, "Arial", Yellow );
         //
         ObjectDelete(0,"Dolly22");
         Dolly22( "Dolly22", 215, 12,4);
         ObjectSetString_(0, "Dolly22", "SELL STOP-2  "+Symbol()+ "  to ", 9, "Arial", OrangeRed );
         //
         ObjectDelete(0,"Dolly23");
         Dolly23( "Dolly23", 215, 12,4);
         ObjectSetString_(0, "Dolly23"," "+ SELL1 +"", 9, "Arial",DarkOrange);
         //
         ObjectDelete(0,"Dolly24");
         Dolly24( "Dolly24", 230, 12,4);
         ObjectSetString_(0, "Dolly24",  "TP               and SL @    ", 9, "Arial", OrangeRed );
         //
         ObjectDelete(0,"Dolly25");
         Dolly25( "Dolly25", 230, 12,4);
         ObjectSetString_(0, "Dolly25"," "+ PROFIT3 +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly26");
         Dolly26( "Dolly26", 230, 12,4);
         ObjectSetString_(0, "Dolly26"," "+STOP3+ " " , 9, "Arial", Yellow );
         //
         ObjectDelete(0,"Dolly27");
         Dolly27( "Dolly27", 245, 12,4);
         ObjectSetString_(0, "Dolly27", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
         //
         ObjectDelete(0,"Dolly28");
         Dolly28( "Dolly28", 260, 12,4);
         ObjectSetString_(0, "Dolly28", "POTENTIAL REVERSAL LEVELS"  , 9, "Arial",DarkSeaGreen);
         //
         ObjectDelete(0,"Dolly29");
         Dolly29( "Dolly29", 270, 12,4);
         ObjectSetString_(0, "Dolly29", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
         //
         ObjectDelete(0,"Dolly30");
         Dolly30( "Dolly30", 285, 12,4);
         ObjectSetString_(0, "Dolly30", "BEARISH CORRECTION : "  , 9, "Arial",DeepSkyBlue);
         //
         ObjectDelete(0,"Dolly31");
         Dolly31( "Dolly31", 300, 12,4);
         ObjectSetString_(0, "Dolly31", "BUY STOP "+Symbol()+ "  @ ", 9, "Arial", DodgerBlue );
         //
         ObjectDelete(0,"Dolly32");
         Dolly32( "Dolly32", 300, 12,4);
         ObjectSetString_(0, "Dolly32"," "+ BUYTARGT +"", 9, "Arial", DarkOrange );
         //
         ObjectDelete(0,"Dolly33");
         Dolly33( "Dolly33", 315, 12,4);
         ObjectSetString_(0, "Dolly33",  "TP               and SL @    ", 9, "Arial", DodgerBlue );
         //
         ObjectDelete(0,"Dolly34");
         Dolly34( "Dolly34", 315, 12,4);
         ObjectSetString_(0, "Dolly34"," "+ PROFIT4  +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly35");
         Dolly35( "Dolly35", 315, 12,4);
         ObjectSetString_(0, "Dolly35"," "+STOP4+ " " , 9, "Arial", Yellow );
         //
         ObjectDelete(0,"Dolly36");
         Dolly36( "Dolly36", 335, 12,4);
         ObjectSetString_(0, "Dolly36", "BULLISH CORRECTION : "  , 9, "Arial",Orange);
         //
         ObjectDelete(0,"Dolly37");
         Dolly37( "Dolly37", 350, 12,4);
         ObjectSetString_(0, "Dolly37", "SELL STOP "+Symbol()+ "  @ ", 9, "Arial",  OrangeRed );
         //
         ObjectDelete(0,"Dolly38");
         Dolly38( "Dolly38", 350, 12,4);
         ObjectSetString_(0, "Dolly38"," "+ SELLTARGT +"", 9, "Arial", DarkOrange );
         //
         ObjectDelete(0,"Dolly39");
         Dolly39( "Dolly39", 365, 12,4);
         ObjectSetString_(0, "Dolly39",  "TP               and SL @    ", 9, "Arial",  OrangeRed );
         //
         ObjectDelete(0,"Dolly40");
         Dolly40( "Dolly40", 365, 12,4);
         ObjectSetString_(0, "Dolly40"," "+ PROFIT5  +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly41");
         Dolly41( "Dolly41", 365, 12,4);
         ObjectSetString_(0, "Dolly41"," "+STOP5+ " " , 9, "Arial", Yellow );
         //
         ObjectDelete(0,"Dolly42");
         Dolly42( "Dolly42", 380, 12,4);
         ObjectSetString_(0, "Dolly42", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
         //
         ObjectDelete(0,"Dolly43");
         Dolly43( "Dolly43", 395, 12,4);
         ObjectSetString_(0, "Dolly43",  "DAILY OPEN", 9, "Arial",  Orange );
         //
         ObjectDelete(0,"Dolly44");
         Dolly44( "Dolly44", 395, 12,4);
         ObjectSetString_(0, "Dolly44"," "+ OPEN1 +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly45");
         Dolly45( "Dolly45", 410, 12,4);
         ObjectSetString_(0, "Dolly45","DAILY AVERAGE RANGE " , 9, "Arial",DarkSeaGreen);
         //
         ObjectDelete(0,"Dolly46");
         Dolly46( "Dolly46", 410, 12,4);
         ObjectSetString_(0, "Dolly46"," "+DAR+ " " , 9, "Arial", DarkOrange );
         //
         ObjectDelete(0,"Dolly47");
         Dolly47( "Dolly47", 420, 12,4);
         ObjectSetString_(0, "Dolly47", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );  
         // Market Price
         ObjectDelete(0,"Dolly48");
         Dolly48( "Dolly48", 435, 12,4);
         ObjectSetString_(0, "Dolly48","Price", 10, "Arial", Silver);
         //
         ObjectDelete(0,"Dolly49");
         Dolly49( "Dolly49", 435, 12,4);
         ObjectSetString_(0, "Dolly49"," "+PRICE+" ", 15, "Arial", Silver);
        }
      // Today Market Change
      ObjectDelete(0,"Dolly50");
      Dolly50( "Dolly50", 10, 12,4);
      ObjectSetString_(0, "Dolly50","Change", 10, "Arial", Silver);
      //
      ObjectDelete(0,"Dolly51");
      Dolly51( "Dolly51", 18, 12,4);
      if (ChangeVal==0)
        {
         ObjectSetString_(0, "Dolly51","+"+CHANGE+" ", 15, "Arial", Gold);
        }
        else if (ChangeVal > 0) 
        {
            ObjectSetString_(0, "Dolly51","+"+CHANGE+" ", 15, "Arial", Lime);
           }
           else 
           {
            ObjectSetString_(0, "Dolly51"," "+CHANGE+" ", 15, "Arial", Red);
           }
     } // Show Comment - End
   if(Auto_Signals==true )
     {
      if (Show_DollyCOMMENTS==true)
        {
         ObjectDelete(0,"Dolly42");
         Dolly42( "Dolly42", 98, 12,4);
         ObjectSetString_(0, "Dolly42", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );
         //
         ObjectDelete(0,"Dolly43");
         Dolly43( "Dolly43", 112, 12,4);
         ObjectSetString_(0, "Dolly43",  "DAILY OPEN", 9, "Arial",  Orange );
         //
         ObjectDelete(0,"Dolly44");
         Dolly44( "Dolly44", 112, 12,4);
         ObjectSetString_(0, "Dolly44"," "+ OPEN1 +"", 9, "Arial", YellowGreen );
         //
         ObjectDelete(0,"Dolly45");
         Dolly45( "Dolly45", 125, 12,4);
         ObjectSetString_(0, "Dolly45","DAILY AVERAGE RANGE " , 9, "Arial",DarkSeaGreen);
         //
         ObjectDelete(0,"Dolly46");
         Dolly46( "Dolly46", 125, 12,4);
         ObjectSetString_(0, "Dolly46"," "+DAR+ " " , 9, "Arial", DarkOrange );
         //
         ObjectDelete(0,"Dolly47");
         Dolly47( "Dolly47", 134, 12,4);
         ObjectSetString_(0, "Dolly47", ",,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,"  , 8, "Arial", Black );    
         //
         ObjectDelete(0,"Dolly48");
         Dolly48( "Dolly48", 148, 12,4);
         ObjectSetString_(0, "Dolly48","Price", 10, "Arial", Silver);
         //
         ObjectDelete(0,"Dolly49");
         Dolly49( "Dolly49", 148, 12,4);
         ObjectSetString_(0, "Dolly49"," "+PRICE+" ", 15, "Arial", Silver);
        }
      }
    }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ObjectSetString_(long chart_ID,string name,string text,int textsize,string font,color Color)
  {
//----
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,textsize);
//----
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly( string Text, int xOffset, int yOffset,int iCorner) //TITLE
  {  
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20);
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly1( string Text, int xOffset, int yOffset,int iCorner) //LINE
  {  
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly2( string Text, int xOffset, int yOffset,int iCorner)//Buy Zone
  {
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly3( string Text, int xOffset, int yOffset,int iCorner) //LINE
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly4( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly5( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 170 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly6( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly7( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 35 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly8( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 140 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly9( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly10( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 170 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly11( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly12( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 35 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly13( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 140 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly14( string Text, int xOffset, int yOffset,int iCorner) //Line
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20);
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly15( string Text, int xOffset, int yOffset,int iCorner) //SELL ZONE
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly16( string Text, int xOffset, int yOffset,int iCorner) //LINE
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly17( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly18( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 170 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly19( string Text, int xOffset, int yOffset,int iCorner) // Line
  {
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly20( string Text, int xOffset, int yOffset,int iCorner) // 1st SELL 
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 35 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly21( string Text, int xOffset, int yOffset,int iCorner) // 1st SELL SL
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 140 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly22( string Text, int xOffset, int yOffset,int iCorner) // 2nd SELL
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly23( string Text, int xOffset, int yOffset,int iCorner) // 2nd SELL
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 170 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly24( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly25( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 35);
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly26( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 140 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly27( string Text, int xOffset, int yOffset,int iCorner)//LINE 
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly28( string Text, int xOffset, int yOffset,int iCorner) // POTENTIAL 
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly29( string Text, int xOffset, int yOffset,int iCorner) // LINE
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly30( string Text, int xOffset, int yOffset,int iCorner) //BEARISH CORR
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly31( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly32( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 170 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly33( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly34( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 35 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly35( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 140 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly36( string Text, int xOffset, int yOffset,int iCorner) //BULLISH CORR
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly37( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly38( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 170 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly39( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly40( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 35 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly41( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 140 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly42( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly43( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly44( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 100 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly45( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly46( string Text, int xOffset, int yOffset,int iCorner)
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 160 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly47( string Text, int xOffset, int yOffset,int iCorner) //Line 
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly48( string Text, int xOffset, int yOffset,int iCorner) //Price Text 
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 20 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly49( string Text, int xOffset, int yOffset,int iCorner) //Price Value
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 50 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly50( string Text, int xOffset, int yOffset,int iCorner) //Change Text
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 850 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dolly51( string Text, int xOffset, int yOffset,int iCorner) //Change Value 
  { 
   ObjectCreate(0,Text,OBJ_LABEL         , 0, 0, 0 );
   ObjectSetInteger(0,Text,OBJPROP_CORNER    , iCorner);
   ObjectSetInteger(0,Text,OBJPROP_XDISTANCE , 885 );
   ObjectSetInteger(0,Text,OBJPROP_YDISTANCE , xOffset );
   ObjectSetInteger(0,Text,OBJPROP_BACK      , true );
  }
//+------------------------------------------------------------------+   
//| Получение значения ценовой таймсерии                             |
//+------------------------------------------------------------------+ 
double PriceSeries
(
 ENUM_APPLIED_PRICE applied_price,// Ценовая константа
 uint   bar// Индекс сдвига относительно текущего бара на указанное количество периодов назад или вперёд).
 )
//PriceSeries(applied_price, bar, open, low, high, close)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   switch(applied_price)
     {
      //---- Ценовые константы из перечисления ENUM_APPLIED_PRICE
      case  PRICE_CLOSE: return(iClose(NULL,PERIOD_CURRENT,bar));
      case  PRICE_OPEN: return(iOpen(NULL,PERIOD_CURRENT,bar));
      case  PRICE_HIGH: return(iHigh(NULL,PERIOD_CURRENT,bar));
      case  PRICE_LOW: return(iLow(NULL,PERIOD_CURRENT,bar));
      case  PRICE_MEDIAN: return((iHigh(NULL,PERIOD_CURRENT,bar)+iLow(NULL,PERIOD_CURRENT,bar))/2.0);
      case  PRICE_TYPICAL: return((iClose(NULL,PERIOD_CURRENT,bar)+iHigh(NULL,PERIOD_CURRENT,bar)+iLow(NULL,PERIOD_CURRENT,bar))/3.0);
      case  PRICE_WEIGHTED: return((2*iClose(NULL,PERIOD_CURRENT,bar)+iHigh(NULL,PERIOD_CURRENT,bar)+iLow(NULL,PERIOD_CURRENT,bar))/4.0);
      }
//----
  return(iClose(NULL,PERIOD_CURRENT,bar));
  }
//+------------------------------------------------------------------+