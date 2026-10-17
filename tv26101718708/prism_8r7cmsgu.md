# Prism

- url: https://www.tradingview.com/script/8r7CMSgu/
- type: indicator
- pine_id: PUB;c2bf779f12bb408ca51d8b73cbba5dc0
- version: 7.0

## Description

Prism : Integrated Trend Flow & Structural Risk Engine**

**Prism ** is a high-precision trend-following system designed to filter market noise and provide institutional-grade trade management. By combining **Guppy Multiple Moving Average (GMMA)** logic with **Dynamic Structural Walls** and an **Automated Entry Advice Engine**, it offers a comprehensive solution for traders who prioritize confluence over guesswork.

### **Core Logic: The Triple-Filter Approach**
Prism PRO doesn't just look at price; it analyzes the "fabric" of the market through three distinct layers:

1.  **The Ribbon Stack (Sentiment & Flow):** Utilizing 12 EMA layers, the script identifies when short-term sentiment (the fast group) is perfectly aligned with long-term capital flow (the slow group). Signals only fire when the trend is "stacked" and healthy.
2.  **Momentum Confirmation:** A built-in RSI filter ensures that signals are only triggered when momentum is on your side ([symbol="NYSE:RSI"]NYSE:RSI[/symbol] > 50$ for Longs, [symbol="NYSE:RSI"]NYSE:RSI[/symbol] < 50$ for Shorts), preventing "drift" entries in low-volatility environments.
3.  **Structural Wall Confluence:** This is the heart of the system. The script identifies the nearest **Auto-Fibonacci level** and compares it with the **EMA 12**. It selects the strongest level to create a "Structural Wall," which serves as the basis for the **Advised Stop Loss**.

### **Key Features**
* **Dynamic Entry Advice Engine:** The dashboard provides real-time feedback. It labels entries as **IDEAL**, **LATE**, or **OVEREXTENDED** based on the price's deviation from the EMA 12 and the live Reward-to-Risk (R/R) ratio.
* **Frozen State Persistence:** Unlike standard indicators that reset when a trend breaks, Prism PRO "freezes" your trade data (Entry, Stop, Target). If the ribbon stack breaks while you are in a trade, the dashboard keeps showing your last valid levels (marked with an `*`) so you can monitor your exit.
* **Ratchet Trailing Stop:** An ATR-based trailing stop that only moves in a favorable direction, protecting your capital as the trade progresses.
* **Fibo-Compression Alerts:** The dashboard monitors the distance between the current price and major Fibonacci levels. If the price is too close to a major level, it triggers a **⚠️ Warning**, alerting you to potential reversal zones or "compression" before a breakout.

### **The Dashboard Breakdown**
* **System Mode:** Instant visual of current trend bias.
* **Risk Metrics:** Live ATR volatility and percentage-based risk/reward calculations.
* **Final Call:** A "Engine Status" indicator showing the strength of the current flow.
* **Entry Advice:** Direct instructions (e.g., "Wait Pullback" or "Monitor Open Position").

### **How to Use**
1.  **The Setup:** Look for a **BUY** or **SELL** label.
2.  **The Filter:** Check the **Entry Advice**. If it says "OVEREXTENDED," wait for a pullback to the ribbon.
3.  **Risk Management:** Use the **Advised Stop** or the **Trailing Stop** provided on the dashboard to manage your exit.
4.  **Targeting:** The script plots a 1:2 R/R target by default, which is automatically cross-referenced with the nearest Fibonacci level for higher probability.

---
Disclaimer
This indicator is for educational and informational purposes only and does not constitute financial or investment advice. Trading financial markets involves significant risk of loss. Past performance is not indicative of future results. Always perform your own due diligence and consult with a professional financial advisor before making any investment decisions. The author assumes no responsibility for any financial losses incurred through the use of this script.

## Source Code

````pine
//@version=6
indicator("Prism Indicator", overlay=true, max_bars_back=500)

