//------------------------------------------------------------------

   #property copyright "mladen"
   #property link      "www.forex-tsd.com"

//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Velocity"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

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
   pr_average,    // Average (high+low+oprn+close)/4
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage   // Heiken ashi average
};

//
//
//
//
//

input int       Length       = 32;        // Velocity period
input enPrices  Price        = pr_median; // Price to use
input int       NormPeriod   = 14;        // Normalization period
input color     ColorFrom    = clrOrange; // Color down
input color     ColorTo      = clrLime;   // Color Up
input int       ColorSteps   = 50;        // Color steps for drawing

//
//
//
//
//

double vel[];
double colorBuffer[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int cSteps;
int OnInit()
{
   SetIndexBuffer(0,vel,INDICATOR_DATA); 
   SetIndexBuffer(1,colorBuffer,INDICATOR_COLOR_INDEX); 
             cSteps = (ColorSteps>1) ? ColorSteps : 2;
             PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,cSteps+1);
               for (int i=0;i<cSteps+1;i++) 
                     PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,gradientColor(i,cSteps+1,ColorFrom,ColorTo));

   //
   //
   //
   //
   //
            
   IndicatorSetString(INDICATOR_SHORTNAME," Velocity ("+string(Length)+")");
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

   //
   //
   //
   //
   //

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      double price  = getPrice(Price,open,close,high,low,i,rates_total);
             vel[i] = iRsi(iVelocity(price,Length,i,rates_total),NormPeriod,rates_total,i);
             if (i>0)
             {
                colorBuffer[i] = colorBuffer[i-1];
                  double min = vel[i];
                  double max = vel[i];
                  double col = 0;
                  for(int k=1; k<ColorSteps && (i-k)>=0; k++)
                  {
                     min = (vel[i-k]<min) ? vel[i-k] : min;
                     max = (vel[i-k]>max) ? vel[i-k] : max;
                  }
                  if((max-min) == 0)
                        col = 50;
                  else  col = 100 * (vel[i]-min)/(max-min);         
                  colorBuffer[i] = MathFloor(col*cSteps/100.0);                                  
             }                    
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


double workHa[][4];
double getPrice(enPrices price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
  if (price>=pr_haclose && price<=pr_haaverage)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars);

         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][2] + workHa[i-1][3])/2.0;
         else   haOpen  = open[i]+close[i];
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][0] = haLow;  workHa[i][1] = haHigh; } 
         else                 { workHa[i][0] = haHigh; workHa[i][1] = haLow;  } 
                                workHa[i][2] = haOpen;
                                workHa[i][3] = haClose;
         //
         //
         //
         //
         //
         
         switch (price)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
   }
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

double prices[];
double iVelocity(double price, double length, int i, int total)
{
   if (ArraySize(prices)!=total) ArrayResize(prices,total);
   prices[i] = price;
   
   
   double suma = 0.0, sumwa=0;
   double sumb = 0.0, sumwb=0;

      for(int k=0; k<length && (i-k)>=0; k++)
      {
         double weight = length-k;
            suma  += prices[i-k] * weight;
            sumb  += prices[i-k] * weight * weight;
            sumwa += weight;
            sumwb += weight*weight;
      }
   return(sumb/sumwb-suma/sumwa);
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

//
//
//
//

double iRsi(double price, double period, int bars, int i, int forInstance=0)
{
   if (ArrayRange(workRsi,0)!=bars) ArrayResize(workRsi,bars);
   int z = forInstance*3; double alpha = 1.0 /(double)period; 

   //
   //
   //
   //
   //
   
      workRsi[i][_price+z] = price;
      if (i<period)
      {
         int k; double sum = 0; for (k=0; k<period && (i-k-1)>=0; k++) sum += MathAbs(workRsi[i-k][_price+z]-workRsi[i-k-1][_price+z]);
            workRsi[i][_change+z] = (workRsi[i][_price+z]-workRsi[0][_price+z])/MathMax(k,1);
            workRsi[i][_changa+z] =                                         sum/MathMax(k,1);
      }
      else
      {
         double change = workRsi[i][_price+z]-workRsi[i-1][_price+z];
            workRsi[i][_change+z] = workRsi[i-1][_change+z] + alpha*(        change  - workRsi[i-1][_change+z]);
            workRsi[i][_changa+z] = workRsi[i-1][_changa+z] + alpha*(MathAbs(change) - workRsi[i-1][_changa+z]);
      }
      if (workRsi[i][_changa+z] != 0)
            return(50.0*(workRsi[i][_change+z]/workRsi[i][_changa+z]+1));
      else  return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

color getColor(int stepNo, int totalSteps, color from, color to)
{
   double stes = (double)totalSteps-1.0;
   double step = (from-to)/(stes);
   return((color)round(from-step*stepNo));
}
color gradientColor(int step, int totalSteps, color from, color to)
{
   color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
   color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
   color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
   return(newBlue+newGreen+newRed);
}