//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Trend  intensity index"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "Filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend intensity index levels"
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
input ENUM_MA_METHOD     inpMethod     = MODE_SMA;      // Method
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE;   // Price
input double             inpLevelHigh  = 80;            // Levels up
input double             inpLevelLow   = 20;            // Levels down

double val[],valc[],lev[],fup[],fdn[],maa[],map[]; 
string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};
int    ª_mapHandle,ª_maaHandle,ª_maPeriod; 

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
         SetIndexBuffer(5,maa ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,map ,INDICATOR_CALCULATIONS);
         
         ª_maPeriod  = (inpPeriod>0) ? inpPeriod*2 : 2;
         ª_maaHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpMethod,inpPrice); if (!_checkHandle(ª_maaHandle,"Average")) return(INIT_FAILED);
         ª_mapHandle = iMA(_Symbol,0,1          ,0,inpMethod,inpPrice); if (!_checkHandle(ª_mapHandle,"Price"))   return(INIT_FAILED);
         
   //
   //---
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend intensity index "+ª_maNames[inpMethod]+" ("+(string)inpPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { Print(TimeToString(TimeLocal(),TIME_SECONDS)); return; }

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
         if (CopyBuffer(ª_maaHandle,0,0,_copyCount,maa)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_mapHandle,0,0,_copyCount,map)!=_copyCount) return(prev_calculated);

   //
   //
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (maa[i]==EMPTY_VALUE) maa[i] = 0;
      if (map[i]==EMPTY_VALUE) map[i] = 0;
         double sumUpDeviations = 0;
         double sumDnDeviations = 0;
               for(int k=0; k<inpPeriod && i>=k; k++)
               {
                  double diff = map[i-k]-maa[i];
                  if (diff>0)
                        sumUpDeviations += diff;
                  else  sumDnDeviations -= diff;
               }               
         if ((sumUpDeviations+sumDnDeviations)!=0)
               val[i] = 100*sumUpDeviations/(sumUpDeviations+sumDnDeviations);
         else  val[i] = 0; 
      
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

