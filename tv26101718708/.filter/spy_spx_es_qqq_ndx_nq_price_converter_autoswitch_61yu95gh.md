# SPY SPX ES / QQQ NDX NQ Price Converter (auto-switch)

- url: https://www.tradingview.com/script/61yU95GH-SPY-SPX-ES-QQQ-NDX-NQ-Price-Converter-auto-switch/
- type: indicator
- pine_id: PUB;1b1fef1f017b4807b443767ef96706d9
- version: 4.0

## Description

[b]SPY SPX ES / QQQ NDX NQ Price Converter (auto-switch)[/b]

Converts round-number price levels between SPY, SPX, ES futures, QQQ, NDX, NQ futures, and index CFDs — and switches between the S&P and Nasdaq sets automatically based on the chart you're on.

Credit where it's due: this is built on two open-source scripts by **PtGambler** — "SPY SPX ES Price Converter [Pt]" and "QQQ NDX NQ Price Converter [Pt]" — republished open-source under the Mozilla Public License 2.0, as the originals are. The conversion concept is his.

[b]What this adds[/b]

The originals are two separate indicators, one per index complex. Switching from an S&P chart to a Nasdaq chart meant swapping indicators and re-entering settings. This version is one script that reads the chart symbol and loads the matching complex automatically:

- [b]S&P[/b] — SPY, SPX, ES1!, and a configurable CFD (default SPX500USD)
- [b]Nasdaq[/b] — QQQ, NDX, NQ1!, and a configurable CFD (default NAS100USD)

Detection covers the ETF, cash index, continuous futures (including micros), and common CFD tickers. A manual override forces either complex if you want the levels on an unrelated chart, and on an unrecognized symbol the indicator draws nothing rather than showing misleading levels.

Rebuilt around four generic rows instead of two hardcoded symbol sets, so a single code path drives whichever complex is active.

[b]Other changes[/b]

- [b]Quarter marks[/b] — optional .25 / .50 / .75 stubs between the whole-dollar ETF levels, drawn as short segments at the label column rather than lines across the chart
- [b]Auto step sizing[/b] — leave a row's step at 0 and it picks 1 / 10 / 100 to match the active complex, instead of needing a manual edit on every switch
- [b]Price label omits the chart's own symbol[/b] — on ES you see SPX and SPY, not ES, whose price is already on the axis. Cash index is listed first on futures and CFD charts
- [b]Change % for all four rows[/b], each from its own prior daily close; the originals showed it for futures and the CFD only
- [b]Table rewritten[/b] — the originals addressed cells that the fill helper never wrote to, so the futures change % was colored in the wrong cell and then merged over. Fixed and restructured as symbol / price / change
- [b]Level loop rewritten[/b] as a single pass over the range, replacing the two-loop version that computed the same levels twice
- [b]Written in Pine v6[/b]

[b]Settings[/b]

Each of the four rows has its own show toggle, color, step, label offset, and line style ("None" keeps labels without lines). General settings control the level count, label text size, the last-price label, and whether conversion updates every tick or on candle close. The price table is positionable with an optional change column.

[b]Notes[/b]

SPX and NDX need index data on your TradingView plan. CFD symbols default to OANDA tickers — set the exchange prefix if your feed differs. Line count is capped at 500 per script, so enabling all four rows with a high level count plus quarter marks can hit the ceiling, at which point the oldest lines are dropped silently.

This is a price-conversion utility, not a signal or strategy. It shows where a round number on one instrument sits on another.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PtGambler — derived from "SPY SPX ES Price Converter [Pt]" and "QQQ NDX NQ Price Converter [Pt]"
// Merged version: auto-detects whether the chart is in the S&P complex (SPY/SPX/ES/SPX500USD)
// or the Nasdaq complex (QQQ/NDX/NQ/NAS100USD) and swaps the whole level set accordingly.

//@version=6
indicator("Index Price Converter [SPX/NDX auto]", shorttitle = 'IdxPx[Pt]', overlay = true, max_labels_count = 500, max_lines_count = 500)

// ─────────────────────────────────────────────────────────── groups
g_mode  = 'Complex'
g_etf   = 'ETF   (SPY / QQQ)'
g_idx   = 'Index (SPX / NDX)'
g_fut   = 'Futures (ES / NQ)'
g_cfd   = 'CFD / FX'
g_gen   = 'General'
g_table = 'Price Table'

