# Futures Gamma Levels

- url: https://www.tradingview.com/script/6DRDbpqD-Futures-Gamma-Levels/
- type: indicator
- pine_id: PUB;2bd0a68a0bd44789af7971e01af6f3a1
- version: 4.0

## Description

[b]Futures GEX Levels[/b]
Brings Gamma Exposure (GEX) levels from options markets directly onto your futures charts — fully converted and price-locked. A single indicator that works across NQ, ES, GC, and SI futures with zero configuration needed between charts.
Designed for active futures daytraders who use GammaLens (gammalens.markets) as their GEX data source.

[b]The Problem This Solves[/b]
Futures contracts like NQ, ES, GC, and SI have no meaningful native options chain. The gamma levels that actually drive price action on these instruments come from their ETF and index equivalents — QQQ, SPX, GLD, and SLV respectively. But those levels are priced in ETF/index terms, not futures terms. Overlaying them raw on a futures chart puts every level in the wrong place.
This indicator solves that by automatically detecting which futures chart you are on, fetching the matching ETF or index price via request.security(), calculating the live ratio, and converting all gamma levels into the correct futures price coordinates — in real time, on every bar.

[b]Supported Instruments[/b]
NQ1! / MNQ1! → QQQ options → NQ/QQQ ratio
ES1! / MES1! → SPX options → ES/SPX ratio
GC1! / MGC1! → GLD options → GC/GLD ratio
SI1! / SIL1! → SLV options → SI/SLV ratio
SPX is used as the source for ES rather than SPY, as SPX has significantly deeper options liquidity and is the more accurate representation of dealer gamma positioning for S&P 500 futures.

[b]What Gets Plotted[/b]
[b]Call Wal[/b]l — Highest positive GEX strike. Dealers are heavily long gamma here, selling into rallies. Acts as strong resistance.
[b]Put Wall[/b] — Most negative GEX strike. Acts as support, but a break below can accelerate selling as dealers flip their hedge.
[b]HVL / Gamma Flip[/b] — The regime boundary. Above it: dealers are net long gamma, dampening volatility, market tends to mean-revert. Below it: dealers are net short gamma, amplifying moves, market tends to trend.
[b]GEX Levels 1–10[/b] — Secondary gamma strikes ranked by magnitude. These act as additional support/resistance zones where dealer hedging flows are concentrated.
All levels are color-coded, labeled directly above each line in white text, and fully customizable in the settings.

[b]How It Works — The Conversion[/b]
Pine Script cannot make external HTTP requests, so GEX data cannot be pulled automatically. Instead, this indicator acts as a precision conversion and visualization layer on top of your preferred GEX data source.
Each morning you paste the ETF/index gamma levels from GammaLens into the appropriate input group in the settings. The indicator then fetches the live ETF or index price using request.security(), divides the current futures price by the ETF price to get a live ratio, multiplies every input level by that ratio to convert it to futures terms, and draws each level as a horizontal line anchored via xloc.bar_time — so lines stay locked to their price level regardless of how you scroll or zoom.

[b]Setup (30 seconds each morning)[/b]
Add the indicator to any supported futures chart — it auto-detects the instrument
Open GammaLens (gammalens.markets) and look up the matching source: NQ → QQQ | ES → SPX | GC → GLD | SI → SLV
Open indicator Settings and find the correct input group for your chart
Paste in the gamma levels (Call Wall, Put Wall, HVL, and any GEX levels you want)
Lines appear immediately, price-locked and labeled

The same settings persist across all four instruments — you only need to fill in the group matching the chart you are currently on.

[b]Info Table[/b]
A small table in the top-right corner dynamically displays the active instrument pair label, live futures price, live ETF/index price, and the calculated ratio — so you can verify the conversion is current and accurate at a glance.

