# TraxisLab Liquidation Heatmap

- url: https://www.tradingview.com/script/hyonJDZ9/
- type: indicator
- pine_id: PUB;eabec2d41eab49c39599a63a667d8fa8
- version: 1.0

## Description

The TraxisLab Liquidation Heatmap visualizes potential liquidation zones based on price structure, volume, and leverage dynamics. It is designed to provide a clear view of where liquidity is likely to accumulate directly within the chart.

What this indicator does

The indicator identifies price areas where leveraged long and short positions are most likely to be liquidated.
It uses pivot-based structure combined with volume and configurable leverage levels from 10x up to 100x to estimate and display these zones as a dynamic heatmap.

The goal is to highlight areas of concentrated liquidity, potential stop hunts, and zones where price is more likely to react.

Core functionality

Anchor data support allows the use of an external symbol, such as Binance perpetual futures, to improve the realism of the calculations.

Leverage-based calculations are applied across multiple tiers including 10x, 25x, 50x, and 100x.

Volume-weighted estimation assigns each zone an approximate liquidation size in millions of USD.

Cluster detection groups nearby zones together, indicating stronger areas of liquidity concentration.

Nearest zone identification highlights the most relevant zone relative to the current price.

Detailed tooltips provide additional context such as price level, long and short distribution, estimated size, and distance from the current market price.

Time-based fading reduces the visibility of older zones, keeping the focus on more recent data.

Visual structure

The indicator displays heatmap-style zones directly on the chart, with separate color schemes for long and short liquidations.
Intensity varies depending on leverage and clustering strength.

Optional cluster lines improve readability, while labels provide a concise overview of each zone.
An integrated table summarizes the most relevant nearby levels.

Calculation methodology

Liquidation zones are derived from market structure.

Pivot highs are used to estimate potential short liquidations.
Pivot lows are used to estimate potential long liquidations.

The calculations are based on the following formulas:

Short liquidation is calculated as price multiplied by one plus one divided by leverage.
Long liquidation is calculated as price multiplied by one minus one divided by leverage.

Additional factors include volume data, ATR for zone sizing and clustering, and a simulated position allocation model.

Important note

This indicator provides estimated liquidation zones and does not use actual exchange liquidation data.

The calculations are based on typical leverage behavior and market mechanics and are intended to approximate where liquidity is likely positioned.

Application

The indicator can be used to identify potential liquidity targets, anticipate volatility, and refine entries and exits around key levels.
It can also be combined with price action or other analytical methods for more advanced strategies.

This tool is intended for traders who focus on liquidity, structure, and market behavior.

## Source Code

````pine
//@version=5
indicator("TraxisLab — Liquidation Heatmap", "TraxisLab LIQ", true,
     max_boxes_count=500, max_labels_count=500, max_lines_count=500,
     max_bars_back=5000)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════

grp_anc = "── Datenquelle ──"
i_use_anc = input.bool(true, "Anker-Symbol verwenden", group=grp_anc)
i_anchor = input.symbol("BINANCE:BTCUSDT.P", "Anker-Symbol", group=grp_anc)
i_anc_tf = input.timeframe("", "Anker-Timeframe (leer=Chart)", group=grp_anc)

grp_lev = "── Hebelstufen ──"
l1_on = input.bool(true, "10x aktivieren", group=grp_lev, inline="l1")
l1_v = input.float(10, "", group=grp_lev, inline="l1", minval=2)
l2_on = input.bool(true, "25x aktivieren", group=grp_lev, inline="l2")
l2_v = input.float(25, "", group=grp_lev, inline="l2", minval=2)
l3_on = input.bool(true, "50x aktivieren", group=grp_lev, inline="l3")
l3_v = input.float(50, "", group=grp_lev, inline="l3", minval=2)
l4_on = input.bool(true, "100x aktivieren", group=grp_lev, inline="l4")
l4_v = input.float(100, "", group=grp_lev, inline="l4", minval=2)

