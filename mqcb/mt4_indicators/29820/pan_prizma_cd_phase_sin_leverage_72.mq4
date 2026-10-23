//+------------------------------------------------------------------+
//|                                Copyright 2020, Aleksey Panfilov. |
//|                                                filpan1@yandex.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Aleksei Panfilov. filpan1@yandex.ru"
#property link      "https://www.mql5.com/ru/market/product/18363"
#property version   "1.3"
#property strict

#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   9

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

#property indicator_label8  "Line8"
#property indicator_type8   DRAW_HISTOGRAM
#property indicator_color8  clrSilver
#property indicator_style8  STYLE_SOLID
#property indicator_width8  1

#property indicator_label5  "Line5"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGreen
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

#property indicator_label6  "Line6"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  2

#property indicator_label7  "Line7"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDarkGreen
#property indicator_style7  STYLE_DOT
#property indicator_width7  1

#property indicator_label9  "Line9_Amplitude"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrOrange
#property indicator_style9  STYLE_SOLID
#property indicator_width9  3

input        int line_power  = 2;
input        int leverage    = 1;
input     double multiplier  = -2.0;
input        int line4_SHIFT = 0;
input        int interval    = 1;
input        int StartPoint  = 400;
input        int XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=1;
input        int Multiplikator_HISTOGRAM = 1000000;
input        int Multiplikator_PRICE = 1;
input     double Multiplikator_Amplitude = 1.0;
input        int Discount_PRICE       =0;
input        int InpSignalSMA=9; 

double a1_Buffer[];
double a2_Buffer[];
double a3_Buffer[];
double a4_Buffer[];
double a5_Buffer[];
double a6_Buffer[];
double a7_Buffer[];
double a8_Buffer[];
double a9_Buffer[];

double P,O,M,C,H_kv,H,A,K,S_ZN,S,AK,AS,AK_S,AS_S;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,a1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,a2_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,a3_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,a4_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,a5_Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,a6_Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,a7_Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,a8_Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,a9_Buffer,INDICATOR_DATA);
//----
  SetIndexShift(0,119*interval);
  SetIndexShift(1,-72*interval);
  SetIndexShift(2,120*interval);
  SetIndexShift(3,line4_SHIFT*interval);
  SetIndexShift(4,0);
  SetIndexShift(5,0);
  SetIndexShift(6,0);
  SetIndexShift(7,0);
  SetIndexShift(8,0);
   
