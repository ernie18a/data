//+------------------------------------------------------------------+
//|                                                 BodyPosition.mq5 |
//|                                                        J.S. 2013 |
//|                                     http://www.eselstreckdich.de |
//+------------------------------------------------------------------+
#property copyright "J.S. 2012"
#property link      "http://www.eselstreckdich.de"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   9
#property indicator_label1  "Moon"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGold
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label2  "Mercury"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlack
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label3  "Venus"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label4  "Mars"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
#property indicator_label5  "Jupiter"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkOrange
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
#property indicator_label6  "Saturn"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrTurquoise
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
#property indicator_label7  "Uranus"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrGreenYellow
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
#property indicator_label8  "Neptune"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1
#property indicator_label9  "Pluto"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrOliveDrab
#property indicator_style9  STYLE_SOLID
#property indicator_width9  1

#include <SWISSEPH.mqh>

input bool Geocentric=true;  // geocentric view

//--- indicator buffers
double Moon[];
double Mercury[];
double Venus[];
double Mars[];
double Jupiter[];
double Saturn[];
double Uranus[];
double Neptune[];
double Pluto[];
int flag=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0,Moon,INDICATOR_DATA);
   SetIndexBuffer(1,Mercury,INDICATOR_DATA);
   SetIndexBuffer(2,Venus,INDICATOR_DATA);
   SetIndexBuffer(3,Mars,INDICATOR_DATA);
   SetIndexBuffer(4,Jupiter,INDICATOR_DATA);
   SetIndexBuffer(5,Saturn,INDICATOR_DATA);
   SetIndexBuffer(6,Uranus,INDICATOR_DATA);
   SetIndexBuffer(7,Neptune,INDICATOR_DATA);
   SetIndexBuffer(8,Pluto,INDICATOR_DATA);
   
   flag=0;
   if(!Geocentric) flag=SEFLG_HELCTR;
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   swe_close();
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
                const int &spread[]) {
                
                
   double a[6];
   for( int i=prev_calculated; i<rates_total && !IsStopped(); i++) {
      
      calculate(time[i],SE_MOON,a,flag);     Moon[i]=a[0];
      calculate(time[i],SE_MERCURY,a,flag);  Mercury[i]=a[0];
      calculate(time[i],SE_VENUS,a,flag);    Venus[i]=a[0];
      calculate(time[i],SE_MARS,a,flag);     Mars[i]=a[0];
      calculate(time[i],SE_JUPITER,a,flag);  Jupiter[i]=a[0];
      calculate(time[i],SE_SATURN,a,flag);   Saturn[i]=a[0];
      calculate(time[i],SE_URANUS,a,flag);   Uranus[i]=a[0];
      calculate(time[i],SE_NEPTUNE,a,flag);  Neptune[i]=a[0];
      calculate(time[i],SE_PLUTO,a,flag);    Pluto[i]=a[0];
   }                
   return(rates_total);
}
