# Session Breakout & Reversal iFVG v10 (CSD Filter)

- url: https://www.tradingview.com/script/TdB1hOqp-Session-Breakout-Reversal-iFVG-v10-CSD-Filter/
- type: indicator
- pine_id: PUB;6143746247394a23915485b2ccc293a8
- version: 1.0

## Description

This indicator is designed specifically for futures and index traders looking to capitalize on liquidity sweeps and session reversals. By combining Session Ranges, Liquidity Sweeps, Inverse Fair Value Gaps (iFVG), and a Change in State of Delivery (CSD) filter, the script systematically identifies high-probability reversal setups.

Instead of trading standard continuation breakouts, this strategy assumes that initial session breakouts are often liquidity grabs. It waits for the false breakout to occur, confirms the reversal via an iFVG, and plots exact entry signals.

Core Methodology & Trade Logic
The indicator operates using a strict step-by-step logic:

Session Range Building: The script plots high/low boxes during user-defined timeframes (e.g., Asian Session, London Session). Note: The time inputs are strictly mathematically locked to New York (EST/EDT) time to prevent common TradingView local timezone bugs.

The Sweep (Liquidity Grab): Once the session ends, the script waits for the price to break the defined range.

Upward Sweep: Price takes the buy-side liquidity above the session box.

Downward Sweep: Price takes the sell-side liquidity below the session box.

The Reversal & iFVG Entry: * If price sweeps the High, the indicator looks for a reversal. It tracks Bullish FVGs and waits for the price to break and close below one, turning it into a Bearish iFVG. This triggers a Short signal.

If price sweeps the Low, the indicator tracks Bearish FVGs and waits for the price to break and close above one, turning it into a Bullish iFVG. This triggers a Long signal.

Invalidation: Only one trade is permitted per session range. If an iFVG setup does not trigger before the next defined session begins, the current setup is invalidated.

Key Features & Customizable Settings

Bulletproof NY Time Inputs: Set your start and end hours/minutes using raw numerical values mapped strictly to the America/New_York timezone.

Breakout Logic (Sweep vs. Close): You can toggle whether a simple wick (Sweep) past the session range is enough to trigger the setup phase, or if a full candle Close is required.

iFVG Minimum Size: Filter out market noise by setting a minimum size (in points) for a Fair Value Gap to be considered valid for the reversal.

CSD Filter (Change in State of Delivery): An optional risk-management toggle. If enabled, the script tracks Market Structure Shifts using fractal pivot swings. If a CSD occurs before your iFVG entry is triggered, the setup is deemed compromised and the trade is cancelled. You can adjust the Swing Length for the CSD tracking.

How to Read the Chart

Blue Box: Asian Session Range.

Orange Box: London Session Range.

Green Triangle (Below Bar): Long Reversal Entry confirmed via Bullish iFVG.

Red Triangle (Above Bar): Short Reversal Entry confirmed via Bearish iFVG.

## Source Code

````pine
//@version=6
indicator("Session Breakout & Reversal iFVG v10 (CSD Filter)", overlay=true, max_boxes_count=50)

// --- SETTINGS: NUMERIC TIME INPUTS (NEW YORK TIME) ---
grp_asia = "Asian Session (NY Time)"
asia_sh = input.int(1,  "Start (Hour)",  minval=0, maxval=23, group=grp_asia)
asia_sm = input.int(12, "Start (Min)",    minval=0, maxval=59, group=grp_asia)
asia_eh = input.int(2,  "End (Hour)", minval=0, maxval=23, group=grp_asia)
asia_em = input.int(12, "End (Min)",   minval=0, maxval=59, group=grp_asia)

grp_lon = "London Session (NY Time)"
lon_sh = input.int(9,  "Start (Hour)",  minval=0, maxval=23, group=grp_lon)
lon_sm = input.int(0,  "Start (Min)",    minval=0, maxval=59, group=grp_lon)
lon_eh = input.int(10, "End (Hour)", minval=0, maxval=23, group=grp_lon)
lon_em = input.int(0,  "End (Min)",   minval=0, maxval=59, group=grp_lon)

grp_fvg = "iFVG Filters"
ifvg_min = input.float(2.0, "iFVG Minimum Size (Points)", step=0.25, group=grp_fvg)

grp_logic = "Breakout Logic"
use_sweep = input.bool(true, "Use Sweep (Wick is enough)", group=grp_logic, tooltip="If checked, only the candle High/Low needs to break the session range. If unchecked, a candle Close outside the range is required.")

// --- NEW SETTING: CSD FILTER ---
grp_csd = "CSD Filter"
use_csd = input.bool(true, "Enable CSD Filter", group=grp_csd, tooltip="If a Change in State of Delivery (CSD) occurs before the entry is triggered, the trade will be cancelled.")
csd_length = input.int(5, "CSD Swing Length", minval=1, group=grp_csd, tooltip="Number of bars used to define the Swing High/Low for the CSD check.")

// --- TIME CHECK (Forced to New York Time) ---
curr_h = hour(time, "America/New_York")
curr_m = minute(time, "America/New_York")
curr_mins = curr_h * 60 + curr_m

f_in_session(sh, sm, eh, em) =>
    start_m = sh * 60 + sm
    end_m   = eh * 60 + em
    is_in = start_m <= end_m ? (curr_mins >= start_m and curr_mins <= end_m) : (curr_mins >= start_m or curr_mins <= end_m)
    is_in

