//+------------------------------------------------------------------+
//|                           FxCraft_Example_BollingerReversion.mq5 |
//|                    Example EA from FxCraft - https://fxcraft.biz |
//+------------------------------------------------------------------+
//
// PL: Przykładowy EA (program edukacyjny) – Bollinger Bands, powrót do średniej.
//     Działa WYŁĄCZNIE na rachunku demo i w testerze strategii.
//     Licencja: FxCraft Example EA License (plik LICENSE.txt) – bezpłatny, do nauki
//     i testów, udostępniany „tak jak jest”, bez żadnych gwarancji.
//     Program nie stanowi rekomendacji ani doradztwa inwestycyjnego. Handel na rynku
//     Forex i kontraktami CFD wiąże się z wysokim ryzykiem utraty kapitału. Wyniki
//     historyczne i wyniki z testera nie gwarantują przyszłych wyników. FxCraft nie
//     ponosi odpowiedzialności za straty wynikające z użycia programu.
//
// EN: Example EA (educational program) – Bollinger Bands, mean reversion.
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
// Zasady / Rules:
//   - BUY: świeca 2 zamknięta poniżej dolnej wstęgi, świeca 1 zamknięta z powrotem wewnątrz wstęgi
//     BUY: bar 2 closed below the lower band, bar 1 closed back inside the bands
//   - SELL: świeca 2 zamknięta powyżej górnej wstęgi, świeca 1 zamknięta z powrotem wewnątrz wstęgi
//     SELL: bar 2 closed above the upper band, bar 1 closed back inside the bands
//   - opcjonalny filtr RSI (świeca 2): BUY tylko przy RSI < poziom dolny, SELL tylko przy RSI > poziom górny
//     optional RSI filter (bar 2): BUY only if RSI < lower level, SELL only if RSI > upper level
//   - wyjście: cena dotyka bieżącej linii środkowej albo Stop Loss
//     exit: price touches the current middle line or Stop Loss
//   - godziny handlu ograniczają tylko otwieranie pozycji; maks. InpMaxPositions pozycji naraz
//     trading hours limit only opening positions; max InpMaxPositions positions at once
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, FxCraft"
#property link        "https://fxcraft.biz"
#property version     "1.00"
#property description "Example EA from FxCraft: Bollinger Bands mean reversion (educational program)."
#property description "DEMO ACCOUNTS AND STRATEGY TESTER ONLY. Provided 'as is', without warranty."
#property description "Not investment advice. Trading Forex/CFDs involves a high risk of losing capital."
#property description "License: FxCraft Example EA License. https://fxcraft.biz"

#include <Trade\Trade.mqh>

//--- Parametry / Inputs
input group "=== Signal ==="
input ENUM_TIMEFRAMES    InpTimeframe     = PERIOD_CURRENT; // TimeFrame
input int                InpBandsPeriod   = 20;             // Bollinger Bands period
input double             InpBandsDev      = 2.0;            // Bollinger Bands deviation
input ENUM_APPLIED_PRICE InpBandsPrice    = PRICE_CLOSE;    // Bollinger Bands applied price

input group "=== RSI filter ==="
input bool               InpUseRsi        = false;          // Use RSI filter
input int                InpRsiPeriod     = 14;             // RSI period
input double             InpRsiLower      = 30.0;           // RSI lower level (BUY below)
input double             InpRsiUpper      = 70.0;           // RSI upper level (SELL above)

input group "=== Trading hours (server time) ==="
input string             InpTradeStart    = "00:00";        // Trading start (HH:MM)
input string             InpTradeEnd      = "00:00";        // Trading end (HH:MM, start = end -> all day)
input bool               InpCloseOutside  = false;          // Close position outside trading hours

input group "=== Orders ==="
input double             InpLots          = 0.10;           // Lot (fixed)
input int                InpStopLoss      = 300;            // Stop Loss (points, 0 = none)
input int                InpMaxPositions  = 1;              // Max open positions at once
input ulong              InpMagic         = 5020;           // Magic number
input int                InpSlippage      = 10;             // Max slippage (points)

input group "=== Filters ==="
input int                InpMaxSpread     = 30;             // Max spread (points, 0 = off)

//--- Stałe / Constants
#define EA_NAME        "FxCraft Example BollingerReversion"
#define LABEL_TITLE    "FxCraftExample_Title"
#define LABEL_SUBTITLE "FxCraftExample_Subtitle"
#define MAX_RETRIES    3

enum ENUM_Account_State { ACC_STATE_UNKNOWN, ACC_STATE_ALLOWED, ACC_STATE_BLOCKED };
enum ENUM_Open_Result   { OPEN_OK, OPEN_RETRY_LATER, OPEN_GIVE_UP };

