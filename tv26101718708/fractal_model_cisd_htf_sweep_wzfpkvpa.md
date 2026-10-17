# fractal model + CISD + HTF Sweep

- url: https://www.tradingview.com/script/WZFpkvpA/
- type: indicator
- pine_id: PUB;b93c588f92094ad3999e8139db8e9104
- version: 1.0

## Description

// =====================================================================
// EN: fractal model + CISD + HTF Sweep Indicator (Legacy Personal Tool)
// -----------------------------------------------------------------------
// Project: fractal model + CISD + HTF Sweep
//
// What this script does:
//   - Builds a synthetic higher-timeframe (HTF) candle display from a
//     lower timeframe chart, so you can see HTF candles without
//     switching charts.
//   - Classifies a simple "Bias" (Bullish / Bearish / Range / No Bias)
//     based on whether price swept and/or closed beyond the previous
//     HTF candle's high/low.
//   - Detects swing highs/lows (pivots) and tracks "CISD" structure
//     shifts: when price sweeps a swing point and then closes back
//     through a tracked level, marking a potential change in
//     short-term direction. Optional Fibonacci extension levels are
//     drawn from the sweep/CISD points.
//   - Detects "sweep and return" setups on a chosen timeframe (price
//     pokes above/below the prior candle's high/low but closes back
//     inside it) and raises an alert/label when this happens.
//
// Status:
//   This is an OLDER personal indicator and is NO LONGER IN ACTIVE USE.
//   It is shared here as-is for educational and research purposes only.
//
// License / Use:
//   Open-sourced for learning. No warranty of accuracy or profitability.
//   This is NOT financial advice. Do not use as a sole basis for trading
//   decisions — verify behavior yourself before relying on it.
//
// Beginner notes (read this if you are new to Pine Script / trading):
//   - "HTF candles" here = candles from a Higher TimeFrame (e.g. Daily,
//     Weekly) drawn as boxes on the right side of the chart, just to
//     give visual context for the bigger trend.
//   - "CISD" (Change in State of Delivery) is a simple way some traders
//     describe price reversing direction after sweeping a recent
//     swing high/low and then closing back through it. In this script
//     it is only a visual label ("CISD+"/"CISD-") plus optional Fib
//     lines — it does NOT place any trades.
//   - "Sweep" generally means price briefly pokes past a prior high/low
//     (grabbing "liquidity") before reversing. The alert in this script
//     fires when that poke happens AND the candle closes back inside
//     the prior range.
//   - This script only draws visuals and alerts — it does not buy or
//     sell anything. Treat all signals as discussion points to study,
//     not as ready-made trade signals.
// =====================================================================
// 中文: AMD / CISD 高時間框架 Sweep 指標（個人舊版工具）
// -----------------------------------------------------------------------
// 專案名稱：fractal model + CISD + HTF Sweep
//
// 這個指標做什麼：
//   - 在低時間框架圖表上，重建一個「高時間框架（HTF）蠟燭」的視覺顯示，
//     讓你不用切換圖表就能看到高時間框架的走勢。
//   - 根據價格是否「掃過」或「收盤穿越」前一根 HTF 蠟燭的高/低點，
//     判斷一個簡單的 Bias（偏多 / 偏空 / 區間 / 無偏向）。
//   - 偵測 Swing 高低點（樞紐點），並追蹤「CISD」結構轉變：
//     當價格先掃過某個 Swing 點，之後收盤又穿回某個關卡時，
//     視為短線方向可能改變的訊號，並可選擇畫出 Fibonacci 延伸線。
//   - 在指定時間框架上偵測「Sweep and Return」：價格短暫穿出前一根
//     K 棒的高/低點，但收盤又收回原本範圍內，符合條件時觸發提示
//     標籤與 Alert。
//
// 狀態說明：
//   這是一個「舊版本指標」，目前已經停止使用。
//   在此開源僅供研究與學習用途。
//
// 授權 / 使用須知：
//   開源僅供學習參考，不保證準確性或獲利能力。
//   本指標內容「不構成投資建議」，請勿單獨依賴本指標做交易決策，
//   使用前請自行驗證其行為是否符合你的需求。
//
// 給新手的說明（如果你不熟悉 Pine Script 或交易術語，請先看這段）：
//   - 這裡的「HTF 蠟燭」是指用方框（box）畫在圖表右側的「高時間框架」
//     （例如日線、週線）蠟燭，目的只是讓你能順便看到大趨勢的視覺參考。
//   - 「CISD」（狀態轉變）是部分交易者用來描述「價格掃過近期的 Swing
//     高/低點之後，又收盤穿回原本關卡」的一種說法，象徵短線方向可能
//     轉變。在這個指標裡，CISD 只是畫出「CISD+ / CISD-」標籤與選擇性
//     的 Fib 延伸線，並不會自動下單。
//   - 「Sweep（掃單）」通常是指價格短暫穿過前一根高/低點（去掃流動性）
//     後又反轉。指標中的 Alert，是在「穿出後、收盤又收回原範圍內」時
//     才會觸發。
//   - 這個指標只負責畫圖與發出提示，不會自動買賣。請把所有訊號當作
//     學習與討論用的參考，而不是可以直接拿來下單的訊號。
// =====================================================================

