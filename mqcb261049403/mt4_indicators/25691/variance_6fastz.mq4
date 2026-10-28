//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Variance"
//------------------------------------------------------------------
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  clrDodgerBlue

input int inpVarPeriod = 14; // Variance period
double val[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit(void)
{
   IndicatorDigits(8);
   string short_name = "Variance("+IntegerToString(inpVarPeriod)+")";
   
      //
      //
      //
      
      SetIndexBuffer(0,val); SetIndexStyle(0,DRAW_LINE); SetIndexLabel(0,short_name);
      IndicatorShortName(short_name);
         iVariance.init(inpVarPeriod);
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int limit=MathMin(rates_total-prev_calculated+1,rates_total-1);
   
   //
   //
   //
   
   for(int i=limit; i>=0; i--) val[i]=iVariance.calculate(close[i],rates_total-i-1,rates_total);
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

class cVariance
{
   private :
      int m_period;
      int m_arraySize;
         class cVarStruct
         {
            public :
               double price;
               double price2;
               double sum;
               double sum2;
               cVarStruct() : price(0),price2(0),sum(0),sum2(0) { }
         };
      cVarStruct m_array[];
   public:
      cVariance() : m_period(1), m_arraySize(-1) {                     }
     ~cVariance()                                { ArrayFree(m_array); }

      ///
      ///
      ///

      void init(int period)
      {
         m_period = (period>1) ? period : 1;
      }
      
      double calculate(double price, int i, int bars)
      {
            if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
            
            m_array[i].price  = price;
            m_array[i].price2 = price*price;
            
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
            return ((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/(double)m_period);
      }
};
cVariance iVariance;
