//+------------------------------------------------------------------+
//| Advanced_PropFirm_Trade_Panel_SR_2_81.mq5  v2.81                 |
//| Advanced Prop-firm Trade Panel based on S-R                      |
//| Prop-firm guard + manual S/R trading panel (never auto-trades)   |
//+------------------------------------------------------------------+
#property copyright   "ClassicalTrading | www.mql5.com/en/users/classicaltrading/"
#property link        "https://www.mql5.com/en/users/classicaltrading/"
#property version     "2.81"
#property description "Advanced Prop-firm Trade Panel based on S-R"
#property description "Prop-firm DD guard + manual S-R trading panel."
#property description "Never auto-trades. Drag lines by their handles."

#define APP_NAME  "Advanced Prop-firm Trade Panel based on S-R"
#define APP_VER   "2.81"
#define APP_SHORT "Adv. Prop-firm Trade Panel (S/R)"

// asset classes for the leverage rules
#define AC_FOREX        0
#define AC_EXOTIC       1
#define AC_GOLD         2
#define AC_SILVER       3
#define AC_OIL          4
#define AC_INDEX        5
#define AC_SHARE        6
#define AC_CRYPTOMAJOR  7
#define AC_CRYPTO       8
#define AC_OTHER        9

#include <Trade/Trade.mqh>

enum ENUM_DD_REF  { DDREF_BALANCE=0, DDREF_EQUITY=1, DDREF_HIGHER=2 };
enum ENUM_SCOPE   { SCOPE_MAGIC=0, SCOPE_SYMBOL=1, SCOPE_ACCOUNT=2 };
enum ENUM_THEME   { THEME_DARK=0, THEME_LIGHT=1 };
enum ENUM_DAYMODE { DAY_NY_CLOSE=0, DAY_SERVER=1 };
enum ENUM_SRMODE  { SR_AGGRESSIVE=0, SR_CONSERVATIVE=1 };
enum ENUM_HEDGEMARGIN { HM_NET=0, HM_LARGER=1, HM_NONE=2 };
enum ENUM_PENDTYPE { PT_BOTH=0, PT_LIMIT=1, PT_STOP=2 };

input group "==== Prop firm rules ===="
input double InpStartBalance   = 0.0;    // Starting balance (0 = auto-detect)
input double InpDailyDDPct     = 4.0;    // Daily drawdown limit %
input double InpBufferPct      = 15.0;   // Buffer: % of the daily DD limit (stop earlier)
input double InpMaxDDPct       = 10.0;   // Max drawdown % (static, from starting balance)
input double InpMaxBufferPct   = 0.0;    // Buffer: % of the max DD amount (0 = off)
input ENUM_DD_REF InpDDRef     = DDREF_BALANCE; // Daily DD starts from: day-start balance / day-start equity / higher of both
input ENUM_DAYMODE InpDayMode  = DAY_NY_CLOSE; // Day transition: FXIFY = New York 17:00 (DST-aware) / broker server midnight
input int    InpRolloverNYHour = 17;     // New York hour at which the new trading day starts (FXIFY: 17 = 5 PM)
input bool   InpNYDst          = true;   // New York time follows US daylight saving (false = fixed EST, UTC-5)
input int    InpRolloverShiftH = 0;      // Server-midnight mode only: shift of the rollover in hours
input bool   InpBlockRisky     = true;   // Block orders whose worst-case loss (hedge-netted, incl. open/pending SL risk) exceeds the remaining DD allowance
input double InpDDOrangePct    = 40.0;   // Drawdown bars turn ORANGE at this % of the limit (yellow below)
input double InpDDRedPct       = 70.0;   // Drawdown bars turn RED at this % of the limit

input group "==== Leverage / margin rules (prop firm; FXIFY standard, all editable) ===="
input bool   InpLevOn          = true;   // Apply the prop-firm leverage rule (the broker's own margin is always checked as well)
input double InpLevForex       = 30.0;   // Leverage 1:x - forex
input double InpLevExotic      = 6.0;    // Leverage 1:x - exotic FX pairs (currency codes listed below)
input string InpExotics        = "MXN,ZAR,TRY,THB,HKD,SGD,PLN,CZK,HUF,CNH,ILS"; // Exotic currency codes (comma separated, found inside the symbol name)
input double InpLevGold        = 30.0;   // Leverage 1:x - gold
input double InpLevSilver      = 10.0;   // Leverage 1:x - silver
input double InpLevOil         = 5.0;    // Leverage 1:x - oil / energies
input double InpLevIndices     = 10.0;   // Leverage 1:x - indices
input double InpLevShares      = 2.0;    // Leverage 1:x - shares
input double InpLevCryptoMajor = 5.0;    // Leverage 1:x - major crypto
input string InpCryptoMajors   = "BTC,ETH,SOL"; // Major crypto tickers (symbol starts with)
input double InpLevCrypto      = 2.0;    // Leverage 1:x - other crypto
input double InpLevOther       = 10.0;   // Leverage 1:x - other commodities / unrecognised symbols
input ENUM_HEDGEMARGIN InpHedgeMargin = HM_NET; // Margin of hedged positions on one symbol: net exposure / larger side / both sides
input double InpMarginUsePct   = 80.0;   // Max margin as % of equity - checked at EVERY grid level, after the drawdown of the earlier orders

input group "==== Profit goals ===="
input double InpPassPct        = 10.0;   // Total profit to pass the challenge, % of starting balance (0 = off). Reached = close all + lock
input double InpDayMaxProfit   = 0.0;    // Max desired DAILY profit (realized + floating, 0 = off). Reached = close EVERYTHING incl. all pendings + lock until next day
input bool   InpDayMaxMoney    = false;  // Max daily profit unit: false = %, true = account currency
input bool   InpBasketOn       = true;   // Basket: close all OPEN trades (scope below) at this FLOATING profit. Pending orders stay - except pendings of grids. Does not lock trading
input double InpBasketVal      = 1.0;    // Basket floating profit target
input bool   InpBasketMoney    = false;  // Basket target unit: false = %, true = account currency
input bool   InpBasketTrail    = false;  // Basket: virtual trailing stop instead of closing at the target
input double InpTrailVal       = 0.5;    // Trail distance behind the peak floating profit
input bool   InpTrailMoney     = false;  // Trail unit: false = %, true = account currency

input group "==== Order defaults (Live + Pending) ===="
input long   InpMagic          = 777001;
input string InpComment        = "SR_Propfirm_EA"; // Only used to recognise grids placed by the previous version. Order comments are now compact codes (G/L/P/T + B/S + id)
input double InpLot            = 0.10;
input int    InpSLPts          = 250;
input int    InpTPPts          = 250;
input bool   InpAutoLot        = true;   // Lot from risk % and SL (capped by the leverage rule)
input double InpRiskPct        = 1.0;    // Risk % per trade (of starting balance)
input ENUM_PENDTYPE InpPendType = PT_BOTH; // Pending tab: suggest limit orders, stop orders or both
input int    InpMinPendDist    = 500;    // Pending: min distance from price (points)
input ENUM_SCOPE InpCloseScope = SCOPE_ACCOUNT; // Close buttons + basket act on: magic / symbol / ACCOUNT (= also trades NOT created by this EA)

input group "==== Grid defaults ===="
input double InpGridRiskPct    = 0.0;    // Risk % whole grid (0 = half of daily DD)
input int    InpGridOrders     = 4;      // Orders in grid (2..8)
input double InpGridLotIncPct  = 150.0;  // Lot multiplier per level in % (150 = x1.5)
input bool   InpGridTP1Auto    = true;   // TP of first order: automatic (nearest S/R), shown in pips and adjustable
input int    InpGridTP1Pts     = 250;    // TP of first order: fallback when no S/R level is found (points)
input bool   InpGridMoveTP     = true;   // Grid: on EVERY fill (from the 2nd order) move the real TP of all grid orders to the grid take-profit level (server-side)
input bool   InpGridInitTP     = true;   // Every PENDING grid order gets a take profit at the open price of the 1st order (works even if the EA / VPS is off)
input bool   InpGridBEOn       = false;  // Breakeven: active by default (off)
input double InpGridBEBufPips  = 2.0;    // Breakeven: buffer in pips beyond the grid's average entry
input double InpGridBETrigPips = 0.0;    // Breakeven: trigger, pips in profit (0 = as soon as the broker allows)
input int    InpPipPoints      = 0;      // Points per pip (0 = auto: 10 on 3/5-digit symbols and metals)
input double InpGridTPValue    = 250.0;  // TP of whole grid (points or currency)
input bool   InpGridTPMoney    = false;  // Grid TP unit: false = points, true = account currency
input int    InpGridMinPts     = 250;    // Min points between grid orders
input double InpGridDistIncPct = 50.0;   // Each next gap grows by this % of the first gap

input int    InpExtMaxAdd      = 6;      // Extend grid button: max orders to add
input double InpExtUsePct      = 100.0;  // Extend grid button: use up to this % of the remaining daily DD allowance (day's profit included)

input group "==== Support / Resistance finder (not drawn) ===="
input ENUM_TIMEFRAMES InpSRTF  = PERIOD_CURRENT; // Timeframe
input int    InpSRLookback     = 500;    // Bars to scan
input int    InpSRStrength     = 3;      // Pivot strength (bars each side)
input double InpSRClusterATR   = 0.5;    // Cluster tolerance (x avg bar range)
input int    InpSRMinTouches   = 2;      // Min pivots per level
input int    InpSRMaxLevels    = 12;     // Max levels kept
input double InpSLBufATR       = 0.25;   // SL buffer beyond level (x avg bar range)
input ENUM_SRMODE InpSRMode    = SR_AGGRESSIVE; // Stops / targets: AGGRESSIVE (nearest levels, current behaviour) or CONSERVATIVE (much stronger levels, more room)
input double InpConsStrengthMult = 2.0;  // Conservative: pivot strength x
input int    InpConsExtraTouches = 1;    // Conservative: extra pivots required per level
input double InpConsClusterMult  = 1.5;  // Conservative: cluster tolerance x
input double InpConsLookbackMult = 2.0;  // Conservative: bars to scan x
input double InpConsKeepPct      = 50.0; // Conservative: keep only the strongest % of the levels
input double InpConsMinGapATR    = 2.0;  // Conservative: min distance between two levels (x avg bar range)
input double InpConsSLBufMult    = 2.0;  // Conservative: SL buffer x
input double InpConsMinDistATR   = 1.0;  // Conservative: SL/TP suggestions at least this far from price (x avg bar range)
input double InpConsGridMinMult  = 2.0;  // Conservative: min gap between grid orders x

input group "==== Two terminals (PC + VPS on the same account) ===="
input bool   InpMgrDelay       = false;  // Wait 1 s before every AUTOMATIC action (guards, basket, grid TP / breakeven / cleanup). Switch ON on the terminal that should act second

input group "==== Strategy tester (ignored on a live / demo account) ===="
input bool   InpTestAutoTrade  = true;   // Tester: open trades automatically (S/R bounce, needed for MQL5 Market validation). Turn OFF to use the panel by hand in visual mode
input double InpTestRiskPct    = 0.5;    // Tester: risk % of the starting balance per automatic trade
input int    InpTestMaxTrades  = 1;      // Tester: max open automatic positions at the same time
input double InpTestMinRR      = 1.5;    // Tester: minimum reward : risk of an automatic trade

input group "==== GUI ===="
input bool   InpUseInputs      = false;  // Apply ALL inputs now and ignore the values saved by the panel buttons (switch it back off afterwards)
input ENUM_THEME InpTheme      = THEME_DARK;
input bool   InpChartTheme     = true;   // Also switch the chart colours with the theme (light = colour on white, dark = colour on near-black; trade levels / history settings are not touched)
input int    InpScale          = 100;    // Panel scale %
input int    InpFont           = 9;      // Font size
input int    InpPanelX         = 15;
input int    InpPanelY         = 25;
input int    InpPanelW         = 340;
input int    InpPanelH         = 520;
input int    InpDeviation      = 30;
input bool   InpTradeLevels    = true;   // Chart: show trade levels (applied at start)
input bool   InpTradeHistory   = false;  // Chart: show trade history (applied at start)

//--- constants / objects
// COMPACT ORDER COMMENTS (MT5 allows 31 characters):   <kind><side><id>.<index>
//   kind  G = grid order   L = live market order   P = pending order   T = tester auto trade
//   side  B = buy          S = sell
//   id    grid number (time based -> unique even when a PC and a VPS both place grids)
//   index order number inside the grid (0 = first order).   Examples:  GB482913.0   GS482913.3   LB   PS
// Any terminal that runs this EA with the same magic number on the same symbol recognises and manages these orders.
string CmLive(bool buy) { return buy ? "LB" : "LS"; }
string CmPend(bool buy) { return buy ? "PB" : "PS"; }
string CmTest(bool buy) { return buy ? "TB" : "TS"; }
string CmGrid(bool buy, int id, int k) { return StringFormat("G%s%d.%d", buy ? "B" : "S", id, k); }
bool CmIsGrid(const string c)
{
   if(StringLen(c) >= 4 && StringGetCharacter(c, 0) == 'G' && (StringGetCharacter(c, 1) == 'B' || StringGetCharacter(c, 1) == 'S')
      && StringGetCharacter(c, 2) >= '0' && StringGetCharacter(c, 2) <= '9') return true;
   return StringFind(c, InpComment + "_grid") == 0;                  // grids placed by the previous version
}
int CmGridId(const string c)
{
   if(StringFind(c, InpComment + "_grid") == 0) return (int)StringToInteger(StringSubstr(c, StringLen(InpComment) + 5));
   return (int)StringToInteger(StringSubstr(c, 2));
}
bool CmIsPend(const string c)
{
   return StringLen(c) >= 2 && StringGetCharacter(c, 0) == 'P' && (StringGetCharacter(c, 1) == 'B' || StringGetCharacter(c, 1) == 'S');
}
CTrade trade;
const string P = "PFP_";
const string V = "PFV_";

//--- runtime settings
double gDailyDD, gBuf, gMaxDD, gStartOv;
int    gScale, gFont;
bool   gDark;
int    gPx, gPy, gPw, gPh;
int    gTab = 0;
bool   gBuy = true;
long   gMagic;
double gLot, gRisk;
bool   gTpOn = true, gSlOn = true, gAuto;
int    gTpPts, gSlPts, gMinDist;
double gGRisk, gGInc, gGTPVal;
int    gGN, gGTP1, gGMin; double gGDistPct;
bool   gGTPMoney;
int    gSRMode = 0;      // 0 aggressive, 1 conservative
bool   gChartTheme = true;
int    gPendType = 0;    // pending tab: 0 both, 1 limit only, 2 stop only
bool   gTester = false, gVisual = true, gGui = true, gTestAuto = false;   // strategy tester flags (live: tester=false, gui=true)
datetime gTestBar = 0;

//--- hedge-aware risk model: every open position / pending order of the account as an "item"
struct RItem { int si; int dir; double vol; double ref; double sl; double tp; bool pend; bool cand; int gid; };
RItem  gRI[]; int gRN = 0;
string gRS[]; double gRPv[]; double gRLv[]; int gRSN = 0;   // symbol table: money per 1.0 price unit per lot (profit / loss side)

//--- margin context (leverage rules)
struct MCtx { double mOther; double nb; double ns; double rB; double rS; };
MCtx   gMC; uint gMCT = 0; int gMCpos = -1;
bool   gMin = false;                  // panel minimized (title bar only)
bool   gMgrDelay = false, gGMoveTP = true;
string gGateK[32]; uint gGateT[32];
bool   gGInitTP = true, gAllow2nd = false, gGWasBlk = false, gGEdited = false; uint gGRefT = 0;
bool   gGMarginOK = true, gGCapped = false; int gGFailAt = -1; double gGMaxUse = 0;
bool   gLotCapped = false;

//--- extend grid (two-click: plan, then confirm)
bool   gXArmed = false; uint gXTime = 0; int gXId = -1, gXN = 0;
double gXSL = 0, gXScale = 1.0, gXRisk = 0, gXAllow = 0, gXCurSL = 0, gXExt = 0, gXLastLot = 0;
double gXPx[8], gXLots[8], gXFirst = 0;
double gSnPx[48], gSnVol[48]; bool gSnPend[48]; int gSnN = 0;

//--- profit goals / grid extras
double gPassPct, gDayMax, gBkVal, gTrVal;
bool   gDayMaxM, gBkOn, gBkM, gTrailOn, gTrM;
double gBkPeak = 0; bool gBkArmed = false;
bool   gGTP1Auto, gBEOn; double gBEBuf, gBETrig;
string gLastClk = ""; uint gLastClkT = 0;

//--- stats
double   gStartAuto = 0; bool gStartFound = false;
datetime gDayStart = 0;  double gDayBal = 0, gDayEq = 0, gDayRef = 0; bool gEqEst = false;
double   gEq, gBal, gStartEff, gDailyLim, gDailyTrig, gDayLoss, gMaxFloor, gMaxTrig, gMaxUsed, gAllow;
int      gLock = 0;      // 0 none, 1 daily, 2 max DD
datetime gLockDay = 0;
string   gMsg = "";      bool gMsgBad = false;

//--- S/R
struct SRLevel { double price; double score; int touches; double lo; double hi; };   // lo/hi = lowest/highest pivot inside the zone
SRLevel gSR[]; int gSRn = 0; double gATR = 0; datetime gSRBar = 0; ENUM_TIMEFRAMES gSRTf = PERIOD_CURRENT; uint gSRTry = 0;

//--- preview state
double lvSL = 0, lvTP = 0; bool lvSLd = false, lvTPd = false;
double pdE = 0, pdSL = 0, pdTP = 0; bool pdUseSug = true;
double sugTP[3], sugSL[3];
struct Sug { double e; double sl; double tp; int type; bool ok; };
Sug    gPS[3];
double gGPx[8], gGLots[8]; int gGCnt = 4; double gGSL = 0, gGTP = 0, gGRiskAct = 0;
bool   gGPlanned = false, gGDirty = true, gGHidden = false, gHidePrev = false;

//--- colors
color cBG, cHdr, cTxt, cDim, cBtn, cEdit, cBord, cAcc, cBuy, cSell, cGood, cBad, cWarn, cYel, cOra;
color cOnBg, cOnFg, cOffBg, cOffFg, cAggBg, cAggFg;   // toggle buttons: ON = green shade, OFF = grey shade; S/R mode: aggressive = light red, conservative = light green

//--- layout
int gLX, gLW, gRH, gCY, gPad, gPwE, gPhE, gFE = 9;

//--- mouse drag
int gMode = 0, gMx0, gMy0, gPx0, gPy0, gPw0, gPh0; uint gLastRB = 0;
//--- preview line drag (own mouse handling: one click, drag, release)
string gDragLn = ""; bool gPrevDown = false; bool gNewObj = false;

void CountGrids(int &nb, int &ns);   // defined in the grid section
void ExtDraw();                      // defined in the grid section
int CollectGrids(int &ids[], bool &buys[]);
bool GridBlocked();                  // defined in the grid section
string GridNote(color &c);           // defined in the grid section
bool HitObj(string n, int x, int y);   // defined with the mouse handling
void UpdateUI();
double SpD();

//+------------------------------------------------------------------+
//| helpers                                                          |
//+------------------------------------------------------------------+
double NP(double p) { return NormalizeDouble(p, _Digits); }
double Ask() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
double Bid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
double MinStop() { return (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * _Point; }
double VPP()
{
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);   // risk is always computed on the LOSS side
   if(tv <= 0) tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0) return 0;
   return tv * _Point / ts;   // money per point per 1.0 lot
}
double NormVol(double v)
{
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(st <= 0) st = 0.01;
   v = MathFloor(v / st + 1e-9) * st;
   v = MathMax(mn, MathMin(mx, v));
   int d = (int)MathMax(0, MathRound(-MathLog10(st)));
   return NormalizeDouble(v, d);
}
double RiskBase() { return gStartEff > 0 ? gStartEff : AccountInfoDouble(ACCOUNT_BALANCE); }
ENUM_TIMEFRAMES EffTF() { return (InpSRTF == PERIOD_CURRENT) ? (ENUM_TIMEFRAMES)_Period : InpSRTF; }
int PipPts()   // points per pip
{
   if(InpPipPoints > 0) return InpPipPoints;
   if(_Digits == 3 || _Digits == 5) return 10;
   string sy = _Symbol; StringToUpper(sy);
   if(_Digits == 2 && (StringFind(sy, "XAU") >= 0 || StringFind(sy, "XAG") >= 0 || StringFind(sy, "GOLD") >= 0 || StringFind(sy, "SILVER") >= 0)) return 10;
   return 1;
}
double Pips(double pts) { return pts / (double)PipPts(); }
double GoalMoney(double v, bool money, double base) { return money ? v : base * v / 100.0; }
string Ccy() { return AccountInfoString(ACCOUNT_CURRENCY); }
bool   Cons() { return gSRMode == 1; }
string PendTypeText() { return gPendType == 0 ? "Pending type: BOTH (limit + stop) - next" : (gPendType == 1 ? "Pending type: LIMIT only - next" : "Pending type: STOP only - next"); }
double SLBuf()   { return gATR * InpSLBufATR * (Cons() ? InpConsSLBufMult : 1.0) + SpD(); }   // SL buffer beyond a level + the spread (SL only)
double GMinEff() { return (double)gGMin * (Cons() ? InpConsGridMinMult : 1.0); }              // min gap between grid orders (points)
double SRMinDist()                                                                           // min distance of a suggested SL/TP from the price
{
   double ms = MinStop() + 5 * _Point;
   if(Cons()) ms = MathMax(ms, gATR * InpConsMinDistATR);
   return ms;
}
double SpD() { return MathMax(0.0, Ask() - Bid()); }                       // spread in price units
int    SpP() { return (int)MathRound(SpD() / _Point); }                      // spread in points
int    BasePts(double dist) { return (int)MathMax(1.0, MathRound(dist / _Point) - SpP()); }   // line distance -> the "pts" box (spread excluded)
int    TpPtsOf(double dist) { return (int)MathMax(1.0, MathRound(dist / _Point)); }      // TP distance -> the "pts" box (the spread is NOT added to take profits)
double GridTpPx(double e0) { return NP(gBuy ? e0 + gGTP1 * _Point : e0 - gGTP1 * _Point); }
string RiskPct(double money) { double b = RiskBase(); return b > 0 ? StringFormat("%.2f%%", money / b * 100.0) : "-"; }

string LockTag()
{
   switch(gLock)
   {
      case 1: return "  [DAILY LOCK]";
      case 2: return "  [MAX DD LOCK]";
      case 3: return "  [TARGET REACHED]";
      case 4: return "  [DAILY PROFIT LOCK]";
   }
   return "";
}
string HdrText()
{
   int cap = (int)((gPwE - gFE * 6.0 - gFE * 2.4 - 8) / (gFE * 0.72));
   string tag = LockTag();
   if(StringLen(APP_NAME) + StringLen(tag) <= cap) return APP_NAME + tag;
   if(StringLen(APP_SHORT) + StringLen(tag) <= cap) return APP_SHORT + tag;
   return "Prop-firm S/R Panel" + tag;
}
string LockText()
{
   switch(gLock)
   {
      case 0: return "ACTIVE";
      case 1: return "LOCKED - daily";
      case 2: return "LOCKED - max DD";
      case 3: return "LOCKED - target reached";
   }
   return "LOCKED - daily profit goal";
}
// drawdown colour escalates yellow -> orange -> red (never green)
color DDCol(double ratio, bool breached)
{
   double p = ratio * 100.0;
   if(breached || p >= InpDDRedPct) return cBad;
   if(p >= InpDDOrangePct) return cOra;
   return cYel;
}
uint gMsgT = 0;
void SetMsg(string m, bool bad = false) { gMsg = m; gMsgBad = bad; gMsgT = GetTickCount(); Print("PFP: ", m); }

