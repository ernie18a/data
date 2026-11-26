# Currency Strength Session & TF Breakout [Silver Bulletx]

- url: https://www.tradingview.com/script/Y4ldFr2Z-Currency-Strength-Session-TF-Breakout-Silver-Bulletx/
- type: indicator
- pine_id: PUB;970a8e5b7875410e83dbe030c9b3bc90
- version: 1.0

## Description

Currency Strength Session & TF Breakout [Silver Bulletx]

Currency Strength Session & TF Breakout is a specialized EURUSD and USDJPY currency strength indicator designed to compare the relative strength of the currencies behind the pair.

The indicator analyzes EUR, USD, and JPY strength using price movement, EMA-based Bull Power / Bear Power, ATR normalization, and directional weighting.

It provides two analysis modes:

Trailing Relative Strength
Relative Strength Scatter Graph
IMPORTANT — Supported Pairs

This indicator ONLY works on:

EURUSD
USDJPY

It will not run on other chart symbols.

Although EURJPY is used internally as part of the currency-strength calculation, the indicator itself is designed specifically for EURUSD and USDJPY charts.

How It Works

The indicator breaks the selected pair into its individual currencies and calculates their relative strength.

For the calculations, it uses:

EURUSD
USDJPY
EURJPY

These three currency pairs allow the indicator to derive relative strength for EUR, USD, and JPY.

Asymmetric Bull & Bear Power

Instead of treating bullish and bearish movement identically, the indicator measures how far the candle's high and low extend from an EMA.

Bull Power measures upside reach above the EMA.

Bear Power measures downside reach below the EMA.

Both are normalized using ATR, allowing the strength calculation to adapt to current market volatility.

The resulting movement is then given additional weighting when bullish or bearish pressure becomes stronger.

This creates an asymmetric currency-strength model designed to emphasize stronger directional expansion.

Timeframe Engine

Choose from:

5 Minutes
15 Minutes
30 Minutes
1 Hour
4 Hours
Daily
Session Mode

The selected timeframe determines how the strength calculation is accumulated and reset.

Session Mode

The Session Mode is designed to track currency strength separately around major intraday market sessions.

It recognizes:

Asian Session
London Session
New York Session

Session Mode resets the strength calculation when a new tracked session begins.

This can be useful when analyzing session momentum, London breakout, New York momentum, Asian range behavior, and changes in currency strength between sessions.

Strength Meter

The built-in Currency Strength Meter displays the relative strength of the two currencies on the current chart.

For example:

EURUSD → EUR vs USD

USDJPY → USD vs JPY

The meter dynamically scales the displayed strength values so the relationship between the two currencies can be viewed quickly.

Relative Strength Scatter Graph

The optional Relative Strength Scatter Graph provides another way to visualize currency strength.

It categorizes the current relationship into areas representing:

Strong
Improving
Weakening
Weak

It also compares current strength with previous strength to show whether currency momentum is improving or deteriorating.

What It Can Help Analyze

This indicator is designed for traders analyzing:

EURUSD currency strength
USDJPY currency strength
EUR vs USD strength
USD vs JPY strength
Forex market bias
Currency momentum
Relative strength
Session strength
London session
New York session
Asian session
Forex breakouts
Trend continuation
Momentum shifts
Bullish and bearish pressure
ATR-normalized strength
Intraday Forex trading
Best Use

The indicator is specifically built for EURUSD and USDJPY Forex analysis.

It can be particularly useful when trying to determine which currency is currently showing greater directional strength rather than looking at the pair alone.

For example, on EURUSD:

Strong EUR + Weak USD → bullish EURUSD conditions

Weak EUR + Strong USD → bearish EURUSD conditions

On USDJPY:

Strong USD + Weak JPY → bullish USDJPY conditions

Weak USD + Strong JPY → bearish USDJPY conditions

These relationships should be treated as market context, not guaranteed trading signals.

Key Features
EURUSD-only / USDJPY-only design
Currency strength analysis
EUR, USD and JPY strength engine
ATR-normalized Bull Power / Bear Power
Asymmetric bullish/bearish weighting
Session-based strength tracking
5m, 15m, 30m, 1H, 4H and Daily engines
Asian, London and New York session mode
Currency strength meter
Relative strength scatter graph
Momentum and strength-change visualization

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// Copyright Silver Bulletx Branding (Modified to v6 with Asymmetric Bull/Bear BBP Weighting)

//@version=6
indicator("Currency Strength Session & TF Breakout [Silver Bulletx]", overlay=false)