grp_gen = "── Berechnung ──"
i_pvt = input.int(10, "Lookback (Bars)", group=grp_gen, minval=2, maxval=30)
i_zatr = input.float(0.3, "Zonenhöhe (ATR-x)", group=grp_gen, minval=0.05, maxval=2.0, step=0.05)
i_age = input.int(200, "Max. Alter (Bars)", group=grp_gen, minval=20, maxval=500)
i_clr = input.float(1.0, "Cluster-Radius (ATR-x)", group=grp_gen, minval=0.2, maxval=3.0, step=0.1)
i_pfr = input.float(0.30, "Positions-Anteil", group=grp_gen, minval=0.05, maxval=1.0, step=0.05)
i_mth = input.float(50, "Min $M für Anzeige", group=grp_gen, minval=0, maxval=1000, step=10)

grp_vis = "── Darstellung ──"
i_lab = input.bool(true, "Labels anzeigen", group=grp_vis)
i_lin = input.bool(true, "Cluster-Linien", group=grp_vis)
i_nrst = input.bool(true, "Nächste Zone markieren", group=grp_vis)
i_lsz = input.string("Klein", "Label-Größe", options=["Winzig", "Klein", "Normal"], group=grp_vis)
i_opac = input.int(65, "Box-Deckkraft (%)", group=grp_vis, minval=10, maxval=95, step=5)
i_fade = input.bool(true, "Alters-Fading", group=grp_vis)
i_tbl = input.bool(true, "Tabelle", group=grp_vis)

