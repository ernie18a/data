# Composite Liquidity Flow: five-asset weighted volume delta

- url: https://www.tradingview.com/script/jTZmMRqW-Composite-Liquidity-Flow-five-asset-weighted-volume-delta/
- type: indicator
- pine_id: PUB;3a74a461cc7a4765a81c992214928067
- version: 2.0

## Description

What it does

One histogram that answers a single question: which way is the whole index complex leaning right now? It estimates buying and selling pressure across five instruments at once, weights them, smooths them, and prints the net as a z-scored delta with an agreement layer on top.

What is original here

Volume delta and RSI are both public methodology, and neither is mine. Three things here are not standard:

1. Pressure is attributed per bar from candle geometry, then priced in dollars rather than counted in shares. A 600-dollar instrument and a 60-dollar instrument therefore contribute on a comparable scale, which a raw share-count composite cannot do.

2. The five legs are not summed. Index futures, their tracking funds, and an inverse hedge fund are weighted separately, and the hedge leg has its logic inverted, so buying in the inverse product is counted as selling pressure on the complex. Hedging demand is treated as information rather than noise. This is the part I have not seen elsewhere.

3. The composite is z-scored against its own recent distribution, so the same scale reads correctly on a quiet session and on a high-volatility print.

The RSI layer is a display filter, not an input to the flow calculation. It gates when markers are allowed to print and never changes the histogram. That is the reason for the combination: flow describes who is pushing, RSI describes whether price has already travelled, and a marker is only allowed when the two agree. Without the filter the same flow model prints far more markers, most of them late.

How it works

Per-instrument pressure comes from candle structure. On an up bar, the body plus the lower wick is attributed to buyers and the upper wick to sellers; on a down bar the attribution reverses. That fraction multiplies the bar volume, then the closing price, producing a dollar figure per leg. Legs are weighted, summed, smoothed with an exponential average, then converted to a z-score against a rolling lookback. A session filter zeroes the fund legs outside regular hours, where their volume is unrepresentative of real positioning.

Divergences require three conditions at once: price at a lookback extreme, three consecutive bars of the composite moving the other way, and optional confirmation from the filter. A cooldown then suppresses repeats so the markers stay rare enough to mean something.

How to use it

Built for intraday index trading and tuned by default for 5-minute charts. Above the zero line and rising, with the filter supportive, means the composite tape agrees with a long. Below and falling is the mirror. The divergence markers are warnings about the move in progress, not entries. The dashboard reports each component separately so you can see which one is disagreeing before you act on the net.

What it cannot do

Markers are evaluated on the live bar, so a divergence or agreement arrow can appear and then disappear before the bar closes. Judge them on closed bars only. Nothing is drawn in the past and no confirmed marker moves once its bar has closed.

Everything here is estimated from open, high, low, close and volume. It is a structural proxy for order flow, not tick data, and it inherits every weakness a proxy has: it cannot see the order book, it cannot distinguish an aggressive buyer from a passive one, and on thin instruments the attribution is close to meaningless. It describes the index complex only and says nothing useful about an individual stock. It does not predict anything. It describes what the current bar and its neighbors have already printed.

Settings

Five symbols and their weights, smoothing length and z-score lookback, filter parameters, divergence strictness and cooldown, session handling, and a display toggle for each visual layer.

## Source Code

````pine
//@version=6
indicator("Composite Liquidity Flow Elite", "CLF Elite", format = format.price, precision = 2, max_labels_count = 50)

// =============================================================================
// COMPOSITE LIQUIDITY FLOW ELITE
//
// Measures candle-location pressure across five configurable assets, scales
// every leg by its own relative volume, inverts the hedge leg, and normalizes
// the active weighted composite. This avoids mixing raw futures contracts,
// ETF shares, and price×volume values as though they shared one unit.
//
// Integrity rules
//  • All markers and alerts require a confirmed chart bar.
//  • Security requests use lookahead_off; no future bars are requested.
//  • Missing legs are removed from both numerator and denominator.
//  • Signals stop when active data coverage falls below the configured floor.
//  • Divergence compares confirmed price pivots, not rolling-range proximity.
//
// Timeframe requirements
//  • Intraday charts only. The session gate, per-leg volume baselines, and the
//    composite universe are defined against the regular New York session.
//
// Honest limitations
//  • Nothing here is a signal or a forecast. Agreement markers mean the
//    composite and the filter currently point the same way, nothing more.
//  • Candle-location pressure estimates participation; it is not bid/ask delta.
//  • Cross-symbol feeds can have different sessions, delays, and volume rules.
//  • Relative-volume scaling improves comparability but does not create a
//    causal or predictive relationship between the selected instruments.
//  • Loaded history and symbol entitlements can change displayed results.
// =============================================================================

