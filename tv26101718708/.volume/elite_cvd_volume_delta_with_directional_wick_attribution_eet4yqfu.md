# Elite CVD: volume delta with directional wick attribution

- url: https://www.tradingview.com/script/eET4Yqfu-Elite-CVD-volume-delta-with-directional-wick-attribution/
- type: indicator
- pine_id: PUB;8b8e5b0d4f234235b524797f3b7fa3c4
- version: 2.0

## Description

A cumulative volume delta that attributes wick volume directionally instead of splitting every bar down the middle, with all three proxy models exposed so you can compare them yourself.

[b]What it does[/b]

Volume delta estimates how much of a bar's volume was buyer-initiated versus seller-initiated, then accumulates the difference into a running total. When that total rises while price stalls, buyers are absorbing supply. When it falls while price grinds higher, the advance is not being paid for. This plots that total, colours each bar's contribution by whether the pressure is building or fading, marks unusually heavy volume, and flags divergences between the total and price.

[b]What is different here[/b]

Cumulative volume delta is a public idea with many open-source implementations on this platform, and I claim no ownership of it. What differs is how the volume gets attributed.

Almost every delta proxy splits a bar by where the close sits within the range. That treats both wicks as neutral, which is a choice, and usually an unexamined one. It says the volume in a long lower wick carries the same meaning as volume in a long upper wick.

This one reads wicks directionally. On an up bar, the lower wick is treated as selling that buyers absorbed and overcame, so most of that volume is credited to buyers, while the upper wick is treated as rejection and mostly credited to sellers. On a down bar the reading inverts. The split is 75/25 rather than 50/50, and the body always goes to the direction the bar closed.

Whether that assumption is better than the neutral one is something you should decide rather than take on faith, so the classic model, the directional model, and an average of the two are all selectable from one dropdown. Switch between them on your own instrument and see whether the difference matters. If it does not, use the classic one.

[b]How the parts work together[/b]

Four components share one job, which is why they sit in one script rather than four.

The delta engine produces the per-bar reading. The relative-volume layer scales that reading by how heavy the bar was against its own recent average, using a square root so a four-times-volume bar counts double rather than quadruple. That matters because a large delta on thin volume is noise and a moderate delta on heavy volume is participation, and an unweighted total treats them as equal.

The acceleration colouring compares each bar's delta to its own reading a few bars back and dims the histogram when pressure is fading. Pressure that is still positive but decelerating is the condition that precedes most reversals in this kind of data, and a plain two-colour histogram hides it entirely.

The divergence layer compares confirmed price pivots against the delta total at those same bars. Divergences are confirmed rather than live: they appear only once the pivot's right-hand bars have elapsed, so they will always print a few bars after the turn.

[b]How to use it[/b]

Built for intraday work on futures, and it functions on any symbol that reports volume.

Start with the reset mode. Session reset gives you the day's accumulated pressure and is the right default for intraday trading. Fixed length gives a rolling window. Running never resets and is only useful over short chart histories.

Read the relationship rather than the level. The absolute number means little on its own, since it depends on how long the total has been accumulating. What carries information is the direction of the total relative to price, whether it sits above or below its signal line, and whether the per-bar contribution is brightening or dimming.

The table reports the current bar's buy and sell split, the bar delta with an acceleration marker, the running total and which reset mode produced it, the signal-line relationship, relative volume, and raw volume.

[b]What it cannot do[/b]

This is a proxy and not real order flow. It infers the aggressor side from the shape of the bar. It has no access to bid and ask data, no tick data, and no exchange-reported delta. On any instrument where true delta is available to you, the true delta is better and you should use that instead.

The directional wick reading is an assumption about intent, not a measurement. It is defensible and it is still an assumption, which is why the neutral model remains available.

With relative-volume weighting switched on, the running total is no longer in contracts or shares, because each bar is scaled before being added. The shape of the line stays comparable across time; the units do not. Turn the weighting off if you need the axis to be literal.

The session reset follows the exchange's own daily session, so on futures it resets at the futures open rather than the equity open. That is correct for a futures instrument and worth knowing if you apply the script elsewhere.