## Source Code

````pine
//@version=6
indicator("fractal model + CISD + HTF Sweep", overlay=true, max_bars_back=250, max_boxes_count=100)

// Auto-selects a "sensible" higher timeframe based on the current chart timeframe
autoHTF() =>
    switch timeframe.period
        "1"      => "15"
        "5"      => "120"
        "15"     => "240"
        "60"     => "D"
        "120"     => "D"
        "240"    => "W"
        "M"    => "12M"
        "W"    => "6M"
        "D"      => "M"
        => "60"

// === User Input Settings ===
useAutoTF = input.bool(true, "Auto HTF", group="Time")
manualTF = input.timeframe("240", "Manual HTF", group="Time")
ShowGrayBox = input.bool(false, "Show Gray Box", group="Liquidity")
ShowBias = input.bool(false, "HTF Bias", group = "Liquidity")
Showhtf = input.bool(true, "HTF Candles", group = "Liquidity")
ShowpivotL = input.bool(false,"Bullish Liquidity (SwingL)", group = "Liquidity")
ShowpivotH = input.bool(false, "Bearish Liquidity (SwingH)" , group = "Liquidity")
lenght = input.int(1, 'lenght', minval=1, maxval=1000, group = "Liquidity")
tf = useAutoTF ? autoHTF() : manualTF

numb = 5  // Number of HTF candles to display (including current)

// Color settings
up_col    = color.green      // Bullish candle
up_wick   = color.green      // Bullish wick
dn_col    = color.black      // Bearish candle
dn_wick   = color.black      // Bearish wick
loc      = 10

// === HTF Data ===
[oHTF, hHTF, lHTF, cHTF] = request.security(syminfo.ticker, tf, [open, high, low, close], lookahead=barmerge.lookahead_on)
[prevHigh, prevLow, prevClose] = request.security(syminfo.tickerid, tf, [high[1], low[1], close[1]])
[currHigh, currLow, currClose] = request.security(syminfo.tickerid, tf, [high, low, close])
midpoint = (prevHigh + prevLow) / 2

// === Bias Determination Logic ===
// Beginner note: "Bias" here is just a label describing whether price
// broke and/or closed beyond the previous HTF candle's high/low.
didBreakHigh = currHigh > prevHigh
didBreakLow = currLow < prevLow
closeAboveHigh = currClose > prevHigh
closeBelowLow = currClose < prevLow
sweepHigh = currHigh > prevHigh
sweepLow = currLow < prevLow

var string bias = "No Bias"
if closeAboveHigh and not closeBelowLow
    bias := "Bullish Bias"
else if closeBelowLow and not closeAboveHigh
    bias := "Bearish Bias"
else if sweepHigh and sweepLow
    bias := "Range Bias"
else if sweepHigh
    bias := "Potential Bearish"
else if sweepLow
    bias := "Potential Bullish"
else
    bias := "No Bias"

// === HTF Candle Rendering ===
// Beginner note: these box/line objects are purely visual — they draw
// a strip of HTF candles on the chart; they don't affect any signal.
type HTF
    array<box> candle
    array<line> wickH
    array<line> wickL
    array<float> hl

var candle = HTF.new(array.new<box>(numb), array.new<line>(numb), array.new<line>(numb), array.new<float>(numb * 2))
b = bar_index

// NOTE (v6): ta.change() returns a float, so it must be compared with
// "!= 0" before using it in a boolean "and"/"if" expression.
if ta.change(oHTF) != 0 and Showhtf
    if candle.candle.size() > 0
        candle.candle.shift().delete()
        candle.wickH.shift().delete()
        candle.wickL.shift().delete()
    if candle.hl.size() >= 2
        candle.hl.shift()
        candle.hl.shift()

    candle.candle.push(box.new(b + numb * 4 + loc, math.max(oHTF, cHTF), b + numb * 4 + loc + 2, math.min(oHTF, cHTF), border_color=color.new(color.black, 100), bgcolor=oHTF > cHTF ? dn_col : up_col))
    candle.wickH.push(line.new(b + numb * 4 + loc + 1, math.max(oHTF, cHTF), b + numb * 4 + loc + 1, hHTF, color=oHTF > cHTF ? dn_wick : up_wick))
    candle.wickL.push(line.new(b + numb * 4 + loc + 1, math.min(oHTF, cHTF), b + numb * 4 + loc + 1, lHTF, color=oHTF > cHTF ? dn_wick : up_wick))
    candle.hl.push(hHTF)
    candle.hl.push(lHTF)
