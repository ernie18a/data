# Bull & Bear Volume Bubbles [FEELS]

- url: https://www.tradingview.com/script/PmFmAZh8-Bull-Bear-Volume-Bubbles-FEELS/
- type: indicator
- pine_id: PUB;ff035fa050814b29a7ebbff23dd853e7
- version: 1.0

## Description

Where did heavy buying last trade, and where did heavy selling? Two lines, and the bubbles that put them there.

Every bar with unusual volume gets a bubble. The bigger the volume compared with the bars before it, the bigger the bubble. The script looks inside each bar through a lower timeframe, puts the bubble at the price where most of that bar's volume changed hands, and colours it by whether up-volume or down-volume was larger. Heavy bars that come in a run are grouped into one wave with one tag, and two lines keep the price of the last heavy bull bar and the last heavy bear bar on the chart.

What makes it different: heavy volume rarely comes alone. Instead of a bubble and a label on every bar of a run, heavy bars of the same colour close together are one wave: one tag on its biggest bar, with the count, and only that bubble at full strength. Two lines keep the price where the last heavy bull bar and the last heavy bear bar traded, so price above both, below both or between them reads at a glance. Each bubble sits at the price where most of its bar's volume traded, read from a lower timeframe.

[i]ETH/USD, 1D. The June low came as one bear wave of two heavy bars, tagged once. The August breakout is a bull wave of two, and price now trades above both lines.[/i]
https://www.tradingview.com/x/O3lHU36t/

[b]FEATURES[/b]

- A bubble on every bar with volume at least 1.5× the average of the 50 bars before it. Four sizes: from 1.5×, 2.2×, 3× and 4.5×.
- Bubble placed at the price where most of the bar's volume traded, read from a lower timeframe.
- Bubble coloured by up-volume against down-volume inside the bar.
- Heavy bars (3× and up) at full strength, the rest faded.
- Heavy bars of the same colour close together form one wave: one tag on its biggest bar, such as BULL VOL 4.5× · 4 bars, and only that bubble stays at full strength.
- Two lines: the price of the last heavy bull bar and of the last heavy bear bar.
- Hover a bubble to see its volume multiple, the up and down split, and the price where most volume traded.
- An optional panel with both lines and how far the current price is from each.
- Five alerts, all on bar close: heavy bull volume, heavy bear volume, heavy volume either side, close above the last bear line, close below the last bull line.
- Every threshold, word, colour, fade and line style can be changed.

[b]HOW IT WORKS[/b]

Size. A bar's volume is divided by the average volume of the 50 bars before it. The bar itself is left out of the average, so a spike can't raise its own yardstick. From 1.5× the bar gets a bubble, and from 3× it counts as heavy.

Place. The script reads the bar through a lower timeframe: 1h bars inside a daily bar, 15m inside 4h, 5m inside 1h, 1m inside 15m. It finds the lower-timeframe bar that carried the most volume and puts the bubble at that bar's price. On a long candle this is often near one end of it, not in the middle.

Colour. Inside the same bar, the volume of lower-timeframe bars that closed up is added up, and so is the volume of those that closed down. Green when up-volume is larger, red when down-volume is.

Waves. Heavy volume rarely comes alone. Heavy bars of the same colour no more than 15 bars apart are one wave. The wave gets one tag, on its biggest bar, on the side of the candle where that bubble sits. The count in the tag is the number of heavy bars in the wave. If two tags would land on the same side within 8 bars, they are split: a bull and a bear tag go above and below by which bubble is higher, and of two same-colour tags the newer one moves to the other side.

Lines. The two lines start at the bubble of the last heavy bull bar and the last heavy bear bar and run to the right edge, with their price.

Everything, alerts included, is decided on closed bars. A bubble, once drawn, does not move. A wave's tag can still move to a bigger bar while the wave is running.

[i]NVDA, 4h. The last heavy bear bar left a line at 191.24. Price came back to it through the summer, then moved above both lines.[/i]
https://www.tradingview.com/x/kJ9mwxEW/

[b]HOW TO READ IT[/b]

