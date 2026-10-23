//+------------------------------------------------------------------+
//|                                            SessionRangeDesk.mq5  |
//|   Session Range Desk MT5  —  v4.01                               |
//|                                                                  |
//|   [[EA-Daily-Range]] v3.00 cekirdegi + cok-kopya koordinasyonu.  |
//|   Ayni EA 3-4 grafige kurulur; kopyalar terminal global          |
//|   degiskenleri uzerinden birbirini gorur, girdi setlerini ve     |
//|   gunluk risk taahhudunu paylasir, ortak bir gunluk risk         |
//|   tavanini birlikte uygular. Panel her grafikte butun sepeti     |
//|   gosterir.                                                      |
//+------------------------------------------------------------------+
#property copyright "Erdem Kaynak"
#property link      "https://www.mql5.com/en/users/"
#property version   "4.01"
#property description "Session range breakout. One trade per symbol per day, always a visible stop,"
#property description "forced flat at a fixed time. Run one copy per chart - the copies see each"
#property description "other and share a single daily risk ceiling."
#property description "No grid. No martingale. No hidden averaging."

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Canvas\Canvas.mqh>

//+------------------------------------------------------------------+
//|  ENUM                                                            |
//+------------------------------------------------------------------+
enum ENUM_BREAKOUT_MODE {
   BREAKOUT_TOUCH,   // Touch
   BREAKOUT_CLOSE    // Bar close
};

enum ENUM_PANEL_CORNER {
   PC_LEFT_UPPER,    // Top left
   PC_RIGHT_UPPER,   // Top right
   PC_LEFT_LOWER,    // Bottom left
   PC_RIGHT_LOWER    // Bottom right
};

//--- Durum kodlari (bus uzerinden paylasilir, panelde merdiven olur)
#define ST_WAIT      0   // Range penceresi beklenirken
#define ST_RANGE     1   // Range kuruldu, kirilim bekleniyor
#define ST_TRADE     2   // Pozisyon acik
#define ST_BE        3   // Break-even alindi
#define ST_PARTIAL   4   // Parsiyel alindi
#define ST_FLAT      5   // Gun bitti / pozisyon kapandi
#define ST_SKIP      6   // Bugun islem yok (filtre, min lot, butce)
#define ST_OFFLINE   9   // Kopya yayin yapmiyor

//+------------------------------------------------------------------+
//|  INPUTS                                                          |
//+------------------------------------------------------------------+
input group "=== SESSION ==="
input int     StartHour        = 1;      // Range window start - hour (server)
input int     StartMinute      = 15;     // Range window start - minute
input int     EndHour          = 23;     // Force flat - hour (server)
input int     EndMinute        = 0;      // Force flat - minute
input int     LookbackCandles  = 8;      // Bars used to build the range

input group "=== STRATEGY ==="
input ENUM_BREAKOUT_MODE BreakoutMode = BREAKOUT_CLOSE; // Breakout confirmation

input group "=== RANGE FILTER (ATR) ==="
input ENUM_TIMEFRAMES ATR_TF   = PERIOD_D1;   // ATR timeframe
input int     ATR_Period       = 14;          // ATR period
input double  Min_ATR_Mult     = 0.10;        // Reject range narrower than ATR x this
input double  Max_ATR_Mult     = 0.40;        // Reject range wider than ATR x this

input group "=== RISK ==="
input double  RiskPercent      = 0.5;    // Risk per trade, % of balance
input double  MaxDailyRiskPct  = 2.0;    // DESK-WIDE daily risk ceiling, % of balance
input bool    SkipOnMinLot     = true;   // Skip if minimum lot exceeds target risk
input double  MinLotTolerance  = 15.0;   // Allowed overshoot before skipping, %

input group "=== TAKE PROFIT ==="
input bool    UseTP            = true;   // Use a fixed take profit
input double  TP_R             = 2.0;    // Take profit, in R

input group "=== BREAK EVEN ==="
input bool    UseBreakEven     = true;   // Move stop to break even
input double  BE_Trigger_R     = 1.0;    // Trigger, in R
input double  BE_Target_R      = 0.0;    // New stop, in R from entry

input group "=== PARTIAL TAKE PROFIT ==="
input bool    UsePartialTP     = true;   // Close part of the position
input double  PTP_Trigger_R    = 2.0;    // Trigger, in R
input double  PTP_Percent      = 50.0;   // Portion to close, %

input group "=== DESK ==="
input ulong   MagicNumber      = 240900; // Magic - MUST match on every chart
input string  DeskName         = "DESK"; // Desk id - MUST match on every chart

input group "=== PANEL ==="
input bool    ShowPanel        = true;   // Draw the desk panel
input ENUM_PANEL_CORNER PanelCorner = PC_LEFT_UPPER; // Panel corner
input int     PanelX           = 16;     // Panel offset X
input int     PanelY           = 42;     // Panel offset Y
input bool    ShowChartLevels  = true;   // Draw range box and trade levels

//+------------------------------------------------------------------+
//|  PALETTE  (Urun-Ayrisma-Raporu karari)                           |
//+------------------------------------------------------------------+
#define C_GROUND   C'22,26,32'      // #161A20
#define C_HEAD     C'32,38,47'      // #20262F
#define C_EDGE     C'58,66,78'      // #3A424E
#define C_EDGEOUT  C'13,16,21'      // dis kenarlik
#define C_INK      C'196,203,212'   // #C4CBD4
#define C_INKHI    C'228,233,238'
#define C_DIM      C'122,131,143'   // #7A838F
#define C_GOOD     C'80,190,120'    // #50BE78
#define C_WARN     C'226,178,64'    // #E2B240
#define C_BAD      C'224,86,74'     // #E0564A
#define C_ACC      C'88,155,224'    // #589BE0
#define C_TRACK    C'36,43,52'

//--- Panel olculeri
#define P_W        480
#define P_H        392
#define P_PAD      12
#define P_ROWH     34

#define F_UI       "Segoe UI"
#define F_MONO     "Consolas"

//--- Grafik nesne oneki
#define PFX        "SRD_"

//+------------------------------------------------------------------+
//|  GLOBAL STATE                                                    |
//+------------------------------------------------------------------+
CTrade         trade;
CSymbolInfo    sym;
CCanvas        cv;

bool   isRangeActive    = false;
bool   rangeSetToday    = false;
bool   tradeOpenedToday = false;
bool   ptpDone          = false;
bool   eodDone          = false;
bool   beTriggered      = false;
bool   badParams        = false;
bool   visualMode       = false;
bool   panelReady       = false;
bool   testerMode       = false;
bool   chartLevelsMode  = false;
bool   historyDirty     = true;
double cachedRealized   = 0.0;
ulong  lastRenderMs     = 0;

double rangeHigh        = 0.0;
double rangeLow         = 0.0;
double slDist           = 0.0;
double entryPx          = 0.0;
double lastATR          = 0.0;
double dayBalStart      = 0.0;

double myCommitted      = 0.0;   // bugun bu sembolde riske atilmis $
double myPnlToday       = 0.0;   // bugun bu sembolde realize + floating
double myLot            = 0.0;
double myR              = -99.0;

int    curDay           = -1;
int    myState          = ST_WAIT;
string skipReason       = "";

int    atrH             = INVALID_HANDLE;
string busPfx           = "";
string panelObj         = "";

//--- gun ici equity egrisi (dakika basina bir ornek)
double eqCurve[1440];
int    eqCount          = 0;
double eqDayStart       = 0.0;

