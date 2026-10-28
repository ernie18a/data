# MTF SMA & EMA

- url: https://www.tradingview.com/script/lQtKjYul/
- type: indicator
- pine_id: PUB;6c92325e50b64dbd9b40b7cc02d85a69
- version: 14.0

## Description

This indicator is an all-in-one trend analysis tool designed to give traders a comprehensive macro and micro view of moving averages (SMAs & EMAs) across multiple timeframes simultaneously. It perfectly combines a dynamic, color-coded dashboard with customizable on-chart plots, allowing you to read the market trend without constantly switching timeframes.

🔥 Key Features:

Multi-Timeframe (MTF) Dashboard: Instantly view SMA (5, 8, 13) and EMA (21, 34, 55, 89, 100, 144, 200, 233, 377) values for 4 distinct timeframes (20-Min, 1-Hour, 4-Hour, and 1-Day) all in one clean, right-aligned table.

Dynamic Distance Percentage: Each cell goes beyond just showing the MA value; it calculates and displays the exact percentage distance between the current live price and that specific moving average (e.g., +0.50% or -1.20%).

Visual Trend Indication (Heatmap): The dashboard acts as a trend heatmap. If the current price is above a moving average, the cell turns Teal (Bullish). If the price is below, it turns Maroon (Bearish). This allows for split-second trend identification across multiple dimensions.

Centered Live Price: The current market price is elegantly merged and centered at the top of the dashboard for quick visual reference.

On-Chart Plots: While the table shows the macro picture, the indicator automatically draws the selected moving averages for your current chart timeframe.

Highly Optimized (No Lag): Built entirely in Pine Script™ v5, the code utilizes custom type objects and grouped request.security() calls. This advanced architecture ensures maximum performance and completely bypasses the typical security call limits.

⚙️ How to Use & Customize:

Inputs Tab (Table Control): You have full control over the dashboard. Want to hide the 1-Day column? Or maybe hide EMA 377? Simply uncheck them in the inputs. The table will automatically resize and re-center the remaining data flawlessly.

Style Tab (Chart Control): You can easily toggle the visibility, color, and line thickness of the moving averages plotted directly on your chart via the indicator's Style settings.

Whether you are a scalper looking for quick pullbacks to the 20-min MAs, or a swing trader checking the 4H/1D macro trend alignment, this dashboard provides all the necessary data at a single glance.

## Source Code

````pine
//@version=6
indicator("MTFSMAEMA", overlay=true, max_lines_count=0, max_labels_count=0)

// =====================================================================
// --- HELPER FUNCTION: ROUND TO MINTICK (FAIL-SAFE) ---
// =====================================================================
f_round(val) => 
    if syminfo.mintick == 0 or na(syminfo.mintick) or na(val)
        math.round(val)
    else
        math.round(val / syminfo.mintick) * syminfo.mintick

// =====================================================================
// --- USER INPUTS: VISIBILITY TOGGLES ---
// =====================================================================
grp_vis = "VISIBILITY TOGGLES"
show_plots = input.bool(true, "Show MA Lines on Chart", group=grp_vis)
show_table = input.bool(true, "Show MTF Dashboard (Right)", group=grp_vis)
show_radar = input.bool(true, "Show Binary Radar (Top Center)", group=grp_vis)

// =====================================================================
// --- USER INPUTS: CALCULATION MODES ---
// =====================================================================
grp_calc = "CALCULATION MODES"
calc_mode_tbl   = input.string("Bar Close (Confirmed)", title="Table & Radar Calculation", options=["Live (Real-time)", "Bar Close (Confirmed)"], group=grp_calc)
calc_mode_chart = input.string("Live (Real-time)",      title="Chart Plots Calculation",   options=["Live (Real-time)", "Bar Close (Confirmed)"], group=grp_calc)

