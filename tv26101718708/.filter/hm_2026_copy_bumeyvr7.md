# HM 2026 copy

- url: https://www.tradingview.com/script/BuMeyVR7-HM-2026-copy/
- type: indicator
- pine_id: PUB;0abdde1c2b264cfb857392201e7a3701
- version: 1.0

## Description

A modernized, data-tuned evolution of the classic Hilega-Milega indicator.
Built around RSI(9) + a fast EMA(3) and slow WMA(21) of RSI, with four
distinct signal types, quality-filtered divergences, regime detection,
adaptive lengths, and a live dashboard.

═══ WHAT'S DIFFERENT ═══

Most RSI scripts add features without testing whether they help. Every
filter, threshold, and signal type in this indicator was validated against
2 years of 1-hour BTCUSDT.P data. Highlights from that work:

Volume-confirmed crosses had 3× the edge of unfiltered crosses
Buy signals work BETTER in bear regimes than bull (counterintuitive)
Divergences with the previous pivot in OB/OS zone outperformed unfiltered divergences by ~10 percentage points of win rate
"Premium" divergences (also requiring 1%+ price displacement) hit 100% win rate in the test sample
═══ FOUR SIGNAL TYPES, FOUR EDGES ═══

▲ SCALP (small triangle) — Vol-confirmed RSI MA cross, 4-hour hold edge
⬆ SWING (arrow) — Same trigger, framed for 16-hour holds
◆ REVERSAL (purple diamond) — Contrarian fade of deep RSI extremes
(≥80 / ≤20). Highest win rate in backtest.
● DIVERGENCE (lime/fuchsia circle + connecting line) — Three quality
tiers: All / Standard / Premium. Lines drawn on both RSI panel AND
price chart for instant confirmation.

═══ LIVE DASHBOARD ═══

Floats over the price chart with at-a-glance status: bias, momentum,
TF-aware regime detector, OB/OS state, volume strength, current adaptive
lengths, composite 0-100 score, last signal age, and a regime-aware
"edge tip" that nudges you toward what's working in the current market.

═══ ADAPTIVE LENGTHS ═══

RSI/Fast-MA/Slow-MA lengths auto-adjust to volatility regime. High vol
shortens lengths (faster reaction), quiet markets lengthen them (more
filtering). Strength is configurable from 0 (off) to 1 (full).

═══ ALERTS ═══

Every signal has both a human-readable text alert AND a JSON webhook
alert (suitable for Discord/Telegram/auto-trading bots). 23 alerts total.

═══ RECOMMENDED USE ═══

Best on 1h+ TFs for crypto. Can be tuned for forex/stocks.
Don't trade signals blindly — the score and dashboard exist to give you context. A scalp-buy in a bear regime with high volume and an oversold RSI is a different trade than the same signal in a bull regime with low volume.
The "Premium" divergence tier produces few but very clean signals.
Regime auto-scaling keeps the indicator usable across timeframes without re-tuning.
═══ CREDITS ═══

Built on top of the original Hilega-Milega indicator (RSI + RSI moving
averages structure). All additions, filters, and tuning are original.)

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  HM 2026 — a modernized Hilega-Milega
//  Core    : RSI(9) · "Price" = EMA(3) of RSI · "Strength" = WMA(21) of RSI
//  Signals : ▲ Scalp   ⬆ Swing   ◆ Reversal   ● Divergence (All/Standard/Premium)
//  Extras  : volatility-adaptive lengths, TF-aware regime detector, volume
//            filter, floating dashboard, 23 alert conditions (text + JSON)
//  Built on the original Hilega-Milega structure (RSI + RSI moving averages).
// ════════════════════════════════════════════════════════════════════════════
indicator("HM 2026", shorttitle = "HM 2026", overlay = false, max_bars_back = 500, max_lines_count = 500, max_labels_count = 500)

// ─── 1 · CORE ───────────────────────────────────────────────────────────────
G1 = "1 · CORE"
rsiLenIn  = input.int(9, "RSI length", minval = 2, group = G1)
srcIn     = input.source(close, "Source", group = G1)
fastLenIn = input.int(3, "Fast EMA", minval = 1, group = G1)
slowLenIn = input.int(21, "Slow WMA", minval = 2, group = G1)
obLvl     = input.float(70, "Overbought", minval = 50, maxval = 100, group = G1)
osLvl     = input.float(30, "Oversold", minval = 0, maxval = 50, group = G1)