//--- panel konumu (surukleme ile degisir)
int    panX             = 0;
int    panY             = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//|   ONINIT / ONDEINIT                                              |
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   bool isOpt = (bool)MQLInfoInteger(MQL_OPTIMIZATION);
   bool isTst = (bool)MQLInfoInteger(MQL_TESTER);
   bool isVis = (bool)MQLInfoInteger(MQL_VISUAL_MODE);
   testerMode = isTst;
   bool graphicsAllowed = !isOpt && (!isTst || isVis);
   visualMode = ShowPanel && graphicsAllowed;
   chartLevelsMode = ShowChartLevels && graphicsAllowed;

   Print("==============================================================");
   Print("LOG [Init] Session Range Desk v4.01 - ", _Symbol);

   if(Max_ATR_Mult <= Min_ATR_Mult) {
      badParams = true;
      Print("HATA [Init] Max_ATR_Mult, Min_ATR_Mult'ten buyuk olmali. EA calismayacak.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(RiskPercent <= 0.0 || MaxDailyRiskPct <= 0.0) {
      badParams = true;
      Print("HATA [Init] Risk degerleri sifir veya negatif olamaz. EA calismayacak.");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(RiskPercent > MaxDailyRiskPct)
      PrintFormat("UYARI [Init] Islem riski (%%%.2f) masa tavanindan (%%%.2f) buyuk. "
                  "Ilk islem tavani tek basina doldurur.", RiskPercent, MaxDailyRiskPct);

   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetAsyncMode(false);
   if(!sym.Name(_Symbol)) { Print("HATA [Init] Sembol bilgisi alinamadi."); return INIT_FAILED; }

   atrH = iATR(_Symbol, ATR_TF, ATR_Period);
   if(atrH == INVALID_HANDLE) { Print("HATA [Init] ATR gostergesi yuklenemedi."); return INIT_FAILED; }

   busPfx      = StringFormat("SRD_%s_%I64u_", DeskName, MagicNumber);
   panelObj    = PFX + "panel_" + _Symbol;
   dayBalStart = AccountInfoDouble(ACCOUNT_BALANCE);
   eqDayStart  = AccountInfoDouble(ACCOUNT_EQUITY);

   MqlDateTime dt; TimeCurrent(dt);
   curDay = dt.day;

   //--- Restart sonrasi: acik pozisyondan state'i geri kur, gun icini yeniden hesapla
   RestoreStateFromPosition();
   RecomputeTodayFromHistory();

   panX = PanelX;
   panY = PanelY;
   RestorePanelPos();

   if(visualMode) BuildPanel();
   if(chartLevelsMode) DrawDayLines();

   BusPublish();

   PrintFormat("LOG [Init] Masa: %s | Magic: %I64u | Bakiye: %.2f | Islem riski: %%%.2f | Masa tavani: %%%.2f",
               DeskName, MagicNumber, dayBalStart, RiskPercent, MaxDailyRiskPct);
   PrintFormat("LOG [Init] Masada gorunen kopyalar: %s", BusRoster());
   Print("==============================================================");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(atrH != INVALID_HANDLE) IndicatorRelease(atrH);
   BusClearMine();
   if(panelReady) { cv.Destroy(); panelReady = false; }
   if(visualMode || chartLevelsMode) {
      ObjectsDeleteAll(0, PFX);
      ChartRedraw();
   }
   Print("LOG [Deinit] EA durduruldu. Sebep: ", reason);
}

//+------------------------------------------------------------------+
//|                                                                  |
//|   ONTICK                                                         |
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
{
   if(badParams) return;

   MqlDateTime dt;
   TimeCurrent(dt);

   //--- Yeni gun
   if(dt.day != curDay) {
      curDay           = dt.day;
      isRangeActive    = false;
      rangeSetToday    = false;
      tradeOpenedToday = false;
      ptpDone          = false;
      eodDone          = false;
      beTriggered      = false;
      slDist           = 0.0;
      entryPx          = 0.0;
      rangeHigh        = 0.0;
      rangeLow         = 0.0;
      myCommitted      = 0.0;
      myPnlToday       = 0.0;
      myLot            = 0.0;
      myR              = -99.0;
      myState          = ST_WAIT;
      skipReason       = "";
      dayBalStart      = AccountInfoDouble(ACCOUNT_BALANCE);
      eqDayStart       = AccountInfoDouble(ACCOUNT_EQUITY);
      eqCount          = 0;
      ArrayInitialize(eqCurve, 0.0);
      historyDirty     = true;
      cachedRealized   = 0.0;

      PrintFormat("LOG [Yeni Gun] Baslangic bakiyesi: %.2f", dayBalStart);
      if(chartLevelsMode) { DelRangeObjs(); DelTradeLines(); DrawDayLines(); }
   }

   int nowMin   = dt.hour * 60 + dt.min;
   int startMin = StartHour * 60 + StartMinute;
   int endMin   = EndHour   * 60 + EndMinute;

   //--- 1. Gun sonu zorla kapanis
   if(nowMin >= endMin && !eodDone) {
      ulong tk = FindTicket();
      if(tk > 0) {
         Print("LOG [EOD] Gun sonu saati geldi, pozisyon kapatiliyor.");
         trade.PositionClose(tk);
      }
      isRangeActive = false;
      eodDone       = true;
      myState       = ST_FLAT;
      if(chartLevelsMode) { DelRangeObjs(); DelTradeLines(); }
   }

   //--- 2. Range kurulumu
   if(nowMin >= startMin && nowMin < endMin && !rangeSetToday && !tradeOpenedToday && !eodDone)
      SetRange();

   //--- 3. Kirilim
   if(isRangeActive && !tradeOpenedToday) CheckBreakout();

   //--- 4. Pozisyon yonetimi
   ulong tk2 = FindTicket();
   if(tk2 > 0) {
      ManagePos(tk2);
   } else if(tradeOpenedToday && myState != ST_FLAT && myState != ST_SKIP) {
      Print("LOG [Sonuc] Islem kapandi.");
      myState = ST_FLAT;
      myR     = -99.0;
      myLot   = 0.0;
      if(chartLevelsMode) DelTradeLines();
   }

   //--- 5. Gun ici muhasebe + bus yayini + panel (saniyede bir)
   static datetime lastSec = 0;
   datetime now = TimeCurrent();
   if((!testerMode || visualMode) && now != lastSec) {
      lastSec = now;
      RecomputeTodayFromHistory();
      if(visualMode) SampleEquity(nowMin);
      BusPublish();
   }

   // Simulation time can advance hours per real second. Rendering is wall-clock
   // throttled; trade decisions and position management above are never throttled.
   ulong renderMs = GetTickCount64();
   if((visualMode || chartLevelsMode) && renderMs - lastRenderMs >= 250) {
      lastRenderMs = renderMs;
      if(chartLevelsMode && tk2 > 0) UpdateTradeLines(tk2);
      if(visualMode) UpdatePanel();
   }
}

// History changes on execution, not on every market tick. Keep the presentation
// cache invalid until the next successful history read, including day rollover.
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD ||
      trans.type == TRADE_TRANSACTION_DEAL_UPDATE ||
      trans.type == TRADE_TRANSACTION_DEAL_DELETE)
      historyDirty = true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//|   STRATEJI                                                       |
//|                                                                  |
//+------------------------------------------------------------------+
void SetRange()
{
   int hi = iHighest(_Symbol, _Period, MODE_HIGH, LookbackCandles, 1);
   int lo = iLowest (_Symbol, _Period, MODE_LOW,  LookbackCandles, 1);
   if(hi < 0 || lo < 0) return;

   rangeHigh = iHigh(_Symbol, _Period, hi);
   rangeLow  = iLow (_Symbol, _Period, lo);
   double dist = rangeHigh - rangeLow;
   if(dist <= 0) return;

   double buf[];
   ArraySetAsSeries(buf, true);
   if(CopyBuffer(atrH, 0, 1, 1, buf) <= 0) return;
   lastATR = buf[0];
   if(lastATR <= 0) return;

   double minR = lastATR * Min_ATR_Mult;
   double maxR = lastATR * Max_ATR_Mult;

   if(dist < minR || dist > maxR) {
      rangeSetToday = true;
      isRangeActive = false;
      myState       = ST_SKIP;
      skipReason    = (dist < minR) ? "range too narrow" : "range too wide";
      PrintFormat("LOG [Range Red] Genislik %.5f | ATR araligi %.5f - %.5f | %s",
                  dist, minR, maxR, skipReason);
      if(chartLevelsMode) DelRangeObjs();
      return;
   }

   isRangeActive = true;
   rangeSetToday = true;
   myState       = ST_RANGE;
   skipReason    = "";
   PrintFormat("LOG [Range Onay] High %.5f | Low %.5f | Genislik %.0f puan",
               rangeHigh, rangeLow, dist / _Point);
   if(chartLevelsMode) DrawRangeObjs();
}

