//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Normalized smoother MACD"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Normalized MACD"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_width1  2

//
//--- input parameters
//

input int                inpFastPeriod   = 12;           // MACD fast period
input int                inpSlowPeriod   = 26;           // MACD slow period
input ENUM_MA_METHOD     inpMaMethod     = MODE_SMMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE;  // Price
input int                inpNormPeriod   = 50;           // Normalization period

//
//--- indicator buffers
//

double val[],valc[],macd[],mafast[],maslow[];
int _normPeriod,_macdFastHandle,_macdSlowHandle;

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val   ,INDICATOR_DATA);
   SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,macd  ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,mafast,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,maslow,INDICATOR_CALCULATIONS);
         _normPeriod = inpNormPeriod>1 ? inpNormPeriod-1 : 1;
         _macdFastHandle = iMA(_Symbol,0,inpFastPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(_macdFastHandle,"Fast average")) return(INIT_FAILED);
         _macdSlowHandle = iMA(_Symbol,0,inpSlowPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(_macdSlowHandle,"Slow average")) return(INIT_FAILED);
   
   //
   //---
   //
            
   IndicatorSetString(INDICATOR_SHORTNAME,"Normalized MACD of "+StringSubstr(EnumToString(inpMaMethod),5)+" ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+")("+(string)inpNormPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   int _copyCount = rates_total-prev_calculated+1; if (_copyCount>rates_total) _copyCount=rates_total;
         if (CopyBuffer(_macdFastHandle,0,0,_copyCount,mafast)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(_macdSlowHandle,0,0,_copyCount,maslow)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   static int    prev_i=-1;
   static double prev_max,prev_min;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      macd[i] = mafast[i]-maslow[i];
         
         //
         //---
         //
         
         if (prev_i!=i)
         {
            int _start = i-inpNormPeriod+1; if (_start<0) _start = 0;;
               prev_max = macd[ArrayMaximum(macd,_start,_normPeriod)];            
               prev_min = macd[ArrayMinimum(macd,_start,_normPeriod)];            
               prev_i   = i;
         }      
         double max  = (macd[i]>prev_max) ? macd[i] : prev_max;
         double min  = (macd[i]<prev_min) ? macd[i] : prev_min;
         val[i] = 0;
            if (macd[i]>0 && max!=0) val[i] = macd[i]/max;
            if (macd[i]<0 && min!=0) val[i] = macd[i]/MathAbs(min);
         valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : 0;
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