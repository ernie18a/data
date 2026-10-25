//+------------------------------------------------------------------+
//|                                           CandleColorCounter.mq5 |
//|                              Saeed Molanezhad Iran +989372946203 |
//+------------------------------------------------------------------+
#property copyright "Saeed Molanezhad (Iran) +989372946203"
#property version   "1.00"
#property indicator_separate_window
#property indicator_minimum 20
#property indicator_maximum 80
#property indicator_level1 71
#property indicator_level2 62
#property indicator_level3 50
#property indicator_level4 38
#property indicator_level5 29
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_type2   DRAW_LINE
#property indicator_color2  Blue

//--- indicator buffers
double  LineBullBuffer[];
double  LineBearBuffer[];
input int  Bar_Period=89;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping   
   SetIndexBuffer(0,LineBullBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LineBearBuffer,INDICATOR_DATA);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,1);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Bar_Period);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Bar_Period);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"CCC("+string(Bar_Period)+")");
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
//---
   if(Bar_Period<rates_total)
     {
      double BBullc=0,BBearc=0;
      int i,j;
      for(i=rates_total-1;i>Bar_Period-1;i--)
        {
         BBullc=0;
         BBearc=0;
         for(j=i;j>=i-Bar_Period;j--)
           {
            if(open[j]<close[j]) {BBullc++;  }
            if(open[j]>close[j]) {BBearc++;  }
           }
         LineBullBuffer[i]=((BBullc/Bar_Period)*100);
         LineBearBuffer[i]=((BBearc/Bar_Period)*100);
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);

  }
//+------------------------------------------------------------------+
