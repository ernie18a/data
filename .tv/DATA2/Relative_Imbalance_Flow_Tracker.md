<!-- tradingview-pine-id: PUB;16d539c6161f4d83aec1cb82379dc651 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Relative Imbalance Flow Tracker

Source: https://www.tradingview.com/script/3Bcp58JY-Relative-Imbalance-Flow-Tracker-RIFT/

## Description

RIFT — Relative Imbalance Flow Tracker

RIFT is an RSI-based momentum indicator designed to make shifts in momentum easier to see by combining RSI candles, multiple RSI moving averages, dynamic envelopes, Bollinger bands, momentum zones, and price-chart signals into a single system.

Rather than treating RSI as a simple overbought/oversold oscillator, RIFT treats RSI as its own momentum chart. RSI is displayed as OHLC candles, preserving much more of the movement that occurred during each price candle, while multiple moving averages track momentum across different time horizons.

Momentum Moving Averages

By default, RIFT tracks four moving averages of RSI:

16 WMA — Pink: short-term momentum
32 SMA — Yellow: intermediate momentum 
96 WMA — Aqua: longer-term momentum
160 WMA — Orange: broader momentum trend

These lengths and MA types are fully configurable.

The interaction between these averages is one of the primary signals in RIFT. Crossovers tend to become particularly important when they occur near momentum pivots or after the averages have compressed together.

A common setup occurs when the short pink MA curls over or under the longer yellow MA as the averages converge. The longer aqua and orange averages provide context for whether that short-term shift is occurring with or against the broader momentum structure.

Filling the Gaps

One of the most useful visual behaviors is watching the RSI candles move through the gaps between the moving averages.

When momentum begins moving decisively through a compressed MA structure, RSI candles can rapidly fill the space between one average and the next. These moves often correspond with strong directional price movement.

The timeframe matters considerably. A momentum transition visible on a higher timeframe can produce a much larger and more sustained move when viewed on lower timeframes. This allows RIFT to be used top-down: identify the larger momentum transition first, then use lower timeframes to observe and trade the resulting move.

Red and Green Momentum Fills

RIFT creates dynamic envelopes around its RSI moving averages and highlights important momentum extremes with red upper fills and green lower fills.

These aren't simply traditional RSI "overbought" and "oversold" readings.

When RSI reaches the lower green fill, watch for RSI to break upward out of the region while the short-term moving averages begin curling upward or crossing. This can indicate a developing bullish momentum reversal.

When RSI reaches the upper red fill, watch for RSI to break downward out of the region while the short-term averages curl downward or cross. This can indicate a developing bearish momentum reversal.

The strongest setups generally come from several pieces of information agreeing at once: RSI leaving an extreme fill, moving averages squeezing or converging, the short-term averages beginning to curl and cross, and the longer averages confirming a broader momentum shift.

Price-Chart Signals

RIFT can also project important RSI events directly onto the main price chart so the trader doesn't have to constantly compare two panes.

Optional chart highlighting can show when:

RSI is inside or beyond the upper red momentum fill
RSI is inside or beyond the lower green momentum fill

RSI crosses 50 ->

(Sherlock Secret TIP: This correlates almost exactly with a cross of the price over a 100wma on the price chart on any timeframe and any chart when RSI is set to a length of 32. This allows you to have a spacial indicator of where price would be if RSI were to go to 50. If you learn the patterns, you can estimate this somewhat reliably.)

RSI crosses any of the four momentum moving averages

The MA crossover backgrounds use the corresponding MA colors, making it possible to see exactly when momentum crosses an important RSI average while looking directly at price.

Additional Features

RIFT also includes configurable RSI smoothing, RSI Rate of Change, optional Bollinger Bands, configurable 20–30 / 45–55 / 70–80 momentum zones, customizable RSI candle appearance, dynamic pane scaling, and extensive visual controls.

The result is less of a conventional RSI indicator and more of a multi-timeframe momentum map. Instead of asking only whether RSI is "high" or "low," RIFT is designed to show where momentum is compressed, where it is beginning to rotate, which momentum horizon is changing direction, and when RSI is beginning to accelerate through the structure.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Sherlock_MacGyver
//@version=6
indicator("Relative Imbalance Flow Tracker", shorttitle = "RIFT", overlay=false)

// ══════════════════════════════════════════════════════════════════════════════════════
// === ⏱ RSI + Smoothing Settings ===
// ══════════════════════════════════════════════════════════════════════════════════════
groupRSI = "🎛 RSI Settings"
rsiLen = input.int(32, "RSI Length", group=groupRSI,
     tooltip="Base RSI length. Controls how many bars are used for the RSI calculation.")
smoothRSI = input.bool(false, "Smooth RSI?", group=groupRSI,
     tooltip="Enable optional smoothing for the RSI to reduce choppiness.")
smoothAll = input(true, "Smooth Moving Averages", group=groupRSI,
     tooltip="Smooths moving averages along with RSI")
rsiSmoothLen = input.int(3, "Smoothing Length", minval=1, group=groupRSI,
     tooltip="Number of bars used to smooth the RSI if enabled.")
rsiSmoothType = input.string("RMA", "Smoothing Type", options=["RMA", "EMA", "SMA", "WMA"], group=groupRSI,
     tooltip="Choose smoothing method for the RSI: RMA (default), EMA, SMA, or WMA.")
rsiRocLen = input.int(9, "RSI ROC Length", minval=1, group=groupRSI,
     tooltip="Lookback period used to calculate the percentage rate of change of the final RSI line.")
rsiRocScale = input.float(0.50, "RSI ROC Display Scale", minval=0.05, step=0.05, group=groupRSI,
     tooltip="Visual multiplier for the RSI ROC line around 50. A value of 0.50 cuts its distance from 50 in half.")

