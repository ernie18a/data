# Dynamic Regime Matrix [Adaptive 5-Layer System]

- url: https://www.tradingview.com/script/tJJU9S3O/
- type: indicator
- pine_id: PUB;663054fd9a7a4512a6e0ae360374aefe
- version: 4.0

## Description

Title: Dynamic Regime Matrix [Adaptive 5-Layer System]

Overview:
The Dynamic Regime Matrix (DRM) is a professional-grade, non-repainting indicator designed to systematically eliminate market noise, avoid false breakouts, and capture high-probability trends. By filtering the market through 5 distinct logical layers, DRM ensures you only enter the market when conditions are heavily in your favor.

The 5-Layer Architecture:

HTF Regime Filter (Chikou & ADX): Analyzes the Higher Timeframe (HTF) momentum using Chikou Span and ADX. It classifies the market into Trend, Range, or "Storm" (extreme overextended volatility) to establish a strict directional bias.

Volatility Gate: Uses an ATR/SMA cross. The gate only opens when the market is "alive." It completely shuts down trading during dead hours, holidays, or low-liquidity chop.

Trend Confirmation: Requires a perfect EMA ribbon alignment (Short > Mid > Long) and current timeframe Chikou confirmation.

Entry Trigger: A hybrid momentum trigger using CCI zero-line/100 breaks combined with RSI hidden divergence for pinpoint entries.

Risk Management Output: Automatically calculates and plots ATR-based Stop Loss (SL) and two Take Profit (TP) levels the moment a signal fires.

Key Features:

Auto (Dynamic) Mode: Automatically adapts to market momentum. When ADX shows a strong trend (>40), the system dynamically widens TP targets, shortens the CCI trigger for faster entries, and relaxes the Volatility Gate to prevent missing massive moves.

Diagnostic Dashboard: A clean, unobtrusive UI panel shows exactly which filters are passing ("OK") or failing ("NG"), helping you understand the market context at a glance.

Alerts Ready: Get instant notifications with entry price, SL, and TP targets when all 5 layers align.

Note: This indicator strictly calculates on bar_close and does NOT repaint.

## Source Code

````pine
//@version=5
indicator("Dynamic Regime Matrix [Adaptive 5-Layer System]", overlay=true, max_lines_count=500)

// ==========================================
// [Settings] 0. System Mode
// ==========================================
sys_mode = input.string("Auto (Dynamic)", title="Parameter Mode", options=["Manual", "Auto (Dynamic)"], group="0. System Settings")

// ==========================================
// [Settings] 1. HTF Regime Filter
// ==========================================
htf = input.timeframe("15", title="Higher Timeframe (HTF)", group="1. HTF Regime Filter") 
adxlen = input.int(14, title="ADX Length", group="1. HTF Regime Filter")
storm_adx_threshold = input.int(60, title="Storm Mode: ADX Threshold", group="1. HTF Regime Filter")
range_adx_threshold = input.int(20, title="Range Mode: ADX Threshold", group="1. HTF Regime Filter")

htf_chikou_long_cond = close > close[26]
htf_chikou_short_cond = close < close[26]
htf_bias_long = request.security(syminfo.tickerid, htf, htf_chikou_long_cond)
htf_bias_short = request.security(syminfo.tickerid, htf, htf_chikou_short_cond)

[diplus, diminus, adx] = ta.dmi(adxlen, adxlen)
is_strong_trend = adx > 40
is_normal_trend = adx > 20 and adx <= 40

// ==========================================
// [Settings] 2. Volatility Gate
// ==========================================
manual_atr_sma_len = input.int(20, title="[Manual] ATR SMA Length", group="2. Volatility Gate")
storm_atr_mult = input.float(1.5, title="Storm Mode: ATR Expansion Multiplier", group="2. Volatility Gate")

active_atr_sma_len = sys_mode == "Auto (Dynamic)" ? (is_strong_trend ? 30 : 20) : manual_atr_sma_len

atr = ta.atr(14)
atr_sma = ta.sma(atr, active_atr_sma_len)
vol_gate = atr > atr_sma
storm_mode = adx > storm_adx_threshold and atr > (atr_sma * storm_atr_mult)
range_mode = adx < range_adx_threshold

