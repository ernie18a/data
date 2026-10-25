//------------------------------------------------------------------
#property copyright    "© mladen, 2018"
#property link         "mladenfx@gmail.com"
#property version      "1.00"
#property description  "BB squeeze on chart"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 11
#property indicator_plots   6

#property indicator_label1  "squeeze area"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "BB upper band"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrGainsboro,clrLimeGreen
#property indicator_label3  "Keltner channel upper band"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "BB and Keltner channel middle value"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrSilver,clrLimeGreen,clrOrange
#property indicator_width4  2
#property indicator_label5  "Keltner channel lower band"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrSilver
#property indicator_style5  STYLE_DOT
#property indicator_label6  "BB lower band"
#property indicator_type6   DRAW_COLOR_LINE
#property indicator_color6  clrGainsboro,clrOrange
//
//---
//
input int                inpPeriod        = 20;          // BB and Keltner period
input ENUM_APPLIED_PRICE inpPrice         = PRICE_CLOSE; // Price 
input double             inpBbMultiplier  = 2.0;         // BB width
input double             inpKcMultiplier  = 1.5;         // Keltner channel width, <=0 same as BB width)
//
//---
//
double mid[],midc[],bbup[],bbupc[],bbdn[],bbdnc[],kelu[],keld[],sqzu[],sqzd[],atr[],_kcMultiplier;;
int _bbHandle,_atrHandle;

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
{
   //---- indicator buffers mapping
         SetIndexBuffer(0,sqzu  ,INDICATOR_DATA);
         SetIndexBuffer(1,sqzd  ,INDICATOR_DATA);
         SetIndexBuffer(2,bbup  ,INDICATOR_DATA);
         SetIndexBuffer(3,bbupc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,kelu  ,INDICATOR_DATA);
         SetIndexBuffer(5,mid   ,INDICATOR_DATA);
         SetIndexBuffer(6,midc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(7,keld  ,INDICATOR_DATA);
         SetIndexBuffer(8,bbdn  ,INDICATOR_DATA);
         SetIndexBuffer(9,bbdnc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(10,atr  ,INDICATOR_CALCULATIONS);
   //--- handles
         _kcMultiplier = (inpKcMultiplier<=0) ? inpBbMultiplier : inpKcMultiplier;
         _bbHandle     = iBands(_Symbol,0,inpPeriod,0,inpBbMultiplier,inpPrice); if (!_checkHandle(_bbHandle ,"Bollinger bands")) return(INIT_FAILED);
         _atrHandle    = iATR(_Symbol,0,inpPeriod);                              if (!_checkHandle(_atrHandle,"ATR")            ) return(INIT_FAILED);
   //--- indicator short name assignment
         IndicatorSetString(INDICATOR_SHORTNAME,"BB squeeze ("+(string)inpPeriod+","+(string)inpBbMultiplier+","+(string)_kcMultiplier+")");
   return(0);
}

//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 

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
   if(BarsCalculated(_bbHandle)<rates_total)  return(prev_calculated);
   if(BarsCalculated(_atrHandle)<rates_total) return(prev_calculated);
   
   //
   //---
   //
      
      int _copyCount = MathMin(rates_total-prev_calculated+1,rates_total);
            if (CopyBuffer(_bbHandle ,BASE_LINE ,0,_copyCount,mid )!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_bbHandle ,LOWER_BAND,0,_copyCount,bbdn)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_bbHandle ,UPPER_BAND,0,_copyCount,bbup)!=_copyCount) return(prev_calculated);
            if (CopyBuffer(_atrHandle,BASE_LINE ,0,_copyCount,atr )!=_copyCount) return(prev_calculated);
   
   //
   //---
   //

   int i=(int)MathMax(prev_calculated-1,0); for (; i<rates_total && !_StopFlag; i++)
   {
      keld[i] = mid[i]-atr[i]*_kcMultiplier;
      kelu[i] = mid[i]+atr[i]*_kcMultiplier;
      bool _squeeze = (kelu[i]>bbup[i]);
         sqzu[i]  = (_squeeze) ? bbup[i] : mid[i];
         sqzd[i]  = (_squeeze) ? bbdn[i] : mid[i];
         bbupc[i] = (_squeeze) ? 0 : (close[i]>bbup[i]) ? 1 : 0;
         bbdnc[i] = (_squeeze) ? 0 : (close[i]<bbdn[i]) ? 1 : 0;
         midc[i]  = (_squeeze) ? 0 : (close[i]>mid[i])  ? 1 : 2;
   }
   return(i);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
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