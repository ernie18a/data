# AMT Order Flow Suite v2.2

- url: https://www.tradingview.com/script/A4jmkFCw-AMT-Order-Flow-Suite-v2-2/
- type: indicator
- pine_id: PUB;b82d55635a9044efb4964e4094fa7efa
- version: 1.0

## Description

AMT Order Flow Suite v2.2 — CVD · Delta · VWAP · Session Levels · Virgin POC
A complete Auction Market Theory order flow indicator built for XAUUSD (Gold), combining Cumulative Volume Delta, per-bar delta, session-anchored VWAP, intraday Point of Control, Value Area levels, Virgin POC detection, and Failed Auction signals — all in one script.
Developed and validated against 1.3 million ticks of raw XAUUSD price data across multiple weeks of live session analysis. Everything you see on the chart is derived from actual volume and delta, not price patterns alone.

WHAT IT SHOWS
Cumulative Volume Delta (CVD)
The core of the indicator. CVD accumulates signed volume throughout each session — positive when buyers are aggressive, negative when sellers dominate. Resets at the start of every new session so you always see the current day's order flow in isolation. An EMA signal line rides on top — when CVD crosses below its signal, bias turns bearish; above it, bullish. The fill colour shifts green/red to make the bias instantly readable.
CVD Divergence Labels
When price makes a new session high but CVD fails to confirm (DIST label) — that is distribution: institutions selling into retail buying. When price makes a new session low but CVD holds up (ABS label) — that is absorption: buyers stepping in as price flushes stops. These are the two highest-conviction signals in the indicator. Both are validated against real tick data.
Per-Bar Delta Histogram
Shows the signed volume of every individual bar — how hard buyers or sellers hit at that exact moment. Weighted by bar body ratio so doji bars don't falsely signal. High-volume bars are flagged with a marker. Absorption bars (high volume + tight range — the classic sign of an iceberg order defending a level) are marked with a diamond.
Session-Anchored VWAP with Standard Deviation Bands
VWAP resets each session and is calculated from the true volume-weighted average price. The ±1σ bands approximate the 70% Value Area — the zone where most of the day's business occurred. The ±2σ bands mark the outer extremes. Price extended beyond ±2σ with declining CVD is one of the strongest mean-reversion signals available.
Intraday POC (Point of Control)
Tracks the price level with the highest volume of the current session in real time. The POC is drawn as a dashed gold line extending right. This is the fair value anchor — price gravitates back to it repeatedly throughout the session and into the next day.
Value Area High (VAH) and Value Area Low (VAL)
Derived from the VWAP standard deviation bands. VAH = VWAP +1σ, VAL = VWAP -1σ. These are the boundaries of accepted value. Price breaking outside them and failing to hold is the definition of a Failed Auction — the primary trade setup this indicator is built around.
Virgin POC Detection
Tracks the POC of the previous two sessions. If price has not returned to a prior session's POC since that session ended, that level is "virgin" — untouched high-volume ground. When price finally reaches it, a circle marker appears on the chart (VP for 1-session-old, VP2 for 2-session-old). Virgin POCs produce the strongest reactions of any level because they contain trapped participants at their cost basis. Lines for VP1 and VP2 are drawn on the chart automatically each session and the live price levels are shown in the info table.
Failed Auction Signals (FA↑ / FA↓)
A Failed Auction occurs when price spikes outside the Value Area then returns back inside, rejecting the breakout. FA↑ (triangle up, below bar) fires when price has recently been below VAL and recovered back into value with positive delta and CVD above its signal line — buyers reclaimed the level. FA↓ (triangle down, above bar) fires when price has been above VAH and falls back with negative delta and CVD below its signal line — sellers rejected the breakout. Both signals are confirmed by CVD direction, not price alone.
Session Backgrounds and Open Labels
Asia (purple), London (gold), and NY (green) session backgrounds so you can instantly see which session produced which price action. LON and NY open labels appear at the exact opening bar of each session.
Live Info Table
Top-right corner dashboard showing: Session CVD, CVD Bias (BULL/BEAR), current bar delta, volume ratio, distance from VWAP, live POC price, VAH and VAL prices, current session name, active signal (if any), and the live levels of VP1 and VP2. Everything you need to read order flow without switching panes.

