//------------------------------------------------------------------
#property copyright   "www.forex-tsd.com"
#property link        "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "MACD histo"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrLime,clrGreen,clrOrange,clrDarkGoldenrod
#property indicator_width1  2
#property indicator_label2  "MACD"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLime,clrOrange
#property indicator_width2  2
#property indicator_label3  "Signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  Gold
#property indicator_width3  2

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
   pr_weighted    // Weighted
};

input int      InpRsiPeriod    = 14;       // RSI period
input int      InpFastEMA      = 12;       // Fast EMA period
input int      InpSlowEMA      = 26;       // Slow EMA period
input int      InpSignalEMA    =  9;       // Signal EMA period
input enPrices InpAppliedPrice = pr_close; // Price to use
input bool     InpDoubleMacd   = true;     // Should it be double macd?

//
//
//
//
//

double  macd[];
double  maclc[];
double  macdh[];
double  macdc[];
double  signal[];


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void OnInit()
{
   SetIndexBuffer(0,macdh ,INDICATOR_DATA);
   SetIndexBuffer(1,macdc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,macd  ,INDICATOR_DATA);
   SetIndexBuffer(3,maclc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,signal,INDICATOR_DATA);
      string add = ""; if (InpDoubleMacd) add = "double";
      IndicatorSetString(INDICATOR_SHORTNAME,"MACD "+add+" ("+string(InpFastEMA)+","+string(InpSlowEMA)+","+string(InpSignalEMA)+")");
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
         double price = getPrice(InpAppliedPrice,open,close,high,low,i,rates_total);
         
         //
         //
         //
         //
         //

            double tmacd = iEma(price,InpFastEMA,rates_total,i,0)-iEma(price,InpSlowEMA,rates_total,i,1);
            if (InpDoubleMacd)
                  macd[i] = iRsi(iEma(tmacd,InpFastEMA,rates_total,i,2)-iEma(tmacd,InpSlowEMA,rates_total,i,3),InpRsiPeriod,rates_total,i)-50;
            else  macd[i] = iRsi(tmacd                                                                        ,InpRsiPeriod,rates_total,i)-50;             
            signal[i] = iEma(macd[i],InpSignalEMA,rates_total,i,4);
            macdh[i]  = macd[i];
            if (i>0)
            {
               macdc[i] = macdc[i-1];
               maclc[i] = maclc[i-1];
               if (macd[i]>0)
               {
                  if (macd[i]>macd[i-1]) macdc[i] = 0;
                  if (macd[i]<macd[i-1]) macdc[i] = 1;
               }                  
               if (macd[i]<0)
               {
                  if (macd[i]<macd[i-1]) macdc[i] = 2;
                  if (macd[i]>macd[i-1]) macdc[i] = 3;

               }
               if (macd[i]>signal[i]) maclc[i] = 0;
               if (macd[i]<signal[i]) maclc[i] = 1;
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

double workEma[][5];
double iEma(double price, double period, int bars, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= bars) ArrayResize(workEma,bars);

   //
   //
   //
   //
   //

   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   else   workEma[r][instanceNo] = price;
   return(workEma[r][instanceNo]);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//


double getPrice(enPrices pricet, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
   switch (pricet)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}