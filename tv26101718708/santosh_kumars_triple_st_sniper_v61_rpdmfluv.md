# Santosh Kumar's Triple ST Sniper v6.1

- url: https://www.tradingview.com/script/RPDmflUv-Santosh-Kumar-s-Triple-ST-Sniper-v6-1/
- type: indicator
- pine_id: PUB;b0ee3cc01528494aac451dcdb8aaeb98
- version: 1.0

## Description

This indicator is a pure price-action and momentum confluence system based on three distinct layers of SuperTrend filters, specifically optimized for the 15-Minute (15M) timeframe. It completely removes the lag of traditional moving averages and focuses purely on high-velocity trend capturing and dynamic support/resistance zones.

### 📊 System Settings (Parameters Used):
* **Fast SuperTrend:** Period 10, Multiplier 1.0 (Used as Momentum Sensor & Exit Trigger)
* **Medium SuperTrend:** Period 12, Multiplier 2.0 (Used as Core Stop-Loss & Primary Bounce Zone)
* **Slow SuperTrend:** Period 14, Multiplier 2.5 (Used as Major Structural Trend Base)

---

### 🎮 Trading Rules & Execution Strategy (Hinglish Guide):

1. Entry Trigger:
* 🚀 BUY Signal: Jab teeno SuperTrends ek saath GREEN ho jaate hain, tab Dashboard par "BUY" flash hota hai. Yeh ek fresh entry point hai normal base quantity ke saath.
* 💥 SHORT Signal: Jab teeno SuperTrend lines ek saath RED zone me convert hoti hain, tab Dashboard "SHORT" command dikhata hai.

2. The Bounce Back (Pyramiding / Leverage Top-up):
* Uptrend me entry lene ke baad, jab price niche pullback leta hai aur Medium ST (12, 2.0) ya Slow ST (14, 2.5) line par aakar support (rejection) dikhata hai, wahan position size ya leverage ko badhaya (scale-in) ja sakta hai.
* Stop Loss: In that case, strict SL is trailing just below the bounce candle's low.

3. Target/Momentum Exit:
* Jaise hi market ek sharp spike deta hai aur top par trend exhausted hota hai, sabse pehle Fast ST (10, 1.0) flip maarta hai. Dashboard turant "EXIT (FAST ST REVERSAL)" alert flash karega to lock profits immediately.

---

### 🎛️ Premium On-Screen Dashboard:
The script includes a clean, real-time UI table on the top-right corner showing:
* Owner Name: Santosh Kumar (@santoshpsiii)
* Live trend color matrix of all 3 SuperTrends simultaneously.
* Final Action trigger (BUY / SHORT / EXIT / WAIT) based on live candle closes.

*Disclaimer: This tool is designed for algorithmic visualization and manual momentum trading

## Source Code

````pine
//@version=6
indicator("Santosh Kumar's Triple ST Sniper v6.1", overlay=true)

// ---- USER BRANDING & CREDIT ----
// Strategy Owner: Santosh Kumar (@santoshpsiii)
// Execution Timeframe: 15 Minutes (15M) Optimized for V6

// ---- INPUTS ----
ats1 = input.int(10, title="Fast ST Period (Exit Trigger)", group="ST 1 Settings")
mult1 = input.float(1.0, title="Fast ST Multiplier (Exit Trigger)", group="ST 1 Settings")

ats2 = input.int(12, title="Medium ST Period (Core SL / Bounce)", group="ST 2 Settings")
mult2 = input.float(2.0, title="Medium ST Multiplier (Core SL / Bounce)", group="ST 2 Settings")

ats3 = input.int(14, title="Slow ST Period (Major Base)", group="ST 3 Settings")
mult3 = input.float(2.5, title="Slow ST Multiplier (Major Base)", group="ST 3 Settings")

// ---- INDICATORS CONFIG ----
[st1, dir1] = ta.supertrend(mult1, ats1)
[st2, dir2] = ta.supertrend(mult2, ats2)
[st3, dir3] = ta.supertrend(mult3, ats3)

st1_green = dir1 < 0
st2_green = dir2 < 0
st3_green = dir3 < 0

// ---- CORE SIGNAL LOGIC ----
string final_action = "WAIT"
color action_color = color.gray

if st1_green and st2_green and st3_green
    final_action := "🚀 BUY (ALL GREEN)"
    action_color := color.green
else if not st1_green and not st2_green and not st3_green
    final_action := "💥 SHORT (ALL RED)"
    action_color := color.red
else if (st1_green == false and st2_green and st3_green) or (st1_green == true and not st2_green and not st3_green)
    final_action := "⏹️ EXIT (FAST ST REVERSAL)"
    action_color := color.navy // V6 compatible alternative for orange warning

// ---- VISUAL DASHBOARD UI DESIGN (V6 FIXED COLORS) ----
var table dashTable = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 15), border_width=1, border_color=color.gray)

if barstate.islast
    // Branding Header (V6 Basic Colors)
    table.cell(dashTable, 0, 0, "OWNER:", bgcolor=color.blue, text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 0, "SANTOSH KUMAR", bgcolor=color.blue, text_color=color.white, text_size=size.small)
    
    // Sub-Header
    table.cell(dashTable, 0, 1, "TRIPLE ST SYSTEM", bgcolor=color.navy, text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 1, "LIVE SCAN (15M)", bgcolor=color.navy, text_color=color.white, text_size=size.small)
    
    // Row 1: Fast ST
    table.cell(dashTable, 0, 2, "Fast ST (10, 1.0)", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 2, st1_green ? "GREEN" : "RED", bgcolor=st1_green ? color.green : color.red, text_color=color.white, text_size=size.small)
    
    // Row 2: Medium ST
    table.cell(dashTable, 0, 3, "Medium ST (12, 2.0)", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 3, st2_green ? "GREEN" : "RED", bgcolor=st2_green ? color.green : color.red, text_color=color.white, text_size=size.small)
    
    // Row 3: Slow ST
    table.cell(dashTable, 0, 4, "Slow ST (14, 2.5)", text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 4, st3_green ? "GREEN" : "RED", bgcolor=st3_green ? color.green : color.red, text_color=color.white, text_size=size.small)
    
    // Row 4: FINAL ACTION
    table.cell(dashTable, 0, 5, "SANTOSH'S SIGNAL", bgcolor=color.blue, text_color=color.white, text_size=size.small)
    table.cell(dashTable, 1, 5, final_action, bgcolor=action_color, text_color=color.white, text_size=size.small)

// ---- LINES PLOTTING ----
plot(st1, color=st1_green ? color.new(color.green, 40) : color.new(color.red, 40), title="Fast ST Line (10, 1.0)", linewidth=1)
plot(st2, color=st2_green ? color.lime : color.red, title="Medium ST Line (12, 2.0)", linewidth=2)
plot(st3, color=st3_green ? color.teal : color.maroon, title="Slow ST Line (14, 2.5)", linewidth=3)
````
