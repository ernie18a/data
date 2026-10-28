//+------------------------------------------------------------------+
//|                    HTF PO3 + RSI Divergence                      |                       
//|       RSI Divergence Lines/Boxes + HTF PO3 Candle Projection     |
//+------------------------------------------------------------------+
#property copyright   "Hammad Dilber"
#property version     "1.07"
#property description "HTF PO3 Candle + RSI Divergence Lines & Boxes (Chart + RSI Window)"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_level1     70.0
#property indicator_level2     50.0
#property indicator_level3     30.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DOT

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group           "=== RSI Divergence ==="
input int             InpRsiLen      = 14;
input int             InpLbLeft      = 5;
input int             InpLbRight     = 5;
input color           InpBullDivCol  = clrLime;
input color           InpBearDivCol  = clrRed;
input bool            InpShowOnChart = true;   // Show divergence lines on main chart too

input group           "=== HTF PO3 Settings ==="
input ENUM_TIMEFRAMES InpHTF         = PERIOD_H1;
input int             InpCandleCount = 3;
input int             InpRightOffset = 3;    // Bars gap from last chart bar (keep small: 1-5)
input bool            InpShowLabels  = true;
input bool            InpShowDelta   = true;
input color           InpBullCandle  = C'8,153,129';
input color           InpBearCandle  = C'242,54,69';

input group           "=== Signal Filters ==="
input bool            InpUseHTFConfirm  = true;   // HTF candle direction match
input double          InpRsiBuyLevel    = 45.0;   // RSI must be below this for BUY
input double          InpRsiSellLevel   = 55.0;   // RSI must be above this for SELL
input bool            InpUseDeltaFilter = true;   // Delta must confirm direction
input bool            InpShowArrows     = true;   // Show arrows on chart
input bool            InpShowDashboard  = true;   // Show signal dashboard
input color           InpBuyArrowCol    = C'0,200,130';   // BUY arrow color
input color           InpSellArrowCol   = C'255,80,80';   // SELL arrow color

input group           "=== Alerts ==="
input bool            InpAlertBull   = true;
input bool            InpAlertBear   = true;

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
double RsiBuffer[];
int    rsiHandle;
int    subWin = -1;
int    subWinSearchAttempts = 0; // Bug #5 Fix: track retry attempts

double   plPriceMem = EMPTY_VALUE, plRsiMem = EMPTY_VALUE;
int      plIdxMem   = -1;
double   phPriceMem = EMPTY_VALUE, phRsiMem = EMPTY_VALUE;
int      phIdxMem   = -1;

string OBJ_PREFIX  = "HTFDIV_";
string PO3_PREFIX  = "HTFPO3_";
string SIG_PREFIX  = "HTFSIG_";   // Signal arrows + dashboard

// Last alerted bar times — Fix #F: prevent repeated alerts on same divergence bar
datetime lastBullAlertBar = 0;
datetime lastBearAlertBar = 0;

// Last signal state for dashboard
string lastSignal     = "NONE";   // "BUY", "SELL", "NONE"
datetime lastSigTime  = 0;

//+------------------------------------------------------------------+
//| Forward Declarations                                             |
//+------------------------------------------------------------------+
void DeleteByPrefix(const string prefix);
void DrawBullDiv(const datetime &time[], const double &low[], int ci, int pi, double pPrice, double pRsi);
void DrawBearDiv(const datetime &time[], const double &high[], int ci, int pi, double pPrice, double pRsi);
void UpdateHTFData(const double &open[], const double &high[], const double &low[], const double &close[], const long &tv[]);
void DrawPO3();
void CheckAndDrawSignal(bool isBull, int idx, const datetime &time[], const double &price[]);
void DrawSignalArrow(bool isBull, int idx, const datetime &time[], const double &price[]);
void DrawDashboard();

double   htfO[10], htfH[10], htfL[10], htfC[10], htfDelta[10];
datetime htfBarTime[10];
int      htfCount = 0;

double   liveO = 0, liveH = 0, liveL = 0, liveC = 0, liveDelta = 0;
datetime liveStartTime = 0;
datetime lastHTFTime   = 0;

//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, RsiBuffer, INDICATOR_DATA);
   ArraySetAsSeries(RsiBuffer, true);
   PlotIndexSetString(0, PLOT_LABEL, "RSI(" + IntegerToString(InpRsiLen) + ")");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   // Bug #5 Fix: reset subwindow search state on every init/reinit so retry always works
   subWin = -1;
   subWinSearchAttempts = 0;

   rsiHandle = iRSI(_Symbol, PERIOD_CURRENT, InpRsiLen, PRICE_CLOSE);
   if(rsiHandle == INVALID_HANDLE)
   {
      Print("ERROR: RSI handle failed");
      return INIT_FAILED;
   }

   // Bug #6 Fix: Explicitly reset pivot memory on every init/reinit
   plPriceMem = EMPTY_VALUE; plRsiMem = EMPTY_VALUE; plIdxMem = -1;
   phPriceMem = EMPTY_VALUE; phRsiMem = EMPTY_VALUE; phIdxMem = -1;
   // Reset HTF live state
   liveO=0; liveH=0; liveL=0; liveC=0; liveDelta=0;
   liveStartTime=0; lastHTFTime=0; htfCount=0;
   // Fix #F: reset alert memory
   lastBullAlertBar=0; lastBearAlertBar=0;

   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "HTF PO3 + RSI Div");
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteByPrefix(OBJ_PREFIX);
   DeleteByPrefix(PO3_PREFIX);
   DeleteByPrefix(SIG_PREFIX);
   IndicatorRelease(rsiHandle);
}

