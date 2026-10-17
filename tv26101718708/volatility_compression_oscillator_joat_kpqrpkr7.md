# Volatility Compression Oscillator [JOAT]

- url: https://www.tradingview.com/script/KpQrPKr7-Volatility-Compression-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;3a99ff25243548db88f296781ca13f14
- version: 1.0

## Description

[b]Volatility Compression Oscillator [JOAT][/b]

[b]Introduction[/b]

Volatility Compression Oscillator [JOAT] is a two-line momentum oscillator that measures where price is trading inside a dynamic volatility envelope, then tracks the compression and release of that positioning through line crosses, histogram rotation, and divergence. It is designed to show when price is quietly loading pressure, when that pressure starts to expand, and when expansion may be exhausting.

This script is useful for traders who want more than a standard bounded oscillator. It combines normalized price location, dual smoothing, histogram analysis, and divergence into one compact pane.

[image]https://www.tradingview.com/x/CQvBuMcd/[/image]

[b]Why This Indicator Exists[/b]

[list]
[*][b]Adaptive Normalization:[/b] Measures price against a volatility-sensitive envelope instead of a fixed formula
[*][b]Two-Speed Momentum Read:[/b] Uses fast and slow lines to reveal early shifts in pressure
[*][b]Compression / Release Logic:[/b] The histogram shows whether momentum is accelerating or fading
[*][b]Exhaustion Markers:[/b] Histogram peaks and troughs help spot unstable extensions
[*][b]Divergence Layer:[/b] Tracks when price makes a new swing but oscillator pressure does not confirm
[/list]

[b]Core Components Explained[/b]

[b]1. Dynamic Volatility Envelope[/b]

[pine]
offset = avgRange * scale * (1 + avgBody / avgRange)
[/pine]

The script centers the envelope around the candle midpoint average, then expands it with both average range and average body contribution. This makes the oscillator adaptive to both volatility and candle conviction.

[b]2. Normalized Oscillator Calculation[/b]

[pine]
rawOsc = 100 * (close - lowerBand) / bandWidth - 50
[/pine]

Price is transformed into a centered oscillator that measures whether price is trading in the upper or lower half of the active volatility envelope.

[b]3. Dual-Smoothing Engine[/b]

The raw oscillator is processed through fast and slow smoothing chains. Their relationship drives the main trend reading:

[list]
[*]Fast above slow = bullish pressure
[*]Fast below slow = bearish pressure
[*]Histogram expanding = pressure increasing
[*]Histogram fading = pressure weakening
[/list]

[b]4. Signal Layers[/b]

The indicator produces several distinct signal families:

[list]
[*][b]MA Cross Signals:[/b] Momentum handoff between fast and slow lines
[*][b]OB/OS Crosses:[/b] Stretch events when Line 1 crosses the thresholds
[*][b]Histogram Peaks / Troughs:[/b] Local exhaustion cues
[*][b]Divergences:[/b] Price making a stronger swing while oscillator pressure weakens
[/list]

[b]5. Chart Cleanliness Controls[/b]

Divergence lines are retained with an internal cap so the script does not keep drawing indefinitely. This keeps the pane readable and reduces object-limit risk on long-running charts.

[b]Visual Elements[/b]

[list]
[*][b]Histogram Columns:[/b] Momentum spread between fast and slow lines
[*][b]Fast Line:[/b] Main directional pressure line
[*][b]Slow Line:[/b] Reference trend line
[*][b]Zero Fill:[/b] Directional fill from Line 1 to the centerline
[*][b]OB/OS Background:[/b] Soft shading in stretch conditions
[*][b]Signal Markers:[/b] Circles, triangles, diamonds, and squares for different event types
[*][b]Dashboard:[/b] Trend, line values, histogram value, regime, and divergence state
[/list]

[b]Input Parameters[/b]