// --- Inputs ---
show_s1 = input.bool(true,  "Show", inline="s1", group="Short MAs")
s_len1  = input.int(5,      "SMA 1", inline="s1", group="Short MAs")
show_s2 = input.bool(true,  "Show", inline="s2", group="Short MAs")
s_len2  = input.int(8,      "SMA 2", inline="s2", group="Short MAs")
show_s3 = input.bool(true,  "Show", inline="s3", group="Short MAs")
s_len3  = input.int(13,     "SMA 3", inline="s3", group="Short MAs")
show_s4 = input.bool(false, "Show", inline="s4", group="Short MAs")
s_len4  = input.int(21,     "EMA 4", inline="s4", group="Short MAs")
show_s5 = input.bool(false, "Show", inline="s5", group="Short MAs")
s_len5  = input.int(34,     "EMA 5 (Base)", inline="s5", group="Short MAs")
show_s6 = input.bool(true,  "Show", inline="s6", group="Short MAs")
s_len6  = input.int(55,     "EMA 6", inline="s6", group="Short MAs")

show_l1 = input.bool(true,  "Show", inline="l1", group="Long EMAs")
l_len1  = input.int(89,     "EMA 1", inline="l1", group="Long EMAs")
show_l2 = input.bool(false, "Show", inline="l2", group="Long EMAs")
l_len2  = input.int(100,    "EMA 2", inline="l2", group="Long EMAs")
show_l3 = input.bool(true,  "Show", inline="l3", group="Long EMAs")
l_len3  = input.int(144,    "EMA 3 (Base)", inline="l3", group="Long EMAs")
show_l4 = input.bool(false, "Show", inline="l4", group="Long EMAs")
l_len4  = input.int(200,    "EMA 4", inline="l4", group="Long EMAs")
show_l5 = input.bool(false, "Show", inline="l5", group="Long EMAs")
l_len5  = input.int(233,    "EMA 5", inline="l5", group="Long EMAs")
show_l6 = input.bool(true,  "Show", inline="l6", group="Long EMAs")
l_len6  = input.int(377,    "EMA 6", inline="l6", group="Long EMAs")

rsi_len      = input.int(14,    "RSI Length",           group="Logic & Momentum")
atr_len      = input.int(14,    "ATR Length",           group="Risk Management")
atr_mult     = input.float(1.5, "ATR Stop Multiplier",  group="Risk Management")
rr_ratio     = input.float(2.0, "Target Reward Ratio",  group="Risk Management")
fib_lookback = input.int(100,   "Auto-Fib Lookback",    group="Dynamic Levels")

show_buy     = input.bool(true, "Show BUY Labels",      group="Visual Settings")
show_sell    = input.bool(true, "Show SELL Labels",     group="Visual Settings")

// --- Calculations ---
sma1      = ta.sma(close, s_len1)
sma2      = ta.sma(close, s_len2)
sma3      = ta.sma(close, s_len3)
ema4      = ta.ema(close, s_len4)
ema5_base = ta.ema(close, s_len5)
ema6      = ta.ema(close, s_len6)

ema7       = ta.ema(close, l_len1)
ema8       = ta.ema(close, l_len2)
ema9_base  = ta.ema(close, l_len3)
ema10      = ta.ema(close, l_len4)
ema11      = ta.ema(close, l_len5)
ema12_long = ta.ema(close, l_len6)

// --- Momentum & Logic Conditions ---
rsi_val          = ta.rsi(close, rsi_len)
is_bullish_stack = sma1 > ema6 and ema6 > ema7 and ema7 > ema12_long
is_bearish_stack = sma1 < ema6 and ema6 < ema7 and ema7 < ema12_long

// ============================================================
// VIRTUAL TRADE STATE & SIGNAL ENGINE
// ============================================================
bool raw_long_cond  = is_bullish_stack and rsi_val > 50
bool raw_short_cond = is_bearish_stack and rsi_val < 50

var int trade_state = 0 

bool long_signal  = raw_long_cond  and trade_state <= 0
bool short_signal = raw_short_cond and trade_state >= 0

if long_signal
    trade_state := 1
if short_signal
    trade_state := -1

bool is_long_cond  = (trade_state == 1)
bool is_short_cond = (trade_state == -1)

// --- Trend Direction Logic ---
string trend_dir   = "NEUTRAL"
color  trend_color = color.new(color.gray, 0)
if is_bullish_stack
    trend_dir   := "BULLISH"
    trend_color := color.new(color.green, 0)
else if is_bearish_stack
    trend_dir   := "BEARISH"
    trend_color := color.new(color.red, 0)

