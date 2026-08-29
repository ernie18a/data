<!-- tradingview-pine-id: PUB;ae48269d4e7d44bc967c313223a7a488 -->
<!-- tradingviewscripts-format: 1 -->
# GCGrid — Psych Levels NomadaScalper

Source: https://www.tradingview.com/script/ZIQRZaiD-GCGrid-Psych-Levels-NomadaScalper/

## Description

# GCGrid, Psych Levels (NomadaScalper)

**Dual absolute grid of psychological levels for gold: every $100 and every $250, drawn as reaction zones instead of single lines.**

## What this is

Gold trades in the thousands, and round prices carry real weight up there. Whole hundreds like 4,100 or 4,300, and the bigger quarter thousand steps like 4,250 or 4,500, are the numbers people keep in their heads, park orders around and quote to each other. GCGrid draws that map for you and then stays out of the way.

Everything on the chart is absolute. A level is a multiple of 100 or a multiple of 250, and that is the whole definition. Nothing comes from a lookback window, a pivot search, a moving average or a fitted parameter. The consequence matters more than it sounds: the same levels appear on the 1 minute and on the daily, on any broker feed, on any date range, and they never shift after a candle closes.

I built this because I got tired of redrawing the same hundreds by hand every session, and because I wanted the two scales visible at once without the chart turning into a ladder of identical lines.

## How the grid is built

The script takes the current close and walks outward in both directions on each grid. You choose how many levels you want above and below price for each layer, up to four on each side, so the chart only ever shows the neighbourhood you are actually trading in.

Each level is drawn as a band rather than a line. You set the half width in points, so a half width of 5 on the $100 grid means 4,300 is shown as a zone from 4,295 to 4,305. Price rarely turns exactly on a round number, it turns near it, and a band says that honestly where a hairline pretends otherwise. If you still want the exact price marked, the centreline option puts a solid hairline at the level itself inside the band.

There is an opacity hierarchy so the chart reads at a glance. The nearest level on each side is drawn strongest and outer levels fade as they get further away. The $250 layer uses a wider, fainter body with a sharper edge, since a major level should announce itself by its boundary rather than by its mass, and it is painted underneath the $100 layer so the two never fight.

Every multiple of 500 belongs to both grids at the same time. By default those confluent levels are drawn once, as the wider $250 band, and flagged with a gold star chip so you can see instantly that two scales agree there. You can switch that off and have both bands drawn nested if you prefer to see the structure literally.

FastZone is the last piece of geometry: a dashed line at the 50 percent midpoint between consecutive $100 levels. It is purely a display layer and it never feeds anything else in the script. It exists because the halfway point of a hundred is where a lot of intraday rotation dies.

## The reaction markers

This is the part I spent the most time on, and the part where I wanted no ambiguity at all.

A marker is classified by the **direction of approach**, not by where the candle closes. If the previous bar closed above a zone and the current bar reaches down into it, that is marked as a Possible Support test. If the previous bar closed below a zone and the current bar reaches up into it, that is a Possible Resistance test. Falling into a level makes it support, rising into it makes it resistance. That is the whole rule, and there is nothing to tune inside it.

Three design choices keep it honest:

Markers are evaluated on confirmed bars only. Nothing appears and vanishes while a candle is still forming, and nothing repaints when you reload the chart.

The marker fires on arrival, on the first closed bar that reaches the zone from that side. One marker per level per episode, and that level only becomes eligible again once price moves more than half a grid step away from it.

The marker stays on the chart even if price later slices straight through. It flags that a test happened. It says nothing about whether the test held, and the script does not measure, store or imply any success rate anywhere.

Marker distance from the zone edge is scaled by ATR(14), so the labels sit off the candles whether you are on a 1 minute chart or a weekly one. You can show arrows, labels, both, or cap how many recent events stay visible.

## The dashboard

A compact panel that answers the questions you would otherwise squint at the chart for: which layers are active and how many levels each is showing, how many confluent levels are currently in view, the nearest level above and below the close with the signed distance in dollars to each, and the full span of what is currently drawn. Position and size are configurable, and it can be switched off entirely.

## How I use it

As context, not as a trigger. The grid tells me where the obvious prices are before the session starts, the bands tell me how much room a level realistically deserves, the star tells me which levels have two scales behind them, and the markers give me a clean record of which levels price has already come to test today and from which side. What I do with that information is a separate decision that this script does not make for me.

