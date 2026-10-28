# Relative Volume

- url: https://www.tradingview.com/script/3SLEmBKa-Relative-Volume/
- type: indicator
- pine_id: PUB;011798f2e2ad43789cc974f3a1b5a12d
- version: 1.0

## Description

[b]DESCRIPTION[/b]

Relative Volume (RVOL) is an intraday volume analysis indicator designed to show how the current bar's volume compares with the typical volume recorded during the same time of day over a selected number of previous trading days.

Instead of comparing volume with a simple moving average, this indicator maintains a separate volume history for each intraday time slot. This helps account for the natural changes in trading volume throughout the trading session.

The indicator calculates:

RVOL = Current Volume ÷ Average Volume for the Same Time Slot

An RVOL value of 1.0 means the current volume is approximately equal to its historical average for that time of day.

Values above 1.0 indicate higher-than-usual participation, while values below 1.0 indicate lower-than-usual activity.

USER INPUTS :

1️⃣ CALCULATION

Lookback (Trading Days)
Defines how many previous trading days are used to calculate the average volume for each intraday time slot.

Default: 30 Trading Days
Range: 1–250 Trading Days

Plot Mode
Choose how the volume information is displayed:

• Volume — Displays actual volume columns along with the historical time-slot average.
• RVOL Ratio — Displays the Relative Volume ratio, where 1.0 represents the historical average.

2️⃣ RVOL TIERS

🩶 Dead Below
Defines the RVOL level below which volume is considered extremely low or "dead."

Default: 0.5

🟠 High Above
Defines the RVOL level at which volume is considered significantly higher than its historical average.

Default: 1.5

🔴 Extreme Above
Defines the RVOL level at which volume is considered extremely high compared with its historical average.

Default: 2.5

3️⃣ DISPLAY

Color Mode

• Tiers — Uses predefined volume categories.
• Gradient — Uses a continuous color gradient based on the RVOL value.

Palette

• Neon
• Muted
• Native
• Custom

The Custom option allows users to define their own cool, hot, neutral, and baseline colors.

4️⃣ EFFECTS

Glow on Extreme Columns
Adds a visual glow around extreme-volume columns to make major volume spikes easier to identify.

Color Price Bars
Optionally colors significant high-volume candles directly on the price chart.

It is designed as a volume analysis and confirmation tool that can be used alongside a trading strategy. Traders can use changes in RVOL to identify periods of increasing or decreasing market participation and combine this information with their own entry and exit methodology.

[b]WHY IT IS UNIQUE:[/b]

The main advantage of this indicator is that it does not simply compare current volume with a generic volume moving average.

Instead, it compares the current bar with the historical average volume of the same time-of-day slot.

For example, if the current candle is at 10:30 AM, its volume is compared with the historical 10:30 AM volume from the selected number of previous trading days.

This approach helps account for the natural intraday volume profile, where some parts of the trading session normally have much higher volume than others.

The indicator also provides multiple RVOL tiers:

🩶 DEAD — Very low participation
🔵 BELOW AVG — Below historical average
🟢 ABOVE AVG — Above historical average
🟠 HIGH — Strong volume activity
🔴 EXTREME — Exceptional volume activity

Extreme volume can also receive a visual glow, making unusual volume spikes immediately visible on the chart.

The indicator also excludes the current candle from the historical average calculation, helping prevent the current volume from influencing the benchmark against which it is being compared.

[b]HOW USER CAN BENEFIT FROM IT :[/b]

This indicator can help traders quickly identify when market participation is significantly different from normal.

Possible uses include:

• Identifying unusual volume spikes.

• Confirming breakouts with increased market participation.

• Identifying periods of unusually low activity.

• Detecting when market participation starts increasing.

• Using RVOL as a confirmation tool alongside price-action strategies.

• Identifying potentially important candles during intraday trading.

• Filtering trades when volume is significantly below normal.

• Comparing current volume with a more relevant time-of-day benchmark.

• Using the RVOL Ratio mode to quickly understand whether current volume is normal, below average, high, or extreme.

