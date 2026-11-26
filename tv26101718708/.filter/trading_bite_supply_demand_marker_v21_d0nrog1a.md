# TRADING BITE Supply Demand Marker V2.1

- url: https://www.tradingview.com/script/d0nRog1A-TRADING-BITE-Supply-Demand-Marker-V2-1/
- type: indicator
- pine_id: PUB;53bb4355c52b43bdbe38de1486a95787
- version: 1.0

## Description

This Indicator Automatically identifies key supply and demand candles and highlights potential reversal zones. Integrated volume analysis validates market moves, helping traders make more informed entry and exit decisions. Perfect for spotting high-probability trades and understanding market structure at a glance.

[b]Features:[/b]

[list]
[*]Highlights Supply & Demand zones automatically
[*]Marks key reversal candles
[*]Volume-based validation for stronger signals
[*]Easy-to-read visual alerts for trading decisions
[/list]
[b]
Disclaimer / No Liability Notice:[/b]
This indicator is provided for educational and informational purposes only. It does not guarantee profits or predict future market movements. Trading financial instruments involves substantial risk of loss, and you should only trade with money you can afford to lose.

By using this indicator, you acknowledge that you assume full responsibility for any trading decisions made based on its signals. The developer accepts no liability for any losses, damages, or financial consequences that may result from using this tool.

Always perform your own analysis and consider consulting a licensed financial advisor before making trading decisions. Past performance is not indicative of future results.

## Source Code

````pine
//@version=6
indicator("TRADING BITE Supply Demand Marker V2.1", overlay=false)
// === TRADING BITE ===
// === Version:2.1 ===

// === To identify Supply and Demand Volume bars ===
// === Option to customize Color of Candles  ===
// === Option to customize size of Text on Volume Bars  ===
// === Option to customize Color of Volume Bars  ===


// === INPUTS ===
tf = input.timeframe("", "Volume Analysis Timeframe (leave blank for chart TF)")
bullColor = input.color(color.green, "Bullish Signal Color")
bearColor = input.color(color.red, "Bearish Signal Color")
neutralOverrideColor = input.color(color.gray, "Neutral Volume Bar Color Override (Optional)")
useNeutralOverride = input.bool(false, "Override Neutral Volume Bar Color?")

textSizeInput = input.string("small", "Text Size", options=["tiny", "small", "normal", "large", "huge"])
textColor = input.color(color.white, "Text Color")

enableCandleColor = input.bool(true, "Enable Candle Color Change Based on Volume")

// === FETCH VOLUME & PRICE DATA ===
vol = request.security(syminfo.tickerid, tf, volume)
close_ = request.security(syminfo.tickerid, tf, close)
open_ = request.security(syminfo.tickerid, tf, open)
vol1 = request.security(syminfo.tickerid, tf, volume[1])
vol2 = request.security(syminfo.tickerid, tf, volume[2])

// === LOGIC ===
isBull = close_ > open_
isBear = close_ < open_
volLowerThanPrev2 = vol < vol1 and vol < vol2
showS = isBull and volLowerThanPrev2
showD = isBear and volLowerThanPrev2

// === VOLUME PLOT ===
neutralVolColor = useNeutralOverride ? neutralOverrideColor : isBull ? color.green : isBear ? color.red : color.gray
volColor = showS ? bullColor : showD ? bearColor : neutralVolColor
plot(vol, style=plot.style_columns, color=volColor, title="Volume")

// === CANDLE COLORING BASED ON VOLUME SIGNAL ===
candleColor = enableCandleColor ? (showS ? bullColor : showD ? bearColor : na) : na
barcolor(candleColor)

// === TEXT MARKERS “S” and “D” — with size-specific plotchar ===
plotchar(showS and textSizeInput == "tiny", title="S tiny", char='S', location=location.top, color=textColor, size=size.tiny)
plotchar(showS and textSizeInput == "small", title="S small", char='S', location=location.top, color=textColor, size=size.small)
plotchar(showS and textSizeInput == "normal", title="S normal", char='S', location=location.top, color=textColor, size=size.normal)
plotchar(showS and textSizeInput == "large", title="S large", char='S', location=location.top, color=textColor, size=size.large)
plotchar(showS and textSizeInput == "huge", title="S huge", char='S', location=location.top, color=textColor, size=size.huge)

plotchar(showD and textSizeInput == "tiny", title="D tiny", char='D', location=location.top, color=textColor, size=size.tiny)
plotchar(showD and textSizeInput == "small", title="D small", char='D', location=location.top, color=textColor, size=size.small)
plotchar(showD and textSizeInput == "normal", title="D normal", char='D', location=location.top, color=textColor, size=size.normal)
plotchar(showD and textSizeInput == "large", title="D large", char='D', location=location.top, color=textColor, size=size.large)
plotchar(showD and textSizeInput == "huge", title="D huge", char='D', location=location.top, color=textColor, size=size.huge)


// === TRADING BITE ===
````
