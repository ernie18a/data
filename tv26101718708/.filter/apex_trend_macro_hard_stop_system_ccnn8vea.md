# APEX TREND: Macro & Hard Stop System

- url: https://www.tradingview.com/script/cCnN8veA-APEX-TREND-Macro-Hard-Stop-System/
- type: indicator
- pine_id: PUB;a4832e0780e34d49b450e8ab034c0e78
- version: 1.0

## Description

[b]APEX TREND: Macro & Hard Stop System [Institutional Grade][/b]
The APEX TREND System is a composite trend-following strategy engineered to solve the "Whipsaw" problem inherent in standard breakout systems. It orchestrates four distinct technical theories—Macro Trend Filtering, Volatility Squeeze, Momentum, and Volatility Stop-Loss—into a single, hierarchical decision-making engine.

This script is not merely a collection of indicators; it is a rules-based trading system designed for Swing Traders (Day/Week timeframes) who aim to capture major trend extensions while strictly managing downside risk through a "Hard Stop" mechanism.

🧠 Underlying Concepts & Originality
Many trend indicators fail because they treat all price movements equally. The APEX TREND differentiates itself by applying an "Institutional Filter" logic derived from classic Dow Theory and Modern Volatility Analysis.

1. The Macro Hard Stop (The 200 EMA Logic)

Origin: Based on the institutional mandate that “Nothing good happens below the 200-day moving average.”

Function: Unlike standard super trends that flip constantly in sideways markets, this system integrates a 200-period Exponential Moving Average (EMA) as a non-negotiable "Hard Stop."

Synergy: This acts as the primary gatekeeper. Even if the volatility engine signals a "Buy," the system suppresses the signal if the price is below the Macro Baseline, effectively filtering out counter-trend traps.

2. The Volatility Engine (Squeeze Theory)

Origin: Derived from John Carter’s TTM Squeeze concept.

Function: The script identifies periods where Bollinger Bands (Standard Deviation) contract inside Keltner Channels (ATR). This indicates a period of potential energy build-up.

Synergy: The system only triggers an entry when this energy is released (Breakout) AND coincides with Linear Regression Momentum, ensuring the breakout is genuine.

3. Anti-Chop Filter (ADX Integration)

Origin: J. Welles Wilder’s Directional Movement Theory.

Function: A common failure point for trend systems is low-volatility chop. This script utilizes the Average Directional Index (ADX).

Synergy: If the ADX is below the threshold (Default: 20), the market is deemed "Choppy." The script visually represents this by painting candles GRAY, signaling a "No-Trade Zone" regardless of price action.

4. The "Run Trend" Stop Loss (Factor 4.0 ATR)

Origin: Adapted from the Turtle Trading rules regarding volatility-based stops.

Function: Standard Trailing Stops (usually Factor 3.0) are too tight for crypto or volatile equities on daily timeframes.

Optimization: This system employs a wider ATR Multiplier of 4.0. This allows the asset to fluctuate naturally within a trend without triggering a premature exit, maximizing the "Run Trend" potential.

🛠 How It Works (The Algorithm)
The script processes data in a specific order to generate a signal:

Check Macro Trend: Is Price > EMA 200? (If No, Longs are disabled).

Check Volatility: Is ADX > 20? (If No, all signals are disabled).

Check Volume: Is Current Volume > 1.2x Average Volume? (Confirmation of institutional participation).

Trigger: Has a Volatility Breakout occurred in the direction of the Macro Trend?

Execution: If ALL above are true -> Generate Signal.

🎯 Strategy Guide
1. Long Setup (Bullish)
Signal: Look for the Green "APEX LONG" Label.

Condition: The price must be ABOVE the White Line (EMA 200).

Execution: Enter at the close of the signal candle.

Stop Loss: Initial stop at the Green Trailing Line.

2. Short Setup (Bearish)
Signal: Look for the Red "APEX SHORT" Label.

Condition: The price must be BELOW the White Line (EMA 200).

Execution: Enter at the close of the signal candle.

Stop Loss: Initial stop at the Red Trailing Line.

3. Exit Rules (Crucial)
This system employs a Dual-Exit Mechanism:

Soft Exit (Profit Taking): Close the position if the price crosses the Trailing Stop Line (Green/Red line). This locks in profits during a trend reversal.