string GK(string k) { return "PFP" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) + "_" + k; }
double GVG(string k, double d) { string n = GK(k); return GlobalVariableCheck(n) ? GlobalVariableGet(n) : d; }
// A value saved by the panel (theme, scale, font, limits ...) only wins over its INPUT while that input is unchanged since the last start.
// Change an input in the properties dialog and the new input value is applied; "InpUseInputs" applies all inputs at once.
double GVI(string k, double inp)
{
   string ik = "in_" + k;
   bool same = GlobalVariableCheck(GK(ik)) && MathAbs(GVG(ik, inp) - inp) < 1e-9;
   GlobalVariableSet(GK(ik), inp);
   if(InpUseInputs || !same) return inp;
   return GVG(k, inp);
}
void   GVS(string k, double v) { GlobalVariableSet(GK(k), v); }

void SaveCfg()
{
   GVS("dd", gDailyDD); GVS("buf", gBuf); GVS("maxdd", gMaxDD); GVS("startov", gStartOv);
   GVS("scale", gScale); GVS("font", gFont); GVS("dark", gDark ? 1 : 0);
   GVS("x", gPx); GVS("y", gPy); GVS("w", gPw); GVS("h", gPh);
   GVS("pass", gPassPct); GVS("dmax", gDayMax); GVS("dmaxm", gDayMaxM ? 1 : 0);
   GVS("bkon", gBkOn ? 1 : 0); GVS("bkv", gBkVal); GVS("bkm", gBkM ? 1 : 0);
   GVS("trail", gTrailOn ? 1 : 0); GVS("trv", gTrVal); GVS("trm", gTrM ? 1 : 0);
   GVS("tp1auto", gGTP1Auto ? 1 : 0); GVS("beon", gBEOn ? 1 : 0); GVS("bebuf", gBEBuf); GVS("betrig", gBETrig);
   GVS("srmode", gSRMode); GVS("ptype", gPendType); GVS("gitp", gGInitTP ? 1 : 0); GVS("mgd", gMgrDelay ? 1 : 0); GVS("pmin", gMin ? 1 : 0); GVS("gmtp", gGMoveTP ? 1 : 0);
}
void SaveBk() { GVS("bkarm", gBkArmed ? 1 : 0); GVS("bkpeak", gBkPeak); }
void SaveLock() { GVS("lock", gLock); GVS("lockday", (double)gLockDay); }

void SetTheme()
{
   if(gDark)
   {
      cBG = C'30,33,40'; cHdr = C'18,20,26'; cTxt = C'225,228,235'; cDim = C'150,155,168';
      cBtn = C'52,57,70'; cEdit = C'18,20,26'; cBord = C'70,76,92'; cAcc = C'0,140,230';
   }
   else
   {
      cBG = C'243,244,247'; cHdr = C'214,218,228'; cTxt = C'25,28,35'; cDim = C'100,105,118';
      cBtn = C'208,212,224'; cEdit = clrWhite; cBord = C'170,175,190'; cAcc = C'0,102,180';
   }
   cBuy = C'20,140,95'; cSell = C'200,60,60'; cGood = C'40,170,100'; cBad = C'220,70,70';
   if(gDark) { cWarn = C'230,170,40'; cYel = C'240,214,50'; cOra = C'240,128,32'; }
   else      { cWarn = C'170,105,0';  cYel = C'166,118,0';  cOra = C'205,92,0'; }   // light mode: darker yellow / amber / orange for contrast
   if(gDark)
   {
      cOnBg  = C'32,112,74';   cOnFg  = clrWhite;
      cOffBg = C'40,44,54';    cOffFg = C'150,155,168';
      cAggBg = C'140,62,62';   cAggFg = clrWhite;
   }
   else
   {
      cOnBg  = C'150,220,175'; cOnFg  = C'10,60,30';
      cOffBg = C'228,231,239'; cOffFg = C'100,105,118';
      cAggBg = C'244,178,178'; cAggFg = C'90,20,20';
   }
}

//--- chart colours that follow the theme (only colours: trade levels, trade history, grid on/off, chart type stay as the user set them)
const int gChartProps[] = { CHART_COLOR_BACKGROUND, CHART_COLOR_FOREGROUND, CHART_COLOR_GRID, CHART_COLOR_VOLUME, CHART_COLOR_CHART_UP,
                            CHART_COLOR_CHART_DOWN, CHART_COLOR_CHART_LINE, CHART_COLOR_CANDLE_BULL, CHART_COLOR_CANDLE_BEAR,
                            CHART_COLOR_BID, CHART_COLOR_ASK, CHART_COLOR_LAST, CHART_COLOR_STOP_LEVEL };
void SaveChartOrig()      // remember the user's own chart colours once, to give them back when the EA is removed
{
   if(GlobalVariableCheck(GK("cho0"))) return;
   for(int i = 0; i < ArraySize(gChartProps); i++)
      GVS("cho" + IntegerToString(i), (double)ChartGetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)gChartProps[i]));
}
void RestoreChartOrig()
{
   if(!GlobalVariableCheck(GK("cho0"))) return;
   for(int i = 0; i < ArraySize(gChartProps); i++)
   {
      ChartSetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)gChartProps[i], (long)GVG("cho" + IntegerToString(i), 0));
      GlobalVariableDel(GK("cho" + IntegerToString(i)));
   }
   ChartRedraw();
}
void ApplyChartTheme()
{
   if(!gChartTheme) return;
   color bg, fg, grid, vol, up, dn, line, bid, ask, last, stp;
   if(gDark)      // colour on near-black
   {
      bg = C'12,13,17';  fg = C'170,176,190'; grid = C'36,39,48'; vol = C'110,116,132';
      up = C'38,190,150'; dn = C'240,84,84'; line = C'110,170,255';
      bid = C'90,150,255'; ask = C'255,150,90'; last = C'150,155,170'; stp = C'240,84,84';
   }
   else           // colour on white
   {
      bg = clrWhite;     fg = C'55,60,72';    grid = C'226,229,236'; vol = C'120,126,140';
      up = C'0,150,110'; dn = C'215,50,50';   line = C'30,90,200';
      bid = C'30,90,200'; ask = C'210,100,30'; last = C'110,115,130'; stp = C'215,50,50';
   }
   color v[13];                                          // same order as gChartProps; candle bull / bear take the up / down colours
   v[0] = bg; v[1] = fg; v[2] = grid; v[3] = vol; v[4] = up; v[5] = dn; v[6] = line; v[7] = up; v[8] = dn; v[9] = bid; v[10] = ask; v[11] = last; v[12] = stp;
   for(int i = 0; i < 13; i++) ChartSetInteger(0, (ENUM_CHART_PROPERTY_INTEGER)gChartProps[i], (long)v[i]);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| S/R finder (pivot clustering, never drawn)                       |
//+------------------------------------------------------------------+
// conservative mode: keep only the strongest levels and enforce real room between neighbouring levels
void ConsFilter()
{
   if(gSRn <= 3) return;
   int keep = (int)MathMax(3.0, MathCeil(gSRn * InpConsKeepPct / 100.0));
   while(gSRn > keep)
   {
      int mi = 0;
      for(int i = 1; i < gSRn; i++) if(gSR[i].score < gSR[mi].score) mi = i;
      for(int i = mi; i < gSRn - 1; i++) gSR[i] = gSR[i + 1];
      gSRn--;
   }
   double gap = gATR * InpConsMinGapATR;
   bool ch = true;
   while(ch && gSRn > 1)
   {
      ch = false;
      for(int i = 0; i < gSRn - 1; i++)
         if(gSR[i + 1].price - gSR[i].price < gap)
         {
            int rm = (gSR[i].score >= gSR[i + 1].score) ? i + 1 : i;     // the weaker of the two goes
            for(int j = rm; j < gSRn - 1; j++) gSR[j] = gSR[j + 1];
            gSRn--; ch = true; break;
         }
   }
   ArrayResize(gSR, gSRn);
}

void BuildSR()
{
   ENUM_TIMEFRAMES tf = EffTF(); gSRTf = tf;     // always the CURRENT chart timeframe unless a fixed one is set in the inputs
   int k = MathMax(1, InpSRStrength);
   int lookback = InpSRLookback, minTouch = InpSRMinTouches; double clusterX = InpSRClusterATR;
   if(Cons())
   {
      k = (int)MathMax((double)(k + 1), MathRound(k * InpConsStrengthMult));
      lookback = (int)(lookback * InpConsLookbackMult);
      clusterX *= InpConsClusterMult;
      minTouch += InpConsExtraTouches;
   }
   MqlRates r[]; ArraySetAsSeries(r, true);
   int n = CopyRates(_Symbol, tf, 0, lookback + k + 5, r);
   gSRn = 0; ArrayResize(gSR, 0);
   if(n < 2 * k + 20) return;
   int ac = MathMin(14, n - 2); double a = 0;
   for(int i = 1; i <= ac; i++) a += (r[i].high - r[i].low);
   gATR = a / ac;
   double tol = MathMax(gATR * clusterX, _Point * 3);

   double pp[], pw[]; int pc = 0;
   for(int i = k; i < n - k; i++)
   {
      bool h = true, l = true;
      for(int j = 1; j <= k; j++)
      {
         if(r[i].high < r[i - j].high || r[i].high < r[i + j].high) h = false;
         if(r[i].low  > r[i - j].low  || r[i].low  > r[i + j].low)  l = false;
      }
      double w = 1.0 - 0.5 * (double)i / (double)n;   // recent pivots weigh more
      if(h) { ArrayResize(pp, pc + 1); ArrayResize(pw, pc + 1); pp[pc] = r[i].high; pw[pc] = w; pc++; }
      if(l) { ArrayResize(pp, pc + 1); ArrayResize(pw, pc + 1); pp[pc] = r[i].low;  pw[pc] = w; pc++; }
   }
   for(int i = 1; i < pc; i++)
   {
      double kp = pp[i], kw = pw[i]; int j = i - 1;
      while(j >= 0 && pp[j] > kp) { pp[j + 1] = pp[j]; pw[j + 1] = pw[j]; j--; }
      pp[j + 1] = kp; pw[j + 1] = kw;
   }
   double sp = 0, sw = 0, clo = 0, chi = 0; int cn = 0;
   for(int i = 0; i <= pc; i++)
   {
      bool flush = false;
      if(i == pc) flush = true;
      else if(cn > 0 && MathAbs(pp[i] - sp / cn) > tol) flush = true;
      if(flush && cn > 0)
      {
         if(cn >= minTouch)
         {
            ArrayResize(gSR, gSRn + 1);
            gSR[gSRn].price = sp / cn; gSR[gSRn].touches = cn; gSR[gSRn].score = sw;
            gSR[gSRn].lo = clo; gSR[gSRn].hi = chi; gSRn++;
         }
         sp = 0; sw = 0; cn = 0;
      }
      if(i < pc) { if(cn == 0) clo = pp[i]; chi = pp[i]; sp += pp[i]; sw += pw[i]; cn++; }
   }
   ArrayResize(gSR, gSRn);
   if(Cons()) ConsFilter();
   while(gSRn > InpSRMaxLevels)
   {
      int mi = 0;
      for(int i = 1; i < gSRn; i++) if(gSR[i].score < gSR[mi].score) mi = i;
      for(int i = mi; i < gSRn - 1; i++) gSR[i] = gSR[i + 1];
      gSRn--;
   }
   ArrayResize(gSR, gSRn);
}
// levels strictly above 'price', nearest first
int Above(double price, int cnt, double &o[])
{
   ArrayResize(o, 0); int k = 0;
   for(int i = 0; i < gSRn && k < cnt; i++)
      if(gSR[i].price > price) { ArrayResize(o, k + 1); o[k++] = gSR[i].price; }
   return k;
}
// levels strictly below 'price', nearest first
int Below(double price, int cnt, double &o[])
{
   ArrayResize(o, 0); int k = 0;
   for(int i = gSRn - 1; i >= 0 && k < cnt; i--)
      if(gSR[i].price < price) { ArrayResize(o, k + 1); o[k++] = gSR[i].price; }
   return k;
}
// index of the nearest zone whose centre is below / above 'price' (-1 = none)
int LvBelow(double price) { for(int i = gSRn - 1; i >= 0; i--) if(gSR[i].price < price) return i; return -1; }
int LvAbove(double price) { for(int i = 0; i < gSRn; i++) if(gSR[i].price > price) return i; return -1; }

//+------------------------------------------------------------------+
//| account stats + prop firm guard                                  |
//+------------------------------------------------------------------+
void DetectStart()
{
   if(gStartFound) return;
   if(!HistorySelect(0, TimeCurrent() + 86400)) return;
   int n = HistoryDealsTotal(); double tradePL = 0, other = 0;
   for(int i = 0; i < n; i++)
   {
      ulong t = HistoryDealGetTicket(i);
      long ty = HistoryDealGetInteger(t, DEAL_TYPE);
      double pr = HistoryDealGetDouble(t, DEAL_PROFIT);
      if(ty == DEAL_TYPE_BALANCE && pr > 0) { gStartAuto = pr; gStartFound = true; return; }
      if(ty == DEAL_TYPE_BUY || ty == DEAL_TYPE_SELL)
         tradePL += pr + HistoryDealGetDouble(t, DEAL_SWAP) + HistoryDealGetDouble(t, DEAL_COMMISSION) + HistoryDealGetDouble(t, DEAL_FEE);
   }
   // no deposit deal visible (history not loaded / reset account): estimate and snap to a standard size
   double est = AccountInfoDouble(ACCOUNT_BALANCE) - tradePL - other;
   if(est <= 0) est = AccountInfoDouble(ACCOUNT_BALANCE);
   double std[] = {1000,2000,2500,3000,5000,6000,8000,10000,15000,20000,25000,30000,40000,50000,60000,75000,80000,100000,150000,200000,250000,300000,400000,500000,1000000};
   for(int i = 0; i < ArraySize(std); i++)
      if(MathAbs(est - std[i]) / std[i] < 0.03) { est = std[i]; break; }
   gStartAuto = est;
}

//--- New York time (for the FXIFY daily reset at 5 PM New York)
datetime NthSunday(int y, int m, int n)   // 00:00 of the n-th Sunday of a month (pure calendar maths)
{
   MqlDateTime s;
   s.year = y; s.mon = m; s.day = 1; s.hour = 0; s.min = 0; s.sec = 0; s.day_of_week = 0; s.day_of_year = 0;
   datetime first = StructToTime(s);
   MqlDateTime f; TimeToStruct(first, f);
   int firstSun = 1 + ((7 - f.day_of_week) % 7);
   s.day = firstSun + (n - 1) * 7;
   return StructToTime(s);
}
int NYOffset(datetime gmt)   // seconds to ADD to GMT to get New York local time
{
   if(!InpNYDst) return -5 * 3600;
   MqlDateTime d; TimeToStruct(gmt, d);
   datetime dstStart = NthSunday(d.year, 3, 2) + 7 * 3600;    // 2nd Sunday of March, 02:00 EST = 07:00 UTC
   datetime dstEnd   = NthSunday(d.year, 11, 1) + 6 * 3600;   // 1st Sunday of November, 02:00 EDT = 06:00 UTC
   return (gmt >= dstStart && gmt < dstEnd) ? -4 * 3600 : -5 * 3600;
}
// start of the current trading day, expressed in SERVER time (deal history uses server time)
datetime DayStartServer(datetime nowSrv)
{
   datetime gmt = TimeGMT();
   if(InpDayMode == DAY_SERVER || gmt <= 0)
   {
      long sh = (long)InpRolloverShiftH * 3600;
      return (datetime)((((long)nowSrv - sh) / 86400) * 86400 + sh);
   }
   long srvOff = (long)nowSrv - (long)gmt;
   srvOff = (long)MathRound((double)srvOff / 900.0) * 900;           // server offset, snapped to 15 minutes
   int  off = NYOffset(gmt);
   long rs  = (long)MathMax(0, MathMin(23, InpRolloverNYHour)) * 3600;
   long nyNow = (long)gmt + off;
   long nyStart = ((nyNow - rs) / 86400) * 86400 + rs;               // last 17:00 New York (as a New York wall-clock number)
   long gmtStart = nyStart - off;
   int  off2 = NYOffset((datetime)gmtStart);
   if(off2 != off) gmtStart = nyStart - off2;
   return (datetime)(gmtStart + srvOff);
}

void RefreshHistory()
{
   datetime now = TimeTradeServer();
   datetime ds = DayStartServer(now);
   if(HistorySelect(ds, now + 3600))
   {
      double sum = 0; int n = HistoryDealsTotal();
      for(int i = 0; i < n; i++)
      {
         ulong t = HistoryDealGetTicket(i);
         long ty = HistoryDealGetInteger(t, DEAL_TYPE);
         if(ty == DEAL_TYPE_BUY || ty == DEAL_TYPE_SELL)
            sum += HistoryDealGetDouble(t, DEAL_PROFIT) + HistoryDealGetDouble(t, DEAL_SWAP)
                 + HistoryDealGetDouble(t, DEAL_COMMISSION) + HistoryDealGetDouble(t, DEAL_FEE);
      }
      gDayBal = AccountInfoDouble(ACCOUNT_BALANCE) - sum;
   }
   else if(gDayBal <= 0) gDayBal = AccountInfoDouble(ACCOUNT_BALANCE);
   if(ds != gDayStart)
   {
      bool first = (gDayStart == 0);
      gDayStart = ds;
      if(first && GVG("eqday", 0) == (double)ds) { gDayEq = GVG("eq", gDayBal); gEqEst = false; }
      else if(first) { gDayEq = gDayBal; gEqEst = true; }   // EA attached mid-day: equity at rollover unknown, estimate
      else { gDayEq = AccountInfoDouble(ACCOUNT_EQUITY); gEqEst = false; }
      if(!gEqEst) { GVS("eqday", (double)ds); GVS("eq", gDayEq); }
      if((gLock == 1 || gLock == 4) && gLockDay != ds) { gLock = 0; SaveLock(); SetMsg("New day: daily lock released"); }
   }
   DetectStart();
}

void UpdateStats()
{
   gEq = AccountInfoDouble(ACCOUNT_EQUITY); gBal = AccountInfoDouble(ACCOUNT_BALANCE);
   gStartEff = (gStartOv > 0) ? gStartOv : (gStartAuto > 0 ? gStartAuto : gBal);
   double rb = (gDayBal > 0 ? gDayBal : gBal), re = (gDayEq > 0 ? gDayEq : rb);
   gDayRef    = (InpDDRef == DDREF_EQUITY) ? re : ((InpDDRef == DDREF_HIGHER) ? MathMax(rb, re) : rb);
   gDailyLim  = gDayRef * gDailyDD / 100.0;
   gDailyTrig = gDailyLim * (1.0 - gBuf / 100.0);
   gDayLoss   = gDayRef - gEq;
   gMaxFloor  = gStartEff * (1.0 - gMaxDD / 100.0);
   gMaxTrig   = gMaxFloor + gStartEff * gMaxDD / 100.0 * InpMaxBufferPct / 100.0;
   gMaxUsed   = gStartEff - gEq;
   gAllow     = MathMin(gDailyTrig - gDayLoss, gEq - gMaxTrig);
}

bool InScope(const string sym, long magic)
{
   if(InpCloseScope == SCOPE_ACCOUNT) return true;
   if(InpCloseScope == SCOPE_SYMBOL)  return sym == _Symbol;
   return (sym == _Symbol && magic == gMagic);
}

//--- management delay for two terminals on one account: an automatic action is only taken when its condition has been true for
//    1 full second (when the delay is switched on). The terminal WITHOUT delay acts first; the delayed one then finds nothing left to do.
bool Gate(const string key, bool cond)
{
   int slot = -1, fr = -1;
   for(int i = 0; i < 32; i++)
   {
      if(gGateK[i] == key) { slot = i; break; }
      if(fr < 0 && gGateK[i] == "") fr = i;
   }
   if(!cond) { if(slot >= 0) gGateK[slot] = ""; return false; }
   if(!gMgrDelay || gTester) return true;
   if(slot < 0)
   {
      if(fr < 0) return true;                       // table full: never block a protective action
      gGateK[fr] = key; gGateT[fr] = GetTickCount();
      return false;
   }
   return GetTickCount() - gGateT[slot] >= 1000;
}
void SetTimerRate()
{
   EventKillTimer();
   if(gTester && !gVisual) EventSetTimer(30);
   else if(gMgrDelay && !gTester) EventSetMillisecondTimer(250);   // a 1 s delay needs a finer clock
   else EventSetTimer(1);
}

//--- close / modify / delete that respect the broker's FREEZE level and never hammer the server:
//    a position whose SL/TP (or a pending order whose price) is inside the freeze distance cannot be closed / modified
//    ("Modification failed due to order or position being close to market"). The server's own SL/TP handles it, so we wait;
//    after any failed attempt the same ticket is left alone for a few seconds (simulated time in the tester).
ulong gCbTk[32]; datetime gCbUntil[32];
bool CbBlocked(ulong t)
{
   datetime now = TimeCurrent();
   for(int i = 0; i < 32; i++) if(gCbTk[i] == t && gCbUntil[i] > now) return true;
   return false;
}
void CbSet(ulong t, int secs)
{
   datetime now = TimeCurrent(); int slot = -1;
   for(int i = 0; i < 32; i++)
   {
      if(gCbTk[i] == t) { slot = i; break; }
      if(slot < 0 && (gCbTk[i] == 0 || gCbUntil[i] <= now)) slot = i;
   }
   if(slot < 0) slot = 0;
   gCbTk[slot] = t; gCbUntil[slot] = now + secs;
}
double FreezeDist(const string sym) { return (double)SymbolInfoInteger(sym, SYMBOL_TRADE_FREEZE_LEVEL) * SymbolInfoDouble(sym, SYMBOL_POINT); }
bool PosFrozen()          // the SELECTED position
{
   string sy = PositionGetString(POSITION_SYMBOL); double fz = FreezeDist(sy);
   if(fz <= 0) return false;
   double px = SymbolInfoDouble(sy, PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? SYMBOL_BID : SYMBOL_ASK);
   double sl = PositionGetDouble(POSITION_SL), tp = PositionGetDouble(POSITION_TP);
   return (tp > 0 && MathAbs(tp - px) <= fz) || (sl > 0 && MathAbs(px - sl) <= fz);
}
bool OrdFrozen()          // the SELECTED pending order
{
   string sy = OrderGetString(ORDER_SYMBOL); double fz = FreezeDist(sy);
   if(fz <= 0) return false;
   long ot = OrderGetInteger(ORDER_TYPE);
   bool buy = (ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP || ot == ORDER_TYPE_BUY_STOP_LIMIT);
   double px = SymbolInfoDouble(sy, buy ? SYMBOL_ASK : SYMBOL_BID);
   return MathAbs(OrderGetDouble(ORDER_PRICE_OPEN) - px) <= fz;
}
bool ClosePos(ulong t)
{
   if(CbBlocked(t)) return false;
   if(!PositionSelectByTicket(t)) return false;
   if(PosFrozen()) { CbSet(t, 2); return false; }
   if(trade.PositionClose(t)) return true;
   CbSet(t, 3);
   Print("PFP: close #", t, " refused (", trade.ResultRetcodeDescription(), ") - will retry in a few seconds");
   return false;
}
bool ModPos(ulong t, double sl, double tp)
{
   if(CbBlocked(t)) return false;
   if(!PositionSelectByTicket(t)) return false;
   if(PosFrozen()) { CbSet(t, 2); return false; }
   if(trade.PositionModify(t, sl, tp)) return true;
   CbSet(t, 3);
   return false;
}
bool ModOrd(ulong t, double tp)       // change only the TP of a pending order
{
   if(CbBlocked(t)) return false;
   if(!OrderSelect(t)) return false;
   if(OrdFrozen()) { CbSet(t, 2); return false; }
   if(trade.OrderModify(t, OrderGetDouble(ORDER_PRICE_OPEN), OrderGetDouble(ORDER_SL), tp, ORDER_TIME_GTC, 0)) return true;
   CbSet(t, 3);
   return false;
}
bool DelOrd(ulong t)
{
   if(CbBlocked(t)) return false;
   if(!OrderSelect(t)) return false;
   if(OrdFrozen()) { CbSet(t, 2); return false; }
   if(trade.OrderDelete(t)) return true;
   CbSet(t, 3);
   return false;
}

void CloseEverything(string why)
{
   trade.SetDeviationInPoints(InpDeviation * 3);
   for(int pass = 0; pass < 3; pass++)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      { ulong t = PositionGetTicket(i); if(t > 0) ClosePos(t); }
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      { ulong t = OrderGetTicket(i); if(t > 0) DelOrd(t); }
      if(PositionsTotal() == 0 && OrdersTotal() == 0) break;
   }
   trade.SetDeviationInPoints(InpDeviation);
   if(PositionsTotal() == 0 && OrdersTotal() == 0) Print("PFP guard: closed everything - ", why);
}

