# Uptrick: Adaptive Trend Matrix

- url: https://www.tradingview.com/script/FQZBvcMe-Uptrick-Adaptive-Trend-Matrix/
- type: indicator
- pine_id: PUB;5af2f91d45a9468d9dd3dae1d7b4cd7c
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Uptrick Adaptive Trend Matrix is a trend-following overlay that combines a volatility-based ratcheting trail with a ten-factor confirmation score. The trail defines where the current trend would be considered broken, while the confirmation score decides whether that break is supported by enough independent market evidence to flip the trend and print a Buy or Sell signal. Once a signal prints, the script projects three ATR-based take-profit levels and marks the bar on which each level is reached. The aim is to give traders one clean view of the current trend direction, trend changes that are backed by broad agreement across different types of indicators, and objective profit-taking reference points.

[b][i]Originality[/i][/b]
Most trailing-stop trend tools flip direction the moment price closes through the trail. Most multi-indicator dashboards, on the other hand, display a score without tying it to any price structure. Adaptive Trend Matrix links the two. The trail is never allowed to flip on price alone. A trend change requires three conditions on the same confirmed bar:
[list]
[*]Price closes through the opposing trail.
[*]Price also closes on the new side of the smoothed trend basis.
[*]At least a user-defined number of the ten confirmations agree with the new direction.
[/list]
If price breaks the trail but the confirmation count is below the threshold, the trend stays unchanged and no signal is printed. In other words, the confluence score acts as a gate on the trail, not as a separate panel the trader has to interpret on their own.

The ten confirmations were selected so they measure different characteristics of the market instead of repeating the same information:
[list]
[*]Trend structure: EMA 12 versus EMA 34, and DMI direction filtered by a minimum ADX.
[*]Momentum: RSI, MACD, Stochastic, CCI and Rate of Change.
[*]Volume and participation: MFI, OBV relative to its own EMA, and price relative to VWAP.
[/list]
Because a signal needs agreement across these groups, a break that is supported only by short-term momentum, but not by structure or volume, may not reach the threshold and is then ignored. Several confirmations use neutral buffer zones (RSI and MFI must be above 52 or below 48, and the Stochastic must be above 45 or below 55) so that readings sitting near their midpoint do not count toward either side.

The trail is built from a double-smoothed EMA of hlc3 and a smoothed ATR. The bullish and bearish trails are both calculated on every bar and ratchet in their own direction. This means the opposing trail is always available as the break level for the next signal, even while the current trend is active.

[b][i]Features[/i][/b]
[list]
[*]Bullish trail that ratchets upward only and resets to the current basis-minus-ATR level when price closes below it.
[*]Bearish trail that ratchets downward only and resets to the current basis-plus-ATR level when price closes above it.
[*]Double-smoothed EMA basis on hlc3 used as the trend centerline and as an additional break condition.
[*]Smoothed ATR used for trail distance, signal placement, take-profit distances and marker offsets.
[*]Ten-factor confirmation matrix scored separately for the bullish and the bearish side, from 0 to 10.
[*]Adjustable confirmation threshold from 4 to 10.
[*]Minimum ADX filter that decides whether the DMI confirmation is allowed to count.
[*]Neutral buffer zones on RSI, MFI and Stochastic to avoid counting midpoint readings.
[*]Confirmation-gated trend state: trail color and candle color only change when a qualifying signal occurs.
[*]Buy and Sell labels evaluated on confirmed bar closes only.
[*]Strict signal alternation: a Buy can only follow a Sell and vice versa, with no repeated signals in the same direction.
[*]Signal labels placed at an adjustable ATR offset beyond the trail.
[*]Signal label tooltip showing how many of the ten confirmations were present on the signal bar.
[*]Three take-profit levels calculated from the signal bar's close and ATR.
[*]Take-profit levels locked at entry and reset only by the next opposite signal.
[*]X markers printed once per take-profit level on the first confirmed bar after the signal that reaches it.
[*]Adjustable offset that places TP X markers clear of the candles.
[*]Trend-colored candles.
[*]Vertical gradient between trail and price, strongest at the trail and fading toward price.
[*]Display trail clamped so it always stays at least one tick on the trend side of price.
[*]Bull and bear confirmation counts shown in the Data Window on every bar.
[*]Five alert conditions: Buy, Sell, TP1, TP2 and TP3.
[*]Fully adjustable colors, transparency and visibility for every visual element.
[/list]