// =============================================================================
// 1. Configuration
// =============================================================================
grp_comp = "Composite assets"
sym_1 = input.symbol("NQ1!", "Asset 1 (tech futures)", group=grp_comp)
sym_2 = input.symbol("ES1!", "Asset 2 (S&P futures)", group=grp_comp)
sym_3 = input.symbol("SPY",  "Asset 3 (S&P fund)", group=grp_comp)
sym_4 = input.symbol("QQQ",  "Asset 4 (tech fund)", group=grp_comp)
sym_5 = input.symbol("SQQQ", "Asset 5 (inverse hedge)", group=grp_comp)
min_active_legs = input.int(4, "Minimum active legs for signals", minval = 2, maxval = 5, group = grp_comp,
     tooltip = "Blocks markers and alerts when too much of the composite is missing or outside its session.")

grp_weights = "Asset weighting"
wt_nq = input.float(0.5, "NQ weight", minval=0, maxval=2, step=0.1, group=grp_weights, tooltip="Futures leg weight.")
wt_es = input.float(0.5, "ES weight", minval=0, maxval=2, step=0.1, group=grp_weights)
wt_spy = input.float(0.7, "SPY weight", minval=0, maxval=2, step=0.1, group=grp_weights, tooltip="Fund flow reads differently from futures, so it is weighted up by default.")
wt_qqq = input.float(0.7, "QQQ weight", minval=0, maxval=2, step=0.1, group=grp_weights)
wt_sqqq = input.float(0.4, "SQQQ weight", minval=0, maxval=2, step=0.1, group=grp_weights, tooltip="Inverse hedge, logic inverted.")

grp_smooth = "Smoothing and normalization"
ema_length = input.int(25, "Smoothing length", minval=1, maxval=100, group=grp_smooth, tooltip="25 is a reasonable starting point on a 5 minute chart.")
use_normalization = input.bool(true, "Normalize values (z-score)", group=grp_smooth, tooltip="Compresses the scale so quiet and volatile sessions read the same way.")
norm_length = input.int(50, "Normalization lookback", minval=10, maxval=200, group=grp_smooth)
volume_baseline = input.int(30, "Per-asset relative-volume baseline", minval = 5, maxval = 200, group = grp_smooth,
     tooltip = "Each asset's signed pressure is scaled by its own average volume before assets are combined. This prevents futures and ETFs from dominating solely because their raw units differ.")
rvol_cap = input.float(5.0, "Per-asset RVOL cap", minval = 1.0, maxval = 20.0, step = 0.5,
     group = grp_smooth, tooltip = "Caps isolated bad prints and extreme opening volume from hijacking the entire composite.")

grp_rsi = "Relative strength filter"
use_rsi_confluence = input.bool(true, "Require filter agreement for markers", group=grp_rsi, tooltip="When off, agreement markers print on composite flow alone.")
rsi_length = input.int(14, "Filter length", minval=5, maxval=30, group=grp_rsi)
rsi_ob = input.int(70, "Upper band", minval=60, maxval=90, group=grp_rsi)
rsi_os = input.int(30, "Lower band", minval=10, maxval=40, group=grp_rsi)
rsi_source_sym = input.symbol("ES1!", "Filter source symbol", group=grp_rsi, tooltip="Symbol the filter is computed from.")

grp_div = "Divergence detection"
show_divergences = input.bool(true, "Show divergences", group=grp_div)
div_strength = input.int(3, "Price pivot strength", minval = 1, maxval = 10, group = grp_div,
     tooltip = "A divergence is confirmed only after this many bars form to the right of a price pivot.")
