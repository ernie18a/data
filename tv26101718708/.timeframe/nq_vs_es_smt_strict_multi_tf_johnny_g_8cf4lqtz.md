# NQ vs ES SMT Strict Multi TF Johnny g

- url: https://www.tradingview.com/script/8CF4lqTz-NQ-vs-ES-SMT-Strict-Multi-TF-Johnny-g/
- type: indicator
- pine_id: PUB;cdb02a32cad7436e8e6c4828ea4f462e
- version: 1.0

## Description

multi timeframe set to view set in real time without having to change charts

## Source Code

````pine
//@version=5
indicator("NQ vs ES SMT Strict Multi TF", overlay=true, max_lines_count=500, max_labels_count=500)

nq = input.symbol("CME_MINI:NQ1!", "NQ Symbol")
es = input.symbol("CME_MINI:ES1!", "ES Symbol")

lb = input.int(2, "Left Bars")
rb = input.int(2, "Right Bars")

showLines = input.bool(true, "Show SMT Lines")
showLabels = input.bool(true, "Show SMT Labels")

txt(v) => v == 1 ? "Bull" : v == -1 ? "Bear" : "-"
col(v) => v == 1 ? color.green : v == -1 ? color.red : color.gray

nqH1 = request.security(nq, "1", high)
nqL1 = request.security(nq, "1", low)
esH1 = request.security(es, "1", high)
esL1 = request.security(es, "1", low)
nqPH1 = ta.pivothigh(nqH1, lb, rb)
nqPL1 = ta.pivotlow(nqL1, lb, rb)
esPH1 = ta.pivothigh(esH1, lb, rb)
esPL1 = ta.pivotlow(esL1, lb, rb)
tf1 = not na(nqPL1) and not na(esPL1) and nqPL1 < ta.valuewhen(not na(nqPL1), nqPL1, 1) and esPL1 >= ta.valuewhen(not na(esPL1), esPL1, 1) ? 1 : not na(nqPH1) and not na(esPH1) and nqPH1 > ta.valuewhen(not na(nqPH1), nqPH1, 1) and esPH1 <= ta.valuewhen(not na(esPH1), esPH1, 1) ? -1 : 0

nqH2 = request.security(nq, "2", high)
nqL2 = request.security(nq, "2", low)
esH2 = request.security(es, "2", high)
esL2 = request.security(es, "2", low)
nqPH2 = ta.pivothigh(nqH2, lb, rb)
nqPL2 = ta.pivotlow(nqL2, lb, rb)
esPH2 = ta.pivothigh(esH2, lb, rb)
esPL2 = ta.pivotlow(esL2, lb, rb)
tf2 = not na(nqPL2) and not na(esPL2) and nqPL2 < ta.valuewhen(not na(nqPL2), nqPL2, 1) and esPL2 >= ta.valuewhen(not na(esPL2), esPL2, 1) ? 1 : not na(nqPH2) and not na(esPH2) and nqPH2 > ta.valuewhen(not na(nqPH2), nqPH2, 1) and esPH2 <= ta.valuewhen(not na(esPH2), esPH2, 1) ? -1 : 0

nqH3 = request.security(nq, "3", high)
nqL3 = request.security(nq, "3", low)
esH3 = request.security(es, "3", high)
esL3 = request.security(es, "3", low)
nqPH3 = ta.pivothigh(nqH3, lb, rb)
nqPL3 = ta.pivotlow(nqL3, lb, rb)
esPH3 = ta.pivothigh(esH3, lb, rb)
esPL3 = ta.pivotlow(esL3, lb, rb)
tf3 = not na(nqPL3) and not na(esPL3) and nqPL3 < ta.valuewhen(not na(nqPL3), nqPL3, 1) and esPL3 >= ta.valuewhen(not na(esPL3), esPL3, 1) ? 1 : not na(nqPH3) and not na(esPH3) and nqPH3 > ta.valuewhen(not na(nqPH3), nqPH3, 1) and esPH3 <= ta.valuewhen(not na(esPH3), esPH3, 1) ? -1 : 0