string engine_status = "ENGINE LOCKED"
color  status_color  = color.new(color.gray, 0)
if is_long_cond
    engine_status := "FLOW STRONG (BUY)"
    status_color  := color.new(color.green, 0)
else if is_short_cond
    engine_status := "FLOW STRONG (SELL)"
    status_color  := color.new(color.red, 0)

// --- Fixed Dynamic Risk ---
atr_val = ta.atr(atr_len)

float fixed_stop_long    = ta.valuewhen(long_signal,  low  - (atr_val * atr_mult), 0)
float fixed_target_long  = ta.valuewhen(long_signal,  close + (math.abs(close - fixed_stop_long)  * rr_ratio), 0)
float fixed_stop_short   = ta.valuewhen(short_signal, high + (atr_val * atr_mult), 0)
float fixed_target_short = ta.valuewhen(short_signal, close - (math.abs(close - fixed_stop_short) * rr_ratio), 0)

float active_stop   = is_long_cond  ? fixed_stop_long   : is_short_cond ? fixed_stop_short   : na
float active_target = is_long_cond  ? fixed_target_long : is_short_cond ? fixed_target_short : na
float active_entry  = is_long_cond  ? ta.valuewhen(long_signal,  close, 0) : is_short_cond ? ta.valuewhen(short_signal, close, 0) : na

// --- Auto-Fibonacci ---
highest_point = ta.highest(high, fib_lookback)
lowest_point  = ta.lowest(low,  fib_lookback)
fib_range     = highest_point - lowest_point

f_1618    = highest_point + (fib_range * 0.618)
f_1272    = highest_point + (fib_range * 0.272)
f_1000    = highest_point
f_0886    = highest_point - (fib_range * 0.114) // EKLENDI
f_0786    = highest_point - (fib_range * 0.214)
f_0618    = highest_point - (fib_range * 0.382)
f_0500    = highest_point - (fib_range * 0.500)
f_0382    = highest_point - (fib_range * 0.618)
f_0236    = highest_point - (fib_range * 0.764)
f_0000    = lowest_point
f_neg0272 = lowest_point - (fib_range * 0.272) // EKLENDI
f_neg0618 = lowest_point - (fib_range * 0.618) // EKLENDI

// --- Plotting Classic Fibs ---
plot(f_1618,    "Fib 1.618",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_1272,    "Fib 1.272",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_1000,    "Fib 1.000",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_0886,    "Fib 0.886",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane) // EKLENDI
plot(f_0786,    "Fib 0.786",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_0618,    "Fib 0.618",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_0500,    "Fib 0.500",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_0382,    "Fib 0.382",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_0236,    "Fib 0.236",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_0000,    "Fib 0.000",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane)
plot(f_neg0272, "Fib -0.272", color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane) // EKLENDI
plot(f_neg0618, "Fib -0.618", color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1, display=display.pane) // EKLENDI

// --- Plotting Ribbon ---
plot(show_s1 ? sma1      : na, color=color.new(color.white, 0), title="Short SMA 1 (5)") 
plot(show_s2 ? sma2      : na, color=color.new(color.yellow, 0), title="Short SMA 2 (8)") 
plot(show_s3 ? sma3      : na, color=color.new(color.orange, 0), title="Short SMA 3 (13)") 
plot(show_s4 ? ema4      : na, color=color.new(color.fuchsia, 0), title="Short EMA 4 (21)") 
plot(show_s5 ? ema5_base : na, color=color.new(color.rgb(255, 105, 180), 0), title="Short EMA 5 (34)") 
plot(show_s6 ? ema6      : na, color=color.new(color.purple, 0), linewidth=2, title="Short EMA 6 (55)") 

plot(show_l1 ? ema7       : na, color=color.new(color.blue, 0), title="Long EMA 1 (89)") 
plot(show_l2 ? ema8       : na, color=color.new(color.aqua, 0), title="Long EMA 2 (100)") 
plot(show_l3 ? ema9_base  : na, color=color.new(color.teal, 0), title="Long EMA 3 (144)") 
plot(show_l4 ? ema10      : na, color=color.new(color.lime, 0), title="Long EMA 4 (200)") 
plot(show_l5 ? ema11      : na, color=color.new(color.rgb(173, 255, 47), 0), title="Long EMA 5 (233)") 
plot(show_l6 ? ema12_long : na, color=color.new(color.gray, 0), linewidth=2, title="Long EMA 6 (377)") 

