# Uptrick X PineIndicators: Z-Score Flow Strategy

- url: https://www.tradingview.com/script/58zwiw6n-Uptrick-X-PineIndicators-Z-Score-Flow-Strategy/
- type: strategy
- pine_id: PUB;9ff7fdccaa6846cfa68fe36142941070
- version: 1.0

## Description

This strategy is based on the Z-Score Flow Indicator developed by Uptrick. Full credit for the original concept and logic goes to Uptrick.

The Z-Score Flow Strategy combines statistical mean-reversion logic with trend filtering, RSI confirmation, and multi-mode trade execution, offering a flexible and structured approach to trading both reversals and trend continuations.

[b]Core Concepts Behind Z-Score Flow[/b]
[b]1. Z-Score Mean Reversion Logic[/b]
The Z-score measures how far current price deviates from its statistical mean, in standard deviations.
[list]
[*] A high positive Z-score (e.g. > 2) suggests price is overbought and may revert downward.
[*] A low negative Z-score (e.g. < -2) suggests price is oversold and may revert upward.
[/list]
The strategy uses Z-score thresholds to trigger signals when price deviates far enough from its mean.

[b]2. Trend Filtering with EMA[/b]
To prevent counter-trend entries, the strategy includes a trend filter based on a 50-period EMA:
[list]
[*] Only allows long entries if price is below EMA (mean-reversion in downtrends).
[*] Only allows short entries if price is above EMA (mean-reversion in uptrends).
[/list]

[b]3. RSI Confirmation and Lockout System[/b]
An RSI smoothing mechanism helps confirm signals and avoid whipsaws:
[list]
[*] RSI must be below 30 and rising to allow buys.
[*] RSI must be above 70 and falling to allow sells.
[*] Once a signal occurs, it is "locked out" until RSI re-enters the neutral zone (30–70).
[/list]

This avoids multiple signals in overextended zones and reduces overtrading.

[b]Entry Signal Logic[/b]
A buy or sell is triggered when:
[list]
[*] Z-score crosses below (buy) or above (sell) the threshold.
[*] RSI smoothed condition is met (oversold and rising / overbought and falling).
[*] The trend condition (EMA filter) aligns.
[*] A cooldown period has passed since the last opposite trade.
[/list]

This layered approach helps ensure signal quality and timing precision.

[b]Trade Modes[/b]
The strategy includes three distinct trade modes to adapt to various market behaviors:

[b]1. Standard Mode[/b]
[list]
[*] Trades are opened using the Z-score + RSI + trend filter logic.
[*] Each signal must pass all layered conditions.
[/list]

[b]2. Zero Cross Mode[/b]
[list]
[*] Trades are based on the Z-score crossing zero.
[*] This mode is useful in trend continuation setups, rather than mean reversion.
[/list]

[b]3. Trend Reversal Mode[/b]
[list]
[*] Trades occur when the mean slope direction changes, i.e., basis line changes color.
[*] Helps capture early trend shifts with less lag.
[/list]

Each mode can be customized for long-only, short-only, or long & short execution.

[b]Visual Components[/b]
[b]1. Z-Score Mean Line[/b]
[list]
[*] The basis (mean) line is colored based on slope direction.
[*] Green = bullish slope, Purple = bearish slope, Gray = flat.
[*] A wide shadow band underneath reflects current trend momentum.
[/list]

[b]2. Gradient Fill to Price[/b]
A gradient zone between price and the mean reflects:
[list]
[*] Price above mean = bearish zone with purple overlay.
[*] Price below mean = bullish zone with teal overlay.
[/list]

This visual aid quickly reveals market positioning relative to equilibrium.

[b]3. Signal Markers[/b]
[list]
[*] "𝓤𝓹" labels appear for buy signals.
[*] "𝓓𝓸𝔀𝓷" labels appear for sell signals.
[*] These are colored and positioned according to trend context.
[/list]

[b]Customization Options[/b]
[list]
[*] Z-Score Period & Thresholds: Define sensitivity to price deviations.
[*] EMA Trend Filter Length: Filter entries with long-term bias.
[*] RSI & Smoothing Periods: Fine-tune RSI confirmation conditions.
[*] Cooldown Period: Prevent signal spam and enforce timing gaps.
[*] Slope Index: Adjust how far back to compare mean slope.
[*] Visual Settings: Toggle mean lines, gradients, and more.
[/list]

