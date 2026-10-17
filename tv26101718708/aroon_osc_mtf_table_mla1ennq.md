# Aroon Osc MTF Table

- url: https://www.tradingview.com/script/MLA1enNq-Aroon-Osc-MTF-Table/
- type: indicator
- pine_id: PUB;50628ff090f347568f27adaa42fc833a
- version: 6.0

## Description

Disclaimer : I will not responsible for any mistake, losses, etc. handle with care at your own risk.

## Source Code

````pine
//@version=6
indicator("Aroon Osc MTF Table", "Aroon Osc Table", overlay = true)

import TradingView/ta/11 as TVta

lengthInput      = input.int(14, "Length", minval = 1)
htfMode          = input.string("Live HTF", "HTF Mode", options = ["Live HTF", "Confirmed HTF"])
textSizeInp      = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"])
topPadding       = input.int(2, "Top padding rows", minval = 0, maxval = 10)
tolerancePercent = input.float(1.0, "Pointer tolerance % (0 = minimal epsilon)", minval = 0.0, step = 0.1)

tf1 = input.timeframe("30",  "TF 1")
tf2 = input.timeframe("60",  "TF 2")
tf3 = input.timeframe("180", "TF 3")
tf4 = input.timeframe("300", "TF 4")
tf5 = input.timeframe("480", "TF 5")
tf6 = input.timeframe("720", "TF 6")
tf7 = input.timeframe("D",   "TF 7")

f_size(_size) =>
    if _size == "Tiny"
        size.tiny
    else if _size == "Normal"
        size.normal
    else
        size.small

f_tfLabel(_tf) =>
    if _tf == "30"
        "30m"
    else if _tf == "60"
        "1H"
    else if _tf == "180"
        "3H"
    else if _tf == "300"
        "5H"
    else if _tf == "480"
        "8H"
    else if _tf == "720"
        "12H"
    else if _tf == "D"
        "1D"
    else
        _tf

f_osc() =>
    [aroonUp, aroonDn] = TVta.aroon(lengthInput)
    aroonUp - aroonDn

f_norm(_v) =>
    na(_v) ? na : math.round(_v * 10.0) / 10.0

f_tolAbs(_base, _tolPct) =>
    _tolPct <= 0 ? 0.000001 : math.max(math.abs(_base), 0.000001) * _tolPct / 100.0

f_bias(_v) =>
    if na(_v)
        "NA"
    else if _v > 0
        "Bull"
    else if _v < 0
        "Bear"
    else
        "Neutral"

f_pointer(_curr, _prev, _tolPct) =>
    if na(_curr) or na(_prev)
        "NA"
    else
        diffVal = _curr - _prev
        tolVal  = f_tolAbs(_prev, _tolPct)
        if math.abs(diffVal) <= tolVal
            "→ Flat"
        else if diffVal > 0
            "↗ Up"
        else
            "↘ Down"

f_pattern(_v0, _v1, _v2, _tolPct) =>
    if na(_v0) or na(_v1) or na(_v2)
        "NA"
    else
        d01   = _v0 - _v1
        d12   = _v1 - _v2
        tol01 = f_tolAbs(_v1, _tolPct)
        tol12 = f_tolAbs(_v2, _tolPct)
        eq01  = math.abs(d01) <= tol01
        eq12  = math.abs(d12) <= tol12

        if eq01 and eq12
            "Flat"
        else if not eq12 and d12 > 0 and not eq01 and d01 > 0
            "Rising"
        else if not eq12 and d12 < 0 and not eq01 and d01 < 0
            "Falling"
        else if eq01
            _v0 >= 0 ? "Flat Top" : "Flat Bottom"
        else if not eq12 and d12 < 0 and not eq01 and d01 > 0
            "Mid Bottom"
        else if not eq12 and d12 > 0 and not eq01 and d01 < 0
            "Mid Top"
        else
            _v0 >= 0 ? "Flat Top" : "Flat Bottom"

f_bg(_v) =>
    if na(_v)
        color.new(color.gray, 85)
    else if _v >= 50
        color.new(color.green, 0)
    else if _v > 0
        color.new(color.green, 65)
    else if _v <= -50
        color.new(color.red, 0)
    else if _v < 0
        color.new(color.red, 65)
    else
        color.new(color.gray, 70)

f_fmt(_v) =>
    na(_v) ? "NA" : str.tostring(_v, "#.0")