A practical note on scope: the 100 and 250 steps are fixed constants, chosen for gold, where price sits in the four figure range. On instruments priced very differently those steps will not be meaningful, and they are deliberately not user editable because making them editable would turn a specific idea into a generic round number tool.

## Settings summary

**Grid $100:** levels above, levels below, band half width, level labels.

**Grid $250:** on or off, levels above, levels below, band half width, level labels, duplicate removal for confluent levels.

**Level styling:** centreline inside the bands.

**Reaction markers:** on or off, style (arrow plus label, label only, arrow only), how many recent events to keep, show the level price in the marker text, marker gap as a multiple of ATR, and whether the $250 layer is marked as well.

**FastZone:** show the 50 percent midpoints, show their labels.

**Colors:** resistance, support and FastZone tints, all tuned for a light chart background by default.

**UI:** dashboard on or off, panel position, panel size.

## Credits and disclaimer

Original work by NomadaScalper. This is the public evolution of my private Key100 and KeyPoint250 scripts, merged into a single dual grid engine with the approach based marker logic added. Written in Pine Script v6.

This indicator is a charting and context tool. It does not produce buy or sell signals, it does not claim or measure any win rate, and it is not financial advice. Anything you trade is your own decision and your own risk.

---

## Source Code

````pine
// © NomadaScalper
// [GCGrid — Psych Levels: $100 + $250 dual grid for gold] - v2.2
// Original work by NomadaScalper. Evolution of the private "Key100 / KeyPoint250"
// series. v2.2: reaction markers classified by DIRECTION OF APPROACH
// (falling into a level = Possible Support; rising into it = Possible Resistance),
// evaluated on CLOSED bars only (no repaint).
//@version=6

indicator("GCGrid — Psych Levels NomadaScalper", shorttitle = "GCGrid NomadaScalper",
     overlay = true, max_lines_count = 30, max_labels_count = 200, max_boxes_count = 30)

// =============================================================================
// 1. PALETTE — Obsidian & Gold (named constants only, no inline hex when painting)
// =============================================================================

// -- HUD surfaces (dark, self-contained) --
color C_SURFACE_2 = #0F151E
color C_SURFACE_3 = #151C28
color C_CELL      = #0E141D
color C_CELL_ALT  = #121A24
color C_DIVIDER   = #212B39
color C_FRAME     = #2C3746

// -- HUD text hierarchy --
color C_TEXT_PRI  = #F1F5F9
color C_MUTED     = #C5CAD3
color C_DIM       = #99A1AE

// -- Semantics --
color C_ACCENT    = #C9A85A
color C_OK        = #5DAE83
color C_DANGER    = #CE6A62

// -- On-chart ink: DOUBLE SURFACE. Dark inks meant to sit on a LIGHT chart
//    background inside a tinted label. NOT interchangeable with HUD text above.
color C_INK_RES   = #8E2F2A
color C_INK_SUP   = #157A4E
color C_INK_FZ    = #2C4867
color C_INK_DARK  = #0A0E14   // dark ink for FILLED chips (gold star, header chip)

// -- Default zone colors (light-background tuned) --
color C_ZONE_RES  = #CE6A62
color C_ZONE_SUP  = #5DAE83
color C_ZONE_FZ   = #5A6472

// =============================================================================
// 2. ENGINE CONSTANTS  (untouched from v1.1 — display pass only)
// =============================================================================

const float STEP_1     = 100.0   // primary grid — identity of this indicator
const float STEP_2     = 250.0   // major grid
const float EPS        = 0.01    // float tolerance for level identity (never ==)
const int   BODY_BARS  = 1       // box body width in bars (extend.both does the rest)
const int   LBL_OFFSET = 5       // label offset to the right, in bars

// =============================================================================
// 3. INPUTS  (English only — §0)
// =============================================================================

const string G_G1 = "◧  Grid · $100"
i_above_1   = input.int(2,     "Levels above",            group = G_G1, minval = 1, maxval = 4)
i_below_1   = input.int(2,     "Levels below",            group = G_G1, minval = 1, maxval = 4)
i_half_1    = input.float(5.0, "Band half-width (± pts)", group = G_G1, minval = 0.5, maxval = 50.0, step = 0.5,
     tooltip = "Distance from the level to each edge. 5 = a 10 pt band (4300 → 4295-4305).")
i_lbl_1     = input.bool(true, "Show level labels",       group = G_G1)

