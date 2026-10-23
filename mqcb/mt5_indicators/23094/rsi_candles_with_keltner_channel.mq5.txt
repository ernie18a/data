//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Rsi candles with \"Keltner\" channels"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 12
#property indicator_plots   4
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_label2  "average"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "channel up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_DOT
#property indicator_label4  "channel up"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_style4  STYLE_DOT

input int    inpRsiPeriod  = 14;  // RSI period
input int    inpAvgPeriod  = 0;   // Channel period (<=1 for same as RSI period)
input double inpMultiplier = 1.5; // Channels multiplier

//
//--- indicator buffers
//
double rsio[],rsih[],rsil[],rsic[],rsicl[],kel[],kelu[],keld[],tr[],rsi[],atr[],avg[],ª_workRsi[4];
int ª_rshHandle,ª_rslHandle,ª_rsoHandle,ª_rscHandle,ª_avgPeriod;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer( 0,rsio ,INDICATOR_DATA);
         SetIndexBuffer( 1,rsih ,INDICATOR_DATA);
         SetIndexBuffer( 2,rsil ,INDICATOR_DATA);
         SetIndexBuffer( 3,rsic ,INDICATOR_DATA);
         SetIndexBuffer( 4,rsicl,INDICATOR_COLOR_INDEX);
         SetIndexBuffer( 5,kel  ,INDICATOR_DATA);
         SetIndexBuffer( 6,kelu ,INDICATOR_DATA);
         SetIndexBuffer( 7,keld ,INDICATOR_DATA);
         SetIndexBuffer( 8,tr   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer( 9,atr  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(10,rsi  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(11,avg  ,INDICATOR_CALCULATIONS);

         //
         //---
         //
         
         ª_rshHandle   = iRSI(_Symbol,0,inpRsiPeriod,PRICE_HIGH);  if (!_checkHandle(ª_rshHandle,"RSI of high"))  return(INIT_FAILED);
         ª_rslHandle   = iRSI(_Symbol,0,inpRsiPeriod,PRICE_LOW );  if (!_checkHandle(ª_rslHandle,"RSI of low"))   return(INIT_FAILED);
         ª_rsoHandle   = iRSI(_Symbol,0,inpRsiPeriod,PRICE_OPEN);  if (!_checkHandle(ª_rsoHandle,"RSI of open"))  return(INIT_FAILED);
         ª_rscHandle   = iRSI(_Symbol,0,inpRsiPeriod,PRICE_CLOSE); if (!_checkHandle(ª_rscHandle,"RSI of close")) return(INIT_FAILED);
         ª_avgPeriod   = (inpAvgPeriod>1) ? inpAvgPeriod : inpRsiPeriod;
   //
   //---
   //      
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi candles ("+(string)inpRsiPeriod+","+(string)ª_avgPeriod+","+(string)inpMultiplier+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
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
         if (CopyBuffer(ª_rshHandle,0,0,_copyCount,rsih)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_rslHandle,0,0,_copyCount,rsil)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_rsoHandle,0,0,_copyCount,rsio)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_rscHandle,0,0,_copyCount,rsic)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (rsil[i] == EMPTY_VALUE) rsil[i]=0;
      if (rsih[i] == EMPTY_VALUE) rsih[i]=0;
      if (rsio[i] == EMPTY_VALUE) rsio[i]=0;
      if (rsic[i] == EMPTY_VALUE) rsic[i]=0;
                   ª_workRsi[1] = rsil[i]; 
                   ª_workRsi[0] = rsih[i]; 
                   ª_workRsi[2] = rsio[i]; 
                   ª_workRsi[3] = rsic[i]; 
                                  rsih[i] = ª_workRsi[ArrayMaximum(ª_workRsi)];
                                  rsil[i] = ª_workRsi[ArrayMinimum(ª_workRsi)];
         
         //
         //---
         //
         
         rsi[i] = (rsih[i]+rsil[i]+rsio[i]+rsic[i])/4.0;
         tr[i]  = (i>0) ? MathMax(rsih[i],rsic[i-1])-MathMin(rsil[i],rsic[i-1]) : rsih[i]-rsil[i];
         if (i>ª_avgPeriod)
            {
               avg[i] = avg[i-1]+rsi[i]-rsi[i-ª_avgPeriod];
               atr[i] = atr[i-1]+tr[i]-tr[i-ª_avgPeriod];
            }
         else
            {
               avg[i] = atr[i] = 0;
               for (int k=0; k<ª_avgPeriod && i>=k; k++)
               {
                  avg[i] += rsi[i-k];
                  atr[i] += tr[i-k];
               }
            }            
         kel[i]  = avg[i]/(double)ª_avgPeriod;
         kelu[i] = kel[i]+inpMultiplier*atr[i]/(double)ª_avgPeriod;
         keld[i] = kel[i]-inpMultiplier*atr[i]/(double)ª_avgPeriod;
         rsicl[i]= (rsic[i]>rsio[i]) ? 1 : (rsic[i]<rsio[i]) ? 2 : 0;
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
//+------------------------------------------------------------------+