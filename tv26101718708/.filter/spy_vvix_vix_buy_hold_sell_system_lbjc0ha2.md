# SPY VVIX VIX Buy Hold Sell System

- url: https://www.tradingview.com/script/lbjC0hA2-SPY-VVIX-VIX-Buy-Hold-Sell-System/
- type: indicator
- pine_id: PUB;ec0a178267d74e05ba9344cfe20788fc
- version: 2.0

## Description

Following changes are made:
DEFEND = BLUE (table)
Keeps SELL = RED (aggressive exit)
DEFEND now visually = risk management mode

## Source Code

````pine
//@version=5
indicator("NetJay_SPY VVIX VIX Buy Hold Sell System", shorttitle="SPY VVIX BHS", overlay=true)

//====================================================================================
// SPY VVIX VIX Buy Hold Sell System
//====================================================================================

//----------------------------------------------------
// Inputs
//----------------------------------------------------
src = input.source(close, "SPY Source")

vvixSymbol = input.symbol("CBOE:VVIX", "VVIX Symbol")
vixSymbol  = input.symbol("CBOE:VIX", "VIX Symbol")
riskTF     = input.timeframe("60", "VVIX/VIX Timeframe")

vvixCaution = input.float(100.0, "VVIX Caution Level")
vvixDanger  = input.float(110.0, "VVIX Danger Level")
vvixPanic   = input.float(120.0, "VVIX Panic Level")

vvixEmaLen = input.int(10, "VVIX EMA Length", minval=1)
vixEmaLen  = input.int(10, "VIX EMA Length", minval=1)

trendEmaLen = input.int(50, "SPY Trend EMA", minval=1)

rangePeriod = input.int(100, "Range Filter Period", minval=1)
rangeMult   = input.float(3.0, "Range Multiplier", minval=0.1)

showDashboard = input.bool(true, "Show Dashboard")
showActionGuide = input.bool(true, "Show Compact Action Guide")
showHoldLabels = input.bool(false, "Show HOLD Labels")

//----------------------------------------------------
// VVIX and VIX Data
//----------------------------------------------------
vvix = request.security(vvixSymbol, riskTF, close)
vix  = request.security(vixSymbol, riskTF, close)

vvixEma = ta.ema(vvix, vvixEmaLen)
vixEma  = ta.ema(vix, vixEmaLen)

vvixRising  = vvix > vvixEma and vvix > vvix[1]
vvixFalling = vvix < vvixEma and vvix < vvix[1]

vixRising  = vix > vixEma and vix > vix[1]
vixFalling = vix < vixEma and vix < vix[1]

//----------------------------------------------------
// SPY Trend
//----------------------------------------------------
spyEma = ta.ema(src, trendEmaLen)

spyBullTrend = src > spyEma
spyBearTrend = src < spyEma

//----------------------------------------------------
// Range Filter
//----------------------------------------------------
smoothrng(x, t, m) =>
    wper = t * 2 - 1
    avrng = ta.ema(math.abs(x - x[1]), t)
    ta.ema(avrng, wper) * m

smrng = smoothrng(src, rangePeriod, rangeMult)

rngfilt(x, r) =>
    filtValue = x
    filtValue := x > nz(filtValue[1]) ? x - r < nz(filtValue[1]) ? nz(filtValue[1]) : x - r : x + r > nz(filtValue[1]) ? nz(filtValue[1]) : x + r
    filtValue

filt = rngfilt(src, smrng)

upward = 0.0
upward := filt > filt[1] ? nz(upward[1]) + 1 : filt < filt[1] ? 0 : nz(upward[1])

downward = 0.0
downward := filt < filt[1] ? nz(downward[1]) + 1 : filt > filt[1] ? 0 : nz(downward[1])

rangeBull = src > filt and upward > 0
rangeBear = src < filt and downward > 0

//----------------------------------------------------
// VVIX / VIX Risk Regime
//----------------------------------------------------
riskCalm = vvix < vvixCaution and not vixRising
riskDanger = vvix >= vvixDanger
riskPanic = vvix >= vvixPanic

confirmedRisk = vvixRising and vixRising
panicRisk = riskPanic or confirmedRisk

//----------------------------------------------------
// Buy / Hold / Sell Logic
//----------------------------------------------------
buyCondition = spyBullTrend and rangeBull and riskCalm and vvixFalling

holdCondition = spyBullTrend and rangeBull and not panicRisk

sellCondition = panicRisk or (riskDanger and vvixRising) or (spyBearTrend and rangeBear)

// State
state = 0
state := buyCondition ? 1 : sellCondition ? -1 : holdCondition ? 0 : nz(state[1])

buySignal = state == 1 and nz(state[1]) != 1
sellSignal = state == -1 and nz(state[1]) != -1
holdSignal = state == 0 and nz(state[1]) != 0

//----------------------------------------------------
// Colors
//----------------------------------------------------
barCol = state == 1 ? color.green : state == -1 ? color.red : color.yellow
filterCol = rangeBull ? color.green : rangeBear ? color.red : color.gray

//----------------------------------------------------
// Plots
//----------------------------------------------------
plot(filt, "Range Filter", color=filterCol, linewidth=2)
plot(spyEma, "SPY EMA", color=color.orange)

barcolor(barCol)

plotshape(buySignal, "BUY SPY", text="BUY", style=shape.labelup, location=location.belowbar, color=color.green, textcolor=color.white)

plotshape(sellSignal, "SELL / DEFEND", text="SELL / DEFEND", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white)

//----------------------------------------------------
// Dashboard
//----------------------------------------------------
var table dash = table.new(position.bottom_left, 2, 5)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Signal")
    table.cell(dash, 1, 0, state == 1 ? "BUY" : state == -1 ? "SELL / DEFEND" : "HOLD")

    table.cell(dash, 0, 1, "VVIX")
    table.cell(dash, 1, 1, str.tostring(vvix))

    table.cell(dash, 0, 2, "VIX")
    table.cell(dash, 1, 2, str.tostring(vix))

    table.cell(dash, 0, 3, "Trend")
    table.cell(dash, 1, 3, spyBullTrend ? "Bullish" : "Bearish")

    table.cell(dash, 0, 4, "Range")
    table.cell(dash, 1, 4, rangeBull ? "Bullish" : "Bearish")

//----------------------------------------------------
// Action Guide (DEFEND = BLUE)
//----------------------------------------------------
var table guide = table.new(position.bottom_right, 2, 4)

if showActionGuide and barstate.islast
    table.cell(guide, 0, 0, "BUY", bgcolor=color.green, text_color=color.white)
    table.cell(guide, 1, 0, "Go long", bgcolor=color.green, text_color=color.white)

    table.cell(guide, 0, 1, "HOLD", bgcolor=color.yellow, text_color=color.black)
    table.cell(guide, 1, 1, "Keep position", bgcolor=color.yellow, text_color=color.black)

    table.cell(guide, 0, 2, "SELL", bgcolor=color.red, text_color=color.white)
    table.cell(guide, 1, 2, "Exit/reduce", bgcolor=color.red, text_color=color.white)

    table.cell(guide, 0, 3, "DEFEND", bgcolor=color.blue, text_color=color.white)
    table.cell(guide, 1, 3, "Hedge/protect", bgcolor=color.blue, text_color=color.white)

//----------------------------------------------------
// Alerts
//----------------------------------------------------
alertcondition(buySignal, "BUY SPY", "BUY SPY")
alertcondition(sellSignal, "SELL / DEFEND", "SELL / DEFEND")
alertcondition(holdSignal, "HOLD SPY", "HOLD SPY")
````
