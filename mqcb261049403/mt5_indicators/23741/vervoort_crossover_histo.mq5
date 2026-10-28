//------------------------------------------------------------------
#property copyright "© mladen, 2018"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Crossover state"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrSilver,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2
#property indicator_minimum 0
#property indicator_maximum 1

//
//--- input parameters
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
input double   inpPeriod1 = 55;           // Fast tema period
input enPrices inpPrice1  = pr_typical;   // Fast tema price
input double   inpPeriod2 = 55;           // Slow tema period
input enPrices inpPrice2  = pr_haaverage; // Slow tema price

//
//--- indicator buffers
//

double val[],valc[],valf[],vals[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //
   //
         SetIndexBuffer(0,val ,INDICATOR_DATA);
         SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,valf,INDICATOR_CALCULATIONS);
         SetIndexBuffer(3,vals,INDICATOR_CALCULATIONS);
   //      
   //
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Vervoort crossover ("+(string)inpPeriod1+","+(string)inpPeriod2+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      valf[i] = iZlTema(getPrice(inpPrice1,open,close,high,low,i,rates_total),inpPeriod1,i,rates_total,0);
      vals[i] = iZlTema(getPrice(inpPrice2,open,close,high,low,i,rates_total),inpPeriod2,i,rates_total,1);
      val[i]  = 1;
      valc[i] = (valf[i]>vals[i]) ? 1 : (valf[i]<vals[i]) ? 2 : (i>0) ? valc[i-1] : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//
double iZlTema(double price, double period, int i, int bars, int instanceNo=0)
{

   #define _arraySize 6
   static double m_array[][2*_arraySize];
   static int m_arraySize=-1;
          if (m_arraySize<bars)
          {
              m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0);
          }

   //
   //---
   //

   #define _ztema11 0
   #define _ztema21 1
   #define _ztema31 2
   #define _ztema12 3
   #define _ztema22 4
   #define _ztema32 5

   instanceNo*=_arraySize;
   if(i>0 && period>1)
   {
      double alpha=2.0/(1.0+period);
         m_array[i][_ztema11+instanceNo] = m_array[i-1][_ztema11+instanceNo]+alpha*(price                          -m_array[i-1][_ztema11+instanceNo]);
         m_array[i][_ztema21+instanceNo] = m_array[i-1][_ztema21+instanceNo]+alpha*(m_array[i][_ztema11+instanceNo]-m_array[i-1][_ztema21+instanceNo]);
         m_array[i][_ztema31+instanceNo] = m_array[i-1][_ztema31+instanceNo]+alpha*(m_array[i][_ztema21+instanceNo]-m_array[i-1][_ztema31+instanceNo]);
         double tema1=m_array[i][_ztema31+instanceNo]+3.0*(m_array[i][_ztema11+instanceNo]-m_array[i][_ztema21+instanceNo]);

         m_array[i][_ztema12+instanceNo] = m_array[i-1][_ztema12+instanceNo]+alpha*(tema1                          -m_array[i-1][_ztema12+instanceNo]);
         m_array[i][_ztema22+instanceNo] = m_array[i-1][_ztema22+instanceNo]+alpha*(m_array[i][_ztema12+instanceNo]-m_array[i-1][_ztema22+instanceNo]);
         m_array[i][_ztema32+instanceNo] = m_array[i-1][_ztema32+instanceNo]+alpha*(m_array[i][_ztema22+instanceNo]-m_array[i-1][_ztema32+instanceNo]);
         double tema2=m_array[i][_ztema32+instanceNo]+3.0*(m_array[i][_ztema12+instanceNo]-m_array[i][_ztema22+instanceNo]);
         return(2.0*tema1-tema2);
   }
   else
   {
         m_array[i][_ztema11+instanceNo] = price;
         m_array[i][_ztema21+instanceNo] = price;
         m_array[i][_ztema31+instanceNo] = price;
         m_array[i][_ztema12+instanceNo] = price;
         m_array[i][_ztema22+instanceNo] = price;
         m_array[i][_ztema32+instanceNo] = price;
   }     
   return(price);
   #undef  _arraySize #undef  _ztema11 #undef  _ztema21 #undef  _ztema31 #undef  _ztema12 #undef  _ztema22 #undef  _ztema32
}

//
//---
//

double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars)
{
   if (tprice>=pr_haclose)
   {
      static double workHa[][4];
      static int m_arraySize=-1;
             if (m_arraySize<_bars)
             {
                 m_arraySize = ArrayResize(workHa,_bars+500); if (m_arraySize<_bars) return(0);
             }
        
            //
            //---
            //
        
            #define _max(a,b) ((a>b)?(a):(b))
            #define _min(a,b) ((a<b)?(a):(b))
         
               double haOpen  = (i>0) ? (workHa[i-1][2] + workHa[i-1][3])/2.0 : (open[i]+close[i])/2;
               double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
               double haHigh  = _max(high[i], _max(haOpen,haClose));
               double haLow   = _min(low[i] , _min(haOpen,haClose));
            
            #undef _max #undef _min            

            if(haOpen  <haClose) { workHa[i][0] = haLow;  workHa[i][1] = haHigh; }
            else                 { workHa[i][0] = haHigh; workHa[i][1] = haLow;  }
                                   workHa[i][2] = haOpen;
                                   workHa[i][3] = haClose;
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

//------------------------------------------------------------------
