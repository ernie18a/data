//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "CCI  - atr or std based"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "CCI"
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
enum enColorMode
{
   clr_onSlope, // Change color on slope change
   clr_onZero   // Change color on zero cross
};
input int                inpPeriod       = 50;            // Period
input int                inpSmoothing    = 0;             // Smoothing period (<=1 for no smoothing)
input ENUM_APPLIED_PRICE inpPrice        = PRICE_TYPICAL; // Price
input enUseWhat          inpUseWhat      = use_dev;       // Calculation method 
input enColorMode        inpColorMode    = clr_onZero;    // Color changing method 

//
//--- indicator buffers
//

double val[],valc[],ade[],ma[],price[];
int  ª_adHandle,ª_maHandle,ª_prHandle,ª_prPeriod;
string ª_cciTypes[] = {"ATR based","STD based"};
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
         SetIndexBuffer(2,ade  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,ma   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,price,INDICATOR_CALCULATIONS);
   //            
   //--- external indicator(s) loading
   //
   
         ª_prPeriod = (inpSmoothing>1) ? inpSmoothing : 1;
         if (inpUseWhat==use_atr)
               { ª_adHandle=iATR(_Symbol,0,inpPeriod);                        if (!_checkHandle(ª_adHandle,"ATR"))                return(INIT_FAILED); }
         else  { ª_adHandle=iStdDev(_Symbol,0,inpPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(ª_adHandle,"Standard deviation")) return(INIT_FAILED); }
                 ª_maHandle =iMA(_Symbol,0,inpPeriod ,0,MODE_SMA,inpPrice);   if (!_checkHandle(ª_maHandle,"Average"))            return(INIT_FAILED);
                 ª_prHandle =iMA(_Symbol,0,ª_prPeriod,0,MODE_SMA,inpPrice);   if (!_checkHandle(ª_prHandle,"Prices"))             return(INIT_FAILED);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,ª_cciTypes[inpUseWhat]+" CCI ("+(string)inpPeriod+(ª_prPeriod>1 ? ","+(string)ª_prPeriod : "")+")");
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
      val[i]  = (ade[i]!=0) ? (price[i]-ma[i])/(0.015*ade[i]) : 0;
      if (inpColorMode==clr_onSlope)
            valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1]: 0;
      else  valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : 0;
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
