//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "WPR"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "Wpr trending"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrCoral
#property indicator_width1  2
#property indicator_label2  "Wpr reverting"
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrCoral
#property indicator_width2  0
#property indicator_label3  "Wpr"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrIndianRed
#property indicator_width3  2
#property indicator_level1   30
#property indicator_level2  -30

//
//--- input parameters
//

input int                inpPeriod    = 32;          // WPR period
input int                inpVolPeriod =  0;          // Volatilty period (<=0 for same as WPR period)
input double             inpSmooth    =  8;          // Smoothing/slowing period (<= 1 for no smoothing)
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double val[],valc[],valw[],valht[],valhtc[],valhr[],valhrc[],ª_alpha;
int ª_volPeriod;
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,valht ,INDICATOR_DATA);
         SetIndexBuffer(1,valhtc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valhr ,INDICATOR_DATA);
         SetIndexBuffer(3,valhrc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,val   ,INDICATOR_DATA);
         SetIndexBuffer(5,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(6,valw  ,INDICATOR_CALCULATIONS);
         
         //
         //---
         //
         
         ª_volPeriod = (inpVolPeriod>1) ? inpVolPeriod : inpPeriod;
         ª_alpha     = 2.0/(1.0+MathSqrt(inpSmooth>1 ? inpSmooth : 1));
   //
   //--- indicator short name assignment
   //
         IndicatorSetString(INDICATOR_SHORTNAME,"Volatility adjusted WPR ("+(string)inpPeriod+","+(string)ª_volPeriod+","+string(inpSmooth>1 ? inpSmooth : 1)+")");
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
         int _wprPeriod = int(inpPeriod/iVolatility(_price,ª_volPeriod,i, rates_total));
         int _start     = (i>_wprPeriod) ? i-_wprPeriod+1 : 0;
            double _min = low [ArrayMinimum(low ,_start,_wprPeriod)];
            double _max = high[ArrayMaximum(high,_start,_wprPeriod)];
            double _wpr = (_max!=_min) ? 50-100*(_max-close[i])/(_max-_min) : 0;
                valw[i] = (i>0) ? valw[i-1] + ª_alpha*(_wpr-valw[i-1]) : 0; 
                val[i]  = (i>0) ? val[i-1]  + ª_alpha*(valw[i]-val[i-1]) : 0; 
      
         //
         //---
         //
         
         int slope  = (i>0) ? (val[i]>0) ? (val[i]>val[i-1]) ? 1 : 0 : (val[i]<val[i-1]) ? 1 : 0 : 0;
            valht[i]  = ( slope==1) ? val[i] : EMPTY_VALUE;
            valhr[i]  = ( slope==0) ? val[i] : EMPTY_VALUE;
            valc[i]   = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
            valhtc[i] = (val[i]>0) ? 1 : 2;
            valhrc[i] = (val[i]>0) ? 1 : 2;
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