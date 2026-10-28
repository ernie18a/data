# KIRON Flow

- url: https://www.tradingview.com/script/EI3onoax-KIRON-Flow/
- type: indicator
- pine_id: PUB;83bd3eafd5964bc6ab5d1e9c3576c251
- version: 1.0

## Description

OVERVIEW

KIRON Flow is an order-flow confirmation indicator that estimates buying and selling aggression from intrabar data and evaluates it against session VWAP structure. It plots session Cumulative Volume Delta (CVD) as candles, detects absorption and CVD divergence at key VWAP levels, prints its own two-stage reversal signals, and can grade signals from its companion indicator, KIRON VWAP Engine, as confirmed or unconfirmed by order flow.

The two indicators are designed to answer different questions. KIRON VWAP Engine shows where price is relative to volume-weighted fair value and when a structured setup has formed. KIRON Flow shows whether aggressive participation supports that setup. Each works on its own; used together, they separate setups that have order-flow support from those that do not.

HOW IT WORKS

1. Intrabar Delta Estimation
TradingView does not provide bid/ask trade data, so delta is estimated from lower-timeframe bars (1-minute by default). For each intrabar, volume is split between buyers and sellers using one of two methods:
- Close Location (default): delta = volume x (2 x close - high - low) / (high - low). An intrabar closing at its high counts as fully buyer-initiated, at its low fully seller-initiated, and proportionally in between.
- Up/Down Bar: all of an intrabar's volume is assigned by its direction.
Intrabars with no range fall back to a tick rule, comparing the close with the prior intrabar's close. Summing intrabar deltas gives each chart bar's delta.

2. CVD Candles
Delta accumulates into a session CVD that resets on the same anchor as the VWAP (Daily by default). Each CVD candle opens at the prior cumulative value and closes at the new one. Its high and low are the extremes of the running cumulative delta through the bar's intrabars, so wicks show how far aggression pushed within the bar, not just where it finished. Candle brightness reflects relative volume: bright candles are high-RVOL bars, faded candles are normal. A Bar Delta histogram view is available as an alternative.

3. Time-of-Day Relative Volume
Relative volume compares each bar's volume with the average volume of the same time slot over recent sessions (10 by default), not a rolling average of recent bars. Intraday volume is uneven, with surges at session opens and scheduled data, so time-of-day normalisation avoids treating every session open as abnormal.

4. Session VWAP and Bands
KIRON Flow calculates the same volume-weighted VWAP and standard deviation bands as KIRON VWAP Engine, using identical maths and intrabar precision. These levels define where absorption and divergence are assessed. Match the Anchor, Precision, External Volume and band settings between the two indicators so the levels align.

5. External Volume Source
Spot and CFD feeds often report tick volume. When External Volume is enabled, delta is calculated from another symbol's intrabar data (for example, exchange-traded futures on a spot chart), and that symbol's volume also weights the VWAP.

EVENTS

Absorption (A)
Aggressive volume that fails to move price at a key level. All of the following must be true:
- Relative volume at or above the threshold (1.5x by default)
- Bar range no larger than 0.8 x ATR(14)
- Delta opposes the close: for bullish absorption, delta is negative (sellers aggressive) but the bar closes in the upper half of its range; bearish is the mirror
- The bar interacts with a key level: for bullish absorption, it dips to the VWAP and closes on or above it, or trades into lower band 2; bearish is the mirror at the VWAP from below or upper band 2
Interpretation: passive buyers (or sellers) are absorbing aggressive orders at the level.

CVD Divergence (D)
Price reaches a new N-bar extreme (20 bars by default) at least a set number of bars (3 by default) after the previous extreme, inside the selected band zone, while CVD fails to exceed its value at the previous extreme. The comparison uses the intrabar CVD high or low at each extreme. References reset each session, so divergences never compare across sessions.
Interpretation: price is extending while aggressive participation is fading.

FLOW SIGNALS
KIRON Flow's own signals use a two-stage structure: an event creates a setup, and a separate bar must confirm it.

FLOW BUY
Stage 1: a bullish absorption or bullish divergence arms the setup.
Stage 2: within the trigger window (5 bars by default), a bar must close:
- above its open
- above the prior close
- with positive delta
- above lower band 2
The setup is cancelled if price closes below the event bar's low or the window expires. Only one signal fires per setup.

FLOW SELL
The exact mirror, armed by bearish absorption or bearish divergence.

