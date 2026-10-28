//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Phase accumulation adaptive RSX"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Rsx"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2

//
//--- input parameters
//

input double             inpPeriod = 1;           // PA cycles to reach
input double             inpFilter = 0;           // PA cycles filter (<=1 for no filtering)
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double val[],valc[];
double ª_cycleFilter; 

//------------------------------------------------------------------ 
// Custom indicator initialization function
//------------------------------------------------------------------
int OnInit()
  {
   //--- indicator buffers mapping
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            ª_cycleFilter = (inpFilter>1) ? inpFilter : 1;
   //--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Phase accumulation adaptive RSX ("+(string)inpPeriod+")");
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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
         val[i]  = iRsx(_price,iHilbertPhase(_price,ª_cycleFilter,inpPeriod,i,rates_total),i,0);
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _rsxInstances      1
#define _rsxInstancesSize 13
#define _rsxRingSize       6
double workRsx[_rsxRingSize][_rsxInstances*_rsxInstancesSize];
//
//---
//
double iRsx(double price, double period, int i, int instance=0)
{
   int _indC = (i)%_rsxRingSize;
   int _inst = instance*_rsxInstancesSize;
   
      workRsx[_indC][_inst]=price;
      
      //
      //---
      //

      double res = 50.0;
      if (i>0 && period>=1)
      {
         int _indP = (i-1)%_rsxRingSize;
         double Kg  = (3.0)/(2.0+period), Hg=1.0-Kg;
         double mom = workRsx[_indC][_inst]-workRsx[_indP][_inst];
         double moa = (mom<0) ? -mom : mom;
         for(int k=0,kk=_inst+1; k<3; k++,kk+=4)
         {
            workRsx[_indC][kk  ] = Kg*mom                  + Hg*workRsx[_indP][kk  ];
            workRsx[_indC][kk+1] = Kg*workRsx[_indC][kk  ] + Hg*workRsx[_indP][kk+1]; mom = 1.5*workRsx[_indC][kk  ] - 0.5 * workRsx[_indC][kk+1];
            workRsx[_indC][kk+2] = Kg*moa                  + Hg*workRsx[_indP][kk+2];
            workRsx[_indC][kk+3] = Kg*workRsx[_indC][kk+2] + Hg*workRsx[_indP][kk+3]; moa = 1.5*workRsx[_indC][kk+2] - 0.5 * workRsx[_indC][kk+3];
         }
         res = (mom/(moa>DBL_MIN?moa:DBL_MIN)+1.0)*50.0;
      }         
      else for(int k=1; k<_rsxInstancesSize; k++) workRsx[_indC][_inst+k]=0; 
   return(res>0?res<100?res:100:0);
}

//
//---
//

#define _checkArrayReserve 500
#define _checkArraySize(_arrayName,_ratesTotal)                            \
     static bool _arrayError     = false;                                  \
   { static int  _arrayResizedTo = 0;                                      \
             if (_arrayResizedTo<_ratesTotal)                              \
             {                                                             \
                  int _res = (_ratesTotal+_checkArrayReserve);             \
                      _res -= ArrayResize(_arrayName,_res);                \
                  if (_res)                                                \
                        _arrayError     = true;                            \
                  else {_arrayResizedTo = _ratesTotal+_checkArrayReserve;  \
              }}                                                           \
   }

//
//---
//
//#define _hilInstances    1
#define _hilInstanceSize 9
#ifdef  _hilInstances
      double  _workHil[][_hilInstances*_hilInstanceSize];
#else   
      double  _workHil[][_hilInstanceSize];
#endif   
double iHilbertPhase(double price, double filter, double cyclesToReach, int i,int bars, int _inst=0)
{
   _checkArraySize(_workHil,bars); if (_arrayError) return(0);
      
   //
   //---
   //

      #define _price      _inst
      #define _smooth     _inst+1
      #define _detrender  _inst+2
      #define _period     _inst+3
      #define _instPeriod _inst+4
      #define _phase      _inst+5
      #define _deltaPhase _inst+6
      #define _Q1         _inst+7
      #define _I1         _inst+8
      
      _inst              *= _hilInstanceSize;
      _workHil[i][_price] = price; 
         if (i<6) { 
                     _workHil[i][_instPeriod] = 1;
                     _workHil[i][_period]     = 1;  
                     _workHil[i][_deltaPhase] = 7;  
                     _workHil[i][_smooth]     = _workHil[i][_Q1] = _workHil[i][_I1] = price; 
                     return(1); 
                  }
                  cyclesToReach *= 360.0;

      //
      //---
      //
      
      #define _calcComp(_ind) ((0.0962*_workHil[i][_ind] + 0.5769*_workHil[i-2][_ind] - 0.5769*_workHil[i-4][_ind] - 0.0962*_workHil[i-6][_ind]) * (0.075*_workHil[i-1][_period] + 0.54))

         _workHil[i][_smooth]     = (4.0*_workHil[i][_price]+3.0*_workHil[i-1][_price]+2.0*_workHil[i-2][_price]+_workHil[i-3][_price])/10.0;
         _workHil[i][_detrender]  = _calcComp(_smooth);
         _workHil[i][_Q1]         = 0.15*_calcComp(_detrender)    +0.85*_workHil[i-1][_Q1];
         _workHil[i][_I1]         = 0.15*_workHil[i-3][_detrender]+0.85*_workHil[i-1][_I1];
         _workHil[i][_phase]      = _workHil[i-1][_phase];
         _workHil[i][_instPeriod] = _workHil[i-1][_instPeriod];

         //
         //---
         //

         if (MathAbs(_workHil[i][_I1])>0)
                     _workHil[i][_phase] = 180.0/M_PI*MathArctan(MathAbs(_workHil[i][_Q1]/_workHil[i][_I1]));
           
         if (_workHil[i][_I1]<0 && _workHil[i][_Q1]>0) _workHil[i][_phase] = 180.0-_workHil[i][_phase];
         if (_workHil[i][_I1]<0 && _workHil[i][_Q1]<0) _workHil[i][_phase] = 180.0+_workHil[i][_phase];
         if (_workHil[i][_I1]>0 && _workHil[i][_Q1]<0) _workHil[i][_phase] = 360.0-_workHil[i][_phase];

         //
         //---
         //
                        
         _workHil[i][_deltaPhase] = _workHil[i-1][_phase]-_workHil[i][_phase];

         if (_workHil[i-1][_phase]<90.0 && _workHil[i][_phase]>270.0) _workHil[i][_deltaPhase] = 360.0+_workHil[i-1][_phase]-_workHil[i][_phase];
         if (_workHil[i][_deltaPhase]>60.0) _workHil[i][_deltaPhase] = 60.0;
         if (_workHil[i][_deltaPhase]< 7.0) _workHil[i][_deltaPhase] =  7.0;
      
         //
         //---
         //
         
         double phaseSum = _workHil[i][_deltaPhase]; int k=1; for (; phaseSum<cyclesToReach && i>=k; k++) phaseSum += _workHil[i-k][_deltaPhase];
           _workHil[i][_instPeriod]= k;
           _workHil[i][_period] = _workHil[i-1][_period]+(2.0/(1.0+filter))*(_workHil[i][_instPeriod]-_workHil[i-1][_period]);
   return (_workHil[i][_period]);

   //
   //---
   //
   
   #undef _price
   #undef _smooth
   #undef _detrender
   #undef _period
   #undef _instPeriod
   #undef _phase
   #undef _deltaPhase
   #undef _Q1
   #undef _I1
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
//+------------------------------------------------------------------+