// --- Plotting Fixed Lines ---
plot(active_stop,   "Stop Level",   color=color.new(color.maroon, 40), style=plot.style_circles, linewidth=1, display=display.pane)
plot(active_target, "Target Level", color=color.new(color.teal,   40), style=plot.style_circles, linewidth=1, display=display.pane)

// ============================================================
// STRUCTURAL WALL ANALYSIS
// ============================================================
float fib_support = na
if f_0000 < close
    fib_support := f_0000
if f_0236 < close
    fib_support := na(fib_support) ? f_0236 : math.max(fib_support, f_0236)
if f_0382 < close
    fib_support := na(fib_support) ? f_0382 : math.max(fib_support, f_0382)
if f_0500 < close
    fib_support := na(fib_support) ? f_0500 : math.max(fib_support, f_0500)
if f_0618 < close
    fib_support := na(fib_support) ? f_0618 : math.max(fib_support, f_0618)
if f_0786 < close
    fib_support := na(fib_support) ? f_0786 : math.max(fib_support, f_0786)
if f_0886 < close // EKLENDI
    fib_support := na(fib_support) ? f_0886 : math.max(fib_support, f_0886)
if f_1000 < close
    fib_support := na(fib_support) ? f_1000 : math.max(fib_support, f_1000)
if f_1272 < close
    fib_support := na(fib_support) ? f_1272 : math.max(fib_support, f_1272)
if f_1618 < close
    fib_support := na(fib_support) ? f_1618 : math.max(fib_support, f_1618)

float fib_resistance = na
if f_1618 > close
    fib_resistance := f_1618
if f_1272 > close
    fib_resistance := na(fib_resistance) ? f_1272 : math.min(fib_resistance, f_1272)
if f_1000 > close
    fib_resistance := na(fib_resistance) ? f_1000 : math.min(fib_resistance, f_1000)
if f_0886 > close // EKLENDI
    fib_resistance := na(fib_resistance) ? f_0886 : math.min(fib_resistance, f_0886)
if f_0786 > close
    fib_resistance := na(fib_resistance) ? f_0786 : math.min(fib_resistance, f_0786)
if f_0618 > close
    fib_resistance := na(fib_resistance) ? f_0618 : math.min(fib_resistance, f_0618)
if f_0500 > close
    fib_resistance := na(fib_resistance) ? f_0500 : math.min(fib_resistance, f_0500)
if f_0382 > close
    fib_resistance := na(fib_resistance) ? f_0382 : math.min(fib_resistance, f_0382)
if f_0236 > close
    fib_resistance := na(fib_resistance) ? f_0236 : math.min(fib_resistance, f_0236)
if f_0000 > close
    fib_resistance := na(fib_resistance) ? f_0000 : math.min(fib_resistance, f_0000)

float ema5_base_below = ema5_base < close ? ema5_base : na
float ema5_base_above = ema5_base > close ? ema5_base : na

float struct_wall_long = na
if not na(ema5_base_below) and not na(fib_support)
    struct_wall_long := math.max(ema5_base_below, fib_support)
else if not na(ema5_base_below)
    struct_wall_long := ema5_base_below
else if not na(fib_support)
    struct_wall_long := fib_support

float struct_wall_short = na
if not na(ema5_base_above) and not na(fib_resistance)
    struct_wall_short := math.min(ema5_base_above, fib_resistance)
else if not na(ema5_base_above)
    struct_wall_short := ema5_base_above
else if not na(fib_resistance)
    struct_wall_short := fib_resistance

float advised_stop = na
if is_long_cond and not na(struct_wall_long)
    advised_stop := struct_wall_long - (atr_val * 0.2)
else if is_short_cond and not na(struct_wall_short)
    advised_stop := struct_wall_short + (atr_val * 0.2)

// ============================================================
// TRAILING STOP
// ============================================================
var float trailing_stop = na

if long_signal
    trailing_stop := na(advised_stop) ? active_stop : advised_stop
else if short_signal
    trailing_stop := na(advised_stop) ? active_stop : advised_stop
else if is_long_cond and not na(advised_stop)
    trailing_stop := na(trailing_stop) ? advised_stop : math.max(trailing_stop, advised_stop)
else if is_short_cond and not na(advised_stop)
    trailing_stop := na(trailing_stop) ? advised_stop : math.min(trailing_stop, advised_stop)
