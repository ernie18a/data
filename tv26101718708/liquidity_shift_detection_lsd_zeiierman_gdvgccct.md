# Liquidity Shift Detection [LSD] (Zeiierman)

- url: https://www.tradingview.com/script/gdVgCcCT-Liquidity-Shift-Detection-LSD-Zeiierman/
- type: indicator
- pine_id: PUB;b7f709ed838a4035b58d74a8f7153d7e
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Liquidity Shift Detection [LSD] (Zeiierman)[/b] is a liquidity and market acceptance framework designed to identify where the market sweeps liquidity and subsequently establishes acceptance away from that liquidity event.

The script continuously tracks swing highs and swing lows, monitors for liquidity sweeps beyond those levels, and waits for confirmation through displacement or structural acceptance. Once confirmed, the swept level becomes a Liquidity Shift Detection (LSD) level.

[b]The LSD level acts as a reference point between two important market phases:[/b]

• [b]The Sweep Area[/b], where liquidity was collected.
• [b]The Acceptance Area[/b], where the market demonstrated acceptance after the liquidity event occurred.

Rather than focusing solely on reversals, the indicator helps traders visualize where liquidity was taken, where acceptance formed, and where price subsequently began discovering value.
[image]https://www.tradingview.com/x/4O56tudq/[/image]

⚪ [b]Acceptance and Price Discovery[/b]
The LSD framework is designed to identify where liquidity collection transitions into market acceptance.

• The Sweep Area shows where liquidity was taken.
• The LSD level shows where acceptance was established after the sweep.
[image]https://www.tradingview.com/x/sd0i9VJs/[/image]
From that point, the price may continue to discover value, either higher or lower, depending on future market participation. This allows traders to separate the liquidity event itself from the market behavior that followed it.

█ [b]How It Works[/b]

⚪ [b]Swing Structure Detection[/b]
The script continuously identifies swing highs and swing lows that may act as future liquidity pools.
[pine]ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low, len, len)[/pine]
These levels become the reference points used to detect future liquidity sweeps and market acceptance.

⚪ [b]Liquidity Sweep Detection[/b]
Once a swing level is established, the script monitors for sweeps beyond that level.
[pine]low < swingLow and close > swingLow
high > swingHigh and close < swingHigh[/pine]
A sweep occurs when price trades beyond a previous swing level and then returns back through it. These events often represent liquidity collection, stop runs, or failed breakout attempts.

⚪ [b]The Sweep Area[/b]
When a valid sweep occurs, the indicator creates a Sweep Area.

The Sweep Area highlights where liquidity was collected and where the liquidity event occurred.

[b]This area may contain:[/b]
• Triggered stop-losses
• Trapped breakout traders
• Absorbed liquidity

The Sweep Area itself does not predict direction. It simply identifies where liquidity was taken.

⚪ [b]The LSD Level[/b]
The swept swing level becomes the Liquidity Shift Detection (LSD) level.
[pine]bullLevel := swingLow
bearLevel := swingHigh[/pine]
The LSD level acts as the market’s acceptance reference after the sweep.

⚪ [b]Confirmation[/b]
After a sweep occurs, the script waits for confirmation.

Confirmation can occur through displacement or structural acceptance.
[pine]bullLSD = bullPending and (bullBreak or bullDisp)
bearLSD = bearPending and (bearBreak or bearDisp)[/pine]
This helps filter weaker sweeps and focuses on situations where the market is actively moving away from the liquidity event.

⚪ [b]Liquidity Shift Detection (LSD)[/b]
When a sweep is followed by confirmation, a Liquidity Shift Detection event is created. The script plots the LSD level and visualizes the completed formation.

At this stage, the market has demonstrated acceptance away from the original liquidity event.

█ [b]How to Use[/b]

⚪ [b]Identify Liquidity Collection[/b]
The Sweep Area shows where liquidity was taken.

[b]This helps traders identify:[/b]
• Stop runs
• Liquidity grabs
• Failed breakouts
• Areas where resting orders may have been absorbed
[image]https://www.tradingview.com/x/v5ovZHJH/[/image]
⚪ [b]Monitor Market Acceptance[/b]
Once an LSD is confirmed, traders can evaluate how the market behaves relative to the LSD level.

