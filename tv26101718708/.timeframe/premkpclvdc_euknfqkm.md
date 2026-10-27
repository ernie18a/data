# PremK|P&C/LVDC

- url: https://www.tradingview.com/script/eUKNfqkm-PremK-P-C-LVDC/
- type: indicator
- pine_id: PUB;e645c1cc1f984f899e4956d47bf3e3e3
- version: 1.0

## Description

Put and call options are derivative contracts used in stock or index trading to speculate on price direction or hedge against losses. A call option gives you the right to buy an asset at a set price, used when you expect prices to rise. A put option gives you the right to sell an asset at a set price, used when you expect prices to fall.

## Source Code

````pine
// ============================================================
// PremK | PUT & CALL VP Levels
// ============================================================
//@version=6
indicator("PremK|P&C/LVDC", overlay=true,
     max_bars_back=1000, max_lines_count=500,
     max_labels_count=500, max_boxes_count=500)

length = input.int(7, "How many previous days?", minval=1, maxval=200)
       
    // Detect first candle of the day
isNewDay = ta.change(time("D"))

// Store opening candle values
var float oHigh = na
var float oLow  = na
var float oClose = na
var float oOpen = na

if bool (isNewDay)
    oHigh  := high
    oLow   := low
    oClose := close
    oOpen := open

ph = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
pl = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
pc = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
po = request.security(syminfo.tickerid, "D", open[1], lookahead=barmerge.lookahead_on)

avgClose = ta.sma(pc, length)

plot(ph,title="ph", color=color.rgb(41, 5, 249), linewidth=2, style=plot.style_linebr)
plot(pl, title="pl", color=color.rgb(41, 5, 249), linewidth=2, style=plot.style_linebr)
plot(pc, title="pc", color=color.rgb(253, 5, 59), linewidth=2, style=plot.style_linebr)

// Inputs for option details
expiry = input.string("260602", title="NIFTY:Expiry (yymmdd)")
callstrike = input.int(24000, title="NIFTY:Call Strike Price", minval=1)
putstrike = input.int(24000, title="NIFTY:Put Strike Price", minval=1)

// Construct option symbols
call_sym = "NSE:NIFTY" + expiry + "C" + str.tostring(callstrike)
put_sym =  "NSE:NIFTY" + expiry + "P" + str.tostring(putstrike)

// Previous day values for underlying (Nifty)

prev_close = request.security(syminfo.tickerid, "D", close[1])


// Using request.security to get the 'open' from the daily ('D') timeframe

call_close = request.security(call_sym, "D", close[1], lookahead=barmerge.lookahead_on)


put_close  = request.security(put_sym, "D", close[1], lookahead=barmerge.lookahead_on)

// Option values

prev_close_call = request.security(call_sym, "D", close)

prev_close_put = request.security(put_sym, "D", close)

avg_cpc = (prev_close_call + prev_close_put) / 2


// Plot the averages as horizontal lines

plot(avg_cpc, title="CPC", color=color.rgb(240, 236, 6), linewidth=2,style=plot.style_linebr)

// ══════════════════════════════════════════════════════════════
//Bar Color Based on Above/Below EMA...

emaLength = input.int(5, minval=1, maxval=300, title="EMA Length")
emaLength1 = input.int(16, minval=1, maxval=300, title="EMA Length1")
showEMA   = input.bool(true, title="Show EMA")

usedEma = ta.ema(close, emaLength)
usedEma1 = ta.ema(close, emaLength1)
emaUpColor   = hlc3 >= usedEma
emaDownColor = hlc3 < usedEma
emaUpColor1   = hlc3 >= usedEma1
emaDownColor1 = hlc3 < usedEma1

col = emaUpColor ? color.rgb(27, 212, 123) : color.red
col1 = emaUpColor1 ? color.rgb(27, 212, 123) : color.red

barcolor(emaUpColor ? color.rgb(27, 212, 123) : color.red)

plot(showEMA ? usedEma : na,title="EMA",linewidth=2,color=col)
plot(showEMA ? usedEma1 : na,title="EMA16",linewidth=2,color=col)
// ══════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════
i_rows     = input.int   (5,   "Profile Rows",               minval=5,  maxval=100, group="Volume Profile")
i_histW    = input.int   (7,   "Histogram Max Width (bars)",  minval=3,  maxval=100, group="Volume Profile")
i_showHist = input.bool  (true, "Show Histogram",              group="Volume Profile")

i_putLen   = input.int   (150,  "PUT Lookback Bars",           minval=10, group="PUT Levels")
i_putVA    = input.float (95.0, "PUT Value Area %",            minval=50, maxval=99, group="PUT Levels")
i_showPut  = input.bool  (true, "Show PUT Levels",             group="PUT Levels")
i_putVAH   = input.color (color.rgb(16, 207, 9),            "PUT VAH Color", group="PUT Levels")
i_putPOC   = input.color (color.rgb(250, 3, 217),          "PUT POC Color", group="PUT Levels")
i_putVAL   = input.color (color.rgb(218, 45, 54),          "PUT VAL Color", group="PUT Levels")

i_callLen  = input.int   (70,   "CALL Lookback Bars",          minval=10, group="CALL Levels")
i_callVA   = input.float (95.0, "CALL Value Area %",           minval=50, maxval=99, group="CALL Levels")
i_showCall = input.bool  (true, "Show CALL Levels",            group="CALL Levels")
i_callVAH  = input.color (color.rgb(253, 3, 16),         "CALL VAH Color",group="CALL Levels")
i_callPOC  = input.color (color.rgb(94, 255, 0, 34),       "CALL POC Color",group="CALL Levels")
i_callVAL  = input.color (color.teal,         "CALL VAL Color",group="CALL Levels")

