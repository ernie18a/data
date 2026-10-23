//+------------------------------------------------------------------+
//|                                              GoldScalpBot.mq5 |
//|                     Autonomous XAUUSD scalper + bridge client |
//|         Author: Philippe Davenson Azor (MQL5: pipo-xdavens)   |
//|         https://www.mql5.com/en/users/pipo-xdavens              |
//+------------------------------------------------------------------+
#property copyright "Philippe Davenson Azor (pipo-xdavens)"
#property link      "https://www.mql5.com/en/users/pipo-xdavens"
#property version   "1.39"

#include <Trade/Trade.mqh>

#ifndef GOLDSCALP_EDITION_MARKET
#ifndef GOLDSCALP_SUBSCRIBE_URL
#define GOLDSCALP_SUBSCRIBE_URL "https://www.mql5.com/en/market/product/190166"
#endif
#ifndef GOLDSCALP_TRIAL_DAYS
#define GOLDSCALP_TRIAL_DAYS 7
#endif
#define GS_LIC_TRIAL_GV   "GS_TRIAL_START_V1"
#define GS_LIC_STATE_OK   0
#define GS_LIC_STATE_DEMO 1
#define GS_LIC_STATE_TRIAL 2
#define GS_LIC_STATE_SUB  3
#define GS_LIC_STATE_EXPIRED 4
#define GS_LIC_STATE_BADKEY 5

int    g_licState = GS_LIC_STATE_OK;
string g_licLabel = "OK";
string g_licHint  = "";
int    g_licDaysLeft = -1;

string GsLicenseSecret() { return "KlirlineGoldScalp2026ChangeMe"; }

int GsChecksum(const string s)
{
   uint h = 2166136261;
   int n = StringLen(s);
   for(int i = 0; i < n; i++)
   {
      h ^= (uint)StringGetCharacter(s, i);
      h *= 16777619;
   }
   return (int)(h & 0x7FFFFFFF);
}

bool GsParseLicenseKey(const string key, long &boundAccount, datetime &expires)
{
   boundAccount = 0;
   expires = 0;
   string k = key;
   StringTrimLeft(k);
   StringTrimRight(k);
   StringToUpper(k);
   StringReplace(k, " ", "");
   string parts[];
   int n = StringSplit(k, '-', parts);
   if(n != 4) return false;
   if(parts[0] != "GS1") return false;
   boundAccount = StringToInteger(parts[1]);
   if(boundAccount <= 0) return false;
   if(StringLen(parts[2]) != 8) return false;
   int y = (int)StringToInteger(StringSubstr(parts[2], 0, 4));
   int m = (int)StringToInteger(StringSubstr(parts[2], 4, 2));
   int d = (int)StringToInteger(StringSubstr(parts[2], 6, 2));
   if(y < 2026 || m < 1 || m > 12 || d < 1 || d > 31) return false;
   MqlDateTime dt;
   dt.year = y; dt.mon = m; dt.day = d;
   dt.hour = 23; dt.min = 59; dt.sec = 59;
   expires = StructToTime(dt);
   int expect = GsChecksum(IntegerToString(boundAccount) + parts[2] + GsLicenseSecret());
   int got = (int)StringToInteger(parts[3]);
   return (got == expect);
}

bool GsIsDemoAccount()
{
   return (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO);
}

bool GsIsTesterEnv()
{
   return (bool)MQLInfoInteger(MQL_TESTER) || (bool)MQLInfoInteger(MQL_OPTIMIZATION) ||
          (bool)MQLInfoInteger(MQL_FORWARD);
}

datetime GsTrialStart(const bool createIfMissing)
{
   if(GlobalVariableCheck(GS_LIC_TRIAL_GV))
      return (datetime)GlobalVariableGet(GS_LIC_TRIAL_GV);
   if(!createIfMissing) return 0;
   datetime now = TimeGMT();
   GlobalVariableSet(GS_LIC_TRIAL_GV, (double)now);
   return now;
}

int GsDaysLeft(const datetime endAt)
{
   int sec = (int)(endAt - TimeGMT());
   if(sec <= 0) return 0;
   return (int)MathCeil(sec / 86400.0);
}

void GsSetLic(const int state, const string label, const string hint, const int daysLeft = -1)
{
   g_licState = state;
   g_licLabel = label;
   g_licHint = hint;
   g_licDaysLeft = daysLeft;
}

bool GsLicenseAllowsNewTrades()
{
   return (g_licState == GS_LIC_STATE_OK ||
           g_licState == GS_LIC_STATE_DEMO ||
           g_licState == GS_LIC_STATE_TRIAL ||
           g_licState == GS_LIC_STATE_SUB);
}

string GsLicenseStatusTag()
{
   if(g_licDaysLeft >= 0)
      return g_licLabel + " " + IntegerToString(g_licDaysLeft) + "d";
   return g_licLabel;
}

void GsLicenseInit(const string licenseKey, const string subscribeUrl, const int trialDays)
{
   if(GsIsTesterEnv())
   {
      GsSetLic(GS_LIC_STATE_OK, "TESTER", "", -1);
      return;
   }
   if(GsIsDemoAccount())
   {
      GsSetLic(GS_LIC_STATE_DEMO, "DEMO+",
         "DEMO UNLIMITED — Pro only required on LIVE. " + subscribeUrl, -1);
      Print("GoldScalp DEMO UNLIMITED. Live/Pro: ", subscribeUrl);
      return;
   }
   if(licenseKey != "")
   {
      long bound = 0;
      datetime exp = 0;
      long acc = AccountInfoInteger(ACCOUNT_LOGIN);
      if(!GsParseLicenseKey(licenseKey, bound, exp))
      {
         GsSetLic(GS_LIC_STATE_BADKEY, "BADKEY", "Invalid Pro key. Buy: " + subscribeUrl);
         return;
      }
      if(bound != acc)
      {
         GsSetLic(GS_LIC_STATE_BADKEY, "ACCT",
            "Pro key bound to #" + IntegerToString(bound) + " — this account is #" + IntegerToString(acc));
         return;
      }
      if(TimeGMT() > exp)
      {
         GsSetLic(GS_LIC_STATE_EXPIRED, "EXPIRED", "Pro expired. Renew: " + subscribeUrl, 0);
         return;
      }
      GsSetLic(GS_LIC_STATE_SUB, "PRO", "Pro until " + TimeToString(exp, TIME_DATE), GsDaysLeft(exp));
      Print("GoldScalp PRO OK until ", TimeToString(exp, TIME_DATE));
      return;
   }
   int days = (trialDays > 0 ? trialDays : GOLDSCALP_TRIAL_DAYS);
   datetime start = GsTrialStart(true);
   datetime endAt = start + (datetime)days * 86400;
   int left = GsDaysLeft(endAt);
   if(left <= 0)
   {
      GsSetLic(GS_LIC_STATE_EXPIRED, "EXPIRED", "Live trial ended. Get Pro: " + subscribeUrl, 0);
      Alert("GoldScalp: live trial ended. DEMO stays unlimited. Get Pro: " + subscribeUrl);
      return;
   }
   GsSetLic(GS_LIC_STATE_TRIAL, "TRIAL",
      "Live trial " + IntegerToString(left) + "d left. Then Pro: " + subscribeUrl, left);
   Print("GoldScalp LIVE trial: ", left, "d. DEMO unlimited. Pro: ", subscribeUrl);
}
#else
// Market Rent = license. No demo/trial/account/time gates in this binary (Market rules).
bool GsLicenseAllowsNewTrades() { return true; }
string GsLicenseStatusTag() { return "RENT"; }
#endif

//--- core — designed for XAUUSD M5 (IC Markets / ECN gold)
#ifdef GOLDSCALP_EDITION_MARKET
input string InpSymbol           = "";       // empty = chart (Market validator). Live: set XAUUSD
#else
input string InpSymbol           = "XAUUSD"; // default gold; empty = use chart symbol
#endif
input ENUM_TIMEFRAMES InpTF      = PERIOD_M5;
input long   InpMagic            = 260803;
input string InpComment          = "GoldScalp";
#ifndef GOLDSCALP_EDITION_MARKET
input bool   InpUseBridge        = false; // false = MT5 seul (recommandé)
input string InpBridgeUrl        = "http://127.0.0.1:8765";
input string InpBridgeToken      = "change-me-goldscalp";
#endif
#ifdef GOLDSCALP_EDITION_MARKET
input bool   InpRequireGoldOnly  = false; // Market: never lock instrument
input bool   InpPreferGoldSymbol = false; // live: attach on XAUUSD chart (recommended)
#else
input bool   InpRequireGoldOnly  = true;  // live: XAUUSD/GOLD only (tester may use EURUSD)
input bool   InpPreferGoldSymbol = true;  // if XAUUSD missing, find GOLD / XAUUSD.a etc.
#endif
input double InpMaxSpreadGoldPts = 800;   // gold often has wider point spreads than FX

#ifndef GOLDSCALP_EDITION_MARKET
//--- Code Base / Direct only (Market uses MQL5 rental — no external key)
input group "Edition — Demo unlimited / Pro live"
input string InpLicenseKey       = "";   // Pro key GS1-account-YYYYMMDD-check (live). Empty = trial
input int    InpTrialDays        = 7;    // live trial days (demo is always unlimited)
input string InpSubscribeUrl     = "https://www.mql5.com/en/market/product/190166";
#endif

//--- risk / quick scalp (pas de day trade) — v1.27 research defaults
input double InpRiskPercent      = 0.40;  // v1.27 — 0.25–0.50% recommandé petit compte
input double InpSlAtrMult        = 0.90;
input double InpTpAtrMult        = 0.85;  // TP proche = sortie rapide
input int    InpAtrPeriod        = 14;
input double InpMaxSpreadPoints  = 350;
input int    InpMaxPositions     = 2;     // v1.27 — 2 max (≈0.8% risque total à 0.40%)
input int    InpMaxTradeMinutes  = 10;    // hard close — scalping, pas daytrade
input double InpDailyLossPct     = 2.0;   // v1.27 — stop journée 1.5–2%
input double InpFloatingDdPct    = 2.0;
input int    InpMaxTradesPerDay  = 20;    // plus d'opportunités
input int    InpMaxConsecLosses  = 3;
input int    InpWinsForScale     = 99;
input double InpLotScaleFactor   = 1.0;
input double InpMaxLotMult       = 1.0;
input double InpHardMaxLot       = 0.5;
input double InpMarginUsagePct   = 25.0;
input double InpMinLotMaxRiskPct = 5.0;  // v1.28 — petit compte: autoriser 0.01 si risque SL ≤ ce %
input double InpMinNetRR         = 0.75;

//--- strategy
input int    InpFastMa           = 9;
input int    InpSlowMa           = 21;
input int    InpMomentumBars     = 6;
input int    InpMinScore         = 55; // v1.25 test — un peu plus d'entrées
input string InpMacroSymbol      = "EURUSD";
input bool   InpUseMacroFilter   = true;
input bool   InpTradeLondon      = true;
input bool   InpTradeNewYork     = true;
input bool   InpRequireOverlap   = false; // false = Londres OU New York (pas seulement overlap)
input bool   InpAllowLondonOpen  = true;
input int    InpLondonStartHour  = 7;   // UTC
input int    InpLondonEndHour    = 16;  // UTC (exclus)
input int    InpNyStartHour      = 12;  // UTC
input int    InpNyEndHour        = 23;  // UTC (exclus) — ~19h locale UTC-4
input bool   InpNewsPause        = false; // pause manuelle
input bool   InpFlattenOnNews    = true;
input bool   InpUseCalendarNews  = true;  // calendrier économique MT5 (USD)
input int    InpNewsBeforeMin    = 20;    // un peu moins strict qu'avant
input int    InpNewsAfterMin     = 10;
input bool   InpBlockMedNews     = false; // true = bloquer aussi news MODERATE
input bool   InpHardQualityFilters = false; // false = score soft (recommandé pour tester)
input int    InpAvoidHourOpenMin = 1;     // moins de blocage en début d'heure