Divergences are confirmed, which means late by design. They describe a turn that has already formed. They are not predictions and no claim is made about how often they resolve favourably.

[b]On authorship[/b]

Cumulative volume delta, relative volume and pivot divergence are all public methodology and I have said so plainly. The implementation is not borrowed. Every line is written from scratch and no code in it is copied or adapted from another author's script, on this platform or anywhere else.

[b]Settings[/b]

Proxy model selection; reset mode with a fixed-length option, signal line length and type; display mode for line, histogram or both, acceleration colouring and its lookback, and the zero fill; relative-volume weighting with its average length, type and spike threshold; divergence toggle with pivot left and right bars; and table position, size and colours.

## Source Code

````pine
//@version=6
// =============================================================================
// Elite CVD
//
// A candle-structure volume-delta proxy with reset-aware accumulation,
// relative-volume context, and confirmed price/CVD divergence.
//
// Honest limitations
// - This is not bid/ask delta. It infers participation from OHLCV bars.
// - Directional wick attribution is a model of bar structure, not a record of
//   aggressor-side executions.
// - RVOL weighting intentionally changes the units from contracts/shares to a
//   weighted quantity. Disable it when literal volume units are required.
// - Confirmed divergence arrives after the selected right-pivot bars. It never
//   uses a future value early and it is not a prediction.
// - Missing volume contributes zero and is disclosed in the dashboard; it can
//   no longer poison the cumulative series with na.
// - On daily and higher charts, Session reset restarts on every bar, so CVD
//   equals the bar's own delta. Use Rolling Window or None there.
// =============================================================================

indicator("Elite CVD: directional wick volume delta", "Elite CVD",
     format = format.volume, overlay = false)

// =============================================================================
// INPUTS
// =============================================================================
string GRP_PROXY = "Volume Proxy"
string PROXY_CTX = "Context-Aware (Recommended)"
string PROXY_BLD = "Blended (Context + Close Location)"
string PROXY_HL = "Classic Close Location"
string proxy_method = input.string(PROXY_CTX, "Proxy Method",
     options = [PROXY_CTX, PROXY_BLD, PROXY_HL], group = GRP_PROXY)
float wick_bias = input.float(0.75, "Directional Wick Attribution", minval = 0.50,
     maxval = 1.00, step = 0.05, group = GRP_PROXY,
     tooltip = "On a directional candle, this share of the supportive wick is credited to the winning side and the same share of the rejection wick to the opposing side.")

string GRP_CVD = "CVD Engine"
string RST_SESSION = "Session"
string RST_BLOCK = "Fixed Blocks"
string RST_ROLL = "Rolling Window"
string RST_NONE = "None (Running)"
string cvd_reset = input.string(RST_SESSION, "Reset Mode",
     options = [RST_SESSION, RST_BLOCK, RST_ROLL, RST_NONE], group = GRP_CVD,
     tooltip = "Fixed Blocks truly resets every N bars. Rolling Window is a moving N-bar sum; these are deliberately separate semantics.")
int cvd_length = input.int(50, "Block / Rolling Length", minval = 5, maxval = 2000, group = GRP_CVD)
string SESSION_EXCHANGE = "Exchange Day"
string SESSION_CUSTOM = "Custom Session"
string session_basis = input.string(SESSION_EXCHANGE, "Session Reset Basis",
     options = [SESSION_EXCHANGE, SESSION_CUSTOM], group = GRP_CVD)
string custom_session = input.session("0930-1600", "Custom Session", group = GRP_CVD)
string custom_timezone = input.string("America/New_York", "Custom Time Zone", group = GRP_CVD,
     tooltip = "Use an IANA zone such as America/New_York so daylight-saving changes are handled.")
bool custom_only = input.bool(false, "Accumulate Custom Session Only", group = GRP_CVD,
     tooltip = "Only applies when Session Reset Basis is Custom Session. Outside-session bars contribute zero.")
bool show_cvd_ma = input.bool(true, "Show Signal Line", group = GRP_CVD)
int cvd_ma_len = input.int(8, "Signal Length", minval = 2, maxval = 500, group = GRP_CVD)
string cvd_ma_type = input.string("EMA", "Signal Type", options = ["EMA", "SMA", "WMA"], group = GRP_CVD)

