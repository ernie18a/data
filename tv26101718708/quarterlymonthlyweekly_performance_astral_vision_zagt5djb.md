# Quarterly/Monthly/Weekly Performance | Astral Vision 

- url: https://www.tradingview.com/script/ZagT5DJB/
- type: indicator
- pine_id: PUB;ffac8098e2c5486db6534fcd8e6bfc46
- version: 1.0

## Description

[b]Quarterly/Monthly/Weekly Performance | Astral Vision 🌠💠[/b]

Price performance measured over fixed trailing windows (7, 30, and 90 bars) captures the momentum of Bitcoin's move at three structurally distinct timescales simultaneously. 
Weekly performance reflects short-term trend pressure; monthly performance captures the medium-term cycle direction; quarterly performance reveals whether the broader macro trend is accumulating or distributing. Reading all three in a single panel eliminates the need to switch timeframes to understand where momentum stands across the full temporal structure.

This indicator plots trailing price performance as gradient-filled columns for each active window, with configurable overbought and oversold thresholds that identify statistically extreme moves. All three windows can be active simultaneously or independently, and each drives its own overlay on the price chart through candle coloring or background highlighting.

[b]Calculation ⚙️[/b]

`Performance = (close − close[N]) / close[N] × 100`

Where N is 7, 30, or 90 bars for weekly, monthly, and quarterly windows respectively. The result is a simple trailing percentage return expressed relative to the close N bars ago, with no smoothing applied — preserving the raw momentum read at each timescale.

[b]Plots 📊[/b]
[list]
[*]Performance columns for each active window (weekly, monthly, quarterly) with gradient fill, opaque at the column tip, fading toward zero
[*]Zero baseline
[*]Overbought and oversold threshold lines for each active window
[*]Background highlight on the price chart when any active window's performance breaches a threshold (Background Color mode)
[*]Candle coloring on the price chart by the sign of the active window's performance (Plot Candle mode)
[/list]

[b]Inputs 🎛️[/b]
[list]
[*]`Overlay Mode`: Background Color, Plot Candle, or None for price chart output
[*]`Show Weekly / Monthly / Quarterly`: independent toggles for each performance window
[*]`Weekly OB / OS Threshold`: extreme levels for the 7-bar window (defaults +20 / −15)
[*]`Monthly OB / OS Threshold`: extreme levels for the 30-bar window (defaults +35 / −20)
[*]`Quarterly OB / OS Threshold`: extreme levels for the 90-bar window (defaults +50 / −30)
[/list]

[b]Colors 🎨[/b]

5 Astral Vision presets + custom override. Default: Hermes. Positive color applies when performance is above zero; negative color applies when performance is below zero. Both the column fills and the price chart overlays follow the same coloring logic.

[b]Purpose 🎯[/b]

Standard momentum indicators process price through mathematical transformations (RSI, MACD, stochastic) that make their absolute values abstract and cycle-dependent. A trader looking for a direct answer to "how much has Bitcoin moved in the last month?" gets no clean output from any of those tools.

This indicator answers that question directly with no transformation, keeping the output in percentage terms that are immediately interpretable. 
The three-window structure lets traders read weekly, monthly, and quarterly momentum in a single panel, identifying divergences between timescales, such as a strong monthly trend with an overextended weekly reading, that single-window indicators cannot surface. 
The threshold system identifies when a given trailing return has reached historically extreme levels for that window, providing a contextual signal layer on top of the raw performance read.

[b]Disclaimer ⭕️[/b]

It is not financial advice, not an investment recommendation, and not affiliated with any financial institution, research firm, or organization of any kind. All content is provided for educational and informational purposes only. Always conduct your own research before making any financial decision.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AstralVision 

//@version=6
indicator("Quarterly/Monthly/Weekly Performance | Astral Vision 🌠💠", format=format.percent, precision=2)

string group1 = "Settings"
string group2 = "Astral Colors"
string gw     = "Weekly Thresholds"
string gm     = "Monthly Thresholds"
string gq     = "Quarterly Thresholds"

string overlay_mode = input.string("Background Color", "Overlay Mode",
     options=["Background Color", "Plot Candle", "None"], group=group1)
bool show_weekly    = input.bool(false, "Show Weekly",    group=group1)
bool show_monthly   = input.bool(true, "Show Monthly",   group=group1)
bool show_quarterly = input.bool(false,  "Show Quarterly", group=group1)

float thresh_ob_w = input.float(20.0,  "Weekly OB Threshold",    step=0.5, group=gw)
float thresh_os_w = input.float(-15.0, "Weekly OS Threshold",    step=0.5, group=gw)
float thresh_ob_m = input.float(35.0,  "Monthly OB Threshold",   step=1.0, group=gm)
float thresh_os_m = input.float(-20.0, "Monthly OS Threshold",   step=1.0, group=gm)
float thresh_ob_q = input.float(50.0,  "Quarterly OB Threshold", step=1.0, group=gq)
float thresh_os_q = input.float(-30.0, "Quarterly OS Threshold", step=1.0, group=gq)

