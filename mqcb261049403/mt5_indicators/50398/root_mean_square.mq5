//--------------------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2024"
#property link        "mladenfx@gmail.com"
//--------------------------------------------------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "pdfma"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrLimeGreen,clrDarkOrange
#property indicator_width1  3

//
//
//

input int                inpPeriod = 25;          // Period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

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
            
   return(INIT_SUCCEEDED);
}

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
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
   int limit = (prev_calculated>0) ? prev_calculated-1 : 0;
   
   //
   //
   //

   for (int i=limit; i<rates_total && !_StopFlag; i++)
      {
          val[i]      = iRootMeanSquare(iGetPrice(inpPrice,open[i],high[i],low[i],close[i]),inpPeriod,i,rates_total);
          valColor[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valColor[i-1] : 0;
      }                  
   return(rates_total);
}

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
//
//
//

double iRootMeanSquare(double value, int period, int r, int bars, int instanceNo=0)
{
   struct sWorkStruct
      {
         double valueXvalue;
         double valueXvalueSum;
      };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize <= bars)  m_workSize = ArrayResize(m_work,bars+500,2000);
                  if (period<1) period    = 1;

   //
   //
   //

      m_work[r].valueXvalue = value*value; 
         if (r>=period)
               {  m_work[r].valueXvalueSum  = m_work[r-1].valueXvalueSum  + m_work[r].valueXvalue  - m_work[r-period].valueXvalue; }
         else  {  m_work[r].valueXvalueSum = m_work[r].valueXvalue; for (int k=1; k<period && r>=k; k++) m_work[r].valueXvalueSum  += m_work[r-k].valueXvalue; }            
      
   return(MathSqrt(m_work[r].valueXvalueSum/(double)period));
}

//--------------------------------------------------------------------------------------------------------------
//
//--------------------------------------------------------------------------------------------------------------
//
//
//

double iGetPrice(int tprice, double open, double high, const double low, const double close)
{
   switch (tprice)
      {
         case PRICE_CLOSE:     return(close);
         case PRICE_OPEN:      return(open);
         case PRICE_HIGH:      return(high);
         case PRICE_LOW:       return(low);
         case PRICE_MEDIAN:    return((high+low)/2.0);
         case PRICE_TYPICAL:   return((high+low+close)/3.0);
         case PRICE_WEIGHTED:  return((high+low+close+close)/4.0);
      }
   return(0);
}