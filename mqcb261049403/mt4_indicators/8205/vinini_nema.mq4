//+------------------------------------------------------------------+
//|                                                  VininI_nEMA.mq4 |
//|               Sergey P. Murzinov && Victor I. Nicolaev aka Vinin |
//|                                             e-mail:vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright, 2007/ Sergey P. Murzinov && Victor I. Nicolaev"
#property link      "e-mail_to: vinin@mail.ru"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

//---- input parameters
extern int       EMA_period=89;     // Период EMA
extern int price_mode=0;            // Используемая цена 0 - PRICE_CLOSE, 
                                    //                   1 - PRICE_OPEN,
                                    //                   2 - PRICE_HIGH,
                                    //                   3 - PRICE_LOW,
                                    //                   4 - PRICE_MEDIAN,
                                    //                   5 - PRICE_TYPICAL,
                                    //                   6 - PRICE_WEIGHTED
extern int mode_ema=0;              // Глубина обработки ошибки, максимум 6

//---- buffers
double nEma[];
double Ema1[];
double Ema2[];
double Ema3[];
double Ema4[];
double Ema5[];
double Ema6[];
double Ema7[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,nEma);

   if (mode_ema<0) mode_ema=0;
   if (mode_ema>6) mode_ema=6;
   if (mode_ema>=0) SetIndexBuffer(1,Ema1);
   if (mode_ema>=1) SetIndexBuffer(2,Ema2);
   if (mode_ema>=2) SetIndexBuffer(3,Ema3);
   if (mode_ema>=3) SetIndexBuffer(4,Ema4);
   if (mode_ema>=4) SetIndexBuffer(5,Ema5);
   if (mode_ema>=5) SetIndexBuffer(6,Ema6);
   if (mode_ema>=6) SetIndexBuffer(7,Ema7);

   SetIndexDrawBegin(0,EMA_period*(mode_ema+1));
   IndicatorShortName(mode_ema+"-EMA("+EMA_period+")");
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int   i,
         limit1,
         limit2,
         limit3,
         limit4,
         limit5,
         limit6,
         limit7,
         counted_bars=IndicatorCounted();
//----
   if (counted_bars==0) {
      limit1=Bars-1;
      limit2=limit1-EMA_period;
      limit3=limit2-EMA_period;
      limit4=limit3-EMA_period;
      limit5=limit4-EMA_period;
      limit6=limit5-EMA_period;
      limit7=limit6-EMA_period;
      }
   if (counted_bars>0) {
      limit1=Bars-counted_bars-1;
      limit2=limit1;
      limit3=limit2;
      limit4=limit3;
      limit5=limit4;
      limit6=limit5;
      limit7=limit6;
      }
   if (mode_ema>=0)  for (i=limit1;i>=0;i--) Ema1[i]=iMA(Symbol(),Period(),EMA_period,0,MODE_EMA,price_mode,i);
   if (mode_ema>=1)  for (i=limit2;i>=0;i--) Ema2[i]=iMAOnArray(Ema1,  0,EMA_period,0,MODE_EMA,i);
   if (mode_ema>=2)  for (i=limit3;i>=0;i--) Ema3[i]=iMAOnArray(Ema2,  0,EMA_period,0,MODE_EMA,i);      
   if (mode_ema>=3)  for (i=limit4;i>=0;i--) Ema4[i]=iMAOnArray(Ema3,  0,EMA_period,0,MODE_EMA,i);      
   if (mode_ema>=4)  for (i=limit5;i>=0;i--) Ema5[i]=iMAOnArray(Ema4,  0,EMA_period,0,MODE_EMA,i);      
   if (mode_ema>=5)  for (i=limit6;i>=0;i--) Ema6[i]=iMAOnArray(Ema5,  0,EMA_period,0,MODE_EMA,i);         
   if (mode_ema>=6)  for (i=limit7;i>=0;i--) Ema7[i]=iMAOnArray(Ema6,  0,EMA_period,0,MODE_EMA,i);         

   if (mode_ema==0)  for (i=limit1;i>=0;i--) nEma[i] = 1.0*Ema1[i];
   if (mode_ema==1)  for (i=limit2;i>=0;i--) nEma[i] = 2.0*Ema1[i]- 1.0*Ema2[i];
   if (mode_ema==2)  for (i=limit3;i>=0;i--) nEma[i] = 3.0*Ema1[i]- 3.0*Ema2[i]+ 1.0*Ema3[i];
   if (mode_ema==3)  for (i=limit4;i>=0;i--) nEma[i] = 4.0*Ema1[i]- 6.0*Ema2[i]+ 4.0*Ema3[i]- 1.0*Ema4[i];
   if (mode_ema==4)  for (i=limit5;i>=0;i--) nEma[i] = 5.0*Ema1[i]-10.0*Ema2[i]+10.0*Ema3[i]- 5.0*Ema4[i]+ 1.0*Ema5[i];
   if (mode_ema==5)  for (i=limit6;i>=0;i--) nEma[i] = 6.0*Ema1[i]-15.0*Ema2[i]+20.0*Ema3[i]-15.0*Ema4[i]+ 6.0*Ema5[i]-1.0*Ema6[i];
   if (mode_ema==6)  for (i=limit7;i>=0;i--) nEma[i] = 7.0*Ema1[i]-21.0*Ema2[i]+35.0*Ema3[i]-35.0*Ema4[i]+21.0*Ema5[i]-7.0*Ema6[i]+1.0*Ema7[i];
   return(0);
  }
//+------------------------------------------------------------------+


