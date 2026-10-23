//+------------------------------------------------------------------+
//| FractalZigZagNoRepaint.mq4
//| Copyright © Pointzero-indicator.com
//| Shows ZigZag signals without repainting, ever.
//+------------------------------------------------------------------+
#property copyright "Copyright © Gad Benisty"
#property version   "1.22"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 clrRed
#property indicator_color2 clrBlue
#property indicator_color3 clrRed
#property indicator_color4 clrBlue
#property indicator_color5 clrCrimson
#property indicator_color6 clrCrimson

//#define IName          "Fractal ZigZag No-Repaint"
#define ZZBack         1
#define ExpertName         "Ofir"
#define MinOn
//+------------------+
// INCLUDE OFIR BLUE |
//+------------------+
#include <OfirBlueAPI.mqh>

string OPRX              = ".";
string vPrfx=".Ofir";
//-------------------------------
// Input parameters
//-------------------------------
extern int nbRetrace=3; //Number of candles
extern bool SendToOfir=false; //Send signal to Ofir
enum ENUM_FILTER
  {
   None, //None
   Pivot, // Pivot
   Ofir // Ofir
  };

extern ENUM_FILTER FilterType = None; //Filter mode
extern bool CalculateOnBarClose    = true;
bool useZigZAg=false;
extern int  ZZDepth                = 12;
extern int  ZZDev                  = 5;
extern bool ShowSL=true;
extern bool pushAlerts = false;
extern bool isDebug = false;
static datetime   dPrevtime = 0;
bool isLoaded = false;
//-------------------------------
// Buffers
//-------------------------------
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double SellBuffer[];
double BuyBuffer[];
double SLBuffer[];
double TestBuffer[];
double EntryBuffer[];

//-------------------------------
// Internal variables
//-------------------------------
string OfirSignalDir="Ofir";

// Fractals value -mine-
double fr_resistance       = 0;
double fr_support          = EMPTY_VALUE;
bool fr_resistance_change  = EMPTY_VALUE;
bool fr_support_change     = EMPTY_VALUE;

// zzvalues
double zzhigh = 0;
double zzlow = 0;

// Offset in chart
//int    fractalShift;
//int gvarAccount = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //+--------------------------+
   // INITIALIZE OFIR BLUE API  |
   //+--------------------------+
   blue.Init("OfirSampleIndicator",BlueToken); //Put your indicator name & the Ofir Blue token given to each user
   
   isLoaded = false;
   OPRX="or";
   ObjectsRemoveAll();
//SendNotification("Init");
// Arrows
   if(IsTesting())
      vPrfx=".Test";
   MathSrand(GetTickCount());
   initBuffers();
    
   return(0);
  }

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsRemoveAll();
   EventKillTimer();
   return(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
// Start, limit, etc..
   startRetrace();

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_KEYDOWN)
     {
      //Print(lparam);
      if(lparam==83)
        {
         blue.SendChart("Sell EURUSD",clrPowderBlue);
        }

     }
  }
//+------------------------------------------------------------------+
//| Custom code ahead
//+------------------------------------------------------------------+