const string G_G2 = "▦  Grid · $250"
i_show_2    = input.bool(true,  "Show $250 grid",          group = G_G2)
i_above_2   = input.int(2,      "Levels above",            group = G_G2, minval = 1, maxval = 4)
i_below_2   = input.int(2,      "Levels below",            group = G_G2, minval = 1, maxval = 4)
i_half_2    = input.float(10.0, "Band half-width (± pts)", group = G_G2, minval = 0.5, maxval = 50.0, step = 0.5,
     tooltip = "Distance from the level to each edge. 10 = a 20 pt band (4250 → 4240-4260).")
i_lbl_2     = input.bool(true,  "Show level labels",       group = G_G2)
i_dedupe    = input.bool(true,  "De-duplicate confluent levels", group = G_G2,
     tooltip = "Levels that belong to both grids (multiples of 500) are drawn once, " +
          "as the wider $250 band, flagged ★. Turn off to draw both bands nested.")

const string G_ST = "▧  Level styling"
i_centerln  = input.bool(true, "Draw centerline inside bands", group = G_ST,
     tooltip = "A solid hairline at the exact level, inside the band. " +
          "The band is the reaction zone; the line is the precise price.")

const string G_MK = "★  Reaction markers"
i_show_mk  = input.bool(true, "Show reaction markers", group = G_MK,
     tooltip = "Marks where price reached a grid zone and closed back outside it. " +
          "Evaluated on CLOSED bars only, so a marker never appears and disappears " +
          "while a candle is forming.")
i_mk_style = input.string("Arrow + label", "Marker style", group = G_MK,
     options = ["Arrow + label", "Label only", "Arrow only"])
i_mk_limit = input.int(10, "Limit to last N markers", group = G_MK, minval = 1, maxval = 20,
     tooltip = "Counts EVENTS, not objects. Arrow + label pushes two objects per event.")
i_mk_price = input.bool(true, "Show level in marker text", group = G_MK)
i_mk_gap   = input.float(0.6, "Marker gap (× ATR)", group = G_MK, minval = 0.1, maxval = 3.0, step = 0.1,
     tooltip = "Distance from the zone edge to the marker, relative to ATR(14). " +
          "Keeps markers off the candles on any timeframe.")
i_mk_250   = input.bool(true, "Also mark $250 levels", group = G_MK)

const string G_FZ = "◷  FastZone"
i_show_fz     = input.bool(true, "Show FastZone (50%)",  group = G_FZ,
     tooltip = "Midpoints of the $100 grid only. Display filter — it never gates the engine.")
i_show_fz_lbl = input.bool(true, "Show FastZone labels", group = G_FZ)

const string G_COL = "✦  Colors"
i_col_res = input.color(C_ZONE_RES, "Resistance (above price)", group = G_COL)
i_col_sup = input.color(C_ZONE_SUP, "Support (below price)",    group = G_COL)
i_col_fz  = input.color(C_ZONE_FZ,  "FastZone 50%",             group = G_COL)

const string G_UI = "✦  UI Architecture (HUDs)"
i_show_dash   = input.bool(true, "Show Dashboards", group = G_UI)
i_dash_pos    = input.string("Bottom Right", "▸ Panel position", group = G_UI,
     options = ["Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right",
                "Bottom Left", "Bottom Center", "Bottom Right"])
i_master_size = input.string("Small", "▸ Panel size", group = G_UI,
     options = ["Tiny", "Small", "Normal", "Large"])

// -- size ladder: two base sizes, no HERO (state panel, §2) --
string TXT_L = i_master_size == "Tiny" ? size.tiny : i_master_size == "Small" ? size.small :
               i_master_size == "Normal" ? size.normal : size.large
string TXT_S = i_master_size == "Tiny" ? size.tiny : i_master_size == "Small" ? size.tiny :
               i_master_size == "Normal" ? size.small : size.normal

string DASH_POS = i_dash_pos == "Top Center" ? position.top_center :
                  i_dash_pos == "Top Right" ? position.top_right :
                  i_dash_pos == "Middle Left" ? position.middle_left :
                  i_dash_pos == "Middle Center" ? position.middle_center :
                  i_dash_pos == "Middle Right" ? position.middle_right :
                  i_dash_pos == "Bottom Left" ? position.bottom_left :
                  i_dash_pos == "Bottom Center" ? position.bottom_center : position.bottom_right

// =============================================================================
// 4. CANON FORMATTERS  (def before use)
// =============================================================================

f_c(string s) => " " + s + " "

f_cell(table t, int c, int r, string txt, color tc, string ha, string sz, color bg, string tip) =>
    table.cell(t, c, r, f_c(txt), text_color = tc, text_halign = ha, text_valign = text.align_center,
         text_size = sz, bgcolor = bg, tooltip = tip, text_font_family = font.family_monospace)