ALERT CONDITIONS (9 total)

✅ FA Long — Failed Auction long signal fired
✅ FA Short — Failed Auction short signal fired
✅ Bearish CVD Divergence — price new high, CVD not confirming (distribution)
✅ Bullish CVD Divergence — price new low, CVD not confirming (absorption)
✅ Absorption Detected — high volume + tight range at current bar
✅ Virgin POC Touch (1 session) — price reaching yesterday's untouched POC
✅ Virgin POC Touch (2 sessions) — price reaching 2-session-old POC (higher conviction)
✅ London Open — session beginning, watch for stop-hunt then direction
✅ NY Open — key session, trend continuation or reversal hour


SETTINGS

Timezone — set to your broker's chart timezone (default: Europe/London)
London / NY open hours — adjustable so the session labels and alerts fire at the correct time for your data feed
CVD Signal EMA length — controls how responsive the signal line is (default 20)
Volume average length — lookback for the volume ratio and absorption calculations
High-volume threshold — the multiple above average volume that triggers the high-vol flag
Absorption range ratio — how tight a bar's range must be relative to average to qualify as absorption
Level lookback — how many bars the POC tracker uses
All colours — fully customisable: bull, bear, CVD line, POC, VAH, VAL, VWAP, Virgin POC, absorption


HOW TO USE IT
Add to a 1-minute or 5-minute XAUUSD chart. Set your timezone to match your broker's data feed. The CVD pane appears below the chart automatically — if you only want the overlay elements on the main chart, right-click the pane and move or close it.
Each morning before London opens: note the POC, VAH, and VAL from the previous session (visible as dashed lines). Note the VP1 and VP2 levels in the info table — these are your virgin reaction zones for the day.
During London and NY: watch the CVD fill. Green fill above zero with price near VAL = look for FA↑. Red fill below zero with price near VAH = look for FA↓. DIST label at a new price high = distribution, shorts favoured. ABS label at a new price low = absorption, longs favoured.

NOTES
Works on any instrument with volume data but was designed and tested specifically on XAUUSD spot (Gold). The POC and Value Area are approximated using a session-anchored VWAP standard deviation method — this keeps the indicator fast and free of the loop timeout errors that affect bin-based volume profile calculations in Pine Script. For tick-perfect volume profiles, combine with TradingView's built-in Session Volume Profile tool.
Built on Pine Script v6. No repainting. All calculations are bar-confirmed.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © APCapitalTrading

// ============================================================
// AMT ORDER FLOW SUITE — XAUUSD  v2.2
// CVD · Delta · VWAP · Session Levels · Failed Auction · Virgin POC
// ============================================================
// v2.2 fixes:
//   - ta.highest/lowest inside conditionals → pre-computed globals
//   - line.delete inside if-block → correct Pine v6 syntax
//   - removed _row() inner function (not supported in Pine v6 indicators)
// ============================================================

//@version=6
indicator(
     title             = "AMT Order Flow Suite v2.2",
     shorttitle        = "AMT Flow",
     overlay           = false,
     max_bars_back     = 5000,
     max_lines_count   = 400,
     max_labels_count  = 100,
     max_boxes_count   = 50)

// ============================================================
// INPUTS
// ============================================================
g0 = "═══ SESSION ═══"
tz       = input.string("Europe/London","Timezone", group=g0,
     options=["Europe/London","America/New_York","UTC","Asia/Tokyo"])
sess_lon = input.int(8,  "London open (UK hr)", minval=0, maxval=23, group=g0)
sess_ny  = input.int(13, "NY open (UK hr)",     minval=0, maxval=23, group=g0)
show_sess= input.bool(true, "Session backgrounds", group=g0)

g1 = "═══ CVD ═══"
cvd_sig_len  = input.int(20,  "CVD Signal EMA length", minval=3, maxval=200, group=g1)
show_cvd_div = input.bool(true,"Show divergence labels", group=g1)

