//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "adaptive deviation"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrDeepPink,clrMediumSeaGreen
#property indicator_width1  2

//
//
//

input int                inpPeriod = 20;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//
//
double val[],valc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
            iAdaptiveDeviation.init(inpPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptive deviation ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price  = getPrice(inpPrice,open,high,low,close,i);
             val[i]  = iAdaptiveDeviation.calculate(_price,i,rates_total);
             valc[i] = (i>0) ?(val[i]>val[i-1]) ? 2 :(val[i]<val[i-1]) ? 1 : valc[i-1]: 0;
   }
   return(i);
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//---
//

class cAdaptiveDeviation
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_fastEnd;
      double m_slowEnd;
      double m_periodDiff;
         struct sAdaptiveStruct
         {
            double price;
            double ema0;
            double ema1;
            double difference;
            double noise;
         };
      sAdaptiveStruct m_array[];
   public:
      cAdaptiveDeviation() : m_period(1), m_arraySize(-1) {                     }
     ~cAdaptiveDeviation()                                { ArrayFree(m_array); }

      ///
      ///
      ///

      void init(int period)
      {
         m_period     = (period>1) ? period : 1;
         m_fastEnd    = MathMax(m_period/2.0,1);
         m_slowEnd    =         m_period*5;
         m_periodDiff = m_slowEnd - m_fastEnd;
      }
      
      double calculate(double price, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize=ArrayResize(m_array,bars+500,2000); if (m_arraySize<bars) return(0); }
         
            //
            //
            //
         
            m_array[i].price      = price;
            m_array[i].difference = (i>0) ? m_array[i].price-m_array[i-1].price : 0; if (m_array[i].difference<0) m_array[i].difference *= -1.0;
            double signal = 0;
            if (i>m_period)
            {
                     signal           = m_array[i].price-m_array[i-m_period].price; if (signal<0) signal *= -1.0;
                     m_array[i].noise = m_array[i-1].noise + m_array[i].difference - m_array[i-m_period].difference;
            }         
            else for(int k=0; k<m_period && i>=k; k++) m_array[i].noise += m_array[i-k].difference;  
      
         //
         //
         //
             
            if (i>0)
            {        
               double averagePeriod = (m_array[i].noise!=0) ? (signal/m_array[i].noise)*m_periodDiff+m_fastEnd : m_period;
               double alpha         = 2.0/(1.0+averagePeriod);
                    m_array[i].ema0 = m_array[i-1].ema0+alpha*(price      -m_array[i-1].ema0);
                    m_array[i].ema1 = m_array[i-1].ema1+alpha*(price*price-m_array[i-1].ema1);
                    
                    //
                    //
                    //
                    
                    return(MathSqrt(averagePeriod*(m_array[i].ema1-m_array[i].ema0*m_array[i].ema0)/MathMax(averagePeriod-1,1)));
            }
            else m_array[i].ema0 = m_array[i].ema1 = price;
            return(0);
      }
};
cAdaptiveDeviation iAdaptiveDeviation;

//
//---
//

template <typename T> 
double getPrice(ENUM_APPLIED_PRICE tprice, T& open[], T& high[], T& low[], T& close[], int i)
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
//------------------------------------------------------------------