// banker's price: "$4,100" — thousands separator, no decimals on a $100/$250 grid
f_usd(float v) =>
    string out = "—"
    if not na(v)
        string s = str.tostring(int(math.round(v)))
        int    n = str.length(s)
        out := n > 3 ? str.substring(s, 0, n - 3) + "," + str.substring(s, n - 3) : s
        out := "$" + out
    out

f_half(float v) => na(v) ? "—" : "±" + str.tostring(v, "#.#")
f_sgn(float x, string fmt) => na(x) ? "—" : (x < 0 ? "-" : "+") + str.tostring(math.abs(x), fmt)

// absolute grid: k-th level strictly above / strictly below price
f_lvl_above(float px, float step, int k) => math.floor(px / step) * step + k * step
f_lvl_below(float px, float step, int k) => math.ceil(px / step) * step - k * step

// nearest grid multiple to a price
f_nearest(float px, float step) => math.round(px / step) * step

// float identity by tolerance — never "==" on floats
f_in(float[] lad, float v) =>
    bool hit = false
    if array.size(lad) > 0
        for i = 0 to array.size(lad) - 1
            if math.abs(array.get(lad, i) - v) < EPS
                hit := true
    hit

// opacity hierarchy on a light background.
// tier 1 ($100): body present, crisp edge.  tier 2 ($250): whisper body, sharper
// edge — a major level is marked by its edge, not by its mass.
f_border_op(int rank, int tier) =>
    tier == 2 ? (rank == 0 ? 6 : rank == 1 ? 30 : 45) : (rank == 0 ? 8 : rank == 1 ? 40 : 55)
f_fill_op(int rank, int tier) =>
    tier == 2 ? (rank == 0 ? 86 : rank == 1 ? 92 : 94) : (rank == 0 ? 78 : rank == 1 ? 90 : 93)
f_center_op(int rank, int tier) =>
    tier == 2 ? (rank == 0 ? 15 : 45) : (rank == 0 ? 20 : 55)

// =============================================================================
// 5. OBJECT POOLS
// =============================================================================

var box[]   q_boxes    = array.new<box>()
var label[] q_lbls     = array.new<label>()
var line[]  q_center   = array.new<line>()
var line[]  q_fz_lines = array.new<line>()
var label[] q_fz_lbls  = array.new<label>()
var label[] q_mk       = array.new<label>()   // reaction markers: event-scoped, never wiped

// =============================================================================
// 6. DRAWING PRIMITIVES  (time-anchored — no historical buffer consumption)
// =============================================================================

f_draw_level(float lvl, bool is_above, int rank, int tier, bool confluent,
     bool show_lbl, float half, color col) =>
    int t_right = time + BODY_BARS * timeframe.in_seconds() * 1000
    box bx = box.new(
         left         = time,
         top          = lvl + half,
         right        = t_right,
         bottom       = lvl - half,
         xloc         = xloc.bar_time,
         border_color = color.new(col, f_border_op(rank, tier)),
         border_width = 1,
         bgcolor      = color.new(col, f_fill_op(rank, tier)),
         extend       = extend.both)
    line cl = na
    if i_centerln
        cl := line.new(
             x1     = time,
             y1     = lvl,
             x2     = t_right,
             y2     = lvl,
             xloc   = xloc.bar_time,
             color  = color.new(col, f_center_op(rank, tier)),
             width  = 1,
             style  = line.style_solid,
             extend = extend.both)
    label lb = na
    if show_lbl
        // hierarchy §4: confluence = FILLED gold chip, dark ink (the A+ mark).
        // $250 = firmer tinted chip. $100 = light tinted chip (routine).
        string glyph = confluent ? "★ " : tier == 2 ? "◆ " : ""
        string kind  = confluent ? "Confluence · $100 + $250" : tier == 2 ? "Major · $250 grid" : "$100 grid"
        color  c_bg  = confluent ? color.new(C_ACCENT, 15) : color.new(col, tier == 2 ? 70 : 78)
        color  c_ink = confluent ? C_INK_DARK : is_above ? C_INK_RES : C_INK_SUP
        lb := label.new(
             x                = bar_index + LBL_OFFSET,
             y                = lvl,
             text             = glyph + f_usd(lvl) + (is_above ? " ▲" : " ▼"),
             color            = c_bg,
             textcolor        = c_ink,
             style            = label.style_label_left,
             size             = tier == 2 ? size.normal : size.small,
             text_font_family = font.family_monospace,
             tooltip          = (is_above ? "Resistance" : "Support") + " · " + kind + "\n" +
                  "Zone: " + f_usd(lvl - half) + " — " + f_usd(lvl + half) +
                  "  (" + f_half(half) + " pts)\n" +
                  "Rank " + str.tostring(rank + 1) + " from price.")
    [bx, cl, lb]

