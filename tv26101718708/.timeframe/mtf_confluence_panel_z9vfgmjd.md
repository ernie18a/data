# MTF Confluence Panel

- url: https://www.tradingview.com/script/Z9VfGmjD-MTF-Confluence-Panel/
- type: indicator
- pine_id: PUB;9ddec97c2cd74bc6be731fcc0e20503c
- version: 1.0

## Description

This script gives you a clean, uncluttered view of six different timeframes at once. For each timeframe, it shows the 9 and 21 EMA crossover and trend direction, the RSI value, VWAP, 50 EMA, the overall bullish or bearish consensus, and both price level and volume strength. 

Everything is neatly organized so you can quickly see the bigger picture without switching charts.

## Source Code

````pine
//@version=6
indicator("MTF Confluence Panel", overlay = true, max_labels_count = 500)

rsiLen   = input.int(14, "RSI Length")
volMult  = input.float(1.8, "Volume Spike Multiplier")
ema50Len = input.int(50, "EMA 50 Length")

tf1 = input.timeframe("1",  "1m")
tf2 = input.timeframe("3",  "3m")
tf3 = input.timeframe("5",  "5m")
tf4 = input.timeframe("10", "10m")
tf5 = input.timeframe("15", "15m")
tf6 = input.timeframe("30", "30m")

bullColor = input.color(color.green, "Bull Color")
bearColor = input.color(color.red,   "Bear Color")
neutColor = input.color(color.gray,  "Neutral Color")

posInput = input.string("Top Right", "Table Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right"])
pos = posInput == "Top Left" ? position.top_left : posInput == "Top Right" ? position.top_right : posInput == "Bottom Left" ? position.bottom_left : position.bottom_right

// ── Data Requests ──
vwap1 = request.security(syminfo.tickerid, tf1, ta.vwap(hlc3))
rsi1  = request.security(syminfo.tickerid, tf1, ta.rsi(close, rsiLen))
ema501 = request.security(syminfo.tickerid, tf1, ta.ema(close, ema50Len))
ema91  = request.security(syminfo.tickerid, tf1, ta.ema(close, 9))
ema211 = request.security(syminfo.tickerid, tf1, ta.ema(close, 21))
vol1   = request.security(syminfo.tickerid, tf1, volume)

vwap2 = request.security(syminfo.tickerid, tf2, ta.vwap(hlc3))
rsi2  = request.security(syminfo.tickerid, tf2, ta.rsi(close, rsiLen))
ema502 = request.security(syminfo.tickerid, tf2, ta.ema(close, ema50Len))
ema92  = request.security(syminfo.tickerid, tf2, ta.ema(close, 9))
ema212 = request.security(syminfo.tickerid, tf2, ta.ema(close, 21))
vol2   = request.security(syminfo.tickerid, tf2, volume)

vwap3 = request.security(syminfo.tickerid, tf3, ta.vwap(hlc3))
rsi3  = request.security(syminfo.tickerid, tf3, ta.rsi(close, rsiLen))
ema503 = request.security(syminfo.tickerid, tf3, ta.ema(close, ema50Len))
ema93  = request.security(syminfo.tickerid, tf3, ta.ema(close, 9))
ema213 = request.security(syminfo.tickerid, tf3, ta.ema(close, 21))
vol3   = request.security(syminfo.tickerid, tf3, volume)

vwap4 = request.security(syminfo.tickerid, tf4, ta.vwap(hlc3))
rsi4  = request.security(syminfo.tickerid, tf4, ta.rsi(close, rsiLen))
ema504 = request.security(syminfo.tickerid, tf4, ta.ema(close, ema50Len))
ema94  = request.security(syminfo.tickerid, tf4, ta.ema(close, 9))
ema214 = request.security(syminfo.tickerid, tf4, ta.ema(close, 21))
vol4   = request.security(syminfo.tickerid, tf4, volume)

