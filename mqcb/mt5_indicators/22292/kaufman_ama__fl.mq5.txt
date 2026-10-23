//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Kaufman adaptive MA - with floating levels"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   4
#property indicator_label1  "Level up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrForestGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Middle level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCrimson
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Kaufman AMA"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrCrimson,clrForestGreen
#property indicator_width4  2
//--- input parameters
enum enColorMode
{
   col_onZero, // Change color on middle line cross
   col_onOuter // Change color on outer levels cross
};
input int                inpPeriod      = 14;          // AMA period
input int                inpFastPeriod  =  2;          // Fast end period
input int                inpSlowPeriod  = 30;          // Slow end period
input double             inpPower       =  2;          // Smooth power
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input int                inpFlPeriod    = 32;          // Floating levels period
input double             inpFlLevelUp   = 80.0;        // Up level %
input double             inpFlLevelDown = 20.0;        // Down level %
input enColorMode        inpColorMode   = col_onOuter; // Change color mode 
//--- indicator buffers
double val[],valc[],flup[],flmi[],fldn[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,flup,INDICATOR_DATA);
   SetIndexBuffer(1,flmi,INDICATOR_DATA);
   SetIndexBuffer(2,fldn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Kaufman adaptive MA with floating levels("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
         val[i]  = iKama(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpFastPeriod,inpSlowPeriod,inpPower,i,rates_total);
            int _start = MathMax(i-inpFlPeriod+1,0);
            double min = val[ArrayMinimum(val,_start,inpFlPeriod)];
            double max = val[ArrayMaximum(val,_start,inpFlPeriod)];
            double range = max-min;
            flup[i] = min+inpFlLevelUp  *range/100.0;
            fldn[i] = min+inpFlLevelDown*range/100.0;
            flmi[i] = min+50            *range/100.0;
         switch (inpColorMode)
         {
            case col_onOuter : valc[i] = (val[i]>flup[i]) ? 2 :(val[i]<fldn[i]) ? 1 : 0; break;
            case col_onZero  : valc[i] = (val[i]>flmi[i]) ? 2 :(val[i]<flmi[i]) ? 1 : (i>0) ? valc[i-1]: 0; break;
         }            
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define kamaInstances     1
#define kamaInstancesSize 3
double workAma[][kamaInstances*kamaInstancesSize];
#define _diff  0
#define _kama  1
#define _price 2
//
//---
//
double iKama(double price,int period,double fast,double slow,double power,int r, int bars,int instanceNo=0)
  {
   if(ArrayRange(workAma,0)!=bars) ArrayResize(workAma,bars);  instanceNo*=kamaInstancesSize;
   double fastend = (2.0 /(fast + 1.0));
   double slowend = (2.0 /(slow + 1.0));
//
//---
//
   double efratio = 1; workAma[r][instanceNo+_price] = price;
   double signal  = (r>=period) ? MathAbs(price-workAma[r-period][instanceNo+_price]) : 0;
   double noise   = 0;
   workAma[r][instanceNo+_diff] = (r>0) ? MathAbs(price-workAma[r-1][instanceNo+_price]) : 0;
      for(int k=0; k<period && r-k>=0; k++) noise+=workAma[r-k][instanceNo+_diff];
      if(noise!=0)
            efratio = signal/noise;
      else  efratio = 1;
//
//---
//
   workAma[r][instanceNo+_kama]=(r>0) ? workAma[r-1][instanceNo+_kama]+MathPow(efratio*(fastend-slowend)+slowend,power)*(price-workAma[r-1][instanceNo+_kama]) : price;
   return(workAma[r][instanceNo+_kama]);
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