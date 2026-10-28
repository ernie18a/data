//+-------------------------------------------------------------+
//|                                            RSI on price.mq4 |
//|                                                             |
//| Level_Adjust=4 corresponds to levels 70,30 on RSI indicator |
//| A lower value will expand the bands for expanded RSI levels |           
//+-------------------------------------------------------------+
#property copyright "Copyright © 2021, Max Michael"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 LimeGreen
#property indicator_color2 Red
#property indicator_color3 LimeGreen
#property indicator_color4 Red
#property indicator_color5 DimGray
#property strict

// inputs
extern int           Length = 8;
extern double  Level_Adjust = 4;
extern int          MaxBars = 1000;

// buffers
double emaUp[];
double emaDn[];
double Eup[];
double Edn[];
double Mid[];

int init()
{
   IndicatorShortName("RSI("+IntegerToString(Length) +") ");
   SetIndexBuffer(0,emaUp); SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,emaDn); SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(2,Eup); SetIndexStyle(2,DRAW_LINE); SetIndexLabel(2,"RSI level Up");
   SetIndexBuffer(3,Edn); SetIndexStyle(3,DRAW_LINE); SetIndexLabel(3,"RSI level Down");
   SetIndexBuffer(4,Mid); SetIndexStyle(4,DRAW_LINE); SetIndexLabel(4,"RSI 50 level");
   MaxBars=MathMin(Bars,MaxBars);
   Level_Adjust=(Level_Adjust<1) ? 1 : Level_Adjust;
   return(0);
}

int deinit() { return(0); }

int start()
{
   int CountedBars=IndicatorCounted();
   if (CountedBars<0) return(-1);
   int limit = Bars-CountedBars-1;
   if (limit > MaxBars) limit=MaxBars;
   double wilders = Length*2-1;
   double   alpha = 2.0/(1+wilders);
   double   alph2 = (1+wilders)/Level_Adjust*1.04;
   
   for (int i=limit; i>=0; i--)
   {
      if (i==MaxBars) { emaUp[i]=0.0001; emaDn[i]=0.0001; } //initialize emas
      else 
      {
         double Su=(Close[i]-Close[i+1]>0) ? Close[i]-Close[i+1] : 0;
         double Sd=(Close[i]-Close[i+1]<0) ? Close[i+1]-Close[i] : 0;
         emaUp[i]= (Su - emaUp[i+1]) * alpha + emaUp[i+1];
         emaDn[i]= (Sd - emaDn[i+1]) * alpha + emaDn[i+1];
         Eup[i]  =  emaUp[i] *alph2 + iMA(NULL,0,wilders,0,MODE_EMA,PRICE_CLOSE,i);
         Edn[i]  =-(emaDn[i])*alph2 + iMA(NULL,0,wilders,0,MODE_EMA,PRICE_CLOSE,i);
         Mid[i]  = (Eup[i]+Edn[i])/2;
      }
   }
   return(0);
}
