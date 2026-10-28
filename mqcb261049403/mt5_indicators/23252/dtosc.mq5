//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Dynamic Trader Oscillator"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   2
#property indicator_label1  "DTOSC"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrMediumSeaGreen,clrOrangeRed
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_DOT
#property indicator_level1  0
#property indicator_level2  100
#include <MovingAverages.mqh>

//
//--- input parameters
//

input int                inpPeriod     = 14;          // Period
input ENUM_APPLIED_PRICE inpPrice      = PRICE_CLOSE; // Price 
input int                inpStoPeriod  = 32;          // Stochastic period
input int                inpStoSlowing =  3;          // Stochastic slowing
input int                inpStoSignal  =  3;          // Stochastic signal period
input ENUM_MA_METHOD     inpStoMethod  = MODE_EMA;    // Stochastic signal method

//
//--- buffers declarations
//

double sto[],stoc[],sig[],rsi[]; 
int  ª_rsiHandle,ª_rsiPeriod; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,sto ,INDICATOR_DATA);
         SetIndexBuffer(1,stoc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,sig ,INDICATOR_DATA);
         SetIndexBuffer(3,rsi ,INDICATOR_CALCULATIONS);

         //
         //---
         //
                  
         ª_rsiPeriod   = (inpPeriod>1) ? inpPeriod : 1;
         ª_rsiHandle   = iRSI(_Symbol,0,ª_rsiPeriod,inpPrice); if (!_checkHandle(ª_rsiHandle,"RSI")) return(INIT_FAILED);
         
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"\"DTOSC\" ("+(string)inpPeriod+","+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)inpStoSignal+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//  Custom indicator iteration function
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
         if (CopyBuffer(ª_rsiHandle,0,0,_copyCount,rsi)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   int start= prev_calculated-1; if (start<0) start=0; for (int i=start; i<rates_total && !_StopFlag; i++)
   {
      if (rsi[i]==EMPTY_VALUE) rsi[i] = 0;
         sto[i] = iStoch(rsi[i],rsi[i],rsi[i],inpStoPeriod,inpStoSlowing,i);
   }
   int weightsum=0;
   switch (inpStoMethod)
   {
      case MODE_SMA  : SimpleMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig); break;
      case MODE_EMA  : ExponentialMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig); break;
      case MODE_SMMA : SmoothedMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig); break;
      default        : LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,inpStoSignal,sto,sig,weightsum);
   }
   for (int i=start; i<rates_total && !_StopFlag; i++) stoc[i] = (sto[i]>sig[i]) ? 0 : (sto[i]<sig[i]) ? 1 : (i>0) ? stoc[i-1] : 0;
   return (rates_total);
}

//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

double iStoch(double price, double priceHigh, double priceLow, int period, int slowing, int i,int instance=0)
{
   #define ¤ instance
   #define _functionInstances 1
   #define _functionRingSize 32
   
      class cStochasticWork
      {
         public :
            int    originalPeriod;
            int    period;
            int    slowing;
            int    slowingSize;
            double maxArray[];
            double minArray[];
            double diffh[];
            double diffl[];
            double sumh[];
            double suml[];
         
            cStochasticWork() { originalPeriod=-1; return; }
           ~cStochasticWork() { ArrayFree(maxArray); ArrayFree(minArray); ArrayFree(diffh); ArrayFree(diffl); ArrayFree(sumh); ArrayFree(suml); return; }
      };
      static cStochasticWork  m_work[_functionInstances];
         if (m_work[¤].originalPeriod!=period)
         {
            m_work[¤].originalPeriod =  period;
            m_work[¤].period         = (period>0) ? period : 1;
            m_work[¤].slowing        = (slowing>0) ? slowing : 1;
            m_work[¤].slowingSize    = m_work[¤].slowing+_functionRingSize;
                  ArrayResize(m_work[¤].maxArray,m_work[¤].period);      ArrayInitialize(m_work[¤].maxArray,priceHigh);
                  ArrayResize(m_work[¤].minArray,m_work[¤].period);      ArrayInitialize(m_work[¤].minArray,priceLow);
                  ArrayResize(m_work[¤].diffh   ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].diffh   ,0);
                  ArrayResize(m_work[¤].diffl   ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].diffl   ,0);
                  ArrayResize(m_work[¤].sumh    ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].sumh    ,0);
                  ArrayResize(m_work[¤].suml    ,m_work[¤].slowingSize); ArrayInitialize(m_work[¤].suml    ,0);
         }
      
      //
      //---
      //
      
      int _pos = (i) % m_work[¤].period;
                       m_work[¤].minArray[_pos]=priceLow;
                       m_work[¤].maxArray[_pos]=priceHigh;
         double min =  m_work[¤].minArray[ArrayMinimum(m_work[¤].minArray)];
         double max =  m_work[¤].maxArray[ArrayMaximum(m_work[¤].maxArray)];
               _pos = (i) % m_work[¤].slowingSize;
                       m_work[¤].diffh[_pos] = max  -min;
                       m_work[¤].diffl[_pos] = price-min;

                       //
                       //---
                       //
                         
                       if (i>m_work[¤].slowing)
                       {
                           int _posp = (i-1                ) % m_work[¤].slowingSize;
                           int _posf = (i-m_work[¤].slowing) % m_work[¤].slowingSize;
                              m_work[¤].sumh[_pos] = m_work[¤].sumh[_posp]+m_work[¤].diffh[_pos]-m_work[¤].diffh[_posf];
                              m_work[¤].suml[_pos] = m_work[¤].suml[_posp]+m_work[¤].diffl[_pos]-m_work[¤].diffl[_posf];
                       }
                       else
                       {
                           m_work[¤].sumh[_pos] = m_work[¤].diffh[_pos];
                           m_work[¤].suml[_pos] = m_work[¤].diffl[_pos];
                           for (int k=1, _posp=_pos-1; k<m_work[¤].slowing; k++, _posp--)
                           {
                              if (_posp<0) _posp += m_work[¤].slowingSize; 
                                 m_work[¤].sumh[_pos] += m_work[¤].diffh[_posp];
                                 m_work[¤].suml[_pos] += m_work[¤].diffl[_posp];
                           }
                       }
      return((m_work[¤].sumh[_pos]!=0.0)? 100.0*m_work[¤].suml[_pos]/m_work[¤].sumh[_pos]:0);
      
      //
      //---
      //
      
   #undef ¤ #undef _functionInstances #undef _functionRingSize
}

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