//--- progressive quick exits (scalp rapide + close vert)
input bool   InpUseBreakeven     = true;
input bool   InpUsePartial       = true;
input bool   InpUseTrail         = true;
input bool   InpCloseWhenGreen   = true;  // fermer dès que vert (scalp)
input int    InpGreenMinSeconds  = 20;    // attendre un peu le spread
input double InpGreenMinR        = 0.50;  // v1.27 — ≥0.5R net (évite faux "vert" spread)
input double InpGreenMinMoney    = 0.50;  // et profit $ minimum (AND avec R)
input double InpBeAtR            = 0.50;  // v1.27 — BE pas avant ~0.5R
input double InpPartialAtR       = 0.55;
input double InpPartialPct       = 50.0;
input double InpPartial2AtR      = 0.75;
input double InpPartial2Pct      = 50.0;
input double InpTrailAtR         = 0.65;
input double InpTrailAtrMult     = 0.40;
input int    InpBankProfitMinutes = 5;   // bank profit tôt (setups normaux)
input double InpBankProfitMinR   = 0.50; // v1.27 — aligné sur 0.5R
input bool   InpAllowRunners     = true; // setups forts → laisser courir (moins de risque via BE/trail)
input int    InpRunnerMinScore   = 72;   // v1.21 — plus de runners
input int    InpRunnerMaxMinutes = 28;   // durée max runner (toujours limité)
input double InpRunnerTpAtrMult  = 1.60; // TP plus large si setup fort
input double InpRunnerBeAtR      = 0.30; // sécuriser tôt
input double InpRunnerPartialAtR = 0.55; // encaisser une partie
input double InpRunnerPartialPct = 40.0;
input double InpRunnerTrailAtR   = 0.70;
input double InpRunnerTrailAtrMult = 0.50;
#ifndef GOLDSCALP_EDITION_MARKET
input int    InpBridgeMs         = 1500;
#endif
input int    InpSlippage         = 30;

//--- notifications (trades effectués)
input bool   InpNotifyOnTrade    = true;  // notifier ouverture / fermeture
input bool   InpNotifyPush       = true;  // push téléphone (MetaQuotes ID)
input bool   InpNotifyAlert      = true;  // popup MT5
input bool   InpNotifyMail       = false; // email (SMTP MT5)
input bool   InpNotifyPartial    = true;  // aussi les partials
input bool   InpNotifySound      = true;

CTrade trade;
int    atrHandle = INVALID_HANDLE;
int    fastHandle = INVALID_HANDLE;
int    slowHandle = INVALID_HANDLE;
int    htfFastHandle = INVALID_HANDLE;
int    htfSlowHandle = INVALID_HANDLE;
int    h4FastHandle = INVALID_HANDLE;
int    h4SlowHandle = INVALID_HANDLE;
int    macroFastHandle = INVALID_HANDLE;
int    macroSlowHandle = INVALID_HANDLE;

string g_symbol = "";
ENUM_TIMEFRAMES g_workTf = PERIOD_M5;
bool   g_paused = false;
bool   g_auto = true;
bool   g_newsRed = false;       // bridge / manual feed
bool   g_calendarRed = false;   // MT5 economic calendar
string g_newsReason = "";
datetime g_lastNewsCheck = 0;
int    g_consecWins = 0;
int    g_consecLosses = 0;
int    g_tradesToday = 0;
double g_dayStartEquity = 0;
int    g_dayStamp = 0;
datetime g_lastBar = 0;

int    g_lastScore = 0;
string g_lastDecision = "IDLE";
string g_lastReasons = "";
string g_lastSignal = "none";

string TradeSymbol() { return g_symbol; }

bool IsGoldSymbolName(string sym)
{
   StringToUpper(sym);
   // Strip common broker suffixes for matching: XAUUSD.a, XAUUSDm, GOLD#, etc.
   StringReplace(sym, ".", "");
   StringReplace(sym, "#", "");
   StringReplace(sym, "-", "");
   StringReplace(sym, "_", "");
   StringReplace(sym, " ", "");
   if(StringFind(sym, "XAU") >= 0) return true;
   if(StringFind(sym, "GOLD") >= 0) return true;
   return false;
}

bool IsGoldSymbol()
{
   return IsGoldSymbolName(g_symbol);
}

string FindBrokerGoldSymbol()
{
   // Prefer exact common names first (IC Markets, most ECN)
   string candidates[] = {
      "XAUUSD", "GOLD", "XAUUSDm", "XAUUSD.a", "XAUUSD.", "XAUUSD#",
      "XAUUSD.pro", "XAUUSD.i", "XAUUSD.c", "XAUUSD.s",
      "GOLD.a", "GOLDm", "XAUUSD.raw"
   };
   for(int i = 0; i < ArraySize(candidates); i++)
   {
      if(SymbolSelect(candidates[i], true))
         return candidates[i];
   }
   // Scan Market Watch for any gold-like symbol
   int total = SymbolsTotal(true);
   for(int i = 0; i < total; i++)
   {
      string s = SymbolName(i, true);
      if(IsGoldSymbolName(s) && SymbolSelect(s, true))
         return s;
   }
   total = SymbolsTotal(false);
   for(int i = 0; i < total; i++)
   {
      string s = SymbolName(i, false);
      if(IsGoldSymbolName(s) && SymbolSelect(s, true))
         return s;
   }
   return "";
}

string ResolveTradeSymbol()
{
   // Code Base / Market validators test EURUSD — always keep chart symbol in tester
   if(IsTester() || (bool)MQLInfoInteger(MQL_OPTIMIZATION))
      return _Symbol;

   // Explicit symbol (default Code Base: XAUUSD)
   if(InpSymbol != "")
   {
      if(SymbolSelect(InpSymbol, true))
         return InpSymbol;
      Print("GoldScalp: InpSymbol=", InpSymbol, " not found — searching broker gold…");
   }

   // Chart already on gold (XAUUSD, GOLD, XAUUSD.a, …)
   if(IsGoldSymbolName(_Symbol))
   {
      SymbolSelect(_Symbol, true);
      return _Symbol;
   }

   if(InpPreferGoldSymbol)
   {
      string gold = FindBrokerGoldSymbol();
      if(gold != "")
      {
         Print("GoldScalp: chart=", _Symbol, " → trading ", gold);
         return gold;
      }
   }

   // Last resort: common IC Markets / ECN gold names
   string fallbacks[] = {"XAUUSD", "GOLD", "XAUUSD.a", "XAUUSDm"};
   for(int i = 0; i < ArraySize(fallbacks); i++)
   {
      if(SymbolSelect(fallbacks[i], true))
      {
         Print("GoldScalp: using gold symbol ", fallbacks[i]);
         return fallbacks[i];
      }
   }

   return _Symbol;
}

double EffectiveMaxSpreadPoints()
{
   if(IsGoldSymbol() && InpMaxSpreadGoldPts > 0)
      return MathMax(InpMaxSpreadPoints, InpMaxSpreadGoldPts);
   return InpMaxSpreadPoints;
}

void NotifyTrade(const string title, const string body)
{
   if(!InpNotifyOnTrade || IsTester()) return;
   string msg = "GoldScalp " + title + ": " + body;
   Print(msg);
   if(InpNotifyAlert)
      Alert(msg);
   if(InpNotifyPush)
   {
      if(!SendNotification(msg))
         Print("GoldScalp Notify push failed — set MetaQuotes ID in Tools > Options > Notifications");
   }
   if(InpNotifyMail)
      SendMail("GoldScalp " + title, msg);
   if(InpNotifySound)
      PlaySound("alert.wav");
}

bool NewsBlocked()
{
   return (InpNewsPause || g_newsRed || g_calendarRed);
}

void RefreshCalendarNews()
{
   if(!InpUseCalendarNews)
   {
      g_calendarRed = false;
      return;
   }
   if(!IsTester() && (TimeCurrent() - g_lastNewsCheck) < 20 && g_lastNewsCheck > 0)
      return;
   g_lastNewsCheck = TimeCurrent();

   datetime now = TimeGMT();
   datetime from = now - (datetime)InpNewsAfterMin * 60;
   datetime to   = now + (datetime)InpNewsBeforeMin * 60;

   MqlCalendarValue values[];
   int n = CalendarValueHistory(values, from, to, NULL, "USD");
   bool red = false;
   string reason = "";

   for(int i = 0; i < n; i++)
   {
      MqlCalendarEvent ev;
      if(!CalendarEventById(values[i].event_id, ev)) continue;

      if(ev.importance < CALENDAR_IMPORTANCE_HIGH)
      {
         if(!(InpBlockMedNews && ev.importance >= CALENDAR_IMPORTANCE_MODERATE))
            continue;
      }

      datetime et = (datetime)values[i].time;
      if(et < from || et > to) continue;

      red = true;
      reason = ev.name;
      break;
   }

   g_calendarRed = red;
   if(red)
      g_newsReason = reason;
   else if(!g_newsRed)
      g_newsReason = "";
}

bool IsTester()
{
   return (bool)MQLInfoInteger(MQL_TESTER) || (bool)MQLInfoInteger(MQL_OPTIMIZATION) ||
          (bool)MQLInfoInteger(MQL_FORWARD);
}

double MinStopDistance()
{
   string sym = TradeSymbol();
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   if(point <= 0) return 0;
   int stops = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_STOPS_LEVEL);
   int freeze = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double spread = MathMax(0.0, ask - bid);
   // Market validator: "close to market" if SL/TP inside stops/freeze — pad aggressively
   int level = MathMax(stops, freeze);
   int pad = MathMax(10, level);
   double levelDist = (double)(level + pad) * point;
   return MathMax(levelDist, spread * 3.0 + 10.0 * point);
}

bool BuildStops(const bool isBuy, const double slDist, const double tpDist, double &sl, double &tp)
{
   string sym = TradeSymbol();
   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double minDist = MinStopDistance();
   double useSl = MathMax(slDist, minDist);
   double useTp = MathMax(tpDist, minDist);

   if(isBuy)
   {
      sl = NormalizeDouble(bid - useSl, digits);
      tp = NormalizeDouble(ask + useTp, digits);
      if(sl > bid - minDist || tp < ask + minDist) return false;
   }
   else
   {
      sl = NormalizeDouble(ask + useSl, digits);
      tp = NormalizeDouble(bid - useTp, digits);
      if(sl < ask + minDist || tp > bid - minDist) return false;
   }
   return (sl > 0 && tp > 0);
}

bool PositionNearFreeze(const ulong ticket)
{
   if(!PositionSelectByTicket(ticket)) return true;
   string sym = PositionGetString(POSITION_SYMBOL);
   int freeze = (int)SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL);
   if(freeze <= 0) return false;
   double point = SymbolInfoDouble(sym, SYMBOL_POINT);
   if(point <= 0) return false;
   double minDist = freeze * point;
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double sl = PositionGetDouble(POSITION_SL);
   double tp = PositionGetDouble(POSITION_TP);
   long type = PositionGetInteger(POSITION_TYPE);
   double price = (type == POSITION_TYPE_BUY ? bid : ask);
   if(sl > 0 && MathAbs(price - sl) <= minDist) return true;
   if(tp > 0 && MathAbs(price - tp) <= minDist) return true;
   return false;
}

