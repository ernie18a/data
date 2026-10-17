# VIDYA + Fisher Trend System [Custom]

- url: https://www.tradingview.com/script/oi0GcMVK/
- type: indicator
- pine_id: PUB;ead0445333884a94b5693936925b5cdf
- version: 2.0

## Description

VIDYA + Fisher Trend System [Custom]
A powerful trend-following system combining Volumatic VIDYA with Fisher Transform for high-probability entry signals

📊 Overview
This indicator is a comprehensive trading system that combines two proven technical analysis tools:

VIDYA (Variable Index Dynamic Average) - A smart moving average that adapts to market volatility

Fisher Transform - A mathematical transformation that converts price data into a Gaussian normal distribution

The system uses VIDYA to determine trend direction and the Fisher Transform to generate precise entry signals with take-profit targets.

🎯 Core Concept
The indicator operates on a dual-layer approach:

Trend Layer (VIDYA): Dynamically identifies market trend using Volumatic VIDYA with adaptive bands

Signal Layer (Fisher Transform): Generates entry and exit signals based on Fisher crossovers at key levels

🟢 BUY Signal Conditions:
Trend is UP (price above lower VIDYA band)

Fisher is below 0 (oversold condition)

Fisher line crosses above Trigger line (momentum shift)

🔴 SELL Signal Conditions:
Trend is DOWN (price below upper VIDYA band)

Fisher is above 0 (overbought condition)

Fisher line crosses below Trigger line (momentum shift)

🎯 Take-Profit System
The indicator includes an intelligent take-profit mechanism:

After a BUY signal: TP triggers when Fisher crosses below Trigger (momentum exhaustion)

After a SELL signal: TP triggers when Fisher crosses above Trigger (momentum exhaustion)

Each position tracks entry Fisher value for reference

🔧 Input Parameters
VIDYA Settings
Parameter	Description	Default
VIDYA Length	Calculation period for VIDYA	10
VIDYA Momentum	Momentum period for volatility adjustment	20
Distance Factor	Multiplier for upper/lower bands	2.0
Fisher Transform Settings
Parameter	Description	Default
Fisher Length	Period for Fisher calculation	9
Visual Settings
Parameter	Description	Default
Up Trend Color	Color for uptrend visualization	Green
Down Trend Color	Color for downtrend visualization	Red
Shadow	Enable/disable trend fill	True
📈 Visualization
Main Chart
VIDYA Trend Line: Dynamic trend line colored by direction

BUY Signals: Green triangle pointing up with "BUY" text

SELL Signals: Red triangle pointing down with "SELL" text

TP Signals: Orange triangle with "TP" text

Trend Fill: Semi-transparent fill between price and trend line

Fisher Pane (Separate Window)
Fisher Line (Blue): Main Fisher Transform value

Trigger Line (Orange): Previous Fisher value

Key Levels: 1.5, 0.75, 0, -0.75, -1.5 (dashed lines)

Signal Markers: Small triangles at signal points

Information Table (Top-Right)
Current trend direction

Latest Fisher value with color coding

Trading status (BUY/SELL opportunity or WAIT)

TP status (Active/Waiting)

Entry Fisher values for open positions

🚨 Alert Conditions
The indicator provides comprehensive alert conditions:

🔵 BUY Signal

🔴 SELL Signal

📈 Trend Turned UP

📉 Trend Turned DOWN

🎯 BUY TP Signal (Take Profit)

🎯 SELL TP Signal (Take Profit)

💡 How to Use
1. Trend Identification
Uptrend: Green trend line, price above lower band

Downtrend: Red trend line, price below upper band

2. Entry Signals
Wait for trend confirmation

Enter on BUY/SELL signals

Use Fisher values for position management

3. Risk Management
Use TP signals to take profits

Monitor Fisher levels for extreme conditions (±1.5)

Adjust position sizing based on trend strength

🔍 Technical Explanation
VIDYA (Variable Index Dynamic Average)
VIDYA adapts to market volatility using the Chande Momentum Oscillator (CMO). Unlike traditional moving averages, VIDYA becomes more responsive during volatile periods and smoother during quiet periods, making it ideal for trend identification.

Fisher Transform
The Fisher Transform normalizes price data, making price movements more apparent. It helps identify turning points by highlighting when prices reach extreme levels (overbought/oversold) and when momentum shifts occur.

