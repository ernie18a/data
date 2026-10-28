# Breadth Topping Syndrome

- url: https://www.tradingview.com/script/WbFOdoNP-Breadth-Topping-Syndrome/
- type: indicator
- pine_id: PUB;98faee9fb4034b789e166423bff1be6c
- version: 1.0

## Description

This indicator plots a normalized breadth deterioration score in a separate pane and fires a discrete topping signal when several independent NYSE internal breadth conditions assemble while the market is still rising. The thesis is that major tops are a syndrome, not a single event: internal bifurcation, weakening participation and fading leadership tend to appear together near distributive peaks, and their conjunction inside an uptrend carries more information than any one of them alone.


█ [b]OVERVIEW[/b]

Breadth Topping Syndrome (BTS) condenses four warning conditions into one framework:

 - C1: a Miekka style divergence, where NYSE new 52 week highs and new 52 week lows are
  simultaneously elevated as a percentage of advances plus declines.
 - C2: Norman Fosback's High Low Logic Index at a high percentile of its own trailing history.
 - C3: weak S&P 500 participation (percentage of constituents above their 200 day moving
  average) while the trend reference index is in an uptrend.
 - C4: a weighted deterioration score built from the same normalized components exceeding
  a threshold.

When a configurable minimum number of these conditions has been observed within a short synchronization span and the trend gate is up, a trigger fires and opens a signal window. Inside the window the syndrome is Active only while the McClellan Oscillator is negative. Repeated triggers within a trailing lookback are counted as a cluster.


█ [b]HISTORY / BACKGROUND[/b]

The components have documented lineages. The simultaneous new highs and new lows divergence condition follows James R. Miekka's Hindenburg Omen specification (1995), itself derived from work by Martin Zweig and Norman Fosback: both extremes elevated at once, measured against advances plus declines, valid only in an uptrend, with the McClellan Oscillator acting as an activation gate inside a fixed window rather than as a co equal trigger. The High Low Logic Index is Fosback's, published in 1976: the minimum of new highs and new lows relative to total issues isolates the disagreement component of breadth. Percentage of stocks above the 200 day moving average is a standard participation measure. The McClellan Oscillator is the 19/39 period EMA differential of net advances, per Sherman and Marian McClellan.

The syndrome architecture that combines them is novel and is described in full below. The conceptual basis is that each component captures a different failure mode of an advance, so requiring several to appear near simultaneously filters the false positives that any single measure produces on its own.


█ [b]HOW IT WORKS[/b]

The script requests seven external series at the chart timeframe: NYSE advancing issues, declining issues, new 52 week highs, new 52 week lows, a trend reference index, and a primary plus fallback participation symbol. All requests use ignore_invalid_symbol, and a data integrity gate suppresses every signal when any core feed returns no value.

On each bar the script computes:

 - The Miekka ratios: new highs and new lows each divided by advances plus declines, times 100.
  C1 is true when both meet the threshold.
 - The High Low Logic Index: the minimum of new highs and new lows divided by advances plus
  declines, times 100, smoothed with an EMA, then converted to a percentile rank over the
  normalization lookback. C2 is true when the percentile meets the warning level.
 - The participation percentile: the participation series (gap filled with its last valid value so feed
  gaps do not distort the distribution) percentile ranked over the same lookback. C3 is true when
  the percentile is at or below the warning level while the trend reference index is above its close
  a configurable number of bars ago. This is the divergence conjunction: price rising, participation
  weak relative to its own recent history.
 - The leadership share: new highs divided by new highs plus new lows, times 100, percentile
  ranked and inverted.
 - The deterioration score: the weighted average of the HLLI percentile, the inverted participation
  percentile and the inverted leadership percentile, scaled 0 to 100. If both participation symbols
  fail to resolve, the score reweights automatically over the two remaining components. C4 is true
  when the score meets its threshold.

