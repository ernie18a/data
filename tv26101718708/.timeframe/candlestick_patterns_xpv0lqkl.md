# Candlestick Patterns

- url: https://www.tradingview.com/script/Xpv0lQKl-Candlestick-Patterns/
- type: indicator
- pine_id: PUB;8484b57b7b0e45b094820075186aa64e
- version: 3.0

## Description

Title: Candlestick Patterns

Description:

Detects and labels 15 classic Japanese candlestick patterns in real time, with a multi-timeframe trend filter that highlights which signals align with the prevailing trend direction.

Patterns detected

Single-candle patterns: Doji, Hammer, Hanging Man, Inverted Hammer, Shooting Star.

Two-candle patterns: Bullish Engulfing, Bearish Engulfing, Bullish Harami, Bearish Harami, Piercing Line, Dark Cloud Cover.

Three-candle patterns: Morning Star, Evening Star, Three White Soldiers, Three Black Crows.

Pattern logic

Candle anatomy is computed from body, upper wick, lower wick, and full range on each bar. The wick-to-body ratio threshold is configurable — default 2.0x means the shadow must be at least twice the body size for hammer and shooting star shapes. The Doji threshold is expressed as body size as a percentage of the full range, defaulting to 10%.

Engulfing patterns require the current candle to fully contain the prior candle's body. Harami requires the current body to fit inside the prior range and be less than 60% of the prior body size. Piercing Line requires the close to cross above the midpoint of the prior bearish candle; Dark Cloud Cover requires the close to cross below the midpoint of the prior bullish candle.

Morning and Evening Star use a three-bar setup: a strong directional candle, followed by a small-body indecision candle (body less than 30% of its range), followed by a confirmation candle that closes past the midpoint of the first candle.

Three White Soldiers and Three Black Crows require three consecutive same-direction closes, each higher/lower than the last, with the opens gapping slightly into the prior body.

Trend filter

An EMA crossover (default 20/50) determines trend direction on the current timeframe and three configurable higher timeframes via request.security(). With-trend signals are displayed at full opacity; counter-trend signals are shown at reduced opacity. An optional filter hides counter-trend patterns entirely.

MTF Trend Panel

A compact table in the bottom-right corner shows the current trend direction (▲ Bull / ▼ Bear) across the current timeframe plus the three configured higher timeframes, with the EMA pair displayed as a label. Each cell is color-coded green or red.

Display

Each detected pattern places a label above (bearish) or below (bullish) the candle with the pattern name. A subtle background color fill highlights the bar. Both label colors and background highlights are independently configurable.

Works on any instrument and timeframe.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  CANDLESTICK PATTERNS + MTF TREND FILTER
// ═══════════════════════════════════════════════════════════════════════════
//  Fourteen classic candlestick patterns, classified the way the literature
//  actually defines them, filtered against a multi-timeframe EMA trend.
//
//  Two things here are done differently from the usual pattern script:
//
//  1. HAMMER vs HANGING MAN IS DECIDED BY TREND, NOT BY COLOUR. They are the
//     same candle. What separates them is where it appears: a hammer ends a
//     decline, a hanging man ends an advance. A red hammer is still a hammer.
//     Same for Inverted Hammer vs Shooting Star.
//
//  2. THE GAP RULE IS A SETTING. Nison defines Piercing / Dark Cloud as opening
//     beyond the PRIOR CANDLE'S EXTREME, which is right for stocks. On forex,
//     crypto and 24h indices there are no opening gaps, so that definition
//     never fires and the pattern silently disappears. Both readings ship.
// ═══════════════════════════════════════════════════════════════════════════

indicator("Candlestick Patterns + MTF Trend Filter", "CandlesMTF",
     overlay = true, max_labels_count = 500)

grp_pat = "── Patterns ──"
show_hammer   = input.bool(true,  "Hammer / Hanging Man",       group=grp_pat)
show_inv      = input.bool(true,  "Inv Hammer / Shooting Star", group=grp_pat)
show_doji     = input.bool(false, "Doji",                       group=grp_pat)
show_engulf   = input.bool(true,  "Engulfing",                  group=grp_pat)
show_harami   = input.bool(false, "Harami",                     group=grp_pat)
show_star     = input.bool(true,  "Morning / Evening Star",     group=grp_pat)
show_soldiers = input.bool(true,  "3 Soldiers / 3 Crows",       group=grp_pat)
show_piercing = input.bool(true,  "Piercing / Dark Cloud",      group=grp_pat)

