/*
 * For the indicator to work, place the
 * SmoothAlgorithms.mqh
 * in the directory: MetaTrader\\MQL5\Include
 */
//+------------------------------------------------------------------+
//|                                                XATRStopLevel.mq5 | 
//|                               Copyright © Sovpel Alexander, 2009 | 
//|                               E-mail: Sovpel-Alexander@yandex.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © Sovpel Alexander, 2009"
#property link "E-mail: Sovpel-Alexander@yandex.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//+-----------------------------------+
// type_font enumeration description  |
// CFontName class description        | 
//+-----------------------------------+
#include <GetFontName.mqh>
//+-----------------------------------+
//|  CXMA class description           |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of the CXATR class variables from the SmoothAlgorithms.mqh file
CXMA XATR1;
//+-----------------------------------+
//|  Declaration of enumerations      |
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
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input Smooth_Method XMA_Method=MODE_LWMA; //averaging method
input uint XLength=12; //smoothing depth                    
input int XPhase=15; //smoothing parameter,
                     // for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
// For VIDIA, it is a CMO period, for AMA, it is a slow moving average period
input uint Multiplier=3; //Stop Loss coefficient of ATR

input color  Color1=clrBlue;//color of the first line
input color  Color2=clrMagenta;//color of the second line
input int    FontSize=11; //font size
input type_font FontType=Font14; //font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_LEFT_UPPER; //location corner
input uint Y_=20; //vertical location
input uint X_=5; //horizontal location
//+-----------------------------------+

string sFontType,IndName;
//---- Declaration of integer variables of data starting point
int min_rates_total;
uint shift_1,shift_2;
//+------------------------------------------------------------------+   
//| XATR indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=XATR1.GetStartBars(XMA_Method,XLength,XPhase)+1;
//---- setting alerts for invalid values of external parameters
   XATR1.XMALengthCheck("XLength", XLength);
   XATR1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);

//---- initializations of variable for indicator short name
   string shortname;
   string Smooth1=XATR1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"XATR(",XLength,", ",Smooth1,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- 
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   Deinit(); 
//----   
   IndName=__FILE__;
   int Len=StringLen(IndName);
   IndName=StringSubstr(IndName,0,Len-4);
//----
   switch(WhatCorner)
     {
      case CORNER_RIGHT_LOWER:
        {
         shift_1=Y_+20;
         shift_2=Y_+0;
         break;
        }

      case CORNER_LEFT_LOWER:
        {
         shift_1=Y_+20;
         shift_2=Y_+0;
         break;
        }
      default:
        {
         shift_1=Y_+0;
         shift_2=Y_+20;
        }
     }
//---- end of initialization
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
//| XATR iteration function                                          | 
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
//---- checking the number of bars to be enough for calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of variables with a floating point  
   double atr,xatr=0.0;
//---- Declaration of integer variables and getting the bars already calculated
   int first,bar;
   
   string word;

//---- calculation of the starting number first for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=1; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting number for calculation of new bars

//---- Main calculation loop of the indicator
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      atr=MathMax(high[bar],close[bar-1])-MathMin(low[bar],close[bar-1]);
      atr/=_Point;
      xatr=XATR1.XMASeries(1,prev_calculated,rates_total,XMA_Method,XPhase,XLength,atr,bar,false);
     }
      
   string sxatr=DoubleToString(xatr,0);
   StringConcatenate(word,IndName," : Average volatility of the market  - ",sxatr," points.");   
   SetTLabel(0,"ATR_0",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_1,word,Color1,sFontType,FontSize);

   uint Percentage=Multiplier*100;
   string smxatr=DoubleToString(xatr*Multiplier,0);
   StringConcatenate(word,IndName," : Adaptive stop ( ", string(Percentage),"% of ATR ) - ",smxatr," points.");     
   SetTLabel(0,"ATR_1",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,shift_2,word,Color2,sFontType,FontSize); 
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,"ATR_0");
   ObjectDelete(0,"ATR_1");
//----
  }
//+------------------------------------------------------------------+
//|  Creating a text label                                           |
//+------------------------------------------------------------------+
void CreateTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Resetting a text label                                          |
//+------------------------------------------------------------------+
void SetTLabel
(
 long   chart_id,         // chart ID
 string name,             // object name
 int    nwin,             // window index
 ENUM_BASE_CORNER corner,// base corner location
 ENUM_ANCHOR_POINT point, // anchor point location
 int    X,                // the distance from the base corner along the X-axis in pixels
 int    Y,                // the distance from the base corner along the Y-axis in pixels
 string text,             // text
 color  Color,            // text color
 string Font,             // text font
 int    Size              // font size
 )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
     }
//----
  }
//+------------------------------------------------------------------+
