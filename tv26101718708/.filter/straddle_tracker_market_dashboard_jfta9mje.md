# Straddle Tracker + Market Dashboard

- url: https://www.tradingview.com/script/jFTa9Mje-Straddle-Tracker-Market-Dashboard/
- type: indicator
- pine_id: PUB;e55d921ce18640c0bfcba605273a0bb7
- version: 5.0

## Description

[b]RM Straddle Tracker + Multi-Timeframe Market Dashboard[/b]

The RM Straddle Tracker + Market Dashboard is a professional options analysis tool designed for traders who monitor ATM Straddles, Futures Pairs, Synthetic Positions, and Premium-Based Market Direction.

Instead of analyzing only price action, this indicator tracks the combined premium value of two instruments (typically Call + Put) and evaluates market sentiment across multiple timeframes using a powerful dashboard of trend and momentum indicators.

[b]Key Features[/b]
✅ Real-Time Straddle Premium Tracking
Tracks combined premium of:
Call + Put Options
Futures Pairs
Any two custom symbols
Displays live combined premium line.
Shows current straddle value directly on the chart.
✅ Multi-Timeframe Market Dashboard

[b]Analyze sentiment across:[/b]

5 Minute
15 Minute
1 Hour
1 Day
1 Week
1 Month

Get a quick overview of market strength without switching charts.

[b]Indicators Included[/b]
Moving Averages
SMA 9
SMA 20
SMA 50
SMA 100
SMA 200
Momentum
RSI (14)
MACD Histogram
Trend
Custom Non-Repainting SuperTrend

[b]Each indicator is classified as:[/b]

🟢 Bullish
🔴 Bearish
⚪ Neutral

Unique Shift Price Technology

One of the most powerful features of this dashboard is the Shift Price Tracker.

Whenever an indicator changes from:

Bullish → Bearish
Bearish → Bullish

the dashboard captures and stores the exact straddle premium at the moment of the shift.

This allows traders to:

Identify important sentiment changes.
Compare current premium with previous trend reversals.
Track premium expansion and contraction.
Build better entry and exit decisions.
Smart Alert System

[b]Receive alerts whenever:[/b]

SMA trend changes
RSI flips direction
MACD changes bias
SuperTrend reverses

Alerts are generated only on confirmed state changes to reduce noise.

[b]Best Use Cases[/b]

✔ NIFTY Weekly Straddles
✔ BANKNIFTY Weekly Straddles
✔ FINNIFTY Straddles
✔ Synthetic Futures Tracking
✔ Options Selling Strategies
✔ Volatility Monitoring
✔ Premium Expansion Analysis
✔ Multi-Timeframe Trend Confirmation

[b]Advantages[/b]
Multi-timeframe analysis in one screen
Premium-based market sentiment
Non-repainting dashboard logic
Shift-price memory system
Customizable timeframes and indicators
Suitable for intraday and positional traders
Disclaimer

This indicator is an analytical and educational tool. It does not provide financial advice. Always use proper risk management and perform your own analysis before taking any trade decisions.

## Source Code

````pine
//@version=6
indicator("Straddle Chart + Multiple TimeFrames Multiple Indicators  Dashboard", overlay=false, scale=scale.left, max_labels_count=500, max_boxes_count=500)

// ==========================================
// OPTION STRADDLE INPUTS & CONFIGURATIONS
// ==========================================
var string G_STRAD = "Straddle Settings (Options/Futures pairs)"
show_straddle  = input.bool(true, "Plot Straddle Premium Line", group=G_STRAD)
call_ticker    = input.symbol("NSE:NIFTY26062323500CE", "Call Option Ticker / Pair A", group=G_STRAD)
put_ticker     = input.symbol("NSE:NIFTY26062323500PE", "Put Option Ticker / Pair B", group=G_STRAD)
straddle_color = input.color(color.orange, "Straddle Line Color", group=G_STRAD)

