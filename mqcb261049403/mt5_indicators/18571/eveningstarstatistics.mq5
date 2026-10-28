//+------------------------------------------------------------------+
//|                                        EveningStarStatistics.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
#property description "Panel indicator: \"Evening Star\" pattern " 
#property description "search results for different periods" 
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots   0
#include <Graphics\Graphic.mqh>
//--- object for creating graphs
CGraphic my_graphic;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
//--- input parameters 
input ushort   InpWidth          = 900;                        // Width
input ushort   InpHeight         = 400;                        // Height  
input datetime InpStartTime      = __DATETIME__-365*24*60*60;  // Start time 
input datetime InpEndTime        = __DATETIME__;               // End time 
input bool     InpGap            = true;                       // Gap. true -> gap is taken into account
input bool     InpCandle2Type    = true;                       // Candle 2 type. true -> type of candle 2 is taken into account
input bool     InpCandleSizes    = true;                       // Candle sizes. true -> candle sizes is taken into account
//--- 
double         ExtDistance=0.0;        // minimum size of gap
double         m_adjusted_point;       // point value adjusted for 3 or 5 points
bool           m_first_start=false;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(Digits()==3 || Digits()==5)
      digits_adjust=10;
   m_adjusted_point=Point()*digits_adjust;

   ExtDistance=1*m_adjusted_point;                                      // minimum size of gap
//--- canvas creation
   my_graphic.Create(0,"Evening Star Statistics",0,20,20,20+InpWidth,20+InpHeight);
//---
   m_first_start=false;
//--- 
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   my_graphic.Destroy();
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
   if(!m_first_start)
     {
      //--- revert access to arrays - do it like in timeseries 
      ArraySetAsSeries(time,true);
      ArraySetAsSeries(open,true);
      ArraySetAsSeries(high,true);
      ArraySetAsSeries(low,true);
      ArraySetAsSeries(close,true);

      int size=rates_total;
      double arrX[],arrY[];
      ArraySetAsSeries(arrX,true);
      ArraySetAsSeries(arrY,true);

      //--- we apply the input parameter "Start time"
      for(int j=0;j<size;j++)
        {
         if(time[j]<InpStartTime)
           {
            size=j;
            break;
           }
        }

      int limit=size;
      ArrayResize(arrX,limit);
      ArrayResize(arrY,limit);

      arrY[0]=0.0;
      arrY[limit-3]=0.0;
      arrY[limit-2]=0.0;
      arrY[limit-1]=0.0;
      arrX[limit-3]=(double)time[limit-3];
      arrX[limit-2]=(double)time[limit-2];
      arrX[limit-1]=(double)time[limit-1];
/*
   "2"    "1"    "0"
   
           |
        C --- 
          | |
          | |     |
    |   O ---  O --- 
 C ---     |     ||| 
   | |           |||
   | |           |||
   | |           |||
   | |         C ---
   | |            |
   | | 
 O ---
    |
*/
      for(int i=0; i<limit-3;i++)
        {
         arrX[i]=(double)time[i];
         //--- OHLC
         //--- rough check: bar with the index "0" - bearish and bar with the index "2" - bullish
         if(open[i+0]>close[i+0] && open[i+2]<close[i+2]) // 
           {
            if(InpCandleSizes) // Candle sizes 
               if(MathAbs(open[i+0]-close[i+0])<MathAbs(open[i+1]-close[i+1]) || 
                  MathAbs(open[i+2]-close[i+2])<MathAbs(open[i+1]-close[i+1]))
                 {
                  arrY[i+1]=0.0;
                  continue;
                 }
            if(InpCandle2Type) // Candle 2 type
              {
               if(open[i+1]>close[i+1])
                 {
                  arrY[i+1]=0.0;
                  continue;
                 }
              }
            else
              {
               if(close[i+1]>open[i+1])
                 {
                  arrY[i+1]=0.0;
                  continue;
                 }
              }
            if(InpGap) // Gap
               if(open[i+0]>=close[i+1]-ExtDistance || open[i+1]<=close[i+2]+ExtDistance)
                 {
                  arrY[i+1]=0.0;
                  continue;
                 }
            arrY[i+1]=1.0;
           }
        }
      CCurve *curve_b=my_graphic.CurveAdd(arrX,arrY,CURVE_POINTS,"");
      //--- x axis
      CAxis *xAxis=my_graphic.XAxis();
      xAxis.Type(AXIS_TYPE_DATETIME);
      if(Period()>PERIOD_M30)
         xAxis.ValuesDateTimeMode(TIME_DATE);
      else
         xAxis.ValuesDateTimeMode(TIME_DATE|TIME_MINUTES);
      //--- y axis
      CAxis *yAxis=my_graphic.YAxis();
      yAxis.ZeroLever(1.0);
      yAxis.Min(0.9);
      //---
      my_graphic.CurvePlotAll();
      string text=Symbol()+","+StringSubstr(EnumToString(Period()),7,-1);
      text+=";";
      text+=(InpGap)?"true":"false";
      text+=";";
      text+=(InpCandle2Type)?"true":"false";
      text+=";";
      text+=(InpCandleSizes)?"true":"false";
      my_graphic.TextAdd((20+InpWidth)/3,(20+InpHeight)/3,"Evening Star ("+text+")",ColorToARGB(clrBlue,255));

      my_graphic.Update();

      m_first_start=true;
     }
//--- return value of prev_calculated for next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+