The indicator is intended to complement a trading methodology rather than act as a standalone buy or sell signal.

Users should combine RVOL with price action, market structure, volatility, and their own risk-management rules when making trading decisions.

ALERTS :

The indicator provides three alert conditions:

RVOL ≥ 1.0
Triggers when relative volume crosses above its time-of-day average.

RVOL ≥ High
Triggers when RVOL crosses above the user-defined High threshold.

RVOL ≥ Extreme
Triggers when RVOL crosses above the user-defined Extreme threshold.

[b]DISCLAIMER :[/b]

This indicator is an analytical tool and does not guarantee profitable trading results.

High relative volume does not necessarily mean that price will move in a particular direction. Volume should be interpreted together with price action and market conditions.

This script is provided for educational and informational purposes only and should not be considered investment, financial, or trading advice.

## Source Code

````pine
// © Shivam_Mandrai
//@version=6

indicator("Relative Volume", overlay = false, format = format.volume)

// _________________________________________________ User Inputs _____________________________________________ \\

// ------------------------------------------------ Calculation ----------------------------------------------- \\
lookback_days       = input.int(30, "Lookback (Trading Days)", minval = 1, maxval = 250, group = "1️⃣ Calculation", tooltip = "Each time slot's average volume is computed over the last N trading days.")
plot_mode           = input.string("Volume", "Plot Mode", options = ["Volume", "RVOL Ratio"], group = "1️⃣ Calculation", tooltip = "Volume = columns show actual volume with the time-slot average as a line. RVOL Ratio = columns show volume ÷ slot average, with 1.0 as the baseline.")

// ------------------------------------------------ RVOL Tiers ------------------------------------------------ \\
lvl_dead            = input.float(0.5, "🩶 Dead Below"   , minval = 0.1, step = 0.1, group = "2️⃣ RVOL Tiers", tooltip = "Below this ratio the bar is treated as dead volume and fades into the background.")
lvl_high            = input.float(1.5, "🟠 High Above"   , minval = 1.0, step = 0.1, group = "2️⃣ RVOL Tiers", tooltip = "At or above this ratio the column switches from the cool hero colour to the hot one.")
lvl_extr            = input.float(2.5, "🔴 Extreme Above", minval = 1.5, step = 0.1, group = "2️⃣ RVOL Tiers", tooltip = "At or above this ratio the column goes fully opaque and picks up the glow. This is the only element allowed to shout.")