// ══════════════════════════════════════════════════════════════════════════════════════
// === 🕯 RSI Candle Settings ===
// ══════════════════════════════════════════════════════════════════════════════════════
groupRsiCandles = "🕯 RSI Candle Settings"
showRsiCandles = input.bool(true, "Show RSI Candles", group=groupRsiCandles,
     tooltip="Draws OHLC candles in RSI space so intrabar RSI range is preserved historically instead of showing only the final close.")
rsiCandleSource = input.string("Final RSI", "Candle Source", options=["Final RSI", "Raw RSI"], group=groupRsiCandles,
     tooltip="Final RSI follows the indicator's Smooth RSI setting. Raw RSI shows unsmoothed RSI OHLC.")
rsiCandleColorMode = input.string("RSI Candle", "Candle Color Mode", options=["RSI Candle", "Price Candle"], group=groupRsiCandles,
     tooltip="RSI Candle colors by RSI close vs RSI open. Price Candle colors by the underlying price candle direction.")
rsiCandleUpColor = input.color(color.lime, "Up", group=groupRsiCandles, inline="rsiCandleColors",
     tooltip="Color used for bullish RSI candles.")
rsiCandleDownColor = input.color(color.red, "Down", group=groupRsiCandles, inline="rsiCandleColors",
     tooltip="Color used for bearish RSI candles.")
rsiCandleDojiColor = input.color(color.gray, "Doji", group=groupRsiCandles, inline="rsiCandleColors",
     tooltip="Color used when the RSI candle body is smaller than the Doji Threshold.")
rsiCandleBodyTransp = input.int(25, "Body Transparency", minval=0, maxval=100, step=5, group=groupRsiCandles,
     tooltip="Transparency of RSI candle bodies. Lower = more opaque.")
showRsiCandleWicks = input.bool(true, "Show Wicks", group=groupRsiCandles, inline="rsiCandleWicks")
rsiCandleWickColor = input.color(color.white, "Wick", group=groupRsiCandles, inline="rsiCandleWicks",
     tooltip="Color of RSI candle wicks.")
rsiCandleWickTransp = input.int(20, "Wick Transparency", minval=0, maxval=100, step=5, group=groupRsiCandles)
showRsiCandleBorders = input.bool(true, "Show Borders", group=groupRsiCandles, inline="rsiCandleBorders")
rsiCandleBorderTransp = input.int(0, "Border Transparency", minval=0, maxval=100, step=5, group=groupRsiCandles, inline="rsiCandleBorders")
rsiCandleDojiThreshold = input.float(0.10, "Doji Threshold (RSI points)", minval=0.0, step=0.05, group=groupRsiCandles,
     tooltip="Bodies with an absolute RSI open/close difference at or below this value use the Doji color.")
rsiCandleMaxWick = input.float(8.0, "Max Wick Length (RSI points)", minval=0.0, step=0.5, group=groupRsiCandles,
     tooltip="Caps how far a wick can extend beyond the candle body. Prevents degenerate near-0/near-100 intrabar RSI readings from stretching the scale.")

// ══════════════════════════════════════════════════════════════════════════════════════
// === 🧠 Moving Averages + Envelope Settings ===
// ══════════════════════════════════════════════════════════════════════════════════════
groupMA = "📏 MA & Envelope Settings"
ma1Type = input.string("WMA", "MA 1 Type", options=["SMA", "WMA"], group=groupMA,
     tooltip="Choose the moving average type for MA 1.")
ma2Type = input.string("SMA", "MA 2 Type", options=["SMA", "WMA"], group=groupMA,
     tooltip="Choose the moving average type for MA 2.")
ma3Type = input.string("WMA", "MA 3 Type", options=["SMA", "WMA"], group=groupMA,
     tooltip="Choose the moving average type for MA 3.")
ma4Type = input.string("WMA", "MA 4 Type", options=["SMA", "WMA"], group=groupMA,
     tooltip="Choose the moving average type for MA 4.")
ma1Len = input.int(16, "MA 1 Length", minval=1, group=groupMA,
     tooltip="Lookback length for MA 1.")
ma2Len = input.int(32, "MA 2 Length", minval=1, group=groupMA,
     tooltip="Lookback length for MA 2.")
ma3Len = input.int(96, "MA 3 Length", minval=1, group=groupMA,
     tooltip="Lookback length for MA 3.")
ma4Len = input.int(160, "MA 4 Length", minval=1, group=groupMA,
     tooltip="Lookback length for MA 4.")
envPerc = input.float(10.0, "Envelope % Width", minval=0.1, step=1, group=groupMA,
     tooltip="Controls the distance of envelope bands from their respective MA. Expressed as percent of the MA value.")

// Main chart background signal settings
groupChartBg = "Main Chart Background Signals"
showRedFillChartBg = input.bool(false, "RSI Inside/Above Red Fill", group=groupChartBg,
     tooltip="Colors every main-chart bar while RSI is inside or above the active red envelope fill.")
showGreenFillChartBg = input.bool(false, "RSI Inside/Below Green Fill", group=groupChartBg,
     tooltip="Colors every main-chart bar while RSI is inside or below the active green envelope fill.")
showRsi50CrossChartBg = input.bool(false, "RSI Crosses 50", group=groupChartBg,
     tooltip="Colors the main-chart background on the exact bar RSI crosses 50.")
showMa1CrossChartBg = input.bool(false, "RSI Crosses MA 1", group=groupChartBg,
     tooltip="Colors the main-chart background with the MA 1 color on crossover bars.")
showMa2CrossChartBg = input.bool(false, "RSI Crosses MA 2", group=groupChartBg,
     tooltip="Colors the main-chart background with the MA 2 color on crossover bars.")
