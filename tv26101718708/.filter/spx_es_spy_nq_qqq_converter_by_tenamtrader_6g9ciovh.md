# SPX | ES | SPY | NQ | QQQ Converter by TenAMTrader

- url: https://www.tradingview.com/script/6g9ciOvH-SPX-ES-SPY-NQ-QQQ-Converter-by-TenAMTrader/
- type: indicator
- pine_id: PUB;81b4f36e84854aad803b422eb4c4c799
- version: 1.0

## Description

SPX | ES | SPY | NQ | QQQ Converter by TenAMTrader

A lightweight overlay table that displays real-time price, point change, and percentage change for your key S&P 500 and Nasdaq instruments — all in one glance, right on your chart.
Built to sit cleanly at the top of your SPX chart without cluttering your view. All instruments are pulled from the daily timeframe so change values always reflect the true day's move, regardless of what intraday timeframe your chart is set to.
Always displayed:

SPX (S&P 500 Index)
ES (E-mini S&P 500 Futures)
SPY (S&P 500 ETF)

Optional — toggle on/off in settings:

NQ (E-mini Nasdaq 100 Futures)
QQQ (Nasdaq 100 ETF)

Each row shows:

Live price
Point change vs. prior day's close
Percentage change vs. prior day's close

Color coded green/red on all values for instant readability. Designed for traders who need quick cross-instrument reference without switching charts or windows.
Settings:

Position — Top Right / Top Left / Top Center
Text Size — Tiny / Small / Normal / Large
Instruments — Toggle NQ and QQQ on or off (default off)


This script is for informational purposes only and does not constitute financial advice. All data is provided as-is with no guarantee of accuracy or timeliness. Past performance is not indicative of future results. Trading involves substantial risk of loss and is not suitable for all investors. The author assumes no liability for any trading decisions made based on this tool. Always do your own research and consult a qualified financial advisor before making any investment decisions.

## Source Code

````pine
//@version=6
indicator('SPX | ES | SPY | NQ | QQQ Converter by TenAMTrader', shorttitle = 'SPX / ES / SPY Converter', overlay = true)

