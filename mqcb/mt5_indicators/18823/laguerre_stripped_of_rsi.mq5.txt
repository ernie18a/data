//------------------------------------------------------------------
#property copyright "© mladen, 2017"
#property link      "mladenfx@gmail.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 11
#property indicator_plots   8
#property indicator_label1  "Fill 1"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'0,205,126',C'155,0,126'
#property indicator_label2  "Fill 2"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'0,180,126',C'180,0,126'
#property indicator_label3  "Fill 3"
#property indicator_type3   DRAW_FILLING
#property indicator_color3  C'0,155,126',C'205,0,126'
#property indicator_label4  "Laguerre 1"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGray
#property indicator_label5  "Laguerre 2"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrGray
#property indicator_label6  "Laguerre 3"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrGray
#property indicator_label7  "Laguerre 4"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGray
#property indicator_label8  "RSI"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrSilver
#property indicator_width8  2

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
enum enRsiMaMethod
{
   rsm_original=-1, // Original RSI calculation
   rsm_sma,         // Calculate RSI using SMA
   rsm_ema,         // Calculate RSI using EMA
   rsm_smma,        // Calculate RSI using SMMA
   rsm_lwma         // Calculate RSI using LWMA
};

input  int             RsiPeriod     = 14;            // RSI period
input  enPrices        RsiPrice      = pr_close;      // RSI price
input  enRsiMaMethod   MaMethodToUse = rsm_original;  // What ma method to use in rsi calculation
input  double          Gamma         = 0.75;          // Laguerre gamma