Hard Exit (Emergency): Close the position IMMEDIATELY if the price crosses the White EMA 200 Line against your trade. This prevents holding a position during a major market regime change.

⚙️ Settings
Momentum Engine: Adjust Bollinger Band/Keltner Channel lengths to tune breakout sensitivity.

Apex Filters: Toggle the EMA 200 or ADX filters on/off to adapt to different asset classes.

Risk Management: The ATR Multiplier (Default 4.0) controls the width of the trailing stop. Lower values = Tighter stops (Scalping); Higher values = Looser stops (Swing).

Disclaimer: This script is designed for trend-following on higher timeframes (4H, 1D, 1W). Please backtest on your specific asset before live trading.

## Source Code

````pine
//@version=6
indicator("APEX TREND: Macro & Hard Stop System", shorttitle="APEX TREND", overlay=true)

// ==========================================
// 1. SETTINGS (ตั้งค่าระบบ)
// ==========================================
group_sqz = "1. Momentum Engine (ตัวขับเคลื่อน)"
bb_len    = input.int(20, "BB Length", group=group_sqz)
bb_mult   = input.float(2.0, "BB MultFactor", group=group_sqz)
kc_mult   = input.float(1.5, "KC MultFactor", group=group_sqz)

group_flt = "2. Apex Filters (ตัวกรองขั้นสูง)"
use_ema   = input.bool(true, "Enable Macro Hard Stop (EMA 200)", group=group_flt)
use_adx   = input.bool(true, "Enable Volatility Filter (ADX)", group=group_flt)
adx_th    = input.int(20, "ADX Threshold (Strength)", group=group_flt)
vol_mult  = input.float(1.2, "Volume Flow Factor", group=group_flt)

group_exit = "3. Risk Management (การจัดการความเสี่ยง)"
atr_period = input.int(14, "ATR Period", group=group_exit)
atr_mult   = input.float(4.0, "Trend Holding Width (Factor 4.0)", group=group_exit)

// ==========================================
// 2. CALCULATIONS (การคำนวณ)
// ==========================================

// --- A. Macro Trend Architecture (EMA 200) ---
ema200 = ta.ema(close, 200)
// กฎเหล็ก: ห้ามสวนเทรนด์ใหญ่
is_uptrend_macro = use_ema ? (close > ema200) : true
is_downtrend_macro = use_ema ? (close < ema200) : true

// --- B. Trend Strength (ADX) ---
[_, _, adx] = ta.dmi(14, 14)
is_strong = use_adx ? (adx > adx_th) : true

// --- C. Volatility Squeeze & Momentum ---
[basis, upperBB, lowerBB] = ta.bb(close, bb_len, bb_mult)
[kc_mid, upperKC, lowerKC] = ta.kc(close, bb_len, kc_mult)
is_squeeze = (lowerBB > lowerKC) and (upperBB < upperKC)

// Linear Regression Momentum (หาทิศทางที่แท้จริง)
src_mom = close - math.avg(math.avg(ta.highest(high, bb_len), ta.lowest(low, bb_len)), ta.sma(close, bb_len))
val = ta.linreg(src_mom, bb_len, 0)
is_bull_mom = val > 0
is_bear_mom = val < 0

// --- D. Institutional Volume Flow ---
vol_avg = ta.sma(volume, 20)
is_vol_ok = volume > (vol_avg * vol_mult)

// --- E. Dynamic Trailing Stop (ATR Based) ---
atr = ta.atr(atr_period)
long_sl_raw = ta.highest(close, atr_period) - (atr * atr_mult)
short_sl_raw = ta.lowest(close, atr_period) + (atr * atr_mult)

var float long_trail = na
long_trail := na(long_trail[1]) ? long_sl_raw : math.max(long_sl_raw, long_trail[1])

var float short_trail = na
short_trail := na(short_trail[1]) ? short_sl_raw : math.min(short_sl_raw, short_trail[1])

// ==========================================
// 3. SIGNAL LOGIC & STATE MACHINE
// ==========================================
var int trade_state = 0 // 0=Wait, 1=Long, -1=Short

// Apex Breakout Conditions
bull_break = ta.crossover(close, upperBB) and is_bull_mom and is_vol_ok and is_strong and is_uptrend_macro
bear_break = ta.crossunder(close, lowerBB) and is_bear_mom and is_vol_ok and is_strong and is_downtrend_macro

