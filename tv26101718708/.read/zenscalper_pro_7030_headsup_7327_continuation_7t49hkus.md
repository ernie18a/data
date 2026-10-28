# ZenScalper Pro 70/30 Heads-Up + 73/27 Continuation

- url: https://www.tradingview.com/script/7T49HKuS-ZenScalper-Pro-70-30-Heads-Up-73-27-Continuation/
- type: indicator
- pine_id: PUB;881bfc469a8b4d2680b4c523cd2e0c62
- version: 1.0

## Description

RSI continuation indicator using 70/30 heads-up levels and 73/27 confirmation levels. Includes volume confirmation, EMA trend filter, watch signals, and customizable RSI coloring.

## Source Code

````pine
//@version=6
indicator("Zen Scalper Pro — 70/30 Heads-Up + 73/27 Continuation", overlay=false, max_labels_count=500, scale=scale.right)

// ========================
// Inputs — core
// ========================
rsiPeriod        = input.int(9,  "RSI Period")
smaPeriod        = input.int(10, "RSI SMA Period")
emaPeriod        = input.int(9,  "Price EMA Filter")
volumeLength     = input.int(20, "Volume SMA Period")
volumeMultiplier = input.float(1.5, "Volume Threshold (x Avg)")

overbought  = input.int(73, "Overbought Threshold")
oversold    = input.int(27, "Oversold Threshold")
headsUpHigh = input.int(70, "Heads-Up High")
headsUpLow  = input.int(30, "Heads-Up Low")

// ========================
// Inputs — styling & toggles
// ========================
useWhiteRSI      = input.bool(false, "Force RSI line to white")
useSmartColor    = input.bool(true,  "Use Smart RSI color")
fadeLowVolColor  = input.bool(true,  "Fade RSI color on weak volume")

showBuySell      = input.bool(true,  "Show BUY / SELL signal balloons")
showHeadsUp      = input.bool(true,  "Show Heads-Up triangles (70/30)")
showWatchSignals = input.bool(true,  "Show early Watch triangles")
useEMAConfirm    = input.bool(true,  "Require price >/< EMA to confirm signals")

rsiColorUp       = input.color(color.lime,   "Color: RSI Up")
rsiColorDown     = input.color(color.red,    "Color: RSI Down")
rsiColorNeutral  = input.color(color.silver, "Color: RSI Neutral")

// ========================
// Calculations
// ========================
rsi     = ta.rsi(close, rsiPeriod)
rsiSMA  = ta.sma(rsi, smaPeriod)
ema     = ta.ema(close, emaPeriod)
volMA   = ta.sma(volume, volumeLength)

volStrong    = volume > volMA
volConfirmed = volume > volMA * volumeMultiplier

rsiRising  = rsi > rsi[1]
rsiFalling = rsi < rsi[1]
priceBull  = close > ema
priceBear  = close < ema

// ========================
// Signal logic
// ========================
confirmBuy  = not useEMAConfirm or priceBull
confirmSell = not useEMAConfirm or priceBear

buySignal  = (rsi > overbought) and rsiRising  and volConfirmed and confirmBuy
sellSignal = (rsi < oversold)   and rsiFalling and volConfirmed and confirmSell

watchBuy   = (rsi > overbought) and rsiRising  and not buySignal
watchSell  = (rsi < oversold)   and rsiFalling and not sellSignal

headsUpBuy  = ta.crossover(rsi, headsUpHigh)
headsUpSell = ta.crossunder(rsi, headsUpLow)

// ========================
// Smart RSI coloring
// ========================
rsiSlope      = rsi - rsi[1]
rsiSlopeWeak  = math.abs(rsiSlope) < 0.3
rsiRangeFlat  = rsi > 44 and rsi < 56
rsiFlat       = rsiSlopeWeak and rsiRangeFlat and not volStrong
breakoutZone  = priceBull or priceBear

rsiColorSmart =
     rsiFlat ? rsiColorNeutral :
     rsiRising  and (volStrong or breakoutZone) ? rsiColorUp :
     rsiFalling and (volStrong or breakoutZone) ? rsiColorDown :
     (fadeLowVolColor ? color.new(rsiColorNeutral, 40) : rsiColorNeutral)

rsiColorStrict =
     volStrong ? (rsiRising ? rsiColorUp : (rsiFalling ? rsiColorDown : rsiColorNeutral))
               : (fadeLowVolColor ? color.new(rsiColorNeutral, 40) : rsiColorNeutral)

rsiColor = useWhiteRSI ? color.white : (useSmartColor ? rsiColorSmart : rsiColorStrict)

// ========================
// Plots
// ========================
plotRSI = plot(rsi, title="RSI", color=rsiColor, linewidth=2)
plot(rsiSMA, title="RSI SMA", color=color.gray)

hline(overbought, "Overbought", color=color.gray)
hline(oversold,   "Oversold",   color=color.gray)
hline(50,         "Midline",    color=color.gray, linestyle=hline.style_dotted)

// Zone shading
plotTop    = plot(overbought, display=display.none)
plotBottom = plot(oversold,   display=display.none)
fill(plotTop,    plotRSI, color = (rsi > overbought and volStrong) ? color.new(rsiColorUp,   85) : na)
fill(plotBottom, plotRSI, color = (rsi < oversold   and volStrong) ? color.new(rsiColorDown, 85) : na)

// ========================
// Markers (same behavior as before)
// ========================

// BUY / SELL balloons
plotshape(showBuySell and buySignal,  title="BUY",  location=location.bottom,
     style=shape.labelup, text="BUY", color=color.green, textcolor=color.white, size=size.tiny)

plotshape(showBuySell and sellSignal, title="SELL", location=location.top,
     style=shape.labeldown, text="SELL", color=color.maroon, textcolor=color.white, size=size.tiny)

// Watch triangles (lighter)
plotshape(showWatchSignals and watchBuy,  title="Watch BUY",  location=location.bottom,
     style=shape.triangleup, color=color.new(color.green, 30), size=size.tiny)

plotshape(showWatchSignals and watchSell, title="Watch SELL", location=location.top,
     style=shape.triangledown, color=color.new(color.red, 30), size=size.tiny)

// Heads-Up triangles (darker)
plotshape(showHeadsUp and headsUpBuy,  title="Heads-Up BUY",  location=location.bottom,
     style=shape.triangleup, color=color.new(color.lime, 0), size=size.tiny)

plotshape(showHeadsUp and headsUpSell, title="Heads-Up SELL", location=location.top,
     style=shape.triangledown, color=color.new(color.red, 0), size=size.tiny)

// ========================
// Alerts
// ========================
alertcondition(buySignal, title="BUY Alert", message="RSI Scalper BUY Confirmed: RSI > 73 and rising")

alertcondition(sellSignal, title="SELL Alert", message="RSI Scalper SELL Confirmed: RSI < 27 and falling")

alertcondition(showHeadsUp and headsUpBuy, title="Heads-Up BUY (70)", message="RSI crossed above 70")

alertcondition(showHeadsUp and headsUpSell, title="Heads-Up SELL (30)", message="RSI crossed below 30")
````
