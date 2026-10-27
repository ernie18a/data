# ALKHFAJEE - Multi-Indicator Market Radar & Cumulative Liquidity 

- url: https://www.tradingview.com/script/Qr19flop/
- type: indicator
- pine_id: PUB;a8cfde73d80243b0a5dbd2c64c5716ec
- version: 1.0

## Description

ALKHFAJEE Market Radar is an all-in-one technical screening matrix and real-time data cockpit built entirely in Pine Script v6. Operating as an on-screen Head-Up Display (HUD), it aggregates cumulative intraday order book liquidity with structural technical metrics to optimize market execution and eliminate blind trading.

Core Features & Analytics Engines:

1. Cumulative Session Liquidity Tracker ($)
Tracks real-time dollar-flow distribution by segmenting bar volume against price action. It continuously calculates the exact net-dollar flow of the current day, alerting you to whether institutional money is actively accumulating (Buying) or distributing (Selling).

2. Multi-Oscillator Momentum Confluence
Synthesizes real-time outputs from legendary momentum indicators including RSI (14), Money Flow Index (MFI), Stochastic %K, and Commodity Channel Index (CCI). The engine translates raw numbers into active market states like Overbought, Oversold, or Strong Acceleration.

3. Structural Trend & Cycle Filters
Integrates the Choppiness Index (CI) cycle lengths alongside MACD histograms and Directional Movement (DMI/ADX) matrixes. This section accurately distinguishes clear trending micro-structures from dangerous, range-bound sideways market noise.

4. Volumetric Intensity Scanners (Whale Detection)
Leverages a customized Relative Volume (RVOL) multiplier. It instantly alerts the user when massive volume blocks ("Whale Liquidity") enter the market compared to the historical average volume.

How to Use:
• Clean Setup: Designed to be an overlay cockpit, allowing you to hide clutter and read the entire market condition from a single table.
• Fully Customizable: Change positions (Top/Bottom, Left/Right) and tweak length parameters dynamically via the settings menu.

## Source Code

````pine
//@version=6
indicator('نظام الخفاجي - الرادار الشامل', overlay = true)

// --- 1. إعدادات الموقع ---
table_pos = input.string('Top Right', 'موقع الجدول', options = ['Top Right', 'Bottom Right', 'Top Left', 'Bottom Left'])
pos_val = table_pos == 'Top Right' ? position.top_right : table_pos == 'Bottom Right' ? position.bottom_right : table_pos == 'Top Left' ? position.top_left : position.bottom_left

// --- 2. حساب سيولة الجلسة التراكمية ($) ---
is_new_day = ta.change(time('D')) != 0
var float daily_in = 0.0
var float daily_out = 0.0

float instant_in = (close - low) / (high - low + 0.000001) * volume * close
float instant_out = (high - close) / (high - low + 0.000001) * volume * close

if is_new_day
    daily_in := instant_in
    daily_out := instant_out
    daily_out
else
    daily_in := daily_in + instant_in
    daily_out := daily_out + instant_out
    daily_out

float daily_net = daily_in - daily_out

format_m(amt) =>
    abs_amt = math.abs(amt)
    abs_amt >= 1000000000 ? str.tostring(amt / 1000000000, '#.##') + '  مليار $' : abs_amt >= 1000000 ? str.tostring(amt / 1000000, '#.##') + '  مليون $' : str.tostring(amt / 1000, '#.#') + '  ألف $'

// --- 3. المؤشرات ---
rsi = ta.rsi(close, 14)
mfi = ta.mfi(close, 14)
obv = ta.obv
cci = ta.cci(close, 20)
ci = 100 * math.log10(math.sum(ta.tr, 14) / (ta.highest(high, 14) - ta.lowest(low, 14) + 0.000001)) / math.log10(14)
[macd, sig, hist] = ta.macd(close, 12, 26, 9)
stoch = ta.stoch(close, high, low, 14)

adx_len = input.int(14, 'فترة ADX')
[di_plus, di_minus, adx_val] = ta.dmi(adx_len, adx_len)

rvol_len = input.int(20, 'فترة RVOL')
avg_vol = ta.sma(volume, rvol_len)
rvol = volume / avg_vol

