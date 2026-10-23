//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "EMA to SMA MACD"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   4
#property indicator_label1  "Macd fill area"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'215,255,215',C'255,230,230'
#property indicator_label2  "Signal fill area"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  clrMediumSeaGreen,clrOrange
#property indicator_label3  "EMA to SMA MACD"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_label4  "Signal"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrDarkGray
#property indicator_width4  2

//
//--- input parameters
//

input int                inpPeriod       = 26;          // Period
input int                inpSignalPeriod =  5;          // Signal period
input ENUM_APPLIED_PRICE inpPrice        = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double fillmu[],fillmd[],fillu[],filld[],macd[],signal[],ema[],sma[];
int ª_emaHandle,ª_smaHandle,ª_maPeriod;


//------------------------------------------------------------------
// Custom indicator initialization function                          
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillmu,INDICATOR_DATA);
         SetIndexBuffer(1,fillmd,INDICATOR_DATA);
         SetIndexBuffer(2,fillu ,INDICATOR_DATA);
         SetIndexBuffer(3,filld ,INDICATOR_DATA);
         SetIndexBuffer(4,macd  ,INDICATOR_DATA);
         SetIndexBuffer(5,signal,INDICATOR_DATA);
         SetIndexBuffer(6,ema   ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,sma   ,INDICATOR_CALCULATIONS);
            ª_maPeriod  = inpPeriod>0 ? inpPeriod : 1;
            ª_emaHandle = iMA(_Symbol,0,ª_maPeriod,0,MODE_EMA,inpPrice); if (!_checkHandle(ª_emaHandle,"EMA")) { return(INIT_FAILED); }
            ª_smaHandle = iMA(_Symbol,0,ª_maPeriod,0,MODE_SMA,inpPrice); if (!_checkHandle(ª_smaHandle,"SMA")) { return(INIT_FAILED); }
         
            iSignal.init(inpSignalPeriod);
   //
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"EMA to SMA MACD ("+(string)inpPeriod+","+(string)inpSignalPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

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
         if (CopyBuffer(ª_emaHandle,0,0,_copyCount,ema)!=_copyCount) return(prev_calculated);
         if (CopyBuffer(ª_smaHandle,0,0,_copyCount,sma)!=_copyCount) return(prev_calculated);
   
   //
   //---
   //
  

   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (ema[i]==EMPTY_VALUE) ema[i]=0;
      if (sma[i]==EMPTY_VALUE) sma[i]=0;
      macd[i]   = fillu[i] = ema[i]-sma[i];
      signal[i] = filld[i] = iSignal.calculate(macd[i],i);
      fillmd[i] = 0;
      fillmu[i] = (macd[i]>0) ? MathMax(MathMin(macd[i],signal[i]),0) : MathMin(MathMax(macd[i],signal[i]),0);
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
   #define _ringSize 32 
   private :
      struct scSmaArrayStruct
         {
            double value;
            double summ;
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
            m_arraySize = m_period+_ringSize;
               ArrayResize(m_array,m_arraySize);
               for (int k=0; k<m_arraySize; k++)
               {
                  m_array[k].value = 
                  m_array[k].summ  = 0;
               }
         }
         
     double calculate(double value, int i)
         {
            int _indC = (i)%m_arraySize; m_array[_indC].value=value;
               if (i>m_period)
               {
                  int _indP = (i-1       )%m_arraySize;
                  int _indB = (i-m_period)%m_arraySize;
                     m_array[_indC].summ = m_array[_indP].summ+value-m_array[_indB].value;
               }
               else
               {
                     m_array[_indC].summ = 0;
                     int k=0; for(int _indR=_indC; k<m_period && i>=k; k++,_indR--)
                     {
                        if (_indR<0) 
                            _indR += m_arraySize; m_array[_indC].summ += m_array[_indR].value;
                     }
                     return(m_array[_indC].summ/(double)k);
               }         
               return(m_array[_indC].summ/(double)m_period);
      }   
   #undef _ringSize
};
CSma iSignal;

//
//---
//
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
//------------------------------------------------------------------