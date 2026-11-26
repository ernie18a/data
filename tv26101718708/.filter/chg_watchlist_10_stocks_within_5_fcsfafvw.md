# CHG% watchlist 10+ stocks (within .5%)

- url: https://www.tradingview.com/script/fCsFafVW-CHG-watchlist-10-stocks-within-5/
- type: indicator
- pine_id: PUB;2d8704d3c9e641eaa19a570d53c370a5
- version: 1.0

## Description

Im a 15 year old coder/trader and i use CHG% to determine the stocks i trade so i made this indicator to show the Change % whilst in replay mode so i can backtest (:

## Source Code

````pine
//@version=5
indicator("Sorted Stock Scanner HUD", overlay=true)

// Function
f(sym) =>
    c = request.security(sym, "1", close)
    p = request.security(sym, "D", close[1])
    (c / p - 1) * 100

// Arrays
string[] names = array.new_string()
float[] vals = array.new_float()

add(name, val) =>
    array.push(names, name)
    array.push(vals, val)

// Stocks
add("INTC", f("NASDAQ:INTC"))
add("AMD",  f("NASDAQ:AMD"))
add("NVDA", f("NASDAQ:NVDA"))
add("AMZN", f("NASDAQ:AMZN"))
add("MU",   f("NASDAQ:MU"))
add("META", f("NASDAQ:META"))
add("MSFT", f("NASDAQ:MSFT"))
add("QQQ",  f("NASDAQ:QQQ"))
add("GOOG", f("NASDAQ:GOOG"))   // kept
add("HOOD", f("NASDAQ:HOOD"))
add("COIN", f("NASDAQ:COIN"))
add("SPY",  f("AMEX:SPY"))
add("TSLA", f("NASDAQ:TSLA"))
add("NFLX", f("NASDAQ:NFLX"))
add("MA",   f("NYSE:MA"))
add("AAPL", f("NASDAQ:AAPL"))
add("ORCL", f("NYSE:ORCL"))

// Sort (highest to lowest)
for i = 0 to array.size(vals) - 2
    for j = i + 1 to array.size(vals) - 1
        if array.get(vals, j) > array.get(vals, i)
            v1 = array.get(vals, i)
            v2 = array.get(vals, j)
            n1 = array.get(names, i)
            n2 = array.get(names, j)

            array.set(vals, i, v2)
            array.set(vals, j, v1)
            array.set(names, i, n2)
            array.set(names, j, n1)

// Table
var table t = table.new(position.top_right, 2, 20)

if barstate.islast
    table.cell(t, 0, 0, "STOCK")
    table.cell(t, 1, 0, "%")

    for i = 0 to array.size(names) - 1
        table.cell(t, 0, i + 1, array.get(names, i))
        table.cell(t, 1, i + 1, str.tostring(array.get(vals, i), "#.##") + "%")
````
