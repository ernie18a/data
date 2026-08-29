<!-- tradingview-pine-id: PUB;4ec0fcdf1e7b49d68415fc2c925f4291 -->
<!-- tradingviewscripts-format: 1 -->
# MACD Divergence Pro [NQ]

Source: https://www.tradingview.com/script/NDC4wpbc-MACD-Divergence-Pro-NQ/

## Description

MACD Divergence Pro [NQ]
its an indicator that helps you find divergences and continuations on the moving average convergence divergence.

---

## Source Code

````pine
// MACD Divergence Pro — built for Nasdaq (NQ) futures
// Regular + Hidden divergence detection w/ strength scoring, MACD continuation signals, dual-pane drawing, alerts
// Includes optional Early Warning: a live, repainting preview of Regular Divergence AND Continuation before official confirmation
//@version=6
indicator("MACD Divergence Pro [NQ]", shorttitle="MACD Div Pro", overlay=false, format=format.price, precision=4, max_lines_count=500, max_labels_count=500)

// ============================== INPUTS ==============================
grp_macd = "MACD Settings"
fastLength   = input.int(12, "Fast Length", minval=1, group=grp_macd)
slowLength   = input.int(26, "Slow Length", minval=1, group=grp_macd)
signalLength = input.int(9,  "Signal Length", minval=1, group=grp_macd)
srcInput     = input.source(close, "Source", group=grp_macd)
maType       = input.string("EMA", "MA Type", options=["EMA", "SMA"], group=grp_macd)

grp_div = "Divergence Detection"
pivotLeftBars  = input.int(5, "Pivot Left Bars", minval=1, group=grp_div, tooltip="How many bars to the left must be lower/higher to confirm a pivot")
pivotRightBars = input.int(5, "Pivot Right Bars", minval=1, group=grp_div, tooltip="Bars to the right needed to confirm a pivot (adds a small delay but prevents repainting)")
maxLookback    = input.int(60, "Max Bars Between Pivots", minval=1, group=grp_div)
minLookback    = input.int(5,  "Min Bars Between Pivots", minval=1, group=grp_div)

showRegularBull = input.bool(true,  "Regular Bullish (reversal up)",  group=grp_div)
showRegularBear = input.bool(true,  "Regular Bearish (reversal down)", group=grp_div)
showHiddenDiv   = input.bool(false, "Show Hidden Divergence", group=grp_div, tooltip="Toggles both hidden bullish and hidden bearish divergence detection")

grp_strength = "Divergence Strength"
showStrength   = input.bool(true, "Show Strength Score On Labels", group=grp_strength)
strongThresh   = input.int(70, "Strong Threshold", minval=0, maxval=100, group=grp_strength)
mediumThresh   = input.int(40, "Medium Threshold", minval=0, maxval=100, group=grp_strength)
volLookback    = input.int(50, "Volatility Lookback (MACD stdev / ATR)", minval=5, group=grp_strength)
minStrengthToShow = input.int(0, "Minimum Strength To Draw (0=show all)", minval=0, maxval=100, group=grp_strength, tooltip="Filter out weak/low-confidence divergences below this score")

