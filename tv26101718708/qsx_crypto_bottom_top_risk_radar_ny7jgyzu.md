# QSX Crypto Bottom & Top Risk Radar

- url: https://www.tradingview.com/script/nY7jGyZu/
- type: indicator
- pine_id: PUB;4bb071e70ba843bfb774b7ee40e52ed9
- version: 2.0

## Description

QSX Crypto Bottom & Top Risk Radar

An open-source risk-state radar for crypto. It answers one question: is the crowd at an exhaustion extreme right now — near a washed-out bottom, or a crowded top? It is a market-context tool, not a trading system, and it does not size positions.

HOW IT WORKS

All logic is visible in the source. Three building blocks:

1. Crowd gauge (the core). Binance BTC perpetual Long/Short Ratio (accounts), pulled via TradingView's Request library, ranked as a percentile over the past 365 daily bars. The absolute ratio drifts across market regimes, so the radar always reads it relative to its own trailing year:
- below the 10th percentile — the long crowd is washed out (capitulation pressure, historically a bottoming condition);
- above the 80th percentile — longs are crowded;
- above the 90th percentile — crowding is extreme.

2. Chart context filter. A 0-100 trend/volatility gauge built from the SMA200 trend state (price above/below + slope) blended with a normalized ATR(14) volatility rank over the last 100 bars, smoothed over 5 days. Its 3-day direction decides whether conditions are improving or fading. Top-risk states additionally require ADX(14) >= 20, so the radar stays quiet in directionless chop instead of calling tops in flat markets.

3. States. Crowd extremes and chart context combine into: BOTTOM (crowd washed out, or washed out and already recovering), CALM (no extreme), TOP RISK (crowded longs plus fading trend), and HIGH RISK (extreme crowding plus fading trend and momentum). A marker cooldown collapses each episode into sparse markers so one episode prints one readable signal instead of a cluster.

DASHBOARD

The panel shows a 0-100 crowd-exhaustion score (distance from neutral positioning, direction-aware), the current state, a heat bar, a one-line conclusion, and the raw BTC crowd percentile so you can see how close conditions are to the thresholds before anything fires.

HISTORICAL CASE LABELS

"Bottom-to-high +X%" and "Risk-off case -X% DD" labels annotate what actually followed past radar states, measured to the best/worst extreme reached afterwards. They keep updating while an episode is running, so treat them as retrospective illustrations of past cases — not performance claims, probabilities, or expectations.

HOW TO USE IT

- Daily charts only; the radar checks the timeframe and asks you to switch if needed. States are confirmed at the daily close — set alerts to "Once Per Bar Close".
- The crowd gauge always comes from BTC perp Long/Short accounts, even on an altcoin chart; only the trend/volatility context comes from the chart symbol. Read states as BTC-market-wide conditions.
- Typical use: as a regime filter on top of your own process — e.g. tighten risk when TOP/HIGH RISK is active, and treat BOTTOM states as environments where capitulation is historically present, not as automatic buy signals.

LIMITATIONS

- Long/Short Ratio history starts around 2020 and the percentile needs about a year of warm-up, so states begin printing from roughly 2021.
- Bottom states can appear early in extended downtrends and persist while price keeps falling; crowd exhaustion marks conditions, not exact turning points.
- No position sizing, no portfolio advice, no guarantees. Educational information only, not financial advice. Crypto is volatile — never risk money you cannot afford to lose.

## Source Code

````pine
// Copyright QuantScopeX.
// QSX Crypto Bottom & Top Risk Radar 1.4
// ---------------------------------------------------------------------
// Free TradingView risk-state radar (presentation version).
//
// Purpose:
// - Show crypto crowd-exhaustion risk states on the current chart.
// - Keep the chart clean enough for screenshots and public sharing.
// - Add close-confirmed alerts for both initial capitulation and the existing
//   recovery state, without changing the signal engine.
// - Disclose the TradingView-native Binance BTC perpetual positioning feed.
//   If that feed is unavailable, the script fails closed and emits no signal.
// - Keep the full paid engine (crash / major-top attribution, market
//   scan, why, position integration) separate from this public preview.
//
// This is a risk-state radar, not a standalone trading system.
// It does not provide position sizing or portfolio advice.
// ---------------------------------------------------------------------

//@version=6
indicator("QSX Crypto Bottom & Top Risk Radar 1.4", shorttitle="QSX Bottom/Top Radar", overlay=true, max_labels_count=500)

import TradingView/Request/2 as tvreq

