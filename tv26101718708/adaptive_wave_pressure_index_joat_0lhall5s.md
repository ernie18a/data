# Adaptive Wave Pressure Index [JOAT]

- url: https://www.tradingview.com/script/0lhAlL5s-Adaptive-Wave-Pressure-Index-JOAT/
- type: indicator
- pine_id: PUB;927b4906472247abb04566d33871572d
- version: 1.0

## Description

[b]Adaptive Wave Pressure Index [JOAT][/b]

[b]Introduction[/b]

Adaptive Wave Pressure Index [JOAT] is a normalized slope oscillator built to measure directional pressure through the relationship between regression slope and volatility. By scaling a manually calculated OLS slope with ATR, the script produces a dimensionless momentum reading that can be compared across instruments and timeframes much more cleanly than raw slope alone.

This indicator is designed for traders who want wave pressure, not just speed. It tracks directional force, smooths that force into fast and slow lines, colors the histogram using structural swing context, and adds divergence detection for potential exhaustion.

[image]https://www.tradingview.com/x/Bmi1CnJX/[/image]

[b]Why This Indicator Exists[/b]

[list]
[*][b]Volatility-Normalized Momentum:[/b] Regression slope is scaled by ATR to improve comparability
[*][b]Fast / Slow Pressure Read:[/b] Reveals acceleration and deceleration of directional force
[*][b]Structure Overlay:[/b] Swing-sequence counts add context to histogram strength
[*][b]Zone Framework:[/b] Overbought and oversold thresholds define pressure extremes
[*][b]Divergence Layer:[/b] Flags when price reaches new extremes without matching pressure
[/list]

[b]Core Components Explained[/b]

[b]1. Manual OLS Slope[/b]

[pine]
rawSlope = f_olsSlope(regLength)
[/pine]

The script calculates slope directly from the last N closes rather than relying on a built-in regression shortcut. This provides more control over normalization and display logic.

[b]2. ATR Normalization[/b]

[pine]
normSlope = rawSlope / ta.atr(atrNormPeriod)
[/pine]

Dividing slope by ATR transforms it into a volatility-aware measure of pressure. A positive slope on a low-volatility asset and a positive slope on a high-volatility asset become more comparable after normalization.

[b]3. Fast / Slow Pressure System[/b]

Two EMAs are applied to the normalized slope:

[list]
[*][b]Fast Line:[/b] More responsive pressure state
[*][b]Slow Line:[/b] More stable reference
[*][b]Histogram:[/b] Spread between fast and slow, showing acceleration or fade
[/list]

[b]4. Structural Sequence Layer[/b]

The indicator also counts consecutive higher lows and lower highs in price. When structure strongly supports the current pressure direction, histogram colors intensify. This adds a valuable distinction between pressure that is statistically rising and pressure that is also structurally confirmed.

[b]5. Divergence and Zone Logic[/b]

The script highlights:

[list]
[*]Fast-line crosses of overbought and oversold thresholds
[*]Fast/slow line crosses
[*]Bullish and bearish divergences
[/list]

Divergence lines are retained with a fixed cap so the pane stays readable over time.

[b]Visual Elements[/b]

[list]
[*][b]Histogram:[/b] Pressure spread with structural-intensity color logic
[*][b]Fast Line:[/b] Main directional read
[*][b]Slow Line:[/b] Reference pressure line
[*][b]Zero Fill:[/b] Directional bias area fill
[*][b]OB/OS Background:[/b] Soft zone shading for extreme pressure
[*][b]Markers:[/b] Crosses and divergence markers
[*][b]Dashboard:[/b] Raw slope, normalized slope, trend, structure sequence, divergence, and active zone
[/list]

[b]Input Parameters[/b]

[list]
[*][b]Regression Length:[/b] Window for OLS slope calculation
[*][b]ATR Norm Period:[/b] Volatility baseline used for normalization
[*][b]Fast / Slow EMA:[/b] Pressure responsiveness controls
[*][b]OB / OS Levels:[/b] Extreme pressure thresholds
[*][b]Pivot Left / Right:[/b] Sensitivity for structural and divergence logic
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Read whether fast is above or below slow.  
[b]Step 2:[/b] Check the histogram to see whether pressure is expanding or contracting.  
[b]Step 3:[/b] Use the sequence readout to judge whether price structure agrees with the oscillator.  
[b]Step 4:[/b] Treat divergences as warnings that pressure may be weakening.  
[b]Step 5:[/b] Use OB/OS events to identify stretched pressure, especially after large runs.

