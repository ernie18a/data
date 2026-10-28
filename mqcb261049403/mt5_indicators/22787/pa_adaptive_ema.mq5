//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Phase accumulation adaptive EMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2

//
//--- input parameters
//

input double             inpCyclesPeriod  = 1;           // EMA cycles period
input double             inpCyclesFilter  = 0;           // EMA cycles filter (<=1 for no filtering)
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price

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
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         ª_cycleFilter = (inpCyclesFilter>1) ? inpCyclesFilter : 1;
   IndicatorSetString(INDICATOR_SHORTNAME,"Phase accumulation adaptive EMA ("+(string)inpCyclesPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}
//
//---
//

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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
         val[i]  = (i>0) ? val[i-1]+(2.0/(1+iHilbertPhase(_price,ª_cycleFilter,inpCyclesPeriod,i,rates_total)))*(_price-val[i-1]) : _price;
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 : (val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }          
   return(rates_total);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
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
