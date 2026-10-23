//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Phase change index"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Phase change index levels"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_width2  0
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrDarkOrange
#property indicator_width3  2

//
//---
//

input int                inpPeriod     = 30;            // Period
input int                inpSmooth     = 5;             // Smooth period
input ENUM_MA_METHOD     inpMethod     = MODE_SMA;      // Method
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;   // Price
input double             inpLevelHigh  = 80;            // Levels up
input double             inpLevelLow   = 20;            // Levels down

double val[],valc[],lev[],fup[],fdn[],map[]; 
int    ª_mapHandle; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//
//

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
         SetIndexBuffer(5,map ,INDICATOR_CALCULATIONS);
         
         ª_mapHandle = iMA(_Symbol,0,inpSmooth,0,inpMethod,inpPrice); if (!_checkHandle(ª_mapHandle,"Average"))   return(INIT_FAILED);
         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Phase change index "+(string)inpPeriod+","+(string)inpSmooth+")");
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
         if (CopyBuffer(ª_mapHandle,0,0,_copyCount,map)!=_copyCount) return(prev_calculated);

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (map[i]==EMPTY_VALUE) map[i] = 0;
      if (i>=inpPeriod)
      {
         double momentum = map[i]-map[i-inpPeriod];
         double sumUpDi  = 0;
         double sumDnDi  = 0;
         for(int k=1; k<inpPeriod && i>=k; k++)
         {
            double gradient  = map[i-inpPeriod]+momentum*(inpPeriod-k)/(inpPeriod);
            double deviation = map[i-k]-gradient;
            if (deviation > 0)
                  sumUpDi += deviation;
            else  sumDnDi -= deviation;
         } 
         val[i] = ((sumUpDi+sumDnDi)!=0) ? 100-100.0*sumUpDi/(sumUpDi+sumDnDi) : 0;
      }         
      else val[i] = 0;
      valc[i] = (val[i]>inpLevelHigh) ? 1 : (val[i]<inpLevelLow) ? 2 : 0;
      lev[i]  = (valc[i]==1) ? 100 : (valc[i]==2) ? 0 : 50;
      fup[i]  =  val[i];
      fdn[i]  = (val[i]>50) ? MathMin(val[i],inpLevelHigh) : MathMax(val[i],inpLevelLow);
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