div_min_flow = input.float(0.25, "Minimum flow disagreement (z)", minval = 0.0, maxval = 3.0,
     step = 0.05, group = grp_div)
require_rsi_for_div = input.bool(true, "Require filter confirmation", group=grp_div, tooltip="Only show a divergence when the filter also confirms: at least 60 at a price high for bearish, at most 40 at a price low for bullish. These are fixed confirmation levels, separate from the marker bands above.")

grp_session = "Session filter"
use_session_filter = input.bool(true, "Filter non-regular-hours data", group=grp_session,
     tooltip="Applies the same regular-hours gate to every leg so the composite universe does not change between overnight futures-only data and the cash-session open.")
session_time = input.session("0930-1600", "Regular session", group=grp_session)
hide_premarket_hist = input.bool(true, "Suppress pre-market histogram", group=grp_session, tooltip="Zeroes the histogram before the regular session.")

grp_visual = "Visual settings"
show_cloud = input.bool(false, "Show pressure cloud", group=grp_visual, tooltip="Off by default; the histogram is cleaner alone.")
show_histogram = input.bool(true, "Show delta histogram", group=grp_visual)
show_momentum = input.bool(true, "Show flow momentum", group=grp_visual)
show_dashboard = input.bool(true, "Show dashboard", group=grp_visual)
show_confluence_signals = input.bool(true, "Show agreement markers", group=grp_visual, tooltip="Arrows when flow and the filter align.")
mom_length = input.int(5, "Momentum length", minval=1, maxval=20, group=grp_visual)
min_breadth = input.float(0.60, "Minimum directional breadth", minval = 0.50, maxval = 1.0,
     step = 0.05, group = grp_visual, tooltip = "Share of active asset weight that must agree with the composite direction.")
signal_cooldown = input.int(10, "Agreement cooldown bars", minval = 0, maxval = 100, group = grp_visual)
tbl_size = input.string(size.small, "Dashboard text size", options = [size.tiny, size.small, size.normal], group = grp_visual)
tbl_pos = input.string(position.top_right, "Dashboard position",
     options = [position.top_right, position.top_left, position.middle_right, position.middle_left,
                 position.bottom_right, position.bottom_left], group = grp_visual)

if barstate.isfirst and not timeframe.isintraday
    runtime.error("Composite Liquidity Flow Elite requires an intraday chart.")

// =============================================================================
// 2. Session helpers
// =============================================================================
is_rth() =>
    not na(time(timeframe.period, session_time, "America/New_York"))

in_session = is_rth()

// =============================================================================
// 3. Filter calculation, from the specified symbol
// Lookahead is explicitly off: this script never reads future data.
// =============================================================================
// RSI is calculated inside the requested symbol's context. Calculating it
// after requesting `close` would make the result depend on the host chart's
// gaps and session rather than the filter symbol's own bar sequence.
rsi_val = request.security(rsi_source_sym, timeframe.period, ta.rsi(close, rsi_length),
     gaps = barmerge.gaps_off, ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off)

rsi_bullish = rsi_val < rsi_os or (rsi_val > rsi_val[1] and rsi_val[1] < rsi_os)
rsi_bearish = rsi_val > rsi_ob or (rsi_val < rsi_val[1] and rsi_val[1] > rsi_ob)
rsi_neutral_bull = rsi_val > 50 and rsi_val < rsi_ob
rsi_neutral_bear = rsi_val < 50 and rsi_val > rsi_os

// =============================================================================
// 4. Per-asset pressure calculation
// =============================================================================
leg_metrics(bool apply_session) =>
    bool session_ok = apply_session ? is_rth() : true
    float spread = high - low
    // When the session gate is active, overnight futures bars do not enter the
    // RTH volume baseline. Otherwise the cash open is compared with thin
    // overnight volume and receives a structurally inflated score every day.
    // The average is a persistent session-gated RMA rather than ta.ema over an
    // na-gapped series: ta.ema reseeds from an SMA after every na gap and that
    // seed needs a full window of consecutive valid bars, which left the
    // baseline dead for the first `volume_baseline` bars of every single day.
    // This form carries yesterday's regular-hours average into today's open.
    var float avg_volume = na
    if session_ok and not na(volume) and volume > 0
        avg_volume := na(avg_volume) ? volume : (avg_volume * (volume_baseline - 1) + volume) / volume_baseline
    bool valid = session_ok and not na(volume) and volume > 0 and not na(avg_volume) and avg_volume > 0 and spread > 0
    // Close-location value is algebraically equivalent to the original
    // body/wick allocation, but makes the signed pressure explicit.
    float close_location = valid ? (2.0 * close - high - low) / spread : na
    float relative_volume = valid ? math.min(volume / avg_volume, rvol_cap) : na
    float signed_flow = valid ? close_location * relative_volume : na
    [signed_flow, valid]

