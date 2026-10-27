# DN ULTIMATE SUPER SCANNER + SIGNAL DASHBOARD

- url: https://www.tradingview.com/script/DCEuBA2J-DN-ULTIMATE-SUPER-SCANNER-SIGNAL-DASHBOARD/
- type: indicator
- pine_id: PUB;7c865b80648749ab8b9e333a2bb37227
- version: 1.0

## Description

DN Ultimate Super Scanner + Signal Dashboard is a full trading framework built for traders who want one clean tool for trend direction, momentum, volume, breakout conditions, and trade management.

This indicator combines the Doing Numbers 9 / 65 / 200 framework with an added 9 / 21 / 65 + 200 signal dashboard. It is designed to help identify bullish and bearish trend alignment, high-volume candles, buy-the-dip opportunities, sell-the-rally setups, range breaks, squeeze conditions, and potential continuation setups.

Key features:
• Auto timeframe mode for 1M scalp, 5M day trade, 15M entry, 1H confirmation, and swing trading
• 9 / 65 / 200 EMA framework stack
• 9 / 21 / 65 + 200 signal panel
• VWAP confirmation for intraday trades
• RSI and relative volume checks
• High-volume and low-volume candle markers
• Buy dip and sell rally signals
• Range high and range low breakout alerts
• Breakout score based on price, volume, ATR, RSI, moving averages, 52-week high proximity, and squeeze conditions
• TTM-style squeeze detection
• ATR trail, entry price, and TP progress panel
• Buffered Trend Cloud for visual trade management
• Built-in alerts for scalp, day trade, swing, range break, squeeze, and panel signals

How I use it:
The scanner is not meant to be a blind buy or sell system. It is a confirmation tool. I use it to identify when trend, volume, momentum, and structure are lining up. Entries should still be confirmed with price action, support/resistance levels, candle closes, and risk management.

Best use:
• 1M / 5M / 15M for intraday setups
• 1H / 4H / Daily for swing confirmation
• Combine with manual support, resistance, supply, demand, and market context

The goal of this tool is simple:
Plan the trade. Wait for confirmation. Execute with discipline. Manage risk.

Disclaimer:
This script is for educational and research purposes only. It is not financial advice. Trading stocks and options involves risk, and options can lose 100% of premium.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © dthomas1026
//@version=6
indicator("DN ULTIMATE SUPER SCANNER + SIGNAL DASHBOARD", overlay=true, shorttitle="DN-ULTIMATE-PANEL", max_labels_count=500)

//====================================================
// INPUTS
//====================================================
volLength = input.int(20, "Volume Average Length")
highVolMult = input.float(1.5, "High Volume Multiplier")
lowVolMult = input.float(0.6, "Low Volume Multiplier")
rsiLength = input.int(14, "RSI Length")
breakoutLookback = input.int(20, "Range Break Lookback")

useFrameworkStack = input.bool(true, "Framework Stack: 9/65/200 On Every Timeframe")
showDashboard = input.bool(true, "Show Full Dashboard")
showBreakoutScanner = input.bool(true, "Show Breakout Scanner")
showVWAP = input.bool(true, "Show VWAP")

showMAs = input.bool(true, "Show Moving Averages")
showLabels = input.bool(true, "Show Buy/Sell Labels")
showSignalPanel = input.bool(true, "Show Entry / Trail / TP Panel")
showTrendCloud = input.bool(true, "Show Buffered Trend Cloud")

atrLen = input.int(14, "ATR Length")
trailAtrMult = input.float(1.0, "Trail ATR Multiplier", step=0.25)

useRvolFilter = input.bool(false, "Use RVOL Filter For Panel Signals")
rvolMin = input.float(1.5, "Minimum RVOL", step=0.1)

//====================================================
// AUTO TIMEFRAME MODE
//====================================================
is1m = timeframe.period == "1"
is5m = timeframe.period == "5"
is15m = timeframe.period == "15"
is1H = timeframe.period == "60"

isIntraday = is1m or is5m or is15m or is1H
isSwing = not isIntraday