grp_thr = "── Thresholds ──"
wick_mult = input.float(2.0,  "Wick/body ratio",          group=grp_thr, minval=1.0, step=0.1)
doji_pct  = input.float(10.0, "Doji max body % of range", group=grp_thr, minval=1.0, maxval=40.0, step=1.0)
gap_rule  = input.string("Relaxed — below prior close", "Piercing / Dark Cloud gap",
     options=["Relaxed — below prior close", "Strict — beyond prior extreme"], group=grp_thr,
     tooltip="Strict is the textbook definition and is correct on instruments that gap at the open. On forex, crypto and 24h indices price opens where it closed, so the strict rule almost never triggers and both patterns vanish from the chart. Relaxed is the reading in common use.")

grp_flt = "── Significance filter ──"
min_body  = input.float(0.6,  "Minimum candle size (x ATR)", minval=0.0, step=0.1, group=grp_flt,
     tooltip="A pattern on a candle a third the size of the average one is not the pattern, it is noise wearing its name. This is the single setting that decides whether the chart is readable. Raise it until only the candles you would actually have noticed survive.")
eng_ratio = input.float(1.5,  "Engulfing must exceed prior body by", minval=1.0, step=0.1, group=grp_flt,
     tooltip="On 24h markets price opens where it closed, so 'engulfing' by one tick happens constantly. Requiring the body to be this many times the prior body is what makes the word mean something.")
pen_pct   = input.float(50.0, "Piercing / Dark Cloud penetration %", minval=50.0, maxval=100.0, step=5.0, group=grp_flt,
     tooltip="How deep into the prior body the close must reach. 50% is the textbook minimum; higher demands a more convincing reversal.")
cool_bars = input.int(5, "Minimum bars between labels", minval=0, maxval=100, group=grp_flt,
     tooltip="Stops clusters. Patterns overlap constantly, and three labels in four bars tell you nothing three did not.")