request_leg(string symbol_name, bool apply_session) =>
    request.security(symbol_name, timeframe.period, leg_metrics(apply_session),
         gaps = barmerge.gaps_on, ignore_invalid_symbol = true, lookahead = barmerge.lookahead_off)

// =============================================================================
// 5. Aggregate data from all assets
// =============================================================================
[flow1, valid1] = request_leg(sym_1, use_session_filter)
[flow2, valid2] = request_leg(sym_2, use_session_filter)
[flow3, valid3] = request_leg(sym_3, use_session_filter)
[flow4, valid4] = request_leg(sym_4, use_session_filter)
[hedgeRaw, valid5] = request_leg(sym_5, use_session_filter)
float flow5 = valid5 ? -hedgeRaw : na

float activeW1 = valid1 and wt_nq > 0 ? wt_nq : 0.0
float activeW2 = valid2 and wt_es > 0 ? wt_es : 0.0
float activeW3 = valid3 and wt_spy > 0 ? wt_spy : 0.0
float activeW4 = valid4 and wt_qqq > 0 ? wt_qqq : 0.0
float activeW5 = valid5 and wt_sqqq > 0 ? wt_sqqq : 0.0
float active_weight = activeW1 + activeW2 + activeW3 + activeW4 + activeW5
int active_legs = (activeW1 > 0 ? 1 : 0) + (activeW2 > 0 ? 1 : 0) +
     (activeW3 > 0 ? 1 : 0) + (activeW4 > 0 ? 1 : 0) + (activeW5 > 0 ? 1 : 0)

float weighted_flow = (valid1 ? flow1 * wt_nq : 0.0) + (valid2 ? flow2 * wt_es : 0.0) +
     (valid3 ? flow3 * wt_spy : 0.0) + (valid4 ? flow4 * wt_qqq : 0.0) +
     (valid5 ? flow5 * wt_sqqq : 0.0)
float composite_flow = active_weight > 0 ? weighted_flow / active_weight : na

float weighted_buy = (valid1 ? math.max(flow1, 0.0) * wt_nq : 0.0) +
     (valid2 ? math.max(flow2, 0.0) * wt_es : 0.0) + (valid3 ? math.max(flow3, 0.0) * wt_spy : 0.0) +
     (valid4 ? math.max(flow4, 0.0) * wt_qqq : 0.0) + (valid5 ? math.max(flow5, 0.0) * wt_sqqq : 0.0)
float weighted_sell = (valid1 ? math.max(-flow1, 0.0) * wt_nq : 0.0) +
     (valid2 ? math.max(-flow2, 0.0) * wt_es : 0.0) + (valid3 ? math.max(-flow3, 0.0) * wt_spy : 0.0) +
     (valid4 ? math.max(-flow4, 0.0) * wt_qqq : 0.0) + (valid5 ? math.max(-flow5, 0.0) * wt_sqqq : 0.0)
float total_buy = active_weight > 0 ? weighted_buy / active_weight : na
float total_sell = active_weight > 0 ? weighted_sell / active_weight : na

float bullish_weight = (valid1 and flow1 > 0 ? wt_nq : 0.0) + (valid2 and flow2 > 0 ? wt_es : 0.0) +
     (valid3 and flow3 > 0 ? wt_spy : 0.0) + (valid4 and flow4 > 0 ? wt_qqq : 0.0) +
     (valid5 and flow5 > 0 ? wt_sqqq : 0.0)