string GRP_VOL = "Volume Context"
bool weight_rvol = input.bool(true, "RVOL-Weight Delta", group = GRP_VOL,
     tooltip = "Uses sqrt(RVOL), capped at the selected ceiling. Disable for literal volume units.")
int rvol_avg_len = input.int(20, "RVOL Baseline Length", minval = 5, maxval = 500, group = GRP_VOL)
string rvol_avg_type = input.string("EMA", "RVOL Baseline Type",
     options = ["EMA", "SMA", "RMA"], group = GRP_VOL)
float rvol_cap = input.float(6.0, "RVOL Weighting Cap", minval = 1.0, maxval = 50.0,
     step = 0.5, group = GRP_VOL,
     tooltip = "Caps only the weighting multiplier, protecting the engine from bad volume prints. Displayed RVOL remains uncapped.")
float rvol_spike_th = input.float(2.0, "RVOL Spike Threshold", minval = 1.1,
     maxval = 20.0, step = 0.1, group = GRP_VOL)
bool show_rvol_dots = input.bool(true, "Show RVOL Spike Dots", group = GRP_VOL)

string GRP_DIV = "Confirmed Divergence"
bool show_div = input.bool(true, "Show Divergences", group = GRP_DIV)
int div_pivot_lb = input.int(5, "Pivot Left Bars", minval = 2, maxval = 50, group = GRP_DIV)
int div_pivot_rb = input.int(2, "Pivot Right Bars", minval = 1, maxval = 20, group = GRP_DIV)
int div_max_gap = input.int(100, "Maximum Bars Between Pivots", minval = 5, maxval = 1000, group = GRP_DIV)
int div_scale_len = input.int(20, "Delta Scale Length", minval = 5, maxval = 200, group = GRP_DIV)
float div_min_strength = input.float(0.25, "Minimum CVD Separation (x Avg Delta)", minval = 0.0,
     maxval = 10.0, step = 0.05, group = GRP_DIV,
     tooltip = "Rejects cosmetic divergences where the two CVD pivot readings are nearly identical.")

string GRP_DISP = "Display"
string DISP_CVD = "CVD Line Only"
string DISP_HIST = "Histogram Only"
string DISP_BOTH = "Both"
string display_mode = input.string(DISP_CVD, "Display Mode",
     options = [DISP_CVD, DISP_HIST, DISP_BOTH], group = GRP_DISP)
bool show_roc = input.bool(true, "Delta Acceleration Coloring", group = GRP_DISP)
int roc_len = input.int(3, "Acceleration Lookback", minval = 1, maxval = 50, group = GRP_DISP)
bool show_fill = input.bool(true, "CVD Zero Fill", group = GRP_DISP)
bool show_table = input.bool(true, "Show Dashboard", group = GRP_DISP)
string table_position = input.string(position.top_right, "Dashboard Position",
     options = [position.top_right, position.top_left, position.bottom_right, position.bottom_left], group = GRP_DISP)
string table_size = input.string(size.small, "Dashboard Size",
     options = [size.tiny, size.small, size.normal], group = GRP_DISP)

