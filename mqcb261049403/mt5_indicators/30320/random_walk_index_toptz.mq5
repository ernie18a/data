//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Random walk index"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Random walk index up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Random walk index down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrPaleVioletRed
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Random walk index down"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrLimeGreen,clrPaleVioletRed
#property indicator_width3  3

//
//---
//
input int inpRwiLength = 25;       // Random walk index period

double val[],valc[],rwiUp[],rwiDn[],rwiCoeffs[];
int rwiLength;
//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,rwiUp,INDICATOR_DATA); 
   SetIndexBuffer(1,rwiDn,INDICATOR_DATA); 
   SetIndexBuffer(2,val  ,INDICATOR_DATA); 
   SetIndexBuffer(3,valc ,INDICATOR_COLOR_INDEX); 
   IndicatorSetString(INDICATOR_SHORTNAME," Random walk index ("+string(inpRwiLength)+")");
   
      //
      //
      //
      
      rwiLength = inpRwiLength>0 ? inpRwiLength : 0;
      
         ArrayResize(rwiCoeffs,rwiLength);
         for (int k = 1; k <rwiLength; k++)
            rwiCoeffs[k] = MathSqrt(k+1.0)/(k+1.0);
      
      //
      //
      //
      
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
   int limit = prev_calculated-1; if (limit<0) limit = 0;
   
   //
   //
   //
   
      struct sWorkStruct
      {
         double tr;
         double prevLow;
         double prevHigh;
         int    prevBar;
         
         sWorkStruct() : prevBar(-1), prevLow(DBL_MAX), prevHigh(DBL_MIN) {}
      };
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize <= rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

   //
   //
   //
   
   for (int i=limit; i<rates_total && !_StopFlag; i++)
   {
      m_work[i].tr = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) - (low[i]<close[i-1] ? low[i] : close[i-1]) : high[i]-low[i];

         if (m_work[i].prevBar!=i || m_work[i].prevHigh!=high[i] || m_work[i].prevLow!=low[i])
         {
            m_work[i  ].prevBar  =  i;
            m_work[i+1].prevBar  = -1;
            m_work[i  ].prevHigh = high[i];
            m_work[i  ].prevLow  = low[i];
            
            //
            //
            //
            
            double trwiUp = 0;
            double trwiDo = 0;
            double atr    = m_work[i].tr;
         
            for (int k = 1; k<inpRwiLength && (i-k)>=0; k++)
            {
               atr += m_work[i-k].tr;  
               
               //
               //---
               //
               double denominator  = atr*rwiCoeffs[k];
                  if (denominator != 0)
                  {
                     double _tmpUp = (high[i] - low[i-k]) / denominator;
                     double _tmpDn = (high[i-k] - low[i]) / denominator;
                        if (_tmpUp > trwiUp) trwiUp = _tmpUp;
                        if (_tmpDn > trwiDo) trwiDo = _tmpDn;
                  }
            }
            rwiUp[i] = trwiUp;
            rwiDn[i] = trwiDo;
         }
         val[i]  = (rwiUp[i]>rwiDn[i]) ? rwiUp[i] : rwiDn[i];
         valc[i] = (rwiUp[i]>rwiDn[i]) ? 0 : 1;
   }      
   return(rates_total);
}