# CVD Absorption - Outcome Statistics [Dots3Red]

- url: https://www.tradingview.com/script/UgaF1Yk8-CVD-Absorption-Outcome-Statistics-Dots3Red/
- type: indicator
- pine_id: PUB;6c4511a518f644958b17481f7aad9098
- version: 1.0

## Description

🧲 [b]CVD ABSORPTION - OUTCOME STATISTICS [Dots3Red][/b]
This indicator plots an approximated [b]Cumulative Volume Delta[/b], flags absorption events (heavy volume on a small-range bar with clearly one-sided pressure), and measures how often each type of absorption was followed by a reversal on the current chart, shown as a percentage with the sample size next to it.

✨ [b]WHY THIS MATTERS[/b]
Absorption is a classic order-flow idea: a lot of buying (or selling) hits the market, but price barely moves. Someone on the other side quietly took all of it. When the aggressive side runs out, price often turns. Plenty of tools flag absorption, but very few say whether it actually led to a reversal on the instrument you trade. On some charts it is a reliable warning; on others it means nothing. This script keeps score so you can see which applies to yours.

⚙️ [b]HOW IT WORKS[/b]
📊 [b]Delta approximation[/b] — each bar's volume is split into buying and selling pressure based on where the close sits within the bar's range: a close near the high counts as mostly buying, a close near the low as mostly selling. The running total is the CVD line. This is a standard approximation for feeds without bid/ask data, not true order flow.

