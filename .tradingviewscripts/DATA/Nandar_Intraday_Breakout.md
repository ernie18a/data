<!-- tradingview-pine-id: PUB;e432215d573b4b8396c373619e924d37 -->
<!-- tradingviewscripts-format: 1 -->
# Nandar Intraday Breakout

Source: https://www.tradingview.com/script/IIYnM1eN-Walkerz/

## Description

The Walkerz Strategy is an algorithmic trading system based on Price Action and momentum, specifically designed for high-volatility instruments like XAUUSD and BTCUSD. This strategy focuses on detecting key level breakouts combined with a multi-layered trend confirmation filter to minimize false signals and fake-outs.

Underlying Concepts & How It Works

Multi-Timeframe (MTF) Approach: The strategy relies heavily on dual time frame analysis. Traders are expected to use a Higher Time Frame (HTF), such as H1, H4, or Daily, to map out the primary trend and identify solid structural Resistance (A) and Support (B) levels. The script is then applied to a Lower Time Frame (LTF), such as M1, M5, or M15, to detect the actual breakout from those predefined HTF levels.

Fair Value Gap (FVG) Confirmation: A simple breakout is not enough. Once the price breaks the HTF resistance/support, the script waits for a valid Fair Value Gap (Bullish FVG for long, Bearish FVG for short) to form before executing the entry.

Momentum Filter (ADX): To avoid trading in choppy conditions, the Average Directional Index (ADX) is used as a filter. Trades are only validated if the trend is strong enough or if the market conditions align perfectly with the breakout direction.

Dynamic Risk Management & Backtest Properties
To comply with realistic trading expectations and avoid misleading results, the default backtest properties are configured as follows:

Initial Capital: $25,000.

Risk Per Trade: Fixed at $200 per trade. This represents only a 0.8% risk of the initial equity, ensuring sustainable scaling and adhering to the standard 1-2% maximum risk rule.

Lot Size: Calculated dynamically based on the distance between the entry price and the Stop Loss to ensure the maximum loss never exceeds the defined $200.

Commission & Slippage: Set to $1 cash per order with a 2-tick slippage to simulate realistic live market executions.

Take Profit: Calculated dynamically using Fibonacci extension zones from the breakout range.

---

## Source Code

````pine
//@version=6
strategy("Nandar Intraday Breakout", overlay=true, pyramiding=1, calc_on_every_tick=true, initial_capital=25000, margin_long=0.1, margin_short=0.1, commission_type=strategy.commission.cash_per_order, commission_value=1, slippage=2, max_lines_count=500)

// === Input Manajemen Risiko ===
risk_usd = input.float(600.0, "Maksimal Loss (USD)", group="Manajemen Risiko")
rr_ratio = input.float(2.0, "Risk:Reward Ratio", minval=0.1, step=0.5, group="Manajemen Risiko")
lev_xau = input.float(20.0, "Leverage XAUUSD (1:X)", group="Manajemen Risiko")
lev_btc = input.float(2.0, "Leverage BTCUSD (1:X)", group="Manajemen Risiko")

// === Input XAUUSD ===
xau_res = input.float(4327.745, "Resistance (A) XAU", group="XAUUSD")
xau_sup = input.float(4301.015, "Support (B) XAU", group="XAUUSD")

// === Input BTCUSD ===
btc_res = input.float(64944.16, "Resistance (A) BTC", group="BTCUSD")
btc_sup = input.float(64087.41, "Support (B) BTC", group="BTCUSD")

// === Deteksi Pair Otomatis ===
is_xau = str.contains(syminfo.ticker, "XAUUSD")
is_btc = str.contains(syminfo.ticker, "BTCUSD")

// Assign nilai sesuai chart yang aktif
harga_a = is_xau ? xau_res : (is_btc ? btc_res : na)
harga_b = is_xau ? xau_sup : (is_btc ? btc_sup : na)

// === Jendela Waktu ===
waktu_mulai = input.time(timestamp("2026-08-07T19:40:00"), "Mulai")
waktu_selesai = input.time(timestamp("2027-01-01T06:59:00"), "Selesai")
in_window = time >= waktu_mulai and time <= waktu_selesai

// === ZONA BAHAYA (NO-TRADE ZONES) - HANYA VISUAL ===
// Membaca waktu secara paksa menggunakan zona waktu GMT+8 (WITA)
jam_sekarang = hour(time, "GMT+8")

