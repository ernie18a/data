# Real-Time Position Sizing Dashboard

- url: https://www.tradingview.com/script/zwgdIDdx-Real-Time-Position-Sizing-Dashboard/
- type: indicator
- pine_id: PUB;0e70c6ba508c4bf9812a4da8ec8354b5
- version: 1.0

## Description

Indicates trade size based on max dollar risk, as defined in the indicator settings, when the stop is one tick beyond the current and previous candles.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("Real-Time Position Sizing Dashboard", overlay = true)

// --- Constants ---
COLOR_BULL = #00ff00 // Bright Green
COLOR_BEAR = #ff0000 // Bright Red
COLOR_NEUTRAL = #00000000

// --- Inputs ---
riskAmountInput = input.float(100.0, "Risk Amount ($)", minval = 0.0, tooltip = "Total dollar amount to risk on this trade.")
slSourceInput   = input.string("Candle Bodies", "SL Source", options = ["Candle Bodies", "Wicks"], tooltip = "Logic used to determine the Stop Loss level.")
roundingInput   = input.int(2, "Rounding Precision", minval = 0, tooltip = "Decimal precision for the trade size calculation.")

// --- Core Logic ---
float bodyHigh = math.max(open, close)
float bodyLow  = math.min(open, close)
float bodyHighPrev = math.max(open[1], close[1])
float bodyLowPrev  = math.min(open[1], close[1])

// Momentum Detection (Relative to previous candle's body)
bool isBullishMomentum = close > bodyHighPrev
bool isBearishMomentum = close < bodyLowPrev

// SL Calculation Logic
float stopPrice = na
string direction = "Neutral"
color tableBg = COLOR_NEUTRAL

if isBullishMomentum
    direction := "Long"
    tableBg   := color.new(COLOR_BULL, 30)
    stopPrice := (slSourceInput == "Candle Bodies" ? math.min(bodyLow, bodyLowPrev) : math.min(low, low[1])) - syminfo.mintick
else if isBearishMomentum
    direction := "Short"
    tableBg   := color.new(COLOR_BEAR, 30)
    stopPrice := (slSourceInput == "Candle Bodies" ? math.max(bodyHigh, bodyHighPrev) : math.max(high, high[1])) + syminfo.mintick

// Position Sizing Calculation
float distance = math.abs(close - stopPrice)
float riskPerUnit = distance * syminfo.pointvalue
float tradeSize = (riskPerUnit > 0 and not na(riskPerUnit)) ? riskAmountInput / riskPerUnit : na

// --- Dashboard (Table) ---
var table dashboard = table.new(position.top_right, 2, 3, border_width = 1, border_color = chart.fg_color)

if barstate.islast
    // Header Style
    color textColor = chart.fg_color
    
    // Row 0: Direction
    table.cell(dashboard, 0, 0, "Direction",  text_color = textColor, bgcolor = tableBg)
    table.cell(dashboard, 1, 0, direction,    text_color = textColor, bgcolor = tableBg)
    
    // Row 1: Stop Price
    table.cell(dashboard, 0, 1, "Stop Price", text_color = textColor, bgcolor = tableBg)
    table.cell(dashboard, 1, 1, str.tostring(stopPrice, format.mintick), text_color = textColor, bgcolor = tableBg)
    
    // Row 2: Enter Size
    table.cell(dashboard, 0, 2, "Enter Size", text_color = textColor, bgcolor = tableBg)
    table.cell(dashboard, 1, 2, str.tostring(math.round(tradeSize, roundingInput)), text_color = textColor, bgcolor = tableBg)

// Visual cues on chart
plot(stopPrice, "Stop Level", color = isBullishMomentum ? COLOR_BULL : isBearishMomentum ? COLOR_BEAR : na, style = plot.style_linebr, linewidth = 2)
````