[b]Use Cases & Strategy Strengths[/b]
[b]1. Mean-Reversion Trading
Ideal for catching pullbacks in trending markets or fading overextended price moves.

[b]2. Trend Continuation or Reversal
With multiple trade modes, traders can choose between fading price extremes or trading slope momentum.

[b]3. Signal Clarity and Risk Control
The combination of Z-score, RSI, EMA trend, and cooldown logic provides high-confidence signals with built-in filters.

[b]Conclusion[/b]
The Z-Score Flow Strategy by Uptrick X PineIndicators is a [b]versatile and structured trading system[/b] that:
[list]
[*] Fuses statistical deviation (Z-score) with technical filters.
[*] Provides both mean-reversion and trend-based entry logic.
[*] Uses visual overlays and signal labels for clarity.
[*] Prevents noise-driven trades via cooldown and lockout systems.
[/list]

This strategy is well-suited for traders seeking a data-driven, multi-condition entry framework that can adapt to various market types.

[b]Full credit for the original concept and indicator goes to Uptrick.[/b]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick X PineIndicators

//@version=6
strategy("Uptrick X PineIndicators: Z-Score Flow Strategy", overlay=true, initial_capital=10000, currency=currency.USD, default_qty_type=strategy.percent_of_equity, default_qty_value=30, pyramiding=0)

// ===== INPUTS from Original Indicator ===== //
zLen            = input.int(100, "Z-Score Period")
emaTrendLen     = input.int(50, "EMA Trend Filter")
rsiLen          = input.int(14, "RSI Length")
rsiEmaLen       = input.int(8, "EMA of RSI Period")
zBuyLevel       = input.float(-2.0, "Z-Score Buy Threshold")
zSellLevel      = input.float(2.0, "Z-Score Sell Threshold")
cooldownBars    = input.int(10, "Cooldown (Bars)")
slopeIndex      = input.int(30, "Slope Sensitivity (Bars)", minval=1)
showMeanLine    = input.bool(true, "Show Z-Score Mean Line")

// ===== CORE CALCULATIONS ===== //
basis       = ta.sma(close, zLen)
stdev       = ta.stdev(close, zLen)
zscore      = (close - basis) / stdev
emaTrend    = ta.ema(close, emaTrendLen)
rsi         = ta.rsi(close, rsiLen)
rsiEma      = ta.ema(rsi, rsiEmaLen)
rsiEmaSlope = rsiEma - rsiEma[1]

isUptrend   = close > emaTrend
isDowntrend = close < emaTrend

// ===== SINGLE-SIGNAL RSI ZONE LOCKOUT ===== //
var bool canBuy  = true
var bool canSell = true

if rsiEma > 30
    canBuy := true
if rsiEma < 70
    canSell := true

rsiBuyConfirm  = rsiEma < 30 and rsiEmaSlope > 0 and canBuy
rsiSellConfirm = rsiEma > 70 and rsiEmaSlope < 0 and canSell

rawBuy  = zscore < zBuyLevel and isDowntrend and rsiBuyConfirm
rawSell = zscore > zSellLevel and isUptrend and rsiSellConfirm

if rawBuy
    canBuy := false
if rawSell
    canSell := false

// ===== COOLDOWN LOGIC ===== //
var int lastBuyBar  = na
var int lastSellBar = na

buySignal  = rawBuy and (na(lastSellBar) or bar_index - lastSellBar > cooldownBars)
sellSignal = rawSell and (na(lastBuyBar) or bar_index - lastBuyBar > cooldownBars)

if buySignal
    lastBuyBar := bar_index
if sellSignal
    lastSellBar := bar_index

// ===== COLOR & PLOTTING DEFINITIONS ===== //
bullColor  = color.rgb(92, 240, 215)       // #5CF0D7
bearColor  = color.rgb(179, 42, 195)       // #B32AC3
flatColor  = color.rgb(136, 136, 136)       // gray

bullShadow = color.rgb(92, 240, 215, 50)
bearShadow = color.rgb(179, 42, 195, 50)
flatShadow = color.new(flatColor, 80)

slopeColor  = basis > basis[slopeIndex] ? bullColor : basis < basis[slopeIndex] ? bearColor : flatColor
shadowColor = basis > basis[slopeIndex] ? bullShadow : basis < basis[slopeIndex] ? bearShadow : flatShadow