//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   if(rates_total < InpLbLeft + InpLbRight + 5) return 0;

   // Bug #5 Fix: retry FindSubWindow up to 10 ticks so early divergences are not lost
   if(subWin < 0 && subWinSearchAttempts < 10)
   {
      subWin = FindSubWindow();
      subWinSearchAttempts++;
   }

   ArraySetAsSeries(time,        true);
   ArraySetAsSeries(open,        true);
   ArraySetAsSeries(high,        true);
   ArraySetAsSeries(low,         true);
   ArraySetAsSeries(close,       true);
   ArraySetAsSeries(tick_volume, true);

   if(CopyBuffer(rsiHandle, 0, 0, rates_total, RsiBuffer) <= 0) return 0;

   // Bug #1 Fix: Reset pivot memory on every full recalculation to prevent stale/false divergences
   if(prev_calculated == 0)
   {
      plPriceMem = EMPTY_VALUE; plRsiMem = EMPTY_VALUE; plIdxMem = -1;
      phPriceMem = EMPTY_VALUE; phRsiMem = EMPTY_VALUE; phIdxMem = -1;
   }

   int limit = (prev_calculated == 0) ? rates_total - InpLbLeft - InpLbRight - 2 : 3;

   for(int i = limit; i >= InpLbRight; i--)
   {
      if(IsPivotLow(RsiBuffer, i, InpLbLeft, InpLbRight))
      {
         if(plPriceMem != EMPTY_VALUE)
         {
            if(low[i] < plPriceMem && RsiBuffer[i] > plRsiMem)
            {
               DrawBullDiv(time, low, i, plIdxMem, plPriceMem, plRsiMem);
               // Arrow on every divergence (historical + live)
               CheckAndDrawSignal(true, i, time, low);
               // Alert only on fresh signal (Fix #F: check bar time to avoid duplicate alerts)
               if(i == InpLbRight && InpAlertBull && time[i] != lastBullAlertBar)
               {
                  Alert(_Symbol + " - Bullish RSI Divergence!");
                  lastBullAlertBar = time[i];
               }
            }
         }
         plPriceMem = low[i];
         plRsiMem   = RsiBuffer[i];
         plIdxMem   = i;
      }

      if(IsPivotHigh(RsiBuffer, i, InpLbLeft, InpLbRight))
      {
         if(phPriceMem != EMPTY_VALUE)
         {
            if(high[i] > phPriceMem && RsiBuffer[i] < phRsiMem)
            {
               DrawBearDiv(time, high, i, phIdxMem, phPriceMem, phRsiMem);
               // Arrow on every divergence (historical + live)
               CheckAndDrawSignal(false, i, time, high);
               // Alert only on fresh signal (Fix #F: check bar time to avoid duplicate alerts)
               if(i == InpLbRight && InpAlertBear && time[i] != lastBearAlertBar)
               {
                  Alert(_Symbol + " - Bearish RSI Divergence!");
                  lastBearAlertBar = time[i];
               }
            }
         }
         phPriceMem = high[i];
         phRsiMem   = RsiBuffer[i];
         phIdxMem   = i;
      }
   }

   UpdateHTFData(open, high, low, close, tick_volume);
   DrawPO3();

   return rates_total;
}

//+------------------------------------------------------------------+
// Bug #4 Fix: Reliable subwindow finder using ChartWindowFind first,
// fallback to name-search. Also resets search counter on success.   |
//+------------------------------------------------------------------+
int FindSubWindow()
{
   // Primary: use ChartWindowFind with the indicator's short name
   int w = (int)ChartWindowFind(0, "HTF PO3 + RSI Div");
   if(w >= 0) return w;

   // Fallback: iterate all subwindows and match by partial name
   int wins = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
   for(w = 1; w < wins; w++)
   {
      int cnt = ChartIndicatorsTotal(0, w);
      for(int k = 0; k < cnt; k++)
      {
         string iname = ChartIndicatorName(0, w, k);
         if(StringFind(iname, "HTF PO3") >= 0 ||
            StringFind(iname, "RSI Div") >= 0)
            return w;
      }
   }
   return -1; // Bug #2 Fix: return -1 so DrawBullDiv/DrawBearDiv skip drawing instead of using wrong window
}

