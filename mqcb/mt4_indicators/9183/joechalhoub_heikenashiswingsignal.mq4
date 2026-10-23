//+------------------------------------------------------------------+
//|                            JoeChalhoub_HeikenAshiSwingSignal.mq4 |
//|                                                  www.Rpchost.com |
//|                                            webmaster@rpchost.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2009, JoeChalhoub_HeikenAshiSwingSignal"
#property link      "webmaster@rpchost.com"
//----
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1 LimeGreen
#property indicator_color2 FireBrick
#property indicator_color3 Green
#property indicator_color4 Red


#include <WinUser32.mqh>

extern string    Symbol1       = "";
extern string    Symbol2       = "";


extern int TimeFrame=0;

extern int HzShift   =0;
extern int mtfHzShift=0;
extern int VrtShift  =0;
extern int maxbars   =2000;

int ticket;

extern string TimeFrames="M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN|0-CurrentTF";

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

double HeikenLowH1,HeikenHighH1,HeikenOpenH1,HeikenCloseH1;
double HeikenLowM5,HeikenHighM5,HeikenOpenM5,HeikenCloseM5;

double HeikenCloseH4_1,HeikenCloseH4_0;
double HeikenOpenH4_1,HeikenOpenH4_0;

double HeikenLowH1shift,HeikenHighH1shift,HeikenOpenH1shift,HeikenCloseH1shift;
double HeikenLowH4shift,HeikenHighH4shift;
double HeikenLowM5shift,HeikenHighM5shift,HeikenOpenM5shift,HeikenCloseM5shift;

double HeikenCloseH4_1shift,HeikenCloseH4_0shift;
double HeikenOpenH4_1shift,HeikenOpenH4_0shift;

string CurrShift;

//---- input parameters
extern string    separator1="*** OSMA Settings ***";
extern int       fastEMA = 12;
extern int       slowEMA = 26;
extern int       signal=9;
extern string    separator2="*** Indicator Settings ***";
extern bool      drawDivergenceLines=true;
extern bool      displayAlert=true;
//---- buffers

extern int period=10;
extern int price=0; // 0 or other = (H+L)/2

extern bool Mode_Fast=False;
extern bool Signals=False;
extern int MA1period=9,MA2period=45;
extern string TypeHelp="SMA- 0, EMA - 1, SMMA - 2, LWMA- 3";
extern string TypeHelp2="John Hyden settings TypeMA1=0, TypeMA2=3";
extern int TypeMA1=0;
extern int TypeMA2=3;


static int cc,cc1;
static string strH4Trend;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+


//---- buffers
double upOsMA[500];
double downOsMA[500];
double bullishDivergence[500];
double bearishDivergence[500];

double bullishDiverg[500];
double bearishDiverg[500];

static bool isBuy=false;
static bool isSell=false;

bool isBuySet,isSellSet;

double OsMA[500];

double upMA[500];
double downMA[500];
double bullishDivergenceMA[500];
double bearishDivergenceMA[500];

double point;

double bullishDivergenceMADeviation[500];
double bearishDivergenceMADeviation[500];

double MA[500];

double SLShort,SLLong,strTargetLong,strTargetShort,C0,C1,C2;
string Target,ask,SL,bid,strSell,strBuy;

extern bool    Debug=false;

#define  CHART_CMD_UPDATE_DATA            33324



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

#import "wininet.dll"

int InternetAttemptConnect(int x);
int InternetOpenA(string sAgent,int lAccessType,
                  string sProxyName="",string sProxyBypass="",
                  int lFlags=0);
int InternetOpenUrlA(int hInternetSession,string sUrl,
                     string sHeaders="",int lHeadersLength=0,
                     int lFlags=0,int lContext=0);
int InternetReadFile(int hFile,int &sBuffer[],int lNumBytesToRead,
                     int &lNumberOfBytesRead[]);
int InternetCloseHandle(int hInet);
#import

extern bool lines    = true;        // показывать вертикальные линии в моменты выхода новостей
extern bool texts    = true;        // показывать текстовые надписи с описаниями новостей
extern bool comments = true;        // показывать список ближайших будущих и прошедших новостей
extern int total_in_list = 10;      // количество новостей в списке

extern bool high     = true;        // показывать важные новости
extern bool medium   = true;        // показывать новости средней важности
extern bool low      = true;        // показывать новости малой важности

extern int update=15;             // обновлять список новостей каждые 15 минут

