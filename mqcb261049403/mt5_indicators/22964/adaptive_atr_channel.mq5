//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Adaptive ATR channel"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrDarkOrange
#property indicator_width1  2
#property indicator_label2  "Upper band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Lower band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT

//
//---
//

input int                inpPeriod     = 20;          // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price
input double             inpMultiplier = 1.0;         // ATR multiplier

//
//---
//

double val[],valc[],valu[],vald[],tr[],atr[];
double ª_minPeriod,ª_maxPeriod;

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

void OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valu,INDICATOR_DATA);
         SetIndexBuffer(3,vald,INDICATOR_DATA);
         SetIndexBuffer(4,tr  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,atr ,INDICATOR_CALCULATIONS);
   //            
   //----
   //
         ª_minPeriod = inpPeriod /2.0; if (ª_minPeriod<1) ª_minPeriod=1;
         ª_maxPeriod = ª_minPeriod*2.0;
   //
   //---
   //         
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptive ATR channel ("+(string)inpPeriod+")");
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_where,_index) { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _where = close[_index];                                              break; \
      case PRICE_OPEN:     _where = open[_index];                                               break; \
      case PRICE_HIGH:     _where = high[_index];                                               break; \
      case PRICE_LOW:      _where = low[_index];                                                break; \
      case PRICE_MEDIAN:   _where = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _where = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _where = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _where = 0; \
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
      tr[i] = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) - (low[i]<close[i-1] ? low[i] : close[i-1]) : high[i]-low[i];
      
      //
      //---
      //
      
         double _price; _setPrice(inpPrice,_price,i);
         double _averagePeriod = iEr(_price,inpPeriod,i,rates_total)*(ª_maxPeriod-ª_minPeriod)+ª_minPeriod;
         double _alpha         = 2.0 / (1.0+_averagePeriod);
         double _atr           = tr[i]; int k=1; for (; k<_averagePeriod && i>=k; k++) _atr += tr[i-k]; _atr/=(double)k;
      
      //
      //---
      //
         
      atr[i]  = (i>0) ? atr[i-1]+_alpha*(_atr  -atr[i-1]) : _atr;
      val[i]  = (i>0) ? val[i-1]+_alpha*(_price-val[i-1]) : _price;
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0 ;
      valu[i] = val[i]+inpMultiplier*atr[i];
      vald[i] = val[i]-inpMultiplier*atr[i];
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

double iEr(double value, int period, int i, int bars, int _instance=0)
{
   //
   //---
   //
   
      #define _functionInstancesArraySize 3
      #ifdef  _functionInstances
            static double _workArray[][_functionInstancesArraySize*_functionInstances];
      #else static double _workArray[][_functionInstancesArraySize];
      #endif
            _checkArraySize(_workArray,bars); 

      //
      //---
      //
                  
         #ifdef  _functionInstances
                   int _winst = _instance*_functionInstancesArraySize;
         #else #define _winst _instance
         #endif

         #define _values _winst
         #define _diff   _winst+1
         #define _noise  _winst+2

      //
      //---
      //
      
         _workArray[i][_values] = value;
         _workArray[i][_diff]   = (i>0)? (_workArray[i][_values]>_workArray[i-1][_values]) ? _workArray[i][_values]-_workArray[i-1][_values] : _workArray[i-1][_values]-_workArray[i][_values] : 0;
         if (i<=period)
             { _workArray[i][_noise] = _workArray[i][_diff]; for(int k=1; k<period && (i-k)>=0; k++) _workArray[i][_noise] += _workArray[i-k][_diff]; }
         else  _workArray[i][_noise] = _workArray[i-1][_noise]-_workArray[i-period][_diff]+_workArray[i][_diff];

         //
         //---
         //
      
      double _efr = (_workArray[i][_noise]!=0 && i>period) ? (_workArray[i][_values]>_workArray[i-period][_values] ? _workArray[i][_values]-_workArray[i-period][_values] : _workArray[i-period][_values]-_workArray[i][_values])/_workArray[i][_noise] : 0;
      return(_efr);   
   
   //
   //---
   //
   
   #undef _values #undef _diff #undef _noise
   #undef _functionInstances #undef _functionInstancesArraySize
}
//------------------------------------------------------------------