else
    d = loc
    for i = 0 to candle.candle.size() - 1
        x = candle.candle.get(i)
        if i < numb - 1
            x.set_left(b + d * 2)
            x.set_right(b + d * 2 + 2)
            candle.wickH.get(i).set_x1(b + d * 2 + 1)
            candle.wickH.get(i).set_x2(b + d * 2 + 1)
            candle.wickL.get(i).set_x1(b + d * 2 + 1)
            candle.wickL.get(i).set_x2(b + d * 2 + 1)
        else
            x.set_lefttop(b + d * 2, math.max(oHTF, cHTF))
            x.set_rightbottom(b + d * 2 + 2, math.min(oHTF, cHTF))
            x.set_bgcolor(oHTF > cHTF ? dn_col : up_col)
            candle.wickH.get(i).set_xy1(b + d * 2 + 1, math.max(oHTF, cHTF))
            candle.wickH.get(i).set_xy2(b + d * 2 + 1, hHTF)
            candle.wickH.get(i).set_color(oHTF > cHTF ? dn_wick : up_wick)
            candle.wickL.get(i).set_xy1(b + d * 2 + 1, math.min(oHTF, cHTF))
            candle.wickL.get(i).set_xy2(b + d * 2 + 1, lHTF)
            candle.wickL.get(i).set_color(oHTF > cHTF ? dn_wick : up_wick)
            candle.hl.set(numb * 2 - 2, hHTF)
            candle.hl.set(numb * 2 - 1, lHTF)
        d += 2

// === Bias Separator Line and Gray Box (controlled by Bias) ===
// NOTE (v6): ta.change() returns float, cast to bool with "!= 0".
newSession = ta.change(time(tf)) != 0
var int lastSessionStart = na
var int prevSessionStart = na
var label[] biasLabels = array.new<label>()
var box currBox = na
var box[] biasBoxes = array.new<box>()
var bool drawNextBiasBox = false

if newSession
    // Draw separator line marking the start of a new HTF session
    line.new(bar_index, high + syminfo.mintick, bar_index, low, xloc.bar_index, extend=extend.both, color=color.gray, style=line.style_dotted, width=1)

    // Only draw gray box when the previous segment's bias allowed it
    if not na(prevSessionStart) and drawNextBiasBox and ShowGrayBox
        topVal = math.max(prevClose, midpoint)
        botVal = math.min(prevClose, midpoint)
        newBox = box.new(left=lastSessionStart, right=bar_index, top=topVal, bottom=botVal, xloc=xloc.bar_index, border_color=color.new(color.gray, 80), bgcolor=color.new(color.gray, 80))
        array.push(biasBoxes, newBox)


    // Bias label
    if ShowBias
        lbl = label.new(bar_index, currHigh, bias, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(color.blue, 0), textcolor=color.white, size=size.small)
        array.push(biasLabels, lbl)

    // Update draw control flag for the next session
    drawNextBiasBox := bias != "Range Bias" and bias != "No Bias" and ShowGrayBox

    // Update session time tracking
    prevSessionStart := lastSessionStart
    lastSessionStart := bar_index

// Update the live (in-progress) box, shown only while bias is valid
if not na(lastSessionStart)
    if not na(currBox)
        box.delete(currBox)
    if bias != "Range Bias" and bias != "No Bias" and ShowGrayBox
        topLive = math.max(prevClose, midpoint)
        botLive = math.min(prevClose, midpoint)
        currBox := box.new(left=lastSessionStart, right=bar_index, top=topLive, bottom=botLive, xloc=xloc.bar_index, border_color=color.new(color.gray, 80), bgcolor=color.new(color.gray, 80))

//--------------------------CISD-----------------------------
// Settings (simplified)
Maximum_Sequence_Length = input.int(8, 'Max Sequence Length', minval=1, maxval=1000)
showBullCISD            = input.bool(false, 'Show CISD+')
showBearCISD            = input.bool(false, 'Show CISD-')
showFib                 = input.bool(true, 'Show Fib')

// Constants and variables
INV      = color(na)
n        = bar_index
textSize = size.tiny
cBull    = color.blue
cBear    = color.blue
cSweepH  = color.gray
cSweepL  = color.gray

