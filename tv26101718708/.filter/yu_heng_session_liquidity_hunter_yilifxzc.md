# Yu Heng Session Liquidity Hunter

- url: https://www.tradingview.com/script/yiLiFxzC-Yu-Heng-Session-Liquidity-Hunter/
- type: indicator
- pine_id: PUB;6b635bf89bf94b649d70354a62a32b8c
- version: 4.0

## Description

宇哥版 Session Liquidity Hunter

点击链接加入免收费【翻身有道】社区：[url=https://discord.gg/QmFYr7bJ]https://discord.gg/QmFYr7bJ[/url]
联系社区管理员咨询加入社区：[url=https://discord.gg/QmFYr7bJ]https://wa.link/kmm9dg[/url]

This indicator is built for traders who focus on liquidity, session behavior, and real market structure.

Core concept:
Asia accumulates liquidity → London hunts → New York confirms or reverses.

Features:
• Asia / London / New York session boxes
• Automatic Session High & Low tracking
• Right-hand-side (RHS) projected levels
• Asia High / Low sweep detection
• London & New York Kill Zones
• Optional labels and alerts
• Clean structure for intraday execution

How to use:
1. Identify Asia range (liquidity pool)
2. Watch London for sweep (fake breakout or real expansion)
3. Use New York session for confirmation or reversal
4. Combine with order flow / structure (BOS, MSS)

This tool is not a signal generator.
It is designed to help you read liquidity and understand market intent.

Best used for:
• Crypto (BTC, ETH, Altcoins)
• Forex indices
• Intraday trading (M5 – H1)

Trading is not about prediction.
It is about positioning around liquidity.

----------------------------------------------------------------------

宇哥版 Session Liquidity Hunter

市场不是随机的。

每天都在重复同一件事：
亚洲盘蓄水 → 伦敦扫流动性 → 美盘决定方向

这个工具的目的不是给你信号，
而是让你看懂“钱在哪里”。

功能：
• 亚洲 / 伦敦 / 美盘结构区间
• 自动标记 Session High / Low
• Asia 流动性被扫提示
• London & New York Kill Zone
• 右侧延伸关键价格
• 清晰盘面结构辅助

使用逻辑：
1. 亚洲盘 = 建立流动性池
2. 伦敦盘 = 扫流动性（最关键）
3. 美盘 = 延续 or 反杀

重点不是方向，
而是——谁在被收割。

适合：
• BTC / ETH / 山寨币
• 外汇 / 指数
• 短线结构交易

交易不是猜涨跌，
而是理解流动性。

## Source Code

````pine
//@version=6
indicator("YH Session OC + DWM + H4 Smart Labels GMT+8", overlay=true, max_lines_count=500, max_labels_count=500)

// =====================================================
// GLOBAL
// =====================================================
groupGlobal = "Global"
gmt8 = "Etc/GMT-8"

showOnlyRecentDays = input.bool(true, "Only show recent days", group=groupGlobal)
recentDays = input.int(5, "Recent days", minval=1, maxval=30, group=groupGlobal)

showSessionLabels = input.bool(true, "Show Session Labels", group=groupGlobal)
showDWMLabels = input.bool(true, "Show D/W/M/H4 Labels", group=groupGlobal)

labelSizeInput = input.string("small", "Label Size", options=["tiny", "small", "normal", "large"], group=groupGlobal)
labelSize =
     labelSizeInput == "tiny" ? size.tiny :
     labelSizeInput == "small" ? size.small :
     labelSizeInput == "normal" ? size.normal :
     size.large

msInDay = 24 * 60 * 60 * 1000
ms30 = 30 * 60 * 1000
isRecent = not showOnlyRecentDays or time >= timenow - recentDays * msInDay

// =====================================================
// SESSION SETTINGS GMT+8
// =====================================================
groupAsia = "Asia GMT+8"
showAsia = input.bool(true, "Show Asia", group=groupAsia)
asiaSession = input.session("0800-1500", "Asia Session", group=groupAsia)
asiaColor = input.color(color.lime, "Asia Color", group=groupAsia)
asiaWidth = input.int(2, "Asia Width", minval=1, maxval=5, group=groupAsia)

groupLondon = "London GMT+8"
showLondon = input.bool(true, "Show London", group=groupLondon)
londonSession = input.session("1500-2330", "London Session", group=groupLondon)
londonColor = input.color(color.red, "London Color", group=groupLondon)
londonWidth = input.int(2, "London Width", minval=1, maxval=5, group=groupLondon)

groupUSA = "USA GMT+8"
showUSA = input.bool(true, "Show USA", group=groupUSA)
usaSession = input.session("2130-0400", "USA Session", group=groupUSA)
usaColor = input.color(color.blue, "USA Color", group=groupUSA)
usaWidth = input.int(2, "USA Width", minval=1, maxval=5, group=groupUSA)

// =====================================================
// SWEEP SETTINGS
// =====================================================
groupSweep = "Session O/C Sweep"
showSweepLines = input.bool(false, "Show Sweep Dotted Lines", group=groupSweep)
showSweepLabels = input.bool(false, "Show Sweep Labels", group=groupSweep)
sweepLineLengthBars = input.int(60, "Sweep line length bars", minval=5, maxval=300, group=groupSweep)
sweepLineWidth = input.int(1, "Sweep line width", minval=1, maxval=5, group=groupSweep)

// =====================================================
// KILL ZONES GMT+8
// =====================================================
groupKZ = "Kill Zones GMT+8"

showLondonKZ = input.bool(true, "Show London Kill Zone", group=groupKZ)
londonKZSession = input.session("1500-1700", "London KZ", group=groupKZ)
londonKZColor = input.color(color.new(color.orange, 90), "London KZ Color", group=groupKZ)

showNYKZ = input.bool(true, "Show NY Kill Zone", group=groupKZ)
nyKZSession = input.session("2130-2300", "NY KZ", group=groupKZ)
nyKZColor = input.color(color.new(color.purple, 90), "NY KZ Color", group=groupKZ)

// =====================================================
// D / W / M SETTINGS
// =====================================================
groupDWM = "D / W / M GMT+8"

showDWM = input.bool(true, "Show D/W/M", group=groupDWM)
showDay = input.bool(true, "Show Daily", group=groupDWM)
showWeek = input.bool(true, "Show Weekly", group=groupDWM)
showMonth = input.bool(true, "Show Monthly", group=groupDWM)

dColor = input.color(color.yellow, "D Color", group=groupDWM)
wColor = input.color(color.aqua, "W Color", group=groupDWM)
mColor = input.color(color.fuchsia, "M Color", group=groupDWM)

dwmWidth = input.int(2, "D/W/M Width", minval=1, maxval=5, group=groupDWM)
dwmOffsetBars = input.int(60, "D/W/M/H4 Offset Bars", minval=10, maxval=500, group=groupDWM)
dwmMergeTicks = input.int(30, "Merge labels if within ticks", minval=1, maxval=500, group=groupDWM)

// =====================================================
// H4 SETTINGS
// =====================================================
groupH4 = "H4 Levels"

showH4 = input.bool(true, "Show H4", group=groupH4)
h4Color = input.color(color.orange, "H4 Color", group=groupH4)
h4Width = input.int(2, "H4 Width", minval=1, maxval=5, group=groupH4)

// =====================================================
// HELPERS
// =====================================================
f_update_line(_line, _x1, _x2, _y, _color, _width, _style) =>
    line ln = _line
    if na(ln)
        ln := line.new(_x1, _y, _x2, _y, xloc=xloc.bar_index, extend=extend.none, color=_color, width=_width, style=_style)
    else
        line.set_xy1(ln, _x1, _y)
        line.set_xy2(ln, _x2, _y)
        line.set_color(ln, _color)
        line.set_width(ln, _width)
        line.set_style(ln, _style)
        line.set_extend(ln, extend.none)
    ln

f_update_anchor_line(_line, _y, _color, _width, _style, _offset) =>
    line ln = _line
    int x1 = bar_index
    int x2 = bar_index + _offset
    if na(ln)
        ln := line.new(x1, _y, x2, _y, xloc=xloc.bar_index, extend=extend.none, color=_color, width=_width, style=_style)
    else
        line.set_xy1(ln, x1, _y)
        line.set_xy2(ln, x2, _y)
        line.set_color(ln, _color)
        line.set_width(ln, _width)
        line.set_style(ln, _style)
        line.set_extend(ln, extend.none)
    ln

f_update_label(_label, _x, _y, _text, _color) =>
    label lb = _label
    if na(lb)
        lb := label.new(_x, _y, _text, xloc=xloc.bar_index, style=label.style_none, textcolor=_color, size=labelSize, color=color.new(color.black, 100))
    else
        label.set_x(lb, _x)
        label.set_y(lb, _y)
        label.set_text(lb, _text)
        label.set_textcolor(lb, _color)
        label.set_size(lb, labelSize)
        label.set_style(lb, label.style_none)
        label.set_color(lb, color.new(color.black, 100))
    lb

f_draw_sweep_line(_price, _txt, _color) =>
    if showSweepLines
        line.new(bar_index, _price, bar_index + sweepLineLengthBars, _price, xloc=xloc.bar_index, extend=extend.none, color=_color, width=sweepLineWidth, style=line.style_dotted)
    if showSweepLabels
        label.new(bar_index + sweepLineLengthBars, _price, _txt, xloc=xloc.bar_index, style=label.style_none, textcolor=_color, size=labelSize, color=color.new(color.black, 100))

f_same_level(_a, _b) =>
    not na(_a) and not na(_b) and math.abs(_a - _b) <= dwmMergeTicks * syminfo.mintick

f_add_txt(_base, _add) =>
    _base == "" ? _add : _base + " / " + _add

// =====================================================
// TRUE GMT+8 D / W / M LEVELS
// =====================================================
gDay = dayofmonth(time, gmt8)
gWeek = weekofyear(time, gmt8)
gMonth = month(time, gmt8)
gYear = year(time, gmt8)

newDay = gDay != gDay[1] or gMonth != gMonth[1] or gYear != gYear[1]
newWeek = gWeek != gWeek[1] or gYear != gYear[1]
newMonth = gMonth != gMonth[1] or gYear != gYear[1]

var float dOpen = na
var float pdOpen = na
var float pdClose = na

var float wOpen = na
var float pwOpen = na
var float pwClose = na

var float mOpen = na
var float pmOpen = na
var float pmClose = na

if na(dOpen)
    dOpen := open
if na(wOpen)
    wOpen := open
if na(mOpen)
    mOpen := open

if newDay
    pdOpen := dOpen
    pdClose := close[1]
    dOpen := open

if newWeek
    pwOpen := wOpen
    pwClose := close[1]
    wOpen := open

if newMonth
    pmOpen := mOpen
    pmClose := close[1]
    mOpen := open

dFallbackPrevOpen = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)
dFallbackPrevClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)