1. Big bubble, big volume. Size is always relative to the bars before it, not an absolute number.
2. Green bubble: more volume went through on rising lower-timeframe bars. Red: on falling ones. The candle colour can disagree with the bubble, and that disagreement is the information.
3. The position of the bubble inside the candle is where the volume traded. A bubble at the bottom of a long red candle means most of the selling happened near the low.
4. One tag per wave. BEAR VOL 4.7× · 4 bars means four heavy red bars close together, the biggest at 4.7× the average.
5. The two lines show where heavy buying and heavy selling last traded. Price above both, below both, or between them is a quick read of who last showed up in size.
6. Faded bubbles are ordinary above-average volume, and the faded heavy ones belong to a wave whose biggest bubble is elsewhere.

[i]SOL/USDT, 30m. Intraday. Price trades between the two lines: under the last heavy bull bar, above the last heavy bear bar.[/i]
https://www.tradingview.com/x/TBJ7xTvo/

[b]SETTINGS WORTH KNOWING[/b]

- [i]Heavy from, × average[/i]: 3 by default. Raise it to keep only the biggest volume.
- [i]Show bubbles under the heavy level[/i]: turn off to see heavy volume only.
- [i]Bubble sits[/i] and [i]Colour by[/i]: switch back to the middle of the bar and to where the bar closed, if you prefer the classic reading.
- [i]Pick the lower timeframe automatically[/i]: off lets you choose it yourself.
- [i]In a wave, only the biggest bubble at full strength[/i]: off shows every heavy bubble at full strength.
- [i]Same-colour heavy bars this close are one wave, bars[/i]: 15 by default. Lower it for more, shorter waves.
- [i]Show the panel[/i]: off by default.

[b]HONESTY[/b]

Up-volume and down-volume are added up from lower-timeframe bars that closed up or down. That is an approximation of buying and selling, not real order flow.

TradingView keeps lower-timeframe history for a limited number of bars. Further back, the bubble falls back to the middle of the bar (high + low + close ÷ 3) and its colour to where the bar closed in its range. On a chart timeframe under 15 minutes the bar itself is used the same way.

Heavy volume says that something happened, not what happens next. The script does not forecast and does not score itself.

Symbols without volume data draw nothing and say so.

Open source. Read it, change it, and tell me if something is wrong.

## Source Code

````pine
//@version=6
// Bull & Bear Volume Bubbles [FEELS]
// Version 0.7 — 2026-10-06
//
// Every bar with unusual volume gets a bubble. Its size is that bar's volume divided by the
// average of the bars before it.
//
// The script looks inside each bar through a lower timeframe (1h bars inside a daily bar, for
// example). The bubble sits at the price where most of that bar's volume traded, and its colour
// says who did more of the trading: green when the lower-timeframe bars that closed up carried
// more volume than those that closed down, red the other way. Where TradingView has no
// lower-timeframe history, the bubble falls back to the middle of the bar (high + low + close
// ÷ 3) and the colour to where the bar closed in its range.
//
// Heavy bars (3x average by default) usually come in a run. Heavy bars of the same colour
// close together count as one wave: only its biggest bubble stays at full strength, and the
// wave gets one tag on that bar, such as BULL VOL 4.5x · 4 bars.
//
// Two lines mark the price of the last heavy bull bar and the last heavy bear bar, so you can
// see at a glance whether price now trades above or below them.
//
// Nothing here is a forecast. It only describes where heavy volume traded and which side
// carried it. Everything is decided on closed bars.

indicator("Bull & Bear Volume Bubbles [FEELS]", "Volume Bubbles [FEELS]", overlay = true,
     max_labels_count = 500, max_lines_count = 50, behind_chart = false)
// behind_chart = false keeps the bubbles in front of the candles. It has to be a constant, so it
// can't be a setting. If you want the candles on top, use Visual Order → Send to Back.

// ─────────────────────────────────────────────────────────────── inputs ────
grpV = "Volume"
avgLen = input.int(50, "Average volume over the previous, bars", minval = 5, maxval = 500, group = grpV,
     tooltip = "A bar's volume is divided by the average of this many bars before it. The bar itself is left out, so a spike can't raise its own yardstick.")