// Market validator rejects repeated failed PositionModify (invalid stops / no change).
datetime g_modFailAt = 0;
ulong    g_modFailTicket = 0;

bool StopsLevelsOk(const bool isBuy, const double sl, const double tp)
{
   string sym = TradeSymbol();
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ask = SymbolInfoDouble(sym, SYMBOL_ASK);
   double minDist = MinStopDistance();
   if(bid <= 0 || ask <= 0 || minDist <= 0) return false;

   if(sl > 0)
   {
      if(isBuy)
      {
         if(sl >= bid - minDist) return false;
      }
      else
      {
         if(sl <= ask + minDist) return false;
      }
   }
   if(tp > 0)
   {
      if(isBuy)
      {
         if(tp <= ask + minDist) return false;
      }
      else
      {
         if(tp >= bid - minDist) return false;
      }
   }
   return true;
}

bool LevelsActuallyChange(const double curSl, const double curTp, const double newSl, const double newTp)
{
   double point = SymbolInfoDouble(TradeSymbol(), SYMBOL_POINT);
   if(point <= 0) point = 0.00001;
   const double eps = point * 0.5;
   const bool slChanged = (MathAbs(curSl - newSl) > eps);
   const bool tpChanged = (MathAbs(curTp - newTp) > eps);
   return (slChanged || tpChanged);
}

bool SafePositionModify(const ulong ticket, double newSl, double newTp)
{
   if(ticket == 0) return false;
   if(PositionNearFreeze(ticket)) return false;
   if(g_modFailTicket == ticket && g_modFailAt > 0 && (TimeCurrent() - g_modFailAt) < 8)
      return false;
   if(!PositionSelectByTicket(ticket)) return false;

   string sym = PositionGetString(POSITION_SYMBOL);
   int digits = (int)SymbolInfoInteger(sym, SYMBOL_DIGITS);
   long type = PositionGetInteger(POSITION_TYPE);
   double curSl = PositionGetDouble(POSITION_SL);
   double curTp = PositionGetDouble(POSITION_TP);
   newSl = NormalizeDouble(newSl, digits);
   newTp = NormalizeDouble(newTp, digits);

   if(!LevelsActuallyChange(curSl, curTp, newSl, newTp))
      return false;
   if(!StopsLevelsOk(type == POSITION_TYPE_BUY, newSl, newTp))
      return false;

   EnsureFilling(sym);
   if(!trade.PositionModify(ticket, newSl, newTp))
   {
      g_modFailTicket = ticket;
      g_modFailAt = TimeCurrent();
      return false;
   }
   const uint rc = trade.ResultRetcode();
   if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL && rc != TRADE_RETCODE_PLACED)
   {
      g_modFailTicket = ticket;
      g_modFailAt = TimeCurrent();
      return false;
   }
   if(g_modFailTicket == ticket)
   {
      g_modFailTicket = 0;
      g_modFailAt = 0;
   }
   return true;
}

int DayStamp()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return dt.year * 10000 + dt.mon * 100 + dt.day;
}

void SyncDayRisk()
{
   int today = DayStamp();
   if(today != g_dayStamp)
   {
      g_dayStamp = today;
      g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      g_consecWins = 0;
      g_consecLosses = 0;
      g_tradesToday = 0;
   }
}

bool DailyLossHit()
{
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double ddPct = 100.0 * (g_dayStartEquity - eq) / MathMax(g_dayStartEquity, 1.0);
   return ddPct >= InpDailyLossPct;
}

bool FloatingDdHit()
{
   if(InpFloatingDdPct <= 0) return false;
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   double ddPct = 100.0 * (g_dayStartEquity - eq) / MathMax(g_dayStartEquity, 1.0);
   return ddPct >= InpFloatingDdPct;
}

bool InLondonOpen()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   return (dt.hour >= InpLondonStartHour && dt.hour < MathMin(InpLondonStartHour + 3, InpLondonEndHour));
}

bool SessionOk()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   int h = dt.hour;
   if(dt.day_of_week == 5 && h >= 18) return false;

   bool london = InpTradeLondon && h >= InpLondonStartHour && h < InpLondonEndHour;
   bool ny = InpTradeNewYork && h >= InpNyStartHour && h < InpNyEndHour;
   if(InpRequireOverlap)
   {
      if(london && ny) return true;
      // secondary: London open only when HTF not flat (checked later with signal)
      if(InpAllowLondonOpen && InLondonOpen() && london) return true;
      return false;
   }
   return london || ny;
}

bool InOverlap()
{
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   int h = dt.hour;
   return (h >= MathMax(InpLondonStartHour, InpNyStartHour) &&
           h < MathMin(InpLondonEndHour, InpNyEndHour) &&
           InpTradeLondon && InpTradeNewYork);
}

string SessionTag()
{
   if(InOverlap()) return "overlap";
   if(InLondonOpen()) return "london_open";
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   if(InpTradeNewYork && dt.hour >= InpNyStartHour && dt.hour < InpNyEndHour) return "ny";
   return "session";
}

string SessionLabel()
{
   if(!SessionOk()) return "CLOSED";
   if(InOverlap()) return "OVERLAP";
   if(InLondonOpen()) return "LONDON_OPEN";
   MqlDateTime dt;
   TimeToStruct(TimeGMT(), dt);
   if(InpTradeNewYork && dt.hour >= InpNyStartHour && dt.hour < InpNyEndHour) return "NEW_YORK";
   if(InpTradeLondon && dt.hour >= InpLondonStartHour && dt.hour < InpLondonEndHour) return "LONDON";
   return "SESSION";
}

#define GS_STATUS "GS_STATUS"

void EnsureStatusPanel()
{
   // cleanup old multi-line / black-box objects
   ObjectDelete(0, "GS_L1");
   ObjectDelete(0, "GS_L2");
   ObjectDelete(0, "GS_L3");
   ObjectDelete(0, "GS_L4");
   ObjectDelete(0, "GS_PANEL_BG");
   ObjectDelete(0, "GS_PANEL_TXT");

   if(ObjectFind(0, GS_STATUS) >= 0) return;
   ObjectCreate(0, GS_STATUS, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_XDISTANCE, 10);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_YDISTANCE, 18);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_COLOR, clrBlack);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_FONTSIZE, 9);
   ObjectSetString(0, GS_STATUS, OBJPROP_FONT, "Arial");
   ObjectSetInteger(0, GS_STATUS, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_BACK, false);
}

void DeleteStatusPanel()
{
   ObjectDelete(0, GS_STATUS);
   ObjectDelete(0, "GS_L1");
   ObjectDelete(0, "GS_L2");
   ObjectDelete(0, "GS_L3");
   ObjectDelete(0, "GS_L4");
   ObjectDelete(0, "GS_PANEL_BG");
   ObjectDelete(0, "GS_PANEL_TXT");
}

string StatusBlockTag(const string reasons)
{
   if(reasons == "" || reasons == "init_ok") return "wait";

   // Exact / unambiguous block codes only (avoid matching "spread_ok")
   if(reasons == "algo_blocked" || StringFind(reasons, "algo_trading_blocked") >= 0)
      return "algo_blocked";
   if(reasons == "lot0" || StringFind(reasons, "lot0;") >= 0 || StringFind(reasons, ";lot0") >= 0)
      return "lot0";
   if(reasons == "rr_fail" || StringFind(reasons, "rr_fail;") >= 0)
      return "rr_fail";
   if(reasons == "spread" || StringFind(reasons, "spread_pre_send") >= 0 || StringFind(reasons, "spread_veto") >= 0)
      return "spread";
   if(reasons == "stops_fail" || StringFind(reasons, "stops_fail;") >= 0)
      return "stops_fail";
   if(reasons == "order_fail" || StringFind(reasons, "order_fail;") >= 0)
      return "order_fail";
   if(StringFind(reasons, "news_pause") >= 0)
      return "news";
   if(reasons == "session_closed") return "session";
   if(reasons == "no_entry_signal" || reasons == "no_signal") return "no_signal";
   if(StringFind(reasons, "sub_required") >= 0) return "subscribe";
   if(reasons == "daily_loss") return "daily_loss";
   if(reasons == "floating_dd") return "float_dd";
   if(reasons == "max_consec_losses") return "consec_loss";
   if(reasons == "max_trades_day") return "max_trades";
   if(reasons == "max_positions") return "max_pos";
   if(reasons == "hour_open_risk") return "hour_open";
   if(reasons == "atr0") return "atr0";
   if(reasons == "htf_against_hard") return "htf_hard";
   if(reasons == "vol_bad_hard") return "vol_hard";
   if(reasons == "midrange_hard") return "mid_hard";
   if(StringFind(reasons, "same_bar") >= 0) return "same_bar";

   // On GO, show a compact quality tag instead of long score dump
   if(StringFind(reasons, "htf_align") >= 0 && StringFind(reasons, "structure(+10)") >= 0)
      return "htf+structure";
   if(StringFind(reasons, "htf_align") >= 0)
      return "htf_ok";
   if(StringFind(reasons, "htf_against") >= 0)
      return "htf_soft";
   if(StringLen(reasons) > 28)
      return StringSubstr(reasons, 0, 25) + "...";
   return reasons;
}

void UpdateChartStatus()
{
   string mode = (!g_auto ? "OFF" : (g_paused || NewsBlocked() ? "PAUSE" : "AUTO"));
   // Algo terminal/EA flags (visible even when AUTO)
   if(mode == "AUTO")
   {
      if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
         mode = "ALGO_OFF";
   }
   string news = (NewsBlocked()
      ? ("NEWS:" + (g_newsReason == "" ? "block" : g_newsReason))
      : "ok");

   // Prefer short block codes so the user always sees WHY (lot0 / rr_fail / algo…)
   string reason = StatusBlockTag(g_lastReasons);
   if(StringLen(news) > 20)
      news = StringSubstr(news, 0, 17) + "...";

   string line = StringFormat(
      "GoldScalp v1.39 %s | %s | %s | %s s%d %s | %d/%d | %s | %s",
      mode,
      GsLicenseStatusTag(),
      SessionLabel(),
      g_lastDecision,
      g_lastScore,
      g_lastSignal,
      g_tradesToday,
      InpMaxTradesPerDay,
      news,
      reason
   );

   Comment("");
   EnsureStatusPanel();
   ObjectSetString(0, GS_STATUS, OBJPROP_TEXT, line);
   ObjectSetInteger(0, GS_STATUS, OBJPROP_COLOR, clrBlack);
   ChartRedraw(0);
}

double SpreadPoints()
{
   double ask = SymbolInfoDouble(TradeSymbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(TradeSymbol(), SYMBOL_BID);
   double point = SymbolInfoDouble(TradeSymbol(), SYMBOL_POINT);
   if(point <= 0) return 999999;
   return (ask - bid) / point;
}

int CountOurPositions()
{
   int n = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != TradeSymbol()) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      n++;
   }
   return n;
}

double AtrValue(int shift)
{
   double buf[];
   if(CopyBuffer(atrHandle, 0, shift, 1, buf) < 1) return 0;
   return buf[0];
}

