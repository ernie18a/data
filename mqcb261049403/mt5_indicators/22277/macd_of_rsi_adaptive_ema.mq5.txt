//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "MACD of RSI adaptive EMA"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2
#property indicator_label2  "MACD signal line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
//--- input parameters
enum enColorOn
{
   color_onSlope, // Change color on MACD slope change
   color_onZero,  // Change color on MACD crossing zero line
   color_onSignal // Change color on MACD crossing signal line
};
input int                inpFastPeriod   = 12;           // MACD fast period
input int                inpSlowPeriod   = 26;           // MACD slow period
input int                inpSignalPeriod = 9;            // MACD signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;  // Price 
input enColorOn          inpColorOn      = color_onZero; // Color change on :
//--- buffers declarations
double val[],valc[],signal[],emaf[],emas[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,signal,INDICATOR_DATA);
   SetIndexBuffer(3,emaf,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,emas,INDICATOR_CALCULATIONS);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD of RSI adaptive EMA ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+","+(string)inpSignalPeriod+")");
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
   double _alphaSignal = 2.0 / (1.0 + inpSignalPeriod);
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
         double _price  = getPrice(inpPrice,open,close,high,low,i,rates_total);
		   double _alphaf = MathAbs(iRsi(_price,inpFastPeriod  ,i,rates_total,0)/100.0 - 0.5) * 2.0;
		   double _alphas = MathAbs(iRsi(_price,inpSlowPeriod  ,i,rates_total,1)/100.0 - 0.5) * 2.0;
      
         emaf[i]   = (i>0) ? emaf[i-1]+_alphaf*(_price-emaf[i-1]) : _price;
         emas[i]   = (i>0) ? emas[i-1]+_alphas*(_price-emas[i-1]) : _price;
         val[i]    = emaf[i] - emas[i];
         signal[i] = (i>0) ? signal[i-1] + _alphaSignal*(val[i]-signal[i-1]) : val[i];
         switch (inpColorOn)
         {
            case color_onSlope : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
            case color_onZero  : valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : (i>0) ? valc[i-1] : 0; break;
            default :            valc[i] = (val[i]>signal[i]) ? 1 :(val[i]<signal[i]) ? 2 : (i>0) ? valc[i-1] : 0;   
         }            
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsiInstances 2
#define _rsiInstancesSize 3
double workRsi[][_rsiInstances*_rsiInstancesSize];
#define _price  0
#define _change 1
#define _changa 2
//
//---
//
double iRsi(double price,double period,int r,int bars,int instanceNo=0)
  {
   if(ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z=instanceNo*_rsiInstancesSize;

//
//---
//

   workRsi[r][z+_price]=price;
   double alpha=1.0/MathMax(period,1);
   if(r<period)
     {
      int k; double sum=0; for(k=0; k<period && (r-k-1)>=0; k++) sum+=MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
      workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
      workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
     }
   else
     {
      double change=workRsi[r][z+_price]-workRsi[r-1][z+_price];
      workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
      workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
     }
   return(50.0*(workRsi[r][z+_change]/MathMax(workRsi[r][z+_changa],DBL_MIN)+1));
  }
//
//---
//
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
