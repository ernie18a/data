<!-- tradingview-pine-id: PUB;a7a3f05cd29e4fc29c58f489c946fae4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PIPSHUSTLE GOLD OPTION FLOW DEALER STRATEGY

Source: https://www.tradingview.com/script/rT2zQEcQ-PIPSHUSTLE-GOLD-OPTION-FLOW-DEALER/

## Description

The **PIPSHUSTLE Gold Dealer Flow Indicator** is a liquidity-and-volume-based trading indicator designed specifically for **Gold (XAUUSD)**. Its purpose is to identify areas where price may be trapping traders, reacting to liquidity, or showing signs of stronger institutional-style activity.

The indicator focuses on six main components:

* **Sweep Trap Zone:** Detects when Gold runs above a previous high or below a previous low, then closes back inside the level. This can indicate a liquidity grab or false breakout. Bullish sweep traps form below previous lows, while bearish sweep traps form above previous highs.

* **Active Dealers Zone:** A dynamic area around VWAP that uses ATR and relative volume to highlight periods where trading activity is unusually strong. This is intended to act as a proxy for areas where larger market participants may be most active.

* **Reclaim Pivot:** Marks the key price level that was swept and then reclaimed. A bullish reclaim pivot appears after downside liquidity is taken and price closes back above the level. A bearish reclaim pivot appears after upside liquidity is taken and price falls back below it.

* **Main Dealer Ceiling:** A dynamic resistance level created from important upper-side liquidity sweeps and rejection points. If Gold repeatedly fails around this area, it can act as a major resistance or potential SELL zone.

* **Main Dealer Floor:** The bullish equivalent of the Dealer Ceiling. It tracks important lower-side liquidity sweeps and reclaim points, acting as a potential support or BUY zone.

* **BUY / SELL Signals:** The indicator does not generate a signal from a liquidity sweep alone. It combines several conditions such as liquidity sweep, reclaim, VWAP position, volume, EMA trend, displacement, and dealer-zone activity. A signal is printed only after enough conditions align.

A typical **BUY setup** is:

**Sell-side liquidity sweep → bullish trap → reclaim pivot → Dealer Floor holds → price confirms above VWAP → BUY**

A typical **SELL setup** is:

**Buy-side liquidity sweep → bearish trap → Dealer Ceiling rejection → reclaim pivot fails → price confirms below VWAP → SELL**

The signal system also uses a **confirmation score**, allowing stronger setups to require more conditions before a BUY or SELL appears.

It is best viewed as a **dealer-flow/liquidity proxy indicator**, not a true institutional options-feed indicator. Pine Script does not directly provide dealer gamma positioning or full options order-flow data, so the indicator estimates these areas using price action, liquidity behavior, VWAP, volatility and volume.

---

## Source Code

````pine
//@version=6
indicator("PIPSHUSTLE GOLD OPTION FLOW DEALER STRATEGY", overlay=true, max_boxes_count=200, max_lines_count=200, max_labels_count=200)

//====================================================
// INPUTS
//====================================================

groupLiquidity = "Liquidity Sweep Settings"
sweepLookback = input.int(20, "Liquidity Sweep Lookback", minval=5, group=groupLiquidity)
trapLength = input.int(10, "Sweep Trap Zone Length", minval=1, group=groupLiquidity)

groupDealer = "Dealer Flow Settings"
atrLength = input.int(14, "ATR Length", minval=1, group=groupDealer)
volumeLength = input.int(20, "Volume Average Length", minval=5, group=groupDealer)
volumeMultiplier = input.float(1.30, "Active Dealer Volume Multiplier", minval=0.1, step=0.05, group=groupDealer)
dealerZoneATR = input.float(0.40, "Active Dealer Zone ATR Width", minval=0.05, step=0.05, group=groupDealer)

groupTrend = "Trend Filter"
fastEMALength = input.int(50, "Fast EMA", minval=1, group=groupTrend)
slowEMALength = input.int(200, "Slow EMA", minval=1, group=groupTrend)
useTrendFilter = input.bool(true, "Use EMA Trend Filter", group=groupTrend)

groupSignals = "BUY / SELL Settings"
minimumScore = input.int(4, "Minimum Signal Score", minval=2, maxval=7, group=groupSignals)
cooldownBars = input.int(5, "Signal Cooldown Bars", minval=0, group=groupSignals)
showSignals = input.bool(true, "Show BUY / SELL Signals", group=groupSignals)
showSignalDetails = input.bool(true, "Show Signal Score Labels", group=groupSignals)