//+------------------------------------------------------------------+
void CheckBreakout()
{
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

   if(BreakoutMode == BREAKOUT_TOUCH) {
      if(ask >= rangeHigh)     DoTrade(ORDER_TYPE_BUY,  ask, rangeLow);
      else if(bid <= rangeLow) DoTrade(ORDER_TYPE_SELL, bid, rangeHigh);
   } else {
      if(IsNewBar()) {
         double c = iClose(_Symbol, _Period, 1);
         if(c > rangeHigh)     DoTrade(ORDER_TYPE_BUY,  ask, rangeLow);
         else if(c < rangeLow) DoTrade(ORDER_TYPE_SELL, bid, rangeHigh);
      }
   }
}

//+------------------------------------------------------------------+
//|  DOTRADE - masa tavani ve min lot kontrolu burada                |
//+------------------------------------------------------------------+
void DoTrade(ENUM_ORDER_TYPE type, double px, double slPx)
{
   double d = MathAbs(px - slPx);
   if(d <= 0) return;

   double bal        = AccountInfoDouble(ACCOUNT_BALANCE);
   double targetRisk = bal * RiskPercent / 100.0;

   //--- (a) MASA TAVANI: diger kopyalarin bugun riske attigi + benimki
   double othersRisk = BusCommittedOthers();
   double deskCap    = bal * MaxDailyRiskPct / 100.0;
   if(othersRisk + targetRisk > deskCap + 0.005) {
      rangeSetToday = true;
      isRangeActive = false;
      myState       = ST_SKIP;
      skipReason    = StringFormat("desk cap: %.2f+%.2f > %.2f", othersRisk, targetRisk, deskCap);
      PrintFormat("LOG [Masa Tavani] Islem ACILMADI. Diger kopyalar $%.2f riske atmis, "
                  "benimki $%.2f olacakti, tavan $%.2f (%%%.2f). Sepet: %s",
                  othersRisk, targetRisk, deskCap, MaxDailyRiskPct, BusRoster());
      if(chartLevelsMode) DelRangeObjs();
      return;
   }

   //--- (b) LOT
   double lot     = 0.0;
   double lotRisk = 0.0;
   if(!CalcLot(d, targetRisk, lot, lotRisk)) return;

   //--- (c) MIN LOT: minimum lot hedef riski asiyorsa acma, logla
   double overshoot = (targetRisk > 0) ? (lotRisk / targetRisk - 1.0) * 100.0 : 0.0;
   if(SkipOnMinLot && overshoot > MinLotTolerance) {
      rangeSetToday = true;
      isRangeActive = false;
      myState       = ST_SKIP;
      skipReason    = StringFormat("min lot: %.2f%% risk", lotRisk / bal * 100.0);
      PrintFormat("LOG [Min Lot] Islem ACILMADI. Minimum lot %.2f, tasidigi risk $%.2f (%%%.2f), "
                  "hedef $%.2f (%%%.2f), asim %%%.1f > tolerans %%%.1f.",
                  lot, lotRisk, lotRisk / bal * 100.0, targetRisk, RiskPercent, overshoot, MinLotTolerance);
      if(chartLevelsMode) DelRangeObjs();
      return;
   }

   //--- (d) EMIR
   double tp = 0.0;
   if(UseTP) tp = (type == ORDER_TYPE_BUY) ? px + d * TP_R : px - d * TP_R;

   PrintFormat("LOG [Emir] %s | Lot %.2f | Giris %.5f | SL %.5f (%.0f puan) | Risk $%.2f | "
               "Masa kullanimi $%.2f/$%.2f",
               (type == ORDER_TYPE_BUY) ? "BUY" : "SELL", lot, px, slPx, d / _Point,
               lotRisk, othersRisk + lotRisk, deskCap);

   bool ok = (type == ORDER_TYPE_BUY)
             ? trade.Buy (lot, _Symbol, px, slPx, tp, "SRD-BUY")
             : trade.Sell(lot, _Symbol, px, slPx, tp, "SRD-SELL");

   if(!ok) {
      PrintFormat("HATA [Emir Red] Broker reddetti. Retcode %d - %s",
                  trade.ResultRetcode(), trade.ResultRetcodeDescription());
      return;
   }

   tradeOpenedToday = true;
   isRangeActive    = false;
   entryPx          = px;
   slDist           = d;
   myLot            = lot;
   myCommitted      = lotRisk;
   beTriggered      = false;
   ptpDone          = false;
   myState          = ST_TRADE;
   skipReason       = "";

   BusPublish();

   if(chartLevelsMode) {
      FreezeRangeBox();
      ulong tkNew = FindTicket();
      if(tkNew > 0) DrawTradeLines(tkNew, type, px, slPx, tp);
   }
   Print("LOG [Emir OK] Pozisyon acildi, yonetim basliyor.");
}

//+------------------------------------------------------------------+
//|  CALCLOT - OrderCalcProfit uzerinden, broker verisinden bagimsiz |
//+------------------------------------------------------------------+
bool CalcLot(double d, double targetRisk, double &lotOut, double &riskOut)
{
   lotOut = 0.0; riskOut = 0.0;

   double entry = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double stop  = entry - d;
   double per1  = 0.0;

   if(!OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1.0, entry, stop, per1)) {
      double tv = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      if(ts > 0 && tv > 0) per1 = (d / ts) * tv;
      else {
         Print("HATA [Lot] Risk hesaplanamadi, islem iptal.");
         return false;
      }
   }
   per1 = MathAbs(per1);
   if(per1 <= 0) { Print("HATA [Lot] 1 lot riski sifir cikti."); return false; }

   double mn  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stp = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(stp <= 0) stp = mn;

   double raw = targetRisk / per1;
   double lot = MathFloor(raw / stp) * stp;        // asagi yuvarla: risk asilmasin
   if(lot < mn) lot = mn;                          // ama min lot altina inilemez
   if(lot > mx) lot = mx;
   lot = NormalizeDouble(lot, 2);

   lotOut  = lot;
   riskOut = lot * per1;
   return true;
}

