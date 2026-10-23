//+------------------------------------------------------------------+
//|                                FxCraft_Example_RangeBreakout.mq5 |
//|                    Example EA from FxCraft - https://fxcraft.biz |
//+------------------------------------------------------------------+
//
// PL: Przykładowy EA (program edukacyjny) – wybicie z zakresu (np. sesji azjatyckiej).
//     Działa WYŁĄCZNIE na rachunku demo i w testerze strategii.
//     Licencja: FxCraft Example EA License (plik LICENSE.txt) – bezpłatny, do nauki
//     i testów, udostępniany „tak jak jest”, bez żadnych gwarancji.
//     Program nie stanowi rekomendacji ani doradztwa inwestycyjnego. Handel na rynku
//     Forex i kontraktami CFD wiąże się z wysokim ryzykiem utraty kapitału. Wyniki
//     historyczne i wyniki z testera nie gwarantują przyszłych wyników. FxCraft nie
//     ponosi odpowiedzialności za straty wynikające z użycia programu.
//
// EN: Example EA (educational program) – range breakout (e.g. Asian session).
//     Works ONLY on demo accounts and in the Strategy Tester.
//     License: FxCraft Example EA License (LICENSE.txt) – free, for learning and
//     testing, provided "as is", without any warranty.
//     This program is not investment advice or a recommendation. Trading Forex and
//     CFDs involves a high risk of losing capital. Past and backtest results do not
//     guarantee future results. FxCraft is not liable for any losses resulting from
//     the use of this program.
//
// Chcesz używać EA na rachunku rzeczywistym lub go rozbudować? Napisz: https://fxcraft.biz
// Want to use the EA on a live account or extend it? Contact us: https://fxcraft.biz
//
// Zasady / Rules (czas serwera, jedna doba / server time, within one day):
//   - zakres High/Low ze świec M1 między RangeStart i RangeEnd (niezależnie od wykresu)
//     range High/Low from M1 bars between RangeStart and RangeEnd (independent of the chart)
//   - po zakończeniu zakresu, raz dziennie / after the range ends, once a day:
//       BuyStop  = High + Shift + spread, SL = Low - ShiftSL,           TP = wejście/entry + RR * (entry - SL)
//       SellStop = Low - Shift,           SL = High + ShiftSL + spread, TP = wejście/entry - RR * (SL - entry)
//   - gdy jedno zlecenie wejdzie, drugie jest kasowane; o CancelTime kasowane są niezrealizowane zlecenia
//     when one order is filled, the other is deleted; at CancelTime unfilled orders are deleted
//   - opcjonalnie zamknięcie pozycji o CloseTime / optionally the position is closed at CloseTime
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, FxCraft"
#property link        "https://fxcraft.biz"
#property version     "1.00"
#property description "Example EA from FxCraft: range breakout with pending orders (educational program)."
#property description "DEMO ACCOUNTS AND STRATEGY TESTER ONLY. Provided 'as is', without warranty."
#property description "Not investment advice. Trading Forex/CFDs involves a high risk of losing capital."
#property description "License: FxCraft Example EA License. https://fxcraft.biz"

#include <Trade\Trade.mqh>

//--- Parametry / Inputs
input group "=== Range (server time) ==="
input string InpRangeStart   = "00:00";  // Range start (HH:MM)
input string InpRangeEnd     = "07:00";  // Range end (HH:MM)
input string InpCancelTime   = "20:00";  // Delete pending orders at (HH:MM)
input bool   InpUseCloseTime = true;     // Close open position at CloseTime
input string InpCloseTime    = "22:00";  // Close time (HH:MM)
input int    InpMinRange     = 0;        // Min range width (points, 0 = no limit)
input int    InpMaxRange     = 0;        // Max range width (points, 0 = no limit)

input group "=== Orders ==="
input int    InpShift        = 20;       // Entry shift from High/Low (points)
input int    InpShiftSL      = 20;       // Stop Loss shift beyond the range (points)
input double InpRiskReward   = 1.0;      // TP RR (1 = 1:1)
input double InpLots         = 0.10;     // Lot (fixed)
input ulong  InpMagic        = 5030;     // Magic number
input int    InpSlippage     = 10;       // Max slippage (points)