is_danger_zone = (jam_sekarang == 1) or                                 // 01:00 - 01:59 (Malam larut)
                 (jam_sekarang >= 4 and jam_sekarang <= 5) or           // 04:00 - 05:59 (Sesi mati)
                 (jam_sekarang == 8) or                                 // 08:00 - 08:59 (Jebakan Asia)
                 (jam_sekarang == 10) or                                // 10:00 - 10:59 (Transisi tren)
                 (jam_sekarang >= 14 and jam_sekarang <= 18) or         // 14:00 - 18:59 (ZONA BAHAYA EROPA)
                 (jam_sekarang == 20)                                   // 20:00 - 20:59 (Pre-Market NY)

// Visualisasi Latar Belakang Merah Transparan di Zona Bahaya
bgcolor(is_danger_zone ? color.new(color.red, 93) : na, title="Zona Bahaya")

// === Fibonacci Factor ===
fib_factor = input.float(0.618, "Fibonacci Factor", options=[0.6, 0.618, 0.786])

// === ADX untuk Deteksi Kondisi Pasar ===
adx_len = input.int(14, "ADX Length")
adx_smoothing = input.int(14, "ADX Smoothing")
adx_threshold = input.float(30.0, "ADX Threshold")

[di_plus, di_minus, adx] = ta.dmi(adx_len, adx_smoothing)

is_ranging = adx <= adx_threshold
is_trending = adx > adx_threshold
trend_bullish = di_plus > di_minus and is_trending
trend_bearish = di_minus > di_plus and is_trending

// === State Mesin & Tracker Data Panel ===
var int state = 0
var float curr_entry = na
var float curr_tp = na
var float curr_sl = na
var float curr_lot = na

if strategy.position_size == 0
    state := 0
    curr_entry := na
    curr_tp := na
    curr_sl := na
    curr_lot := na

// Deteksi Breakout Level (Tanpa filter larangan entry)
if state == 0 and in_window and not na(harga_a) and not na(harga_b) and harga_a > harga_b
    if close > harga_a
        state := 2
    else if close < harga_b
        state := -2

// === FVG ===
bullish_fvg = high[2] < low[0] and close[1] > open[1]
bearish_fvg = low[2] > high[0] and close[1] < open[1]

// === Garis Visual Minimalis ===
var line tp_line = na
var line sl_line = na
var line en_line = na
var line mid_sl_line = na

if strategy.position_size != 0
    line.set_x2(tp_line, bar_index)
    line.set_x2(sl_line, bar_index)
    line.set_x2(en_line, bar_index)
    line.set_x2(mid_sl_line, bar_index)