Each condition contributes to the syndrome if it was true on any bar within the synchronization span. When the count of contributing conditions reaches the required minimum while the uptrend gate is true, a trigger fires on the first such bar (edge triggered, so a persisting syndrome does not retrigger). The trigger opens a signal window measured in trading days. Within the window, the syndrome is Active while the McClellan Oscillator, computed as the fast EMA minus the slow EMA of net advances, is below zero, and deactivates when it turns positive without closing the window. The cluster count is the number of triggers within the trailing cluster lookback.


█ [b]HOW TO USE[/b]

The script is designed for the 1D timeframe. The breadth feeds are daily series, the window and cluster inputs are specified in trading days, and the Miekka and McClellan parameters are daily conventions, so daily resolution matches the granularity of the logic.

 - Blue score line: current breadth deterioration, 0 to 100, against a dashed threshold line and a
  dotted midline at 50. The line turns orange above the threshold and red while the syndrome
  is Active. Gray indicates missing core data.
 - Faint purple line: the HLLI percentile, shown separately because it is the slowest moving and
  most historically studied component.
 - Red triangle at the top of the pane: a syndrome trigger fired on that bar.
 - Small maroon diamond: the Miekka condition alone was true on that bar without a full trigger,
  useful for tracking the classical signal inside the broader framework.
 - Maroon background: syndrome Active (inside a signal window with the McClellan Oscillator
  negative). Orange background: window open but the oscillator is positive, so the syndrome is
  temporarily deactivated and will reactivate if the oscillator turns negative before the window
  expires.
 - Status table (top right): overall state, each condition's current value and contribution, the
  syndrome count, the oscillator value, bars remaining in the window, and the cluster count.

A single trigger is a caution flag. Two or more triggers within the cluster lookback have historically been the more serious configuration for divergence based breadth signals, and the script exposes a dedicated alert for that case. Four alerts are provided: trigger fired, syndrome turned Active, clustered trigger, and score crossing above its threshold.


█ [b]SETTINGS[/b]

 - Conditions Required (N of 4): syndrome count needed to trigger. Default 3.
 - Condition Sync Span: bars within which a condition still counts toward the syndrome. Default 5.
 - Signal Window: trading days a trigger keeps the window open. Default 30.
 - Cluster Lookback: trailing trading days over which triggers are counted. Default 60.
 - C1 Miekka NH/NL Threshold: minimum percent of advances plus declines for both new highs
  and new lows. Default 2.8.
 - C2 HLLI Warning Percentile: percentile of the smoothed HLLI that flags bifurcation. Default 90.
 - C3 Participation Warning Percentile: participation percentile at or below which weakness is
  flagged in an uptrend. Default 25.
 - C4 Deterioration Score Threshold: score level that flags composite weakness. Default 75.
 - Uptrend Lookback: bars over which the trend reference must have risen. Default 50.
 - HLLI EMA Length: smoothing applied to the raw HLLI ratio. Default 50.
 - Percentile Rank Lookback: window for all percentile ranks. Default 252.
 - Score weights for the bifurcation, participation and leadership components. Default 33.3 each.
 - MCO Fast EMA and Slow EMA: McClellan Oscillator periods. Defaults 19 and 39.
 - Data Symbols: all seven feeds are exposed as string inputs and can be substituted.
 - Show Status Table: toggles the table. Default on.


█ [b]WHAT MAKES IT ORIGINAL[/b]

The individual components are public domain methods. What this script does differently is the combination architecture. First, every component is percentile ranked against its own trailing distribution before use, so the warning levels adapt to the prevailing breadth regime instead of relying on fixed absolute thresholds calibrated to a decades old NYSE universe. Second, the conditions are fused through an N of M syndrome count with a synchronization span, not a same bar AND, which acknowledges that breadth deterioration components rarely align to the exact day. Third, the trigger inherits the two phase Miekka mechanism but generalizes it: the syndrome, not a single divergence, opens the window, and the McClellan Oscillator gates activation inside it. Fourth, trigger clustering is quantified directly on the chart rather than left to visual inspection. This conjunction of adaptive normalization, tolerant multi condition assembly, windowed gating and cluster counting does not correspond to any single published method and is the substance of the script.