wFallbackPrevOpen = request.security(syminfo.tickerid, "W", open[1], lookahead=barmerge.lookahead_on)
wFallbackPrevClose = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)

mFallbackPrevOpen = request.security(syminfo.tickerid, "M", open[1], lookahead=barmerge.lookahead_on)
mFallbackPrevClose = request.security(syminfo.tickerid, "M", close[1], lookahead=barmerge.lookahead_on)

pdOpenFinal = na(pdOpen) ? dFallbackPrevOpen : pdOpen
pdCloseFinal = na(pdClose) ? dFallbackPrevClose : pdClose

pwOpenFinal = na(pwOpen) ? wFallbackPrevOpen : pwOpen
pwCloseFinal = na(pwClose) ? wFallbackPrevClose : pwClose

pmOpenFinal = na(pmOpen) ? mFallbackPrevOpen : pmOpen
pmCloseFinal = na(pmClose) ? mFallbackPrevClose : pmClose

// =====================================================
// H4 LEVELS
// =====================================================
h4Open = request.security(syminfo.tickerid, "240", open, lookahead=barmerge.lookahead_on)
ph4Open = request.security(syminfo.tickerid, "240", open[1], lookahead=barmerge.lookahead_on)
ph4Close = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_on)

// =====================================================
// ANCHOR LINES D/W/M/H4
// =====================================================
var line dOpenLine = na
var line pdOpenLine = na
var line pdCloseLine = na

