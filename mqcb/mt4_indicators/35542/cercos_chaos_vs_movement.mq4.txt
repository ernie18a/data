//+------------------------------------------------------------------+
//|                                     Cercos_Chaos_vs_Movement.mq4 |
//|                    Copyright 2021, Manuel Alejandro Cercós Pérez |
//|                         https://www.mql5.com/en/users/alexcercos |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Manuel Alejandro Cercós Pérez"
#property link      "https://www.mql5.com/en/users/alexcercos"
#property version   "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   2

#property indicator_label1  "Move"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLime
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Chaos"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input int Inp_period = 6; //Period
input double Inp_chaosStrength = 2.0; // Chaos Strength
input double Inp_chaosWidth = 1.5; //Chaos Width
input double Inp_moveStrength = 1.0; //Movement Strength

double BufferMoveRes[];
double BufferChaosRes[];

double BufferMove[];
double BufferChaos[];
double BufferWicks[];

double highOC[];
double lowOC[];

double highestHigh[];
double lowestLow[];

int period;
double chaosStrength;
double chaosWidth;
double moveStrength;

int OnInit()
{
   period = Inp_period >=2 ? Inp_period : 2; 
   chaosStrength = Inp_chaosStrength > 0 ? Inp_chaosStrength : 1.0;
   chaosWidth = Inp_chaosWidth > 0 ? Inp_chaosWidth : 1.0;
   moveStrength = Inp_moveStrength > 0 ? Inp_moveStrength : 1.0;
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Cercós Chaos vs Movement (" + (string)period +")");

   SetIndexBuffer(0, BufferMoveRes, INDICATOR_DATA);
   SetIndexBuffer(1, BufferChaosRes, INDICATOR_DATA);
   SetIndexBuffer(2, BufferWicks, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, highestHigh, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, lowestLow, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, highOC, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, lowOC, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, BufferMove, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, BufferChaos, INDICATOR_CALCULATIONS);
   
   SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexStyle(8, DRAW_NONE);
   
   SetIndexLabel(2, NULL);
   SetIndexLabel(3, NULL);
   SetIndexLabel(4, NULL);
   SetIndexLabel(5, NULL);
   SetIndexLabel(6, NULL);
   SetIndexLabel(7, NULL);
   SetIndexLabel(8, NULL);
   
   ArraySetAsSeries(BufferMoveRes, true);
   ArraySetAsSeries(BufferChaosRes, true);
   ArraySetAsSeries(BufferWicks, true);
   ArraySetAsSeries(highestHigh, true);
   ArraySetAsSeries(lowestLow, true);
   ArraySetAsSeries(highOC, true);
   ArraySetAsSeries(lowOC, true);
   ArraySetAsSeries(BufferMove, true);
   ArraySetAsSeries(BufferChaos, true);
   
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
   int limit = MathMin(rates_total - prev_calculated, rates_total - 1);
   
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(open, true);
   
   for (int i=limit; i >= 0 && !IsStopped(); i--)
   {
      BufferWicks[i] = (high[i] - low[i]) - MathAbs(open[i] - close[i]);
      
      highOC[i] = MathMax(close[i], open[i]);
      lowOC[i] = MathMin(close[i], open[i]);
   }
   
   limit = MathMin(rates_total - prev_calculated, rates_total - period);
   
   if (limit>1)
   {
      ArrayInitialize(BufferMoveRes, EMPTY_VALUE);
      ArrayInitialize(BufferChaosRes, EMPTY_VALUE);
      ArrayInitialize(BufferMove, EMPTY_VALUE);
      ArrayInitialize(BufferChaos, EMPTY_VALUE);
      ArrayInitialize(highestHigh, EMPTY_VALUE);
      ArrayInitialize(lowestLow, EMPTY_VALUE);
   }
   
   
   
   for (int i=limit; i >= 0 && !IsStopped(); i--)
   {
      if (highestHigh[i+1] == EMPTY_VALUE)
      {
         highestHigh[i] = ArrayMaximum(highOC, period, i) - i;
         lowestLow[i] = ArrayMinimum(lowOC, period, i) - i;
      }
      else
      {
         if (highestHigh[i+1]+1 >= period)
         {
            highestHigh[i] = ArrayMaximum(highOC, period, i) - i;
         }
         else
         {
            highestHigh[i] = highOC[(int)highestHigh[i+1] + i + 1] > highOC[i] ? highestHigh[i+1]+1 : 0;
         }
         
         if (lowestLow[i+1]+1 >= period)
         {
            lowestLow[i] = ArrayMinimum(lowOC, period, i) - i;
         }
         else
         {
            lowestLow[i] = lowOC[(int)lowestLow[i+1] + i + 1] < lowOC[i] ? lowestLow[i+1]+1 : 0;
         }
      }
      
      if (BufferMove[i+1] == EMPTY_VALUE)
      {
         BufferMove[i] = 0.0;
         for (int j=i; j < i + period; j++)
         {
            BufferMove[i] += (highOC[j] - lowOC[j]);
         }
      }
      else
      {
         BufferMove[i] = BufferMove[i+1] + (highOC[i] - lowOC[i]) - (highOC[i+period] - lowOC[i+period]);
      }
      
      if (BufferChaos[i+1] == EMPTY_VALUE)
      {
         BufferChaos[i] = 0.0;
         for (int j=i; j < i + period; j++)
         {
            BufferChaos[i] += BufferWicks[j];
         }
      }
      else
      {
         BufferChaos[i] = BufferChaos[i+1] - BufferWicks[i+period] + BufferWicks[i];
      }
      
      double totalMove = highOC[(int)highestHigh[i] + i] - lowOC[(int)lowestLow[i] + i];
      
      if (totalMove == 0.0)
      {
         BufferMoveRes[i] = 0.0;
         BufferChaosRes[i] = 1.0;
      }
      else
      {
         if (BufferMove[i] != 0.0)
            BufferMoveRes[i] = MathPow(MathMin(totalMove / BufferMove[i], 1.0), 1.0 / moveStrength);
         else
            BufferMoveRes[i] = 1.0;
         
         BufferChaosRes[i] = MathPow(Sigmoid(BufferChaos[i] / (chaosWidth * totalMove)), chaosStrength);
      }
      
   }
   
   
   return(rates_total);
}

double Sigmoid(double num, bool zeroLimit=false)
{
   double expP = MathExp(num);
   double expN = MathExp(-num);
   
   if (expN == 0) return 1;
   
   double res = (expP - expN)/(expP + expN);
   
   if (zeroLimit)
      return (res+1.0)/2.0;
   else
      return res;
}