i_extend   = input.bool  (true,    "Extend Lines Right", group="Style")
i_lblSize  = input.string("small", "Label Size",         group="Style",
             options=["tiny","small","normal","large","huge"])

// ══════════════════════════════════════════════════════════════
// LABEL SIZE
// ══════════════════════════════════════════════════════════════
f_lsize() =>
    switch i_lblSize
        "tiny"   => size.tiny
        "small"  => size.small
        "large"  => size.large
        "huge"   => size.huge
        =>          size.normal

// ══════════════════════════════════════════════════════════════
// PERSISTENT OBJECTS
// ══════════════════════════════════════════════════════════════
var float vah_p = na, var float poc_p = na, var float val_p = na
var float vah_c = na, var float poc_c = na, var float val_c = na

var line  l_pvah = na, var line  l_ppoc = na, var line  l_pval = na
var line  l_cvah = na, var line  l_cpoc = na, var line  l_cval = na
var label b_pvah = na, var label b_ppoc = na, var label b_pval = na
var label b_cvah = na, var label b_cpoc = na, var label b_cval = na

var box[] bxs_put  = array.new_box()
var box[] bxs_call = array.new_box()

// ══════════════════════════════════════════════════════════════
// MAIN — last bar only
// ══════════════════════════════════════════════════════════════
if barstate.islast

    // ─────────────────────────────────────────────────────────
    // ① PUT VOLUME PROFILE
    // ─────────────────────────────────────────────────────────
    float p_ph = high, float p_pl = low
    for i = 1 to i_putLen - 1
        p_ph := math.max(p_ph, high[i])
        p_pl := math.min(p_pl, low [i])
    float p_rng = p_ph - p_pl

    float p_vah = na, float p_poc = na, float p_val = na
    int   p_pocRow = 0, int p_upRow = 0, int p_dnRow = 0

    if p_rng > 0
        float p_step = p_rng / i_rows
        float[] p_vol = array.new_float(i_rows, 0.0)

        for i = 0 to i_putLen - 1
            float bh = high  [i]
            float bl = low   [i]
            float bv = volume[i]
            float br = bh - bl
            if br <= 0.0
                br := p_step
            for r = 0 to i_rows - 1
                float rl = p_pl + r * p_step
                float rh = rl + p_step
                float ol = math.max(bl, rl)
                float oh = math.min(bh, rh)
                if oh > ol
                    array.set(p_vol, r, array.get(p_vol, r) + bv * (oh - ol) / br)

        float p_maxV = array.max(p_vol)
        for r = 0 to i_rows - 1
            if array.get(p_vol, r) >= p_maxV
                p_pocRow := r

        float p_vaVol = array.get(p_vol, p_pocRow)
        float p_tgt   = array.sum(p_vol) * i_putVA / 100.0
        p_upRow := p_pocRow
        p_dnRow := p_pocRow
        while p_vaVol < p_tgt and (p_upRow < i_rows - 1 or p_dnRow > 0)
            float upA = p_upRow < i_rows - 1 ? array.get(p_vol, p_upRow + 1) : 0.0
            float dnA = p_dnRow > 0          ? array.get(p_vol, p_dnRow - 1) : 0.0
            if upA >= dnA
                if p_upRow < i_rows - 1
                    p_upRow += 1
                    p_vaVol += array.get(p_vol, p_upRow)
            else
                if p_dnRow > 0
                    p_dnRow -= 1
                    p_vaVol += array.get(p_vol, p_dnRow)

        p_poc := p_pl + p_pocRow * p_step + p_step * 0.5
        p_vah := p_pl + p_upRow  * p_step + p_step
        p_val := p_pl + p_dnRow  * p_step

        // Draw PUT histogram
        for bx in bxs_put
            box.delete(bx)
        array.clear(bxs_put)

        if i_showHist
            int p_histLeft = bar_index - i_putLen + 1
            for r = 0 to i_rows - 1
                float rv  = array.get(p_vol, r)
                float rl  = p_pl + r * p_step
                float rh  = rl + p_step
                int   bw  = math.max(1, math.round(rv / p_maxV * i_histW))
                bool  inVA   = r >= p_dnRow and r <= p_upRow
                int   transp = r == p_pocRow ? 0 : inVA ? 40 : 70
                array.push(bxs_put, box.new(
                     left         = p_histLeft,
                     top          = rh,
                     right        = p_histLeft + bw,
                     bottom       = rl,
                     bgcolor      = color.new(color.red, transp),
                     border_color = color.new(color.red, 80),
                     border_width = 1))

        vah_p := p_vah
        poc_p := p_poc
        val_p := p_val

    // ─────────────────────────────────────────────────────────
    // ② CALL VOLUME PROFILE
    // ─────────────────────────────────────────────────────────
    float c_ph = high, float c_pl = low
    for i = 1 to i_callLen - 1
        c_ph := math.max(c_ph, high[i])
        c_pl := math.min(c_pl, low [i])
    float c_rng = c_ph - c_pl

    float c_vah = na, float c_poc = na, float c_val = na
    int   c_pocRow = 0, int c_upRow = 0, int c_dnRow = 0

    if c_rng > 0
        float c_step = c_rng / i_rows
        float[] c_vol = array.new_float(i_rows, 0.0)

        for i = 0 to i_callLen - 1
            float bh = high  [i]
            float bl = low   [i]
            float bv = volume[i]
            float br = bh - bl
            if br <= 0.0
                br := c_step
            for r = 0 to i_rows - 1
                float rl = c_pl + r * c_step
                float rh = rl + c_step
                float ol = math.max(bl, rl)
                float oh = math.min(bh, rh)
                if oh > ol
                    array.set(c_vol, r, array.get(c_vol, r) + bv * (oh - ol) / br)

        float c_maxV = array.max(c_vol)
        for r = 0 to i_rows - 1
            if array.get(c_vol, r) >= c_maxV
                c_pocRow := r

        float c_vaVol = array.get(c_vol, c_pocRow)
        float c_tgt   = array.sum(c_vol) * i_callVA / 100.0
        c_upRow := c_pocRow
        c_dnRow := c_pocRow
        while c_vaVol < c_tgt and (c_upRow < i_rows - 1 or c_dnRow > 0)
            float upA = c_upRow < i_rows - 1 ? array.get(c_vol, c_upRow + 1) : 0.0
            float dnA = c_dnRow > 0          ? array.get(c_vol, c_dnRow - 1) : 0.0
            if upA >= dnA
                if c_upRow < i_rows - 1
                    c_upRow += 1
                    c_vaVol += array.get(c_vol, c_upRow)
            else
                if c_dnRow > 0
                    c_dnRow -= 1
                    c_vaVol += array.get(c_vol, c_dnRow)

        c_poc := c_pl + c_pocRow * c_step + c_step * 0.5
        c_vah := c_pl + c_upRow  * c_step + c_step
        c_val := c_pl + c_dnRow  * c_step

        // Draw CALL histogram
        for bx in bxs_call
            box.delete(bx)
        array.clear(bxs_call)

        if i_showHist
            int c_histLeft = bar_index - i_callLen + 1
            for r = 0 to i_rows - 1
                float rv  = array.get(c_vol, r)
                float rl  = c_pl + r * c_step
                float rh  = rl + c_step
                int   bw  = math.max(1, math.round(rv / c_maxV * i_histW))
                bool  inVA   = r >= c_dnRow and r <= c_upRow
                int   transp = r == c_pocRow ? 0 : inVA ? 40 : 70
                array.push(bxs_call, box.new(
                     left         = c_histLeft,
                     top          = rh,
                     right        = c_histLeft + bw,
                     bottom       = rl,
                     bgcolor      = color.new(color.teal, transp),
                     border_color = color.new(color.teal, 80),
                     border_width = 1))

        vah_c := c_vah
        poc_c := c_poc
        val_c := c_val

    // ─────────────────────────────────────────────────────────
    // ③ LINES & LABELS
    // ─────────────────────────────────────────────────────────
    if not na(l_pvah)
        line.delete(l_pvah)
    if not na(l_ppoc)
        line.delete(l_ppoc)
    if not na(l_pval)
        line.delete(l_pval)
    if not na(l_cvah)
        line.delete(l_cvah)
    if not na(l_cpoc)
        line.delete(l_cpoc)
    if not na(l_cval)
        line.delete(l_cval)
    if not na(b_pvah)
        label.delete(b_pvah)
    if not na(b_ppoc)
        label.delete(b_ppoc)
    if not na(b_pval)
        label.delete(b_pval)
    if not na(b_cvah)
        label.delete(b_cvah)
    if not na(b_cpoc)
        label.delete(b_cpoc)
    if not na(b_cval)
        label.delete(b_cval)

    int pLL  = bar_index - i_putLen  + 1
    int cLL  = bar_index - i_callLen + 1
    int lR   = bar_index + 10
    // Labels: right edge of each histogram
    int pLX  = pLL + i_histW + 1
    int cLX  = cLL + i_histW + 1

    if i_showPut and not na(vah_p)
        l_pvah := line.new(pLL, vah_p, lR, vah_p, color=i_putVAH, width=2,
             extend=i_extend ? extend.right : extend.none)
        b_pvah := label.new(pLX, vah_p,
             "PUT VAH  DN SELLER EXIT : " + str.tostring(vah_p, "#.00"),
             color=i_putVAH, textcolor=color.white,
             style=label.style_label_right, size=f_lsize())

        l_ppoc := line.new(pLL, poc_p, lR, poc_p, color=i_putPOC, width=2,
             style=line.style_dashed,
             extend=i_extend ? extend.right : extend.none)
        b_ppoc := label.new(pLX, poc_p,
             "PUT POC : " + str.tostring(poc_p, "#.00"),
             color=i_putPOC, textcolor=color.white,
             style=label.style_label_right, size=f_lsize())

        l_pval := line.new(pLL, val_p, lR, val_p, color=i_putVAL, width=2,
             extend=i_extend ? extend.right : extend.none)
        b_pval := label.new(pLX, val_p,
             "PUT VAL  BUYER EXIT : " + str.tostring(val_p, "#.00"),
             color=i_putVAL, textcolor=color.white,
             style=label.style_label_right, size=f_lsize())

    if i_showCall and not na(vah_c)
        l_cvah := line.new(cLL, vah_c, lR, vah_c, color=i_callVAH, width=2,
             extend=i_extend ? extend.right : extend.none)
        b_cvah := label.new(cLX, vah_c,
             "CALL VAH  BUYER EXIT : " + str.tostring(vah_c, "#.00"),
             color=i_callVAH, textcolor=color.white,
             style=label.style_label_right, size=f_lsize())

        l_cpoc := line.new(cLL, poc_c, lR, poc_c, color=i_callPOC, width=2,
             style=line.style_dashed,
             extend=i_extend ? extend.right : extend.none)
        b_cpoc := label.new(cLX, poc_c,
             "CALL POC : " + str.tostring(poc_c, "#.00"),
             color=i_callPOC, textcolor=color.black,
             style=label.style_label_right, size=f_lsize())

        l_cval := line.new(cLL, val_c, lR, val_c, color=i_callVAL, width=2,
             extend=i_extend ? extend.right : extend.none)
        b_cval := label.new(cLX, val_c,
             "CALL VAL  DN SELLER EXIT : " + str.tostring(val_c, "#.00"),
             color=i_callVAL, textcolor=color.white,
             style=label.style_label_right, size=f_lsize())

