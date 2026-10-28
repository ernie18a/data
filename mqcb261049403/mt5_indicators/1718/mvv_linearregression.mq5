//+------------------------------------------------------------------+
//|                                         MVV_LinearRegression.mq5 |
//|                                            Copyright © 2007, MVV |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, MVV"
#property link      ""
#property description "A standard linear regression channel and support/resistance levels"
//---- Indicator version number
#property version   "1.00"
//---- The indicator is drawn in the main window
#property indicator_chart_window 
//---- One buffer is used for calculating and drawing the indicator
#property indicator_buffers 1
//---- No graphical constructions are used
#property indicator_plots   0
//+----------------------------------------------+ 
//|  Declaring enumerations                      |
//+----------------------------------------------+ 
enum ENUM_WIDTH //Constant type
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+----------------------------------------------+ 
//|  Declaring enumerations                      |
//+----------------------------------------------+ 
enum ENUM_STYLE
  {
   SOLID_,//Solid line
   DASH_,//Dashed line
   DOT_,//Dotted line
   DASHDOT_,//Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+ 
//|  Declaring constants                         |
//+----------------------------------------------+ 
#define RESET  0 // A constant for returning an indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input datetime FixedDateTime=D'2013.05.01 00:00';    // Channel construction date
input color LR_Color = clrBlue;                      // Channel color
input ENUM_STYLE LR_STYLE = SOLID_;                  // Style of the channel lines
input ENUM_WIDTH LR_WIDTH = w_1;                     // Width of the channel lines
input color STOP_Color = clrRed;                     // Color of stops

//---- MA parameters
input uint   MAPeriod=21;                            // MA period
input  ENUM_MA_METHOD   MAType=MODE_SMMA;            // MA averaging period
input ENUM_APPLIED_PRICE   MAPrice=PRICE_CLOSE;      // MA color
//+----------------------------------------------+

//---- Declaring a dynamic array that will be further 
// used as an indicator buffer
double MABuffer[];

datetime _N_Time;
string sFixedDateTime;
//---- Declaring integer variables for the indicator handles
int MA_Handle;
//---- Declaring integer variables of the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of global variables 
   min_rates_total=int(MAPeriod);
   sFixedDateTime=TimeToString(FixedDateTime,TIME_DATE|TIME_MINUTES);

//---- Getting the handle of the iMA indicator
   MA_Handle=iMA(NULL,0,MAPeriod,0,MAType,MAPrice);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get the handle of the iMA indicator");

//---- set dynamic array as an indicator buffer
   SetIndexBuffer(0,MABuffer,INDICATOR_CALCULATIONS);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(MABuffer,true);

/ / ---- Setting the recording fidelity of the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- data window name and subwindow label 
   string short_name="MVV_LinearRegression+STOP ("+sFixedDateTime+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void Deinit()
  {
//----
   ObjectDelete(0,"LR("+sFixedDateTime+")");
   ObjectDelete(0,"STOP("+sFixedDateTime+")");
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // Amount of history in bars at the current tick
                const int prev_calculated,// Amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[]
                )
  {
  //---- Check if the number of bars is enough for the calculation
   if(BarsCalculated(MA_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

   if(_N_Time==Time[rates_total-1]) return(RESET);

//---- declaration of local variables 
   int to_copy,start,stop,i_max,i_min;
   double a;

//---- calculations of the necessary number of copied data and limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      to_copy=rates_total-min_rates_total; // starting index for the calculation of all bars
      _N_Time=0;
     }
   else
     {
      to_copy=rates_total-prev_calculated+1; // starting index for the calculation of new bars
     }

//---- copy newly appeared data into the arrays
   if(CopyBuffer(MA_Handle,0,0,to_copy,MABuffer)<=0) return(RESET);

//---- indexing elements in arrays as in timeseries 
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);

   start=iBarShift(NULL,Period(),FixedDateTime);

   i_max=ArrayMaximum(High,1,start);
   i_min=ArrayMinimum(Low,1,start);

   if(Close[start]<MABuffer[start]) stop=i_max;
   if(Close[start]>MABuffer[start]) stop=i_min;

   _N_Time=Time[0];

   if(stop>5)
     {
      int n=start+1;
      //---- calculate price values
      double value=Close[0];
      double b,c;
      double sumy=value;
      double sumx=0.0;
      double sumxy=0.0;
      double sumx2=0.0;

      for(int i=1; i<n; i++)
        {
         value=Close[i];
         sumy+=value;
         sumxy+=value*i;
         sumx+=i;
         sumx2+=i*i;
        }

      c=sumx2*n-sumx*sumx;
      if(!c) return(rates_total);
      b=(sumxy*n-sumx*sumy)/c;
      a=(sumy-sumx*b)/n;
     }

   string name="LR("+sFixedDateTime+")";
   SetRegression(0,name,0,Time[start],Time[stop],LR_Color,LR_STYLE,LR_WIDTH,name);

   name="STOP("+sFixedDateTime+")";
   CreateArrowRightPrice(0,name,0,Time[0],a,STOP_Color,1);
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Creating a linear regression channel                            |
//+------------------------------------------------------------------+
void CreateRegression
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 datetime time2,         // price level time 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_REGRESSION,nwin,time1,0,time2,0);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting the linear regression channel                         |
//+------------------------------------------------------------------+
void SetRegression
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // price level time 1
 datetime time2,         // price level time 2
 color    Color,         // line color
 int      style,         // line style
 int      width,         // line width
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRegression(chart_id,name,nwin,time1,time2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,0);
      ObjectMove(chart_id,name,1,time2,0);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void CreateArrowRightPrice //CreateArrowRightPrice(0,"",0,Time,Price,Color,3)
(
 long   chart_id,         // Chart ID
 string name,             // Object name
 int    nwin,             // window index
 datetime Time,           // price label time
 double Price,            // the price label location on a vertical
 color  Color,            // text color
 uint    Size             // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,Time,Price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,Size);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting the text label                                        |
//+------------------------------------------------------------------+
void SetVline
(
 long   chart_id,         // Chart ID
 string name,             // Object name
 int    nwin,             // window index
 datetime Time,           // price label time
 double Price,            // the price label location on a vertical
 color  Color,            // text color
 uint    Size             // font size
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateArrowRightPrice(chart_id,name,nwin,Time,Price,Color,Size);
   else
     {
      ObjectMove(chart_id,name,0,Time,Price);
     }
//----
  }
//+------------------------------------------------------------------+
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol_,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol_,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol_,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