in_asia = f_in_session(asia_sh, asia_sm, asia_eh, asia_em)
in_lon  = f_in_session(lon_sh, lon_sm, lon_eh, lon_em)

// --- FVG TRACKING ---
var float bull_hi = na
var float bull_lo = na
var float bear_hi = na
var float bear_lo = na

if bar_index >= 2
    if low > high[2] and (low - high[2]) >= ifvg_min
        bull_hi := low
        bull_lo := high[2]
    if high < low[2] and (low[2] - high) >= ifvg_min
        bear_hi := low[2]
        bear_lo := high

// --- CSD TRACKING ---
var float last_swing_hi = na
var float last_swing_lo = na
var bool bear_csd_occurred = false
var bool bull_csd_occurred = false

sw_hi = ta.pivothigh(high, csd_length, csd_length)
sw_lo = ta.pivotlow(low, csd_length, csd_length)

if not na(sw_hi)
    last_swing_hi := sw_hi
if not na(sw_lo)
    last_swing_lo := sw_lo

// Reset CSD states on session start
var bool was_in_asia = false
bool asia_start = in_asia and not was_in_asia
bool asia_end   = not in_asia and was_in_asia
was_in_asia := in_asia 

var bool was_in_lon = false
bool lon_start = in_lon and not was_in_lon
bool lon_end   = not in_lon and was_in_lon
was_in_lon := in_lon

if asia_start or lon_start
    bear_csd_occurred := false
    bull_csd_occurred := false

// Trigger CSD if price closes past recent swing
if not na(last_swing_lo) and close < last_swing_lo
    bear_csd_occurred := true
if not na(last_swing_hi) and close > last_swing_hi
    bull_csd_occurred := true


// --- ASIAN SESSION STATE TRACKING ---
var float asia_hi = na
var float asia_lo = na
var int asia_state = 0
var box asia_box = na

if asia_start
    asia_hi := high
    asia_lo := low
    asia_state := 0
    bull_hi := na
    bear_hi := na
    asia_box := box.new(bar_index, high, bar_index, low, border_color=color.blue, bgcolor=color.new(color.blue, 90))

if in_asia
    if na(asia_hi)
        asia_hi := high
        asia_lo := low
    else
        asia_hi := math.max(asia_hi, high)
        asia_lo := math.min(asia_lo, low)
        
    if not na(asia_box)
        box.set_top(asia_box, asia_hi)
        box.set_bottom(asia_box, asia_lo)
        box.set_right(asia_box, bar_index)

if asia_end
    asia_state := 1

if asia_state == 1
    if use_sweep ? high > asia_hi : close > asia_hi
        asia_state := 2 // Breakout UP
    else if use_sweep ? low < asia_lo : close < asia_lo
        asia_state := -2 // Breakout DOWN

// --- LONDON SESSION STATE TRACKING ---
var float lon_hi = na
var float lon_lo = na
var int lon_state = 0
var box lon_box = na

if lon_start
    lon_hi := high
    lon_lo := low
    lon_state := 0
    bull_hi := na
    bear_hi := na
    lon_box := box.new(bar_index, high, bar_index, low, border_color=color.orange, bgcolor=color.new(color.orange, 90))

if in_lon
    if na(lon_hi)
        lon_hi := high
        lon_lo := low
    else
        lon_hi := math.max(lon_hi, high)
        lon_lo := math.min(lon_lo, low)
        
    if not na(lon_box)
        box.set_top(lon_box, lon_hi)
        box.set_bottom(lon_box, lon_lo)
        box.set_right(lon_box, bar_index)

if lon_end
    lon_state := 1

if lon_state == 1
    if use_sweep ? high > lon_hi : close > lon_hi
        lon_state := 2 // Breakout UP
    else if use_sweep ? low < lon_lo : close < lon_lo
        lon_state := -2 // Breakout DOWN

// --- INVALIDATION ---
if lon_start and (asia_state == 1 or asia_state == 2 or asia_state == -2)
    asia_state := 3

// --- SIGNALS (REVERSAL LOGIC WITH CSD FILTER) ---
bool do_long = false
bool do_short = false

// Asia Up-breakout/sweep -> Look for SHORT (Break Bull FVG downwards)
if asia_state == 2 and not na(bull_lo) and close < bull_lo
    if not (use_csd and bear_csd_occurred[1])
        do_short := true
    asia_state := 3

// Asia Down-breakout/sweep -> Look for LONG (Break Bear FVG upwards)
if asia_state == -2 and not na(bear_hi) and close > bear_hi
    if not (use_csd and bull_csd_occurred[1])
        do_long := true
    asia_state := 3

// London Up-breakout/sweep -> Look for SHORT
if lon_state == 2 and not na(bull_lo) and close < bull_lo
    if not (use_csd and bear_csd_occurred[1])
        do_short := true
    lon_state := 3

// London Down-breakout/sweep -> Look for LONG
if lon_state == -2 and not na(bear_hi) and close > bear_hi
    if not (use_csd and bull_csd_occurred[1])
        do_long := true
    lon_state := 3

// --- VISUALIZATION ---
plotshape(do_long, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small, title="Long Reversal")
plotshape(do_short, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small, title="Short Reversal")

alertcondition(do_long, title="Long Reversal Setup", message="Reversal Long Setup Confirmed!")
alertcondition(do_short, title="Short Reversal Setup", message="Reversal Short Setup Confirmed!")
````