[b]Best Practices[/b]

[list]
[*]Use on instruments with clean swings and sufficient range
[*]Respect signals more when sequence direction agrees with fast/slow direction
[*]Use divergence with structure, not by itself
[*]Increase regression length for smoother wave pressure
[*]Lower lengths react faster but create more noise
[/list]

[b]Indicator Limitations[/b]

[list]
[*]Normalized slope improves comparison but does not eliminate market differences
[*]Pressure can stay elevated in strong trends
[*]Divergences can persist before price turns
[*]Short settings increase false transitions
[*]Structure counts are descriptive, not predictive
[/list]

[b]Technical Implementation[/b]

Built in Pine Script v6 using:
[list]
[*]Manual OLS slope computation
[*]ATR normalization
[*]Dual-EMA pressure smoothing
[*]Pivot-based structure counting
[*]Capped divergence-line management
[*]Confirmed-bar signal generation
[/list]

[b]Originality Statement[/b]

This indicator is original in the way it combines normalized regression slope, structural sequence intensity, and divergence management into a single wave-pressure framework. Its purpose is not just to show direction, but to show how forceful and how structurally supported that direction is.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Momentum and divergence tools can fail, especially during volatile transitions. Always use proper risk management and independent confirmation.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Adaptive Wave Pressure Index [JOAT]", shorttitle="AWPI [JOAT]", overlay=false, max_labels_count=120, max_lines_count=120)

grp_core = "Core Settings"
grp_div = "Divergence Settings"
grp_sig = "Signal Filters"
grp_vis = "Visual Settings"
grp_table = "Dashboard"

i_reg_len = input.int(20, "Regression Length", minval=5, maxval=200, group=grp_core)
i_atr_norm = input.int(14, "ATR Norm Period", minval=1, maxval=100, group=grp_core)
i_fast_smooth = input.int(5, "Fast EMA", minval=1, maxval=100, group=grp_core)
i_slow_smooth = input.int(13, "Slow EMA", minval=2, maxval=200, group=grp_core)
i_ob_level = input.float(0.5, "Overbought Level", minval=0.01, maxval=10.0, step=0.01, group=grp_core)
i_os_level = input.float(-0.5, "Oversold Level", minval=-10.0, maxval=-0.01, step=0.01, group=grp_core)
i_hist_peak_up = input.float(0.15, "Histogram Peak Upper", minval=0.01, maxval=5.0, step=0.01, group=grp_sig)
i_hist_peak_lo = input.float(-0.15, "Histogram Peak Lower", minval=-5.0, maxval=-0.01, step=0.01, group=grp_sig)
i_use_dynamic_levels = input.bool(true, "Dynamic OB/OS Opacity", group=grp_sig)
i_min_transp = input.int(85, "Weak Level Transparency", minval=0, maxval=100, group=grp_sig)
i_max_transp = input.int(10, "Strong Level Transparency", minval=0, maxval=100, group=grp_sig)
i_pivot_left = input.int(5, "Pivot Left", minval=1, maxval=20, group=grp_div)
i_pivot_right = input.int(5, "Pivot Right", minval=1, maxval=20, group=grp_div)
i_show_div = input.bool(true, "Show Divergence", group=grp_div)
i_bull_col = input.color(#00c2a8, "Bull Color", group=grp_vis)
i_bear_col = input.color(#ff7a21, "Bear Color", group=grp_vis)
i_show_barcolor = input.bool(true, "Show Candle Coloring", group=grp_vis)
i_show_glow = input.bool(true, "Show Glow Lines", group=grp_vis)
i_show_bg = input.bool(true, "Show Bias Background", group=grp_vis)
i_show_marks = input.bool(true, "Show Markers", group=grp_vis)
i_show_heat_cloud = input.bool(true, "Show Heat Cloud", group=grp_vis)
i_show_wave_ribbon = input.bool(true, "Show Wave Ribbon", group=grp_vis)
i_show_table = input.bool(true, "Show Dashboard", group=grp_table)
i_table_pos = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grp_table)
i_table_size = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_table)

MAX_DIV_LINES = 24

f_tpos(s) =>
    switch s
        "Top Left" => position.top_left
        "Top Right" => position.top_right
        "Bottom Left" => position.bottom_left
        => position.bottom_right

f_tsize(s) =>
    switch s
        "Tiny" => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal

f_remap(val, inMin, inMax, outMin, outMax) =>
    outMin + (val - inMin) * (outMax - outMin) / math.max(inMax - inMin, 1e-10)