showMa3CrossChartBg = input.bool(false, "RSI Crosses MA 3", group=groupChartBg,
     tooltip="Colors the main-chart background with the MA 3 color on crossover bars.")
showMa4CrossChartBg = input.bool(false, "RSI Crosses MA 4", group=groupChartBg,
     tooltip="Colors the main-chart background with the MA 4 color on crossover bars.")
chartBgTransparency = input.int(85, "Main Chart Background Transparency", minval=0, maxval=100, step=5, group=groupChartBg)

// ══════════════════════════════════════════════════════════════════════════════════════
// === 🎨 Visual Settings ===
// ══════════════════════════════════════════════════════════════════════════════════════
groupVisual   = "🎨 Visual Settings"
showRsi       = input(false, "Toggle RSI Line", group=groupVisual,
     tooltip  = "Turns the RSI line on and off.")
rsiLineWidth  = input.int(1, "RSI Line Width", group=groupVisual,
     tooltip  = "Line thickness of the RSI plot.")
rsiGlowWidth  = input.int(5, "RSI Glow Width", group=groupVisual,
     tooltip  = "Line thickness of the glowing trail behind RSI.")
rsiGlowTransp = input.int(65, "RSI Glow Transparency", minval=0, maxval=100, step=5, group=groupVisual,
     tooltip  = "Controls transparency of the glowing RSI trail. Lower = brighter.")
showMa1      = input(true, "MA 1", group=groupVisual, inline = "ma1",
     tooltip = "Toggle the MA 1 line.")
ma1Color     = input.color(color.fuchsia, "", group=groupVisual, inline = "ma1",
     tooltip = "Color for the MA 1 line.")
showMa2      = input(true, "MA 2", group=groupVisual, inline = "ma2",
     tooltip = "Toggle the MA 2 line.")
ma2Color     = input.color(color.yellow, "", group=groupVisual, inline = "ma2",
     tooltip = "Color for the MA 2 line.")
showMa3      = input(true, "MA 3", group=groupVisual, inline = "ma3",
     tooltip = "Toggle the MA 3 line.")
ma3Color     = input.color(color.aqua, "", group=groupVisual, inline = "ma3",
     tooltip = "Color for the MA 3 line.")
showMa4      = input(true, "MA 4", group=groupVisual, inline = "ma4",
     tooltip = "Toggle the MA 4 line.")
ma4Color     = input.color(color.orange, "", group=groupVisual, inline = "ma4",
     tooltip = "Color for the MA 4 line.")
maWidth      = input.int(1, "MA Line Width", minval=1, maxval=4, group=groupVisual,
     tooltip ="Line thickness for the moving-average plots.")

groupBB = "〰 Bollinger Band Settings"
showBB = input.bool(false, "Toggle Bollinger Bands", group=groupBB,
     tooltip="Show Bollinger Bands around the RSI line.")
bbLength = input.int(20, "Bollinger Band Length", minval=1, group=groupBB,
     tooltip="Lookback length used to calculate the Bollinger basis and deviation.")
bbMultiplier = input.float(2.0, "Standard Deviation Multiplier", minval=0.1, step=0.1, group=groupBB,
     tooltip="Number of standard deviations used for the upper and lower bands.")
bbTopColor = input.color(color.red, "Top Band Color", group=groupBB,
     tooltip="Color of the upper Bollinger Band.")
bbBottomColor = input.color(color.green, "Bottom Band Color", group=groupBB,
     tooltip="Color of the lower Bollinger Band.")
bbBasisColor = input.color(color.gray, "Basis Color", group=groupBB,
     tooltip="Color of the Bollinger basis line.")
bbFillColor = input.color(color.blue, "Band Fill Color", group=groupBB,
     tooltip="Color used between the Bollinger Bands.")
bbTransparency = input.int(85, "Band Fill Transparency", minval=0, maxval=100, step=5, group=groupBB)

zoneUpperColor  = input.color(color.green, "High RSI Zone Color", group=groupVisual,
     tooltip    ="Color used to fill the RSI 70–80 high RSI zone.")
zoneMiddleColor = input.color(color.yellow, "Neutral RSI Zone Color", group=groupVisual,
     tooltip    ="Color used to fill the RSI 45-55 neutral zone. Price will accelerate more than usual when making moves in the upward direction above this zone or downward direction when below this zone.")
zoneLowerColor  = input.color(color.red, "Low RSI Zone Color", group=groupVisual,
     tooltip    ="Color used to fill the RSI 20–30 low RSI zone.")
showZones       = input.bool(true, "Show RSI Zones?", group=groupVisual,
     tooltip    ="Toggle fill display between 20-30, 45-55 & 70-80 RSI zones.")
zoneTransparency  = input.int(80, "RSI Zone Transparency", step=5, group=groupVisual,
     tooltip    ="Transparency amount for low, neutral and high RSI zones.")
dynamicRangePadding = input.float(5.0, "Dynamic Range Padding", minval=0.5, maxval=15.0, step=0.5, group=groupVisual,
     tooltip="Adds this many RSI points above the highest and below the lowest indicator value inside the zoom lookback.")
zoomLookback = input.int(300, "Zoom Lookback (bars)", minval=10, maxval=4500, group=groupVisual,
     tooltip="The scale fits the highest/lowest indicator values over this many recent bars, plus padding. Set roughly to the number of bars you keep on screen.")
revealDist = input.float(0.0, "Level Reveal Distance", minval=0.0, step=0.5, group=groupVisual,
     tooltip="If a zone boundary is within this many RSI points beyond the window extremes, extend the scale to include it so you can watch the level approach. 0 = off.")
envUpperColor   = input.color(color.red, "Upper Envelope Fill Color", group=groupVisual,
     tooltip    ="Color for the upper (fast) envelope band when dominant.")
