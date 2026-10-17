# Uptrick: Adaptive Volatility Trend

- url: https://www.tradingview.com/script/UUiGurkN-Uptrick-Adaptive-Volatility-Trend/
- type: indicator
- pine_id: PUB;3eb1f2aea6114b9f8f79b49a47d1ae8e
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Uptrick: Adaptive Volatility Trend is a trend-following overlay built on an ATR trailing band whose width and baseline speed are both controlled by a single market regime score. Most ATR trail indicators use a fixed multiplier and a fixed baseline, so they are either too tight in choppy markets (frequent whipsaws) or too loose in clean trends (late exits and late entries). This script measures how directional price movement is and whether volatility is expanding, combines those two readings into one regime score between 0 and 1, and uses that score to decide how wide the trail should be and how fast its baseline should react. On top of the trend engine, it includes an optional take profit marking module with fixed ATR targets and an RSI exhaustion target, plus trend candles, a vertical gradient fill and alerts.

[b][i]Originality[/i][/b]
The individual building blocks are classic, public domain concepts: the ATR trailing band logic popularized by the Supertrend indicator, Perry Kaufman's Efficiency Ratio, a ratio of current ATR to its own average, an exponential moving average, and the RSI. What this script does differently is how these parts are tied together and why.

[list]
[*]The Efficiency Ratio was chosen because it directly measures whether price is travelling in a straight line or moving back and forth. Low efficiency means noise, which is exactly when a fixed trail gets whipsawed.
[*]The ATR expansion reading was chosen because a sudden rise in volatility relative to recent history is when a tight trail is most likely to be stopped out by a single large candle. Only expansion is counted; volatility below its average does not add to the score, so quiet markets do not widen the trail.
[*]These two readings are blended with user-set weights into one smoothed, clamped regime score. That single score then drives two things at once: the ATR multiplier (interpolated between a minimum and a maximum) and the length of the baseline EMA (interpolated between a fast and a slow factor).
[*]The result is that in efficient, calm trends the baseline speeds up and the trail tightens, while in noisy or expanding conditions the baseline slows down and the trail widens. A standard Supertrend only has a fixed multiplier around a fixed hl2 midpoint, so it cannot do either of these.
[*]The baseline is a custom EMA of hl2 whose smoothing constant is recalculated on every bar from the adaptive length, rather than a fixed length moving average.
[*]The RSI take profit module is included because trend-following trails exit late by design. The RSI exhaustion target gives an earlier reference point for partial profit taking within a trend, without changing the trend state itself. The static ATR targets are sized from the ATR at entry so they scale with the volatility present when the signal fired.
[/list]

[b][i]Features[/i][/b]
[list]
[*]Adaptive ATR trailing band that flips between a bullish lower trail and a bearish upper trail
[*]Kaufman Efficiency Ratio used to measure how directional or noisy recent price movement is
[*]Volatility regime reading based on current ATR divided by its average, counting expansion only
[*]Expansion reading compressed into a 0 to 1 range so extreme spikes cannot dominate the score
[*]Weighted regime score combining inefficiency and volatility expansion, smoothed and clamped between 0 and 1
[*]ATR multiplier that scales between a user-defined minimum and maximum based on the regime score
[*]Adaptive baseline EMA on hl2 whose length scales between a fast and a slow factor based on the regime score
[*]Ratcheting band memory so the active trail only moves in the direction of the trend until a flip occurs
[*]Trend flips confirmed only on closed bars, when price closes beyond the opposite band
[*]Buy and Sell labels on each trend flip, offset from the trail by an adjustable ATR distance
[*]Take profit module with four modes: Off, Static, Dynamic and Both
[*]Three static take profit levels placed at fixed ATR multiples from the entry close, using the ATR value at the signal bar
[*]Each static take profit is marked only once per trend and is checked from the bar after the signal onward
[*]Dynamic RSI take profit that arms when RSI reaches the exhaustion level and triggers when RSI crosses back out of it
[*]One dynamic take profit mark per trend
[*]Take profit hits shown as X markers placed above the high (long) or below the low (short) at an adjustable ATR distance
[*]Separate visibility toggles for static and dynamic take profit markers
[*]Optional display of the adaptive baseline
[*]Vertical gradient fill between the trail and price, strongest at the trail and fading toward price
[*]Trend candles colored by the current trend direction
[*]Adjustable trail width and transparency
[*]Fully customizable bullish, bearish, label text and take profit marker colors
[*]Data Window readouts for the adaptive ATR multiplier, trend efficiency, volatility ratio and adaptive regime score
[*]Six alert conditions: Buy, Sell, Static TP1, Static TP2, Static TP3 and Dynamic RSI TP
[*]Input length safeguards so every length input is treated as at least 1
[/list]