f_dynamicLevelColor(level, src, baseColor, levelAbs) =>
    if not i_use_dynamic_levels
        baseColor
    else
        rawDist = math.abs(level - src)
        clamped = math.max(0.0, math.min(rawDist, levelAbs))
        transp = math.round(f_remap(clamped, 0.0, levelAbs, i_max_transp, i_min_transp))
        color.new(baseColor, transp)

f_olsSlope(n) =>
    sampleSize = math.max(math.min(n, bar_index + 1), 2)
    float sumX = 0.0
    float sumY = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    for i = 0 to sampleSize - 1
        x = float(sampleSize - 1 - i)
        y = close[i]
        sumX += x
        sumY += y
        sumXY += x * y
        sumX2 += x * x
    denom = float(sampleSize) * sumX2 - sumX * sumX
    denom == 0.0 ? 0.0 : (float(sampleSize) * sumXY - sumX * sumY) / denom

rawSlope = f_olsSlope(i_reg_len)
normSlope = rawSlope / math.max(ta.atr(i_atr_norm), 1e-10)
fastLine = ta.ema(normSlope, i_fast_smooth)
slowLine = ta.ema(normSlope, i_slow_smooth)
hist = fastLine - slowLine
trendUp = fastLine > slowLine

crossAboveOB = barstate.isconfirmed and ta.crossover(fastLine, i_ob_level)
crossBelowOS = barstate.isconfirmed and ta.crossunder(fastLine, i_os_level)
bullCross = barstate.isconfirmed and ta.crossover(fastLine, slowLine)
bearCross = barstate.isconfirmed and ta.crossunder(fastLine, slowLine)
isOB = fastLine > i_ob_level
isOS = fastLine < i_os_level

pivotHighPrice = ta.pivothigh(high, i_pivot_left, i_pivot_right)
pivotLowPrice = ta.pivotlow(low, i_pivot_left, i_pivot_right)
var float lastPivotHighPrice = na
var float lastPivotLowPrice = na
var int upSequenceCount = 0
var int downSequenceCount = 0
if barstate.isconfirmed and not na(pivotHighPrice)
    downSequenceCount := not na(lastPivotHighPrice) and pivotHighPrice < lastPivotHighPrice ? downSequenceCount + 1 : 1
    lastPivotHighPrice := pivotHighPrice
if barstate.isconfirmed and not na(pivotLowPrice)
    upSequenceCount := not na(lastPivotLowPrice) and pivotLowPrice > lastPivotLowPrice ? upSequenceCount + 1 : 1
    lastPivotLowPrice := pivotLowPrice

fastPivotHigh = ta.pivothigh(fastLine, i_pivot_left, i_pivot_right)
fastPivotLow = ta.pivotlow(fastLine, i_pivot_left, i_pivot_right)
var float lastFastPivotHigh = na
var float lastFastPivotLow = na
var float lastFastPivotPriceHigh = na
var float lastFastPivotPriceLow = na
var int lastFastPivotHighBar = na
var int lastFastPivotLowBar = na
var line[] divLines = array.new_line()

f_storeDivLine(line newLine) =>
    array.push(divLines, newLine)
    if array.size(divLines) > MAX_DIV_LINES
        line oldLine = array.shift(divLines)
        line.delete(oldLine)

bearDiv = false
bullDiv = false
if barstate.isconfirmed and not na(fastPivotHigh)
    if not na(lastFastPivotHigh) and not na(lastFastPivotPriceHigh) and fastPivotHigh < lastFastPivotHigh and high[i_pivot_right] > lastFastPivotPriceHigh
        bearDiv := true
        if i_show_div
            newDivLine = line.new(lastFastPivotHighBar, lastFastPivotHigh, bar_index - i_pivot_right, fastPivotHigh, color=color.new(i_bear_col, 15), width=1, style=line.style_dashed)
            f_storeDivLine(newDivLine)
    lastFastPivotHigh := fastPivotHigh
    lastFastPivotPriceHigh := high[i_pivot_right]
    lastFastPivotHighBar := bar_index - i_pivot_right
if barstate.isconfirmed and not na(fastPivotLow)
    if not na(lastFastPivotLow) and not na(lastFastPivotPriceLow) and fastPivotLow > lastFastPivotLow and low[i_pivot_right] < lastFastPivotPriceLow
        bullDiv := true
        if i_show_div
            newDivLine = line.new(lastFastPivotLowBar, lastFastPivotLow, bar_index - i_pivot_right, fastPivotLow, color=color.new(i_bull_col, 15), width=1, style=line.style_dashed)
            f_storeDivLine(newDivLine)
    lastFastPivotLow := fastPivotLow
    lastFastPivotPriceLow := low[i_pivot_right]
    lastFastPivotLowBar := bar_index - i_pivot_right

