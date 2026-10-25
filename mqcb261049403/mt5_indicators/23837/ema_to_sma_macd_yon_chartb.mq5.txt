//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "EMA to SMA MACD - on chart"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Fill area"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrMediumSeaGreen,clrOrange
#property indicator_label2  "EMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_label3  "SMA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_width3  2

//
//--- input parameters
//

input int                inpPeriod       = 26;          // Period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double fillu[],filld[],ema[],sma[];
int ª_emaHandle,ª_smaHandle,ª_maPeriod;


//------------------------------------------------------------------
// Custom indicator initialization function                          
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillu ,INDICATOR_DATA);
         SetIndexBuffer(1,filld ,INDICATOR_DATA);
         SetIndexBuffer(2,ema   ,INDICATOR_DATA);
         SetIndexBuffer(3,sma   ,INDICATOR_DATA);
            ª_maPeriod  = inpPeriod>0 ? inpPeriod : 1;
            ª_emaHandle = iMA(_Symbol,0,ª_maPeriod,0,MODE_EMA,inpPrice); if (!_checkHandle(ª_emaHandle,"EMA")) { return(INIT_FAILED); }
            ª_smaHandle = iMA(_Symbol,0,ª_maPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(ª_smaHandle,"SMA")) { return(INIT_FAILED); }
         
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA to SMA MACD ("+(string)inpPeriod+")");
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
         if (CopyBuffer(ª_emaHandle,0,0,_copyCount,ema)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_smaHandle,0,0,_copyCount,sma)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (ema[i]==EMPTY_VALUE) ema[i]=0;
      if (sma[i]==EMPTY_VALUE) sma[i]=0;
      fillu[i] = ema[i];
      filld[i] = sma[i];
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
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
//------------------------------------------------------------------