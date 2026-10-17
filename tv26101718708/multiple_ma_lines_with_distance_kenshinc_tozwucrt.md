# Multiple MA Lines with Distance (KenshinC)

- url: https://www.tradingview.com/script/tozwucrt-Multiple-MA-Lines-with-Distance-KenshinC/
- type: indicator
- pine_id: PUB;4741f32d370743b9afa7d9f47ecf247c
- version: 1.0

## Description

[b]**Multiple MA Lines with Distance (Custom Source)**[/b]

Unlock the full picture of market structure with this powerful multi-layered moving average tool.

This indicator plots **14 Simple Moving Averages** with intelligently increasing lengths — from short-term (16) to very long-term (5 years) — all calculated on a **customizable price source**. It helps you instantly see how far the current price has deviated from multiple trend layers, making it perfect for **mean-reversion**, **trend strength analysis**, **DCA strategies**, and long-term position management.

[b]### Key Features[/b]
- **Flexible MA Source**: Choose from Close, Open, High, Low, HL2, HLC3, OHLC4, or **OHL2C** (weighted OHLC with adjustable Close weight) — ideal for different market conditions (use High when price falls from peaks, Low when rising from bottoms).
- **Distance & Percentage Display**: Clear table showing absolute distance and % difference from price to each MA, with **thousand separators** and user-defined decimal precision.
- **4 Customizable Horizontal Lines**: Extend any 4 MAs as dashed support/resistance lines across the entire chart for easy visual reference.
- **Clean Visuals**: Beautiful gradient color scheme from short to long-term MAs + professional info table in the top-right corner.
- **Built-in DCA Tracker**: Visual orange line showing cumulative invested capital over time (great for dollar-cost averaging strategies).
- Fully customizable lengths, table display, decimal places, and more.

Whether you're a swing trader, position trader, or long-term investor, this tool gives you a complete "trend map" in one clean indicator — no more cluttered charts or manual calculations.

[b]### How to Use[/b]

1. **Choose Your MA Source** (Source Settings)
   - **OHL2C** (default): Balanced weighted price (recommended for most cases).
   - Switch to **High** in strong downtrends or **Low** in strong uptrends for better context.

2. **Analyze the Table** (Table Settings)
   - The table shows MA length, current MA value, distance from price, and **% difference**.
   - Positive % = Price is above the MA (strength).
   - Negative % = Price is below the MA (potential mean-reversion opportunity).
   - Use large negative % on long-term MAs (MA10–MA14) as potential buying zones.

3. **Set Horizontal Lines** (Horizontal Lines)
   - Select any 4 MAs (e.g., MA5, MA10, MA12, MA14) to display as permanent dashed horizontal levels. Excellent for identifying major support/resistance zones.

4. **DCA Mode** (DCA Settings)
   - Set your daily/periodic investment amount and start date.
   - The orange line shows your total capital deployed over time — great for tracking accumulation.

[b]**Best Timeframes**:[/b] Daily and Weekly charts (works on lower timeframes too).

[b]**Pro Tips**:[/b]
- When price deviates more than 15–25% below long-term MAs (MA10+), it often signals deep value or capitulation zones.
- Use the shortest MAs for entry timing and longest MAs for overall trend bias.
- Combine with volume or RSI for even stronger confluence.

This indicator was designed for clarity and practicality — turning complex multi-MA analysis into simple, actionable insights.

Enjoy trading smarter!  
Feedback and suggestions are always welcome.

© KenshinC

## Source Code

````pine
//@version=6
indicator("Multiple MA Lines with Distance (KenshinC)", overlay=true, max_lines_count=500, max_labels_count=500)

// ── Source Mode Settings ──
source_mode = input.string("OHL2C", "MA Source Mode", 
     options=["Close", "Open", "High", "Low", "HL2", "HLC3", "OHLC4", "OHL2C"], 
     group="Source Settings")

close_weight = input.float(2.0, "Close Weight in OHL2C (if selected)", 
     minval=0.0, step=0.1, group="Source Settings")

// Calculate source based on selected mode
ma_source = switch source_mode
    "Close"  => close
    "Open"   => open
    "High"   => high
    "Low"    => low
    "HL2"    => hl2
    "HLC3"   => hlc3
    "OHLC4"  => ohlc4
    "OHL2C"  => (open + high + low + close_weight * close) / (3 + close_weight)
    => close