// ==========================================
// DASHBOARD INPUTS & CONFIGURATIONS
// ==========================================
var string G_DISPLAY = "Dashboard Display"
show_dash   = input.bool(true, "Show Dashboard Table", group=G_DISPLAY)
dash_pos    = input.string("top_right", "Table Position Anchor", options=["top_right", "bottom_right", "top_left", "bottom_left", "center_right", "center_left"], group=G_DISPLAY)
text_size   = input.string("small", "Text Font Size", options=["tiny", "small", "normal", "large"], group=G_DISPLAY)

var string G_TF = "Timeframes to Display"
tf_5m_en    = input.bool(true, "Enable 5 Min Column", group=G_TF)
tf_15m_en   = input.bool(true, "Enable 15 Min Column", group=G_TF)
tf_1h_en    = input.bool(true, "Enable 1 Hour Column", group=G_TF)
tf_1d_en    = input.bool(true, "Enable 1 Day Column", group=G_TF)
tf_1w_en    = input.bool(true, "Enable 1 Week Column", group=G_TF)
tf_1m_en    = input.bool(true, "Enable 1 Month Column", group=G_TF)

var string G_IND = "Indicators to Display"
ind_sma9_en  = input.bool(true, "Enable SMA 9 Row", group=G_IND)
ind_sma20_en = input.bool(true, "Enable SMA 20 Row", group=G_IND)
ind_sma50_en = input.bool(true, "Enable SMA 50 Row", group=G_IND)
ind_sma100_en= input.bool(true, "Enable SMA 100 Row", group=G_IND)
ind_sma200_en= input.bool(true, "Enable SMA 200 Row", group=G_IND)
ind_rsi_en   = input.bool(true, "Enable RSI Row", group=G_IND)
ind_macd_en  = input.bool(true, "Enable MACD Row", group=G_IND)
ind_st_en    = input.bool(true, "Enable SuperTrend Row", group=G_IND)

var string G_ALERT = "Alert Configurations"
alert_changes = input.bool(true, "Alert on State Change", group=G_ALERT)

var string G_ST = "SuperTrend Settings"
st_atr_len  = input.int(10, "SuperTrend ATR Length", group=G_ST)
st_mult     = input.float(3.0, "SuperTrend Multiplier", group=G_ST)

// ==========================================
// STRADDLE PRICE PER TIMEFRAME
// ==========================================
f_straddle_price(simple string tf) =>
    c = request.security(call_ticker, tf, close, ignore_invalid_symbol=true)
    p = request.security(put_ticker,  tf, close, ignore_invalid_symbol=true)
    (na(c) ? 0.0 : c) + (na(p) ? 0.0 : p)

sp_5m  = f_straddle_price("5")
sp_15m = f_straddle_price("15")
sp_1h  = f_straddle_price("60")
sp_1d  = f_straddle_price("1D")
sp_1w  = f_straddle_price("1W")
sp_1mo = f_straddle_price("1M")

call_premium     = request.security(call_ticker, timeframe.period, close, ignore_invalid_symbol=true)
put_premium      = request.security(put_ticker,  timeframe.period, close, ignore_invalid_symbol=true)
straddle_premium = (na(call_premium) ? 0.0 : call_premium) + (na(put_premium) ? 0.0 : put_premium)

plot(show_straddle and straddle_premium > 0 ? straddle_premium : na,
     title="Combined Straddle Premium", color=straddle_color, linewidth=2)

var label straddle_price_label = na

if show_straddle and barstate.islast and straddle_premium > 0
    if not na(straddle_price_label)
        label.delete(straddle_price_label)

    straddle_price_label := label.new(
         bar_index,
         straddle_premium,
         text="₹" + str.tostring(straddle_premium, "#.00"),
         color=straddle_color,
         textcolor=color.white,
         style=label.style_label_left,
         size=size.normal)
// ==========================================
// CORE STATES CALCULATOR
// ==========================================
var string BULL = "Bullish"
var string BEAR = "Bearish"
var string FLAT = "Flat"

var color COLOR_BULL = color.new(color.green, 20)
var color COLOR_BEAR = color.new(color.red, 20)
var color COLOR_FLAT = color.new(color.gray, 20)