Acceptance above or below the level may provide insight into whether the liquidity shift remains active.

The farther price moves away from the LSD level while maintaining acceptance, the stronger the resulting move becomes.
[image]https://www.tradingview.com/x/hSTS9Pr6/[/image]

⚪ [b]Analyze the Relationship Between the Sweep and Acceptance[/b]

The indicator separates two distinct market concepts:

• [b]Sweep Area[/b] → Where liquidity was collected.
• [b]LSD Level[/b] → Where acceptance was established after the sweep.

This allows traders to clearly distinguish between the liquidity event itself and the market behavior that followed it.
[image]https://www.tradingview.com/x/KyuwIp1J/[/image]
█ [b]Settings[/b]
[list]
[*][b]Swing Length / Structure Sensitivity: [/b]Controls how sensitive swing high and swing low detection becomes.
[*][b]Displacement Body ATR Multiplier:[/b] Controls the minimum candle body size required for displacement confirmation.
[*][b]LSD Display Mode:[/b] Choose between displaying only confirmed LSD formations or showing live developing formations.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator('Liquidity Shift Detection [LSD] (Zeiierman)', overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)
//}

// ~~ Tooltips {
var string t1  = 'Controls how sensitive the swing structure detection is. Lower values detect smaller swings faster, while higher values require larger structure points.'
var string t2  = 'Sets the minimum candle body size required for displacement confirmation, measured as a multiple of ATR. Higher values require stronger displacement.'
var string t3  = 'Choose whether LSD drawings appear only after confirmation or while the setup is still developing.'
var string t4  = 'Shows or hides the main LSD level line.'
var string t5  = 'Shows or hides the sweep wick marker from the swept level to the sweep extreme.'
var string t6  = 'Shows or hides the formation boxes drawn around the LSD and sweep areas.'
var string t7  = 'Shows or hides the confirmation arrow printed on the confirmation candle.'
var string t8  = 'Shows or hides the centered LSD label on the confirmed level.'
var string t9  = 'Shows or hides the Sweep area label on the gray sweep zone.'
var string t10 = 'Controls the thickness of the LSD level line.'
var string t11 = 'Controls the thickness of the sweep wick marker.'
var string t12 = 'Sets the color of the bullish formation box.'
var string t13 = 'Sets the color of the bearish formation box.'
var string t14 = 'Sets the color of the sweep area box.'
var string t15 = 'Controls the transparency of all formation and sweep area boxes. Higher values make boxes more transparent.'
var string t16 = 'Controls the transparency of box borders. Higher values make borders more transparent.'
var string t17 = 'Controls the thickness of box borders.'
var string t18 = 'Sets the text shown inside the centered LSD label.'
var string t19 = 'Controls the size of the centered LSD label.'
var string t20 = 'Sets the text shown on the sweep area label.'
var string t21 = 'Controls the size of the sweep area label.'
var string t22 = 'Sets the color of the sweep area label text.'
var string t23 = 'Sets the symbol or text used for bullish confirmation arrows.'
var string t24 = 'Sets the symbol or text used for bearish confirmation arrows.'
var string t25 = 'Controls the size of the confirmation arrows.'
var string t26 = 'Sets the main bullish color used for bullish LSD lines, labels, and arrows.'
var string t27 = 'Sets the main bearish color used for bearish LSD lines, labels, and arrows.'
var string t28 = 'Sets the color of the sweep wick marker.'
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
len      = input.int(8, 'Swing Length / Structure Sensitivity', minval = 1, tooltip = t1)
dispMult = input.float(1.2, 'Displacement Body ATR Multiplier', minval = 0.1, step = 0.1, tooltip = t2)

