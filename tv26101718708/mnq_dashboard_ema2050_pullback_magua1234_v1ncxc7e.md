# MNQ Dashboard EMA20/50 Pullback magua1234

- url: https://www.tradingview.com/script/V1ncxc7e-MNQ-Dashboard-EMA20-50-Pullback-magua1234/
- type: indicator
- pine_id: PUB;43ca7f6ee2a44942a94ef641117d2275
- version: 1.0

## Description

pro trade to find out possible way to trade like pro and smart trader

## Source Code

````pine
//@version=6
indicator('MNQ Dashboard EMA20/50 Pullback', overlay = true)

// ===== CONFIG =====
riskUSD = input.float(250, 'Risk ($)')
rr = input.float(2.0, 'Risk Reward')
atrMult = input.float(1.0, 'ATR Mult')

// ===== EMAS =====
ema20 = ta.ema(close, 20)
ema50 = ta.ema(close, 50)

bullTrend = ema20 > ema50
bearTrend = ema20 < ema50

// ===== PULLBACK LOGIC =====
buySignal = bullTrend and low <= ema20 and close > ema20

sellSignal = bearTrend and high >= ema20 and close < ema20

// ===== ATR STOP =====
atr = ta.atr(14)

entry = close

longSL = entry - atr * atrMult
longTP = entry + atr * atrMult * rr

shortSL = entry + atr * atrMult
shortTP = entry - atr * atrMult * rr

// ===== CURRENT DIRECTION =====
dir = bullTrend ? 'BUY' : 'SELL'

slPrice = bullTrend ? longSL : shortSL
tpPrice = bullTrend ? longTP : shortTP

stopPoints = math.abs(entry - slPrice)

// MNQ = $2 por punto
contracts = math.floor(riskUSD / (stopPoints * 2))

// ===== SESSION =====
ny = not na(time(timeframe.period, '0930-1600', 'America/New_York'))

london = not na(time(timeframe.period, '0300-1200', 'Europe/London'))

asia = not na(time(timeframe.period, '1900-0400', 'Asia/Tokyo'))

sessionName = ny ? 'NEW YORK' : london ? 'LONDON' : asia ? 'ASIA' : 'OFF'

// ===== RATING =====
strength = math.abs(ema20 - ema50)

rating = strength > atr * 1.5 ? '★★★★★' : strength > atr * 1.0 ? '★★★★' : strength > atr * 0.7 ? '★★★' : strength > atr * 0.4 ? '★★' : '★'

// ===== DASHBOARD =====
var table dash = table.new(position.top_right, 2, 12, bgcolor = color.rgb(9, 15, 50), border_width = 1)

if barstate.islast

    table.cell(dash, 0, 0, 'MNQ DASHBOARD', bgcolor = color.blue, text_color = color.white)

    table.cell(dash, 1, 0, '')

    table.cell(dash, 0, 1, 'Signal')
    table.cell(dash, 1, 1, dir, text_color = dir == 'BUY' ? color.lime : color.red)

    table.cell(dash, 0, 2, 'Session')
    table.cell(dash, 1, 2, sessionName)

    table.cell(dash, 0, 3, 'Rating')
    table.cell(dash, 1, 3, rating, text_color = color.lime)

    table.cell(dash, 0, 4, 'Entry')
    table.cell(dash, 1, 4, str.tostring(entry))

    table.cell(dash, 0, 5, 'Stop')
    table.cell(dash, 1, 5, str.tostring(slPrice), text_color = color.red)

    table.cell(dash, 0, 6, 'Target')
    table.cell(dash, 1, 6, str.tostring(tpPrice), text_color = color.lime)

    table.cell(dash, 0, 7, 'SL Pts')
    table.cell(dash, 1, 7, str.tostring(stopPoints))

    table.cell(dash, 0, 8, 'Contracts')
    table.cell(dash, 1, 8, str.tostring(contracts))

    table.cell(dash, 0, 9, 'Risk')
    table.cell(dash, 1, 9, '$' + str.tostring(riskUSD))

    table.cell(dash, 0, 10, 'EMA20')
    table.cell(dash, 1, 10, str.tostring(ema20))

    table.cell(dash, 0, 11, 'EMA50')
    table.cell(dash, 1, 11, str.tostring(ema50))

// ===== PLOTS =====
plot(ema20, color = color.green, linewidth = 2)
plot(ema50, color = color.orange, linewidth = 2)

plotshape(buySignal, title = 'BUY', location = location.belowbar, style = shape.labelup, color = color.lime, text = 'BUY')

plotshape(sellSignal, title = 'SELL', location = location.abovebar, style = shape.labeldown, color = color.red, text = 'SELL')

// ===== ALERTS =====
alertcondition(buySignal, title = 'BUY Signal', message = 'MNQ BUY Pullback EMA20')

alertcondition(sellSignal, title = 'SELL Signal', message = 'MNQ SELL Pullback EMA20')
````
