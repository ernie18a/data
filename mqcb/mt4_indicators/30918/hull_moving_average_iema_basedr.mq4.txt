//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_label1  "Hull"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_width1  2
#property indicator_label2  "Hull - slope down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "Hull - slope down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2

//
//
//

input int                inpPeriod  = 20;          // Period
input double             inpDivisor = 2.0;         // Divisor ("speed")
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

double val[],valda[],valdb[],valc[],fullAlpha,halfAlpha,sqrtAlpha;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valda,INDICATOR_DATA);
   SetIndexBuffer(2,valdb,INDICATOR_DATA);
   SetIndexBuffer(3,valc );

      //
      //
      //
      
      double fullPeriod = MathMax(inpPeriod,1);
             fullAlpha = 2.0/(1.0+fullPeriod);
             halfAlpha = 2.0/(1.0+MathMax(fullPeriod/inpDivisor,1));
             sqrtAlpha = 2.0/(1.0+MathMax(MathSqrt(fullPeriod),1));
   IndicatorSetString(INDICATOR_SHORTNAME,"Hull (ema)("+(string)inpPeriod+","+(string)inpDivisor+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//
//
//

int  OnCalculate(const int rates_total,
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
   int limit=rates_total-prev_calculated+1; if (limit>=rates_total) limit=rates_total-1;
  
   //
   //
   //
   
         struct sWorkStruct
         {
            double emaFull;
            double emaHalf;
            double emaSqrt;
         };
         static sWorkStruct m_work[];
         static int         m_workSize = -1;
                        if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);
   //
   //
   //
  
   if (valc[limit]==-1) iCleanPoint(limit,rates_total,valda,valdb);
   for (int i=limit, r=rates_total-i-1; i>=0 && !_StopFlag; i--,r++)
   {
      double price = iMA(NULL,0,1,0,MODE_SMA,inpPrice,i);
      if (r>0)
      {
           m_work[r].emaFull = m_work[r-1].emaFull + fullAlpha*(price-m_work[r-1].emaFull);
           m_work[r].emaHalf = m_work[r-1].emaHalf + halfAlpha*(price-m_work[r-1].emaHalf);
           m_work[r].emaSqrt = m_work[r-1].emaSqrt + sqrtAlpha*(2.0*m_work[r].emaHalf-m_work[r].emaFull-m_work[r-1].emaSqrt);
      }
      else m_work[r].emaFull = m_work[r].emaHalf = m_work[r].emaSqrt = price;
         
      val[i]   = m_work[r].emaSqrt;
      valc[i]  = (r>0) ? (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? -1 : valc[i+1] : 0;
      valda[i] = valdb[i] = EMPTY_VALUE;
            if (valc[i] == -1) iPlotPoint(i,rates_total,valda,valdb,val);
   }
   return(rates_total);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

void iCleanPoint(int i, int bars, double& first[], double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i, int bars, double& first[], double& second[], double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE)
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}