envLowerColor   = input.color(color.green, "Lower Envelope Fill Color", group=groupVisual,
     tooltip    ="Color for the lower (fast) envelope band when dominant.")
fillTransp      = input.int(60, "Fill Transparency", step=5, group=groupVisual,
     tooltip    ="Transparency of the envelope fills and lines.")
showFill        = input.bool(true, "Show Envelope Fills?", group=groupVisual,
     tooltip    ="Toggle visibility of the dynamic red/green fill between dominant envelope bands.")

groupDebug = "🔧 Scale Debugging"
showScaleAnchors = input.bool(true, "Show Scale Anchor Dots", group=groupDebug,
     tooltip="Makes the two scale-anchor plots visible as white dots at the requested floor/ceiling. Turn off once the scale behaves.")
showScaleDebug = input.bool(true, "Show Scale Debug Table", group=groupDebug,
     tooltip="Shows the rolling high/low of every component group plus the final requested scale range. Compare the Scale row against what the pane actually displays. Turn off once the scale behaves.")

// ══════════════════════════════════════════════════════════════════════════════════════
// === 🧮 Core Logic ===
// ══════════════════════════════════════════════════════════════════════════════════════
get_ma(src, len, type) =>
    type == "WMA" ? ta.wma(src, len) : ta.sma(src, len)

get_smooth(src, len, type) =>
    type == "EMA" ? ta.ema(src, len) :
     type == "WMA" ? ta.wma(src, len) :
     type == "SMA" ? ta.sma(src, len) :
     ta.rma(src, len)

// Keep visuals inside the meaningful RSI display domain without changing the
// underlying values used by signals, comparisons, or alert conditions.
clamp_rsi_display(value) =>
    math.max(0.0, math.min(100.0, value))

include_min(float currentValue, float candidate) =>
    na(candidate) ? currentValue : na(currentValue) ? candidate : math.min(currentValue, candidate)

include_max(float currentValue, float candidate) =>
    na(candidate) ? currentValue : na(currentValue) ? candidate : math.max(currentValue, candidate)

rsiRaw = ta.rsi(close, rsiLen)
rsi    = smoothRSI ? get_smooth(rsiRaw, rsiSmoothLen, rsiSmoothType) : rsiRaw

// Wilder gain/loss state used to reconstruct the RSI range that occurred inside each price bar.
rsiChange = ta.change(close)
rsiAvgGain = ta.rma(math.max(rsiChange, 0.0), rsiLen)
rsiAvgLoss = ta.rma(math.max(-rsiChange, 0.0), rsiLen)

// Returns the raw close-based RSI that would exist on the current bar if price were at `price`.
rsi_raw_at_price(float price) =>
    float result = na
    prevGain = rsiAvgGain[1]
    prevLoss = rsiAvgLoss[1]
    prevClose = close[1]
    if not na(prevGain) and not na(prevLoss) and not na(prevClose)
        delta = price - prevClose
        thisGain = math.max(delta, 0.0)
        thisLoss = math.max(-delta, 0.0)
        newGain = (prevGain * (rsiLen - 1) + thisGain) / rsiLen
        newLoss = (prevLoss * (rsiLen - 1) + thisLoss) / rsiLen
        result := newLoss == 0.0 ? 100.0 : newGain == 0.0 ? 0.0 : 100.0 - (100.0 / (1.0 + newGain / newLoss))
    else
        result := rsiRaw
    result

// Converts a hypothetical raw RSI for THIS bar into the corresponding value of the final/smoothed RSI.
rsi_apply_current_smoothing(float rawHypothetical) =>
    float result = rawHypothetical
    if smoothRSI
        alpha = rsiSmoothType == "RMA" ? 1.0 / rsiSmoothLen :
                 rsiSmoothType == "EMA" ? 2.0 / (rsiSmoothLen + 1.0) :
                 rsiSmoothType == "SMA" ? 1.0 / rsiSmoothLen :
                 2.0 / (rsiSmoothLen + 1.0)  // WMA: newest sample weight / total weight
        result := na(rsi) or na(rsiRaw) ? rawHypothetical : rsi + alpha * (rawHypothetical - rsiRaw)
    result

rsiCandleRawOpen  = rsi_raw_at_price(open)
rsiCandleRawHigh  = rsi_raw_at_price(high)
rsiCandleRawLow   = rsi_raw_at_price(low)
rsiCandleRawClose = rsiRaw

rsiCandleFinalOpen  = rsi_apply_current_smoothing(rsiCandleRawOpen)
rsiCandleFinalHigh  = rsi_apply_current_smoothing(rsiCandleRawHigh)
rsiCandleFinalLow   = rsi_apply_current_smoothing(rsiCandleRawLow)
rsiCandleFinalClose = rsi

rsiCandleOpen  = rsiCandleSource == "Final RSI" ? rsiCandleFinalOpen  : rsiCandleRawOpen
rsiCandleHigh  = rsiCandleSource == "Final RSI" ? rsiCandleFinalHigh  : rsiCandleRawHigh
rsiCandleLow   = rsiCandleSource == "Final RSI" ? rsiCandleFinalLow   : rsiCandleRawLow
rsiCandleClose = rsiCandleSource == "Final RSI" ? rsiCandleFinalClose : rsiCandleRawClose

