# TechnoFunda

- url: https://www.tradingview.com/script/dImF6NnI-TechnoFunda/
- type: indicator
- pine_id: PUB;15272871266a4418855db71e23b5ea95
- version: 1.0

## Description

TechnoFunda  combines fundamental and technical analysis into a single dashboard.
Features:
• ROE > 15%
• Debt/Equity < 0.5
• Operating Margin > 15%
• Positive Net Income
• EMA50 > EMA200
• RSI > 50
• ADX > 20
• Volume > SMA20
• 52-Week High Proximity
Ratings:
8-9 = Excellent
6-7 = Strong
4-5 = Average
0-3 = Weak
Suitable for investors and positional traders.

## Source Code

````pine
//@version=6
indicator("TechnoFunda", overlay=true)

//================ FUNDAMENTAL DATA =================
netIncome = request.financial(syminfo.tickerid, "NET_INCOME", "FY")
equity = request.financial(syminfo.tickerid, "TOTAL_EQUITY", "FY")
debt = request.financial(syminfo.tickerid, "TOTAL_DEBT", "FY")
opMargin = request.financial(syminfo.tickerid, "OPERATING_MARGIN", "FY")

roe = equity != 0 ? (netIncome / equity) * 100 : na
deRatio = equity != 0 ? debt / equity : na

//================ TECHNICAL DATA =================
ema50 = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

rsiValue = ta.rsi(close, 14)

diLength = 14
adxLength = 14
[plusDI, minusDI, adxValue] = ta.dmi(diLength, adxLength)

volSMA20 = ta.sma(volume, 20)

high52 = ta.highest(high, 252)
proximity = high52 != 0 ? close / high52 * 100 : na

//================ CONDITIONS =================
c1 = roe > 15
c2 = deRatio < 0.5
c3 = opMargin > 15
c4 = netIncome > 0
c5 = ema50 > ema200
c6 = rsiValue > 50
c7 = adxValue > 20
c8 = volume > volSMA20
c9 = proximity > 90

//================ SCORE =================
score = 0
score := score + (c1 ? 1 : 0)
score := score + (c2 ? 1 : 0)
score := score + (c3 ? 1 : 0)
score := score + (c4 ? 1 : 0)
score := score + (c5 ? 1 : 0)
score := score + (c6 ? 1 : 0)
score := score + (c7 ? 1 : 0)
score := score + (c8 ? 1 : 0)
score := score + (c9 ? 1 : 0)

//================ RATING =================
rating = "WEAK"

if score >= 8
    rating := "EXCELLENT"
else if score >= 6
    rating := "STRONG"
else if score >= 4
    rating := "AVERAGE"

//================ TABLE =================
var table t = table.new(position.bottom_right, 4, 12, border_width=1)

status(cond) =>
    cond ? "PASS" : "FAIL"

if barstate.islast
    table.cell(t, 0, 0, "Metric", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 1, 0, "Value", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 2, 0, "Ideal", bgcolor=color.blue, text_color=color.white)
    table.cell(t, 3, 0, "Status", bgcolor=color.blue, text_color=color.white)

    table.cell(t, 0, 1, "ROE")
    table.cell(t, 1, 1, str.tostring(roe, "#.##") + "%")
    table.cell(t, 2, 1, ">15%")
    table.cell(t, 3, 1, status(c1), bgcolor=c1 ? color.green : color.red)

    table.cell(t, 0, 2, "Debt/Equity")
    table.cell(t, 1, 2, str.tostring(deRatio, "#.##"))
    table.cell(t, 2, 2, "<0.50")
    table.cell(t, 3, 2, status(c2), bgcolor=c2 ? color.green : color.red)

    table.cell(t, 0, 3, "Operating Margin")
    table.cell(t, 1, 3, str.tostring(opMargin, "#.##") + "%")
    table.cell(t, 2, 3, ">15%")
    table.cell(t, 3, 3, status(c3), bgcolor=c3 ? color.green : color.red)

    table.cell(t, 0, 4, "Positive Income")
    table.cell(t, 1, 4, netIncome > 0 ? "Yes" : "No")
    table.cell(t, 2, 4, "Positive")
    table.cell(t, 3, 4, status(c4), bgcolor=c4 ? color.green : color.red)

    table.cell(t, 0, 5, "EMA50 > EMA200")
    table.cell(t, 1, 5, c5 ? "Yes" : "No")
    table.cell(t, 2, 5, "Bullish")
    table.cell(t, 3, 5, status(c5), bgcolor=c5 ? color.green : color.red)

    table.cell(t, 0, 6, "RSI")
    table.cell(t, 1, 6, str.tostring(rsiValue, "#.##"))
    table.cell(t, 2, 6, ">50")
    table.cell(t, 3, 6, status(c6), bgcolor=c6 ? color.green : color.red)

    table.cell(t, 0, 7, "ADX")
    table.cell(t, 1, 7, str.tostring(adxValue, "#.##"))
    table.cell(t, 2, 7, ">20")
    table.cell(t, 3, 7, status(c7), bgcolor=c7 ? color.green : color.red)

    table.cell(t, 0, 8, "Volume > SMA20")
    table.cell(t, 1, 8, c8 ? "High" : "Low")
    table.cell(t, 2, 8, "Yes")
    table.cell(t, 3, 8, status(c8), bgcolor=c8 ? color.green : color.red)

    table.cell(t, 0, 9, "52W High Proximity")
    table.cell(t, 1, 9, str.tostring(proximity, "#.##") + "%")
    table.cell(t, 2, 9, ">90%")
    table.cell(t, 3, 9, status(c9), bgcolor=c9 ? color.green : color.red)

    table.cell(t, 0, 10, "Score", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 10, str.tostring(score) + "/9", bgcolor=color.black, text_color=color.white)

    table.cell(t, 0, 11, "Rating", bgcolor=color.black, text_color=color.white)
    table.cell(t, 1, 11, rating, bgcolor=color.black, text_color=color.white)
````
