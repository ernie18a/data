//------------------------------------------------------------------
#property copyright "© mladen, 2019"
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
#property strict
//
//
//

input int inpAtrPeriod = 14; // ATR period
double val[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);

      //
      //
      //
      
      iAtr.init(inpAtrPeriod);
   IndicatorSetString(INDICATOR_SHORTNAME,"Adaptive ATR ("+(string)inpAtrPeriod+")");
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

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
   int i=rates_total-prev_calculated; if (i>rates_total-1) i=rates_total-1; for (; i>=0 && !_StopFlag; i--) 
   { 
      val[i] = iAtr.calculate(high,low,i,rates_total); 
   }
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

class CAtrAdaptive
{
   private :
         int    m_period;
         double m_fastEnd;
         double m_slowEnd;
         double m_periodDiff;
         struct sAtrStruct
         {
            double price;
            double difference;
            double noise;
            double atr;
         };
         sAtrStruct m_array[];
         int        m_arraySize;
   public :
      CAtrAdaptive() : m_period(1), m_arraySize(-1) { return; }
     ~CAtrAdaptive()                                { return; }
     
     //
     //---
     //
     
     void init(int period)
         {
            m_period     = (period>1) ? period : 1;
            m_fastEnd    = MathMax(m_period/2.0,1);
            m_slowEnd    =         m_period*5;
            m_periodDiff = m_slowEnd - m_fastEnd;
         }
      template <typename T>         
      double calculate(T& high[], T& low[], int i, int bars)
         {
            if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500,2000); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
          
            int r = bars-i-1;
            m_array[r].price      = (high[i]+low[i])*0.5;
            m_array[r].difference = (r>0) ? m_array[r].price-m_array[r-1].price : 0; if (m_array[r].difference<0) m_array[r].difference *= -1.0;
            double signal         = 0;
            if (r>m_period)
            {
                     signal           = m_array[r].price-m_array[r-m_period].price; if (signal<0) signal *= -1.0;
                     m_array[r].noise = m_array[r-1].noise + m_array[r].difference - m_array[r-m_period].difference;
            }         
            else for(int k=0; k<m_period && r>=k; k++) m_array[r].noise += m_array[r-k].difference;  
      
         //
         //
         //
             
         double averagePeriod = (m_array[r].noise!=0) ? (signal/m_array[r].noise)*m_periodDiff+m_fastEnd : m_period;
                    m_array[r].atr  = (r>0) ? m_array[r-1].atr+(2.0/(1.0+averagePeriod))*((high[i]-low[i])-m_array[r-1].atr) : (high[i]-low[i]);
            return (m_array[r].atr);
      }   
};
CAtrAdaptive iAtr;