t1     = input.float(1.5, "Small bubble from, × average", minval = 1.0, maxval = 50, step = 0.1, group = grpV)
t2     = input.float(2.2, "Medium bubble from, × average", minval = 1.0, maxval = 50, step = 0.1, group = grpV)
t3     = input.float(3.0, "Heavy from, × average", minval = 1.0, maxval = 50, step = 0.1, group = grpV,
     tooltip = "Heavy bubbles are drawn at full strength, get a BULL VOL / BEAR VOL tag and set the two lines.")
t4     = input.float(4.5, "Biggest bubble from, × average", minval = 1.0, maxval = 50, step = 0.1, group = grpV)

grpI = "Inside the bar"
posMode = input.string("Where most volume traded", "Bubble sits", options = ["Where most volume traded", "Middle of the bar"], group = grpI,
     tooltip = "Where most volume traded: the lower-timeframe bar with the most volume inside this bar, at its own middle. Middle of the bar: high + low + close ÷ 3.")
colMode = input.string("Up vs down volume inside the bar", "Colour by", options = ["Up vs down volume inside the bar", "Where the bar closed"], group = grpI,
     tooltip = "Up vs down volume: volume of the lower-timeframe bars that closed up against those that closed down. Where the bar closed: green in the upper half of its range, red in the lower.")
ltfAuto = input.bool(true, "Pick the lower timeframe automatically", group = grpI,
     tooltip = "1D and up reads 1h bars, 4h–1D reads 15m, 1h–4h reads 5m, 15m–1h reads 1m. Below 15m the bar itself is used.")
ltfMan  = input.timeframe("15", "Otherwise use", group = grpI)

grpW = "Waves"
tagOn  = input.bool(true, "Tag heavy volume", group = grpW)
oneBig = input.bool(true, "In a wave, only the biggest bubble at full strength", group = grpW,
     tooltip = "The other heavy bubbles of the wave are drawn faded, like ordinary ones. Keeps a crash or a squeeze from turning into a pile of bubbles.")
gap    = input.int(15, "Same-colour heavy bars this close are one wave, bars", minval = 1, maxval = 200, group = grpW,
     tooltip = "Heavy volume comes in runs. A run gets one tag on its biggest bar, with the number of heavy bars in it, instead of a tag on every bar.")
clash  = input.int(8, "Two tags closer than this go on opposite sides, bars", minval = 0, maxval = 50, group = grpW,
     tooltip = "When two tags would land on the same side of the candles this close together, the newer one moves to the other side. 0 turns this off.")
bullTx = input.string("BULL VOL", "Bull word", group = grpW)
bearTx = input.string("BEAR VOL", "Bear word", group = grpW)
barsTx = input.string("bars", "Word after the count", group = grpW)

grpLn = "Last heavy bull / bear"
lnOn       = input.bool(true, "Show the two lines", group = grpLn,
     tooltip = "At the price of the last heavy bull bar and the last heavy bear bar, measured the same way as the bubbles.")
lastBullTx = input.string("LAST BULL VOL", "Bull line words", group = grpLn)
lastBearTx = input.string("LAST BEAR VOL", "Bear line words", group = grpLn)
lnStyle    = input.string("Dashed", "Style", options = ["Dashed", "Dotted", "Solid"], group = grpLn)
lnWidth    = input.int(2, "Width", minval = 1, maxval = 5, group = grpLn)
lnRight    = input.int(6, "Runs past the last bar, bars", minval = 1, maxval = 100, group = grpLn)

grpP = "Panel"
panelOn  = input.bool(false, "Show the panel", group = grpP,
     tooltip = "Both lines with their price and how far the current price is from each.")
panelPos = input.string("Top right", "Where", options = ["Top right", "Bottom right", "Top left", "Bottom left"], group = grpP)

