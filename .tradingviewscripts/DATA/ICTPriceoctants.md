<!-- tradingview-pine-id: PUB;e0fbc056208547b6aeb91bddbc56d81c -->
<!-- tradingviewscripts-format: 1 -->
# ICT-Price-octants

Source: https://www.tradingview.com/script/RjhQiloV/

## Description

Permit the user to select two price levels, and compute the mid point, or quadrants or octants for the range.
If so configured, extends the octants as price moves out of the selected price range.
Can generate alerts if price seems to bounce exactly at an octant level.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © franjballest

// Ask for two points for a range, and then
// draw quadrants and proyections on a given range to determine ICT relevant levels.

//@version=6
indicator("ICT-Price-octants", overlay=true, 
    max_lines_count    = 500,
    max_labels_count = 500,
    max_bars_back=5000
 
    )

getstyle(s) =>
    switch s
        "solid" => line.style_solid
        "dashed" => line.style_dashed
        "dotted" => line.style_dotted


// Line/Box style
type Sty
    string sty  // solid/dotted/dashed
    int wid     // width
    color col   // color
    color col2 = na   // background or secondary color if any


var G_MAIN = "Main settings"
var p0 = input.price(0, title="First level", group=G_MAIN, confirm=true)
var p1 = input.price(0, title="Second level", group = G_MAIN, confirm=true)

var nq = input.int(4, "Number of levels (2, 4, 8)", options=[2,4,8], group = G_MAIN, 
     tooltip = "just C.E. or quadrants or octants")
var auto = input.bool(true, "Proyect the range as price moves outside (auto)", group = G_MAIN)
var po3up = input.int(1, "Number of proyections above",  minval=0, maxval=50, 
     group = G_MAIN, tooltip = "number of std.dev. lines to be drawn above the range unless auto")
var po3down = input.int(1, "Number of proyections below", group = G_MAIN, minval=0, maxval=50,
     tooltip = "number of std.dev. lines to be drawn below the range unless auto")

var dorect = input.bool(false, "Draw rectangle", group = G_MAIN, inline = "rect")
var rcol = input.color(color.new(color.blue,90), "", group = G_MAIN, inline = "rect")
var dovline = input.bool(true, "Draw time lines", group=G_MAIN, inline = "vln")
var vxlnsty = getstyle(input.string("solid", "line style", 
    options=["solid", "dashed", "dotted"], group = G_MAIN, inline="vln"))
var vlnwid = input.int(1, "", options = [1, 2, 3], group = G_MAIN, inline = "vln")
var vlncol = input.color(color.black, "", group = G_MAIN, inline = "vln")
var vlnsty = Sty.new(vxlnsty, vlnwid, vlncol)
var xlnsty = getstyle(input.string("solid", "line style", 
    options=["solid", "dashed", "dotted"], group = G_MAIN, inline="dayln"))
var lnwid = input.int(2, "", options = [1, 2, 3], group = G_MAIN, inline = "dayln")
var lncol = input.color(color.blue, "", group = G_MAIN, inline = "dayln")
var lnsty = Sty.new(xlnsty, lnwid, lncol, rcol)

var doalerts = input.bool(false, "alert of candle bounces on levels", group = G_MAIN)

var tfok = timeframe.isminutes and timeframe.multiplier <=60

// Instance of a range
type Range
    float hi 
    float lo
    box rect = na // rectangle drawn if any
    array<line> qs =  na // array of cuadrants and PO3s
    bool drawrect = false
    Sty sty = na// line style
    float minprj = na   // price for min stddev
    float maxprj = na   // price for max stddev
    float wid = na // sep between lines
    line vline0 = na
    line vline1 = na
    

mkRange(hi, lo) =>
    zz = Range.new(hi, lo)
    zz.sty := lnsty
    zz

method mkline(Range zn, float p, bool isx = false) =>
    ln = line.new(bar_index, p, last_bar_index, p, color = zn.sty.col,
        extend = extend.both,
        width = zn.sty.wid, style=zn.sty.sty)
    zn.qs.push(ln)
   
method mklines(Range zn) =>
    zn.mkline(zn.hi)
    zn.mkline(zn.lo)
    rg = math.abs(zn.hi-zn.lo)
    zn.wid := rg/nq
    p = zn.lo
    zn.minprj := zn.lo
    zn.maxprj := zn.hi
    for i = 0 to nq-1
        p += zn.wid 
        zn.mkline(p)
    p := zn.hi
    for i = 0 to po3up-1
        if po3up <= 0
            break
        p += zn.wid 
        zn.mkline(p, isx=true)
        zn.maxprj := p
    for i = 1 to po3down-1
        if po3down <= 0
            break
        p -= zn.wid 
        zn.mkline(p, isx = true)
        zn.minprj := p



    
method update(Range zn) =>
    if na(zn.qs)
        zn.qs := array.new<line>()
        if zn.qs.size() == 0
            zn.mklines()
    if na(zn.rect) and dorect
        zn.rect := box.new(bar_index, zn.lo, last_bar_index, zn.hi, 
        extend = extend.both, 
        border_color = zn.sty.col, bgcolor = zn.sty.col2)
    if auto
        if low < zn.minprj
            zn.minprj := zn.minprj - zn.wid
            zn.mkline(zn.minprj, isx = true)
        if high > zn.maxprj
            zn.maxprj := zn.maxprj + zn.wid
            zn.mkline(zn.maxprj, isx = true)
    true


method alerts(Range zn) =>
    if not na(zn) and not na(zn.qs)
        for ln in zn.qs
            y = ln.get_y1()
            if math.abs(y-low) < 2 and close > low+10
                alert("bounce up at octant", alert.freq_once_per_bar)
            if math.abs(y-high) < 2 and close < high-10
                alert("bounce down at octant", alert.freq_once_per_bar)
 
var Range rg = mkRange(p0, p1)
if tfok
    rg.update()

    if doalerts
        rg.alerts()
````