nqH4 = request.security(nq, "4", high)
nqL4 = request.security(nq, "4", low)
esH4 = request.security(es, "4", high)
esL4 = request.security(es, "4", low)
nqPH4 = ta.pivothigh(nqH4, lb, rb)
nqPL4 = ta.pivotlow(nqL4, lb, rb)
esPH4 = ta.pivothigh(esH4, lb, rb)
esPL4 = ta.pivotlow(esL4, lb, rb)
tf4 = not na(nqPL4) and not na(esPL4) and nqPL4 < ta.valuewhen(not na(nqPL4), nqPL4, 1) and esPL4 >= ta.valuewhen(not na(esPL4), esPL4, 1) ? 1 : not na(nqPH4) and not na(esPH4) and nqPH4 > ta.valuewhen(not na(nqPH4), nqPH4, 1) and esPH4 <= ta.valuewhen(not na(esPH4), esPH4, 1) ? -1 : 0

nqH5 = request.security(nq, "5", high)
nqL5 = request.security(nq, "5", low)
esH5 = request.security(es, "5", high)
esL5 = request.security(es, "5", low)
nqPH5 = ta.pivothigh(nqH5, lb, rb)
nqPL5 = ta.pivotlow(nqL5, lb, rb)
esPH5 = ta.pivothigh(esH5, lb, rb)
esPL5 = ta.pivotlow(esL5, lb, rb)
tf5 = not na(nqPL5) and not na(esPL5) and nqPL5 < ta.valuewhen(not na(nqPL5), nqPL5, 1) and esPL5 >= ta.valuewhen(not na(esPL5), esPL5, 1) ? 1 : not na(nqPH5) and not na(esPH5) and nqPH5 > ta.valuewhen(not na(nqPH5), nqPH5, 1) and esPH5 <= ta.valuewhen(not na(esPH5), esPH5, 1) ? -1 : 0

nqH15 = request.security(nq, "15", high)
nqL15 = request.security(nq, "15", low)
esH15 = request.security(es, "15", high)
esL15 = request.security(es, "15", low)
nqPH15 = ta.pivothigh(nqH15, lb, rb)
nqPL15 = ta.pivotlow(nqL15, lb, rb)
esPH15 = ta.pivothigh(esH15, lb, rb)
esPL15 = ta.pivotlow(esL15, lb, rb)
tf15 = not na(nqPL15) and not na(esPL15) and nqPL15 < ta.valuewhen(not na(nqPL15), nqPL15, 1) and esPL15 >= ta.valuewhen(not na(esPL15), esPL15, 1) ? 1 : not na(nqPH15) and not na(esPH15) and nqPH15 > ta.valuewhen(not na(nqPH15), nqPH15, 1) and esPH15 <= ta.valuewhen(not na(esPH15), esPH15, 1) ? -1 : 0

nqH60 = request.security(nq, "60", high)
nqL60 = request.security(nq, "60", low)
esH60 = request.security(es, "60", high)
esL60 = request.security(es, "60", low)
nqPH60 = ta.pivothigh(nqH60, lb, rb)
nqPL60 = ta.pivotlow(nqL60, lb, rb)
esPH60 = ta.pivothigh(esH60, lb, rb)
esPL60 = ta.pivotlow(esL60, lb, rb)
tf60 = not na(nqPL60) and not na(esPL60) and nqPL60 < ta.valuewhen(not na(nqPL60), nqPL60, 1) and esPL60 >= ta.valuewhen(not na(esPL60), esPL60, 1) ? 1 : not na(nqPH60) and not na(esPH60) and nqPH60 > ta.valuewhen(not na(nqPH60), nqPH60, 1) and esPH60 <= ta.valuewhen(not na(esPH60), esPH60, 1) ? -1 : 0

