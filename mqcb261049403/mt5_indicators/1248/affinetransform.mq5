// +——————————————————————————————————————————————————————————————————————————————————————————————+
// ¦     Affine Transform                                                     AffineTransform.mq5 ¦
// ¦  The indicator performs an affine transformation of the time series of price data (by prices,¦
// ¦ specified in the Applied_Price parameter), using the inclination angle of the trend line.    ¦
// ¦  Instructions for use:                                                                       ¦
// ¦   •create a trend line, assign a name to it's object;                                        ¦
// ¦   •attach the indicator to a chart, specifying the name of trend line in the trend line      ¦
// ¦    Trendline_Name parameter;                                                                 ¦
// ¦   •Choose the price constant in the Applied_Price parameter.                                 ¦
// ¦  Note: if there is a change of the trend line, the indicator recalculates all statements.    ¦
// ¦  Thanks to the author of the idea, which in base of the indicator: Lihovidov V.N.            ¦
// ¦  Huge please to distribute the indicator only in the source (.mq5), and do not change the    ¦
// ¦ textof this header.                                                                          ¦
// ¦----------------------------------------------------------------------------------------------¦
// ¦     [release 1] 06.12.2009                                                                   ¦
// ¦ (•)The first release.                                                                        ¦
// ¦ Suggestions for improvements are welcome                    _________________________________¦
// ¦ author's page: http://codebase.mql4.com/ru/6280            |                                 ¦
// ¦                                                            | © xp3rienced, Ekaterinburg 2009 ¦
// +——————————————————————————————————————————————————————————————————————————————————————————————+
#property copyright "Copyright © 2009, xp3rienced"
#property link      "no4ta[at]inbox.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers 5
#property indicator_buffers 5 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Declaration of constants         |
//+-----------------------------------+
#define RESET 0 // The constant for returning the indicator recalculation command to the terminal
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMagenta,clrGray,clrPaleGreen
//---- displaying the indicator label
#property indicator_label1  "AffineTransform Open";"AffineTransform High";"AffineTransform Low";"AffineTransform Close"

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Trendline_Name="A_Line";    // Object name (trend line)  
//+-----------------------------------+
//---- Declaration of integer variables of data starting point
int min_rates_total;
//---- declaration of dynamic arrays that will further be 
// used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];

//---- indicator global variables
double LineAngleTg;                         // Tangent of trend line inclination angle
double LinePrice1, LinePrice2;              // Price coordinates of trend line points
datetime LineTime1, LineTime2;              // Time coordinates of trend line points
int Shift1, Shift2;                         // Bar shifting of trend line points
int Multiplier;                             // Multiplier applied to the price (to reduce the margin of error)
bool NeedUpdate;
//+------------------------------------------------------------------+    
//| AffineTransform indicator initialization function                | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=100;
   NeedUpdate = true;
   Multiplier = int(MathPow(10,_Digits));

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- setting dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);

//---- indexing elements in the buffer as time series
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);

//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"Affine Transform Candles");
//--- determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| AffineTransform iteration function                               | 
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
   if(rates_total<min_rates_total) return(RESET);

//---- Declaration of integer variables and getting the bars already calculated
   int limit,bar;

//---- calculation of the starting number limit for the bar recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-1; // starting index for the calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for the calculation of new bars
     }

//---- calculation of the tangent of  inclination angle, and if it has changed - full redrawing
   CalcAngleTg();

   if(NeedUpdate)
     {
      limit=rates_total-1;
      NeedUpdate=false;
     }

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- main indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double res=(bar-Shift1)*LineAngleTg;

      //--- Initialization of candles 
      ExtOpenBuffer[bar]=(open[bar]-LinePrice1)*Multiplier+res;
      ExtCloseBuffer[bar]=(close[bar]-LinePrice1)*Multiplier+res;
      ExtHighBuffer[bar]=(high[bar]-LinePrice1)*Multiplier+res;
      ExtLowBuffer[bar]=(low[bar]-LinePrice1)*Multiplier+res;

      if(close[bar]>open[bar]) ExtColorBuffer[bar]=2;
      else if(close[bar]<open[bar]) ExtColorBuffer[bar]=0;
      else ExtColorBuffer[bar]=1;
     }
//----        
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| iBarShift() function                                             |
//+------------------------------------------------------------------+
int iBarShift(string symbol,ENUM_TIMEFRAMES timeframe,datetime time)

// iBarShift(symbol, timeframe, time)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   if(time<0) return(-1);
   datetime Arr[],time1;

   time1=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE);

   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
     {
      int size=ArraySize(Arr);
      return(size-1);
     }
   else return(-1);
//----
  }
//+------------------------------------------------------------------+
//| CalcAngleTg() function                                           |
//+------------------------------------------------------------------+  
void CalcAngleTg()
  {
//----
   if(ObjectFind(0,Trendline_Name)==-1) return;
//----
   double tg;
//----
   LinePrice1 = ObjectGetDouble(0,Trendline_Name,OBJPROP_PRICE,0);
   LinePrice2 = ObjectGetDouble(0,Trendline_Name,OBJPROP_PRICE,1);

   LineTime1 = datetime(ObjectGetInteger(0,Trendline_Name,OBJPROP_TIME,0));
   LineTime2 = datetime(ObjectGetInteger(0,Trendline_Name,OBJPROP_TIME,1));
//----
   Shift1 = iBarShift(NULL,PERIOD_CURRENT,LineTime1);
   Shift2 = iBarShift(NULL,PERIOD_CURRENT,LineTime2);
//----
   tg=(LinePrice2-LinePrice1)*Multiplier/(Shift1-Shift2);
   if(tg!=LineAngleTg) NeedUpdate=true;
   LineAngleTg=tg;
//----
  }
//+------------------------------------------------------------------+
