# GEX Levels ES Futures Only

- url: https://www.tradingview.com/script/uljvPAZf-GEX-Levels-ES-Futures-Only/
- type: indicator
- pine_id: PUB;15d4b90a28fb43a18693147b35cb302b
- version: 339.0

## Description

GEX Levels — Gamma Exposure Trading Map

This indicator overlays key Gamma Exposure (GEX) levels directly on your ES futures chart, giving you a real-time structural map of where dealer hedging creates predictable price behavior.

What it shows:

🟢 Ceiling (Major Positive Gamma) — The dominant gamma wall. Price gravitates toward this level and tends to reject hard. Strong resistance above, magnet from below.

⚡ Flip Line (Zero Gamma) — The regime boundary. Above it, dealers are long gamma — they buy dips and sell rips, keeping price range-bound. Below it, dealers are short gamma — momentum accelerates and stops get hunted. This is the most important level on the chart.

🔶 Speed Zone (Major Negative Gamma) — Once price enters here, dealer hedging amplifies moves. Expect fast, volatile price action in either direction.

🔴 Sell Zone — High-probability short entry area based on the current GEX structure. Wait for price to reach this zone before looking for a setup.

🎯 Goals 1 & 2 — Profit targets derived from the next significant gamma walls below.

🤍 Buy Zone — Potential long entry area, only valid on a strong bounce with momentum confirmation.

How levels are set:

Levels are updated manually based on fresh GEX data and price structure analysis. They reflect the current day's dealer positioning and are refreshed each session. The timestamp in the top-right corner shows when the levels were last updated.

Best used on: ES (S&P 500 E-mini Futures) — 5 minute chart
Data source: GEX analysis from options market maker positioning (SPX options flow)
Note: GEX levels work best during regular trading hours (9:30 AM – 4:00 PM ET). Always use in conjunction with your own price action analysis and risk management rules.

## Source Code

````pine
//@version=6
indicator("GEX Levels", shorttitle="GEX", overlay=true, max_labels_count=50, max_boxes_count=20, max_lines_count=60)

// ── ES/SPX premium: refreshed every 30 min during SPX hours, identical on every timeframe ──
// A roll-date-triggered version (only recomputing when ES1! rolls to its
// next quarterly contract, per TradingView's ~6-business-days-before-
// expiration schedule) was tried first. It broke in practice: ES1! is a
// back-adjusted continuous contract (chart shows "B-ADJ") -- TradingView
// retroactively shifts ALL historical closes at every roll so there's no
// visible price gap on the chart. That means close[] at or near a PAST
// roll bar is a synthetic, shifted number, not the real price that
// contract traded at -- anchoring the premium calc there produced a
// badly wrong premium (~9pts instead of the real ~68pts).
//
// Recomputing every closed bar (tried next) sidestepped that, but SPX cash
// only trades 9:30-16:00 ET while ES trades nearly 24/5 -- outside SPX's
// hours request.security() just holds SPX's last frozen print while ES
// keeps moving, so the "premium" silently tracked ES's own overnight/
// pre-market price action and dragged every GEX level along with it on
// every bar.
//
// Freezing once a day on the chart's own timeframe (tried next) stopped the
// per-candle movement, but each timeframe grabbed a different "last bar
// before 16:00" for ES and SPX, so 1m/5m/15m charts showed slightly
// different levels.
//
// A once-a-day freeze from the prior 16:00 ET close (tried next) was stable
// and timeframe-independent, but the real ES/SPX gap drifts a few points
// day to day (57.5 at the 10/01 close vs 53.7 live on 10/02), so levels
// sat ~4pts off all session.
//
// Fix: pair the last COMPLETED 30-minute closes of ES and SPX, and only
// accept the pair when both bars closed at the exact same timestamp. SPX
// only has 30m bars 9:30-16:00, so this refreshes at 10:00, 10:30 ... 15:30
// and holds the last pair through the overnight session. Read from fixed
// 30m bars (not the chart's own), so every chart timeframe shows identical
// levels, which step at most once per half hour. ES is forced to its
// extended session so its 30m bars stay aligned to :00/:30.
es_ticker = ticker.modify(syminfo.tickerid, session = session.extended)
[es_c, es_k]   = request.security(es_ticker, "30", [close[1], time_close[1]])
[spx_c, spx_k] = request.security("SPX", "30", [close[1], time_close[1]])

