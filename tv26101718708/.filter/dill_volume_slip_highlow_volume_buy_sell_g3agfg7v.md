# DILL Volume Slip - High/Low Volume Buy Sell

- url: https://www.tradingview.com/script/G3aGFg7v-DILL-Volume-Slip-High-Low-Volume-Buy-Sell/
- type: indicator
- pine_id: PUB;83cf02b00e114a9c813fa1d3eabcfeae
- version: 4.0

## Description

📊 NEW TOOL ADDED TO THE DOING NUMBERS TOOLBOX

I just finished building a custom TradingView indicator called the **DILL Volume Slip Indicator**.

Most traders look at volume, but very few know how to interpret it quickly. This indicator was designed to remove the guesswork and instantly show what's happening behind the candles.

🔥 What it does:

✅ Highlights HIGH VOLUME candles

* Shows when institutions and larger market participants may be active.
* Helps identify potential momentum moves and breakouts.

✅ Highlights LOW VOLUME candles

* Identifies weak participation.
* Helps avoid getting trapped in low-conviction moves.

✅ Clear BUY Signals

* Requires strong bullish volume.
* Confirms trend direction using the 9 EMA and 65 EMA.
* Designed to keep traders aligned with momentum instead of fighting it.

✅ Clear SELL Signals

* Requires strong bearish volume.
* Confirms downside momentum with trend alignment.
* Helps identify potential breakdown opportunities.

✅ Trend Confirmation

* Uses the 9 EMA and 65 EMA to define market direction.
* Keeps traders focused on higher probability setups.

✅ Visual Simplicity

* Green = strength
* Red = weakness
* Gray = low participation
* Easy-to-read labels directly on the chart

Why this matters:

Volume is one of the few indicators that reveals what market participants are actually doing. Price can move on emotion, but volume shows commitment.

When high volume aligns with trend direction, it often signals increased probability that a move has real conviction behind it.

This indicator is not designed to predict the future.

It's designed to help traders:
• Identify momentum
• Avoid weak setups
• Follow the trend
• Improve trade selection
• Build better discipline

As we continue building the DOING NUMBERS ecosystem, I'll be releasing additional tools that combine:
📈 Trend Structure
📊 Volume Analysis
💧 Liquidity Levels
⚡ RSI Confirmation
🎯 Entry & Exit Frameworks

The goal isn't more indicators.

The goal is better decisions.

#DoingNumbers #TradingView #StockMarket #VolumeTrading #TechnicalAnalysis #DayTrading #SwingTrading #OptionsTrading #TradingEducation #CreatingGenerationalWealth

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © dthomas1026
//@version=6
indicator("DN ULTIMATE SUPER SCANNER V3", overlay=true, shorttitle="DN-ULTIMATE-V3")

// ===== INPUTS =====
volLength = input.int(20, "Volume Average Length")
highVolMult = input.float(1.5, "High Volume Multiplier")
lowVolMult = input.float(0.6, "Low Volume Multiplier")
rsiLength = input.int(14, "RSI Length")
breakoutLookback = input.int(20, "Range Break Lookback")
useFrameworkStack = input.bool(true, "Framework Stack: 9/65/200 On Every Timeframe")
showDashboard = input.bool(true, "Show Dashboard")
showBreakoutScanner = input.bool(true, "Show Breakout Scanner")
showVWAP = input.bool(true, "Show VWAP")

// ===== AUTO TIMEFRAME MODE =====
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

// ===== MOVING AVERAGES =====
fastEMA = ta.ema(close, fastLen)
midEMA = ta.ema(close, midLen)
slowEMA = ta.ema(close, slowLen)

sma20 = ta.sma(close, 20)
sma50 = ta.sma(close, 50)

// ===== VWAP =====
vwapVal = ta.vwap(close)

// ===== RSI / VOLUME =====
rsi = ta.rsi(close, rsiLength)
avgVol = ta.sma(volume, volLength)
avgVol50 = ta.sma(volume, 50)

highVol = volume > avgVol * highVolMult
lowVol = volume < avgVol * lowVolMult
rvol = volume / avgVol

bullCandle = close > open
bearCandle = close < open

// ===== TREND =====
bullTrend = fastEMA > midEMA and midEMA > slowEMA
bearTrend = fastEMA < midEMA and midEMA < slowEMA