█ [b]NOTES / LIMITATIONS[/b]

 - The breadth feeds have limited historical depth. No signals can exist before the feeds begin,
  and because every percentile rank requires the full normalization lookback (default 252 bars),
  the first year of available feed history produces unreliable ranks and should be disregarded.
 - The logic is designed for daily resolution. On other timeframes the external series return
  whatever the feeds report at that resolution, and the day denominated windows lose their
  intended meaning.
 - All values on the developing realtime bar update until the bar closes. Signals should be
  evaluated on closed bars. The script uses same timeframe requests with lookahead off and
  does not reference future data.
 - If neither participation symbol resolves, condition C3 can never contribute. With the default
  requirement of 3 of 4, all three remaining conditions must then assemble, which makes
  triggers strictly rarer. The table marks participation as N/A in that state.
 - Data is pulled from fixed external symbols regardless of the chart symbol. The chart symbol
  only determines the bar grid, so the indicator belongs on a US equity index chart at 1D.
 - Breadth divergence signals of this family have a documented false positive history. This tool
  flags conditions that have accompanied past tops. It is a risk assessment input, not a
  standalone trading signal, and no claim is made about future results.

## Source Code

````pine
// Breadth Topping Syndrome
//
// Combines three normalized NYSE internal-breadth dimensions into a single
// deterioration score, then applies an N-of-M syndrome trigger gated through
// a Miekka-style signal window with a McClellan Oscillator activation gate.
//
// Components:
//   C1  Miekka divergence  : new highs % AND new lows % both >= threshold of (adv + dec)
//   C2  Fosback HLLI       : min(NH, NL) / (adv + dec), EMA-smoothed, percentile-ranked
//   C3  Participation      : % of S&P 500 above 200DMA (S5TH, MMTH fallback),
//                            percentile-ranked and inverted; divergence = weak
//                            participation percentile while the index is in an uptrend
//   C4  Deterioration score: weighted composite of C2/C3/leadership percentiles
//
// Trigger fires when >= N of the four conditions have been true within the sync
// span while the trend gate is up. A trigger opens a signal window; the syndrome
// is ACTIVE only while the McClellan Oscillator is negative inside the window.
// Triggers within the trailing cluster lookback are counted; clusters are the
// stronger warning.
//
// Designed for the 1D timeframe on US equity index charts.

//@version=6
indicator("Breadth Topping Syndrome", shorttitle = "BTS", overlay = false, precision = 1)

// ─── INPUTS ──────────────────────────────────────────────────────────────────

g_syn = "Syndrome"
int    n_required   = input.int(3,    "Conditions Required (N of 4)",      minval = 1, maxval = 4, group = g_syn)
int    sync_span    = input.int(5,    "Condition Sync Span (bars)",        minval = 1, group = g_syn,
     tooltip = "A condition counts toward the syndrome if it was true on any bar within this span.")
int    window_len   = input.int(30,   "Signal Window (trading days)",      minval = 1, group = g_syn)
int    cluster_len  = input.int(60,   "Cluster Lookback (trading days)",   minval = 1, group = g_syn)

g_cond = "Conditions"
float  miekka_thr   = input.float(2.8, "C1: Miekka NH/NL Threshold %",     step = 0.1, group = g_cond)
float  hlli_warn    = input.float(90,  "C2: HLLI Warning Percentile",      minval = 50, maxval = 100, group = g_cond)
float  part_warn    = input.float(25,  "C3: Participation Warning Percentile", minval = 0, maxval = 50, group = g_cond)
float  score_warn   = input.float(75,  "C4: Deterioration Score Threshold", minval = 50, maxval = 100, group = g_cond)
int    trend_lb     = input.int(50,    "Uptrend Lookback (bars)",          minval = 1, group = g_cond)

g_norm = "Normalization"
int    hlli_ema_len = input.int(50,   "HLLI EMA Length",                   minval = 1, group = g_norm)
int    rank_len     = input.int(252,  "Percentile Rank Lookback",          minval = 50, group = g_norm)

