//+------------------------------------------------------------------+
//|                                          Basing Candlesticks.mq4 |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property copyright "www.Wolfforex.com, 2025"
#property version   "1.00"
#property strict

#property description "Marks candlesticks with body < 50% of overall length (high-low range)."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_type1 DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrBlue
#property indicator_width1 1
#property indicator_type2 DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_color2 clrBlue
#property indicator_width2 1

input int Percentage = 50; // Percentage for Basing Candle calculation.
input int TriggerCandle = 1; // TriggerCandle: Number of candle to check for alerts.
input bool EnableNativeAlerts = false; // EnableNativeAlerts: Alert popup inside platform.
input bool EnableSoundAlerts = false; // EnableSoundAlerts: Play a sound on alert.
input bool EnableEmailAlerts = false; // EnableEmailAlerts: Send an email on alert.
input bool EnablePushAlerts = false; // EnablePushAlerts: Send a push notification on alert.
input string AlertEmailSubject = "";
input string AlertText = "";
input string SoundFileName	= "alert.wav";

double H[];
double L[];

datetime LastAlertTime = D'01.01.1970';

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//|------------------------------------------------------------------|
int init()
{
   SetIndexBuffer(0, H);
   SetIndexBuffer(1, L);

   LastAlertTime = Time[0];
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   if (ExtCountedBars > 0) ExtCountedBars--;

   int i = Bars - ExtCountedBars - 1;

   while(i >= 0)
   {
      double length = High[i] - Low[i];
      double body = MathAbs(Open[i] - Close[i]);
      double percentage = (double)Percentage / 100.0;
      if ((length != 0) && (body / length < percentage))
      {
         H[i] = Open[i];
         L[i] = Close[i];
      }
      else
      {
         H[i] = EMPTY_VALUE;
         L[i] = EMPTY_VALUE;
      }
 	   i--;
   }

   if (Time[0] > LastAlertTime)
	{
	   string Text;
   	// Basing Candle Alert
   	if (H[TriggerCandle] != EMPTY_VALUE)
   	{
   		Text = AlertText + "Basing Candle Alert: " + Symbol() + " - " + TF2Str(Period()) + ".";
   		if (EnableNativeAlerts) Alert(Text);
   		if (EnableEmailAlerts) SendMail(AlertEmailSubject + "Basing Candle Alert", Text);
   		if (EnableSoundAlerts) PlaySound(SoundFileName);
   		if (EnablePushAlerts) SendNotification(Text);
   		LastAlertTime = Time[0];
   	}
   }
   return(0);
}

//+------------------------------------------------------------------+
//| Converts Period() to normal string value.                        |
//+------------------------------------------------------------------+
string TF2Str(int period)
{
   switch(period)
   {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
      default: return("Unknown");
   }
   return(EnumToString((ENUM_TIMEFRAMES)Period()));
}
//+------------------------------------------------------------------+