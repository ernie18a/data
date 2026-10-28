//+------------------------------------------------------------------+
//|                              Trend Direction And Force Index.mq5 |
//|                                    Copyright 2022, aligroup inc. |
//|                                         https://www.aligroup.org |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, aligroup inc."
#property link "https://www.aligroup.org"
#property version "1.00"
#property strict

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots 4

//--- plot TDFI
#property indicator_label1 "TDFI"
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_color1 clrSilver, clrTeal,clrLightSkyBlue, clrBrown,clrPink
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
//--- plot BUY
#property indicator_label2 "BUY"
#property indicator_type2 DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_color2 clrLime
#property indicator_width2 1
//--- plot SELL
#property indicator_label3 "SELL"
#property indicator_type3 DRAW_ARROW
#property indicator_style3 STYLE_SOLID
#property indicator_color3 clrRed
#property indicator_width3 1
//--- plot FLAT
#property indicator_label4 "FLAT"
#property indicator_type4 DRAW_ARROW
#property indicator_style4 STYLE_SOLID
#property indicator_color4 clrSilver
#property indicator_width4 1

input int inpTrendPeriod = 14;         // Trend period
input double inpSmooth = 3.0;          // Smoothing period
input double inpTriggerUp = 0.05;      // Trigger up level
input double inpTriggerDown = -0.05;   // Trigger down level
input bool AlertOn = true;             // Alerts On
input bool SoundON = true;             // Show Alert Message
input bool EmailON = false;            // Send Email Alerts
input bool PushNotificationON = false; // Send Push Notifications

string prog_name = "TDFi";
int _maxPeriod = 3 * inpTrendPeriod;
double Trend[], Colors[], mma[], smma[], tdfa[], Buy[], Sell[], Flat[];
double _alpha = 2.0 / (1.0 + inpTrendPeriod), _alpha2 = 2.0 / (1.0 + MathSqrt(MathMax(inpSmooth, 1)));
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Trend, INDICATOR_DATA);
   SetIndexBuffer(1, Colors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, Buy, INDICATOR_DATA);
   SetIndexBuffer(3, Sell, INDICATOR_DATA);
   SetIndexBuffer(4, Flat, INDICATOR_DATA);

   SetIndexBuffer(5, mma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, smma, INDICATOR_CALCULATIONS);
   SetIndexBuffer(7, tdfa, INDICATOR_CALCULATIONS);

   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 0.0); 

   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   IndicatorSetString(INDICATOR_SHORTNAME, "TDFI(" + string(inpTrendPeriod) + "," + string(MathMax(inpSmooth, 1)) + ")");

//---
   return (INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[])
  {
//---
   for(int i = MathMax(prev_calculated - 1, 1); i < rates_total; i++)
     {
      Colors[i] = 0;
      Trend[i] = Buy[i]  = Sell[i] = Flat[i] = EMPTY_VALUE;
      mma[i] = (i > 0) ? mma[i - 1] + _alpha * (close[i] - mma[i - 1]) : close[i];
      smma[i] = (i > 0) ? smma[i - 1] + _alpha * (mma[i] - smma[i - 1]) : mma[i];

      double impetmma = mma[i] - mma[i - 1];
      double impetsmma = smma[i] - smma[i - 1];
      double divma = MathAbs(mma[i] - smma[i]);
      double averimpet = (impetmma + impetsmma) / 2.0;
      double tdf = divma * averimpet * averimpet * averimpet;

      tdfa[i] = MathAbs(tdf);
      int _start = MathMax(i - _maxPeriod + 1, 0);
      double _absValue = tdfa[ArrayMaximum(tdfa, _start, _maxPeriod)];

      double _val1 = (_absValue > 0) ? tdf / _absValue : 0;
      Trend[i] = Trend[i - 1] + _alpha2 * (_val1 - Trend[i - 1]);

      if(Trend[i] > inpTriggerUp)
        {
         Colors[i] = Trend[i] > Trend[i - 1] ? 1 : 2;

         if(Trend[i - 1] < inpTriggerUp)
           {
            Buy[i] = 0.0;
           }
        }
      if(Trend[i] < inpTriggerDown)
        {
         Colors[i] = Trend[i] < Trend[i - 1] ? 3 : 4;

         if(Trend[i - 1] > inpTriggerDown)
           {
            Sell[i] = 0.0;
           }
        }
      if((Trend[i] < inpTriggerUp && Trend[i - 1] > inpTriggerUp) || (Trend[i] > inpTriggerDown && Trend[i - 1] < inpTriggerDown))
        {
         Flat[i] = 0.0;
        }
     }

   if(AlertOn)
     {
      bool isNewBar = false;
      static datetime LastBarTime = 0;
      datetime CurrentBarTime = iTime(Symbol(), PERIOD_CURRENT, 0);
      LastBarTime = (isNewBar = (CurrentBarTime > LastBarTime)) ? CurrentBarTime : LastBarTime;

      if(isNewBar)
        {
         int bar = rates_total - 2;
         string message = (Buy[bar] == 0.0) ? "BUY" : (Sell[bar] == 0.0) ? "SELL" : "";

         if(StringLen(message) > 0)
           {
            message = TimeToString(time[bar], TIME_MINUTES) + " " + Symbol() + " " + prog_name + " " + GetTimeFrame(PERIOD_CURRENT) + " " + message;

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
string GetTimeFrame(ENUM_TIMEFRAMES timeframe)
  {
   timeframe = (timeframe == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)Period() : timeframe;
   string period_xxx = EnumToString(timeframe); // PERIOD_XXX
   return StringSubstr(period_xxx, 7);          // XXX
  }

//+------------------------------------------------------------------+
