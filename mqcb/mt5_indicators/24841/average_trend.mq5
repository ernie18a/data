//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "average trend"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Average trend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width1  2

//
//
//

input int                inpMaPeriod     = 35;          // Average period
input ENUM_MA_METHOD     inpMaMethod     = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price
input double             inpAcceleration = 1.05;        // Acceleration factor

//
//
//

double val[],valc[],avg[],trend[],step[];
int _maHandle;

//------------------------------------------------------------------ 
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,avg  ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,trend,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,step ,INDICATOR_CALCULATIONS);
   
   //
   //
   //
   
      _maHandle  = iMA(_Symbol,0,inpMaPeriod,0,inpMaMethod,inpPrice); if (!_checkHandle(_maHandle,"average")) return(INIT_FAILED);
   IndicatorSetString(INDICATOR_SHORTNAME,"Average ("+StringSubstr(EnumToString(inpMaMethod),5)+") trend ("+(string)inpMaPeriod+","+(string)inpAcceleration+")");
   return (INIT_SUCCEEDED);
  }
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
         if (CopyBuffer(_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);

   //
   //
   //
     
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (i>0)
      {
         trend[i] = (avg[i]>avg[i-1]) ? 1 : (avg[i]<avg[i-1]) ? -1 : trend[i-1];
         step[i]  = (trend[i]!=trend[i-1]) ? 0.01 : step[i-1]*inpAcceleration;
         val[i]   = (val[i-1]+trend[i]*step[i]);
      }
      else { trend[i] = 0; step[i] = 0.01; val[i] = 0; }         
      valc[i] = (trend[i]==1) ? 1 : (trend[i]==-1) ? 2 : 0;
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