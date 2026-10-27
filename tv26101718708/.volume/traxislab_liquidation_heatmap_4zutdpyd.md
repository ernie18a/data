# TraxisLab - Liquidation Heatmap

- url: https://www.tradingview.com/script/4zuTdPyD/
- type: indicator
- pine_id: PUB;59acc79cbebe47aab21b28bdc3afb201
- version: 1.0

## Description

TraxisLab Liquidation Heatmap is a visual liquidity-mapping tool designed to estimate potential liquidation zones based on recent pivot highs/lows, leverage levels, volume, volatility, and clustered price areas.

The script projects possible long and short liquidation levels on the chart and groups nearby zones into readable clusters. It is built to help traders identify where leveraged positions may be vulnerable and where price could be drawn toward liquidity.

Core Concept

The indicator estimates liquidation zones by using pivot-based entry assumptions and configurable leverage levels.

When a pivot high or pivot low is detected, the script calculates potential liquidation prices for selected leverage tiers such as:

10x
25x
50x
100x

These levels are then displayed as heatmap zones and grouped into clusters when several liquidation levels are close to each other.

Anchor Symbol Support

The script can use an external anchor symbol as its data source.

For example, traders can display liquidation estimates on one chart while calculating zones from a selected futures symbol such as BTCUSDT perpetual contracts.

The anchor timeframe can also be customized, or left empty to use the current chart timeframe.

This is useful when you want liquidation zones to be based on a more liquid reference market.

Liquidation Zone Logic

The script estimates liquidation levels using:

Recent pivot highs and lows
Configurable leverage tiers
ATR-based volatility buffer
Maintenance margin assumptions
Fee buffer
Position-size approximation
Volume-based notional estimate

Long liquidation zones are projected below potential long entry areas.
Short liquidation zones are projected above potential short entry areas.

The result is a visual map of areas where leveraged positions may be forced out if price reaches those zones.

Heatmap Visualization

Liquidation zones are drawn as boxes on the chart.

The visual intensity depends on leverage, age, and density.
Older zones can fade over time, while higher-density zones receive stronger visual emphasis.

The heatmap includes:

Warm colors for long liquidation zones
Cool colors for short liquidation zones
Highlighting for high-density clusters
Special emphasis for the nearest zone
Optional cluster lines
Optional age fading
Visual prioritization to reduce noise
Cluster Detection

Nearby liquidation levels are automatically grouped into clusters using an ATR-based cluster radius.

Each cluster shows:

Number of zones in the cluster
Long vs short zone composition
Estimated notional volume
Distance from current price
Relevance score
Source information when using an anchor symbol

This helps traders focus on important liquidity areas instead of reading every individual liquidation box.

Nearest Zone Marker

The indicator can automatically highlight the closest liquidation cluster to the current price.

This marker shows:

Direction of the nearest zone
Percentage distance from price
Estimated volume in the cluster

This provides a quick overview of the next potential liquidity magnet above or below the market.

Liquidity Cockpit Table

The built-in table summarizes the most relevant nearby liquidation areas.

It displays:

Nearest short liquidation cluster above price
Nearest long liquidation cluster below price
Distance to each zone
Estimated volume
Number of active zones
Number of active clusters
Total estimated liquidation volume
Data source status

This makes it easier to read the heatmap without overcrowding the chart.

Alerts

The script includes alert conditions for:

Price near a long liquidation cluster
Price near a short liquidation cluster

Alerts trigger when price approaches a cluster with sufficient density within the defined ATR distance.

How to Use

Use this indicator as a liquidity and risk map, not as a direct entry signal.

Typical use cases include:

Identifying potential liquidity magnets
Spotting areas where leveraged traders may be forced out
Comparing nearby long and short liquidation pressure
Finding high-density liquidity clusters
Watching whether price is approaching the nearest liquidation zone
Using liquidation zones together with market structure, VWAP, trend, or order-flow tools

The strongest zones are usually those with multiple clustered levels, higher estimated volume, and proximity to current price.

Notes

This script does not access exchange liquidation books directly.
It creates an estimated liquidation heatmap based on price structure, volume, leverage assumptions, volatility, and configurable margin logic.

Values shown in millions are approximate and should be treated as visual context, not exact liquidation data.

The quality of the output depends on the selected symbol, anchor symbol, timeframe, and market conditions.

Disclaimer