// ─────────────────────────────────────────────────────────── inputs
mode        = input.string('Auto', 'Index complex', options = ['Auto', 'S&P 500', 'Nasdaq 100'], group = g_mode,
     tooltip = 'Auto reads the chart symbol. Falls back to the S&P complex if the symbol is unrecognized.')

update_freq = input.string('Every tick', 'Conversion frequency', ['Every tick', 'Per candle close'], group = g_gen)
levels_n    = input.int(10, '# of levels +/-', minval = 1, maxval = 50, group = g_gen)
in_txt_size = input.string('Normal', 'Label text size', options = ['Auto', 'Large', 'Normal', 'Small', 'Tiny'], group = g_gen)
show_last   = input.bool(true, 'Show last price label', group = g_gen)
hide_self   = input.bool(true, "Hide the chart's own symbol", group = g_gen,
     tooltip = 'The chart symbol needs no conversion - its prices are already on the axis - so its ' +
     'level set is normally just clutter. Untick to draw it anyway as plain round-number levels ' +
     '(useful on SPY/QQQ for the quarter marks).')

// ETF row -------------------------------------------------------------------
use_etf   = input.bool(true, 'Show', inline = 'etf1', group = g_etf)
etf_step_i= input.float(0, '| Step (0 = auto)', minval = 0, step = 0.5, inline = 'etf1', group = g_etf)
etf_col   = input.color(color.fuchsia, '', inline = 'etf1', group = g_etf)
etf_base  = input.int(1, 'Round base', minval = 1, inline = 'etf2', group = g_etf)
etf_off   = input.int(50, '| Offset', step = 10, inline = 'etf2', group = g_etf)
etf_ls_i  = input.string('Dashed', '| Line', options = ['Solid', 'Dashed', 'Dotted', 'None'], inline = 'etf2', group = g_etf)
etf_qtr   = input.bool(true, 'Quarter marks (.25 / .50 / .75)', inline = 'etf3', group = g_etf)
qtr_len   = input.int(8, '| Length (bars)', minval = 1, maxval = 100, inline = 'etf3', group = g_etf)
etf_spx_i = input.symbol('AMEX:SPY',   'S&P ETF symbol', group = g_etf)
etf_ndx_i = input.symbol('NASDAQ:QQQ', 'Nasdaq ETF symbol', group = g_etf)
etf_ext   = input.bool(true, 'Include extended hours', group = g_etf,
     tooltip = 'request.security() uses a symbol\'s REGULAR session unless told otherwise, so ' +
     'without this the ETF price is frozen at the 4pm close all night while a futures chart ' +
     'keeps trading. Untick to go back to regular-hours-only.')

// Index row -----------------------------------------------------------------
use_idx   = input.bool(false, 'Show', inline = 'idx1', group = g_idx)
idx_step_i= input.float(0, '| Step (0 = auto)', minval = 0, step = 5, inline = 'idx1', group = g_idx)
idx_col   = input.color(color.yellow, '', inline = 'idx1', group = g_idx)
idx_off   = input.int(100, 'Offset', step = 10, inline = 'idx2', group = g_idx)
idx_ls_i  = input.string('Dashed', '| Line', options = ['Solid', 'Dashed', 'Dotted', 'None'], inline = 'idx2', group = g_idx)

// Futures row ---------------------------------------------------------------
use_fut   = input.bool(false, 'Show', inline = 'fut1', group = g_fut)
fut_step_i= input.float(0, '| Step (0 = auto)', minval = 0, step = 5, inline = 'fut1', group = g_fut)
fut_col   = input.color(color.orange, '', inline = 'fut1', group = g_fut)
fut_off   = input.int(150, 'Offset', step = 10, inline = 'fut2', group = g_fut)
fut_ls_i  = input.string('Dashed', '| Line', options = ['Solid', 'Dashed', 'Dotted', 'None'], inline = 'fut2', group = g_fut)

