<!-- tradingview-pine-id: PUB;39fa133d7f7c47a3a38bc8e3bf31087a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Uptrick: Band Flow

Source: https://www.tradingview.com/script/QqSFhZiX-Uptrick-Band-Flow/

## Description

Introduction
Uptrick: Band Flow is a trend overlay built from a smoothed moving-average baseline and ATR bands. The trend only changes when a bar closes outside the opposite band, so the trend color holds while price moves inside the envelope. When the trend changes, the script prints one Up or Down label and tracks five ATR-based target levels from the entry close.

Originality
The building blocks are standard: a weighted moving average, an EMA smoothing pass and ATR. What it adds is how they are assembled and why each piece is there:

[*]WMA baseline: weights recent closes more heavily than a simple average, so the center line reacts sooner at the same length.
[*]EMA smoothing pass: reduces bar-to-bar noise in the baseline so the band center does not jitter.
[*]ATR band width: scales the envelope to current volatility instead of a fixed price distance. Separate upper and lower multipliers allow an asymmetric envelope.
[*]Trend state with memory: price inside the bands keeps the previous trend, and only a close beyond the opposite band flips it. This replaces a plain baseline cross, so touching the center line alone does not change the trend.
[*]Single-position signal engine: a new label is only issued when direction changes, so repeated breakouts in the same direction do not stack signals.
[*]Entry-frozen ATR ladder: ATR is captured on the signal bar, so the five target levels stay fixed instead of moving with volatility after entry.
[*]Selectable signal anchor: label placement is separated from signal logic, so labels can sit on the trail edge or beyond the candle without changing when signals occur.

The parts form one calculation chain rather than several unrelated indicators merged together: the baseline feeds the bands, the bands define the trend state, the trend state defines the signals, and the signals define the entry and target levels.

Features

[*]Smoothed baseline: weighted moving average of close with an optional EMA smoothing pass
[*]ATR is floored at the symbol's minimum tick so band width never collapses to zero
[*]Upper and lower ATR bands with independent multipliers
[*]Trend state with memory: a close that crosses above the upper band turns the trend bullish, a close that crosses below the lower band turns it bearish, and price inside the bands keeps the previous state
[*]Trend changes are evaluated on confirmed bar closes only
[*]Three overlay modes: Center, Trail and Bands
[*]Center mode: baseline line in the trend color with a gradient fill between the baseline and price
[*]Trail mode: one-sided trail, lower trail in an uptrend and upper trail in a downtrend, with a gradient between the inner edge and an outer edge expanded by extra ATR
[*]Bands mode: full upper and lower envelope with a gradient that is strongest near the baseline
[*]Trend candles: candle body, border and wick colored by trend state (cyan for bullish, magenta for bearish)
[*]Up and Down labels, one per direction change, no pyramiding
[*]Two signal anchor modes: Bands and ATR
[*]Five ATR take-profit levels measured from the entry close, each marked with a small cross when reached
[*]Each take-profit level marks once per signal, and all levels reset on the next signal
[*]Dashboard in the top right corner, two columns by six rows: script name and trend state, trend direction, overlay mode, signal anchor mode, entry price, take-profit progress shown as five dots
[*]Seven alert conditions: Up, Down, TP1, TP2, TP3, TP4 and TP5
[*]Display toggles for signals, trend candles, dashboard and take-profit markers
[*]Written in Pine Script v6 using only the chart's own data, with no request.security calls

Inputs 

Trend Engine (group 01)

[*]Trend Length (default 30): length of the weighted moving average baseline
[*]Trend Smoothing (default 4): EMA length applied to the baseline, set to 1 to switch the smoothing off
[*]Band ATR Length (default 14): ATR period used for band width and for the take-profit distances
[*]Upper Band Multiplier (default 1.50): ATR multiple added above the baseline
[*]Lower Band Multiplier (default 1.50): ATR multiple subtracted below the baseline

Overlay (group 02)