//+------------------------------------------------------------------+
bool IsPivotLow(const double &buf[], int idx, int left, int right)
{
   int bufSize = ArraySize(buf);
   if(idx + left  >= bufSize) return false;  // Fix #E: bounds guard
   if(idx - right < 0)        return false;  // Fix #E: bounds guard
   for(int j = 1; j <= left;  j++) if(buf[idx+j] <= buf[idx]) return false;
   for(int j = 1; j <= right; j++) if(buf[idx-j] <= buf[idx]) return false;
   return true;
}

bool IsPivotHigh(const double &buf[], int idx, int left, int right)
{
   int bufSize = ArraySize(buf);
   if(idx + left  >= bufSize) return false;  // Fix #E: bounds guard
   if(idx - right < 0)        return false;  // Fix #E: bounds guard
   for(int j = 1; j <= left;  j++) if(buf[idx+j] >= buf[idx]) return false;
   for(int j = 1; j <= right; j++) if(buf[idx-j] >= buf[idx]) return false;
   return true;
}

//+------------------------------------------------------------------+
void DrawBullDiv(const datetime &time[], const double &low[],
                 int ci, int pi, double pPrice, double pRsi)
{
   if(pi < 0 || subWin < 0) return;
   datetime t1 = time[pi], t2 = time[ci];
   double   r1 = pRsi,     r2 = RsiBuffer[ci];
   double   p1 = pPrice,   p2 = low[ci];
   string   tag = OBJ_PREFIX + "BL" + IntegerToString((int)t2);

   // --- RSI Subwindow objects ---
   if(ObjectFind(0, tag+"_l") < 0)
   {
      ObjectCreate(0, tag+"_l", OBJ_TREND, subWin, t1, r1, t2, r2);
      ObjectSetInteger(0, tag+"_l", OBJPROP_COLOR,     InpBullDivCol);
      ObjectSetInteger(0, tag+"_l", OBJPROP_WIDTH,     2);
      ObjectSetInteger(0, tag+"_l", OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, tag+"_l", OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, tag+"_l", OBJPROP_HIDDEN,    true);
   }
   if(ObjectFind(0, tag+"_t") < 0)
   {
      ObjectCreate(0, tag+"_t", OBJ_TEXT, subWin, t2, r2 - 4.0);
      ObjectSetString(0,  tag+"_t", OBJPROP_TEXT,      "Bull Div");
      ObjectSetInteger(0, tag+"_t", OBJPROP_COLOR,     InpBullDivCol);
      ObjectSetInteger(0, tag+"_t", OBJPROP_FONTSIZE,  8);
      ObjectSetInteger(0, tag+"_t", OBJPROP_ANCHOR,    ANCHOR_UPPER);
      ObjectSetInteger(0, tag+"_t", OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, tag+"_t", OBJPROP_HIDDEN,    true);
   }

   // --- Main Chart (window 0) objects ---
   if(InpShowOnChart)
   {
      if(ObjectFind(0, tag+"_cl") < 0)
      {
         ObjectCreate(0, tag+"_cl", OBJ_TREND, 0, t1, p1, t2, p2);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_COLOR,     InpBullDivCol);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_WIDTH,     2);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_STYLE,     STYLE_SOLID);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_HIDDEN,    true);
      }
      if(ObjectFind(0, tag+"_ct") < 0)
      {
         ObjectCreate(0, tag+"_ct", OBJ_TEXT, 0, t2, p2);
         ObjectSetString(0,  tag+"_ct", OBJPROP_TEXT,      "▲ Bull Div");
         ObjectSetInteger(0, tag+"_ct", OBJPROP_COLOR,     InpBullDivCol);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_FONTSIZE,  9);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_ANCHOR,    ANCHOR_UPPER);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_HIDDEN,    true);
      }
   }
}