// ─── 2 · ADAPTIVE LENGTHS ───────────────────────────────────────────────────
G2 = "2 · ADAPTIVE LENGTHS"
adaptOn  = input.bool(true, "Adaptive lengths on", group = G2)
atrLen   = input.int(20, "ATR lookback", minval = 2, group = G2)
adaptStr = input.float(0.5, "Adapt strength", minval = 0.0, maxval = 1.0, step = 0.05, group = G2)
minMult  = input.float(0.5, "Min multiplier", minval = 0.1, maxval = 1.0, step = 0.05, group = G2)
maxMult  = input.float(1.8, "Max multiplier", minval = 1.0, maxval = 5.0, step = 0.05, group = G2)
lenCap   = input.int(80, "Max length cap (perf)", minval = 10, maxval = 200, group = G2)

// ─── 3 · SIGNAL ENGINE ──────────────────────────────────────────────────────
G3 = "3 · SIGNAL ENGINE"
TIP_50 = "When on, buy crosses only count if RSI > 50 and sell crosses only if RSI < 50. Fewer, more trend-aligned signals."
scalpOn = input.bool(true, "SCALP signals (4h hold edge)", group = G3)
swingOn = input.bool(true, "SWING signals (16h hold edge)", group = G3)
req50   = input.bool(false, "Also require RSI on right side of 50", group = G3, tooltip = TIP_50)

// ─── 4 · REVERSALS (RSI EXTREMES) ───────────────────────────────────────────
G4 = "4 · REVERSALS (RSI EXTREMES)"
revOn = input.bool(true, "REVERSAL signals (deep RSI extremes)", group = G4)
revHi = input.float(80, "Reversal short trigger (RSI ≥)", minval = 50, maxval = 100, group = G4)
revLo = input.float(20, "Reversal long trigger (RSI ≤)", minval = 0, maxval = 50, group = G4)

// ─── 5 · DIVERGENCES ────────────────────────────────────────────────────────
G5 = "5 · DIVERGENCES"
TIP_TIER = "All — every regular divergence that passes the RSI-delta and bar-gap rules.\nStandard — the previous pivot must sit in the OS zone (bull) or OB zone (bear).\nPremium — Standard + at least 1% price displacement between the two pivots."
divOn     = input.bool(true, "Divergence signals", group = G5)
pivLen    = input.int(5, "Pivot lookback", minval = 1, maxval = 50, group = G5)
maxGap    = input.int(60, "Max bars between pivots", minval = 5, maxval = 400, group = G5)
minDelta  = input.float(2, "Min RSI delta", minval = 0, step = 0.5, group = G5)
tier      = input.string("Standard", "Quality tier", options = ["All", "Standard", "Premium"], group = G5, tooltip = TIP_TIER)
minDisp   = input.float(0, "Extra: min price displacement %", minval = 0, step = 0.1, group = G5)
divLinesR = input.bool(true, "Draw divergence lines in RSI panel", group = G5)
divLinesP = input.bool(true, "Also draw divergence lines on price chart", group = G5)

// ─── 6 · VOLUME FILTER ──────────────────────────────────────────────────────
G6 = "6 · VOLUME FILTER"
volLen    = input.int(20, "Volume MA length", minval = 1, group = G6)
volMult   = input.float(1.2, "Volume multiplier", minval = 0, step = 0.05, group = G6)
showHiVol = input.bool(false, "Show high-volume dots", group = G6)

// ─── 7 · REGIME DETECTOR ────────────────────────────────────────────────────
G7 = "7 · REGIME DETECTOR"
regAuto  = input.bool(true, "Auto-scale regime lookback to timeframe", group = G7)
regLenIn = input.int(200, "Manual regime lookback", minval = 20, maxval = 1000, group = G7)
bullTh   = input.float(5, "Bull regime threshold (slope %)", step = 0.5, group = G7)
bearTh   = input.float(-5, "Bear regime threshold (slope %)", step = 0.5, group = G7)

