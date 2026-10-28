//+------------------------------------------------------------------+
//|                                               RSI_Strike(AM).mq4 |
//|                                               Andrey Matvievskiy |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Andrey Matvievskiy"
#property link      ""
//----
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Aqua
#property indicator_color2 Aqua
#property indicator_color3 Silver
#property indicator_color4 Silver
#property indicator_color5 Orange
#property indicator_color6 Orange
#property indicator_color7 Red
#property indicator_color8 Red

//----
double CrossUp1[];
double CrossDown1[];
double CrossUp2[];
double CrossDown2[];
double CrossUp3[];
double CrossDown3[];
double CrossUp4[];
double CrossDown4[];

extern int RSI_Period1=2;
extern int RSI_Period2=4;
extern int RSI_Price1=0;
extern int RSI_Price2=0;

extern int RSI_Period3=3;
extern int RSI_Period4=6;
extern int RSI_Price3=0;
extern int RSI_Price4=0;

extern int RSI_Period5=4;
extern int RSI_Period6=8;
extern int RSI_Price5=0;
extern int RSI_Price6=0;

extern int RSI_Period7=5;
extern int RSI_Period8=10;
extern int RSI_Price7=0;
extern int RSI_Price8=0;


extern int CountedBars=300;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_ARROW,0,0);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,CrossUp1);
   SetIndexStyle(1,DRAW_ARROW,0,0);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,CrossDown1);

   SetIndexStyle(2,DRAW_ARROW,0,0);
   SetIndexArrow(2,233);
   SetIndexBuffer(2,CrossUp2);
   SetIndexStyle(3,DRAW_ARROW,0,0);
   SetIndexArrow(3,234);
   SetIndexBuffer(3,CrossDown2);

   SetIndexStyle(4,DRAW_ARROW,0,0);
   SetIndexArrow(4,233);
   SetIndexBuffer(4,CrossUp3);
   SetIndexStyle(5,DRAW_ARROW,0,0);
   SetIndexArrow(5,234);
   SetIndexBuffer(5,CrossDown3);

   SetIndexStyle(6,DRAW_ARROW,0,0);
   SetIndexArrow(6,233);
   SetIndexBuffer(6,CrossUp4);
   SetIndexStyle(7,DRAW_ARROW,0,0);
   SetIndexArrow(7,234);
   SetIndexBuffer(7,CrossDown4);

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
   int limit,i,counter;
   double Range,AvgRange;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+CountedBars;

//----
   for(i=1; i<=limit; i++)
     {
      counter=i;
      Range=0;
      AvgRange=0;
      for(counter=i;counter<=i+9;counter++)
        {
         AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
        }
      Range=AvgRange/10;
      //----

      double A_1 = iRSI(NULL, 0, RSI_Period1, RSI_Price1, i);
      double A_2 = iRSI(NULL, 0, RSI_Period1, RSI_Price1, i+1);

      double B_1 = iRSI(NULL, 0, RSI_Period2, RSI_Price2, i);
      double B_2 = iRSI(NULL, 0, RSI_Period2, RSI_Price2, i+1);


      double C_1 = iRSI(NULL, 0, RSI_Period3, RSI_Price3, i);
      double C_2 = iRSI(NULL, 0, RSI_Period3, RSI_Price3, i+1);

      double D_1 = iRSI(NULL, 0, RSI_Period4, RSI_Price4, i);
      double D_2 = iRSI(NULL, 0, RSI_Period4, RSI_Price4, i+1);


      double E_1 = iRSI(NULL, 0, RSI_Period5, RSI_Price5, i);
      double E_2 = iRSI(NULL, 0, RSI_Period5, RSI_Price5, i+1);

      double F_1 = iRSI(NULL, 0, RSI_Period6, RSI_Price6, i);
      double F_2 = iRSI(NULL, 0, RSI_Period6, RSI_Price6, i+1);


      double G_1 = iRSI(NULL, 0, RSI_Period7, RSI_Price7, i);
      double G_2 = iRSI(NULL, 0, RSI_Period7, RSI_Price7, i+1);

      double K_1 = iRSI(NULL, 0, RSI_Period8, RSI_Price8, i);
      double K_2 = iRSI(NULL, 0, RSI_Period8, RSI_Price8, i+1);


      //----
      if((A_1>B_1) && (A_2<B_2))
        {
         CrossUp1[i]=Low[i]-Range*0.2;
        }
      else  if((A_1<B_1) && (A_2>B_2))
        {
         CrossDown1[i]=High[i]+Range*0.2;
        }

      if((C_1>D_1) && (C_2<D_2))
        {
         CrossUp2[i]=Low[i]-Range*0.4;
        }
      else  if((C_1<D_1) && (C_2>D_2))
        {
         CrossDown2[i]=High[i]+Range*0.4;
        }

      if((E_1>F_1) && (E_2<F_2))
        {
         CrossUp3[i]=Low[i]-Range*0.6;
        }
      else  if((E_1<F_1) && (E_2>F_2))
        {
         CrossDown3[i]=High[i]+Range*0.6;
        }


      if((G_1>K_1) && (G_2<K_2))
        {
         CrossUp4[i]=Low[i]-Range*0.8;
        }
      else  if((G_1<K_1) && (G_2>K_2))
        {
         CrossDown4[i]=High[i]+Range*0.8;
        }

     }
   return(0);
  }
//+------------------------------------------------------------------+