[b][i]Inputs[/i][/b]
[b]Appearance[/b]
[list]
[*]Bullish Color (default #00FFE5): color for the bullish trail, candles, gradient and Buy labels.
[*]Bearish Color (default #FF00B5): color for the bearish trail, candles, gradient and Sell labels.
[*]Buy Text (default black): text color of Buy labels.
[*]Sell Text (default white): text color of Sell labels.
[*]TP X Color (default white): color of the take-profit X markers.
[/list]
[b]Trend Engine[/b]
[list]
[*]Trend Length (default 16): EMA length of the hlc3 basis. Lower values react faster, higher values produce longer trend regimes.
[*]Smoothing (default 3): additional EMA smoothing applied to both the basis and the ATR.
[*]ATR Length (default 10): ATR period that controls how quickly volatility adapts.
[*]Trail Distance (default 1.8): ATR multiplier for the distance between basis and trail. Lower values allow quicker trend switches, higher values produce smoother trends.
[/list]
[b]Signals[/b]
[list]
[*]Show Buy / Sell (default on): shows or hides the signal labels.
[*]Required Confirmations (default 6, range 4 to 10): minimum number of agreeing confirmations needed for a signal. 6 is balanced, 7 to 8 is stricter.
[*]Minimum ADX (default 15): minimum ADX value required for the DMI confirmation to count.
[*]Signal Trail Offset (default 0.5): ATR distance between the trail and the signal label. Buy labels sit below the trail, Sell labels above it.
[/list]
[b]Take Profits[/b]
[list]
[*]Show TP Xs (default on): shows or hides the take-profit markers.
[*]TP1 Distance (default 1.0): TP1 distance from entry in ATR.
[*]TP2 Distance (default 2.0): TP2 distance from entry in ATR.
[*]TP3 Distance (default 3.25): TP3 distance from entry in ATR.
[*]TP X Offset (default 2.0): ATR distance of the X marker above the high (longs) or below the low (shorts).
[/list]
[b]Display[/b]
[list]
[*]Vertical Gradient (default on): shows or hides the gradient between trail and price.
[*]Trend Candles (default on): shows or hides trend-colored candles.
[*]Gradient At Trail (default 72): gradient transparency at the trail. The gradient fades to fully transparent at price.
[*]Trail Transparency (default 30): transparency of the trail line.
[/list]

[b][i]How It Works[/i][/b]
[b]1. Basis and volatility[/b]
An EMA of hlc3 is calculated with the Trend Length, then smoothed again with the Smoothing length. ATR is calculated with the ATR Length and smoothed the same way.

[b]2. Trails[/b]
The bullish candidate level is the basis minus ATR multiplied by Trail Distance, and the bearish candidate level is the basis plus the same distance. The bullish trail keeps the highest candidate value over time and the bearish trail keeps the lowest. When price closes beyond a trail, that trail resets to the current candidate level.

[b]3. Confirmation matrix[/b]
On every bar each of the ten confirmations is checked for bullish and bearish conditions:
[list]
[*]EMA: EMA 12 above or below EMA 34.
[*]RSI (14): above 52 or below 48.
[*]MACD (12, 26, 9): MACD line above signal with a positive histogram, or below signal with a negative histogram.
[*]Stochastic (14, 3): %K above %D and above 45, or below %D and below 55.
[*]CCI (20, hlc3): above or below zero.
[*]DMI (14, 14): +DI above -DI, or -DI above +DI, with ADX at or above the minimum.
[*]ROC (10): above or below zero.
[*]MFI (14): above 52 or below 48.
[*]OBV: above or below its 14-period EMA.
[*]VWAP: close above or below the session VWAP.
[/list]
Each condition that is true adds one point to its side, giving a bullish score and a bearish score between 0 and 10.

[b]4. Signals[/b]
A Buy prints on a confirmed bar when the current trend is bearish, the close is above both the bearish trail and the basis, and the bullish score meets the Required Confirmations. A Sell prints under the mirrored conditions. A signal flips the trend state, which switches the active trail, candle color and gradient.

[b]5. Take profits[/b]
On each signal the close and ATR of that bar are stored, and three levels are calculated at the chosen ATR distances in the trade direction. From the next bar onward, each level is checked once on confirmed bars. When a level is reached, an X is printed on that bar. The X is placed at an ATR offset beyond the bar's high or low for visibility, so it marks the bar on which the level was reached, not the exact price of the level.

[b][i]How to Use[/i][/b]
[list]
[*]Read the trail and candle color as the current trend bias. The trend only changes on a printed signal.
[*]Treat Buy and Sell labels as confirmed trend changes. Hover over a label to see how many confirmations supported it.
[*]Use the opposing trail as a reference for where the current trend would be challenged.
[*]Use the TP X markers as reference points for scaling out or tightening risk. They do not track any open position after an opposite signal.
[*]Raise Required Confirmations or Trail Distance for fewer, more selective signals. Lower them for faster reactions.
[*]Check the Data Window to see how many confirmations each side currently has, even when no signal prints.
[*]Set alerts with the frequency Once Per Bar Close, since all signals and TP events are evaluated on confirmed bars.
[*]The OBV, MFI and VWAP confirmations rely on the chart's volume data. On symbols without volume data, these confirmations cannot contribute, so a lower Required Confirmations value may be needed.
[*]Use the script on standard candlestick or bar charts. Signals on Heikin Ashi, Renko, Kagi, Point and Figure or Range charts are based on synthetic prices and do not reflect real tradable prices.
[*]Signals and take-profit markers do not repaint once a bar has closed. No future data or plot offsets are used.
[/list]

[b][i]Conclusion[/i][/b]
Uptrick Adaptive Trend Matrix ties a volatility-adaptive trailing structure to a ten-factor confirmation score, so that trend changes require both a structural price break and broad agreement across trend, momentum and volume measures. Combined with fixed ATR-based take-profit reference levels, confirmation counts in the Data Window and alerts for every event, it gives traders a structured way to follow trends, judge the strength behind each signal and plan exits. All thresholds are adjustable, so the balance between responsiveness and selectivity can be tuned to the trader's market and timeframe.

[quote][b][i]Disclaimer[/i][/b]
This script is provided for educational and informational purposes only and does not constitute financial advice. Trading involves substantial risk, and past performance does not guarantee future results. Signals and take-profit levels are based on historical price and volume calculations and can fail in any market condition. Always do your own research, test thoroughly and use proper risk management before making trading decisions.[/quote]

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
     "Uptrick: Adaptive Trend Matrix",
     shorttitle="Adaptive Trend Matrix",
     overlay=true,
     max_labels_count=500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 · APPEARANCE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gStyle = "01 · Appearance"

bullColor = input.color(
     #00FFE5,
     "Bullish Color",
     group=gStyle,
     tooltip="Bullish trail, candles, gradient and Buy signals."
)

bearColor = input.color(
     #FF00B5,
     "Bearish Color",
     group=gStyle,
     tooltip="Bearish trail, candles, gradient and Sell signals."
)

signalTextBull = input.color(
     #000000,
     "Buy Text",
     group=gStyle
)

signalTextBear = input.color(
     #FFFFFF,
     "Sell Text",
     group=gStyle
)

tpColor = input.color(
     #FFFFFF,
     "TP X Color",
     group=gStyle,
     tooltip="Color used for take-profit X markers."
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 · TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gTrend = "02 · Trend Engine"

basisLength = input.int(
     16,
     "Trend Length",
     minval=2,
     group=gTrend,
     tooltip="Lower values react faster. Higher values produce smoother and longer trend regimes."
)

smoothLength = input.int(
     3,
     "Smoothing",
     minval=1,
     group=gTrend,
     tooltip="Additional smoothing applied to the trend basis and ATR."
)

atrLength = input.int(
     10,
     "ATR Length",
     minval=2,
     group=gTrend,
     tooltip="Controls how quickly volatility reacts."
)

atrMultiplier = input.float(
     1.8,
     "Trail Distance",
     minval=0.5,
     step=0.1,
     group=gTrend,
     tooltip="Lower values create quicker trend switches. Higher values produce smoother trends."
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 · SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gSignals = "03 · Signals"

showSignals = input.bool(
     true,
     "Show Buy / Sell",
     group=gSignals,
     tooltip="Show or hide Adaptive Trend Matrix Buy and Sell signals."
)

requiredConfirmations = input.int(
     6,
     "Required Confirmations",
     minval=4,
     maxval=10,
     group=gSignals,
     tooltip=
         "Number of trend confirmations required before a signal can trigger.\n" +
         "6 = balanced.\n" +
         "7–8 = stricter."
)

adxMinimum = input.float(
     15,
     "Minimum ADX",
     minval=0,
     step=1,
     group=gSignals,
     tooltip="Minimum ADX required for DMI to count as a valid confirmation."
)

signalTrailATR = input.float(
     0.5,
     "Signal Trail Offset",
     minval=0,
     step=0.05,
     group=gSignals,
     tooltip=
         "Buy = trail - ATR offset.\n" +
         "Sell = trail + ATR offset."
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 · TAKE PROFITS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gTP = "04 · Take Profits"

showTP = input.bool(
     true,
     "Show TP Xs",
     group=gTP
)

tp1ATR = input.float(
     1.0,
     "TP1 Distance",
     minval=0.1,
     step=0.1,
     group=gTP,
     tooltip="TP1 distance from entry measured in ATR."
)

tp2ATR = input.float(
     2.0,
     "TP2 Distance",
     minval=0.1,
     step=0.1,
     group=gTP,
     tooltip="TP2 distance from entry measured in ATR."
)

tp3ATR = input.float(
     3.25,
     "TP3 Distance",
     minval=0.1,
     step=0.1,
     group=gTP,
     tooltip="TP3 distance from entry measured in ATR."
)

tpXOffsetATR = input.float(
     2.0,
     "TP X Offset",
     minval=0,
     step=0.1,
     group=gTP,
     tooltip=
         "Long TP X = high + ATR offset.\n" +
         "Short TP X = low - ATR offset."
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 · DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gDisplay = "05 · Display"

showGradient = input.bool(
     true,
     "Vertical Gradient",
     group=gDisplay
)

showCandles = input.bool(
     true,
     "Trend Candles",
     group=gDisplay
)

gradientTransparency = input.int(
     72,
     "Gradient At Trail",
     minval=0,
     maxval=100,
     group=gDisplay,
     tooltip="Gradient opacity at the trail. It fades toward price."
)

trailTransparency = input.int(
     30,
     "Trail Transparency",
     minval=0,
     maxval=100,
     group=gDisplay
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BASIS + ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

basisRaw =
     ta.ema(
         hlc3,
         basisLength
     )

basis =
     ta.ema(
         basisRaw,
         smoothLength
     )

atrRaw =
     ta.atr(
         atrLength
     )

atr =
     ta.ema(
         atrRaw,
         smoothLength
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RATCHETING TRAILS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longCandidate =
     basis -
     atr *
     atrMultiplier

shortCandidate =
     basis +
     atr *
     atrMultiplier


var float bullTrail = na
var float bearTrail = na


bullTrail :=
     na(bullTrail[1]) ?
     longCandidate :
     math.max(
         longCandidate,
         bullTrail[1]
     )


bearTrail :=
     na(bearTrail[1]) ?
     shortCandidate :
     math.min(
         shortCandidate,
         bearTrail[1]
     )


if not na(bullTrail[1]) and
   close < bullTrail[1]

    bullTrail :=
         longCandidate


if not na(bearTrail[1]) and
   close > bearTrail[1]

    bearTrail :=
         shortCandidate


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 · EMA STRUCTURE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaFast =
     ta.ema(
         close,
         12
     )

emaSlow =
     ta.ema(
         close,
         34
     )

emaBull =
     emaFast >
     emaSlow

emaBear =
     emaFast <
     emaSlow


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 · RSI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

rsi =
     ta.rsi(
         close,
         14
     )

rsiBull =
     rsi >
     52

rsiBear =
     rsi <
     48


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 · MACD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[macdLine, macdSignal, macdHist] =
     ta.macd(
         close,
         12,
         26,
         9
     )

macdBull =
     macdLine >
     macdSignal and
     macdHist >
     0

macdBear =
     macdLine <
     macdSignal and
     macdHist <
     0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 · STOCHASTIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

stochK =
     ta.stoch(
         close,
         high,
         low,
         14
     )

stochD =
     ta.sma(
         stochK,
         3
     )

stochBull =
     stochK >
     stochD and
     stochK >
     45

stochBear =
     stochK <
     stochD and
     stochK <
     55


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 · CCI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cci =
     ta.cci(
         hlc3,
         20
     )

cciBull =
     cci >
     0

cciBear =
     cci <
     0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 · DMI / ADX
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[plusDI, minusDI, adx] =
     ta.dmi(
         14,
         14
     )

dmiBull =
     plusDI >
     minusDI and
     adx >=
     adxMinimum

dmiBear =
     minusDI >
     plusDI and
     adx >=
     adxMinimum


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07 · ROC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

roc =
     ta.roc(
         close,
         10
     )

rocBull =
     roc >
     0

rocBear =
     roc <
     0


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 08 · MFI
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mfi =
     ta.mfi(
         hlc3,
         14
     )

mfiBull =
     mfi >
     52

mfiBear =
     mfi <
     48


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09 · OBV
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

obv =
     ta.cum(
         close > close[1] ?
         volume :
         close < close[1] ?
         -volume :
         0
     )

obvEMA =
     ta.ema(
         obv,
         14
     )

obvBull =
     obv >
     obvEMA

obvBear =
     obv <
     obvEMA


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10 · VWAP
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

vwapValue =
     ta.vwap(
         hlc3
     )

vwapBull =
     close >
     vwapValue

vwapBear =
     close <
     vwapValue


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE TREND MATRIX SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullScore =
     (emaBull ? 1 : 0) +
     (rsiBull ? 1 : 0) +
     (macdBull ? 1 : 0) +
     (stochBull ? 1 : 0) +
     (cciBull ? 1 : 0) +
     (dmiBull ? 1 : 0) +
     (rocBull ? 1 : 0) +
     (mfiBull ? 1 : 0) +
     (obvBull ? 1 : 0) +
     (vwapBull ? 1 : 0)


bearScore =
     (emaBear ? 1 : 0) +
     (rsiBear ? 1 : 0) +
     (macdBear ? 1 : 0) +
     (stochBear ? 1 : 0) +
     (cciBear ? 1 : 0) +
     (dmiBear ? 1 : 0) +
     (rocBear ? 1 : 0) +
     (mfiBear ? 1 : 0) +
     (obvBear ? 1 : 0) +
     (vwapBear ? 1 : 0)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int trend = 0


if trend == 0

    trend :=
         close >= basis ?
         1 :
         -1


bullBreak =
     close >
     bearTrail and
     close >
     basis


bearBreak =
     close <
     bullTrail and
     close <
     basis


rawBuy =
     barstate.isconfirmed and
     trend == -1 and
     bullBreak and
     bullScore >= requiredConfirmations


rawSell =
     barstate.isconfirmed and
     trend == 1 and
     bearBreak and
     bearScore >= requiredConfirmations


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STRICT NO PYRAMIDING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int signalDirection = 0


buySignal =
     rawBuy and
     signalDirection != 1


sellSignal =
     rawSell and
     signalDirection != -1


if buySignal

    trend := 1
    signalDirection := 1


else if sellSignal

    trend := -1
    signalDirection := -1


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ACTIVE MATRIX TRAIL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

activeTrail =
     trend == 1 ?
     bullTrail :
     bearTrail


displayTrail =
     trend == 1 ?
     math.min(
         activeTrail,
         close - syminfo.mintick
     ) :
     math.max(
         activeTrail,
         close + syminfo.mintick
     )


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

var float tp1 = na
var float tp2 = na
var float tp3 = na

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW LONG
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if buySignal

    tradeDirection := 1
    signalBar := bar_index

    entryPrice := close
    entryATR := atr

    tp1 :=
         entryPrice +
         entryATR *
         tp1ATR

    tp2 :=
         entryPrice +
         entryATR *
         tp2ATR

    tp3 :=
         entryPrice +
         entryATR *
         tp3ATR

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// NEW SHORT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if sellSignal

    tradeDirection := -1
    signalBar := bar_index

    entryPrice := close
    entryATR := atr

    tp1 :=
         entryPrice -
         entryATR *
         tp1ATR

    tp2 :=
         entryPrice -
         entryATR *
         tp2ATR

    tp3 :=
         entryPrice -
         entryATR *
         tp3ATR

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TAKE-PROFIT DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

canCheckTP =
     barstate.isconfirmed and
     not na(signalBar) and
     bar_index >
     signalBar


longTP1 =
     canCheckTP and
     tradeDirection == 1 and
     not tp1Hit and
     high >= tp1


longTP2 =
     canCheckTP and
     tradeDirection == 1 and
     not tp2Hit and
     high >= tp2


longTP3 =
     canCheckTP and
     tradeDirection == 1 and
     not tp3Hit and
     high >= tp3


shortTP1 =
     canCheckTP and
     tradeDirection == -1 and
     not tp1Hit and
     low <= tp1


shortTP2 =
     canCheckTP and
     tradeDirection == -1 and
     not tp2Hit and
     low <= tp2


shortTP3 =
     canCheckTP and
     tradeDirection == -1 and
     not tp3Hit and
     low <= tp3


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP X POSITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longTPX =
     high +
     atr *
     tpXOffsetATR


shortTPX =
     low -
     atr *
     tpXOffsetATR


tp1X =
     longTP1 ?
     longTPX :
     shortTP1 ?
     shortTPX :
     na


tp2X =
     longTP2 ?
     longTPX :
     shortTP2 ?
     shortTPX :
     na


tp3X =
     longTP3 ?
     longTPX :
     shortTP3 ?
     shortTPX :
     na


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP Xs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotchar(
     showTP ?
     tp1X :
     na,
     "Adaptive Trend Matrix TP1",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)


plotchar(
     showTP ?
     tp2X :
     na,
     "Adaptive Trend Matrix TP2",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)


plotchar(
     showTP ?
     tp3X :
     na,
     "Adaptive Trend Matrix TP3",
     char="X",
     location=location.absolute,
     color=tpColor,
     size=size.tiny
)


if barstate.isconfirmed

    if longTP1 or shortTP1
        tp1Hit := true

    if longTP2 or shortTP2
        tp2Hit := true

    if longTP3 or shortTP3
        tp3Hit := true


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE TREND MATRIX TRAIL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pTrend =
     plot(
         displayTrail,
         "Adaptive Trend Matrix Trail",
         color=color.new(
             trendColor,
             trailTransparency
         ),
         linewidth=1,
         style=plot.style_linebr
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INVISIBLE PRICE ANCHOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pPrice =
     plot(
         close,
         "Adaptive Trend Matrix Price Anchor",
         color=color.new(
             trendColor,
             100
         ),
         display=display.none
     )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE TREND MATRIX GRADIENT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gradientTop =
     math.max(
         close,
         displayTrail
     )


gradientBottom =
     math.min(
         close,
         displayTrail
     )


priceAboveTrail =
     close >=
     displayTrail


trailGradientColor =
     color.new(
         trendColor,
         gradientTransparency
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
     title="Adaptive Trend Matrix Gradient"
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ADAPTIVE TREND MATRIX CANDLES
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

     "Adaptive Trend Matrix Candles",

     color=trendColor,
     wickcolor=trendColor,
     bordercolor=trendColor
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL ANCHORS
//
// BUY  = TRAIL - 0.5 ATR
// SELL = TRAIL + 0.5 ATR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

buyAnchor =
     displayTrail -
     atr *
     signalTrailATR


sellAnchor =
     displayTrail +
     atr *
     signalTrailATR


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BUY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSignals and
   buySignal

    label.new(
         bar_index,
         buyAnchor,
         "𝓑𝓾𝔂",
         yloc=yloc.price,
         style=label.style_label_up,
         color=bullColor,
         textcolor=signalTextBull,
         size=size.normal,
         tooltip=
             "Adaptive Trend Matrix Buy\n\n" +
             str.tostring(
                 bullScore
             ) +
             "/10 confirmations"
    )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SELL
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSignals and
   sellSignal

    label.new(
         bar_index,
         sellAnchor,
         "𝓢𝓮𝓵𝓵",
         yloc=yloc.price,
         style=label.style_label_down,
         color=bearColor,
         textcolor=signalTextBear,
         size=size.normal,
         tooltip=
             "Adaptive Trend Matrix Sell\n\n" +
             str.tostring(
                 bearScore
             ) +
             "/10 confirmations"
    )


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DATA WINDOW
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     bullScore,
     "Adaptive Trend Matrix Bull Confirmations",
     display=display.data_window
)

plot(
     bearScore,
     "Adaptive Trend Matrix Bear Confirmations",
     display=display.data_window
)


//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buySignal,
     "Adaptive Trend Matrix Buy",
     "Uptrick Adaptive Trend Matrix Buy on {{ticker}}"
)

alertcondition(
     sellSignal,
     "Adaptive Trend Matrix Sell",
     "Uptrick Adaptive Trend Matrix Sell on {{ticker}}"
)

alertcondition(
     longTP1 or shortTP1,
     "Adaptive Trend Matrix TP1",
     "Uptrick Adaptive Trend Matrix TP1 reached on {{ticker}}"
)

alertcondition(
     longTP2 or shortTP2,
     "Adaptive Trend Matrix TP2",
     "Uptrick Adaptive Trend Matrix TP2 reached on {{ticker}}"
)

alertcondition(
     longTP3 or shortTP3,
     "Adaptive Trend Matrix TP3",
     "Uptrick Adaptive Trend Matrix TP3 reached on {{ticker}}"
)
````
