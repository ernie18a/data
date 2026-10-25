//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Laguerre filter - no gamma"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Laguerre filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrCrimson
#property indicator_width1  2
//--- input parameters
input double             inpPeriod = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
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
   IndicatorSetString(INDICATOR_SHORTNAME,"Laguerre filter -ng ("+(string)inpPeriod+")");
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
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      val[i]=iLaGuerreFil(getPrice(inpPrice,open,close,high,low,i),inpPeriod,i);
      valc[i]=(i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _lagFilInstances 1
#define _lagFilInstancesSize 4
#define _lagFilRingSize 6
double workLagFil[_lagFilRingSize][_lagFilInstances*_lagFilInstancesSize];
double iLaGuerreFil(double price, double period, int i, int instance=0)
{
   int _indC = (i)%_lagFilRingSize;
   int _inst = instance*_lagFilInstancesSize;

      //
      //---
      //

      if (i>0 && period>1)
      {      
         int    _indP  = (i-1)%_lagFilRingSize;
         double _gamma = 1.0 - 10.0/(period+9.0);
            workLagFil[_indC][_inst  ] =  price                      + _gamma*(workLagFil[_indP][_inst  ] - price                     );
            workLagFil[_indC][_inst+1] =  workLagFil[_indP][_inst  ] + _gamma*(workLagFil[_indP][_inst+1] - workLagFil[_indC][_inst  ]);
            workLagFil[_indC][_inst+2] =  workLagFil[_indP][_inst+1] + _gamma*(workLagFil[_indP][_inst+2] - workLagFil[_indC][_inst+1]);
            workLagFil[_indC][_inst+3] =  workLagFil[_indP][_inst+2] + _gamma*(workLagFil[_indP][_inst+3] - workLagFil[_indC][_inst+2]);
      }
      else for (int k=0; k<_lagFilInstancesSize; k++) workLagFil[_indC][_inst+k]=price;

      //
      //---
      //

   return((workLagFil[_indC][_inst]+2.0*workLagFil[_indC][_inst+1]+2.0*workLagFil[_indC][_inst+2]+workLagFil[_indC][_inst+3])/6.0);
}
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
