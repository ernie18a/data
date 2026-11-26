# Volumetric Pressure Gradient [JOAT]

- url: https://www.tradingview.com/script/FsC78krG-Volumetric-Pressure-Gradient-JOAT/
- type: indicator
- pine_id: PUB;075be4f4821b467abf8fdda510c2e7e5
- version: 1.0

## Description

[b]Volumetric Pressure Gradient [JOAT][/b]

[b]Introduction[/b]

Volumetric Pressure Gradient [JOAT] is an institutional-style volume location oscillator that converts rolling value distribution into a clean 0-100 pressure map. Instead of forcing the trader to interpret raw profile levels in price space only, the indicator rescales the Point of Control, Value Area High, and Value Area Low into the same oscillator space as current price location. This creates a direct view of whether price is trading above value, below value, or rotating through equilibrium.

The result is a cleaner decision tool for traders who want to understand auction positioning without cluttering the chart with a full profile rendering. It is designed to answer a simple but powerful question: where is price trading relative to where volume has actually concentrated?

[b]Why This Indicator Exists[/b]

[list]
[*][b]Value Location Context:[/b] Shows where price sits inside the recent auction range
[*][b]POC Relationship:[/b] Highlights when price is trading above or below volume-weighted equilibrium
[*][b]Value Area Awareness:[/b] Tracks whether price is stretching outside accepted value or rotating back into it
[*][b]Momentum Confirmation:[/b] Uses consecutive closes relative to the scaled POC for cleaner pressure confirmation
[*][b]Compact Visualization:[/b] Delivers profile intelligence in a sub-pane without overwhelming the chart
[/list]

[image]https://www.tradingview.com/x/32gGf9J0/[/image]

[b]Core Components Explained[/b]

[b]1. Rolling Volume Distribution[/b]

[pine]
winHigh = ta.highest(high, lookback)
winLow  = ta.lowest(low, lookback)
binSize = (winHigh - winLow) / bins
[/pine]

The indicator builds a rolling distribution over the selected lookback window using equal-width price bins. Each candle contributes volume into the bin that contains its midpoint. This keeps the logic fast, stable, and visually clean while still capturing where trade participation has concentrated.

[b]2. Point of Control Calculation[/b]

The Point of Control is the bin with the greatest accumulated volume. It represents the most accepted price area inside the current rolling auction. When the oscillator is above the scaled POC, buyers are holding price above accepted value. When below, price is trading at a discount relative to the current volume center of gravity.

[b]3. Value Area Expansion[/b]

[pine]
vaTarget = totalVol * valueAreaPct / 100.0
[/pine]

Starting from the POC, the script expands upward and downward until the cumulative volume reaches the selected value area percentage. This produces a dynamic Value Area High and Value Area Low that respond to where trading activity is actually clustering.

[b]4. Oscillator Normalization[/b]

[pine]
oscillator = ta.ema((close - winLow) / range * 100.0, smoothLen)
[/pine]

Price location is transformed into a 0-100 oscillator so it can be compared directly against the scaled POC and value boundaries. This turns volume profile interpretation into a faster read:

[list]
[*]Above POC = premium to value
[*]Below POC = discount to value
[*]Near Value Area High = acceptance near upper auction boundary
[*]Near Value Area Low = acceptance near lower auction boundary
[/list]

[b]5. Pressure Confirmation Logic[/b]

The indicator tracks consecutive bars above or below the scaled POC. This avoids overreacting to one-bar noise and helps confirm whether price is actually sustaining premium or discount pressure.

[b]Visual Elements[/b]

[list]
[*][b]Main Oscillator:[/b] Color-switching pressure line based on price location relative to POC
[*][b]POC Line:[/b] Gold equilibrium reference showing accepted value
[*][b]VA High / VA Low:[/b] Soft boundary lines for the active value area
[*][b]Gradient Fill:[/b] Bullish above POC, bearish below POC
[*][b]OB/OS Background:[/b] Optional shading when price stretches to extremes
[*][b]Momentum Markers:[/b] Compact confirmation triangles when above/below-POC pressure persists
[*][b]Dashboard:[/b] Live readout of VAH, POC, VAL, width, position, and regime
[/list]

[b]Input Parameters[/b]