input group "=== Trading days ==="
input bool   InpMonday       = true;     // Monday
input bool   InpTuesday      = true;     // Tuesday
input bool   InpWednesday    = true;     // Wednesday
input bool   InpThursday     = true;     // Thursday
input bool   InpFriday       = true;     // Friday

input group "=== Filters ==="
input int    InpMaxSpread    = 30;       // Max spread (points, 0 = off)

//--- Stałe / Constants
#define EA_NAME        "FxCraft Example RangeBreakout"
#define LABEL_TITLE    "FxCraftExample_Title"
#define LABEL_SUBTITLE "FxCraftExample_Subtitle"
#define MAX_RETRIES    3

enum ENUM_Account_State { ACC_STATE_UNKNOWN, ACC_STATE_ALLOWED, ACC_STATE_BLOCKED };

//--- Zmienne globalne / Globals
CTrade   _trade;
int      _rangeStart  = 0;   // minuty od północy / minutes from midnight
int      _rangeEnd    = 0;
int      _cancelTime  = 0;
int      _closeTime   = 0;
datetime _doneDay     = 0;   // dzień, w którym zlecenia już wystawiono lub pominięto / day already handled

//+------------------------------------------------------------------+
//| Inicjalizacja / Initialization                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // Tylko demo i tester / Demo and tester only
   if(GetAccountState() == ACC_STATE_BLOCKED)
   {
      ShowDemoOnlyMessage();
      return INIT_FAILED;
   }

   // Kontrola parametrów / Input validation
   _rangeStart = ParseTime(InpRangeStart);
   _rangeEnd   = ParseTime(InpRangeEnd);
   _cancelTime = ParseTime(InpCancelTime);
   _closeTime  = ParseTime(InpCloseTime);
   if(_rangeStart < 0 || _rangeEnd < 0 || _cancelTime < 0 || _closeTime < 0)
   {
      Log("niepoprawny format godzin (HH:MM)", "invalid time format (HH:MM)");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(_rangeStart >= _rangeEnd || _cancelTime <= _rangeEnd || (InpUseCloseTime && _closeTime <= _rangeEnd))
   {
      Log("wymagane: początek zakresu < koniec zakresu < godzina anulowania (i zamknięcia), w jednej dobie",
          "required: range start < range end < cancel time (and close time), within one day");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpLots <= 0.0 || InpShift < 0 || InpShiftSL < 0 || InpRiskReward <= 0.0 || InpMinRange < 0 ||
      InpMaxRange < 0 || (InpMaxRange > 0 && InpMaxRange < InpMinRange) || InpSlippage < 0 || InpMaxSpread < 0)
   {
      Log("niepoprawne parametry (lot > 0, RR > 0, pozostałe >= 0)", "invalid inputs (lot > 0, RR > 0, others >= 0)");
      return INIT_PARAMETERS_INCORRECT;
   }

   _trade.SetExpertMagicNumber(InpMagic);
   _trade.SetDeviationInPoints((ulong)InpSlippage);
   _trade.SetTypeFillingBySymbol(_Symbol);
   _trade.SetMarginMode();

   CreateLabels();
   Log("przykładowy program edukacyjny – wysokie ryzyko utraty kapitału, tylko rachunek demo i tester",
       "example educational program – high risk of losing capital, demo account and tester only");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Zakończenie / Deinitialization                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectDelete(0, LABEL_TITLE);
   ObjectDelete(0, LABEL_SUBTITLE);
}

