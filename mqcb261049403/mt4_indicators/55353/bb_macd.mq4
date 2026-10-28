//+------------------------------------------------------------------+
//|                                                      BB_MACD.mq4 |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property copyright "www.Wolfforex.com, 2025"
#property version   "1.02"
#property strict

#property description "An advanced version of MACD indicator for trend change detection."

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4
#property indicator_color1 clrLime    // bbMACD up
#property indicator_color2 clrMagenta // bbMACD down
#property indicator_color3 clrBlue    // Upper band
#property indicator_color4 clrRed     // Lower band
#property indicator_width1 0
#property indicator_width2 0
#property indicator_width3 1
#property indicator_width4 1
#property indicator_type1 DRAW_ARROW
#property indicator_type2 DRAW_ARROW
#property indicator_type3 DRAW_LINE
#property indicator_type4 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
#property indicator_style4 STYLE_SOLID
#property indicator_label1 "bbMACD up"
#property indicator_label2 "bbMACD down"
#property indicator_label3 "Upper band"
#property indicator_label4 "Lower band"

// Indicator parameters:
input int FastLen = 12;
input int SlowLen = 26;
input int Length = 10;
input int barsCount = 400;
input double StDv = 2.5;
input bool EnableNativeAlerts = false;
input bool EnableSoundAlerts = false;
input bool EnableEmailAlerts = false;
input bool EnablePushAlerts = false;
input string SoundFileName	= "alert.wav";

// Indicator buffers:
double ExtMapBuffer1[];  // bbMACD up
double ExtMapBuffer2[];  // bbMACD down
double ExtMapBuffer3[];  // Upper band
double ExtMapBuffer4[];  // Lower band


// Global variables:
double bbMACD[]; // Used as a calculation buffer.
int LastBars = 0; // To resize bbMACD.
datetime LastAlertTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // Plots:
   SetIndexBuffer(0, ExtMapBuffer1, INDICATOR_DATA); // bbMacd up
   SetIndexArrow(0, 108);
   SetIndexBuffer(1, ExtMapBuffer2, INDICATOR_DATA); // bbMacd down
   SetIndexArrow(1, 108);
   SetIndexBuffer(2, ExtMapBuffer3, INDICATOR_DATA); // Upper band
   SetIndexBuffer(3, ExtMapBuffer4, INDICATOR_DATA); // Lowerband line

   IndicatorShortName("BB MACD(" + IntegerToString(FastLen) + "," + IntegerToString(SlowLen) + "," + IntegerToString(Length) + ")");
   IndicatorDigits(Digits + 1);

   // For barsCount > 0, DrawBegin is calculated in start().
   if (barsCount == 0) SetIndexDrawBegin(0, Length); // One is enought.

   ArraySetAsSeries(bbMACD, true);

   return(0);
}

//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Custom BB_MACD                                                   |
//+------------------------------------------------------------------+
int start()
{
   int limit;

   if (Bars < Length)
   {
      Print("Not enough bars!");
      return(-1);
   }
   
   int counted_bars = IndicatorCounted();
   if (counted_bars < 0) return(-1);
   if (counted_bars > 0) counted_bars--;

   if (barsCount > 0) limit = MathMin(barsCount, Bars - counted_bars);
   else limit = Bars - counted_bars;

   // Adjust starting point in time for indicator output.
   if (barsCount > 0)
   {
      int draw_begin = Bars - barsCount + Length;
      if (draw_begin < Length) draw_begin = Length;
      SetIndexDrawBegin(0, draw_begin); // One is enough.
   }

   if (LastBars == 0)
   {
      ArrayResize(bbMACD, limit);
      ArrayInitialize(bbMACD, 0);
   }
   else if (Bars - LastBars > 0)
   {
      int oldsize = ArraySize(bbMACD);
      int newsize = ArrayResize(bbMACD, oldsize + Bars - LastBars);
      int difference = newsize - oldsize;
      // Shift values.
      for (int i = newsize - 1; i >= difference; i--)
         bbMACD[i] = bbMACD[i - difference];
   }
   LastBars = Bars;
   
   for (int i = 0; i < limit; i++)
      bbMACD[i] = iMA(NULL, 0, FastLen, 0, MODE_EMA, PRICE_CLOSE, i) -
                  iMA(NULL, 0, SlowLen, 0, MODE_EMA, PRICE_CLOSE, i);

   // EMA and StdDev on Array will be calculated using Length as a period on the previously calculated EMA data. Avoiding 'array out of range' errors.
   if (barsCount > 0)
      if (limit > barsCount - Length) limit = barsCount - Length;
   if (limit > Bars - Length) limit = Bars - Length;

   for (int i = 0; i < limit; i++)
   {
      double avg = iMAOnArray(bbMACD, 0, Length, 0, MODE_EMA, i);
      double sDev = iStdDevOnArray(bbMACD, 0, Length, MODE_EMA, 0, i);
      
      if (bbMACD[i] >= bbMACD[i + 1])
      {
         ExtMapBuffer1[i] = bbMACD[i];
         ExtMapBuffer2[i] = EMPTY_VALUE;
      }
      else if (bbMACD[i] < bbMACD[i + 1])
      {
         ExtMapBuffer1[i] = EMPTY_VALUE;
         ExtMapBuffer2[i] = bbMACD[i];
      }
      
      if ((i == 2) && (LastAlertTime != Time[1]))
      {
         if ((ExtMapBuffer1[i] == EMPTY_VALUE) && (ExtMapBuffer1[i - 1] == bbMACD[i - 1]))
         {
      		string Text = Symbol() + " - " + EnumToString((ENUM_TIMEFRAMES)Period()) + " - BB_MACD: from DOWN to UP @ " + TimeToString(Time[1]) + ".";
      		if (EnableNativeAlerts) Alert(Text);
      		if (EnableEmailAlerts) SendMail(Text, Text);
      		if (EnableSoundAlerts) PlaySound(SoundFileName);
      		if (EnablePushAlerts) SendNotification(Text);
      		LastAlertTime = Time[1];
         }
         else if ((ExtMapBuffer2[i] == EMPTY_VALUE) && (ExtMapBuffer2[i - 1] == bbMACD[i - 1]))
         {
      		string Text = Symbol() + " - " + EnumToString((ENUM_TIMEFRAMES)Period()) + " - BB_MACD: from UP to DOWN @ " + TimeToString(Time[1]) + ".";
      		if (EnableNativeAlerts) Alert(Text);
      		if (EnableEmailAlerts) SendMail(Text, Text);
      		if (EnableSoundAlerts) PlaySound(SoundFileName);
      		if (EnablePushAlerts) SendNotification(Text);
      		LastAlertTime = Time[1];
         }
      }
      
      ExtMapBuffer3[i] = avg + (StDv * sDev);
      ExtMapBuffer4[i] = avg - (StDv * sDev);
   }

   return(0);
}
//+------------------------------------------------------------------+ 