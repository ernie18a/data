# ZH

- url: https://www.tradingview.com/script/Ta4WRoSv-ZH/
- type: indicator
- pine_id: PUB;35c7ddd512a542c4a34e4e7ad879346c
- version: 1.0

## Description

Here's a publishable summary for your ZH indicator:

---

**ZH — EP Trading Dashboard**

An all-in-one overlay built for Episodic Pivot traders. Combines a clean moving average stack, session VWAP, and a live data panel surfacing the metrics that matter most when evaluating a gap-up candidate.

**Moving Averages**
Plots the 10 EMA, 20 EMA, 50 SMA, 100 SMA, and 200 SMA with fully customizable colors. A timeframe filter lets you choose where they appear — all timeframes, intraday only, daily only, daily & weekly, or weekly & above — so your chart stays uncluttered.

**VWAP**
Session-anchored VWAP based on HLC/3, plotted intraday only, no bands. Resets each new day for a clean read on where volume-weighted value sits during the session.

**EP Data Panel (bottom-right)**
A compact stats table showing the key characteristics of an EP setup, all locked to daily values regardless of your chart timeframe:
- Market Cap (flags red under $40M)
- Share Float
- ADR% (14-period)
- ATR (14-period)
- VOL — daily volume (highlights above 8.9M)
- RVOL 90 — volume vs. 90-day average (highlights above 300%)
- $ VOL — dollar volume, color-tiered at $100M, $500M, and $1B

**Market Context Panel (top-right)**
- QQQ — daily % change, green/red
- BRD — market breadth via ATHI/ATLO, green/red

**Customization**
Adjustable text size, background, text color, volume highlight thresholds, and spacing.

Designed to keep the essential neglected-stock-plus-catalyst-plus-volume read visible at a glance, without cluttering the chart.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © htflagz

//@version=6
indicator(title = 'ZH', shorttitle = 'ZH', overlay = true, max_bars_back = 253)

// =============================================================================
// ZH MMA
// =============================================================================

grp_mma     = 'Moving Averages'
show_mma    = input.bool(true, title = 'Show Moving Averages', group = grp_mma)
mma_tf      = input.string('Daily Only', title = 'Show On Timeframe', options = ['All', 'Intraday Only', 'Daily Only', 'Daily & Weekly', 'Weekly & Above'], group = grp_mma)
col_10ema   = input.color(color.white,  title = '10 EMA Color',  group = grp_mma)
col_20ema   = input.color(color.yellow, title = '20 EMA Color',  group = grp_mma)
col_50sma   = input.color(color.green,  title = '50 SMA Color',  group = grp_mma)
col_100sma  = input.color(color.red,    title = '100 SMA Color', group = grp_mma)
col_200sma  = input.color(color.blue,   title = '200 SMA Color', group = grp_mma)

ema10  = ta.ema(close, 10)
ema20  = ta.ema(close, 20)
sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)

_is_intraday = timeframe.isintraday
_is_daily    = timeframe.isdaily
_is_weekly   = timeframe.isweekly or timeframe.ismonthly

mma_tf_visible = switch mma_tf
    'All'            => true
    'Intraday Only'  => _is_intraday
    'Daily Only'     => _is_daily
    'Daily & Weekly' => _is_daily or _is_weekly
    'Weekly & Above' => _is_weekly
    => true

mma_visible = show_mma and mma_tf_visible

plot(ema10,  title = '10 EMA',  color = mma_visible ? col_10ema  : na, linewidth = 1)
plot(ema20,  title = '20 EMA',  color = mma_visible ? col_20ema  : na, linewidth = 1)
plot(sma50,  title = '50 SMA',  color = mma_visible ? col_50sma  : na, linewidth = 1)
plot(sma100, title = '100 SMA', color = mma_visible ? col_100sma : na, linewidth = 1)
plot(sma200, title = '200 SMA', color = mma_visible ? col_200sma : na, linewidth = 1)

