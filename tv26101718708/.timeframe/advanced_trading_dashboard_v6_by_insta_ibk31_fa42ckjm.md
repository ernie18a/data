# Advanced Trading Dashboard v6 By Insta: IB_K31

- url: https://www.tradingview.com/script/Fa42cKJm-Advanced-Trading-Dashboard-v6-By-Insta-IB-K31/
- type: indicator
- pine_id: PUB;71dfff8b229b425f924d70e53a693cb6
- version: 1.0

## Description

[b]🎯 Advanced Trading Dashboard v6 | The All-in-One Indicator
A comprehensive analytical suite that integrates 7 powerful tools into a single dashboard. Designed to help traders execute precise entries and exits with high-level data visualization.

✨ Key Features:
1. 📅 D-2 & H4 Institutional Levels Automatically plots the High/Low of the second-to-last Daily candle and the previous 4-hour candle—critical liquidity zones monitored by institutional traders.

2. 📊 Multi-Indicator Scoring System (6 Indicators) Intelligently analyzes market direction using RSI, EMA 9/21, MACD, Stochastic, ADX/DMI, and Volume. It calculates real-time Bull/Bear Scores to quantify trend strength.

3. 🚀 Smart Entry Signals * Strong BUY/SELL: Triggered when 4+ indicators align.

Potential BUY?/SELL?: Triggered when 3 indicators align.

4. 🕯️ Candlestick Pattern Recognition Automatically detects and labels key patterns: Engulfing, Hammer, Shooting Star, Morning/Evening Star, Three Soldiers, and Three Crows.

5. 🔮 Predictive Candle Forecasting Visualizes 3 projected future candles based on current Momentum and ATR (Average True Range).

6. 💧 Buy/Sell Liquidity Analysis Measures the ratio of buying vs. selling volume to identify who is currently in control of the market.

7. 📋 Comprehensive Information Dashboard A streamlined, real-time display of all data points, providing an instant final assessment of market bias and entry quality.

🎯 Best Suited For:
Assets: Gold (XAU/USD), Oil (WTI), Forex, Indices, and Stocks.

Timeframes: Works on all intervals (Optimized for H1 and H4).

⚙️ Fully Customizable:
Tailor the dashboard to your style by adjusting indicator periods, colors, and display preferences.

⚠️ Disclaimer: > This indicator is an analytical aid and does not constitute financial advice. Always practice proper risk management and never rely on a single signal for trading decisions.[/b]

## Source Code

````pine
//@version=6
indicator("🎯 Advanced Trading Dashboard v6 | المؤشر المتكامل", 
     overlay = true, 
     max_lines_count  = 500, 
     max_labels_count = 500,
     max_boxes_count  = 200)

// ============================================================
// ⚙️ SETTINGS | الإعدادات
// ============================================================