vwap5 = request.security(syminfo.tickerid, tf5, ta.vwap(hlc3))
rsi5  = request.security(syminfo.tickerid, tf5, ta.rsi(close, rsiLen))
ema505 = request.security(syminfo.tickerid, tf5, ta.ema(close, ema50Len))
ema95  = request.security(syminfo.tickerid, tf5, ta.ema(close, 9))
ema215 = request.security(syminfo.tickerid, tf5, ta.ema(close, 21))
vol5   = request.security(syminfo.tickerid, tf5, volume)

vwap6 = request.security(syminfo.tickerid, tf6, ta.vwap(hlc3))
rsi6  = request.security(syminfo.tickerid, tf6, ta.rsi(close, rsiLen))
ema506 = request.security(syminfo.tickerid, tf6, ta.ema(close, ema50Len))
ema96  = request.security(syminfo.tickerid, tf6, ta.ema(close, 9))
ema216 = request.security(syminfo.tickerid, tf6, ta.ema(close, 21))
vol6   = request.security(syminfo.tickerid, tf6, volume)

// Calculations
bias1 = ema91 > ema211
slope1 = ema91 > ema91[1] ? "UP" : "DOWN"
v1 = close > vwap1 ? 1 : close < vwap1 ? -1 : 0
e501 = close > ema501 ? 1 : -1
volAvg1 = ta.sma(vol1, 20)
volSig1 = vol1 > volAvg1 * volMult ? 1 : -1

bias2 = ema92 > ema212
slope2 = ema92 > ema92[1] ? "UP" : "DOWN"
v2 = close > vwap2 ? 1 : close < vwap2 ? -1 : 0
e502 = close > ema502 ? 1 : -1
volAvg2 = ta.sma(vol2, 20)
volSig2 = vol2 > volAvg2 * volMult ? 1 : -1

bias3 = ema93 > ema213
slope3 = ema93 > ema93[1] ? "UP" : "DOWN"
v3 = close > vwap3 ? 1 : close < vwap3 ? -1 : 0
e503 = close > ema503 ? 1 : -1
volAvg3 = ta.sma(vol3, 20)
volSig3 = vol3 > volAvg3 * volMult ? 1 : -1

bias4 = ema94 > ema214
slope4 = ema94 > ema94[1] ? "UP" : "DOWN"
v4 = close > vwap4 ? 1 : close < vwap4 ? -1 : 0
e504 = close > ema504 ? 1 : -1
volAvg4 = ta.sma(vol4, 20)
volSig4 = vol4 > volAvg4 * volMult ? 1 : -1

bias5 = ema95 > ema215
slope5 = ema95 > ema95[1] ? "UP" : "DOWN"
v5 = close > vwap5 ? 1 : close < vwap5 ? -1 : 0
e505 = close > ema505 ? 1 : -1
volAvg5 = ta.sma(vol5, 20)
volSig5 = vol5 > volAvg5 * volMult ? 1 : -1

bias6 = ema96 > ema216
slope6 = ema96 > ema96[1] ? "UP" : "DOWN"
v6 = close > vwap6 ? 1 : close < vwap6 ? -1 : 0
e506 = close > ema506 ? 1 : -1
volAvg6 = ta.sma(vol6, 20)
volSig6 = vol6 > volAvg6 * volMult ? 1 : -1

// Table
var t = table.new(pos, 8, 7, bgcolor = color.new(color.black, 85), border_width = 1)

