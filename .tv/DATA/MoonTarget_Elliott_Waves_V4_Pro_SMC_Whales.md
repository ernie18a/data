<!-- tradingview-pine-id: PUB;9a08148624e6414e956ad0fdccb885d6 -->
<!-- tradingviewscripts-format: 1 -->
# MoonTarget Elliott Waves V.4 (Pro SMC & Whales)

Source: https://www.tradingview.com/script/OM0TFWRP-MoonTarget-Elliott-Waves-V-4-Pro-SMC-Whales/

## Description

This script is a highly advanced, all-in-one trading assistant built for TradingView. It does not just draw lines, but it actually reads the market like a professional trader. 🤖

At its core, it uses an **Elliott Wave engine** to track price movements. It spots the *exact* highs and lows to map out impulsive and corrective waves. 🌊

But it gets much smarter than that. It includes **Smart Money Concepts (SMC)** to find hidden bank order blocks. 🏦

It also tracks **RSI divergence** to tell you when a trend is losing its steam. This helps you avoid entering trades at the *wrong* time. 🛑

The trade management system is truly incredible. You can easily set up to **four Take Profit (TP) targets** for your trades. 🎯

Whenever a target is hit, the script *automatically* moves your stop-loss to secure your profits. It basically protects your money while you sleep. 🛡️

There is also a massive, interactive **dashboard** on your screen. It shows your win rate, live profits, and a complete confluence checklist before any trade. 📊

You will also find a built-in **Whale Radar** to measure market volume and liquidity. It tracks global market sessions and counts down to major economic news. 🌍

Finally, it gives you live **AI text alerts** right on the chart. It will gently warn you to wait or tell you when a golden setup is ready to go. ✨
2 days ago
Release Notes
Update Notes: Advanced Trade Management & Smart Auto-Timing

Dynamic Multi-TP System: Users can now select up to 4 Take Profit targets. The script automatically calculates progressive, risk-based spacing for each target to maximize profits during strong trends.

Smart Stop-Loss Trailing: Implemented an automated SL securing mechanism. The SL now perfectly trails your targets (moves to Break-Even at TP1, trails to TP1 when TP2 is hit, etc.) to lock in profits and protect capital.

Visual UI Enhancements: Added dynamic chart labels that instantly update when a target is hit (e.g., "TP1 Hit ✅ Success!") and clearly display when the Stop Loss is secured ("Secured 🛡️").

Automated Global Market Engine: Upgraded the session timer to automatically sync with the specific broker's official server time. It now flawlessly supports 24/7 Crypto markets, handles custom broker hours (like FXCM), and works perfectly during Bar Replay backtesting without any manual time inputs.
2 days ago
Release Notes
Release Notes: Compilation Fix & Smart Multi-Asset Sync

Code Stabilization: Fixed undeclared identifier bugs (liq_status, smart_alert, etc.) to guarantee 100% compilation stability and smooth execution across all charts.

Universal Broker Session Sync: Upgraded the market closing timer to automatically fetch official session times across all asset classes (Forex, Metals, Commodities, Stocks, and Crypto) directly from the broker's daily feed (time_close("D")).

Crypto UI Display Optimization: Added asset-aware visual rules so Crypto instruments clearly display "Open 24/7", preventing any misleading session countdowns.
2 days ago
Release Notes
Release Notes: Universal Timezone Sync for Economic News

Global UTC Timezone Selection: Added a dedicated Timezone option (user_tz) in settings, allowing traders anywhere in the world to select their exact local UTC offset (from UTC-12 to UTC+12).

Accurate News Countdown Engine: Updated the economic news calculations to process times strictly against your chosen local timezone, preventing premature "Released" statuses caused by differing broker server times.
2 days ago
Release Notes
Release Notes: Real-Time Date Sync Fix

Dashboard Header Rollover: Fixed the stats header date display to strictly align with syminfo.timezone.

Accurate Date Roll: Ensures the dashboard date immediately reflects your active chart timezone at midnight, resolving any broker server lag without altering any core trading rules or wave logic.
2 days ago
Release Notes
Release Notes: Higher Timeframe (1D+) Date Resolution Fix

Multi-Timeframe Header Accuracy: Fixed a timestamp offset where Daily (1D) bars and higher timeframes displayed the previous session's date due to early bar-open timestamps.

Real-Time Calendar Sync: The dashboard header date now stays perfectly synced with the current calendar date across all timeframes (from 1m up to 1D and Monthly bars) seamlessly.
2 days ago
Release Notes
Release Notes: Customizable MTF, Sub-Wave Trading & Adjustable RSI

Customizable MTF Filter Timeframe: Replaced the fixed 4H MTF filter with a flexible timeframe selector (mtf_res), allowing traders to evaluate trend alignment across any desired higher timeframe (from 1m up to 1M).

Optional Sub-Wave Trading Mode: Added a new toggle (trade_sub_waves) allowing the execution engine to capture faster entries on internal sub-wave pivots, strictly obeying Elliott Wave entry logic.

Adjustable RSI Thresholds: Exposed RSI buy and sell levels (rsi_buy_level & rsi_sell_level) in inputs so traders can freely customize momentum filter sensitivity.
2 days ago
Release Notes
Release Notes: Precise Local Timezone Date Sync

Dashboard Date Sync: Updated the header date display calculation to bind directly with the user-selected local timezone (user_tz).

Midnight Rollover Fix: Ensures the dashboard date immediately rolls over precisely at local midnight regardless of broker server time, maintaining complete accuracy across all timeframes.
2 days ago
Release Notes
Release Notes: Strict Elliott Wave 4 Invalidation Filter

Wave 4 Overlap & Breach Filter: Added strict validation logic preventing Wave 4 from forming if price breaches the Wave 2 low (pl <= w2_low).

Clean Pattern Recognition: Automatically cancels false wave counts during sharp trend collapses, eliminating chart clutter and keeping trade signals aligned with strict Elliott Wave rules.

---

## Source Code

````pine
//@version=6
indicator("MoonTarget Elliott Waves V.4 (Pro SMC & Whales)", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50)

// ================= إعدادات العرض والتحسينات البصرية =================
grp_disp = "Display Settings / إعدادات العرض"
show_dash = input.bool(true, "Show Dashboard | إظهار اللوحة", group=grp_disp)
dash_size_in = input.string("Small", "Dashboard Size / مقاس اللوحة", options=["Auto Fit (تلقائي)", "Tiny (Mobile)", "Small", "Medium (وسط)", "Normal", "Large", "Huge (عملاق)"], group=grp_disp)
show_conf = input.bool(true, "Show Confluence Checklist | تفاصيل التوافق", group=grp_disp)
show_trade_lines = input.bool(true, "Show Trade Lines | رسم خطوط الصفقات", group=grp_disp)
show_signal_candle = input.bool(true, "Highlight Signal Candles | تلوين شموع الإشارة", group=grp_disp)
show_trade = input.bool(true, "Show Trade Info | إظهار تفاصيل الصفقات", group=grp_disp)
show_stats = input.bool(true, "Show Daily Stats | إظهار الإحصائيات", group=grp_disp)
show_wave = input.bool(true, "Show Wave Info | إظهار معلومات الموجات", group=grp_disp)
show_wave_visual = input.bool(true, "Show Wave Visual in Dash | رسم مسار الموجة باللوحة", group=grp_disp)
show_news = input.bool(true, "Show Economic News | إظهار الأخبار", group=grp_disp)
show_timer = input.bool(true, "Show Market Timer | إظهار مؤقت السوق", group=grp_disp)
show_zigzag = input.bool(true, "Show Main Waves | إظهار الموجات الرئيسية", group=grp_disp)
show_sub_waves = input.bool(true, "Show Sub-Waves | إظهار الموجات الداخلية", group=grp_disp)

// ================= الإضافات الاحترافية (SMC & Fibo & V4) =================
grp_pro = "Pro Features (SMC, Fibo, Div) / الإضافات الاحترافية"
use_mtf_filter = input.bool(true, "Use MTF Filter | فلتر الفريم الأكبر", group=grp_pro)
mtf_res = input.timeframe("240", "MTF Timeframe / فريم الفلتر", group=grp_pro)
use_time_filter = input.bool(true, "Use Time/Volatility Filter | فلتر السيولة الزمني", group=grp_pro)
show_fibo = input.bool(true, "Show Fibo Target (1.618) | هدف فيبوناتشي", group=grp_pro)
show_ob = input.bool(true, "Show Order Blocks (SMC) | الأوردر بلوك", group=grp_pro)
show_div = input.bool(true, "Detect RSI Divergence | كشف الدايفرجنس", group=grp_pro)
show_ai_alert = input.bool(true, "Show Smart AI Alert | تنبيهات الذكاء الاصطناعي", group=grp_pro)

// ================= رادار الفريمات (MTF Radar) =================
grp_radar = "MTF Radar / رادار الفريمات"
show_mtf_radar = input.bool(true, "Enable MTF Radar | إظهار شريط الرادار", group=grp_radar)
r_tf1_en = input.bool(true, "TF 1", inline="r1", group=grp_radar)
r_tf1 = input.timeframe("5", "", inline="r1", group=grp_radar)
r_tf2_en = input.bool(true, "TF 2", inline="r2", group=grp_radar)
r_tf2 = input.timeframe("15", "", inline="r2", group=grp_radar)
r_tf3_en = input.bool(true, "TF 3", inline="r3", group=grp_radar)
r_tf3 = input.timeframe("60", "", inline="r3", group=grp_radar)
r_tf4_en = input.bool(true, "TF 4", inline="r4", group=grp_radar)
r_tf4 = input.timeframe("240", "", inline="r4", group=grp_radar)
r_tf5_en = input.bool(false, "TF 5", inline="r5", group=grp_radar)
r_tf5 = input.timeframe("D", "", inline="r5", group=grp_radar)

// ================= الإعدادات الأساسية =================
grp_lang = "Language & Position / اللغة والمكان"
lang = input.string("English", options=["Arabic", "English"], title="Language / لغة الواجهة", group=grp_lang)
pos_input = input.string("Top Right", "Dashboard Position / مكان اللوحة", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grp_lang)
dash_pos = pos_input == "Top Right" ? position.top_right : pos_input == "Top Left" ? position.top_left : pos_input == "Bottom Right" ? position.bottom_right : position.bottom_left

grp_trade = "Trading Settings / إعدادات التداول"
trade_sub_waves = input.bool(false, "Enable Sub-Wave Trading | تداول الموجات الداخلية", group=grp_trade)
rsi_buy_level = input.int(30, "RSI Buy Level / مستوى الشراء", group=grp_trade)
rsi_sell_level = input.int(70, "RSI Sell Level / مستوى البيع", group=grp_trade)
tp_count = input.int(2, "Number of Targets / عدد الأهداف (1-4)", minval=1, maxval=4, group=grp_trade)
lot_size = input.float(0.01, "Lot Size / حجم العقد", step=0.01, group=grp_trade)
mult_mode = input.string("Auto (Smart MT4 Sizing)", "Contract Multiplier / معامل العقد", options=["Auto (Smart MT4 Sizing)", "Custom"], group=grp_trade)
custom_mult = input.float(100.0, "Custom Multiplier / قيمة المعامل المخصص", group=grp_trade)
rr_ratio = input.float(2.0, "Risk/Reward Ratio / نسبة المخاطرة", step=0.1, group=grp_trade)
wave_length = input.int(12, "Main Wave Sensitivity / حساسية الموجات الكبيرة", group=grp_trade)