f_draw_fastzone(float lo, float hi, bool show_lbl, color col) =>
    float mid = (lo + hi) / 2.0
    line ln = line.new(
         x1     = time,
         y1     = mid,
         x2     = time + BODY_BARS * timeframe.in_seconds() * 1000,
         y2     = mid,
         xloc   = xloc.bar_time,
         color  = color.new(col, 25),
         width  = 1,
         style  = line.style_dashed,
         extend = extend.both)
    label lb = na
    if show_lbl
        lb := label.new(
             x                = bar_index + LBL_OFFSET,
             y                = mid,
             text             = "FZ " + f_usd(mid),
             color            = color.new(col, 85),
             textcolor        = C_INK_FZ,
             style            = label.style_label_left,
             size             = size.tiny,
             text_font_family = font.family_monospace,
             tooltip          = "FastZone · 50% midpoint between " + f_usd(lo) + " and " + f_usd(hi))
    [ln, lb]

// =============================================================================
// 6-BIS. REACTION MARKERS — classified by DIRECTION OF APPROACH.
//
// Mechanical definition (fixed, no tuning):
//   Possible Support    : close[1] > lvl + half   (previous bar closed ABOVE the zone)
//                         AND this bar's range reaches the zone
//                         (low <= lvl + half and high >= lvl - half)
//   Possible Resistance : close[1] < lvl - half   (previous bar closed BELOW the zone)
//                         AND this bar's range reaches the zone
//   lvl = grid multiple nearest to the bar's extreme (low for support, high for
//   resistance). Falling into a level makes it support; rising into it makes it
//   resistance — regardless of where the bar closes.
//
// Fires on ARRIVAL: the first CLOSED bar that reaches the zone from that side.
// One marker per level per episode; the level re-arms once close moves more than
// half a step away. Evaluated on closed bars only, so nothing repaints — and the
// marker stays even if price later breaks through. It flags the test, not the outcome.
// No hit-rate is measured or implied.
// =============================================================================

float atr_mk = ta.atr(14)

var float armed_res_1 = na
var float armed_sup_1 = na
var float armed_res_2 = na
var float armed_sup_2 = na

// event-scoped lifecycle: cap is N events x objects-per-event (§8)
f_mk_push(label lb) =>
    if not na(lb)
        array.push(q_mk, lb)
        int per_event = i_mk_style == "Arrow + label" ? 2 : 1
        int cap = i_mk_limit * per_event
        while array.size(q_mk) > cap
            label.delete(array.shift(q_mk))

f_mk_draw(float lvl, float half, bool is_res, bool confluent) =>
    float gap  = nz(atr_mk, half) * i_mk_gap
    float edge = is_res ? lvl + half : lvl - half
    float y_ar = is_res ? edge + gap : edge - gap
    float y_lb = is_res ? edge + gap * 2.0 : edge - gap * 2.0
    color col  = is_res ? i_col_res : i_col_sup
    color ink  = is_res ? C_INK_RES : C_INK_SUP
    string txt = (is_res ? "Possible Resistance" : "Possible Support") +
         (i_mk_price ? "  " + f_usd(lvl) : "")
    string tip = (is_res ? "Possible Resistance" : "Possible Support") + " · " +
         (confluent ? "$100 + $250 confluence" : "grid level") + "\n" +
         "Level: " + f_usd(lvl) + "   Zone: " + f_usd(lvl - half) + " — " + f_usd(lvl + half) + "\n" +
         (is_res ? "Price rose into this level from below." :
              "Price fell into this level from above.") + "\n" +
         "Marked on the first closed bar that reached the zone from that side.\n" +
         "This flags the test only. No success rate is implied or measured."
    if i_mk_style != "Label only"
        f_mk_push(label.new(bar_index, y_ar, "",
             color     = color.new(col, 20),
             style     = is_res ? label.style_arrowdown : label.style_arrowup,
             size      = size.small,
             tooltip   = tip))
    if i_mk_style != "Arrow only"
        f_mk_push(label.new(bar_index, y_lb, txt,
             color            = confluent ? color.new(C_ACCENT, 20) : color.new(col, 82),
             textcolor        = confluent ? C_INK_DARK : ink,
             style            = is_res ? label.style_label_down : label.style_label_up,
             size             = size.tiny,
             text_font_family = font.family_monospace,
             tooltip          = tip))

