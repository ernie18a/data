#  Asia & London Killzone Module IndicatorThis indicator is base

- url: https://www.tradingview.com/script/MgoI7F6L/
- type: indicator
- pine_id: PUB;2ea2f257bbf94ffcb90c7cadef4b233a
- version: 1.0

## Description

🌏 Asia Module
Trading Session: 19:00 ~ 21:00 (New York Time)
Features:

18:00 Opening Price Marker — Marks the daily 18:00 NY open (CME futures daily candle open) as a directional bias confluence

Price below open → Higher probability of long setups
Price above open → Higher probability of short setups


18:00-19:00 High/Low — Automatically marks the highs and lows of the first hour as liquidity reference points
Asia Trading Session Box — Highlights the 19:00-21:00 entry window with a translucent background


🇬🇧 London Module (Gold Only)
Trading Session: 03:00 ~ 04:00 (New York Time)
Features:

Full Asia High/Low (Buyside / Sellside Liquidity) — Marks the high and low of the complete Asian session (19:00 ~ 03:00) as liquidity targets for the London session
2:00 ~ 3:00 High/Low — Marks the highs and lows of the hour preceding the London open
London Trading Session Box — Highlights the 03:00-04:00 entry window
Entry Logic: Wait for one side of liquidity to be swept, then enter on reversal confirmation. Target the opposite liquidity zone


⚙️ Key Features

✅ Intraday Logic — Each new trading day starts at 18:00 NY time. All previous day's markings are automatically cleared to keep the chart clean
✅ Auto DST Handling — Default tracks America/New_York timezone with automatic Daylight Saving Time adjustment. Can also be manually locked to UTC-5 or UTC-4
✅ Smart Label Offset — Labels from different sessions are horizontally staggered, remaining clearly readable even when high/low points overlap on the same candle
✅ Full Style Customization — Colors, line widths, line styles, label sizes, and transparency are all adjustable


🎨 Customization Options

Timezone Mode: Auto / Lock Standard Time (UTC-5) / Lock Daylight Saving (UTC-4)
Color Settings: 9 independent color controls for all elements
Line Styles: 4 line groups with individual width (1-5) and style (Solid / Dashed / Dotted) settings
Label Styles: 5 size options, optional price display, transparency, text color, and arrow direction


📌 Usage Recommendations

Set chart timezone to UTC-4 or America/New_York to ensure session markers align correctly with NY time
Recommended timeframes: 5-minute / 15-minute charts
Suitable instruments: XAUUSD (Gold), major Forex pairs, ES/NQ index futures
The London Module is designed specifically for Gold — for other instruments, the Asia Module alone is recommended


⚠️ Disclaimer
This indicator is for technical analysis reference only and does not constitute investment advice. Trading involves risk. Please trade responsibly based on your own risk tolerance.

## Source Code

