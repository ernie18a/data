# EMA Ribbon + Smart FVG + 3 Daily Candles HUD

- url: https://www.tradingview.com/script/tFx05qac/
- type: indicator
- pine_id: PUB;f9d5eeb840bc4907b8a0c6fead2097b5
- version: 1.0

## Description

EMA Ribbon + Smart FVG + 3 Daily Candles HUD
透過指標方便觀看圖表

## Source Code

````pine
//@version=6
indicator("EMA Ribbon + Smart FVG + 3 Daily Candles HUD", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=300)

// ══════════════════════════════════════════════
// EMA SETTINGS (6 LINES)
// ══════════════════════════════════════════════
emaLen1 = input.int(7,   "EMA 1", group="EMA", inline="ema1")
emaCol1 = input.color(color.rgb( 64, 195, 255), "", group="EMA", inline="ema1")
emaWid1 = input.int(2, "", minval=1, maxval=4,   group="EMA", inline="ema1")

emaLen2 = input.int(21,  "EMA 2", group="EMA", inline="ema2")
emaCol2 = input.color(color.rgb( 72, 230, 170), "", group="EMA", inline="ema2")
emaWid2 = input.int(2, "", minval=1, maxval=4,   group="EMA", inline="ema2")

emaLen3 = input.int(56,  "EMA 3", group="EMA", inline="ema3")
emaCol3 = input.color(color.rgb(140, 220,  60), "", group="EMA", inline="ema3")
emaWid3 = input.int(2, "", minval=1, maxval=4,   group="EMA", inline="ema3")

emaLen4 = input.int(147, "EMA 4", group="EMA", inline="ema4")
emaCol4 = input.color(color.rgb(255, 200,   0), "", group="EMA", inline="ema4")
emaWid4 = input.int(2, "", minval=1, maxval=4,   group="EMA", inline="ema4")

emaLen5 = input.int(200, "EMA 5", group="EMA", inline="ema5")
emaCol5 = input.color(color.rgb(255, 120,  30), "", group="EMA", inline="ema5")
emaWid5 = input.int(2, "", minval=1, maxval=4,   group="EMA", inline="ema5")

emaLen6 = input.int(300, "EMA 6", group="EMA", inline="ema6")
emaCol6 = input.color(color.rgb(240,  50,  80), "", group="EMA", inline="ema6")
emaWid6 = input.int(2, "", minval=1, maxval=4,   group="EMA", inline="ema6")

plot(ta.ema(close, emaLen1), "EMA 1", color=emaCol1, linewidth=emaWid1)
plot(ta.ema(close, emaLen2), "EMA 2", color=emaCol2, linewidth=emaWid2)
plot(ta.ema(close, emaLen3), "EMA 3", color=emaCol3, linewidth=emaWid3)
plot(ta.ema(close, emaLen4), "EMA 4", color=emaCol4, linewidth=emaWid4)
plot(ta.ema(close, emaLen5), "EMA 5", color=emaCol5, linewidth=emaWid5)
plot(ta.ema(close, emaLen6), "EMA 6", color=emaCol6, linewidth=emaWid6)

// ══════════════════════════════════════════════
// FVG SETTINGS
// ══════════════════════════════════════════════
bullColor  = input.color(color.new(color.green, 85), "Bull FVG",     group="FVG")
bearColor  = input.color(color.new(color.red,   85), "Bear FVG",     group="FVG")
midColor   = input.color(color.new(color.gray,   0), "Midline Color",group="FVG")
extendBars = input.int(50, "Extend Bars", group="FVG")
maxKeep    = input.int(6,  "Max Active FVG", group="FVG")
labelSize  = input.string(size.tiny, "FVG Label Size",
     options=[size.tiny, size.small, size.normal, size.large], group="FVG")

// ── FVG Arrays ──
var box[]  bullBox = array.new_box()
var box[]  bearBox = array.new_box()
var line[] bullMid = array.new_line()
var line[] bearMid = array.new_line()

// ── FVG Detection ──
bullFVG = low > high[2]
bearFVG = high < low[2]

// ── Create Bull FVG ──
if bullFVG
    top = low
    bot = high[2]
    mid = (top + bot) / 2
    b = box.new(
         bar_index - 2, top,
         bar_index + extendBars, bot,
         bgcolor=bullColor,
         border_color=color.new(color.green, 40),
         text="FVG+",
         text_color=color.black,
         text_size=labelSize,
         text_halign=text.align_right,
         text_valign=text.align_bottom)
    m = line.new(bar_index - 2, mid, bar_index + extendBars, mid, color=midColor, width=1)
    array.push(bullBox, b)
    array.push(bullMid, m)
    if array.size(bullBox) > maxKeep
        box.delete(array.shift(bullBox))
        line.delete(array.shift(bullMid))