//+------------------------------------------------------------------+
//| Główna pętla / Main loop                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!IsAccountOk())
      return;

   datetime now      = TimeCurrent();
   datetime dayStart = (datetime)((long)now - (long)now % 86400);   // początek doby serwera / server day start
   int      minutes  = (int)((now - dayStart) / 60);
   bool     hasPosition = CountPositions() > 0;

   // Jedno zlecenie weszło – skasuj drugie / One order filled – delete the other one
   if(hasPosition && CountPendingOrders() > 0)
   {
      Log("zlecenie zrealizowane – kasowanie drugiego zlecenia", "order filled – deleting the other order");
      DeletePendingOrders();
   }

   // Godzina anulowania zleceń / Pending order cancel time
   if(minutes >= _cancelTime && CountPendingOrders() > 0)
   {
      Log("godzina anulowania – kasowanie zleceń oczekujących", "cancel time – deleting pending orders");
      DeletePendingOrders();
   }

   // Opcjonalne zamknięcie pozycji / Optional position close
   if(InpUseCloseTime && minutes >= _closeTime && hasPosition)
   {
      Log("godzina zamknięcia – zamykanie pozycji", "close time – closing position");
      ClosePositions();
   }

   // Wystawienie zleceń raz dziennie po zakończeniu zakresu / Place orders once a day after the range ends
   if(_doneDay == dayStart || minutes < _rangeEnd || minutes >= _cancelTime)
      return;
   if(!IsTradingDay(now))
   {
      _doneDay = dayStart;
      return;
   }
   // Po restarcie: zlecenia z dzisiaj już były / After a restart: today's orders already existed
   if(hasPosition || CountPendingOrders() > 0 || HadOrdersSince(dayStart))
   {
      _doneDay = dayStart;
      return;
   }
   if(!IsSpreadOk(dayStart))
      return;   // ponowienie na kolejnym ticku (do godziny anulowania) / retry on next tick (until cancel time)

   double high, low;
   if(!GetRange(dayStart, high, low))
      return;   // dane M1 niegotowe – ponowienie / M1 data not ready – retry
   _doneDay = dayStart;
   PlaceBreakoutOrders(high, low);
}

//+------------------------------------------------------------------+
//| Zakres High/Low ze świec M1 / Range High/Low from M1 bars        |
//+------------------------------------------------------------------+
bool GetRange(datetime dayStart, double &high, double &low)
{
   datetime from = dayStart + _rangeStart * 60;
   datetime to   = dayStart + _rangeEnd * 60 - 1;   // bez świecy zaczynającej się o RangeEnd / without the bar at RangeEnd
   double highs[], lows[];
   int count = CopyHigh(_Symbol, PERIOD_M1, from, to, highs);
   if(count <= 0 || CopyLow(_Symbol, PERIOD_M1, from, to, lows) != count)
      return false;
   high = highs[ArrayMaximum(highs)];
   low  = lows[ArrayMinimum(lows)];
   return true;
}

//+------------------------------------------------------------------+
//| Wystawienie zleceń BuyStop i SellStop / Place BuyStop and SellStop |
//+------------------------------------------------------------------+
void PlaceBreakoutOrders(double high, double low)
{
   int width = (int)MathRound((high - low) / _Point);
   string rangeText = DoubleToString(low, _Digits) + " - " + DoubleToString(high, _Digits) +
                      " (" + IntegerToString(width) + " pt)";
   if((InpMinRange > 0 && width < InpMinRange) || (InpMaxRange > 0 && width > InpMaxRange))
   {
      Log("zakres " + rangeText + " poza limitem szerokości – dziś bez zleceń",
          "range " + rangeText + " outside the width limits – no orders today");
      return;
   }
   Log("zakres " + rangeText, "range " + rangeText);

   double ask    = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid    = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double spread = ask - bid;   // spread z chwili wystawienia / spread at the moment of placing

   double buyPrice  = NormalizePrice(high + InpShift * _Point + spread);
   double buySl     = NormalizePrice(low - InpShiftSL * _Point);
   double buyTp     = NormalizePrice(buyPrice + InpRiskReward * (buyPrice - buySl));
   double sellPrice = NormalizePrice(low - InpShift * _Point);
   double sellSl    = NormalizePrice(high + InpShiftSL * _Point + spread);
   double sellTp    = NormalizePrice(sellPrice - InpRiskReward * (sellSl - sellPrice));

   double minDist = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double lots    = NormalizeLots(InpLots);   // lot liczony tuż przed wystawieniem / lot calculated right before placing

   // Cena już za poziomem wybicia (luka) – ta strona jest pomijana / Price already beyond the level (gap) – side skipped
   if(buyPrice - ask > minDist)
      PlacePendingOrder(true, lots, buyPrice, buySl, buyTp, minDist);
   else
      Log("cena już powyżej poziomu BuyStop – BUY pominięty", "price already above the BuyStop level – BUY skipped");

   if(bid - sellPrice > minDist)
      PlacePendingOrder(false, lots, sellPrice, sellSl, sellTp, minDist);
   else
      Log("cena już poniżej poziomu SellStop – SELL pominięty", "price already below the SellStop level – SELL skipped");
}