// ══════════════════════════════════════════════════════════════
// DATA WINDOW
// ══════════════════════════════════════════════════════════════
plot(vah_p, "PUT VAH",  color=i_putVAH,  display=display.data_window)
plot(poc_p, "PUT POC",  color=i_putPOC,  display=display.data_window)
plot(val_p, "PUT VAL",  color=i_putVAL,  display=display.data_window)
plot(vah_c, "CALL VAH", color=i_callVAH, display=display.data_window)
plot(poc_c, "CALL POC", color=i_callPOC, display=display.data_window)
plot(val_c, "CALL VAL", color=i_callVAL, display=display.data_window)

//-----------End of Script-----------
// INPUT GROUPS (for cleaner settings UI)
// ------------------------------------------
grpStrike = "Strike Settings"
grpLine   = "Line Settings"
grpLabel  = "Label Settings"


// ------------------------------------------
// STRIKE SETTINGS
// ------------------------------------------
step       = input.float(50.0, 'Step (points)', minval = 1, step = 50, group = grpStrike)
levelsSide = input.int(50, 'Levels per side', minval = 1, maxval = 150, group = grpStrike)
strikeMode = input.string( 'Strike Price Range', 'Strike Mode', options = ['Strike Price Range', 'Exact Strike Price'], group = grpStrike)