//----
/*
  PlotIndexSetInteger(0,PLOT_SHIFT,119*interval);
  PlotIndexSetInteger(1,PLOT_SHIFT,-72*interval);
  PlotIndexSetInteger(2,PLOT_SHIFT,120*interval);
  PlotIndexSetInteger(3,PLOT_SHIFT,line4_SHIFT*interval);
  PlotIndexSetInteger(4,PLOT_SHIFT,0);
  PlotIndexSetInteger(5,PLOT_SHIFT,0);
  PlotIndexSetInteger(6,PLOT_SHIFT,0);
  PlotIndexSetInteger(7,PLOT_SHIFT,0);
  PlotIndexSetInteger(8,PLOT_SHIFT,0);
*/
//----

   ArraySetAsSeries(a1_Buffer,true);
   ArraySetAsSeries(a2_Buffer,true);
   ArraySetAsSeries(a3_Buffer,true);
   ArraySetAsSeries(a4_Buffer,true);
   ArraySetAsSeries(a5_Buffer,true);
   ArraySetAsSeries(a6_Buffer,true);
   ArraySetAsSeries(a7_Buffer,true);
   ArraySetAsSeries(a8_Buffer,true);
   ArraySetAsSeries(a9_Buffer,true);

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
   ArraySetAsSeries(time,true);
   if(prev_calculated==0)// first calculation    
     {
      limit=rates_total-StartPoint*interval;
      if(limit<1)return(0);
      for(i=rates_total-1;i>=limit;i--)
        {
         a1_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a2_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a3_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a4_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a5_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a6_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a7_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a8_Buffer[i]=open[limit]*Multiplikator_PRICE;
         a9_Buffer[i]=open[limit]*Multiplikator_PRICE;
        }
     }
   else limit=rates_total-prev_calculated;
   for(i=limit;i>=0 && !IsStopped();i--)
     {
      a2_Buffer[i]=((open[i]*Multiplikator_PRICE-Discount_PRICE)+5061600*a2_Buffer[i+1*interval]-7489800*a2_Buffer[i+2*interval]+4926624*a2_Buffer[i+3*interval]-1215450*a2_Buffer[i+4*interval ])/1282975;

//                                                                  СБЕРЕЖЕНИЕ РЕСУРСА ИЛИ if(i>=0)-Альтернатива рассчет на весь график
      if(line_power ==2)   {    a3_Buffer[i+192*interval]=a2_Buffer[i];   if(i<=5000*interval) { for(z=192-1;z>=0;z--){        a3_Buffer[i+0+z*interval]=  2.998096443*a3_Buffer[i+1*interval+z*interval]  -  2.9980964433*a3_Buffer[i+2*interval+z*interval]  +  1*a3_Buffer[i+3*interval+z*interval];  }}
                        
                                a1_Buffer[i+192*interval]=(a3_Buffer[i+193*interval]-1.998096443*a3_Buffer[i+192*interval]+a3_Buffer[i+191*interval])/0.001903557;   
                                                                          if(i<=5000*interval) { for(z=192-1;z>=0;z--){        a1_Buffer[i+0+z*interval]=(a3_Buffer[i+2*interval+z*interval]-1.998096443*a3_Buffer[i+1*interval+z*interval]+a3_Buffer[i+0*interval+z*interval])/0.001903557;}}
                           }

      if(line_power ==3)   {    a3_Buffer[i+192*interval]=a2_Buffer[i];   if(i<=5000*interval) { for(z=192-1;z>=0;z--){        a3_Buffer[i+0+z*interval]=  3.998096443*a3_Buffer[i+1*interval+z*interval]  -  5.996192886*a3_Buffer[i+2*interval+z*interval]   +  3.998096443*a3_Buffer[i+3*interval+z*interval]  - 1*a3_Buffer[i+4*interval+z*interval];  }}
                        
                                a1_Buffer[i+192*interval]=(a3_Buffer[i+193*interval]-1.998096443*a3_Buffer[i+192*interval]+a3_Buffer[i+191*interval])/0.001903557;   
                                                                          if(i<=5000*interval) { for(z=192-1;z>=0;z--){        a1_Buffer[i+0+z*interval]=(a3_Buffer[i+2*interval+z*interval]-1.998096443*a3_Buffer[i+1*interval+z*interval]+a3_Buffer[i+0*interval+z*interval])/0.001903557;}}
                           }


      if(line_power ==4)   {    a3_Buffer[i+192*interval]=a2_Buffer[i];   if(i<=5000*interval) { for(z=192-1;z>=0;z--){        a3_Buffer[i+0+z*interval]=  4.998096443*a3_Buffer[i+1*interval+z*interval]  - 9.994289329*a3_Buffer[i+2*interval+z*interval]  +  9.994289329*a3_Buffer[i+3*interval+z*interval] - 4.998096443*a3_Buffer[i+4*interval+z*interval]  +  1*a3_Buffer[i+5*interval+z*interval];  }}

                                a1_Buffer[i+192*interval]=(a3_Buffer[i+193*interval]-1.998096443*a3_Buffer[i+192*interval]+a3_Buffer[i+191*interval])/0.001903557;   
                                                                          if(i<=5000*interval) { for(z=192-1;z>=0;z--){        a1_Buffer[i+0+z*interval]=(a3_Buffer[i+2*interval+z*interval]-1.998096443*a3_Buffer[i+1*interval+z*interval]+a3_Buffer[i+0*interval+z*interval])/0.001903557;}}
                           }
//====================================================================================================================================================        
      a4_Buffer[i]=(a3_Buffer[i+192*interval-leverage*interval]- a1_Buffer[i+192*interval-leverage*interval])* multiplier + a1_Buffer[i+192*interval-leverage*interval];   //Не перерисовываемая линия расчитанная от значений синусойды 

                                         M=  a3_Buffer[i+192*interval-leverage*interval];
                                         O=  a3_Buffer[i+191*interval-leverage*interval];
                                         P=  a3_Buffer[i+190*interval-leverage*interval];
      
                                         C=  a1_Buffer[i+191*interval-leverage*interval];  // Координата центра при заданном периоде.
   
                                      H_kv=  ((O - C)*(O - C) - (M - C)*(P - C));    // Квадрат половины хорды (Абсолютное значение)    https://dxdy.ru/post1085243.html#p1085243
                                         H=  MathPow(H_kv,0.5);                      // Полоина хорды (Абсолютное значение)
                                         A=(H/0.043318753)/_Point ;                  //Амплитуда в пунктах, через хорду и синус угла одного шага из периода 145. Угол одного шага 360/145. 

            if(H_kv > 0 && (P-M)!=0)      K= (P-M)/(MathPow(H_kv,0.5)*2);               // Коcинус фазы
               if(MathAbs(O-C) > 0)   S_ZN=  (O-C)/MathAbs(O-C);                       // Знак синуса (+-1)
                                         S=  MathPow(1 - MathPow(K,2),0.5)*S_ZN;       // Cинус фазы
                                        AK= MathArccos(K)/3.14159265358979*180;        
                                        AS= MathArcsin(K)/3.14159265358979*180;        //Арксинус Угол фазы из синуса в градусах
                                        
                                        AK_S= MathArccos(S)/3.14159265358979*180;
                                        AS_S= MathArcsin(S)/3.14159265358979*180;
               
// Распределение по четвертям тригонометрической плоскости.

      if( K>0 && S<0)      a5_Buffer[i]= AS;   
      if( K>0 && S>0)      a5_Buffer[i]= AS*(-1)+180;   
      if( K<0 && S>0)      a5_Buffer[i]= AS*(-1)+180;   
      if( K<0 && S<0)      a5_Buffer[i]= AS+360;
      
      if( K>0 && S<0)      a6_Buffer[i]= AS+180      -360;   
      if( K>0 && S>0)      a6_Buffer[i]= AS*(-1)+360 -360;   
      if( K<0 && S>0)      a6_Buffer[i]= AS*(-1)     -360;   
      if( K<0 && S<0)      a6_Buffer[i]= AS+180      -360;

                           a7_Buffer[i]= AS*2;                                           // Чистый Арксинус умноженный на 2, чтобы исключить совпадение с линией фазы

                           a8_Buffer[i] = (P - M)*Multiplikator_HISTOGRAM;               // Значение гистограммы
                           a9_Buffer[i] = A*Multiplikator_Amplitude;                     // Амплитуда в пунках
                                                                                             
/*
//====================================================================================================================================================================== 
     SimpleMAOnBuffer(rates_total,prev_calculated,0,InpSignalSMA,a8_Buffer,a9_Buffer);  // Классическая сигнальная линия гистограммы
*/  
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
/*
1	-2,998096443	2,998096443	-1	0	0
1	-3,998096443	5,996192886	-3,998096443	1	0
1	-4,998096443	9,994289329	-9,994289329	4,998096443	-1

*/