// ==========================================
// MANUAL SUPERTREND — STATE VARS PER TIMEFRAME
// var inside functions resets per call instance,
// so we declare persistent state at script level
// ==========================================

f_st_bands(src, atr_len, mult) =>
    tr_proxy   = math.abs(src - src[1])
    atr_custom = ta.rma(tr_proxy, atr_len)
    raw_upper  = src + mult * atr_custom
    raw_lower  = src - mult * atr_custom
    [raw_upper, raw_lower]

// Per-timeframe persistent SuperTrend state
var float st5_upper  = na
var float st5_lower  = na
var int   st5_dir    = 1

var float st15_upper = na
var float st15_lower = na
var int   st15_dir   = 1

var float st60_upper = na
var float st60_lower = na
var int   st60_dir   = 1

var float stD_upper  = na
var float stD_lower  = na
var int   stD_dir    = 1

var float stW_upper  = na
var float stW_lower  = na
var int   stW_dir    = 1

var float stM_upper  = na
var float stM_lower  = na
var int   stM_dir    = 1

// Ratchet + flip logic as a macro-style function
// Returns [st_line, direction]  direction: -1=Bullish, 1=Bearish
f_st_update(src, raw_upper, raw_lower, prev_upper, prev_lower, prev_dir) =>
    // Band ratchet — bands only tighten, never widen
    new_upper = (na(prev_upper) or raw_upper < prev_upper) ? raw_upper : prev_upper
    new_lower = (na(prev_lower) or raw_lower > prev_lower) ? raw_lower : prev_lower

    // Trend flip — only changes when price CROSSES the band
    new_dir = prev_dir
    if prev_dir == 1        // currently Bearish
        if src > new_upper  // price crossed above upper → flip Bullish
            new_dir := -1
            new_lower := raw_lower  // reset lower band on flip
    else                    // currently Bullish
        if src < new_lower  // price crossed below lower → flip Bearish
            new_dir := 1
            new_upper := raw_upper  // reset upper band on flip

    st_line = new_dir == -1 ? new_lower : new_upper
    [st_line, new_dir, new_upper, new_lower]

// ==========================================
// COMPUTE BANDS PER TIMEFRAME
// ==========================================
[raw_u5,  raw_l5]  = f_st_bands(sp_5m,  st_atr_len, st_mult)
[raw_u15, raw_l15] = f_st_bands(sp_15m, st_atr_len, st_mult)
[raw_u60, raw_l60] = f_st_bands(sp_1h,  st_atr_len, st_mult)
[raw_uD,  raw_lD]  = f_st_bands(sp_1d,  st_atr_len, st_mult)
[raw_uW,  raw_lW]  = f_st_bands(sp_1w,  st_atr_len, st_mult)
[raw_uM,  raw_lM]  = f_st_bands(sp_1mo, st_atr_len, st_mult)

// ==========================================
// UPDATE STATE PER TIMEFRAME & PERSIST
// ==========================================
[stval5,  st5_dir_new,  st5_u,  st5_l]  = f_st_update(sp_5m,  raw_u5,  raw_l5,  st5_upper,  st5_lower,  st5_dir)
st5_upper  := st5_u
st5_lower  := st5_l
st5_dir    := st5_dir_new

[stval15, st15_dir_new, st15_u, st15_l] = f_st_update(sp_15m, raw_u15, raw_l15, st15_upper, st15_lower, st15_dir)
st15_upper := st15_u
st15_lower := st15_l
st15_dir   := st15_dir_new

[stval60, st60_dir_new, st60_u, st60_l] = f_st_update(sp_1h,  raw_u60, raw_l60, st60_upper, st60_lower, st60_dir)
st60_upper := st60_u
st60_lower := st60_l
st60_dir   := st60_dir_new

[stvalD,  stD_dir_new,  stD_u,  stD_l]  = f_st_update(sp_1d,  raw_uD,  raw_lD,  stD_upper,  stD_lower,  stD_dir)
stD_upper  := stD_u
stD_lower  := stD_l
stD_dir    := stD_dir_new

