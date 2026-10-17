# KEY LEVEL SMC - Order Block

- url: https://www.tradingview.com/script/4MmGpAx6-KEY-LEVEL-SMC-Order-Block/
- type: indicator
- pine_id: PUB;c39cc19515cf44e598b343875011ade2
- version: 4.0

## Description

The "KEY LEVEL SMC - Order Block" is a specialized institutional technical analysis tool optimized for TradingView v6. It automatically detects, highlights, and projects Order Blocks (OB) using strict algorithmic price action and structural efficiency logic. 

This indicator is specifically engineered for traders utilizing Smart Money Concepts (SMC) and Order Flow mechanics to maintain an objective view of institutional supply and demand zones.

### 📐 How It Works (Algorithmic Logic):
Unlike standard engulfing indicators, this script applies a strict filter requiring the immediate displacement to leave a structural imbalance (Fair Value Gap/Inefficiency) behind. The signal evaluates a 3-candle sequence:

1. **Bullish Order Block Configuration:**
   - The setup identifies a specific institutional down-candle followed by aggressive upward displacement. 
   - A valid signal is triggered only if the opening price of the current setup candle is within or below the previous candle's body, closes above the previous candle's open, and the subsequent candle's low fails to mitigate the high of the initial candle (confirming an immediate structural imbalance).
   - **Zone Boundaries:** The automated box marks the lowest point between the two initial candles as the bottom zone, and the open price of the setup candle as the top zone.

2. **Bearish Order Block Configuration:**
   - The setup tracks an institutional up-candle followed by sharp downward displacement.
   - Trigger criteria mandate that the setup candle opens within or above the previous body, closes below the previous open, and the subsequent candle's high leaves an unmitigated gap below the previous candle's low.
   - **Zone Boundaries:** The automated box spans from the highest point of the displacement candles to the open price of the setup candle.

### 💻 Key Features & Customization:
* **Dynamic Box Array Management:** The script utilizes dynamic arrays (`box[]`) to plot and track multiple historical zones simultaneously. To ensure peak chart performance without causing lag, it features an automated memory cleanup loop governed by the "Maximum Box Displayed" parameter.
* **Real-time Extensions:** Zones remain active and extend dynamically to the right with each new bar until the price action fully mitigates or invalidates the defined structural level.
* **Dark-Mode Optimized UI:** Built-in customized color groups allow traders to seamlessly adjust candle overlays and box transparencies to fit professional dark layout themes perfectly.

### 🛑 Disclaimer & Use Case:
This tool is intended for professional intraday and swing trading strategies across major pairs, indices, and metals. It works best when combined with higher-timeframe order flow alignment and key Fibonacci expansion target objectives.

## Source Code

````pine
//@version=6
indicator("KEY LEVEL SMC - Order Block", overlay=true)

// Inputs
highBarNext = high
lowBarNext = low
highBarPrevious = high[2]
lowBarPrevious = low[2]
openBarPrevious = open[2]
closeBarPrevious = close[2]
openBarCurrent = open[1]
closeBarCurrent = close[1]
int offset = 2 
bar_index_ = bar_index[offset]

