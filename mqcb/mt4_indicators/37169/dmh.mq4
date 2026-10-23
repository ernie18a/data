//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Directional Movement using Hann windowing"
#property description "Based on work published by John Ehlers"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  3
#property indicator_label1   "DMH"
#property indicator_type1    DRAW_LINE
#property indicator_color1   clrDeepSkyBlue
#property indicator_width1   2
#property indicator_label2   "DMH down"
#property indicator_type2    DRAW_LINE
#property indicator_color2   clrCoral
#property indicator_width2   2
#property indicator_label3   "DMH down"
#property indicator_type3    DRAW_LINE
#property indicator_color3   clrCoral
#property indicator_width3   2
#property strict

//
//
//

input int inpPeriod = 14; // DMH period
      enum enColorOn
         {
            col_onSlope,  // Change color on slope change
            col_onZero,   // Change color on zero cross
            col_noChange, // No color change
         };
input enColorOn inpColorOn = col_onSlope; // Color change mode         

//
//
//

double val[],valda[],valdb[],valc[];
struct sGlobalStruct
{
   int    period;
   double alpha;
   double coeffs[];
   double coeffsSum;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorDigits(5);
   IndicatorBuffers(4);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valda,INDICATOR_DATA);
   SetIndexBuffer(2,valdb,INDICATOR_DATA);
   SetIndexBuffer(3,valc ,INDICATOR_CALCULATIONS);
   
      //
      //
      //

            global.period    = MathMax(inpPeriod,1);
            global.alpha     = 1.0/(double)global.period;
            global.coeffsSum = 0;
               ArrayResize(global.coeffs,global.period);
               for (int i=0; i<global.period; i++)
                  {
                     double _coeff = 1.0 - MathCos((2*M_PI*(i+1))/(global.period+1.0));
                           global.coeffs[i]  = _coeff;
                           global.coeffsSum += _coeff;
                  }

      //
      //
      //

   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("DMH (%i)",global.period));            
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
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;

   //
   //
   //

      struct sWorkStruct
            {
               double ema;
            };   
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      if (valc[limit]==2) iCleanPoint(limit,rates_total,valda,valdb);
      for (int i=limit, r=rates_total-i-1; i>=0; i--,r++)
         {
            double upperMove = (r>0) ? high[i]-high[i+1] : 0;
            double lowerMove = (r>0) ? low[i+1]-low[i] : 0;
            double plusDM    = (upperMove>lowerMove && upperMove>0) ? upperMove : 0;
            double minusDM   = (lowerMove>upperMove && lowerMove>0) ? lowerMove : 0;
               //
               //
               //
               
                  m_work[r].ema = (r>0) ? m_work[r-1].ema + global.alpha*((plusDM-minusDM) - m_work[r-1].ema) : (plusDM-minusDM);
                  
            double dSum = 0; for (int k=0; k<global.period && r>=k; k++) dSum += m_work[r-k].ema*global.coeffs[k];
            val[i]  = (global.coeffsSum!=0) ? dSum/global.coeffsSum : 0;
            switch (inpColorOn)
               {
                  case col_onSlope : valc[i] = (r>0) ? (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? 2 : valc[i+1] : 0; break;
                  case col_onZero  : valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : (r>0) ? valc[i+1] : 0;               break;
                  default :          valc[i] = 0;
               }                  
            if (valc[i]==2) iPlotPoint(i,rates_total,valda,valdb,val); else valda[i] = valdb[i] = EMPTY_VALUE;               
         }

   //
   //
   //

   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

void iCleanPoint(int i, int bars, double& first[], double& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i]  != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
           first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i, int bars, double& first[], double& second[], double& source[])
{
   if (i>=bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = source[i]; first[i+1]  = source[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = source[i]; second[i+1] = source[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = source[i];                            second[i] = EMPTY_VALUE; }
}

