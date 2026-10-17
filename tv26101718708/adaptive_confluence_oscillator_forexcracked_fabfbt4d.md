# Adaptive Confluence Oscillator [ForexCracked]

- url: https://www.tradingview.com/script/fABFBt4d-Adaptive-Confluence-Oscillator-ForexCracked/
- type: indicator
- pine_id: PUB;5abf30a420244e3ca84033a567e7a1ff
- version: 1.0

## Description

🔵 OVERVIEW

The Adaptive Confluence Oscillator scores four independent read-outs of the market on a continuous scale, weights them according to the current market regime, and plots the result as a single 0 to 100 line. Instead of asking "do my indicators agree, yes or no," it asks "how strongly does each one agree, and which of them should I be listening to right now."

It has no fixed overbought or oversold levels. The bands are calculated from the oscillator's own recent behaviour, so they widen when the market gets volatile and tighten when it goes quiet.

Signals confirm on candle close and do not repaint.

🔵 WHY THIS IS BUILT THE WAY IT IS

Most multi-indicator tools take a vote. RSI is oversold or it is not. That throws away most of the information: an RSI of 29 and an RSI of 12 are not the same signal, but a vote counts them identically. It also treats every indicator as equally relevant at all times, which is plainly false. Stochastic exhaustion means one thing in a strong trend and the opposite thing in a range.

This oscillator fixes both problems. Every component returns a continuous score, and the market regime decides how much each score is worth.

🔵 THE FOUR COMPONENTS (each scored from -1 to +1)

• Trend: how far price sits from its baseline EMA, measured in ATR units rather than in price. Distance matters, not just which side of the line you are on. Because it is measured in ATR, it reads the same on gold as it does on EURUSD.

• Momentum: RSI recentred around 50, so it contributes proportionally instead of flipping at a threshold.

• Impulse: the MACD histogram converted to a z-score against its own rolling deviation. This makes MACD comparable across symbols and timeframes without ever re-tuning it, which raw MACD values are not.

• Stretch: the Stochastic, recentred. This is the component that changes behaviour with regime (see below).

🔵 THE REGIME SWITCH (the part that makes it adaptive)

ADX decides whether the market is trending or ranging, and that changes two things.

First, the weights re-balance:

• Trending: Trend 0.35, Momentum 0.25, Impulse 0.30, Stretch 0.10

• Ranging: Trend 0.15, Momentum 0.25, Impulse 0.20, Stretch 0.40

Second, and more importantly, the Stretch component flips sign. In a trend, a stretched Stochastic confirms the move and pushes the score further in that direction. In a range, the same reading argues for a fade and pushes the score the other way. This is the behaviour a discretionary trader applies without thinking about it, and it is what a fixed vote cannot express.

🔵 ADAPTIVE BANDS

There are no 70/30 lines here. The upper and lower bands are the rolling mean of the oscillator plus and minus a multiple of its own standard deviation. A reading of 68 can be an extreme in a quiet market and completely unremarkable in a volatile one, and the bands reflect that.

• BUY: the score crosses above the upper adaptive band

• SELL: the score crosses below the lower adaptive band

🔵 DIVERGENCE

The script finds pivots on the score itself and compares them against price at those same bars. When price makes a higher high but the score makes a lower high, that is marked as a bearish divergence, and the mirror case as bullish. Divergences are labelled and have their own alerts. Because a divergence is anchored to a confirmed pivot, it prints a few bars after that pivot forms and never moves once printed.

🔵 THE DASHBOARD

The panel shows each component's live score, its current weight, the detected regime with the ADX value, and the oscillator against its adaptive bands. You can see exactly which component is driving the reading and why, rather than trusting a black box.

🔵 SETTINGS

• Baseline EMA 34, ATR 14, Trend Span 2.0 x ATR

• RSI 14, MACD 12/26/9, Stochastic 14

• ADX 14, trending above 22

