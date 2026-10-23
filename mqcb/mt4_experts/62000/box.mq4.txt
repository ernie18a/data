//+------------------------------------------------------------------+
//|                                                          Box.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrGreen
#property indicator_width1 2
#property indicator_width2 2
#include <ExpertFunctions.mqh>

input int period = 20;
input int overlook =  10;

double ResBuffer[];
double SuppBuffer[];
bool Support; 
bool Resistance;

double Resistance(int starting)
{
      double High1 = High[ArrayMaximum(High,period,starting)];
      double High2 = High[ArrayMaximum(High, period + overlook,starting)];
      if (High1 == High2) return High1;
      else return 0;
}

double Support(int starting)
{
      double Low1 = Low[ArrayMinimum(Low,period, starting)];
      double Low2 = Low[ArrayMinimum(Low,period+overlook,starting)];
      if (Low1 == Low2) return Low1;
      else return 0;
}

int OnInit()
{
   ArraySetAsSeries(ResBuffer,false);
   ArraySetAsSeries(SuppBuffer,false); 
   ArrayInitialize(ResBuffer,0);
   ArrayInitialize(SuppBuffer,0);
   SetIndexBuffer(0,ResBuffer);
   SetIndexBuffer(1,SuppBuffer);
   string short_name="Box("+IntegerToString(period)+")";
   IndicatorShortName(short_name);
   SetIndexDrawBegin(0,0);
   SetIndexDrawBegin(1,0);
   return(INIT_SUCCEEDED);
}
  
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
   if(!IsNewCandle())
      return 0;
   static int i;
   static double Savedmin = 0.0, Savedmax = 0.0;
   static datetime last_calc = 0;
   if((rates_total <= period + overlook) || (period <= 0) || (overlook < 0))
      return(rates_total);
   ArraySetAsSeries(ResBuffer,false);
   ArraySetAsSeries(SuppBuffer,false); 

   for(i = 0; i < period+overlook;i++)
   {
       SuppBuffer[i] =EMPTY_VALUE;
       ResBuffer[i] =EMPTY_VALUE;
   }
   static int a = MathMax(period +overlook,prev_calculated-1);
   if(a != -1)
      PrintFormat("amikor bent vagyok az %d adik candlenél kezdek.",a);
   a = -1;
   int start = MathMax(prev_calculated - 1, period + overlook);
   //Print("Recalc from: " + time[start] + " to: " + time[rates_total-1]);
   for(i = start; i < rates_total; i++)
   { 
      
      if(time[rates_total-i] < last_calc)
         continue;
      bool BounceUp = (Support(rates_total-i)*2 + high[ArrayMaximum(high,rates_total-i,period)])/3 < close[rates_total-i];     //bounceup check
      bool BounceBack = (low[ArrayMinimum(low,rates_total-i,period)] + Resistance(rates_total-i)*2)/3 > close[rates_total-i]; //bounceback check
      if(time[rates_total-i] >= last_calc)
         last_calc = time[rates_total-i];
     // PrintFormat("BounceBack: %d bounceup :%d", BounceBack,BounceUp);
     // PrintFormat("Resistance: %lf, Support: %lf",Resistance(rates_total-i),Support(rates_total-i));
      if(Support(rates_total-i) != 0.0 && BounceUp && (!Support || (Support(rates_total-i) >Savedmin && Savedmin != 0.0)))
      {
         SuppBuffer[i] = Support(rates_total-i);
         Savedmin = Support(rates_total-i);
         Support = true;
      }
      else if(low[rates_total-i] > Savedmin && Support)
      {
         SuppBuffer[i] = Savedmin;
      }
      else
      {
         SuppBuffer[i] = EMPTY_VALUE;
         Support = false;
         Savedmin = 0;
      }
     
      if(Resistance(rates_total-i) != 0.0 && BounceBack && (!Resistance || (Resistance(rates_total-i) < Savedmax && Savedmax != 0.0)))
      {
         //PrintFormat("In resist: resistance: %d, Savedmax: %lf ",Resistance,Savedmax);
         ResBuffer[i] = Resistance(rates_total-i);
         Savedmax = Resistance(rates_total-i);
         Resistance = true;
      }
      else if(high[rates_total-i] < Savedmax && Resistance)
      {
         ResBuffer[i] = Savedmax;
      }
      else
      {
         ResBuffer[i] = EMPTY_VALUE;
         Resistance =false;
         Savedmax = 0;
      }
   }
   return(rates_total); 
}