[b]Notes[/b]
Set any level to 0 to hide it. The ratio updates live on every bar, so [i]converted levels drift slightly intraday as the futures/ETF spread moves — this is normal and expected behavior[/i]. Best used on intraday timeframes (1m–15m) for daytrading context.
[b]This indicator does not calculate GEX internally. It is a visualization layer designed to work with externally sourced data. GammaLens and Barchart offers a free tier covering QQQ, SPX, GLD, and SLV — which maps directly to all four instruments this indicator supports.[/b]

## Source Code

````pine
//@version=6
indicator("Futures Gamma Levels V2", overlay=true, max_lines_count=52, max_labels_count=52, max_boxes_count=52)

// ═══════════════════════════════════════════════════════════════
//  Futures GEX Levels
//  Converts ETF/Index gamma exposure levels to futures prices.
//
//  Supported instruments (auto-detected):
//    NQ1! / MNQ1!  ←  QQQ options
//    ES1! / MES1!  ←  SPX options
//    GC1! / MGC1!  ←  GLD options
//    SI1! / SIL1!  ←  SLV options
//
//  HOW TO USE:
//  1. Open any supported futures chart
//  2. Each morning, go to gammalens.markets or barchart.com and look up
//     the matching ETF/Index (QQQ, SPX, GLD, SLV)
//  3. Paste the gamma levels into the correct input group
//  4. Lines auto-convert to futures prices via the conversion ratio,
//     which is locked at the 09:30 ET open so levels stay stable
// ═══════════════════════════════════════════════════════════════

// ── Instrument Detection ──
is_nq = syminfo.root == "NQ"  or syminfo.root == "MNQ"
is_es = syminfo.root == "ES"  or syminfo.root == "MES"
is_gc = syminfo.root == "GC"  or syminfo.root == "MGC"
is_si = syminfo.root == "SI"  or syminfo.root == "SIL"

// ── Display Options ──
var grp_disp = "Display Options"
show_table = input.bool(true, "Show Info Table", group=grp_disp)
line_width = input.int(2,     "Line Width",       group=grp_disp, minval=1, maxval=4)

// ── Ratio ──
var grp_ratio = "Ratio"
lock_ratio = input.bool(true, "Lock ratio at session open", group=grp_ratio, tooltip="ON = the ratio is captured at the 09:30 ET RTH open and held for the rest of the day → levels stay perfectly still. OFF = live ratio (old behaviour; levels drift as the basis moves).")

// ── Zones ──
var grp_zone = "Zones"
show_zones     = input.bool(true,  "Zones on Call Wall / Put Wall / HVL", group=grp_zone)
show_gex_zones = input.bool(false, "Zones on GEX levels",                 group=grp_zone, tooltip="Off by default — ten extra bands can crowd a 1-minute chart.")
zone_mult      = input.float(2.0,  "Zone width (× 5-min ATR)",            group=grp_zone, minval=0.1, step=0.1, tooltip="Total zone height = this multiplier × the 5-minute ATR. Raise for wider bands, lower for tighter ones. This is the main knob to tune.")
atr_len        = input.int(14,     "ATR length",                          group=grp_zone, minval=1)
zone_transp    = input.int(88,     "Zone fill transparency",              group=grp_zone, minval=50, maxval=98, tooltip="Higher = fainter fill. The centre line stays fully visible either way.")

