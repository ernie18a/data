# True Seasonal Probability Map

- url: https://www.tradingview.com/script/dQVdiZgx/
- type: indicator
- pine_id: PUB;ebaa1205cee94223801317cdb3d05483
- version: 2.0

## Description

True Seasonal Probability Map is a weekly seasonal analysis tool for 1W charts.

The script combines two related seasonal views:

1. True Seasonal Curve
The curve groups historical weekly price changes by calendar week and builds a normalized seasonal path. Users can choose the lookback period, smoothing, detrending, and normalization mode. The curve helps visualize how the selected market has tended to move through the calendar year.

2. Bernstein Weekly Probability Map
The weekly boxes show the historical percentage of positive closes for each calendar week. The Bernstein lookback can be set independently from the seasonal curve, using maximum available data, 30 years, 15 years, or a custom value. This allows users to compare a shorter seasonal regime with a broader long-term probability sample.

The weekly boxes are aligned with the chart timeline. Boxes for the current year align with the corresponding weekly candles, while future boxes extend to the right of the current bar to show upcoming calendar weeks. Green indicates a positive historical bias, red indicates a negative historical bias, and neutral colors indicate a more balanced probability zone.

A configurable average window highlights the current week plus the next selected number of weeks. By default, the box shows a 6-week average including the current week. The average value is displayed inside the highlighted period.

Main settings:
- True Seasonal Years: lookback used for the seasonal curve.
- Bernstein Lookback: lookback used for weekly probability calculations.
- Line Color Source: choose whether the seasonal curve colors follow Bernstein probabilities or the True Seasonal probability calculation.
- Bernstein Future Weeks: number of future weekly probability boxes to display.
- Current Avg Weeks: number of weeks included in the highlighted average window.
- Reliability %: threshold used to classify stronger bullish or bearish probability zones.

This indicator does not generate buy or sell signals. It is intended as a seasonal context tool. Historical seasonal tendencies and weekly positive-close probabilities do not predict future results. Use this tool together with market structure, trend, volatility, liquidity, macro context, and risk management.

## Source Code

````pine
//@version=6
indicator("True Seasonal Probability Map", shorttitle="TS Prob Map", overlay=false,
     max_bars_back=5000, max_lines_count=500, max_labels_count=500,
     max_boxes_count=500, max_polylines_count=20)

string G0 = "Theme"
bool useTheme = input.bool(true, "Enable theme", group=G0)
string themeChoice = input.string("Classic Teal/Red", "Theme",
     options=["Classic Teal/Red", "Dark Pro", "Light Pro", "Scalper Neon", "Swing Soft", "Blue/Orange", "Muted Desk"],
     group=G0,
     tooltip="Classic Teal/Red  - balanced default look\nDark Pro          - high contrast for dark charts\nLight Pro         - darker colors for light charts\nScalper Neon      - bright, fast to read\nSwing Soft        - softer swing-trading palette\nBlue/Orange       - clear alternate bull/bear split\nMuted Desk        - neutral, less saturated")

color thOb = themeChoice == "Classic Teal/Red" ? #089981 : themeChoice == "Dark Pro" ? #00C082 : themeChoice == "Light Pro" ? #0F766E : themeChoice == "Scalper Neon" ? #00E5FF : themeChoice == "Swing Soft" ? #14B8A6 : themeChoice == "Blue/Orange" ? #2563EB : themeChoice == "Muted Desk" ? #2F9E85 : #089981
color thOs = themeChoice == "Classic Teal/Red" ? #F23645 : themeChoice == "Dark Pro" ? #FF4D5A : themeChoice == "Light Pro" ? #B91C1C : themeChoice == "Scalper Neon" ? #FF3B5C : themeChoice == "Swing Soft" ? #D9465F : themeChoice == "Blue/Orange" ? #EA580C : themeChoice == "Muted Desk" ? #C65B6C : #F23645
color thSig = themeChoice == "Classic Teal/Red" ? #FF5D00 : themeChoice == "Dark Pro" ? #F59E0B : themeChoice == "Light Pro" ? #1D4ED8 : themeChoice == "Scalper Neon" ? #FFD400 : themeChoice == "Swing Soft" ? #FDBA74 : themeChoice == "Blue/Orange" ? #FACC15 : themeChoice == "Muted Desk" ? #94A3B8 : #FF5D00
color thVpBuy = themeChoice == "Classic Teal/Red" ? #26A69A : themeChoice == "Dark Pro" ? #14B8A6 : themeChoice == "Light Pro" ? #0EA5A3 : themeChoice == "Scalper Neon" ? #00BCD4 : themeChoice == "Swing Soft" ? #5EEAD4 : themeChoice == "Blue/Orange" ? #60A5FA : themeChoice == "Muted Desk" ? #6BB5A4 : #26A69A
color thNeutral = themeChoice == "Light Pro" ? #64748B : themeChoice == "Muted Desk" ? #8B93A4 : #787B86
color thText = themeChoice == "Dark Pro" ? #CBD5E1 : themeChoice == "Light Pro" ? #334155 : themeChoice == "Scalper Neon" ? #D1D5DB : themeChoice == "Swing Soft" ? #CBD5E1 : themeChoice == "Blue/Orange" ? #CBD5E1 : themeChoice == "Muted Desk" ? #AEB7C6 : #B2B5BE
color thPanel = themeChoice == "Dark Pro" ? #0F172A : themeChoice == "Light Pro" ? #F8FAFC : themeChoice == "Scalper Neon" ? #111827 : themeChoice == "Swing Soft" ? #1F2937 : themeChoice == "Blue/Orange" ? #172033 : themeChoice == "Muted Desk" ? #20242C : #1A1A1A