[stvalW,  stW_dir_new,  stW_u,  stW_l]  = f_st_update(sp_1w,  raw_uW,  raw_lW,  stW_upper,  stW_lower,  stW_dir)
stW_upper  := stW_u
stW_lower  := stW_l
stW_dir    := stW_dir_new

[stvalM,  stM_dir_new,  stM_u,  stM_l]  = f_st_update(sp_1mo, raw_uM,  raw_lM,  stM_upper,  stM_lower,  stM_dir)
stM_upper  := stM_u
stM_lower  := stM_l
stM_dir    := stM_dir_new

// ==========================================
// UPDATED f_calc_states — takes pre-computed
// st_dir per timeframe instead of calling
// f_supertrend_custom internally
// ==========================================
f_calc_states(sp, st_direction) =>
    s9   = ta.sma(sp, 9)
    s20  = ta.sma(sp, 20)
    s50  = ta.sma(sp, 50)
    s100 = ta.sma(sp, 100)
    s200 = ta.sma(sp, 200)

    state_sma9   = sp > s9   ? BULL : BEAR
    state_sma20  = sp > s20  ? BULL : BEAR
    state_sma50  = sp > s50  ? BULL : BEAR
    state_sma100 = sp > s100 ? BULL : BEAR
    state_sma200 = sp > s200 ? BULL : BEAR

    r          = ta.rsi(sp, 14)
    state_rsi  = r > 50 ? BULL : r < 50 ? BEAR : FLAT

    [_, __, histLine] = ta.macd(sp, 12, 26, 9)
    state_macd = histLine > 0 ? BULL : histLine < 0 ? BEAR : FLAT

    // KEY FIX: use pre-computed direction passed in as argument
    state_st   = st_direction == -1 ? BULL : BEAR

    [state_sma9, state_sma20, state_sma50, state_sma100, state_sma200, state_rsi, state_macd, state_st]

// Pass pre-computed st_dir into f_calc_states per timeframe
[tf5_s9,  tf5_s20,  tf5_s50,  tf5_s100,  tf5_s200,  tf5_rsi,  tf5_macd,  tf5_st]  = f_calc_states(sp_5m,  st5_dir)
[tf15_s9, tf15_s20, tf15_s50, tf15_s100, tf15_s200, tf15_rsi, tf15_macd, tf15_st] = f_calc_states(sp_15m, st15_dir)
[tf60_s9, tf60_s20, tf60_s50, tf60_s100, tf60_s200, tf60_rsi, tf60_macd, tf60_st] = f_calc_states(sp_1h,  st60_dir)
[tfD_s9,  tfD_s20,  tfD_s50,  tfD_s100,  tfD_s200,  tfD_rsi,  tfD_macd,  tfD_st]  = f_calc_states(sp_1d,  stD_dir)
[tfW_s9,  tfW_s20,  tfW_s50,  tfW_s100,  tfW_s200,  tfW_rsi,  tfW_macd,  tfW_st]  = f_calc_states(sp_1w,  stW_dir)
[tfM_s9,  tfM_s20,  tfM_s50,  tfM_s100,  tfM_s200,  tfM_rsi,  tfM_macd,  tfM_st]  = f_calc_states(sp_1mo, stM_dir)
// ==========================================
// KEY ADDITION: PRICE-AT-SHIFT TRACKER
// Stores the straddle price at the moment each indicator
// changed state — persists until the next shift
// ==========================================
f_shift_price(string current_state, float price_series) =>
    // var persists the last-shift price across all bars
    var float  shift_price = na
    var string last_state  = na
    if na(last_state)
        last_state  := current_state
        shift_price := price_series
    if current_state != last_state
        shift_price := price_series   // capture price at the moment of shift
        last_state  := current_state
    shift_price