grp_cont = "MACD Continuation Signals"
showContBull = input.bool(true, "Bullish Continuation (trend-up confirmation)", group=grp_cont)
showContBear = input.bool(true, "Bearish Continuation (trend-down confirmation)", group=grp_cont)
colContBull  = input.color(color.new(#00e676, 40), "Bullish Continuation Color", group=grp_cont)
colContBear  = input.color(color.new(#ff1744, 40), "Bearish Continuation Color", group=grp_cont)

grp_style = "Display"
lineWidthInput = input.int(2, "Line Width", minval=1, maxval=6, group=grp_style, tooltip="Applies to all divergence and continuation lines")
lineStyleInput = input.string("Solid", "Line Style", options=["Solid", "Dashed", "Dotted"], group=grp_style, tooltip="Applies to all divergence and continuation lines")
colBullReg = input.color(color.new(#00e676, 0), "Regular Bullish Color", group=grp_style)
colBearReg = input.color(color.new(#ff1744, 0), "Regular Bearish Color", group=grp_style)
colBullHid = input.color(color.new(#00bcd4, 0), "Hidden Bullish Color", group=grp_style)
colBearHid = input.color(color.new(#ff9100, 0), "Hidden Bearish Color", group=grp_style)
drawOnPriceChart = input.bool(true, "Draw Divergence Lines On Price Chart Too", group=grp_style)
showLabels = input.bool(true, "Show Text Labels", group=grp_style)

grp_early = "Early Warning (Repainting)"
showEarlyWarning   = input.bool(false, "Show Early/Provisional Signals", group=grp_early, tooltip="Live preview of Regular Divergence and Continuation signals before official confirmation. This CAN move or vanish as new bars form. Treat it as a heads-up, not a trade trigger. No alert fires for this signal.")
earlyTransparency  = input.int(60, "Early Signal Transparency", minval=0, maxval=90, group=grp_early, tooltip="Higher = more faded, to visually separate it from confirmed signals")

// ============================== MACD CALC ==============================
fastMA = maType == "EMA" ? ta.ema(srcInput, fastLength) : ta.sma(srcInput, fastLength)
slowMA = maType == "EMA" ? ta.ema(srcInput, slowLength) : ta.sma(srcInput, slowLength)
macdLine   = fastMA - slowMA
signalLine = maType == "EMA" ? ta.ema(macdLine, signalLength) : ta.sma(macdLine, signalLength)
histLine   = macdLine - signalLine

// classic 4-color histogram
histColor = histLine >= 0 ?
     (histLine > histLine[1] ? color.new(#26a69a, 0)  : color.new(#26a69a, 55)) :
     (histLine < histLine[1] ? color.new(#ef5350, 0)  : color.new(#ef5350, 55))

plot(histLine, title="Histogram", style=plot.style_columns, color=histColor)
plot(macdLine, title="MACD", color=color.new(#2962ff, 0), linewidth=2)
plot(signalLine, title="Signal", color=color.new(#ff6d00, 0), linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 60))

// ============================== VOLATILITY REFERENCES (for strength scoring) ==============================
macdVola = ta.stdev(macdLine, volLookback)
atrPct   = ta.atr(14) / close * 100

// ============================== STRENGTH SCORING ==============================
f_strength(float macdDelta, float priceDeltaPct, int barDist) =>
    macdScore  = macdVola > 0 ? math.min(math.abs(macdDelta) / (macdVola * 2) * 100, 100) : 0.0
    priceScore = atrPct > 0 ? math.min(priceDeltaPct / (atrPct * 2) * 100, 100) : 0.0
    distScore  = math.max(0.0, 100.0 - (barDist / float(maxLookback) * 100.0))
    score = macdScore * 0.45 + priceScore * 0.35 + distScore * 0.20
    math.round(score)

f_tier(float score) =>
    tier = score >= strongThresh ? "S" : score >= mediumThresh ? "M" : "W"
    tier

f_labelText(string base, float score) =>
    txt = showStrength ? base + " " + str.tostring(score) + " (" + f_tier(score) + ")" : base
    txt

f_lineStyle() =>
    style = lineStyleInput == "Solid" ? line.style_solid : lineStyleInput == "Dashed" ? line.style_dashed : line.style_solid
    style

// ============================== PIVOT STORAGE ==============================
pivHighMACD = ta.pivothigh(macdLine, pivotLeftBars, pivotRightBars)
pivLowMACD  = ta.pivotlow(macdLine, pivotLeftBars, pivotRightBars)

var array<int>   phBar   = array.new<int>()
var array<float> phMacd  = array.new<float>()
var array<float> phPrice = array.new<float>()

var array<int>   plBar   = array.new<int>()
var array<float> plMacd  = array.new<float>()
var array<float> plPrice = array.new<float>()

maxStore = 50

// live (continuously-updating) trackers for Early Warning -- the running extremum of the leg still in progress
var float liveLowMacd   = na
var float liveLowPrice  = na
var int   liveLowBar    = na
var float liveHighMacd  = na
var float liveHighPrice = na
var int   liveHighBar   = na

if na(liveLowBar) or macdLine < liveLowMacd
    liveLowMacd := macdLine
    liveLowPrice := low
    liveLowBar := bar_index

if na(liveHighBar) or macdLine > liveHighMacd
    liveHighMacd := macdLine
    liveHighPrice := high
    liveHighBar := bar_index

if not na(pivHighMACD)
    idx = bar_index - pivotRightBars
    array.push(phBar, idx)
    array.push(phMacd, pivHighMACD)
    array.push(phPrice, high[pivotRightBars])
    if array.size(phBar) > maxStore
        array.shift(phBar)
        array.shift(phMacd)
        array.shift(phPrice)
    liveHighBar := na  // leg just confirmed -> reset tracker to start fresh on the next leg

if not na(pivLowMACD)
    idx = bar_index - pivotRightBars
    array.push(plBar, idx)
    array.push(plMacd, pivLowMACD)
    array.push(plPrice, low[pivotRightBars])
    if array.size(plBar) > maxStore
        array.shift(plBar)
        array.shift(plMacd)
        array.shift(plPrice)
    liveLowBar := na  // leg just confirmed -> reset tracker to start fresh on the next leg

// ============================== DIVERGENCE + CONTINUATION LOGIC ==============================
bullRegFired = false
bearRegFired = false
bullHidFired = false
bearHidFired = false
contBullFired = false
contBearFired = false

if not na(pivLowMACD) and array.size(plBar) >= 2
    n = array.size(plBar)
    curBar   = array.get(plBar, n - 1)
    curMacd  = array.get(plMacd, n - 1)
    curPrice = array.get(plPrice, n - 1)
    prevBar   = array.get(plBar, n - 2)
    prevMacd  = array.get(plMacd, n - 2)
    prevPrice = array.get(plPrice, n - 2)
    dist = curBar - prevBar
    macdDelta = curMacd - prevMacd
    priceDeltaPct = prevPrice != 0 ? math.abs(curPrice - prevPrice) / prevPrice * 100 : 0.0
    score = f_strength(macdDelta, priceDeltaPct, dist)

    if dist >= minLookback and dist <= maxLookback and score >= minStrengthToShow
        // Regular Bullish: price makes a lower low, MACD makes a higher low
        if showRegularBull and curPrice < prevPrice and curMacd > prevMacd
            bullRegFired := true
            line.new(prevBar, prevMacd, curBar, curMacd, color=colBullReg, width=lineWidthInput, style=f_lineStyle())
            if showLabels
                label.new(curBar, curMacd, f_labelText("Div", score), style=label.style_label_up, color=colBullReg, textcolor=color.white, size=size.tiny)
            if drawOnPriceChart
                line.new(prevBar, prevPrice, curBar, curPrice, color=colBullReg, width=lineWidthInput, style=f_lineStyle(), force_overlay=true)
                if showLabels
                    label.new(curBar, curPrice, f_labelText("Div", score), style=label.style_label_up, color=colBullReg, textcolor=color.white, size=size.tiny, force_overlay=true)

        // Hidden Bullish: price makes a higher low, MACD makes a lower low
        if showHiddenDiv and curPrice > prevPrice and curMacd < prevMacd
            bullHidFired := true
            line.new(prevBar, prevMacd, curBar, curMacd, color=colBullHid, width=lineWidthInput, style=f_lineStyle())
            if showLabels
                label.new(curBar, curMacd, f_labelText("H.Div", score), style=label.style_label_up, color=colBullHid, textcolor=color.white, size=size.tiny)
            if drawOnPriceChart
                line.new(prevBar, prevPrice, curBar, curPrice, color=colBullHid, width=lineWidthInput, style=f_lineStyle(), force_overlay=true)
                if showLabels
                    label.new(curBar, curPrice, f_labelText("H.Div", score), style=label.style_label_up, color=colBullHid, textcolor=color.white, size=size.tiny, force_overlay=true)

        // Continuation Bullish: price AND MACD both make higher lows (uptrend confirmed, no divergence)
        if showContBull and curPrice > prevPrice and curMacd > prevMacd
            contBullFired := true
            line.new(prevBar, prevMacd, curBar, curMacd, color=colContBull, width=lineWidthInput, style=f_lineStyle())
            if showLabels
                label.new(curBar, curMacd, f_labelText("Cont", score), style=label.style_label_up, color=colContBull, textcolor=color.white, size=size.tiny)
            if drawOnPriceChart
                line.new(prevBar, prevPrice, curBar, curPrice, color=colContBull, width=lineWidthInput, style=f_lineStyle(), force_overlay=true)
                if showLabels
                    label.new(curBar, curPrice, f_labelText("Cont", score), style=label.style_label_up, color=colContBull, textcolor=color.white, size=size.tiny, force_overlay=true)

if not na(pivHighMACD) and array.size(phBar) >= 2
    n = array.size(phBar)
    curBar   = array.get(phBar, n - 1)
    curMacd  = array.get(phMacd, n - 1)
    curPrice = array.get(phPrice, n - 1)
    prevBar   = array.get(phBar, n - 2)
    prevMacd  = array.get(phMacd, n - 2)
    prevPrice = array.get(phPrice, n - 2)
    dist = curBar - prevBar
    macdDelta = curMacd - prevMacd
    priceDeltaPct = prevPrice != 0 ? math.abs(curPrice - prevPrice) / prevPrice * 100 : 0.0
    score = f_strength(macdDelta, priceDeltaPct, dist)

    if dist >= minLookback and dist <= maxLookback and score >= minStrengthToShow
        // Regular Bearish: price makes a higher high, MACD makes a lower high
        if showRegularBear and curPrice > prevPrice and curMacd < prevMacd
            bearRegFired := true
            line.new(prevBar, prevMacd, curBar, curMacd, color=colBearReg, width=lineWidthInput, style=f_lineStyle())
            if showLabels
                label.new(curBar, curMacd, f_labelText("Div", score), style=label.style_label_down, color=colBearReg, textcolor=color.white, size=size.tiny)
            if drawOnPriceChart
                line.new(prevBar, prevPrice, curBar, curPrice, color=colBearReg, width=lineWidthInput, style=f_lineStyle(), force_overlay=true)
                if showLabels
                    label.new(curBar, curPrice, f_labelText("Div", score), style=label.style_label_down, color=colBearReg, textcolor=color.white, size=size.tiny, force_overlay=true)

        // Hidden Bearish: price makes a lower high, MACD makes a higher high
        if showHiddenDiv and curPrice < prevPrice and curMacd > prevMacd
            bearHidFired := true
            line.new(prevBar, prevMacd, curBar, curMacd, color=colBearHid, width=lineWidthInput, style=f_lineStyle())
            if showLabels
                label.new(curBar, curMacd, f_labelText("H.Div", score), style=label.style_label_down, color=colBearHid, textcolor=color.white, size=size.tiny)
            if drawOnPriceChart
                line.new(prevBar, prevPrice, curBar, curPrice, color=colBearHid, width=lineWidthInput, style=f_lineStyle(), force_overlay=true)
                if showLabels
                    label.new(curBar, curPrice, f_labelText("H.Div", score), style=label.style_label_down, color=colBearHid, textcolor=color.white, size=size.tiny, force_overlay=true)

        // Continuation Bearish: price AND MACD both make lower highs (downtrend confirmed, no divergence)
        if showContBear and curPrice < prevPrice and curMacd < prevMacd
            contBearFired := true
            line.new(prevBar, prevMacd, curBar, curMacd, color=colContBear, width=lineWidthInput, style=f_lineStyle())
            if showLabels
                label.new(curBar, curMacd, f_labelText("Cont", score), style=label.style_label_down, color=colContBear, textcolor=color.white, size=size.tiny)
            if drawOnPriceChart
                line.new(prevBar, prevPrice, curBar, curPrice, color=colContBear, width=lineWidthInput, style=f_lineStyle(), force_overlay=true)
                if showLabels
                    label.new(curBar, curPrice, f_labelText("Cont", score), style=label.style_label_down, color=colContBear, textcolor=color.white, size=size.tiny, force_overlay=true)

// ============================== EARLY WARNING (repainting preview) ==============================
// Compares the live, still-forming extremum against the last OFFICIALLY confirmed pivot.
// Covers Regular Divergence AND Continuation. Updates every bar while the leg develops;
// clears once the leg either confirms above or the condition breaks.
var line  earlyBullLineMacd   = na
var label earlyBullLabelMacd  = na
var line  earlyBullLinePrice  = na
var label earlyBullLabelPrice = na

var line  earlyBearLineMacd   = na
var label earlyBearLabelMacd  = na
var line  earlyBearLinePrice  = na
var label earlyBearLabelPrice = na

var line  earlyContBullLineMacd   = na
var label earlyContBullLabelMacd  = na
var line  earlyContBullLinePrice  = na
var label earlyContBullLabelPrice = na

var line  earlyContBearLineMacd   = na
var label earlyContBearLabelMacd  = na
var line  earlyContBearLinePrice  = na
var label earlyContBearLabelPrice = na

if not showEarlyWarning
    if not na(earlyBullLineMacd)
        line.delete(earlyBullLineMacd)
        earlyBullLineMacd := na
    if not na(earlyBullLabelMacd)
        label.delete(earlyBullLabelMacd)
        earlyBullLabelMacd := na
    if not na(earlyBullLinePrice)
        line.delete(earlyBullLinePrice)
        earlyBullLinePrice := na
    if not na(earlyBullLabelPrice)
        label.delete(earlyBullLabelPrice)
        earlyBullLabelPrice := na
    if not na(earlyBearLineMacd)
        line.delete(earlyBearLineMacd)
        earlyBearLineMacd := na
    if not na(earlyBearLabelMacd)
        label.delete(earlyBearLabelMacd)
        earlyBearLabelMacd := na
    if not na(earlyBearLinePrice)
        line.delete(earlyBearLinePrice)
        earlyBearLinePrice := na
    if not na(earlyBearLabelPrice)
        label.delete(earlyBearLabelPrice)
        earlyBearLabelPrice := na
    if not na(earlyContBullLineMacd)
        line.delete(earlyContBullLineMacd)
        earlyContBullLineMacd := na
    if not na(earlyContBullLabelMacd)
        label.delete(earlyContBullLabelMacd)
        earlyContBullLabelMacd := na
    if not na(earlyContBullLinePrice)
        line.delete(earlyContBullLinePrice)
        earlyContBullLinePrice := na
    if not na(earlyContBullLabelPrice)
        label.delete(earlyContBullLabelPrice)
        earlyContBullLabelPrice := na
    if not na(earlyContBearLineMacd)
        line.delete(earlyContBearLineMacd)
        earlyContBearLineMacd := na
    if not na(earlyContBearLabelMacd)
        label.delete(earlyContBearLabelMacd)
        earlyContBearLabelMacd := na
    if not na(earlyContBearLinePrice)
        line.delete(earlyContBearLinePrice)
        earlyContBearLinePrice := na
    if not na(earlyContBearLabelPrice)
        label.delete(earlyContBearLabelPrice)
        earlyContBearLabelPrice := na

if showEarlyWarning
    // ---- Low-side: Regular Bullish Divergence vs Bullish Continuation, both vs live low ----
    bullDivEarlyValid  = false
    contBullEarlyValid = false
    if array.size(plBar) >= 1 and not na(liveLowBar)
        pB = array.get(plBar, array.size(plBar) - 1)
        pM = array.get(plMacd, array.size(plBar) - 1)
        pP = array.get(plPrice, array.size(plBar) - 1)
        eDist = liveLowBar - pB
        withinRangeLow = liveLowBar > pB and eDist >= minLookback and eDist <= maxLookback

        if withinRangeLow and showRegularBull and liveLowPrice < pP and liveLowMacd > pM
            bullDivEarlyValid := true
            eColor = color.new(colBullReg, earlyTransparency)
            eScore = f_strength(liveLowMacd - pM, pP != 0 ? math.abs(liveLowPrice - pP) / pP * 100 : 0.0, eDist)
            if na(earlyBullLineMacd)
                earlyBullLineMacd := line.new(pB, pM, liveLowBar, liveLowMacd, color=eColor, width=1, style=line.style_solid)
            else
                line.set_xy1(earlyBullLineMacd, pB, pM)
                line.set_xy2(earlyBullLineMacd, liveLowBar, liveLowMacd)
                line.set_color(earlyBullLineMacd, eColor)
            if showLabels
                if na(earlyBullLabelMacd)
                    earlyBullLabelMacd := label.new(liveLowBar, liveLowMacd, f_labelText("~Div", eScore), style=label.style_label_up, color=eColor, textcolor=color.white, size=size.tiny)
                else
                    label.set_xy(earlyBullLabelMacd, liveLowBar, liveLowMacd)
                    label.set_text(earlyBullLabelMacd, f_labelText("~Div", eScore))
                    label.set_color(earlyBullLabelMacd, eColor)
            if drawOnPriceChart
                if na(earlyBullLinePrice)
                    earlyBullLinePrice := line.new(pB, pP, liveLowBar, liveLowPrice, color=eColor, width=1, style=line.style_solid, force_overlay=true)
                else
                    line.set_xy1(earlyBullLinePrice, pB, pP)
                    line.set_xy2(earlyBullLinePrice, liveLowBar, liveLowPrice)
                    line.set_color(earlyBullLinePrice, eColor)
                if showLabels
                    if na(earlyBullLabelPrice)
                        earlyBullLabelPrice := label.new(liveLowBar, liveLowPrice, f_labelText("~Div", eScore), style=label.style_label_up, color=eColor, textcolor=color.white, size=size.tiny, force_overlay=true)
                    else
                        label.set_xy(earlyBullLabelPrice, liveLowBar, liveLowPrice)
                        label.set_text(earlyBullLabelPrice, f_labelText("~Div", eScore))
                        label.set_color(earlyBullLabelPrice, eColor)

        if withinRangeLow and showContBull and liveLowPrice > pP and liveLowMacd > pM
            contBullEarlyValid := true
            ecColor = color.new(colContBull, earlyTransparency)
            ecScore = f_strength(liveLowMacd - pM, pP != 0 ? math.abs(liveLowPrice - pP) / pP * 100 : 0.0, eDist)
            if na(earlyContBullLineMacd)
                earlyContBullLineMacd := line.new(pB, pM, liveLowBar, liveLowMacd, color=ecColor, width=1, style=line.style_solid)
            else
                line.set_xy1(earlyContBullLineMacd, pB, pM)
                line.set_xy2(earlyContBullLineMacd, liveLowBar, liveLowMacd)
                line.set_color(earlyContBullLineMacd, ecColor)
            if showLabels
                if na(earlyContBullLabelMacd)
                    earlyContBullLabelMacd := label.new(liveLowBar, liveLowMacd, f_labelText("~Cont", ecScore), style=label.style_label_up, color=ecColor, textcolor=color.white, size=size.tiny)
                else
                    label.set_xy(earlyContBullLabelMacd, liveLowBar, liveLowMacd)
                    label.set_text(earlyContBullLabelMacd, f_labelText("~Cont", ecScore))
                    label.set_color(earlyContBullLabelMacd, ecColor)
            if drawOnPriceChart
                if na(earlyContBullLinePrice)
                    earlyContBullLinePrice := line.new(pB, pP, liveLowBar, liveLowPrice, color=ecColor, width=1, style=line.style_solid, force_overlay=true)
                else
                    line.set_xy1(earlyContBullLinePrice, pB, pP)
                    line.set_xy2(earlyContBullLinePrice, liveLowBar, liveLowPrice)
                    line.set_color(earlyContBullLinePrice, ecColor)
                if showLabels
                    if na(earlyContBullLabelPrice)
                        earlyContBullLabelPrice := label.new(liveLowBar, liveLowPrice, f_labelText("~Cont", ecScore), style=label.style_label_up, color=ecColor, textcolor=color.white, size=size.tiny, force_overlay=true)
                    else
                        label.set_xy(earlyContBullLabelPrice, liveLowBar, liveLowPrice)
                        label.set_text(earlyContBullLabelPrice, f_labelText("~Cont", ecScore))
                        label.set_color(earlyContBullLabelPrice, ecColor)

    if not bullDivEarlyValid
        if not na(earlyBullLineMacd)
            line.delete(earlyBullLineMacd)
            earlyBullLineMacd := na
        if not na(earlyBullLabelMacd)
            label.delete(earlyBullLabelMacd)
            earlyBullLabelMacd := na
        if not na(earlyBullLinePrice)
            line.delete(earlyBullLinePrice)
            earlyBullLinePrice := na
        if not na(earlyBullLabelPrice)
            label.delete(earlyBullLabelPrice)
            earlyBullLabelPrice := na

    if not contBullEarlyValid
        if not na(earlyContBullLineMacd)
            line.delete(earlyContBullLineMacd)
            earlyContBullLineMacd := na
        if not na(earlyContBullLabelMacd)
            label.delete(earlyContBullLabelMacd)
            earlyContBullLabelMacd := na
        if not na(earlyContBullLinePrice)
            line.delete(earlyContBullLinePrice)
            earlyContBullLinePrice := na
        if not na(earlyContBullLabelPrice)
            label.delete(earlyContBullLabelPrice)
            earlyContBullLabelPrice := na

    // ---- High-side: Regular Bearish Divergence vs Bearish Continuation, both vs live high ----
    bearDivEarlyValid  = false
    contBearEarlyValid = false
    if array.size(phBar) >= 1 and not na(liveHighBar)
        pB2 = array.get(phBar, array.size(phBar) - 1)
        pM2 = array.get(phMacd, array.size(phBar) - 1)
        pP2 = array.get(phPrice, array.size(phBar) - 1)
        eDist2 = liveHighBar - pB2
        withinRangeHigh = liveHighBar > pB2 and eDist2 >= minLookback and eDist2 <= maxLookback

        if withinRangeHigh and showRegularBear and liveHighPrice > pP2 and liveHighMacd < pM2
            bearDivEarlyValid := true
            eColor2 = color.new(colBearReg, earlyTransparency)
            eScore2 = f_strength(liveHighMacd - pM2, pP2 != 0 ? math.abs(liveHighPrice - pP2) / pP2 * 100 : 0.0, eDist2)
            if na(earlyBearLineMacd)
                earlyBearLineMacd := line.new(pB2, pM2, liveHighBar, liveHighMacd, color=eColor2, width=1, style=line.style_solid)
            else
                line.set_xy1(earlyBearLineMacd, pB2, pM2)
                line.set_xy2(earlyBearLineMacd, liveHighBar, liveHighMacd)
                line.set_color(earlyBearLineMacd, eColor2)
            if showLabels
                if na(earlyBearLabelMacd)
                    earlyBearLabelMacd := label.new(liveHighBar, liveHighMacd, f_labelText("~Div", eScore2), style=label.style_label_down, color=eColor2, textcolor=color.white, size=size.tiny)
                else
                    label.set_xy(earlyBearLabelMacd, liveHighBar, liveHighMacd)
                    label.set_text(earlyBearLabelMacd, f_labelText("~Div", eScore2))
                    label.set_color(earlyBearLabelMacd, eColor2)
            if drawOnPriceChart
                if na(earlyBearLinePrice)
                    earlyBearLinePrice := line.new(pB2, pP2, liveHighBar, liveHighPrice, color=eColor2, width=1, style=line.style_solid, force_overlay=true)
                else
                    line.set_xy1(earlyBearLinePrice, pB2, pP2)
                    line.set_xy2(earlyBearLinePrice, liveHighBar, liveHighPrice)
                    line.set_color(earlyBearLinePrice, eColor2)
                if showLabels
                    if na(earlyBearLabelPrice)
                        earlyBearLabelPrice := label.new(liveHighBar, liveHighPrice, f_labelText("~Div", eScore2), style=label.style_label_down, color=eColor2, textcolor=color.white, size=size.tiny, force_overlay=true)
                    else
                        label.set_xy(earlyBearLabelPrice, liveHighBar, liveHighPrice)
                        label.set_text(earlyBearLabelPrice, f_labelText("~Div", eScore2))
                        label.set_color(earlyBearLabelPrice, eColor2)

        if withinRangeHigh and showContBear and liveHighPrice < pP2 and liveHighMacd < pM2
            contBearEarlyValid := true
            ecColor2 = color.new(colContBear, earlyTransparency)
            ecScore2 = f_strength(liveHighMacd - pM2, pP2 != 0 ? math.abs(liveHighPrice - pP2) / pP2 * 100 : 0.0, eDist2)
            if na(earlyContBearLineMacd)
                earlyContBearLineMacd := line.new(pB2, pM2, liveHighBar, liveHighMacd, color=ecColor2, width=1, style=line.style_solid)
            else
                line.set_xy1(earlyContBearLineMacd, pB2, pM2)
                line.set_xy2(earlyContBearLineMacd, liveHighBar, liveHighMacd)
                line.set_color(earlyContBearLineMacd, ecColor2)
            if showLabels
                if na(earlyContBearLabelMacd)
                    earlyContBearLabelMacd := label.new(liveHighBar, liveHighMacd, f_labelText("~Cont", ecScore2), style=label.style_label_down, color=ecColor2, textcolor=color.white, size=size.tiny)
                else
                    label.set_xy(earlyContBearLabelMacd, liveHighBar, liveHighMacd)
                    label.set_text(earlyContBearLabelMacd, f_labelText("~Cont", ecScore2))
                    label.set_color(earlyContBearLabelMacd, ecColor2)
            if drawOnPriceChart
                if na(earlyContBearLinePrice)
                    earlyContBearLinePrice := line.new(pB2, pP2, liveHighBar, liveHighPrice, color=ecColor2, width=1, style=line.style_solid, force_overlay=true)
                else
                    line.set_xy1(earlyContBearLinePrice, pB2, pP2)
                    line.set_xy2(earlyContBearLinePrice, liveHighBar, liveHighPrice)
                    line.set_color(earlyContBearLinePrice, ecColor2)
                if showLabels
                    if na(earlyContBearLabelPrice)
                        earlyContBearLabelPrice := label.new(liveHighBar, liveHighPrice, f_labelText("~Cont", ecScore2), style=label.style_label_down, color=ecColor2, textcolor=color.white, size=size.tiny, force_overlay=true)
                    else
                        label.set_xy(earlyContBearLabelPrice, liveHighBar, liveHighPrice)
                        label.set_text(earlyContBearLabelPrice, f_labelText("~Cont", ecScore2))
                        label.set_color(earlyContBearLabelPrice, ecColor2)

    if not bearDivEarlyValid
        if not na(earlyBearLineMacd)
            line.delete(earlyBearLineMacd)
            earlyBearLineMacd := na
        if not na(earlyBearLabelMacd)
            label.delete(earlyBearLabelMacd)
            earlyBearLabelMacd := na
        if not na(earlyBearLinePrice)
            line.delete(earlyBearLinePrice)
            earlyBearLinePrice := na
        if not na(earlyBearLabelPrice)
            label.delete(earlyBearLabelPrice)
            earlyBearLabelPrice := na

    if not contBearEarlyValid
        if not na(earlyContBearLineMacd)
            line.delete(earlyContBearLineMacd)
            earlyContBearLineMacd := na
        if not na(earlyContBearLabelMacd)
            label.delete(earlyContBearLabelMacd)
            earlyContBearLabelMacd := na
        if not na(earlyContBearLinePrice)
            line.delete(earlyContBearLinePrice)
            earlyContBearLinePrice := na
        if not na(earlyContBearLabelPrice)
            label.delete(earlyContBearLabelPrice)
            earlyContBearLabelPrice := na

// ============================== ALERTS ==============================
alertcondition(bullRegFired, title="Regular Bullish Divergence", message="MACD Divergence Pro: Regular Bullish Divergence on {{ticker}} {{interval}}")
alertcondition(bearRegFired, title="Regular Bearish Divergence", message="MACD Divergence Pro: Regular Bearish Divergence on {{ticker}} {{interval}}")
alertcondition(bullHidFired, title="Hidden Bullish Divergence",  message="MACD Divergence Pro: Hidden Bullish Divergence on {{ticker}} {{interval}}")
alertcondition(bearHidFired, title="Hidden Bearish Divergence",  message="MACD Divergence Pro: Hidden Bearish Divergence on {{ticker}} {{interval}}")
alertcondition(contBullFired, title="Bullish Continuation", message="MACD Divergence Pro: Bullish Continuation on {{ticker}} {{interval}}")
alertcondition(contBearFired, title="Bearish Continuation", message="MACD Divergence Pro: Bearish Continuation on {{ticker}} {{interval}}")
````
