//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "mikko breakout"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 14
#property indicator_plots   3
#property indicator_label1  "Bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrLimeGreen,clrSandyBrown
#property indicator_label2  "Candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrDarkGray,clrLimeGreen,clrSandyBrown
#property indicator_label3  "Line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrSandyBrown
#property indicator_width3  2
//
//--- input parameters
//
enum enDisplayStyle
  {
   dis_automatic, // Automatic display style
   dis_line,      // Display line
   dis_bars,      // Display bars
   dis_candles    // Display candles
  };
input int                inpPeriod       = 20;            // Period / count
input enDisplayStyle     inpDisplayStyle = dis_automatic; // Display style

                                                          //
//--- buffers and global variables declarations
//
double canh[],canl[],cano[],canc[],cancl[],baro[],barh[],barl[],barc[],barcl[],line[],linecl[],val[],valcl[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,baro,INDICATOR_DATA);
   SetIndexBuffer(1,barh,INDICATOR_DATA);
   SetIndexBuffer(2,barl,INDICATOR_DATA);
   SetIndexBuffer(3,barc,INDICATOR_DATA);
   SetIndexBuffer(4,barcl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,cano,INDICATOR_DATA);
   SetIndexBuffer(6,canh,INDICATOR_DATA);
   SetIndexBuffer(7,canl,INDICATOR_DATA);
   SetIndexBuffer(8,canc,INDICATOR_DATA);
   SetIndexBuffer(9,cancl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(10,line,INDICATOR_DATA);
   SetIndexBuffer(11,linecl,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(12,val,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,valcl,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Mikko breakout ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
 

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
#define displayLine   0
#define displayBars   1
#define displayCandle 2
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   int limit=prev_calculated-1;
   static int prevDisplayType = -1;
   int currDisplayType = -1;
   switch(inpDisplayStyle)
     {
      case dis_line :      currDisplayType = CHART_LINE;    break;
      case dis_bars :      currDisplayType = CHART_BARS;    break;
      case dis_candles :   currDisplayType = CHART_CANDLES; break;
      case dis_automatic : currDisplayType = (int)ChartGetInteger(0,CHART_MODE);
     }
   if(currDisplayType!=prevDisplayType)
     {
      limit=0; prevDisplayType=currDisplayType;
     }
   int i=(int)MathMax(limit,0); for(; i<rates_total && !_StopFlag; i++)
     {
         int _start = MathMax(i-inpPeriod,0);
         double mmLow  = low[ArrayMinimum(low,_start,inpPeriod)];
         double mmHigh = high[ArrayMaximum(high,_start,inpPeriod)];
         int    trend  = (high[i]>mmHigh) ? 1 : (low[i]<mmLow) ? -1 : 0;
      val[i]   = (i>0) ? (trend==1) ? high[i-1] : (trend==-1) ? low[i-1] : (high[i-1]+low[i-1])/2.0 : EMPTY_VALUE;
      valcl[i] = (i>0) ? (trend==1) ? 1 : (trend==-1) ? 2 : valcl[i-1] : 0;
      baro[i] = barh[i] = barl[i] = barc[i] = EMPTY_VALUE;
      cano[i] = canh[i] = canl[i] = canc[i] = EMPTY_VALUE;
      line[i] = EMPTY_VALUE;
      if (trend!=0)
      switch(currDisplayType)
        {
         case CHART_BARS :
            barh[i]  = high[i];
            barl[i]  = low[i];
            barc[i]  = close[i];
            baro[i]  = open[i];
            barcl[i] = valcl[i];
            break;
         case CHART_CANDLES :
            canh[i]  = high[i];
            canl[i]  = low[i];
            canc[i]  = close[i];
            cano[i]  = open[i];
            cancl[i] = valcl[i];
            break;
         case CHART_LINE :
            line[i]=val[i];
            linecl[i]=valcl[i];
        }
     }
   return (i);
  }