fastLen = useFrameworkStack ? 9 : is1m ? 8 : is5m ? 9 : 9
midLen  = useFrameworkStack ? 65 : is1m ? 21 : is5m ? 20 : 65
slowLen = useFrameworkStack ? 200 : is1m ? 50 : is5m ? 50 : 200

modeText = is1m ? "1M SCALP" : is5m ? "5M DAY TRADE" : is15m ? "15M ENTRY" : is1H ? "1H CONFIRMATION" : "SWING"

//====================================================
// MOVING AVERAGES — SCANNER ENGINE
//====================================================
fastEMA = ta.ema(close, fastLen)
midEMA = ta.ema(close, midLen)
slowEMA = ta.ema(close, slowLen)

sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)
sma200 = ta.sma(close, 200)

//====================================================
// MOVING AVERAGES — SIGNAL PANEL ENGINE
// Uses 9 / 21 / 65 + 200 SMA logic
//====================================================
panelEMA9 = ta.ema(close, 9)
panelEMA21 = ta.ema(close, 21)
panelEMA65 = ta.ema(close, 65)
panelSMA200 = ta.sma(close, 200)

//====================================================
// VWAP
//====================================================
vwapVal = ta.vwap(close)

//====================================================
// RSI / VOLUME
//====================================================
rsi = ta.rsi(close, rsiLength)
avgVol = ta.sma(volume, volLength)
avgVol50 = ta.sma(volume, 50)

highVol = volume > avgVol * highVolMult
lowVol = volume < avgVol * lowVolMult
rvol = avgVol > 0 ? volume / avgVol : na
rvolPass = not useRvolFilter or rvol >= rvolMin

bullCandle = close > open
bearCandle = close < open

//====================================================
// TREND — SCANNER ENGINE
//====================================================
bullTrend = fastEMA > midEMA and midEMA > slowEMA
bearTrend = fastEMA < midEMA and midEMA < slowEMA

aboveVWAP = close > vwapVal
belowVWAP = close < vwapVal

//====================================================
// TREND — SIGNAL PANEL ENGINE
//====================================================
panelBullStack = panelEMA9 > panelEMA21 and panelEMA21 > panelEMA65 and close > panelSMA200
panelBearStack = panelEMA9 < panelEMA21 and panelEMA21 < panelEMA65 and close < panelSMA200

panelLongSignal = panelBullStack and not panelBullStack[1] and rvolPass
panelShortSignal = panelBearStack and not panelBearStack[1] and rvolPass

//====================================================
// INTRADAY SIGNALS
//====================================================
scalpLong = isIntraday and bullTrend and aboveVWAP and highVol and bullCandle and rsi > 55
scalpShort = isIntraday and bearTrend and belowVWAP and highVol and bearCandle and rsi < 45

dayBuyDip = isIntraday and bullTrend and aboveVWAP and low <= fastEMA and close > fastEMA and volume > avgVol and rsi > 50
daySellRally = isIntraday and bearTrend and belowVWAP and high >= fastEMA and close < fastEMA and volume > avgVol and rsi < 50

//====================================================
// SWING SIGNALS
//====================================================
strongBuy = isSwing and bullTrend and close > fastEMA and highVol and bullCandle and rsi > 50
strongSell = isSwing and bearTrend and close < fastEMA and highVol and bearCandle and rsi < 50

buyDip = isSwing and bullTrend and low <= fastEMA and close > fastEMA and volume > avgVol and rsi > 50
sellRally = isSwing and bearTrend and high >= fastEMA and close < fastEMA and volume > avgVol and rsi < 50

//====================================================
// RANGE BREAKS
//====================================================
rangeHighBreak = isIntraday and close > ta.highest(high[1], breakoutLookback) and highVol and aboveVWAP
rangeLowBreak = isIntraday and close < ta.lowest(low[1], breakoutLookback) and highVol and belowVWAP

//====================================================
// BREAKOUT SCANNER
//====================================================
atrVal = ta.atr(atrLen)

returns = (close - close[1]) / close[1] * 100
vol20d = ta.stdev(returns, 20)

high52w = request.security(syminfo.tickerid, "D", ta.highest(high, 252))
pctFromHigh = ((high52w - close) / high52w) * 100