group_d2     = "📅 الشمعة اليومية قبل الأخيرة"
show_d2      = input.bool(true,  "إظهار حدود اليوم قبل الأخير", group = group_d2)
d2_high_col  = input.color(color.new(#FF6B35, 20), "لون الحد الأعلى D-2",  group = group_d2)
d2_low_col   = input.color(color.new(#35A7FF, 20), "لون الحد الأدنى D-2",   group = group_d2)

group_h4     = "🕓 شمعة الـ4 ساعات الأخيرة"
show_h4      = input.bool(true,  "إظهار حدود H4 الأخيرة", group = group_h4)
h4_high_col  = input.color(color.new(#FFD700, 30), "لون الحد الأعلى H4", group = group_h4)
h4_low_col   = input.color(color.new(#00E5FF, 30), "لون الحد الأدنى H4",  group = group_h4)

group_sig    = "📡 إشارات الدخول والمؤشرات"
show_signals = input.bool(true,  "إظهار إشارات الدخول",  group = group_sig)
show_indi    = input.bool(true,  "إظهار لوحة المؤشرات",   group = group_sig)
rsi_len      = input.int(14,     "فترة RSI",  minval = 2,  group = group_sig)
ema_fast     = input.int(9,      "EMA سريع",  minval = 1,  group = group_sig)
ema_slow     = input.int(21,     "EMA بطيء",  minval = 2,  group = group_sig)

group_liq    = "💧 السيولة الشرائية / البيعية"
show_liq     = input.bool(true,  "إظهار السيولة",          group = group_liq)
liq_len      = input.int(20,     "فترة حساب السيولة", minval = 5, group = group_liq)

group_pat    = "🔷 الأنماط والشموع المستقبلية"
show_pat     = input.bool(true,  "إظهار الأنماط الشمعية",     group = group_pat)
show_proj    = input.bool(true,  "إظهار الشموع المستقبلية",   group = group_pat)

// ============================================================
// 1️⃣  الشمعة اليومية قبل الأخيرة (D-2)
// ============================================================
d2h = request.security(syminfo.tickerid, "D", high[2], lookahead = barmerge.lookahead_on)
d2l = request.security(syminfo.tickerid, "D", low[2],  lookahead = barmerge.lookahead_on)

if show_d2 and barstate.islast
    line.new(bar_index - 50, d2h, bar_index + 15, d2h, color = d2_high_col, width = 2, style = line.style_dashed)
    line.new(bar_index - 50, d2l, bar_index + 15, d2l, color = d2_low_col,  width = 2, style = line.style_dashed)
    label.new(bar_index + 15, d2h, "⬆ D-2 High: " + str.tostring(d2h, "#.####"), color = d2_high_col, textcolor = color.white, style = label.style_label_left, size = size.small)
    label.new(bar_index + 15, d2l, "⬇ D-2 Low:  " + str.tostring(d2l, "#.####"), color = d2_low_col,  textcolor = color.white, style = label.style_label_left, size = size.small)

// ============================================================
// 2️⃣  شمعة الـ4 ساعات الأخيرة
// ============================================================
h4h = request.security(syminfo.tickerid, "240", high[1], lookahead = barmerge.lookahead_on)
h4l = request.security(syminfo.tickerid, "240", low[1],  lookahead = barmerge.lookahead_on)

if show_h4 and barstate.islast
    line.new(bar_index - 30, h4h, bar_index + 12, h4h, color = h4_high_col, width = 2, style = line.style_dotted)
    line.new(bar_index - 30, h4l, bar_index + 12, h4l, color = h4_low_col,  width = 2, style = line.style_dotted)
    label.new(bar_index + 12, h4h, "⬆ H4 High: " + str.tostring(h4h, "#.####"), color = h4_high_col, textcolor = color.black, style = label.style_label_left, size = size.small)
    label.new(bar_index + 12, h4l, "⬇ H4 Low:  " + str.tostring(h4l, "#.####"), color = h4_low_col,  textcolor = color.black, style = label.style_label_left, size = size.small)

// ============================================================
// 3️⃣  المؤشرات الإيجابية / السلبية
// ============================================================
float rsi_val   = ta.rsi(close, rsi_len)
float ema9      = ta.ema(close, ema_fast)
float ema21     = ta.ema(close, ema_slow)
float macd_line = ta.ema(close, 12) - ta.ema(close, 26)
float macd_sig  = ta.ema(macd_line, 9)
float macd_hist = macd_line - macd_sig
float stoch_k   = ta.stoch(close, high, low, 14)
float stoch_d   = ta.ema(stoch_k, 3)
[dip, dim, adx_val] = ta.dmi(14, 14)
float vol_avg   = ta.sma(volume, 20)
float atr_val   = ta.atr(14)

bool rsi_bull   = rsi_val > 55 and rsi_val < 75
bool rsi_bear   = rsi_val < 45 and rsi_val > 25
bool ema_bull   = ema9 > ema21
bool ema_bear   = ema9 < ema21
bool macd_bull  = macd_hist > 0 and macd_hist > macd_hist[1]
bool macd_bear  = macd_hist < 0 and macd_hist < macd_hist[1]
bool stoch_bull = stoch_k > stoch_d and stoch_k < 80
bool stoch_bear = stoch_k < stoch_d and stoch_k > 20
bool adx_bull   = dip > dim and adx_val > 20
bool adx_bear   = dim > dip and adx_val > 20
bool vol_bull   = close > open and volume > vol_avg
bool vol_bear   = close < open and volume > vol_avg

int bull_score = (rsi_bull ? 1 : 0) + (ema_bull ? 1 : 0) + (macd_bull ? 1 : 0) + (stoch_bull ? 1 : 0) + (adx_bull ? 1 : 0) + (vol_bull ? 1 : 0)
int bear_score = (rsi_bear ? 1 : 0) + (ema_bear ? 1 : 0) + (macd_bear ? 1 : 0) + (stoch_bear ? 1 : 0) + (adx_bear ? 1 : 0) + (vol_bear ? 1 : 0)

// ============================================================
// 4️⃣  إشارات الدخول
// ============================================================
bool strong_buy  = bull_score >= 4 and ema_bull and rsi_val > 50 and macd_bull
bool strong_sell = bear_score >= 4 and ema_bear and rsi_val < 50 and macd_bear
bool med_buy     = bull_score >= 3 and not strong_buy
bool med_sell    = bear_score >= 3 and not strong_sell

if show_signals
    if strong_buy
        label.new(bar_index, low * 0.9995, "🚀 BUY", color = color.new(#00C853, 0), textcolor = color.white, style = label.style_label_up, size = size.normal)
    if strong_sell
        label.new(bar_index, high * 1.0005, "🔻 SELL", color = color.new(#D50000, 0), textcolor = color.white, style = label.style_label_down, size = size.normal)
    if med_buy
        label.new(bar_index, low * 0.9998, "↑ BUY?", color = color.new(#69F0AE, 0), textcolor = color.black, style = label.style_label_up, size = size.small)
    if med_sell
        label.new(bar_index, high * 1.0002, "↓ SELL?", color = color.new(#FF5252, 0), textcolor = color.white, style = label.style_label_down, size = size.small)

// ============================================================
// 5️⃣  الأنماط الشمعية + تلوين الشموع
// ============================================================
bool bullish_candle = close > open
bool bearish_candle = close < open
bool doji_candle    = math.abs(close - open) <= (high - low) * 0.1

barcolor(bullish_candle ? color.new(#00E676, 0) : bearish_candle ? color.new(#FF1744, 0) : color.new(#FFFF00, 0))

bool bull_engulf  = bearish_candle[1] and bullish_candle and close > open[1] and open < close[1]
bool bear_engulf  = bullish_candle[1] and bearish_candle and close < open[1] and open > close[1]

bool hammer       = (high - low) > 3 * math.abs(close - open) and (close - low) / (0.001 + high - low) > 0.6 and (high - close) / (0.001 + high - low) < 0.1
bool shoot_star   = (high - low) > 3 * math.abs(close - open) and (high - close) / (0.001 + high - low) > 0.6 and (close - low) / (0.001 + high - low) < 0.1
bool morning_star = bearish_candle[2] and doji_candle[1] and bullish_candle and close > (open[2] + close[2]) / 2
bool evening_star = bullish_candle[2] and doji_candle[1] and bearish_candle and close < (open[2] + close[2]) / 2
bool three_white  = bullish_candle and bullish_candle[1] and bullish_candle[2] and close > close[1] and close[1] > close[2]
bool three_crows  = bearish_candle and bearish_candle[1] and bearish_candle[2] and close < close[1] and close[1] < close[2]

if show_pat
    if bull_engulf
        label.new(bar_index, low,  "Engulf ↑", color = #00BFA5, textcolor = color.white, style = label.style_label_up, size = size.tiny)
    if bear_engulf
        label.new(bar_index, high, "Engulf ↓", color = #FF6D00, textcolor = color.white, style = label.style_label_down, size = size.tiny)
    if hammer
        label.new(bar_index, low,  "🔨", color = #76FF03, textcolor = color.black, style = label.style_label_up, size = size.small)
    if shoot_star
        label.new(bar_index, high, "⭐", color = #FF3D00, textcolor = color.white, style = label.style_label_down, size = size.small)
    if morning_star
        label.new(bar_index, low,  "🌅 Morning Star", color = #00E5FF, textcolor = color.black, style = label.style_label_up, size = size.small)
    if evening_star
        label.new(bar_index, high, "🌇 Evening Star", color = #FF6F00, textcolor = color.white, style = label.style_label_down, size = size.small)
    if three_white
        label.new(bar_index, low,  "3 Soldiers ↑", color = #00C853, textcolor = color.white, style = label.style_label_up, size = size.small)
    if three_crows
        label.new(bar_index, high, "3 Crows ↓", color = #B71C1C, textcolor = color.white, style = label.style_label_down, size = size.small)

// ============================================================
// 6️⃣  الشموع المستقبلية المحتملة
// ============================================================
float avg_body  = ta.sma(math.abs(close - open), 10)
float momentum  = ta.roc(close, 5)
bool proj_up    = momentum > 0 and bull_score > bear_score
bool proj_down  = momentum < 0 and bear_score > bull_score

if show_proj and barstate.islast
    color proj_col_up   = color.new(#00E676, 60)
    color proj_col_down = color.new(#FF1744, 60)
    color proj_col_neut = color.new(#90A4AE, 70)

    for i = 1 to 3
        float proj_open  = proj_up ? close + atr_val * 0.3 * (i - 1) : proj_down ? close - atr_val * 0.3 * (i - 1) : close
        float proj_close = proj_up ? proj_open + avg_body : proj_down ? proj_open - avg_body : proj_open + avg_body * 0.3
        float proj_high  = math.max(proj_open, proj_close) + atr_val * 0.15
        float proj_low   = math.min(proj_open, proj_close) - atr_val * 0.15
        color bar_col    = proj_up ? proj_col_up : proj_down ? proj_col_down : proj_col_neut

        box.new(bar_index + i, math.max(proj_open, proj_close), bar_index + i, math.min(proj_open, proj_close), border_color = bar_col, bgcolor = bar_col, border_width = 1)
        line.new(bar_index + i, proj_high, bar_index + i, math.max(proj_open, proj_close), color = bar_col, width = 1)
        line.new(bar_index + i, math.min(proj_open, proj_close), bar_index + i, proj_low, color = bar_col, width = 1)

// ============================================================
// 7️⃣  السيولة الشرائية مقابل البيعية
// ============================================================
float buy_vol_bar  = bullish_candle ? volume : 0.0
float sell_vol_bar = bearish_candle ? volume : 0.0

float buy_liq  = ta.sma(buy_vol_bar,  liq_len)
float sell_liq = ta.sma(sell_vol_bar, liq_len)

bool  liq_bull_dom  = buy_liq > sell_liq
float liq_pct_bull  = buy_liq  / (buy_liq + sell_liq + 0.001) * 100
float liq_pct_bear  = sell_liq / (buy_liq + sell_liq + 0.001) * 100

// ============================================================
// 📊 لوحة المعلومات الشاملة
// ============================================================
if show_indi and barstate.islast
    string bias_str  = bull_score > bear_score ? "🟢 صاعد" : bear_score > bull_score ? "🔴 هابط" : "🟡 محايد"

    string rsi_str   = rsi_bull   ? "🟢 RSI+"  : rsi_bear   ? "🔴 RSI-"  : "⚪ RSI~"
    string ema_str   = ema_bull   ? "🟢 EMA+"  : ema_bear   ? "🔴 EMA-"  : "⚪ EMA~"
    string macd_str  = macd_bull  ? "🟢 MACD+" : macd_bear  ? "🔴 MACD-" : "⚪ MACD~"
    string stoch_str = stoch_bull ? "🟢 STK+"  : stoch_bear ? "🔴 STK-"  : "⚪ STK~"
    string adx_str   = adx_bull   ? "🟢 ADX+"  : adx_bear   ? "🔴 ADX-"  : "⚪ ADX~"
    string vol_str   = vol_bull   ? "🟢 VOL+"  : vol_bear   ? "🔴 VOL-"  : "⚪ VOL~"

    string liq_str   = liq_bull_dom ? "🟢 شراء " + str.tostring(liq_pct_bull, "#.#") + "% | بيع " + str.tostring(liq_pct_bear, "#.#") + "%" : "🔴 بيع "  + str.tostring(liq_pct_bear, "#.#") + "% | شراء " + str.tostring(liq_pct_bull, "#.#") + "%"

    string entry_str = strong_buy ? "🚀 دخول شراء قوي" : strong_sell ? "🔻 دخول بيع قوي" : med_buy ? "↑ شراء محتمل" : med_sell ? "↓ بيع محتمل" : "⏳ انتظار"

    string proj_str  = proj_up ? "📈 صعود متوقع" : proj_down ? "📉 هبوط متوقع" : "↔ محايد"

    string info_text = "═══════════════════════════\n" + "  📊 المؤشر المتكامل v6\n" + "═══════════════════════════\n" + "التحيز: " + bias_str + "   Bull:" + str.tostring(bull_score) + " Bear:" + str.tostring(bear_score) + "\n" + "───────────────────────────\n" + "المؤشرات:\n" + rsi_str + " RSI=" + str.tostring(rsi_val, "#.##") + "\n" + ema_str + " EMA9=" + str.tostring(ema9, "#.####") + "\n" + macd_str + " HIST=" + str.tostring(macd_hist, "#.######") + "\n" + stoch_str + " K=" + str.tostring(stoch_k, "#.#") + "\n" + adx_str + " ADX=" + str.tostring(adx_val, "#.#") + "\n" + vol_str + " VOL=" + str.tostring(volume, "#") + "\n" + "───────────────────────────\n" + "💧 " + liq_str + "\n" + "───────────────────────────\n" + "🎯 " + entry_str + "\n" + "🔮 " + proj_str + "\n" + "───────────────────────────\n" + "📅 D-2 H: " + str.tostring(d2h, "#.####") + "\n" + "📅 D-2 L: " + str.tostring(d2l, "#.####") + "\n" + "🕓 H4  H: " + str.tostring(h4h, "#.####") + "\n" + "🕓 H4  L: " + str.tostring(h4l, "#.####") + "\n" + "═══════════════════════════"

    label.new(bar_index + 2, ta.highest(high, 50), info_text, color = color.new(#0D1B2A, 10), textcolor = color.new(#E0F7FA, 0), style = label.style_label_left, size = size.normal, textalign = text.align_left)

// ============================================================
// 📈 رسم EMA
// ============================================================
plot(ema9,  "EMA 9",  color = color.new(#FFD700, 0), linewidth = 1)
plot(ema21, "EMA 21", color = color.new(#FF6B35, 0), linewidth = 1)
````