bool PlacePendingOrder(bool isBuy, double lots, double price, double sl, double tp, double minDist)
{
   // SL/TP nie bliżej niż wymaga broker / SL/TP not closer than the broker minimum
   double slWanted = sl, tpWanted = tp;
   sl = isBuy ? MathMin(sl, price - minDist) : MathMax(sl, price + minDist);
   tp = isBuy ? MathMax(tp, price + minDist) : MathMin(tp, price - minDist);
   if(MathAbs(sl - slWanted) > _Point / 2 || MathAbs(tp - tpWanted) > _Point / 2)
      Log("SL/TP powiększone do minimalnej odległości brokera", "SL/TP widened to the broker minimum distance");
   sl = NormalizePrice(sl);
   tp = NormalizePrice(tp);

   if(!IsPendingLimitOk() || !IsVolumeLimitOk(isBuy, lots) || !HasEnoughMargin(isBuy, lots, price))
      return false;

   string name = isBuy ? "BuyStop" : "SellStop";
   for(int attempt = 1; attempt <= MAX_RETRIES; attempt++)
   {
      bool sent = isBuy ? _trade.BuyStop(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, EA_NAME)
                        : _trade.SellStop(lots, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, EA_NAME);
      uint retcode = _trade.ResultRetcode();
      if(sent && (retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED))
      {
         string details = name + " " + DoubleToString(lots, LotDigits()) + " @ " + DoubleToString(price, _Digits) +
                          " SL=" + DoubleToString(sl, _Digits) + " TP=" + DoubleToString(tp, _Digits);
         Log("wystawiono " + details, "placed " + details);
         return true;
      }

      string error = IntegerToString(retcode) + " (" + _trade.ResultRetcodeDescription() + ")";
      Log("błąd wystawienia " + name + " " + error + ", próba " + IntegerToString(attempt),
          name + " placing error " + error + ", attempt " + IntegerToString(attempt));
      if(!IsRetryable(retcode))
         return false;
      Sleep(500);
   }
   return false;
}

//+------------------------------------------------------------------+
//| Dni handlu / Trading days                                        |
//+------------------------------------------------------------------+
bool IsTradingDay(datetime time)
{
   MqlDateTime t;
   TimeToStruct(time, t);
   switch(t.day_of_week)
   {
      case 1: return InpMonday;
      case 2: return InpTuesday;
      case 3: return InpWednesday;
      case 4: return InpThursday;
      case 5: return InpFriday;
   }
   return false;
}

// "HH:MM" -> minuty od północy, -1 = błąd / minutes from midnight, -1 = error
int ParseTime(string text)
{
   string parts[];
   if(StringSplit(text, ':', parts) != 2)
      return -1;
   int hours   = (int)StringToInteger(parts[0]);
   int minutes = (int)StringToInteger(parts[1]);
   if(hours < 0 || hours > 23 || minutes < 0 || minutes > 59)
      return -1;
   return hours * 60 + minutes;
}

//+------------------------------------------------------------------+
//| Wolne środki / Free margin check                                 |
//+------------------------------------------------------------------+
bool HasEnoughMargin(bool isBuy, double lots, double price)
{
   double margin = 0.0;
   if(!OrderCalcMargin(isBuy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, _Symbol, lots, price, margin))
   {
      Log("błąd obliczenia depozytu " + IntegerToString(GetLastError()),
          "margin calculation error " + IntegerToString(GetLastError()));
      return false;
   }
   if(margin > AccountInfoDouble(ACCOUNT_MARGIN_FREE))
   {
      Log("za mało wolnych środków", "not enough free margin");
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| Filtr spreadu / Spread filter                                    |
//+------------------------------------------------------------------+
bool IsSpreadOk(datetime dayStart)
{
   if(InpMaxSpread <= 0)
      return true;
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread <= InpMaxSpread)
      return true;

   // komunikat raz dziennie / message once a day
   static datetime lastLogDay = 0;
   if(lastLogDay != dayStart)
   {
      lastLogDay = dayStart;
      string values = IntegerToString(spread) + " > " + IntegerToString(InpMaxSpread);
      Log("spread za wysoki: " + values + " – czekam", "spread too high: " + values + " – waiting");
   }
   return false;
}

//+------------------------------------------------------------------+
//| Pozycje i zlecenia tego EA / Positions and orders of this EA     |
//+------------------------------------------------------------------+
bool IsOwnPosition()
{
   return PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == (long)InpMagic;
}

bool IsOwnOrder()
{
   return OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == (long)InpMagic;
}

int CountPositions()
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetTicket(i) != 0 && IsOwnPosition())
         count++;
   }
   return count;
}

