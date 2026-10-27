# Dynamic Slope-Compressed TMA

- url: https://www.tradingview.com/script/Y3BRx4Kt-Dynamic-Slope-Compressed-TMA/
- type: indicator
- pine_id: PUB;9fa56f3b41ac41ae894feb4d065216f6
- version: 1.0

## Description

This indicator is a modified Triangular Moving Average-style band system designed to adapt its upper and lower bands based on directional moving-average slope.

The midline is built from a TMA-style smoothing structure using selectable WMA, DWMA, or TWMA logic, with ATR-based upper and lower bands around the midline. The key feature is dynamic band compression: when the selected slope MA is strongly rising, the upper band remains fully expanded while the lower band gradually compresses toward the midline. When the selected slope MA is strongly falling, the lower band remains fully expanded while the upper band gradually compresses toward the midline.

This creates an adaptive channel that reflects directional pressure. In strong uptrends, downside band space contracts toward the midline. In strong downtrends, upside band space contracts toward the midline. At maximum slope strength, the compressed side can reach the midline, depending on the user’s settings.

Main features:

TMA-style midline using selectable WMA, DWMA, or TWMA smoothing
ATR-based upper and lower bands
Dynamic slope-based compression of the opposite-side band
User-selectable slope MA type, length, lookback, and source
Adjustable slope sensitivity using ATR-normalized slope strength
Optional minimum compressed band width
Optional original uncompressed bands for comparison
Optional debug values for compression and slope behavior

How it works:

The indicator calculates a TMA-style midline and standard ATR bands. It then measures the slope of a user-selected moving average. When slope strength increases upward, the lower band moves closer to the midline while the upper band stays at the normal ATR distance. When slope strength increases downward, the upper band moves closer to the midline while the lower band stays at the normal ATR distance.

This can help visualize when price is trending strongly enough that one side of the channel should tighten rather than remain symmetrical.

Suggested use:

This indicator can be used as a trend-aware volatility channel, a directional mean-reversion reference, or a visual filter for overextended price action. It is not intended to be used as a standalone buy/sell signal. Traders should combine it with their own confirmation tools, market structure, volume/VWAP, or higher-timeframe analysis.

Important note:

This indicator does not guarantee future price movement. It is a visual and analytical tool only. Use proper risk management and test all settings before using it in live trading.

## Source Code

````pine
//@version=5
indicator("Dynamic Slope-Compressed TMA", overlay=true)

// ─────────────────────────────────────────────────────────────
// TMA SETTINGS
// ─────────────────────────────────────────────────────────────
groupTMA = "TMA"

TMA_Period = input.int(60, "TMA Number of Bars Back", minval=1, group=groupTMA)
ATR_Period = input.int(120, "ATR Number of Bars Back", minval=1, group=groupTMA)
ATR_Multiplier = input.float(2.5, "Base ATR Multiplier", step=0.25, minval=0.0, group=groupTMA)
src = input.source(close, "TMA Price", group=groupTMA)
ma_type = input.string("DWMA", "TMA MA Type", options=["WMA", "DWMA", "TWMA"], group=groupTMA)

plotMidline = input.bool(true, "Plot TMA Midline", group=groupTMA)
plotOriginalBands = input.bool(false, "Plot Original Uncompressed Bands", group=groupTMA)

// ─────────────────────────────────────────────────────────────
// SLOPE COMPRESSION SETTINGS
// ─────────────────────────────────────────────────────────────
groupSlope = "Dynamic Slope Compression"

slopeSrc = input.source(close, "Slope MA Source", group=groupSlope)
slopeLen = input.int(50, "Slope MA Length", minval=1, group=groupSlope)
slopeType = input.string("EMA", "Slope MA Type", options=["SMA", "EMA", "SMMA (RMA)", "WMA", "VWMA"], group=groupSlope)
slopeLookback = input.int(5, "Slope Lookback Bars", minval=1, group=groupSlope)
slopeAtrLen = input.int(14, "Slope Normalizing ATR Length", minval=1, group=groupSlope)
fullCompressionSlopeATR = input.float(1.0, "Slope Needed For Full Compression, In ATR Units", step=0.05, minval=0.05, group=groupSlope)
compressionPower = input.float(1.0, "Compression Curve Power", step=0.1, minval=0.1, group=groupSlope)
minCompressedSidePct = input.float(0.0, "Minimum Compressed Side Width %", step=1.0, minval=0.0, maxval=100.0, group=groupSlope)

