# Institutional SD Master - Trader Sect69

- url: https://www.tradingview.com/script/IDfOMbbN-Institutional-SD-Master-Trader-Sect69/
- type: indicator
- pine_id: PUB;41100634710e49bc91f41ef2713c1ddb
- version: 2.0

## Description

### **How to Use This Indicator**

#### **1. Configuration & Setup**
* **Asset Selection:** Choose between **Gold (H4 Bias)** or **Crypto (H1 Bias)** in the settings.
    * *Gold:* Uses a 4-hour HTF anchor for direction.
    * *Crypto:* Uses a refined 1-hour internal candle lookback for intraday displacement.
* **Trading Days:** Toggle specific days (Mon-Fri) to display **Box Ranges**. The indicator will only be "ACTIVE" on these chosen days to keep you disciplined and avoid overtrading.

#### **2. Understanding the Dashboard**
The real-time dashboard tracks your strategy requirements automatically:
* **Signal Bias:** Determines direction based on **EMA 9/18** trend alignment and price location relative to the **Daily Open (P.Open)**.
* **Criteria Check:** Displays **READY ✅** only when price has performed an **Institutional Sweep** (moving into Discount for longs or Premium for shorts).
* **Execution Levels:** Provides 4-decimal precision for your **Entry (-0.5)**, **Target 1 (-1.0)**, **Target 2 (-2.0)**, and **Invalidation**.

#### **3. The Institutional SD Logic**
Unlike standard Fibonacci tools, this script anchors the SD from a specific **Institutional Reference Point** (HTF Open/Close) to a recent **Liquidity Purge** (Swing High/Low). 
* **Entry (-0.5):** Look for a "Break and Retest" of a PD Array (FVG or Order Block) nested at this level.
* **Targets:** Aim for -1.0 (First Objective) and -2.0 (Institutional Expansion).
* **Risk Management:** Move your Stop Loss to **Break Even** once price closes a body beyond the -1.0 level.

### **Core Principles**
* **Consistency:** Only trade on "Active Days."
* **Discipline:** If the Criteria Check is **SEARCHING 🔍**, stay flat.
* **Preservation:** The Invalidation level is your "hard stop." If it breaks, the setup is dead.

---

**Author Note:** This tool is designed to remove emotion from trading by transforming subjective price action into objective mathematical levels. Be consistent, be disciplined.

## Source Code

````pine
// @version=5
indicator("Institutional SD Master - Logic Fixed", overlay=true, max_boxes_count=500)

// --- 1. Inputs ---
group_setup = "Global Setup"
show_mon = input.bool(true, "Mon", group=group_setup, inline="d")
show_tue = input.bool(true, "Tue", group=group_setup, inline="d")
show_wed = input.bool(true, "Wed", group=group_setup, inline="d")
show_thu = input.bool(true, "Thu", group=group_setup, inline="d")
show_fri = input.bool(true, "Fri", group=group_setup, inline="d")
pair     = input.string("Gold", "Asset Type", options=["Gold", "Crypto"], group=group_setup)
show_box = input.bool(true, "Show Probability Box", group=group_setup)

group_color = "Visuals"
bg_c   = input.color(color.new(color.black, 20), "Board Bg", group=group_color)
txt_c  = input.color(color.white, "Text Color", group=group_color)
val_c  = input.color(color.aqua, "Values Color", group=group_color)

// --- 2. Directional Logic & SD Math ---
d_open = request.security(syminfo.tickerid, "D", open)
h4_c   = request.security(syminfo.tickerid, "240", close[1])
h1_l   = request.security(syminfo.tickerid, "60", low[0])

is_active = (dayofweek == dayofweek.monday and show_mon) or (dayofweek == dayofweek.tuesday and show_tue) or (dayofweek == dayofweek.wednesday and show_wed) or (dayofweek == dayofweek.thursday and show_thu) or (dayofweek == dayofweek.friday and show_fri)

e9 = ta.ema(close, 9), e18 = ta.ema(close, 18), bull = e9 > e18

// --- CRITICAL LOGIC FIX ---
// For Longs: Anchor (Start) is LOW, Reference (End) is HIGH -> Target is ABOVE
// For Shorts: Anchor (Start) is HIGH, Reference (End) is LOW -> Target is BELOW
raw_pl = ta.pivotlow(low, 2, 2), raw_ph = ta.pivothigh(high, 2, 2)
sd_start = bull ? ta.valuewhen(not na(raw_pl), raw_pl, 0) : ta.valuewhen(not na(raw_ph), raw_ph, 0)
sd_end   = pair == "Gold" ? h4_c : h1_l

// Calculation of Distance (Expansion Range)
float range_dist = sd_end - sd_start

// Levels: Entry at -0.5 (Retracement), Target at -2.0 (Expansion)
float entry = sd_end - (range_dist * 0.5)
float tp    = sd_end + (range_dist * 1.5) // This ensures the -2.0 projection is in the right direction
float sl    = sd_start

// Probability Sweep Filter
swept = bull ? low <= d_open : high >= d_open

// --- 3. Visual Probability Box ---
var box p_box = na, var box l_box = na
if show_box and is_active and swept
    if na(p_box)
        p_box := box.new(bar_index, entry, bar_index, tp, bgcolor=color.new(color.green, 85), border_color=color.green)
        l_box := box.new(bar_index, entry, bar_index, sl, bgcolor=color.new(color.red, 85), border_color=color.red)
    else
        box.set_right(p_box, bar_index), box.set_right(l_box, bar_index)
        box.set_left(p_box, bar_index - 10), box.set_left(l_box, bar_index - 10)
        box.set_top(p_box, bull ? tp : entry), box.set_bottom(p_box, bull ? entry : tp)
        box.set_top(l_box, bull ? entry : sl), box.set_bottom(l_box, bull ? sl : entry)
else
    box.delete(p_box), box.delete(l_box)
    p_box := na, l_box := na

// --- 4. Final Dashboard ---
f(v) => str.tostring(v, "#.####")
var table b = table.new(position.top_right, 2, 10, bgcolor=bg_c, border_width=1, border_color=color.gray)
if barstate.islast
    table.cell(b, 0, 0, "Market Status", text_color=txt_c), table.cell(b, 1, 0, is_active ? "ACTIVE" : "OFF", bgcolor=is_active ? color.green : color.red, text_color=color.white)
    table.cell(b, 0, 1, "P.Open Value", text_color=txt_c),  table.cell(b, 1, 1, f(d_open), text_color=val_c)
    table.cell(b, 0, 2, "Signal Bias", text_color=txt_c),   table.cell(b, 1, 2, bull ? "LONG" : "SHORT", bgcolor=bull ? color.new(color.green, 70) : color.new(color.red, 70), text_color=color.white)
    table.cell(b, 0, 3, "Entry (-0.5)", text_color=txt_c),  table.cell(b, 1, 3, f(entry), text_color=val_c)
    table.cell(b, 0, 4, "Target (-2.0)", text_color=txt_c), table.cell(b, 1, 4, f(tp), text_color=color.lime)
    table.cell(b, 0, 5, "SL / Inval.", text_color=txt_c),   table.cell(b, 1, 5, f(sl), text_color=color.red)
    table.cell(b, 0, 6, "Prob. Check", text_color=txt_c),   table.cell(b, 1, 6, swept ? "HIGH ✅" : "LOW ⏳", bgcolor=swept ? color.green : color.orange, text_color=color.white)
````
