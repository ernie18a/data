# Intraday Key Levels

- url: https://www.tradingview.com/script/y958MLtN-Intraday-Key-Levels/
- type: indicator
- pine_id: PUB;3191007c99f04aaf84894ea6c1bdc9b5
- version: 1.0

## Description

Daily/Weekly MA's
                                                                              
  A clean overlay indicator that plots static daily and weekly moving averages
   as flat horizontal lines on intraday charts — no curling, no slope on the  
  live bar.
                                                                              
  Features:                                                 
  - 3 Daily MAs and 2 Weekly MAs with EMA/SMA toggle
  - Yesterday's High, Low, and Close levels                                   
  - All MAs calculated from RTH closes only (9:30 AM – 4:00 PM ET), excluding
  extended hours                                                              
  - Lines update once at market close and stay flat until the next session    
  ends                                                                        
  - Clean breaks between days — no diagonal drops when values change          
  - Color-matched labels showing MA length, type, and current value 
  - Fully customizable colors, line width, and visibility toggles per group   
                                                                              
  How it works:                                                               
  MAs are computed manually from RTH session closes rather than using         
  request.security, ensuring values remain static throughout the trading day  
  and don't recalculate on every tick. Yesterday's HLC levels flip immediately
   at the RTH close so they're available during after-hours and premarket.    
                                                            
  Best used on: Intraday timeframes (1m–60m). Lines automatically hide on     
  daily/weekly/monthly charts.

## Source Code

````pine
//@version=6
indicator('Daily/Weekly MA\'s', overlay = true, max_labels_count = 500, max_lines_count = 500)

isIntraday = timeframe.isintraday

