//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Volatility quality"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1

#property indicator_label1  "Volatility quality"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrange
#property indicator_width1  2
  
//
//---
//

input int             inpPriceSmoothing         = 5;          // Price smoothing period
input ENUM_MA_METHOD  inpPriceSmoothingMethod   = MODE_LWMA;  // Price smoothing method
input double          inpFilter                 = 20.0;       // Filter (% of ATR)

//
//--
//

double val[],valc[],mah[],mal[],mao[],mac[],atr[],ª_filter;
int ª_maHandleh,ª_maHandlel,ª_maHandleo,ª_maHandlec,ª_atrHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   ª_maHandleh = iMA(_Symbol,0,inpPriceSmoothing,0,inpPriceSmoothingMethod,PRICE_HIGH);  if (!_checkHandle(ª_maHandleh,"average of high"))  { return(INIT_FAILED); }
   ª_maHandlel = iMA(_Symbol,0,inpPriceSmoothing,0,inpPriceSmoothingMethod,PRICE_LOW);   if (!_checkHandle(ª_maHandlel,"average of low"))   { return(INIT_FAILED); }
   ª_maHandleo = iMA(_Symbol,0,inpPriceSmoothing,0,inpPriceSmoothingMethod,PRICE_OPEN);  if (!_checkHandle(ª_maHandleo,"average of open"))  { return(INIT_FAILED); }
   ª_maHandlec = iMA(_Symbol,0,inpPriceSmoothing,0,inpPriceSmoothingMethod,PRICE_CLOSE); if (!_checkHandle(ª_maHandlec,"average of close")) { return(INIT_FAILED); }
   ª_atrHandle = iATR(_Symbol,0,inpPriceSmoothing);                                      if (!_checkHandle(ª_atrHandle,"ATR"))              { return(INIT_FAILED); }

   //
   //---
   //
   
      SetIndexBuffer(0,val    ,INDICATOR_DATA);
      SetIndexBuffer(1,valc   ,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(2,mah    ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(3,mal    ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(4,mao    ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(5,mac    ,INDICATOR_CALCULATIONS);
      SetIndexBuffer(6,atr    ,INDICATOR_CALCULATIONS);
         ª_filter = inpFilter/100.0;
   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Volatility quality ("+(string)inpPriceSmoothing+", filter "+(string)inpFilter+"% of ATR)");
   return(0);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

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
         if (CopyBuffer(ª_maHandleh,0,0,_copyCount,mah)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_maHandlel,0,0,_copyCount,mal)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_maHandleo,0,0,_copyCount,mao)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_maHandlec,0,0,_copyCount,mac)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_atrHandle,0,0,_copyCount,atr)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   #define cHigh  mah[i]
   #define cLow   mal[i]
   #define cOpen  mao[i]
   #define cClose mac[i]
   #define pClose ((i>0) ? mac[i-1] : mac[i])
   
   int i = (prev_calculated>0 ? prev_calculated-1 : 0); for (; i<rates_total && !_StopFlag; i++)
   {
      if (mah[i] == EMPTY_VALUE) mah[i] = high[i];
      if (mal[i] == EMPTY_VALUE) mal[i] = low[i];
      if (mao[i] == EMPTY_VALUE) mao[i] = open[i];
      if (mac[i] == EMPTY_VALUE) mac[i] = close[i];
      if (atr[i] == EMPTY_VALUE) atr[i] = 0;
      double trueRange = (cHigh>pClose ? cHigh : pClose)-(cLow<pClose? cLow :pClose);
      double range     = cHigh-cLow;
      double vqi       = (range>0 && trueRange>0) ? ((cClose-pClose)/trueRange + (cClose-cOpen)/range)*0.5 : (i>0) ? val[i-1] : 0;

      //
      //
      //
      //
      //
  
         val[i] = (i>0) ? val[i-1]+(vqi>0?vqi:-vqi)*(cClose-pClose+cClose-cOpen)*0.5 : 0;
            if (ª_filter > 0 && i>0) if ((val[i]>val[i-1] ? val[i]-val[i-1] : val[i-1]-val[i]) < ª_filter*atr[i]) val[i] = val[i-1];
            valc[i]  = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return(rates_total);
}

//------------------------------------------------------------------
//  Custom function(s)
//------------------------------------------------------------------
//
//---
//

bool _checkHandle(int _handle, string _description)
{
   static int  _chkHandles[];
          int  _size   = ArraySize(_chkHandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chkHandles,_size+1); _chkHandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chkHandles[i]); ArrayResize(_chkHandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}
//------------------------------------------------------------------