aboveVWAP = close > vwapVal
belowVWAP = close < vwapVal

// ===== INTRADAY SIGNALS =====
scalpLong = isIntraday and bullTrend and aboveVWAP and highVol and bullCandle and rsi > 55
scalpShort = isIntraday and bearTrend and belowVWAP and highVol and bearCandle and rsi < 45

dayBuyDip = isIntraday and bullTrend and aboveVWAP and low <= fastEMA and close > fastEMA and volume > avgVol and rsi > 50
daySellRally = isIntraday and bearTrend and belowVWAP and high >= fastEMA and close < fastEMA and volume > avgVol and rsi < 50

// ===== SWING SIGNALS =====
strongBuy = isSwing and bullTrend and close > fastEMA and highVol and bullCandle and rsi > 50
strongSell = isSwing and bearTrend and close < fastEMA and highVol and bearCandle and rsi < 50

buyDip = isSwing and bullTrend and low <= fastEMA and close > fastEMA and volume > avgVol and rsi > 50
sellRally = isSwing and bearTrend and high >= fastEMA and close < fastEMA and volume > avgVol and rsi < 50

// ===== RANGE BREAKS =====
rangeHighBreak = isIntraday and close > ta.highest(high[1], breakoutLookback) and highVol and aboveVWAP
rangeLowBreak = isIntraday and close < ta.lowest(low[1], breakoutLookback) and highVol and belowVWAP

// ===== BREAKOUT SCANNER =====
atrVal = ta.atr(14)

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

// ===== CANDLE COLORS =====
barcolor(
     scalpLong or strongBuy ? color.lime :
     scalpShort or strongSell ? color.red :
     fullMatch ? color.yellow :
     highVol and bullCandle ? color.green :
     highVol and bearCandle ? color.maroon :
     lowVol ? color.gray :
     na
)

// ===== PLOTS =====
plot(fastEMA, "Fast EMA Auto", color=color.orange, linewidth=2)
plot(midEMA, "Middle EMA Auto", color=color.blue, linewidth=2)
plot(slowEMA, "Slow EMA Auto", color=color.white, linewidth=3)

plot(showVWAP and isIntraday ? vwapVal : na, "VWAP", color=color.purple, linewidth=2)

plot(showBreakoutScanner ? sma20 : na, "20 SMA", color=color.new(color.aqua, 65))
plot(showBreakoutScanner ? sma50 : na, "50 SMA", color=color.new(color.orange, 65))
plot(showBreakoutScanner ? bbUpper : na, "BB Upper", color=color.new(color.purple, 75))
plot(showBreakoutScanner ? bbLower : na, "BB Lower", color=color.new(color.purple, 75))

// ===== LABELS =====
plotshape(scalpLong, title="Scalp Long", text="SCALP LONG", location=location.belowbar, style=shape.labelup, color=color.lime, textcolor=color.black)
plotshape(scalpShort, title="Scalp Short", text="SCALP SHORT", location=location.abovebar, style=shape.labeldown, color=color.red, textcolor=color.white)

plotshape(dayBuyDip and not scalpLong, title="Day Buy Dip", text="BUY DIP", location=location.belowbar, style=shape.triangleup, color=color.green, textcolor=color.white)
plotshape(daySellRally and not scalpShort, title="Day Sell Rally", text="SELL RALLY", location=location.abovebar, style=shape.triangledown, color=color.maroon, textcolor=color.white)

plotshape(strongBuy, title="Strong Buy", text="STRONG BUY", location=location.belowbar, style=shape.labelup, color=color.lime, textcolor=color.black)
plotshape(strongSell, title="Strong Sell", text="STRONG SELL", location=location.abovebar, style=shape.labeldown, color=color.red, textcolor=color.white)

plotshape(buyDip and not strongBuy, title="Swing Buy Dip", text="BUY DIP", location=location.belowbar, style=shape.triangleup, color=color.green, textcolor=color.white)
plotshape(sellRally and not strongSell, title="Swing Sell Rally", text="SELL RALLY", location=location.abovebar, style=shape.triangledown, color=color.maroon, textcolor=color.white)

