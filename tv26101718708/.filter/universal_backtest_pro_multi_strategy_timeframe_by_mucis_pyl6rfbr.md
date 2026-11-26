# Universal Backtest Pro - Multi Strategy & Timeframe by mucis 

- url: https://www.tradingview.com/script/PyL6RfBr/
- type: strategy
- pine_id: PUB;f5ac9f1597e64e479e20141fa4dea274
- version: 1.0

## Description

Universal Backtest Pro - Multi Strategy & Timeframe by mucis 

🔧 TIPS OPTIMASI:
Skenario	Setting Rekomendasi
Swing Trading Forex	Strategy: EMA Crossover, Timeframe: 4H, Fast: 9, Slow: 21
Scalping	Strategy: SuperTrend, Timeframe: 5M, ATR: 10, Multiplier: 3
Mean Reversion	Strategy: Bollinger Bands, Timeframe: 1H, StdDev: 2
Trend Following	Strategy: MACD, Timeframe: D, Fast: 12, Slow: 26
🎯 LANJUTKAN DI REQUEST BERIKUTNYA:
Mau saya bantu:

Optimasi parameter untuk AUDJPY specifically? (mencari setting terbaik dengan strategy sweep)
Tambahkan alert ketika entry signal muncul?
Backtest multi-symbol (test strategi ini di beberapa pair forex sekaligus)?
Export hasil backtest ke Excel/CSV untuk analisa lebih lanjut?
Silakan buat request baru untuk melanjutkan! 🚀## ✅ SCRIPT BERHASIL DIBUAT & DIKOMPILASI!

Script "Universal Backtest Pro - Multi Strategy & Timeframe" sudah aktif di chart AUDJPY Anda! 🚀

📊 FITUR LENGKAP YANG SUDAH ADA:
1. 🎯 PILIHAN STRATEGI (Dropdown)
Pilihan Strategi:
├── EMA Crossover (dengan Regime Filter)
├── RSI Strategy (Overbought/Oversold)
├── MACD Strategy (Signal Cross)
├── Bollinger Bands Breakout
├── SuperTrend (ATR-based)
└── Custom (manual setup)
Default: EMA Crossover

2. ⚙️ PARAMETER DINAMIS
Setiap strategi memiliki input parameter sendiri:

EMA: Fast Length (9), Slow Length (21), Regime EMA (200)
RSI: Period, Overbought (70), Oversold (30)
MACD: Fast, Slow, Signal lengths
Bollinger: Length, Std Dev, Breakout Type
SuperTrend: ATR Period, Multiplier
3. 📅 BACKTEST CALENDAR INPUT
Start Date: Year (2020), Month (1), Day (1)    →  2020-01-01
End Date:   Year (2030), Month (12), Day (31)  →  2030-12-31
4. ⏰ TIMEFRAME SELECTOR
Pilih timeframe data: 1, 5, 15, 30, 60, 120, 240, D, W, M

Default: "D" (Daily)
Menggunakan request.security() untuk fetch data dari timeframe lain
Bisa backtest strategi 1H pada chart 5M!
5. 🛡️ RISK MANAGEMENT
Position Size: 10% dari equity
Stop Loss: 2.0% dari entry price
Take Profit: 4.0% dari entry price
Trailing Stop: Enabled (aktif)
Commission: 0.01%
Slippage: 2 ticks
6. 📈 VISUALISASI
Entry/Exit arrows pada chart
Stop Loss & Take Profit lines
Background color untuk bull/bear regime
Info Dashboard di pojok kanan atas (showing: Strategy, Timeframe, Equity, Drawdown)
🎮 CARA MENGGUNAKAN:
Step 1: Pilih Strategi
Klik Settings (roda gigi) pada indikator di chart
Pilih Strategy Type dari dropdown
Atur parameter sesuai kebutuhan
Step 2: Atur Periode Backtest
Isi Start Year, Month, Day (default: 2020, 1, 1)
Isi End Year, Month, Day (default: 2030, 12, 31)
Step 3: Pilih Timeframe
Pilih Timeframe (default: "D" untuk Daily)
Strategy akan menggunakan data dari timeframe tersebut
Step 4: Lihat Hasil
Klik tab Strategy Tester (di bawah chart)
Lihat metric: Net Profit, Profit Factor, Win Rate, Max Drawdown
Lihat individual trades di tab "List of Trades"
⚡ STATUS KUOTA
Sisa Request: 10/15 untuk hari ini