nqH240 = request.security(nq, "240", high)
nqL240 = request.security(nq, "240", low)
esH240 = request.security(es, "240", high)
esL240 = request.security(es, "240", low)
nqPH240 = ta.pivothigh(nqH240, lb, rb)
nqPL240 = ta.pivotlow(nqL240, lb, rb)
esPH240 = ta.pivothigh(esH240, lb, rb)
esPL240 = ta.pivotlow(esL240, lb, rb)
tf240 = not na(nqPL240) and not na(esPL240) and nqPL240 < ta.valuewhen(not na(nqPL240), nqPL240, 1) and esPL240 >= ta.valuewhen(not na(esPL240), esPL240, 1) ? 1 : not na(nqPH240) and not na(esPH240) and nqPH240 > ta.valuewhen(not na(nqPH240), nqPH240, 1) and esPH240 <= ta.valuewhen(not na(esPH240), esPH240, 1) ? -1 : 0

var table t = table.new(position.top_right, 2, 9)

table.cell(t, 0, 0, "TF", bgcolor=color.black, text_color=color.white)
table.cell(t, 1, 0, "SMT", bgcolor=color.black, text_color=color.white)

table.cell(t, 0, 1, "1m")
table.cell(t, 1, 1, txt(tf1), bgcolor=col(tf1), text_color=color.white)

table.cell(t, 0, 2, "2m")
table.cell(t, 1, 2, txt(tf2), bgcolor=col(tf2), text_color=color.white)

table.cell(t, 0, 3, "3m")
table.cell(t, 1, 3, txt(tf3), bgcolor=col(tf3), text_color=color.white)

table.cell(t, 0, 4, "4m")
table.cell(t, 1, 4, txt(tf4), bgcolor=col(tf4), text_color=color.white)

table.cell(t, 0, 5, "5m")
table.cell(t, 1, 5, txt(tf5), bgcolor=col(tf5), text_color=color.white)

table.cell(t, 0, 6, "15m")
table.cell(t, 1, 6, txt(tf15), bgcolor=col(tf15), text_color=color.white)

table.cell(t, 0, 7, "1H")
table.cell(t, 1, 7, txt(tf60), bgcolor=col(tf60), text_color=color.white)

table.cell(t, 0, 8, "4H")
table.cell(t, 1, 8, txt(tf240), bgcolor=col(tf240), text_color=color.white)

chartPH = ta.pivothigh(high, lb, rb)
chartPL = ta.pivotlow(low, lb, rb)

esChartH = request.security(es, timeframe.period, high)
esChartL = request.security(es, timeframe.period, low)
esChartPH = ta.pivothigh(esChartH, lb, rb)
esChartPL = ta.pivotlow(esChartL, lb, rb)

prevChartPH = ta.valuewhen(not na(chartPH), chartPH, 1)
prevChartPL = ta.valuewhen(not na(chartPL), chartPL, 1)

prevEsPH = ta.valuewhen(not na(esChartPH), esChartPH, 1)
prevEsPL = ta.valuewhen(not na(esChartPL), esChartPL, 1)

bearChart = not na(chartPH) and not na(esChartPH) and chartPH > prevChartPH and esChartPH <= prevEsPH
bullChart = not na(chartPL) and not na(esChartPL) and chartPL < prevChartPL and esChartPL >= prevEsPL

prevHighX = ta.valuewhen(not na(chartPH), bar_index - rb, 1)
prevLowX = ta.valuewhen(not na(chartPL), bar_index - rb, 1)

if showLines and bearChart
    line.new(prevHighX, prevChartPH, bar_index - rb, chartPH, color=color.red, width=2)
    if showLabels
        label.new(bar_index - rb, chartPH, "SMT Bear", style=label.style_label_down, color=color.red, textcolor=color.white)

if showLines and bullChart
    line.new(prevLowX, prevChartPL, bar_index - rb, chartPL, color=color.green, width=2)
    if showLabels
        label.new(bar_index - rb, chartPL, "SMT Bull", style=label.style_label_up, color=color.green, textcolor=color.white)

bull = tf1 == 1 or tf2 == 1 or tf3 == 1 or tf4 == 1 or tf5 == 1 or tf15 == 1 or tf60 == 1 or tf240 == 1
bear = tf1 == -1 or tf2 == -1 or tf3 == -1 or tf4 == -1 or tf5 == -1 or tf15 == -1 or tf60 == -1 or tf240 == -1

alertcondition(bull, "Bull SMT", "Bullish SMT detected")
alertcondition(bear, "Bear SMT", "Bearish SMT detected")
````
