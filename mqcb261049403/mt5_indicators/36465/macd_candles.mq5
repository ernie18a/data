//+------------------------------------------------------------------+
//|                  Moving Average Convergence/Divergence(MACD).mq5 |
//|                                                          A.L.I™. |
//|                                       "https://www.aligroup.com" |
//+------------------------------------------------------------------+
#property copyright "A.L.I™"
#property link "https://www.aligroup.com"
#property version "1.00"

#property strict
#property indicator_chart_window
#property description "Moving Average Convergence/Divergence"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 1

#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_color1 clrLimeGreen, clrGreen, clrRed, clrFireBrick, clrDimGray
#property indicator_label1 "Macd Candles"

input int InpFastEMA = 12;                           // Macd fast period
input int InpSlowEMA = 26;                           // Macd slow period
input int InpSignalEMA = 9;                          // Macd Signal period
input ENUM_APPLIED_PRICE AppliedPrice = PRICE_CLOSE; // Applied Price
input bool AlertOn = true;                           // Alerts On
input bool SoundON = true;                           // Show Alert Message
input bool EmailON = false;                          // Send Email Alerts
input bool PushNotificationON = false;               // Send Push Notifications

//--- indicator handles
int iMACD_Handle;
string prog_name = "MACD";
double candleH[], candleL[], candleO[], candleC[], Colors[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int OnInit()
  {
   SetIndexBuffer(0, candleO, INDICATOR_DATA);
   SetIndexBuffer(1, candleH, INDICATOR_DATA);
   SetIndexBuffer(2, candleL, INDICATOR_DATA);
   SetIndexBuffer(3, candleC, INDICATOR_DATA);
   SetIndexBuffer(4, Colors, INDICATOR_COLOR_INDEX); 

//--- get indicator handles
   if((iMACD_Handle = iMACD(Symbol(), PERIOD_CURRENT, InpFastEMA, InpSlowEMA, InpSignalEMA, AppliedPrice)) == INVALID_HANDLE)
     {
      Print("Failed to initialize ", Symbol(), " MACD indicator handle");
      return (INIT_FAILED);
     }
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {
   double MacdMainBuffer[], MacdSignalBuffer[];

//--- get fast indicator buffer values
   if(BarsCalculated(iMACD_Handle) < rates_total || CopyBuffer(iMACD_Handle, MAIN_LINE, 0, rates_total, MacdMainBuffer) < rates_total)
     {
      Print("Unable to get macd indicator values, Error Code: ", GetLastError());
      return 0;
     }
   if(BarsCalculated(iMACD_Handle) < rates_total || CopyBuffer(iMACD_Handle, SIGNAL_LINE, 0, rates_total, MacdSignalBuffer) < rates_total)
     {
      Print("Unable to get macd indicator values, Error Code: ", GetLastError());
      return 0;
     }

   for(int i = MathMax(prev_calculated - 1, 1); i < rates_total; i++)
     {
      if(MacdMainBuffer[i] > 0)
        {
         if(MacdMainBuffer[i] > MacdSignalBuffer[i])
            Colors[i] = 0;
         if(MacdMainBuffer[i] < MacdSignalBuffer[i])
            Colors[i] = 1;
        }
      if(MacdMainBuffer[i] < 0)
        {
         if(MacdMainBuffer[i] < MacdSignalBuffer[i])
            Colors[i] = 2;
         if(MacdMainBuffer[i] > MacdSignalBuffer[i])
            Colors[i] = 3;
        }
      candleO[i] = open[i];
      candleH[i] = high[i];
      candleL[i] = low[i];
      candleC[i] = close[i];
     }

   if(AlertOn)
     {
      bool isNewBar = false;
      static datetime LastBarTime = 0;
      datetime CurrentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
      LastBarTime = (isNewBar = (CurrentBarTime > LastBarTime)) ? CurrentBarTime : LastBarTime;

      if(isNewBar)
        {
         string message = NULL;
         ArraySetAsSeries(MacdMainBuffer, true);

         if(MacdMainBuffer[0] > 0 && MacdMainBuffer[1] > 0 && MacdMainBuffer[2] < 0)
           {
            message = "BUY";
           }
         if(MacdMainBuffer[0] < 0 && MacdMainBuffer[1] < 0 && MacdMainBuffer[2] > 0)
           {
            message = "SELL";
           }

         if(message != NULL)
           {
            message = TimeToString(TimeCurrent(), TIME_MINUTES) + " " + Symbol() + " " + GetTimeFrame(PERIOD_CURRENT) + " " + prog_name + " " + message;

            if(SoundON)
               Alert(message);
            if(PushNotificationON)
               SendNotification(message);
            if(EmailON)
               SendMail(prog_name, message);
           }

        }
     }
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(ENUM_TIMEFRAMES timeframe)
  {
   timeframe = (timeframe == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)Period() : timeframe;
   string period_xxx = EnumToString(timeframe); // PERIOD_XXX
   return StringSubstr(period_xxx, 7);          // XXX
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
