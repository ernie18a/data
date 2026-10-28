//------------------------------------------------------------------
#property copyright   "© mladen, 2020"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "Ocean natural market slope"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrMediumSeaGreen,clrCoral
#property indicator_width1  2

//
//
//

input int                inpNmsPeriod  = 40;          // Natural market slope period
input ENUM_APPLIED_PRICE inpNmsPrice   = PRICE_CLOSE; // Price
input int                inpTemaPeriod = 10;          // Triple EMA pre-smoothing period

//
//
//

double val[],valc[]; double alpha;
int    iNmsPeriod;
struct sCoeffStruct
{
      double sumx;
      double sumx2;
      double bot;
      double root; 
};
sCoeffStruct coeff[];

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
      
      iNmsPeriod  = (inpNmsPeriod>1)  ? inpNmsPeriod : 1;
            alpha = 2.0 /(1.0 + MathMax(inpTemaPeriod,1));
            ArrayResize(coeff,iNmsPeriod+1);
            for (int period=1; period<=iNmsPeriod ; period++)
            {
               coeff[period].sumx  = period*(period+1.0)/2.0;
               coeff[period].sumx2 = period*(period+1.0)*(2*period+1.0)/6.0;
               coeff[period].bot   = period*coeff[period].sumx2 - coeff[period].sumx*coeff[period].sumx;
                  if (coeff[period].bot==0) coeff[period].bot=1;
               coeff[period].root  = MathSqrt(period);
            }           

      //
      //
      //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Ocean nms ("+(string)iNmsPeriod+","+(string)inpTemaPeriod+")");
   return(INIT_SUCCEEDED);
}

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
   int limit = prev_calculated-1; if (limit<0) limit = 0;

   //
   //
   //
      
      struct sWorkStruct
      {
            double price;
            double tema0;
            double tema1;
            double tema2;
      };
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize < rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

   //
   //
   //

   for(int i=limit; i<rates_total; i++)
   {
      double _price = MathLog(getPrice(inpNmsPrice,open[i],high[i],low[i],close[i]));
      
      //
      //
      //
         
         if (i==0) m_work[i].tema0 = m_work[i].tema1 = m_work[i].tema2 = _price;
         else
         {
            m_work[i].tema0 = m_work[i-1].tema0 + alpha*(_price          - m_work[i-1].tema0);
            m_work[i].tema1 = m_work[i-1].tema1 + alpha*(m_work[i].tema0 - m_work[i-1].tema1);
            m_work[i].tema2 = m_work[i-1].tema2 + alpha*(m_work[i].tema1 - m_work[i-1].tema2);
         }
         m_work[i].price = (3.0*m_work[i].tema0 - 3.0*m_work[i].tema1 + m_work[i].tema2);

      //
      //
      //
   
         double sumxy  = 0.00;
         double sumy   = 0.00;
         double sum    = 0.00;

         //
         //
         //
   
         for (int period=1; period<=iNmsPeriod && i>=period; period++)
         {
            sumxy += sumy+m_work[i-(period-1)].price;
            sumy  +=      m_work[i-(period-1)].price;
            sum   += ((period*sumxy - coeff[period].sumx*sumy)/coeff[period].bot)*coeff[period].root;
         }           
         val[i]  = sum*100.00;
         valc[i] = (i>0) ? (val[i]>val[i-1]) ? 0 : 1 : 0;
   }
   return(rates_total);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

template <typename T>
double getPrice(ENUM_APPLIED_PRICE price, T& open, T& high, T& low, T& close)
{
   switch (price)
   {
      case PRICE_CLOSE:    return(close);
      case PRICE_HIGH:     return(high);
      case PRICE_LOW:      return(low);
      case PRICE_OPEN:     return(open);
      case PRICE_MEDIAN:   return((high+low)/2.0);
      case PRICE_TYPICAL:  return((high+low+close)/3.0);
      case PRICE_WEIGHTED: return((high+low+close+close)/4.0);
   }            
   return(0);
}