[list]
[*][b]Lookback Bars:[/b] Window used for the rolling profile and oscillator normalization
[*][b]Value Area %:[/b] Percentage of total volume used to define accepted value
[*][b]Overbought / Oversold:[/b] Stretch thresholds for auction extremes
[*][b]Momentum Confirm Bars:[/b] Required bars above or below POC before confirmation fires
[*][b]Oscillator EMA:[/b] Smoothing applied to the normalized pressure line
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1:[/b] Identify whether the oscillator is above or below the POC. This tells you if price is trading at premium or discount relative to recent value.  
[b]Step 2:[/b] Check whether price is rotating inside value or expanding away from it.  
[b]Step 3:[/b] Watch for momentum confirmation markers when pressure sustains on one side of the POC.  
[b]Step 4:[/b] Use overbought and oversold conditions as context, not automatic reversal signals.  
[b]Step 5:[/b] Combine with structure or trend tools for directional execution.

[b]Best Practices[/b]

[list]
[*]Use on liquid markets where reported volume is meaningful
[*]Treat the POC as equilibrium, not as guaranteed support or resistance
[*]Combine premium/discount information with higher-timeframe structure
[*]Momentum confirmation works best when the value area is not extremely narrow
[*]Value area width can help identify compression vs expansion conditions
[/list]

[b]Indicator Limitations[/b]

[list]
[*]This is a rolling approximation of value, not a full exchange-native volume profile engine
[*]Very small lookbacks can make value levels overly reactive
[*]Overbought and oversold readings can remain extended in strong trends
[*]Value acceptance does not guarantee reversal
[*]Volume quality varies by market and broker feed
[/list]

[b]Technical Implementation[/b]

Built in Pine Script v6 using:
[list]
[*]Rolling bin-based volume distribution
[*]POC-first value area expansion
[*]Normalized 0-100 price-location oscillator
[*]EMA smoothing for pressure readability
[*]Consecutive-bar momentum confirmation
[*]Non-repainting confirmed-bar updates
[/list]

[b]Originality Statement[/b]

This indicator is original in how it compresses profile-style value logic into an oscillator workflow. Rather than drawing a traditional profile on the price chart, it translates value, equilibrium, and range position into a compact pressure framework that is easier to combine with momentum and structure analysis.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Trading involves risk, including the risk of loss. Volume-based context improves decision quality, but it does not predict future price movement with certainty. Always use proper risk management and independent judgment.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volumetric Pressure Gradient [JOAT]", shorttitle="VPG [JOAT]", overlay=false, max_labels_count=100, max_lines_count=100)

grp_core = "Core Settings"
grp_sig = "Signal Filters"
grp_vis = "Visual Settings"
grp_table = "Dashboard"

i_lookback = input.int(100, "Lookback Bars", minval=20, maxval=500, group=grp_core)
i_va_pct = input.float(70.0, "Value Area %", minval=50.0, maxval=99.0, step=1.0, group=grp_core)
i_ob_level = input.float(70.0, "Overbought Level", minval=51.0, maxval=99.0, step=0.5, group=grp_core)
i_os_level = input.float(30.0, "Oversold Level", minval=1.0, maxval=49.0, step=0.5, group=grp_core)
i_mom_bars = input.int(2, "Momentum Confirm Bars", minval=1, maxval=5, group=grp_core)
i_smooth_len = input.int(3, "Oscillator EMA", minval=1, maxval=20, group=grp_core)

i_show_poc_signals = input.bool(true, "Show POC Break Signals", group=grp_sig)
i_poc_break_filter = input.float(4.0, "POC Break Filter", minval=0.0, maxval=25.0, step=0.5, group=grp_sig)
i_show_va_signals = input.bool(true, "Show VA Break Signals", group=grp_sig)
i_va_break_filter = input.float(2.0, "VA Break Filter", minval=0.0, maxval=25.0, step=0.5, group=grp_sig)
i_dev_threshold = input.float(35.0, "Strong Deviation Threshold", minval=1.0, maxval=100.0, step=0.5, group=grp_sig)