// =====================================================================
// --- USER INPUTS: TABLE SETTINGS ---
// =====================================================================
grp_tf = "DISPLAY TIMEFRAMES (TABLE)"
in_show_20m = input.bool(true, "20 Minutes", group=grp_tf)
in_show_1h  = input.bool(true, "1 Hour",     group=grp_tf)
in_show_4h  = input.bool(true, "4 Hours",    group=grp_tf)
in_show_1d  = input.bool(true, "1 Day",      group=grp_tf)

grp_sma = "SMA SETTINGS (TABLE)"
show_sma5  = input.bool(true, "SMA 5",  group=grp_sma)
show_sma8  = input.bool(true, "SMA 8",  group=grp_sma)
show_sma13 = input.bool(true, "SMA 13", group=grp_sma)

grp_ema = "EMA SETTINGS (TABLE)"
show_ema21  = input.bool(true, "EMA 21",  group=grp_ema)
show_ema34  = input.bool(true, "EMA 34",  group=grp_ema)
show_ema55  = input.bool(true, "EMA 55",  group=grp_ema)
show_ema89  = input.bool(true, "EMA 89",  group=grp_ema)
show_ema100 = input.bool(true, "EMA 100", group=grp_ema)
show_ema144 = input.bool(true, "EMA 144", group=grp_ema)
show_ema200 = input.bool(true, "EMA 200", group=grp_ema)
show_ema233 = input.bool(true, "EMA 233", group=grp_ema)
show_ema377 = input.bool(true, "EMA 377", group=grp_ema)

// =====================================================================
// --- OTOMATİK GÜVENLİK KALKANI ---
// =====================================================================
curr_tf_sec = timeframe.in_seconds(timeframe.period)
show_20m = in_show_20m and (curr_tf_sec <= 1200)
show_1h  = in_show_1h  and (curr_tf_sec <= 3600)
show_4h  = in_show_4h  and (curr_tf_sec <= 14400)
show_1d  = in_show_1d  and (curr_tf_sec <= 86400)

// =====================================================================
// --- KRİTİK OPTİMİZASYON: KOŞULLU request.security ---
// Her TF için sadece aktif olduğunda hesapla; 12 yerine MAX 12 seri/TF
// Tüm MA'lar tek dizide taşınır → tip sistemi yerine float dizisi
// =====================================================================
is_live_mode = calc_mode_tbl == "Live (Real-time)"
src_tbl = is_live_mode ? close : close[1]
curr_price = close

// Tek bir timeframe için tüm MA değerlerini [12] float dizisi olarak döndür
// index: 0=sma5,1=sma8,2=sma13,3=ema21,4=ema34,5=ema55,
//        6=ema89,7=ema100,8=ema144,9=ema200,10=ema233,11=ema377
calc_mas_arr(s) =>
    float[] r = array.new_float(12, na)
    if show_sma5   or show_radar
        array.set(r, 0, ta.sma(s, 5))
    if show_sma8   or show_radar
        array.set(r, 1, ta.sma(s, 8))
    if show_sma13  or show_radar
        array.set(r, 2, ta.sma(s, 13))
    if show_ema21  or show_radar
        array.set(r, 3, ta.ema(s, 21))
    if show_ema34  or show_radar
        array.set(r, 4, ta.ema(s, 34))
    if show_ema55  or show_radar
        array.set(r, 5, ta.ema(s, 55))
    if show_ema89  or show_radar
        array.set(r, 6, ta.ema(s, 89))
    if show_ema100 or show_radar
        array.set(r, 7, ta.ema(s, 100))
    if show_ema144 or show_radar
        array.set(r, 8, ta.ema(s, 144))
    if show_ema200 or show_radar
        array.set(r, 9, ta.ema(s, 200))
    if show_ema233 or show_radar
        array.set(r, 10, ta.ema(s, 233))
    if show_ema377 or show_radar
        array.set(r, 11, ta.ema(s, 377))
    r

