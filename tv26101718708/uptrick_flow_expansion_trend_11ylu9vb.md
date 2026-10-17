# Uptrick: Flow Expansion Trend

- url: https://www.tradingview.com/script/11yLU9vb-Uptrick-Flow-Expansion-Trend/
- type: indicator
- pine_id: PUB;b02938e6792f461590c1c269954d4ba6
- version: 1.0

## Description

[b][i]Introduction[/i][/b]
Uptrick: Flow Expansion Trend (FET) is an overlay tool built around an efficiency-adaptive midline that speeds up or slows down based on how directional recent price movement has been. The midline is paired with a volatility-based signal boundary and a minimum flow-strength filter to determine confirmed trend flips, and the script includes a market-state read that classifies current conditions as directional, developing, or compressed. Signal labels can be anchored to price highs and lows, a fixed ATR distance from price, or the midline itself.

[b][i]Originality[/i][/b]
This script's core is an efficiency ratio, calculated as the net price movement over a lookback divided by the sum of all bar-to-bar movement over that same lookback, which produces a value between 0 and 1 describing how directional versus choppy the recent path has been. Rather than using this ratio as a standalone oscillator, it is fed into the smoothing constant of the midline itself, so the midline's responsiveness continuously adjusts between a fast and slow smoothing constant based on current market efficiency. This is what separates the midline from a standard moving average, since it does not use a fixed lookback response but instead reshapes itself with the character of the move.

The signal boundary distance around the midline is also adaptive: it widens or narrows based on the same efficiency reading, so the distance price must travel to trigger a trend flip contracts in efficient, directional conditions and expands in choppier ones. A trend flip additionally requires a minimum flow-strength threshold, a normalized measure of the midline's own rate of change relative to ATR, so a boundary breach alone is not sufficient to flip the trend without accompanying follow-through in the midline's slope.

Combining an adaptive midline, an adaptive signal boundary, and a flow-strength confirmation filter into a single confirmed-trend mechanism is the original contribution of this script, since each of the three components is derived from the same efficiency and volatility inputs but serves a distinct role in preventing premature or noise-driven flips. The selectable signal anchor further separates the trend calculation from the signal display, letting traders choose whether labels sit at the bar's high/low, a fixed ATR offset from price, or directly on the midline, without altering the underlying trend logic in any way.

[b][i]Features[/i][/b]
[list]
[*]Efficiency-adaptive midline that adjusts its smoothing speed based on how directional recent price action has been
[*]Adaptive signal boundary that widens in choppy conditions and narrows in directional conditions
[*]Minimum flow-strength filter required alongside a boundary breach to confirm a trend flip
[*]Confirmed-bar trend state calculation to avoid intrabar repainting of the trend flip
[*]Selectable signal anchor for up and down labels: high/low, fixed ATR distance from price, or midline
[*]Adjustable ATR distance value when the ATR distance anchor is selected
[*]Up and down trend signal labels
[*]Optional candle coloring based on the most recent confirmed signal
[*]Adjustable midline width
[*]On-chart dashboard showing trend, market efficiency percentage, flow strength, market state classification, bars since the last signal, and current signal anchor mode
[*]Four selectable dashboard positions
[*]Four alert conditions: up signal, down signal, any trend signal, and market becoming directional
[/list]
[b][i]Inputs[/i][/b]
[list]
[*]Trend Engine: source, trend length, signal distance multiplier, minimum signal strength threshold.
[*]Signals: show/hide up and down signals, signal anchor mode, signal ATR distance.
[*]Visuals: candle coloring toggle, midline width, show/hide dashboard, dashboard position.
[/list]
[b][i]How It Works / How to Use[/i][/b]
The script measures how efficiently price has moved over the trend length by comparing net displacement to total path length traveled. This efficiency value continuously reshapes the midline's smoothing speed, so the midline hugs price more closely in strong directional runs and lags more in choppy conditions. An ATR-based boundary is placed around the midline, with its distance also scaled by the same efficiency reading. A trend flip is confirmed only when price closes beyond this boundary on a confirmed bar and the midline's own rate of change exceeds the minimum flow-strength threshold in that direction.

Once a flip is confirmed, the up or down label is placed according to the chosen signal anchor: at the bar's high or low, at a fixed ATR distance beyond price, or directly on the midline. This is purely a display choice and does not affect when or why a trend flip occurs.
Traders can use the midline's slope and color for ongoing directional bias, the up and down signals for confirmed flips, and the dashboard's market-state classification to gauge whether current conditions are more suited to trend-following or more likely to produce choppy, range-bound behavior.

[b][i]Conclusion[/i][/b]
Uptrick: Flow Expansion Trend combines an efficiency-adaptive midline, a matching adaptive signal boundary, and a flow-strength confirmation filter into a single trend-following overlay, giving traders a trend read that reshapes itself with current market conditions rather than relying on a fixed-speed average, with flexible signal placement to suit different charting preferences.