f_htfBar(_tf, _barsBack) =>
    float out = na
    if htfMode == "Live HTF"
        out := request.security(syminfo.tickerid, _tf, f_osc()[_barsBack], barmerge.gaps_off, barmerge.lookahead_off)
    else
        out := request.security(syminfo.tickerid, _tf, f_osc()[_barsBack + 1], barmerge.gaps_off, barmerge.lookahead_on)
    f_norm(out)

// Direct HTF-context sampling for current / prev / prev2
v01 = f_htfBar(tf1, 0)
v11 = f_htfBar(tf1, 1)
v21 = f_htfBar(tf1, 2)

v02 = f_htfBar(tf2, 0)
v12 = f_htfBar(tf2, 1)
v22 = f_htfBar(tf2, 2)

v03 = f_htfBar(tf3, 0)
v13 = f_htfBar(tf3, 1)
v23 = f_htfBar(tf3, 2)

v04 = f_htfBar(tf4, 0)
v14 = f_htfBar(tf4, 1)
v24 = f_htfBar(tf4, 2)

v05 = f_htfBar(tf5, 0)
v15 = f_htfBar(tf5, 1)
v25 = f_htfBar(tf5, 2)

v06 = f_htfBar(tf6, 0)
v16 = f_htfBar(tf6, 1)
v26 = f_htfBar(tf6, 2)

v07 = f_htfBar(tf7, 0)
v17 = f_htfBar(tf7, 1)
v27 = f_htfBar(tf7, 2)

label1 = f_tfLabel(tf1)
label2 = f_tfLabel(tf2)
label3 = f_tfLabel(tf3)
label4 = f_tfLabel(tf4)
label5 = f_tfLabel(tf5)
label6 = f_tfLabel(tf6)
label7 = f_tfLabel(tf7)

bias1 = f_bias(v01)
bias2 = f_bias(v02)
bias3 = f_bias(v03)
bias4 = f_bias(v04)
bias5 = f_bias(v05)
bias6 = f_bias(v06)
bias7 = f_bias(v07)

pointer1 = f_pointer(v01, v11, tolerancePercent)
pointer2 = f_pointer(v02, v12, tolerancePercent)
pointer3 = f_pointer(v03, v13, tolerancePercent)
pointer4 = f_pointer(v04, v14, tolerancePercent)
pointer5 = f_pointer(v05, v15, tolerancePercent)
pointer6 = f_pointer(v06, v16, tolerancePercent)
pointer7 = f_pointer(v07, v17, tolerancePercent)

pattern1 = f_pattern(v01, v11, v21, tolerancePercent)
pattern2 = f_pattern(v02, v12, v22, tolerancePercent)
pattern3 = f_pattern(v03, v13, v23, tolerancePercent)
pattern4 = f_pattern(v04, v14, v24, tolerancePercent)
pattern5 = f_pattern(v05, v15, v25, tolerancePercent)
pattern6 = f_pattern(v06, v16, v26, tolerancePercent)
pattern7 = f_pattern(v07, v17, v27, tolerancePercent)

bg1 = f_bg(v01)
bg2 = f_bg(v02)
bg3 = f_bg(v03)
bg4 = f_bg(v04)
bg5 = f_bg(v05)
bg6 = f_bg(v06)
bg7 = f_bg(v07)

var table tb = table.new(position.top_right, 5, 20, border_width = 1)

