//------------------------------------------------------------------
#property copyright    "© mladen, 2018"
#property link         "mladenfx@gmail.com"
#property description  "Fast EMA Hull"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Fast Ema hull"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2
//--- input parameters
input double             inpPeriod = 27;           // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
//--- indicator buffers
double val[],valc[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Fast Ema Hull ("+(string)inpPeriod+")");
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
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      val[i]=iHulle(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,i);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _ehullInstances 1
#define _ehullInstancesSize 3
#define _ehullRingSize 5
double workHulle[_ehullRingSize][_ehullInstances*_ehullInstancesSize];
//
//---
//
double iHulle(double price, double period, int i, int instance=0)
{
   int _indP = (i-1)%_ehullRingSize;
   int _indC = (i  )%_ehullRingSize;
   int _inst = instance*_ehullInstancesSize;
   
   //
   //---
   //
   
   if(i>0 && period>1)
   {
      #define _alpha(_period) (2.0/(2.0+(_period-1.0)/2.0))
         workHulle[_indC][_inst  ] = (i>0) ? workHulle[_indP][_inst  ]+_alpha(         period/2.0)*(price                                              -workHulle[_indP][_inst  ]) : price;
         workHulle[_indC][_inst+1] = (i>0) ? workHulle[_indP][_inst+1]+_alpha(         period    )*(price                                              -workHulle[_indP][_inst+1]) : price;
         workHulle[_indC][_inst+2] = (i>0) ? workHulle[_indP][_inst+2]+_alpha(MathSqrt(period)   )*(2*workHulle[_indC][_inst]-workHulle[_indC][_inst+1]-workHulle[_indP][_inst+2]) : price;
   }      
   else for(int k=0; k<_ehullInstancesSize; k++) workHulle[_indC][k+_inst] = (i>0) ? workHulle[_indP][k+_inst]: price;      
   return(workHulle[_indC][_inst+2]);
   
   //
   //---
   //
   
   #undef _alpha
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