double AtrAvg(int bars)
{
   double sum = 0;
   int n = 0;
   for(int i = 1; i <= bars; i++)
   {
      double v = AtrValue(i);
      if(v > 0) { sum += v; n++; }
   }
   return (n > 0 ? sum / n : 0);
}

//+------------------------------------------------------------------+
int OnInit()
{
   g_symbol = ResolveTradeSymbol();
   if(!SymbolSelect(g_symbol, true))
   {
      Print("GoldScalp: cannot select symbol ", g_symbol);
      return INIT_FAILED;
   }
   if(InpRequireGoldOnly && !IsGoldSymbolName(g_symbol))
   {
      // Code Base / Market validators test EURUSD — never INIT_FAILED in tester
      if(IsTester())
      {
         Print("GoldScalp WARNING: tester chart=", g_symbol,
               " — strategy designed for XAUUSD/GOLD. Continuing for validation.");
      }
#ifdef GOLDSCALP_EDITION_MARKET
      else
      {
         Print("GoldScalp WARNING: chart=", g_symbol,
               " — strategy designed for XAUUSD/GOLD M5. Trading continues (Market rules).");
      }
#else
      else
      {
         Print("GoldScalp REFUSED: chart=", g_symbol,
               " — attach on XAUUSD (or gold) M5 only. Set InpRequireGoldOnly=false to override.");
         return INIT_FAILED;
      }
#endif
   }
   if(InpTF != PERIOD_M5 && !IsTester())
      Print("GoldScalp WARNING: InpTF=", EnumToString(InpTF), " — strategy designed for M5");
   // Tester/Market validation often runs H1 — use chart TF so ATR/stops aren't tiny M5 distances
   g_workTf = InpTF;
   if(IsTester())
      g_workTf = (ENUM_TIMEFRAMES)Period();
   if(InpUseMacroFilter && InpMacroSymbol != "")
      SymbolSelect(InpMacroSymbol, true);

   trade.SetExpertMagicNumber((int)InpMagic);
   // Gold needs more slippage room than FX (points scale differs by broker digits)
   int slip = InpSlippage;
   if(IsGoldSymbol())
      slip = MathMax(InpSlippage, 100);
   trade.SetDeviationInPoints(slip);
   EnsureFilling(g_symbol);

   atrHandle  = iATR(g_symbol, g_workTf, InpAtrPeriod);
   fastHandle = iMA(g_symbol, g_workTf, InpFastMa, 0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(g_symbol, g_workTf, InpSlowMa, 0, MODE_EMA, PRICE_CLOSE);
   htfFastHandle = iMA(g_symbol, PERIOD_H1, InpFastMa, 0, MODE_EMA, PRICE_CLOSE);
   htfSlowHandle = iMA(g_symbol, PERIOD_H1, InpSlowMa, 0, MODE_EMA, PRICE_CLOSE);
   h4FastHandle = iMA(g_symbol, PERIOD_H4, InpFastMa, 0, MODE_EMA, PRICE_CLOSE);
   h4SlowHandle = iMA(g_symbol, PERIOD_H4, InpSlowMa, 0, MODE_EMA, PRICE_CLOSE);

   if(InpUseMacroFilter && InpMacroSymbol != "")
   {
      macroFastHandle = iMA(InpMacroSymbol, PERIOD_H1, InpFastMa, 0, MODE_EMA, PRICE_CLOSE);
      macroSlowHandle = iMA(InpMacroSymbol, PERIOD_H1, InpSlowMa, 0, MODE_EMA, PRICE_CLOSE);
   }

   if(atrHandle == INVALID_HANDLE || fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE ||
      htfFastHandle == INVALID_HANDLE || htfSlowHandle == INVALID_HANDLE ||
      h4FastHandle == INVALID_HANDLE || h4SlowHandle == INVALID_HANDLE)
   {
      Print("GoldScalp: indicator init failed");
      return INIT_FAILED;
   }

   g_dayStartEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_dayStamp = DayStamp();
#ifndef GOLDSCALP_EDITION_MARKET
   GsLicenseInit(InpLicenseKey, InpSubscribeUrl, InpTrialDays);
#endif
   // Timer: bridge heartbeat and/or calendar news refresh
   if(!IsTester())
   {
#ifdef GOLDSCALP_EDITION_MARKET
      EventSetMillisecondTimer(5000);
#else
      EventSetMillisecondTimer(MathMax(500, InpUseBridge ? InpBridgeMs : 5000));
#endif
   }
   RefreshCalendarNews();
   Print("GoldScalpBot v1.39 Symbol=", g_symbol,
         " Gold=", (IsGoldSymbol() ? "YES" : "no"),
         " TF=", EnumToString(g_workTf),
         " Risk%=", InpRiskPercent,
         " MaxPos=", InpMaxPositions,
         " DailyLoss%=", InpDailyLossPct,
         " GreenMinR=", InpGreenMinR,
         " MaxMin=", InpMaxTradeMinutes,
         " RunnerScore>=", InpRunnerMinScore,
         " Notify=", (InpNotifyOnTrade ? "ON" : "OFF"),
         " TP=", InpTpAtrMult, "xATR",
         " MinScore=", InpMinScore,
         " CloseGreen=", (InpCloseWhenGreen ? "ON" : "OFF"),
         " CalendarNews=", (InpUseCalendarNews ? "ON" : "OFF"),
#ifdef GOLDSCALP_EDITION_MARKET
         " Bridge=OFF (Market)",
#else
         " Bridge=", (InpUseBridge ? "ON" : "OFF (MT5-only)"),
#endif
         " Overlap=", (InpRequireOverlap ? "required" : "optional"),
         " License=", GsLicenseStatusTag(),
         " Algo=", (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ? "OK" : "BLOCKED"),
         " EA_trade=", (MQLInfoInteger(MQL_TRADE_ALLOWED) ? "OK" : "BLOCKED"));
   g_lastDecision = "IDLE";
   g_lastReasons = "init_ok";
   UpdateChartStatus();
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   Comment("");
   DeleteStatusPanel();
   if(atrHandle != INVALID_HANDLE) IndicatorRelease(atrHandle);
   if(fastHandle != INVALID_HANDLE) IndicatorRelease(fastHandle);
   if(slowHandle != INVALID_HANDLE) IndicatorRelease(slowHandle);
   if(htfFastHandle != INVALID_HANDLE) IndicatorRelease(htfFastHandle);
   if(htfSlowHandle != INVALID_HANDLE) IndicatorRelease(htfSlowHandle);
   if(h4FastHandle != INVALID_HANDLE) IndicatorRelease(h4FastHandle);
   if(h4SlowHandle != INVALID_HANDLE) IndicatorRelease(h4SlowHandle);
   if(macroFastHandle != INVALID_HANDLE) IndicatorRelease(macroFastHandle);
   if(macroSlowHandle != INVALID_HANDLE) IndicatorRelease(macroSlowHandle);
}

void OnTimer()
{
   if(IsTester()) return;
   SyncDayRisk();
   RefreshCalendarNews();
#ifndef GOLDSCALP_EDITION_MARKET
   if(InpUseBridge)
   {
      BridgePullCommands();
      BridgePushState();
   }
#endif
   UpdateChartStatus();
}

//+------------------------------------------------------------------+
//| HTF / macro bias                                                  |
//+------------------------------------------------------------------+
int MaBias(int fastH, int slowH)
{
   double f[], s[];
   ArraySetAsSeries(f, true);
   ArraySetAsSeries(s, true);
   if(CopyBuffer(fastH, 0, 0, 3, f) < 3) return 0;
   if(CopyBuffer(slowH, 0, 0, 3, s) < 3) return 0;
   // closed bar [1]
   if(f[1] > s[1] && f[1] >= f[2]) return 1;
   if(f[1] < s[1] && f[1] <= f[2]) return -1;
   if(f[1] > s[1]) return 1;
   if(f[1] < s[1]) return -1;
   return 0;
}

int HtfBias()
{
   int h1 = MaBias(htfFastHandle, htfSlowHandle);
   int h4 = MaBias(h4FastHandle, h4SlowHandle);
   if(h1 == 0 && h4 == 0) return 0;
   if(h1 != 0 && h4 != 0 && h1 != h4) return 0; // conflict
   return (h1 != 0 ? h1 : h4);
}

// EURUSD up ≈ dollar soft ≈ gold-friendly; return +1 gold-bullish macro, -1 gold-bearish
int MacroBiasGold()
{
   if(!InpUseMacroFilter || macroFastHandle == INVALID_HANDLE) return 0;
   int eur = MaBias(macroFastHandle, macroSlowHandle);
   return eur; // EURUSD bullish → gold bias bullish
}

int EntrySignal()
{
   double fast[3], slow[3];
   double close[], high[], low[];
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   if(CopyBuffer(fastHandle, 0, 0, 3, fast) < 3) return 0;
   if(CopyBuffer(slowHandle, 0, 0, 3, slow) < 3) return 0;
   int need = InpMomentumBars + 2;
   if(CopyClose(TradeSymbol(), g_workTf, 0, need, close) < need) return 0;
   if(CopyHigh(TradeSymbol(), g_workTf, 0, need, high) < need) return 0;
   if(CopyLow(TradeSymbol(), g_workTf, 0, need, low) < need) return 0;

   double mom = close[1] - close[InpMomentumBars];
   bool bullCross = fast[2] <= slow[2] && fast[1] > slow[1];
   bool bearCross = fast[2] >= slow[2] && fast[1] < slow[1];
   bool bullTrend = fast[1] > slow[1] && mom > 0;
   bool bearTrend = fast[1] < slow[1] && mom < 0;

   double hh = high[2], ll = low[2];
   for(int i = 2; i <= InpMomentumBars; i++)
   {
      if(high[i] > hh) hh = high[i];
      if(low[i] < ll) ll = low[i];
   }
   bool breakUp = high[1] >= hh && close[1] > close[2];
   bool breakDn = low[1] <= ll && close[1] < close[2];

   if(bullCross || (bullTrend && breakUp)) return 1;
   if(bearCross || (bearTrend && breakDn)) return -1;
   return 0;
}

bool StructureOk(const int signal)
{
   double high[], low[], close[];
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int n = 20;
   if(CopyHigh(TradeSymbol(), g_workTf, 0, n, high) < n) return true;
   if(CopyLow(TradeSymbol(), g_workTf, 0, n, low) < n) return true;
   if(CopyClose(TradeSymbol(), g_workTf, 0, n, close) < n) return true;

   double hh = high[1], ll = low[1];
   for(int i = 1; i < n; i++)
   {
      if(high[i] > hh) hh = high[i];
      if(low[i] < ll) ll = low[i];
   }
   double range = hh - ll;
   if(range <= 0) return true;
   double pos = (close[1] - ll) / range;
   // avoid mid-range chop (narrower band = fewer false blocks)
   if(pos > 0.45 && pos < 0.55) return false;
   if(signal > 0 && pos < 0.45) return false;
   if(signal < 0 && pos > 0.55) return false;
   return true;
}

bool VolOk(double atr)
{
   double avg = AtrAvg(20);
   if(avg <= 0) return true;
   double ratio = atr / avg;
   if(ratio < 0.55) return false; // too quiet
   if(ratio > 2.2) return false;  // spike / news chaos
   return true;
}

bool NetRrOk(const double slDist, const double tpDist)
{
   if(slDist <= 0) return false;
   double rr = tpDist / slDist;
   // approximate spread cost in R
   double point = SymbolInfoDouble(TradeSymbol(), SYMBOL_POINT);
   double spread = SpreadPoints() * point;
   double costR = spread / slDist;
   return (rr - costR) >= InpMinNetRR;
}

int BuildPreTradeScore(const int signal, const double atr, string &reasons)
{
   int score = 50;
   reasons = "";

   if(signal == 0)
   {
      reasons = "no_signal";
      return 0;
   }

   // HTF — soft penalties (no hard veto by default in v1.25)
   int htf = HtfBias();
   if(htf == signal) { score += 20; reasons += "htf_align(+20);"; }
   else if(htf == 0) { score += 5; reasons += "htf_flat(+5);"; }
   else { score -= 15; reasons += "htf_against(-15);"; }

   // Macro (EURUSD proxy)
   if(InpUseMacroFilter)
   {
      int mac = MacroBiasGold();
      if(mac == signal) { score += 15; reasons += "macro_align(+15);"; }
      else if(mac == 0) { score += 0; reasons += "macro_flat(0);"; }
      else { score -= 10; reasons += "macro_against(-10);"; }
   }

   // Volatility
   if(VolOk(atr)) { score += 10; reasons += "vol_ok(+10);"; }
   else { score -= 12; reasons += "vol_bad(-12);"; }

   // Spread
   double sp = SpreadPoints();
   double maxSp = EffectiveMaxSpreadPoints();
   if(sp > maxSp) { score -= 40; reasons += "spread_veto(-40);"; }
   else if(sp < maxSp * 0.5) { score += 10; reasons += "spread_tight(+10);"; }
   else { score += 3; reasons += "spread_ok(+3);"; }

   // Session
   if(InOverlap()) { score += 10; reasons += "overlap(+10);"; }
   else if(InpAllowLondonOpen && InLondonOpen())
   {
      if(htf == signal) { score += 6; reasons += "london_htf(+6);"; }
      else { score -= 15; reasons += "london_no_htf(-15);"; }
   }
   else if(SessionOk()) { score += 3; reasons += "session(+3);"; }
   else { score -= 20; reasons += "session_bad(-20);"; }

   // News
   if(NewsBlocked()) { score -= 50; reasons += "news_red(-50);"; }
   else { score += 5; reasons += "news_clear(+5);"; }

   // Structure
   if(StructureOk(signal)) { score += 10; reasons += "structure(+10);"; }
   else { score -= 8; reasons += "midrange(-8);"; }

   if(score < 0) score = 0;
   if(score > 100) score = 100;
   return score;
}

double NormalizeLot(double lot)
{
   string sym = TradeSymbol();
   double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   if(minLot <= 0) minLot = 0.01;
   if(step <= 0) step = minLot;
   if(maxLot <= 0) maxLot = 100.0;
   if(InpHardMaxLot > 0) maxLot = MathMin(maxLot, InpHardMaxLot);

   if(lot < minLot)
      return 0;

   // Floor to step, then re-normalize — avoid float dust that Market flags as Invalid volume
   double steps = MathFloor((lot / step) + 1e-12);
   lot = steps * step;
   int digits = (int)MathCeil(MathMax(0.0, -MathLog10(step) - 1e-12));
   if(digits > 8) digits = 8;
   lot = NormalizeDouble(lot, digits);

   if(lot < minLot - 1e-12) return 0;
   if(lot > maxLot) lot = NormalizeDouble(MathFloor(maxLot / step) * step, digits);

   // Final multiple check (article 2555)
   double ratio = lot / step;
   if(MathAbs(ratio - MathRound(ratio)) > 1e-7)
      lot = NormalizeDouble(MathRound(ratio) * step, digits);

   if(lot < minLot - 1e-12 || lot > maxLot + 1e-12) return 0;
   return lot;
}

bool IsVolumeValid(const double volume)
{
   string sym = TradeSymbol();
   double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   if(minLot <= 0) minLot = 0.01;
   if(step <= 0) step = minLot;
   if(maxLot <= 0) maxLot = 100.0;
   if(volume < minLot - 1e-12) return false;
   if(volume > maxLot + 1e-12) return false;
   int ratio = (int)MathRound(volume / step);
   return (MathAbs(ratio * step - volume) <= 0.0000001);
}

bool IsNettingAccount()
{
   long mode = AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   return (mode == ACCOUNT_MARGIN_MODE_RETAIL_NETTING ||
           mode == ACCOUNT_MARGIN_MODE_EXCHANGE);
}

void EnsureFilling(const string sym)
{
   if(!trade.SetTypeFillingBySymbol(sym))
      trade.SetTypeFilling(ORDER_FILLING_RETURN);
}

datetime g_closeFailAt = 0;
ulong    g_closeFailTicket = 0;

bool SafePositionClose(const ulong ticket)
{
   if(ticket == 0) return false;
   if(g_closeFailTicket == ticket && g_closeFailAt > 0 && (TimeCurrent() - g_closeFailAt) < 8)
      return false;
   if(!PositionSelectByTicket(ticket)) return false;
   if(PositionNearFreeze(ticket)) return false;

   double vol = PositionGetDouble(POSITION_VOLUME);
   if(!IsVolumeValid(vol))
   {
      // Re-align residual dust volumes when possible
      string sym = TradeSymbol();
      double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
      double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
      if(step <= 0) step = 0.01;
      int digits = (int)MathCeil(MathMax(0.0, -MathLog10(step) - 1e-12));
      double aligned = NormalizeDouble(MathRound(vol / step) * step, digits);
      if(aligned < minLot || !IsVolumeValid(aligned))
      {
         g_closeFailTicket = ticket;
         g_closeFailAt = TimeCurrent();
         return false;
      }
   }

   EnsureFilling(PositionGetString(POSITION_SYMBOL));
   if(!trade.PositionClose(ticket))
   {
      g_closeFailTicket = ticket;
      g_closeFailAt = TimeCurrent();
      return false;
   }
   uint rc = trade.ResultRetcode();
   if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL && rc != TRADE_RETCODE_PLACED)
   {
      g_closeFailTicket = ticket;
      g_closeFailAt = TimeCurrent();
      return false;
   }
   if(g_closeFailTicket == ticket)
   {
      g_closeFailTicket = 0;
      g_closeFailAt = 0;
   }
   return true;
}

