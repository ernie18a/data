//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Cuttlers' RSI adaptive EMA with floating levels"
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
#property indicator_label4  "Cuttlers' RSI adaptive EMA"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrCrimson,clrForestGreen
#property indicator_width4  2
//--- input parameters
enum enColorMode
{
   col_onZero, // Change color on middle line cross
   col_onOuter // Change color on outer levels cross
};
input double             inpPeriod      = 32;          // RSI period
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Cuttlers' RSI adaptive EMA with floating levels("+(string)inpPeriod+")");
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
         double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
		   double _alpha = MathAbs(iRsi(_price,inpPeriod,i,rates_total)/100.0 - 0.5) * 2.0;
         val[i]  = (i>0) ? val[i-1]+_alpha*(_price-val[i-1]) : _price;
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
#define _rsiInstances 1
#define _rsiInstancesSize 1
double workRsi[][_rsiInstances*_rsiInstancesSize];
#define _price  0
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
      double sump = 0;
      double sumn = 0;
      for (int k=0; k<(int)period && (r-k-1)>=0; k++)
      {
               double diff = workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price];
                  if (diff > 0)
                        sump += diff;
                  else  sumn -= diff;
      }
   return(100.0-100.0/(1.0+sump/MathMax(sumn,DBL_MIN)));
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