// Track shift prices for every indicator × timeframe combination
sp5_s9    = f_shift_price(tf5_s9,   sp_5m)
sp5_s20   = f_shift_price(tf5_s20,  sp_5m)
sp5_s50   = f_shift_price(tf5_s50,  sp_5m)
sp5_s100  = f_shift_price(tf5_s100, sp_5m)
sp5_s200  = f_shift_price(tf5_s200, sp_5m)
sp5_rsi   = f_shift_price(tf5_rsi,  sp_5m)
sp5_macd  = f_shift_price(tf5_macd, sp_5m)
sp5_st    = f_shift_price(tf5_st,   sp_5m)

sp15_s9   = f_shift_price(tf15_s9,   sp_15m)
sp15_s20  = f_shift_price(tf15_s20,  sp_15m)
sp15_s50  = f_shift_price(tf15_s50,  sp_15m)
sp15_s100 = f_shift_price(tf15_s100, sp_15m)
sp15_s200 = f_shift_price(tf15_s200, sp_15m)
sp15_rsi  = f_shift_price(tf15_rsi,  sp_15m)
sp15_macd = f_shift_price(tf15_macd, sp_15m)
sp15_st   = f_shift_price(tf15_st,   sp_15m)

sp60_s9   = f_shift_price(tf60_s9,   sp_1h)
sp60_s20  = f_shift_price(tf60_s20,  sp_1h)
sp60_s50  = f_shift_price(tf60_s50,  sp_1h)
sp60_s100 = f_shift_price(tf60_s100, sp_1h)
sp60_s200 = f_shift_price(tf60_s200, sp_1h)
sp60_rsi  = f_shift_price(tf60_rsi,  sp_1h)
sp60_macd = f_shift_price(tf60_macd, sp_1h)
sp60_st   = f_shift_price(tf60_st,   sp_1h)

spD_s9   = f_shift_price(tfD_s9,   sp_1d)
spD_s20  = f_shift_price(tfD_s20,  sp_1d)
spD_s50  = f_shift_price(tfD_s50,  sp_1d)
spD_s100 = f_shift_price(tfD_s100, sp_1d)
spD_s200 = f_shift_price(tfD_s200, sp_1d)
spD_rsi  = f_shift_price(tfD_rsi,  sp_1d)
spD_macd = f_shift_price(tfD_macd, sp_1d)
spD_st   = f_shift_price(tfD_st,   sp_1d)

spW_s9   = f_shift_price(tfW_s9,   sp_1w)
spW_s20  = f_shift_price(tfW_s20,  sp_1w)
spW_s50  = f_shift_price(tfW_s50,  sp_1w)
spW_s100 = f_shift_price(tfW_s100, sp_1w)
spW_s200 = f_shift_price(tfW_s200, sp_1w)
spW_rsi  = f_shift_price(tfW_rsi,  sp_1w)
spW_macd = f_shift_price(tfW_macd, sp_1w)
spW_st   = f_shift_price(tfW_st,   sp_1w)

spM_s9   = f_shift_price(tfM_s9,   sp_1mo)
spM_s20  = f_shift_price(tfM_s20,  sp_1mo)
spM_s50  = f_shift_price(tfM_s50,  sp_1mo)
spM_s100 = f_shift_price(tfM_s100, sp_1mo)
spM_s200 = f_shift_price(tfM_s200, sp_1mo)
spM_rsi  = f_shift_price(tfM_rsi,  sp_1mo)
spM_macd = f_shift_price(tfM_macd, sp_1mo)
spM_st   = f_shift_price(tfM_st,   sp_1mo)

// ==========================================
// ALERT SYSTEM
// ==========================================
f_check_alert(current, previous, name, tf) =>
    if alert_changes and (current != previous) and not na(previous)
        if (current == BULL and previous == BEAR) or (current == BEAR and previous == BULL)
            alert("Straddle State Change on " + syminfo.ticker + " (" + tf + "): " + name + " shifted to " + current, alert.freq_once_per_bar_close)