int CountPendingOrders()
{
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderGetTicket(i) != 0 && IsOwnOrder())
         count++;
   }
   return count;
}

// Czy EA wystawiał dziś zlecenia (historia) – po restarcie / Did the EA place orders today (history) – after a restart
bool HadOrdersSince(datetime from)
{
   if(!HistorySelect(from, TimeCurrent() + 60))
      return false;
   for(int i = HistoryOrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = HistoryOrderGetTicket(i);
      if(ticket == 0)
         continue;
      if(HistoryOrderGetString(ticket, ORDER_SYMBOL) == _Symbol &&
         HistoryOrderGetInteger(ticket, ORDER_MAGIC) == (long)InpMagic &&
         (datetime)HistoryOrderGetInteger(ticket, ORDER_TIME_SETUP) >= from)
         return true;
   }
   return false;
}

void DeletePendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0 || !IsOwnOrder())
         continue;
      if(IsOrderFrozen())
      {
         LogFrozen(ticket);
         continue;
      }
      string ticketText = "#" + IntegerToString((long)ticket);
      for(int attempt = 1; attempt <= MAX_RETRIES; attempt++)
      {
         if(_trade.OrderDelete(ticket) && _trade.ResultRetcode() == TRADE_RETCODE_DONE)
         {
            Log("skasowano zlecenie " + ticketText, "order deleted " + ticketText);
            break;
         }
         uint err = _trade.ResultRetcode();
         Log("błąd kasowania zlecenia " + ticketText + ": " + IntegerToString(err),
             "order delete error " + ticketText + ": " + IntegerToString(err));
         if(!IsRetryable(err))
            break;
         Sleep(500);
      }
   }
}

void ClosePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket != 0 && IsOwnPosition())
         ClosePositionWithRetry(ticket);
   }
}

bool ClosePositionWithRetry(ulong ticket)
{
   string ticketText = "#" + IntegerToString((long)ticket);
   // Za blisko ceny (freeze level) – bez żądania, ponowienie na kolejnym ticku
   // Too close to the market (freeze level) – no request, retry on the next tick
   if(PositionSelectByTicket(ticket) && IsPositionFrozen())
   {
      LogFrozen(ticket);
      return false;
   }
   for(int attempt = 1; attempt <= MAX_RETRIES; attempt++)
   {
      if(_trade.PositionClose(ticket, (ulong)InpSlippage))
      {
         uint retcode = _trade.ResultRetcode();
         if(retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED)
         {
            Log("zamknięto pozycję " + ticketText, "position closed " + ticketText);
            return true;
         }
      }
      uint err = _trade.ResultRetcode();
      string error = IntegerToString(err) + " (" + _trade.ResultRetcodeDescription() + ") " + ticketText;
      Log("błąd zamknięcia " + error + ", próba " + IntegerToString(attempt),
          "close error " + error + ", attempt " + IntegerToString(attempt));
      if(!IsRetryable(err))
         return false;
      Sleep(500);
   }
   return false;
}

// Błędy, przy których warto ponowić zlecenie / Errors worth retrying
bool IsRetryable(uint retcode)
{
   return retcode == TRADE_RETCODE_REQUOTE || retcode == TRADE_RETCODE_PRICE_CHANGED ||
          retcode == TRADE_RETCODE_PRICE_OFF || retcode == TRADE_RETCODE_TOO_MANY_REQUESTS;
}