[list]
[*][b]Volatility Window:[/b] Lookback for midpoint, body, and range normalization
[*][b]Band Scale %:[/b] Width multiplier for the adaptive envelope
[*][b]OB / OS Levels:[/b] Stretch boundaries for Line 1
[*][b]Line 1 / Line 2 Smoothing:[/b] Controls responsiveness of the dual-line engine
[*][b]Pivot Length:[/b] Sensitivity for divergence and histogram turning points
[*][b]Histogram Peak Levels:[/b] Defines stronger exhaustion zones
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Determine whether fast is above or below slow.  
[b]Step 2:[/b] Watch the histogram for acceleration or decay.  
[b]Step 3:[/b] Use MA crosses for timing only when they occur in sensible zones.  
[b]Step 4:[/b] Treat OB/OS signals as context for stretch, not automatic reversal commands.  
[b]Step 5:[/b] Respect divergences most when they align with histogram exhaustion.

[b]Best Practices[/b]

[list]
[*]Use higher pivot lengths when markets are noisy
[*]Treat histogram turns near extremes as better-quality warnings
[*]Use line crosses in the direction of the higher-timeframe trend
[*]Avoid overreacting to every divergence in strong trends
[*]Keep marker display on only if you actively trade the signal layer
[/list]

[b]Indicator Limitations[/b]

[list]
[*]Oscillators can stay overbought or oversold in strong trends
[*]Divergences are warning signs, not standalone trade systems
[*]Short smoothing lengths will create more noise
[*]Compression readings can fail to expand immediately
[*]Signal quality depends heavily on market structure and instrument behavior
[/list]

[b]Technical Implementation[/b]

Built in Pine Script v6 using:
[list]
[*]Adaptive volatility-band normalization
[*]Dual-smoothed oscillator lines
[*]Histogram spread calculation
[*]Pivot-based divergence detection
[*]Object-retention caps for divergence lines
[*]Confirmed-bar signal logic
[/list]

[b]Originality Statement[/b]

This indicator is original in how it frames volatility compression and release through normalized envelope location, dual-line momentum, histogram exhaustion, and divergence management in one pane. Its value comes from synthesis and signal layering rather than from any single oscillator component alone.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Oscillator signals can fail, especially in volatile or trendless conditions. Always use proper risk management and independent judgment.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volatility Compression Oscillator [JOAT]", shorttitle="VCO [JOAT]", overlay=false, max_labels_count=150, max_lines_count=150)

grp_core = "Core Settings"
grp_div = "Divergence Settings"
grp_sig = "Signal Filters"
grp_vis = "Visual Settings"
grp_table = "Dashboard"

i_vol_window = input.int(10, "Volatility Window", minval=2, maxval=200, group=grp_core)
i_band_scale = input.float(200.0, "Band Scale %", minval=10.0, maxval=1000.0, step=10.0, group=grp_core)
i_ob_level = input.float(25.0, "Overbought Level", minval=5.0, maxval=99.0, group=grp_core)
i_os_level = input.float(-25.0, "Oversold Level", minval=-99.0, maxval=-5.0, group=grp_core)
i_smooth1_ema = input.int(7, "Line 1 EMA", minval=1, maxval=100, group=grp_core)
i_ma1_len = input.int(5, "Line 1 SMA", minval=1, maxval=100, group=grp_core)
i_smooth2_ema = input.int(10, "Line 2 EMA", minval=1, maxval=100, group=grp_core)
i_ma2_len = input.int(5, "Line 2 SMA", minval=1, maxval=100, group=grp_core)
i_pivot_len = input.int(2, "Divergence Pivot Length", minval=1, maxval=10, group=grp_div)
i_show_div = input.bool(true, "Show Divergence", group=grp_div)
i_hist_peak_up = input.float(3.0, "Histogram Peak Upper", minval=0.1, maxval=100.0, step=0.1, group=grp_sig)
i_hist_peak_lo = input.float(-3.0, "Histogram Peak Lower", minval=-100.0, maxval=-0.1, step=0.1, group=grp_sig)
i_bull_r_up = input.float(20.0, "Bull Range Upper", minval=0.1, maxval=100.0, step=0.1, group=grp_sig)
i_bull_r_lo = input.float(1.0, "Bull Range Lower", minval=-100.0, maxval=100.0, step=0.1, group=grp_sig)
i_bear_r_up = input.float(-1.0, "Bear Range Upper", minval=-100.0, maxval=100.0, step=0.1, group=grp_sig)
i_bear_r_lo = input.float(-20.0, "Bear Range Lower", minval=-100.0, maxval=-0.1, step=0.1, group=grp_sig)
i_use_dynamic_levels = input.bool(true, "Dynamic OB/OS Opacity", group=grp_sig)
i_min_transp = input.int(85, "Weak Level Transparency", minval=0, maxval=100, group=grp_sig)
i_max_transp = input.int(10, "Strong Level Transparency", minval=0, maxval=100, group=grp_sig)