void CheckLimits()
{
   UpdateStats();
   if(gLock != 0)
   {
      if(Gate("lockclr", PositionsTotal() > 0 || OrdersTotal() > 0)) CloseEverything("trading locked");
      return;
   }
   if(Gate("maxdd", gStartEff > 0 && gEq <= gMaxTrig))
   {
      Gate("maxdd", false);
      CloseEverything("MAX DD reached");
      gLock = 2; SaveLock();
      string m = "MAX DRAWDOWN reached - everything closed, trading locked";
      SetMsg(m, true); Alert("PropFirm guard: ", m);
   }
   else if(Gate("dayd", gDailyTrig > 0 && gDayLoss >= gDailyTrig))
   {
      Gate("dayd", false);
      CloseEverything("daily DD buffer reached");
      gLock = 1; gLockDay = gDayStart; SaveLock();
      string m = "DAILY DD buffer reached - everything closed, locked until next day";
      SetMsg(m, true); Alert("PropFirm guard: ", m);
   }
}

//+------------------------------------------------------------------+
//| profit goals (virtual: the EA closes things itself)              |
//+------------------------------------------------------------------+
int CountScopePos()
{
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(InScope(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC))) n++;
   }
   return n;
}
int CountScopeAll()
{
   int n = CountScopePos();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(InScope(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC))) n++;
   }
   return n;
}
double FloatScope()
{
   double f = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(InScope(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC)))
         f += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return f;
}
int CountScopeGridPend()
{
   int n = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(InScope(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC)) && CmIsGrid(OrderGetString(ORDER_COMMENT))) n++;
   }
   return n;
}
// BASKET close: every open position in the close scope (also trades not created by this EA, depending on the scope setting)
// + the pending orders that are part of a grid. Ordinary pending orders are NOT touched.
void CloseScopeAll(string why)
{
   trade.SetDeviationInPoints(InpDeviation * 3);
   for(int pass = 0; pass < 3; pass++)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong t = PositionGetTicket(i); if(t == 0) continue;
         if(InScope(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC))) ClosePos(t);
      }
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong t = OrderGetTicket(i); if(t == 0) continue;
         if(InScope(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC)) && CmIsGrid(OrderGetString(ORDER_COMMENT)))
            DelOrd(t);
      }
      if(CountScopePos() == 0 && CountScopeGridPend() == 0) break;
   }
   trade.SetDeviationInPoints(InpDeviation);
   if(CountScopePos() == 0 && CountScopeGridPend() == 0) Print("PFP basket: closed open trades + grid pendings in scope - ", why);
}

void CheckGoals()
{
   UpdateStats();
   if(gLock != 0) return;
   // 1) total profit needed to pass the challenge
   if(Gate("pass", gPassPct > 0 && gStartEff > 0 && gEq >= gStartEff * (1.0 + gPassPct / 100.0)))
   {
      Gate("pass", false);
      CloseEverything("profit target to pass reached");
      gBkArmed = false; gBkPeak = 0; SaveBk();
      gLock = 3; SaveLock();
      string m = StringFormat("PROFIT TARGET %.2f%% reached - everything closed, trading locked", gPassPct);
      SetMsg(m); Alert("PropFirm goals: ", m);
      return;
   }
   // 2) max desired daily profit
   if(Gate("dmax", gDayMax > 0 && gDayRef > 0 && -gDayLoss >= GoalMoney(gDayMax, gDayMaxM, gDayRef)))
   {
      Gate("dmax", false);
      CloseEverything("max daily profit reached");
      gBkArmed = false; gBkPeak = 0; SaveBk();
      gLock = 4; gLockDay = gDayStart; SaveLock();
      string m = StringFormat("MAX DAILY PROFIT reached (+%.2f) - everything closed, locked until next day", -gDayLoss);
      SetMsg(m); Alert("PropFirm goals: ", m);
      return;
   }
   // 3) basket / floating profit over ALL trades, pendings and grids in scope
   if(!gBkOn) { if(gBkArmed) { gBkArmed = false; gBkPeak = 0; } return; }
   if(CountScopePos() == 0) { Gate("bk", false); Gate("trl", false); if(gBkArmed) { gBkArmed = false; gBkPeak = 0; SaveBk(); } return; }
   double base = RiskBase(), fl = FloatScope(), tgt = GoalMoney(gBkVal, gBkM, base);
   if(tgt <= 0) return;
   if(!gTrailOn)
   {
      if(Gate("bk", fl >= tgt))
      {
         Gate("bk", false);
         CloseScopeAll("basket target reached");
         if(CountScopePos() == 0) SetMsg(StringFormat("Basket target reached (+%.2f) - open trades closed", fl));
      }
      return;
   }
   double tr = GoalMoney(gTrVal, gTrM, base);
   if(!gBkArmed)
   {
      if(fl >= tgt) { gBkArmed = true; gBkPeak = fl; SaveBk(); SetMsg(StringFormat("Basket trailing stop armed at +%.2f", fl)); }
      return;
   }
   if(fl > gBkPeak) gBkPeak = fl;
   if(Gate("trl", fl <= gBkPeak - tr))
   {
      Gate("trl", false);
      CloseScopeAll("basket trailing stop hit");
      if(CountScopePos() == 0)                       // still armed while a position could not be closed yet
      {
         SetMsg(StringFormat("Basket trail hit: closed at about +%.2f (peak +%.2f)", fl, gBkPeak));
         gBkArmed = false; gBkPeak = 0; SaveBk();
      }
   }
}

//+------------------------------------------------------------------+
//| risk gate                                                        |
//+------------------------------------------------------------------+
//--- every open position and pending order of the ACCOUNT (the daily DD is account-wide) becomes an item.
//    Worst case = the worst net result over every price the market could travel to from here, where each position
//    is stopped at its SL / closed at its TP when the price passes it.  Opposite positions therefore offset each other:
//    a buy grid on top of an open sell grid does NOT add risk, it reduces it.
//    Only OPEN positions earn hedge credit: pending orders count with their possible LOSS only (they may never fill).
int RI_Sym(const string s)
{
   for(int i = 0; i < gRSN; i++) if(gRS[i] == s) return i;
   ArrayResize(gRS, gRSN + 1); ArrayResize(gRPv, gRSN + 1); ArrayResize(gRLv, gRSN + 1);
   double tvp = SymbolInfoDouble(s, SYMBOL_TRADE_TICK_VALUE_PROFIT); if(tvp <= 0) tvp = SymbolInfoDouble(s, SYMBOL_TRADE_TICK_VALUE);
   double tvl = SymbolInfoDouble(s, SYMBOL_TRADE_TICK_VALUE_LOSS);   if(tvl <= 0) tvl = tvp;
   double ts  = SymbolInfoDouble(s, SYMBOL_TRADE_TICK_SIZE);
   gRS[gRSN] = s; gRPv[gRSN] = (ts > 0) ? tvp / ts : 0; gRLv[gRSN] = (ts > 0) ? tvl / ts : 0;   // money per 1.0 price unit per lot
   gRSN++;
   return gRSN - 1;
}
void RI_Add(const string sym, int dir, double vol, double ref, double sl, double tp, bool pend, bool cand, int gid)
{
   int si = RI_Sym(sym);
   ArrayResize(gRI, gRN + 1);
   gRI[gRN].si = si; gRI[gRN].dir = dir; gRI[gRN].vol = vol; gRI[gRN].ref = ref;
   gRI[gRN].sl = sl; gRI[gRN].tp = tp; gRI[gRN].pend = pend; gRI[gRN].cand = cand; gRI[gRN].gid = gid;
   gRN++;
}
void RI_Cut(int n) { if(n < 0) n = 0; if(n < gRN) { gRN = n; ArrayResize(gRI, n); } }
int  RI_GridOf(const string c) { return CmIsGrid(c) ? CmGridId(c) : -1; }

void RI_Load()
{
   gRN = 0; gRSN = 0;
   ArrayResize(gRI, 0); ArrayResize(gRS, 0); ArrayResize(gRPv, 0); ArrayResize(gRLv, 0);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      string sy = PositionGetString(POSITION_SYMBOL);
      int dir = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 1 : -1;
      RI_Add(sy, dir, PositionGetDouble(POSITION_VOLUME), PositionGetDouble(POSITION_PRICE_CURRENT),
             PositionGetDouble(POSITION_SL), PositionGetDouble(POSITION_TP), false, false, RI_GridOf(PositionGetString(POSITION_COMMENT)));
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      long ot = OrderGetInteger(ORDER_TYPE); int dir = 0;
      if(ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP) dir = 1;
      else if(ot == ORDER_TYPE_SELL_LIMIT || ot == ORDER_TYPE_SELL_STOP) dir = -1;
      if(dir == 0) continue;
      double sl = OrderGetDouble(ORDER_SL); if(sl <= 0) continue;
      RI_Add(OrderGetString(ORDER_SYMBOL), dir, OrderGetDouble(ORDER_VOLUME_CURRENT), OrderGetDouble(ORDER_PRICE_OPEN),
             sl, OrderGetDouble(ORDER_TP), true, false, RI_GridOf(OrderGetString(ORDER_COMMENT)));
   }
}

// money result of one item if the market travels from c0 (now) to the price px
double RI_Pnl(int i, double px, double c0)
{
   RItem it = gRI[i];
   if(it.pend)
   {
      bool fill = (px >= it.ref && it.ref >= c0) || (px <= it.ref && it.ref <= c0);   // the path from now to px crosses the order
      if(!fill) return 0;
   }
   double x;
   if(it.dir > 0) x = (it.sl > 0 && px <= it.sl) ? it.sl : ((it.tp > 0 && px >= it.tp) ? it.tp : px);
   else           x = (it.sl > 0 && px >= it.sl) ? it.sl : ((it.tp > 0 && px <= it.tp) ? it.tp : px);
   double d = (x - it.ref) * it.dir;
   double m = it.vol * d * (d >= 0 ? gRPv[it.si] : gRLv[it.si]);
   if(it.pend && m > 0) m = 0;      // no hedge credit from orders that may never fill
   return m;
}

// worst net loss (>= 0) over all scenarios, summed over symbols (different symbols are not netted against each other)
double RI_Worst()
{
   double total = 0;
   for(int s = 0; s < gRSN; s++)
   {
      double c0 = SymbolInfoDouble(gRS[s], SYMBOL_BID);
      double pr[]; int np = 0; ArrayResize(pr, 1 + 3 * gRN);
      pr[np++] = c0; bool any = false;
      for(int i = 0; i < gRN; i++)
      {
         if(gRI[i].si != s || gRI[i].sl <= 0) continue;     // positions without SL have no defined risk
         any = true;
         pr[np++] = gRI[i].sl;
         if(gRI[i].tp > 0) pr[np++] = gRI[i].tp;
         if(gRI[i].pend) pr[np++] = gRI[i].ref;
      }
      if(!any) continue;
      double worst = 0;
      for(int k = 0; k < np; k++)
      {
         double sum = 0;
         for(int i = 0; i < gRN; i++) if(gRI[i].si == s && gRI[i].sl > 0) sum += RI_Pnl(i, pr[k], c0);
         if(-sum > worst) worst = -sum;
      }
      total += worst;
   }
   return total;
}

// result of the OPEN positions of the chart symbol if the market travels to px (used for the equity at a grid level)
double RI_PosPnl(double px)
{
   int si = -1;
   for(int i = 0; i < gRSN; i++) if(gRS[i] == _Symbol) { si = i; break; }
   if(si < 0) return 0;
   double c0 = Bid(), sum = 0;
   for(int i = 0; i < gRN; i++) if(gRI[i].si == si && !gRI[i].pend && !gRI[i].cand) sum += RI_Pnl(i, px, c0);
   return sum;
}

// gate: the order(s) already added as candidates to the item list may not push the worst case beyond the allowance
// (an order that only REDUCES the worst case - a hedge - is always allowed)
bool HedgeGate(double before)
{
   if(!InpBlockRisky) return true;
   UpdateStats();
   double after = RI_Worst();
   if(after > gAllow + 0.005 && after > before + 0.005)
   {
      SetMsg(StringFormat("Blocked: worst-case loss %.2f (hedge-netted, now %.2f) > remaining allowance %.2f", after, before, gAllow), true);
      return false;
   }
   return true;
}

//+------------------------------------------------------------------+
//| leverage / margin (prop firm rule + broker margin, hedge-aware)  |
//+------------------------------------------------------------------+
bool TokHit(const string symU, const string list, bool startsOnly)
{
   string parts[]; int n = StringSplit(list, ',', parts);
   for(int i = 0; i < n; i++)
   {
      string t = parts[i]; StringTrimLeft(t); StringTrimRight(t); StringToUpper(t);
      if(StringLen(t) == 0) continue;
      int p = StringFind(symU, t);
      if(p >= 0 && (!startsOnly || p <= 1)) return true;
   }
   return false;
}
bool Has(const string s, const string k) { return StringFind(s, k) >= 0; }

int AssetClass(const string sym)
{
   string s = sym; StringToUpper(s);
   string path = SymbolInfoString(sym, SYMBOL_PATH); StringToUpper(path);
   ENUM_SYMBOL_CALC_MODE cm = (ENUM_SYMBOL_CALC_MODE)SymbolInfoInteger(sym, SYMBOL_TRADE_CALC_MODE);
   if(Has(s, "XAU") || Has(s, "GOLD")) return AC_GOLD;
   if(Has(s, "XAG") || Has(s, "SILVER")) return AC_SILVER;
   if(Has(s, "XTI") || Has(s, "XBR") || Has(s, "WTI") || Has(s, "BRENT") || Has(s, "OIL") || Has(s, "UKO") || Has(s, "USO") ||
      Has(s, "NGAS") || Has(s, "XNG") || Has(s, "NATGAS")) return AC_OIL;
   if(Has(path, "CRYPTO") || TokHit(s, "BTC,ETH,LTC,XRP,BCH,SOL,DOGE,ADA,DOT,BNB,AVAX,LINK,MATIC,TRX,XLM,SHIB,ATOM,ETC,XMR,DASH,EOS,NEO,IOTA,NEAR,PEPE", true))
      return TokHit(s, InpCryptoMajors, true) ? AC_CRYPTOMAJOR : AC_CRYPTO;
   if(cm == SYMBOL_CALC_MODE_EXCH_STOCKS || Has(path, "STOCK") || Has(path, "SHARE") || Has(path, "EQUIT")) return AC_SHARE;
   if(cm == SYMBOL_CALC_MODE_CFDINDEX || Has(path, "INDIC") || Has(path, "INDEX") ||
      TokHit(s, "US30,US500,US100,USTEC,NAS,NDX,SPX,SP500,DJ,DOW,GER,DE40,DE30,DAX,UK100,FTSE,JP225,JPN,NIKKEI,AUS200,ASX,FRA40,CAC,EU50,STOXX,HK50,HSI,ES35,IBEX,CH20,VIX,DXY,USDX", true))
      return AC_INDEX;
   if(cm == SYMBOL_CALC_MODE_FOREX || cm == SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE || Has(path, "FOREX"))
      return TokHit(s, InpExotics, false) ? AC_EXOTIC : AC_FOREX;
   return AC_OTHER;
}
string ClsName(int c)
{
   switch(c)
   {
      case AC_FOREX:       return "forex";
      case AC_EXOTIC:      return "exotic FX";
      case AC_GOLD:        return "gold";
      case AC_SILVER:      return "silver";
      case AC_OIL:         return "oil/energy";
      case AC_INDEX:       return "index";
      case AC_SHARE:       return "shares";
      case AC_CRYPTOMAJOR: return "crypto major";
      case AC_CRYPTO:      return "crypto";
   }
   return "other";
}
// prop firm leverage (1:x) for a symbol; 0 = rule switched off
double LevFor(const string sym, int &cls)
{
   cls = AssetClass(sym);
   if(!InpLevOn) return 0;
   switch(cls)
   {
      case AC_FOREX:       return InpLevForex;
      case AC_EXOTIC:      return InpLevExotic;
      case AC_GOLD:        return InpLevGold;
      case AC_SILVER:      return InpLevSilver;
      case AC_OIL:         return InpLevOil;
      case AC_INDEX:       return InpLevIndices;
      case AC_SHARE:       return InpLevShares;
      case AC_CRYPTOMAJOR: return InpLevCryptoMajor;
      case AC_CRYPTO:      return InpLevCrypto;
   }
   return InpLevOther;
}
// margin for 1.0 lot in account currency = the stricter of (notional / prop-firm leverage) and the broker's own margin
double MarginPerLot(const string sym, bool buy)
{
   double price = SymbolInfoDouble(sym, buy ? SYMBOL_ASK : SYMBOL_BID);
   if(price <= 0) price = SymbolInfoDouble(sym, SYMBOL_BID);
   double tv = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE), ts = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   int cls; double lev = LevFor(sym, cls);
   double prop = 0;
   if(lev > 0 && ts > 0) prop = price * tv / ts / lev;       // price x tick value / tick size = notional of 1 lot in account currency
   double brk = 0;
   if(!OrderCalcMargin(buy ? ORDER_TYPE_BUY : ORDER_TYPE_SELL, sym, 1.0, price, brk)) brk = 0;
   return MathMax(prop, brk);
}
// margin of one symbol's exposure: hedged volume is netted (default), only the larger side counts, or both sides count
double ExpoMargin(double rB, double rS, double b, double s)
{
   switch(InpHedgeMargin)
   {
      case HM_NET:    return (b >= s) ? (b - s) * rB : (s - b) * rS;
      case HM_LARGER: return (b >= s) ? b * rB : s * rS;
   }
   return b * rB + s * rS;
}
void LoadMarginCtx(bool force = false)
{
   if(!force && gMCpos == PositionsTotal() && GetTickCount() - gMCT < 500) return;
   string sy[]; double bv[], sv[]; int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      string s = PositionGetString(POSITION_SYMBOL); double v = PositionGetDouble(POSITION_VOLUME);
      bool b = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
      int k = -1;
      for(int j = 0; j < n; j++) if(sy[j] == s) { k = j; break; }
      if(k < 0) { ArrayResize(sy, n + 1); ArrayResize(bv, n + 1); ArrayResize(sv, n + 1); sy[n] = s; bv[n] = 0; sv[n] = 0; k = n; n++; }
      if(b) bv[k] += v; else sv[k] += v;
   }
   gMC.mOther = 0; gMC.nb = 0; gMC.ns = 0;
   for(int j = 0; j < n; j++)
   {
      if(sy[j] == _Symbol) { gMC.nb = bv[j]; gMC.ns = sv[j]; }
      else gMC.mOther += ExpoMargin(MarginPerLot(sy[j], true), MarginPerLot(sy[j], false), bv[j], sv[j]);
   }
   gMC.rB = MarginPerLot(_Symbol, true); gMC.rS = MarginPerLot(_Symbol, false);
   gMCT = GetTickCount(); gMCpos = PositionsTotal();
}
// Can the account carry 'vol' MORE lots (of a plan) when the market stands at px?
//   equity at that moment = equity now + result of the open positions travelling to px - floating loss of the plan's earlier orders
//   margin at that moment = other symbols + this symbol's net exposure incl. the plan's volume
// needs RI_Load() and LoadMarginCtx() first
bool StageOK(bool buy, double px, double vol, double newLoss, double &mOut, double &eqOut)
{
   eqOut = gEq + RI_PosPnl(px) - newLoss;
   mOut  = gMC.mOther + ExpoMargin(gMC.rB, gMC.rS, gMC.nb + (buy ? vol : 0.0), gMC.ns + (buy ? 0.0 : vol));
   return (eqOut > 0 && mOut <= eqOut * InpMarginUsePct / 100.0);
}
// every level of a grid: the last order must still be affordable after the drawdown of all earlier orders
bool GridMarginCheck(const double &lots[], const double &px[], int cnt, bool buy, int &failAt, double &maxUse)
{
   failAt = -1; maxUse = 0;
   double cum = 0, perPt = VPP() / _Point;           // loss per 1.0 price unit per lot
   for(int k = 0; k < cnt; k++)
   {
      double fl = 0;
      for(int i = 0; i < k; i++) fl += lots[i] * MathAbs(px[k] - px[i]) * perPt;
      double m, eq;
      bool ok = StageOK(buy, px[k], cum + lots[k], fl, m, eq);
      double use = (eq > 0) ? m / eq * 100.0 : 999.0;
      if(use > maxUse) maxUse = use;
      if(!ok && failAt < 0) failAt = k;
      cum += lots[k];
   }
   return failAt < 0;
}
string LevText(bool buy, double px, double lot, bool &bad)
{
   int cls; double lev = LevFor(_Symbol, cls);
   RI_Load(); LoadMarginCtx();
   double m, eq; bool ok = StageOK(buy, px, lot, 0, m, eq);
   bad = !ok;
   double use = (eq > 0) ? m / eq * 100.0 : 999.0;
   string l = (lev > 0) ? StringFormat("1:%.0f %s", lev, ClsName(cls)) : ("broker lev. " + ClsName(cls));
   return StringFormat("%s | %.0f (%.0f%% eq)%s", l, m, use, gLotCapped ? " CAPPED" : (ok ? "" : " TOO HIGH"));
}
string GridLevText()
{
   int cls; double lev = LevFor(_Symbol, cls);
   string l = (lev > 0) ? StringFormat("1:%.0f %s", lev, ClsName(cls)) : ("broker lev. " + ClsName(cls));
   return StringFormat("%s | peak %.0f%% eq%s", l, gGMaxUse, gGMarginOK ? (gGCapped ? " LOTS CAPPED" : "") : " NOT AFFORDABLE");
}
//+------------------------------------------------------------------+
//| low level object helpers                                         |
//+------------------------------------------------------------------+
void Obj(string n, ENUM_OBJECT t)
{
   if(ObjectFind(0, n) < 0) ObjectCreate(0, n, t, 0, 0, 0);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   // clicks go to the highest z-order: panel background 1000, panel controls 2000, chart/preview lines stay at 0
   ObjectSetInteger(0, n, OBJPROP_ZORDER, t == OBJ_RECTANGLE_LABEL ? 1000 : 2000);
}
void MkRect(string n, int x, int y, int w, int h, color bg, color br)
{
   Obj(n, OBJ_RECTANGLE_LABEL);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);     ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);  ObjectSetInteger(0, n, OBJPROP_COLOR, br);
   ObjectSetInteger(0, n, OBJPROP_BORDER_TYPE, BORDER_FLAT);
}
int TY(int y, int h) { return y + MathMax(0, (h - (int)(gFE * 1.6)) / 2); }
void MkLbl(string n, string t, int x, int y, color c, bool right = false)
{
   Obj(n, OBJ_LABEL);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_ANCHOR, right ? ANCHOR_RIGHT_UPPER : ANCHOR_LEFT_UPPER);
   ObjectSetString(0, n, OBJPROP_TEXT, t); ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, gFE); ObjectSetString(0, n, OBJPROP_FONT, "Arial");
}
void MkBtn(string n, string t, int x, int y, int w, int h, color bg, color fg)
{
   Obj(n, OBJ_BUTTON);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);     ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, bg);  ObjectSetInteger(0, n, OBJPROP_COLOR, fg);
   ObjectSetInteger(0, n, OBJPROP_BORDER_COLOR, cBord);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, gFE); ObjectSetString(0, n, OBJPROP_FONT, "Arial");
   ObjectSetString(0, n, OBJPROP_TEXT, t); ObjectSetInteger(0, n, OBJPROP_STATE, false);
}
void MkEdt(string n, string t, int x, int y, int w, int h)
{
   Obj(n, OBJ_EDIT);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x); ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, n, OBJPROP_XSIZE, w);     ObjectSetInteger(0, n, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, cEdit); ObjectSetInteger(0, n, OBJPROP_COLOR, cTxt);
   ObjectSetInteger(0, n, OBJPROP_BORDER_COLOR, cBord);
   ObjectSetInteger(0, n, OBJPROP_ALIGN, ALIGN_CENTER); ObjectSetInteger(0, n, OBJPROP_READONLY, false);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, gFE); ObjectSetString(0, n, OBJPROP_FONT, "Arial");
   ObjectSetString(0, n, OBJPROP_TEXT, t);
}
void SetT(string n, string t, color c = clrNONE)
{
   if(ObjectFind(0, n) < 0) return;
   if(StringFind(n, P + "V_") == 0 && n != P + "V_msg" && n != P + "V_msg2")
   {
      // info rows are right-aligned: a long value would run over its caption -> cut with "..." and show the full text as tooltip
      string cap = ObjectGetString(0, P + "L_" + StringSubstr(n, StringLen(P) + 2), OBJPROP_TEXT);
      double cw = gFE * 0.72;
      int mx = (int)((gLW - StringLen(cap) * cw - 12) / cw);
      if(mx < 8) mx = 8;
      ObjectSetString(0, n, OBJPROP_TOOLTIP, t);
      if(StringLen(t) > mx) t = StringSubstr(t, 0, mx - 3) + "...";
   }
   ObjectSetString(0, n, OBJPROP_TEXT, t);
   if(c != clrNONE) ObjectSetInteger(0, n, OBJPROP_COLOR, c);
}
void SetEdit(string key, string t) { SetT(P + "E_" + key, t); }
void SetToggle(string n, string cap, bool on)
{
   if(ObjectFind(0, n) < 0) return;
   ObjectSetString(0, n, OBJPROP_TEXT, (on ? "[On] " : "[Off] ") + cap);
   ObjectSetInteger(0, n, OBJPROP_BGCOLOR, on ? cOnBg : cOffBg);
   ObjectSetInteger(0, n, OBJPROP_COLOR, on ? cOnFg : cOffFg);
}

