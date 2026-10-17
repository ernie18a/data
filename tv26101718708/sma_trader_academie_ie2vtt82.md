# SMA Trader Academie

- url: https://www.tradingview.com/script/Ie2Vtt82-SMA-Trader-Academie/
- type: indicator
- pine_id: PUB;21cfd7740f7647b18295debe11711943
- version: 1.0

## Description

indicateur de trader académie. MA 50,100,200 Daily

## Source Code

````pine
//@version=6
indicator("SMA Trader Academie", overlay=true, max_lines_count=500)

// ===== Inputs =====
priceChangePercents = input.string("0", "Future Price change %", options=["50","40","30","20","10","0","-10","-20","-30","-40","-50"])
projBars = input.int(60, "Projection bars (how far to the right)", minval=1, maxval=150)

showSMA50  = input.bool(true,  "Show SMA 50")
showSMA100 = input.bool(true,  "Show SMA 100")
showSMA200 = input.bool(true,  "Show SMA 200")

color50  = input.color(color.blue,  "SMA 50 Color")
color100 = input.color(color.green, "SMA 100 Color")
color200 = input.color(color.red,   "SMA 200 Color")

// ===== Function: future SMA =====
futureSMA(int _len, int _futureOffset) =>
    int x = _futureOffset
    if x > _len - 1
        x := _len - 1

    float total = 0.0
    for j = 0 to (_len - 1 - x)
        total += close[j]

    float pct = str.tonumber(priceChangePercents)
    float futPrice = close * (100.0 + pct) / 100.0
    (total + x * futPrice) / _len

// ===== Current values =====
float v50  = futureSMA(50,  0)
float v100 = futureSMA(100, 0)
float v200 = futureSMA(200, 0)

// Plot current lines
plot(showSMA50  ? v50  : na, color=color50,  title="SMA 50 (Scenario)")
plot(showSMA100 ? v100 : na, color=color100, title="SMA 100 (Scenario)")
plot(showSMA200 ? v200 : na, color=color200, title="SMA 200 (Scenario)")

// ===== Line storage =====
var line[] lines50  = array.new_line()
var line[] lines100 = array.new_line()
var line[] lines200 = array.new_line()

// ✅ FIX: guard when array is empty
deleteLines(line[] arr) =>
    int sz = array.size(arr)
    if sz > 0
        for k = 0 to sz - 1
            line ln = array.get(arr, k)
            line.delete(ln)
        array.clear(arr)

// ===== Draw limited projections on last bar only =====
if barstate.islast
    deleteLines(lines50)
    deleteLines(lines100)
    deleteLines(lines200)

    if showSMA50
        float lastV = v50
        for i = 1 to projBars
            int x1 = bar_index + i - 1
            int x2 = bar_index + i
            float curV = futureSMA(50, i)
            line ln = line.new(x1, lastV, x2, curV, color=color50, style=line.style_dotted, width=1)
            array.push(lines50, ln)
            lastV := curV

    if showSMA100
        float lastV = v100
        for i = 1 to projBars
            int x1 = bar_index + i - 1
            int x2 = bar_index + i
            float curV = futureSMA(100, i)
            line ln = line.new(x1, lastV, x2, curV, color=color100, style=line.style_dotted, width=1)
            array.push(lines100, ln)
            lastV := curV

    if showSMA200
        float lastV = v200
        for i = 1 to projBars
            int x1 = bar_index + i - 1
            int x2 = bar_index + i
            float curV = futureSMA(200, i)
            line ln = line.new(x1, lastV, x2, curV, color=color200, style=line.style_dotted, width=1)
            array.push(lines200, ln)
            lastV := curV
````