g_wt = "Score Weights"
float  w_hlli       = input.float(33.3, "Bifurcation (HLLI) Weight",       minval = 0, maxval = 100, group = g_wt)
float  w_part       = input.float(33.3, "Participation Weight",            minval = 0, maxval = 100, group = g_wt)
float  w_lead       = input.float(33.3, "Leadership Weight",               minval = 0, maxval = 100, group = g_wt)

g_mco = "McClellan Gate"
int    mco_fast     = input.int(19,   "MCO Fast EMA",                      minval = 1, group = g_mco)
int    mco_slow     = input.int(39,   "MCO Slow EMA",                      minval = 1, group = g_mco)

g_sym = "Data Symbols"
string sym_adv      = input.string("INDEX:ADVN", "NYSE Advancing Issues",  group = g_sym)
string sym_dec      = input.string("INDEX:DECN", "NYSE Declining Issues",  group = g_sym)
string sym_hi       = input.string("INDEX:MAHN", "NYSE New 52W Highs",     group = g_sym)
string sym_lo       = input.string("INDEX:MALN", "NYSE New 52W Lows",      group = g_sym)
string sym_trend    = input.string("NYA",        "Trend Reference Index",  group = g_sym)
string sym_part_1   = input.string("S5TH",       "Participation (primary)", group = g_sym)
string sym_part_2   = input.string("MMTH",       "Participation (fallback)", group = g_sym)

g_disp = "Display"
bool   show_table   = input.bool(true, "Show Status Table", group = g_disp)

// ─── DATA ────────────────────────────────────────────────────────────────────

float adv    = request.security(sym_adv,    timeframe.period, close, ignore_invalid_symbol = true)
float dec    = request.security(sym_dec,    timeframe.period, close, ignore_invalid_symbol = true)
float nh     = request.security(sym_hi,     timeframe.period, close, ignore_invalid_symbol = true)
float nl     = request.security(sym_lo,     timeframe.period, close, ignore_invalid_symbol = true)
float trend  = request.security(sym_trend,  timeframe.period, close, ignore_invalid_symbol = true)
float part_1 = request.security(sym_part_1, timeframe.period, close, ignore_invalid_symbol = true)
float part_2 = request.security(sym_part_2, timeframe.period, close, ignore_invalid_symbol = true)

float participation = not na(part_1) ? part_1 : part_2

// Core feeds required for any signal. Participation is optional (score reweights).
bool data_ok = not na(adv) and not na(dec) and not na(nh) and not na(nl) and not na(trend)
bool part_ok = not na(participation)

// ─── COMPONENT CALCULATIONS ──────────────────────────────────────────────────

// Denominator per Miekka: advances plus declines
float total_ad = nz(adv) + nz(dec)

// C1 raw: Miekka simultaneous NH/NL divergence
float nh_pct = total_ad > 0 ? nz(nh) / total_ad * 100.0 : 0.0
float nl_pct = total_ad > 0 ? nz(nl) / total_ad * 100.0 : 0.0

// C2 raw: Fosback High Low Logic Index
float hlli_raw = total_ad > 0 ? math.min(nz(nh), nz(nl)) / total_ad * 100.0 : 0.0
float hlli     = ta.ema(hlli_raw, hlli_ema_len)
float hlli_pctl = ta.percentrank(hlli, rank_len)

// C3 raw: participation percentile. fixnan carries the last valid value so
// intermittent feed gaps do not pollute the rank history; if the feed never
// resolves, the series stays na and the score reweights.
float part_ff = fixnan(participation)
float part_pctl_raw = ta.percentrank(part_ff, rank_len)
float part_pctl = part_ok ? part_pctl_raw : na

// Leadership: share of new highs in total new extremes, percentile-ranked
float lead = nz(nh) + nz(nl) > 0 ? nz(nh) / (nz(nh) + nz(nl)) * 100.0 : 50.0
float lead_pctl = ta.percentrank(lead, rank_len)