if barstate.isconfirmed
    if tf_5m_en
        f_check_alert(tf5_s9,   tf5_s9[1],   "SMA 9",      "5m")
        f_check_alert(tf5_s20,  tf5_s20[1],  "SMA 20",     "5m")
        f_check_alert(tf5_s50,  tf5_s50[1],  "SMA 50",     "5m")
        f_check_alert(tf5_s100, tf5_s100[1], "SMA 100",    "5m")
        f_check_alert(tf5_s200, tf5_s200[1], "SMA 200",    "5m")
        f_check_alert(tf5_rsi,  tf5_rsi[1],  "RSI",        "5m")
        f_check_alert(tf5_macd, tf5_macd[1], "MACD",       "5m")
        f_check_alert(tf5_st,   tf5_st[1],   "SuperTrend", "5m")
    if tf_15m_en
        f_check_alert(tf15_s9,   tf15_s9[1],   "SMA 9",      "15m")
        f_check_alert(tf15_s20,  tf15_s20[1],  "SMA 20",     "15m")
        f_check_alert(tf15_s50,  tf15_s50[1],  "SMA 50",     "15m")
        f_check_alert(tf15_s100, tf15_s100[1], "SMA 100",    "15m")
        f_check_alert(tf15_s200, tf15_s200[1], "SMA 200",    "15m")
        f_check_alert(tf15_rsi,  tf15_rsi[1],  "RSI",        "15m")
        f_check_alert(tf15_macd, tf15_macd[1], "MACD",       "15m")
        f_check_alert(tf15_st,   tf15_st[1],   "SuperTrend", "15m")
    if tf_1h_en
        f_check_alert(tf60_s9,   tf60_s9[1],   "SMA 9",      "1h")
        f_check_alert(tf60_s20,  tf60_s20[1],  "SMA 20",     "1h")
        f_check_alert(tf60_s50,  tf60_s50[1],  "SMA 50",     "1h")
        f_check_alert(tf60_s100, tf60_s100[1], "SMA 100",    "1h")
        f_check_alert(tf60_s200, tf60_s200[1], "SMA 200",    "1h")
        f_check_alert(tf60_rsi,  tf60_rsi[1],  "RSI",        "1h")
        f_check_alert(tf60_macd, tf60_macd[1], "MACD",       "1h")
        f_check_alert(tf60_st,   tf60_st[1],   "SuperTrend", "1h")

// ==========================================
// DASHBOARD UI RENDER ENGINE
// ==========================================
var position = dash_pos == "top_right"    ? position.top_right    :
               dash_pos == "bottom_right" ? position.bottom_right :
               dash_pos == "top_left"     ? position.top_left     :
               dash_pos == "bottom_left"  ? position.bottom_left  :
               dash_pos == "center_right" ? position.middle_right : position.middle_left

var size = text_size == "tiny"   ? size.tiny   :
           text_size == "small"  ? size.small  :
           text_size == "normal" ? size.normal : size.large

var table dash = table.new(position, columns=15, rows=15,
     bgcolor=color.new(color.black, 100), border_color=color.black, border_width=1)

f_get_color(string state) =>
    state == BULL ? COLOR_BULL : state == BEAR ? COLOR_BEAR : COLOR_FLAT

// KEY ADDITION: cell now shows "Bullish\n₹123.45" — state on line 1, shift price on line 2
f_cell_text(string state, float shift_px) =>
    price_str = na(shift_px) ? "" : "\n₹" + str.tostring(shift_px, "#.00")
    state + price_str