float bearish_weight = (valid1 and flow1 < 0 ? wt_nq : 0.0) + (valid2 and flow2 < 0 ? wt_es : 0.0) +
     (valid3 and flow3 < 0 ? wt_spy : 0.0) + (valid4 and flow4 < 0 ? wt_qqq : 0.0) +
     (valid5 and flow5 < 0 ? wt_sqqq : 0.0)
float bull_breadth = active_weight > 0 ? bullish_weight / active_weight : na
float bear_breadth = active_weight > 0 ? bearish_weight / active_weight : na

// =============================================================================
// 6. Smoothing and normalization
// =============================================================================
// Persistent EMAs updated only on bars where the composite exists. ta.ema over
// the na-gapped composite reseeded every morning and needed a full window of
// consecutive in-session bars before producing output, so with the session
// filter on, the pane was structurally blank for the first part of every day.
float emaAlpha = 2.0 / (ema_length + 1)
var float smooth_buy = na
var float smooth_sell = na
var float raw_delta = na
if not na(total_buy)
    smooth_buy := na(smooth_buy) ? total_buy : smooth_buy + emaAlpha * (total_buy - smooth_buy)
if not na(total_sell)
    smooth_sell := na(smooth_sell) ? total_sell : smooth_sell + emaAlpha * (total_sell - smooth_sell)
if not na(composite_flow)
    raw_delta := na(raw_delta) ? composite_flow : raw_delta + emaAlpha * (composite_flow - raw_delta)

// The normalization window holds the last `norm_length` in-session composite
// values. Running ta.stdev over the calendar series either died on the
// overnight na block or, patched with carry-forward, understated the spread by
// filling the window with frozen repeats. A valid-only ring does neither.
var array<float> normWindow = array.new_float()
if not na(composite_flow) and not na(raw_delta)
    array.push(normWindow, raw_delta)
    if array.size(normWindow) > norm_length
        array.shift(normWindow)
float delta_mean = array.size(normWindow) >= 10 ? array.avg(normWindow) : na
float delta_std = array.size(normWindow) >= 10 ? array.stdev(normWindow) : na
float norm_delta = not na(delta_std) and delta_std > 0 ? (raw_delta - delta_mean) / delta_std : na

float delta = use_normalization ? norm_delta : raw_delta
// Signals always use the standardized series so their thresholds do not
// change when the user switches the display between raw and normalized units.
float analysis_delta = norm_delta
bool data_ready = active_legs >= min_active_legs and not na(analysis_delta)

float display_delta = hide_premarket_hist and not in_session ? na : delta

// Momentum is a plain difference, not ta.roc(). delta is a z-score that crosses
// zero, and ta.roc divides by delta[n]: near zero that produces spikes in the
// hundreds, and when delta[n] is negative the sign of the result inverts, so
// improving flow scored as deteriorating. A difference is in the same units as
// delta, plots on the same scale, and cannot divide by zero.
float flow_momentum = delta - delta[mom_length]

bool flow_bullish = data_ready and analysis_delta > 0
bool flow_bearish = data_ready and analysis_delta < 0
// Renamed: these are first differences, so they mean rising and falling.
// Acceleration would be the second difference. The old names described
// something the code never computed.
bool flow_rising_now = analysis_delta > analysis_delta[1]
bool flow_falling_now = analysis_delta < analysis_delta[1]

// =============================================================================
// 7. Confirmed structural divergence
// =============================================================================
// A genuine divergence compares like-for-like confirmed price pivots. The old
// rolling-range test could fire without price making a structural high or low.
float pricePivotHigh = ta.pivothigh(high, div_strength, div_strength)
float pricePivotLow = ta.pivotlow(low, div_strength, div_strength)
var float priorPivotHighPrice = na
var float priorPivotHighFlow = na
var float priorPivotLowPrice = na
var float priorPivotLowFlow = na
bool show_bear_div = false
bool show_bull_div = false

