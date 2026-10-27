# MSNR  CISD SMT Divergence

- url: https://www.tradingview.com/script/QwKf9726-MSNR-CISD-SMT-Divergence/
- type: indicator
- pine_id: PUB;b12ed87dfae348c996fcb1f0c36827e3
- version: 1.0

## Description

COMPLETE EXECUTION CHECKLIST
Check 15M+ MSNR — What's the HTF bias? (HH/HL = longs, LL/LH = shorts)
Mark PDH/PDL/11:00 Open — Where is price relative to key levels?
Wait for Session Liquidity Sweep — Asian/London/US high or low taken?
Confirm SMT Divergence — Is correlated asset confirming or diverging?
Check CISD Level — Is there a delivery level at the sweep zone?
Enter at FVG — Is there a gap for precise entry?
Target opposite liquidity — BSL ↔ SSL, PDH ↔ PDL

## Source Code

````pine
//@version=6
indicator('MSNR  CISD SMT Divergence', overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// =========================================================================
// TIMEFRAME CHECK
// =========================================================================
bool isMSNRTf = not timeframe.isintraday or timeframe.in_seconds() >= 900

// =========================================================================
// INPUTS
// =========================================================================

// MSNR (15M+ only)
grp_msnr = 'MSNR (15M+ only)'
showA = input.bool(true, 'Show A-Shapes', group = grp_msnr)
colA = input.color(color.red, 'A-Shape Color', group = grp_msnr)
showV = input.bool(true, 'Show V-Shapes', group = grp_msnr)
colV = input.color(color.green, 'V-Shape Color', group = grp_msnr)
showMS = input.bool(true, 'Show MS Labels', group = grp_msnr)
pivotLen = input.int(5, 'Pivot Length', minval = 2, group = grp_msnr)

// CISD
grp_cisd = 'CISD Levels'
showCISD = input.bool(true, 'Show CISD', group = grp_cisd)
bullCISDCol = input.color(color.blue, 'Bull CISD', group = grp_cisd)
bearCISDCol = input.color(color.orange, 'Bear CISD', group = grp_cisd)
cisdLineWidth = input.int(2, 'Line Width', minval = 1, maxval = 5, group = grp_cisd)
lookAheadBars = input.int(5, 'Extension Bars', minval = 1, maxval = 20, group = grp_cisd)
keepOldCISD = input.bool(false, 'Keep Old Levels', group = grp_cisd)

// FVG
grp_fvg = 'Fair Value Gaps'
showFVG = input.bool(true, 'Show FVG', group = grp_fvg)
fvg_bull = input.color(color.new(color.green, 90), 'Bull FVG', group = grp_fvg)
fvg_bear = input.color(color.new(color.red, 90), 'Bear FVG', group = grp_fvg)

// Liquidity
grp_liq = 'Liquidity'
showLiq = input.bool(true, 'Show BSL/SSL', group = grp_liq)
liqLen = input.int(5, 'Pivot Length', minval = 2, group = grp_liq)
bslCol = input.color(color.new(color.red, 70), 'BSL', group = grp_liq)
sslCol = input.color(color.new(color.green, 70), 'SSL', group = grp_liq)

// Previous Day Levels
grp_pdh = 'Previous Day Levels'
showPDH = input.bool(true, 'Show Prev Day High', group = grp_pdh)
showPDL = input.bool(true, 'Show Prev Day Low', group = grp_pdh)
pdhCol = input.color(color.silver, 'PDH/PDL Color', group = grp_pdh)
pdhWidth = input.int(2, 'PDH/PDL Width', minval = 1, maxval = 4, group = grp_pdh)
pdhStyleInp = input.string('Solid', 'PDH/PDL Style', options = ['Solid', 'Dotted', 'Dashed'], group = grp_pdh)

// True Day Open
grp_tdo = 'True Day Open (11:00 BKK)'
showTDO = input.bool(true, 'Show True Day Open', group = grp_tdo)
tdoCol = input.color(color.gray, 'TDO Color', group = grp_tdo)
tdoWidth = input.int(2, 'TDO Width', minval = 1, maxval = 4, group = grp_tdo)
tdoStyleInp = input.string('Dotted', 'TDO Style', options = ['Solid', 'Dotted', 'Dashed'], group = grp_tdo)

// SMT Divergence
grp_smt = 'SMT Divergence'
smtSymbol = input.symbol('CME_MINI:NQ1!', 'Correlated Symbol', group = grp_smt)
showSMT = input.bool(true, 'Show SMT Divergence', group = grp_smt)
smtLen = input.int(5, 'SMT Pivot Length', minval = 2, group = grp_smt)
smtBullCol = input.color(color.teal, 'Bullish SMT', group = grp_smt)
smtBearCol = input.color(color.maroon, 'Bearish SMT', group = grp_smt)
smtWidth = input.int(2, 'SMT Line Width', minval = 1, maxval = 4, group = grp_smt)

// =========================================================================
// STYLE HELPERS
// =========================================================================
pdhStyle = pdhStyleInp == 'Dotted' ? line.style_dotted : pdhStyleInp == 'Dashed' ? line.style_dashed : line.style_solid
tdoStyle = tdoStyleInp == 'Dotted' ? line.style_dotted : tdoStyleInp == 'Dashed' ? line.style_dashed : line.style_solid

// =========================================================================
// MSNR A/V SHAPES — 15M+ ONLY
// =========================================================================
a_shape = isMSNRTf ? ta.pivothigh(close, pivotLen, pivotLen) : na
v_shape = isMSNRTf ? ta.pivotlow(close, pivotLen, pivotLen) : na

var array<line> active_A_lines = array.new_line()
var array<line> active_V_lines = array.new_line()
var float last_a_val = na
var float last_v_val = na

if isMSNRTf
    if not na(a_shape)
        bool already_broken = false
        for i = 0 to pivotLen - 1
            if close[i] > a_shape
                already_broken := true
                break
        int px = bar_index - pivotLen
        if not already_broken and showA
            line l = line.new(px, a_shape, bar_index, a_shape, color = colA, width = 2)
            array.push(active_A_lines, l)
            if array.size(active_A_lines) > 5
                line.delete(array.shift(active_A_lines))
        if showMS
            string ms_txt = na(last_a_val) ? 'H' : a_shape > last_a_val ? 'HH' : 'LH'
            label.new(px, a_shape, ms_txt, style = label.style_label_down, color = color.new(colA, 100), textcolor = colA, size = size.small)
        last_a_val := a_shape

    if not na(v_shape)
        bool already_broken_v = false
        for i = 0 to pivotLen - 1
            if close[i] < v_shape
                already_broken_v := true
                break
        int px = bar_index - pivotLen
        if not already_broken_v and showV
            line l = line.new(px, v_shape, bar_index, v_shape, color = colV, width = 2)
            array.push(active_V_lines, l)
            if array.size(active_V_lines) > 5
                line.delete(array.shift(active_V_lines))
        if showMS
            string ms_txt_v = na(last_v_val) ? 'L' : v_shape > last_v_val ? 'HL' : 'LL'
            label.new(px, v_shape, ms_txt_v, style = label.style_label_up, color = color.new(colV, 100), textcolor = colV, size = size.small)
        last_v_val := v_shape

    if array.size(active_A_lines) > 0
        for i = array.size(active_A_lines) - 1 to 0
            line l = array.get(active_A_lines, i)
            line.set_x2(l, bar_index)
            if close > line.get_y1(l)
                line.delete(l)
                array.remove(active_A_lines, i)

    if array.size(active_V_lines) > 0
        for i = array.size(active_V_lines) - 1 to 0
            line l = array.get(active_V_lines, i)
            line.set_x2(l, bar_index)
            if close < line.get_y1(l)
                line.delete(l)
                array.remove(active_V_lines, i)

// =========================================================================
// CISD
// =========================================================================
type MarketStructure
    float topPrice
    float bottomPrice
    bool isBullish

type cisd
    line level
    label txt
    bool completed

var MarketStructure currentStructure = MarketStructure.new(0, 0, false)
var cisdLevelsBu = array.new<cisd>()
var cisdLevelsBe = array.new<cisd>()
var bool isBullishPullback = false
var bool isBearishPullback = false
var float potentialTopPrice = na
var float potentialBottomPrice = na
var int bullishBreakIndex = na
var int bearishBreakIndex = na

bearishPullbackDetected = close[1] > open[1]
bullishPullbackDetected = close[1] < open[1]

if bearishPullbackDetected and not isBearishPullback
    isBearishPullback := true
    potentialTopPrice := open[1]
    bullishBreakIndex := bar_index[1]

if bullishPullbackDetected and not isBullishPullback
    isBullishPullback := true
    potentialBottomPrice := open[1]
    bearishBreakIndex := bar_index[1]

if isBullishPullback
    if open < potentialBottomPrice
        potentialBottomPrice := open
        bearishBreakIndex := bar_index
    if close < open and open > potentialBottomPrice
        potentialBottomPrice := open
        bearishBreakIndex := bar_index

if isBearishPullback
    if open > potentialTopPrice
        potentialTopPrice := open
        bullishBreakIndex := bar_index
    if close > open and open < potentialTopPrice
        potentialTopPrice := open
        bullishBreakIndex := bar_index

if showCISD and low < currentStructure.bottomPrice
    currentStructure.bottomPrice := low
    currentStructure.isBullish := false
    if isBearishPullback and bar_index - bullishBreakIndex != 0
        currentStructure.topPrice := math.max(high[bar_index - bullishBreakIndex], high[bar_index - bullishBreakIndex + 1])
        isBearishPullback := false
        line bearishLine = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color = bullCISDCol, width = cisdLineWidth, style = line.style_solid)
        label bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, '+CISD', color = color.new(color.white, 100), textcolor = bullCISDCol, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBe.push(cisd.new(bearishLine, bearishLabel, false))
    else if close[1] > open[1] and close < open
        currentStructure.topPrice := high[1]
        isBearishPullback := false
        line bearishLine = line.new(bullishBreakIndex, potentialTopPrice, bar_index + lookAheadBars, potentialTopPrice, color = bullCISDCol, width = cisdLineWidth, style = line.style_solid)
        label bearishLabel = label.new(bar_index + lookAheadBars, potentialTopPrice, '+CISD', color = color.new(color.white, 100), textcolor = bullCISDCol, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBe.push(cisd.new(bearishLine, bearishLabel, false))

if showCISD and high > currentStructure.topPrice
    currentStructure.isBullish := true
    currentStructure.topPrice := high
    if isBullishPullback and bar_index - bearishBreakIndex != 0
        currentStructure.bottomPrice := math.min(low[bar_index - bearishBreakIndex], low[bar_index - bearishBreakIndex + 1])
        isBullishPullback := false
        line bullishLine = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color = bearCISDCol, width = cisdLineWidth, style = line.style_solid)
        label bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, '-CISD', color = color.new(color.white, 100), textcolor = bearCISDCol, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBu.push(cisd.new(bullishLine, bullishLabel, false))
    else if close[1] < open[1] and close > open
        currentStructure.bottomPrice := low[1]
        isBullishPullback := false
        line bullishLine = line.new(bearishBreakIndex, potentialBottomPrice, bar_index + lookAheadBars, potentialBottomPrice, color = bearCISDCol, width = cisdLineWidth, style = line.style_solid)
        label bullishLabel = label.new(bar_index + lookAheadBars, potentialBottomPrice, '-CISD', color = color.new(color.white, 100), textcolor = bearCISDCol, style = label.style_label_left, size = size.small, text_formatting = text.format_italic)
        cisdLevelsBu.push(cisd.new(bullishLine, bullishLabel, false))