// ------------------------------------------
// LINE SETTINGS
// ------------------------------------------
lineWidth    = input.int(1, 'Line width', minval = 1, maxval = 5, group = grpLine)
lineColor    = input.color(color.new(#d505fa, 40), 'Line color', group = grpLine)
lineStyleOpt = input.string('Dotted', 'Line style', options = ['Solid', 'Dashed', 'Dotted'], group = grpLine)
extOpt       = input.string('Both', 'Extend', options = ['Both', 'Right', 'Left', 'None'], group = grpLine)

// ------------------------------------------
// LABEL SETTINGS
// ------------------------------------------
showLabels   = input.bool(true, 'Show labels', group = grpLabel)
barsRight    = input.int(10, 'Labels Distance', minval = 1, group = grpLabel)
labelSizeOpt = input.string('Normal', 'Label size', options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = grpLabel)

// NEW: Label style controls
labelTextColor = input.color(color.white, 'Label text color', group = grpLabel)
labelBgColor   = input.color(color.new(color.black, 60), 'Label background color', group = grpLabel)

// ------------------------------------------
// ENUM HELPERS
// ------------------------------------------
f_getExtend(_opt) =>
    _opt == 'Both' ? extend.both : _opt == 'Right' ? extend.right : _opt == 'Left' ? extend.left : extend.none

f_getLineStyle(_opt) =>
    _opt == 'Solid' ? line.style_solid : _opt == 'Dashed' ? line.style_dashed : line.style_dotted

f_getLabelSize(_opt) =>
    _opt == 'Tiny' ? size.tiny :
     _opt == 'Small' ? size.small :
     _opt == 'Large' ? size.large :
     _opt == 'Huge' ? size.huge :
     size.normal

extEnum       = f_getExtend(extOpt)
lineStyleEnum = f_getLineStyle(lineStyleOpt)
labelSizeEnum = f_getLabelSize(labelSizeOpt)

// ------------------------------------------
// CORE MATH
// ------------------------------------------
base = strikeMode == 'Strike Price Range' ? (math.round(close / step) * step + step / 2.0) : (math.round(close / step) * step + step)
total = levelsSide * 2 + 1

// ------------------------------------------
// STORAGE ARRAYS
// ------------------------------------------
var array<line>  lines  = array.new_line()
var array<label> labels = array.new_label()

// ------------------------------------------
// STYLE APPLY (lines)
// ------------------------------------------
f_styleLine(l) =>
    line.set_color(l, lineColor)
    line.set_width(l, lineWidth)
    line.set_extend(l, extEnum)
    line.set_style(l, lineStyleEnum)

// ------------------------------------------
// LABEL HELPERS
// ------------------------------------------
f_hideLabel(lb) =>
    label.set_text(lb, "")
    label.set_y(lb, na)

// Common label properties applied every update so they react to input changes
f_applyLabelCommon(lb, _x) =>
    label.set_x(lb, _x)
    label.set_size(lb, labelSizeEnum)
    label.set_textcolor(lb, labelTextColor)   // NEW
    label.set_color(lb, labelBgColor)         // NEW (background)

// ------------------------------------------
// CLEAR / REBUILD
// ------------------------------------------
f_clearAll() =>
    lnSz = array.size(lines)
    if lnSz > 0
        for i = 0 to lnSz - 1
            l = array.get(lines, i)
            if not na(l)
                line.delete(l)

    lbSz = array.size(labels)
    if lbSz > 0
        for j = 0 to lbSz - 1
            lb = array.get(labels, j)
            if not na(lb)
                label.delete(lb)

    array.clear(lines)
    array.clear(labels)

f_rebuild() =>
    f_clearAll()

    for idx = -levelsSide to levelsSide
        y = base + idx * step

        l = line.new(bar_index - 1, y, bar_index, y)
        f_styleLine(l)
        array.push(lines, l)

        // Create label with defaults; dynamic colors are applied on update.
        lb = label.new(
            na, na, "",
            style     = label.style_label_center,
            textcolor = labelTextColor,  // NEW
            color     = labelBgColor,    // NEW
            size      = labelSizeEnum)
        array.push(labels, lb)


// ------------------------------------------
// INIT
// ------------------------------------------
if barstate.isfirst or array.size(lines) != total or array.size(labels) != total
    f_rebuild()

// ------------------------------------------
// UPDATE (LAST BAR ONLY)
// ------------------------------------------
if barstate.islast
    lnSz = array.size(lines)
    lbSz = array.size(labels)

    if lnSz != total or lbSz != total
        f_rebuild()
    else
        lastIdx = last_bar_index
        futureX = lastIdx + barsRight

        for i = 0 to total - 1
            idx = i - levelsSide
            y   = base + idx * step

            // Update line
            l = array.get(lines, i)
            line.set_xy1(l, bar_index - 1, y)
            line.set_xy2(l, bar_index,     y)
            f_styleLine(l)

            // Update label
            lb = array.get(labels, i)

            if not showLabels
                f_hideLabel(lb)
            else
                f_applyLabelCommon(lb, futureX)

                if strikeMode == 'Strike Price Range'
                    // Label centered BETWEEN this line and next line
                    if i < total - 1
                        nextIdx = (i + 1) - levelsSide
                        nextY   = base + nextIdx * step
                        midY    = (y + nextY) / 2.0

                        label.set_y(lb, midY)
                        label.set_text(lb, str.tostring(midY))
                    else
                        // No next line => hide last label
                        f_hideLabel(lb)
                else
                    // Exact strike: label ON the line
                    label.set_y(lb, y)
                    label.set_text(lb, str.tostring(y))
// ------------------------------------------
import UkutaLabs/UkutaLabs_General_library/7 as ulgl

//-----------------
//USER VARIABLES
//-----------------
int MaxDisplay = input.int(defval=3, title="Max Display", group="Configuration")
int ExtensionPercentage = input.int(defval=20, title="Extension Percentage", group="Configuration")


bool ShowLabels = input.bool(defval=true, title="Show Labels", group="Label Settings")
string LabelSize = input.string(defval="Tiny", title="Label Size", options=["Tiny", "Small", "Medium", "Large"], group="Label Settings")
string TextHAlign = input.string(defval="Right", title="Text HAlignment", options=["Left", "Center", "Right"], group="Label Settings")
string TextVAlign = input.string(defval="Top", title="Text VAlignment", options=["Top", "Bottom"], group="Label Settings")


bool DisplayCurrentTimeFrame = input.bool(defval=true, title="Display (On/Off)", group="Current Timeframe")
color ColorCurrent = input.color(defval=color.blue, title="Color", group="Current Timeframe")
bool DisplayHigherTimeFrame5 = input.bool(defval=false, title="Display (On/Off)", group="5 Minute Timeframe")
color Color5 = input.color(defval=color.blue, title="Color", group="5 Minute Timeframe")
bool DisplayHigherTimeFrame15 = input.bool(defval=false, title="Display (On/Off)", group="15 Minute Timeframe")
color Color15 = input.color(defval=color.blue, title="Color", group="15 Minute Timeframe")
bool DisplayHigherTimeFrame30 = input.bool(defval=false, title="Display (On/Off)", group="30 Minute Timeframe")
color Color30 = input.color(defval=color.blue, title="Color", group="30 Minute Timeframe")
bool DisplayHigherTimeFrame60 = input.bool(defval=false, title="Display (On/Off)", group="60 Minute Timeframe")
color Color60 = input.color(defval=color.blue, title="Color", group="60 Minute Timeframe")
bool DisplayHigherTimeFrame120 = input.bool(defval=false, title="Display (On/Off)", group="120 Minute Timeframe")
color Color120 = input.color(defval=color.blue, title="Color", group="120 Minute Timeframe")
bool DisplayHigherTimeFrame240 = input.bool(defval=false, title="Display (On/Off)", group="240 Minute Timeframe")
color Color240 = input.color(defval=color.blue, title="Color", group="240 Minute Timeframe")
bool DisplayHigherTimeFrameDaily = input.bool(defval=false, title="Display (On/Off)", group="Daily Timeframe")
color ColorDaily = input.color(defval=color.blue, title="Color", group="Daily Timeframe")

//-----------------
//CLASSES
//-----------------
type BarStructure
    int left
    float top
    int right
    float bottom
    float barOpen
    float barClose

type CandleRange
    bool current
    box body
    box initialbody
    line highLine
    line medLine
    line lowLine
    box lbHigh
    box lbLow
    line extHighLine
    line extLowLine
    box lbExtHigh
    box lbExtLow

method extendRange(CandleRange this) =>
    if not na(this)
        this.body.set_right(bar_index)
        this.highLine.set_x2(bar_index)
        this.medLine.set_x2(bar_index)
        this.lowLine.set_x2(bar_index)
        if(ExtensionPercentage > 0)
            this.extHighLine.set_x2(bar_index)
            this.extLowLine.set_x2(bar_index)
        if ShowLabels
            this.lbHigh.set_right(bar_index)
            this.lbLow.set_right(bar_index)
        if(ShowLabels and ExtensionPercentage > 0)
            this.lbExtHigh.set_right(bar_index)
            this.lbExtLow.set_right(bar_index)

method disqualify(CandleRange this) =>
    if not na(this)
        this.current := false

method deleteItem(CandleRange this) =>
    if not na(this)
        this.body.delete()
        this.initialbody.delete()
        this.highLine.delete()
        this.medLine.delete()
        this.lowLine.delete()
        if(ExtensionPercentage > 0)
            this.extHighLine.delete()
            this.extLowLine.delete()
        if ShowLabels
            this.lbHigh.delete()
            this.lbLow.delete()
        if(ShowLabels and ExtensionPercentage > 0)
            this.lbExtHigh.delete()
            this.lbExtLow.delete()
//-----------------
//Variables
//-----------------
//var float tfp = timeframe.isintraday and not timeframe.isseconds ? (str.tonumber(timeframe.period)) 
// : timeframe.isseconds ? (timeframe.period == "S" ? 1/60 : str.tonumber(str.substring(timeframe.period, 0, str.length(timeframe.period)-1))/60)
// : 0

var float tfp = ulgl.GetTimeFramePeriod()

var int b = 0

var barsCurrent = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var bars5 = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var bars15 = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var bars30 = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var bars60 = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var bars120 = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var bars240 = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))
var barsdaily = array.new<BarStructure> (3,BarStructure.new(bar_index,high,bar_index,high,open,close))

