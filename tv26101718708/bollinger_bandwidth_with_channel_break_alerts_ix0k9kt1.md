# Bollinger BandWidth with Channel Break Alerts

- url: https://www.tradingview.com/script/iX0K9Kt1-Bollinger-BandWidth-with-Channel-Break-Alerts/
- type: indicator
- pine_id: PUB;dd2561c2360a4a6c92ec317046bd4166
- version: 1.0

## Description

[image]https://www.tradingview.com/x/v6ncXSxH/[/image]# Bollinger BandWidth with Channel Break & Momentum Alerts (BBW Alerts)

## Overview

The **Bollinger BandWidth with Channel Break Alerts** indicator measures relative volatility cycles—specifically identifying when the market moves from deep compression (squeeze) to explosive expansion (breakout).

Standard Bollinger Bands show channel boundaries directly on price. This indicator plots normalized **BandWidth (BBW)** as an oscillator to clearly track the compression floor and volatility ceiling over rolling lookback windows. It filters volatility breakouts with directional price action and relative candle-body momentum, pinpointing high-probability entry opportunities right as price breaks out of the squeeze.

---

## How It Works

### 1. Bollinger BandWidth Formula

The indicator calculates normalized BandWidth as a percentage:


$$\text{BBW} = \frac{\text{Upper Band} - \text{Lower Band}}{\text{Basis (SMA)}} \times 100$$

* A low BBW value signals a low-volatility consolidation phase (the squeeze).
* A rising BBW value signals expanding volatility and trending conditions.

### 2. Rolling Extremes (The Volatility Channel)

* **Lowest Contraction (Green Line):** Tracks the lowest BBW reading over your selected lookback window (`contractionLengthInput`, default: 125 bars). This defines the floor of the squeeze.
* **Highest Expansion (Red Line):** Tracks the peak BBW reading over your selected lookback window (`expansionLengthInput`, default: 125 bars). This marks maximum volatility where moves often exhaust.

### 3. Price Action & Candle Body Filter

Not all expansions lead to clean trends. To filter out false breaks, the script includes a relative candle-body filter:

* Compares the absolute body size ($\vert{}\text{Close} - \text{Open}\vert{}$) of the breakout bar against a simple moving average of previous candle bodies.
* Ensures only high-momentum candles trigger confirmed signals when configured.

---

## Key Visual Signals

| Marker / Signal | Visual Representation | Meaning |
| --- | --- | --- |
| **Bullish Channel Break** | Green Triangle Up (Bottom) | BBW crossed above the contraction floor while price closed above the middle basis. |
| **Bearish Channel Break** | Red Triangle Down (Bottom) | BBW crossed above the contraction floor while price closed below the middle basis. |
| **Touch Lower Limit** | Green Triangle Down (Bottom) | BBW touched the contraction floor—market is entering peak squeeze. |
| **Touch Upper Limit** | Red Triangle Up (Top) | BBW reached multi-period peak expansion—volatility exhaustion warning. |
| **Channel Break Highlight** | Green / Red Background Tint | Confirms active breakout bar direction at a glance. |

---

## Included Alerts

This script features dedicated alerts compatible with standard TradingView alert dialogs as well as dynamic webhook automations.

### 1. Channel Breakout Alerts (Trade Entry)

* **`BBW Channel Break - Bullish Entry`**: Fires when BBW crosses up out of the multi-period contraction channel while price action is bullish (`Close > Basis`). Best used for Long entry confirmation.
* **`BBW Channel Break - Bearish Entry`**: Fires when BBW crosses up out of the contraction channel while price action is bearish (`Close < Basis`). Best used for Short entry confirmation.
* **`BBW Channel Break - Any`**: Triggers whenever BBW breaks out of the squeeze floor regardless of directional bias.

### 2. Volatility Cycle Alerts

* **`BBW Touches Lower Limit`**: Alerts when the market hits maximum compression (Lowest Contraction line), warning you that a large move is preparing to load.
* **`BBW Touches Upper Limit`**: Alerts when volatility reaches its multi-period ceiling (Highest Expansion line), signaling potential trend exhaustion or parabolic climax.
* **`BBW Curves Up + Big Body Candle`**: Triggers when volatility curls upward from the base with an expanded candle body meeting your multiplier threshold.

