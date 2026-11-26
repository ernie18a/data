# Last Low/High Targets X966 v1.4

- url: https://www.tradingview.com/script/1ulzceoX-Last-Low-High-Targets-X966-v1-4/
- type: indicator
- pine_id: PUB;fe4b0d0fddec4af58bd6c46a869ccc19
- version: 1.0

## Description

# X966 – Last Low/High → W3 Targets

X966 is a market structure indicator designed to identify high-probability trading opportunities using **LL → HL** and **HH → LH** formations, followed by confirmed breakout or retest entries.

## How it works

* Detects significant swing highs and swing lows.
* Identifies Higher Low (HL) and Lower High (LH) structures.
* Automatically plots the breakout/entry level.
* Waits for a confirmed breakout or retest based on user settings.
* Projects TP1, TP2, and TP3 using either Fibonacci Expansion or ATR.
* Calculates an automatic invalidation/stop-loss level.
* Assigns a Quality Score based on market structure, breakout confirmation, displacement, volume, and optional higher-timeframe trend bias.

## Features

* Supports both Long and Short setups.
* Multiple entry modes: Breakout, Retest, or Both.
* Late Breakout Capture to detect breakouts occurring before pivot confirmation.
* Automatic Risk/Reward calculation.
* Built-in dashboard displaying setup status, quality score, entry, stop-loss, and targets.
* Smart confirmed-bar alerts in both English and Arabic.

**Disclaimer:** This indicator is designed to assist market structure analysis and trade planning. It should be used alongside sound risk management and overall market context rather than as a standalone trading system.



# X966 – Last Low/High → W3 Targets

مؤشر يعتمد على تحليل هيكل السوق (Market Structure) لاكتشاف فرص الشراء والبيع بعد تكوّن نماذج **LL → HL** أو **HH → LH**، ثم ينتظر تأكيد الاختراق قبل إعطاء إشارة دخول مع أهداف ووقف خسارة محسوبة تلقائياً.

### آلية العمل

* يحدد آخر القيعان والقمم المهمة.
* يكتشف تكوّن **Higher Low (HL)** أو **Lower High (LH)**.
* يرسم مستوى الاختراق (Entry / Break Level).
* ينتظر اختراق أو إعادة اختبار حسب الإعدادات.
* يحسب أهداف TP1 و TP2 و TP3 باستخدام **Fibonacci Projection** أو **ATR**.
* يحدد وقف الخسارة (Invalidation / Stop Loss) تلقائياً.
* يعطي **Quality Score** لتقييم قوة الفرصة اعتماداً على هيكل السوق، الاختراق، الزخم (Displacement)، الحجم (Volume)، واتجاه الفريم الأكبر (HTF Bias) عند تفعيلها.

### المميزات

✅ يدعم صفقات الشراء والبيع.
✅ اختيار الدخول عند الاختراق أو إعادة الاختبار أو الاثنين معاً.
✅ التقاط الاختراقات التي حدثت قبل تأكيد المحور (Late Breakout Capture).
✅ أهداف تلقائية مع حساب نسبة العائد إلى المخاطرة (Risk/Reward).
✅ لوحة معلومات تعرض حالة الصفقة والجودة والأهداف.
✅ تنبيهات ذكية بالعربي والإنجليزي بعد إغلاق الشمعة لتقليل الإشارات الوهمية.

### ملاحظة

المؤشر أداة تساعد على قراءة هيكل السوق، وليس نظام تداول آلي. يفضل استخدامه مع إدارة رأس مال مناسبة والتأكيد من حركة السعر والسياق العام للسوق.

## Source Code