// -------------------------------------------------- Palette ------------------------------------------------- \\
color_mode          = input.string("Tiers", "Color Mode", options = ["Tiers", "Gradient"], group = "3️⃣ Display", tooltip = "Tiers = five discrete steps built from two hero colours. Gradient = a continuous ramp from the Dead threshold to the Extreme threshold.")
palette_preset      = input.string("Neon", "Palette", options = ["Neon", "Muted", "Native", "Custom"], group = "3️⃣ Display", tooltip = "Neon = cyan/magenta on dark. Muted = softer, better on light themes. Native = TradingView's own green/red. Custom = use the three colours below.")
cool_input          = input.color(#00E5FF, "Cool / Hot"        , group = "3️⃣ Display", inline = "hero", tooltip = "Custom preset only. Cool = below the average, Hot = at or above the High tier.")
hot_input           = input.color(#FF2D75, ""                  , group = "3️⃣ Display", inline = "hero")
neut_input          = input.color(#7C8EA3, "Neutral (Dead)"    , group = "3️⃣ Display", tooltip = "Custom preset only. Used for dead volume, which should barely register.")
line_input          = input.color(#D1D4DC, "Average / Baseline", group = "3️⃣ Display", tooltip = "The slot-average line in Volume mode and the 1.0 baseline in RVOL Ratio mode.")

// ---------------------------------------------- Visual Effects ---------------------------------------------- \\
show_glow           = input.bool(true , "Glow on Extreme Columns", group = "4️⃣ Effects", tooltip = "Draws two widening, near-transparent copies of the column behind extreme bars so spikes bloom instead of just being red.")
color_bars          = input.bool(false, "Color Price Bars"       , group = "4️⃣ Effects", tooltip = "Paints only the High and Extreme candles on the price pane and leaves every other bar at the chart default.")

// _________________________________________________ Palette Resolution ______________________________________ \\

// ------------------------------------------ Hero Colours per Preset ----------------------------------------- \\
[cool_col, hot_col, neut_col] = switch palette_preset
    "Neon"   => [#00E5FF, #FF2D75, #7C8EA3]
    "Muted"  => [#29B453, #BD2B2B, #7C8EA3]
    "Native" => [#089981, #F23645, #787B86]
    =>          [cool_input, hot_input, neut_input]

// ----------------------------------- Tier Colours as a Transparency Ladder ---------------------------------- \\
c_dead              = color.new(neut_col, 85)
c_below             = color.new(cool_col, 55)
c_above             = color.new(cool_col, 20)
c_high              = color.new(hot_col , 15)
c_extr              = color.new(hot_col , 0)
grad_lo             = color.new(cool_col, 75)
grad_hi             = color.new(hot_col , 0)
avg_line_col        = color.new(line_input, 20)

// _________________________________________________ Storage _________________________________________________ \\

// ------------------------- One row per time-of-day slot, one column per trading day ------------------------- \\
var array<int>    slot_keys = array.new<int>()      // minutes-of-day key (hour * 60 + minute)
var matrix<float> m_vol     = matrix.new<float>()   // volume per slot per day
var bool          need_new_col = false

// _________________________________________________ Helper Functions ________________________________________ \\

// -------------------------------------- Zero-pad a number to two digits ------------------------------------- \\
f_two_digit(int n) =>
    (n < 10 ? "0" : "") + str.tostring(n)

// -------------------------------------- Convert minutes-key to "HH:MM" -------------------------------------- \\
f_key_to_time(int k) =>
    f_two_digit(math.floor(k / 60)) + ":" + f_two_digit(k % 60)

// --------------------------------- Mean of one matrix row, ignoring na cells -------------------------------- \\
f_row_mean(matrix<float> m, int r) =>
    float s         = 0.0
    int   c         = 0
    if r >= 0 and matrix.columns(m) > 0 and r < matrix.rows(m)
        for j = 0 to matrix.columns(m) - 1
            v       = matrix.get(m, r, j)
            if not na(v)
                s += v
                c += 1
    [c > 0 ? s / c : na, c]

// ------------------------------------- Map text-size input to size const ------------------------------------ \\
f_txt_size(string s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : size.normal

// -------------------------------------- Pick a color for the given RVOL ------------------------------------- \\
f_tier_color(float rvol) =>
    na(rvol) ? c_dead : color_mode == "Gradient" ? color.from_gradient(rvol, lvl_dead, lvl_extr, grad_lo, grad_hi) : rvol >= lvl_extr ? c_extr : rvol >= lvl_high ? c_high : rvol >= 1.0 ? c_above : rvol >= lvl_dead ? c_below : c_dead

// ----------------------------------------- Human-readable tier name ----------------------------------------- \\
f_tier_name(float rvol) =>
    na(rvol) ? "—" : rvol >= lvl_extr ? "🔴 EXTREME" : rvol >= lvl_high ? "🟠 HIGH" : rvol >= 1.0 ? "🟢 ABOVE AVG" : rvol >= lvl_dead ? "🔵 BELOW AVG" : "🩶 DEAD"

// _________________________________________________ Per-Bar Lookup __________________________________________ \\

// ------------- Runs BEFORE the storage update, so the average always excludes the current candle ------------ \\
key                 = timeframe.isintraday ? hour(time) * 60 + minute(time) : -1
slot_idx            = array.indexof(slot_keys, key)
[avg_vol, sample_cnt] = f_row_mean(m_vol, slot_idx)

// --------------------------------------- Relative volume for this bar --------------------------------------- \\
rvol                = not na(avg_vol) and avg_vol > 0 ? volume / avg_vol : na

// _________________________________________________ Data Collection _________________________________________ \\

// ------------------------------- Flag a fresh column at every new trading day ------------------------------- \\
if timeframe.change("D")
    need_new_col    := true

// ----------------------------------- Store this bar's volume into its slot ---------------------------------- \\
if barstate.isconfirmed and timeframe.isintraday and not na(volume)
    idx             = slot_idx
    // --------------------------------- Add a new row if this slot is unseen --------------------------------- \\
    if idx == -1
        array.push(slot_keys, key)
        matrix.add_row(m_vol, matrix.rows(m_vol))
        idx         := array.size(slot_keys) - 1
    // ----------------------------- Add today's column, trim beyond the lookback ----------------------------- \\
    if need_new_col or matrix.columns(m_vol) == 0
        matrix.add_col(m_vol, matrix.columns(m_vol))
        if matrix.columns(m_vol) > lookback_days
            matrix.remove_col(m_vol, 0)
        need_new_col := false
    // ------------------------------------ Write the volume into the cell ------------------------------------ \\
    matrix.set(m_vol, idx, matrix.columns(m_vol) - 1, volume)

// _________________________________________________ Plotting ________________________________________________ \\

// ----------------------------- Column height, tier color and significance flags ----------------------------- \\
bar_color           = f_tier_color(rvol)
col_val             = plot_mode == "Volume" ? volume  : rvol
line_val            = plot_mode == "Volume" ? avg_vol : 1.0
is_extreme          = not na(rvol) and rvol >= lvl_extr
is_significant      = not na(rvol) and rvol >= lvl_high

// ----------------------------- Core columns, extreme bloom and the slot average ----------------------------- \\
plot(timeframe.isintraday ? col_val : na                              , "Columns"          , color = bar_color                , style = plot.style_columns, linewidth = 1)
plot(timeframe.isintraday and show_glow and is_extreme ? col_val : na , ""                 , color = color.new(hot_col, 85)   , style = plot.style_columns, linewidth = 3, display = display.pane, editable = false)
plot(timeframe.isintraday and show_glow and is_extreme ? col_val : na , ""                 , color = color.new(hot_col, 95)   , style = plot.style_columns, linewidth = 6, display = display.pane, editable = false)
plot(timeframe.isintraday and plot_mode == "Volume" ? line_val : na   , "Avg Volume (Slot)", color = avg_line_col             , style = plot.style_line   , linewidth = 2)

// ----------------------------------- Reference levels for RVOL Ratio mode ----------------------------------- \\
plot(plot_mode == "RVOL Ratio" ? 1.0 : na          , "Baseline 1.0"  , color = color.new(line_input, 45), style = plot.style_line, linewidth = 1, display = display.pane, editable = false)
p_high              = plot(plot_mode == "RVOL Ratio" ? lvl_high : na , "", color = color.new(hot_col, 60), style = plot.style_line, linewidth = 1, display = display.pane, editable = false)
p_extr              = plot(plot_mode == "RVOL Ratio" ? lvl_extr : na , "", color = color.new(hot_col, 35), style = plot.style_line, linewidth = 1, display = display.pane, editable = false)
fill(p_high, p_extr, color = color.new(hot_col, 92), title = "High Zone")

// ----------------------------- Optional price bar painting on significant volume ---------------------------- \\
barcolor(color_bars and timeframe.isintraday and is_significant ? (is_extreme ? c_extr : c_high) : na, title = "High Volume Bars", editable = false)

// _________________________________________________ Alerts __________________________________________________ \\
alertcondition(barstate.isconfirmed and not na(rvol) and rvol >= 1.0 and nz(rvol[1]) < 1.0, "RVOL ≥ 1.0", "Relative volume crossed above its time-of-day average")
alertcondition(barstate.isconfirmed and not na(rvol) and rvol >= lvl_high and nz(rvol[1]) < lvl_high, "RVOL ≥ High", "Relative volume crossed above the High tier")
alertcondition(barstate.isconfirmed and not na(rvol) and rvol >= lvl_extr and nz(rvol[1]) < lvl_extr, "RVOL ≥ Extreme", "Relative volume crossed above the Extreme tier")
````
