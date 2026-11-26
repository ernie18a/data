# EMA Trend Table & Daily Levels (Fully Restored)

- url: https://www.tradingview.com/script/wUAMzI45-EMA-Trend-Table-Daily-Levels-Fully-Restored/
- type: indicator
- pine_id: PUB;992c9270acb24bc5bbdf6d308bed8fd7
- version: 1.0

## Description

EMA  5 strategy, This strategy is built on EMA 200 high and low channel and when price is above ema200 only buy and below only sell based on price action

## Source Code

````pine
//@version=6
indicator("EMA Trend Table & Daily Levels (Fully Restored)", overlay=true)

// ================= EMA INPUTS =================
groupEMA = "EMAs"

showAllEMAs  = input.bool(true, "Show EMA Lines", group=groupEMA)
showEMATable = input.bool(true, "Show EMA Table", group=groupEMA)

len1 = input.int(5,   "EMA 1 Length", group=groupEMA)
len2 = input.int(21,  "EMA 2 Length", group=groupEMA)
len3 = input.int(48,  "EMA 3 Length", group=groupEMA)
len4 = input.int(200, "EMA 4 Length", group=groupEMA)

// ================= EMA SOURCE CONTROL (PRESERVED) =================
groupSRC = "EMA Source (OHLC)"

src1 = input.string("Close", "EMA 1 Source", options=["Open","High","Low","Close"], group=groupSRC)
src2 = input.string("Close", "EMA 2 Source", options=["Open","High","Low","Close"], group=groupSRC)
src3 = input.string("Close", "EMA 3 Source", options=["Open","High","Low","Close"], group=groupSRC)
src4 = input.string("Close", "EMA 4 Source", options=["Open","High","Low","Close"], group=groupSRC)

// ================= SAFE SOURCE FUNCTION (NO SYNTAX ERROR) =================
getSrc(sel) =>
    sel == "Open" ? open :
     sel == "High" ? high :
     sel == "Low"  ? low  :
     close

// ================= EMA CALC =================
ema1 = ta.ema(getSrc(src1), len1)
ema2 = ta.ema(getSrc(src2), len2)
ema3 = ta.ema(getSrc(src3), len3)
ema4 = ta.ema(getSrc(src4), len4)

// ================= TREND =================
t1 = close > ema1 ? "Bullish" : "Bearish"
t2 = close > ema2 ? "Bullish" : "Bearish"
t3 = close > ema3 ? "Bullish" : "Bearish"
t4 = close > ema4 ? "Bullish" : "Bearish"

// ================= COLORS =================
bull = color.lime
bear = color.red
neu  = color.orange

overallBull = t1=="Bullish" and t2=="Bullish" and t3=="Bullish" and t4=="Bullish"
overallBear = t1=="Bearish" and t2=="Bearish" and t3=="Bearish" and t4=="Bearish"

overall = overallBull ? "Bullish" : overallBear ? "Bearish" : "Mixed"
oc = overallBull ? bull : overallBear ? bear : neu

// ================= EMA TABLE (UNCHANGED STRUCTURE) =================
var table t = table.new(position.top_right, 3, 6)

if showEMATable

    table.cell(t, 0, 0, "EMA", bgcolor=color.navy, text_color=color.white)
    table.cell(t, 1, 0, "LENGTH", bgcolor=color.navy, text_color=color.white)
    table.cell(t, 2, 0, "TREND", bgcolor=color.navy, text_color=color.white)

    table.cell(t, 0, 1, "EMA1")
    table.cell(t, 1, 1, str.tostring(len1))
    table.cell(t, 2, 1, t1, bgcolor=t1=="Bullish"?bull:bear)

    table.cell(t, 0, 2, "EMA2")
    table.cell(t, 1, 2, str.tostring(len2))
    table.cell(t, 2, 2, t2, bgcolor=t2=="Bullish"?bull:bear)

    table.cell(t, 0, 3, "EMA3")
    table.cell(t, 1, 3, str.tostring(len3))
    table.cell(t, 2, 3, t3, bgcolor=t3=="Bullish"?bull:bear)

    table.cell(t, 0, 4, "EMA4")
    table.cell(t, 1, 4, str.tostring(len4))
    table.cell(t, 2, 4, t4, bgcolor=t4=="Bullish"?bull:bear)

    table.cell(t, 0, 5, "OVERALL")
    table.cell(t, 1, 5, "")
    table.cell(t, 2, 5, overall, bgcolor=oc)

// ================= EMA PLOTS (UNCHANGED) =================
plot(showAllEMAs ? ema1 : na, color=color.blue, title="EMA 1")
plot(showAllEMAs ? ema2 : na, color=color.orange, title="EMA 2")
plot(showAllEMAs ? ema3 : na, color=color.purple, title="EMA 3")
plot(showAllEMAs ? ema4 : na, color=color.red, title="EMA 4")

// ================= DAILY LEVELS (FULL RESTORED) =================
groupLevels = "Daily Levels"

showPrevHL    = input.bool(true, "Show Previous Day H/L", group=groupLevels)
showCurrHL    = input.bool(true, "Show Current Day H/L", group=groupLevels)
showPrevClose = input.bool(true, "Show Previous Day Close", group=groupLevels)
showCurrOpen  = input.bool(true, "Show Current Day Open", group=groupLevels)

pdhColor = input.color(color.blue, "Prev High", group=groupLevels)
pdlColor = input.color(color.blue, "Prev Low", group=groupLevels)
pdcColor = input.color(color.teal, "Prev Close", group=groupLevels)
cdoColor = input.color(color.orange, "Curr Open", group=groupLevels)
cdhColor = input.color(color.green, "Curr High", group=groupLevels)
cdlColor = input.color(color.red, "Curr Low", group=groupLevels)

ph = request.security(syminfo.tickerid, "D", high[1])
pl = request.security(syminfo.tickerid, "D", low[1])
pc = request.security(syminfo.tickerid, "D", close[1])

ch = request.security(syminfo.tickerid, "D", high)
cl = request.security(syminfo.tickerid, "D", low)
co = request.security(syminfo.tickerid, "D", open)

newDay = timeframe.change("D")

var line lph = na
var line lpl = na
var line lpc = na
var line lco = na
var line lch = na
var line lcl = na

if barstate.isfirst or newDay
    line.delete(lph)
    line.delete(lpl)
    line.delete(lpc)
    line.delete(lco)
    line.delete(lch)
    line.delete(lcl)

    if showPrevHL
        lph := line.new(bar_index, ph, bar_index+50, ph, color=pdhColor, width=2)
        lpl := line.new(bar_index, pl, bar_index+50, pl, color=pdlColor, width=2)

    if showPrevClose
        lpc := line.new(bar_index, pc, bar_index+50, pc, color=pdcColor, width=2)

    if showCurrOpen
        lco := line.new(bar_index, co, bar_index+50, co, color=cdoColor, width=2)

    if showCurrHL
        lch := line.new(bar_index, ch, bar_index+50, ch, color=cdhColor, width=2)
        lcl := line.new(bar_index, cl, bar_index+50, cl, color=cdlColor, width=2)

if not na(lch)
    line.set_y1(lch, ch)
    line.set_y2(lch, ch)

if not na(lcl)
    line.set_y1(lcl, cl)
    line.set_y2(lcl, cl)
````
