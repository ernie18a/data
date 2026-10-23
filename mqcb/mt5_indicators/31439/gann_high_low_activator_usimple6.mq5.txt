//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Gann high/low activator"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Gann activator"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//

input int  inpPeriod = 10;  // Activator period

double val[],valc[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA); 
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX); 
   IndicatorSetString(INDICATOR_SHORTNAME,"Gann high/low activator ("+string(inpPeriod)+")");
   return(INIT_SUCCEEDED);
}

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
   int limit = (prev_calculated ? prev_calculated-1 : 0);
   
   //
   //
   //
      
         struct sWorkStruct
         {
            double sumHigh;
            double sumLow;
            int    state;
         };
         static sWorkStruct m_work[];
         static int         m_workSize = -1;
                       if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);
      
   //
   //
   //
      
   for (int i=limit; i<rates_total && !_StopFlag; i++)
   {
      if (i>inpPeriod)
         {
            m_work[i].sumHigh = m_work[i-1].sumHigh + high[i] - high[i-inpPeriod];
            m_work[i].sumLow  = m_work[i-1].sumLow  + low[i]  - low[i-inpPeriod];
         }            
      else
         {
            m_work[i].sumHigh = high[i];     
            m_work[i].sumLow  = low[i];     
            for (int k=1; k<inpPeriod && i>=k; k++)
            {
               m_work[i].sumHigh += high[i-k];     
               m_work[i].sumLow  += low[i-k];     
            }
         }
         
      //
      //
      //
         
      double avgHigh = (i>0) ? m_work[i-1].sumHigh/(double)inpPeriod : high[i];
      double avgLow  = (i>0) ? m_work[i-1].sumLow /(double)inpPeriod : low[i];
      
         m_work[i].state = (close[i]>avgHigh) ? 1 : (close[i]<avgLow) ? -1 : (i>0) ? m_work[i-1].state : 0;
         val[i]  = (m_work[i].state==1) ? avgLow : (m_work[i].state==-1) ? avgHigh : close[i];
         valc[i] = (m_work[i].state==1) ? 0 : 1;
   }      
   return(rates_total);
}