showCompressionDebug = input.bool(false, "Show Compression Debug Values", group=groupSlope)

// ─────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────
groupColors = "Colors"

midColor = input.color(color.new(color.black, 0), "Midline Color", group=groupColors)
upperColor = input.color(color.new(color.red, 0), "Upper Band Color", group=groupColors)
lowerColor = input.color(color.new(color.green, 0), "Lower Band Color", group=groupColors)
originalBandColor = input.color(color.new(color.gray, 70), "Original Band Color", group=groupColors)

// ─────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────
f_clamp(x, minVal, maxVal) =>
    math.max(minVal, math.min(maxVal, x))

ma_any(_source, _len, _type) =>
    switch _type
        "SMA" => ta.sma(_source, _len)
        "EMA" => ta.ema(_source, _len)
        "SMMA (RMA)" => ta.rma(_source, _len)
        "WMA" => ta.wma(_source, _len)
        "VWMA" => ta.vwma(_source, _len)

// ─────────────────────────────────────────────────────────────
// ORIGINAL TMA FORMULA STRUCTURE FROM YOUR INDICATOR
// WMA / DWMA / TWMA variant, then SWMA final smoothing
// ─────────────────────────────────────────────────────────────
f_ssi1() => ta.wma(src, TMA_Period)
f_ssi2() => ta.wma(f_ssi1(), TMA_Period)
f_ssi3() => 2.0 * f_ssi1() - f_ssi2()
f_ssi4() => 3.0 * (f_ssi1() - f_ssi2()) + ta.wma(f_ssi2(), TMA_Period)

variant(_type) =>
    wma = f_ssi1()
    dwma = f_ssi3()
    twma = f_ssi4()
    _type == "WMA" ? wma : _type == "DWMA" ? dwma : _type == "TWMA" ? twma : na

tmaMid = ta.swma(variant(ma_type))
bandWidth = ta.atr(ATR_Period) * ATR_Multiplier

originalUpper = tmaMid + bandWidth
originalLower = tmaMid - bandWidth

// ─────────────────────────────────────────────────────────────
// DYNAMIC SLOPE COMPRESSION
// Positive slope:
//     Upper stays original.
//     Lower moves toward midline.
// Negative slope:
//     Lower stays original.
//     Upper moves toward midline.
// ─────────────────────────────────────────────────────────────
slopeMa = ma_any(slopeSrc, slopeLen, slopeType)
slopeRaw = slopeMa - slopeMa[slopeLookback]
slopeNormBase = ta.atr(slopeAtrLen) * fullCompressionSlopeATR
slopeStrengthRaw = slopeNormBase > 0.0 ? math.abs(slopeRaw) / slopeNormBase : 0.0
slopeStrengthClamped = f_clamp(slopeStrengthRaw, 0.0, 1.0)
compression = math.pow(slopeStrengthClamped, compressionPower)

minSideMultiplier = minCompressedSidePct / 100.0
compressedSideMultiplier = math.max(1.0 - compression, minSideMultiplier)

upperSideMultiplier = slopeRaw < 0.0 ? compressedSideMultiplier : 1.0
lowerSideMultiplier = slopeRaw > 0.0 ? compressedSideMultiplier : 1.0

dynamicUpper = tmaMid + bandWidth * upperSideMultiplier
dynamicLower = tmaMid - bandWidth * lowerSideMultiplier

// ─────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────
plot(plotMidline ? tmaMid : na, title="Dynamic TMA Midline", color=midColor, linewidth=1)
plot(dynamicUpper, title="Dynamic TMA Upper", color=upperColor, linewidth=2)
plot(dynamicLower, title="Dynamic TMA Lower", color=lowerColor, linewidth=2)

plot(plotOriginalBands ? originalUpper : na, title="Original TMA Upper", color=originalBandColor, linewidth=1, style=plot.style_line)
plot(plotOriginalBands ? originalLower : na, title="Original TMA Lower", color=originalBandColor, linewidth=1, style=plot.style_line)

// Debug values in Data Window
plot(showCompressionDebug ? compression : na, title="Compression 0-1", display=display.data_window)
plot(showCompressionDebug ? upperSideMultiplier : na, title="Upper Side Multiplier", display=display.data_window)
plot(showCompressionDebug ? lowerSideMultiplier : na, title="Lower Side Multiplier", display=display.data_window)
plot(showCompressionDebug ? slopeRaw : na, title="Slope Raw", display=display.data_window)
````
