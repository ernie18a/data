<!-- tradingview-pine-id: PUB;be1dd402b68f41de8052e146f100693b -->
<!-- tradingviewscripts-format: 1 -->
# 4H Liquidity Sweep + Close-Through Signal

Source: https://www.tradingview.com/script/zQW6UI9M-4H-Liquidity-Sweep-Close-Through-Signal/

## Description

Signals when a 4h candle takes out the low/high of previous candle and closes above high/low of previous candle.

---

## Source Code

````pine
//@version=6
indicator("4H Liquidity Sweep + Close-Through Signal", overlay=true, max_labels_count=500)

// ============================================================================
// LOGIC
// BUY  : current 4H candle wicks BELOW previous 4H low (sweep) then CLOSES
//        ABOVE the previous 4H high.
// SELL : current 4H candle wicks ABOVE previous 4H high (sweep) then CLOSES
//        BELOW the previous 4H low.
//
// Works on ANY chart timeframe — it pulls 4H data via request.security using
// the offset+lookahead_on trick, which only ever reads CLOSED 4H bars, so it
// does not repaint. Signals appear the moment the relevant 4H bar has fully
// closed (i.e. on the first chart bar after that 4H close).
// ============================================================================

htf = input.timeframe("240", "Higher Timeframe", tooltip="Default = 4 hours (240 minutes)")
showLabels   = input.bool(true, "Show Buy/Sell Labels")
showLevels   = input.bool(true, "Plot Previous 4H High/Low")
onlyOnePerBar = input.bool(true, "Fire signal only once per new 4H candle")

// --- Pull HTF OHLC using the non-repainting offset trick ---
// [1] offset = the most recently CLOSED htf bar
// [2] offset = the htf bar before that (the "previous" one we compare against)
curHigh  = request.security(syminfo.tickerid, htf, high[1],  lookahead = barmerge.lookahead_on)
curLow   = request.security(syminfo.tickerid, htf, low[1],   lookahead = barmerge.lookahead_on)
curClose = request.security(syminfo.tickerid, htf, close[1], lookahead = barmerge.lookahead_on)
curTime  = request.security(syminfo.tickerid, htf, time[1],  lookahead = barmerge.lookahead_on)

prevHigh = request.security(syminfo.tickerid, htf, high[2],  lookahead = barmerge.lookahead_on)
prevLow  = request.security(syminfo.tickerid, htf, low[2],   lookahead = barmerge.lookahead_on)

// --- Detect when a NEW 4H bar has just closed (so we don't fire the same signal on every chart bar) ---
var float lastSignalTime = na
isNewHtfBar = ta.change(curTime) != 0

// --- Sweep + close-through conditions ---
bullSweep = curLow  < prevLow  and curClose > prevHigh
bearSweep = curHigh > prevHigh and curClose < prevLow

buySignal  = bullSweep and (not onlyOnePerBar or isNewHtfBar)
sellSignal = bearSweep and (not onlyOnePerBar or isNewHtfBar)

// avoid duplicate firing across multiple chart bars belonging to the same 4H bar
buyFire  = buySignal  and (na(lastSignalTime) or curTime != lastSignalTime)
sellFire = sellSignal and (na(lastSignalTime) or curTime != lastSignalTime)

if buyFire or sellFire
    lastSignalTime := curTime

// ============================================================================
// PLOTTING
// ============================================================================
plotshape(buyFire,  title="Buy Signal",  location=location.belowbar,
     style=shape.labelup, color=color.new(color.green, 0), text="BUY",
     textcolor=color.white, size=size.small)

plotshape(sellFire, title="Sell Signal", location=location.abovebar,
     style=shape.labeldown, color=color.new(color.red, 0), text="SELL",
     textcolor=color.white, size=size.small)

plot(showLevels ? prevHigh : na, title="Prev 4H High", color=color.new(color.gray, 40), style=plot.style_circles)
plot(showLevels ? prevLow  : na, title="Prev 4H Low",  color=color.new(color.gray, 40), style=plot.style_circles)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(buyFire,  title="4H Bull Sweep + Close Above",  message="4H BUY: swept prior low, closed above prior high on {{ticker}}")
alertcondition(sellFire, title="4H Bear Sweep + Close Below",  message="4H SELL: swept prior high, closed below prior low on {{ticker}}")
````