bool SafePositionClosePartial(const ulong ticket, double closeVol)
{
   if(ticket == 0) return false;
   // Market validator runs netting — partials often produce Invalid volume there
   if(IsNettingAccount()) return false;
   if(IsTester()) return false; // avoid Market validation spam
   if(g_closeFailTicket == ticket && g_closeFailAt > 0 && (TimeCurrent() - g_closeFailAt) < 8)
      return false;
   if(!PositionSelectByTicket(ticket)) return false;
   if(PositionNearFreeze(ticket)) return false;

   double posVol = PositionGetDouble(POSITION_VOLUME);
   string sym = TradeSymbol();
   double minLot = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double step = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   if(step <= 0) step = 0.01;
   int digits = (int)MathCeil(MathMax(0.0, -MathLog10(step) - 1e-12));

   closeVol = NormalizeLot(closeVol);
   if(closeVol < minLot) return false;
   double remain = NormalizeDouble(posVol - closeVol, digits);
   if(remain < minLot - 1e-12) // would leave dust — do a full close instead
      return SafePositionClose(ticket);
   if(!IsVolumeValid(closeVol) || !IsVolumeValid(remain))
      return false;

   EnsureFilling(PositionGetString(POSITION_SYMBOL));
   if(!trade.PositionClosePartial(ticket, closeVol))
   {
      g_closeFailTicket = ticket;
      g_closeFailAt = TimeCurrent();
      return false;
   }
   uint rc = trade.ResultRetcode();
   if(rc != TRADE_RETCODE_DONE && rc != TRADE_RETCODE_DONE_PARTIAL && rc != TRADE_RETCODE_PLACED)
   {
      g_closeFailTicket = ticket;
      g_closeFailAt = TimeCurrent();
      return false;
   }
   return true;
}

double MaxLotByMargin(ENUM_ORDER_TYPE type)
{
   double price = (type == ORDER_TYPE_BUY)
      ? SymbolInfoDouble(TradeSymbol(), SYMBOL_ASK)
      : SymbolInfoDouble(TradeSymbol(), SYMBOL_BID);
   double free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double minLot = SymbolInfoDouble(TradeSymbol(), SYMBOL_VOLUME_MIN);
   if(free <= 0 || price <= 0) return 0;
   double marginOne = 0;
   if(!OrderCalcMargin(type, TradeSymbol(), 1.0, price, marginOne) || marginOne <= 0)
      return InpHardMaxLot > 0 ? InpHardMaxLot : 0.1;
   double usable = free * (InpMarginUsagePct / 100.0);
   double lots = usable / marginOne;
   // v1.28: if raw lots < minLot, still allow minLot when margin for minLot fits
   if(lots < minLot && minLot > 0)
   {
      double marginMin = 0;
      if(OrderCalcMargin(type, TradeSymbol(), minLot, price, marginMin) &&
         marginMin > 0 && marginMin <= usable)
         return minLot;
      return 0;
   }
   return NormalizeLot(lots);
}

double CalcLot(double atr, const int signal)
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskMoney = equity * (InpRiskPercent / 100.0);
   double tickSize = SymbolInfoDouble(TradeSymbol(), SYMBOL_TRADE_TICK_SIZE);
   double tickValue = SymbolInfoDouble(TradeSymbol(), SYMBOL_TRADE_TICK_VALUE);
   double minLot = SymbolInfoDouble(TradeSymbol(), SYMBOL_VOLUME_MIN);
   double slDist = MathMax(atr * InpSlAtrMult, MinStopDistance());
   if(tickSize <= 0 || tickValue <= 0 || slDist <= 0) return 0;

   double ticks = slDist / tickSize;
   double lossPerLot = ticks * tickValue;
   if(lossPerLot <= 0) return 0;

   double baseLot = riskMoney / lossPerLot;
   double mult = 1.0;
   if(InpLotScaleFactor > 1.0 && g_consecWins >= InpWinsForScale)
   {
      int steps = g_consecWins - InpWinsForScale + 1;
      mult = MathMin(InpMaxLotMult, MathPow(InpLotScaleFactor, steps));
   }
   // Macro against → cut size 50%
   if(InpUseMacroFilter)
   {
      int mac = MacroBiasGold();
      if(mac != 0 && mac != signal) mult *= 0.5;
   }

   double raw = baseLot * mult;
   double lot = NormalizeLot(raw);

   // v1.28 — petit compte: si risque% < min lot, autoriser min lot si SL risk ≤ InpMinLotMaxRiskPct
   if(lot <= 0 && minLot > 0 && InpMinLotMaxRiskPct > 0)
   {
      double minLotRisk = lossPerLot * minLot;
      double maxRiskMoney = equity * (InpMinLotMaxRiskPct / 100.0);
      if(minLotRisk <= maxRiskMoney)
      {
         lot = minLot;
         Print("GoldScalp LOT min-fallback lot=", DoubleToString(lot, 2),
               " risk$=", DoubleToString(minLotRisk, 2),
               " cap$=", DoubleToString(maxRiskMoney, 2),
               " (risk% too small for gold min lot)");
      }
      else
      {
         Print("GoldScalp LOT0 minLotRisk$=", DoubleToString(minLotRisk, 2),
               " > cap$=", DoubleToString(maxRiskMoney, 2),
               " equity=", DoubleToString(equity, 2),
               " raise InpMinLotMaxRiskPct or InpRiskPercent");
      }
   }

   double maxBuy = MaxLotByMargin(ORDER_TYPE_BUY);
   double maxSell = MaxLotByMargin(ORDER_TYPE_SELL);
   double maxMarginLot = MathMin(maxBuy, maxSell);
   if(maxMarginLot <= 0)
   {
      Print("GoldScalp LOT0 margin: cannot afford min lot (free margin / leverage)");
      return 0;
   }
   return NormalizeLot(MathMin(lot, maxMarginLot));
}