//+------------------------------------------------------------------+
void ManagePos(ulong tk)
{
   if(!PositionSelectByTicket(tk)) return;
   if(slDist <= 0) {
      // State kurtarilamadi: SL'e DOKUNMA, yonetimi sessizce kapat.
      myState = ST_TRADE;
      return;
   }

   double curPx = PositionGetDouble(POSITION_PRICE_CURRENT);
   double sl    = PositionGetDouble(POSITION_SL);
   double tp    = PositionGetDouble(POSITION_TP);
   double vol   = PositionGetDouble(POSITION_VOLUME);
   long   ptype = PositionGetInteger(POSITION_TYPE);

   double pd = (ptype == POSITION_TYPE_BUY) ? (curPx - entryPx) : (entryPx - curPx);
   double R  = pd / slDist;
   myR   = R;
   myLot = vol;

   //--- Parsiyel
   if(UsePartialTP && !ptpDone && R >= PTP_Trigger_R) {
      double stp = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      double mn  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double cvl = vol * (PTP_Percent / 100.0);
      if(stp > 0) cvl = MathFloor(cvl / stp) * stp;
      if(cvl >= mn && (vol - cvl) >= mn) {
         PrintFormat("LOG [Parsiyel] %.2f R'de %.2f lot kapatiliyor.", R, cvl);
         if(trade.PositionClosePartial(tk, cvl)) { ptpDone = true; myState = ST_PARTIAL; }
      } else {
         ptpDone = true;   // bolunemiyor, bir daha deneme
         PrintFormat("LOG [Parsiyel] Hacim bolunemedi (lot %.2f, min %.2f). Atlandi.", vol, mn);
      }
   }

   //--- Break even
   if(UseBreakEven && !beTriggered && R >= BE_Trigger_R) {
      double newSL = (ptype == POSITION_TYPE_BUY)
                     ? entryPx + slDist * BE_Target_R
                     : entryPx - slDist * BE_Target_R;
      newSL = NormalizeDouble(newSL, _Digits);

      bool mod = false;
      if(ptype == POSITION_TYPE_BUY  && (sl == 0 || sl < newSL)) mod = true;
      if(ptype == POSITION_TYPE_SELL && (sl == 0 || sl > newSL)) mod = true;

      if(mod && trade.PositionModify(tk, newSL, tp)) {
         beTriggered = true;
         PrintFormat("LOG [Break Even] %.2f R'de SL %.5f'e cekildi.", R, newSL);
      }
   }

   if(myState != ST_PARTIAL)
      myState = beTriggered ? ST_BE : ST_TRADE;
   if(ptpDone) myState = ST_PARTIAL;

   //--- Taahhut: BE alindiysa riske atilan para artik masada degil
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   if(beTriggered) {
      double lockedR = BE_Target_R;
      myCommitted = (lockedR >= 0) ? 0.0 : MathAbs(lockedR) * bal * RiskPercent / 100.0;
   }
}

//+------------------------------------------------------------------+
ulong FindTicket()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong tk = PositionGetTicket(i);
      if(tk == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == (long)MagicNumber) return tk;
   }
   return 0;
}

//+------------------------------------------------------------------+
bool IsNewBar()
{
   static datetime last = 0;
   datetime cur = iTime(_Symbol, _Period, 0);
   if(cur != last) { last = cur; return true; }
   return false;
}

//+------------------------------------------------------------------+
//|  RESTORE - restart sonrasi acik pozisyondan state'i geri kur     |
//|  ([[Kritik-Bulgular]] bulgu 1: bunu yapmayan EA SL'i siliyordu)  |
//+------------------------------------------------------------------+
void RestoreStateFromPosition()
{
   ulong tk = FindTicket();
   if(tk == 0) return;
   if(!PositionSelectByTicket(tk)) return;

   double open = PositionGetDouble(POSITION_PRICE_OPEN);
   double sl   = PositionGetDouble(POSITION_SL);
   long   ptp  = PositionGetInteger(POSITION_TYPE);

   tradeOpenedToday = true;
   rangeSetToday    = true;
   entryPx          = open;
   myLot            = PositionGetDouble(POSITION_VOLUME);

   if(sl <= 0) {
      slDist  = 0.0;
      myState = ST_TRADE;
      Print("UYARI [Restore] Acik pozisyonun SL'i yok. Yonetim KAPALI - "
            "EA bu pozisyona dokunmayacak. Stop'u elle koy.");
      return;
   }

   double d = (ptp == POSITION_TYPE_BUY) ? (open - sl) : (sl - open);
   if(d <= 0) {
      // SL zaten BE'ye ya da otesine cekilmis: orijinal risk geri hesaplanamaz
      slDist      = 0.0;
      beTriggered = true;
      ptpDone     = true;
      myState     = ST_BE;
      Print("UYARI [Restore] SL zaten girisin otesinde. Orijinal risk bilinmiyor - "
            "BE ve parsiyel kapatildi, SL'e dokunulmuyor.");
      return;
   }

   slDist  = d;
   myState = ST_TRADE;
   PrintFormat("LOG [Restore] Acik pozisyon bulundu. Giris %.5f | SL %.5f | Risk mesafesi %.0f puan. "
               "BE ve parsiyel yeniden kuruldu.", open, sl, d / _Point);
}

//+------------------------------------------------------------------+
//|  Bugunun realize + floating tablosunu islem gecmisinden kur      |
//|  Terminal restart olsa bile masa tavani dogru yerden sayar.      |
//+------------------------------------------------------------------+
void RecomputeTodayFromHistory()
{
   MqlDateTime dt; TimeCurrent(dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime dayStart = StructToTime(dt);

   double realized = cachedRealized;
   double worst    = 0.0;   // gun icinde gerceklesmis en kotu zarar (taahhut tabani)

   if(historyDirty && HistorySelect(dayStart, TimeCurrent())) {
      realized = 0.0;
      int total = HistoryDealsTotal();
      for(int i = 0; i < total; i++) {
         ulong dk = HistoryDealGetTicket(i);
         if(dk == 0) continue;
         if(HistoryDealGetString(dk, DEAL_SYMBOL) != _Symbol) continue;
         if(HistoryDealGetInteger(dk, DEAL_MAGIC) != (long)MagicNumber) continue;
         long entry = HistoryDealGetInteger(dk, DEAL_ENTRY);
         if(entry == DEAL_ENTRY_IN) continue;
         realized += HistoryDealGetDouble(dk, DEAL_PROFIT)
                   + HistoryDealGetDouble(dk, DEAL_SWAP)
                   + HistoryDealGetDouble(dk, DEAL_COMMISSION);
      }
      cachedRealized = realized;
      historyDirty = false;
   }
   if(realized < 0) worst = -realized;

   double floatPnl = 0.0;
   ulong tk = FindTicket();
   if(tk > 0 && PositionSelectByTicket(tk))
      floatPnl = PositionGetDouble(POSITION_PROFIT)
               + PositionGetDouble(POSITION_SWAP);

   myPnlToday = realized + floatPnl;

   //--- Taahhut: acik pozisyon varsa hala riske atilan para, yoksa gerceklesen zarar
   if(tk > 0) {
      if(myCommitted <= 0.0 && slDist > 0.0) {
         // restart sonrasi: acik pozisyonun tasidigi riski yeniden olc
         double per = 0.0;
         double open = PositionGetDouble(POSITION_PRICE_OPEN);
         double sl   = PositionGetDouble(POSITION_SL);
         double vol  = PositionGetDouble(POSITION_VOLUME);
         long   pt   = PositionGetInteger(POSITION_TYPE);
         if(sl > 0 && OrderCalcProfit((ENUM_ORDER_TYPE)pt, _Symbol, vol, open, sl, per))
            myCommitted = MathAbs(per);
      }
   } else {
      myCommitted = worst;
   }
}

//+------------------------------------------------------------------+
void SampleEquity(int nowMin)
{
   if(nowMin < 0 || nowMin >= 1440) return;
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eqDayStart <= 0) eqDayStart = eq;
   eqCurve[nowMin] = eq - eqDayStart;
   if(nowMin + 1 > eqCount) eqCount = nowMin + 1;
}

//+------------------------------------------------------------------+
//|                                                                  |
//|   DESK BUS  -  kopyalar birbirini buradan gorur                  |
//|   Terminal global degiskenleri: SRD_<desk>_<magic>_<SYM>_<alan>  |
//|                                                                  |
//+------------------------------------------------------------------+
void BusSet(string field, double v)
{
   string n = busPfx + _Symbol + "_" + field;
   if(!GlobalVariableCheck(n)) GlobalVariableTemp(n);
   GlobalVariableSet(n, v);
}