string GRP_COLOR = "Colors"
color col_bull = input.color(#00e676, "Bull", inline = "c", group = GRP_COLOR)
color col_bear = input.color(#ff1744, "Bear", inline = "c", group = GRP_COLOR)
color col_signal = input.color(#ffa726, "Signal", group = GRP_COLOR)

// =============================================================================
// CONSERVATIVE VOLUME ATTRIBUTION
// =============================================================================
bool volume_ok = not na(volume) and volume >= 0
float safe_volume = volume_ok ? volume : 0.0
float spread = high - low
bool range_ok = not na(spread) and spread > 0

float close_location = range_ok ? math.min(math.max((close - low) / spread, 0.0), 1.0) : 0.5
float hl_buy = safe_volume * close_location
float hl_sell = safe_volume - hl_buy

int candle_dir = close > open ? 1 : close < open ? -1 : close > nz(close[1], close) ? 1 :
     close < nz(close[1], close) ? -1 : 0
float body = math.abs(close - open)
float upper_wick = math.max(high - math.max(open, close), 0.0)
float lower_wick = math.max(math.min(open, close) - low, 0.0)

float ctx_buy = safe_volume * 0.5
float ctx_sell = safe_volume * 0.5

if range_ok and candle_dir != 0
    float body_pct = body / spread
    float upper_pct = upper_wick / spread
    float lower_pct = lower_wick / spread
    if candle_dir == 1
        ctx_buy := (body_pct + lower_pct * wick_bias + upper_pct * (1.0 - wick_bias)) * safe_volume
        ctx_sell := safe_volume - ctx_buy
    else
        ctx_sell := (body_pct + upper_pct * wick_bias + lower_pct * (1.0 - wick_bias)) * safe_volume
        ctx_buy := safe_volume - ctx_sell

float blended_buy = (hl_buy + ctx_buy) * 0.5
float blended_sell = safe_volume - blended_buy

float buy_volume = switch proxy_method
    PROXY_CTX => ctx_buy
    PROXY_BLD => blended_buy
    => hl_buy

float sell_volume = switch proxy_method
    PROXY_CTX => ctx_sell
    PROXY_BLD => blended_sell
    => hl_sell

// All stateful averages execute on every bar; the selector only chooses which
// completed series to read. The current bar is then excluded from its own
// baseline, so a spike cannot inflate the denominator used to judge itself.
float volume_ema = ta.ema(safe_volume, rvol_avg_len)
float volume_sma = ta.sma(safe_volume, rvol_avg_len)
float volume_rma = ta.rma(safe_volume, rvol_avg_len)
float vol_average_now = switch rvol_avg_type
    "EMA" => volume_ema
    "SMA" => volume_sma
    => volume_rma

float vol_baseline = vol_average_now[1]
float rvol = volume_ok and not na(vol_baseline) and vol_baseline > 0 ? safe_volume / vol_baseline : na
float capped_rvol = math.min(math.max(nz(rvol, 1.0), 0.1), rvol_cap)
float rvol_weight = weight_rvol ? math.sqrt(capped_rvol) : 1.0
bool is_spike = not na(rvol) and rvol >= rvol_spike_th

float raw_delta = volume_ok ? buy_volume - sell_volume : 0.0
float weighted_delta = raw_delta * rvol_weight

// =============================================================================
// SESSION INCLUSION AND RESET CLOCK
// =============================================================================
bool in_custom_session = not na(time(timeframe.period, custom_session, custom_timezone))
bool custom_session_start = in_custom_session and (barstate.isfirst or not in_custom_session[1])
bool exchange_session_start = timeframe.change("D")
bool selected_session_start = session_basis == SESSION_EXCHANGE ? exchange_session_start : custom_session_start
bool restrict_to_custom = session_basis == SESSION_CUSTOM and custom_only
bool include_bar = not restrict_to_custom or in_custom_session
float bar_delta = include_bar ? weighted_delta : 0.0

// Fixed Blocks and Rolling Window are separate engines. The former resets a
// cumulative ledger; the latter uses a constant-time ring buffer.
var int block_bars = 0
bool fixed_block_reset = false
if cvd_reset == RST_BLOCK
    if barstate.isfirst or block_bars >= cvd_length
        fixed_block_reset := true
        block_bars := 1
    else
        block_bars += 1
else
    block_bars := 0

bool reset_now = barstate.isfirst or (cvd_reset == RST_SESSION and selected_session_start) or
     (cvd_reset == RST_BLOCK and fixed_block_reset)

var array<float> rolling_buffer = array.new_float()
var float rolling_sum = 0.0
var int rolling_index = 0
var float cvd = 0.0

if cvd_reset == RST_ROLL
    if array.size(rolling_buffer) < cvd_length
        array.push(rolling_buffer, bar_delta)
        rolling_sum += bar_delta
    else
        float oldest_delta = array.get(rolling_buffer, rolling_index)
        rolling_sum += bar_delta - oldest_delta
        array.set(rolling_buffer, rolling_index, bar_delta)
        rolling_index := (rolling_index + 1) % cvd_length
    cvd := rolling_sum
else
    if reset_now
        cvd := bar_delta
    else
        cvd += bar_delta

var int reset_epoch = 0
var int bars_in_epoch = 0
if reset_now
    reset_epoch += 1
    bars_in_epoch := 1
else
    bars_in_epoch += 1

// EMA restarts exactly with the cumulative engine. SMA/WMA are hidden until
// their complete window belongs to the new epoch, eliminating prior-session
// bleed from the displayed signal.
float ema_alpha = 2.0 / (cvd_ma_len + 1.0)
var float reset_ema = na
if reset_now or na(reset_ema)
    reset_ema := cvd
else
    reset_ema += ema_alpha * (cvd - reset_ema)

bool finite_epoch = cvd_reset == RST_SESSION or cvd_reset == RST_BLOCK
bool linear_ma_ready = not finite_epoch or bars_in_epoch >= cvd_ma_len
float cvd_sma = ta.sma(cvd, cvd_ma_len)
float cvd_wma = ta.wma(cvd, cvd_ma_len)
float cvd_signal = switch cvd_ma_type
    "EMA" => reset_ema
    "SMA" => linear_ma_ready ? cvd_sma : na
    => linear_ma_ready ? cvd_wma : na

float delta_change = bar_delta - nz(bar_delta[roc_len])
bool delta_accel = (bar_delta > 0 and delta_change > 0) or (bar_delta < 0 and delta_change < 0)
float delta_scale = ta.ema(math.abs(bar_delta), div_scale_len)

// =============================================================================
// CONFIRMED, EPOCH-SAFE DIVERGENCE
// =============================================================================
float price_pivot_high = ta.pivothigh(high, div_pivot_lb, div_pivot_rb)
float price_pivot_low = ta.pivotlow(low, div_pivot_lb, div_pivot_rb)
float cvd_at_pivot = cvd[div_pivot_rb]
int epoch_at_pivot = reset_epoch[div_pivot_rb]
int pivot_bar = bar_index - div_pivot_rb
float scale_at_pivot = math.max(nz(delta_scale[div_pivot_rb]), 0.0000000001)
bool pivot_included = not restrict_to_custom or in_custom_session[div_pivot_rb]

var float last_price_high = na
var float last_price_low = na
var float last_cvd_high = na
var float last_cvd_low = na
var int last_high_epoch = -1
var int last_low_epoch = -1
var int last_high_bar = -1
var int last_low_bar = -1

bool bear_div = false
bool bull_div = false

if barstate.isconfirmed and pivot_included and not na(price_pivot_high) and not na(cvd_at_pivot)
    bool comparable_high = not na(last_price_high) and not na(last_cvd_high) and
         epoch_at_pivot == last_high_epoch and pivot_bar > last_high_bar and
         pivot_bar - last_high_bar <= div_max_gap
    bool strong_high = comparable_high and last_cvd_high - cvd_at_pivot >= div_min_strength * scale_at_pivot
    bear_div := comparable_high and strong_high and price_pivot_high > last_price_high and cvd_at_pivot < last_cvd_high
    last_price_high := price_pivot_high
    last_cvd_high := cvd_at_pivot
    last_high_epoch := epoch_at_pivot
    last_high_bar := pivot_bar

if barstate.isconfirmed and pivot_included and not na(price_pivot_low) and not na(cvd_at_pivot)
    bool comparable_low = not na(last_price_low) and not na(last_cvd_low) and
         epoch_at_pivot == last_low_epoch and pivot_bar > last_low_bar and
         pivot_bar - last_low_bar <= div_max_gap
    bool strong_low = comparable_low and cvd_at_pivot - last_cvd_low >= div_min_strength * scale_at_pivot
    bull_div := comparable_low and strong_low and price_pivot_low < last_price_low and cvd_at_pivot > last_cvd_low
    last_price_low := price_pivot_low
    last_cvd_low := cvd_at_pivot
    last_low_epoch := epoch_at_pivot
    last_low_bar := pivot_bar

// =============================================================================
// PLOTS
// =============================================================================
bool draw_hist = display_mode == DISP_HIST or display_mode == DISP_BOTH
bool draw_cvd = display_mode == DISP_CVD or display_mode == DISP_BOTH
// Transparency is additive across the two conditions so the acceleration fade
// survives Both mode: fading bars stay visibly dimmer than accelerating ones
// whether or not the CVD line is drawn over the histogram.
int hist_transp = (show_roc and not delta_accel ? 55 : 0) + (draw_cvd and draw_hist ? 35 : 0)
color hist_draw_color = color.new(bar_delta >= 0 ? col_bull : col_bear, math.min(hist_transp, 88))

plot(draw_hist ? bar_delta : na, "Bar Delta", color = hist_draw_color, style = plot.style_columns)
plot(draw_cvd ? cvd : na, "CVD", color = cvd >= 0 ? col_bull : col_bear, linewidth = 3)
plot(draw_cvd and show_cvd_ma ? cvd_signal : na, "Signal", color = color.new(col_signal, 15), linewidth = 2)
hline(0, "Zero", color = color.new(#546e7a, 50))

p_cvd = plot(draw_cvd and show_fill ? cvd : na, "CVD Fill Source", color = color(na),
     display = display.none, editable = false)
p_zero = plot(draw_cvd and show_fill ? 0.0 : na, "Zero Fill Source", color = color(na),
     display = display.none, editable = false)
fill(p_cvd, p_zero, color = cvd >= 0 ? color.new(col_bull, 92) : color.new(col_bear, 92),
     title = "CVD Zone")

plotshape(series = draw_cvd and show_rvol_dots and include_bar and is_spike ? cvd : na,
     title = "RVOL Spike", style = shape.diamond, location = location.absolute,
     color = color.white, size = size.tiny)
plotshape(series = show_div and bear_div ? cvd_at_pivot : na, title = "Bearish Divergence",
     style = shape.triangledown, location = location.absolute, color = col_bear,
     size = size.small, offset = -div_pivot_rb, text = "div", textcolor = col_bear)
plotshape(series = show_div and bull_div ? cvd_at_pivot : na, title = "Bullish Divergence",
     style = shape.triangleup, location = location.absolute, color = col_bull,
     size = size.small, offset = -div_pivot_rb, text = "div", textcolor = col_bull)

bgcolor(reset_now and not barstate.isfirst ? color.new(#455a64, 88) : na, title = "CVD Reset")

// =============================================================================
// DASHBOARD
// =============================================================================
var table dashboard = table.new(table_position, 2, 9, border_width = 1,
     border_color = color.new(#6e7681, 70), bgcolor = color.new(#0d1117, 8))

f_volume(float value) =>
    na(value) ? "-" : str.tostring(value, format.volume)

if barstate.islast and show_table
    float buy_pct = safe_volume > 0 ? buy_volume / safe_volume * 100.0 : 50.0
    float sell_pct = 100.0 - buy_pct
    bool buyers_lead = buy_pct >= sell_pct
    color bias_color = buyers_lead ? col_bull : col_bear
    string bias_state = (buyers_lead ? "Buy " + str.tostring(buy_pct, "#.#") :
         "Sell " + str.tostring(sell_pct, "#.#")) + "%"
    string data_state = not volume_ok ? "volume missing" : not include_bar ? "outside session" : "ready"
    color data_color = data_state == "ready" ? color.lime : data_state == "outside session" ? color.orange : color.red
    string reset_tag = cvd_reset == RST_SESSION ? (session_basis == SESSION_EXCHANGE ? "session / exchange" : "session / custom") :
         cvd_reset == RST_BLOCK ? "block " + str.tostring(cvd_length) :
         cvd_reset == RST_ROLL ? "rolling " + str.tostring(cvd_length) : "running"
    string signal_state = na(cvd_signal) ? "warming" : cvd >= cvd_signal ? "CVD above" : "CVD below"
    color signal_color = na(cvd_signal) ? color.gray : cvd >= cvd_signal ? col_bull : col_bear
    string proxy_tag = proxy_method == PROXY_CTX ? "context" : proxy_method == PROXY_BLD ? "blended" : "close location"
    string delta_prefix = bar_delta > 0 ? "+" : ""
    string cvd_prefix = cvd > 0 ? "+" : ""
    string rvol_state = na(rvol) ? "warming" : str.tostring(rvol, "#.##") + "x" + (is_spike ? " spike" : "")

    table.cell(dashboard, 0, 0, "Delta engine", text_color = color.white, bgcolor = #161b22, text_size = table_size)
    table.cell(dashboard, 1, 0, data_state, text_color = data_color, bgcolor = #161b22, text_size = table_size)
    table.cell(dashboard, 0, 1, "Bias", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 1, bias_state, text_color = bias_color, text_size = table_size)
    table.cell(dashboard, 0, 2, "Bar delta", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 2, delta_prefix + f_volume(bar_delta) + (delta_accel ? " >>" : " >"),
         text_color = bar_delta >= 0 ? col_bull : col_bear, text_size = table_size)
    table.cell(dashboard, 0, 3, "CVD", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 3, cvd_prefix + f_volume(cvd), text_color = cvd >= 0 ? col_bull : col_bear,
         text_size = table_size)
    table.cell(dashboard, 0, 4, "Signal", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 4, signal_state, text_color = signal_color, text_size = table_size)
    table.cell(dashboard, 0, 5, "RVOL", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 5, rvol_state, text_color = is_spike ? #ffd740 : na(rvol) ? color.gray : rvol >= 1 ? col_bull : col_bear,
         text_size = table_size)
    table.cell(dashboard, 0, 6, "Proxy", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 6, proxy_tag + (weight_rvol ? " / weighted" : " / literal"),
         text_color = weight_rvol ? color.orange : color.white, text_size = table_size)
    table.cell(dashboard, 0, 7, "Reset", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 7, reset_tag, text_color = color.white, text_size = table_size)
    table.cell(dashboard, 0, 8, "Divergence", text_color = color.gray, text_size = table_size)
    table.cell(dashboard, 1, 8, bear_div ? "bear confirmed" : bull_div ? "bull confirmed" : "none",
         text_color = bear_div ? col_bear : bull_div ? col_bull : color.gray, text_size = table_size)

// =============================================================================
// CONFIRMED-BAR ALERTS
// =============================================================================
bool confirmed = barstate.isconfirmed
bool cross_above_zero = ta.crossover(cvd, 0)
bool cross_below_zero = ta.crossunder(cvd, 0)
bool cross_above_signal = ta.crossover(cvd, cvd_signal)
bool cross_below_signal = ta.crossunder(cvd, cvd_signal)
alertcondition(confirmed and cross_above_zero, "CVD Cross Above Zero", "CVD crossed above zero")
alertcondition(confirmed and cross_below_zero, "CVD Cross Below Zero", "CVD crossed below zero")
alertcondition(confirmed and not na(cvd_signal) and cross_above_signal, "CVD Cross Above Signal", "CVD crossed above its reset-aware signal")
alertcondition(confirmed and not na(cvd_signal) and cross_below_signal, "CVD Cross Below Signal", "CVD crossed below its reset-aware signal")
alertcondition(confirmed and include_bar and is_spike and bar_delta > 0, "RVOL Spike Buyers", "High relative volume with buy-side proxy dominance")
alertcondition(confirmed and include_bar and is_spike and bar_delta < 0, "RVOL Spike Sellers", "High relative volume with sell-side proxy dominance")
alertcondition(confirmed and bear_div, "Bearish Divergence", "Price made a higher high while CVD made a materially lower high")
alertcondition(confirmed and bull_div, "Bullish Divergence", "Price made a lower low while CVD made a materially higher low")
alertcondition(confirmed and bar_delta > 0 and not delta_accel and delta_accel[1], "Buy Delta Fading", "Buy-side proxy delta is decelerating")
alertcondition(confirmed and bar_delta < 0 and not delta_accel and delta_accel[1], "Sell Delta Fading", "Sell-side proxy delta is decelerating")
````