regime_ok_long = htf_bias_long and not storm_mode and not range_mode
regime_ok_short = htf_bias_short and not storm_mode and not range_mode

// ==========================================
// [Settings] 3. Trend Confirmation
// ==========================================
ema_short = ta.ema(close, input.int(25, "EMA Short", group="3. Trend Confirmation"))
ema_mid = ta.ema(close, input.int(75, "EMA Mid", group="3. Trend Confirmation"))
ema_long = ta.ema(close, input.int(200, "EMA Long", group="3. Trend Confirmation"))

ema_ribbon_long = ema_short > ema_mid and ema_mid > ema_long
ema_ribbon_short = ema_short < ema_mid and ema_mid < ema_long
chikou_long = close > close[26]
chikou_short = close < close[26]
trend_ok_long = ema_ribbon_long and chikou_long
trend_ok_short = ema_ribbon_short and chikou_short

// ==========================================
// [Settings] 4. Entry Trigger
// ==========================================
manual_cci_len = input.int(11, "[Manual] CCI Length", group="4. Entry Trigger")

cci_fast = ta.cci(close, 9)
cci_norm = ta.cci(close, 11)
cci_manual = ta.cci(close, manual_cci_len)
cci = sys_mode == "Auto (Dynamic)" ? (is_strong_trend ? cci_fast : cci_norm) : cci_manual

cci_bull = ta.crossover(cci, -100) or ta.crossover(cci, 0)
cci_bear = ta.crossunder(cci,100) or ta.crossunder(cci, 0)

rsi = ta.rsi(close, 14)
hidden_bull_div = close > close[10] and rsi < rsi[10] and rsi < 50
hidden_bear_div = close < close[10] and rsi > rsi[10] and rsi > 50

trigger_long = cci_bull or hidden_bull_div
trigger_short = cci_bear or hidden_bear_div

buy_signal = regime_ok_long and vol_gate and trend_ok_long and trigger_long
sell_signal = regime_ok_short and vol_gate and trend_ok_short and trigger_short

// ==========================================
// [Settings] 5. Risk Management Output
// ==========================================
manual_sl_mult = input.float(1.5, "[Manual] SL ATR Multiplier", group="5. Risk Management")
manual_tp1_mult = input.float(2.0, "[Manual] TP1 ATR Multiplier", group="5. Risk Management")
manual_tp2_mult = input.float(3.5, "[Manual] TP2 ATR Multiplier", group="5. Risk Management")

active_sl_mult = sys_mode == "Auto (Dynamic)" ? 1.5 : manual_sl_mult
active_tp1_mult = sys_mode == "Auto (Dynamic)" ? (is_strong_trend ? 2.5 : 2.0) : manual_tp1_mult
active_tp2_mult = sys_mode == "Auto (Dynamic)" ? (is_strong_trend ? 4.5 : 3.5) : manual_tp2_mult

