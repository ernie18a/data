# Adaptive Trend Cloud [JOAT]

- url: https://www.tradingview.com/script/ZDiMMDSE-Adaptive-Trend-Cloud-JOAT/
- type: indicator
- pine_id: PUB;4d13423b611e46d7b88c994bc2c8ed43
- version: 1.0

## Description

[b]═══ ADAPTIVE TREND CLOUD [JOAT] ═══[/b]

A volatility-adaptive ATR SuperTrend that breathes with the market. Instead of a fixed multiplier, the band width auto-scales to the live volatility regime, then paints a filled cloud to a signal EMA, colors your candles by trend strength, and drops ATR-anchored SL/TP zones on every confirmed flip. One clean, self-contained trend engine with a cyberpunk chrome readout.

[image]https://www.tradingview.com/x/Haf0hhI7/[/image]

[b]▎ WHAT IT DOES[/b]
It tracks the prevailing trend with a SuperTrend line whose ATR multiplier [i]adapts[/i] to how volatile price currently is — wider in turbulence to avoid whipsaw, tighter in calm to catch turns earlier. The space between that line and a signal EMA is filled as a [b]Trend Cloud[/b], candles are shaded by how far price sits from the line, and momentum-confirmed [b]BUY[/b] / [b]SELL[/b] labels fire only when trend, regime, and momentum agree.

[b]▎ HOW IT WORKS[/b]
• [b]Adaptive multiplier[/b] — current ATR is percentile-ranked against its recent window to place volatility on a 0–1 scale. The base multiplier is then scaled up or down within an adjustable range, so high volatility widens the bands and low volatility narrows them.
• [b]SuperTrend core[/b] — upper and lower bands are built from your chosen price basis (hl2, close, or ohlc4) ± adaptive-multiplier × ATR, and direction flips when price closes through the opposite band.
• [b]Trend Cloud[/b] — a fill is drawn between the SuperTrend line and an EMA (which doubles as the regime filter), tinted green in uptrends and red in downtrends.
• [b]Trend strength[/b] — measured as the distance from close to the SuperTrend line in ATR units, clamped and normalized so roughly 3 ATR reads as fully saturated. This drives the candle and cloud gradient from weak to strong.
• [b]Momentum confluence[/b] — an optional filter requiring [b]RSI[/b] above/below its midline, or [b]MACD[/b] histogram sign, to agree with the flip direction.
• [b]Signal logic[/b] — a BUY needs a bullish flip [i]plus[/i] price above the EMA [i]plus[/i] momentum agreement; a SELL needs the mirror. All three conditions must line up.
• [b]SL/TP zones[/b] — on each signal, stop distance is ATR × your SL multiple, TP1 sits at 1R, and TP2 at your risk:reward ratio; boxes, lines, and labels live-extend forward while the trade runs, then freeze on the next flip.

[b]▎ HOW TO USE IT[/b]
• Trade with the cloud: green cloud and green-shaded candles favor longs, red favors shorts.
• Treat [b]BUY[/b] / [b]SELL[/b] labels as your trigger — they only appear on a confirmed flip that also passes the EMA and momentum filters.
• Use the [b]RISK ZONE[/b] (red) and [b]TARGET ZONE[/b] (green) boxes to frame a trade at a glance: entry line, dashed SL, dotted TP1 at 1R, and TP2 at your chosen R multiple.
• Read candle brightness as conviction — deeply saturated candles mean price is stretched from the line and the trend is strong; pale candles signal a weakening or fresh move.
• Optionally enable the [b]VWAP + σ bands[/b] for an intraday mean-reference and to gauge stretch from the session average.
• Combine with your own structure, higher-timeframe bias, and levels — this is context, not a standalone system.

[b]▎ KEY SETTINGS[/b]
• [b]Engine[/b] — ATR length, base multiplier, adaptive range (0 = fixed multiplier), volatility rank window, and band source.
• [b]Filters[/b] — signal/trend EMA length, momentum toggle, RSI vs MACD, RSI length and midline.
• [b]Risk[/b] — show zones on/off, SL in ATR units, risk:reward ratio, zone projection length, and how many past zones to keep.
• [b]Visuals[/b] — cloud toggle and transparency, gradient candles, line/EMA/label toggles, VWAP bands and σ, label size, and the four bull/bear gradient colors.
• [b]Dashboard[/b] — show/hide, panel position, and text size.