//--- row builders
int RowY(double u = 1.0) { int y = gCY; gCY += (int)MathRound(gRH * u); return y; }
void RowEdit(string key, string cap, string val)
{
   int y = RowY(), h = gRH - 3, lw = (int)(gLW * 0.58);
   MkLbl(P + "L_" + key, cap, gLX, TY(y, h), cTxt);
   MkEdt(P + "E_" + key, val, gLX + lw, y, gLW - lw, h);
}
void RowInfo(string key, string cap)
{
   int y = RowY(), h = gRH - 3;
   MkLbl(P + "L_" + key, cap, gLX, TY(y, h), cDim);
   MkLbl(P + "V_" + key, "-", gLX + gLW, TY(y, h), cTxt, true);
}
void RowCheck(string key, string cap, bool on)
{
   int y = RowY(), h = gRH - 3;
   MkBtn(P + "C_" + key, (on ? "[On] " : "[Off] ") + cap, gLX, y, gLW, h, on ? cOnBg : cOffBg, on ? cOnFg : cOffFg);
}
void RowCheckEdit(string ck, string ek, string cap, bool on, string val)
{
   int y = RowY(), h = gRH - 3, lw = (int)(gLW * 0.58);
   MkBtn(P + "C_" + ck, (on ? "[On] " : "[Off] ") + cap, gLX, y, lw - 3, h, on ? cOnBg : cOffBg, on ? cOnFg : cOffFg);
   MkEdt(P + "E_" + ek, val, gLX + lw, y, gLW - lw, h);
}
void RowBtns(string pre, int n, string &labels[], double u = 1.0)
{
   int y = RowY(u), h = (int)(gRH * u) - 3; int w = (gLW - (n - 1) * 3) / n;
   for(int i = 0; i < n; i++)
      MkBtn(P + "B_" + pre + IntegerToString(i), labels[i], gLX + i * (w + 3), y, w, h, cBtn, cTxt);
}
void RowBar(string key)
{
   int y = RowY(0.6), h = (int)(gRH * 0.6) - 4;
   MkRect(P + "BB_" + key, gLX, y + 1, gLW, h, cEdit, cBord);
   MkRect(P + "BF_" + key, gLX + 1, y + 2, 2, h - 2, cYel, cYel);                 // drawdown fill (from the left)
   MkRect(P + "BP_" + key, gLX + gLW - 3, y + 2, 2, h - 2, cGood, cGood);          // profit fill (from the right)
}
void RowUnitEdit(string key, string cap, bool money, string val)
{
   int y = RowY(), h = gRH - 3, lw = (int)(gLW * 0.58);
   MkBtn(P + "U_" + key, cap + (money ? " [" + Ccy() + "]" : " [%]"), gLX, y, lw - 3, h, cBtn, cTxt);
   MkEdt(P + "E_" + key, val, gLX + lw, y, gLW - lw, h);
}
void RowMsg()
{
   int y = RowY(), h = gRH - 3;
   MkLbl(P + "V_msg", " ", gLX, TY(y, h), cDim);
   int y2 = RowY();
   MkLbl(P + "V_msg2", " ", gLX, TY(y2, h), cDim);
}
double TabUnits(int t)
{
   if(t == 0) return 25.2;
   if(t == 1) return 16.0;
   if(t == 2) return 26.0;
   return 18.0;
}

//+------------------------------------------------------------------+
//| panel                                                            |
//+------------------------------------------------------------------+
void BuildPanel()
{
   ObjectsDeleteAll(0, P);
   double s = gScale / 100.0;
   gFE = (int)MathMax(7, MathRound(gFont * s));
   int ru = (int)MathMax(gFE * 2.0, 22.0 * s);
   gPad = (int)MathMax(4, 6 * s);
   int topRows = (gTab == 0) ? 2 : 3;
   int top = ru * topRows + gPad;
   int gripH = (int)(ru * 0.8);
   double units = TabUnits(gTab);
   int need = top + (int)(units * ru) + gPad + gripH;
   gPhE = MathMax((int)(gPh * s), need);
   gPwE = MathMax((int)(gPw * s), (int)(gFE * 31));
   gRH = (int)MathMin(ru * 2.0, MathMax((double)ru, (double)(gPhE - top - gPad - gripH) / units));

   if(gMin)      // minimized: only the title bar (drag it to move) and a restore button
   {
      gPhE = ru;
      MkRect(P + "BG", gPx, gPy, gPwE, ru, cBG, cBord);
      MkBtn(P + "HDR", HdrText(), gPx, gPy, gPwE - ru, ru, cHdr, cTxt);
      MkBtn(P + "B_min", "+", gPx + gPwE - ru, gPy, ru, ru, cHdr, cAcc);
      ObjectSetString(0, P + "B_min", OBJPROP_TOOLTIP, "Restore panel");
      UpdateUI();
      return;
   }
   MkRect(P + "BG", gPx, gPy, gPwE, gPhE, cBG, cBord);
   int tw = (int)(gFE * 6.0);
   int mw = (int)MathMax(ru * 0.9, gFE * 2.2);        // minimize button
   MkBtn(P + "HDR", HdrText(), gPx, gPy, gPwE - tw - mw, ru, cHdr, cTxt);
   MkBtn(P + "B_min", ShortToString(0x2212), gPx + gPwE - tw - mw, gPy, mw, ru, cHdr, cAcc);
   ObjectSetString(0, P + "B_min", OBJPROP_TOOLTIP, "Minimize panel");
   MkBtn(P + "B_theme", gDark ? "Light" : "Dark", gPx + gPwE - tw, gPy, tw, ru, cHdr, cAcc);
   string tn[4] = {"MAIN", "LIVE", "GRID", "PEND"};
   int w4 = gPwE / 4;
   for(int i = 0; i < 4; i++)
      MkBtn(P + "B_tab" + IntegerToString(i), tn[i], gPx + i * w4, gPy + ru, (i == 3 ? gPwE - 3 * w4 : w4), ru,
            (i == gTab ? cAcc : cBtn), (i == gTab ? clrWhite : cTxt));
   if(gTab > 0)
   {
      int hw = gPwE / 2;
      MkBtn(P + "B_buy",  "BUY side",  gPx,      gPy + 2 * ru, hw,        ru, gBuy ? cBuy : cBtn,  gBuy ? clrWhite : cTxt);
      MkBtn(P + "B_sell", "SELL side", gPx + hw, gPy + 2 * ru, gPwE - hw, ru, !gBuy ? cSell : cBtn, !gBuy ? clrWhite : cTxt);
   }
   gLX = gPx + gPad; gLW = gPwE - 2 * gPad; gCY = gPy + ru * topRows + gPad / 2;

   if(gTab == 0)
   {
      RowEdit("startov", "Start balance (0=auto)", DoubleToString(gStartOv, 2));
      RowInfo("start", "Starting balance");
      RowInfo("balq", "Balance / Equity");
      RowEdit("ddpct", "Daily DD limit %", DoubleToString(gDailyDD, 2));
      RowEdit("bufpct", "Buffer % of daily DD", DoubleToString(gBuf, 1));
      RowEdit("maxdd", "Max DD %", DoubleToString(gMaxDD, 2));
      RowInfo("dref", "Daily DD reference");
      RowInfo("dstart", "Day (re)starts at");
      RowInfo("daily", "Daily loss");
      RowBar("d");
      RowInfo("trig", "Daily limit / buffer stop");
      RowInfo("maxi", "Max DD floor / used");
      RowBar("m");
      RowInfo("stat", "Status");
      RowEdit("passpct", "Pass target % (0=off)", DoubleToString(gPassPct, 2));
      RowUnitEdit("dmax", "Max daily profit (close all+lock)", gDayMaxM, DoubleToString(gDayMax, 2));
      RowCheck("bk", "Basket: close floating profit only", gBkOn);
      RowUnitEdit("bkv", "Basket profit", gBkM, DoubleToString(gBkVal, 2));
      RowCheck("trail", "Basket virtual trailing stop", gTrailOn);
      RowUnitEdit("trv", "Trail behind peak", gTrM, DoubleToString(gTrVal, 2));
      RowInfo("goalp", "Profit today | total");
      RowInfo("goalb", "Basket status");
      RowCheck("mgd", "1 s delay before auto actions (2nd terminal)", gMgrDelay);
      { int ys = RowY(); MkBtn(P + "B_srmode", gSRMode == 0 ? "S/R mode: AGGRESSIVE (nearest levels)" : "S/R mode: CONSERVATIVE (strong, wide)", gLX, ys, gLW, gRH - 3,
              gSRMode == 0 ? cAggBg : cOnBg, gSRMode == 0 ? cAggFg : cOnFg); }
      string ui[4] = {"Scale -", "Scale +", "Font -", "Font +"};
      RowBtns("ui", 4, ui);
      int y = RowY(); MkBtn(P + "B_unlock", "Trading enabled", gLX, y, gLW, gRH - 3, cBtn, cGood);
   }
   else if(gTab == 1)
   {
      RowEdit("magic", "Magic number", IntegerToString(gMagic));
      RowCheck("auto", "Auto lot from SL + risk %", gAuto);
      RowEdit("risk", "Risk % per trade", DoubleToString(gRisk, 2));
      RowEdit("lot", "Lot size", DoubleToString(gLot, 2));
      RowCheckEdit("tp", "tp", "Take profit (pts)", gTpOn, IntegerToString(gTpPts));
      RowCheckEdit("sl", "sl", "Stop loss (pts+spread)", gSlOn, IntegerToString(gSlPts));
      string a[3] = {"-", "-", "-"};
      RowBtns("sugtp", 3, a); RowBtns("sugsl", 3, a);
      RowInfo("rr", "Risk / Reward / R:R");
      RowInfo("lev", "Leverage / margin");
      RowInfo("hr", "Acct risk now -> after");
      int y = RowY(2.0), h = (int)(gRH * 2.0) - 4, hw = (gLW - 4) / 2;
      MkBtn(P + "B_buyNow",  "BUY",  gLX,          y, hw,        h, cBuy,  clrWhite);
      MkBtn(P + "B_sellNow", "SELL", gLX + hw + 4, y, gLW - hw - 4, h, cSell, clrWhite);
      string c[3] = {"Close all", "Close profit", "Close loss"};
      RowBtns("close", 3, c);
      RowMsg();
   }
   else if(gTab == 2)
   {
      { int yn = RowY(); MkLbl(P + "V_gnote", " ", gLX, TY(yn, gRH - 3), cWarn); }
      RowEdit("magic", "Magic number", IntegerToString(gMagic));
      RowEdit("gridrisk", "Risk % whole grid", DoubleToString(gGRisk, 2));
      RowEdit("gridn", "Orders in grid", IntegerToString(gGN));
      RowEdit("gridinc", "Lot multiplier %", DoubleToString(gGInc, 0));
      RowCheckEdit("tp1a", "gridtp1", "Auto TP1 (S/R) - pips", gGTP1Auto, DoubleToString(Pips(gGTP1), 1));
      RowEdit("gridtpval", "TP whole grid", DoubleToString(gGTPVal, 2));
      int y = RowY(); MkBtn(P + "B_gunit", gGTPMoney ? "Grid TP unit: CURRENCY" : "Grid TP unit: POINTS", gLX, y, gLW, gRH - 3, cBtn, cTxt);
      RowEdit("gridmin", "Min pts between orders", IntegerToString(gGMin));
      RowEdit("griddist", "Dist. increment % of 1st", DoubleToString(gGDistPct, 0));
      RowCheckEdit("be", "bepips", "Breakeven + buffer (pips)", gBEOn, DoubleToString(gBEBuf, 1));
      RowEdit("betrig", "BE trigger pips (0=asap)", DoubleToString(gBETrig, 1));
      RowCheck("gitp", "Pending orders: TP at 1st order price", gGInitTP);
      RowCheck("gmtp", "Move real TPs on every fill (2nd order on)", gGMoveTP);
      RowCheck("g2nd", "Allow 2nd grid in this direction", gAllow2nd);
      RowInfo("glots", "Lots");
      RowInfo("grr", "Risk / TP1 / Grid TP");
      RowInfo("grr2", "R:R  TP1 | whole grid");
      RowInfo("gcnt", "Active grids (buy / sell)");
      RowInfo("glev", "Leverage / margin");
      RowInfo("hr", "Acct risk now -> after");
      string b[2] = {"PLACE GRID", "CLOSE GRID"};
      int y2 = RowY(), h = gRH - 3, hw = (gLW - 3) / 2;
      MkBtn(P + "B_gplace", b[0], gLX, y2, hw, h, cAcc, clrWhite);
      MkBtn(P + "B_gcancel", (gBuy ? "CLOSE BUY GRIDS" : "CLOSE SELL GRIDS"), gLX + hw + 3, y2, gLW - hw - 3, h, cSell, clrWhite);
      int y4 = RowY(); MkBtn(P + "B_gext", "EXTEND GRID: next S/R, use daily DD room", gLX, y4, gLW, gRH - 3, cBtn, cTxt);
      int y3 = RowY(); MkBtn(P + "B_gresug", "Re-suggest levels from S/R (" + (gSRMode == 0 ? "aggressive" : "conservative") + ")", gLX, y3, gLW, gRH - 3, cBtn, cTxt);
      RowMsg();
   }
   else
   {
      RowEdit("magic", "Magic number", IntegerToString(gMagic));
      RowCheck("auto", "Auto lot from SL + risk %", gAuto);
      RowEdit("risk", "Risk % per trade", DoubleToString(gRisk, 2));
      RowEdit("lot", "Lot size", DoubleToString(gLot, 2));
      RowEdit("mindist", "Min entry distance (pts)", IntegerToString(gMinDist));
      { int yt = RowY(); MkBtn(P + "B_ptype", PendTypeText(), gLX, yt, gLW, gRH - 3, cBtn, cTxt); }
      RowCheckEdit("tp", "tp", "Take profit (pts)", gTpOn, IntegerToString(gTpPts));
      RowCheckEdit("sl", "sl", "Stop loss (pts+spread)", gSlOn, IntegerToString(gSlPts));
      RowCheck("sug", "Use suggested SL/TP", pdUseSug);
      for(int i = 0; i < 3; i++)
      { int y = RowY(); MkBtn(P + "B_ps" + IntegerToString(i), "-", gLX, y, gLW, gRH - 3, cBtn, cTxt); }
      RowInfo("rr", "Risk / Reward / R:R");
      RowInfo("lev", "Leverage / margin");
      RowInfo("hr", "Acct risk now -> after");
      string b[2] = {"PLACE PENDING", "CANCEL PENDING"};
      int y2 = RowY(), h = gRH - 3, hw = (gLW - 3) / 2;
      MkBtn(P + "B_placep", b[0], gLX, y2, hw, h, cAcc, clrWhite);
      MkBtn(P + "B_cancelp", b[1], gLX + hw + 3, y2, gLW - hw - 3, h, cSell, clrWhite);
      RowMsg();
   }
   MkBtn(P + "GRIP", "//", gPx + gPwE - gripH * 2, gPy + gPhE - gripH, gripH * 2, gripH, cBtn, cDim);
   UpdateUI();
   ChartRedraw();
}

void ShiftPanel(int dx, int dy)
{
   int tot = ObjectsTotal(0, 0, -1);
   for(int i = 0; i < tot; i++)
   {
      string n = ObjectName(0, i, 0, -1);
      if(StringFind(n, P) != 0) continue;
      ObjectSetInteger(0, n, OBJPROP_XDISTANCE, ObjectGetInteger(0, n, OBJPROP_XDISTANCE) + dx);
      ObjectSetInteger(0, n, OBJPROP_YDISTANCE, ObjectGetInteger(0, n, OBJPROP_YDISTANCE) + dy);
   }
}

// one bar: drawdown fills from the left (yellow/orange/red), profit fills from the right (green)
void SetBar2(string key, double ddRatio, color ddCol, double profRatio)
{
   string f = P + "BF_" + key, p = P + "BP_" + key, b = P + "BB_" + key;
   if(ObjectFind(0, f) < 0 || ObjectFind(0, p) < 0 || ObjectFind(0, b) < 0) return;
   int w  = (int)ObjectGetInteger(0, b, OBJPROP_XSIZE) - 2;
   int bx = (int)ObjectGetInteger(0, b, OBJPROP_XDISTANCE);
   int wd = (int)(w * MathMin(1.0, MathMax(0.0, ddRatio)));
   int wp = (int)(w * MathMin(1.0, MathMax(0.0, profRatio)));
   color c1 = (wd > 0) ? ddCol : cEdit, c2 = (wp > 0) ? cGood : cEdit;
   wd = MathMax(1, wd); wp = MathMax(1, wp);
   ObjectSetInteger(0, f, OBJPROP_XDISTANCE, bx + 1);
   ObjectSetInteger(0, f, OBJPROP_XSIZE, wd);
   ObjectSetInteger(0, f, OBJPROP_BGCOLOR, c1); ObjectSetInteger(0, f, OBJPROP_COLOR, c1);
   ObjectSetInteger(0, p, OBJPROP_XDISTANCE, bx + 1 + w - wp);
   ObjectSetInteger(0, p, OBJPROP_XSIZE, wp);
   ObjectSetInteger(0, p, OBJPROP_BGCOLOR, c2); ObjectSetInteger(0, p, OBJPROP_COLOR, c2);
}

string TypeShort(int t)
{
   switch(t)
   {
      case ORDER_TYPE_BUY_LIMIT:  return "BUY LMT";
      case ORDER_TYPE_BUY_STOP:   return "BUY STP";
      case ORDER_TYPE_SELL_LIMIT: return "SELL LMT";
      case ORDER_TYPE_SELL_STOP:  return "SELL STP";
   }
   return "?";
}

void ShowHR(double bf, double af)
{
   bool bad = (af > gAllow && af > bf + 0.005);
   SetT(P + "V_hr", StringFormat("-%.2f -> -%.2f  (allow %.2f)", bf, af, MathMax(0.0, gAllow)), bad ? cBad : (af < bf - 0.005 ? cGood : cTxt));
}
void ShowMsg()
{
   if(gMsg != "" && GetTickCount() - gMsgT > 10000) gMsg = "";      // a note disappears after 10 seconds
   color c = gMsgBad ? cBad : cDim;
   int cap = (int)MathMax(24.0, gLW / (gFE * 0.58));
   string a = gMsg, b = "";
   if(StringLen(a) > cap)
   {
      int cut = cap;
      for(int i = cap; i > cap / 2; i--) if(StringGetCharacter(gMsg, i) == ' ') { cut = i; break; }
      a = StringSubstr(gMsg, 0, cut); b = StringSubstr(gMsg, cut);
      StringTrimLeft(b);
      if(StringLen(b) > cap + 6) b = StringSubstr(b, 0, cap + 4) + "..";
   }
   if(a == "") a = " ";                                              // an EMPTY text makes MT5 draw the word "Label"
   if(b == "") b = " ";
   SetT(P + "V_msg", a, c); SetT(P + "V_msg2", b, c);
   if(ObjectFind(0, P + "V_msg") >= 0) ObjectSetString(0, P + "V_msg", OBJPROP_TOOLTIP, gMsg);
}