void CloseAllOurs()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != TradeSymbol()) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      if(PositionNearFreeze(ticket)) continue;
      SafePositionClose(ticket);
   }
}

string PartialKey(const ulong ticket)
{
   return "GS_PART_" + IntegerToString((long)ticket);
}

string ScoreKey(const ulong ticket)
{
   return "GS_SCORE_" + IntegerToString((long)ticket);
}

void SetEntryScore(const ulong ticket, const int score)
{
   if(ticket == 0) return;
   GlobalVariableSet(ScoreKey(ticket), (double)score);
}

int ParseScoreFromComment(const string cmt)
{
   int p = StringFind(cmt, " s");
   if(p < 0) return 0;
   return (int)StringToInteger(StringSubstr(cmt, p + 2));
}

int GetEntryScore(const ulong ticket)
{
   string key = ScoreKey(ticket);
   if(GlobalVariableCheck(key))
      return (int)GlobalVariableGet(key);
   if(!PositionSelectByTicket(ticket)) return 0;
   return ParseScoreFromComment(PositionGetString(POSITION_COMMENT));
}

bool IsRunnerTrade(const ulong ticket)
{
   if(!InpAllowRunners) return false;
   return (GetEntryScore(ticket) >= InpRunnerMinScore);
}

ulong FindOurNewestPosition()
{
   ulong best = 0;
   datetime bestT = 0;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != TradeSymbol()) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      datetime t = (datetime)PositionGetInteger(POSITION_TIME);
      if(t >= bestT) { bestT = t; best = ticket; }
   }
   return best;
}

int GetPartialStage(const ulong ticket)
{
   string key = PartialKey(ticket);
   if(!GlobalVariableCheck(key)) return 0;
   return (int)GlobalVariableGet(key);
}

void SetPartialStage(const ulong ticket, const int stage)
{
   GlobalVariableSet(PartialKey(ticket), stage);
}

void ClearTradeMeta(const ulong ticket)
{
   string pk = PartialKey(ticket);
   string sk = ScoreKey(ticket);
   if(GlobalVariableCheck(pk)) GlobalVariableDel(pk);
   if(GlobalVariableCheck(sk)) GlobalVariableDel(sk);
}

void ClearPartialStage(const ulong ticket)
{
   ClearTradeMeta(ticket);
}

void ManageOpenTrades()
{
   // Market auto-check runs Strategy Tester (often EURUSD netting). Aggressive
   // green-close / partial / BE / trail spam is what produces Invalid volume & failed modify.
   const bool testerSafe = IsTester();

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL) != TradeSymbol()) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;

      datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
      int ageMin = (int)((TimeCurrent() - openTime) / 60);

      long type = PositionGetInteger(POSITION_TYPE);
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double volume = PositionGetDouble(POSITION_VOLUME);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      double ask = SymbolInfoDouble(TradeSymbol(), SYMBOL_ASK);
      double bid = SymbolInfoDouble(TradeSymbol(), SYMBOL_BID);
      double atr = AtrValue(0);
      if(atr <= 0) atr = AtrValue(1);
      int digits = (int)SymbolInfoInteger(TradeSymbol(), SYMBOL_DIGITS);

      double risk = MathAbs(open - sl);
      if(risk <= 0) risk = MathMax(atr * InpSlAtrMult, MinStopDistance());
      double price = (type == POSITION_TYPE_BUY ? bid : ask);
      double favor = (type == POSITION_TYPE_BUY ? (price - open) : (open - price));
      double rMultiple = (risk > 0 ? favor / risk : 0);
      int ageSec = (int)(TimeCurrent() - openTime);
      double pnl = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      bool isRunner = IsRunnerTrade(ticket);
      int maxMin = (isRunner ? InpRunnerMaxMinutes : InpMaxTradeMinutes);

      // --- Tester / Market validation: SL+TP only + rare time stop ---
      if(testerSafe)
      {
         if(maxMin > 0 && ageMin >= maxMin)
         {
            if(SafePositionClose(ticket))
               ClearTradeMeta(ticket);
         }
         continue;
      }

      // Scalp: close green only if ≥ MinR AND MinMoney (net of spread noise)
      if(!isRunner && InpCloseWhenGreen && ageSec >= InpGreenMinSeconds && favor > 0)
      {
         const bool rOk = (rMultiple >= InpGreenMinR);
         const bool moneyOk = (InpGreenMinMoney <= 0.0 || pnl >= InpGreenMinMoney);
         if(rOk && moneyOk)
         {
            if(SafePositionClose(ticket))
            {
               ClearTradeMeta(ticket);
               Print("GoldScalp CLOSE GREEN (scalp) R=", DoubleToString(rMultiple, 2),
                     " pnl=", DoubleToString(pnl, 2));
               // push/alert via OnTradeTransaction (deal confirmé)
            }
            continue;
         }
      }

      // Time stop
      if(maxMin > 0 && ageMin >= maxMin)
      {
         if(SafePositionClose(ticket))
         {
            ClearTradeMeta(ticket);
            Print("GoldScalp TIME STOP ", (isRunner ? "runner" : "scalp"), " age=", ageMin, "m");
         }
         continue;
      }

      // Bank quick profit — scalp only (runners keep running with trail)
      if(!isRunner && InpBankProfitMinutes > 0 && ageMin >= InpBankProfitMinutes && rMultiple >= InpBankProfitMinR)
      {
         if(SafePositionClose(ticket))
         {
            ClearTradeMeta(ticket);
            Print("GoldScalp bank quick profit R=", DoubleToString(rMultiple, 2), " age=", ageMin, "m");
         }
         continue;
      }

      int stage = GetPartialStage(ticket);
      double minLot = SymbolInfoDouble(TradeSymbol(), SYMBOL_VOLUME_MIN);

      double beAt = (isRunner ? InpRunnerBeAtR : InpBeAtR);
      double partAt = (isRunner ? InpRunnerPartialAtR : InpPartialAtR);
      double partPct = (isRunner ? InpRunnerPartialPct : InpPartialPct);
      double trailAt = (isRunner ? InpRunnerTrailAtR : InpTrailAtR);
      double trailMult = (isRunner ? InpRunnerTrailAtrMult : InpTrailAtrMult);

      // Progressive partial #1 (hedging only — skipped on Market netting validator)
      if(InpUsePartial && !IsNettingAccount() && stage < 1 && rMultiple >= partAt)
      {
         double closeVol = NormalizeLot(volume * (partPct / 100.0));
         if(closeVol >= minLot && volume - closeVol >= minLot - 1e-8)
         {
            if(SafePositionClosePartial(ticket, closeVol))
            {
               SetPartialStage(ticket, 1);
               Print("GoldScalp PARTIAL1 ", (isRunner ? "runner" : "scalp"),
                     " R=", DoubleToString(rMultiple, 2));
               if(InpNotifyPartial)
                  NotifyTrade("PARTIAL",
                     StringFormat("%s R=%s vol=%.2f",
                        (isRunner ? "runner" : "scalp"),
                        DoubleToString(rMultiple, 2),
                        closeVol));
            }
         }
         else
            SetPartialStage(ticket, 1);
      }

      // Progressive partial #2 — mainly for scalp; runners often stop at stage 1 + trail
      if(!isRunner && InpUsePartial && !IsNettingAccount() && InpPartial2AtR > 0 && stage < 2 && rMultiple >= InpPartial2AtR)
      {
         if(!PositionSelectByTicket(ticket)) continue;
         volume = PositionGetDouble(POSITION_VOLUME);
         double closeVol = NormalizeLot(volume * (InpPartial2Pct / 100.0));
         if(closeVol >= minLot && volume - closeVol >= minLot - 1e-8)
         {
            if(SafePositionClosePartial(ticket, closeVol))
               SetPartialStage(ticket, 2);
         }
         else
            SetPartialStage(ticket, 2);
      }

      // Breakeven early — lock risk (especially runners)
      if(InpUseBreakeven && rMultiple >= beAt)
      {
         if(!PositionSelectByTicket(ticket)) continue;
         sl = PositionGetDouble(POSITION_SL);
         tp = PositionGetDouble(POSITION_TP);
         double minDist = MinStopDistance();
         double be = NormalizeDouble(open, digits);
         bool need = false;
         if(type == POSITION_TYPE_BUY && (sl < open - 1e-8 || sl == 0)) need = true;
         if(type == POSITION_TYPE_SELL && (sl > open + 1e-8 || sl == 0)) need = true;
         // Only move to BE when open itself respects stop level vs current price
         if(need)
         {
            if(type == POSITION_TYPE_BUY && be > bid - minDist) need = false;
            if(type == POSITION_TYPE_SELL && be < ask + minDist) need = false;
         }
         if(need)
            SafePositionModify(ticket, be, tp);
      }

      // Trail — lock more profit while letting runner grow
      if(InpUseTrail && rMultiple >= trailAt && atr > 0)
      {
         if(!PositionSelectByTicket(ticket)) continue;
         sl = PositionGetDouble(POSITION_SL);
         tp = PositionGetDouble(POSITION_TP);
         price = (type == POSITION_TYPE_BUY ? bid : ask);
         double minDist = MinStopDistance();
         double trailDist = MathMax(atr * trailMult, minDist);
         double point = SymbolInfoDouble(TradeSymbol(), SYMBOL_POINT);
         if(point <= 0) point = 0.00001;
         double minImprove = MathMax(minDist * 0.25, 5.0 * point);
         if(type == POSITION_TYPE_BUY)
         {
            double newSl = NormalizeDouble(price - trailDist, digits);
            double maxSl = NormalizeDouble(bid - minDist, digits);
            if(newSl > maxSl) newSl = maxSl;
            if(newSl > sl + minImprove && newSl < bid)
               SafePositionModify(ticket, newSl, tp);
         }
         else
         {
            double newSl = NormalizeDouble(price + trailDist, digits);
            double minSl = NormalizeDouble(ask + minDist, digits);
            if(newSl < minSl) newSl = minSl;
            if((sl == 0 || newSl < sl - minImprove) && newSl > ask)
               SafePositionModify(ticket, newSl, tp);
         }
      }
   }
}