// ─────────────────────────────────────────────
//  Settings
// ─────────────────────────────────────────────
var GRP = 'Display'
tbl_pos = input.string('Top Right', 'Position', options = ['Top Right', 'Top Left', 'Top Center'], group = GRP)
tbl_size = input.string('Normal', 'Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = GRP)

var GRP2 = 'Instruments'
show_nq = input.bool(false, 'Show NQ  (E-mini Nasdaq Futures)', group = GRP2)
show_qqq = input.bool(false, 'Show QQQ (Nasdaq ETF)', group = GRP2)

// ─────────────────────────────────────────────
//  Data feeds — all on Daily so change is
//  always vs. prior day's close
// ─────────────────────────────────────────────
spx = request.security('SP:SPX', 'D', close)
spx_prev = request.security('SP:SPX', 'D', close[1])

es = request.security('CME_MINI:ES1!', 'D', close)
es_prev = request.security('CME_MINI:ES1!', 'D', close[1])

spy = request.security('AMEX:SPY', 'D', close)
spy_prev = request.security('AMEX:SPY', 'D', close[1])

nq = request.security('CME_MINI:NQ1!', 'D', close)
nq_prev = request.security('CME_MINI:NQ1!', 'D', close[1])

qqq = request.security('NASDAQ:QQQ', 'D', close)
qqq_prev = request.security('NASDAQ:QQQ', 'D', close[1])

spx_chg = spx - spx_prev
es_chg = es - es_prev
spy_chg = spy - spy_prev
nq_chg = nq - nq_prev
qqq_chg = qqq - qqq_prev

spx_pct = spx_chg / spx_prev * 100
es_pct = es_chg / es_prev * 100
spy_pct = spy_chg / spy_prev * 100
nq_pct = nq_chg / nq_prev * 100
qqq_pct = qqq_chg / qqq_prev * 100

// ─────────────────────────────────────────────
//  Helpers
// ─────────────────────────────────────────────
pos() =>
    tbl_pos == 'Top Right' ? position.top_right : tbl_pos == 'Top Left' ? position.top_left : position.top_center

sz() =>
    tbl_size == 'Tiny' ? size.tiny : tbl_size == 'Small' ? size.small : tbl_size == 'Large' ? size.large : size.normal

color_of(chg) =>
    chg >= 0 ? color.new(#00c853, 0) : color.new(#ff1744, 0)
chg_str(v) =>
    (v >= 0 ? '+' : '') + str.tostring(v, '#.##')
pct_str(v) =>
    (v >= 0 ? '+' : '') + str.tostring(v, '#.##') + '%'

// ─────────────────────────────────────────────
//  Dynamic row count based on toggles
// ─────────────────────────────────────────────
total_rows = 4 + (show_nq ? 1 : 0) + (show_qqq ? 1 : 0)

// ─────────────────────────────────────────────
//  Table
// ─────────────────────────────────────────────
var table t = table.new(pos(), 4, 6, border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1, bgcolor = color.new(#0d1117, 10))

if barstate.islast
    // Header
    table.cell(t, 0, 0, '', text_color = color.new(color.gray, 30), text_size = sz(), bgcolor = color.new(#161b22, 5))
    table.cell(t, 1, 0, 'PRICE', text_color = color.new(color.gray, 20), text_size = sz(), bgcolor = color.new(#161b22, 5), text_halign = text.align_right)
    table.cell(t, 2, 0, 'CHG', text_color = color.new(color.gray, 20), text_size = sz(), bgcolor = color.new(#161b22, 5), text_halign = text.align_right)
    table.cell(t, 3, 0, '%', text_color = color.new(color.gray, 20), text_size = sz(), bgcolor = color.new(#161b22, 5), text_halign = text.align_right)

    // SPX — always row 1
    table.cell(t, 0, 1, ' SPX ', text_color = color.new(#58a6ff, 0), text_size = sz(), bgcolor = color.new(#0d1117, 10))
    table.cell(t, 1, 1, str.tostring(spx, '#.##'), text_color = color_of(spx_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
    table.cell(t, 2, 1, chg_str(spx_chg), text_color = color_of(spx_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
    table.cell(t, 3, 1, pct_str(spx_pct), text_color = color_of(spx_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

    // ES — always row 2
    table.cell(t, 0, 2, ' ES  ', text_color = color.new(#f0a500, 0), text_size = sz(), bgcolor = color.new(#0d1117, 10))
    table.cell(t, 1, 2, str.tostring(es, '#.##'), text_color = color_of(es_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
    table.cell(t, 2, 2, chg_str(es_chg), text_color = color_of(es_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
    table.cell(t, 3, 2, pct_str(es_pct), text_color = color_of(es_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

    // SPY — always row 3
    table.cell(t, 0, 3, ' SPY ', text_color = color.new(#3fb950, 0), text_size = sz(), bgcolor = color.new(#0d1117, 10))
    table.cell(t, 1, 3, str.tostring(spy, '#.##'), text_color = color_of(spy_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
    table.cell(t, 2, 3, chg_str(spy_chg), text_color = color_of(spy_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
    table.cell(t, 3, 3, pct_str(spy_pct), text_color = color_of(spy_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

    // NQ — optional row 4
    nq_row = 4
    if show_nq
        table.cell(t, 0, nq_row, ' NQ  ', text_color = color.new(#d2a8ff, 0), text_size = sz(), bgcolor = color.new(#0d1117, 10))
        table.cell(t, 1, nq_row, str.tostring(nq, '#.##'), text_color = color_of(nq_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 2, nq_row, chg_str(nq_chg), text_color = color_of(nq_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 3, nq_row, pct_str(nq_pct), text_color = color_of(nq_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)

    // QQQ — optional row 5 (or 4 if NQ is off)
    qqq_row = show_nq ? 5 : 4
    if show_qqq
        table.cell(t, 0, qqq_row, ' QQQ ', text_color = color.new(#ff7b72, 0), text_size = sz(), bgcolor = color.new(#0d1117, 10))
        table.cell(t, 1, qqq_row, str.tostring(qqq, '#.##'), text_color = color_of(qqq_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 2, qqq_row, chg_str(qqq_chg), text_color = color_of(qqq_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
        table.cell(t, 3, qqq_row, pct_str(qqq_pct), text_color = color_of(qqq_chg), text_size = sz(), bgcolor = color.new(#0d1117, 10), text_halign = text.align_right)
````