if barstate.isconfirmed and not na(pricePivotHigh)
    float pivotFlowHigh = analysis_delta[div_strength]
    float pivotRsiHigh = rsi_val[div_strength]
    bool flowReadyHigh = not na(pivotFlowHigh) and active_legs[div_strength] >= min_active_legs
    bool rawBearDiv = flowReadyHigh and not na(priorPivotHighPrice) and
         pricePivotHigh > priorPivotHighPrice and priorPivotHighFlow - pivotFlowHigh >= div_min_flow
    bool rsiBearOK = not require_rsi_for_div or (not na(pivotRsiHigh) and pivotRsiHigh >= 60)
    show_bear_div := show_divergences and in_session[div_strength] and rawBearDiv and rsiBearOK
    if flowReadyHigh
        priorPivotHighPrice := pricePivotHigh
        priorPivotHighFlow := pivotFlowHigh

if barstate.isconfirmed and not na(pricePivotLow)
    float pivotFlowLow = analysis_delta[div_strength]
    float pivotRsiLow = rsi_val[div_strength]
    bool flowReadyLow = not na(pivotFlowLow) and active_legs[div_strength] >= min_active_legs
    bool rawBullDiv = flowReadyLow and not na(priorPivotLowPrice) and
         pricePivotLow < priorPivotLowPrice and pivotFlowLow - priorPivotLowFlow >= div_min_flow
    bool rsiBullOK = not require_rsi_for_div or (not na(pivotRsiLow) and pivotRsiLow <= 40)
    show_bull_div := show_divergences and in_session[div_strength] and rawBullDiv and rsiBullOK
    if flowReadyLow
        priorPivotLowPrice := pricePivotLow
        priorPivotLowFlow := pivotFlowLow

// =============================================================================
// 8. Agreement markers
// =============================================================================
// use_rsi_confluence was declared but never referenced: the filter was always
// on and the toggle did nothing. It is now wired to the agreement markers.
bool bull_filter_ok = use_rsi_confluence ? (rsi_bullish or rsi_neutral_bull) : true
bool bear_filter_ok = use_rsi_confluence ? (rsi_bearish or rsi_neutral_bear) : true

bool strong_bull_confluence = flow_bullish and flow_rising_now and bull_filter_ok and
     not na(bull_breadth) and bull_breadth >= min_breadth and in_session
bool strong_bear_confluence = flow_bearish and flow_falling_now and bear_filter_ok and
     not na(bear_breadth) and bear_breadth >= min_breadth and in_session

bool bull_cross = ta.crossover(analysis_delta, 0)
bool bear_cross = ta.crossunder(analysis_delta, 0)

bool confirmed_bull_cross = barstate.isconfirmed and data_ready and bull_cross and bull_filter_ok and in_session
bool confirmed_bear_cross = barstate.isconfirmed and data_ready and bear_cross and bear_filter_ok and in_session

var int last_bull_conf_bar = -1000000
var int last_bear_conf_bar = -1000000

bool show_bull_confluence = barstate.isconfirmed and strong_bull_confluence and not strong_bull_confluence[1] and
     bar_index - last_bull_conf_bar >= signal_cooldown and show_confluence_signals
bool show_bear_confluence = barstate.isconfirmed and strong_bear_confluence and not strong_bear_confluence[1] and
     bar_index - last_bear_conf_bar >= signal_cooldown and show_confluence_signals

if show_bull_confluence
    last_bull_conf_bar := bar_index
if show_bear_confluence
    last_bear_conf_bar := bar_index

// =============================================================================
// 9. Flow strength
// =============================================================================
float avg_delta = ta.sma(math.abs(analysis_delta), 20)
float flow_strength = not na(avg_delta) and avg_delta > 0 ? math.abs(analysis_delta) / avg_delta : na

bool strong_bull_flow_state = flow_bullish and flow_strength > 1.5 and in_session
bool strong_bear_flow_state = flow_bearish and flow_strength > 1.5 and in_session
bool strong_bull_flow = barstate.isconfirmed and strong_bull_flow_state and not strong_bull_flow_state[1]
bool strong_bear_flow = barstate.isconfirmed and strong_bear_flow_state and not strong_bear_flow_state[1]

// =============================================================================
// 10. Plotting
// =============================================================================
color col_buy = color.new(color.teal, 50)
color col_sell = color.new(color.red, 50)
color col_fill = smooth_buy > smooth_sell ? color.new(color.teal, 85) : color.new(color.red, 85)

