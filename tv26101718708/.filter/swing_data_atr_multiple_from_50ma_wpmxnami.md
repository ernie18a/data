# Swing Data + ATR% Multiple from 50-MA

- url: https://www.tradingview.com/script/WpmxnamI-Swing-Data-ATR-Multiple-from-50-MA/
- type: indicator
- pine_id: PUB;9a3cbfee2a414f39b51fc41687d0fe17
- version: 1.0

## Description

Combines Swing Data (ADR%, Float, Volume metrics, RS Rating, Sector) with ATR% Multiple from 50-MA. Plots colour-coded dots above bars when price is extended from the 50-MA by a configurable number of ATR multiples. All data displayed in a single customisable table with 9 position options.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Trxits

//@version=6
indicator(title = 'Swing Data + ATR% Multiple from 50-MA', shorttitle='SD+ATRMult', overlay=true, max_bars_back = 253)

// ============================================================
// TABLE & DISPLAY INPUTS
// ============================================================
posTable        = input.string('Top Right', 'Table Position', options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'], group='Table')
tbl_size        = input.string('Small', 'Table Size', options=['Tiny','Small','Normal','Large'], group='Table')
txt_col         = input(color.orange, 'Text Color', group='Table')
bg_col          = input(#00000000,    'Background Color', group='Table')
txt_align_left  = input.string('Center', 'Left Column Align',  options=['Left','Center','Right'], group='Table')
txt_align_right = input.string('Center', 'Right Column Align', options=['Left','Center','Right'], group='Table')
show_empty_top  = input(true, 'Empty row at top', group='Table')
add_empty_dn    = input.int(0, 'Empty rows at bottom', minval=0, maxval=5, group='Table')

// ============================================================
// SWING DATA — DISPLAY TOGGLES (defaults match your screenshots)
// ============================================================
show_mktCap       = input(true,  'Show Market Cap',        group='Swing Data Display')
show_float        = input(true,  'Show Shares Float',      group='Swing Data Display')
show_floatpercent = input(false, 'Show Float%',            group='Swing Data Display')
show_adrp         = input(true,  'Show ADR%',              group='Swing Data Display')
show_atrPer       = input(false, 'Show ATR%',              group='Swing Data Display')
show_atr_val      = input(true,  'Show ATR',               group='Swing Data Display')
show_ipo_date     = input(false, 'Show IPO Timer',         group='Swing Data Display')
show_lod_dist     = input(true,  'Show LoD dist.',         group='Swing Data Display')
show_lod_price    = input(true,  'Show LoD Price',         group='Swing Data Display')
show_dist_high    = input(false, 'Show % dist 52W High',   group='Swing Data Display')
show_dist_low     = input(false, 'Show % dist 52W Low',    group='Swing Data Display')
show_ADVS         = input(true,  'Show Avg $ Volume',      group='Swing Data Display')
show_ADV          = input(false, 'Show Avg Volume',        group='Swing Data Display')
show_projVol      = input(false, 'Show Projected Volume',  group='Swing Data Display')
show_relVol       = input(false, 'Show Relative Volume',   group='Swing Data Display')
show_volBuzz      = input(false, 'Show Vol. Buzz',         group='Swing Data Display')
show_UDratio      = input(false, 'Show U/D Ratio',         group='Swing Data Display')
show_rs_rating    = input(false, 'Show RS Rating',         group='Swing Data Display')
show_liqCap       = input(false, 'Show Liquidity Cap',     group='Swing Data Display')
show_sector       = input(true,  'Show Sector',            group='Swing Data Display')
show_selectSector = input(false, 'Show Sector ETF',        group='Swing Data Display', inline='ss')
show_sector_rs    = input(false, 'Sector RS',              group='Swing Data Display', inline='ss')
sector_chg_Up     = input(color.rgb(165,214,167,0), 'Positive Chg Color', group='Swing Data Display')
sector_chg_Dn     = input(color.rgb(250,161,164,0), 'Negative Chg Color', group='Swing Data Display')
show_ind          = input(true,  'Show Industry Group',    group='Swing Data Display')

// ============================================================
// SWING DATA — PARAMETERS
// ============================================================
adrp_len = input.int(20, 'ADR% Length',      group='Swing Data Parameters')
atr_len  = input.int(14, 'ATR Length',       group='Swing Data Parameters')
vol_len  = input.int(50, 'Volume MA Length', group='Swing Data Parameters')

// ============================================================
// ATR% MULTIPLE — PARAMETERS
// ============================================================
show_atrMult_tbl = input(true,  'Show ATR% Multiple rows in table', group='ATR% Multiple from MA')
atrMult_atrLen   = input.int(14, 'ATR Length', group='ATR% Multiple from MA')
atrMult_maLen    = input.int(50, 'MA Length',  group='ATR% Multiple from MA')

// ============================================================
// 3 DOT LEVELS (defaults match your screenshots)
// ============================================================
dot1_on     = input(true,          'Enable Level 1 Dot',        group='Dot Level 1')
dot1_thresh = input.float(11,      'Level 1 Threshold (x ATR)', group='Dot Level 1', step=0.5)
dot1_col    = input(color.yellow,  'Level 1 Color',             group='Dot Level 1')
dot1_size   = input.string('tiny', 'Level 1 Size', options=['tiny','small','normal','large'], group='Dot Level 1')

dot2_on     = input(true,          'Enable Level 2 Dot',        group='Dot Level 2')
dot2_thresh = input.float(13.5,    'Level 2 Threshold (x ATR)', group='Dot Level 2', step=0.5)
dot2_col    = input(color.orange,  'Level 2 Color',             group='Dot Level 2')
dot2_size   = input.string('tiny', 'Level 2 Size', options=['tiny','small','normal','large'], group='Dot Level 2')

dot3_on     = input(true,          'Enable Level 3 Dot',        group='Dot Level 3')
dot3_thresh = input.float(16,      'Level 3 Threshold (x ATR)', group='Dot Level 3', step=0.5)
dot3_col    = input(color.red,     'Level 3 Color',             group='Dot Level 3')
dot3_size   = input.string('tiny', 'Level 3 Size', options=['tiny','small','normal','large'], group='Dot Level 3')

// ============================================================
// SWITCH HELPERS
// ============================================================
tablePos = switch posTable
    'Top Left'      => position.top_left
    'Top Center'    => position.top_center
    'Top Right'     => position.top_right
    'Middle Left'   => position.middle_left
    'Middle Center' => position.middle_center
    'Middle Right'  => position.middle_right
    'Bottom Left'   => position.bottom_left
    'Bottom Center' => position.bottom_center
    'Bottom Right'  => position.bottom_right

size_tbl = switch tbl_size
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    'Large'  => size.large

align_L = switch txt_align_left
    'Left'   => text.align_left
    'Center' => text.align_center
    'Right'  => text.align_right

align_R = switch txt_align_right
    'Left'   => text.align_left
    'Center' => text.align_center
    'Right'  => text.align_right

// ============================================================
// SWING DATA CALCULATIONS
// ============================================================
s  = syminfo.tickerid
tf = timeframe.period

arp       = 100 * (ta.sma(high / low, adrp_len) - 1)
atr       = ta.atr(atr_len)
atrp      = 100 * (atr / close)
lod_dist  = 100 * (close - low) / atr
lod_price = low

ipoSince = request.security(s, 'D', (bar_index + 1) / 252)

vol    = request.security(s, tf, volume)
ma     = ta.sma(vol, vol_len)
relVol = vol / ma * 100

avgDaVol     = request.security(s, tf, ma)
avgDaVolCalc = avgDaVol
uV = ''
if avgDaVol >= 1000 and avgDaVol < 1000000
    avgDaVol := avgDaVol / 1000
    uV := 'K'
if avgDaVol >= 1000000 and avgDaVol < 1000000000
    avgDaVol := avgDaVol / 1000000
    uV := 'M'
if avgDaVol >= 1000000000
    avgDaVol := avgDaVol / 1000000000
    uV := 'B'

closeDa  = request.security(s, tf, close)
advdolDa = closeDa * avgDaVolCalc
uVDoll = ''
if advdolDa >= 1000 and advdolDa < 1000000
    advdolDa := advdolDa / 1000
    uVDoll := 'K'
if advdolDa >= 1000000 and advdolDa < 1000000000
    advdolDa := advdolDa / 1000000
    uVDoll := 'M'
if advdolDa >= 1000000000
    advdolDa := advdolDa / 1000000000
    uVDoll := 'B'

MCap = request.financial(s, 'MARKET_CAP_BASIC', 'D', ignore_invalid_symbol=true)
if na(MCap)
    MCap := syminfo.shares_outstanding_total * close
MCapCalc = MCap
uM = ''
if MCap >= 1000 and MCap < 1000000
    MCap := MCap / 1000
    uM := 'K'
if MCap >= 1000000 and MCap < 1000000000
    MCap := MCap / 1000000
    uM := 'M'
if MCap >= 1000000000
    MCap := MCap / 1000000000
    uM := 'B'

FSO      = syminfo.shares_outstanding_float
floatPer = (FSO * closeDa) / MCapCalc * 100

time_passed = (timenow    - time)    / 1000
time_left   = (time_close - timenow) / 1000
vol_per_sec = 0.0
vol_proj    = float(volume)
uP = ''
if time_left > 0
    vol_per_sec := volume / time_passed
    vol_proj    := volume + vol_per_sec * time_left
if vol_proj >= 1000 and vol_proj < 1000000
    vol_proj := vol_proj / 1000
    uP := 'K'
if vol_proj >= 1000000 and vol_proj < 1000000000
    vol_proj := vol_proj / 1000000
    uP := 'M'
if vol_proj >= 1000000000
    vol_proj := vol_proj / 1000000000
    uP := 'B'

volBuzz = 100 * (volume / ta.sma(volume, vol_len) - 1)

string sector = syminfo.sector
if na(sector)
    sector := 'N/A'

get_sector_etf(sec) =>
    switch sec
        "Technology Services"    => "XLK"
        "Electronic Technology"  => "XLK"
        "Finance"                => "XLF"
        "Health Technology"      => "XLV"
        "Health Services"        => "XLV"
        "Retail Trade"           => "XLP"
        "Consumer Non-Durables"  => "XLP"
        "Energy Minerals"        => "XLE"
        "Producer Manufacturing" => "XLI"
        "Consumer Services"      => "XLY"
        "Consumer Durables"      => "XLY"
        "Commercial Services"    => "XLI"
        "Industrial Services"    => "XLI"
        "Utilities"              => "XLU"
        "Transportation"         => "XLI"
        "Non-Energy Minerals"    => "XLB"
        "Process Industries"     => "XLB"
        "Communications"         => "XLC"
        "Distribution Services"  => "XLI"
        => "SPY"

sector_etf  = get_sector_etf(sector)
closeSector = request.security(sector_etf, 'D', close)
openSector  = request.security(sector_etf, 'D', open)
sector_chg  = (closeSector - openSector) / openSector * 100

string industryGrp = syminfo.industry
if na(industryGrp)
    industryGrp := 'N/A'

f_attr(score, hi, lo, rUp, rDn, w) =>
    s2 = score + (score - lo) * w
    if s2 > hi - 1
        s2 := hi - 1
    k1 = lo / rDn
    k2 = (hi - 1) / rUp
    k3 = (k1 - k2) / (hi - 1 - lo)
    r  = s2 / (k1 - k3 * (score - lo))
    math.max(rDn, math.min(rUp, r))

f_rs(ticker) =>
    n63  = math.min(bar_index, 63)
    n126 = math.min(bar_index, 126)
    n189 = math.min(bar_index, 189)
    n252 = math.min(bar_index, 252)
    cT   = request.security(ticker,   'D', close)
    cSPX = request.security('SP:SPX', 'D', close)
    rs_t = 0.4*(cT/cT[n63])     + 0.2*(cT/cT[n126])     + 0.2*(cT/cT[n189])     + 0.2*(cT/cT[n252])
    rs_s = 0.4*(cSPX/cSPX[n63]) + 0.2*(cSPX/cSPX[n126]) + 0.2*(cSPX/cSPX[n189]) + 0.2*(cSPX/cSPX[n252])
    float score  = rs_t / rs_s * 100
    float rating = -1.0
    curve = request.seed('seed_fred6725_rs_rating', 'RSRATING', close)
    delta = ta.barssince(na(curve) != true)
    var float[] dv = array.new_float(7)
    var int cnt = 0
    float v0 = 0.0
    float v1 = 0.0
    float v2 = 0.0
    float v3 = 0.0
    float v4 = 0.0
    float v5 = 0.0
    float v6 = 0.0
    if true
        for i = delta to 34 + delta
            cv = nz(curve[i])
            if not array.includes(dv, cv) and cnt < 7 and cv != 0
                array.set(dv, cnt, cv)
                cnt := cnt + 1
        v0 := array.get(dv, 0)
        v1 := array.get(dv, 1)
        v2 := array.get(dv, 2)
        v3 := array.get(dv, 3)
        v4 := array.get(dv, 4)
        v5 := array.get(dv, 5)
        v6 := array.get(dv, 6)
    if score >= v0
        rating := 99.0
    if score <= v6
        rating := 1.0
    if score < v0 and score >= v1
        rating := f_attr(score, v0, v1, 98, 90, 0.33)
    if score < v1 and score >= v2
        rating := f_attr(score, v1, v2, 89, 70, 2.1)
    if score < v2 and score >= v3
        rating := f_attr(score, v2, v3, 69, 50, 0)
    if score < v3 and score >= v4
        rating := f_attr(score, v3, v4, 49, 30, 0)
    if score < v4 and score >= v5
        rating := f_attr(score, v4, v5, 29, 10, 0)
    if score < v5 and score >= v6
        rating := f_attr(score, v5, v6, 9,  2,  0)
    rating

sectorRs      = f_rs(sector_etf)
totalRsRating = f_rs(syminfo.tickerid)

volDa        = request.security(s, 'D', volume)
maDa         = request.security(s, 'D', ta.sma(volDa, vol_len))
liquidityCap = request.security(s, 'D', maDa) * 0.01

upDnVolRatio = math.sum(close > close[1] ? volume : 0, 50) / math.sum(close < close[1] ? volume : 0, 50)

fiftyTwoWeekHigh = request.security(s, 'W', ta.highest(high, 52))
fiftyTwoWeekLow  = request.security(s, 'W', ta.lowest(low,  52))
distFromHigh     = 100 * (closeDa / fiftyTwoWeekHigh - 1)
distFromLow      = 100 * (closeDa / fiftyTwoWeekLow  - 1)

sharesFloat = syminfo.shares_outstanding_float
uF = ''
if sharesFloat >= 1000 and sharesFloat < 1000000
    sharesFloat := sharesFloat / 1000
    uF := 'K'
if sharesFloat >= 1000000 and sharesFloat < 1000000000
    sharesFloat := sharesFloat / 1000000
    uF := 'M'
if sharesFloat >= 1000000000
    sharesFloat := sharesFloat / 1000000000
    uF := 'B'

// ============================================================
// ATR% MULTIPLE CALCULATIONS
// ============================================================
am_atr    = ta.atr(atrMult_atrLen)
am_atrP   = 100 * (am_atr / close)
am_ma     = ta.sma(close, atrMult_maLen)
am_gainMA = 100 * (close - am_ma) / am_ma
am_ratio  = am_atrP != 0 ? am_gainMA / am_atrP : na

// ============================================================
// DOT PLOTS — above bar, size branched for compile-time const
// ============================================================
d1_base = dot1_on and am_ratio >= dot1_thresh and (not dot2_on or am_ratio < dot2_thresh)
plotshape(d1_base and dot1_size == 'tiny',   style=shape.circle, location=location.abovebar, color=dot1_col, size=size.tiny,   title='Dot L1 tiny')
plotshape(d1_base and dot1_size == 'small',  style=shape.circle, location=location.abovebar, color=dot1_col, size=size.small,  title='Dot L1 small')
plotshape(d1_base and dot1_size == 'normal', style=shape.circle, location=location.abovebar, color=dot1_col, size=size.normal, title='Dot L1 normal')
plotshape(d1_base and dot1_size == 'large',  style=shape.circle, location=location.abovebar, color=dot1_col, size=size.large,  title='Dot L1 large')

d2_base = dot2_on and am_ratio >= dot2_thresh and (not dot3_on or am_ratio < dot3_thresh)
plotshape(d2_base and dot2_size == 'tiny',   style=shape.circle, location=location.abovebar, color=dot2_col, size=size.tiny,   title='Dot L2 tiny')
plotshape(d2_base and dot2_size == 'small',  style=shape.circle, location=location.abovebar, color=dot2_col, size=size.small,  title='Dot L2 small')
plotshape(d2_base and dot2_size == 'normal', style=shape.circle, location=location.abovebar, color=dot2_col, size=size.normal, title='Dot L2 normal')
plotshape(d2_base and dot2_size == 'large',  style=shape.circle, location=location.abovebar, color=dot2_col, size=size.large,  title='Dot L2 large')

d3_base = dot3_on and am_ratio >= dot3_thresh
plotshape(d3_base and dot3_size == 'tiny',   style=shape.circle, location=location.abovebar, color=dot3_col, size=size.tiny,   title='Dot L3 tiny')
plotshape(d3_base and dot3_size == 'small',  style=shape.circle, location=location.abovebar, color=dot3_col, size=size.small,  title='Dot L3 small')
plotshape(d3_base and dot3_size == 'normal', style=shape.circle, location=location.abovebar, color=dot3_col, size=size.normal, title='Dot L3 normal')
plotshape(d3_base and dot3_size == 'large',  style=shape.circle, location=location.abovebar, color=dot3_col, size=size.large,  title='Dot L3 large')

// ============================================================
// UNIFIED TABLE
// ============================================================
tfDaily = timeframe.isdaily
table t = table.new(tablePos, 2, 40, bgcolor=bg_col)

f_row(tbl, r, lbl, val) =>
    table.cell(tbl, 0, r, lbl, text_color=txt_col, text_size=size_tbl)
    table.cell(tbl, 1, r, val, text_color=txt_col, text_size=size_tbl)
    table.cell_set_text_halign(tbl, 0, r, text_halign=align_L)
    table.cell_set_text_halign(tbl, 1, r, text_halign=align_R)

f_full(tbl, r, lbl, col) =>
    table.cell(tbl, 0, r, lbl, text_color=col, text_size=size_tbl)
    table.cell(tbl, 1, r, '')
    table.merge_cells(tbl, 0, r, 1, r)
    table.cell_set_text_halign(tbl, 0, r, text_halign=align_L)

if barstate.islast
    r = 0

    if show_empty_top
        table.cell(t, 0, r, '')
        table.cell(t, 1, r, '')
        r := r + 1

    if show_mktCap
        f_row(t, r, 'Market Cap', str.tostring(MCap,'0.00') + uM)
        r := r + 1
    if show_float
        f_row(t, r, 'Shares Float', str.tostring(sharesFloat,'0.00') + uF)
        r := r + 1
    if show_floatpercent
        f_row(t, r, 'Float %', str.tostring(floatPer,'0.0') + '%')
        r := r + 1
    if show_adrp
        f_row(t, r, 'ADR%', str.tostring(arp,'0.00') + '%')
        r := r + 1
    if show_atrPer
        f_row(t, r, 'ATR%', str.tostring(atrp,'0.00') + '%')
        r := r + 1
    if show_atr_val
        f_row(t, r, 'ATR', str.tostring(atr,'0.00'))
        r := r + 1
    if show_ipo_date
        f_row(t, r, 'IPO Timer', str.tostring(ipoSince,'0.00') + 'Y')
        r := r + 1
    if show_lod_dist
        f_row(t, r, 'LoD dist.', str.tostring(lod_dist,'0') + '%')
        r := r + 1
    if show_lod_price
        f_row(t, r, 'LoD Price', str.tostring(lod_price,'0.00'))
        r := r + 1
    if show_dist_high
        f_row(t, r, 'Off 52W High', str.tostring(distFromHigh,'0.0') + '%')
        r := r + 1
    if show_dist_low
        f_row(t, r, 'Above 52W Low', '+' + str.tostring(distFromLow,'0.0') + '%')
        r := r + 1
    if show_ADVS
        f_row(t, r, 'Avg $ Vol', '$' + str.tostring(advdolDa,'0.00') + uVDoll)
        r := r + 1
    if show_ADV
        f_row(t, r, 'Avg Vol', str.tostring(avgDaVol,'0.00') + uV)
        r := r + 1
    if show_projVol
        f_row(t, r, 'Proj. Vol', str.tostring(vol_proj,'0.00') + uP)
        r := r + 1
    if show_relVol
        f_row(t, r, 'Rel. Vol', str.tostring(relVol,'0') + '%')
        r := r + 1
    if show_volBuzz
        f_row(t, r, 'Vol. Buzz', str.tostring(volBuzz,'0') + '%')
        r := r + 1
    if show_UDratio
        f_row(t, r, 'U/D Ratio', str.tostring(upDnVolRatio,'0.0'))
        r := r + 1
    if show_rs_rating
        f_row(t, r, 'RS Rating', tfDaily ? str.tostring(totalRsRating,'0.0') : '-')
        r := r + 1
    if show_liqCap
        f_row(t, r, 'Liquidity Cap', str.tostring(liquidityCap,'0'))
        r := r + 1
    if show_sector
        f_full(t, r, sector, txt_col)
        r := r + 1
    if show_selectSector
        sd = show_sector_rs ? sector_etf + ' (RS ' + str.tostring(sectorRs,'0') + ')' : sector_etf
        sc = sector_chg > 0 ? '+' + str.tostring(sector_chg,'0.00') + '%' : str.tostring(sector_chg,'0.00') + '%'
        table.cell(t, 0, r, sd, text_color=txt_col, text_size=size_tbl)
        table.cell(t, 1, r, sc, text_color=sector_chg > 0 ? sector_chg_Up : sector_chg_Dn, text_size=size_tbl)
        table.cell_set_text_halign(t, 0, r, text_halign=align_L)
        table.cell_set_text_halign(t, 1, r, text_halign=align_R)
        r := r + 1
    if show_ind
        f_full(t, r, industryGrp, txt_col)
        r := r + 1

    if show_atrMult_tbl
        table.cell(t, 0, r, '-- ATR% Multiple --', text_color=txt_col, text_size=size_tbl)
        table.cell(t, 1, r, '')
        table.merge_cells(t, 0, r, 1, r)
        table.cell_set_text_halign(t, 0, r, text_halign=text.align_center)
        r := r + 1
        f_row(t, r, 'ATR% Mult From MA', str.tostring(am_ratio,'0.00'))
        r := r + 1
        f_row(t, r, '% Gain From MA', str.tostring(am_gainMA,'0.00') + '%')
        r := r + 1
        f_row(t, r, 'ATR%', str.tostring(am_atrP,'0.00') + '%')
        r := r + 1
        if dot1_on
            table.cell(t, 0, r, 'L1: >= ' + str.tostring(dot1_thresh,'0.#') + 'x', text_color=dot1_col, text_size=size_tbl)
            table.cell(t, 1, r, '●', text_color=dot1_col, text_size=size_tbl)
            table.cell_set_text_halign(t, 0, r, text_halign=align_L)
            table.cell_set_text_halign(t, 1, r, text_halign=align_R)
            r := r + 1
        if dot2_on
            table.cell(t, 0, r, 'L2: >= ' + str.tostring(dot2_thresh,'0.#') + 'x', text_color=dot2_col, text_size=size_tbl)
            table.cell(t, 1, r, '●', text_color=dot2_col, text_size=size_tbl)
            table.cell_set_text_halign(t, 0, r, text_halign=align_L)
            table.cell_set_text_halign(t, 1, r, text_halign=align_R)
            r := r + 1
        if dot3_on
            table.cell(t, 0, r, 'L3: >= ' + str.tostring(dot3_thresh,'0.#') + 'x', text_color=dot3_col, text_size=size_tbl)
            table.cell(t, 1, r, '●', text_color=dot3_col, text_size=size_tbl)
            table.cell_set_text_halign(t, 0, r, text_halign=align_L)
            table.cell_set_text_halign(t, 1, r, text_halign=align_R)
            r := r + 1

    if add_empty_dn > 0
        table.cell(t, 0, r, '')
        r := r + 1
    if add_empty_dn > 1
        table.cell(t, 0, r, '')
        r := r + 1
    if add_empty_dn > 2
        table.cell(t, 0, r, '')
        r := r + 1
    if add_empty_dn > 3
        table.cell(t, 0, r, '')
        r := r + 1
    if add_empty_dn > 4
        table.cell(t, 0, r, '')
````
