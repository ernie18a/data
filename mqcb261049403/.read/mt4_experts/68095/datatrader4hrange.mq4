//+------------------------------------------------------------------+
//|                                         DataTraderH4Breakout.mq4 |
//|                                                    Mueller Peter |
//|                   https://www.mql5.com/en/users/mullerp04/seller |
//+------------------------------------------------------------------+
#property copyright "Mueller Peter"
#property link      "https://www.mql5.com/en/users/mullerp04/seller"
#property version   "1.01"
#property strict

//--- Basic inputs
extern int  ServerGMTOffsetWinter = 2;   // Server GMT offset in Winter time
extern int  ServerGMTOffsetSummer = 3;   // Server GMT offset in Summer time (can be the same as winter)

//--- Server switching dates (month/day) (as seen in server time date)
extern int  ServerSwitchToSummerMonth = 3;   // Month when broker's server switches to Summer time
extern int  ServerSwitchToSummerDay   = 1;   // Day of month when broker's server switches to Summer time
extern int  ServerSwitchToWinterMonth = 11;  // Month when broker's server switches to Winter time
extern int  ServerSwitchToWinterDay   = 1;   // Day of month when broker's server switches to Winter time

//--- Trading inputs
extern double Lots        = 0.1;    // Lot size
extern int    Slippage    = 10;     // Slippage in points
extern int    MagicNumber = 240401; // Magic number

//--- Global variables used for forming the range
bool   RangeFormed = false;
double RangeTop    = 0.0;
double RangeBottom = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
{
   // ------ This section is purely for aesthetics, so that the chart's backtest looks better
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, C'0x12,0x12,0x12');
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES);
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   ChartSetInteger(0, CHART_COLOR_CHART_UP,   C'0x08,0x99,0x81');
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL,C'0x08,0x99,0x81');
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, C'0xf2,0x36,0x45');
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR,C'0xf2,0x36,0x45');

   // Creating the support and resistance horizontal lines, these will be modified based on the ranges formed.
   if(ObjectFind(0, "Support") < 0)
   {
      ObjectCreate("Support", OBJ_HLINE, 0, 0, Ask);
      ObjectSet("Support", OBJPROP_COLOR, clrRed);
   }

   if(ObjectFind(0, "Resistance") < 0)
   {
      ObjectCreate("Resistance", OBJ_HLINE, 0, 0, Ask);
      ObjectSet("Resistance", OBJPROP_COLOR, clrGreen);
   }

   // Initializing the Range
   RangeBottom = DBL_MAX;
   RangeTop    = 0.0;

   return(0);
}

