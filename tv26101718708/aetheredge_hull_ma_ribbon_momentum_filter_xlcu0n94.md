# AetherEdge - Hull MA Ribbon + Momentum Filter

- url: https://www.tradingview.com/script/XLCu0n94/
- type: indicator
- pine_id: PUB;0b087b7d3efd4390bfbc79ea5a882520
- version: 1.0

## Description

🖊️ Overview
AetherEdge Hull MA Ribbon + Momentum Filter is a next-generation trend visualization engine that fuses the ultra-low-latency characteristics of Hull Moving Averages (HMA) with a composite RSI+MACD momentum score. Six HMA ribbons trace price flow with smooth precision, while a 7-tier color gradient evolves dynamically with real-time momentum strength. This is a professional visual analysis tool that captures both direction and strength of trend at a glance.

🔶 Key Features

6-Line HMA Ribbon: Smooth, responsive trend visualization powered by ultra-low-latency Hull MA
RSI+MACD Composite Momentum Score: Weight-adjustable hybrid indicator
7-Tier Strength Categorization: Strong Bull / Bull / Weak Bull / Neutral / Weak Bear / Bear / Strong Bear
Perfect Stacking Detection: Identifies maximum trend strength via 6-line full alignment
Dynamic Gradient Coloring: Bold inner, fading outer—professional visual
Ribbon Alignment Filter: Suppresses signal false positives
Cross Signal Detection: Auto-marks trend reversal points
Integrated Dashboard: Momentum %, strength category, ribbon state at a glance
Dark Mode Support: AetherEdge premium UI
🧠 Technical Architecture
This indicator integrates Hull MA's mathematical superiority with multi-factor momentum analysis—a refined trend analysis system.

Hull MA Formula: HMA(n) = WMA(2*WMA(n/2) − WMA(n), sqrt(n))—solves traditional MA lag via double-WMA differential and sqrt-smoothing. Reaction speed approximately 2x that of EMA.
6-Line Ribbon Structure: baseLen + step×0–5 arithmetic progression. Gradient from short-term (h1) to long-term (h6), visualizing trend hierarchy.
Momentum Score Composition Logic:
RSI Normalization: (RSI − 50) / 50 mapped to -1 to +1
MACD Histogram Normalization: hist / stdev(hist, 100) standardized, clipped at ±3, divided by 3
Weighted Average: rsiWeight × RSInorm + (1−rsiWeight) × MACDnorm
Final output displayed as 0–100% momentum index
Ribbon Direction Detection: ribbonUp/Down determined by slope of central HMAs (h3, h4)
Perfect Stacking: h1>h2>h3>h4>h5>h6 full alignment certifies maximum trend strength
7-Tier Strength Classification:
+3 (Strong Bull): High momentum + up + perfect alignment
+2 (Bull): High momentum + up
+1 (Weak Bull): Mid momentum + up
0 (Neutral): No directional bias
−1 to −3: Symmetrical bearish judgment
Dynamic Coloring: Entire ribbon shifts across 7 colors based on strengthCat
⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–Daily): baseLen=20, step=8, rsiWeight=0.5 (standard balance)
ETH (1H–4H): baseLen=15, step=6 prioritizing reaction speed
SOL (High-Vol): baseLen=25, step=10 for noise reduction
XRP (Range): strongLvl=70, weakLvl=30 for strict judgment
Tuning Guide:

Day Trading: baseLen=10-15, step=5, primary 1H/15M
Swing: baseLen=30-50, step=10 for macro trends
Scalping: baseLen=8, step=4 for ultra-short-term response
Momentum-Focused: rsiWeight=0.7 for higher RSI weight (effective in range)
Trend-Focused: rsiWeight=0.3 for higher MACD weight (strong trend detection)
Excess Signals: strongLvl=70+ for selectivity
Few Signals: strongLvl=60 + ribbonAlign=false to relax
💡 How to Use in Practice

★★★ STRONG BULL/BEAR: Maximum confluence, optimal for trend-following entries
Ribbon Expansion: Widening 6-line spread indicates trend acceleration—pullback long / rebound short recommended
Ribbon Contraction: Converging 6 lines = breakout precursor warning
Color Transition Points: Bull→Neutral→Bear shifts = early trend reversal alerts
Multi-Timeframe Synergy: Higher-TF Strong Bull + lower-TF pullback = perfect entry
AetherEdge Synergy:
Order Block + FVG Detector OB retest + Strong Bull color = ultra-high-conviction entry
Self-Evolving S/R Grid strong line + ribbon directional match = enhanced target precision
Squeeze Breaker breakout + ribbon expansion = trend continuation confirmation
Stop Loss: When price penetrates entire ribbon in opposite direction
⚠️ Important Notes