[b][i]Inputs[/i][/b]

[b]01 Color Scheme[/b]
[list]
[*]Bullish Color: color used for the bullish trail, candles, gradient and Buy label
[*]Bearish Color: color used for the bearish trail, candles, gradient and Sell label
[*]Buy Text: text color inside the Buy label
[*]Sell Text: text color inside the Sell label
[*]TP X Color: color of all take profit X markers
[/list]

[b]02 Adaptive Engine[/b]
[list]
[*]Efficiency Length: lookback for the Efficiency Ratio (default 12)
[*]Volatility Regime Length: length of the ATR average used for the volatility ratio (default 18)
[*]Adaptation Smoothing: EMA length used to smooth the volatility score and the final regime score (default 3)
[/list]

[b]03 Adaptive Trend[/b]
[list]
[*]ATR Length: ATR period used for band width, targets and offsets (default 10)
[*]Minimum ATR Multiplier: band width used when the regime score is 0 (default 1.4)
[*]Maximum ATR Multiplier: band width used when the regime score is 1 (default 3.0)
[*]Volatility Influence: weight of volatility expansion in the regime score (default 0.50)
[*]Efficiency Influence: weight of inefficiency in the regime score (default 0.85)
[/list]

[b]04 Adaptive Basis[/b]
[list]
[*]Basis Length: base length of the adaptive baseline EMA (default 8)
[*]Fast Regime Factor: length multiplier applied when the regime score is 0 (default 0.40)
[*]Slow Regime Factor: length multiplier applied when the regime score is 1 (default 1.35)
[/list]

[b]05 Signals[/b]
[list]
[*]Show Buy / Sell: toggles the trend flip labels
[*]Signal Trail Distance: ATR distance between the trail and the label (default 1.0)
[/list]

[b]06 Take Profits[/b]
[list]
[*]TP Mode: Off, Static, Dynamic or Both (default Static)
[*]TP1 ATR, TP2 ATR, TP3 ATR: ATR multiples from the entry close for the three static targets (defaults 1.0, 2.5, 3.0)
[*]TP X Distance: ATR distance of the X marker above the high or below the low (default 0.75)
[*]Dynamic RSI Length: RSI period for the dynamic target (default 14)
[*]Long Exhaustion: RSI level that arms the long dynamic target (default 75)
[*]Short Exhaustion: RSI level that arms the short dynamic target (default 25)
[*]Static TP Xs: shows or hides static take profit markers
[*]Dynamic TP Xs: shows or hides dynamic take profit markers
[/list]

[b]07 Display[/b]
[list]
[*]Show Adaptive Trail: toggles the trailing band
[*]Trail Width: line width of the trail
[*]Trail Transparency: transparency of the trail
[*]Show Adaptive Basis: toggles the adaptive baseline (off by default)
[*]Basis Transparency: transparency of the baseline
[*]Vertical Price Gradient: toggles the gradient fill between trail and price
[*]Gradient At Trail: transparency of the gradient at the trail edge
[*]Trend Candles: toggles trend-colored candles
[/list]

