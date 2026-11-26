# BSL/SSL + Real-Time FVGs + 5m MSS

- url: https://www.tradingview.com/script/1DwK7FAF-BSL-SSL-Real-Time-FVGs-5m-MSS/
- type: indicator
- pine_id: PUB;1a8bef000c6e4d0fbf547fb0a7309c65
- version: 1.0

## Description

Enjoy a free ict indicator to spot buy side and sell side liquidity sweeps, with fvgs, mss, in real time.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ 
// © LuxAlgo

//@version=6
indicator("BSL/SSL + Real-Time FVGs + 5m MSS", "LuxAlgo - BSL/SSL + FVGs + MSS", overlay = true,  max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 3000)

//------------------------------------------------------------------------------
//Settings
//-----------------------------------------------------------------------------{
liqGrp = 'Liquidity Detection'
liqLen = input.int   (7, title = 'Detection Length', minval = 3, maxval = 13, inline = 'LIQ', group = liqGrp)
liqMar = 10 / input.float (6.9, 'Margin', minval = 4, maxval = 9, step = 0.1, inline = 'LIQ', group = liqGrp)

liqBuy = input.bool (true, 'Buyside Liquidity Zones, Margin', inline = 'Buyside', group = liqGrp)
marBuy    = input.float(2.3, '', minval = 1.5, maxval = 10, step = .1, inline = 'Buyside', group = liqGrp)
cLIQ_B = input.color (color.new(#4caf50,  0), '', inline = 'Buyside', group = liqGrp)

liqSel = input.bool (true, 'Sellside Liquidity Zones, Margin', inline = 'Sellside', group = liqGrp)
marSel = input.float(2.3, '', minval = 1.5, maxval = 10, step = .1, inline = 'Sellside', group = liqGrp)
cLIQ_S = input.color (color.new(#f23645,  0), '', inline = 'Sellside', group = liqGrp)

mode   = input.string('Present', title = 'Mode', options =['Present', 'Historical'], inline = 'MOD', group = liqGrp)
visLiq = input.int   (3, '    # Visible Levels', minval = 1, maxval = 50, inline = 'MOD', group = liqGrp)

fvgGrp = 'Fair Value Gaps'
showFvg = input.bool(true, 'Show Real-Time FVGs', group = fvgGrp, tooltip = "Shows FVGs as they form. Does not show FVGs that form inside active liquidity zones.")
fvgVolFilter = input.float(0.5, 'Volatility Filter (ATR Multiple)', minval = 0, step = 0.1, group = fvgGrp)
fvgMaxCount = input.int(5, 'Max FVGs to Display', minval = 1, maxval = 50, group = fvgGrp)
fvgBullColor = input.color(color.new(#089981, 80), 'Bullish FVG Color', group = fvgGrp)
fvgBearColor = input.color(color.new(#f23645, 80), 'Bearish FVG Color', group = fvgGrp)

mssGrp = 'Market Structure Shift'
showMSS = input.bool(true, 'Show 5m MSS', group = mssGrp)
mssBullColor = input.color(#089981, 'Bullish MSS Color', group = mssGrp)
mssBearColor = input.color(#f23645, 'Bearish MSS Color', group = mssGrp)
mssLineStyle = input.string(line.style_dashed, 'MSS Line Style', options = [line.style_solid, line.style_dashed, line.style_dotted], group = mssGrp)
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
//General Calculations
//-----------------------------------------------------------------------------{
maxSize = 50
atr     = ta.atr(10)
per     = mode == 'Present' ? last_bar_index - bar_index <=  500 : true
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
//User Defined Types
//-----------------------------------------------------------------------------{
type ZZ 
    int   [] d
    int   [] x 
    float [] y 

type bar
    float o = open
    float h = high
    float l = low
    float c = close
    int   i = bar_index

type liq
    box   bx
    box   bxz
    box   bxt
    bool  brZ
    bool  brL
    line  ln
    line  lne

type fvg
    box   bx
    float top
    float bot
    bool  mitigated = false
    int   dir // 1 for Bullish, -1 for Bearish
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
//Variables
//-----------------------------------------------------------------------------{
var ZZ aZZ = ZZ.new(array.new<int>(maxSize, 0), array.new<int>(maxSize, 0), array.new<float>(maxSize, na))
bar b = bar.new()

var liq[] b_liq_B = array.new<liq> (1, liq.new(box(na), box(na), box(na), false, false, line(na), line(na)))
var liq[] b_liq_S = array.new<liq> (1, liq.new(box(na), box(na), box(na), false, false, line(na), line(na)))

var fvg[] fvg_array = array.new<fvg>()

var int dir = na, var int x1 = na, var float y1 = na, var int x2 = na, var float y2 = na
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
//Functions/methods
//-----------------------------------------------------------------------------{
method in_out(ZZ aZZ, int _d, int _x, float _y) =>
    aZZ.d.unshift(_d), aZZ.x.unshift(_x), aZZ.y.unshift(_y), aZZ.d.pop(), aZZ.x.pop(), aZZ.y.pop()

max_bars_back(time, 1000)

check_alignment(float top, float bot, liq[] liq_array) =>
    bool aligned = false
    if liq_array.size() > 0
        for i = 0 to liq_array.size() - 1
            l = liq_array.get(i)
            if l.brZ
                zTop = l.bxz.get_top()
                zBot = l.bxz.get_bottom()
                if not (top < zBot or bot > zTop)
                    aligned := true
                    break
    aligned
//-----------------------------------------------------------------------------}

//-----------------------------------------------------------------------------
//Calculations
//-----------------------------------------------------------------------------{
x2 := b.i - 1
ph  = ta.pivothigh(liqLen, 1)
pl  = ta.pivotlow (liqLen, 1)

// --- Liquidity Logic ---
if not na(ph)   
    dir := aZZ.d.get(0), x1  := aZZ.x.get(0), y1  := aZZ.y.get(0), y2  := nz(high[1])
    if dir < 1
        aZZ.in_out(1, x2, y2)
    else
        if dir == 1 and ph > y1 
            aZZ.x.set(0, x2), aZZ.y.set(0, y2)
    
    if per
        count = 0, st_P = 0., st_B = 0, minP = 0., maxP = 10e6
        for i = 0 to maxSize - 1
            if aZZ.d.get(i) ==  1 
                if aZZ.y.get(i) > ph + (atr / liqMar)
                    break
                else
                    if aZZ.y.get(i) > ph - (atr / liqMar) and aZZ.y.get(i) < ph + (atr / liqMar)
                        count += 1, st_B := aZZ.x.get(i), st_P := aZZ.y.get(i)
                        if aZZ.y.get(i) > minP
                            minP := aZZ.y.get(i)
                        if aZZ.y.get(i) < maxP 
                            maxP := aZZ.y.get(i)

        if count > 2
            getB = b_liq_B.get(0)
            if st_B == getB.bx.get_left()
                getB.bx.set_top(math.avg(minP, maxP) + (atr / liqMar))
                getB.bx.set_rightbottom(b.i + 10, math.avg(minP, maxP) - (atr / liqMar))
            else
                b_liq_B.unshift(liq.new(box.new(st_B, math.avg(minP, maxP) + (atr / liqMar), b.i + 10, math.avg(minP, maxP) - (atr / liqMar), bgcolor=color(na), border_color=color(na)), box.new(na, na, na, na, bgcolor = color(na), border_color = color(na)), box.new(st_B, st_P, b.i + 10, st_P, text = 'Buyside liquidity', text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom, text_color = color.new(cLIQ_B, 25), bgcolor = color(na), border_color = color(na)), false, false, line.new(st_B, st_P, b.i - 1, st_P, color = color.new(cLIQ_B, 0)), line.new(b.i - 1, st_P, na, st_P, color = color.new(cLIQ_B, 0), style = line.style_dotted)))

            if b_liq_B.size() > visLiq
                getLast = b_liq_B.pop()
                getLast.bx.delete(), getLast.bxz.delete(), getLast.bxt.delete(), getLast.ln.delete(), getLast.lne.delete()               

if not na(pl)
    dir := aZZ.d.get (0), x1  := aZZ.x.get (0), y1  := aZZ.y.get (0), y2  := nz(low[1])
    if dir > -1
        aZZ.in_out(-1, x2, y2)
    else
        if dir == -1 and pl < y1 
            aZZ.x.set(0, x2), aZZ.y.set(0, y2)
    
    if per
        count = 0, st_P = 0., st_B = 0, minP = 0., maxP = 10e6
        for i = 0 to maxSize - 1
            if aZZ.d.get(i) == -1 
                if aZZ.y.get(i) < pl - (atr / liqMar)
                    break
                else
                    if aZZ.y.get(i) > pl - (atr / liqMar) and aZZ.y.get(i) < pl + (atr / liqMar)
                        count += 1, st_B := aZZ.x.get(i), st_P := aZZ.y.get(i)
                        if aZZ.y.get(i) > minP
                            minP := aZZ.y.get(i)
                        if aZZ.y.get(i) < maxP 
                            maxP := aZZ.y.get(i)

        if count > 2
            getB = b_liq_S.get(0)
            if st_B == getB.bx.get_left()
                getB.bx.set_top(math.avg(minP, maxP) + (atr / liqMar))
                getB.bx.set_rightbottom(b.i + 10, math.avg(minP, maxP) - (atr / liqMar))
            else
                b_liq_S.unshift(liq.new(box.new(st_B, math.avg(minP, maxP) + (atr / liqMar), b.i + 10, math.avg(minP, maxP) - (atr / liqMar), bgcolor=color(na), border_color=color(na)), box.new(na, na, na, na, bgcolor=color(na), border_color=color(na)), box.new(st_B, st_P, b.i + 10, st_P, text = 'Sellside liquidity', text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top, text_color = color.new(cLIQ_S, 25), bgcolor=color(na), border_color=color(na)), false, false, line.new(st_B, st_P, b.i - 1, st_P, color = color.new(cLIQ_S, 0)), line.new(b.i - 1, st_P, na, st_P, color = color.new(cLIQ_S, 0), style = line.style_dotted)))

            if b_liq_S.size() > visLiq
                getLast = b_liq_S.pop()
                getLast.bx.delete(), getLast.bxz.delete(), getLast.bxt.delete(), getLast.ln.delete(), getLast.lne.delete()               

// Update Zone Status
for i = 0 to b_liq_B.size() - 1
    x = b_liq_B.get(i)
    if not x.brL
        x.lne.set_x2(b.i)
        if high > x.bx.get_top()
            x.brL := true, x.brZ := true
            x.bxz.set_lefttop(b.i - 1, math.min(x.ln.get_y1() + marBuy * (atr), high))
            x.bxz.set_rightbottom(b.i + 1, x.ln.get_y1())
            x.bxz.set_bgcolor(color.new(cLIQ_B, liqBuy ? 73 : 100))
    else if x.brZ
        if low > x.ln.get_y1() - marBuy * (atr) and high < x.ln.get_y1() + marBuy * (atr)
            x.bxz.set_right(b.i + 1), x.bxz.set_top(math.max(high, x.bxz.get_top()))
            if liqBuy
                x.lne.set_x2(b.i + 1)
        else
            x.brZ := false

for i = 0 to b_liq_S.size() - 1
    x = b_liq_S.get(i)
    if not x.brL
        x.lne.set_x2(b.i)
        if low < x.bx.get_bottom()
            x.brL := true, x.brZ := true
            x.bxz.set_lefttop(b.i - 1, x.ln.get_y1())
            x.bxz.set_rightbottom(b.i + 1, math.max(x.ln.get_y1() - marSel * (atr), low))
            x.bxz.set_bgcolor(color.new(cLIQ_S, liqSel ? 73 : 100))
    else if x.brZ
        if low > x.ln.get_y1() - marSel * (atr) and high < x.ln.get_y1() + marSel * (atr)
            x.bxz.set_rightbottom(b.i + 1, math.min(low, x.bxz.get_bottom()))
            if liqSel
                x.lne.set_x2(b.i + 1)
        else
            x.brZ := false

// --- Real-Time FVG Logic ---
if showFvg
    isBullFvg = low > high[2]
    isBearFvg = high < low[2]
    atrVal = ta.atr(14)
    
    if isBullFvg and (low - high[2]) > atrVal * fvgVolFilter
        if not check_alignment(low, high[2], b_liq_B) and not check_alignment(low, high[2], b_liq_S)
            fvg_array.unshift(fvg.new(box.new(b.i - 1, low, b.i, high[2], bgcolor = fvgBullColor, border_color = color.new(fvgBullColor, 50)), low, high[2], false, 1))
            
    if isBearFvg and (low[2] - high) > atrVal * fvgVolFilter
        if not check_alignment(low[2], high, b_liq_B) and not check_alignment(low[2], high, b_liq_S)
            fvg_array.unshift(fvg.new(box.new(b.i - 1, low[2], b.i, high, bgcolor = fvgBearColor, border_color = color.new(fvgBearColor, 50)), low[2], high, false, -1))

    if fvg_array.size() > 0
        for i = fvg_array.size() - 1 to 0
            f = fvg_array.get(i)
            if not f.mitigated
                f.bx.set_right(b.i + 1)
                if (f.dir == 1 and close < f.bot) or (f.dir == -1 and close > f.top)
                    f.mitigated := true
            
    if fvg_array.size() > fvgMaxCount
        oldest = fvg_array.pop()
        oldest.bx.delete()

// --- 5m MSS Logic + Line ---
[h5, l5, c5, ph5, pl5, idx5] = request.security(syminfo.tickerid, "5", [high, low, close, ta.pivothigh(3, 3), ta.pivotlow(3, 3), bar_index])

var float lastPH5 = na, var float lastPL5 = na
var int lastPHidx = na, var int lastPLidx = na
var bool phFound = false, var bool plFound = false

if not na(ph5)
    lastPH5 := ph5
    lastPHidx := b.i // Approximate bar index on current chart
    phFound := true
if not na(pl5)
    lastPL5 := pl5
    lastPLidx := b.i
    plFound := true

if showMSS
    // Bullish Shift: Price breaks above previous structural high
    if phFound and close > lastPH5
        label.new(b.i, high, "MSS", color = #00000000, textcolor = mssBullColor, style = label.style_label_down, size = size.small)
        // Draw line from pivot to break point
        line.new(lastPHidx - 5, lastPH5, b.i, lastPH5, color = mssBullColor, style = mssLineStyle, width = 1)
        lastPH5 := na, phFound := false
    
    // Bearish Shift: Price breaks below previous structural low
    if plFound and close < lastPL5
        label.new(b.i, low, "MSS", color = #00000000, textcolor = mssBearColor, style = label.style_label_up, size = size.small)
        // Draw line from pivot to break point
        line.new(lastPLidx - 5, lastPL5, b.i, lastPL5, color = mssBearColor, style = mssLineStyle, width = 1)
        lastPL5 := na, plFound := false
//-----------------------------------------------------------------------------}
````
