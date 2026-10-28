//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI of average"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "CCI of average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2

//
//--- input parameters
//
enum enColorChangeOn
{
   cchange_onSlope,  // Change color on slope change
   cchange_onLevels, // Change color on levels crossing
   cchange_onZero    // Change color on zero crossing
};
input int                inpCciPeriod   =  32;              // CCI period
input int                inpMaPeriod    =  14;              // Average period (<= 1 for no average)
input ENUM_MA_METHOD     inpMaMethod    = MODE_EMA;         // Average method
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE;      // Price 
input double             inpLevel       = 100;              // Level(s) (+ and - will be the same)
input enColorChangeOn    inpColorChange = cchange_onLevels; // Color change type

//
//--- buffers declarations
//

double val[],valc[];

//
//--- indicator handles
//

int ª_maHandle,ª_maPeriod,ª_cciHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //--- indicator buffers mapping
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            IndicatorSetInteger(INDICATOR_LEVELS,2);
            IndicatorSetDouble(INDICATOR_LEVELVALUE,0, inpLevel);
            IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-inpLevel);

   //--- indicator short name assignment
         ª_maPeriod  = inpMaPeriod>0 ? inpMaPeriod : 1;
         ª_maHandle  = iMA(_Symbol,0,ª_maPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maHandle,"average")) { return(INIT_FAILED); }
         ª_cciHandle = iCCI(_Symbol,0,inpCciPeriod,ª_maHandle);          if (!_checkHandle(ª_cciHandle,"CCI"))    { return(INIT_FAILED); }
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI of "+StringSubstr(EnumToString(inpMaMethod),5,-1)+" ("+(string)inpCciPeriod+","+(string)inpMaPeriod+")");
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
         if (CopyBuffer(ª_cciHandle,0,0,_copyCount,val)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  
   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
      switch (inpColorChange)
      {
         case cchange_onLevels : valc[i] = (val[i]>inpLevel) ? 1 :(val[i]<-inpLevel) ? 2 : 0; break;
         case cchange_onSlope  : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
         case cchange_onZero   : valc[i] = (val[i]>0) ? 1 :(val[i]<0) ? 2 : 0; break;
      }         
   return (i);
}
  
//------------------------------------------------------------------
//    custom functions
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