//+------------------------------------------------------------------+
void BusPublish()
{
   if((bool)MQLInfoInteger(MQL_OPTIMIZATION)) return;

   double pn = -9.0;
   if(rangeHigh > rangeLow) {
      double px = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      pn = (px - rangeLow) / (rangeHigh - rangeLow);
      if(pn < -0.6) pn = -0.6;
      if(pn >  1.6) pn =  1.6;
   }

   BusSet("hb", (double)TimeCurrent());
   BusSet("st", (double)myState);
   BusSet("pn", pn);
   BusSet("rr", myR);
   BusSet("lt", myLot);
   BusSet("cm", myCommitted);
   BusSet("pl", myPnlToday);
   BusSet("rk", RiskPercent);
   BusSet("dc", MaxDailyRiskPct);
}

//+------------------------------------------------------------------+
void BusClearMine()
{
   string f[] = {"hb","st","pn","rr","lt","cm","pl","rk","dc"};
   for(int i = 0; i < ArraySize(f); i++) {
      string n = busPfx + _Symbol + "_" + f[i];
      if(GlobalVariableCheck(n)) GlobalVariableDel(n);
   }
}

//+------------------------------------------------------------------+
//|  Masadaki sembolleri topla (kendisi dahil), heartbeat'i taze     |
//|  olanlari dondur.                                                |
//+------------------------------------------------------------------+
int BusSymbols(string &out[])
{
   ArrayResize(out, 0);
   int    total = GlobalVariablesTotal();
   int    plen  = StringLen(busPfx);
   datetime now = TimeCurrent();

   for(int i = 0; i < total; i++) {
      string n = GlobalVariableName(i);
      if(StringLen(n) <= plen + 4) continue;
      if(StringSubstr(n, 0, plen) != busPfx) continue;
      if(StringSubstr(n, StringLen(n) - 3) != "_hb") continue;

      string s = StringSubstr(n, plen, StringLen(n) - plen - 3);
      if(s == "") continue;

      datetime hb = (datetime)GlobalVariableGet(n);
      if(now - hb > 180 && s != _Symbol) continue;   // 3 dk sessiz kalan kopya dusuruluyor

      int k = ArraySize(out);
      ArrayResize(out, k + 1);
      out[k] = s;
   }
   //--- kararli sira: sembol adina gore
   int cnt = ArraySize(out);
   for(int a = 0; a < cnt - 1; a++)
      for(int b = a + 1; b < cnt; b++)
         if(StringCompare(out[a], out[b]) > 0) {
            string t = out[a]; out[a] = out[b]; out[b] = t;
         }
   return cnt;
}

//+------------------------------------------------------------------+
double BusGet(string s, string field, double def)
{
   string n = busPfx + s + "_" + field;
   if(!GlobalVariableCheck(n)) return def;
   return GlobalVariableGet(n);
}

//+------------------------------------------------------------------+
//|  Bu sembol disindaki kopyalarin bugun riske attigi toplam $      |
//+------------------------------------------------------------------+
double BusCommittedOthers()
{
   string s[];
   int n = BusSymbols(s);
   double sum = 0.0;
   for(int i = 0; i < n; i++) {
      if(s[i] == _Symbol) continue;
      sum += MathMax(0.0, BusGet(s[i], "cm", 0.0));
   }
   return sum;
}

//+------------------------------------------------------------------+
double BusCommittedAll()
{
   string s[];
   int n = BusSymbols(s);
   double sum = 0.0;
   for(int i = 0; i < n; i++) sum += MathMax(0.0, BusGet(s[i], "cm", 0.0));
   return sum;
}

//+------------------------------------------------------------------+
string BusRoster()
{
   string s[];
   int n = BusSymbols(s);
   if(n == 0) return "(yok)";
   string r = "";
   for(int i = 0; i < n; i++) {
      if(i > 0) r += ", ";
      r += s[i] + StringFormat("(%%%.2f)", BusGet(s[i], "rk", 0.0));
   }
   return r;
}

//##################################################################//
//                                                                  //
//   PANEL  -  CCanvas                                              //
//   visualMode=false iken hicbiri cagrilmaz.                       //
//                                                                  //
//##################################################################//

void RestorePanelPos()
{
   string nx = busPfx + _Symbol + "_px";
   string ny = busPfx + _Symbol + "_py";
   if(GlobalVariableCheck(nx)) panX = (int)GlobalVariableGet(nx);
   if(GlobalVariableCheck(ny)) panY = (int)GlobalVariableGet(ny);
}

//+------------------------------------------------------------------+
void SavePanelPos()
{
   string nx = busPfx + _Symbol + "_px";
   string ny = busPfx + _Symbol + "_py";
   if(!GlobalVariableCheck(nx)) GlobalVariableTemp(nx);
   if(!GlobalVariableCheck(ny)) GlobalVariableTemp(ny);
   GlobalVariableSet(nx, panX);
   GlobalVariableSet(ny, panY);
}

//+------------------------------------------------------------------+
ENUM_BASE_CORNER PanelCornerEnum()
{
   switch(PanelCorner) {
      case PC_RIGHT_UPPER: return CORNER_RIGHT_UPPER;
      case PC_LEFT_LOWER:  return CORNER_LEFT_LOWER;
      case PC_RIGHT_LOWER: return CORNER_RIGHT_LOWER;
   }
   return CORNER_LEFT_UPPER;
}

//+------------------------------------------------------------------+
void BuildPanel()
{
   if(panelReady) return;
   if(!cv.CreateBitmapLabel(0, 0, panelObj, panX, panY, P_W, P_H, COLOR_FORMAT_ARGB_NORMALIZE)) {
      Print("HATA [Panel] Canvas olusturulamadi: ", GetLastError());
      return;
   }
   ObjectSetInteger(0, panelObj, OBJPROP_CORNER,     PanelCornerEnum());
   ObjectSetInteger(0, panelObj, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, panelObj, OBJPROP_SELECTED,   false);
   ObjectSetInteger(0, panelObj, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, panelObj, OBJPROP_ZORDER,     100);
   panelReady = true;
   UpdatePanel();
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_OBJECT_DRAG && sparam == panelObj) {
      panX = (int)ObjectGetInteger(0, panelObj, OBJPROP_XDISTANCE);
      panY = (int)ObjectGetInteger(0, panelObj, OBJPROP_YDISTANCE);
      SavePanelPos();
   }
   if(id == CHARTEVENT_CHART_CHANGE && visualMode) UpdatePanel();
}

//+------------------------------------------------------------------+
//|  Yardimcilar                                                     |
//+------------------------------------------------------------------+
void PBox(int x1, int y1, int x2, int y2, uint fill)
{
   cv.FillRectangle(x1, y1, x2, y2, ColorToARGB(fill, 255));
}

void PHair(int y, uint clr)
{
   cv.FillRectangle(0, y, P_W - 1, y, ColorToARGB(clr, 255));
}

void PTxt(int x, int y, string t, uint clr, string font, int pt, uint align = TA_LEFT | TA_TOP, uint flags = 0)
{
   cv.FontSet(font, -pt * 10, flags);
   cv.TextOut(x, y, t, ColorToARGB(clr, 255), align);
}

string StateName(int st)
{
   switch(st) {
      case ST_WAIT:    return "WAITING";
      case ST_RANGE:   return "ARMED";
      case ST_TRADE:   return "IN TRADE";
      case ST_BE:      return "BREAK EVEN";
      case ST_PARTIAL: return "PARTIAL";
      case ST_FLAT:    return "FLAT";
      case ST_SKIP:    return "SKIPPED";
   }
   return "OFFLINE";
}

uint StateColor(int st)
{
   switch(st) {
      case ST_RANGE:   return C_WARN;
      case ST_TRADE:   return C_ACC;
      case ST_BE:      return C_ACC;
      case ST_PARTIAL: return C_GOOD;
      case ST_FLAT:    return C_DIM;
      case ST_SKIP:    return C_BAD;
   }
   return C_DIM;
}