// Wick capping: quiet one-directional runs push Wilder avgLoss (or avgGain) toward zero,
// which makes the instantaneous RSI at a bar's extreme spike to ~100 (or ~0) even while
// the close-based RSI barely moves. Those degenerate wicks stretch auto-scale, so the
// DISPLAYED candle range is winsorized to the body plus a fixed allowance.
rsiCandleBodyHi = math.max(rsiCandleOpen, rsiCandleClose)
rsiCandleBodyLo = math.min(rsiCandleOpen, rsiCandleClose)
rsiCandleHighDisp = clamp_rsi_display(math.min(rsiCandleHigh, rsiCandleBodyHi + rsiCandleMaxWick))
rsiCandleLowDisp  = clamp_rsi_display(math.max(rsiCandleLow,  rsiCandleBodyLo - rsiCandleMaxWick))
rsiCandleOpenDisp  = clamp_rsi_display(rsiCandleOpen)
rsiCandleCloseDisp = clamp_rsi_display(rsiCandleClose)

rsiCandleDoji = math.abs(rsiCandleClose - rsiCandleOpen) <= rsiCandleDojiThreshold
rsiCandleUp = rsiCandleColorMode == "Price Candle" ? close >= open : rsiCandleClose >= rsiCandleOpen
rsiCandleBaseColor = rsiCandleDoji ? rsiCandleDojiColor : rsiCandleUp ? rsiCandleUpColor : rsiCandleDownColor
rsiCandleBodyColor = color.new(rsiCandleBaseColor, rsiCandleBodyTransp)
rsiCandleWickPlotColor = showRsiCandleWicks ? color.new(rsiCandleWickColor, rsiCandleWickTransp) : color.new(rsiCandleWickColor, 100)
rsiCandleBorderColor = showRsiCandleBorders ? color.new(rsiCandleBaseColor, rsiCandleBorderTransp) : color.new(rsiCandleBaseColor, 100)

rsiAvg = (high + low) / 2
rsiAvgRaw = ta.rsi(rsiAvg, rsiLen)
rsiAvgLine = smoothRSI ? get_smooth(rsiAvgRaw, rsiSmoothLen, rsiSmoothType) : rsiAvgRaw

rsiRoc = ta.roc(rsi, rsiRocLen)
rsiRocDisplay = 50 + (rsiRoc * rsiRocScale)

// Smooths moving averages if toggled
smoothMAs = smoothAll ? rsi : rsiRaw
ma1 = get_ma(smoothMAs, ma1Len, ma1Type)
ma2 = get_ma(smoothMAs, ma2Len, ma2Type)
ma3 = get_ma(smoothMAs, ma3Len, ma3Type)
ma4 = get_ma(smoothMAs, ma4Len, ma4Type)

bbBasis = ta.sma(rsi, bbLength)
bbDeviation = ta.stdev(rsi, bbLength) * bbMultiplier
bbTop = bbBasis + bbDeviation
bbBottom = bbBasis - bbDeviation

// Envelope math
envOffset1 = ma1 * envPerc / 100
upperEnv1  = ma1 + envOffset1
lowerEnv1  = ma1 - envOffset1
envOffset2 = ma2 * envPerc / 100
upperEnv2  = ma2 + envOffset2
lowerEnv2  = ma2 - envOffset2
envOffset3 = ma3 * envPerc / 100
upperEnv3  = ma3 + envOffset3
lowerEnv3  = ma3 - envOffset3
envOffset4 = ma4 * envPerc / 100
upperEnv4  = ma4 + envOffset4
lowerEnv4  = ma4 - envOffset4

// Dominance logic
rsiAbove1 = rsi > ma1
rsiAbove2 = rsi > ma2
rsiColor   = rsiAbove1 and rsiAbove2 ? color.lime :
             not rsiAbove1 and not rsiAbove2 ? color.red :
             rsiAbove1 != rsiAbove2 ? color.orange : na

// Envelope fade logic
highestUpperEnv = math.max(math.max(upperEnv1, upperEnv2), math.max(upperEnv3, upperEnv4))
lowestLowerEnv = math.min(math.min(lowerEnv1, lowerEnv2), math.min(lowerEnv3, lowerEnv4))

upper1Color = color.new(color.red,   upperEnv1 == highestUpperEnv ? fillTransp : na)
upper2Color = color.new(color.red,   upperEnv2 == highestUpperEnv ? fillTransp : na)
upper3Color = color.new(color.green, upperEnv3 == highestUpperEnv ? fillTransp : na)
upper4Color = color.new(color.green, upperEnv4 == highestUpperEnv ? fillTransp : na)
lower1Color = color.new(color.green, lowerEnv1 == lowestLowerEnv ? fillTransp : na)
lower2Color = color.new(color.green, lowerEnv2 == lowestLowerEnv ? fillTransp : na)
lower3Color = color.new(color.red,   lowerEnv3 == lowestLowerEnv ? fillTransp : na)
lower4Color = color.new(color.red,   lowerEnv4 == lowestLowerEnv ? fillTransp : na)

fillColorUpper = upperEnv1 > upperEnv2 ? color.new(envUpperColor, fillTransp) : na
fillColorLower = lowerEnv1 < lowerEnv2 ? color.new(envLowerColor, fillTransp) : na

// Display-state series. Hidden plots use `na` so they do not contaminate Auto scale.
rsiDisplay = clamp_rsi_display(rsi)
rsiAvgDisplay = clamp_rsi_display(rsiAvgLine)
rsiRocDisplayClamped = clamp_rsi_display(rsiRocDisplay)
bbTopDisplay = clamp_rsi_display(bbTop)
bbBottomDisplay = clamp_rsi_display(bbBottom)
bbBasisDisplay = clamp_rsi_display(bbBasis)

upperEnv1Display = clamp_rsi_display(upperEnv1)
upperEnv2Display = clamp_rsi_display(upperEnv2)
upperEnv3Display = clamp_rsi_display(upperEnv3)
upperEnv4Display = clamp_rsi_display(upperEnv4)
lowerEnv1Display = clamp_rsi_display(lowerEnv1)
lowerEnv2Display = clamp_rsi_display(lowerEnv2)
lowerEnv3Display = clamp_rsi_display(lowerEnv3)
lowerEnv4Display = clamp_rsi_display(lowerEnv4)

