//+------------------------------------------------------------------+
//|                                                   SpreadInfo.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                              |
//| to the terminal_data_folder\MQL5\Include                         |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru" 
//---- indicator version
#property version   "1.00"
#property description "The indicator displays spread, averaged spread and their ratio in one of the chart corners"
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots   1
//+----------------------------------------------+
// type_font enumeration description             |
// CFontName class description                   | 
//+----------------------------------------------+ 
#include <GetFontName.mqh>
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input string SpName="Spread";                          // Spread name
input string MaSpName="MASpread";                      // Average spread name
input string RatioName="Ratio";                        // Spread and its average value ratio name
input color  TextColor1=Magenta;                       // Spread color
input color  TextColor2=Blue;                          // Average spread color
input color  TextColor3=Red;                           // Spread and its average value ratio color
input int    FontSize=15;                              // Font size
input type_font FontType=Font14;                       // Font type
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Location corner
input uint Y_=1;                                       // Vertical location
input uint X_=5;                                       // Horizontal location
input int period=100;                                  // Spread smoothing period
//+----------------------------------------------+
string sFontType;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| СMoving_Average class description                                | 
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+
//|  Creation of a text label                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // chart ID
                  string name,             // object name
                  int    nwin,             // window index
                  ENUM_BASE_CORNER corner, // base corner location
                  ENUM_ANCHOR_POINT point, // anchor point location
                  int    X,                // the distance from the base corner along the X-axis in pixels
                  int    Y,                // the distance from the base corner along the Y-axis in pixels
                  string text,             // text
                  color  Color,            // text color
                  string Font,             // text font
                  int    Size)             // font size
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
//|  Text label reinstallation                                       |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // chart ID
               string name,             // object name
               int    nwin,             // window index
               ENUM_BASE_CORNER corner, // base corner location
               ENUM_ANCHOR_POINT point, // anchor point location
               int    X,                // the distance from the base corner along the X-axis in pixels
               int    Y,                // the distance from the base corner along the Y-axis in pixels
               string text,             // text
               color  Color,            // text color
               string Font,             // text font
               int    Size)             // font size
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,Color,Font,Size);
     }
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//----
   CFontName FONT;
   sFontType=FONT.GetFontName(FontType);
   min_rates_total=period;
   Deinit();
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   ObjectDelete(0,"Spread_Label_1");
   ObjectDelete(0,"Spread_Label_2");
   ObjectDelete(0,"Spread_Label_3");
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
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables
   double ratio,MaSpread=0;
   int first,bar;
   string sMaSpread,sSpread,sRatio;

//---- initialization of the indicator in the OnCalculate() block
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
      first=0;                 // starting index for calculation of all first loop bars
   else
      first=prev_calculated-1; // starting index for calculation of new bars

//---- declaration of the CMoving_Average class variables from the MASeries_Cls.mqh file
   static CMoving_Average SMA;

//---- main indicator calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      MaSpread=SMA.SMASeries(0,prev_calculated,rates_total,period,spread[bar],bar,false);
     }

   sMaSpread=MaSpName+": "+DoubleToString(MaSpread,0);
   sSpread=SpName+": "+string(spread[rates_total-1]);
   ratio=spread[rates_total-1]/MaSpread;
   sRatio=RatioName+": "+DoubleToString(ratio,2);
//---- 
   SetTLabel(0,"Spread_Label_1",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+0,sSpread,TextColor1,sFontType,FontSize);
   SetTLabel(0,"Spread_Label_2",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+20,sMaSpread,TextColor2,sFontType,FontSize);
   SetTLabel(0,"Spread_Label_3",0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_,Y_+40,sRatio,TextColor3,sFontType,FontSize);
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
