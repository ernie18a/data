# P3 Power Price & Money Flow Extremes

- url: https://www.tradingview.com/script/3mn5pK18-P3-Power-Price-Money-Flow-Extremes/
- type: indicator
- pine_id: PUB;a31e53d90e3341edb32580065e6b76d4
- version: 1.0

## Description

[image]https://www.tradingview.com/x/Ocr6uu8j/[/image]Don’t Trade the Move. Understand It.

P3 Power is a simple tool built to help you recognize when the market is in an extreme condition.

It combines two components:

• %R (blue) → measures how far price has stretched  
• MFI (green) → shows whether money is actually behind the move  

When both align, something important is happening. That doesn’t mean buy or sell — it means pay attention.

HOW I USE IT

This is not an entry indicator. It is a decision filter.

I use it to answer:
• Is price stretched?  
• Is money confirming the move?  
• Is this expansion or exhaustion?  

When both are at extremes, the market is in a high-energy state. From there, I rely on structure and location.

USING WITH VWAP

This is where it becomes powerful.

• Extreme + far from VWAP → often reversion  
• Extreme + holding VWAP bands → often continuation  
• Extreme + VWAP rejection → strong reaction potential  

P3 Power tells you when something matters. VWAP helps decide what to do.

MULTI-TIMEFRAME USE

You can run %R and MFI on different timeframes.

Examples to test:
• Same timeframe → precise timing  
• Lower TF %R + higher TF MFI → early signal + confirmation  
• Higher TF MFI → larger exhaustion zones  

This is where the tool opens up — but it requires backtesting.

IMPORTANT

This indicator does NOT provide entry or exit signals.

If you trade every extreme, you will get run over.

Extremes can mean:
• reversal  
• continuation  
• or nothing  

Use this with structure, VWAP, and your own rules.

This tool is built to help you understand conditions — not chase signals.

## Source Code

````pine
//@version=6
import HeWhoMustNotBeNamed/ta/1

indicator("P3 Power", format=format.price, precision=2, explicit_plot_zorder=true)

// === GROUPS ===
const string groupSettings = "Settings"
const string groupLevels = "Shared Guide Levels"
const string groupWR = "P3%R Settings"
const string groupMFI = "P3MFI Settings"
const string groupAlerts = "Alerts"

// === SHARED LEVELS ===
p3_upper = input.int(90, "Upper Extreme", minval=0, maxval=100, group=groupLevels)
p3_mid   = input.int(50, "Midline", minval=0, maxval=100, group=groupLevels)
p3_lower = input.int(10, "Lower Extreme", minval=0, maxval=100, group=groupLevels)

// === SHARED LEVEL COLORS ===
p3_hot_color = input.color(#CA0017, "Upper Level Color", group=groupSettings, inline="lvlcol")
p3_cold_color = input.color(#2466A7, "Lower Level Color", group=groupSettings, inline="lvlcol")
p3_mid_base_color = input.color(color.gray, "Midline Color", group=groupSettings)
p3_mid_color = color.new(p3_mid_base_color, 50)

// === P3%R INPUTS ===
p3_wr_tf = input.timeframe("", "P3%R Timeframe (blank = chart)", group=groupWR)
p3_wr_src = input.source(close, "P3%R Source", group=groupWR)
p3_wr_smooth_type = input.string("ema", "P3%R Smoothing Type", options=["sma", "ema", "hma", "rma", "wma", "vwma", "swma", "highlow", "linreg", "median", "mom", "percentrank"], group=groupWR)
p3_wr_line_color = input.color(color.rgb(139, 174, 255), "P3%R Line Color", group=groupWR)
p3_wr_length = input.int(112, "P3%R Slow Length", minval=1, group=groupWR)
p3_wr_smoothing_length = input.int(3, "P3%R Slow Smoothing Length", minval=1, group=groupWR)

// === P3MFI INPUTS ===
p3_mfi_tf = input.timeframe("", "P3MFI Timeframe (blank = chart)", group=groupMFI)
p3_mfi_length = input.int(8, "P3MFI Length", minval=1, maxval=2000, group=groupMFI)
p3_mfi_line_color = input.color(#7E57C2, "P3MFI Line Color", group=groupMFI)

// === ALERT INPUTS ===
enable_ob_alert = input.bool(true, "Enable Both Overbought Alert", group=groupAlerts)
enable_os_alert = input.bool(true, "Enable Both Oversold Alert", group=groupAlerts)

// === P3%R CALCULATION ===
p3_wr_calc() =>
    float max_val = ta.highest(p3_wr_length)
    float min_val = ta.lowest(p3_wr_length)
    float raw = 100 * (p3_wr_src - max_val) / (max_val - min_val)
    p3_wr_smoothing_length > 1 ? ta.ma(raw, p3_wr_smooth_type, p3_wr_smoothing_length) : raw

float p3_wr_raw = request.security(
    syminfo.tickerid,
    p3_wr_tf == "" ? timeframe.period : p3_wr_tf,
    p3_wr_calc()
)

// Normalize %R from -100..0 to 0..100
float p3_wr = p3_wr_raw + 100

// === P3MFI CALCULATION ===
float p3_mfi = request.security(
    syminfo.tickerid,
    p3_mfi_tf == "" ? timeframe.period : p3_mfi_tf,
    ta.mfi(hlc3, p3_mfi_length)
)

// === STATES ===
bool p3_wr_overbought = p3_wr >= p3_upper
bool p3_wr_oversold = p3_wr <= p3_lower

bool p3_mfi_overbought = p3_mfi >= p3_upper
bool p3_mfi_oversold = p3_mfi <= p3_lower

bool both_overbought = p3_wr_overbought and p3_mfi_overbought
bool both_oversold = p3_wr_oversold and p3_mfi_oversold

// === GUIDE LINES ===
hline(p3_upper, "Upper Extreme", color.new(p3_hot_color, 20), linestyle=hline.style_solid)
hline(p3_mid, "Midline", p3_mid_color, linestyle=hline.style_solid)
hline(p3_lower, "Lower Extreme", color.new(p3_cold_color, 20), linestyle=hline.style_solid)

// === PLOTS ===
plot(p3_wr, "P3%R", color=p3_wr_line_color, linewidth=1)
plot(p3_mfi, "P3MFI", color=p3_mfi_line_color, linewidth=1)

// === ALERT CONDITIONS ===
alertcondition(enable_ob_alert and both_overbought, "P3 Power Both Overbought", "P3%R and P3MFI are both above the upper extreme.")
alertcondition(enable_os_alert and both_oversold, "P3 Power Both Oversold", "P3%R and P3MFI are both below the lower extreme.")
````