groupDisplay = "Display Settings"
showSweepZones = input.bool(true, "Show Sweep Trap Zones", group=groupDisplay)
showSweepMarkers = input.bool(true, "Show Sweep Markers", group=groupDisplay)
showDealerZone = input.bool(true, "Show Active Dealer Zone", group=groupDisplay)
showDealerLevels = input.bool(true, "Show Dealer Ceiling / Floor", group=groupDisplay)
showReclaimPivot = input.bool(true, "Show Reclaim Pivot", group=groupDisplay)
showVWAP = input.bool(true, "Show Dealer VWAP", group=groupDisplay)
showEMA = input.bool(true, "Show EMA 50 / 200", group=groupDisplay)
showDealerBackground = input.bool(true, "Highlight Active Dealer Activity", group=groupDisplay)

//====================================================
// CORE CALCULATIONS
//====================================================

atr = ta.atr(atrLength)
avgVolume = ta.sma(volume, volumeLength)

emaFast = ta.ema(close, fastEMALength)
emaSlow = ta.ema(close, slowEMALength)

vwapValue = ta.vwap(hlc3)

bullTrend = emaFast > emaSlow
bearTrend = emaFast < emaSlow

highVolume = volume > avgVolume * volumeMultiplier

previousLiquidityHigh = ta.highest(high[1], sweepLookback)
previousLiquidityLow = ta.lowest(low[1], sweepLookback)

//====================================================
// CANDLE CONDITIONS
//====================================================

bullishCandle = close > open
bearishCandle = close < open

bodySize = math.abs(close - open)

bullDisplacement = bullishCandle and bodySize > atr * 0.40
bearDisplacement = bearishCandle and bodySize > atr * 0.40

//====================================================
// LIQUIDITY SWEEPS
//====================================================

// Sweep below previous lows and close back above.
bullishSweep = not na(previousLiquidityLow) and low < previousLiquidityLow and close > previousLiquidityLow

// Sweep above previous highs and close back below.
bearishSweep = not na(previousLiquidityHigh) and high > previousLiquidityHigh and close < previousLiquidityHigh

bullSweepTrap = bullishSweep and bullishCandle
bearSweepTrap = bearishSweep and bearishCandle

//====================================================
// SWEEP TRAP ZONES
//====================================================

if showSweepZones and bullSweepTrap
    box.new(left=bar_index, top=previousLiquidityLow, right=bar_index + trapLength, bottom=low, border_color=color.new(color.lime, 10), bgcolor=color.new(color.lime, 85))

if showSweepZones and bearSweepTrap
    box.new(left=bar_index, top=high, right=bar_index + trapLength, bottom=previousLiquidityHigh, border_color=color.new(color.red, 10), bgcolor=color.new(color.red, 85))

//====================================================
// ACTIVE DEALER ZONE
//====================================================

dealerUpper = vwapValue + atr * dealerZoneATR
dealerLower = vwapValue - atr * dealerZoneATR

insideDealerZone = close <= dealerUpper and close >= dealerLower
activeDealer = highVolume and insideDealerZone

dealerUpperPlot = plot(showDealerZone ? dealerUpper : na, title="Active Dealer Zone High", color=color.new(color.orange, 45), linewidth=1)
dealerLowerPlot = plot(showDealerZone ? dealerLower : na, title="Active Dealer Zone Low", color=color.new(color.orange, 45), linewidth=1)

fill(dealerUpperPlot, dealerLowerPlot, color=showDealerZone ? color.new(color.orange, 90) : na, title="Active Dealers Zone")

//====================================================
// MAIN DEALER CEILING / FLOOR
//====================================================

var float mainDealerCeiling = na
var float mainDealerFloor = na

if bearSweepTrap
    mainDealerCeiling := high

if bullSweepTrap
    mainDealerFloor := low

plot(showDealerLevels ? mainDealerCeiling : na, title="Main Dealer Ceiling", color=color.red, linewidth=2, style=plot.style_stepline)
plot(showDealerLevels ? mainDealerFloor : na, title="Main Dealer Floor", color=color.lime, linewidth=2, style=plot.style_stepline)

//====================================================
// RECLAIM PIVOT
//====================================================

var float reclaimPivot = na
var int reclaimDirection = 0

bullReclaim = bullishSweep and bullishCandle and close > previousLiquidityLow
bearReclaim = bearishSweep and bearishCandle and close < previousLiquidityHigh

if bullReclaim
    reclaimPivot := previousLiquidityLow
    reclaimDirection := 1

if bearReclaim
    reclaimPivot := previousLiquidityHigh
    reclaimDirection := -1

color reclaimColor = color.gray

if reclaimDirection == 1
    reclaimColor := color.aqua
else if reclaimDirection == -1
    reclaimColor := color.fuchsia
else
    reclaimColor := color.gray

plot(showReclaimPivot ? reclaimPivot : na, title="Reclaim Pivot", color=reclaimColor, linewidth=2, style=plot.style_stepline)

//====================================================
// DEALER FLOW BIAS
//====================================================

aboveVWAP = close > vwapValue
belowVWAP = close < vwapValue

bullDealerFlow = aboveVWAP and close > emaFast
bearDealerFlow = belowVWAP and close < emaFast

//====================================================
// SIGNAL SCORES
//====================================================

