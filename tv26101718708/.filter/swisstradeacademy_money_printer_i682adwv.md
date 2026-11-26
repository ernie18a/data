# SwissTradeAcademy Money Printer

- url: https://www.tradingview.com/script/i682AdwV-SwissTradeAcademy-Money-Printer/
- type: indicator
- pine_id: PUB;bb0a71971de846d188f891a29c56ec7c
- version: 1.0

## Description

The SwissTradeAcademy Money Printer is a professional-grade, multi-component trading indicator developed in Pine Script v6. It combines three powerful analysis methodologies into a single, high-performance tool, designed to keep your TradingView charts clean while providing comprehensive market insights.

Core Components

1. Super Bollinger Trend (SBT)
A dynamic trend-following system based on Bollinger Band volatility.

Trend Tracking: Uses an adaptive baseline that shifts based on price action and volatility.

Integrated ZigZag: Automatically identifies and connects local highs and lows to visualize market structure.

Signal Labels: Provides clear visual markers for trend shifts and price targets.

2. MACD Price Overlay
Unlike standard oscillators that sit in a separate pane, this MACD is projected directly onto the price chart.

Trend Momentum: Features a dual-line MACD (Fast/Slow) and a Signal line that change color based on momentum direction.

Visual Fill: Uses a dynamic color cloud to represent the gap between the MACD and Signal lines, highlighting bullish and bearish strength.

SMA 89 Filter: Includes a long-term 89-period Simple Moving Average to identify the "Golden Mean" and primary market direction.

3. 4-in-1 Multi-Timeframe MAs
A flexible Moving Average engine that allows for deep customization.

Versatile Types: Choose from SMA, EMA, WMA, RMA, HMA, or VWMA.

Multi-Timeframe (MTF) Support: Plot MAs from higher timeframes (e.g., 1H or Daily) directly onto your current lower-timeframe chart.

Custom Sources: Calculate averages based on Open, High, Low, Close, or HL2.

Key Features
Pine Script v6 Optimized: Built with the latest TradingView standards for maximum execution speed and reliability.

Organized Settings: All parameters are logically grouped in the "Inputs" tab for easy configuration.

Clean Interface: Combines three indicators into one, saving valuable indicator slots for free-tier users and reducing chart clutter.

How to Use
Trend Confirmation: Look for alignment between the Super Bollinger Trend color and the MACD cloud color.

Support & Resistance: Use the 89 SMA and the 200 EMA (MA 1) as major "institutional" levels for trade entries or exits.

Volatility Alerts: The ZigZag labels help track the distance of moves, assisting in setting realistic Take Profit levels.

## Source Code

````pine
//@version=6
indicator("SwissTradeAcademy Money Printer", "STA MP", overlay=true, max_labels_count=500)

// ==========================================
// --- INDICATOR 1: SUPER BOLLINGER TREND ---
// ==========================================
sbt_group = "--- SUPER BOLLINGER TREND ---"
sbt_prd         = input.int(12, "Period", minval=1, inline="setting", group=sbt_group)
sbt_mult        = input.float(2.0, "Mult", minval=0.1, step=0.1, inline="setting", tooltip="Set the Bollinger Band period and multiplier.", group=sbt_group)
sbt_showZigZag  = input.bool(true, "ZigZag", inline="zigzag", group=sbt_group)
sbt_signal      = input.string("Signal", "Signal Style", ["Signal", "Peak Distance"], inline="zigzag", group=sbt_group)
sbt_dev         = input.string("ZigZag", "ZigZag Type", ["ZigZag", "High/Low", "Close"], inline="zigzag", group=sbt_group)
sbt_showTable   = input.bool(false, "Average/Median Distance", group=sbt_group)
sbt_showTP      = input.bool(false, "Take Profit", inline="tp", group=sbt_group)
sbt_Tp_calc     = input.string("Median", "TP Basis", ["Median", "Average"], inline="tp", group=sbt_group)

type SBT_ZigZag
    int[]   x1
    float[] y1
    float[] diff

type SBT_Trend
    float s
    color c

var sbt_zz    = SBT_ZigZag.new(array.new<int>(), array.new<float>(), array.new<float>())
var sbt_logic = SBT_Trend.new(0.0, na)

float sbt_bbup = ta.sma(high, sbt_prd) + ta.stdev(high, sbt_prd) * sbt_mult
float sbt_bbdn = ta.sma(low, sbt_prd) - ta.stdev(low, sbt_prd) * sbt_mult

method zigzag(SBT_ZigZag z, color col, float p, bool l) =>
    float y2 = sbt_dev == "ZigZag" ? sbt_logic.s : sbt_dev == "High/Low" ? p : close
    if z.x1.size() > 0
        int x1_val = z.x1.get(0)
        float y1_val = z.y1.get(0)
        z.diff.unshift(math.abs(y2 - y1_val))
        line.new(x1_val, y1_val, bar_index, y2, color=color.new(color.gray, 50), style=line.style_dashed)
        label_style = sbt_signal == "Signal" ? (l ? label.style_triangleup : label.style_triangledown) : (l ? label.style_label_up : label.style_label_down)
        txt_val = sbt_signal == "Signal" ? na : str.tostring(y2 - y1_val, format.mintick) + "p"
        label.new(bar_index, sbt_logic.s, txt_val, color=col, size=size.small, style=label_style, textcolor=chart.bg_color)
    z.x1.unshift(bar_index)
    z.y1.unshift(y2)

sbt_logic.s := na(sbt_bbdn) or na(sbt_bbup) ? 0.0 : close > sbt_logic.s ? math.max(sbt_logic.s, sbt_bbdn) : close < sbt_logic.s ? math.min(sbt_logic.s, sbt_bbup) : 0.0