extern bool auto = true;            // авто-выбор новостей, подходящих для валютной пары графика
extern bool eur = true;             // показывать новости для определенных валют
extern bool usd = true;
extern bool jpy = true;
extern bool gbp = true;
extern bool chf = true;
extern bool cad = true;
extern bool aud = true;
extern bool nzd = true;

extern color high_color    = Maroon;         // цвет важных новостей
extern color medium_color  = Sienna;         // цвет обычных новостей
extern color low_color     = DarkSlateGray;  // цвет незначительных новостей

extern bool russian=true;         // использовать файл перевода для руссификации новостей

extern int server_timezone = 2;     // часовой пояс сервера (Alpary - GMT+2)
extern int show_timezone   = 4;     // показывать время для часового пояса (Москва - GMT+4)

extern bool alerts = true;          // предупреждать о выходе новостей звуковыми сигналами
extern int  alert_before = 5;       // предупреждать за 5 минут до выхода новостей
extern int  alert_every  = 30;      // звуковые сигналы каждые 30 секунд

datetime NextTime;

datetime TTime[1000];

// -----------------------------------------------------------------------------------------------------------------------------
int TotalNews=0;
string News[1000][10];
datetime LastUpdate=0;
int NextNewsLine=0;
int LastAlert=0;
string Translate[1000][2];
int TotalTranslate=0;

static string str;

string Filter1 = "";
string Filter2 = "";

static datetime time;

static bool resume=false;

double LPeak,LTrough;
// -----------------------------------------------------------------------------------------------------------------------------

