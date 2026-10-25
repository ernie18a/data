//+------------------------------------------------------------------+
//|                                                   dc signals.mq5 |
//|                                     DC2008 Copyright © 2008-2016 |
//|                             https://www.mql5.com/ru/users/dc2008 |
//+------------------------------------------------------------------+
#property copyright     "Copyright © 2008-2016, DC2008"
#property link          "https://www.mql5.com/ru/users/dc2008"
#property version       "2.00"
#property description   "Генератор сигналов DC signals"
//---
#property indicator_chart_window
//--- Количество буферов для расчета индикатора
#property indicator_buffers 6
//--- Количество графических серий в индикаторе
#property indicator_plots   6
//--- plot 1
#property indicator_label1  "Upper Bound"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrYellow
#property indicator_width1  3
//--- plot 2
#property indicator_label2  "Lower Bound"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrAqua
#property indicator_width2  3
//--- plot 3
#property indicator_label3  "Center line"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrRed
#property indicator_width3  1
//--- plot 4
#property indicator_label4  "Settlement price"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  clrTomato
#property indicator_width4  0
//--- plot 5
#property indicator_label5  "Reference line"
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrRed
#property indicator_width5  3
//--- plot 6
#property indicator_label6  "Upper breakborder"
#property indicator_type6   DRAW_ARROW
#property indicator_color6  clrBlue
#property indicator_width6  3
//---
input int  history=500;    // Количество баров для анализа
double   DCOS[];
double   BULLSBEARS[];
double   BufferUPDown[];
double   Buffer1[];
double   Buffer2[];
double   Buffer3[];
int      h_Bulls,h_Bears;
double   Bulls[],Bears[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   ObjectsDeleteAll(0,-1,-1);
//--- indicator buffers mapping
   ArraySetAsSeries(DCOS,true);
   ArraySetAsSeries(BULLSBEARS,true);
   ArraySetAsSeries(BufferUPDown,true);
   ArraySetAsSeries(Buffer1,true);
   ArraySetAsSeries(Buffer2,true);
   ArraySetAsSeries(Buffer3,true);
   SetIndexBuffer(0,DCOS,INDICATOR_DATA);
   SetIndexBuffer(1,BULLSBEARS,INDICATOR_DATA);
   SetIndexBuffer(2,BufferUPDown,INDICATOR_DATA);
   SetIndexBuffer(3,Buffer1,INDICATOR_DATA);
   SetIndexBuffer(4,Buffer2,INDICATOR_DATA);
   SetIndexBuffer(5,Buffer3,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
   PlotIndexSetInteger(2,PLOT_ARROW,159);
   PlotIndexSetInteger(3,PLOT_ARROW,250);
   PlotIndexSetInteger(4,PLOT_ARROW,178);
   PlotIndexSetInteger(5,PLOT_ARROW,178);
//---
   h_Bulls=iBullsPower(NULL,0,21);
   h_Bears=iBearsPower(NULL,0,21);
   ArraySetAsSeries(Bulls,true);
   ArraySetAsSeries(Bears,true);
   ChartRedraw();
   return(INIT_SUCCEEDED);
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
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(tick_volume,true);
//---
   int rt=rates_total-history;
   for(int i=0; i<6; i++)
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,rt);
   for(int i=history; i>=0; i--)
     {
      CopyBuffer(h_Bulls,0,i,1,Bulls);
      CopyBuffer(h_Bears,0,i,1,Bears);

      BULLSBEARS[i]=Bulls[0]+Bears[0];

      if(close[i]>open[i]) DCOS[i]=DCOS[i+1]+tick_volume[i];
      if(close[i]==open[i]) DCOS[i]=DCOS[i+1];
      if(close[i]<open[i]) DCOS[i]=DCOS[i+1]-tick_volume[i];

      if(close[i]>(high[i]+low[i])/2) DCOS[i]+=(double)tick_volume[i];
      if(close[i]<(high[i]+low[i])/2) DCOS[i]-=(double)tick_volume[i];

      if(close[i]>(high[i]+low[i]+open[i])/3) DCOS[i]+=(double)tick_volume[i];
      if(close[i]<(high[i]+low[i]+open[i])/3) DCOS[i]-=(double)tick_volume[i];

      if(close[i]>((high[i]+low[i])/2+open[i])/2) DCOS[i]+=(double)tick_volume[i];
      if(close[i]<((high[i]+low[i])/2+open[i])/2) DCOS[i]-=(double)tick_volume[i];
     }

   for(int i=history; i>=1; i--)
     {
      if(DCOS[i]<DCOS[i+1] && BULLSBEARS[i]>BULLSBEARS[i+1]) BufferUPDown[i]=high[i];
      if(DCOS[i]>DCOS[i+1] && BULLSBEARS[i]<BULLSBEARS[i+1]) BufferUPDown[i]=low[i];

      if(DCOS[i]<DCOS[i+1] && DCOS[i+2]<DCOS[i+1]) Buffer1[i]=high[i];
      if(DCOS[i]>DCOS[i+1] && DCOS[i+2]>DCOS[i+1]) Buffer1[i]=low[i];

      if(DCOS[i]<DCOS[i+1] && BULLSBEARS[i]>BULLSBEARS[i+1]
         && DCOS[i]>DCOS[i-1] && BULLSBEARS[i]>BULLSBEARS[i-1])
         Buffer2[i]=low[i];
      if(DCOS[i]>DCOS[i+1] && BULLSBEARS[i]<BULLSBEARS[i+1]
         && DCOS[i]<DCOS[i-1] && BULLSBEARS[i]<BULLSBEARS[i-1])
         Buffer3[i]=high[i];
     }
   for(int i=history; i>=0; i--)
     {
      DCOS[i]=NULL;
      BULLSBEARS[i]=NULL;
     }
   for(int i=history; i>=1; i--)
     {
      DCOS[i]=Buffer2[i];
      BULLSBEARS[i]=Buffer3[i];
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