// ── Colors ──
var grp_col = "Colors"
col_call_wall = input.color(color.new(#26a69a, 0),  "Call Wall",        group=grp_col)
col_put_wall  = input.color(color.new(#ef5350, 0),  "Put Wall",         group=grp_col)
col_hvl       = input.color(color.new(#ffeb3b, 0),  "HVL / Gamma Flip", group=grp_col)
col_gex       = input.color(color.new(#b0bec5, 30), "GEX Levels",       group=grp_col)

// ── NQ — QQQ Levels ──
var grp_nq = "NQ  |  QQQ Levels (from GammaLens)"
nq_call_wall = input.float(0.0, "Call Wall",        group=grp_nq, tooltip="Highest positive GEX strike — acts as resistance")
nq_put_wall  = input.float(0.0, "Put Wall",         group=grp_nq, tooltip="Most negative GEX strike — acts as support")
nq_hvl       = input.float(0.0, "HVL / Gamma Flip", group=grp_nq, tooltip="Above = positive gamma (range-bound), Below = negative gamma (trending)")
nq_gex1      = input.float(0.0, "GEX Level 1",      group=grp_nq)
nq_gex2      = input.float(0.0, "GEX Level 2",      group=grp_nq)
nq_gex3      = input.float(0.0, "GEX Level 3",      group=grp_nq)
nq_gex4      = input.float(0.0, "GEX Level 4",      group=grp_nq)
nq_gex5      = input.float(0.0, "GEX Level 5",      group=grp_nq)
nq_gex6      = input.float(0.0, "GEX Level 6",      group=grp_nq)
nq_gex7      = input.float(0.0, "GEX Level 7",      group=grp_nq)
nq_gex8      = input.float(0.0, "GEX Level 8",      group=grp_nq)
nq_gex9      = input.float(0.0, "GEX Level 9",      group=grp_nq)
nq_gex10     = input.float(0.0, "GEX Level 10",     group=grp_nq)

// ── ES — SPX Levels ──
var grp_es = "ES  |  SPX Levels (from GammaLens)"
es_call_wall = input.float(0.0, "Call Wall",        group=grp_es, tooltip="Highest positive GEX strike — acts as resistance")
es_put_wall  = input.float(0.0, "Put Wall",         group=grp_es, tooltip="Most negative GEX strike — acts as support")
es_hvl       = input.float(0.0, "HVL / Gamma Flip", group=grp_es, tooltip="Above = positive gamma (range-bound), Below = negative gamma (trending)")
es_gex1      = input.float(0.0, "GEX Level 1",      group=grp_es)
es_gex2      = input.float(0.0, "GEX Level 2",      group=grp_es)
es_gex3      = input.float(0.0, "GEX Level 3",      group=grp_es)
es_gex4      = input.float(0.0, "GEX Level 4",      group=grp_es)
es_gex5      = input.float(0.0, "GEX Level 5",      group=grp_es)
es_gex6      = input.float(0.0, "GEX Level 6",      group=grp_es)
es_gex7      = input.float(0.0, "GEX Level 7",      group=grp_es)
es_gex8      = input.float(0.0, "GEX Level 8",      group=grp_es)
es_gex9      = input.float(0.0, "GEX Level 9",      group=grp_es)
es_gex10     = input.float(0.0, "GEX Level 10",     group=grp_es)

// ── GC — GLD Levels ──
var grp_gc = "GC  |  GLD Levels (from GammaLens)"
gc_call_wall = input.float(0.0, "Call Wall",        group=grp_gc, tooltip="Highest positive GEX strike — acts as resistance")
gc_put_wall  = input.float(0.0, "Put Wall",         group=grp_gc, tooltip="Most negative GEX strike — acts as support")
gc_hvl       = input.float(0.0, "HVL / Gamma Flip", group=grp_gc, tooltip="Above = positive gamma (range-bound), Below = negative gamma (trending)")
gc_gex1      = input.float(0.0, "GEX Level 1",      group=grp_gc)
gc_gex2      = input.float(0.0, "GEX Level 2",      group=grp_gc)
gc_gex3      = input.float(0.0, "GEX Level 3",      group=grp_gc)
gc_gex4      = input.float(0.0, "GEX Level 4",      group=grp_gc)
gc_gex5      = input.float(0.0, "GEX Level 5",      group=grp_gc)
gc_gex6      = input.float(0.0, "GEX Level 6",      group=grp_gc)
gc_gex7      = input.float(0.0, "GEX Level 7",      group=grp_gc)
gc_gex8      = input.float(0.0, "GEX Level 8",      group=grp_gc)
gc_gex9      = input.float(0.0, "GEX Level 9",      group=grp_gc)
gc_gex10     = input.float(0.0, "GEX Level 10",     group=grp_gc)

// ── SI — SLV Levels ──
var grp_si = "SI  |  SLV Levels (from GammaLens)"
si_call_wall = input.float(0.0, "Call Wall",        group=grp_si, tooltip="Highest positive GEX strike — acts as resistance")
si_put_wall  = input.float(0.0, "Put Wall",         group=grp_si, tooltip="Most negative GEX strike — acts as support")
si_hvl       = input.float(0.0, "HVL / Gamma Flip", group=grp_si, tooltip="Above = positive gamma (range-bound), Below = negative gamma (trending)")
si_gex1      = input.float(0.0, "GEX Level 1",      group=grp_si)
si_gex2      = input.float(0.0, "GEX Level 2",      group=grp_si)
si_gex3      = input.float(0.0, "GEX Level 3",      group=grp_si)
si_gex4      = input.float(0.0, "GEX Level 4",      group=grp_si)
si_gex5      = input.float(0.0, "GEX Level 5",      group=grp_si)
si_gex6      = input.float(0.0, "GEX Level 6",      group=grp_si)
si_gex7      = input.float(0.0, "GEX Level 7",      group=grp_si)
si_gex8      = input.float(0.0, "GEX Level 8",      group=grp_si)
si_gex9      = input.float(0.0, "GEX Level 9",      group=grp_si)
si_gex10     = input.float(0.0, "GEX Level 10",     group=grp_si)

// ═══════════════════════════════════════════════════════════════
//  CONVERSION — fetch ETF/index price, compute live ratio,
//  then select active input group based on detected instrument
// ═══════════════════════════════════════════════════════════════
qqq_price = request.security("QQQ",    timeframe.period, close)
spx_price = request.security("SP:SPX", timeframe.period, close)
gld_price = request.security("GLD",    timeframe.period, close)
slv_price = request.security("SLV",    timeframe.period, close)

fut_price = close

// Select the right ETF price and input group for this chart
etf_price  = is_nq ? qqq_price :
             is_es ? spx_price :
             is_gc ? gld_price :
             is_si ? slv_price : na

live_ratio = fut_price / etf_price

// ── Ratio lock ──
// Gamma levels are a static daily value, so the conversion ratio should be
// static too. Recomputing it every tick from two independently moving prices
// is what makes the levels jitter — and overnight, when the ETF is closed but
// futures keep trading, the basis drifts badly.
// Fix: capture the ratio once on the first RTH bar of each day and hold it.
new_day = timeframe.change("D")
in_rth  = not na(time(timeframe.period, "0930-1600", "America/New_York"))

var float locked_ratio = na
if new_day
    locked_ratio := na
if in_rth and na(locked_ratio) and not na(live_ratio)
    locked_ratio := live_ratio

// Before RTH opens (Globex overnight) fall back to the live ratio —
// it's the best estimate available until the ETF starts trading.
ratio        = lock_ratio ? (na(locked_ratio) ? live_ratio : locked_ratio) : live_ratio
ratio_locked = lock_ratio and not na(locked_ratio)

// ═══════════════════════════════════════════════════════════════
//  ZONE WIDTH — live 5-minute ATR
//  The levels themselves are fixed (locked ratio), but the band around
//  them breathes with current short-term volatility. [1] reads the last
//  *confirmed* 5-min bar, so the zone steps cleanly instead of wobbling
//  intrabar. ATR is measured on the futures chart itself, so it needs no
//  ratio conversion.
// ═══════════════════════════════════════════════════════════════
atr_5m    = request.security(syminfo.tickerid, "5", ta.atr(atr_len)[1], lookahead=barmerge.lookahead_off)
atr_local = ta.atr(atr_len)[1]

// On 5-minute charts and higher, fall back to the chart's own ATR.
atr_used  = timeframe.in_seconds() <= 300 ? atr_5m : atr_local
zone_half = na(atr_used) ? na : (atr_used * zone_mult) / 2.0

// Select and convert the active input group
raw_call_wall = is_nq ? nq_call_wall : is_es ? es_call_wall : is_gc ? gc_call_wall : is_si ? si_call_wall : 0.0
raw_put_wall  = is_nq ? nq_put_wall  : is_es ? es_put_wall  : is_gc ? gc_put_wall  : is_si ? si_put_wall  : 0.0
raw_hvl       = is_nq ? nq_hvl       : is_es ? es_hvl       : is_gc ? gc_hvl       : is_si ? si_hvl       : 0.0
raw_gex1      = is_nq ? nq_gex1      : is_es ? es_gex1      : is_gc ? gc_gex1      : is_si ? si_gex1      : 0.0
raw_gex2      = is_nq ? nq_gex2      : is_es ? es_gex2      : is_gc ? gc_gex2      : is_si ? si_gex2      : 0.0
raw_gex3      = is_nq ? nq_gex3      : is_es ? es_gex3      : is_gc ? gc_gex3      : is_si ? si_gex3      : 0.0
raw_gex4      = is_nq ? nq_gex4      : is_es ? es_gex4      : is_gc ? gc_gex4      : is_si ? si_gex4      : 0.0
raw_gex5      = is_nq ? nq_gex5      : is_es ? es_gex5      : is_gc ? gc_gex5      : is_si ? si_gex5      : 0.0
raw_gex6      = is_nq ? nq_gex6      : is_es ? es_gex6      : is_gc ? gc_gex6      : is_si ? si_gex6      : 0.0
raw_gex7      = is_nq ? nq_gex7      : is_es ? es_gex7      : is_gc ? gc_gex7      : is_si ? si_gex7      : 0.0
raw_gex8      = is_nq ? nq_gex8      : is_es ? es_gex8      : is_gc ? gc_gex8      : is_si ? si_gex8      : 0.0
raw_gex9      = is_nq ? nq_gex9      : is_es ? es_gex9      : is_gc ? gc_gex9      : is_si ? si_gex9      : 0.0
raw_gex10     = is_nq ? nq_gex10     : is_es ? es_gex10     : is_gc ? gc_gex10     : is_si ? si_gex10     : 0.0

// Apply ratio conversion
conv_call_wall = raw_call_wall * ratio
conv_put_wall  = raw_put_wall  * ratio
conv_hvl       = raw_hvl       * ratio
conv_gex1      = raw_gex1      * ratio
conv_gex2      = raw_gex2      * ratio
conv_gex3      = raw_gex3      * ratio
conv_gex4      = raw_gex4      * ratio
conv_gex5      = raw_gex5      * ratio
conv_gex6      = raw_gex6      * ratio
conv_gex7      = raw_gex7      * ratio
conv_gex8      = raw_gex8      * ratio
conv_gex9      = raw_gex9      * ratio
conv_gex10     = raw_gex10     * ratio

// ═══════════════════════════════════════════════════════════════
//  LINES & LABELS
//  xloc.bar_time anchors lines to timestamps, not bar index —
//  they stay locked to price when scrolling and zooming.
// ═══════════════════════════════════════════════════════════════
var line  l_cw  = na,  var label lb_cw  = na
var line  l_pw  = na,  var label lb_pw  = na
var line  l_hvl = na,  var label lb_hvl = na
var line  l_g1  = na,  var label lb_g1  = na
var line  l_g2  = na,  var label lb_g2  = na
var line  l_g3  = na,  var label lb_g3  = na
var line  l_g4  = na,  var label lb_g4  = na
var line  l_g5  = na,  var label lb_g5  = na
var line  l_g6  = na,  var label lb_g6  = na
var line  l_g7  = na,  var label lb_g7  = na
var line  l_g8  = na,  var label lb_g8  = na
var line  l_g9  = na,  var label lb_g9  = na
var line  l_g10 = na,  var label lb_g10 = na

// Helper: update line in place
update_line(l, price, col) =>
    if not na(l)
        line.set_y1(l, price)
        line.set_y2(l, price)
        line.set_color(l, col)
        line.set_width(l, line_width)

// Helper: create or update label — v6 compliant (returns value, no arg mutation)
update_label(lb, price, col, txt) =>
    result = lb
    if price > 0
        if na(lb)
            result := label.new(bar_index + 5, price, txt,
                 color=color.new(col, 100), textcolor=color.white,
                 style=label.style_label_lower_left, size=size.normal)
        else
            label.set_x(lb, bar_index + 5)
            label.set_y(lb, price)
            label.set_text(lb, txt)
            label.set_textcolor(lb, color.white)
            label.set_color(lb, color.new(col, 100))
            label.set_style(lb, label.style_label_lower_left)
            label.set_size(lb, size.normal)
    else
        if not na(lb)
            label.delete(lb)
            result := na
    result

// ═══════════════════════════════════════════════════════════════
//  ZONES
//  Drawn before the lines so the soft band sits behind the sharp
//  centre line. The line still marks the exact strike; the zone shows
//  the reaction band around it.
// ═══════════════════════════════════════════════════════════════
var box z_cw  = na
var box z_pw  = na
var box z_hvl = na
var box z_g1  = na
var box z_g2  = na
var box z_g3  = na
var box z_g4  = na
var box z_g5  = na
var box z_g6  = na
var box z_g7  = na
var box z_g8  = na
var box z_g9  = na
var box z_g10 = na

// Helper: create or update a zone — v6 compliant (returns value, no arg mutation)
update_zone(bx, price, col, show) =>
    result = bx
    if show and price > 0 and not na(zone_half)
        border_col = color.new(col, math.max(zone_transp - 25, 0))
        fill_col   = color.new(col, zone_transp)
        if na(bx)
            result := box.new(time, price + zone_half, time + 1, price - zone_half,
                 xloc=xloc.bar_time, extend=extend.both,
                 border_color=border_col, border_width=1, bgcolor=fill_col)
        else
            box.set_top(bx,          price + zone_half)
            box.set_bottom(bx,       price - zone_half)
            box.set_border_color(bx, border_col)
            box.set_bgcolor(bx,      fill_col)
    else
        if not na(bx)
            box.delete(bx)
            result := na
    result

z_cw  := update_zone(z_cw,  conv_call_wall, col_call_wall, show_zones)
z_pw  := update_zone(z_pw,  conv_put_wall,  col_put_wall,  show_zones)
z_hvl := update_zone(z_hvl, conv_hvl,       col_hvl,       show_zones)
z_g1  := update_zone(z_g1,  conv_gex1,      col_gex,       show_gex_zones)
z_g2  := update_zone(z_g2,  conv_gex2,      col_gex,       show_gex_zones)
z_g3  := update_zone(z_g3,  conv_gex3,      col_gex,       show_gex_zones)
z_g4  := update_zone(z_g4,  conv_gex4,      col_gex,       show_gex_zones)
z_g5  := update_zone(z_g5,  conv_gex5,      col_gex,       show_gex_zones)
z_g6  := update_zone(z_g6,  conv_gex6,      col_gex,       show_gex_zones)
z_g7  := update_zone(z_g7,  conv_gex7,      col_gex,       show_gex_zones)
z_g8  := update_zone(z_g8,  conv_gex8,      col_gex,       show_gex_zones)
z_g9  := update_zone(z_g9,  conv_gex9,      col_gex,       show_gex_zones)
z_g10 := update_zone(z_g10, conv_gex10,     col_gex,       show_gex_zones)

// ── Draw levels ──
// Call Wall
if raw_call_wall > 0
    if na(l_cw)
        l_cw := line.new(time, conv_call_wall, time + 1, conv_call_wall, xloc=xloc.bar_time, color=col_call_wall, width=line_width, extend=extend.both)
    else
        update_line(l_cw, conv_call_wall, col_call_wall)
else if not na(l_cw)
    line.delete(l_cw)
    l_cw := na
lb_cw := update_label(lb_cw, conv_call_wall, col_call_wall, " Call Wall  " + str.tostring(math.round(conv_call_wall, 0)))

// Put Wall
if raw_put_wall > 0
    if na(l_pw)
        l_pw := line.new(time, conv_put_wall, time + 1, conv_put_wall, xloc=xloc.bar_time, color=col_put_wall, width=line_width, extend=extend.both)
    else
        update_line(l_pw, conv_put_wall, col_put_wall)
else if not na(l_pw)
    line.delete(l_pw)
    l_pw := na
lb_pw := update_label(lb_pw, conv_put_wall, col_put_wall, " Put Wall  " + str.tostring(math.round(conv_put_wall, 0)))

// HVL
if raw_hvl > 0
    if na(l_hvl)
        l_hvl := line.new(time, conv_hvl, time + 1, conv_hvl, xloc=xloc.bar_time, color=col_hvl, width=line_width, extend=extend.both)
    else
        update_line(l_hvl, conv_hvl, col_hvl)
else if not na(l_hvl)
    line.delete(l_hvl)
    l_hvl := na
lb_hvl := update_label(lb_hvl, conv_hvl, col_hvl, "⚡ HVL  " + str.tostring(math.round(conv_hvl, 0)))

// GEX 1
if raw_gex1 > 0
    if na(l_g1)
        l_g1 := line.new(time, conv_gex1, time + 1, conv_gex1, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g1, conv_gex1, col_gex)
else if not na(l_g1)
    line.delete(l_g1)
    l_g1 := na
lb_g1 := update_label(lb_g1, conv_gex1, col_gex, "◆ GEX 1  " + str.tostring(math.round(conv_gex1, 0)))

// GEX 2
if raw_gex2 > 0
    if na(l_g2)
        l_g2 := line.new(time, conv_gex2, time + 1, conv_gex2, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g2, conv_gex2, col_gex)
else if not na(l_g2)
    line.delete(l_g2)
    l_g2 := na
lb_g2 := update_label(lb_g2, conv_gex2, col_gex, "◆ GEX 2  " + str.tostring(math.round(conv_gex2, 0)))

// GEX 3
if raw_gex3 > 0
    if na(l_g3)
        l_g3 := line.new(time, conv_gex3, time + 1, conv_gex3, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g3, conv_gex3, col_gex)
else if not na(l_g3)
    line.delete(l_g3)
    l_g3 := na
lb_g3 := update_label(lb_g3, conv_gex3, col_gex, "◆ GEX 3  " + str.tostring(math.round(conv_gex3, 0)))

// GEX 4
if raw_gex4 > 0
    if na(l_g4)
        l_g4 := line.new(time, conv_gex4, time + 1, conv_gex4, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g4, conv_gex4, col_gex)
else if not na(l_g4)
    line.delete(l_g4)
    l_g4 := na
lb_g4 := update_label(lb_g4, conv_gex4, col_gex, "◆ GEX 4  " + str.tostring(math.round(conv_gex4, 0)))

// GEX 5
if raw_gex5 > 0
    if na(l_g5)
        l_g5 := line.new(time, conv_gex5, time + 1, conv_gex5, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g5, conv_gex5, col_gex)
else if not na(l_g5)
    line.delete(l_g5)
    l_g5 := na
lb_g5 := update_label(lb_g5, conv_gex5, col_gex, "◆ GEX 5  " + str.tostring(math.round(conv_gex5, 0)))

// GEX 6
if raw_gex6 > 0
    if na(l_g6)
        l_g6 := line.new(time, conv_gex6, time + 1, conv_gex6, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g6, conv_gex6, col_gex)
else if not na(l_g6)
    line.delete(l_g6)
    l_g6 := na
lb_g6 := update_label(lb_g6, conv_gex6, col_gex, "◆ GEX 6  " + str.tostring(math.round(conv_gex6, 0)))

// GEX 7
if raw_gex7 > 0
    if na(l_g7)
        l_g7 := line.new(time, conv_gex7, time + 1, conv_gex7, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g7, conv_gex7, col_gex)
else if not na(l_g7)
    line.delete(l_g7)
    l_g7 := na
lb_g7 := update_label(lb_g7, conv_gex7, col_gex, "◆ GEX 7  " + str.tostring(math.round(conv_gex7, 0)))

// GEX 8
if raw_gex8 > 0
    if na(l_g8)
        l_g8 := line.new(time, conv_gex8, time + 1, conv_gex8, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g8, conv_gex8, col_gex)
else if not na(l_g8)
    line.delete(l_g8)
    l_g8 := na
lb_g8 := update_label(lb_g8, conv_gex8, col_gex, "◆ GEX 8  " + str.tostring(math.round(conv_gex8, 0)))

// GEX 9
if raw_gex9 > 0
    if na(l_g9)
        l_g9 := line.new(time, conv_gex9, time + 1, conv_gex9, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g9, conv_gex9, col_gex)
else if not na(l_g9)
    line.delete(l_g9)
    l_g9 := na
lb_g9 := update_label(lb_g9, conv_gex9, col_gex, "◆ GEX 9  " + str.tostring(math.round(conv_gex9, 0)))

// GEX 10
if raw_gex10 > 0
    if na(l_g10)
        l_g10 := line.new(time, conv_gex10, time + 1, conv_gex10, xloc=xloc.bar_time, color=col_gex, width=line_width, extend=extend.both)
    else
        update_line(l_g10, conv_gex10, col_gex)
else if not na(l_g10)
    line.delete(l_g10)
    l_g10 := na
lb_g10 := update_label(lb_g10, conv_gex10, col_gex, "◆ GEX 10  " + str.tostring(math.round(conv_gex10, 0)))

// ═══════════════════════════════════════════════════════════════
//  INFO TABLE — shows active instrument pair and conversion ratio
//  🔒 = ratio locked at RTH open   ●  = live ratio
// ═══════════════════════════════════════════════════════════════
if show_table
    etf_label = is_nq ? "QQQ" : is_es ? "SPX" : is_gc ? "GLD" : is_si ? "SLV" : "—"
    fut_label = syminfo.root

    var table info = table.new(position.top_right, 2, 5,
         border_color=color.new(color.gray, 60), border_width=1,
         bgcolor=color.new(color.black, 75))
    table.cell(info, 0, 0, fut_label + "/" + etf_label + " Ratio", text_color=color.gray,   text_size=size.small)
    table.cell(info, 1, 0, str.tostring(math.round(ratio, 4)) + (ratio_locked ? " 🔒" : " ●"),
         text_color=ratio_locked ? color.white : color.orange, text_size=size.small)
    table.cell(info, 0, 1, fut_label + " Price",                    text_color=color.gray,   text_size=size.small)
    table.cell(info, 1, 1, str.tostring(math.round(fut_price, 2)),  text_color=color.white,  text_size=size.small)
    table.cell(info, 0, 2, etf_label + " Price",                    text_color=color.gray,   text_size=size.small)
    table.cell(info, 1, 2, str.tostring(math.round(etf_price, 2)),  text_color=color.white,  text_size=size.small)
    table.cell(info, 0, 3, "Zone Width",                            text_color=color.gray,   text_size=size.small)
    table.cell(info, 1, 3, na(zone_half) ? "—" : str.tostring(math.round(zone_half * 2, 2)),
         text_color=color.white, text_size=size.small)
    table.cell(info, 0, 4, "Levels Date",                           text_color=color.gray,   text_size=size.small)
    table.cell(info, 1, 4, str.format("{0,date,MM/dd/yyyy}", timenow), text_color=color.yellow, text_size=size.small)
````