[b][i]How It Works[/i][/b]
[list]
[*]Trend efficiency is calculated as the absolute net change in close over the efficiency length, divided by the sum of absolute bar-to-bar changes over the same length. A value near 1 means price moved almost in a straight line; a value near 0 means most movement cancelled itself out.
[*]The volatility ratio is the current ATR divided by the simple moving average of ATR over the volatility regime length. Only the part above 1 is kept (expansion), it is compressed with x / (1 + x) so it stays between 0 and 1, then smoothed with a short EMA.
[*]The raw regime score is inefficiency (1 minus efficiency) multiplied by the efficiency influence, plus the volatility score multiplied by the volatility influence. It is smoothed with an EMA and clamped between 0 and 1.
[*]The ATR multiplier is interpolated linearly from the minimum to the maximum multiplier using the regime score.
[*]The baseline length is the basis length multiplied by a factor interpolated from the fast to the slow regime factor, rounded to a whole number. With default settings this ranges from roughly 3 to 11 bars. The baseline is an EMA of hl2 whose smoothing constant is recalculated from this length on every bar.
[*]Upper and lower bands are placed at the baseline plus and minus ATR times the adaptive multiplier. The bands use Supertrend-style memory: the lower band can only rise and the upper band can only fall until price closes through them.
[*]On a confirmed bar, if the trend is bearish and close is above the upper band, the trend flips bullish and a Buy label is printed. If the trend is bullish and close is below the lower band, the trend flips bearish and a Sell label is printed. The active trail is the lower band in a bullish trend and the upper band in a bearish trend.
[*]When a signal fires, the entry close and the ATR at that bar are stored. Static targets are placed at entry plus or minus ATR times TP1, TP2 and TP3. From the next bar onward, each target is marked once when the bar's high (long) or low (short) reaches it.
[*]For the dynamic target in a long trend, RSI must first reach the long exhaustion level, then an X is marked when RSI crosses back below it. Short trends use the mirror logic with the short exhaustion level. Only one dynamic target is marked per trend.
[*]All targets reset when the next opposite signal fires.
[/list]

[b][i]How to Use[/i][/b]
[list]
[*]Use the trail color and the trend candles as the primary read of trend direction. The trail doubles as a trailing reference level for stops.
[*]Buy and Sell labels mark confirmed flips. They appear once the bar closes, not intrabar.
[*]Open the Data Window to see the current regime score, multiplier, efficiency and volatility ratio. A rising regime score means the trail is widening and the baseline is slowing down, which usually happens in choppy or expanding conditions.
[*]Static targets are useful as fixed, volatility-scaled reference levels for scaling out of a position. The dynamic RSI target is useful as an earlier warning that momentum within the trend has reached an extreme and started to fade.
[*]If signals are too frequent on your market and timeframe, raise the minimum multiplier or the efficiency influence. If the trail feels too slow, lower the maximum multiplier or the slow regime factor.
[*]The trend candles are drawn over the chart's native candles. For the cleanest view, you can hide the chart's own candle bodies in the chart settings.
[*]Set alerts from the alert menu for trend flips and for each take profit event.
[*]Take profit X markers are visual references only. The indicator does not track positions or exits, and the trend continues until the next opposite signal.
[*]Like any trend-following tool, the trail lags by design and can produce losing flips in sideways markets.
[/list]

[b][i]Conclusion[/i][/b]
Uptrick: Adaptive Volatility Trend takes the familiar ATR trailing band and makes both its width and its baseline speed respond to one measurable regime score built from trend efficiency and volatility expansion. The aim is a trail that stays close to price during clean, orderly trends and gives price more room when conditions become noisy or volatile. Volatility-scaled static targets and an RSI exhaustion target round it out as reference points for managing a trend once it has been identified. All regime readings are exposed in the Data Window, so users can see exactly why the trail is behaving the way it is.