table_pos_input = input.string("Bottom Right", "Table Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group="Display Settings")
table_size_input = input.string("Small", "Table Text Size", options=["Tiny", "Small", "Normal", "Large"], group="Display Settings")
pos_val = table_pos_input == "Top Right" ? position.top_right : table_pos_input == "Bottom Right" ? position.bottom_right : table_pos_input == "Top Left" ? position.top_left : position.bottom_left
txt_size = table_size_input == "Tiny" ? size.tiny : table_size_input == "Small" ? size.small : table_size_input == "Normal" ? size.normal : size.large

var float sl = na
var float tp1 = na
var float tp2 = na
var string trade_type = "None"

if buy_signal
    sl := close - (atr * active_sl_mult)
    tp1 := close + (atr * active_tp1_mult)
    tp2 := close + (atr * active_tp2_mult)
    trade_type := "Long"

if sell_signal
    sl := close + (atr * active_sl_mult)
    tp1 := close - (atr * active_tp1_mult)
    tp2 := close - (atr * active_tp2_mult)
    trade_type := "Short"

plot(sl, "SL Line", color=color.new(color.red, 40), style=plot.style_linebr, linewidth=2)
plot(tp1, "TP1 Line", color=color.new(color.green, 40), style=plot.style_linebr, linewidth=1)
plot(tp2, "TP2 Line", color=color.new(color.blue, 40), style=plot.style_linebr, linewidth=1)
plotshape(buy_signal, "BUY", shape.triangleup, location.belowbar, color.blue, size=size.small, text="BUY")
plotshape(sell_signal, "SELL", shape.triangledown, location.abovebar, color.red, size=size.small, text="SELL")

// ==========================================
// [Settings] 6. Alerts
// ==========================================
if buy_signal
    alert_msg = "🟢 [BUY Signal]\nSymbol: " + syminfo.ticker + "\nPrice: " + str.tostring(close, "#.##") + "\n---\n🔴 SL: " + str.tostring(sl, "#.##") + "\n🎯 TP1: " + str.tostring(tp1, "#.##") + "\n🎯 TP2: " + str.tostring(tp2, "#.##")
    alert(alert_msg, alert.freq_once_per_bar_close)

if sell_signal
    alert_msg = "🔴 [SELL Signal]\nSymbol: " + syminfo.ticker + "\nPrice: " + str.tostring(close, "#.##") + "\n---\n🔴 SL: " + str.tostring(sl, "#.##") + "\n🎯 TP1: " + str.tostring(tp1, "#.##") + "\n🎯 TP2: " + str.tostring(tp2, "#.##")
    alert(alert_msg, alert.freq_once_per_bar_close)

// ==========================================
// Diagnostic Table
// ==========================================
var table info_table = table.new(pos_val, 2, 7, border_width=1, border_color=color.gray)

if barstate.islast
    f1 = (htf_bias_long or htf_bias_short) ? "OK" : "NG"
    f2 = vol_gate ? "OK" : "NG"
    f3 = (trend_ok_long or trend_ok_short) ? "OK" : "NG"
    
    trend_state_txt = range_mode ? "Range" : (storm_mode ? "Storm" : (is_strong_trend ? "Strong Trend" : "Normal Trend"))
    mode_color = sys_mode == "Auto (Dynamic)" ? color.new(color.orange, 0) : color.gray

    table.cell(info_table, 0, 0, "Mode [" + trend_state_txt + "]", bgcolor=mode_color, text_color=color.black, text_size=txt_size)
    table.cell(info_table, 1, 0, sys_mode == "Auto (Dynamic)" ? "AUTO" : "MANUAL", bgcolor=mode_color, text_color=color.black, text_size=txt_size)
    table.cell(info_table, 0, 1, "1. HTF Chikou", text_color=color.white, text_size=txt_size)
    table.cell(info_table, 1, 1, f1, bgcolor=f1=="OK"?color.green:color.red, text_size=txt_size)
    table.cell(info_table, 0, 2, "2. Volatility", text_color=color.white, text_size=txt_size)
    table.cell(info_table, 1, 2, f2, bgcolor=f2=="OK"?color.green:color.red, text_size=txt_size)
    table.cell(info_table, 0, 3, "3. EMA Trend", text_color=color.white, text_size=txt_size)
    table.cell(info_table, 1, 3, f3, bgcolor=f3=="OK"?color.green:color.red, text_size=txt_size)
    table.cell(info_table, 0, 4, "SL Target", text_color=color.white, text_size=txt_size)
    table.cell(info_table, 1, 4, str.tostring(sl, "#.###"), text_color=color.white, text_size=txt_size)
    table.cell(info_table, 0, 5, "TP1 (x" + str.tostring(active_tp1_mult) + ")", text_color=color.white, text_size=txt_size)
    table.cell(info_table, 1, 5, str.tostring(tp1, "#.###"), text_color=color.white, text_size=txt_size)
    table.cell(info_table, 0, 6, "TP2 (x" + str.tostring(active_tp2_mult) + ")", text_color=color.white, text_size=txt_size)
    table.cell(info_table, 1, 6, str.tostring(tp2, "#.###"), text_color=color.white, text_size=txt_size)
````
