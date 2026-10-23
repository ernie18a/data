//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "McGinley dynamic average"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "McGinley dynamic average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input int                inpPeriod = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price
input ENUM_MA_METHOD     inpMethod = MODE_EMA;    // Average method

//
//--- indicator buffers
//
double val[],valc[],avg[]; 
int ª_maHandle,ª_maPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,avg ,INDICATOR_CALCULATIONS);
            ª_maPeriod  = inpPeriod>0 ? inpPeriod : 1;
            ª_maHandle  = iMA(_Symbol,0,ª_maPeriod,0,inpMethod,inpPrice); if (!_checkHandle(ª_maHandle,"average")) { return(INIT_FAILED); }
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"McGinley dynamic "+StringSubstr(EnumToString(inpMethod),5)+" ("+(string)inpPeriod+")");
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      double _price; _setPrice(inpPrice,_price,i);
      if (avg[i]==EMPTY_VALUE) avg[i] = _price;   
         val[i]  = (i>0) ? avg[i-1]+(_price-avg[i-1])/(_price/avg[i-1]*125.0) : _price;
         valc[i] = (i>0) ?(val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom class(es)
//------------------------------------------------------------------
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