string ClockLeft(int targetMin)
{
   MqlDateTime dt; TimeCurrent(dt);
   int now = dt.hour * 60 + dt.min;
   int left = targetMin - now;
   if(left < 0) left += 1440;
   int hh = left / 60, mm = left % 60;
   int ss = 59 - dt.sec;
   if(hh > 0) return StringFormat("%dh %02dm", hh, mm);
   return StringFormat("%02d:%02d", mm, ss);
}

//+------------------------------------------------------------------+
//|  270 derecelik gauge                                             |
//+------------------------------------------------------------------+
void DrawGauge(int cx, int cy, int r, int lw, double frac, uint clr)
{
   double a0 = M_PI * 0.75;
   double a1 = M_PI * 2.25;
   if(frac < 0) frac = 0;
   if(frac > 1) frac = 1;

   for(int i = 0; i < lw; i++)
      cv.Arc(cx, cy, r + i, r + i, a0, a1, ColorToARGB(C_TRACK, 255));

   if(frac > 0.001) {
      double a2 = a0 + (a1 - a0) * frac;
      for(int i = 0; i < lw; i++)
         cv.Arc(cx, cy, r + i, r + i, a0, a2, ColorToARGB(clr, 255));
   }
}

//+------------------------------------------------------------------+
//|  Gun ici equity sparkline                                        |
//+------------------------------------------------------------------+
void DrawSpark(int x1, int y1, int x2, int y2)
{
   PBox(x1, y1, x2, y2, C_TRACK);
   if(eqCount < 2) return;

   double mn = 1e18, mx = -1e18;
   for(int i = 0; i < eqCount; i++) {
      if(eqCurve[i] < mn) mn = eqCurve[i];
      if(eqCurve[i] > mx) mx = eqCurve[i];
   }
   if(mx - mn < 1e-9) { mn -= 1.0; mx += 1.0; }

   int W = x2 - x1;
   int H = y2 - y1;
   int px = -1, py = -1;
   uint line = (eqCurve[eqCount - 1] >= 0) ? C_GOOD : C_BAD;

   //--- sifir cizgisi
   int zy = y2 - (int)((0.0 - mn) / (mx - mn) * H);
   if(zy > y1 && zy < y2) cv.FillRectangle(x1, zy, x2, zy, ColorToARGB(C_EDGE, 255));

   for(int i = 0; i < eqCount; i++) {
      int cxp = x1 + (int)((double)i / (double)(eqCount - 1) * W);
      int cyp = y2 - (int)((eqCurve[i] - mn) / (mx - mn) * H);
      if(px >= 0) cv.LineAA(px, py, cxp, cyp, ColorToARGB(line, 255));
      px = cxp; py = cyp;
   }
   if(px >= 0) cv.FillCircle(px, py, 2, ColorToARGB(line, 255));
}

//+------------------------------------------------------------------+
//|  Satirdaki range konum cubugu                                    |
//+------------------------------------------------------------------+
void DrawRangeBar(int x1, int y, int x2, double pn, int st)
{
   int h = 4;
   int mid = y;
   PBox(x1, mid - h / 2, x2, mid + h / 2, C_TRACK);
   if(pn < -1.0) return;                       // range yok

   int W  = x2 - x1;
   int gx = x1 + (int)(0.28 * W);              // range govdesi: 0.28 .. 0.72
   int gw = (int)(0.44 * W);

   PBox(gx, mid - h / 2, gx + gw, mid + h / 2, C_ACC);
   PBox(gx - 1, mid - 7, gx + 1, mid + 7, C_ACC);
   PBox(gx + gw - 1, mid - 7, gx + gw + 1, mid + 7, C_ACC);

   double t = 0.28 + pn * 0.44;
   if(t < 0.01) t = 0.01;
   if(t > 0.99) t = 0.99;
   int mx = x1 + (int)(t * W);

   uint mc = StateColor(st);
   if(st == ST_WAIT || st == ST_RANGE) mc = (pn > 1.0 || pn < 0.0) ? C_WARN : C_INK;

   //--- kirilimdan sonraki yol
   if(pn > 1.0) PBox(gx + gw, mid - h / 2, mx, mid + h / 2, C_GOOD);
   if(pn < 0.0) PBox(mx, mid - h / 2, gx, mid + h / 2, C_GOOD);

   cv.FillTriangle(mx, mid - 8, mx + 6, mid, mx - 6, mid, ColorToARGB(mc, 255));
   cv.FillTriangle(mx, mid + 8, mx + 6, mid, mx - 6, mid, ColorToARGB(mc, 255));
}