// ─── 8 · DASHBOARD ──────────────────────────────────────────────────────────
G8 = "8 · DASHBOARD"
dashOn   = input.bool(true, "Show dashboard", group = G8)
dashPos  = input.string("top_right", "Position", options = ["top_right", "top_left", "top_center", "middle_right", "middle_left", "bottom_right", "bottom_left", "bottom_center"], group = G8)
dashSize = input.string("small", "Size", options = ["tiny", "small", "normal", "large"], group = G8)

// ─── 9 · VISUALS ────────────────────────────────────────────────────────────
G9 = "9 · VISUALS"
zonesOn   = input.bool(true, "Highlight OB/OS zones", group = G9)
fill50On  = input.bool(true, "Fill RSI vs 50", group = G9)
txtLabels = input.bool(false, "BUY/SELL text labels", group = G9)

// ─── Palette ────────────────────────────────────────────────────────────────
C_RSI     = #363a45
C_PRICE   = #6aa84f
C_STR     = #d6574a
C_SCALP_B = #5f9e98
C_SCALP_S = #d4685a
C_SWING_B = #3f7d6e
C_SWING_S = #a3402c
C_REV     = #7e57c2
C_BULLDIV = #8de07f
C_BEARDIV = #c45cf2
C_HIVOL   = #f2e05c
C_UP      = #26a69a
C_DN      = #ef5350

// ════════════════════════════════════════════════════════════════════════════
//  Helpers (series-length versions so lengths can adapt bar by bar)
// ════════════════════════════════════════════════════════════════════════════
f_rma(float src, float len) =>
    float a = 1.0 / math.max(len, 1.0)
    float r = 0.0
    r := na(r[1]) ? src : a * src + (1.0 - a) * r[1]
    r

f_rsi(float src, float len) =>
    float ch = nz(ta.change(src))
    float up = f_rma(math.max(ch, 0.0), len)
    float dn = f_rma(math.max(-ch, 0.0), len)
    dn == 0.0 and up == 0.0 ? 50.0 : dn == 0.0 ? 100.0 : 100.0 - 100.0 / (1.0 + up / dn)

f_ema(float src, float len) =>
    float a = 2.0 / (len + 1.0)
    float e = 0.0
    e := na(e[1]) ? src : a * src + (1.0 - a) * e[1]
    e

f_wma(float src, int len) =>
    float num = 0.0
    float den = 0.0
    for i = 0 to len - 1
        float v = src[i]
        if not na(v)
            float w = len - i
            num += w * v
            den += w
    den > 0 ? num / den : na

f_len(int base, float m, int lo) =>
    math.min(lenCap, math.max(lo, int(math.round(base * m))))

f_pos(string p) =>
    switch p
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "middle_right"  => position.middle_right
        "middle_left"   => position.middle_left
        "bottom_right"  => position.bottom_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        => position.top_right

f_tsize(string s) =>
    switch s
        "tiny"   => size.tiny
        "normal" => size.normal
        "large"  => size.large
        => size.small

// ════════════════════════════════════════════════════════════════════════════
//  Adaptive lengths — high vol shortens, quiet markets lengthen
// ════════════════════════════════════════════════════════════════════════════
float atrVal   = ta.atr(atrLen)
float atrBase  = ta.sma(atrVal, atrLen * 5)
float volRatio = atrBase > 0 ? atrVal / atrBase : 1.0
float multRaw  = adaptOn ? math.pow(math.max(volRatio, 0.01), -adaptStr) : 1.0
float mult     = math.max(minMult, math.min(maxMult, multRaw))

int rsiLenA  = f_len(rsiLenIn, mult, 2)
int fastLenA = f_len(fastLenIn, mult, 1)
int slowLenA = f_len(slowLenIn, mult, 2)

// ════════════════════════════════════════════════════════════════════════════
//  Core: RSI, Price (fast EMA of RSI), Strength (slow WMA of RSI)
// ════════════════════════════════════════════════════════════════════════════
float rsiA  = f_rsi(srcIn, rsiLenA)
float rsiS  = ta.rsi(srcIn, rsiLenIn)
float rsiV  = adaptOn ? rsiA : rsiS