grpL = "Look"
colBull   = input.color(#2E8B60, "Bull", inline = "c", group = grpL)
colBear   = input.color(#B5453C, "Bear", inline = "c", group = grpL)
fadeBig   = input.int(38, "Heavy bubble fade, %", minval = 0, maxval = 95, group = grpL)
showSmall = input.bool(true, "Show bubbles under the heavy level", group = grpL)
fadeSmall = input.int(75, "Their fade, %", minval = 0, maxval = 95, group = grpL)
tagSize   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = grpL)
maxBub    = input.int(300, "Bubbles kept on the chart", minval = 20, maxval = 440, group = grpL,
     tooltip = "The oldest are removed first. TradingView allows 500 labels per script in total.")

// ─────────────────────────────────────────────────────────────── helpers ───
txtSz(s) =>
    s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : size.small

lnSt(s) =>
    s == "Dotted" ? line.style_dotted : s == "Solid" ? line.style_solid : line.style_dashed

tagText(word, m, n) =>
    word + " " + str.tostring(m, "0.0") + "×" + (n > 1 ? " · " + str.tostring(n) + " " + barsTx : "")

pctText(p, ref) =>
    d = (p - ref) / ref * 100
    (d >= 0 ? "+" : "") + str.tostring(d, "0.0") + "%"

// ─────────────────────────────────────────────────────────────── inside the bar ──
tfSec = timeframe.in_seconds()
ltfA  = tfSec >= 86400 ? "60" : tfSec >= 14400 ? "15" : tfSec >= 3600 ? "5" : tfSec >= 900 ? "1" : ""
ltf   = ltfAuto ? ltfA : ltfMan
useIn = ltf != "" and timeframe.in_seconds(ltf) < tfSec

[iH, iL, iC, iO, iV] = request.security_lower_tf(syminfo.tickerid, useIn ? ltf : timeframe.period, [high, low, close, open, volume])

// price of the lower-timeframe bar that carried the most volume, and up minus down volume
float poc  = na
float upV  = 0.0
float dnV  = 0.0
float topV = -1.0
n = useIn ? array.size(iV) : 0
if n > 0
    for k = 0 to n - 1
        v = array.get(iV, k)
        if not na(v)
            if v > topV
                topV := v
                poc  := (array.get(iH, k) + array.get(iL, k) + array.get(iC, k)) / 3
            o = array.get(iO, k)
            c = array.get(iC, k)
            if c > o
                upV += v
            else if c < o
                dnV += v
            else
                upV += v / 2
                dnV += v / 2
haveIn = n > 0 and not na(poc) and upV + dnV > 0

// ─────────────────────────────────────────────────────────────── measure ───
avgV   = ta.sma(volume, avgLen)[1]
hasVol = not na(volume) and not na(avgV) and avgV > 0
r      = hasVol ? volume / avgV : 0.0
rng    = high - low
bullCl = rng > 0 ? (close - low) / rng >= 0.5 : close >= open
bull   = colMode == "Where the bar closed" or not haveIn ? bullCl : upV >= dnV
py     = posMode == "Where most volume traded" and haveIn ? poc : hlc3
heavy  = hasVol and r >= t3
done   = barstate.isconfirmed

var bool anyVol = false
anyVol := anyVol or (not na(volume) and volume > 0)

// ─────────────────────────────────────────────────────────────── bubbles ───
var array<label> bubs = array.new<label>()
label thisBub = na

if done and hasVol and r >= t1 and (heavy or showSmall)
    bsz  = r >= t4 ? size.huge : r >= t3 ? size.large : r >= t2 ? size.normal : size.small
    bcol = color.new(bull ? colBull : colBear, heavy ? fadeBig : fadeSmall)
    side = haveIn and colMode != "Where the bar closed" ?
         "up volume " + str.tostring(upV / (upV + dnV) * 100, "0") + "% · down " + str.tostring(dnV / (upV + dnV) * 100, "0") + "%" :
         "closed in the " + (bullCl ? "upper" : "lower") + " half of the bar"
    at   = haveIn and posMode == "Where most volume traded" ? " · most volume near " + str.tostring(py, format.mintick) : ""
    tip  = str.tostring(r, "0.0") + "× the average volume · " + side + at
    thisBub := label.new(bar_index, py, "", style = label.style_circle, color = bcol, size = bsz, tooltip = tip)
    array.push(bubs, thisBub)
    if array.size(bubs) > maxBub
        label.delete(array.shift(bubs))

// ─────────────────────────────────────────────────────────────── waves ─────
// Heavy bars of the same colour no more than `gap` bars apart are one wave. While the wave goes
// on, its tag moves to the biggest bar and its count goes up. With oneBig on, the bubble that
// stops being the wave's biggest is faded.
//
// The tag sits on the biggest bar itself, on the side where that bar's bubble is: above the bar
// when the bubble is in its upper half, below when in the lower. If another tag already sits on
// that side within `clash` bars, the two are split: a bull and a bear tag go above / below by
// which bubble is higher, a same-colour pair puts the newer one on the other side.
var array<label> tags = array.new<label>()
var int   uLast = na
var label uTag  = na
var label uBig  = na
var float uMax  = na
var int   uCnt  = 0
var float uHi   = na
var float uLo   = na
var bool  uUp   = true
var float uPy   = na
var bool  uShow = true
var int   uPX   = na
var bool  uPUp  = true
var int   dLast = na
var label dTag  = na
var label dBig  = na
var float dMax  = na
var int   dCnt  = 0
var float dHi   = na
var float dLo   = na
var bool  dUp   = false
var float dPy   = na
var bool  dShow = false
var int   dPX   = na
var bool  dPUp  = false
upper     = py >= (high + low) / 2
fadedBull = color.new(colBull, fadeSmall)
fadedBear = color.new(colBear, fadeSmall)

if done and heavy and bull
    if na(uLast) or bar_index - uLast > gap
        if not na(uTag)
            uPX  := label.get_x(uTag)
            uPUp := uShow
        uCnt := 1
        uMax := r
        uHi  := high
        uLo  := low
        uUp  := upper
        uPy  := py
        uBig := thisBub
        if tagOn
            uTag := label.new(bar_index, high, "", color = colBull, textcolor = color.white, size = txtSz(tagSize))
            array.push(tags, uTag)
    else
        uCnt += 1
        if r > uMax
            uMax := r
            uHi  := high
            uLo  := low
            uUp  := upper
            uPy  := py
            if oneBig
                label.set_color(uBig, fadedBull)
            uBig := thisBub
            label.set_x(uTag, bar_index)
        else if oneBig
            label.set_color(thisBub, fadedBull)
    if not na(uTag)
        ux = label.get_x(uTag)
        sideU = uUp
        if not na(dTag) and math.abs(label.get_x(dTag) - ux) <= clash and dShow == sideU
            sideU := uPy >= dPy
            dShow := not sideU
            label.set_y(dTag, dShow ? dHi : dLo)
            label.set_style(dTag, dShow ? label.style_label_down : label.style_label_up)
        else if not na(uPX) and ux - uPX <= clash and uPUp == sideU
            sideU := not sideU
        uShow := sideU
        label.set_y(uTag, sideU ? uHi : uLo)
        label.set_style(uTag, sideU ? label.style_label_down : label.style_label_up)
        label.set_text(uTag, tagText(bullTx, uMax, uCnt))
        label.set_tooltip(uTag, str.tostring(uCnt) + " heavy bull bar(s) in this wave · the biggest " + str.tostring(uMax, "0.0") + "× the average volume")
    uLast := bar_index

if done and heavy and not bull
    if na(dLast) or bar_index - dLast > gap
        if not na(dTag)
            dPX  := label.get_x(dTag)
            dPUp := dShow
        dCnt := 1
        dMax := r
        dHi  := high
        dLo  := low
        dUp  := upper
        dPy  := py
        dBig := thisBub
        if tagOn
            dTag := label.new(bar_index, low, "", color = colBear, textcolor = color.white, size = txtSz(tagSize))
            array.push(tags, dTag)
    else
        dCnt += 1
        if r > dMax
            dMax := r
            dHi  := high
            dLo  := low
            dUp  := upper
            dPy  := py
            if oneBig
                label.set_color(dBig, fadedBear)
            dBig := thisBub
            label.set_x(dTag, bar_index)
        else if oneBig
            label.set_color(thisBub, fadedBear)
    if not na(dTag)
        dx = label.get_x(dTag)
        sideD = dUp
        if not na(uTag) and math.abs(label.get_x(uTag) - dx) <= clash and uShow == sideD
            sideD := dPy > uPy
            uShow := not sideD
            label.set_y(uTag, uShow ? uHi : uLo)
            label.set_style(uTag, uShow ? label.style_label_down : label.style_label_up)
        else if not na(dPX) and dx - dPX <= clash and dPUp == sideD
            sideD := not sideD
        dShow := sideD
        label.set_y(dTag, sideD ? dHi : dLo)
        label.set_style(dTag, sideD ? label.style_label_down : label.style_label_up)
        label.set_text(dTag, tagText(bearTx, dMax, dCnt))
        label.set_tooltip(dTag, str.tostring(dCnt) + " heavy bear bar(s) in this wave · the biggest " + str.tostring(dMax, "0.0") + "× the average volume")
    dLast := bar_index

if array.size(tags) > 50
    label.delete(array.shift(tags))

// ─────────────────────────────────────────────────────────────── last heavy bull / bear ──
var int   uX = na
var float uY = na
var int   dX = na
var float dY = na

if done and heavy and bull
    uX := bar_index
    uY := py
if done and heavy and not bull
    dX := bar_index
    dY := py

var line  uLn = na
var label uLb = na
var line  dLn = na
var label dLb = na

if barstate.islast and lnOn
    xr = bar_index + lnRight
    if not na(uX)
        ux1 = math.max(uX, bar_index - 4500)
        if na(uLn)
            uLn := line.new(ux1, uY, xr, uY, color = colBull, width = lnWidth, style = lnSt(lnStyle))
            uLb := label.new(xr, uY, "", style = label.style_label_left, color = colBull,
                 textcolor = color.white, size = txtSz(tagSize))
        line.set_xy1(uLn, ux1, uY)
        line.set_xy2(uLn, xr, uY)
        label.set_xy(uLb, xr, uY)
        label.set_text(uLb, lastBullTx + "  " + str.tostring(uY, format.mintick))
    if not na(dX)
        dx1 = math.max(dX, bar_index - 4500)
        if na(dLn)
            dLn := line.new(dx1, dY, xr, dY, color = colBear, width = lnWidth, style = lnSt(lnStyle))
            dLb := label.new(xr, dY, "", style = label.style_label_left, color = colBear,
                 textcolor = color.white, size = txtSz(tagSize))
        line.set_xy1(dLn, dx1, dY)
        line.set_xy2(dLn, xr, dY)
        label.set_xy(dLb, xr, dY)
        label.set_text(dLb, lastBearTx + "  " + str.tostring(dY, format.mintick))

// ─────────────────────────────────────────────────────────────── panel ─────
pPos = panelPos == "Bottom right" ? position.bottom_right : panelPos == "Top left" ? position.top_left :
     panelPos == "Bottom left" ? position.bottom_left : position.top_right
var table panel = table.new(pPos, 2, 2)

if barstate.islast and not anyVol
    table.cell(panel, 0, 0, "This symbol has no volume data, so there is nothing to draw.",
         text_color = chart.fg_color, text_size = txtSz(tagSize))
else if barstate.islast and panelOn
    table.cell(panel, 0, 0, lastBullTx, text_color = colBull, text_size = txtSz(tagSize), text_halign = text.align_left)
    table.cell(panel, 1, 0, na(uY) ? "–" : str.tostring(uY, format.mintick) + "   " + pctText(close, uY),
         text_color = chart.fg_color, text_size = txtSz(tagSize), text_halign = text.align_right)
    table.cell(panel, 0, 1, lastBearTx, text_color = colBear, text_size = txtSz(tagSize), text_halign = text.align_left)
    table.cell(panel, 1, 1, na(dY) ? "–" : str.tostring(dY, format.mintick) + "   " + pctText(close, dY),
         text_color = chart.fg_color, text_size = txtSz(tagSize), text_halign = text.align_right)

// ─────────────────────────────────────────────────────────────── alerts ────
// All alerts wait for the bar to close, like the drawing does, so a half-built bar can't fire one.
// uY / dY already include this bar once it closes, so the crosses compare with the previous value.
alertcondition(done and heavy and bull, "Heavy bull volume", "Heavy volume, bull side")
alertcondition(done and heavy and not bull, "Heavy bear volume", "Heavy volume, bear side")
alertcondition(done and heavy, "Heavy volume, either side", "Heavy volume")
alertcondition(done and not na(dY[1]) and close > dY[1] and close[1] <= dY[1], "Closed above the last bear volume", "Price closed above the last heavy bear bar")
alertcondition(done and not na(uY[1]) and close < uY[1] and close[1] >= uY[1], "Closed below the last bull volume", "Price closed below the last heavy bull bar")
````
