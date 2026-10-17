# Fake Pin Bar & Engulfing Pattern Detector

- url: https://www.tradingview.com/script/Slasb2pf/
- type: indicator
- pine_id: PUB;09bf106a54d548e7861134ae12ab36a3
- version: 1.0

## Description

Fake Pin Bar & Engulfing Pattern Detector

This indicator is designed to detect Fake Pin Bar structures and standard Engulfing candle patterns directly on the chart.

A Fake Pin Bar is a price action pattern that appears after price forms a Mother Bar, then one or more Inside Bars, and finally produces a false breakout candle. The signal candle briefly breaks outside the Mother Bar range, but then returns back inside the structure. If that breakout candle also has a strong rejection wick and a relatively small body, the indicator marks it as a Fake Pin Bar.

The idea behind this pattern is simple: price attempts to break above or below a consolidation area, fails to continue, and closes back inside the previous range. This can show rejection, trapped breakout traders, or a possible reversal area.

How The Indicator Works

The script looks for three main components:

1. Mother Bar
A candle that defines the main high and low range.

2. Inside Bar Sequence
One or more candles after the Mother Bar that remain inside the Mother Bar range.

3. False Breakout Pin Bar
The signal candle must break only one side of the Mother Bar range and then return back inside it. For a bearish signal, price breaks above the Mother Bar high and rejects downward. For a bullish signal, price breaks below the Mother Bar low and rejects upward.

The indicator also detects standard bullish and bearish Engulfing patterns. An engulfing pattern is detected when the current candle body fully engulfs the previous candle body in the opposite direction.

Best Use Cases

This indicator is best used as a price action confirmation tool, not as a standalone trading system.

It can be useful around:

- Support and resistance areas
- Supply and demand zones
- Previous session highs and lows
- Liquidity sweep areas
- Consolidation breakouts
- Higher timeframe key levels
- Trend pullbacks
- Range boundaries

Fake Pin Bars are generally more meaningful when they appear at important market levels instead of random areas in the middle of a chart.

Settings

Minimum Wick Ratio
Controls how large the rejection wick must be compared to the full candle range. A higher value requires a stronger wick and produces fewer signals.

Maximum Body Ratio
Controls the maximum allowed candle body size compared to the full candle range. A lower value requires a smaller body and makes the pin bar condition stricter.

Maximum Inside Bar Count
Defines how many Inside Bars the script can look for after the Mother Bar. A higher value allows the indicator to detect longer consolidation structures.

Confirm Signals After Bar Close
When enabled, signals are confirmed only after the candle closes. This helps avoid signals changing during the live candle.

Require Body Inside Mother Bar
When enabled, the signal candle body must return fully inside the Mother Bar range. This makes Fake Pin Bar detection stricter.

Show Engulfing Candles
Turns standard bullish and bearish Engulfing candle detection on or off.

Show Pattern Details
Shows or hides the Mother Bar pattern box and high/low guide lines.

Label Text Size
Changes the size of the Fake Pin Bar signal labels.

Inside Bar Area Opacity
Controls the opacity of the pattern area shown on the chart.

Bullish Candle Color
Sets the color used for bullish Engulfing candles.

Bearish Candle Color
Sets the color used for bearish Engulfing candles.

Important Notes

This indicator does not place trades, does not calculate stop loss or take profit levels, and does not provide financial advice.

Signals should be combined with market structure, trend direction, volume, support/resistance, and proper risk management.

No price action pattern is perfect. Fake breakouts and engulfing candles can fail, especially in low-volume or choppy market conditions.

## Source Code

````pine
//@version=6
// SPDX-License-Identifier: MPL-2.0
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

