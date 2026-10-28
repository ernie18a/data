# PDL/PDH, VWAP break and retest strategy.

- url: https://www.tradingview.com/script/mekE7VJG-PDL-PDH-VWAP-break-and-retest-strategy/
- type: indicator
- pine_id: PUB;4015fa24d8544afaa1ba8d750a587796
- version: 1.0

## Description

script for a break and retest of the premarket low and premarket high for names in the nasdaq

## Source Code

````pine
//@version=5
indicator("Pre-Market & PDL/VWAP Options Scalper V6 (Alerts)", overlay=true, max_labels_count=500)

// --- 1. USER SETTINGS ---
vol_ma_length   = input.int(10, "Volume MA Length for Confirmation")
retest_pct      = input.float(0.12, "Retest Buffer Precision (%)", step=0.01)

// --- 2. PRE-MARKET & INTRADAY SESSION ENGINE ---
in_premarket = not na(time(timeframe.period, "0200-0730:23456", "America/Denver"))
in_regular   = not na(time(timeframe.period, "0730-1400:23456", "America/Denver"))
is_new_day   = ta.change(time("D", "America/Denver"))

var float pm_high = na
var float pm_low  = na
var float day_pmh = na
var float day_pml = na
var float hod = na
var float lod = na

if is_new_day
    pm_high := high
    pm_low  := low
    hod     := na
    lod     := na
else if in_premarket
    pm_high := math.max(high, na(pm_high) ? high : pm_high)
    pm_low  := math.min(low,  na(pm_low)  ? low  : pm_low)

if ta.change(in_premarket) and not in_premarket
    day_pmh := pm_high
    day_pml := pm_low

if in_regular
    hod := na(hod) ? high : math.max(high, hod)
    lod := na(lod) ? low  : math.min(low, lod)

pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

// --- 3. HARDTIME LOCK WINDOWS ---
in_entry_window = not na(time(timeframe.period, "0730-0830:23456", "America/Denver"))

// --- 4. BREAKOUT STATE MACHINE TRACKER ---
var int breakout_state = 0 
var int breakout_bar_idx = 0

if ta.change(in_premarket) and not in_premarket
    breakout_state := 0

if not in_premarket and breakout_state == 0
    if close > day_pmh
        breakout_state := 1
        breakout_bar_idx := bar_index
    else if close < day_pml
        breakout_state := -1
        breakout_bar_idx := bar_index

// --- 5. TECHNICAL CONFIRMATION FILTERS ---
buffer_zone   = close * (retest_pct / 100)
chart_ema     = ta.ema(close, 9)
current_vwap  = ta.vwap
vol_confirmed = volume > ta.sma(volume, vol_ma_length)

is_retest_bar = (bar_index > breakout_bar_idx)

at_pmh_retest  = (breakout_state == 1)  and is_retest_bar and (math.abs(low - day_pmh) <= buffer_zone) and (close >= day_pmh)
at_pml_retest  = (breakout_state == -1) and is_retest_bar and (math.abs(high - day_pml) <= buffer_zone) and (close <= day_pml)
at_pdh_retest  = (breakout_state == 1)  and is_retest_bar and (math.abs(low - pdh) <= buffer_zone) and (close >= pdh)
at_pdl_retest  = (breakout_state == -1) and is_retest_bar and (math.abs(high - pdl) <= buffer_zone) and (close <= pdl)
at_vwap_retest = (breakout_state == -1) and is_retest_bar and (math.abs(high - current_vwap) <= buffer_zone) and (close <= current_vwap)

vwap_long_allowed  = (close > current_vwap)
vwap_short_allowed = (close < current_vwap)

// --- 6. TRIGGER LOGIC & TARGET EVALUATION ---
long_trigger  = (at_pmh_retest or at_pdh_retest) and (close > chart_ema) and vwap_long_allowed and vol_confirmed and in_entry_window
short_trigger = (at_pml_retest or at_pdl_retest or at_vwap_retest) and (close < chart_ema) and vwap_short_allowed and vol_confirmed and in_entry_window

// Calculate targets dynamically for the alert strings
float valid_hod = na(hod) ? high : hod
float valid_lod = na(lod) ? low : lod
float dynamic_long_tp  = math.abs(valid_hod - close) < math.abs(pdh - close) ? valid_hod : pdh
float dynamic_short_tp = math.abs(valid_lod - close) < math.abs(pdl - close) ? valid_lod : pdl

// --- 7. VISUAL SIGNALS AND CODES ---
plotshape(long_trigger, title="Long Radar Hit", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.small)
plotshape(short_trigger, title="Short Radar Hit", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// --- 8. SIMPLIFIED TEXT ALERT CHANNELS ---
if long_trigger
    alert("SCALPER LONG: " + syminfo.ticker + " @ " + str.tostring(close) + " | TP Target: " + str.tostring(dynamic_long_tp), alert.freq_once_per_bar)

if short_trigger
    alert("SCALPER SHORT: " + syminfo.ticker + " @ " + str.tostring(close) + " | TP Target: " + str.tostring(dynamic_short_tp), alert.freq_once_per_bar)
````
