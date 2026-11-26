# HTF Supply & Demand Zones

- url: https://www.tradingview.com/script/2Tf4O8P2-HTF-Supply-Demand-Zones/
- type: indicator
- pine_id: PUB;59ae518a16944549889695a2fefa10c8
- version: 1.0

## Description

HTF Supply & Demand Zones
Displays higher-timeframe (default 15m) supply and demand zones directly on your lower timeframe execution chart (e.g. 3m). Ideal for traders who identify zones on the 15m and execute on the 3m.
How zones are identified:

Demand zone (green): body of the last bearish candle before a strong bullish impulse move on the HTF
Supply zone (red): body of the last bullish candle before a strong bearish impulse move on the HTF

Features:

No repainting — only uses confirmed, closed HTF bars
ATR-based impulse filter (adjustable)
Zones fade when tested, disappear when broken
Configurable lookback, zone count, colors, and extend length
Built-in alerts for when price enters a zone
Works on any symbol and any timeframe combination

## Source Code

````pine
// =============================================================================
//  HTF SUPPLY & DEMAND ZONES
//
//  Shows higher-timeframe (default 15m) supply & demand zones on any lower
//  timeframe chart — e.g. use your 3m execution chart while seeing the 15m zones.
//
//  Zone logic is identical to Wiko S/D:
//    DEMAND zone = body of last BEARISH candle before a strong bullish impulse
//    SUPPLY zone = body of last BULLISH candle before a strong bearish impulse
//
//  Extra vs same-TF version:
//    • Zones are detected on the HTF, drawn on your current LTF chart
//    • No repainting: only confirmed, closed HTF bars are used
// =============================================================================
//@version=6
indicator('HTF Supply & Demand Zones', 'HTF S&D', overlay = true, max_boxes_count = 500, max_labels_count = 300)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
string GRP_DET = '▸ Detection'
string GRP_DISP = '▸ Display'

htfTF = input.timeframe('15', 'Higher Timeframe', tooltip = 'Zones are identified on this timeframe and drawn on your current chart.', group = GRP_DET)
atrLen = input.int(14, 'ATR Length', group = GRP_DET, minval = 2)
impulseMult = input.float(1.5, 'Impulse body ≥ N × ATR', group = GRP_DET, minval = 0.5, step = 0.1, tooltip = 'Higher = fewer, stronger zones.')
maxLookback = input.int(5, 'Max bars back for base candle', group = GRP_DET, minval = 1, maxval = 10)
useBodyOnly = input.bool(true, 'Zone uses body only (not wick)', group = GRP_DET)
breakOnClose = input.bool(true, 'Break requires close beyond zone', group = GRP_DET)

maxZones = input.int(12, 'Max active zones per side', group = GRP_DISP, minval = 2, maxval = 30)
extendBars = input.int(50, 'Extend zone right N bars', group = GRP_DISP, minval = 5, maxval = 500)
fadeTested = input.bool(true, 'Fade zones once tested', group = GRP_DISP)
hideBroken = input.bool(true, 'Hide broken zones', group = GRP_DISP)
showLabels = input.bool(true, 'Show FRESH / TESTED labels', group = GRP_DISP)