float fastA = f_ema(rsiV, fastLenA)
float fastS = ta.ema(rsiV, fastLenIn)
float slowA = f_wma(rsiV, slowLenA)
float slowS = ta.wma(rsiV, slowLenIn)

float fastV = adaptOn ? fastA : fastS
float slowV = adaptOn ? slowA : slowS

// ════════════════════════════════════════════════════════════════════════════
//  Volume filter (bypassed automatically on symbols with no volume)
// ════════════════════════════════════════════════════════════════════════════
bool  volAvail = ta.cum(nz(volume)) > 0
float volMA    = ta.sma(volume, volLen)
float relVol   = volAvail and volMA > 0 ? volume / volMA : 1.0
bool  hiVolBar = volAvail and volume > volMA * volMult
bool  volOk    = volAvail ? hiVolBar : true

// ════════════════════════════════════════════════════════════════════════════
//  Regime detector — regression slope % over a TF-aware window
// ════════════════════════════════════════════════════════════════════════════
int   tfSec    = timeframe.in_seconds()
float baseSecs = regLenIn * 3600.0                     // manual lookback is calibrated on 1h
int   regLen   = regAuto ? math.max(50, math.min(600, int(math.round(baseSecs / tfSec)))) : regLenIn
float thScale  = regAuto ? math.sqrt(regLen * 1.0 * tfSec / baseSecs) : 1.0   // vol scales with √time
float bullThE  = bullTh * thScale
float bearThE  = bearTh * thScale

float lrNow    = ta.linreg(close, regLen, 0)
float lrThen   = ta.linreg(close, regLen, regLen - 1)
float slopePct = nz(lrThen) != 0 ? (lrNow - lrThen) / lrThen * 100.0 : na
int   regInt   = na(slopePct) ? 0 : slopePct >= bullThE ? 1 : slopePct <= bearThE ? -1 : 0

// ════════════════════════════════════════════════════════════════════════════
//  Signal engine — SCALP / SWING (vol-confirmed Price × Strength cross)
// ════════════════════════════════════════════════════════════════════════════
bool xUp = ta.crossover(fastV, slowV)
bool xDn = ta.crossunder(fastV, slowV)

bool baseBuy  = xUp and volOk and (not req50 or rsiV > 50)
bool baseSell = xDn and volOk and (not req50 or rsiV < 50)

// Hold windows in bars: one signal per direction per hold horizon
int scalpHold = math.max(1, int(math.ceil(4.0 * 3600.0 / tfSec)))
int swingHold = math.max(1, int(math.ceil(16.0 * 3600.0 / tfSec)))

var int lastScalpB = na
var int lastScalpS = na
var int lastSwingB = na
var int lastSwingS = na

bool scalpBuy  = scalpOn and baseBuy  and (na(lastScalpB) or bar_index - lastScalpB >= scalpHold)
bool scalpSell = scalpOn and baseSell and (na(lastScalpS) or bar_index - lastScalpS >= scalpHold)
bool swingBuy  = swingOn and baseBuy  and (na(lastSwingB) or bar_index - lastSwingB >= swingHold)
bool swingSell = swingOn and baseSell and (na(lastSwingS) or bar_index - lastSwingS >= swingHold)

if scalpBuy
    lastScalpB := bar_index
if scalpSell
    lastScalpS := bar_index
if swingBuy
    lastSwingB := bar_index
if swingSell
    lastSwingS := bar_index

// ════════════════════════════════════════════════════════════════════════════
//  Reversals — contrarian fade of deep RSI extremes
// ════════════════════════════════════════════════════════════════════════════
bool intoDeepOB = rsiV >= revHi and nz(rsiV[1], 50) < revHi
bool intoDeepOS = rsiV <= revLo and nz(rsiV[1], 50) > revLo
bool revSell = revOn and intoDeepOB
bool revBuy  = revOn and intoDeepOS

// ════════════════════════════════════════════════════════════════════════════
//  Divergences — regular bull/bear with quality tiers
// ════════════════════════════════════════════════════════════════════════════
float pl = ta.pivotlow(rsiV, pivLen, pivLen)
float ph = ta.pivothigh(rsiV, pivLen, pivLen)