//------------------------------------------------------------------------------
// Settings
//-----------------------------------------------------------------------------{
display      = input.string('Trailing Relative Strength', title='Mode', options = ['Trailing Relative Strength', 'Relative Strength Scatter Graph'])
freq         = input.string('60', 'Timeframe Engine Selection', 
               options = ['5', '15', '30', '60', '240', 'D', 'Session Mode'],
               tooltip = "Select standard tracking timeframes OR select 'Session Mode' to auto-reset and plot separately on each distinct intraday market session opening.")

bbp_len      = input.int(10, 'BBP EMA Length', minval = 1, group = 'BBP Asymmetric Engine')
weight_mult  = input.float(1.5, 'BBP Impact Multiplier', minval = 0.1, step = 0.1, group = 'BBP Asymmetric Engine', tooltip = "Scales the extra expansion given to Bull (Base) and Bear (Quote) power.")

USD_css      = input.color(#ff1100, 'USD Color', inline = 'USD')
EUR_css      = input.color(#2157f3, 'EUR Color', inline = 'EUR')
JPY_css      = input.color(#e91e63, 'JPY Color', inline = 'JPY')

// Meter
showDash     = input.bool(true, 'Show Strength Meter', group = 'Meter')
resolution   = input.int(20, 'Strength Meter Resolution', group = 'Meter')
dashLoc      = input.string('Top Right', 'Location', options = ['Top Right', 'Bottom Right', 'Bottom Left'], group = 'Meter')
textSize     = input.string('Small', 'Size', options = ['Tiny', 'Small', 'Normal'], group = 'Meter')

// Scatter Graph
scatterRes        = input.int(20, 'Scatter Graph Resolution', maxval = 500, group = 'Scatter Graph')
scatterStrong     = input.color(color.new(color.green, 80), 'Strong', group = 'Scatter Graph')
scatterImprove    = input.color(color.new(color.aqua, 80), 'Improving', group = 'Scatter Graph')
scatterWeakening  = input.color(color.new(color.yellow, 80), 'Weakening', group = 'Scatter Graph')
scatterWeak       = input.color(color.new(color.red, 80), 'Weak', group = 'Scatter Graph')  
//-----------------------------------------------------------------------------}

// Chart Validation
//-----------------------------------------------------------------------------{
is_EU = syminfo.basecurrency == "EUR" and syminfo.currency == "USD"
is_UJ = syminfo.basecurrency == "USD" and syminfo.currency == "JPY"

if not is_EU and not is_UJ
    runtime.error("This customized indicator ONLY works on EURUSD or USDJPY.")
//-----------------------------------------------------------------------------}

// Global Variables
//-----------------------------------------------------------------------------{
n = bar_index

var label lbl_curr1 = label.new(x=na, y=na, text='.', color=#00000000, style=label.style_label_center, size=size.large)
var label lbl_curr2 = label.new(x=na, y=na, text='.', color=#00000000, style=label.style_label_center, size=size.large)
//-----------------------------------------------------------------------------}

// Asymmetric Bull/Bear BBP Calculation Function
//-----------------------------------------------------------------------------{
f_get_asymmetric_bbp_changes(sym, len, mult) =>
    [o, h, l, c, ema_val, atr_val] = request.security(sym, timeframe.period, [open, high, low, close, ta.ema(close, len), ta.atr(14)])
    
    // Percentage return of current bar
    raw_chg = (c - o) / o * 100
    
    // Calculate Bull Power (Buyer Reach) & Bear Power (Seller Push)
    bull_power = math.max(0.0, h - ema_val)
    bear_power = math.max(0.0, ema_val - l)
    
    // Normalize against ATR
    bull_ratio = atr_val == 0 ? 0.0 : (bull_power / atr_val)
    bear_ratio = atr_val == 0 ? 0.0 : (bear_power / atr_val)
    
    // Soft Floor Weights (Base=1.0 during choppy ranges)
    base_weight  = 1.0 + (bull_ratio * mult)
    quote_weight = 1.0 + (bear_ratio * mult)
    
    // Compute directional weighted changes for Base (+) and Quote (-) currencies
    base_chg  = raw_chg >= 0 ? (raw_chg * base_weight) : raw_chg
    quote_chg = raw_chg <= 0 ? (raw_chg * quote_weight) : raw_chg
    
    [base_chg, quote_chg]

set_meter(tb, col, strength, min_val, max_val, bg_css)=>
    scale = (max_val - min_val) == 0 ? 0 : (strength - min_val) / (max_val - min_val) * (resolution-1)
    
    table.clear(tb, col, 2, col, resolution+1)
    int loop_max = int(scale)
    if loop_max >= 0
        for i = 0 to loop_max
            css = color.from_gradient(i, 0, loop_max <= 0 ? 1 : loop_max, color.new(bg_css, 100), bg_css)
            table.cell(table_id=tb, column=col, row=resolution+1 - i, text="", bgcolor=css, text_size=size.tiny, height=0.1)
    
    table.cell(table_id=tb, column=col, row=1, text=str.format('{0}{1,number,#.##}', strength > 0 ? '+' : '', strength)
      , bgcolor=bg_css
      , text_size=size.tiny
      , text_color=color.white
      , width=2)
//-----------------------------------------------------------------------------}

// Session Engine
//-----------------------------------------------------------------------------{
in_asian  = not na(time(timeframe.period, "0000-0900:23456", "UTC"))
in_london = not na(time(timeframe.period, "0800-1700:23456", "UTC"))
in_ny     = not na(time(timeframe.period, "1300-2200:23456", "UTC"))

asian_start  = in_asian and not in_asian[1]
london_start = in_london and not in_london[1]
ny_start     = in_ny and not in_ny[1]

bool is_session_mode = (freq == 'Session Mode')
bool dt = false

if is_session_mode
    dt := asian_start or london_start or ny_start
else
    dt := timeframe.change(freq)
//-----------------------------------------------------------------------------}

// Asymmetric Currency Calculation Execution
//-----------------------------------------------------------------------------{
[eu_base_chg, eu_quote_chg] = f_get_asymmetric_bbp_changes("EURUSD", bbp_len, weight_mult)
[uj_base_chg, uj_quote_chg] = f_get_asymmetric_bbp_changes("USDJPY", bbp_len, weight_mult)
[ej_base_chg, ej_quote_chg] = f_get_asymmetric_bbp_changes("EURJPY", bbp_len, weight_mult)

var float sum_usd = 0.
var float prev_usd = 0.
var float sum_eur = 0.
var float prev_eur = 0.
var float sum_jpy = 0.
var float prev_jpy = 0.

bool active_calc = not is_session_mode or (in_asian or in_london or in_ny)

if active_calc
    if dt
        prev_usd := sum_usd
        prev_eur := sum_eur
        prev_jpy := sum_jpy

        sum_usd := math.avg(-eu_quote_chg, uj_base_chg)
        sum_eur := math.avg(eu_base_chg, ej_base_chg)
        sum_jpy := math.avg(-uj_quote_chg, -ej_quote_chg)
    else
        sum_usd += math.avg(-eu_quote_chg, uj_base_chg)
        sum_eur += math.avg(eu_base_chg, ej_base_chg)
        sum_jpy += math.avg(-uj_quote_chg, -ej_quote_chg)
else
    sum_usd := na
    sum_eur := na
    sum_jpy := na

curr1_name  = is_EU ? "EUR" : "USD"
curr2_name  = is_EU ? "USD" : "JPY"
curr1_css   = is_EU ? EUR_css : USD_css
curr2_css   = is_EU ? USD_css : JPY_css
curr1_val   = is_EU ? sum_eur : sum_usd
curr2_val   = is_EU ? sum_usd : sum_jpy
curr1_prev  = is_EU ? prev_eur : prev_usd
curr2_prev  = is_EU ? prev_usd : prev_jpy
//-----------------------------------------------------------------------------}

// UI Components: Strength Meter Table
//-----------------------------------------------------------------------------{
var table_position = dashLoc == 'Bottom Left' ? position.bottom_left : dashLoc == 'Top Right' ? position.top_right : position.bottom_right
var table_size     = textSize == 'Tiny' ? size.tiny : textSize == 'Small' ? size.small : size.normal

var tb = table.new(position=table_position, columns=5, rows=resolution+3, bgcolor=#1e222d, border_width=1, frame_color=#373a46, frame_width=1)

if barstate.isfirst and showDash
    table.cell(table_id=tb, column=0, row=0, text=str.format('Strength ({0})', freq), text_size=table_size, text_color=color.white)
    table.merge_cells(table_id=tb, start_column=0, start_row=0, end_column=4, end_row=0)

    for i = 0 to 4 by 2
        table.cell(table_id=tb, column=i, row=1, bgcolor=#1e222d, width=0.1)
        table.merge_cells(table_id=tb, start_column=i, start_row=1, end_column=i, end_row=resolution+2)

    table.cell(table_id=tb, column=1, row=resolution+2, text=curr1_name, text_color=color.white, text_size=table_size, bgcolor=curr1_css)
    table.cell(table_id=tb, column=3, row=resolution+2, text=curr2_name, text_color=color.white, text_size=table_size, bgcolor=curr2_css)

if barstate.islast and showDash and not na(curr1_val) and not na(curr2_val)
    min_val = math.min(curr1_val, curr2_val)
    max_val = math.max(curr1_val, curr2_val)
    
    set_meter(tb, 1, curr1_val, min_val, max_val, curr1_css)
    set_meter(tb, 3, curr2_val, min_val, max_val, curr2_css)
//-----------------------------------------------------------------------------}

// UI Components: Scatter Plot
//-----------------------------------------------------------------------------{
var bx_strong    = box.new(left=na, top=na, right=na, bottom=na, border_color=na, bgcolor=scatterStrong)
var bx_improve   = box.new(left=na, top=na, right=na, bottom=na, border_color=na, bgcolor=scatterImprove)
var bx_weakening = box.new(left=na, top=na, right=na, bottom=na, border_color=na, bgcolor=scatterWeakening)
var bx_weak      = box.new(left=na, top=na, right=na, bottom=na, border_color=na, bgcolor=scatterWeak)

var label x_label = label.new(x=na, y=na, text='Prev Strength', style=label.style_label_up, color=#00000000, textcolor=chart.fg_color)
var label y_label = label.new(x=na, y=0.0, text='Strength', style=label.style_label_right, color=#00000000, textcolor=chart.fg_color)

if display == 'Relative Strength Scatter Graph' and not na(curr1_val) and not na(curr2_val)
    min_val = math.min(curr1_val, curr2_val)
    max_val = math.max(curr1_val, curr2_val)

    prev_min = math.min(curr1_val - curr1_prev, curr2_val - curr2_prev)
    prev_max = math.max(curr1_val - curr1_prev, curr2_val - curr2_prev)
    
    if barstate.islast
        box.set_lefttop(bx_strong, n + int(scatterRes / 2), max_val)
        box.set_rightbottom(bx_strong, n + scatterRes, 0.0)
        
        box.set_lefttop(bx_improve, n, max_val)
        box.set_rightbottom(bx_improve, n + int(scatterRes / 2), 0.0)
        
        box.set_lefttop(bx_weakening, n + int(scatterRes / 2), 0.0)
        box.set_rightbottom(bx_weakening, n + scatterRes, min_val)
        
        box.set_lefttop(bx_weak, n, 0.0)
        box.set_rightbottom(bx_weak, n + int(scatterRes / 2), min_val)
        
        label.set_xy(x_label, n + int(scatterRes / 2), min_val)
        label.set_x(y_label, n)
        
        scale_prev1 = (prev_max - prev_min) == 0 ? 0 : (curr1_val - curr1_prev - prev_min) / (prev_max - prev_min)
        label.set_x(lbl_curr1, n + int(scale_prev1 * scatterRes))
        label.set_y(lbl_curr1, curr1_val)
        label.set_textcolor(lbl_curr1, curr1_css)
        
        scale_prev2 = (prev_max - prev_min) == 0 ? 0 : (curr2_val - curr2_prev - prev_min) / (prev_max - prev_min)
        label.set_x(lbl_curr2, n + int(scale_prev2 * scatterRes))
        label.set_y(lbl_curr2, curr2_val)
        label.set_textcolor(lbl_curr2, curr2_css)
//-----------------------------------------------------------------------------}

// Visual Line Plots
//-----------------------------------------------------------------------------{
color plot_c1 = display == 'Trailing Relative Strength' ? (dt ? color.new(curr1_css, 100) : curr1_css) : color.new(curr1_css, 100)
color plot_c2 = display == 'Trailing Relative Strength' ? (dt ? color.new(curr2_css, 100) : curr2_css) : color.new(curr2_css, 100)

plot(curr1_val, color=plot_c1, linewidth=2, title="Currency 1 Line", style=plot.style_line)
plot(curr2_val, color=plot_c2, linewidth=2, title="Currency 2 Line", style=plot.style_line)

color bg_band = (display == 'Trailing Relative Strength' and dt) ? color.new(color.gray, 90) : color.new(color.gray, 100)
bgcolor(bg_band) 
//-----------------------------------------------------------------------------}
````
