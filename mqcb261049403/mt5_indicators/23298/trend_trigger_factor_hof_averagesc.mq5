//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend trigger factor"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend trigger factor levels"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  0
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrOrangeRed
#property indicator_width3  2

//
//---
//

input int                inpPeriod     = 15;            // Period
input int                inpAvgPeriod  = 5;             // Pre-smoothing period
input ENUM_MA_METHOD     inpAvgMethod  = MODE_EMA;      // Pre-smoothing method
input double             inpLevels     = 100;           // Levels at +- (nnn)

double val[],valc[],lev[],fup[],fdn[],mah[],mal[]; 
string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};
int    ª_mahHandle,ª_malHandle,ª_maPeriod; 

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
         SetIndexBuffer(2,lev ,INDICATOR_DATA); 
         SetIndexBuffer(3,val ,INDICATOR_DATA); 
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,mah ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,mal ,INDICATOR_CALCULATIONS);
         
         ª_maPeriod  = (inpAvgPeriod>1) ? inpAvgPeriod : 1;
         ª_mahHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,PRICE_HIGH); if (!_checkHandle(ª_mahHandle,"Average of high")) return(INIT_FAILED);
         ª_malHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,PRICE_LOW);  if (!_checkHandle(ª_malHandle,"Average of low"))  return(INIT_FAILED);
         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend trigger factor "+ª_maNames[inpAvgMethod]+" ("+(string)inpPeriod+","+(string)ª_maPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------ 

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
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (mah[i]==EMPTY_VALUE) mah[i] = high[i];
      if (mal[i]==EMPTY_VALUE) mal[i] = low[i];
         
         int _start  = i-inpPeriod  +1; if (_start<0)  _start  = 0;
         int _starto = i-inpPeriod*2+1; if (_starto<0) _starto = 0;
         
         //
         //---
         //
         
            double HighestHighRecent = mah[ArrayMaximum(mah,_start ,inpPeriod)];
            double HighestHighOlder  = mah[ArrayMaximum(mah,_starto,inpPeriod)];
            double LowestLowRecent   = mal[ArrayMinimum(mal,_start ,inpPeriod)];
            double LowestLowOlder    = mal[ArrayMinimum(mal,_starto,inpPeriod)];
            double BuyPower          = HighestHighRecent - LowestLowOlder;
            double SellPower         = HighestHighOlder  - LowestLowRecent;

         //
         //---
         //
         
         val[i]  = (BuyPower+SellPower!=0) ? 100*(BuyPower-SellPower)/(0.5*(BuyPower+SellPower)) : 0;
         valc[i] = (val[i]>inpLevels) ? 1 : (val[i]<-inpLevels) ? 2 : 0;
         lev[i]  = (val[i]>0) ? inpLevels : (val[i]<0) ? -inpLevels : 0;
         fup[i]  =  val[i];
         fdn[i]  = (val[i]>0) ? MathMin(val[i],inpLevels) : MathMax(val[i],-inpLevels);
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