string G_MAIN = "True Seasonal"
string G_BST = "Bernstein Weekly Boxes"
string G_MON = "Monthly Seasonality"
string G_TDM = "Trading Day of Month"
string G_COL = "Colors"

int i_years = input.int(15, "True Seasonal Years", group=G_MAIN, minval=1, maxval=30)
int i_future = input.int(26, "Seasonal Forecast Weeks", group=G_MAIN, minval=0, maxval=260)
int i_smooth = input.int(1, "Smoothing MA", group=G_MAIN, minval=1, maxval=20)
bool i_detrend = input.bool(true, "De-trending", group=G_MAIN)
string i_norm = input.string("Bernstein", "Normalization", options=["Bernstein", "Z-Score/StdDev", "Percent", "Direction", "Raw"], group=G_MAIN,
     tooltip="Bernstein/Z-Score divides weekly percent change by its 52-week standard deviation. Percent uses raw percent change. Direction uses only up/down.")
bool i_show_standard = input.bool(true, "Show standard line", group=G_MAIN)
string i_line_color_source = input.string("Bernstein %Up", "Line color source",
     options=["Bernstein %Up", "True Seasonal %Up"], group=G_MAIN)
color i_standard_hist_col_input = input.color(#2196F3, "Standard historical", group=G_MAIN)
color i_standard_fore_col_input = input.color(#FF9800, "Standard Forecast", group=G_MAIN)
int i_standard_width = input.int(2, "Standard width", group=G_MAIN, minval=1, maxval=5)

string i_bernstein_lookback = input.string("Max data", "Bernstein Lookback",
     options=["Max data", "30 Years", "15 Years", "Custom"], group=G_BST)
int i_bernstein_custom_years = input.int(30, "Bernstein Custom Years", group=G_BST, minval=1, maxval=90)
float i_reliab = input.float(59.0, "Reliability %", group=G_BST, minval=50.0, maxval=100.0, step=0.5)
int i_forecast_window = input.int(5, "Forecast Window Weeks", group=G_BST, minval=1, maxval=12)
int i_current_label_avg_weeks = input.int(6, "Current Avg Weeks incl. current", group=G_BST, minval=1, maxval=52)
int i_bernstein_future = input.int(26, "Bernstein Future Weeks", group=G_BST, minval=0, maxval=260)
bool i_complete_current_year = input.bool(true, "Complete current calendar year", group=G_BST,
     tooltip="Draws missing Bernstein weekly boxes through the end of the current calendar year, even when Bernstein Future Weeks is lower.")
bool i_show_week_boxes = input.bool(true, "Show current-year weekly boxes", group=G_BST)
bool i_show_box_text = input.bool(true, "Show bottom labels", group=G_BST)
bool i_show_month_guides = input.bool(true, "Show month separators", group=G_BST)
float i_bottom_label_y = input.float(-112.0, "Bottom label Y", group=G_BST, minval=-200.0, maxval=0.0, step=1.0)
float i_box_scale = input.float(2.0, "Box scale", group=G_BST, minval=0.5, maxval=4.0, step=0.25,
     tooltip="2.0 matches the Bernstein logic: (probability - 50) * 2.")
int i_box_alpha = input.int(28, "Box transparency", group=G_BST, minval=0, maxval=95)
bool i_show_stats_table = input.bool(true, "Show seasonality table", group=G_BST)

string i_month_basis = input.string("Weekly bars", "Monthly Basis", options=["Weekly bars", "Calendar months"], group=G_MON)
string i_month_lookback = input.string("Same as Bernstein", "Monthly Lookback",
     options=["Same as Bernstein", "Max data", "30 Years", "15 Years", "Custom"], group=G_MON)
int i_month_custom_years = input.int(30, "Monthly Custom Years", group=G_MON, minval=1, maxval=90)

bool i_enable_tdm = input.bool(true, "Enable TDM stats", group=G_TDM,
     tooltip="TDM = trading day of month. Stats use daily open-to-close changes from lower-timeframe daily bars. TDW is intentionally not included.")
string i_tdm_scope = input.string("Current month", "TDM Scope", options=["Current month", "All months"], group=G_TDM,
     tooltip="Current month evaluates each trading day from prior observations of the current calendar month. All months pools the same trading day across every month.")
int i_tdm_years = input.int(15, "TDM Years", group=G_TDM, minval=1, maxval=40)
int i_tdm_max_day = input.int(23, "Max TDM day", group=G_TDM, minval=1, maxval=31)

color i_bull_col_input = input.color(#089981, "Bull", group=G_COL)
color i_bear_col_input = input.color(#F23645, "Bear", group=G_COL)
color i_neutral_col_input = input.color(#787B86, "Neutral", group=G_COL)
color i_now_col_input = input.color(#FF9800, "Current", group=G_COL)
int i_line_width = input.int(3, "Seasonal line width", group=G_COL, minval=1, maxval=5)

color i_standard_hist_col = useTheme ? thVpBuy : i_standard_hist_col_input
color i_standard_fore_col = useTheme ? thSig : i_standard_fore_col_input
color i_bull_col = useTheme ? thOb : i_bull_col_input
color i_bear_col = useTheme ? thOs : i_bear_col_input
color i_neutral_col = useTheme ? thNeutral : i_neutral_col_input
color i_now_col = useTheme ? thSig : i_now_col_input
color i_text_col = useTheme ? thText : color.white
color i_panel_col = useTheme ? thPanel : color.black
color i_table_bg = color.new(i_panel_col, 8)
color i_table_head_bg = color.new(i_panel_col, 0)
color i_table_empty_bg = color.new(i_panel_col, 100)

if not (timeframe.isweekly and timeframe.multiplier == 1)
    runtime.error("trueSeasonal requires a 1W chart so each Bernstein box aligns with its weekly candle.")

int nof_bins = 52
int WEEK_MS = 604800000
int TDM_DAYS = 32
int TDM_MONTHS = 12
int slot = math.min(nof_bins, math.max(1, weekofyear(time_close)))
int bin = slot - 1

var int[] slot_history = array.new_int()
array.push(slot_history, slot)

var float[] bins = array.new_float()
var float[] counts = array.new_float()
var float[] up_counts = array.new_float()
var float[] sample_counts = array.new_float()

if array.size(bins) == 0
    for i = 0 to nof_bins - 1
        array.push(bins, 0.0)
        array.push(counts, 0.0)
        array.push(up_counts, 0.0)
        array.push(sample_counts, 0.0)

var int[] tdm_counts = array.new_int()
var int[] tdm_up_counts = array.new_int()
var float[] tdm_pct_sums = array.new_float()
if array.size(tdm_counts) == 0
    for i = 0 to TDM_MONTHS * TDM_DAYS - 1
        array.push(tdm_counts, 0)
        array.push(tdm_up_counts, 0)
        array.push(tdm_pct_sums, 0.0)

var int tdm_track_year = na
var int tdm_track_month = na
var int tdm_day_no = 0
var int current_tdm_no = na

[tdm_times, tdm_opens, tdm_closes] =
     request.security_lower_tf(syminfo.tickerid, "D", [time_close, open, close], ignore_invalid_symbol=true)

int tdm_start_year = year(timenow) - i_tdm_years
int tdm_end_year = year(timenow) - 1
if i_enable_tdm and array.size(tdm_times) > 0
    int tdm_items = math.min(array.size(tdm_times), math.min(array.size(tdm_opens), array.size(tdm_closes)))
    for di = 0 to tdm_items - 1
        int d_ts = array.get(tdm_times, di)
        float d_open = array.get(tdm_opens, di)
        float d_close = array.get(tdm_closes, di)
        if not na(d_ts) and not na(d_open) and not na(d_close) and d_open != 0
            int d_year = year(d_ts)
            int d_month = month(d_ts)
            if na(tdm_track_month) or d_month != tdm_track_month or d_year != tdm_track_year
                tdm_track_year := d_year
                tdm_track_month := d_month
                tdm_day_no := 1
            else
                tdm_day_no += 1
            current_tdm_no := tdm_day_no

            if d_year >= tdm_start_year and d_year <= tdm_end_year and tdm_day_no >= 1 and tdm_day_no <= math.min(i_tdm_max_day, 31)
                float d_pct = (d_close - d_open) / d_open * 100.0
                int tdm_idx = (d_month - 1) * TDM_DAYS + tdm_day_no
                array.set(tdm_counts, tdm_idx, array.get(tdm_counts, tdm_idx) + 1)
                array.set(tdm_pct_sums, tdm_idx, array.get(tdm_pct_sums, tdm_idx) + d_pct)
                if d_close > d_open
                    array.set(tdm_up_counts, tdm_idx, array.get(tdm_up_counts, tdm_idx) + 1)

int seasonal_cutoff = timenow - int(math.round(i_years * 31557600000.0))
bool useMaxBernsteinData = i_bernstein_lookback == "Max data"
int effectiveBernsteinYears = i_bernstein_lookback == "15 Years" ? 15 :
     i_bernstein_lookback == "30 Years" ? 30 :
     i_bernstein_custom_years

if bar_index > 0 and bin >= 0 and bin < array.size(bins)
    float raw_delta = close - close[1]
    float pct_delta = close[1] != 0 ? raw_delta / close[1] * 100.0 : 0.0
    float year_std_dev = ta.stdev(pct_delta, nof_bins)
    bool use_z_score = i_norm == "Bernstein" or i_norm == "Z-Score/StdDev"
    float delta = use_z_score ? (year_std_dev > 0 ? pct_delta / year_std_dev : pct_delta) :
         i_norm == "Percent" ? pct_delta :
         i_norm == "Direction" ? (raw_delta > 0 ? 1.0 : raw_delta < 0 ? -1.0 : 0.0) :
         raw_delta
    if time > seasonal_cutoff
        array.set(bins, bin, array.get(bins, bin) + delta)
        array.set(counts, bin, array.get(counts, bin) + 1.0)
    array.set(sample_counts, bin, array.get(sample_counts, bin) + 1.0)
    if raw_delta > 0
        array.set(up_counts, bin, array.get(up_counts, bin) + 1.0)

int maxBernsteinBars = 4999
int maxBackW = useMaxBernsteinData ? math.min(bar_index, maxBernsteinBars) : math.min(bar_index, effectiveBernsteinYears * 54 + 8)
int cutoffW = useMaxBernsteinData ? 0 : timenow - int(math.round(effectiveBernsteinYears * 31557600000.0))

var int visible_left_bar = na
var int visible_right_bar = na
if time == chart.left_visible_bar_time
    visible_left_bar := bar_index
if time >= chart.left_visible_bar_time and time <= chart.right_visible_bar_time
    visible_right_bar := bar_index

f_build_profile(float[] src_bins, float[] src_counts) =>
    int used = array.size(src_bins) - 1
    float[] lv = array.new_float(array.size(src_bins), 0.0)
    float accum = 0.0
    int last_used = 0

    for i = 0 to used
        float c = array.get(src_counts, i)
        if c > 0
            accum += array.get(src_bins, i) / c
            array.set(lv, i, accum)
            last_used := i
        else if i > 0
            array.set(lv, i, array.get(lv, i - 1))

    if i_detrend and last_used > 0
        float first_value = array.get(lv, 0)
        float last_value = array.get(lv, last_used)
        float step = (last_value - first_value) / last_used
        for i = 1 to last_used
            array.set(lv, i, array.get(lv, i) - step * i)

    if i_smooth > 1
        float[] smoothed = array.new_float(array.size(src_bins), 0.0)
        array.set(smoothed, 0, array.get(lv, 0))
        for i = 1 to used
            float sum_values = 0.0
            int sample_size = 0
            for j = 0 to i_smooth - 1
                int idx = i - j
                if idx >= 0
                    sum_values += array.get(lv, idx)
                    sample_size += 1
            if sample_size > 0
                array.set(smoothed, i, sum_values / sample_size)
        lv := smoothed

    float min_value = array.min(lv)
    for i = 0 to used
        array.set(lv, i, array.get(lv, i) - min_value)

    float max_value = array.max(lv)
    if max_value != 0.0
        for i = 0 to used
            array.set(lv, i, (array.get(lv, i) / max_value - 0.5) * 200.0)

    lv

f_build_pct_up(float[] src_up_counts, float[] src_sample_counts) =>
    int used = array.size(src_up_counts) - 1
    float[] pct_up = array.new_float(array.size(src_up_counts), 50.0)
    for i = 0 to used
        float samples = array.get(src_sample_counts, i)
        float pct = samples > 0 ? array.get(src_up_counts, i) * 100.0 / samples : 50.0
        array.set(pct_up, i, pct)
    pct_up

f_tdm_idx(int month_no, int tdm_day) =>
    int safe_month = math.max(1, math.min(month_no, TDM_MONTHS))
    int safe_day = math.max(1, math.min(tdm_day, TDM_DAYS - 1))
    (safe_month - 1) * TDM_DAYS + safe_day

f_tdm_totals(int month_no, int tdm_day) =>
    int safe_day = math.max(1, math.min(tdm_day, TDM_DAYS - 1))
    int samples = 0
    int ups = 0
    float pct_sum = 0.0
    if i_tdm_scope == "All months"
        for mo = 1 to TDM_MONTHS
            int idx = f_tdm_idx(mo, safe_day)
            samples += array.get(tdm_counts, idx)
            ups += array.get(tdm_up_counts, idx)
            pct_sum += array.get(tdm_pct_sums, idx)
    else
        int idx = f_tdm_idx(month_no, safe_day)
        samples := array.get(tdm_counts, idx)
        ups := array.get(tdm_up_counts, idx)
        pct_sum := array.get(tdm_pct_sums, idx)
    [samples, ups, pct_sum]

f_tdm_pct_up(int month_no, int tdm_day) =>
    [samples, ups, _] = f_tdm_totals(month_no, tdm_day)
    samples > 0 ? ups * 100.0 / samples : 50.0

f_tdm_avg_pct(int month_no, int tdm_day) =>
    [samples, _, pct_sum] = f_tdm_totals(month_no, tdm_day)
    samples > 0 ? pct_sum / samples : 0.0

f_tdm_samples(int month_no, int tdm_day) =>
    [samples, _, _] = f_tdm_totals(month_no, tdm_day)
    samples

f_tdm_required_samples() =>
    i_tdm_scope == "All months" ? i_tdm_years * TDM_MONTHS : i_tdm_years

f_pct_bg(float pct) =>
    pct >= 70.0 ? color.new(i_bull_col, 18) :
     (100.0 - pct) >= 70.0 ? color.new(i_bear_col, 18) :
     pct >= i_reliab ? color.new(i_bull_col, 38) :
     (100.0 - pct) >= i_reliab ? color.new(i_bear_col, 38) :
     color.new(i_panel_col, 15)

f_segment_color(float pct, bool is_forecast) =>
    int strong_alpha = is_forecast ? 25 : 0
    int weak_alpha = is_forecast ? 60 : 22
    if pct >= i_reliab
        color.new(i_bull_col, strong_alpha)
    else if (100.0 - pct) >= i_reliab
        color.new(i_bear_col, strong_alpha)
    else if pct >= 52.0
        color.new(i_bull_col, weak_alpha)
    else if pct <= 48.0
        color.new(i_bear_col, weak_alpha)
    else
        color.new(i_neutral_col, int(math.min(95.0, weak_alpha + 10.0)))

f_box_color(float pct) =>
    int weak_alpha = int(math.min(95.0, i_box_alpha + 28.0))
    if pct >= i_reliab
        color.new(i_bull_col, i_box_alpha)
    else if (100.0 - pct) >= i_reliab
        color.new(i_bear_col, i_box_alpha)
    else if pct >= 52.0
        color.new(i_bull_col, weak_alpha)
    else if pct <= 48.0
        color.new(i_bear_col, weak_alpha)
    else
        color.new(i_neutral_col, weak_alpha)

f_prob_text_color(float pct) =>
    if pct >= 52.0
        i_bull_col
    else if pct <= 48.0
        i_bear_col
    else
        i_text_col

f_clear_lines(line[] ids) =>
    while array.size(ids) > 0
        line.delete(array.pop(ids))

f_clear_boxes(box[] ids) =>
    while array.size(ids) > 0
        box.delete(array.pop(ids))

f_clear_labels(label[] ids) =>
    while array.size(ids) > 0
        label.delete(array.pop(ids))

f_slot_text(int current_bin) =>
    "W" + str.tostring(current_bin + 1)

f_month_name(int mo) =>
    mo == 1 ? "Jan" :
     mo == 2 ? "Feb" :
     mo == 3 ? "Mar" :
     mo == 4 ? "Apr" :
     mo == 5 ? "May" :
     mo == 6 ? "Jun" :
     mo == 7 ? "Jul" :
     mo == 8 ? "Aug" :
     mo == 9 ? "Sep" :
     mo == 10 ? "Oct" :
     mo == 11 ? "Nov" :
     "Dec"

f_fmt_pct(float value) =>
    na(value) ? "n/a" : str.tostring(math.round(value, 1)) + "%"

f_fmt_signed_pct(float value) =>
    na(value) ? "n/a" : (value > 0 ? "+" : "") + str.tostring(math.round(value, 2)) + "%"

var line[] hist_lines = array.new_line()
var line[] forecast_lines = array.new_line()
var box[] year_boxes = array.new_box()
var label[] year_labels = array.new_label()
var line[] year_guides = array.new_line()
var polyline standard_hist_line = na
var polyline standard_forecast_line = na
var table stats_table = table.new(position.top_right, 4, 29,
     bgcolor=color.new(i_panel_col, 8), frame_color=color.new(i_neutral_col, 70),
     frame_width=1, border_color=color.new(i_neutral_col, 82), border_width=1)

hline(0.0, "Neutral / 50%", color=color.new(i_neutral_col, 80))
hline((i_reliab - 50.0) * i_box_scale, "Bernstein Bull", color=color.new(i_bull_col, 82), linestyle=hline.style_dotted)
hline(-(i_reliab - 50.0) * i_box_scale, "Bernstein Bear", color=color.new(i_bear_col, 82), linestyle=hline.style_dotted)
hline((60.0 - 50.0) * i_box_scale, "60% Bull", color=color.new(i_bull_col, 90), linestyle=hline.style_dotted)
hline(-(60.0 - 50.0) * i_box_scale, "60% Bear", color=color.new(i_bear_col, 90), linestyle=hline.style_dotted)
hline((70.0 - 50.0) * i_box_scale, "70% Strong Bull", color=color.new(i_bull_col, 78), linestyle=hline.style_dashed)
hline(-(70.0 - 50.0) * i_box_scale, "70% Strong Bear", color=color.new(i_bear_col, 78), linestyle=hline.style_dashed)

if barstate.islast and array.size(bins) > 0
    f_clear_lines(hist_lines)
    f_clear_lines(forecast_lines)
    f_clear_boxes(year_boxes)
    f_clear_labels(year_labels)
    f_clear_lines(year_guides)
    if not na(standard_hist_line)
        polyline.delete(standard_hist_line)
    if not na(standard_forecast_line)
        polyline.delete(standard_forecast_line)

    int used = array.size(bins) - 1
    int current_bin = math.max(0, math.min(used, bin))
    array<int> bernCnt = array.new_int(52, 0)
    array<int> bernUpCnt = array.new_int(52, 0)
    if maxBackW > 0
        for i = 0 to maxBackW - 1
            int ts = time_close[i]
            int prevTs = time_close[i + 1]
            float cl = close[i]
            float prevCl = close[i + 1]
            if ts >= cutoffW and year(ts) == year(prevTs) and not na(cl) and not na(prevCl) and prevCl > 0
                int wk = math.min(51, math.max(0, weekofyear(ts) - 1))
                array.set(bernCnt, wk, array.get(bernCnt, wk) + 1)
                if cl > prevCl
                    array.set(bernUpCnt, wk, array.get(bernUpCnt, wk) + 1)

    array<float> weekPctUp = array.new_float(52, 50.0)
    for wk = 0 to 51
        int cnt = array.get(bernCnt, wk)
        float pct = cnt > 0 ? array.get(bernUpCnt, wk) * 100.0 / cnt : 50.0
        array.set(weekPctUp, wk, pct)

    bool useSameMonthData = i_month_lookback == "Same as Bernstein"
    bool useMaxMonthData = i_month_lookback == "Max data"
    int effectiveMonthYears = i_month_lookback == "15 Years" ? 15 :
         i_month_lookback == "30 Years" ? 30 :
         i_month_custom_years
    int maxBackM = useSameMonthData ? maxBackW :
         useMaxMonthData ? math.min(bar_index, maxBernsteinBars) :
         math.min(bar_index, effectiveMonthYears * 54 + 8)
    int cutoffM = useSameMonthData ? cutoffW :
         useMaxMonthData ? 0 :
         timenow - int(math.round(effectiveMonthYears * 31557600000.0))

    array<int> monthCnt = array.new_int(12, 0)
    array<int> monthUpCnt = array.new_int(12, 0)
    if maxBackM > 0
        if i_month_basis == "Calendar months"
            int seenMonth = na
            int seenYear = na
            float newerMonthClose = na
            int newerMonthIdx = na
            int newerMonthTs = na
            for i = 0 to maxBackM - 1
                int ts = time_close[i]
                float cl = close[i]
                if not na(ts) and not na(cl)
                    int mo = month(ts)
                    int yr = year(ts)
                    if na(seenMonth) or mo != seenMonth or yr != seenYear
                        if not na(newerMonthClose) and not na(newerMonthIdx) and not na(newerMonthTs) and cl > 0 and newerMonthTs >= cutoffM
                            array.set(monthCnt, newerMonthIdx, array.get(monthCnt, newerMonthIdx) + 1)
                            if newerMonthClose > cl
                                array.set(monthUpCnt, newerMonthIdx, array.get(monthUpCnt, newerMonthIdx) + 1)
                        seenMonth := mo
                        seenYear := yr
                        newerMonthClose := cl
                        newerMonthIdx := math.min(11, math.max(0, mo - 1))
                        newerMonthTs := ts
        else
            for i = 0 to maxBackM - 1
                int ts = time_close[i]
                int prevTs = time_close[i + 1]
                float cl = close[i]
                float prevCl = close[i + 1]
                if ts >= cutoffM and year(ts) == year(prevTs) and not na(cl) and not na(prevCl) and prevCl > 0
                    int mo = math.min(11, math.max(0, month(ts) - 1))
                    array.set(monthCnt, mo, array.get(monthCnt, mo) + 1)
                    if cl > prevCl
                        array.set(monthUpCnt, mo, array.get(monthUpCnt, mo) + 1)

    array<float> monthPctUp = array.new_float(12, 50.0)
    for mo = 0 to 11
        int cnt = array.get(monthCnt, mo)
        float pct = cnt > 0 ? array.get(monthUpCnt, mo) * 100.0 / cnt : 50.0
        array.set(monthPctUp, mo, pct)

    float[] seasonal_curve = f_build_profile(bins, counts)
    float[] pct_up_curve = f_build_pct_up(up_counts, sample_counts)
    chart.point[] hist_points = array.new<chart.point>()
    chart.point[] forecast_points = array.new<chart.point>()
    int last_hist_index = math.min(nz(visible_right_bar, bar_index), array.size(slot_history) - 1)
    int first_hist_index = na(visible_left_bar) ? math.max(0, last_hist_index - 300) : math.min(visible_left_bar, last_hist_index)

    for bi = first_hist_index to last_hist_index
        int sl = array.get(slot_history, bi)
        int curve_bin = math.max(0, math.min(used, sl - 1))
        float y = array.get(seasonal_curve, curve_bin)
        array.push(hist_points, chart.point.from_index(bi, y))

    int max_total_segments = 400
    int future_bars = math.min(i_future, max_total_segments)
    int visible_segments = math.max(0, last_hist_index - first_hist_index)
    int hist_budget = math.max(0, max_total_segments - future_bars)
    int hist_step = hist_budget > 0 and visible_segments > hist_budget ? int(math.ceil(visible_segments * 1.0 / hist_budget)) : 1

    int seg_left = first_hist_index
    while seg_left < last_hist_index and hist_budget > 0
        int seg_right = math.min(last_hist_index, seg_left + hist_step)
        int left_slot = array.get(slot_history, seg_left)
        int right_slot = array.get(slot_history, seg_right)
        int left_bin = math.max(0, math.min(used, left_slot - 1))
        int right_bin = math.max(0, math.min(used, right_slot - 1))
        float y1 = array.get(seasonal_curve, left_bin)
        float y2 = array.get(seasonal_curve, right_bin)
        float pct = i_line_color_source == "Bernstein %Up" ? array.get(weekPctUp, right_bin) : array.get(pct_up_curve, right_bin)
        array.push(hist_lines, line.new(seg_left, y1, seg_right, y2,
             color=f_segment_color(pct, false), width=i_line_width))
        seg_left := seg_right

    float current_value = array.get(seasonal_curve, current_bin)
    array.push(forecast_points, chart.point.from_index(bar_index, current_value))

    if future_bars > 0
        int next_bin = current_bin
        float prev_y = current_value
        for step = 1 to future_bars
            next_bin += 1
            if next_bin > used
                next_bin := 0
            float next_y = array.get(seasonal_curve, next_bin)
            float next_pct = i_line_color_source == "Bernstein %Up" ? array.get(weekPctUp, next_bin) : array.get(pct_up_curve, next_bin)
            array.push(forecast_points, chart.point.from_index(bar_index + step, next_y))
            array.push(forecast_lines, line.new(bar_index + step - 1, prev_y, bar_index + step, next_y,
                 color=f_segment_color(next_pct, true), width=i_line_width))
            prev_y := next_y

    if i_show_standard and array.size(hist_points) > 1
        standard_hist_line := polyline.new(hist_points, curved=true, line_color=i_standard_hist_col, line_width=i_standard_width)
    else
        standard_hist_line := na

    if i_show_standard and array.size(forecast_points) > 1
        standard_forecast_line := polyline.new(forecast_points, curved=true, line_color=i_standard_fore_col, line_width=i_standard_width)
    else
        standard_forecast_line := na

    float curBernPct = array.get(weekPctUp, current_bin)
    float windowPctSum = 0.0
    for k = 1 to i_forecast_window
        windowPctSum += array.get(weekPctUp, (current_bin + k) % 52)
    float windowAvgUp = windowPctSum / i_forecast_window
    float labelAvgPctSum = 0.0
    for k = 0 to i_current_label_avg_weeks - 1
        labelAvgPctSum += array.get(weekPctUp, (current_bin + k) % 52)
    float labelAvgPct = labelAvgPctSum / i_current_label_avg_weeks
    int currentMonthIdx = math.min(11, math.max(0, month(time_close) - 1))
    float currentMonthPct = array.get(monthPctUp, currentMonthIdx)
    int currentMonthSamples = array.get(monthCnt, currentMonthIdx)
    int currentTdmMonthNo = na(tdm_track_month) ? currentMonthIdx + 1 : math.max(1, math.min(tdm_track_month, TDM_MONTHS))
    string tdmLabelPrefix = i_tdm_scope == "Current month" ? f_month_name(currentTdmMonthNo) + " " : ""
    int safeCurrentTdm = na(current_tdm_no) ? 1 : math.max(1, math.min(current_tdm_no, i_tdm_max_day))
    float currentTdmPct = i_enable_tdm ? f_tdm_pct_up(currentTdmMonthNo, safeCurrentTdm) : na
    float currentTdmAvg = i_enable_tdm ? f_tdm_avg_pct(currentTdmMonthNo, safeCurrentTdm) : na
    int currentTdmSamples = i_enable_tdm ? f_tdm_samples(currentTdmMonthNo, safeCurrentTdm) : 0
    int currentTdmRequired = i_enable_tdm ? f_tdm_required_samples() : 0
    bool currentTdmQualified = currentTdmSamples >= currentTdmRequired
    string currentTdmLabel = tdmLabelPrefix + "D" + str.tostring(safeCurrentTdm)

    if i_show_week_boxes
        int activeYear = year(time_close)
        int yearLookback = math.min(bar_index, 60)
        int yearStartTime = na
        int prevMonthSeen = na
        int avgWindowRightTs = time + i_current_label_avg_weeks * WEEK_MS
        int avgWindowEndBin = (current_bin + i_current_label_avg_weeks - 1) % 52
        string avgLabelText = f_slot_text(current_bin) + "-" + f_slot_text(avgWindowEndBin) + "\n" +
             str.tostring(i_current_label_avg_weeks) + "W Avg\n" +
             str.tostring(math.round(labelAvgPct, 1)) + "%"

        for i = 0 to yearLookback
            int barTs = time_close[i]
            if year(barTs) == activeYear
                int leftTs = time[i]
                int rightTs = time_close[i]
                int wk = math.min(51, math.max(0, weekofyear(barTs) - 1))
                float wPctUp = array.get(weekPctUp, wk)
                float wHeight = (wPctUp - 50.0) * i_box_scale
                float wTop = wHeight > 0 ? wHeight : 0.0
                float wBot = wHeight > 0 ? 0.0 : wHeight
                bool isCurrentBar = i == 0
                color wCol = isCurrentBar ? color.new(i_now_col, int(math.min(i_box_alpha, 35))) : f_box_color(wPctUp)
                color borderCol = isCurrentBar ? i_now_col : color.new(i_panel_col, 80)
                array.push(year_boxes, box.new(leftTs, wTop, rightTs, wBot,
                     border_color=borderCol, border_width=isCurrentBar ? 2 : 0,
                     xloc=xloc.bar_time, bgcolor=wCol))

                yearStartTime := na(yearStartTime) ? leftTs : math.min(yearStartTime, leftTs)

                int thisMonth = month(barTs)
                if i_show_month_guides and not na(prevMonthSeen) and thisMonth != prevMonthSeen
                    array.push(year_guides, line.new(rightTs, -105, rightTs, 105,
                         xloc=xloc.bar_time, color=color.new(i_neutral_col, 72),
                         width=1, style=line.style_dotted))
                prevMonthSeen := thisMonth

                if i_show_box_text
                    int midTs = int(math.round((leftTs + rightTs) / 2.0))
                    string pctText = (isCurrentBar ? f_slot_text(wk) + "\n" : "") + str.tostring(math.round(wPctUp, 0)) + "%"
                    array.push(year_labels, label.new(midTs, i_bottom_label_y, text=pctText,
                         xloc=xloc.bar_time, yloc=yloc.price,
                         style=label.style_none, color=color.new(i_panel_col, 100),
                         textcolor=f_prob_text_color(wPctUp), size=size.tiny))

        if not na(yearStartTime)
            array.push(year_guides, line.new(yearStartTime, 0, time_close, 0,
                 xloc=xloc.bar_time, color=color.new(i_neutral_col, 55), width=1))

        int weeksToYearEnd = 0
        if i_complete_current_year
            for step = 1 to 60
                int testLeftTs = time + step * WEEK_MS
                if year(testLeftTs) == activeYear
                    weeksToYearEnd := step
        int futureBoxBars = math.min(math.max(i_bernstein_future, weeksToYearEnd), 260)
        if futureBoxBars > 0
            for step = 1 to futureBoxBars
                // Keep projected boxes on the calendar time axis instead of compressed bar-index space.
                int fLeftTs = time + step * WEEK_MS
                int fRightTs = time_close + step * WEEK_MS
                int fMidTs = int(math.round((fLeftTs + fRightTs) / 2.0))
                int fwk = math.min(51, math.max(0, weekofyear(fRightTs) - 1))
                float fPctUp = array.get(weekPctUp, fwk)
                float fHeight = (fPctUp - 50.0) * i_box_scale
                float fTop = fHeight > 0 ? fHeight : 0.0
                float fBot = fHeight > 0 ? 0.0 : fHeight
                bool inWindow = step <= i_forecast_window

                array.push(year_boxes, box.new(fLeftTs, fTop, fRightTs, fBot,
                     border_color=inWindow ? color.new(i_now_col, 55) : color.new(i_panel_col, 85),
                     border_width=inWindow ? 1 : 0, xloc=xloc.bar_time,
                     bgcolor=f_box_color(fPctUp)))

                int prevLeftTs = time + (step - 1) * WEEK_MS
                bool monthChange = month(fLeftTs) != month(prevLeftTs)
                if i_show_month_guides and monthChange
                    array.push(year_guides, line.new(fLeftTs, -105, fLeftTs, 105,
                         xloc=xloc.bar_time, color=color.new(i_neutral_col, 72),
                         width=1, style=line.style_dotted))

                if i_show_box_text
                    string fText = f_slot_text(fwk) + "\n" + str.tostring(math.round(fPctUp, 0)) + "%"
                    array.push(year_labels, label.new(fMidTs, i_bottom_label_y, text=fText,
                         xloc=xloc.bar_time, yloc=yloc.price,
                         style=label.style_none, color=color.new(i_panel_col, 100),
                         textcolor=f_prob_text_color(fPctUp), size=size.tiny))

        array.push(year_boxes, box.new(time, 105, avgWindowRightTs, -105,
             border_color=color.new(i_now_col, 100), border_width=0,
             xloc=xloc.bar_time, bgcolor=color.new(i_now_col, 92),
             text=avgLabelText, text_size=size.small, text_color=f_prob_text_color(labelAvgPct),
             text_halign=text.align_center, text_valign=text.align_top))

    if i_show_stats_table
        table.cell(stats_table, 0, 0, "Today", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_head_bg)
        table.cell(stats_table, 1, 0, currentTdmLabel, text_color=i_now_col, text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 2, 0, "", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 3, 0, "trading day", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)

        table.cell(stats_table, 0, 1, "Signal", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_head_bg)
        table.cell(stats_table, 1, 1, "%Up", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_head_bg)
        table.cell(stats_table, 2, 1, "%Down", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_head_bg)
        table.cell(stats_table, 3, 1, "Extra", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_head_bg)

        table.cell(stats_table, 0, 2, f_slot_text(current_bin), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 1, 2, f_fmt_pct(curBernPct), text_color=f_prob_text_color(curBernPct), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 2, 2, f_fmt_pct(100.0 - curBernPct), text_color=f_prob_text_color(100.0 - curBernPct), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 3, 2, "n=" + str.tostring(array.get(bernCnt, current_bin)), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)

        table.cell(stats_table, 0, 3, str.tostring(i_forecast_window) + "W run", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 1, 3, f_fmt_pct(windowAvgUp), text_color=f_prob_text_color(windowAvgUp), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 2, 3, f_fmt_pct(100.0 - windowAvgUp), text_color=f_prob_text_color(100.0 - windowAvgUp), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 3, 3, "rel " + f_fmt_pct(i_reliab), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)

        table.cell(stats_table, 0, 4, f_month_name(currentMonthIdx + 1), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 1, 4, f_fmt_pct(currentMonthPct), text_color=f_prob_text_color(currentMonthPct), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 2, 4, f_fmt_pct(100.0 - currentMonthPct), text_color=f_prob_text_color(100.0 - currentMonthPct), text_size=size.tiny, bgcolor=i_table_bg)
        string monthBasisShort = i_month_basis == "Weekly bars" ? "Weekly" : "Monthly"
        table.cell(stats_table, 3, 4, monthBasisShort + " n=" + str.tostring(currentMonthSamples), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)

        float tdmBgPct = currentTdmQualified and not na(currentTdmPct) ? currentTdmPct : 50.0
        table.cell(stats_table, 0, 5, "Now: " + currentTdmLabel, text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 1, 5, f_fmt_pct(currentTdmPct), text_color=f_prob_text_color(tdmBgPct), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 2, 5, f_fmt_pct(100.0 - currentTdmPct), text_color=f_prob_text_color(100.0 - tdmBgPct), text_size=size.tiny, bgcolor=i_table_bg)
        table.cell(stats_table, 3, 5, "n=" + str.tostring(currentTdmSamples) + "/" + str.tostring(currentTdmRequired) + " " + f_fmt_signed_pct(currentTdmAvg), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)

        int tdmRow = 6
        bool hasTdmHit = false
        if i_enable_tdm
            for tdmDay = 1 to i_tdm_max_day
                int samples = f_tdm_samples(currentTdmMonthNo, tdmDay)
                if samples >= currentTdmRequired
                    float upPct = f_tdm_pct_up(currentTdmMonthNo, tdmDay)
                    float downPct = 100.0 - upPct
                    bool isHit = upPct >= i_reliab or downPct >= i_reliab
                    if isHit and tdmRow <= 28
                        float avgPct = f_tdm_avg_pct(currentTdmMonthNo, tdmDay)
                        table.cell(stats_table, 0, tdmRow, "D" + str.tostring(tdmDay), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
                        table.cell(stats_table, 1, tdmRow, f_fmt_pct(upPct), text_color=f_prob_text_color(upPct), text_size=size.tiny, bgcolor=i_table_bg)
                        table.cell(stats_table, 2, tdmRow, f_fmt_pct(downPct), text_color=f_prob_text_color(downPct), text_size=size.tiny, bgcolor=i_table_bg)
                        table.cell(stats_table, 3, tdmRow, "n=" + str.tostring(samples) + " " + f_fmt_signed_pct(avgPct), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
                        tdmRow += 1
                        hasTdmHit := true

        if not hasTdmHit
            table.cell(stats_table, 0, tdmRow, "No TDM", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
            table.cell(stats_table, 1, tdmRow, ">" + f_fmt_pct(i_reliab), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
            table.cell(stats_table, 2, tdmRow, "", text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
            table.cell(stats_table, 3, tdmRow, "min n=" + str.tostring(currentTdmRequired), text_color=i_text_col, text_size=size.tiny, bgcolor=i_table_bg)
            tdmRow += 1

        if tdmRow <= 28
            table.clear(stats_table, 0, tdmRow, 3, 28)
    else
        table.clear(stats_table, 0, 0, 3, 28)
````
