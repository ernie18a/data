# Boursa Kuwait Sectors Performance

- url: https://www.tradingview.com/script/TB02mLC4-Boursa-Kuwait-Sectors-Performance/
- type: indicator
- pine_id: PUB;835f4387e23d4302a4784c7eeca29470
- version: 1.0

## Description

Boursa Kuwait Sectors Performance

OVERVIEW
A compact table that shows the performance of the 13 Boursa Kuwait sector indices alongside the three market indices (All Share BKA, Premier Market BKP, Main Market BKM) in a single view. It is designed for traders who follow sector rotation in the Kuwaiti market and want to see at a glance which sectors are leading or lagging the overall market.

WHAT IT ADDS
- All Boursa Kuwait sector and market indices in one sortable table, on any chart symbol.
- The comparison period follows the chart timeframe, so one script covers daily, weekly, monthly, quarterly and yearly views.
- Relative change versus the All Share Index (BKA) for every sector.
- The number of listed stocks per sector, to put each move in context: a one-stock sector behaves very differently from a 44-stock sector.
- A native right-to-left Arabic layout, with a full English mode.

HOW IT WORKS
- For each index, the script requests the current and previous close on the chart timeframe and calculates: (close / previous close - 1) x 100.
- Daily chart = daily change, weekly = weekly, monthly = monthly, 3M = quarterly, 12M = yearly. On intraday charts the table shows the daily change. The column header names the active period.
- RS vs BKA = sector change minus BKA change on the same timeframe, in percentage points. Positive means the sector outperformed the market over that period. The same value appears as a tooltip when hovering over each change cell; it can also be shown as a separate column.
- Sectors can be sorted by change, by RS vs BKA, or by number of stocks, ascending or descending. Sectors with no data are always placed at the bottom.

HOW TO USE
Add the script to any chart; it does not depend on the chart symbol. Change the chart timeframe to change the comparison period. Sort by change or RS vs BKA to see which sectors are outperforming or underperforming the market.

SETTINGS
- Language: Arabic (default, right-to-left layout) or English.
- Sort By and direction; Market Rows on/off; Ticker and Stocks columns on/off; RS vs BKA column on/off.
- Position, Top Offset (empty rows so the table does not cover the chart buttons), Text Size.
- Theme: Auto (follows the chart background), Dark, Light, or Custom colours. Up / Down / Flat colours apply in every theme.

ARABIC INTERFACE - ENGLISH TRANSLATIONS
Headers: الرمز = Ticker | المؤشر = Index | الأسهم = Stocks | مقابل العام = vs BKA | يومي = Daily | أسبوعي = Weekly | شهري = Monthly | ربعي = Quarterly | سنوي = Yearly
Markets: السوق العام = All Share (BKA) | السوق الأول = Premier Market (BKP) | السوق الرئيسي = Main Market (BKM)
Sectors: البنوك = Banks (BKB) | الخدمات المالية = Financial Services (BKFS) | العقار = Real Estate (BKRE) | الصناعية = Industrials (BKI) | الخدمات الاستهلاكية = Consumer Discretionary (BKCD) | التأمين = Insurance (BKINS) | الطاقة = Energy (BKE) | الاتصالات = Telecommunications (BKTEL) | المواد الأساسية = Basic Materials (BKBM) | الرعاية الصحية = Health Care (BKHC) | السلع الاستهلاكية = Consumer Staples (BKCS) | التكنولوجيا = Technology (BKTECH) | المنافع = Utilities (BKU)
Hovering over any Arabic index name shows its English name.

LIMITATIONS
- Stock counts per sector are fixed in the code (Boursa Kuwait stock screener, 29 Sep 2026, 137 stocks). They do not update automatically when companies list or delist; they will be revised in script updates. Counts are not shown for BKP and BKM.
- Values on the current, unfinished bar update in real time and are final only after the bar closes.
- On non-standard multiples (for example 2D or 2W) the header shows the timeframe code instead of a period name.
- Values depend on the availability of the KSE index symbols on TradingView; a missing value is shown as "—".
- RS vs BKA is a simple difference in percentage points, not a ratio-based relative strength line.
- Sectors with very few stocks (Technology and Utilities have one stock each) can show large moves driven by a single company.
- The script displays information only. It does not generate trading signals and is not investment advice.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/

//@version=6
indicator('Boursa Kuwait Sectors Performance', 'Boursa Kuwait Sectors Performance', overlay = true)

// ═══════════════════════ Inputs ═══════════════════════
GRP_V = 'View'
GRP_S = 'Style'