grp_vis = "── Display ──"
col_bull = input.color(color.new(#00c853, 0), "Bullish", group=grp_vis)
col_bear = input.color(color.new(#ff1744, 0), "Bearish", group=grp_vis)
col_neut = input.color(color.new(#787b86, 0), "Neutral", group=grp_vis)
show_bg  = input.bool(true, "Background highlight", group=grp_vis,
     tooltip="Marks the bar the pattern COMPLETED on, matching the label. It does not paint a whole run of bars where the condition happens to stay true.")

grp_trend = "── Trend Panel ──"
show_trend      = input.bool(true,  "Show trend panel",              group=grp_trend)
ema_fast        = input.int(20,     "EMA fast",                      group=grp_trend, minval=1, maxval=200)
ema_slow        = input.int(50,     "EMA slow",                      group=grp_trend, minval=1, maxval=500)
tf_1            = input.timeframe("60",  "TF 1",                     group=grp_trend)
tf_2            = input.timeframe("240", "TF 2",                     group=grp_trend)
tf_3            = input.timeframe("D",   "TF 3",                     group=grp_trend)
with_trend_only = input.bool(true,  "Show only with-trend patterns", group=grp_trend)

// ── Trend, computed FIRST ─────────────────────────────────────────────────
// The hammer family needs it to be classified at all, so it cannot live at the
// bottom of the script the way a display-only panel would.
_trend(f, s) => ta.ema(close, f) > ta.ema(close, s) ? 1 : -1

trend_now = _trend(ema_fast, ema_slow)
trend_tf1 = request.security(syminfo.tickerid, tf_1, _trend(ema_fast, ema_slow))
trend_tf2 = request.security(syminfo.tickerid, tf_2, _trend(ema_fast, ema_slow))
trend_tf3 = request.security(syminfo.tickerid, tf_3, _trend(ema_fast, ema_slow))

bool up_trend = trend_now == 1
bool dn_trend = trend_now == -1

// ── Candle anatomy ────────────────────────────────────────────────────────
atr14 = ta.atr(14)
body = math.abs(close - open)
uw   = high - math.max(close, open)
lw   = math.min(close, open) - low
rng  = high - low
bull = close >= open
bear = close < open

p_body = math.abs(close[1] - open[1])
p_rng  = high[1] - low[1]
p_bull = close[1] >= open[1]
p_bear = close[1] < open[1]

// Body-driven patterns are judged on the body; the hammer family has a small
// body by definition, so those are judged on the whole range instead.
bool sig_body = body >= min_body * atr14
bool sig_rng  = rng  >= min_body * atr14

// ── Pattern detection ─────────────────────────────────────────────────────
doji = show_doji and rng > 0 and body / rng * 100.0 < doji_pct

// Long lower wick, small upper wick. The SHAPE is one pattern; the CONTEXT
// gives it its name. Colour is irrelevant and was the old bug.
h_shape     = body > 0 and sig_rng and lw >= wick_mult * body and uw <= body * 0.5
hammer      = show_hammer and h_shape and dn_trend    // ends a decline
hanging_man = show_hammer and h_shape and up_trend    // ends an advance

inv_shape   = body > 0 and sig_rng and uw >= wick_mult * body and lw <= body * 0.5
inv_hammer  = show_inv and inv_shape and dn_trend
shoot_star  = show_inv and inv_shape and up_trend

bull_engulf = show_engulf and p_bear and bull and sig_body and close >= open[1] and open <= close[1] and body >= p_body * eng_ratio
bear_engulf = show_engulf and p_bull and bear and sig_body and close <= open[1] and open >= close[1] and body >= p_body * eng_ratio
bull_harami = show_harami and p_bear and bull and p_rng >= min_body * atr14 and high < high[1] and low > low[1] and body < p_body * 0.6
bear_harami = show_harami and p_bull and bear and p_rng >= min_body * atr14 and high < high[1] and low > low[1] and body < p_body * 0.6

bool  strict_gap = gap_rule == "Strict — beyond prior extreme"
float pierce_ref = strict_gap ? low[1]  : close[1]
float dark_ref   = strict_gap ? high[1] : close[1]
float pen = pen_pct / 100.0
piercing   = show_piercing and p_bear and bull and sig_body and open < pierce_ref and close > close[1] + (open[1] - close[1]) * pen
dark_cloud = show_piercing and p_bull and bear and sig_body and open > dark_ref   and close < close[1] - (close[1] - open[1]) * pen

star_ratio   = p_rng > 0 ? p_body / p_rng : 1.0
ms_setup     = p_bear and bar_index >= 2 and close[2] < open[2] and star_ratio < 0.3
morning_star = show_star and ms_setup and bull and sig_body and close > (open[2] + close[2]) / 2.0
es_setup     = p_bull and bar_index >= 2 and close[2] > open[2] and star_ratio < 0.3
evening_star = show_star and es_setup and bear and sig_body and close < (open[2] + close[2]) / 2.0

sol_dir        = bull and close[1] > open[1] and close[2] > open[2]
sol_asc        = close > close[1] and close[1] > close[2]
sol_gap        = open < close[1] and open > open[1]
three_soldiers = show_soldiers and sol_dir and sol_asc and sol_gap and sig_body
crow_dir       = bear and close[1] < open[1] and close[2] < open[2]
crow_asc       = close < close[1] and close[1] < close[2]
crow_gap       = open > close[1] and open < open[1]
three_crows    = show_soldiers and crow_dir and crow_asc and crow_gap and sig_body

// ── First bar of each run ─────────────────────────────────────────────────
// Everything downstream — labels, background AND alerts — uses these. Mixing
// the raw condition into the background or the alerts was what produced one
// label but three highlighted bars and three alerts on a three-bar run.
hammer_new   = hammer         and not hammer[1]
hanging_new  = hanging_man    and not hanging_man[1]
inv_hmr_new  = inv_hammer     and not inv_hammer[1]
shoot_new    = shoot_star     and not shoot_star[1]
bengulf_new  = bull_engulf    and not bull_engulf[1]
beargulf_new = bear_engulf    and not bear_engulf[1]
bharami_new  = bull_harami    and not bull_harami[1]
bearami_new  = bear_harami    and not bear_harami[1]
piercing_new = piercing       and not piercing[1]
dcloud_new   = dark_cloud     and not dark_cloud[1]
morning_new  = morning_star   and not morning_star[1]
evening_new  = evening_star   and not evening_star[1]
soldiers_new = three_soldiers and not three_soldiers[1]
crows_new    = three_crows    and not three_crows[1]
doji_new     = doji           and not doji[1]

// ── One label per side, however many patterns fire ────────────────────────
// A hammer that is also a bullish engulfing used to draw two labels at the
// same anchor, one hidden under the other. They are stacked into one instead.
addName(string acc, bool cond, string nm) =>
    cond ? (acc == "" ? nm : acc + "\n" + nm) : acc

string bullTxt = ""
bullTxt := addName(bullTxt, hammer_new,   "Hammer")
bullTxt := addName(bullTxt, inv_hmr_new,  "Inv Hammer")
bullTxt := addName(bullTxt, bengulf_new,  "Bull Engulf")
bullTxt := addName(bullTxt, bharami_new,  "Bull Harami")
bullTxt := addName(bullTxt, piercing_new, "Piercing")
bullTxt := addName(bullTxt, morning_new,  "Morning Star")
bullTxt := addName(bullTxt, soldiers_new, "3 Soldiers")

string bearTxt = ""
bearTxt := addName(bearTxt, hanging_new,  "Hanging Man")
bearTxt := addName(bearTxt, shoot_new,    "Shooting Star")
bearTxt := addName(bearTxt, beargulf_new, "Bear Engulf")
bearTxt := addName(bearTxt, bearami_new,  "Bear Harami")
bearTxt := addName(bearTxt, dcloud_new,   "Dark Cloud")
bearTxt := addName(bearTxt, evening_new,  "Evening Star")
bearTxt := addName(bearTxt, crows_new,    "3 Crows")

bool anyBull = bullTxt != ""
bool anyBear = bearTxt != ""
bool passBull = anyBull and (not with_trend_only or up_trend)
bool passBear = anyBear and (not with_trend_only or dn_trend)

// ── Labels ────────────────────────────────────────────────────────────────
// One mark per cooldown window. Patterns overlap constantly and a cluster of
// three in four bars says nothing the first one did not.
var int last_lbl = -9999
bool cool_ok = (bar_index - last_lbl) >= cool_bars
passBull := passBull and cool_ok
passBear := passBear and cool_ok
if passBull or passBear
    last_lbl := bar_index

if passBull
    label.new(bar_index, low, bullTxt, style = label.style_label_up,
         color = up_trend ? color.new(col_bull, 10) : color.new(col_bull, 60),
         textcolor = color.white, size = size.small)

if passBear
    label.new(bar_index, high, bearTxt, style = label.style_label_down,
         color = dn_trend ? color.new(col_bear, 10) : color.new(col_bear, 60),
         textcolor = color.white, size = size.small)

// Doji only when nothing else fired: it anchors where the bearish label goes,
// and a Doji is the least informative of the set — it should not cover a
// Shooting Star to announce that the body was small.
if doji_new and not passBull and not passBear
    label.new(bar_index, high, "Doji", style = label.style_label_down,
         color = color.new(col_neut, 10), textcolor = color.white, size = size.small)

bgcolor(show_bg and passBull ? color.new(col_bull, 88) : na)
bgcolor(show_bg and passBear ? color.new(col_bear, 88) : na)

// ── Trend Panel ───────────────────────────────────────────────────────────
// Built once. The old version deleted and rebuilt the whole table on every
// realtime tick, which is eleven object operations per tick for four values
// that change a handful of times a day.
_tcol(d) => d == 1 ? color.new(col_bull, 20) : color.new(col_bear, 20)
_ttxt(d) => d == 1 ? "▲ Bull" : "▼ Bear"
````