histCol = hist > 0 ? (upSequenceCount >= 3 ? i_bull_col : color.new(i_bull_col, hist > hist[1] ? 20 : 55)) : (downSequenceCount >= 3 ? i_bear_col : color.new(i_bear_col, hist < hist[1] ? 20 : 55))
seqStr = upSequenceCount >= downSequenceCount ? "UP x" + str.tostring(upSequenceCount) : "DN x" + str.tostring(downSequenceCount)
seqCol = upSequenceCount >= downSequenceCount ? i_bull_col : i_bear_col
histPeakUp = barstate.isconfirmed and hist < hist[1] and hist[1] > hist[2] and hist[1] > i_hist_peak_up
histPeakDown = barstate.isconfirmed and hist > hist[1] and hist[1] < hist[2] and hist[1] < i_hist_peak_lo
pressureScore = math.min(math.abs(normSlope) * 100.0, 100.0)
waveStrength = math.min(math.abs(fastLine) / math.max(math.abs(i_ob_level), 1e-10), 1.0)
awpiBarCol = i_show_barcolor ? color.from_gradient(waveStrength, 0.0, 1.0, color.new(trendUp ? i_bull_col : i_bear_col, 70), trendUp ? i_bull_col : i_bear_col) : na
wavePersistence = trendUp ? ta.barssince(not trendUp) : ta.barssince(trendUp)
signalState = bullCross ? "BULL CROSS" : bearCross ? "BEAR CROSS" : histPeakUp ? "PEAK DOWN" : histPeakDown ? "PEAK UP" : bullDiv ? "BULL DIV" : bearDiv ? "BEAR DIV" : "IDLE"
zeroBias = fastLine >= 0 ? "ABOVE ZERO" : "BELOW ZERO"
signalDensity = (bullCross ? 1 : 0) + (bearCross ? 1 : 0) + (histPeakUp ? 1 : 0) + (histPeakDown ? 1 : 0) + (bullDiv ? 1 : 0) + (bearDiv ? 1 : 0)
waveSpread = math.abs(fastLine - slowLine)
zonePersistence = isOB ? ta.barssince(not isOB) : isOS ? ta.barssince(not isOS) : 0
structureState = upSequenceCount > downSequenceCount ? "STRUCT UP" : downSequenceCount > upSequenceCount ? "STRUCT DOWN" : "STRUCT FLAT"
trendStrength = math.min(math.abs(fastLine) * 100.0, 100.0)
waveEnergy = math.min(waveSpread * 100.0, 100.0)
divergenceState = bullDiv ? "BULL DIV" : bearDiv ? "BEAR DIV" : "NONE"
pressureZone = fastLine > i_ob_level ? "UPPER EXTREME" : fastLine < i_os_level ? "LOWER EXTREME" : "NEUTRAL ZONE"
pressureBalance = math.min(math.abs(fastLine + slowLine) * 50.0, 100.0)
cycleState = bullCross ? "UP CYCLE" : bearCross ? "DOWN CYCLE" : trendUp ? "BULL HOLD" : "BEAR HOLD"
reversalRisk = bullDiv or bearDiv or histPeakUp or histPeakDown ? math.min(waveEnergy + pressureScore * 0.5, 100.0) : waveEnergy * 0.5
zoneBiasScore = math.min(math.abs(fastLine) / math.max(math.abs(i_ob_level), 1e-10) * 100.0, 100.0)
obPersistence = isOB ? ta.barssince(not isOB) : 0
osPersistence = isOS ? ta.barssince(not isOS) : 0
histState = hist > 0 ? "POS HIST" : hist < 0 ? "NEG HIST" : "FLAT HIST"
lineState = fastLine > slowLine ? "FAST LEADS" : fastLine < slowLine ? "SLOW LEADS" : "TIED"
driveState = trendUp and fastLine >= 0 ? "BULL DRIVE" : not trendUp and fastLine <= 0 ? "BEAR DRIVE" : "ROTATION"
signalPressure = math.min(signalDensity * 15.0 + waveEnergy * 0.5, 100.0)
wavePulse = math.min(math.abs(hist - hist[1]) * 160.0, 100.0)
waveAcceleration = math.min(math.abs(fastLine - fastLine[1]) * 120.0, 100.0)
meanReversionIndex = math.min(math.abs(normSlope - fastLine) * 45.0, 100.0)
controlScore = math.min((pressureScore * 0.35) + (waveEnergy * 0.35) + (wavePulse * 0.30), 100.0)
flowState = trendUp and wavePulse >= 35 ? "BULL EXPANSION" : not trendUp and wavePulse >= 35 ? "BEAR EXPANSION" : waveEnergy >= 40 ? "TREND DRIVE" : "BALANCED"
waveRibbonTop = math.max(fastLine, slowLine)
waveRibbonBottom = math.min(fastLine, slowLine)
strongBullImpulse = bullCross and wavePulse >= 25 and fastLine >= 0
strongBearImpulse = bearCross and wavePulse >= 25 and fastLine <= 0
heatBias = hist >= 0 ? pressureScore : 100.0 - pressureScore
waveEcho = fastLine * 0.65 + hist * 0.35
barcolor(awpiBarCol, title="AWPI Candle Color")