i_bull_col = input.color(#06a22f, "Bull Color", group=grp_vis)
i_bear_col = input.color(#cf1717, "Bear Color", group=grp_vis)
i_poc_col = input.color(#ffd700, "POC Color", group=grp_vis)
i_show_fills = input.bool(true, "Show Gradient Fills", group=grp_vis)
i_show_bg = input.bool(true, "Show OB/OS Background", group=grp_vis)
i_show_dev_bg = input.bool(true, "Show Deviation Highlight", group=grp_vis)
i_show_glow = input.bool(true, "Show Glow Lines", group=grp_vis)
i_show_barcolor = input.bool(true, "Show Candle Coloring", group=grp_vis)
i_show_marks = input.bool(true, "Show Signal Markers", group=grp_vis)

i_show_table = input.bool(true, "Show Dashboard", group=grp_table)
i_table_pos = input.string("Top Right", "Table Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=grp_table)
i_table_size = input.string("Normal", "Table Size", options=["Tiny", "Small", "Normal", "Large"], group=grp_table)

NUM_BINS = 20

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

f_blend(baseColor, strength) =>
    color.from_gradient(strength, 0.0, 1.0, color.new(baseColor, 80), color.new(baseColor, 0))

winHigh = ta.highest(high, i_lookback)
winLow = ta.lowest(low, i_lookback)
rng = math.max(winHigh - winLow, 1e-10)
availableBars = math.max(math.min(i_lookback, bar_index + 1), 1)

var float[] binVols = array.new_float(NUM_BINS, 0.0)
var float pocPrice = close
var float vaHigh = high
var float vaLow = low
var bool bullPocBroken = false
var bool bearPocBroken = false
var bool bullVaBroken = false
var bool bearVaBroken = false

if barstate.isconfirmed
    binSize = math.max(rng / NUM_BINS, 1e-10)
    newBins = array.new_float(NUM_BINS, 0.0)
    for k = 0 to availableBars - 1
        midPrice = (high[k] + low[k]) / 2.0
        binIdx = int(math.floor((midPrice - winLow) / binSize))
        binIdx := math.max(0, math.min(NUM_BINS - 1, binIdx))
        array.set(newBins, binIdx, array.get(newBins, binIdx) + volume[k])
    binVols := newBins

    totalVol = 0.0
    pocBin = 0
    maxVol = 0.0
    for b = 0 to NUM_BINS - 1
        binVol = array.get(binVols, b)
        totalVol += binVol
        if binVol > maxVol
            maxVol := binVol
            pocBin := b
    pocPrice := winLow + (pocBin + 0.5) * binSize

    vaTarget = totalVol * i_va_pct / 100.0
    vaCum = array.get(binVols, pocBin)
    vaLowBin = pocBin
    vaHighBin = pocBin
    for _ = 0 to NUM_BINS - 1
        if vaCum >= vaTarget
            break
        upVol = vaHighBin < NUM_BINS - 1 ? array.get(binVols, vaHighBin + 1) : -1.0
        dnVol = vaLowBin > 0 ? array.get(binVols, vaLowBin - 1) : -1.0
        if upVol >= dnVol
            vaHighBin := math.min(NUM_BINS - 1, vaHighBin + 1)
            vaCum += math.max(upVol, 0.0)
        else
            vaLowBin := math.max(0, vaLowBin - 1)
            vaCum += math.max(dnVol, 0.0)
    vaHigh := winLow + (vaHighBin + 1) * binSize
    vaLow := winLow + vaLowBin * binSize

oscRaw = math.max(math.min((close - winLow) / rng * 100.0, 100.0), 0.0)
oscillator = ta.ema(oscRaw, i_smooth_len)
pocScaled = math.max(math.min((pocPrice - winLow) / rng * 100.0, 100.0), 0.0)
vaHighScaled = math.max(math.min((vaHigh - winLow) / rng * 100.0, 100.0), 0.0)
vaLowScaled = math.max(math.min((vaLow - winLow) / rng * 100.0, 100.0), 0.0)

abovePOC = oscillator > pocScaled
belowPOC = oscillator < pocScaled
deviationFromPoc = math.abs(oscillator - pocScaled)
strongDeviation = deviationFromPoc >= i_dev_threshold
profileSlope = ta.ema(oscillator - pocScaled, 5)
locationStrength = math.min(deviationFromPoc / math.max(i_dev_threshold, 1e-10), 1.0)
oscRangeBias = oscillator > 50 ? "UPPER HALF" : oscillator < 50 ? "LOWER HALF" : "MIDLINE"
valueStateScore = math.min(math.abs(oscillator - 50.0) * 2.0, 100.0)
rangeLocation = str.tostring(oscillator, "#.0") + " / 100"
valueState = abovePOC ? "POC HIGH" : belowPOC ? "POC LOW" : "FAIR VALUE"
rotationScore = math.min(math.abs(profileSlope) * 4.0, 100.0)
rangeDrive = abovePOC ? "BULL DRIVE" : belowPOC ? "BEAR DRIVE" : "ROTATION"

var int consAbove = 0
var int consBelow = 0
if barstate.isconfirmed
    if abovePOC
        consAbove += 1
        consBelow := 0
    else if belowPOC
        consBelow += 1
        consAbove := 0
    else
        consAbove := 0
        consBelow := 0

crossAbovePOC = barstate.isconfirmed and i_show_poc_signals and oscillator[1] <= pocScaled[1] + i_poc_break_filter and oscillator > pocScaled + i_poc_break_filter
crossBelowPOC = barstate.isconfirmed and i_show_poc_signals and oscillator[1] >= pocScaled[1] - i_poc_break_filter and oscillator < pocScaled - i_poc_break_filter
crossAboveOB = barstate.isconfirmed and ta.crossover(oscillator, i_ob_level)
crossBelowOS = barstate.isconfirmed and ta.crossunder(oscillator, i_os_level)
crossAboveVA = barstate.isconfirmed and i_show_va_signals and oscillator[1] <= vaHighScaled[1] + i_va_break_filter and oscillator > vaHighScaled + i_va_break_filter
crossBelowVA = barstate.isconfirmed and i_show_va_signals and oscillator[1] >= vaLowScaled[1] - i_va_break_filter and oscillator < vaLowScaled - i_va_break_filter
momConfirmBull = barstate.isconfirmed and consAbove >= i_mom_bars and consAbove[1] < i_mom_bars
momConfirmBear = barstate.isconfirmed and consBelow >= i_mom_bars and consBelow[1] < i_mom_bars

pocBullSignal = crossAbovePOC and not bullPocBroken
pocBearSignal = crossBelowPOC and not bearPocBroken
vaBullSignal = crossAboveVA and not bullVaBroken
vaBearSignal = crossBelowVA and not bearVaBroken

if pocBullSignal
    bullPocBroken := true
if pocBearSignal
    bearPocBroken := true
if vaBullSignal
    bullVaBroken := true
if vaBearSignal
    bearVaBroken := true
if oscillator <= pocScaled
    bullPocBroken := false
if oscillator >= pocScaled
    bearPocBroken := false
if oscillator <= vaHighScaled
    bullVaBroken := false
if oscillator >= vaLowScaled
    bearVaBroken := false

mainCol = abovePOC ? i_bull_col : i_bear_col
vaWidthPct = (vaHigh - vaLow) / rng * 100.0
premiumState = oscillator > vaHighScaled
discountState = oscillator < vaLowScaled
valueRotation = premiumState ? "PREMIUM" : discountState ? "DISCOUNT" : "EQUILIBRIUM"
biasPersistence = abovePOC ? ta.barssince(not abovePOC) : ta.barssince(abovePOC)
pocDistancePct = deviationFromPoc / 100.0
premiumDiscountScore = premiumState ? math.min((oscillator - vaHighScaled) * 4.0, 100.0) : discountState ? math.min((vaLowScaled - oscillator) * 4.0, 100.0) : 0.0
oscBasis = ta.ema(oscillator, 8)
oscTrendUp = oscillator >= oscBasis
zonePersistence = premiumState ? ta.barssince(not premiumState) : discountState ? ta.barssince(not discountState) : 0
signalState = pocBullSignal ? "POC BULL" : pocBearSignal ? "POC BEAR" : vaBullSignal ? "VA BULL" : vaBearSignal ? "VA BEAR" : momConfirmBull ? "MOM BULL" : momConfirmBear ? "MOM BEAR" : "IDLE"
signalDensity = (pocBullSignal ? 1 : 0) + (pocBearSignal ? 1 : 0) + (vaBullSignal ? 1 : 0) + (vaBearSignal ? 1 : 0) + (momConfirmBull ? 1 : 0) + (momConfirmBear ? 1 : 0)
valueCompression = math.max(0.0, 100.0 - math.min(vaWidthPct * 6.0, 100.0))
valueAcceptance = math.max(0.0, 100.0 - premiumDiscountScore)
vpgBarCol = i_show_barcolor ? color.from_gradient(locationStrength, 0.0, 1.0, color.new(abovePOC ? i_bull_col : i_bear_col, 80), abovePOC ? i_bull_col : i_bear_col) : na
valueState := premiumState ? "AUCTION HIGH" : discountState ? "AUCTION LOW" : "FAIR VALUE"
rangeDrive := oscTrendUp and abovePOC ? "BULL DRIVE" : not oscTrendUp and belowPOC ? "BEAR DRIVE" : "ROTATION"
regimeLabel = oscillator > i_ob_level ? "OVERBOUGHT" : oscillator < i_os_level ? "OVERSOLD" : strongDeviation and abovePOC ? "PREMIUM EXPANSION" : strongDeviation ? "DISCOUNT EXPANSION" : abovePOC ? "BULL TREND" : "BEAR TREND"
regimeCol = oscillator > i_ob_level ? i_bear_col : oscillator < i_os_level ? i_bull_col : abovePOC ? i_bull_col : i_bear_col
auctionBias = oscillator > vaHighScaled ? "ABOVE VALUE" : oscillator < vaLowScaled ? "BELOW VALUE" : "INSIDE VALUE"
barcolor(vpgBarCol, title="VPG Candle Color")

pOsc = plot(oscillator, "Oscillator", color=mainCol, linewidth=2)
pPoc = plot(pocScaled, "POC", color=i_poc_col, linewidth=1)
plot(i_show_glow ? oscillator : na, "Osc Glow Outer", color=color.new(mainCol, 90), linewidth=7)
plot(i_show_glow ? oscillator : na, "Osc Glow Mid", color=color.new(mainCol, 78), linewidth=5)
plot(i_show_glow ? pocScaled : na, "POC Glow Outer", color=color.new(i_poc_col, 90), linewidth=6)
plot(i_show_glow ? pocScaled : na, "POC Glow Mid", color=color.new(i_poc_col, 80), linewidth=4)
pVaHigh = plot(vaHighScaled, "VA High", color=color.new(i_bull_col, 55), linewidth=1)
pVaLow = plot(vaLowScaled, "VA Low", color=color.new(i_bear_col, 55), linewidth=1)
fill(pOsc, pPoc, color=i_show_fills and abovePOC ? color.new(i_bull_col, 74) : na)
fill(pOsc, pPoc, color=i_show_fills and not abovePOC ? color.new(i_bear_col, 74) : na)
fill(pVaHigh, pVaLow, color=color.new(abovePOC ? i_bull_col : i_bear_col, 94), title="Value Area Fill")
fill(pOsc, pVaHigh, color=i_show_fills and premiumState ? color.new(i_bear_col, 90) : na, title="Premium Fill")
fill(pOsc, pVaLow, color=i_show_fills and discountState ? color.new(i_bull_col, 90) : na, title="Discount Fill")

plot(i_show_glow ? profileSlope + 50.0 : na, "Slope Ribbon Glow", color=color.new(profileSlope >= 0 ? i_bull_col : i_bear_col, 90), linewidth=4)
pSlope = plot(profileSlope + 50.0, "Profile Slope Ribbon", color=color.new(profileSlope >= 0 ? i_bull_col : i_bear_col, 30), linewidth=1)
plot(i_show_glow ? oscBasis : na, "Osc Basis Glow", color=color.new(oscTrendUp ? i_bull_col : i_bear_col, 92), linewidth=4)
pBasis = plot(oscBasis, "Osc Basis", color=color.new(oscTrendUp ? i_bull_col : i_bear_col, 45), linewidth=1)
fill(pOsc, pBasis, color=i_show_fills ? color.new(oscTrendUp ? i_bull_col : i_bear_col, 92) : na, title="Osc Basis Fill")
fill(pSlope, pBasis, color=i_show_fills ? color.new(profileSlope >= 0 ? i_bull_col : i_bear_col, 94) : na, title="Slope Basis Fill")

hline(i_ob_level, "Overbought", color=color.new(i_bear_col, 30), linestyle=hline.style_dashed)
hline(i_os_level, "Oversold", color=color.new(i_bull_col, 30), linestyle=hline.style_dashed)
hline(50.0, "Midline", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
hline(0.0, "Floor", color=color.new(color.gray, 80))
hline(100.0, "Ceiling", color=color.new(color.gray, 80))

bgcolor(i_show_bg and oscillator > i_ob_level ? color.new(i_bear_col, 90) : na)
bgcolor(i_show_bg and oscillator < i_os_level ? color.new(i_bull_col, 90) : na)
bgcolor(i_show_dev_bg and strongDeviation and abovePOC ? color.new(i_bull_col, 93) : na)
bgcolor(i_show_dev_bg and strongDeviation and belowPOC ? color.new(i_bear_col, 93) : na)

plotshape(i_show_marks and momConfirmBull, "Momentum Bull", style=shape.triangleup, location=location.bottom, color=i_bull_col, size=size.tiny)
plotshape(i_show_marks and momConfirmBear, "Momentum Bear", style=shape.triangledown, location=location.top, color=i_bear_col, size=size.tiny)
plotshape(i_show_marks and pocBullSignal ? pocScaled - 4.0 : na, "POC Bull", style=shape.triangleup, location=location.absolute, color=i_bull_col, size=size.tiny)
plotshape(i_show_marks and pocBearSignal ? pocScaled + 4.0 : na, "POC Bear", style=shape.triangledown, location=location.absolute, color=i_bear_col, size=size.tiny)
plotshape(i_show_marks and vaBullSignal ? vaHighScaled + 2.0 : na, "VA Bull", style=shape.diamond, location=location.absolute, color=color.new(i_bull_col, 10), size=size.tiny)
plotshape(i_show_marks and vaBearSignal ? vaLowScaled - 2.0 : na, "VA Bear", style=shape.diamond, location=location.absolute, color=color.new(i_bear_col, 10), size=size.tiny)
plotshape(i_show_marks and strongDeviation and premiumState ? oscillator : na, "Premium Deviation", style=shape.circle, location=location.absolute, color=color.new(i_bear_col, 15), size=size.tiny)
plotshape(i_show_marks and strongDeviation and discountState ? oscillator : na, "Discount Deviation", style=shape.circle, location=location.absolute, color=color.new(i_bull_col, 15), size=size.tiny)

var table dash = na
if i_show_table
    if na(dash)
        dash := table.new(position.top_right, 2, 9, bgcolor=#1a1a2e, border_color=#333355, border_width=1, frame_color=#444466, frame_width=1)
    if barstate.islast
        sz = size.normal
        table.cell(dash, 0, 0, "VPG [JOAT]", text_color=i_poc_col, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 1, 0, "VALUE", text_color=#aaaacc, text_size=sz, bgcolor=#0d0d1a, text_halign=text.align_center)
        table.cell(dash, 0, 1, "Regime", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 1, regimeLabel, text_color=regimeCol, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 2, "Auction Bias", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 2, auctionBias, text_color=auctionBias == "ABOVE VALUE" ? i_bull_col : auctionBias == "BELOW VALUE" ? i_bear_col : i_poc_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 3, "Osc / POC", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 3, str.tostring(oscillator, "#.1") + " / " + str.tostring(pocScaled, "#.1"), text_color=mainCol, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 4, "Compression", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 4, str.tostring(valueCompression, "#.0") + "%", text_color=valueCompression >= 50 ? i_poc_col : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 5, "Signal", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 5, signalState, text_color=signalState == "IDLE" ? #ccccdd : regimeCol, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 6, "Rotation", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 6, valueRotation, text_color=premiumState ? i_bear_col : discountState ? i_bull_col : i_poc_col, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 7, "Deviation", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 7, str.tostring(deviationFromPoc, "#.1"), text_color=strongDeviation ? regimeCol : #ccccdd, text_size=sz, bgcolor=#111122)
        table.cell(dash, 0, 8, "Range Drive", text_color=#aaaacc, text_size=sz, bgcolor=#111122)
        table.cell(dash, 1, 8, rangeDrive, text_color=oscTrendUp ? i_bull_col : i_bear_col, text_size=sz, bgcolor=#111122)

alertcondition(crossAbovePOC, "VPG: Cross Above POC", "VPG [JOAT]: oscillator crossed above POC.")
alertcondition(crossBelowPOC, "VPG: Cross Below POC", "VPG [JOAT]: oscillator crossed below POC.")
alertcondition(crossAboveVA, "VPG: Cross Above VAH", "VPG [JOAT]: oscillator crossed above value area high.")
alertcondition(crossBelowVA, "VPG: Cross Below VAL", "VPG [JOAT]: oscillator crossed below value area low.")
alertcondition(crossAboveOB, "VPG: Cross Above OB", "VPG [JOAT]: oscillator crossed into overbought.")
alertcondition(crossBelowOS, "VPG: Cross Below OS", "VPG [JOAT]: oscillator crossed into oversold.")
alertcondition(momConfirmBull, "VPG: Momentum Bull", "VPG [JOAT]: bullish momentum confirmed above POC.")
alertcondition(momConfirmBear, "VPG: Momentum Bear", "VPG [JOAT]: bearish momentum confirmed below POC.")
````