[quote]Disclaimer
This script is provided for informational and educational purposes only and does not constitute financial advice. Past performance, whether shown historically or implied through the script's logic, does not guarantee future results. Always perform your own due diligence and risk management before making trading decisions.[/quote]

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
     "Uptrick: Flow Expansion Trend",
     shorttitle = "FET",
     overlay = true,
     max_labels_count = 500
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpEngine = "01. Trend Engine"

source = input.source(
     hlc3,
     "Source",
     group = grpEngine
)

trendLength = input.int(
     34,
     "Trend Length",
     minval = 5,
     group = grpEngine
)

bandMultiplier = input.float(
     1.6,
     "Signal Distance",
     step = 0.1,
     group = grpEngine
)

minimumStrength = input.float(
     0.03,
     "Signal Strength",
     minval = 0.0,
     step = 0.01,
     group = grpEngine
)

grpSignals = "02. Signals"

showSignals = input.bool(
     true,
     "Show Up / Down Signals",
     group = grpSignals
)

signalAnchor = input.string(
     "Midline",
     "Signal Anchor",
     options = [
          "High / Low",
          "ATR Distance",
          "Midline"
     ],
     group = grpSignals
)

signalAtrDistance = input.float(
     0.50,
     "Signal ATR Distance",
     minval = 0.0,
     step = 0.05,
     group = grpSignals
)

grpVisuals = "03. Visuals"

colorCandles = input.bool(
     true,
     "Color Candles",
     group = grpVisuals
)

lineWidth = input.int(
     4,
     "Midline Width",
     minval = 1,
     maxval = 8,
     group = grpVisuals
)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = grpVisuals
)

dashboardPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options = [
          "Top Left",
          "Top Right",
          "Bottom Left",
          "Bottom Right"
     ],
     group = grpVisuals
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Colors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullColor = color.new(#00FFE5, 0)
bearColor = color.new(#FF00B5, 0)
neutralColor = color.new(#FFD84D, 0)

blackText = color.new(#000000, 0)
whiteText = color.new(#FFFFFF, 0)

darkBackground = color.new(#000104, 12)
headerBackground = color.new(#111827, 0)
softBorder = color.new(color.white, 55)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Functions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_clamp(_value, _minimum, _maximum) =>
    math.max(
         _minimum,
         math.min(
              _value,
              _maximum
         )
    )

f_tablePosition(_position) =>
    _position == "Top Left" ? position.top_left :
     _position == "Bottom Left" ? position.bottom_left :
     _position == "Bottom Right" ? position.bottom_right :
     position.top_right

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Market Efficiency
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

netMovement = math.abs(
     source -
     source[trendLength]
)

totalMovement = math.sum(
     math.abs(
          ta.change(source)
     ),
     trendLength
)

efficiency =
     na(totalMovement) or totalMovement == 0.0 ?
     0.0 :
     netMovement / totalMovement

efficiency := f_clamp(
     efficiency,
     0.0,
     1.0
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive Flow Midline
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

fastAlpha = 2.0 / 3.0

slowAlpha =
     2.0 /
     (trendLength + 1.0)

adaptiveAlpha = math.pow(
     efficiency *
     (fastAlpha - slowAlpha) +
     slowAlpha,
     2
)

var float flowLine = na

flowLine :=
     na(flowLine[1]) ?
     source :
     flowLine[1] +
     adaptiveAlpha *
     (source - flowLine[1])

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Internal Signal Boundaries
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atrValue = ta.atr(14)

safeAtr =
     atrValue != 0.0 ?
     atrValue :
     syminfo.mintick

flowVelocity = ta.ema(
     ta.change(flowLine),
     5
)

flowStrength =
     flowVelocity /
     safeAtr

adaptiveExpansion =
     1.25 -
     efficiency * 0.45

signalDistance =
     safeAtr *
     bandMultiplier *
     adaptiveExpansion

upperBoundary =
     flowLine +
     signalDistance

lowerBoundary =
     flowLine -
     signalDistance

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Confirmed Trend State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int trend = na

trend := nz(
     trend[1],
     close >= flowLine ? 1 : -1
)

if barstate.isconfirmed
    if trend[1] == -1 and close > upperBoundary and flowStrength > minimumStrength
        trend := 1

    else if trend[1] == 1 and close < lowerBoundary and flowStrength < -minimumStrength
        trend := -1

bullish = trend == 1
bearish = trend == -1

upSignal =
     barstate.isconfirmed and
     bullish and
     trend[1] == -1

downSignal =
     barstate.isconfirmed and
     bearish and
     trend[1] == 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Latest Signal State
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var int latestSignal = na
var int latestSignalBar = na

latestSignal := nz(
     latestSignal[1],
     trend
)

if upSignal
    latestSignal := 1
    latestSignalBar := bar_index

if downSignal
    latestSignal := -1
    latestSignalBar := bar_index

latestColor =
     latestSignal == 1 ?
     bullColor :
     latestSignal == -1 ?
     bearColor :
     neutralColor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Adaptive Midline
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     flowLine,
     title = "Adaptive Flow Midline",
     color = latestColor,
     linewidth = lineWidth
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Signal Anchors
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

upAnchor =
     signalAnchor == "High / Low" ?
     low :
     signalAnchor == "ATR Distance" ?
     low - safeAtr * signalAtrDistance :
     flowLine

downAnchor =
     signalAnchor == "High / Low" ?
     high :
     signalAnchor == "ATR Distance" ?
     high + safeAtr * signalAtrDistance :
     flowLine

upLabelAnchor =
     showSignals and upSignal ?
     upAnchor :
     na

downLabelAnchor =
     showSignals and downSignal ?
     downAnchor :
     na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Up / Down Signals
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     upLabelAnchor,
     title = "Up Signal",
     location = location.absolute,
     style = shape.labelup,
     text = "𝓤𝓹",
     color = bullColor,
     textcolor = blackText,
     size = size.normal
)

plotshape(
     downLabelAnchor,
     title = "Down Signal",
     location = location.absolute,
     style = shape.labeldown,
     text = "𝓓𝓸𝔀𝓷",
     color = bearColor,
     textcolor = whiteText,
     size = size.normal
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Candle Coloring by Latest Signal
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

candleColor =
     colorCandles ?
     latestColor :
     na

plotcandle(
     open,
     high,
     low,
     close,
     title = "Latest Signal Candles",
     color = candleColor,
     wickcolor = candleColor,
     bordercolor = candleColor
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard Values
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendText =
     latestSignal == 1 ?
     "Bullish" :
     latestSignal == -1 ?
     "Bearish" :
     "Neutral"

efficiencyText =
     str.tostring(
          efficiency * 100.0,
          "#.0"
     ) + "%"

strengthText =
     str.tostring(
          flowStrength,
          "#.000"
     )

marketState =
     efficiency >= 0.60 ?
     "Directional" :
     efficiency >= 0.30 ?
     "Developing" :
     "Compressed"

barsSinceSignal =
     na(latestSignalBar) ?
     na :
     bar_index - latestSignalBar

barsText =
     na(barsSinceSignal) ?
     "N/A" :
     str.tostring(barsSinceSignal)

anchorText =
     signalAnchor == "ATR Distance" ?
     "ATR " + str.tostring(signalAtrDistance, "#.00") :
     signalAnchor

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Dashboard
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dashboard = table.new(
     f_tablePosition(dashboardPosition),
     2,
     7,
     frame_color = color.new(color.white, 35),
     frame_width = 1,
     border_color = softBorder,
     border_width = 1
)

if barstate.isfirst
    table.merge_cells(
         dashboard,
         0,
         0,
         1,
         0
    )

if showDashboard and barstate.islast
    table.cell(
         dashboard,
         0,
         0,
         "FET",
         text_color = whiteText,
         bgcolor = headerBackground,
         text_halign = text.align_center
    )

    table.cell(
         dashboard,
         0,
         1,
         "Trend",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         1,
         trendText,
         text_color = latestSignal == 1 ? blackText : whiteText,
         bgcolor = latestColor
    )

    table.cell(
         dashboard,
         0,
         2,
         "Efficiency",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         2,
         efficiencyText,
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         0,
         3,
         "Flow Strength",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         3,
         strengthText,
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         0,
         4,
         "Market State",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         4,
         marketState,
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         0,
         5,
         "Bars Since Signal",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         5,
         barsText,
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         0,
         6,
         "Signal Anchor",
         text_color = whiteText,
         bgcolor = darkBackground
    )

    table.cell(
         dashboard,
         1,
         6,
         anchorText,
         text_color = whiteText,
         bgcolor = darkBackground
    )

if not showDashboard and barstate.islast
    table.clear(
         dashboard,
         0,
         0,
         1,
         6
    )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Alert Conditions
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     upSignal,
     title = "Up Signal",
     message = "Uptrick FET: Up signal printed on {{ticker}} at {{close}}"
)

alertcondition(
     downSignal,
     title = "Down Signal",
     message = "Uptrick FET: Down signal printed on {{ticker}} at {{close}}"
)

alertcondition(
     upSignal or downSignal,
     title = "Any Trend Signal",
     message = "Uptrick FET: New trend signal printed on {{ticker}} at {{close}}"
)

alertcondition(
     ta.crossover(efficiency, 0.60),
     title = "Directional Market",
     message = "Uptrick FET: Market efficiency became directional on {{ticker}}"
)
````