False Signals in Sideways Markets: Frequent color shifts in range; tune weakLvl/strongLvl
Ribbon Alignment Lag: Perfect stacking requires bar progression
MACD Normalization Period: Stdev calculation requires 100 bars; initial wait period
HMA Characteristics: Fast response carries overshoot risk in volatile moves
Hull MA Re-Entrance: Watch for minor reversals immediately after turning points
🚨 Disclaimer
This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Trend and momentum evaluations based on historical price data do not guarantee future market behavior. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - Hull MA Ribbon + Momentum Filter", "AE-HullRibbon", overlay=true, max_labels_count=100, max_lines_count=100)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpR = "① Hull Ribbon"
ribbonEnable = input.bool(true, "Show Ribbon", group=grpR)
baseLen      = input.int(20, "Base Length", minval=4, maxval=200, group=grpR)
step         = input.int(8,  "Length Step (between lines)", minval=2, maxval=30, group=grpR)
lineWidth    = input.int(2,  "Line Width", minval=1, maxval=4, group=grpR)
fillRibbon   = input.bool(true, "Fill Between Lines", group=grpR)
src          = input.source(close, "Source", group=grpR)

grpM = "② Momentum Filter"
momEnable    = input.bool(true, "Apply Momentum Coloring", group=grpM)
rsiLen       = input.int(14, "RSI Length", minval=2, maxval=100, group=grpM)
macdFast     = input.int(12, "MACD Fast", minval=2, maxval=100, group=grpM)
macdSlow     = input.int(26, "MACD Slow", minval=5, maxval=200, group=grpM)
macdSig      = input.int(9,  "MACD Signal", minval=2, maxval=50, group=grpM)
rsiWeight    = input.float(0.5, "RSI Weight", minval=0.0, maxval=1.0, step=0.1, group=grpM)
strongLvl    = input.float(65.0, "Strong Trend Threshold (%)", minval=50.0, maxval=95.0, step=1.0, group=grpM)
weakLvl      = input.float(35.0, "Weak Trend Threshold (%)",   minval=5.0,  maxval=50.0, step=1.0, group=grpM)

grpS = "③ Signals"
sigEnable    = input.bool(true, "Show Cross Signals", group=grpS)
ribbonAlign  = input.bool(true, "Require Ribbon Alignment", group=grpS)

