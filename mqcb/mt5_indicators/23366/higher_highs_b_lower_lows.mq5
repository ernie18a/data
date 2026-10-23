//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Higher Highs & Lower Lows"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Fill zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'235,255,235',C'255,235,235'
#property indicator_label2  "HH value"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_width2  2
#property indicator_label3  "LL value"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2

//
//--- input parameters
//

input int inpPeriod = 20; // Period

//
//--- buffers declarations
//

double valhh[],valll[],fillu[],filld[]; 
double ª_alpha; 
//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
         SetIndexBuffer(0,fillu,INDICATOR_DATA);
         SetIndexBuffer(1,filld,INDICATOR_DATA);
         SetIndexBuffer(2,valhh,INDICATOR_DATA);
         SetIndexBuffer(3,valll,INDICATOR_DATA);
            ª_alpha = 2.0/(inpPeriod+1.0);
   //         
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Higher Highs & Lower Lows ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
//  Custom indicator iteration function
//------------------------------------------------------------------
//
//---
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
   int start= prev_calculated-1; if (start<0) start=0; for (int i=start; i<rates_total && !_StopFlag; i++)
   {
      double _hhmin,_hhmax,_llmin,_llmax;
         _hhMinMax.calculate(high[i],high[i],inpPeriod,_hhmin,_hhmax,i);
         _llMinMax.calculate(low[i] ,low[i] ,inpPeriod,_llmin,_llmax,i);

         //
         //---
         //
         
         if (i>0)
         {         
            double _hhval = (high[i]>high[i-1]) ? 100*(high[i]-_hhmin)/(_hhmax-_hhmin) : 0;
            double _llval = (low[i] <low[i-1] ) ? 100*(_llmax -low[i])/(_llmax-_llmin) : 0;
            valhh[i] = fillu[i] = valhh[i-1] + ª_alpha*(_hhval-valhh[i-1]);
            valll[i] = filld[i] = valll[i-1] + ª_alpha*(_llval-valll[i-1]);
         }
         else valhh[i] = valll[i] = 0;            
   }
   return (rates_total);
}

//------------------------------------------------------------------
//    Custom function(s)
//------------------------------------------------------------------
//
//---
//

class cMinMax
{
   private :
      int    originalPeriod;
      int    period;
      int    prevbar;
      double currmin;
      double currmax;
      double prevmax;
      double prevmin;
      double minArray[];
      double maxArray[];
         
   public :
      cMinMax() { originalPeriod = prevbar = INT_MIN;       return; }
     ~cMinMax() { ArrayFree(minArray); ArrayFree(maxArray); return; }
     
      //
      //
      //
     
      void calculate(double valueMin, double valueMax, int forPeriod, double& min, double& max, int i)
      {
         if (prevbar!=i)
         {
            prevbar = i;
               if (originalPeriod!=forPeriod)
               {
                     originalPeriod =  forPeriod;
                     period         = (forPeriod>0) ? forPeriod : 1;
                     prevmin        = valueMin;
                     prevmax        = valueMax;
                     currmin        = valueMin;
                     currmax        = valueMax;
                           ArrayResize(minArray,period-1); ArrayInitialize(minArray,valueMin);
                           ArrayResize(maxArray,period-1); ArrayInitialize(maxArray,valueMax);
               }
               if (period>1)
               {
                  int _pos = (i) % (period-1);
                     minArray[_pos] = currmin;
                     maxArray[_pos] = currmax;
                     prevmin        = minArray[ArrayMinimum(minArray)];
                     prevmax        = maxArray[ArrayMaximum(maxArray)];
               }
               else  { prevmin = valueMin; prevmax = valueMax; }
         }

         //
         //
         //
            
         currmin = valueMin;
         currmax = valueMax;
            max = (prevmax>valueMax) ? prevmax : valueMax;
            min = (prevmin<valueMin) ? prevmin : valueMin;
         return;
     }
};
cMinMax _hhMinMax;
cMinMax _llMinMax;
//------------------------------------------------------------------
