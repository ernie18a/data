//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   4
#property indicator_label1  "filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrYellowGreen,clrPaleVioletRed
#property indicator_label2  "up level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrLimeGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "down level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepPink
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Laguerre filter"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrDeepPink
#property indicator_width4  2
//---
enum enDisplayFill
{
   fill_display, // Display the filled zones
   fill_dont     // Don't display the filled zones
};
input double             inpPeriod  = 14;            // Period
input double             inpPeriodl =  0;            // Levels period (<=1 for same as filter period)
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE;   // Price
input enDisplayFill      inpDisplay = fill_display;  // Filled zones display :
//
//---
//
double val[],valc[],levelUp[],levelDn[],fillu[],filld[],atr[];
double _levelsPeriod;
int    _atrHandle,_atrPeriod; 
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
   //---- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA); 
   SetIndexBuffer(1,filld,INDICATOR_DATA); 
   SetIndexBuffer(2,levelUp,INDICATOR_DATA); 
   SetIndexBuffer(3,levelDn,INDICATOR_DATA);
   SetIndexBuffer(4,val,INDICATOR_DATA);
   SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,atr,INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
      //----
            _atrPeriod    = MathMax((int)inpPeriod,1);
            _atrHandle    = iATR(_Symbol,0,_atrPeriod); if (!_checkHandle(_atrHandle)) return(INIT_FAILED);
            _levelsPeriod = (inpPeriodl<=1 ? inpPeriod : inpPeriodl);
      //----
   IndicatorSetString(INDICATOR_SHORTNAME,"Laguerre filter levels ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
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
             _coeff = (_coeff+1.0)/2.0;
  
      val[i] = iLaGuerreFil(getPrice(inpPrice,open,close,high,low,i),inpPeriod*_coeff,i,0);
         double _levelUp = iLaGuerreFil(val[i],_levelsPeriod*_coeff,i,1,(i>0 ? !(val[i]>levelDn[i-1]) : false));
         double _levelDn = iLaGuerreFil(val[i],_levelsPeriod*_coeff,i,2,(i>0 ? !(val[i]<levelUp[i-1]) : false));
      levelUp[i] = MathMax(_levelUp,_levelDn);
      levelDn[i] = MathMin(_levelUp,_levelDn);
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
      fillu[i]   = (inpDisplay==fill_dont) ? EMPTY_VALUE : val[i];
      filld[i]   = (inpDisplay==fill_dont) ? EMPTY_VALUE : (valc[i]==0) ? val[i] : (valc[i]==1) ? levelUp[i] : levelDn[i];
   }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _lagFilInstances 3
#define _lagFilInstancesSize 4
#define _lagFilRingSize 6
double workLagFil[_lagFilRingSize][_lagFilInstances*_lagFilInstancesSize];
double iLaGuerreFil(double price, double period, int i, int instance=0, bool copy=false)
{
   int _indC = (i  )%_lagFilRingSize;
   int _indP = (i-1)%_lagFilRingSize;
   int _inst = instance*_lagFilInstancesSize;

      //
      //---
      //

      if (!copy && i>0 && period>1)
      {      
         double _gamma = 1.0 - 10.0/(period+9.0);
            workLagFil[_indC][_inst  ] =  price                      + _gamma*(workLagFil[_indP][_inst  ] - price                     );
            workLagFil[_indC][_inst+1] =  workLagFil[_indP][_inst  ] + _gamma*(workLagFil[_indP][_inst+1] - workLagFil[_indC][_inst  ]);
            workLagFil[_indC][_inst+2] =  workLagFil[_indP][_inst+1] + _gamma*(workLagFil[_indP][_inst+2] - workLagFil[_indC][_inst+1]);
            workLagFil[_indC][_inst+3] =  workLagFil[_indP][_inst+2] + _gamma*(workLagFil[_indP][_inst+3] - workLagFil[_indC][_inst+2]);
      }
      else for (int k=0; k<_lagFilInstancesSize; k++) workLagFil[_indC][_inst+k]= (copy && i>0) ? workLagFil[_indP][_inst+k] : price;

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