var rangeCurrent = array.new<CandleRange> (1, CandleRange.new(false))
var range5 = array.new<CandleRange> (1, CandleRange.new(false))
var range15 = array.new<CandleRange> (1, CandleRange.new(false))
var range30 = array.new<CandleRange> (1, CandleRange.new(false))
var range60 = array.new<CandleRange> (1, CandleRange.new(false))
var range120 = array.new<CandleRange> (1, CandleRange.new(false))
var range240 = array.new<CandleRange> (1, CandleRange.new(false))
var rangeDaily = array.new<CandleRange> (1, CandleRange.new(false))

//-----------------
//METHODS
//-----------------
newRange(array<CandleRange> currentRange, array<BarStructure> bars) => 
 (bars.get(2).barOpen < bars.get(2).barClose ? bars.get(2).barOpen > bars.get(0).bottom and bars.get(2).barClose < bars.get(0).top : bars.get(2).barOpen < bars.get(0).top and bars.get(2).barClose > bars.get(0).bottom)
 and (bars.get(1).barOpen < bars.get(1).barClose ? bars.get(1).barOpen > bars.get(0).bottom and bars.get(1).barClose < bars.get(0).top : bars.get(1).barOpen < bars.get(0).top and bars.get(2).barClose > bars.get(0).bottom)
 and not currentRange.get(currentRange.size()-1).current