// Type definitions
type bin
    line ln
    bool active
    chart.point cp1
    chart.point cp2
    bool broken = false

type swing
    chart.point cp
    line        ln
    line        wick
    bool active = false

// Initialize variables
bull  = close > open
bear  = close < open

var int         trend          = 0
var array<bin>  arrBull        = array.new<bin>()
var array<bin>  arrBear        = array.new<bin>()

var array<swing>swingsH        = array.new<swing>()
var array<swing>swingsL        = array.new<swing>()
var chart.point cp_lastPh      = chart.point.from_index(n , high)
var chart.point cp_lastPl      = chart.point.from_index(n , low )

var chart.point trackPriceBull = chart.point.from_index(na,  na )
var chart.point trackPriceBear = chart.point.from_index(na,  na )

// Detect swing highs and lows (pivot points)
ph = ta.pivothigh(lenght, lenght)
pl = ta.pivotlow(lenght, lenght)

if not na(ph) and ShowpivotH
    line.new(x1=bar_index - lenght, y1=ph, x2=bar_index + lenght, y2=ph,
             xloc=xloc.bar_index, extend=extend.none, color=color.gray, width=1)

if not na(pl) and ShowpivotL
    line.new(x1=bar_index - lenght, y1=pl, x2=bar_index + lenght, y2=pl,
             xloc=xloc.bar_index, extend=extend.none, color=color.gray, width=1)

if not na(ph)
    swingsH.push(swing.new(chart.point.from_index(n-lenght, ph)))
    cp_lastPh := chart.point.from_index(n-lenght, ph)

if not na(pl)
    swingsL.push(swing.new(chart.point.from_index(n-lenght, pl)))
    cp_lastPl := chart.point.from_index(n-lenght, pl)


if bull and bear[1]
    trackPriceBull := chart.point.from_index(n, open)

if bear and bull[1]
    trackPriceBear := chart.point.from_index(n, open)

// Sweep mode logic (Liquidity Sweep)
// Beginner note: a "sweep" of a swing high/low is detected here, then
// a line is tracked from the open after a reversal candle; if price
// later closes back through that level it becomes a "CISD" event below.
if swingsH.size() > 0
    max_bars_back(close, 1000)
    for i = swingsH.size() - 1 to 0
        s = swingsH.get(i)
        x = s.cp.index
        y = s.cp.price
        if n - x > Maximum_Sequence_Length
            swingsH.remove(i)
        else if not s.active
            if high > y and showBearCISD
                s.ln   := line.new(x, y, n, y, color=cSweepH)
                s.wick := line.new(n, y, n, high, color=cSweepH, width=3)
                s.active := true
                swingsH.set(i, s)
                good = true
                if good
                    arrBull.push(bin.new(line.new(trackPriceBull.index, trackPriceBull.price, n, trackPriceBull.price, color=color.new(cBull, 40)),true,chart.point.from_index(cp_lastPh.index, cp_lastPh.price),chart.point.from_index(n, cp_lastPh.price)))

if swingsL.size() > 0
    max_bars_back(close, 1000)
    for i = swingsL.size() - 1 to 0
        s = swingsL.get(i)
        x = s.cp.index
        y = s.cp.price
        if n - x > Maximum_Sequence_Length
            swingsL.remove(i)
        else if not s.active
            if low < y and showBullCISD
                s.ln   := line.new(x, y, n, y, color=cSweepL)
                s.wick := line.new(n, y, n, low, color=cSweepL, width=3)
                s.active := true
                swingsL.set(i, s)
                good = true
                if good
                    arrBear.push(bin.new(line.new(trackPriceBear.index, trackPriceBear.price, n, trackPriceBear.price, color=color.new(cBear, 40)),true,chart.point.from_index(cp_lastPl.index, cp_lastPl.price),chart.point.from_index(n, cp_lastPl.price)))

