//+--------------------------------------------------------------------+
//|                                             RSI stop & reverse.mq4 |
//+--------------------------------------------------------------------+
#property copyright "Copyright © 2021, Max Michael"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 DodgerBlue
#property strict

// inputs
extern int           Length = 8;
extern int         Level_Up = 70;    
extern int         Level_Dn = 30;
extern bool    ShowRSIbands = true;
extern int          MaxBars = 1000;

// globals
double LevUp, LevDn;

// buffers
double emaUp[];
double emaDn[];
double Eup[];
double Edn[];
double Stop[];

int init()
{
   IndicatorShortName("RSI("+IntegerToString(Length) +") ");
   SetIndexBuffer(0,emaUp); SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(1,emaDn); SetIndexStyle(1,DRAW_NONE);
   if(ShowRSIbands)
   {
     SetIndexBuffer(2,Eup); SetIndexStyle(2,DRAW_LINE); 
     SetIndexBuffer(3,Edn); SetIndexStyle(3,DRAW_LINE); 
   }
   else
   {
     SetIndexBuffer(2,Eup); SetIndexStyle(2,DRAW_NONE); 
     SetIndexBuffer(3,Edn); SetIndexStyle(3,DRAW_NONE); 
   }
   SetIndexBuffer(4,Stop); SetIndexStyle(4,DRAW_LINE); 
   SetIndexLabel(4,"RSI stop level");
   MaxBars=MathMin(Bars,MaxBars);
   Length = (Length<2) ? 2 : Length;
   Level_Up= (Level_Up<51) ? 51 : Level_Up; Level_Up= (Level_Up>100) ? 100 : Level_Up;   
   Level_Dn= (Level_Dn>49) ? 49 : Level_Dn; Level_Dn= (Level_Dn<0) ? 0 : Level_Dn;
   // Convert level values to percent
   LevUp=(Level_Up-50)/20.0;
   LevDn=(50-Level_Dn)/20.0;
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
   // Differential equation of length, level, delta.
   double delta_up = (wilders/((1+1/wilders)*5))*LevUp;
   double delta_dn = (wilders/((1+1/wilders)*5))*LevDn;
   
   for (int i=limit; i>=0; i--)
   {
      if (i==MaxBars) { emaUp[i]=0.0001; emaDn[i]=0.0001; } //initialize emas
      else 
      {
         double Su=(Close[i]-Close[i+1]>0) ? Close[i]-Close[i+1] : 0;
         double Sd=(Close[i]-Close[i+1]<0) ? Close[i+1]-Close[i] : 0;
         emaUp[i]= (Su - emaUp[i+1]) * alpha + emaUp[i+1];
         emaDn[i]= (Sd - emaDn[i+1]) * alpha + emaDn[i+1];
         double ccrange = emaUp[i]+emaDn[i];
         Eup[i]  = ccrange *delta_up + iMA(NULL,0,wilders,0,MODE_EMA,PRICE_CLOSE,i);
         Edn[i]  =-ccrange *delta_dn + iMA(NULL,0,wilders,0,MODE_EMA,PRICE_CLOSE,i);
         
         double prev = Stop[i+1];
         if ( Close[i] > prev && Close[i+1] > prev) { Stop[i] = MathMax(prev, Edn[i]); } //uptrend
         else if ( Close[i] < prev && Close[i+1] < prev) { Stop[i] = MathMin(prev, Eup[i]); } //dntrend
         else if ( Close[i] > prev) { Stop[i] = Edn[i]; } //change of trend up else down
         else { Stop[i] = Eup[i]; }      
      }
   }
   return(0);
}