var line wOpenLine = na
var line pwOpenLine = na
var line pwCloseLine = na

var line mOpenLine = na
var line pmOpenLine = na
var line pmCloseLine = na

var line h4OpenLine = na
var line ph4OpenLine = na
var line ph4CloseLine = na

if barstate.islast
    if showDWM
        if showDay
            dOpenLine := f_update_anchor_line(dOpenLine, dOpen, dColor, dwmWidth, line.style_solid, dwmOffsetBars)
            pdOpenLine := f_update_anchor_line(pdOpenLine, pdOpenFinal, color.new(dColor, 25), dwmWidth, line.style_solid, dwmOffsetBars)
            pdCloseLine := f_update_anchor_line(pdCloseLine, pdCloseFinal, color.new(dColor, 45), dwmWidth, line.style_dotted, dwmOffsetBars)

        if showWeek
            wOpenLine := f_update_anchor_line(wOpenLine, wOpen, wColor, dwmWidth, line.style_solid, dwmOffsetBars)
            pwOpenLine := f_update_anchor_line(pwOpenLine, pwOpenFinal, color.new(wColor, 25), dwmWidth, line.style_solid, dwmOffsetBars)
            pwCloseLine := f_update_anchor_line(pwCloseLine, pwCloseFinal, color.new(wColor, 45), dwmWidth, line.style_dotted, dwmOffsetBars)

        if showMonth
            mOpenLine := f_update_anchor_line(mOpenLine, mOpen, mColor, dwmWidth, line.style_solid, dwmOffsetBars)
            pmOpenLine := f_update_anchor_line(pmOpenLine, pmOpenFinal, color.new(mColor, 25), dwmWidth, line.style_solid, dwmOffsetBars)
            pmCloseLine := f_update_anchor_line(pmCloseLine, pmCloseFinal, color.new(mColor, 45), dwmWidth, line.style_dotted, dwmOffsetBars)

    if showH4
        h4OpenLine := f_update_anchor_line(h4OpenLine, h4Open, h4Color, h4Width, line.style_solid, dwmOffsetBars)
        ph4OpenLine := f_update_anchor_line(ph4OpenLine, ph4Open, color.new(h4Color, 25), h4Width, line.style_solid, dwmOffsetBars)
        ph4CloseLine := f_update_anchor_line(ph4CloseLine, ph4Close, color.new(h4Color, 45), h4Width, line.style_dotted, dwmOffsetBars)

