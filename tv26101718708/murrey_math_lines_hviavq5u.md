# Murrey Math Lines

- url: https://www.tradingview.com/script/HVIaVq5u-Murrey-Math-Lines/
- type: indicator
- pine_id: PUB;8e815a5ad8e94a419faf0d0c467dedc4
- version: 1.0

## Description

The Murrey Math Line (MML) indicator is a technical analysis tool based on the principles of W.D. Gann and the concept that price movement follows specific geometric proportions. It divides price action into a grid of eight equal segments (octaves) to identify potential support, resistance, and trend reversal points.

## Source Code

````pine
//@version=5
indicator("Murrey Math Lines", shorttitle="MML Latest Grid", overlay=true, max_lines_count=100, max_labels_count=100)

// ── Inputs
groupMain   = "Main"
res1        = input.timeframe("", "Resolution", group=groupMain)
frame       = input.int(64, "Frame Size", minval=8, maxval=256, group=groupMain)
mult        = input.float(1.5, "Frame Multiplier", minval=1.0, maxval=2.0, step=0.5, group=groupMain)
wicks       = input.bool(true, "Ignore Wicks?", group=groupMain)

groupLabels = "Labels"
showLabels  = input.bool(true, "Show Price / % Gap Labels", group=groupLabels)
labelOffset = input.int(1, "Label Offset Bars", minval=0, group=groupLabels)

groupStyle  = "Lines"

// Default hidden: +3/8, +2/8, -2/8, -3/8
show_p38 = input.bool(false, "Show +3/8", group=groupStyle)
show_p28 = input.bool(false, "Show +2/8", group=groupStyle)
show_p18 = input.bool(true,  "Show +1/8", group=groupStyle)
show_88  = input.bool(true,  "Show 8/8",  group=groupStyle)
show_78  = input.bool(true,  "Show 7/8",  group=groupStyle)
show_68  = input.bool(true,  "Show 6/8",  group=groupStyle)
show_58  = input.bool(true,  "Show 5/8",  group=groupStyle)
show_48  = input.bool(true,  "Show 4/8",  group=groupStyle)
show_38  = input.bool(true,  "Show 3/8",  group=groupStyle)
show_28  = input.bool(true,  "Show 2/8",  group=groupStyle)
show_18  = input.bool(true,  "Show 1/8",  group=groupStyle)
show_08  = input.bool(true,  "Show 0/8",  group=groupStyle)
show_m18 = input.bool(true,  "Show -1/8", group=groupStyle)
show_m28 = input.bool(false, "Show -2/8", group=groupStyle)
show_m38 = input.bool(false, "Show -3/8", group=groupStyle)

col_p38 = input.color(color.rgb(0, 128, 0),   "+3/8 Color", group=groupStyle)
col_p28 = input.color(color.rgb(255, 0, 0),   "+2/8 Color", group=groupStyle)
col_p18 = input.color(color.rgb(128, 128, 128), "+1/8 Color", group=groupStyle)
col_88  = input.color(color.rgb(0, 0, 255),   "8/8 Color", group=groupStyle)
col_78  = input.color(color.rgb(128, 128, 128), "7/8 Color", group=groupStyle)
col_68  = input.color(color.rgb(255, 0, 0),   "6/8 Color", group=groupStyle)
col_58  = input.color(color.rgb(0, 128, 0),   "5/8 Color", group=groupStyle)
col_48  = input.color(color.rgb(0, 0, 255),   "4/8 Color", group=groupStyle)
col_38  = input.color(color.rgb(0, 128, 0),   "3/8 Color", group=groupStyle)
col_28  = input.color(color.rgb(255, 0, 0),   "2/8 Color", group=groupStyle)
col_18  = input.color(color.rgb(128, 128, 128), "1/8 Color", group=groupStyle)
col_08  = input.color(color.rgb(0, 0, 255),   "0/8 Color", group=groupStyle)
col_m18 = input.color(color.rgb(128, 128, 128), "-1/8 Color", group=groupStyle)
col_m28 = input.color(color.rgb(255, 0, 0),   "-2/8 Color", group=groupStyle)
col_m38 = input.color(color.rgb(0, 128, 0),   "-3/8 Color", group=groupStyle)

