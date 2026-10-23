//|                                Copyright 2018, Aleksey Panfilov. |
//|                                                filpan1@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Aleksei Panfilov. filpan1@yandex.ru"
#property link      "https://www.mql5.com/ru/market/product/18845"
#property link      "filpan1@yandex.ru"
#property version   "1.2"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "Line1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Line2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  6

#property indicator_label3  "Line3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

#property indicator_label4  "Line4"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  3

input        int line_power  = 2;
input        int leverage    = 132;
input     double multiplier  = -2.0;
input        int line4_SHIFT = 0;
input        int interval    = 3;
input        int StartPoint  = 400;

double a1_Buffer[];
double a2_Buffer[];
double a3_Buffer[];
double a4_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,a1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,a2_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,a3_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,a4_Buffer,INDICATOR_DATA);
   
//----
  PlotIndexSetInteger(0,PLOT_SHIFT,119*interval);
  PlotIndexSetInteger(1,PLOT_SHIFT,-72*interval);
  PlotIndexSetInteger(2,PLOT_SHIFT,120*interval);
  PlotIndexSetInteger(3,PLOT_SHIFT,line4_SHIFT*interval);
//----

   ArraySetAsSeries(a4_Buffer,true);
   ArraySetAsSeries(a3_Buffer,true);
   ArraySetAsSeries(a2_Buffer,true);
   ArraySetAsSeries(a1_Buffer,true);

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
   int i,z,limit;
   ArraySetAsSeries(open,true);
   if(prev_calculated==0)// first calculation    
     {
      limit=rates_total-StartPoint*interval;
      if(limit<1)return(0);
      for(i=rates_total-1;i>=limit;i--)
        {
         a1_Buffer[i]=open[limit];
         a2_Buffer[i]=open[limit];
         a3_Buffer[i]=open[limit];
         a4_Buffer[i]=open[limit];
        }
     }
   else limit=rates_total-prev_calculated;
   for(i=limit;i>=0 && !IsStopped();i--)
     {
      a2_Buffer[i]=((open[i])+5061600*a2_Buffer[i+1*interval]-7489800*a2_Buffer[i+2*interval]+4926624*a2_Buffer[i+3*interval]-1215450*a2_Buffer[i+4*interval ])/1282975;


      if(line_power ==2)   {    a3_Buffer[i+192*interval]=a2_Buffer[i];   if(i>=0) { for(z=192-1;z>=0;z--){        a3_Buffer[i+0+z*interval]=  2.998096443*a3_Buffer[i+1*interval+z*interval]  -  2.9980964433*a3_Buffer[i+2*interval+z*interval]  +  1*a3_Buffer[i+3*interval+z*interval];  }}
                        
                                a1_Buffer[i+192*interval]=(a3_Buffer[i+193*interval]-1.998096443*a3_Buffer[i+192*interval]+a3_Buffer[i+191*interval])/0.001903557;   
                                                                          if(i>=0) { for(z=192-1;z>=0;z--){        a1_Buffer[i+0+z*interval]=(a3_Buffer[i+2*interval+z*interval]-1.998096443*a3_Buffer[i+1*interval+z*interval]+a3_Buffer[i+0*interval+z*interval])/0.001903557;}}
                           }

      if(line_power ==3)   {    a3_Buffer[i+192*interval]=a2_Buffer[i];   if(i>=0) { for(z=192-1;z>=0;z--){        a3_Buffer[i+0+z*interval]=  3.998096443*a3_Buffer[i+1*interval+z*interval]  -  5.996192886*a3_Buffer[i+2*interval+z*interval]   +  3.998096443*a3_Buffer[i+3*interval+z*interval]  - 1*a3_Buffer[i+4*interval+z*interval];  }}
                        
                                a1_Buffer[i+192*interval]=(a3_Buffer[i+193*interval]-1.998096443*a3_Buffer[i+192*interval]+a3_Buffer[i+191*interval])/0.001903557;   
                                                                          if(i>=0) { for(z=192-1;z>=0;z--){        a1_Buffer[i+0+z*interval]=(a3_Buffer[i+2*interval+z*interval]-1.998096443*a3_Buffer[i+1*interval+z*interval]+a3_Buffer[i+0*interval+z*interval])/0.001903557;}}
                           }


      if(line_power ==4)   {    a3_Buffer[i+192*interval]=a2_Buffer[i];   if(i>=0) { for(z=192-1;z>=0;z--){        a3_Buffer[i+0+z*interval]=  4.998096443*a3_Buffer[i+1*interval+z*interval]  - 9.994289329*a3_Buffer[i+2*interval+z*interval]  +  9.994289329*a3_Buffer[i+3*interval+z*interval] - 4.998096443*a3_Buffer[i+4*interval+z*interval]  +  1*a3_Buffer[i+5*interval+z*interval];  }}

                                a1_Buffer[i+192*interval]=(a3_Buffer[i+193*interval]-1.998096443*a3_Buffer[i+192*interval]+a3_Buffer[i+191*interval])/0.001903557;   
                                                                          if(i>=0) { for(z=192-1;z>=0;z--){        a1_Buffer[i+0+z*interval]=(a3_Buffer[i+2*interval+z*interval]-1.998096443*a3_Buffer[i+1*interval+z*interval]+a3_Buffer[i+0*interval+z*interval])/0.001903557;}}
                           }
      a4_Buffer[i]=(a3_Buffer[i+192*interval-leverage*interval]- a1_Buffer[i+192*interval-leverage*interval])* multiplier + a1_Buffer[i+192*interval-leverage*interval];
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
/*
1	-2,998096443	2,998096443	-1	0	0
1	-3,998096443	5,996192886	-3,998096443	1	0
1	-4,998096443	9,994289329	-9,994289329	4,998096443	-1

*/