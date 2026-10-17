# Auto-Logger Multi-Timeframe Analyzer by mucis

- url: https://www.tradingview.com/script/AiG3pP7V/
- type: indicator
- pine_id: PUB;b9355bd2b9b14eb2b32fa194f343505a
- version: 1.0

## Description

multi time frame  untuk cek history backtest bahkan winrate dari tiap indikator agar kita bisa tau win dan lose tanpa perlu forward test yang lama

## Source Code

````pine
//@version=6
indicator("Auto-Logger Multi-Timeframe Analyzer", shorttitle="AL-MTF", overlay=false, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

// ══════════════════════════════════════════════════════════════════════════════
// INPUT PARAMETERS
// ══════════════════════════════════════════════════════════════════════════════
grp_signal = "⚙️ Signal Settings"
ema_fast_len = input.int(9, "EMA Fast Length", group=grp_signal, minval=1)
ema_slow_len = input.int(21, "EMA Slow Length", group=grp_signal, minval=1)
rsi_len = input.int(14, "RSI Length", group=grp_signal, minval=1)
rsi_overbought = input.int(70, "RSI Overbought", group=grp_signal, minval=50, maxval=100)
rsi_oversold = input.int(30, "RSI Oversold", group=grp_signal, minval=0, maxval=50)
vol_len = input.int(20, "Volume MA Length", group=grp_signal, minval=1)

grp_mtf = "📊 Multi-Timeframe Settings"
timeframes = input.string("1,5,15,30,60,240,D,W,M", "Timeframes (comma separated)", group=grp_mtf)
lookback_bars = input.int(500, "Lookback Bars for Analysis", group=grp_mtf, minval=100, maxval=5000)

grp_display = "🎨 Display Settings"
show_table = input.bool(true, "Show Statistics Table", group=grp_display)
show_best_tf = input.bool(true, "Highlight Best Timeframe", group=grp_display)
show_signals = input.bool(true, "Show Current Signals", group=grp_display)

// ══════════════════════════════════════════════════════════════════════════════
// FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// Parse timeframes
parse_timeframes(tf_string) =>
    string[] tfs = str.split(tf_string, ",")
    tfs

// Signal generation function
generate_signal(src_open, src_high, src_low, src_close, src_volume) =>
    ema_fast = ta.ema(src_close, ema_fast_len)
    ema_slow = ta.ema(src_close, ema_slow_len)
    rsi = ta.rsi(src_close, rsi_len)
    vol_ma = ta.sma(src_volume, vol_len)
    vol_filter = src_volume > vol_ma
    
    bullish_cross = ta.crossover(ema_fast, ema_slow)
    bearish_cross = ta.crossunder(ema_fast, ema_slow)
    
    valid_long = bullish_cross and rsi < rsi_overbought and vol_filter
    valid_short = bearish_cross and rsi > rsi_oversold and vol_filter
    
    [valid_long, valid_short, ema_fast, ema_slow, rsi]

// Backtest calculation function
calculate_backtest(src_open, src_high, src_low, src_close, lookback) =>
    var float total_profit = 0.0
    var float total_loss = 0.0
    var int wins = 0
    var int losses = 0
    var float max_equity = 0.0
    var float max_dd = 0.0
    var float current_equity = 0.0
    var float entry_price = 0.0
    var int position = 0
    
    [long_signal, short_signal, _, _, _] = generate_signal(src_open, src_high, src_low, src_close, volume)
    
    if long_signal and position != 1
        if position == -1
            trade_pnl = (entry_price - src_close) / entry_price * 100
            if trade_pnl > 0
                wins += 1
                total_profit += trade_pnl
            else
                losses += 1
                total_loss += math.abs(trade_pnl)
            current_equity += trade_pnl
        
        position := 1
        entry_price := src_close
    
    if short_signal and position != -1
        if position == 1
            trade_pnl = (src_close - entry_price) / entry_price * 100
            if trade_pnl > 0
                wins += 1
                total_profit += trade_pnl
            else
                losses += 1
                total_loss += math.abs(trade_pnl)
            current_equity += trade_pnl
        
        position := -1
        entry_price := src_close
    
    if current_equity > max_equity
        max_equity := current_equity
    
    drawdown = max_equity - current_equity
    if drawdown > max_dd
        max_dd := drawdown
    
    total_trades = wins + losses
    win_rate = total_trades > 0 ? (wins / total_trades) * 100 : 0.0
    profit_factor = total_loss > 0 ? total_profit / total_loss : 0.0
    net_profit = total_profit - total_loss
    
    [total_trades, win_rate, profit_factor, net_profit, max_dd, wins, losses]

// ══════════════════════════════════════════════════════════════════════════════
// MAIN CALCULATION
// ══════════════════════════════════════════════════════════════════════════════

[cur_trades, cur_wr, cur_pf, cur_np, cur_dd, cur_wins, cur_losses] = calculate_backtest(open, high, low, close, lookback_bars)

string[] tf_list = parse_timeframes(timeframes)

var float[] tf_trades = array.new_float(0)
var float[] tf_winrate = array.new_float(0)
var float[] tf_pf = array.new_float(0)
var float[] tf_netprofit = array.new_float(0)
var float[] tf_drawdown = array.new_float(0)
var string[] tf_names = array.new_string(0)

if barstate.islast
    array.clear(tf_trades)
    array.clear(tf_winrate)
    array.clear(tf_pf)
    array.clear(tf_netprofit)
    array.clear(tf_drawdown)
    array.clear(tf_names)
    
    for i = 0 to array.size(tf_list) - 1
        tf = array.get(tf_list, i)
        array.push(tf_names, tf)
        
        [tf_open, tf_high, tf_low, tf_close, tf_vol] = request.security(syminfo.tickerid, tf, [open, high, low, close, volume], gaps=barmerge.gaps_off)
        
        [trades, wr, pf, np, dd, _, _] = calculate_backtest(tf_open, tf_high, tf_low, tf_close, lookback_bars)
        
        array.push(tf_trades, float(trades))
        array.push(tf_winrate, wr)
        array.push(tf_pf, pf)
        array.push(tf_netprofit, np)
        array.push(tf_drawdown, dd)

// ══════════════════════════════════════════════════════════════════════════════
// VISUALIZATION - TABLE
// ══════════════════════════════════════════════════════════════════════════════

var int best_idx = 0
var float best_pf = 0.0

if barstate.islast
    for i = 0 to array.size(tf_pf) - 1
        current_pf = array.get(tf_pf, i)
        if current_pf > best_pf
            best_pf := current_pf
            best_idx := i

if show_table and barstate.islast
    var tbl = table.new(position.top_right, 6, 11, bgcolor=color.black, border_width=1, border_color=color.gray)
    
    table.cell(tbl, 0, 0, "Timeframe", text_color=color.white, bgcolor=color.navy)
    table.cell(tbl, 1, 0, "Trades", text_color=color.white, bgcolor=color.navy)
    table.cell(tbl, 2, 0, "Win Rate", text_color=color.white, bgcolor=color.navy)
    table.cell(tbl, 3, 0, "Profit Factor", text_color=color.white, bgcolor=color.navy)
    table.cell(tbl, 4, 0, "Net Profit %", text_color=color.white, bgcolor=color.navy)
    table.cell(tbl, 5, 0, "Max DD %", text_color=color.white, bgcolor=color.navy)
    
    for i = 0 to array.size(tf_names) - 1
        tf_name = array.get(tf_names, i)
        trades = array.get(tf_trades, i)
        wr = array.get(tf_winrate, i)
        pf = array.get(tf_pf, i)
        np = array.get(tf_netprofit, i)
        dd = array.get(tf_drawdown, i)
        
        is_best = (i == best_idx and pf > 1.0)
        row_color = is_best ? color.new(color.green, 70) : (i % 2 == 0 ? color.new(color.gray, 90) : color.new(color.gray, 80))
        
        wr_color = wr > 50 ? color.green : wr > 40 ? color.yellow : color.red
        pf_color = pf > 1.5 ? color.green : pf > 1.0 ? color.yellow : color.red
        np_color = np > 0 ? color.green : color.red
        dd_color = dd < 10 ? color.green : dd < 20 ? color.yellow : color.red
        
        table.cell(tbl, 0, i + 1, tf_name, text_color=color.white, bgcolor=row_color)
        table.cell(tbl, 1, i + 1, str.tostring(trades, "#"), text_color=color.white, bgcolor=row_color)
        table.cell(tbl, 2, i + 1, str.tostring(wr, "#.#") + "%", text_color=wr_color, bgcolor=row_color)
        table.cell(tbl, 3, i + 1, str.tostring(pf, "#.##"), text_color=pf_color, bgcolor=row_color)
        table.cell(tbl, 4, i + 1, str.tostring(np, "#.##") + "%", text_color=np_color, bgcolor=row_color)
        table.cell(tbl, 5, i + 1, str.tostring(dd, "#.##") + "%", text_color=dd_color, bgcolor=row_color)
    
    table.cell(tbl, 0, 10, "CURRENT", text_color=color.yellow, bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 1, 10, str.tostring(cur_trades, "#"), text_color=color.white, bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 2, 10, str.tostring(cur_wr, "#.#") + "%", text_color=cur_wr > 50 ? color.green : color.red, bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 3, 10, str.tostring(cur_pf, "#.##"), text_color=cur_pf > 1.0 ? color.green : color.red, bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 4, 10, str.tostring(cur_np, "#.##") + "%", text_color=cur_np > 0 ? color.green : color.red, bgcolor=color.new(color.purple, 50))
    table.cell(tbl, 5, 10, str.tostring(cur_dd, "#.##") + "%", text_color=cur_dd < 20 ? color.green : color.red, bgcolor=color.new(color.purple, 50))

// ══════════════════════════════════════════════════════════════════════════════
// CURRENT TIMEFRAME SIGNAL DISPLAY
// ══════════════════════════════════════════════════════════════════════════════

[long_sig, short_sig, ema_f, ema_s, rsi_val] = generate_signal(open, high, low, close, volume)

plot(ema_f, "EMA Fast", color=color.new(color.blue, 0), linewidth=2, display = show_signals ? display.all : display.none)
plot(ema_s, "EMA Slow", color=color.new(color.orange, 0), linewidth=2, display = show_signals ? display.all : display.none)

plotshape(long_sig, "Long Signal", shape.triangleup, location.belowbar, color.green, size=size.small, display = show_signals ? display.all : display.none)
plotshape(short_sig, "Short Signal", shape.triangledown, location.abovebar, color.red, size=size.small, display = show_signals ? display.all : display.none)

trend_bull = ema_f > ema_s
trend_bear = ema_f < ema_s
bgcolor(show_signals and trend_bull ? color.new(color.green, 90) : show_signals and trend_bear ? color.new(color.red, 90) : na)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════

[long_now, short_now, _, _, _] = generate_signal(open, high, low, close, volume)

alertcondition(long_now, "MTF Long Signal", "🟢 Long Signal Detected on {{ticker}} - {{timeframe}}")
alertcondition(short_now, "MTF Short Signal", "🔴 Short Signal Detected on {{ticker}} - {{timeframe}}")

if barstate.islast
    var label info_label = na
    label.delete(info_label)
    
    info_text = str.format("📊 Auto-Logger MTF Analysis\nCurrent TF: {0}\nBest TF: {1} (PF: {2})\nTotal Analysis TFs: {3}", timeframe.period, array.size(tf_names) > 0 ? array.get(tf_names, best_idx) : "N/A", str.tostring(best_pf, "#.##"), str.tostring(array.size(tf_names)))
    
    info_label := label.new(bar_index, high, info_text, 
     color=color.black, 
     textcolor=color.white,
     style=label.style_label_lower_right,
     size=size.small)

// ══════════════════════════════════════════════════════════════════════════════
// END OF SCRIPT
// ══════════════════════════════════════════════════════════════════════════════
````
