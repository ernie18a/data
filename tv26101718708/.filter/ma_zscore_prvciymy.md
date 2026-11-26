# MA Z-score

- url: https://www.tradingview.com/script/pRVciYMy/
- type: indicator
- pine_id: PUB;2fc2631cda4046d0bb360d08caef63b9
- version: 2.0

## Description

## MA Z-Score

The MA Z-Score is a momentum and trend-strength indicator that measures how far a moving average deviates from its statistical mean using a Z-score calculation. Instead of analyzing raw price action directly, this script normalizes the selected moving average and helps traders identify trend acceleration, overextended conditions, and momentum shifts more clearly across different markets and timeframes.

### Features

* Multiple Moving Average types:

  * EMA
  * SMA
  * DEMA
  * HMA
  * VWMA

* Z-score normalization of the selected MA

* Configurable lookback period

* Adjustable bullish and bearish thresholds

* Dynamic trend coloring

* Optional bar coloring

* Custom visual reference levels

* Built-in alert conditions for long and short signals

### How It Works

The script first calculates a moving average based on the selected type and length.

It then computes:

* The mean of the MA using an EMA
* The standard deviation over the chosen lookback period
* The Z-score using:

[
Z = \frac{MA - Mean}{Standard\ Deviation}
]

This creates a normalized oscillator showing how extreme the current MA value is relative to its recent behavior.

### Signal Logic

* Long Condition:

  * Triggered when the Z-score rises above the bullish threshold.

* Short Condition:

  * Triggered when the Z-score falls below the bearish threshold.

The oscillator changes color depending on trend direction:

* Green = bullish momentum
* Pink = bearish momentum

Optional candle coloring allows price bars to reflect the current trend state directly on the chart.

### Best Use Cases

This indicator can be used for:

* Trend confirmation
* Momentum analysis
* Detecting strong expansions
* Identifying potential reversals
* Filtering trades with statistical context
* Multi-timeframe trend alignment

### Tips

* Lower thresholds create more signals but increase noise.
* Higher thresholds filter weak momentum and focus on stronger trends.
* HMA and DEMA react faster to price movement.
* VWMA can be useful for volume-sensitive markets.

### Alerts

The script includes built-in TradingView alerts:

* MA Z-score Long
* MA Z-score Short

These alerts can be connected to notifications, bots, or automated workflows.

### Important

This indicator is not designed as a standalone trading system. It works best when combined with:

* Market structure
* Support & resistance
* Volume analysis
* Higher timeframe bias
* Risk management

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © bii_vg

//@version=5
indicator(title="MA Z-score", overlay=false, timeframe="", timeframe_gaps=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
len = input.int(20,"MA len", group = "MA Settings")
src = input.source(close, "MA src", group = "MA Settings")
maType = input.string("EMA", "MA Type", options = ["EMA","SMA","DEMA","HMA","VWMA"], group="MA Settings")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MA FUNCTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_ma(_src, _len, _type) =>
    float _ma = na
    
    if _type == "EMA"
        _ma := ta.ema(_src, _len)
    else if _type == "SMA"
        _ma := ta.sma(_src, _len)
    else if _type == "DEMA"
        ema1 = ta.ema(_src, _len)
        _ma := 2 * ema1 - ta.ema(ema1, _len)
    else if _type == "HMA"
        _len_half = math.round(_len / 2)
        _len_sqrt = math.round(math.sqrt(_len))
        _ma := ta.wma(2 * ta.wma(_src, _len_half) - ta.wma(_src, _len), _len_sqrt)
    else if _type == "VWMA"
        _ma := ta.vwma(_src, _len)

    _ma

// MA berechnen
ma = f_ma(src, len, maType)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Z-SCORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lookback = input.int(30,"lookback period", group = "Z-score")

mean = ta.ema(ma, lookback)
stdDev = ta.stdev(ma, lookback)
zScore = (ma - mean) / nz(stdDev, 1e-10)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL THRESHOLDS (aktiv)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Threshold_L = input.float(1,title = "Threshold uptrend", step = 0.5, group = "Threshold")
Threshold_S = input.float(0,title = "Threshold downtrend" , step = 0.5, group = "Threshold") 

L = zScore > Threshold_L
S = zScore < Threshold_S

var int vii = 0

if L and not S 
    vii := 1
else if S 
    vii := -1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXTRA LEVELS (nur visuell)
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
lvl1 = input.float(2.0, "Extra Level 1", group="Extra Levels")
lvl2 = input.float(-1.0, "Extra Level 2", group="Extra Levels")
lvl3 = input.float(3.0, "Extra Level 3", group="Extra Levels")
lvl4 = input.float(-2.0, "Extra Level 4", group="Extra Levels")
lvl5 = input.float(0.5, "Extra Level 5", group="Extra Levels")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plot(zScore, "Z-score plot", color = vii == 1 ? color.rgb(0, 255, 187) : vii == -1 ? color.rgb(255, 0, 157) : color.gray, linewidth = 2)

hline(Threshold_L, "Uptrend", color = color.rgb(0, 255, 187))
hline(Threshold_S, "Downtrend", color = color.rgb(255, 0, 157))

hline(lvl1, "Extra 1", color=color.gray, linestyle=hline.style_dotted)
hline(lvl2, "Extra 2", color=color.gray, linestyle=hline.style_dotted)
hline(lvl3, "Extra 3", color=color.gray, linestyle=hline.style_dotted)
hline(lvl4, "Extra 4", color=color.gray, linestyle=hline.style_dotted)
hline(lvl5, "Extra 5", color=color.gray, linestyle=hline.style_dotted)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BAR COLOR
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bar = input.bool(true,"bar color", group = "bar color settings")
barcolor(vii == 1 and bar ? color.rgb(0, 255, 187) : na)
barcolor(vii == -1 and bar ? color.rgb(255, 0, 157) : na)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(L, title="MA Z-score Long", message="MA Z-score Long {{exchange}}:{{ticker}}")
alertcondition(S, title="MA Z-score Short", message="MA Z-score Short {{exchange}}:{{ticker}}")
````
