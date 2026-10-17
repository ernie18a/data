# RobinHood Stochastics Oscillator RSI - RSOR

- url: https://www.tradingview.com/script/BJ3o6pfM-RobinHood-Stochastics-Oscillator-RSI-RSOR/
- type: indicator
- pine_id: PUB;4385703ea5eb4f3d8a8b10dcb544458d
- version: 2.0

## Description

[b]Overview[/b] This indicator is a complete Pine Script v6 port of the custom "RSOR" (RSI of EMA + Stochastics) indicator originally built for MT4 (MQL4). It combines a unique momentum calculation—RSI of EMA—with two distinct Stochastic oscillators (Fast and Slow) into a single, clean pane.

[b]How It Works[/b] [list] [][b]RSI of EMA (Purple Line):[/b] Unlike the traditional Wilder's RSI, this script calculates the relative strength based on the difference between consecutive Exponential Moving Averages (EMA). It uses a custom "Simple Sum" logic to accumulate gains and losses over the specified period, making it highly reactive to momentum shifts. [][b]Stochastic Fast & Slow:[/b] The indicator utilizes dual Stochastics. Both the Fast (Orange) and Slow (Blue) Stochastics are configured to smooth their %D signal lines using an EMA (mirroring the [i]MODE_EMA[/i] parameter from MT4). The raw %K lines are hidden to reduce chart clutter, focusing strictly on the smoothed %D signal lines. [/list]

[b]How to Use It[/b] Traders can use this indicator to identify momentum exhaustion, divergences, and trend entries: [list] []Look for the RSI of EMA to cross into the extreme zones (above 70 or below 30) for potential reversal setups. []Use the direction and positioning of the Fast and Slow Stochastics relative to the neutral zone to gauge the primary trend. [*]Confluence between the RSI of EMA and Stochastics leaving the shaded extreme zones provides high-probability entry signals. [/list]

[b]Visual Groupings and Zones[/b] To enhance readability without overpowering the price chart, the indicator features 3 distinct background zones with subtle opacity fills: [list] [][b]Oversold Zone (10 - 30):[/b] Bounded by red dotted lines with a very light red background fill to indicate extreme downside momentum. [][b]Neutral Zone (45 - 55):[/b] Bounded by white dotted/dashed lines with a light white background fill to define the midline chop zone. [*][b]Overbought Zone (70 - 90):[/b] Bounded by green dotted lines with a light green background fill to indicate extreme upside momentum. [/list]

## Source Code

````pine
//@version=6
indicator("RobinHood Stochastics Oscillator RSI - RSOR", shorttitle="RSOR", overlay=false, precision=2)

// --- Inputs ---
// RSI of EMA Settings
rsi_grp = "--- RSI of EMA Settings ---"
RSI_Period = input.int(4, "RSI Period", minval=1, group=rsi_grp)
EMA_Period = input.int(14, "EMA Period", minval=1, group=rsi_grp)
color_rsi  = input.color(#9C27B0, "Color RSI of EMA", group=rsi_grp)  // DodgerBlue
width_rsi  = input.int(3, "Width RSI of EMA", minval=1, group=rsi_grp)

// Stochastic Fast Settings
stoch1_grp   = "--- Stochastic Fast Settings ---"
S1_K         = input.int(8, "Stoch Fast %K", minval=1, group=stoch1_grp)
S1_D         = input.int(3, "Stoch Fast %D", minval=1, group=stoch1_grp)
S1_Slowing   = input.int(3, "Stoch Fast Slowing", minval=1, group=stoch1_grp)
color_stoch1 = input.color(color.orange, "Color Stoch Fast", group=stoch1_grp)
width_stoch1 = input.int(1, "Width Stoch Fast", minval=1, group=stoch1_grp)

// Stochastic Slow Settings
stoch2_grp   = "--- Stochastic Slow Settings ---"
S2_K         = input.int(55, "Stoch Slow %K", minval=1, group=stoch2_grp)
S2_D         = input.int(12, "Stoch Slow %D", minval=1, group=stoch2_grp)
S2_Slowing   = input.int(3, "Stoch Slow Slowing", minval=1, group=stoch2_grp)
color_stoch2 = input.color(color.rgb(0, 191, 255), "Color Stoch Slow", group=stoch2_grp) // DeepSkyBlue
width_stoch2 = input.int(1, "Width Stoch Slow", minval=1, group=stoch2_grp)

// --- Logic ---

// 1. RSI of EMA (Simple Sum Logic)
ema_val = ta.ema(close, EMA_Period)
ema_diff = ema_val - ema_val[1]

gains = 0.0
losses = 0.0
for j = 0 to RSI_Period - 1
    d = nz(ema_diff[j])
    if d > 0
        gains += d
    else
        losses -= d  // diff < 0 nên -= biến thành cộng |diff|

// Xử lý edge case: khi chưa đủ số nến để tính EMA và RSI, trả về na để biểu đồ không hiển thị đường nằm ngang 100.0 vô nghĩa
rsi_ema = bar_index < EMA_Period + RSI_Period ? na : (losses == 0 ? 100.0 : 100.0 - (100.0 / (1.0 + (gains / losses))))

// 2. Stochastic Fast %D
raw_k1 = ta.stoch(close, high, low, S1_K)
slowed_k1 = ta.sma(raw_k1, S1_Slowing)
stoch_fast_d = ta.ema(slowed_k1, S1_D)

// 3. Stochastic Slow %D
raw_k2 = ta.stoch(close, high, low, S2_K)
slowed_k2 = ta.sma(raw_k2, S2_Slowing)
stoch_slow_d = ta.ema(slowed_k2, S2_D)

// --- Plotting ---
plot(rsi_ema, title="RSI of EMA", color=color_rsi, linewidth=width_rsi)
plot(stoch_fast_d, title="Stoch Fast %D", color=color_stoch1, linewidth=width_stoch1)
plot(stoch_slow_d, title="Stoch Slow %D", color=color_stoch2, linewidth=width_stoch2)

// Levels
// Nhóm 10-20-30: Yellow
h30 = hline(30, "Level 30", color=color.new(color.red, 70), linestyle=hline.style_dotted)
h20 = hline(20, "Level 20", color=color.new(color.red, 70), linestyle=hline.style_dotted)
h10 = hline(10, "Level 10", color=color.new(color.red, 70), linestyle=hline.style_dotted)
fill(h30, h10, color=color.new(color.red, 95), title="Background Yellow Group")

// Nhóm 45-50-55: Green
h55 = hline(55, "Level 55", color=color.new(color.white, 70), linestyle=hline.style_dotted)
h50 = hline(50, "Level 50", color=color.new(color.white, 70), linestyle=hline.style_dashed)
h45 = hline(45, "Level 45", color=color.new(color.white, 70), linestyle=hline.style_dotted)
fill(h55, h45, color=color.new(color.white, 97), title="Background Green Group")

// Nhóm 70-80-90: Blue
h90 = hline(90, "Level 90", color=color.new(color.green, 70), linestyle=hline.style_dotted)
h80 = hline(80, "Level 80", color=color.new(color.green, 70), linestyle=hline.style_dotted)
h70 = hline(70, "Level 70", color=color.new(color.green, 70), linestyle=hline.style_dotted)
fill(h90, h70, color=color.new(color.green, 95), title="Background Blue Group")
````
