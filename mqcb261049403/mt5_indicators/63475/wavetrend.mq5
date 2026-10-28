#property copyright "wazatrader"
#property version "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 2

#property indicator_label1 "WT1"
#property indicator_type1 DRAW_LINE
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1

#property indicator_label2 "WT2"
#property indicator_type2 DRAW_LINE
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1

// Inputs
input int n1 = 10; // Channel Length
input int n2 = 21; // Average Length

// Buffers
double wt1Buffer[];
double wt2Buffer[];
double esaBuffer[];
double dBuffer[];
double ciBuffer[];
double tciBuffer[];

// Variables to store crossing states
bool crossUp = false;
bool crossDown = false;

// Initialization function
int OnInit()
{
   SetIndexBuffer(0, wt1Buffer, INDICATOR_DATA);
   SetIndexBuffer(1, wt2Buffer, INDICATOR_DATA);
   SetIndexBuffer(2, esaBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, dBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, ciBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, tciBuffer, INDICATOR_CALCULATIONS);

   IndicatorSetString(INDICATOR_SHORTNAME, "WT Indicator");

  

   return(INIT_SUCCEEDED);
}
// Calculation function
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
   int begin = MathMax(n1, n2) + 1;
   if (rates_total < begin) return(0);

   int start = MathMax(prev_calculated - 1, begin);

   for (int i = start; i < rates_total; i++)
   {
      double hlc3 = (high[i] + low[i] + close[i]) / 3.0;

      if (i == 0)
         esaBuffer[i] = hlc3;
      else
         esaBuffer[i] = (2.0 / (n1 + 1)) * hlc3 + (1.0 - (2.0 / (n1 + 1))) * esaBuffer[i - 1];

      if (i == 0)
         dBuffer[i] = MathAbs(hlc3 - esaBuffer[i]);
      else
         dBuffer[i] = (2.0 / (n1 + 1)) * MathAbs(hlc3 - esaBuffer[i]) + (1.0 - (2.0 / (n1 + 1))) * dBuffer[i - 1];

      ciBuffer[i] = (hlc3 - esaBuffer[i]) / (0.015 * dBuffer[i]);

      if (i == 0)
         tciBuffer[i] = ciBuffer[i];
      else
         tciBuffer[i] = (2.0 / (n2 + 1)) * ciBuffer[i] + (1.0 - (2.0 / (n2 + 1))) * tciBuffer[i - 1];

      // WT1
      wt1Buffer[i] = tciBuffer[i];

      // WT2 - Moving average of WT1
      if (i >= 4)
         wt2Buffer[i] = (wt1Buffer[i] + wt1Buffer[i - 1] + wt1Buffer[i - 2] + wt1Buffer[i - 3]) / 4.0;
      else
         wt2Buffer[i] = wt1Buffer[i];
   }

   // Check for cross up and cross down
   if (rates_total >= 2)
   {
      double wt1_prev = wt1Buffer[rates_total - 2];
      double wt2_prev = wt2Buffer[rates_total - 2];
      double wt1_now = wt1Buffer[rates_total - 1];
      double wt2_now = wt2Buffer[rates_total - 1];

      if (wt1_prev < wt2_prev && wt1_now > wt2_now && !crossUp)
      {
         crossUp = true;
         crossDown = false;

         // Get the currency pair name and current timeframe
         string symbol = Symbol();
         int timeframe = Period();
         string timeframeStr;

         // Convert timeframe from number to string
         switch (timeframe)
         {
            case 1: timeframeStr = "1 minute"; break;
            case 5: timeframeStr = "5 minutes"; break;
            case 15: timeframeStr = "15 minutes"; break;
            case 30: timeframeStr = "30 minutes"; break;
            case 60: timeframeStr = "1 hour"; break;
            case 240: timeframeStr = "4 hours"; break;
            case 1440: timeframeStr = "1 day"; break;
            case 10080: timeframeStr = "1 week"; break;
            case 43200: timeframeStr = "1 month"; break;
            default: timeframeStr = "Unknown"; break;
         }

         // Create notification
         string notificationText = symbol + " - WT1 just crossed WT2 on timeframe " + timeframeStr;
         SendNotification(notificationText);
      }
      else if (wt1_prev > wt2_prev && wt1_now < wt2_now && !crossDown)
      {
         crossDown = true;
         crossUp = false;

         // Get the currency pair name and current timeframe
         string symbol = Symbol();
         int timeframe = Period();
         string timeframeStr;

         // Convert timeframe from number to string
         switch (timeframe)
         {
            case 1: timeframeStr = "1 minute"; break;
            case 5: timeframeStr = "5 minutes"; break;
            case 15: timeframeStr = "15 minutes"; break;
            case 30: timeframeStr = "30 minutes"; break;
            case 60: timeframeStr = "1 hour"; break;
            case 240: timeframeStr = "4 hours"; break;
            case 1440: timeframeStr = "1 day"; break;
            case 10080: timeframeStr = "1 week"; break;
            case 43200: timeframeStr = "1 month"; break;
            default: timeframeStr = "Unknown"; break;
         }

         // Create notification
         string notificationText = symbol + " - WT1 just crossed WT2 on timeframe " + timeframeStr;
         SendNotification(notificationText);
      }
   }

   // Debug WT1 and WT2 data
   Print("WT1: ", wt1Buffer[rates_total - 1], " | WT2: ", wt2Buffer[rates_total - 1]);

   return(rates_total);
}