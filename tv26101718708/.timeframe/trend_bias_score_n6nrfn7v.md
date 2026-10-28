# Trend Bias Score

- url: https://www.tradingview.com/script/N6nRfn7V/
- type: indicator
- pine_id: PUB;d87f197236174142a8e861da2a1c72b3
- version: 1.0

## Description

📊 Trend Bias Score:

Trend Bias Score is a multi-timeframe directional bias oscillator designed to summarize market direction, trend strength, momentum condition, acceleration, volatility/volume energy, and open interest behavior into one clean composite score.

🧠 Main Concept:

Trend Bias Score attempts to answer one core question:

Is the market environment currently supporting bullish continuation, bearish continuation or indecision?

To do this, the script evaluates several market dimensions:

1. 📈 Trend structure
2. ⚡ Momentum
3. 🚀 Momentum acceleration
4. 🔊 Volume behavior
5. 🌪️ Volatility expansion or contraction
6. 📉 Open Interest behavior, when available
7. ⏱️ Multi-timeframe alignment

🧩 The Indicator Includes Different Asset Profiles:

🪙 Crypto
🛢️ Commodity
📊 Index
🏢 Stock
💱 Forex

Each asset class behaves differently. A crypto pair does not usually move like a stock index, a commodity, or a forex pair. Because of that, this script does not use one universal weighting model for every market.

⚙️ How the Score Is Built?

📈 1. Trend Score

The trend component uses a three-layer moving average structure.

⚡ 2. Momentum Score

Momentum is measured with RSI and normalized around the 50 level.

🚀 3. Acceleration Score

The acceleration component uses the MACD histogram change.

🔥 4. Energy Score

The energy score combines three different market activity inputs:

🔊 Volume behavior
🌪️ ATR behavior
📉 Open Interest behavior, when available

⏱️ Multi-Timeframe Structure:

The indicator calculates the bias across multiple internal timeframes and combines them into one final score.

The default structure is designed to represent a broader trend hierarchy:

🔬 Micro trend
🧭 Sub-minor trend
📍 Minor trend
🔎 Intermediate trend
🏛️ Main trend
🌍 Macro trend

🧾 Six-Timeframe Table:

The indicator includes a six-row multi-timeframe table.

The table is fully transparent in the background and uses simple directional coloring:

🟢 Green: score above zero
🔴 Red: score below zero
⚪ Gray: neutral or unavailable value

This makes the table useful for quickly checking whether the market is aligned across timeframes or showing conflict between short-term and higher-timeframe conditions.

🎯 Oscillator Interpretation:

The oscillator is centered around zero.

General interpretation:

🟢 Above +0.50: Strong bullish bias
🟩 Between +0.30 and +0.50: Moderate bullish bias
⚪ Between -0.30 and +0.30: Neutral or mixed zone
🟥 Between -0.30 and -0.50: Moderate bearish bias
🔴 Below -0.50: Strong bearish bias

🧭 How I Use It?

This indicator is best used as a bias filter rather than a direct entry system.

🟢 Bullish Conditions

A bullish environment is stronger when:

* The main Bias Score is above zero
* The oscillator is rising
* Several table timeframes are green
* Higher timeframes support the direction
* Pullbacks remain above key structural levels

🔴 Bearish Conditions

A bearish environment is stronger when:

* The main Bias Score is below zero
* The oscillator is falling
* Several table timeframes are red
* Higher timeframes confirm weakness
* Rallies fail below key resistance zones

⚪ Neutral Conditions

The market is less clear when:

* The Bias Score is near zero
* The table is mixed
* Short-term and higher-timeframe readings conflict
* Price is moving sideways
* Momentum and energy components are weak

🛠️ Best Practices:

Trend Bias Score works best when combined with:

* Market structure
* Support and resistance
* Volume analysis
* Price action
* Breakout or breakdown confirmation
* Order blocks
* Fair value gaps
* Liquidity zones
* Higher-timeframe context

⚠️ Important Notes:

This script uses standard multi-timeframe data requests. Higher-timeframe values can still change while the higher-timeframe candle is open.

Open Interest data depends on symbol availability. If Open Interest data is not available, the script still works using the remaining energy components.

The score is a composite model, not a prediction engine.

A positive score does not guarantee price will rise.

A negative score does not guarantee price will fall.

