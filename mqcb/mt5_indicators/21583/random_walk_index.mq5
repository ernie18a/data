//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Random walk index"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "Random walk index up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "Random walk index down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrPaleVioletRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//
//---
//
input int inpRwiLength = 25;       // Random walk index period

double rwiUp[],rwiDn[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
int OnInit()
{
   SetIndexBuffer(0,rwiUp,INDICATOR_DATA); 
   SetIndexBuffer(1,rwiDn,INDICATOR_DATA); 
   IndicatorSetString(INDICATOR_SHORTNAME," Random walk index ("+string(inpRwiLength)+")");
   return(INIT_SUCCEEDED);
}
//
//---
//
double ranges[];
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
   if (ArraySize(ranges)!=rates_total) ArrayResize(ranges,rates_total);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      ranges[i] = (i>2) ? MathMax(high[i-1],close[i-2])-MathMin(low[i-1],close[i-2]) : 0;
         double trwiUp = 0;
         double trwiDo = 0;
         double atr    = ranges[i];
         
         for (int k = 1; k < inpRwiLength && (i-k)>=0; k++)
         {
            atr += ranges[i-k];  
            //
            //---
            //
            double denominator  = (atr/(k+1.0))*MathSqrt(k+1);
               if (denominator != 0)
               {
                  trwiUp = MathMax(trwiUp,(high[i] - low[i-k]) / denominator);
                  trwiDo = MathMax(trwiDo,(high[i-k] - low[i]) / denominator);
               }
         }
         rwiUp[i] = trwiUp;
         rwiDn[i] = trwiDo;
   }      
   return(rates_total);
}