withinRange(array<CandleRange> currentRange, array<BarStructure> bars) => 
    if currentRange.get(currentRange.size()-1).current and bars.get(2).barClose < currentRange.get(currentRange.size()-1).body.get_top() and bars.get(2).barClose > currentRange.get(currentRange.size()-1).body.get_bottom()
        currentRange.get(currentRange.size()-1).extendRange()
    if currentRange.get(currentRange.size()-1).current and (bars.get(2).barClose > currentRange.get(currentRange.size()-1).body.get_top() or bars.get(2).barClose < currentRange.get(currentRange.size()-1).body.get_bottom())
        currentRange.get(currentRange.size()-1).disqualify()

DrawRange(int BarsPerHigher, array<BarStructure> bars, array<CandleRange> currentRange, color rangeColor, string labelText) =>
    var CandleRange newCandleRange = na

    var BarStructure NewBarStructure = BarStructure.new(bar_index,high,bar_index,low,open,close) 
    NewBarStructure :=  BarsPerHigher==1 ? BarStructure.new(bar_index,high,bar_index,low,open,close) 
     : b%BarsPerHigher==0 ? BarStructure.new(left = bar_index[BarsPerHigher] < bars.get(bars.size()-1).right ? bars.get(bars.size()-1).right+1: bar_index[BarsPerHigher], top = ta.highest(BarsPerHigher)[1], right = bar_index[1], bottom = ta.lowest(BarsPerHigher)[1], barOpen = open[BarsPerHigher], barClose = close[1]) : NewBarStructure

    if b%BarsPerHigher == 0
        bars.shift()
        bars.push(NewBarStructure)
        
        if newRange(currentRange, bars)
            currentRange.push(CandleRange.new(
             current = true,
             body = box.new(left = bars.get(0).left, top = bars.get(0).top, right = bars.get(0).right, bottom = bars.get(0).bottom, bgcolor = color.new(rangeColor, 90), border_color = na),
             initialbody = box.new(left = bars.get(0).left, top = bars.get(0).top, right = bar_index , bottom = bars.get(0).bottom, bgcolor = color.new(rangeColor, 80), border_color = na),
             highLine = line.new(x1 = bars.get(0).left, y1 = bars.get(0).top, x2 = bar_index, y2 = bars.get(0).top, color = color.new(rangeColor, 0), style = ulgl.GetLineStyle("Solid")),
             medLine = line.new(x1 = bars.get(0).left, y1 = (bars.get(0).top + bars.get(0).bottom) / 2, x2 = bar_index, y2 = (bars.get(0).top + bars.get(0).bottom) / 2, color = color.new(rangeColor, 0), style = ulgl.GetLineStyle("Dashed")),
             lowLine = line.new(x1 = bars.get(0).left, y1 = bars.get(0).bottom, x2 = bar_index, y2 = bars.get(0).bottom, color = color.new(rangeColor, 0), style = ulgl.GetLineStyle("Solid")),
             extHighLine = ExtensionPercentage > 0 ? line.new(x1 = bars.get(0).left, y1 = bars.get(0).top + (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), x2 = bar_index, y2 = bars.get(0).top + (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), color = color.new(rangeColor, 0), style = ulgl.GetLineStyle("Dotted")) : na,
             extLowLine = ExtensionPercentage > 0 ? line.new(x1 = bars.get(0).left, y1 = bars.get(0).bottom - (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), x2 = bar_index, y2 = bars.get(0).bottom - (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), color = color.new(rangeColor, 0), style = ulgl.GetLineStyle("Dotted")) : na,
             
            lbHigh = ShowLabels ? box.new(left = bars.get(0).left, top = bars.get(0).top, right = bar_index, bottom = bars.get(0).top, bgcolor = color.new(rangeColor, 100), border_color = na, text = labelText + "(" + str.tostring(bars.get(0).top) + ")", text_valign = ulgl.GetVAlign(TextVAlign), text_halign = ulgl.GetHAlign(TextHAlign), text_color = color.new(rangeColor,0), text_size = ulgl.GetFontSize(LabelSize)) : na,
             lbLow = ShowLabels ? box.new(left = bars.get(0).left, top = bars.get(0).bottom, right = bar_index, bottom = bars.get(0).bottom, bgcolor = color.new(rangeColor, 100), border_color = na, text = "(" + str.tostring(bars.get(0).bottom) + ")", text_valign = ulgl.GetVAlign(TextVAlign), text_halign = ulgl.GetHAlign(TextHAlign), text_color = color.new(rangeColor,0), text_size = ulgl.GetFontSize(LabelSize)) : na,
             lbExtHigh = ShowLabels and ExtensionPercentage > 0 ? box.new(left = bars.get(0).left, top = bars.get(0).top + (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), right = bar_index, bottom = bars.get(0).top + (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), bgcolor = color.new(rangeColor, 100), border_color = na, text = "" + str.tostring(bars.get(0).top + (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100)) + " - (" + str.tostring(ExtensionPercentage) + "%)", text_valign = ulgl.GetVAlign(TextVAlign), text_halign = ulgl.GetHAlign(TextHAlign), text_color = color.new(rangeColor,0), text_size = ulgl.GetFontSize(LabelSize)) : na,
             lbExtLow = ShowLabels and ExtensionPercentage > 0 ? box.new(left = bars.get(0).left, top = bars.get(0).bottom - (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), right = bar_index, bottom = bars.get(0).bottom - (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100), bgcolor = color.new(rangeColor, 100), border_color = na, text = "" + str.tostring(bars.get(0).bottom - (bars.get(0).top-bars.get(0).bottom)*(ExtensionPercentage/100)) + " - (" + str.tostring(ExtensionPercentage) + "%)", text_valign = ulgl.GetVAlign(TextVAlign), text_halign = ulgl.GetHAlign(TextHAlign), text_color = color.new(rangeColor,0), text_size = ulgl.GetFontSize(LabelSize)) : na
             ))
        
        withinRange(currentRange, bars)

        if currentRange.size() > MaxDisplay
            currentRange.get(0).deleteItem()
            currentRange.shift()