````pine
//@version=6
indicator('Last Low/High → W3 Targets · X966 v1.4', 'LL/HH→W3 · X966', overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ============================================================
// X966 v1.4 CHANGELOG
// [BRAND] Telegram: @dr_basl
// [NEW-1] Direction Mode: Long | Short | Both
// [NEW-2] Entry Mode: Breakout | Retest | Breakout + Retest
// [NEW-3] Invalidation Mode: Wick | Close
// [NEW-4] Late Breakout Capture: catches breakouts that happened during pivot confirmation delay
// [NEW-5] Quality Score: Structure + Breakout + Displacement + Volume + HTF Bias
// [NEW-6] RR dashboard: Entry / SL / TP1-3 / RR / Quality
// [NEW-7] Short mirror model: HH → LH → break LL → downside targets
// [KEEP] Pine v6, confirmed-only alerts, AR/EN alerts, Theme-Aware Colors Engine, f_clamp255(float)
// ============================================================

//──────────────────────────────────────────────────────────────────────────────
// Settings
//──────────────────────────────────────────────────────────────────────────────
grp_calc = 'Calculation'
min_len_input = input.int(2, 'Min Length', minval = 1, group = grp_calc)
max_len_input = input.int(10, 'Max Length', minval = 2, group = grp_calc)
priority_mode = input.string('Lowest Break Level', 'Priority Mode', options = ['Lowest Break Level', 'Highest Break Level', 'Longest Length', 'Shortest Length', 'Most Recent'], group = grp_calc)
direction_mode = input.string('Long', 'Direction Mode', options = ['Long', 'Short', 'Both'], group = grp_calc)
entry_mode = input.string('Breakout', 'Entry Mode', options = ['Breakout', 'Retest', 'Breakout + Retest'], group = grp_calc)
invalidation_mode = input.string('Close', 'Invalidation Mode', options = ['Close', 'Wick'], group = grp_calc, tooltip = 'Close = invalidate only after confirmed close through SL. Wick = invalidate if wick pierces SL on confirmed bar.')
allow_late_breakout = input.bool(true, 'Capture Late Breakout After Pivot Confirmation', group = grp_calc)

// Targets Settings
grp_tgt = 'Targets Engine'
target_mode = input.string('Fibonacci', 'Target Mode', options = ['Fibonacci', 'ATR'], group = grp_tgt, tooltip = 'Fibonacci: project wave-1 from wave-2. ATR: volatility-scaled targets from Entry.')
show_tp3 = input.bool(true, 'Show TP3 (extended)', group = grp_tgt)

fib_target1 = input.float(1.0, 'Fib TP1 Ratio', step = 0.1, group = grp_tgt)
fib_target2 = input.float(1.272, 'Fib TP2 Ratio', step = 0.1, group = grp_tgt)
fib_target3 = input.float(1.618, 'Fib TP3 Ratio', step = 0.1, group = grp_tgt)

atr_len = input.int(14, 'ATR Length', minval = 1, group = grp_tgt)
atr_mult1 = input.float(1.5, 'ATR TP1 Mult', step = 0.1, group = grp_tgt)
atr_mult2 = input.float(3.0, 'ATR TP2 Mult', step = 0.1, group = grp_tgt)
atr_mult3 = input.float(4.5, 'ATR TP3 Mult', step = 0.1, group = grp_tgt)

col_tp1 = input.color(color.green, 'TP1 Color', group = grp_tgt)
col_tp2 = input.color(color.teal, 'TP2 Color', group = grp_tgt)
col_tp3 = input.color(color.blue, 'TP3 Color', group = grp_tgt)
col_sl = input.color(color.red, 'Stop Loss Color', group = grp_tgt)
lblSize_targets = input.string(size.small, 'Targets Text Size', options = [size.tiny, size.small, size.normal, size.large], group = grp_tgt)

// Quality Settings
grp_quality = 'Quality Filters / Score'
use_score_gate = input.bool(true, 'Gate Alerts By Score', group = grp_quality)
min_alert_score = input.int(70, 'Minimum Alert Score', minval = 0, maxval = 100, group = grp_quality)

use_displacement = input.bool(true, 'Use Displacement Score', group = grp_quality)
disp_atr_mult = input.float(0.15, 'Displacement ATR Mult', minval = 0.0, step = 0.05, group = grp_quality, tooltip = 'Long: close must exceed entry by ATR×mult. Short: close must close below entry by ATR×mult.')

use_volume_score = input.bool(false, 'Use Volume Score', group = grp_quality)
volume_len = input.int(20, 'Volume SMA Length', minval = 1, group = grp_quality)
volume_mult = input.float(1.2, 'Volume Multiplier', minval = 0.1, step = 0.1, group = grp_quality)

use_htf_bias = input.bool(false, 'Use HTF Bias Score', group = grp_quality)
htf_tf = input.timeframe('240', 'HTF Bias Timeframe', group = grp_quality)
htf_ema_len = input.int(200, 'HTF EMA Length', minval = 1, group = grp_quality)

// Visibility Settings
grp_vis = 'Visibility Settings'
show_LL = input.bool(true, 'Show LL Label', group = grp_vis)
show_HL = input.bool(true, 'Show HL Label', group = grp_vis)
show_HH = input.bool(true, 'Show HH Label', group = grp_vis)
show_LH = input.bool(true, 'Show LH Label', group = grp_vis)
show_Trend = input.bool(true, 'Show Trendline', group = grp_vis)
show_PLine = input.bool(true, 'Show Break / Entry Line', group = grp_vis)
show_PLabel = input.bool(true, 'Show Break / Entry Price', group = grp_vis)
show_Targets = input.bool(true, 'Show Targets & Stop Loss', group = grp_vis)
show_dashboard = input.bool(true, 'Show Quality Dashboard', group = grp_vis)

// Labels / Lines
grp_lbl = 'Label Settings'
lblSize = input.string(size.small, 'Pivot Text Size', options = [size.tiny, size.small, size.normal, size.large], group = grp_lbl)
col_LLHL = input.color(color.gray, 'Structure Text Color', group = grp_lbl)
col_PivText = input.color(color.orange, 'Entry Price Color', group = grp_lbl)

grp_line = 'Line Settings'
col_Trend = input.color(color.gray, 'Trendline Color', group = grp_line)
width_Trend = input.int(1, 'Trendline Width', minval = 1, group = grp_line)
style_Trend = input.string(line.style_dashed, 'Trendline Style', options = [line.style_solid, line.style_dashed, line.style_dotted], group = grp_line)
col_Pivot = input.color(color.orange, 'Entry Line Color', group = grp_line)
width_Pivot = input.int(2, 'Entry Line Width', minval = 1, group = grp_line)
style_Pivot = input.string(line.style_solid, 'Entry Line Style', options = [line.style_solid, line.style_dashed, line.style_dotted], group = grp_line)

// Alerts
grp_alert = 'Alerts'
enable_alerts = input.bool(true, 'Enable Dynamic Alert (AR/EN)', group = grp_alert)

//──────────────────────────────────────────────────────────────────────────────
// X966 Theme-Aware Colors Engine
//──────────────────────────────────────────────────────────────────────────────
grp_theme = 'Theme Engine (X966)'
useThemeAware = input.bool(true, 'Theme-Aware Colors', group = grp_theme)
themeMode = input.string('Auto', 'Theme Mode', options = ['Auto', 'Dark', 'Light'], group = grp_theme)

f_clamp255(float v) =>
    math.max(0, math.min(255, int(v)))

f_darkenColor(color c, float factor) =>
    color.rgb(f_clamp255(color.r(c) * (1.0 - factor)), f_clamp255(color.g(c) * (1.0 - factor)), f_clamp255(color.b(c) * (1.0 - factor)), color.t(c))

f_brightenColor(color c, float factor) =>
    color.rgb(f_clamp255(color.r(c) + (255.0 - color.r(c)) * factor), f_clamp255(color.g(c) + (255.0 - color.g(c)) * factor), f_clamp255(color.b(c) + (255.0 - color.b(c)) * factor), color.t(c))

float themeLuminance = 0.299 * color.r(chart.bg_color) + 0.587 * color.g(chart.bg_color) + 0.114 * color.b(chart.bg_color)
bool isDarkTheme = themeMode == 'Auto' ? themeLuminance < 128.0 : themeMode == 'Dark'

color themeTextColor = isDarkTheme ? color.rgb(235, 235, 235) : color.rgb(30, 30, 30)
color themeAccentColor = isDarkTheme ? color.rgb(255, 190, 90) : color.rgb(200, 120, 0)
color themeBgColor = isDarkTheme ? color.rgb(20, 22, 28) : color.rgb(250, 250, 250)
color themeMutedColor = isDarkTheme ? color.rgb(140, 145, 155) : color.rgb(110, 115, 125)
color themePanelBg = isDarkTheme ? color.new(color.rgb(20, 22, 28), 15) : color.new(color.rgb(250, 250, 250), 15)

f_adaptColor(color c) =>
    not useThemeAware ? c : isDarkTheme ? f_brightenColor(c, 0.20) : f_darkenColor(c, 0.15)

color c_tp1_fx = f_adaptColor(col_tp1)
color c_tp2_fx = f_adaptColor(col_tp2)
color c_tp3_fx = f_adaptColor(col_tp3)
color c_sl_fx = f_adaptColor(col_sl)
color c_struct_fx = useThemeAware ? themeMutedColor : col_LLHL
color c_entry_fx = useThemeAware ? themeAccentColor : col_PivText
color c_trend_fx = useThemeAware ? themeMutedColor : col_Trend
color c_entryline_fx = f_adaptColor(col_Pivot)

//──────────────────────────────────────────────────────────────────────────────
// Types
//──────────────────────────────────────────────────────────────────────────────
type LongState
    int len
    float prev_low
    int prev_idx
    float curr_low
    int curr_idx
    bool is_setup
    float break_val
    int break_idx
    bool breakout_seen
    int breakout_idx
    bool breakout_event
    bool late_breakout_event
    bool retest_event


type ShortState
    int len
    float prev_high
    int prev_idx
    float curr_high
    int curr_idx
    bool is_setup
    float break_val
    int break_idx
    bool breakout_seen
    int breakout_idx
    bool breakout_event
    bool late_breakout_event
    bool retest_event


type Drawings
    line trendLine
    line entryLine
    label entryLabel
    label prevLabel
    label currLabel
    line tp1Line
    line tp2Line
    line tp3Line
    line slLine
    label tp1Label
    label tp2Label
    label tp3Label
    label slLabel

method clear(Drawings d) =>
    line.delete(d.trendLine)
    line.delete(d.entryLine)
    label.delete(d.entryLabel)
    label.delete(d.prevLabel)
    label.delete(d.currLabel)
    line.delete(d.tp1Line)
    line.delete(d.tp2Line)
    line.delete(d.tp3Line)
    line.delete(d.slLine)
    label.delete(d.tp1Label)
    label.delete(d.tp2Label)
    label.delete(d.tp3Label)
    label.delete(d.slLabel)
    d.trendLine := na
    d.entryLine := na
    d.entryLabel := na
    d.prevLabel := na
    d.currLabel := na
    d.tp1Line := na
    d.tp2Line := na
    d.tp3Line := na
    d.slLine := na
    d.tp1Label := na
    d.tp2Label := na
    d.tp3Label := na
    d.slLabel := na

//──────────────────────────────────────────────────────────────────────────────
// Globals
//──────────────────────────────────────────────────────────────────────────────
var LongState[] longStates = array.new<LongState>()
var ShortState[] shortStates = array.new<ShortState>()

int eff_min_len = math.min(min_len_input, max_len_input)
int eff_max_len = math.max(min_len_input, max_len_input)

if bar_index == 0
    for i = eff_min_len to eff_max_len
        array.push(longStates, LongState.new(i, na, na, na, na, false, na, na, false, na, false, false, false))
        array.push(shortStates, ShortState.new(i, na, na, na, na, false, na, na, false, na, false, false, false))

var Drawings dr = Drawings.new()
var int last_drawn_signature = 0
var string last_alerted_key = ''
var table dash = table.new(position.top_right, 2, 9, border_width = 1)

float atr_val = ta.atr(atr_len)
float vol_sma = ta.sma(volume, volume_len)
float htf_close = request.security(syminfo.tickerid, htf_tf, close[1], lookahead = barmerge.lookahead_off)
float htf_ema = request.security(syminfo.tickerid, htf_tf, ta.ema(close, htf_ema_len)[1], lookahead = barmerge.lookahead_off)

//──────────────────────────────────────────────────────────────────────────────
// Utility functions
//──────────────────────────────────────────────────────────────────────────────
f_longBreakoutInWindow(float level, int fromIdx) =>
    bool found = false
    if allow_late_breakout and not na(level) and not na(fromIdx)
        int startIdx = math.max(fromIdx + 1, bar_index - 4990)
        int endIdx = bar_index
        if endIdx >= startIdx
            for i = startIdx to endIdx
                int off = bar_index - i
                if off >= 0 and off + 1 < 4990
                    if close[off] > level and close[off + 1] <= level
                        found := true
    found

f_shortBreakoutInWindow(float level, int fromIdx) =>
    bool found = false
    if allow_late_breakout and not na(level) and not na(fromIdx)
        int startIdx = math.max(fromIdx + 1, bar_index - 4990)
        int endIdx = bar_index
        if endIdx >= startIdx
            for i = startIdx to endIdx
                int off = bar_index - i
                if off >= 0 and off + 1 < 4990
                    if close[off] < level and close[off + 1] >= level
                        found := true
    found

f_computeTargets(int dir, float entry, float prevPivot, float currPivot, float atrv) =>
    float tp1 = na
    float tp2 = na
    float tp3 = na
    float sl = currPivot
    if dir == 1
        if target_mode == 'Fibonacci'
            float wave1 = entry - prevPivot
            tp1 := currPivot + wave1 * fib_target1
            tp2 := currPivot + wave1 * fib_target2
            tp3 := currPivot + wave1 * fib_target3
        else
            tp1 := entry + atrv * atr_mult1
            tp2 := entry + atrv * atr_mult2
            tp3 := entry + atrv * atr_mult3
    else
        if target_mode == 'Fibonacci'
            float wave1 = prevPivot - entry
            tp1 := currPivot - wave1 * fib_target1
            tp2 := currPivot - wave1 * fib_target2
            tp3 := currPivot - wave1 * fib_target3
        else
            tp1 := entry - atrv * atr_mult1
            tp2 := entry - atrv * atr_mult2
            tp3 := entry - atrv * atr_mult3
    [tp1, tp2, tp3, sl]

f_rr(float entry, float sl, float tp) =>
    float risk = math.abs(entry - sl)
    risk > 0 ? math.abs(tp - entry) / risk : na

f_qualityName(int score) =>
    score >= 85 ? 'HIGH' : score >= 70 ? 'VALID' : score >= 60 ? 'WATCH' : 'LOW'

f_qualityColor(int score) =>
    score >= 85 ? c_tp1_fx : score >= 70 ? c_entry_fx : score >= 60 ? c_tp2_fx : c_sl_fx

f_score(int dir, bool isSetup, bool breakoutSeen, float entry) =>
    bool dispOk = dir == 1 ? close > entry + atr_val * disp_atr_mult : close < entry - atr_val * disp_atr_mult
    bool volOk = not na(vol_sma) and volume >= vol_sma * volume_mult
    bool htfOk = dir == 1 ? htf_close > htf_ema : htf_close < htf_ema
    int score = 0
    score += isSetup ? 25 : 0
    score += breakoutSeen ? 25 : 0
    score += use_displacement ? (dispOk ? 20 : 0) : 20
    score += use_volume_score ? (volOk ? 15 : 0) : 15
    score += use_htf_bias ? (htfOk ? 15 : 0) : 15
    score

//──────────────────────────────────────────────────────────────────────────────
// State update methods
//──────────────────────────────────────────────────────────────────────────────
method updateLong(LongState st) =>
    st.breakout_event := false
    st.late_breakout_event := false
    st.retest_event := false

    float p = ta.pivotlow(low, st.len, st.len)
    if not na(p)
        bool is_hl = not na(st.curr_low) and p > st.curr_low

        st.prev_low := st.curr_low
        st.prev_idx := st.curr_idx
        st.curr_low := p
        st.curr_idx := bar_index - st.len
        st.is_setup := is_hl
        st.break_val := na
        st.break_idx := na
        st.breakout_seen := false
        st.breakout_idx := na

        if is_hl and not na(st.prev_idx)
            float max_h = na
            int max_h_idx = na
            int start_scan = math.max(st.prev_idx + 1, bar_index - 4990)
            int end_scan = st.curr_idx - 1
            if end_scan >= start_scan
                for i = start_scan to end_scan
                    int off = bar_index - i
                    if off >= 0 and off < 4990
                        float val = high[off]
                        if na(max_h) or val > max_h
                            max_h := val
                            max_h_idx := i
            st.break_val := max_h
            st.break_idx := max_h_idx

    if barstate.isconfirmed
        if st.is_setup and not na(st.curr_low)
            bool invalid = invalidation_mode == 'Close' ? close < st.curr_low : low < st.curr_low
            if invalid
                st.is_setup := false
                st.breakout_seen := false
                st.breakout_idx := na
                if low < st.curr_low
                    st.curr_low := low
                    st.curr_idx := bar_index

            if not invalid and not na(st.break_val)
                bool breakNow = close > st.break_val and close[1] <= st.break_val
                bool lateNow = allow_late_breakout and not st.breakout_seen and close > st.break_val and f_longBreakoutInWindow(st.break_val, st.curr_idx)
                if breakNow
                    st.breakout_event := true
                    st.breakout_seen := true
                    st.breakout_idx := bar_index
                if not breakNow and lateNow
                    st.late_breakout_event := true
                    st.breakout_seen := true
                    st.breakout_idx := bar_index

                bool retestNow = st.breakout_seen and not na(st.breakout_idx) and bar_index > st.breakout_idx and low <= st.break_val and close > st.break_val
                if retestNow
                    st.retest_event := true
        if (not st.is_setup or na(st.curr_low)) and not na(st.curr_low) and low < st.curr_low
            st.curr_low := low
            st.curr_idx := bar_index
    true

method updateShort(ShortState st) =>
    st.breakout_event := false
    st.late_breakout_event := false
    st.retest_event := false

    float p = ta.pivothigh(high, st.len, st.len)
    if not na(p)
        bool is_lh = not na(st.curr_high) and p < st.curr_high

        st.prev_high := st.curr_high
        st.prev_idx := st.curr_idx
        st.curr_high := p
        st.curr_idx := bar_index - st.len
        st.is_setup := is_lh
        st.break_val := na
        st.break_idx := na
        st.breakout_seen := false
        st.breakout_idx := na

        if is_lh and not na(st.prev_idx)
            float min_l = na
            int min_l_idx = na
            int start_scan = math.max(st.prev_idx + 1, bar_index - 4990)
            int end_scan = st.curr_idx - 1
            if end_scan >= start_scan
                for i = start_scan to end_scan
                    int off = bar_index - i
                    if off >= 0 and off < 4990
                        float val = low[off]
                        if na(min_l) or val < min_l
                            min_l := val
                            min_l_idx := i
            st.break_val := min_l
            st.break_idx := min_l_idx

    if barstate.isconfirmed
        if st.is_setup and not na(st.curr_high)
            bool invalid = invalidation_mode == 'Close' ? close > st.curr_high : high > st.curr_high
            if invalid
                st.is_setup := false
                st.breakout_seen := false
                st.breakout_idx := na
                if high > st.curr_high
                    st.curr_high := high
                    st.curr_idx := bar_index

            if not invalid and not na(st.break_val)
                bool breakNow = close < st.break_val and close[1] >= st.break_val
                bool lateNow = allow_late_breakout and not st.breakout_seen and close < st.break_val and f_shortBreakoutInWindow(st.break_val, st.curr_idx)
                if breakNow
                    st.breakout_event := true
                    st.breakout_seen := true
                    st.breakout_idx := bar_index
                if not breakNow and lateNow
                    st.late_breakout_event := true
                    st.breakout_seen := true
                    st.breakout_idx := bar_index

                bool retestNow = st.breakout_seen and not na(st.breakout_idx) and bar_index > st.breakout_idx and high >= st.break_val and close < st.break_val
                if retestNow
                    st.retest_event := true
        if (not st.is_setup or na(st.curr_high)) and not na(st.curr_high) and high > st.curr_high
            st.curr_high := high
            st.curr_idx := bar_index
    true

//──────────────────────────────────────────────────────────────────────────────
// Main logic
//──────────────────────────────────────────────────────────────────────────────
for st in longStates
    st.updateLong()

for st in shortStates
    st.updateShort()

LongState longWinner = na
ShortState shortWinner = na

for st in longStates
    if st.is_setup and not na(st.break_val)
        bool take = false
        if na(longWinner)
            take := true
        else if priority_mode == 'Lowest Break Level'
            take := st.break_val < longWinner.break_val
        else if priority_mode == 'Highest Break Level'
            take := st.break_val > longWinner.break_val
        else if priority_mode == 'Longest Length'
            take := st.len > longWinner.len
        else if priority_mode == 'Shortest Length'
            take := st.len < longWinner.len
        else
            take := st.curr_idx > longWinner.curr_idx
        if take
            longWinner := st

for st in shortStates
    if st.is_setup and not na(st.break_val)
        bool take = false
        if na(shortWinner)
            take := true
        else if priority_mode == 'Lowest Break Level'
            take := st.break_val < shortWinner.break_val
        else if priority_mode == 'Highest Break Level'
            take := st.break_val > shortWinner.break_val
        else if priority_mode == 'Longest Length'
            take := st.len > shortWinner.len
        else if priority_mode == 'Shortest Length'
            take := st.len < shortWinner.len
        else
            take := st.curr_idx > shortWinner.curr_idx
        if take
            shortWinner := st

bool hasLong = not na(longWinner)
bool hasShort = not na(shortWinner)

int activeDir = 0
int activeLen = na
float activePrev = na
int activePrevIdx = na
float activeCurr = na
int activeCurrIdx = na
float activeEntry = na
int activeEntryIdx = na
bool activeSetup = false
bool activeBreakoutSeen = false
bool activeBreakoutEvent = false
bool activeLateEvent = false
bool activeRetestEvent = false

if direction_mode == 'Long' and hasLong
    activeDir := 1
else if direction_mode == 'Short' and hasShort
    activeDir := -1
else if direction_mode == 'Both'
    if hasLong and hasShort
        int longScoreTmp = f_score(1, longWinner.is_setup, longWinner.breakout_seen, longWinner.break_val)
        int shortScoreTmp = f_score(-1, shortWinner.is_setup, shortWinner.breakout_seen, shortWinner.break_val)
        activeDir := longScoreTmp == shortScoreTmp ? (longWinner.curr_idx >= shortWinner.curr_idx ? 1 : -1) : (longScoreTmp > shortScoreTmp ? 1 : -1)
    else if hasLong
        activeDir := 1
    else if hasShort
        activeDir := -1

if activeDir == 1 and hasLong
    activeLen := longWinner.len
    activePrev := longWinner.prev_low
    activePrevIdx := longWinner.prev_idx
    activeCurr := longWinner.curr_low
    activeCurrIdx := longWinner.curr_idx
    activeEntry := longWinner.break_val
    activeEntryIdx := longWinner.break_idx
    activeSetup := longWinner.is_setup
    activeBreakoutSeen := longWinner.breakout_seen
    activeBreakoutEvent := longWinner.breakout_event
    activeLateEvent := longWinner.late_breakout_event
    activeRetestEvent := longWinner.retest_event
else if activeDir == -1 and hasShort
    activeLen := shortWinner.len
    activePrev := shortWinner.prev_high
    activePrevIdx := shortWinner.prev_idx
    activeCurr := shortWinner.curr_high
    activeCurrIdx := shortWinner.curr_idx
    activeEntry := shortWinner.break_val
    activeEntryIdx := shortWinner.break_idx
    activeSetup := shortWinner.is_setup
    activeBreakoutSeen := shortWinner.breakout_seen
    activeBreakoutEvent := shortWinner.breakout_event
    activeLateEvent := shortWinner.late_breakout_event
    activeRetestEvent := shortWinner.retest_event

bool hasActive = activeDir != 0 and activeSetup and not na(activeEntry) and not na(activeCurr) and not na(activePrev) and not na(activeCurrIdx) and not na(activePrevIdx)
int activeScore = hasActive ? f_score(activeDir, activeSetup, activeBreakoutSeen, activeEntry) : 0
[tp1, tp2, tp3, sl] = f_computeTargets(activeDir, activeEntry, activePrev, activeCurr, atr_val)
float rr1 = hasActive ? f_rr(activeEntry, sl, tp1) : na
float rr2 = hasActive ? f_rr(activeEntry, sl, tp2) : na
float rr3 = hasActive ? f_rr(activeEntry, sl, tp3) : na

//──────────────────────────────────────────────────────────────────────────────
// Drawing
//──────────────────────────────────────────────────────────────────────────────
int dirCode = activeDir == 1 ? 1 : activeDir == -1 ? 2 : 0
int current_signature = hasActive ? activeCurrIdx * 1000 + activeLen * 10 + dirCode : 0

if current_signature != last_drawn_signature
    dr.clear()

    if hasActive
        bool isLong = activeDir == 1
        string prevTxt = isLong ? 'LL' : 'HH'
        string currTxt = isLong ? 'HL' : 'LH'
        bool showPrev = isLong ? show_LL : show_HH
        bool showCurr = isLong ? show_HL : show_LH
        prevStyle = isLong ? label.style_label_up : label.style_label_down
        currStyle = isLong ? label.style_label_up : label.style_label_down
        string dirTxt = isLong ? 'LONG' : 'SHORT'
        string modeTag = target_mode == 'Fibonacci' ? 'Fib' : 'ATR'

        if showPrev
            dr.prevLabel := label.new(activePrevIdx, activePrev, text = prevTxt, style = prevStyle, color = color.new(color.white, 100), textcolor = c_struct_fx, size = lblSize)

        if showCurr
            dr.currLabel := label.new(activeCurrIdx, activeCurr, text = currTxt, style = currStyle, color = color.new(color.white, 100), textcolor = c_struct_fx, size = lblSize)

        if show_Trend
            dr.trendLine := line.new(activePrevIdx, activePrev, activeCurrIdx, activeCurr, color = c_trend_fx, style = style_Trend, width = width_Trend)

        if show_PLine and not na(activeEntryIdx)
            dr.entryLine := line.new(activeEntryIdx, activeEntry, bar_index + 10, activeEntry, color = c_entryline_fx, width = width_Pivot, style = style_Pivot)

        if show_PLabel
            dr.entryLabel := label.new(bar_index + 10, activeEntry, text = dirTxt + ' Entry / Break\n' + str.tostring(activeEntry, format.mintick), style = label.style_label_left, color = color.new(color.white, 100), textcolor = c_entry_fx, size = lblSize)

        if show_Targets
            string r1 = target_mode == 'Fibonacci' ? str.tostring(fib_target1) : str.tostring(atr_mult1) + 'x'
            string r2 = target_mode == 'Fibonacci' ? str.tostring(fib_target2) : str.tostring(atr_mult2) + 'x'
            string r3 = target_mode == 'Fibonacci' ? str.tostring(fib_target3) : str.tostring(atr_mult3) + 'x'

            dr.tp1Line := line.new(activeCurrIdx, tp1, bar_index + 10, tp1, color = c_tp1_fx, width = 1, style = line.style_dashed)
            dr.tp1Label := label.new(bar_index + 10, tp1, text = 'TP1 ' + modeTag + ' (' + r1 + ') · RR ' + str.tostring(rr1, '#.##') + '\n' + str.tostring(tp1, format.mintick), style = label.style_label_left, color = color.new(color.white, 100), textcolor = c_tp1_fx, size = lblSize_targets)

            dr.tp2Line := line.new(activeCurrIdx, tp2, bar_index + 10, tp2, color = c_tp2_fx, width = 1, style = line.style_dashed)
            dr.tp2Label := label.new(bar_index + 10, tp2, text = 'TP2 ' + modeTag + ' (' + r2 + ') · RR ' + str.tostring(rr2, '#.##') + '\n' + str.tostring(tp2, format.mintick), style = label.style_label_left, color = color.new(color.white, 100), textcolor = c_tp2_fx, size = lblSize_targets)

            if show_tp3
                dr.tp3Line := line.new(activeCurrIdx, tp3, bar_index + 10, tp3, color = c_tp3_fx, width = 1, style = line.style_dotted)
                dr.tp3Label := label.new(bar_index + 10, tp3, text = 'TP3 ' + modeTag + ' (' + r3 + ') · RR ' + str.tostring(rr3, '#.##') + '\n' + str.tostring(tp3, format.mintick), style = label.style_label_left, color = color.new(color.white, 100), textcolor = c_tp3_fx, size = lblSize_targets)

            dr.slLine := line.new(activeCurrIdx, sl, bar_index + 10, sl, color = c_sl_fx, width = 1, style = line.style_solid)
            dr.slLabel := label.new(bar_index + 10, sl, text = 'Invalidation / SL\n' + str.tostring(sl, format.mintick), style = label.style_label_left, color = color.new(color.white, 100), textcolor = c_sl_fx, size = lblSize_targets)

    last_drawn_signature := current_signature

// Realtime extension
if hasActive
    if not na(dr.entryLine)
        line.set_x2(dr.entryLine, bar_index + 5)
    if not na(dr.entryLabel)
        label.set_x(dr.entryLabel, bar_index + 5)
    if not na(dr.tp1Line)
        line.set_x2(dr.tp1Line, bar_index + 5)
    if not na(dr.tp1Label)
        label.set_x(dr.tp1Label, bar_index + 5)
    if not na(dr.tp2Line)
        line.set_x2(dr.tp2Line, bar_index + 5)
    if not na(dr.tp2Label)
        label.set_x(dr.tp2Label, bar_index + 5)
    if not na(dr.tp3Line)
        line.set_x2(dr.tp3Line, bar_index + 5)
    if not na(dr.tp3Label)
        label.set_x(dr.tp3Label, bar_index + 5)
    if not na(dr.slLine)
        line.set_x2(dr.slLine, bar_index + 5)
    if not na(dr.slLabel)
        label.set_x(dr.slLabel, bar_index + 5)
else if last_drawn_signature != 0
    dr.clear()
    last_drawn_signature := 0

//──────────────────────────────────────────────────────────────────────────────
// Dashboard
//──────────────────────────────────────────────────────────────────────────────
f_setDashCell(int col, int row, string txt, color txtColor, color bgColor) =>
    table.cell(dash, col, row, txt, text_color = txtColor, bgcolor = bgColor, text_size = size.small)

if show_dashboard
    color qCol = f_qualityColor(activeScore)
    string sideTxt = activeDir == 1 ? 'LONG' : activeDir == -1 ? 'SHORT' : 'NONE'
    string stateTxt = hasActive ? (activeBreakoutSeen ? 'Breakout seen' : 'Setup waiting') : 'No setup'
    string rrTxt = hasActive ? 'TP1 ' + str.tostring(rr1, '#.##') + ' | TP2 ' + str.tostring(rr2, '#.##') + (show_tp3 ? ' | TP3 ' + str.tostring(rr3, '#.##') : '') : 'n/a'
    f_setDashCell(0, 0, 'X966 W3', themeTextColor, themePanelBg)
    f_setDashCell(1, 0, f_qualityName(activeScore), qCol, themePanelBg)
    f_setDashCell(0, 1, 'Side', themeMutedColor, themeBgColor)
    f_setDashCell(1, 1, sideTxt, themeTextColor, themeBgColor)
    f_setDashCell(0, 2, 'Score', themeMutedColor, themeBgColor)
    f_setDashCell(1, 2, str.tostring(activeScore) + '/100', qCol, themeBgColor)
    f_setDashCell(0, 3, 'State', themeMutedColor, themeBgColor)
    f_setDashCell(1, 3, stateTxt, themeTextColor, themeBgColor)
    f_setDashCell(0, 4, 'Entry', themeMutedColor, themeBgColor)
    f_setDashCell(1, 4, hasActive ? str.tostring(activeEntry, format.mintick) : 'n/a', themeTextColor, themeBgColor)
    f_setDashCell(0, 5, 'SL', themeMutedColor, themeBgColor)
    f_setDashCell(1, 5, hasActive ? str.tostring(sl, format.mintick) : 'n/a', c_sl_fx, themeBgColor)
    f_setDashCell(0, 6, 'RR', themeMutedColor, themeBgColor)
    f_setDashCell(1, 6, rrTxt, themeTextColor, themeBgColor)
    f_setDashCell(0, 7, 'Mode', themeMutedColor, themeBgColor)
    f_setDashCell(1, 7, entry_mode + ' · ' + invalidation_mode, themeTextColor, themeBgColor)
    f_setDashCell(0, 8, 'Target', themeMutedColor, themeBgColor)
    f_setDashCell(1, 8, target_mode, themeTextColor, themeBgColor)
else
    for r = 0 to 8
        f_setDashCell(0, r, '', color.new(color.white, 100), color.new(color.white, 100))
        f_setDashCell(1, r, '', color.new(color.white, 100), color.new(color.white, 100))

//──────────────────────────────────────────────────────────────────────────────
// Alerts — confirmed only
//──────────────────────────────────────────────────────────────────────────────
bool wantsBreakoutAlert = entry_mode == 'Breakout' or entry_mode == 'Breakout + Retest'
bool wantsRetestAlert = entry_mode == 'Retest' or entry_mode == 'Breakout + Retest'

bool breakoutSignal = hasActive and barstate.isconfirmed and wantsBreakoutAlert and (activeBreakoutEvent or activeLateEvent)
bool retestSignal = hasActive and barstate.isconfirmed and wantsRetestAlert and activeRetestEvent
bool rawSignal = breakoutSignal or retestSignal
bool scoreOk = not use_score_gate or activeScore >= min_alert_score
bool final_alert_trigger = rawSignal and scoreOk

string signalKind = retestSignal ? 'RETEST' : activeLateEvent ? 'LATE_BREAKOUT' : 'BREAKOUT'
string alertKey = str.tostring(activeDir) + ':' + str.tostring(current_signature) + ':' + signalKind
bool unique_alert_trigger = final_alert_trigger and alertKey != last_alerted_key

if unique_alert_trigger
    last_alerted_key := alertKey
    if enable_alerts
        string sideEn = activeDir == 1 ? 'LONG' : 'SHORT'
        string sideAr = activeDir == 1 ? 'شراء' : 'بيع'
        string quality = f_qualityName(activeScore)
        string mode_a = target_mode == 'Fibonacci' ? 'Fib' : 'ATR'
        string eventAr = signalKind == 'RETEST' ? 'إعادة اختبار مؤكدة' : signalKind == 'LATE_BREAKOUT' ? 'اختراق ملتقط بعد تأكيد المحور' : 'اختراق مؤكد'
        string eventEn = signalKind == 'RETEST' ? 'Retest Confirmed' : signalKind == 'LATE_BREAKOUT' ? 'Late Breakout Captured' : 'Breakout Confirmed'
        string msg_ar = '🔔 X966 | ' + eventAr + ' · ' + sideAr + ' (' + mode_a + ')\n' + syminfo.ticker + ' · ' + timeframe.period + '\nالجودة: ' + quality + ' · Score ' + str.tostring(activeScore) + '/100\nالدخول: ' + str.tostring(activeEntry, format.mintick) + '\nTP1: ' + str.tostring(tp1, format.mintick) + ' · RR ' + str.tostring(rr1, '#.##') + '\nTP2: ' + str.tostring(tp2, format.mintick) + ' · RR ' + str.tostring(rr2, '#.##') + (show_tp3 ? '\nTP3: ' + str.tostring(tp3, format.mintick) + ' · RR ' + str.tostring(rr3, '#.##') : '') + '\nSL: ' + str.tostring(sl, format.mintick)
        string msg_en = '🔔 X966 | ' + eventEn + ' · ' + sideEn + ' (' + mode_a + ')\n' + syminfo.ticker + ' · ' + timeframe.period + '\nQuality: ' + quality + ' · Score ' + str.tostring(activeScore) + '/100\nEntry: ' + str.tostring(activeEntry, format.mintick) + '\nTP1: ' + str.tostring(tp1, format.mintick) + ' · RR ' + str.tostring(rr1, '#.##') + '\nTP2: ' + str.tostring(tp2, format.mintick) + ' · RR ' + str.tostring(rr2, '#.##') + (show_tp3 ? '\nTP3: ' + str.tostring(tp3, format.mintick) + ' · RR ' + str.tostring(rr3, '#.##') : '') + '\nSL: ' + str.tostring(sl, format.mintick)
        alert(msg_ar + '\n---\n' + msg_en, alert.freq_once_per_bar_close)

alertcondition(unique_alert_trigger, title = 'X966 W3 Signal Confirmed', message = 'X966 W3 confirmed signal — dynamic AR/EN alert has details.')
````