int deinit()
{
   return(0);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
int start()
{
   // Trading logic is only applied when a new candle is formed
   if(IsNewCandle())
   {
      RangeForming(); // If the current time is inside the 4H window, we form the range

      if(RangeFormed && OpenOrdersCountForSymbolMagic(Symbol(), MagicNumber) == 0)
      {
         // Buy signal: candle 1 closes above RangeBottom, candle 2 closes below RangeBottom
         if(iClose(Symbol(), PERIOD_M5, 1) > RangeBottom && iClose(Symbol(), PERIOD_M5, 2) < RangeBottom)
         {
            int i = 2;
            double lowestLow = DBL_MAX;

            while(iClose(Symbol(), PERIOD_M5, i) < RangeBottom)
            {
               double lo = iLow(Symbol(), PERIOD_M5, i);
               if(lo < lowestLow) lowestLow = lo;
               i++;
               if(i > 15) return(0);
            }
            if(lowestLow == DBL_MAX) return(0);

            RefreshRates();
            double ask = Ask;

            double SL = lowestLow;
            double TP = ask + 2.0 * MathAbs(ask - lowestLow);

            SL = NormalizeDouble(SL, Digits);
            TP = NormalizeDouble(TP, Digits);

            double stopLevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL) * Point;
            
            if(CheckVolumeValue(Lots) &&
               MathAbs(ask - SL) > stopLevel &&
               MathAbs(ask - TP) > stopLevel)
            {
               int ticket = OrderSend(Symbol(), OP_BUY, Lots, ask, Slippage, SL, TP,
                                      "H4Breakout", MagicNumber, 0, clrNONE);
            }
         }

         // Sell signal: candle 1 closes below RangeTop, candle 2 closes above RangeTop
         if(iClose(Symbol(), PERIOD_M5, 1) < RangeTop && iClose(Symbol(), PERIOD_M5, 2) > RangeTop)
         {
            int i = 2;
            double highestHigh = 0.0;

            while(iClose(Symbol(), PERIOD_M5, i) > RangeTop)
            {
               double hi = iHigh(Symbol(), PERIOD_M5, i);
               if(hi > highestHigh) highestHigh = hi;
               i++;
               if(i > 15) return(0);
            }
            if(highestHigh <= 0.0) return(0);

            RefreshRates();
            double bid = Bid;

            double SL = highestHigh;
            double TP = bid - 2.0 * MathAbs(bid - highestHigh);

            SL = NormalizeDouble(SL, Digits);
            TP = NormalizeDouble(TP, Digits);

            double stopLevel = SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL) * Point;

            if(CheckVolumeValue(Lots) &&
               MathAbs(bid - SL) > stopLevel &&
               MathAbs(bid - TP) > stopLevel)
            {
               int ticket = OrderSend(Symbol(), OP_SELL, Lots, bid, Slippage, SL, TP,
                                      "H4Breakout", MagicNumber, 0, clrNONE);
            }
         }
      }
   }

   return(0);
}

//+------------------------------------------------------------------+
//| New candle detection (M5)                                        |
//+------------------------------------------------------------------+
bool IsNewCandle()
{
   static datetime prevTime = 0;
   datetime t = iTime(Symbol(), PERIOD_M5, 0);
   if(t != prevTime)
   {
      prevTime = t;
      return(true);
   }
   return(false);
}

//+------------------------------------------------------------------+
//| Time conversion helpers                                          |
//+------------------------------------------------------------------+
int ServerOffsetHours(datetime server_time)
{
   MqlDateTime st;
   TimeToStruct(server_time, st);

   MqlDateTime s = st;
   s.mon = ServerSwitchToSummerMonth;
   s.day = ServerSwitchToSummerDay;
   s.hour = 0; s.min = 0; s.sec = 0;

   MqlDateTime w = st;
   w.mon = ServerSwitchToWinterMonth;
   w.day = ServerSwitchToWinterDay;
   w.hour = 0; w.min = 0; w.sec = 0;

   datetime startSummer = StructToTime(s);
   datetime startWinter = StructToTime(w);

   // Typical case: the summer start of your server's offset comes before the winter switching in the year
   if(startSummer < startWinter)
   {
      if(server_time >= startSummer && server_time < startWinter)
         return(ServerGMTOffsetSummer);
      return(ServerGMTOffsetWinter);
   }

   // Wrap-around across year boundary
   if(server_time >= startSummer || server_time < startWinter)
      return(ServerGMTOffsetSummer);
   return(ServerGMTOffsetWinter);
}

datetime ServerToUTC(datetime server_time)
{
   return(server_time - (ServerOffsetHours(server_time) * 3600));
}

int DayOfWeek_0Sun(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return(dt.day_of_week); // 0=Sunday..6=Saturday
}

int NthSundayOfMonth(int year, int month, int nth)
{
   MqlDateTime d;
   d.year = year; d.mon = month; d.day = 1; d.hour = 0; d.min = 0; d.sec = 0;
   datetime first = StructToTime(d);

   int dow = DayOfWeek_0Sun(first);
   int firstSundayDay = 1 + ((7 - dow) % 7);
   return(firstSundayDay + 7 * (nth - 1));
}

int FirstSundayOfMonth(int year, int month)
{
   return(NthSundayOfMonth(year, month, 1));
}

