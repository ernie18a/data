//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "ATR adaptive Laguerre filter"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Laguerre filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrCrimson
#property indicator_width1  2
//--- input parameters
input double             inpPeriod = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
//--- indicator buffers
double val[],valc[],atr[];
int  _atrHandle,_atrPeriod; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
   //--- indicator buffers mapping
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,atr,INDICATOR_CALCULATIONS);
   //--- indicator(s) loading
         _atrPeriod = MathMax((int)inpPeriod,1);
         _atrHandle=iATR(_Symbol,0,_atrPeriod); if (!_checkHandle(_atrHandle)) return(INIT_FAILED);
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive Laguerre filter ("+(string)inpPeriod+")");
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
   if(BarsCalculated(_atrHandle)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = MathMin(rates_total-prev_calculated+1,rates_total);
            if (CopyBuffer(_atrHandle,0,0,_copyCount,atr)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
   {
      int    _start = MathMax(i-_atrPeriod+1,0);
      double _max   = atr[ArrayMaximum(atr,_start,_atrPeriod)];            
      double _min   = atr[ArrayMinimum(atr,_start,_atrPeriod)];            
      double _coeff = (_min!=_max) ? 1-(atr[i]-_min)/(_max-_min) : 0.5;
      
      val[i]  = iLaGuerreFil(getPrice(inpPrice,open,close,high,low,i),inpPeriod*(_coeff+1.0)/2.0,i);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
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

//
//---
//  
bool _checkHandle(int _handle)
{
   static int _handles[];
          int _size = ArraySize(_handles);
          
          if (_handle!=INVALID_HANDLE) 
          { 
               ArrayResize(_handles,_size+1); 
                           _handles[_size]=_handle; 
                                 return(true); 
          }
          for (int i=_size-1; i>0; i--)
               IndicatorRelease(_handles[i]); ArrayResize(_handles,0);
          return(false);
}
//+------------------------------------------------------------------+