void UpdateUI()
{
   UpdateStats();
   SetT(P + "HDR", HdrText(), gLock == 0 ? cTxt : (gLock >= 3 ? cWarn : cBad));
   double pt = _Point, vpp = VPP();
   if(gTab == 0)
   {
      SetT(P + "V_start", DoubleToString(gStartEff, 2) + (gStartOv > 0 ? " (manual)" : (gStartFound ? " (auto)" : " (estimated)")));
      SetT(P + "V_balq", DoubleToString(gBal, 2) + " / " + DoubleToString(gEq, 2));
      string rn = (InpDDRef == DDREF_BALANCE) ? "balance" : ((InpDDRef == DDREF_EQUITY) ? "equity" : "higher of both");
      if(InpDDRef != DDREF_BALANCE && gEqEst) rn += ", est.";
      SetT(P + "V_dref", DoubleToString(gDayRef, 2) + " (" + rn + ")");
      SetT(P + "V_dstart", TimeToString(gDayStart, TIME_DATE | TIME_MINUTES) + (InpDayMode == DAY_NY_CLOSE ? StringFormat(" srv (%02d:00 NY)", InpRolloverNYHour) : " srv"));
      double pr = gDailyLim > 0 ? gDayLoss / gDailyLim : 0;
      bool dB = gDayLoss >= gDailyTrig;
      color dc = (gDayLoss > 0) ? DDCol(pr, dB) : cGood;
      if(gDayLoss > 0) SetT(P + "V_daily", StringFormat("-%.2f  (%.0f%% of limit)", gDayLoss, pr * 100.0), dc);
      else             SetT(P + "V_daily", StringFormat("+%.2f  profit today", -gDayLoss), cGood);
      double dsc = (gDayMax > 0 && gDayRef > 0) ? GoalMoney(gDayMax, gDayMaxM, gDayRef) : gDailyLim;
      SetBar2("d", MathMax(0.0, pr), dc, dsc > 0 ? MathMax(0.0, -gDayLoss) / dsc : 0.0);
      SetT(P + "V_trig", StringFormat("%.2f / stop at %.2f", gDailyLim, gDailyTrig));
      double mr = (gStartEff > 0 && gMaxDD > 0) ? gMaxUsed / (gStartEff * gMaxDD / 100.0) : 0;
      bool mB = gEq <= gMaxTrig;
      color mc = (gMaxUsed > 0) ? DDCol(mr, mB) : cGood;
      SetT(P + "V_maxi", StringFormat("%.2f / %.2f", gMaxFloor, gMaxUsed), mB ? cBad : cTxt);
      double psc = (gStartEff > 0) ? gStartEff * ((gPassPct > 0) ? gPassPct : gMaxDD) / 100.0 : 0.0;
      SetBar2("m", MathMax(0.0, mr), mc, psc > 0 ? MathMax(0.0, gEq - gStartEff) / psc : 0.0);
      SetT(P + "V_stat", LockText(), gLock == 0 ? cGood : (gLock >= 3 ? cWarn : cBad));
      if(gLock == 0) SetT(P + "B_unlock", "Trading enabled", cGood);
      else SetT(P + "B_unlock", (gLock <= 2 ? "DD limit reached - UNLOCK trading" : "Goal reached - UNLOCK trading"), cWarn);
      // profit goals
      double pm = gEq - gStartEff;
      string gp = StringFormat("%+.2f  |  %+.2f", -gDayLoss, pm);
      if(gPassPct > 0 && gStartEff > 0) gp += StringFormat(" (%.0f%%)", pm / (gStartEff * gPassPct / 100.0) * 100.0);
      SetT(P + "V_goalp", gp, gLock >= 3 ? cWarn : cTxt);
      string gb = "off";
      if(gBkOn)
      {
         double fl = FloatScope(), bs = RiskBase(), tg = GoalMoney(gBkVal, gBkM, bs), tr = GoalMoney(gTrVal, gTrM, bs);
         if(!gTrailOn)       gb = StringFormat("%+.2f / close at %.2f", fl, tg);
         else if(!gBkArmed)  gb = StringFormat("%+.2f / trail arms at %.2f", fl, tg);
         else                gb = StringFormat("%+.2f / peak %.2f / stop %.2f", fl, gBkPeak, gBkPeak - tr);
      }
      SetT(P + "V_goalb", gb);
      return;
   }
   ShowMsg();
   if(gTab == 1)
   {
      double e = gBuy ? Ask() : Bid();
      for(int i = 0; i < 3; i++)
      {
         string a = "TP" + IntegerToString(i + 1) + ": -", b = "SL" + IntegerToString(i + 1) + ": -";
         if(sugTP[i] > 0) a = StringFormat("TP%d %s (%d)", i + 1, DoubleToString(sugTP[i], _Digits), (int)MathRound(MathAbs(sugTP[i] - e) / pt));
         if(sugSL[i] > 0) b = StringFormat("SL%d %s (%d)", i + 1, DoubleToString(sugSL[i], _Digits), (int)MathRound(MathAbs(sugSL[i] - e) / pt));
         SetT(P + "B_sugtp" + IntegerToString(i), a); SetT(P + "B_sugsl" + IntegerToString(i), b);
      }
      double slp = (gSlOn ? MathAbs(e - lvSL) / pt : 0), tpp = (gTpOn ? MathAbs(lvTP - e) / pt : 0);
      double risk = gLot * slp * vpp, rew = gLot * tpp * vpp;
      SetT(P + "V_rr", StringFormat("-%.2f (%s) / +%.2f / 1:%.2f", risk, RiskPct(risk), rew, slp > 0 ? tpp / slp : 0.0));
      if(gAuto) SetEdit("lot", DoubleToString(gLot, 2));
      bool bad; string lt = LevText(gBuy, e, gLot, bad);
      SetT(P + "V_lev", lt, bad ? cBad : (gLotCapped ? cWarn : cTxt));
      RI_Load(); int nb = gRN; double bf = RI_Worst();
      if(gSlOn) RI_Add(_Symbol, gBuy ? 1 : -1, gLot, e, lvSL, gTpOn ? lvTP : 0.0, false, true, -1);
      double af = RI_Worst(); RI_Cut(nb);
      ShowHR(bf, af);
   }
   else if(gTab == 2)
   {
      string ls = "";
      for(int i = 0; i < gGCnt; i++) ls += (i > 0 ? " / " : "") + DoubleToString(gGLots[i], 2);
      SetT(P + "V_glots", ls);
      double e0 = gGPx[0], tot = 0;
      for(int i = 0; i < gGCnt; i++) tot += gGLots[i];
      double tp1 = gGLots[0] * MathAbs(gGTP - e0) / pt * vpp;
      double gtp = gGTPMoney ? gGTPVal : tot * gGTPVal * vpp;
      SetT(P + "V_grr", StringFormat("-%.2f (%s) / +%.2f / +%.2f", gGRiskAct, RiskPct(gGRiskAct), tp1, gtp));
      double risk1 = gGLots[0] * MathAbs(e0 - gGSL) / pt * vpp;   // risk if only the first order is filled
      SetT(P + "V_grr2", StringFormat("1:%.2f | 1:%.2f", risk1 > 0 ? tp1 / risk1 : 0.0, gGRiskAct > 0 ? gtp / gGRiskAct : 0.0));
      int nb, ns; CountGrids(nb, ns);
      SetT(P + "V_gcnt", StringFormat("%d / %d", nb, ns));
      color gnc; string gnt = GridNote(gnc); SetT(P + "V_gnote", gnt, gnc);
      SetT(P + "V_glev", GridLevText(), !gGMarginOK ? cBad : (gGCapped ? cWarn : cTxt));
      RI_Load(); int nr = gRN; double bf = RI_Worst();
      for(int i = 0; i < gGCnt; i++)
         RI_Add(_Symbol, gBuy ? 1 : -1, gGLots[i], gGPx[i], gGSL, (i == 0 && gGTP1 > 0) ? gGTP : 0.0, i > 0, true, -1);
      double af = RI_Worst(); RI_Cut(nr);
      ShowHR(bf, af);
      if(gXArmed && GetTickCount() - gXTime < 15000) SetT(P + "B_gext", "CONFIRM EXTEND (click again within 15 s)", cWarn);
      else SetT(P + "B_gext", "EXTEND GRID: next S/R, use daily DD room", cTxt);
   }
   else
   {
      for(int i = 0; i < 3; i++)
      {
         string t = "-";
         if(gPS[i].ok)
            t = StringFormat("%s %s  SL %s  TP %s", TypeShort(gPS[i].type), DoubleToString(gPS[i].e, _Digits),
                             DoubleToString(gPS[i].sl, _Digits), DoubleToString(gPS[i].tp, _Digits));
         SetT(P + "B_ps" + IntegerToString(i), t);
      }
      double slp = (gSlOn ? MathAbs(pdE - pdSL) / pt : 0), tpp = (gTpOn ? MathAbs(pdTP - pdE) / pt : 0);
      double risk = gLot * slp * vpp, rew = gLot * tpp * vpp;
      SetT(P + "V_rr", StringFormat("-%.2f (%s) / +%.2f / 1:%.2f", risk, RiskPct(risk), rew, slp > 0 ? tpp / slp : 0.0));
      if(gAuto) SetEdit("lot", DoubleToString(gLot, 2));
      bool bad; string lt = LevText(gBuy, pdE, gLot, bad);
      SetT(P + "V_lev", lt, bad ? cBad : (gLotCapped ? cWarn : cTxt));
      RI_Load(); int nb = gRN; double bf = RI_Worst();
      if(gSlOn) RI_Add(_Symbol, gBuy ? 1 : -1, gLot, pdE, pdSL, gTpOn ? pdTP : 0.0, true, true, -1);
      double af = RI_Worst(); RI_Cut(nb);
      ShowHR(bf, af);
   }
}

//+------------------------------------------------------------------+
//| chart preview (risk/reward lines)                                |
//+------------------------------------------------------------------+
void ClearPreview() { ObjectsDeleteAll(0, V); }

void PLine(string n, double price, color c, ENUM_LINE_STYLE st, bool drag, bool setp)
{
   // the EA state is authoritative; lines are moved by the EA's own mouse drag (see PickLine/MoveDragLine),
   // so they are never "selectable" (no double-click needed, nothing for the terminal to fight with)
   if(ObjectFind(0, n) < 0)
   {
      ObjectCreate(0, n, OBJ_HLINE, 0, 0, price);
      gNewObj = true;                                  // new object = drawn above the panel -> panel gets raised
   }
   else if(MathAbs(ObjectGetDouble(0, n, OBJPROP_PRICE) - price) > _Point * 0.5)
      ObjectSetDouble(0, n, OBJPROP_PRICE, price);
   ObjectSetInteger(0, n, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_STYLE, st);
   ObjectSetInteger(0, n, OBJPROP_WIDTH, drag ? 2 : 1);   // thicker = draggable
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, n, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, n, OBJPROP_BACK, false);
   ObjectSetInteger(0, n, OBJPROP_ZORDER, 0);
}
//--- drag handles: a coloured pill at the right edge of every draggable line
string TxtOf(string line)       { return V + "T_" + StringSubstr(line, StringLen(V)); }
string HdlOf(string txtName)    { string h = txtName; StringReplace(h, V + "T_", V + "H_");  return h; }
string HdlTxtOf(string txtName) { string h = txtName; StringReplace(h, V + "T_", V + "HT_"); return h; }
void DelTxt(string txtName) { ObjectDelete(0, txtName); ObjectDelete(0, HdlOf(txtName)); ObjectDelete(0, HdlTxtOf(txtName)); }
int  HFont()   { return MathMax(7, gFE - 1); }
int  HandleW() { return (int)(HFont() * 0.66 * 8.0) + 12; }
int  HandleH() { return (int)(HFont() * 2.0); }
string Grip()  { return ShortToString(0x2195) + " "; }       // up-down arrow
color OnCol(color c)
{
   uint u = (uint)c;
   int r = (int)(u & 0xFF), g = (int)((u >> 8) & 0xFF), b = (int)((u >> 16) & 0xFF);
   return (0.299 * r + 0.587 * g + 0.114 * b > 150.0) ? clrBlack : clrWhite;
}
void PHandle(string txtName, int ly, color c, string txt)
{
   string hb = HdlOf(txtName), ht = HdlTxtOf(txtName);
   int W = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS), hw = HandleW(), hh = HandleH();
   string base = StringSubstr(txtName, StringLen(V) + 2);
   bool act = (gDragLn == V + base);
   if(ObjectFind(0, hb) < 0)
   {
      ObjectCreate(0, hb, OBJ_RECTANGLE_LABEL, 0, 0, 0); gNewObj = true;
      ObjectSetInteger(0, hb, OBJPROP_SELECTABLE, false); ObjectSetInteger(0, hb, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, hb, OBJPROP_CORNER, CORNER_LEFT_UPPER); ObjectSetInteger(0, hb, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, hb, OBJPROP_ZORDER, 0);
   }
   ObjectSetInteger(0, hb, OBJPROP_XDISTANCE, W - hw - 4); ObjectSetInteger(0, hb, OBJPROP_YDISTANCE, ly - hh / 2);
   ObjectSetInteger(0, hb, OBJPROP_XSIZE, hw);            ObjectSetInteger(0, hb, OBJPROP_YSIZE, hh);
   ObjectSetInteger(0, hb, OBJPROP_BGCOLOR, c);
   ObjectSetInteger(0, hb, OBJPROP_COLOR, act ? (gDark ? clrWhite : clrBlack) : (gDark ? C'20,22,28' : clrWhite));
   if(ObjectFind(0, ht) < 0)
   {
      ObjectCreate(0, ht, OBJ_LABEL, 0, 0, 0); gNewObj = true;
      ObjectSetInteger(0, ht, OBJPROP_SELECTABLE, false); ObjectSetInteger(0, ht, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, ht, OBJPROP_CORNER, CORNER_LEFT_UPPER); ObjectSetInteger(0, ht, OBJPROP_ANCHOR, ANCHOR_CENTER);
      ObjectSetString(0, ht, OBJPROP_FONT, "Arial"); ObjectSetInteger(0, ht, OBJPROP_ZORDER, 0);
   }
   ObjectSetInteger(0, ht, OBJPROP_XDISTANCE, W - 4 - hw / 2); ObjectSetInteger(0, ht, OBJPROP_YDISTANCE, ly);
   ObjectSetString(0, ht, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, ht, OBJPROP_COLOR, OnCol(c));
   ObjectSetInteger(0, ht, OBJPROP_FONTSIZE, HFont());
}

int gLblN = 0; int gLblY[24];
void PText(string n, double price, string txt, color c, string hdl = "")
{
   int x, y; datetime t = iTime(_Symbol, _Period, 0);
   if(!ChartTimePriceToXY(0, 0, t, price, x, y)) { DelTxt(n); return; }
   int ly = y;                                   // real position of the line (the label may be nudged to avoid overlaps)
   int fs = MathMax(7, gFE - 1), fh = (int)(fs * 1.9);
   for(int g = 0; g < 24; g++)
   {
      bool hit = false;
      for(int i = 0; i < gLblN; i++) if(MathAbs(y - gLblY[i]) < fh) { y = gLblY[i] - fh; hit = true; }
      if(!hit) break;
   }
   if(gLblN < 24) gLblY[gLblN++] = y;
   if(ObjectFind(0, n) < 0)
   {
      ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0); gNewObj = true;
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, n, OBJPROP_ANCHOR, ANCHOR_RIGHT_LOWER);
      ObjectSetString(0, n, OBJPROP_FONT, "Arial");
   }
   int W = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS);
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, hdl != "" ? W - HandleW() - 12 : W - 6);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, n, OBJPROP_TEXT, txt);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, fs);
   ObjectSetInteger(0, n, OBJPROP_ZORDER, 0);
   if(hdl != "") PHandle(n, ly, c, Grip() + hdl);
   else { ObjectDelete(0, HdlOf(n)); ObjectDelete(0, HdlTxtOf(n)); }
}
void PZone(string n, double p1, double p2, color c)
{
   int w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS), sub = 0; double pr;
   datetime t1, t2;
   if(!ChartXYToTimePrice(0, MathMax(0, w - 300), 0, sub, t1, pr)) return;
   if(!ChartXYToTimePrice(0, w - 8, 0, sub, t2, pr)) return;
   if(ObjectFind(0, n) < 0)
   {
      ObjectCreate(0, n, OBJ_RECTANGLE, 0, t1, p1, t2, p2); gNewObj = true;
      ObjectSetInteger(0, n, OBJPROP_FILL, true);
      ObjectSetInteger(0, n, OBJPROP_BACK, true);
      ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, n, OBJPROP_HIDDEN, true);
   }
   ObjectSetInteger(0, n, OBJPROP_TIME, 0, t1); ObjectSetDouble(0, n, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, n, OBJPROP_TIME, 1, t2); ObjectSetDouble(0, n, OBJPROP_PRICE, 1, p2);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
}
color ZoneRisk() { return gDark ? C'85,30,30' : C'245,200,200'; }
color ZoneRew()  { return gDark ? C'20,70,45' : C'190,235,200'; }

void KillLine(string base)
{
   ObjectDelete(0, V + base); DelTxt(V + "T_" + base);
}
void ClearExtPreview()
{
   ObjectDelete(0, V + "XSL"); DelTxt(V + "T_XSL");
   for(int j = 0; j < 8; j++) { ObjectDelete(0, V + "X" + IntegerToString(j)); DelTxt(V + "T_X" + IntegerToString(j)); }
}

// lot from the risk %, then capped so that it is affordable under the leverage rule (margin at the entry, after the drawdown of open trades)
void AutoLot(double slPts, bool buy, double px)
{
   gLotCapped = false;
   if(!gAuto || !gSlOn || slPts <= 0) return;
   double vpp = VPP(); if(vpp <= 0) return;
   double want = NormVol(RiskBase() * gRisk / 100.0 / (slPts * vpp));
   RI_Load(); LoadMarginCtx();
   double m, eq;
   if(StageOK(buy, px, want, 0, m, eq)) { gLot = want; return; }
   double lo = 0, hi = want;
   for(int it = 0; it < 40; it++) { double mid = (lo + hi) / 2.0; if(StageOK(buy, px, mid, 0, m, eq)) lo = mid; else hi = mid; }
   gLotCapped = true;
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   gLot = (lo >= mn) ? NormVol(lo) : mn;
}

void PreviewLive()
{
   double pt = _Point, vpp = VPP();
   double e = gBuy ? Ask() : Bid();
   if(!lvSLd) lvSL = NP(gBuy ? e - gSlPts * pt - SpD() : e + gSlPts * pt + SpD());   // the points are BEYOND the spread
   if(!lvTPd) lvTP = NP(gBuy ? e + gTpPts * pt : e - gTpPts * pt);
   double slp = MathAbs(e - lvSL) / pt, tpp = MathAbs(lvTP - e) / pt;
   AutoLot(slp, gBuy, e);
   PLine(V + "ENTRY", e, cAcc, STYLE_SOLID, false, true);
   PText(V + "T_ENTRY", e, StringFormat(" %s %.2f lot", gBuy ? "BUY" : "SELL", gLot), cAcc);
   if(gSlOn)
   {
      PLine(V + "SL", lvSL, cBad, STYLE_DASH, true, !lvSLd);
      PText(V + "T_SL", lvSL, StringFormat(" SL %d pts  -%.2f", (int)MathRound(slp), gLot * slp * vpp), cBad, "SL");
      PZone(V + "ZR", e, lvSL, ZoneRisk());
   }
   else { KillLine("SL"); ObjectDelete(0, V + "ZR"); }
   if(gTpOn)
   {
      PLine(V + "TP", lvTP, cGood, STYLE_DASH, true, !lvTPd);
      PText(V + "T_TP", lvTP, StringFormat(" TP %d pts  +%.2f  R:R 1:%.2f", (int)MathRound(tpp), gLot * tpp * vpp, slp > 0 ? tpp / slp : 0.0), cGood, "TP");
      PZone(V + "ZW", e, lvTP, ZoneRew());
   }
   else { KillLine("TP"); ObjectDelete(0, V + "ZW"); }
}

void PreviewPend()
{
   double pt = _Point, vpp = VPP();
   double slp = MathAbs(pdE - pdSL) / pt, tpp = MathAbs(pdTP - pdE) / pt;
   AutoLot(slp, gBuy, pdE);
   double ref = gBuy ? Ask() : Bid();
   string tp = gBuy ? (pdE < ref ? "BUY LIMIT" : "BUY STOP") : (pdE > ref ? "SELL LIMIT" : "SELL STOP");
   double dist = MathAbs(pdE - ref) / pt;
   PLine(V + "ENTRY", pdE, cAcc, STYLE_SOLID, true, false);
   PText(V + "T_ENTRY", pdE, StringFormat(" %s %.2f lot  (%d pts away%s)", tp, gLot, (int)MathRound(dist), dist < gMinDist ? " TOO CLOSE" : ""),
         dist < gMinDist ? cWarn : cAcc, "ENTRY");
   if(gSlOn)
   {
      PLine(V + "SL", pdSL, cBad, STYLE_DASH, true, false);
      PText(V + "T_SL", pdSL, StringFormat(" SL %d pts  -%.2f", (int)MathRound(slp), gLot * slp * vpp), cBad, "SL");
      PZone(V + "ZR", pdE, pdSL, ZoneRisk());
   }
   else { KillLine("SL"); ObjectDelete(0, V + "ZR"); }
   if(gTpOn)
   {
      PLine(V + "TP", pdTP, cGood, STYLE_DASH, true, false);
      PText(V + "T_TP", pdTP, StringFormat(" TP %d pts  +%.2f  R:R 1:%.2f", (int)MathRound(tpp), gLot * tpp * vpp, slp > 0 ? tpp / slp : 0.0), cGood, "TP");
      PZone(V + "ZW", pdE, pdTP, ZoneRew());
   }
   else { KillLine("TP"); ObjectDelete(0, V + "ZW"); }
}

//+------------------------------------------------------------------+
//| suggestions and grid planning                                    |
//+------------------------------------------------------------------+
void SuggestLive()
{
   double buf = SLBuf(), ms = SRMinDist();
   double tg[], st[];
   for(int i = 0; i < 3; i++) { sugTP[i] = 0; sugSL[i] = 0; }
   int a, b;
   if(gBuy) { a = Above(Ask() + ms, 3, tg); b = Below(Bid() - ms, 3, st); }
   else     { a = Below(Bid() - ms, 3, tg);  b = Above(Ask() + ms, 3, st); }
   for(int i = 0; i < a; i++) sugTP[i] = NP(tg[i]);
   for(int i = 0; i < b; i++) sugSL[i] = NP(gBuy ? st[i] - buf : st[i] + buf);
}

void MakeSug(int idx, double e, int type)
{
   double pt = _Point, buf = SLBuf(), ms = SRMinDist();
   double defSL = gSlPts * pt + SpD(), defTP = gTpPts * pt;
   bool buy = (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP);
   double L[], U[]; double sl = 0, tp = 0;
   if(buy)
   {
      int k = Below(e - ms, 1, L);
      sl = (k > 0) ? L[0] - buf : e - defSL;
      if(e - sl < ms) sl = e - defSL;
      int ku = Above(e + ms, 6, U);
      for(int j = 0; j < ku; j++) if(U[j] - e >= e - sl) { tp = U[j]; break; }
      if(tp == 0) tp = e + defTP;
   }
   else
   {
      int k = Above(e + ms, 1, U);
      sl = (k > 0) ? U[0] + buf : e + defSL;
      if(sl - e < ms) sl = e + defSL;
      int kl = Below(e - ms, 6, L);
      for(int j = 0; j < kl; j++) if(e - L[j] >= sl - e) { tp = L[j]; break; }
      if(tp == 0) tp = e - defTP;
   }
   gPS[idx].e = NP(e); gPS[idx].sl = NP(sl); gPS[idx].tp = NP(tp); gPS[idx].type = type; gPS[idx].ok = true;
}

void SuggestPending()
{
   for(int i = 0; i < 3; i++) gPS[i].ok = false;
   double pt = _Point, minD = gMinDist * pt, buf = SLBuf();
   double A[], B[]; int n = 0;
   bool lim = (gPendType != 2), stp = (gPendType != 1);       // both / limit only / stop only
   if(gBuy)
   {
      if(lim) { int ka = Below(Ask() - minD, 3, A); for(int i = 0; i < ka && n < 3; i++) MakeSug(n++, A[i], ORDER_TYPE_BUY_LIMIT); }
      if(stp) { int kb = Above(Ask() + minD, 3, B); for(int i = 0; i < kb && n < 3; i++) MakeSug(n++, B[i] + buf * 0.3, ORDER_TYPE_BUY_STOP); }
   }
   else
   {
      if(lim) { int ka = Above(Bid() + minD, 3, A); for(int i = 0; i < ka && n < 3; i++) MakeSug(n++, A[i], ORDER_TYPE_SELL_LIMIT); }
      if(stp) { int kb = Below(Bid() - minD, 3, B); for(int i = 0; i < kb && n < 3; i++) MakeSug(n++, B[i] - buf * 0.3, ORDER_TYPE_SELL_STOP); }
   }
}

void PendDefaults()
{
   double pt = _Point;
   pdSL = NP(gBuy ? pdE - gSlPts * pt - SpD() : pdE + gSlPts * pt + SpD());
   pdTP = NP(gBuy ? pdE + gTpPts * pt : pdE - gTpPts * pt);
}
void ApplySug(int i)
{
   if(i < 0 || i > 2 || !gPS[i].ok) return;
   gHidePrev = false;
   pdE = gPS[i].e;
   if(pdUseSug)
   {
      pdSL = gPS[i].sl; pdTP = gPS[i].tp;
      gSlPts = BasePts(MathAbs(pdE - pdSL));
      gTpPts = TpPtsOf(MathAbs(pdTP - pdE));
      SetEdit("sl", IntegerToString(gSlPts)); SetEdit("tp", IntegerToString(gTpPts));
   }
   else PendDefaults();
   ClearPreview();
}
void InitPending()
{
   if(gPS[0].ok) ApplySug(0);
   else
   {
      bool stp = (gPendType == 2);       // stop only: entry on the breakout side of the price, otherwise the limit side
      pdE = NP(gBuy ? (stp ? Ask() + gMinDist * _Point : Ask() - gMinDist * _Point)
                    : (stp ? Bid() - gMinDist * _Point : Bid() + gMinDist * _Point));
      PendDefaults();
   }
}

// automatic first-order TP: nearest S/R level in the profit direction (fallback: input points)
double AutoTP1(double e0)
{
   double pt = _Point, ms = MinStop() + 5 * pt;
   double T[];
   int c = gBuy ? Above(e0 + ms, 1, T) : Below(e0 - ms, 1, T);
   if(c > 0) return NP(T[0]);
   return NP(gBuy ? e0 + InpGridTP1Pts * pt : e0 - InpGridTP1Pts * pt);
}