w_p38 = input.int(1, "+3/8 Width", minval=1, maxval=5, group=groupStyle)
w_p28 = input.int(1, "+2/8 Width", minval=1, maxval=5, group=groupStyle)
w_p18 = input.int(1, "+1/8 Width", minval=1, maxval=5, group=groupStyle)
w_88  = input.int(2, "8/8 Width",  minval=1, maxval=5, group=groupStyle)
w_78  = input.int(1, "7/8 Width",  minval=1, maxval=5, group=groupStyle)
w_68  = input.int(1, "6/8 Width",  minval=1, maxval=5, group=groupStyle)
w_58  = input.int(1, "5/8 Width",  minval=1, maxval=5, group=groupStyle)
w_48  = input.int(2, "4/8 Width",  minval=1, maxval=5, group=groupStyle)
w_38  = input.int(1, "3/8 Width",  minval=1, maxval=5, group=groupStyle)
w_28  = input.int(1, "2/8 Width",  minval=1, maxval=5, group=groupStyle)
w_18  = input.int(1, "1/8 Width",  minval=1, maxval=5, group=groupStyle)
w_08  = input.int(2, "0/8 Width",  minval=1, maxval=5, group=groupStyle)
w_m18 = input.int(1, "-1/8 Width", minval=1, maxval=5, group=groupStyle)
w_m28 = input.int(1, "-2/8 Width", minval=1, maxval=5, group=groupStyle)
w_m38 = input.int(1, "-3/8 Width", minval=1, maxval=5, group=groupStyle)

// ── Math constants
logTen   = math.log(10.0)
log8     = math.log(8.0)
log2     = math.log(2.0)
lookback = math.round(frame * mult)

// ── Resolution source
ss  = syminfo.tickerid
res = res1 == "" ? timeframe.period : res1

o = request.security(ss, res, open)
c = request.security(ss, res, close)
h = request.security(ss, res, high)
l = request.security(ss, res, low)

uPrice = wicks ? math.max(o, c) : h
lPrice = wicks ? math.min(o, c) : l

// ── Murrey calculation
vLow  = ta.lowest(lPrice, lookback)
vHigh = ta.highest(uPrice, lookback)
vDist = vHigh - vLow

tmpHigh = vLow < 0 ? -vLow : vHigh
tmpLow  = vLow < 0 ? -vLow - vDist : vLow
shift   = vLow < 0

sfRaw = math.log(0.4 * tmpHigh) / logTen
sfVar = sfRaw - math.floor(sfRaw)

float SR = na
if tmpHigh > 25
    if sfVar > 0
        SR := math.exp(logTen * (math.floor(sfRaw) + 1))
    else
        SR := math.exp(logTen * math.floor(sfRaw))
else
    SR := 100 * math.exp(log8 * math.floor(math.log(0.005 * tmpHigh) / log8))

nVar1 = math.log(SR / (tmpHigh - tmpLow)) / log8
nVar2 = nVar1 - math.floor(nVar1)
N = nVar1 <= 0 ? 0 : nVar2 == 0 ? math.floor(nVar1) : math.floor(nVar1) + 1

SI = SR * math.exp(-N * log8)
M  = math.floor((1.0 / log2) * math.log((tmpHigh - tmpLow) / SI) + 0.0000001)
I  = math.round((tmpHigh + tmpLow) * 0.5 / (SI * math.exp((M - 1) * log2)))

Bot = (I - 1) * SI * math.exp((M - 1) * log2)
Top = (I + 1) * SI * math.exp((M - 1) * log2)

doShift = tmpHigh - Top > 0.25 * (Top - Bot) or Bot - tmpLow > 0.25 * (Top - Bot)
ER = doShift ? 1 : 0

