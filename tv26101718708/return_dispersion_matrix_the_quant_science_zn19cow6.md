# Return Dispersion Matrix [The Quant Science]

- url: https://www.tradingview.com/script/ZN19COW6-Return-Dispersion-Matrix-The-Quant-Science/
- type: indicator
- pine_id: PUB;810305f140894c5292146f7d018ad5cb
- version: 1.0

## Description

[b]Introduction[/b]
The Return Dispersion Matrix is a quantitative analysis tool that maps the temporal dependence of returns. In technical terms, performs a two-dimensional, 1-lag autocorrelation analysis, measuring the relationship and relative frequency between the return of the previous session [b](Yesterday)[/b] and that of the current session [b](Today)[/b] within specific volatility ranges.

[b]It answers the key questions:[/b]
💭 🔑 “When a candle closes in the green or red, what is the most common range of returns?”
💭 🔑  “When the price did X yesterday, what does it probably do today?”

[b]What does this indicator do?[/b]
[b]1. Automatically calculate the probability of future returns[/b] for a given range of values and display the result in the right-hand column.
[image]https://www.tradingview.com/x/RNu8LGOv/[/image]

[b]2. Instantly identify the market trend using the quadrants.[/b] Calculates the quadrant with the highest number of points and highlights it by lighting it up.
[image]https://www.tradingview.com/x/TRYojxQx/[/image]

🟢 [b]Q1[/b]
[list]
[*]A green candle followed by another green candle
[*]High concentration of points indicates that positive days tend to generate immediate additional momentum
[*]Suitable for trend-following and bullish breakout strategies
[/list]
[image]https://www.tradingview.com/x/EfZSsTIX/[/image]

🟢 [b]Q2[/b]
[list]
[*]A red candle followed by a green candle
[*]Heavy trading volume indicates a “resilient” market: buyers step in immediately when prices fall (“buy the dip”)
[*]Suitable for accumulation strategies on pullbacks
[/list]
[image]https://www.tradingview.com/x/HgU03790/[/image]

🔴 [b]Q3[/b]
[list]
[*]A red candle followed by another red candle
[*]Indicates that sales generate further sales without immediate support
[*]Sign of underlying weakness or persistent downtrends
[/list]
[image]https://www.tradingview.com/x/Y8jgLm29/[/image]

🔴 [b]Q4[/b]
[list]
[*]A green candle followed by a red candle
[*]There are many indications that rallies are short-lived and lead to rapid profit-taking in the Suitable for “sell the rally” strategies
[/list]
[image]https://www.tradingview.com/x/Pp838pDo/[/image]

The horizontal X-axis represents the return of the previous candle (t-1), while the vertical Y-axis shows the return of the current candle (t). This allows you to visually determine whether a positive or negative day tends to be followed by one of the same sign (persistence) or the opposite sign (mean reversion).
[image]https://www.tradingview.com/x/yhYCiQUA/[/image]
[b]X-axis[/b]
[list]
[*][b]To the right of 0: [/b]previous candle closed in positive territory (+)
[*][b]To the left of 0:[/b] previous candle closed in negative territory (-)
[/list]
[b]Y-axis[/b]
[list]
[*][b]Above 0:[/b] current candle is closing / has closed in positive territory (+)
[*][b]Below 0:[/b] current candle is closing / has closed in negative territory (-)
[/list]

[b]3. Automatically calculates volatility bands.[/b] It identifies the maximum range observed during the analysis period and divides the positive values into bands. These values are displayed in the left column in white.
[image]https://www.tradingview.com/x/ntz9WoCX/[/image]

[b]4. Automatically calculates frequency clusters.[/b] The density and transparency of the points immediately reveal where most sessions are concentrated and which events represent anomalies or extreme outliers.
[image]https://www.tradingview.com/x/dcPVNFtL/[/image]

[b]Uses[/b]
[b]Identifying the Market Regime[/b]
Observing the concentration of points reveals the prevailing nature of the asset:
[list]
[*][b]Q1 / Q3 Prevalence (Trend / Inertia): [/b]The market tends toward continuation. The best strategy is to buy on breakouts or sell on support breaks.
[*][b]Prevalence of Q2 / Q4 (Mean Reversion):[/b] Buying at highs is statistically a losing strategy.
[/list] 

[b]Assessment of Asymmetry and Risk Management (Fat Tails)[/b]
By comparing the vertical extent of the points on the positive and negative sides:
If, on the negative side (Q3 / Q4), the points frequently reach the extreme ranges (e.g., -L4 or -L5), while on the positive side they stop at +L2, the asset exhibits asymmetric downside volatility (crash risk). [b]Essential for the correct calculation of position sizing and for the strategic placement of stop-loss orders.[/b]

[b]Operational Execution Filter (Probabilistic Edge)[/b]
The tool acts as a statistical validator before entering the market:
[b]Example: [/b]A trader wants to go long on an asset. The matrix shows that, under current conditions, Quadrant Q2 has a frequency of 45% (high probability that a red day will be followed by a green day). [b]Instead of buying during the positive candle, the trader waits for a negative session to close before placing a buy order at the next opening, thereby maximizing expected return.[/b]

