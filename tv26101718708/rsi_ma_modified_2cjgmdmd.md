# RSI + MA Modified

- url: https://www.tradingview.com/script/2cJGmdmD-RSI-MA-Modified/
- type: indicator
- pine_id: PUB;277c442be1504f369c4a6582b64c34ce
- version: 1.0

## Description

The original indicator has been modified to speed up the sensitivity of the RSI (new default is 9 SMA periods) and to use a 19 EMA as the trigger line. Background fill has been added to highlight when the RSI is greater than the trigger (green fill), and when the RSI is less than its trigger (red fill). The changes modify the focus of the indicator, typically used as an 'Overbought' / "Oversold' indicator when the RSI is above 70 or below 30, to a focus on when the RSI has changed its Trend by going above or below 50.
Much as the Bolliinger Bands use 20 as the Basis for recognizing the change in direction of a trend, this modified RSI + MA indicator uses the 9 SMA changing from below to above 50, or above to below 50 as the identification of Trend direction changing.

## Source Code

````pine
//@version=6
indicator(
    title      = "RSI + MA",
    shorttitle = "RSI+MA",
    overlay    = false,
    format     = format.price,
    precision  = 2
)

// === RSI Settings ===
rsiLen = input.int(14, "RSI Length")
src    = input.source(close, "Source")

change = ta.change(src)
up     = ta.rma(math.max(change, 0), rsiLen)
down   = ta.rma(-math.min(change, 0), rsiLen)
rsi    = down == 0 ? 100 : up == 0 ? 0 : 100 - (100 / (1 + up / down))

// === MA over RSI ===
maType = input.string("SMA", "MA Type", options=["SMA", "EMA", "RMA", "WMA"])
maLen  = input.int(14, "MA Length")

ma(source, length, _type) =>
    switch _type
        "SMA" => ta.sma(source, length)
        "EMA" => ta.ema(source, length)
        "RMA" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)

ma_rsi = ma(rsi, maLen, maType)

// === Plots ===
rsiPlot  = plot(rsi,    "RSI",    color=#F9A825, linewidth=2)
maPlot   = plot(ma_rsi, "RSI MA", color=color.white, linewidth=1)

// === Levels ===
// 80 overbought (checked, solid)
hline(80, "80", color=#787B86, linestyle=hline.style_solid)
// 50 midline (unchecked by default — dotted, greyed out)
hline(50, "50", color=color.new(#787B86, 50), linestyle=hline.style_dotted)
// 20 oversold (checked, solid)
hline(20, "20", color=#787B86, linestyle=hline.style_solid)

// Zero Line at 50 (per style profile)
zeroLine = hline(50,  "Zero Line",  color=color.new(#aaaaaa, 60), linestyle=hline.style_solid)
// Top at 100 (solid gray)
topLine  = hline(100, "Top (100)",  color=#888888, linestyle=hline.style_solid)
// Below Zero anchor at 0 (solid darker gray)
belowLine = hline(0,  "Below Zero", color=#555555, linestyle=hline.style_solid)

// === Zero-Line Fills ===
aboveZeroColor = input.color(color.new(#00cc00, 85), "Fill above 0", group="Zero‑Line Fills")
belowZeroColor = input.color(color.new(#cc0000, 85), "Fill below 0", group="Zero‑Line Fills")

fill(topLine,   zeroLine,  color=aboveZeroColor, title="Above Zero Fill")
fill(zeroLine,  belowLine, color=belowZeroColor, title="Below Zero Fill")

// === RSI vs MA Background Fill ===
colorAbove = input.color(color.new(#00ff00, 70), "Above MA", group="Plots Background")
colorBelow = input.color(color.new(#ff0000, 70), "Below MA",  group="Plots Background")

fill(rsiPlot, maPlot, color=rsi > ma_rsi ? colorAbove : colorBelow, title="Plots Background")
````