### 3. Programmatic Webhook Alert (`alert()`)

The script includes dynamic `alert()` function calls containing real-time price, ticker, and timeframe data:

* `BUY SIGNAL: BBW broke out of squeeze channel upward...`
* `SELL SIGNAL: BBW broke out of squeeze channel downward...`

To receive both directional triggers under a single alert without creating separate alerts, choose **"Any alert() function call"** in the TradingView Alert Creation window.

---

## Recommended Settings & Tips

* **Trigger Setting:** Always set alert frequency to **"Once Per Bar Close"** to avoid false triggers from intra-bar wicks that collapse before the candle finishes.
* **Length Inputs (Default: 125):**
* On lower intraday timeframes (1m–15m), 100–150 bars captures several hours to a few sessions of consolidation.
* On daily/weekly swing charts, adjust between 50 and 100 bars to capture quarterly cycles.


* **Confirming with Price Action:** Use the middle SMA line (20 SMA) or local support/resistance levels as invalidation stops when trading squeeze breaks.

## Source Code

````pine
//@version=6
indicator(title="Bollinger BandWidth with Channel Break Alerts", shorttitle="BBW Alerts", format=format.price, precision=2)

string TT_LENGTH   = "The time period to be used in calculating the SMA which creates the base for the Upper and Lower Bands."
string TT_SOURCE   = "Determines what data from each bar will be used in calculations."
string TT_MULT     = "The number of Standard Deviations away from the SMA that the Upper and Lower Bands should be."
string TT_HI_EXP   = "The Highest Expansion plot displays the highest value that BBW had in the last N bars."
string TT_LO_EXP   = "The Lowest Contraction plot displays the lowest value that BBW had in the last N bars."
string TT_BODY_LEN = "Lookback window of prior bars to compute the baseline average candle body size."
string TT_BODY_MUL = "How many times larger the current candle body (|close - open|) must be compared to the surrounding average."

// ================= Inputs =================
length                 = input.int(20,       "Length", minval = 1, tooltip = TT_LENGTH)
src                    = input.source(close, "Source",             tooltip = TT_SOURCE)
mult                   = input.float(2.0,    "StdDev", minval = 0.001, maxval = 50, tooltip = TT_MULT)
expansionLengthInput   = input.int(125,      "Highest Expansion Length",  minval = 1, tooltip = TT_HI_EXP)
contractionLengthInput = input.int(125,      "Lowest Contraction Length", minval = 1, tooltip = TT_LO_EXP)
showSignals            = input.bool(true,    "Show Visual Shapes on Chart")

// Candle Body Filter Inputs
candleGroup            = "Price Action Body Filter"
bodyLookback           = input.int(10,       "Surrounding Candles Lookback", minval = 2, tooltip = TT_BODY_LEN, group = candleGroup)
bodyMultiplier         = input.float(1.8,    "Body Size Multiplier", minval = 1.0, step = 0.1, tooltip = TT_BODY_MUL, group = candleGroup)
bodyDirection          = input.string("Any", "Trigger Direction", options = ["Any", "Bullish Only", "Bearish Only"], group = candleGroup)

// ================= Calculations =================
basis = ta.sma(src, length)
dev   = mult * ta.stdev(src, length)
upper = basis + dev
lower = basis - dev
bbw   = ((upper - lower) / basis) * 100

// Expansion & Contraction levels (Current & Previous reference)
highestExp  = ta.highest(bbw, expansionLengthInput)
lowestCont  = ta.lowest(bbw, contractionLengthInput)

// Reference thresholds based on prior bars
hiThreshold = ta.highest(bbw[1], expansionLengthInput)
loThreshold = ta.lowest(bbw[1], contractionLengthInput)

// ================= Candle Body Expansion Logic =================
candleBody         = math.abs(close - open)
avgSurroundingBody = ta.sma(candleBody[1], bodyLookback)
isBigBody          = candleBody >= (avgSurroundingBody * bodyMultiplier)