// Deterioration score: high = deteriorating. Participation and leadership inverted.
float inv_part = part_ok ? 100.0 - part_pctl : na
float inv_lead = 100.0 - lead_pctl
float wt_total_full = w_hlli + w_part + w_lead
float wt_total_two  = w_hlli + w_lead
float score = part_ok ?
     (hlli_pctl * w_hlli + inv_part * w_part + inv_lead * w_lead) / (wt_total_full > 0 ? wt_total_full : 100.0) :
     (hlli_pctl * w_hlli + inv_lead * w_lead) / (wt_total_two > 0 ? wt_total_two : 100.0)

// Trend gate: reference index above its close trend_lb bars ago
bool uptrend = data_ok and trend > trend[trend_lb]

// McClellan Oscillator on NYSE net advances
float ad_net    = nz(adv) - nz(dec)
float mco       = ta.ema(ad_net, mco_fast) - ta.ema(ad_net, mco_slow)
bool  mco_neg   = mco < 0

// ─── SYNDROME CONDITIONS ─────────────────────────────────────────────────────

bool c1_now = data_ok and nh_pct >= miekka_thr and nl_pct >= miekka_thr
bool c2_now = data_ok and hlli_pctl >= hlli_warn
bool c3_now = data_ok and part_ok and part_pctl <= part_warn and uptrend
bool c4_now = data_ok and score >= score_warn

// A condition contributes if seen within the sync span (na before first
// occurrence maps to out-of-span)
bool c1_syn = nz(ta.barssince(c1_now), sync_span + 1) <= sync_span - 1
bool c2_syn = nz(ta.barssince(c2_now), sync_span + 1) <= sync_span - 1
bool c3_syn = nz(ta.barssince(c3_now), sync_span + 1) <= sync_span - 1
bool c4_syn = nz(ta.barssince(c4_now), sync_span + 1) <= sync_span - 1

int syn_count = (c1_syn ? 1 : 0) + (c2_syn ? 1 : 0) + (c3_syn ? 1 : 0) + (c4_syn ? 1 : 0)

// Edge-triggered: fires on the first bar the syndrome assembles
bool trigger_state = data_ok and uptrend and syn_count >= n_required
bool trigger = trigger_state and not trigger_state[1]

// ─── WINDOW, GATE, CLUSTER ───────────────────────────────────────────────────

int  bars_since = ta.barssince(trigger)
int  safe_since = na(bars_since) ? window_len + 1 : bars_since
bool in_window  = safe_since <= window_len
bool active     = in_window and mco_neg

int cluster = int(math.sum(trigger ? 1 : 0, cluster_len))

// ─── PLOTS ───────────────────────────────────────────────────────────────────

color score_col = not data_ok ? color.gray :
     active ? color.red :
     score >= score_warn ? color.orange :
     color.new(color.blue, 0)
plot(score, "Deterioration Score", color = score_col, linewidth = 2)
plot(hlli_pctl, "HLLI Percentile", color = color.new(color.purple, 60), linewidth = 1)

hline(score_warn, "Score Threshold", color = color.new(color.orange, 50), linestyle = hline.style_dashed)
hline(50, "Midline", color = color.new(color.gray, 70), linestyle = hline.style_dotted)

plotshape(trigger, "Syndrome Trigger", style = shape.triangledown, location = location.top,
     color = color.red, size = size.small)
plotshape(c1_now and not trigger, "Miekka Condition", style = shape.diamond, location = location.top,
     color = color.new(color.maroon, 40), size = size.tiny)

bgcolor(active ? color.new(color.maroon, 80) :
     in_window and not mco_neg ? color.new(color.orange, 88) : na,
     title = "Syndrome State")

// Data-window diagnostics
plot(nh_pct,   "NH % of A+D",        display = display.data_window)
plot(nl_pct,   "NL % of A+D",        display = display.data_window)
plot(hlli,     "HLLI (EMA)",         display = display.data_window)
plot(part_pctl,"Participation Pctl", display = display.data_window)
plot(inv_lead, "Leadership Pctl (inv)", display = display.data_window)
plot(mco,      "McClellan Osc",      display = display.data_window)
plot(syn_count,"Syndrome Count",     display = display.data_window)
plot(cluster,  "Cluster Count",      display = display.data_window)