// ── Daily MAs ──
showDaily = input.bool(true, 'Show Daily MAs', group = 'Daily Settings')
dailyMaType = input.string('EMA', 'Daily MA Type', options = ['EMA', 'SMA'], group = 'Daily Settings')
dailyMa1Length = input.int(9, 'MA 1', minval = 1, group = 'Daily Settings', inline = 'D1')
dailyColor1 = input.color(#4169E1, '', group = 'Daily Settings', inline = 'D1')
dailyMa2Length = input.int(21, 'MA 2', minval = 1, group = 'Daily Settings', inline = 'D2')
dailyColor2 = input.color(#FFD700, '', group = 'Daily Settings', inline = 'D2')
dailyMa3Length = input.int(50, 'MA 3', minval = 1, group = 'Daily Settings', inline = 'D3')
dailyColor3 = input.color(#7B68EE, '', group = 'Daily Settings', inline = 'D3')

// ── Weekly MAs ──
showWeekly = input.bool(true, 'Show Weekly MAs', group = 'Weekly Settings')
weeklyMaType = input.string('EMA', 'Weekly MA Type', options = ['EMA', 'SMA'], group = 'Weekly Settings')
weeklyMa1Length = input.int(9, 'MA 1', minval = 1, group = 'Weekly Settings', inline = 'W1')
weeklyColor1 = input.color(#D4A017, '', group = 'Weekly Settings', inline = 'W1')
weeklyMa2Length = input.int(21, 'MA 2', minval = 1, group = 'Weekly Settings', inline = 'W2')
weeklyColor2 = input.color(#008080, '', group = 'Weekly Settings', inline = 'W2')

lineWidth = input.int(2, 'Line Width', minval = 1, maxval = 5, group = 'Display')

showYestOHLC = input.bool(true, 'Show Yesterday HLC', group = 'Yesterday HLC')
yHighColor = input.color(#808080, 'High', group = 'Yesterday HLC', inline = 'YH')
yLowColor = input.color(#808080, 'Low', group = 'Yesterday HLC', inline = 'YL')
yCloseColor = input.color(#808080, 'Close', group = 'Yesterday HLC', inline = 'YC')

// ── Session detection ──
isRTH = not na(time(timeframe.period, '0930-1600:23456', 'America/New_York'))
var bool wasRTH = false

// ── Yesterday HLC (needs prev/curr flip) ──
var float currSessHigh = na, var float currSessLow = na, var float currSessClose = na
var float prevSessHigh = na, var float prevSessLow = na, var float prevSessClose = na

// ── Daily MA single values (NO prev/curr) ──
var array<float> dailyCloses = array.new_float(0)
var float dailyMa1 = na, var float dailyMa2 = na, var float dailyMa3 = na
var float dEma1 = na, var float dEma2 = na, var float dEma3 = na

// ── Weekly MA single values (NO prev/curr) ──
var array<float> weeklyCloses = array.new_float(0)
var float weeklyMa1 = na, var float weeklyMa2 = na
var float wEma1 = na, var float wEma2 = na
var float lastWeeklyClose = na
var int lastWeekId = na

getSma(arr, len) =>
    sz = array.size(arr)
    if sz >= len
        sum = 0.0
        for i = 0 to len - 1
            sum += array.get(arr, sz - 1 - i)
        sum / len
    else
        na

// ── Session logic ──
if isRTH
    if not wasRTH
        prevSessHigh := currSessHigh
        prevSessLow := currSessLow
        prevSessClose := currSessClose
        currSessHigh := high
        currSessLow := low
    else
        currSessHigh := math.max(currSessHigh, high)
        currSessLow := math.min(currSessLow, low)
    currSessClose := close
    lastWeeklyClose := close

// RTH just ended — update daily MAs once
if wasRTH and not isRTH and not na(currSessClose)
    array.push(dailyCloses, currSessClose)
    if array.size(dailyCloses) > 200
        array.shift(dailyCloses)
    float k1 = 2.0 / (dailyMa1Length + 1)
    float k2 = 2.0 / (dailyMa2Length + 1)
    float k3 = 2.0 / (dailyMa3Length + 1)
    dEma1 := na(dEma1) ? currSessClose : currSessClose * k1 + dEma1 * (1 - k1)
    dEma2 := na(dEma2) ? currSessClose : currSessClose * k2 + dEma2 * (1 - k2)
    dEma3 := na(dEma3) ? currSessClose : currSessClose * k3 + dEma3 * (1 - k3)
    dailyMa1 := dailyMaType == 'EMA' ? dEma1 : getSma(dailyCloses, dailyMa1Length)
    dailyMa2 := dailyMaType == 'EMA' ? dEma2 : getSma(dailyCloses, dailyMa2Length)
    dailyMa3 := dailyMaType == 'EMA' ? dEma3 : getSma(dailyCloses, dailyMa3Length)
    int currWeekId = year(time) * 100 + weekofyear(time)
    if not na(lastWeekId) and currWeekId != lastWeekId and not na(lastWeeklyClose)
        array.push(weeklyCloses, lastWeeklyClose)
        if array.size(weeklyCloses) > 200
            array.shift(weeklyCloses)
        float wk1 = 2.0 / (weeklyMa1Length + 1)
        float wk2 = 2.0 / (weeklyMa2Length + 1)
        wEma1 := na(wEma1) ? lastWeeklyClose : lastWeeklyClose * wk1 + wEma1 * (1 - wk1)
        wEma2 := na(wEma2) ? lastWeeklyClose : lastWeeklyClose * wk2 + wEma2 * (1 - wk2)
        weeklyMa1 := weeklyMaType == 'EMA' ? wEma1 : getSma(weeklyCloses, weeklyMa1Length)
        weeklyMa2 := weeklyMaType == 'EMA' ? wEma2 : getSma(weeklyCloses, weeklyMa2Length)
    lastWeekId := currWeekId

wasRTH := isRTH

// ── Display values ──
// Yesterday HLC still uses prev/curr flip (values reset each session)
yHigh = isRTH ? prevSessHigh : currSessHigh
yLow = isRTH ? prevSessLow : currSessLow
yClose = isRTH ? prevSessClose : currSessClose
// MAs use single values — no flip needed, they stay constant until next RTH close

fmtPrice(val) => str.tostring(val, format.mintick)
dColor1 = color.new(dailyColor1, 10)
dColor2 = color.new(dailyColor2, 10)
dColor3 = color.new(dailyColor3, 10)
wColor1 = color.new(weeklyColor1, 10)
wColor2 = color.new(weeklyColor2, 10)
yHColor = color.new(yHighColor, 50)
yLColor = color.new(yLowColor, 50)
yCColor = color.new(yCloseColor, 50)

dMa1Changed = ta.change(dailyMa1) != 0
dMa2Changed = ta.change(dailyMa2) != 0
dMa3Changed = ta.change(dailyMa3) != 0
wMa1Changed = ta.change(weeklyMa1) != 0
wMa2Changed = ta.change(weeklyMa2) != 0
yHighChanged = ta.change(yHigh) != 0
yLowChanged = ta.change(yLow) != 0
yCloseChanged = ta.change(yClose) != 0

plot(showDaily and isIntraday and not dMa1Changed ? dailyMa1 : na, 'Daily MA 1', color = dColor1, linewidth = math.max(1, lineWidth), style = plot.style_linebr)
plot(showDaily and isIntraday and not dMa2Changed ? dailyMa2 : na, 'Daily MA 2', color = dColor2, linewidth = math.max(1, lineWidth), style = plot.style_linebr)
plot(showDaily and isIntraday and not dMa3Changed ? dailyMa3 : na, 'Daily MA 3', color = dColor3, linewidth = math.max(1, lineWidth), style = plot.style_linebr)
plot(showWeekly and isIntraday and not wMa1Changed ? weeklyMa1 : na, 'Weekly MA 1', color = wColor1, linewidth = math.max(1, lineWidth), style = plot.style_linebr)
plot(showWeekly and isIntraday and not wMa2Changed ? weeklyMa2 : na, 'Weekly MA 2', color = wColor2, linewidth = math.max(1, lineWidth), style = plot.style_linebr)
plot(showYestOHLC and isIntraday and not yHighChanged ? yHigh : na, 'Yesterday High', color = yHColor, linewidth = 1, style = plot.style_linebr)
plot(showYestOHLC and isIntraday and not yLowChanged ? yLow : na, 'Yesterday Low', color = yLColor, linewidth = 1, style = plot.style_linebr)
plot(showYestOHLC and isIntraday and not yCloseChanged ? yClose : na, 'Yesterday Close', color = yCColor, linewidth = 1, style = plot.style_linebr)

transparent = color.new(color.black, 100)
var label dMa1Lbl = na, var label dMa2Lbl = na, var label dMa3Lbl = na
var label wMa1Lbl = na, var label wMa2Lbl = na
var label yHighLbl = na, var label yLowLbl = na, var label yCloseLbl = na

if showDaily and isIntraday
    label.delete(dMa1Lbl), label.delete(dMa2Lbl), label.delete(dMa3Lbl)
    dMa1Lbl := label.new(bar_index, dailyMa1, str.tostring(dailyMa1Length) + 'd ' + dailyMaType + ' (' + fmtPrice(dailyMa1) + ')', style = label.style_label_left, textcolor = dColor1, color = transparent, size = size.small)
    dMa2Lbl := label.new(bar_index, dailyMa2, str.tostring(dailyMa2Length) + 'd ' + dailyMaType + ' (' + fmtPrice(dailyMa2) + ')', style = label.style_label_left, textcolor = dColor2, color = transparent, size = size.small)  
    dMa3Lbl := label.new(bar_index, dailyMa3, str.tostring(dailyMa3Length) + 'd ' + dailyMaType + ' (' + fmtPrice(dailyMa3) + ')', style = label.style_label_left, textcolor = dColor3, color = transparent, size = size.small)

if showWeekly and isIntraday
    label.delete(wMa1Lbl), label.delete(wMa2Lbl)
    wMa1Lbl := label.new(bar_index, weeklyMa1, str.tostring(weeklyMa1Length) + 'w ' + weeklyMaType + ' (' + fmtPrice(weeklyMa1) + ')', style = label.style_label_left, textcolor = wColor1, color = transparent, size = size.small)
    wMa2Lbl := label.new(bar_index, weeklyMa2, str.tostring(weeklyMa2Length) + 'w ' + weeklyMaType + ' (' + fmtPrice(weeklyMa2) + ')', style = label.style_label_left, textcolor = wColor2, color = transparent, size = size.small)

if showYestOHLC and isIntraday
    label.delete(yHighLbl), label.delete(yLowLbl), label.delete(yCloseLbl)
    yHighLbl := label.new(bar_index, yHigh, 'Yesterday\'s High (' + fmtPrice(yHigh) + ')', style = label.style_label_left, textcolor = yHColor, color = transparent, size = size.small)
    yLowLbl := label.new(bar_index, yLow, 'Yesterday\'s Low (' + fmtPrice(yLow) + ')', style = label.style_label_left, textcolor = yLColor, color = transparent, size = size.small)
    yCloseLbl := label.new(bar_index, yClose, 'Yesterday\'s Close (' + fmtPrice(yClose) + ')', style = label.style_label_left, textcolor = yCColor, color = transparent, size = size.small)
````