// request.security: sadece gerekli TF'ler çağrılır
data_20m = show_20m ? request.security(syminfo.tickerid, "20",  calc_mas_arr(src_tbl), gaps=barmerge.gaps_off) : array.new_float(12, na)
data_1h  = show_1h  ? request.security(syminfo.tickerid, "60",  calc_mas_arr(src_tbl), gaps=barmerge.gaps_off) : array.new_float(12, na)
data_4h  = show_4h  ? request.security(syminfo.tickerid, "240", calc_mas_arr(src_tbl), gaps=barmerge.gaps_off) : array.new_float(12, na)
data_1d  = show_1d  ? request.security(syminfo.tickerid, "1D",  calc_mas_arr(src_tbl), gaps=barmerge.gaps_off) : array.new_float(12, na)
curr_data = calc_mas_arr(src_tbl)

// =====================================================================
// --- MA İSİMLERİ VE SHOW FLAG'LERİ ---
// =====================================================================
var string[] ma_labels = array.from("SMA 5","SMA 8","SMA 13","EMA 21","EMA 34","EMA 55","EMA 89","EMA 100","EMA 144","EMA 200","EMA 233","EMA 377")
var bool[]   ma_shows  = array.from(false,false,false,false,false,false,false,false,false,false,false,false)

// =====================================================================
// --- TABLE ---
// =====================================================================
var table ma_tbl = table.new(position.top_right, columns=5, rows=16, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    // show flag'lerini güncelle
    array.set(ma_shows, 0, show_sma5)
    array.set(ma_shows, 1, show_sma8)
    array.set(ma_shows, 2, show_sma13)
    array.set(ma_shows, 3, show_ema21)
    array.set(ma_shows, 4, show_ema34)
    array.set(ma_shows, 5, show_ema55)
    array.set(ma_shows, 6, show_ema89)
    array.set(ma_shows, 7, show_ema100)
    array.set(ma_shows, 8, show_ema144)
    array.set(ma_shows, 9, show_ema200)
    array.set(ma_shows, 10, show_ema233)
    array.set(ma_shows, 11, show_ema377)

    if show_table
        float rnd_curr = f_round(curr_price)
        int bull_cnt = 0
        int total_cnt = 0

        // --- HEADER SATIRI (row 1): Zaman dilimi etiketleri ---
        table.cell(ma_tbl, 0, 1, "MA Label", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
        int ci = 1
        if show_20m
            table.cell(ma_tbl, ci, 1, "20 Min",  text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
            ci += 1
        if show_1h
            table.cell(ma_tbl, ci, 1, "1 Hour",  text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
            ci += 1
        if show_4h
            table.cell(ma_tbl, ci, 1, "4 Hours", text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)
            ci += 1
        if show_1d
            table.cell(ma_tbl, ci, 1, "1 Day",   text_color=color.white, bgcolor=color.new(color.blue, 40), text_size=size.small)

        // --- MA SATIRLARI (row 2'den itibaren) ---
        int r = 2
        for i = 0 to 11
            if array.get(ma_shows, i)
                string lbl = array.get(ma_labels, i)
                table.cell(ma_tbl, 0, r, lbl, text_color=color.white, bgcolor=color.new(color.gray, 80), text_size=size.small)
                int ci2 = 1
                float[] tfd = array.new_float(0)
                // 4 TF datasını sıraya koy
                if show_20m
                    array.push(tfd, array.get(data_20m, i))
                if show_1h
                    array.push(tfd, array.get(data_1h, i))
                if show_4h
                    array.push(tfd, array.get(data_4h, i))
                if show_1d
                    array.push(tfd, array.get(data_1d, i))

                for j = 0 to array.size(tfd) - 1
                    float mv = array.get(tfd, j)
                    if not na(mv)
                        float rmv = f_round(mv)
                        bool is_bull = rnd_curr >= rmv
                        float pct = mv != 0 ? ((curr_price - mv) / mv) * 100 : 0
                        string sign = pct >= 0 ? "+" : ""
                        string cell_txt = str.tostring(mv, format.mintick) + "\n(" + sign + str.tostring(pct, "0.00") + "%)"
                        color bg_col = is_bull ? color.new(color.teal, 60) : color.new(color.maroon, 60)
                        table.cell(ma_tbl, ci2, r, cell_txt, text_color=color.white, bgcolor=bg_col, text_size=size.small)
                        if is_bull
                            bull_cnt += 1
                        total_cnt += 1
                    else
                        table.cell(ma_tbl, ci2, r, "N/A", text_color=color.gray, bgcolor=color.new(color.black, 80), text_size=size.small)
                    ci2 += 1
                r += 1

        // --- ROW 0: Fiyat + Trend Health ---
        float trend_score = total_cnt > 0 ? (bull_cnt / total_cnt) * 100 : 0
        string trend_txt = "Price: " + str.tostring(curr_price, format.mintick) + "   |   Trend: " + str.tostring(trend_score, "#.00") + "% Bullish"
        color trend_bg = trend_score >= 50 ? color.new(color.teal, 30) : color.new(color.maroon, 30)
        table.cell(ma_tbl, 0, 0, trend_txt, text_color=color.white, bgcolor=trend_bg, text_size=size.small)
        int last_col = (show_20m ? 1 : 0) + (show_1h ? 1 : 0) + (show_4h ? 1 : 0) + (show_1d ? 1 : 0)
        if last_col > 0
            table.merge_cells(ma_tbl, 0, 0, last_col, 0)
    else
        table.clear(ma_tbl, 0, 0, 4, 15)

// =====================================================================
// --- CHART PLOTS ---
// =====================================================================
src_chart = calc_mode_chart == "Live (Real-time)" ? close : close[1]

plot(show_plots and show_sma5   ? ta.sma(src_chart, 5)   : na, color=#FFFFFF,  title="SMA 5")
plot(show_plots and show_sma8   ? ta.sma(src_chart, 8)   : na, color=#FFEB3B,  title="SMA 8")
plot(show_plots and show_sma13  ? ta.sma(src_chart, 13)  : na, color=#FF9800,  title="SMA 13")
plot(show_plots and show_ema21  ? ta.ema(src_chart, 21)  : na, color=#FF5252,  title="EMA 21")
plot(show_plots and show_ema34  ? ta.ema(src_chart, 34)  : na, color=#FF4081,  title="EMA 34")
plot(show_plots and show_ema55  ? ta.ema(src_chart, 55)  : na, color=#E040FB,  title="EMA 55")
plot(show_plots and show_ema89  ? ta.ema(src_chart, 89)  : na, color=#448AFF,  title="EMA 89")
plot(show_plots and show_ema100 ? ta.ema(src_chart, 100) : na, color=#00BCD4,  title="EMA 100")
plot(show_plots and show_ema144 ? ta.ema(src_chart, 144) : na, color=#1DE9B6,  title="EMA 144")
plot(show_plots and show_ema200 ? ta.ema(src_chart, 200) : na, color=#00E676,  title="EMA 200", linewidth=2)
plot(show_plots and show_ema233 ? ta.ema(src_chart, 233) : na, color=#CDDC39,  title="EMA 233")
plot(show_plots and show_ema377 ? ta.ema(src_chart, 377) : na, color=#B0BEC5,  title="EMA 377", linewidth=2)

// =====================================================================
// --- RADAR ---
// =====================================================================
var table radar_tbl = table.new(position.top_center, columns=3, rows=6, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.new(color.gray, 60))

var float[] r_vals  = array.new_float(3, na)
var string[] r_names = array.new_string(3, "N/A")
var float[] s_vals  = array.new_float(3, na)
var string[] s_names = array.new_string(3, "N/A")

f_radar_push(float val, string name, float price) =>
    if not na(val)
        float m = f_round(val)
        float gap = syminfo.mintick * 2
        if m > price + gap
            bool is_dupe = false
            for k = 0 to 2
                float rv = array.get(r_vals, k)
                if not na(rv) and math.abs(m - rv) <= gap
                    is_dupe := true
            if not is_dupe
                float v0 = array.get(r_vals, 0)
                float v1 = array.get(r_vals, 1)
                if na(v0) or m < v0
                    array.set(r_vals, 2, v1),            array.set(r_names, 2, array.get(r_names, 1))
                    array.set(r_vals, 1, v0),            array.set(r_names, 1, array.get(r_names, 0))
                    array.set(r_vals, 0, m),             array.set(r_names, 0, name)
                else if na(v1) or m < v1
                    array.set(r_vals, 2, v1),            array.set(r_names, 2, array.get(r_names, 1))
                    array.set(r_vals, 1, m),             array.set(r_names, 1, name)
                else
                    float v2 = array.get(r_vals, 2)
                    if na(v2) or m < v2
                        array.set(r_vals, 2, m),         array.set(r_names, 2, name)
        else if m < price - gap
            bool is_dupe = false
            for k = 0 to 2
                float sv = array.get(s_vals, k)
                if not na(sv) and math.abs(m - sv) <= gap
                    is_dupe := true
            if not is_dupe
                float v0 = array.get(s_vals, 0)
                float v1 = array.get(s_vals, 1)
                if na(v0) or m > v0
                    array.set(s_vals, 2, v1),            array.set(s_names, 2, array.get(s_names, 1))
                    array.set(s_vals, 1, v0),            array.set(s_names, 1, array.get(s_names, 0))
                    array.set(s_vals, 0, m),             array.set(s_names, 0, name)
                else if na(v1) or m > v1
                    array.set(s_vals, 2, v1),            array.set(s_names, 2, array.get(s_names, 1))
                    array.set(s_vals, 1, m),             array.set(s_names, 1, name)
                else
                    float v2 = array.get(s_vals, 2)
                    if na(v2) or m > v2
                        array.set(s_vals, 2, m),         array.set(s_names, 2, name)

f_eval_tf(float[] d, string tf_name, float price) =>
    for i = 0 to 11
        if array.get(ma_shows, i)
            float mv = array.get(d, i)
            f_radar_push(mv, tf_name + " " + array.get(ma_labels, i), price)

if barstate.islast
    if show_radar
        array.fill(r_vals, na),  array.fill(r_names, "N/A")
        array.fill(s_vals, na),  array.fill(s_names, "N/A")
        float rnd_price = f_round(src_tbl)

        if show_20m
            f_eval_tf(data_20m, "20m", rnd_price)
        if show_1h
            f_eval_tf(data_1h,  "1h",  rnd_price)
        if show_4h
            f_eval_tf(data_4h,  "4h",  rnd_price)
        if show_1d
            f_eval_tf(data_1d,  "1d",  rnd_price)
        f_eval_tf(curr_data, timeframe.period, rnd_price)

        float closest_sup = array.get(s_vals, 0)
        string closest_sup_name = array.get(s_names, 0)
        float closest_res = array.get(r_vals, 0)
        string closest_res_name = array.get(r_names, 0)

        float min_dist_sup = not na(closest_sup) ? rnd_price - closest_sup : 999999
        float min_dist_res = not na(closest_res) ? closest_res - rnd_price : 999999

        string trade_action = "WAIT"
        color  action_col   = color.gray
        string setup_desc   = ""

        if not na(closest_sup) and not na(closest_res)
            if min_dist_sup <= min_dist_res
                trade_action := "BUY (Bounce)"
                action_col   := color.new(color.teal, 30)
                setup_desc   := "Bounce from " + closest_sup_name
            else
                trade_action := "SELL (Reject)"
                action_col   := color.new(color.maroon, 30)
                setup_desc   := "Reject from " + closest_res_name

        string sl_val   = "N/A", string sl_name  = "N/A"
        string tp1_val  = "N/A", string tp1_name = "N/A"
        string tp2_val  = "N/A", string tp2_name = "N/A"
        string tp3_val  = "N/A", string tp3_name = "N/A"
        color sl_col = color.silver, color tp_col = color.silver

        if trade_action == "BUY (Bounce)"
            sl_val  := not na(closest_sup) ? str.tostring(closest_sup, format.mintick) : "N/A"
            sl_name := closest_sup_name
            sl_col  := color.new(color.red, 0)
            tp_col  := color.new(color.green, 0)
            tp1_val  := not na(array.get(r_vals, 0)) ? str.tostring(array.get(r_vals, 0), format.mintick) : "N/A"
            tp1_name := array.get(r_names, 0)
            tp2_val  := not na(array.get(r_vals, 1)) ? str.tostring(array.get(r_vals, 1), format.mintick) : "N/A"
            tp2_name := array.get(r_names, 1)
            tp3_val  := not na(array.get(r_vals, 2)) ? str.tostring(array.get(r_vals, 2), format.mintick) : "N/A"
            tp3_name := array.get(r_names, 2)
        else if trade_action == "SELL (Reject)"
            sl_val  := not na(closest_res) ? str.tostring(closest_res, format.mintick) : "N/A"
            sl_name := closest_res_name
            sl_col  := color.new(color.red, 0)
            tp_col  := color.new(color.green, 0)
            tp1_val  := not na(array.get(s_vals, 0)) ? str.tostring(array.get(s_vals, 0), format.mintick) : "N/A"
            tp1_name := array.get(s_names, 0)
            tp2_val  := not na(array.get(s_vals, 1)) ? str.tostring(array.get(s_vals, 1), format.mintick) : "N/A"
            tp2_name := array.get(s_names, 1)
            tp3_val  := not na(array.get(s_vals, 2)) ? str.tostring(array.get(s_vals, 2), format.mintick) : "N/A"
            tp3_name := array.get(s_names, 2)

        table.cell(radar_tbl, 0, 0, "MTF Radar | Price: " + str.tostring(rnd_price, format.mintick), text_color=color.white, bgcolor=color.new(color.purple, 40), text_size=size.small)
        table.merge_cells(radar_tbl, 0, 0, 2, 0)
        table.cell(radar_tbl, 0, 1, "ACTION:", text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(radar_tbl, 1, 1, trade_action, text_color=color.white, bgcolor=action_col, text_size=size.small)
        table.cell(radar_tbl, 2, 1, setup_desc, text_color=color.silver, text_size=size.small)
        table.cell(radar_tbl, 0, 2, "SL:",   text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(radar_tbl, 1, 2, sl_name, text_color=sl_col, text_size=size.small)
        table.cell(radar_tbl, 2, 2, sl_val,  text_color=color.white, text_size=size.small)
        table.cell(radar_tbl, 0, 3, "TP 1:",  text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(radar_tbl, 1, 3, tp1_name, text_color=tp_col, text_size=size.small)
        table.cell(radar_tbl, 2, 3, tp1_val,  text_color=color.white, text_size=size.small)
        table.cell(radar_tbl, 0, 4, "TP 2:",  text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(radar_tbl, 1, 4, tp2_name, text_color=tp_col, text_size=size.small)
        table.cell(radar_tbl, 2, 4, tp2_val,  text_color=color.white, text_size=size.small)
        table.cell(radar_tbl, 0, 5, "TP 3:",  text_color=color.white, text_halign=text.align_left, text_size=size.small)
        table.cell(radar_tbl, 1, 5, tp3_name, text_color=tp_col, text_size=size.small)
        table.cell(radar_tbl, 2, 5, tp3_val,  text_color=color.white, text_size=size.small)
    else
        table.clear(radar_tbl, 0, 0, 2, 5)
````
