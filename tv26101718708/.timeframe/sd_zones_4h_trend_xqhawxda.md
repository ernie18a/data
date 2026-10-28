# S&D Zones + 4H Trend

- url: https://www.tradingview.com/script/xQHAwxdA-S-D-Zones-4H-Trend/
- type: indicator
- pine_id: PUB;26e9dc057ddd415380a70afc1841d1fe
- version: 1.0

## Description

supply demand for mutlitime frame and identifying 4 hour trend

## Source Code

````pine

//@version=6
indicator("S&D Zones + 4H Trend", overlay=true, max_boxes_count=100, max_labels_count=200)

// ── INPUTS ──────────────────────────────────────────────
var g1 = "4H Trend"
swingLen     = input.int(10,  "Pivot Lookback (4H bars)", group=g1, minval=3, maxval=20)
emaLen       = input.int(50,  "EMA Length",               group=g1)

var g2 = "Zone Detection"
zoneTF       = input.timeframe("30", "Zone Timeframe",    group=g2)
atrLen       = input.int(14,   "ATR Length",              group=g2)
impulseMult  = input.float(1.5,"Min Impulse (x ATR)",     group=g2, step=0.1, minval=0.5)
obLookback   = input.int(5,    "OB Lookback Candles",     group=g2, minval=1, maxval=10)
maxZones     = input.int(5,    "Max Zones per Side",      group=g2, minval=1, maxval=15)
showMisalign = input.bool(true,"Show Misaligned Zones",   group=g2)
showBroken   = input.bool(true,"Show Broken Zones",       group=g2)