int init()
  {

//---- indicators
// SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
// SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexStyle(5,DRAW_ARROW);
   SetIndexStyle(6,DRAW_ARROW);
   SetIndexStyle(7,DRAW_NONE);
//  SetIndexStyle(8, DRAW_ARROW);
//  SetIndexStyle(9, DRAW_ARROW);


//----   SetIndexStyle(3, DRAW_LINE, EMPTY, 2, Violet);

//SetIndexBuffer(0, upMA);
//SetIndexBuffer(1, downMA);
   SetIndexBuffer(2,bullishDivergenceMA);
   SetIndexBuffer(3,bearishDivergenceMA);
   SetIndexBuffer(4,MA);
   SetIndexBuffer(5,bullishDivergence);
   SetIndexBuffer(6,bearishDivergence);
//SetIndexBuffer(7, OsMA);
//  SetIndexBuffer(8, SELLMA);
// SetIndexBuffer(9, BUYMA);


//----   
   SetIndexArrow(0,233);
   SetIndexArrow(1,234);

   SetIndexArrow(5,233);
   SetIndexArrow(6,234);

   SetIndexArrow(8,233);
   SetIndexArrow(9,234);

   SetIndexArrow(10,233);
   SetIndexArrow(11,234);

   SetIndexArrow(15,233);
   SetIndexArrow(16,234);

   ObjectCreate("Symbol1",OBJ_LABEL,0,0,0,0,0);
   ObjectCreate("Symbol2",OBJ_LABEL,0,0,0,0,0);

//----

//---- indicators


   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i=ObjectsTotal()-1; i>=0; i--)
     {
      string label=ObjectName(i);
      if(StringSubstr(label,0,14)!="DivergenceLine")
         continue;
      ObjectDelete(label);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+



int start()
  {

   string Symbol_1 = " † ";
   string Symbol_2 = "JOE CHALHOUB - Rpchost.com";

   ObjectSetText("Symbol1",Symbol_1,"7","Arial Black",Lime);
   ObjectSet("Symbol1",OBJPROP_XDISTANCE,3);
   ObjectSet("Symbol1",OBJPROP_YDISTANCE,30);
   ObjectSet("Symbol1",OBJPROP_COLOR,Blue);
   ObjectSet("Symbol1",OBJPROP_CORNER,"111");

   ObjectSetText("Symbol2",Symbol_2,"7","Arial Black",Lime);
   ObjectSet("Symbol2",OBJPROP_XDISTANCE,3);
   ObjectSet("Symbol2",OBJPROP_YDISTANCE,50);
   ObjectSet("Symbol2",OBJPROP_COLOR,Red);
   ObjectSet("Symbol2",OBJPROP_CORNER,"111");

   if(Symbol()=="GBPUSD" || Symbol()=="EURUSD")
      point=0.0001;
   if(Symbol()=="USDJPY")
      point=0.01;

   int counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit--;

   CalculateIndicator(limit);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| M5 Indicator                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {

   for(int i=2000; i>=0; i--)
     {
      setSignals(i);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setSignals(int shift)
  {
//SSSS
   if(shift<2000)
     {
      setHeiken();

      int iH0 = iBarShift(Symbol(),PERIOD_H1,iTime(Symbol(),PERIOD_M5,shift),false);
      int iH1 = iBarShift(Symbol(),PERIOD_H1,iTime(Symbol(),PERIOD_M5,shift),false)+1;
      int iH4 = iBarShift(Symbol(),PERIOD_H4,iTime(Symbol(),PERIOD_M5,shift),false);

      HeikenCloseH1= iCustom(NULL,PERIOD_H1,"Heiken Ashi",3,1);
      HeikenOpenH1 = iCustom(NULL,PERIOD_H1,"Heiken Ashi",2,1);

      HeikenCloseM5= iCustom(NULL,PERIOD_H1,"Heiken Ashi",3,0);
      HeikenOpenM5 = iCustom(NULL,PERIOD_H1,"Heiken Ashi",2,0);

      HeikenCloseH4_0= iCustom(NULL,PERIOD_H4,"Heiken Ashi",3,0);
      HeikenOpenH4_0 = iCustom(NULL,PERIOD_H4,"Heiken Ashi",2,0);


      HeikenCloseH1shift= iCustom(NULL,PERIOD_H1,"Heiken Ashi",3,iH1);
      HeikenOpenH1shift = iCustom(NULL,PERIOD_H1,"Heiken Ashi",2,iH1);

      HeikenCloseM5shift= iCustom(NULL,PERIOD_H1,"Heiken Ashi",3,iH0);
      HeikenOpenM5shift = iCustom(NULL,PERIOD_H1,"Heiken Ashi",2,iH0);

      HeikenCloseH4_0shift= iCustom(NULL,PERIOD_H4,"Heiken Ashi",3,iH4);
      HeikenOpenH4_0shift = iCustom(NULL,PERIOD_H4,"Heiken Ashi",2,iH4);

      HeikenCloseH4_1shift= iCustom(NULL,PERIOD_H4,"Heiken Ashi",3,iH4+1);
      HeikenOpenH4_1shift = iCustom(NULL,PERIOD_H4,"Heiken Ashi",2,iH4+1);


      if(HeikenCloseH1shift<HeikenOpenH1shift)
        {
         HeikenLowH1shift  = iCustom(NULL,PERIOD_H1,"Heiken Ashi",1,iH1);
         HeikenHighH1shift = iCustom(NULL,PERIOD_H1,"Heiken Ashi",0,iH1);
        }
      if(HeikenCloseH1shift>HeikenOpenH1shift)
        {
         HeikenLowH1shift  = iCustom(NULL,PERIOD_H1,"Heiken Ashi",0,iH1);
         HeikenHighH1shift = iCustom(NULL,PERIOD_H1,"Heiken Ashi",1,iH1);
        }

      if(HeikenCloseH4_1shift<HeikenOpenH4_1shift)
        {
         HeikenLowH4shift  = iCustom(NULL,PERIOD_H4,"Heiken Ashi",1,iH4+1);
         HeikenHighH4shift = iCustom(NULL,PERIOD_H4,"Heiken Ashi",0,iH4+1);
        }
      if(HeikenCloseH4_1shift>HeikenOpenH4_1shift)
        {
         HeikenLowH4shift  = iCustom(NULL,PERIOD_H4,"Heiken Ashi",0,iH4+1);
         HeikenHighH4shift = iCustom(NULL,PERIOD_H4,"Heiken Ashi",1,iH4+1);
        }



      if(isBuy==true && shift>1)
        {
         DrawPriceTrendLine(Time[shift],Time[shift],Low[shift],High[shift],Green,STYLE_SOLID);
        }
      if((isBuy==true) && shift<=1)
        {
         DrawPriceTrendLine(Time[1],Time[1],Low[1],High[1],Green,STYLE_SOLID);
         DrawPriceTrendLine(Time[0],Time[0],Low[0],High[0],Green,STYLE_SOLID);
        }

      if(isSell==true && shift>1)
        {
         DrawPriceTrendLine(Time[shift],Time[shift],High[shift],High[shift],Red,STYLE_SOLID);
        }
      if((isSell==true) && shift<=1)
        {
         DrawPriceTrendLine(Time[1],Time[1],High[1],High[1],Red,STYLE_SOLID);
         DrawPriceTrendLine(Time[0],Time[0],High[0],High[0],Red,STYLE_SOLID);
        }
     }

//CLOSE BUY  

   if(iClose(Symbol(),PERIOD_M5,shift+1)<HeikenLowH4shift)
     {
      isBuy=false;
     }

//CLOSE SELL  

   if(iClose(Symbol(),PERIOD_M5,shift+1)>HeikenHighH4shift)
     {
      isSell=false;
     }

   H4Trend(shift);

//BUY
   if(strH4Trend=="up" && iClose(Symbol(),PERIOD_M5,shift+1)<HeikenOpenH1shift && HeikenCloseH1shift>HeikenOpenH1shift)
     {
      isBuy=true;
      isSell=false;
      DrawPriceTrendLine(Time[shift+1],Time[shift+1],Low[shift+1],High[shift+1],Green,STYLE_SOLID);
     }

//SELL 
   if(isBuy==false && strH4Trend=="down" && iClose(Symbol(),PERIOD_M5,shift+1)>HeikenOpenH1shift && HeikenCloseH1shift<HeikenOpenH1shift)
     {
      isBuy=false;
      isSell=true;
      DrawPriceTrendLine(Time[shift+1],Time[shift+1],High[shift+1],High[shift+1],Red,STYLE_DASHDOTDOT);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1,datetime x2,double y1,
                        double y2,color lineColor,double style)
  {
   string label="DivergenceLine2.1# "+DoubleToStr(x1,0);
//ObjectDelete(label);
   ObjectCreate(label,OBJ_ARROW,0,x2,y1,x1,y2,0,0);

   ObjectSet(label,OBJPROP_COLOR,lineColor);

   ObjectSet(label,OBJPROP_SCALE,500);

   ObjectSet(label,OBJPROP_RAY,true);
   ObjectSet(label,OBJPROP_WIDTH,2);

   if(lineColor==Red)
      ObjectSet(label,OBJPROP_ARROWCODE,234);
   if(lineColor==Green)
      ObjectSet(label,OBJPROP_ARROWCODE,233);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void H4Trend(int shift)
  {

   int iH0=iBarShift(Symbol(),PERIOD_H4,iTime(Symbol(),PERIOD_M5,shift),false);

   HeikenCloseH4_1= iCustom(NULL,PERIOD_H4,"Heiken Ashi",3,iH0+1);
   HeikenOpenH4_1 = iCustom(NULL,PERIOD_H4,"Heiken Ashi",2,iH0+1);

   HeikenCloseH4_0= iCustom(NULL,PERIOD_H4,"Heiken Ashi",3,iH0);
   HeikenOpenH4_0 = iCustom(NULL,PERIOD_H4,"Heiken Ashi",2,iH0);


   if(iClose(Symbol(),PERIOD_M5,shift+1)<HeikenLowH4shift)
     {
      strH4Trend="down";
     }
   else if(iClose(Symbol(),PERIOD_M5,shift+1)>HeikenHighH4shift)
     {
      strH4Trend="up";
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setHeiken()
  {
   return;
   datetime TimeArray[];
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);

   int   i,limit,y=0,counted_bars=IndicatorCounted();
   if(counted_bars < 0)  return;
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+TimeFrame/Period();

   int size=ArraySize(TimeArray);
   ArrayResize(ExtMapBuffer1,size);
   ArrayResize(ExtMapBuffer2,size);
   ArrayResize(ExtMapBuffer3,size);
   ArrayResize(ExtMapBuffer4,size);

   for(i=0,y=0;i<limit;i++)
     {

      if(y<ArraySize(TimeArray))
        {
         if(Time[i]<TimeArray[y]) y++;
        }

/***********************************************************   
   Add your main indicator loop below.  You can add the full
      indicator code or you can just reference an existing
      indicator with its iValue or iCustom.
   Rule 1:  Add extern inputs above for all neccesary values   
   Rule 2:  Use 'TimeFrame' for the indicator time frame
   Rule 3:  Use 'y' for your indicator's shift value
 **********************************************************/

      ExtMapBuffer1[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",0,y)+VrtShift*Point;
      ExtMapBuffer2[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",1,y)+VrtShift*Point;
      ExtMapBuffer3[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",2,y)+VrtShift*Point;
      ExtMapBuffer4[i]=iCustom(NULL,TimeFrame,"Heiken Ashi",3,y)+VrtShift*Point;
     }

  }
//+------------------------------------------------------------------+
