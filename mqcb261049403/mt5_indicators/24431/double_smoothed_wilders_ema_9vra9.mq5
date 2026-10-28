//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Double smoothed Wilders EMA - volatility ratio adaptive"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Double smoothed Wilders EMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input ENUM_APPLIED_PRICE inpPrice  = PRICE_MEDIAN; // Price
input int                inpPeriod = 14;           // Period

//
//--- indicator buffers
//

double val[],valc[],work[];
double _alpha;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//---
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,work,INDICATOR_COLOR_INDEX);
      iVolatilityRatio.init(inpPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"Double smoothed Wilders EMA (vra)("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

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
   int i=prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      if (i>0)
      {
         double _ratio = iVolatilityRatio.calculate(_price,i,rates_total);
         _alpha = 1.0 /MathSqrt(inpPeriod>1 ? inpPeriod/_ratio : 1);
            work[i] = work[i-1] + _alpha*(_price-work[i-1]);
            val[i]  = val[i-1]  + _alpha*(work[i]-val[i-1]);
            valc[i] = (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1];
      }
      else { work[i] = val[i] = _price; valc[i] = 0; }
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

//
//---
//

class cStdDevVolatilityRatio
{
   private :
      int m_period;
      int m_arraySize;
         struct sStdDevVolatilityRatioStruct
         {
            public :
               double price;
               double price2;
               double sum;
               double sum2;
               double sumd;
               double deviation;
         };
      sStdDevVolatilityRatioStruct m_array[];
   public:
      cStdDevVolatilityRatio() : m_arraySize(-1) {  }
     ~cStdDevVolatilityRatio()                   { ArrayFree(m_array); }

      //
      //---
      //

      void init(int period)
      {
         m_period = (period>1) ? period : 1;
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }

            m_array[i].price =price;
            m_array[i].price2=price*price;
            
            //
            //---
            //
            
            if (i>m_period)
            {
                  m_array[i].sum  = m_array[i-1].sum +m_array[i].price -m_array[i-m_period].price;
                  m_array[i].sum2 = m_array[i-1].sum2+m_array[i].price2-m_array[i-m_period].price2;
            }
            else  
            {
                  m_array[i].sum  = m_array[i].price;
                  m_array[i].sum2 = m_array[i].price2; 
                  for(int k=1; k<m_period && i>=k; k++) 
                  {
                        m_array[i].sum  += m_array[i-k].price; 
                        m_array[i].sum2 += m_array[i-k].price2; 
                  }                  
            }         
            m_array[i].deviation = (MathSqrt((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/(double)m_period));
            if (i>m_period) 
                  m_array[i].sumd  = m_array[i-1].sumd +m_array[i].deviation -m_array[i-m_period].deviation;
            else
            {
                  m_array[i].sumd = m_array[i].deviation;
                  for(int k=1; k<m_period && i>=k; k++) 
                        m_array[i].sumd += m_array[i-k].deviation; 
            }

            double deviationAverage = m_array[i].sumd/(double)m_period;
            return(deviationAverage != 0 ? m_array[i].deviation/deviationAverage : 1);
      }
};
cStdDevVolatilityRatio iVolatilityRatio;

//
//
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[],T& close[],T& high[], T& low[],int i)
{
   switch(tprice)
   {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}
//------------------------------------------------------------------+