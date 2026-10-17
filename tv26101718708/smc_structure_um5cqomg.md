# SMC Structure

- url: https://www.tradingview.com/script/uM5CQOmg-SMC-Structure/
- type: indicator
- pine_id: PUB;4410cbe0606e4fbab442bbecae7cacbd
- version: 1.0

## Description

A personal Script used for a SMC setup, Using ChoCh and BoS auto entry signals to better read the chart quickly

## Source Code

````pine
//@version=5
indicator("SMC Structure", overlay=true, max_lines_count=500, max_labels_count=500)

len    = input.int(10, "Swing Length")
col5m  = input.color(color.new(#2196F3,0), "5m Color")
col15m = input.color(color.new(#FF9800,0), "15m Color")
col4h  = input.color(color.new(#E040FB,0), "4H Color")

atrOffset = ta.atr(14) * 0.5

var float h1 = na
var int   h1b = na
var float l1 = na
var int   l1b = na
var bool  bearish = true
var bool  brokH = false
var bool  brokL = false

ph = ta.pivothigh(high, len, len)
pl = ta.pivotlow(low, len, len)

if not na(ph)
    h1    := ph
    h1b   := bar_index - len
    brokH := false

if not na(pl)
    l1    := pl
    l1b   := bar_index - len
    brokL := false

bullBreak = not na(h1) and not na(h1b) and close > h1 and close[1] <= h1 and not brokH
bearBreak = not na(l1) and not na(l1b) and close < l1 and close[1] >= l1 and not brokL

if bullBreak
    brokH   := true
    isChoch  = bearish
    col      = isChoch ? color.orange : color.green
    lbl      = isChoch ? "CHoCh" : "BoS"
    line.new(h1b, h1, bar_index, h1, color=col, width=1)
    label.new(bar_index, h1 - atrOffset, lbl, style=label.style_none, textcolor=col, size=size.tiny)
    bearish := false

if bearBreak
    brokL   := true
    isChoch  = not bearish
    col      = isChoch ? color.orange : color.green
    lbl      = isChoch ? "CHoCh" : "BoS"
    line.new(l1b, l1, bar_index, l1, color=col, width=1)
    label.new(bar_index, l1 - atrOffset, lbl, style=label.style_none, textcolor=col, size=size.tiny)
    bearish := true

getLevel(len) =>
    ph = ta.pivothigh(high, len, len)
    pl = ta.pivotlow(low, len, len)
    var float curSH = na
    var float curSL = na
    if not na(ph)
        curSH := ph
    if not na(pl)
        curSL := pl
    [curSH, curSL]

[sh5,  sl5]  = request.security(syminfo.tickerid, "5",   getLevel(len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sh15, sl15] = request.security(syminfo.tickerid, "15",  getLevel(len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
[sh4,  sl4]  = request.security(syminfo.tickerid, "240", getLevel(len), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)

var float p5sh  = na
var float p5sl  = na
var float p15sh = na
var float p15sl = na
var float p4sh  = na
var float p4sl  = na

if not na(sh5)
    p5sh := sh5
if not na(sl5)
    p5sl := sl5
if not na(sh15)
    p15sh := sh15
if not na(sl15)
    p15sl := sl15
if not na(sh4)
    p4sh := sh4
if not na(sl4)
    p4sl := sl4

var line  sh5l  = na
var label sh5b  = na
var line  sl5l  = na
var label sl5b  = na
var line  sh15l = na
var label sh15b = na
var line  sl15l = na
var label sl15b = na
var line  sh4l  = na
var label sh4b  = na
var line  sl4l  = na
var label sl4b  = na

if barstate.islast
    line.delete(sh5l)
    label.delete(sh5b)
    line.delete(sl5l)
    label.delete(sl5b)
    line.delete(sh15l)
    label.delete(sh15b)
    line.delete(sl15l)
    label.delete(sl15b)
    line.delete(sh4l)
    label.delete(sh4b)
    line.delete(sl4l)
    label.delete(sl4b)
    if not na(p5sh)
        sh5l := line.new(bar_index - 300, p5sh, bar_index, p5sh, color=col5m, width=1, extend=extend.right)
        sh5b := label.new(bar_index, p5sh - atrOffset, "5m SH", style=label.style_none, textcolor=col5m, size=size.tiny)
    if not na(p5sl)
        sl5l := line.new(bar_index - 300, p5sl, bar_index, p5sl, color=col5m, width=1, extend=extend.right)
        sl5b := label.new(bar_index, p5sl - atrOffset, "5m SL", style=label.style_none, textcolor=col5m, size=size.tiny)
    if not na(p15sh)
        sh15l := line.new(bar_index - 300, p15sh, bar_index, p15sh, color=col15m, width=1, extend=extend.right)
        sh15b := label.new(bar_index, p15sh - atrOffset, "15m SH", style=label.style_none, textcolor=col15m, size=size.tiny)
    if not na(p15sl)
        sl15l := line.new(bar_index - 300, p15sl, bar_index, p15sl, color=col15m, width=1, extend=extend.right)
        sl15b := label.new(bar_index, p15sl - atrOffset, "15m SL", style=label.style_none, textcolor=col15m, size=size.tiny)
    if not na(p4sh)
        sh4l := line.new(bar_index - 300, p4sh, bar_index, p4sh, color=col4h, width=2, extend=extend.right)
        sh4b := label.new(bar_index, p4sh - atrOffset, "4H SH", style=label.style_none, textcolor=col4h, size=size.tiny)
    if not na(p4sl)
        sl4l := line.new(bar_index - 300, p4sl, bar_index, p4sl, color=col4h, width=2, extend=extend.right)
        sl4b := label.new(bar_index, p4sl - atrOffset, "4H SL", style=label.style_none, textcolor=col4h, size=size.tiny)
````
