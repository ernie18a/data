//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Stochastic of one of 4 types of averages"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Stochastic of average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input int                inpStoPeriod  = 32;          // Stochastic period
input int                inpStoSlowing =  3;          // Stochastic slowing
input int                inpAvgPeriod  = 14;          // Average period
input ENUM_MA_METHOD     inpAvgMethod  = MODE_EMA;    // Average method
input ENUM_APPLIED_PRICE inpAvgPrice   = PRICE_CLOSE; // Price 

//
//--- buffers declarations
//

double val[],valc[],avg[]; string ª_maNames[] = {"SMA","EMA","SMMA","LWMA"};
int  ª_maHandle,ª_maPeriod; 

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,val,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,avg ,INDICATOR_CALCULATIONS);
         
         //
         //---
         //
         
         ª_maPeriod = (inpAvgPeriod>1) ? inpAvgPeriod : 1;
         ª_maHandle = iMA(_Symbol,0,ª_maPeriod ,0,inpAvgMethod,inpAvgPrice); if (!_checkHandle(ª_maHandle,"Average")) return(INIT_FAILED);
         
         IndicatorSetInteger(INDICATOR_LEVELS,2);
            IndicatorSetDouble(INDICATOR_LEVELVALUE,0,0);
            IndicatorSetDouble(INDICATOR_LEVELVALUE,1,100);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic of "+ª_maNames[inpAvgMethod]+" ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)ª_maPeriod+")");
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
         if (CopyBuffer(ª_maHandle,0,0,_copyCount,avg)!=_copyCount) return(prev_calculated);

   //
   //---
   //
   
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      if (avg[i]==EMPTY_VALUE) avg[i] = close[i];
         val[i]  = iStoch(avg[i],avg[i],avg[i],inpStoPeriod,inpStoSlowing,i);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 :(val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }
   return (i);
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