// approach test for one layer; returns the fired levels (na if none)
f_mk_scan(float step, float half) =>
    float lvl_s = f_nearest(low,  step)
    float lvl_r = f_nearest(high, step)
    bool  reach_s = low <= lvl_s + half and high >= lvl_s - half
    bool  reach_r = high >= lvl_r - half and low <= lvl_r + half
    float fire_s = close[1] > lvl_s + half and reach_s ? lvl_s : na
    float fire_r = close[1] < lvl_r - half and reach_r ? lvl_r : na
    [fire_s, fire_r]

if i_show_mk and barstate.isconfirmed
    // ── $100 layer ──
    [s1, r1] = f_mk_scan(STEP_1, i_half_1)
    if not na(armed_res_1) and math.abs(close - armed_res_1) > STEP_1 / 2.0
        armed_res_1 := na
    if not na(armed_sup_1) and math.abs(close - armed_sup_1) > STEP_1 / 2.0
        armed_sup_1 := na
    if not na(s1) and (na(armed_sup_1) or math.abs(armed_sup_1 - s1) > EPS)
        armed_sup_1 := s1
        f_mk_draw(s1, i_half_1, false, math.abs(s1 % 500.0) < EPS)
    if not na(r1) and (na(armed_res_1) or math.abs(armed_res_1 - r1) > EPS)
        armed_res_1 := r1
        f_mk_draw(r1, i_half_1, true, math.abs(r1 % 500.0) < EPS)

    // ── $250 layer (skipped when it would duplicate a $500 confluence) ──
    if i_mk_250 and i_show_2
        [s2, r2] = f_mk_scan(STEP_2, i_half_2)
        if not na(armed_res_2) and math.abs(close - armed_res_2) > STEP_2 / 2.0
            armed_res_2 := na
        if not na(armed_sup_2) and math.abs(close - armed_sup_2) > STEP_2 / 2.0
            armed_sup_2 := na
        if not na(s2) and math.abs(s2 % 500.0) > EPS and (na(armed_sup_2) or math.abs(armed_sup_2 - s2) > EPS)
            armed_sup_2 := s2
            f_mk_draw(s2, i_half_2, false, false)
        if not na(r2) and math.abs(r2 % 500.0) > EPS and (na(armed_res_2) or math.abs(armed_res_2 - r2) > EPS)
            armed_res_2 := r2
            f_mk_draw(r2, i_half_2, true, false)

// =============================================================================
// 7. MAIN — full redraw on the last bar  (engine identical to v1.1)
// =============================================================================

var float rng_lo    = na
var float rng_hi    = na
var float next_up   = na
var float next_dn   = na
var int   n_confl   = 0