• Band lookback 100, band width 1.0 x standard deviation

🔵 HOW TO USE

• Take signals where the dashboard regime agrees with the direction. A BUY in a trending regime is a continuation. A BUY in a ranging regime is a fade off the bottom of the range.

• Treat a divergence as a warning to tighten or take partials, not as a standalone entry.

• Raise the band width above 1.0 for fewer and stronger signals, lower it for more.

• Widen Trend Span on noisy symbols so ordinary volatility does not read as trend.

⚠️ DISCLAIMER

This is an analysis tool, not a prediction. A confluence score is a measure of agreement, and indicators can agree and still be wrong. Results depend on market conditions, settings, and your own execution and risk management. Shared for educational and research purposes. Not financial advice.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © ForexCracked

//@version=6
indicator("Adaptive Confluence Oscillator [ForexCracked]", shorttitle="ACO [FXC]", overlay=false, max_labels_count=500)

// =====================================================================
// Adaptive Confluence Oscillator - original work.
// ---------------------------------------------------------------------
// This is not a threshold-vote indicator.
//
// 1) CONTINUOUS SCORING. Each component returns a score in [-1, +1]
//    instead of a yes/no vote, so an RSI of 29 and an RSI of 12 do not
//    contribute the same amount.
//
// 2) SCALE-FREE NORMALIZATION. Trend is the distance of price from a
//    baseline EMA measured in ATR units. Impulse is the MACD histogram
//    converted to a z-score against its own rolling deviation. Both are
//    therefore comparable across symbols without re-tuning.
//
// 3) ADAPTIVE BANDS. No fixed 70/30 or 55/45. The bands are the rolling
//    mean of the oscillator plus/minus a multiple of its own standard
//    deviation, so they widen in volatile conditions and tighten in calm.
//
// 4) REGIME-WEIGHTED. ADX decides the weighting. In a trend, trend and
//    impulse dominate. In a range, stretch dominates AND FLIPS SIGN,
//    because a stretched oscillator confirms a trend but fades a range.
//
// 5) DIVERGENCE. Price is compared against the score at the score's own
//    pivots.
//
// Signals confirm on candle close and do not repaint.
// =====================================================================

// ---------------- INPUTS ----------------
gC = "Components"
emaLen   = input.int(34, "Baseline EMA", minval = 5, group = gC, tooltip = "The trend component measures how far price sits from this EMA, in ATR units.")
atrLen   = input.int(14, "ATR Length", minval = 2, group = gC)
atrSpan  = input.float(2.0, "Trend Span (x ATR)", minval = 0.5, step = 0.5, group = gC, tooltip = "How many ATRs away from the baseline counts as a full-strength trend score.")
rsiLen   = input.int(14, "RSI Length", minval = 2, group = gC)
macdFast = input.int(12, "MACD Fast", minval = 2, group = gC)
macdSlow = input.int(26, "MACD Slow", minval = 3, group = gC)
macdSig  = input.int(9,  "MACD Signal", minval = 2, group = gC)
stochLen = input.int(14, "Stochastic Length", minval = 2, group = gC)

gR = "Regime"
adxLen = input.int(14, "ADX Length", minval = 2, group = gR)
adxSm  = input.int(14, "ADX Smoothing", minval = 2, group = gR)
adxTh  = input.float(22.0, "Trending Above ADX", minval = 5.0, step = 1.0, group = gR, tooltip = "Above this value the market is treated as trending and the component weights re-balance.")

gB = "Adaptive Bands"
bandLen  = input.int(100, "Band Lookback", minval = 20, group = gB)
bandMult = input.float(1.0, "Band Width (x StDev)", minval = 0.25, step = 0.25, group = gB)

