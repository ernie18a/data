# Liquidity Sweep Engine

- url: https://www.tradingview.com/script/K4PtbeTE-Liquidity-Sweep-Engine/
- type: indicator
- pine_id: PUB;89e739339e39403795fcf8ce64ca55f8
- version: 1.0

## Description

A clean entry, stop and target tool built around one idea: price often runs
resting liquidity, fails to hold beyond it, and reverses. LSE maps where that
liquidity sits, waits for a sweep and reclaim, and prints a complete trade plan
with an even-sized stop and a target of 1:1 or better.

WHAT YOU SEE ON THE CHART
- A LONG or SHORT tag with the planned ratio, for example "LSE LONG 1:3"
- A red risk box and a green reward box
- SL, ENTRY and TP price lines, with a marker at every step (1:1, 1:2, 1:3...)
- A black line showing the exact liquidity level that was swept
- A result tag when the trade ends, showing the real outcome in R
- One optional entry at the front of the market when no sweep trade is open
- A small stats box with trades, win rate, average R and current status

HOW A SIGNAL IS BUILT
1. Liquidity map: swing highs and lows, equal highs and lows, prior day, week
   and month levels, Asia, London, overnight and opening range levels, higher
   timeframe swings, round numbers, value area and naked POCs, unfilled fair
   value gaps.
2. Sweep and reclaim: price must wick through a level and close back inside
   within a few bars. Too shallow counts as a touch, too deep counts as a
   breakout, and each level can only signal once.
3. Confirmation: a displacement candle or a structure shift is required.
4. Confluence: relative volume, lower timeframe delta, fair value gap, higher
   timeframe bias, premium and discount, VWAP side, volatility regime, active
   hours and SMT divergence are scored. Scheduled news minutes are blocked.

RISK MODEL
- Every stop is the same size for its trader type: 2 ATR (Scalper), 2.5 ATR
  (Day trader) or 3 ATR (Swing). The sweep wick must fit inside it or the
  signal is skipped. The stop never moves.
- The target is a whole multiple of the stop, from 1:1 up to 1:14, placed in
  front of the liquidity pool the setup is aiming at. Stronger confluence aims
  at a further pool.

SETTINGS
- Trader type: Auto, Scalper, Day trader or Swing
- Sensitivity: 1 to 10
- Signals: Fewer, Balanced or More
- Show one entry signal at the front of the market: on or off
- Display toggles for candle colors, the swept liquidity line and the stats box

GOOD TO KNOW
- Signals print on closed bars only and do not repaint. Swing levels confirm a
  few bars late by design.
- The stats box counts every signal at its real exit. A bar that touches both
  stop and target is counted as a loss.
- The front-of-market entry follows the higher timeframe trend. It is not a
  confirmed sweep signal and is tracked on its own line in the stats box.
- Works on futures, crypto, forex, stocks and indices. Hover any signal tag to
  see the full reasoning behind it.
- Alerts fire on every confirmed signal.

