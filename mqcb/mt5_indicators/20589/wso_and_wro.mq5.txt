//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Wso & Wro"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_label1  "Wso"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2
#property indicator_label2  "Wro"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDeepSkyBlue
#property indicator_width2  2
//--- input parameters
input int  inpWsoWroPeriod=9;         // Wso & Wro period
double wso[],wro[],wrk[][12];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,wso,INDICATOR_DATA);
   SetIndexBuffer(1,wro,INDICATOR_DATA);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Wso & Wro ("+(string)inpWsoWroPeriod+")");
//---
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
#define S1 0
#define S2 1
#define S3 2
#define S4 3
#define S5 4
#define S6 5
#define R1 6
#define R2 7
#define R3 8
#define R4 9
#define R5 10
#define R6 11
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
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(ArrayRange(wrk,0)!=rates_total) ArrayResize(wrk,rates_total);
//
//---
//
   int center=(inpWsoWroPeriod-1)/2;
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      if(i==0)
        {
         for(int k=0; k<6; k++)
           {
            wrk[i][k]   = low[i];
            wrk[i][k+6] = high[i];
           }
         continue;
        }
      //
      //---
      //
      int _start  = (int)MathMax(i-inpWsoWroPeriod+1,0);
      int lowest  = i-ArrayMinimum(low, _start,inpWsoWroPeriod);
      int highest = i-ArrayMaximum(high,_start,inpWsoWroPeriod);

      for(int k=0; k<12; k++) wrk[i][k] = wrk[i-1][k];
      if(lowest==center)
        {
         wrk[i][S1] = low[i-center];
         wrk[i][S2] = wrk[i-1][S1];
         wrk[i][S3] = wrk[i-1][S2];
         wrk[i][S4] = wrk[i-1][S3];
         wrk[i][S5] = wrk[i-1][S4];
         wrk[i][S6] = wrk[i-1][S5];
        }
      if(highest==center)
        {
         wrk[i][R1] = high[i-center];
         wrk[i][R2] = wrk[i-1][R1];
         wrk[i][R3] = wrk[i-1][R2];
         wrk[i][R4] = wrk[i-1][R3];
         wrk[i][R5] = wrk[i-1][R4];
         wrk[i][R6] = wrk[i-1][R5];
        }
      wso[i]=100*(1-(MathInt(wrk[i][S1]/close[i])+
                  MathInt(wrk[i][S2]/close[i])+
                  MathInt(wrk[i][S3]/close[i])+
                  MathInt(wrk[i][S4]/close[i])+
                  MathInt(wrk[i][S5]/close[i])+
                  MathInt(wrk[i][S6]/close[i]))/6.0);
      wro[i]=100*(1-(MathInt(wrk[i][R1]/close[i])+
                  MathInt(wrk[i][R2]/close[i])+
                  MathInt(wrk[i][R3]/close[i])+
                  MathInt(wrk[i][R4]/close[i])+
                  MathInt(wrk[i][R5]/close[i])+
                  MathInt(wrk[i][R6]/close[i]))/6.0);
     }
   return (i);
  }
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
double MathInt(double number)
  {
   if(number>=1.0)
      return(1);
   else  return(0);
  }
//+------------------------------------------------------------------+
