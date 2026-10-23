//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "TrendFlex"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDodgerBlue,clrCoral
#property indicator_width1  2

//
//---
//

input int inpFastPeriod = 20; // Fast trend-flex period
input int inpSlowPeriod = 50; // Slow trend-flex period
double  val[],valc[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val   ,INDICATOR_DATA);
   SetIndexBuffer(1,valc  ,INDICATOR_COLOR_INDEX);

      iTfFast.OnInit(inpFastPeriod);
      iTfSlow.OnInit(inpSlowPeriod);
      
   //
   //
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"TrendFlex ("+(string)inpFastPeriod+","+(string)inpSlowPeriod+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

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
   int limit = MathMax(prev_calculated-1,0);
   for(int i=limit; i<rates_total && !_StopFlag; i++)
   {
      double _price = (i>0 ? (close[i]+close[i-1])/2 : close[i]);
         val[i]  = iTfFast.OnCalculate(_price,i,rates_total)-iTfSlow.OnCalculate(_price,i,rates_total);
         valc[i] = (i>0) ? val[i]>val[i-1] ? 0 :  val[i]<val[i-1] ? 1 : 0 : 0;
   }
   return(rates_total);
}

 
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

class CTrendFlex
{
   private :
         double m_c1;
         double m_c2;
         double m_c3;
         struct sWorkStruct
         {
            double value;
            double ssm;
            double sum;
            double ms;
         };
         sWorkStruct m_array[];
         int         m_arraySize;
         int         m_period;
         
   public :
      CTrendFlex() : m_c1(1), m_c2(1), m_c3(1), m_arraySize(-1) {  }
     ~CTrendFlex()                                              {  }
     
      //
      //---
      //
     
      void OnInit(int period)
      {
         m_period = (period>1) ? period : 1;

         double a1 = MathExp(-1.414*M_PI/m_period);
         double b1 = 2.0*a1*MathCos(1.414*M_PI/m_period);
            m_c2 = b1;
            m_c3 = -a1*a1;
            m_c1 = 1.0 - m_c2 - m_c3;
      }
      double OnCalculate(double value, int i, int bars)
      {
         if (m_arraySize<bars) m_arraySize=ArrayResize(m_array,bars+500);

         //
         //
         //
         
         m_array[i].value = value;
            if (i>1)
                    m_array[i].ssm = m_c1*(m_array[i].value+m_array[i-1].value)/2.0 + m_c2*m_array[i-1].ssm + m_c3*m_array[i-2].ssm;
            else    m_array[i].ssm = value;
            if (i>m_period)
                  m_array[i].sum = m_array[i-1].sum + m_array[i].ssm - m_array[i-m_period].ssm;
            else
               {                     
                  m_array[i].sum = m_array[i].ssm;
                     for (int k=1; k<m_period && (i-k)>=0; k++) m_array[i].sum += m_array[i-k].ssm;
               }  
               
               //
               //
               //
               
               double sum   = m_period*m_array[i].ssm-m_array[i].sum;
                      sum  /= m_period;

               m_array[i].ms = (i>0) ? 0.04 * sum*sum+0.96*m_array[i-1].ms : 0;
       return (m_array[i].ms!=0 ? sum/MathSqrt(m_array[i].ms) : 0);
      }   
};
CTrendFlex iTfSlow,iTfFast;