upper1Visible = upperEnv1 == highestUpperEnv
upper2Visible = upperEnv2 == highestUpperEnv
upper3Visible = upperEnv3 == highestUpperEnv
upper4Visible = upperEnv4 == highestUpperEnv
lower1Visible = lowerEnv1 == lowestLowerEnv
lower2Visible = lowerEnv2 == lowestLowerEnv
lower3Visible = lowerEnv3 == lowestLowerEnv
lower4Visible = lowerEnv4 == lowestLowerEnv
upperFillVisible = showFill and upperEnv1 > upperEnv2
lowerFillVisible = showFill and lowerEnv1 < lowerEnv2

// ══════════════════════════════════════════════════════════════════════════════════════
// === 📐 Dynamic Scale (rolling window) ===
// ══════════════════════════════════════════════════════════════════════════════════════
// Per-bar extremes of each component GROUP, tracked separately so the debug table can
// identify which series drives the scale. Every value here is exactly what gets plotted.

// -- Candles --
float candBarLo = showRsiCandles ? rsiCandleLowDisp : na
float candBarHi = showRsiCandles ? rsiCandleHighDisp : na

// -- Lines (RSI / HL-avg RSI / ROC) --
float lineBarLo = na
float lineBarHi = na
lineBarLo := include_min(lineBarLo, showRsi ? rsiDisplay : na)
lineBarHi := include_max(lineBarHi, showRsi ? rsiDisplay : na)


// -- Moving averages --
float maBarLo = na
float maBarHi = na
maBarLo := include_min(maBarLo, showMa1 ? ma1 : na)
maBarHi := include_max(maBarHi, showMa1 ? ma1 : na)
maBarLo := include_min(maBarLo, showMa2 ? ma2 : na)
maBarHi := include_max(maBarHi, showMa2 ? ma2 : na)
maBarLo := include_min(maBarLo, showMa3 ? ma3 : na)
maBarHi := include_max(maBarHi, showMa3 ? ma3 : na)
maBarLo := include_min(maBarLo, showMa4 ? ma4 : na)
maBarHi := include_max(maBarHi, showMa4 ? ma4 : na)

// -- Envelopes (dominant lines + active fills) --
float envBarLo = na
float envBarHi = na
envBarLo := include_min(envBarLo, upper1Visible ? upperEnv1Display : na)
envBarHi := include_max(envBarHi, upper1Visible ? upperEnv1Display : na)
envBarLo := include_min(envBarLo, upper2Visible ? upperEnv2Display : na)
envBarHi := include_max(envBarHi, upper2Visible ? upperEnv2Display : na)
envBarLo := include_min(envBarLo, upper3Visible ? upperEnv3Display : na)
envBarHi := include_max(envBarHi, upper3Visible ? upperEnv3Display : na)
envBarLo := include_min(envBarLo, upper4Visible ? upperEnv4Display : na)
envBarHi := include_max(envBarHi, upper4Visible ? upperEnv4Display : na)
envBarLo := include_min(envBarLo, lower1Visible ? lowerEnv1Display : na)
envBarHi := include_max(envBarHi, lower1Visible ? lowerEnv1Display : na)
envBarLo := include_min(envBarLo, lower2Visible ? lowerEnv2Display : na)
envBarHi := include_max(envBarHi, lower2Visible ? lowerEnv2Display : na)
envBarLo := include_min(envBarLo, lower3Visible ? lowerEnv3Display : na)
envBarHi := include_max(envBarHi, lower3Visible ? lowerEnv3Display : na)
envBarLo := include_min(envBarLo, lower4Visible ? lowerEnv4Display : na)
envBarHi := include_max(envBarHi, lower4Visible ? lowerEnv4Display : na)
envBarLo := include_min(envBarLo, upperFillVisible ? math.min(upperEnv1Display, upperEnv2Display) : na)
envBarHi := include_max(envBarHi, upperFillVisible ? math.max(upperEnv1Display, upperEnv2Display) : na)
envBarLo := include_min(envBarLo, lowerFillVisible ? math.min(lowerEnv1Display, lowerEnv2Display) : na)
envBarHi := include_max(envBarHi, lowerFillVisible ? math.max(lowerEnv1Display, lowerEnv2Display) : na)

// -- Bollinger Bands --
float bbBarLo = showBB ? bbBottomDisplay : na
float bbBarHi = showBB ? bbTopDisplay : na

// Rolling extremes over the zoom lookback. The nz() sentinels make na bars neutral:
// a missing low contributes 100 (can never win lowest), a missing high contributes 0
// (can never win highest).
winCandLo = ta.lowest(nz(candBarLo, 100.0), zoomLookback)
winCandHi = ta.highest(nz(candBarHi, 0.0), zoomLookback)
winLineLo = ta.lowest(nz(lineBarLo, 100.0), zoomLookback)
winLineHi = ta.highest(nz(lineBarHi, 0.0), zoomLookback)
winMaLo   = ta.lowest(nz(maBarLo, 100.0), zoomLookback)
winMaHi   = ta.highest(nz(maBarHi, 0.0), zoomLookback)
winEnvLo  = ta.lowest(nz(envBarLo, 100.0), zoomLookback)
winEnvHi  = ta.highest(nz(envBarHi, 0.0), zoomLookback)
winBbLo   = ta.lowest(nz(bbBarLo, 100.0), zoomLookback)
winBbHi   = ta.highest(nz(bbBarHi, 0.0), zoomLookback)

float visibleWindowLow  = math.min(winCandLo, math.min(winLineLo, math.min(winMaLo, math.min(winEnvLo, winBbLo))))
float visibleWindowHigh = math.max(winCandHi, math.max(winLineHi, math.max(winMaHi, math.max(winEnvHi, winBbHi))))