[*]Overlay Mode (default Bands): Center, Trail or Bands
[*]Trail Outer Expansion (default 0.85): extra ATR added to the outer trail edge. Also moves the labels when Signal Anchor is set to Bands
[*]Trail Smoothing (default 5): EMA length applied to the baseline and ATR used for the outer trail edge, set to 1 to switch off. Also moves the labels when Signal Anchor is set to Bands

Signal Anchor (group 03)

[*]Signal Anchor (default Bands): Bands places labels on the outer trail edge (below price for Up, above price for Down). ATR places them beyond the candle low or high. This changes label position only, not when signals occur
[*]Signal ATR Length (default 14): ATR period used for ATR-anchored labels
[*]Signal ATR Distance (default 0.80): ATR multiple between the candle low or high and the label

ATR Take Profits (group 04)

[*]Show ATR Take Profits (default on): switches take-profit markers and take-profit alerts on or off
[*]TP1 ATR, TP2 ATR, TP3 ATR, TP4 ATR, TP5 ATR (defaults 1.0, 2.0, 3.0, 4.0, 5.0): ATR multiple for each target level, measured from the entry close

Display (group 05)

[*]Show Signals (default on): Up and Down labels
[*]Trend Candles (default on): trend-colored candles
[*]Dashboard (default on): dashboard table

How It Works
Baseline: a weighted moving average of close over Trend Length, then an EMA of that average over Trend Smoothing.

Bands: upper band is the baseline plus ATR times the Upper Band Multiplier. Lower band is the baseline minus ATR times the Lower Band Multiplier.

Trend state: bullish when a bar closes above the upper band after the previous bar closed at or below the upper band. Bearish is the mirror case below the lower band. While price stays inside the bands, the previous state is kept.

Signals: an Up label appears on a bullish break when the script is not already long. A Down label appears on a bearish break when the script is not already short. The close of that bar becomes the entry price and the ATR of that bar is stored.

Targets: each level is the entry price plus (long) or minus (short) the stored ATR times that level's multiplier. A level is marked when a bar's high (long) or low (short) reaches it. The position stays tracked until the opposite signal.

Trail: in an uptrend the inner edge is the lower band, and the outer edge is the smoothed baseline minus the smoothed ATR times (Lower Band Multiplier plus Trail Outer Expansion). In a downtrend the trail is mirrored above price.

How to Use

[*]Use standard candlestick or bar charts. Heikin Ashi, Renko, Kagi, Point and Figure and Range charts do not show real traded prices, so signals and targets on them would not be realistic
[*]Read the trend from the color: cyan is bullish, magenta is bearish. The color only changes when a close breaks the opposite band
[*]Treat an Up or Down label as confirmation that a close has left the envelope, not as an early warning
[*]Tune the band multipliers to set how far price must travel from the baseline before the trend flips: smaller multipliers generally flip sooner and more often, larger multipliers generally flip later and less often. Trend Length changes how closely the baseline follows price, which moves where the bands sit, so test length changes on your own markets rather than assuming a direction
[*]Pick the overlay mode you prefer: Center for a minimal view, Trail for a one-sided trail, Bands for the full envelope
[*]Use the ATR targets as reference distances from entry. They are not orders or predictions
[*]For alerts, open the alert dialog, select Band Flow and choose a condition. Up and Down conditions are only true on a bar close. Take-profit conditions can become true while a bar is still forming, so choose the alert frequency accordingly

Conclusion
Band Flow combines a smoothed baseline, ATR bands, a trend state that only flips on a full breakout, a single-position signal and a fixed ATR target ladder in one overlay. It is a tool for reading trend state and measuring ATR distances from a breakout, not a complete trading system. Test the settings on the markets and timeframes you trade and combine it with your own analysis and risk management.

Disclaimer
This script is for educational and informational purposes only and is not financial advice. Trading involves risk, including the loss of capital. Past behavior of any indicator does not guarantee future results. Always do your own research and use your own risk management.

---

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
     "Uptrick: Band Flow",
     shorttitle="Band Flow",
     overlay=true,
     max_labels_count=500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01. TREND ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gTrend = "01. Trend Engine"

