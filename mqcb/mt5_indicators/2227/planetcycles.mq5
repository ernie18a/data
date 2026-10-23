//+------------------------------------------------------------------+
//|                                                 PlanetCycles.mq5 |
//|                                                        J.S. 2012 |
//|                                     http://www.eselstreckdich.de |
//+------------------------------------------------------------------+
#property copyright "J.S. 2012"
#property link      "http://www.eselstreckdich.de"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "PlanetCycle"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#include <SWISSEPH.mqh>

input bool Geocentric=true;  // geocentric view
input BODY fastPlanet=Moon;  // planet fast
input BODY slowPlanet=Sun;  // planet slow

//--- indicator buffers
double CycleBuffer[];
int flag=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(0,CycleBuffer,INDICATOR_DATA);
   
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

   double a[6], b[6];

   for( int i=prev_calculated; i<rates_total && !IsStopped(); i++) {
   
      calculate(time[i],fastPlanet,a,flag);
      calculate(time[i],slowPlanet,b,flag);
      
      if(Geocentric &&
         (slowPlanet==SE_SUN || slowPlanet==SE_MERCURY || slowPlanet==SE_VENUS) &&
         (fastPlanet==SE_SUN || fastPlanet==SE_MERCURY || fastPlanet==SE_VENUS)) {

         // z.B. Merkur bzw. Venus vor oder hinter der Sonne, Buch Seite 4
         CycleBuffer[i]=a[0]-b[0];
         while(CycleBuffer[i]>180) CycleBuffer[i]-=180;
         while(CycleBuffer[i]<-180) CycleBuffer[i]+=180;
         if(i>0 && CycleBuffer[i]-CycleBuffer[i-1]<-100) CycleBuffer[i]+=180;
         if(i>0 && CycleBuffer[i]-CycleBuffer[i-1]>100) CycleBuffer[i]-=180;
         
      } else {
      
         // Aspekte 0..180°, Buch Seite 15
         CycleBuffer[i]=a[0]-b[0];
         if(CycleBuffer[i]>360) CycleBuffer[i]-=360;
         if(CycleBuffer[i]<-360) CycleBuffer[i]+=360;
         if(CycleBuffer[i]>180) CycleBuffer[i]=360-CycleBuffer[i];
         if(CycleBuffer[i]<-180) CycleBuffer[i]=360+CycleBuffer[i];
         CycleBuffer[i]=MathAbs(CycleBuffer[i]);
      }
   }
   return(rates_total);
}