//+------------------------------------------------------------------+
//| Lot i ceny / Lot and prices                                      |
//+------------------------------------------------------------------+
// Lot zaokrąglony w dół do kroku lota i przycięty do min./maks. brokera; liczba miejsc po przecinku
// z kroku lota, np. krok 0.01 -> 2, 0.05 -> 2, 0.5 -> 1, 1 -> 0, 0.001 -> 3 (0.12 przy kroku 0.05 -> 0.10).
// Lot rounded down to the lot step and clamped to broker min/max; decimal places from the lot step.
double NormalizeLots(double lots)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step   = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step > 0.0)
      lots = MathFloor(lots / step + 1e-9) * step;
   lots = MathMax(minLot, MathMin(maxLot, lots));
   return NormalizeDouble(lots, LotDigits());
}

int LotDigits()
{
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   return (step > 0.0) ? (int)MathMax(0, MathCeil(-MathLog10(step) - 1e-9)) : 2;
}

double NormalizePrice(double price)
{
   if(price <= 0.0)
      return 0.0;
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(tickSize > 0.0)
      price = MathRound(price / tickSize) * tickSize;
   return NormalizeDouble(price, _Digits);
}

//+------------------------------------------------------------------+
//| Limit wolumenu na instrumencie / Symbol volume limit             |
//+------------------------------------------------------------------+
// SYMBOL_VOLUME_LIMIT: maks. łączny wolumen pozycji i zleceń oczekujących w jednym kierunku na instrumencie
// (wszystkich, nie tylko tego EA); 0 = bez limitu.
// SYMBOL_VOLUME_LIMIT: max. total volume of positions and pending orders in one direction on the symbol
// (all of them, not only this EA's); 0 = no limit.
bool IsVolumeLimitOk(bool isBuy, double lots)
{
   double limit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);
   if(limit <= 0.0)
      return true;

   double volume = lots;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetTicket(i) == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol)
         continue;
      bool positionBuy = ((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      if(positionBuy == isBuy)
         volume += PositionGetDouble(POSITION_VOLUME);
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderGetTicket(i) == 0 || OrderGetString(ORDER_SYMBOL) != _Symbol)
         continue;
      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      bool orderBuy = (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_STOP_LIMIT);
      if(orderBuy == isBuy)
         volume += OrderGetDouble(ORDER_VOLUME_CURRENT);
   }
   if(volume <= limit + 1e-8)
      return true;

   string values = DoubleToString(volume, LotDigits()) + " > " + DoubleToString(limit, LotDigits());
   Log("przekroczony limit wolumenu na instrumencie: " + values, "symbol volume limit exceeded: " + values);
   return false;
}

// ACCOUNT_LIMIT_ORDERS: maks. liczba zleceń oczekujących na rachunku (wszystkich); 0 = bez limitu.
// ACCOUNT_LIMIT_ORDERS: max. number of pending orders on the account (all of them); 0 = no limit.
bool IsPendingLimitOk()
{
   int limit = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   if(limit <= 0 || OrdersTotal() < limit)
      return true;
   Log("osiągnięty limit zleceń oczekujących na rachunku: " + IntegerToString(limit),
       "account pending order limit reached: " + IntegerToString(limit));
   return false;
}

//+------------------------------------------------------------------+
//| Poziom zamrożenia / Freeze level                                 |
//+------------------------------------------------------------------+
// SYMBOL_TRADE_FREEZE_LEVEL: serwer nie pozwala zamknąć pozycji ani skasować zlecenia, gdy SL, TP lub cena
// zlecenia są bliżej ceny rynkowej niż poziom zamrożenia (błąd „too close to market”). EA nie wysyła wtedy
// żądania i ponawia na kolejnym ticku.
// SYMBOL_TRADE_FREEZE_LEVEL: the server rejects closing a position or deleting an order when its SL, TP or
// order price is closer to the market than the freeze level ("too close to market"). The EA does not send
// a request then and retries on the next tick.
// Komunikat raz na pozycję/zlecenie / Message once per position/order
void LogFrozen(ulong ticket)
{
   static ulong lastTicket = 0;
   if(ticket == lastTicket)
      return;
   lastTicket = ticket;
   string ticketText = "#" + IntegerToString((long)ticket);
   Log("pozycja/zlecenie " + ticketText + " za blisko ceny (freeze level) – ponowienie później",
       "position/order " + ticketText + " too close to the market (freeze level) – retry later");
}