// =====================================================
// SMART MERGED D/W/M/H4 LABELS
// =====================================================
var label smartLabel1 = na
var label smartLabel2 = na
var label smartLabel3 = na
var label smartLabel4 = na
var label smartLabel5 = na
var label smartLabel6 = na
var label smartLabel7 = na
var label smartLabel8 = na
var label smartLabel9 = na
var label smartLabel10 = na
var label smartLabel11 = na
var label smartLabel12 = na

if barstate.islast and showDWMLabels
    int lx = bar_index + dwmOffsetBars

    prices = array.new_float()
    texts = array.new_string()
    colors = array.new_color()

    if showDWM
        if showDay
            array.push(prices, dOpen), array.push(texts, "D O"), array.push(colors, dColor)
            array.push(prices, pdOpenFinal), array.push(texts, "PD O"), array.push(colors, color.new(dColor, 25))
            array.push(prices, pdCloseFinal), array.push(texts, "PD C"), array.push(colors, color.new(dColor, 45))

        if showWeek
            array.push(prices, wOpen), array.push(texts, "W O"), array.push(colors, wColor)
            array.push(prices, pwOpenFinal), array.push(texts, "PW O"), array.push(colors, color.new(wColor, 25))
            array.push(prices, pwCloseFinal), array.push(texts, "PW C"), array.push(colors, color.new(wColor, 45))

        if showMonth
            array.push(prices, mOpen), array.push(texts, "M O"), array.push(colors, mColor)
            array.push(prices, pmOpenFinal), array.push(texts, "PM O"), array.push(colors, color.new(mColor, 25))
            array.push(prices, pmCloseFinal), array.push(texts, "PM C"), array.push(colors, color.new(mColor, 45))

    if showH4
        array.push(prices, h4Open), array.push(texts, "H4 O"), array.push(colors, h4Color)
        array.push(prices, ph4Open), array.push(texts, "PH4 O"), array.push(colors, color.new(h4Color, 25))
        array.push(prices, ph4Close), array.push(texts, "PH4 C"), array.push(colors, color.new(h4Color, 45))

    mergedPrices = array.new_float()
    mergedTexts = array.new_string()
    mergedColors = array.new_color()

    for i = 0 to array.size(prices) - 1
        float p = array.get(prices, i)
        string t = array.get(texts, i)
        color c = array.get(colors, i)

        if not na(p)
            bool merged = false

            if array.size(mergedPrices) > 0
                for j = 0 to array.size(mergedPrices) - 1
                    float mp = array.get(mergedPrices, j)
                    if f_same_level(p, mp)
                        array.set(mergedTexts, j, f_add_txt(array.get(mergedTexts, j), t))
                        merged := true

            if not merged
                array.push(mergedPrices, p)
                array.push(mergedTexts, t)
                array.push(mergedColors, c)

    smartLabel1 := array.size(mergedPrices) > 0 ? f_update_label(smartLabel1, lx, array.get(mergedPrices, 0), array.get(mergedTexts, 0), array.get(mergedColors, 0)) : smartLabel1
    smartLabel2 := array.size(mergedPrices) > 1 ? f_update_label(smartLabel2, lx, array.get(mergedPrices, 1), array.get(mergedTexts, 1), array.get(mergedColors, 1)) : smartLabel2
    smartLabel3 := array.size(mergedPrices) > 2 ? f_update_label(smartLabel3, lx, array.get(mergedPrices, 2), array.get(mergedTexts, 2), array.get(mergedColors, 2)) : smartLabel3
    smartLabel4 := array.size(mergedPrices) > 3 ? f_update_label(smartLabel4, lx, array.get(mergedPrices, 3), array.get(mergedTexts, 3), array.get(mergedColors, 3)) : smartLabel4
    smartLabel5 := array.size(mergedPrices) > 4 ? f_update_label(smartLabel5, lx, array.get(mergedPrices, 4), array.get(mergedTexts, 4), array.get(mergedColors, 4)) : smartLabel5
    smartLabel6 := array.size(mergedPrices) > 5 ? f_update_label(smartLabel6, lx, array.get(mergedPrices, 5), array.get(mergedTexts, 5), array.get(mergedColors, 5)) : smartLabel6
    smartLabel7 := array.size(mergedPrices) > 6 ? f_update_label(smartLabel7, lx, array.get(mergedPrices, 6), array.get(mergedTexts, 6), array.get(mergedColors, 6)) : smartLabel7
    smartLabel8 := array.size(mergedPrices) > 7 ? f_update_label(smartLabel8, lx, array.get(mergedPrices, 7), array.get(mergedTexts, 7), array.get(mergedColors, 7)) : smartLabel8
    smartLabel9 := array.size(mergedPrices) > 8 ? f_update_label(smartLabel9, lx, array.get(mergedPrices, 8), array.get(mergedTexts, 8), array.get(mergedColors, 8)) : smartLabel9
    smartLabel10 := array.size(mergedPrices) > 9 ? f_update_label(smartLabel10, lx, array.get(mergedPrices, 9), array.get(mergedTexts, 9), array.get(mergedColors, 9)) : smartLabel10
    smartLabel11 := array.size(mergedPrices) > 10 ? f_update_label(smartLabel11, lx, array.get(mergedPrices, 10), array.get(mergedTexts, 10), array.get(mergedColors, 10)) : smartLabel11
    smartLabel12 := array.size(mergedPrices) > 11 ? f_update_label(smartLabel12, lx, array.get(mergedPrices, 11), array.get(mergedTexts, 11), array.get(mergedColors, 11)) : smartLabel12