DISCLAIMER
This script is an educational and charting tool, not financial advice. It does
not predict the market and past signals do not guarantee future results. Test
it on a paper account and manage your own risk.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rcj101208
//@version=6
indicator("Liquidity Sweep Engine", shorttitle = "LSE", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// =====================================================================================
//  LIQUIDITY SWEEP ENGINE (LSE) v8
//  Three simple settings on top. Thirty liquidity tools working underneath:
//  swing / equal highs and lows, prior day / week / month, Asia / London / overnight /
//  opening range, higher timeframe swings, round numbers, volume profile, fair value gaps,
//  sweep and reclaim, penetration limits, reclaim timer, relative volume, lower timeframe
//  delta, displacement, structure shift, displacement FVG, higher timeframe bias,
//  premium / discount, time of day, volatility regime, VWAP, SMT divergence, level
//  quality, one signal per level, structural stop, liquidity targets, minimum reward.
//
//  Risk model: every stop is the same size for its trader type (2, 2.5 or 3 ATR from
//  entry), it must sit beyond the sweep wick or the signal is skipped, and it never
//  moves. The target is a whole multiple of that risk, from 1:1 up to 1:14, placed in
//  front of the liquidity pool the setup is aiming at. Stronger confluence aims further.
//
//  Signals fire on closed bars only and never repaint. The stats box counts every signal
//  at its real exit. A bar that touches both stop and target counts as a loss.
// =====================================================================================

// ====================================== SETTINGS ====================================
const string G1 = "Settings"
string i_type  = input.string("Auto", "Trader type", options = ["Auto", "Scalper", "Day trader", "Swing"], group = G1, tooltip = "Scalper uses a 2 ATR stop, Day trader 2.5 ATR, Swing 3 ATR with longer holds. Auto picks from your chart timeframe: 3 minutes and under is Scalper, up to 30 minutes is Day trader, above that is Swing.")
int    i_sens  = input.int(5, "Sensitivity", minval = 1, maxval = 10, group = G1, tooltip = "Higher reacts to smaller swings and smaller reversal candles. Lower waits for bigger, cleaner ones.")
bool   i_now   = input.bool(true, "Show one entry signal at the front of the market", group = G1, tooltip = "When no confirmed sweep trade is open, one dashed box at the latest bars gives a long or short entry in the direction of the higher timeframe trend. It is locked at the close of the bar where it prints: entry, stop and target never move. When it ends it is removed from the chart and the next one prints. It is not a confirmed sweep signal and is tracked on its own line in the stats box.")
string i_amt   = input.string("Balanced", "Signals", options = ["Fewer", "Balanced", "More"], group = G1, tooltip = "How much confluence a sweep needs before a signal prints.")
const string G2 = "Display"
bool   i_candles = input.bool(true, "Blue / black candles", group = G2)
bool   i_liqLine = input.bool(true, "Show the liquidity line that was swept", group = G2)
bool   i_stats   = input.bool(true, "Show stats box", group = G2)

// ================================ INTERNAL PRESETS ==================================
const string TZ = "America/New_York"
int    tfSec = timeframe.in_seconds(timeframe.period)
string prof  = i_type == "Auto" ? (tfSec <= 180 ? "Scalper" : tfSec <= 1800 ? "Day trader" : "Swing") : i_type
float  sensF = 1.0 + (5 - i_sens) * 0.08

int   P_PIVL    = math.max(2, math.round((prof == "Scalper" ? 6 : prof == "Day trader" ? 10 : 14) * sensF))
int   P_PIVR    = math.max(2, math.round((prof == "Scalper" ? 3 : prof == "Day trader" ? 5 : 7) * sensF))
int   P_RECLAIM = prof == "Scalper" ? 2 : 3
int   P_CONFIRM = prof == "Scalper" ? 4 : prof == "Day trader" ? 6 : 8
int   P_HOLD    = prof == "Scalper" ? 60 : prof == "Day trader" ? 120 : 200
int   P_COOL    = prof == "Scalper" ? 3 : 5
float P_DISP    = 0.8 * sensF
float P_MINQ    = i_amt == "Fewer" ? 40.0 : i_amt == "Balanced" ? 30.0 : 22.0
float P_SCORE   = i_amt == "Fewer" ? 0.62 : i_amt == "Balanced" ? 0.45 : 0.36
float P_STOP    = prof == "Scalper" ? 2.0 : prof == "Day trader" ? 2.5 : 3.0
float P_TIER1   = 0.60
float P_TIER2   = 0.72

const float EQ_TOL    = 0.10
const float PEN_MIN   = 0.05
const float PEN_MAX   = 1.50
const float RVOL_MIN  = 1.3
const float DISP_CLS  = 0.35
const int   MS_LEN    = 2
const float FVG_MIN   = 0.25
const int   FVG_AGE   = 300
const int   PD_LEN    = 200
const float ATR_PCT   = 30.0
const int   SMT_LEN   = 20
const int   AGE_CAP   = 200
const int   REACH_LEN = 30
const float REACH_CAP = 5.0
const float STOP_BUF  = 0.15
const float TP_OFF    = 0.05
const int   HTF_LEN   = 3
const int   MAX_LVLS  = 80
const int   R_CAP     = 14
const float HAIR      = 1.0
const int   HOLD_CAP  = 5
const float HW_RR     = 0.2
bool  HW = false

string htfTf  = tfSec <= 300 ? "60" : tfSec <= 900 ? "240" : tfSec <= 14400 ? "D" : tfSec <= 86400 ? "W" : "M"
string ltfUse = tfSec >= 86400 ? "60" : tfSec >= 3600 ? "5" : tfSec >= 300 ? "1" : timeframe.period
string anchor = tfSec < 86400 ? "D" : tfSec < 604800 ? "M" : "12M"
bool   useSessions = timeframe.isintraday and tfSec <= 3600

// SMT partner, picked automatically from the chart symbol
string root = syminfo.root
string tk   = syminfo.ticker
string smtSym = (root == "NQ" or root == "MNQ") ? "CME_MINI:ES1!" : (root == "ES" or root == "MES" or root == "YM" or root == "MYM" or root == "RTY" or root == "M2K") ? "CME_MINI:NQ1!" : str.contains(tk, "BTC") ? syminfo.prefix + ":" + str.replace_all(tk, "BTC", "ETH") : str.contains(tk, "ETH") ? syminfo.prefix + ":" + str.replace_all(tk, "ETH", "BTC") : str.contains(tk, "EURUSD") ? syminfo.prefix + ":" + str.replace_all(tk, "EURUSD", "GBPUSD") : str.contains(tk, "GBPUSD") ? syminfo.prefix + ":" + str.replace_all(tk, "GBPUSD", "EURUSD") : tk == "QQQ" ? "AMEX:SPY" : tk == "SPY" ? "NASDAQ:QQQ" : ""
bool smtOn = smtSym != ""

// ================================== CORE SERIES ====================================
// Every ta.* and request.* call lives at the top level so it runs on every bar.
bool  C   = barstate.isconfirmed
float atr = ta.atr(14)

// 1-2. swing pivots
float ph = ta.pivothigh(high, P_PIVL, P_PIVR)
float pl = ta.pivotlow(low, P_PIVL, P_PIVR)

// 3. prior day / week / month (last completed bar, no future data)
[pdH, pdL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwH, pwL] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmH, pmL] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

// 6 + 18. higher timeframe swings and bias, both from the previous closed HTF bar
[hPH, hPL, bF, bS] = request.security(syminfo.tickerid, htfTf, [ta.pivothigh(high, HTF_LEN, HTF_LEN)[1], ta.pivotlow(low, HTF_LEN, HTF_LEN)[1], ta.ema(close, 20)[1], ta.ema(close, 50)[1]], lookahead = barmerge.lookahead_on)
int bias = na(bF) or na(bS) ? 0 : bF > bS ? 1 : -1

// 7. round numbers, sized to the instrument
var float rStep = na
if na(rStep) and close > 0
    float rawStep = close * 0.004
    float k10 = math.pow(10, math.floor(math.log10(rawStep)))
    float mant = rawStep / k10
    rStep := (mant < 1.75 ? 1.0 : mant < 3.75 ? 2.5 : mant < 7.5 ? 5.0 : 10.0) * k10

// 9 / 17. fair value gaps
bool bullFvg = low > high[2] and (low - high[2]) >= FVG_MIN * atr
bool bearFvg = high < low[2] and (low[2] - high) >= FVG_MIN * atr

// 13. relative volume
float vol    = nz(volume)
float volSma = ta.sma(vol, 20)
float relVol = volSma > 0 ? vol / volSma : 0.0
float rvMax  = ta.highest(relVol, P_RECLAIM + 1)

// 14. lower timeframe delta
array<float> ltfArr = request.security_lower_tf(syminfo.tickerid, ltfUse, close > open ? volume : close < open ? -volume : 0.0)
float barDelta = na(ltfArr) ? 0.0 : ltfArr.size() > 0 ? nz(ltfArr.sum()) : 0.0
float d2 = barDelta + nz(barDelta[1])

