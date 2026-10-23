//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
#property indicator_label1  "filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrYellowGreen,clrPaleVioletRed
#property indicator_label2  "up level"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_DOT
#property indicator_label3  "down level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepPink
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Hull"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrMediumSeaGreen,clrDeepPink
#property indicator_width4  2

//
//--- input parameters
//

enum enDisplayFill
{
   fill_display, // Display the filled zones
   fill_dont     // Don't display the filled zones
};
input int                inpPeriod  = 20;           // Period
input double             inpDivisor = 2.0;          // Divisor ("speed")
input double             inpPeriodl =  3;           // Levels period (<=1 for same as Hull period)
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE;  // Price
input enDisplayFill      inpDisplay = fill_display; // Filled zones display :

//
//--- indicator buffers
//

double val[],valc[],levelUp[],levelDn[],fillu[],filld[];
double _levelsPeriod,_alphaLevels;
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,fillu  ,INDICATOR_DATA); 
         SetIndexBuffer(1,filld  ,INDICATOR_DATA); 
         SetIndexBuffer(2,levelUp,INDICATOR_DATA); 
         SetIndexBuffer(3,levelDn,INDICATOR_DATA);
         SetIndexBuffer(4,val    ,INDICATOR_DATA);
         SetIndexBuffer(5,valc   ,INDICATOR_COLOR_INDEX);
            _levelsPeriod = (inpPeriodl<=1 ? inpPeriod : inpPeriodl);
            _alphaLevels  = 2.0/(1.0+_levelsPeriod);   
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"Hull ("+(string)inpPeriod+")");
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
      val[i]     = iHull(_price,inpPeriod,inpDivisor,i,rates_total,0);
      levelUp[i] = (i>0) ? (val[i]>levelDn[i-1]) ? levelUp[i-1]+(_alphaLevels)*(val[i]-levelUp[i-1]) : levelUp[i-1] : val[i];
      levelDn[i] = (i>0) ? (val[i]<levelUp[i-1]) ? levelDn[i-1]+(_alphaLevels)*(val[i]-levelDn[i-1]) : levelDn[i-1] : val[i];
      valc[i]    = (val[i]>levelUp[i]) ? 1 : (val[i]<levelDn[i]) ? 2 : (i>0) ? (val[i]==val[i-1]) ? valc[i-1]: 0 : 0;
      fillu[i]   = (inpDisplay==fill_dont) ? EMPTY_VALUE : val[i];
      filld[i]   = (inpDisplay==fill_dont) ? EMPTY_VALUE : (valc[i]==0) ? val[i] : (valc[i]==1) ? levelUp[i] : levelDn[i];
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

//#define _hullInstances 1
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