// ── Create Bear FVG ──
if bearFVG
    top = low[2]
    bot = high
    mid = (top + bot) / 2
    b = box.new(
         bar_index - 2, top,
         bar_index + extendBars, bot,
         bgcolor=bearColor,
         border_color=color.new(color.red, 40),
         text="FVG-",
         text_color=color.black,
         text_size=labelSize,
         text_halign=text.align_right,
         text_valign=text.align_bottom)
    m = line.new(bar_index - 2, mid, bar_index + extendBars, mid, color=midColor, width=1)
    array.push(bearBox, b)
    array.push(bearMid, m)
    if array.size(bearBox) > maxKeep
        box.delete(array.shift(bearBox))
        line.delete(array.shift(bearMid))

// ── Midline Touch = Invalidation ──
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
     "Trade Like a Pro",
     "Title",
     group=groupWM)

wmSubtitle = input.text_area(
     "DISCIPLINE | PATIENCE | CONSISTENCY | BELIEVE IN YOURSELF",
     "Subtitle",
     group=groupWM)

showSymbol = input.bool(true, "Show Symbol Info", group=groupWM)

wmPosition = input.string(
     "middle_center", "Position",
     options=["top_left","top_center","top_right",
              "middle_left","middle_center","middle_right",
              "bottom_left","bottom_center","bottom_right"],
     group=groupWM)

titleColor    = input.color(color.new(color.black, 0), "Title Color",    group=groupWM)
subtitleColor = input.color(color.new(color.gray,  0), "Subtitle Color", group=groupWM)
symbolColor   = input.color(color.new(color.gray,  0), "Symbol Color",   group=groupWM)
bgColor       = input.color(color.new(color.white,100), "Background",    group=groupWM)

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
         text_color=titleColor, text_size=titleSize, bgcolor=bgColor)
    table.cell(wmTable, 0, 1, wmSubtitle,
         text_color=subtitleColor, text_size=subtitleSize, bgcolor=bgColor)
    if showSymbol
        symbolInfo = syminfo.ticker + " | " + timeframe.period
        table.cell(wmTable, 0, 2, symbolInfo,
             text_color=symbolColor, text_size=symbolSize, bgcolor=bgColor)

// ══════════════════════════════════════════════
// 3 DAILY CANDLES HUD (D-2 / D-1 / D)
// ══════════════════════════════════════════════
groupHUD = "Daily HUD"

useTheme   = input.bool(true, "使用系統主題色", group=groupHUD)
baseOffset = input.int(10, "基本 X 偏移量", minval=0, group=groupHUD)
gap        = input.int(7,  "K棒間距",       minval=1, group=groupHUD)

// D-2 色設定
d2BodyBullInput   = input.color(color.rgb(0,220,120), "D-2 燭身-看漲",  group="D-2 燭色")
d2BodyBearInput   = input.color(color.rgb(255,40,40), "D-2 燭身-看跌",  group="D-2 燭色")
d2BorderBullInput = input.color(color.rgb(0,220,120), "D-2 邊框-看漲",  group="D-2 燭色")
d2BorderBearInput = input.color(color.rgb(255,40,40), "D-2 邊框-看跌",  group="D-2 燭色")
d2WickBullInput   = input.color(color.black,          "D-2 燭芯-看漲",  group="D-2 燭色")
d2WickBearInput   = input.color(color.black,          "D-2 燭芯-看跌",  group="D-2 燭色")

// D-1 色設定
d1BodyBullInput   = input.color(color.rgb(0,220,120), "D-1 燭身-看漲",  group="D-1 燭色")
d1BodyBearInput   = input.color(color.rgb(255,40,40), "D-1 燭身-看跌",  group="D-1 燭色")
d1BorderBullInput = input.color(color.rgb(0,220,120), "D-1 邊框-看漲",  group="D-1 燭色")
d1BorderBearInput = input.color(color.rgb(255,40,40), "D-1 邊框-看跌",  group="D-1 燭色")
d1WickBullInput   = input.color(color.black,          "D-1 燭芯-看漲",  group="D-1 燭色")
d1WickBearInput   = input.color(color.black,          "D-1 燭芯-看跌",  group="D-1 燭色")

// D 色設定
dBodyBullInput    = input.color(color.rgb(0,220,120), "D 燭身-看漲",    group="D 燭色")
dBodyBearInput    = input.color(color.rgb(255,40,40), "D 燭身-看跌",    group="D 燭色")
dBorderBullInput  = input.color(color.rgb(0,220,120), "D 邊框-看漲",    group="D 燭色")
dBorderBearInput  = input.color(color.rgb(255,40,40), "D 邊框-看跌",    group="D 燭色")
dWickBullInput    = input.color(color.black,          "D 燭芯-看漲",    group="D 燭色")
dWickBearInput    = input.color(color.black,          "D 燭芯-看跌",    group="D 燭色")