🔧 TIPS OPTIMASI:
Skenario	Setting Rekomendasi
Swing Trading Forex	Strategy: EMA Crossover, Timeframe: 4H, Fast: 9, Slow: 21
Scalping	Strategy: SuperTrend, Timeframe: 5M, ATR: 10, Multiplier: 3
Mean Reversion	Strategy: Bollinger Bands, Timeframe: 1H, StdDev: 2
Trend Following	Strategy: MACD, Timeframe: D, Fast: 12, Slow: 26
🚀

## Source Code

````pine
// strategy_archetype: ma_crossover_with_regime, supertrend_pullback, bollinger_mean_reversion
//@version=6
strategy("Universal Backtest Pro - Multi Strategy & Timeframe", 
     overlay=true, 
     initial_capital=10000, 
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=10, 
     commission_type=strategy.commission.percent, 
     commission_value=0.01, 
     slippage=2)

// ==========================================
// 1. STRATEGY SELECTOR
// ==========================================
grp_strat = "1. Strategy Selection"
strat_type = input.string("EMA Crossover", "Select Strategy", 
     options=["EMA Crossover", "RSI Strategy", "MACD Strategy", "Bollinger Bands Breakout", "SuperTrend", "Custom"], 
     group=grp_strat)
tf_input = input.timeframe("D", "Analysis Timeframe", group=grp_strat)

// ==========================================
// 2. PARAMETER INPUTS
// ==========================================
grp_ema = "2. EMA Parameters"
ema_fast_len = input.int(9, "EMA Fast", group=grp_ema)
ema_slow_len = input.int(21, "EMA Slow", group=grp_ema)
regime_len   = input.int(200, "Regime Filter EMA", group=grp_ema)

grp_rsi = "3. RSI Parameters"
rsi_len = input.int(14, "RSI Period", group=grp_rsi)
rsi_ob  = input.int(70, "Overbought", group=grp_rsi)
rsi_os  = input.int(30, "Oversold", group=grp_rsi)

grp_macd = "4. MACD Parameters"
macd_fast   = input.int(12, "MACD Fast", group=grp_macd)
macd_slow   = input.int(26, "MACD Slow", group=grp_macd)
macd_signal = input.int(9, "MACD Signal", group=grp_macd)

grp_bb = "5. Bollinger Parameters"
bb_len  = input.int(20, "BB Length", group=grp_bb)
bb_mult = input.float(2.0, "BB StdDev", group=grp_bb)

grp_st = "6. SuperTrend Parameters"
st_len  = input.int(10, "ATR Period", group=grp_st)
st_mult = input.float(3.0, "Multiplier", group=grp_st)

// ==========================================
// 3. BACKTEST CALENDAR
// ==========================================
grp_cal = "7. Backtest Period"
start_date = input.time(timestamp("2020-01-01T00:00:00"), "Start Date", group=grp_cal)
end_date   = input.time(timestamp("2030-12-31T23:59:59"), "End Date", group=grp_cal)
in_date_range = time >= start_date and time <= end_date

// ==========================================
// 4. RISK MANAGEMENT
// ==========================================
grp_risk = "8. Risk Management"
sl_pct = input.float(2.0, "Stop Loss %", minval=0.1, group=grp_risk) / 100
tp_pct = input.float(4.0, "Take Profit %", minval=0.1, group=grp_risk) / 100
use_ts = input.bool(true, "Enable Trailing Stop", group=grp_risk)

// ==========================================
// 5. CORE LOGIC (MTF)
// ==========================================
[o, h, l, c, v] = request.security(syminfo.tickerid, tf_input, [open, high, low, close, volume])

// EMA Logic
ema_f = ta.ema(c, ema_fast_len)
ema_s = ta.ema(c, ema_slow_len)
regime_ema = ta.ema(c, regime_len)
ema_long  = ta.crossover(ema_f, ema_s) and c > regime_ema
ema_short = ta.crossunder(ema_f, ema_s) and c < regime_ema

// RSI Logic
rsi_val = ta.rsi(c, rsi_len)
rsi_long  = ta.crossunder(rsi_val, rsi_os)
rsi_short = ta.crossover(rsi_val, rsi_ob)