else
    trailing_stop := na

plot(is_long_cond or is_short_cond ? trailing_stop : na, "Trailing Stop", color=color.new(color.yellow, 40), style=plot.style_circles, linewidth=1, display=display.pane)

// ============================================================
// UNIFIED EXIT LOGIC
// ============================================================
float current_stop = na(trailing_stop) ? active_stop : trailing_stop

bool stop_hit_long    = is_long_cond  and not long_signal  and (low <= current_stop)
bool stop_hit_short   = is_short_cond and not short_signal and (high >= current_stop)
bool tp_hit_long      = is_long_cond  and not long_signal  and (high >= active_target)
bool tp_hit_short     = is_short_cond and not short_signal and (low <= active_target)
bool trend_break_long = is_long_cond  and not is_bullish_stack
bool trend_break_short= is_short_cond and not is_bearish_stack

bool sell_long_pos = stop_hit_long or tp_hit_long or trend_break_long
bool buy_short_pos = stop_hit_short or tp_hit_short or trend_break_short

if sell_long_pos or buy_short_pos
    trade_state := 0

// --- Signal Shapes ---
plotshape(show_buy and long_signal,   "Buy Signal",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="BUY",  textcolor=color.white, display=display.pane)
plotshape(show_sell and (short_signal or sell_long_pos), "Sell Signal", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,   0), size=size.small, text="SELL", textcolor=color.white, display=display.pane)