//+------------------------------------------------------------------+
void DrawBearDiv(const datetime &time[], const double &high[],
                 int ci, int pi, double pPrice, double pRsi)
{
   if(pi < 0 || subWin < 0) return;
   datetime t1 = time[pi], t2 = time[ci];
   double   r1 = pRsi,     r2 = RsiBuffer[ci];
   double   p1 = pPrice,   p2 = high[ci];
   string   tag = OBJ_PREFIX + "BR" + IntegerToString((int)t2);

   // --- RSI Subwindow objects ---
   if(ObjectFind(0, tag+"_l") < 0)
   {
      ObjectCreate(0, tag+"_l", OBJ_TREND, subWin, t1, r1, t2, r2);
      ObjectSetInteger(0, tag+"_l", OBJPROP_COLOR,     InpBearDivCol);
      ObjectSetInteger(0, tag+"_l", OBJPROP_WIDTH,     2);
      ObjectSetInteger(0, tag+"_l", OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, tag+"_l", OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, tag+"_l", OBJPROP_HIDDEN,    true);
   }
   if(ObjectFind(0, tag+"_t") < 0)
   {
      ObjectCreate(0, tag+"_t", OBJ_TEXT, subWin, t2, r2 + 4.0);
      ObjectSetString(0,  tag+"_t", OBJPROP_TEXT,      "Bear Div");
      ObjectSetInteger(0, tag+"_t", OBJPROP_COLOR,     InpBearDivCol);
      ObjectSetInteger(0, tag+"_t", OBJPROP_FONTSIZE,  8);
      ObjectSetInteger(0, tag+"_t", OBJPROP_ANCHOR,    ANCHOR_LOWER);
      ObjectSetInteger(0, tag+"_t", OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0, tag+"_t", OBJPROP_HIDDEN,    true);
   }

   // --- Main Chart (window 0) objects ---
   if(InpShowOnChart)
   {
      if(ObjectFind(0, tag+"_cl") < 0)
      {
         ObjectCreate(0, tag+"_cl", OBJ_TREND, 0, t1, p1, t2, p2);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_COLOR,     InpBearDivCol);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_WIDTH,     2);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_STYLE,     STYLE_SOLID);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_RAY_RIGHT, false);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0, tag+"_cl", OBJPROP_HIDDEN,    true);
      }
      if(ObjectFind(0, tag+"_ct") < 0)
      {
         ObjectCreate(0, tag+"_ct", OBJ_TEXT, 0, t2, p2);
         ObjectSetString(0,  tag+"_ct", OBJPROP_TEXT,      "▼ Bear Div");
         ObjectSetInteger(0, tag+"_ct", OBJPROP_COLOR,     InpBearDivCol);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_FONTSIZE,  9);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_ANCHOR,    ANCHOR_LOWER);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0, tag+"_ct", OBJPROP_HIDDEN,    true);
      }
   }
}

//+------------------------------------------------------------------+
void UpdateHTFData(const double &open[], const double &high[],
                   const double &low[],  const double &close[],
                   const long   &tv[])
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   int copied = CopyRates(_Symbol, InpHTF, 0, 12, rates);
   if(copied < 2) return;

   datetime curT = rates[0].time;

   if(lastHTFTime != 0 && curT != lastHTFTime)
   {
      int mx = MathMin(htfCount, 9);
      for(int k = mx; k > 0; k--)
      {
         htfO[k]=htfO[k-1]; htfH[k]=htfH[k-1];
         htfL[k]=htfL[k-1]; htfC[k]=htfC[k-1];
         htfDelta[k]=htfDelta[k-1]; htfBarTime[k]=htfBarTime[k-1];
      }
      htfO[0]=liveO; htfH[0]=liveH; htfL[0]=liveL; htfC[0]=liveC;
      htfDelta[0]=liveDelta; htfBarTime[0]=liveStartTime;
      if(htfCount < 10) htfCount++;

      liveO=rates[0].open; liveH=rates[0].high;
      liveL=rates[0].low;  liveC=close[0];
      liveDelta=(close[0]>open[0])?(double)tv[0]:-(double)tv[0];
      liveStartTime=curT;
   }
   else if(lastHTFTime == 0)
   {
      liveO=rates[0].open; liveH=rates[0].high;
      liveL = rates[0].low;  // Fix #C: in Forex low is always > 0; direct assignment is correct
      liveC=close[0];
      liveDelta=0; liveStartTime=curT;

      htfCount = MathMin(copied-1, 10);
      for(int k=0; k<htfCount; k++)
      {
         htfO[k]=rates[k+1].open; htfH[k]=rates[k+1].high;
         htfL[k]=rates[k+1].low;  htfC[k]=rates[k+1].close;
         // Bug #3 Fix: historical delta now signed like live delta
         htfDelta[k] = (rates[k+1].close >= rates[k+1].open)
                       ? (double)rates[k+1].tick_volume
                       : -(double)rates[k+1].tick_volume;
         htfBarTime[k]=rates[k+1].time;
      }
   }
   else
   {
      if(rates[0].high > liveH) liveH = rates[0].high;
      // Bug #2 Fix: removed liveL==0 fallback; now always guarded by > 0 check
      if(rates[0].low > 0 && rates[0].low < liveL) liveL = rates[0].low;  // Fix #D: removed stale liveL==0 fallback
      liveC = close[0];
      // Bug #4 Fix: assign (not accumulate) because tv[0] is already the full cumulative bar volume
      liveDelta = (close[0]>open[0])?(double)tv[0]:-(double)tv[0];
   }
   lastHTFTime = curT;
}

