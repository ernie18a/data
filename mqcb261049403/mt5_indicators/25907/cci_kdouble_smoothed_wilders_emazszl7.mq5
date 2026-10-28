//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "CCI of ds Wilder's EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrLightSalmon
#property indicator_width1  2

//
//---
//

input  int                inpPeriod     = 50;            // CCI period
input  int                inpEmaPeriod  = 14;            // Wilder's EMA period
input  ENUM_APPLIED_PRICE inpPrice      = PRICE_TYPICAL; // Price

double val[],valc[],ema1[],ema2[],_alpha;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //
   //
         SetIndexBuffer(0,val  ,INDICATOR_DATA);
         SetIndexBuffer(1,valc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,ema1 ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,ema2 ,INDICATOR_CALCULATIONS);
            _workCci.init(inpPeriod);
            _alpha = 1.0 /MathSqrt(inpEmaPeriod>1 ? inpEmaPeriod : 1);

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI std based ("+(string)inpPeriod+")(ds Wilder's EMA "+(string)inpEmaPeriod+" smoothed)");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
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
      double _price; _setPrice(inpPrice,_price,i);
      if (i>0)
      {
         ema1[i] = ema1[i-1] + _alpha*(_price -ema1[i-1]);
         ema2[i] = ema2[i-1] + _alpha*(ema1[i]-ema2[i-1]);
      }
      else ema1[i] = ema2[i] = _price;         
           val[i]  = _workCci.calculate(ema2[i],i,rates_total);
           valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : (i>0) ? valc[i-1] : 0;
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
      sCciWork  m_array[];
      int       m_period;
      int       m_arraySize;
      
   public :
      CCci() : m_period(1), m_arraySize(-1) { }
     ~CCci()                                { }
     
     //
     //---
     //
     
     void   init(int period) { m_period= (period) > 0 ? period : 1; return; }
     double calculate(double value, int i, int bars)
     {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
         
         //
         //---
         //
         
         m_array[i].value  = value;
         m_array[i].value2 = value*value;
            if (i>m_period)
                  {
                     m_array[i].summ  = m_array[i-1].summ +m_array[i].value -m_array[i-m_period].value;
                     m_array[i].summ2 = m_array[i-1].summ2+m_array[i].value2-m_array[i-m_period].value2;
                  }
            else  {
                     m_array[i].summ  = m_array[i].value;
                     m_array[i].summ2 = m_array[i].value2;
                     for (int k=1; k<m_period && i>=k; k++)
                     {
                        m_array[i].summ  += m_array[i-k].value; 
                        m_array[i].summ2 += m_array[i-k].value2; 
                     }
                  }         
         double _avg = m_array[i].summ/(double)m_period;
         double _dev = MathSqrt((m_array[i].summ2-m_array[i].summ*_avg)/(double)m_period);
         return(_dev!=0 ? (value-_avg)/(0.015*_dev) : 0);
     }
};
CCci _workCci;