// ===== PLOT Z-SCORE MEAN LINE + SHADOW ===== //
plot(showMeanLine ? basis : na, "Z-Mean Shadow", color=shadowColor, linewidth=10)
plot(showMeanLine ? basis : na, "Z-Mean", color=slopeColor, linewidth=2)

// ===== GRADIENT FILL: Z-Mean to Price ===== //
showGradient = input.bool(true, "Show Gradient to Price")

// Define gradient color stops
bullTopColor  = chart.bg_color  // Top = brighter teal
bullBottomColor = #369081f2  // Bottom = almost transparent

bearTopColor  = chart.bg_color  // Top = stronger purple
bearBottomColor = #64176cf2  // Bottom = nearly clear

// Define fill zones
priceAbove = close > basis
priceBelow = close < basis

// Gradient when price is below the mean (bullish zone)
fill(
     plot1=plot(showGradient and priceBelow ? basis : na, title="Bull Basis", display=display.none),
     plot2=plot(showGradient and priceBelow ? close : na, title="Bull Price", display=display.none),
     top_value=close,
     bottom_value=basis,
     top_color=bearTopColor,
     bottom_color=bearBottomColor
 )

// Gradient when price is above the mean (bearish zone)
fill(
     plot1=plot(showGradient and priceAbove ? close : na, title="Bear Price", display=display.none),
     plot2=plot(showGradient and priceAbove ? basis : na, title="Bear Basis", display=display.none),
     top_value=close,
     bottom_value=basis,
     top_color=bullTopColor,
     bottom_color=bullBottomColor
 )

// ===== SIGNAL LABELS ===== //
plotshape(buySignal,
     title="𝓑𝓾𝔂",
     location=location.belowbar,
     color=bullColor,
     style=shape.labelup,
     text="𝓤𝓹",
     textcolor=color.black,
     size=size.small)

plotshape(sellSignal,
     title="𝓢𝓮𝓵𝓵",
     location=location.abovebar,
     color=bearColor,
     style=shape.labeldown,
     text="𝓓𝓸𝔀𝓷",
     textcolor=color.white,
     size=size.small)

// ===== TRADE MANAGEMENT INPUTS ===== //
tradeMode  = input.string("Standard", "Trade Mode", options=["Standard", "Zero Cross", "Trend Reversal"])
enableLong  = input.bool(true, "Enable Long Trades")
enableShort = input.bool(true, "Enable Short Trades")

// ===== STRATEGY ORDER EXECUTION ===== //
if tradeMode == "Standard"
    // Standard mode: use the original signals.
    if enableLong and buySignal
        strategy.entry("Long", strategy.long)
    if enableLong and sellSignal
        strategy.close("Long")
    
    if enableShort and sellSignal
        strategy.entry("Short", strategy.short)
    if enableShort and buySignal
        strategy.close("Short")
else if tradeMode == "Zero Cross"
    // Zero Cross Mode: trade when the raw z-score crosses 0.
    zeroCrossUp   = ta.crossover(zscore, 0)
    zeroCrossDown = ta.crossunder(zscore, 0)
    
    if zeroCrossUp
        if enableShort
            strategy.close("Short")
        if enableLong
            strategy.entry("Long", strategy.long)
    if zeroCrossDown
        if enableLong
            strategy.close("Long")
        if enableShort
            strategy.entry("Short", strategy.short)
else if tradeMode == "Trend Reversal"
    // Trend Reversal Mode: trade based on the indicator's color change (from bullish to bearish or vice versa)
    bullishCondition = basis > basis[slopeIndex]
    bearishCondition = basis < basis[slopeIndex]
    trendBullishReversal = bearishCondition[1] and bullishCondition    // War vorher bearish, jetzt bullish.
    trendBearishReversal = bullishCondition[1] and bearishCondition    // War vorher bullish, jetzt bearish.
    
    if trendBullishReversal
        if enableShort
            strategy.close("Short")
        if enableLong
            strategy.entry("Long", strategy.long)
    if trendBearishReversal
        if enableLong
            strategy.close("Long")
        if enableShort
            strategy.entry("Short", strategy.short)

// ===== ALERTS ===== //
alertcondition(buySignal, title="Buy Alert", message="📈 Z-Score Flow Buy Signal")
alertcondition(sellSignal, title="Sell Alert", message="📉 Z-Score Flow Sell Signal")
````