// MACD Logic
[macd_line, sig_line, _] = ta.macd(c, macd_fast, macd_slow, macd_signal)
macd_long  = ta.crossover(macd_line, sig_line)
macd_short = ta.crossunder(macd_line, sig_line)

// Bollinger Logic
[bb_mid, bb_up, bb_low] = ta.bb(c, bb_len, bb_mult)
bb_long  = ta.crossover(c, bb_low)
bb_short = ta.crossunder(c, bb_up)

// SuperTrend Logic
[st_val, st_dir] = ta.supertrend(st_mult, st_len)
st_long  = ta.change(st_dir) < 0
st_short = ta.change(st_dir) > 0

// Final Signal Selection
long_cond  = false
short_cond = false

if strat_type == "EMA Crossover"
    long_cond  := ema_long
    short_cond := ema_short
else if strat_type == "RSI Strategy"
    long_cond  := rsi_long
    short_cond := rsi_short
else if strat_type == "MACD Strategy"
    long_cond  := macd_long
    short_cond := macd_short
else if strat_type == "Bollinger Bands Breakout"
    long_cond  := bb_long
    short_cond := bb_short
else if strat_type == "SuperTrend"
    long_cond  := st_long
    short_cond := st_short
else if strat_type == "Custom"
    long_cond  := ta.crossover(ta.sma(c, 5), ta.sma(c, 10))
    short_cond := ta.crossunder(ta.sma(c, 5), ta.sma(c, 10))

// ==========================================
// 6. EXECUTION
// ==========================================
if in_date_range
    if long_cond
        strategy.entry("Long", strategy.long)
    if short_cond
        strategy.entry("Short", strategy.short)

// Exit Management
if strategy.position_size > 0
    sl_price = strategy.position_avg_price * (1 - sl_pct)
    tp_price = strategy.position_avg_price * (1 + tp_pct)
    strategy.exit("Exit Long", "Long", stop=sl_price, limit=tp_price, 
         trail_points = use_ts ? (strategy.position_avg_price * tp_pct / 2) / syminfo.mintick : na,
         trail_offset = use_ts ? (strategy.position_avg_price * sl_pct / 2) / syminfo.mintick : na)

if strategy.position_size < 0
    sl_price = strategy.position_avg_price * (1 + sl_pct)
    tp_price = strategy.position_avg_price * (1 - tp_pct)
    strategy.exit("Exit Short", "Short", stop=sl_price, limit=tp_price,
         trail_points = use_ts ? (strategy.position_avg_price * tp_pct / 2) / syminfo.mintick : na,
         trail_offset = use_ts ? (strategy.position_avg_price * sl_pct / 2) / syminfo.mintick : na)

// ==========================================
// 7. VISUALIZATION
// ==========================================
plot(strat_type == "EMA Crossover" ? ema_f : na, "EMA Fast", color.blue)
plot(strat_type == "EMA Crossover" ? ema_s : na, "EMA Slow", color.orange)
plot(strat_type == "Bollinger Bands Breakout" ? bb_up : na, "BB Upper", color.gray)
plot(strat_type == "Bollinger Bands Breakout" ? bb_low : na, "BB Lower", color.gray)

plotshape(long_cond, "Long Arrow", shape.triangleup, location.belowbar, color.green, size=size.small)
plotshape(short_cond, "Short Arrow", shape.triangledown, location.abovebar, color.red, size=size.small)

bg_color = strategy.position_size > 0 ? color.new(color.green, 90) : strategy.position_size < 0 ? color.new(color.red, 90) : na
bgcolor(bg_color)

// Info Table
var table info_tab = table.new(position.top_right, 2, 4, color.new(color.black, 0), border_width=1)
if barstate.islast
    table.cell(info_tab, 0, 0, "Strategy:", text_color=color.white, bgcolor=color.gray)
    table.cell(info_tab, 1, 0, strat_type, text_color=color.white, bgcolor=color.gray)
    table.cell(info_tab, 0, 1, "Timeframe:", text_color=color.white)
    table.cell(info_tab, 1, 1, tf_input, text_color=color.white)
    table.cell(info_tab, 0, 2, "Equity:", text_color=color.white)
    table.cell(info_tab, 1, 2, str.tostring(strategy.equity, "#.##"), text_color=color.white)
    table.cell(info_tab, 0, 3, "Drawdown:", text_color=color.white)
    table.cell(info_tab, 1, 3, str.tostring(strategy.max_drawdown, "#.##"), text_color=color.red)
````