indicator("Fake Pin Bar & Engulfing Pattern Detector", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// --- Inputs ---

float minWickRatio = input.float(0.55, title="Minimum Wick Ratio", minval=0.0, maxval=1.0, step=0.05, group="Pin Bar")
float maxBodyRatio = input.float(0.35, title="Maximum Body Ratio", minval=0.0, maxval=1.0, step=0.05, group="Pin Bar")

int maxIbCount = input.int(5, title="Maximum Inside Bar Count", minval=1, group="Inside Bar")

bool waitClose = input.bool(true, title="Confirm Signals After Bar Close", group="Signal")
bool strictMode = input.bool(false, title="Require Body Inside Mother Bar", group="Signal")
bool enableEngulfing = input.bool(true, title="Show Engulfing Candles", group="Signal")

bool showPatternDetails = input.bool(true, title="Show Pattern Details", group="Chart")
string labelSizeInput = input.string("S", title="Label Text Size", options=["XS", "S", "M", "L", "XL"], group="Chart")
int insideBarAreaOpacity = input.int(20, title="Inside Bar Area Opacity", minval=0, maxval=100, group="Chart")
color bullishCandleColor = input.color(color.teal, title="Bullish Candle Color", group="Chart")
color bearishCandleColor = input.color(color.orange, title="Bearish Candle Color", group="Chart")

// --- Calculations ---

float rng = high - low
float body = math.abs(close - open)
float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low

float upperRatio = rng == 0 ? 0 : upperWick / rng
float lowerRatio = rng == 0 ? 0 : lowerWick / rng
float bodyRatio = rng == 0 ? 0 : body / rng

bool detectionAllowed = waitClose ? barstate.isconfirmed : true

bool bearishPatternDetected = false
bool bullishPatternDetected = false
int triggeredK = na
float activeMbHigh = na
float activeMbLow = na

bool bearishEngulfDetected = false
bool bullishEngulfDetected = false

float minBodyPct = 5.0
int insideBarAreaTransparency = 100 - insideBarAreaOpacity
string labelSize = switch labelSizeInput
    "XS" => size.tiny
    "M" => size.normal
    "L" => size.large
    "XL" => size.huge
    => size.small

// Scan completed Mother Bar + Inside Bar structures.
if detectionAllowed
    for offset = 0 to maxIbCount - 1
        int k = maxIbCount - offset
        if bar_index >= k + 1
            float mbH = high[k + 1]
            float mbL = low[k + 1]

            bool allInside = true
            for j = 1 to k
                if high[j] > mbH or low[j] < mbL
                    allInside := false
                    break

            if allInside
                float signalBodyHigh = math.max(open, close)
                float signalBodyLow = math.min(open, close)
                bool signalCloseInsideMb = close <= mbH and close >= mbL
                bool signalBodyInsideMb = signalBodyHigh <= mbH and signalBodyLow >= mbL
                bool signalReturnInsideMb = strictMode ? signalBodyInsideMb : signalCloseInsideMb
                bool breaksAboveOnly = high > mbH and low >= mbL
                bool breaksBelowOnly = low < mbL and high <= mbH

                bool isBearishBreakout = breaksAboveOnly and signalReturnInsideMb
                bool isBearishPinBar = upperRatio >= minWickRatio and bodyRatio <= maxBodyRatio and upperWick > lowerWick

                bool isBullishBreakout = breaksBelowOnly and signalReturnInsideMb
                bool isBullishPinBar = lowerRatio >= minWickRatio and bodyRatio <= maxBodyRatio and lowerWick > upperWick

                if isBearishBreakout and isBearishPinBar
                    bearishPatternDetected := true
                    triggeredK := k
                    activeMbHigh := mbH
                    activeMbLow := mbL
                    break

                if isBullishBreakout and isBullishPinBar
                    bullishPatternDetected := true
                    triggeredK := k
                    activeMbHigh := mbH
                    activeMbLow := mbL
                    break

// Detect standalone Engulfing patterns.
if detectionAllowed and enableEngulfing and bar_index >= 1
    float prevRng = high[1] - low[1]
    float prevBody = math.abs(close[1] - open[1])
    bool prevIsDoji = prevRng == 0 or (prevBody / prevRng * 100) < minBodyPct

    if not prevIsDoji
        bool engulfsCandle = math.max(open, close) >= math.max(open[1], close[1]) and math.min(open, close) <= math.min(open[1], close[1])
        bool prevBullish = close[1] > open[1]
        bool prevBearish = close[1] < open[1]
        bool currBullish = close > open
        bool currBearish = close < open

        if engulfsCandle and currBearish and prevBullish
            bearishEngulfDetected := true

        if engulfsCandle and currBullish and prevBearish
            bullishEngulfDetected := true

// --- Visuals ---

// Drawings are created only when the current bar meets the detection rules.
// Mother Bar and Inside Bar objects highlight the completed pattern context.
if bearishPatternDetected or bullishPatternDetected
    int mbIndex = bar_index[triggeredK + 1]

    if showPatternDetails
        box.new(left=mbIndex, top=activeMbHigh, right=bar_index[1], bottom=activeMbLow, border_color=color.new(color.gray, 50), border_width=1, border_style=line.style_dashed, bgcolor=color.new(color.gray, insideBarAreaTransparency))
        line.new(x1=mbIndex, y1=activeMbHigh, x2=bar_index, y2=activeMbHigh, color=color.red, width=1, style=line.style_dotted)
        line.new(x1=mbIndex, y1=activeMbLow, x2=bar_index, y2=activeMbLow, color=color.green, width=1, style=line.style_dotted)

    if bearishPatternDetected
        label.new(x=bar_index, y=high, text="Bearish Fake Pin Bar", style=label.style_label_down, color=color.red, textcolor=color.white, size=labelSize)

    if bullishPatternDetected
        label.new(x=bar_index, y=low, text="Bullish Fake Pin Bar", style=label.style_label_up, color=color.green, textcolor=color.white, size=labelSize)

barcolor(bearishEngulfDetected ? bearishCandleColor : na)
barcolor(bullishEngulfDetected ? bullishCandleColor : na)

// --- Alerts ---

alertcondition(bullishPatternDetected, title="Bullish Fake Pin Bar Detected", message="Bullish Fake Pin Bar pattern detected.")
alertcondition(bearishPatternDetected, title="Bearish Fake Pin Bar Detected", message="Bearish Fake Pin Bar pattern detected.")
alertcondition(bullishPatternDetected or bearishPatternDetected, title="Any Fake Pin Bar Pattern Detected", message="Fake Pin Bar pattern detected.")

alertcondition(bullishEngulfDetected, title="Bullish Engulfing Detected", message="Bullish Engulfing pattern detected.")
alertcondition(bearishEngulfDetected, title="Bearish Engulfing Detected", message="Bearish Engulfing pattern detected.")
alertcondition(bullishEngulfDetected or bearishEngulfDetected, title="Any Engulfing Pattern Detected", message="Engulfing pattern detected.")
````
