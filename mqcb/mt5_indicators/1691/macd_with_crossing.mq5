//+---------------------------------------------------------------------+ 
//|                                              MACD_with_Crossing.mq5 | 
//|                                             Copyright © 208, mladen | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2008, mladen"
#property link "" 
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- only two plots are used
#property indicator_plots   2
//+-----------------------------------+
//|  Cloud drawing parameters         |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_FILLING
//---- the following colors are used for the indicator cloud
#property indicator_color1 clrLime,clrMagenta
//---- displaying label of the signal line
#property indicator_label1  "Up Trend; Down Trend"
//+-----------------------------------+
//|  Cloud drawing parameters         |
//+-----------------------------------+
//---- drawing the indicator as a histogram
#property indicator_type2 DRAW_HISTOGRAM
//---- Gray color is used as the color of the diagrams of the MACD indicator
#property indicator_color2 clrGray
//---- the indicator line is a continuous curve
#property indicator_style2 STYLE_SOLID
//---- Indicator line width is equal to 2
#property indicator_width2 2
//---- displaying the indicator label
#property indicator_label2 "MACD"
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMA1,XMA2,XMA3;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price
   PRICE_DEMARK_         //Demark Price
  };
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
/*enum Smooth_Method - enumeration is declared in SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum ENUM_WIDTH //Type of constant
  {
   w_1 = 1,   //1
   w_2,       //2
   w_3,       //3
   w_4,       //4
   w_5        //5
  };
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       //Solid line
   DASH_,        //Dashed line
   DOT_,         //Dotted line
   DASHDOT_,     //Dot-dash line
   DASHDOTDOT_   //Dot-dash line with double dots
  };
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method MA_Method_=MODE_EMA; //method of averaging
input uint Fast_MA = 12; //period of the fast MACD moving average
input uint Slow_MA = 26; //depth of the slow MACD moving average
input Smooth_Method Signal_Method_=MODE_EMA; //method of averaging of MACD
input uint Signal_SMA=9; //signal line period 
input Applied_price_ AppliedPrice_=PRICE_CLOSE_;//price constant

//---- settings for the line
input uint BarsTotal = 50;         //number of bars to set the lines
input color Line_Color_Up=clrDodgerBlue; //color of growth
input color Line_Color_Dn=clrRed;  //color of fall
input STYLE Line_Style=SOLID_; //style of a line
input ENUM_WIDTH Line_Width=w_5; //width of a line
input bool SetBackground=true; //line background display
//+-----------------------------------+
//---- indicator buffers
double MACDBuffer[],SignBuffer[],HistBuffer[];
//---- Declaration of integer variables of data starting point
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_=XMA1.GetStartBars(MA_Method_,MathMax(Fast_MA,Slow_MA),15);
   min_rates_total=min_rates_+XMA1.GetStartBars(Signal_Method_,Signal_SMA,15);

//---- transformation of the dynamic array MACDBuffer into an indicator buffer
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set SignBuffer dynamic array as an indicator buffer
   SetIndexBuffer(1,SignBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- transformation of the HistBuffer dynamic array into an indicator buffer
   SetIndexBuffer(2,HistBuffer,INDICATOR_DATA);
//---- shifting the starting point of the indicator drawing
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"MACD_with_Crossing( ",Fast_MA,", ",Slow_MA,", ",Signal_SMA," )");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void Deinit()
  {
//----
   int total=ObjectsTotal(0,0,-1)-1;
   string name,sirname;

   for(int numb=total; numb>=0 && !IsStopped(); numb--)
     {
      name=ObjectName(0,numb,0,-1);
      sirname=StringSubstr(name,0,StringLen("MacdCross"));

      if(sirname=="MacdCross") ObjectDelete(0,name);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+     
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- Checking if the number of bars is sufficient for the calculation
   if(rates_total<min_rates_total) return(0);

//---- Declaration of integer variables
   int first,bar;
   double price_,fast_ma,slow_ma,crossing;
   color Line_Color;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      first=0; // starting number for calculation of all bars
      Deinit();
     }
   else first=prev_calculated-1; // starting number for the calculation of new bars

//---- main cycle of calculation of the MACD indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price_=PriceSeries(AppliedPrice_,bar,open,low,high,close);
      fast_ma=XMA1.XMASeries(0,prev_calculated,rates_total,MA_Method_,15,Fast_MA,price_,bar,false);
      slow_ma=XMA2.XMASeries(0,prev_calculated,rates_total,MA_Method_,15,Slow_MA,price_,bar,false);
      MACDBuffer[bar]=(fast_ma-slow_ma)/_Point;
      SignBuffer[bar]=XMA3.XMASeries(min_rates_total,prev_calculated,rates_total,Signal_Method_,15,Signal_SMA,MACDBuffer[bar],bar,false);
      HistBuffer[bar]=MACDBuffer[bar]-SignBuffer[bar];
     }

   int barx=int(rates_total-1-BarsTotal);
   if(prev_calculated<=rates_total && prev_calculated>0 && first<barx) Deinit();
   first=int(MathMax(first,barx));
//---- main loop to set the lines
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      string name="MacdCross"+string(bar);
      crossing=HistBuffer[bar]*HistBuffer[bar-1];
            
      if(crossing<0)
        {
         if(HistBuffer[bar]<0.0) Line_Color=Line_Color_Dn;
         else Line_Color=Line_Color_Up;
         SetVline(0,name,0,time[bar],Line_Color,Line_Style,Line_Width,SetBackground,name);
        }
       else ObjectDelete(0,name);
     }
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  Vertical line creation                                          |
//+------------------------------------------------------------------+
void CreateVline
(
 long     chart_id,      // chart ID.
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // vertical level time
 color    Color,         // color of the line
 int      style,         // style of a line
 int      width,         // width of a line
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_VLINE,nwin,time1,999999999);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,background);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY,true);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP, "\n"); //prohibition of tooltip
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); // background object
//----
  }
//+------------------------------------------------------------------+
//|  Vertical line reinstallation                                    |
//+------------------------------------------------------------------+
void SetVline
(
 long     chart_id,      // chart ID.
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // vertical level time
 color    Color,         // color of the line
 int      style,         // style of a line
 int      width,         // width of a line
 bool     background,// line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateVline(chart_id,name,nwin,time1,Color,style,width,background,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,999999999);
     }
//----
  }
//+------------------------------------------------------------------+ 