This indicator is for educational and analytical purposes only.
It does not provide financial advice, trading recommendations, or guaranteed results. Always use proper risk management and perform your own analysis before making trading decisions.

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
i_prio = input.bool(true, "Visuelle Priorisierung", group=grp_vis, tooltip="Wichtige Zonen hervorheben, unwichtige zurücknehmen")
i_tbl = input.bool(true, "Tabelle", group=grp_vis)

grp_col = "── Farben ──"
c_lb = input.color(#FF8A00, "Long-Liq (warm)", group=grp_col)
c_sb = input.color(#00B0FF, "Short-Liq (kalt)", group=grp_col)
c_hot = input.color(#FFEB3B, "Hohe Dichte", group=grp_col)
c_ext = input.color(#FF1744, "Extreme Dichte", group=grp_col)
c_tl = input.color(#FFD54F, "Long Text", group=grp_col)
c_ts = input.color(#4FC3F7, "Short Text", group=grp_col)
c_nr = input.color(#E040FB, "Nächste Zone", group=grp_col)

// ═══════════════════════════════════════════
// ANCHOR DATA
// ═══════════════════════════════════════════

atf = i_anc_tf == "" ? timeframe.period : i_anc_tf

a_o = request.security(i_anchor, atf, open, ignore_invalid_symbol=true)
a_h = request.security(i_anchor, atf, high, ignore_invalid_symbol=true)
a_l = request.security(i_anchor, atf, low, ignore_invalid_symbol=true)
a_c = request.security(i_anchor, atf, close, ignore_invalid_symbol=true)
a_v = request.security(i_anchor, atf, volume, ignore_invalid_symbol=true)

src_o = i_use_anc and not na(a_o) ? a_o : open
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
// PIVOTS
// ═══════════════════════════════════════════

phi = ta.pivothigh(src_h, i_pvt, i_pvt)
plo = ta.pivotlow(src_l, i_pvt, i_pvt)

// ═══════════════════════════════════════════
// ZONE COLOR — mit visueller Priorisierung
// ═══════════════════════════════════════════

f_zc(bool il, float lv, int ag) =>
    inten = math.min(1.0, (lv - 10) / 90)
    base = il ? c_lb : c_sb
    h2 = color.from_gradient(inten, 0, 1, base, c_hot)
    btr = 100 - i_opac
    af = i_fade ? math.round(float(ag) / float(i_age) * 25) : 0
    color.new(h2, math.min(95, btr + af))

// ═══════════════════════════════════════════
// LIQUIDATIONS-LOGIK
// ═══════════════════════════════════════════

f_mmr(float lv) =>
    lv <= 10 ? 0.0050 :
     lv <= 25 ? 0.0045 :
     lv <= 50 ? 0.0040 :
     0.0035

f_fee_buf(float lv) =>
    math.min(0.0020, 0.0010 + (1.0 / lv) * 0.05)

f_vol_buf(float ep) =>
    ep > 0 ? math.min(0.0035, (sa / ep) * 0.22) : 0.0

f_eff_dist(float ep, float lv) =>
    base = 1.0 / lv
    mmr  = f_mmr(lv)
    fee  = f_fee_buf(lv)
    volb = f_vol_buf(ep)
    math.max(0.0005, base - mmr - fee - volb)

f_short_entry(float ph, float pl, float po, float pc) =>
    rng = math.max(syminfo.mintick, ph - pl)
    bodyTop = math.max(po, pc)
    math.min(ph, math.max(bodyTop, ph - rng * 0.28))

f_long_entry(float ph, float pl, float po, float pc) =>
    rng = math.max(syminfo.mintick, ph - pl)
    bodyBot = math.min(po, pc)
    math.max(pl, math.min(bodyBot, pl + rng * 0.28))

f_short_liq(float ep, float lv) =>
    d = f_eff_dist(ep, lv)
    ep * (1.0 + d)

f_long_liq(float ep, float lv) =>
    d = f_eff_dist(ep, lv)
    ep * (1.0 - d)

// ═══════════════════════════════════════════
// CREATE ZONES
// ═══════════════════════════════════════════

if not na(phi) and nl > 0
    ph = src_h[i_pvt]
    pl = src_l[i_pvt]
    po = src_o[i_pvt]
    pc = src_c[i_pvt]
    ep = f_short_entry(ph, pl, po, pc)

    pv = nz(src_v[i_pvt], nz(src_v, 0))
    em = pv * ep * i_pfr / math.max(1, nl) / 1e6

    for i = 0 to nl - 1
        lv = array.get(levs, i)
        lq = f_short_liq(ep, lv)
        c = f_zc(false, lv, 0)
        bd = color.new(c_sb, 40)
        array.push(bxs, box.new(bar_index - i_pvt, lq + hh, bar_index, lq - hh, border_color=bd, bgcolor=c, border_width=1))
        array.push(bxc, lq)
        array.push(bxb, bar_index)
        array.push(bxl, false)
        array.push(bxv, lv)
        array.push(bxm, em)

if not na(plo) and nl > 0
    ph = src_h[i_pvt]
    pl = src_l[i_pvt]
    po = src_o[i_pvt]
    pc = src_c[i_pvt]
    ep = f_long_entry(ph, pl, po, pc)

    pv = nz(src_v[i_pvt], nz(src_v, 0))
    em = pv * ep * i_pfr / math.max(1, nl) / 1e6

    for i = 0 to nl - 1
        lv = array.get(levs, i)
        lq = f_long_liq(ep, lv)
        c = f_zc(true, lv, 0)
        bd = color.new(c_lb, 40)
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
// CLUSTER + LABELS mit Anti-Overlap
// ═══════════════════════════════════════════

var array<label> sla = array.new_label(0)
var array<line>  lna = array.new_line(0)
var array<float> cpa = array.new_float(0)
var array<int>   cca = array.new_int(0)
var array<int>   cl_l = array.new_int(0)
var array<int>   cl_s = array.new_int(0)
var array<float> cma = array.new_float(0)

if barstate.islast
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

    // ─── Labels mit Anti-Overlap Algorithmus ───
    ncl = array.size(cpa)

    if ncl > 0 and i_lab
        // Sortier-Index nach Preis (für Anti-Overlap)
        var array<int> idx_sort = array.new_int(0)
        array.clear(idx_sort)
        for k = 0 to ncl - 1
            array.push(idx_sort, k)

        // Bubble sort by price ascending
        for a = 0 to ncl - 2
            for bi = 0 to ncl - 2 - a
                ia = array.get(idx_sort, bi)
                ib2 = array.get(idx_sort, bi + 1)
                if array.get(cpa, ia) > array.get(cpa, ib2)
                    array.set(idx_sort, bi, ib2)
                    array.set(idx_sort, bi + 1, ia)

        // Nächste Zone finden
        ni = 0
        nd = math.abs(close - array.get(cpa, 0))
        if ncl > 1
            for i = 1 to ncl - 1
                d = math.abs(close - array.get(cpa, i))
                if d < nd
                    nd := d
                    ni := i

        // Max $M für Relevanz-Scoring
        max_mm = 0.0
        for i = 0 to ncl - 1
            max_mm := math.max(max_mm, array.get(cma, i))

        // Label-Erstellung in Preisreihenfolge mit dynamischem X-Offset
        var float prev_price = -1.0
        prev_price := -1.0
        var int col_cycle = 0
        col_cycle := 0
        min_gap = sa * 0.8  // Mindestabstand für Labels

        for k = 0 to ncl - 1
            i = array.get(idx_sort, k)
            p = array.get(cpa, i)
            ct = array.get(cca, i)
            lcc = array.get(cl_l, i)
            scc = array.get(cl_s, i)
            mm = array.get(cma, i)
            isnr = i == ni and i_nrst
            dist_pct = close != 0 ? math.abs(p - close) / close * 100 : 0

            // Dynamischer X-Offset gegen Überlappung
            if prev_price >= 0 and (p - prev_price) < min_gap
                col_cycle := col_cycle + 1
            else
                col_cycle := 0
            x_off = 3 + col_cycle * 14
            prev_price := p

            // Farb-Hierarchie
            tc = lcc > scc ? c_tl : c_ts
            if ct >= 6
                tc := c_ext
            else if ct >= 4
                tc := c_hot

            // Relevanz-Score für Priorisierung
            rel_score = 0.0
            rel_score += math.min(1.0, float(ct) / 6.0) * 0.4
            rel_score += (max_mm > 0 ? math.min(1.0, mm / max_mm) : 0) * 0.3
            dist_norm = close > 0 ? math.min(1.0, math.abs(p - close) / (sa * 10)) : 1.0
            rel_score += (1.0 - dist_norm) * 0.3

            // Opacity basierend auf Relevanz
            label_opac = 30
            if i_prio
                if rel_score < 0.3
                    label_opac := 60
                else if rel_score < 0.5
                    label_opac := 40

            // Kompakter Label-Text
            anchor = ct >= 4 ? "◆" : ct >= 2 ? "●" : "○"
            t = anchor + " " + str.tostring(ct) + "×"
            if lcc > 0 and scc > 0
                t := t + " L" + str.tostring(lcc) + "·S" + str.tostring(scc)
            else if lcc > 0
                t := t + " Long"
            else
                t := t + " Short"

            if mm >= i_mth
                t := t + "  ·  $" + str.tostring(mm, "#.0") + "M"

            if isnr
                t := "▶ " + t

            // Tooltip
            typ = lcc > scc ? "Long" : lcc < scc ? "Short" : "Gemischt"
            dir = p > close ? "oberhalb" : "unterhalb"
            tt = "═════════════════\n"
            tt := tt + "  TraxisLab · Liquidation\n"
            tt := tt + "═════════════════\n"
            tt := tt + "  Preis      " + str.tostring(p, format.mintick) + "\n"
            tt := tt + "  Typ         " + str.tostring(ct) + "× " + typ + "\n"
            tt := tt + "  Volumen   $" + str.tostring(mm, "#.0") + "M\n"
            tt := tt + "─────────────────\n"
            tt := tt + "  Long        " + str.tostring(lcc) + " Zonen\n"
            tt := tt + "  Short       " + str.tostring(scc) + " Zonen\n"
            tt := tt + "  Abstand   " + str.tostring(dist_pct, "#.00") + "% " + dir + "\n"
            if i_use_anc
                tt := tt + "  Quelle    " + i_anchor + "\n"
            tt := tt + "─────────────────\n"
            tt := tt + "  Relevanz  " + str.tostring(math.round(rel_score * 100)) + "/100"

            bg = isnr ? color.new(c_nr, 35) : color.new(#0a0a12, label_opac)
            array.push(sla, label.new(x=bar_index + x_off, y=p, text=t, xloc=xloc.bar_index, yloc=yloc.price, color=bg, style=label.style_label_left, textcolor=tc, size=lsz, textalign=text.align_left, tooltip=tt))

            // Cluster-Linien — mehrschichtig
            if i_lin and ct >= 2
                if isnr
                    // Pulsierender Look: 3 gestaffelte Linien
                    array.push(lna, line.new(bar_index - 8, p, bar_index + x_off - 2, p, color=color.new(c_nr, 0), width=2, style=line.style_solid))
                    array.push(lna, line.new(bar_index - 12, p, bar_index - 8, p, color=color.new(c_nr, 40), width=1, style=line.style_solid))
                    array.push(lna, line.new(bar_index - 16, p, bar_index - 12, p, color=color.new(c_nr, 70), width=1, style=line.style_solid))
                else
                    base_col = lcc > scc ? c_lb : c_sb
                    line_opac = ct >= 5 ? 25 : ct >= 4 ? 40 : ct >= 3 ? 55 : 70
                    if i_prio and rel_score < 0.4
                        line_opac := math.min(85, line_opac + 20)
                    ls = ct >= 4 ? line.style_solid : ct >= 3 ? line.style_dashed : line.style_dotted
                    lw = ct >= 5 ? 2 : 1
                    // Gradient-Effekt: schwächere Enden
                    array.push(lna, line.new(bar_index - 10, p, bar_index + x_off - 2, p, color=color.new(base_col, line_opac), width=lw, style=ls))
                    if ct >= 4
                        array.push(lna, line.new(bar_index - 14, p, bar_index - 10, p, color=color.new(base_col, math.min(90, line_opac + 25)), width=1, style=line.style_dotted))

    // Nearest Zone — elegantes Pointer-Label
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
        nt = "  " + dr + "  " + str.tostring(dp, "#.00") + "%"
        if nm >= 1
            nt := nt + "  ·  $" + str.tostring(nm, "#.0") + "M  "
        ntt = "═════════════════\n  NÄCHSTE ZIELZONE\n═════════════════\n  Preis        " + str.tostring(np, format.mintick) + "\n  Abstand    " + str.tostring(dp, "#.00") + "%\n  Volumen   $" + str.tostring(nm, "#.0") + "M"

        // Pointer-Badge weiter rechts platziert
        array.push(sla, label.new(x=bar_index + 40, y=np, text=nt, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(c_nr, 20), style=label.style_label_left, textcolor=color.white, size=size.small, textalign=text.align_left, tooltip=ntt))

// ═══════════════════════════════════════════
// TABLE — Premium Cockpit Design
// ═══════════════════════════════════════════

var table tb = table.new(position.bottom_right, 4, 5, bgcolor=color.new(#0a0a12, 8), border_color=color.new(#2a2a3a, 40), border_width=1, frame_color=color.new(#2a2a3a, 30), frame_width=1)

if i_tbl and barstate.islast
    // Header-Zeile
    table.cell(tb, 0, 0, "◆ TraxisLab", text_color=color.new(color.white, 0), text_size=size.small, bgcolor=color.new(#1a1a28, 20))
    table.cell(tb, 1, 0, "LIQ", text_color=color.new(#787b86, 0), text_size=size.tiny, bgcolor=color.new(#1a1a28, 20))
    table.cell(tb, 2, 0, "", bgcolor=color.new(#1a1a28, 20))
    table.cell(tb, 3, 0, "", bgcolor=color.new(#1a1a28, 20))

    // Spalten-Header
    table.cell(tb, 0, 1, "Richtung", text_color=#5a5e70, text_size=size.tiny)
    table.cell(tb, 1, 1, "Preis", text_color=#5a5e70, text_size=size.tiny)
    table.cell(tb, 2, 1, "Distanz", text_color=#5a5e70, text_size=size.tiny)
    table.cell(tb, 3, 1, "Volumen", text_color=#5a5e70, text_size=size.tiny)

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

    // Short oben
    if fa
        dist_a = close > 0 ? (ap - close) / close * 100 : 0
        table.cell(tb, 0, 2, "▲ Short", text_color=c_ts, text_size=size.tiny)
        table.cell(tb, 1, 2, str.tostring(ap, format.mintick), text_color=color.white, text_size=size.tiny)
        table.cell(tb, 2, 2, "+" + str.tostring(dist_a, "#.00") + "%", text_color=c_ts, text_size=size.tiny)
        table.cell(tb, 3, 2, "$" + str.tostring(am, "#.0") + "M", text_color=c_ts, text_size=size.tiny)
    else
        table.cell(tb, 0, 2, "▲ Short", text_color=#3a3d48, text_size=size.tiny)
        table.cell(tb, 1, 2, "—", text_color=#3a3d48, text_size=size.tiny)
        table.cell(tb, 2, 2, "—", text_color=#3a3d48, text_size=size.tiny)
        table.cell(tb, 3, 2, "—", text_color=#3a3d48, text_size=size.tiny)

    // Long unten
    if fb
        dist_b = close > 0 ? (bp - close) / close * 100 : 0
        table.cell(tb, 0, 3, "▼ Long", text_color=c_tl, text_size=size.tiny)
        table.cell(tb, 1, 3, str.tostring(bp, format.mintick), text_color=color.white, text_size=size.tiny)
        table.cell(tb, 2, 3, str.tostring(dist_b, "#.00") + "%", text_color=c_tl, text_size=size.tiny)
        table.cell(tb, 3, 3, "$" + str.tostring(bm_v, "#.0") + "M", text_color=c_tl, text_size=size.tiny)
    else
        table.cell(tb, 0, 3, "▼ Long", text_color=#3a3d48, text_size=size.tiny)
        table.cell(tb, 1, 3, "—", text_color=#3a3d48, text_size=size.tiny)
        table.cell(tb, 2, 3, "—", text_color=#3a3d48, text_size=size.tiny)
        table.cell(tb, 3, 3, "—", text_color=#3a3d48, text_size=size.tiny)

    // Footer mit Gesamt-Stats
    tm = 0.0
    if ncl2 > 0
        for i = 0 to ncl2 - 1
            tm += array.get(cma, i)
    src_txt = i_use_anc ? "● LIVE" : "○ CHART"
    src_col = i_use_anc ? #00c853 : #787b86
    table.cell(tb, 0, 4, src_txt, text_color=src_col, text_size=size.tiny, bgcolor=color.new(#1a1a28, 40))
    table.cell(tb, 1, 4, str.tostring(array.size(bxs)) + " Zonen", text_color=#787b86, text_size=size.tiny, bgcolor=color.new(#1a1a28, 40))
    table.cell(tb, 2, 4, str.tostring(ncl2) + " Cluster", text_color=#787b86, text_size=size.tiny, bgcolor=color.new(#1a1a28, 40))
    table.cell(tb, 3, 4, "Σ $" + str.tostring(tm, "#") + "M", text_color=c_hot, text_size=size.tiny, bgcolor=color.new(#1a1a28, 40))

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