// 15. displacement
float rng  = high - low
float body = math.abs(close - open)
bool bullDisp = close > open and rng > 0 and body >= P_DISP * atr and (high - close) / rng <= DISP_CLS
bool bearDisp = close < open and rng > 0 and body >= P_DISP * atr and (close - low) / rng <= DISP_CLS

// 16. internal structure
float mph = ta.pivothigh(high, MS_LEN, MS_LEN)
float mpl = ta.pivotlow(low, MS_LEN, MS_LEN)
var float lastMH = na
var float lastML = na
if not na(mph)
    lastMH := mph
if not na(mpl)
    lastML := mpl

// 19. premium / discount
float pdHi = ta.highest(high, PD_LEN)
float pdLo = ta.lowest(low, PD_LEN)
float pdEq = (pdHi + pdLo) / 2

// 20. active hours (London open, New York morning, New York afternoon) and news minutes
bool inW1 = not na(time(timeframe.period, "0200-0500", TZ))
bool inW2 = not na(time(timeframe.period, "0830-1130", TZ))
bool inW3 = not na(time(timeframe.period, "1330-1530", TZ))
bool inN1 = not na(time(timeframe.period, "0825-0840", TZ))
bool inN2 = not na(time(timeframe.period, "0955-1005", TZ))
bool inWindow = inW1 or inW2 or inW3
bool inNews   = timeframe.isintraday and tfSec <= 900 and (inN1 or inN2)

// 21. volatility regime
float atrRank = ta.percentrank(atr, 200)
bool  volOk   = atrRank >= ATR_PCT

// 22. anchored VWAP
bool newSess = timeframe.change(anchor)
float vw = ta.vwap(hlc3, newSess)

// 23. SMT divergence against the partner market
[smtH, smtL] = request.security(smtOn ? smtSym : syminfo.tickerid, timeframe.period, [high, low], ignore_invalid_symbol = true)
bool  smtLive = smtOn and not na(smtH)
int   smtW = P_RECLAIM + 1
float mHiW = ta.highest(high, smtW)
float mLoW = ta.lowest(low, smtW)
float mHiN = ta.highest(high, SMT_LEN)
float mLoN = ta.lowest(low, SMT_LEN)
float sHiW = ta.highest(smtH, smtW)
float sLoW = ta.lowest(smtL, smtW)
float sHiN = ta.highest(smtH, SMT_LEN)
float sLoN = ta.lowest(smtL, SMT_LEN)
bool smtBear = smtLive and mHiW > mHiN[smtW] and sHiW <= sHiN[smtW]
bool smtBull = smtLive and mLoW < mLoN[smtW] and sLoW >= sLoN[smtW]

// 24. reach
float reachLo = ta.lowest(low, REACH_LEN)
float reachHi = ta.highest(high, REACH_LEN)

// ================================ TYPES AND STORAGE =================================
type Level
    float  price
    int    dir
    int    bornBar
    int    bornTime
    int    touchBar
    int    touches
    int    weight
    string kind
    int    piercedBar
    float  ext

type Gap
    float top
    float bot
    int   dir
    int   bornBar

var array<Level> levels    = array.new<Level>()
var array<Gap>   gaps      = array.new<Gap>()
var array<label> sigLabels = array.new<label>()
var array<box>   trBoxes   = array.new<box>()
var array<line>  liqLines  = array.new<line>()
var array<line>  trLines   = array.new<line>()
var array<label> trTags    = array.new<label>()

// ==================================== FUNCTIONS =====================================
f_mk(bool used, bool ok) => not used ? "n/a" : ok ? "yes" : "no"

f_nearRound(float p) =>
    bool res = false
    if not na(rStep) and not na(atr)
        res := math.abs(p - math.round(p / rStep) * rStep) <= EQ_TOL * atr
    res

f_tagText(Level lv) =>
    string base = lv.kind
    if lv.touches > 1 and lv.kind == "Swing high"
        base := "Equal highs"
    if lv.touches > 1 and lv.kind == "Swing low"
        base := "Equal lows"
    string res = lv.touches > 1 ? base + " x" + str.tostring(lv.touches) : base
    res

f_addLevel(float p, int d, int bBar, int bTime, int w, string kd) =>
    if not na(p)
        levels.push(Level.new(price = p, dir = d, bornBar = bBar, bornTime = bTime, touchBar = bBar, touches = 1, weight = w, kind = kd, piercedBar = na, ext = na))
        if levels.size() > MAX_LVLS
            int idx = 0
            for i = 0 to levels.size() - 1
                Level lv = levels.get(i)
                if lv.weight == 1
                    idx := i
                    break
            levels.remove(idx)
    true

f_replace(string kd, float p, int d, int w) =>
    if levels.size() > 0
        for i = levels.size() - 1 to 0
            Level lv = levels.get(i)
            if lv.kind == kd
                levels.remove(i)
    f_addLevel(p, d, bar_index, time, w, kd)
    true

// 4-5. tracks a session's high and low and flags the first bar after it ends
f_sess(string s) =>
    bool inS = not na(time(timeframe.period, s, TZ))
    var float hi = na
    var float lo = na
    bool wasIn = inS[1]
    if inS and not wasIn
        hi := high
        lo := low
    else if inS
        hi := math.max(hi, high)
        lo := math.min(lo, low)
    bool ended = wasIn and not inS
    [hi, lo, ended]

// 8. point of control and value area from a price-binned volume map
f_profile(map<int, float> m, int bMin, int bMax, float sz) =>
    float pocP = na
    float vahP = na
    float valP = na
    if m.size() > 0 and not na(bMin) and not na(bMax)
        int pocBin = bMin
        float pocVol = -1.0
        float total = 0.0
        for b = bMin to bMax
            float v = nz(m.get(b))
            total += v
            if v > pocVol
                pocVol := v
                pocBin := b
        int up = pocBin
        int dn = pocBin
        float acc = pocVol
        float goal = total * 0.7
        while acc < goal and (up < bMax or dn > bMin)
            float vUp = up < bMax ? nz(m.get(up + 1)) : -1.0
            float vDn = dn > bMin ? nz(m.get(dn - 1)) : -1.0
            if vUp >= vDn
                up += 1
                acc += vUp
            else
                dn -= 1
                acc += vDn
        pocP := (pocBin + 0.5) * sz
        vahP := (up + 1) * sz
        valP := dn * sz
    [pocP, vahP, valP]