// CFD row -------------------------------------------------------------------
use_cfd   = input.bool(false, 'Show', inline = 'cfd1', group = g_cfd)
cfd_step_i= input.float(0, '| Step (0 = auto)', minval = 0, step = 5, inline = 'cfd1', group = g_cfd)
cfd_col   = input.color(color.aqua, '', inline = 'cfd1', group = g_cfd)
cfd_spx   = input.symbol('SPX500USD', 'S&P CFD symbol', group = g_cfd)
cfd_ndx   = input.symbol('NAS100USD', 'Nasdaq CFD symbol', group = g_cfd)
cfd_off   = input.int(200, 'Offset', step = 10, inline = 'cfd2', group = g_cfd)
cfd_ls_i  = input.string('Dashed', '| Line', options = ['Solid', 'Dashed', 'Dotted', 'None'], inline = 'cfd2', group = g_cfd)

// Table ---------------------------------------------------------------------
show_table    = input.bool(true, 'Show prices', group = g_table, inline = 'tbl')
tableLocation = input.string('Top right', options = ['Top left', 'Top center', 'Top right', 'Bottom left', 'Bottom center', 'Bottom right'], title = '| Location', group = g_table, inline = 'tbl')
tbl_font      = input.string('Normal', '    └ Font size', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large'], group = g_table)
show_chg      = input.bool(true, 'Show price change %', group = g_table)

tablePosition = tableLocation == 'Top left' ? position.top_left : tableLocation == 'Top center' ? position.top_center : tableLocation == 'Top right' ? position.top_right : tableLocation == 'Bottom left' ? position.bottom_left : tableLocation == 'Bottom center' ? position.bottom_center : position.bottom_right

text_size = switch in_txt_size
    'Auto'   => size.auto
    'Large'  => size.large
    'Normal' => size.normal
    'Small'  => size.small
    'Tiny'   => size.tiny
    => size.normal          // v6: switch returning a unique type needs a default block

f_lineStyle(_s) =>
    switch _s
        'Solid'  => line.style_solid
        'Dotted' => line.style_dotted
        => line.style_dashed

etf_ls = f_lineStyle(etf_ls_i)
idx_ls = f_lineStyle(idx_ls_i)
fut_ls = f_lineStyle(fut_ls_i)
cfd_ls = f_lineStyle(cfd_ls_i)

// 'None' hides the lines but keeps the labels
etf_draw = etf_ls_i != 'None'
idx_draw = idx_ls_i != 'None'
fut_draw = fut_ls_i != 'None'
cfd_draw = cfd_ls_i != 'None'

// ─────────────────────────────────────────────── complex detection
// syminfo.ticker is a simple string, so everything derived from it stays
// simple and can be fed to request.security() as the symbol argument.
sym = str.upper(syminfo.ticker)

// An ES/NQ prefix alone is not enough: ESTC, ESS, ESAB, ESNT and NQ-prefixed
// equities would all be read as index futures and light the whole thing up on
// an unrelated stock. Require the instrument to actually be a future.
isFut = syminfo.type == 'futures' or str.contains(sym, '!')

// Micro contracts quote the same index value as their full-size counterparts
// (MES $5/pt against ES $50/pt, MNQ $2/pt against NQ $20/pt), so only the
// contract name differs and nothing about the conversion changes. Following the
// chart also means a micro symbol is only ever requested on a chart already
// showing it, so this can never ask for data the user is not entitled to.
isMicro = isFut and (str.startswith(sym, 'MES') or str.startswith(sym, 'MNQ'))

auto_ndx = str.contains(sym, 'QQQ') or str.contains(sym, 'NDX') or str.contains(sym, 'NDQ') or str.contains(sym, 'NAS100') or str.contains(sym, 'US100') or str.contains(sym, 'USTEC') or (isFut and (str.startswith(sym, 'NQ') or str.startswith(sym, 'MNQ')))

auto_spx = str.contains(sym, 'SPY') or str.contains(sym, 'SPX') or str.contains(sym, 'SP500') or str.contains(sym, 'US500') or (isFut and (str.startswith(sym, 'ES') or str.startswith(sym, 'MES')))

isNDX = mode == 'Auto' ? (auto_ndx and not auto_spx) : mode == 'Nasdaq 100'

// The chart symbol belongs to one of the two complexes. On Auto, an unrecognized
// symbol draws nothing at all; picking a complex manually forces the display on.
symKnown = auto_ndx or auto_spx
active   = mode != 'Auto' or symKnown

etf_tid = isNDX ? etf_ndx_i : etf_spx_i
etf_sym = str.contains(etf_tid, ':') ? array.get(str.split(etf_tid, ':'), 1) : etf_tid
etf_req = etf_ext ? ticker.modify(etf_tid, session.extended) : etf_tid
idx_sym = isNDX ? 'NDX'  : 'SPX'
fut_sym = isNDX ? (isMicro ? 'MNQ1!' : 'NQ1!') : (isMicro ? 'MES1!' : 'ES1!')
cfd_sym = isNDX ? cfd_ndx : cfd_spx
cfd_lbl = str.contains(cfd_sym, ':') ? array.get(str.split(cfd_sym, ':'), 1) : cfd_sym

// Which session each row's number actually covers. request.security() reads a
// symbol's REGULAR session unless handed an extended ticker, and Pine has no
// constant for the overnight/24h feed at all: ticker.new() and ticker.modify()
// accept only session.regular and session.extended, and a session string cannot
// substitute for one - strings test whether a bar sits in a window, types decide
// which bars are fetched. So EXT is as far as an ETF row reaches, roughly
// 04:00-20:00 ET, and it goes dark overnight.
etf_ses = etf_ext ? 'EXT' : 'RTH'
idx_ses = 'RTH'                     // cash index, not calculated outside RTH
fut_ses = '24x5'
cfd_ses = '24x5'

// auto steps: 1 for the ETF, 10 for SPX-side, 100 for NDX-side
big_step = isNDX ? 100.0 : 10.0
etf_step = etf_step_i == 0 ? 1.0      : etf_step_i
idx_step = idx_step_i == 0 ? big_step : idx_step_i
fut_step = fut_step_i == 0 ? big_step : fut_step_i
cfd_step = cfd_step_i == 0 ? big_step : cfd_step_i

// ───────────────────────────────────── which row is the chart itself?
// Used both to suppress that row's levels and to pin its conversion ratio to 1.
isEtfChart = sym == etf_sym
isIdxChart = sym == idx_sym
isFutChart = isFut and (str.startswith(sym, 'ES') or str.startswith(sym, 'MES') or str.startswith(sym, 'NQ') or str.startswith(sym, 'MNQ'))
isCfdChart = sym == str.upper(cfd_lbl) or str.contains(sym, '500') or str.contains(sym, '100') or str.contains(sym, 'USTEC')

// ─────────────────────────────────────────────────────────── data
t1 = time(timeframe.period, '0930-1600:23456', 'America/New_York')

etf_price = request.security(etf_req, timeframe.period, math.round_to_mintick(close))
etf_pdc   = request.security(etf_tid, '1D', close[1])
idx_price = request.security(idx_sym, timeframe.period, math.round_to_mintick(close))
idx_pdc   = request.security(idx_sym, '1D', close[1])
// v6: `t1` is an int, no implicit cast to bool — "last bar was in session, this one isn't"
sessionJustEnded = not na(t1[1]) and na(t1)
[fut_price, fut_pdc] = request.security(fut_sym, timeframe.period, [math.round_to_mintick(close), ta.valuewhen(sessionJustEnded, open, 0)])
cfd_price = request.security(cfd_sym, timeframe.period, math.round_to_mintick(close))
cfd_pdc   = request.security(cfd_sym, '1D', close[1])

f_pct(_p, _prev) => na(_prev) or _prev == 0 ? na : (_p - _prev) / _prev * 100

etf_chg = f_pct(etf_price, etf_pdc)
idx_chg = f_pct(idx_price, idx_pdc)
fut_chg = f_pct(fut_price, fut_pdc)
cfd_chg = f_pct(cfd_price, cfd_pdc)

// closing price during regular hours (used for the cash-session symbols)
close_price     = close
inSession       = not na(t1)
regular_close_0 = ta.valuewhen(inSession, close, 0)
regular_close   = inSession ? close : regular_close_0

// A conversion ratio is only meaningful if both sides are read at the same
// instant. Rather than assume that instant is the RTH close, take the chart's
// close from whenever the ETF last actually moved.
etf_upd = nz(ta.change(etf_price), 0) != 0
etf_ref = nz(ta.valuewhen(etf_upd, close, 0), close)

// nearest round base for each symbol
etf_p0 = math.floor(etf_price / etf_base) * etf_base
idx_p0 = math.floor(idx_price / idx_step) * idx_step
fut_p0 = math.floor(fut_price / fut_step) * fut_step
cfd_p0 = math.floor(cfd_price / cfd_step) * cfd_step

var etf_lines = array.new_line()
var idx_lines = array.new_line()
var fut_lines = array.new_line()
var cfd_lines = array.new_line()
var etf_lbls  = array.new_label()
var idx_lbls  = array.new_label()
var fut_lbls  = array.new_label()
var cfd_lbls  = array.new_label()

// ─────────────────────────────────────────────────────── functions
f_setLevels(_name, _lineArr, _lblArr, _basePrice, _altPrice, _step, _qtr, _offset, _color, _linestyle, _draw, _refPrice, _isSelf) =>
    _price = _refPrice
    if not na(_altPrice) and _altPrice != 0 and not na(_price)
        // The chart's own symbol converts to itself, so the ratio is 1 by
        // definition. Computing it would divide a session-frozen close by a
        // live extended-hours price and shift every level off its round number.
        ratio = _isSelf ? 1.0 : _price / _altPrice
        qtrCol = color.new(_color, 25)
        for i = -levels_n to levels_n
            altLvl = _basePrice + i * _step
            px     = altLvl * ratio
            if _draw
                array.push(_lineArr, line.new(bar_index, px, bar_index + 1, px, xloc.bar_index, extend.both, _color, _linestyle, 1))
            array.push(_lblArr, label.new(bar_index + _offset, px, _name + ' ' + str.tostring(altLvl), xloc = xloc.bar_index, color = color.new(chart.bg_color, 50), style = label.style_label_left, textcolor = _color, size = text_size, textalign = text.align_left))

            // quarter marks — short stubs starting at the label anchor, so they
            // share the same column as the price labels
            if _qtr and i < levels_n
                for j = 1 to 3
                    qPx = (altLvl + j * _step / 4) * ratio
                    array.push(_lineArr, line.new(bar_index + _offset, qPx, bar_index + _offset + qtr_len, qPx, xloc.bar_index, extend.none, qtrCol, line.style_solid, 1))

f_drawLabelX(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip) =>
    var id = label.new(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip)
    label.set_xy(id, _x, _y)
    label.set_text(id, _text)
    label.set_tooltip(id, _tooltip)
    label.set_textcolor(id, _textcolor)
    id

f_clearLines(_array) =>
    while array.size(_array) > 0
        line.delete(array.shift(_array))

f_clearLabels(_array) =>
    while array.size(_array) > 0
        label.delete(array.shift(_array))

// ───────────────────────────────────────────── last price label text
// The label lists every symbol in the complex except the chart's own, whose price
// is already on the axis. Independent of the Show checkboxes — those gate the
// level lines, not this readout.
t_etf = isEtfChart ? '' : etf_sym + ' ' + str.tostring(etf_price) + '  ' + etf_ses + '\n'
t_idx = isIdxChart ? '' : idx_sym + ' ' + str.tostring(idx_price) + '  ' + idx_ses + '\n'
t_fut = isFutChart ? '' : fut_sym + ' ' + str.tostring(fut_price) + '  ' + fut_ses + '\n'
t_cfd = isCfdChart ? '' : cfd_lbl + ' ' + str.tostring(cfd_price) + '  ' + cfd_ses + '\n'

// Cash market first — on ES that's SPX, then SPY.
price_text = isFutChart or isCfdChart ? t_idx + t_etf + t_fut + t_cfd : isIdxChart ? t_etf + t_fut + t_cfd + t_idx : t_idx + t_fut + t_cfd + t_etf

// ─────────────────────────────────────────────────────────── main
if active and (update_freq == 'Per candle close' ? barstate.isconfirmed : barstate.islast)
    f_clearLines(etf_lines)
    f_clearLines(idx_lines)
    f_clearLines(fut_lines)
    f_clearLines(cfd_lines)
    f_clearLabels(etf_lbls)
    f_clearLabels(idx_lbls)
    f_clearLabels(fut_lbls)
    f_clearLabels(cfd_lbls)

    if show_last
        f_drawLabelX(bar_index, close, price_text, xloc.bar_index, yloc.price, color.new(chart.bg_color, 70), label.style_label_left, chart.fg_color, size.normal, text.align_left, '')

    if use_etf and not (hide_self and isEtfChart)
        f_setLevels(etf_sym, etf_lines, etf_lbls, etf_p0, etf_price, etf_step, etf_qtr, etf_off, etf_col, etf_ls, etf_draw, etf_ref, isEtfChart)
    if use_idx and not (hide_self and isIdxChart)
        f_setLevels(idx_sym, idx_lines, idx_lbls, idx_p0, idx_price, idx_step, false, idx_off, idx_col, idx_ls, idx_draw, regular_close, isIdxChart)
    if use_fut and not (hide_self and isFutChart)
        f_setLevels(fut_sym, fut_lines, fut_lbls, fut_p0, fut_price, fut_step, false, fut_off, fut_col, fut_ls, fut_draw, close_price, isFutChart)
    if use_cfd and not (hide_self and isCfdChart)
        f_setLevels(cfd_lbl, cfd_lines, cfd_lbls, cfd_p0, cfd_price, cfd_step, false, cfd_off, cfd_col, cfd_ls, cfd_draw, close_price, isCfdChart)

// ────────────────────────────────────────────────────────── table
var displayTable = table.new(tablePosition, 3, 5, border_width = 1)

f_fillCell(_row, _col, series string _txt, series color _tcol) =>
    switch tbl_font
        'Auto'   => table.cell(displayTable, _col, _row, _txt, bgcolor = color.new(chart.bg_color, 50), text_color = _tcol, text_halign = text.align_left, text_valign = text.align_center, text_size = size.auto)
        'Tiny'   => table.cell(displayTable, _col, _row, _txt, bgcolor = color.new(chart.bg_color, 50), text_color = _tcol, text_halign = text.align_left, text_valign = text.align_center, text_size = size.tiny)
        'Small'  => table.cell(displayTable, _col, _row, _txt, bgcolor = color.new(chart.bg_color, 50), text_color = _tcol, text_halign = text.align_left, text_valign = text.align_center, text_size = size.small)
        'Normal' => table.cell(displayTable, _col, _row, _txt, bgcolor = color.new(chart.bg_color, 50), text_color = _tcol, text_halign = text.align_left, text_valign = text.align_center, text_size = size.normal)
        'Large'  => table.cell(displayTable, _col, _row, _txt, bgcolor = color.new(chart.bg_color, 50), text_color = _tcol, text_halign = text.align_left, text_valign = text.align_center, text_size = size.large)
        => table.cell(displayTable, _col, _row, _txt, bgcolor = color.new(chart.bg_color, 50), text_color = _tcol, text_halign = text.align_left, text_valign = text.align_center, text_size = size.normal)

f_chgTxt(_pct) => na(_pct) ? 'n/a' : (_pct >= 0 ? '+' : '') + str.tostring(_pct, '#.##') + '%'
f_chgCol(_pct) => na(_pct) ? chart.fg_color : _pct >= 0 ? color.green : color.red

if barstate.islast and show_table and active
    f_fillCell(0, 0, isNDX ? 'NDX cplx' : 'SPX cplx', chart.fg_color)
    f_fillCell(0, 1, 'Price', chart.fg_color)

    f_fillCell(1, 0, etf_sym + '  ' + etf_ses, etf_col)
    f_fillCell(2, 0, idx_sym + '  ' + idx_ses, idx_col)
    f_fillCell(3, 0, fut_sym + '  ' + fut_ses, fut_col)
    f_fillCell(4, 0, cfd_lbl + '  ' + cfd_ses, cfd_col)

    f_fillCell(1, 1, str.tostring(etf_price), chart.fg_color)
    f_fillCell(2, 1, str.tostring(idx_price), chart.fg_color)
    f_fillCell(3, 1, str.tostring(fut_price), chart.fg_color)
    f_fillCell(4, 1, str.tostring(cfd_price), chart.fg_color)

    if show_chg
        f_fillCell(0, 2, 'Chg', chart.fg_color)
        f_fillCell(1, 2, f_chgTxt(etf_chg), f_chgCol(etf_chg))
        f_fillCell(2, 2, f_chgTxt(idx_chg), f_chgCol(idx_chg))
        f_fillCell(3, 2, f_chgTxt(fut_chg), f_chgCol(fut_chg))
        f_fillCell(4, 2, f_chgTxt(cfd_chg), f_chgCol(cfd_chg))
````