grp_wave = "Wave Settings / إعدادات الموجات"
wave_deg = input.string("Minor (1, 2, 3, A, B, C)", "Wave Degree", options=["Minor (1, 2, 3, A, B, C)", "Intermediate ((1), (2), (A))", "Primary ([1], [2], [A])", "Cycle (I, II, III, a, b, c)"], group=grp_wave)

// ================= إعدادات فترة الإحصائيات =================
grp_time = "Stats Period / فترة الإحصائيات"
stats_period = input.string("Today / اليوم", "Calculate Stats For / حساب الإحصائيات لـ", options=["Today / اليوم", "Current Week / هذا الأسبوع", "Current Month / هذا الشهر", "All Time / كل الوقت", "Custom Date / تاريخ مخصص"], group=grp_time)
custom_start = input.time(timestamp("2026-07-01T00:00:00"), "Custom Start Date / تاريخ البداية", group=grp_time)
custom_end   = input.time(timestamp("2026-12-31T23:59:59"), "Custom End Date / تاريخ النهاية", group=grp_time)

// ================= الأخبار والتداول الآلي =================
grp_news = "ECONOMIC NEWS | الأخبار الاقتصادية"
news_title = input.string("Fed Interest Rate", "News Title", group=grp_news)
news_date = input.string("اليوم (Today)", "News Date", options=["اليوم (Today)", "غداً (Tomorrow)", "تاريخ مخصص (Custom Date)"], group=grp_news)
news_custom = input.time(timestamp("2026-08-01T17:00:00"), "Custom News Date / تاريخ مخصص للأخبار", group=grp_news)
news_prev = input.string("53.53%", "Previous", group=grp_news)
news_fore = input.string("54%", "Forecast", group=grp_news)
news_h = input.int(5, "Hour (1-12) (If Today/Tomorrow)", minval=1, maxval=12, group=grp_news)
news_m = input.int(0, "Minute", minval=0, maxval=59, group=grp_news)
news_ampm = input.string("PM", "AM/PM", options=["AM", "PM"], group=grp_news)
user_tz = input.string("UTC+3", "Your Local Timezone / توقيتك المحلي", options=["UTC-12", "UTC-11", "UTC-10", "UTC-9", "UTC-8", "UTC-7", "UTC-6", "UTC-5", "UTC-4", "UTC-3", "UTC-2", "UTC-1", "UTC+0", "UTC+1", "UTC+2", "UTC+3", "UTC+4", "UTC+5", "UTC+6", "UTC+7", "UTC+8", "UTC+9", "UTC+10", "UTC+11", "UTC+12"], group=grp_news)

grp_alerts = "AUTO TRADING ALERTS / التداول الآلي"
buy_msg = input.string("Buy_Signal_Pi", "Buy Alert Message", group=grp_alerts)
sell_msg = input.string("Sell_Signal_Pi", "Sell Alert Message", group=grp_alerts)
min_prob = input.int(60, "Minimum Probability %", group=grp_alerts)

// ================= حساب المعامل الذكي =================
get_contract_size() =>
    float m = 100000.0 // Default for Forex
    string t = syminfo.ticker
    string type = syminfo.type
    if type == "crypto" or str.contains(t, "BTC") or str.contains(t, "ETH")
        m := 1.0
    else if str.contains(t, "XAU") or str.contains(t, "GOLD")
        m := 100.0
    else if str.contains(t, "XAG") or str.contains(t, "SILVER")
        m := 5000.0
    else if str.contains(t, "USOIL") or str.contains(t, "WTI") or str.contains(t, "BRENT")
        m := 1000.0
    else if type == "index" or str.contains(t, "US30") or str.contains(t, "NAS100") or str.contains(t, "SPX")
        m := 10.0
    else if type == "stock"
        m := 1.0
        
    if str.contains(t, "JPY")
        m := m / close
    m

float mult = mult_mode == "Auto (Smart MT4 Sizing)" ? get_contract_size() : custom_mult

// ================= مؤشرات العزم والحيتان (إضافة ATR) =================
rsi_val = ta.rsi(close, 14)
vol_ma = ta.sma(volume, 20)
bool high_vol = volume > (vol_ma * 1.5)
bool low_vol = volume < (vol_ma * 0.8)
bool is_bull_vol = close >= open

atr_val = ta.atr(14)
atr_ma = ta.sma(atr_val, 20)
bool good_volatility = atr_val > atr_ma

// ================= محرك الموجات الداخلية =================
int sub_wl = math.max(3, math.floor(wave_length / 3))
float ph_sub = ta.pivothigh(high, sub_wl, sub_wl)
float pl_sub = ta.pivotlow(low, sub_wl, sub_wl)

var int sub_cycle = 0
var float last_sub_piv_price = na
var int last_sub_piv_time = na
var int last_sub_dir = 0 

if not na(ph_sub) and last_sub_dir != 1
    sub_cycle := sub_cycle >= 8 ? 1 : sub_cycle + 1
    last_sub_dir := 1
    if show_sub_waves and not na(last_sub_piv_time)
        line.new(x1=last_sub_piv_time, y1=last_sub_piv_price, x2=time[sub_wl], y2=ph_sub, xloc=xloc.bar_time, color=color.new(color.white, 50), width=1, style=line.style_dotted)
        string slbl = sub_cycle==1?"i":sub_cycle==2?"ii":sub_cycle==3?"iii":sub_cycle==4?"iv":sub_cycle==5?"v":sub_cycle==6?"a":sub_cycle==7?"b":"c"
        label.new(x=time[sub_wl], y=ph_sub, xloc=xloc.bar_time, text=slbl, style=label.style_label_down, color=color.new(color.black, 100), textcolor=color.yellow, size=size.small)
    last_sub_piv_price := ph_sub
    last_sub_piv_time := time[sub_wl]

if not na(pl_sub) and last_sub_dir != -1
    sub_cycle := sub_cycle >= 8 ? 1 : sub_cycle + 1
    last_sub_dir := -1
    if show_sub_waves and not na(last_sub_piv_time)
        line.new(x1=last_sub_piv_time, y1=last_sub_piv_price, x2=time[sub_wl], y2=pl_sub, xloc=xloc.bar_time, color=color.new(color.white, 50), width=1, style=line.style_dotted)
        string slbl = sub_cycle==1?"i":sub_cycle==2?"ii":sub_cycle==3?"iii":sub_cycle==4?"iv":sub_cycle==5?"v":sub_cycle==6?"a":sub_cycle==7?"b":"c"
        label.new(x=time[sub_wl], y=pl_sub, xloc=xloc.bar_time, text=slbl, style=label.style_label_up, color=color.new(color.black, 100), textcolor=color.yellow, size=size.small)
    last_sub_piv_price := pl_sub
    last_sub_piv_time := time[sub_wl]

// ================= محرك قواعد إليوت و نيلي =================
int wl = wave_length
float ph = ta.pivothigh(high, wl, wl)
float pl = ta.pivotlow(low, wl, wl)

var int wave_cycle = 0 
var int last_pivot = 0 
var float last_piv_price = na
var int last_piv_time = na
var float len_m1 = na
var float len_m2 = na

var float w1_start = na, var float w1_peak = na, var float w2_low = na
var float w3_peak = na, var float w4_low = na, var float w5_peak = na, var float wa_low = na

var float last_rsi_ph = na, var float last_rsi_pl = na
var float ob_bull_top = na, var float ob_bull_bot = na
var float ob_bear_top = na, var float ob_bear_bot = na
var bool active_bull_div = false, var bool active_bear_div = false
var box last_bull_ob = na, var box last_bear_ob = na, var box last_fibo_box = na