⚠️ Important Notes
This is a trend-following system - performs best in trending markets

May produce false signals in ranging/choppy markets

Always use proper risk management and position sizing

Best used in conjunction with other analysis tools

Default settings are optimized for daily timeframes - adjust for other timeframes

🏆 Credits
This indicator is inspired by and incorporates elements from:

BigBelluga - Original VIDYA concept and implementation

John Ehlers - Fisher Transform mathematical framework

The combination of these two powerful tools creates a robust system that adapts to market conditions while providing clear, actionable signals.

🔄 Version History
v1.0 - Initial release

VIDYA trend detection with adaptive bands

Fisher Transform signal generation

Integrated take-profit system

Full alert conditions

Interactive information table

📝 Disclaimer
This indicator is for educational and informational purposes only. It does not constitute financial advice. Always conduct your own research and analysis before making trading decisions. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("VIDYA + Fisher Trend System [Custom]", overlay=true, precision=4)

// ==============================================
// 1. VOLUMATIC VIDYA (Trend Determiner)
// ==============================================
int vidya_length = input.int(10, 'VIDYA Length')
int vidya_momentum = input.int(20, 'VIDYA Momentum')
float band_distance = input.float(2, 'Distance factor for upper/lower bands', step=0.1)

float source = input.source(close, 'Source')