string theme      = input.string("Hermes", "Theme", options=["Inferno","Paradiso","Futura","Infinito","Hermes"], group=group2)
bool   usecustom  = input.bool(false, "Use Custom Colors", group=group2)
color  custom_pos = input.color(color.white, "Custom Positive", group=group2)
color  custom_neg = input.color(color.gray,  "Custom Negative", group=group2)

color pos_col = usecustom ? custom_pos :
     theme == "Inferno"  ? color.rgb(255,0,0)    :
     theme == "Paradiso" ? color.rgb(0,210,255)   :
     theme == "Futura"   ? color.rgb(0,255,180)   :
     theme == "Infinito" ? color.rgb(180,120,255) :
     color.rgb(255,160,0)

color neg_col = usecustom ? custom_neg :
     theme == "Inferno"  ? color.rgb(120,0,0)   :
     theme == "Paradiso" ? color.rgb(0,80,160)   :
     theme == "Futura"   ? color.rgb(180,0,255)  :
     theme == "Infinito" ? color.rgb(255,220,80) :
     color.rgb(0,180,120)

float perf_w = close[7]  > 0 ? (close - close[7])  / close[7]  * 100 : na
float perf_m = close[30] > 0 ? (close - close[30]) / close[30] * 100 : na
float perf_q = close[90] > 0 ? (close - close[90]) / close[90] * 100 : na

color cw = perf_w >= 0 ? pos_col : neg_col
color cm = perf_m >= 0 ? pos_col : neg_col
color cq = perf_q >= 0 ? pos_col : neg_col

bool use_bg     = overlay_mode == "Background Color"
bool use_candle = overlay_mode == "Plot Candle"

p_q  = plot(show_quarterly ? perf_q : na, color=color.new(cq, 0), linewidth=1, style=plot.style_columns)
p_z1 = plot(0, display=display.none)
fill(p_q, p_z1,
     top_color    = perf_q >= 0 ? color.new(pos_col, 60) : color.new(neg_col, 60),
     bottom_color = perf_q >= 0 ? color.new(pos_col, 90) : color.new(neg_col, 90))

p_m  = plot(show_monthly ? perf_m : na, color=color.new(cm, 0), linewidth=1, style=plot.style_columns)
p_z2 = plot(0, display=display.none)
fill(p_m, p_z2,
     top_color    = perf_m >= 0 ? color.new(pos_col, 60) : color.new(neg_col, 60),
     bottom_color = perf_m >= 0 ? color.new(pos_col, 90) : color.new(neg_col, 90))

p_w  = plot(show_weekly ? perf_w : na, color=color.new(cw, 0), linewidth=1, style=plot.style_columns)
p_z3 = plot(0, display=display.none)
fill(p_w, p_z3,
     top_color    = perf_w >= 0 ? color.new(pos_col, 60) : color.new(neg_col, 60),
     bottom_color = perf_w >= 0 ? color.new(pos_col, 90) : color.new(neg_col, 90))

plot(0, color=color.new(color.rgb(120,120,120), 50), linewidth=1)

plot(show_weekly    ? thresh_ob_w : na, color=color.new(neg_col, 20), linewidth=2)
plot(show_weekly    ? thresh_os_w : na, color=color.new(pos_col, 20), linewidth=2)
plot(show_monthly   ? thresh_ob_m : na, color=color.new(neg_col, 20), linewidth=2)
plot(show_monthly   ? thresh_os_m : na, color=color.new(pos_col, 20), linewidth=2)
plot(show_quarterly ? thresh_ob_q : na, color=color.new(neg_col, 20), linewidth=2)
plot(show_quarterly ? thresh_os_q : na, color=color.new(pos_col, 20), linewidth=2)

bgcolor(use_bg and show_weekly    and perf_w >= thresh_ob_w ? color.new(neg_col, 50) : na, force_overlay=true)
bgcolor(use_bg and show_weekly    and perf_w <= thresh_os_w ? color.new(pos_col, 50) : na, force_overlay=true)
bgcolor(use_bg and show_monthly   and perf_m >= thresh_ob_m ? color.new(neg_col, 50) : na, force_overlay=true)
bgcolor(use_bg and show_monthly   and perf_m <= thresh_os_m ? color.new(pos_col, 50) : na, force_overlay=true)
bgcolor(use_bg and show_quarterly and perf_q >= thresh_ob_q ? color.new(neg_col, 50) : na, force_overlay=true)
bgcolor(use_bg and show_quarterly and perf_q <= thresh_os_q ? color.new(pos_col, 50) : na, force_overlay=true)

plotcandle(open, high, low, close, "W Candle",
     use_candle and show_weekly ? cw : na,
     use_candle and show_weekly ? cw : na,
     bordercolor  = use_candle and show_weekly ? cw : na,
     force_overlay = true)

plotcandle(open, high, low, close, "M Candle",
     use_candle and show_monthly ? cm : na,
     use_candle and show_monthly ? cm : na,
     bordercolor  = use_candle and show_monthly ? cm : na,
     force_overlay = true)

plotcandle(open, high, low, close, "Q Candle",
     use_candle and show_quarterly ? cq : na,
     use_candle and show_quarterly ? cq : na,
     bordercolor  = use_candle and show_quarterly ? cq : na,
     force_overlay = true)
````
