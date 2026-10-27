# BK AK-Vigilante

- url: https://www.tradingview.com/script/n2FTdVu4-BK-AK-Vigilante/
- type: indicator
- pine_id: PUB;78993ae76d6b42ddb15ad78a7891ec81
- version: 1.0

## Description

☠ BK AK-Vigilante ☠

All glory to G-d.
Respect to my mentor AK, whose standard is discipline, confirmation, and execution without noise.

BK AK-Vigilante is a CCI-based momentum and reversal framework built to expose what most traders miss: not just where momentum is, but whether it is accelerating, fading, exhausting, or quietly preparing to reverse.

This indicator does not treat CCI like a basic overbought and oversold tool. It turns CCI into a layered read of market behavior by combining raw CCI structure, slope pressure, smoothing interaction, momentum-state transitions, fast and slow divergence engines, velocity expansion, absorption signals, multi-timeframe alignment, and a confluence intelligence layer that helps separate trend continuation from reversal conditions.

What it does

BK AK-Vigilante tracks the market through multiple stacked reads:

a core CCI engine
optional smoothing and Bollinger structure
instant slope coloring for momentum pressure
crossover fill between CCI and its smoothing average
peak and valley pivot detection
fast divergence for tactical shifts
slow divergence for structural shifts
divergence confluence when both engines align
momentum histogram state changes such as launch, surge, fade, and flip
velocity envelope breaks
absorption and exhaustion detection at extremes
higher-timeframe confluence
a CCI volatility ratio that helps judge signal quality
a compact intelligence layer and status table for live decision support

How it works

The script starts with raw CCI, then builds context around it.

The slope layer measures how aggressively CCI is changing bar to bar. That makes the line react not just to level, but to force. The histogram then compares CCI to its smoothing average so you can see when momentum is launching, accelerating, fading, or flipping. That matters because reversals often begin with deceleration before they appear in price.

The divergence engine is split into two parts. The fast engine is for tactical divergence and shorter-turn behavior. The slow engine is for structural divergence and larger reversals. When both engines align inside the confluence window, the script flags that as a much higher-conviction condition than a single divergence by itself.

On top of that, the script checks for absorption at deep extremes. That helps identify the moments when CCI is still stretched, but the force behind the move is already dying. The velocity envelope adds another layer by showing when CCI is pushing beyond its normal movement range. The volatility ratio then helps filter whether current conditions are expanded and meaningful or compressed and likely to be noisy.

What makes it different

BK AK-Vigilante is not a decorative CCI remake.

Its purpose is to convert CCI from a simple oscillator into a market-state tool.

The difference is in the interaction of its layers:

slope tells you pressure
histogram tells you state
divergence tells you disagreement
absorption tells you exhaustion
velocity tells you acceleration
MTF tells you alignment
confluence intelligence tells you when the layers are working together

That is the edge here. It is built to help answer practical questions:

Is the current move still healthy or already fading?
Is this extreme actually strong, or is it exhausted?
Is divergence tactical noise or structural risk?
Are multiple layers confirming the same direction?
Is this the point to press, reduce, or prepare for reversal?

How to use it

A clean workflow is:

Start with the CCI regime and slope.
Then check the histogram state.
Then check whether divergence is forming.
Then look for absorption or velocity breaks.
Then confirm with MTF and the volatility ratio.

In practice:

SURGE + strong slope + expanded volatility favors continuation.
FADE + absorption at extremes is where reversal risk becomes real.
Fast and slow divergence together is where conviction increases.
Compressed volatility means reduce trust in signals and avoid overcommitting.
MTF agreement gives better directional confidence.

This script is best used as a decision-support tool, not as a blind auto-entry system.

Best fit

BK AK-Vigilante is suited for traders who want momentum and reversal structure in one place, especially for:

intraday scalping
day trading
momentum continuation trades
exhaustion-based reversal setups
confirmation work alongside structure, levels, or price action

It can be used on any market, but it is most useful where momentum shifts matter and where the trader wants to distinguish between a real trend leg and a move that is already starting to fail.

Bottom line

BK AK-Vigilante was built to read momentum with more depth than a standard oscillator.

Not just overbought.
Not just oversold.
Not just divergence.

It is a framework for reading pressure, state, exhaustion, acceleration, and confluence through CCI so the trader can act with more structure and less guesswork.

☠ BK AK-Vigilante ☠

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Ki11a_B 


