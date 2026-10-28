//+------------------------------------------------------------------+
//|                                         DataTraderH4Breakout.mq5 |
//|                                                    Mueller Peter |
//|                   https://www.mql5.com/en/users/mullerp04/seller |
//+------------------------------------------------------------------+
#property copyright "Mueller Peter"
#property link      "https://www.mql5.com/en/users/mullerp04/seller"
#property version   "1.01"
#include <Trade\Trade.mqh>

//--- Basic inputs
input int  ServerGMTOffsetWinter = 2;   // Server GMT offset in Winter time
input int  ServerGMTOffsetSummer = 3;   // Server GMT offset in Summer time (can be the same as winter)

//--- Server switching dates (month/day) (as seen in server time date)
input int  ServerSwitchToSummerMonth = 3;   // Month when broker's server switches to Summer time
input int  ServerSwitchToSummerDay   = 1;   // Day of month when broker's server switches to Summer time
input int  ServerSwitchToWinterMonth = 11;  // Month when broker's server switches to Winter time
input int  ServerSwitchToWinterDay   = 1;   // Day of month when broker's server switches to Winter time

//--- Trading input 
input double Lots = 0.1; // Lot size

// Global variables used for forming the range
bool   RangeFormed = false;
double RangeTop    = 0;
double RangeBottom = 0;


int OnInit()
{
   // ------ This section is purely for aesthetics, so that the chart's backtest looks better
   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,C'0x12,0x12,0x12');
   ChartSetInteger(ChartID(),CHART_MODE,CHART_CANDLES);
   ChartSetInteger(ChartID(),CHART_SHOW_GRID,false);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,C'0x08,0x99,0x81');
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,C'0x08,0x99,0x81');
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,C'0xf2,0x36,0x45');
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,C'0xf2,0x36,0x45');
   
   // Creating the support and resistance horizontal lines, these will be modified based on the ranges formed.
   ObjectCreate(ChartID(),"Support",OBJ_HLINE,0,0,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   ObjectSetInteger(ChartID(),"Support",OBJPROP_COLOR,clrRed);

   ObjectCreate(ChartID(),"Resistance",OBJ_HLINE,0,0,SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   ObjectSetInteger(ChartID(),"Resistance",OBJPROP_COLOR,clrGreen);

   // Initializing the Range
   RangeBottom = DBL_MAX;
   RangeTop    = 0.0;
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {}

void OnTick()
{
   // Trading logic is only applied when a new candle is formed
   if(IsNewCandle())
   {
      RangeForming(); // If the current time is inside the 4H window, we form the range
      if(RangeFormed && PositionsTotal() == 0) // If the range was formed and there are no open positions we check for signals
      {
         if(iClose(_Symbol,PERIOD_M5,1) > RangeBottom && iClose(_Symbol,PERIOD_M5,2) < RangeBottom) // Buy signal
         {
            int i = 2;
            double lowestLow = DBL_MAX;
            double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
            while(iClose(_Symbol,PERIOD_M5,i) < RangeBottom) // search for lowest low as the SL TP = 2*SL
            {
               double lo = iLow(_Symbol,PERIOD_M5,i);
               if(lo < lowestLow)
                  lowestLow = lo;
               i++;
               if(i > 15)
                  return;
            }
            if(lowestLow == DBL_MAX) // error check (safety, should never enter)
               return;
            double SL = lowestLow;
            double TP = ask + 2.0*MathAbs(ask-lowestLow);
            CTrade Trade;
            if(CheckVolumeValue(Lots)&& MathAbs(ask-SL) > SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*4*_Point && MathAbs(ask-TP) > SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*4*_Point)
               Trade.Buy(Lots,_Symbol,ask,SL,TP);
         }

         if(iClose(_Symbol,PERIOD_M5,1) < RangeTop && iClose(_Symbol,PERIOD_M5,2) > RangeTop) // sell signal
         {
            int i = 2;
            double highestHigh = 0.0;
            double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
            while(iClose(_Symbol,PERIOD_M5,i) > RangeTop) // searching for highest high, which will be the SL. TP = 2*SL
            {
               double hi = iHigh(_Symbol,PERIOD_M5,i);
               if(hi > highestHigh)
                  highestHigh = hi;
               i++;
               if(i > 15)
                  return;
            }
            if(highestHigh <= 0.0) // error check (safety, should never enter)
               return;
            double SL = highestHigh;
            double TP = bid - 2.0*MathAbs(bid-highestHigh);
            CTrade Trade;
            if(CheckVolumeValue(Lots) && MathAbs(bid-SL) > SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*4*_Point && MathAbs(bid-TP) > SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL)*4*_Point)
               Trade.Sell(Lots,_Symbol,bid,SL,TP);
         }
      }
   }
}

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
}

//---------------------- New candle detection -----------------
bool IsNewCandle()
{
   static int prevbars= 0;
   int bars = iBars(_Symbol,PERIOD_M5);
   if(bars != prevbars)
   {
      prevbars = bars;
      return true;
   }
   return false;
}

