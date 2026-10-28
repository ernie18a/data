//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Wso & Wro channel"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_label1  "Wso & Wro zone"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrGainsboro,clrGainsboro
#property indicator_label2  "Wso"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_label3  "Wro"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_width3  1
//--- input parameters
input int  inpWsoWroPeriod=9; // Wso & Wro period
double wso[],wro[],fillu[],filld[],wrk[][12];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fillu,INDICATOR_DATA);
   SetIndexBuffer(1,filld,INDICATOR_DATA);
   SetIndexBuffer(2,wso,INDICATOR_DATA);
   SetIndexBuffer(3,wro,INDICATOR_DATA);
//--- indicator short name assignment
   IndicatorSetString(INDICATOR_SHORTNAME,"Wso & Wro channel("+(string)inpWsoWroPeriod+")");
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
      wso[i]=wrk[i][S1];
      wro[i]=wrk[i][R1];
      filld[i]=wso[i];
      fillu[i]=wro[i];
     }
   return (i);
  }