if array.size(cisdLevelsBu) > 1 and not keepOldCISD
    cisd latest = array.shift(cisdLevelsBu)
    line.delete(latest.level)
    label.delete(latest.txt)

if array.size(cisdLevelsBe) > 1 and not keepOldCISD
    cisd latest = array.shift(cisdLevelsBe)
    line.delete(latest.level)
    label.delete(latest.txt)

if showCISD and array.size(cisdLevelsBu) >= 1
    cisd latest = array.get(cisdLevelsBu, 0)
    if not (close < latest.level.get_y2()) and not latest.completed
        line.set_x2(latest.level, bar_index + lookAheadBars)
        label.set_x(latest.txt, bar_index + lookAheadBars)
    if close < latest.level.get_y2() and not latest.completed
        latest.completed := true

if showCISD and array.size(cisdLevelsBe) >= 1
    cisd latest = array.get(cisdLevelsBe, 0)
    if not (close > latest.level.get_y2()) and not latest.completed
        line.set_x2(latest.level, bar_index + lookAheadBars)
        label.set_x(latest.txt, bar_index + lookAheadBars)
    if close > latest.level.get_y2() and not latest.completed
        latest.completed := true

// =========================================================================
// LIQUIDITY
// =========================================================================
var line bsl_line = na
var line ssl_line = na
bsl_pivot = ta.pivothigh(high, liqLen, liqLen)
ssl_pivot = ta.pivotlow(low, liqLen, liqLen)