//+------------------------------------------------------------------+
//|  PANELI CIZ                                                      |
//+------------------------------------------------------------------+
void UpdatePanel()
{
   if(!panelReady) return;

   double bal    = AccountInfoDouble(ACCOUNT_BALANCE);
   double deskCap= bal * MaxDailyRiskPct / 100.0;
   double used   = BusCommittedAll();
   double frac   = (deskCap > 0) ? used / deskCap : 0.0;
   double usedPct= (bal > 0) ? used / bal * 100.0 : 0.0;

   string s[];
   int    nsym = BusSymbols(s);

   double deskPnl = 0.0;
   for(int i = 0; i < nsym; i++) deskPnl += BusGet(s[i], "pl", 0.0);

   cv.Erase(ColorToARGB(C_GROUND, 255));

   int y = 0;

   //=== BASLIK =====================================================
   PBox(0, 0, P_W - 1, 29, C_HEAD);
   for(int d = 0; d < 3; d++)
      PBox(P_PAD, 9 + d * 5, P_PAD + 1, 10 + d * 5, C_DIM);
   for(int d2 = 0; d2 < 3; d2++)
      PBox(P_PAD + 5, 9 + d2 * 5, P_PAD + 6, 10 + d2 * 5, C_DIM);

   PTxt(P_PAD + 16, 8, "SESSION RANGE DESK", C_INKHI, F_UI, 9, TA_LEFT | TA_TOP, FW_SEMIBOLD);
   PTxt(P_W - P_PAD, 9, "v4.01", C_DIM, F_MONO, 7, TA_RIGHT | TA_TOP);
   PHair(29, C_EDGE);
   y = 30;

   //=== SUNUCU SERIDI ==============================================
   MqlDateTime dt; TimeCurrent(dt);
   int gmt = (int)MathRound((double)(TimeCurrent() - TimeGMT()) / 3600.0);
   double spr = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);

   uint dotc = (nsym >= 2) ? C_GOOD : C_WARN;
   cv.FillCircle(P_PAD + 3, y + 12, 3, ColorToARGB(dotc, 255));
   PTxt(P_PAD + 13, y + 6,
        StringFormat("Server %02d:%02d  GMT%+d", dt.hour, dt.min, gmt),
        C_INK, F_MONO, 8);
   PTxt(P_W - P_PAD, y + 6,
        StringFormat("%d on desk  ·  spread %.0f", nsym, spr),
        C_DIM, F_MONO, 8, TA_RIGHT | TA_TOP);
   PHair(y + 25, C_EDGE);
   y += 26;

   //=== RISK BUTCESI ===============================================
   int by = y;
   uint gclr = (frac >= 1.0) ? C_BAD : (frac >= 0.7 ? C_WARN : C_GOOD);
   DrawGauge(P_PAD + 36, by + 40, 24, 7, frac, gclr);
   PTxt(P_PAD + 36, by + 33, StringFormat("%.2f%%", usedPct), C_INKHI, F_MONO, 9,
        TA_CENTER | TA_TOP, FW_SEMIBOLD);

   int lx = P_PAD + 84;
   PTxt(lx, by + 8, "DESK DAILY RISK BUDGET", C_DIM, F_UI, 7, TA_LEFT | TA_TOP, FW_SEMIBOLD);
   PTxt(lx, by + 22, StringFormat("$%.2f used  /  $%.2f cap  (%.2f%%)", used, deskCap, MaxDailyRiskPct),
        C_INK, F_MONO, 8);
   DrawSpark(lx, by + 40, P_W - P_PAD - 92, by + 68);
   PTxt(P_W - P_PAD, by + 46,
        StringFormat("%s$%.2f", (deskPnl >= 0 ? "+" : "-"), MathAbs(deskPnl)),
        (deskPnl >= 0 ? C_GOOD : C_BAD), F_MONO, 10, TA_RIGHT | TA_TOP, FW_SEMIBOLD);
   PHair(by + 78, C_EDGE);
   y = by + 79;

   //=== GERI SAYIMLAR ==============================================
   int cy = y;
   int startMin = StartHour * 60 + StartMinute;
   int endMin   = EndHour * 60 + EndMinute;
   int nowMin   = dt.hour * 60 + dt.min;

   string leftLbl, leftVal;
   uint   leftClr = C_INKHI;
   if(!rangeSetToday && nowMin < startMin) { leftLbl = "RANGE LOCKS IN"; leftVal = ClockLeft(startMin); leftClr = C_WARN; }
   else if(isRangeActive)                  { leftLbl = "RANGE";          leftVal = "ARMED"; leftClr = C_WARN; }
   else                                    { leftLbl = "RANGE";          leftVal = "LOCKED"; leftClr = C_DIM; }

   PTxt(P_PAD, cy + 7, leftLbl, C_DIM, F_UI, 7, TA_LEFT | TA_TOP, FW_SEMIBOLD);
   PTxt(P_PAD, cy + 19, leftVal, leftClr, F_MONO, 11, TA_LEFT | TA_TOP, FW_SEMIBOLD);

   PBox(P_W / 2, cy + 4, P_W / 2, cy + 40, C_EDGE);

   PTxt(P_W / 2 + P_PAD, cy + 7, "FORCED FLAT IN", C_DIM, F_UI, 7, TA_LEFT | TA_TOP, FW_SEMIBOLD);
   PTxt(P_W / 2 + P_PAD, cy + 19, ClockLeft(endMin), C_INKHI, F_MONO, 11, TA_LEFT | TA_TOP, FW_SEMIBOLD);

   PHair(cy + 44, C_EDGE);
   y = cy + 45;

   //=== SATIR BASLIGI ==============================================
   int cSym = P_PAD;
   int cBdg = P_PAD + 88;
   int cBar = P_PAD + 176;
   int cBarE= P_W - 106;
   int cR   = P_W - 58;
   int cLot = P_W - P_PAD;

   PTxt(cSym, y + 6, "SYMBOL",  C_DIM, F_UI, 7, TA_LEFT  | TA_TOP, FW_SEMIBOLD);
   PTxt(cBdg, y + 6, "STATE",   C_DIM, F_UI, 7, TA_LEFT  | TA_TOP, FW_SEMIBOLD);
   PTxt(cBar, y + 6, "RANGE",   C_DIM, F_UI, 7, TA_LEFT  | TA_TOP, FW_SEMIBOLD);
   PTxt(cR,   y + 6, "R",       C_DIM, F_UI, 7, TA_RIGHT | TA_TOP, FW_SEMIBOLD);
   PTxt(cLot, y + 6, "LOT",     C_DIM, F_UI, 7, TA_RIGHT | TA_TOP, FW_SEMIBOLD);
   PHair(y + 21, C_EDGE);
   y += 22;

   //=== SATIRLAR ===================================================
   int shown = (nsym > 4) ? 4 : nsym;
   for(int i = 0; i < shown; i++) {
      string ss  = s[i];
      int    st  = (int)BusGet(ss, "st", ST_OFFLINE);
      double pn  = BusGet(ss, "pn", -9.0);
      double rr  = BusGet(ss, "rr", -99.0);
      double lt  = BusGet(ss, "lt", 0.0);
      bool   mine= (ss == _Symbol);

      int ry = y + i * P_ROWH;

      if(mine)               PBox(0, ry, 3, ry + P_ROWH - 1, C_ACC);
      if(st == ST_SKIP)      PBox(4, ry, P_W - 1, ry + P_ROWH - 1, C'32,26,27');
      else if(mine)          PBox(4, ry, P_W - 1, ry + P_ROWH - 1, C'26,31,39');

      PTxt(cSym, ry + 6, ss, C_INKHI, F_MONO, 8, TA_LEFT | TA_TOP, FW_SEMIBOLD);
      PTxt(cBdg, ry + 7, StateName(st), StateColor(st), F_UI, 7, TA_LEFT | TA_TOP, FW_SEMIBOLD);

      if(st == ST_SKIP) {
         string why = mine ? skipReason : "no trade today";
         PTxt(cBar, ry + 7, why, C_BAD, F_MONO, 7);
      } else {
         DrawRangeBar(cBar, ry + P_ROWH / 2, cBarE, pn, st);
      }

      if(rr > -90.0)
         PTxt(cR, ry + 6, StringFormat("%+.1f", rr), (rr >= 0 ? C_GOOD : C_BAD),
              F_MONO, 8, TA_RIGHT | TA_TOP);
      else
         PTxt(cR, ry + 6, "-", C_DIM, F_MONO, 8, TA_RIGHT | TA_TOP);

      PTxt(cLot, ry + 6, (lt > 0 ? StringFormat("%.2f", lt) : "-"),
           (lt > 0 ? C_INK : C_DIM), F_MONO, 8, TA_RIGHT | TA_TOP);

      if(i < shown - 1) PHair(ry + P_ROWH - 1, C'42,48,57');
   }

   if(shown == 0)
      PTxt(P_W / 2, y + 12, "no copies publishing", C_DIM, F_UI, 8, TA_CENTER | TA_TOP);

   y += 4 * P_ROWH;
   PHair(y, C_EDGE);
   y += 1;

   //=== MERDIVEN ===================================================
   PTxt(P_PAD, y + 7, _Symbol + " - TODAY", C_DIM, F_UI, 7, TA_LEFT | TA_TOP, FW_SEMIBOLD);

   string steps[6] = {"WAIT", "RANGE", "TRADE", "BE", "PARTIAL", "FLAT"};
   int reached = 0;
   if(myState == ST_RANGE)   reached = 1;
   if(myState == ST_TRADE)   reached = 2;
   if(myState == ST_BE)      reached = 3;
   if(myState == ST_PARTIAL) reached = 4;
   if(myState == ST_FLAT)    reached = 5;
   if(myState == ST_SKIP)    reached = -1;

   int sx = P_PAD;
   int sw = (P_W - 2 * P_PAD) / 6;
   for(int k = 0; k < 6; k++) {
      uint bar = C_EDGE, txt = C_DIM;
      if(reached >= 0 && k < reached)  { bar = C_GOOD; txt = C_INK; }
      if(reached >= 0 && k == reached) { bar = C_ACC;  txt = C_ACC; }
      if(reached < 0)                  { bar = (k == 0 ? C_BAD : C_EDGE); txt = (k == 0 ? C_BAD : C_DIM); }
      PBox(sx + k * sw, y + 24, sx + (k + 1) * sw - 4, y + 25, bar);
      PTxt(sx + k * sw, y + 29, (reached < 0 && k == 0) ? "SKIPPED" : steps[k],
           txt, F_UI, 7, TA_LEFT | TA_TOP, FW_SEMIBOLD);
   }

   //=== CERCEVE ====================================================
   cv.Rectangle(0, 0, P_W - 1, P_H - 1, ColorToARGB(C_EDGE, 255));
   cv.Rectangle(1, 1, P_W - 2, P_H - 2, ColorToARGB(C_EDGEOUT, 160));

   cv.Update();
}

//##################################################################//
//                                                                  //
//   GRAFIK KATMANI  (range kutusu ve islem seviyeleri)             //
//                                                                  //
//##################################################################//