colDemandFresh = input.color(color.new(#26a69a, 70), 'Demand FRESH', group = GRP_DISP, inline = 'd')
colDemandTested = input.color(color.new(#26a69a, 88), 'Demand TESTED', group = GRP_DISP, inline = 'd')
colSupplyFresh = input.color(color.new(#ef5350, 70), 'Supply FRESH', group = GRP_DISP, inline = 's')
colSupplyTested = input.color(color.new(#ef5350, 88), 'Supply TESTED', group = GRP_DISP, inline = 's')
colBorderD = input.color(#26a69a, 'Demand border', group = GRP_DISP, inline = 'b')
colBorderS = input.color(#ef5350, 'Supply border', group = GRP_DISP, inline = 'b')

// ─────────────────────────────────────────────────────────────────────────────
//  HTF DATA — last CLOSED bar (no repainting)
// ─────────────────────────────────────────────────────────────────────────────
[htfO, htfH, htfL, htfC, htfT] = request.security(syminfo.tickerid, htfTF, [open[1], high[1], low[1], close[1], time[1]], lookahead = barmerge.lookahead_on)

htfATR = request.security(syminfo.tickerid, htfTF, ta.atr(atrLen)[1], lookahead = barmerge.lookahead_on)

newHTFBar = ta.change(htfT) > 0

// ─────────────────────────────────────────────────────────────────────────────
//  ROLLING HTF HISTORY
// ─────────────────────────────────────────────────────────────────────────────
var array<float> hO = array.new_float()
var array<float> hH = array.new_float()
var array<float> hL = array.new_float()
var array<float> hC = array.new_float()
var array<float> hATR = array.new_float()

if newHTFBar
    array.push(hO, htfO)
    array.push(hH, htfH)
    array.push(hL, htfL)
    array.push(hC, htfC)
    array.push(hATR, htfATR)
    while array.size(hO) > maxLookback + 3
        array.shift(hO)
        array.shift(hH)
        array.shift(hL)
        array.shift(hC)
        array.shift(hATR)

// ─────────────────────────────────────────────────────────────────────────────
//  ZONE STORAGE
// ─────────────────────────────────────────────────────────────────────────────
var array<float> dTop = array.new_float()
var array<float> dBot = array.new_float()
var array<bool> dTest = array.new_bool()
var array<bool> dBroken = array.new_bool()
var array<box> dBox = array.new_box()
var array<label> dLbl = array.new_label()

var array<float> sTop = array.new_float()
var array<float> sBot = array.new_float()
var array<bool> sTest = array.new_bool()
var array<bool> sBroken = array.new_bool()
var array<box> sBox = array.new_box()
var array<label> sLbl = array.new_label()

// ─────────────────────────────────────────────────────────────────────────────
//  ZONE DETECTION
// ─────────────────────────────────────────────────────────────────────────────
if newHTFBar
    int sz = array.size(hO)

    if sz >= 2
        int last = sz - 1
        float iO = array.get(hO, last)
        float iC = array.get(hC, last)
        float iATR = array.get(hATR, last)
        float iBody = math.abs(iC - iO)
        bool imp = iBody >= impulseMult * iATR

        if imp
            // ── DEMAND: bullish impulse ───────────────────────────────────
            if iC > iO
                float zTop = na
                float zBot = na
                for k = 1 to math.min(maxLookback, sz - 1) by 1
                    int idx = last - k
                    float bO = array.get(hO, idx)
                    float bH = array.get(hH, idx)
                    float bL = array.get(hL, idx)
                    float bC = array.get(hC, idx)
                    if bC < bO
                        zTop := useBodyOnly ? math.max(bO, bC) : bH
                        zBot := useBodyOnly ? math.min(bO, bC) : bL
                        break

                if not na(zTop) and zTop - zBot > syminfo.mintick
                    string lbl = 'Demand · ' + htfTF + ' FRESH'
                    b = box.new(bar_index, zTop, bar_index + extendBars, zBot, bgcolor = colDemandFresh, border_color = color.new(colBorderD, 50), border_width = 1)
                    l = showLabels ? label.new(bar_index, zTop, lbl, style = label.style_label_lower_right, color = color.new(colBorderD, 70), textcolor = color.new(colBorderD, 0), size = size.tiny, yloc = yloc.price) : na
                    array.push(dTop, zTop)
                    array.push(dBot, zBot)
                    array.push(dTest, false)
                    array.push(dBroken, false)
                    array.push(dBox, b)
                    array.push(dLbl, l)
                    while array.size(dTop) > maxZones
                        box.delete(array.shift(dBox))
                        label lOld = array.shift(dLbl)
                        if not na(lOld)
                            label.delete(lOld)
                        array.shift(dTop)
                        array.shift(dBot)
                        array.shift(dTest)
                        array.shift(dBroken)

            // ── SUPPLY: bearish impulse ───────────────────────────────────
            if iC < iO
                float zTop = na
                float zBot = na
                for k = 1 to math.min(maxLookback, sz - 1) by 1
                    int idx = last - k
                    float bO = array.get(hO, idx)
                    float bH = array.get(hH, idx)
                    float bL = array.get(hL, idx)
                    float bC = array.get(hC, idx)
                    if bC > bO
                        zTop := useBodyOnly ? math.max(bO, bC) : bH
                        zBot := useBodyOnly ? math.min(bO, bC) : bL
                        break

                if not na(zTop) and zTop - zBot > syminfo.mintick
                    string lbl = 'Supply · ' + htfTF + ' FRESH'
                    b = box.new(bar_index, zTop, bar_index + extendBars, zBot, bgcolor = colSupplyFresh, border_color = color.new(colBorderS, 50), border_width = 1)
                    l = showLabels ? label.new(bar_index, zTop, lbl, style = label.style_label_upper_right, color = color.new(colBorderS, 70), textcolor = color.new(colBorderS, 0), size = size.tiny, yloc = yloc.price) : na
                    array.push(sTop, zTop)
                    array.push(sBot, zBot)
                    array.push(sTest, false)
                    array.push(sBroken, false)
                    array.push(sBox, b)
                    array.push(sLbl, l)
                    while array.size(sTop) > maxZones
                        box.delete(array.shift(sBox))
                        label lOld = array.shift(sLbl)
                        if not na(lOld)
                            label.delete(lOld)
                        array.shift(sTop)
                        array.shift(sBot)
                        array.shift(sTest)
                        array.shift(sBroken)

// ─────────────────────────────────────────────────────────────────────────────
//  UPDATE — extend, test, break
// ─────────────────────────────────────────────────────────────────────────────
int dSz = array.size(dBox)
if dSz > 0
    for i = 0 to dSz - 1 by 1
        if not array.get(dBroken, i)
            box b = array.get(dBox, i)
            float zt = array.get(dTop, i)
            float zb = array.get(dBot, i)
            bool tst = array.get(dTest, i)
            if not na(b)
                box.set_right(b, bar_index + extendBars)
            if not tst and low <= zt and high >= zb
                array.set(dTest, i, true)
                if fadeTested and not na(b)
                    box.set_bgcolor(b, colDemandTested)
                label l = array.get(dLbl, i)
                if not na(l)
                    label.set_text(l, 'Demand · ' + htfTF + ' TESTED')
            bool broke = breakOnClose ? close < zb : low < zb
            if broke
                array.set(dBroken, i, true)
                if not na(b)
                    if hideBroken
                        box.delete(b)
                    else
                        box.set_right(b, bar_index)
                        box.set_bgcolor(b, color.new(color.gray, 92))
                        box.set_border_color(b, color.new(color.gray, 60))
                label l = array.get(dLbl, i)
                if not na(l) and hideBroken
                    label.delete(l)

int sSz = array.size(sBox)
if sSz > 0
    for i = 0 to sSz - 1 by 1
        if not array.get(sBroken, i)
            box b = array.get(sBox, i)
            float zt = array.get(sTop, i)
            float zb = array.get(sBot, i)
            bool tst = array.get(sTest, i)
            if not na(b)
                box.set_right(b, bar_index + extendBars)
            if not tst and high >= zb and low <= zt
                array.set(sTest, i, true)
                if fadeTested and not na(b)
                    box.set_bgcolor(b, colSupplyTested)
                label l = array.get(sLbl, i)
                if not na(l)
                    label.set_text(l, 'Supply · ' + htfTF + ' TESTED')
            bool broke = breakOnClose ? close > zt : high > zt
            if broke
                array.set(sBroken, i, true)
                if not na(b)
                    if hideBroken
                        box.delete(b)
                    else
                        box.set_right(b, bar_index)
                        box.set_bgcolor(b, color.new(color.gray, 92))
                        box.set_border_color(b, color.new(color.gray, 60))
                label l = array.get(sLbl, i)
                if not na(l) and hideBroken
                    label.delete(l)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────────
bool inDem = false
bool inSup = false

if array.size(dBox) > 0
    for i = 0 to array.size(dBox) - 1 by 1
        if not array.get(dBroken, i)
            if low <= array.get(dTop, i) and high >= array.get(dBot, i)
                inDem := true
                inDem

if array.size(sBox) > 0
    for i = 0 to array.size(sBox) - 1 by 1
        if not array.get(sBroken, i)
            if high >= array.get(sBot, i) and low <= array.get(sTop, i)
                inSup := true
                inSup

alertcondition(inDem, 'Price in HTF Demand Zone', '✅ Price entered an HTF Demand Zone')
alertcondition(inSup, 'Price in HTF Supply Zone', '⚠️ Price entered an HTF Supply Zone')
````
