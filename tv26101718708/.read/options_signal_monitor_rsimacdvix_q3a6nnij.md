# Options Signal Monitor - RSI/MACD/VIX

- url: https://www.tradingview.com/script/q3a6nNij-Options-Signal-Monitor-RSI-MACD-VIX/
- type: indicator
- pine_id: PUB;35df77ab289e43e4a8fb19e8e30addc0
- version: 1.0

## Description

When you use alert(), you create one single alert in TradingView's alert dialog (instead of three separate ones), and the message text is determined dynamically at runtime — which is exactly what you need for dynamic strikes, expiry, and SL values.

## Source Code

````pine
//@version=5
indicator("Options Signal Monitor - RSI/MACD/VIX", overlay=true, max_labels_count=500)

// ============================================================
//  USER-CONFIGURABLE SETTINGS
//  Change strikes, expiry, and premium limits here easily
// ============================================================

// --- Call Setup ---
call_strike       = input.int(7150,   title="Call Strike Price",       group="📈 Call Setup")
call_expiry       = input.string("Apr 21 2026", title="Call Expiry Date",  group="📈 Call Setup")
call_max_premium  = input.float(6.0,  title="Call Max Premium ($)",    group="📈 Call Setup")
call_stop_loss    = input.float(2.50, title="Call Stop Loss ($)",       group="📈 Call Setup")

// --- Put Setup ---
put_strike        = input.int(7100,   title="Put Strike Price",        group="📉 Put Setup")
put_expiry        = input.string("Apr 21 2026", title="Put Expiry Date",   group="📉 Put Setup")
put_max_premium   = input.float(6.0,  title="Put Max Premium ($)",     group="📉 Put Setup")
put_stop_loss     = input.float(2.50, title="Put Stop Loss ($)",        group="📉 Put Setup")

// --- Stop Loss Trigger ---
entry_premium     = input.float(6.0,  title="Entry Premium Paid ($)",  group="⛔ Stop Loss Logic")
sl_pct            = input.float(50.0, title="Stop Loss % Drop",        group="⛔ Stop Loss Logic")

// --- RSI Settings ---
rsi_length        = input.int(14,     title="RSI Length",              group="📊 Indicator Settings")
rsi_ob            = input.int(70,     title="RSI Overbought Level",    group="📊 Indicator Settings")
rsi_os            = input.int(30,     title="RSI Oversold Level",      group="📊 Indicator Settings")

// --- MACD Settings ---
macd_fast         = input.int(12,     title="MACD Fast Length",        group="📊 Indicator Settings")
macd_slow         = input.int(26,     title="MACD Slow Length",        group="📊 Indicator Settings")
macd_signal_len   = input.int(9,      title="MACD Signal Length",      group="📊 Indicator Settings")

// --- VIX Threshold ---
vix_symbol        = input.symbol("VIX", title="VIX Symbol",            group="📊 Indicator Settings")
vix_high_thresh   = input.float(20.0, title="VIX High (Fear) Level",   group="📊 Indicator Settings")
vix_low_thresh    = input.float(15.0, title="VIX Low (Calm) Level",    group="📊 Indicator Settings")

// ============================================================
//  INDICATOR CALCULATIONS
// ============================================================

// --- RSI ---
rsi_val = ta.rsi(close, rsi_length)

// --- MACD ---
[macd_line, signal_line, hist_line] = ta.macd(close, macd_fast, macd_slow, macd_signal_len)

// MACD Crossovers
macd_bull_cross = ta.crossover(macd_line, signal_line)   // Bullish crossover
macd_bear_cross = ta.crossunder(macd_line, signal_line)  // Bearish crossunder

// Histogram momentum direction
hist_rising  = hist_line > hist_line[1] and hist_line > 0
hist_falling = hist_line < hist_line[1] and hist_line < 0

// --- VIX (fetched from external symbol) ---
vix_close = request.security(vix_symbol, timeframe.period, close)
vix_calm  = vix_close < vix_low_thresh    // Low VIX = calm market, good for calls
vix_fear  = vix_close > vix_high_thresh   // High VIX = fear/volatile, good for puts

// ============================================================
//  SIGNAL CONDITIONS
// ============================================================