[b]▎ DASHBOARD[/b]
A compact chrome panel reports live: current [b]Direction[/b], the [b]Adaptive Multiplier[/b] in effect, the [b]Volatility Regime[/b] (Low / Normal / High with a percentile), [b]Trend Strength[/b] %, [b]Bars In Trend[/b], [b]Distance To Flip[/b] in ATR, the [b]Active Signal[/b] state, the current [b]ATR[/b] value, and whether [b]Momentum[/b] is aligned or divergent.

[b]▎ ALERTS[/b]
• [b]Bull Flip[/b] — SuperTrend turns up with price above EMA and momentum aligned.
• [b]Bear Flip[/b] — SuperTrend turns down with price below EMA and momentum aligned.
• [b]Any Flip[/b] — either signal fires.
Each includes ticker and interval placeholders.

[b]▎ NOTES[/b]
• Works on any market and any timeframe — the adaptive engine re-ranks volatility to whatever chart you load.
• Signals confirm on the close of the flip bar and do not repaint after that bar closes.
• Fully self-contained with no external libraries; every visual layer (cloud, candles, zones, VWAP, dashboard) has its own toggle so you can keep the chart as clean as you like.

[i]For research and education only. This is not financial advice. No indicator can predict the future, and past behavior does not guarantee future results. Always do your own analysis and manage your own risk.[/i]

