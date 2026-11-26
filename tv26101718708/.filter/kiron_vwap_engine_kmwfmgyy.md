# KIRON VWAP Engine

- url: https://www.tradingview.com/script/KmwfmgyY-KIRON-VWAP-Engine/
- type: indicator
- pine_id: PUB;31b32452fef246f3a82c3f7eac458ecc
- version: 1.0

## Description

OVERVIEW

KIRON VWAP Engine is a multi-anchor Volume Weighted Average Price framework that combines a high-precision VWAP calculation, volume-weighted standard deviation bands, prior-period reference levels and a rules-based signal layer in a single overlay. It is designed for intraday traders who use VWAP as a fair-value reference and want to see trend state, stretch from value and structured setups in one place.

WHAT MAKES IT DIFFERENT

1. Intrabar Precision
Standard VWAP implementations treat each chart bar as a single price (typically HLC3). On 15-minute or hourly charts, that approximation can misplace volume within the bar. In Intrabar mode, this script rebuilds every chart bar from lower-timeframe data (1-minute by default), computing the bar's volume-weighted mean price and mean squared price from its constituent intrabars. Both the VWAP and its deviation bands are therefore calculated from finer-grained volume distribution. Where lower-timeframe history is unavailable (TradingView limits intrabar requests to roughly 100,000 bars), the script automatically falls back to chart-bar data. Select "Chart" precision to compute the full history on a uniform basis.

2. External Volume Source
Spot and CFD symbols frequently report broker tick volume rather than traded volume. The optional External Volume setting weights the chart's prices using another symbol's volume, for example applying exchange-traded futures volume to a spot chart. Bars where the external symbol has no data carry zero weight.

3. Volume-Weighted Deviation Bands
Bands are calculated from the volume-weighted variance of price around the VWAP (sigma = sqrt(sum(P^2 x V) / sum(V) - VWAP^2)), plotted at three user-defined multiples (1, 2 and 3 by default). The zone between bands 2 and 3 is shaded to highlight statistically stretched conditions.

4. Clean Anchor Handling
Nothing is plotted until the first complete anchor period begins, so partial periods at the start of chart history are never displayed. Connecting segments at each reset are hidden to avoid misleading diagonal lines.

FEATURES

Primary VWAP
Anchored to a selectable period (Daily by default). The line colour reflects slope state: rising, falling or flat. Slope is measured over a configurable lookback and normalised by ATR, so small tick-by-tick changes do not cause colour flicker.

Weekly VWAP
Higher-timeframe fair-value reference for swing context and confluence.

Previous Period VWAP
The final VWAP value of the prior period, carried forward as a horizontal reference. The level displays at full strength while untested and fades once price trades through it.

Event Anchors (intraday only)
- London Open (default 08:00 Europe/London)
- COMEX Open (default 08:20 America/New_York)
- Custom Anchor (any date and time)
Each resets on the first bar whose close passes the specified time, so the anchor works correctly on any intraday timeframe.

Information Table
- Current VWAP value
- Distance from VWAP in standard deviations
- Slope state
- Distance from Weekly VWAP in weekly standard deviations
- Previous period VWAP and whether it has been tested
- Most recent signal and bars elapsed

SIGNAL LOGIC
Signals are confirmed on bar close only and do not repaint. Each includes a suggested stop and two targets, displayed in the label tooltip and optionally drawn as lines on the chart.

Trend Pullback (PB)
Conditions for a long (shorts are the mirror image):
- VWAP slope is rising
- Price pulls back to the VWAP without breaking the second lower band
- No bar closes below the first lower band during the setup
- A bullish bar closes back above the VWAP, either with a lower rejection wick meeting the minimum size or by reclaiming the VWAP from a prior close at or below it
Stop: beyond the setup swing low plus an ATR buffer
Target 1: upper band 1
Target 2: upper band 2

