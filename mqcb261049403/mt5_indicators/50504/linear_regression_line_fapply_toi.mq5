//--------------------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2024"
#property link        "mladenfx@gmail.com"
//--------------------------------------------------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Linear regression line"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrDarkOrange
#property indicator_width1  2

//
//
//

input int                inpPeriod = 100;   // Period

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
//
//
//

double val[],valColor[];

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val     ,INDICATOR_DATA);
   SetIndexBuffer(1,valColor,INDICATOR_COLOR_INDEX);
   
      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("LR slope (%i)",inpPeriod)); 
   return(INIT_SUCCEEDED);
}

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
//
//
//

int  OnCalculate(const int     rates_total,
                 const int     prev_calculated,
                 const int     begin,
                 const double& price[])
{ 
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;
   
   //
   //
   //

   double _slope     = 0;
   double _intercept = 0;;
      for (int i=limit; i<rates_total && !_StopFlag; i++)
         {
            double _price = (price[i]!=EMPTY_VALUE) ? price[i] : 0;
            double _lrValue = iLinearRegression(_price,inpPeriod,_slope,_intercept,i,rates_total);
         }
      for (int i=0; i<inpPeriod && !_StopFlag; i++) 
         {
            val[rates_total-i-1]      = _intercept + _slope*(inpPeriod-i-1);
            valColor[rates_total-i-1] = (_slope>0) ? 1 : (_slope<0) ? 2 : 0;
         }

   //
   //
   //
         
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,rates_total-inpPeriod);      
   return(rates_total);
}

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
//
//
//

double iLinearRegression(double value, int period, double& _slope, double& _intercept, int r, int bars)
{
  struct sWorkStruct
      {
            struct sDataStruct
                  {
                        double value;
                        double sumY;
                        double sumXY;
                  };
            sDataStruct data[];
            int         dataSize;
            int         period;
            double      sumX;
            double      sumXX;
            double      divisor;
            
            //
            //
            //
                           
            sWorkStruct() : dataSize(-1), period(-1) { }
      };
   static sWorkStruct m_work;
                  if (m_work.dataSize <= bars) m_work.dataSize = ArrayResize(m_work.data,bars+500,2000);
                  
                  if (period<1) period = 1;
                  if (m_work.period != (int)period)
                        {
                           m_work.period  = (int)period;
                           m_work.sumX    = m_work.period * (m_work.period-1.0) / 2.0;
                           m_work.sumXX   = m_work.period * (m_work.period-1.0) * (2.0 * m_work.period - 1.0) / 6.0;
                           m_work.divisor = m_work.sumX * m_work.sumX - m_work.period * m_work.sumXX;
                              if (m_work.divisor) 
                                  m_work.divisor = 1.0/m_work.divisor;
                        }

      //
      //---
      //

         m_work.data[r].value = value;
         
            //
            //
            //
            
            if (r>=m_work.period)
                  {
                        m_work.data[r].sumY  = m_work.data[r-1].sumY  + value               - m_work.data[r-m_work.period].value;
                        m_work.data[r].sumXY = m_work.data[r-1].sumXY + m_work.data[r].sumY - m_work.data[r-m_work.period].value*(m_work.period-1.0) - value;
                  }
            else
                  {
                        m_work.data[r].sumY  = value;
                        m_work.data[r].sumXY = 0;

                           //
                           //
                           //
                           
                           for (int k=1; k<m_work.period && r>=k; k++)
                                 {
                                       m_work.data[r].sumY  +=   m_work.data[r-k].value;
                                       m_work.data[r].sumXY += k*m_work.data[r-k].value;
                                 }
                  }
         
         _slope     = (m_work.period*m_work.data[r].sumXY - m_work.sumX * m_work.data[r].sumY) * m_work.divisor;
         _intercept = (m_work.data[r].sumY - _slope * m_work.sumX) / (double)m_work.period ;
   
   //
   //
   //

   return(_intercept  + _slope*(m_work.period-1.0));
}