plot_buy = plot(show_cloud ? smooth_buy : na, "Buying pressure", color=col_buy, linewidth=1)
plot_sell = plot(show_cloud ? smooth_sell : na, "Selling pressure", color=col_sell, linewidth=1)
fill(plot_buy, plot_sell, color=show_cloud ? col_fill : na, title="Pressure cloud")

color col_delta_pos_strong = color.new(#00E676, 20)
color col_delta_pos_weak = color.new(#00E676, 60)
color col_delta_neg_strong = color.new(#FF5252, 20)
color col_delta_neg_weak = color.new(#FF5252, 60)
color col_neutral = color.new(color.gray, 70)

color hist_color = na
if hide_premarket_hist and not in_session
    hist_color := col_neutral
else if delta > 0
    hist_color := delta > delta[1] ? col_delta_pos_strong : col_delta_pos_weak
else
    hist_color := delta < delta[1] ? col_delta_neg_strong : col_delta_neg_weak

plot(show_histogram ? display_delta : na, "Net flow delta", style=plot.style_columns, color=hist_color)

hline(0, "Zero line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

plot(show_momentum and (not hide_premarket_hist or in_session) ? flow_momentum : na,
     "Flow momentum", color=color.new(color.yellow, 30), linewidth=2)

// Divergences are discovered `div_strength` bars after the pivot confirms, but
// drawn on the actual pivot bar. Alerts still fire only at confirmation time.
plotshape(show_bear_div ? delta[div_strength] : na, title = "Bearish divergence",
     style = shape.triangledown, location = location.absolute, offset = -div_strength,
     color = color.orange, size = size.normal, text = "Div", textcolor = color.orange)
plotshape(show_bull_div ? delta[div_strength] : na, title = "Bullish divergence",
     style = shape.triangleup, location = location.absolute, offset = -div_strength,
     color = color.lime, size = size.normal, text = "Div", textcolor = color.lime)

plotshape(show_bull_confluence, title = "Bullish agreement", style = shape.arrowup,
     location = location.bottom, color = #00E676, size = size.large)
plotshape(show_bear_confluence, title = "Bearish agreement", style = shape.arrowdown,
     location = location.top, color = #FF5252, size = size.large)

plotshape(confirmed_bull_cross ? display_delta : na, title = "Confirmed bullish cross",
     style = shape.circle, location = location.absolute, color = color.teal, size = size.tiny)
plotshape(confirmed_bear_cross ? display_delta : na, title = "Confirmed bearish cross",
     style = shape.circle, location = location.absolute, color = color.red, size = size.tiny)

// =============================================================================
// 11. Session background
// =============================================================================
bgcolor(not in_session ? color.new(color.gray, 95) : na, title="Outside regular session")

// =============================================================================
// 12. Dashboard
// =============================================================================
if show_dashboard and barstate.islast
    var table dash = table.new(tbl_pos, 2, 9, bgcolor=color.new(#1a1a2e, 5), border_color=color.new(color.gray, 60), border_width=1)

    table.cell(dash, 0, 0, "Composite flow", text_color=color.white, text_size=tbl_size, bgcolor=color.new(#16213e, 0))
    table.cell(dash, 1, 0, in_session ? "Regular" : "Extended", text_color=in_session ? color.lime : color.gray, text_size=tbl_size, bgcolor=color.new(#16213e, 0))

    bool bulls_winning = not na(analysis_delta) and analysis_delta > 0
    string status_text = na(analysis_delta) ? "Warming" : not data_ready ? "Data limited" : bulls_winning ? "Bullish" : "Bearish"
    color status_color = not data_ready ? color.gray : bulls_winning ? #00E676 : #FF5252
    table.cell(dash, 0, 1, "Direction", text_color=color.gray, text_size=tbl_size)
    table.cell(dash, 1, 1, status_text, text_color=status_color, text_size=tbl_size)

    string strength_label = na(flow_strength) ? "-" : flow_strength > 2.0 ? "Extreme" : flow_strength > 1.5 ? "Strong" : flow_strength > 1.0 ? "Normal" : "Weak"
    color strength_color = not na(flow_strength) and flow_strength > 1.5 ? status_color : color.gray
    table.cell(dash, 0, 2, "Strength", text_color=color.gray, text_size=tbl_size)
    table.cell(dash, 1, 2, strength_label, text_color=strength_color, text_size=tbl_size)

    string mom_label = na(flow_momentum) ? "-" : flow_momentum > 0 ? "Rising" : flow_momentum < 0 ? "Falling" : "Flat"
    table.cell(dash, 0, 3, "Momentum", text_color=color.gray, text_size=tbl_size)
    table.cell(dash, 1, 3, mom_label, text_color=na(flow_momentum) ? color.gray : flow_momentum > 0 ? #00E676 : #FF5252, text_size=tbl_size)

    string rsi_label = na(rsi_val) ? "-" : str.tostring(rsi_val, "#.0")
    color rsi_color = rsi_val > rsi_ob ? #FF5252 : rsi_val < rsi_os ? #00E676 : color.white
    table.cell(dash, 0, 4, "Filter", text_color=color.gray, text_size=tbl_size)
    table.cell(dash, 1, 4, rsi_label, text_color=rsi_color, text_size=tbl_size)

    float directional_breadth = bulls_winning ? bull_breadth : bear_breadth
    string breadth_label = na(directional_breadth) ? "-" : str.tostring(math.round(directional_breadth * 100.0)) + "% " + (bulls_winning ? "bull" : "bear")
    color breadth_color = not na(directional_breadth) and directional_breadth >= min_breadth ? status_color : color.gray
    table.cell(dash, 0, 5, "Breadth", text_color=color.gray, text_size=tbl_size,
         tooltip = "Share of currently active asset weight pointing in the composite direction.")
    table.cell(dash, 1, 5, breadth_label, text_color=breadth_color, text_size=tbl_size)

    string coverage_label = str.tostring(active_legs) + "/5 legs · w " + str.tostring(active_weight, "0.0")
    color coverage_color = active_legs >= 4 ? color.white : active_legs >= 3 ? color.yellow : #FF5252
    table.cell(dash, 0, 6, "Coverage", text_color=color.gray, text_size=tbl_size,
         tooltip = "Only legs with a valid current bar and nonzero configured weight enter the composite denominator.")
    table.cell(dash, 1, 6, coverage_label, text_color=coverage_color, text_size=tbl_size)

    string conf_status = "-"
    color conf_color = color.gray
    if show_bull_confluence or (strong_bull_confluence and bar_index - last_bull_conf_bar < 3)
        conf_status := "Long"
        conf_color := #00E676
    else if show_bear_confluence or (strong_bear_confluence and bar_index - last_bear_conf_bar < 3)
        conf_status := "Short"
        conf_color := #FF5252

    table.cell(dash, 0, 7, "Agreement", text_color=color.gray, text_size=tbl_size)
    table.cell(dash, 1, 7, conf_status, text_color=conf_color, text_size=tbl_size)

    table.cell(dash, 0, 8, "Delta", text_color=color.gray, text_size=tbl_size)
    table.cell(dash, 1, 8, na(delta) ? "-" : str.tostring(delta, "#.00"),
         text_color=na(delta) ? color.gray : delta > 0 ? #00E676 : #FF5252, text_size=tbl_size)

// =============================================================================
// 13. Alerts
// =============================================================================
alertcondition(confirmed_bull_cross, "Confirmed bullish cross", "Composite flow crossed above zero with filter confirmation")
alertcondition(confirmed_bear_cross, "Confirmed bearish cross", "Composite flow crossed below zero with filter confirmation")
alertcondition(show_bear_div, "Bearish divergence", "Price high with weakening composite flow and filter confirmation")
alertcondition(show_bull_div, "Bullish divergence", "Price low with strengthening composite flow and filter confirmation")
alertcondition(show_bull_confluence, "Bullish agreement", "Composite flow and filter aligned to the upside")
alertcondition(show_bear_confluence, "Bearish agreement", "Composite flow and filter aligned to the downside")
alertcondition(strong_bull_flow, "Strong bullish flow", "Composite flow showing strong buying pressure")
alertcondition(strong_bear_flow, "Strong bearish flow", "Composite flow showing strong selling pressure")
````