// =====================================================
// SESSION DETECTION
// =====================================================
inAsia = showAsia and isRecent and not na(time(timeframe.period, asiaSession, gmt8))
inLondon = showLondon and isRecent and not na(time(timeframe.period, londonSession, gmt8))
inUSA = showUSA and isRecent and not na(time(timeframe.period, usaSession, gmt8))

asiaStart = inAsia and not inAsia[1]
asiaEnd = not inAsia and inAsia[1]

londonStart = inLondon and not inLondon[1]
londonEnd = not inLondon and inLondon[1]

usaStart = inUSA and not inUSA[1]
usaEnd = not inUSA and inUSA[1]

// =====================================================
// KILL ZONE BACKGROUND
// =====================================================
inLondonKZ = showLondonKZ and isRecent and not na(time(timeframe.period, londonKZSession, gmt8))
inNYKZ = showNYKZ and isRecent and not na(time(timeframe.period, nyKZSession, gmt8))

bgcolor(inLondonKZ ? londonKZColor : na)
bgcolor(inNYKZ ? nyKZColor : na)

// =====================================================
// ASIA SESSION FIRST M30 CANDLE OPEN / CLOSE
// =====================================================
var int asiaStartBar = na
var int asiaLastBar = na
var int asiaStartTime = na
var bool asiaM30Locked = false
var float asiaOpenLevel = na
var float asiaCloseLevel = na
var line asiaOpenLine = na
var line asiaCloseLine = na
var bool asiaOpenSwept = false
var bool asiaCloseSwept = false