[i]Made with passion by JackOfAllTrades ⚡[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Adaptive Trend Cloud [JOAT]", shorttitle="ATC [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
//  ADAPTIVE TREND CLOUD [JOAT]
//  An ATR SuperTrend whose multiplier auto-adapts to the live volatility regime
//  (ATR percentile rank). Filled cloud between the SuperTrend line and a signal EMA,
//  gradient candle coloring by trend strength (distance-from-line / ATR), ATR-anchored
//  SL/TP zone boxes on every flip, and an optional VWAP + σ-band overlay.
//  Cyberpunk / chrome identity — neon green #00E676→#00C853, neon red #FF1744→#D50000.
//  Self-contained — no external libraries.
// ═══════════════════════════════════════════════════════════════════════════════

// ── 01 · Engine ────────────────────────────────────────────────────────────────
gEng      = "01 · Engine"
atrLen    = input.int(10,   "ATR Length",            minval=2,   maxval=100,           group=gEng, tooltip="ATR period driving the SuperTrend band width.")
baseMult  = input.float(3.0,"Base Multiplier",       minval=0.5, maxval=10.0, step=0.1, group=gEng, tooltip="Neutral ATR multiplier. The adaptive engine scales this up in high volatility and down in low volatility.")
adaptRng  = input.float(1.2,"Adaptive Range (±)",    minval=0.0, maxval=3.0,  step=0.1, group=gEng, tooltip="How far the multiplier can swing from the base value across the volatility spectrum. 0 = fixed multiplier.")
volLen    = input.int(100,  "Volatility Rank Window",minval=20,  maxval=500,           group=gEng, tooltip="Lookback used to percentile-rank current ATR against its recent history.")
srcType   = input.string("hl2","Band Source",        options=["hl2","close","ohlc4"], group=gEng, tooltip="Price basis the bands are built around.")

// ── 02 · Filters ───────────────────────────────────────────────────────────────
gFlt      = "02 · Filters"
emaLen    = input.int(50,   "Signal / Trend EMA",    minval=5,   maxval=400,           group=gFlt, tooltip="EMA used both as the cloud's second boundary and the regime filter. Longs need price above it, shorts below.")
useMom    = input.bool(true,"Momentum Confluence",   group=gFlt, tooltip="Require RSI momentum agreement for a signal to fire.")
momType   = input.string("RSI","Momentum Type",      options=["RSI","MACD"], group=gFlt, tooltip="RSI: > mid for longs, < mid for shorts. MACD: histogram sign must agree.")
rsiLen    = input.int(14,   "RSI Length",            minval=2,   maxval=50,            group=gFlt, tooltip="RSI period for momentum confluence.")
rsiMid    = input.float(50, "RSI Midline",           minval=30,  maxval=70,   step=1,  group=gFlt, tooltip="RSI level separating bullish/bearish momentum.")

// ── 03 · Risk (SL / TP Zones) ────────────────────────────────────────────────────
gRsk      = "03 · Risk"
showRisk  = input.bool(true, "Show SL / TP Zones",   group=gRsk, tooltip="Draw ATR-anchored stop / target ZONE BOXES + lines + labels on each flip. Live-extends while the trade runs, then freezes on the next flip.")
slMult    = input.float(1.5, "SL (× ATR)",           minval=0.2, maxval=6.0, step=0.1, group=gRsk, tooltip="Stop distance from entry, in ATR units.")
rrRatio   = input.float(2.0, "Risk : Reward",        minval=0.5, maxval=10.0,step=0.1, group=gRsk, tooltip="TP2 distance = SL distance × this ratio. TP1 is fixed at 1R.")
riskLen   = input.int(60,    "Zone Length (bars)",   minval=10,  maxval=300,           group=gRsk, tooltip="Maximum forward projection the live zone extends to before freezing.")
riskKeep  = input.int(6,     "Max SL/TP Kept",       minval=1,   maxval=30,            group=gRsk, tooltip="Older frozen SL/TP zones beyond this count are deleted.")

// ── 04 · Visuals ───────────────────────────────────────────────────────────────
gVis      = "04 · Visuals"
showCloud = input.bool(true, "Show Cloud",           group=gVis)
cloudTr   = input.int(78,   "Cloud Transparency",    minval=40,  maxval=98,            group=gVis)
gradCandle= input.bool(true, "Gradient Strength Candles", group=gVis, tooltip="Color candles by trend strength = distance from SuperTrend line in ATR units. Default ON.")
showLine  = input.bool(true, "Show SuperTrend Line", group=gVis)
showEma   = input.bool(true, "Show Signal EMA",      group=gVis)
showSig   = input.bool(true, "Show BUY / SELL Labels", group=gVis)
useVwap   = input.bool(false,"Show VWAP + σ Bands",  group=gVis, tooltip="Chrome session VWAP with ±σ band fill. Default OFF. Resets per session; works intraday.")
vwapDev   = input.float(1.0, "VWAP Band σ",          minval=0.5, maxval=4.0, step=0.5, group=gVis, tooltip="Standard-deviation multiple for the VWAP bands.")
lblSize   = input.string("Small","Label Size",       options=["Tiny","Small","Normal","Large"], group=gVis, tooltip="Text size for SL/TP zone labels.")
bullFar   = input.color(#00C853, "Bull Strong",      group=gVis, inline="bc")
bullNear  = input.color(#00E676, "Weak",             group=gVis, inline="bc")
bearFar   = input.color(#D50000, "Bear Strong",      group=gVis, inline="br")
bearNear  = input.color(#FF1744, "Weak",             group=gVis, inline="br")

// ── 05 · Dashboard ─────────────────────────────────────────────────────────────
gDash     = "05 · Dashboard"
showDash  = input.bool(true, "Show Dashboard",       group=gDash)
dashPos   = input.string("Top Right","Position",     options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group=gDash)
dashSize  = input.string("Normal","Text Size",       options=["Tiny","Small","Normal"], group=gDash)

// ═══════════════════════════════════════════════════════════════════════════════
//  PALETTE — cyberpunk / chrome identity
// ═══════════════════════════════════════════════════════════════════════════════
color cyGreen  = #00E676
color cyGreenD = #00C853
color cyRed    = #FF1744
color cyRedD   = #D50000
color chrome   = #C4CCD6

// ═══════════════════════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

// ═══════════════════════════════════════════════════════════════════════════════
//  ADAPTIVE ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
float src = srcType == "close" ? close : srcType == "ohlc4" ? ohlc4 : hl2
float atr = ta.atr(atrLen)

// Percentile rank of current ATR within its recent window → 0..1 volatility regime.
float volRank = ta.percentrank(atr, volLen) / 100.0
float volReg  = na(volRank) ? 0.5 : volRank

// Adaptive multiplier: base scaled by where volatility sits in its range.
// High vol → wider bands (fewer whipsaws); low vol → tighter bands (earlier flips).
float adaptMult = baseMult + (volReg - 0.5) * 2.0 * adaptRng
adaptMult := math.max(0.25, adaptMult)

// ── SuperTrend (inline, adaptive multiplier) ────────────────────────────────────
float upRaw = src + adaptMult * atr
float dnRaw = src - adaptMult * atr

var float up  = na
var float dn  = na
var int   dir = 1

up  := na(up[1])  or upRaw < up[1]  or close[1] > up[1] ? upRaw : up[1]
dn  := na(dn[1])  or dnRaw > dn[1]  or close[1] < dn[1] ? dnRaw : dn[1]
dir := na(dir[1]) ? 1 : dir[1] == -1 and close > up[1] ? 1 : dir[1] == 1 and close < dn[1] ? -1 : dir[1]

float stLine  = dir == 1 ? dn : up
float emaLine = ta.ema(close, emaLen)

// ── Trend strength = distance from line in ATR units (0..~1 clamp) ──────────────
float rawStrength = atr > 0 ? math.abs(close - stLine) / atr : 0.0
float strength    = math.min(rawStrength / 3.0, 1.0)   // 3 ATR = fully saturated
float strengthPct = strength * 100.0

// ── Momentum confluence ─────────────────────────────────────────────────────────
float rsi = ta.rsi(close, rsiLen)
// MACD histogram computed directly (macdLine − signalLine) to avoid an
// unused-tuple-element on ta.macd's macd/signal outputs.
float macdLine = ta.ema(close, 12) - ta.ema(close, 26)
float histLine = macdLine - ta.ema(macdLine, 9)
bool momBull = not useMom or (momType == "RSI" ? rsi > rsiMid : histLine > 0)
bool momBear = not useMom or (momType == "RSI" ? rsi < rsiMid : histLine < 0)

// ── Signals: flip + regime filter + momentum ────────────────────────────────────
bool flipBull = dir == 1  and dir[1] == -1
bool flipBear = dir == -1 and dir[1] == 1
bool aboveEma = close > emaLine
bool belowEma = close < emaLine

bool buySig  = flipBull and aboveEma and momBull
bool sellSig = flipBear and belowEma and momBear

// ── Bars in trend & regime label ────────────────────────────────────────────────
var int barsInTrend = 0
barsInTrend := dir == dir[1] ? barsInTrend + 1 : 1
string regTxt = volReg >= 0.66 ? "High" : volReg <= 0.33 ? "Low" : "Normal"

// ═══════════════════════════════════════════════════════════════════════════════
//  VISUALS — CLOUD & GRADIENT CANDLES
// ═══════════════════════════════════════════════════════════════════════════════
color stColor = dir == 1 ? color.from_gradient(strength, 0.0, 1.0, bullNear, bullFar) : color.from_gradient(strength, 0.0, 1.0, bearNear, bearFar)

p_st  = plot(showLine ? stLine  : na, "SuperTrend", color=stColor, linewidth=2)
p_ema = plot(showEma  ? emaLine : na, "Signal EMA", color=color.new(color.gray, 40), linewidth=1)

// Cloud fill between SuperTrend line and EMA, tinted by trend & strength.
color cloudCol = dir == 1 ? color.new(color.from_gradient(strength, 0.0, 1.0, bullNear, bullFar), cloudTr) : color.new(color.from_gradient(strength, 0.0, 1.0, bearNear, bearFar), cloudTr)
fill(p_st, p_ema, color=showCloud ? cloudCol : na, title="Trend Cloud")

// Gradient strength candles — the signature (toggle, default ON).
color candleCol = dir == 1 ? color.from_gradient(strength, 0.0, 1.0, bullNear, bullFar) : color.from_gradient(strength, 0.0, 1.0, bearNear, bearFar)
barcolor(gradCandle ? candleCol : na, title="Strength Candles")

// Signal labels (clean pills — no arrows).
plotshape(showSig and buySig,  "BUY",  location=location.belowbar, style=shape.labelup,   size=size.small, color=bullFar, text="BUY",  textcolor=color.white)
plotshape(showSig and sellSig, "SELL", location=location.abovebar, style=shape.labeldown, size=size.small, color=bearFar, text="SELL", textcolor=color.white)

// ═══════════════════════════════════════════════════════════════════════════════
//  VWAP + σ BANDS (chrome, toggle — default OFF)
// ═══════════════════════════════════════════════════════════════════════════════
float vwapV = ta.vwap(hlc3)
float vwSd  = ta.stdev(close, 100)
float vwUp1 = vwapV + vwapDev * vwSd
float vwLo1 = vwapV - vwapDev * vwSd
plot(useVwap ? vwapV : na, "VWAP", color=color.new(chrome, 0), linewidth=2)
p_vu = plot(useVwap ? vwUp1 : na, "VWAP+σ", color=color.new(chrome, 70), linewidth=1)
p_vl = plot(useVwap ? vwLo1 : na, "VWAP-σ", color=color.new(chrome, 70), linewidth=1)
fill(p_vu, p_vl, color=useVwap ? color.new(chrome, 92) : na, title="VWAP Band")

// ═══════════════════════════════════════════════════════════════════════════════
//  RISK — SL / TP ZONE BOXES + LINES + LABELS (live-extend, then freeze on flip)
// ═══════════════════════════════════════════════════════════════════════════════
type riskViz
    box   slBox
    box   tpBox
    line  enL
    line  slL
    line  t1L
    line  t2L
    label enLb
    label slLb
    label t1Lb
    label t2Lb
    label rTag
    label tTag

var array<riskViz> riskHist = array.new<riskViz>()

// Currently-active (live-extending) zone refs.
var box   aSlBox = na
var box   aTpBox = na
var line  aEnL   = na
var line  aSlL   = na
var line  aT1L   = na
var line  aT2L   = na
var label aEnLb  = na
var label aSlLb  = na
var label aT1Lb  = na
var label aT2Lb  = na
var label aRTag  = na
var label aTTag  = na
var int   aEntryBar = na
var bool  aActive   = false

bool riskFlip = showRisk and (buySig or sellSig) and atr > 0

if riskFlip
    // Freeze & archive the previous active zone, capped cleanup.
    if aActive
        array.push(riskHist, riskViz.new(aSlBox, aTpBox, aEnL, aSlL, aT1L, aT2L, aEnLb, aSlLb, aT1Lb, aT2Lb, aRTag, aTTag))
        while array.size(riskHist) > riskKeep
            riskViz old = array.shift(riskHist)
            if not na(old.slBox)
                box.delete(old.slBox)
            if not na(old.tpBox)
                box.delete(old.tpBox)
            if not na(old.enL)
                line.delete(old.enL)
            if not na(old.slL)
                line.delete(old.slL)
            if not na(old.t1L)
                line.delete(old.t1L)
            if not na(old.t2L)
                line.delete(old.t2L)
            if not na(old.enLb)
                label.delete(old.enLb)
            if not na(old.slLb)
                label.delete(old.slLb)
            if not na(old.t1Lb)
                label.delete(old.t1Lb)
            if not na(old.t2Lb)
                label.delete(old.t2Lb)
            if not na(old.rTag)
                label.delete(old.rTag)
            if not na(old.tTag)
                label.delete(old.tTag)

    bool  isLong = buySig
    float entry  = close
    float slDist = atr * slMult
    float slP = isLong ? entry - slDist : entry + slDist
    float t1P = isLong ? entry + slDist : entry - slDist
    float t2P = isLong ? entry + slDist * rrRatio : entry - slDist * rrRatio
    color cDir = isLong ? cyGreen : cyRed
    int   xr   = bar_index + 3

    float tpTop = isLong ? t2P : entry
    float tpBot = isLong ? entry : t2P
    float slTop = isLong ? entry : slP
    float slBot = isLong ? slP : entry
    float rMid  = (entry + slP) / 2.0
    float tMid  = (entry + t2P) / 2.0

    aSlBox := box.new(bar_index, slTop, xr, slBot, xloc=xloc.bar_index, bgcolor=color.new(cyRedD, 82), border_color=color.new(cyRed, 45), border_width=1)
    aTpBox := box.new(bar_index, tpTop, xr, tpBot, xloc=xloc.bar_index, bgcolor=color.new(cyGreenD, 82), border_color=color.new(cyGreen, 45), border_width=1)
    aEnL := line.new(bar_index, entry, xr, entry, xloc=xloc.bar_index, color=color.new(cDir, 0), width=2)
    aSlL := line.new(bar_index, slP, xr, slP, xloc=xloc.bar_index, color=color.new(cyRedD, 10), width=1, style=line.style_dashed)
    aT1L := line.new(bar_index, t1P, xr, t1P, xloc=xloc.bar_index, color=color.new(cyGreen, 35), width=1, style=line.style_dotted)
    aT2L := line.new(bar_index, t2P, xr, t2P, xloc=xloc.bar_index, color=color.new(cyGreen, 10), width=1)
    aEnLb := label.new(xr, entry, (isLong ? "LONG" : "SHORT") + " @ " + str.tostring(entry, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cDir, 0), textcolor=color.white, size=f_size(lblSize))
    aSlLb := label.new(xr, slP, "SL @ " + str.tostring(slP, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cyRedD, 10), textcolor=color.white, size=f_size(lblSize))
    aT1Lb := label.new(xr, t1P, "TP1 1R", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cyGreen, 25), textcolor=color.white, size=f_size(lblSize))
    aT2Lb := label.new(xr, t2P, "TP2 " + str.tostring(rrRatio, "#.#") + "R", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(cyGreenD, 10), textcolor=color.white, size=f_size(lblSize))
    aRTag := label.new(bar_index, rMid, "RISK ZONE", xloc=xloc.bar_index, style=label.style_label_right, color=color.new(cyRedD, 30), textcolor=color.white, size=size.tiny, text_formatting=text.format_bold + text.format_italic)
    aTTag := label.new(bar_index, tMid, "TARGET ZONE", xloc=xloc.bar_index, style=label.style_label_right, color=color.new(cyGreenD, 30), textcolor=color.white, size=size.tiny, text_formatting=text.format_bold + text.format_italic)
    aEntryBar := bar_index
    aActive   := true

// Live-extend the active zone forward until the next flip (then it freezes).
if aActive and not riskFlip and showRisk
    int xr2 = aEntryBar + math.min(bar_index - aEntryBar + 3, riskLen)
    if not na(aSlBox)
        box.set_right(aSlBox, xr2)
    if not na(aTpBox)
        box.set_right(aTpBox, xr2)
    if not na(aEnL)
        line.set_x2(aEnL, xr2)
    if not na(aSlL)
        line.set_x2(aSlL, xr2)
    if not na(aT1L)
        line.set_x2(aT1L, xr2)
    if not na(aT2L)
        line.set_x2(aT2L, xr2)
    if not na(aEnLb)
        label.set_x(aEnLb, xr2)
    if not na(aSlLb)
        label.set_x(aSlLb, xr2)
    if not na(aT1Lb)
        label.set_x(aT1Lb, xr2)
    if not na(aT2Lb)
        label.set_x(aT2Lb, xr2)

// ═══════════════════════════════════════════════════════════════════════════════
//  DISTANCE TO FLIP  (price move needed to cross the opposite band)
// ═══════════════════════════════════════════════════════════════════════════════
float flipLevel = dir == 1 ? dn : up
float distFlip  = math.abs(close - flipLevel)
float distFlipA = atr > 0 ? distFlip / atr : 0.0

// ═══════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
color cBull    = cyGreenD
color cBear    = cyRedD
color cNeut    = #6b7480
color panelBg  = color.new(#0a0a0a, 8)
color panelAlt = color.new(#141821, 8)
color txtHi    = #e8ecf2
color txtLo    = #8a94a4

var table dash = table.new(f_pos(dashPos), 2, 10, frame_color=color.new(#39424f, 0), frame_width=1, border_width=1, border_color=color.new(#39424f, 30))

if barstate.islast and showDash
    ps = f_size(dashSize)
    color dirCol = dir == 1 ? cBull : cBear
    color headHue = dir == 1 ? color.from_gradient(strength, 0.0, 1.0, cyGreen, cyGreenD) : color.from_gradient(strength, 0.0, 1.0, cyRed, cyRedD)
    string sigTxt = buySig ? "BUY" : sellSig ? "SELL" : barsInTrend <= 3 ? (dir == 1 ? "Fresh Bull" : "Fresh Bear") : "—"
    color sigCol = buySig ? cBull : sellSig ? cBear : cNeut
    color regCol = regTxt == "High" ? cBear : regTxt == "Low" ? cBull : txtHi

    table.cell(dash, 0, 0, "ADAPTIVE TREND CLOUD", text_color=#0a0a0a, text_size=ps, text_halign=text.align_left, bgcolor=headHue)
    table.cell_set_text_formatting(dash, 0, 0, text.format_bold + text.format_italic)
    table.cell(dash, 1, 0, dir == 1 ? "BULL" : "BEAR", text_color=color.white, text_size=ps, text_halign=text.align_center, bgcolor=dirCol)
    table.cell_set_text_formatting(dash, 1, 0, text.format_bold + text.format_italic)

    table.cell(dash, 0, 1, "Direction", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 1, dir == 1 ? "● Uptrend" : "● Downtrend", text_color=dirCol, text_size=ps, text_halign=text.align_center, bgcolor=panelBg)

    table.cell(dash, 0, 2, "Adaptive Mult", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 2, str.tostring(adaptMult, "#.##") + "×", text_color=txtHi, text_size=ps, text_halign=text.align_center, bgcolor=panelAlt)

    table.cell(dash, 0, 3, "Vol Regime", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 3, regTxt + " (" + str.tostring(volReg * 100.0, "#") + "%)", text_color=regCol, text_size=ps, text_halign=text.align_center, bgcolor=panelBg)

    table.cell(dash, 0, 4, "Trend Strength", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 4, str.tostring(strengthPct, "#") + "%", text_color=color.from_gradient(strength, 0.0, 1.0, txtLo, dirCol), text_size=ps, text_halign=text.align_center, bgcolor=panelAlt)

    table.cell(dash, 0, 5, "Bars In Trend", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 5, str.tostring(barsInTrend), text_color=txtHi, text_size=ps, text_halign=text.align_center, bgcolor=panelBg)

    table.cell(dash, 0, 6, "Dist To Flip", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 6, str.tostring(distFlipA, "#.##") + " ATR", text_color=txtHi, text_size=ps, text_halign=text.align_center, bgcolor=panelAlt)

    table.cell(dash, 0, 7, "Active Signal", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 7, sigTxt, text_color=sigCol, text_size=ps, text_halign=text.align_center, bgcolor=panelBg)

    table.cell(dash, 0, 8, "ATR (" + str.tostring(atrLen) + ")", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 8, str.tostring(atr, format.mintick), text_color=txtHi, text_size=ps, text_halign=text.align_center, bgcolor=panelAlt)

    table.cell(dash, 0, 9, "Momentum", text_color=txtLo, text_size=ps, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 9, not useMom ? "Off" : momBull and dir == 1 ? "Aligned" : momBear and dir == -1 ? "Aligned" : "Divergent", text_color=(momBull and dir == 1) or (momBear and dir == -1) ? cBull : useMom ? cNeut : txtLo, text_size=ps, text_halign=text.align_center, bgcolor=panelBg)

// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(buySig,  "ATC — Bull Flip", "Adaptive Trend Cloud [JOAT]: BULL flip — SuperTrend turned up, price above EMA, momentum aligned on {{ticker}} {{interval}}.")
alertcondition(sellSig, "ATC — Bear Flip", "Adaptive Trend Cloud [JOAT]: BEAR flip — SuperTrend turned down, price below EMA, momentum aligned on {{ticker}} {{interval}}.")
alertcondition(buySig or sellSig, "ATC — Any Flip", "Adaptive Trend Cloud [JOAT]: trend flip signal on {{ticker}} {{interval}}.")
````
