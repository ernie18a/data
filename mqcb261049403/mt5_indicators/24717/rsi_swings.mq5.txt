//------------------------------------------------------------------
#property copyright   "© mladen 2019"
#property link        "mladenfx@gmail.com"
#property description "RSI swings"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Rsi"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//
//

input int                inpRsiPeriod   = 14;          // RSI period
input int                inpMaPeriod    =  32;         // Average period
input ENUM_MA_METHOD     inpMaMethod    = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input double             inpLevelUp1    = 70;          // Level up 1
input double             inpLevelUp2    = 60;          // Level up 2
input double             inpLevelDn2    = 40;          // Level down 2
input double             inpLevelDn1    = 30;          // Level down 1

//
//---
//

double val[],valc[],rsi[];
int  ª_rsiHandle,ª_maHandle,ª_rsiPeriod; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,rsi ,INDICATOR_CALCULATIONS);
            ª_rsiPeriod = (inpRsiPeriod>1) ? inpRsiPeriod : 1;
            ª_maHandle  = iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(ª_maHandle,"average")) return(INIT_FAILED);
            ª_rsiHandle = iRSI(_Symbol,0,ª_rsiPeriod,ª_maHandle);            if (!_checkHandle(ª_rsiHandle,"RSI"))    return(INIT_FAILED);
            
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"RSI swings ("+(string)inpRsiPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
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
         if (CopyBuffer(ª_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (rsi[i] == EMPTY_VALUE) rsi[i] = 0;
      
         valc[i] = (i>0) ? valc[i-1] : 0;
            if (rsi[i]<inpLevelDn2 && valc[i] == 1) valc[i] = 0;
            if (rsi[i]>inpLevelUp2 && valc[i] == 2) valc[i] = 0;
            if (rsi[i]>inpLevelUp1)                 valc[i] = 1;
            if (rsi[i]<inpLevelDn1)                 valc[i] = 2;

            val[i] = (valc[i]==1) ? 1 : (valc[i]==2) ? -1 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

bool _checkHandle(int _handle, string _description)
{
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------