if showLiq
    if not na(bsl_pivot)
        bool already_swept = false
        for i = 0 to liqLen - 1
            if high[i] > bsl_pivot
                already_swept := true
                break
        if not already_swept
            if not na(bsl_line)
                line.delete(bsl_line)
            bsl_line := line.new(bar_index - liqLen, bsl_pivot, bar_index, bsl_pivot, color = bslCol, style = line.style_dotted, width = 2)
    if not na(ssl_pivot)
        bool already_swept_ssl = false
        for i = 0 to liqLen - 1
            if low[i] < ssl_pivot
                already_swept_ssl := true
                break
        if not already_swept_ssl
            if not na(ssl_line)
                line.delete(ssl_line)
            ssl_line := line.new(bar_index - liqLen, ssl_pivot, bar_index, ssl_pivot, color = sslCol, style = line.style_dotted, width = 2)

if showLiq and not na(bsl_line)
    if high <= line.get_y1(bsl_line)
        line.set_x2(bsl_line, bar_index)
    else
        line.delete(bsl_line)
        bsl_line := na

if showLiq and not na(ssl_line)
    if low >= line.get_y1(ssl_line)
        line.set_x2(ssl_line, bar_index)
    else
        line.delete(ssl_line)
        ssl_line := na

// =========================================================================
// FVG
// =========================================================================
var array<box> b_fvgs = array.new_box()
var array<line> b_fvg_mids = array.new_line()
var array<box> r_fvgs = array.new_box()
var array<line> r_fvg_mids = array.new_line()