[quote][b][i]Disclaimer[/i][/b]
This script is provided for educational and informational purposes only and does not constitute financial advice. Trading involves substantial risk, and past behavior of any indicator does not guarantee future results. Always do your own research and use proper risk management before making any trading decisions.[/quote]

## Source Code

````pine
// This work is licensed under an Attribution-ShareAlike 4.0 International License (CC BY-SA 4.0)
// https://creativecommons.org/licenses/by-sa/4.0/
// © Uptrick

//@version=6

//    ██╗   ██╗██████╗ ████████╗██████╗ ██╗ ██████╗██╗  ██╗
//    ██║   ██║██╔══██╗╚══██╔══╝██╔══██╗██║██╔════╝██║ ██╔╝
//    ██║   ██║██████╔╝   ██║   ██████╔╝██║██║     █████╔╝
//    ██║   ██║██╔═══╝    ██║   ██╔══██╗██║██║     ██╔═██╗
//    ╚██████╔╝██║        ██║   ██║  ██║██║╚██████╗██║  ██╗
//     ╚═════╝ ╚═╝        ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝


indicator(
     "Uptrick: Adaptive Volatility Trend",
     shorttitle="Adaptive Vol Trend",
     overlay=true,
     max_labels_count=500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 · COLOR SCHEME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gColors = "01 · Color Scheme"

bullColor = input.color(
     #00FFE5,
     "Bullish Color",
     group=gColors
)

bearColor = input.color(
     #FF00B5,
     "Bearish Color",
     group=gColors
)

signalTextBull = input.color(
     #000000,
     "Buy Text",
     group=gColors
)

signalTextBear = input.color(
     #FFFFFF,
     "Sell Text",
     group=gColors
)

tpColor = input.color(
     #FFFFFF,
     "TP X Color",
     group=gColors
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 · ADAPTIVE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gEngine = "02 · Adaptive Engine"

efficiencyLength = input.int(
     12,
     "Efficiency Length",
     group=gEngine
)

volatilityLength = input.int(
     18,
     "Volatility Regime Length",
     group=gEngine
)

adaptSmooth = input.int(
     3,
     "Adaptation Smoothing",
     group=gEngine
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 · ADAPTIVE TREND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gTrend = "03 · Adaptive Trend"

atrLength = input.int(
     10,
     "ATR Length",
     group=gTrend
)

minATRMultiplier = input.float(
     1.4,
     "Minimum ATR Multiplier",
     step=0.1,
     group=gTrend
)

maxATRMultiplier = input.float(
     3.0,
     "Maximum ATR Multiplier",
     step=0.1,
     group=gTrend
)

volatilityInfluence = input.float(
     0.50,
     "Volatility Influence",
     step=0.05,
     group=gTrend
)

efficiencyInfluence = input.float(
     0.85,
     "Efficiency Influence",
     step=0.05,
     group=gTrend
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 · ADAPTIVE BASIS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gBasis = "04 · Adaptive Basis"

basisLength = input.int(
     8,
     "Basis Length",
     group=gBasis
)

basisFastFactor = input.float(
     0.40,
     "Fast Regime Factor",
     step=0.05,
     group=gBasis
)

basisSlowFactor = input.float(
     1.35,
     "Slow Regime Factor",
     step=0.05,
     group=gBasis
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 · SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gSignals = "05 · Signals"

showSignals = input.bool(
     true,
     "Show Buy / Sell",
     group=gSignals
)

signalATRDistance = input.float(
     1.0,
     "Signal Trail Distance",
     step=0.1,
     group=gSignals
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 · TAKE PROFITS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gTP = "06 · Take Profits"

tpMode = input.string(
     "Static",
     "TP Mode",
     options=[
         "Off",
         "Static",
         "Dynamic",
         "Both"
     ],
     group=gTP
)

staticTP1ATR = input.float(
     1.0,
     "TP1 ATR",
     inline="ST1",
     step=0.1,
     group=gTP
)

staticTP2ATR = input.float(
     2.5,
     "TP2 ATR",
     inline="ST2",
     step=0.1,
     group=gTP
)

staticTP3ATR = input.float(
     3.0,
     "TP3 ATR",
     inline="ST3",
     step=0.1,
     group=gTP
)

tpXDistanceATR = input.float(
     0.75,
     "TP X Distance",
     step=0.05,
     group=gTP,
     tooltip=
         "Long TP X = high + ATR distance.\n" +
         "Short TP X = low - ATR distance."
)

rsiLength = input.int(
     14,
     "Dynamic RSI Length",
     group=gTP
)

rsiUpper = input.float(
     75,
     "Long Exhaustion",
     inline="RSI",
     step=1,
     group=gTP
)

rsiLower = input.float(
     25,
     "Short Exhaustion",
     inline="RSI",
     step=1,
     group=gTP
)

showStaticTPXs = input.bool(
     true,
     "Static TP Xs",
     group=gTP
)

showDynamicTPXs = input.bool(
     true,
     "Dynamic TP Xs",
     group=gTP
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07 · DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gDisplay = "07 · Display"

showTrendLine = input.bool(
     true,
     "Show Adaptive Trail",
     group=gDisplay
)

trendLineWidth = input.int(
     1,
     "Trail Width",
     group=gDisplay
)

trendLineTransparency = input.int(
     35,
     "Trail Transparency",
     group=gDisplay
)

showBasis = input.bool(
     false,
     "Show Adaptive Basis",
     group=gDisplay
)

basisTransparency = input.int(
     80,
     "Basis Transparency",
     group=gDisplay
)

showGradient = input.bool(
     true,
     "Vertical Price Gradient",
     group=gDisplay
)

gradientTrailTransparency = input.int(
     70,
     "Gradient At Trail",
     group=gDisplay
)

showCandles = input.bool(
     true,
     "Trend Candles",
     group=gDisplay
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAFE LENGTHS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

safeEfficiencyLength =
     math.max(
         efficiencyLength,
         1
     )

safeVolatilityLength =
     math.max(
         volatilityLength,
         1
     )

safeAdaptSmooth =
     math.max(
         adaptSmooth,
         1
     )

safeATRLength =
     math.max(
         atrLength,
         1
     )

safeBasisLength =
     math.max(
         basisLength,
         1
     )

safeRSILength =
     math.max(
         rsiLength,
         1
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND EFFICIENCY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

directionalMove =
     math.abs(
         close -
         close[safeEfficiencyLength]
     )

totalMove =
     math.sum(
         math.abs(
             close -
             close[1]
         ),
         safeEfficiencyLength
     )

efficiency =
     totalMove != 0 ?
     directionalMove /
     totalMove :
     0.0

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VOLATILITY REGIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr =
     ta.atr(
         safeATRLength
     )

averageATR =
     ta.sma(
         atr,
         safeVolatilityLength
     )

volatilityRatio =
     averageATR != 0 ?
     atr /
     averageATR :
     1.0

volExpansion =
     math.max(
         volatilityRatio -
         1.0,
         0.0
     )

volScoreRaw =
     volExpansion /
     (
         1.0 +
         volExpansion
     )

volScore =
     ta.ema(
         volScoreRaw,
         safeAdaptSmooth
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE REGIME
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

inefficiency =
     1.0 -
     efficiency

rawRegimeScore =
     inefficiency *
     efficiencyInfluence +
     volScore *
     volatilityInfluence

regimeScore =
     ta.ema(
         rawRegimeScore,
         safeAdaptSmooth
     )

normalizedRegime =
     math.max(
         math.min(
             regimeScore,
             1.0
         ),
         0.0
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE MULTIPLIER
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

adaptiveMultiplier =
     minATRMultiplier +
     (
         maxATRMultiplier -
         minATRMultiplier
     ) *
     normalizedRegime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE BASIS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

adaptiveBasisFactor =
     basisFastFactor +
     (
         basisSlowFactor -
         basisFastFactor
     ) *
     normalizedRegime

adaptiveBasisLength =
     math.max(
         int(
             math.round(
                 safeBasisLength *
                 adaptiveBasisFactor
             )
         ),
         1
     )

basisAlpha =
     2.0 /
     (
         adaptiveBasisLength +
         1.0
     )

var float adaptiveBasis = na

adaptiveBasis :=
     na(adaptiveBasis[1]) ?
     hl2 :
     adaptiveBasis[1] +
     basisAlpha *
     (
         hl2 -
         adaptiveBasis[1]
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIC BANDS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upperBasic =
     adaptiveBasis +
     atr *
     adaptiveMultiplier

lowerBasic =
     adaptiveBasis -
     atr *
     adaptiveMultiplier

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPERTREND MEMORY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var float finalUpper = na
var float finalLower = na

finalUpper :=
     na(finalUpper[1]) ?
     upperBasic :
     upperBasic < finalUpper[1] or
     close[1] > finalUpper[1] ?
     upperBasic :
     finalUpper[1]

finalLower :=
     na(finalLower[1]) ?
     lowerBasic :
     lowerBasic > finalLower[1] or
     close[1] < finalLower[1] ?
     lowerBasic :
     finalLower[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int trend = na

if na(trend)

    trend :=
         close >= adaptiveBasis ?
         1 :
         -1

previousTrend =
     trend

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONFIRMED TREND FLIPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullFlip =
     barstate.isconfirmed and
     trend == -1 and
     close > finalUpper

bearFlip =
     barstate.isconfirmed and
     trend == 1 and
     close < finalLower

if barstate.isconfirmed

    if bullFlip
        trend := 1

    else if bearFlip
        trend := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buySignal =
     previousTrend == -1 and
     trend == 1

sellSignal =
     previousTrend == 1 and
     trend == -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE TRAIL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

activeTrendLine =
     trend == 1 ?
     finalLower :
     finalUpper

trendColor =
     trend == 1 ?
     bullColor :
     bearColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRADE STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int tradeDirection = 0
var int signalBar = na

var float entryPrice = na
var float entryATR = na

var float staticTP1 = na
var float staticTP2 = na
var float staticTP3 = na

var bool staticTP1Hit = false
var bool staticTP2Hit = false
var bool staticTP3Hit = false

var bool dynamicTPHit = false
var bool longRSIArmed = false
var bool shortRSIArmed = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW LONG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buySignal

    tradeDirection := 1
    signalBar := bar_index

    entryPrice := close
    entryATR := atr

    staticTP1 :=
         entryPrice +
         entryATR *
         staticTP1ATR

    staticTP2 :=
         entryPrice +
         entryATR *
         staticTP2ATR

    staticTP3 :=
         entryPrice +
         entryATR *
         staticTP3ATR

    staticTP1Hit := false
    staticTP2Hit := false
    staticTP3Hit := false

    dynamicTPHit := false
    longRSIArmed := false
    shortRSIArmed := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW SHORT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if sellSignal

    tradeDirection := -1
    signalBar := bar_index

    entryPrice := close
    entryATR := atr

    staticTP1 :=
         entryPrice -
         entryATR *
         staticTP1ATR

    staticTP2 :=
         entryPrice -
         entryATR *
         staticTP2ATR

    staticTP3 :=
         entryPrice -
         entryATR *
         staticTP3ATR

    staticTP1Hit := false
    staticTP2Hit := false
    staticTP3Hit := false

    dynamicTPHit := false
    longRSIArmed := false
    shortRSIArmed := false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATIC TPs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

staticEnabled =
     tpMode == "Static" or
     tpMode == "Both"

canCheckTP =
     barstate.isconfirmed and
     not na(signalBar) and
     bar_index > signalBar

longStaticTP1Hit =
     staticEnabled and
     canCheckTP and
     tradeDirection == 1 and
     not staticTP1Hit and
     high >= staticTP1

longStaticTP2Hit =
     staticEnabled and
     canCheckTP and
     tradeDirection == 1 and
     not staticTP2Hit and
     high >= staticTP2

longStaticTP3Hit =
     staticEnabled and
     canCheckTP and
     tradeDirection == 1 and
     not staticTP3Hit and
     high >= staticTP3

shortStaticTP1Hit =
     staticEnabled and
     canCheckTP and
     tradeDirection == -1 and
     not staticTP1Hit and
     low <= staticTP1

shortStaticTP2Hit =
     staticEnabled and
     canCheckTP and
     tradeDirection == -1 and
     not staticTP2Hit and
     low <= staticTP2

shortStaticTP3Hit =
     staticEnabled and
     canCheckTP and
     tradeDirection == -1 and
     not staticTP3Hit and
     low <= staticTP3

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP X POSITIONS
//
// LONG  = HIGH + 0.75 ATR
// SHORT = LOW  - 0.75 ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longTPX =
     high +
     atr *
     tpXDistanceATR

shortTPX =
     low -
     atr *
     tpXDistanceATR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STATIC TP X SERIES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

staticTP1X =
     longStaticTP1Hit ?
     longTPX :
     shortStaticTP1Hit ?
     shortTPX :
     na

staticTP2X =
     longStaticTP2Hit ?
     longTPX :
     shortStaticTP2Hit ?
     shortTPX :
     na

staticTP3X =
     longStaticTP3Hit ?
     longTPX :
     shortStaticTP3Hit ?
     shortTPX :
     na

plotchar(
     showStaticTPXs ?
     staticTP1X :
     na,
     "Static TP1",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)

plotchar(
     showStaticTPXs ?
     staticTP2X :
     na,
     "Static TP2",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)

plotchar(
     showStaticTPXs ?
     staticTP3X :
     na,
     "Static TP3",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LOCK STATIC TPs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if barstate.isconfirmed

    if longStaticTP1Hit or shortStaticTP1Hit
        staticTP1Hit := true

    if longStaticTP2Hit or shortStaticTP2Hit
        staticTP2Hit := true

    if longStaticTP3Hit or shortStaticTP3Hit
        staticTP3Hit := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC RSI TP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dynamicEnabled =
     tpMode == "Dynamic" or
     tpMode == "Both"

rsi =
     ta.rsi(
         close,
         safeRSILength
     )

if barstate.isconfirmed and
   dynamicEnabled and
   not dynamicTPHit

    if tradeDirection == 1 and
       rsi >= rsiUpper

        longRSIArmed := true

    if tradeDirection == -1 and
       rsi <= rsiLower

        shortRSIArmed := true

rsiCrossDown =
     ta.crossunder(
         rsi,
         rsiUpper
     )

rsiCrossUp =
     ta.crossover(
         rsi,
         rsiLower
     )

longDynamicTP =
     dynamicEnabled and
     canCheckTP and
     tradeDirection == 1 and
     longRSIArmed and
     not dynamicTPHit and
     rsiCrossDown

shortDynamicTP =
     dynamicEnabled and
     canCheckTP and
     tradeDirection == -1 and
     shortRSIArmed and
     not dynamicTPHit and
     rsiCrossUp
     
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DYNAMIC TP X
//
// SAME 0.75 ATR OFFSET
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

dynamicTPX =
     longDynamicTP ?
     longTPX :
     shortDynamicTP ?
     shortTPX :
     na

plotchar(
     showDynamicTPXs ?
     dynamicTPX :
     na,
     "Dynamic TP",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)

if barstate.isconfirmed and
   (
       longDynamicTP or
       shortDynamicTP
   )

    dynamicTPHit := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRAIL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pTrend = plot(
     showTrendLine ?
     activeTrendLine :
     na,
     "Adaptive Volatility Trail",
     color=color.new(
         trendColor,
         trendLineTransparency
     ),
     linewidth=trendLineWidth,
     style=plot.style_linebr
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OPTIONAL BASIS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     showBasis ?
     adaptiveBasis :
     na,
     "Adaptive Basis",
     color=color.new(
         trendColor,
         basisTransparency
     ),
     linewidth=1
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PRICE ANCHOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pPrice = plot(
     close,
     "Price Anchor",
     color=color.new(
         trendColor,
         100
     ),
     display=display.none
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VERTICAL GRADIENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gradientTop =
     math.max(
         close,
         activeTrendLine
     )

gradientBottom =
     math.min(
         close,
         activeTrendLine
     )

priceAboveTrail =
     close >= activeTrendLine

trailGradientColor =
     color.new(
         trendColor,
         gradientTrailTransparency
     )

priceGradientColor =
     color.new(
         trendColor,
         100
     )

gradientTopColor =
     priceAboveTrail ?
     priceGradientColor :
     trailGradientColor

gradientBottomColor =
     priceAboveTrail ?
     trailGradientColor :
     priceGradientColor

fill(
     pTrend,
     pPrice,
     gradientTop,
     gradientBottom,
     showGradient ?
     gradientTopColor :
     na,
     showGradient ?
     gradientBottomColor :
     na,
     title="Adaptive Price Gradient"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND CANDLES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotcandle(
     showCandles ?
     open :
     na,

     showCandles ?
     high :
     na,

     showCandles ?
     low :
     na,

     showCandles ?
     close :
     na,

     "Adaptive Trend Candles",

     color=trendColor,
     wickcolor=trendColor,
     bordercolor=trendColor
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL ANCHORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buySignalAnchor =
     finalLower -
     atr *
     signalATRDistance

sellSignalAnchor =
     finalUpper +
     atr *
     signalATRDistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSignals and buySignal

    label.new(
         bar_index,
         buySignalAnchor,
         "𝓑𝓾𝔂",
         yloc=yloc.price,
         style=label.style_label_up,
         color=bullColor,
         textcolor=signalTextBull,
         size=size.normal
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSignals and sellSignal

    label.new(
         bar_index,
         sellSignalAnchor,
         "𝓢𝓮𝓵𝓵",
         yloc=yloc.price,
         style=label.style_label_down,
         color=bearColor,
         textcolor=signalTextBear,
         size=size.normal
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     adaptiveMultiplier,
     "Adaptive ATR Multiplier",
     display=display.data_window
)

plot(
     efficiency,
     "Trend Efficiency",
     display=display.data_window
)

plot(
     volatilityRatio,
     "Volatility Ratio",
     display=display.data_window
)

plot(
     normalizedRegime,
     "Adaptive Regime Score",
     display=display.data_window
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buySignal,
     "Adaptive Volatility Buy",
     "Uptrick Adaptive Volatility Trend switched bullish on {{ticker}}"
)

alertcondition(
     sellSignal,
     "Adaptive Volatility Sell",
     "Uptrick Adaptive Volatility Trend switched bearish on {{ticker}}"
)

alertcondition(
     longStaticTP1Hit or shortStaticTP1Hit,
     "Static TP1",
     "Static TP1 reached on {{ticker}}"
)

alertcondition(
     longStaticTP2Hit or shortStaticTP2Hit,
     "Static TP2",
     "Static TP2 reached on {{ticker}}"
)

alertcondition(
     longStaticTP3Hit or shortStaticTP3Hit,
     "Static TP3",
     "Static TP3 reached on {{ticker}}"
)

alertcondition(
     longDynamicTP or shortDynamicTP,
     "Dynamic RSI TP",
     "Dynamic RSI target triggered on {{ticker}}"
)
````