// --------------------------------------------------------------------- Inputs
grp_display = "Display"
show_marks = input.bool(true, "Radar markers", group=grp_display)
show_recovery_mark = input.bool(false, "Recovery confirmation marker", group=grp_display,
     tooltip="Optional small marker when the existing Bottom state first turns into Recovery. It does not change Bottom or Top Risk logic.")
marker_cd = input.int(20, "Marker cooldown", minval=0, maxval=120, group=grp_display,
     tooltip="Collapses each top/bottom risk episode into sparse chart markers.")
show_bg = input.bool(false, "Risk-state background", group=grp_display,
     tooltip="Off by default to keep the chart clean for public screenshots.")
show_dashboard = input.bool(true, "Dashboard", group=grp_display)
show_case_markers = input.bool(false, "Historical case labels", group=grp_display,
     tooltip="Shows what happened after historical radar states. These are historical cases, not promises.")
panel_pos = input.string("top_right", "Dashboard position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grp_display)

// --------------------------------------------------------------------- Constants
QSX_SOURCE = "BINANCE:BTCUSDT.P"
ENGINE_FLOOR = 10.0
ENGINE_CEILING = 80.0
ENGINE_EXTREME = 90.0
ENGINE_TURN_WINDOW = 3
ENGINE_MEMORY = 365
QUIET_MODE_FILTER = true
QUIET_MODE_THRESHOLD = 20.0
ENGINE_FILTER_LEN = 14

TREND_LEN = 200
VOL_LEN = 14
VOL_RANK_LEN = 100
SMOOTH_LEN = 5

W_TREND = 0.4117647058823529 / (0.4117647058823529 + 0.23529411764705885)
W_VOL = 1.0 - W_TREND
THEO = W_TREND * 1.0 + W_VOL * 0.5

COL_GREEN = #22c55e
COL_GREEN_D = #15803d
COL_AMBER = #f59e0b
COL_RED = #ef4444
COL_RED_D = #991b1b
COL_DIM = #a1a1aa
COL_MUTED = #71717a
COL_TEXT = #e4e4e7
COL_WARN = #f97316
COL_CYAN = #38bdf8
COL_PANEL = #050505
COL_PANEL_2 = #111827
COL_TRACK = #27272a

CASE_RALLY_THRESHOLD = 18.0
CASE_DROP_THRESHOLD = 18.0

is_daily = timeframe.isdaily and timeframe.multiplier == 1

// --------------------------------------------------------------------- Helpers
f_pos(_p) =>
    switch _p
        "top_left" => position.top_left
        "bottom_right" => position.bottom_right
        "bottom_left" => position.bottom_left
        "middle_right" => position.middle_right
        => position.top_right

f_clamp(_x, _lo, _hi) =>
    math.max(_lo, math.min(_hi, _x))

// --------------------------------------------------------------------- Chart trend/weather
f_trend_score() =>
    _ma = ta.sma(close, TREND_LEN)
    _above = (not na(_ma) and close > _ma) ? 0.5 : -0.5
    _slope = (not na(_ma) and not na(_ma[1]) and _ma > _ma[1]) ? 0.5 : -0.5
    _above + _slope

f_lite100() =>
    _trend = f_trend_score()
    _tr = math.max(high - low, math.max(math.abs(high - close[1]), math.abs(low - close[1])))
    _atr = ta.sma(_tr, VOL_LEN)
    _nv = _atr / close
    _nh = ta.highest(_nv, VOL_RANK_LEN)
    _nl = ta.lowest(_nv, VOL_RANK_LEN)
    _spread = _nh - _nl
    _vol_pct = (na(_nv) or na(_nh) or na(_nl)) ? na : (_spread == 0.0 ? 0.5 : (_nv - _nl) / _spread)
    _vol_score = _vol_pct > 0.7 ? -0.5 : _vol_pct < 0.3 ? 0.5 : 0.0
    _smooth = ta.sma(W_TREND * _trend + W_VOL * _vol_score, SMOOTH_LEN)
    f_clamp(50.0 + (_smooth / THEO) * 45.0, 0.0, 100.0)

lite = f_lite100()
ma_weather = ta.sma(f_trend_score(), SMOOTH_LEN)

trend_down = not na(lite) and not na(lite[ENGINE_TURN_WINDOW]) and lite < lite[ENGINE_TURN_WINDOW]
ma_down = not na(ma_weather) and not na(ma_weather[ENGINE_TURN_WINDOW]) and ma_weather < ma_weather[ENGINE_TURN_WINDOW]
trend_up = not na(lite) and not na(lite[ENGINE_TURN_WINDOW]) and lite > lite[ENGINE_TURN_WINDOW]

[_di_plus, _di_minus, chart_adx] = ta.dmi(ENGINE_FILTER_LEN, ENGINE_FILTER_LEN)
top_env = (not QUIET_MODE_FILTER) or (not na(chart_adx) and chart_adx >= QUIET_MODE_THRESHOLD)

// --------------------------------------------------------------------- Preview signal core
// Pine cannot call the maintained Coinglass feed used by the website radar.
// The public script therefore uses TradingView's native metric only and fails
// closed rather than silently substituting a different source.
btc_lsr = tvreq.cryptoDerivativeMetric(QSX_SOURCE, "Long/Short Ratio Accounts", "1D")
lsr_pct = ta.percentrank(btc_lsr, ENGINE_MEMORY)
lsr_metric_available = not na(btc_lsr)
lsr_ok = not na(lsr_pct)
active = is_daily and lsr_ok

capitulation_raw = lsr_ok and lsr_pct < ENGINE_FLOOR
retail_crowded = lsr_ok and lsr_pct > ENGINE_CEILING
retail_extreme = lsr_ok and lsr_pct > ENGINE_EXTREME

// --------------------------------------------------------------------- States
recovery_now = active and capitulation_raw and trend_up
capitulation_now = active and capitulation_raw and not trend_up
high_risk_now = active and top_env and trend_down and ma_down and retail_extreme
top_risk_now = active and top_env and trend_down and retail_crowded and not high_risk_now

//  2 = recovery, 1 = bottom pressure, 0 = neutral, -1 = top risk, -2 = high risk
radar_state = high_risk_now ? -2 : top_risk_now ? -1 : recovery_now ? 2 : capitulation_now ? 1 : 0

// Public signal surface: only two marker families.
bottom_side = active and capitulation_raw
top_side = active and top_env and trend_down and retail_crowded

var int last_bottom_bar = na
var int last_top_bar = na

fire_bottom = bottom_side and (na(last_bottom_bar) or bar_index - last_bottom_bar > marker_cd)
fire_top = top_side and (na(last_top_bar) or bar_index - last_top_bar > marker_cd)

if bottom_side
    last_bottom_bar := bar_index
if top_side
    last_top_bar := bar_index

// Do not emit realtime alerts before the daily candle is confirmed. Historical
// bars are confirmed, so this does not alter the visible historical markers.
fire_bottom_close = fire_bottom and barstate.isconfirmed
fire_top_close = fire_top and barstate.isconfirmed
recovery_started = recovery_now and not recovery_now[1]
fire_recovery_close = recovery_started and barstate.isconfirmed

// --------------------------------------------------------------------- Text / dashboard values
state_txt =
     not is_daily ? "1D REQUIRED" :
     not lsr_ok ? "SIGNAL OFFLINE" :
     radar_state == 2 ? "BOTTOM" :
     radar_state == 1 ? "BOTTOM" :
     radar_state == -2 ? "HIGH RISK" :
     radar_state == -1 ? "TOP RISK" :
     "CALM"

state_col =
     (not is_daily or not lsr_ok) ? COL_WARN :
     radar_state == 2 ? COL_GREEN :
     radar_state == 1 ? COL_GREEN_D :
     radar_state == -2 ? COL_RED :
     radar_state == -1 ? COL_AMBER :
     COL_MUTED

title_txt =
     not is_daily ? "SWITCH TO 1D" :
     not lsr_ok ? "NO SIGNAL FEED" :
     radar_state == 2 ? "RECOVERY" :
     radar_state == 1 ? "BOTTOM" :
     radar_state == -2 ? "HIGH RISK" :
     radar_state == -1 ? "TOP RISK" :
     "CALM"

verdict_txt =
     not is_daily ? "Conclusion: switch this chart to daily." :
     not lsr_ok ? "Conclusion: BTC L/S feed is unavailable." :
     radar_state == 2 ? "Bottom pressure easing." :
     radar_state == 1 ? "Crowd washed out." :
     radar_state == -2 ? "Extreme top risk." :
     radar_state == -1 ? "Crowded longs fading." :
     "No top/bottom extreme."

heat_txt =
     not lsr_ok ? "No feed" :
     lsr_pct < ENGINE_FLOOR ? "Washed out" :
     lsr_pct > ENGINE_EXTREME ? "Extreme long" :
     lsr_pct > ENGINE_CEILING ? "Crowded long" :
     "Normal"

trend_txt = trend_up ? "Improving" : trend_down ? "Fading" : "Stable"
trend_detail_txt = trend_txt + " | ADX " + (na(chart_adx) ? "n/a" : str.tostring(math.round(chart_adx)))

feed_txt = lsr_metric_available ? "Feed: TV Binance BTC perp L/S accounts" : "Feed: unavailable"
data_status_txt =
     lsr_ok ? "TV feed ready" :
     lsr_metric_available ? "365D rank warming up" : "Signal paused: no L/S feed"

exhaustion_score =
     not lsr_ok ? na :
     capitulation_raw ? 100.0 - lsr_pct :
     retail_crowded ? lsr_pct :
     math.abs(lsr_pct - 50.0) * 2.0
exhaustion_score := f_clamp(exhaustion_score, 0.0, 100.0)

score_txt = not is_daily ? "--" : not lsr_ok ? "n/a" : str.tostring(math.round(exhaustion_score)) + "/100"
active_segments = int(f_clamp(math.ceil(nz(exhaustion_score, 0.0) / 10.0), 0.0, 10.0))

// --------------------------------------------------------------------- Visuals
bg_col =
     radar_state == 2 ? color.new(COL_GREEN, 88) :
     radar_state == 1 ? color.new(COL_GREEN_D, 91) :
     radar_state == -1 ? color.new(COL_AMBER, 90) :
     radar_state == -2 ? color.new(COL_RED, 88) :
     na
bgcolor(show_bg ? bg_col : na, title="Risk-state background")

plotshape(show_marks and fire_bottom_close, title="BOTTOM", style=shape.triangleup, location=location.belowbar,
     color=color.new(COL_GREEN, 0), textcolor=color.white, size=size.normal, text="BOTTOM")
plotshape(show_marks and fire_top_close, title="TOP RISK", style=shape.triangledown, location=location.abovebar,
     color=color.new(COL_AMBER, 0), textcolor=color.black, size=size.small, text="RISK")
plotshape(show_marks and show_recovery_mark and fire_recovery_close, title="RECOVERY CONFIRMED", style=shape.diamond, location=location.belowbar,
     color=color.new(COL_CYAN, 0), textcolor=color.black, size=size.tiny, text="REC")

plot(radar_state, title="QSX radar state", display=display.none)
plot(lsr_pct, title="QSX retail pulse", display=display.none)
plot(lite, title="QSX turn pulse", display=display.none)
plot(chart_adx, title="QSX mode pulse", display=display.none)

// Historical case labels. These are visual proof-points for the public
// chart, not probability estimates or position advice.
var bool tracking_bottom_case = false
var float bottom_case_entry = na
var float bottom_case_high = na
var float bottom_case_best_rally = na
var label bottom_case_label = na

var bool tracking_top_case = false
var float top_case_entry = na
var float top_case_low = na
var float top_case_worst_drop = na
var label top_case_label = na

if show_case_markers and fire_bottom
    tracking_bottom_case := true
    bottom_case_entry := close
    bottom_case_high := high
    bottom_case_best_rally := 0.0
    bottom_case_label := na

if show_case_markers and fire_top
    tracking_top_case := true
    top_case_entry := close
    top_case_low := low
    top_case_worst_drop := 0.0
    top_case_label := na

if tracking_bottom_case
    _new_high = na(bottom_case_high) or high > bottom_case_high
    bottom_case_high := math.max(nz(bottom_case_high, high), high)
    bottom_case_best_rally := bottom_case_entry > 0.0 ? (bottom_case_high / bottom_case_entry - 1.0) * 100.0 : na
    _case_ready = _new_high and not na(bottom_case_best_rally) and bottom_case_best_rally >= CASE_RALLY_THRESHOLD
    if _case_ready
        _txt = "Bottom-to-high +" + str.tostring(math.round(bottom_case_best_rally)) + "%"
        if na(bottom_case_label)
            bottom_case_label := label.new(bar_index, high, _txt, yloc=yloc.abovebar, style=label.style_label_down, color=color.new(COL_GREEN, 0), textcolor=color.white, size=size.small)
        else
            label.set_x(bottom_case_label, bar_index)
            label.set_y(bottom_case_label, high)
            label.set_text(bottom_case_label, _txt)
    if fire_top
        tracking_bottom_case := false

if tracking_top_case
    _new_low = na(top_case_low) or low < top_case_low
    top_case_low := math.min(nz(top_case_low, low), low)
    top_case_worst_drop := top_case_entry > 0.0 ? (top_case_low / top_case_entry - 1.0) * 100.0 : na
    _case_ready = _new_low and not na(top_case_worst_drop) and top_case_worst_drop <= -CASE_DROP_THRESHOLD
    if _case_ready
        _txt = "Risk-off case " + str.tostring(math.round(top_case_worst_drop)) + "% DD"
        if na(top_case_label)
            top_case_label := label.new(bar_index, low, _txt, yloc=yloc.belowbar, style=label.style_label_up, color=color.new(COL_RED, 0), textcolor=color.white, size=size.small)
        else
            label.set_x(top_case_label, bar_index)
            label.set_y(top_case_label, low)
            label.set_text(top_case_label, _txt)
    if fire_bottom
        tracking_top_case := false

// --------------------------------------------------------------------- Dashboard
var table panel = na
if show_dashboard and na(panel)
    panel := table.new(f_pos(panel_pos), 10, 7, border_width=0, frame_width=1, frame_color=color.new(COL_MUTED, 70))
    table.merge_cells(panel, 0, 0, 9, 0)
    table.merge_cells(panel, 0, 1, 3, 1)
    table.merge_cells(panel, 4, 1, 9, 1)
    table.merge_cells(panel, 0, 3, 9, 3)
    table.merge_cells(panel, 0, 4, 9, 4)
    table.merge_cells(panel, 0, 5, 9, 5)
    table.merge_cells(panel, 0, 6, 9, 6)

if show_dashboard and barstate.islast
    table.cell(panel, 0, 0, "QSX CROWD EXHAUSTION RADAR", text_color=COL_TEXT, text_size=size.small, bgcolor=COL_PANEL_2, text_halign=text.align_left)
    table.cell(panel, 0, 1, score_txt, text_color=color.white, text_size=size.huge, bgcolor=COL_PANEL, text_halign=text.align_center)
    table.cell(panel, 4, 1, title_txt, text_color=state_col, text_size=size.large, bgcolor=COL_PANEL, text_halign=text.align_center)

    for i = 0 to 9
        seg_on = i < active_segments
        seg_color =
             radar_state > 0 ? COL_GREEN :
             radar_state == -2 ? (i < 7 ? COL_AMBER : COL_RED) :
             radar_state == -1 ? (i < 8 ? COL_AMBER : COL_RED) :
             i < 5 ? COL_GREEN : i < 8 ? COL_AMBER : COL_RED
        table.cell(panel, i, 2, "", bgcolor=seg_on ? seg_color : COL_TRACK)

    table.cell(panel, 0, 3, verdict_txt, text_color=COL_TEXT, text_size=size.normal, bgcolor=COL_PANEL_2, text_halign=text.align_center)
    table.cell(panel, 0, 4, "BTC crowd: " + (lsr_ok ? str.tostring(math.round(lsr_pct)) + " / 100" : "n/a") + " | " + heat_txt, text_color=COL_CYAN, text_size=size.small, bgcolor=COL_PANEL_2, text_halign=text.align_center)
    table.cell(panel, 0, 5, "Chart: " + trend_detail_txt + " | 1D close only", text_color=COL_DIM, text_size=size.tiny, bgcolor=COL_PANEL, text_halign=text.align_center)
    table.cell(panel, 0, 6, feed_txt + " | " + data_status_txt, text_color=COL_CYAN, text_size=size.tiny, bgcolor=COL_PANEL_2, text_halign=text.align_center)

if not show_dashboard and not na(panel)
    table.delete(panel)
    panel := na

// --------------------------------------------------------------------- Warnings
var label tf_warn = na
if not is_daily and barstate.islast
    if na(tf_warn)
        tf_warn := label.new(bar_index, high, "QSX Bottom/Top Radar: switch to 1D", yloc=yloc.abovebar, style=label.style_label_down,
             color=color.new(COL_WARN, 0), textcolor=color.white, size=size.small)
    else
        label.set_x(tf_warn, bar_index)
        label.set_y(tf_warn, high)
else if is_daily and not na(tf_warn)
    label.delete(tf_warn)
    tf_warn := na

// --------------------------------------------------------------------- Alerts
alertcondition(fire_bottom_close, title="QSX BOTTOM", message="QSX Crypto Bottom & Top Risk Radar: confirmed BOTTOM state on {{ticker}} daily close.")
alertcondition(fire_recovery_close, title="QSX RECOVERY CONFIRMED", message="QSX Crypto Bottom & Top Risk Radar: confirmed RECOVERY state on {{ticker}} daily close.")
alertcondition(fire_top_close, title="QSX TOP RISK", message="QSX Crypto Bottom & Top Risk Radar: confirmed TOP RISK state on {{ticker}} daily close.")
alertcondition(fire_bottom_close or fire_recovery_close or fire_top_close, title="QSX Bottom/Top Radar state update", message="QSX Crypto Bottom & Top Risk Radar: confirmed state update on {{ticker}} daily close.")
````
