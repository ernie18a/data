# Gann Time Cycles Pro: Confluence 

- url: https://www.tradingview.com/script/wvB4k17z-Gann-Time-Cycles-Pro-Confluence/
- type: indicator
- pine_id: PUB;13479e15ccd1488d8791ec09db726735
- version: 1.0

## Description

Think of the stock market like a giant, calm pond. 
When the market has a **massive crash** (a bottom) or hits a **crazy all-time high** (a top), it is like dropping a giant boulder into that pond. 

That boulder creates ripples. Those ripples travel forward in time. According to W.D. Gann, those ripples hit the shore at very specific mathematical intervals: **90 days, 180 days, 270 days, and 360 days** later. When a ripple hits, the market usually changes direction violently.

### How to Use the Custom Features (User-Defined)

**1. The 5 Anchors (Your "Boulders")**
Instead of just tracking one boulder, the system lets you drop up to 5. 
* **How to use it:** Look at a Daily chart. Find the lowest low of last year. Make that **Anchor 1**. Find the highest high of six months ago. Make that **Anchor 2**. 
* *Layman Translation:* You are telling the system, "Hey, these two dates were super important. Show me where their future ripples are going to land."

**2. The Custom Cycles (Your "Custom Ripples")**
You already have the standard ripples (90, 180, 270, 360). But what if a specific stock, like Tesla or Reliance, has its own weird, unique rhythm? Or what if you want to use the famous "144" Fibonacci number?
* **How to use it:** Go into the settings and type `144` into Custom Cycle 1, and maybe `45` into Custom Cycle 2. 
* *Layman Translation:* You are telling the system, "I don't just want the standard ripples. I want to see a special ripple exactly 144 days after my boulder dropped."

---

### Your Step-by-Step Action Plan (How to trade it tomorrow)

Here is exactly what you do when you open TradingView:

**Step 1: Turn on the Engine**
Apply the indicator to your chart. Go to the settings.

**Step 2: Set your Anchors (The Past)**
Look back at the chart and find 2 or 3 major turning points (big V-shaped bottoms or upside-down V-shaped tops). 
* Check the box for `Use A1` and put in the date of the first bottom.
* Check the box for `Use A2` and put in the date of the top.

**Step 3: Set your Cycles (The Rhythm)**
Leave the standard 90, 180, 270, and 360 as they are. If you like a specific number (like 45 or 144), type it into the Custom slots. If you don't want custom ones, just type `0` to turn them off. 

**Step 4: Hunt for the "Time Cluster" (The Future)**
Now, look at the blank, empty space on the right side of your screen (the future). The system has drawn a bunch of vertical lines (Orange for Calendar days, Blue for Trading days). 

**THIS IS THE MOST IMPORTANT PART:**
You are looking for a spot where a line from Anchor 1 lands **right next to, or exactly on top of**, a line from Anchor 2. 

* *Example:* Let's say Anchor 1's 360-day line lands on October 15th. And Anchor 2's 180-day line lands on October 16th. 
* *What it means:* Two massive historical ripples are crashing into each other at the exact same time. 

**Step 5: How to Trade It**
When the actual date arrives (October 15th), you do not just blindly buy or sell. You watch the price action. 
* If the stock has been going up, up, up into that October 15th date... expect it to suddenly reverse and crash down. (Take profits, or prepare to Short).
* If the stock has been bleeding and crashing down into that October 15th date... expect it to suddenly find a bottom and shoot up. (Get ready to Buy).

**In short:** You use the overlapping lines to circle dates on your calendar. When that date arrives, expect the current trend to suddenly flip directions.

## Source Code

````pine
//@version=5
indicator("Gann Time Cycles Pro: Confluence [GMIS]", overlay=true, max_lines_count=500, max_labels_count=500)

// --- User Inputs ---
grp_a = "1. Cycle Anchor Points"
useA1  = input.bool(true,  title="Use A1", group=grp_a, inline="a1")
timeA1 = input.time(timestamp("2023-01-01 00:00"), title="", group=grp_a, inline="a1")

useA2  = input.bool(false, title="Use A2", group=grp_a, inline="a2")
timeA2 = input.time(timestamp("2023-03-01 00:00"), title="", group=grp_a, inline="a2")

useA3  = input.bool(false, title="Use A3", group=grp_a, inline="a3")
timeA3 = input.time(timestamp("2023-06-01 00:00"), title="", group=grp_a, inline="a3")

useA4  = input.bool(false, title="Use A4", group=grp_a, inline="a4")
timeA4 = input.time(timestamp("2023-09-01 00:00"), title="", group=grp_a, inline="a4")

useA5  = input.bool(false, title="Use A5", group=grp_a, inline="a5")
timeA5 = input.time(timestamp("2024-01-01 00:00"), title="", group=grp_a, inline="a5")