i_lang = input.string('Arabic', 'Language', ['Arabic', 'English'], group = GRP_V, display = display.none)
i_sort = input.string('Change', 'Sort By', ['Change', 'RS vs BKA', 'Stocks', 'None'], group = GRP_V, inline = 'sort', tooltip = 'Change follows the chart timeframe: daily chart = daily change, weekly = weekly, monthly = monthly. Intraday charts show the daily change.', display = display.none)
i_dir  = input.string('High to Low', '', ['High to Low', 'Low to High'], group = GRP_V, inline = 'sort', display = display.none)
i_mkt  = input.bool(true,  'Market Rows (BKA / BKP / BKM)', group = GRP_V, display = display.none)
i_tick = input.bool(true,  'Ticker', group = GRP_V, inline = 'cols', display = display.none)
i_cnt  = input.bool(true,  'Stocks', group = GRP_V, inline = 'cols', display = display.none)
i_rs   = input.bool(false, 'RS vs BKA column', group = GRP_V, tooltip = 'Optional: sector change minus All Share (BKA) change on the same timeframe, in percentage points. Positive = outperformed the market.', display = display.none)

i_pos  = input.string(position.top_right, 'Position', [position.top_left, position.top_center, position.top_right, position.middle_left, position.middle_right, position.bottom_left, position.bottom_center, position.bottom_right], group = GRP_S, display = display.none)
i_gap  = input.int(2, 'Top Offset (rows)', 0, 5, group = GRP_S, active = i_pos == position.top_left or i_pos == position.top_center or i_pos == position.top_right, tooltip = 'Empty rows above the table when it sits at the top, so it does not cover the chart buttons (maximize, etc.).', display = display.none)
i_size = input.string(size.normal, 'Text Size', [size.tiny, size.small, size.normal, size.large], group = GRP_S, display = display.none)
i_theme = input.string('Auto', 'Theme', ['Auto', 'Dark', 'Light', 'Custom'], group = GRP_S, tooltip = 'Auto reads the chart background and switches between the Dark and Light palettes.\nCustom uses the Text / Rows / Market / Header colours below.\nUp / Down / Flat colours apply in every theme.', display = display.none)
i_up   = input.color(#26A69A, 'Up', group = GRP_S, inline = 'clr', display = display.none)
i_dn   = input.color(#EF5350, 'Down', group = GRP_S, inline = 'clr', display = display.none)
i_neu  = input.color(#9598A1, 'Flat', group = GRP_S, inline = 'clr', display = display.none)
IS_CUSTOM = i_theme == 'Custom'   // greys out the colour pickers below unless Theme = Custom
i_txt  = input.color(#D1D4DC, 'Text', group = GRP_S, inline = 'bg', tooltip = 'Editable only when Theme = Custom.', active = IS_CUSTOM, display = display.none)
i_bg1  = input.color(#1E222D, 'Rows', group = GRP_S, inline = 'bg', active = IS_CUSTOM, display = display.none)
i_bg2  = input.color(#262B38, '', group = GRP_S, inline = 'bg', active = IS_CUSTOM, display = display.none)
i_mbg  = input.color(#2F3445, 'Market', group = GRP_S, inline = 'bg', active = IS_CUSTOM, display = display.none)
i_hbg  = input.color(#131722, 'Header', group = GRP_S, inline = 'bg', active = IS_CUSTOM, display = display.none)

// ═══════════════════════ Theme ═══════════════════════
f_lum(color c) =>
    0.299 * color.r(c) + 0.587 * color.g(c) + 0.114 * color.b(c)

CUSTOM = i_theme == 'Custom'
DARK   = i_theme == 'Dark' or (i_theme == 'Auto' and f_lum(chart.bg_color) < 128)

c_txt = CUSTOM ? i_txt : DARK ? #D1D4DC : #131722
c_bg1 = CUSTOM ? i_bg1 : DARK ? #1E222D : #FFFFFF
c_bg2 = CUSTOM ? i_bg2 : DARK ? #262B38 : #F3F4F7
c_mbg = CUSTOM ? i_mbg : DARK ? #2F3445 : #E4E7ED
c_hbg = CUSTOM ? i_hbg : DARK ? #131722 : #D1D4DC
c_htx = CUSTOM ? color.new(i_txt, 35) : DARK ? #9598A1 : #434651
// Tint strength: stronger on dark rows, lighter on light rows
TINT  = f_lum(c_bg1) < 128 ? 0.22 : 0.14

// ═══════════════════════ Model ═══════════════════════
type Idx
    string sym
    string tk
    string ar
    string en
    int    n
    float  chg = na
    float  rs  = na

// Listed stocks per sector — Boursa Kuwait stock screener, 29 Sep 2026 (137 stocks).
// Fixed in code, not in settings; updated with script releases when companies list or delist.
n_b    = 9
n_fs   = 44
n_re   = 29
n_i    = 19
n_cd   = 10
n_ins  = 8
n_e    = 5
n_tel  = 4
n_bm   = 3
n_hc   = 2
n_cs   = 2
n_tech = 1
n_u    = 1
N_TOTAL = n_b + n_fs + n_re + n_i + n_cd + n_ins + n_e + n_tel + n_bm + n_hc + n_cs + n_tech + n_u

var markets = array.from(
     Idx.new('KSE:BKA', 'BKA', 'السوق العام',   'All Share',      N_TOTAL),
     Idx.new('KSE:BKP', 'BKP', 'السوق الأول',   'Premier Market', 0),
     Idx.new('KSE:BKM', 'BKM', 'السوق الرئيسي', 'Main Market',    0))

var sectors = array.from(
     Idx.new('KSE:BKB',    'BKB',    'البنوك',              'Banks',                  n_b),
     Idx.new('KSE:BKFS',   'BKFS',   'الخدمات المالية',     'Financial Services',     n_fs),
     Idx.new('KSE:BKRE',   'BKRE',   'العقار',              'Real Estate',            n_re),
     Idx.new('KSE:BKI',    'BKI',    'الصناعية',            'Industrials',            n_i),
     Idx.new('KSE:BKCD',   'BKCD',   'الخدمات الاستهلاكية', 'Consumer Discretionary', n_cd),
     Idx.new('KSE:BKINS',  'BKINS',  'التأمين',             'Insurance',              n_ins),
     Idx.new('KSE:BKE',    'BKE',    'الطاقة',              'Energy',                 n_e),
     Idx.new('KSE:BKTEL',  'BKTEL',  'الاتصالات',           'Telecommunications',     n_tel),
     Idx.new('KSE:BKBM',   'BKBM',   'المواد الأساسية',     'Basic Materials',        n_bm),
     Idx.new('KSE:BKHC',   'BKHC',   'الرعاية الصحية',      'Health Care',            n_hc),
     Idx.new('KSE:BKCS',   'BKCS',   'السلع الاستهلاكية',   'Consumer Staples',       n_cs),
     Idx.new('KSE:BKTECH', 'BKTECH', 'التكنولوجيا',         'Technology',             n_tech),
     Idx.new('KSE:BKU',    'BKU',    'المنافع',             'Utilities',              n_u))

// Timeframe follows the chart; intraday charts use the daily change
TF = timeframe.isintraday ? 'D' : ''

f_change(string sym) =>
    [c, p] = request.security(sym, TF, [close, close[1]], ignore_invalid_symbol = true)
    na(p) or p == 0 ? na : (c / p - 1) * 100

for x in markets
    x.chg := f_change(x.sym)
base = markets.get(0).chg
for x in markets
    x.rs := x.sym == 'KSE:BKA' ? na : x.chg - base
for x in sectors
    x.chg := f_change(x.sym)
    x.rs  := x.chg - base

// ═══════════════════════ Helpers ═══════════════════════
is_en = i_lang == 'English'

// Period name shown in the column header
f_period() =>
    if timeframe.isintraday or (timeframe.isdaily and timeframe.multiplier == 1)
        is_en ? 'Daily' : 'يومي'
    else if timeframe.isweekly and timeframe.multiplier == 1
        is_en ? 'Weekly' : 'أسبوعي'
    else if timeframe.ismonthly and timeframe.multiplier == 1
        is_en ? 'Monthly' : 'شهري'
    else if timeframe.ismonthly and timeframe.multiplier == 3
        is_en ? 'Quarterly' : 'ربعي'
    else if timeframe.ismonthly and timeframe.multiplier == 12
        is_en ? 'Yearly' : 'سنوي'
    else
        timeframe.period

f_col(float v) =>
    na(v) ? i_neu : v > 0 ? i_up : v < 0 ? i_dn : i_neu

// Solid dark tint of the signal colour over the row background (no transparency, so the chart never shows through)
f_tint(color c, color base_) =>
    color.rgb(color.r(c) * TINT + color.r(base_) * (1 - TINT), color.g(c) * TINT + color.g(base_) * (1 - TINT), color.b(c) * TINT + color.b(base_) * (1 - TINT))

// Sign comes from the raw value, so moves that round to zero keep their direction (-0.00 / +0.00)
f_fmt(float v, string unit) =>
    na(v) ? '—' : (v > 0 ? '+' : v < 0 ? '-' : '') + str.tostring(math.abs(v), '0.00') + unit

f_cell(table t, int c, int r, string txt, color tc, color bg, string ha, string tip = '') =>
    table.cell(t, c, r, txt, text_color = tc, bgcolor = bg, text_size = i_size, text_halign = ha, tooltip = tip)

// On light rows the signal colour is darkened 25% for the text so it stays readable
f_num(table t, int c, int r, float v, string unit, color bg, string tip = '') =>
    sc = f_col(v)
    tc = f_lum(bg) < 128 ? sc : color.rgb(color.r(sc) * 0.75, color.g(sc) * 0.75, color.b(sc) * 0.75)
    f_cell(t, c, r, f_fmt(v, unit), tc, na(v) ? bg : f_tint(sc, bg), text.align_center, tip)

f_kinds() =>
    k = array.new_string()
    if i_tick
        k.push('T')
    k.push('S')
    if i_cnt
        k.push('N')
    k.push('C')
    if i_rs
        k.push('R')
    if not is_en
        k.reverse()   // RTL: ticker on the far right, numbers on the left
    k

f_row(table t, array<string> kinds, int r, Idx x, color bg) =>
    for [j, k] in kinds
        if k == 'T'
            f_cell(t, j, r, x.tk, c_txt, bg, text.align_center)
        else if k == 'S'
            // Hover tooltip: the index name in the other language
            f_cell(t, j, r, is_en ? x.en : x.ar, c_txt, bg, is_en ? text.align_left : text.align_right, is_en ? x.ar : x.en)
        else if k == 'N'
            f_cell(t, j, r, x.n > 0 ? str.tostring(x.n) : '', c_txt, bg, text.align_center)
        else if k == 'C'
            // Hover tooltip: difference vs the All Share Index (BKA) on the same timeframe
            f_num(t, j, r, x.chg, '%', bg, x.sym == 'KSE:BKA' ? '' : (is_en ? 'vs BKA: ' : 'مقابل العام: ') + f_fmt(x.rs, ''))
        else
            f_num(t, j, r, x.rs, '', bg)

f_label(string k) =>
    switch k
        'T' => is_en ? 'Ticker' : 'الرمز'
        'S' => is_en ? 'Index'  : 'المؤشر'
        'N' => is_en ? 'Stocks' : 'الأسهم'
        'C' => f_period()
        => is_en ? 'vs BKA' : 'مقابل العام'

f_key(Idx x, int i) =>
    switch i_sort
        'Change'    => x.chg
        'RS vs BKA' => x.rs
        'Stocks'    => float(x.n)
        => float(i)

// ═══════════════════════ Table ═══════════════════════
// Max rows: 5 spacer + 1 header + 3 market + 13 sectors = 22
// border_width = 0: the transparent spacer rows stay invisible; rows are separated by alternating shades
var table tbl = table.new(i_pos, 5, 22, border_width = 0)

if barstate.islast
    tbl.clear(0, 0, 4, 21)
    kinds = f_kinds()
    r = 0

    // Transparent spacer rows (top positions only)
    if str.startswith(i_pos, 'top') and i_gap > 0
        for g = 1 to i_gap
            table.cell(tbl, 0, r, ' ', text_size = i_size, bgcolor = color(na))
            r += 1

    for [j, k] in kinds
        f_cell(tbl, j, r, f_label(k), c_htx, c_hbg, text.align_center)
    r += 1

    if i_mkt
        for x in markets
            f_row(tbl, kinds, r, x, c_mbg)
            r += 1

    // Sort keys: na always sinks to the bottom; 'None' keeps the default order
    none_ = i_sort == 'None'
    desc = i_dir == 'High to Low' and not none_
    keys = array.new_float()
    for [i, x] in sectors
        v = f_key(x, i)
        keys.push(none_ ? float(i) : na(v) ? (desc ? -1e10 : 1e10) : v)
    idx = keys.sort_indices(desc ? order.descending : order.ascending)

    for i = 0 to sectors.size() - 1
        f_row(tbl, kinds, r, sectors.get(idx.get(i)), i % 2 == 0 ? c_bg1 : c_bg2)
        r += 1
````