//@version=6
indicator(title="BK AK-Vigilante", shorttitle="☠", format=format.price, precision=2, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════
// ██  CORE CCI ENGINE
// ════════════════════════════════════════════════════════════════
GRP_CORE = "═══ CORE CCI ═══"
length      = input.int(20, "CCI Length", minval=1, group=GRP_CORE)
src         = input.source(hlc3, "Source", group=GRP_CORE)

ma_val  = ta.sma(src, length)
cci_raw = (src - ma_val) / (0.015 * ta.dev(src, length))

// ════════════════════════════════════════════════════════════════
// ██  SMOOTHING MA ENGINE
// ════════════════════════════════════════════════════════════════
GRP_SMOOTH = "═══ SMOOTHING MA ═══"
maTypeInput   = input.string("EMA", "Type", options=["None", "SMA", "EMA", "RMA", "WMA", "VWMA", "SMA + BB"], group=GRP_SMOOTH)
maLengthInput = input.int(9, "Length", minval=1, group=GRP_SMOOTH)
enableMA  = maTypeInput != "None"
isBB      = maTypeInput == "SMA + BB"
bbMultInput   = input.float(2.0, "BB StdDev", minval=0.001, maxval=50, step=0.5, group=GRP_SMOOTH, tooltip="Only applies with SMA + BB")

ma_func(source, len, MAtype) =>
    switch MAtype
        "SMA"      => ta.sma(source, len)
        "SMA + BB" => ta.sma(source, len)
        "EMA"      => ta.ema(source, len)
        "RMA"      => ta.rma(source, len)
        "WMA"      => ta.wma(source, len)
        "VWMA"     => ta.vwma(source, len)
        => na

smoothingMA    = enableMA ? ma_func(cci_raw, maLengthInput, maTypeInput) : na
smoothingStDev = isBB ? ta.stdev(cci_raw, maLengthInput) * bbMultInput : na

// ════════════════════════════════════════════════════════════════
// ██  SLOPE COLORING — INSTANT (1-bar delta, optional smoothing)
// ════════════════════════════════════════════════════════════════
GRP_SLOPE = "═══ SLOPE COLORING ═══"
slopeSmooth  = input.int(2, "Slope Smoothing", minval=1, maxval=5, group=GRP_SLOPE, tooltip="1 = raw instant, 2-5 = light EMA smoothing on delta")
slopeThresh  = input.float(3.0, "Strong Slope Threshold", minval=0.1, step=0.5, group=GRP_SLOPE, tooltip="Above this = neon, below = faded")

rawDelta = cci_raw - cci_raw[1]
slope    = slopeSmooth <= 1 ? rawDelta : ta.ema(rawDelta, slopeSmooth)

col_strongUp   = color.new(#00E676, 0)
col_weakUp     = color.new(#00E676, 55)
col_neutral    = color.new(#787B86, 30)
col_weakDown   = color.new(#FF1744, 55)
col_strongDown = color.new(#FF1744, 0)

cci_color = slope > slopeThresh ? col_strongUp :
     slope > 0 ? col_weakUp :
     slope < -slopeThresh ? col_strongDown :
     slope < 0 ? col_weakDown :
     col_neutral

// ════════════════════════════════════════════════════════════════
// ██  SMOOTHING MA — DISTINCT COLOR (gold bull / steel bear)
// ════════════════════════════════════════════════════════════════
GRP_MA_COLOR = "═══ MA COLORS ═══"
colMABull = input.color(color.new(#FFD54F, 20), "MA Bull Color", group=GRP_MA_COLOR, tooltip="MA color when CCI is above it")
colMABear = input.color(color.new(#64B5F6, 20), "MA Bear Color", group=GRP_MA_COLOR, tooltip="MA color when CCI is below it")

cciAboveMA = enableMA ? cci_raw > smoothingMA : false
maColor = cciAboveMA ? colMABull : colMABear

// ════════════════════════════════════════════════════════════════
// ██  REGIME ZONES — BREATHING DYNAMIC OPACITY
// ════════════════════════════════════════════════════════════════
GRP_REGIME = "═══ REGIME ZONES ═══"
showRegime = input.bool(true, "Show Extreme Background", group=GRP_REGIME)
showZeroLine = input.bool(true, "Show Zero Line", group=GRP_REGIME)

// Zero line as plot — doesn't pin Y-axis scale like hline does
plot(showZeroLine ? 0 : na, "Zero Line", color=color.new(#787B86, 60), linewidth=1, style=plot.style_circles)

// bgcolor ONLY on extremes (±200+) — rare, meaningful, not constant noise
obColor = if showRegime and cci_raw > 200
    depth = math.min(math.abs(cci_raw - 200) / 150, 1.0)
    alpha = math.round(90 - depth * 15)
    color.new(#FF5722, alpha)
else
    na

osColor = if showRegime and cci_raw < -200
    depth = math.min(math.abs(cci_raw + 200) / 150, 1.0)
    alpha = math.round(90 - depth * 15)
    color.new(#1565C0, alpha)
else
    na

bgcolor(obColor, title="Extreme OB Background")
bgcolor(osColor, title="Extreme OS Background")

// ════════════════════════════════════════════════════════════════
// ██  CROSS-COLOR TURNOVER FILL (CCI vs Smoothing MA)
// ════════════════════════════════════════════════════════════════
GRP_CROSS = "═══ CROSSOVER FILL ═══"
showCrossFill  = input.bool(true, "Show Cross Fill", group=GRP_CROSS)
crossFillAlpha = input.int(85, "Fill Transparency", minval=50, maxval=98, group=GRP_CROSS)

p_cci = plot(cci_raw, "CCI", color=cci_color, linewidth=2)
p_sma = plot(smoothingMA, "Smoothing MA", color=enableMA ? maColor : na, linewidth=1)

crossFillColor = if showCrossFill and enableMA
    cciAboveMA ? color.new(#00E676, crossFillAlpha) : color.new(#FF1744, crossFillAlpha)
else
    na

fill(p_cci, p_sma, color=crossFillColor, title="CCI/MA Cross Fill")

// Bollinger Band plots
bbUpper = plot(enableMA and isBB ? smoothingMA + smoothingStDev : na, "BB Upper", color=color.new(#4CAF50, 50))
bbLower = plot(enableMA and isBB ? smoothingMA - smoothingStDev : na, "BB Lower", color=color.new(#4CAF50, 50))
fill(bbUpper, bbLower, color=isBB ? color.new(#4CAF50, 93) : na, title="BB Fill")

// ════════════════════════════════════════════════════════════════
// ██  ZERO-LINE CROSS DETECTION (alerts only — no visual clutter)
// ════════════════════════════════════════════════════════════════
zeroCrossUp   = ta.crossover(cci_raw, 0)
zeroCrossDown = ta.crossunder(cci_raw, 0)

// ════════════════════════════════════════════════════════════════
// ██  PEAK / VALLEY — PIVOT MARKERS
// ════════════════════════════════════════════════════════════════
GRP_PV = "═══ PEAKS & VALLEYS ═══"
showPV       = input.bool(true, "Show Peaks/Valleys", group=GRP_PV)
pvLookback   = input.int(5, "Pivot Lookback", minval=2, maxval=20, group=GRP_PV)
pvMinLevel   = input.float(50.0, "Min CCI Level", minval=0, group=GRP_PV)

pvHigh = ta.pivothigh(cci_raw, pvLookback, pvLookback)
pvLow  = ta.pivotlow(cci_raw, pvLookback, pvLookback)

validPeak   = not na(pvHigh) and pvHigh >  pvMinLevel
validValley = not na(pvLow)  and pvLow  < -pvMinLevel

if showPV and validPeak
    label.new(bar_index - pvLookback, pvHigh, "◆", color=color.new(color.black, 100), textcolor=color.new(#FF1744, 0), style=label.style_none, size=size.tiny,
         tooltip="PEAK\nCCI: " + str.tostring(pvHigh, "#.##") + "\nAction: Watch for slope flip → short entry")

if showPV and validValley
    label.new(bar_index - pvLookback, pvLow, "◆", color=color.new(color.black, 100), textcolor=color.new(#00E676, 0), style=label.style_none, size=size.tiny,
         tooltip="VALLEY\nCCI: " + str.tostring(pvLow, "#.##") + "\nAction: Watch for slope flip → long entry")

// ════════════════════════════════════════════════════════════════
// ██  DUAL DIVERGENCE ENGINE — REBUILT (OB/OS zone filter)
// ════════════════════════════════════════════════════════════════
// Divergences ONLY draw when CCI pivots are in extreme zones.
// A divergence at CCI=40 is noise. A divergence at CCI=180 is a signal.

GRP_DIVF = "═══ DIVERGENCE — FAST ═══"
showDivFast      = input.bool(true, "Show Fast Divergences", group=GRP_DIVF)
divFastLB        = input.int(5, "Fast Pivot Lookback", minval=2, maxval=15, group=GRP_DIVF, tooltip="Higher = fewer but cleaner pivots")
divFastMaxBars   = input.int(40, "Fast Max Bars Between", minval=5, maxval=100, group=GRP_DIVF)
divFastMinCCI    = input.float(80.0, "Fast Min CCI Level", minval=0, maxval=300, group=GRP_DIVF, tooltip="Pivot must be above this (absolute) to qualify. Filters out neutral zone noise.")
showFastHidden   = input.bool(true, "Show Fast Hidden Div", group=GRP_DIVF)
colFastBear      = input.color(color.new(#FF1744, 50), "Fast Bear Color", group=GRP_DIVF)
colFastBull      = input.color(color.new(#00E676, 50), "Fast Bull Color", group=GRP_DIVF)
divFastMaxLines  = input.int(6, "Fast Max Lines", minval=2, maxval=20, group=GRP_DIVF, tooltip="Auto-deletes oldest when exceeded")

GRP_DIVS = "═══ DIVERGENCE — SLOW ═══"
showDivSlow      = input.bool(true, "Show Slow Divergences", group=GRP_DIVS)
divSlowLB        = input.int(12, "Slow Pivot Lookback", minval=5, maxval=30, group=GRP_DIVS, tooltip="Higher = catches structural swings")
divSlowMaxBars   = input.int(120, "Slow Max Bars Between", minval=20, maxval=400, group=GRP_DIVS)
divSlowMinCCI    = input.float(100.0, "Slow Min CCI Level", minval=0, maxval=400, group=GRP_DIVS, tooltip="Pivot must be above this (absolute) to qualify. Structural divs need real extremes.")
showSlowHidden   = input.bool(true, "Show Slow Hidden Div", group=GRP_DIVS)
colSlowBear      = input.color(color.new(#FF6F00, 50), "Slow Bear Color", group=GRP_DIVS)
colSlowBull      = input.color(color.new(#00BFA5, 50), "Slow Bull Color", group=GRP_DIVS)
divSlowMaxLines  = input.int(4, "Slow Max Lines", minval=2, maxval=20, group=GRP_DIVS, tooltip="Auto-deletes oldest when exceeded")

GRP_DIVC = "═══ DIVERGENCE — CONFLUENCE ═══"
showDivConfluence = input.bool(true, "Show Confluence Markers", group=GRP_DIVC)
confluenceWindow  = input.int(8, "Confluence Window (bars)", minval=1, maxval=30, group=GRP_DIVC)

// ── Pivots
fPriceH = ta.pivothigh(high,    divFastLB, divFastLB)
fPriceL = ta.pivotlow(low,      divFastLB, divFastLB)
fCCIH   = ta.pivothigh(cci_raw, divFastLB, divFastLB)
fCCIL   = ta.pivotlow(cci_raw,  divFastLB, divFastLB)

sPriceH = ta.pivothigh(high,    divSlowLB, divSlowLB)
sPriceL = ta.pivotlow(low,      divSlowLB, divSlowLB)
sCCIH   = ta.pivothigh(cci_raw, divSlowLB, divSlowLB)
sCCIL   = ta.pivotlow(cci_raw,  divSlowLB, divSlowLB)

// ── Line/label management arrays for auto-cleanup
var line[]  fDivLines  = array.new_line()
var label[] fDivLabels = array.new_label()
var line[]  sDivLines  = array.new_line()
var label[] sDivLabels = array.new_label()

// Helper: add line+label and trim oldest
addDivLine(line[] lines, label[] labels, int maxN, int x1, float y1, int x2, float y2, color col, int w, string sty, string icon, string tip, bool isTop) =>
    newLine = line.new(x1, y1, x2, y2, color=col, width=w, style=sty == "solid" ? line.style_solid : line.style_dashed)
    lblStyle = isTop ? label.style_none : label.style_none
    newLabel = label.new(x2, y2, icon, color=color.new(color.black, 100), textcolor=col, style=label.style_none, size=size.tiny, tooltip=tip)
    array.push(lines, newLine)
    array.push(labels, newLabel)
    if array.size(lines) > maxN
        line.delete(array.shift(lines))
        label.delete(array.shift(labels))

// ── FAST engine state
var float fPrevPriceH = na, var float fPrevCCIH = na, var int fPrevBarH = na
var float fPrevPriceL = na, var float fPrevCCIL = na, var int fPrevBarL = na
var int lastFastBullBar = 0, var int lastFastBearBar = 0

// FAST HIGHS — only when BOTH pivots are above min CCI level
if not na(fPriceH) and not na(fCCIH) and fCCIH > divFastMinCCI
    if not na(fPrevPriceH) and not na(fPrevCCIH) and fPrevCCIH > divFastMinCCI
        btwn = bar_index - divFastLB - fPrevBarH
        if btwn > 0 and btwn <= divFastMaxBars
            curBar = bar_index - divFastLB
            // Regular bearish: price HH, CCI LH
            if fPriceH > fPrevPriceH and fCCIH < fPrevCCIH and showDivFast
                tip = "● FAST BEAR DIVERGENCE\n═══════════════════\n\n▸ PRICE: Higher High\n▸ CCI: Lower High (" + str.tostring(fPrevCCIH, "#.#") + " → " + str.tostring(fCCIH, "#.#") + ")\n▸ SPAN: " + str.tostring(btwn) + " bars\n\n─── INSTITUTIONAL ACTION ───\nMomentum failing to confirm price high.\nTactical exhaustion signal.\nTIGHTEN long stops to last swing low.\nPREPARE short entry on slope flip confirmation.\nDo not front-run — wait for CCI slope to turn negative."
                addDivLine(fDivLines, fDivLabels, divFastMaxLines, fPrevBarH, fPrevCCIH, curBar, fCCIH, colFastBear, 1, "solid", "●", tip, true)
                lastFastBearBar := curBar
            // Hidden bullish: price LH, CCI HH
            if fPriceH < fPrevPriceH and fCCIH > fPrevCCIH and showDivFast and showFastHidden
                tip = "○ FAST HIDDEN BULL\n═══════════════════\n\n▸ PRICE: Lower High\n▸ CCI: Higher High (" + str.tostring(fPrevCCIH, "#.#") + " → " + str.tostring(fCCIH, "#.#") + ")\n\n─── INSTITUTIONAL ACTION ───\nMomentum stronger than price suggests.\nContinuation signal — trend has hidden strength.\nHOLD longs. Add on pullback to MA.\nStop below last significant valley."
                addDivLine(fDivLines, fDivLabels, divFastMaxLines, fPrevBarH, fPrevCCIH, curBar, fCCIH, colFastBull, 1, "dashed", "○", tip, true)
                lastFastBullBar := curBar
    if not na(fCCIH) and fCCIH > divFastMinCCI
        fPrevPriceH := fPriceH
        fPrevCCIH   := fCCIH
        fPrevBarH   := bar_index - divFastLB

// FAST LOWS — only when BOTH pivots are below -min CCI level
if not na(fPriceL) and not na(fCCIL) and fCCIL < -divFastMinCCI
    if not na(fPrevPriceL) and not na(fPrevCCIL) and fPrevCCIL < -divFastMinCCI
        btwn = bar_index - divFastLB - fPrevBarL
        if btwn > 0 and btwn <= divFastMaxBars
            curBar = bar_index - divFastLB
            // Regular bullish: price LL, CCI HL
            if fPriceL < fPrevPriceL and fCCIL > fPrevCCIL and showDivFast
                tip = "● FAST BULL DIVERGENCE\n═══════════════════\n\n▸ PRICE: Lower Low\n▸ CCI: Higher Low (" + str.tostring(fPrevCCIL, "#.#") + " → " + str.tostring(fCCIL, "#.#") + ")\n▸ SPAN: " + str.tostring(btwn) + " bars\n\n─── INSTITUTIONAL ACTION ───\nMomentum failing to confirm price low.\nTactical exhaustion signal.\nTIGHTEN short stops to last swing high.\nPREPARE long entry on slope flip confirmation.\nDo not front-run — wait for CCI slope to turn positive."
                addDivLine(fDivLines, fDivLabels, divFastMaxLines, fPrevBarL, fPrevCCIL, curBar, fCCIL, colFastBull, 1, "solid", "●", tip, false)
                lastFastBullBar := curBar
            // Hidden bearish: price HL, CCI LL
            if fPriceL > fPrevPriceL and fCCIL < fPrevCCIL and showDivFast and showFastHidden
                tip = "○ FAST HIDDEN BEAR\n═══════════════════\n\n▸ PRICE: Higher Low\n▸ CCI: Lower Low (" + str.tostring(fPrevCCIL, "#.#") + " → " + str.tostring(fCCIL, "#.#") + ")\n\n─── INSTITUTIONAL ACTION ───\nMomentum weaker than price suggests.\nContinuation signal — downtrend has hidden strength.\nHOLD shorts. Add on rally to MA.\nStop above last significant peak."
                addDivLine(fDivLines, fDivLabels, divFastMaxLines, fPrevBarL, fPrevCCIL, curBar, fCCIL, colFastBear, 1, "dashed", "○", tip, false)
                lastFastBearBar := curBar
    if not na(fCCIL) and fCCIL < -divFastMinCCI
        fPrevPriceL := fPriceL
        fPrevCCIL   := fCCIL
        fPrevBarL   := bar_index - divFastLB

// ── SLOW engine state
var float sPrevPriceH = na, var float sPrevCCIH = na, var int sPrevBarH = na
var float sPrevPriceL = na, var float sPrevCCIL = na, var int sPrevBarL = na
var int lastSlowBullBar = 0, var int lastSlowBearBar = 0

// SLOW HIGHS
if not na(sPriceH) and not na(sCCIH) and sCCIH > divSlowMinCCI
    if not na(sPrevPriceH) and not na(sPrevCCIH) and sPrevCCIH > divSlowMinCCI
        btwn = bar_index - divSlowLB - sPrevBarH
        if btwn > 0 and btwn <= divSlowMaxBars
            curBar = bar_index - divSlowLB
            if sPriceH > sPrevPriceH and sCCIH < sPrevCCIH and showDivSlow
                tip = "◉ SLOW BEAR DIVERGENCE (STRUCTURAL)\n═══════════════════\n\n▸ PRICE: Higher High\n▸ CCI: Lower High (" + str.tostring(sPrevCCIH, "#.#") + " → " + str.tostring(sCCIH, "#.#") + ")\n▸ SPAN: " + str.tostring(btwn) + " bars\n\n─── INSTITUTIONAL ACTION ───\nStructural momentum failure at significant extreme.\nThis is the high-timeframe exhaustion signal.\nCLOSE long positions or reduce to 25%.\nENTER short on CCI slope flip + histogram FADE.\nTarget: Mean reversion to CCI zero line.\nThis divergence type precedes the largest reversals."
                addDivLine(sDivLines, sDivLabels, divSlowMaxLines, sPrevBarH, sPrevCCIH, curBar, sCCIH, colSlowBear, 1, "solid", "◉", tip, true)
                lastSlowBearBar := curBar
            if sPriceH < sPrevPriceH and sCCIH > sPrevCCIH and showDivSlow and showSlowHidden
                tip = "◎ SLOW HIDDEN BULL (STRUCTURAL)\n═══════════════════\n\n▸ PRICE: Lower High\n▸ CCI: Higher High\n\n─── INSTITUTIONAL ACTION ───\nStructural momentum stronger than price shows.\nThe trend has deep underlying strength.\nHOLD longs with conviction. Add on dips.\nThis is NOT a reversal — it's hidden continuation."
                addDivLine(sDivLines, sDivLabels, divSlowMaxLines, sPrevBarH, sPrevCCIH, curBar, sCCIH, colSlowBull, 1, "dashed", "◎", tip, true)
                lastSlowBullBar := curBar
    if not na(sCCIH) and sCCIH > divSlowMinCCI
        sPrevPriceH := sPriceH
        sPrevCCIH   := sCCIH
        sPrevBarH   := bar_index - divSlowLB

// SLOW LOWS
if not na(sPriceL) and not na(sCCIL) and sCCIL < -divSlowMinCCI
    if not na(sPrevPriceL) and not na(sPrevCCIL) and sPrevCCIL < -divSlowMinCCI
        btwn = bar_index - divSlowLB - sPrevBarL
        if btwn > 0 and btwn <= divSlowMaxBars
            curBar = bar_index - divSlowLB
            if sPriceL < sPrevPriceL and sCCIL > sPrevCCIL and showDivSlow
                tip = "◉ SLOW BULL DIVERGENCE (STRUCTURAL)\n═══════════════════\n\n▸ PRICE: Lower Low\n▸ CCI: Higher Low (" + str.tostring(sPrevCCIL, "#.#") + " → " + str.tostring(sCCIL, "#.#") + ")\n▸ SPAN: " + str.tostring(btwn) + " bars\n\n─── INSTITUTIONAL ACTION ───\nStructural momentum failure at significant extreme.\nThis is the high-timeframe exhaustion signal.\nCLOSE short positions or reduce to 25%.\nENTER long on CCI slope flip + histogram FADE.\nTarget: Mean reversion to CCI zero line.\nThis divergence type precedes the largest reversals."
                addDivLine(sDivLines, sDivLabels, divSlowMaxLines, sPrevBarL, sPrevCCIL, curBar, sCCIL, colSlowBull, 1, "solid", "◉", tip, false)
                lastSlowBullBar := curBar
            if sPriceL > sPrevPriceL and sCCIL < sPrevCCIL and showDivSlow and showSlowHidden
                tip = "◎ SLOW HIDDEN BEAR (STRUCTURAL)\n═══════════════════\n\n▸ PRICE: Higher Low\n▸ CCI: Lower Low\n\n─── INSTITUTIONAL ACTION ───\nStructural momentum weaker than price shows.\nThe downtrend has deep underlying strength.\nHOLD shorts with conviction. Add on rallies.\nThis is NOT a reversal — it's hidden continuation."
                addDivLine(sDivLines, sDivLabels, divSlowMaxLines, sPrevBarL, sPrevCCIL, curBar, sCCIL, colSlowBear, 1, "dashed", "◎", tip, false)
                lastSlowBearBar := curBar
    if not na(sCCIL) and sCCIL < -divSlowMinCCI
        sPrevPriceL := sPriceL
        sPrevCCIL   := sCCIL
        sPrevBarL   := bar_index - divSlowLB

// ── CONFLUENCE DETECTION
bullConfluence = math.abs(lastFastBullBar - lastSlowBullBar) <= confluenceWindow and lastFastBullBar > 0 and lastSlowBullBar > 0
bearConfluence = math.abs(lastFastBearBar - lastSlowBearBar) <= confluenceWindow and lastFastBearBar > 0 and lastSlowBearBar > 0

var bool prevBullConf = false, var bool prevBearConf = false
newBullConf = bullConfluence and not prevBullConf
newBearConf = bearConfluence and not prevBearConf
prevBullConf := bullConfluence
prevBearConf := bearConfluence

if showDivConfluence and newBullConf
    label.new(bar_index, cci_raw, "⚡", color=color.new(color.black, 100), textcolor=color.new(#FFD600, 0), style=label.style_none, size=size.small,
         tooltip="⚡ DUAL ENGINE BULL CONFLUENCE\n═══════════════════\n\n▸ FAST engine: Bullish divergence confirmed\n▸ SLOW engine: Bullish divergence confirmed\n▸ Both fired within " + str.tostring(confluenceWindow) + " bars\n\n─── INSTITUTIONAL ACTION ───\nHighest conviction LONG signal this indicator produces.\nBoth tactical and structural divergence aligned.\nENTER long with full allocation.\nStop below the most recent valley.\nTarget: CCI return to OB zone (+100).")
if showDivConfluence and newBearConf
    label.new(bar_index, cci_raw, "⚡", color=color.new(color.black, 100), textcolor=color.new(#FFD600, 0), style=label.style_none, size=size.small,
         tooltip="⚡ DUAL ENGINE BEAR CONFLUENCE\n═══════════════════\n\n▸ FAST engine: Bearish divergence confirmed\n▸ SLOW engine: Bearish divergence confirmed\n▸ Both fired within " + str.tostring(confluenceWindow) + " bars\n\n─── INSTITUTIONAL ACTION ───\nHighest conviction SHORT signal this indicator produces.\nBoth tactical and structural divergence aligned.\nENTER short with full allocation.\nStop above the most recent peak.\nTarget: CCI return to OS zone (-100).")

// ════════════════════════════════════════════════════════════════
// ██  MOMENTUM HISTOGRAM — STATE MACHINE
// ════════════════════════════════════════════════════════════════
GRP_HIST = "═══ MOMENTUM HISTOGRAM ═══"
showHist       = input.bool(true, "Show Histogram", group=GRP_HIST)
histBullColor  = input.color(#00E676, "Bull Color (above zero)", group=GRP_HIST)
histBearColor  = input.color(#FF1744, "Bear Color (below zero)", group=GRP_HIST)
histLaunchBull = input.color(#69F0AE, "LAUNCH Bull Color", group=GRP_HIST, tooltip="Color when histogram just crossed zero and expanding (bullish)")
histLaunchBear = input.color(#FF8A80, "LAUNCH Bear Color", group=GRP_HIST, tooltip="Color when histogram just crossed zero and expanding (bearish)")
histFlipBull   = input.color(#B9F6CA, "FLIP Bull Color", group=GRP_HIST)
histFlipBear   = input.color(#FF8A80, "FLIP Bear Color", group=GRP_HIST)
histAlphaBump  = input.int(15, "Transparency Bump", minval=0, maxval=80, group=GRP_HIST, tooltip="Added to base transparency. 0 = full brightness. Higher = more see-through across ALL states.")

histVal    = enableMA ? cci_raw - smoothingMA : na
histGrow   = not na(histVal) and not na(histVal[1]) ? histVal > histVal[1] : false
histShrink = not na(histVal) and not na(histVal[1]) ? histVal < histVal[1] : false

// ── State Machine
// LAUNCH = histogram just crossed zero and expanding (new leg)
// SURGE  = histogram on same side, still growing (acceleration)
// FADE   = histogram on same side, shrinking (deceleration — EARLY WARNING)
// FLIP   = histogram just crossed zero (regime change)
histCrossUp   = not na(histVal) and not na(histVal[1]) ? histVal > 0 and histVal[1] <= 0 : false
histCrossDown = not na(histVal) and not na(histVal[1]) ? histVal < 0 and histVal[1] >= 0 : false
histCross     = histCrossUp or histCrossDown

histAboveZero = not na(histVal) ? histVal > 0 : false
histBelowZero = not na(histVal) ? histVal < 0 : false

// State assignment
var string histState = "—"
if na(histVal)
    histState := "—"
else if histCross and histGrow
    histState := "LAUNCH"
else if histCross
    histState := "FLIP"
else if not histCross and histGrow
    histState := "SURGE"
else if not histCross and histShrink
    histState := "FADE"
// else stays at previous state (flat bar)

// ── Streak counter: consecutive bars in same direction (growing or shrinking)
var int streak = 0
if histGrow
    streak := streak >= 0 ? streak + 1 : 1
else if histShrink
    streak := streak <= 0 ? streak - 1 : -1
else
    streak := 0

absStreak = math.abs(streak)

// ── State-aware histogram coloring (uses configurable color inputs + transparency bump)
histColor = if na(histVal)
    na
else if histState == "LAUNCH"
    histAboveZero ? color.new(histLaunchBull, math.min(20 + histAlphaBump, 99)) : color.new(histLaunchBear, math.min(20 + histAlphaBump, 99))
else if histState == "SURGE"
    histAboveZero ? color.new(histBullColor, math.min(15 + histAlphaBump, 99)) : color.new(histBearColor, math.min(15 + histAlphaBump, 99))
else if histState == "FADE"
    histAboveZero ? color.new(histBullColor, math.min(65 + histAlphaBump, 99)) : color.new(histBearColor, math.min(65 + histAlphaBump, 99))
else if histState == "FLIP"
    histAboveZero ? color.new(histFlipBull, math.min(10 + histAlphaBump, 99)) : color.new(histFlipBear, math.min(10 + histAlphaBump, 99))
else
    color.new(#787B86, math.min(70 + histAlphaBump, 99))

plot(showHist and enableMA ? histVal : na, "Momentum Histogram", color=histColor, style=plot.style_columns)

// ── Alerts for state transitions
fadeAfterSurge = histState == "FADE" and histState[1] == "SURGE"
alertcondition(histState == "LAUNCH", "Histogram Launch", "New momentum leg detected — histogram crossed zero and expanding")
alertcondition(fadeAfterSurge,        "Histogram Fade",   "Momentum decelerating after surge — early reversal warning")

// ════════════════════════════════════════════════════════════════
// ██  VELOCITY ENVELOPE
// ════════════════════════════════════════════════════════════════
GRP_VEL = "═══ VELOCITY ENVELOPE ═══"
showVelEnv   = input.bool(true, "Show Velocity Envelope", group=GRP_VEL)
velLen       = input.int(20, "Envelope Length", minval=5, maxval=50, group=GRP_VEL)
velMult      = input.float(2.0, "Envelope Multiplier", minval=0.5, maxval=5.0, step=0.25, group=GRP_VEL)
velColor     = input.color(#E040FB, "Envelope Color", group=GRP_VEL)
velLineAlpha = input.int(65, "Line Transparency", minval=0, maxval=95, group=GRP_VEL)
velFillAlpha = input.int(99, "Fill Transparency", minval=50, maxval=99, group=GRP_VEL)

cciMA_vel    = ta.sma(cci_raw, velLen)
cciStdev     = ta.stdev(cci_raw, velLen)
velUpper     = cciMA_vel + cciStdev * velMult
velLower     = cciMA_vel - cciStdev * velMult

pVelU = plot(showVelEnv ? velUpper : na, "Vel Upper", color=color.new(velColor, velLineAlpha), linewidth=1)
pVelL = plot(showVelEnv ? velLower : na, "Vel Lower", color=color.new(velColor, velLineAlpha), linewidth=1)
fill(pVelU, pVelL, color=showVelEnv ? color.new(velColor, velFillAlpha) : na, title="Velocity Envelope Fill")

_velCrossUp  = ta.crossover(cci_raw, velUpper)
_velCrossDn  = ta.crossunder(cci_raw, velLower)
velBreakUp   = showVelEnv and _velCrossUp
velBreakDown = showVelEnv and _velCrossDn

if velBreakUp
    label.new(bar_index, velUpper, "▲", color=color.new(color.black, 100), textcolor=color.new(#E040FB, 0), style=label.style_label_up, size=size.tiny,
         tooltip="VEL BREAK UP\nCCI: " + str.tostring(cci_raw, "#.#") + " > Env: " + str.tostring(velUpper, "#.#") + "\nAction: Acceleration surge")
if velBreakDown
    label.new(bar_index, velLower, "▼", color=color.new(color.black, 100), textcolor=color.new(#E040FB, 0), style=label.style_label_down, size=size.tiny,
         tooltip="VEL BREAK DN\nCCI: " + str.tostring(cci_raw, "#.#") + " < Env: " + str.tostring(velLower, "#.#") + "\nAction: Acceleration crash")

// ════════════════════════════════════════════════════════════════
// ██  ABSORPTION / EXHAUSTION
// ════════════════════════════════════════════════════════════════
GRP_ABS = "═══ ABSORPTION ═══"
showAbsorption = input.bool(true, "Show Absorption", group=GRP_ABS)
absLookback    = input.int(10, "Absorption Lookback", minval=3, maxval=30, group=GRP_ABS)
absSlopeDecay  = input.float(0.4, "Slope Decay Threshold", minval=0.1, maxval=0.9, step=0.1, group=GRP_ABS)

absSlope     = math.abs(slope)
peakSlope    = ta.highest(absSlope, absLookback)
slopeDecayed = peakSlope > 0 ? absSlope / peakSlope : 1.0

inExtremeOB = cci_raw > 150
inExtremeOS = cci_raw < -150
absorptionOB = showAbsorption and inExtremeOB and slopeDecayed < absSlopeDecay and slopeDecayed[1] >= absSlopeDecay
absorptionOS = showAbsorption and inExtremeOS and slopeDecayed < absSlopeDecay and slopeDecayed[1] >= absSlopeDecay

if absorptionOB
    label.new(bar_index, cci_raw, "✕", color=color.new(color.black, 100), textcolor=color.new(#FF9800, 0), style=label.style_label_down, size=size.tiny,
         tooltip="ABSORPTION OB\nCCI: " + str.tostring(cci_raw, "#.#") + "\nSlope decay: " + str.tostring(slopeDecayed * 100, "#.#") + "%\nAction: Momentum dying at extreme → reversal imminent")
if absorptionOS
    label.new(bar_index, cci_raw, "✕", color=color.new(color.black, 100), textcolor=color.new(#FF9800, 0), style=label.style_label_up, size=size.tiny,
         tooltip="ABSORPTION OS\nCCI: " + str.tostring(cci_raw, "#.#") + "\nSlope decay: " + str.tostring(slopeDecayed * 100, "#.#") + "%\nAction: Momentum dying at extreme → reversal imminent")

// ════════════════════════════════════════════════════════════════
// ██  MTF CONFLUENCE
// ════════════════════════════════════════════════════════════════
GRP_MTF = "═══ MTF CONFLUENCE ═══"
showMTF    = input.bool(false, "Show MTF Dots", group=GRP_MTF)
htf1       = input.timeframe("60",  "Higher TF 1", group=GRP_MTF)
htf2       = input.timeframe("240", "Higher TF 2", group=GRP_MTF)

[htf1_cci, htf1_prev] = request.security(syminfo.tickerid, htf1, [cci_raw, cci_raw[1]], lookahead=barmerge.lookahead_off)
[htf2_cci, htf2_prev] = request.security(syminfo.tickerid, htf2, [cci_raw, cci_raw[1]], lookahead=barmerge.lookahead_off)

allBullish = cci_raw > 0 and htf1_cci > 0 and htf2_cci > 0
allBearish = cci_raw < 0 and htf1_cci < 0 and htf2_cci < 0

mtfColor = allBullish ? color.new(#00E676, 20) : allBearish ? color.new(#FF1744, 20) : na
plotshape(showMTF and (allBullish or allBearish) ? cci_raw : na, "MTF Confluence", shape.circle, location.absolute, mtfColor, size=size.auto)

// ════════════════════════════════════════════════════════════════
// ██  CCI VOLATILITY RATIO — SIGNAL CONFIDENCE FILTER
// ════════════════════════════════════════════════════════════════
GRP_CVOL = "═══ CCI VOLATILITY ═══"
cvolLen      = input.int(20, "Range Lookback", minval=5, maxval=100, group=GRP_CVOL, tooltip="Bars to measure current CCI range")
cvolAvgLen   = input.int(100, "Average Lookback", minval=20, maxval=500, group=GRP_CVOL, tooltip="Bars to measure normal CCI range")
cvolExpand   = input.float(1.5, "Expansion Threshold", minval=1.0, maxval=3.0, step=0.1, group=GRP_CVOL, tooltip="Above this = expanded, signals high conviction")
cvolCompress = input.float(0.7, "Compression Threshold", minval=0.1, maxval=1.0, step=0.1, group=GRP_CVOL, tooltip="Below this = compressed, chop zone, reduce size")

cciRange    = ta.highest(cci_raw, cvolLen) - ta.lowest(cci_raw, cvolLen)
cciAvgRange = ta.sma(cciRange, cvolAvgLen)
cvolRatio   = cciAvgRange > 0 ? cciRange / cciAvgRange : 1.0

cvolExpanded   = cvolRatio >= cvolExpand
cvolCompressed = cvolRatio <= cvolCompress

// ════════════════════════════════════════════════════════════════
// ██  CONFLUENCE INTELLIGENCE ENGINE — CROSS-LAYER PATTERN DETECTION
// ════════════════════════════════════════════════════════════════
// Detects when indicator layers agree (high conviction) or conflict
// (transition zones). Outputs a single intel read with strategy.

// ── Layer states for pattern matching
slopeStrong   = math.abs(slope) > slopeThresh
slopeUp       = slope > 0
slopeDown     = slope < 0
regimeOB      = cci_raw > 100
regimeOS      = cci_raw < -100
regimeExtreme = math.abs(cci_raw) > 200
recentPeak    = validPeak
recentValley  = validValley

// ── CONFLUENCE PATTERNS (priority order — first match wins)
// Icons only on chart. All detail lives in tooltips.
var string intelIcon = "—"
var string intelTip  = ""
var color  intelCol  = color.new(#555555, 0)

// P1: TRIPLE REVERSAL — Fade + Absorption
if histState == "FADE" and (absorptionOB or absorptionOS)
    intelIcon := "⚡"
    intelCol  := color.new(#FFD600, 0)
    intelTip  := "⚡ TRIPLE REVERSAL\n═══════════════════\n\n▸ HISTOGRAM: FADE — momentum decelerating\n▸ ABSORPTION: Active — slope exhausted at extreme\n▸ CCI: " + str.tostring(cci_raw, "#.#") + " | Slope: " + str.tostring(slope, "#.#") + "\n\n─── INSTITUTIONAL ACTION ───\n"
    intelTip  += absorptionOB ? "CLOSE all long exposure immediately.\nENTER short with stop 1 ATR above the CCI peak.\nTARGET: Mean reversion to zero line.\nSIZING: Full conviction — all layers confirmed.\nTIMING: Execute now, do not wait for additional confirmation." : "CLOSE all short exposure immediately.\nENTER long with stop 1 ATR below the CCI valley.\nTARGET: Mean reversion to zero line.\nSIZING: Full conviction — all layers confirmed.\nTIMING: Execute now, do not wait for additional confirmation."

// P2: FULL TREND — Surge + Strong slope + CVR expanded
else if histState == "SURGE" and slopeStrong and cvolExpanded
    intelIcon := slopeUp ? "🔥" : "🔥"
    intelCol  := slopeUp ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    intelTip  := "🔥 FULL TREND ALIGNMENT\n═══════════════════\n\n▸ HISTOGRAM: SURGE ×" + str.tostring(absStreak) + " — accelerating\n▸ SLOPE: " + str.tostring(slope, "#.#") + " — strong " + (slopeUp ? "bullish" : "bearish") + "\n▸ CVR: " + str.tostring(cvolRatio, "#.##") + "x — expanded (real vol)\n\n─── INSTITUTIONAL ACTION ───\nMAX CONVICTION " + (slopeUp ? "LONG" : "SHORT") + " environment.\nDo NOT counter-trade under any circumstance.\nTrail stops behind the move — do not tighten prematurely.\nAdd to winners on pullbacks to the smoothing MA.\nSIZING: Full allocation. This is the setup you wait for."

// P3: EXHAUSTION CONVERGENCE — Fade + Weak slope + Extreme regime
else if histState == "FADE" and not slopeStrong and regimeExtreme
    intelIcon := cci_raw > 0 ? "☠" : "☠"
    intelCol  := color.new(#FF9800, 0)
    intelTip  := "☠ EXHAUSTION CONVERGENCE\n═══════════════════\n\n▸ HISTOGRAM: FADE — decelerating\n▸ SLOPE: " + str.tostring(slope, "#.#") + " — weak, losing momentum\n▸ REGIME: Extreme at " + str.tostring(cci_raw, "#") + "\n\n─── INSTITUTIONAL ACTION ───\nAll layers indicate exhaustion.\nCLOSE trend positions — do not hold through this.\nTIGHTEN stops to breakeven or better.\nPREPARE counter-trade entry but wait for FLIP confirmation.\nDo NOT front-run the reversal without ✕ absorption signal.\nSIZING: Reduce to 25% or flat."

// P4: REGIME/SLOPE DIVERGENCE — Deep OB/OS + hard slope reversal
else if cci_raw > 150 and slopeDown and math.abs(slope) > slopeThresh * 2
    intelIcon := "⬇"
    intelCol  := color.new(#FF9800, 0)
    intelTip  := "⬇ EARLY EXIT — REGIME/SLOPE DIVERGENCE\n═══════════════════\n\n▸ REGIME: Deep Overbought at " + str.tostring(cci_raw, "#") + "\n▸ SLOPE: " + str.tostring(slope, "#.#") + " — reversing hard (2x threshold)\n\n─── INSTITUTIONAL ACTION ───\nCCI still in OB but momentum has flipped bearish.\nThis is the early warning before the full reversal.\nCLOSE or REDUCE long positions immediately.\nDo NOT initiate new longs.\nWait for slope to confirm bullish again before re-entry.\nSIZING: Reduce to 0-25% long exposure."

else if cci_raw < -150 and slopeUp and math.abs(slope) > slopeThresh * 2
    intelIcon := "⬆"
    intelCol  := color.new(#FF9800, 0)
    intelTip  := "⬆ EARLY EXIT — REGIME/SLOPE DIVERGENCE\n═══════════════════\n\n▸ REGIME: Deep Oversold at " + str.tostring(cci_raw, "#") + "\n▸ SLOPE: " + str.tostring(slope, "#.#") + " — reversing hard (2x threshold)\n\n─── INSTITUTIONAL ACTION ───\nCCI still in OS but momentum has flipped bullish.\nThis is the early warning before the full reversal.\nCLOSE or REDUCE short positions immediately.\nDo NOT initiate new shorts.\nWait for slope to confirm bearish again before re-entry.\nSIZING: Reduce to 0-25% short exposure."

// P5: CONFLICT — Absorption firing but histogram still surging
else if (absorptionOB or absorptionOS) and histState == "SURGE"
    intelIcon := "⚔"
    intelCol  := color.new(#AAAAAA, 0)
    intelTip  := "⚔ SIGNAL CONFLICT\n═══════════════════\n\n▸ ABSORPTION: Active — slope decaying at extreme\n▸ HISTOGRAM: SURGE ×" + str.tostring(absStreak) + " — still expanding\n▸ CCI: " + str.tostring(cci_raw, "#.#") + "\n\n─── INSTITUTIONAL ACTION ───\nTwo layers are contradicting.\nAbsorption says the move is dying.\nHistogram says momentum is still building.\nDo NOT act on absorption alone — it may be premature.\nWAIT for histogram to confirm FADE before counter-trading.\nMAINTAIN current position with tighter stops.\nSIZING: No changes. Monitor for resolution."

// P6: NORMAL
else
    intelIcon := histState == "SURGE" ? (slopeUp ? "▲" : "▼") : histState == "FADE" ? "◌" : "·"
    intelCol  := histState == "SURGE" ? (slopeUp ? color.new(#00E676, 40) : color.new(#FF1744, 40)) : histState == "FADE" ? color.new(#FF9800, 40) : color.new(#555555, 0)
    intelTip  := "CURRENT STATUS\n═══════════════════\n\n▸ CCI: " + str.tostring(cci_raw, "#.#") + "\n▸ SLOPE: " + str.tostring(slope, "#.#") + "\n▸ HISTOGRAM: " + histState + " ×" + str.tostring(absStreak) + "\n▸ CVR: " + str.tostring(cvolRatio, "#.##") + "x\n\n─── INSTITUTIONAL ACTION ───\n"
    intelTip  += histState == "SURGE" ? "Trend in progress. Hold positions. Monitor for FADE transition.\nFADE after extended SURGE = highest probability reversal setup." : histState == "FADE" ? "Momentum weakening. Tighten stops.\nWatch for absorption ✕ or exhaustion convergence ☠.\nDo not add to positions in FADE state." : "No active signal. Wait for a clear state to develop.\nAvoid initiating new positions in neutral conditions."

// ── Chart markers (icons only, fire on transition, min bar spacing)
GRP_INTEL = "═══ INTEL MARKERS ═══"
showIntel    = input.bool(true, "Show Intel Markers", group=GRP_INTEL)
intelMinBars = input.int(5, "Min Bars Between Labels", minval=1, maxval=20, group=GRP_INTEL)

var string prevIntel = "—"
var int lastIntelBar = 0
intelChanged = intelIcon != prevIntel
prevIntel := intelIcon

// Only chart-mark actionable patterns (not normal states)
isActionableIntel = intelIcon == "⚡" or intelIcon == "🔥" or intelIcon == "☠" or intelIcon == "⬆" or intelIcon == "⬇" or intelIcon == "⚔"

barsSinceLastIntel = bar_index - lastIntelBar

if showIntel and intelChanged and isActionableIntel and barsSinceLastIntel >= intelMinBars
    lblPos = cci_raw > 0 ? cci_raw + 20 : cci_raw - 20
    label.new(bar_index, lblPos, intelIcon, color=color.new(color.black, 100), textcolor=intelCol, style=label.style_none, size=size.small, tooltip=intelTip)
    lastIntelBar := bar_index

alertcondition(intelIcon == "⚡", "Triple Reversal", "⚡ Triple reversal — FADE + Absorption convergence")
alertcondition(intelIcon == "⚔", "Signal Conflict", "⚔ Absorption vs SURGE conflict — wait for resolution")
alertcondition(intelChanged and isActionableIntel, "Intel Pattern", "New confluence pattern detected")

// ════════════════════════════════════════════════════════════════
// ██  ALERTS
// ════════════════════════════════════════════════════════════════
// ±100 cross detection (for alerts only — no visual markers)
crossAbove100  = ta.crossover(cci_raw, 100)
crossBelow100  = ta.crossunder(cci_raw, 100)
crossAboveN100 = ta.crossover(cci_raw, -100)
crossBelowN100 = ta.crossunder(cci_raw, -100)
alertcondition(zeroCrossUp,    "CCI Zero Cross Up",      "CCI crossed above zero")
alertcondition(zeroCrossDown,  "CCI Zero Cross Down",    "CCI crossed below zero")
alertcondition(crossAbove100,  "CCI Entered OB (+100)",  "CCI crossed above +100")
alertcondition(crossBelow100,  "CCI Exited OB (+100)",   "CCI crossed below +100")
alertcondition(crossAboveN100, "CCI Exited OS (-100)",   "CCI crossed above -100")
alertcondition(crossBelowN100, "CCI Entered OS (-100)",  "CCI crossed below -100")
alertcondition(absorptionOB,   "Absorption at OB",       "CCI absorption detected in overbought zone")
alertcondition(absorptionOS,   "Absorption at OS",       "CCI absorption detected in oversold zone")
alertcondition(velBreakUp,     "Velocity Break Up",      "CCI broke above velocity envelope")
alertcondition(velBreakDown,   "Velocity Break Down",    "CCI broke below velocity envelope")
alertcondition(newBullConf,    "Div Confluence Bull",    "Fast + Slow bullish divergence confluence detected")
alertcondition(newBearConf,    "Div Confluence Bear",    "Fast + Slow bearish divergence confluence detected")

// ════════════════════════════════════════════════════════════════
// ██  STATUS TABLE
// ════════════════════════════════════════════════════════════════
GRP_TBL = "═══ STATUS TABLE ═══"
showTable     = input.bool(true, "Show Status Table", group=GRP_TBL)
tblPos        = input.string("Bottom Center", "Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=GRP_TBL)
tblSize       = input.string("Tiny", "Text Size", options=["Tiny", "Small", "Normal"], group=GRP_TBL)
tblBgColor    = input.color(#1E1E1E, "Background Color", group=GRP_TBL)
tblBgAlpha    = input.int(10, "Background Transparency", minval=0, maxval=100, group=GRP_TBL, tooltip="0 = solid, 100 = invisible")
tblBorderColor = input.color(#333333, "Border Color", group=GRP_TBL)
tblBorderAlpha = input.int(0, "Border Transparency", minval=0, maxval=100, group=GRP_TBL)

tablePos = switch tblPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right

tblTextSize = switch tblSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal

if barstate.islast and showTable
    // Horizontal: 11 columns × 2 rows
    var tbl = table.new(tablePos, 11, 2, bgcolor=color.new(tblBgColor, tblBgAlpha), border_color=color.new(tblBorderColor, tblBorderAlpha), border_width=1, frame_color=color.new(tblBorderColor, tblBorderAlpha), frame_width=1)

    // ── CCI
    regime = cci_raw > 200 ? "EXT OB" : cci_raw > 100 ? "OB" : cci_raw > 0 ? "BULL" : cci_raw > -100 ? "BEAR" : cci_raw > -200 ? "OS" : "EXT OS"
    cciTip = "CCI: " + str.tostring(cci_raw, "#.##") + " | " + regime + "\n─────────────────\n"
    cciTip += cci_raw > 200 ? "EXTREME — Reversal risk high. Tighten stops, don't add. Watch for absorption ✕ signals." :
         cci_raw > 100 ? "OVERBOUGHT — Momentum strong but extended. Trail stops, watch for slope decay." :
         cci_raw > 0 ? "BULLISH — Above zero, trend favors longs. Look for pullbacks to MA for entries." :
         cci_raw > -100 ? "BEARISH — Below zero, trend favors shorts. Look for rallies to MA for entries." :
         cci_raw > -200 ? "OVERSOLD — Momentum weak but extended. Trail stops, watch for slope recovery." :
         "EXTREME — Reversal risk high. Tighten stops, don't add. Watch for absorption ✕ signals."
    table.cell(tbl, 0, 0, "CCI", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=cciTip)
    table.cell(tbl, 0, 1, str.tostring(cci_raw, "#.#"), text_color=cci_color, text_size=tblTextSize, tooltip=cciTip)

    // ── Regime
    regimeCol = cci_raw > 100 ? color.new(#FF5722, 0) : cci_raw > 0 ? color.new(#00E676, 0) : cci_raw > -100 ? color.new(#FF1744, 0) : color.new(#1565C0, 0)
    regTip = "Regime: " + regime + "\n─────────────────\nDefines directional bias.\n>0 = Bullish regime (favor longs)\n<0 = Bearish regime (favor shorts)\n>±100 = Trending\n>±200 = Extreme (reversal zone)"
    table.cell(tbl, 1, 0, "Reg", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=regTip)
    table.cell(tbl, 1, 1, regime, text_color=regimeCol, text_size=tblTextSize, tooltip=regTip)

    // ── Slope
    slopeCol = slope > slopeThresh ? col_strongUp : slope > 0 ? col_weakUp : slope < -slopeThresh ? col_strongDown : slope < 0 ? col_weakDown : col_neutral
    slopeTip = "Slope: " + str.tostring(slope, "#.##") + "\n─────────────────\nRate of CCI change (momentum acceleration).\n"
    slopeTip += slope > slopeThresh ? "STRONG UP — Accelerating bullish. Hold longs, add on dips." :
         slope > 0 ? "WEAK UP — Rising but decelerating. Tighten stops, watch for flip." :
         slope < -slopeThresh ? "STRONG DOWN — Accelerating bearish. Hold shorts, add on rallies." :
         slope < 0 ? "WEAK DOWN — Falling but decelerating. Tighten stops, watch for flip." :
         "FLAT — No directional momentum. Stay flat or scalp only."
    table.cell(tbl, 2, 0, "Slp", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=slopeTip)
    table.cell(tbl, 2, 1, str.tostring(slope, "#.#"), text_color=slopeCol, text_size=tblTextSize, tooltip=slopeTip)

    // ── Histogram State
    stateCol = histState == "LAUNCH" ? color.new(#69F0AE, 0) : histState == "SURGE" ? color.new(#00E676, 0) : histState == "FADE" ? color.new(#FF9800, 0) : histState == "FLIP" ? color.new(#B9F6CA, 0) : color.new(#555555, 0)
    stateStr = histState == "—" ? "—" : histState
    streakStr = absStreak > 0 ? str.tostring(absStreak) : ""
    stateTip = "Histogram State: " + histState + " | Streak: " + str.tostring(absStreak) + "\n─────────────────\n"
    stateTip += histState == "LAUNCH" ? "LAUNCH — Histogram just crossed zero AND expanding. New trend leg initiating. Enter with trend, size up." :
         histState == "SURGE" ? "SURGE (" + str.tostring(absStreak) + " bars) — Momentum accelerating. Ride it. Don't counter-trade. Trail stops behind the move." :
         histState == "FADE" ? "FADE (" + str.tostring(absStreak) + " bars) — ⚠ EARLY WARNING. Momentum decelerating before CCI turns. Tighten stops. Prep counter-trade. If FADE + Absorption + Peak = triple-confirmed reversal." :
         histState == "FLIP" ? "FLIP — Histogram crossed zero. Regime change. Previous trend exhausted. Reassess bias." :
         "No state — MA may be disabled."
    table.cell(tbl, 3, 0, "Hst", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=stateTip)
    table.cell(tbl, 3, 1, stateStr + streakStr, text_color=stateCol, text_size=tblTextSize, tooltip=stateTip)

    // ── MΔ (raw value)
    histStr = enableMA ? str.tostring(histVal, "#.#") : "—"
    histTblCol = na(histVal) ? color.gray : histVal > 0 ? color.new(#00E676, 0) : color.new(#FF1744, 0)
    mdTip = "Momentum Delta: " + histStr + "\n─────────────────\nCCI minus smoothing MA. Raw spread value."
    table.cell(tbl, 4, 0, "MΔ", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=mdTip)
    table.cell(tbl, 4, 1, histStr, text_color=histTblCol, text_size=tblTextSize, tooltip=mdTip)

    // ── Absorption
    absStr = absorptionOB ? "⚠OB" : absorptionOS ? "⚠OS" : "—"
    absCol = (absorptionOB or absorptionOS) ? color.new(#FF9800, 0) : color.new(#555555, 0)
    absTip = "Absorption: " + absStr + "\n─────────────────\nSlope dying at extreme CCI level.\n"
    absTip += absorptionOB ? "OB ABSORPTION — Momentum exhausting at high. Reversal imminent. Prep short or tighten long stops." :
         absorptionOS ? "OS ABSORPTION — Momentum exhausting at low. Reversal imminent. Prep long or tighten short stops." :
         "No absorption detected. CCI slope consistent with level."
    table.cell(tbl, 5, 0, "Abs", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=absTip)
    table.cell(tbl, 5, 1, absStr, text_color=absCol, text_size=tblTextSize, tooltip=absTip)

    // ── MTF
    mtfStr = not showMTF ? "OFF" : allBullish ? "▲" : allBearish ? "▼" : "MIX"
    mtfCol = allBullish ? color.new(#00E676, 0) : allBearish ? color.new(#FF1744, 0) : color.new(#AAAAAA, 0)
    mtfTip = "MTF Confluence: " + mtfStr + "\n─────────────────\n"
    mtfTip += not showMTF ? "Disabled. Enable in settings to see multi-timeframe CCI alignment." :
         allBullish ? "ALL BULLISH — Chart TF + HTF1 + HTF2 all CCI > 0. Strong directional alignment. High conviction long setups." :
         allBearish ? "ALL BEARISH — Chart TF + HTF1 + HTF2 all CCI < 0. Strong directional alignment. High conviction short setups." :
         "MIXED — Timeframes disagree. Reduce size, scalp only, or wait for alignment."
    table.cell(tbl, 6, 0, "MTF", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=mtfTip)
    table.cell(tbl, 6, 1, mtfStr, text_color=mtfCol, text_size=tblTextSize, tooltip=mtfTip)

    // ── Divergence
    divStr = newBullConf ? "⚡B" : newBearConf ? "⚡S" : bullConfluence ? "B" : bearConfluence ? "S" : "—"
    divCol = (newBullConf or bullConfluence) ? color.new(#FFD600, 0) : (newBearConf or bearConfluence) ? color.new(#FFD600, 0) : color.new(#555555, 0)
    divTip = "Divergence: " + divStr + "\n─────────────────\nDual engine (Fast tactical + Slow structural).\n"
    divTip += newBullConf ? "⚡ BULL CONFLUENCE — Both engines fired bullish. Highest conviction long signal." :
         newBearConf ? "⚡ BEAR CONFLUENCE — Both engines fired bearish. Highest conviction short signal." :
         bullConfluence ? "Bull confluence active from recent signals." :
         bearConfluence ? "Bear confluence active from recent signals." :
         "No active divergence confluence."
    table.cell(tbl, 7, 0, "Div", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=divTip)
    table.cell(tbl, 7, 1, divStr, text_color=divCol, text_size=tblTextSize, tooltip=divTip)

    // ── Velocity
    velStr = not showVelEnv ? "OFF" : cci_raw > velUpper ? "▲" : cci_raw < velLower ? "▼" : "IN"
    velCol = cci_raw > velUpper ? color.new(#E040FB, 0) : cci_raw < velLower ? color.new(#E040FB, 0) : color.new(#555555, 0)
    velTip = "Velocity Envelope: " + velStr + "\n─────────────────\n"
    velTip += not showVelEnv ? "Disabled. Enable to see CCI volatility breakouts." :
         cci_raw > velUpper ? "BREAK UP — CCI surged above its own volatility band. Acceleration event. Ride or fade the spike." :
         cci_raw < velLower ? "BREAK DN — CCI crashed below its own volatility band. Acceleration event. Ride or fade the crash." :
         "INSIDE — CCI within normal volatility range. No acceleration signal."
    table.cell(tbl, 8, 0, "Vel", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=velTip)
    table.cell(tbl, 8, 1, velStr, text_color=velCol, text_size=tblTextSize, tooltip=velTip)

    // ── CCI Vol Ratio (signal confidence)
    cvolStr = str.tostring(cvolRatio, "#.##")
    cvolCol = cvolExpanded ? color.new(#00E676, 0) : cvolCompressed ? color.new(#FF1744, 0) : color.new(#AAAAAA, 0)
    cvolState = cvolExpanded ? "EXPANDED" : cvolCompressed ? "COMPRESSED" : "NORMAL"
    cvolTip = "CCI Vol Ratio: " + cvolStr + " (" + cvolState + ")\n─────────────────\nCurrent CCI range vs average range.\n"
    cvolTip += cvolExpanded ? "EXPANDED (>" + str.tostring(cvolExpand, "#.#") + "x) — CCI swinging wider than normal. Signals are high conviction. Size up. Trends are real." :
         cvolCompressed ? "COMPRESSED (<" + str.tostring(cvolCompress, "#.#") + "x) — CCI range is squeezed. Chop zone. Signals are low conviction. Reduce size or sit out. Breakout pending." :
         "NORMAL — Standard volatility. Trade signals at normal conviction and sizing."
    table.cell(tbl, 9, 0, "CVR", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=cvolTip)
    table.cell(tbl, 9, 1, cvolStr, text_color=cvolCol, text_size=tblTextSize, tooltip=cvolTip)

    // ── Intel (Confluence Intelligence — icon only, detail in tooltip)
    table.cell(tbl, 10, 0, "🧠", text_color=color.new(#AAAAAA, 0), text_size=tblTextSize, tooltip=intelTip)
    table.cell(tbl, 10, 1, intelIcon, text_color=intelCol, text_size=tblTextSize, tooltip=intelTip)

// end
````