// ─── STATUS TABLE ────────────────────────────────────────────────────────────

var table tbl = table.new(position.top_right, 2, 9, bgcolor = color.new(color.black, 80), border_width = 1)
if show_table and barstate.islast
    color hdr = color.white
    color on  = color.red
    color off = color.new(color.gray, 20)
    color okc = color.green

    table.cell(tbl, 0, 0, "BTS", text_color = hdr, text_size = size.small)
    table.cell(tbl, 1, 0, not data_ok ? "DATA UNAVAILABLE" :
         active ? "ACTIVE" :
         in_window ? "WINDOW OPEN (MCO+)" : "INACTIVE",
         text_color = not data_ok ? color.gray : active ? on : in_window ? color.orange : okc,
         text_size = size.small)

    table.cell(tbl, 0, 1, "C1 Miekka", text_color = c1_syn ? on : off, text_size = size.small)
    table.cell(tbl, 1, 1, str.tostring(nh_pct, "#.0") + "% / " + str.tostring(nl_pct, "#.0") + "%",
         text_color = c1_syn ? on : off, text_size = size.small)

    table.cell(tbl, 0, 2, "C2 HLLI pctl", text_color = c2_syn ? on : off, text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(hlli_pctl, "#.0"), text_color = c2_syn ? on : off, text_size = size.small)

    table.cell(tbl, 0, 3, "C3 Part pctl", text_color = c3_syn ? on : off, text_size = size.small)
    table.cell(tbl, 1, 3, part_ok ? str.tostring(part_pctl, "#.0") : "N/A",
         text_color = not part_ok ? color.gray : c3_syn ? on : off, text_size = size.small)

    table.cell(tbl, 0, 4, "C4 Score", text_color = c4_syn ? on : off, text_size = size.small)
    table.cell(tbl, 1, 4, str.tostring(score, "#.0"), text_color = c4_syn ? on : off, text_size = size.small)

    table.cell(tbl, 0, 5, "Count", text_color = hdr, text_size = size.small)
    table.cell(tbl, 1, 5, str.tostring(syn_count) + " / " + str.tostring(n_required),
         text_color = syn_count >= n_required ? on : hdr, text_size = size.small)

    table.cell(tbl, 0, 6, "MCO", text_color = mco_neg ? on : okc, text_size = size.small)
    table.cell(tbl, 1, 6, str.tostring(mco, "#.0"), text_color = mco_neg ? on : okc, text_size = size.small)

    table.cell(tbl, 0, 7, "Window", text_color = hdr, text_size = size.small)
    table.cell(tbl, 1, 7, in_window ? str.tostring(window_len - safe_since) + " bars left" : "closed",
         text_color = in_window ? color.orange : off, text_size = size.small)

    table.cell(tbl, 0, 8, "Cluster", text_color = cluster >= 2 ? on : hdr, text_size = size.small)
    table.cell(tbl, 1, 8, str.tostring(cluster) + " in " + str.tostring(cluster_len),
         text_color = cluster >= 2 ? on : hdr, text_size = size.small)

// ─── ALERTS ──────────────────────────────────────────────────────────────────

alertcondition(trigger, "BTS Trigger",
     "Breadth Topping Syndrome: trigger fired (syndrome assembled in uptrend). Signal window open.")
alertcondition(active and not active[1], "BTS Active",
     "Breadth Topping Syndrome: ACTIVE (inside signal window, McClellan Oscillator negative).")
alertcondition(trigger and cluster >= 2, "BTS Cluster",
     "Breadth Topping Syndrome: second trigger within cluster lookback. Clustered signals are the stronger warning.")
alertcondition(ta.crossover(score, score_warn), "BTS Score Threshold",
     "Breadth deterioration score crossed above threshold.")
````
