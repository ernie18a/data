<!-- tradingview-pine-id: PUB;bf8f6a1ad2884da08ba395083b12ccc0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Eaglizer RSI Cloud

Source: https://www.tradingview.com/script/lRpOa5ZW-Eaglizer-RSI-Cloud/

## Description

Most RSI indicators plot one line that whips around and tells you very little on its own. This plots two moving averages of the RSI instead, and fills the space between them, so you can see the momentum regime rather than the momentum noise.

WHAT IT DOES

It takes RSI 14, then builds two moving averages on top of it. A fast one at 9 and a slow one at 50. The space between them is filled as a cloud.

When the fast average is above the slow one, the cloud is green and momentum is in a bullish regime.
When the fast average is below the slow one, the cloud is red and momentum is in a bearish regime.
A small triangle marks the bar where the cloud flips.

WHY AVERAGE THE RSI AT ALL

Raw RSI reacts to every bar. That is useful for spotting an extreme reading, and useless for telling you what the underlying momentum is actually doing. Averaging the RSI strips out the single bar reactions and leaves the shape of the move.

The 9 and the 50 do different jobs. The fast average is what momentum is doing right now. The slow average is the regime you are trading inside. The gap between them is the part that matters: a wide cloud means momentum is running, a narrow one means it is stalling, and a flip means the regime changed.

HOW I USE IT

I use this as a filter, not as a trigger. I want the cloud on my side before I take a setup in that direction. If I am looking for longs and the cloud is red, I wait.

I trade this mostly on the 4 hour and the daily. On very low timeframes the slow average becomes slow enough to be behind the move.

A flip on its own is not an entry. It is a reason to go look at the chart.

SETTINGS

RSI length, default 14. Fast RSI MA, default 9. Slow RSI MA, default 50. Both averages can be set to SMA or EMA, and SMA is the default because it is steadier.

You can turn on the raw RSI line if you want to see it underneath the cloud. It is off by default because the whole point is to stop staring at it.

Reference levels sit at 70, 50, and 30.

ALERTS

Two alert conditions are included, one for the cloud flipping bullish and one for it flipping bearish. Both carry the ticker and the close price.

WHAT THIS IS NOT

This is not a complete trading system and I am not presenting it as one. It has no entry price, no stop, and no target. It tells you what momentum regime you are in. Everything after that is on you.

The full system I trade adds pivot breakout boxes, an EMA 89, a higher timeframe EMA 34, a volume filter, and defined stop and target rules. If you want it, the link is on my profile.

DISCLAIMER

This is a technical analysis tool for education and research. It is not financial advice, it is not a recommendation to buy or sell anything, and past behavior of any indicator does not predict future results. Trading involves risk of loss. Size your positions accordingly and do your own work.

---

## Source Code

````pine
//@version=6
indicator("Eaglizer RSI Cloud", shorttitle="RSI Cloud", overlay=false)

// INPUTS

grpRSI   = "RSI"
grpCloud = "Cloud"
grpViz   = "Display"

rsiLen = input.int(14, "RSI Length", minval=1, group=grpRSI, tooltip="Length of the underlying RSI. Default 14.")
rsiSrc = input.source(close, "Source", group=grpRSI)

fastLen = input.int(9,  "Fast RSI MA", minval=1, group=grpCloud, tooltip="Short moving average of the RSI. This is momentum right now.")
slowLen = input.int(50, "Slow RSI MA", minval=1, group=grpCloud, tooltip="Long moving average of the RSI. This is the momentum regime.")
maType  = input.string("SMA", "MA Type", options=["SMA", "EMA"], group=grpCloud)

showRaw = input.bool(false, "Show raw RSI line", group=grpViz)
colBull = input.color(color.new(color.green, 75), "Bullish cloud", group=grpViz)
colBear = input.color(color.new(color.red,   75), "Bearish cloud", group=grpViz)

// CALCULATIONS

rsiVal = ta.rsi(rsiSrc, rsiLen)

// Both averages are computed every bar and then selected, rather than calling
// one inside a ternary. Pine evaluates ta functions on every bar regardless,
// so this avoids inconsistent series behavior.
pickMA(src, length) =>
    e = ta.ema(src, length)
    s = ta.sma(src, length)
    maType == "EMA" ? e : s

fastMA = pickMA(rsiVal, fastLen)
slowMA = pickMA(rsiVal, slowLen)

bullish  = fastMA > slowMA
flipUp   = ta.crossover(fastMA, slowMA)
flipDown = ta.crossunder(fastMA, slowMA)

// PLOTS

pFast = plot(fastMA, title="Fast RSI MA", color=color.new(color.aqua,   0), linewidth=2)
pSlow = plot(slowMA, title="Slow RSI MA", color=color.new(color.orange, 0), linewidth=2)
fill(pFast, pSlow, color=bullish ? colBull : colBear, title="RSI Cloud")

plot(showRaw ? rsiVal : na, title="RSI", color=color.new(color.gray, 40), linewidth=1)

hline(70, "Overbought", color=color.new(color.gray, 60), linestyle=hline.style_dashed)
hline(50, "Midline",    color=color.new(color.gray, 40), linestyle=hline.style_dotted)
hline(30, "Oversold",   color=color.new(color.gray, 60), linestyle=hline.style_dashed)

plotshape(flipUp,   title="Cloud flips up",   location=location.bottom, color=color.green, style=shape.triangleup,   size=size.tiny)
plotshape(flipDown, title="Cloud flips down", location=location.top,    color=color.red,   style=shape.triangledown, size=size.tiny)

// ALERTS

alertcondition(flipUp,   title="Cloud flips bullish", message="Eaglizer RSI Cloud: momentum flipped bullish on {{ticker}} at {{close}}")
alertcondition(flipDown, title="Cloud flips bearish", message="Eaglizer RSI Cloud: momentum flipped bearish on {{ticker}} at {{close}}")
````