if showFVG
    if low > high[2]
        float top = low
        float bot = high[2]
        float mid = (top + bot) / 2.0
        box bx = box.new(bar_index - 1, top, bar_index, bot, border_color = color(na), bgcolor = fvg_bull)
        line ln = line.new(bar_index - 1, mid, bar_index, mid, color = color.new(color.green, 40), style = line.style_solid, width = 1)
        array.push(b_fvgs, bx)
        array.push(b_fvg_mids, ln)
        if array.size(b_fvgs) > 10
            box.delete(array.shift(b_fvgs))
            line.delete(array.shift(b_fvg_mids))
    if high < low[2]
        float top = low[2]
        float bot = high
        float mid = (top + bot) / 2.0
        box bx = box.new(bar_index - 1, top, bar_index, bot, border_color = color(na), bgcolor = fvg_bear)
        line ln = line.new(bar_index - 1, mid, bar_index, mid, color = color.new(color.red, 40), style = line.style_solid, width = 1)
        array.push(r_fvgs, bx)
        array.push(r_fvg_mids, ln)
        if array.size(r_fvgs) > 10
            box.delete(array.shift(r_fvgs))
            line.delete(array.shift(r_fvg_mids))
    if array.size(b_fvgs) > 0
        for i = array.size(b_fvgs) - 1 to 0
            box bx = array.get(b_fvgs, i)
            line ln = array.get(b_fvg_mids, i)
            box.set_right(bx, bar_index)
            line.set_x2(ln, bar_index)
            if close < box.get_bottom(bx)
                box.delete(bx)
                line.delete(ln)
                array.remove(b_fvgs, i)
                array.remove(b_fvg_mids, i)
    if array.size(r_fvgs) > 0
        for i = array.size(r_fvgs) - 1 to 0
            box bx = array.get(r_fvgs, i)
            line ln = array.get(r_fvg_mids, i)
            box.set_right(bx, bar_index)
            line.set_x2(ln, bar_index)
            if close > box.get_top(bx)
                box.delete(bx)
                line.delete(ln)
                array.remove(r_fvgs, i)
                array.remove(r_fvg_mids, i)

// =========================================================================
// PREVIOUS DAY HIGH / LOW — Solid, Adjustable, Extended
// =========================================================================
pdh = request.security(syminfo.tickerid, '1D', high[1], lookahead = barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, '1D', low[1], lookahead = barmerge.lookahead_on)

var line pdh_line = na
var label pdh_lbl = na
var line pdl_line = na
var label pdl_lbl = na
var float last_pdh = na
var float last_pdl = na

bool new_trading_day = ta.change(time_tradingday) != 0

if new_trading_day
    if not na(pdh_line)
        line.delete(pdh_line)
        pdh_line := na
    if not na(pdh_lbl)
        label.delete(pdh_lbl)
        pdh_lbl := na
    if not na(pdl_line)
        line.delete(pdl_line)
        pdl_line := na
    if not na(pdl_lbl)
        label.delete(pdl_lbl)
        pdl_lbl := na

    last_pdh := pdh
    last_pdl := pdl

    if showPDH and not na(last_pdh)
        pdh_line := line.new(bar_index, last_pdh, bar_index + 10, last_pdh, color = pdhCol, style = pdhStyle, width = pdhWidth, extend = extend.right)
        pdh_lbl := label.new(bar_index, last_pdh, 'PDH', style = label.style_label_down, color = color(na), textcolor = pdhCol, size = size.tiny)
    if showPDL and not na(last_pdl)
        pdl_line := line.new(bar_index, last_pdl, bar_index + 10, last_pdl, color = pdhCol, style = pdhStyle, width = pdhWidth, extend = extend.right)
        pdl_lbl := label.new(bar_index, last_pdl, 'PDL', style = label.style_label_up, color = color(na), textcolor = pdhCol, size = size.tiny)