void PlanGrid()
{
   gGEdited = false; gGRefT = GetTickCount();
   double pt = _Point, buf = SLBuf(), ms = MinStop() + 5 * pt;
   gGCnt = MathMax(2, MathMin(8, gGN));
   double e0 = gBuy ? Ask() : Bid();
   gGPx[0] = e0; double prev = e0; double L[];
   for(int k = 1; k < gGCnt; k++)
   {
      double need = GMinEff() * (1.0 + (k - 1) * gGDistPct / 100.0) * pt, px;
      int c = gBuy ? Below(prev - need + pt, 1, L) : Above(prev + need - pt, 1, L);
      px = (c > 0) ? L[0] : (gBuy ? prev - need : prev + need);
      gGPx[k] = NP(px); prev = px;
   }
   // master SL: beyond the OUTER edge of the S/R zone (lowest pivot for buys / highest for sells) + buffer, never inside the zone
   double need2 = GMinEff() * pt * 0.5, sl;
   int zi = gBuy ? LvBelow(prev - need2) : LvAbove(prev + need2);
   if(zi >= 0) sl = gBuy ? gSR[zi].lo - buf : gSR[zi].hi + buf;
   else        sl = gBuy ? prev - GMinEff() * pt - buf : prev + GMinEff() * pt + buf;
   // safety net: if the SL still lands inside any zone (or its buffer band), push it out the far side
   if(gBuy) { for(int g = gSRn - 1; g >= 0; g--) if(sl <= gSR[g].hi && sl >= gSR[g].lo - buf) sl = gSR[g].lo - buf; }
   else     { for(int g = 0; g < gSRn; g++)      if(sl >= gSR[g].lo && sl <= gSR[g].hi + buf) sl = gSR[g].hi + buf; }
   if(gBuy && prev - sl < ms) sl = prev - ms;
   if(!gBuy && sl - prev < ms) sl = prev + ms;
   gGSL = NP(sl);
   // first-order TP
   if(gGTP1Auto)
   {
      gGTP = AutoTP1(e0);
      gGTP1 = TpPtsOf(MathAbs(gGTP - e0));
   }
   else gGTP = GridTpPx(e0);
   SetEdit("gridtp1", DoubleToString(Pips(gGTP1), 1));
   gGPlanned = true; gGDirty = true;
}

// lots of the grid for a base lot l0, and the leverage check of every level
bool GridBuild(double l0)
{
   double m = MathMax(0.1, gGInc / 100.0), w = 1;
   for(int i = 0; i < gGCnt; i++) { gGLots[i] = NormVol(l0 * w); w *= m; }
   return GridMarginCheck(gGLots, gGPx, gGCnt, gBuy, gGFailAt, gGMaxUse);
}

void CalcGridLots()
{
   double pt = _Point, vpp = VPP();
   double m = MathMax(0.1, gGInc / 100.0);
   gGPx[0] = gBuy ? Ask() : Bid();
   double riskMoney = RiskBase() * gGRisk / 100.0;
   double sumw = 0, w = 1;
   for(int i = 0; i < gGCnt; i++) { sumw += w * MathAbs(gGPx[i] - gGSL) / pt; w *= m; }
   double l0 = (sumw > 0 && vpp > 0) ? riskMoney / (vpp * sumw) : 0;
   // leverage: the LAST grid order must still be affordable after the drawdown of all earlier orders (and of open trades)
   RI_Load(); LoadMarginCtx();
   gGCapped = false;
   bool ok = GridBuild(l0);
   if(!ok)
   {
      gGCapped = true;
      double lo = 0, hi = l0;
      for(int it = 0; it < 40; it++) { double mid = (lo + hi) / 2.0; if(GridBuild(mid)) lo = mid; else hi = mid; }
      ok = GridBuild(lo);
   }
   gGMarginOK = ok;
   gGRiskAct = 0;
   for(int i = 0; i < gGCnt; i++) gGRiskAct += gGLots[i] * MathAbs(gGPx[i] - gGSL) / pt * vpp;
}

void PreviewGrid()
{
   if(!gGPlanned) PlanGrid();
   CalcGridLots();
   double pt = _Point, vpp = VPP(), e0 = gGPx[0];
   if(!gGTP1Auto) gGTP = GridTpPx(e0);   // manual TP1 = fixed pips from the entry
   PLine(V + "G0", e0, cAcc, STYLE_SOLID, false, true);
   PText(V + "T_G0", e0, StringFormat(" #1 MARKET %.2f lot", gGLots[0]), cAcc);
   for(int k = 1; k < 8; k++)
   {
      string nm = V + "G" + IntegerToString(k);
      if(k < gGCnt)
      {
         PLine(nm, gGPx[k], cWarn, STYLE_DASH, true, gGDirty);
         PText(V + "T_G" + IntegerToString(k), gGPx[k], StringFormat(" #%d pending %.2f lot", k + 1, gGLots[k]), cWarn, "#" + IntegerToString(k + 1));
      }
      else { ObjectDelete(0, nm); DelTxt(V + "T_G" + IntegerToString(k)); }
   }
   PLine(V + "GSL", gGSL, cBad, STYLE_DASH, true, gGDirty);
   PText(V + "T_GSL", gGSL, StringFormat(" GRID SL  -%.2f if all filled", gGRiskAct), cBad, "SL ALL");
   PLine(V + "GTP", gGTP, cGood, STYLE_DASH, true, gGDirty || !gGTP1Auto);
   double gr1 = gGLots[0] * MathAbs(e0 - gGSL) / pt * vpp, gw1 = gGLots[0] * MathAbs(gGTP - e0) / pt * vpp;
   PText(V + "T_GTP", gGTP, StringFormat(" TP #1 only  +%.2f  R:R 1:%.2f", gw1, gr1 > 0 ? gw1 / gr1 : 0.0), cGood, "TP #1");
   PZone(V + "ZR", e0, gGSL, ZoneRisk());
   PZone(V + "ZW", e0, gGTP, ZoneRew());
   gGDirty = false;
}

void UpdatePreview()
{
   gLblN = 0;
   if(gTab == 1) PreviewLive();
   else if(gTab == 2)
   {
      // while a grid of this direction is open there is no preview of another one (unless "Allow 2nd grid" is on);
      // when it is gone the levels are re-planned automatically
      if(GridBlocked()) { if(!gGWasBlk) { ClearPreview(); gGWasBlk = true; } }
      else
      {
         if(gGWasBlk) { gGWasBlk = false; PlanGrid(); ClearPreview(); }
         if(!gGHidden) PreviewGrid();
      }
      if(gXArmed) ExtDraw();
   }
   else if(gTab == 3) { if(!gHidePrev) PreviewPend(); }
   // chart objects created AFTER the panel are painted on top of it. Whenever a line / label / zone was newly
   // created, rebuild the panel so it is created last and therefore always sits above the trade lines.
   if(gNewObj && gMode == 0 && gDragLn == "")
   {
      gNewObj = false;
      if(ObjectFind(0, P + "BG") >= 0) BuildPanel();
   }
}

void EnterTab()
{
   gDragLn = ""; gXArmed = false; gAllow2nd = false; gGWasBlk = false;
   ClearPreview();
   gGHidden = false;
   lvSLd = false; lvTPd = false; gGPlanned = false; gHidePrev = false;
   if(gTab == 1) SuggestLive();
   if(gTab == 2) PlanGrid();
   if(gTab == 3) { SuggestPending(); InitPending(); }
   UpdatePreview();
}

//+------------------------------------------------------------------+
//| trading actions                                                  |
//+------------------------------------------------------------------+
bool Locked()
{
   if(gLock != 0) { SetMsg("Trading is locked by the prop firm guard", true); return true; }
   return false;
}

// hedge-netted worst-case gate + leverage / margin check for ONE order (market or pending)
bool PreTradeChecks(bool buy, double lot, double entry, double sl, double tp, bool pend)
{
   UpdateStats();
   RI_Load(); int nb = gRN; double before = RI_Worst();
   if(sl > 0) RI_Add(_Symbol, buy ? 1 : -1, lot, entry, sl, tp, pend, true, -1);
   bool gate = HedgeGate(before);
   RI_Cut(nb);
   if(!gate) return false;
   LoadMarginCtx(true);
   double m, eq;
   if(!StageOK(buy, entry, lot, 0, m, eq))
   {
      SetMsg(StringFormat("Blocked by leverage: margin %.2f > %.0f%% of equity %.2f %s", m, InpMarginUsePct, eq,
                          pend ? "when the order triggers" : "after this order"), true);
      return false;
   }
   return true;
}

void DoMarket(bool buy)
{
   if(Locked()) return;
   double pt = _Point, e = buy ? Ask() : Bid();
   double sl = 0, tp = 0;
   if(gSlOn) sl = (buy == gBuy && lvSLd) ? lvSL : (buy ? e - gSlPts * pt - SpD() : e + gSlPts * pt + SpD());
   if(gTpOn) tp = (buy == gBuy && lvTPd) ? lvTP : (buy ? e + gTpPts * pt : e - gTpPts * pt);
   sl = gSlOn ? NP(sl) : 0; tp = gTpOn ? NP(tp) : 0;
   double slp = gSlOn ? MathAbs(e - sl) / pt : 0;
   UpdateStats();
   if(gAuto) AutoLot(slp, buy, e);
   double lot = NormVol(gLot);
   if(!PreTradeChecks(buy, lot, e, sl, tp, false)) return;
   trade.SetExpertMagicNumber(gMagic);
   bool ok = buy ? trade.Buy(lot, _Symbol, 0, sl, tp, CmLive(true)) : trade.Sell(lot, _Symbol, 0, sl, tp, CmLive(false));
   SetMsg(ok ? StringFormat("%s %.2f lot sent", buy ? "BUY" : "SELL", lot)
             : "Order failed: " + trade.ResultRetcodeDescription(), !ok);
}

void CloseScoped(int mode)   // 0 all (+pendings), 1 profit, 2 loss
{
   trade.SetExpertMagicNumber(gMagic);
   int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(!InScope(PositionGetString(POSITION_SYMBOL), PositionGetInteger(POSITION_MAGIC))) continue;
      double pf = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      if(mode == 1 && pf <= 0) continue;
      if(mode == 2 && pf >= 0) continue;
      if(trade.PositionClose(t)) n++;
   }
   if(mode == 0)
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong t = OrderGetTicket(i); if(t == 0) continue;
         if(!InScope(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC))) continue;
         if(trade.OrderDelete(t)) n++;
      }
   SetMsg(StringFormat("Closed/deleted %d", n));
}

// an identical pending order (same side, price, volume, comment) is never placed twice
bool PendingExists(double price, double vol)
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol || OrderGetInteger(ORDER_MAGIC) != gMagic) continue;
      long ot = OrderGetInteger(ORDER_TYPE);
      bool b = (ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP);
      if(b != gBuy) continue;
      if(MathAbs(OrderGetDouble(ORDER_PRICE_OPEN) - price) < _Point * 0.5 && MathAbs(OrderGetDouble(ORDER_VOLUME_CURRENT) - vol) < 1e-9
         && CmIsPend(OrderGetString(ORDER_COMMENT))) return true;
   }
   return false;
}

void PlacePending()
{
   if(Locked()) return;
   double pt = _Point, e = NP(pdE), ref = gBuy ? Ask() : Bid();
   if(MathAbs(e - ref) / pt < gMinDist) { SetMsg("Entry is closer than the min distance", true); return; }
   double sl = gSlOn ? NP(pdSL) : 0, tp = gTpOn ? NP(pdTP) : 0;
   if(gSlOn && ((gBuy && sl >= e) || (!gBuy && sl <= e))) { SetMsg("SL is on the wrong side of entry", true); return; }
   if(gTpOn && ((gBuy && tp <= e) || (!gBuy && tp >= e))) { SetMsg("TP is on the wrong side of entry", true); return; }
   double slp = gSlOn ? MathAbs(e - sl) / pt : 0;
   UpdateStats();
   if(gAuto) AutoLot(slp, gBuy, e);
   double lot = NormVol(gLot);
   if(PendingExists(e, lot)) { SetMsg("An identical pending order already exists - not placed again", true); return; }
   if(!PreTradeChecks(gBuy, lot, e, sl, tp, true)) return;
   trade.SetExpertMagicNumber(gMagic);
   bool ok;
   if(gBuy) ok = (e < Ask()) ? trade.BuyLimit(lot, e, _Symbol, sl, tp, ORDER_TIME_GTC, 0, CmPend(true))
                             : trade.BuyStop(lot, e, _Symbol, sl, tp, ORDER_TIME_GTC, 0, CmPend(true));
   else     ok = (e > Bid()) ? trade.SellLimit(lot, e, _Symbol, sl, tp, ORDER_TIME_GTC, 0, CmPend(false))
                             : trade.SellStop(lot, e, _Symbol, sl, tp, ORDER_TIME_GTC, 0, CmPend(false));
   SetMsg(ok ? "Pending order placed" : "Pending failed: " + trade.ResultRetcodeDescription(), !ok);
   if(ok) { gHidePrev = true; ClearPreview(); }
}

void CancelPending()
{
   int n = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(!InScope(OrderGetString(ORDER_SYMBOL), OrderGetInteger(ORDER_MAGIC))) continue;
      if(trade.OrderDelete(t)) n++;
   }
   SetMsg(StringFormat("Deleted %d pending orders", n));
}

//--- grids: several grids (buy AND sell, even stacked) can live side by side.
//    Every grid gets its own id in the order comment: <comment>_grid<id>
bool IsGridComment(string c) { return CmIsGrid(c); }
int  GridIdOf(string c)      { return CmGridId(c); }
bool GridMatch(string c, int id) { return IsGridComment(c) && GridIdOf(c) == id; }

int NextGridId()
{
   int id = (int)(TimeCurrent() % 1000000);
   if(id < 1) id = 1;
   int ids[]; bool bs[]; int n = CollectGrids(ids, bs);
   for(int guard = 0; guard < 1000; guard++)
   {
      bool used = false;
      for(int i = 0; i < n; i++) if(ids[i] == id) { used = true; break; }
      if(!used) break;
      id = (id % 999999) + 1;
   }
   return id;
}

void AddGrid(int &ids[], bool &buys[], int &n, int id, bool b)
{
   for(int i = 0; i < n; i++) if(ids[i] == id) return;
   ArrayResize(ids, n + 1); ArrayResize(buys, n + 1);
   ids[n] = id; buys[n] = b; n++;
}

int CollectGrids(int &ids[], bool &buys[])
{
   ArrayResize(ids, 0); ArrayResize(buys, 0); int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      string c = PositionGetString(POSITION_COMMENT);
      if(!IsGridComment(c)) continue;
      AddGrid(ids, buys, n, GridIdOf(c), PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol || OrderGetInteger(ORDER_MAGIC) != gMagic) continue;
      string c = OrderGetString(ORDER_COMMENT);
      if(!IsGridComment(c)) continue;
      long ot = OrderGetInteger(ORDER_TYPE);
      AddGrid(ids, buys, n, GridIdOf(c), ot == ORDER_TYPE_BUY_LIMIT || ot == ORDER_TYPE_BUY_STOP);
   }
   return n;
}

void CountGrids(int &nb, int &ns)
{
   int ids[]; bool bs[]; int n = CollectGrids(ids, bs);
   nb = 0; ns = 0;
   for(int i = 0; i < n; i++) { if(bs[i]) nb++; else ns++; }
}

// a grid of the CURRENT direction is open (positions or pendings) and the user has not enabled a 2nd one: no preview, no new grid
bool GridBlocked()
{
   int nb, ns; CountGrids(nb, ns);
   return ((gBuy ? nb : ns) > 0) && !gAllow2nd;
}
string GridNote(color &c)
{
   int ids[]; bool bs[]; int g = CollectGrids(ids, bs), id = -1;
   for(int i = 0; i < g; i++) if(bs[i] == gBuy && ids[i] > id) id = ids[i];
   if(id < 0) { c = cDim; return " ";}                       // a blank must be " " - an empty label text shows as "Label"
   int pos = 0, pend = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == gMagic && GridMatch(PositionGetString(POSITION_COMMENT), id)) pos++;
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == gMagic && GridMatch(OrderGetString(ORDER_COMMENT), id)) pend++;
   }
   c = cWarn;
   return StringFormat("%s GRID #%d IS OPEN (%d filled, %d pending)%s", gBuy ? "BUY" : "SELL", id, pos, pend,
                       gAllow2nd ? " - 2nd grid enabled" : " - preview off");
}

int CloseGridId(int id)
{
   int n = 0;
   trade.SetExpertMagicNumber(gMagic);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == gMagic
         && GridMatch(PositionGetString(POSITION_COMMENT), id)) { if(ClosePos(t)) n++; }
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == gMagic
         && GridMatch(OrderGetString(ORDER_COMMENT), id)) { if(DelOrd(t)) n++; }
   }
   return n;
}

// closes every grid of one side (all its positions + pending orders)
void CloseGrids(bool buy, string why)
{
   int ids[]; bool bs[]; int g = CollectGrids(ids, bs), n = 0, cnt = 0;
   for(int i = 0; i < g; i++) if(bs[i] == buy) { n += CloseGridId(ids[i]); cnt++; }
   SetMsg(StringFormat("%d %s grid(s) closed (%d orders): %s", cnt, buy ? "BUY" : "SELL", n, why));
}

void PlaceGrid()
{
   if(Locked()) return;
   if(GridBlocked()) { SetMsg(StringFormat("A %s grid is already open - switch to the other side or tick 'Allow 2nd grid' first", gBuy ? "BUY" : "SELL"), true); return; }
   if(gGHidden) { SetMsg("This grid is already placed - click Re-suggest levels (or switch side) to plan a new one", true); return; }
   double pt = _Point, ms = MinStop() + 5 * pt;
   CalcGridLots();
   // auto TP1 level may have been overtaken by price since it was planned
   if(gGTP1Auto && (gBuy ? gGTP < gGPx[0] + ms : gGTP > gGPx[0] - ms))
   { gGTP = AutoTP1(gGPx[0]); gGTP1 = TpPtsOf(MathAbs(gGTP - gGPx[0])); }
   if(!gGTP1Auto) gGTP = GridTpPx(gGPx[0]);
   UpdateStats();
   if(!gGMarginOK)
   {
      SetMsg(StringFormat("Blocked by leverage: grid order #%d cannot be carried (margin %.0f%% of equity > %.0f%%) even with minimum lots",
                          gGFailAt + 1, gGMaxUse, InpMarginUsePct), true);
      return;
   }
   RI_Load(); int nbase = gRN; double before = RI_Worst();
   for(int k = 0; k < gGCnt; k++)
      RI_Add(_Symbol, gBuy ? 1 : -1, gGLots[k], gGPx[k], gGSL, (k == 0 && gGTP1 > 0) ? gGTP : 0.0, k > 0, true, -1);
   bool gate = HedgeGate(before);
   RI_Cut(nbase);
   if(!gate) return;
   int id = NextGridId();
   string cm = CmGrid(gBuy, id, 0);
   double sl = gGSL, tp1 = (gGTP1 > 0) ? gGTP : 0;
   trade.SetExpertMagicNumber(gMagic);
   bool ok = gBuy ? trade.Buy(gGLots[0], _Symbol, 0, sl, tp1, cm) : trade.Sell(gGLots[0], _Symbol, 0, sl, tp1, cm);
   if(!ok) { SetMsg("Grid order #1 failed: " + trade.ResultRetcodeDescription(), true); return; }
   double p1 = trade.ResultPrice(); if(p1 <= 0) p1 = gGPx[0];       // real open price of the 1st order
   int bad = 0;
   for(int k = 1; k < gGCnt; k++)
   {
      // every pending order carries a TP at the 1st order's price: profit + stop are server-side even if the EA / VPS goes off
      double tpk = (gGInitTP && MathAbs(p1 - gGPx[k]) >= ms) ? NP(p1) : 0.0;
      bool o = gBuy ? trade.BuyLimit(gGLots[k], gGPx[k], _Symbol, sl, tpk, ORDER_TIME_GTC, 0, CmGrid(true, id, k))
                    : trade.SellLimit(gGLots[k], gGPx[k], _Symbol, sl, tpk, ORDER_TIME_GTC, 0, CmGrid(false, id, k));
      if(!o) bad++;
   }
   ClearPreview();
   gAllow2nd = false;                                                // the 2nd-grid permission is used up
   double target = RiskBase() * gGRisk / 100.0;
   string m = (bad == 0) ? StringFormat("%s grid #%d placed", gBuy ? "BUY" : "SELL", id)
                         : StringFormat("Grid #%d placed, %d pending failed: %s", id, bad, trade.ResultRetcodeDescription());
   if(target > 0 && gGRiskAct > target * 1.10)
      m += StringFormat(" | risk %.2f > target %.2f (min lot / lot step)", gGRiskAct, target);
   SetMsg(m, bad > 0);
}

// breakeven for one grid: SL of all its positions -> average entry +/- buffer; the unfilled pendings are dropped
void ApplyBE(int id, bool buy, double avg)
{
   double pt = _Point, pip = PipPts() * pt;
   double buf = gBEBuf * pip, trig = gBETrig * pip, ms = MinStop() + 2 * pt;
   double mv  = buy ? (Bid() - avg) : (avg - Ask());
   double nsl = NP(buy ? avg + buf : avg - buf);
   double room = buy ? (Bid() - nsl) : (nsl - Ask());
   bool need = !(mv <= 0 || mv < trig || room < ms);
   if(!Gate("be" + IntegerToString(id), need)) return;
   Gate("be" + IntegerToString(id), false);
   trade.SetExpertMagicNumber(gMagic);
   int moved = 0, del = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      if(!GridMatch(PositionGetString(POSITION_COMMENT), id)) continue;
      double cur = PositionGetDouble(POSITION_SL);
      bool better = (cur == 0) || (buy ? nsl > cur : nsl < cur);
      if(better && ModPos(t, nsl, PositionGetDouble(POSITION_TP))) moved++;
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol || OrderGetInteger(ORDER_MAGIC) != gMagic) continue;
      if(GridMatch(OrderGetString(ORDER_COMMENT), id) && DelOrd(t)) del++;
   }
   if(moved > 0 || del > 0)
      SetMsg(StringFormat("Grid #%d breakeven: SL %s on %d position(s), %d pending dropped", id, DoubleToString(nsl, _Digits), moved, del));
}

// --- real (server-side) take profit of a grid: from the 2nd filled order on, every open position AND every remaining pending
//     order of the grid carries the grid take-profit price (average entry +/- the grid TP). It is re-set after EVERY new fill,
//     so the grid keeps a sensible exit even if the EA / VPS goes offline.
double ProfitPerPriceUnit()
{
   double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT); if(tv <= 0) tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   return (ts > 0) ? tv / ts : 0;
}
int GridTpApply(int id, bool buy, double tpPx, bool apply)
{
   double pt = _Point, ms = MinStop() + 2 * pt; int n = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      if(!GridMatch(PositionGetString(POSITION_COMMENT), id)) continue;
      if(MathAbs(PositionGetDouble(POSITION_TP) - tpPx) < pt * 0.5) continue;
      if(buy ? tpPx < Bid() + ms : tpPx > Ask() - ms) continue;       // already reached / too close: the grid-TP rule below closes it
      double sl = PositionGetDouble(POSITION_SL);
      n++;
      if(apply) ModPos(t, sl, tpPx);
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol || OrderGetInteger(ORDER_MAGIC) != gMagic) continue;
      if(!GridMatch(OrderGetString(ORDER_COMMENT), id)) continue;
      double price = OrderGetDouble(ORDER_PRICE_OPEN);
      if(MathAbs(OrderGetDouble(ORDER_TP) - tpPx) < pt * 0.5) continue;
      if(buy ? tpPx < price + ms : tpPx > price - ms) continue;
      n++;
      if(apply) ModOrd(t, tpPx);
   }
   return n;
}
void GridTpMove(int id, bool buy, double vol, double wsum)
{
   if(vol <= 0) return;
   double avg = wsum / vol, tpPx;
   if(gGTPMoney)
   {
      double pv = ProfitPerPriceUnit(); if(pv <= 0) return;
      double d = gGTPVal / (vol * pv);                              // price distance at which the whole grid shows the target amount
      tpPx = buy ? avg + d : avg - d;
   }
   else tpPx = buy ? avg + gGTPVal * _Point : avg - gGTPVal * _Point;
   tpPx = NP(tpPx);
   string key = "tpm" + IntegerToString(id);
   if(!Gate(key, GridTpApply(id, buy, tpPx, false) > 0)) return;
   int n = GridTpApply(id, buy, tpPx, true);
   Gate(key, false);
   if(n > 0) Print("PFP grid #", id, ": real TP moved to ", DoubleToString(tpPx, _Digits), " on ", n, " order(s)");
}