f_draw_row(bool enable, string label,
     string s5,  string s15,  string s60,  string sD,  string sW,  string sM,
     float  p5,  float  p15,  float  p60,  float  pD,  float  pW,  float  pM,
     int cur_row) =>
    next_row = cur_row
    if enable
        table.cell(dash, 0, cur_row, label,
             bgcolor=color.gray, text_color=color.white, text_size=size, text_halign=text.align_left)
        c_idx = 1
        if tf_5m_en
            table.cell(dash, c_idx, cur_row, f_cell_text(s5, p5),
                 bgcolor=f_get_color(s5), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_15m_en
            table.cell(dash, c_idx, cur_row, f_cell_text(s15, p15),
                 bgcolor=f_get_color(s15), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1h_en
            table.cell(dash, c_idx, cur_row, f_cell_text(s60, p60),
                 bgcolor=f_get_color(s60), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1d_en
            table.cell(dash, c_idx, cur_row, f_cell_text(sD, pD),
                 bgcolor=f_get_color(sD), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1w_en
            table.cell(dash, c_idx, cur_row, f_cell_text(sW, pW),
                 bgcolor=f_get_color(sW), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        if tf_1m_en
            table.cell(dash, c_idx, cur_row, f_cell_text(sM, pM),
                 bgcolor=f_get_color(sM), text_color=color.white, text_size=size)
            c_idx := c_idx + 1
        next_row := cur_row + 1
    next_row

if show_dash and barstate.islast
    table.clear(dash, 0, 0, 14, 14)
    table.cell(dash, 0, 0, "Indicator", bgcolor=color.gray, text_color=color.white, text_size=size)

    col_idx = 1
    if tf_5m_en
        table.cell(dash, col_idx, 0, "5 Min",   bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_15m_en
        table.cell(dash, col_idx, 0, "15 Min",  bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1h_en
        table.cell(dash, col_idx, 0, "1 Hour",  bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1d_en
        table.cell(dash, col_idx, 0, "1 Day",   bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1w_en
        table.cell(dash, col_idx, 0, "1 Week",  bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1
    if tf_1m_en
        table.cell(dash, col_idx, 0, "1 Month", bgcolor=color.gray, text_color=color.white, text_size=size)
        col_idx := col_idx + 1

    row_idx = 1
    row_idx := f_draw_row(ind_sma9_en,   "SMA 9",
         tf5_s9,   tf15_s9,   tf60_s9,   tfD_s9,   tfW_s9,   tfM_s9,
         sp5_s9,   sp15_s9,   sp60_s9,   spD_s9,   spW_s9,   spM_s9,   row_idx)
    row_idx := f_draw_row(ind_sma20_en,  "SMA 20",
         tf5_s20,  tf15_s20,  tf60_s20,  tfD_s20,  tfW_s20,  tfM_s20,
         sp5_s20,  sp15_s20,  sp60_s20,  spD_s20,  spW_s20,  spM_s20,  row_idx)
    row_idx := f_draw_row(ind_sma50_en,  "SMA 50",
         tf5_s50,  tf15_s50,  tf60_s50,  tfD_s50,  tfW_s50,  tfM_s50,
         sp5_s50,  sp15_s50,  sp60_s50,  spD_s50,  spW_s50,  spM_s50,  row_idx)
    row_idx := f_draw_row(ind_sma100_en, "SMA 100",
         tf5_s100, tf15_s100, tf60_s100, tfD_s100, tfW_s100, tfM_s100,
         sp5_s100, sp15_s100, sp60_s100, spD_s100, spW_s100, spM_s100, row_idx)
    row_idx := f_draw_row(ind_sma200_en, "SMA 200",
         tf5_s200, tf15_s200, tf60_s200, tfD_s200, tfW_s200, tfM_s200,
         sp5_s200, sp15_s200, sp60_s200, spD_s200, spW_s200, spM_s200, row_idx)
    row_idx := f_draw_row(ind_rsi_en,    "RSI (50)",
         tf5_rsi,  tf15_rsi,  tf60_rsi,  tfD_rsi,  tfW_rsi,  tfM_rsi,
         sp5_rsi,  sp15_rsi,  sp60_rsi,  spD_rsi,  spW_rsi,  spM_rsi,  row_idx)
    row_idx := f_draw_row(ind_macd_en,   "MACD Hist",
         tf5_macd, tf15_macd, tf60_macd, tfD_macd, tfW_macd, tfM_macd,
         sp5_macd, sp15_macd, sp60_macd, spD_macd, spW_macd, spM_macd, row_idx)
    row_idx := f_draw_row(ind_st_en,     "SuperTrend",
         tf5_st,   tf15_st,   tf60_st,   tfD_st,   tfW_st,   tfM_st,
         sp5_st,   sp15_st,   sp60_st,   spD_st,   spW_st,   spM_st,   row_idx)
````
