//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDeepSkyBlue
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_width1  2
#property indicator_width2  2
#property strict

//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};
input int      CalcPeriod = 20;       // Calculation period
input enPrices Price      = pr_close; // Price 
input double   Q1         = 0.8;      // K for entries
input double   Q2         = 0.4;      // K for exits

//
//
//

double quot1[],quot2[],hp[],peak[],prices[];
double angle = 0.707 * 2.0 * M_PI /100;
double alpha = (cos(angle)+sin(angle)-1.0)/cos(angle);

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,quot1 ,INDICATOR_DATA);
   SetIndexBuffer(1,quot2 ,INDICATOR_DATA);
   SetIndexBuffer(2,hp    ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,prices,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,peak  ,INDICATOR_CALCULATIONS);

      //
      //
      //
      
   return(INIT_SUCCEEDED); 
}
void OnDeinit(const int reason){ return; }


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[]) 
{
   int limit = (prev_calculated==0) ? 0 : prev_calculated-1;
         
   //
   //
   //
    
      for(int i=limit; i<rates_total; i++)
      {
         prices[i] = getPrice(Price,open,close,high,low,i,rates_total); 
         if (i<2) 
         { 
            hp[i]   = prices[i]; 
            peak[i] = prices[i]; iSsm(hp[i],CalcPeriod,i,rates_total);
            continue; 
         }
         
         //
         //
         //
         
         hp[i]   = (1-alpha/2.0)*(1-alpha/2.0)*(prices[i]-2.0*prices[i-1]+prices[i-2]) + 2.0*(1-alpha)*hp[i-1] - (1-alpha)*(1-alpha)*hp[i-2];         
         peak[i] = 0.991*peak[i-1];
            double hps  = iSsm(hp[i],CalcPeriod,i,rates_total);
                  if (MathAbs(hps)>peak[i]) peak[i] = MathAbs(hps);
            double x = 0; if (peak[i] != 0) x=hps/peak[i];
            
            //
            //
            //
            
            quot1[i] = (x+Q1)/(Q1*x+1.0);               
            quot2[i] = (x+Q2)/(Q2*x+1.0);               
      }       
      return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//

#define _ssmInstances 1
double iSsm(double price, double period, int i, int bars, int instanceNo=0)
{
   struct sCoeffsStruct
      {
         double _speriod;
         double _sc1;
         double _sc2;
         double _sc3;
            sCoeffsStruct() : _speriod(EMPTY_VALUE) {}
      };
   static sCoeffsStruct m_coeffs[_ssmInstances];
   struct sDataStruct
      {
         double _tprice;
         double _ssm;
      };
   struct sWorkStruct { sDataStruct data[_ssmInstances]; };
   static sWorkStruct m_work[];
   static int         m_workSize = -1;
                  if (m_workSize<bars) m_workSize = ArrayResize(m_work,bars+500,2000);
                  if (m_coeffs[instanceNo]._speriod != period)
                     {
                        m_coeffs[instanceNo]._speriod = period;
                           double a1 = MathExp(-1.414*M_PI/period);
                           double b1 = 2.0*a1*MathCos(1.414*M_PI/period);
                              m_coeffs[instanceNo]._sc2 = b1;
                              m_coeffs[instanceNo]._sc3 = -a1*a1;
                              m_coeffs[instanceNo]._sc1 = 1.0 - m_coeffs[instanceNo]._sc2 - m_coeffs[instanceNo]._sc3;
                     }

   //
   //
   //

      m_work[i].data[instanceNo]._ssm    = 
      m_work[i].data[instanceNo]._tprice = price;
      if (i>1)
      {  
          m_work[i].data[instanceNo]._ssm = m_coeffs[instanceNo]._sc1*(m_work[i].data[instanceNo]._tprice+m_work[i-1].data[instanceNo]._tprice)/2.0 + 
                                            m_coeffs[instanceNo]._sc2* m_work[i-1].data[instanceNo]._ssm                                + 
                                            m_coeffs[instanceNo]._sc3* m_work[i-1].data[instanceNo]._ssm; }
   return(m_work[i].data[instanceNo]._ssm);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
   if (tprice>=pr_haclose)
   {
         static double workHa[][4];
         static int    workHaSize = -1;
                   if (workHaSize<bars) workHaSize = ArrayResize(workHa,bars+500,2000);
         int r = i;
         
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][2] + workHa[r-1][3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][0] = haLow;  workHa[r][1] = haHigh; } 
         else                 { workHa[r][0] = haHigh; workHa[r][1] = haLow;  } 
                                workHa[r][2] = haOpen;
                                workHa[r][3] = haClose;
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
   }
   return(0);
}   