#define O_BOX   PFX "box"
#define O_RHI   PFX "rhi"
#define O_RLO   PFX "rlo"
#define O_ENT   PFX "ent"
#define O_SL    PFX "sl"
#define O_TP    PFX "tp"
#define O_PTP   PFX "ptp"
#define O_BE    PFX "be"
#define O_VS    PFX "vs"
#define O_VE    PFX "ve"

void MkHLine(string n, double px, uint clr, int width, ENUM_LINE_STYLE style, string text)
{
   if(ObjectFind(0, n) < 0) ObjectCreate(0, n, OBJ_HLINE, 0, 0, px);
   ObjectSetDouble (0, n, OBJPROP_PRICE, px);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, n, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, n, OBJPROP_STYLE, style);
   ObjectSetInteger(0, n, OBJPROP_BACK,  false);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
   ObjectSetString (0, n, OBJPROP_TEXT,  text);
   ObjectSetString (0, n, OBJPROP_TOOLTIP, text);
}

void MkVLine(string n, datetime t, uint clr, ENUM_LINE_STYLE style)
{
   if(ObjectFind(0, n) < 0) ObjectCreate(0, n, OBJ_VLINE, 0, t, 0);
   ObjectSetInteger(0, n, OBJPROP_TIME,  t);
   ObjectSetInteger(0, n, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, n, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, n, OBJPROP_STYLE, style);
   ObjectSetInteger(0, n, OBJPROP_BACK,  true);
   ObjectSetInteger(0, n, OBJPROP_SELECTABLE, false);
}

void DrawRangeObjs()
{
   MkHLine(O_RHI, rangeHigh, C_ACC, 1, STYLE_DASH, "Range high");
   MkHLine(O_RLO, rangeLow,  C_ACC, 1, STYLE_DASH, "Range low");

   datetime t1 = iTime(_Symbol, _Period, LookbackCandles);
   datetime t2 = iTime(_Symbol, _Period, 0);
   if(ObjectFind(0, O_BOX) < 0)
      ObjectCreate(0, O_BOX, OBJ_RECTANGLE, 0, t1, rangeHigh, t2, rangeLow);
   ObjectSetInteger(0, O_BOX, OBJPROP_TIME,  0, t1);
   ObjectSetDouble (0, O_BOX, OBJPROP_PRICE, 0, rangeHigh);
   ObjectSetInteger(0, O_BOX, OBJPROP_TIME,  1, t2);
   ObjectSetDouble (0, O_BOX, OBJPROP_PRICE, 1, rangeLow);
   ObjectSetInteger(0, O_BOX, OBJPROP_COLOR, C_ACC);
   ObjectSetInteger(0, O_BOX, OBJPROP_FILL,  true);
   ObjectSetInteger(0, O_BOX, OBJPROP_BACK,  true);
   ObjectSetInteger(0, O_BOX, OBJPROP_SELECTABLE, false);
   ChartRedraw();
}

void FreezeRangeBox()
{
   if(ObjectFind(0, O_BOX) < 0) return;
   ObjectSetInteger(0, O_BOX, OBJPROP_TIME, 1, iTime(_Symbol, _Period, 0));
}

void DelRangeObjs()
{
   ObjectDelete(0, O_BOX); ObjectDelete(0, O_RHI); ObjectDelete(0, O_RLO);
   ChartRedraw();
}

void DrawTradeLines(ulong tk, ENUM_ORDER_TYPE type, double entry, double sl, double tp)
{
   bool isBuy = (type == ORDER_TYPE_BUY);
   MkHLine(O_ENT, entry, C_INK, 2, STYLE_SOLID, "Entry");
   MkHLine(O_SL,  sl,    C_BAD, 2, STYLE_SOLID, StringFormat("Stop  %.2f%%", RiskPercent));
   if(UseTP && tp > 0)
      MkHLine(O_TP, tp, C_GOOD, 2, STYLE_SOLID, StringFormat("Target  %.1fR", TP_R));
   if(UsePartialTP) {
      double p = isBuy ? entry + slDist * PTP_Trigger_R : entry - slDist * PTP_Trigger_R;
      MkHLine(O_PTP, p, C_GOOD, 1, STYLE_DOT,
              StringFormat("Partial  %.1fR  %.0f%%", PTP_Trigger_R, PTP_Percent));
   }
   if(UseBreakEven) {
      double b = isBuy ? entry + slDist * BE_Trigger_R : entry - slDist * BE_Trigger_R;
      MkHLine(O_BE, b, C_WARN, 1, STYLE_DOT, StringFormat("Break even trigger  %.1fR", BE_Trigger_R));
   }
   ChartRedraw();
}

void UpdateTradeLines(ulong tk)
{
   if(!PositionSelectByTicket(tk)) return;
   double sl = PositionGetDouble(POSITION_SL);
   if(sl > 0) MkHLine(O_SL, sl, beTriggered ? C_ACC : C_BAD, 2, STYLE_SOLID,
                      beTriggered ? "Stop at break even" : StringFormat("Stop  %.2f%%", RiskPercent));
}

void DelTradeLines()
{
   ObjectDelete(0, O_ENT); ObjectDelete(0, O_SL); ObjectDelete(0, O_TP);
   ObjectDelete(0, O_PTP); ObjectDelete(0, O_BE);
   ChartRedraw();
}

void DrawDayLines()
{
   MqlDateTime dt; TimeCurrent(dt);
   datetime midnight = StringToTime(StringFormat("%04d.%02d.%02d 00:00", dt.year, dt.mon, dt.day));
   MkVLine(O_VS, midnight + StartHour * 3600 + StartMinute * 60, C_ACC,  STYLE_DOT);
   MkVLine(O_VE, midnight + EndHour   * 3600 + EndMinute   * 60, C_WARN, STYLE_DOT);
   ChartRedraw();
}

//##################################################################//
//                                                                  //
//   ONTESTER  -  kara duzgunlugu, sadece net kar degil             //
//   Egim x R^2 x sqrt(islem)  -  100 islem altini cezalandirir.    //
//                                                                  //
//##################################################################//
double OnTester()
{
   int deals = 0;
   double eq[];
   if(!HistorySelect(0, TimeCurrent())) return -1000.0;

   int total = HistoryDealsTotal();
   double bal = TesterStatistics(STAT_INITIAL_DEPOSIT);
   ArrayResize(eq, 0);

   for(int i = 0; i < total; i++) {
      ulong dk = HistoryDealGetTicket(i);
      if(dk == 0) continue;
      if(HistoryDealGetInteger(dk, DEAL_ENTRY) == DEAL_ENTRY_IN) continue;
      bal += HistoryDealGetDouble(dk, DEAL_PROFIT)
           + HistoryDealGetDouble(dk, DEAL_SWAP)
           + HistoryDealGetDouble(dk, DEAL_COMMISSION);
      if(bal <= 0) return -1000.0;
      int k = ArraySize(eq);
      ArrayResize(eq, k + 1);
      eq[k] = MathLog(bal);
      deals++;
   }
   if(deals < 30) return -500.0;

   //--- log-bakiyeye dogru regresyon
   int n = ArraySize(eq);
   double sx = 0, sy = 0, sxx = 0, sxy = 0, syy = 0;
   for(int i = 0; i < n; i++) {
      double x = (double)i, yv = eq[i];
      sx += x; sy += yv; sxx += x * x; sxy += x * yv; syy += yv * yv;
   }
   double den = n * sxx - sx * sx;
   if(MathAbs(den) < 1e-12) return -500.0;

   double slope = (n * sxy - sx * sy) / den;
   double rnum  = (n * sxy - sx * sy);
   double rden  = MathSqrt(MathAbs((n * sxx - sx * sx) * (n * syy - sy * sy)));
   double r2    = (rden > 1e-12) ? (rnum / rden) * (rnum / rden) : 0.0;

   double score = slope * r2 * MathSqrt((double)deals) * 10000.0;
   if(deals < 100) score -= 500.0;
   return score;
}
//+------------------------------------------------------------------+