void ManageGrid(int id)
{
   int pos = 0, pend = 0; double vol = 0, profit = 0, wsum = 0; bool buy = true;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      if(!GridMatch(PositionGetString(POSITION_COMMENT), id)) continue;
      double v = PositionGetDouble(POSITION_VOLUME);
      pos++; vol += v; wsum += v * PositionGetDouble(POSITION_PRICE_OPEN);
      profit += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
      buy = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY);
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == gMagic
         && GridMatch(OrderGetString(ORDER_COMMENT), id)) pend++;
   }
   if(Gate("gdn" + IntegerToString(id), pos == 0 && pend > 0))
   { Gate("gdn" + IntegerToString(id), false); CloseGridId(id); SetMsg(StringFormat("Grid #%d closed: first order finished (TP/SL)", id)); return; }
   if(pos == 0) return;
   if(gBEOn && vol > 0) ApplyBE(id, buy, wsum / vol);
   if(pos < 2) return;
   // more than one order active: manage the whole grid
   trade.SetExpertMagicNumber(gMagic);
   if(gGMoveTP) GridTpMove(id, buy, vol, wsum);
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      if(!GridMatch(PositionGetString(POSITION_COMMENT), id)) continue;
      if(!gGMoveTP && !gGInitTP && PositionGetDouble(POSITION_TP) != 0) ModPos(t, PositionGetDouble(POSITION_SL), 0.0);
   }
   bool hit;
   if(gGTPMoney) hit = (profit >= gGTPVal);
   else
   {
      double avg = wsum / vol;
      double mv = buy ? (Bid() - avg) : (avg - Ask());
      hit = (mv / _Point >= gGTPVal);
   }
   if(Gate("gtp" + IntegerToString(id), hit))
   { Gate("gtp" + IntegerToString(id), false); CloseGridId(id); SetMsg(StringFormat("Grid #%d closed: grid take profit reached", id)); }
}

void ManageGrids()
{
   int ids[]; bool bs[]; int n = CollectGrids(ids, bs);
   for(int g = 0; g < n; g++) ManageGrid(ids[g]);
}

//+------------------------------------------------------------------+
//| extend grid: move the stop to the next strong S/R zone and add   |
//| orders up to the remaining daily-DD allowance (day profit incl.) |
//+------------------------------------------------------------------+
bool GridSnapshot(int id, bool buy)
{
   gSnN = 0; gXCurSL = 0; gXExt = 0; gXLastLot = 0; double extPx = 0; bool have = false;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      if(!GridMatch(PositionGetString(POSITION_COMMENT), id) || gSnN >= 48) continue;
      gSnPx[gSnN] = PositionGetDouble(POSITION_PRICE_OPEN); gSnVol[gSnN] = PositionGetDouble(POSITION_VOLUME); gSnPend[gSnN] = false; gSnN++;
      double sl = PositionGetDouble(POSITION_SL);
      if(sl > 0 && (gXCurSL == 0 || (buy ? sl < gXCurSL : sl > gXCurSL))) gXCurSL = sl;
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol || OrderGetInteger(ORDER_MAGIC) != gMagic) continue;
      if(!GridMatch(OrderGetString(ORDER_COMMENT), id) || gSnN >= 48) continue;
      gSnPx[gSnN] = OrderGetDouble(ORDER_PRICE_OPEN); gSnVol[gSnN] = OrderGetDouble(ORDER_VOLUME_CURRENT); gSnPend[gSnN] = true; gSnN++;
      double sl = OrderGetDouble(ORDER_SL);
      if(sl > 0 && (gXCurSL == 0 || (buy ? sl < gXCurSL : sl > gXCurSL))) gXCurSL = sl;
   }
   for(int i = 0; i < gSnN; i++)
      if(!have || (buy ? gSnPx[i] < extPx : gSnPx[i] > extPx)) { extPx = gSnPx[i]; gXLastLot = gSnVol[i]; have = true; }
   gXExt = extPx;
   gXFirst = (gSnN > 0) ? gSnPx[0] : 0;
   for(int i = 1; i < gSnN; i++) gXFirst = buy ? MathMax(gXFirst, gSnPx[i]) : MathMin(gXFirst, gSnPx[i]);   // 1st order = nearest to the market
   if(!have || gXCurSL <= 0) return false;
   if(buy ? gXCurSL >= gXExt : gXCurSL <= gXExt) return false;     // stop already at breakeven / inside the grid: nothing to extend
   return true;
}

// new master SL: beyond the next S/R zone past the current stop (never inside a zone or its buffer band)
double ExtNewSL(bool buy, double curSL, double ext)
{
   double pt = _Point, buf = SLBuf(), gap = GMinEff() * pt;
   int zi = buy ? LvBelow(curSL - gap * 0.5) : LvAbove(curSL + gap * 0.5);
   double sl;
   if(zi >= 0) sl = buy ? gSR[zi].lo - buf : gSR[zi].hi + buf;
   else        sl = buy ? curSL - gap * 2.0 : curSL + gap * 2.0;
   if(buy) { for(int g = gSRn - 1; g >= 0; g--) if(sl <= gSR[g].hi && sl >= gSR[g].lo - buf) sl = gSR[g].lo - buf; }
   else    { for(int g = 0; g < gSRn; g++)      if(sl >= gSR[g].lo && sl <= gSR[g].hi + buf) sl = gSR[g].hi + buf; }
   if(buy && sl >= curSL - pt) sl = curSL - gap;
   if(!buy && sl <= curSL + pt) sl = curSL + gap;
   if(buy && ext - sl < gap) sl = ext - gap;
   if(!buy && sl - ext < gap) sl = ext + gap;
   return NP(sl);
}

// levels for the added orders: between the deepest order and the new stop (S/R levels first, grid spacing otherwise)
int ExtLevels(bool buy, double ext, double newSL, int existing, double &px[])
{
   double pt = _Point, ms = MinStop() + 5 * pt, gapB = GMinEff();
   double prev = ext; double L[]; int n = 0; int maxN = MathMin(8, MathMax(0, InpExtMaxAdd));
   double cur = buy ? Bid() : Ask();
   for(int j = 0; j < maxN; j++)
   {
      double need = gapB * (1.0 + (existing - 1 + j) * gGDistPct / 100.0) * pt;
      int c = buy ? Below(prev - need + pt, 1, L) : Above(prev + need - pt, 1, L);
      double p = (c > 0) ? L[0] : (buy ? prev - need : prev + need);
      double lim = gapB * 0.5 * pt;
      if(buy ? p <= newSL + lim : p >= newSL - lim) break;         // no room left before the new stop
      prev = p;
      if(buy ? p > cur - ms : p < cur + ms) continue;              // price already passed this level
      px[n++] = NP(p);
   }
   return n;
}

// does the plan fit? stop moved to gXSL, 'a' orders added with lots = scale x natural continuation of the lot multiplier
//   risk   : worst case of the WHOLE account (hedge-netted) <= allowance
//   margin : every pending level of the grid (old + new) must still be affordable after the drawdown of the orders before it
bool ExtEval(bool buy, int id, int a, double scale, double &risk)
{
   double m = MathMax(0.1, gGInc / 100.0), lot = gXLastLot;
   for(int j = 0; j < a; j++) { lot *= m; gXLots[j] = NormVol(lot * scale); }
   RI_Load();
   for(int i = 0; i < gRN; i++) if(gRI[i].gid == id) gRI[i].sl = gXSL;
   for(int j = 0; j < a; j++) RI_Add(_Symbol, buy ? 1 : -1, gXLots[j], gXPx[j], gXSL, 0, true, true, id);
   risk = RI_Worst();
   bool riskOk = (risk <= gXAllow + 0.005);
   LoadMarginCtx();
   double pxs[56], vs[56]; int n = 0;
   for(int i = 0; i < gSnN; i++) if(gSnPend[i] && n < 56) { pxs[n] = gSnPx[i]; vs[n] = gSnVol[i]; n++; }
   for(int j = 0; j < a && n < 56; j++) { pxs[n] = gXPx[j]; vs[n] = gXLots[j]; n++; }
   for(int i = 1; i < n; i++)                                       // nearest to the market first
   {
      double kp = pxs[i], kv = vs[i]; int j = i - 1;
      while(j >= 0 && (buy ? pxs[j] < kp : pxs[j] > kp)) { pxs[j + 1] = pxs[j]; vs[j + 1] = vs[j]; j--; }
      pxs[j + 1] = kp; vs[j + 1] = kv;
   }
   bool mOk = true; double cum = 0, perPt = VPP() / _Point;
   for(int k = 0; k < n && mOk; k++)
   {
      double fl = 0;
      for(int i = 0; i < k; i++) fl += vs[i] * MathAbs(pxs[k] - pxs[i]) * perPt;
      double mm, eq;
      if(!StageOK(buy, pxs[k], cum + vs[k], fl, mm, eq)) mOk = false;
      cum += vs[k];
   }
   return riskOk && mOk;
}

void ExtDraw()
{
   if(!gXArmed) return;
   PLine(V + "XSL", gXSL, cBad, STYLE_DOT, false, true);
   PText(V + "T_XSL", gXSL, StringFormat(" NEW GRID SL (worst case -%.2f)", gXRisk), cBad);
   for(int j = 0; j < 8; j++)
   {
      string nm = V + "X" + IntegerToString(j);
      if(j < gXN)
      {
         PLine(nm, gXPx[j], cWarn, STYLE_DOT, false, true);
         PText(V + "T_X" + IntegerToString(j), gXPx[j], StringFormat(" +%.2f lot (new)", gXLots[j]), cWarn);
      }
      else { ObjectDelete(0, nm); DelTxt(V + "T_X" + IntegerToString(j)); }
   }
}

void ExtendExecute()
{
   gXArmed = false; ClearExtPreview();
   int id = gXId; bool buy = gBuy;
   UpdateStats(); gXAllow = MathMax(0.0, gAllow) * InpExtUsePct / 100.0;
   if(!GridSnapshot(id, buy)) { SetMsg("Grid changed - extend cancelled", true); return; }
   double risk;
   if(!ExtEval(buy, id, gXN, gXScale, risk)) { SetMsg("Market moved: the plan no longer fits the allowance - click EXTEND again", true); return; }
   trade.SetExpertMagicNumber(gMagic);
   int okn = 0, bad = 0;
   for(int j = 0; j < gXN; j++)                                   // new orders first (they carry the new, deeper stop)
   {
      double tpj = (gGInitTP && MathAbs(gXFirst - gXPx[j]) >= MinStop() + 5 * _Point) ? NP(gXFirst) : 0.0;
      bool o = buy ? trade.BuyLimit(gXLots[j], gXPx[j], _Symbol, gXSL, tpj, ORDER_TIME_GTC, 0, CmGrid(true, id, gSnN + j))
                   : trade.SellLimit(gXLots[j], gXPx[j], _Symbol, gXSL, tpj, ORDER_TIME_GTC, 0, CmGrid(false, id, gSnN + j));
      if(o) okn++; else bad++;
   }
   int moved = 0, mfail = 0;                                      // then move the stop of every existing order of this grid
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol || PositionGetInteger(POSITION_MAGIC) != gMagic) continue;
      if(!GridMatch(PositionGetString(POSITION_COMMENT), id)) continue;
      if(trade.PositionModify(t, gXSL, PositionGetDouble(POSITION_TP))) moved++; else mfail++;
   }
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong t = OrderGetTicket(i); if(t == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol || OrderGetInteger(ORDER_MAGIC) != gMagic) continue;
      if(!GridMatch(OrderGetString(ORDER_COMMENT), id)) continue;
      if(trade.OrderModify(t, OrderGetDouble(ORDER_PRICE_OPEN), gXSL, OrderGetDouble(ORDER_TP), ORDER_TIME_GTC, 0)) moved++; else mfail++;
   }
   SetMsg(StringFormat("Grid #%d extended: SL -> %s, +%d orders, worst case -%.2f of %.2f allowed%s", id, DoubleToString(gXSL, _Digits),
                       okn, risk, gXAllow, (bad + mfail > 0) ? StringFormat(" | %d failed: %s", bad + mfail, trade.ResultRetcodeDescription()) : ""), (bad + mfail) > 0);
}

void ExtendGrid()
{
   if(Locked()) return;
   if(gXArmed && GetTickCount() - gXTime < 15000) { ExtendExecute(); return; }     // second click = confirm
   gXArmed = false; ClearExtPreview();
   int ids[]; bool bs[]; int g = CollectGrids(ids, bs), id = -1;
   for(int i = 0; i < g; i++) if(bs[i] == gBuy && ids[i] > id) id = ids[i];
   if(id < 0) { SetMsg(StringFormat("No active %s grid to extend", gBuy ? "BUY" : "SELL"), true); return; }
   if(!GridSnapshot(id, gBuy)) { SetMsg("This grid has no stop beyond its orders to move (breakeven?)", true); return; }
   if(gSRn == 0) BuildSR();
   UpdateStats();
   gXAllow = MathMax(0.0, gAllow) * InpExtUsePct / 100.0;      // allowance already includes today's profit (equity above the day reference)
   gXId = id; gXSL = ExtNewSL(gBuy, gXCurSL, gXExt);
   int amax = ExtLevels(gBuy, gXExt, gXSL, gSnN, gXPx);
   double risk = 0, sc = 1.0; int use = -1;
   for(int a = amax; a >= 1 && use < 0; a--) if(ExtEval(gBuy, id, a, 1.0, risk)) use = a;
   if(use < 0 && amax >= 1)
   {
      double lo = 0, hi = 1.0;                                  // natural lots too big: shrink the added lots, keep at least one new order
      for(int it = 0; it < 30; it++) { double mid = (lo + hi) / 2.0; if(ExtEval(gBuy, id, 1, mid, risk)) lo = mid; else hi = mid; }
      if(lo > 0.0 && ExtEval(gBuy, id, 1, lo, risk)) { use = 1; sc = lo; }
   }
   if(use < 0 && ExtEval(gBuy, id, 0, 1.0, risk)) { use = 0; sc = 1.0; }   // no room for new orders: move the stop only
   if(use < 0)
   {
      ExtEval(gBuy, id, 0, 1.0, risk);
      SetMsg(StringFormat("Cannot extend: SL at %s alone needs %.2f > allowance %.2f (or margin too low)", DoubleToString(gXSL, _Digits), risk, gXAllow), true);
      return;
   }
   ExtEval(gBuy, id, use, sc, risk);                            // leave lots / risk matching the chosen plan
   gXN = use; gXScale = sc; gXRisk = risk; gXArmed = true; gXTime = GetTickCount();
   string ls = "";
   for(int j = 0; j < use; j++) ls += (j > 0 ? "/" : "") + DoubleToString(gXLots[j], 2);
   Print("PFP extend plan grid #", id, ": SL ", DoubleToString(gXCurSL, _Digits), " -> ", DoubleToString(gXSL, _Digits),
         ", added lots ", ls, ", worst case ", DoubleToString(risk, 2), " / allowance ", DoubleToString(gXAllow, 2));
   SetMsg(StringFormat("Extend #%d: SL %s -> %s, +%d orders | worst case -%.2f of %.2f allowed (day P/L %+.2f). CLICK AGAIN to confirm",
                       id, DoubleToString(gXCurSL, _Digits), DoubleToString(gXSL, _Digits), use, risk, gXAllow, -gDayLoss));
   UpdatePreview();
}

//+------------------------------------------------------------------+
//| strategy tester: automatic S/R-bounce trades (tester only)       |
//+------------------------------------------------------------------+
// One decision per new bar of the S/R timeframe: a bar that touches a strong level and closes back on the right side of it.
// SL beyond the zone (+ buffer + spread), TP at the next level (at least the minimum R:R). Lot from the risk %, capped by the
// leverage rule; every order goes through the same hedge / allowance / margin gates as a manual order.
void TesterAuto()
{
   if(gLock != 0) return;
   ENUM_TIMEFRAMES tf = EffTF();
   datetime bt = iTime(_Symbol, tf, 0);
   if(bt == 0 || bt == gTestBar) return;
   gTestBar = bt;
   if(gSRn == 0 || gATR <= 0) return;
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) return;
   int open = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong t = PositionGetTicket(i); if(t == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == gMagic) open++;
   }
   if(open >= MathMax(1, InpTestMaxTrades)) return;
   MqlRates r[]; ArraySetAsSeries(r, true);
   if(CopyRates(_Symbol, tf, 1, 1, r) < 1) return;             // r[0] = the last CLOSED bar
   double tol = gATR * 0.25;
   int dir = 0, li = -1;
   for(int i = 0; i < gSRn && dir == 0; i++)
   {
      double L = gSR[i].price;
      if(r[0].low <= L + tol && r[0].low >= L - gATR && r[0].close > L && r[0].close > r[0].open) { dir = 1; li = i; }
      else if(r[0].high >= L - tol && r[0].high <= L + gATR && r[0].close < L && r[0].close < r[0].open) { dir = -1; li = i; }
   }
   if(dir == 0) return;
   bool buy = (dir > 0);
   double e = buy ? Ask() : Bid(), buf = SLBuf(), ms = MinStop() + 5 * _Point;
   if(e <= 0) return;
   double sl = buy ? MathMin(gSR[li].lo, r[0].low) - buf : MathMax(gSR[li].hi, r[0].high) + buf;
   if(buy ? e - sl < ms : sl - e < ms) sl = buy ? e - ms : e + ms;
   double risk = MathAbs(e - sl), rr = MathMax(1.0, InpTestMinRR);
   double T[];
   int c = buy ? Above(e + MathMax(ms, risk * rr), 1, T) : Below(e - MathMax(ms, risk * rr), 1, T);
   double tp = (c > 0) ? T[0] : (buy ? e + risk * rr : e - risk * rr);
   if(MathAbs(tp - e) > risk * 4.0) tp = buy ? e + risk * rr : e - risk * rr;
   sl = NP(sl); tp = NP(tp);
   // lot: risk % -> capped by the leverage rule (AutoLot works on the panel globals, which are restored right after)
   bool sa = gAuto, ss = gSlOn; double sr = gRisk;
   gAuto = true; gSlOn = true; gRisk = InpTestRiskPct;
   AutoLot(risk / _Point, buy, e);
   gAuto = sa; gSlOn = ss; gRisk = sr;
   double lot = NormVol(gLot), vpp = VPP();
   if(vpp <= 0) return;
   if(lot * (risk / _Point) * vpp > RiskBase() * InpTestRiskPct / 100.0 * 2.0) return;   // the minimum lot would risk far more than planned: skip
   if(!PreTradeChecks(buy, lot, e, sl, tp, false)) return;
   trade.SetExpertMagicNumber(gMagic);
   bool ok = buy ? trade.Buy(lot, _Symbol, 0, sl, tp, CmTest(true)) : trade.Sell(lot, _Symbol, 0, sl, tp, CmTest(false));
   if(!ok) Print("PFP tester: order failed - ", trade.ResultRetcodeDescription());
}

// custom optimisation criterion (recovery factor, rewarding a decent number of trades)
double OnTester()
{
   double tr = TesterStatistics(STAT_TRADES);
   if(tr < 10) return 0.0;
   return TesterStatistics(STAT_RECOVERY_FACTOR) * MathSqrt(tr);
}

//+------------------------------------------------------------------+
//| events                                                           |
//+------------------------------------------------------------------+
void ResetLinesFromPts()
{
   gHidePrev = false;
   lvSLd = false; lvTPd = false;
   if(gTab == 3) PendDefaults();
   ClearPreview(); UpdatePreview();
}

void HandleEdit(string name)
{
   string key = StringSubstr(name, StringLen(P) + 2);
   string t = ObjectGetString(0, name, OBJPROP_TEXT);
   StringReplace(t, ",", ".");
   double d = StringToDouble(t);
   bool rebuild = false;
   if(key == "startov")      { gStartOv = MathMax(0, d); }
   else if(key == "ddpct")   { gDailyDD = MathMax(0.1, d); }
   else if(key == "bufpct")  { gBuf = MathMin(90, MathMax(0, d)); }
   else if(key == "maxdd")   { gMaxDD = MathMax(0.5, d); }
   else if(key == "magic")   { gMagic = StringToInteger(t); }
   else if(key == "risk")    { gRisk = MathMax(0.01, d); }
   else if(key == "lot")     { gLot = NormVol(d); gAuto = false; rebuild = true; SetMsg("Manual lot: auto-lot (risk %) switched OFF - tick 'Auto lot' to use the risk % again"); }
   else if(key == "tp")      { gTpPts = MathMax(1, (int)d); ResetLinesFromPts(); }
   else if(key == "sl")      { gSlPts = MathMax(1, (int)d); ResetLinesFromPts(); }
   else if(key == "mindist") { gMinDist = MathMax(0, (int)d); SuggestPending(); }
   else if(key == "gridrisk")  { gGRisk = MathMax(0.01, d); }
   else if(key == "gridn")     { gGN = MathMax(2, MathMin(8, (int)d)); PlanGrid(); ClearPreview(); rebuild = true; }
   else if(key == "gridinc")   { gGInc = MathMax(10, d); }
   else if(key == "gridtp1")
   {
      // value is in PIPS; typing a value switches the automatic decision off
      gGTP1 = MathMax(1, (int)MathRound(MathMax(0.1, d) * PipPts())); gGTP1Auto = false;
      gGTP = GridTpPx(gGPx[0]);
      ObjectDelete(0, V + "GTP"); gGDirty = true;
      SetEdit("gridtp1", DoubleToString(Pips(gGTP1), 1)); SetToggle(P + "C_tp1a", "Auto TP1 (S/R) - pips", false);
   }
   else if(key == "bepips")    { gBEBuf = MathMax(0, d); }
   else if(key == "betrig")    { gBETrig = MathMax(0, d); }
   else if(key == "passpct")   { gPassPct = MathMax(0, d); }
   else if(key == "dmax")      { gDayMax = MathMax(0, d); }
   else if(key == "bkv")       { gBkVal = MathMax(0, d); }
   else if(key == "trv")       { gTrVal = MathMax(0, d); }
   else if(key == "gridtpval") { gGTPVal = MathMax(0.01, d); }
   else if(key == "gridmin")   { gGMin = MathMax(1, (int)d); PlanGrid(); ClearPreview(); }
   else if(key == "griddist")  { gGDistPct = MathMax(0, d); PlanGrid(); ClearPreview(); }
   SaveCfg();
   if(rebuild) BuildPanel(); else { UpdatePreview(); UpdateUI(); }
}

