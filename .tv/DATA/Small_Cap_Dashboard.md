<!-- tradingview-pine-id: PUB;d3ecee3625c147239337f3e56697aaf8 -->
<!-- tradingviewscripts-format: 1 -->
# Small Cap Dashboard

Source: https://www.tradingview.com/script/MaQaQEz9-Small-Cap-Dashboard/

## Description

Small Cap Dashboard is a compact on-chart information panel designed for active traders who want key stock metrics visible at a glance without opening multiple menus or indicators.

The dashboard displays:

Price
Daily % change
Daily volume
Relative volume (RVOL)
Free float
Float rotation
RSI
MACD direction
VWAP position
Short-term trend
ATR
Day high
Day low

The indicator is especially useful for small-cap and momentum stocks, where relative volume, float size, and float rotation can help identify unusually active securities.

Float Rotation is calculated as daily trading volume divided by reported free float. For example, a stock with a 2 million share float and 6 million shares of volume has approximately 3x float rotation.

RVOL compares current daily volume with average daily volume over the selected lookback period.

The dashboard is displayed in a compact format in the top-right corner of the chart and automatically updates when changing symbols.

Important: Free-float data depends on the information available through TradingView and may be unavailable for some securities. This indicator is intended as an informational and analysis tool only and should not be considered financial advice.

---

## Source Code

````pine
//@version=6
indicator("Small Cap Dashboard", overlay=true)

// SETTINGS
rvolLength = input.int(10, "RVOL Lookback Days", minval=2)
rsiLength = input.int(14, "RSI Length", minval=2)
atrLength = input.int(14, "ATR Length", minval=2)

// DAILY DATA
prevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
dayVolume = request.security(syminfo.tickerid, "D", volume)
dayHigh = request.security(syminfo.tickerid, "D", high)
dayLow = request.security(syminfo.tickerid, "D", low)
avgDailyVolume = request.security(syminfo.tickerid, "D", ta.sma(volume, rvolLength))

// BASIC DATA
price = close
changePct = na(prevClose) or prevClose == 0 ? na : ((price - prevClose) / prevClose) * 100

// FREE FLOAT
freeFloat = syminfo.shares_outstanding_float

// RVOL
rvol = na(avgDailyVolume) or avgDailyVolume == 0 ? na : dayVolume / avgDailyVolume

// FLOAT ROTATION
floatRotation = na(freeFloat) or freeFloat == 0 ? na : dayVolume / freeFloat

// RSI
rsi = ta.rsi(close, rsiLength)

// MACD
[macdLine, signalLine, macdHist] = ta.macd(close, 12, 26, 9)
macdBullish = macdLine > signalLine

// VWAP
vwap = ta.vwap(hlc3)
aboveVWAP = close >= vwap

// EMAS / TREND
ema9 = ta.ema(close, 9)
ema20 = ta.ema(close, 20)

bullTrend = close > vwap and ema9 > ema20
bearTrend = close < vwap and ema9 < ema20

// ATR
atr = ta.atr(atrLength)

// COLORS
green = color.rgb(35, 170, 100)
red = color.rgb(215, 60, 70)
orange = color.rgb(235, 135, 45)
yellow = color.rgb(210, 180, 55)
gray = color.rgb(75, 80, 90)
dark = color.rgb(23, 27, 35)
labelBG = color.rgb(38, 43, 54)
headerBG = color.rgb(30, 35, 46)
white = color.white

// FORMAT LARGE NUMBERS
formatNumber(float value) =>
    string result = "N/A"
    if not na(value)
        if value >= 1000000000
            result := str.tostring(value / 1000000000, "#.##") + "B"
        else if value >= 1000000
            result := str.tostring(value / 1000000, "#.##") + "M"
        else if value >= 1000
            result := str.tostring(value / 1000, "#.##") + "K"
        else
            result := str.tostring(value, "#")
    result

// DISPLAY TEXT
changeText = na(changePct) ? "N/A" : str.tostring(changePct, "#.##") + "%"
rvolText = na(rvol) ? "N/A" : str.tostring(rvol, "#.##") + "x"
rotationText = na(floatRotation) ? "N/A" : str.tostring(floatRotation, "#.##") + "x"
rsiText = na(rsi) ? "N/A" : str.tostring(rsi, "#.##")
atrText = na(atr) ? "N/A" : "$" + str.tostring(atr, format.mintick)
highText = na(dayHigh) ? "N/A" : "$" + str.tostring(dayHigh, format.mintick)
lowText = na(dayLow) ? "N/A" : "$" + str.tostring(dayLow, format.mintick)