MM = ER == 0 ? M : ER == 1 and M < 2 ? M + 1 : 0
NN = ER == 0 ? N : ER == 1 and M < 2 ? N : N - 1

finalSI  = ER == 1 ? SR * math.exp(-NN * log8) : SI
finalI   = ER == 1 ? math.round((tmpHigh + tmpLow) * 0.5 / (finalSI * math.exp((MM - 1) * log2))) : I
finalBot = ER == 1 ? (finalI - 1) * finalSI * math.exp((MM - 1) * log2) : Bot
finalTop = ER == 1 ? (finalI + 1) * finalSI * math.exp((MM - 1) * log2) : Top

increment = (finalTop - finalBot) / 8.0
absTop    = shift ? -(finalBot - 3.0 * increment) : finalTop + 3.0 * increment

plus38     = absTop
plus28     = absTop - increment
plus18     = absTop - 2.0 * increment
eightEight = absTop - 3.0 * increment
sevenEight = absTop - 4.0 * increment
sixEight   = absTop - 5.0 * increment
fiveEight  = absTop - 6.0 * increment
fourEight  = absTop - 7.0 * increment
threeEight = absTop - 8.0 * increment
twoEight   = absTop - 9.0 * increment
oneEight   = absTop - 10.0 * increment
zeroEight  = absTop - 11.0 * increment
minus18    = absTop - 12.0 * increment
minus28    = absTop - 13.0 * increment
minus38    = absTop - 14.0 * increment

// ── Labels text: price + % gap from line below
f_gap_text(_curr, _below) =>
    gapPct = _below != 0 ? ((_curr - _below) / _below) * 100.0 : na
    str.tostring(_curr, format.mintick) + " (" + str.tostring(gapPct, "#.##") + "%)"

// ── Persistent lines
var line ln_p38 = na
var line ln_p28 = na
var line ln_p18 = na
var line ln_88  = na
var line ln_78  = na
var line ln_68  = na
var line ln_58  = na
var line ln_48  = na
var line ln_38  = na
var line ln_28  = na
var line ln_18  = na
var line ln_08  = na
var line ln_m18 = na
var line ln_m28 = na
var line ln_m38 = na

// ── Persistent labels
var label lb_p38 = na
var label lb_p28 = na
var label lb_p18 = na
var label lb_88  = na
var label lb_78  = na
var label lb_68  = na
var label lb_58  = na
var label lb_48  = na
var label lb_38  = na
var label lb_28  = na
var label lb_18  = na
var label lb_08  = na
var label lb_m18 = na
var label lb_m28 = na
var label lb_m38 = na

