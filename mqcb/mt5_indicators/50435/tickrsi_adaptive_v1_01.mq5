//+------------------------------------------------------------------+
//|                             TickRSI_adaptive_TrendLaboratory.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                                                  |
//|                                    MT5 conversion by phade, 2024 |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, TrendLaboratory"
#property link      "http://finance.groups.yahoo.com/group/TrendLaboratory"
#property version   "1.01"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 3
#property indicator_color1 clrLime
#property indicator_type1   DRAW_LINE
#property indicator_width1  2

#property indicator_color2 clrDodgerBlue
#property indicator_type2   DRAW_LINE
#property indicator_width2  2

#property indicator_color3 clrTomato
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_DOT
#property indicator_width3  1

#property indicator_label1 "ARSI"
#property indicator_label2 "Fast"
#property indicator_label3 "Slow"


//---- buffers
input int     ARSIPeriod  =    14;  //Adaptive RSI Period
input int     FastMA      =     5; //Fast MA Length(Period)
input int     SlowMA      =    14; //Slow MA Length(Period)
input int     MA_Mode     =     0; //MA Mode: 0-SMA,1-EMA,2-Wilder(SMMA),3-LWMA
input int     UseDelimiter =     1;
input color   DelimColor  =  clrGray; //Color of Bars Delimiter
input int     MaxTicks    =   200; //Max Number of ticks
input int     NumTicks    =     0; //TimeFrame in ticks (=0 if NumSecs  > 0)
input string  RSI_ind     = "Examples\\RSI"; //Load RSI indicator
double Ticks[];
double Fast[];
double Slow[];
double ARSI[];

int      barCounter = 0;
int      tickCounter = 0;
int      delimeterCounter;
static datetime pTime;
string   short_name, setup;

long digits = 3;

int handle = INVALID_HANDLE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- indicators
   SetIndexBuffer(0, Ticks, INDICATOR_DATA);
   SetIndexBuffer(1, Fast, INDICATOR_DATA);
   SetIndexBuffer(2, Slow, INDICATOR_DATA);
   SetIndexBuffer(3, ARSI, INDICATOR_DATA);
   ArraySetAsSeries(Ticks, true);
   ArraySetAsSeries(Fast, true);
   ArraySetAsSeries(Slow, true);
   ArraySetAsSeries(ARSI, true);

   IndicatorSetInteger(INDICATOR_DIGITS, SymbolInfoInteger(Symbol(), SYMBOL_DIGITS, digits));

   short_name = "TickAdaptiveRSI_v1("
                + IntegerToString(ARSIPeriod)
                + "," + IntegerToString(FastMA)
                + "," + IntegerToString(SlowMA)
                + "," + IntegerToString(MA_Mode)
                + "," + IntegerToString(UseDelimiter) + ")";

   handle = iCustom(NULL, PERIOD_CURRENT, RSI_ind);

   IndicatorSetString(INDICATOR_SHORTNAME, short_name);

   setup = short_name + ": ";
   pTime = iTime(_Symbol, _Period, 0);

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

   tickCounter++;

   if(tickCounter == 0)
     {
      for(int i = MaxTicks; i >= 0; i--)
        {
         Ticks[i] = 0.0;
         Fast[i] = 0.0;
         Slow[i] = 0.0;
        }
     }

   if(Ticks[tickCounter] == 0)
     {
      Fast[tickCounter] = EMPTY_VALUE;
      Slow[tickCounter] = EMPTY_VALUE;
      ARSI[tickCounter] = EMPTY_VALUE;
     }


   if(tickCounter >= MaxTicks)
     {
      tickCounter = MaxTicks;
      Ticks[tickCounter] = 0.0;
      Fast[tickCounter] = 0.0;
      Slow[tickCounter] = 0.0;
     }

   int calculated = BarsCalculated(handle);

   if(calculated < rates_total)
     {

      Print("Not all data of handle is calculated (", calculated, " bars). Error ", GetLastError());
      return 0;
     }

   int to_copy = (prev_calculated > rates_total || prev_calculated < 0) ? rates_total : rates_total - prev_calculated;

   if(prev_calculated > 0)
      to_copy++;



   int copied = CopyBuffer(handle, 0, 0, to_copy, ARSI);
   // int copied = CopyBuffer(handle, 0, 0, 2, ARSI);

   if(copied <= 0)
     {
      Print("Failed to copy values!");
      return(0);
     }

   if(ARSI[1] < 2 * ARSI[0]) Ticks[0] = (ARSI[0] - ARSI[1]) * 10000;

   //Print("0=",ARSI[0]," 1=",ARSI[1]," t=",Ticks[0]);

   if(MA_Mode == 0)
     {
      if(tickCounter >= FastMA + ARSIPeriod)
         Fast[0] = TickSMA(Ticks,FastMA);
      if(tickCounter >= SlowMA + ARSIPeriod)
         Slow[0] = TickSMA(Ticks,SlowMA);
     }
   else
      if(MA_Mode == 1)
        {
         if(tickCounter == FastMA)
            Fast[0] = TickSMA(Ticks,FastMA);
         else
            if(tickCounter > FastMA)
               Fast[0] = TickEMA(Ticks,Fast,FastMA);
         if(tickCounter == SlowMA)
            Slow[0] = TickSMA(Ticks,SlowMA);
         else
            if(tickCounter > SlowMA)
               Slow[0] = TickEMA(Ticks,Slow,SlowMA);
        }
      else
         if(MA_Mode == 2)
           {
            if(tickCounter == 2 * FastMA - 1)
               Fast[0] = TickSMA(Ticks,2 * FastMA - 1);
            else
               if(tickCounter > 2 * FastMA - 1)
                  Fast[0] = TickEMA(Ticks,Fast,2 * FastMA - 1);
            if(tickCounter == 2 * SlowMA - 1)
               Slow[0] = TickSMA(Ticks,2 * SlowMA - 1);
            else
               if(tickCounter > 2 * SlowMA - 1)
                  Slow[0] = TickEMA(Ticks,Slow,2 * SlowMA - 1);
           }
   if(MA_Mode == 3)
     {
      if(tickCounter >= FastMA + ARSIPeriod)
         Fast[0] = TickLWMA(Ticks,FastMA);
      if(tickCounter >= SlowMA + ARSIPeriod)
         Slow[0] = TickLWMA(Ticks,SlowMA);
     }

   return(rates_total);
  }


//+------------------------------------------------------------------+
double TickSMA(double &array[], int per)
  {
   double Sum = 0;
   for(int i = 0; i < per; i++)
      Sum += array[i];
   return(Sum / per);
  }
//+------------------------------------------------------------------+
double TickEMA(double &array1[], double &array2[], int per)
  {
   return(array2[1] + 2.0 / (1 + per) * (array1[0] - array2[1]));
  }
//+------------------------------------------------------------------+
double TickLWMA(double &array[], int per)
  {
   double Sum = 0;
   double Weight = 0;

   for(int i = 0; i < per; i++)
     {
      Weight += (per - i);
      Sum += array[i] * (per - i);
     }

   if(Weight > 0)
      return(Sum / Weight);
   else
      return(0);
  }
//+------------------------------------------------------------------+