// Display CISD structure shift and signal (and draw Fib extension)
// Beginner note: "CISD-" means price swept a high and then closed back
// below the tracked level (potential bearish shift); "CISD+" is the
// mirror case for swept lows (potential bullish shift).
if arrBull.size() > 0 and showBearCISD
    for i = arrBull.size() - 1 to 0
        get = arrBull.get(i)
        get.ln.set_x2(n)
        x1 = get.ln.get_x1()
        if n - x1 > Maximum_Sequence_Length
            get.ln.delete()
            arrBull.remove(i)
        else if close < get.ln.get_y2()
            get.ln.set_color(cBear)
            trend := -1
            x = math.ceil(math.avg(x1, n))
            label.new(x, get.ln.get_y2(), style=label.style_label_up, textcolor=cBear, text='CISD-', size=textSize, color=INV)

            sweep_start_x = get.cp1.index
            sweep_price_y = get.cp1.price
            cisd_price_y  = get.ln.get_y2()

            if showFib
                delta = cisd_price_y - sweep_price_y
                fibLevels = array.from(0.0, 1.0, 1.5, 2.0, 2.5, 4.0)

                for j = 0 to array.size(fibLevels) - 1
                    lv = array.get(fibLevels, j)
                    price = cisd_price_y + delta * lv
                    line.new(n, price, n + 4, price, color=color.black, style=line.style_dashed)
                    label.new(n + 4, price, text="Fib " + str.tostring(lv), textcolor=color.black, size=size.tiny, style=label.style_none)

            arrBull.remove(i)


if arrBear.size() > 0 and showBullCISD
    for i = arrBear.size() - 1 to 0
        get = arrBear.get(i)
        get.ln.set_x2(n)
        x1 = get.ln.get_x1()
        if n - x1 > Maximum_Sequence_Length
            get.ln.delete()
            arrBear.remove(i)
        else if close > get.ln.get_y2()
            get.ln.set_color(cBull)
            trend := 1
            x = math.ceil(math.avg(x1, n))
            label.new(x, get.ln.get_y2(), style=label.style_label_down, textcolor=cBull, text='CISD+', size=textSize, color=INV)

            sweep_start_x = get.cp1.index
            sweep_price_y = get.cp1.price
            cisd_price_y  = get.ln.get_y2()

            if showFib
                delta = sweep_price_y - cisd_price_y
                fibLevels = array.from(0.0, 1.0, 1.5, 2.0, 2.5, 4.0)

                for j = 0 to array.size(fibLevels) - 1
                    lv = array.get(fibLevels, j)
                    price = cisd_price_y - delta * lv
                    line.new(n, price, n + 4, price, color=color.black, style=line.style_dashed)
                    label.new(n + 4, price, text="Fib " + str.tostring(lv), textcolor=color.black, size=size.tiny, style=label.style_none)

            arrBear.remove(i)


// === Label Configuration ===
max_labels = input.int(0, "Maximum # of Alert Labels", minval=0, maxval=500)
label_color = color.blue
text_color = color.white
label_size_val = size.small
var array<label> label_array = array.new<label>()

// === Sweep and Return Logic ===
// Beginner note: this checks, on the chosen HTF timeframe, whether the
// candle poked above/below the prior candle's high/low but closed back
// inside that range — a classic "fakeout" / liquidity grab pattern.
sweep_and_return(tf) =>
    h = request.security(syminfo.tickerid, tf, high, lookahead=barmerge.lookahead_on)
    l = request.security(syminfo.tickerid, tf, low, lookahead=barmerge.lookahead_on)
    c = request.security(syminfo.tickerid, tf, close, lookahead=barmerge.lookahead_on)
    prev_h = request.security(syminfo.tickerid, tf, high[1], lookahead=barmerge.lookahead_on)
    prev_l = request.security(syminfo.tickerid, tf, low[1], lookahead=barmerge.lookahead_on)
    sweep_hi = h > prev_h and c <= prev_h
    sweep_lo = l < prev_l and c >= prev_l
    [sweep_hi, sweep_lo]

// === Track Alert State ===
var bool alerted = false
var bool sweep_hi = false
var bool sweep_lo = false

if na(tf)
    sweep_hi := false
    sweep_lo := false
else
    [sh, sl] = sweep_and_return(tf)
    sweep_hi := sh
    sweep_lo := sl

new_alert = (sweep_hi or sweep_lo) and not alerted
alerted := new_alert ? true : alerted

// === Reset Alert State on New HTF Bar ===
// NOTE (v6): ta.change() returns float, cast to bool with "!= 0".
if not na(tf) and ta.change(time(tf)) != 0
    alerted := false

// === Manage Labels ===
manage_labels(l, max_count) =>
    array.push(label_array, l)
    while array.size(label_array) > max_count
        old = array.shift(label_array)
        label.delete(old)

// === Draw Label on Chart ===
if new_alert and not na(tf)
    price_level = sweep_hi ? high : low
    l = label.new(x=bar_index,y=price_level,text= " Sweep",style=sweep_hi ? label.style_label_down : label.style_label_up,color=label_color,textcolor=text_color,size=label_size_val,xloc=xloc.bar_index,yloc=yloc.price)
    manage_labels(l, max_labels)

// === Alert ===
alertcondition(new_alert, title= " Sweep and Return", message=" timeframe: Initial candle swept previous candle and closed within its range")
````