if asiaStart
    asiaStartBar := bar_index
    asiaLastBar := bar_index
    asiaStartTime := time
    asiaM30Locked := false
    asiaOpenSwept := false
    asiaCloseSwept := false
    asiaOpenLevel := open
    asiaCloseLevel := close
    asiaOpenLine := line.new(bar_index, asiaOpenLevel, bar_index, asiaOpenLevel, xloc=xloc.bar_index, color=asiaColor, width=asiaWidth, style=line.style_solid)
    asiaCloseLine := line.new(bar_index, asiaCloseLevel, bar_index, asiaCloseLevel, xloc=xloc.bar_index, color=asiaColor, width=asiaWidth, style=line.style_solid)

if inAsia
    asiaLastBar := bar_index

    if not asiaM30Locked
        if time < asiaStartTime + ms30
            asiaCloseLevel := close
        else
            asiaM30Locked := true

    asiaOpenLine := f_update_line(asiaOpenLine, asiaStartBar, asiaLastBar, asiaOpenLevel, asiaColor, asiaWidth, line.style_solid)
    asiaCloseLine := f_update_line(asiaCloseLine, asiaStartBar, asiaLastBar, asiaCloseLevel, asiaColor, asiaWidth, line.style_solid)

    if asiaM30Locked and not asiaOpenSwept and high > asiaOpenLevel and close < asiaOpenLevel
        asiaOpenSwept := true
        f_draw_sweep_line(asiaOpenLevel, "Sweep Asia O", asiaColor)

    if asiaM30Locked and not asiaCloseSwept and low < asiaCloseLevel and close > asiaCloseLevel
        asiaCloseSwept := true
        f_draw_sweep_line(asiaCloseLevel, "Sweep Asia C", asiaColor)

if asiaEnd and not na(asiaLastBar) and showSessionLabels
    label.new(asiaLastBar + 1, asiaOpenLevel, "Asia O", xloc=xloc.bar_index, style=label.style_none, textcolor=asiaColor, size=labelSize, color=color.new(color.black, 100))
    label.new(asiaLastBar + 1, asiaCloseLevel, "Asia C", xloc=xloc.bar_index, style=label.style_none, textcolor=asiaColor, size=labelSize, color=color.new(color.black, 100))

// =====================================================
// LONDON SESSION FIRST M30 CANDLE OPEN / CLOSE
// =====================================================
var int londonStartBar = na
var int londonLastBar = na
var int londonStartTime = na
var bool londonM30Locked = false
var float londonOpenLevel = na
var float londonCloseLevel = na
var line londonOpenLine = na
var line londonCloseLine = na
var bool londonOpenSwept = false
var bool londonCloseSwept = false

if londonStart
    londonStartBar := bar_index
    londonLastBar := bar_index
    londonStartTime := time
    londonM30Locked := false
    londonOpenSwept := false
    londonCloseSwept := false
    londonOpenLevel := open
    londonCloseLevel := close
    londonOpenLine := line.new(bar_index, londonOpenLevel, bar_index, londonOpenLevel, xloc=xloc.bar_index, color=londonColor, width=londonWidth, style=line.style_solid)
    londonCloseLine := line.new(bar_index, londonCloseLevel, bar_index, londonCloseLevel, xloc=xloc.bar_index, color=londonColor, width=londonWidth, style=line.style_solid)

