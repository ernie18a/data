# Gemini Quant OS - Multiple Edge

- url: https://www.tradingview.com/script/GWnexbj8/
- type: indicator
- pine_id: PUB;0bc300fcc85444ecab93f2b24f1e59a9
- version: 1.0

## Description

Gemini Quant OS — Multiple Edge

Overview

Gemini Quant OS — Multiple Edge is a multi-factor technical framework designed to combine several analytical components into a structured market analysis model.

This script is part of the broader Gemini Quant OS ecosystem.


---

Core Concepts

The framework combines multiple technical conditions to assist traders in evaluating trend quality, momentum behavior, and volatility structure.

The model integrates:

trend analysis

momentum confirmation

volatility filtering

ATR structure

breakout context

relative strength conditions


Instead of relying on a single indicator, the framework attempts to build a broader technical context around market conditions.


---

Features

Multi-factor analysis framework

Trend and momentum integration

Volatility-aware logic

ATR-based structure analysis

Market condition filtering

Multi-market compatibility



---

Best Use Cases

Best suited for:

structured discretionary trading

trend continuation analysis

volatility expansion environments

swing trading

H1–D1 analysis



---

Notes

This script is designed for educational and analytical purposes only.

Not financial advice.

## Source Code

````pine
//@version=6
indicator("Gemini Multiple Edge Framework ", overlay=true, max_labels_count=500)

// ==========================================
// 參數設定 (與 EA 邏輯同步)
// ==========================================
group_trend = "1/2/4. 趨勢與突破"
ema_fast_len = input.int(20, "短期 EMA", group=group_trend)
ema_slow_len = input.int(50, "長期 EMA", group=group_trend)
brk_period   = input.int(20, "突破回溯週期", group=group_trend)
htf_period   = input.timeframe("240", "高時區確認 (MTF)", group=group_trend)

group_vol = "3. 成交量優勢"
vol_mult = input.float(1.3, "成交量放大倍數", group=group_vol)

group_osc = "8/9. 動力指標 (RSI/ADX)"
rsi_len = input.int(14, "RSI 週期", group=group_osc)
rsi_min_buy = input.float(50.0, "買入 RSI 下限", group=group_osc)
rsi_max_buy = input.float(75.0, "買入 RSI 上限", group=group_osc)

group_rr = "6. 盈虧比規劃 (R&R&S)"
atr_len  = input.int(14, "ATR 週期", group=group_rr)
sl_mult  = input.float(2.0, "ATR 止損倍數", group=group_rr)
tp1_r    = input.float(1.0, "TP1 倍數 (1R)", group=group_rr)
tp2_r    = input.float(2.0, "TP2 倍數 (2R)", group=group_rr)

// ==========================================
// 核心邏輯計算
// ==========================================
// 1. 均線與趨勢
ema_f = ta.ema(close, ema_fast_len)
ema_s = ta.ema(close, ema_slow_len)
htf_ema_f = request.security(syminfo.tickerid, htf_period, ta.ema(close, ema_fast_len))
htf_ema_s = request.security(syminfo.tickerid, htf_period, ta.ema(close, ema_slow_len))

// 2. 突破位 (S&R)
hh = ta.highest(high[1], brk_period)
ll = ta.lowest(low[1], brk_period)

// 3. 成交量
v_ma = ta.sma(volume, 20)
v_ok = volume > v_ma * vol_mult

// 4. RSI
rsi = ta.rsi(close, rsi_len)

// 5. ATR 止損距離
atr = ta.atr(atr_len)

// ==========================================
// 訊號判斷 (Confluence)
// ==========================================
buy_cond = ta.crossover(close, hh) and ema_f > ema_s and close > htf_ema_f and rsi >= rsi_min_buy and rsi <= rsi_max_buy and v_ok
sell_cond = ta.crossunder(close, ll) and ema_f < ema_s and close < htf_ema_f and rsi <= 50 and rsi >= 25 and v_ok

// ==========================================
// 繪圖與視覺化
// ==========================================
plot(ema_f, "Fast EMA", color.new(color.blue, 0))
plot(ema_s, "Slow EMA", color.new(color.red, 0))

// 繪製壓力/支撐線
plot(hh, "Resistance", color.new(color.gray, 70), style=plot.style_stepline)
plot(ll, "Support", color.new(color.gray, 70), style=plot.style_stepline)

// 進場標籤與 R&R 預測
if buy_cond
    sl_dist = atr * sl_mult
    entry_p = close
    sl_p = entry_p - sl_dist
    tp1_p = entry_p + sl_dist * tp1_r
    tp2_p = entry_p + sl_dist * tp2_r
    
    label.new(bar_index, low, "BUY\nSL: " + str.tostring(sl_p, "#.##") + "\nTP1: " + str.tostring(tp1_p, "#.##"), color=color.green, textcolor=color.white, style=label.style_label_up)
    // 繪製目標區間
    line.new(bar_index, tp1_p, bar_index + 10, tp1_p, color=color.new(color.green, 50), width=2)
    line.new(bar_index, tp2_p, bar_index + 10, tp2_p, color=color.new(color.orange, 20), width=2, style=line.style_dashed)

if sell_cond
    sl_dist = atr * sl_mult
    entry_p = close
    sl_p = entry_p + sl_dist
    tp1_p = entry_p - sl_dist * tp1_r
    tp2_p = entry_p - sl_dist * tp2_r
    
    label.new(bar_index, high, "SELL\nSL: " + str.tostring(sl_p, "#.##") + "\nTP1: " + str.tostring(tp1_p, "#.##"), color=color.red, textcolor=color.white, style=label.style_label_down)
    line.new(bar_index, tp1_p, bar_index + 10, tp1_p, color=color.new(color.red, 50), width=2)

// 相對強度背景 (與 EA 邏輯一致)
rs_color = (ema_f > ema_s and close > htf_ema_f) ? color.new(color.green, 90) : (ema_f < ema_s and close < htf_ema_f) ? color.new(color.red, 90) : na
bgcolor(rs_color)

// ==========================================
// 狀態面板 (Dashboard)
// ==========================================
var table status_table = table.new(position.top_right, 2, 4, border_width=1)
if barstate.islast
    table.cell(status_table, 0, 0, "趨勢 (MTF)", bgcolor=color.gray, text_color=color.white)
    table.cell(status_table, 1, 0, close > htf_ema_f ? "看多" : "看空", bgcolor=close > htf_ema_f ? color.green : color.red)
    table.cell(status_table, 0, 1, "量能確認", bgcolor=color.gray, text_color=color.white)
    table.cell(status_table, 1, 1, v_ok ? "放量" : "萎縮", bgcolor=v_ok ? color.green : color.orange)
````