datetime NY_DST_Start_UTC(int year)
{
   int day = NthSundayOfMonth(year, 3, 2);
   MqlDateTime t;
   t.year = year; t.mon = 3; t.day = day; t.hour = 7; t.min = 0; t.sec = 0; // 07:00 UTC
   return(StructToTime(t));
}

datetime NY_DST_End_UTC(int year)
{
   int day = FirstSundayOfMonth(year, 11);
   MqlDateTime t;
   t.year = year; t.mon = 11; t.day = day; t.hour = 6; t.min = 0; t.sec = 0; // 06:00 UTC
   return(StructToTime(t));
}

int NewYorkGMTOffsetHoursFromUTC(datetime utc_time)
{
   MqlDateTime u;
   TimeToStruct(utc_time, u);

   datetime ds = NY_DST_Start_UTC(u.year);
   datetime de = NY_DST_End_UTC(u.year);

   // NY: winter -5, summer -4
   if(utc_time >= ds && utc_time < de) return(-4);
   return(-5);
}

datetime UTCToNewYork(datetime utc_time)
{
   return(utc_time + (NewYorkGMTOffsetHoursFromUTC(utc_time) * 3600));
}

// Returns true if current time is within the first 4 hours of NY local time
bool TimeNewyorkFirst_4_H(datetime server_time)
{
   datetime utc_time = ServerToUTC(server_time);
   datetime ny_time  = UTCToNewYork(utc_time);

   MqlDateTime ny;
   TimeToStruct(ny_time, ny);

   int minutes = ny.hour * 60 + ny.min;
   return(minutes >= 0 && minutes < 240);
}

//+------------------------------------------------------------------+
//| Range logic (call after candle close)                            |
//+------------------------------------------------------------------+
void RangeForming()
{
   datetime server_time = TimeCurrent();

   if(TimeNewyorkFirst_4_H(server_time))
   {
      if(RangeFormed)
      {
         RangeBottom = DBL_MAX;
         RangeTop    = 0.0;
         RangeFormed = false;
      }

      double lo = iLow(Symbol(), PERIOD_M5, 1);
      double hi = iHigh(Symbol(), PERIOD_M5, 1);

      if(lo < RangeBottom) RangeBottom = lo;
      if(hi > RangeTop)    RangeTop    = hi;
   }
   else if(RangeFormed == false)
   {
      if(RangeBottom != DBL_MAX && RangeTop > RangeBottom)
      {
         ObjectSet("Support",    OBJPROP_PRICE1, RangeBottom);
         ObjectSet("Resistance", OBJPROP_PRICE1, RangeTop);
         RangeFormed = true;
      }
   }
}

//+------------------------------------------------------------------+
//| Helpers                                                         |
//+------------------------------------------------------------------+
int OpenOrdersCountForSymbolMagic(string sym, int magic)
{
   int cnt = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != sym) continue;
      if(OrderMagicNumber() != magic) continue;
      if(OrderType() == OP_BUY || OrderType() == OP_SELL) cnt++;
   }
   return(cnt);
}

bool CheckVolumeValue(double volume)
{
   double min_volume = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   if(volume < min_volume) return(false);

   double max_volume = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX); 
   if(volume > max_volume) return(false);

   double volume_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP); 
   int ratio = (int)MathRound(volume / volume_step);
   if(MathAbs(ratio * volume_step - volume) > 0.0000001) return(false);

   if(LotSize() * volume > AccountFreeMargin() / 2.0) return(false);

   return(true);
}

// Returns the amount of money it'd take to open 1.0 lot (estimated from min lot margin check)
double LotSize(double Price = 0.0)
{
   double minlot = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double after  = AccountFreeMarginCheck(Symbol(), OP_BUY, minlot);
   double cost   = AccountFreeMargin() - after;
   if(minlot <= 0.0) return(0.0);
   return(cost / minlot);
}