//+------------------------------------------------------------------+
void DrawPO3()
{
   DeleteByPrefix(PO3_PREFIX);

   int      count  = MathMin(InpCandleCount, 10);
   int      cW     = 5;
   int      gap    = 8;
   int      psec   = (int)PeriodSeconds();

   // Fix: anchor to last bar time so candles appear just after the chart's last visible bar
   // TimeCurrent() can jump far into the future on weekends/gaps; last bar time is always correct
   datetime lastBar = (datetime)SeriesInfoInteger(_Symbol, PERIOD_CURRENT, SERIES_LASTBAR_DATE);
   if(lastBar == 0) lastBar = TimeCurrent(); // fallback
   datetime now = lastBar;

   for(int p = 0; p < count; p++)
   {
      bool     isLive = (p == count - 1);
      double   o, h, l, c, delta;
      datetime startT;

      if(isLive)
      {
         o=liveO; h=liveH; l=liveL; c=liveC;
         delta=liveDelta; startT=liveStartTime;
      }
      else
      {
         int idx = (count-2) - p;
         // Bug #3 Fix: also guard idx < 0 to handle edge case when CandleCount > htfCount+1
         if(idx < 0 || idx >= htfCount || htfO[idx]==0) continue;
         o=htfO[idx]; h=htfH[idx]; l=htfL[idx]; c=htfC[idx];
         delta=htfDelta[idx]; startT=htfBarTime[idx];
      }

      if(o==0 || h==0 || h==l) continue;

      bool  bull   = (c >= o);
      color col    = bull ? InpBullCandle : InpBearCandle;
      color wkCol  = isLive ? col : BlendGray(col, 0.55);

      int      base = InpRightOffset + p*(cW+gap);
      datetime tS   = (datetime)(now + (datetime)base          * psec);
      datetime tMid = (datetime)(now + (datetime)(base + cW/2) * psec);
      datetime tE   = (datetime)(now + (datetime)(base + cW)   * psec);

      string pfx = PO3_PREFIX + IntegerToString(p) + "_";

      // Wick
      ObjectCreate(0, pfx+"wk", OBJ_TREND, 0, tMid, h, tMid, l);
      ObjectSetInteger(0, pfx+"wk", OBJPROP_COLOR,     wkCol);
      ObjectSetInteger(0, pfx+"wk", OBJPROP_WIDTH,     2);
      ObjectSetInteger(0, pfx+"wk", OBJPROP_RAY_RIGHT, false);
      ObjectSetInteger(0, pfx+"wk", OBJPROP_SELECTABLE,false);

      // Body
      double bTop = MathMax(o,c), bBot = MathMin(o,c);
      if(bTop == bBot) bBot -= _Point;
      ObjectCreate(0, pfx+"bd", OBJ_RECTANGLE, 0, tS, bTop, tE, bBot);
      ObjectSetInteger(0, pfx+"bd", OBJPROP_COLOR,     wkCol);
      ObjectSetInteger(0, pfx+"bd", OBJPROP_BACK,      true);
      ObjectSetInteger(0, pfx+"bd", OBJPROP_FILL,      true);
      ObjectSetInteger(0, pfx+"bd", OBJPROP_SELECTABLE,false);

      // TF label
      string tfStr = GetTFStr(InpHTF);
      string tStr  = isLive ? tfStr : (tfStr+" "+TimeToString(startT,TIME_MINUTES));
      ObjectCreate(0, pfx+"tf", OBJ_TEXT, 0, tMid, h);
      ObjectSetString(0,  pfx+"tf", OBJPROP_TEXT,      tStr);
      ObjectSetInteger(0, pfx+"tf", OBJPROP_COLOR,     isLive ? clrWhite : C'180,180,180');
      ObjectSetInteger(0, pfx+"tf", OBJPROP_FONTSIZE,  isLive ? 10 : 8);
      ObjectSetString(0,  pfx+"tf", OBJPROP_FONT,      "Arial Bold");
      ObjectSetInteger(0, pfx+"tf", OBJPROP_ANCHOR,    ANCHOR_LOWER);
      ObjectSetInteger(0, pfx+"tf", OBJPROP_SELECTABLE,false);

      // OHLC labels (live only)
      if(InpShowLabels && isLive)
      {
         int dg = _Digits;
         string nm[4]; nm[0]=pfx+"oL"; nm[1]=pfx+"hL"; nm[2]=pfx+"lL"; nm[3]=pfx+"cL";
         double pv[4]; pv[0]=o; pv[1]=h; pv[2]=l; pv[3]=c;
         string tx[4]; tx[0]="O:"+DoubleToString(o,dg); tx[1]="H:"+DoubleToString(h,dg);
                       tx[2]="L:"+DoubleToString(l,dg); tx[3]="C:"+DoubleToString(c,dg);
         color  cl[4]; cl[0]=clrWhite; cl[1]=C'0,230,150'; cl[2]=C'255,100,100'; cl[3]=col;

         for(int x=0; x<4; x++)
         {
            ObjectCreate(0, nm[x], OBJ_TEXT, 0, tE, pv[x]);
            ObjectSetString(0,  nm[x], OBJPROP_TEXT,      tx[x]);
            ObjectSetInteger(0, nm[x], OBJPROP_COLOR,     cl[x]);
            ObjectSetInteger(0, nm[x], OBJPROP_FONTSIZE,  9);
            ObjectSetString(0,  nm[x], OBJPROP_FONT,      "Arial Bold");
            ObjectSetInteger(0, nm[x], OBJPROP_ANCHOR,    ANCHOR_LEFT);
            ObjectSetInteger(0, nm[x], OBJPROP_SELECTABLE,false);
         }
      }

      // Delta label
      if(InpShowDelta)
      {
         color dCol;
         if(isLive)
            dCol = (delta >= 0) ? C'0,230,150' : C'255,100,100';  // bright green / bright red
         else
            dCol = C'180,180,180';  // light gray for historical
         ObjectCreate(0, pfx+"dL", OBJ_TEXT, 0, tMid, l);
         ObjectSetString(0,  pfx+"dL", OBJPROP_TEXT,      "D:"+FormatDelta(delta));
         ObjectSetInteger(0, pfx+"dL", OBJPROP_COLOR,     dCol);
         ObjectSetInteger(0, pfx+"dL", OBJPROP_FONTSIZE,  isLive ? 9 : 8);
         ObjectSetString(0,  pfx+"dL", OBJPROP_FONT,      "Arial Bold");
         ObjectSetInteger(0, pfx+"dL", OBJPROP_ANCHOR,    ANCHOR_UPPER);
         ObjectSetInteger(0, pfx+"dL", OBJPROP_SELECTABLE,false);
      }
   }
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
// Signal: check filters then draw arrow + update dashboard         |
//+------------------------------------------------------------------+
void CheckAndDrawSignal(bool isBull, int idx,
                        const datetime &time[], const double &price[])
{
   bool isLive = (idx == InpLbRight);

   // --- Filter 1: RSI Level (applies to ALL bars — historical + live) ---
   double rsiVal = RsiBuffer[idx];
   if(isBull  && rsiVal > InpRsiBuyLevel)  return;
   if(!isBull && rsiVal < InpRsiSellLevel) return;

   // --- Filters 2 & 3: HTF + Delta — only meaningful on live bar ---
   if(isLive)
   {
      if(InpUseHTFConfirm)
      {
         bool htfBull = (liveC >= liveO);
         if(isBull  && !htfBull) return;
         if(!isBull && htfBull)  return;
      }
      if(InpUseDeltaFilter)
      {
         if(isBull  && liveDelta < 0) return;
         if(!isBull && liveDelta > 0) return;
      }
   }

   // --- Draw arrow on chart (historical + live) ---
   if(InpShowArrows) DrawSignalArrow(isBull, idx, time, price);

   // --- Update dashboard only for live signal ---
   if(isLive)
   {
      lastSignal  = isBull ? "BUY" : "SELL";
      lastSigTime = time[idx];
      if(InpShowDashboard) DrawDashboard();
   }
}

//+------------------------------------------------------------------+
void DrawSignalArrow(bool isBull, int idx,
                     const datetime &time[], const double &price[])
{
   string tag  = SIG_PREFIX + "ARR" + IntegerToString((int)time[idx]);
   if(ObjectFind(0, tag) >= 0) return;   // already drawn

   // Fix #A: iATR() returns a handle, not a value. Must use CopyBuffer() to get actual ATR value.
   double gap;
   int    atrHandle = iATR(_Symbol, PERIOD_CURRENT, 14);
   double atrBuf[1];
   if(atrHandle != INVALID_HANDLE && CopyBuffer(atrHandle, 0, 0, 1, atrBuf) == 1 && atrBuf[0] > 0)
      gap = atrBuf[0] * 0.5;
   else
      gap = _Point * 100 * 0.5;
   IndicatorRelease(atrHandle);

   double arrowP = isBull ? price[idx] - gap : price[idx] + gap;

   int   code = isBull ? 233 : 234;   // Wingdings ▲ / ▼
   color col  = isBull ? InpBuyArrowCol : InpSellArrowCol;

   ObjectCreate(0, tag, OBJ_ARROW, 0, time[idx], arrowP);
   ObjectSetInteger(0, tag, OBJPROP_ARROWCODE,  code);
   ObjectSetInteger(0, tag, OBJPROP_COLOR,      col);
   ObjectSetInteger(0, tag, OBJPROP_WIDTH,      3);
   ObjectSetInteger(0, tag, OBJPROP_ANCHOR,     isBull ? ANCHOR_TOP : ANCHOR_BOTTOM);
   ObjectSetInteger(0, tag, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, tag, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, tag, OBJPROP_ZORDER,     10);
}

//+------------------------------------------------------------------+
// DrawDashboard — Full always-visible panel, Top-Left corner        |
// Shows: Symbol/TF | HTF Direction | RSI | Delta | Signal | Time   |
//+------------------------------------------------------------------+
void DrawDashboard()
{
   string dbPrefix = SIG_PREFIX + "DB_";
   DeleteByPrefix(dbPrefix);

   // ── Signal colours ──────────────────────────────────────────────
   bool   hasSig  = (lastSignal == "BUY" || lastSignal == "SELL");
   bool   isBuy   = (lastSignal == "BUY");
   color  sigBg   = !hasSig ? C'30,30,30'   : (isBuy ? C'0,55,35'    : C'55,10,10');
   color  sigBrd  = !hasSig ? C'80,80,80'   : (isBuy ? C'0,200,130'  : C'255,80,80');
   color  sigTxtC = !hasSig ? clrSilver     : (isBuy ? C'0,230,150'  : C'255,110,110');
   string sigStr  = !hasSig ? "──  NO SIGNAL  ──"
                            : (isBuy ? "▲   BUY  SIGNAL" : "▼   SELL  SIGNAL");

   // ── HTF direction ────────────────────────────────────────────────
   bool   htfBull = (liveC >= liveO);
   string htfStr  = "HTF [" + GetTFStr(InpHTF) + "]: " + (htfBull ? "▲ Bullish" : "▼ Bearish");
   color  htfCol  = htfBull ? C'0,200,130' : C'255,80,80';

   // ── RSI ──────────────────────────────────────────────────────────
   double rsiNow  = (ArraySize(RsiBuffer) > InpLbRight) ? RsiBuffer[InpLbRight] : 0.0;
   string rsiStr  = "RSI (" + IntegerToString(InpRsiLen) + "):  " + DoubleToString(rsiNow, 1);
   color  rsiCol  = (rsiNow <= 30) ? C'0,220,140'
                  : (rsiNow >= 70) ? C'255,80,80'
                  : (rsiNow <  50) ? C'0,180,110'
                  : (rsiNow >  50) ? C'220,80,80'
                  : clrSilver;

   // ── Delta ────────────────────────────────────────────────────────
   string dltStr  = "Delta:  " + FormatDelta(liveDelta);
   color  dltCol  = (liveDelta > 0) ? C'0,200,130' : (liveDelta < 0) ? C'255,80,80' : clrSilver;

   // ── Symbol / Timeframe ───────────────────────────────────────────
   string symStr  = _Symbol + "  |  " + GetTFStr(Period());
   color  symCol  = clrWhite;

   // ── Last signal time ─────────────────────────────────────────────
   string timStr  = "Time: "
                  + (lastSigTime > 0 ? TimeToString(lastSigTime, TIME_DATE|TIME_MINUTES) : "---");
   color  timCol  = C'160,160,160';

   // ── Divider ──────────────────────────────────────────────────────
   string div1    = "───────────────";

   // ── Layout ───────────────────────────────────────────────────────
   int xBase = 12;   // pixels from left
   int yBase = 28;   // pixels from top — thoda neechay, toolbar se gap
   int lineH = 20;
   int boxW  = 200;  // fit width — zyada chaurai nahi
   int rows  = 8;
   int boxH  = lineH * rows + 12;

   // ── Background box ───────────────────────────────────────────────
   string bgTag = SIG_PREFIX + "DB_BG";
   ObjectCreate(0, bgTag, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, bgTag, OBJPROP_CORNER,      CORNER_LEFT_UPPER);
   ObjectSetInteger(0, bgTag, OBJPROP_XDISTANCE,   xBase - 8);
   ObjectSetInteger(0, bgTag, OBJPROP_YDISTANCE,   yBase - 8);
   ObjectSetInteger(0, bgTag, OBJPROP_XSIZE,        boxW);
   ObjectSetInteger(0, bgTag, OBJPROP_YSIZE,        boxH);
   ObjectSetInteger(0, bgTag, OBJPROP_BGCOLOR,      C'18,22,28');
   ObjectSetInteger(0, bgTag, OBJPROP_BORDER_TYPE,  BORDER_FLAT);
   ObjectSetInteger(0, bgTag, OBJPROP_COLOR,        sigBrd);
   ObjectSetInteger(0, bgTag, OBJPROP_WIDTH,        2);
   ObjectSetInteger(0, bgTag, OBJPROP_SELECTABLE,   false);
   ObjectSetInteger(0, bgTag, OBJPROP_HIDDEN,       true);
   ObjectSetInteger(0, bgTag, OBJPROP_ZORDER,       0);

   // ── Signal highlight strip ───────────────────────────────────────
   string stripTag = SIG_PREFIX + "DB_STRIP";
   ObjectCreate(0, stripTag, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, stripTag, OBJPROP_CORNER,    CORNER_LEFT_UPPER);
   ObjectSetInteger(0, stripTag, OBJPROP_XDISTANCE, xBase - 8);
   ObjectSetInteger(0, stripTag, OBJPROP_YDISTANCE, yBase - 8 + boxH - lineH - 8);
   ObjectSetInteger(0, stripTag, OBJPROP_XSIZE,      boxW);
   ObjectSetInteger(0, stripTag, OBJPROP_YSIZE,      lineH + 6);
   ObjectSetInteger(0, stripTag, OBJPROP_BGCOLOR,    sigBg);
   ObjectSetInteger(0, stripTag, OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0, stripTag, OBJPROP_COLOR,      sigBg);
   ObjectSetInteger(0, stripTag, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, stripTag, OBJPROP_HIDDEN,     true);
   ObjectSetInteger(0, stripTag, OBJPROP_ZORDER,     1);

   // ── Text rows ────────────────────────────────────────────────────
   // row order: symbol | divider | HTF | RSI | Delta | divider | Signal | Time
   string rowTxt[8]; color rowCol[8]; int rowSz[8]; string rowFnt[8];
   rowTxt[0]=symStr;  rowCol[0]=symCol;   rowSz[0]=10; rowFnt[0]="Arial Bold";
   rowTxt[1]=div1;    rowCol[1]=C'50,55,60'; rowSz[1]=8;  rowFnt[1]="Arial";
   rowTxt[2]=htfStr;  rowCol[2]=htfCol;   rowSz[2]=9;  rowFnt[2]="Arial Bold";
   rowTxt[3]=rsiStr;  rowCol[3]=rsiCol;   rowSz[3]=9;  rowFnt[3]="Arial Bold";
   rowTxt[4]=dltStr;  rowCol[4]=dltCol;   rowSz[4]=9;  rowFnt[4]="Arial Bold";
   rowTxt[5]=div1;    rowCol[5]=C'50,55,60'; rowSz[5]=8;  rowFnt[5]="Arial";
   rowTxt[6]=sigStr;  rowCol[6]=sigTxtC;  rowSz[6]=11; rowFnt[6]="Arial Bold";
   rowTxt[7]=timStr;  rowCol[7]=timCol;   rowSz[7]=8;  rowFnt[7]="Arial";

   for(int r = 0; r < 8; r++)
   {
      string rtag = SIG_PREFIX + "DB_R" + IntegerToString(r);
      ObjectCreate(0, rtag, OBJ_LABEL, 0, 0, 0);
      ObjectSetString(0,  rtag, OBJPROP_TEXT,       rowTxt[r]);
      ObjectSetInteger(0, rtag, OBJPROP_COLOR,      rowCol[r]);
      ObjectSetInteger(0, rtag, OBJPROP_FONTSIZE,   rowSz[r]);
      ObjectSetString(0,  rtag, OBJPROP_FONT,       rowFnt[r]);
      ObjectSetInteger(0, rtag, OBJPROP_CORNER,     CORNER_LEFT_UPPER);
      ObjectSetInteger(0, rtag, OBJPROP_XDISTANCE,  xBase);
      ObjectSetInteger(0, rtag, OBJPROP_YDISTANCE,  yBase + r * lineH);
      ObjectSetInteger(0, rtag, OBJPROP_ANCHOR,     ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, rtag, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, rtag, OBJPROP_HIDDEN,     true);
      ObjectSetInteger(0, rtag, OBJPROP_ZORDER,     2);
   }

   ChartRedraw(0);
}

//+------------------------------------------------------------------+
void DeleteByPrefix(const string prefix)
{
   int total = ObjectsTotal(0,-1,-1);
   for(int i=total-1; i>=0; i--)
   {
      string nm = ObjectName(0,i,-1,-1);
      if(StringFind(nm, prefix)==0) ObjectDelete(0, nm);
   }
}

//+------------------------------------------------------------------+
string FormatDelta(double val)
{
   string s   = (val>=0.0)?"+":"";
   double abs = MathAbs(val);
   if(abs>=1000000.0) return s+DoubleToString(val/1000000.0,1)+"M";
   if(abs>=1000.0)    return s+DoubleToString(val/1000.0,   1)+"K";
   return s+DoubleToString(val,0);
}

//+------------------------------------------------------------------+
string GetTFStr(ENUM_TIMEFRAMES tf)
{
   switch(tf)
   {
      case PERIOD_M1:  return "1m";
      case PERIOD_M2:  return "2m";
      case PERIOD_M3:  return "3m";
      case PERIOD_M4:  return "4m";
      case PERIOD_M5:  return "5m";
      case PERIOD_M6:  return "6m";
      case PERIOD_M10: return "10m";
      case PERIOD_M12: return "12m";
      case PERIOD_M15: return "15m";
      case PERIOD_M20: return "20m";
      case PERIOD_M30: return "30m";
      case PERIOD_H1:  return "1H";
      case PERIOD_H2:  return "2H";
      case PERIOD_H3:  return "3H";
      case PERIOD_H4:  return "4H";
      case PERIOD_H6:  return "6H";
      case PERIOD_H8:  return "8H";
      case PERIOD_H12: return "12H";
      case PERIOD_D1:  return "1D";
      case PERIOD_W1:  return "1W";
      case PERIOD_MN1: return "1MN";
      default:         return "HTF";
   }
}

//+------------------------------------------------------------------+
// Bug #8 Fix: MQL5 color is BGR. Corrected channel extraction names.|
//+------------------------------------------------------------------+
color BlendGray(color c, double ratio)
{
   int blue  = (int)(c & 0xFF);           // lowest byte  = Blue in MQL5 BGR
   int green = (int)((c >> 8)  & 0xFF);   // middle byte  = Green
   int red   = (int)((c >> 16) & 0xFF);   // highest byte = Red
   int gray  = 128;
   blue  = (int)(blue *(1.0-ratio) + gray*ratio);
   green = (int)(green*(1.0-ratio) + gray*ratio);
   red   = (int)(red  *(1.0-ratio) + gray*ratio);
   return (color)(blue | (green<<8) | (red<<16));
}
//+------------------------------------------------------------------+