It only shows whether the current technical environment is more supportive of bullish or bearish conditions according to the selected model.

❗Disclaimer:

This indicator is for educational and analytical purposes only.

It is not financial advice.

It does not guarantee future performance.

Always use proper risk management and make your own trading decisions.

## Source Code

````pine
//@version=6
indicator("Trend Bias Score", overlay = false, precision = 2)

gt = "TREND BIAS SCORE"
asset_profile = input.string("Kripto", "Varlık", options = ["Kripto", "Emtia", "Endeks", "Hisse", "Forex"], group = gt)

gtf = "TABLO ZAMAN DİLİMLERİ"
table_tf1 = input.timeframe("15",  "Mikro Trend", options = ["15", "30", "45", "60", "120", "240", "D", "W", "M", "3M"], group = gtf)
table_tf2 = input.timeframe("60",  "Sub-Minör Trend", options = ["15", "30", "45", "60", "120", "240", "D", "W", "M", "3M"], group = gtf)
table_tf3 = input.timeframe("240", "Minör Trend", options = ["15", "30", "45", "60", "120", "240", "D", "W", "M", "3M"], group = gtf)
table_tf4 = input.timeframe("D",   "Ara Trend", options = ["15", "30", "45", "60", "120", "240", "D", "W", "M", "3M"], group = gtf)
table_tf5 = input.timeframe("W",   "Ana Trend", options = ["15", "30", "45", "60", "120", "240", "D", "W", "M", "3M"], group = gtf)
table_tf6 = input.timeframe("M",  "Makro Trend", options = ["15", "30", "45", "60", "120", "240", "D", "W", "M", "3M"], group = gtf)

gtv = "TABLO AYARLARI"
table_size_sel = input.string("Small", "Tablo Boyutu", options = ["Tiny", "Small", "Normal", "Large", "Huge"], group = gtv)

table_size = table_size_sel == "Tiny" ? size.tiny :
     table_size_sel == "Small" ? size.small :
     table_size_sel == "Normal" ? size.normal :
     table_size_sel == "Large" ? size.large :
     size.huge

is_crypto = asset_profile == "Kripto"
is_commodity = asset_profile == "Emtia"
is_index = asset_profile == "Endeks"
is_equity = asset_profile == "Hisse"
is_forex = asset_profile == "Forex"

f_tf_label(tf) =>
    string out = tf
    if tf == "15"
        out := "15m"
    else if tf == "30"
        out := "30m"
    else if tf == "45"
        out := "45m"
    else if tf == "60"
        out := "1H"
    else if tf == "120"
        out := "2H"
    else if tf == "240"
        out := "4H"
    else if tf == "D" or tf == "1D"
        out := "D"
    else if tf == "W" or tf == "1W"
        out := "W"
    else if tf == "M" or tf == "1M"
        out := "M"
    else if tf == "3M"
        out := "3M"
    out

f_ma(src, len, type) =>
    float result = na
    if type == "SMA"
        result := ta.sma(src, len)
    else if type == "EMA"
        result := ta.ema(src, len)
    else if type == "WMA"
        result := ta.wma(src, len)
    else if type == "VWMA"
        result := ta.vwma(src, len)
    else
        result := ta.ema(src, len)
    result

f_get_auto_oi_ticker() =>
    clean_ticker = str.replace(syminfo.ticker, ".P", "")
    clean_ticker := str.replace(clean_ticker, "PERP", "")
    syminfo.prefix + ":" + clean_ticker + "_OI"

f_oi_data(len) =>
    oi_val = close 
    oi_ma = ta.sma(oi_val, len)
    [oi_val, oi_ma]

f_combine(ts, ms, as_score, vb, ab, c, o, oi_v, oi_m, trend_w, momentum_w, accel_w, energy_w, energy_vol_w, energy_atr_w, energy_oi_w) =>
    float oi_bias = 0.0
    bool has_oi = not na(oi_v) and not na(oi_m)

    if has_oi
        if c >= o and oi_v > oi_m
            oi_bias := 1.0
        else if c < o and oi_v > oi_m
            oi_bias := -1.0
        else if c >= o and oi_v <= oi_m
            oi_bias := -0.5
        else if c < o and oi_v <= oi_m
            oi_bias := 0.5

    float energy_weight_sum = has_oi ? (energy_vol_w + energy_atr_w + energy_oi_w) : (energy_vol_w + energy_atr_w)
    float energy_score = 0.0

    if energy_weight_sum != 0
        energy_score := has_oi ? ((vb * energy_vol_w + ab * energy_atr_w + oi_bias * energy_oi_w) / energy_weight_sum) : ((vb * energy_vol_w + ab * energy_atr_w) / energy_weight_sum)

    float combine_weight_sum = trend_w + momentum_w + accel_w + energy_w
    combine_weight_sum != 0 ? ((ts * trend_w) + (ms * momentum_w) + (as_score * accel_w) + (energy_score * energy_w)) / combine_weight_sum : na