// Signal Variables
bool open_long = false
bool open_short = false
bool close_long = false
bool close_short = false

// --- CORE LOGIC LOOP ---
if trade_state == 0
    // สถานะว่าง: รอสัญญาณ Apex
    if bull_break
        trade_state := 1
        open_long := true
        long_trail := long_sl_raw
    else if bear_break
        trade_state := -1
        open_short := true
        short_trail := short_sl_raw

else if trade_state == 1
    // ถือ Long: ออกเมื่อหลุด Trail หรือ หลุด Macro Hard Stop
    bool hard_stop_long = use_ema and (close < ema200)
    
    if ta.crossunder(close, long_trail) or hard_stop_long
        trade_state := 0
        close_long := true

else if trade_state == -1
    // ถือ Short: ออกเมื่อทะลุ Trail หรือ ทะลุ Macro Hard Stop
    bool hard_stop_short = use_ema and (close > ema200)
    
    if ta.crossover(close, short_trail) or hard_stop_short
        trade_state := 0
        close_short := true

// ==========================================
// 4. VISUALIZATION (หน้าตา)
// ==========================================

// Plot Macro Hard Stop Line
plot(use_ema ? ema200 : na, "Macro Hard Stop (EMA 200)", color=color.white, linewidth=2)

// Plot Trailing Stop Lines
plot(trade_state == 1 ? long_trail : na, "Apex Long Stop", color=#00ff00, style=plot.style_linebr, linewidth=2)
plot(trade_state == -1 ? short_trail : na, "Apex Short Stop", color=#ff0000, style=plot.style_linebr, linewidth=2)

// Paint Bar (Smart Colors)
// เขียว = Bull Run, แดง = Bear Run, เทา = No Trade Zone
barcolor(trade_state == 1 ? #00ff00 : trade_state == -1 ? #ff0000 : #5d606b)

// Plot Entry Signals
plotshape(open_long, title="APEX LONG", location=location.belowbar, color=#00ff00, style=shape.labelup, size=size.small, text="APEX\nLONG", textcolor=color.black)
plotshape(open_short, title="APEX SHORT", location=location.abovebar, color=#ff0000, style=shape.labeldown, size=size.small, text="APEX\nSHORT", textcolor=color.white)

// Plot Exit Signals
plotshape(close_long, title="EXIT", location=location.abovebar, color=color.white, style=shape.xcross, size=size.tiny)
plotshape(close_short, title="EXIT", location=location.belowbar, color=color.white, style=shape.xcross, size=size.tiny)

// ==========================================
// 5. DASHBOARD (แผงควบคุม)
// ==========================================
var table tbl = table.new(position.bottom_right, 2, 5, bgcolor=color.new(color.black, 30), border_width=1)
if barstate.islast
    table.cell(tbl, 0, 0, "APEX SYSTEM", text_color=color.white, width=12, bgcolor=#003366)
    
    // Status
    txt = trade_state == 1 ? "BULL RUNNING" : (trade_state == -1 ? "BEAR RUNNING" : "WAITING")
    col = trade_state == 1 ? #00ff00 : (trade_state == -1 ? #ff0000 : color.gray)
    txt_col = trade_state == 1 ? color.black : color.white

    table.cell(tbl, 0, 1, "Status", text_color=color.white)
    table.cell(tbl, 1, 1, txt, bgcolor=col, text_color=txt_col)

    // Trailing Stop Price
    sl_val = trade_state == 1 ? long_trail : (trade_state == -1 ? short_trail : na)
    table.cell(tbl, 0, 2, "Trailing Stop", text_color=color.white)
    table.cell(tbl, 1, 2, str.tostring(sl_val, "#.##"), text_color=color.white)
    
    // EMA Hard Stop Price
    table.cell(tbl, 0, 3, "Hard Stop (200)", text_color=color.gray)
    table.cell(tbl, 1, 3, str.tostring(ema200, "#.##"), text_color=color.white)
    
    // Macro Check
    ema_stat = close > ema200 ? "BULLISH ZONE" : "BEARISH ZONE"
    table.cell(tbl, 0, 4, "Macro View", text_color=color.gray)
    table.cell(tbl, 1, 4, ema_stat, text_color=close > ema200 ? #00ff00 : #ff0000)
````