// 24. level quality, 0 to 100: timeframe of origin, touches, age, reach, round number
f_quality(Level lv, float reach) =>
    float ageS = math.min((bar_index - lv.bornBar) * 1.0 / AGE_CAP, 1.0)
    float tchS = math.min((lv.touches - 1) / 2.0, 1.0)
    float tfS  = (lv.weight - 1) / 3.0
    float rchS = math.max(math.min(nz(reach) / REACH_CAP, 1.0), 0.0)
    float q    = 30 * tfS + 25 * tchS + 20 * ageS + 25 * rchS + (f_nearRound(lv.price) ? 10 : 0)
    math.min(q, 100.0)

// 27. every opposing liquidity pool at 1R or further, as a distance in R
f_pools(int d, float entryPx, float riskPx, bool majorOnly) =>
    array<float> rrs = array.new<float>()
    array<string> tags = array.new<string>()
    float off = TP_OFF * atr
    if levels.size() > 0
        for i = 0 to levels.size() - 1
            Level lv = levels.get(i)
            bool sideL = d == 1 ? (lv.dir >= 0 and lv.price > entryPx) : (lv.dir <= 0 and lv.price < entryPx)
            bool major = lv.weight >= 2 or lv.touches >= 2
            if na(lv.piercedBar) and sideL and (major or not majorOnly)
                float rrL = (math.abs(lv.price - entryPx) - off) / riskPx
                if rrL >= 1.0 / HAIR
                    rrs.push(rrL)
                    tags.push(f_tagText(lv))
    if not majorOnly and gaps.size() > 0
        for i = 0 to gaps.size() - 1
            Gap g = gaps.get(i)
            float edge = d == 1 ? g.bot : g.top
            bool sideG = g.dir == -d and (d == 1 ? edge > entryPx : edge < entryPx)
            if sideG
                float rrG = (math.abs(edge - entryPx) - off) / riskPx
                if rrG >= 1.0 / HAIR
                    rrs.push(rrG)
                    tags.push("Unfilled FVG")
    [rrs, tags]

f_clearTradeDrawings() =>
    while trLines.size() > 0
        line.delete(trLines.pop())
    while trTags.size() > 0
        label.delete(trTags.pop())
    true

f_tradeLine(float p, color c, string txt, bool solid) =>
    if not na(p)
        trLines.push(line.new(bar_index, p, bar_index + 1, p, extend = extend.right, color = c, width = 1, style = solid ? line.style_solid : line.style_dotted))
        trTags.push(label.new(bar_index + 10, p, txt, style = label.style_none, textcolor = c, size = size.tiny))
    true

f_keepLabel(label l) =>
    sigLabels.push(l)
    if sigLabels.size() > 400
        label.delete(sigLabels.shift())
    true

f_keepBox(box b) =>
    trBoxes.push(b)
    if trBoxes.size() > 400
        box.delete(trBoxes.shift())
    true

f_keepLine(line l) =>
    liqLines.push(l)
    if liqLines.size() > 120
        line.delete(liqLines.shift())
    true

[asH, asL, asEnd] = f_sess("1800-0300")
[loH, loL, loEnd] = f_sess("0300-0800")
[onH, onL, onEnd] = f_sess("1800-0930")
[orH, orL, orEnd] = f_sess("0930-1000")

// ==================================== TRADE STATE ===================================
var int    trState   = 0      // 0 flat, 2 live
var int    trDir     = 0
var float  trEntry   = na
var float  trStop    = na
var float  trRisk    = na
var float  trTp      = na
var float  trRR      = 1.0
var float  trPeakPx  = na
var int    trPeakBar = na
var int    trFillBar = na
var box    trRiskBox = na
var box    trRewBox  = na
var int    lastEndBar = na

var int    nTrades = 0
var int    nTpHit  = 0
var float  sumR    = 0.0
var int    n1T = 0
var int    n1H = 0
var int    n2T = 0
var int    n2H = 0
var int    n3T = 0
var int    n3H = 0

var int    suDir     = 0
var float  suLvl     = na
var float  suExt     = na
var float  suQ       = na
var float  suPen     = na
var string suTag     = ""
var int    suBar     = na
var int    suPierce  = na
var int    suBorn    = na
var bool   suDisp    = false
var bool   suMss     = false
var bool   suFvg     = false
var float  suMssLvl  = na
var bool   suRvol    = false
var bool   suDelta   = false
var bool   suSmt     = false

bool   doClose  = false
float  closeR   = na
string closeWhy = ""

// ============================ STEP 1: MANAGE THE OPEN TRADE =========================
// The stop never moves. A trade ends at the stop (-1R), at the target (+N R), or on time.
if C and trState == 2 and bar_index > trFillBar
    bool hitSL = trDir == 1 ? low <= trStop : high >= trStop
    bool hitTP = trDir == 1 ? high >= trTp : low <= trTp
    if hitSL
        doClose := true
        closeR := -1.0
        closeWhy := "Stopped out"
    else
        if trDir == 1 and high > trPeakPx
            trPeakPx := math.min(high, trTp)
            trPeakBar := bar_index
        if trDir == -1 and low < trPeakPx
            trPeakPx := math.max(low, trTp)
            trPeakBar := bar_index
        if hitTP
            doClose := true
            closeR := trRR
            closeWhy := "Target hit"
    if not doClose and bar_index - trFillBar >= P_HOLD * math.min(trRR, HOLD_CAP)
        doClose := true
        closeR := trDir * (close - trEntry) / trRisk
        closeWhy := "Time exit"

if C and trState == 2
    box.set_right(trRiskBox, bar_index)
    box.set_right(trRewBox, bar_index)