// ── Draw only one latest grid, extended back exactly `frame` bars
if barstate.islast
    x1 = math.max(0, bar_index - frame + 1)
    x2 = bar_index
    lx = bar_index + labelOffset
    labelBg = color.new(color.white, 100)

    // +3/8
    if show_p38
        if na(ln_p38)
            ln_p38 := line.new(x1, plus38, x2, plus38, xloc=xloc.bar_index, extend=extend.none, color=col_p38, width=w_p38)
        else
            line.set_x1(ln_p38, x1), line.set_y1(ln_p38, plus38), line.set_x2(ln_p38, x2), line.set_y2(ln_p38, plus38), line.set_color(ln_p38, col_p38), line.set_width(ln_p38, w_p38)
        if showLabels
            txt = f_gap_text(plus38, plus28)
            if na(lb_p38)
                lb_p38 := label.new(lx, plus38, txt, style=label.style_label_left, textcolor=col_p38, color=labelBg, size=size.normal)
            else
                label.set_x(lb_p38, lx), label.set_y(lb_p38, plus38), label.set_text(lb_p38, txt), label.set_textcolor(lb_p38, col_p38)
        else
            if not na(lb_p38)
                label.delete(lb_p38)
                lb_p38 := na
    else
        if not na(ln_p38)
            line.delete(ln_p38)
            ln_p38 := na
        if not na(lb_p38)
            label.delete(lb_p38)
            lb_p38 := na

    // +2/8
    if show_p28
        if na(ln_p28)
            ln_p28 := line.new(x1, plus28, x2, plus28, xloc=xloc.bar_index, extend=extend.none, color=col_p28, width=w_p28)
        else
            line.set_x1(ln_p28, x1), line.set_y1(ln_p28, plus28), line.set_x2(ln_p28, x2), line.set_y2(ln_p28, plus28), line.set_color(ln_p28, col_p28), line.set_width(ln_p28, w_p28)
        if showLabels
            txt = f_gap_text(plus28, plus18)
            if na(lb_p28)
                lb_p28 := label.new(lx, plus28, txt, style=label.style_label_left, textcolor=col_p28, color=labelBg, size=size.normal)
            else
                label.set_x(lb_p28, lx), label.set_y(lb_p28, plus28), label.set_text(lb_p28, txt), label.set_textcolor(lb_p28, col_p28)
        else
            if not na(lb_p28)
                label.delete(lb_p28)
                lb_p28 := na
    else
        if not na(ln_p28)
            line.delete(ln_p28)
            ln_p28 := na
        if not na(lb_p28)
            label.delete(lb_p28)
            lb_p28 := na

    // +1/8
    if show_p18
        if na(ln_p18)
            ln_p18 := line.new(x1, plus18, x2, plus18, xloc=xloc.bar_index, extend=extend.none, color=col_p18, width=w_p18)
        else
            line.set_x1(ln_p18, x1), line.set_y1(ln_p18, plus18), line.set_x2(ln_p18, x2), line.set_y2(ln_p18, plus18), line.set_color(ln_p18, col_p18), line.set_width(ln_p18, w_p18)
        if showLabels
            txt = f_gap_text(plus18, eightEight)
            if na(lb_p18)
                lb_p18 := label.new(lx, plus18, txt, style=label.style_label_left, textcolor=col_p18, color=labelBg, size=size.normal)
            else
                label.set_x(lb_p18, lx), label.set_y(lb_p18, plus18), label.set_text(lb_p18, txt), label.set_textcolor(lb_p18, col_p18)
        else
            if not na(lb_p18)
                label.delete(lb_p18)
                lb_p18 := na
    else
        if not na(ln_p18)
            line.delete(ln_p18)
            ln_p18 := na
        if not na(lb_p18)
            label.delete(lb_p18)
            lb_p18 := na

    // 8/8
    if show_88
        if na(ln_88)
            ln_88 := line.new(x1, eightEight, x2, eightEight, xloc=xloc.bar_index, extend=extend.none, color=col_88, width=w_88)
        else
            line.set_x1(ln_88, x1), line.set_y1(ln_88, eightEight), line.set_x2(ln_88, x2), line.set_y2(ln_88, eightEight), line.set_color(ln_88, col_88), line.set_width(ln_88, w_88)
        if showLabels
            txt = f_gap_text(eightEight, sevenEight)
            if na(lb_88)
                lb_88 := label.new(lx, eightEight, txt, style=label.style_label_left, textcolor=col_88, color=labelBg, size=size.normal)
            else
                label.set_x(lb_88, lx), label.set_y(lb_88, eightEight), label.set_text(lb_88, txt), label.set_textcolor(lb_88, col_88)
        else
            if not na(lb_88)
                label.delete(lb_88)
                lb_88 := na
    else
        if not na(ln_88)
            line.delete(ln_88)
            ln_88 := na
        if not na(lb_88)
            label.delete(lb_88)
            lb_88 := na

    // 7/8
    if show_78
        if na(ln_78)
            ln_78 := line.new(x1, sevenEight, x2, sevenEight, xloc=xloc.bar_index, extend=extend.none, color=col_78, width=w_78)
        else
            line.set_x1(ln_78, x1), line.set_y1(ln_78, sevenEight), line.set_x2(ln_78, x2), line.set_y2(ln_78, sevenEight), line.set_color(ln_78, col_78), line.set_width(ln_78, w_78)
        if showLabels
            txt = f_gap_text(sevenEight, sixEight)
            if na(lb_78)
                lb_78 := label.new(lx, sevenEight, txt, style=label.style_label_left, textcolor=col_78, color=labelBg, size=size.normal)
            else
                label.set_x(lb_78, lx), label.set_y(lb_78, sevenEight), label.set_text(lb_78, txt), label.set_textcolor(lb_78, col_78)
        else
            if not na(lb_78)
                label.delete(lb_78)
                lb_78 := na
    else
        if not na(ln_78)
            line.delete(ln_78)
            ln_78 := na
        if not na(lb_78)
            label.delete(lb_78)
            lb_78 := na

    // 6/8
    if show_68
        if na(ln_68)
            ln_68 := line.new(x1, sixEight, x2, sixEight, xloc=xloc.bar_index, extend=extend.none, color=col_68, width=w_68)
        else
            line.set_x1(ln_68, x1), line.set_y1(ln_68, sixEight), line.set_x2(ln_68, x2), line.set_y2(ln_68, sixEight), line.set_color(ln_68, col_68), line.set_width(ln_68, w_68)
        if showLabels
            txt = f_gap_text(sixEight, fiveEight)
            if na(lb_68)
                lb_68 := label.new(lx, sixEight, txt, style=label.style_label_left, textcolor=col_68, color=labelBg, size=size.normal)
            else
                label.set_x(lb_68, lx), label.set_y(lb_68, sixEight), label.set_text(lb_68, txt), label.set_textcolor(lb_68, col_68)
        else
            if not na(lb_68)
                label.delete(lb_68)
                lb_68 := na
    else
        if not na(ln_68)
            line.delete(ln_68)
            ln_68 := na
        if not na(lb_68)
            label.delete(lb_68)
            lb_68 := na

    // 5/8
    if show_58
        if na(ln_58)
            ln_58 := line.new(x1, fiveEight, x2, fiveEight, xloc=xloc.bar_index, extend=extend.none, color=col_58, width=w_58)
        else
            line.set_x1(ln_58, x1), line.set_y1(ln_58, fiveEight), line.set_x2(ln_58, x2), line.set_y2(ln_58, fiveEight), line.set_color(ln_58, col_58), line.set_width(ln_58, w_58)
        if showLabels
            txt = f_gap_text(fiveEight, fourEight)
            if na(lb_58)
                lb_58 := label.new(lx, fiveEight, txt, style=label.style_label_left, textcolor=col_58, color=labelBg, size=size.normal)
            else
                label.set_x(lb_58, lx), label.set_y(lb_58, fiveEight), label.set_text(lb_58, txt), label.set_textcolor(lb_58, col_58)
        else
            if not na(lb_58)
                label.delete(lb_58)
                lb_58 := na
    else
        if not na(ln_58)
            line.delete(ln_58)
            ln_58 := na
        if not na(lb_58)
            label.delete(lb_58)
            lb_58 := na

    // 4/8
    if show_48
        if na(ln_48)
            ln_48 := line.new(x1, fourEight, x2, fourEight, xloc=xloc.bar_index, extend=extend.none, color=col_48, width=w_48)
        else
            line.set_x1(ln_48, x1), line.set_y1(ln_48, fourEight), line.set_x2(ln_48, x2), line.set_y2(ln_48, fourEight), line.set_color(ln_48, col_48), line.set_width(ln_48, w_48)
        if showLabels
            txt = f_gap_text(fourEight, threeEight)
            if na(lb_48)
                lb_48 := label.new(lx, fourEight, txt, style=label.style_label_left, textcolor=col_48, color=labelBg, size=size.normal)
            else
                label.set_x(lb_48, lx), label.set_y(lb_48, fourEight), label.set_text(lb_48, txt), label.set_textcolor(lb_48, col_48)
        else
            if not na(lb_48)
                label.delete(lb_48)
                lb_48 := na
    else
        if not na(ln_48)
            line.delete(ln_48)
            ln_48 := na
        if not na(lb_48)
            label.delete(lb_48)
            lb_48 := na

    // 3/8
    if show_38
        if na(ln_38)
            ln_38 := line.new(x1, threeEight, x2, threeEight, xloc=xloc.bar_index, extend=extend.none, color=col_38, width=w_38)
        else
            line.set_x1(ln_38, x1), line.set_y1(ln_38, threeEight), line.set_x2(ln_38, x2), line.set_y2(ln_38, threeEight), line.set_color(ln_38, col_38), line.set_width(ln_38, w_38)
        if showLabels
            txt = f_gap_text(threeEight, twoEight)
            if na(lb_38)
                lb_38 := label.new(lx, threeEight, txt, style=label.style_label_left, textcolor=col_38, color=labelBg, size=size.normal)
            else
                label.set_x(lb_38, lx), label.set_y(lb_38, threeEight), label.set_text(lb_38, txt), label.set_textcolor(lb_38, col_38)
        else
            if not na(lb_38)
                label.delete(lb_38)
                lb_38 := na
    else
        if not na(ln_38)
            line.delete(ln_38)
            ln_38 := na
        if not na(lb_38)
            label.delete(lb_38)
            lb_38 := na

    // 2/8
    if show_28
        if na(ln_28)
            ln_28 := line.new(x1, twoEight, x2, twoEight, xloc=xloc.bar_index, extend=extend.none, color=col_28, width=w_28)
        else
            line.set_x1(ln_28, x1), line.set_y1(ln_28, twoEight), line.set_x2(ln_28, x2), line.set_y2(ln_28, twoEight), line.set_color(ln_28, col_28), line.set_width(ln_28, w_28)
        if showLabels
            txt = f_gap_text(twoEight, oneEight)
            if na(lb_28)
                lb_28 := label.new(lx, twoEight, txt, style=label.style_label_left, textcolor=col_28, color=labelBg, size=size.normal)
            else
                label.set_x(lb_28, lx), label.set_y(lb_28, twoEight), label.set_text(lb_28, txt), label.set_textcolor(lb_28, col_28)
        else
            if not na(lb_28)
                label.delete(lb_28)
                lb_28 := na
    else
        if not na(ln_28)
            line.delete(ln_28)
            ln_28 := na
        if not na(lb_28)
            label.delete(lb_28)
            lb_28 := na

    // 1/8
    if show_18
        if na(ln_18)
            ln_18 := line.new(x1, oneEight, x2, oneEight, xloc=xloc.bar_index, extend=extend.none, color=col_18, width=w_18)
        else
            line.set_x1(ln_18, x1), line.set_y1(ln_18, oneEight), line.set_x2(ln_18, x2), line.set_y2(ln_18, oneEight), line.set_color(ln_18, col_18), line.set_width(ln_18, w_18)
        if showLabels
            txt = f_gap_text(oneEight, zeroEight)
            if na(lb_18)
                lb_18 := label.new(lx, oneEight, txt, style=label.style_label_left, textcolor=col_18, color=labelBg, size=size.normal)
            else
                label.set_x(lb_18, lx), label.set_y(lb_18, oneEight), label.set_text(lb_18, txt), label.set_textcolor(lb_18, col_18)
        else
            if not na(lb_18)
                label.delete(lb_18)
                lb_18 := na
    else
        if not na(ln_18)
            line.delete(ln_18)
            ln_18 := na
        if not na(lb_18)
            label.delete(lb_18)
            lb_18 := na

    // 0/8
    if show_08
        if na(ln_08)
            ln_08 := line.new(x1, zeroEight, x2, zeroEight, xloc=xloc.bar_index, extend=extend.none, color=col_08, width=w_08)
        else
            line.set_x1(ln_08, x1), line.set_y1(ln_08, zeroEight), line.set_x2(ln_08, x2), line.set_y2(ln_08, zeroEight), line.set_color(ln_08, col_08), line.set_width(ln_08, w_08)
        if showLabels
            txt = f_gap_text(zeroEight, minus18)
            if na(lb_08)
                lb_08 := label.new(lx, zeroEight, txt, style=label.style_label_left, textcolor=col_08, color=labelBg, size=size.normal)
            else
                label.set_x(lb_08, lx), label.set_y(lb_08, zeroEight), label.set_text(lb_08, txt), label.set_textcolor(lb_08, col_08)
        else
            if not na(lb_08)
                label.delete(lb_08)
                lb_08 := na
    else
        if not na(ln_08)
            line.delete(ln_08)
            ln_08 := na
        if not na(lb_08)
            label.delete(lb_08)
            lb_08 := na

    // -1/8
    if show_m18
        if na(ln_m18)
            ln_m18 := line.new(x1, minus18, x2, minus18, xloc=xloc.bar_index, extend=extend.none, color=col_m18, width=w_m18)
        else
            line.set_x1(ln_m18, x1), line.set_y1(ln_m18, minus18), line.set_x2(ln_m18, x2), line.set_y2(ln_m18, minus18), line.set_color(ln_m18, col_m18), line.set_width(ln_m18, w_m18)
        if showLabels
            txt = f_gap_text(minus18, minus28)
            if na(lb_m18)
                lb_m18 := label.new(lx, minus18, txt, style=label.style_label_left, textcolor=col_m18, color=labelBg, size=size.normal)
            else
                label.set_x(lb_m18, lx), label.set_y(lb_m18, minus18), label.set_text(lb_m18, txt), label.set_textcolor(lb_m18, col_m18)
        else
            if not na(lb_m18)
                label.delete(lb_m18)
                lb_m18 := na
    else
        if not na(ln_m18)
            line.delete(ln_m18)
            ln_m18 := na
        if not na(lb_m18)
            label.delete(lb_m18)
            lb_m18 := na

    // -2/8
    if show_m28
        if na(ln_m28)
            ln_m28 := line.new(x1, minus28, x2, minus28, xloc=xloc.bar_index, extend=extend.none, color=col_m28, width=w_m28)
        else
            line.set_x1(ln_m28, x1), line.set_y1(ln_m28, minus28), line.set_x2(ln_m28, x2), line.set_y2(ln_m28, minus28), line.set_color(ln_m28, col_m28), line.set_width(ln_m28, w_m28)
        if showLabels
            txt = f_gap_text(minus28, minus38)
            if na(lb_m28)
                lb_m28 := label.new(lx, minus28, txt, style=label.style_label_left, textcolor=col_m28, color=labelBg, size=size.normal)
            else
                label.set_x(lb_m28, lx), label.set_y(lb_m28, minus28), label.set_text(lb_m28, txt), label.set_textcolor(lb_m28, col_m28)
        else
            if not na(lb_m28)
                label.delete(lb_m28)
                lb_m28 := na
    else
        if not na(ln_m28)
            line.delete(ln_m28)
            ln_m28 := na
        if not na(lb_m28)
            label.delete(lb_m28)
            lb_m28 := na

    // -3/8
    if show_m38
        if na(ln_m38)
            ln_m38 := line.new(x1, minus38, x2, minus38, xloc=xloc.bar_index, extend=extend.none, color=col_m38, width=w_m38)
        else
            line.set_x1(ln_m38, x1), line.set_y1(ln_m38, minus38), line.set_x2(ln_m38, x2), line.set_y2(ln_m38, minus38), line.set_color(ln_m38, col_m38), line.set_width(ln_m38, w_m38)
        if showLabels
            txt = str.tostring(minus38, format.mintick)
            if na(lb_m38)
                lb_m38 := label.new(lx, minus38, txt, style=label.style_label_left, textcolor=col_m38, color=labelBg, size=size.normal)
            else
                label.set_x(lb_m38, lx), label.set_y(lb_m38, minus38), label.set_text(lb_m38, txt), label.set_textcolor(lb_m38, col_m38)
        else
            if not na(lb_m38)
                label.delete(lb_m38)
                lb_m38 := na
    else
        if not na(ln_m38)
            line.delete(ln_m38)
            ln_m38 := na
        if not na(lb_m38)
            label.delete(lb_m38)
            lb_m38 := na

