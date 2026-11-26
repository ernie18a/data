# ORB Breakout

- url: https://www.tradingview.com/script/KWfBq6HU-ORB-Breakout/
- type: indicator
- pine_id: PUB;8121a98dbdc54493a47e299f3c47f9fc
- version: 1.0

## Description

What it does:
Identifies high-probability opening range breakout AND breakdown setups. Detects when price breaks above OR High (long) or below OR Low (short) with confirming conditions. Fires once per day per direction, independently.

---

Opening Range
The first candle(s) after the 9:30 ET open define the range:
1m chart → OR = the single 9:30 bar
5m chart → OR = the 9:30–9:34 bar

Three levels are plotted from the OR:
🟠 OR High — breakout trigger level
🟣 OR Low — breakdown trigger level
⚪ OR Midpoint (50%) — equilibrium level (toggleable)

All three use plot.style_linebr — appear as named rows in TV's Style tab with full color/thickness control.

---

Breakout Signal — all 4 must be true
Body closes above OR High
Volume ≥ 1.5× OR avg volume (adjustable)
Price above VWAP
Within signal window (9:31–11:30 ET on 1m / 9:35–11:30 ET on 5m)

→ 🟢 Green background + orange bar + ORB↑ label below bar

---

Breakdown Signal — all 4 must be true
Body closes below OR Low
Volume ≥ 1.5× OR avg volume
Price below VWAP
Within signal window

→ 🔴 Red background + red bar + ORB↓ label above bar

---

Alerts
Two separate alert condition entries — set them independently in TV:
ORB Breakout — fires on bullish break
ORB Breakdown — fires on bearish break

Both fire once per day max, even if conditions reset.

---
Designed for
Pre-open stock selection + early session execution. Works alongside SIP/EP workflow — stocks already identified pre-market, watching for the break in either direction at the open.

## Source Code

````pine


//@version=6
indicator("ORB Breakout", overlay=true, max_lines_count=100, max_labels_count=100)

// INPUTS
vol_mult  = input.float(1.5, "Volume Multiplier (vs OR avg)", minval=1.0, step=0.1)
show_vwap = input.bool(true, "Show VWAP Line")
show_eq   = input.bool(true, "Show 50% Equilibrium Line")

// TIME — Eastern
et_hour = hour(time, "America/New_York")
et_min  = minute(time, "America/New_York")
et_hhmm = et_hour * 100 + et_min

// TIMEFRAME-AWARE OR WINDOW
// 1m chart → OR = 9:30 bar only (1 bar)
// 5m chart → OR = 9:30–9:34 (1 bar / 5 mins)
// Other TFs fall back to 5m window
is_1m = timeframe.period == "1"
in_or_window  = is_1m ? (et_hhmm == 930) : (et_hhmm >= 930 and et_hhmm <= 934)
lock_trigger  = is_1m ? (et_hhmm >= 931)  : (et_hhmm >= 935)
in_sig_window = is_1m ? (et_hhmm >= 931 and et_hhmm < 1130) : (et_hhmm >= 935 and et_hhmm < 1130)

// Only build OR during regular session — prevents pre-market bars polluting the range
in_regular = session.ismarket

// NEW DAY
date_int = year * 10000 + month * 100 + dayofmonth
new_day  = ta.change(date_int) != 0

// STATE
var float or_high      = na
var float or_low       = na
var float or_mid       = na
var float or_vol_sum   = 0.0
var int   or_bar_count = 0
var bool  or_locked    = false
var float or_avg_vol   = na
var bool  alerted_today = false
var bool  breakdown_alerted_today = false

if new_day
    or_high       := na
    or_low        := na
    or_mid        := na
    or_vol_sum    := 0.0
    or_bar_count  := 0
    or_locked     := false
    or_avg_vol    := na
    alerted_today := false
    breakdown_alerted_today := false

if in_or_window and in_regular
    or_high      := na(or_high) ? high : math.max(or_high, high)
    or_low       := na(or_low)  ? low  : math.min(or_low, low)
    or_vol_sum   += volume
    or_bar_count += 1

if not or_locked and lock_trigger and not na(or_high)
    or_avg_vol := or_bar_count > 0 ? or_vol_sum / or_bar_count : na
    or_mid     := (or_high + or_low) / 2
    or_locked  := true

// PLOTS
or_visible = (in_or_window or (or_locked and in_sig_window)) and not na(or_high)

display_mid = in_or_window and not na(or_high) and not na(or_low) ? (or_high + or_low) / 2 :
              or_locked and in_sig_window and not na(or_mid) ? or_mid : na

plot(or_visible ? or_high : na, title="OR High",          color=color.new(color.orange, 0),  linewidth=2, style=plot.style_linebr)
plot(or_visible ? or_low  : na, title="OR Low",           color=color.new(color.fuchsia, 0), linewidth=2, style=plot.style_linebr)
plot(show_eq ? display_mid : na, title="OR Midpoint (50%)", color=color.new(color.gray, 40),   linewidth=1, style=plot.style_linebr)

vwap_val = ta.vwap
plot(show_vwap ? vwap_val : na, title="VWAP", color=color.new(color.blue, 0), linewidth=1)

// SIGNAL
cond_body_break = or_locked and not na(or_high) and close > or_high
cond_volume     = or_locked and not na(or_avg_vol) and volume >= vol_mult * or_avg_vol
cond_vwap       = not na(vwap_val) and close > vwap_val
cond_time       = in_sig_window
all_met = cond_body_break and cond_volume and cond_vwap and cond_time and not alerted_today

if all_met
    alerted_today := true

// BREAKDOWN SIGNAL
cond_body_break_down = or_locked and not na(or_low) and close < or_low
cond_volume_down     = or_locked and not na(or_avg_vol) and volume >= vol_mult * or_avg_vol
cond_vwap_down       = not na(vwap_val) and close < vwap_val
all_met_down = cond_body_break_down and cond_volume_down and cond_vwap_down and cond_time and not breakdown_alerted_today

if all_met_down
    breakdown_alerted_today := true

// VISUALS
bgcolor(all_met      ? color.new(color.green, 80) : na, title="Breakout Background")
bgcolor(all_met_down ? color.new(color.red,   80) : na, title="Breakdown Background")
barcolor(all_met      ? color.orange : all_met_down ? color.red : na, title="Signal Candle")
plotshape(all_met,      title="ORB Breakout Signal",  style=shape.triangleup,   location=location.belowbar, color=color.new(color.orange, 0), size=size.normal, text="ORB↑")
plotshape(all_met_down, title="ORB Breakdown Signal", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,    0), size=size.normal, text="ORB↓")

// ALERTS
alertcondition(all_met,      title="ORB Breakout",  message="ORB BREAKOUT  - Symbol: {{ticker}} | Price: {{close}} | Time: {{time}}")
alertcondition(all_met_down, title="ORB Breakdown", message="ORB BREAKDOWN - Symbol: {{ticker}} | Price: {{close}} | Time: {{time}}")
````
