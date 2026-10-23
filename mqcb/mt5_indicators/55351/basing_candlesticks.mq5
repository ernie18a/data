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
#property indicator_buffers 4
#property indicator_plots 1
#property indicator_type1 DRAW_CANDLES
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrBlue
#property indicator_width1 1

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
double O[];
double C[];

datetime LastAlertTime = D'01.01.1970';

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, O, INDICATOR_DATA);
   SetIndexBuffer(1, H, INDICATOR_DATA);
   SetIndexBuffer(2, L, INDICATOR_DATA);
   SetIndexBuffer(3, C, INDICATOR_DATA);

   ArraySetAsSeries(O, true);
   ArraySetAsSeries(H, true);
   ArraySetAsSeries(L, true);
   ArraySetAsSeries(C, true);

   LastAlertTime = iTime(Symbol(), Period(), 0);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator main iteration function                         |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   
   ArraySetAsSeries(Open, true);
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Close, true);
   ArraySetAsSeries(Time, true);
   
   int counted_bars = prev_calculated;
   if (counted_bars < 0) return(-1);
   if (counted_bars > 0) counted_bars--;
   int i = rates_total - counted_bars - 1;
   if (i == 0) i++;

   while(i >= 0)
   {
      double length = High[i] - Low[i];
      double body = MathAbs(Open[i] - Close[i]);
      double percentage = (double)Percentage / 100.0;
      if ((length != 0) && (body / length < percentage))
      {
         H[i] = High[i];
         L[i] = Low[i];
         O[i] = Open[i];
         C[i] = Close[i];
      }
      else
      {
         H[i] = EMPTY_VALUE;
         L[i] = EMPTY_VALUE;
         O[i] = EMPTY_VALUE;
         C[i] = EMPTY_VALUE;
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

   return(rates_total);
}

//+------------------------------------------------------------------+
//| Converts Period() to normal string value.                        |
//+------------------------------------------------------------------+
string TF2Str(int period)
{
   switch(period)
   {
      case PERIOD_M1: return("M1");
      case PERIOD_M2: return("M2");
      case PERIOD_M3: return("M3");
      case PERIOD_M4: return("M4");
      case PERIOD_M5: return("M5");
      case PERIOD_M6: return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H2: return("H2");
      case PERIOD_H3: return("H3");
      case PERIOD_H4: return("H4");
      case PERIOD_H6: return("H6");
      case PERIOD_H8: return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
      default: return("Unknown");
   }
   return(EnumToString((ENUM_TIMEFRAMES)Period()));
}
//+------------------------------------------------------------------+