// ============================================================
// DYNAMIC ALERTS
// ============================================================
if long_signal
    alert("Prism: BUY Signal! Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if short_signal
    alert("Prism: SELL Signal (Short)! Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

if stop_hit_long or stop_hit_short
    alert("Prism: EXIT! (Reason: Stop Hit). Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if tp_hit_long or tp_hit_short
    alert("Prism: EXIT! (Reason: Target Hit). Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)
if (trend_break_long and not (stop_hit_long or tp_hit_long)) or (trend_break_short and not (stop_hit_short or tp_hit_short))
    alert("Prism: EXIT! (Reason: Trend Broken). Price: " + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

// ============================================================
// ENTRY ADVICE ENGINE
// ============================================================
string entry_advice = "WAITING"
color  advice_bg    = color.new(color.gray, 0)

if (is_long_cond or is_short_cond) and not na(active_entry) and not na(active_target) and not na(advised_stop)
    float pot_gain  = is_long_cond ? (active_target - close) : (close - active_target)
    float pot_risk  = is_long_cond ? (close - advised_stop)  : (advised_stop - close)
    float live_rr   = pot_risk > 0 ? pot_gain / pot_risk : 0.0
    float entry_dev = math.abs(close - active_entry) / active_entry
    bool  tgt_hit   = is_long_cond ? (close >= active_target) : (close <= active_target)
    bool  overext   = is_long_cond ? (close > ema5_base * 1.02)   : (close < ema5_base * 0.98)

    if tgt_hit
        entry_advice := "TARGET HIT - WAIT PULLBACK"
        advice_bg    := color.new(color.red, 0)
    else if live_rr < 1.0
        entry_advice := "RISK > REWARD - SKIP"
        advice_bg    := color.new(color.red, 0)
    else if overext
        entry_advice := "OVEREXTENDED - WAIT PULLBACK"
        advice_bg    := color.new(color.orange, 0)
    else if entry_dev <= 0.01
        entry_advice := "IDEAL ENTRY"
        advice_bg    := color.new(color.green, 0)
    else
        entry_advice := "LATE ENTRY - CAUTION"
        advice_bg    := color.new(color.orange, 0)

// ============================================================
// FROZEN DISPLAY VALUES & DASHBOARD
// ============================================================
var float  frozen_entry     = na
var float  frozen_stop      = na
var float  frozen_target    = na
var float  frozen_adv_stop  = na
var float  frozen_trail     = na
var string frozen_advice    = "WAITING"
var color  frozen_advice_bg = color.new(color.gray, 0)

if is_long_cond or is_short_cond
    if not na(active_entry)
        frozen_entry := active_entry
    if not na(active_stop)
        frozen_stop := active_stop
    if not na(active_target)
        frozen_target := active_target
    if not na(advised_stop)
        frozen_adv_stop := advised_stop
    frozen_advice    := entry_advice
    frozen_advice_bg := advice_bg

if not na(trailing_stop)
    frozen_trail := trailing_stop

bool   is_locked       = not (is_long_cond or is_short_cond)
string disp_advice     = is_locked and not na(frozen_entry) ? "MONITOR OPEN POSITION" : entry_advice
color  disp_advice_bg  = is_locked and not na(frozen_entry) ? color.new(color.blue, 20) : advice_bg

var table panel = table.new(position.top_right, 2, 10, border_width=1, border_color=color.black)

if barstate.islast
    float ref_entry  = na(active_entry)  ? frozen_entry  : active_entry
    float ref_stop   = na(active_stop)   ? frozen_stop   : active_stop
    float ref_target = na(active_target) ? frozen_target : active_target
    float ref_adv    = na(advised_stop)  ? frozen_adv_stop : advised_stop
    float ref_trail  = na(trailing_stop) ? frozen_trail  : trailing_stop

    string stale = is_locked ? " *" : ""

    closest_fib_val  = f_1618
    closest_fib_name = "Fib 1.618"
    min_dist = na(ref_target) ? 9999999 : math.abs(ref_target - f_1618)

    if not na(ref_target)
        if math.abs(ref_target - f_1272) < min_dist
            closest_fib_val  := f_1272
            closest_fib_name := "Fib 1.272"
            min_dist         := math.abs(ref_target - f_1272)
        if math.abs(ref_target - f_1000) < min_dist
            closest_fib_val  := f_1000
            closest_fib_name := "Fib 1.000"
            min_dist         := math.abs(ref_target - f_1000)
        if math.abs(ref_target - f_0886) < min_dist // EKLENDI
            closest_fib_val  := f_0886
            closest_fib_name := "Fib 0.886"
            min_dist         := math.abs(ref_target - f_0886)
        if math.abs(ref_target - f_0786) < min_dist
            closest_fib_val  := f_0786
            closest_fib_name := "Fib 0.786"
            min_dist         := math.abs(ref_target - f_0786)
        if math.abs(ref_target - f_0618) < min_dist
            closest_fib_val  := f_0618
            closest_fib_name := "Fib 0.618"
            min_dist         := math.abs(ref_target - f_0618)
        if math.abs(ref_target - f_0500) < min_dist
            closest_fib_val  := f_0500
            closest_fib_name := "Fib 0.500"
            min_dist         := math.abs(ref_target - f_0500)
        if math.abs(ref_target - f_0382) < min_dist
            closest_fib_val  := f_0382
            closest_fib_name := "Fib 0.382"
            min_dist         := math.abs(ref_target - f_0382)
        if math.abs(ref_target - f_0236) < min_dist
            closest_fib_val  := f_0236
            closest_fib_name := "Fib 0.236"
            min_dist         := math.abs(ref_target - f_0236)
        if math.abs(ref_target - f_0000) < min_dist
            closest_fib_val  := f_0000
            closest_fib_name := "Fib 0.000"
            min_dist         := math.abs(ref_target - f_0000)
        if math.abs(ref_target - f_neg0272) < min_dist // EKLENDI
            closest_fib_val  := f_neg0272
            closest_fib_name := "Fib -0.272"
            min_dist         := math.abs(ref_target - f_neg0272)
        if math.abs(ref_target - f_neg0618) < min_dist // EKLENDI
            closest_fib_val  := f_neg0618
            closest_fib_name := "Fib -0.618"
            min_dist         := math.abs(ref_target - f_neg0618)

    bool is_fibo_warning = false
    if not na(ref_entry) and not na(ref_target)
        if math.abs(close - closest_fib_val) <= (atr_val * 0.5)
            is_fibo_warning := true

    color  fib_bg        = is_fibo_warning ? color.new(color.yellow, 0) : color.new(color.purple, 0)
    color  fib_txt       = is_fibo_warning ? color.black : color.white
    string fib_alert_txt = is_fibo_warning ? "⚠️ " + closest_fib_name : closest_fib_name

    string entry_str = na(ref_entry)  ? "WAITING" : str.tostring(ref_entry,  format.mintick) + stale
    string est_stop_pct = str.tostring(math.round(((atr_val * atr_mult) / close) * 100, 2)) + "%"
    string stop_str     = na(ref_stop) ? "-" : str.tostring(ref_stop, format.mintick) + stale + " (" + est_stop_pct + ")"
    string est_target_pct = str.tostring(math.round((((atr_val * atr_mult) * rr_ratio) / close) * 100, 2)) + "%"
    string target_str     = na(ref_target) ? "-" : str.tostring(ref_target, format.mintick) + stale + " (" + est_target_pct + ")"
    string fib_str      = na(ref_target) ? "-" : (fib_alert_txt + " : " + str.tostring(closest_fib_val, format.mintick))
    string adv_stop_str = na(ref_adv)   ? "-" : str.tostring(ref_adv,   format.mintick) + stale
    string trail_str    = na(ref_trail) ? "-" : str.tostring(ref_trail, format.mintick) + stale

    table.cell(panel, 0, 0, "SYSTEM MODE",      bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 0, trend_dir,          bgcolor=trend_color,                text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 1, "VOLATILITY (ATR)", bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 1, str.tostring(math.round(atr_val, 2)), bgcolor=color.new(color.gray, 0), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 2, "ENTRY PRICE",      bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 2, entry_str,          bgcolor=color.new(color.blue, 0),   text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 3, "STOP & RISK",       bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 3, stop_str,            bgcolor=color.new(color.maroon, 0), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 4, "TARGET (1:" + str.tostring(rr_ratio) + ")", bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 4, target_str, bgcolor=color.new(color.teal, 0), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 5, "CLOSEST FIBO",      bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 5, fib_str,             bgcolor=fib_bg,                     text_color=fib_txt,     text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 6, "FINAL CALL",        bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 6, engine_status,       bgcolor=status_color,               text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 7, "ENTRY ADVICE",       bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 7, disp_advice,          bgcolor=disp_advice_bg,             text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 8, "ADVISED STOP",        bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 8, adv_stop_str,          bgcolor=color.new(color.navy, 0),   text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(panel, 0, 9, "TRAILING STOP",        bgcolor=color.new(color.black, 10), text_color=color.white, text_size=size.small)
    table.cell(panel, 1, 9, trail_str,              bgcolor=color.new(color.olive, 0),  text_color=color.white, text_size=size.small, text_halign=text.align_center)

// ============================================================
// FIBONACCI DYNAMIC LABELS
// ============================================================
var label_1618    = label.new(bar_index, f_1618, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_1272    = label.new(bar_index, f_1272, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_1000    = label.new(bar_index, f_1000, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_0886    = label.new(bar_index, f_0886, "", style=label.style_none, textcolor=color.orange, size=size.small) // EKLENDI
var label_0786    = label.new(bar_index, f_0786, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_0618    = label.new(bar_index, f_0618, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_0500    = label.new(bar_index, f_0500, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_0382    = label.new(bar_index, f_0382, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_0236    = label.new(bar_index, f_0236, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_0000    = label.new(bar_index, f_0000, "", style=label.style_none, textcolor=color.orange, size=size.small)
var label_neg0272 = label.new(bar_index, f_neg0272, "", style=label.style_none, textcolor=color.orange, size=size.small) // EKLENDI
var label_neg0618 = label.new(bar_index, f_neg0618, "", style=label.style_none, textcolor=color.orange, size=size.small) // EKLENDI

update_fib_label(_lbl, _val, _txt) =>
    label.set_xy(_lbl, bar_index + 2, _val)
    label.set_text(_lbl, _txt + " (" + str.tostring(_val, format.mintick) + ")")

if barstate.islast
    update_fib_label(label_1618,    f_1618,    "1.618")
    update_fib_label(label_1272,    f_1272,    "1.272")
    update_fib_label(label_1000,    f_1000,    "1.000")
    update_fib_label(label_0886,    f_0886,    "0.886")    // EKLENDI
    update_fib_label(label_0786,    f_0786,    "0.786")
    update_fib_label(label_0618,    f_0618,    "0.618")
    update_fib_label(label_0500,    f_0500,    "0.500")
    update_fib_label(label_0382,    f_0382,    "0.382")
    update_fib_label(label_0236,    f_0236,    "0.236")
    update_fib_label(label_0000,    f_0000,    "0.000")
    update_fib_label(label_neg0272, f_neg0272, "-0.272") // EKLENDI
    update_fib_label(label_neg0618, f_neg0618, "-0.618") // EKLENDI
````