// 只在 H4 以下時間框架顯示
showOnlyBelowH4 = timeframe.isintraday and timeframe.in_seconds() <= 14400

// 日線資料
d2O = request.security(syminfo.tickerid, "D", open[2],  barmerge.gaps_off, barmerge.lookahead_off)
d2H = request.security(syminfo.tickerid, "D", high[2],  barmerge.gaps_off, barmerge.lookahead_off)
d2L = request.security(syminfo.tickerid, "D", low[2],   barmerge.gaps_off, barmerge.lookahead_off)
d2C = request.security(syminfo.tickerid, "D", close[2], barmerge.gaps_off, barmerge.lookahead_off)

d1O = request.security(syminfo.tickerid, "D", open[1],  barmerge.gaps_off, barmerge.lookahead_off)
d1H = request.security(syminfo.tickerid, "D", high[1],  barmerge.gaps_off, barmerge.lookahead_off)
d1L = request.security(syminfo.tickerid, "D", low[1],   barmerge.gaps_off, barmerge.lookahead_off)
d1C = request.security(syminfo.tickerid, "D", close[1], barmerge.gaps_off, barmerge.lookahead_off)

dO  = request.security(syminfo.tickerid, "D", open,  barmerge.gaps_off, barmerge.lookahead_off)
dH  = request.security(syminfo.tickerid, "D", high,  barmerge.gaps_off, barmerge.lookahead_off)
dL  = request.security(syminfo.tickerid, "D", low,   barmerge.gaps_off, barmerge.lookahead_off)
dC  = request.security(syminfo.tickerid, "D", close, barmerge.gaps_off, barmerge.lookahead_off)

// HUD 物件容器（獨立命名，避免與 FVG 衝突）
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

// 繪製迷你日K燭
f_drawCandle(_x, _o, _h, _l, _c, _bodyColor, _borderColor, _wickColor) =>
    int bodyW = 2
    int x1    = _x
    int x2    = _x + bodyW
    int xc    = _x + 1
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

// 主繪圖邏輯
if barstate.islast and showOnlyBelowH4
    f_hud_clear()

    int baseX = last_bar_index + baseOffset
    int d2X   = baseX
    int d1X   = baseX + gap
    int dX    = baseX + gap * 2

    // D-2
    bool d2Bull       = d2C >= d2O
    color d2BodyCol   = useTheme ? (d2Bull ? color.green : color.red) : (d2Bull ? d2BodyBullInput   : d2BodyBearInput)
    color d2BorderCol = useTheme ? (d2Bull ? color.green : color.red) : (d2Bull ? d2BorderBullInput : d2BorderBearInput)
    color d2WickCol   = useTheme ? chart.fg_color : (d2Bull ? d2WickBullInput : d2WickBearInput)
    int d2Center = f_drawCandle(d2X, d2O, d2H, d2L, d2C, d2BodyCol, d2BorderCol, d2WickCol)
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

    // D-1
    bool d1Bull       = d1C >= d1O
    color d1BodyCol   = useTheme ? (d1Bull ? color.green : color.red) : (d1Bull ? d1BodyBullInput   : d1BodyBearInput)
    color d1BorderCol = useTheme ? (d1Bull ? color.green : color.red) : (d1Bull ? d1BorderBullInput : d1BorderBearInput)
    color d1WickCol   = useTheme ? chart.fg_color : (d1Bull ? d1WickBullInput : d1WickBearInput)
    int d1Center = f_drawCandle(d1X, d1O, d1H, d1L, d1C, d1BodyCol, d1BorderCol, d1WickCol)
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

    // D (今日)
    bool dBull       = dC >= dO
    color dBodyCol   = useTheme ? (dBull ? color.green : color.red) : (dBull ? dBodyBullInput   : dBodyBearInput)
    color dBorderCol = useTheme ? (dBull ? color.green : color.red) : (dBull ? dBorderBullInput : dBorderBearInput)
    color dWickCol   = useTheme ? chart.fg_color : (dBull ? dWickBullInput : dWickBearInput)
    int dCenter = f_drawCandle(dX, dO, dH, dL, dC, dBodyCol, dBorderCol, dWickCol)
    array.push(hudLabels, label.new(
         x=dCenter, y=dH + math.max((dH - dL) * 0.10, syminfo.mintick * 30),
         xloc=xloc.bar_index, text="D",
         style=label.style_none, textcolor=color.black, size=size.small))
````