isBullish = close > open
isBearish = close < open

bodyDirValid = switch bodyDirection
    "Bullish Only" => isBullish
    "Bearish Only" => isBearish
    => true

// ================= Channel Breakout Logic =================
// 1. BBW crosses above the squeeze channel line (Lowest Contraction threshold)
bbwChannelBreak = ta.crossover(bbw, loThreshold)

// 2. Price direction check at the time of breakout
bullishBreak = bbwChannelBreak and (close > basis) and (bodyDirection != "Bearish Only")
bearishBreak = bbwChannelBreak and (close < basis) and (bodyDirection != "Bullish Only")
anyChannelBreak = bbwChannelBreak and bodyDirValid

// 3. Existing alert conditions
touchUpper         = (bbw >= hiThreshold) and (bbw[1] < hiThreshold)
touchLower         = (bbw <= loThreshold) and (bbw[1] > loThreshold)
curveUpLower       = (bbw[1] <= loThreshold[1]) and (bbw > bbw[1])
curveDownUpper     = (bbw[1] >= hiThreshold[1]) and (bbw < bbw[1])
curveUpWithBigBody = curveUpLower and isBigBody and bodyDirValid

// ================= Plots =================
plot(bbw, "Bollinger BandWidth", color = #2962FF, linewidth = 2)
plot(highestExp, "Highest Expansion",  color = color.new(#F23645, 40), linewidth = 1)
plot(lowestCont, "Lowest Contraction", color = color.new(#089981, 40), linewidth = 1)

// Visual signal markers on BBW pane
plotshape(showSignals and bullishBreak, title="Bullish Channel Break", style=shape.triangleup,   location=location.bottom, color=color.green, size=size.small)
plotshape(showSignals and bearishBreak, title="Bearish Channel Break", style=shape.triangledown, location=location.bottom, color=color.red,   size=size.small)
plotshape(showSignals and touchUpper,   title="Touch Upper Marker",    style=shape.triangleup,   location=location.top,    color=#F23645,     size=size.tiny)
plotshape(showSignals and touchLower,   title="Touch Lower Marker",    style=shape.triangledown, location=location.bottom, color=#089981,     size=size.tiny)

// Background highlights
bgcolor(showSignals and bullishBreak ? color.new(color.green, 85) : showSignals and bearishBreak ? color.new(color.red, 85) : na, title="Channel Break Highlight")

// ================= Alerts Configuration =================
// Specific Channel Break Alerts for Trade Entry
alertcondition(bullishBreak,
     title   = "BBW Channel Break - Bullish Entry",
     message = "BBW broke out of the contraction channel with bullish price action! Ticker: {{ticker}} | Price: {{close}} | Interval: {{interval}}")

alertcondition(bearishBreak,
     title   = "BBW Channel Break - Bearish Entry",
     message = "BBW broke out of the contraction channel with bearish price action! Ticker: {{ticker}} | Price: {{close}} | Interval: {{interval}}")

alertcondition(anyChannelBreak,
     title   = "BBW Channel Break - Any",
     message = "BBW broke above the contraction floor channel on {{ticker}} at price {{close}}.")

// Standard boundary conditions
alertcondition(touchLower, 
     title   = "BBW Touches Lower Limit", 
     message = "BBW has touched the Lowest Contraction line on {{ticker}}.")

alertcondition(touchUpper, 
     title   = "BBW Touches Upper Limit", 
     message = "BBW has touched the Highest Expansion line on {{ticker}}.")

alertcondition(curveUpWithBigBody, 
     title   = "BBW Curves Up + Big Body Candle", 
     message = "BBW curled upwards with momentum expansion on {{ticker}} at {{close}}.")

// Programmatic alerts (usable with 'Any alert() function call')
if bullishBreak
    alert("BUY SIGNAL: BBW broke out of squeeze channel upward on " + syminfo.ticker + " at " + str.tostring(close), alert.freq_once_per_bar_close)

if bearishBreak
    alert("SELL SIGNAL: BBW broke out of squeeze channel downward on " + syminfo.ticker + " at " + str.tostring(close), alert.freq_once_per_bar_close)
````