Mean Reversion (MR)
Conditions for a short (longs are the mirror image):
- VWAP slope is flat
- Price tags the second upper band
- A bearish bar closes back inside band 2, either with an upper rejection wick or re-entering from a prior close outside the band
Stop: beyond the setup swing high plus an ATR buffer
Target 1: band 1, or halfway to the VWAP
Target 2: the VWAP
Mean Reversion signals are suppressed while the VWAP is trending, to avoid fading directional moves.

Signal Filters
- Warm-up period: no signals for a set number of bars after each reset
- One signal per setup: after a Pullback signal, price must close beyond band 1 before another fires in the same direction; after a Mean Reversion signal, price must return to the VWAP
- Minimum reward-to-risk to Target 2 (default 1.0)
- Optional Weekly VWAP filter: longs only above the Weekly VWAP, shorts only below

HOW TO USE
1. Apply to an intraday chart. The default settings are designed around 5-minute to 15-minute charts with a Daily anchor.
2. Read the slope colour first. A rising or falling VWAP indicates directional participation; a flat VWAP indicates balance.
3. In trending conditions, treat the VWAP and first band as the value zone for continuation entries. Price holding band 2 or 3 in a strong trend is not in itself a reversal signal.
4. In balanced conditions, bands 2 and 3 mark statistically stretched prices, with the VWAP as the reversion target.
5. Use untested prior-period VWAPs and Weekly VWAP confluence as additional reference levels.
6. Treat signals as structured setups to be evaluated alongside your own analysis, not as standalone instructions.

SETTINGS
Core: source, primary anchor, precision mode, intrabar timeframe, external volume symbol
Deviation Bands: visibility and multiplier for each band
Additional Anchors: Weekly, Previous Period, London, COMEX and Custom anchor times
Signals: setup types, warm-up bars, setup window, minimum rejection wick, Weekly filter, stop buffer, minimum R:R, level line length
Style: slope sensitivity, line width, colours, table visibility

ALERTS
- BUY Signal / SELL Signal
- VWAP Cross Up / VWAP Cross Down
- Upper Band 2 Tag / Lower Band 2 Tag
- Previous VWAP Tagged
For alert messages containing entry, stop, targets and R:R, create an alert using the "Any alert() function call" condition.

LIMITATIONS
- VWAP accuracy depends on the volume supplied by the data feed. Symbols without reliable volume will produce a less meaningful VWAP; the script stops with an error if the feed provides no volume at all.
- Intrabar precision applies only where lower-timeframe history is available.
- When using external volume, differences in trading hours between the chart symbol and the volume symbol reduce weighting during non-overlapping periods.
- Signal conditions are rule-based and do not account for news, liquidity or broader market context.

DISCLAIMER
This script is provided for educational and informational purposes only and does not constitute financial advice. Past behaviour of price relative to VWAP does not guarantee future results. Always apply your own risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KironKavanagh