Levels (shown in the label tooltip)
- Stop: beyond the extreme since the event, plus an ATR buffer (0.25 x ATR by default)
- Target 1: the next VWAP level in the trade direction (VWAP, then band 1, then band 2)
- Target 2: the level after Target 1

KIRON VWAP ENGINE (COMPANION)
KIRON VWAP Engine is a multi-anchor VWAP overlay:
- Intrabar-precision VWAP with volume-weighted standard deviation bands at 1, 2 and 3 sigma
- Weekly VWAP, and the previous period's VWAP with untested/tested status
- Optional London, COMEX and custom time anchors
- A slope state (rising, falling or flat, normalised by ATR)
- Two rule-based signal types:
  - Trend Pullback (PB): in a trending VWAP, price pulls back to the VWAP without closing beyond band 1, then closes back on the trend side with a rejection wick or a VWAP reclaim.
  - Mean Reversion (MR): in a flat VWAP, price tags band 2, then closes back inside with rejection.
Engine signals confirm on bar close, include stop and target levels, and require a minimum reward-to-risk.

HOW THE TWO WORK TOGETHER

Signal Link
KIRON VWAP Engine outputs its signals as a hidden plot named "Signal":
- 1 = Pullback long
- 2 = Mean Reversion long
- -1 = Pullback short
- -2 = Mean Reversion short
- 0 = no signal
KIRON Flow reads this plot through a source input and grades each engine signal on the bar it prints.

Grading Rules
Pullback signals are CONFIRMED when:
- delta on the signal bar agrees with the trade direction, and
- CVD held a higher low through the pullback (lower high for shorts), compared with the lowest (highest) CVD over the prior swing window. If the session is too young to measure the prior swing, only the delta condition is applied.
Mean Reversion signals are CONFIRMED when a divergence or absorption in the trade direction occurred within the confirmation window (5 bars by default).
Any signal that fails is marked UNCONFIRMED.

Display
- Confirmed signals: a check mark in the Flow pane, plus a coloured background highlight on the price chart
- Unconfirmed signals: a grey cross in the Flow pane

Setup
1. Add KIRON VWAP Engine and KIRON Flow to the same chart.
2. In KIRON Flow settings, enable "Grade KVWAP Signals".
3. Set "KVWAP Signal Source" to "KVWAP: Signal".
4. Match Anchor, Precision, External Volume and band multipliers across both indicators.
The Flow table shows "Source not linked" if the source is set incorrectly.

Suggested Workflow
1. Read the VWAP Engine slope. Rising or falling favours Trend Pullback setups; flat favours Mean Reversion at band 2.
2. Read session CVD for context. Rising CVD with price above VWAP indicates buyer control; falling CVD with price below VWAP indicates seller control.
3. Prioritise engine signals that KIRON Flow grades as confirmed.
4. Treat FLOW BUY / FLOW SELL signals as counter-move entries at levels. They carry the most context when aligned with the engine's regime, for example a FLOW SELL at the upper band while the VWAP is flat, or a FLOW BUY at the VWAP while the VWAP is rising.
5. Be cautious with Flow reversal signals against a strongly trending VWAP.

TABLE
- Session CVD and whether buyers or sellers are in control
- Current bar delta
- Relative volume
- Delta data source: Intrabar, or Bar estimate where intrabar history is unavailable
- Last event and bars elapsed
- Last Flow signal
- Last graded engine signal

SETTINGS
Core: anchor, VWAP source, precision, intrabar timeframe, external volume symbol, band multipliers
Delta: estimation method, display mode (CVD Candles or Bar Delta)
Relative Volume: lookback sessions, high-RVOL threshold
Events: divergence lookback, minimum bars between extremes, divergence zone, absorption range limit, price-chart markers
Flow Signals: visibility, price-chart labels, trigger window, stop buffer
KIRON VWAP Link: grading toggle, signal source, confirmation window, prior swing lookback, price-chart highlight
Style: colours, table visibility

ALERTS
- Flow BUY / Flow SELL
- Confirmed KVWAP BUY / Confirmed KVWAP SELL
- Bullish / Bearish CVD Divergence
- Bullish / Bearish Absorption
For Flow signal alerts that include entry, stop and targets, create an alert using the "Any alert() function call" condition.

