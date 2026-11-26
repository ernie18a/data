# supply and demand based liquiditiy [use 10 min TF only]

- url: https://www.tradingview.com/script/2CxfTQuA-supply-and-demand-based-liquiditiy-use-10-min-TF-only/
- type: indicator
- pine_id: PUB;4ecd9c2cc27b412686827f532b9e4c9d
- version: 1.0

## Description

most powerful supply and demand strategy, so only applied to 10 min time frame like it draw high probable supply and demand, so no need to feel the pair of drawing S&D zones

## Source Code

````pine
 //@version=5
// =============================================================================
//  LIQUIDITY-FILTERED S&D — FRESH  (v3)
//  • Front-line liquidity only: nearest untaken pool above & below price.
//  • A zone is VALID only if front-line liquidity sits between it and price
//    (that liquidity is taken first). The zone that IS the liquidity is hidden.
//  • FRESH only: once price returns and tests a zone, it is deleted.
//  • Shows only the nearest valid+fresh zone per side. "✓" = liquidity taken.
//  DELETE all previous versions before adding this. Sources CC BY-NC-SA 4.0.
// =============================================================================
indicator("Liquidity-Filtered S&D — Fresh", overlay = true, max_boxes_count = 300, max_lines_count = 100, max_labels_count = 100)

// ------------------------------ INPUTS -------------------------------------
grpSD    = "Supply / Demand"
showSD   = input.bool(true,  "Show zones",                    group = grpSD)
impCand  = input.int(2,      "Impulse candles (2-3)",         group = grpSD, minval = 2, maxval = 3)
volLen   = input.int(200,    "Volume average length",         group = grpSD, minval = 10)
volMult  = input.float(1.0,  "Volume threshold (× avg)",      group = grpSD, minval = 0.5, step = 0.1)
showN    = input.int(1,      "Valid zones to show per side",  group = grpSD, minval = 1, maxval = 5)
freshOnly= input.bool(true,  "Fresh only (delete tested zones)", group = grpSD, tooltip = "Once price returns and touches a zone, it is removed.")
maxKeep  = input.int(12,     "Zones tracked per side",        group = grpSD, minval = 2, maxval = 30)

grpLQ    = "Liquidity"
liqLen   = input.int(14,     "Liquidity pivot lookback",      group = grpLQ, minval = 2)
showLiq  = input.bool(true,  "Show front-line liquidity",     group = grpLQ)

showDash = input.bool(true,  "Show delta dashboard",          group = "Filter")

