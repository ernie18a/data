//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3
#property indicator_label1  "Upper zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "Lower zone"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'255,230,183'
#property indicator_label3  "Stoch (like)"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrLimeGreen,clrOrangeRed
#property indicator_width3  2

//
//
//

input int    inpPeriod            = 32; // Period
input int    inpSlowing           = 3;  // Slowing
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
         pr_tbiased2,   // Trend biased (extreme) price
         pr_closeclose, // Close/close
         pr_highlow,    // High/Low
         pr_haclose,    // Heiken ashi close
         pr_haopen ,    // Heiken ashi open
         pr_hahigh,     // Heiken ashi high
         pr_halow,      // Heiken ashi low
         pr_hamedian,   // Heiken ashi median
         pr_hatypical,  // Heiken ashi typical
         pr_haweighted, // Heiken ashi weighted
         pr_haaverage,  // Heiken ashi average
         pr_hamedianb,  // Heiken ashi median body
         pr_hatbiased,  // Heiken ashi trend biased price
         pr_hatbiased2, // Heiken ashi trend biased (extreme) price
         pr_habclose,   // Heiken ashi (better formula) close
         pr_habopen ,   // Heiken ashi (better formula) open
         pr_habhigh,    // Heiken ashi (better formula) high
         pr_hablow,     // Heiken ashi (better formula) low
         pr_habmedian,  // Heiken ashi (better formula) median
         pr_habtypical, // Heiken ashi (better formula) typical
         pr_habweighted,// Heiken ashi (better formula) weighted
         pr_habaverage, // Heiken ashi (better formula) average
         pr_habmedianb, // Heiken ashi (better formula) median body
         pr_habtbiased, // Heiken ashi (better formula) trend biased price
         pr_habtbiased2,// Heiken ashi (better formula) trend biased (extreme) price
      };
input enPrices inpPrice   = pr_close; // Price 
input double   inpLevelUp = 80;       // Upper level
input double   inpLevelDn = 20;       // Lower level

//
//
//

double fupu[],fupd[],fdnd[],fdnu[],val[],valc[];
struct sGlobalStruct
{
   int    period;
   int    slowing;
   double levelUp;
   double levelDn;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,fupu,INDICATOR_DATA);      
   SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu,INDICATOR_DATA);      
   SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer(4,val ,INDICATOR_DATA); 
   SetIndexBuffer(5,valc,INDICATOR_COLOR_INDEX);

      //
      //
      //

      global.period  = MathMax(inpPeriod,1);
      global.slowing = MathMax(inpSlowing,1);
      global.levelUp = MathMin(MathMax(inpLevelUp,inpLevelDn),100);
      global.levelDn = MathMax(MathMin(inpLevelUp,inpLevelDn),  0);
      
      if (inpSlowing<1) { return(INIT_FAILED); }      
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate (const int rates_total,
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
            double sto;
            double stoSum;
            int    prevBar;
            double prevMin;
            double prevMax;
            
            sWorkStruct() : prevBar(-1) {}
         };
      static sWorkStruct m_work[];
      static int         m_workSize=-1;
                     if (m_workSize<=rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);
               
   //
   //
   //
   
   for (int i=limit; i<rates_total && !_StopFlag; i++)
      {
         if (m_work[i].prevBar!=i || m_work[i+1].prevBar>=i)
               {
                  m_work[i  ].prevBar = i;
                  m_work[i+1].prevBar =-1;
      
                  //
                  //
                  //
                  
                  if (i>0 && global.period>1)
                     {
                        int _minMaxPeriod =   global.period-1; 
                        int _start        = i-global.period+1; if(_start<0) { _start = 0; _minMaxPeriod = i; }
                           m_work[i].prevMax = high[ArrayMaximum(high,_start,_minMaxPeriod)];
                           m_work[i].prevMin = low [ArrayMinimum(low ,_start,_minMaxPeriod)];
                     }
                  else
                     {
                           m_work[i].prevMin = low[i];
                           m_work[i].prevMax = high[i];
                     }                     
               }

         //
         //
         //
            
            double _min = (m_work[i].prevMin<low[i])  ? m_work[i].prevMin : low[i];
            double _max = (m_work[i].prevMax>high[i]) ? m_work[i].prevMax : high[i];
            double _rng = _max-_min;
            double _prc = iGetPrice(inpPrice,open,high,low,close,i,rates_total);
            
               fdnd[i] = _min; fdnu[i] = _min+_rng*global.levelDn/100.0;
               fupu[i] = _max; fupd[i] = _min+_rng*global.levelUp/100.0;

         m_work[i].sto = (_max!=_min) ? (_prc-_min)/(_max-_min) : 0;
         if (i>=global.slowing)
               { m_work[i].stoSum = m_work[i-1].stoSum + m_work[i].sto - m_work[i-global.slowing].sto; }
         else  { m_work[i].stoSum = m_work[i].sto; for (int k=1; k<global.slowing && i>=k; k++) m_work[i].stoSum += m_work[i-k].sto; };

               val[i]  = _min+_rng*m_work[i].stoSum/(double)global.slowing;
               valc[i] = (val[i]>=fupd[i]) ? 1 : (val[i]<=fdnu[i]) ? 2 : 0;
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
//---
//

template <typename T>
double iGetPrice(int tprice, T& open[], T& high[], T& low[], T& close[], int i, int bars)
{
   if (tprice>=pr_haclose)
   {
      struct sHaStruct
      {
         double open;
         double high;
         double low;
         double close;
      };
      static sHaStruct m_array[];
      static int       m_arraySize = -1;
                   if (m_arraySize<bars) m_arraySize = ArrayResize(m_array,bars+500);
                   
         //
         //
         //
                            
         #ifdef __MQL4__                  
            int r = bars-i-1;
         #else            
            int r = i;
         #endif            
         
         //
         //
         //
         
         double haOpen  = (r>0) ? (m_array[r-1].open + m_array[r-1].close)/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         #define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
            if (_prHABF(tprice))
                  if (high[i]!=low[i])
                        haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
                  else  haClose = (open[i]+close[i])/2.0; 
         #undef  _prHABF                  
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         
         if(haOpen<haClose) { m_array[r].high  = haLow;  m_array[r].low = haHigh; } 
         else               { m_array[r].high  = haHigh; m_array[r].low = haLow;  } 
                              m_array[r].open  = haOpen;
                              m_array[r].close = haClose;
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
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
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}