if barstate.islast
    // -- wipe --
    for bx in q_boxes
        box.delete(bx)
    for lb in q_lbls
        label.delete(lb)
    for ln in q_center
        line.delete(ln)
    for ln in q_fz_lines
        line.delete(ln)
    for lb in q_fz_lbls
        label.delete(lb)
    array.clear(q_boxes)
    array.clear(q_lbls)
    array.clear(q_center)
    array.clear(q_fz_lines)
    array.clear(q_fz_lbls)

    float px = close

    // -- ladders, ascending. lad_1 is ALWAYS complete: de-dupe hides a box,
    //    it never removes a level from the engine (§6).
    float[] lad_1 = array.new<float>()
    for k = i_below_1 to 1
        array.push(lad_1, f_lvl_below(px, STEP_1, k))
    for k = 1 to i_above_1
        array.push(lad_1, f_lvl_above(px, STEP_1, k))

    float[] lad_2 = array.new<float>()
    if i_show_2
        for k = i_below_2 to 1
            array.push(lad_2, f_lvl_below(px, STEP_2, k))
        for k = 1 to i_above_2
            array.push(lad_2, f_lvl_above(px, STEP_2, k))

    // -- nearest levels (deterministic; $100 grid is always the finest) --
    next_up := f_lvl_above(px, STEP_1, 1)
    next_dn := f_lvl_below(px, STEP_1, 1)

    // -- confluence census (deterministic: pure overlap) --
    n_confl := 0
    if array.size(lad_1) > 0
        for i = 0 to array.size(lad_1) - 1
            if f_in(lad_2, array.get(lad_1, i))
                n_confl += 1

    // -- visible span across BOTH layers --
    rng_lo := array.get(lad_1, 0)
    rng_hi := array.get(lad_1, array.size(lad_1) - 1)
    if array.size(lad_2) > 0
        rng_lo := math.min(rng_lo, array.get(lad_2, 0))
        rng_hi := math.max(rng_hi, array.get(lad_2, array.size(lad_2) - 1))

    // -- layer 2 first: wider bands go underneath --
    if i_show_2
        for k = 1 to i_below_2
            float lvl = f_lvl_below(px, STEP_2, k)
            [bx, cl, lb] = f_draw_level(lvl, false, k - 1, 2, f_in(lad_1, lvl), i_lbl_2, i_half_2, i_col_sup)
            array.push(q_boxes, bx)
            if not na(cl)
                array.push(q_center, cl)
            if not na(lb)
                array.push(q_lbls, lb)
        for k = 1 to i_above_2
            float lvl = f_lvl_above(px, STEP_2, k)
            [bx, cl, lb] = f_draw_level(lvl, true, k - 1, 2, f_in(lad_1, lvl), i_lbl_2, i_half_2, i_col_res)
            array.push(q_boxes, bx)
            if not na(cl)
                array.push(q_center, cl)
            if not na(lb)
                array.push(q_lbls, lb)

    // -- layer 1 on top; confluent boxes suppressed when de-dupe is on --
    for k = 1 to i_below_1
        float lvl = f_lvl_below(px, STEP_1, k)
        if not (i_dedupe and f_in(lad_2, lvl))
            [bx, cl, lb] = f_draw_level(lvl, false, k - 1, 1, false, i_lbl_1, i_half_1, i_col_sup)
            array.push(q_boxes, bx)
            if not na(cl)
                array.push(q_center, cl)
            if not na(lb)
                array.push(q_lbls, lb)
    for k = 1 to i_above_1
        float lvl = f_lvl_above(px, STEP_1, k)
        if not (i_dedupe and f_in(lad_2, lvl))
            [bx, cl, lb] = f_draw_level(lvl, true, k - 1, 1, false, i_lbl_1, i_half_1, i_col_res)
            array.push(q_boxes, bx)
            if not na(cl)
                array.push(q_center, cl)
            if not na(lb)
                array.push(q_lbls, lb)

    // -- FastZone: computed on the FULL $100 ladder, de-dupe irrelevant --
    if i_show_fz and array.size(lad_1) >= 2
        for i = 0 to array.size(lad_1) - 2
            [ln, lb] = f_draw_fastzone(array.get(lad_1, i), array.get(lad_1, i + 1), i_show_fz_lbl, i_col_fz)
            array.push(q_fz_lines, ln)
            if not na(lb)
                array.push(q_fz_lbls, lb)

// =============================================================================
// 8. DASHBOARD  (delete + rebuild pattern — handles toggle and position)
// =============================================================================

var table tbl = na