color up_trend_color = input(#17dfad, '+', group='Color', inline='c')
color down_trend_color = input(#dd326b, '-', group='Color', inline='c')
bool shadow = input.bool(true, 'Shadow', group='Color', inline='c')

// VIDYA Calculation
vidya_calc(src, vidya_length, vidya_momentum) =>
    float momentum = ta.change(src)
    float sum_pos_momentum = math.sum(momentum >= 0 ? momentum : 0.0, vidya_momentum)
    float sum_neg_momentum = math.sum(momentum >= 0 ? 0.0 : -momentum, vidya_momentum)
    float abs_cmo = math.abs(100 * (sum_pos_momentum - sum_neg_momentum) / (sum_pos_momentum + sum_neg_momentum))
    float alpha = 2 / (vidya_length + 1)
    var float vidya_value = 0.0
    vidya_value := alpha * abs_cmo / 100 * src + (1 - alpha * abs_cmo / 100) * nz(vidya_value[1])
    ta.sma(vidya_value, 15)

float atr_value = ta.atr(200)
vidya_value = vidya_calc(source, vidya_length, vidya_momentum)

float upper_band = vidya_value + atr_value * band_distance
float lower_band = vidya_value - atr_value * band_distance

// Trend Direction
var bool is_trend_up = false

if ta.crossover(source, upper_band)
    is_trend_up := true
if ta.crossunder(source, lower_band)
    is_trend_up := false

// ==============================================
// 2. FISHER TRANSFORM (Signal Generator)
// ==============================================
len = input.int(9, minval=1, title="Fisher Length", group="Fisher Transform")

high_ = ta.highest(hl2, len)
low_ = ta.lowest(hl2, len)

round_(val) => val > .99 ? .999 : val < -.99 ? -.999 : val

value = 0.0
value := round_(.66 * ((hl2 - low_) / (high_ - low_) - .5) + .67 * nz(value[1]))

fish1 = 0.0
fish1 := .5 * math.log((1 + value) / (1 - value)) + .5 * nz(fish1[1])
fish2 = fish1[1]

// ==============================================
// 3. PERSISTENT SIGNAL MECHANISM (PREVENT SIGNAL LOSS)
// ==============================================

// Persistent signal variables
var bool buy_signal_persistent = false
var bool sell_signal_persistent = false
var float buy_signal_price = na
var float sell_signal_price = na
var int buy_signal_bar = 0
var int sell_signal_bar = 0
var float buy_entry_fisher = na
var float sell_entry_fisher = na

// New signal conditions (temporary)
bool buy_signal_new = is_trend_up and fish1 < 0 and fish1 > fish2 and fish1[1] <= fish2[1]
bool sell_signal_new = not is_trend_up and fish1 > 0 and fish1 < fish2 and fish1[1] >= fish2[1]

// Lock BUY signal (fixed on first trigger)
if buy_signal_new and not buy_signal_persistent
    buy_signal_persistent := true
    buy_signal_price := close
    buy_signal_bar := bar_index
    buy_entry_fisher := fish1

// Lock SELL signal (fixed on first trigger)
if sell_signal_new and not sell_signal_persistent
    sell_signal_persistent := true
    sell_signal_price := close
    sell_signal_bar := bar_index
    sell_entry_fisher := fish1

// Reset signals when opposite signal occurs
if (sell_signal_persistent and buy_signal_new)
    buy_signal_persistent := false
    buy_signal_price := na
    buy_signal_bar := 0
    buy_entry_fisher := na

if (buy_signal_persistent and sell_signal_new)
    sell_signal_persistent := false
    sell_signal_price := na
    sell_signal_bar := 0
    sell_entry_fisher := na

// ==============================================
// 4. TAKE-PROFIT (TP) SIGNALS - PERSISTENT VERSION
// ==============================================

// BUY TP Condition: While persistent BUY signal exists, Fisher crosses down
bool buy_tp_signal = buy_signal_persistent and fish1 < fish2 and fish1[1] >= fish2[1]

// SELL TP Condition: While persistent SELL signal exists, Fisher crosses up
bool sell_tp_signal = sell_signal_persistent and fish1 > fish2 and fish1[1] <= fish2[1]

// Clear signals when TP is triggered
if buy_tp_signal
    buy_signal_persistent := false
    buy_signal_price := na
    buy_signal_bar := 0
    buy_entry_fisher := na

if sell_tp_signal
    sell_signal_persistent := false
    sell_signal_price := na
    sell_signal_bar := 0
    sell_entry_fisher := na

// ==============================================
// 5. VISUALIZATION - MAIN WINDOW
// ==============================================

// VIDYA Trend Line
float smoothed_value = is_trend_up ? lower_band : upper_band
color trend_color = is_trend_up ? up_trend_color : down_trend_color

p1 = plot(smoothed_value, color=trend_color, linewidth=2, style=plot.style_linebr, title="VIDYA Trend")
p2 = plot(hl2, display=display.none)

fill(p1, p2, smoothed_value, hl2, color.new(trend_color, shadow ? 80 : 100), na)

// Fisher Levels (Reference in main window)
hline(1.5, "1.5", color=#E91E63, linestyle=hline.style_dashed)
hline(0.75, "0.75", color=#787B86, linestyle=hline.style_dashed)
hline(0, "0", color=#E91E63, linestyle=hline.style_dashed)
hline(-0.75, "-0.75", color=#787B86, linestyle=hline.style_dashed)
hline(-1.5, "-1.5", color=#E91E63, linestyle=hline.style_dashed)

// Fisher Lines (For lower pane)
plot(fish1, color=#2962FF, title="Fisher", display=display.pane)
plot(fish2, color=#FF6D00, title="Trigger", display=display.pane)

// ==============================================
// 6. SIGNAL INDICATORS (PERSISTENT)
// ==============================================

// BUY Signal - Main window (doesn't disappear)
plotshape(buy_signal_persistent, title="BUY Signal", style=shape.triangleup, 
          location=location.belowbar, color=color.new(#17dfad, 0), 
          size=size.huge, text="BUY", textcolor=color.white)

// SELL Signal - Main window (doesn't disappear)
plotshape(sell_signal_persistent, title="SELL Signal", style=shape.triangledown, 
          location=location.abovebar, color=color.new(#dd326b, 0), 
          size=size.huge, text="SELL", textcolor=color.white)

// BUY Signal - Fisher lower pane
plotshape(buy_signal_persistent, title="BUY Fisher", style=shape.triangleup, 
          location=location.bottom, color=color.new(#17dfad, 0), 
          size=size.small, display=display.pane)

// SELL Signal - Fisher lower pane
plotshape(sell_signal_persistent, title="SELL Fisher", style=shape.triangledown, 
          location=location.top, color=color.new(#dd326b, 0), 
          size=size.small, display=display.pane)

// ==============================================
// 7. TP INDICATORS
// ==============================================

// BUY TP - Main window
plotshape(buy_tp_signal, title="BUY TP Signal", style=shape.triangledown,
          location=location.abovebar, color=color.new(#FF6B00, 0),
          size=size.huge, text="TP", textcolor=color.white)

// SELL TP - Main window
plotshape(sell_tp_signal, title="SELL TP Signal", style=shape.triangleup,
          location=location.belowbar, color=color.new(#FF6B00, 0),
          size=size.huge, text="TP", textcolor=color.white)

// BUY TP - Fisher lower pane
plotshape(buy_tp_signal, title="BUY TP Fisher", style=shape.triangledown,
          location=location.top, color=color.new(#FF6B00, 0),
          size=size.small, display=display.pane)

// SELL TP - Fisher lower pane
plotshape(sell_tp_signal, title="SELL TP Fisher", style=shape.triangleup,
          location=location.bottom, color=color.new(#FF6B00, 0),
          size=size.small, display=display.pane)

// ==============================================
// 8. ALERT CONDITION (Notifications)
// ==============================================

alertcondition(buy_signal_persistent, title="🔵 BUY Signal", message="BUY: Trend UP + Fisher cross below 0")
alertcondition(sell_signal_persistent, title="🔴 SELL Signal", message="SELL: Trend DOWN + Fisher cross above 0")
alertcondition(buy_tp_signal, title="🎯 BUY TP Signal", message="BUY TP: Fisher crosses down - TAKE PROFIT")
alertcondition(sell_tp_signal, title="🎯 SELL TP Signal", message="SELL TP: Fisher crosses up - TAKE PROFIT")
alertcondition(is_trend_up and not is_trend_up[1], title="📈 Trend Turned UP", message="VIDYA Trend turned UP")
alertcondition(not is_trend_up and is_trend_up[1], title="📉 Trend Turned DOWN", message="VIDYA Trend turned DOWN")

// ==============================================
// 9. TABLE INFORMATION (Last bar)
// ==============================================

if barstate.islast
    var table info_table = table.new(position.top_right, 2, 7, bgcolor=color.new(color.black, 85), border_width=1, border_color=color.gray)
    
    // Trend
    table.cell(info_table, 0, 0, "Trend", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 0, is_trend_up ? "▲ UP" : "▼ DOWN", text_color=trend_color, text_size=size.small)
    
    // Fisher
    table.cell(info_table, 0, 1, "Fisher", text_color=color.white, text_size=size.small)
    table.cell(info_table, 1, 1, str.tostring(fish1, "#.##"), text_color=fish1 > 1.5 ? color.red : fish1 < -1.5 ? color.green : color.white, text_size=size.small)
    
    // Signal Status
    table.cell(info_table, 0, 2, "Signal", text_color=color.white, text_size=size.small)
    string status = buy_signal_persistent ? "⚡ BUY ACTIVE" : sell_signal_persistent ? "⚡ SELL ACTIVE" : "⏸ WAITING"
    color status_color = buy_signal_persistent ? color.green : sell_signal_persistent ? color.red : color.gray
    table.cell(info_table, 1, 2, status, text_color=status_color, text_size=size.small)
    
    // TP Status
    table.cell(info_table, 0, 3, "TP Status", text_color=color.white, text_size=size.small)
    string tp_status = buy_tp_signal ? "✅ BUY TP" : sell_tp_signal ? "✅ SELL TP" : "⏸ WAITING"
    color tp_color = buy_tp_signal ? color.green : sell_tp_signal ? color.red : color.gray
    table.cell(info_table, 1, 3, tp_status, text_color=tp_color, text_size=size.small)
    
    // BUY Entry Price
    if not na(buy_signal_price)
        table.cell(info_table, 0, 4, "BUY Entry", text_color=color.white, text_size=size.small)
        table.cell(info_table, 1, 4, str.tostring(buy_signal_price, "#.##"), text_color=color.green, text_size=size.small)
    
    // SELL Entry Price
    if not na(sell_signal_price)
        table.cell(info_table, 0, 5, "SELL Entry", text_color=color.white, text_size=size.small)
        table.cell(info_table, 1, 5, str.tostring(sell_signal_price, "#.##"), text_color=color.red, text_size=size.small)
    
    // Fisher Entry Values
    if not na(buy_entry_fisher)
        table.cell(info_table, 0, 6, "BUY Fisher", text_color=color.white, text_size=size.small)
        table.cell(info_table, 1, 6, str.tostring(buy_entry_fisher, "#.##"), text_color=color.green, text_size=size.small)
    
    if not na(sell_entry_fisher)
        table.cell(info_table, 0, 6, "SELL Fisher", text_color=color.white, text_size=size.small)
        table.cell(info_table, 1, 6, str.tostring(sell_entry_fisher, "#.##"), text_color=color.red, text_size=size.small)
````