// Brand Colors Customization (Dark Mode Optimized)
bearCandlecolor = input.color(defval=#a86161, title="Bearish OB Candle", inline='customcolor', group="Chart Customization Candles")
bullcandlecolor = input.color(defval=#004d40, title="Bullish OB Candle",  inline='customcolor', group="Chart Customization Candles")
adtranspCandle  = input.int(defval=65, title="Candle Transparency", minval=1, maxval=100, group="Chart Customization Candles")

bearboxcolor    = input.color(defval=#8b3a3a, title="Bearish OB Box", inline='customcolor', group="Chart Customization Box")
bullboxcolor     = input.color(defval=#1f534d, title="Bullish OB Box",  inline='customcolor', group="Chart Customization Box")
showOBboxes     = input.bool(true, title="Show OB Boxes", group="Chart Customization Box")
adtransp        = input.int(defval=75, title="Box Transparency", minval=1, maxval=100, group="Chart Customization Box")
adboxcount      = input.int(defval=50, title="Maximum Box Displayed", minval=1, maxval=200, group="Chart Customization")

// If the Candle in index of 1 and the next candle does not fill the imbalance, then a signal is generated. 
bullishEngulfing = openBarCurrent <= closeBarPrevious and openBarCurrent < openBarPrevious and closeBarCurrent > openBarPrevious and lowBarNext > highBarPrevious
bearishEngulfing = openBarCurrent >= closeBarPrevious and openBarCurrent > openBarPrevious and closeBarCurrent < openBarPrevious and highBarNext < lowBarPrevious

// Plot OB Candles
barcolor(bullishEngulfing ? color.new(bullcandlecolor, adtranspCandle) : na, offset=-2)
barcolor(bearishEngulfing ? color.new(bearCandlecolor, adtranspCandle) : na, offset=-2)

// Box Variables
var box[] bearboxarray = array.new_box()
var box[] bullboxarray = array.new_box()

// Box Color Variables
color adbearboxcolor        = color.new(bearboxcolor, adtransp)
color adbullboxcolor        = color.new(bullboxcolor, adtransp)
color adbearborderboxcolor = color.new(bearboxcolor, adtransp)
color adbullborderboxcolor = color.new(bullboxcolor, adtransp)

// Bearish OB Box Calculation
f_choppedoffbear(box[] bearboxarray) =>
    if (array.size(bearboxarray) > 0)
        for i = array.size(bearboxarray) - 1 to 0
            cutbox       = array.get(bearboxarray, i)
            boxlowzone   = box.get_bottom(cutbox)
            boxhighzone  = box.get_top(cutbox)
            boxrightzone = box.get_right(cutbox)
            if (na(boxrightzone) or (bar_index - 1 == boxrightzone and not ((high > boxlowzone and low < boxlowzone) or (high > boxhighzone and low < boxhighzone))))
                box.set_right(array.get(bearboxarray, i), bar_index)

// Bearish OB Box Plotting
if (bearishEngulfing and showOBboxes)
    boxhighzone = high[2] > high[1] ? high[2] : high[1]
    boxlowzone  = open[2]
    bearbox     = box.new(bar_index_, boxhighzone, bar_index, boxlowzone, border_color=adbearborderboxcolor, border_style=line.style_dashed, bgcolor=adbearboxcolor)
    if (array.size(bearboxarray) > adboxcount)
        box.delete(array.shift(bearboxarray))
    array.push(bearboxarray, bearbox)

f_choppedoffbear(bearboxarray)    

// Bullish OB Box Calculation
f_choppedoffbull(box[] bullboxarray) =>
    if (array.size(bullboxarray) > 0)
        for i = array.size(bullboxarray) - 1 to 0
            cutbox       = array.get(bullboxarray, i)
            boxlowzone   = box.get_bottom(cutbox)
            boxhighzone  = box.get_top(cutbox)
            boxrightzone = box.get_right(cutbox)
            if (na(boxrightzone) or (bar_index - 1 == boxrightzone and not ((high > boxlowzone and low < boxlowzone) or (high > boxhighzone and low < boxhighzone))))
                box.set_right(array.get(bullboxarray, i), bar_index)

// Bullish OB Box Plotting
if (bullishEngulfing and showOBboxes)
    boxlowzone  = low[1] < low[2] ? low[1] : low[2]
    boxhighzone = open[2]
    bullbox     = box.new(bar_index_, boxhighzone, bar_index, boxlowzone, border_color=adbullborderboxcolor, border_style=line.style_dashed, bgcolor=adbullboxcolor)
    if (array.size(bullboxarray) > adboxcount)
        box.delete(array.shift(bullboxarray))
    array.push(bullboxarray, bullbox)

f_choppedoffbull(bullboxarray)
 // update preview
  // update preview
````
