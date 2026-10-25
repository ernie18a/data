//------------------------------------------------------------------
#property copyright "© mladen"
#property link      "mladenfx@gmail.com www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "No trade zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,238,210',C'255,238,210';
#property indicator_label2  "Laguerre RSI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrPaleVioletRed
#property indicator_width2  2
#property indicator_label3  "Laguerre filter signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDimGray
#property indicator_style3  STYLE_DASHDOTDOT

//
//
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
   pr_tbiased2,   // Trend biased (extreme) price
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
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};

input double   RsiGamma             = 0.80;  // Laguerre RSI gamma
input enPrices RsiPrice             = 0;     // Price
input double   RsiSmoothGamma       = 0.001; // Laguerre RSI smooth gamma
input int      RsiSmoothSpeed       = 2;     // Laguerre RSI smooth speed (min 0, max 6)
input double   FilterGamma          = 0.60;  // Laguerre filter gamma
input int      FilterSpeed          = 2;     // Laguerre filter speed (min 0, max 6)
input double   LevelUp              = 0.85;  // Level up
input double   LevelDown            = 0.15;  // Level down
input bool     NoTradeZoneVisible   = true;  // Display no trade zone?
input double   NoTradeZoneUp        = 0.65;  // No trade zone up
input double   NoTradeZoneDown      = 0.35;  // No trade zone down

double osc[],oscs[],levu[],levd[];

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
   SetIndexBuffer(0,levu,INDICATOR_DATA);
   SetIndexBuffer(1,levd,INDICATOR_DATA);
   SetIndexBuffer(2,osc  ,INDICATOR_DATA); 
   SetIndexBuffer(3,oscs ,INDICATOR_DATA); 
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,LevelUp);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,LevelDown);
   
      IndicatorSetString(INDICATOR_SHORTNAME,"Laguerre RSI with Laguerre filter("+(string)RsiGamma+","+(string)FilterGamma+")");
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
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
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
   
   //
   //
   //
   //
   //
      
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      osc[i]  = LaGuerreRsi(getPrice(RsiPrice,open,close,high,low,i,rates_total),RsiGamma,RsiSmoothGamma,RsiSmoothSpeed,i,rates_total);
      oscs[i] = LaGuerreFil(osc[i],FilterGamma,FilterSpeed,i,rates_total);
      levu[i] = NoTradeZoneUp;
      levd[i] = NoTradeZoneDown;
   }
   return(rates_total);
}


//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLagRsi[][15];
double LaGuerreRsi(double price, double gamma, double smooth, double smoothSpeed, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workLagRsi,0)!=bars) ArrayResize(workLagRsi,bars); instanceNo*=5;

   //
   //
   //
   //
   //

   workLagRsi[i][instanceNo+0] = (i>0) ? (1.0 - gamma)*price                                                + gamma*workLagRsi[i-1][instanceNo+0] : price;
	workLagRsi[i][instanceNo+1] = (i>0) ? -gamma*workLagRsi[i][instanceNo+0] + workLagRsi[i-1][instanceNo+0] + gamma*workLagRsi[i-1][instanceNo+1] : price;
	workLagRsi[i][instanceNo+2] = (i>0) ? -gamma*workLagRsi[i][instanceNo+1] + workLagRsi[i-1][instanceNo+1] + gamma*workLagRsi[i-1][instanceNo+2] : price;
	workLagRsi[i][instanceNo+3] = (i>0) ? -gamma*workLagRsi[i][instanceNo+2] + workLagRsi[i-1][instanceNo+2] + gamma*workLagRsi[i-1][instanceNo+3] : price;

   //
   //
   //
   //
   //

      double CU = 0.00;
      double CD = 0.00;
      if (i>0)
      {   
            if (workLagRsi[i][instanceNo+0] >= workLagRsi[i][instanceNo+1])
            			CU =      workLagRsi[i][instanceNo+0] - workLagRsi[i][instanceNo+1];
            else	   CD =      workLagRsi[i][instanceNo+1] - workLagRsi[i][instanceNo+0];
            if (workLagRsi[i][instanceNo+1] >= workLagRsi[i][instanceNo+2])
            			CU = CU + workLagRsi[i][instanceNo+1] - workLagRsi[i][instanceNo+2];
            else	   CD = CD + workLagRsi[i][instanceNo+2] - workLagRsi[i][instanceNo+1];
            if (workLagRsi[i][instanceNo+2] >= workLagRsi[i][instanceNo+3])
   	       		   CU = CU + workLagRsi[i][instanceNo+2] - workLagRsi[i][instanceNo+3];
            else	   CD = CD + workLagRsi[i][instanceNo+3] - workLagRsi[i][instanceNo+2];
         }            
         if (CU + CD != 0) 
               workLagRsi[i][instanceNo+4] = CU / (CU + CD);
         else  workLagRsi[i][instanceNo+4] = 0;

   //
   //
   //
   //
   //

   return(LaGuerreFil(workLagRsi[i][instanceNo+4],smooth,(int)smoothSpeed,i,bars,1));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workLagFil[][8];
double LaGuerreFil(double price, double gamma, int smoothSpeed, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workLagFil,0)!=bars) ArrayResize(workLagFil,bars); instanceNo*=4;
   if (gamma<=0) return(price);

   //
   //
   //
   //
   //
      
   workLagFil[i][instanceNo+0] = (i>0) ? (1.0 - gamma)*price                                                + gamma*workLagFil[i-1][instanceNo+0] : price;
	workLagFil[i][instanceNo+1] = (i>0) ? -gamma*workLagFil[i][instanceNo+0] + workLagFil[i-1][instanceNo+0] + gamma*workLagFil[i-1][instanceNo+1] : price;
	workLagFil[i][instanceNo+2] = (i>0) ? -gamma*workLagFil[i][instanceNo+1] + workLagFil[i-1][instanceNo+1] + gamma*workLagFil[i-1][instanceNo+2] : price;
	workLagFil[i][instanceNo+3] = (i>0) ? -gamma*workLagFil[i][instanceNo+2] + workLagFil[i-1][instanceNo+2] + gamma*workLagFil[i-1][instanceNo+3] : price;

   //
   //
   //
   //
   //
 
   double coeffs[]={0,0,0,0};
      smoothSpeed = MathMax(MathMin(smoothSpeed,6),0);   
      switch (smoothSpeed)
      {
         case 0: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 1; coeffs[3] = 1; break;
         case 1: coeffs[0] = 1; coeffs[1] = 1; coeffs[2] = 2; coeffs[3] = 1; break;
         case 2: coeffs[0] = 1; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
         case 3: coeffs[0] = 2; coeffs[1] = 2; coeffs[2] = 2; coeffs[3] = 1; break;
         case 4: coeffs[0] = 2; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
         case 5: coeffs[0] = 3; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
         case 6: coeffs[0] = 4; coeffs[1] = 3; coeffs[2] = 2; coeffs[3] = 1; break;
      }
   double sumc = 0; for (int k=0; k<4; k++) sumc += coeffs[k];
   return((coeffs[0]*workLagFil[i][instanceNo+0]+coeffs[1]*workLagFil[i][instanceNo+1]+coeffs[2]*workLagFil[i][instanceNo+2]+coeffs[3]*workLagFil[i][instanceNo+3])/sumc);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances 2
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
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
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
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