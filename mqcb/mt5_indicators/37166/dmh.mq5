//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Directional Movement using Hann windowing"
#property description "Based on work published by John Ehlers"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "DMH"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDarkGray,clrDeepSkyBlue,clrCoral
#property indicator_width1   2

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

double val[],valc[];
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
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
   
      //
      //
      //

            global.period    = MathMax(inpPeriod,1);
            global.alpha     = 1.0/(double)global.period;
            global.coeffsSum = 0;
               ArrayResize(global.coeffs,global.period);
               for (int i=0; i<global.period; i++)
                  {
                  // (1 - Cosine(360*count / (Length +1)))
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
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

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

      for (int i=_limit; i<rates_total; i++)
         {
            double upperMove = (i>0) ? high[i]-high[i-1] : 0;
            double lowerMove = (i>0) ? low[i-1]-low[i] : 0;
            double plusDM    = (upperMove>lowerMove && upperMove>0) ? upperMove : 0;
            double minusDM   = (lowerMove>upperMove && lowerMove>0) ? lowerMove : 0;
               //
               //
               //
               
                  m_work[i].ema = (i>0) ? m_work[i-1].ema + global.alpha*((plusDM-minusDM) - m_work[i-1].ema) : (plusDM-minusDM);
                  
            double dSum = 0; for (int k=0; k<global.period && i>=k; k++) dSum += m_work[i-k].ema*global.coeffs[k];
            val[i]  = (global.coeffsSum!=0) ? dSum/global.coeffsSum : 0;
            switch (inpColorOn)
               {
                  case col_onSlope : valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0; break;
                  case col_onZero  : valc[i] = (val[i]>0) ? 1 : (val[i]<0) ? 2 : (i>0) ? valc[i-1] : 0;               break;
                  default :          valc[i] = 0;
               }                  
         }

   //
   //
   //

   return(rates_total);
}