void HandleClick(string name)
{
   string k = StringSubstr(name, StringLen(P));
   if(k == "B_min") { gMin = !gMin; gDragLn = ""; SaveCfg(); BuildPanel(); ChartRedraw(); return; }
   if(k == "HDR" || k == "GRIP") return;
   if(StringFind(k, "B_tab") == 0)
   { gTab = (int)StringToInteger(StringSubstr(k, 5)); BuildPanel(); EnterTab(); return; }
   if(k == "B_buy" || k == "B_sell")
   { gBuy = (k == "B_buy"); BuildPanel(); EnterTab(); return; }
   if(k == "B_theme") { gDark = !gDark; SetTheme(); ApplyChartTheme(); SaveCfg(); BuildPanel(); ClearPreview(); UpdatePreview(); return; }
   if(k == "B_ui0") { gScale = MathMax(50, gScale - 10); SaveCfg(); BuildPanel(); return; }
   if(k == "B_ui1") { gScale = MathMin(250, gScale + 10); SaveCfg(); BuildPanel(); return; }
   if(k == "B_ui2") { gFont = MathMax(6, gFont - 1); SaveCfg(); BuildPanel(); return; }
   if(k == "B_ui3") { gFont = MathMin(24, gFont + 1); SaveCfg(); BuildPanel(); return; }
   if(k == "B_unlock")
   {
      if(gLock == 0) { SetMsg("Trading is enabled - nothing to unlock"); UpdateUI(); return; }
      gLock = 0; SaveLock(); SetMsg("Trading unlocked manually");
      CheckLimits();      // re-locks at once if the drawdown limit is still breached
      UpdateUI(); return;
   }
   if(k == "C_auto") { gAuto = !gAuto; BuildPanel(); return; }
   if(k == "C_tp")   { gTpOn = !gTpOn; BuildPanel(); UpdatePreview(); return; }
   if(k == "C_sl")   { gSlOn = !gSlOn; BuildPanel(); UpdatePreview(); return; }
   if(k == "C_sug")  { pdUseSug = !pdUseSug; BuildPanel(); return; }
   if(k == "C_tp1a") { gGTP1Auto = !gGTP1Auto; if(gGTP1Auto) PlanGrid(); SaveCfg(); BuildPanel(); ClearPreview(); UpdatePreview(); return; }
   if(k == "C_be")   { gBEOn = !gBEOn; SaveCfg(); BuildPanel(); SetMsg(gBEOn ? "Breakeven ON for grids" : "Breakeven off"); UpdateUI(); return; }
   if(k == "C_bk")   { gBkOn = !gBkOn; gBkArmed = false; gBkPeak = 0; SaveBk(); SaveCfg(); BuildPanel(); return; }
   if(k == "C_trail"){ gTrailOn = !gTrailOn; gBkArmed = false; gBkPeak = 0; SaveBk(); SaveCfg(); BuildPanel(); return; }
   if(k == "U_dmax") { gDayMaxM = !gDayMaxM; SaveCfg(); BuildPanel(); return; }
   if(k == "U_bkv")  { gBkM = !gBkM; SaveCfg(); BuildPanel(); return; }
   if(k == "U_trv")  { gTrM = !gTrM; SaveCfg(); BuildPanel(); return; }
   if(k == "B_buyNow")  { DoMarket(true);  return; }
   if(k == "B_sellNow") { DoMarket(false); return; }
   if(k == "B_close0") { CloseScoped(0); return; }
   if(k == "B_close1") { CloseScoped(1); return; }
   if(k == "B_close2") { CloseScoped(2); return; }
   if(StringFind(k, "B_sugtp") == 0)
   {
      int i = (int)StringToInteger(StringSubstr(k, 7));
      if(i >= 0 && i < 3 && sugTP[i] > 0)
      {
         lvTP = sugTP[i]; lvTPd = true; gTpOn = true;
         gTpPts = TpPtsOf(MathAbs(lvTP - (gBuy ? Ask() : Bid())));
         ObjectDelete(0, V + "TP"); BuildPanel(); UpdatePreview();
      }
      return;
   }
   if(StringFind(k, "B_sugsl") == 0)
   {
      int i = (int)StringToInteger(StringSubstr(k, 7));
      if(i >= 0 && i < 3 && sugSL[i] > 0)
      {
         lvSL = sugSL[i]; lvSLd = true; gSlOn = true;
         gSlPts = BasePts(MathAbs(lvSL - (gBuy ? Ask() : Bid())));
         ObjectDelete(0, V + "SL"); BuildPanel(); UpdatePreview();
      }
      return;
   }
   if(StringFind(k, "B_ps") == 0)
   { ApplySug((int)StringToInteger(StringSubstr(k, 4))); UpdatePreview(); UpdateUI(); return; }
   if(k == "B_ptype")
   {
      gPendType = (gPendType + 1) % 3; SaveCfg();
      SuggestPending(); gHidePrev = false; InitPending(); ClearPreview();
      BuildPanel(); UpdatePreview(); return;
   }
   if(k == "B_placep")  { PlacePending(); return; }
   if(k == "B_cancelp") { CancelPending(); return; }
   if(k == "C_mgd")
   {
      gMgrDelay = !gMgrDelay; SaveCfg(); SetTimerRate(); BuildPanel();
      SetMsg(gMgrDelay ? "Delay ON: automatic actions wait 1 s (the other terminal acts first)" : "Delay OFF: automatic actions are immediate");
      UpdateUI(); return;
   }
   if(k == "C_gmtp")
   {
      gGMoveTP = !gGMoveTP; SaveCfg(); BuildPanel();
      SetMsg(gGMoveTP ? "Real TPs of a grid move on every fill (from the 2nd order)" : "Real TPs of a grid are not moved after fills");
      UpdateUI(); return;
   }
   if(k == "C_gitp")
   {
      gGInitTP = !gGInitTP; SaveCfg(); BuildPanel();
      SetMsg(gGInitTP ? "New grids: every pending order gets a TP at the 1st order's price" : "New grids: pending orders without individual TP");
      UpdateUI(); return;
   }
   if(k == "C_g2nd")
   {
      gAllow2nd = !gAllow2nd; gGWasBlk = false;
      if(gAllow2nd) { PlanGrid(); SetMsg(StringFormat("2nd %s grid enabled - plan it, then PLACE GRID", gBuy ? "BUY" : "SELL")); }
      ClearPreview(); BuildPanel(); UpdatePreview(); UpdateUI(); return;
   }
   if(k == "B_gext")    { ExtendGrid(); return; }
   if(k == "B_srmode")
   {
      gSRMode = (gSRMode == 0) ? 1 : 0; SaveCfg();
      BuildSR(); gSRBar = iTime(_Symbol, EffTF(), 0);
      SuggestLive(); SuggestPending();
      SetMsg(StringFormat("S/R mode: %s (%d levels)", gSRMode == 0 ? "AGGRESSIVE" : "CONSERVATIVE", gSRn));
      BuildPanel(); return;
   }
   if(k == "B_gunit")   { gGTPMoney = !gGTPMoney; BuildPanel(); return; }
   if(k == "B_gplace")  { PlaceGrid(); return; }
   if(k == "B_gcancel") { CloseGrids(gBuy, "closed manually"); return; }
   if(k == "B_gresug")
   {
      if(GridBlocked()) { SetMsg(StringFormat("A %s grid is open - tick 'Allow 2nd grid' to plan another one in this direction", gBuy ? "BUY" : "SELL"), true); return; }
      // rebuild S/R on the CURRENT chart timeframe first, then re-plan; this also frees the panel for a new grid
      BuildSR(); gSRBar = iTime(_Symbol, EffTF(), 0);
      gGHidden = false;
      PlanGrid(); ClearPreview(); UpdatePreview();
      SetMsg(StringFormat("S/R rebuilt on %s: %d levels", EnumToString(EffTF()), gSRn));
      UpdateUI(); return;
   }
}

// applies a dragged price to the right state variable (with side/min-distance clamping); lots, risk and R:R follow
void HandleDrag(string name, double pr)
{
   double pt = _Point, ms = MinStop() + 2 * pt;
   pr = NP(pr);
   if(gTab == 1)
   {
      double e = gBuy ? Ask() : Bid();
      if(name == V + "SL")
      {
         pr = gBuy ? MathMin(pr, NP(e - ms)) : MathMax(pr, NP(e + ms));
         lvSL = pr; lvSLd = true; gSlPts = BasePts(MathAbs(e - pr)); SetEdit("sl", IntegerToString(gSlPts));
      }
      else if(name == V + "TP")
      {
         pr = gBuy ? MathMax(pr, NP(e + ms)) : MathMin(pr, NP(e - ms));
         lvTP = pr; lvTPd = true; gTpPts = TpPtsOf(MathAbs(pr - e)); SetEdit("tp", IntegerToString(gTpPts));
      }
   }
   else if(gTab == 3)
   {
      if(name == V + "ENTRY")
      {
         double d = pr - pdE; pdE = pr; pdSL = NP(pdSL + d); pdTP = NP(pdTP + d);   // SL / TP travel with the entry
      }
      else if(name == V + "SL") { pr = gBuy ? MathMin(pr, NP(pdE - pt)) : MathMax(pr, NP(pdE + pt)); pdSL = pr; }
      else if(name == V + "TP") { pr = gBuy ? MathMax(pr, NP(pdE + pt)) : MathMin(pr, NP(pdE - pt)); pdTP = pr; }
      gSlPts = BasePts(MathAbs(pdE - pdSL)); gTpPts = TpPtsOf(MathAbs(pdTP - pdE));
      SetEdit("sl", IntegerToString(gSlPts)); SetEdit("tp", IntegerToString(gTpPts));
   }
   else if(gTab == 2)
   {
      gGEdited = true;      // hand-placed levels are not overwritten by the 1-minute refresh (only by the Re-suggest button)
      if(name == V + "GSL")
      {
         double ext = gGPx[0];
         for(int k = 1; k < gGCnt; k++) ext = gBuy ? MathMin(ext, gGPx[k]) : MathMax(ext, gGPx[k]);
         gGSL = gBuy ? MathMin(pr, NP(ext - pt)) : MathMax(pr, NP(ext + pt));          // always beyond the last grid order
      }
      else if(name == V + "GTP")
      {
         pr = gBuy ? MathMax(pr, NP(gGPx[0] + ms)) : MathMin(pr, NP(gGPx[0] - ms));
         gGTP = pr; gGTP1 = TpPtsOf(MathAbs(pr - gGPx[0])); gGTP1Auto = false;
         SetEdit("gridtp1", DoubleToString(Pips(gGTP1), 1)); SetToggle(P + "C_tp1a", "Auto TP1 (S/R) - pips", false);
      }
      else
         for(int k = 1; k < 8; k++)
            if(name == V + "G" + IntegerToString(k))
            {
               pr = gBuy ? MathMin(pr, NP(gGPx[0] - ms)) : MathMax(pr, NP(gGPx[0] + ms));
               pr = gBuy ? MathMax(pr, NP(gGSL + pt)) : MathMin(pr, NP(gGSL - pt));
               gGPx[k] = pr;
            }
   }
   UpdatePreview(); UpdateUI(); ChartRedraw();
}

// names of the preview lines that can be dragged on the current tab
int DragNames(string &nm[])
{
   ArrayResize(nm, 0); int n = 0;
   if(gTab == 1)
   {
      if(gSlOn) { ArrayResize(nm, n + 1); nm[n++] = V + "SL"; }
      if(gTpOn) { ArrayResize(nm, n + 1); nm[n++] = V + "TP"; }
   }
   else if(gTab == 3 && !gHidePrev)
   {
      ArrayResize(nm, 3); nm[0] = V + "ENTRY"; nm[1] = V + "SL"; nm[2] = V + "TP"; n = 3;
      if(!gSlOn) nm[1] = ""; if(!gTpOn) nm[2] = "";
   }
   else if(gTab == 2 && !gGHidden && !GridBlocked())
   {
      ArrayResize(nm, 2); nm[0] = V + "GSL"; nm[1] = V + "GTP"; n = 2;
      for(int k = 1; k < gGCnt; k++) { ArrayResize(nm, n + 1); nm[n++] = V + "G" + IntegerToString(k); }
   }
   return n;
}

// the draggable line closest to the mouse (within a few pixels), or ""
string PickLine(int mx, int my)
{
   string nm[]; int n = DragNames(nm);
   datetime t = iTime(_Symbol, _Period, 0);
   string best = ""; int bd = 7;
   for(int i = 0; i < n; i++)
   {
      if(nm[i] == "" || ObjectFind(0, nm[i]) < 0) continue;
      int x, y;
      if(!ChartTimePriceToXY(0, 0, t, ObjectGetDouble(0, nm[i], OBJPROP_PRICE), x, y)) continue;
      int d = MathAbs(y - my);
      if(HitObj(HdlOf(TxtOf(nm[i])), mx, my)) d = 0;       // the handle itself always grabs its line
      if(d < bd) { bd = d; best = nm[i]; }
   }
   return best;
}

void MoveDragLine(int mx, int my)
{
   int sub = 0; datetime t; double pr;
   if(!ChartXYToTimePrice(0, mx, my, sub, t, pr)) return;
   HandleDrag(gDragLn, pr);
}

void EndDragLine()
{
   gDragLn = "";
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   UpdatePreview(); UpdateUI(); ChartRedraw();
}

bool HitObj(string n, int x, int y)
{
   if(ObjectFind(0, n) < 0) return false;
   int ox = (int)ObjectGetInteger(0, n, OBJPROP_XDISTANCE), oy = (int)ObjectGetInteger(0, n, OBJPROP_YDISTANCE);
   int w = (int)ObjectGetInteger(0, n, OBJPROP_XSIZE), h = (int)ObjectGetInteger(0, n, OBJPROP_YSIZE);
   return (x >= ox && x <= ox + w && y >= oy && y <= oy + h);
}

// a physical click can reach us twice (object click + chart click): act only once per button
bool IsTradeBtn(string name)
{
   string k = StringSubstr(name, StringLen(P));
   return (k == "B_buyNow" || k == "B_sellNow" || k == "B_placep" || k == "B_cancelp" || k == "B_gplace" || k == "B_gcancel" ||
           k == "B_gext" || StringFind(k, "B_close") == 0);
}
void ClickOnce(string name)
{
   uint now = GetTickCount();
   uint win = IsTradeBtn(name) ? 1500 : 200;
   if(name == gLastClk && now - gLastClkT < win) return;
   gLastClk = name; gLastClkT = now;
   gMsg = "";                       // any button click clears the current note (the action may set a new one)
   HandleClick(name);
   gLastClkT = GetTickCount();     // the window runs from the END of the action: a slow trade call no longer lets the duplicate event through
   if(ObjectFind(0, name) >= 0) ObjectSetInteger(0, name, OBJPROP_STATE, false);
   ChartRedraw();
}

// button of the panel under the cursor (fallback when a chart line swallowed the click)
string FindPanelHit(int x, int y)
{
   int tot = ObjectsTotal(0, 0, OBJ_BUTTON);
   for(int i = 0; i < tot; i++)
   {
      string n = ObjectName(0, i, 0, OBJ_BUTTON);
      if(StringFind(n, P) != 0) continue;
      if(HitObj(n, x, y)) return n;
   }
   return "";
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      if(StringFind(sparam, P) == 0) ClickOnce(sparam);
   }
   else if(id == CHARTEVENT_CLICK)
   {
      int cx = (int)lparam, cy = (int)dparam;
      if(gMode == 0 && HitObj(P + "BG", cx, cy))
      {
         string hit = FindPanelHit(cx, cy);
         if(hit != "") ClickOnce(hit);
      }
   }
   else if(id == CHARTEVENT_OBJECT_ENDEDIT)
   {
      if(StringFind(sparam, P) == 0) { HandleEdit(sparam); ChartRedraw(); }
   }
   else if(id == CHARTEVENT_OBJECT_DRAG)
   {
      if(StringFind(sparam, V) == 0) HandleDrag(sparam, ObjectGetDouble(0, sparam, OBJPROP_PRICE));
   }
   else if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int x = (int)lparam, y = (int)dparam;
      bool down = (((int)StringToInteger(sparam)) & 1) != 0;
      bool pressed = down && !gPrevDown; gPrevDown = down;
      if(gDragLn != "")
      {
         if(down) { MoveDragLine(x, y); return; }
         EndDragLine();
      }
      else if(pressed && gMode == 0 && !HitObj(P + "BG", x, y))
      {
         string ln = PickLine(x, y);
         if(ln != "") { gDragLn = ln; ChartSetInteger(0, CHART_MOUSE_SCROLL, false); return; }
      }
      if(down && gMode == 0)
      {
         int m = 0;
         if(HitObj(P + "HDR", x, y)) m = 1; else if(HitObj(P + "GRIP", x, y)) m = 2;
         if(m != 0)
         {
            gMode = m; gMx0 = x; gMy0 = y; gPx0 = gPx; gPy0 = gPy; gPw0 = gPw; gPh0 = gPh;
            ChartSetInteger(0, CHART_MOUSE_SCROLL, false);
         }
      }
      else if(down && gMode != 0)
      {
         if(gMode == 1)
         {
            int nx = MathMax(0, gPx0 + x - gMx0), ny = MathMax(0, gPy0 + y - gMy0);
            ShiftPanel(nx - gPx, ny - gPy); gPx = nx; gPy = ny;
            ChartRedraw();
         }
         else if(GetTickCount() - gLastRB > 60)
         {
            double sc = gScale / 100.0;
            gPw = (int)MathMax(100, (gPw0 * sc + x - gMx0) / sc); gPh = (int)MathMax(100, (gPh0 * sc + y - gMy0) / sc);
            gLastRB = GetTickCount(); BuildPanel();
         }
      }
      else if(!down && gMode != 0)
      {
         gMode = 0; ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
         SaveCfg(); BuildPanel();
      }
   }
}

//+------------------------------------------------------------------+
//| lifecycle                                                        |
//+------------------------------------------------------------------+
int OnInit()
{
   gDailyDD = GVI("dd", InpDailyDDPct);      gBuf   = GVI("buf", InpBufferPct);
   gMaxDD   = GVI("maxdd", InpMaxDDPct);     gStartOv = GVI("startov", InpStartBalance);
   gScale   = (int)GVI("scale", InpScale);   gFont  = (int)GVI("font", InpFont);
   gDark    = (GVI("dark", InpTheme == THEME_DARK ? 1 : 0) > 0.5);
   gPx = (int)GVI("x", InpPanelX); gPy = (int)GVI("y", InpPanelY);
   gPw = (int)GVI("w", InpPanelW); gPh = (int)GVI("h", InpPanelH);
   gLock = (int)GVG("lock", 0); gLockDay = (datetime)(long)GVG("lockday", 0);

   gMagic = InpMagic; gLot = InpLot; gRisk = InpRiskPct; gAuto = InpAutoLot;
   gSlPts = InpSLPts; gTpPts = InpTPPts; gMinDist = InpMinPendDist;
   gGRisk = (InpGridRiskPct > 0) ? InpGridRiskPct : gDailyDD / 2.0;
   gGN = MathMax(2, MathMin(8, InpGridOrders)); gGInc = InpGridLotIncPct; gGTP1 = InpGridTP1Pts;
   gGTPVal = InpGridTPValue; gGTPMoney = InpGridTPMoney; gGMin = InpGridMinPts; gGDistPct = InpGridDistIncPct;
   gGTP1Auto = (GVI("tp1auto", InpGridTP1Auto ? 1 : 0) > 0.5);
   gBEOn = (GVI("beon", InpGridBEOn ? 1 : 0) > 0.5); gBEBuf = GVI("bebuf", InpGridBEBufPips); gBETrig = GVI("betrig", InpGridBETrigPips);
   gSRMode = (int)GVI("srmode", (double)InpSRMode);
   gPendType = (int)GVI("ptype", (double)InpPendType);
   gGInitTP = (GVI("gitp", InpGridInitTP ? 1 : 0) > 0.5);
   gMin = (GVG("pmin", 0) > 0.5);                     // minimized state is remembered (it is not an input)
   gMgrDelay = (GVI("mgd", InpMgrDelay ? 1 : 0) > 0.5);
   gGMoveTP  = (GVI("gmtp", InpGridMoveTP ? 1 : 0) > 0.5);
   gPassPct = GVI("pass", InpPassPct);
   gTester  = (bool)MQLInfoInteger(MQL_TESTER);
   gVisual  = (bool)MQLInfoInteger(MQL_VISUAL_MODE);
   gGui     = (!gTester || gVisual);                    // no panel / chart work in a non-visual test (much faster)
   gTestAuto = (gTester && InpTestAutoTrade);
   if(gTestAuto) gPassPct = 0;                          // an automatic back-test must not stop at the challenge target
   gDayMax  = GVI("dmax", InpDayMaxProfit);   gDayMaxM = (GVI("dmaxm", InpDayMaxMoney ? 1 : 0) > 0.5);
   gBkOn    = (GVI("bkon", InpBasketOn ? 1 : 0) > 0.5);
   gBkVal   = GVI("bkv", InpBasketVal);       gBkM = (GVI("bkm", InpBasketMoney ? 1 : 0) > 0.5);
   gTrailOn = (GVI("trail", InpBasketTrail ? 1 : 0) > 0.5);
   gTrVal   = GVI("trv", InpTrailVal);        gTrM = (GVI("trm", InpTrailMoney ? 1 : 0) > 0.5);
   gBkArmed = (GVG("bkarm", 0) > 0.5);        gBkPeak = GVG("bkpeak", 0);

   trade.SetDeviationInPoints(InpDeviation);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetAsyncMode(false);

   Print(APP_NAME, " v", APP_VER, " started - day starts ", InpDayMode == DAY_NY_CLOSE ? StringFormat("%02d:00 New York", InpRolloverNYHour) : "at server midnight");
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_SHOW_TRADE_LEVELS, InpTradeLevels);     // trade levels on,
   ChartSetInteger(0, CHART_SHOW_TRADE_HISTORY, InpTradeHistory);   // trade history off (defaults)
   SetTheme();
   gChartTheme = InpChartTheme;
   if(gChartTheme && gGui) { SaveChartOrig(); ApplyChartTheme(); }
   RefreshHistory();
   BuildSR();
   gSRBar = iTime(_Symbol, EffTF(), 0);
   UpdateStats();
   if(gGui) { BuildPanel(); EnterTab(); }
   SetTimerRate();
   if(gTester) Print("PFP tester: ", gTestAuto ? "automatic trading ON" : "automatic trading OFF (manual panel)", gVisual ? ", visual mode" : "");
   return INIT_SUCCEEDED;
}

// removes EVERY object of the panel and of the previews (also anything a prefix delete could miss) and repaints the chart
void RemoveAllObjects()
{
   ObjectsDeleteAll(0, P);
   ObjectsDeleteAll(0, V);
   for(int i = ObjectsTotal(0, -1, -1) - 1; i >= 0; i--)
   {
      string n = ObjectName(0, i, -1, -1);
      if(StringFind(n, P) == 0 || StringFind(n, V) == 0) ObjectDelete(0, n);
   }
   ChartRedraw();
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   SaveCfg(); SaveBk();
   ChartSetInteger(0, CHART_MOUSE_SCROLL, true);
   RemoveAllObjects();                                  // panel + preview lines + handles, then repaint
   if(reason == REASON_REMOVE) RestoreChartOrig();      // give the chart its own colours back
   ChartRedraw();
}

void OnTick()
{
   ENUM_TIMEFRAMES tf = EffTF();
   datetime bt = iTime(_Symbol, tf, 0);
   if(bt != gSRBar || tf != gSRTf)
   {
      gSRBar = bt; BuildSR();
      if(gTab == 1) SuggestLive();
      if(gTab == 3) SuggestPending();
   }
   CheckLimits();
   CheckGoals();
   ManageGrids();
   if(gTestAuto) TesterAuto();
   if(!gGui) return;
   if(gMode == 0) { UpdatePreview(); UpdateUI(); }
   ChartRedraw();
}

void OnTimer()
{
   static uint lastSlow = 0;
   bool slow = (!gMgrDelay || gTester || GetTickCount() - lastSlow >= 900);
   if(slow) { lastSlow = GetTickCount(); RefreshHistory(); }
   if(gXArmed && GetTickCount() - gXTime > 15000) { gXArmed = false; ClearExtPreview(); SetMsg("Extend plan expired - click EXTEND GRID again"); }
   // S/R: follow the current timeframe, and retry while the history of a freshly switched timeframe is still loading
   ENUM_TIMEFRAMES tf = EffTF();
   bool tfChanged = (tf != gSRTf);
   if(tfChanged || (gSRn == 0 && GetTickCount() - gSRTry > 5000))
   {
      int before = gSRn;
      gSRTry = GetTickCount(); BuildSR(); gSRBar = iTime(_Symbol, tf, 0);
      if(gTab == 2 && !gGHidden && (tfChanged || (before == 0 && gSRn > 0))) { PlanGrid(); ClearPreview(); }
   }
   CheckLimits();
   CheckGoals();
   SaveBk();
   ManageGrids();
   if(!gGui || !slow) return;
   if(gTab == 1) SuggestLive();
   if(gTab == 3) SuggestPending();
   if(gTab == 2 && !GridBlocked() && !gGEdited && gDragLn == "" && GetTickCount() - gGRefT >= 60000)
   { BuildSR(); gSRBar = iTime(_Symbol, EffTF(), 0); PlanGrid(); ClearPreview(); }   // grid levels follow the market every minute
   if(gMode == 0) { UpdatePreview(); UpdateUI(); }
   ChartRedraw();
}
//+------------------------------------------------------------------+
