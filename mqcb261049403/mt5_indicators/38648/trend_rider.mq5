//+------------------------------------------------------------------+
//|                                                  Trend Rider.mq5 |
//|                                          Copyright 2022, A.L.I™. |
//|                                       "https://www.aligroup.com" |
//+------------------------------------------------------------------+
#property copyright "A.L.I™"
#property link "https://www.aligroup.com"
#property version "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots 2

//--- plot Bars
#property indicator_label1 "Bars"
#property indicator_type1 DRAW_COLOR_CANDLES
#property indicator_color1 clrDimGray, clrGreen, clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- plot TrendLine
#property indicator_label2 "TrendLine"
#property indicator_type2 DRAW_COLOR_LINE
#property indicator_color2 clrDeepSkyBlue, clrPaleVioletRed
#property indicator_style2 STYLE_DOT
#property indicator_width2 1

#define RESET 0
#define Buy 1.0
#define Sell -1.0

input int AtrLength = 10;                                // ATR calculaion period
input double AtrMultiplier = 3.0;                        // ATR multiplier
input ENUM_APPLIED_PRICE AtrAppliedPrice = PRICE_CLOSE;  // AtrAppliedPrice to use
input int RsiPeriod = 14;                                // Rsi Period
input ENUM_APPLIED_PRICE RsiAppliedPrice = PRICE_CLOSE;  // Rsi Applied AtrAppliedPrice
input int InpFastEMA = 12;                               // Macd fast period
input int InpSlowEMA = 26;                               // Macd slow period
input int InpSignalEMA = 9;                              // Macd Signal period
input ENUM_APPLIED_PRICE MacdAppliedPrice = PRICE_CLOSE; // Applied AtrAppliedPrice
input bool AlertOn = true;                               // Alerts On
input bool SoundON = true;                               // Show Alert Message
input bool EmailON = false;                              // Send Email Alerts
input bool PushNotificationON = false;                   // Send Push Notifications