// Safety fallback for a configuration where every visual toggle is disabled.
visibleWindowLow  := visibleWindowLow >= 100.0 ? rsiDisplay : visibleWindowLow
visibleWindowHigh := visibleWindowHigh <= 0.0 ? rsiDisplay : visibleWindowHigh

float dynamicScaleLow  = visibleWindowLow - dynamicRangePadding
float dynamicScaleHigh = visibleWindowHigh + dynamicRangePadding

// Optional: pull the next zone boundary into view while it is being approached.
next_level_above(float v) =>
    v < 20 ? 20.0 : v < 30 ? 30.0 : v < 45 ? 45.0 : v < 55 ? 55.0 : v < 70 ? 70.0 : v < 80 ? 80.0 : float(na)

next_level_below(float v) =>
    v > 80 ? 80.0 : v > 70 ? 70.0 : v > 55 ? 55.0 : v > 45 ? 45.0 : v > 30 ? 30.0 : v > 20 ? 20.0 : float(na)

if revealDist > 0.0
    float lvlAbove = next_level_above(visibleWindowHigh)
    float lvlBelow = next_level_below(visibleWindowLow)
    if not na(lvlAbove) and lvlAbove - visibleWindowHigh <= revealDist
        dynamicScaleHigh := math.max(dynamicScaleHigh, lvlAbove + 1.0)
    if not na(lvlBelow) and visibleWindowLow - lvlBelow <= revealDist
        dynamicScaleLow := math.min(dynamicScaleLow, lvlBelow - 1.0)

dynamicAnchorBar = time == chart.right_visible_bar_time or (barstate.islast and chart.right_visible_bar_time > time)
anchorColor = showScaleAnchors ? color.new(color.white, 0) : color.new(color.white, 100)

// ══════════════════════════════════════════════════════════════════════════════════════
// === 📈 Plots ===
// ══════════════════════════════════════════════════════════════════════════════════════
// One-bar plots make Auto scale honor the padded rolling-window range without
// drawing permanent horizontal levels across the pane.
plot(dynamicAnchorBar ? dynamicScaleLow : na, title="Dynamic Scale Floor", color=anchorColor, style=plot.style_circles, editable=false, display=display.pane)
plot(dynamicAnchorBar ? dynamicScaleHigh : na, title="Dynamic Scale Ceiling", color=anchorColor, style=plot.style_circles, editable=false, display=display.pane)

plotcandle(
     showRsiCandles ? rsiCandleOpenDisp : na,
     showRsiCandles ? rsiCandleHighDisp : na,
     showRsiCandles ? rsiCandleLowDisp : na,
     showRsiCandles ? rsiCandleCloseDisp : na,
     title="RSI OHLC Candles",
     color=rsiCandleBodyColor,
     wickcolor=rsiCandleWickPlotColor,
     bordercolor=rsiCandleBorderColor)

plot(showRsi ? rsiDisplay : na, title="RSI Glow", color=color.new(rsiColor, rsiGlowTransp), linewidth=rsiGlowWidth)
plot(showRsi ? rsiDisplay : na, title="RSI", color=rsiColor, linewidth=rsiLineWidth)

plot(showMa1 ? ma1 : na, title="MA 1", color=ma1Color, linewidth=maWidth)
plot(showMa2 ? ma2 : na, title="MA 2", color=ma2Color, linewidth=maWidth)
plot(showMa3 ? ma3 : na, title="MA 3", color=ma3Color, linewidth=maWidth)
plot(showMa4 ? ma4 : na, title="MA 4", color=ma4Color, linewidth=maWidth)

bbTopPlot = plot(showBB ? bbTopDisplay : na, title="Bollinger Top Band", color=bbTopColor, linewidth=1)
bbBottomPlot = plot(showBB ? bbBottomDisplay : na, title="Bollinger Bottom Band", color=bbBottomColor, linewidth=1)
bbBasisPlot = plot(showBB ? bbBasisDisplay : na, title="Bollinger Basis", color=bbBasisColor, linewidth=1)
fill(bbTopPlot, bbBottomPlot, color=showBB ? color.new(bbFillColor, bbTransparency) : na, title="Bollinger Band Fill")

plot(upper1Visible ? upperEnv1Display : na, title="Upper Envelope MA 1", color=upper1Color, linewidth=1, style=plot.style_linebr)
plot(upper2Visible ? upperEnv2Display : na, title="Upper Envelope MA 2", color=upper2Color, linewidth=2, style=plot.style_linebr)
plot(upper3Visible ? upperEnv3Display : na, title="Upper Envelope MA 3", color=upper3Color, linewidth=2, style=plot.style_linebr)
plot(upper4Visible ? upperEnv4Display : na, title="Upper Envelope MA 4", color=upper4Color, linewidth=2, style=plot.style_linebr)
plot(lower1Visible ? lowerEnv1Display : na, title="Lower Envelope MA 1", color=lower1Color, linewidth=1, style=plot.style_linebr)
plot(lower2Visible ? lowerEnv2Display : na, title="Lower Envelope MA 2", color=lower2Color, linewidth=2, style=plot.style_linebr)
plot(lower3Visible ? lowerEnv3Display : na, title="Lower Envelope MA 3", color=lower3Color, linewidth=2, style=plot.style_linebr)
plot(lower4Visible ? lowerEnv4Display : na, title="Lower Envelope MA 4", color=lower4Color, linewidth=2, style=plot.style_linebr)

fill(
     plot(upperFillVisible ? upperEnv1Display : na, title="Upper Envelope MA 1 Fill", color=na, style=plot.style_linebr),
     plot(upperFillVisible ? upperEnv2Display : na, title="Upper Envelope MA 2 Fill", color=na, style=plot.style_linebr),
     color = showFill ? fillColorUpper : na,
     title = "Upper Envelope Fill",
     fillgaps = false)