// =============================================================================
// ZH VWAP — HLC/3, session anchor, intraday only, no bands
// =============================================================================

vwap_src = hlc3

cumVolume = ta.cum(volume)
if barstate.islast and cumVolume == 0
    runtime.error("No volume is provided by the data vendor.")

vwap_isNewPeriod = timeframe.change("D")
if na(vwap_src[1])
    vwap_isNewPeriod := true

float vwapValue = na
if timeframe.isintraday
    [_vwap, _, _] = ta.vwap(vwap_src, vwap_isNewPeriod, 1)
    vwapValue := _vwap

plot(vwapValue, title = 'VWAP', color = color.white, linewidth = 1)

// =============================================================================
// ZH EP DATA
// =============================================================================

grp_layout  = 'Layout & Style'
tbl_size    = input.string('Small', title = 'Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = grp_layout)
bg_col      = input.color(color.new(color.black, 100), title = 'Background Color', group = grp_layout)
txt_col     = input.color(color.orange, title = 'Text Color', group = grp_layout)

grp_vol_col = 'Volume Colors'
col_vol_hi   = input.color(color.green,  title = 'VOL Color (> 8.9M)',        group = grp_vol_col)
col_rvol_hi  = input.color(color.green,  title = 'RVOL 90 Color (> 300%)',    group = grp_vol_col)
col_dvol_100 = input.color(color.yellow, title = '$ VOL Color (> $100M)',     group = grp_vol_col)
col_dvol_500 = input.color(color.orange, title = '$ VOL Color (> $500M)',     group = grp_vol_col)
col_dvol_1b  = input.color(color.red,    title = '$ VOL Color (> $1B)',       group = grp_vol_col)

grp_spacing = 'Spacing'
empty_rows_br = input.int(1, title = 'Empty Rows Below Bottom Block', minval = 0, maxval = 10, group = grp_spacing)

s = syminfo.tickerid

// Market Cap
MCapRaw = request.financial(s, 'MARKET_CAP_BASIC', 'D', ignore_invalid_symbol = true)
if na(MCapRaw)
    MCapRaw := syminfo.shares_outstanding_total * close

// Float
sharesFloat = syminfo.shares_outstanding_float

// ADR% and ATR — always daily, regardless of chart timeframe
adrp = request.security(s, 'D', 100 * ta.sma(high - low, 14) / close)
atr  = request.security(s, 'D', ta.atr(14))

// Daily volume data — locked to daily bar regardless of chart timeframe
volDa   = request.security(s, 'D', volume, lookahead = barmerge.lookahead_on)
closeDa = request.security(s, 'D', close,  lookahead = barmerge.lookahead_on)

// Dollar Volume
dollarVol = volDa * closeDa

// RVOL 90 — share volume based
avgVol90  = request.security(s, 'D', ta.sma(volume, 90), lookahead = barmerge.lookahead_on)
rvol90    = not na(volDa) and not na(avgVol90) and avgVol90 > 0 ? (volDa / avgVol90) * 100 : na

// QQQ
qqqClose = request.security('QQQ', 'D', close)
qqqPrev  = request.security('QQQ', 'D', close[1])
qqqPct   = not na(qqqClose) and not na(qqqPrev) and qqqPrev != 0 ? (qqqClose - qqqPrev) / qqqPrev * 100 : na

// Breadth
athiClose = request.security('ATHI.US', '1', close)
atloClose = request.security('ATLO.US', '1', close)
breadth   = not na(athiClose) and not na(atloClose) and atloClose != 0 ? (athiClose - atloClose) / atloClose * 100 : na

fmt_num(val) =>
    val >= 1000000000 ? str.tostring(val / 1000000000, '0.00') + 'B' :
     val >= 1000000  ? str.tostring(val / 1000000,    '0.00') + 'M' :
     val >= 1000     ? str.tostring(val / 1000,       '0.00') + 'K' :
     str.tostring(val, '0.00')

tbl_sz = switch tbl_size
    'Tiny'   => size.tiny
    'Small'  => size.small
    'Normal' => size.normal
    'Large'  => size.large
    => size.small

col_qqq = not na(qqqPct) ? (qqqPct > 0 ? color.green : color.red) : txt_col
col_brd = not na(breadth) ? (breadth > 0 ? color.green : color.red) : txt_col

var table t_top = table.new(position.top_right, 2, 2, bgcolor = bg_col, border_width = 0, frame_width = 0)

if barstate.islast
    qqq_str = not na(qqqPct) ? (qqqPct > 0 ? '+' : '') + str.tostring(qqqPct, '0.00') + '%' : 'N/A'
    brd_str = not na(breadth) ? (breadth > 0 ? '+' : '') + str.tostring(breadth, '0.00') + '%' : 'N/A'

    table.cell(t_top, 0, 0, 'QQQ',   text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_top, 1, 0, 'BRD',   text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_top, 0, 1, qqq_str, text_color = col_qqq, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_top, 1, 1, brd_str, text_color = col_brd, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)

var table t_br = table.new(position.bottom_right, 3, 15, bgcolor = bg_col, border_width = 0, frame_width = 0)

if barstate.islast
    row = 0

    // Market Cap / Float / ADR% / ATR — merge cols 0+1 for label, col 2 for value, tight right-aligned
    col_mcap = MCapRaw < 40000000 ? color.red : txt_col
    table.cell(t_br, 0, row, 'Market Cap',     text_color = txt_col,  bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    table.merge_cells(t_br, 0, row, 1, row)
    table.cell(t_br, 2, row, fmt_num(MCapRaw),  text_color = col_mcap, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    row += 1

    table.cell(t_br, 0, row, 'Share Float',       text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    table.merge_cells(t_br, 0, row, 1, row)
    table.cell(t_br, 2, row, fmt_num(sharesFloat),  text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    row += 1

    table.cell(t_br, 0, row, 'ADR%',                            text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    table.merge_cells(t_br, 0, row, 1, row)
    table.cell(t_br, 2, row, str.tostring(adrp, '0.00') + '%',  text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    row += 1

    table.cell(t_br, 0, row, 'ATR',                    text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    table.merge_cells(t_br, 0, row, 1, row)
    table.cell(t_br, 2, row, str.tostring(atr, '0.00'), text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_right)
    row += 1

    table.cell(t_br, 0, row, '', bgcolor = bg_col)
    table.merge_cells(t_br, 0, row, 2, row)
    row += 1

    // VOL | RVOL 90 | $ VOL
    rvol_str  = not na(rvol90)  ? str.tostring(rvol90,  '0.00') + '%' : 'N/A'
    col_vol   = not na(volDa) and volDa > 8900000  ? col_vol_hi   : txt_col
    col_rvol  = not na(rvol90) and rvol90 > 300    ? col_rvol_hi  : txt_col
    col_dvol  = dollarVol >= 1000000000 ? col_dvol_1b : dollarVol >= 500000000 ? col_dvol_500 : dollarVol >= 100000000 ? col_dvol_100 : txt_col

    table.cell(t_br, 0, row, 'VOL',     text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_br, 1, row, 'RVOL 90', text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_br, 2, row, '$ VOL',   text_color = txt_col, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    row += 1

    table.cell(t_br, 0, row, fmt_num(volDa),           text_color = col_vol,  bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_br, 1, row, rvol_str,                 text_color = col_rvol, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    table.cell(t_br, 2, row, '$' + fmt_num(dollarVol), text_color = col_dvol, bgcolor = bg_col, text_size = tbl_sz, text_halign = text.align_center)
    row += 1

    for i = 0 to empty_rows_br - 1
        table.cell(t_br, 0, row, '', bgcolor = bg_col)
        table.cell(t_br, 1, row, '', bgcolor = bg_col)
        table.cell(t_br, 2, row, '', bgcolor = bg_col)
        row += 1
````