/**
* Returns fractal resistance
* @param int shift
*/
void startRetrace()
  {
   int Start = 0;
   int limit;
   int counted_bars = IndicatorCounted();

   double lastSignal=0;
   string cAlert;
   string signalRef;
   int candleType=-1;
   static int nc=0;
   double sl=0,tp=0,gap=0,tp1=0,tp2=0;
   double reward=2;
   double reward2=3.5;
   bool send2Ofir=false;

   if(counted_bars < 0)
      return;

// do not check repeated bars
   limit = Bars - 1 - counted_bars;

// Check if ignore bar 0
   if(CalculateOnBarClose == true)
      Start = 1;

// Check the signal foreach bar from past to present
   send2Ofir=(isLoaded && BlueToken != "");
   for(int i = limit; i >= Start; i--)
     {
      candleType=getRetraceCandleType(i);
      if(candleType==OP_BUY)
        {
         nc++;
         BuyBuffer[i]=iClose(NULL,0,i);
         EntryBuffer[i]=iClose(NULL,0,i);
         setArrow("Entry Point",iTime(Symbol(),0,i),BuyBuffer[i],nc);
         gap=MathAbs(BuyBuffer[i]-iHigher(NULL,0,i));
         sl=BuyBuffer[i]-gap;
         SLBuffer[i]=sl;
         tp=BuyBuffer[i]+reward*gap;
         tp2=BuyBuffer[i]+reward2*gap;
         setArrow("SL Point",iTime(Symbol(),0,i),sl,nc,clrRed);
         setArrow("TP1 Point",iTime(Symbol(),0,i),tp,nc,clrGreen);
         setArrow("TP2 Point",iTime(Symbol(),0,i),tp2,nc,clrGreen);
        }
      if(candleType==OP_SELL)
        {
         SellBuffer[i]=iClose(NULL,0,i);
         EntryBuffer[i]=iClose(NULL,0,i);
         nc++;
         setArrow("Entry Point",iTime(Symbol(),0,i),SellBuffer[i],nc);
         gap=MathAbs(SellBuffer[i]-iLower(NULL,0,i));
         sl=SellBuffer[i]+gap;
         SLBuffer[i]=sl;
         tp=SellBuffer[i]-reward*gap;
         tp2=SellBuffer[i]-reward2*gap;
         setArrow("SL Point",iTime(Symbol(),0,i),sl,nc,clrRed);
         setArrow("TP1 Point",iTime(Symbol(),0,i),tp,nc,clrGreen);
         setArrow("TP2 Point",iTime(Symbol(),0,i),tp2,nc,clrGreen);
        }
      
      if(candleType>=0 && send2Ofir)
        {
          //+--------------------------+
          // SEND SIGNAL TO OFIR BLUE  |
          //+--------------------------+
         blue.SendSignal(candleType,Symbol(),0,sl,tp,tp2,0,"Don't wait too long...");
         
         
          //+---------------------------------+
          // SEND CUSTOM MESSAGE TO OFIR BLUE |
          //+---------------------------------+
         blue.SendMessage(StringFormat("%s %s %s at %f SL:%f TP:%f",strOpType(candleType),blueFlag(blueSimplify(Symbol())),blueSimplify(Symbol()),getMP(candleType,Symbol()),sl,tp,tp2));

          //+--------------------------+
          // SEND CHART TO OFIR BLUE   |
          //+--------------------------+
         blue.SendChart(strOpType(candleType)+" "+blueSimplify(Symbol()),(isOdd(candleType))?clrPowderBlue:clrDarkSalmon);
         
         
         send2Ofir=false;
        }
     }
   isLoaded=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iHigher(string s,int period,int n,int nCount=3)
  {
   double max=iHigh(s,0,n);
   for(int i=1; i<=nCount; i++)
     {
      max=MathMax(max,iHigh(s,0,n+i));
     }
   return(max);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLower(string s,int period,int n,int nCount=3)
  {
   double min=iLow(s,0,n);
   for(int i=1; i<nCount; i++)
     {
      min=MathMin(min,iLow(s,0,n+i));
     }
   return(min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void setArrow(string name,datetime time=0,double price=0,int nc=0,color InpColor=clrBlue)
  {
//string InpName=(type==OP_SELL)?"Signal_Sell":"Signal_Buy";

   ENUM_LINE_STYLE   InpStyle=STYLE_SOLID;
   int               InpWidth=1;
   bool              InpBack=false;
   if(nc==0)
      nc=MathRand();
   name+=(string)nc;
   ArrowLeftPriceCreate(0,OPRX+name,0,time,price,InpColor,
                        InpStyle,InpWidth,InpBack,true,false,0,name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void initBuffers()
  {
   SetIndexStyle(0, DRAW_ARROW, STYLE_DOT, 1);
   SetIndexArrow(0, 218);
   SetIndexBuffer(0, ExtMapBuffer1);
   SetIndexStyle(1, DRAW_ARROW, STYLE_DOT, 1);
   SetIndexArrow(1, 217);
   SetIndexBuffer(1, ExtMapBuffer2);
   SetIndexStyle(2, DRAW_ARROW, STYLE_DOT, 5);
   SetIndexArrow(2, 234);
   SetIndexBuffer(2, SellBuffer);
   SetIndexStyle(3, DRAW_ARROW, STYLE_DOT, 5);
   SetIndexArrow(3, 233);
   SetIndexBuffer(3, BuyBuffer);
   SetIndexStyle(4, DRAW_ARROW, STYLE_DOT, 1);
   SetIndexArrow(4, 110);
   SetIndexBuffer(4, SLBuffer);
   SetIndexStyle(5, DRAW_ARROW, STYLE_DOT, 1);
   SetIndexArrow(5, 110);
   SetIndexBuffer(5, TestBuffer);
   SetIndexStyle(6, DRAW_ARROW, STYLE_DOT, 1);
   SetIndexArrow(6, 116);
   SetIndexBuffer(6, EntryBuffer);


// Data window
   IndicatorShortName(ExpertName);
   SetIndexLabel(0, "Fractal Up");
   SetIndexLabel(1, "Fractal Down");
   SetIndexLabel(2, "Sell");
   SetIndexLabel(3, "Buy");
   SetIndexLabel(4, "SL");
   SetIndexLabel(5, "Test");

// Copyright
//Comment("Copyright © http://www.pointzero-indicator.com");


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckTrend(string s,int type)
  {
   double pivot,mp;
   switch(FilterType)
     {
      case None:
         return(true);
         break;
      case Pivot:
         pivot=GlobalVariableGet(vPrfx+s+"Pivot");
         mp=getMP(type,s);
         Print("Check Trend mp=",mp," pivot=",pivot," type=",strOpType(type));
         if(pivot>0)
           {
            if(isOdd(type) && mp>pivot)
               return(true);
            if(!isOdd(type) && mp<pivot)
               return(true);
           }
         break;
     }
   return(false);
  }
//+------------------------------------------------------------------+
void ObjectsRemoveAll(string prefix="",string cb="")
  {
   ObjectsDeleteAll(0,OPRX+prefix,-1,-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getRetraceCandleType(int i,string s=NULL)
  {
   int ret=-1;
//ret=OP_BUY;
   if(iClose(s,0,i)<iOpen(s,0,i) && iClose(s,0,i+1)<iOpen(s,0,i+1) && iClose(s,0,i+2)<iOpen(s,0,i+2) && iClose(s,0,i+3)>iOpen(s,0,i+3))
     {
      ret=OP_BUY;
     }
   if(iClose(s,0,i)>iOpen(s,0,i) && iClose(s,0,i+1)>iOpen(s,0,i+1) && iClose(s,0,i+2)>iOpen(s,0,i+2) && iClose(s,0,i+3)<iOpen(s,0,i+3))
     {
      ret=OP_SELL;
     }
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArrowLeftPriceCreate(const long            chart_ID=0,        // chart's ID
                          const string          name="LeftPrice",  // price label name
                          const int             sub_window=0,      // subwindow index
                          datetime              time=0,            // anchor point time
                          double                price=0,           // anchor point price
                          const color           clr=clrRed,        // price label color
                          const ENUM_LINE_STYLE style=STYLE_SOLID, // border line style
                          const int             width=1,           // price label size
                          const bool            back=false,        // in the background
                          const bool            selection=true,    // highlight to move
                          const bool            hidden=true,       // hidden in the object list
                          const long            z_order=0,         // priority for mouse click
                          const string            tooltip="\n")
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create a price label
   ObjectDelete(chart_ID,name);
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_LEFT_PRICE,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create the left price label! Error code = ",GetLastError());
      return(false);
     }
//--- set the label color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the label size
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getMP(int type,string symb)
  {
   SymbolSelect(symb,true);
   if(type==-1)
      return((MarketInfo(symb,MODE_ASK)+MarketInfo(symb,MODE_BID))/2);
   return(((isOdd(type))?MarketInfo(symb,MODE_ASK):MarketInfo(symb,MODE_BID)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isOdd(double n)
  {
   return((n/2)==(int)(n/2));
  }
//+------------------------------------------------------------------+
