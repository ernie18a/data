//------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   3
#property indicator_label1  "T3 velocity histo"
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
#property indicator_color1  clrLimeGreen,clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "T3 velocity"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen,clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_label3  "T3 velocity signal"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrLimeGreen,clrOrange
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

//
//---
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

input double   T3Period    = 14;             // T3 velocity calculation period
input double   T3Hot       = 1.0;            // T3 hot value
input bool     T3Original  = false;          // T3 original Tillson calculation?
input enPrices Price       = pr_close;       // Price to use
input int      ColorNorm   = 20;             // Colors normalization period
input color    ColorFrom   = clrSandyBrown;  // Color down
input color    ColorTo     = clrDeepSkyBlue; // Color Up
input int      ColorSteps  = 20;             // Color steps for drawing

//
//
//
//
//
//

double vel[],vel2[];
double velh[],velh2[];
double colorBuffer[],colorBuffer2[];
double colorBufferh[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int cSteps;
int OnInit()
{
   SetIndexBuffer(0,velh,INDICATOR_DATA); 
   SetIndexBuffer(1,velh2,INDICATOR_DATA); 
   SetIndexBuffer(2,colorBufferh,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(3,vel,INDICATOR_DATA); 
   SetIndexBuffer(4,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(5,vel2,INDICATOR_DATA); 
   SetIndexBuffer(6,colorBuffer2,INDICATOR_COLOR_INDEX); 
   cSteps = (ColorSteps>1) ? ColorSteps : 2;
      PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,cSteps+1);
      PlotIndexSetInteger(1,PLOT_COLOR_INDEXES,cSteps+1);
      PlotIndexSetInteger(2,PLOT_COLOR_INDEXES,cSteps+1);
      for (int i=0;i<cSteps+1;i++) PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,gradientColor(i,cSteps+1,ColorFrom,ColorTo));
      for (int i=0;i<cSteps+1;i++) PlotIndexSetInteger(1,PLOT_LINE_COLOR,i,gradientColor(i,cSteps+1,ColorFrom,ColorTo));
      for (int i=0;i<cSteps+1;i++) PlotIndexSetInteger(2,PLOT_LINE_COLOR,i,gradientColor(i,cSteps+1,ColorFrom,ColorTo));
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      static int    prev_i=-1;
      static double prev_max,prev_min;

      //
      //
      //
   
      int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
      {
      double price = getPrice(Price,open,close,high,low,i,rates_total);
             vel[i]  = iT3(price,T3Period,T3Hot,T3Original,i,rates_total,0)-iT3(price,T3Period,T3Hot/2.0,T3Original,i,rates_total,1);      
             velh[i] = vel[i];
             if (i>0) { velh2[i] = vel[i-1]; vel2[i] = vel[i-1]; }
               if (prev_i!=i)
               {
                  prev_i = i; 
                  int start    = i-ColorNorm+1; if (start<0) start=0;
                      prev_max = vel[ArrayMaximum(vel,start,ColorNorm-1)];
                      prev_min = vel[ArrayMinimum(vel,start,ColorNorm-1)];
               }
               double max = (vel[i] > prev_max) ? vel[i] : prev_max;
               double min = (vel[i] < prev_min) ? vel[i] : prev_min;
               double sto = (max!=min) ? 100*(vel[i]-min)/(max-min) : 50;
                  colorBuffer[i]  = (int)(sto*cSteps/100.0);                                  
                  colorBuffer2[i] = colorBuffer[i];
                  colorBufferh[i] = colorBuffer[i];
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

double iT3(double price, double period, double volumeFactor, bool original, int i, int bars, int instance=0)
{
   #define ¤ instance
   #define _functionInstances 2
   #define _functionArraySize 7
   
      //
      //---
      //
      
         class cT3CoeffStruct
            {
               public : 
                  double OriginalPeriod;
                  double OriginalVolume;
                  double Volume;
                  double CalcPeriod;
                  double VolumePlus;
                  double Alpha;
                  
                  cT3CoeffStruct(): OriginalPeriod(DBL_EPSILON),OriginalVolume(DBL_EPSILON) {  }
                 ~cT3CoeffStruct()                                                          { };
            };
         static cT3CoeffStruct m_coeff[_functionInstances];
         static double         m_array[][_functionInstances][_functionArraySize];
         static int            m_arraySize=-1;
         if (m_arraySize<bars) { m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
         if (m_coeff[¤].OriginalPeriod!=period || m_coeff[¤].OriginalVolume!=volumeFactor)
            {
               m_coeff[¤].OriginalPeriod =  period;
               m_coeff[¤].OriginalVolume =  volumeFactor;
               m_coeff[¤].Volume         = (volumeFactor>0) ? (volumeFactor>1) ? 1 : volumeFactor : DBL_MIN;
               m_coeff[¤].VolumePlus     =  m_coeff[¤].Volume+1;
               m_coeff[¤].CalcPeriod     = (period > 1 ? period : 1);
               m_coeff[¤].Alpha          = (original) ? 2.0/(1.0+m_coeff[¤].CalcPeriod) : 2.0/(2.0+(m_coeff[¤].CalcPeriod-1.0)/2.0);
            }
   
      //
      //---
      //
   
      if(i>0 && m_coeff[¤].CalcPeriod>1)
      {
         
            #define _gdema(_ind1,_ind2) (m_array[i][¤][_ind1]*m_coeff[¤].VolumePlus-m_array[i][¤][_ind2]*m_coeff[¤].Volume)
         
            //
            //---
            //
         
            m_array[i][¤][0] = m_array[i-1][¤][0]+m_coeff[¤].Alpha*(price           -m_array[i-1][¤][0]);
            m_array[i][¤][1] = m_array[i-1][¤][1]+m_coeff[¤].Alpha*(m_array[i][¤][0]-m_array[i-1][¤][1]);
            m_array[i][¤][2] = m_array[i-1][¤][2]+m_coeff[¤].Alpha*(_gdema(0,1)     -m_array[i-1][¤][2]);
            m_array[i][¤][3] = m_array[i-1][¤][3]+m_coeff[¤].Alpha*(m_array[i][¤][2]-m_array[i-1][¤][3]);
            m_array[i][¤][4] = m_array[i-1][¤][4]+m_coeff[¤].Alpha*(_gdema(2,3)     -m_array[i-1][¤][4]);
            m_array[i][¤][5] = m_array[i-1][¤][5]+m_coeff[¤].Alpha*(m_array[i][¤][4]-m_array[i-1][¤][5]);
            m_array[i][¤][6] = _gdema(4,5);
            
            #undef _gdema 
      }
      else for(int k=0; k<_functionArraySize; k++) m_array[i][¤][k] = price;
   return(m_array[i][¤][6]);
   
   //
   //---
   //

   #undef ¤ #undef _functionInstances #undef _functionArraySize
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


double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
  if (price>=pr_haclose)
   {
      if (ArrayRange(workHa,0)<= bars) ArrayResize(workHa,bars+500);
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][2] + workHa[i-1][3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
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
   //
   //
   
   switch (price)
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