// Display
lsdMode        = input.string('Confirmed LSD', 'LSD Display Mode', options = ['Confirmed LSD', 'Live LSD'], group = 'Display', inline = 'm', tooltip = t3)
showLive       = lsdMode == 'Live LSD'
showLine       = input.bool(true, 'Show LSD Line', group = 'Display', inline = 'l', tooltip = t4)
showWick       = input.bool(true, 'Show Sweep Wick', group = 'Display', inline = 'w', tooltip = t5)
showBox        = input.bool(true, 'Show Formation Box', group = 'Display', tooltip = t6)
showArrow      = input.bool(true, 'Show Confirmation Arrow', group = 'Display', tooltip = t7)
showLabel      = input.bool(true, 'Show Centered LSD Label', group = 'Display', tooltip = t8)
showSweepLabel = input.bool(true, 'Show Sweep Area Label', group = 'Display', tooltip = t9)

lineWidth = input.int(2, '', minval = 1, maxval = 5, group = 'Display', inline = 'l', tooltip = t10)
wickWidth = input.int(20, '', minval = 1, maxval = 20, group = 'Display', inline = 'w', tooltip = t11)

// Box Style
bullBoxColor  = input.color(#089981, 'Bullish Formation Box Color', group = 'Box Style', tooltip = t12)
bearBoxColor  = input.color(#f23645, 'Bearish Formation Box Color', group = 'Box Style', tooltip = t13)
sweepBoxColor = input.color(color.gray, 'Sweep Area Box Color', group = 'Box Style', tooltip = t14)
boxTrans      = input.int(90, 'Formation Box Transparency', minval = 0, maxval = 100, group = 'Box Style', tooltip = t15)
boxBorderTran = input.int(75, 'Box Border Transparency', minval = 0, maxval = 100, group = 'Box Style', tooltip = t16)
boxBorderW    = input.int(1, 'Box Border Width', minval = 0, maxval = 5, group = 'Box Style', tooltip = t17)

// Label Style
lsdLabelText      = input.string('LSD', 'LSD Label Text', group = 'Label Style', tooltip = t18)
lsdLabelSizeInp   = input.string('Tiny', 'LSD Label Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = 'Label Style', tooltip = t19)
sweepLabelText    = input.string('Sweep area', 'Sweep Area Label Text', group = 'Label Style', tooltip = t20)
sweepLabelSizeInp = input.string('Tiny', 'Sweep Area Label Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = 'Label Style', tooltip = t21)
sweepLabelColor   = input.color(color.white, 'Sweep Area Label Color', group = 'Label Style', tooltip = t22)

// Arrow Style
bullArrowText = input.string('▲', 'Bullish Arrow Text', group = 'Arrow Style', tooltip = t23)
bearArrowText = input.string('▼', 'Bearish Arrow Text', group = 'Arrow Style', tooltip = t24)
arrowSizeInp  = input.string('Small', 'Arrow Size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = 'Arrow Style', tooltip = t25)

// Colors
bullColor  = input.color(#089981, 'Bullish Color', group = 'Colors', tooltip = t26)
bearColor  = input.color(#f23645, 'Bearish Color', group = 'Colors', tooltip = t27)
sweepColor = input.color(color.new(color.yellow, 45), 'Sweep Wick Color', group = 'Colors', tooltip = t28)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Style {
getSize(_s) =>
    switch _s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        => size.huge

lsdLabelSize   = getSize(lsdLabelSizeInp)
sweepLabelSize = getSize(sweepLabelSizeInp)
arrowSize      = getSize(arrowSizeInp)
invis          = color.new(color.white, 100)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Conditions {
bullDispCond(_body, _atr) =>
    close > open and _body >= _atr * dispMult

bearDispCond(_body, _atr) =>
    close < open and _body >= _atr * dispMult

bullSweepCond(_level) =>
    not na(_level) and low < _level and close > _level

bearSweepCond(_level) =>
    not na(_level) and high > _level and close < _level

bullBreakCond(_level) =>
    not na(_level) and close > _level

bearBreakCond(_level) =>
    not na(_level) and close < _level

isExpired(_pending, _bar) =>
    _pending and bar_index - _bar > 100

bullConfirm(_pending, _break, _disp) =>
    barstate.isconfirmed and _pending and (_break or _disp)

bearConfirm(_pending, _break, _disp) =>
    barstate.isconfirmed and _pending and (_break or _disp)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Object Helpers {
delLine(_ln) =>
    if not na(_ln)
        line.delete(_ln)

delBox(_bx) =>
    if not na(_bx)
        box.delete(_bx)

delLabel(_lb) =>
    if not na(_lb)
        label.delete(_lb)

newLSDLine(_bar, _level, _color) =>
    line.new(_bar, _level, bar_index, _level, color = _color, width = lineWidth)

newWick(_bar, _level, _extreme) =>
    line.new(_bar, _level, _bar, _extreme, color = sweepColor, width = wickWidth)

stretchLine(_ln) =>
    if not na(_ln)
        line.set_x2(_ln, bar_index)
    _ln

paintLine(_ln, _color) =>
    if not na(_ln)
        line.set_color(_ln, _color)
        line.set_width(_ln, lineWidth)
        line.set_x2(_ln, bar_index)
    _ln

dashLine(_ln, _dash) =>
    if _dash and not na(_ln)
        line.set_style(_ln, line.style_dashed)
    _ln

finalLine(_ln, _bar, _level, _color, _dash) =>
    ln = _ln

    if showLine
        if na(ln)
            ln := line.new(_bar, _level, bar_index, _level, color = _color, width = lineWidth)
        else
            ln := paintLine(ln, _color)

        ln := dashLine(ln, _dash)

    ln

newBox(_left, _top, _bot, _bg, _border) =>
    box.new(
         left = _left,
         top = _top,
         right = bar_index,
         bottom = _bot,
         bgcolor = _bg,
         border_color = _border,
         border_width = boxBorderW
     )

setBox(_bx, _top, _bot) =>
    box.set_right(_bx, bar_index)
    box.set_top(_bx, _top)
    box.set_bottom(_bx, _bot)
    _bx

updateBox(_bx, _left, _top, _bot, _bg, _border) =>
    bx = _bx

    if na(bx)
        bx := newBox(_left, _top, _bot, _bg, _border)
    else
        bx := setBox(bx, _top, _bot)

    bx

drawBox(_left, _top, _bot, _bg, _border) =>
    showBox ? newBox(_left, _top, _bot, _bg, _border) : na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Label Helpers {
drawLabel(_isBull, _bar, _level, _color) =>
    if showLabel
        label.new(
             _bar,
             _level,
             lsdLabelText,
             style = _isBull ? label.style_label_down : label.style_label_up,
             textcolor = _color,
             color = invis,
             size = lsdLabelSize
         )

drawArrow(_isBull, _color) =>
    if showArrow
        label.new(
             bar_index,
             _isBull ? low : high,
             _isBull ? bullArrowText : bearArrowText,
             style = _isBull ? label.style_label_up : label.style_label_down,
             textcolor = _color,
             color = invis,
             size = arrowSize
         )

newSweepLabel(_bar, _top, _bot, _isBull) =>
    y = _isBull ? _bot : _top

    label.new(
         _bar,
         y,
         sweepLabelText,
         style = _isBull ? label.style_label_up : label.style_label_down,
         textcolor = sweepLabelColor,
         color = invis,
         size = sweepLabelSize
     )

setSweepLabel(_lb, _bar, _top, _bot, _isBull) =>
    if not na(_lb)
        label.set_x(_lb, math.ceil(math.avg(_bar, bar_index)))
        label.set_y(_lb, _isBull ? _bot : _top)
        label.set_text(_lb, sweepLabelText)
        label.set_textcolor(_lb, sweepLabelColor)
        label.set_size(_lb, sweepLabelSize)
    _lb

updateSweepLabel(_lb, _bar, _top, _bot, _isBull) =>
    lb = _lb

    if showLive and showBox and showSweepLabel
        mid = math.ceil(math.avg(_bar, bar_index))

        if na(lb)
            lb := newSweepLabel(mid, _top, _bot, _isBull)
        else
            lb := setSweepLabel(lb, _bar, _top, _bot, _isBull)

    lb

drawSweepLabel(_bar, _top, _bot, _isBull) =>
    showBox and showSweepLabel ? newSweepLabel(math.ceil(math.avg(_bar, bar_index)), _top, _bot, _isBull) : na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Box Helpers {
bullTopBoxUpdate(_bx, _bar, _high, _level) =>
    showLive and showBox and _high > _level ?
         updateBox(
             _bx,
             _bar,
             _high,
             _level,
             color.new(bullBoxColor, boxTrans),
             color.new(bullBoxColor, boxBorderTran)
         ) : _bx

bullBotBoxUpdate(_bx, _bar, _low, _level) =>
    showLive and showBox and _low < _level ?
         updateBox(
             _bx,
             _bar,
             _level,
             _low,
             color.new(sweepBoxColor, boxTrans),
             color.new(sweepBoxColor, boxBorderTran)
         ) : _bx

bearTopBoxUpdate(_bx, _bar, _high, _level) =>
    showLive and showBox and _high > _level ?
         updateBox(
             _bx,
             _bar,
             _high,
             _level,
             color.new(sweepBoxColor, boxTrans),
             color.new(sweepBoxColor, boxBorderTran)
         ) : _bx

bearBotBoxUpdate(_bx, _bar, _low, _level) =>
    showLive and showBox and _low < _level ?
         updateBox(
             _bx,
             _bar,
             _level,
             _low,
             color.new(bearBoxColor, boxTrans),
             color.new(bearBoxColor, boxBorderTran)
         ) : _bx

drawBullBoxes(_bar, _high, _low, _level) =>
    if _high > _level
        drawBox(
             _bar,
             _high,
             _level,
             color.new(bullBoxColor, boxTrans),
             color.new(bullBoxColor, boxBorderTran)
         )

    if _low < _level
        drawBox(
             _bar,
             _level,
             _low,
             color.new(sweepBoxColor, boxTrans),
             color.new(sweepBoxColor, boxBorderTran)
         )

drawBearBoxes(_bar, _high, _low, _level) =>
    if _high > _level
        drawBox(
             _bar,
             _high,
             _level,
             color.new(sweepBoxColor, boxTrans),
             color.new(sweepBoxColor, boxBorderTran)
         )

    if _low < _level
        drawBox(
             _bar,
             _level,
             _low,
             color.new(bearBoxColor, boxTrans),
             color.new(bearBoxColor, boxBorderTran)
         )
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Structure {
atr  = ta.atr(14)
body = math.abs(close - open)

bullDisp = bullDispCond(body, atr)
bearDisp = bearDispCond(body, atr)

ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low, len, len)

var float swingHigh = na
var float swingLow  = na
var int swingHighBar = na
var int swingLowBar  = na

if not na(ph)
    swingHigh := ph
    swingHighBar := bar_index - len

if not na(pl)
    swingLow := pl
    swingLowBar := bar_index - len
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Sweep Detection {
bullSweep = bullSweepCond(swingLow)
bearSweep = bearSweepCond(swingHigh)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  LSD State {
var bool bullPending = false
var bool bearPending = false

var float bullExtreme = na
var float bullLevel = na
var int bullBar = na
var float bullHigh = na
var float bullLow = na

var float bearExtreme = na
var float bearLevel = na
var int bearBar = na
var float bearHigh = na
var float bearLow = na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// Live Objects {
var line bullLine = na
var line bearLine = na
var line bullWick = na
var line bearWick = na

var box bullTopBox = na
var box bullBotBox = na
var box bearTopBox = na
var box bearBotBox = na

var label bullSweepLabel = na
var label bearSweepLabel = na

clearBull() =>
    delLine(bullLine)
    delLine(bullWick)
    delBox(bullTopBox)
    delBox(bullBotBox)
    delLabel(bullSweepLabel)

clearBear() =>
    delLine(bearLine)
    delLine(bearWick)
    delBox(bearTopBox)
    delBox(bearBotBox)
    delLabel(bearSweepLabel)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Start Formations {
if bullSweep
    clearBull()

    bullPending := true
    bullExtreme := low
    bullLevel := swingLow
    bullBar := bar_index
    bullHigh := high
    bullLow := low
    bullSweepLabel := na

    if showLive and showLine
        bullLine := newLSDLine(bullBar, bullLevel, bullColor)

    if showLive and showWick
        bullWick := newWick(bullBar, bullLevel, bullExtreme)

if bearSweep
    clearBear()

    bearPending := true
    bearExtreme := high
    bearLevel := swingHigh
    bearBar := bar_index
    bearHigh := high
    bearLow := low
    bearSweepLabel := na

    if showLive and showLine
        bearLine := newLSDLine(bearBar, bearLevel, bearColor)

    if showLive and showWick
        bearWick := newWick(bearBar, bearLevel, bearExtreme)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Update Formations {
if bullPending
    bullHigh := math.max(nz(bullHigh, high), high)
    bullLow := math.min(nz(bullLow, low), low)

    if showLive and showLine
        bullLine := stretchLine(bullLine)

    bullTopBox := bullTopBoxUpdate(bullTopBox, bullBar, bullHigh, bullLevel)
    bullBotBox := bullBotBoxUpdate(bullBotBox, bullBar, bullLow, bullLevel)

    if bullLow < bullLevel
        bullSweepLabel := updateSweepLabel(bullSweepLabel, bullBar, bullLevel, bullLow, true)

if bearPending
    bearHigh := math.max(nz(bearHigh, high), high)
    bearLow := math.min(nz(bearLow, low), low)

    if showLive and showLine
        bearLine := stretchLine(bearLine)

    bearTopBox := bearTopBoxUpdate(bearTopBox, bearBar, bearHigh, bearLevel)
    bearBotBox := bearBotBoxUpdate(bearBotBox, bearBar, bearLow, bearLevel)

    if bearHigh > bearLevel
        bearSweepLabel := updateSweepLabel(bearSweepLabel, bearBar, bearHigh, bearLevel, false)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Expiration {
if isExpired(bullPending, bullBar)
    bullPending := false
    clearBull()
    bullSweepLabel := na

if isExpired(bearPending, bearBar)
    bearPending := false
    clearBear()
    bearSweepLabel := na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Confirmation {
bullBreak = bullBreakCond(swingHigh)
bearBreak = bearBreakCond(swingLow)

bullLSD = bullConfirm(bullPending, bullBreak, bullDisp)
bearLSD = bearConfirm(bearPending, bearBreak, bearDisp)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// Finalize {
var int trend = 0

finalizeBull() =>
    sameTrend = trend == 1
    midBar = math.ceil(math.avg(bullBar, bar_index))

    bullLineOut = finalLine(bullLine, bullBar, bullLevel, bullColor, sameTrend)

    if not showLive and showWick
        newWick(bullBar, bullLevel, bullExtreme)

    if not showLive
        drawBullBoxes(bullBar, bullHigh, bullLow, bullLevel)

        if bullLow < bullLevel
            drawSweepLabel(bullBar, bullLevel, bullLow, true)

    drawLabel(true, midBar, bullLevel, bullColor)
    drawArrow(true, bullColor)

    bullLineOut

finalizeBear() =>
    sameTrend = trend == -1
    midBar = math.ceil(math.avg(bearBar, bar_index))

    bearLineOut = finalLine(bearLine, bearBar, bearLevel, bearColor, sameTrend)

    if not showLive and showWick
        newWick(bearBar, bearLevel, bearExtreme)

    if not showLive
        drawBearBoxes(bearBar, bearHigh, bearLow, bearLevel)

        if bearHigh > bearLevel
            drawSweepLabel(bearBar, bearHigh, bearLevel, false)

    drawLabel(false, midBar, bearLevel, bearColor)
    drawArrow(false, bearColor)

    bearLineOut
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Execute {
if bullLSD
    bullLine := finalizeBull()

    trend := 1
    bullPending := false

    bullLine := na
    bullWick := na
    bullTopBox := na
    bullBotBox := na
    bullSweepLabel := na

if bearLSD
    bearLine := finalizeBear()

    trend := -1
    bearPending := false

    bearLine := na
    bearWick := na
    bearTopBox := na
    bearBotBox := na
    bearSweepLabel := na
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~  Alerts {
alertcondition(bullLSD, title = 'Bullish LSD', message = 'Bullish Liquidity Shift Detection confirmed.')
alertcondition(bearLSD, title = 'Bearish LSD', message = 'Bearish Liquidity Shift Detection confirmed.')
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