//-----------------
//Function
//-----------------
if session.isfirstbar
    b := 0
if DisplayCurrentTimeFrame
    DrawRange(1, barsCurrent, rangeCurrent, ColorCurrent, "Current Timeframe")
if DisplayHigherTimeFrame5 and 5%tfp==0
    DrawRange(math.floor(5/tfp), bars5, range5, Color5, "5 Minute")
if DisplayHigherTimeFrame15 and 15%tfp==0
    DrawRange(math.floor(15/tfp), bars15, range15, Color15, "15 Minute")
if DisplayHigherTimeFrame30 and 30%tfp==0
    DrawRange(math.floor(30/tfp), bars30, range30, Color30, "30 Minute")
if DisplayHigherTimeFrame60 and 60%tfp==0
    DrawRange(math.floor(60/tfp), bars60, range60, Color60, "60 Minute")
if DisplayHigherTimeFrame120 and 120%tfp==0
    DrawRange(math.floor(120/tfp), bars120, range120, Color120, "120 Minute")
if DisplayHigherTimeFrame240 and 240%tfp==0
    DrawRange(math.floor(240/tfp), bars240, range240, Color240, "240 Minute")
if DisplayHigherTimeFrameDaily and 1380%tfp==0 and (tfp>=5 or tfp==0)
    DrawRange(math.floor(1380/tfp), barsdaily, rangeDaily, ColorDaily, "Daily")

b+=1                
//------------------------------------------------------------------------------

shorttitle='LVDC'
 , max_labels_count=500
 , overlay=true
 , n=bar_index