[b]Settings[/b]
Traders can easily adjust the indicator's parameters using the user interface.
[list=1]
[*][b]Data Points Visualization: [/b]adjust the number of points within the matrix
[*][b]Matrix Offset:[/b] move the table to the right on the graph
[*][b]Levels Color:[/b] set the indicator colors 
[*][b]Highlight Dominant Quadrant:[/b] apply automatic calculation of the winning quadrant
[/list]
[image]https://www.tradingview.com/x/bmfPl7oy/[/image]

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International  
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © The Quant Science

//@version=6
indicator('Return Dispersion Matrix [The Quant Science]', overlay = true, max_labels_count = 500)

int data_points_visualization = input.int(50, 'Data Points Visualization', minval = 5, maxval = 450, group = 'Settings')
int matrix_offset = input.int(100, 'Matrix Offset', minval = 10, maxval = 250, group = 'Settings')
color color_up = input.color(color.lime, 'Positive Levels Color', group = 'Colors', inline = 'col')
color color_down = input.color(color.red, 'Negative Levels Color', group = 'Colors', inline = 'col')
bool show_quadrants = input.bool(true, 'Highlight Dominant Quadrant', group = 'Quadrant Settings')

float current_returns = (close - close[1]) / close[1] * 100.0
float previous_returns = (close[1] - close[2]) / close[2] * 100.0

var float[] returns_x = array.new<float>(0)
var float[] returns_y = array.new<float>(0)

returns_x.push(previous_returns)
returns_y.push(current_returns)

if returns_x.size() > data_points_visualization
    array.shift(returns_x)
    array.shift(returns_y)

var box[] matrix_boxes    = array.new<box>()
var line[] matrix_lines   = array.new<line>()
var label[] matrix_dots   = array.new<label>()
var label[] matrix_labels = array.new<label>()
var label[] pct_labels    = array.new<label>()

clean_drawings() =>
    while matrix_boxes.size() > 0
        box.delete(matrix_boxes.pop())
    while matrix_lines.size() > 0
        line.delete(matrix_lines.pop())
    while matrix_dots.size() > 0
        label.delete(matrix_dots.pop())
    while matrix_labels.size() > 0
        label.delete(matrix_labels.pop())
    while pct_labels.size() > 0
        label.delete(pct_labels.pop())

CreateMatrixLevels(float limit, int base_idx, float anchor_price, box[] boxes_arr, line[] lines_arr, label[] labels_arr) =>
    float step_val = limit / 5.0
    float price_step = anchor_price * (step_val / 100.0)

    for i = 1 to 5
        float p_bot_p = anchor_price + ((i - 1) * price_step)
        float p_top_p = anchor_price + (i * price_step)
        float n_top_p = anchor_price - ((i - 1) * price_step)
        float n_bot_p = anchor_price - (i * price_step)

        int alpha_bg = 99 - (i * 4) 
        color box_color_up = color.new(color_up, alpha_bg)
        color box_color_down = color.new(color_down, alpha_bg)

        boxes_arr.push(box.new(base_idx, p_top_p, base_idx + 200, p_bot_p, bgcolor = box_color_up, border_color = color(na)))
        boxes_arr.push(box.new(base_idx, n_top_p, base_idx + 200, n_bot_p, bgcolor = box_color_down, border_color = color(na)))

        float y_pos_pos = anchor_price + ((i - 0.5) * price_step)
        float y_pos_neg = anchor_price - ((i - 0.5) * price_step)

        chart.point pt_p = chart.point.from_index(base_idx - 3, y_pos_pos)
        chart.point pt_n = chart.point.from_index(base_idx - 3, y_pos_neg)
        
        float level_pct = (i - 0.5) * step_val
        
        string fmt_fixed = '#.##'
        string str_val_pos = '+' + str.tostring(level_pct, fmt_fixed) + '%'
        string str_val_neg = '-' + str.tostring(level_pct, fmt_fixed) + '%'

        labels_arr.push(label.new(pt_p, str_val_pos, style = label.style_label_right, color = color(na), textcolor = color.new(color.white, 40), size = size.small))
        labels_arr.push(label.new(pt_n, str_val_neg, style = label.style_label_right, color = color(na), textcolor = color.new(color.white, 40), size = size.small))

MatrixDistribution(float x, float y, int base_idx, float limit, float anchor_price, float max_d, label[] dots_arr) =>
    int X_pos = base_idx + 100 + math.round((x / limit) * 100)
    
    float price_step = anchor_price * ((limit / 5.0) / 100.0)
    float Y_pos = anchor_price + (y * (price_step / (limit / 5.0)))
    
    chart.point cp = chart.point.from_index(X_pos, Y_pos)
    
    color base_col = y >= 0 ? color_up : color_down
    float dist = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
    int trans = math.round((dist / max_d) * 75)
    color dot_color = color.new(base_col, math.max(10, trans))

    dots_arr.push(label.new(cp, '●', color = color(na), textcolor = dot_color, style = label.style_label_center, size = size.small))