// === Eksekusi Sinyal ===
if state == 2 and bearish_fvg and strategy.position_size == 0
    if (is_ranging or trend_bearish)
        range_sell = high - harga_b
        tp_sell = high - range_sell * fib_factor
        reward = close - tp_sell
        
        if reward > 0
            risk_dist = reward / rr_ratio
            sl_sell = close + risk_dist
            mid_sl_sell = (close + sl_sell) / 2
            
            // Kalkulasi Lot & Filter Leverage Dinamis
            qty_tv = risk_usd / risk_dist
            active_lev = is_xau ? lev_xau : (is_btc ? lev_btc : 1.0)
            max_qty_allowed = (strategy.equity * active_lev) / close
            final_qty = math.min(qty_tv, max_qty_allowed)
            lot_size = final_qty / (is_xau ? 100 : 1)

            strategy.entry("Jual", strategy.short, qty=final_qty, alert_message='{"Aksi":"SELL","TP":'+str.tostring(tp_sell)+',"SL":'+str.tostring(sl_sell)+'}')
            strategy.exit("Exit Jual", "Jual", limit=tp_sell, stop=sl_sell, alert_message='{"Aksi":"TUTUP SELL"}')

            // Simpan Data
            curr_entry := close
            curr_tp := tp_sell
            curr_sl := sl_sell
            curr_lot := lot_size

            // Gambar Garis Minimalis
            en_line := line.new(bar_index, close, bar_index, close, color=#d500f9, style=line.style_solid, width=2)
            tp_line := line.new(bar_index, tp_sell, bar_index, tp_sell, color=#00e676, style=line.style_dashed, width=2)
            sl_line := line.new(bar_index, sl_sell, bar_index, sl_sell, color=#ff1744, style=line.style_dashed, width=2)
            mid_sl_line := line.new(bar_index, mid_sl_sell, bar_index, mid_sl_sell, color=color.orange, style=line.style_dashed, width=2)

            state := 3 

if state == -2 and bullish_fvg and strategy.position_size == 0
    if (is_ranging or trend_bullish)
        range_buy = harga_a - low
        tp_buy = low + range_buy * fib_factor
        reward = tp_buy - close
        
        if reward > 0
            risk_dist = reward / rr_ratio
            sl_buy = close - risk_dist
            mid_sl_buy = (close + sl_buy) / 2
            
            // Kalkulasi Lot & Filter Leverage Dinamis
            qty_tv = risk_usd / risk_dist
            active_lev = is_xau ? lev_xau : (is_btc ? lev_btc : 1.0)
            max_qty_allowed = (strategy.equity * active_lev) / close
            final_qty = math.min(qty_tv, max_qty_allowed)
            lot_size = final_qty / (is_xau ? 100 : 1)

            strategy.entry("Beli", strategy.long, qty=final_qty, alert_message='{"Aksi":"BUY","TP":'+str.tostring(tp_buy)+',"SL":'+str.tostring(sl_buy)+'}')
            strategy.exit("Exit Beli", "Beli", limit=tp_buy, stop=sl_buy, alert_message='{"Aksi":"TUTUP BUY"}')

            // Simpan Data
            curr_entry := close
            curr_tp := tp_buy
            curr_sl := sl_buy
            curr_lot := lot_size

            // Gambar Garis Minimalis
            en_line := line.new(bar_index, close, bar_index, close, color=#d500f9, style=line.style_solid, width=2)
            tp_line := line.new(bar_index, tp_buy, bar_index, tp_buy, color=#00e676, style=line.style_dashed, width=2)
            sl_line := line.new(bar_index, sl_buy, bar_index, sl_buy, color=#ff1744, style=line.style_dashed, width=2)
            mid_sl_line := line.new(bar_index, mid_sl_buy, bar_index, mid_sl_buy, color=color.orange, style=line.style_dashed, width=2)

            state := -3 

// === TABEL DASHBOARD ===
var table dash = table.new(position.bottom_right, columns=2, rows=6, bgcolor=color.new(#1e1e1e, 10), border_width=1, border_color=color.new(color.gray, 70))

if barstate.islast
    table.cell(dash, 0, 0, "STATUS", text_color=color.white, bgcolor=color.new(color.gray, 80))
    if strategy.position_size > 0
        table.cell(dash, 1, 0, "BUY ACTIVE 🟢", text_color=#00e676, bgcolor=color.new(color.gray, 80))
    else if strategy.position_size < 0
        table.cell(dash, 1, 0, "SELL ACTIVE 🔴", text_color=#ff1744, bgcolor=color.new(color.gray, 80))
    else
        table.cell(dash, 1, 0, is_danger_zone ? "DANGER ZONE 🚫" : "WAITING ⏳", text_color=is_danger_zone ? color.red : color.gray, bgcolor=color.new(color.gray, 80))
    
    table.cell(dash, 0, 1, "ENTRY PRICE", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 1, na(curr_entry) ? "-" : str.tostring(curr_entry, "#.##"), text_color=#d500f9, text_halign=text.align_right)
    
    table.cell(dash, 0, 2, "TAKE PROFIT", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 2, na(curr_tp) ? "-" : str.tostring(curr_tp, "#.##"), text_color=#00e676, text_halign=text.align_right)
    
    table.cell(dash, 0, 3, "STOP LOSS", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 3, na(curr_sl) ? "-" : str.tostring(curr_sl, "#.##"), text_color=#ff1744, text_halign=text.align_right)
    
    table.cell(dash, 0, 4, "LOT SIZE", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 4, na(curr_lot) ? "-" : str.tostring(curr_lot, "#.##"), text_color=color.yellow, text_halign=text.align_right)
    
    table.cell(dash, 0, 5, "RISK : REWARD", text_color=color.white, text_halign=text.align_left)
    table.cell(dash, 1, 5, strategy.position_size != 0 ? "1:" + str.tostring(rr_ratio) : "-", text_color=color.white, text_halign=text.align_right)

// === Visual ADX ===
hline(adx_threshold, "ADX Threshold", color=color.gray, linestyle=hline.style_dashed)
plot(adx, "ADX", color=color.yellow, display=display.status_line)
````