var float frozen_premium = na
if not na(es_c) and not na(spx_c) and es_k == spx_k
    frozen_premium := es_c - spx_c
es_premium = frozen_premium

// ── Levels (SPX-based — 10/15/26 14:12, auto-extracted by SentinelGEX) ──────────────────────────────────
float p         = nz(es_premium, 0)
float ceil_val  = 7735.0 + p
float flip_val  = 7800.0 + p
float speed_val = 7700.0 + p
float sz_top    = 7803.0 + p
float sz_bot    = 7799.0 + p
float stop_val  = 7742.0 + p
float t1_val    = 7750.0 + p
float t2_val    = 7698.0 + p
float bz_top    = 7704.0 + p
float bz_bot    = 7697.0 + p
float bstop_val = 7690.0 + p
float lt1_val   = 7767.5 + p
float lt2_val   = 7735.0 + p
string refresh  = "10/15/26 14:12"

float phod_val = request.security(syminfo.tickerid, "D", high[1])
float plod_val = request.security(syminfo.tickerid, "D", low[1])
float hod_val  = request.security(syminfo.tickerid, "D", high)
float lod_val  = request.security(syminfo.tickerid, "D", low)

float bar_delta   = close >= open ? volume : -volume
float cvd         = ta.cum(bar_delta)
bool  cvd_rising  = cvd > cvd[10]
bool  cvd_falling = cvd < cvd[10]

// ── Scalping references: overnight high/low ────────────────────────
showOn   = input.bool(true, "Show Overnight High/Low (until taken out)", group="Scalping")

bool rth      = not na(time(timeframe.period, "0930-1600", "America/New_York"))
bool onSess   = not na(time(timeframe.period, "1800-0930", "America/New_York"))
bool rthStart = rth and not rth[1]

var float onh    = na
var float onl    = na
var float rth_hi = na
var float rth_lo = na
if onSess and not onSess[1]
    onh := high
    onl := low
else if onSess
    onh := math.max(nz(onh, high), high)
    onl := math.min(nz(onl, low), low)
if rthStart
    rth_hi := high
    rth_lo := low
else if rth
    rth_hi := math.max(rth_hi, high)
    rth_lo := math.min(rth_lo, low)
// Only shown during RTH, and only until the RTH session trades through it.
bool showOnh = showOn and rth and not na(onh) and not na(rth_hi) and rth_hi < onh
bool showOnl = showOn and rth and not na(onl) and not na(rth_lo) and rth_lo > onl

// ── Structure confirmation (lightweight MSS) ───────────────────────────────────
swingLen        = input.int (5,    "Structure Swing Length",                 minval=2,   maxval=20, group="Structure Confirmation")
useStructFilter = input.bool(true, "Require structure break for FAVORED bias",                       group="Structure Confirmation")

float ph_struct = ta.pivothigh(swingLen, swingLen)
float pl_struct = ta.pivotlow (swingLen, swingLen)
var float lastSwingHigh = na
var float lastSwingLow  = na
if not na(ph_struct)
    lastSwingHigh := ph_struct
if not na(pl_struct)
    lastSwingLow := pl_struct

bool bearishMSS = not na(lastSwingLow)  and ta.crossunder(close, lastSwingLow)
bool bullishMSS = not na(lastSwingHigh) and ta.crossover (close, lastSwingHigh)

var bool structConfirmedShort = false
var bool structConfirmedLong  = false
if bearishMSS
    structConfirmedShort := true
    structConfirmedLong  := false
if bullishMSS
    structConfirmedLong  := true
    structConfirmedShort := false