````pine
//@version=5
indicator("亞盤 & 倫敦模組交易指標", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// =============================================================================
// 設定參數
// =============================================================================

// --- 時區設定 ---
grpTz = "時區設定 (冬夏令)"
tzMode = input.string("自動", "時區模式", options=["自動", "鎖定冬令時(UTC-5)", "鎖定夏令時(UTC-4)"], group=grpTz, tooltip="自動=跟著美東時間自動切換 / 鎖定=固定該偏移")

tz = tzMode == "鎖定冬令時(UTC-5)" ? "UTC-5" : tzMode == "鎖定夏令時(UTC-4)" ? "UTC-4" : "America/New_York"

// --- 亞盤模組設定 ---
grpAsia = "亞盤模組設定"
showAsiaModule       = input.bool(true, "啟用亞盤模組", group=grpAsia)
showAsiaSession      = input.bool(true, "顯示亞盤交易時段 (19:00-21:00)", group=grpAsia)
showOpenPrice        = input.bool(true, "1. 標記 18:00 開盤價", group=grpAsia)
showAsiaHighLow      = input.bool(true, "2. 標記 18:00-19:00 最高低點", group=grpAsia)

// --- 倫敦模組設定 ---
grpLondon = "倫敦模組設定 (只限黃金)"
showLondonSession    = input.bool(true, "顯示倫敦交易時段 (3:00-4:00)", group=grpLondon)
showLondonHighLow    = input.bool(true, "1. 標記亞洲高低點 + 2:00-3:00 高低點", group=grpLondon)

// =============================================================================
// 樣式設定 - 顏色
// =============================================================================
grpColor = "樣式 - 顏色"
asiaSessionColor     = input.color(color.new(color.teal, 85), "亞盤交易時段背景", group=grpColor)
londonSessionColor   = input.color(color.new(color.blue, 85), "倫敦交易時段背景", group=grpColor)
openPriceColor       = input.color(color.yellow, "18:00 開盤價線", group=grpColor)
asiaHighColor        = input.color(color.red,    "亞盤高點 [18-19]", group=grpColor)
asiaLowColor         = input.color(color.green,  "亞盤低點 [18-19]", group=grpColor)
asiaFullHighColor    = input.color(color.fuchsia, "亞洲完整高點 [Asia]Buy", group=grpColor)
asiaFullLowColor     = input.color(color.aqua,    "亞洲完整低點 [Asia]Sell", group=grpColor)
preLondonHighColor   = input.color(color.orange, "倫敦前高點 [2-3]", group=grpColor)
preLondonLowColor    = input.color(color.lime,   "倫敦前低點 [2-3]", group=grpColor)

// =============================================================================
// 樣式設定 - 線條
// =============================================================================
grpLine = "樣式 - 線條"
openLineWidth        = input.int(2, "18:00 開盤價線粗細", minval=1, maxval=5, group=grpLine)
openLineStyleStr     = input.string("實線", "18:00 開盤價線樣式", options=["實線", "虛線", "點線"], group=grpLine)
asiaHighLowLineWidth = input.int(2, "亞盤高低點線粗細 [18-19]", minval=1, maxval=5, group=grpLine)
asiaHighLowStyleStr  = input.string("虛線", "亞盤高低點線樣式 [18-19]", options=["實線", "虛線", "點線"], group=grpLine)
asiaFullLineWidth    = input.int(2, "亞洲完整高低點線粗細", minval=1, maxval=5, group=grpLine)
asiaFullStyleStr     = input.string("實線", "亞洲完整高低點線樣式", options=["實線", "虛線", "點線"], group=grpLine)
preLondonLineWidth   = input.int(2, "倫敦前高低點線粗細 [2-3]", minval=1, maxval=5, group=grpLine)
preLondonStyleStr    = input.string("虛線", "倫敦前高低點線樣式 [2-3]", options=["實線", "虛線", "點線"], group=grpLine)

// 字串轉 line.style 常數
strToLineStyle(s) =>
    s == "實線" ? line.style_solid : s == "虛線" ? line.style_dashed : line.style_dotted

openLineStyle    = strToLineStyle(openLineStyleStr)
asiaHighLowStyle = strToLineStyle(asiaHighLowStyleStr)
asiaFullStyle    = strToLineStyle(asiaFullStyleStr)
preLondonStyle   = strToLineStyle(preLondonStyleStr)

// =============================================================================
// 樣式設定 - 區塊與邊框
// =============================================================================
grpBox = "樣式 - 區塊"
sessionBoxBorderWidth = input.int(1, "交易時段邊框粗細", minval=0, maxval=5, group=grpBox)
sessionBoxBorderStyleStr = input.string("實線", "交易時段邊框樣式", options=["實線", "虛線", "點線"], group=grpBox)
showSessionBorder    = input.bool(true, "顯示交易時段邊框", group=grpBox)

strToBoxBorderStyle(s) =>
    s == "實線" ? line.style_solid : s == "虛線" ? line.style_dashed : line.style_dotted

sessionBoxBorderStyle = strToBoxBorderStyle(sessionBoxBorderStyleStr)

// =============================================================================
// 樣式設定 - 標籤
// =============================================================================
grpLabel = "樣式 - 標籤"
showLabels           = input.bool(true, "顯示標籤", group=grpLabel)
labelSize            = input.string("tiny", "標籤大小", options=["tiny", "small", "normal", "large", "huge"], group=grpLabel)
showPriceInLabel     = input.bool(false, "標籤顯示價格數值", group=grpLabel)
labelOffsetBars      = input.int(3, "標籤水平偏移 (K線數)", minval=0, maxval=20, group=grpLabel, tooltip="不同時段標籤的水平錯開距離")
labelTransparency    = input.int(30, "標籤背景透明度 %", minval=0, maxval=100, group=grpLabel)
labelTextColor       = input.color(color.white, "標籤文字顏色", group=grpLabel)
labelStyleHighStr    = input.string("向下箭頭", "高點標籤樣式", options=["向下箭頭", "向左", "向右", "標籤無箭頭"], group=grpLabel)
labelStyleLowStr     = input.string("向上箭頭", "低點標籤樣式", options=["向上箭頭", "向左", "向右", "標籤無箭頭"], group=grpLabel)

labelSizeConst = labelSize == "tiny" ? size.tiny : labelSize == "small" ? size.small : labelSize == "normal" ? size.normal : labelSize == "large" ? size.large : size.huge

strToLabelStyleHigh(s) =>
    s == "向下箭頭" ? label.style_label_down : s == "向左" ? label.style_label_left : s == "向右" ? label.style_label_right : label.style_label_center

strToLabelStyleLow(s) =>
    s == "向上箭頭" ? label.style_label_up : s == "向左" ? label.style_label_left : s == "向右" ? label.style_label_right : label.style_label_center

labelStyleHigh = strToLabelStyleHigh(labelStyleHighStr)
labelStyleLow  = strToLabelStyleLow(labelStyleLowStr)

// =============================================================================
// 自訂「交易日 ID」
// =============================================================================
shiftedTime  = time - 18 * 60 * 60 * 1000
tradingDayId = year(shiftedTime, tz) * 10000 + month(shiftedTime, tz) * 100 + dayofmonth(shiftedTime, tz)
isNewDay = ta.change(tradingDayId) != 0

// =============================================================================
// 輔助函式
// =============================================================================
makeLabel(prefix, price) =>
    showPriceInLabel ? prefix + " " + str.tostring(price, format.mintick) : prefix

// =============================================================================
// 亞盤模組
// =============================================================================

var box   asiaSessionBox   = na
var line  openLine1800     = na
var label openLabel1800    = na
var line  asiaHighLine     = na
var line  asiaLowLine      = na
var label asiaHighLabel    = na
var label asiaLowLabel     = na

var float asiaHigh = na
var float asiaLow  = na
var int   asiaHighBar = na
var int   asiaLowBar  = na
var float openPrice1800 = na
var int   openBar1800   = na
var bool  open1800Marked = false

if isNewDay
    if not na(asiaSessionBox)
        box.delete(asiaSessionBox)
    asiaSessionBox := na
    if not na(openLine1800)
        line.delete(openLine1800)
    openLine1800 := na
    if not na(openLabel1800)
        label.delete(openLabel1800)
    openLabel1800 := na
    if not na(asiaHighLine)
        line.delete(asiaHighLine)
    asiaHighLine := na
    if not na(asiaLowLine)
        line.delete(asiaLowLine)
    asiaLowLine := na
    if not na(asiaHighLabel)
        label.delete(asiaHighLabel)
    asiaHighLabel := na
    if not na(asiaLowLabel)
        label.delete(asiaLowLabel)
    asiaLowLabel := na
    asiaHigh := na
    asiaLow  := na
    asiaHighBar := na
    asiaLowBar  := na
    openPrice1800 := na
    openBar1800   := na
    open1800Marked := false

// --- 亞盤交易時段 (19:00 ~ 21:00) ---
inAsiaSession = not na(time(timeframe.period, "1900-2100", tz))

if showAsiaModule and showAsiaSession
    if inAsiaSession and not inAsiaSession[1]
        borderColor = showSessionBorder ? color.new(color.teal, 50) : color.new(color.teal, 100)
        asiaSessionBox := box.new(bar_index, high, bar_index, low, bgcolor=asiaSessionColor, border_color=borderColor, border_width=sessionBoxBorderWidth, border_style=sessionBoxBorderStyle, extend=extend.none)
    if inAsiaSession and not na(asiaSessionBox)
        box.set_right(asiaSessionBox, bar_index)
        box.set_top(asiaSessionBox, math.max(box.get_top(asiaSessionBox), high))
        box.set_bottom(asiaSessionBox, math.min(box.get_bottom(asiaSessionBox), low))

// --- 功能 1: 標記 18:00 開盤價 ---
if showAsiaModule and showOpenPrice and isNewDay and not open1800Marked
    openPrice1800 := open
    openBar1800   := bar_index
    openLine1800  := line.new(bar_index, openPrice1800, bar_index, openPrice1800, color=openPriceColor, width=openLineWidth, style=openLineStyle, extend=extend.none)
    if showLabels
        openLabel1800 := label.new(bar_index, openPrice1800, makeLabel("18:00 Open", openPrice1800), style=label.style_label_right, color=color.new(openPriceColor, labelTransparency), textcolor=labelTextColor, size=labelSizeConst)
    open1800Marked := true

if showAsiaModule and showOpenPrice and not na(openLine1800)
    line.set_x2(openLine1800, bar_index)

// --- 功能 2: 標記 18:00 ~ 19:00 之間的最高低點 ---
inAsiaHighLowRange = not na(time(timeframe.period, "1800-1900", tz))

if showAsiaModule and showAsiaHighLow and inAsiaHighLowRange
    if na(asiaHigh) or high > asiaHigh
        asiaHigh := high
        asiaHighBar := bar_index
    if na(asiaLow) or low < asiaLow
        asiaLow := low
        asiaLowBar := bar_index

if showAsiaModule and showAsiaHighLow and not inAsiaHighLowRange and inAsiaHighLowRange[1] and na(asiaHighLine) and not na(asiaHigh)
    asiaHighLine := line.new(asiaHighBar, asiaHigh, bar_index, asiaHigh, color=asiaHighColor, width=asiaHighLowLineWidth, style=asiaHighLowStyle, extend=extend.none)
    asiaLowLine  := line.new(asiaLowBar,  asiaLow,  bar_index, asiaLow,  color=asiaLowColor,  width=asiaHighLowLineWidth, style=asiaHighLowStyle, extend=extend.none)
    if showLabels
        asiaHighLabel := label.new(asiaHighBar, asiaHigh, makeLabel("[18-19]高", asiaHigh), style=labelStyleHigh, color=color.new(asiaHighColor, labelTransparency), textcolor=labelTextColor, size=labelSizeConst)
        asiaLowLabel  := label.new(asiaLowBar,  asiaLow,  makeLabel("[18-19]低", asiaLow),  style=labelStyleLow,  color=color.new(asiaLowColor,  labelTransparency), textcolor=labelTextColor, size=labelSizeConst)

if showAsiaModule and showAsiaHighLow and not na(asiaHighLine)
    line.set_x2(asiaHighLine, bar_index)
if showAsiaModule and showAsiaHighLow and not na(asiaLowLine)
    line.set_x2(asiaLowLine, bar_index)

// =============================================================================
// 倫敦模組
// =============================================================================

var line  asiaFullHighLine  = na
var line  asiaFullLowLine   = na
var label asiaFullHighLabel = na
var label asiaFullLowLabel  = na
var line  preLondonHighLine = na
var line  preLondonLowLine  = na
var label preLondonHighLabel = na
var label preLondonLowLabel  = na
var box   londonSessionBox   = na

var float asiaFullHigh = na
var float asiaFullLow  = na
var int   asiaFullHighBar = na
var int   asiaFullLowBar  = na
var float preLondonHigh = na
var float preLondonLow  = na
var int   preLondonHighBar = na
var int   preLondonLowBar  = na
var bool  asiaFullDrawn = false
var bool  preLondonDrawn = false

if isNewDay
    if not na(asiaFullHighLine)
        line.delete(asiaFullHighLine)
    asiaFullHighLine := na
    if not na(asiaFullLowLine)
        line.delete(asiaFullLowLine)
    asiaFullLowLine := na
    if not na(asiaFullHighLabel)
        label.delete(asiaFullHighLabel)
    asiaFullHighLabel := na
    if not na(asiaFullLowLabel)
        label.delete(asiaFullLowLabel)
    asiaFullLowLabel := na
    if not na(preLondonHighLine)
        line.delete(preLondonHighLine)
    preLondonHighLine := na
    if not na(preLondonLowLine)
        line.delete(preLondonLowLine)
    preLondonLowLine := na
    if not na(preLondonHighLabel)
        label.delete(preLondonHighLabel)
    preLondonHighLabel := na
    if not na(preLondonLowLabel)
        label.delete(preLondonLowLabel)
    preLondonLowLabel := na
    if not na(londonSessionBox)
        box.delete(londonSessionBox)
    londonSessionBox := na
    asiaFullHigh := na
    asiaFullLow  := na
    asiaFullHighBar := na
    asiaFullLowBar  := na
    preLondonHigh := na
    preLondonLow  := na
    preLondonHighBar := na
    preLondonLowBar  := na
    asiaFullDrawn := false
    preLondonDrawn := false

// --- 功能 1: 標記亞洲完整高低點 (19:00 ~ 03:00) ---
inAsiaFullSession = not na(time(timeframe.period, "1900-0300", tz))

if showLondonHighLow and inAsiaFullSession
    if na(asiaFullHigh) or high > asiaFullHigh
        asiaFullHigh := high
        asiaFullHighBar := bar_index
    if na(asiaFullLow) or low < asiaFullLow
        asiaFullLow := low
        asiaFullLowBar := bar_index

isAt0300 = hour(time, tz) == 3 and minute(time, tz) == 0
if showLondonHighLow and isAt0300 and not asiaFullDrawn and not na(asiaFullHigh)
    asiaFullHighLine := line.new(asiaFullHighBar, asiaFullHigh, bar_index, asiaFullHigh, color=asiaFullHighColor, width=asiaFullLineWidth, style=asiaFullStyle, extend=extend.none)
    asiaFullLowLine  := line.new(asiaFullLowBar,  asiaFullLow,  bar_index, asiaFullLow,  color=asiaFullLowColor,  width=asiaFullLineWidth, style=asiaFullStyle, extend=extend.none)
    if showLabels
        asiaFullHighLabel := label.new(asiaFullHighBar + labelOffsetBars, asiaFullHigh, makeLabel("[Asia]Buy", asiaFullHigh), style=labelStyleHigh, color=color.new(asiaFullHighColor, labelTransparency), textcolor=labelTextColor, size=labelSizeConst)
        asiaFullLowLabel  := label.new(asiaFullLowBar  + labelOffsetBars, asiaFullLow,  makeLabel("[Asia]Sell", asiaFullLow), style=labelStyleLow,  color=color.new(asiaFullLowColor,  labelTransparency), textcolor=labelTextColor, size=labelSizeConst)
    asiaFullDrawn := true

if showLondonHighLow and not na(asiaFullHighLine)
    line.set_x2(asiaFullHighLine, bar_index)
if showLondonHighLow and not na(asiaFullLowLine)
    line.set_x2(asiaFullLowLine, bar_index)

// --- 功能 1: 標記 2:00 ~ 3:00 之間的最高低點 ---
inPreLondonRange = not na(time(timeframe.period, "0200-0300", tz))

if showLondonHighLow and inPreLondonRange
    if na(preLondonHigh) or high > preLondonHigh
        preLondonHigh := high
        preLondonHighBar := bar_index
    if na(preLondonLow) or low < preLondonLow
        preLondonLow := low
        preLondonLowBar := bar_index

if showLondonHighLow and isAt0300 and not preLondonDrawn and not na(preLondonHigh)
    preLondonHighLine := line.new(preLondonHighBar, preLondonHigh, bar_index, preLondonHigh, color=preLondonHighColor, width=preLondonLineWidth, style=preLondonStyle, extend=extend.none)
    preLondonLowLine  := line.new(preLondonLowBar,  preLondonLow,  bar_index, preLondonLow,  color=preLondonLowColor,  width=preLondonLineWidth, style=preLondonStyle, extend=extend.none)
    if showLabels
        preLondonHighLabel := label.new(preLondonHighBar + labelOffsetBars * 2, preLondonHigh, makeLabel("[2-3]高", preLondonHigh), style=labelStyleHigh, color=color.new(preLondonHighColor, labelTransparency), textcolor=labelTextColor, size=labelSizeConst)
        preLondonLowLabel  := label.new(preLondonLowBar  + labelOffsetBars * 2, preLondonLow,  makeLabel("[2-3]低", preLondonLow),  style=labelStyleLow,  color=color.new(preLondonLowColor,  labelTransparency), textcolor=labelTextColor, size=labelSizeConst)
    preLondonDrawn := true

if showLondonHighLow and not na(preLondonHighLine)
    line.set_x2(preLondonHighLine, bar_index)
if showLondonHighLow and not na(preLondonLowLine)
    line.set_x2(preLondonLowLine, bar_index)

// --- 倫敦交易時段 (3:00 ~ 4:00) ---
inLondonSession = not na(time(timeframe.period, "0300-0400", tz))

if showLondonSession
    if inLondonSession and not inLondonSession[1]
        borderColor = showSessionBorder ? color.new(color.blue, 50) : color.new(color.blue, 100)
        londonSessionBox := box.new(bar_index, high, bar_index, low, bgcolor=londonSessionColor, border_color=borderColor, border_width=sessionBoxBorderWidth, border_style=sessionBoxBorderStyle, extend=extend.none)
    if inLondonSession and not na(londonSessionBox)
        box.set_right(londonSessionBox, bar_index)
        box.set_top(londonSessionBox, math.max(box.get_top(londonSessionBox), high))
        box.set_bottom(londonSessionBox, math.min(box.get_bottom(londonSessionBox), low))
````