bbBasis = ta.sma(close, 20)
bbDev = 2 * ta.stdev(close, 20)
bbUpper = bbBasis + bbDev
bbLower = bbBasis - bbDev

kcBasis = ta.ema(close, 20)
kcRange = ta.ema(ta.tr(true), 20) * 1.5
kcUpper = kcBasis + kcRange
kcLower = kcBasis - kcRange

squeezeOn = bbUpper < kcUpper and bbLower > kcLower
squeezeReleased = not squeezeOn and squeezeOn[1]

checkPrice = close > 15
checkVolume = avgVol50 > 1000000
checkAtr = atrVal > 1
checkLowVol = vol20d < 3
checkNearHigh = pctFromHigh <= 3
checkRsi = rsi >= 50 and rsi <= 70
checkAboveSma20 = close > sma20
checkAboveSma50 = close > sma50
checkSqueeze = squeezeOn

totalChecks =
     (checkPrice ? 1 : 0) +
     (checkVolume ? 1 : 0) +
     (checkAtr ? 1 : 0) +
     (checkLowVol ? 1 : 0) +
     (checkNearHigh ? 1 : 0) +
     (checkRsi ? 1 : 0) +
     (checkAboveSma20 ? 1 : 0) +
     (checkAboveSma50 ? 1 : 0) +
     (checkSqueeze ? 1 : 0)

fullMatch = totalChecks == 9
strongMatch = totalChecks >= 7

//====================================================
// ENTRY / TRAIL / TP ENGINE
//====================================================
var string tradeState = "FLAT"
var float entryPrice = na
var float trailPrice = na
var float riskUnit = na
var int direction = 0

newLong = panelLongSignal
newShort = panelShortSignal

if newLong
    tradeState := "LONG"
    direction := 1
    entryPrice := close
    riskUnit := atrVal * trailAtrMult
    trailPrice := close - riskUnit

if newShort
    tradeState := "SHORT"
    direction := -1
    entryPrice := close
    riskUnit := atrVal * trailAtrMult
    trailPrice := close + riskUnit

if tradeState == "LONG" and not na(riskUnit)
    trailPrice := math.max(trailPrice, close - riskUnit)
    if close < trailPrice
        tradeState := "FLAT"
        direction := 0

if tradeState == "SHORT" and not na(riskUnit)
    trailPrice := math.min(trailPrice, close + riskUnit)
    if close > trailPrice
        tradeState := "FLAT"
        direction := 0

tp1 = direction == 1 ? entryPrice + riskUnit : direction == -1 ? entryPrice - riskUnit : na
tp2 = direction == 1 ? entryPrice + riskUnit * 2 : direction == -1 ? entryPrice - riskUnit * 2 : na
tp3 = direction == 1 ? entryPrice + riskUnit * 3 : direction == -1 ? entryPrice - riskUnit * 3 : na

tpStatus = "—"

if tradeState == "LONG"
    tpStatus := close >= tp3 ? "TP3 HIT" : close >= tp2 ? "TP2 HIT" : close >= tp1 ? "TP1 HIT" : "→ TP1"

if tradeState == "SHORT"
    tpStatus := close <= tp3 ? "TP3 HIT" : close <= tp2 ? "TP2 HIT" : close <= tp1 ? "TP1 HIT" : "→ TP1"

//====================================================
// BUFFERED TREND CLOUD
//====================================================
cloudTop = panelEMA65 + atrVal * 0.5
cloudBot = panelEMA65 - atrVal * 0.5

//====================================================
// CANDLE COLORS
//====================================================
barcolor(
     scalpLong or strongBuy or panelLongSignal ? color.lime :
     scalpShort or strongSell or panelShortSignal ? color.red :
     fullMatch ? color.yellow :
     highVol and bullCandle ? color.green :
     highVol and bearCandle ? color.maroon :
     lowVol ? color.gray :
     na
)

//====================================================
// PLOTS
//====================================================
plot(showMAs ? fastEMA : na, "Fast EMA Auto", color=color.orange, linewidth=2)
plot(showMAs ? midEMA : na, "Middle EMA Auto", color=color.blue, linewidth=2)
plot(showMAs ? slowEMA : na, "Slow EMA Auto", color=color.white, linewidth=3)