// --- 4. الجدول ---
var tbl = table.new(pos_val, 3, 17, border_width = 2, border_color = color.new(#FFD700, 40), frame_width = 2, frame_color = #FFD700)

if barstate.islast

    // ===== رأس الجدول =====
    table.cell(tbl, 0, 0, '◈  رادار الخفاجي الشامل  ◈', bgcolor = #1C1C1C, text_color = #FFD700, text_size = size.normal, text_halign = text.align_center)
    table.merge_cells(tbl, 0, 0, 2, 0)

    // ===== رأس الأعمدة =====
    table.cell(tbl, 0, 1, '▸  المؤشر', bgcolor = #2A2A2A, text_color = #FFD700, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 1, '▸  القيمة', bgcolor = #2A2A2A, text_color = #FFD700, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 1, '▸  التفسير', bgcolor = #2A2A2A, text_color = #FFD700, text_size = size.normal, text_halign = text.align_center)

    // ===== صافي السيولة =====
    net_c = daily_net >= 0 ? color.lime : color.red
    net_t = daily_net >= 0 ? '✅  تدفق شرائي' : '🔴  تدفق بيعي'
    table.cell(tbl, 0, 2, '💰  صافي سيولة اليوم', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 2, format_m(daily_net), bgcolor = #0D0D0D, text_color = net_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 2, net_t, bgcolor = #0D0D0D, text_color = net_c, text_size = size.normal, text_halign = text.align_center)

    // ===== RSI =====
    rsi_c = rsi > 55 ? color.lime : rsi < 45 ? color.red : color.gray
    rsi_t = rsi > 70 ? '⚠️  تشبع شراء' : rsi > 55 ? '📈  زخم صاعد' : rsi < 30 ? '⚠️  تشبع بيع' : rsi < 45 ? '📉  زخم هابط' : '⚖️  محايد'
    table.cell(tbl, 0, 3, '📊  مؤشر RSI  (14)', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 3, str.tostring(math.round(rsi, 1)), bgcolor = #0D0D0D, text_color = rsi_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 3, rsi_t, bgcolor = #0D0D0D, text_color = rsi_c, text_size = size.normal, text_halign = text.align_center)

    // ===== MFI =====
    mfi_c = mfi > 60 ? color.lime : mfi < 40 ? color.red : color.gray
    mfi_t = mfi > 80 ? '⚠️  تشبع شراء' : mfi > 60 ? '💧  تدفق إيجابي' : mfi < 20 ? '⚠️  تشبع بيع' : mfi < 40 ? '💧  تدفق سلبي' : '⚖️  محايد'
    table.cell(tbl, 0, 4, '💧  تدفق الأموال MFI', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 4, str.tostring(math.round(mfi, 1)), bgcolor = #0D0D0D, text_color = mfi_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 4, mfi_t, bgcolor = #0D0D0D, text_color = mfi_c, text_size = size.normal, text_halign = text.align_center)

    // ===== CCI =====
    cci_c = cci > 100 ? color.lime : cci < -100 ? color.red : color.gray
    cci_t = cci > 200 ? '🚀  قوة استثنائية' : cci > 100 ? '⚡  قوي صاعد' : cci < -200 ? '💥  ضغط شديد' : cci < -100 ? '⚡  قوي هابط' : '⚖️  محايد'
    table.cell(tbl, 0, 5, '⚡  مؤشر القوة CCI', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 5, str.tostring(math.round(cci)), bgcolor = #0D0D0D, text_color = cci_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 5, cci_t, bgcolor = #0D0D0D, text_color = cci_c, text_size = size.normal, text_halign = text.align_center)

    // ===== CI =====
    ci_c = ci < 38 ? color.yellow : color.gray
    ci_t = ci < 38 ? '🎯  اتجاه واضح' : ci < 61.8 ? '🌀  ترند محتمل' : '🌊  سوق عشوائي'
    table.cell(tbl, 0, 6, '🌀  مؤشر السرعة CI', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 6, str.tostring(math.round(ci, 1)), bgcolor = #0D0D0D, text_color = ci_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 6, ci_t, bgcolor = #0D0D0D, text_color = ci_c, text_size = size.normal, text_halign = text.align_center)

    // ===== MACD =====
    macd_c = hist > 0 ? color.lime : color.red
    macd_t = hist > 0 ? '📈  زخم صاعد' : '📉  زخم هابط'
    table.cell(tbl, 0, 7, '📈  هيستوغرام MACD', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 7, str.tostring(hist, '#.###'), bgcolor = #0D0D0D, text_color = macd_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 7, macd_t, bgcolor = #0D0D0D, text_color = macd_c, text_size = size.normal, text_halign = text.align_center)

    // ===== Stoch =====
    st_c = stoch > 80 ? color.lime : stoch < 20 ? color.red : color.gray
    st_t = stoch > 80 ? '⚠️  تشبع شراء' : stoch > 50 ? '🎯  ميل صاعد' : stoch < 20 ? '⚠️  تشبع بيع' : '🎯  ميل هابط'
    table.cell(tbl, 0, 8, '🎯  مؤشر ستوكاستك K', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 8, str.tostring(math.round(stoch)), bgcolor = #0D0D0D, text_color = st_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 8, st_t, bgcolor = #0D0D0D, text_color = st_c, text_size = size.normal, text_halign = text.align_center)

    // ===== OBV =====
    obv_up = ta.change(obv) > 0
    obv_c = obv_up ? color.lime : color.red
    obv_t = obv_up ? '🟢  تجميع' : '🔴  تصريف'
    table.cell(tbl, 0, 9, '🔁  حجم التوازن OBV', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 9, obv_up ? 'صاعد ▲' : 'هابط ▼', bgcolor = #0D0D0D, text_color = obv_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 9, obv_t, bgcolor = #0D0D0D, text_color = obv_c, text_size = size.normal, text_halign = text.align_center)

    // ===== فاصل =====
    table.cell(tbl, 0, 10, '━━━━━━━━━━━━━━━━━━━━━', bgcolor = #1A1A1A, text_color = #FFD700, text_size = size.small, text_halign = text.align_center)
    table.cell(tbl, 1, 10, '◆بسم الله الرحمن الرحيم  ◆', bgcolor = #1A1A1A, text_color = #FFD700, text_size = size.small, text_halign = text.align_center)
    table.cell(tbl, 2, 10, '━━━━━━━━━━━━━━━━━━━━━', bgcolor = #1A1A1A, text_color = #FFD700, text_size = size.small, text_halign = text.align_center)

    // ===== ADX =====
    adx_c = adx_val >= 25 ? color.yellow : color.gray
    adx_t = adx_val >= 40 ? '🔥  اتجاه قوي جداً' : adx_val >= 25 ? '💪  اتجاه قوي' : adx_val >= 20 ? '〰️  اتجاه متوسط' : '😴  بدون اتجاه'
    table.cell(tbl, 0, 11, '📡  قوة الاتجاه ADX', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 11, str.tostring(math.round(adx_val, 1)), bgcolor = #0D0D0D, text_color = adx_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 11, adx_t, bgcolor = #0D0D0D, text_color = adx_c, text_size = size.normal, text_halign = text.align_center)

    // ===== قوة الشراء +DI =====
    dip_c = di_plus > di_minus ? color.lime : color.gray
    dip_t = di_plus > di_minus ? '🟢  المشترون أقوى' : '⚪  المشترون أضعف'
    table.cell(tbl, 0, 12, '🟢  قوة الشراء  +DI', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 12, str.tostring(math.round(di_plus, 1)), bgcolor = #0D0D0D, text_color = dip_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 12, dip_t, bgcolor = #0D0D0D, text_color = dip_c, text_size = size.normal, text_halign = text.align_center)

    // ===== قوة البيع -DI =====
    dim_c = di_minus > di_plus ? color.red : color.gray
    dim_t = di_minus > di_plus ? '🔴  البائعون أقوى' : '⚪  البائعون أضعف'
    table.cell(tbl, 0, 13, '🔴  قوة البيع  -DI', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 13, str.tostring(math.round(di_minus, 1)), bgcolor = #0D0D0D, text_color = dim_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 13, dim_t, bgcolor = #0D0D0D, text_color = dim_c, text_size = size.normal, text_halign = text.align_center)

    // ===== RVOL =====
    rvol_c = rvol >= 1.5 ? color.yellow : rvol >= 0.8 ? color.gray : color.red
    rvol_t = rvol >= 2.0 ? '🔥  حجم ضخم جداً' : rvol >= 1.5 ? '📦  حجم مرتفع' : rvol >= 0.8 ? '✅  حجم طبيعي' : '😴  حجم منخفض'
    table.cell(tbl, 0, 14, '📦  الحجم النسبي RVOL', bgcolor = #0D0D0D, text_color = color.white, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 14, str.tostring(math.round(rvol, 2)) + 'x', bgcolor = #0D0D0D, text_color = rvol_c, text_size = size.normal, text_halign = text.align_center)
    table.cell(tbl, 2, 14, rvol_t, bgcolor = #0D0D0D, text_color = rvol_c, text_size = size.normal, text_halign = text.align_center) // ===== ملخص القرار =====

    // نقاط الشراء (من المؤشرات السابقة)
    score_rsi = rsi > 60 ? 2 : rsi > 50 ? 1 : rsi < 40 ? -2 : rsi < 50 ? -1 : 0
    score_mfi = mfi > 60 ? 2 : mfi > 50 ? 1 : mfi < 40 ? -2 : mfi < 50 ? -1 : 0
    score_cci = cci > 100 ? 2 : cci > 0 ? 1 : cci < -100 ? -2 : cci < 0 ? -1 : 0
    score_macd = hist > 0 ? 2 : -2
    score_stoch = stoch > 80 ? 1 : stoch > 50 ? 2 : stoch < 20 ? -1 : stoch < 50 ? -2 : 0
    score_obv = ta.change(obv) > 0 ? 2 : -2
    score_adx = di_plus > di_minus and adx_val > 20 ? 2 : di_plus > di_minus ? 1 : di_minus > di_plus and adx_val > 20 ? -2 : -1
    score_rvol = rvol >= 1.5 and di_plus > di_minus ? 2 : rvol >= 1.5 and di_minus > di_plus ? -2 : 0
    score_liq = daily_net > 0 ? 2 : -2

    total_score = score_rsi + score_mfi + score_cci + score_macd + score_stoch + score_obv + score_adx + score_rvol + score_liq
    // النقاط: من -18 إلى +18

    decision = total_score >= 12 ? '🚀  شراء قوي جداً' : total_score >= 6 ? '✅  ميل للشراء' : total_score >= -5 ? '⚖️  محايد - انتظر' : total_score >= -11 ? '⚠️  ميل للبيع' : '🔴  بيع قوي - ابتعد'

    dec_c = total_score >= 6 ? color.lime : total_score >= -5 ? color.gray : color.red

    score_display = str.tostring(total_score) + ' / 18'

    table.cell(tbl, 0, 15, '🏆  ملخص القرار النهائي', bgcolor = #1C0A00, text_color = #FFD700, text_size = size.normal, text_halign = text.align_left)
    table.cell(tbl, 1, 15, score_display, bgcolor = #1C0A00, text_color = dec_c, text_size = size.large, text_halign = text.align_center)
    table.cell(tbl, 2, 15, decision, bgcolor = #1C0A00, text_color = dec_c, text_size = size.normal, text_halign = text.align_center)

    // ===== وقت آخر تحديث =====
    table.cell(tbl, 0, 16, '🕐  آخر تحديث: ' + str.format_time(timenow, 'HH:mm:ss', 'Asia/Riyadh'), bgcolor = #111111, text_color = color.new(color.gray, 30), text_size = size.small, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 16, 2, 16)

// --- 5. إشارات كول وبوت ---
plotshape(ta.crossover(ta.ema(close, 5), ta.ema(close, 13)) and rsi > 45, 'كول', shape.labelup, location.belowbar, color.lime, text = 'كول', textcolor = color.black, size = size.small)
plotshape(ta.crossunder(ta.ema(close, 5), ta.ema(close, 13)) and rsi < 55, 'بوت', shape.labeldown, location.abovebar, color.red, text = 'بوت', textcolor = color.white, size = size.small)
````