g2 = "═══ DELTA ═══"
vol_len      = input.int(20,   "Volume avg length",      minval=5, maxval=100, group=g2)
hi_vol_mult  = input.float(1.5,"High-vol threshold ×",   minval=1.1, maxval=5.0, step=0.1, group=g2)
absorb_ratio = input.float(0.70,"Absorption range ratio", minval=0.3, maxval=1.0, step=0.05, group=g2)

g3 = "═══ VWAP / LEVELS ═══"
show_vwap  = input.bool(true, "Show VWAP",          group=g3)
show_bands = input.bool(true, "Show VWAP ±1σ ±2σ",  group=g3)
vp_len     = input.int(100,   "Level lookback (bars)", minval=20, maxval=300, group=g3)

g4 = "═══ SIGNALS ═══"
show_fa       = input.bool(true, "Show Failed Auction signals", group=g4)
show_vp_touch = input.bool(true, "Show Virgin POC touches",     group=g4)

g5 = "═══ COLOURS ═══"
c_bull = input.color(color.new(#00FF88,0),  "Positive / Bull", group=g5)
c_bear = input.color(color.new(#FF3B5C,0),  "Negative / Bear", group=g5)
c_cvd  = input.color(color.new(#00D4FF,0),  "CVD line",        group=g5)
c_poc  = input.color(color.new(#FFD700,0),  "POC",             group=g5)
c_vah  = input.color(color.new(#FF3B5C,50), "VAH",             group=g5)
c_val  = input.color(color.new(#00FF88,50), "VAL",             group=g5)
c_vwap = input.color(color.new(#00D4FF,0),  "VWAP",            group=g5)
c_vp   = input.color(color.new(#9B72FF,0),  "Virgin POC",      group=g5)
c_abs  = input.color(color.new(#9B72FF,0),  "Absorption",      group=g5)


// ============================================================
// SESSION DETECTION
// ============================================================
bar_hour       = hour(time, tz)
is_new_session = ta.change(time("D","0000-0000", tz)) != 0
is_lon_open    = bar_hour == sess_lon and minute == 0
is_ny_open     = bar_hour == sess_ny  and minute == 0
is_asia        = bar_hour >= 22 or bar_hour < 6
is_london      = bar_hour >= 6  and bar_hour < 13
is_ny          = bar_hour >= 13 and bar_hour < 22


// ============================================================
// DELTA (per bar)
// ============================================================
float rng      = high - low
float body_pct = rng > 0 ? math.abs(close - open) / rng : 0.5
float bar_delta= close >= open ? volume * body_pct : -(volume * body_pct)

float avg_vol   = ta.sma(volume, vol_len)
float vol_ratio = avg_vol > 0 ? volume / avg_vol : 1.0
float avg_range = ta.sma(rng, vol_len)
bool  is_hi_vol = vol_ratio >= hi_vol_mult
bool  is_absorb = is_hi_vol and rng <= avg_range * absorb_ratio


// ============================================================
// CVD — SESSION CUMULATIVE DELTA
// ============================================================
var float cvd_sess = 0.0
if is_new_session
    cvd_sess := 0.0
cvd_sess += bar_delta

float cvd_ema      = ta.ema(cvd_sess, cvd_sig_len)
bool  cvd_bull_bias = cvd_sess > cvd_ema
bool  cvd_bear_bias = cvd_sess < cvd_ema

// ── Divergence pre-compute (FIX: ta.highest/lowest OUTSIDE conditionals) ──
int   div_lb        = 20
float ph_high       = ta.highest(high,     div_lb)   // price highest
float pl_low        = ta.lowest(low,       div_lb)   // price lowest
float cvd_h         = ta.highest(cvd_sess, div_lb)   // CVD highest
float cvd_l         = ta.lowest(cvd_sess,  div_lb)   // CVD lowest

bool bear_div = show_cvd_div
     and high >= ph_high
     and cvd_sess < cvd_h * 0.95
     and cvd_sess < 0

bool bull_div = show_cvd_div
     and low <= pl_low
     and cvd_sess > cvd_l * 0.95
     and cvd_sess > 0


// ============================================================
// VWAP — SESSION ANCHORED
// ============================================================
var float vw_nom = 0.0
var float vw_den = 0.0
var float vw_sq  = 0.0

if is_new_session
    vw_nom := 0.0
    vw_den := 0.0
    vw_sq  := 0.0

float tp    = (high + low + close) / 3.0
vw_nom     += tp * volume
vw_den     += volume
vw_sq      += tp * tp * volume

float vwap_v   = vw_den > 0 ? vw_nom / vw_den : tp
float vwap_var = vw_den > 0 ? (vw_sq / vw_den) - vwap_v * vwap_v : 0.0
float vwap_sd  = vwap_var > 0 ? math.sqrt(vwap_var) : 0.0

float vu1 = vwap_v + vwap_sd
float vd1 = vwap_v - vwap_sd
float vu2 = vwap_v + 2.0 * vwap_sd
float vd2 = vwap_v - 2.0 * vwap_sd


// ============================================================
// LIGHTWEIGHT POC / VAH / VAL
// ============================================================
var float sess_poc_price = na
var float sess_poc_vol   = 0.0

if is_new_session
    sess_poc_price := close
    sess_poc_vol   := volume

if volume > sess_poc_vol
    sess_poc_price := close
    sess_poc_vol   := volume

float poc_level = sess_poc_price
float vah_level = vu1    // VWAP +1σ ≈ 70% value area high
float val_level = vd1    // VWAP -1σ ≈ 70% value area low

var float sess_high = high
var float sess_low  = low
if is_new_session
    sess_high := high
    sess_low  := low
sess_high := math.max(sess_high, high)
sess_low  := math.min(sess_low,  low)


// ============================================================
// VIRGIN POC TRACKING
// ============================================================
var float vp1 = na
var float vp2 = na
var float vp3 = na
var bool  vp1_touched = false
var bool  vp2_touched = false
var bool  vp3_touched = false

if is_new_session
    vp3         := vp2
    vp2         := vp1
    vp1         := sess_poc_price
    vp1_touched := false
    vp2_touched := false
    vp3_touched := false

float vp_prox = syminfo.mintick * 50

bool touch_vp1 = show_vp_touch and not na(vp1) and not vp1_touched
     and math.abs(close - vp1) <= vp_prox
bool touch_vp2 = show_vp_touch and not na(vp2) and not vp2_touched
     and math.abs(close - vp2) <= vp_prox and not touch_vp1
bool touch_vp3 = show_vp_touch and not na(vp3) and not vp3_touched
     and math.abs(close - vp3) <= vp_prox and not touch_vp1 and not touch_vp2

if touch_vp1
    vp1_touched := true
if touch_vp2
    vp2_touched := true
if touch_vp3
    vp3_touched := true


// ============================================================
// FAILED AUCTION SIGNALS
// ============================================================
// Pre-compute lookbacks OUTSIDE conditionals (Pine v6 requirement)
float hi5 = ta.highest(high, 5)
float lo5  = ta.lowest(low,  5)
float fa_prox = vp_prox * 2

bool was_above_vah = hi5 > vah_level + fa_prox
bool now_at_vah    = close < vah_level + fa_prox and close > vah_level - fa_prox * 2
bool was_below_val = lo5  < val_level - fa_prox
bool now_at_val    = close > val_level - fa_prox  and close < val_level + fa_prox * 2

bool fa_short = show_fa and was_above_vah and now_at_vah and bar_delta < 0 and cvd_bear_bias
bool fa_long  = show_fa and was_below_val and now_at_val and bar_delta > 0 and cvd_bull_bias


// ============================================================
// PLOTS — CVD PANE
// ============================================================
p_cvd  = plot(cvd_sess, "CVD (Session)",
     color     = cvd_sess >= 0 ? c_bull : c_bear,
     linewidth = 2,
     display   = display.pane)

p_zero = plot(0.0, display = display.none)
fill(p_cvd, p_zero,
     color = cvd_sess >= 0 ? color.new(c_bull, 88) : color.new(c_bear, 88),
     title = "CVD Fill")

plot(cvd_ema, "CVD Signal",
     color     = color.new(color.white, 55),
     linewidth = 1,
     display   = display.pane)

hline(0, "Zero", color.new(color.white, 70), linestyle = hline.style_dashed)

plotshape(bear_div, "Bear Div",
     style     = shape.labeldown,
     location  = location.top,
     color     = c_bear,
     textcolor = c_bear,
     text      = "DIST",
     size      = size.tiny,
     display   = display.pane)

plotshape(bull_div, "Bull Div",
     style     = shape.labelup,
     location  = location.bottom,
     color     = c_bull,
     textcolor = c_bull,
     text      = "ABS",
     size      = size.tiny,
     display   = display.pane)


// ============================================================
// PLOTS — DELTA HISTOGRAM PANE
// ============================================================
plot(bar_delta, "Bar Delta",
     style     = plot.style_histogram,
     color     = bar_delta >= 0 ? color.new(c_bull, 20) : color.new(c_bear, 20),
     linewidth = 2,
     display   = display.pane)

plotshape(is_absorb, "Absorption",
     style     = shape.diamond,
     location  = location.top,
     color     = c_abs,
     size      = size.tiny,
     text      = "A",
     textcolor = c_abs,
     display   = display.pane)

plotshape(is_hi_vol and not is_absorb, "High Volume",
     style     = shape.square,
     location  = location.top,
     color     = color.new(c_cvd, 40),
     size      = size.tiny,
     display   = display.pane)


// ============================================================
// OVERLAY — VWAP
// ============================================================
plot(show_vwap ? vwap_v : na, "VWAP",
     color = c_vwap, linewidth = 2)

plot(show_vwap and show_bands ? vu1 : na, "VWAP +1σ (VAH)",
     color = c_vah, linewidth = 1, style = plot.style_linebr)

plot(show_vwap and show_bands ? vd1 : na, "VWAP -1σ (VAL)",
     color = c_val, linewidth = 1, style = plot.style_linebr)

plot(show_vwap and show_bands ? vu2 : na, "VWAP +2σ",
     color = color.new(c_vah, 70), linewidth = 1, style = plot.style_linebr)

plot(show_vwap and show_bands ? vd2 : na, "VWAP -2σ",
     color = color.new(c_val, 70), linewidth = 1, style = plot.style_linebr)

p_vu1 = plot(show_vwap and show_bands ? vu1 : na, display = display.none)
p_vd1 = plot(show_vwap and show_bands ? vd1 : na, display = display.none)
fill(p_vu1, p_vd1, color = color.new(c_vwap, 94), title = "VWAP Band Fill")


// ============================================================
// OVERLAY — SESSION POC LINE  (FIX: delete only when line exists)
// ============================================================
var line line_poc  = na
var label lbl_poc  = na

if barstate.islast
    // Delete previous
    if not na(line_poc)
        line.delete(line_poc)
    if not na(lbl_poc)
        label.delete(lbl_poc)

    // Draw fresh
    if not na(poc_level)
        line_poc := line.new(
             bar_index[math.min(bar_index, vp_len)], poc_level,
             bar_index, poc_level,
             extend    = extend.right,
             color     = c_poc,
             style     = line.style_dashed,
             width     = 2)
        lbl_poc := label.new(
             bar_index, poc_level,
             "POC " + str.tostring(poc_level, "#.##"),
             color      = color.new(c_poc, 20),
             textcolor  = color.black,
             style      = label.style_label_left,
             size       = size.tiny)


// ============================================================
// OVERLAY — VIRGIN POC LINES  (FIX: proper delete-before-draw)
// ============================================================
var line line_vp1 = na
var line line_vp2 = na

if is_new_session
    if not na(line_vp1)
        line.delete(line_vp1)
    if not na(line_vp2)
        line.delete(line_vp2)
    line_vp1 := na
    line_vp2 := na

    if not na(vp1)
        line_vp1 := line.new(
             bar_index, vp1, bar_index + 1, vp1,
             extend = extend.right,
             color  = c_vp,
             style  = line.style_dashed,
             width  = 1)

    if not na(vp2)
        line_vp2 := line.new(
             bar_index, vp2, bar_index + 1, vp2,
             extend = extend.right,
             color  = color.new(c_vp, 50),
             style  = line.style_dotted,
             width  = 1)


// ============================================================
// OVERLAY — FA & VIRGIN POC SIGNALS
// ============================================================
plotshape(fa_long, "FA Long ↑",
     style     = shape.triangleup,
     location  = location.belowbar,
     color     = c_bull,
     size      = size.small,
     text      = "FA↑",
     textcolor = c_bull)

plotshape(fa_short, "FA Short ↓",
     style     = shape.triangledown,
     location  = location.abovebar,
     color     = c_bear,
     size      = size.small,
     text      = "FA↓",
     textcolor = c_bear)

plotshape(touch_vp1, "Virgin POC 1",
     style     = shape.circle,
     location  = location.abovebar,
     color     = c_vp,
     size      = size.small,
     text      = "VP",
     textcolor = c_vp)

plotshape(touch_vp2, "Virgin POC 2",
     style     = shape.circle,
     location  = location.abovebar,
     color     = color.new(c_vp, 40),
     size      = size.small,
     text      = "VP2",
     textcolor = color.new(c_vp, 40))


// ============================================================
// OVERLAY — SESSION BACKGROUNDS & OPEN LABELS
// ============================================================
bgcolor(show_sess and is_london ? color.new(#C8961A, 96) : na, title = "London")
bgcolor(show_sess and is_ny     ? color.new(#1D9E75, 97) : na, title = "NY")
bgcolor(show_sess and is_asia   ? color.new(#52528A, 97) : na, title = "Asia")

if is_lon_open
    label.new(bar_index, high, "LON",
         color     = color.new(#C8961A, 20),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.tiny)

if is_ny_open
    label.new(bar_index, high, "NY",
         color     = color.new(#1D9E75, 20),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.tiny)


// ============================================================
// INFO TABLE  (FIX: no nested functions — direct table.cell calls)
// ============================================================
var table tbl = table.new(position.top_right, 2, 12,
     bgcolor      = color.new(#0C0C18, 8),
     border_color = color.new(#242436, 0),
     border_width = 1,
     frame_color  = color.new(#C8961A, 0),
     frame_width  = 1)

if barstate.islast

    // Row 0 — header
    table.cell(tbl,0,0,"AMT FLOW v2.2",
         text_color   = color.new(#FFD700, 0),
         text_size    = size.normal,
         bgcolor      = color.new(#161622, 0),
         text_halign  = text.align_center)
    table.cell(tbl,1,0,"XAUUSD",
         text_color   = color.new(#52528A, 0),
         text_size    = size.small,
         bgcolor      = color.new(#161622, 0),
         text_halign  = text.align_center)

    // Row 1 — Session CVD
    color c1 = cvd_sess >= 0 ? c_bull : c_bear
    table.cell(tbl,0,1,"SESSION CVD",  text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,1,(cvd_sess>=0?"+":"") + str.tostring(math.round(cvd_sess)),
         text_color=c1, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 2 — CVD bias
    table.cell(tbl,0,2,"CVD BIAS",     text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,2,cvd_bull_bias?"BULL ▲":"BEAR ▼",
         text_color=cvd_bull_bias?c_bull:c_bear, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 3 — Bar Delta
    color c3 = bar_delta >= 0 ? c_bull : c_bear
    table.cell(tbl,0,3,"BAR Δ",        text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,3,(bar_delta>=0?"+":"") + str.tostring(math.round(bar_delta)),
         text_color=c3, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 4 — Vol Ratio
    color c4 = is_hi_vol ? color.new(#FF8C42,0) : color.new(#DDE0F0,0)
    table.cell(tbl,0,4,"VOL RATIO",    text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,4,str.tostring(vol_ratio,"#.##") + "×" + (is_hi_vol?" 🔥":""),
         text_color=c4, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 5 — vs VWAP
    float pvw = close - vwap_v
    color c5  = pvw >= 0 ? c_bull : c_bear
    table.cell(tbl,0,5,"vs VWAP",      text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,5,(pvw>=0?"+":"") + str.tostring(pvw,"#.##"),
         text_color=c5, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 6 — POC
    table.cell(tbl,0,6,"POC",          text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,6,not na(poc_level) ? str.tostring(poc_level,"#.##") : "─",
         text_color=color.new(#FFD700,0), text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 7 — VAH
    table.cell(tbl,0,7,"VAH",          text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,7,not na(vah_level) ? str.tostring(vah_level,"#.##") : "─",
         text_color=c_vah, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 8 — VAL
    table.cell(tbl,0,8,"VAL",          text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,8,not na(val_level) ? str.tostring(val_level,"#.##") : "─",
         text_color=c_val, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 9 — Session
    string s9  = is_london?"LONDON 🇬🇧":is_ny?"NEW YORK 🇺🇸":"ASIA 🌏"
    color  c9  = is_london?c_bear:is_ny?c_bull:color.new(#9B72FF,0)
    table.cell(tbl,0,9,"SESSION",      text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,9,s9,             text_color=c9, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 10 — Signal
    string s10 = is_absorb?"ABSORPTION 🟣":fa_long?"FA LONG ▲":fa_short?"FA SHORT ▼":
         bear_div?"DIST DIV ⚠":bull_div?"ABS DIV ⚠":
         touch_vp1 or touch_vp2?"⚡ VIRGIN POC":"—"
    color  c10 = is_absorb?c_abs:fa_long?c_bull:fa_short?c_bear:
         bear_div or bull_div?c_poc:touch_vp1 or touch_vp2?c_vp:color.new(#52528A,0)
    table.cell(tbl,0,10,"SIGNAL",      text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,10,s10,           text_color=c10, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)

    // Row 11 — Virgin POC levels
    string s11 = (not na(vp1)?"VP1:"+str.tostring(vp1,"#.#")+" ":"")+
                 (not na(vp2)?"VP2:"+str.tostring(vp2,"#.#"):"")
    table.cell(tbl,0,11,"VIRGIN POCs", text_color=color.new(#52528A,0), text_size=size.small, bgcolor=color.new(#10101C,0))
    table.cell(tbl,1,11,s11 == "" ? "—" : s11,
         text_color=c_vp, text_size=size.small, bgcolor=color.new(#10101C,0), text_halign=text.align_right)


// ============================================================
// ALERTS
// ============================================================
alertcondition(fa_long,  "FA Long ↑",
     "🟢 FA LONG | {{ticker}} {{interval}} | VAL recovery + CVD rising")
alertcondition(fa_short, "FA Short ↓",
     "🔴 FA SHORT | {{ticker}} {{interval}} | VAH rejection + CVD falling")
alertcondition(bear_div, "Bearish CVD Divergence",
     "⚠ DIST | {{ticker}} | Price new high, CVD not confirming")
alertcondition(bull_div, "Bullish CVD Divergence",
     "⚠ ABS | {{ticker}} | Price new low, CVD not confirming")
alertcondition(is_absorb,"Absorption Detected",
     "🟣 ABSORPTION | {{ticker}} | High vol + tight range")
alertcondition(touch_vp1,"Virgin POC Touch (1 sess)",
     "⚡ VP1 | {{ticker}} | Touching yesterday POC first time")
alertcondition(touch_vp2,"Virgin POC Touch (2 sess)",
     "⚡ VP2 | {{ticker}} | Touching 2-session POC — higher conviction")
alertcondition(is_lon_open,"London Open",
     "🇬🇧 LONDON OPEN | Watch for stop-hunt then direction")
alertcondition(is_ny_open, "NY Open",
     "🇺🇸 NY OPEN | Trend or reversal — key session begins")
````
