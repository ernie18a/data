//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Adaptive ATR"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//---
//

input int inpPeriod = 14; // period

double val[]; double m_fastEnd,m_slowEnd; int m_period;

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   SetIndexBuffer(0,val,INDICATOR_DATA);
         m_period    = (inpPeriod>1) ? inpPeriod : 1;
         m_fastEnd   = MathMax(m_period/2.0,1);
         m_slowEnd   =         m_period*5;

   //
   //---
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptive ATR ("+(string)m_period+")");
   return(INIT_SUCCEEDED);
}

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
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
   struct sEfrStruct
   {
      double price;
      double difference;
      double noise;
   };
   static sEfrStruct m_array[];
   static int        m_arraySize=-1;
                 if (m_arraySize<rates_total)
                 {
                     m_arraySize = ArrayResize(m_array,rates_total+500); if (m_arraySize<rates_total) return(0);
                 }
                 
   //
   //
   //
                    
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      m_array[i].price      = (high[i]+low[i])/2.0;
      m_array[i].difference = (i>0) ? m_array[i].price-m_array[i-1].price : 0; if (m_array[i].difference<0) m_array[i].difference *= -1.0;

      //
      //
      //
                     
      double signal  = 0;
         if (i>m_period)
         {
                     signal           = m_array[i].price-m_array[i-m_period].price; if (signal<0) signal *= -1.0;
                     m_array[i].noise = m_array[i-1].noise + m_array[i].difference - m_array[i-m_period].difference;
         }         
         else       
         {
                     m_array[i].noise = m_array[i].difference;
                     for(int k=1; k<m_period && i>=k; k++) m_array[i].noise += m_array[i-k].difference;
         }
      
         //
         //
         //
             
      double efratio       = (m_array[i].noise!=0) ? signal/m_array[i].noise : 1;
      double averagePeriod = (m_array[i].noise!=0) ? ((signal/m_array[i].noise)*(m_slowEnd-m_fastEnd))+m_fastEnd : m_period;
      val[i]  = (i>0) ? val[i-1]+(2.0/(1.0+averagePeriod))*((high[i]-low[i])-val[i-1]) : (high[i]-low[i]);
   }      
   return(rates_total);
}