//--- Zmienne globalne / Globals
CTrade   _trade;
int      _bandsHandle   = INVALID_HANDLE;
int      _rsiHandle     = INVALID_HANDLE;
int      _tradeStart    = 0;   // początek handlu w minutach od północy / trading start in minutes from midnight
int      _tradeEnd      = 0;   // koniec handlu w minutach od północy / trading end in minutes from midnight
datetime _lastBarTime   = 0;   // ostatnia sprawdzona świeca / last processed bar
// Sygnał powstaje tylko na otwarciu nowej świecy. Gdy otwarcie pozycji się nie uda (spread, requote),
// EA ponawia je na kolejnych tickach, ale najdalej do końca tej świecy (_signalBarTime).
// A signal is created only at the open of a new bar. If opening fails (spread, requote), the EA retries
// on the next ticks, but no longer than until the end of that bar (_signalBarTime).
int      _signal        = 0;   // 1 = BUY, -1 = SELL, 0 = brak / none
datetime _signalBarTime = 0;   // świeca, na której powstał sygnał / bar of the pending signal

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
   _tradeStart = ParseTime(InpTradeStart);
   _tradeEnd   = ParseTime(InpTradeEnd);
   if(_tradeStart < 0 || _tradeEnd < 0)
   {
      Log("niepoprawny format godzin handlu (HH:MM)", "invalid trading hours format (HH:MM)");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpBandsPeriod < 2 || InpBandsDev <= 0.0 || InpRsiPeriod < 2 || InpRsiLower >= InpRsiUpper)
   {
      Log("niepoprawne parametry wskaźników", "invalid indicator inputs");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(InpLots <= 0.0 || InpMaxPositions < 1 || InpStopLoss < 0 || InpSlippage < 0 || InpMaxSpread < 0)
   {
      Log("niepoprawne parametry (lot > 0, maks. pozycji >= 1, pozostałe >= 0)", "invalid inputs (lot > 0, max positions >= 1, others >= 0)");
      return INIT_PARAMETERS_INCORRECT;
   }

   _bandsHandle = iBands(_Symbol, InpTimeframe, InpBandsPeriod, 0, InpBandsDev, InpBandsPrice);
   _rsiHandle   = InpUseRsi ? iRSI(_Symbol, InpTimeframe, InpRsiPeriod, PRICE_CLOSE) : INVALID_HANDLE;
   if(_bandsHandle == INVALID_HANDLE || (InpUseRsi && _rsiHandle == INVALID_HANDLE))
   {
      Log("błąd tworzenia wskaźnika " + IntegerToString(GetLastError()),
          "indicator creation error " + IntegerToString(GetLastError()));
      return INIT_FAILED;
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
   if(_bandsHandle != INVALID_HANDLE)
      IndicatorRelease(_bandsHandle);
   if(_rsiHandle != INVALID_HANDLE)
      IndicatorRelease(_rsiHandle);
}

//+------------------------------------------------------------------+
//| Główna pętla / Main loop                                         |
//+------------------------------------------------------------------+
void OnTick()
{
   if(!IsAccountOk())
      return;

   // Wyjścia: linia środkowa, koniec godzin handlu / Exits: middle line, end of trading hours
   ManagePositions();

   datetime barTime = iTime(_Symbol, InpTimeframe, 0);
   if(barTime == 0)
      return;

   // Pierwszy tick: tylko zapamiętaj świecę – EA czeka na nowy sygnał
   // First tick: remember the bar only – the EA waits for a new signal
   if(_lastBarTime == 0)
   {
      _lastBarTime = barTime;
      return;
   }

   // Nowa świeca: sprawdź sygnał na świecach zamkniętych / New bar: check signal on closed bars
   if(barTime != _lastBarTime)
   {
      int signal = 0;
      if(!ReadSignal(signal))
         return;   // dane niegotowe – ponowienie na kolejnym ticku / data not ready – retry on next tick
      _lastBarTime   = barTime;
      _signal        = signal;
      _signalBarTime = barTime;
      if(signal != 0)
         Log("sygnał " + SignalName(signal), "signal " + SignalName(signal));
   }

   // Sygnał jest ważny do końca świecy / The signal is valid until the end of the bar
   if(_signal != 0 && _signalBarTime == barTime)
      ExecuteSignal();
}

//+------------------------------------------------------------------+
//| Sygnał: 1 = BUY, -1 = SELL, 0 = brak / Signal                    |
//+------------------------------------------------------------------+
bool ReadSignal(int &signal)
{
   double upper[], lower[];
   ArraySetAsSeries(upper, true);
   ArraySetAsSeries(lower, true);
   // indeks 0 = świeca 1 (ostatnia zamknięta), indeks 1 = świeca 2
   // index 0 = bar 1 (last closed), index 1 = bar 2
   if(CopyBuffer(_bandsHandle, UPPER_BAND, 1, 2, upper) != 2 || CopyBuffer(_bandsHandle, LOWER_BAND, 1, 2, lower) != 2)
      return false;
   double close1 = iClose(_Symbol, InpTimeframe, 1);
   double close2 = iClose(_Symbol, InpTimeframe, 2);
   if(close1 <= 0.0 || close2 <= 0.0)
      return false;

   bool close1Inside = (close1 > lower[0] && close1 < upper[0]);
   signal = 0;
   if(close2 < lower[1] && close1Inside)
      signal = 1;
   else if(close2 > upper[1] && close1Inside)
      signal = -1;

   // Filtr RSI na świecy 2 / RSI filter on bar 2
   if(signal != 0 && InpUseRsi)
   {
      double rsi[];
      if(CopyBuffer(_rsiHandle, 0, 2, 1, rsi) != 1)
         return false;
      if((signal > 0 && rsi[0] >= InpRsiLower) || (signal < 0 && rsi[0] <= InpRsiUpper))
      {
         string value = DoubleToString(rsi[0], 1);
         Log("sygnał " + SignalName(signal) + " odrzucony przez filtr RSI (" + value + ")",
             "signal " + SignalName(signal) + " rejected by RSI filter (" + value + ")");
         signal = 0;
      }
   }
   return true;
}

string SignalName(int signal)
{
   return (signal > 0) ? "BUY" : "SELL";
}

// Bieżąca linia środkowa (0 = błąd) / Current middle line (0 = error)
double MiddleLine()
{
   double middle[];
   if(CopyBuffer(_bandsHandle, BASE_LINE, 0, 1, middle) != 1)
      return 0.0;
   return middle[0];
}

//+------------------------------------------------------------------+
//| Wykonanie sygnału / Signal execution                             |
//+------------------------------------------------------------------+
void ExecuteSignal()
{
   bool isBuy = (_signal > 0);

   // Maks. liczba otwartych pozycji / Max open positions at once
   if(CountPositions(POSITION_TYPE_BUY) + CountPositions(POSITION_TYPE_SELL) >= InpMaxPositions)
   {
      _signal = 0;
      return;
   }

   if(!IsWithinTradingHours())
   {
      Log("sygnał poza godzinami handlu – pominięty", "signal outside trading hours – skipped");
      _signal = 0;
      return;
   }

   // Cena musi być jeszcze po właściwej stronie linii środkowej (inaczej od razu nastąpiłoby wyjście)
   // Price must still be on the proper side of the middle line (otherwise the exit would trigger at once)
   double middle = MiddleLine();
   if(middle <= 0.0)
      return;   // ponowienie na kolejnym ticku / retry on next tick
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if((isBuy && bid >= middle) || (!isBuy && ask <= middle))
   {
      Log("cena już przy linii środkowej – sygnał pominięty", "price already at the middle line – signal skipped");
      _signal = 0;
      return;
   }

   if(!IsSpreadOk())
      return;   // ponowienie w tej świecy / retry within this bar

   ENUM_Open_Result result = OpenPosition(isBuy);
   if(result != OPEN_RETRY_LATER)
      _signal = 0;
}

//+------------------------------------------------------------------+
//| Zarządzanie pozycją / Position management                        |
//+------------------------------------------------------------------+
void ManagePositions()
{
   bool hasBuy  = CountPositions(POSITION_TYPE_BUY) > 0;
   bool hasSell = CountPositions(POSITION_TYPE_SELL) > 0;
   if(!hasBuy && !hasSell)
      return;

   // Zamknięcie poza godzinami handlu (opcjonalne) / Closing outside trading hours (optional)
   if(InpCloseOutside && !IsWithinTradingHours())
   {
      Log("koniec godzin handlu – zamknięcie pozycji", "end of trading hours – closing position");
      ClosePositions(POSITION_TYPE_BUY);
      ClosePositions(POSITION_TYPE_SELL);
      return;
   }

   // Wyjście na bieżącej linii środkowej / Exit at the current middle line
   double middle = MiddleLine();
   if(middle <= 0.0)
      return;
   if(hasBuy && SymbolInfoDouble(_Symbol, SYMBOL_BID) >= middle)
   {
      Log("cena dotknęła linii środkowej – zamknięcie BUY", "price touched the middle line – closing BUY");
      ClosePositions(POSITION_TYPE_BUY);
   }
   if(hasSell && SymbolInfoDouble(_Symbol, SYMBOL_ASK) <= middle)
   {
      Log("cena dotknęła linii środkowej – zamknięcie SELL", "price touched the middle line – closing SELL");
      ClosePositions(POSITION_TYPE_SELL);
   }
}

//+------------------------------------------------------------------+
//| Godziny handlu / Trading hours                                   |
//+------------------------------------------------------------------+
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

// Początek = koniec -> cała doba; przedział przez północ (np. 22:00-06:00) dozwolony
// Start = end -> all day; a range across midnight (e.g. 22:00-06:00) is allowed
bool IsWithinTradingHours()
{
   if(_tradeStart == _tradeEnd)
      return true;
   MqlDateTime now;
   TimeToStruct(TimeCurrent(), now);
   int minutes = now.hour * 60 + now.min;
   if(_tradeStart < _tradeEnd)
      return minutes >= _tradeStart && minutes < _tradeEnd;
   return minutes >= _tradeStart || minutes < _tradeEnd;
}

//+------------------------------------------------------------------+
//| Otwarcie pozycji rynkowej / Open a market position               |
//+------------------------------------------------------------------+
ENUM_Open_Result OpenPosition(bool isBuy)
{
   // Lot liczony tuż przed otwarciem / Lot calculated right before opening
   double lots = NormalizeLots(InpLots);

   for(int attempt = 1; attempt <= MAX_RETRIES; attempt++)
   {
      double price = isBuy ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(!IsVolumeLimitOk(isBuy, lots) || !HasEnoughMargin(isBuy, lots, price))
         return OPEN_GIVE_UP;

      double sl = CalcStopLoss(isBuy, price);
      bool sent = isBuy ? _trade.Buy(lots, _Symbol, price, sl, 0.0, EA_NAME)
                        : _trade.Sell(lots, _Symbol, price, sl, 0.0, EA_NAME);
      uint retcode = _trade.ResultRetcode();
      if(sent && (retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED))
      {
         string details = SignalName(isBuy ? 1 : -1) + " " + DoubleToString(lots, LotDigits()) +
                          " SL=" + DoubleToString(sl, _Digits);
         Log("otwarto " + details, "opened " + details);
         return OPEN_OK;
      }

      string error = IntegerToString(retcode) + " (" + _trade.ResultRetcodeDescription() + ")";
      Log("błąd otwarcia " + error + ", próba " + IntegerToString(attempt),
          "open error " + error + ", attempt " + IntegerToString(attempt));
      if(!IsRetryable(retcode))
         return OPEN_GIVE_UP;
      Sleep(500);
   }
   return OPEN_RETRY_LATER;
}

//+------------------------------------------------------------------+
//| Cena SL z kontrolą stop level / SL price with stop level check   |
//+------------------------------------------------------------------+
double CalcStopLoss(bool isBuy, double price)
{
   if(InpStopLoss <= 0)
      return 0.0;
   double minDist = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point;
   double wanted  = isBuy ? price - InpStopLoss * _Point : price + InpStopLoss * _Point;
   double sl      = isBuy ? MathMin(wanted, SymbolInfoDouble(_Symbol, SYMBOL_BID) - minDist)
                          : MathMax(wanted, SymbolInfoDouble(_Symbol, SYMBOL_ASK) + minDist);
   if(MathAbs(sl - wanted) > _Point / 2)
      Log("SL powiększony do minimalnej odległości brokera", "SL widened to the broker minimum distance");
   return NormalizePrice(sl);
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
bool IsSpreadOk()
{
   if(InpMaxSpread <= 0)
      return true;
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread <= InpMaxSpread)
      return true;

   // komunikat raz na świecę / message once per bar
   static datetime lastLogBar = 0;
   if(lastLogBar != _signalBarTime)
   {
      lastLogBar = _signalBarTime;
      string values = IntegerToString(spread) + " > " + IntegerToString(InpMaxSpread);
      Log("spread za wysoki: " + values, "spread too high: " + values);
   }
   return false;
}

//+------------------------------------------------------------------+
//| Pozycje tego EA / Positions of this EA                           |
//+------------------------------------------------------------------+
bool IsOwnPosition()
{
   return PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == (long)InpMagic;
}

int CountPositions(ENUM_POSITION_TYPE type)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      if(PositionGetTicket(i) == 0 || !IsOwnPosition())
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) == type)
         count++;
   }
   return count;
}

// true, gdy wszystkie pozycje danego typu zostały zamknięte / true when all positions of the type were closed
bool ClosePositions(ENUM_POSITION_TYPE type)
{
   bool allClosed = true;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || !IsOwnPosition())
         continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE) != type)
         continue;
      if(!ClosePositionWithRetry(ticket))
         allClosed = false;
   }
   return allClosed;
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