f_base_fusion(m_t, p1, p2, p3, rsi_l, v_t) =>
    ma1_val = f_ma(close, p1, m_t)
    ma2_val = f_ma(close, p2, m_t)
    ma3_val = f_ma(close, p3, m_t)
    
    t1 = na(ma1_val) ? 0.0 : (close > ma1_val ? 1.0 : -1.0)
    t2 = (na(ma1_val) or na(ma2_val)) ? 0.0 : (ma1_val > ma2_val ? 1.0 : -1.0)
    t3 = (na(ma2_val) or na(ma3_val)) ? 0.0 : (ma2_val > ma3_val ? 1.0 : -1.0)
    trend_score = (t1 * 0.2) + (t2 * 0.3) + (t3 * 0.5)
    
    m_rsi = ta.rsi(close, rsi_l)
    momentum_score = na(m_rsi) ? 0.0 : ((m_rsi - 50) / 50)
    
    [macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)
    histChange = ta.change(histLine)
    accel_score = na(histLine) ? 0.0 : (histChange > 0 ? 1.0 : -1.0)
    
    v_src = v_t == "Toplam" ? volume : volume * (close >= open ? 1 : -1)
    ema_v = ta.ema(v_src, 50)
    v_bias = na(ema_v) ? 0.0 : (v_src > ema_v ? (close >= open ? 1.0 : -1.0) : 0.0)
    
    atr_val = ta.atr(14)
    ema_atr = ta.ema(atr_val, 14)
    a_bias = na(ema_atr) ? 0.0 : (atr_val > ema_atr ? 1.0 : -1.0)
    
    [trend_score, momentum_score, accel_score, v_bias, a_bias, close, open]

f_profile_avg(v1, s1, w1, v2, s2, w2, v3, s3, w3, v4, s4, w4, v5, s5, w5, v6, s6, w6) =>
    float sum_v = 0.0
    float sum_w = 0.0

    if s1 and not na(v1)
        sum_v += v1 * w1
        sum_w += w1
    if s2 and not na(v2)
        sum_v += v2 * w2
        sum_w += w2
    if s3 and not na(v3)
        sum_v += v3 * w3
        sum_w += w3
    if s4 and not na(v4)
        sum_v += v4 * w4
        sum_w += w4
    if s5 and not na(v5)
        sum_v += v5 * w5
        sum_w += w5
    if s6 and not na(v6)
        sum_v += v6 * w6
        sum_w += w6

    sum_w > 0 ? sum_v / sum_w : na

t_ma_type = is_crypto ? "EMA" : is_commodity ? "SMA" : is_index ? "SMA" : is_equity ? "EMA" : "EMA"
t_rsi_len = 21
t_vol_type = "Delta"

tbs_trend_w = is_crypto ? 0.30 : is_commodity ? 0.42 : is_index ? 0.44 : is_equity ? 0.34 : 0.40
tbs_momentum_w = is_crypto ? 0.22 : is_commodity ? 0.22 : is_index ? 0.22 : is_equity ? 0.22 : 0.24
tbs_accel_w = is_crypto ? 0.16 : is_commodity ? 0.10 : is_index ? 0.10 : is_equity ? 0.12 : 0.12
tbs_energy_w = is_crypto ? 0.32 : is_commodity ? 0.26 : is_index ? 0.24 : is_equity ? 0.32 : 0.24

tbs_energy_vol_w = is_crypto ? 0.30 : is_commodity ? 0.30 : is_index ? 0.25 : is_equity ? 0.50 : 0.10
tbs_energy_atr_w = is_crypto ? 0.20 : is_commodity ? 0.45 : is_index ? 0.45 : is_equity ? 0.35 : 0.65
tbs_energy_oi_w = is_crypto ? 0.50 : is_commodity ? 0.25 : is_index ? 0.30 : is_equity ? 0.15 : 0.25

