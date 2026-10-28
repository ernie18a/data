//+------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property version     "1.00"
#property description "Dual ulcer index"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
#property indicator_label1  "Index up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_style1  STYLE_DOT
#property indicator_label2  "Index down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkGray
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Ulcer index"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrDarkGray,clrDodgerBlue,clrSandyBrown
#property indicator_width3  2
//--- input parameters
enum enCalcType
{
   uind_regular, // Regular ulcer index calculation
   uind_inverted // Inverted ulcer index calculation
};
input int                inpPeriod = 32;           // Ulcer index period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE;  // Price
input enCalcType         inpType   = uind_regular; // Calculation mode  
//--- buffers declarations
double uindu[],uindd[],val[],valc[],prices[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,uindu,INDICATOR_DATA);
   SetIndexBuffer(1,uindd,INDICATOR_DATA);
   SetIndexBuffer(2,val,INDICATOR_DATA);
   SetIndexBuffer(3,valc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,prices,INDICATOR_CALCULATIONS);
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Dual"+(inpType==uind_inverted?" inverted":"")+" ulcer index ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);

   //
   //---
   //
   
   int i=(int)MathMax(prev_calculated-1,0); for(; i<rates_total && !_StopFlag; i++)
     {
      
       prices[i] = getPrice(inpPrice,open,close,high,low,i,rates_total); 
       if (i<inpPeriod) 
       {
         val[i]  = uindu[i] = uindd[i] = EMPTY_VALUE;
         valc[i] = 0;
         continue;
       }
       //
       //---
       //         
       
       double sumsqd = 0;
       double sumsqu = 0;
       if (inpType==uind_regular)
       {
            double max = prices[i-inpPeriod+1];
            double min = prices[i-inpPeriod+1];
   
            for (int k = inpPeriod-2; k>=0; k--)
               {
                  if (prices[i-k] > max)
                       max = prices[i-k];
                  else sumsqd += MathPow(100.0*((max-prices[i-k])/max),2);
                  if (prices[i-k] < min)
                       min = prices[i-k];
                  else sumsqu += MathPow(100.0*((prices[i-k]-min)/min),2);
               }
         }
         else
         {
            double max = prices[i];
            double min = prices[i];
   
            for (int k = 1; k<inpPeriod; k++)
               {
                  if (prices[i-k] > max)
                       max = prices[i-k];
                  else sumsqu += MathPow(100.0*((max-prices[i-k])/max),2);
                  if (prices[i-k] < min)
                       min = prices[i-k];
                  else sumsqd += MathPow(100.0*((prices[i-k]-min)/min),2);
               }
         }               

         //
         //
         //
         //
         //
         
         uindu[i] = MathSqrt(sumsqu/inpPeriod);
         uindd[i] = MathSqrt(sumsqd/inpPeriod);
         valc[i]  = (uindu[i]>uindd[i]) ? 1 : (uindu[i]<uindd[i]) ? 2 : valc[i];
         val[i]   = (valc[i]==1) ? uindu[i] : uindd[i];
     }
   return (i);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