if barstate.islast
    sz = f_size(textSizeInp)
    tc = color.white
    clearBg = color.new(color.black, 100)
    hdrBg = color.rgb(30, 30, 30)
    hdrTx = color.white

    table.clear(tb, 0, 0, 4, 19)

    for r = 0 to topPadding - 1
        table.cell(tb, 0, r, "", bgcolor = clearBg, text_size = sz)
        table.cell(tb, 1, r, "", bgcolor = clearBg, text_size = sz)
        table.cell(tb, 2, r, "", bgcolor = clearBg, text_size = sz)
        table.cell(tb, 3, r, "", bgcolor = clearBg, text_size = sz)
        table.cell(tb, 4, r, "", bgcolor = clearBg, text_size = sz)

    headerRow = topPadding

    table.cell(tb, 0, headerRow, "TF",      text_color = hdrTx, bgcolor = hdrBg, text_size = sz)
    table.cell(tb, 1, headerRow, "Value",   text_color = hdrTx, bgcolor = hdrBg, text_size = sz)
    table.cell(tb, 2, headerRow, "Bias",    text_color = hdrTx, bgcolor = hdrBg, text_size = sz)
    table.cell(tb, 3, headerRow, "Pointer", text_color = hdrTx, bgcolor = hdrBg, text_size = sz)
    table.cell(tb, 4, headerRow, "Pattern", text_color = hdrTx, bgcolor = hdrBg, text_size = sz)

    table.cell(tb, 0, headerRow + 1, label1,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 1, f_fmt(v01), text_color = tc, bgcolor = bg1, text_size = sz)
    table.cell(tb, 2, headerRow + 1, bias1,      text_color = tc, bgcolor = bg1, text_size = sz)
    table.cell(tb, 3, headerRow + 1, pointer1,   text_color = tc, bgcolor = bg1, text_size = sz)
    table.cell(tb, 4, headerRow + 1, pattern1,   text_color = tc, bgcolor = bg1, text_size = sz)

    table.cell(tb, 0, headerRow + 2, label2,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 2, f_fmt(v02), text_color = tc, bgcolor = bg2, text_size = sz)
    table.cell(tb, 2, headerRow + 2, bias2,      text_color = tc, bgcolor = bg2, text_size = sz)
    table.cell(tb, 3, headerRow + 2, pointer2,   text_color = tc, bgcolor = bg2, text_size = sz)
    table.cell(tb, 4, headerRow + 2, pattern2,   text_color = tc, bgcolor = bg2, text_size = sz)

    table.cell(tb, 0, headerRow + 3, label3,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 3, f_fmt(v03), text_color = tc, bgcolor = bg3, text_size = sz)
    table.cell(tb, 2, headerRow + 3, bias3,      text_color = tc, bgcolor = bg3, text_size = sz)
    table.cell(tb, 3, headerRow + 3, pointer3,   text_color = tc, bgcolor = bg3, text_size = sz)
    table.cell(tb, 4, headerRow + 3, pattern3,   text_color = tc, bgcolor = bg3, text_size = sz)

    table.cell(tb, 0, headerRow + 4, label4,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 4, f_fmt(v04), text_color = tc, bgcolor = bg4, text_size = sz)
    table.cell(tb, 2, headerRow + 4, bias4,      text_color = tc, bgcolor = bg4, text_size = sz)
    table.cell(tb, 3, headerRow + 4, pointer4,   text_color = tc, bgcolor = bg4, text_size = sz)
    table.cell(tb, 4, headerRow + 4, pattern4,   text_color = tc, bgcolor = bg4, text_size = sz)

    table.cell(tb, 0, headerRow + 5, label5,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 5, f_fmt(v05), text_color = tc, bgcolor = bg5, text_size = sz)
    table.cell(tb, 2, headerRow + 5, bias5,      text_color = tc, bgcolor = bg5, text_size = sz)
    table.cell(tb, 3, headerRow + 5, pointer5,   text_color = tc, bgcolor = bg5, text_size = sz)
    table.cell(tb, 4, headerRow + 5, pattern5,   text_color = tc, bgcolor = bg5, text_size = sz)

    table.cell(tb, 0, headerRow + 6, label6,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 6, f_fmt(v06), text_color = tc, bgcolor = bg6, text_size = sz)
    table.cell(tb, 2, headerRow + 6, bias6,      text_color = tc, bgcolor = bg6, text_size = sz)
    table.cell(tb, 3, headerRow + 6, pointer6,   text_color = tc, bgcolor = bg6, text_size = sz)
    table.cell(tb, 4, headerRow + 6, pattern6,   text_color = tc, bgcolor = bg6, text_size = sz)

    table.cell(tb, 0, headerRow + 7, label7,     text_color = tc, bgcolor = color.new(color.black, 0), text_size = sz)
    table.cell(tb, 1, headerRow + 7, f_fmt(v07), text_color = tc, bgcolor = bg7, text_size = sz)
    table.cell(tb, 2, headerRow + 7, bias7,      text_color = tc, bgcolor = bg7, text_size = sz)
    table.cell(tb, 3, headerRow + 7, pointer7,   text_color = tc, bgcolor = bg7, text_size = sz)
    table.cell(tb, 4, headerRow + 7, pattern7,   text_color = tc, bgcolor = bg7, text_size = sz)
````