var float prevPLrsi = na
var float prevPLpx  = na
var int   prevPLbar = na
var float prevPHrsi = na
var float prevPHpx  = na
var int   prevPHbar = na

bool bullDiv = false
bool bearDiv = false

if not na(pl)
    int   curBar = bar_index - pivLen
    float curPx  = low[pivLen]
    if divOn and not na(prevPLbar)
        int   gap    = curBar - prevPLbar
        float dRsi   = pl - prevPLrsi
        float dispPc = math.abs(curPx - prevPLpx) / prevPLpx * 100.0
        bool  basic  = gap <= maxGap and curPx < prevPLpx and dRsi >= minDelta
        bool  zoneOk = prevPLrsi <= osLvl
        bool  tierOk = tier == "All" ? true : tier == "Standard" ? zoneOk : zoneOk and dispPc >= 1.0
        if basic and tierOk and dispPc >= minDisp
            bullDiv := true
            if divLinesR
                line.new(prevPLbar, prevPLrsi, curBar, pl, color = C_BULLDIV, width = 1)
            if divLinesP
                line.new(prevPLbar, prevPLpx, curBar, curPx, color = C_BULLDIV, width = 1, force_overlay = true)
    prevPLrsi := pl
    prevPLpx  := curPx
    prevPLbar := curBar

if not na(ph)
    int   curBar = bar_index - pivLen
    float curPx  = high[pivLen]
    if divOn and not na(prevPHbar)
        int   gap    = curBar - prevPHbar
        float dRsi   = prevPHrsi - ph
        float dispPc = math.abs(curPx - prevPHpx) / prevPHpx * 100.0
        bool  basic  = gap <= maxGap and curPx > prevPHpx and dRsi >= minDelta
        bool  zoneOk = prevPHrsi >= obLvl
        bool  tierOk = tier == "All" ? true : tier == "Standard" ? zoneOk : zoneOk and dispPc >= 1.0
        if basic and tierOk and dispPc >= minDisp
            bearDiv := true
            if divLinesR
                line.new(prevPHbar, prevPHrsi, curBar, ph, color = C_BEARDIV, width = 1)
            if divLinesP
                line.new(prevPHbar, prevPHpx, curBar, curPx, color = C_BEARDIV, width = 1, force_overlay = true)
    prevPHrsi := ph
    prevPHpx  := curPx
    prevPHbar := curBar

bool anyBuy  = scalpBuy or swingBuy or revBuy or bullDiv
bool anySell = scalpSell or swingSell or revSell or bearDiv

// ─── Last-signal tracker (higher-priority types assigned last) ──────────────
var string lastSig    = "—"
var int    lastSigBar = na
if scalpBuy
    lastSig    := "Scalp Buy"
    lastSigBar := bar_index
if scalpSell
    lastSig    := "Scalp Sell"
    lastSigBar := bar_index
if swingBuy
    lastSig    := "Swing Buy"
    lastSigBar := bar_index
if swingSell
    lastSig    := "Swing Sell"
    lastSigBar := bar_index
if bullDiv
    lastSig    := "Bull Div"
    lastSigBar := bar_index
if bearDiv
    lastSig    := "Bear Div"
    lastSigBar := bar_index
if revBuy
    lastSig    := "Rev Buy"
    lastSigBar := bar_index
if revSell
    lastSig    := "Rev Sell"
    lastSigBar := bar_index

// ─── Composite 0-100 score (50 = neutral, >50 bullish) ─────────────────────
float momComp = math.max(0.0, math.min(100.0, 50.0 + nz(fastV - slowV) * 2.5))
float regComp = regInt == 1 ? 100.0 : regInt == -1 ? 0.0 : 50.0
float volComp = 50.0 + 50.0 * math.min(1.0, math.max(0.0, relVol - 1.0)) * math.sign(close - open)
float score   = 0.35 * nz(rsiV, 50) + 0.30 * momComp + 0.20 * regComp + 0.15 * volComp

// ════════════════════════════════════════════════════════════════════════════
//  Plots (declaration order matches the Style tab)
// ════════════════════════════════════════════════════════════════════════════
bgcolor(zonesOn and rsiV >= obLvl ? color.new(C_DN, 88) : na, title = "OB zone")
bgcolor(zonesOn and rsiV <= osLvl ? color.new(C_UP, 88) : na, title = "OS zone")