// ── Alerts against latest levels
alertcondition(ta.crossover(close, plus38),     "Crossover +3/8", "Crossover +3/8")
alertcondition(ta.crossover(close, plus28),     "Crossover +2/8", "Crossover +2/8")
alertcondition(ta.crossover(close, plus18),     "Crossover +1/8", "Crossover +1/8")
alertcondition(ta.crossover(close, eightEight), "Crossover 8/8",  "Crossover 8/8")
alertcondition(ta.crossover(close, sevenEight), "Crossover 7/8",  "Crossover 7/8")
alertcondition(ta.crossover(close, sixEight),   "Crossover 6/8",  "Crossover 6/8")
alertcondition(ta.crossover(close, fiveEight),  "Crossover 5/8",  "Crossover 5/8")
alertcondition(ta.crossover(close, fourEight),  "Crossover 4/8",  "Crossover 4/8")
alertcondition(ta.crossover(close, threeEight), "Crossover 3/8",  "Crossover 3/8")
alertcondition(ta.crossover(close, twoEight),   "Crossover 2/8",  "Crossover 2/8")
alertcondition(ta.crossover(close, oneEight),   "Crossover 1/8",  "Crossover 1/8")
alertcondition(ta.crossover(close, zeroEight),  "Crossover 0/8",  "Crossover 0/8")
alertcondition(ta.crossover(close, minus18),    "Crossover -1/8", "Crossover -1/8")
alertcondition(ta.crossover(close, minus28),    "Crossover -2/8", "Crossover -2/8")
alertcondition(ta.crossover(close, minus38),    "Crossover -3/8", "Crossover -3/8")

