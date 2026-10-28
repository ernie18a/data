//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "CCI"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//---
//

input  int                inpPeriod      = 50;            // CCI period
input  int                inpHullPeriod  = 14;            // Hull period
input  double             inpHullDivisor = 2;             // Hull divisor
input  ENUM_APPLIED_PRICE inpPrice       = PRICE_TYPICAL; // Price

double val[],valc[],prices[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val    ,INDICATOR_DATA);
   SetIndexBuffer(1,valc   ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices ,INDICATOR_CALCULATIONS);
      _workCci.init(inpPeriod);
      iHull.init(inpHullPeriod,inpHullDivisor);

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI std based ("+(string)inpPeriod+")(Hull "+(string)inpHullPeriod+" smoothed)");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

#define _setPrice(_priceType,_target,_index) \
   { \
   switch(_priceType) \
   { \
      case PRICE_CLOSE:    _target = close[_index];                                              break; \
      case PRICE_OPEN:     _target = open[_index];                                               break; \
      case PRICE_HIGH:     _target = high[_index];                                               break; \
      case PRICE_LOW:      _target = low[_index];                                                break; \
      case PRICE_MEDIAN:   _target = (high[_index]+low[_index])/2.0;                             break; \
      case PRICE_TYPICAL:  _target = (high[_index]+low[_index]+close[_index])/3.0;               break; \
      case PRICE_WEIGHTED: _target = (high[_index]+low[_index]+close[_index]+close[_index])/4.0; break; \
      default : _target = 0; \
   }}

//
//---
//


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      _setPrice(inpPrice,prices[i],i);
         val[i] = _workCci.calculate(iHull.calculate(prices[i],i,rates_total),i,rates_total);
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
   }      
   return(rates_total);
}

//------------------------------------------------------------------
// Custom class(es)
//------------------------------------------------------------------
//
//---
//

class CCci
{
   private :
      struct sCciWork
      {
         double value;
         double value2;
         double summ;
         double summ2;
      };
      sCciWork  m_work[];
      int       m_period;
      double    m_period2;
      int       m_arraySize;
      
   public :
      CCci() { m_arraySize=-1; m_period=1; }
     ~CCci() { m_arraySize=-1; ArrayFree(m_work); }
     
     //
     //---
     //
     
     void   init(int period) { m_period=period; return; }
     double calculate(double value, int i, int bars)
     {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_work,bars+500); if (m_arraySize<bars) return(0); }
         
         //
         //---
         //
         
         m_work[i].value  = value;
         m_work[i].value2 = value*value;
            if (i>m_period)
                  {
                     m_work[i].summ  = m_work[i-1].summ +m_work[i].value -m_work[i-m_period].value;
                     m_work[i].summ2 = m_work[i-1].summ2+m_work[i].value2-m_work[i-m_period].value2;
                  }
            else  {
                     m_work[i].summ  = m_work[i].value;
                     m_work[i].summ2 = m_work[i].value2;
                     for (int k=1; k<m_period && i>=k; k++)
                     {
                        m_work[i].summ  += m_work[i-k].value; 
                        m_work[i].summ2 += m_work[i-k].value2; 
                     }
                  }         
         double _avg = m_work[i].summ/(double)m_period;
         double _dev = MathSqrt((m_work[i].summ2-m_work[i].summ*_avg)/(double)m_period);
         return(_dev!=0 ? (value-_avg)/(0.015*_dev) : 0);
     }
};
CCci _workCci;

//
//---
//

class CHull
{
   private :
      int    m_fullPeriod;
      int    m_halfPeriod;
      int    m_sqrtPeriod;
      int    m_arraySize;
      double m_weight1;
      double m_weight2;
      double m_weight3;
      struct sHullArrayStruct
         {
            double price;
            double price3;
            double wsum1;
            double wsum2;
            double wsum3;
            double lsum1;
            double lsum2;
            double lsum3;
         };
      sHullArrayStruct m_array[];
   
   public :
      CHull() { init(1,2.0); };
     ~CHull() { ArrayFree(m_array); };
     
     ///
     ///
     ///
     
      bool init(int period, double divisor)
      {
            m_fullPeriod = (int)(period>1 ? period : 1);   
            m_halfPeriod = (int)(m_fullPeriod>1 ? m_fullPeriod/(divisor>1 ? divisor : 1) : 1);
            m_sqrtPeriod = (int) MathSqrt(m_fullPeriod);
            m_arraySize  = -1; m_weight1 = m_weight2 = m_weight3 = 1;
               return(true);
      }
      
      double calculate( double value, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
             
            m_array[i].price=value;
            if (i>m_fullPeriod)
            {
               m_array[i].wsum1 = m_array[i-1].wsum1+value*m_halfPeriod-m_array[i-1].lsum1;
               m_array[i].lsum1 = m_array[i-1].lsum1+value-m_array[i-m_halfPeriod].price;
               m_array[i].wsum2 = m_array[i-1].wsum2+value*m_fullPeriod-m_array[i-1].lsum2;
               m_array[i].lsum2 = m_array[i-1].lsum2+value-m_array[i-m_fullPeriod].price;
            }
            else
            {
               m_array[i].wsum1 = m_array[i].wsum2 =
               m_array[i].lsum1 = m_array[i].lsum2 = m_weight1 = m_weight2 = 0;
               for(int k=0, w1=m_halfPeriod, w2=m_fullPeriod; w2>0 && i>=k; k++, w1--, w2--)
               {
                  if (w1>0)
                  {
                     m_array[i].wsum1 += m_array[i-k].price*w1;
                     m_array[i].lsum1 += m_array[i-k].price;
                     m_weight1 += w1;
                  }                  
                  m_array[i].wsum2 += m_array[i-k].price*w2;
                  m_array[i].lsum2 += m_array[i-k].price;
                  m_weight2 += w2;
               }
            }
            m_array[i].price3=2.0*m_array[i].wsum1/m_weight1-m_array[i].wsum2/m_weight2;
         
            // 
            //---
            //
         
            if (i>m_sqrtPeriod)
            {
               m_array[i].wsum3 = m_array[i-1].wsum3+m_array[i].price3*m_sqrtPeriod-m_array[i-1].lsum3;
               m_array[i].lsum3 = m_array[i-1].lsum3+m_array[i].price3-m_array[i-m_sqrtPeriod].price3;
            }
            else
            {  
               m_array[i].wsum3 =
               m_array[i].lsum3 = m_weight3 = 0;
               for(int k=0, w3=m_sqrtPeriod; w3>0 && i>=k; k++, w3--)
               {
                  m_array[i].wsum3 += m_array[i-k].price3*w3;
                  m_array[i].lsum3 += m_array[i-k].price3;
                  m_weight3 += w3;
               }
            }         
         return(m_array[i].wsum3/m_weight3);
      }
};
CHull iHull;