double lagg1u[],lagg1d[],lagg2u[],lagg2d[],lagg3u[],lagg3d[],lagg1[],lagg2[],lagg3[],lagg4[],rsi[];

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
   SetIndexBuffer( 0,lagg1u ,INDICATOR_DATA);
   SetIndexBuffer( 1,lagg1d ,INDICATOR_DATA);
   SetIndexBuffer( 2,lagg2u ,INDICATOR_DATA);
   SetIndexBuffer( 3,lagg2d ,INDICATOR_DATA);
   SetIndexBuffer( 4,lagg3u ,INDICATOR_DATA);
   SetIndexBuffer( 5,lagg3d ,INDICATOR_DATA);
   SetIndexBuffer( 6,lagg1  ,INDICATOR_DATA);
   SetIndexBuffer( 7,lagg2  ,INDICATOR_DATA);
   SetIndexBuffer( 8,lagg3  ,INDICATOR_DATA);
   SetIndexBuffer( 9,lagg4  ,INDICATOR_DATA);
   SetIndexBuffer(10,rsi    ,INDICATOR_DATA);
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

   int i=MathMax(prev_calculated-1,0); for (; i<rates_total  && !_StopFlag; i++)
   {
      double laga,lagb,lagc,lagd; 
         rsi[i] = iRsi(MaMethodToUse,getPrice(RsiPrice,open,close,high,low,i,rates_total),RsiPeriod,i,rates_total);
         iLaGuerre(rsi[i],Gamma,laga,lagb,lagc,lagd,i,rates_total,0);
            lagg1[i]  = laga;
            lagg2[i]  = lagb;
            lagg3[i]  = lagc;
            lagg4[i]  = lagd;
            lagg1u[i] = laga;
            lagg1d[i] = lagb;
            lagg2u[i] = lagb;
            lagg2d[i] = lagc;
            lagg3u[i] = lagc;
            lagg3d[i] = lagd;
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workLag[][4];
void iLaGuerre(double price, double gamma, double& val1, double& val2, double& val3, double& val4, int i, int bars, int instanceNo=0)
{
   if (ArrayRange(workLag,0)!=bars) ArrayResize(workLag,bars); instanceNo*=4;

   //
   //
   //
   //
   //

   gamma = MathMax(MathMin(gamma,0.99),0.01);
   if (i>0)
   {      
      workLag[i][instanceNo+0] = (1.0 - gamma)*price                                          + gamma*workLag[i-1][instanceNo+0];
	   workLag[i][instanceNo+1] = -gamma*workLag[i][instanceNo+0] + workLag[i-1][instanceNo+0] + gamma*workLag[i-1][instanceNo+1];
	   workLag[i][instanceNo+2] = -gamma*workLag[i][instanceNo+1] + workLag[i-1][instanceNo+1] + gamma*workLag[i-1][instanceNo+2];
	   workLag[i][instanceNo+3] = -gamma*workLag[i][instanceNo+2] + workLag[i-1][instanceNo+2] + gamma*workLag[i-1][instanceNo+3];
   }	   
   else for (int k=0; k<4; k++) workLag[i][instanceNo+k] = price;
   val1 = workLag[i][instanceNo+0];
   val2 = workLag[i][instanceNo+1];
   val3 = workLag[i][instanceNo+2];
   val4 = workLag[i][instanceNo+3];
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

double workRsi[][3];
#define _price  0
#define _change 1
#define _changa 2

double iRsi(int maMethod, double price, double period, int i, int _bars, int instanceNo=0)
{
   if (ArrayRange(workRsi,0)!=_bars) ArrayResize(workRsi,_bars); int r = i;
      int z = instanceNo*3; 
   
   //
   //
   //
   //
   //
   
   workRsi[r][z+_price] = price;
         if (r<period)
            {
               int k; double sum = 0; for (k=0; k<period && (r-k-1)>=0; k++) sum += MathAbs(workRsi[r-k][z+_price]-workRsi[r-k-1][z+_price]);
                  workRsi[r][z+_change] = (workRsi[r][z+_price]-workRsi[0][z+_price])/MathMax(k,1);
                  workRsi[r][z+_changa] =                                         sum/MathMax(k,1);
            }
         else
            {
               double change = workRsi[r][z+_price]-workRsi[r-1][z+_price];
               switch (maMethod)
               {
                  case rsm_original :
                     {
                        double alpha = 1.0/period; 
                               workRsi[r][z+_change] = workRsi[r-1][z+_change] + alpha*(        change  - workRsi[r-1][z+_change]);
                               workRsi[r][z+_changa] = workRsi[r-1][z+_changa] + alpha*(MathAbs(change) - workRsi[r-1][z+_changa]);
                               break;
                     }                               
                  case rsm_sma :                    
                               workRsi[r][z+_change] = iSma(        change ,(int)period,r,_bars,0);
                               workRsi[r][z+_changa] = iSma(MathAbs(change),(int)period,r,_bars,1);
                               break;
                  case rsm_ema :                    
                               workRsi[r][z+_change] = iEma(        change ,period,r,_bars,0);
                               workRsi[r][z+_changa] = iEma(MathAbs(change),period,r,_bars,1);
                               break;
                  case rsm_smma :                    
                               workRsi[r][z+_change] = iSmma(        change ,period,r,_bars,0);
                               workRsi[r][z+_changa] = iSmma(MathAbs(change),period,r,_bars,1);
                               break;
                  case rsm_lwma :                    
                               workRsi[r][z+_change] = iLwma(        change ,period,r,_bars,0);
                               workRsi[r][z+_changa] = iLwma(MathAbs(change),period,r,_bars,1);
                               break;
               }                               
            }
         if (workRsi[r][z+_changa] != 0)
               return(50.0*(workRsi[r][z+_change]/workRsi[r][z+_changa]+1));
         else  return(50.0);
   
}

//
//
//
//
//

#define _maInstances 3
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances
#define _maWorkBufferx4 4*_maInstances
#define _maWorkBufferx5 5*_maInstances

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars,  int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars,  int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
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

#define _pricesInstances 1
#define _pricesSize      4
double workHa[][_pricesInstances*_pricesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); instanceNo*=_pricesSize;
         
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