hline(i_ob_level, "OB", color=color.new(i_bear_col, 40), linestyle=hline.style_dashed)
hline(i_os_level, "OS", color=color.new(i_bull_col, 40), linestyle=hline.style_dashed)
hline(0.0, "Zero", color=color.new(color.gray, 55), linestyle=hline.style_dashed)
plot(i_use_dynamic_levels ? i_ob_level : na, "Dynamic OB", color=f_dynamicLevelColor(i_ob_level, fastLine, i_bear_col, math.abs(i_ob_level)), linewidth=3)
plot(i_use_dynamic_levels ? i_os_level : na, "Dynamic OS", color=f_dynamicLevelColor(i_os_level, fastLine, i_bull_col, math.abs(i_os_level)), linewidth=3)
plot(hist, "Histogram", color=histCol, style=plot.style_columns)
plot(i_show_glow ? fastLine : na, "Fast Glow Outer", color=color.new(trendUp ? i_bull_col : i_bear_col, 88), linewidth=7)
plot(i_show_glow ? fastLine : na, "Fast Glow Mid", color=color.new(trendUp ? i_bull_col : i_bear_col, 76), linewidth=5)
pFast = plot(fastLine, "Fast Line", color=trendUp ? i_bull_col : i_bear_col, linewidth=2)
plot(i_show_glow ? slowLine : na, "Slow Glow", color=color.new(#ffd700, 88), linewidth=4)
pSlow = plot(slowLine, "Slow Line", color=color.new(#ffd700, 20), linewidth=1)
plot(i_show_glow ? waveEcho : na, "Wave Echo", color=color.new(#00d4ff, 70), linewidth=2)
pZero = plot(0.0, display=display.none)
fill(pFast, pZero, color=color.new(trendUp ? i_bull_col : i_bear_col, 85))
fill(pFast, pSlow, color=color.new(trendUp ? i_bull_col : i_bear_col, 88))
plot(i_show_heat_cloud ? waveRibbonTop : na, "Wave Ribbon Top", color=color.new(trendUp ? i_bull_col : i_bear_col, 95), linewidth=1)
plot(i_show_heat_cloud ? waveRibbonBottom : na, "Wave Ribbon Bottom", color=color.new(trendUp ? i_bull_col : i_bear_col, 95), linewidth=1)
pWaveRibbonTop = plot(i_show_wave_ribbon ? waveRibbonTop : na, "Wave Ribbon High", color=color.new(trendUp ? i_bull_col : i_bear_col, 72), linewidth=1)
pWaveRibbonBottom = plot(i_show_wave_ribbon ? waveRibbonBottom : na, "Wave Ribbon Low", color=color.new(trendUp ? i_bull_col : i_bear_col, 72), linewidth=1)
fill(pWaveRibbonTop, pWaveRibbonBottom, color=color.new(trendUp ? i_bull_col : i_bear_col, 90))
bgcolor(i_show_bg and isOB ? color.new(i_bear_col, 92) : na)
bgcolor(i_show_bg and isOS ? color.new(i_bull_col, 92) : na)
bgcolor(i_show_bg and trendUp and fastLine > 0 and fastLine < i_ob_level ? color.new(i_bull_col, 96) : na)
bgcolor(i_show_bg and not trendUp and fastLine < 0 and fastLine > i_os_level ? color.new(i_bear_col, 96) : na)
bgcolor(i_show_heat_cloud and controlScore >= 70 ? color.new(trendUp ? i_bull_col : i_bear_col, 95) : na)

plotshape(i_show_marks and crossAboveOB, "OB Cross", style=shape.triangledown, location=location.top, color=i_bear_col, size=size.tiny)
plotshape(i_show_marks and crossBelowOS, "OS Cross", style=shape.triangleup, location=location.bottom, color=i_bull_col, size=size.tiny)
plotshape(i_show_marks and bullCross, "Bull Cross", style=shape.circle, location=location.bottom, color=color.new(i_bull_col, 20), size=size.tiny)
plotshape(i_show_marks and bearCross, "Bear Cross", style=shape.circle, location=location.top, color=color.new(i_bear_col, 20), size=size.tiny)
plotshape(i_show_marks and histPeakUp, "Hist Peak Up", style=shape.diamond, location=location.top, color=color.new(i_bear_col, 20), size=size.tiny)
plotshape(i_show_marks and histPeakDown, "Hist Peak Down", style=shape.diamond, location=location.bottom, color=color.new(i_bull_col, 20), size=size.tiny)
plotshape(i_show_marks and i_show_div and bullDiv, "Bull Div", style=shape.square, location=location.bottom, color=i_bull_col, size=size.tiny)
plotshape(i_show_marks and i_show_div and bearDiv, "Bear Div", style=shape.square, location=location.top, color=i_bear_col, size=size.tiny)
plotshape(i_show_marks and strongBullImpulse, "Strong Bull Wave", style=shape.triangleup, location=location.bottom, color=color.new(i_bull_col, 0), size=size.small)
plotshape(i_show_marks and strongBearImpulse, "Strong Bear Wave", style=shape.triangledown, location=location.top, color=color.new(i_bear_col, 0), size=size.small)

var table dash = na
if i_show_table
    if na(dash)
        dash := table.new(position.top_right, 2, 9, bgcolor=#1a1a2e, border_color=#333355, border_width=1, frame_color=#444466, frame_width=1)
    if barstate.islast
        sz = size.normal
        zoneStr = isOB ? "OVERBOUGHT" : isOS ? "OVERSOLD" : trendUp ? "BULL ZONE" : "BEAR ZONE"
        zoneCol = isOB ? i_bear_col : isOS ? i_bull_col : trendUp ? i_bull_col : i_bear_col
        table.cell(dash, 0, 0, "AWPI [JOAT]", text_color=#ffd700, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 1, 0, "VALUE", text_color=#aaaacc, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 0, 1, "Trend", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 1, trendUp ? "BULL" : "BEAR", text_color=trendUp ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 2, "Wave Stack", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 2, seqStr, text_color=seqCol, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 3, "Signal", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 3, signalState, text_color=signalState == "IDLE" ? #ccccdd : zoneCol, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 4, "Pressure", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 4, str.tostring(pressureScore, "#.0") + "%", text_color=pressureScore > 50 ? zoneCol : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 5, "Echo", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 5, str.tostring(waveEcho, "#.###"), text_color=#00d4ff, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 6, "Flow State", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 6, flowState, text_color=trendUp ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 7, "Control", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 7, str.tostring(controlScore, "#.0") + "%", text_color=controlScore >= 50 ? zoneCol : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 8, "Wave Pulse", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 8, str.tostring(wavePulse, "#.0") + "%", text_color=wavePulse >= 50 ? #ffd700 : #ccccdd, text_size=sz, bgcolor=#111122)

alertcondition(crossAboveOB, "AWPI: OB Cross", "AWPI [JOAT]: fast line crossed above overbought.")
alertcondition(crossBelowOS, "AWPI: OS Cross", "AWPI [JOAT]: fast line crossed below oversold.")
alertcondition(bullCross, "AWPI: Bull Cross", "AWPI [JOAT]: fast line crossed above slow line.")
alertcondition(bearCross, "AWPI: Bear Cross", "AWPI [JOAT]: fast line crossed below slow line.")
alertcondition(histPeakUp, "AWPI: Histogram Peak Up", "AWPI [JOAT]: histogram peaked in the upper pressure zone.")
alertcondition(histPeakDown, "AWPI: Histogram Peak Down", "AWPI [JOAT]: histogram troughed in the lower pressure zone.")
alertcondition(bullDiv, "AWPI: Bull Divergence", "AWPI [JOAT]: bullish divergence detected.")
alertcondition(bearDiv, "AWPI: Bear Divergence", "AWPI [JOAT]: bearish divergence detected.")
````
