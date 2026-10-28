//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Directional momentum of average"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Directional momentum of average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2

//
//--- input parameters
//
input int                inpMomPeriod   = 32;               // Momentum period
input int                inpMaPeriod    = 14;               // Average period (<= 1 for no average)
input ENUM_MA_METHOD     inpMaMethod    = MODE_EMA;         // Average method
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price 

//
//--- buffers declarations
//

double val[],valc[],ma[];

//
//--- indicator handles
//

int ª_maHandle,ª_maPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,ma  ,INDICATOR_CALCULATIONS);
   //---
         ª_maPeriod  = inpMaPeriod>0 ? inpMaPeriod : 1;
         ª_maHandle  = iMA(_Symbol,0,ª_maPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maHandle,"average"))   return(INIT_FAILED);
   //--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Directional momentum of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpMomPeriod+","+(string)ª_maPeriod+")");
   return (INIT_SUCCEEDED);
}

//
//---
//

void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,ma)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (ma[i]==EMPTY_VALUE) ma[i] = 0;
         val[i]  = iDirectionalMomentum(ma[i],inpMomPeriod,ª_maPeriod,i,rates_total);
         valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : 0;
   }
   return (i);
}
  
//------------------------------------------------------------------
//    custom functions
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

#define _momInstancesSize 3
double  _momArray[][_momInstancesSize];
double iDirectionalMomentum(double price, int period, int safeCount, int i, int _bars, int instance=0)
{
   _checkArraySize(_momArray,_bars); if (_arrayError) return(1);
   
      #define _price instance
      #define _diff  instance+1
      #define _sumd  instance+2
   
      //
      //---
      //
   
      int _sumTill = (2*safeCount>period) ? 2*safeCount : period;
      _momArray[i][_price] = price;
                      double diff = (i>0) ? _momArray[i][_price]-_momArray[i-1][_price] : 0;
      _momArray[i][_diff] = (diff>0) ? diff : -diff;
      if (i>_sumTill)
            { _momArray[i][_sumd] = _momArray[i-1][_sumd]-_momArray[i-period][_diff]+_momArray[i][_diff]; }
      else  { _momArray[i][_sumd] = _momArray[i][_diff]; for(int k=1; k<period && i>=k; k++) _momArray[i][_sumd] += _momArray[i-k][_diff]; }            
      return( (i>period) ? _momArray[i][_price]>_momArray[i-period][_price] ? _momArray[i][_sumd] : -_momArray[i][_sumd] : 0);   
   
   #undef _price
   #undef _diff
   #undef _sumd
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
//+------------------------------------------------------------------+
