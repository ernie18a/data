//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Rsi(var) Hull of Hulll average"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrCrimson
#property indicator_width1  2
#property indicator_minimum -5
#property indicator_maximum 105
#property indicator_level1  50

//
//--- input parameters
//

input int                inpPeriod   = 50;          // RSI period
input int                inpSmooth   = 14;          // Price smoothing period (<=1 for not smoothing)
input double             inpDivisor  = 1.5;         // Hull divisor
input ENUM_APPLIED_PRICE inpPrice    = PRICE_CLOSE; // Price 

//
//--- buffers and global variables declarations
//

double val[],valc[],prices[];
int ¹_smoothPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,prices,INDICATOR_CALCULATIONS);
            ¹_smoothPeriod = inpSmooth>1 ? inpSmooth : 1;
   //---
         IndicatorSetString(INDICATOR_SHORTNAME,"Rsi(var) Hull ("+(string)inpPeriod+","+(string)¹_smoothPeriod+","+(string)inpDivisor+")");
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
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
              prices[i] = iHull(_price,¹_smoothPeriod,inpDivisor,i,rates_total,2);

      double _diff     = (prices[i]-(i>0 ? prices[i-1] : prices[i]));
      double _difa     = (_diff>0) ? _diff : -_diff;
      double _avgBulls = iHull(0.5*(_difa+_diff),inpPeriod,inpDivisor,i,rates_total,0);
      double _avgBears = iHull(0.5*(_difa-_diff),inpPeriod,inpDivisor,i,rates_total,1);

      val[i]  = (_avgBulls!=0) ? 100.0/(1.0+_avgBears/_avgBulls) : 0; 
            if (val[i]>100) val[i] = 100; 
            if (val[i]<  0) val[i] =   0;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return (i);
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

#define _hullInstances 3
#define _hullInstanceSize 12
#ifdef  _hullInstances
      double _workHull[][_hullInstances*_hullInstanceSize];
#else
      double _workHull[][_hullInstanceSize];
#endif      
double iHull(double price, int period, double divisor, int i, int bars, int _inst=0)
{
   _checkArraySize(_workHull,bars); 
   #ifdef _hullInstances
         _inst*=_hullInstanceSize; 
   #endif         
   #define _coeffs  _inst
   #define _price   _inst+1
   #define _price3  _inst+2
   #define _wsum1   _inst+3
   #define _wsum2   _inst+4
   #define _wsum3   _inst+5
   #define _lsum1   _inst+6
   #define _lsum2   _inst+7
   #define _lsum3   _inst+8
   #define _weight1 _inst+9
   #define _weight2 _inst+10
   #define _weight3 _inst+11
      
   //
   //---
   //
      
      if (_workHull[0][_coeffs] != period)
      {
          _workHull[0][_coeffs] = period;
          _workHull[2][_coeffs] = (int)(period>1 ? period : 1);   
          _workHull[1][_coeffs] = (int)(_workHull[2][_coeffs]>1 ? _workHull[2][_coeffs]/(divisor>1 ? divisor : 1) : 1);
          _workHull[3][_coeffs] = (int) MathSqrt(_workHull[2][_coeffs]);
      }
         
      //
      //---
      //

      _workHull[i][_price]=price;
      if (i>_workHull[2][_coeffs])
      {
         _workHull[i][_weight1] = _workHull[i-1][_weight1];
         _workHull[i][_wsum1]   = _workHull[i-1][_wsum1]+price*_workHull[1][_coeffs]-_workHull[i-1][_lsum1];
         _workHull[i][_lsum1]   = _workHull[i-1][_lsum1]+price-_workHull[i-(int)_workHull[1][_coeffs]][_price];
         _workHull[i][_weight2] = _workHull[i-1][_weight2];
         _workHull[i][_wsum2]   = _workHull[i-1][_wsum2]+price*_workHull[2][_coeffs]-_workHull[i-1][_lsum2];
         _workHull[i][_lsum2]   = _workHull[i-1][_lsum2]+price-_workHull[i-(int)_workHull[2][_coeffs]][_price];
      }
      else
      {
         _workHull[i][_wsum1]   = _workHull[i][_wsum2]   = 0;
         _workHull[i][_lsum1]   = _workHull[i][_lsum2]   = 0;
         _workHull[i][_weight1] = _workHull[i][_weight2] = 0;
         for(int k=0, w1=(int)_workHull[1][_coeffs], w2=(int)_workHull[2][_coeffs]; w2>0 && i>=k; k++, w1--, w2--)
         {
            if (w1>0)
            {
               _workHull[i][_wsum1]   += _workHull[i-k][_price]*w1;
               _workHull[i][_lsum1]   += _workHull[i-k][_price];
               _workHull[i][_weight1] += w1;
            }                  
            _workHull[i][_wsum2]   += _workHull[i-k][_price]*w2;
            _workHull[i][_lsum2]   += _workHull[i-k][_price];
            _workHull[i][_weight2] += w2;
         }
      }
      _workHull[i][_price3]=2.0*_workHull[i][_wsum1]/_workHull[i][_weight1]-_workHull[i][_wsum2]/_workHull[i][_weight2];
         
      //
      //---
      //
         
      if (i>_workHull[3][_coeffs])
      {
         _workHull[i][_weight3] = _workHull[i-1][_weight3];
         _workHull[i][_wsum3]   = _workHull[i-1][_wsum3]+_workHull[i][_price3]*_workHull[3][_coeffs]-_workHull[i-1][_lsum3];
         _workHull[i][_lsum3]   = _workHull[i-1][_lsum3]+_workHull[i][_price3]-_workHull[i-(int)_workHull[3][_coeffs]][_price3];
      }
      else
      {
         _workHull[i][_wsum3]   = 0;
         _workHull[i][_lsum3]   = 0;
         _workHull[i][_weight3] = 0;
         for(int k=0, w3=(int)_workHull[3][_coeffs]; w3>0 && i>=k; k++, w3--)
         {
            _workHull[i][_wsum3]   += _workHull[i-k][_price3]*w3;
            _workHull[i][_lsum3]   += _workHull[i-k][_price3];
            _workHull[i][_weight3] += w3;
         }
      }         
      return(_workHull[i][_wsum3]/_workHull[i][_weight3]);

   //
   //---
   //
            
   #undef _coeffs
   #undef _price
   #undef _price3
   #undef _wsum1
   #undef _wsum2
   #undef _wsum3
   #undef _lsum1
   #undef _lsum2
   #undef _lsum3
   #undef _weight1
   #undef _weight2
   #undef _weight3
}

//+------------------------------------------------------------------+