var g3 = "Display"
demandCol  = input.color(color.new(#00c853, 80), "Demand Color", group=g3)
supplyCol  = input.color(color.new(#d50000, 80), "Supply Color", group=g3)
dimAlpha   = input.int(93, "Misaligned Transparency", group=g3, minval=50, maxval=95)
showEMA    = input.bool(true, "Show 4H EMA on Chart", group=g3)

// ── 4H TREND ────────────────────────────────────────────
[h4c, h4e] = request.security(syminfo.tickerid, "240", [close, ta.ema(close, emaLen)], lookahead=barmerge.lookahead_off)
h4ph = request.security(syminfo.tickerid, "240", ta.pivothigh(high, swingLen, swingLen), lookahead=barmerge.lookahead_off)
h4pl = request.security(syminfo.tickerid, "240", ta.pivotlow(low, swingLen, swingLen),  lookahead=barmerge.lookahead_off)

var float sh1 = na, var float sh2 = na
var float sl1 = na, var float sl2 = na

if not na(h4ph)
    sh2 := sh1
    sh1 := h4ph
if not na(h4pl)
    sl2 := sl1
    sl1 := h4pl

bullStruct = not na(sh1) and not na(sh2) and not na(sl1) and not na(sl2) and sh1 > sh2 and sl1 > sl2
bearStruct = not na(sh1) and not na(sh2) and not na(sl1) and not na(sl2) and sh1 < sh2 and sl1 < sl2
bullTrend  = bullStruct and h4c > h4e
bearTrend  = bearStruct and h4c < h4e

plot(showEMA ? h4e : na, "4H EMA", color=color.new(color.orange, 20), linewidth=2)

var table tbl = table.new(position.top_right, 1, 3, border_width=1)
trendTxt  = bullTrend ? "4H  BULLISH" : bearTrend ? "4H  BEARISH" : "4H  NEUTRAL"
trendBg   = bullTrend ? color.new(color.green, 20) : bearTrend ? color.new(color.red, 20) : color.new(color.gray, 30)
structTxt = bullTrend ? "HH + HL  |  EMA OK" : bearTrend ? "LH + LL  |  EMA OK" : bullStruct ? "HH + HL  |  EMA X" : bearStruct ? "LH + LL  |  EMA X" : "No clear structure"
table.cell(tbl, 0, 0, trendTxt,  text_color=color.white, bgcolor=trendBg,                     text_size=size.normal)
table.cell(tbl, 0, 1, structTxt, text_color=color.silver, bgcolor=color.new(color.black, 60), text_size=size.small)
table.cell(tbl, 0, 2, "Zones: " + zoneTF + "m TF", text_color=color.silver, bgcolor=color.new(color.black, 70), text_size=size.tiny)

// ── HTF ZONE DATA ────────────────────────────────────────
[htf_o, htf_c] = request.security(syminfo.tickerid, zoneTF, [open, close], lookahead=barmerge.lookahead_off)
htf_atr        = request.security(syminfo.tickerid, zoneTF, ta.atr(atrLen),  lookahead=barmerge.lookahead_off)

// Buffer confirmed HTF bars (newest at index 0)
var float[] buf_o   = array.new_float()
var float[] buf_c   = array.new_float()
var float[] buf_atr = array.new_float()

newHTFBar = ta.change(htf_c) != 0 or barstate.isfirst

if newHTFBar
    array.unshift(buf_o,   htf_o)
    array.unshift(buf_c,   htf_c)
    array.unshift(buf_atr, htf_atr)
    while array.size(buf_o) > obLookback + 3
        array.pop(buf_o)
        array.pop(buf_c)
        array.pop(buf_atr)

// ── ZONE ARRAYS ──────────────────────────────────────────
var box[]   dBoxes   = array.new_box()
var label[] dLabels  = array.new_label()
var int[]   dTests   = array.new_int()
var float[] dImpulse = array.new_float()
var bool[]  dInside  = array.new_bool()
var bool[]  dBroken  = array.new_bool()

var box[]   sBoxes   = array.new_box()
var label[] sLabels  = array.new_label()
var int[]   sTests   = array.new_int()
var float[] sImpulse = array.new_float()
var bool[]  sInside  = array.new_bool()
var bool[]  sBroken  = array.new_bool()

// ── HELPERS ──────────────────────────────────────────────
f_score(tests, impulse) =>
    s = 0
    s += impulse > 2.5 ? 2 : impulse > 1.5 ? 1 : 0
    s += tests == 0 ? 1 : 0
    s

f_stars(tests, impulse) =>
    s = f_score(tests, impulse)
    s >= 3 ? "★★★ Strong" : s == 2 ? "★★☆ Moderate" : "★☆☆ Weak"

f_starColor(tests, impulse) =>
    s = f_score(tests, impulse)
    s >= 3 ? color.white : s == 2 ? color.yellow : color.gray

f_overlaps(boxes, newH, newL) =>
    overlaps = false
    n = array.size(boxes)
    if n > 0
        for i = 0 to n - 1
            existH = box.get_top(array.get(boxes, i))
            existL = box.get_bottom(array.get(boxes, i))
            if newH >= existL and newL <= existH
                overlaps := true
    overlaps

// ── HTF ZONE DETECTION (runs on each new HTF bar) ────────
if newHTFBar and array.size(buf_c) >= 2
    bufSize    = array.size(buf_c)
    // Latest confirmed HTF bar = index 0
    b0_c   = array.get(buf_c,   0)
    b0_o   = array.get(buf_o,   0)
    b0_atr = array.get(buf_atr, 0)
    b0_body = math.abs(b0_c - b0_o)

    htfBull = b0_c > b0_o and b0_body > impulseMult * b0_atr
    htfBear = b0_c < b0_o and b0_body > impulseMult * b0_atr
    ratio   = b0_body / b0_atr

    // Demand OB: last bearish/doji in lookback bars before this impulse bull
    if htfBull
        obH = float(na), obL = float(na), found = false
        maxLook = math.min(obLookback, bufSize - 1)
        if maxLook >= 1
            for i = 1 to maxLook
                if not found
                    pc = array.get(buf_c, i)
                    po = array.get(buf_o, i)
                    pa = array.get(buf_atr, i)
                    if pc < po or math.abs(pc - po) < 0.3 * pa
                        obH   := math.max(po, pc)
                        obL   := math.min(po, pc)
                        found := true
        if found and not f_overlaps(dBoxes, obH, obL)
            aligned = bullTrend
            bCol    = aligned ? demandCol : color.new(demandCol, dimAlpha)
            bBorder = aligned ? color.new(color.green, 20) : color.new(color.green, 70)
            bWidth  = aligned ? 2 : 1
            if showMisalign or aligned
                b   = box.new(bar_index - 1, obH, bar_index + 100, obL, border_color=bBorder, bgcolor=bCol, border_width=bWidth)
                lbl = label.new(bar_index + 2, obH, zoneTF + "m DEMAND\n" + f_stars(0, ratio), color=color.new(color.green, 50), textcolor=f_starColor(0, ratio), style=label.style_label_lower_right, size=size.small)
                array.push(dBoxes, b), array.push(dLabels, lbl), array.push(dTests, 0)
                array.push(dImpulse, ratio), array.push(dInside, false), array.push(dBroken, false)
                if array.size(dBoxes) > maxZones * 2
                    box.delete(array.shift(dBoxes)), label.delete(array.shift(dLabels))
                    array.shift(dTests), array.shift(dImpulse), array.shift(dInside), array.shift(dBroken)

    // Supply OB: last bullish/doji in lookback bars before this impulse bear
    if htfBear
        obH = float(na), obL = float(na), found = false
        maxLook = math.min(obLookback, bufSize - 1)
        if maxLook >= 1
            for i = 1 to maxLook
                if not found
                    pc = array.get(buf_c, i)
                    po = array.get(buf_o, i)
                    pa = array.get(buf_atr, i)
                    if pc > po or math.abs(pc - po) < 0.3 * pa
                        obH   := math.max(po, pc)
                        obL   := math.min(po, pc)
                        found := true
        if found and not f_overlaps(sBoxes, obH, obL)
            aligned = bearTrend
            bCol    = aligned ? supplyCol : color.new(supplyCol, dimAlpha)
            bBorder = aligned ? color.new(color.red, 20) : color.new(color.red, 70)
            bWidth  = aligned ? 2 : 1
            if showMisalign or aligned
                b   = box.new(bar_index - 1, obH, bar_index + 100, obL, border_color=bBorder, bgcolor=bCol, border_width=bWidth)
                lbl = label.new(bar_index + 2, obH, zoneTF + "m SUPPLY\n" + f_stars(0, ratio), color=color.new(color.red, 50), textcolor=f_starColor(0, ratio), style=label.style_label_upper_right, size=size.small)
                array.push(sBoxes, b), array.push(sLabels, lbl), array.push(sTests, 0)
                array.push(sImpulse, ratio), array.push(sInside, false), array.push(sBroken, false)
                if array.size(sBoxes) > maxZones * 2
                    box.delete(array.shift(sBoxes)), label.delete(array.shift(sLabels))
                    array.shift(sTests), array.shift(sImpulse), array.shift(sInside), array.shift(sBroken)

// ── UPDATE ZONES (every bar) ─────────────────────────────
if barstate.isconfirmed
    dSize = array.size(dBoxes)
    if dSize > 0
        for i = dSize - 1 to 0
            b      = array.get(dBoxes, i)
            zH     = box.get_top(b)
            zL     = box.get_bottom(b)
            lbl    = array.get(dLabels, i)
            tests  = array.get(dTests, i)
            ratio  = array.get(dImpulse, i)
            wasIn  = array.get(dInside, i)
            broken = array.get(dBroken, i)
            isIn   = low <= zH and high >= zL
            box.set_right(b, bar_index + 100)
            label.set_x(lbl, bar_index + 2)
            if not broken
                if isIn and not wasIn
                    tests += 1
                    array.set(dTests, i, tests), array.set(dInside, i, true)
                    label.set_text(lbl, zoneTF + "m DEMAND\n" + f_stars(tests, ratio) + "\n" + str.tostring(tests) + "x tested")
                    label.set_textcolor(lbl, f_starColor(tests, ratio))
                else if not isIn
                    array.set(dInside, i, false)
                if close < zL
                    array.set(dBroken, i, true)
                    if showBroken
                        box.set_bgcolor(b, color.new(color.gray, 92))
                        box.set_border_color(b, color.new(color.gray, 60))
                        box.set_border_width(b, 1)
                        label.set_text(lbl, "BROKEN D  " + str.tostring(tests) + "x")
                        label.set_textcolor(lbl, color.new(color.gray, 40))
                        label.set_color(lbl, color.new(color.gray, 80))
                    else
                        box.delete(b), label.delete(lbl)
                        array.remove(dBoxes, i), array.remove(dLabels, i), array.remove(dTests, i)
                        array.remove(dImpulse, i), array.remove(dInside, i), array.remove(dBroken, i)

    sSize = array.size(sBoxes)
    if sSize > 0
        for i = sSize - 1 to 0
            b      = array.get(sBoxes, i)
            zH     = box.get_top(b)
            zL     = box.get_bottom(b)
            lbl    = array.get(sLabels, i)
            tests  = array.get(sTests, i)
            ratio  = array.get(sImpulse, i)
            wasIn  = array.get(sInside, i)
            broken = array.get(sBroken, i)
            isIn   = low <= zH and high >= zL
            box.set_right(b, bar_index + 100)
            label.set_x(lbl, bar_index + 2)
            if not broken
                if isIn and not wasIn
                    tests += 1
                    array.set(sTests, i, tests), array.set(sInside, i, true)
                    label.set_text(lbl, zoneTF + "m SUPPLY\n" + f_stars(tests, ratio) + "\n" + str.tostring(tests) + "x tested")
                    label.set_textcolor(lbl, f_starColor(tests, ratio))
                else if not isIn
                    array.set(sInside, i, false)
                if close > zH
                    array.set(sBroken, i, true)
                    if showBroken
                        box.set_bgcolor(b, color.new(color.gray, 92))
                        box.set_border_color(b, color.new(color.gray, 60))
                        box.set_border_width(b, 1)
                        label.set_text(lbl, "BROKEN S  " + str.tostring(tests) + "x")
                        label.set_textcolor(lbl, color.new(color.gray, 40))
                        label.set_color(lbl, color.new(color.gray, 80))
                    else
                        box.delete(b), label.delete(lbl)
                        array.remove(sBoxes, i), array.remove(sLabels, i), array.remove(sTests, i)
                        array.remove(sImpulse, i), array.remove(sInside, i), array.remove(sBroken, i)
````
