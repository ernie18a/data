//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Corrected AMA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2
#property indicator_label1  "Corrected AMA original"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_label2  "Corrected AMA"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width2  3

//
//---
//

input int                inpPeriod           = 14;          // Average period
input int                inpFastPeriod       =  2;          // Fast end period
input int                inpSlowPeriod       = 30;          // Slow end period
input ENUM_APPLIED_PRICE inpPrice            = PRICE_CLOSE; // Price
input int                inpCorrectionPeriod =  0;          // "Correction" period (<0 no correction,0 to 1 same as average)

//
//---
//

double val[],valc[],avg[],avgc[],avgw[],prices[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------

int OnInit()
{
   //
   //---
   //
         SetIndexBuffer(0,avg   ,INDICATOR_DATA);
         SetIndexBuffer(1,avgc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,val   ,INDICATOR_DATA);
         SetIndexBuffer(3,valc  ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(4,avgw  ,INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,prices,INDICATOR_CALCULATIONS);
         
         iAma.init(inpPeriod,inpFastPeriod,inpSlowPeriod);
         iCorrMa.init((inpCorrectionPeriod>0) ? inpCorrectionPeriod : (inpCorrectionPeriod<0) ? 0 : inpPeriod );         
   //
   //---
   //      
   IndicatorSetString(INDICATOR_SHORTNAME,"\"Corrected\" AMA ("+(string)inpPeriod+","+(string)inpCorrectionPeriod+")");
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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
      prices[i] = getPrice(inpPrice,open,high,low,close,i);
         iAma.calculate(prices[i],avg,prices,prices,i);
      val[i]  = iCorrMa.calculate(prices[i],avg[i],i,rates_total);
      avgc[i] = valc[i] = (avg[i]>val[i]) ? 1 : (avg[i]<val[i]) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

class CCorrMa
{
   private:
      int  m_period;
      struct sCorrMaStruct
         {
            double corrected;
            double price;
            double price2;
            double summ;
            double summ2;
         };
      sCorrMaStruct m_array[];
      int           m_arraySize;
   
   public :
      CCorrMa() : m_period(1), m_arraySize(-1) { };
     ~CCorrMa()                                { };
     
     //
     //
     //
     
     bool init(int period)
     {
         m_period = (period>1) ? period : 1;
         return(true);
     }
     double calculate(double price, double average, int i, int bars)
     {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<=bars) return(0); }
      
         //
         //---
         //
      
         m_array[i].price  = price;
         m_array[i].price2 = price*price;
         if (i>m_period)
            {
               m_array[i].summ  = m_array[i-1].summ +price            -m_array[i-m_period].price;
               m_array[i].summ2 = m_array[i-1].summ2+m_array[i].price2-m_array[i-m_period].price2;
            }
         else  
            {
               m_array[i].summ  = m_array[i].price;
               m_array[i].summ2 = m_array[i].price2; 
               for(int k=1; k<m_period && i>=k; k++) 
               {
                  m_array[i].summ  += m_array[i-k].price; 
                  m_array[i].summ2 += m_array[i-k].price2; 
               }                  
            }         

         //
         //---
         //
      
         if (i>0) 
         {
            double v1 = (m_array[i].summ2-m_array[i].summ*m_array[i].summ/(double)m_period)/(double)m_period;
            double v2 = (m_array[i-1].corrected-average)*(m_array[i-1].corrected-average);
            double c  = (v2<v1 || v2==0) ? 0 : 1.0-v1/v2;
               m_array[i].corrected = m_array[i-1].corrected + c*(average-m_array[i-1].corrected);
         }
         else m_array[i].corrected = average;
      return (m_array[i].corrected);
     }
};
CCorrMa iCorrMa;

//
//
//

class CAma
{
   private :
      int    m_period;
      int    m_prev_i;
      double m_fastEnd;
      double m_slowEnd;
      double m_prev_max;
      double m_prev_min;

   public :
      CAma(void) : m_period(1),m_fastEnd(2.0/3.0), m_slowEnd( 2.0/31.0) { return; }
     ~CAma(void)                                                        { return; }
    
      //
      //
      //

      bool init(int period, double fastEnd, double slowEnd)
      {
         m_period    = (period>1) ? period+1 : 2;
         m_fastEnd   = (2.0 /(fastEnd + 1.0));
         m_slowEnd   = (2.0 /(slowEnd + 1.0));
         return(true);
      }
      
      template <typename T1, typename T2, typename T3>
      void calculate(double value, T1 &target[], T2 &arrayMax[], T3 &arrayMin[], int i) 
      {       
         if (m_prev_i!=i)
         {
            m_prev_i = i; 
            int start    = i-m_period+1; if (start<0) start=0;
                m_prev_max = arrayMax[ArrayMaximum(arrayMax,start,m_period-1)];
                m_prev_min = arrayMin[ArrayMinimum(arrayMin,start,m_period-1)];
         }
         double max = (arrayMax[i] > m_prev_max) ? arrayMax[i] : m_prev_max;
         double min = (arrayMin[i] < m_prev_min) ? arrayMin[i] : m_prev_min;

         //
         //---
         //

         double mltp = (max!=min) ? ((value-min)-(max-value))/(max-min) : 1; if (mltp<0) mltp *= -1;
         double ssc  = mltp * ( m_fastEnd-m_slowEnd) + m_slowEnd;	
                target[i] = (i>0) ? target[i-1]+(ssc*ssc)*(value-target[i-1]) : value;
      }
};
CAma iAma;

//
//
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
