<!-- tradingview-pine-id: PUB;8d21c05c678c4855bf7a9f6de729bb0e -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SMI Sniper Pro [MTF]

Source: https://www.tradingview.com/script/b4faQEoQ-SMI-Sniper-Pro-MTF/

## Description

This indicator is an elite Multi-Timeframe Stochastic Momentum Index indicator engineered for high-precision scalping and swing trading. 

Built for traders who demand razor-sharp execution, this script combines advanced momentum smoothing with a dynamic real-time dashboard to eliminate market noise and lock onto high-probability entries

 🔑 Key Features

** Multi-Timeframe (MTF) Engine:
Seamlessly track SMI momentum from any higher or lower timeframe directly on your current chart layout.

** Dual Smoothing Mechanism:
Double-smoothed EMA calculations designed to filter out false breakouts and whipsaws in choppy market conditions.

** Dynamic HUD Info Table:
A sleek, compact real-time status table positioned at the top-right corner with intelligent color-coded momentum states.

** Extreme Zone Awareness:
Pre-configured visual fills for Overbought (+40 to +100) and Oversold (-40 to -100) zones to capture perfect market reversals.

** Comprehensive Alert Suite:
Built-in alerts covering Signal Crossovers, Zero-Line crossovers, and Extreme Zone entries so you never miss a setup.

💡 How to Trade with SMI Sniper Pro

** Momentum Crossovers:
Track the interaction between the Yellow SMI line and the White Signal line for early momentum shifts.

** Zero-Line Flips:
Use the 0 line to confirm dominant macro-bias (Bullish above zero, Bearish below zero).

**Zone Rejections:
Watch for momentum exhaustion when the indicator plunges into or emerges from the shaded Extreme Zones.

**Multi-Timeframe Confluence:
Combine the HUD table readings with your chart structure for ultimate sniper precision.

Please Enjoy!!

---

## Source Code

````pine
//@version=6
indicator("SMI Sniper Pro [MTF]", overlay=false, precision=2)

grp_calc     = "Calculation Settings"
tf_input     = input.timeframe("", "Indicator Timeframe", group=grp_calc) 
smi_len      = input.int(8, "SMI Range Length", group=grp_calc)
smi_s1       = input.int(3, "SMI Smoothing 1", group=grp_calc)
smi_s2       = input.int(3, "SMI Smoothing 2", group=grp_calc)
sig_len      = input.int(3, "Signal Line Length", group=grp_calc)

grp_display  = "DISPLAY SETTINGS"
show_table   = input.bool(true, "Show Info Table", group=grp_display)
table_pos    = input.string("top_right", "Table Position", options=["top_right", "bottom_right", "top_left", "bottom_left"], group=grp_display)
table_size   = input.string("normal", "Table Size", options=["small", "normal", "large", "huge"], group=grp_display)

calc_smi() =>
    ll = ta.lowest(low, smi_len)
    hh = ta.highest(high, smi_len)
    diff = hh - ll
    rdiff = close - (hh + ll) / 2
    avg_rel = ta.ema(ta.ema(rdiff, smi_s1), smi_s2)
    avg_diff = ta.ema(ta.ema(diff, smi_s1), smi_s2)
    smi_val = avg_diff != 0 ? (avg_rel / (avg_diff / 2) * 100) : 0
    smi_val

// ดึงข้อมูล Multi-Timeframe
smi = request.security(syminfo.tickerid, tf_input, calc_smi(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
smi_signal = ta.ema(smi, sig_len)

hline(0, "Zero Line", color=color.gray, linestyle=hline.style_dotted)
ob_level = hline(40, "Overbought", color=color.new(#ff0000, 50))
os_level = hline(-40, "Oversold", color=color.new(#00ff08, 50))

fill(ob_level, hline(100), color=color.new(#ff0000, 92), title="OB Fill")
fill(os_level, hline(-100), color=color.new(#00ff08, 92), title="OS Fill")

plot(smi, "SMI Line", color=color.yellow, linewidth=2)
plot(smi_signal, "SMI Signal", color=color.white, linewidth=1)

bull_cross = ta.crossover(smi, smi_signal)
bear_cross = ta.crossunder(smi, smi_signal)

bull_zone = ta.crossover(smi, -40)
bear_zone = ta.crossunder(smi, 40)

bull_zero = ta.crossover(smi, 0)
bear_zero = ta.crossunder(smi, 0)

alertcondition(bull_cross, title="SMI Cross Above Signal", message="SMI Sniper Pro: Bullish Crossover (SMI crossed above Signal)")
alertcondition(bear_cross, title="SMI Cross Under Signal", message="SMI Sniper Pro: Bearish Crossover (SMI crossed under Signal)")

alertcondition(bull_zero, title="SMI Cross Above Zero", message="SMI Sniper Pro: Bullish Zero Line Crossover")
alertcondition(bear_zero, title="SMI Cross Under Zero", message="SMI Sniper Pro: Bearish Zero Line Crossover")

alertcondition(bull_zone, title="SMI Enter Oversold Zone", message="SMI Sniper Pro: Entered Oversold Zone (> -40)")
alertcondition(bear_zone, title="SMI Enter Overbought Zone", message="SMI Sniper Pro: Entered Overbought Zone (< 40)")

display_tf = tf_input == "" ? timeframe.period : tf_input

var pos = table_pos == "top_right" ? position.top_right : 
          table_pos == "bottom_right" ? position.bottom_right :
          table_pos == "top_left" ? position.top_left : position.bottom_left

var t_size = table_size == "small" ? size.small : 
             table_size == "normal" ? size.normal : 
             table_size == "large" ? size.large : size.huge

var table smi_table = table.new(pos, 2, 1, border_width = 1, border_color = color.new(color.gray, 70))

if show_table and barstate.islast
    smi_color = smi > 0 ? color.new(#00ff08, 20) : color.new(#ff0000, 20)
    table.cell(smi_table, 0, 0, "SMI (" + display_tf + ")", bgcolor = color.new(color.gray, 30), text_color = color.white, text_size = t_size)
    table.cell(smi_table, 1, 0, str.tostring(smi, "#.##"), bgcolor = smi_color, text_color = color.white, text_size = t_size)
````
