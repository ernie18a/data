<!-- tradingview-pine-id: PUB;ce3762b08bff493ab52ebb042dca041b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Simple Stop Loss (Swing based with ATR protection)

Source: https://www.tradingview.com/script/KiF0PBLm-Simple-Swing-Stop-Loss-with-ATR-Buffer/

## Description

SSL – Precision Swing & ATR Stop Loss Engine

Stop guessing your exit levels. SSL automatically calculates dynamic, structure-based Stop Loss and Take Profit levels on your live bar to streamline your execution and capital protection.

Structure-Based Stops: Locks SL to recent swing highs/lows over your chosen lookback period.

ATR Noise Protection: Adds an ATR volatility buffer to prevent premature stop-outs from spread spikes.

Automated Take Profit: Projects TP levels instantly based on your custom Risk-to-Reward ratio.

Flexibility: Toggle between candle wicks or bodies to fit your precise market structure strategy.

Clean Chart Focus: Eliminates chart clutter by dynamically rendering levels strictly on the active bar.

Execute with confidence—let SSL handle the math.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Maximkrzsk

//@version=6
indicator("Simple Stop Loss (Swing based with ATR protection)", shorttitle = "SSL",overlay = true)


// Swing low / high on lookback +- (atr) 

// Get user input
direction   = input.string("Long", "Direction", ["Long","Short"], tooltip = "Select position type: 'Long' for buy setups or 'Short' for sell setups.")
useTarget   = input.bool(true,"Use Take Profit?", tooltip = "Enable or disable the Take Profit level plot on the chart.")
rr          = input.float(1.5,"Risk Reward Ratio", tooltip = "Defines your Target size as a multiple of your Stop Loss distance (e.g., 1.5 means target distance is 1.5x your risk).")
lookback    = input.int(7,"Lookback period", tooltip = "The number of previous bars used to calculate local swing highs and swing lows.")
useBody     = input.bool(false, "Use Candle Body", tooltip = "Switch from using high/low wicks to candle close prices for identifying swing points.")
useAtr      = input.bool(true,"Use ATR?", tooltip = "Adds an extra volatility buffer (ATR) to your Stop Loss to protect against wide spreads and market noise.")

// Get ATR and swings
atr         = ta.atr(14)
swingLow    = ta.lowest(useBody ? close : low, lookback + 1)
swingHigh   = ta.highest(useBody ? close : high, lookback + 1)

// calculating stops and targets
stop    = 0.0
target  = 0.0
longStop    = swingLow - (useAtr ? atr : 0)
shortStop   = swingHigh + (useAtr ? atr : 0)
longStopDistance    = close - longStop
shortStopDistance   = shortStop - close
longTarget  = close + longStopDistance * rr
shortTarget = close - shortStopDistance * rr

if direction == "Long"
    stop    := longStop
    target  := longTarget
else
    stop    := shortStop
    target  := shortTarget

// Draw lines to the chart (Delete previous lines on new bar)
var line stopLine = na
var line targetLine = na

if barstate.islast
    line.delete(stopLine)
    line.delete(targetLine)
    
    stopLine := line.new(bar_index, stop, bar_index + 5, stop, color=color.red, width=2)
    if useTarget
        targetLine := line.new(bar_index, target, bar_index + 5, target, color=color.green, width=2)
````