void OnTick()
{
   SyncDayRisk();
   RefreshCalendarNews();
   ManageOpenTrades();

   // Flatten on news red
   if(!IsTester() && NewsBlocked() && InpFlattenOnNews && CountOurPositions() > 0)
      CloseAllOurs();

   if(!GsLicenseAllowsNewTrades())
   {
      g_lastDecision = "NOGO";
      g_lastScore = 0;
      g_lastReasons = "sub_required:" + GsLicenseStatusTag();
      UpdateChartStatus();
      return;
   }

   if(!g_auto || g_paused || NewsBlocked())
   {
      g_lastDecision = "NOGO";
      g_lastScore = 0;
      if(NewsBlocked()) g_lastReasons = "news_pause:" + g_newsReason;
      else if(!g_auto) g_lastReasons = "auto_off";
      else g_lastReasons = "paused";
      UpdateChartStatus();
      return;
   }
   if(DailyLossHit())
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "daily_loss";
      UpdateChartStatus();
      return;
   }
   if(FloatingDdHit())
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "floating_dd";
      UpdateChartStatus();
      return;
   }
   if(g_consecLosses >= InpMaxConsecLosses)
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "max_consec_losses";
      UpdateChartStatus();
      return;
   }
   if(g_tradesToday >= InpMaxTradesPerDay)
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "max_trades_day";
      UpdateChartStatus();
      return;
   }
   if(!SessionOk())
   {
      g_lastDecision = "NOGO";
      g_lastScore = 0;
      g_lastReasons = "session_closed";
      UpdateChartStatus();
      return;
   }
   if(CountOurPositions() >= InpMaxPositions)
   {
      g_lastDecision = "HOLD";
      g_lastReasons = "max_positions";
      UpdateChartStatus();
      return;
   }
   if(SpreadPoints() > EffectiveMaxSpreadPoints())
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "spread";
      UpdateChartStatus();
      return;
   }

   datetime barTime = iTime(TradeSymbol(), g_workTf, 0);
   if(barTime == 0 || barTime == g_lastBar)
   {
      // Same bar: keep managing exits + live dashboard only
      if(g_lastDecision == "IDLE" || g_lastDecision == "")
      {
         g_lastDecision = "WAIT";
         g_lastReasons = "same_bar_wait_signal";
      }
      UpdateChartStatus();
      return;
   }
   g_lastBar = barTime;

   // Better moment: avoid first minutes of each hour (often news/adjustments)
   if(InpAvoidHourOpenMin > 0)
   {
      MqlDateTime dt;
      TimeToStruct(TimeGMT(), dt);
      if(dt.min < InpAvoidHourOpenMin)
      {
         g_lastDecision = "NOGO";
         g_lastReasons = "hour_open_risk";
         UpdateChartStatus();
         return;
      }
   }

   int signal = EntrySignal();
   g_lastSignal = (signal > 0 ? "buy" : (signal < 0 ? "sell" : "none"));
   if(signal == 0)
   {
      g_lastDecision = "WAIT";
      g_lastScore = 0;
      g_lastReasons = "no_entry_signal";
      UpdateChartStatus();
      return;
   }

   if(InpRequireOverlap && InpAllowLondonOpen && InLondonOpen() && !InOverlap())
   {
      if(HtfBias() != signal)
      {
         g_lastDecision = "NOGO";
         g_lastScore = 0;
         g_lastReasons = "london_needs_htf";
         UpdateChartStatus();
         return;
      }
   }

   double atr = AtrValue(1);
   if(atr <= 0)
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "atr0";
      UpdateChartStatus();
      return;
   }

   // Better moment / less risk: hard quality vetoes
   if(InpHardQualityFilters)
   {
      int htf = HtfBias();
      if(htf != 0 && htf != signal)
      {
         g_lastDecision = "NOGO";
         g_lastScore = 0;
         g_lastReasons = "htf_against_hard";
         UpdateChartStatus();
         return;
      }
      if(!VolOk(atr))
      {
         g_lastDecision = "NOGO";
         g_lastScore = 0;
         g_lastReasons = "vol_bad_hard";
         UpdateChartStatus();
         return;
      }
      if(!StructureOk(signal))
      {
         g_lastDecision = "NOGO";
         g_lastScore = 0;
         g_lastReasons = "midrange_hard";
         UpdateChartStatus();
         return;
      }
   }

   string reasons = "";
   int score = BuildPreTradeScore(signal, atr, reasons);
   g_lastScore = score;
   g_lastReasons = reasons;

   double slDist = atr * InpSlAtrMult;
   bool isRunnerSetup = (InpAllowRunners && score >= InpRunnerMinScore);
   double tpMult = (isRunnerSetup ? InpRunnerTpAtrMult : InpTpAtrMult);
   double tpDist = atr * tpMult;
   if(!NetRrOk(slDist, tpDist))
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "rr_fail";
      Print("GoldScalp NOGO rr_fail score=", score, " ", reasons);
      UpdateChartStatus();
      return;
   }

   if(score < InpMinScore)
   {
      g_lastDecision = "NOGO";
      g_lastReasons = StringFormat("score_%d<%d", score, InpMinScore);
      Print("GoldScalp NOGO score=", score, " < ", InpMinScore, " ", reasons);
      UpdateChartStatus();
      return;
   }

   double lot = CalcLot(atr, signal);
   if(lot <= 0)
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "lot0";
      Print("GoldScalp NOGO lot0 score=", score, " equity=", AccountInfoDouble(ACCOUNT_EQUITY));
      UpdateChartStatus();
      return;
   }

   // Final spread check immediately before send
   if(SpreadPoints() > EffectiveMaxSpreadPoints())
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "spread";
      UpdateChartStatus();
      return;
   }

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) || !MQLInfoInteger(MQL_TRADE_ALLOWED))
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "algo_blocked";
      Print("GoldScalp NOGO: AutoTrading blocked (Algo button / EA Allow live trading)");
      UpdateChartStatus();
      return;
   }

   double ask = SymbolInfoDouble(TradeSymbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(TradeSymbol(), SYMBOL_BID);
   double sl = 0, tp = 0;
   if(!BuildStops(signal > 0, slDist, tpDist, sl, tp))
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "stops_fail";
      UpdateChartStatus();
      return;
   }

   lot = NormalizeLot(lot);
   if(lot <= 0 || !IsVolumeValid(lot))
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "bad_volume";
      UpdateChartStatus();
      return;
   }

   // Respect SYMBOL_VOLUME_LIMIT (Market check)
   double volLimit = SymbolInfoDouble(TradeSymbol(), SYMBOL_VOLUME_LIMIT);
   if(volLimit > 0)
   {
      double used = 0;
      for(int i = 0; i < PositionsTotal(); i++)
      {
         ulong t = PositionGetTicket(i);
         if(t == 0 || !PositionSelectByTicket(t)) continue;
         if(PositionGetString(POSITION_SYMBOL) != TradeSymbol()) continue;
         used += PositionGetDouble(POSITION_VOLUME);
      }
      double freeVol = volLimit - used;
      if(freeVol < lot)
      {
         lot = NormalizeLot(freeVol);
         if(lot <= 0 || !IsVolumeValid(lot))
         {
            g_lastDecision = "NOGO";
            g_lastReasons = "volume_limit";
            UpdateChartStatus();
            return;
         }
      }
   }

   EnsureFilling(TradeSymbol());
   string modeTag = (isRunnerSetup ? "run" : "scalp");
   string cmt = StringFormat("%s s%d %s %s", InpComment, score, SessionTag(), modeTag);
   bool ok = false;
   // Open WITHOUT SL/TP first — Market rejects market orders when stops are "close to market"
   if(signal > 0)
      ok = trade.Buy(lot, TradeSymbol(), ask, 0, 0, cmt);
   else
      ok = trade.Sell(lot, TradeSymbol(), bid, 0, 0, cmt);

   if(ok)
   {
      g_tradesToday++;
      g_lastDecision = "GO";
      ulong ticket = FindOurNewestPosition();
      SetEntryScore(ticket, score);
      // Attach stops after fill, rebuilt from current bid/ask
      if(ticket != 0)
      {
         double setSl = 0, setTp = 0;
         if(BuildStops(signal > 0, slDist, tpDist, setSl, setTp))
         {
            if(!SafePositionModify(ticket, setSl, setTp))
            {
               // One wider retry for validator freeze/stops
               double wider = MinStopDistance() * 2.0;
               if(BuildStops(signal > 0, MathMax(slDist, wider), MathMax(tpDist, wider), setSl, setTp))
                  SafePositionModify(ticket, setSl, setTp);
            }
         }
      }
      Print("GoldScalp GO ", modeTag, " score=", score, " TP=", DoubleToString(tpMult, 2), "xATR ", reasons);
      NotifyTrade("OPEN " + modeTag,
         StringFormat("%s %s lot=%.2f score=%d",
            (signal > 0 ? "BUY" : "SELL"),
            TradeSymbol(),
            lot,
            score));
   }
   else
   {
      g_lastDecision = "NOGO";
      g_lastReasons = "order_fail";
      Print("Order failed: ", trade.ResultRetcodeDescription());
   }
   UpdateChartStatus();
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   ulong deal = trans.deal;
   if(deal == 0) return;
   if(!HistoryDealSelect(deal)) return;
   if((long)HistoryDealGetInteger(deal, DEAL_MAGIC) != InpMagic) return;

   long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
   string sym = HistoryDealGetString(deal, DEAL_SYMBOL);
   double vol = HistoryDealGetDouble(deal, DEAL_VOLUME);
   double price = HistoryDealGetDouble(deal, DEAL_PRICE);
   long dtype = HistoryDealGetInteger(deal, DEAL_TYPE);
   string side = (dtype == DEAL_TYPE_BUY ? "BUY" : "SELL");

   if(entry == DEAL_ENTRY_IN)
   {
      // OPEN already notified from OnTick after Buy/Sell — skip duplicate
   }
   else if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
   {
      ulong posId = (ulong)HistoryDealGetInteger(deal, DEAL_POSITION_ID);
      if(posId > 0) ClearTradeMeta(posId);

      double profit = HistoryDealGetDouble(deal, DEAL_PROFIT)
                    + HistoryDealGetDouble(deal, DEAL_SWAP)
                    + HistoryDealGetDouble(deal, DEAL_COMMISSION);
      if(profit > 0)
      {
         g_consecWins++;
         g_consecLosses = 0;
      }
      else
      {
         g_consecLosses++;
         g_consecWins = 0;
      }

      NotifyTrade(profit >= 0 ? "CLOSE +" : "CLOSE -",
         StringFormat("%s %s vol=%.2f @%.2f PnL=%.2f",
            side, sym, vol, price, profit));
   }
}

//+------------------------------------------------------------------+
//| Bridge                                                            |
//+------------------------------------------------------------------+
bool BridgeHeaders(string &headers)
{
#ifdef GOLDSCALP_EDITION_MARKET
   headers = "";
   return false;
#else
   headers = "Content-Type: application/json\r\nX-GoldScalp-Token: " + InpBridgeToken + "\r\n";
   return true;
#endif
}

string JsonEscape(string s)
{
   string o = s;
   StringReplace(o, "\\", "\\\\");
   StringReplace(o, "\"", "\\\"");
   return o;
}

string BuildPositionsJson()
{
   string arr = "[";
   bool first = true;
   for(int i = 0; i < PositionsTotal(); i++)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;
      if((long)PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;

      long type = PositionGetInteger(POSITION_TYPE);
      string side = (type == POSITION_TYPE_BUY ? "buy" : "sell");
      if(!first) arr += ",";
      first = false;
      arr += StringFormat(
         "{\"id\":\"%I64u\",\"symbol\":\"XAU/USD\",\"side\":\"%s\",\"lots\":%.2f,\"openPrice\":%.5f,\"sl\":%.5f,\"tp\":%.5f,\"pnl\":%.2f,\"status\":\"open\",\"openedAt\":\"%s\",\"strategy\":\"%s\"}",
         ticket, side,
         PositionGetDouble(POSITION_VOLUME),
         PositionGetDouble(POSITION_PRICE_OPEN),
         PositionGetDouble(POSITION_SL),
         PositionGetDouble(POSITION_TP),
         PositionGetDouble(POSITION_PROFIT),
         TimeToString((datetime)PositionGetInteger(POSITION_TIME), TIME_DATE|TIME_SECONDS),
         JsonEscape(InpComment)
      );
   }
   arr += "]";
   return arr;
}