fill(
     plot(lowerFillVisible ? lowerEnv1Display : na, title="Lower Envelope MA 1 Fill", color=na, style=plot.style_linebr),
     plot(lowerFillVisible ? lowerEnv2Display : na, title="Lower Envelope MA 2 Fill", color=na, style=plot.style_linebr),
     color = showFill ? fillColorLower : na,
     title = "Lower Envelope Fill",
     fillgaps = false)

// === RSI Zones ===
// TradingView's auto-fit DOES include box/line drawings (verified empirically), so the
// zones must be clipped to the dynamic scale range. Only the sliver of each zone that
// overlaps the padded window is drawn; a full-height box would pin the scale to 20-80
// and defeat the dynamic zoom.
var box lowerZoneBox = box.new(left=na, top=na, right=na, bottom=na, xloc=xloc.bar_time, border_color=na, bgcolor=na)
var box middleZoneBox = box.new(left=na, top=na, right=na, bottom=na, xloc=xloc.bar_time, border_color=na, bgcolor=na)
var box upperZoneBox = box.new(left=na, top=na, right=na, bottom=na, xloc=xloc.bar_time, border_color=na, bgcolor=na)
var line visibleMidline = line.new(x1=na, y1=na, x2=na, y2=na, xloc=xloc.bar_time, extend=extend.none, color=na, style=line.style_dashed, width=1)

// Extend the right edge well past the newest bar so live auto-scroll never outruns the boxes.
zoneRightTime() =>
    math.max(chart.right_visible_bar_time, time + timeframe.in_seconds() * 1000 * 500)

set_zone(box zoneBox, float zoneBottom, float zoneTop, color zoneColor, bool enabled) =>
    clippedBottom = math.max(zoneBottom, dynamicScaleLow)
    clippedTop = math.min(zoneTop, dynamicScaleHigh)
    zoneVisible = enabled and not na(clippedBottom) and not na(clippedTop) and clippedTop > clippedBottom
    // Hidden state parks a zero-height box inside the scale range so it cannot affect the fit.
    hiddenY = na(dynamicScaleLow) ? 50.0 : dynamicScaleLow + 1.0
    box.set_left(zoneBox, chart.left_visible_bar_time)
    box.set_right(zoneBox, zoneRightTime())
    box.set_top(zoneBox, zoneVisible ? clippedTop : hiddenY)
    box.set_bottom(zoneBox, zoneVisible ? clippedBottom : hiddenY)
    box.set_bgcolor(zoneBox, zoneVisible ? color.new(zoneColor, zoneTransparency) : na)

visibleWindowComplete = time == chart.right_visible_bar_time or barstate.islast

if visibleWindowComplete
    set_zone(lowerZoneBox, 20.0, 30.0, zoneLowerColor, showZones)
    set_zone(middleZoneBox, 45.0, 55.0, zoneMiddleColor, showZones)
    set_zone(upperZoneBox, 70.0, 80.0, zoneUpperColor, showZones)

    // The 50 midline is also a drawing, so it too must stay inside the scale range.
    midlineVisible = not na(dynamicScaleLow) and not na(dynamicScaleHigh) and dynamicScaleLow <= 50.0 and dynamicScaleHigh >= 50.0
    hiddenMidY = na(dynamicScaleLow) ? 50.0 : dynamicScaleLow + 1.0
    line.set_xy1(visibleMidline, chart.left_visible_bar_time, midlineVisible ? 50.0 : hiddenMidY)
    line.set_xy2(visibleMidline, zoneRightTime(), midlineVisible ? 50.0 : hiddenMidY)
    line.set_color(visibleMidline, midlineVisible ? color.yellow : na)


// === Main Price Chart Background Signals ===
// The envelope states persist for every qualifying bar.
redFillActive = upperEnv1 > upperEnv2
greenFillActive = lowerEnv1 < lowerEnv2
redFillLowerEdge = math.min(upperEnv1, upperEnv2)
greenFillUpperEdge = math.max(lowerEnv1, lowerEnv2)
rsiInsideOrAboveRedFill = redFillActive and rsi >= redFillLowerEdge
rsiInsideOrBelowGreenFill = greenFillActive and rsi <= greenFillUpperEdge

// Midline and moving-average signals occur only on the exact crossover bar.
rsiCross50 = ta.cross(rsi, 50)
rsiCrossMa1 = ta.cross(rsi, ma1)
rsiCrossMa2 = ta.cross(rsi, ma2)
rsiCrossMa3 = ta.cross(rsi, ma3)
rsiCrossMa4 = ta.cross(rsi, ma4)

// Crossover events take priority over persistent envelope states.
color mainChartBgColor =
     showMa4CrossChartBg and rsiCrossMa4
         ? color.new(ma4Color, chartBgTransparency)
     : showMa3CrossChartBg and rsiCrossMa3
         ? color.new(ma3Color, chartBgTransparency)
     : showMa2CrossChartBg and rsiCrossMa2
         ? color.new(ma2Color, chartBgTransparency)
     : showMa1CrossChartBg and rsiCrossMa1
         ? color.new(ma1Color, chartBgTransparency)
     : showRsi50CrossChartBg and rsiCross50
         ? color.new(color.yellow, chartBgTransparency)
     : showRedFillChartBg and rsiInsideOrAboveRedFill
         ? color.new(envUpperColor, chartBgTransparency)
     : showGreenFillChartBg and rsiInsideOrBelowGreenFill
         ? color.new(envLowerColor, chartBgTransparency)
     : na

bgcolor(mainChartBgColor, title="RIFT Main Chart Background", force_overlay=true)
````