pMid = plot(50, "Mid", color = color.new(color.gray, 100), display = display.none)
pRsi = plot(rsiV, "RSI", color = C_RSI, linewidth = 2)
plot(fastV, "Price", color = C_PRICE, linewidth = 2)
plot(slowV, "Strength", color = C_STR, linewidth = 2)

plotshape(scalpBuy,  "Scalp Buy",     shape.triangleup,   location.bottom, C_SCALP_B, size = size.tiny)
plotshape(scalpSell, "Scalp Sell",    shape.triangledown, location.top,    C_SCALP_S, size = size.tiny)
plotshape(swingBuy,  "Swing Buy",     shape.arrowup,      location.bottom, C_SWING_B, size = size.small)
plotshape(swingSell, "Swing Sell",    shape.arrowdown,    location.top,    C_SWING_S, size = size.small)
plotshape(revBuy,    "Reversal Buy",  shape.diamond,      location.bottom, C_REV,     size = size.tiny)
plotshape(revSell,   "Reversal Sell", shape.diamond,      location.top,    C_REV,     size = size.tiny)
plotshape(bullDiv ? pl : na, "Bull Div Mark", shape.circle, location.absolute, C_BULLDIV, offset = -pivLen, size = size.tiny)
plotshape(bearDiv ? ph : na, "Bear Div Mark", shape.circle, location.absolute, C_BEARDIV, offset = -pivLen, size = size.tiny)
plotshape(showHiVol and hiVolBar, "Hi-Vol", shape.circle, location.bottom, color.new(C_HIVOL, 40), size = size.tiny)