if doClose
    float ranR = math.abs(trPeakPx - trEntry) / trRisk
    bool tpHit = closeWhy == "Target hit"
    nTrades += 1
    sumR += closeR
    if tpHit
        nTpHit += 1
    if trRR >= 1
        n1T += 1
        if ranR >= 0.999
            n1H += 1
    if trRR >= 2
        n2T += 1
        if ranR >= 1.999
            n2H += 1
    if trRR >= 3
        n3T += 1
        if ranR >= 2.999
            n3H += 1
    // a trade that missed its target keeps only the part of the green box price covered
    if not tpHit
        if trDir == 1
            box.set_top(trRewBox, trPeakPx)
        else
            box.set_bottom(trRewBox, trPeakPx)
    string rTxt = tpHit ? "+" + str.tostring(trRR) + "R" : (closeR >= 0 ? "+" : "") + str.tostring(closeR, "#.##") + "R"
    if not tpHit and ranR >= 0.999
        rTxt += "  (reached 1:" + str.tostring(math.floor(ranR + 0.001)) + ")"
    color rCol = closeR > 0 ? color.new(#14532d, 0) : closeR < 0 ? color.new(#7f1d1d, 0) : color.new(#1c1c1c, 0)
    label rl = label.new(trPeakBar, trPeakPx, rTxt, style = trDir == 1 ? label.style_label_down : label.style_label_up, color = rCol, textcolor = color.white, size = size.small, tooltip = closeWhy + "\nPlanned target was 1:" + str.tostring(trRR) + " at " + str.tostring(trTp, format.mintick) + "\nFurthest run before the exit: " + str.tostring(ranR, "#.##") + "R")
    f_keepLabel(rl)
    f_clearTradeDrawings()
    trState := 0
    lastEndBar := bar_index

// ============================ STEP 2: REGISTER LIQUIDITY ============================
if C
    // 1-2. swing highs and lows, merged into equal highs / lows when they line up
    if not na(ph)
        bool mergedH = false
        if levels.size() > 0
            for i = levels.size() - 1 to 0
                Level lv = levels.get(i)
                if lv.dir == 1 and na(lv.piercedBar) and math.abs(lv.price - ph) <= EQ_TOL * atr
                    if lv.touchBar < bar_index - P_PIVR
                        lv.touches += 1
                        lv.touchBar := bar_index - P_PIVR
                    mergedH := true
                    break
        if not mergedH
            f_addLevel(ph, 1, bar_index - P_PIVR, time[P_PIVR], 1, "Swing high")
    if not na(pl)
        bool mergedL = false
        if levels.size() > 0
            for i = levels.size() - 1 to 0
                Level lv = levels.get(i)
                if lv.dir == -1 and na(lv.piercedBar) and math.abs(lv.price - pl) <= EQ_TOL * atr
                    if lv.touchBar < bar_index - P_PIVR
                        lv.touches += 1
                        lv.touchBar := bar_index - P_PIVR
                    mergedL := true
                    break
        if not mergedL
            f_addLevel(pl, -1, bar_index - P_PIVR, time[P_PIVR], 1, "Swing low")

    // 3. prior day / week / month
    if timeframe.isintraday and not na(pdH) and (na(pdH[1]) or pdH != pdH[1] or pdL != pdL[1])
        f_replace("Prior day high", pdH, 1, 3)
        f_replace("Prior day low", pdL, -1, 3)
    if tfSec < 604800 and not na(pwH) and (na(pwH[1]) or pwH != pwH[1] or pwL != pwL[1])
        f_replace("Prior week high", pwH, 1, 4)
        f_replace("Prior week low", pwL, -1, 4)
    if tfSec < 2592000 and not na(pmH) and (na(pmH[1]) or pmH != pmH[1] or pmL != pmL[1])
        f_replace("Prior month high", pmH, 1, 4)
        f_replace("Prior month low", pmL, -1, 4)

    // 4-5. sessions
    if useSessions and asEnd
        f_replace("Asia high", asH, 1, 2)
        f_replace("Asia low", asL, -1, 2)
    if useSessions and loEnd
        f_replace("London high", loH, 1, 2)
        f_replace("London low", loL, -1, 2)
    if useSessions and onEnd
        f_replace("Overnight high", onH, 1, 3)
        f_replace("Overnight low", onL, -1, 3)
    if useSessions and orEnd
        f_replace("Opening range high", orH, 1, 2)
        f_replace("Opening range low", orL, -1, 2)

    // 6. higher timeframe swings
    if not na(hPH) and (na(hPH[1]) or hPH != hPH[1]) and high < hPH
        f_addLevel(hPH, 1, bar_index, time, 3, "HTF swing high")
    if not na(hPL) and (na(hPL[1]) or hPL != hPL[1]) and low > hPL
        f_addLevel(hPL, -1, bar_index, time, 3, "HTF swing low")

// 8. volume profile, built bar by bar and closed out at each new session
var map<int, float> vp = map.new<int, float>()
var float binSz = na
var int vpMin = na
var int vpMax = na
if na(binSz) and close > 0
    binSz := math.max(syminfo.mintick, math.round_to_mintick(close * 0.00025))
if C and not na(binSz)
    if newSess and vp.size() > 0
        [pocP, vahP, valP] = f_profile(vp, vpMin, vpMax, binSz)
        f_replace("Value area high", vahP, 1, 2)
        f_replace("Value area low", valP, -1, 2)
        f_addLevel(pocP, 0, bar_index, time, 2, "Naked POC")
        vp.clear()
        vpMin := na
        vpMax := na
    int bLo = math.floor(low / binSz)
    int bHi = math.floor(high / binSz)
    if bHi - bLo <= 500
        float share = vol / (bHi - bLo + 1)
        for b = bLo to bHi
            vp.put(b, nz(vp.get(b)) + share)
        vpMin := na(vpMin) ? bLo : math.min(vpMin, bLo)
        vpMax := na(vpMax) ? bHi : math.max(vpMax, bHi)

// 9. unfilled fair value gaps
if C
    if bullFvg
        gaps.push(Gap.new(low, high[2], 1, bar_index))
    if bearFvg
        gaps.push(Gap.new(low[2], high, -1, bar_index))
    if gaps.size() > 0
        for i = gaps.size() - 1 to 0
            Gap g = gaps.get(i)
            bool filled = bar_index > g.bornBar and (g.dir == 1 ? low <= g.bot : high >= g.top)
            if filled or bar_index - g.bornBar > FVG_AGE
                gaps.remove(i)
    if gaps.size() > 40
        gaps.shift()

// ============================ STEP 3: DETECT SWEEPS (10-12, 24-25) ==================
int    cDir    = 0
float  cPrice  = na
float  cExt    = na
float  cQ      = -1.0
string cTag    = ""
int    cPierce = na
int    cBorn   = na

if C and levels.size() > 0
    for i = levels.size() - 1 to 0
        Level lv = levels.get(i)
        if bar_index <= lv.bornBar
            continue
        if lv.dir == 0
            // a naked POC is retired once price trades through it
            if high >= lv.price and low <= lv.price
                levels.remove(i)
            continue
        if na(lv.piercedBar)
            bool poked = lv.dir == 1 ? high > lv.price : low < lv.price
            if poked
                lv.piercedBar := bar_index
                lv.ext := lv.dir == 1 ? high : low
        else
            lv.ext := lv.dir == 1 ? math.max(lv.ext, high) : math.min(lv.ext, low)
        if not na(lv.piercedBar)
            float pen = math.abs(lv.ext - lv.price) / atr
            bool back = lv.dir == 1 ? close < lv.price : close > lv.price
            if pen > PEN_MAX
                // 11. too deep: a breakout, not a sweep
                levels.remove(i)
            else if back
                if pen >= PEN_MIN
                    float reach = lv.dir == 1 ? (lv.price - reachLo) / atr : (reachHi - lv.price) / atr
                    float q = f_quality(lv, reach)
                    if q > cQ
                        cQ := q
                        cDir := -lv.dir
                        cPrice := lv.price
                        cExt := lv.ext
                        cTag := f_tagText(lv)
                        cPierce := lv.piercedBar
                        cBorn := lv.bornTime
                    // 25. one signal per level: it is retired either way
                    levels.remove(i)
                else
                    // too shallow to be a sweep: count it as another touch
                    lv.touches += 1
                    lv.touchBar := bar_index
                    lv.price := lv.ext
                    lv.piercedBar := na
                    lv.ext := na
            else if bar_index - lv.piercedBar >= P_RECLAIM
                // 12. no reclaim in time: price was accepted beyond the level
                levels.remove(i)

// ============================ STEP 4: BUILD AND CONFIRM THE SETUP ===================
bool cooled = na(lastEndBar) or bar_index - lastEndBar >= P_COOL
if C and cDir != 0 and cQ >= P_MINQ and trState == 0 and cooled
    suDir    := cDir
    suLvl    := cPrice
    suExt    := cExt
    suQ      := cQ
    suPen    := math.abs(cExt - cPrice) / atr
    suTag    := cTag
    suBar    := bar_index
    suPierce := cPierce
    suBorn   := cBorn
    suDisp   := false
    suMss    := false
    suFvg    := false
    suMssLvl := cDir == -1 ? lastML : lastMH
    suRvol   := rvMax >= RVOL_MIN
    suDelta  := cDir == -1 ? d2 < 0 : d2 > 0
    suSmt    := cDir == -1 ? smtBear : smtBull

if C and suDir != 0 and trState == 0
    bool invalid = bar_index > suBar and (suDir == -1 ? high > suExt : low < suExt)
    bool expired = bar_index - suBar > P_CONFIRM
    if invalid or expired
        suDir := 0
    else
        // 15-17. confirmation evidence builds while the setup is alive
        bool dispNow = suDir == -1 ? bearDisp : bullDisp
        if dispNow
            suDisp := true
        bool mssNow = not na(suMssLvl) and (suDir == -1 ? close < suMssLvl : close > suMssLvl)
        if mssNow
            suMss := true
        bool fvgNow = (suDir == -1 ? bearFvg : bullFvg) and bar_index - 1 >= suPierce
        if fvgNow
            suFvg := true

        // 18-23. context
        bool kBias = bias == suDir
        bool kPd   = suDir == -1 ? suLvl > pdEq : suLvl < pdEq
        bool kVwap = suDir == -1 ? suExt > vw : suExt < vw
        bool useTime = timeframe.isintraday

        int pts = (suRvol ? 1 : 0) + (suDelta ? 1 : 0) + (suDisp ? 1 : 0) + (suMss ? 1 : 0) + (suFvg ? 1 : 0) + (kBias ? 1 : 0) + (kPd ? 1 : 0) + (volOk ? 1 : 0) + (kVwap ? 1 : 0) + ((useTime and inWindow) ? 1 : 0) + ((smtLive and suSmt) ? 1 : 0)
        int ptsMax = 9 + (useTime ? 1 : 0) + (smtLive ? 1 : 0)
        float score = pts * 1.0 / ptsMax

        // a signal needs a real reaction (displacement or a structure shift), enough
        // confluence, and must not sit inside a scheduled news minute
        bool gate = (suDisp or suMss) and not inNews and score >= P_SCORE
        if gate
            float entryPx = close
            // 26. every stop is the same size: P_STOP x ATR from entry. The sweep wick plus its
            //     buffer has to fit inside that distance, otherwise the signal is skipped.
            float wickRisk = math.abs(entryPx - (suDir == -1 ? suExt + STOP_BUF * atr : suExt - STOP_BUF * atr))
            float riskPx = P_STOP * atr
            float stopPx = suDir == -1 ? entryPx + riskPx : entryPx - riskPx
            if riskPx > 0 and wickRisk <= riskPx
                // 27-28. the target is the liquidity pool this setup is aiming at, never less
                // than 1:1. Standard confluence aims at the nearest pool, high confluence at
                // the nearest major pool, very high confluence at the major pool after that.
                [rrAll, tagAll] = f_pools(suDir, entryPx, riskPx, false)
                [rrMaj, tagMaj] = f_pools(suDir, entryPx, riskPx, true)
                bool hasMaj = rrMaj.size() > 0
                float rrw = na
                string tTag = ""
                string conf = score >= 0.72 ? "very high" : score >= 0.60 ? "high" : "standard"
                if score < P_TIER1 or (not hasMaj and rrAll.size() == 0)
                    if rrAll.size() > 0
                        array<int> ordA = rrAll.sort_indices()
                        int kA = ordA.get(0)
                        rrw := rrAll.get(kA)
                        tTag := tagAll.get(kA)
                else
                    array<float> srcR = hasMaj ? rrMaj : rrAll
                    array<string> srcT = hasMaj ? tagMaj : tagAll
                    array<int> ordS = srcR.sort_indices()
                    int kS = ordS.get((score >= P_TIER2 and srcR.size() > 1) ? 1 : 0)
                    rrw := srcR.get(kS)
                    tTag := srcT.get(kS)
                if na(rrw) and not na(rStep)
                    float off = TP_OFF * atr
                    float rn = suDir == 1 ? math.ceil((entryPx + riskPx / HAIR + off) / rStep) * rStep : math.floor((entryPx - riskPx / HAIR - off) / rStep) * rStep
                    rrw := (math.abs(rn - entryPx) - off) / riskPx
                    tTag := "Round number"
                if na(rrw)
                    rrw := 1.0 / HAIR
                    tTag := "1:1 minimum"
                int rrN = math.min(math.max(1, math.floor(rrw * HAIR + 0.000001)), R_CAP)

                trDir     := suDir
                trEntry   := entryPx
                trStop    := stopPx
                trRisk    := riskPx
                trRR      := HW ? HW_RR : rrN
                trTp      := entryPx + suDir * riskPx * trRR
                trPeakPx  := entryPx
                trPeakBar := bar_index
                trFillBar := bar_index
                trState   := 2

                string side = trDir == 1 ? "LONG" : "SHORT"
                string why = "WHY THIS " + side
                why += "\nSwept: " + suTag + " at " + str.tostring(suLvl, format.mintick)
                why += "\nWick went " + str.tostring(suPen, "#.##") + " ATR past it, then closed back inside after " + str.tostring(suBar - suPierce) + " bar(s)"
                why += "\nLevel quality " + str.tostring(suQ, "#") + "/100"
                why += "\nConfidence: " + conf + " (" + str.tostring(pts) + " of " + str.tostring(ptsMax) + " checks)"
                why += "\n"
                why += "\nDisplacement candle: " + f_mk(true, suDisp)
                why += "\nStructure shift: " + f_mk(true, suMss)
                why += "\nFair value gap left behind: " + f_mk(true, suFvg)
                why += "\nVolume spike on the sweep: " + f_mk(true, suRvol)
                why += "\nLower timeframe delta agrees: " + f_mk(true, suDelta)
                why += "\nHigher timeframe bias agrees: " + f_mk(true, kBias)
                why += "\nRight side of the range (premium / discount): " + f_mk(true, kPd)
                why += "\nRight side of VWAP: " + f_mk(true, kVwap)
                why += "\nVolatility healthy: " + f_mk(true, volOk)
                why += "\nActive hours: " + f_mk(useTime, inWindow)
                why += "\nSMT divergence: " + f_mk(smtLive, suSmt)
                why += "\n"
                why += "\nRisk 1 : Reward " + str.tostring(trRR)
                why += "\nEntry " + str.tostring(trEntry, format.mintick)
                why += "\nStop " + str.tostring(trStop, format.mintick) + " (" + str.tostring(P_STOP) + " ATR from entry, beyond the sweep wick, never moves)"
                why += "\nTarget " + str.tostring(trTp, format.mintick) + " (in front of: " + tTag + ")"

                label sl = label.new(bar_index, trDir == 1 ? low : high, (trDir == 1 ? "▲ LSE LONG  1:" : "▼ LSE SHORT  1:") + str.tostring(trRR), style = trDir == 1 ? label.style_label_up : label.style_label_down, color = color.new(#1c1c1c, 0), textcolor = color.white, size = size.small, tooltip = why)
                f_keepLabel(sl)
                trRiskBox := box.new(bar_index, math.max(trEntry, trStop), bar_index + 1, math.min(trEntry, trStop), border_color = color.new(#e05a5a, 100), bgcolor = color.new(#e05a5a, 45))
                trRewBox := box.new(bar_index, math.max(trEntry, trTp), bar_index + 1, math.min(trEntry, trTp), border_color = color.new(#6abf69, 100), bgcolor = color.new(#6abf69, 45))
                f_keepBox(trRiskBox)
                f_keepBox(trRewBox)
                f_clearTradeDrawings()
                f_tradeLine(trStop, color.new(#e05a5a, 0), "SL " + str.tostring(trStop, format.mintick), true)
                f_tradeLine(trEntry, color.new(#2962ff, 0), "LSE ENTRY " + str.tostring(trEntry, format.mintick), true)
                if trRR >= 1
                    for n = 1 to math.floor(trRR)
                        float rungPx = trEntry + trDir * trRisk * n
                        bool last = n == math.floor(trRR)
                        f_tradeLine(rungPx, color.new(#2e9e6b, 0), last ? "TP 1:" + str.tostring(n) + "  " + str.tostring(rungPx, format.mintick) : "1:" + str.tostring(n), last)
                else
                    f_tradeLine(trTp, color.new(#2e9e6b, 0), "TP " + str.tostring(trTp, format.mintick), true)
                if i_liqLine and not na(suBorn)
                    f_keepLine(line.new(suBorn, suLvl, time, suLvl, xloc = xloc.bar_time, color = color.new(#111111, 0), width = 1))
                alert("LSE " + side + " " + syminfo.ticker + " | entry " + str.tostring(trEntry, format.mintick) + " | stop " + str.tostring(trStop, format.mintick) + " | target " + str.tostring(trTp, format.mintick) + " | 1:" + str.tostring(trRR), alert.freq_once_per_bar_close)
                suDir := 0

// ====================================== DISPLAY =====================================
barcolor(i_candles ? (close >= open ? color.new(#2962ff, 0) : color.new(#111111, 0)) : color(na))

// ============================ ENTRY SIGNAL AT THE FRONT OF THE MARKET ===============
// Not a confirmed sweep signal. When no sweep trade is open, exactly one entry is shown
// at the latest bars, in the direction of the higher timeframe trend. It is locked at the
// close of the bar where it prints. When it ends, or when a sweep trade opens, it is
// removed from the chart, so only confirmed trades remain as history.
var int   idState   = 0
var int   idDir     = 0
var float idEntry   = na
var float idStop    = na
var float idTp      = na
var float idRR      = 1.0
var int   idBar     = na
var box   idRiskBox = na
var box   idRewBox  = na
var label idLbl     = na
var array<label> idTags = array.new<label>()
var int   nIdeas    = 0
var int   nIdeaHit  = 0

f_clearIdea() =>
    box.delete(idRiskBox)
    box.delete(idRewBox)
    label.delete(idLbl)
    while idTags.size() > 0
        label.delete(idTags.pop())
    true

f_ideaTag(float p, color c, string txt) =>
    idTags.push(label.new(bar_index + 10, p, txt + " " + str.tostring(p, format.mintick), style = label.style_none, textcolor = c, size = size.tiny))
    true

if C and idState == 1 and bar_index > idBar
    bool idSL = idDir == 1 ? low <= idStop : high >= idStop
    bool idTP = idDir == 1 ? high >= idTp : low <= idTp
    bool idTime = bar_index - idBar >= P_HOLD * math.min(math.max(idRR, 1.0), HOLD_CAP)
    if idSL or idTP or idTime
        nIdeas += 1
        if idTP and not idSL
            nIdeaHit += 1
        f_clearIdea()
        idState := 0
    else if trState == 2
        // a confirmed sweep trade has taken over the front of the market
        f_clearIdea()
        idState := 0
    else
        box.set_right(idRiskBox, bar_index + 1)
        box.set_right(idRewBox, bar_index + 1)

if C and i_now and idState == 0 and trState == 0 and not na(atr)
    int dNow = bias != 0 ? bias : close >= vw ? 1 : -1
    float rNow = P_STOP * atr
    [rrNowArr, tagNowArr] = f_pools(dNow, close, rNow, false)
    float rrNow = 1.0
    string tagNow = "1:1 minimum"
    if rrNowArr.size() > 0
        array<int> ordN = rrNowArr.sort_indices()
        int kN = ordN.get(0)
        rrNow := math.min(math.max(1, math.floor(rrNowArr.get(kN) + 0.000001)), R_CAP)
        tagNow := tagNowArr.get(kN)
    if HW
        rrNow := HW_RR
        tagNow := "one fifth of the stop"
    idDir   := dNow
    idEntry := close
    idStop  := close - dNow * rNow
    idTp    := close + dNow * rNow * rrNow
    idRR    := rrNow
    idBar   := bar_index
    idState := 1
    string tipNow = "ENTRY AT THE FRONT OF THE MARKET, not a confirmed sweep signal"
    tipNow += "\nLocked at this bar's close. Entry, stop and target do not move."
    tipNow += "\nDirection follows the higher timeframe trend" + (bias == 0 ? " (no trend yet, using the VWAP side)" : "")
    tipNow += "\nEntry " + str.tostring(idEntry, format.mintick)
    tipNow += "\nStop " + str.tostring(idStop, format.mintick) + " (" + str.tostring(P_STOP) + " ATR)"
    tipNow += "\nTarget " + str.tostring(idTp, format.mintick) + " (" + tagNow + ")"
    idRiskBox := box.new(bar_index, math.max(idEntry, idStop), bar_index + 1, math.min(idEntry, idStop), border_color = color.new(#e05a5a, 30), border_style = line.style_dashed, bgcolor = color.new(#e05a5a, 78))
    idRewBox := box.new(bar_index, math.max(idEntry, idTp), bar_index + 1, math.min(idEntry, idTp), border_color = color.new(#2e9e6b, 30), border_style = line.style_dashed, bgcolor = color.new(#6abf69, 78))
    idLbl := label.new(bar_index, dNow == 1 ? low : high, (dNow == 1 ? "▲ NOW LONG  1:" : "▼ NOW SHORT  1:") + str.tostring(rrNow), style = dNow == 1 ? label.style_label_up : label.style_label_down, color = color.new(#1c1c1c, 25), textcolor = color.white, size = size.small, tooltip = tipNow)
    f_ideaTag(idStop, color.new(#e05a5a, 0), "SL")
    f_ideaTag(idEntry, color.new(#2962ff, 0), "ENTRY")
    f_ideaTag(idTp, color.new(#2e9e6b, 0), "TP")

var table statBox = table.new(position.bottom_right, 2, 5, bgcolor = color.new(#1c1c1c, 10), border_width = 0)
f_pct(int hit, int total) => total > 0 ? str.tostring(100.0 * hit / total, "#") + "%" : "n/a"
f_stat(int r, string k, string v, color c) =>
    table.cell(statBox, 0, r, k, text_color = color.silver, text_size = size.small, text_halign = text.align_left)
    table.cell(statBox, 1, r, v, text_color = c, text_size = size.small, text_halign = text.align_right)
if barstate.islast and i_stats
    float avgR = nTrades > 0 ? sumR / nTrades : na
    string statusTxt = trState == 2 ? "In a sweep trade" : suDir != 0 ? "Sweep seen, confirming" : idState == 1 ? "Front entry open" : "Scanning"
    f_stat(0, "Trades", str.tostring(nTrades), color.white)
    f_stat(1, "Win rate (hit target)", f_pct(nTpHit, nTrades), color.white)
    f_stat(2, "Avg R per trade", na(avgR) ? "n/a" : (avgR >= 0 ? "+" : "") + str.tostring(avgR, "#.##"), na(avgR) ? color.white : avgR > 0.02 ? color.lime : avgR < -0.02 ? color.red : color.white)
    f_stat(3, "Front entries hit target", nIdeas > 0 ? f_pct(nIdeaHit, nIdeas) + " of " + str.tostring(nIdeas) : "n/a", color.white)
    f_stat(4, "Status", statusTxt, trState == 2 ? color.yellow : color.silver)
````