plot(showVWAP and isIntraday ? vwapVal : na, "VWAP", color=color.purple, linewidth=2)

plot(showBreakoutScanner ? sma20 : na, "20 SMA", color=color.new(color.aqua, 65))
plot(showBreakoutScanner ? sma50 : na, "50 SMA", color=color.new(color.orange, 65))
plot(showBreakoutScanner ? bbUpper : na, "BB Upper", color=color.new(color.purple, 75))
plot(showBreakoutScanner ? bbLower : na, "BB Lower", color=color.new(color.purple, 75))

cloudPlotTop = plot(showTrendCloud ? cloudTop : na, "Buffered Trend Cloud Top", color=color.new(color.green, 80))
cloudPlotBot = plot(showTrendCloud ? cloudBot : na, "Buffered Trend Cloud Bottom", color=color.new(color.green, 80))
fill(cloudPlotTop, cloudPlotBot, color=color.new(color.green, 90))

plot(tradeState != "FLAT" ? trailPrice : na, "DN ATR Trail", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)

//====================================================
// LABELS
//====================================================
plotshape(showLabels and scalpLong, title="Scalp Long", text="SCALP LONG", location=location.belowbar, style=shape.labelup, color=color.lime, textcolor=color.black)
plotshape(showLabels and scalpShort, title="Scalp Short", text="SCALP SHORT", location=location.abovebar, style=shape.labeldown, color=color.red, textcolor=color.white)

plotshape(showLabels and dayBuyDip and not scalpLong, title="Day Buy Dip", text="BUY DIP", location=location.belowbar, style=shape.triangleup, color=color.green, textcolor=color.white)
plotshape(showLabels and daySellRally and not scalpShort, title="Day Sell Rally", text="SELL RALLY", location=location.abovebar, style=shape.triangledown, color=color.maroon, textcolor=color.white)

plotshape(showLabels and strongBuy, title="Strong Buy", text="STRONG BUY", location=location.belowbar, style=shape.labelup, color=color.lime, textcolor=color.black)
plotshape(showLabels and strongSell, title="Strong Sell", text="STRONG SELL", location=location.abovebar, style=shape.labeldown, color=color.red, textcolor=color.white)

plotshape(showLabels and buyDip and not strongBuy, title="Swing Buy Dip", text="BUY DIP", location=location.belowbar, style=shape.triangleup, color=color.green, textcolor=color.white)
plotshape(showLabels and sellRally and not strongSell, title="Swing Sell Rally", text="SELL RALLY", location=location.abovebar, style=shape.triangledown, color=color.maroon, textcolor=color.white)

plotshape(showLabels and rangeHighBreak, title="Range High Break", text="RANGE HIGH", location=location.belowbar, style=shape.labelup, color=color.aqua, textcolor=color.black)
plotshape(showLabels and rangeLowBreak, title="Range Low Break", text="RANGE LOW", location=location.abovebar, style=shape.labeldown, color=color.fuchsia, textcolor=color.white)