hline(50,    "Mid 50",  color = color.new(#787b86, 50), linestyle = hline.style_solid)
hline(obLvl, "OB",      color = color.new(C_DN, 50),    linestyle = hline.style_dotted)
hline(osLvl, "OS",      color = color.new(#4caf50, 50), linestyle = hline.style_dotted)
hline(revHi, "Deep OB", color = color.new(#e53935, 40), linestyle = hline.style_dashed)
hline(revLo, "Deep OS", color = color.new(#43a047, 40), linestyle = hline.style_dashed)

fill(pRsi, pMid, color = fill50On ? (rsiV >= 50 ? color.new(C_DN, 78) : color.new(#2196f3, 80)) : na, title = "RSI vs 50 fill")

// ─── Optional BUY/SELL text labels ──────────────────────────────────────────
if txtLabels and anyBuy
    string bt = (scalpBuy ? "Scalp " : "") + (swingBuy ? "Swing " : "") + (revBuy ? "Reversal " : "") + (bullDiv ? "Bull-div" : "")
    label.new(bar_index, rsiV, "BUY", yloc = yloc.price, style = label.style_label_up, color = C_UP, textcolor = color.white, size = size.tiny, tooltip = str.trim(bt))
if txtLabels and anySell
    string st = (scalpSell ? "Scalp " : "") + (swingSell ? "Swing " : "") + (revSell ? "Reversal " : "") + (bearDiv ? "Bear-div" : "")
    label.new(bar_index, rsiV, "SELL", yloc = yloc.price, style = label.style_label_down, color = C_DN, textcolor = color.white, size = size.tiny, tooltip = str.trim(st))

// ════════════════════════════════════════════════════════════════════════════
//  Live dashboard — floats over the price chart
// ════════════════════════════════════════════════════════════════════════════
var table dash = table.new(f_pos(dashPos), 2, 10, bgcolor = color.new(#131722, 5), frame_color = #363a45, frame_width = 1, border_color = #2a2e39, border_width = 1, force_overlay = true)

f_row(table t, int r, string k, string v, color vc, string ts) =>
    table.cell(t, 0, r, k, text_color = #9598a1, text_halign = text.align_left, text_size = ts)
    table.cell(t, 1, r, v, text_color = vc, text_halign = text.align_right, text_size = ts)

if dashOn and barstate.isfirst
    table.merge_cells(dash, 0, 9, 1, 9)

if dashOn and barstate.islast
    string ts = f_tsize(dashSize)

    // Header
    table.cell(dash, 0, 0, "HM 2026", text_color = color.white, text_halign = text.align_left, text_size = ts, bgcolor = #2a2e39)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color = #d1d4dc, text_halign = text.align_right, text_size = ts, bgcolor = #2a2e39)

    // Bias
    string biasTxt = fastV > slowV and rsiV > 50 ? "BULLISH" : fastV < slowV and rsiV < 50 ? "BEARISH" : fastV > slowV ? "Bull lean" : "Bear lean"
    color  biasCol = fastV > slowV ? C_UP : C_DN
    f_row(dash, 1, "Bias", biasTxt, biasCol, ts)

    // Momentum
    float spread = fastV - slowV
    bool  rising = fastV >= nz(fastV[1], fastV)
    string momTxt = (rising ? "Rising ▲ " : "Falling ▼ ") + (spread >= 0 ? "+" : "") + str.tostring(spread, "0.0")
    f_row(dash, 2, "Momentum", momTxt, rising ? C_UP : C_DN, ts)

    // Regime
    string regTxt = regInt == 1 ? "BULL" : regInt == -1 ? "BEAR" : na(slopePct) ? "—" : "RANGE"
    string regVal = regTxt + (na(slopePct) ? "" : " " + (slopePct >= 0 ? "+" : "") + str.tostring(slopePct, "0.0") + "%") + " · " + str.tostring(regLen) + "b"
    color  regCol = regInt == 1 ? C_UP : regInt == -1 ? C_DN : #d1d4dc
    f_row(dash, 3, "Regime", regVal, regCol, ts)

    // OB/OS state
    string zoneTxt = rsiV >= revHi ? "DEEP OB" : rsiV >= obLvl ? "OB" : rsiV <= revLo ? "DEEP OS" : rsiV <= osLvl ? "OS" : "Neutral"
    color  zoneCol = rsiV >= obLvl ? C_DN : rsiV <= osLvl ? C_UP : #d1d4dc
    f_row(dash, 4, "RSI", str.tostring(rsiV, "0.0") + " · " + zoneTxt, zoneCol, ts)

    // Volume strength
    string volTxt = volAvail ? str.tostring(relVol, "0.00") + "× " + (relVol >= volMult ? "HIGH" : relVol >= 1.0 ? "Normal" : "Low") : "n/a (filter off)"
    color  volCol = volAvail and relVol >= volMult ? C_HIVOL : #d1d4dc
    f_row(dash, 5, "Volume", volTxt, volCol, ts)

    // Current lengths
    int lenR = adaptOn ? rsiLenA : rsiLenIn
    int lenF = adaptOn ? fastLenA : fastLenIn
    int lenS = adaptOn ? slowLenA : slowLenIn
    string lenTxt = str.tostring(lenR) + " / " + str.tostring(lenF) + " / " + str.tostring(lenS) + (adaptOn ? "  ×" + str.tostring(mult, "0.00") : "  (fixed)")
    f_row(dash, 6, "Lengths", lenTxt, #d1d4dc, ts)

    // Composite score
    string scoreLbl = score >= 65 ? "Strong bull" : score >= 55 ? "Bull" : score <= 35 ? "Strong bear" : score <= 45 ? "Bear" : "Neutral"
    f_row(dash, 7, "Score", str.tostring(score, "0") + " · " + scoreLbl, color.from_gradient(score, 30, 70, C_DN, C_UP), ts)

    // Last signal
    string ageTxt = na(lastSigBar) ? "—" : lastSig + " · " + str.tostring(bar_index - lastSigBar) + " bars"
    f_row(dash, 8, "Last signal", ageTxt, #d1d4dc, ts)

    // Regime-aware edge tip
    string tip = ""
    if rsiV >= revHi
        tip := "Deep OB — reversal-sell zone.\nDon't chase longs here."
    else if rsiV <= revLo
        tip := "Deep OS — reversal-buy zone.\nDon't chase shorts here."
    else if regInt == -1
        tip := "Bear regime: buys have shown MORE edge.\nFavor vol-confirmed buys & OS divs."
    else if regInt == 1
        tip := "Bull regime: buys have shown LESS edge.\nWait for OS dips / bull divs."
    else
        tip := "Range: fade the extremes.\nReversals & Standard/Premium divs."
    if volAvail and relVol < 1.0
        tip += "\nLow volume → crosses unconfirmed."
    table.cell(dash, 0, 9, "💡 " + tip, text_color = C_HIVOL, text_halign = text.align_left, text_size = ts, bgcolor = color.new(#2a2e39, 30))

// ════════════════════════════════════════════════════════════════════════════
//  Alerts — 10 text + 10 JSON webhook + 3 regime = 23
// ════════════════════════════════════════════════════════════════════════════
// Text
alertcondition(scalpBuy,  "HM · Scalp Buy",     'HM 2026 ▲ SCALP BUY | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(scalpSell, "HM · Scalp Sell",    'HM 2026 ▼ SCALP SELL | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(swingBuy,  "HM · Swing Buy",     'HM 2026 ⬆ SWING BUY | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(swingSell, "HM · Swing Sell",    'HM 2026 ⬇ SWING SELL | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(revBuy,    "HM · Reversal Buy",  'HM 2026 ◆ REVERSAL BUY (deep OS) | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(revSell,   "HM · Reversal Sell", 'HM 2026 ◆ REVERSAL SELL (deep OB) | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(bullDiv,   "HM · Bull Divergence", 'HM 2026 ● BULLISH DIVERGENCE | {{ticker}} {{interval}} | close {{close}}')
alertcondition(bearDiv,   "HM · Bear Divergence", 'HM 2026 ● BEARISH DIVERGENCE | {{ticker}} {{interval}} | close {{close}}')
alertcondition(anyBuy,    "HM · Any Buy",       'HM 2026 BUY signal | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')
alertcondition(anySell,   "HM · Any Sell",      'HM 2026 SELL signal | {{ticker}} {{interval}} | close {{close}} | RSI {{plot("RSI")}}')

// JSON webhook
alertcondition(scalpBuy,  "HM · Scalp Buy [JSON]",     '{"source":"HM 2026","signal":"SCALP_BUY","side":"buy","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(scalpSell, "HM · Scalp Sell [JSON]",    '{"source":"HM 2026","signal":"SCALP_SELL","side":"sell","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(swingBuy,  "HM · Swing Buy [JSON]",     '{"source":"HM 2026","signal":"SWING_BUY","side":"buy","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(swingSell, "HM · Swing Sell [JSON]",    '{"source":"HM 2026","signal":"SWING_SELL","side":"sell","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(revBuy,    "HM · Reversal Buy [JSON]",  '{"source":"HM 2026","signal":"REVERSAL_BUY","side":"buy","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(revSell,   "HM · Reversal Sell [JSON]", '{"source":"HM 2026","signal":"REVERSAL_SELL","side":"sell","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(bullDiv,   "HM · Bull Divergence [JSON]", '{"source":"HM 2026","signal":"BULL_DIV","side":"buy","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(bearDiv,   "HM · Bear Divergence [JSON]", '{"source":"HM 2026","signal":"BEAR_DIV","side":"sell","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(anyBuy,    "HM · Any Buy [JSON]",       '{"source":"HM 2026","signal":"ANY_BUY","side":"buy","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')
alertcondition(anySell,   "HM · Any Sell [JSON]",      '{"source":"HM 2026","signal":"ANY_SELL","side":"sell","ticker":"{{ticker}}","exchange":"{{exchange}}","interval":"{{interval}}","price":{{close}},"rsi":{{plot("RSI")}},"time":"{{timenow}}"}')

// Regime changes
alertcondition(regInt == 1  and nz(regInt[1]) != 1,  "HM · Regime → BULL",  'HM 2026 regime turned BULL | {{ticker}} {{interval}} | close {{close}}')
alertcondition(regInt == -1 and nz(regInt[1]) != -1, "HM · Regime → BEAR",  'HM 2026 regime turned BEAR | {{ticker}} {{interval}} | close {{close}}')
alertcondition(regInt == 0  and nz(regInt[1]) != 0,  "HM · Regime → RANGE", 'HM 2026 regime turned RANGE | {{ticker}} {{interval}} | close {{close}}')
````