//---------------------- Time conversion helpers ----------------------
// Server offset based on your basic inputs (month/day switch, server-time date)
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
         return ServerGMTOffsetSummer;
      return ServerGMTOffsetWinter;
   }

   // If you configured wrap-around across year boundary
   if(server_time >= startSummer || server_time < startWinter)
      return ServerGMTOffsetSummer;
   return ServerGMTOffsetWinter;
}

datetime ServerToUTC(datetime server_time)
{
   return server_time - (ServerOffsetHours(server_time) * 3600);
}

// US DST rule for New York (this is fixed): 2nd Sunday in March, 1st Sunday in November.
// Transition moments expressed in UTC:
// - DST starts 02:00 EST => 07:00 UTC
// - DST ends   02:00 EDT => 06:00 UTC
int DayOfWeek_0Sun(datetime t)
{
   MqlDateTime dt;
   TimeToStruct(t, dt);
   return dt.day_of_week; // 0=Sunday..6=Saturday
}

// returns an integer, representing the day in the month which is the nth sunday (for example third)
int NthSundayOfMonth(int year, int month, int nth)
{
   MqlDateTime d; d.year=year; d.mon=month; d.day=1; d.hour=0; d.min=0; d.sec=0;
   datetime first = StructToTime(d);
   int dow = DayOfWeek_0Sun(first);
   int firstSundayDay = 1 + ((7 - dow) % 7);
   return firstSundayDay + 7*(nth-1);
}

int FirstSundayOfMonth(int year, int month) // Get the first Sunday of the month
{
   return NthSundayOfMonth(year, month, 1);
}

datetime NY_DST_Start_UTC(int year) // returns the datetime when US summer time begins (second sunday of march)
{
   int day = NthSundayOfMonth(year, 3, 2);
   MqlDateTime t; t.year=year; t.mon=3; t.day=day; t.hour=7; t.min=0; t.sec=0;
   return StructToTime(t);
}

datetime NY_DST_End_UTC(int year) // returns the datetime when US winter time begins (first sunday of November)
{
   int day = FirstSundayOfMonth(year, 11);
   MqlDateTime t; t.year=year; t.mon=11; t.day=day; t.hour=6; t.min=0; t.sec=0;
   return StructToTime(t);
}

int NewYorkGMTOffsetHoursFromUTC(datetime utc_time) // Returns New York's GMT offset
{
   MqlDateTime u;
   TimeToStruct(utc_time, u);

   datetime ds = NY_DST_Start_UTC(u.year);
   datetime de = NY_DST_End_UTC(u.year);

   // NY: winter -5, summer -4
   if(utc_time >= ds && utc_time < de)
      return -4;
   return -5;
}

// Converts GMT time to New York time
datetime UTCToNewYork(datetime utc_time)
{
   return utc_time + (NewYorkGMTOffsetHoursFromUTC(utc_time) * 3600);
}

// Returns true if current time is within the first 4 hours of NY kocal time
bool TimeNewyorkFirst_4_H(datetime server_time)
{
   datetime utc_time = ServerToUTC(server_time);
   datetime ny_time  = UTCToNewYork(utc_time);

   MqlDateTime ny;
   TimeToStruct(ny_time, ny);

   int minutes = ny.hour*60 + ny.min;
   return (minutes >= 0 && minutes < 240);
}

//---------------------- Range logic, called after a candle was formed------
void RangeForming()
{
   datetime server_time = TimeTradeServer();

   if(TimeNewyorkFirst_4_H(server_time))  // If we are in the first 4 Hour range.
   {
      if(RangeFormed) // If this is the first candle, the Range was previously formed
      {  //Initializing values -> Range is empty
         RangeBottom = DBL_MAX;
         RangeTop = 0.0;
         RangeFormed = false;
      }

      double lo = iLow(_Symbol,PERIOD_M5,1);
      double hi = iHigh(_Symbol,PERIOD_M5,1);
      //Check whether we've found a lower low than the previous RangeBottom, or a higher high than the previous Range Top
      if(lo < RangeBottom) RangeBottom = lo;
      if(hi > RangeTop)    RangeTop = hi;
   }
   else if(RangeFormed == false) // If the range formed is false, but we are outside the 4H range ->  RangeFormed 
   {
      if(RangeBottom != DBL_MAX && RangeTop > RangeBottom)
      {
         ObjectSetDouble(ChartID(),"Support",OBJPROP_PRICE,RangeBottom); // Fixating the chart objects at the found support / resistance levels.
         ObjectSetDouble(ChartID(),"Resistance",OBJPROP_PRICE,RangeTop);
         RangeFormed = true;
      }
   }
}
// Basic Volume checker function 
bool CheckVolumeValue(double Vol)
{
   double checkvol = Vol;
   double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double marg;
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(checkvol<min_volume)
     {
      return(false);
     }
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(checkvol>max_volume)
     {
      return(false);
     }
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(checkvol/volume_step);
   if(MathAbs(ratio*volume_step-checkvol)>0.0000001)
     {

      return(false);
     }
   if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,Vol,ask,marg))
      Print("Failed OrderCalcmargin");
   if(marg > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
      return false;
   return(true);
}
