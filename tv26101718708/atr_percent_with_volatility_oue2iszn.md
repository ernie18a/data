# ATR Percent with Volatility

- url: https://www.tradingview.com/script/OUE2iSzn-ATR-Percent-with-Volatility/
- type: indicator
- pine_id: PUB;efdc422389cd45e2a533e0bf66df18c7
- version: 1.0

## Description

This is the ATR % Indicator based on Volatility based market condition under "Market Classification System".

Volatility condition description -
Volatile: Today's ATR% is > 1 standard deviation higher than the average ATR% of the last 100 days. (Avoid taking Long Entry) 
Normal: Today's ATR% is within +1/-1 standard deviation of the average ATR% of the last 100 days. (Good for taking Long Entry) 
Quiet: Today's ATR% is < 1 standard deviation less than the average ATR% of the last 100 days. (Best for taking Long Entry) 

To hide labels of Volatile, Normal, Quiet;
Uncheck ☑ Pane labels under Style tab.

## Source Code

````pine
//@version=6
indicator("ATR% with Volatility", shorttitle="ATR%Vol", overlay=false)

// Inputs
atrLen    = input.int(14,    "ATR Length",         minval=1)
smoothing = input.string("RMA", "Smoothing",          options=["RMA", "SMA", "EMA", "WMA"])
lookback  = input.int(100,   "Lookback Period (SD)", minval=10)

// ATR smoothing
ma(src, len) =>
    switch smoothing
        "RMA" => ta.rma(src, len)
        "SMA" => ta.sma(src, len)
        "EMA" => ta.ema(src, len)
        =>       ta.wma(src, len)

// ATR%
atrRaw = ma(ta.tr(true), atrLen)
atrPct = (atrRaw / close) * 100.0

// Rolling stats over lookback bars
avgAtr    = ta.sma(atrPct, lookback)
stdAtr    = ta.stdev(atrPct, lookback)
upperBand = avgAtr + stdAtr
lowerBand = avgAtr - stdAtr

// Regime flags
isVolatile = atrPct > upperBand
isQuiet    = atrPct < lowerBand

// Colors (single-line ternaries — avoids CE10156)
barColor = isVolatile ? color.new(color.orange, 0) : isQuiet ? color.new(color.blue, 0) : color.new(color.teal, 0)
bgColor  = isVolatile ? color.new(color.orange, 88) : isQuiet ? color.new(color.blue, 90) : color.new(color.teal, 95)

// Plots
plot(atrPct,    "ATR %",    color=barColor,                          linewidth=2)
plot(upperBand, "+1 SD",    color=color.new(color.orange, 30),       linewidth=1)
plot(lowerBand, "-1 SD",    color=color.new(color.blue,   30),       linewidth=1)
plot(avgAtr,    "Avg ATR%", color=color.new(color.gray,   40),       linewidth=1)

// Band fill
pUp = plot(upperBand, display=display.none)
pDn = plot(lowerBand, display=display.none)
fill(pUp, pDn, color.new(color.gray, 90), "Normal zone")

// Background
bgcolor(bgColor)

// Label on regime change only
stateChange = ta.change(isVolatile) or ta.change(isQuiet)

if stateChange
    lbl = isVolatile ? "VOLATILE" : isQuiet ? "QUIET" : "NORMAL"
    lc  = isVolatile ? color.orange : isQuiet ? color.blue : color.teal
    label.new(bar_index, atrPct, text=lbl, color=color.new(lc, 80), textcolor=lc, style=label.style_label_up, size=size.small)

// Alerts
alertcondition(isVolatile and not isVolatile[1], "Volatile regime started", "ATR% crossed above +1 SD")
alertcondition(isQuiet    and not isQuiet[1],    "Quiet regime started",    "ATR% dropped below -1 SD")
````