length = input.int(
     30,
     "Trend Length",
     minval=2,
     group=gTrend
)

smooth = input.int(
     4,
     "Trend Smoothing",
     minval=1,
     group=gTrend
)

atrLength = input.int(
     14,
     "Band ATR Length",
     minval=1,
     group=gTrend
)

upperMult = input.float(
     1.50,
     "Upper Band Multiplier",
     minval=0.10,
     step=0.05,
     group=gTrend
)

lowerMult = input.float(
     1.50,
     "Lower Band Multiplier",
     minval=0.10,
     step=0.05,
     group=gTrend
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02. OVERLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gOverlay = "02. Overlay"

overlayMode = input.string(
     "Bands",
     "Overlay Mode",
     options=["Center", "Trail", "Bands"],
     group=gOverlay
)

trailOuterATR = input.float(
     0.85,
     "Trail Outer Expansion",
     minval=0.10,
     step=0.05,
     group=gOverlay
)

trailSmooth = input.int(
     5,
     "Trail Smoothing",
     minval=1,
     group=gOverlay
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03. SIGNAL ANCHOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gSignals = "03. Signal Anchor"

signalAnchorMode = input.string(
     "Bands",
     "Signal Anchor",
     options=["Bands", "ATR"],
     group=gSignals,
     tooltip="Bands anchors signals to the outer trend band. ATR anchors them beyond the candle high/low."
)

signalATRLength = input.int(
     14,
     "Signal ATR Length",
     minval=1,
     group=gSignals
)

signalATRMult = input.float(
     0.80,
     "Signal ATR Distance",
     minval=0.05,
     step=0.05,
     group=gSignals
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04. ATR TAKE PROFITS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gTP = "04. ATR Take Profits"

showATRTP = input.bool(
     true,
     "Show ATR Take Profits",
     group=gTP
)

tp1Mult = input.float(
     1.0,
     "TP1 ATR",
     minval=0.1,
     step=0.25,
     group=gTP
)

tp2Mult = input.float(
     2.0,
     "TP2 ATR",
     minval=0.1,
     step=0.25,
     group=gTP
)

tp3Mult = input.float(
     3.0,
     "TP3 ATR",
     minval=0.1,
     step=0.25,
     group=gTP
)

tp4Mult = input.float(
     4.0,
     "TP4 ATR",
     minval=0.1,
     step=0.25,
     group=gTP
)

tp5Mult = input.float(
     5.0,
     "TP5 ATR",
     minval=0.1,
     step=0.25,
     group=gTP
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05. DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

gDisplay = "05. Display"

showSignals = input.bool(
     true,
     "Show Signals",
     group=gDisplay
)

showCandles = input.bool(
     true,
     "Trend Candles",
     group=gDisplay
)

showTable = input.bool(
     true,
     "Dashboard",
     group=gDisplay
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullColor = #00FFE5
bearColor = #FF00B5

black = #000000
white = #FFFFFF

dimWhite = color.new(white, 45)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND BASELINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

baseWMA = ta.wma(
     close,
     length
)

basis =
     smooth > 1 ?
     ta.ema(
          baseWMA,
          smooth
     ) :
     baseWMA

bandATR = ta.atr(
     atrLength
)

safeATR = math.max(
     bandATR,
     syminfo.mintick
)

upperBand =
     basis +
     safeATR * upperMult

lowerBand =
     basis -
     safeATR * lowerMult

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TREND STATE
//
// Above upper band = bullish
// Below lower band = bearish
// Inside bands = retain previous trend
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int trend = 0

bullBreak =
     barstate.isconfirmed and
     close > upperBand and
     close[1] <= upperBand[1]

bearBreak =
     barstate.isconfirmed and
     close < lowerBand and
     close[1] >= lowerBand[1]

if bullBreak
    trend := 1

else if bearBreak
    trend := -1

if trend == 0
    trend :=
         close >= basis ?
         1 :
         -1

bullish =
     trend == 1

bearish =
     trend == -1

trendColor =
     bullish ?
     bullColor :
     bearColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TRAIL GEOMETRY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

smoothTrailBasis =
     trailSmooth > 1 ?
     ta.ema(
          basis,
          trailSmooth
     ) :
     basis

smoothTrailATR =
     trailSmooth > 1 ?
     ta.ema(
          safeATR,
          trailSmooth
     ) :
     safeATR

trailInner =
     bullish ?
     basis - safeATR * lowerMult :
     basis + safeATR * upperMult

trailOuter =
     bullish ?
     smoothTrailBasis -
     smoothTrailATR *
     (lowerMult + trailOuterATR) :
     smoothTrailBasis +
     smoothTrailATR *
     (upperMult + trailOuterATR)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL ANCHOR ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Separate ATR purely for signal positioning.

signalATR = ta.atr(
     signalATRLength
)

safeSignalATR = math.max(
     signalATR,
     syminfo.mintick
)

// Band anchors.

bullBandAnchor =
     smoothTrailBasis -
     smoothTrailATR *
     (lowerMult + trailOuterATR)

bearBandAnchor =
     smoothTrailBasis +
     smoothTrailATR *
     (upperMult + trailOuterATR)

// ATR anchors based on candle low/high.

bullATRAnchor =
     low -
     safeSignalATR *
     signalATRMult

bearATRAnchor =
     high +
     safeSignalATR *
     signalATRMult

// Select anchor mode.

bullSignalAnchor =
     signalAnchorMode == "Bands" ?
     bullBandAnchor :
     bullATRAnchor

bearSignalAnchor =
     signalAnchorMode == "Bands" ?
     bearBandAnchor :
     bearATRAnchor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SINGLE TRADE ENGINE
// NO PYRAMIDING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int tradeSide = 0

var float entryPrice = na
var float entryATR = na

newLong =
     bullBreak and
     tradeSide != 1

newShort =
     bearBreak and
     tradeSide != -1

if newLong
    tradeSide := 1
    entryPrice := close
    entryATR := safeATR

if newShort
    tradeSide := -1
    entryPrice := close
    entryATR := safeATR

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR TAKE PROFIT LEVELS
// INTERNAL ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

direction =
     tradeSide == 1 ?
     1.0 :
     -1.0

tp1 =
     not na(entryPrice) ?
     entryPrice +
     entryATR *
     tp1Mult *
     direction :
     na

tp2 =
     not na(entryPrice) ?
     entryPrice +
     entryATR *
     tp2Mult *
     direction :
     na

tp3 =
     not na(entryPrice) ?
     entryPrice +
     entryATR *
     tp3Mult *
     direction :
     na

tp4 =
     not na(entryPrice) ?
     entryPrice +
     entryATR *
     tp4Mult *
     direction :
     na

tp5 =
     not na(entryPrice) ?
     entryPrice +
     entryATR *
     tp5Mult *
     direction :
     na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP STATE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool tp4Hit = false
var bool tp5Hit = false

if newLong or newShort
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp4Hit := false
    tp5Hit := false

f_targetHit(_level) =>
    tradeSide == 1 ?
     high >= _level :
     low <= _level

newTP1 =
     showATRTP and
     not tp1Hit and
     not na(tp1) and
     f_targetHit(tp1)

newTP2 =
     showATRTP and
     not tp2Hit and
     not na(tp2) and
     f_targetHit(tp2)

newTP3 =
     showATRTP and
     not tp3Hit and
     not na(tp3) and
     f_targetHit(tp3)

newTP4 =
     showATRTP and
     not tp4Hit and
     not na(tp4) and
     f_targetHit(tp4)

newTP5 =
     showATRTP and
     not tp5Hit and
     not na(tp5) and
     f_targetHit(tp5)

if newTP1
    tp1Hit := true

if newTP2
    tp2Hit := true

if newTP3
    tp3Hit := true

if newTP4
    tp4Hit := true

if newTP5
    tp5Hit := true

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OVERLAY 1
// CENTER
//
// Gradient only between center line and price.
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showCenter =
     overlayMode == "Center"

pCenter = plot(
     showCenter ?
     basis :
     na,
     "Center Line",
     color=trendColor,
     linewidth=3
)

pCenterPrice = plot(
     showCenter ?
     close :
     na,
     "Center Price",
     color=color.new(
          trendColor,
          100
     ),
     display=display.none
)

fill(
     pCenter,
     pCenterPrice,
     basis,
     close,
     color.new(
          trendColor,
          58
     ),
     color.new(
          trendColor,
          95
     ),
     title="Center Gradient"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OVERLAY 2
// TRAIL
//
// Bull = lower trail only
// Bear = upper trail only
//
// Outer edge = stronger
// Inner edge = softer
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showTrail =
     overlayMode == "Trail"

pTrailInner = plot(
     showTrail ?
     trailInner :
     na,
     "Trail Inner",
     color=color.new(
          trendColor,
          100
     ),
     linewidth=1
)

pTrailOuter = plot(
     showTrail ?
     trailOuter :
     na,
     "Trail Outer",
     color=color.new(
          trendColor,
          28
     ),
     linewidth=2
)

trailTop =
     bullish ?
     trailInner :
     trailOuter

trailBottom =
     bullish ?
     trailOuter :
     trailInner

trailTopColor =
     bullish ?
     color.new(
          trendColor,
          100
     ) :
     color.new(
          trendColor,
          80
     )

trailBottomColor =
     bullish ?
     color.new(
          trendColor,
          80
     ) :
     color.new(
          trendColor,
          100
     )

fill(
     pTrailInner,
     pTrailOuter,
     trailTop,
     trailBottom,
     trailTopColor,
     trailBottomColor,
     title="Trail Gradient"
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// OVERLAY 3
// BANDS
//
// Full upper/lower envelope
// Gradient strongest near center
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

showBands =
     overlayMode == "Bands"

pBandBasis = plot(
     showBands ?
     basis :
     na,
     "Band Center",
     color=trendColor,
     linewidth=3
)

pUpper = plot(
     showBands ?
     upperBand :
     na,
     "Upper Band",
     color=color.new(
          trendColor,
          40
     ),
     linewidth=1
)

pLower = plot(
     showBands ?
     lowerBand :
     na,
     "Lower Band",
     color=color.new(
          trendColor,
          40
     ),
     linewidth=1
)

fill(
     pUpper,
     pBandBasis,
     upperBand,
     basis,
     color.new(
          trendColor,
          94
     ),
     color.new(
          trendColor,
          62
     ),
     title="Upper Band Gradient"
)

fill(
     pBandBasis,
     pLower,
     basis,
     lowerBand,
     color.new(
          trendColor,
          62
     ),
     color.new(
          trendColor,
          94
     ),
     title="Lower Band Gradient"
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
     "Trend Candles",
     color=trendColor,
     wickcolor=trendColor,
     bordercolor=trendColor
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ENTRY SIGNALS
// SELECTABLE ANCHOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showSignals and newLong
    label.new(
         bar_index,
         bullSignalAnchor,
         "𝓤𝓹",
         style=label.style_label_up,
         color=bullColor,
         textcolor=black,
         size=size.normal
    )

if showSignals and newShort
    label.new(
         bar_index,
         bearSignalAnchor,
         "𝓓𝓸𝔀𝓷",
         style=label.style_label_down,
         color=bearColor,
         textcolor=white,
         size=size.normal
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ATR TAKE PROFIT MARKERS
// TINY CROSSES ONLY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     newTP1 ?
     tp1 :
     na,
     title="TP1",
     style=shape.xcross,
     location=location.absolute,
     color=white,
     size=size.tiny
)

plotshape(
     newTP2 ?
     tp2 :
     na,
     title="TP2",
     style=shape.xcross,
     location=location.absolute,
     color=white,
     size=size.tiny
)

plotshape(
     newTP3 ?
     tp3 :
     na,
     title="TP3",
     style=shape.xcross,
     location=location.absolute,
     color=white,
     size=size.tiny
)

plotshape(
     newTP4 ?
     tp4 :
     na,
     title="TP4",
     style=shape.xcross,
     location=location.absolute,
     color=white,
     size=size.tiny
)

plotshape(
     newTP5 ?
     tp5 :
     na,
     title="TP5",
     style=shape.xcross,
     location=location.absolute,
     color=white,
     size=size.tiny
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TP PROGRESS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

int tpCount =
     (tp1Hit ? 1 : 0) +
     (tp2Hit ? 1 : 0) +
     (tp3Hit ? 1 : 0) +
     (tp4Hit ? 1 : 0) +
     (tp5Hit ? 1 : 0)

progress =
     tpCount == 0 ? "○ ○ ○ ○ ○" :
     tpCount == 1 ? "● ○ ○ ○ ○" :
     tpCount == 2 ? "● ● ○ ○ ○" :
     tpCount == 3 ? "● ● ● ○ ○" :
     tpCount == 4 ? "● ● ● ● ○" :
                     "● ● ● ● ●"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dashboard = table.new(
     position.top_right,
     2,
     6,
     bgcolor=black,
     frame_color=color.new(
          white,
          75
     ),
     frame_width=1,
     border_width=0
)

if barstate.islast

    table.clear(
         dashboard,
         0,
         0,
         1,
         5
    )

    if showTable

        table.cell(
             dashboard,
             0,
             0,
             "𝓑𝓪𝓷𝓭 𝓕𝓵𝓸𝔀",
             text_color=white,
             bgcolor=black
        )

        table.cell(
             dashboard,
             1,
             0,
             bullish ?
             "𝓑𝓾𝓵𝓵" :
             "𝓑𝓮𝓪𝓻",
             text_color=trendColor,
             bgcolor=black
        )

        table.cell(
             dashboard,
             0,
             1,
             "Trend",
             text_color=dimWhite,
             bgcolor=black
        )

        table.cell(
             dashboard,
             1,
             1,
             bullish ?
             "UP" :
             "DOWN",
             text_color=trendColor,
             bgcolor=black
        )

        table.cell(
             dashboard,
             0,
             2,
             "Overlay",
             text_color=dimWhite,
             bgcolor=black
        )

        table.cell(
             dashboard,
             1,
             2,
             overlayMode,
             text_color=white,
             bgcolor=black
        )

        table.cell(
             dashboard,
             0,
             3,
             "Signal Anchor",
             text_color=dimWhite,
             bgcolor=black
        )

        table.cell(
             dashboard,
             1,
             3,
             signalAnchorMode,
             text_color=white,
             bgcolor=black
        )

        table.cell(
             dashboard,
             0,
             4,
             "Entry",
             text_color=dimWhite,
             bgcolor=black
        )

        table.cell(
             dashboard,
             1,
             4,
             na(entryPrice) ?
             "—" :
             str.tostring(
                  entryPrice,
                  format.mintick
             ),
             text_color=white,
             bgcolor=black
        )

        table.cell(
             dashboard,
             0,
             5,
             "ATR Targets",
             text_color=dimWhite,
             bgcolor=black
        )

        table.cell(
             dashboard,
             1,
             5,
             progress,
             text_color=trendColor,
             bgcolor=black
        )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     newLong,
     "Band Flow Up",
     "Uptrick Band Flow turned bullish on {{ticker}}"
)

alertcondition(
     newShort,
     "Band Flow Down",
     "Uptrick Band Flow turned bearish on {{ticker}}"
)

alertcondition(
     newTP1,
     "TP1",
     "Band Flow TP1 hit on {{ticker}}"
)

alertcondition(
     newTP2,
     "TP2",
     "Band Flow TP2 hit on {{ticker}}"
)

alertcondition(
     newTP3,
     "TP3",
     "Band Flow TP3 hit on {{ticker}}"
)

alertcondition(
     newTP4,
     "TP4",
     "Band Flow TP4 hit on {{ticker}}"
)

alertcondition(
     newTP5,
     "TP5",
     "Band Flow TP5 hit on {{ticker}}"
)
````