// ── Liquidity clustering near GEX zones ───────────────────────────────────────
liqLookback  = input.int  (20,  "Liquidity Pivot Lookback",       minval=5,   maxval=50, group="Liquidity")
liqTolerance = input.float(1.5, "Liquidity Zone Tolerance (pts)", minval=0.5, maxval=10, group="Liquidity")

// ── Optional enhancement — default OFF, chart looks exactly the same as
//    before until turned on in the indicator's own Settings ─────────────────
showZoneColoring = input.bool(false, "Shade Gamma Regime Zones (background)", group="Enhancements (optional)")

// ── Colors — every default below is the color the indicator always used, so
//    nothing changes until you pick something else in Settings → Inputs.
//    Lines, zone borders and their labels share one color per level; levels
//    that don't apply to the current regime still fade to gray. ────────────
col_ceil   = input.color(#00FFCC,      "Ceiling (major pos gamma)",       group="Colors")
col_flip   = input.color(color.yellow, "Zero Gamma",                      group="Colors")
col_speed  = input.color(color.orange, "Speed Zone (major neg gamma)",    group="Colors")
col_short  = input.color(color.red,    "Short entry zone + stop",         group="Colors")
col_long   = input.color(color.teal,   "Long entry zone",                 group="Colors")
col_lstop  = input.color(color.gray,   "Long stop",                       group="Colors")
col_t1     = input.color(color.green,  "Target 1",                        group="Colors")
col_t2     = input.color(color.yellow, "Target 2",                        group="Colors")
col_liq    = input.color(color.aqua,   "Liquidity-confirmed box border",  group="Colors")
col_phl    = input.color(#A0A0A0,      "Prior day high / low",            group="Colors")
col_hl     = input.color(color.white,  "Today high / low",                group="Colors")
col_on     = input.color(#B39DDB,      "Overnight high / low",            group="Colors")
zone_fill  = input.int  (80,           "Zone box fill transparency (0 solid, 100 clear)", minval=0, maxval=100, group="Colors")
lbl_custom = input.bool (false,        "Use one color for all level labels",              group="Colors")
col_lbl    = input.color(color.white,  "Level label color (when the box above is ticked)", group="Colors")
lbl_size_s = input.string("small",     "Level label size", options=["tiny", "small", "normal", "large"], group="Colors")
lbl_size   = lbl_size_s == "tiny" ? size.tiny : lbl_size_s == "normal" ? size.normal : lbl_size_s == "large" ? size.large : size.small

var float[] recentHighs = array.new_float(0)
var float[] recentLows  = array.new_float(0)

if not na(ph_struct)
    array.unshift(recentHighs, ph_struct)
    if array.size(recentHighs) > liqLookback
        array.pop(recentHighs)
if not na(pl_struct)
    array.unshift(recentLows, pl_struct)
    if array.size(recentLows) > liqLookback
        array.pop(recentLows)

count_in_range(arr, lo, hi) =>
    int c = 0
    if array.size(arr) > 0
        for v in arr
            if v >= lo - liqTolerance and v <= hi + liqTolerance
                c += 1
    c

int shortZoneLiqCount = count_in_range(recentHighs, sz_bot, sz_top)
int longZoneLiqCount  = count_in_range(recentLows,  bz_bot, bz_top)

bool shortLiqConfirmed = shortZoneLiqCount >= 2
bool longLiqConfirmed  = longZoneLiqCount  >= 2

type LblEntry
    float  price
    string txt
    color  col

lbl_add(LblEntry[] reg, float price, string t, color col) =>
    if price != 0
        bool found = false
        for e in reg
            if math.abs(e.price - price) <= 2.0
                e.txt := e.txt + "\n" + t
                found  := true
                break
        if not found
            array.push(reg, LblEntry.new(price, t, col))

p(float v) => str.tostring(v, "#.##")

var label[] lb      = array.new_label()
var box[]   bx      = array.new_box()
var line[]  ln      = array.new_line()
var float[] ln_seen = array.new_float()

draw_ln(float price, color col, int wid, string sty) =>
    if price != 0
        bool skip = false
        for seen in ln_seen
            if seen == price
                skip := true
                break
        if not skip
            array.push(ln_seen, price)
            array.push(ln, line.new(bar_index, price, bar_index + 1, price,
                extend=extend.both, color=col, width=wid, style=sty))

if barstate.islast
    bool is_short   = close < flip_val
    bool is_long    = close > ceil_val
    bool is_neutral = not is_short and not is_long

    color c_cyan   = is_short ? col_ceil                   : is_neutral ? color.new(col_ceil, 55)    : color.new(color.gray, 65)
    color c_red    = is_short ? col_short                  : is_neutral ? color.new(col_short, 50)   : color.new(color.gray, 65)
    color c_orange = is_short ? col_speed                  : is_neutral ? color.new(col_speed, 50)   : color.new(color.gray, 65)
    color c_bgray  = is_long  ? col_lstop                  : is_neutral ? color.new(col_lstop, 40)   : color.new(color.gray, 65)
    color c_bteal  = is_long  ? color.new(col_long, 20)    : is_neutral ? color.new(col_long, 50)    : color.new(color.gray, 65)
    color c_flip   = col_flip
    color c_st1    = is_short ? col_t1                     : color.new(color.gray, 75)
    color c_st2    = is_short ? col_t2                     : color.new(color.gray, 75)
    color c_lt1    = is_long  ? col_t1                     : color.new(color.gray, 75)
    color c_lt2    = is_long  ? col_t2                     : color.new(color.gray, 75)

    bool tableIsShort = is_short and (not useStructFilter or structConfirmedShort)
    bool tableIsLong  = is_long  and (not useStructFilter or structConfirmedLong)

    for l in lb
        label.delete(l)
    for b in bx
        box.delete(b)
    for l in ln
        line.delete(l)
    array.clear(lb)
    array.clear(bx)
    array.clear(ln)
    array.clear(ln_seen)

    int lx = chart.right_visible_bar_time

    draw_ln(ceil_val,  c_cyan,   2, line.style_dotted)
    draw_ln(stop_val,  c_red,    1, line.style_dotted)
    draw_ln(sz_top,    c_red,    2, line.style_solid)
    draw_ln(sz_bot,    c_red,    2, line.style_solid)
    draw_ln(flip_val,  c_flip,   2, line.style_dashed)
    draw_ln(speed_val, c_orange, 2, line.style_dashed)
    draw_ln(bz_top,    c_bgray,  1, line.style_solid)
    draw_ln(bz_bot,    c_bgray,  1, line.style_solid)
    draw_ln(bstop_val, c_bgray,  1, line.style_dotted)
    draw_ln(t1_val,    c_st1,    2, line.style_solid)
    draw_ln(t2_val,    c_st2,    2, line.style_solid)
    draw_ln(lt1_val,   c_lt1,    2, line.style_solid)
    draw_ln(lt2_val,   c_lt2,    2, line.style_solid)
    draw_ln(phod_val,  col_phl, 1, line.style_dashed)
    draw_ln(plod_val,  col_phl, 1, line.style_dashed)
    draw_ln(hod_val,   col_hl,  1, line.style_dashed)
    draw_ln(lod_val,   col_hl,  1, line.style_dashed)
    if showOnh
        draw_ln(onh, col_on, 1, line.style_dashed)
    if showOnl
        draw_ln(onl, col_on, 1, line.style_dashed)

    if sz_top != 0 and sz_bot != 0
        color sz_bg = is_short ? color.new(col_short, zone_fill) : color.new(color.gray, 92)
        array.push(bx, box.new(bar_index - 500, sz_top, bar_index + 13, sz_bot,
            xloc=xloc.bar_index, bgcolor=sz_bg, border_color=c_red, border_width=1))

    if bz_top != 0 and bz_bot != 0
        color bz_bg = is_long ? color.new(col_long, zone_fill) : color.new(color.gray, 92)
        array.push(bx, box.new(bar_index - 500, bz_top, bar_index + 13, bz_bot,
            xloc=xloc.bar_index, bgcolor=bz_bg, border_color=c_bteal, border_width=1))

    if shortLiqConfirmed
        array.push(bx, box.new(bar_index - 20, sz_top, bar_index + 13, sz_bot,
            xloc=xloc.bar_index, bgcolor=color(na), border_color=color.new(col_liq, 0), border_width=2, border_style=line.style_dashed))
    if longLiqConfirmed
        array.push(bx, box.new(bar_index - 20, bz_top, bar_index + 13, bz_bot,
            xloc=xloc.bar_index, bgcolor=color(na), border_color=color.new(col_liq, 0), border_width=2, border_style=line.style_dashed))

    LblEntry[] reg = array.new<LblEntry>()

    lbl_add(reg, ceil_val,               "⬛ MAJOR POS GAMMA — Ceiling  (" + p(ceil_val) + ")",                  c_cyan)
    lbl_add(reg, stop_val,               "🔴 SHORT STOP LOSS  (" + p(stop_val) + ")",                             c_red)
    lbl_add(reg, sz_top,                 "🔴 SHORT ENTRY ZONE  (" + p(sz_bot) + "–" + p(sz_top) + ")" + (shortLiqConfirmed ? "  🌊 LIQ x" + str.tostring(shortZoneLiqCount) : ""), c_red)
    lbl_add(reg, flip_val,               "⚡ ZERO GAMMA — Calm above  |  Volatile below  (" + p(flip_val) + ")",  c_flip)
    lbl_add(reg, speed_val,              "🔶 MAJOR NEG GAMMA — Speed Zone  (" + p(speed_val) + ")",               c_orange)
    lbl_add(reg, (bz_top + bz_bot) / 2, "🤍 LONG ENTRY — Counter-trend  (" + p(bz_bot) + "–" + p(bz_top) + ")" + (longLiqConfirmed ? "  🌊 LIQ x" + str.tostring(longZoneLiqCount) : ""), c_bteal)
    lbl_add(reg, bstop_val,              "🤍 LONG STOP LOSS  (" + p(bstop_val) + ")",                             c_bgray)
    lbl_add(reg, phod_val, "⬜ pHOD  (" + p(phod_val) + ")", col_phl)
    lbl_add(reg, plod_val, "⬜ pLOD  (" + p(plod_val) + ")", col_phl)
    lbl_add(reg, hod_val,  "▫ HOD   (" + p(hod_val)  + ")", col_hl)
    lbl_add(reg, lod_val,  "▫ LOD   (" + p(lod_val)  + ")", col_hl)
    if showOnh
        lbl_add(reg, onh, "◇ ONH  (" + p(onh) + ")", col_on)
    if showOnl
        lbl_add(reg, onl, "◇ ONL  (" + p(onl) + ")", col_on)

    if is_short
        lbl_add(reg, t1_val,   "🎯 SHORT TARGET 1  (" + p(t1_val) + ")",   c_st1)
        lbl_add(reg, t2_val,   "🎯 SHORT TARGET 2  (" + p(t2_val) + ")",   c_st2)
        lbl_add(reg, flip_val, "↩ RESHORT — Zero γ bounce  (" + p(flip_val) + ")" + (structConfirmedShort ? "  ✓ STRUCT" : "  ⚠ no struct"), col_short)

    if is_long
        lbl_add(reg, lt1_val,  "🎯 LONG TARGET 1  (" + p(lt1_val) + ")",   c_lt1)
        lbl_add(reg, lt2_val,  "🎯 LONG TARGET 2  (" + p(lt2_val) + ")",   c_lt2)
        lbl_add(reg, ceil_val, "↩ RELONG — Ceiling dip  (" + p(ceil_val) + ")" + (structConfirmedLong ? "  ✓ STRUCT" : "  ⚠ no struct"), color.new(col_ceil, 0))
        lbl_add(reg, flip_val, "↩ RELONG — Zero γ dip  (" + p(flip_val) + ")"  + (structConfirmedLong ? "  ✓ STRUCT" : "  ⚠ no struct"), col_flip)

    for e in reg
        array.push(lb, label.new(lx, e.price, e.txt,
            xloc=xloc.bar_time, style=label.style_none, textcolor=lbl_custom ? col_lbl : e.col, size=lbl_size, textalign=text.align_right))

// ── Bias Table ────────────────────────────────────────────────────────────────
var table bias_tbl = table.new(position.top_left, 3, 2,
     bgcolor=color.new(color.black, 50), border_width=1,
     border_color=color.new(color.gray, 40), frame_color=color.new(color.gray, 40), frame_width=1)

if barstate.islast
    bool is_short   = close < flip_val
    bool is_neutral = close >= flip_val and close <= ceil_val
    bool is_long    = close > ceil_val
    bool tableIsShort = is_short and (not useStructFilter or structConfirmedShort)
    bool tableIsLong  = is_long  and (not useStructFilter or structConfirmedLong)
    color sc = tableIsShort   ? color.new(color.red,    20) : color.new(color.gray, 80)
    color st = tableIsShort   ? color.white                 : color.new(color.gray, 50)
    color nc = is_neutral ? color.new(color.yellow, 20) : color.new(color.gray, 80)
    color nt = is_neutral ? color.yellow                : color.new(color.gray, 50)
    color lc = tableIsLong    ? color.new(color.green,  20) : color.new(color.gray, 80)
    color lt = tableIsLong    ? color.green                 : color.new(color.gray, 50)
    table.cell(bias_tbl, 0, 0, "▼  SHORT",   text_color=st, bgcolor=sc, text_size=size.normal)
    table.cell(bias_tbl, 1, 0, "▶  NEUTRAL", text_color=nt, bgcolor=nc, text_size=size.normal)
    table.cell(bias_tbl, 2, 0, "▲  LONG",    text_color=lt, bgcolor=lc, text_size=size.normal)
    table.cell(bias_tbl, 0, 1, tableIsShort   ? "BELOW ZERO γ ✓"  : is_short ? "below γ (no struct)" : "—", text_color=st, bgcolor=color.new(color.black, 65), text_size=size.small)
    table.cell(bias_tbl, 1, 1, is_neutral ? "POS γ ZONE"    : "—", text_color=nt, bgcolor=color.new(color.black, 65), text_size=size.small)
    table.cell(bias_tbl, 2, 1, tableIsLong    ? "ABOVE CEILING ✓" : is_long ? "above ceil (no struct)" : "—", text_color=lt, bgcolor=color.new(color.black, 65), text_size=size.small)

// ── Status Table ──────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 1, 6,
     bgcolor=color.new(color.black, 60), border_width=1, border_color=color.new(color.gray, 60))

// refresh is "MM/DD/YY HH:MM" in ET -- parsed so the GEX row can flag stale data.
int gex_ts = na
if str.length(refresh) >= 14
    gex_ts := timestamp("America/New_York",
         2000 + int(str.tonumber(str.substring(refresh, 6, 8))),
         int(str.tonumber(str.substring(refresh, 0, 2))),
         int(str.tonumber(str.substring(refresh, 3, 5))),
         int(str.tonumber(str.substring(refresh, 9, 11))),
         int(str.tonumber(str.substring(refresh, 12, 14))))

if barstate.islast
    bool is_short = close < flip_val
    bool is_long  = close > ceil_val
    bool tableIsShort = is_short and (not useStructFilter or structConfirmedShort)
    bool tableIsLong  = is_long  and (not useStructFilter or structConfirmedLong)
    string bias_txt = tableIsShort ? "▼  SHORT FAVORED" : tableIsLong ? "▲  LONG FAVORED" : (is_short or is_long) ? "▶  AWAITING STRUCT" : "▶  NEUTRAL"
    color  bias_col = tableIsShort ? color.red           : tableIsLong ? color.green        : color.gray
    bool cvd_ok    = (tableIsShort and cvd_falling) or (tableIsLong and cvd_rising)
    string cvd_txt = tableIsShort   ? (cvd_falling ? "CVD ↓  FAVORED" : "CVD ↑  AGAINST") :
                     tableIsLong    ? (cvd_rising  ? "CVD ↑  FAVORED" : "CVD ↓  AGAINST") :
                     cvd_rising ? "CVD ↑" : cvd_falling ? "CVD ↓" : "CVD →"
    color cvd_bg  = cvd_ok ? color.new(bias_col, 30) : color.new(color.gray, 75)
    color cvd_tc  = cvd_ok ? color.white             : color.new(color.gray, 40)
    string liq_txt = tableIsShort ? (shortLiqConfirmed ? "LIQ ✓ x" + str.tostring(shortZoneLiqCount) : "LIQ —") :
                      tableIsLong  ? (longLiqConfirmed  ? "LIQ ✓ x" + str.tostring(longZoneLiqCount)  : "LIQ —") : "LIQ —"
    table.cell(tbl, 0, 0, bias_txt,             text_color=bias_col,                  text_size=size.normal, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 0, 1, cvd_txt,              text_color=cvd_tc,                    text_size=size.small,  bgcolor=cvd_bg)
    table.cell(tbl, 0, 2, liq_txt,              text_color=color.aqua,                text_size=size.small,  bgcolor=color.new(color.black, 60))
    float  zg_dist = close - flip_val
    string zg_txt  = "ZERO γ  " + (zg_dist >= 0 ? "+" : "−") + str.tostring(math.abs(zg_dist), "0.0") + (zg_dist >= 0 ? " above · fade" : " below · momentum")
    color  zg_col  = zg_dist >= 0 ? color.teal : color.orange
    float  age_min = na(gex_ts) ? na : (timenow - gex_ts) / 60000.0
    bool   live    = rth and not na(age_min)
    color  gex_col = not live ? color.new(color.gray, 10) : age_min > 60 ? color.red : age_min > 30 ? color.yellow : color.new(color.gray, 10)
    string gex_txt = "🕐 GEX: " + refresh + (live ? "  (" + str.tostring(math.round(age_min)) + "m old)" : "")
    table.cell(tbl, 0, 3, zg_txt,  text_color=zg_col,  text_size=size.small, bgcolor=color.new(color.black, 60))
    table.cell(tbl, 0, 4, gex_txt, text_color=gex_col, text_size=size.small, bgcolor=color.new(color.black, 60))
    string prem_txt = na(es_premium) ? "ES−SPX prem: n/a (levels unshifted)" : "ES−SPX prem: " + str.tostring(es_premium, "0.00")
    table.cell(tbl, 0, 5, prem_txt, text_color=na(es_premium) ? color.red : color.new(color.gray, 10), text_size=size.small, bgcolor=color.new(color.black, 60))

// ── Alerts ────────────────────────────────────────────────────────────────────
// Wire these up via TradingView's own Create Alert dialog (choose this
// indicator, then one of these three conditions) to get a push/email/webhook
// the instant price actually touches a level, instead of watching the chart.
alertcondition(ta.cross(close, ceil_val),  title="GEX: crossed Ceiling",     message="Price crossed the Ceiling (major positive gamma) level.")
alertcondition(ta.cross(close, flip_val),  title="GEX: crossed Zero Gamma",  message="Price crossed the Zero Gamma (flip) level.")
alertcondition(ta.cross(close, speed_val), title="GEX: crossed Speed Zone",  message="Price crossed the Speed Zone (major negative gamma) level.")

// ── Optional: Gamma Regime Zone shading ─────────────────────────────────────
// Off by default (showZoneColoring, set above). Same SHORT/NEUTRAL/LONG
// classification the Bias Table already uses, just painted as a persistent
// background tint instead of only a table cell: below Zero Gamma reads as
// the amplifying regime, above Ceiling as the dampening regime, and the
// band between the two as neutral/transition.
bool zoneIsShort   = close < flip_val
bool zoneIsNeutral = close >= flip_val and close <= ceil_val
bool zoneIsLong    = close > ceil_val
bgcolor(showZoneColoring ? (zoneIsShort ? color.new(color.red, 93) : zoneIsLong ? color.new(color.green, 93) : color.new(color.yellow, 95)) : na, title="Gamma Regime Zone")
````
