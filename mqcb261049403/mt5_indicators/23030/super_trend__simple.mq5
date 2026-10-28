//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Super trend - \"CCI based\" - simple"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_label1  "Super trend"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

enum enUseWhat
{
   use_atr, // Use ATR for calculation
   use_dev  // Use standard deviation for calculation 
};
input int                inpPeriod       = 50;            // Period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_TYPICAL; // Price
input int                inpAtrDevPeriod = 5;             // Atr / standard deviation period
input enUseWhat          inpUseWhat      = use_atr;       // Calculation method 

//
//--- indicator buffers
//

double val[],valc[],trend[],ade[],ma[],price[];
int  ª_adHandle,ª_maHandle,ª_prHandle;

//------------------------------------------------------------------ 
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
   
         SetIndexBuffer(0,val  ,INDICATOR_DATA);
         SetIndexBuffer(1,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,trend,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,ade  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,ma   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,price,INDICATOR_CALCULATIONS);
   //            
   //--- external indicator(s) loading
   //
   
         if (inpUseWhat==use_atr)
               { ª_adHandle=iATR(_Symbol,0,inpAtrDevPeriod);                        if (!_checkHandle(ª_adHandle,"ATR"))                return(INIT_FAILED); }
         else  { ª_adHandle=iStdDev(_Symbol,0,inpAtrDevPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(ª_adHandle,"Standard deviation")) return(INIT_FAILED); }
                 ª_maHandle =iMA(_Symbol,0,inpPeriod,0,MODE_SMA,inpPrice);  if (!_checkHandle(ª_maHandle ,"Average")) return(INIT_FAILED);
                 ª_prHandle =iMA(_Symbol,0,1        ,0,MODE_SMA,inpPrice);  if (!_checkHandle(ª_prHandle ,"Prices"))  return(INIT_FAILED);

   //
   //--- indicator short name assignment
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Super trend ("+(string)inpPeriod+")");
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
         if (CopyBuffer(ª_adHandle,0,0,_copyCount,ade  )!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,ma   )!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_prHandle,0,0,_copyCount,price)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      trend[i] = (price[i]>ma[i]) ? 1 : (price[i]<ma[i]) ? -1 : (i>0) ? trend[i-1] : 0;
         val[i]  = (i>0) ? (trend[i]==1) ? MathMax(low[i]-ade[i],val[i-1]) : MathMin(high[i]+ade[i],val[i-1]) : close[i];
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
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
//+------------------------------------------------------------------+
