//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_minimum -5
#property indicator_maximum 105
#property indicator_level1  100

//
//---
//

input int                inpPeriod     = 32;           // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;  // Price
input int                inpNormPeriod = 100;          // Normalization period

double val[],valc[],rsi[];
int ª_rsiHandle;

//------------------------------------------------------------------ 
//  Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---- indicator buffers mapping
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,rsi ,INDICATOR_CALCULATIONS);
            ª_rsiHandle = iRSI(_Symbol,0,inpPeriod,inpPrice); if (!_checkHandle(ª_rsiHandle,"RSI"))    { return(INIT_FAILED); }
   //            
   //----
   //
 
   IndicatorSetString(INDICATOR_SHORTNAME,"Normalized RSI ("+(string)inpPeriod+","+(string)inpNormPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
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
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(ª_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);
   //
   //---
   //

      static int    prev_i=-1;
      static double prev_max,prev_min;
   
   //
   //---
   //
  
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (rsi[i] == EMPTY_VALUE) rsi[i] = 0;
         if (prev_i!=i)
         {
            prev_i = i; 
            int start    = i-inpNormPeriod+1; if (start<0) start=0;
                prev_max = rsi[ArrayMaximum(rsi,start,inpNormPeriod-1)];
                prev_min = rsi[ArrayMinimum(rsi,start,inpNormPeriod-1)];
         }
         double max = (rsi[i] > prev_max) ? rsi[i] : prev_max;
         double min = (rsi[i] < prev_min) ? rsi[i] : prev_min;
         double range = (max-min)/100.0;
   
      val[i]  = (range!=0) ? (rsi[i]-min)/range : rsi[i];
      valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
//  Custom function(s)
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