if barstate.islast and returns_x.size() > 0

    clean_drawings()
    
    float max_x = array.max(returns_x)
    float min_x = array.min(returns_x)
    float max_y = array.max(returns_y)
    float min_y = array.min(returns_y)
    float max_range = math.max(1.0, math.abs(max_x), math.abs(min_x), math.abs(max_y), math.abs(min_y))
    float max_d = math.sqrt(2 * math.pow(max_range, 2))

    int base_idx = bar_index + matrix_offset
    int total_points = returns_y.size()
    float anchor_price = close
    
    int[] counts = array.new<int>(10, 0)
    float step_val = max_range / 5.0

    int count_q1 = 0
    int count_q2 = 0
    int count_q3 = 0
    int count_q4 = 0

    for i = 0 to total_points - 1
        float X = returns_x.get(i)
        float Y = returns_y.get(i)
        
        if X >= 0 and Y >= 0
            count_q1 += 1
        else if X < 0 and Y >= 0
            count_q2 += 1
        else if X < 0 and Y < 0
            count_q3 += 1
        else if X >= 0 and Y < 0
            count_q4 += 1

        int lvl = 0
        if Y >= 0
            int pos_lvl = math.min(4, math.floor(Y / step_val))
            lvl := 5 + pos_lvl
        else
            int neg_lvl = math.min(4, math.floor(math.abs(Y) / step_val))
            lvl := math.max(0, 4 - neg_lvl)

        counts.set(lvl, counts.get(lvl) + 1)
        MatrixDistribution(X, Y, base_idx, max_range, anchor_price, max_d, matrix_dots)

    CreateMatrixLevels(max_range, base_idx, anchor_price, matrix_boxes, matrix_lines, matrix_labels)

    if show_quadrants and total_points > 0

        int dominant_q = 1
        int max_val = count_q1

        if count_q2 > max_val
            max_val := count_q2
            dominant_q := 2
        if count_q3 > max_val
            max_val := count_q3
            dominant_q := 3
        if count_q4 > max_val
            max_val := count_q4
            dominant_q := 4

        float y_top = anchor_price + (anchor_price * (max_range / 100.0))
        float y_bot = anchor_price - (anchor_price * (max_range / 100.0))

        int alpha_q1 = dominant_q == 1 ? 70 : 100
        int alpha_q2 = dominant_q == 2 ? 70 : 100
        int alpha_q3 = dominant_q == 3 ? 70 : 100
        int alpha_q4 = dominant_q == 4 ? 70 : 100

        matrix_boxes.push(box.new(base_idx + 100, y_top, base_idx + 200, anchor_price, bgcolor = color.new(color_up, alpha_q1), border_color = color(na)))   // Q1
        matrix_boxes.push(box.new(base_idx, y_top, base_idx + 100, anchor_price, bgcolor = color.new(color_up, alpha_q2), border_color = color(na)))       // Q2
        matrix_boxes.push(box.new(base_idx, anchor_price, base_idx + 100, y_bot, bgcolor = color.new(color_down, alpha_q3), border_color = color(na)))     // Q3
        matrix_boxes.push(box.new(base_idx + 100, anchor_price, base_idx + 200, y_bot, bgcolor = color.new(color_down, alpha_q4), border_color = color(na))) // Q4

    matrix_lines.push(line.new(chart.point.from_index(base_idx, anchor_price), chart.point.from_index(base_idx + 200, anchor_price), color = color.new(color.white, 30), width = 1))
    matrix_lines.push(line.new(chart.point.from_index(base_idx + 100, anchor_price - (anchor_price * (max_range / 100.0))), chart.point.from_index(base_idx + 100, anchor_price + (anchor_price * (max_range / 100.0))), color = color.new(color.white, 30), width = 1))

    float price_step = anchor_price * (step_val / 100.0)

    for i = 0 to 9
        float pct = total_points > 0 ? (counts.get(i) / float(total_points)) * 100.0 : 0.0
        float y_pos = 0.0
        color theme_col = color_up
        string level_tag = ""

        if i >= 5 
            int pos_idx = i - 4
            y_pos := anchor_price + ((pos_idx - 0.5) * price_step)
            theme_col := color_up
            level_tag := "+L" + str.tostring(pos_idx)
        else 
            int neg_idx = 5 - i
            y_pos := anchor_price - ((neg_idx - 0.5) * price_step)
            theme_col := color_down
            level_tag := "-L" + str.tostring(neg_idx)

        color badge_bg = color.new(theme_col, math.max(20, 90 - math.round(pct * 2.0)))
        color text_col = pct > 15 ? color.white : theme_col

        string display_text = level_tag + "  |  " + str.tostring(pct, '#.1') + "%"
        chart.point lbl_pt = chart.point.from_index(base_idx + 208, y_pos)
        
        pct_labels.push(label.new(lbl_pt, display_text, style = label.style_label_left, color = badge_bg, textcolor = text_col, size = size.small))
````