double FreezeDistance()
{
   return (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL) * _Point;
}

// Wybrana pozycja / Selected position
bool IsPositionFrozen()
{
   double freeze = FreezeDistance();
   if(freeze <= 0.0)
      return false;
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl  = PositionGetDouble(POSITION_SL);
   double tp  = PositionGetDouble(POSITION_TP);
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return (tp > 0.0 && tp - bid < freeze) || (sl > 0.0 && bid - sl < freeze);
   return (tp > 0.0 && ask - tp < freeze) || (sl > 0.0 && sl - ask < freeze);
}

// Wybrane zlecenie oczekujące / Selected pending order
bool IsOrderFrozen()
{
   double freeze = FreezeDistance();
   if(freeze <= 0.0)
      return false;
   double bid  = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask  = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double open = OrderGetDouble(ORDER_PRICE_OPEN);
   switch((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE))
   {
      case ORDER_TYPE_BUY_STOP:   return open - ask < freeze;
      case ORDER_TYPE_SELL_STOP:  return bid - open < freeze;
      case ORDER_TYPE_BUY_LIMIT:  return ask - open < freeze;
      case ORDER_TYPE_SELL_LIMIT: return open - bid < freeze;
      default:                    return false;
   }
}

//+------------------------------------------------------------------+
//| Tylko demo i tester / Demo and tester only                       |
//+------------------------------------------------------------------+
ENUM_Account_State GetAccountState()
{
   if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION))
      return ACC_STATE_ALLOWED;
   if(AccountInfoInteger(ACCOUNT_LOGIN) == 0)
      return ACC_STATE_UNKNOWN;   // terminal jeszcze niepołączony / terminal not connected yet
   if((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO)
      return ACC_STATE_ALLOWED;
   return ACC_STATE_BLOCKED;      // rachunek rzeczywisty lub konkursowy / real or contest account
}

// Sprawdzane na każdym ticku (np. zmiana konta) / Checked on every tick (e.g. account change)
bool IsAccountOk()
{
   ENUM_Account_State state = GetAccountState();
   if(state == ACC_STATE_ALLOWED)
      return true;
   if(state == ACC_STATE_BLOCKED)
   {
      ShowDemoOnlyMessage();
      ExpertRemove();
   }
   return false;
}

void ShowDemoOnlyMessage()
{
   string message = Msg("To przykładowy EA od FxCraft – działa tylko na rachunku demo i w testerze strategii. " +
                        "Jeśli chcesz używać go na rachunku rzeczywistym lub dopasować do swoich potrzeb, " +
                        "skontaktuj się z nami: https://fxcraft.biz",
                        "This is an example EA from FxCraft – it works only on demo accounts and in the Strategy Tester. " +
                        "If you want to use it on a live account or adapt it to your needs, " +
                        "contact us: https://fxcraft.biz");
   Alert(EA_NAME, ": ", message);
   Print(EA_NAME, ": ", message);
}

//+------------------------------------------------------------------+
//| Komunikaty w języku terminalu / Messages in the terminal language |
//+------------------------------------------------------------------+
string Msg(string pl, string en)
{
   return (TerminalInfoString(TERMINAL_LANGUAGE) == "Polish") ? pl : en;
}

void Log(string pl, string en)
{
   Print(EA_NAME, ": ", Msg(pl, en));
}

//+------------------------------------------------------------------+
//| Etykieta na wykresie / Chart label                               |
//+------------------------------------------------------------------+
void CreateLabels()
{
   CreateLabel(LABEL_TITLE, "Example EA from FxCraft", 13, clrRed, 20);
   CreateLabel(LABEL_SUBTITLE, "DEMO / TESTER ONLY", 9, clrGray, 44);
}

void CreateLabel(string name, string text, int fontSize, color textColor, int yDistance)
{
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, yDistance);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetString(0, name, OBJPROP_FONT, "Arial");
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
