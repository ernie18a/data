<!-- tradingview-pine-id: PUB;addf438e168444a393a78c8c62babbcc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# ICT Session FVGs [50% Mitigated]

Source: https://www.tradingview.com/script/7u1GreWQ-ICT-Session-FVGs-50-Mitigated/

## Description

This TradingView Pine Script (Version 5) is an overlay indicator designed for traders who use **Inner Circle Trader (ICT)** concepts. It automatically detects and highlights **Fair Value Gaps (FVGs)** that form during specific trading sessions (Killzones) and tracks them until price "mitigates" (fills) them to the 50% level.

Here is a breakdown of exactly how the script works under the hood:

### 1. User Inputs & Constraints

* **Session Toggles:** You can choose to highlight FVGs formed during the **Asia Killzone** (8:00 PM - 12:00 AM EST) and/or the **London Killzone** (2:00 AM - 5:00 AM EST).
* **Performance Lookback:** It only scans for and draws FVGs over the last X days (default is 5). Limiting historical data prevents the chart from lagging.
* **Visuals:** Allows customization of colors for Bullish (green) and Bearish (red) gaps.

### 2. Time Logic Filtering

The script hardcodes the timezone to `America/New_York` (EST). It checks every candle on the chart to see if it falls within the specified Asia or London time windows. If a candle is outside these windows (or outside the 5-day lookback limit), the script will ignore any FVGs that form.

### 3. FVG Detection (The 3-Bar Pattern)

When the active time zones are met, the script looks for the classic 3-candle FVG pattern using an array of custom data objects (`type FVG`):

* **Bullish FVG:** It triggers if the current candle's `low` is higher than the `high` of two candles ago. This leaves an empty gap where only buyers were present.
* **Bearish FVG:** It triggers if the current candle's `high` is lower than the `low` of two candles ago, leaving a gap where only sellers were present.

When a gap is found, the script calculates the exact top, bottom, and **midpoint (50% level)** of the gap, draws a colored box starting from the gap candle, and saves all this data into an array to be tracked.

### 4. Mitigation & 12 PM Cutoff Logic

This is the most dynamic part of the script. On every new candle, the script loops through all previously drawn, active FVGs to see what price is doing to them:

* **The 50% Mitigation Rule:** The script considers a gap "mitigated" (resolved) only when the price pierces the **50% midline** of the box.
* If a bullish gap's midline is hit by a candle's low, or a bearish gap's midline is hit by a candle's high, the gap is marked `mitigated = true`.
* The script then permanently locks the right side of the box to that specific candle, showing exactly where the gap was filled.

* **The Time Cutoff Rule:** If a gap has *not* been mitigated, the script will extend the box to the right so it stays visible on the chart. **However**, it stops extending unmitigated boxes at **12:00 PM (Noon) NY time**. It resumes extending them at 8:00 PM. This mimics the ICT concept of disregarding morning session unmitigated zones once the lunch hour hits.

---

## Source Code

````pine
//@version=6
indicator('ICT Session FVGs [50% Mitigated]', overlay = true, max_boxes_count = 500)

// ==========================================
// INPUTS & SETTINGS
// ==========================================
grp_sessions = 'Killzone Toggles (EST/NY Time)'
show_asia = input.bool(true, 'Highlight Asia FVG (20:00-00:00)', group = grp_sessions)
show_london = input.bool(true, 'Highlight London FVG (02:00-05:00)', group = grp_sessions)

grp_lookback = 'Performance & Lookback'
lookback_days = input.int(5, 'Lookback (Days)', minval = 1, maxval = 20, group = grp_lookback, tooltip = 'Max 20 days to keep chart loading fast.')

grp_style = 'Box Styling'
bull_color = input.color(color.new(color.green, 85), 'Bullish FVG', group = grp_style)
bear_color = input.color(color.new(color.red, 85), 'Bearish FVG', group = grp_style)

// ==========================================
// TIME LOGIC & FILTERS
// ==========================================
tz = 'America/New_York'

// Time zone checks (TradingView handles the daily resets automatically with these time ranges)
in_asia = show_asia and not na(time(timeframe.period, '2000-0000', tz))
in_london = show_london and not na(time(timeframe.period, '0200-0500', tz))
in_active_zone = in_asia or in_london

// Lookback limit calculation
ms_per_day = 1000 * 60 * 60 * 24
is_in_lookback = timenow - time <= lookback_days * ms_per_day

// ==========================================
// CUSTOM FVG DATA TYPE
// ==========================================
type FVG
	float top
	float bottom
	float mid
	bool isBullish
	bool mitigated
	box b

var array<FVG> fvg_array = array.new<FVG>()

// ==========================================
// FVG DETECTION
// ==========================================
if is_in_lookback and in_active_zone
    // Bullish FVG Detection
    if low > high[2]
        top = low
        bottom = high[2]
        mid = (top + bottom) / 2
        bx = box.new(left = bar_index[1], top = top, right = bar_index, bottom = bottom, border_color = color.new(bull_color, 100), bgcolor = bull_color)
        array.push(fvg_array, FVG.new(top, bottom, mid, true, false, bx))

    // Bearish FVG Detection
    if high < low[2]
        top = low[2]
        bottom = high
        mid = (top + bottom) / 2
        bx = box.new(left = bar_index[1], top = top, right = bar_index, bottom = bottom, border_color = color.new(bear_color, 100), bgcolor = bear_color)
        array.push(fvg_array, FVG.new(top, bottom, mid, false, false, bx))

// ==========================================
// MITIGATION & 12 PM CUTOFF LOGIC
// ==========================================
if array.size(fvg_array) > 0
    for i = array.size(fvg_array) - 1 to 0 by 1
        fvg = array.get(fvg_array, i)

        if not fvg.mitigated
            // Check for 50% Mitigation (Price crosses the midline)
            if fvg.isBullish and low <= fvg.mid or not fvg.isBullish and high >= fvg.mid
                fvg.mitigated := true
                box.set_right(fvg.b, bar_index) // Lock the box at the mitigation candle
            // Extend the box ONLY if it is before 12:00 PM NY time
            else // (Or during the evening Asia session for the next day's cycle)
                h = hour(time, tz)
                if h < 12 or h >= 20
                    box.set_right(fvg.b, bar_index)
````