tf1 = is_crypto ? "15" : is_equity ? "30" : "60"
tf2 = is_crypto ? "60" : is_equity ? "120" : "240"
tf3 = is_crypto ? "240" : "D"
tf4 = is_crypto ? "D" : "W"
tf5 = is_crypto ? "W" : "M"
tf6 = is_crypto ? "M" : "3M"

tbs_w1 = is_crypto ? 0.06 : is_commodity ? 0.03 : is_index ? 0.03 : is_equity ? 0.05 : 0.04
tbs_w2 = is_crypto ? 0.09 : is_commodity ? 0.07 : is_index ? 0.07 : is_equity ? 0.09 : 0.08
tbs_w3 = is_crypto ? 0.15 : is_commodity ? 0.16 : is_index ? 0.18 : is_equity ? 0.22 : 0.20
tbs_w4 = is_crypto ? 0.24 : is_commodity ? 0.26 : is_index ? 0.28 : is_equity ? 0.27 : 0.29
tbs_w5 = is_crypto ? 0.26 : is_commodity ? 0.28 : is_index ? 0.27 : is_equity ? 0.23 : 0.24
tbs_w6 = is_crypto ? 0.20 : is_commodity ? 0.20 : is_index ? 0.17 : is_equity ? 0.14 : 0.15

t1_ma1 = is_crypto ? 32 : is_commodity ? 24 : is_index ? 24 : is_equity ? 13 : 24
t1_ma2 = is_crypto ? 96 : is_commodity ? 72 : is_index ? 72 : is_equity ? 39 : 72
t1_ma3 = is_crypto ? 288 : is_commodity ? 336 : is_index ? 336 : is_equity ? 130 : 336

t2_ma1 = is_crypto ? 24 : is_commodity ? 18 : is_index ? 18 : is_equity ? 7 : 18
t2_ma2 = is_crypto ? 72 : is_commodity ? 42 : is_index ? 42 : is_equity ? 20 : 42
t2_ma3 = is_crypto ? 336 : is_commodity ? 126 : is_index ? 126 : is_equity ? 65 : 126

t3_ma1 = is_crypto ? 21 : is_commodity ? 21 : is_index ? 20 : is_equity ? 20 : 21
t3_ma2 = is_crypto ? 42 : is_commodity ? 63 : is_index ? 50 : is_equity ? 50 : 63
t3_ma3 = is_crypto ? 126 : is_commodity ? 252 : is_index ? 200 : is_equity ? 200 : 252

t4_ma1 = is_crypto ? 30 : is_commodity ? 13 : is_index ? 10 : is_equity ? 10 : 13
t4_ma2 = is_crypto ? 90 : is_commodity ? 26 : is_index ? 20 : is_equity ? 20 : 26
t4_ma3 = is_crypto ? 365 : is_commodity ? 52 : is_index ? 40 : is_equity ? 40 : 52

t5_ma1 = is_crypto ? 4 : is_commodity ? 6 : is_index ? 5 : is_equity ? 5 : 6
t5_ma2 = is_crypto ? 13 : is_commodity ? 12 : is_index ? 10 : is_equity ? 10 : 12
t5_ma3 = is_crypto ? 52 : is_commodity ? 24 : is_index ? 20 : is_equity ? 20 : 24

t6_ma1 = is_crypto ? 3 : is_commodity ? 4 : is_index ? 4 : is_equity ? 4 : 4
t6_ma2 = is_crypto ? 6 : is_commodity ? 8 : is_index ? 8 : is_equity ? 8 : 8
t6_ma3 = is_crypto ? 12 : is_commodity ? 16 : is_index ? 12 : is_equity ? 12 : 16

auto_oi_ticker = f_get_auto_oi_ticker()

