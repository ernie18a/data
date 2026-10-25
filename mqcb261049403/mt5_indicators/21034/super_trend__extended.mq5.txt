//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Super trend - CCI based"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 16
#property indicator_plots   3
#property indicator_label1  "Super trend bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_label2  "Super trend candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_label3  "Super trend line"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepPink,clrLimeGreen
#property indicator_width3  2
//--- input parameters
enum enDisplayStyle
  {
   dis_automatic, // Automatic display style
   dis_line,      // Display line
   dis_bars,      // Display bars
   dis_candles    // Display candles
  };
input int                inpPeriod       = 50;            // Cci Period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_TYPICAL; // Cci Price
input int                inpAtrPeriod    = 5;             // Atr period
input enDisplayStyle     inpDisplayStyle = dis_automatic; // Display style
//--- indicator buffers
double canh[],canl[],cano[],canc[],cancl[],baro[],barh[],barl[],barc[],barcl[],line[],linecl[],prices[],trend[],val[],valc[];
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
   SetIndexBuffer(12,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,val,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,valc,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Super trend ("+(string)inpPeriod+")");
//---
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
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
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
      prices[i]  = getPrice(inpPrice,open,close,high,low,i,rates_total);
      double avg = 0; for(int k=0; k<inpPeriod    && (i-k)>=0;   k++) avg +=         prices[i-k];                                            avg /= inpPeriod;
      double dev = 0; for(int k=0; k<inpPeriod    && (i-k)>=0;   k++) dev += MathAbs(prices[i-k]-avg);                                       dev /= inpPeriod;
      double atr = 0; for(int k=0; k<inpAtrPeriod && (i-k-1)>=0; k++) atr += MathMax(high[i-k],close[i-k-1])-MathMin(low[i-k],close[i-k-1]); atr /= inpAtrPeriod;
      double cci = (dev!=0) ?(prices[i]-avg)/(0.015*dev) : 0;
         trend[i] = (cci>0) ? 1 : (cci<0) ? -1 : (i>0) ? trend[i-1] : 0;
         val[i]  = (i>0) ? (trend[i]==1) ? MathMax(low[i]-atr,val[i-1]) : MathMin(high[i]+atr,val[i-1]) : close[i];
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
         baro[i] = barh[i] = barl[i] = barc[i] = EMPTY_VALUE;
         cano[i] = canh[i] = canl[i] = canc[i] = EMPTY_VALUE;
         line[i] = EMPTY_VALUE;
      switch(currDisplayType)
        {
         case CHART_BARS :
            barh[i]  = high[i];
            barl[i]  = low[i];
            barc[i]  = close[i];
            baro[i]  = open[i];
            barcl[i] = valc[i];
            break;
         case CHART_CANDLES :
            canh[i]  = high[i];
            canl[i]  = low[i];
            canc[i]  = close[i];
            cano[i]  = open[i];
            cancl[i] = valc[i];
            break;
         case CHART_LINE :
            line[i]=val[i];
            linecl[i]=valc[i];
        }
         
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   if(i>=0)
      switch(tprice)
        {
         case PRICE_CLOSE:     return(close[i]);
         case PRICE_OPEN:      return(open[i]);
         case PRICE_HIGH:      return(high[i]);
         case PRICE_LOW:       return(low[i]);
         case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
         case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
         case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
        }
   return(0);
  }
//+------------------------------------------------------------------+