// STATUS TEXT
macdText = macdBullish ? "BULLISH" : "BEARISH"
vwapText = aboveVWAP ? "ABOVE" : "BELOW"

string trendText = "NEUTRAL"
if bullTrend
    trendText := "BULLISH"
else if bearTrend
    trendText := "BEARISH"

// STATUS COLORS
changeColor = na(changePct) ? gray : changePct >= 0 ? green : red

rvolColor = gray
if not na(rvol)
    if rvol >= 10
        rvolColor := red
    else if rvol >= 5
        rvolColor := orange
    else if rvol >= 2
        rvolColor := green

floatColor = gray
if not na(freeFloat)
    if freeFloat < 1000000
        floatColor := red
    else if freeFloat < 5000000
        floatColor := orange
    else if freeFloat < 10000000
        floatColor := yellow

rotationColor = gray
if not na(floatRotation)
    if floatRotation >= 3
        rotationColor := red
    else if floatRotation >= 1
        rotationColor := orange
    else if floatRotation >= 0.5
        rotationColor := green

rsiColor = gray
if not na(rsi)
    if rsi >= 70
        rsiColor := red
    else if rsi <= 30
        rsiColor := green

macdColor = macdBullish ? green : red
vwapColor = aboveVWAP ? green : red

trendColor = gray
if bullTrend
    trendColor := green
else if bearTrend
    trendColor := red



// TABLE
var table dash = table.new(
    position.top_right,
    4,
    8,
    frame_width=1,
    border_width=1
)

if barstate.islast

    // HEADER
    table.cell(dash, 0, 0, syminfo.ticker, bgcolor=headerBG, text_color=white, text_size=size.normal)
    table.cell(dash, 1, 0, "SMALL CAP", bgcolor=headerBG, text_color=white)
    table.cell(dash, 2, 0, "", bgcolor=headerBG)
    table.cell(dash, 3, 0, "", bgcolor=headerBG)

    // ROW 1
    table.cell(dash, 0, 1, "Price", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 1, "$" + str.tostring(price, format.mintick), bgcolor=dark, text_color=white)

    table.cell(dash, 2, 1, "Change", bgcolor=labelBG, text_color=white)
    table.cell(dash, 3, 1, changeText, bgcolor=changeColor, text_color=white)

    // ROW 2
    table.cell(dash, 0, 2, "Volume", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 2, formatNumber(dayVolume), bgcolor=dark, text_color=white)

    table.cell(dash, 2, 2, "RVOL", bgcolor=labelBG, text_color=white)
    table.cell(dash, 3, 2, rvolText, bgcolor=rvolColor, text_color=white)

    // ROW 3
    table.cell(dash, 0, 3, "Free Float", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 3, formatNumber(freeFloat), bgcolor=floatColor, text_color=white)

    table.cell(dash, 2, 3, "Float Rot.", bgcolor=labelBG, text_color=white)
    table.cell(dash, 3, 3, rotationText, bgcolor=rotationColor, text_color=white)

    // ROW 4
    table.cell(dash, 0, 4, "RSI", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 4, rsiText, bgcolor=rsiColor, text_color=white)

    table.cell(dash, 2, 4, "MACD", bgcolor=labelBG, text_color=white)
    table.cell(dash, 3, 4, macdText, bgcolor=macdColor, text_color=white)

    // ROW 5
    table.cell(dash, 0, 5, "VWAP", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 5, vwapText, bgcolor=vwapColor, text_color=white)

    table.cell(dash, 2, 5, "Trend", bgcolor=labelBG, text_color=white)
    table.cell(dash, 3, 5, trendText, bgcolor=trendColor, text_color=white)

    // ROW 6 - DAY HIGH / DAY LOW
    table.cell(dash, 0, 6, "Day High", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 6, highText, bgcolor=dark, text_color=white)

    table.cell(dash, 2, 6, "Day Low", bgcolor=labelBG, text_color=white)
    table.cell(dash, 3, 6, lowText, bgcolor=dark, text_color=white)

    // ROW 7 - ATR
    table.cell(dash, 0, 7, "ATR", bgcolor=labelBG, text_color=white)
    table.cell(dash, 1, 7, atrText, bgcolor=dark, text_color=white)

    table.cell(dash, 2, 7, "", bgcolor=dark)
    table.cell(dash, 3, 7, "", bgcolor=dark)



// VWAP LINE
// plot(vwap, title="VWAP", linewidth=2)
````