//@version=6
indicator("KIRON VWAP Engine", "KVWAP", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ═══════════════════════════ INPUTS ═══════════════════════════
const string G_CORE = "Core"
float  src       = input.source(hlc3, "Source", group = G_CORE)
string anchorTF  = input.timeframe("D", "Primary Anchor", group = G_CORE)
string precision = input.string("Intrabar", "Precision", options = ["Intrabar", "Chart"], group = G_CORE, tooltip = "Intrabar: each chart bar is rebuilt from lower-timeframe bars, giving a true volume-weighted price and variance. Chart: one price per bar (same as TradingView's built-in). Intrabar falls back to Chart where lower-timeframe history runs out.")
string ltfIn     = input.timeframe("1", "Intrabar Timeframe", group = G_CORE)
bool   useExtVol = input.bool(false, "External Volume", group = G_CORE, inline = "ext")
string extSym    = input.symbol("COMEX:GC1!", "", group = G_CORE, inline = "ext", tooltip = "Weight prices with another symbol's volume, e.g. COMEX gold futures on an XAUUSD chart. Bars where that symbol has no data carry zero weight.")

const string G_BAND = "Deviation Bands"
bool  showB1 = input.bool(true, "Band 1  ×σ", group = G_BAND, inline = "b1")
float m1     = input.float(1.0, "", minval = 0.1, step = 0.1, group = G_BAND, inline = "b1")
bool  showB2 = input.bool(true, "Band 2  ×σ", group = G_BAND, inline = "b2")
float m2     = input.float(2.0, "", minval = 0.1, step = 0.1, group = G_BAND, inline = "b2")
bool  showB3 = input.bool(true, "Band 3  ×σ", group = G_BAND, inline = "b3")
float m3     = input.float(3.0, "", minval = 0.1, step = 0.1, group = G_BAND, inline = "b3")

const string G_ANC = "Additional Anchors"
bool showW    = input.bool(true,  "Weekly VWAP", group = G_ANC)
bool showPrev = input.bool(true,  "Previous Period VWAP (fades once tested)", group = G_ANC)
bool showLdn  = input.bool(false, "London Open", group = G_ANC, inline = "ldn")
int  ldnH     = input.int(8, "", 0, 23, group = G_ANC, inline = "ldn")
int  ldnM     = input.int(0, ":", 0, 59, group = G_ANC, inline = "ldn", tooltip = "Europe/London time")
bool showNY   = input.bool(false, "COMEX Open", group = G_ANC, inline = "ny")
int  nyH      = input.int(8, "", 0, 23, group = G_ANC, inline = "ny")
int  nyM      = input.int(20, ":", 0, 59, group = G_ANC, inline = "ny", tooltip = "America/New_York time")
bool showC    = input.bool(false, "Custom Anchor", group = G_ANC, inline = "c")
int  custT    = input.time(timestamp("2026-09-01T00:00:00+00:00"), "", group = G_ANC, inline = "c")

const string G_SIG = "Signals"
bool  showSig  = input.bool(true, "Show Signals", group = G_SIG)
bool  usePB    = input.bool(true, "Trend Pullback", group = G_SIG, inline = "st")
bool  useMR    = input.bool(true, "Mean Reversion", group = G_SIG, inline = "st")
int   warmup   = input.int(3, "Warm-up Bars After Reset", minval = 0, group = G_SIG)
int   sigWin   = input.int(3, "Setup Window (bars)", minval = 1, maxval = 20, group = G_SIG, tooltip = "How many bars back the zone touch or band tag may be before the trigger bar.")
float wickMin  = input.float(0.30, "Min Rejection Wick (× bar range)", minval = 0, maxval = 1, step = 0.05, group = G_SIG)
bool  wkFilt   = input.bool(false, "Weekly VWAP Filter", group = G_SIG, tooltip = "Longs only above the weekly VWAP, shorts only below.")
float stopBuf  = input.float(0.25, "Stop Buffer (× ATR)", minval = 0, step = 0.05, group = G_SIG)
float minRR    = input.float(1.0, "Min R:R to TP2", minval = 0, step = 0.1, group = G_SIG)
bool  showLvls = input.bool(true, "Draw SL / TP Lines  — bars", group = G_SIG, inline = "lv")
int   lvlLen   = input.int(20, "", minval = 1, maxval = 200, group = G_SIG, inline = "lv")

const string G_STY = "Style"
int   slopeLen = input.int(5, "Slope Lookback", minval = 1, maxval = 50, group = G_STY)
float slopeThr = input.float(0.10, "Flat Threshold (×ATR)", minval = 0, step = 0.01, group = G_STY)
int   lineW    = input.int(2, "VWAP Width", minval = 1, maxval = 4, group = G_STY)
color colUp    = input.color(#26A69A, "Rising", group = G_STY, inline = "sc")
color colDn    = input.color(#EF5350, "Falling", group = G_STY, inline = "sc")
color colFlat  = input.color(#FFB300, "Flat", group = G_STY, inline = "sc")
color colBand  = input.color(#90A4AE, "Bands", group = G_STY, inline = "bc")
color colExtUp = input.color(#EF5350, "Upper Extreme", group = G_STY, inline = "bc")
color colExtDn = input.color(#26A69A, "Lower Extreme", group = G_STY, inline = "bc")
color colW     = input.color(#42A5F5, "Weekly", group = G_STY, inline = "ac")
color colPrev  = input.color(#FFB300, "Prev", group = G_STY, inline = "ac")
color colLdn   = input.color(#AB47BC, "London", group = G_STY, inline = "ac2")
color colNY    = input.color(#EC407A, "COMEX", group = G_STY, inline = "ac2")
color colC     = input.color(#00BCD4, "Custom", group = G_STY, inline = "ac2")
color colBuy   = input.color(#26A69A, "Buy", group = G_STY, inline = "sg")
color colSell  = input.color(#EF5350, "Sell", group = G_STY, inline = "sg")
color colSL    = input.color(#EF5350, "SL", group = G_STY, inline = "sg")
color colTP    = input.color(#26A69A, "TP", group = G_STY, inline = "sg")
bool  showTbl  = input.bool(true, "Show Table", group = G_STY)

// ═══════════════════════════ BAR PRICE DISTRIBUTION ═══════════════════════════
// Intrabar mode rebuilds each chart bar from lower-timeframe bars: the bar's
// volume-weighted mean price and mean squared price, so both VWAP and σ are exact.
string ltf = precision == "Intrabar" and timeframe.in_seconds(ltfIn) < timeframe.in_seconds(timeframe.period) ? ltfIn : timeframe.period
[ltfP, ltfV] = request.security_lower_tf(syminfo.tickerid, ltf, [src, volume])

float barP  = src
float barP2 = src * src
int   nLtf  = ltfP.size()
if nLtf > 0
    float sV   = 0.0
    float sPV  = 0.0
    float sP2V = 0.0
    float sP   = 0.0
    float sP2  = 0.0
    int   cnt  = 0
    for i = 0 to nLtf - 1
        float p = ltfP.get(i)
        if not na(p)
            float v = nz(ltfV.get(i))
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

// ═══════════════════════════ BAR WEIGHT ═══════════════════════════
string volSym = useExtVol ? extSym : syminfo.tickerid
float  extVol = request.security(volSym, timeframe.period, volume, gaps = barmerge.gaps_on)
float  w      = nz(useExtVol ? extVol : volume)
float  pv     = nz(barP * w)
float  p2v    = nz(barP2 * w)

float cumW = ta.cum(w)
if barstate.islast and cumW == 0
    runtime.error("No volume on this feed. Enable External Volume or use a symbol that provides volume.")

// ═══════════════════════════ ENGINE ═══════════════════════════
// Cumulative ΣPV, ΣP²V, ΣV per anchor. Output is na until the first genuine reset,
// so no partial first period is ever plotted.
vwapEngine(bool reset, float pv, float p2v, float w) =>
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
    sW   += w
    float vw = started and sW > 0 ? sPV / sW : na
    float sd = na(vw) ? na : math.sqrt(math.max(sP2V / sW - vw * vw, 0.0))
    [vw, sd]

// True on the first bar whose close passes the given local clock time.
sessionReset(int hh, int mm, string tz) =>
    int a = timestamp(tz, year(time, tz), month(time, tz), dayofmonth(time, tz), hh, mm)
    time_close > a and nz(time_close[1]) <= a

bool rP = timeframe.change(anchorTF)
bool rW = timeframe.change("W")
bool rL = sessionReset(ldnH, ldnM, "Europe/London")
bool rN = sessionReset(nyH, nyM, "America/New_York")
bool rC = time_close > custT and nz(time_close[1]) <= custT

[vP, sdP] = vwapEngine(rP, pv, p2v, w)
[vW, sdW] = vwapEngine(rW, pv, p2v, w)
[vL, sdL] = vwapEngine(rL, pv, p2v, w)
[vN, sdN] = vwapEngine(rN, pv, p2v, w)
[vC, sdC] = vwapEngine(rC, pv, p2v, w)
max_bars_back(vP, 60)

float u1 = vP + m1 * sdP
float l1 = vP - m1 * sdP
float u2 = vP + m2 * sdP
float l2 = vP - m2 * sdP
float u3 = vP + m3 * sdP
float l3 = vP - m3 * sdP

// ═══════════════════════════ SLOPE STATE ═══════════════════════════
float atr    = ta.atr(14)
int   bsr    = nz(ta.barssince(rP), 0)
int   lb     = math.min(slopeLen, bsr)
float slopeN = lb > 0 and atr > 0 ? (vP - vP[lb]) / atr : 0.0
int   state  = nz(slopeN) > slopeThr ? 1 : nz(slopeN) < -slopeThr ? -1 : 0
color vCol   = state == 1 ? colUp : state == -1 ? colDn : colFlat

// ═══════════════════════════ PREVIOUS PERIOD VWAP ═══════════════════════════
var float pVwap  = na
var bool  pNaked = false
bool pTag = false
if rP
    pVwap  := vP[1]
    pNaked := not na(pVwap)
if pNaked and high >= pVwap and low <= pVwap
    pNaked := false
    pTag   := true

// ═══════════════════════════ SIGNALS ═══════════════════════════
// Trend Pullback: slope trending, price trades back into VWAP (not through band 2),
//   no close beyond band 1, then a bar closes back on the trend side of VWAP with
//   a rejection wick or a VWAP reclaim.  SL beyond setup swing, TP1 band 1, TP2 band 2.
// Mean Reversion: slope flat, price tags band 2, then a bar closes back inside with
//   a rejection wick or re-entry.  SL beyond setup swing, TP1 band 1 / halfway, TP2 VWAP.
// All signals confirm on bar close only (no repaint). One signal per setup.
float rng     = high - low
float loWick  = math.min(open, close) - low
float hiWick  = high - math.max(open, close)
bool  rejL    = rng > 0 and loWick >= wickMin * rng
bool  rejS    = rng > 0 and hiWick >= wickMin * rng

bool  inZoneL = low <= vP and low > l2
bool  inZoneS = high >= vP and high < u2
int   bsZL    = ta.barssince(inZoneL)
int   bsZS    = ta.barssince(inZoneS)
int   bsT2U   = ta.barssince(high >= u2)
int   bsT2L   = ta.barssince(low <= l2)
float minDevL = ta.lowest(close - l1, sigWin + 1)
float maxDevS = ta.highest(close - u1, sigWin + 1)
float swingLo = ta.lowest(low, sigWin + 1)
float swingHi = ta.highest(high, sigWin + 1)
int   winLim  = math.min(sigWin, bsr)

bool pbL = usePB and state == 1  and nz(bsZL, 999) <= winLim and nz(minDevL, -1.0) >= 0 and close > vP and close > open and (rejL or close[1] <= vP)
bool pbS = usePB and state == -1 and nz(bsZS, 999) <= winLim and nz(maxDevS,  1.0) <= 0 and close < vP and close < open and (rejS or close[1] >= vP)
bool mrL = useMR and state == 0  and nz(bsT2L, 999) <= winLim and close > l2 and close < vP and close > open and (rejL or close[1] <= l2)
bool mrS = useMR and state == 0  and nz(bsT2U, 999) <= winLim and close < u2 and close > vP and close < open and (rejS or close[1] >= u2)

// One signal per setup: re-arm only once price has moved away / reached target.
var bool armPBL = true
var bool armPBS = true
var bool armMRL = true
var bool armMRS = true
if rP
    armPBL := true
    armPBS := true
    armMRL := true
    armMRS := true
if close > u1
    armPBL := true
if close < l1
    armPBS := true
if close >= vP
    armMRL := true
if close <= vP
    armMRS := true

bool base  = showSig and barstate.isconfirmed and not na(vP) and sdP > 0 and bsr >= warmup and not rP
bool wkOkL = not wkFilt or na(vW) or close > vW
bool wkOkS = not wkFilt or na(vW) or close < vW
float buf  = stopBuf * nz(atr)

int    dir = 0
string typ = ""
float  sl  = na
float  tp1 = na
float  tp2 = na
if base and wkOkL and armPBL and pbL
    dir := 1
    typ := "PB"
    sl  := swingLo - buf
    tp1 := close < u1 ? u1 : (close + u2) / 2
    tp2 := u2
else if base and wkOkL and armMRL and mrL
    dir := 1
    typ := "MR"
    sl  := swingLo - buf
    tp1 := close < l1 ? l1 : (close + vP) / 2
    tp2 := vP
else if base and wkOkS and armPBS and pbS
    dir := -1
    typ := "PB"
    sl  := swingHi + buf
    tp1 := close > l1 ? l1 : (close + l2) / 2
    tp2 := l2
else if base and wkOkS and armMRS and mrS
    dir := -1
    typ := "MR"
    sl  := swingHi + buf
    tp1 := close > u1 ? u1 : (close + vP) / 2
    tp2 := vP

float risk = dir == 1 ? close - sl  : dir == -1 ? sl - close  : na
float rew  = dir == 1 ? tp2 - close : dir == -1 ? close - tp2 : na
bool  rrOk = dir != 0 and risk > 0 and rew > 0 and rew / risk >= minRR
bool  sigL = dir == 1 and rrOk
bool  sigS = dir == -1 and rrOk

var string lastTxt = "—"
var color  lastCol = color.gray
var int    lastBar = na

if sigL or sigS
    bool   isL  = sigL
    string side = isL ? "BUY" : "SELL"
    string name = typ == "PB" ? "Trend Pullback" : "Mean Reversion"
    float  rr   = rew / risk
    string info = side + " · " + name + "\nEntry " + str.tostring(close, format.mintick) + "\nSL " + str.tostring(sl, format.mintick) + "\nTP1 " + str.tostring(tp1, format.mintick) + "\nTP2 " + str.tostring(tp2, format.mintick) + "\nR:R " + str.tostring(rr, "0.0")
    label.new(bar_index, isL ? low : high, side + " " + typ, yloc = isL ? yloc.belowbar : yloc.abovebar, style = isL ? label.style_label_up : label.style_label_down, color = isL ? colBuy : colSell, textcolor = color.white, size = size.small, tooltip = info)
    if showLvls
        line.new(bar_index, sl,  bar_index + lvlLen, sl,  color = colSL, style = line.style_dashed, width = 1)
        line.new(bar_index, tp1, bar_index + lvlLen, tp1, color = colTP, style = line.style_dotted, width = 1)
        line.new(bar_index, tp2, bar_index + lvlLen, tp2, color = colTP, style = line.style_dashed, width = 1)
    alert(syminfo.ticker + " " + side + " " + name + " @ " + str.tostring(close, format.mintick) + " | SL " + str.tostring(sl, format.mintick) + " | TP1 " + str.tostring(tp1, format.mintick) + " | TP2 " + str.tostring(tp2, format.mintick) + " | R:R " + str.tostring(rr, "0.0"), alert.freq_once_per_bar_close)
    if typ == "PB"
        armPBL := isL ? false : armPBL
        armPBS := isL ? armPBS : false
    else
        armMRL := isL ? false : armMRL
        armMRS := isL ? armMRS : false
    lastTxt := side + " " + typ
    lastCol := isL ? colBuy : colSell
    lastBar := bar_index

// ═══════════════════════════ PLOTS ═══════════════════════════
color bc = rP ? na : color.new(colBand, 45)

plot(vP, "VWAP", rP ? na : vCol, lineW)
pU1 = plot(showB1 ? u1 : na, "Upper 1", bc, 1, display = display.pane)
pL1 = plot(showB1 ? l1 : na, "Lower 1", bc, 1, display = display.pane)
pU2 = plot(showB2 ? u2 : na, "Upper 2", bc, 1, display = display.pane)
pL2 = plot(showB2 ? l2 : na, "Lower 2", bc, 1, display = display.pane)
pU3 = plot(showB3 ? u3 : na, "Upper 3", bc, 1, display = display.pane)
pL3 = plot(showB3 ? l3 : na, "Lower 3", bc, 1, display = display.pane)
fill(pU1, pL1, color = rP ? na : color.new(colBand, 93), title = "Value Area")
fill(pU2, pU3, color = rP ? na : color.new(colExtUp, 88), title = "Upper Extreme")
fill(pL2, pL3, color = rP ? na : color.new(colExtDn, 88), title = "Lower Extreme")

bool intra = timeframe.isintraday
plot(showW ? vW : na, "Weekly VWAP", rW ? na : colW, 1)
plot(showPrev ? pVwap : na, "Prev VWAP", rP ? na : pNaked ? colPrev : color.new(colPrev, 75), 1)
plot(showLdn and intra ? vL : na, "London VWAP", rL ? na : colLdn, 1)
plot(showNY and intra ? vN : na, "COMEX VWAP", rN ? na : colNY, 1)
plot(showC ? vC : na, "Custom VWAP", rC ? na : colC, 1)

// ═══════════════════════════ TABLE ═══════════════════════════
var table tbl = table.new(position.top_right, 2, 6, bgcolor = color.new(#131722, 10), border_color = color.new(#90A4AE, 80), border_width = 1)

fmtZ(float price, float vw, float sd) =>
    float z = sd > 0 ? (price - vw) / sd : na
    na(z) ? "—" : (z >= 0 ? "+" : "") + str.tostring(z, "0.00") + "σ"

cellRow(int r, string k, string v, color vc) =>
    table.cell(tbl, 0, r, k, text_color = #B2B5BE, text_size = size.small, text_halign = text.align_left)
    table.cell(tbl, 1, r, v, text_color = vc, text_size = size.small, text_halign = text.align_right)

if showTbl and barstate.islast
    string sTxt = state == 1 ? "Rising" : state == -1 ? "Falling" : "Flat"
    string sigTxt = na(lastBar) ? "—" : lastTxt + "  " + str.tostring(bar_index - lastBar) + " bars ago"
    cellRow(0, "VWAP", str.tostring(vP, format.mintick), vCol)
    cellRow(1, "Distance", fmtZ(close, vP, sdP), #D1D4DC)
    cellRow(2, "Slope", sTxt, vCol)
    cellRow(3, "Weekly", fmtZ(close, vW, sdW), colW)
    cellRow(4, "Prev VWAP", na(pVwap) ? "—" : str.tostring(pVwap, format.mintick) + (pNaked ? "  naked" : "  tested"), pNaked ? colPrev : color.gray)
    cellRow(5, "Last Signal", sigTxt, na(lastBar) ? color.gray : lastCol)

// ═══════════════════════════ ALERTS ═══════════════════════════
bool xUp = ta.crossover(close, vP)
bool xDn = ta.crossunder(close, vP)
bool tU2 = ta.crossover(high, u2)
bool tL2 = ta.crossunder(low, l2)
alertcondition(sigL, "BUY Signal", "{{ticker}} VWAP BUY signal")
alertcondition(sigS, "SELL Signal", "{{ticker}} VWAP SELL signal")
alertcondition(xUp and not rP, "VWAP Cross Up", "{{ticker}} closed above VWAP")
alertcondition(xDn and not rP, "VWAP Cross Down", "{{ticker}} closed below VWAP")
alertcondition(tU2 and not rP, "Upper Band 2 Tag", "{{ticker}} tagged upper band 2")
alertcondition(tL2 and not rP, "Lower Band 2 Tag", "{{ticker}} tagged lower band 2")
alertcondition(pTag, "Previous VWAP Tagged", "{{ticker}} tagged the previous-period VWAP")
````