gV = "Visuals"
showSignals = input.bool(true, "Show BUY / SELL Labels", group = gV)
showDiv     = input.bool(true, "Show Divergence", group = gV)
divLen      = input.int(5, "Divergence Pivot Strength", minval = 2, maxval = 20, group = gV)
showDash    = input.bool(true, "Show Dashboard", group = gV)
bullCol     = input.color(#26a69a, "Bullish", group = gV)
bearCol     = input.color(#ef5350, "Bearish", group = gV)
neutCol     = input.color(#787b86, "Neutral", group = gV)

// ---------------- COMPONENTS (each resolves to -1 .. +1) ----------------
atr      = ta.atr(atrLen)
baseline = ta.ema(close, emaLen)

// 1) TREND: distance from the baseline in ATR units, clipped to the range
trendRaw   = atr > 0 ? (close - baseline) / (atr * atrSpan) : 0.0
trendScore = math.max(-1.0, math.min(1.0, trendRaw))

// 2) MOMENTUM: RSI recentred on 50
rsiVal   = ta.rsi(close, rsiLen)
momScore = (rsiVal - 50.0) / 50.0

// 3) IMPULSE: MACD histogram as a z-score against its own deviation
[macdLine, sigLine, histLine] = ta.macd(close, macdFast, macdSlow, macdSig)
histSd   = ta.stdev(histLine, bandLen)
impRaw   = histSd > 0 ? histLine / (histSd * 2.0) : 0.0
impScore = math.max(-1.0, math.min(1.0, impRaw))

// 4) STRETCH: stochastic recentred on 50 (sign is decided by regime below)
stochVal    = ta.stoch(close, high, low, stochLen)
stretchBase = (stochVal - 50.0) / 50.0

// ---------------- REGIME ----------------
[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxSm)
trending = adxVal >= adxTh

// In a trend a stretched stochastic CONFIRMS. In a range it FADES.
stretchScore = trending ? stretchBase : -stretchBase

// Weights re-balance with the regime. Each set sums to 1.0
wTrend   = trending ? 0.35 : 0.15
wMom     = trending ? 0.25 : 0.25
wImp     = trending ? 0.30 : 0.20
wStretch = trending ? 0.10 : 0.40

// ---------------- THE OSCILLATOR ----------------
raw = wTrend * trendScore + wMom * momScore + wImp * impScore + wStretch * stretchScore
osc = (raw + 1.0) * 50.0     // map -1..+1 onto 0..100

// ---------------- ADAPTIVE BANDS ----------------
oscMean = ta.sma(osc, bandLen)
oscSd   = ta.stdev(osc, bandLen)
upper   = math.min(100.0, oscMean + bandMult * oscSd)
lower   = math.max(0.0,   oscMean - bandMult * oscSd)

// ---------------- SIGNALS ----------------
buy  = ta.crossover(osc, upper)
sell = ta.crossunder(osc, lower)

oscCol = osc > upper ? bullCol : osc < lower ? bearCol : neutCol

// ---------------- DIVERGENCE (price vs the score, at the score's own pivots) ----------------
phOsc = ta.pivothigh(osc, divLen, divLen)
plOsc = ta.pivotlow(osc, divLen, divLen)

var float prevOscHigh   = na
var float prevPriceHigh = na
var float prevOscLow    = na
var float prevPriceLow  = na

bool bearDiv = false
bool bullDiv = false

if not na(phOsc)
    pxHigh = high[divLen]
    if not na(prevOscHigh) and pxHigh > prevPriceHigh and phOsc < prevOscHigh
        bearDiv := true
    prevOscHigh   := phOsc
    prevPriceHigh := pxHigh

if not na(plOsc)
    pxLow = low[divLen]
    if not na(prevOscLow) and pxLow < prevPriceLow and plOsc > prevOscLow
        bullDiv := true
    prevOscLow   := plOsc
    prevPriceLow := pxLow

// ---------------- PLOTS ----------------
pUp = plot(upper, "Upper Band", color = color.new(neutCol, 55), linewidth = 1)
pLo = plot(lower, "Lower Band", color = color.new(neutCol, 55), linewidth = 1)
fill(pUp, pLo, color = color.new(neutCol, 92))
hline(50, "Midline", linestyle = hline.style_dotted, color = color.new(color.gray, 55))
plot(osc, "Confluence Score", color = oscCol, linewidth = 2)

if showSignals and buy
    label.new(bar_index, osc, "BUY", style = label.style_label_up, color = bullCol, textcolor = color.white, size = size.small)
if showSignals and sell
    label.new(bar_index, osc, "SELL", style = label.style_label_down, color = bearCol, textcolor = color.white, size = size.small)

if showDiv and bearDiv
    label.new(bar_index - divLen, phOsc, "Bear Div", style = label.style_label_down, color = color.new(bearCol, 35), textcolor = color.white, size = size.tiny)
if showDiv and bullDiv
    label.new(bar_index - divLen, plOsc, "Bull Div", style = label.style_label_up, color = color.new(bullCol, 35), textcolor = color.white, size = size.tiny)

// ---------------- DASHBOARD ----------------
var table dash = table.new(position.top_right, 3, 7, bgcolor = color.new(#1a1a2e, 10), border_width = 1, border_color = color.new(color.gray, 60))

if barstate.islast and showDash
    table.cell(dash, 0, 0, "Component", text_color = color.white, text_size = size.small, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 1, 0, "Score",     text_color = color.white, text_size = size.small, bgcolor = color.new(#0d47a1, 20))
    table.cell(dash, 2, 0, "Weight",    text_color = color.white, text_size = size.small, bgcolor = color.new(#0d47a1, 20))

    table.cell(dash, 0, 1, "Trend", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 1, str.tostring(trendScore, "#.00"), text_color = trendScore >= 0 ? bullCol : bearCol, text_size = size.tiny)
    table.cell(dash, 2, 1, str.tostring(wTrend, "#.00"), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 2, "Momentum", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 2, str.tostring(momScore, "#.00"), text_color = momScore >= 0 ? bullCol : bearCol, text_size = size.tiny)
    table.cell(dash, 2, 2, str.tostring(wMom, "#.00"), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 3, "Impulse", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 3, str.tostring(impScore, "#.00"), text_color = impScore >= 0 ? bullCol : bearCol, text_size = size.tiny)
    table.cell(dash, 2, 3, str.tostring(wImp, "#.00"), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 4, "Stretch", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 4, str.tostring(stretchScore, "#.00"), text_color = stretchScore >= 0 ? bullCol : bearCol, text_size = size.tiny)
    table.cell(dash, 2, 4, str.tostring(wStretch, "#.00"), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 5, "Regime", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 5, trending ? "Trending" : "Ranging", text_color = trending ? bullCol : neutCol, text_size = size.tiny)
    table.cell(dash, 2, 5, "ADX " + str.tostring(adxVal, "#.0"), text_color = color.white, text_size = size.tiny)

    table.cell(dash, 0, 6, "Oscillator", text_color = color.gray, text_size = size.tiny)
    table.cell(dash, 1, 6, str.tostring(osc, "#.0"), text_color = oscCol, text_size = size.tiny)
    table.cell(dash, 2, 6, str.tostring(lower, "#.0") + " - " + str.tostring(upper, "#.0"), text_color = color.white, text_size = size.tiny)

// ---------------- ALERTS ----------------
alertcondition(buy,     title = "Confluence BUY",      message = "Adaptive Confluence BUY on {{ticker}} {{interval}}")
alertcondition(sell,    title = "Confluence SELL",     message = "Adaptive Confluence SELL on {{ticker}} {{interval}}")
alertcondition(bullDiv, title = "Bullish Divergence",  message = "Bullish divergence on {{ticker}} {{interval}}")
alertcondition(bearDiv, title = "Bearish Divergence",  message = "Bearish divergence on {{ticker}} {{interval}}")
````