[ts1, ms1, as1, vb1, ab1, ct1, ot1] = request.security(syminfo.tickerid, tf1, f_base_fusion(t_ma_type, t1_ma1, t1_ma2, t1_ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
[oi_v1, oi_m1] = request.security(auto_oi_ticker, tf1, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
tbs_v1 = f_combine(ts1, ms1, as1, vb1, ab1, ct1, ot1, oi_v1, oi_m1, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

[ts2, ms2, as2, vb2, ab2, ct2, ot2] = request.security(syminfo.tickerid, tf2, f_base_fusion(t_ma_type, t2_ma1, t2_ma2, t2_ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
[oi_v2, oi_m2] = request.security(auto_oi_ticker, tf2, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
tbs_v2 = f_combine(ts2, ms2, as2, vb2, ab2, ct2, ot2, oi_v2, oi_m2, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

[ts3, ms3, as3, vb3, ab3, ct3, ot3] = request.security(syminfo.tickerid, tf3, f_base_fusion(t_ma_type, t3_ma1, t3_ma2, t3_ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
[oi_v3, oi_m3] = request.security(auto_oi_ticker, tf3, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
tbs_v3 = f_combine(ts3, ms3, as3, vb3, ab3, ct3, ot3, oi_v3, oi_m3, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

[ts4, ms4, as4, vb4, ab4, ct4, ot4] = request.security(syminfo.tickerid, tf4, f_base_fusion(t_ma_type, t4_ma1, t4_ma2, t4_ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
[oi_v4, oi_m4] = request.security(auto_oi_ticker, tf4, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
tbs_v4 = f_combine(ts4, ms4, as4, vb4, ab4, ct4, ot4, oi_v4, oi_m4, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

[ts5, ms5, as5, vb5, ab5, ct5, ot5] = request.security(syminfo.tickerid, tf5, f_base_fusion(t_ma_type, t5_ma1, t5_ma2, t5_ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
[oi_v5, oi_m5] = request.security(auto_oi_ticker, tf5, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
tbs_v5 = f_combine(ts5, ms5, as5, vb5, ab5, ct5, ot5, oi_v5, oi_m5, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

[ts6, ms6, as6, vb6, ab6, ct6, ot6] = request.security(syminfo.tickerid, tf6, f_base_fusion(t_ma_type, t6_ma1, t6_ma2, t6_ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
[oi_v6, oi_m6] = request.security(auto_oi_ticker, tf6, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
tbs_v6 = f_combine(ts6, ms6, as6, vb6, ab6, ct6, ot6, oi_v6, oi_m6, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

total_bias = f_profile_avg(tbs_v1, true, tbs_w1, tbs_v2, true, tbs_w2, tbs_v3, true, tbs_w3, tbs_v4, true, tbs_w4, tbs_v5, true, tbs_w5, tbs_v6, true, tbs_w6)

f_ma1_by_tf(tf) =>
    int p = 20

    if is_crypto
        if tf == "15"
            p := 32
        else if tf == "30"
            p := 30
        else if tf == "45"
            p := 28
        else if tf == "60"
            p := 24
        else if tf == "120"
            p := 22
        else if tf == "240"
            p := 21
        else if tf == "D" or tf == "1D"
            p := 30
        else if tf == "W" or tf == "1W"
            p := 4
        else if tf == "M" or tf == "1M"
            p := 3
        else if tf == "3M"
            p := 2

    else if is_commodity or is_forex
        if tf == "15"
            p := 36
        else if tf == "30"
            p := 30
        else if tf == "45"
            p := 26
        else if tf == "60"
            p := 24
        else if tf == "120"
            p := 20
        else if tf == "240"
            p := 18
        else if tf == "D" or tf == "1D"
            p := 21
        else if tf == "W" or tf == "1W"
            p := 13
        else if tf == "M" or tf == "1M"
            p := 6
        else if tf == "3M"
            p := 4

    else if is_index
        if tf == "15"
            p := 36
        else if tf == "30"
            p := 30
        else if tf == "45"
            p := 26
        else if tf == "60"
            p := 24
        else if tf == "120"
            p := 20
        else if tf == "240"
            p := 18
        else if tf == "D" or tf == "1D"
            p := 20
        else if tf == "W" or tf == "1W"
            p := 10
        else if tf == "M" or tf == "1M"
            p := 5
        else if tf == "3M"
            p := 4

    else
        if tf == "15"
            p := 20
        else if tf == "30"
            p := 13
        else if tf == "45"
            p := 12
        else if tf == "60"
            p := 10
        else if tf == "120"
            p := 7
        else if tf == "240"
            p := 8
        else if tf == "D" or tf == "1D"
            p := 20
        else if tf == "W" or tf == "1W"
            p := 10
        else if tf == "M" or tf == "1M"
            p := 5
        else if tf == "3M"
            p := 4

    p

f_ma2_by_tf(tf) =>
    int p = 50

    if is_crypto
        if tf == "15"
            p := 96
        else if tf == "30"
            p := 90
        else if tf == "45"
            p := 84
        else if tf == "60"
            p := 72
        else if tf == "120"
            p := 60
        else if tf == "240"
            p := 42
        else if tf == "D" or tf == "1D"
            p := 90
        else if tf == "W" or tf == "1W"
            p := 13
        else if tf == "M" or tf == "1M"
            p := 6
        else if tf == "3M"
            p := 4

    else if is_commodity or is_forex
        if tf == "15"
            p := 108
        else if tf == "30"
            p := 90
        else if tf == "45"
            p := 78
        else if tf == "60"
            p := 72
        else if tf == "120"
            p := 56
        else if tf == "240"
            p := 42
        else if tf == "D" or tf == "1D"
            p := 63
        else if tf == "W" or tf == "1W"
            p := 26
        else if tf == "M" or tf == "1M"
            p := 12
        else if tf == "3M"
            p := 8

    else if is_index
        if tf == "15"
            p := 108
        else if tf == "30"
            p := 90
        else if tf == "45"
            p := 78
        else if tf == "60"
            p := 72
        else if tf == "120"
            p := 56
        else if tf == "240"
            p := 42
        else if tf == "D" or tf == "1D"
            p := 50
        else if tf == "W" or tf == "1W"
            p := 20
        else if tf == "M" or tf == "1M"
            p := 10
        else if tf == "3M"
            p := 8

    else
        if tf == "15"
            p := 60
        else if tf == "30"
            p := 39
        else if tf == "45"
            p := 35
        else if tf == "60"
            p := 30
        else if tf == "120"
            p := 20
        else if tf == "240"
            p := 26
        else if tf == "D" or tf == "1D"
            p := 50
        else if tf == "W" or tf == "1W"
            p := 20
        else if tf == "M" or tf == "1M"
            p := 10
        else if tf == "3M"
            p := 8

    p

f_ma3_by_tf(tf) =>
    int p = 200

    if is_crypto
        if tf == "15"
            p := 288
        else if tf == "30"
            p := 300
        else if tf == "45"
            p := 300
        else if tf == "60"
            p := 336
        else if tf == "120"
            p := 240
        else if tf == "240"
            p := 126
        else if tf == "D" or tf == "1D"
            p := 365
        else if tf == "W" or tf == "1W"
            p := 52
        else if tf == "M" or tf == "1M"
            p := 12
        else if tf == "3M"
            p := 8

    else if is_commodity or is_forex
        if tf == "15"
            p := 432
        else if tf == "30"
            p := 360
        else if tf == "45"
            p := 360
        else if tf == "60"
            p := 336
        else if tf == "120"
            p := 168
        else if tf == "240"
            p := 126
        else if tf == "D" or tf == "1D"
            p := 252
        else if tf == "W" or tf == "1W"
            p := 52
        else if tf == "M" or tf == "1M"
            p := 24
        else if tf == "3M"
            p := 16

    else if is_index
        if tf == "15"
            p := 432
        else if tf == "30"
            p := 360
        else if tf == "45"
            p := 360
        else if tf == "60"
            p := 336
        else if tf == "120"
            p := 168
        else if tf == "240"
            p := 126
        else if tf == "D" or tf == "1D"
            p := 200
        else if tf == "W" or tf == "1W"
            p := 40
        else if tf == "M" or tf == "1M"
            p := 20
        else if tf == "3M"
            p := 12

    else
        if tf == "15"
            p := 200
        else if tf == "30"
            p := 130
        else if tf == "45"
            p := 120
        else if tf == "60"
            p := 100
        else if tf == "120"
            p := 65
        else if tf == "240"
            p := 80
        else if tf == "D" or tf == "1D"
            p := 200
        else if tf == "W" or tf == "1W"
            p := 40
        else if tf == "M" or tf == "1M"
            p := 20
        else if tf == "3M"
            p := 12

    p

f_get_tf_score_custom(tf, ma_type, ma1, ma2, ma3) =>
    [ts, ms, as_score, vb, ab, c, o] = request.security(syminfo.tickerid, tf, f_base_fusion(ma_type, ma1, ma2, ma3, t_rsi_len, t_vol_type), gaps = barmerge.gaps_off)
    [oi_v, oi_m] = request.security(auto_oi_ticker, tf, f_oi_data(14), ignore_invalid_symbol = true, gaps = barmerge.gaps_off)
    f_combine(ts, ms, as_score, vb, ab, c, o, oi_v, oi_m, tbs_trend_w, tbs_momentum_w, tbs_accel_w, tbs_energy_w, tbs_energy_vol_w, tbs_energy_atr_w, tbs_energy_oi_w)

f_get_tf_score_auto(tf) =>
    ma1 = f_ma1_by_tf(tf)
    ma2 = f_ma2_by_tf(tf)
    ma3 = f_ma3_by_tf(tf)
    f_get_tf_score_custom(tf, t_ma_type, ma1, ma2, ma3)

table_s1 = f_get_tf_score_auto(table_tf1)
table_s2 = f_get_tf_score_auto(table_tf2)
table_s3 = f_get_tf_score_auto(table_tf3)
table_s4 = f_get_tf_score_auto(table_tf4)
table_s5 = f_get_tf_score_auto(table_tf5)
table_s6 = f_get_tf_score_auto(table_tf6)

bias_rising = total_bias > total_bias[1]
bias_falling = total_bias < total_bias[1]

bias_color = na(total_bias) ? color.gray :
     total_bias > 0 ? color.rgb(46, 189, 133) :
     total_bias < 0 ? color.rgb(246, 70, 93) :
     color.gray

plot(total_bias, "Bias Score", color = bias_color, linewidth = 1, style = plot.style_line)

h_10  = hline(0.5,  "Üst Çizgi",      color = color.new(#2ebd85, 50), linestyle = hline.style_solid)
h_05  = hline(0.3,  "Orta Üst Çizgi", color = color.new(#2ebd85, 50), linestyle = hline.style_dotted)
h_00  = hline(0.0,  "Orta Çizgi",          color = color.new(color.gray, 50), linestyle = hline.style_solid)
h_m05 = hline(-0.3, "Orta Alt Çizgi",    color = color.new(#f6465d, 50), linestyle = hline.style_dotted)
h_m10 = hline(-0.5, "Alt Çizgi",         color = color.new(#f6465d, 50), linestyle = hline.style_solid)

fill(h_10, h_05,   title = "Yükseliş", color = color.new(#2ebd85, 85))
fill(h_05, h_m05,  title = "Nötr",     color = color.new(color.gray, 85))
fill(h_m05, h_m10, title = "Düşüş",    color = color.new(#f6465d, 85))

var tbl = table.new(position.middle_right, 2, 7, border_width = 1, border_color = #fffffff2)

f_table_score_color(val) =>
    na(val) ? color.rgb(99, 99, 99) : val > 0 ? color.rgb(76, 175, 80) : val < 0 ? color.rgb(242, 54, 69) : color.rgb(99, 99, 99)

f_table_score_text(val) =>
    na(val) ? "-" : str.tostring(val, "#.##")

f_fill_row(t, row, tf_text, val) =>
    c_color = f_table_score_color(val)
    table.cell(t, 0, row, tf_text, text_color = color.white, text_size = table_size, bgcolor = color.new(color.black, 100))
    table.cell(t, 1, row, f_table_score_text(val), text_color = color.white, text_size = table_size, bgcolor = c_color)

if barstate.islast
    table.clear(tbl, 0, 0, 1, 6)

    table.cell(tbl, 0, 0, "Zaman", text_color = color.white, text_size = table_size, bgcolor = color.new(color.black, 100))
    table.cell(tbl, 1, 0, "Skor",  text_color = color.white, text_size = table_size, bgcolor = color.new(color.black, 100))

    f_fill_row(tbl, 1, f_tf_label(table_tf1), table_s1)
    f_fill_row(tbl, 2, f_tf_label(table_tf2), table_s2)
    f_fill_row(tbl, 3, f_tf_label(table_tf3), table_s3)
    f_fill_row(tbl, 4, f_tf_label(table_tf4), table_s4)
    f_fill_row(tbl, 5, f_tf_label(table_tf5), table_s5)
    f_fill_row(tbl, 6, f_tf_label(table_tf6), table_s6)
````