i_bull_col = input.color(#06a22f, "Bull Color", group=grp_vis)
i_bear_col = input.color(#cf1717, "Bear Color", group=grp_vis)
i_show_barcolor = input.bool(true, "Show Candle Coloring", group=grp_vis)
i_show_glow = input.bool(true, "Show Glow Lines", group=grp_vis)
i_show_bg = input.bool(true, "Show Bias Background", group=grp_vis)
i_show_marks = input.bool(true, "Show Markers", group=grp_vis)
i_show_heat_cloud = input.bool(true, "Show Heat Cloud", group=grp_vis)
i_show_signal_ribbon = input.bool(true, "Show Signal Ribbon", group=grp_vis)
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

candleMid = (high + low) / 2.0
midSma = ta.sma(candleMid, i_vol_window)
avgRange = ta.sma(high - low, i_vol_window)
avgBody = ta.sma(math.abs(close - open), i_vol_window)
offset = avgRange * i_band_scale / 100.0 * (1.0 + avgBody / math.max(avgRange, 1e-10))
rawOsc = 100.0 * (close - (midSma - offset)) / math.max(2.0 * offset, 1e-10) - 50.0
oscValue = math.max(math.min(rawOsc, 100.0), -100.0)

ma1 = ta.sma(ta.ema(oscValue, i_smooth1_ema), i_ma1_len)
ma2 = ta.sma(ta.ema(oscValue, i_smooth2_ema), i_ma2_len)
hist = ma1 - ma2
trendUp = ma1 > ma2

maCross = barstate.isconfirmed and ta.crossover(ma1, ma2)
maCrossDown = barstate.isconfirmed and ta.crossunder(ma1, ma2)
bullMACross = maCross and ma1 >= i_bull_r_lo and ma1 <= i_bull_r_up
bearMACross = maCrossDown and ma1 >= i_bear_r_lo and ma1 <= i_bear_r_up
crossAboveOB = barstate.isconfirmed and ta.crossover(ma1, i_ob_level)
crossBelowOS = barstate.isconfirmed and ta.crossunder(ma1, i_os_level)

histPivHi = ta.pivothigh(hist, i_pivot_len, i_pivot_len)
histPivLo = ta.pivotlow(hist, i_pivot_len, i_pivot_len)
histPeakUp = barstate.isconfirmed and not na(histPivHi) and histPivHi > i_hist_peak_up
histPeakDown = barstate.isconfirmed and not na(histPivLo) and histPivLo < i_hist_peak_lo

pivHiOsc = ta.pivothigh(ma1, i_pivot_len, i_pivot_len)
pivLoOsc = ta.pivotlow(ma1, i_pivot_len, i_pivot_len)
var float lastOscHi = na
var float lastOscLo = na
var float lastPriceHi = na
var float lastPriceLo = na
var int lastOscHiBar = na
var int lastOscLoBar = na
var line[] divLines = array.new_line()

f_storeDivLine(line newLine) =>
    array.push(divLines, newLine)
    if array.size(divLines) > MAX_DIV_LINES
        oldLine = array.shift(divLines)
        line.delete(oldLine)

bearDiv = false
bullDiv = false
if barstate.isconfirmed and not na(pivHiOsc)
    if not na(lastOscHi) and not na(lastPriceHi) and pivHiOsc < lastOscHi and high[i_pivot_len] > lastPriceHi
        bearDiv := true
        if i_show_div
            newDivLine = line.new(lastOscHiBar, lastOscHi, bar_index - i_pivot_len, pivHiOsc, color=color.new(i_bear_col, 15), width=1, style=line.style_dashed)
            f_storeDivLine(newDivLine)
    lastOscHi := pivHiOsc
    lastPriceHi := high[i_pivot_len]
    lastOscHiBar := bar_index - i_pivot_len
if barstate.isconfirmed and not na(pivLoOsc)
    if not na(lastOscLo) and not na(lastPriceLo) and pivLoOsc > lastOscLo and low[i_pivot_len] < lastPriceLo
        bullDiv := true
        if i_show_div
            newDivLine = line.new(lastOscLoBar, lastOscLo, bar_index - i_pivot_len, pivLoOsc, color=color.new(i_bull_col, 15), width=1, style=line.style_dashed)
            f_storeDivLine(newDivLine)
    lastOscLo := pivLoOsc
    lastPriceLo := low[i_pivot_len]
    lastOscLoBar := bar_index - i_pivot_len

histCol = hist > 0 ? (hist > hist[1] ? i_bull_col : color.new(i_bull_col, 50)) : (hist < hist[1] ? i_bear_col : color.new(i_bear_col, 50))
regimeLabel = ma1 > i_ob_level ? "OVERBOUGHT" : ma1 < i_os_level ? "OVERSOLD" : trendUp ? "BULL TREND" : "BEAR TREND"
regimeCol = ma1 > i_ob_level ? i_bear_col : ma1 < i_os_level ? i_bull_col : trendUp ? i_bull_col : i_bear_col
compressionScore = math.max(0.0, 100.0 - math.min(math.abs(oscValue), 100.0))
spreadScore = math.min(math.abs(hist) * 10.0, 100.0)
signalState = bullMACross ? "BULL CROSS" : bearMACross ? "BEAR CROSS" : histPeakUp ? "PEAK DOWN" : histPeakDown ? "PEAK UP" : "IDLE"
zeroCrossUp = barstate.isconfirmed and ta.crossover(ma1, 0.0)
zeroCrossDown = barstate.isconfirmed and ta.crossunder(ma1, 0.0)
lineStrength = math.min(math.abs(ma1) / math.max(math.abs(i_ob_level), 1e-10), 1.0)
vcoBarCol = i_show_barcolor ? color.from_gradient(lineStrength, 0.0, 1.0, color.new(trendUp ? i_bull_col : i_bear_col, 70), trendUp ? i_bull_col : i_bear_col) : na
biasPersistence = trendUp ? ta.barssince(not trendUp) : ta.barssince(trendUp)
extremeDistance = math.min(math.abs(ma1 - (trendUp ? i_ob_level : i_os_level)) * 2.0, 100.0)
zeroBias = ma1 >= 0 ? "ABOVE ZERO" : "BELOW ZERO"
signalDensity = (bullMACross ? 1 : 0) + (bearMACross ? 1 : 0) + (histPeakUp ? 1 : 0) + (histPeakDown ? 1 : 0) + (bullDiv ? 1 : 0) + (bearDiv ? 1 : 0)
zonePersistence = ma1 > i_ob_level ? ta.barssince(ma1 <= i_ob_level) : ma1 < i_os_level ? ta.barssince(ma1 >= i_os_level) : 0
lineSpread = math.abs(ma1 - ma2)
trendStrength = math.min(math.abs(ma1) * 2.5, 100.0)
oscPersistence = ma1 >= 0 ? ta.barssince(ma1 < 0) : ta.barssince(ma1 > 0)
exhaustionState = histPeakUp ? "TOPPING" : histPeakDown ? "BOTTOMING" : "ACTIVE"
zoneState = ma1 > i_ob_level ? "OB" : ma1 < i_os_level ? "OS" : "MID"
momentumBalance = math.min(math.abs(ma1 + ma2) * 1.5, 100.0)
reversalRisk = histPeakUp or bearDiv or histPeakDown or bullDiv ? math.min(extremeDistance + spreadScore, 100.0) : spreadScore * 0.5
crossState = zeroCrossUp ? "ZERO UP" : zeroCrossDown ? "ZERO DOWN" : bullMACross ? "BULL MA" : bearMACross ? "BEAR MA" : "NONE"
driveState = trendUp and hist >= 0 ? "BULL DRIVE" : not trendUp and hist <= 0 ? "BEAR DRIVE" : "TRANSITION"
obPersistence = ma1 > i_ob_level ? ta.barssince(ma1 <= i_ob_level) : 0
osPersistence = ma1 < i_os_level ? ta.barssince(ma1 >= i_os_level) : 0
histState = hist > 0 ? "POS HIST" : hist < 0 ? "NEG HIST" : "FLAT HIST"
lineState = ma1 > ma2 ? "FAST LEADS" : ma1 < ma2 ? "SLOW LEADS" : "TIED"
zoneScore = math.min(math.abs(ma1) / math.max(math.abs(i_ob_level), 1e-10) * 100.0, 100.0)
signalPressure = math.min(signalDensity * 15.0 + spreadScore * 0.5, 100.0)
compressionPulse = math.min(math.abs(hist - hist[1]) * 18.0, 100.0)
regimeAcceleration = math.min(math.abs(ma1 - ma1[1]) * 8.0, 100.0)
meanReversionIndex = math.min(math.abs(oscValue - ma1) * 0.9, 100.0)
heatBias = hist >= 0 ? compressionScore : 100.0 - compressionScore
flowState = trendUp and compressionPulse >= 35 ? "EXPANDING BULL" : not trendUp and compressionPulse >= 35 ? "EXPANDING BEAR" : compressionScore >= 65 ? "COILED" : "BALANCED"
controlScore = math.min((trendStrength * 0.35) + (compressionPulse * 0.25) + (spreadScore * 0.40), 100.0)
signalRibbonTop = math.max(ma1, ma2)
signalRibbonBottom = math.min(ma1, ma2)
strongBullImpulse = bullMACross and compressionPulse >= 25 and ma1 >= 0
strongBearImpulse = bearMACross and compressionPulse >= 25 and ma1 <= 0
barcolor(vcoBarCol, title="VCO Candle Color")

hline(i_ob_level, "OB", color=color.new(i_bear_col, 40), linestyle=hline.style_dashed)
hline(i_os_level, "OS", color=color.new(i_bull_col, 40), linestyle=hline.style_dashed)
hline(0.0, "Zero", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
bgcolor(i_show_bg and ma1 > i_ob_level ? color.new(i_bear_col, 93) : na)
bgcolor(i_show_bg and ma1 < i_os_level ? color.new(i_bull_col, 93) : na)
plot(hist, "Histogram", color=histCol, style=plot.style_columns)
plot(i_show_glow ? ma1 : na, "MA1 Glow Outer", color=color.new(trendUp ? i_bull_col : i_bear_col, 88), linewidth=7)
pMa1 = plot(ma1, "Line 1", color=trendUp ? i_bull_col : i_bear_col, linewidth=3)
pMa2 = plot(ma2, "Line 2", color=color.new(#ffd700, 25), linewidth=2)
pZero = plot(0.0, display=display.none)
fill(pMa1, pZero, color=color.new(trendUp ? i_bull_col : i_bear_col, 85))
fill(pMa1, pMa2, color=color.new(trendUp ? i_bull_col : i_bear_col, 88))
bgcolor(i_show_heat_cloud and controlScore >= 70 ? color.new(trendUp ? i_bull_col : i_bear_col, 95) : na)

plotshape(i_show_marks and bullMACross, "Bull MA Cross", style=shape.circle, location=location.bottom, color=i_bull_col, size=size.tiny)
plotshape(i_show_marks and bearMACross, "Bear MA Cross", style=shape.circle, location=location.top, color=i_bear_col, size=size.tiny)
plotshape(i_show_marks and crossAboveOB, "Cross Above OB", style=shape.triangledown, location=location.top, color=i_bear_col, size=size.tiny)
plotshape(i_show_marks and crossBelowOS, "Cross Below OS", style=shape.triangleup, location=location.bottom, color=i_bull_col, size=size.tiny)
plotshape(i_show_marks and strongBullImpulse, "Strong Bull Impulse", style=shape.triangleup, location=location.bottom, color=color.new(i_bull_col, 0), size=size.small)
plotshape(i_show_marks and strongBearImpulse, "Strong Bear Impulse", style=shape.triangledown, location=location.top, color=color.new(i_bear_col, 0), size=size.small)

longSignal = barstate.isconfirmed and (bullMACross or crossBelowOS or (bullDiv and i_show_div))
shortSignal = barstate.isconfirmed and (bearMACross or crossAboveOB or (bearDiv and i_show_div))

var table dash = na
if i_show_table
    if na(dash)
        dash := table.new(position.top_right, 2, 9, bgcolor=#1a1a2e, border_color=#333355, border_width=1, frame_color=#444466, frame_width=1)
    if barstate.islast
        sz = size.normal
        table.cell(dash, 0, 0, "VCO [JOAT]", text_color=#ffd700, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 1, 0, "VALUE", text_color=#aaaacc, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 0, 1, "Trend", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 1, trendUp ? "BULL" : "BEAR", text_color=trendUp ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 2, "Regime", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 2, regimeLabel, text_color=regimeCol, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 3, "Compression", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 3, str.tostring(compressionScore, "#.0") + "%", text_color=compressionScore >= 50 ? #ffd700 : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 4, "Spread", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 4, str.tostring(spreadScore, "#.0") + "%", text_color=trendUp ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 5, "Signal", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 5, signalState, text_color=signalState == "BULL CROSS" ? i_bull_col : signalState == "BEAR CROSS" ? i_bear_col : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 6, "Flow", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 6, flowState, text_color=trendUp ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 7, "Control", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 7, str.tostring(controlScore, "#.0") + "%", text_color=controlScore >= 50 ? regimeCol : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 8, "Mean Rev", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 8, str.tostring(meanReversionIndex, "#.0") + "%", text_color=meanReversionIndex >= 50 ? #ffd700 : #ccccdd, text_size=sz, bgcolor=#111122)

alertcondition(longSignal, "VCO: Long Signal", "VCO [JOAT]: long signal triggered.")
alertcondition(shortSignal, "VCO: Short Signal", "VCO [JOAT]: short signal triggered.")
alertcondition(bullMACross, "VCO: Bull Cross", "VCO [JOAT]: line 1 crossed above line 2.")
alertcondition(bearMACross, "VCO: Bear Cross", "VCO [JOAT]: line 1 crossed below line 2.")
alertcondition(zeroCrossUp, "VCO: Zero Cross Up", "VCO [JOAT]: line 1 crossed above the zero line.")
alertcondition(zeroCrossDown, "VCO: Zero Cross Down", "VCO [JOAT]: line 1 crossed below the zero line.")
alertcondition(histPeakUp, "VCO: Histogram Turn Up", "VCO [JOAT]: histogram peaked in bullish exhaustion zone.")
alertcondition(histPeakDown, "VCO: Histogram Turn Down", "VCO [JOAT]: histogram troughed in bearish exhaustion zone.")
alertcondition(bullDiv, "VCO: Bullish Divergence", "VCO [JOAT]: bullish divergence detected.")
alertcondition(bearDiv, "VCO: Bearish Divergence", "VCO [JOAT]: bearish divergence detected.")
````