plotshape(rangeHighBreak, title="Range High Break", text="RANGE HIGH", location=location.belowbar, style=shape.labelup, color=color.aqua, textcolor=color.black)
plotshape(rangeLowBreak, title="Range Low Break", text="RANGE LOW", location=location.abovebar, style=shape.labeldown, color=color.fuchsia, textcolor=color.white)

plotshape(highVol and bullCandle and not scalpLong and not strongBuy, title="High Bull Volume", text="HIGH VOL", location=location.belowbar, style=shape.labelup, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(highVol and bearCandle and not scalpShort and not strongSell, title="High Bear Volume", text="HIGH VOL", location=location.abovebar, style=shape.labeldown, color=color.red, textcolor=color.white, size=size.tiny)

plotshape(lowVol, title="Low Volume", text="LOW VOL", location=location.bottom, style=shape.circle, color=color.gray, textcolor=color.white, size=size.tiny)

plotshape(showBreakoutScanner and squeezeOn, title="TTM Squeeze", location=location.belowbar, style=shape.circle, color=color.red, size=size.tiny)

plotshape(showBreakoutScanner and fullMatch, title="Breakout Coiled", location=location.belowbar, style=shape.labelup, color=color.yellow, textcolor=color.black, size=size.large, text="⚡ COILED")

bgcolor(fullMatch ? color.new(color.yellow, 78) : strongMatch ? color.new(color.orange, 90) : na)

// ===== DASHBOARD =====
if barstate.islast and showDashboard
    var table dash = table.new(position.top_right, 2, 13, bgcolor=color.new(color.black, 15), border_width=1)

    table.cell(dash, 0, 0, "DN ULTIMATE SCANNER", bgcolor=color.blue, text_color=color.white)
    table.cell(dash, 1, 0, modeText, bgcolor=color.gray, text_color=color.white)

    table.cell(dash, 0, 1, "EMA Stack", text_color=color.white)
    table.cell(dash, 1, 1, str.tostring(fastLen) + " / " + str.tostring(midLen) + " / " + str.tostring(slowLen), text_color=color.white)

    table.cell(dash, 0, 2, "Trend", text_color=color.white)
    table.cell(dash, 1, 2, bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "CHOP", text_color=color.white)

    table.cell(dash, 0, 3, "VWAP", text_color=color.white)
    table.cell(dash, 1, 3, aboveVWAP ? "ABOVE" : belowVWAP ? "BELOW" : "AT VWAP", text_color=color.white)

    table.cell(dash, 0, 4, "High Volume", text_color=color.white)
    table.cell(dash, 1, 4, highVol ? "YES" : "NO", text_color=color.white)

    table.cell(dash, 0, 5, "RVOL", text_color=color.white)
    table.cell(dash, 1, 5, str.tostring(math.round(rvol, 2)), text_color=color.white)

    table.cell(dash, 0, 6, "RSI", text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(math.round(rsi, 1)), text_color=color.white)

    table.cell(dash, 0, 7, "ATR", text_color=color.white)
    table.cell(dash, 1, 7, str.tostring(math.round(atrVal, 2)), text_color=color.white)

    table.cell(dash, 0, 8, "Near 52W High", text_color=color.white)
    table.cell(dash, 1, 8, str.tostring(math.round(pctFromHigh, 2)) + "%", text_color=color.white)

    table.cell(dash, 0, 9, "TTM Squeeze", text_color=color.white)
    table.cell(dash, 1, 9, squeezeOn ? "ON" : "OFF", text_color=color.white)

    table.cell(dash, 0, 10, "Breakout Score", text_color=color.white)
    table.cell(dash, 1, 10, str.tostring(totalChecks) + " / 9", text_color=color.white)

    table.cell(dash, 0, 11, "Setup", text_color=color.white)
    table.cell(dash, 1, 11, fullMatch ? "COILED" : strongMatch ? "FORMING" : scalpLong ? "SCALP LONG" : scalpShort ? "SCALP SHORT" : strongBuy ? "STRONG BUY" : strongSell ? "STRONG SELL" : "WAIT", text_color=color.white)

    table.cell(dash, 0, 12, "Best Use", text_color=color.white)
    table.cell(dash, 1, 12, isIntraday ? "1M / 5M / 15M / 1H" : "Daily / Weekly", text_color=color.white)

// ===== ALERTS =====
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
````