// ── MA Length Settings ──
len1  = input.int(16,  "MA Length 1",  minval=1, group="MA Settings")
len2  = input.int(32,  "MA Length 2",  minval=1, group="MA Settings")
len3  = input.int(64,  "MA Length 3",  minval=1, group="MA Settings")
len4  = input.int(96,  "MA Length 4",  minval=1, group="MA Settings")
len5  = input.int(128, "MA Length 5",  minval=1, group="MA Settings")
len6  = input.int(160, "MA Length 6",  minval=1, group="MA Settings")
len7  = input.int(192, "MA Length 7",  minval=1, group="MA Settings")
len8  = input.int(256, "MA Length 8",  minval=1, group="MA Settings")
len9  = input.int(320, "MA Length 9",  minval=1, group="MA Settings")
len10 = input.int(365, "MA Length 10", minval=1, group="MA Settings")
len11 = input.int(730, "MA Length 11", minval=1, group="MA Settings")
len12 = input.int(1095,"MA Length 12", minval=1, group="MA Settings")
len13 = input.int(1460,"MA Length 13", minval=1, group="MA Settings")
len14 = input.int(1825,"MA Length 14", minval=1, group="MA Settings")

// ── Horizontal Lines Settings ──
ma_line1 = input.int(5,  "Horizontal Line 1 (MA 1-14)", minval=1, maxval=14, group="Horizontal Lines")
ma_line2 = input.int(7,  "Horizontal Line 2 (MA 1-14)", minval=1, maxval=14, group="Horizontal Lines")
ma_line3 = input.int(10, "Horizontal Line 3 (MA 1-14)", minval=1, maxval=14, group="Horizontal Lines")
ma_line4 = input.int(12, "Horizontal Line 4 (MA 1-14)", minval=1, maxval=14, group="Horizontal Lines")

// ── Table Settings ──
decimal_places = input.int(2, "Decimal Places for Table", minval=0, maxval=8, group="Table Settings")
show_table     = input.bool(true, "Show Results Table", group="Table Settings")

// Dynamic number format with thousand separator
var string num_format = ""
if barstate.isfirst
    num_format := decimal_places == 0 ? "#,##0" : "#,##0." + str.repeat("#", decimal_places)

// ── Calculate Moving Averages ──
ma1  = ta.sma(ma_source, len1)
ma2  = ta.sma(ma_source, len2)
ma3  = ta.sma(ma_source, len3)
ma4  = ta.sma(ma_source, len4)
ma5  = ta.sma(ma_source, len5)
ma6  = ta.sma(ma_source, len6)
ma7  = ta.sma(ma_source, len7)
ma8  = ta.sma(ma_source, len8)
ma9  = ta.sma(ma_source, len9)
ma10 = ta.sma(ma_source, len10)
ma11 = ta.sma(ma_source, len11)
ma12 = ta.sma(ma_source, len12)
ma13 = ta.sma(ma_source, len13)
ma14 = ta.sma(ma_source, len14)

// ── Distance and Percentage Calculation ──
f_calc_dist(ma) =>
    dist    = ma_source - ma
    percent = (1 - ma / ma_source) * 100
    [dist, percent]

[dist1,  pct1]  = f_calc_dist(ma1)
[dist2,  pct2]  = f_calc_dist(ma2)
[dist3,  pct3]  = f_calc_dist(ma3)
[dist4,  pct4]  = f_calc_dist(ma4)
[dist5,  pct5]  = f_calc_dist(ma5)
[dist6,  pct6]  = f_calc_dist(ma6)
[dist7,  pct7]  = f_calc_dist(ma7)
[dist8,  pct8]  = f_calc_dist(ma8)
[dist9,  pct9]  = f_calc_dist(ma9)
[dist10, pct10] = f_calc_dist(ma10)
[dist11, pct11] = f_calc_dist(ma11)
[dist12, pct12] = f_calc_dist(ma12)
[dist13, pct13] = f_calc_dist(ma13)
[dist14, pct14] = f_calc_dist(ma14)