plotshape(showLabels and highVol and bullCandle and not scalpLong and not strongBuy, title="High Bull Volume", text="HIGH VOL", location=location.belowbar, style=shape.labelup, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(showLabels and highVol and bearCandle and not scalpShort and not strongSell, title="High Bear Volume", text="HIGH VOL", location=location.abovebar, style=shape.labeldown, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(showLabels and lowVol, title="Low Volume", text="LOW VOL", location=location.bottom, style=shape.circle, color=color.gray, textcolor=color.white, size=size.tiny)

plotshape(showBreakoutScanner and squeezeOn, title="TTM Squeeze", location=location.belowbar, style=shape.circle, color=color.red, size=size.tiny)

plotshape(showBreakoutScanner and fullMatch, title="Breakout Coiled", location=location.belowbar, style=shape.labelup, color=color.yellow, textcolor=color.black, size=size.large, text="COILED")

plotshape(showLabels and panelLongSignal, title="DN Panel Long", style=shape.labelup, text="DN BUY", color=color.lime, textcolor=color.black, location=location.belowbar)
plotshape(showLabels and panelShortSignal, title="DN Panel Short", style=shape.labeldown, text="DN SELL", color=color.red, textcolor=color.white, location=location.abovebar)

bgcolor(fullMatch ? color.new(color.yellow, 78) : strongMatch ? color.new(color.orange, 90) : na)

//====================================================
// DASHBOARD
//====================================================
var table dash = table.new(position.top_right, 2, 24, bgcolor=color.new(color.black, 15), border_width=1)

scannerTrendText = bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "CHOP"
scannerTrendColor = bullTrend ? color.lime : bearTrend ? color.red : color.orange

panelBiasText = panelBullStack ? "BULLISH STACK" : panelBearStack ? "BEARISH STACK" : "MIXED / WAIT"
panelBiasColor = panelBullStack ? color.lime : panelBearStack ? color.red : color.orange

stateColor = tradeState == "LONG" ? color.lime : tradeState == "SHORT" ? color.red : color.gray

setupText =
     fullMatch ? "COILED" :
     strongMatch ? "FORMING" :
     scalpLong ? "SCALP LONG" :
     scalpShort ? "SCALP SHORT" :
     strongBuy ? "STRONG BUY" :
     strongSell ? "STRONG SELL" :
     panelLongSignal ? "DN BUY" :
     panelShortSignal ? "DN SELL" :
     "WAIT"

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "DN ULTIMATE", bgcolor=color.blue, text_color=color.white)
    table.cell(dash, 1, 0, modeText, bgcolor=color.gray, text_color=color.white)

    table.cell(dash, 0, 1, "Ticker", text_color=color.white)
    table.cell(dash, 1, 1, syminfo.ticker, text_color=color.white)

    table.cell(dash, 0, 2, "EMA Stack", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(fastLen) + " / " + str.tostring(midLen) + " / " + str.tostring(slowLen), text_color=color.white)

    table.cell(dash, 0, 3, "Scanner Trend", text_color=color.white)
    table.cell(dash, 1, 3, scannerTrendText, text_color=scannerTrendColor)

    table.cell(dash, 0, 4, "VWAP", text_color=color.white)
    table.cell(dash, 1, 4, aboveVWAP ? "ABOVE" : belowVWAP ? "BELOW" : "AT VWAP", text_color=aboveVWAP ? color.lime : belowVWAP ? color.red : color.orange)

    table.cell(dash, 0, 5, "High Volume", text_color=color.white)
    table.cell(dash, 1, 5, highVol ? "YES" : "NO", text_color=highVol ? color.lime : color.gray)

    table.cell(dash, 0, 6, "RVOL", text_color=color.white)
    table.cell(dash, 1, 6, na(rvol) ? "—" : str.tostring(rvol, "#.##") + "x", text_color=rvolPass ? color.lime : color.red)

    table.cell(dash, 0, 7, "RSI", text_color=color.white)
    table.cell(dash, 1, 7, str.tostring(rsi, "#.#"), text_color=rsi > 55 ? color.lime : rsi < 45 ? color.red : color.orange)

    table.cell(dash, 0, 8, "ATR", text_color=color.white)
    table.cell(dash, 1, 8, str.tostring(atrVal, format.mintick), text_color=color.white)

    table.cell(dash, 0, 9, "Near 52W High", text_color=color.white)
    table.cell(dash, 1, 9, str.tostring(pctFromHigh, "#.##") + "%", text_color=pctFromHigh <= 3 ? color.lime : color.gray)

    table.cell(dash, 0, 10, "TTM Squeeze", text_color=color.white)
    table.cell(dash, 1, 10, squeezeOn ? "ON" : "OFF", text_color=squeezeOn ? color.yellow : color.gray)

    table.cell(dash, 0, 11, "Breakout Score", text_color=color.white)
    table.cell(dash, 1, 11, str.tostring(totalChecks) + " / 9", text_color=fullMatch ? color.yellow : strongMatch ? color.orange : color.gray)

    table.cell(dash, 0, 12, "Setup", text_color=color.white)
    table.cell(dash, 1, 12, setupText, text_color=color.white)

    table.cell(dash, 0, 13, "Best Use", text_color=color.white)
    table.cell(dash, 1, 13, isIntraday ? "1M / 5M / 15M / 1H" : "Daily / Weekly", text_color=color.white)

    if showSignalPanel
        table.cell(dash, 0, 14, "SIGNAL PANEL", bgcolor=color.black, text_color=color.lime)
        table.cell(dash, 1, 14, "9/21/65 + 200", bgcolor=color.black, text_color=color.white)

        table.cell(dash, 0, 15, "Status", text_color=color.white)
        table.cell(dash, 1, 15, tradeState, bgcolor=stateColor, text_color=color.black)

        table.cell(dash, 0, 16, "Panel Bias", text_color=color.white)
        table.cell(dash, 1, 16, panelBiasText, text_color=panelBiasColor)

        table.cell(dash, 0, 17, "Entry", text_color=color.white)
        table.cell(dash, 1, 17, na(entryPrice) ? "—" : str.tostring(entryPrice, format.mintick), text_color=color.lime)

        table.cell(dash, 0, 18, "Trail", text_color=color.white)
        table.cell(dash, 1, 18, na(trailPrice) ? "—" : str.tostring(trailPrice, format.mintick), text_color=color.red)

        table.cell(dash, 0, 19, "TP", text_color=color.white)
        table.cell(dash, 1, 19, tpStatus, text_color=color.lime)

        table.cell(dash, 0, 20, "TP1", text_color=color.white)
        table.cell(dash, 1, 20, na(tp1) ? "—" : str.tostring(tp1, format.mintick), text_color=color.lime)

        table.cell(dash, 0, 21, "TP2", text_color=color.white)
        table.cell(dash, 1, 21, na(tp2) ? "—" : str.tostring(tp2, format.mintick), text_color=color.lime)

        table.cell(dash, 0, 22, "TP3", text_color=color.white)
        table.cell(dash, 1, 22, na(tp3) ? "—" : str.tostring(tp3, format.mintick), text_color=color.lime)

        table.cell(dash, 0, 23, "Exit", text_color=color.white)
        table.cell(dash, 1, 23, "Buffered Trend Cloud", text_color=color.white)

//====================================================
// ALERTS — ORIGINAL SCANNER ALERTS
//====================================================
alertcondition(scalpLong, title="Scalp Long Alert", message='{"event":"dn.scout","signal":"scalp_long","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(scalpShort, title="Scalp Short Alert", message='{"event":"dn.scout","signal":"scalp_short","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')

alertcondition(dayBuyDip, title="Day Buy Dip Alert", message='{"event":"dn.scout","signal":"day_buy_dip","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(daySellRally, title="Day Sell Rally Alert", message='{"event":"dn.scout","signal":"day_sell_rally","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')

alertcondition(strongBuy, title="Strong Buy Alert", message='{"event":"dn.scout","signal":"strong_buy","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(strongSell, title="Strong Sell Alert", message='{"event":"dn.scout","signal":"strong_sell","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')

alertcondition(buyDip, title="Swing Buy Dip Alert", message='{"event":"dn.scout","signal":"swing_buy_dip","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(sellRally, title="Swing Sell Rally Alert", message='{"event":"dn.scout","signal":"swing_sell_rally","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')

alertcondition(rangeHighBreak, title="Range High Break Alert", message='{"event":"dn.scout","signal":"range_high_break","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(rangeLowBreak, title="Range Low Break Alert", message='{"event":"dn.scout","signal":"range_low_break","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')

alertcondition(fullMatch, title="Breakout Setup Coiled", message='{"event":"dn.scout","signal":"coiled_breakout","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(squeezeOn and not squeezeOn[1], title="TTM Squeeze Started", message='{"event":"dn.scout","signal":"squeeze_started","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(squeezeReleased, title="Squeeze Released", message='{"event":"dn.scout","signal":"squeeze_released","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')

//====================================================
// ALERTS — ADDED SIGNAL PANEL ALERTS
//====================================================
alertcondition(panelLongSignal, title="DN Panel Long Signal", message='{"event":"dn.panel","signal":"panel_long","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
alertcondition(panelShortSignal, title="DN Panel Short Signal", message='{"event":"dn.panel","signal":"panel_short","ticker":"{{ticker}}","price":{{close}},"tf":"{{interval}}"}')
````
