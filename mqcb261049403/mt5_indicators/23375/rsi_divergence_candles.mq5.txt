//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Rsi divergence candles"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrMediumSeaGreen,clrOrangeRed

input int                inpFastRsiPeriod  = 8;           // Fast RSI period
input int                inpSlowRsiPeriod  = 55;          // Slow RSI period
input int                inpSmoothPeriod   = 10;          // Smoothing period
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price

//
//--- indicator buffers
//
double rsio[],rsih[],rsil[],rsic[],rsicl[],rsif[],rsis[],ª_workRsi[4];
int ª_rsfHandle,ª_rssHandle;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,rsio ,INDICATOR_DATA);
         SetIndexBuffer(1,rsih ,INDICATOR_DATA);
         SetIndexBuffer(2,rsil ,INDICATOR_DATA);
         SetIndexBuffer(3,rsic ,INDICATOR_DATA);
         SetIndexBuffer(4,rsicl,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(5,rsif ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,rsis ,INDICATOR_CALCULATIONS);

         ª_rsfHandle   = iRSI(_Symbol,0,inpFastRsiPeriod,inpPrice);  if (!_checkHandle(ª_rsfHandle,"Fast RSI"))  return(INIT_FAILED);
         ª_rssHandle   = iRSI(_Symbol,0,inpSlowRsiPeriod,inpPrice);  if (!_checkHandle(ª_rssHandle,"Slow RSI"))  return(INIT_FAILED);
         
            iSma[0].init(inpSmoothPeriod);
            iSma[1].init(inpSmoothPeriod);
   //
   //---
   //      
   IndicatorSetString(INDICATOR_SHORTNAME,"Rsi divergence candles ("+(string)inpFastRsiPeriod+","+(string)inpSlowRsiPeriod+","+(string)inpSmoothPeriod+")");
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
         if (CopyBuffer(ª_rsfHandle,0,0,_copyCount,rsif)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_rssHandle,0,0,_copyCount,rsis)!=_copyCount) return(prev_calculated);

   //
   //---
   //

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (rsif[i]==EMPTY_VALUE) rsif[i] = 0;
      if (rsis[i]==EMPTY_VALUE) rsis[i] = 0;
         rsio[i]  = iSma[0].calculate(rsis[i],i);
         rsih[i]  = (rsif[i]>rsis[i]) ? rsif[i] : rsis[i];
         rsil[i]  = (rsif[i]<rsis[i]) ? rsif[i] : rsis[i];
         rsic[i]  = iSma[1].calculate(rsif[i],i);
         rsicl[i] = (rsic[i]>rsio[i]) ? 1 :(rsic[i]<rsio[i]) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CSma
{
   private :
      struct scSmaArrayStruct
         {
            double value;
            double sum;
            void init() { value=sum=0; }
         };
      scSmaArrayStruct m_array[];
      int              m_arraySize;
      int              m_period;
   public :
      CSma() { init(1);            return; }
     ~CSma() { ArrayFree(m_array); return; }
     
      //
      //---
      //
      
      void init(int period) 
         { 
            m_period    = (period>1) ? period : 1; 
            m_arraySize = m_period+32;
               ArrayResize(m_array,m_arraySize); for (int k=0; k<m_arraySize; k++) m_array[k].init();
         }
         
      double calculate(double value, int i)
         {
            int _indC = (i)%m_arraySize; m_array[_indC].value=value;
            if (i>m_period)
               {
                  int _indP = (i-1       )%m_arraySize;
                  int _indF = (i-m_period)%m_arraySize;
                     m_array[_indC].sum = m_array[_indP].sum+value-m_array[_indF].value;
               }
            else
               {
                     m_array[_indC].sum = 0;
                     int k=0; for(int _indR=_indC; k<m_period && i>=k; k++,_indR--)
                     {
                        if (_indR<0) 
                            _indR += m_arraySize; m_array[_indC].sum += m_array[_indR].value;
                     }
                     return(m_array[_indC].sum/(double)k);
               }         
            return(m_array[_indC].sum/(double)m_period);
      }   
};
CSma iSma[2];

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