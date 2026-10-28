//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Trading the trend"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 12
#property indicator_plots   3
#property indicator_label1  "Trend bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_label3  "Trend line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_style3  STYLE_DOT
//
//--- input parameters
//
input int     inpPeriod       = 21;  // Look back period
input double  inpMultiplier   = 3;   // Multiplier
input int     inpChannelShift = 1;   // Channel shift

//--- buffers and global variables declarations
//
double canh[],canl[],cano[],canc[],cancl[],baro[],barh[],barl[],barc[],barcl[],line[],linecl[];
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
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Trading the trend ("+(string)inpPeriod+")");
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
          int currDisplayType = (int)ChartGetInteger(0,CHART_MODE);;
          if(currDisplayType!=prevDisplayType)
            {
               limit=0; prevDisplayType=currDisplayType;
            }
   //
   //---
   //
   int i=(int)MathMax(limit,0); for(; i<rates_total && !_StopFlag; i++)
     {
      int _start = MathMax(i-inpPeriod-inpChannelShift+1,0);
      double hi      = close[ArrayMaximum(close,_start,inpPeriod)];
      double lo      = close[ArrayMinimum(close,_start,inpPeriod)];
      double tr      = iLwma((i>0?MathMax(high[i],close[i-1])-MathMin(low[i],close[i-1]):high[i]-low[i]),inpPeriod,i,rates_total);
      double hiLimit = hi-tr*inpMultiplier;
      double loLimit = lo+tr*inpMultiplier;
         
      line[i]   = (i>0) ? line[i-1] : close[i];
      linecl[i] = (i>0) ? linecl[i-1] : 0;
         if (close[i]>loLimit && close[i]>hiLimit) line[i] = hiLimit;
         if (close[i]<loLimit && close[i]<hiLimit) line[i] = loLimit;
         if (close[i]>line[i]) { linecl[i] = 1; }
         if (close[i]<line[i]) { linecl[i] = 2; }

      //
      //---
      //
      
      baro[i] = barh[i] = barl[i] = barc[i] = EMPTY_VALUE;
      cano[i] = canh[i] = canl[i] = canc[i] = EMPTY_VALUE;
      switch(currDisplayType)
        {
         case CHART_BARS :
            barh[i]  = high[i];
            barl[i]  = low[i];
            barc[i]  = close[i];
            baro[i]  = open[i];
            barcl[i] = linecl[i];
            break;
         case CHART_CANDLES :
            canh[i]  = high[i];
            canl[i]  = low[i];
            canc[i]  = close[i];
            cano[i]  = open[i];
            cancl[i] = linecl[i];
            break;
        }
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| custom functions                                                 |
//+------------------------------------------------------------------+
double workLwma[][1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//+------------------------------------------------------------------+