grpUI = "🎨 Display"
darkMode     = input.bool(true, "Dark Mode", group=grpUI)
showDash     = input.bool(true, "Show Dashboard", group=grpUI)
dashPos      = input.string("Top Right", "Dashboard Position",
               options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpUI)

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg     = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt  = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText   = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute   = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent = color.new(#00d4ff, 0)

// Strength gradient colors (bullish → bearish)
cStrongBull = color.new(#00ffa3, 0)
cBull       = color.new(#00d4a0, 0)
cWeakBull   = color.new(#5ee8b8, 0)
cNeutral    = color.new(#8892b0, 0)
cWeakBear   = color.new(#ff9aa9, 0)
cBear       = color.new(#ff5577, 0)
cStrongBear = color.new(#ff2d55, 0)

// ═══════════════════════════════════════════════════════════════
//  HULL MA FUNCTION
//  HMA(n) = WMA(2*WMA(n/2) − WMA(n), sqrt(n))
// ═══════════════════════════════════════════════════════════════
f_hma(s, len) =>
    halfLen = math.max(2, math.round(len / 2))
    sqrtLen = math.max(2, math.round(math.sqrt(len)))
    ta.wma(2 * ta.wma(s, halfLen) - ta.wma(s, len), sqrtLen)

// 6 ribbon lengths
len1 = baseLen
len2 = baseLen + step
len3 = baseLen + step * 2
len4 = baseLen + step * 3
len5 = baseLen + step * 4
len6 = baseLen + step * 5

h1 = f_hma(src, len1)
h2 = f_hma(src, len2)
h3 = f_hma(src, len3)
h4 = f_hma(src, len4)
h5 = f_hma(src, len5)
h6 = f_hma(src, len6)

// ═══════════════════════════════════════════════════════════════
//  MOMENTUM SCORE
//  Combine RSI (centered at 50) + MACD histogram (normalized)
// ═══════════════════════════════════════════════════════════════
rsiVal  = ta.rsi(src, rsiLen)
rsiNorm = (rsiVal - 50.0) / 50.0  // -1 .. +1

[macdLine, sigLine, macdHist] = ta.macd(src, macdFast, macdSlow, macdSig)
macdNormRaw = macdHist / ta.stdev(macdHist, 100)
macdNorm = nz(math.max(-3.0, math.min(3.0, macdNormRaw))) / 3.0  // -1 .. +1

momRaw = rsiWeight * rsiNorm + (1.0 - rsiWeight) * macdNorm
mom = math.max(-1.0, math.min(1.0, momRaw))   // -1 .. +1
momPct = (mom + 1.0) * 50.0                   // 0 .. 100

// Ribbon direction (from slope of middle HMA)
ribbonUp   = h3 > h3[1] and h4 > h4[1]
ribbonDown = h3 < h3[1] and h4 < h4[1]

// Stacking quality: perfect bullish = h1>h2>h3>h4>h5>h6
perfectBull = h1 > h2 and h2 > h3 and h3 > h4 and h4 > h5 and h5 > h6
perfectBear = h1 < h2 and h2 < h3 and h3 < h4 and h4 < h5 and h5 < h6

// ═══════════════════════════════════════════════════════════════
//  STRENGTH CATEGORY
// ═══════════════════════════════════════════════════════════════
strengthCat = 0
// 3 = strong bull, 2 = bull, 1 = weak bull
// 0 = neutral
// -1 = weak bear, -2 = bear, -3 = strong bear
if momPct >= strongLvl and ribbonUp and perfectBull
    strengthCat := 3
else if momPct >= strongLvl and ribbonUp
    strengthCat := 2
else if momPct > 50.0 and ribbonUp
    strengthCat := 1
else if momPct <= (100.0 - strongLvl) and ribbonDown and perfectBear
    strengthCat := -3
else if momPct <= (100.0 - strongLvl) and ribbonDown
    strengthCat := -2
else if momPct < 50.0 and ribbonDown
    strengthCat := -1
else
    strengthCat := 0

f_stColor(cat) =>
    switch cat
        3  => cStrongBull
        2  => cBull
        1  => cWeakBull
        0  => cNeutral
        -1 => cWeakBear
        -2 => cBear
        -3 => cStrongBear

f_stText(cat) =>
    switch cat
        3  => "★★★ STRONG BULL"
        2  => "★★ BULL"
        1  => "★ WEAK BULL"
        0  => "— NEUTRAL"
        -1 => "★ WEAK BEAR"
        -2 => "★★ BEAR"
        -3 => "★★★ STRONG BEAR"

ribbonCol = momEnable ? f_stColor(strengthCat) : cAccent

// Fade outer lines, keep inner bold
col1 = color.new(ribbonCol, 0)
col2 = color.new(ribbonCol, 15)
col3 = color.new(ribbonCol, 30)
col4 = color.new(ribbonCol, 45)
col5 = color.new(ribbonCol, 60)
col6 = color.new(ribbonCol, 75)

// ═══════════════════════════════════════════════════════════════
//  PLOT RIBBON
// ═══════════════════════════════════════════════════════════════
p1 = plot(ribbonEnable ? h1 : na, "HMA 1 (fastest)", color=col1, linewidth=lineWidth)
p2 = plot(ribbonEnable ? h2 : na, "HMA 2", color=col2, linewidth=lineWidth)
p3 = plot(ribbonEnable ? h3 : na, "HMA 3", color=col3, linewidth=lineWidth)
p4 = plot(ribbonEnable ? h4 : na, "HMA 4", color=col4, linewidth=lineWidth)
p5 = plot(ribbonEnable ? h5 : na, "HMA 5", color=col5, linewidth=lineWidth)
p6 = plot(ribbonEnable ? h6 : na, "HMA 6 (slowest)", color=col6, linewidth=lineWidth)

fill(p1, p2, color=fillRibbon ? color.new(ribbonCol, 82) : na, title="Fill 1-2")
fill(p2, p3, color=fillRibbon ? color.new(ribbonCol, 85) : na, title="Fill 2-3")
fill(p3, p4, color=fillRibbon ? color.new(ribbonCol, 88) : na, title="Fill 3-4")
fill(p4, p5, color=fillRibbon ? color.new(ribbonCol, 91) : na, title="Fill 4-5")
fill(p5, p6, color=fillRibbon ? color.new(ribbonCol, 94) : na, title="Fill 5-6")

// ═══════════════════════════════════════════════════════════════
//  SIGNALS — price/fastest HMA cross + ribbon alignment filter
// ═══════════════════════════════════════════════════════════════
crossUp   = ta.crossover(h1,  h2)
crossDown = ta.crossunder(h1, h2)

validBull = sigEnable and crossUp   and (not ribbonAlign or perfectBull) and momPct > 50.0
validBear = sigEnable and crossDown and (not ribbonAlign or perfectBear) and momPct < 50.0

plotshape(validBull, title="Buy Signal", style=shape.triangleup,   location=location.belowbar,
     color=cStrongBull, size=size.small, text="BUY",  textcolor=color.black)
plotshape(validBear, title="Sell Signal", style=shape.triangledown, location=location.abovebar,
     color=cStrongBear, size=size.small, text="SELL", textcolor=color.white)

// Subtle background tint on extremes
bgcolor(momEnable and strengthCat ==  3 ? color.new(cStrongBull, 94) : na, title="Strong Bull BG")
bgcolor(momEnable and strengthCat == -3 ? color.new(cStrongBear, 94) : na, title="Strong Bear BG")

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

f_bar(v, width) =>
    n = math.max(0, math.min(width, math.round(v * width)))
    result = ""
    for i = 0 to width - 1
        result := result + (i < n ? "█" : "░")
    result

var table dash = na
if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 2, 12, bgcolor=cBg, border_color=cBorder, border_width=1, frame_color=cAccent, frame_width=1)

    // Header
    table.cell(dash, 0, 0, "★ AETHEREDGE  HULL RIBBON ★", text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "PRICE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 1, str.tostring(close, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center)

    // Trend strength
    stCol = f_stColor(strengthCat)
    table.cell(dash, 0, 2, "TREND STATE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 2, f_stText(strengthCat), text_color=color.white, bgcolor=color.new(stCol, 30), text_halign=text.align_center, text_size=size.small)

    // Momentum score bar
    table.cell(dash, 0, 3, "MOMENTUM", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 3, f_bar(momPct / 100.0, 10) + "  " + str.tostring(momPct, "#.0") + "%", text_color=stCol, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // RSI
    rsiCol = rsiVal > 70 ? cStrongBull : rsiVal > 55 ? cBull : rsiVal < 30 ? cStrongBear : rsiVal < 45 ? cBear : cMute
    table.cell(dash, 0, 4, "RSI(" + str.tostring(rsiLen) + ")", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(rsiVal, "#.0"), text_color=color.white, bgcolor=color.new(rsiCol, 40), text_halign=text.align_center)

    // MACD histogram
    macdCol = macdHist > 0 and macdHist > macdHist[1] ? cStrongBull :
              macdHist > 0 ? cBull :
              macdHist < 0 and macdHist < macdHist[1] ? cStrongBear : cBear
    macdTxt = macdHist > 0 ? "▲ " : "▼ "
    table.cell(dash, 0, 5, "MACD HIST", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 5, macdTxt + str.tostring(macdHist, format.mintick), text_color=color.white, bgcolor=color.new(macdCol, 40), text_halign=text.align_center)

    // Ribbon stacking
    stackTxt = perfectBull ? "▲ PERFECT BULL STACK" : perfectBear ? "▼ PERFECT BEAR STACK" : "≈ MIXED"
    stackCol = perfectBull ? cStrongBull : perfectBear ? cStrongBear : cMute
    table.cell(dash, 0, 6, "RIBBON STACK", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 6, stackTxt, text_color=color.white, bgcolor=color.new(stackCol, 30), text_halign=text.align_center, text_size=size.small)

    // Ribbon slope
    slopeTxt = ribbonUp ? "▲ RISING" : ribbonDown ? "▼ FALLING" : "→ FLAT"
    slopeCol = ribbonUp ? cBull : ribbonDown ? cBear : cMute
    table.cell(dash, 0, 7, "RIBBON SLOPE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 7, slopeTxt, text_color=color.white, bgcolor=color.new(slopeCol, 40), text_halign=text.align_center)

    // HMA values
    table.cell(dash, 0, 8, "HMA FAST (" + str.tostring(len1) + ")", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 8, str.tostring(h1, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 9, "HMA SLOW (" + str.tostring(len6) + ")", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.tostring(h6, format.mintick), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Spread (ribbon width)
    spread    = math.abs(h1 - h6)
    spreadPct = close > 0 ? spread / close * 100.0 : 0.0
    table.cell(dash, 0, 10, "RIBBON SPREAD", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 10, str.tostring(spreadPct, "#.00") + "%", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Last signal
    var string lastSig = "—"
    var color  lastSigCol = cMute
    if validBull
        lastSig := "▲ BUY"
        lastSigCol := cStrongBull
    if validBear
        lastSig := "▼ SELL"
        lastSigCol := cStrongBear
    table.cell(dash, 0, 11, "LAST SIGNAL", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 11, lastSig, text_color=color.white, bgcolor=color.new(lastSigCol, 40), text_halign=text.align_center, text_size=size.small)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(validBull, "Hull Ribbon BUY",  "AetherEdge: HMA cross + momentum aligned (BUY)")
alertcondition(validBear, "Hull Ribbon SELL", "AetherEdge: HMA cross + momentum aligned (SELL)")
alertcondition(strengthCat ==  3 and strengthCat[1] !=  3, "Strong Bull Regime",  "AetherEdge: Entered STRONG BULL trend")
alertcondition(strengthCat == -3 and strengthCat[1] != -3, "Strong Bear Regime",  "AetherEdge: Entered STRONG BEAR trend")
alertcondition(perfectBull and not perfectBull[1], "Perfect Bull Stack", "AetherEdge: HMA perfect bull stacking")
alertcondition(perfectBear and not perfectBear[1], "Perfect Bear Stack", "AetherEdge: HMA perfect bear stacking")
````
