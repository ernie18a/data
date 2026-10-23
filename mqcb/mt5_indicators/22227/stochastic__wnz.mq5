//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Stochastic - with normalized zones"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Normalized zones"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLightBlue,clrPeachPuff
#property indicator_label2  "Normalized stochastic"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Stochastic"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_width3  3
//--- input parameters
input int                inpStoPeriod  =  34;         // Stochastic period
input int                inpStoSlowing =   9;         // Stochastic slowing
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
input int                inpNormPeriod = 20;          // Normalization period
//--- buffers declarations
double val[],valc[],valn[],valfu[],valfd[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,valfu,INDICATOR_DATA);
   SetIndexBuffer(1,valfd,INDICATOR_DATA);
   SetIndexBuffer(2,valn,INDICATOR_DATA);
   SetIndexBuffer(3,val,INDICATOR_DATA);
   SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic - wnz  ("+(string)inpStoPeriod+","+(string)inpNormPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      double _price = getPrice(inpPrice,open,close,high,low,i,rates_total);
      val[i]  = iStoch(_price,_price,_price,inpStoPeriod,inpStoSlowing,i,rates_total)-50;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
      valn[i] = 0;
         int _start = MathMax(i-inpNormPeriod+1,0);
         if (val[i]>0)
         {         
            double hi = val[ArrayMaximum(val,_start,inpNormPeriod)];
               if (hi!=0)
                        valn[i] = 50*val[i]/hi;
         }
         if (val[i]<0)
         {         
            double lo = val[ArrayMinimum(val,_start,inpNormPeriod)];
               if (lo!=0)
                        valn[i] = 50*val[i]/(-lo);
         }
         valfu[i] = valn[i];
         valfd[i] = val[i];
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _stochInstances 1
#define _stochInstancesSize 5
double workSto[][_stochInstances*_stochInstancesSize];
#define _hi 0
#define _lo 1
#define _re 2
#define _ma 3
#define _mi 4
//
//---
//
double iStoch(double priceR,double priceH,double priceL,int period,int slowing,int i, int bars, int instanceNo=0)
  {
   if(ArrayRange(workSto,0)!=bars) ArrayResize(workSto,bars); instanceNo*=_stochInstancesSize;
   workSto[i][_hi+instanceNo] = priceH;
   workSto[i][_lo+instanceNo] = priceL;
   workSto[i][_re+instanceNo] = priceR;
   workSto[i][_ma+instanceNo] = priceH;
   workSto[i][_mi+instanceNo] = priceL;
   for(int k=1; k<period && (i-k)>=0; k++)
     {
      workSto[i][_mi+instanceNo] = MathMin(workSto[i][_mi+instanceNo],workSto[i-k][instanceNo+_lo]);
      workSto[i][_ma+instanceNo] = MathMax(workSto[i][_ma+instanceNo],workSto[i-k][instanceNo+_hi]);
     }
   double sumlow  = 0.0;
   double sumhigh = 0.0;
   for(int k=0; k<slowing && (i-k)>=0; k++)
     {
      sumlow  += workSto[i-k][_re+instanceNo]-workSto[i-k][_mi+instanceNo];
      sumhigh += workSto[i-k][_ma+instanceNo]-workSto[i-k][_mi+instanceNo];
     }
   if(sumhigh!=0.0)
         return(100.0*sumlow/sumhigh);
   else  return(0);
  }  
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
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