// ── Get MA Value by Number ──
f_get_ma_value(ma_number) =>
    switch ma_number
        1  => ma1
        2  => ma2
        3  => ma3
        4  => ma4
        5  => ma5
        6  => ma6
        7  => ma7
        8  => ma8
        9  => ma9
        10 => ma10
        11 => ma11
        12 => ma12
        13 => ma13
        14 => ma14
        => na

// ── Horizontal Lines ──
var line hline1 = line.new(bar_index - 1, f_get_ma_value(ma_line1), bar_index, f_get_ma_value(ma_line1), 
     extend=extend.both, color=color.new(color.blue, 50), style=line.style_dashed, width=3)

var line hline2 = line.new(bar_index - 1, f_get_ma_value(ma_line2), bar_index, f_get_ma_value(ma_line2), 
     extend=extend.both, color=color.new(color.green, 50), style=line.style_dashed, width=3)

var line hline3 = line.new(bar_index - 1, f_get_ma_value(ma_line3), bar_index, f_get_ma_value(ma_line3), 
     extend=extend.both, color=color.new(color.red, 50), style=line.style_dashed, width=3)

var line hline4 = line.new(bar_index - 1, f_get_ma_value(ma_line4), bar_index, f_get_ma_value(ma_line4), 
     extend=extend.both, color=#f7070780, style=line.style_dashed, width=3)

if barstate.islast
    line.set_xy1(hline1, bar_index[1], f_get_ma_value(ma_line1))
    line.set_xy2(hline1, bar_index, f_get_ma_value(ma_line1))
    line.set_xy1(hline2, bar_index[1], f_get_ma_value(ma_line2))
    line.set_xy2(hline2, bar_index, f_get_ma_value(ma_line2))
    line.set_xy1(hline3, bar_index[1], f_get_ma_value(ma_line3))
    line.set_xy2(hline3, bar_index, f_get_ma_value(ma_line3))
    line.set_xy1(hline4, bar_index[1], f_get_ma_value(ma_line4))
    line.set_xy2(hline4, bar_index, f_get_ma_value(ma_line4))

// ── Plot MA Lines with Gradient Colors ──
plot(ma1,  "MA1",  color=color.rgb(255, 0, 0),   linewidth=2)
plot(ma2,  "MA2",  color=color.rgb(255, 128, 0), linewidth=2)
plot(ma3,  "MA3",  color=color.rgb(255, 255, 0), linewidth=2)
plot(ma4,  "MA4",  color=color.rgb(128, 255, 0), linewidth=2)
plot(ma5,  "MA5",  color=color.rgb(0, 255, 0),   linewidth=2)
plot(ma6,  "MA6",  color=color.rgb(0, 255, 128), linewidth=2)
plot(ma7,  "MA7",  color=color.rgb(0, 255, 255), linewidth=2)
plot(ma8,  "MA8",  color=color.rgb(0, 128, 255), linewidth=2)
plot(ma9,  "MA9",  color=color.rgb(0, 0, 255),   linewidth=3)
plot(ma10, "MA10", color=color.rgb(128, 0, 255), linewidth=3)
plot(ma11, "MA11", color=color.rgb(255, 0, 255), linewidth=3)
plot(ma12, "MA12", color=color.rgb(255, 0, 128), linewidth=3)
plot(ma13, "MA13", color=color.rgb(128, 128, 128), linewidth=4)
plot(ma14, "MA14", color=color.rgb(64, 64, 64),   linewidth=4)

// ── Information Table ──
var table info = table.new(position.top_right, 5, 15, border_width=1)

f_update_table() =>
    if show_table
        // Table Header
        table.cell(info, 0, 0, "MA",        bgcolor=color.gray, text_color=color.white)
        table.cell(info, 1, 0, "Length",    bgcolor=color.gray, text_color=color.white)
        table.cell(info, 2, 0, "MA Value",  bgcolor=color.gray, text_color=color.white)
        table.cell(info, 3, 0, "Distance",  bgcolor=color.gray, text_color=color.white)
        table.cell(info, 4, 0, "% Diff",    bgcolor=color.gray, text_color=color.white)

        // MA1
        table.cell(info, 0, 1, "MA1",  bgcolor=color.rgb(255, 0, 0),   text_color=color.white)
        table.cell(info, 1, 1, str.tostring(len1), bgcolor=color.white)
        table.cell(info, 2, 1, str.tostring(ma1,  num_format), bgcolor=color.white)
        table.cell(info, 3, 1, str.tostring(dist1, num_format), bgcolor=color.white)
        table.cell(info, 4, 1, str.tostring(pct1, num_format) + "%", bgcolor=color.white)

        // MA2
        table.cell(info, 0, 2, "MA2",  bgcolor=color.rgb(255, 128, 0), text_color=color.white)
        table.cell(info, 1, 2, str.tostring(len2), bgcolor=color.white)
        table.cell(info, 2, 2, str.tostring(ma2,  num_format), bgcolor=color.white)
        table.cell(info, 3, 2, str.tostring(dist2, num_format), bgcolor=color.white)
        table.cell(info, 4, 2, str.tostring(pct2, num_format) + "%", bgcolor=color.white)

        // MA3
        table.cell(info, 0, 3, "MA3",  bgcolor=color.rgb(255, 255, 0), text_color=color.black)
        table.cell(info, 1, 3, str.tostring(len3), bgcolor=color.white)
        table.cell(info, 2, 3, str.tostring(ma3,  num_format), bgcolor=color.white)
        table.cell(info, 3, 3, str.tostring(dist3, num_format), bgcolor=color.white)
        table.cell(info, 4, 3, str.tostring(pct3, num_format) + "%", bgcolor=color.white)

        // MA4
        table.cell(info, 0, 4, "MA4",  bgcolor=color.rgb(128, 255, 0), text_color=color.black)
        table.cell(info, 1, 4, str.tostring(len4), bgcolor=color.white)
        table.cell(info, 2, 4, str.tostring(ma4,  num_format), bgcolor=color.white)
        table.cell(info, 3, 4, str.tostring(dist4, num_format), bgcolor=color.white)
        table.cell(info, 4, 4, str.tostring(pct4, num_format) + "%", bgcolor=color.white)

        // MA5
        table.cell(info, 0, 5, "MA5",  bgcolor=color.rgb(0, 255, 0), text_color=color.black)
        table.cell(info, 1, 5, str.tostring(len5), bgcolor=color.white)
        table.cell(info, 2, 5, str.tostring(ma5,  num_format), bgcolor=color.white)
        table.cell(info, 3, 5, str.tostring(dist5, num_format), bgcolor=color.white)
        table.cell(info, 4, 5, str.tostring(pct5, num_format) + "%", bgcolor=color.white)

        // MA6
        table.cell(info, 0, 6, "MA6",  bgcolor=color.rgb(0, 255, 128), text_color=color.black)
        table.cell(info, 1, 6, str.tostring(len6), bgcolor=color.white)
        table.cell(info, 2, 6, str.tostring(ma6,  num_format), bgcolor=color.white)
        table.cell(info, 3, 6, str.tostring(dist6, num_format), bgcolor=color.white)
        table.cell(info, 4, 6, str.tostring(pct6, num_format) + "%", bgcolor=color.white)

        // MA7
        table.cell(info, 0, 7, "MA7",  bgcolor=color.rgb(0, 255, 255), text_color=color.black)
        table.cell(info, 1, 7, str.tostring(len7), bgcolor=color.white)
        table.cell(info, 2, 7, str.tostring(ma7,  num_format), bgcolor=color.white)
        table.cell(info, 3, 7, str.tostring(dist7, num_format), bgcolor=color.white)
        table.cell(info, 4, 7, str.tostring(pct7, num_format) + "%", bgcolor=color.white)

        // MA8
        table.cell(info, 0, 8, "MA8",  bgcolor=color.rgb(0, 128, 255), text_color=color.white)
        table.cell(info, 1, 8, str.tostring(len8), bgcolor=color.white)
        table.cell(info, 2, 8, str.tostring(ma8,  num_format), bgcolor=color.white)
        table.cell(info, 3, 8, str.tostring(dist8, num_format), bgcolor=color.white)
        table.cell(info, 4, 8, str.tostring(pct8, num_format) + "%", bgcolor=color.white)

        // MA9
        table.cell(info, 0, 9, "MA9",  bgcolor=color.rgb(0, 0, 255), text_color=color.white)
        table.cell(info, 1, 9, str.tostring(len9), bgcolor=color.white)
        table.cell(info, 2, 9, str.tostring(ma9,  num_format), bgcolor=color.white)
        table.cell(info, 3, 9, str.tostring(dist9, num_format), bgcolor=color.white)
        table.cell(info, 4, 9, str.tostring(pct9, num_format) + "%", bgcolor=color.white)

        // MA10
        table.cell(info, 0, 10, "MA10", bgcolor=color.rgb(128, 0, 255), text_color=color.white)
        table.cell(info, 1, 10, str.tostring(len10), bgcolor=color.white)
        table.cell(info, 2, 10, str.tostring(ma10, num_format), bgcolor=color.white)
        table.cell(info, 3, 10, str.tostring(dist10, num_format), bgcolor=color.white)
        table.cell(info, 4, 10, str.tostring(pct10, num_format) + "%", bgcolor=color.white)

        // MA11
        table.cell(info, 0, 11, "MA11", bgcolor=color.rgb(255, 0, 255), text_color=color.white)
        table.cell(info, 1, 11, str.tostring(len11), bgcolor=color.white)
        table.cell(info, 2, 11, str.tostring(ma11, num_format), bgcolor=color.white)
        table.cell(info, 3, 11, str.tostring(dist11, num_format), bgcolor=color.white)
        table.cell(info, 4, 11, str.tostring(pct11, num_format) + "%", bgcolor=color.white)

        // MA12
        table.cell(info, 0, 12, "MA12", bgcolor=color.rgb(255, 0, 128), text_color=color.white)
        table.cell(info, 1, 12, str.tostring(len12), bgcolor=color.white)
        table.cell(info, 2, 12, str.tostring(ma12, num_format), bgcolor=color.white)
        table.cell(info, 3, 12, str.tostring(dist12, num_format), bgcolor=color.white)
        table.cell(info, 4, 12, str.tostring(pct12, num_format) + "%", bgcolor=color.white)

        // MA13
        table.cell(info, 0, 13, "MA13", bgcolor=color.rgb(128, 128, 128), text_color=color.white)
        table.cell(info, 1, 13, str.tostring(len13), bgcolor=color.white)
        table.cell(info, 2, 13, str.tostring(ma13, num_format), bgcolor=color.white)
        table.cell(info, 3, 13, str.tostring(dist13, num_format), bgcolor=color.white)
        table.cell(info, 4, 13, str.tostring(pct13, num_format) + "%", bgcolor=color.white)

        // MA14
        table.cell(info, 0, 14, "MA14", bgcolor=color.rgb(64, 64, 64), text_color=color.white)
        table.cell(info, 1, 14, str.tostring(len14), bgcolor=color.white)
        table.cell(info, 2, 14, str.tostring(ma14, num_format), bgcolor=color.white)
        table.cell(info, 3, 14, str.tostring(dist14, num_format), bgcolor=color.white)
        table.cell(info, 4, 14, str.tostring(pct14, num_format) + "%", bgcolor=color.white)

    else
        table.clear(info, 0, 4, 0, 14)

f_update_table()

// ── DCA Settings ──
dca_amount = input.float(10, "DCA Amount per Bar", minval=0, group="DCA Settings")
start_date = input.time(timestamp("2023-01-01 00:00 +0000"), "DCA Start Date", group="DCA Settings")
show_dca_line = input.bool(true, "Show DCA Line", group="DCA Settings")

var float total_invested = 0.0
var line dca_line = na

if time >= start_date
    total_invested += dca_amount
    if na(dca_line)
        dca_line := line.new(bar_index - 1, total_invested, bar_index, total_invested, 
             extend=extend.both, color=color.new(color.orange, 50), style=line.style_solid, width=2)
    else
        line.set_xy1(dca_line, bar_index[1], total_invested)
        line.set_xy2(dca_line, bar_index, total_invested)

if not show_dca_line and not na(dca_line)
    line.delete(dca_line)
    dca_line := na
else if show_dca_line and na(dca_line) and time >= start_date
    dca_line := line.new(bar_index - 1, total_invested, bar_index, total_invested, 
         extend=extend.both, color=color.new(color.orange, 50), style=line.style_solid, width=2)
````
