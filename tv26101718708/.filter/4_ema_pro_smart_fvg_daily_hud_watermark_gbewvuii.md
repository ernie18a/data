# 4 EMA Pro + Smart FVG + Daily HUD + Watermark

- url: https://www.tradingview.com/script/gBEWvUIi/
- type: indicator
- pine_id: PUB;10a323bc7a6647dc92d28e05136c2d9c
- version: 3.0

## Description

新增EMA表格直觀
蠟燭偏見直觀
失衡區破50%不顯示

## Source Code

````pine
//@version=6
indicator("4 EMA Pro + Smart FVG + Daily HUD + Watermark", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ══════════════════════════════════════════════
// ① EMA 快線設定
// ══════════════════════════════════════════════
groupEma1 = "① EMA 快線設定"
showEma1  = input.bool(true, "顯示 EMA 1", group=groupEma1)
lenEma1   = input.int(20,  "EMA 1 週期", minval=1, group=groupEma1)
srcEma1   = input.source(close, "EMA 1 來源", group=groupEma1)
colEma1   = input.color(color.new(color.aqua, 0),    "EMA 1 顏色", group=groupEma1)
widEma1   = 2

// ══════════════════════════════════════════════
// ② EMA 中快線設定
// ══════════════════════════════════════════════
groupEma2 = "② EMA 中快線設定"
showEma2  = input.bool(true, "顯示 EMA 2", group=groupEma2)
lenEma2   = input.int(50,  "EMA 2 週期", minval=1, group=groupEma2)
srcEma2   = input.source(close, "EMA 2 來源", group=groupEma2)
colEma2   = input.color(color.new(color.orange, 0),  "EMA 2 顏色", group=groupEma2)
widEma2   = 2

// ══════════════════════════════════════════════
// ③ EMA 中慢線設定
// ══════════════════════════════════════════════
groupEma3 = "③ EMA 中慢線設定"
showEma3  = input.bool(true, "顯示 EMA 3", group=groupEma3)
lenEma3   = input.int(100, "EMA 3 週期", minval=1, group=groupEma3)
srcEma3   = input.source(close, "EMA 3 來源", group=groupEma3)
colEma3   = input.color(color.new(color.fuchsia, 0), "EMA 3 顏色", group=groupEma3)
widEma3   = 2

// ══════════════════════════════════════════════
// ④ EMA 慢線設定
// ══════════════════════════════════════════════
groupEma4 = "④ EMA 慢線設定"
showEma4  = input.bool(true, "顯示 EMA 4", group=groupEma4)
lenEma4   = input.int(200, "EMA 4 週期", minval=1, group=groupEma4)
srcEma4   = input.source(close, "EMA 4 來源", group=groupEma4)
colEma4   = input.color(color.new(color.yellow, 0),  "EMA 4 顏色", group=groupEma4)
widEma4   = 2

// ══════════════════════════════════════════════
// ⑤ EMA 顯示優化設定
// ══════════════════════════════════════════════
groupStyle   = "⑤ EMA 顯示優化設定"
showFill     = input.bool(true,  "顯示 EMA 區間填色",     group=groupStyle)
showBg       = input.bool(false, "依多空排列改變背景",     group=groupStyle)
showTable    = input.bool(true,  "顯示 EMA 狀態表格",     group=groupStyle)
tablePosInp  = input.string("右上", "表格位置",  options=["右上","右下","左上","左下"], group=groupStyle)
tableSizeInp = input.string("正常", "表格字體大小", options=["小","正常","大"],          group=groupStyle)

// ── EMA 計算 ──
ema1 = ta.ema(srcEma1, lenEma1)
ema2 = ta.ema(srcEma2, lenEma2)
ema3 = ta.ema(srcEma3, lenEma3)
ema4 = ta.ema(srcEma4, lenEma4)

// ── 繪製四條 EMA ──
p1 = plot(showEma1 ? ema1 : na, title="EMA 1", color=colEma1, linewidth=widEma1)
p2 = plot(showEma2 ? ema2 : na, title="EMA 2", color=colEma2, linewidth=widEma2)
p3 = plot(showEma3 ? ema3 : na, title="EMA 3", color=colEma3, linewidth=widEma3)
p4 = plot(showEma4 ? ema4 : na, title="EMA 4", color=colEma4, linewidth=widEma4)

// ── EMA 區間填色（三個區間）──
fill(p1, p2,
     color = showFill and showEma1 and showEma2
             ? ema1 >= ema2 ? color.new(color.lime, 88) : color.new(color.red, 88)
             : na,
     title = "EMA1-EMA2 區間")

fill(p2, p3,
     color = showFill and showEma2 and showEma3
             ? ema2 >= ema3 ? color.new(color.lime, 91) : color.new(color.red, 91)
             : na,
     title = "EMA2-EMA3 區間")

fill(p3, p4,
     color = showFill and showEma3 and showEma4
             ? ema3 >= ema4 ? color.new(color.lime, 94) : color.new(color.red, 94)
             : na,
     title = "EMA3-EMA4 區間")

// ── 多空排列判斷（四條）──
bullTrend = close > ema1 and ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bearTrend = close < ema1 and ema1 < ema2 and ema2 < ema3 and ema3 < ema4
sideTrend = not bullTrend and not bearTrend

trendText = bullTrend ? "多頭排列" : bearTrend ? "空頭排列" : "震盪整理"
trendBias = bullTrend ? "偏多"     : bearTrend ? "偏空"     : "等待"
trendBg   = bullTrend ? color.new(color.lime, 82) : bearTrend ? color.new(color.red, 82) : color.new(color.gray, 82)

bgcolor(showBg ? bullTrend ? color.new(color.lime, 92) : bearTrend ? color.new(color.red, 92) : na : na)

// ── EMA1/EMA2 交叉 ──
bullCross = ta.crossover(ema1, ema2)
bearCross = ta.crossunder(ema1, ema2)
crossText = bullCross ? "金叉" : bearCross ? "死叉" : "無交叉"
crossBg   = bullCross ? color.new(color.lime, 65) : bearCross ? color.new(color.red, 65) : color.new(color.gray, 80)

alertcondition(bullCross, title="EMA1 上穿 EMA2", message="EMA1 上穿 EMA2，出現多頭交叉")
alertcondition(bearCross, title="EMA1 下穿 EMA2", message="EMA1 下穿 EMA2，出現空頭交叉")

// ── 表格工具函數 ──
f_tablePos(_pos) =>
    switch _pos
        "右上" => position.top_right
        "右下" => position.bottom_right
        "左上" => position.top_left
        "左下" => position.bottom_left
        => position.top_right

f_textSize(_size) =>
    switch _size
        "小"   => size.small
        "正常" => size.normal
        "大"   => size.large
        => size.normal

f_slopeText(_value) =>
    _value > _value[1] ? "↑ 上升" : _value < _value[1] ? "↓ 下降" : "→ 持平"

f_slopeBg(_value) =>
    _value > _value[1] ? color.new(color.lime, 82) : _value < _value[1] ? color.new(color.red, 82) : color.new(color.gray, 82)

f_priceText(_value) =>
    close > _value ? "價格在上" : close < _value ? "價格在下" : "貼合"

f_priceBg(_value) =>
    close > _value ? color.new(color.lime, 82) : close < _value ? color.new(color.red, 82) : color.new(color.gray, 82)

// ── EMA 狀態表格（5欄 × 7列）──
txtSize = f_textSize(tableSizeInp)

colorHide = color.new(color.black, 100)

f_hideRow(_tbl, _row) =>
    table.cell(_tbl, 0, _row, "", text_color=colorHide, bgcolor=colorHide)
    table.cell(_tbl, 1, _row, "", text_color=colorHide, bgcolor=colorHide)
    table.cell(_tbl, 2, _row, "", text_color=colorHide, bgcolor=colorHide)
    table.cell(_tbl, 3, _row, "", text_color=colorHide, bgcolor=colorHide)
    table.cell(_tbl, 4, _row, "", text_color=colorHide, bgcolor=colorHide)

var table emaTable = table.new(
     f_tablePos(tablePosInp), 5, 7,
     bgcolor      = color.new(color.black, 85),
     frame_color  = color.new(color.white, 35),
     frame_width  = 1,
     border_color = color.new(color.white, 70),
     border_width = 1)

if barstate.islast
    if showTable
        table.cell(emaTable, 0, 0, "四 EMA 面板",                                text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
        table.cell(emaTable, 1, 0, syminfo.ticker,                                text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
        table.cell(emaTable, 2, 0, timeframe.period,                              text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
        table.cell(emaTable, 3, 0, trendText,                                     text_color=color.white, bgcolor=trendBg,                   text_size=txtSize)
        table.cell(emaTable, 4, 0, "收盤 " + str.tostring(close, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)

        table.cell(emaTable, 0, 1, "名稱",     text_color=color.white, bgcolor=color.new(color.gray, 65), text_size=txtSize)
        table.cell(emaTable, 1, 1, "週期",     text_color=color.white, bgcolor=color.new(color.gray, 65), text_size=txtSize)
        table.cell(emaTable, 2, 1, "數值",     text_color=color.white, bgcolor=color.new(color.gray, 65), text_size=txtSize)
        table.cell(emaTable, 3, 1, "斜率",     text_color=color.white, bgcolor=color.new(color.gray, 65), text_size=txtSize)
        table.cell(emaTable, 4, 1, "價格位置", text_color=color.white, bgcolor=color.new(color.gray, 65), text_size=txtSize)

        if showEma1
            table.cell(emaTable, 0, 2, "EMA 1",                            text_color=color.white, bgcolor=color.new(colEma1, 35),     text_size=txtSize)
            table.cell(emaTable, 1, 2, str.tostring(lenEma1),              text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 2, 2, str.tostring(ema1, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 3, 2, f_slopeText(ema1),                  text_color=color.white, bgcolor=f_slopeBg(ema1),            text_size=txtSize)
            table.cell(emaTable, 4, 2, f_priceText(ema1),                  text_color=color.white, bgcolor=f_priceBg(ema1),            text_size=txtSize)
        else
            f_hideRow(emaTable, 2)

        if showEma2
            table.cell(emaTable, 0, 3, "EMA 2",                            text_color=color.white, bgcolor=color.new(colEma2, 35),     text_size=txtSize)
            table.cell(emaTable, 1, 3, str.tostring(lenEma2),              text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 2, 3, str.tostring(ema2, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 3, 3, f_slopeText(ema2),                  text_color=color.white, bgcolor=f_slopeBg(ema2),            text_size=txtSize)
            table.cell(emaTable, 4, 3, f_priceText(ema2),                  text_color=color.white, bgcolor=f_priceBg(ema2),            text_size=txtSize)
        else
            f_hideRow(emaTable, 3)

        if showEma3
            table.cell(emaTable, 0, 4, "EMA 3",                            text_color=color.white, bgcolor=color.new(colEma3, 35),     text_size=txtSize)
            table.cell(emaTable, 1, 4, str.tostring(lenEma3),              text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 2, 4, str.tostring(ema3, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 3, 4, f_slopeText(ema3),                  text_color=color.white, bgcolor=f_slopeBg(ema3),            text_size=txtSize)
            table.cell(emaTable, 4, 4, f_priceText(ema3),                  text_color=color.white, bgcolor=f_priceBg(ema3),            text_size=txtSize)
        else
            f_hideRow(emaTable, 4)

        if showEma4
            table.cell(emaTable, 0, 5, "EMA 4",                            text_color=color.white, bgcolor=color.new(colEma4, 35),     text_size=txtSize)
            table.cell(emaTable, 1, 5, str.tostring(lenEma4),              text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 2, 5, str.tostring(ema4, format.mintick), text_color=color.white, bgcolor=color.new(color.black, 70), text_size=txtSize)
            table.cell(emaTable, 3, 5, f_slopeText(ema4),                  text_color=color.white, bgcolor=f_slopeBg(ema4),            text_size=txtSize)
            table.cell(emaTable, 4, 5, f_priceText(ema4),                  text_color=color.white, bgcolor=f_priceBg(ema4),            text_size=txtSize)
        else
            f_hideRow(emaTable, 5)

        table.cell(emaTable, 0, 6, "狀態",    text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
        table.cell(emaTable, 1, 6, trendText, text_color=color.white, bgcolor=trendBg,                   text_size=txtSize)
        table.cell(emaTable, 2, 6, trendBias, text_color=color.white, bgcolor=trendBg,                   text_size=txtSize)
        table.cell(emaTable, 3, 6, crossText, text_color=color.white, bgcolor=crossBg,                   text_size=txtSize)
        table.cell(emaTable, 4, 6, "更新中",  text_color=color.white, bgcolor=color.new(color.black, 0), text_size=txtSize)
    else
        table.clear(emaTable, 0, 0, 4, 6)

// ══════════════════════════════════════════════
// FVG SETTINGS
// ══════════════════════════════════════════════
bullFvgColor = input.color(color.new(color.green, 85), "Bull FVG",      group="FVG")
bearFvgColor = input.color(color.new(color.red,   85), "Bear FVG",      group="FVG")
midFvgColor  = input.color(color.new(color.gray,   0), "Midline Color", group="FVG")
extendBars   = input.int(50, "Extend Bars",     group="FVG")
maxKeep      = input.int(6,  "Max Active FVG",  group="FVG")
fvgLabelSize = input.string(size.tiny, "FVG Label Size",
     options=[size.tiny, size.small, size.normal, size.large], group="FVG")

var box[]  bullBox = array.new_box()
var box[]  bearBox = array.new_box()
var line[] bullMid = array.new_line()
var line[] bearMid = array.new_line()

bullFVG = low > high[2]
bearFVG = high < low[2]

if bullFVG
    fvgTop = low
    fvgBot = high[2]
    fvgMid = (fvgTop + fvgBot) / 2
    b = box.new(
         bar_index - 2, fvgTop,
         bar_index + extendBars, fvgBot,
         bgcolor=bullFvgColor,
         border_color=color.new(color.green, 40),
         text="FVG+",
         text_color=color.black,
         text_size=fvgLabelSize,
         text_halign=text.align_right,
         text_valign=text.align_bottom)
    m = line.new(bar_index - 2, fvgMid, bar_index + extendBars, fvgMid, color=midFvgColor, width=1)
    array.push(bullBox, b)
    array.push(bullMid, m)
    if array.size(bullBox) > maxKeep
        box.delete(array.shift(bullBox))
        line.delete(array.shift(bullMid))

if bearFVG
    fvgTop = low[2]
    fvgBot = high
    fvgMid = (fvgTop + fvgBot) / 2
    b = box.new(
         bar_index - 2, fvgTop,
         bar_index + extendBars, fvgBot,
         bgcolor=bearFvgColor,
         border_color=color.new(color.red, 40),
         text="FVG-",
         text_color=color.black,
         text_size=fvgLabelSize,
         text_halign=text.align_right,
         text_valign=text.align_bottom)
    m = line.new(bar_index - 2, fvgMid, bar_index + extendBars, fvgMid, color=midFvgColor, width=1)
    array.push(bearBox, b)
    array.push(bearMid, m)
    if array.size(bearBox) > maxKeep
        box.delete(array.shift(bearBox))
        line.delete(array.shift(bearMid))

if array.size(bullBox) > 0
    for i = array.size(bullBox) - 1 to 0
        bx       = array.get(bullBox, i)
        ln       = array.get(bullMid, i)
        midPrice = line.get_y1(ln)
        if low <= midPrice
            box.delete(bx)
            line.delete(ln)
            array.remove(bullBox, i)
            array.remove(bullMid, i)

if array.size(bearBox) > 0
    for i = array.size(bearBox) - 1 to 0
        bx       = array.get(bearBox, i)
        ln       = array.get(bearMid, i)
        midPrice = line.get_y1(ln)
        if high >= midPrice
            box.delete(bx)
            line.delete(ln)
            array.remove(bearBox, i)
            array.remove(bearMid, i)

// ══════════════════════════════════════════════
// WATERMARK SETTINGS
// ══════════════════════════════════════════════
groupWM = "STOP FOMO Watermark"

wmTitle = input.text_area(
     "Trade Like a Pro", "Title", group=groupWM)

wmSubtitle = input.text_area(
     "DISCIPLINE | PATIENCE | CONSISTENCY | BELIEVE IN YOURSELF", "Subtitle", group=groupWM)

showSymbol = input.bool(true, "Show Symbol Info", group=groupWM)

wmPosition = input.string(
     "middle_center", "Position",
     options=["top_left","top_center","top_right",
              "middle_left","middle_center","middle_right",
              "bottom_left","bottom_center","bottom_right"],
     group=groupWM)

titleColor    = input.color(color.new(color.black,  0), "Title Color",    group=groupWM)
subtitleColor = input.color(color.new(color.gray,   0), "Subtitle Color", group=groupWM)
symbolColor   = input.color(color.new(color.gray,   0), "Symbol Color",   group=groupWM)
wmBgColor     = input.color(color.new(color.white, 100), "Background",    group=groupWM)

titleSizeInput    = input.string("large",  "Title Size",    options=["tiny","small","normal","large","huge"], group=groupWM)
subtitleSizeInput = input.string("normal", "Subtitle Size", options=["tiny","small","normal","large","huge"], group=groupWM)
symbolSizeInput   = input.string("small",  "Symbol Size",   options=["tiny","small","normal","large","huge"], group=groupWM)

titleSize =
     titleSizeInput == "tiny"   ? size.tiny   :
     titleSizeInput == "small"  ? size.small  :
     titleSizeInput == "normal" ? size.normal :
     titleSizeInput == "large"  ? size.large  : size.huge

subtitleSize =
     subtitleSizeInput == "tiny"   ? size.tiny   :
     subtitleSizeInput == "small"  ? size.small  :
     subtitleSizeInput == "normal" ? size.normal :
     subtitleSizeInput == "large"  ? size.large  : size.huge

symbolSize =
     symbolSizeInput == "tiny"   ? size.tiny   :
     symbolSizeInput == "small"  ? size.small  :
     symbolSizeInput == "normal" ? size.normal :
     symbolSizeInput == "large"  ? size.large  : size.huge

wmPos =
     wmPosition == "top_left"      ? position.top_left      :
     wmPosition == "top_center"    ? position.top_center    :
     wmPosition == "top_right"     ? position.top_right     :
     wmPosition == "middle_left"   ? position.middle_left   :
     wmPosition == "middle_center" ? position.middle_center :
     wmPosition == "middle_right"  ? position.middle_right  :
     wmPosition == "bottom_left"   ? position.bottom_left   :
     wmPosition == "bottom_center" ? position.bottom_center : position.bottom_right

var table wmTable = table.new(wmPos, 1, 3)

if barstate.islast
    table.cell(wmTable, 0, 0, wmTitle,
         text_color=titleColor, text_size=titleSize, bgcolor=wmBgColor)
    table.cell(wmTable, 0, 1, wmSubtitle,
         text_color=subtitleColor, text_size=subtitleSize, bgcolor=wmBgColor)
    if showSymbol
        symbolInfo = syminfo.ticker + " | " + timeframe.period
        table.cell(wmTable, 0, 2, symbolInfo,
             text_color=symbolColor, text_size=symbolSize, bgcolor=wmBgColor)

// ══════════════════════════════════════════════
// 3 DAILY CANDLES HUD (D-2 / D-1 / D)
// ══════════════════════════════════════════════
groupHUD   = "Daily HUD"
useTheme   = input.bool(true, "使用系統主題色", group=groupHUD)
baseOffset = input.int(10, "基本 X 偏移量", minval=0, group=groupHUD)
hudGap     = input.int(7,  "K棒間距",       minval=1, group=groupHUD)

d2BodyBullInput   = input.color(color.rgb(0,220,120), "D-2 燭身-看漲", group="D-2 燭色")
d2BodyBearInput   = input.color(color.rgb(255,40,40), "D-2 燭身-看跌", group="D-2 燭色")
d2BorderBullInput = input.color(color.rgb(0,220,120), "D-2 邊框-看漲", group="D-2 燭色")
d2BorderBearInput = input.color(color.rgb(255,40,40), "D-2 邊框-看跌", group="D-2 燭色")
d2WickBullInput   = input.color(color.black,          "D-2 燭芯-看漲", group="D-2 燭色")
d2WickBearInput   = input.color(color.black,          "D-2 燭芯-看跌", group="D-2 燭色")

d1BodyBullInput   = input.color(color.rgb(0,220,120), "D-1 燭身-看漲", group="D-1 燭色")
d1BodyBearInput   = input.color(color.rgb(255,40,40), "D-1 燭身-看跌", group="D-1 燭色")
d1BorderBullInput = input.color(color.rgb(0,220,120), "D-1 邊框-看漲", group="D-1 燭色")
d1BorderBearInput = input.color(color.rgb(255,40,40), "D-1 邊框-看跌", group="D-1 燭色")
d1WickBullInput   = input.color(color.black,          "D-1 燭芯-看漲", group="D-1 燭色")
d1WickBearInput   = input.color(color.black,          "D-1 燭芯-看跌", group="D-1 燭色")

dBodyBullInput    = input.color(color.rgb(0,220,120), "D 燭身-看漲",   group="D 燭色")
dBodyBearInput    = input.color(color.rgb(255,40,40), "D 燭身-看跌",   group="D 燭色")
dBorderBullInput  = input.color(color.rgb(0,220,120), "D 邊框-看漲",   group="D 燭色")
dBorderBearInput  = input.color(color.rgb(255,40,40), "D 邊框-看跌",   group="D 燭色")
dWickBullInput    = input.color(color.black,          "D 燭芯-看漲",   group="D 燭色")
dWickBearInput    = input.color(color.black,          "D 燭芯-看跌",   group="D 燭色")

showOnlyBelowH4 = timeframe.isintraday and timeframe.in_seconds() <= 14400

d2O = request.security(syminfo.tickerid, "D", open[2],  barmerge.gaps_off, barmerge.lookahead_off)
d2H = request.security(syminfo.tickerid, "D", high[2],  barmerge.gaps_off, barmerge.lookahead_off)
d2L = request.security(syminfo.tickerid, "D", low[2],   barmerge.gaps_off, barmerge.lookahead_off)
d2C = request.security(syminfo.tickerid, "D", close[2], barmerge.gaps_off, barmerge.lookahead_off)

d1O = request.security(syminfo.tickerid, "D", open[1],  barmerge.gaps_off, barmerge.lookahead_off)
d1H = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_off)
d1L = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_off)
d1C = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

dO    = request.security(syminfo.tickerid, "D", open,  barmerge.gaps_off, barmerge.lookahead_off)
dH    = request.security(syminfo.tickerid, "D", high,  barmerge.gaps_off, barmerge.lookahead_off)
dL    = request.security(syminfo.tickerid, "D", low,   barmerge.gaps_off, barmerge.lookahead_off)
dC    = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_off)
dTime = request.security(syminfo.tickerid, "D", time,  barmerge.gaps_off, barmerge.lookahead_off)

var line[]  hudLines  = array.new_line()
var box[]   hudBoxes  = array.new_box()
var label[] hudLabels = array.new_label()

f_hud_clear() =>
    while array.size(hudLines) > 0
        line.delete(array.pop(hudLines))
    while array.size(hudBoxes) > 0
        box.delete(array.pop(hudBoxes))
    while array.size(hudLabels) > 0
        label.delete(array.pop(hudLabels))

f_drawCandle(_x, _o, _h, _l, _c, _bodyColor, _borderColor, _wickColor) =>
    int x1 = _x
    int x2 = _x + 2
    int xc = _x + 1
    array.push(hudLines, line.new(
         x1=xc, y1=_h, x2=xc, y2=_l,
         xloc=xloc.bar_index, extend=extend.none,
         color=_wickColor, width=1))
    array.push(hudBoxes, box.new(
         left=x1, right=x2,
         top=math.max(_o, _c),
         bottom=math.min(_o, _c),
         xloc=xloc.bar_index,
         border_color=_borderColor,
         border_width=1,
         bgcolor=color.new(_bodyColor, 0)))
    xc

if barstate.islast and showOnlyBelowH4
    f_hud_clear()

    int baseX = last_bar_index + baseOffset
    int d2X   = baseX
    int d1X   = baseX + hudGap
    int dX    = baseX + hudGap * 2

    bool  d2Bull      = d2C >= d2O
    color d2BodyCol   = useTheme ? (d2Bull ? color.green : color.red) : (d2Bull ? d2BodyBullInput   : d2BodyBearInput)
    color d2BorderCol = useTheme ? (d2Bull ? color.green : color.red) : (d2Bull ? d2BorderBullInput : d2BorderBearInput)
    color d2WickCol   = useTheme ? chart.fg_color : (d2Bull ? d2WickBullInput : d2WickBearInput)
    int   d2Center    = f_drawCandle(d2X, d2O, d2H, d2L, d2C, d2BodyCol, d2BorderCol, d2WickCol)
    array.push(hudLabels, label.new(
         x=d2Center, y=d2H + math.max((d2H - d2L) * 0.10, syminfo.mintick * 30),
         xloc=xloc.bar_index, text="D-2",
         style=label.style_none, textcolor=color.black, size=size.small))
    int d2LineEnd = d2X + 16
    array.push(hudLines, line.new(
         x1=d2Center + 1, y1=d2H, x2=d2LineEnd, y2=d2H,
         xloc=xloc.bar_index, extend=extend.none,
         color=color.rgb(255,90,70), style=line.style_dashed, width=1))
    array.push(hudLabels, label.new(
         x=d2LineEnd + 1, y=d2H,
         xloc=xloc.bar_index, text="前日高",
         style=label.style_none, textcolor=color.rgb(140,0,0), size=size.tiny))
    array.push(hudLines, line.new(
         x1=d2Center + 1, y1=d2L, x2=d2LineEnd, y2=d2L,
         xloc=xloc.bar_index, extend=extend.none,
         color=color.rgb(255,90,70), style=line.style_dashed, width=1))
    array.push(hudLabels, label.new(
         x=d2LineEnd + 1, y=d2L,
         xloc=xloc.bar_index, text="前日低",
         style=label.style_none, textcolor=color.rgb(140,0,0), size=size.tiny))

    bool  d1Bull      = d1C >= d1O
    color d1BodyCol   = useTheme ? (d1Bull ? color.green : color.red) : (d1Bull ? d1BodyBullInput   : d1BodyBearInput)
    color d1BorderCol = useTheme ? (d1Bull ? color.green : color.red) : (d1Bull ? d1BorderBullInput : d1BorderBearInput)
    color d1WickCol   = useTheme ? chart.fg_color : (d1Bull ? d1WickBullInput : d1WickBearInput)
    int   d1Center    = f_drawCandle(d1X, d1O, d1H, d1L, d1C, d1BodyCol, d1BorderCol, d1WickCol)
    array.push(hudLabels, label.new(
         x=d1Center, y=d1H + math.max((d1H - d1L) * 0.10, syminfo.mintick * 30),
         xloc=xloc.bar_index, text="D-1",
         style=label.style_none, textcolor=color.black, size=size.small))
    int d1LineEnd = d1X + 16
    array.push(hudLines, line.new(
         x1=d1Center + 1, y1=d1O, x2=d1LineEnd, y2=d1O,
         xloc=xloc.bar_index, extend=extend.none,
         color=color.black, style=line.style_dashed, width=1))
    array.push(hudLabels, label.new(
         x=d1LineEnd + 1, y=d1O,
         xloc=xloc.bar_index, text="O",
         style=label.style_none, textcolor=color.black, size=size.tiny))
    array.push(hudLines, line.new(
         x1=d1Center + 1, y1=d1H, x2=d1LineEnd, y2=d1H,
         xloc=xloc.bar_index, extend=extend.none,
         color=color.black, style=line.style_dashed, width=1))
    array.push(hudLabels, label.new(
         x=d1LineEnd + 1, y=d1H,
         xloc=xloc.bar_index, text="H",
         style=label.style_none, textcolor=color.black, size=size.tiny))
    array.push(hudLines, line.new(
         x1=d1Center + 1, y1=d1L, x2=d1LineEnd, y2=d1L,
         xloc=xloc.bar_index, extend=extend.none,
         color=color.black, style=line.style_dashed, width=1))
    array.push(hudLabels, label.new(
         x=d1LineEnd + 1, y=d1L,
         xloc=xloc.bar_index, text="L",
         style=label.style_none, textcolor=color.black, size=size.tiny))
    array.push(hudLines, line.new(
         x1=d1Center + 1, y1=d1C, x2=d1LineEnd, y2=d1C,
         xloc=xloc.bar_index, extend=extend.none,
         color=color.black, style=line.style_dashed, width=1))
    array.push(hudLabels, label.new(
         x=d1LineEnd + 1, y=d1C,
         xloc=xloc.bar_index, text="C",
         style=label.style_none, textcolor=color.black, size=size.tiny))

    bool  dBull      = dC >= dO
    color dBodyCol   = useTheme ? (dBull ? color.green : color.red) : (dBull ? dBodyBullInput   : dBodyBearInput)
    color dBorderCol = useTheme ? (dBull ? color.green : color.red) : (dBull ? dBorderBullInput : dBorderBearInput)
    color dWickCol   = useTheme ? chart.fg_color : (dBull ? dWickBullInput : dWickBearInput)
    int   dCenter    = f_drawCandle(dX, dO, dH, dL, dC, dBodyCol, dBorderCol, dWickCol)
    array.push(hudLabels, label.new(
         x=dCenter, y=dH + math.max((dH - dL) * 0.10, syminfo.mintick * 30),
         xloc=xloc.bar_index, text="D",
         style=label.style_none, textcolor=color.black, size=size.small))

// ══════════════════════════════════════════════
// DO 今日日線開盤價（主圖橫線，H4 以下皆顯示）
// ══════════════════════════════════════════════
showDO    = timeframe.isintraday and timeframe.in_seconds() <= 14400
doColor   = color.orange

var line  doLine  = na
var label doLabel = na

if showDO and barstate.islast
    if not na(doLine)
        line.delete(doLine)
    if not na(doLabel)
        label.delete(doLabel)
    int doStartTime = int(dTime)
    int doEndTime   = doStartTime + 43200 * 1000
    doLine := line.new(
         x1=doStartTime, y1=dO,
         x2=doEndTime,   y2=dO,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=doColor,
         style=line.style_dashed,
         width=1)
    doLabel := label.new(
         x=doEndTime, y=dO,
         xloc=xloc.bar_time,
         text="DO",
         style=label.style_none,
         textcolor=color.new(color.black, 50),
         size=size.small)
````