bullScore = 0
bullScore += bullishSweep ? 1 : 0
bullScore += bullReclaim ? 1 : 0
bullScore += bullDealerFlow ? 1 : 0
bullScore += highVolume ? 1 : 0
bullScore += bullTrend ? 1 : 0
bullScore += bullDisplacement ? 1 : 0
bullScore += activeDealer ? 1 : 0

bearScore = 0
bearScore += bearishSweep ? 1 : 0
bearScore += bearReclaim ? 1 : 0
bearScore += bearDealerFlow ? 1 : 0
bearScore += highVolume ? 1 : 0
bearScore += bearTrend ? 1 : 0
bearScore += bearDisplacement ? 1 : 0
bearScore += activeDealer ? 1 : 0

//====================================================
// TREND FILTER
//====================================================

bullTrendOK = not useTrendFilter or bullTrend
bearTrendOK = not useTrendFilter or bearTrend

//====================================================
// RAW BUY / SELL CONDITIONS
//====================================================

rawBuySignal = bullishSweep and bullReclaim and bullScore >= minimumScore and bullTrendOK
rawSellSignal = bearishSweep and bearReclaim and bearScore >= minimumScore and bearTrendOK

//====================================================
// SIGNAL COOLDOWN
//====================================================

var int lastBuyBar = na
var int lastSellBar = na

buyCooldownOK = na(lastBuyBar) or bar_index - lastBuyBar > cooldownBars
sellCooldownOK = na(lastSellBar) or bar_index - lastSellBar > cooldownBars

buySignal = rawBuySignal and buyCooldownOK and barstate.isconfirmed
sellSignal = rawSellSignal and sellCooldownOK and barstate.isconfirmed

if buySignal
    lastBuyBar := bar_index

if sellSignal
    lastSellBar := bar_index

//====================================================
// BUY / SELL SIGNALS
//====================================================

plotshape(showSignals and buySignal, title="GOLD BUY", style=shape.labelup, location=location.belowbar, text="BUY", color=color.lime, textcolor=color.black, size=size.normal)
plotshape(showSignals and sellSignal, title="GOLD SELL", style=shape.labeldown, location=location.abovebar, text="SELL", color=color.red, textcolor=color.white, size=size.normal)

//====================================================
// SWEEP MARKERS
//====================================================

plotshape(showSweepMarkers and bullishSweep, title="Sell-Side Sweep", style=shape.circle, location=location.belowbar, text="SWP", color=color.aqua, textcolor=color.black, size=size.tiny)
plotshape(showSweepMarkers and bearishSweep, title="Buy-Side Sweep", style=shape.circle, location=location.abovebar, text="SWP", color=color.orange, textcolor=color.black, size=size.tiny)

//====================================================
// VWAP AND EMAs
//====================================================

plot(showVWAP ? vwapValue : na, title="Dealer VWAP", color=color.yellow, linewidth=2)
plot(showEMA ? emaFast : na, title="Fast EMA", color=color.blue, linewidth=1)
plot(showEMA ? emaSlow : na, title="Slow EMA", color=color.purple, linewidth=2)

//====================================================
// ACTIVE DEALER BACKGROUND
//====================================================

bgcolor(showDealerBackground and activeDealer ? color.new(color.orange, 92) : na, title="Active Dealer Activity")

//====================================================
// SIGNAL DETAILS
//====================================================

if showSignalDetails and buySignal
    label.new(bar_index, low - atr * 0.30, "BUY\nScore: " + str.tostring(bullScore) + "/7", style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.small)

if showSignalDetails and sellSignal
    label.new(bar_index, high + atr * 0.30, "SELL\nScore: " + str.tostring(bearScore) + "/7", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

//====================================================
// DEALER LEVEL BREAKS
//====================================================

ceilingBreak = not na(mainDealerCeiling) and ta.crossover(close, mainDealerCeiling)
floorBreak = not na(mainDealerFloor) and ta.crossunder(close, mainDealerFloor)

//====================================================
// ALERTS
//====================================================

alertcondition(buySignal, title="PIPSHUSTLE GOLD BUY", message="PIPSHUSTLE GOLD DEALER FLOW BUY SIGNAL")
alertcondition(sellSignal, title="PIPSHUSTLE GOLD SELL", message="PIPSHUSTLE GOLD DEALER FLOW SELL SIGNAL")
alertcondition(bullishSweep, title="Gold Sell-Side Liquidity Sweep", message="Gold swept sell-side liquidity and reclaimed the level.")
alertcondition(bearishSweep, title="Gold Buy-Side Liquidity Sweep", message="Gold swept buy-side liquidity and rejected the level.")
alertcondition(ceilingBreak, title="Main Dealer Ceiling Break", message="Gold has broken above the Main Dealer Ceiling.")
alertcondition(floorBreak, title="Main Dealer Floor Break", message="Gold has broken below the Main Dealer Floor.")
````