grp_cycles = "2. Cycle Lengths (Set to 0 to disable)"
c1 = input.int(90,  title="Cycle 1", group=grp_cycles)
c2 = input.int(180, title="Cycle 2", group=grp_cycles)
c3 = input.int(270, title="Cycle 3", group=grp_cycles)
c4 = input.int(360, title="Cycle 4", group=grp_cycles)
c5 = input.int(45,  title="Custom 1", group=grp_cycles)
c6 = input.int(144, title="Custom 2", group=grp_cycles)
c7 = input.int(0,   title="Custom 3", group=grp_cycles)

grp_vis = "3. Visual Settings"
showCalendar  = input.bool(true, title="Show Calendar Days?", group=grp_vis, inline="cal")
calColor      = input.color(color.orange, title="", group=grp_vis, inline="cal")
calStyleInput = input.string("Dashed", title="Style", options=["Solid", "Dashed", "Dotted"], group=grp_vis, inline="cal")

showTrading   = input.bool(true, title="Show Trading Days?  ", group=grp_vis, inline="trd")
trdColor      = input.color(color.aqua, title="", group=grp_vis, inline="trd")
trdStyleInput = input.string("Dotted", title="Style", options=["Solid", "Dashed", "Dotted"], group=grp_vis, inline="trd")

// --- Internal Data Setup ---
f_get_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

calStyle = f_get_style(calStyleInput)
trdStyle = f_get_style(trdStyleInput)

// Persistent Arrays to handle multiple anchors and 7 cycles
var int[] cycles = array.from(c1, c2, c3, c4, c5, c6, c7)
var int[] target_times = array.from(timeA1, timeA2, timeA3, timeA4, timeA5)
var bool[] use_targets = array.from(useA1, useA2, useA3, useA4, useA5)
var string[] a_names   = array.from("A1", "A2", "A3", "A4", "A5")
var bool[] a_found     = array.new_bool(5, false)

// Arrays to store future dates for Alerts
var int[] alert_cal_times = array.new_int()
var int[] alert_trd_bars  = array.new_int()

// --- Core Confluence Engine ---
// Loop through all 5 possible anchors on every bar
for j = 0 to 4
    if array.get(use_targets, j) and not array.get(a_found, j)
        tgt_time = array.get(target_times, j)
        name     = array.get(a_names, j)
        
        // Did the chart cross this anchor's date?
        if time >= tgt_time
            array.set(a_found, j, true) 
            
            // Draw the Master Anchor Line
            line.new(bar_index, low - ta.atr(14), bar_index, high + ta.atr(14), xloc=xloc.bar_index, extend=extend.both, color=color.white, style=line.style_solid, width=2)
            label.new(bar_index, high, name + " ANCHOR\n" + str.tostring(year(time)) + "-" + str.tostring(month(time)) + "-" + str.tostring(dayofmonth(time)), xloc=xloc.bar_index, yloc=yloc.abovebar, color=color.white, textcolor=color.black, style=label.style_label_down)

            // Project the Cycles for THIS specific anchor
            for i = 0 to array.size(cycles) - 1
                int c = array.get(cycles, i)

                // Skip drawing if the user set the cycle to 0
                if c > 0
                    // 1. Plot Calendar Days
                    if showCalendar
                        int futureTime = time + (c * 86400000) 
                        array.push(alert_cal_times, futureTime) 
                        
                        line.new(futureTime, low, futureTime, high, xloc=xloc.bar_time, extend=extend.both, color=calColor, style=calStyle, width=1)
                        label.new(futureTime, low, name + ": " + str.tostring(c) + " Cal", xloc=xloc.bar_time, yloc=yloc.belowbar, color=calColor, textcolor=color.white, style=label.style_label_up, size=size.small)

                    // 2. Plot Trading Days
                    if showTrading
                        int futureBar = bar_index + c 
                        array.push(alert_trd_bars, futureBar) 
                        
                        line.new(futureBar, low, futureBar, high, xloc=xloc.bar_index, extend=extend.both, color=trdColor, style=trdStyle, width=1)
                        label.new(futureBar, high, name + ": " + str.tostring(c) + " Trd", xloc=xloc.bar_index, yloc=yloc.abovebar, color=trdColor, textcolor=color.black, style=label.style_label_down, size=size.small)

// --- Alert System Logic ---
bool is_cal_hit = false
bool is_trd_hit = false

// Trigger if today's bar matches ANY anchor's Trading Day cycle
if array.includes(alert_trd_bars, bar_index)
    is_trd_hit := true

// Trigger if today's time crosses ANY anchor's Calendar Day cycle
if array.size(alert_cal_times) > 0
    for i = 0 to array.size(alert_cal_times) - 1
        a_time = array.get(alert_cal_times, i)
        if time >= a_time and time[1] < a_time
            is_cal_hit := true

// Alert Conditions for TradingView
alertcondition(is_trd_hit, title="Trading Cycle Confluence Hit!", message="Alert: A GMIS Trading Day cycle has been reached today.")
alertcondition(is_cal_hit, title="Calendar Cycle Confluence Hit!", message="Alert: A GMIS Calendar Day cycle has been reached today.")
````