//------------------------------------------------------------------------------
// Settings
//-----------------------------------------------------------------------------{
tick   = input.string   ('LTF'     , 'Data from: ', options= [  'Ticks' ,   'LTF'   ] )
res    = input.timeframe( '1'                                                         , tooltip= "Data from: 'LTF'\nAuto: 'Disabled'"  )
auto   = input.bool     (   true   ,      ''      , inline='auto'                     )
mlt    = input.int      (   3000   ,  ' Auto   '  , inline='auto'                     , tooltip="current TF divided by x\n\nData from: 'LTF'\nAuto: 'Enabled'")
prem   = input.bool     (  false   ,  'Premium'   , tooltip=  'Premium Plan or higher')
colUp  = input.color    (#089981 ,  'Up     '   , inline='u', group='Intrabar Delta')
colUp_ = input.color    (#f23645 ,  'Up -     ' , inline='u', group='Intrabar Delta', tooltip= 'Up -\n-> bullish candle and - Delta' )
colDn  = input.color    (#f23645 ,  'Down'      , inline='d', group='Intrabar Delta')
colDn_ = input.color    (#089981 ,  'Down +'    , inline='d', group='Intrabar Delta', tooltip='Down +\n-> bearish candle and + Delta')
option = input.string   ('full bar',  'Display'   , options= ['half bar', 'full bar'] )
dot    = input.bool     (  false   ,                'Show Previous Max Volume Price'  )
showTab= input.bool     (   true   ,   'Show TF'              , group=     'Table'    )
tabCol = input.color  (#b2b5beaa , 'Text Color'             , group=     'Table'    )     
sizeT  = input.string   (size.tiny , 'Size Table'             , group=     'Table'
       , options =            [size.tiny, size.small, size.normal, size.large])
showD  = input.bool     (  false   ,'Show details',             group=    'Details'   ) 
INV    = color.new(na,na)
CFG    = chart.fg_color
isTick = tick =='Ticks'
isLTF  = tick =='LTF'

//-----------------------------------------------------------------------------}      
//UDT
//-----------------------------------------------------------------------------{
type bin 
    varip float p 
    varip float v

//-----------------------------------------------------------------------------}      
//Variables
//-----------------------------------------------------------------------------{
varip float volBl = na
varip float volBr = na
varip float volNt = na
varip bin   maxBl = bin.new(na, 0)
varip bin   maxBr = bin.new(na, 0)
varip float  vl   = na
varip float  cl   = na
varip float  dfP  = na
varip float  dfV  = na
varip float  TdfV = na
varip bool ticksAvailable = false

var table tab = na   

//-----------------------------------------------------------------------------}      
//Execution
//-----------------------------------------------------------------------------{
//Ticks
if isTick 
    if barstate.isnew 
        maxBl.v := 0, maxBr.v := 0
        cl     :=  open , dfP := 0             // "open" 
        vl     := volume, dfV := 0, TdfV  := 0 // "volume" at first tick
        volBl  :=  0  , volBr := 0, volNt := 0 // dfV
    else
        dfP   := close  - cl
        dfV   := volume - vl

        switch 
            dfP > 0 => 
                volBl += dfV, TdfV += dfV 
                if dfV > maxBl.v 
                    maxBl.v := dfV, maxBl.p := close

            dfP < 0 => 
                volBr += dfV, TdfV += dfV 
                if dfV > maxBr.v 
                    maxBr.v := dfV, maxBr.p := close

        cl    :=  close
        vl    := volume
  
//LTF
tfS  = timeframe.in_seconds(      res       )
tfC  = timeframe.in_seconds(timeframe.period)
rs   = auto ? tfC / mlt : tfS 
rs  := prem ? rs : math.max(60, rs)
res := timeframe.from_seconds(math.min(tfC, rs))

[bV, sV, nV, tV, aCl] = request.security_lower_tf(
  syminfo.tickerid,  res  , 
 [
   close >  open ? volume : 0
 , close <  open ? volume : 0
 , close == open ? volume : 0
 , volume
 , close
 ]                                          )

vSize = tV.size()

//Highest volume when price movement (neutral volume not included)
float maxV = na, float bVmax = na , float sVmax = na 

if isLTF
    bVmax      := bV.max()
    sVmax      := sV.max()
    indices     = (bVmax > sVmax ? bV : sV).sort_indices(order.descending)
    maxV       := indices.size() > 0 ? aCl.get(indices.first()) : na
else 
    if maxBl.v != 0 or maxBr.v != 0
        maxV   := maxBl.v > maxBr.v ? maxBl.p : maxBr.p

// start Tick data
if not ticksAvailable and volBl > 0 
    ticksAvailable := true 

isAllowed = isTick ? ticksAvailable : tV.size() > 0

if isAllowed and not isAllowed[1]
    line.new(n, close, n, close + syminfo.mintick, color=color.silver, style=line.style_dotted, extend=extend.both)

ltf_Vup = bV.sum() 
ltf_Vdn = sV.sum() 

bullV = isTick ? volBl : ltf_Vup
bearV = isTick ? volBr : ltf_Vdn

abs   = math.abs(open  - close)
min   = math.min(open  , close)
max   = math.max(open  , close)
avg   = math.avg(open  , close)
vol   =          bullV + bearV
delta =          bullV - bearV

norm  = delta / volume
aNorm = math.abs(norm) 

pos   = norm >= 0 

float Base  = na
float value = na
value := option == 'half bar' ? avg + norm*abs/2 :  pos ? min + aNorm*abs : max - aNorm*abs
Base  := option == 'half bar' ? avg              :  pos ? min             : max

css   = close > open ? colUp : close < open ? colDn : CFG
cssD  = color.new(norm > 0   ? close > open ? colUp : colDn_ : close < open ? colDn : colUp_, 50)

//-----------------------------------------------------------------------------}      
//Plot
//-----------------------------------------------------------------------------{
barcolor(INV) // use 'Bar's style' "Bars" 
plotcandle(base, base, value, value, color = cssD, wickcolor = na , bordercolor =    na   , display = display.all - display.status_line)
plotcandle(open, high, low  , close, color =  na , wickcolor = css, bordercolor =    css  , display = display.all - display.status_line)
plotcandle(maxV, maxV, maxV , maxV , color = CFG , wickcolor = na , bordercolor =    CFG  , display = display.all - display.status_line)
plot      (dot ? maxV       : na   , color = CFG , style=plot.style_circles     , offset=1, display = display.all - display.status_line)
plot      (bullV                   ,                                                        display =               display.data_window)
plot      (bearV                   ,                                                        display =               display.data_window)

//-----------------------------------------------------------------------------}      
//Details
//-----------------------------------------------------------------------------{
volu = str.tostring(vol        , format.volume )
delt = str.tostring(delta      , format.volume )
perc = str.tostring(norm  * 100, format.percent)

if isAllowed and showD
    label.new(
       n
     , high
     , color=INV
     , textcolor=CFG
     , size=size.small
     , text=str.format(
     "Volume: {0}\nDelta: {1}\n%: {2}"
     , volu , delt, perc)
     )

//-----------------------------------------------------------------------------}      
//Table
//-----------------------------------------------------------------------------{
if showTab and isLTF
    if barstate.isfirst 
        tab  := table.new(position.top_right, 1, 1
             , bgcolor=INV
             )
    if barstate.islast
        tab.cell(0, 0, res, text_color=tabCol)

//-----------------------------------------------------------------------------}
````