string BuildHistoryJson()
{
   datetime to = TimeCurrent();
   datetime from = to - 7 * 24 * 60 * 60;
   if(!HistorySelect(from, to)) return "[]";

   string arr = "[";
   bool first = true;
   int total = HistoryDealsTotal();
   int added = 0;
   for(int i = total - 1; i >= 0 && added < 40; i--)
   {
      ulong deal = HistoryDealGetTicket(i);
      if(deal == 0) continue;
      if((long)HistoryDealGetInteger(deal, DEAL_MAGIC) != InpMagic) continue;
      long entry = HistoryDealGetInteger(deal, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT && entry != DEAL_ENTRY_OUT_BY && entry != DEAL_ENTRY_IN) continue;

      long dtype = HistoryDealGetInteger(deal, DEAL_TYPE);
      string side = (dtype == DEAL_TYPE_BUY ? "buy" : "sell");
      double profit = HistoryDealGetDouble(deal, DEAL_PROFIT)
                    + HistoryDealGetDouble(deal, DEAL_SWAP)
                    + HistoryDealGetDouble(deal, DEAL_COMMISSION);
      string status = (entry == DEAL_ENTRY_IN ? "open" : "closed");

      if(!first) arr += ",";
      first = false;
      added++;
      arr += StringFormat(
         "{\"id\":\"d%I64u\",\"symbol\":\"XAU/USD\",\"side\":\"%s\",\"lots\":%.2f,\"openPrice\":%.5f,\"closePrice\":%.5f,\"sl\":0,\"tp\":0,\"pnl\":%.2f,\"status\":\"%s\",\"openedAt\":\"%s\",\"closedAt\":\"%s\",\"strategy\":\"%s\"}",
         deal, side,
         HistoryDealGetDouble(deal, DEAL_VOLUME),
         HistoryDealGetDouble(deal, DEAL_PRICE),
         HistoryDealGetDouble(deal, DEAL_PRICE),
         profit, status,
         TimeToString((datetime)HistoryDealGetInteger(deal, DEAL_TIME), TIME_DATE|TIME_SECONDS),
         (entry == DEAL_ENTRY_IN ? "" : TimeToString((datetime)HistoryDealGetInteger(deal, DEAL_TIME), TIME_DATE|TIME_SECONDS)),
         JsonEscape(InpComment)
      );
   }
   arr += "]";
   return arr;
}

void ApplyNewsFromJson(const string json)
{
   // Look for "inRedWindow":true in heartbeat response or commands wrapper
   if(StringFind(json, "\"inRedWindow\":true") >= 0 || StringFind(json, "\"inRedWindow\": true") >= 0)
      g_newsRed = true;
   else if(StringFind(json, "\"inRedWindow\":false") >= 0 || StringFind(json, "\"inRedWindow\": false") >= 0)
      g_newsRed = false;

   string reason = "";
   int k = StringFind(json, "\"reason\"");
   if(k >= 0)
   {
      int q1 = StringFind(json, "\"", k + 8);
      if(q1 >= 0)
      {
         int q2 = StringFind(json, "\"", q1 + 1);
         if(q2 > q1) reason = StringSubstr(json, q1 + 1, q2 - q1 - 1);
      }
   }
   if(reason != "") g_newsReason = reason;
}

void BridgePushState()
{
#ifdef GOLDSCALP_EDITION_MARKET
   return;
#else
   string headers;
   BridgeHeaders(headers);
   char data[];
   char result[];
   string resultHeaders;

   double ask = SymbolInfoDouble(TradeSymbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(TradeSymbol(), SYMBOL_BID);
   string mode = (!g_auto ? "OFF" : (g_paused || NewsBlocked() ? "PAUSE" : "AUTO"));

   string body = StringFormat(
      "{\"ok\":true,\"mode\":\"%s\",\"account\":%d,\"equity\":%.2f,\"balance\":%.2f,\"symbol\":\"%s\",\"bid\":%.5f,\"ask\":%.5f,\"spreadPoints\":%.1f,\"consecWins\":%d,\"consecLosses\":%d,\"tradesToday\":%d,\"paused\":%s,\"auto\":%s,\"dailyLossHit\":%s,\"floatingDdHit\":%s,\"lastScore\":%d,\"lastDecision\":\"%s\",\"lastReasons\":\"%s\",\"lastSignal\":\"%s\",\"newsRed\":%s,\"positions\":%s,\"history\":%s,\"serverTime\":\"%s\"}",
      mode,
      (int)AccountInfoInteger(ACCOUNT_LOGIN),
      AccountInfoDouble(ACCOUNT_EQUITY),
      AccountInfoDouble(ACCOUNT_BALANCE),
      TradeSymbol(),
      bid, ask, SpreadPoints(),
      g_consecWins, g_consecLosses, g_tradesToday,
      (g_paused ? "true" : "false"),
      (g_auto ? "true" : "false"),
      (DailyLossHit() ? "true" : "false"),
      (FloatingDdHit() ? "true" : "false"),
      g_lastScore,
      JsonEscape(g_lastDecision),
      JsonEscape(g_lastReasons),
      JsonEscape(g_lastSignal),
      (NewsBlocked() ? "true" : "false"),
      BuildPositionsJson(),
      BuildHistoryJson(),
      TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS)
   );

   StringToCharArray(body, data, 0, WHOLE_ARRAY, CP_UTF8);
   ArrayResize(data, ArraySize(data) - 1);

   string url = InpBridgeUrl + "/ea/heartbeat";
   int code = WebRequest("POST", url, headers, 3000, data, result, resultHeaders);
   if(code == -1)
      Print("Bridge push failed. Allow URL: ", InpBridgeUrl);
   else if(code == 200)
   {
      string resp = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
      ApplyNewsFromJson(resp);
   }
#endif
}

void BridgePullCommands()
{
#ifdef GOLDSCALP_EDITION_MARKET
   return;
#else
   string headers;
   BridgeHeaders(headers);
   char data[];
   char result[];
   string resultHeaders;
   ArrayResize(data, 0);

   string url = InpBridgeUrl + "/ea/commands";
   int code = WebRequest("GET", url, headers, 3000, data, result, resultHeaders);
   if(code != 200) return;

   string json = CharArrayToString(result, 0, WHOLE_ARRAY, CP_UTF8);
   ApplyNewsFromJson(json);
   ProcessCommandsJson(json);
#endif
}

void ProcessCommandsJson(const string json)
{
   int pos = 0;
   while(true)
   {
      string action = JsonGetString(json, "action", pos);
      if(action == "") break;
      int actionPos = StringFind(json, "\"action\"", pos);
      if(actionPos < 0) break;

      if(action == "pause") g_paused = true;
      else if(action == "resume") { g_paused = false; g_auto = true; }
      else if(action == "auto_on") g_auto = true;
      else if(action == "auto_off") g_auto = false;
      else if(action == "close")
      {
         string id = JsonGetString(json, "positionId", actionPos);
         CloseById(id);
      }
      else if(action == "modify")
      {
         string id = JsonGetString(json, "positionId", actionPos);
         double sl = JsonGetNumber(json, "sl", actionPos);
         double tp = JsonGetNumber(json, "tp", actionPos);
         ModifyById(id, sl, tp);
      }
      else if(action == "market")
      {
         string side = JsonGetString(json, "side", actionPos);
         double lots = JsonGetNumber(json, "lots", actionPos);
         ManualMarket(side, lots);
      }

      pos = actionPos + 10;
   }
}

string JsonGetString(const string json, const string key, int from)
{
   string pattern = "\"" + key + "\"";
   int k = StringFind(json, pattern, from);
   if(k < 0) return "";
   int colon = StringFind(json, ":", k + StringLen(pattern));
   if(colon < 0) return "";
   int q1 = StringFind(json, "\"", colon);
   if(q1 < 0) return "";
   int q2 = StringFind(json, "\"", q1 + 1);
   if(q2 < 0) return "";
   return StringSubstr(json, q1 + 1, q2 - q1 - 1);
}

double JsonGetNumber(const string json, const string key, int from)
{
   string pattern = "\"" + key + "\"";
   int k = StringFind(json, pattern, from);
   if(k < 0) return 0;
   int colon = StringFind(json, ":", k + StringLen(pattern));
   if(colon < 0) return 0;
   int i = colon + 1;
   while(i < StringLen(json))
   {
      ushort c = StringGetCharacter(json, i);
      if(c == ' ' || c == '\t') { i++; continue; }
      break;
   }
   int j = i;
   while(j < StringLen(json))
   {
      ushort c = StringGetCharacter(json, j);
      if((c >= '0' && c <= '9') || c == '.' || c == '-') { j++; continue; }
      break;
   }
   return StringToDouble(StringSubstr(json, i, j - i));
}

void CloseById(const string id)
{
   if(id == "" || id == "all")
   {
      CloseAllOurs();
      return;
   }
   ulong ticket = (ulong)StringToInteger(id);
   if(PositionSelectByTicket(ticket))
      SafePositionClose(ticket);
}

void ModifyById(const string id, double sl, double tp)
{
   ulong ticket = (ulong)StringToInteger(id);
   if(!PositionSelectByTicket(ticket)) return;
   if(sl <= 0) sl = PositionGetDouble(POSITION_SL);
   if(tp <= 0) tp = PositionGetDouble(POSITION_TP);
   SafePositionModify(ticket, sl, tp);
}

void ManualMarket(const string side, double lots)
{
   if(NewsBlocked()) return;
   double minLot = SymbolInfoDouble(TradeSymbol(), SYMBOL_VOLUME_MIN);
   if(lots <= 0) lots = minLot;
   lots = NormalizeLot(lots);
   if(lots <= 0) return;
   double atr = AtrValue(0);
   if(atr <= 0) atr = SymbolInfoDouble(TradeSymbol(), SYMBOL_POINT) * 200;
   double ask = SymbolInfoDouble(TradeSymbol(), SYMBOL_ASK);
   double bid = SymbolInfoDouble(TradeSymbol(), SYMBOL_BID);
   double sl = 0, tp = 0;
   int sig = (side == "buy" ? 1 : -1);
   if(!BuildStops(sig > 0, atr * InpSlAtrMult, atr * InpTpAtrMult, sl, tp)) return;

   if(side == "buy")
   {
      lots = MathMin(lots, MaxLotByMargin(ORDER_TYPE_BUY));
      lots = NormalizeLot(lots);
      if(lots <= 0) return;
      EnsureFilling(TradeSymbol());
      if(trade.Buy(lots, TradeSymbol(), ask, 0, 0, InpComment + "-manual"))
      {
         ulong ticket = FindOurNewestPosition();
         if(ticket != 0) SafePositionModify(ticket, sl, tp);
      }
   }
   else if(side == "sell")
   {
      lots = MathMin(lots, MaxLotByMargin(ORDER_TYPE_SELL));
      lots = NormalizeLot(lots);
      if(lots <= 0) return;
      EnsureFilling(TradeSymbol());
      if(trade.Sell(lots, TradeSymbol(), bid, 0, 0, InpComment + "-manual"))
      {
         ulong ticket = FindOurNewestPosition();
         if(ticket != 0) SafePositionModify(ticket, sl, tp);
      }
   }
}
//+------------------------------------------------------------------+