if not na(pdh_lbl)
    label.set_x(pdh_lbl, bar_index)
if not na(pdl_lbl)
    label.set_x(pdl_lbl, bar_index)

// =========================================================================
// TRUE DAY OPEN — 11:00 BKK, Adjustable
// =========================================================================
in_session_tdo(sess_str) => not na(time(timeframe.period, sess_str, 'Asia/Bangkok'))

bool is_1100 = in_session_tdo('1100-1101')
bool is_1100_prev = bar_index > 0 ? is_1100[1] : false

var line tdo_line = na
var label tdo_lbl = na
var float tdo_price = na

if is_1100 and not is_1100_prev
    if not na(tdo_line)
        line.delete(tdo_line)
        tdo_line := na
    if not na(tdo_lbl)
        label.delete(tdo_lbl)
        tdo_lbl := na
    tdo_price := open
    if showTDO and not na(tdo_price)
        tdo_line := line.new(bar_index, tdo_price, bar_index + 10, tdo_price, color = tdoCol, style = tdoStyle, width = tdoWidth, extend = extend.right)
        tdo_lbl := label.new(bar_index, tdo_price, '11:00 Open', style = label.style_label_up, color = color(na), textcolor = tdoCol, size = size.tiny)

if not na(tdo_lbl)
    label.set_x(tdo_lbl, bar_index)

// =========================================================================
// SMT DIVERGENCE — Proper Implementation with Visible Lines
// =========================================================================
// Get correlated symbol data
corrHigh = request.security(smtSymbol, timeframe.period, high, gaps = barmerge.gaps_off)
corrLow = request.security(smtSymbol, timeframe.period, low, gaps = barmerge.gaps_off)
corrClose = request.security(smtSymbol, timeframe.period, close, gaps = barmerge.gaps_off)

// Pivots on both symbols
ph_main = ta.pivothigh(high, smtLen, smtLen)
pl_main = ta.pivotlow(low, smtLen, smtLen)
ph_corr = ta.pivothigh(corrHigh, smtLen, smtLen)
pl_corr = ta.pivotlow(corrLow, smtLen, smtLen)

// Track last pivot values for divergence detection
var float last_ph_main = na
var float last_ph_corr = na
var float last_pl_main = na
var float last_pl_corr = na

var line smt_line = na
var label smt_lbl = na

if showSMT
    // Update pivot history
    if not na(ph_main)
        last_ph_main := ph_main
    if not na(ph_corr)
        last_ph_corr := ph_corr
    if not na(pl_main)
        last_pl_main := pl_main
    if not na(pl_corr)
        last_pl_corr := pl_corr

    // Bearish SMT: Main makes Higher High, Correlated makes Lower High
    if not na(ph_main) and not na(last_ph_main[1]) and not na(last_ph_corr[1])
        bool main_hh = ph_main > last_ph_main[1]
        bool corr_lh = ph_corr < last_ph_corr[1] or (na(ph_corr) and not na(last_ph_corr[1]))
        if main_hh and corr_lh
            if not na(smt_line)
                line.delete(smt_line)
            if not na(smt_lbl)
                label.delete(smt_lbl)
            smt_line := line.new(bar_index - smtLen, ph_main, bar_index, ph_main, color = smtBearCol, width = smtWidth, style = line.style_dashed)
            smt_lbl := label.new(bar_index, ph_main, 'SMT Bear ▼', style = label.style_label_down, color = color(na), textcolor = smtBearCol, size = size.small)

    // Bullish SMT: Main makes Lower Low, Correlated makes Higher Low
    if not na(pl_main) and not na(last_pl_main[1]) and not na(last_pl_corr[1])
        bool main_ll = pl_main < last_pl_main[1]
        bool corr_hl = pl_corr > last_pl_corr[1] or (na(pl_corr) and not na(last_pl_corr[1]))
        if main_ll and corr_hl
            if not na(smt_line)
                line.delete(smt_line)
            if not na(smt_lbl)
                label.delete(smt_lbl)
            smt_line := line.new(bar_index - smtLen, pl_main, bar_index, pl_main, color = smtBullCol, width = smtWidth, style = line.style_dashed)
            smt_lbl := label.new(bar_index, pl_main, 'SMT Bull ▲', style = label.style_label_up, color = color(na), textcolor = smtBullCol, size = size.small)

// Extend SMT line
if not na(smt_line)
    line.set_x2(smt_line, bar_index)
if not na(smt_lbl)
    label.set_x(smt_lbl, bar_index)
````
