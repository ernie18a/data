//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "RSI"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Rsi"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrGreen
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod    = 32;          // RSI period
input int                inpVolPeriod =  0;          // Volatilty period (<=0 for same as RSI period)
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double val[],valc[];
int ª_volPeriod;
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            ª_volPeriod = (inpVolPeriod>1) ? inpVolPeriod : inpPeriod;
   //
   //--- indicator short name assignment
   //
         IndicatorSetString(INDICATOR_SHORTNAME,"Volatility adjusted RSI ("+(string)inpPeriod+","+(string)ª_volPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
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
      double _price; _setPrice(inpPrice,_price,i); 
      val[i]  = iRsi(_price,(double)inpPeriod/iVolatility(_price,ª_volPeriod,i, rates_total),i,rates_total);
      valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
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

#define _rsiInstancesSize 3
#ifndef _rsiInstances
      double _workRsi[][_rsiInstancesSize];
#else
      double _workRsi[][_rsiInstances*_rsiInstancesSize];
#endif   

double iRsi(double price, double period, int i, int bars, int _inst=0)
{
   _checkArraySize(_workRsi,bars); if (_arrayError) return(0);
  
   #define _changa _inst
   #define _change _inst+1
   #define _price  _inst+2
   #ifdef _rsiInstances
          _inst *= _rsiInstancesSize;
   #endif   

   //
   //---
   //
      
         _workRsi[i][_price]=price;
         if(i<period)
         {
            double sum=0,change; for(int k=0; k<i; k++) { change=_workRsi[i-k][_price]-_workRsi[i-k-1][_price];  sum+=(change>0?change:-change); }
               _workRsi[i][_change] = (_workRsi[i][_price]-_workRsi[0][_price])/(i+1.0);
               _workRsi[i][_changa] =                                       sum/(i+1.0);
         }
         else
         {
               double alpha  =  1.0/period;
               double change = _workRsi[i][_price]-_workRsi[i-1][_price];
               double changa = (change>0) ? change : -change;
                             _workRsi[i][_change] = _workRsi[i-1][_change] + alpha*(change - _workRsi[i-1][_change]);
                             _workRsi[i][_changa] = _workRsi[i-1][_changa] + alpha*(changa - _workRsi[i-1][_changa]);
         }
         return(_workRsi[i][_changa]>0 ? 50.0*(_workRsi[i][_change]/_workRsi[i][_changa]+1.0):50.0);

   //
   //---
   //
         
   #undef  _price
   #undef _change
   #undef _changa
}

//
//---
//

#define _volInstancesSize 4
double  _volArray[][_volInstancesSize];
double iVolatility(double price, int period, int i, int _bars, int instance=0)
{
   _checkArraySize(_volArray,_bars); if (_arrayError) return(1);
   
      #define _price instance
      #define _diff  instance+1
      #define _sumd  instance+2
      #define _suma  instance+3
   
      //
      //---
      //
   
      _volArray[i][_price] = price;
                      double diff = (i>0) ? _volArray[i][_price]-_volArray[i-1][_price] : 0;
      _volArray[i][_diff] = (diff>0) ? diff : -diff;
      if (i<=period)
         { 
            _volArray[i][_sumd] = _volArray[i][_diff]; for(int k=1; k<period && i>=k; k++) _volArray[i][_sumd] += _volArray[i-k][_diff]; 
            _volArray[i][_suma] = _volArray[i][_sumd]; for(int k=1; k<period && i>=k; k++) _volArray[i][_suma] += _volArray[i-k][_sumd]; 
         }
      else  
         { 
            _volArray[i][_sumd] = _volArray[i-1][_sumd]-_volArray[i-period][_diff]+_volArray[i][_diff];
            _volArray[i][_suma] = _volArray[i-1][_suma]-_volArray[i-period][_sumd]+_volArray[i][_sumd];
         }            
      return(_volArray[i][_suma]!=0  && _volArray[i][_sumd]!=0 ? (double)period*_volArray[i][_sumd]/_volArray[i][_suma] : 1 );   
   
   #undef _price
   #undef _diff
   #undef _sumd
   #undef _suma
}   
//------------------------------------------------------------------