LIMITATIONS
- Delta is an estimate derived from intrabar OHLCV, not exchange bid/ask trade data. Its quality depends on the data feed; tick-volume feeds produce a weaker approximation than exchange volume.
- Intrabar data is limited by TradingView's lower-timeframe history. Older bars use a chart-bar estimate, shown as "Bar estimate" in the table.
- Relative volume requires several sessions of history per time slot before readings stabilise.
- When using external volume, bars where the external symbol has no data carry zero weight, and differences in trading hours reduce coverage.
- All signals and grades are rule-based, confirm on bar close, and do not account for news, liquidity conditions or broader market context.

DISCLAIMER
This script is provided for educational and informational purposes only and does not constitute financial advice. Order-flow estimates and historical signal behaviour do not guarantee future results. Always apply your own risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KironKavanagh

//@version=6
indicator("KIRON Flow", "KFLOW", overlay = false, format = format.volume, max_labels_count = 500)

// ═══════════════════════════ INPUTS ═══════════════════════════
const string G_CORE = "Core — match KIRON VWAP Engine"
string anchorTF  = input.timeframe("D", "Anchor Period", group = G_CORE)
float  src       = input.source(hlc3, "VWAP Source", group = G_CORE)
string precision = input.string("Intrabar", "VWAP Precision", options = ["Intrabar", "Chart"], group = G_CORE)
string ltfIn     = input.timeframe("1", "Intrabar Timeframe", group = G_CORE)
bool   useExtVol = input.bool(false, "External Volume", group = G_CORE, inline = "ext")
string extSym    = input.symbol("COMEX:GC1!", "", group = G_CORE, inline = "ext", tooltip = "When on, delta is calculated from this symbol's intrabar data and its volume weights the VWAP. Use exchange futures (e.g. COMEX:GC1!) on a spot gold chart for real traded volume.")
float  m1        = input.float(1.0, "Band 1 ×σ", minval = 0.1, step = 0.1, group = G_CORE, inline = "bm")
float  m2        = input.float(2.0, "Band 2 ×σ", minval = 0.1, step = 0.1, group = G_CORE, inline = "bm")

const string G_DELTA = "Delta"
string dMethod  = input.string("Close Location", "Delta Method", options = ["Close Location", "Up/Down Bar"], group = G_DELTA, tooltip = "Close Location splits each intrabar's volume between buyers and sellers by where it closed within its range. Up/Down Bar assigns all of each intrabar's volume by its direction.")
string dispMode = input.string("CVD Candles", "Display", options = ["CVD Candles", "Bar Delta"], group = G_DELTA)

const string G_RV = "Relative Volume (time of day)"
int   rvDays = input.int(10, "Lookback Sessions", minval = 2, maxval = 50, group = G_RV)
float rvHigh = input.float(1.5, "High RVOL Threshold", minval = 1.0, step = 0.1, group = G_RV)

const string G_EV = "Events"
bool   showDiv   = input.bool(true, "Divergence", group = G_EV)
int    divLen    = input.int(20, "New High/Low Lookback", minval = 5, maxval = 200, group = G_EV)
int    divGap    = input.int(3, "Min Bars Between Extremes", minval = 2, maxval = 100, group = G_EV)
string divZone   = input.string("Band 1", "Divergence Zone", options = ["Band 1", "Band 2"], group = G_EV, tooltip = "Divergence only counts when the new extreme reaches this band.")
bool   showAbs   = input.bool(true, "Absorption", group = G_EV)
float  absRng    = input.float(0.8, "Absorption Max Range (× ATR)", minval = 0.1, step = 0.1, group = G_EV)
bool   markPrice = input.bool(true, "Mark Events on Price Chart", group = G_EV)

const string G_FS = "Flow Signals"
bool  showFSig = input.bool(true, "Show Flow Signals", group = G_FS, tooltip = "BUY: a bullish absorption or divergence, then a bar that closes up with positive delta before price closes below the event low. SELL is the mirror.")
bool  fsPrice  = input.bool(true, "Print on Price Chart", group = G_FS)
int   fsWin    = input.int(5, "Trigger Window (bars)", minval = 1, maxval = 30, group = G_FS)
float fsBuf    = input.float(0.25, "Stop Buffer (× ATR)", minval = 0, step = 0.05, group = G_FS)