// ------- CALL (BUY) CONDITIONS -------
// RSI recovering from oversold territory (below 50, not yet overbought)
rsi_bullish = rsi_val > rsi_os and rsi_val < rsi_ob

// MACD bullish: line crossed above signal OR histogram rising above zero
macd_bullish = macd_bull_cross or hist_rising

// Price is above short-term EMA (trend confirmation)
ema_short    = ta.ema(close, 9)
ema_long     = ta.ema(close, 21)
price_above_ema = close > ema_short and ema_short > ema_long

// Combined CALL signal: all three align
call_signal = rsi_bullish and macd_bullish and price_above_ema

// ------- PUT (SELL) CONDITIONS -------
// RSI near or above overbought territory
rsi_bearish = rsi_val > 50 and rsi_val <= rsi_ob + 5

// MACD bearish: line crossed below signal OR histogram falling below zero
macd_bearish = macd_bear_cross or hist_falling

// Price is below short-term EMA (trend confirmation)
price_below_ema = close < ema_short and ema_short < ema_long

// Combined PUT signal: all three align
put_signal = rsi_bearish and macd_bearish and price_below_ema

// ============================================================
//  STOP LOSS LOGIC
//  If premium drops 50% from entry, trigger stop loss label
// ============================================================
sl_trigger_price = entry_premium * (1 - sl_pct / 100)

// Simulate: if RSI diverges badly after a call signal was active
// In live use, you'd track entry bar index and compare premium externally
// Here we flag if conditions reverse sharply after a signal
call_sl_condition = call_signal[3] and rsi_val < rsi_os  // Was bullish, now deeply oversold
put_sl_condition  = put_signal[3] and rsi_val > rsi_ob   // Was bearish, now deeply overbought

// ============================================================
//  LABEL TEXT BUILDERS
// ============================================================

// Helper: format dollar amounts neatly
f_dollar(v) =>
    "$" + str.tostring(v, "#.##")

// --- Call Label Text ---
call_label_text =
     "🟢 CALL SIGNAL\n" +
     "──────────────\n" +
     "Strike : " + str.tostring(call_strike) + "\n" +
     "Expiry : " + call_expiry + "\n" +
     "Max Pay: " + f_dollar(call_max_premium) + "\n" +
     "Stop L : " + f_dollar(call_stop_loss) + "\n" +
     "VIX    : " + str.tostring(vix_close, "#.#") + "\n" +
     "RSI    : " + str.tostring(rsi_val, "#.#")

// --- Put Label Text ---
put_label_text =
     "🔴 PUT SIGNAL\n" +
     "──────────────\n" +
     "Strike : " + str.tostring(put_strike) + "\n" +
     "Expiry : " + put_expiry + "\n" +
     "Max Pay: " + f_dollar(put_max_premium) + "\n" +
     "Stop L : " + f_dollar(put_stop_loss) + "\n" +
     "VIX    : " + str.tostring(vix_close, "#.#") + "\n" +
     "RSI    : " + str.tostring(rsi_val, "#.#")

// --- Stop Loss Label Text ---
sl_label_text =
     "⛔ STOP LOSS HIT\n" +
     "──────────────\n" +
     "Exit Position\n" +
     "SL Level: " + f_dollar(sl_trigger_price)

// ============================================================
//  PLOT LABELS ON CHART
// ============================================================

// --- Call Label (Green, below bar) ---
if call_signal
    label.new(
         x         = bar_index,
         y         = low * 0.9995,
         text      = call_label_text,
         color     = color.new(color.green, 5),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = size.normal
         )

// --- Put Label (Red, above bar) ---
if put_signal
    label.new(
         x         = bar_index,
         y         = high * 1.0005,
         text      = put_label_text,
         color     = color.new(color.red, 5),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = size.normal
         )

// --- Stop Loss Label (Dark Red, below bar) ---
if call_sl_condition or put_sl_condition
    label.new(
         x         = bar_index,
         y         = low * 0.999,
         text      = sl_label_text,
         color     = color.new(color.maroon, 0),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = size.normal
         )

// ============================================================
//  ALERT MESSAGES  (use alert() for dynamic strings)
// ============================================================

// --- Call Alert ---
if call_signal
    call_alert_msg =
         syminfo.ticker + " " +
         str.tostring(call_strike) +
         " Call • " + call_expiry +
         " • Under " + f_dollar(call_max_premium) +
         " • SL " + f_dollar(call_stop_loss)
    alert(call_alert_msg, alert.freq_once_per_bar_close)