if barstate.islast
    if not na(tbl)
        table.delete(tbl)
        tbl := na

    if i_show_dash
        tbl := table.new(DASH_POS, 2, 11,
             frame_color  = C_FRAME,
             frame_width  = 1,
             border_color = C_DIVIDER,
             border_width = 1)

        // r0 — header + status chip (FILLED gold chip, dark ink — the v1.1 fix)
        f_cell(tbl, 0, 0, "◉  GCGRID", C_ACCENT, text.align_left, TXT_S, C_SURFACE_2,
             "GCGrid · NomadaScalper\n\nDual absolute pivot grid for gold: $100 and $250 " +
             "psychological levels.\nLevels are fixed multiples — chart-invariant: identical " +
             "on every timeframe and exchange, no lookback and no repaint.\n" +
             "FastZone = 50% midpoint of the $100 grid.\n" +
             "Nearest level is drawn strong; outer levels fade by opacity.")
        f_cell(tbl, 1, 0, i_show_2 ? "$100+$250" : "$100", C_INK_DARK, text.align_center, TXT_S,
             color.new(C_ACCENT, 25), "Active grid layers. Steps are fixed and not user editable.")

        // r1 — section band
        f_cell(tbl, 0, 1, "GRID LAYERS", C_DIM, text.align_center, TXT_S, C_SURFACE_3,
             "One row per grid. Format: levels above ▲ · levels below ▼ · band half-width.")
        table.merge_cells(tbl, 0, 1, 1, 1)

        // r2 — $100 layer
        f_cell(tbl, 0, 2, "$100", C_MUTED, text.align_left, TXT_L, C_CELL,
             "Primary grid. Every multiple of $100.")
        f_cell(tbl, 1, 2, str.tostring(i_above_1) + "▲ " + str.tostring(i_below_1) + "▼ · " + f_half(i_half_1),
             C_TEXT_PRI, text.align_right, TXT_L, C_CELL,
             "▲ above price · ▼ below price\nBand: " + f_half(i_half_1) +
             " pts from the level to each edge (" + str.tostring(i_half_1 * 2, "#.#") + " pts total).")

        // r3 — $250 layer
        f_cell(tbl, 0, 3, "$250", C_MUTED, text.align_left, TXT_L, C_CELL_ALT,
             "Major grid. Every multiple of $250, drawn wider and underneath.")
        f_cell(tbl, 1, 3, i_show_2 ? str.tostring(i_above_2) + "▲ " + str.tostring(i_below_2) + "▼ · " + f_half(i_half_2) : "✕ OFF",
             i_show_2 ? C_TEXT_PRI : C_DIM, text.align_right, TXT_L, C_CELL_ALT,
             "▲ above price · ▼ below price\nBand: " + f_half(i_half_2) +
             " pts from the level to each edge (" + str.tostring(i_half_2 * 2, "#.#") + " pts total).")

        // r4 — confluence census
        f_cell(tbl, 0, 4, "Confluence", C_MUTED, text.align_left, TXT_L, C_CELL,
             "Levels present in BOTH grids — i.e. multiples of $500 — currently visible.")
        f_cell(tbl, 1, 4, n_confl > 0 ? "★ " + str.tostring(n_confl) : "—",
             n_confl > 0 ? C_ACCENT : C_DIM, text.align_right, TXT_L, C_CELL,
             n_confl > 0 ? "Drawn once as the wider $250 band, flagged ★.\n" +
                  (i_dedupe ? "De-duplication is ON." :
                       "De-duplication is OFF: both bands are drawn nested.") :
                  "No level of the $100 grid coincides with a $250 level right now.")

        // r5 — section band
        f_cell(tbl, 0, 5, "PRICE vs GRID", C_DIM, text.align_center, TXT_S, C_SURFACE_3,
             "Nearest level on each side and the signed distance from the current close, in $.")
        table.merge_cells(tbl, 0, 5, 1, 5)

        // r6 — next level up
        f_cell(tbl, 0, 6, "Next ▲", C_MUTED, text.align_left, TXT_L, C_CELL,
             "Nearest grid level above the current close.")
        f_cell(tbl, 1, 6, na(next_up) ? "—" : f_usd(next_up) + " · " + f_sgn(next_up - close, "#.0"),
             C_DANGER, text.align_right, TXT_L, C_CELL,
             "Distance in $ from close to the nearest level above. Updates live.")

        // r7 — next level down
        f_cell(tbl, 0, 7, "Next ▼", C_MUTED, text.align_left, TXT_L, C_CELL_ALT,
             "Nearest grid level below the current close.")
        f_cell(tbl, 1, 7, na(next_dn) ? "—" : f_usd(next_dn) + " · " + f_sgn(next_dn - close, "#.0"),
             C_OK, text.align_right, TXT_L, C_CELL_ALT,
             "Distance in $ from close to the nearest level below. Updates live.")

        // r8 — visible range
        f_cell(tbl, 0, 8, "Range", C_MUTED, text.align_left, TXT_L, C_CELL,
             "Lowest and highest level currently drawn, across both layers.")
        f_cell(tbl, 1, 8, na(rng_lo) or na(rng_hi) ? "—" : f_usd(rng_lo) + " — " + f_usd(rng_hi),
             C_TEXT_PRI, text.align_right, TXT_L, C_CELL,
             "Visible span only. Both grids are unbounded — they extend as far as price travels.")

        // r9 — reading legend
        f_cell(tbl, 0, 9, "$100 + $250 grid\n★ = both · FZ = 50%", C_DIM, text.align_center, TXT_S,
             C_SURFACE_2, "Levels are absolute multiples. ★ marks a level shared by both grids.")
        table.merge_cells(tbl, 0, 9, 1, 9)

        // r10 — footer / brand
        f_cell(tbl, 0, 10, "✦ GCGrid NomadaScalper", C_ACCENT, text.align_center, TXT_S, C_SURFACE_2,
             "GCGrid · NomadaScalper")
        table.merge_cells(tbl, 0, 10, 1, 10)
````