alertcondition(ta.crossunder(close, plus38),     "Crossunder +3/8", "Crossunder +3/8")
alertcondition(ta.crossunder(close, plus28),     "Crossunder +2/8", "Crossunder +2/8")
alertcondition(ta.crossunder(close, plus18),     "Crossunder +1/8", "Crossunder +1/8")
alertcondition(ta.crossunder(close, eightEight), "Crossunder 8/8",  "Crossunder 8/8")
alertcondition(ta.crossunder(close, sevenEight), "Crossunder 7/8",  "Crossunder 7/8")
alertcondition(ta.crossunder(close, sixEight),   "Crossunder 6/8",  "Crossunder 6/8")
alertcondition(ta.crossunder(close, fiveEight),  "Crossunder 5/8",  "Crossunder 5/8")
alertcondition(ta.crossunder(close, fourEight),  "Crossunder 4/8",  "Crossunder 4/8")
alertcondition(ta.crossunder(close, threeEight), "Crossunder 3/8",  "Crossunder 3/8")
alertcondition(ta.crossunder(close, twoEight),   "Crossunder 2/8",  "Crossunder 2/8")
alertcondition(ta.crossunder(close, oneEight),   "Crossunder 1/8",  "Crossunder 1/8")
alertcondition(ta.crossunder(close, zeroEight),  "Crossunder 0/8",  "Crossunder 0/8")
alertcondition(ta.crossunder(close, minus18),    "Crossunder -1/8", "Crossunder -1/8")
alertcondition(ta.crossunder(close, minus28),    "Crossunder -2/8", "Crossunder -2/8")
alertcondition(ta.crossunder(close, minus38),    "Crossunder -3/8", "Crossunder -3/8")
````