// --- Put Alert ---
if put_signal
    put_alert_msg =
         syminfo.ticker + " " +
         str.tostring(put_strike) +
         " Put • " + put_expiry +
         " • Under " + f_dollar(put_max_premium) +
         " • SL " + f_dollar(put_stop_loss)
    alert(put_alert_msg, alert.freq_once_per_bar_close)

// --- Stop Loss Alert ---
if call_sl_condition or put_sl_condition
    sl_alert_msg = "⛔ Stop Loss Hit - Exit • " +
         syminfo.ticker + " • SL at " + f_dollar(sl_trigger_price)
    alert(sl_alert_msg, alert.freq_once_per_bar_close)
    
// ============================================================
//  VISUAL AIDS — EMAs and signal markers on price chart
// ============================================================

// Plot EMAs for visual trend reference
plot(ema_short, title="EMA 9",  color=color.new(color.aqua,   30), linewidth=1)
plot(ema_long,  title="EMA 21", color=color.new(color.orange, 30), linewidth=1)

// Small triangle markers for quick visual scanning
plotshape(call_signal,         title="Call Entry",   style=shape.triangleup,
     location=location.belowbar, color=color.green, size=size.small)

plotshape(put_signal,          title="Put Entry",    style=shape.triangledown,
     location=location.abovebar, color=color.red,   size=size.small)

plotshape(call_sl_condition or put_sl_condition, title="Stop Loss",
     style=shape.xcross, location=location.belowbar,
     color=color.maroon, size=size.small)

// ============================================================
//  INFO TABLE — Live dashboard in corner
// ============================================================
var table info_table = table.new(
     position.top_right, 2, 7,
     bgcolor       = color.new(color.black, 20),
     border_width  = 1,
     border_color  = color.gray
     )

if barstate.islast
    // Header
    table.cell(info_table, 0, 0, "INDICATOR",  text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy,   10))
    table.cell(info_table, 1, 0, "VALUE",      text_color=color.yellow, text_size=size.small, bgcolor=color.new(color.navy,   10))

    // RSI row
    rsi_color = rsi_val < rsi_os ? color.lime : rsi_val > rsi_ob ? color.red : color.white
    table.cell(info_table, 0, 1, "RSI(14)",    text_color=color.white,  text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(rsi_val, "#.##"), text_color=rsi_color, text_size=size.small)

    // MACD row
    macd_color = macd_line > signal_line ? color.lime : color.red
    table.cell(info_table, 0, 2, "MACD Line",  text_color=color.white,  text_size=size.small)
    table.cell(info_table, 1, 2, str.tostring(macd_line, "#.####"), text_color=macd_color, text_size=size.small)

    // MACD Signal row
    table.cell(info_table, 0, 3, "MACD Sig",   text_color=color.white,  text_size=size.small)
    table.cell(info_table, 1, 3, str.tostring(signal_line, "#.####"), text_color=color.gray, text_size=size.small)

    // VIX row
    vix_color = vix_close > vix_high_thresh ? color.red : vix_close < vix_low_thresh ? color.lime : color.white
    table.cell(info_table, 0, 4, "VIX",        text_color=color.white,  text_size=size.small)
    table.cell(info_table, 1, 4, str.tostring(vix_close, "#.##"), text_color=vix_color, text_size=size.small)

    // Signal status
    sig_txt   = call_signal ? "🟢 CALL" : put_signal ? "🔴 PUT" : "⏳ WAIT"
    sig_color = call_signal ? color.lime  : put_signal ? color.red  : color.gray
    table.cell(info_table, 0, 5, "SIGNAL",     text_color=color.white,  text_size=size.small)
    table.cell(info_table, 1, 5, sig_txt,      text_color=sig_color,    text_size=size.small)

    // SL status
    sl_active = call_sl_condition or put_sl_condition
    table.cell(info_table, 0, 6, "STOP LOSS",  text_color=color.white,  text_size=size.small)
    table.cell(info_table, 1, 6, sl_active ? "⛔ HIT" : "✅ OK",
         text_color = sl_active ? color.red : color.lime, text_size=size.small)
````
