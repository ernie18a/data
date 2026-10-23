//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
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
input  int                inpEmaPeriod  = 14;             // Wilder's EMA period
input  ENUM_APPLIED_PRICE inpPrice       = PRICE_TYPICAL; // Price

double val[],valc[],prices[],ema1[],ema2[],_alpha;


//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val    ,INDICATOR_DATA);
   SetIndexBuffer(1,valc   ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,prices ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ema1   ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ema2   ,INDICATOR_CALCULATIONS);
      _workCci.init(inpPeriod);
      _alpha = 1.0 /MathSqrt(inpPeriod>1 ? inpPeriod : 1);

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"CCI std based ("+(string)inpPeriod+")(ds Wilder's EMA "+(string)inpEmaPeriod+" smoothed)");
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
      if (i>0)
      {
         ema1[i] = ema1[i-1] + _alpha*(prices[i]-ema1[i-1]);
         ema2[i] = ema2[i-1] + _alpha*(ema1[i]  -ema2[i-1]);
      }
      else ema1[i] = ema2[i] = prices[i];         
           val[i]  = _workCci.calculate(ema2[i],i,rates_total);
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