if ta.crossover(close, sbt_logic.s)
    sbt_logic.s := sbt_bbdn
    sbt_logic.c := color.lime
    if sbt_showZigZag
        sbt_zz.zigzag(color.lime, low, true)

if ta.crossunder(close, sbt_logic.s)
    sbt_logic.s := sbt_bbup
    sbt_logic.c := color.red
    if sbt_showZigZag
        sbt_zz.zigzag(color.red, high, false)

plot(sbt_logic.s, "SuperBollingerTrend", sbt_logic.c)

// ==========================================
// --- INDICATOR 2: MACD OVERLAY ---
// ==========================================
mo_group = "--- MACD OVERLAY ---"
mo_fa    = input.int(12, "FAST", group=mo_group)
mo_sa    = input.int(26, "SLOW", group=mo_group)
mo_sig_l = input.int(9, "SIGNAL", group=mo_group)
mo_sma_l = input.int(89, "SMA Overlay", group=mo_group)

mo_macd   = ta.ema(close, mo_sa - mo_fa)
mo_signal = ta.sma(mo_macd, mo_sig_l)
mo_sma    = ta.sma(close, mo_sma_l)

// MACD Plots with Fill
mo_p1 = plot(mo_macd, "MACD Line", mo_macd > mo_macd[1] ? color.green : color.red, 2)
mo_p2 = plot(mo_signal, "Signal Line", mo_signal > mo_signal[1] ? color.green : color.red, 2)
fill(mo_p1, mo_p2, mo_macd > mo_signal ? color.new(color.green, 70) : color.new(color.red, 70), "MACD Signal Fill")

plot(mo_sma, "MACD SMA", mo_sma > mo_sma[1] ? color.green : color.red, 2)

// ==========================================
// --- INDICATOR 3: 4 MAs (FROM 10-IN-1) ---
// ==========================================
ma_group = "--- 4 MAs (STA) ---"
ma_func(src, len, type) =>
    switch type
        'RMA' => ta.rma(src, len)
        'SMA' => ta.sma(src, len)
        'EMA' => ta.ema(src, len)
        'WMA' => ta.wma(src, len)
        'HMA' => ta.hma(src, len < 2 ? 2 : len)
        => ta.vwma(src, len)

tf_func(res) =>
    switch res
        "1 Minute" => '1'
        "5 Minutes" => '5'
        "15 Minutes" => '15'
        "1 Hour" => '60'
        "Day" => 'D'
        => timeframe.period

pr_func(res) =>
    switch res
        "Open" => open
        "High" => high
        "Low" => low
        "hl2" => hl2
        "hlc3" => hlc3
        => close

// MA 1
m1_p = input.bool(true, "MA 1", inline="ma1", group=ma_group)
m1_t = input.string("EMA", "", inline="ma1", options=['RMA', 'SMA', 'EMA', 'WMA','HMA','VWMA'], group=ma_group)
m1_l = input.int(200, "", inline="ma1", group=ma_group)
m1_r = input.string("Normal MA", "", inline="ma1", options=["Normal MA","Open","High","Low","Close","hl2","1 Minute","5 Minutes","15 Minutes","1 Hour","Day"], group=ma_group)
m1_c = input.color(color.red, "", inline="ma1", group=ma_group)

// MA 2
m2_p = input.bool(false, "MA 2", inline="ma2", group=ma_group)
m2_t = input.string("EMA", "", inline="ma2", options=['RMA', 'SMA', 'EMA', 'WMA','HMA','VWMA'], group=ma_group)
m2_l = input.int(50, "", inline="ma2", group=ma_group)
m2_r = input.string("Normal MA", "", inline="ma2", options=["Normal MA","Open","High","Low","Close","hl2","1 Minute","5 Minutes","15 Minutes","1 Hour","Day"], group=ma_group)
m2_c = input.color(color.blue, "", inline="ma2", group=ma_group)

// MA 3
m3_p = input.bool(false, "MA 3", inline="ma3", group=ma_group)
m3_t = input.string("EMA", "", inline="ma3", options=['RMA', 'SMA', 'EMA', 'WMA','HMA','VWMA'], group=ma_group)
m3_l = input.int(20, "", inline="ma3", group=ma_group)
m3_r = input.string("Normal MA", "", inline="ma3", options=["Normal MA","Open","High","Low","Close","hl2","1 Minute","5 Minutes","15 Minutes","1 Hour","Day"], group=ma_group)
m3_c = input.color(color.orange, "", inline="ma3", group=ma_group)

// MA 4
m4_p = input.bool(false, "MA 4", inline="ma4", group=ma_group)
m4_t = input.string("EMA", "", inline="ma4", options=['RMA', 'SMA', 'EMA', 'WMA','HMA','VWMA'], group=ma_group)
m4_l = input.int(10, "", inline="ma4", group=ma_group)
m4_r = input.string("Normal MA", "", inline="ma4", options=["Normal MA","Open","High","Low","Close","hl2","1 Minute","5 Minutes","15 Minutes","1 Hour","Day"], group=ma_group)
m4_c = input.color(color.white, "", inline="ma4", group=ma_group)

calc_ma(p, t, l, r) =>
    p ? (r == "Normal MA" or r == "Open" or r == "High" or r == "Low" or r == "Close" or r == "hl2" ? ma_func(pr_func(r), l, t) : request.security(syminfo.tickerid, tf_func(r), ma_func(close, l, t))) : na

plot(calc_ma(m1_p, m1_t, m1_l, m1_r), "MA 1", m1_c)
plot(calc_ma(m2_p, m2_t, m2_l, m2_r), "MA 2", m2_c)
plot(calc_ma(m3_p, m3_t, m3_l, m3_r), "MA 3", m3_c)
plot(calc_ma(m4_p, m4_t, m4_l, m4_r), "MA 4", m4_c)
````