grp_col = "── Farben ──"
c_lb = input.color(#FF6D00, "Long-Liq", group=grp_col)
c_sb = input.color(#2962FF, "Short-Liq", group=grp_col)
c_hot = input.color(#FFEB3B, "Hohe Dichte", group=grp_col)
c_ext = input.color(#FF1744, "Extreme Dichte", group=grp_col)
c_tl = input.color(#FFD600, "Long Text", group=grp_col)
c_ts = input.color(#00E5FF, "Short Text", group=grp_col)
c_nr = input.color(#E040FB, "Nächste Zone", group=grp_col)

// ═══════════════════════════════════════════
// ANCHOR DATA
// ═══════════════════════════════════════════

atf = i_anc_tf == "" ? timeframe.period : i_anc_tf

a_h = request.security(i_anchor, atf, high, ignore_invalid_symbol=true)

a_l = request.security(i_anchor, atf, low, ignore_invalid_symbol=true)

a_c = request.security(i_anchor, atf, close, ignore_invalid_symbol=true)

a_v = request.security(i_anchor, atf, volume, ignore_invalid_symbol=true)

src_h = i_use_anc and not na(a_h) ? a_h : high

src_l = i_use_anc and not na(a_l) ? a_l : low

src_c = i_use_anc and not na(a_c) ? a_c : close

src_v = i_use_anc and not na(a_v) ? a_v : volume

// ═══════════════════════════════════════════
// CORE
// ═══════════════════════════════════════════

f_sz(string s) =>
    s == "Winzig" ? size.tiny : s == "Klein" ? size.small : size.normal

lsz = f_sz(i_lsz)

atr14 = ta.atr(14)

sa = nz(atr14, close * 0.01)

hh = sa * i_zatr * 0.5

cr = sa * i_clr

var array<float> levs = array.new_float(0)

if barstate.isfirst
    array.clear(levs)
    if l1_on
        array.push(levs, l1_v)
    if l2_on
        array.push(levs, l2_v)
    if l3_on
        array.push(levs, l3_v)
    if l4_on
        array.push(levs, l4_v)

nl = array.size(levs)

// ═══════════════════════════════════════════
// STORAGE
// ═══════════════════════════════════════════

var array<box>   bxs = array.new_box(0)
var array<float> bxc = array.new_float(0)
var array<int>   bxb = array.new_int(0)
var array<bool>  bxl = array.new_bool(0)
var array<float> bxv = array.new_float(0)
var array<float> bxm = array.new_float(0)

// ═══════════════════════════════════════════
// PIVOTS (auf Anker-Daten)
// ═══════════════════════════════════════════

phi = ta.pivothigh(src_h, i_pvt, i_pvt)

plo = ta.pivotlow(src_l, i_pvt, i_pvt)

// ═══════════════════════════════════════════
// ZONE COLOR
// ═══════════════════════════════════════════

f_zc(bool il, float lv, int ag) =>
    inten = math.min(1.0, (lv - 10) / 90)
    base = il ? c_lb : c_sb
    h2 = color.from_gradient(inten, 0, 1, base, c_hot)
    btr = 100 - i_opac
    af = i_fade ? math.round(float(ag) / float(i_age) * 25) : 0
    color.new(h2, math.min(95, btr + af))

// ═══════════════════════════════════════════
// CREATE ZONES
// ═══════════════════════════════════════════

if not na(phi) and nl > 0
    ep = phi
    pv = nz(src_v[i_pvt], nz(src_v, 0))
    em = pv * ep * i_pfr / math.max(1, nl) / 1e6
    for i = 0 to nl - 1
        lv = array.get(levs, i)
        lq = ep * (1 + 1 / lv)
        c = f_zc(false, lv, 0)
        bd = color.new(c_sb, 50)
        array.push(bxs, box.new(bar_index - i_pvt, lq + hh, bar_index, lq - hh, border_color=bd, bgcolor=c, border_width=1))
        array.push(bxc, lq)
        array.push(bxb, bar_index)
        array.push(bxl, false)
        array.push(bxv, lv)
        array.push(bxm, em)

if not na(plo) and nl > 0
    ep = plo
    pv = nz(src_v[i_pvt], nz(src_v, 0))
    em = pv * ep * i_pfr / math.max(1, nl) / 1e6
    for i = 0 to nl - 1
        lv = array.get(levs, i)
        lq = ep * (1 - 1 / lv)
        c = f_zc(true, lv, 0)
        bd = color.new(c_lb, 50)
        array.push(bxs, box.new(bar_index - i_pvt, lq + hh, bar_index, lq - hh, border_color=bd, bgcolor=c, border_width=1))
        array.push(bxc, lq)
        array.push(bxb, bar_index)
        array.push(bxl, true)
        array.push(bxv, lv)
        array.push(bxm, em)

// ═══════════════════════════════════════════
// UPDATE + HIT + FADE
// ═══════════════════════════════════════════

var int hlc = 0
var int hsc = 0

nb = array.size(bxs)

if nb > 0
    for i = nb - 1 to 0
        if array.size(bxs) == 0 or i >= array.size(bxs)
            break
        lv2 = array.get(bxc, i)
        ag = bar_index - array.get(bxb, i)
        il = array.get(bxl, i)
        lev = array.get(bxv, i)
        b = array.get(bxs, i)

        hit = (il and low <= lv2 + hh) or (not il and high >= lv2 - hh)

        if hit or ag > i_age
            if hit
                if il
                    hlc += 1
                else
                    hsc += 1
            box.delete(b)
            array.remove(bxs, i)
            array.remove(bxc, i)
            array.remove(bxb, i)
            array.remove(bxl, i)
            array.remove(bxv, i)
            array.remove(bxm, i)
        else
            box.set_right(b, bar_index)
            box.set_bgcolor(b, f_zc(il, lev, ag))

while array.size(bxs) > 440
    if array.size(bxs) == 0
        break
    box.delete(array.shift(bxs))
    array.shift(bxc)
    array.shift(bxb)
    array.shift(bxl)
    array.shift(bxv)
    array.shift(bxm)

// ═══════════════════════════════════════════
// CLUSTER + LABELS MIT TOOLTIP
// ═══════════════════════════════════════════

var array<label> sla = array.new_label(0)
var array<line>  lna = array.new_line(0)
var array<float> cpa = array.new_float(0)
var array<int>   cca = array.new_int(0)
var array<int>   cl_l = array.new_int(0)
var array<int>   cl_s = array.new_int(0)
var array<float> cma = array.new_float(0)

if barstate.islast
    // Cleanup
    if array.size(sla) > 0
        for i = 0 to array.size(sla) - 1
            label.delete(array.get(sla, i))
    array.clear(sla)

    if array.size(lna) > 0
        for i = 0 to array.size(lna) - 1
            line.delete(array.get(lna, i))
    array.clear(lna)

    array.clear(cpa)
    array.clear(cca)
    array.clear(cl_l)
    array.clear(cl_s)
    array.clear(cma)

    n = array.size(bxc)

    if n > 0
        used = array.new_bool(n, false)

        for i = 0 to n - 1
            if not array.get(used, i)
                array.set(used, i, true)
                cp = array.get(bxc, i)
                cnt = 1
                lcc = array.get(bxl, i) ? 1 : 0
                scc = array.get(bxl, i) ? 0 : 1
                sp = cp
                sm = array.get(bxm, i)

                for j = 0 to n - 1
                    if j != i and not array.get(used, j)
                        if math.abs(array.get(bxc, j) - cp) < cr
                            array.set(used, j, true)
                            cnt += 1
                            sp += array.get(bxc, j)
                            sm += array.get(bxm, j)
                            if array.get(bxl, j)
                                lcc += 1
                            else
                                scc += 1

                array.push(cpa, sp / cnt)
                array.push(cca, cnt)
                array.push(cl_l, lcc)
                array.push(cl_s, scc)
                array.push(cma, sm)

    // Labels + Tooltips
    ncl = array.size(cpa)

    if ncl > 0 and i_lab
        ni = 0
        nd = math.abs(close - array.get(cpa, 0))
        if ncl > 1
            for i = 1 to ncl - 1
                d = math.abs(close - array.get(cpa, i))
                if d < nd
                    nd := d
                    ni := i

        for i = 0 to ncl - 1
            p = array.get(cpa, i)
            ct = array.get(cca, i)
            lcc = array.get(cl_l, i)
            scc = array.get(cl_s, i)
            mm = array.get(cma, i)
            isnr = i == ni and i_nrst
            dist_pct = close != 0 ? math.abs(p - close) / close * 100 : 0

            tc = lcc > scc ? c_tl : c_ts
            if ct >= 6
                tc := c_ext
            else if ct >= 4
                tc := c_hot

            // Sichtbarer Text
            t = str.tostring(ct) + "×"
            if lcc > 0 and scc > 0
                t := t + " L:" + str.tostring(lcc) + " S:" + str.tostring(scc)
            else if lcc > 0
                t := t + " Long"
            else
                t := t + " Short"

            if mm >= i_mth
                t := t + "\n$" + str.tostring(mm, "#.0") + "M"

            if isnr
                t := "► " + t

            // Tooltip (beim Hovern sichtbar)
            typ = lcc > scc ? "Long" : lcc < scc ? "Short" : "Gemischt"
            dir = p > close ? "oberhalb" : "unterhalb"
            tt = "══════════════════════\n"
            tt := tt + "  TraxisLab Liquidation\n"
            tt := tt + "══════════════════════\n"
            tt := tt + "  Preis:        " + str.tostring(p, format.mintick) + "\n"
            tt := tt + "  Typ:           " + str.tostring(ct) + "× " + typ + "\n"
            tt := tt + "  $M:            $" + str.tostring(mm, "#.0") + "M\n"
            tt := tt + "──────────────────────\n"
            tt := tt + "  Long:         " + str.tostring(lcc) + " Zonen\n"
            tt := tt + "  Short:        " + str.tostring(scc) + " Zonen\n"
            tt := tt + "  Abstand:    " + str.tostring(dist_pct, "#.00") + "% " + dir + "\n"
            if i_use_anc
                tt := tt + "  Quelle:      " + i_anchor + "\n"
            tt := tt + "══════════════════════"

            bg = isnr ? color.new(c_nr, 50) : color.new(#0d0d1a, 40)
            array.push(sla, label.new(x=bar_index + 3, y=p, text=t, xloc=xloc.bar_index, yloc=yloc.price, color=bg, style=label.style_label_left, textcolor=tc, size=lsz, textalign=text.align_left, tooltip=tt))

            if i_lin and ct >= 2
                lc2 = isnr ? c_nr : lcc > scc ? color.new(c_lb, 40) : color.new(c_sb, 40)
                lw = ct >= 5 ? 2 : 1
                ls = isnr ? line.style_solid : line.style_dotted
                array.push(lna, line.new(bar_index - 5, p, bar_index + 2, p, color=lc2, width=lw, style=ls))

    // Nearest Zone
    if ncl > 0 and i_nrst
        nd2 = math.abs(close - array.get(cpa, 0))
        np = array.get(cpa, 0)
        nm = array.get(cma, 0)

        if ncl > 1
            for i = 1 to ncl - 1
                d = math.abs(close - array.get(cpa, i))
                if d < nd2
                    nd2 := d
                    np := array.get(cpa, i)
                    nm := array.get(cma, i)

        dr = np > close ? "▲" : "▼"
        dp = close != 0 ? math.abs(np - close) / close * 100 : 0
        nt = dr + " " + str.tostring(dp, "#.00") + "%"
        if nm >= 1
            nt := nt + " $" + str.tostring(nm, "#.0") + "M"
        ntt = "Nächste Liquidationszone\nPreis: " + str.tostring(np, format.mintick) + "\nAbstand: " + str.tostring(dp, "#.00") + "%\n$M: $" + str.tostring(nm, "#.0") + "M"
        array.push(sla, label.new(x=bar_index + 8, y=np, text=nt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_nr, 30), style=label.style_label_left, textcolor=c_nr, size=size.small, textalign=text.align_left, tooltip=ntt))

// ═══════════════════════════════════════════
// TABLE
// ═══════════════════════════════════════════

var table tb = table.new(position.bottom_right, 3, 4, bgcolor=color.new(#0d0d1a, 5), border_color=color.new(#787b86, 80), border_width=1)

if i_tbl and barstate.islast
    table.cell(tb, 0, 0, "TraxisLab", text_color=color.white, text_size=size.tiny)
    table.cell(tb, 1, 0, "Preis", text_color=#787b86, text_size=size.tiny)
    table.cell(tb, 2, 0, "$M", text_color=#787b86, text_size=size.tiny)

    ncl2 = array.size(cpa)

    fa = false
    ap = 0.0
    am = 0.0
    da = 999999999.0
    fb = false
    bp = 0.0
    bm_v = 0.0
    db = 999999999.0

    if ncl2 > 0
        for i = 0 to ncl2 - 1
            p = array.get(cpa, i)
            m = array.get(cma, i)
            if p > close
                d = p - close
                if d < da
                    da := d
                    ap := p
                    am := m
                    fa := true
            if p < close
                d = close - p
                if d < db
                    db := d
                    bp := p
                    bm_v := m
                    fb := true

    if fa
        table.cell(tb, 0, 1, "Short▲", text_color=c_ts, text_size=size.tiny)
        table.cell(tb, 1, 1, str.tostring(ap, format.mintick), text_color=color.white, text_size=size.tiny)
        table.cell(tb, 2, 1, "$" + str.tostring(am, "#.0") + "M", text_color=c_ts, text_size=size.tiny)
    else
        table.cell(tb, 0, 1, "Short▲", text_color=#787b86, text_size=size.tiny)
        table.cell(tb, 1, 1, "–", text_color=#787b86, text_size=size.tiny)
        table.cell(tb, 2, 1, "–", text_color=#787b86, text_size=size.tiny)

    if fb
        table.cell(tb, 0, 2, "Long▼", text_color=c_tl, text_size=size.tiny)
        table.cell(tb, 1, 2, str.tostring(bp, format.mintick), text_color=color.white, text_size=size.tiny)
        table.cell(tb, 2, 2, "$" + str.tostring(bm_v, "#.0") + "M", text_color=c_tl, text_size=size.tiny)
    else
        table.cell(tb, 0, 2, "Long▼", text_color=#787b86, text_size=size.tiny)
        table.cell(tb, 1, 2, "–", text_color=#787b86, text_size=size.tiny)
        table.cell(tb, 2, 2, "–", text_color=#787b86, text_size=size.tiny)

    tm = 0.0
    if ncl2 > 0
        for i = 0 to ncl2 - 1
            tm += array.get(cma, i)
    src_txt = i_use_anc ? "📡" : "📊"
    table.cell(tb, 0, 3, src_txt + " " + str.tostring(array.size(bxs)), text_color=#787b86, text_size=size.tiny)
    table.cell(tb, 1, 3, "", text_color=#787b86, text_size=size.tiny)
    table.cell(tb, 2, 3, "$" + str.tostring(tm, "#") + "M", text_color=c_hot, text_size=size.tiny)

// ═══════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════

dnb = false

dns = false

if array.size(cpa) > 0
    for i = 0 to array.size(cpa) - 1
        p = array.get(cpa, i)
        ct = array.get(cca, i)
        if ct >= 3 and math.abs(close - p) < sa * 1.5
            if p < close
                dnb := true
            else
                dns := true

alertcondition(dnb, "Nahe Long-Liq", "TraxisLab: Long-Liquidationscluster")

alertcondition(dns, "Nahe Short-Liq", "TraxisLab: Short-Liquidationscluster")
````