string prog_name = "Trend Rider";
int iATR_Handle, iRSI_Handle, iMACD_Handle;
double Up[], Dn[], Di[], SuperTrend[], STColors[], candleH[], candleL[], candleO[], candleC[], Ccolors[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//---Relative Strengh Index Candles
   SetIndexBuffer(0, candleO, INDICATOR_DATA);
   SetIndexBuffer(1, candleH, INDICATOR_DATA);
   SetIndexBuffer(2, candleL, INDICATOR_DATA);
   SetIndexBuffer(3, candleC, INDICATOR_DATA);
   SetIndexBuffer(4, Ccolors, INDICATOR_COLOR_INDEX);
//---SuperTrend
   SetIndexBuffer(5, SuperTrend, INDICATOR_DATA);
   SetIndexBuffer(6, STColors, INDICATOR_COLOR_INDEX);
//---Calculations
   SetIndexBuffer(7, Up, INDICATOR_CALCULATIONS);
   SetIndexBuffer(8, Dn, INDICATOR_CALCULATIONS);
   SetIndexBuffer(9, Di, INDICATOR_CALCULATIONS);

   if((iMACD_Handle = iMACD(Symbol(), PERIOD_CURRENT, InpFastEMA, InpSlowEMA, InpSignalEMA, MacdAppliedPrice)) == INVALID_HANDLE)
     {
      Print("Failed to initialize ", Symbol(), " MACD indicator handle");
      return (INIT_FAILED);
     }
   if((iRSI_Handle = iRSI(Symbol(), PERIOD_CURRENT, RsiPeriod, RsiAppliedPrice)) == INVALID_HANDLE)
     {
      Print("Failed to initialize ", Symbol(), " RSI indicator handle");
      return (INIT_FAILED);
     }
   if((iATR_Handle = iATR(Symbol(), PERIOD_CURRENT, AtrLength)) == INVALID_HANDLE)
     {
      Print("Failed to initialize ", Symbol(), " ATR indicator handle");
      return (INIT_FAILED);
     }

   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   IndicatorSetString(INDICATOR_SHORTNAME, prog_name + " (" + string(AtrLength) + "," + string(AtrMultiplier) + ") " + GetTimeFrame(PERIOD_CURRENT));

//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {
   double atr[], rsi[], macd[];

//--- get fast indicator buffer values
   if(BarsCalculated(iMACD_Handle) < rates_total || CopyBuffer(iMACD_Handle, MAIN_LINE, 0, rates_total, macd) < rates_total)
     {
      Print("Unable to get all ", Symbol(), " MACD indicator values, Error Code: ", GetLastError());
      return RESET;
     }
   if(BarsCalculated(iRSI_Handle) < rates_total || CopyBuffer(iRSI_Handle, 0, 0, rates_total, rsi) < rates_total)
     {
      Print("Unable to get all ", Symbol(), " RSI indicator values, Error Code: ", GetLastError());
      return RESET;
     }
   if((BarsCalculated(iATR_Handle) < rates_total) || (CopyBuffer(iATR_Handle, 0, 0, rates_total, atr) < rates_total))
     {
      Print("Unable to get all ", Symbol(), " ATR indicator values, Error Code: ", GetLastError());
      return RESET;
     }

   for(int i = MathMax(prev_calculated - 1, 1); i < rates_total; i++)
     {
      double mprice = (high[i] + low[i]) / 2;
      Up[i] = mprice + AtrMultiplier * atr[i];
      Dn[i] = mprice - AtrMultiplier * atr[i];
      double cprice = getPrice(AtrAppliedPrice, open, close, high, low, i);
      Di[i] = (cprice > Up[i - 1]) ? 1 : (cprice < Dn[i - 1]) ? -1 : Di[i - 1];

      if(Di[i] > 0)
        {
         STColors[i] = 0;
         Ccolors[i] = (rsi[i] > 50 && macd[i] > 0) ? 1 : 0;
         SuperTrend[i] = Dn[i] = MathMax(Dn[i], Dn[i - 1]);
        }
      if(Di[i] < 0)
        {
         STColors[i] = 1;
         Ccolors[i] = (rsi[i] < 50 && macd[i] < 0) ? 2 : 0;
         SuperTrend[i] = Up[i] = MathMin(Up[i], Up[i - 1]);
        }

      candleO[i] = open[i];
      candleH[i] = high[i];
      candleL[i] = low[i];
      candleC[i] = close[i];
     }

   if(AlertOn)
     {
      bool isNewBar = false;
      int bars = rates_total - 1;
      static datetime LastBarTime = 0;
      datetime CurrentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
      LastBarTime = (isNewBar = (CurrentBarTime > LastBarTime)) ? CurrentBarTime : LastBarTime;

      if(isNewBar && Ccolors[bars - 1] != Ccolors[bars - 2])
        {
         string prevTrend = (Ccolors[bars - 2] == 1) ? "BUY" : (Ccolors[bars - 2] == 2) ? "SELL" : "";
         string direction = (Ccolors[bars - 1] == 0) ? "EXIT " + prevTrend : (Ccolors[bars - 1] == 1) ? "BUY" : (Ccolors[bars - 1] == 2)   ? "SELL" : NULL;

         if(direction != NULL)
           {
            string message = TimeToString(time[bars], TIME_MINUTES) + " " + Symbol() + " " + GetTimeFrame(PERIOD_CURRENT) + " " + prog_name + " " + direction;

            if(SoundON)
               Alert(message);
            if(PushNotificationON)
               SendNotification(message);
            if(EmailON)
               SendMail(prog_name, message);
           }
        }
     }
//--- return value of prev_calculated for next call
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getPrice(ENUM_APPLIED_PRICE price, const double &open[], const double &close[], const double &high[], const double &low[], int i)
  {
   switch(price)
     {
      case PRICE_CLOSE:
         return (close[i]);
      case PRICE_OPEN:
         return (open[i]);
      case PRICE_HIGH:
         return (high[i]);
      case PRICE_LOW:
         return (low[i]);
      case PRICE_MEDIAN:
         return ((high[i] + low[i]) / 2.0);
      case PRICE_TYPICAL:
         return ((high[i] + low[i] + close[i]) / 3.0);
      case PRICE_WEIGHTED:
         return ((high[i] + low[i] + close[i] + close[i]) / 4.0);
      default:
         return (close[i]);
     }
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
