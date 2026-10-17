# EMA Ride Scanner

- url: https://www.tradingview.com/script/KBNOjAIS-EMA-Ride-Scanner/
- type: indicator
- pine_id: PUB;a4318acda8f24148905bb177b18f112e
- version: 1.0

## Description

Long term riders of EMA 9 / EMA 21. Buying opportunity on pullback to these EMAs

## Source Code

````pine
//@version=6
indicator("EMA Ride Scanner", shorttitle="EMA_RIDE", overlay=false)

// ═══════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════
grp1 = "EMA Settings"
len9  = input.int(9,  "EMA9",  group=grp1)
len21 = input.int(21, "EMA21", group=grp1)
len50 = input.int(50, "EMA50", group=grp1)

grp2 = "Ride Filters"
min_weeks    = input.int(8,     "Min Weeks Riding EMA21",           group=grp2)
dip_pct      = input.float(3.0, "Entry Dip Zone % (above EMA9)",    group=grp2)
min_bounces  = input.int(2,     "Min Cloud Bounces (90 bars)",       group=grp2)
min_pct_ema9 = input.float(75.0,"Min % bars above EMA9 (60 bars)",  group=grp2)

// ═══════════════════════════════════════════
// CORE CALCULATIONS
// ═══════════════════════════════════════════
ema9  = ta.ema(close, len9)
ema21 = ta.ema(close, len21)
ema50 = ta.ema(close, len50)

// EMA Stack
stack = ema9 > ema21 and ema21 > ema50

// Metric 1: Consecutive closes above EMA21 (hard floor)
var int bars_ema21 = 0
bars_ema21 := close > ema21 ? bars_ema21 + 1 : 0

// Metric 2: % of last 60 bars where close > EMA9
ema9_above_60  = math.sum(close > ema9 ? 1 : 0, 60)
ema9_pct_above = ema9_above_60 / 60.0 * 100

// Metric 3: Cloud bounce episodes in last 90 bars
cloud_tested   = low   <= ema21 * 1.02
cloud_bounced  = close >  ema9
genuine_bounce = cloud_tested and cloud_bounced
bounces_90     = math.sum(genuine_bounce ? 1 : 0, 90)

// Metric 4: Distance from EMAs
dist_ema9  = (close - ema9)  / ema9  * 100
dist_ema21 = (close - ema21) / ema21 * 100

at_ema9_dip  = dist_ema9  >= 0 and dist_ema9  <= dip_pct
at_ema21_dip = dist_ema21 >= 0 and dist_ema21 <= 5.0

// Metric 5: EMA9 slope upward
ema9_rising = ema9 > ema9[3]

// Convert weeks to bars
min_bars = min_weeks * 5

// ═══════════════════════════════════════════
// SIGNALS — using intermediate variables
// to avoid line continuation syntax errors
// ═══════════════════════════════════════════

// Long established ride (8+ weeks)
_l1 = bars_ema21 >= min_bars
_l2 = ema9_pct_above >= min_pct_ema9
_l3 = bounces_90 >= min_bounces
long_ride = _l1 and _l2 and _l3 and stack

// Medium ride (4+ weeks)
_m1 = bars_ema21 >= min_bars / 2
_m2 = ema9_pct_above >= 65.0
medium_ride = _m1 and _m2 and stack

// At EMA9 dip entry NOW
_d1 = at_ema9_dip
_d2 = bars_ema21 >= min_bars
_d3 = bounces_90 >= min_bounces
at_dip_entry = _d1 and _d2 and _d3 and stack and ema9_rising

// At EMA21 deep dip entry
_dd1 = at_ema21_dip
_dd2 = bars_ema21 >= min_bars
at_deep_dip = _dd1 and _dd2 and stack

// ═══════════════════════════════════════════
// SCREENER OUTPUTS
// ═══════════════════════════════════════════
plot(bars_ema21,             title="Weeks Riding EMA21 (bars)")
plot(ema9_pct_above,         title="EMA9 % Above (60 bars)")
plot(bounces_90,             title="Cloud Bounces (90 bars)")
plot(dist_ema9,              title="Distance from EMA9 %")
plot(long_ride   ? 1 : 0,   title="Long Ride (8+ weeks)")
plot(medium_ride ? 1 : 0,   title="Medium Ride (4+ weeks)")
plot(at_dip_entry ? 1 : 0,  title="At EMA9 Dip Entry")
plot(at_deep_dip  ? 1 : 0,  title="At EMA21 Deep Dip")
plot(stack        ? 1 : 0,  title="EMA Stack Aligned")
plot(bounces_90,             title="Historical Bounces")
````