🧲 [b]Absorption detection[/b] — a bar is flagged when all three conditions hold on that bar alone:
• Volume is well above its recent average
• The bar's range is small relative to ATR
• Delta is clearly one-sided (a set fraction of the bar's own volume)
Two types are tracked separately:
• Buying absorbed — heavy buying, price barely advanced (bearish lean)
• Selling absorbed — heavy selling, price barely fell (bullish lean)

🎯 [b]Outcome grading[/b] — each event is graded on whether price then moved a set ATR distance against the absorbed pressure within the outcome window. The ATR is frozen at the moment of the event. Events that don't reach the distance in time count as not reversed.

🔒 [b]Non-repainting[/b] — events are detected and graded on confirmed bars only. Once a marker appears it does not move or disappear.

🖥️ [b]Dashboard[/b] — current CVD, reversal rate and sample size for each absorption type, the event currently being graded, and the outcome window and reset mode.

🧭 [b]HOW TO USE[/b]
1️⃣ [b]Read the rate before reacting to a marker.[/b] "Buying absorbed: 62% reversed down (n=34)" means that on this chart, heavy buying that got stuck was followed by a meaningful drop most of the time. A rate near or below 50% means absorption hasn't been a useful reversal tell here.

2️⃣ [b]Let the sample build.[/b] Absorption events are not frequent. The dashboard shows "Collecting…" until each type has enough graded events.

3️⃣ [b]Context matters.[/b] Absorption at a range high or low, VWAP, or the previous day's high or low is usually more meaningful than absorption in the middle of a range.

4️⃣ [b]Tune detection to the instrument.[/b] Lower the volume threshold or allow a larger range for more events; tighten them for fewer, more extreme ones.

5️⃣ [b]Use it as context, not a trigger.[/b] The rates describe how absorption has behaved on this chart. They do not predict the next event.

⏱️ [b]WHICH TIMEFRAMES WORK BEST[/b]
[b]5-minute through 1-hour[/b] on liquid instruments such as index futures, large-cap stocks and major crypto. Absorption is an intraday concept, and these charts produce enough events to build a sample. 4-hour works but fills slowly. On daily and higher, each bar holds too much activity to read as a single absorption event.

🛠️ SETTINGS

📊 [b]CVD Calculation[/b] — reset mode (continuous, day, week), delta smoothing for display

🧲 [b]Absorption Detection[/b] — volume average length, volume threshold (× average), max range (× ATR), min directional delta (× volume)

🎯 [b]Outcome Grading[/b] — ATR length, reversal confirmation (× ATR), outcome window, minimum events to show a rate

📶 [b]Delta Histogram[/b] — show/hide, scaling (Auto fits the histogram to a share of the CVD line's range, Manual multiplier, or Raw values), style (columns, histogram, area), width, positive/negative colors, transparency. Scaling changes only the drawing; the dashboard always shows real values.

🎨 [b]Visualization[/b] — CVD line and thickness, absorption markers and their colors

🖥️ [b]Dashboard[/b] — show/hide, position

🔔 [b]Alerts[/b] — buying absorbed, selling absorbed

📝 [b]NOTES[/b]
Delta here is estimated from bar shape, not from bid/ask data, so it reflects buying and selling pressure only approximately. On spot forex, TradingView volume is typically tick volume from a single source, which makes volume-based readings less reliable. All rates are specific to this chart, timeframe and settings, and do not transfer to other instruments or configurations.

⚠️ [b]DISCLAIMER[/b]
This is an analytical and visualization tool. It does not generate trade signals and does not constitute financial advice. Historical statistics do not guarantee future performance.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("CVD Absorption - Outcome Statistics [Dots3Red]",
          shorttitle = "CVD Absorption [D3R]",
          overlay    = false,
          max_labels_count = 500)


// COLORS
C_BG      = color.new(#131722, 5)
C_TXT     = color.new(#f8fafc, 0)
C_DIM     = color.new(#94a3b8, 0)
C_BORD    = color.new(#334155, 0)
C_GOOD    = color.new(#00c896, 0)
C_BAD     = color.new(#ff4466, 0)


// INPUTS
GRP_CVD = "📊 CVD Calculation"
GRP_ABS = "🧲 Absorption Detection"
GRP_ST  = "🎯 Outcome Grading"
GRP_VIS = "🎨 Visualization"
GRP_HUD = "🖥️ Dashboard"

reset_mode = input.string("Continuous", "CVD Reset", options=["Continuous", "Day", "Week"], group=GRP_CVD,
             tooltip="Continuous never resets. Day/Week restart the running total at each new period.")
smooth_len = input.int(3, "Delta Smoothing (display only)", minval=1, maxval=20, group=GRP_CVD,
             tooltip="Light smoothing on the delta histogram and CVD line. Absorption detection always uses the bar's own unsmoothed delta. 1 = no smoothing.")

vol_len   = input.int(20, "Volume Average Length", minval=5, group=GRP_ABS)
vol_mult  = input.float(1.8, "Absorption Volume Threshold (×avg)", minval=1.1, maxval=5.0, step=0.1, group=GRP_ABS,
            tooltip="Volume must exceed this multiple of its moving average to be considered heavy enough for absorption.")
range_max = input.float(0.6, "Max Range for Absorption (×ATR)", minval=0.1, maxval=1.5, step=0.05, group=GRP_ABS,
            tooltip="The bar's total range must stay below this multiple of ATR — high volume with a small range is the signature of absorption.")
delta_min = input.float(0.3, "Min Directional Delta (×volume)", minval=0.05, maxval=0.9, step=0.05, group=GRP_ABS,
            tooltip="The bar's delta must be at least this fraction of its own volume, confirming the pressure was one-sided.")

atr_len      = input.int(14, "ATR Length", minval=2, group=GRP_ST)
outcome_atr  = input.float(1.0, "Reversal Confirmation (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=GRP_ST,
               tooltip="Price must move this far opposite the absorbed pressure (ATR frozen at the event) to grade the event as reversed.")
outcome_bars = input.int(12, "Outcome Window (bars)", minval=3, maxval=60, group=GRP_ST)
min_n        = input.int(10, "Min Events to Show Rate", minval=3, group=GRP_ST)

GRP_HIST = "📶 Delta Histogram"

show_hist  = input.bool(true, "Show Delta Histogram", group=GRP_HIST)
hist_scale = input.string("Auto", "Histogram Scaling", options=["Auto", "Manual", "Raw"], group=GRP_HIST,
             tooltip="The CVD line is a running total, so it is usually far larger than one bar's delta, which makes the histogram look tiny.\nAuto: scales the histogram to a share of the CVD line's recent range.\nManual: multiplies delta by the factor below.\nRaw: true values, no scaling.\nScaling only changes the drawing; the dashboard always shows real values.")
hist_fill  = input.int(60, "Auto: Height (% of CVD range)", minval=10, maxval=150, group=GRP_HIST)
hist_mult  = input.float(10.0, "Manual: Multiplier", minval=0.1, step=0.5, group=GRP_HIST)
hist_style = input.string("Columns", "Style", options=["Columns", "Histogram", "Area"], group=GRP_HIST)
hist_w     = input.int(3, "Width (Histogram style)", minval=1, maxval=10, group=GRP_HIST)
col_up     = input.color(#00f0ff, "Positive Delta Color", group=GRP_HIST)
col_down   = input.color(#ff00aa, "Negative Delta Color", group=GRP_HIST)
hist_tr    = input.int(40, "Transparency", minval=0, maxval=95, group=GRP_HIST)

show_line  = input.bool(false, "CVD Line", group=GRP_VIS)
line_w     = input.int(1, "CVD Line Thickness", minval=1, maxval=6, group=GRP_VIS)
show_marks = input.bool(true, "Absorption Markers", group=GRP_VIS)
col_buyabs = input.color(#ff4466, "Buying Absorbed Marker (bearish lean)", group=GRP_VIS)
col_selabs = input.color(#00c896, "Selling Absorbed Marker (bullish lean)", group=GRP_VIS)

show_hud = input.bool(true, "Show Dashboard", group=GRP_HUD)
hud_pos  = input.string("Top Right", "Position",
           options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=GRP_HUD)


// DELTA APPROXIMATION 
float vol       = nz(volume)
float bar_range = high - low
float pos_in_rg = bar_range > 0 ? (close - low) / bar_range : 0.5
float raw_delta = vol * (pos_in_rg * 2.0 - 1.0)
float delta     = ta.sma(raw_delta, smooth_len)

bool chg_d    = timeframe.change("D")
bool chg_w    = timeframe.change("W")
bool do_reset = reset_mode == "Day" ? chg_d : reset_mode == "Week" ? chg_w : false

var float cvd = 0.0
if do_reset
    cvd := 0.0
cvd += nz(delta)


float atr_v  = ta.atr(atr_len)
float vol_ma = ta.sma(vol, vol_len)

bool heavy_vol   = vol_ma > 0 and vol >= vol_ma * vol_mult
bool small_range = bar_range <= range_max * atr_v
bool buy_heavy   = vol > 0 and raw_delta >=  vol * delta_min
bool sell_heavy  = vol > 0 and raw_delta <= -vol * delta_min

// Buying absorbed: heavy buying, price barely advanced → bearish lean.
bool buy_absorbed  = heavy_vol and small_range and buy_heavy
// Selling absorbed: heavy selling, price barely fell → bullish lean.
bool sell_absorbed = heavy_vol and small_range and sell_heavy


var int   pend_bar  = na
var float pend_ref  = na
var float pend_atr  = na
var bool  pend_buy  = false   // true = buying was absorbed (expects a move down)

var int buy_total = 0
var int buy_rev   = 0
var int sel_total = 0
var int sel_rev   = 0

bool new_buy_abs = false
bool new_sel_abs = false

if barstate.isconfirmed
    if not na(pend_bar)
        bool reversed = pend_buy ? (pend_ref - close) >= outcome_atr * pend_atr
                                 : (close - pend_ref) >= outcome_atr * pend_atr
        bool timed = (bar_index - pend_bar) >= outcome_bars
        if reversed or timed
            if pend_buy
                buy_total += 1
                if reversed
                    buy_rev += 1
            else
                sel_total += 1
                if reversed
                    sel_rev += 1
            pend_bar := na

    if na(pend_bar) and not na(atr_v)
        if buy_absorbed
            pend_bar := bar_index
            pend_ref := close
            pend_atr := atr_v
            pend_buy := true
            new_buy_abs := true
        else if sell_absorbed
            pend_bar := bar_index
            pend_ref := close
            pend_atr := atr_v
            pend_buy := false
            new_sel_abs := true


// VISUALS 
float cvd_rng   = ta.highest(math.abs(cvd), 200)
float delta_rng = ta.highest(math.abs(nz(delta)), 200)
float auto_k    = show_line and delta_rng > 0 ? cvd_rng / delta_rng * hist_fill / 100.0 : 1.0
float k         = hist_scale == "Auto" ? auto_k : hist_scale == "Manual" ? hist_mult : 1.0
float delta_draw = delta * k

h_style = hist_style == "Histogram" ? plot.style_histogram : hist_style == "Area" ? plot.style_area : plot.style_columns

plot(delta_draw, "Delta (scaled for display)", style=h_style, linewidth=hist_w,
     color = delta >= 0 ? color.new(col_up, hist_tr) : color.new(col_down, hist_tr),
     display = show_hist ? display.pane : display.none)
plot(show_line ? cvd : na, "CVD", color = cvd >= 0 ? col_up : col_down, linewidth=line_w,
     display = show_line ? display.all : display.none)
hline(0, "Zero", color=color.new(C_DIM, 60))

float mark_y = show_line ? cvd : show_hist ? delta_draw : 0.0

if show_marks and barstate.isconfirmed
    if new_buy_abs
        label.new(bar_index, mark_y, "🧲▼", style=label.style_label_down,
                  color=color.new(#000000, 100), textcolor=col_buyabs, size=size.small,
                  tooltip="Buying absorbed: heavy buying volume, small range")
    if new_sel_abs
        label.new(bar_index, mark_y, "🧲▲", style=label.style_label_up,
                  color=color.new(#000000, 100), textcolor=col_selabs, size=size.small,
                  tooltip="Selling absorbed: heavy selling volume, small range")


// DASHBOARD 
f_hud_pos(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

f_rate_txt(int rev, int tot, string dir_word) =>
    tot >= min_n ? str.tostring(math.round(float(rev) / tot * 100.0)) + "% reversed " + dir_word + " (n=" + str.tostring(tot) + ")" :
                   "Collecting… (n=" + str.tostring(tot) + ")"

f_rate_col(int rev, int tot) =>
    tot < min_n ? C_DIM : float(rev) / tot >= 0.55 ? C_GOOD : float(rev) / tot <= 0.45 ? C_BAD : C_TXT

var table hud = table.new(f_hud_pos(hud_pos), 2, 6,
                          bgcolor=C_BG, border_color=C_BORD,
                          border_width=1, frame_color=C_BORD, frame_width=2, force_overlay = true)

if show_hud and barstate.islast
    color bgA = color.new(#1e293b, 40)
    color bgB = color.new(#0f172a, 40)

    table.cell(hud, 0, 0, "CVD ABSORPTION [D3R]", text_color=C_TXT,
               bgcolor=color.new(#1e293b, 0), text_size=size.small, text_halign=text.align_center)
    table.merge_cells(hud, 0, 0, 1, 0)

    table.cell(hud, 0, 1, "CVD", text_color=C_DIM, bgcolor=bgA, text_size=size.small)
    table.cell(hud, 1, 1, str.tostring(cvd, format.volume),
               text_color = cvd >= 0 ? col_up : col_down, bgcolor=bgA, text_size=size.small, text_halign=text.align_center)

    table.cell(hud, 0, 2, "Buying Absorbed", text_color=col_buyabs, bgcolor=bgB, text_size=size.small,
               tooltip="Heavy buying on a small-range bar. Graded as reversed if price then fell " + str.tostring(outcome_atr) + "× ATR within " + str.tostring(outcome_bars) + " bars.")
    table.cell(hud, 1, 2, f_rate_txt(buy_rev, buy_total, "down"), text_color=f_rate_col(buy_rev, buy_total),
               bgcolor=bgB, text_size=size.small, text_halign=text.align_center)

    table.cell(hud, 0, 3, "Selling Absorbed", text_color=col_selabs, bgcolor=bgA, text_size=size.small,
               tooltip="Heavy selling on a small-range bar. Graded as reversed if price then rose " + str.tostring(outcome_atr) + "× ATR within " + str.tostring(outcome_bars) + " bars.")
    table.cell(hud, 1, 3, f_rate_txt(sel_rev, sel_total, "up"), text_color=f_rate_col(sel_rev, sel_total),
               bgcolor=bgA, text_size=size.small, text_halign=text.align_center)

    table.cell(hud, 0, 4, "Pending Event", text_color=C_DIM, bgcolor=bgB, text_size=size.small)
    table.cell(hud, 1, 4, na(pend_bar) ? "—" : (pend_buy ? "Buying absorbed" : "Selling absorbed") + " (" + str.tostring(bar_index - pend_bar) + "b ago)",
               text_color = na(pend_bar) ? C_DIM : pend_buy ? col_buyabs : col_selabs,
               bgcolor=bgB, text_size=size.small, text_halign=text.align_center)

    table.cell(hud, 0, 5, "Window / Reset", text_color=C_DIM, bgcolor=bgA, text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(outcome_bars) + " bars / " + reset_mode, text_color=C_TXT,
               bgcolor=bgA, text_size=size.small, text_halign=text.align_center)


//  ALERTS 
alertcondition(new_buy_abs, "Buying Absorbed", "D3R CVD Absorption: heavy buying absorbed without price advancing")
alertcondition(new_sel_abs, "Selling Absorbed", "D3R CVD Absorption: heavy selling absorbed without price falling")
````