if barstate.islast
    table.cell(t, 0, 0, "TF",     text_color = color.yellow)
    table.cell(t, 1, 0, "Bias",   text_color = color.yellow)
    table.cell(t, 2, 0, "Trend",  text_color = color.yellow)
    table.cell(t, 3, 0, "RSI",    text_color = color.yellow)
    table.cell(t, 4, 0, "VWAP",   text_color = color.yellow)
    table.cell(t, 5, 0, "EMA 50", text_color = color.yellow)
    table.cell(t, 6, 0, "Overall",text_color = color.yellow)
    table.cell(t, 7, 0, "Volume", text_color = color.yellow)

    // Timeframe 1
    table.cell(t, 0, 1, tf1, text_color = color.white)
    table.cell(t, 1, 1, bias1 ? "BULL" : "BEAR", text_color = bias1 ? bullColor : bearColor)
    table.cell(t, 2, 1, slope1, text_color = slope1 == "UP" ? bullColor : bearColor)
    table.cell(t, 3, 1, str.tostring(rsi1, "#.##"), text_color = rsi1 >= 50 ? bullColor : bearColor)
    table.cell(t, 4, 1, v1 == 1 ? "BULL" : v1 == -1 ? "BEAR" : "NEUT", text_color = v1 == 1 ? bullColor : v1 == -1 ? bearColor : neutColor)
    table.cell(t, 5, 1, e501 == 1 ? "BULL" : "BEAR", text_color = e501 == 1 ? bullColor : bearColor)
    table.cell(t, 6, 1, (bias1 and slope1 == "UP" and rsi1 >= 50 and v1 == 1 and e501 == 1) ? "STRONG BULL" : "NEUTRAL", text_color = (bias1 and slope1 == "UP" and rsi1 >= 50 and v1 == 1 and e501 == 1) ? bullColor : neutColor)
    table.cell(t, 7, 1, volSig1 == 1 ? "HIGH" : "LOW", text_color = volSig1 == 1 ? bullColor : bearColor)

    // Timeframe 2
    table.cell(t, 0, 2, tf2, text_color = color.white)
    table.cell(t, 1, 2, bias2 ? "BULL" : "BEAR", text_color = bias2 ? bullColor : bearColor)
    table.cell(t, 2, 2, slope2, text_color = slope2 == "UP" ? bullColor : bearColor)
    table.cell(t, 3, 2, str.tostring(rsi2, "#.##"), text_color = rsi2 >= 50 ? bullColor : bearColor)
    table.cell(t, 4, 2, v2 == 1 ? "BULL" : v2 == -1 ? "BEAR" : "NEUT", text_color = v2 == 1 ? bullColor : v2 == -1 ? bearColor : neutColor)
    table.cell(t, 5, 2, e502 == 1 ? "BULL" : "BEAR", text_color = e502 == 1 ? bullColor : bearColor)
    table.cell(t, 6, 2, (bias2 and slope2 == "UP" and rsi2 >= 50 and v2 == 1 and e502 == 1) ? "STRONG BULL" : "NEUTRAL", text_color = (bias2 and slope2 == "UP" and rsi2 >= 50 and v2 == 1 and e502 == 1) ? bullColor : neutColor)
    table.cell(t, 7, 2, volSig2 == 1 ? "HIGH" : "LOW", text_color = volSig2 == 1 ? bullColor : bearColor)

    // Timeframe 3
    table.cell(t, 0, 3, tf3, text_color = color.white)
    table.cell(t, 1, 3, bias3 ? "BULL" : "BEAR", text_color = bias3 ? bullColor : bearColor)
    table.cell(t, 2, 3, slope3, text_color = slope3 == "UP" ? bullColor : bearColor)
    table.cell(t, 3, 3, str.tostring(rsi3, "#.##"), text_color = rsi3 >= 50 ? bullColor : bearColor)
    table.cell(t, 4, 3, v3 == 1 ? "BULL" : v3 == -1 ? "BEAR" : "NEUT", text_color = v3 == 1 ? bullColor : v3 == -1 ? bearColor : neutColor)
    table.cell(t, 5, 3, e503 == 1 ? "BULL" : "BEAR", text_color = e503 == 1 ? bullColor : bearColor)
    table.cell(t, 6, 3, (bias3 and slope3 == "UP" and rsi3 >= 50 and v3 == 1 and e503 == 1) ? "STRONG BULL" : "NEUTRAL", text_color = (bias3 and slope3 == "UP" and rsi3 >= 50 and v3 == 1 and e503 == 1) ? bullColor : neutColor)
    table.cell(t, 7, 3, volSig3 == 1 ? "HIGH" : "LOW", text_color = volSig3 == 1 ? bullColor : bearColor)

    // Timeframe 4
    table.cell(t, 0, 4, tf4, text_color = color.white)
    table.cell(t, 1, 4, bias4 ? "BULL" : "BEAR", text_color = bias4 ? bullColor : bearColor)
    table.cell(t, 2, 4, slope4, text_color = slope4 == "UP" ? bullColor : bearColor)
    table.cell(t, 3, 4, str.tostring(rsi4, "#.##"), text_color = rsi4 >= 50 ? bullColor : bearColor)
    table.cell(t, 4, 4, v4 == 1 ? "BULL" : v4 == -1 ? "BEAR" : "NEUT", text_color = v4 == 1 ? bullColor : v4 == -1 ? bearColor : neutColor)
    table.cell(t, 5, 4, e504 == 1 ? "BULL" : "BEAR", text_color = e504 == 1 ? bullColor : bearColor)
    table.cell(t, 6, 4, (bias4 and slope4 == "UP" and rsi4 >= 50 and v4 == 1 and e504 == 1) ? "STRONG BULL" : "NEUTRAL", text_color = (bias4 and slope4 == "UP" and rsi4 >= 50 and v4 == 1 and e504 == 1) ? bullColor : neutColor)
    table.cell(t, 7, 4, volSig4 == 1 ? "HIGH" : "LOW", text_color = volSig4 == 1 ? bullColor : bearColor)

    // Timeframe 5
    table.cell(t, 0, 5, tf5, text_color = color.white)
    table.cell(t, 1, 5, bias5 ? "BULL" : "BEAR", text_color = bias5 ? bullColor : bearColor)
    table.cell(t, 2, 5, slope5, text_color = slope5 == "UP" ? bullColor : bearColor)
    table.cell(t, 3, 5, str.tostring(rsi5, "#.##"), text_color = rsi5 >= 50 ? bullColor : bearColor)
    table.cell(t, 4, 5, v5 == 1 ? "BULL" : v5 == -1 ? "BEAR" : "NEUT", text_color = v5 == 1 ? bullColor : v5 == -1 ? bearColor : neutColor)
    table.cell(t, 5, 5, e505 == 1 ? "BULL" : "BEAR", text_color = e505 == 1 ? bullColor : bearColor)
    table.cell(t, 6, 5, (bias5 and slope5 == "UP" and rsi5 >= 50 and v5 == 1 and e505 == 1) ? "STRONG BULL" : "NEUTRAL", text_color = (bias5 and slope5 == "UP" and rsi5 >= 50 and v5 == 1 and e505 == 1) ? bullColor : neutColor)
    table.cell(t, 7, 5, volSig5 == 1 ? "HIGH" : "LOW", text_color = volSig5 == 1 ? bullColor : bearColor)

    // Timeframe 6
    table.cell(t, 0, 6, tf6, text_color = color.white)
    table.cell(t, 1, 6, bias6 ? "BULL" : "BEAR", text_color = bias6 ? bullColor : bearColor)
    table.cell(t, 2, 6, slope6, text_color = slope6 == "UP" ? bullColor : bearColor)
    table.cell(t, 3, 6, str.tostring(rsi6, "#.##"), text_color = rsi6 >= 50 ? bullColor : bearColor)
    table.cell(t, 4, 6, v6 == 1 ? "BULL" : v6 == -1 ? "BEAR" : "NEUT", text_color = v6 == 1 ? bullColor : v6 == -1 ? bearColor : neutColor)
    table.cell(t, 5, 6, e506 == 1 ? "BULL" : "BEAR", text_color = e506 == 1 ? bullColor : bearColor)
    table.cell(t, 6, 6, (bias6 and slope6 == "UP" and rsi6 >= 50 and v6 == 1 and e506 == 1) ? "STRONG BULL" : "NEUTRAL", text_color = (bias6 and slope6 == "UP" and rsi6 >= 50 and v6 == 1 and e506 == 1) ? bullColor : neutColor)
    table.cell(t, 7, 6, volSig6 == 1 ? "HIGH" : "LOW", text_color = volSig6 == 1 ? bullColor : bearColor)
````
