//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "DSL Trend trigger factor"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend trigger factor level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  0
#property indicator_label3  "Trend trigger factor level down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_width3  0
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrDarkGray,clrDodgerBlue,clrOrangeRed
#property indicator_width4  2

//
//---
//

input int                inpPeriod     = 15;            // Period
input int                inpAvgPeriod  = 5;             // Pre-smoothing period
input ENUM_MA_METHOD     inpAvgMethod  = MODE_EMA;      // Pre-smoothing method
input int                inpSignal     = 10;            // DSL signal period

double val[],valc[],levu[],levd[],fup[],fdn[],mah[],mal[]; 
string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};
int    ª_mahHandle,ª_malHandle,ª_maPeriod; double ª_dslAlpha;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,fup ,INDICATOR_DATA);     
         SetIndexBuffer(1,fdn ,INDICATOR_DATA);
         SetIndexBuffer(2,levu,INDICATOR_DATA); 
         SetIndexBuffer(3,levd,INDICATOR_DATA); 
         SetIndexBuffer(4,val ,INDICATOR_DATA); 
         SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(6,mah ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,mal ,INDICATOR_CALCULATIONS);
         
         ª_maPeriod  = (inpAvgPeriod>1) ? inpAvgPeriod : 1;
         ª_mahHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,PRICE_HIGH); if (!_checkHandle(ª_mahHandle,"Average of high")) return(INIT_FAILED);
         ª_malHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,PRICE_LOW);  if (!_checkHandle(ª_malHandle,"Average of low"))  return(INIT_FAILED);
         ª_dslAlpha  = 2.0/(1.0+(inpSignal>1?inpSignal:1));
         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"DSL Trend trigger factor "+ª_maNames[inpAvgMethod]+" ("+(string)inpPeriod+","+(string)ª_maPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------ 
//
//
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
         if (CopyBuffer(ª_mahHandle,0,0,_copyCount,mah)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_malHandle,0,0,_copyCount,mal)!=_copyCount) return(prev_calculated);
         
         //
         //---
         //
         
         static double HighestHighRecent,LowestLowRecent,
                       HighestHighOlder ,LowestLowOlder;
         static int prev_i=-1;

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (prev_i!=i)
      {
         if (mah[i]==EMPTY_VALUE) mah[i] = high[i];
         if (mal[i]==EMPTY_VALUE) mal[i] = low[i];
         
         prev_i = i;
            int start = i-inpPeriod*2+1; if (start<0) start=0;               
                HighestHighOlder    = mah[ArrayMaximum(mah,start,inpPeriod)];
                LowestLowOlder      = mal[ArrayMinimum(mal,start,inpPeriod)];
                start = i-inpPeriod+1; if (start<0) start=0;
                HighestHighRecent   = mah[ArrayMaximum(mah,start,inpPeriod-1)];
                LowestLowRecent     = mal[ArrayMinimum(mal,start,inpPeriod-1)];
      }
         
      //
      //---
      //
         
      double BuyPower  = (mah[i]>HighestHighRecent ? mah[i] : HighestHighRecent) - LowestLowOlder;
      double SellPower = HighestHighOlder   - (mal[i]<LowestLowRecent ? mal[i] : LowestLowRecent);

      //
      //---
      //
         
      val[i] = fup[i] = fdn[i] = (BuyPower+SellPower!=0) ? 100.0*(BuyPower-SellPower)/(0.5*(BuyPower+SellPower)) : 0;
      if (i>0)
      {
         levu[i] = (val[i]>0) ? levu[i-1]+ª_dslAlpha*(val[i]-levu[i-1]) : levu[i-1];
         levd[i] = (val[i]<0) ? levd[i-1]+ª_dslAlpha*(val[i]-levd[i-1]) : levd[i-1];
      }
      else levu[i] = levd[i] = 0;
           valc[i] = (val[i]>levu[i]) ? 1 : (val[i]<levd[i]) ? 2 : 0;
               if (valc[i]==1) fdn[i] = levu[i];
               if (valc[i]==2) fdn[i] = levd[i];
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
   static int  _chandles[];
          int  _size   = ArraySize(_chandles);
          bool _answer = (_handle!=INVALID_HANDLE);
          if  (_answer)
               { ArrayResize(_chandles,_size+1); _chandles[_size]=_handle; }
          else { for (int i=_size-1; i>=0; i--) IndicatorRelease(_chandles[i]); ArrayResize(_chandles,0); Alert(_description+" initialization failed"); }
   return(_answer);
}  
//------------------------------------------------------------------