cSup = input.color(color.orange,        "Supply",    group = "Style", inline = "c")
cDem = input.color(#009fd4,             "Demand",    group = "Style", inline = "c")
cLiq = input.color(color.new(#ffb300,0),"Liquidity", group = "Style")

volAvg   = ta.sma(volume, volLen)
extraVol = volume > volAvg * volMult
bearC    = close < open
bullC    = close > open
bullRun  = bullC and bullC[1] and (impCand < 3 or bullC[2])
bearRun  = bearC and bearC[1] and (impCand < 3 or bearC[2])

ph = ta.pivothigh(liqLen, liqLen)
pl = ta.pivotlow(liqLen, liqLen)

// -------------------- LIQUIDITY LEVELS (tracked, not drawn) ----------------
var float[] sslLvls = array.new_float()
var float[] bslLvls = array.new_float()
maxLiq = 40
if not na(pl)
    array.push(sslLvls, pl)
    if array.size(sslLvls) > maxLiq
        array.shift(sslLvls)
if not na(ph)
    array.push(bslLvls, ph)
    if array.size(bslLvls) > maxLiq
        array.shift(bslLvls)
if array.size(sslLvls) > 0
    for i = array.size(sslLvls) - 1 to 0
        if low < array.get(sslLvls, i)
            array.remove(sslLvls, i)
if array.size(bslLvls) > 0
    for i = array.size(bslLvls) - 1 to 0
        if high > array.get(bslLvls, i)
            array.remove(bslLvls, i)

frontSSL = float(na)
if array.size(sslLvls) > 0
    for i = 0 to array.size(sslLvls) - 1
        lvl = array.get(sslLvls, i)
        if lvl < close
            frontSSL := na(frontSSL) ? lvl : math.max(frontSSL, lvl)
frontBSL = float(na)
if array.size(bslLvls) > 0
    for i = 0 to array.size(bslLvls) - 1
        lvl = array.get(bslLvls, i)
        if lvl > close
            frontBSL := na(frontBSL) ? lvl : math.min(frontBSL, lvl)

var line  fsLn = na
var line  fbLn = na
var label fsLb = na
var label fbLb = na
line.delete(fsLn)
line.delete(fbLn)
label.delete(fsLb)
label.delete(fbLb)
fsLn := na
fbLn := na
fsLb := na
fbLb := na
if showLiq and not na(frontSSL)
    fsLn := line.new(bar_index - 60, frontSSL, bar_index + 8, frontSSL, color = cLiq, width = 2)
    fsLb := label.new(bar_index + 8, frontSSL, "liq", style = label.style_label_left, color = color.new(cLiq, 20), textcolor = color.black, size = size.tiny)
if showLiq and not na(frontBSL)
    fbLn := line.new(bar_index - 60, frontBSL, bar_index + 8, frontBSL, color = cLiq, width = 2)
    fbLb := label.new(bar_index + 8, frontBSL, "liq", style = label.style_label_left, color = color.new(cLiq, 20), textcolor = color.black, size = size.tiny)

// ----------------------------- S/D STATE -----------------------------------
var box[]   supBox = array.new_box()
var float[] supDel = array.new_float()
var bool[]  supHad = array.new_bool()
var bool[]  supLeft= array.new_bool()
var box[]   demBox = array.new_box()
var float[] demDel = array.new_float()
var bool[]  demHad = array.new_bool()
var bool[]  demLeft= array.new_bool()
var int cntBear = 0
var int cntBull = 0

overlaps(arr, lo, hi) =>
    res = false
    if array.size(arr) > 0
        for k = 0 to array.size(arr) - 1
            bx = array.get(arr, k)
            if lo < box.get_top(bx) and hi > box.get_bottom(bx)
                res := true
                break
    res

if showSD and bearRun and extraVol[1] and cntBear == 0
    delta = 0.0
    oi = -1
    for i = 0 to 5
        if bullC[i]
            oi := i
            break
        delta += bearC[i] ? -volume[i] : volume[i]
    if oi >= 0
        cntBear := 1
        zTop = high[oi]
        zBot = low[oi]
        if not overlaps(supBox, zBot, zTop)
            b = box.new(bar_index - oi, zTop, bar_index, zBot, bgcolor = na, border_color = na)
            box.set_extend(b, extend.right)
            array.push(supBox, b)
            array.push(supDel, delta)
            array.push(supHad, false)
            array.push(supLeft, false)
if cntBear >= 1
    cntBear += 1
if cntBear >= 15
    cntBear := 0

if showSD and bullRun and extraVol[1] and cntBull == 0
    delta = 0.0
    oi = -1
    for i = 0 to 5
        if bearC[i]
            oi := i
            break
        delta += bullC[i] ? volume[i] : -volume[i]
    if oi >= 0
        cntBull := 1
        zTop = high[oi]
        zBot = low[oi]
        if not overlaps(demBox, zBot, zTop)
            b = box.new(bar_index - oi, zTop, bar_index, zBot, bgcolor = na, border_color = na)
            box.set_extend(b, extend.right)
            array.push(demBox, b)
            array.push(demDel, delta)
            array.push(demHad, false)
            array.push(demLeft, false)
if cntBull >= 1
    cntBull += 1
if cntBull >= 15
    cntBull := 0

// ---------- PASS A: mitigation + freshness delete + latch had/left ---------
inDemand = false
inSupply = false

if array.size(demBox) > 0
    for idx = array.size(demBox) - 1 to 0
        b = array.get(demBox, idx)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        leftNow = array.get(demLeft, idx) or low > top
        array.set(demLeft, idx, leftNow)
        if not na(frontSSL) and frontSSL > top
            array.set(demHad, idx, true)
        broke  = close < bot
        tested = freshOnly and leftNow and low <= top
        if broke or tested
            if tested
                inDemand := true
            box.delete(b)
            array.remove(demBox, idx)
            array.remove(demDel, idx)
            array.remove(demHad, idx)
            array.remove(demLeft, idx)

if array.size(supBox) > 0
    for idx = array.size(supBox) - 1 to 0
        b = array.get(supBox, idx)
        top = box.get_top(b)
        bot = box.get_bottom(b)
        leftNow = array.get(supLeft, idx) or high < bot
        array.set(supLeft, idx, leftNow)
        if not na(frontBSL) and frontBSL < bot
            array.set(supHad, idx, true)
        broke  = close > top
        tested = freshOnly and leftNow and high >= bot
        if broke or tested
            if tested
                inSupply := true
            box.delete(b)
            array.remove(supBox, idx)
            array.remove(supDel, idx)
            array.remove(supHad, idx)
            array.remove(supLeft, idx)

// ---------------- PASS B: colour only the nearest N valid ------------------
if array.size(demBox) > 0
    for idx = 0 to array.size(demBox) - 1
        b = array.get(demBox, idx)
        top = box.get_top(b)
        cand = array.get(demHad, idx) and top < close
        show = false
        if cand
            rank = 0
            for j = 0 to array.size(demBox) - 1
                if j != idx and array.get(demHad, j)
                    tj = box.get_top(array.get(demBox, j))
                    if tj < close and tj > top
                        rank += 1
            show := rank < showN
        if show
            armed = na(frontSSL) or frontSSL <= top
            box.set_bgcolor(b, color.new(cDem, armed ? 80 : 90))
            box.set_border_color(b, cDem)
            box.set_text(b, armed ? "Demand ✓" : "Demand")
            box.set_text_color(b, color.new(cDem, 0))
            box.set_text_size(b, size.tiny)
            box.set_text_halign(b, text.align_left)
        else
            box.set_bgcolor(b, na)
            box.set_border_color(b, na)
            box.set_text(b, "")
if array.size(demBox) > maxKeep
    box.delete(array.shift(demBox))
    array.shift(demDel)
    array.shift(demHad)
    array.shift(demLeft)

if array.size(supBox) > 0
    for idx = 0 to array.size(supBox) - 1
        b = array.get(supBox, idx)
        bot = box.get_bottom(b)
        cand = array.get(supHad, idx) and bot > close
        show = false
        if cand
            rank = 0
            for j = 0 to array.size(supBox) - 1
                if j != idx and array.get(supHad, j)
                    bj = box.get_bottom(array.get(supBox, j))
                    if bj > close and bj < bot
                        rank += 1
            show := rank < showN
        if show
            armed = na(frontBSL) or frontBSL >= bot
            box.set_bgcolor(b, color.new(cSup, armed ? 80 : 90))
            box.set_border_color(b, cSup)
            box.set_text(b, armed ? "Supply ✓" : "Supply")
            box.set_text_color(b, color.new(cSup, 0))
            box.set_text_size(b, size.tiny)
            box.set_text_halign(b, text.align_left)
        else
            box.set_bgcolor(b, na)
            box.set_border_color(b, na)
            box.set_text(b, "")
if array.size(supBox) > maxKeep
    box.delete(array.shift(supBox))
    array.shift(supDel)
    array.shift(supHad)
    array.shift(supLeft)

// ------------------------------ DASHBOARD ----------------------------------
var table dash = table.new(position.bottom_right, 2, 2, chart.bg_color)
if showDash and barstate.islast
    dash.cell(0, 0, "Supply Σ", text_halign = text.align_left, text_color = cSup, text_size = size.small)
    dash.cell(0, 1, "Demand Σ", text_halign = text.align_left, text_color = cDem, text_size = size.small)
    dash.cell(1, 0, array.size(supDel) > 0 ? str.tostring(math.abs(array.sum(supDel)), format.volume) : "0", text_color = cSup, text_size = size.small)
    dash.cell(1, 1, array.size(demDel) > 0 ? str.tostring(math.abs(array.sum(demDel)), format.volume) : "0", text_color = cDem, text_size = size.small)

// ------------------------------- ALERTS ------------------------------------
alertcondition(inDemand, "Demand tested", "Price tested the fresh valid demand")
alertcondition(inSupply, "Supply tested", "Price tested the fresh valid supply")
````
