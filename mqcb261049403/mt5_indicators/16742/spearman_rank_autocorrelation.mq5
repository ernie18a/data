//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers   3
#property indicator_plots     2
#property indicator_minimum  -1
#property indicator_maximum  +1

#property indicator_label1  "Spearman levels"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrLimeGreen,clrPaleVioletRed
#property indicator_label2  "Spearman"
#property indicator_type2   DRAW_LINE
#property indicator_color2  DimGray
#property indicator_width2  2

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
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage   // Heiken ashi average
};

input int      SpearmanRank = 14;        // Spearman rank
input enPrices Price        = pr_close;  // Price to use
input double   UpLevel      = +0.85;     // Up level
input double   DnLevel      = -0.85;     // Down level

//
//
//
//
//

double sr[];
double lvla[];
double lvlb[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,lvla,INDICATOR_DATA);
   SetIndexBuffer(1,lvlb,INDICATOR_DATA);
   SetIndexBuffer(2,sr  ,INDICATOR_DATA);
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,UpLevel);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,DnLevel);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,DimGray);
   
   IndicatorSetString(INDICATOR_SHORTNAME,"Spearman rank (auto)correlation ("+(string)SpearmanRank+","+DoubleToString(DnLevel,2)+","+DoubleToString(UpLevel,2)+")");
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

double sort[][3];
double prices[];
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
   
   if (ArraySize(prices)!=rates_total)     ArrayResize(prices,rates_total);
   if (ArrayRange(sort,0) != SpearmanRank) ArrayResize(sort,SpearmanRank);
   
      //
      //
      //
      //
      //
      
      double coef = (MathPow(SpearmanRank,3) - SpearmanRank);

         for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
         {
            prices[i] = getPrice(Price,open,close,high,low,i,rates_total);
            for(int k=0; k<SpearmanRank && (i-k)>=0; k++)
            {
               sort[k][0] = prices[i-k];
               sort[k][1] = k+1;
            }
            SortIt(sort,SpearmanRank);   
               
            //
            //
            //
            //
            //

            double sum = 0.0;
            for(int k=0; k<SpearmanRank; k++)
                  sum += MathPow(sort[k][1]-sort[k][2],2);
                  sr[i]   = 1.00-6.00*sum/coef;
                  lvla[i] = sr[i];
                  lvlb[i] = sr[i];
         
                  if (sr[i]>UpLevel) lvlb[i] = UpLevel;
                  if (sr[i]<DnLevel) lvlb[i] = DnLevel;
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

   //
   //
   //
   //
   //
   
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
   }
   return(0);
}



//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//    shell sort 
//
//
//

void SortIt(double& array[][3], int Rank )
{
   int size      = ArrayRange(array,0);
   int increment = size/2;

   //
   //
   //
   //
   //
   
   while (increment > 0)
   {
      for (int i = increment; i < Rank; i++)
      {
         int    j    = i;
         double temp = array[i][0];
         double temi = array[i][1];
         while ((j >= increment) && (array[j-increment][0] < temp))
         {
            array[j][0] = array[j-increment][0];
            array[j][1] = array[j-increment][1];
            j       =    j-increment;
         }
         array[j][0] = temp;
         array[j][1] = temi;
      }
      if (increment == 2) increment = 1;
      else                increment = (int)(increment / 2.2);
   }

   //
   //
   //
   //
   //
   //
   //

   for(int i = 0; i < size-1; i++)
   {
      array[i][2] = i+1; if(array[i][0] != array[i+1][0]) continue;

      //
      //
      //    average where needed
      //
      //
      
            int j;
            double temp = i+1;
            double temi = 1;
                for (j=i+1; j < size; j++,temi++)
                   if(array[j][0] == array[i][0])
                         temp += (j+1);
                   else break;
            temp /= temi;
      for(; i<j; i++) array[i][2] = temp;
   }
}