bool is_new_ph = not na(ph) and last_pivot != 1
bool is_new_pl = not na(pl) and last_pivot != -1
color line_col = color.new(#00b0ff, 20)

get_w_lbl(cycle, deg) =>
    string lbl = ""
    if deg == "Minor (1, 2, 3, A, B, C)"
        lbl := cycle == 1 ? "1" : cycle == 2 ? "2" : cycle == 3 ? "3" : cycle == 4 ? "4" : cycle == 5 ? "5" : cycle == 6 ? "A" : cycle == 7 ? "B" : "C"
    else if deg == "Intermediate ((1), (2), (A))"
        lbl := cycle == 1 ? "(1)" : cycle == 2 ? "(2)" : cycle == 3 ? "(3)" : cycle == 4 ? "(4)" : cycle == 5 ? "(5)" : cycle == 6 ? "(A)" : cycle == 7 ? "(B)" : "(C)"
    else if deg == "Primary ([1], [2], [A])"
        lbl := cycle == 1 ? "[1]" : cycle == 2 ? "[2]" : cycle == 3 ? "[3]" : cycle == 4 ? "[4]" : cycle == 5 ? "[5]" : cycle == 6 ? "[A]" : cycle == 7 ? "[B]" : "[C]"
    else if deg == "Cycle (I, II, III, a, b, c)"
        lbl := cycle == 1 ? "I" : cycle == 2 ? "II" : cycle == 3 ? "III" : cycle == 4 ? "IV" : cycle == 5 ? "V" : cycle == 6 ? "a" : cycle == 7 ? "b" : "c"
    lbl

get_wave_types(cycle) =>
    string c_type = "", string n_type = ""
    if cycle == 1
        c_type := lang=="Arabic"?"دافعة":"Impulsive", n_type := lang=="Arabic"?"تصحيحية":"Corrective"
    else if cycle == 2
        c_type := lang=="Arabic"?"تصحيحية":"Corrective", n_type := lang=="Arabic"?"دافعة":"Impulsive"
    else if cycle == 3
        c_type := lang=="Arabic"?"دافعة":"Impulsive", n_type := lang=="Arabic"?"تصحيحية":"Corrective"
    else if cycle == 4
        c_type := lang=="Arabic"?"تصحيحية":"Corrective", n_type := lang=="Arabic"?"دافعة":"Impulsive"
    else if cycle == 5
        c_type := lang=="Arabic"?"دافعة":"Impulsive", n_type := lang=="Arabic"?"تصحيح (A)":"Correction (A)"
    else if cycle == 6
        c_type := lang=="Arabic"?"تصحيحية (A)":"Corrective (A)", n_type := lang=="Arabic"?"ارتداد (B)":"Bounce (B)"
    else if cycle == 7
        c_type := lang=="Arabic"?"تصحيحية (B)":"Corrective (B)", n_type := lang=="Arabic"?"هبوط (C)":"Drop (C)"
    else if cycle == 8
        c_type := lang=="Arabic"?"تصحيحية (C)":"Corrective (C)", n_type := lang=="Arabic"?"دورة جديدة":"New Cycle"
    [c_type, n_type]

get_neely_rule(m1_len, m2_len, is_high) =>
    float r = m1_len == 0 ? 0 : m2_len / m1_len
    string rule_txt = "", string struct_txt = "", string ic = ""
    if r < 0.382
        rule_txt := "Rule 1", struct_txt := "Impulsive (:5 / x:c3)", ic := is_high ? "🔻" : "🚀"
    else if r >= 0.382 and r < 0.618
        rule_txt := "Rule 2", struct_txt := "Impulse/Zigzag (:5/:c3/:s5)", ic := is_high ? "🔻" : "🚀"
    else if r >= 0.618 and r <= 0.62
        rule_txt := "Rule 3", struct_txt := "B-Wave/Triangle (:F3/:c3)", ic := "⏳"
    else if r > 0.62 and r < 1.0
        rule_txt := "Rule 4", struct_txt := "Flat/Triangle (:F3/:c3/:s5)", ic := "⏳"
    else if r >= 1.0 and r < 1.618
        rule_txt := "Rule 5", struct_txt := "Irregular Flat (:F3/:c3)", ic := "⚠️"
    else if r >= 1.618 and r <= 2.618
        rule_txt := "Rule 6", struct_txt := "C-Failure (:F3/:c3/:L5)", ic := "⚠️"
    else if r > 2.618
        rule_txt := "Rule 7", struct_txt := "Complex (:F3/:c3)", ic := "⚠️"
    [rule_txt, struct_txt, r, ic]

get_wave_visual(cycle, language) =>
    string here = language == "Arabic" ? "(هنا) 📍" : "📍(Here)"
    string next_w = language == "Arabic" ? "🎯 الهدف" : "Next 🎯"
    string vis = ""
    if cycle == 1
        vis := (language == "Arabic" ? "بداية ↗ 1 " : "Start ↗ 1 ") + here + " ↘ 2 " + next_w
    else if cycle == 2
        vis := "1 ↘ 2 " + here + " ↗ 3 " + next_w
    else if cycle == 3
        vis := "2 ↗ 3 " + here + " ↘ 4 " + next_w
    else if cycle == 4
        vis := "3 ↘ 4 " + here + " ↗ 5 " + next_w
    else if cycle == 5
        vis := "4 ↗ 5 " + here + " ↘ A " + next_w
    else if cycle == 6
        vis := "5 ↘ A " + here + " ↗ B " + next_w
    else if cycle == 7
        vis := "A ↗ B " + here + " ↘ C " + next_w
    else if cycle == 8
        vis := "B ↘ C " + (language == "Arabic" ? " 🚀 1 " : " 🚀 1 ") + next_w
    else
        vis := language == "Arabic" ? "جاري تحليل النمط... ⏳" : "⏳ Waiting for pattern..."
    vis

if is_new_ph
    bool valid = true
    len_m2 := math.abs(ph - last_piv_price)
    [n_rule, n_struct, ret_ratio, w_icon] = get_neely_rule(len_m1, len_m2, true)
    
    active_bear_div := false
    if show_div and wave_cycle >= 3 and ph > last_piv_price and rsi_val[wl] < last_rsi_ph
        active_bear_div := true

    if wave_cycle == 0 or wave_cycle == 8
        wave_cycle := 1, w1_peak := ph, len_m1 := len_m2
    else if wave_cycle == 2
        if ph <= w1_peak 
            valid := false
        else
            wave_cycle := 3, w3_peak := ph, len_m1 := len_m2
    else if wave_cycle == 4
        float w1_len = w1_peak - w1_start
        float w3_len = w3_peak - w2_low
        float w5_len = ph - w4_low
        if w3_len < w1_len and w3_len < w5_len 
            valid := false
        else
            wave_cycle := 5, w5_peak := ph, len_m1 := len_m2
    else if wave_cycle == 6
        wave_cycle := 7, len_m1 := len_m2
    else
        valid := false

    if valid
        last_pivot := 1
        if show_zigzag and not na(last_piv_time)
            line.new(x1=last_piv_time, y1=last_piv_price, x2=time[wl], y2=ph, xloc=xloc.bar_time, color=line_col, width=2, style=line.style_dashed)
        
        if show_ob
            ob_bear_top := high[wl], ob_bear_bot := low[wl]
            if not na(last_bear_ob)
                box.delete(last_bear_ob)
            last_bear_ob := box.new(left=time[wl], top=ob_bear_top, right=time, bottom=ob_bear_bot, xloc=xloc.bar_time, border_color=color.new(color.red, 40), bgcolor=color.new(color.red, 85))
        
        string div_txt = active_bear_div ? "\n(⚡ Div)" : ""
        string full_lbl = w_icon + " " + get_w_lbl(wave_cycle, wave_deg) + "\n" + n_rule + "\n" + n_struct + div_txt + "\n(" + str.tostring(ret_ratio*100, "#.#") + "%)"
        label.new(x=time[wl], y=ph, xloc=xloc.bar_time, text=full_lbl, style=label.style_label_down, color=color.new(#ff1744, 10), textcolor=color.white, size=size.small)
        
        last_piv_price := ph, last_piv_time := time[wl], last_rsi_ph := rsi_val[wl]
    else if wave_cycle != 0
        wave_cycle := 0, last_pivot := 1, len_m1 := len_m2

if is_new_pl
    bool valid = true
    len_m2 := math.abs(last_piv_price - pl)
    [n_rule, n_struct, ret_ratio, w_icon] = get_neely_rule(len_m1, len_m2, false)

    active_bull_div := false
    if show_div and wave_cycle >= 4 and pl < last_piv_price and rsi_val[wl] > last_rsi_pl
        active_bull_div := true

    if wave_cycle == 0
        w1_start := pl, valid := false, last_pivot := -1, len_m1 := len_m2
    else if wave_cycle == 1
        if pl <= w1_start 
            valid := false, w1_start := pl 
        else
            wave_cycle := 2, w2_low := pl, len_m1 := len_m2
    else if wave_cycle == 3
        if pl <= w1_peak or pl <= w2_low
            valid := false, wave_cycle := 0, w1_start := pl
        else
            wave_cycle := 4, w4_low := pl, len_m1 := len_m2
    else if wave_cycle == 5
        wave_cycle := 6, wa_low := pl, len_m1 := len_m2
    else if wave_cycle == 7
        wave_cycle := 8, len_m1 := len_m2
    else
        valid := false, w1_start := pl, len_m1 := len_m2

    if valid and wave_cycle > 0
        last_pivot := -1
        if show_zigzag and not na(last_piv_time)
            line.new(x1=last_piv_time, y1=last_piv_price, x2=time[wl], y2=pl, xloc=xloc.bar_time, color=line_col, width=2, style=line.style_dashed)
        
        if show_ob
            ob_bull_top := high[wl], ob_bull_bot := low[wl]
            if not na(last_bull_ob)
                box.delete(last_bull_ob)
            last_bull_ob := box.new(left=time[wl], top=ob_bull_top, right=time, bottom=ob_bull_bot, xloc=xloc.bar_time, border_color=color.new(color.green, 40), bgcolor=color.new(color.green, 85))

        if show_fibo and wave_cycle == 2
            float fib_target = pl + ((w1_peak - w1_start) * 1.618)
            if not na(last_fibo_box)
                box.delete(last_fibo_box)
            last_fibo_box := box.new(left=time[wl], top=fib_target + (syminfo.mintick*20), right=time, bottom=fib_target - (syminfo.mintick*20), xloc=xloc.bar_time, border_color=color.new(color.blue, 30), bgcolor=color.new(color.blue, 80), text="🎯 Fibo 1.618 Target", text_color=color.white, text_size=size.small)

        string div_txt = active_bull_div ? "\n(⚡ Div)" : ""
        string full_lbl = w_icon + " " + get_w_lbl(wave_cycle, wave_deg) + "\n" + n_rule + "\n" + n_struct + div_txt + "\n(" + str.tostring(ret_ratio*100, "#.#") + "%)"
        label.new(x=time[wl], y=pl, xloc=xloc.bar_time, text=full_lbl, style=label.style_label_up, color=color.new(#00e676, 10), textcolor=color.white, size=size.small)
        
        last_piv_price := pl, last_piv_time := time[wl], last_rsi_pl := rsi_val[wl]
    else if wave_cycle != 0
        wave_cycle := 0, last_pivot := -1, len_m1 := len_m2

if barstate.islast
    if not na(last_bull_ob)
        box.set_right(last_bull_ob, time)
    if not na(last_bear_ob)
        box.set_right(last_bear_ob, time)
    if not na(last_fibo_box)
        box.set_right(last_fibo_box, time)

// ================= إدارة التداول وخطوط الصفقات المحدثة =================
var int total_signals = 0, var int buy_trades = 0, var int sell_trades = 0, var int tp_hits = 0, var int sl_hits = 0, var int be_hits = 0, var float net_profit = 0.0
var bool is_in_trade = false, var int trade_dir = 0, var float active_ep = na, var float active_sl = na, var float active_tp = na
var float active_tp1 = na, var float active_tp2 = na, var float active_tp3 = na, var float active_tp4 = na
var bool tp1_hit = false, var bool tp2_hit = false, var bool tp3_hit = false, var bool tp4_hit = false

float current_pnl = is_in_trade ? (trade_dir == 1 ? close - active_ep : active_ep - close) * mult * lot_size : 0.0
float win_rate = total_signals > 0 ? (tp_hits / total_signals) * 100 : 0.0

var int full_confluence_count = 0

var line ep_line = na, var line sl_line = na
var line tp1_line = na, var line tp2_line = na, var line tp3_line = na, var line tp4_line = na
var label ep_lbl = na, var label sl_lbl = na
var label tp1_lbl = na, var label tp2_lbl = na, var label tp3_lbl = na, var label tp4_lbl = na

bool reset_stats = false
if stats_period == "Today / اليوم"
    reset_stats := ta.change(dayofweek) != 0
else if stats_period == "Current Week / هذا الأسبوع"
    reset_stats := ta.change(weekofyear) != 0
else if stats_period == "Current Month / هذا الشهر"
    reset_stats := ta.change(month) != 0
else if stats_period == "Custom Date / تاريخ مخصص"
    reset_stats := time >= custom_start and time[1] < custom_start

if reset_stats
    total_signals := 0, buy_trades := 0, sell_trades := 0, tp_hits := 0, sl_hits := 0, be_hits := 0, net_profit := 0.0, full_confluence_count := 0

// ================= محرك الأهداف الذكي والمتباعد =================
if is_in_trade
    if trade_dir == 1 
        // 1. فحص وقف الخسارة أولاً (لتجنب إغلاق وهمي في نفس الشمعة)
        if low <= active_sl
            if tp1_hit or tp2_hit or tp3_hit
                be_hits += 1, net_profit += (math.abs(active_sl - active_ep) * mult * lot_size)
            else
                sl_hits += 1, net_profit -= (math.abs(active_ep - active_sl) * mult * lot_size)
            is_in_trade := false
        
        // 2. فحص الأهداف وتسجيل النجاح
        if is_in_trade
            if tp_count >= 1 and high >= active_tp1 and not tp1_hit
                tp1_hit := true
                if tp_count == 1
                    tp_hits += 1, net_profit += (math.abs(active_tp1 - active_ep) * mult * lot_size), is_in_trade := false
            if tp_count >= 2 and high >= active_tp2 and not tp2_hit and is_in_trade
                tp2_hit := true
                if tp_count == 2
                    tp_hits += 1, net_profit += (math.abs(active_tp2 - active_ep) * mult * lot_size), is_in_trade := false
            if tp_count >= 3 and high >= active_tp3 and not tp3_hit and is_in_trade
                tp3_hit := true
                if tp_count == 3
                    tp_hits += 1, net_profit += (math.abs(active_tp3 - active_ep) * mult * lot_size), is_in_trade := false
            if tp_count >= 4 and high >= active_tp4 and not tp4_hit and is_in_trade
                tp4_hit := true
                tp_hits += 1, net_profit += (math.abs(active_tp4 - active_ep) * mult * lot_size), is_in_trade := false
                
        // 3. تأمين وقف الخسارة تدريجياً للشمعة القادمة
        if is_in_trade
            if tp_count >= 4 and tp3_hit
                active_sl := active_tp2
            else if tp_count >= 3 and tp2_hit
                active_sl := active_tp1
            else if tp_count >= 2 and tp1_hit
                active_sl := active_ep + (syminfo.mintick * 20)

    else if trade_dir == -1 
        // 1. فحص وقف الخسارة
        if high >= active_sl
            if tp1_hit or tp2_hit or tp3_hit
                be_hits += 1, net_profit += (math.abs(active_ep - active_sl) * mult * lot_size)
            else
                sl_hits += 1, net_profit -= (math.abs(active_sl - active_ep) * mult * lot_size)
            is_in_trade := false
        
        // 2. فحص الأهداف وتسجيل النجاح
        if is_in_trade
            if tp_count >= 1 and low <= active_tp1 and not tp1_hit
                tp1_hit := true
                if tp_count == 1
                    tp_hits += 1, net_profit += (math.abs(active_ep - active_tp1) * mult * lot_size), is_in_trade := false
            if tp_count >= 2 and low <= active_tp2 and not tp2_hit and is_in_trade
                tp2_hit := true
                if tp_count == 2
                    tp_hits += 1, net_profit += (math.abs(active_ep - active_tp2) * mult * lot_size), is_in_trade := false
            if tp_count >= 3 and low <= active_tp3 and not tp3_hit and is_in_trade
                tp3_hit := true
                if tp_count == 3
                    tp_hits += 1, net_profit += (math.abs(active_ep - active_tp3) * mult * lot_size), is_in_trade := false
            if tp_count >= 4 and low <= active_tp4 and not tp4_hit and is_in_trade
                tp4_hit := true
                tp_hits += 1, net_profit += (math.abs(active_ep - active_tp4) * mult * lot_size), is_in_trade := false

        // 3. تأمين وقف الخسارة
        if is_in_trade
            if tp_count >= 4 and tp3_hit
                active_sl := active_tp2
            else if tp_count >= 3 and tp2_hit
                active_sl := active_tp1
            else if tp_count >= 2 and tp1_hit
                active_sl := active_ep - (syminfo.mintick * 20)

// ================= احتمالية النجاح و MTF Filter =================
bool is_buy_wave_ctx = (wave_cycle % 2 == 0) 
bool is_sell_wave_ctx = (wave_cycle % 2 != 0) 

int base_prob = wave_cycle == 1 ? 75 : wave_cycle == 2 ? 85 : wave_cycle == 3 ? 80 : wave_cycle == 4 ? 85 : wave_cycle == 5 ? 70 : wave_cycle == 6 ? 65 : wave_cycle == 7 ? 85 : 60
int smc_boost = 0
int div_boost = 0
int vol_boost = good_volatility ? 10 : 0

if is_buy_wave_ctx
    if (close <= ob_bull_top and close >= ob_bull_bot)
        smc_boost := 10
    if active_bull_div
        div_boost := 10
else
    if (close <= ob_bear_top and close >= ob_bear_bot)
        smc_boost := 10
    if active_bear_div
        div_boost := 10

int final_prob = math.min(100, base_prob + smc_boost + div_boost + vol_boost)

// حساب التوافق الكامل
bool is_entry_wave_check = (wave_cycle == 2 or wave_cycle == 4 or wave_cycle == 8 or wave_cycle == 5 or wave_cycle == 7 or wave_cycle == 3)
bool current_full_confluence = is_entry_wave_check and (smc_boost > 0) and (div_boost > 0) and good_volatility

if current_full_confluence and not current_full_confluence[1]
    full_confluence_count += 1

ema_mtf = request.security(syminfo.tickerid, mtf_res, ta.ema(close, 200))
rsi_mtf = request.security(syminfo.tickerid, mtf_res, ta.rsi(close, 14))

bool time_ok = not use_time_filter or good_volatility
bool mtf_buy_ok = not use_mtf_filter or (close > ema_mtf) or (rsi_mtf < 40) 
bool mtf_sell_ok = not use_mtf_filter or (close < ema_mtf) or (rsi_mtf > 60) 

bool in_stat_window = true
if stats_period == "Custom Date / تاريخ مخصص"
    in_stat_window := time >= custom_start and time <= custom_end

// --- شروط الشراء ---
bool sub_is_new_pl = not na(pl_sub)
bool sub_is_new_ph = not na(ph_sub)

bool main_buy_cond = is_new_pl and (wave_cycle == 2 or wave_cycle == 4 or wave_cycle == 8) and (rsi_val > rsi_buy_level) and (final_prob >= min_prob) and in_stat_window and mtf_buy_ok and time_ok
bool sub_buy_cond = trade_sub_waves and sub_is_new_pl and (sub_cycle == 2 or sub_cycle == 4 or sub_cycle == 8) and (rsi_val > rsi_buy_level) and (final_prob >= min_prob) and in_stat_window and mtf_buy_ok and time_ok
buy_cond = main_buy_cond or sub_buy_cond

// --- شروط البيع ---
bool is_smart_w3_sell = (wave_cycle == 3) and (active_bear_div or (close <= ob_bear_top and close >= ob_bear_bot))
bool is_regular_sell = (wave_cycle == 5 or wave_cycle == 7)
bool main_sell_cond = is_new_ph and (is_regular_sell or is_smart_w3_sell) and (rsi_val < rsi_sell_level) and (final_prob >= min_prob) and in_stat_window and mtf_sell_ok and time_ok

bool sub_is_smart_w3_sell = (sub_cycle == 3) and (active_bear_div or (close <= ob_bear_top and close >= ob_bear_bot))
bool sub_is_regular_sell = (sub_cycle == 5 or sub_cycle == 7)
bool sub_sell_cond = trade_sub_waves and sub_is_new_ph and (sub_is_regular_sell or sub_is_smart_w3_sell) and (rsi_val < rsi_sell_level) and (final_prob >= min_prob) and in_stat_window and mtf_sell_ok and time_ok
sell_cond = main_sell_cond or sub_sell_cond

if buy_cond
    active_ep := close
    active_sl := main_buy_cond ? last_piv_price : last_sub_piv_price
    float risk_dist = math.abs(active_ep - active_sl)
    // حساب الأهداف مع تباعد حقيقي وقوي
    active_tp1 := active_ep + (risk_dist * rr_ratio)
    active_tp2 := active_ep + (risk_dist * (rr_ratio * 1.5))
    active_tp3 := active_ep + (risk_dist * (rr_ratio * 2.0))
    active_tp4 := active_ep + (risk_dist * (rr_ratio * 2.5))
    
    tp1_hit := false, tp2_hit := false, tp3_hit := false, tp4_hit := false
    is_in_trade := true, trade_dir := 1, total_signals += 1, buy_trades += 1
    alert(buy_msg, alert.freq_once_per_bar_close)
    
    if show_trade_lines
        line.delete(ep_line), line.delete(sl_line)
        line.delete(tp1_line), line.delete(tp2_line), line.delete(tp3_line), line.delete(tp4_line)
        label.delete(ep_lbl), label.delete(sl_lbl)
        label.delete(tp1_lbl), label.delete(tp2_lbl), label.delete(tp3_lbl), label.delete(tp4_lbl)
        
        ep_line := line.new(bar_index, active_ep, bar_index, active_ep, color=color.gray, width=2, style=line.style_dashed)
        sl_line := line.new(bar_index, active_sl, bar_index, active_sl, color=color.new(#ff5252, 0), width=2, style=line.style_solid)
        
        float pot_loss = math.abs(active_ep - active_sl) * mult * lot_size
        ep_lbl := label.new(bar_index, active_ep, "Entry: $0.00", color=color.new(color.black, 100), textcolor=color.white, style=label.style_label_left, size=size.normal)
        sl_lbl := label.new(bar_index, active_sl, "SL: -$" + str.tostring(pot_loss, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#ff5252, 0), style=label.style_label_left, size=size.normal)
        
        if tp_count >= 1
            tp1_line := line.new(bar_index, active_tp1, bar_index, active_tp1, color=color.new(#00e676, 0), width=tp_count==1?2:1, style=tp_count==1?line.style_solid:line.style_dashed)
            float p1 = math.abs(active_tp1 - active_ep) * mult * lot_size
            tp1_lbl := label.new(bar_index, active_tp1, "TP1: +$" + str.tostring(p1, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)
            
        if tp_count >= 2
            tp2_line := line.new(bar_index, active_tp2, bar_index, active_tp2, color=color.new(#00e676, 0), width=tp_count==2?2:1, style=tp_count==2?line.style_solid:line.style_dashed)
            float p2 = math.abs(active_tp2 - active_ep) * mult * lot_size
            tp2_lbl := label.new(bar_index, active_tp2, "TP2: +$" + str.tostring(p2, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)
            
        if tp_count >= 3
            tp3_line := line.new(bar_index, active_tp3, bar_index, active_tp3, color=color.new(#00e676, 0), width=tp_count==3?2:1, style=tp_count==3?line.style_solid:line.style_dashed)
            float p3 = math.abs(active_tp3 - active_ep) * mult * lot_size
            tp3_lbl := label.new(bar_index, active_tp3, "TP3: +$" + str.tostring(p3, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)
            
        if tp_count >= 4
            tp4_line := line.new(bar_index, active_tp4, bar_index, active_tp4, color=color.new(#00e676, 0), width=2, style=line.style_solid)
            float p4 = math.abs(active_tp4 - active_ep) * mult * lot_size
            tp4_lbl := label.new(bar_index, active_tp4, "TP4: +$" + str.tostring(p4, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)

if sell_cond
    active_ep := close
    active_sl := main_sell_cond ? last_piv_price : last_sub_piv_price
    float risk_dist = math.abs(active_sl - active_ep)
    // حساب الأهداف مع تباعد حقيقي وقوي
    active_tp1 := active_ep - (risk_dist * rr_ratio)
    active_tp2 := active_ep - (risk_dist * (rr_ratio * 1.5))
    active_tp3 := active_ep - (risk_dist * (rr_ratio * 2.0))
    active_tp4 := active_ep - (risk_dist * (rr_ratio * 2.5))
    
    tp1_hit := false, tp2_hit := false, tp3_hit := false, tp4_hit := false
    is_in_trade := true, trade_dir := -1, total_signals += 1, sell_trades += 1
    alert(sell_msg, alert.freq_once_per_bar_close)
    
    if show_trade_lines
        line.delete(ep_line), line.delete(sl_line)
        line.delete(tp1_line), line.delete(tp2_line), line.delete(tp3_line), line.delete(tp4_line)
        label.delete(ep_lbl), label.delete(sl_lbl)
        label.delete(tp1_lbl), label.delete(tp2_lbl), label.delete(tp3_lbl), label.delete(tp4_lbl)
        
        ep_line := line.new(bar_index, active_ep, bar_index, active_ep, color=color.gray, width=2, style=line.style_dashed)
        sl_line := line.new(bar_index, active_sl, bar_index, active_sl, color=color.new(#ff5252, 0), width=2, style=line.style_solid)
        
        float pot_loss = math.abs(active_sl - active_ep) * mult * lot_size
        ep_lbl := label.new(bar_index, active_ep, "Entry: $0.00", color=color.new(color.black, 100), textcolor=color.white, style=label.style_label_left, size=size.normal)
        sl_lbl := label.new(bar_index, active_sl, "SL: -$" + str.tostring(pot_loss, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#ff5252, 0), style=label.style_label_left, size=size.normal)
        
        if tp_count >= 1
            tp1_line := line.new(bar_index, active_tp1, bar_index, active_tp1, color=color.new(#00e676, 0), width=tp_count==1?2:1, style=tp_count==1?line.style_solid:line.style_dashed)
            float p1 = math.abs(active_ep - active_tp1) * mult * lot_size
            tp1_lbl := label.new(bar_index, active_tp1, "TP1: +$" + str.tostring(p1, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)
            
        if tp_count >= 2
            tp2_line := line.new(bar_index, active_tp2, bar_index, active_tp2, color=color.new(#00e676, 0), width=tp_count==2?2:1, style=tp_count==2?line.style_solid:line.style_dashed)
            float p2 = math.abs(active_ep - active_tp2) * mult * lot_size
            tp2_lbl := label.new(bar_index, active_tp2, "TP2: +$" + str.tostring(p2, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)
            
        if tp_count >= 3
            tp3_line := line.new(bar_index, active_tp3, bar_index, active_tp3, color=color.new(#00e676, 0), width=tp_count==3?2:1, style=tp_count==3?line.style_solid:line.style_dashed)
            float p3 = math.abs(active_ep - active_tp3) * mult * lot_size
            tp3_lbl := label.new(bar_index, active_tp3, "TP3: +$" + str.tostring(p3, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)
            
        if tp_count >= 4
            tp4_line := line.new(bar_index, active_tp4, bar_index, active_tp4, color=color.new(#00e676, 0), width=2, style=line.style_solid)
            float p4 = math.abs(active_ep - active_tp4) * mult * lot_size
            tp4_lbl := label.new(bar_index, active_tp4, "TP4: +$" + str.tostring(p4, "#.##"), color=color.new(color.black, 100), textcolor=color.new(#00e676, 0), style=label.style_label_left, size=size.normal)

if show_trade_lines
    if is_in_trade
        if not na(ep_line)
            line.set_x2(ep_line, bar_index + 2)
        if not na(sl_line)
            line.set_x2(sl_line, bar_index + 2)
        if not na(tp1_line)
            line.set_x2(tp1_line, bar_index + 2)
        if not na(tp2_line)
            line.set_x2(tp2_line, bar_index + 2)
        if not na(tp3_line)
            line.set_x2(tp3_line, bar_index + 2)
        if not na(tp4_line)
            line.set_x2(tp4_line, bar_index + 2)
            
        if not na(ep_lbl)
            label.set_x(ep_lbl, bar_index + 2)
            string pnl_sign = current_pnl >= 0 ? "+$" : "-$"
            label.set_text(ep_lbl, "Entry (Live: " + pnl_sign + str.tostring(math.abs(current_pnl), "#.##") + ")")
            label.set_textcolor(ep_lbl, current_pnl >= 0 ? color.new(#00e676, 0) : color.new(#ff5252, 0))
        if not na(sl_lbl)
            label.set_x(sl_lbl, bar_index + 2)
        if not na(tp1_lbl)
            label.set_x(tp1_lbl, bar_index + 2)
        if not na(tp2_lbl)
            label.set_x(tp2_lbl, bar_index + 2)
        if not na(tp3_lbl)
            label.set_x(tp3_lbl, bar_index + 2)
        if not na(tp4_lbl)
            label.set_x(tp4_lbl, bar_index + 2)
            
        if tp1_hit or tp2_hit or tp3_hit
            line.set_y1(sl_line, active_sl)
            line.set_y2(sl_line, active_sl)
            line.set_color(sl_line, color.new(color.yellow, 0))
            label.set_y(sl_lbl, active_sl)
            label.set_text(sl_lbl, "SL (Secured 🛡️)")
            label.set_textcolor(sl_lbl, color.new(color.yellow, 0))

    // تحديث علامات الصح والنجاح على الشارت
    if tp1_hit and not na(tp1_lbl)
        line.set_color(tp1_line, color.new(color.gray, 50))
        label.set_text(tp1_lbl, tp_count == 1 ? "TP1 (Hit ✅ Success!)" : "TP1 (Hit ✅)")
        label.set_textcolor(tp1_lbl, color.new(color.gray, 0))
        
    if tp2_hit and not na(tp2_lbl)
        line.set_color(tp2_line, color.new(color.gray, 50))
        label.set_text(tp2_lbl, tp_count == 2 ? "TP2 (Hit ✅ Success!)" : "TP2 (Hit ✅)")
        label.set_textcolor(tp2_lbl, color.new(color.gray, 0))
        
    if tp3_hit and not na(tp3_lbl)
        line.set_color(tp3_line, color.new(color.gray, 50))
        label.set_text(tp3_lbl, tp_count == 3 ? "TP3 (Hit ✅ Success!)" : "TP3 (Hit ✅)")
        label.set_textcolor(tp3_lbl, color.new(color.gray, 0))
        
    if tp4_hit and not na(tp4_lbl)
        line.set_color(tp4_line, color.new(color.gray, 50))
        label.set_text(tp4_lbl, "TP4 (Hit ✅ Success!)")
        label.set_textcolor(tp4_lbl, color.new(color.gray, 0))

barcolor(show_signal_candle and buy_cond ? color.new(#00e676, 0) : show_signal_candle and sell_cond ? color.new(#ff5252, 0) : na)

// ================= تعريف الزمن المتوافق مع إعادة العرض (Replay) =================
int current_time = barstate.isrealtime ? timenow : time
int dash_date_time = math.min(timenow, not na(time_close) ? time_close - 1000 : time)

// ================= وقت الأخبار =================
int target_unix = 0

if news_date == "تاريخ مخصص (Custom Date)"
    target_unix := news_custom
else
    int offset = news_date == "غداً (Tomorrow)" ? 86400000 : 0
    int ref_time = dash_date_time + offset
    int t_y = year(ref_time, user_tz)
    int t_m = month(ref_time, user_tz)
    int t_d = dayofmonth(ref_time, user_tz)
    int h24 = news_ampm == "PM" ? (news_h == 12 ? 12 : news_h + 12) : (news_h == 12 ? 0 : news_h)
    target_unix := timestamp(user_tz, t_y, t_m, t_d, h24, news_m, 0)

int time_left = target_unix - current_time
string countdown_str = time_left > 0 ? (lang=="Arabic" ? "يتبقي: " : "Countdown: ") + str.tostring(math.floor(time_left / 3600000)) + "h " + str.tostring(math.floor((time_left % 3600000) / 60000)) + "m " + str.tostring(math.floor((time_left % 60000) / 1000)) + "s" : (lang=="Arabic" ? "✅ تم الإصدار" : "Released ✅")
bool has_news = time_left > 0 and time_left <= 3600000 

// ================= محرك الأسواق العالمية =================
bool is_crypto = syminfo.type == "crypto" 

int h_utc = hour(current_time, "GMT"), int m_utc = minute(current_time, "GMT"), int s_utc = second(current_time)
int curr_secs = h_utc * 3600 + m_utc * 60 + s_utc

int dow_utc = dayofweek(current_time, "GMT")
int syd_o = 22 * 3600, int syd_c = 7 * 3600
int tok_o = 0 * 3600,  int tok_c = 9 * 3600
int lon_o = 8 * 3600,  int lon_c = 17 * 3600
int ny_o = 13 * 3600,  int ny_c = 22 * 3600

bool is_wknd = not is_crypto and ((dow_utc == 6 and curr_secs >= ny_c) or (dow_utc == 7) or (dow_utc == 1 and curr_secs < syd_o))

bool is_syd = (curr_secs >= syd_o or curr_secs < syd_c) and not is_wknd
bool is_tok = (curr_secs >= tok_o and curr_secs < tok_c) and not is_wknd
bool is_lon = (curr_secs >= lon_o and curr_secs < lon_c) and not is_wknd
bool is_ny  = (curr_secs >= ny_o and curr_secs < ny_c) and not is_wknd

string active_m = ""
if is_syd
    active_m += "Sydney"
if is_tok
    active_m += (active_m == "" ? "" : " & ") + "Tokyo"
if is_lon
    active_m += (active_m == "" ? "" : " & ") + "London"
if is_ny
    active_m += (active_m == "" ? "" : " & ") + "NY"

color active_color = color.green
if active_m == ""
    if is_crypto
        active_m := lang == "Arabic" ? "كريبتو 24/7 🟢" : "Crypto 24/7 🟢"
        active_color := color.green
    else
        active_m := lang == "Arabic" ? "🔴 مغلق (إجازة أسبوعية)" : "Closed (Weekend) 🔴"
        active_color := color.red
else
    active_m := active_m + " 🟢"

int min_close_secs = 999999
string closing_m = ""
if not is_wknd
    if is_syd
        int diff = syd_c - curr_secs
        if diff < 0
            diff += 86400
        if diff < min_close_secs
            min_close_secs := diff, closing_m := "Sydney"
    if is_tok
        int diff = tok_c - curr_secs
        if diff < 0
            diff += 86400
        if diff < min_close_secs
            min_close_secs := diff, closing_m := "Tokyo"
    if is_lon
        int diff = lon_c - curr_secs
        if diff < 0
            diff += 86400
        if diff < min_close_secs
            min_close_secs := diff, closing_m := "London"
    if is_ny
        int diff = ny_c - curr_secs
        if diff < 0
            diff += 86400
        if diff < min_close_secs
            min_close_secs := diff, closing_m := "NY"

int min_open_secs = 999999
string opening_m = ""
get_open_diff(target_secs) =>
    int diff = target_secs - curr_secs
    if diff <= 0
        diff += 86400
    diff

if is_wknd
    int days_to_sun = dow_utc == 6 ? 2 : (dow_utc == 7 ? 1 : 0)
    int target_unix_wk = timestamp("GMT", year(current_time, "GMT"), month(current_time, "GMT"), dayofmonth(current_time, "GMT") + days_to_sun, 22, 0, 0)
    min_open_secs := math.floor((target_unix_wk - current_time) / 1000)
    opening_m := "Sydney"
else
    if not is_syd
        int diff = get_open_diff(syd_o)
        if diff < min_open_secs
            min_open_secs := diff, opening_m := "Sydney"
    if not is_tok
        int diff = get_open_diff(tok_o)
        if diff < min_open_secs
            min_open_secs := diff, opening_m := "Tokyo"
    if not is_lon
        int diff = get_open_diff(lon_o)
        if diff < min_open_secs
            min_open_secs := diff, opening_m := "London"
    if not is_ny
        int diff = get_open_diff(ny_o)
        if diff < min_open_secs
            min_open_secs := diff, opening_m := "NY"

format_time(secs, is_market_open) =>
    int h = math.floor(secs / 3600), int m = math.floor((secs % 3600) / 60), int s = secs % 60
    if is_market_open
        (h >= 24 ? str.tostring(math.floor(h/24)) + "d " : "") + str.tostring(h % 24, "00") + ":" + str.tostring(m, "00") + ":" + str.tostring(s, "00")
    else
        (h >= 24 ? str.tostring(math.floor(h/24)) + "d " : "") + str.tostring(h % 24, "00") + "h " + str.tostring(m, "00") + "m"

// ================= جلب بيانات رادار الفريمات (MTF Radar) =================
bool is_buy_wave_radar = (wave_cycle == 2 or wave_cycle == 4 or wave_cycle == 8)
bool is_sell_wave_radar = (wave_cycle == 5 or wave_cycle == 7 or wave_cycle == 3)

bool is_cooking_buy = not is_in_trade and is_buy_wave_radar and final_prob >= min_prob
bool is_cooking_sell = not is_in_trade and is_sell_wave_radar and final_prob >= min_prob

// دالة صارمة لإجبار المنصة على مزامنة البيانات التراكمية (Strict State Sync)
get_mtf_data(tf) =>
    request.security(syminfo.tickerid, tf, [is_in_trade, trade_dir, is_cooking_buy, is_cooking_sell], barmerge.gaps_off, barmerge.lookahead_off)

[in1, dir1, c_b1, c_s1] = get_mtf_data(r_tf1)
[in2, dir2, c_b2, c_s2] = get_mtf_data(r_tf2)
[in3, dir3, c_b3, c_s3] = get_mtf_data(r_tf3)
[in4, dir4, c_b4, c_s4] = get_mtf_data(r_tf4)
[in5, dir5, c_b5, c_s5] = get_mtf_data(r_tf5)

format_tf(tf) =>
    tf == "1" ? "1m" : tf == "3" ? "3m" : tf == "5" ? "5m" : tf == "15" ? "15m" : tf == "30" ? "30m" : tf == "45" ? "45m" : tf == "60" ? "1H" : tf == "120" ? "2H" : tf == "240" ? "4H" : tf == "D" ? "1D" : tf == "W" ? "1W" : tf == "M" ? "1M" : tf

get_radar_status(en, tf, in_trade, t_dir, c_b, c_s) =>
    string str = ""
    if en
        if in_trade
            str := format_tf(tf) + (t_dir == 1 ? " 🟢⬆️" : " 🔴⬇️")
        else if c_b
            str := format_tf(tf) + " ⏳🟢"
        else if c_s
            str := format_tf(tf) + " ⏳🔴"
    str

// ================= حالة الشارت وعداداته (أوتوماتيك 100%) =================
int session_close = time_close("D") // جلب وقت إغلاق الشمعة اليومية من سيرفر البروكر مباشرة
int ms_to_close = not na(session_close) ? session_close - current_time : 0

bool market_open = false
if barstate.isrealtime
    market_open := ms_to_close > 0 or is_crypto // Crypto is always open
else
    market_open := not na(time) or is_crypto // في وضع الإعادة، طالما هناك شمعة فالسوق مفتوح

string market_status = market_open ? (lang=="Arabic"?"🟢 مفتوح":"MARKET OPEN 🟢") : (lang=="Arabic"?"🔴 السوق قافل":"MARKET CLOSED 🔴")
color market_color = market_open ? color.green : color.red

string market_event_str = "00:00:00"
if is_crypto
    market_event_str := lang=="Arabic" ? "مفتوح 24/7" : "Open 24/7"
else if market_open and ms_to_close > 0
    int d_m = math.floor(ms_to_close / 86400000)
    int h_m = math.floor((ms_to_close % 86400000) / 3600000)
    int m_m = math.floor((ms_to_close % 3600000) / 60000)
    int s_m = math.floor((ms_to_close % 60000) / 1000)
    market_event_str := (d_m > 0 ? str.tostring(d_m) + "d " : "") + str.tostring(h_m, "00") + ":" + str.tostring(m_m, "00") + ":" + str.tostring(s_m, "00")
else
    market_event_str := lang=="Arabic"?"مغلق الآن":"CLOSED"

string event_lbl = market_open ? (lang=="Arabic"?"إغلاق الشارت:":"Chart Closes in:") : (lang=="Arabic"?"إغلاق الشارت:":"Chart Closes in:")

if not market_open and not is_crypto
    market_event_str := lang=="Arabic" ? "راجع الافتتاح العالمي بالأسفل" : "See Global Open below"

string next_open_str = is_crypto ? (lang == "Arabic" ? "مفتوح 24/7" : "Open 24/7") : (opening_m != "" ? (opening_m + " in: " + format_time(min_open_secs, market_open)) : "---")
string next_close_str = is_crypto ? (lang == "Arabic" ? "لا يوجد إغلاق" : "No Close") : (closing_m != "" ? (closing_m + " in: " + format_time(min_close_secs, market_open)) : "---")

if lang == "Arabic"
    if is_crypto
        next_open_str := "مفتوح 24/7"
        next_close_str := "لا يوجد إغلاق"
    else
        string ar_o_name = opening_m == "Sydney" ? "سيدني" : opening_m == "Tokyo" ? "طوكيو" : opening_m == "London" ? "لندن" : "نيويورك"
        next_open_str := opening_m != "" ? ("افتتاح " + ar_o_name + " خلال: " + format_time(min_open_secs, market_open)) : "---"
        string ar_c_name = closing_m == "Sydney" ? "سيدني" : closing_m == "Tokyo" ? "طوكيو" : closing_m == "London" ? "لندن" : "نيويورك"
        next_close_str := closing_m != "" ? ("إغلاق " + ar_c_name + " خلال: " + format_time(min_close_secs, market_open)) : "---"

// ================= رادار الحيتان والذكاء الاصطناعي (محدث بالفلاتر) =================
bool early_lon = (curr_secs >= lon_o and curr_secs <= lon_o + 3600) and not is_wknd
bool early_ny  = (curr_secs >= ny_o and curr_secs <= ny_o + 3600) and not is_wknd
string liq_status = ""
color liq_color = color.white

if (opening_m == "London" or opening_m == "NY") and min_open_secs <= 1800
    liq_status := lang == "Arabic" ? "سيولة متوقعة (أصفر = الأسواق الكبرى ستفتح قريباً) ⏳" : "⏳ Expected Liquidity (Yellow = Major Markets Opening Soon)"
    liq_color := color.yellow
else if early_lon or early_ny or good_volatility
    if high_vol
        liq_status := lang == "Arabic" ? (is_bull_vol ? "سيولة عالية (أخضر = شمعة صاعدة ونشاط قوي) 🔥" : "سيولة عالية (أحمر = شمعة هابطة ونشاط قوي) 🔥") : (is_bull_vol ? "🔥 High Liquidity (Green = Bullish & Strong Activity)" : "🔥 High Liquidity (Red = Bearish & Strong Activity)")
        liq_color := is_bull_vol ? color.green : color.red
    else if low_vol
        liq_status := lang == "Arabic" ? "سيولة ضعيفة (رمادي = السوق بطيء ومفيش حركة) 💤" : "💤 Weak Liquidity (Gray = Slow Market, No Action)"
        liq_color := color.gray
    else
        liq_status := lang == "Arabic" ? "سيولة متوسطة وجيدة (أزرق = حركة سوق معتادة) ⚖️" : "⚖️ Normal/Good Liquidity (Blue = Standard Market Action)"
        liq_color := color.new(#00b0ff,0)
else
    if high_vol
        liq_status := lang == "Arabic" ? "سيولة مفاجئة (برتقالي = نشاط قوي وحجم تداول غير معتاد) ⚡" : "⚡ Sudden Liquidity (Orange = Strong Unusual Activity)"
        liq_color := color.orange
    else
        liq_status := lang == "Arabic" ? "سيولة طبيعية (رمادي = حركة سوق معتادة) ⚖️" : "⚖️ Normal Liquidity (Gray = Standard Market Action)"
        liq_color := color.gray

if has_news
    liq_status := liq_status + (lang == "Arabic" ? " 📰 أخبار +" : " + News 📰")

string smart_alert = ""
color alert_color = color.white

bool alert_buy_ctx = (wave_cycle % 2 == 0)
bool alert_sell_ctx = (wave_cycle % 2 != 0)

if high_vol and wave_cycle == 2 and is_bull_vol
    smart_alert := lang == "Arabic" ? "الحيتان تضخ سيولة شرائية! استعد لانفجار الموجة 3 🚀" : "🚀 Whales Buying! Get ready for Wave 3 breakout."
    alert_color := color.green
else if alert_sell_ctx and active_bear_div and wave_cycle >= 3
    smart_alert := lang == "Arabic" ? "عزم المشتريين انتهى (دايفرجنس سلبي)! استعد لهبوط عنيف ⚠️" : "⚠️ Buyers exhausted (Bear Div)! Prepare for drop."
    alert_color := color.red
else if alert_buy_ctx and active_bull_div
    smart_alert := lang == "Arabic" ? "عزم البائعين انتهى (دايفرجنس إيجابي)! استعد لصعود قوي 🚀" : "🚀 Sellers exhausted (Bull Div)! Prepare for pump."
    alert_color := color.green
else if alert_buy_ctx and (close <= ob_bull_top and close >= ob_bull_bot)
    smart_alert := lang == "Arabic" ? "السعر داخل منطقة أوردر بلوك شرائية. فرصة ارتداد صاعد! 🏦" : "🏦 Price in Bull Bank Order Block. Bounce expected!"
    alert_color := color.green
else if alert_sell_ctx and (close <= ob_bear_top and close >= ob_bear_bot)
    smart_alert := lang == "Arabic" ? "السعر داخل منطقة أوردر بلوك بيعية. فرصة هبوط! 🏦" : "🏦 Price in Bear Bank Order Block. Drop expected!"
    alert_color := color.red
else
    smart_alert := lang == "Arabic" ? "جاري مراقبة السيولة والأنماط... 👀" : "👀 Monitoring liquidity and patterns..."
    alert_color := color.gray

// ================= بناء الداشبورد الكامل =================
int ms_candle = time_close(timeframe.period) - current_time
string candle_timer_str = ""
if ms_candle > 0
    int d_c = math.floor(ms_candle / 86400000), int h_c = math.floor((ms_candle % 86400000) / 3600000), int m_c = math.floor((ms_candle % 3600000) / 60000), int s_c = math.floor((ms_candle % 60000) / 1000)
    candle_timer_str := (d_c > 0 ? str.tostring(d_c) + "d " : "") + str.tostring(h_c, "00") + ":" + str.tostring(m_c, "00") + ":" + str.tostring(s_c, "00")
else
    candle_timer_str := lang == "Arabic" ? "🔴 السوق قافل" : "Market Closed 🔴"

var table dash = table.new(dash_pos, 4, 50, bgcolor=color.new(#1e222d, 5), border_width=1, border_color=color.new(#363a45, 0))

if show_dash and barstate.islast
    c_w = color.white, c_g = color.new(#00e676, 0), c_r = color.new(#ff5252, 0), c_y = color.new(#ffeb3b, 0), c_bg = color.new(#131722, 0), c_title = color.new(#2a2e39, 0), c_or = color.new(#ff9800, 0), c_gray = color.new(#b2b5be, 0)
    int r = 0 
    
    string t_size = dash_size_in == "Auto Fit (تلقائي)" ? size.auto : dash_size_in == "Tiny (Mobile)" ? size.tiny : dash_size_in == "Small" ? size.small : dash_size_in == "Medium (وسط)" ? size.normal : dash_size_in == "Normal" ? size.normal : dash_size_in == "Large" ? size.large : size.huge
    string a_left = lang == "Arabic" ? text.align_right : text.align_left

    string stats_header = stats_period == "Today / اليوم" ? (lang == "Arabic" ? "إحصائيات اليوم" : "Today's Stats") : stats_period == "Current Week / هذا الأسبوع" ? (lang == "Arabic" ? "إحصائيات الأسبوع" : "Week's Stats") : stats_period == "Current Month / هذا الشهر" ? (lang == "Arabic" ? "إحصائيات الشهر" : "Month's Stats") : stats_period == "All Time / كل الوقت" ? (lang == "Arabic" ? "كل الإحصائيات" : "All Time Stats") : (lang == "Arabic" ? "إحصائيات مخصصة" : "Custom Stats")

    table.merge_cells(dash, 0, r, 3, r), table.cell(dash, 0, r, "♦ MoonTarget Elliott Waves V.4 (Advanced Stats Tracker) ♦", text_color=c_or, text_halign=text.align_center, bgcolor=c_title, text_size=t_size), r += 1
    table.cell(dash, 0, r, syminfo.ticker + " " + timeframe.period, text_color=c_or, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
    table.cell(dash, 1, r, str.tostring(close, format.mintick), text_color=c_g, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? stats_header : "", text_color=c_or, text_halign=text.align_center, bgcolor=show_stats?na:c_bg, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(year(current_time, user_tz))+"/"+str.tostring(month(current_time, user_tz))+"/"+str.tostring(dayofmonth(current_time, user_tz)) : "", text_color=c_y, text_halign=text.align_center, bgcolor=show_stats?na:c_bg, text_size=t_size), r += 1

    string tp_lbl_txt = tp_count > 1 ? (lang=="Arabic" ? "الأهداف (TP1-TP" + str.tostring(tp_count) + ")" : "Targets (TP1-TP" + str.tostring(tp_count) + ")") : (lang=="Arabic" ? "الهدف (TP1)" : "Target (TP1)")
    string tp_val_txt = "-"
    color tp_val_col = c_gray
    if is_in_trade
        tp_val_txt := ""
        if tp_count >= 1
            tp_val_txt += str.tostring(active_tp1, format.mintick) + (tp1_hit ? "✅" : "")
        if tp_count >= 2
            tp_val_txt += " | " + str.tostring(active_tp2, format.mintick) + (tp2_hit ? "✅" : "")
        if tp_count >= 3
            tp_val_txt += "\n" + str.tostring(active_tp3, format.mintick) + (tp3_hit ? "✅" : "")
        if tp_count >= 4
            tp_val_txt += " | " + str.tostring(active_tp4, format.mintick) + (tp4_hit ? "✅" : "")
            
        bool final_hit = (tp_count == 1 and tp1_hit) or (tp_count == 2 and tp2_hit) or (tp_count == 3 and tp3_hit) or (tp_count == 4 and tp4_hit)
        bool any_hit = tp1_hit or tp2_hit or tp3_hit or tp4_hit
        tp_val_col := final_hit ? c_g : (any_hit ? color.yellow : c_w)

    table.cell(dash, 0, r, show_trade ? tp_lbl_txt : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 1, r, show_trade ? tp_val_txt : "", text_color=tp_val_col, text_halign=text.align_center, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"إجمالي الإشارات":"Total Signals") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(total_signals) : "", text_color=c_w, text_halign=text.align_center, bgcolor=show_stats?color.new(c_w, 90):na, text_size=t_size), r += 1

    table.cell(dash, 0, r, show_trade ? (lang=="Arabic"?"سعر الدخول":"Entry Price") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 1, r, show_trade ? (is_in_trade ? str.tostring(active_ep, format.mintick) : "-") : "", text_color=c_r, text_halign=text.align_center, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"أهداف محققة ✓":"✓ TP Hits") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(tp_hits) : "", text_color=tp_hits>0?c_w:c_g, text_halign=text.align_center, bgcolor=(show_stats and tp_hits>0)?color.new(c_g, 70):na, text_size=t_size), r += 1

    table.cell(dash, 0, r, show_trade ? (lang=="Arabic"?"(SL) وقف الخسارة":"Stop Loss (SL)") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    
    string sl_dash_txt = "-"
    color sl_dash_col = c_r
    if is_in_trade
        if tp1_hit or tp2_hit or tp3_hit
            sl_dash_txt := str.tostring(active_sl, format.mintick) + " 🛡️"
            sl_dash_col := color.yellow
        else
            sl_dash_txt := str.tostring(active_sl, format.mintick)

    table.cell(dash, 1, r, show_trade ? sl_dash_txt : "", text_color=sl_dash_col, text_halign=text.align_center, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"خسائر ✗":"✗ SL Hits") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(sl_hits) : "", text_color=sl_hits>0?c_w:c_r, text_halign=text.align_center, bgcolor=(show_stats and sl_hits>0)?color.new(c_r, 70):na, text_size=t_size), r += 1

    table.cell(dash, 0, r, "", bgcolor=show_trade?c_bg:na, text_size=t_size), table.cell(dash, 1, r, "", bgcolor=show_trade?c_bg:na, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"(BE) تعادل ⚖":"⚖ Break-Even (BE)") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(be_hits) : "", text_color=be_hits>0?c_bg:c_y, text_halign=text.align_center, bgcolor=(show_stats and be_hits>0)?color.new(c_y, 30):na, text_size=t_size), r += 1

    table.cell(dash, 0, r, show_trade ? (lang=="Arabic"?"الربح اللحظي":"Current PnL") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 1, r, show_trade ? (is_in_trade ? (current_pnl >= 0 ? "+$" : "-$") + str.tostring(math.abs(current_pnl), "#.##") : "$0.0") : "", text_color=current_pnl >= 0 ? c_g : c_r, text_halign=text.align_center, bgcolor=show_trade?c_title:na, text_size=t_size)
    table.cell(dash, 2, r, "", bgcolor=show_stats?c_bg:na, text_size=t_size), table.cell(dash, 3, r, "", bgcolor=show_stats?c_bg:na, text_size=t_size), r += 1

    table.cell(dash, 0, r, show_trade ? (lang=="Arabic"?"حجم العقد:":"Lot Size:") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 1, r, show_trade ? str.tostring(lot_size) : "", text_color=c_w, text_halign=text.align_center, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"إجمالي صافي الربح":"Total Net Profit") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? (net_profit >= 0 ? "+$" : "-$") + str.tostring(math.abs(net_profit), "#.##") : "", text_color=net_profit >= 0 ? c_g : c_r, text_halign=text.align_center, text_size=t_size), r += 1

    table.cell(dash, 0, r, "", bgcolor=show_trade?c_bg:na, text_size=t_size), table.cell(dash, 1, r, "", bgcolor=show_trade?c_bg:na, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"نسبة النجاح:":"Win Rate:") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(win_rate, "#.#") + "%" : "", text_color=c_g, text_halign=text.align_center, text_size=t_size), r += 1

    trade_status = is_in_trade ? (trade_dir == 1 ? (lang=="Arabic"?"شراء نشط !!":"BUY ACTIVE !!") : (lang=="Arabic"?"بيع نشط !!":"SELL ACTIVE !!")) : (lang=="Arabic"?"انتظار":"WAITING")
    if is_in_trade and (tp1_hit or tp2_hit or tp3_hit)
        trade_status := trade_status + (lang=="Arabic" ? " (مؤمنة 🛡️)" : " (Secured 🛡️)")
        
    status_bg = is_in_trade ? (trade_dir == 1 ? color.new(c_g, 40) : color.new(c_r, 40)) : na
    
    table.cell(dash, 0, r, show_trade ? (lang=="Arabic"?"حالة الصفقة:":"Trade Status:") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 1, r, show_trade ? trade_status : "", text_color=is_in_trade ? c_w : c_gray, text_halign=text.align_center, bgcolor=show_trade?status_bg:na, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"صفقات الشراء":"Buy Trades") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(buy_trades) : "", text_color=c_g, text_halign=text.align_center, text_size=t_size), r += 1

    // ================= شريط التقدم لنسبة النجاح =================
    string prob_desc = ""
    color prob_color = c_g
    if final_prob >= 90
        prob_desc := lang == "Arabic" ? " (ممتازة 🚀)" : " (Excellent 🚀)"
        prob_color := color.new(#00e676, 0)
    else if final_prob >= 80
        prob_desc := lang == "Arabic" ? " (قوية 🔥)" : " (Strong 🔥)"
        prob_color := color.new(#00e676, 0)
    else if final_prob >= 70
        prob_desc := lang == "Arabic" ? " (جيدة 👍)" : " (Good 👍)"
        prob_color := color.new(#ffeb3b, 0)
    else if final_prob >= 60
        prob_desc := lang == "Arabic" ? " (مقبولة ⚠️)" : " (Fair ⚠️)"
        prob_color := color.new(#ff9800, 0)
    else
        prob_desc := lang == "Arabic" ? " (ضعيفة ❌)" : " (Weak ❌)"
        prob_color := color.new(#ff5252, 0)
        
    string pb_str = "\n"
    int filled = math.round(final_prob / 10)
    for i = 1 to 10
        pb_str += (i <= filled ? "█" : "▒")

    table.cell(dash, 0, r, show_trade ? (lang=="Arabic"?"النجاح المتوقع:":"Success Prob:") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 1, r, show_trade ? str.tostring(final_prob) + "%" + prob_desc + pb_str : "", text_color=prob_color, text_halign=text.align_center, text_size=t_size)
    table.cell(dash, 2, r, show_stats ? (lang=="Arabic"?"صفقات البيع":"Sell Trades") : "", text_color=c_w, text_halign=a_left, text_size=t_size)
    table.cell(dash, 3, r, show_stats ? str.tostring(sell_trades) : "", text_color=c_r, text_halign=text.align_center, text_size=t_size), r += 1

    // ================= إضافة الرادار هنا (مكانه الجديد) =================
    if show_mtf_radar
        string s1 = get_radar_status(r_tf1_en, r_tf1, in1, dir1, c_b1, c_s1)
        string s2 = get_radar_status(r_tf2_en, r_tf2, in2, dir2, c_b2, c_s2)
        string s3 = get_radar_status(r_tf3_en, r_tf3, in3, dir3, c_b3, c_s3)
        string s4 = get_radar_status(r_tf4_en, r_tf4, in4, dir4, c_b4, c_s4)
        string s5 = get_radar_status(r_tf5_en, r_tf5, in5, dir5, c_b5, c_s5)
        
        string radar_str = s1
        radar_str += (radar_str != "" and s2 != "" ? " | " : "") + s2
        radar_str += (radar_str != "" and s3 != "" ? " | " : "") + s3
        radar_str += (radar_str != "" and s4 != "" ? " | " : "") + s4
        radar_str += (radar_str != "" and s5 != "" ? " | " : "") + s5
        
        if radar_str == ""
            radar_str := lang == "Arabic" ? "لا توجد إشارات حالياً 📡" : "No Signals 📡"
            
        table.merge_cells(dash, 0, r, 3, r)
        table.cell(dash, 0, r, "📡 MTF Radar: " + radar_str, text_color=color.white, text_halign=text.align_center, bgcolor=color.new(#1e222d, 0), text_size=t_size), r += 1

    // ================= تفاصيل التوافق (Confluence Checklist) =================
    if show_conf
        table.merge_cells(dash, 0, r, 3, r)
        table.cell(dash, 0, r, lang=="Arabic"?"✅ شروط التوافق (Confluence Checklist) ✅":"✅ CONFLUENCE CHECKLIST ✅", text_color=c_y, text_halign=text.align_center, bgcolor=color.new(#001944, 0), text_size=t_size), r += 1

        bool is_buy_wave = (wave_cycle == 2 or wave_cycle == 4 or wave_cycle == 8)
        bool is_sell_wave = (wave_cycle == 5 or wave_cycle == 7 or wave_cycle == 3)
        string w_status = (is_buy_wave or is_sell_wave) ? (lang=="Arabic"?"موجة دخول 🟢":"Entry Wave 🟢") : (lang=="Arabic"?"غير مناسبة 🔴":"Not Entry 🔴")
        
        table.cell(dash, 0, r, lang=="Arabic"?"1. قوة الموجة:":"1. Wave Base:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 1, r, str.tostring(base_prob) + "%", text_color=c_g, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 2, r, lang=="Arabic"?"حالة الموجة:":"Wave Status:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 3, r, w_status, text_color=(is_buy_wave or is_sell_wave) ? c_g : c_r, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

        string ob_status = smc_boost > 0 ? (lang=="Arabic"?"متوافق 🟢":"Active 🟢") : (lang=="Arabic"?"غير متوافق 🔴":"Missing 🔴")
        table.cell(dash, 0, r, lang=="Arabic"?"2. أوردر بلوك:":"2. Order Block:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 1, r, "+10%", text_color=c_or, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 2, r, lang=="Arabic"?"دعم بنكي:":"SMC Support:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 3, r, ob_status, text_color=smc_boost > 0 ? c_g : c_r, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

        string div_status = div_boost > 0 ? (lang=="Arabic"?"متوافق 🟢":"Active 🟢") : (lang=="Arabic"?"غير متوافق 🔴":"Missing 🔴")
        table.cell(dash, 0, r, lang=="Arabic"?"3. دايفرجنس:":"3. RSI Div:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 1, r, "+10%", text_color=c_or, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 2, r, lang=="Arabic"?"تأكيد العزم:":"Momentum:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 3, r, div_status, text_color=div_boost > 0 ? c_g : c_r, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

        bool ready_buy = is_buy_wave and (rsi_val > rsi_buy_level) and (final_prob >= min_prob) and in_stat_window and mtf_buy_ok and time_ok
        bool ready_sell = (is_regular_sell or is_smart_w3_sell) and (rsi_val < rsi_sell_level) and (final_prob >= min_prob) and in_stat_window and mtf_sell_ok and time_ok
        
        string advice_icon = ready_buy ? "🚀" : ready_sell ? "🩸" : "⏳"
        string conf_icon = final_prob >= 90 ? "💎" : final_prob >= 80 ? "🔥" : final_prob >= 70 ? "👍" : "⚠️"
        string advice_msg = ""
        
        if ready_buy
            advice_msg := lang=="Arabic" ? "🟢 نصيحة: إشتري الآن | قوة: " + str.tostring(final_prob) + "% " + conf_icon + " | التوافق الكامل: " + str.tostring(full_confluence_count) + " ⚡💎" : "🟢 ADVICE: BUY NOW | Pwr: " + str.tostring(final_prob) + "% " + conf_icon + " | Full Conf: " + str.tostring(full_confluence_count) + " ⚡💎"
        else if ready_sell
            advice_msg := lang=="Arabic" ? "🔴 نصيحة: بيع الآن | قوة: " + str.tostring(final_prob) + "% " + conf_icon + " | التوافق الكامل: " + str.tostring(full_confluence_count) + " ⚡💎" : "🔴 ADVICE: SELL NOW | Pwr: " + str.tostring(final_prob) + "% " + conf_icon + " | Full Conf: " + str.tostring(full_confluence_count) + " ⚡💎"
        else
            advice_msg := lang=="Arabic" ? "⏳ نصيحة: إنتظر | قوة: " + str.tostring(final_prob) + "% " + conf_icon + " | التوافق الكامل: " + str.tostring(full_confluence_count) + " ⚡💎" : "⏳ ADVICE: WAIT | Pwr: " + str.tostring(final_prob) + "% " + conf_icon + " | Full Conf: " + str.tostring(full_confluence_count) + " ⚡💎"
            
        color advice_bg = ready_buy ? color.new(#00e676, 80) : ready_sell ? color.new(#ff5252, 80) : color.new(#311b92, 0)
        color advice_txt_c = ready_buy ? color.new(#00e676, 0) : ready_sell ? color.new(#ff5252, 0) : color.yellow
        
        table.merge_cells(dash, 0, r, 3, r)
        table.cell(dash, 0, r, advice_msg, text_color=advice_txt_c, text_halign=text.align_center, bgcolor=advice_bg, text_size=t_size), r += 1

    if show_wave
        table.merge_cells(dash, 0, r, 3, r)
        table.cell(dash, 0, r, lang=="Arabic"?"🌊 ELLIOTT WAVES قواعد 🌊":"🌊 ELLIOTT WAVES 🌊", text_color=c_y, text_halign=text.align_center, bgcolor=color.new(#001944, 0), text_size=t_size), r += 1
        
        bool curr_is_high = (wave_cycle % 2 != 0)
        int safe_cycle = wave_cycle == 0 ? 1 : wave_cycle
        [c_type, n_type] = get_wave_types(safe_cycle)
        [n_rule, n_struct, ret_ratio, w_icon] = get_neely_rule(len_m1, len_m2, curr_is_high)
        
        string c_lbl = get_w_lbl(wave_cycle, wave_deg)
        string n_lbl = get_w_lbl(wave_cycle == 8 ? 1 : wave_cycle + 1, wave_deg)
        string current_txt = c_lbl != "" and c_type != "" ? w_icon + " " + c_lbl + " (" + c_type + ")" : (c_lbl != "" ? w_icon + " " + c_lbl : (lang=="Arabic"?"انتظار":"Waiting"))
        string next_txt = n_lbl != "" and n_type != "" ? n_lbl + " (" + n_type + ")" : (n_lbl != "" ? n_lbl : "-")

        table.cell(dash, 0, r, lang=="Arabic"?"الموجة الحالية:":"Current Wave:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 1, r, current_txt, text_color=c_or, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 2, r, lang=="Arabic"?"المتوقعة:":"Expected Next:", text_color=color.new(#00b0ff,0), text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 3, r, next_txt, text_color=color.new(#00b0ff,0), text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1
        
        table.cell(dash, 0, r, lang=="Arabic"?"قاعدة التراجع:":"Retrace Rule:", text_color=color.new(#00b0ff,0), text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 1, r, n_rule != "" ? n_rule : "-", text_color=color.new(#00b0ff,0), text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 2, r, lang=="Arabic"?"الشكل المتوقع:":"Pattern Name:", text_color=color.new(#00b0ff,0), text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 3, r, n_struct != "" ? n_struct : "-", text_color=color.new(#00b0ff,0), text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

        if show_wave_visual
            table.merge_cells(dash, 0, r, 3, r)
            table.cell(dash, 0, r, get_wave_visual(safe_cycle, lang), text_color=color.yellow, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

    if show_news
        table.merge_cells(dash, 0, r, 3, r), table.cell(dash, 0, r, (lang=="Arabic"? news_title + " :أخبار اليوم 📊 " : "📊 Today's News: " + news_title), text_color=c_y, text_halign=text.align_center, bgcolor=color.new(#001944, 0), text_size=t_size), r += 1
        table.cell(dash, 0, r, (lang=="Arabic"?"السابق: ":"Previous: ") + news_prev, text_color=c_w, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.cell(dash, 1, r, (lang=="Arabic"?"المتوقع: ":"Forecast: ") + news_fore, text_color=c_w, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 2, r, 3, r)
        table.cell(dash, 2, r, countdown_str, text_color=time_left > 0 ? color.new(#ff9800, 0) : color.new(#00e676, 0), text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

    if show_timer
        table.merge_cells(dash, 0, r, 3, r), table.cell(dash, 0, r, lang=="Arabic"?"🌍 رادار الحيتان والأسواق 🌍":"🌍 WHALES & MARKETS RADAR 🌍", text_color=c_y, text_halign=text.align_center, bgcolor=color.new(#001944, 0), text_size=t_size), r += 1
        
        // --- 1. حالة الشارت وعداداته الأساسية ---
        table.cell(dash, 0, r, lang=="Arabic"?"حالة الشارت:":"Chart Status:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, market_status, text_color=market_color, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1
        
        table.cell(dash, 0, r, event_lbl, text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, market_event_str + (market_open and ms_to_close > 0 and not is_crypto ? " ⏳" : ""), text_color=c_or, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

        // --- 2. رادار السيولة والحيتان ---
        table.cell(dash, 0, r, lang=="Arabic"?"رادار السيولة:":"Whales Radar:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, liq_status, text_color=liq_color, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1
        
        // --- 3. الأسواق العالمية ---
        table.cell(dash, 0, r, lang=="Arabic"?"الأسواق النشطة:":"Active Markets:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, active_m, text_color=active_color, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1
        
        table.cell(dash, 0, r, lang=="Arabic"?"الافتتاح العالمي:":"Global Open:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, lang=="Arabic" ? "⏳ " + next_open_str : next_open_str + " ⏳", text_color=color.new(#ff9800, 0), text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

        table.cell(dash, 0, r, lang=="Arabic"?"الإغلاق العالمي:":"Global Close:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, lang=="Arabic" ? "⏳ " + next_close_str : next_close_str + " ⏳", text_color=c_or, text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1
        
        // --- 4. عداد الشمعة ---
        table.cell(dash, 0, r, lang=="Arabic"?"إغلاق الشمعة:":"Candle Closes in:", text_color=c_w, text_halign=a_left, bgcolor=c_bg, text_size=t_size)
        table.merge_cells(dash, 1, r, 3, r)
        table.cell(dash, 1, r, candle_timer_str, text_color=color.new(#00b0ff,0), text_halign=text.align_center, bgcolor=c_bg, text_size=t_size), r += 1

    if show_ai_alert
        table.merge_cells(dash, 0, r, 3, r)
        table.cell(dash, 0, r, "💡 AI Alert: " + smart_alert, text_color=alert_color, text_halign=text.align_center, bgcolor=color.new(#311b92, 0), text_size=t_size), r += 1
````
