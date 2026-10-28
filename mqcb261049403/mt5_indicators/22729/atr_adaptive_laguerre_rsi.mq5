//------------------------------------------------------------------
#property copyright "© mladen"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrGray,clrDodgerBlue,clrTomato
#property indicator_width1  2

//
//---
//

input int                inpAtrPeriod = 32;             // ATR period 
input ENUM_APPLIED_PRICE inpRsiPrice  = PRICE_CLOSE;    // Price
input double             inpLevelUp   = 0.85;           // Level up
input double             inpLevelDown = 0.15;           // Level down

//
//--- buffers and global variables declarations
//

double val[],valc[],vals[],atr[];
int  ª_atrHandle,ª_atrPeriod; 

//------------------------------------------------------------------
// Custom indicator initialization function                         
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(2,atr,INDICATOR_CALCULATIONS);
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,inpLevelUp);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,inpLevelDown);
   
         ª_atrPeriod = (int)(inpAtrPeriod>1?inpAtrPeriod:1);
         ª_atrHandle=iATR(_Symbol,0,ª_atrPeriod); if (!_checkHandle(ª_atrHandle,"ATR")) return(INIT_FAILED);
      IndicatorSetString(INDICATOR_SHORTNAME,"ATR adaptive Laguerre RSI ("+(string)inpAtrPeriod+")");
   return(0);
}
//------------------------------------------------------------------
// Custom indicator iteration function                              
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_atrHandle,0,0,_copyCount,atr)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      int    start = (i>ª_atrPeriod) ? i-ª_atrPeriod+1 : 0;
      double max   = atr[ArrayMaximum(atr,start,ª_atrPeriod)];            
      double min   = atr[ArrayMinimum(atr,start,ª_atrPeriod)];            
      double coeff = (min!=max) ? 1.0-(atr[i]-min)/(max-min) : 0.5;
           val[i]  = iLaGuerreRsi(getPrice(inpRsiPrice,open,close,high,low,i),ª_atrPeriod*(coeff+0.75),i);
           valc[i] = (val[i]>inpLevelUp) ? 1 : (val[i]<inpLevelDown) ? 2 : 0;
   }
   return(i);
}
//------------------------------------------------------------------
//    custom functions
//------------------------------------------------------------------
//
//---
//
#define _lagRsiInstances 1
#define _lagRsiInstancesSize 4
#define _lagRsiRingSize 6
double workLagRsi[_lagRsiRingSize][_lagRsiInstances*_lagRsiInstancesSize];
//
//---
//
double iLaGuerreRsi(double price, double period, int i, int instance=0)
{
   int _indC = (i  )%_lagRsiRingSize;
   int _inst = instance*_lagRsiInstancesSize;

   //
   //---
   //

      double CU = 0;
      double CD = 0;

      if (i>0 && period>1)
      {      
         int    _indP  = (i-1)%_lagRsiRingSize;
         double _gamma = 1.0 - 10.0/(period+9.0);
         
            workLagRsi[_indC][_inst  ] = price                      + _gamma*(workLagRsi[_indP][_inst  ] - price                     );
            workLagRsi[_indC][_inst+1] = workLagRsi[_indP][_inst  ] + _gamma*(workLagRsi[_indP][_inst+1] - workLagRsi[_indC][_inst  ]);
            workLagRsi[_indC][_inst+2] = workLagRsi[_indP][_inst+1] + _gamma*(workLagRsi[_indP][_inst+2] - workLagRsi[_indC][_inst+1]);
            workLagRsi[_indC][_inst+3] = workLagRsi[_indP][_inst+2] + _gamma*(workLagRsi[_indP][_inst+3] - workLagRsi[_indC][_inst+2]);
            
            //
            //---
            //
            
            if (workLagRsi[_indC][_inst] >= workLagRsi[_indC][_inst+1])
                  CU =  workLagRsi[_indC][_inst  ] - workLagRsi[_indC][_inst+1];
            else  CD =  workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst  ];
            if (workLagRsi[_indC][_inst+1] >= workLagRsi[_indC][_inst+2])
                  CU += workLagRsi[_indC][_inst+1] - workLagRsi[_indC][_inst+2];
            else  CD += workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+1];
            if (workLagRsi[_indC][_inst+2] >= workLagRsi[_indC][_inst+3])
                  CU += workLagRsi[_indC][_inst+2] - workLagRsi[_indC][_inst+3];
            else  CD += workLagRsi[_indC][_inst+3] - workLagRsi[_indC][_inst+2];
      }
      else for (int k=0; k<_lagRsiInstancesSize; k++) workLagRsi[_indC][_inst+k]=price;
   return((CU+CD!=0) ? CU/(CU+CD) : 0);
}

//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
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
//
//---
//  
bool _checkHandle(int _handle, string _description)
{
   static int  _handles[];
          int  _size   = ArraySize(_handles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_handles,_size+1); _handles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_handles[i]); ArrayResize(_handles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}    
//------------------------------------------------------------------