if inLondon
    londonLastBar := bar_index

    if not londonM30Locked
        if time < londonStartTime + ms30
            londonCloseLevel := close
        else
            londonM30Locked := true

    londonOpenLine := f_update_line(londonOpenLine, londonStartBar, londonLastBar, londonOpenLevel, londonColor, londonWidth, line.style_solid)
    londonCloseLine := f_update_line(londonCloseLine, londonStartBar, londonLastBar, londonCloseLevel, londonColor, londonWidth, line.style_solid)

    if londonM30Locked and not londonOpenSwept and high > londonOpenLevel and close < londonOpenLevel
        londonOpenSwept := true
        f_draw_sweep_line(londonOpenLevel, "Sweep London O", londonColor)

    if londonM30Locked and not londonCloseSwept and low < londonCloseLevel and close > londonCloseLevel
        londonCloseSwept := true
        f_draw_sweep_line(londonCloseLevel, "Sweep London C", londonColor)

if londonEnd and not na(londonLastBar) and showSessionLabels
    label.new(londonLastBar + 1, londonOpenLevel, "London O", xloc=xloc.bar_index, style=label.style_none, textcolor=londonColor, size=labelSize, color=color.new(color.black, 100))
    label.new(londonLastBar + 1, londonCloseLevel, "London C", xloc=xloc.bar_index, style=label.style_none, textcolor=londonColor, size=labelSize, color=color.new(color.black, 100))

// =====================================================
// USA SESSION FIRST M30 CANDLE OPEN / CLOSE
// =====================================================
var int usaStartBar = na
var int usaLastBar = na
var int usaStartTime = na
var bool usaM30Locked = false
var float usaOpenLevel = na
var float usaCloseLevel = na
var line usaOpenLine = na
var line usaCloseLine = na
var bool usaOpenSwept = false
var bool usaCloseSwept = false

if usaStart
    usaStartBar := bar_index
    usaLastBar := bar_index
    usaStartTime := time
    usaM30Locked := false
    usaOpenSwept := false
    usaCloseSwept := false
    usaOpenLevel := open
    usaCloseLevel := close
    usaOpenLine := line.new(bar_index, usaOpenLevel, bar_index, usaOpenLevel, xloc=xloc.bar_index, color=usaColor, width=usaWidth, style=line.style_solid)
    usaCloseLine := line.new(bar_index, usaCloseLevel, bar_index, usaCloseLevel, xloc=xloc.bar_index, color=usaColor, width=usaWidth, style=line.style_solid)

if inUSA
    usaLastBar := bar_index

    if not usaM30Locked
        if time < usaStartTime + ms30
            usaCloseLevel := close
        else
            usaM30Locked := true

    usaOpenLine := f_update_line(usaOpenLine, usaStartBar, usaLastBar, usaOpenLevel, usaColor, usaWidth, line.style_solid)
    usaCloseLine := f_update_line(usaCloseLine, usaStartBar, usaLastBar, usaCloseLevel, usaColor, usaWidth, line.style_solid)

    if usaM30Locked and not usaOpenSwept and high > usaOpenLevel and close < usaOpenLevel
        usaOpenSwept := true
        f_draw_sweep_line(usaOpenLevel, "Sweep USA O", usaColor)

    if usaM30Locked and not usaCloseSwept and low < usaCloseLevel and close > usaCloseLevel
        usaCloseSwept := true
        f_draw_sweep_line(usaCloseLevel, "Sweep USA C", usaColor)

if usaEnd and not na(usaLastBar) and showSessionLabels
    label.new(usaLastBar + 1, usaOpenLevel, "USA O", xloc=xloc.bar_index, style=label.style_none, textcolor=usaColor, size=labelSize, color=color.new(color.black, 100))
    label.new(usaLastBar + 1, usaCloseLevel, "USA C", xloc=xloc.bar_index, style=label.style_none, textcolor=usaColor, size=labelSize, color=color.new(color.black, 100))
````
