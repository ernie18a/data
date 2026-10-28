//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Stochastic of choosable price"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Stochastic"
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

enum enPrices
{
   pr_close   =PRICE_CLOSE,    // Close
   pr_open    =PRICE_OPEN,     // Open
   pr_high    =PRICE_HIGH,     // High
   pr_low     =PRICE_LOW,      // Low
   pr_median  =PRICE_MEDIAN,   // Median
   pr_typical =PRICE_TYPICAL,  // Typical
   pr_weighted=PRICE_WEIGHTED, // Wighted
   pr_highlow =-99             // High/Low
};
input int                inpStoPeriod  = 14;          // Stochastic period
input int                inpStoSlowing =  3;          // Stochastic slowing
input int                inpStoSignal  =  3;          // Stochastic signal period
input ENUM_MA_METHOD     inpStoMethod  = MODE_EMA;    // Stochastic signal method
input enPrices           inpPrice      = pr_close;    // Price 

//
//--- buffers declarations
//

double sto[],stoc[],sig[]; 

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
         
         //
         //---
         //

         string _priceType = StringSubstr(EnumToString(inpPrice),3);
                _priceType = (_priceType!="highlow") ? _priceType+"/"+_priceType : "low/high";
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Stochastic "+_priceType+" ("+(string)inpStoPeriod+","+(string)inpStoSlowing+","+(string)inpStoSignal+")");
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
   int start= prev_calculated-1; if (start<0) start=0; for (int i=start; i<rates_total && !_StopFlag; i++)
   {
      double _price,_priceh,_pricel; 
      switch(inpPrice) 
      { 
         case pr_close:    _price = _priceh = _pricel = close[i];                               break; 
         case pr_open:     _price = _priceh = _pricel = open[i];                                break; 
         case pr_high:     _price = _priceh = _pricel = high[i];                                break; 
         case pr_low:      _price = _priceh = _pricel = low[i];                                 break; 
         case pr_median:   _price = _priceh = _pricel = (high[i]+low[i])/2.0;                   break; 
         case pr_typical:  _price = _priceh = _pricel = (high[i]+low[i]+close[i])/3.0;          break; 
         case pr_weighted: _price = _priceh = _pricel = (high[i]+low[i]+close[i]+close[i])/4.0; break; 
         default :         _price  = close[i];
                           _priceh = high[i];
                           _pricel = low[i];
      }
      sto[i] = iStoch(_price,_priceh,_pricel,inpStoPeriod,inpStoSlowing,i);
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
//------------------------------------------------------------------