const string G_LINK = "KIRON VWAP Link"
bool  linkSig  = input.bool(false, "Grade KVWAP Signals", group = G_LINK)
float sigSrc   = input.source(close, "KVWAP Signal Source", group = G_LINK, tooltip = "Select 'KVWAP: Signal' from the KIRON VWAP Engine on the same chart.")
int   confWin  = input.int(5, "Confirmation Window (bars)", minval = 1, maxval = 30, group = G_LINK)
int   priorLen = input.int(20, "Prior Swing Lookback (bars)", minval = 5, maxval = 200, group = G_LINK)
bool  hlConf   = input.bool(true, "Highlight Confirmed Signals on Price Chart", group = G_LINK)

const string G_STY = "Style"
color colPos  = input.color(#26A69A, "Buyers", group = G_STY, inline = "c1")
color colNeg  = input.color(#EF5350, "Sellers", group = G_STY, inline = "c1")
color colAbs  = input.color(#FFB300, "Absorption", group = G_STY, inline = "c2")
color colDiv  = input.color(#AB47BC, "Divergence", group = G_STY, inline = "c2")
color colFB   = input.color(#00BCD4, "Flow Buy", group = G_STY, inline = "c3")
color colFS   = input.color(#EC407A, "Flow Sell", group = G_STY, inline = "c3")
bool  showTbl = input.bool(true, "Show Table", group = G_STY)

// ═══════════════════════════ TYPES ═══════════════════════════
type VolHist
    array<float> v

// ═══════════════════════════ DATA ═══════════════════════════
string ltf     = timeframe.in_seconds(ltfIn) < timeframe.in_seconds(timeframe.period) ? ltfIn : timeframe.period
string flowSym = useExtVol ? extSym : syminfo.tickerid

// Chart-symbol intrabars → VWAP price distribution
[pA, vA] = request.security_lower_tf(syminfo.tickerid, ltf, [src, volume])
// Flow-symbol intrabars → delta
[oA, hA, lA, cA, fvA] = request.security_lower_tf(flowSym, ltf, [open, high, low, close, volume])
// Flow-symbol bar volume → VWAP weight / RVOL
float extVol = request.security(flowSym, timeframe.period, volume, gaps = barmerge.gaps_on)
float w      = nz(useExtVol ? extVol : volume)

float cumW = ta.cum(w)
if barstate.islast and cumW == 0
    runtime.error("No volume on this feed. Enable External Volume or use a symbol that provides volume.")

// ═══════════════════════════ VWAP (same maths as KIRON VWAP Engine) ═══════════════════════════
float barP  = src
float barP2 = src * src
int   nP    = pA.size()
if precision == "Intrabar" and nP > 0
    float sV   = 0.0
    float sPV  = 0.0
    float sP2V = 0.0
    float sP   = 0.0
    float sP2  = 0.0
    int   cnt  = 0
    for i = 0 to nP - 1
        float p = pA.get(i)
        if not na(p)
            float v = nz(vA.get(i))
            sV   += v
            sPV  += p * v
            sP2V += p * p * v
            sP   += p
            sP2  += p * p
            cnt  += 1
    if sV > 0
        barP  := sPV / sV
        barP2 := sP2V / sV
    else if cnt > 0
        barP  := sP / cnt
        barP2 := sP2 / cnt

vwapEngine(bool reset, float pv, float p2v, float wt) =>
    var bool  started = false
    var float sPV     = 0.0
    var float sP2V    = 0.0
    var float sW      = 0.0
    if reset
        started := true
        sPV     := 0.0
        sP2V    := 0.0
        sW      := 0.0
    sPV  += pv
    sP2V += p2v
    sW   += wt
    float vw = started and sW > 0 ? sPV / sW : na
    float sd = na(vw) ? na : math.sqrt(math.max(sP2V / sW - vw * vw, 0.0))
    [vw, sd]

bool rP = timeframe.change(anchorTF)
[vP, sdP] = vwapEngine(rP, nz(barP * w), nz(barP2 * w), w)
float u1 = vP + m1 * sdP
float l1 = vP - m1 * sdP
float u2 = vP + m2 * sdP
float l2 = vP - m2 * sdP

// ═══════════════════════════ DELTA ═══════════════════════════
// Per-bar delta built from intrabars, with the intrabar running path kept so the
// CVD candle has true highs and lows. Falls back to the chart bar where intrabar
// history is unavailable.
float bDelta = 0.0
float runHi  = 0.0
float runLo  = 0.0
int   nF     = cA.size()
bool  ibData = nF > 0
if ibData
    float run = 0.0
    for i = 0 to nF - 1
        float c_ = cA.get(i)
        if not na(c_)
            float o_  = nz(oA.get(i), c_)
            float h_  = nz(hA.get(i), c_)
            float l_  = nz(lA.get(i), c_)
            float v_  = nz(fvA.get(i))
            float r_  = h_ - l_
            float pc_ = i > 0 ? nz(cA.get(i - 1), o_) : o_
            int   tk_ = c_ > pc_ ? 1 : c_ < pc_ ? -1 : 0
            float d_  = 0.0
            if dMethod == "Close Location"
                d_ := r_ > 0 ? v_ * (2 * c_ - h_ - l_) / r_ : v_ * tk_
            else
                d_ := c_ > o_ ? v_ : c_ < o_ ? -v_ : v_ * tk_
            run   += d_
            runHi := math.max(runHi, run)
            runLo := math.min(runLo, run)
    bDelta := run
else
    float r   = high - low
    float pc  = nz(close[1], open)
    int   tk  = close > pc ? 1 : close < pc ? -1 : 0
    float clv = r > 0 ? (2 * close - high - low) / r : tk
    bDelta := dMethod == "Close Location" ? w * clv : close > open ? w : close < open ? -w : w * tk
    runHi  := math.max(0.0, bDelta)
    runLo  := math.min(0.0, bDelta)

// ═══════════════════════════ SESSION CVD ═══════════════════════════
var bool  cvdOn = false
var float cvd   = 0.0
if rP
    cvdOn := true
    cvd   := 0.0
float cvdStart = cvd
cvd += bDelta
float cvdO = cvdOn ? cvdStart : na
float cvdC = cvdOn ? cvd : na
float cvdH = cvdOn ? cvdStart + runHi : na
float cvdL = cvdOn ? cvdStart + runLo : na

// ═══════════════════════════ TIME-OF-DAY RVOL ═══════════════════════════
var map<int, VolHist> rvMap = map.new<int, VolHist>()
int     todKey = hour(time) * 60 + minute(time)
VolHist vh     = rvMap.get(todKey)
float   rvAvg  = na
if not na(vh)
    if vh.v.size() > 0
        rvAvg := vh.v.avg()
float rvol = rvAvg > 0 ? w / rvAvg : na
if barstate.isconfirmed
    if na(vh)
        vh := VolHist.new(array.new<float>())
        rvMap.put(todKey, vh)
    vh.v.push(w)
    if vh.v.size() > rvDays
        vh.v.shift()
bool hiVol = nz(rvol) >= rvHigh

// ═══════════════════════════ ABSORPTION ═══════════════════════════
// Aggressive volume into a key level (VWAP or band 2) that fails to move price:
// high RVOL, small range, delta against the close location.
float atr    = ta.atr(14)
float rngB   = high - low
bool  ready  = cvdOn and not na(vP) and sdP > 0 and barstate.isconfirmed
bool  small  = atr > 0 and rngB <= absRng * atr
bool  supLvl = (low <= vP and close >= vP) or low <= l2
bool  resLvl = (high >= vP and close <= vP) or high >= u2
bool  absBull = showAbs and ready and hiVol and small and bDelta < 0 and close >= low + 0.5 * rngB and supLvl
bool  absBear = showAbs and ready and hiVol and small and bDelta > 0 and close <= high - 0.5 * rngB and resLvl

// ═══════════════════════════ DIVERGENCE ═══════════════════════════
// A new N-bar extreme, reached after a pause of at least divGap bars, inside the
// divergence zone, while CVD fails to make the matching extreme.
float zoneU  = divZone == "Band 1" ? u1 : u2
float zoneL  = divZone == "Band 1" ? l1 : l2
float hhRef  = ta.highest(high, divLen)[1]
float llRef  = ta.lowest(low, divLen)[1]
bool  newHi  = high > hhRef
bool  newLo  = low < llRef

var float refHiCvd = na
var int   refHiBar = na
var float refLoCvd = na
var int   refLoBar = na
bool divBear = false
bool divBull = false
if rP
    refHiCvd := na
    refHiBar := na
    refLoCvd := na
    refLoBar := na
if cvdOn and newHi
    if showDiv and ready and not na(refHiCvd) and bar_index - refHiBar >= divGap and cvdH < refHiCvd and high >= zoneU
        divBear := true
    refHiCvd := cvdH
    refHiBar := bar_index
if cvdOn and newLo
    if showDiv and ready and not na(refLoCvd) and bar_index - refLoBar >= divGap and cvdL > refLoCvd and low <= zoneL
        divBull := true
    refLoCvd := cvdL
    refLoBar := bar_index

// ═══════════════════════════ FLOW SIGNALS ═══════════════════════════
// Stage 1 (setup): bullish absorption or divergence arms a buy (bearish arms a sell).
// Stage 2 (trigger): within the window, a bar closes in the setup direction with
//   delta agreeing, above/below the prior close, and back inside band 2.
// Invalidation: a close beyond the setup bar's extreme, or the window expiring.
float fBuf = fsBuf * nz(atr)
var bool   armFL  = false
var int    evLBar = na
var float  evLLow = na
var float  stLo   = na
var string evLTyp = ""
var bool   armFS  = false
var int    evSBar = na
var float  evSHi  = na
var float  stHi   = na
var string evSTyp = ""

if rP
    armFL := false
    armFS := false
if armFL and (close < evLLow or bar_index - evLBar > fsWin)
    armFL := false
if armFS and (close > evSHi or bar_index - evSBar > fsWin)
    armFS := false
if absBull or divBull
    armFL  := true
    evLBar := bar_index
    evLLow := low
    stLo   := low
    evLTyp := absBull ? "Absorption" : "Divergence"
if absBear or divBear
    armFS  := true
    evSBar := bar_index
    evSHi  := high
    stHi   := high
    evSTyp := absBear ? "Absorption" : "Divergence"
if armFL
    stLo := math.min(stLo, low)
if armFS
    stHi := math.max(stHi, high)

bool fBuy  = showFSig and armFL and barstate.isconfirmed and bDelta > 0 and close > open and close > close[1] and close > l2
bool fSell = showFSig and armFS and barstate.isconfirmed and bDelta < 0 and close < open and close < close[1] and close < u2

var string lastFs    = "—"
var color  lastFsCol = color.gray
var int    lastFsBar = na

if fBuy or fSell
    bool   isL  = fBuy
    string side = isL ? "BUY" : "SELL"
    string kind = isL ? evLTyp : evSTyp
    float  sl   = isL ? stLo - fBuf : stHi + fBuf
    float  t1   = isL ? (close < vP ? vP : close < u1 ? u1 : u2) : (close > vP ? vP : close > l1 ? l1 : l2)
    float  t2   = isL ? (close < vP ? u1 : u2) : (close > vP ? l1 : l2)
    float  risk = math.abs(close - sl)
    float  rr   = risk > 0 ? math.abs(t1 - close) / risk : na
    string info = "FLOW " + side + " · after " + kind + "\nEntry " + str.tostring(close, format.mintick) + "\nSL " + str.tostring(sl, format.mintick) + "\nTP1 " + str.tostring(t1, format.mintick) + "\nTP2 " + str.tostring(t2, format.mintick) + "\nR:R to TP1 " + (na(rr) ? "—" : str.tostring(rr, "0.0"))
    if fsPrice
        label.new(bar_index, isL ? low : high, "FLOW " + side, yloc = isL ? yloc.belowbar : yloc.abovebar, style = isL ? label.style_label_up : label.style_label_down, color = isL ? colFB : colFS, textcolor = color.white, size = size.small, tooltip = info, force_overlay = true)
    alert(syminfo.ticker + " FLOW " + side + " after " + kind + " @ " + str.tostring(close, format.mintick) + " | SL " + str.tostring(sl, format.mintick) + " | TP1 " + str.tostring(t1, format.mintick) + " | TP2 " + str.tostring(t2, format.mintick), alert.freq_once_per_bar_close)
    armFL     := isL ? false : armFL
    armFS     := isL ? armFS : false
    lastFs    := side + " (" + kind + ")"
    lastFsCol := isL ? colFB : colFS
    lastFsBar := bar_index

// ═══════════════════════════ KVWAP SIGNAL GRADING ═══════════════════════════
// Signal codes from KIRON VWAP Engine: 1 PB long, 2 MR long, -1 PB short, -2 MR short.
// PB long confirmed: positive delta on the trigger bar and CVD holding a higher low
//   through the pullback versus the prior swing (mirror for shorts).
// MR confirmed: CVD divergence or absorption in the setup direction within the window.
int   bsr      = nz(ta.barssince(rP), 0)
bool  winClean = bsr > confWin + priorLen
float pbCvdLo  = ta.lowest(cvdL, confWin + 1)
float priorLo  = ta.lowest(cvdL, priorLen)[confWin + 1]
float pbCvdHi  = ta.highest(cvdH, confWin + 1)
float priorHi  = ta.highest(cvdH, priorLen)[confWin + 1]
bool  pbLongOk  = bDelta > 0 and (not winClean or pbCvdLo > priorLo)
bool  pbShortOk = bDelta < 0 and (not winClean or pbCvdHi < priorHi)
int   bsDBear   = ta.barssince(divBear)
int   bsDBull   = ta.barssince(divBull)
int   bsABear   = ta.barssince(absBear)
int   bsABull   = ta.barssince(absBull)
bool  mrShortOk = nz(bsDBear, 999) <= confWin or nz(bsABear, 999) <= confWin
bool  mrLongOk  = nz(bsDBull, 999) <= confWin or nz(bsABull, 999) <= confWin

bool linkOk  = linkSig and not na(sigSrc) and math.abs(sigSrc) <= 2
int  sigCode = linkOk ? math.round(sigSrc) : 0
bool isSig   = linkOk and sigCode != 0 and barstate.isconfirmed
bool conf    = sigCode == 1 ? pbLongOk : sigCode == 2 ? mrLongOk : sigCode == -1 ? pbShortOk : sigCode == -2 ? mrShortOk : false
bool gConfL  = isSig and sigCode > 0 and conf
bool gWeakL  = isSig and sigCode > 0 and not conf
bool gConfS  = isSig and sigCode < 0 and conf
bool gWeakS  = isSig and sigCode < 0 and not conf

// ═══════════════════════════ PLOTS ═══════════════════════════
bool  cvdMode = dispMode == "CVD Candles"
color dCol    = bDelta >= 0 ? (hiVol ? colPos : color.new(colPos, 50)) : (hiVol ? colNeg : color.new(colNeg, 50))

plotcandle(cvdMode ? cvdO : na, cvdMode ? cvdH : na, cvdMode ? cvdL : na, cvdMode ? cvdC : na, "CVD", dCol, dCol, bordercolor = dCol)
plot(cvdMode ? na : bDelta, "Bar Delta", dCol, 1, plot.style_columns)
hline(0, "Zero", color.new(color.gray, 60), hline.style_dotted)

plotshape(divBear, "Bearish Divergence", shape.triangledown, location.top, colDiv, text = "D", textcolor = colDiv, size = size.tiny)
plotshape(divBull, "Bullish Divergence", shape.triangleup, location.bottom, colDiv, text = "D", textcolor = colDiv, size = size.tiny)
plotshape(absBear, "Bearish Absorption", shape.diamond, location.top, colAbs, text = "A", textcolor = colAbs, size = size.tiny)
plotshape(absBull, "Bullish Absorption", shape.diamond, location.bottom, colAbs, text = "A", textcolor = colAbs, size = size.tiny)
plotshape(fBuy, "Flow Buy", shape.arrowup, location.bottom, colFB, size = size.normal)
plotshape(fSell, "Flow Sell", shape.arrowdown, location.top, colFS, size = size.normal)
plotshape(gConfL, "Confirmed Buy", shape.labelup, location.bottom, colPos, text = "✓", textcolor = color.white, size = size.small)
plotshape(gWeakL, "Unconfirmed Buy", shape.labelup, location.bottom, color.gray, text = "✗", textcolor = color.white, size = size.small)
plotshape(gConfS, "Confirmed Sell", shape.labeldown, location.top, colNeg, text = "✓", textcolor = color.white, size = size.small)
plotshape(gWeakS, "Unconfirmed Sell", shape.labeldown, location.top, color.gray, text = "✗", textcolor = color.white, size = size.small)

plotshape(markPrice and divBear, "Bearish Divergence (price)", shape.triangledown, location.abovebar, colDiv, text = "D", textcolor = colDiv, size = size.tiny, force_overlay = true)
plotshape(markPrice and divBull, "Bullish Divergence (price)", shape.triangleup, location.belowbar, colDiv, text = "D", textcolor = colDiv, size = size.tiny, force_overlay = true)
plotshape(markPrice and absBear, "Bearish Absorption (price)", shape.diamond, location.abovebar, colAbs, text = "A", textcolor = colAbs, size = size.tiny, force_overlay = true)
plotshape(markPrice and absBull, "Bullish Absorption (price)", shape.diamond, location.belowbar, colAbs, text = "A", textcolor = colAbs, size = size.tiny, force_overlay = true)
bgcolor(hlConf and gConfL ? color.new(colPos, 80) : hlConf and gConfS ? color.new(colNeg, 80) : na, title = "Confirmed KVWAP Signal (price)", force_overlay = true)

// ═══════════════════════════ TABLE ═══════════════════════════
var string lastEv    = "—"
var color  lastEvCol = color.gray
var int    lastEvBar = na
if divBear
    lastEv    := "Bear Divergence"
    lastEvCol := colDiv
    lastEvBar := bar_index
if divBull
    lastEv    := "Bull Divergence"
    lastEvCol := colDiv
    lastEvBar := bar_index
if absBear
    lastEv    := "Bear Absorption"
    lastEvCol := colAbs
    lastEvBar := bar_index
if absBull
    lastEv    := "Bull Absorption"
    lastEvCol := colAbs
    lastEvBar := bar_index

var string lastGr    = "—"
var color  lastGrCol = color.gray
var int    lastGrBar = na
if isSig
    string gSide = sigCode > 0 ? "BUY" : "SELL"
    string gKind = math.abs(sigCode) == 1 ? "PB" : "MR"
    lastGr    := gSide + " " + gKind + (conf ? "  CONFIRMED" : "  UNCONFIRMED")
    lastGrCol := conf ? (sigCode > 0 ? colPos : colNeg) : color.gray
    lastGrBar := bar_index

var table tbl = table.new(position.top_right, 2, 7, bgcolor = color.new(#131722, 10), border_color = color.new(#90A4AE, 80), border_width = 1)

cellRow(int r, string k, string v, color vc) =>
    table.cell(tbl, 0, r, k, text_color = #B2B5BE, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if showTbl and barstate.islast
    string cvdTxt  = na(cvdC) ? "—" : str.tostring(cvdC, format.volume) + (cvdC >= 0 ? "  buyers" : "  sellers")
    string evTxt   = na(lastEvBar) ? "—" : lastEv + "  " + str.tostring(bar_index - lastEvBar) + " bars"
    string fsTxt   = na(lastFsBar) ? "—" : lastFs + "  " + str.tostring(bar_index - lastFsBar) + " bars"
    string linkTxt = not linkSig ? "Off" : not linkOk ? "Source not linked" : na(lastGrBar) ? "Waiting" : lastGr + "  " + str.tostring(bar_index - lastGrBar) + " bars"
    cellRow(0, "Session CVD", cvdTxt, nz(cvdC) >= 0 ? colPos : colNeg)
    cellRow(1, "Bar Delta", str.tostring(bDelta, format.volume), bDelta >= 0 ? colPos : colNeg)
    cellRow(2, "RVOL", na(rvol) ? "—" : str.tostring(rvol, "0.00") + "×", hiVol ? colAbs : #D1D4DC)
    cellRow(3, "Delta Data", ibData ? "Intrabar" : "Bar estimate", ibData ? #D1D4DC : color.gray)
    cellRow(4, "Last Event", evTxt, na(lastEvBar) ? color.gray : lastEvCol)
    cellRow(5, "Flow Signal", fsTxt, na(lastFsBar) ? color.gray : lastFsCol)
    cellRow(6, "KVWAP Signal", linkTxt, linkOk and not na(lastGrBar) ? lastGrCol : color.gray)

// ═══════════════════════════ ALERTS ═══════════════════════════
alertcondition(fBuy, "Flow BUY", "{{ticker}} KIRON Flow BUY")
alertcondition(fSell, "Flow SELL", "{{ticker}} KIRON Flow SELL")
alertcondition(gConfL, "Confirmed KVWAP BUY", "{{ticker}} KVWAP BUY confirmed by order flow")
alertcondition(gConfS, "Confirmed KVWAP SELL", "{{ticker}} KVWAP SELL confirmed by order flow")
alertcondition(divBear, "Bearish CVD Divergence", "{{ticker}} bearish CVD divergence at upper band")
alertcondition(divBull, "Bullish CVD Divergence", "{{ticker}} bullish CVD divergence at lower band")
alertcondition(absBear, "Bearish Absorption", "{{ticker}} bearish absorption at resistance")
alertcondition(absBull, "Bullish Absorption", "{{ticker}} bullish absorption at support")
````
