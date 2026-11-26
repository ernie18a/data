# EMA Ride Scanner V2.a (Toggle) - Ashish

- url: https://www.tradingview.com/script/mqIrbv3y-EMA-Ride-Scanner-V2-a-Toggle-Ashish/
- type: indicator
- pine_id: PUB;794c0cf3c8304de6a23a3b770a252ee9
- version: 1.0

## Description

Short Description
A dual-mode EMA9/21/50 trend-ride scanner with volume classification and a relative-strength "Grinder Mode" for stocks that trend without ever coiling tight enough to trigger a squeeze. Use alongside its companion, SQZ_SCAN, for momentum timing.

What it does
EMA Ride Scanner V2.a finds stocks in a clean, established uptrend and flags healthy pullback zones to buy — instead of chasing breakouts after the move has happened. Built on ideas from Qullamaggie's Episodic Pivot framework, Stockbee's price-neglect filter, and VCPSwing's 10/20-MA ride philosophy.
It checks: EMA9>21>50 stack alignment, minimum ride duration, distance from 52-week low, and volatility contraction. Volume bars are color-coded as EP surges, distribution, or healthy dips.

Two modes (single toggle)
Standard Mode (toggle OFF) — for stocks that coil and release. Flags a 0-5% pullback to EMA9, ideally on light volume. Pair with SQZ_SCAN for the breakout-timing signal.
Grinder Mode (toggle ON) — for stocks that never coil. Some strong trends have such low, steady volatility that they never compress enough to trigger a squeeze — by the time SQZ_SCAN fires, they've already run too far from EMA9 to count as a dip. Grinder Mode drops the squeeze requirement and instead checks: low ATR, long ride above EMA21, and meaningful outperformance vs a benchmark index (momentum begets momentum). If price is also near EMA9/21, it flags a Grinder Setup.

Note: cloud-bounce count is shown for visual reference only, not used as a filter — low-ATR stocks often show very few bounces simply because they ride EMA9 continuously rather than dipping and recovering.

Companion: SQZ_SCAN
SQZ_SCAN shows when volatility compression releases into a confirmed move — WATCH (squeeze building), EARLY FIRE (just released), or BUY (released + volume confirmed). NOTE: As with most indicators, this is a lagging indicator on a daily timeframe, and accuracy reduces significantly on lower timeframes.

Workflow:
Screen with EMA Ride Scanner (Standard Mode) for clean pullback candidates.
Check SQZ_SCAN on each — prioritize WATCH/EARLY FIRE/BUY.
Separately, screen Grinder Mode for low-volatility names — don't require SQZ confirmation here, it structurally won't fire for this archetype.
Sanity-check on hourly before entry — only to rule out an active breakdown, not as a hard gate. Both indicators are daily-timeframe tools; hourly readings are noisy and shouldn't override a valid daily setup.

What this isn't
A screening tool, not a full trading system — no buy/sell signals, no risk management built in. Combine with your own entry timing, sizing, and stops.

## Source Code

````pine
//@version=6
indicator("EMA Ride Scanner V2.a (Toggle)", overlay=true)

grinder_mode = input.bool(false, "Enable Grinder Mode (V2.a) — OFF = standard V2 / SQZ logic")

ema9_len   = input.int(9,   "EMA 9")
ema21_len  = input.int(21,  "EMA 21")
ema50_len  = input.int(50,  "EMA 50")
atr_len    = input.int(14,  "ATR")
ride_bars  = input.int(4,   "Min Ride Bars (Medium) weeks")
long_bars  = input.int(8,   "Min Ride Bars (Long) weeks")
bounce_len = input.int(90,  "Cloud Bounce Lookback")
ema9_look  = input.int(60,  "EMA9 Above Lookback")
atr_min    = input.float(3.0,  "Min ATR%")
low52_min  = input.float(50.0, "Min % Above 52W Low")

vol_ma_len    = input.int(50,    "Volume MA Length")
ep_vol_mult   = input.float(3.0, "EP Surge Multiplier")
dist_vol_mult = input.float(2.0, "Distribution Multiplier")
dip_vol_mult  = input.float(0.5, "Healthy Dip Threshold")

grinder_atr_max      = input.float(4.0,  "Grinder: Max ATR%")
grinder_bounce_min   = input.int(10,     "Grinder: Min Cloud Bounces (informational only, not a gate)")
grinder_ride_min     = input.int(40,     "Grinder: Min Ride Days")
grinder_outperf_min  = input.float(6.0,  "Grinder: Min Outperformance vs Benchmark % (1mo)")
grinder_outperf_look = input.int(22,     "Grinder: Outperformance Lookback (days)")
bench_sym            = input.symbol("NSE:NIFTYMIDSML400", "Benchmark Symbol")

ema9  = ta.ema(close, ema9_len)
ema21 = ta.ema(close, ema21_len)
ema50 = ta.ema(close, ema50_len)

stack_aligned = ema9 > ema21 and ema21 > ema50

above_ema21 = close > ema21
ride_count  = 0
for i = 0 to 500
    if above_ema21[i]
        ride_count += 1
    else
        break

cloud_bounces = 0
for i = 1 to bounce_len
    if close[i] <= ema9[i] * 1.01 and close[i] > ema21[i] and close[i-1] > ema9[i-1]
        cloud_bounces += 1

ema9_above_count = 0
for i = 0 to ema9_look - 1
    if close[i] > ema9[i]
        ema9_above_count += 1
ema9_pct = (ema9_above_count / ema9_look) * 100

dist_ema9  = ((close - ema9) / ema9) * 100
atr_pct    = (ta.atr(atr_len) / close) * 100
low52      = ta.lowest(low, 252)
above_52wl = ((close - low52) / low52) * 100

medium_ride  = ride_count >= ride_bars * 5
long_ride    = ride_count >= long_bars * 5

// Standard V2 dip zone: 0-5% above EMA9
at_dip_entry_v2 = dist_ema9 >= 0 and dist_ema9 <= 5
at_deep_dip     = dist_ema9 >= 0 and dist_ema9 <= 1

// Grinder cloud zone: price touching or between EMA9 and EMA21
in_cloud = (close <= ema9 and close >= ema21) or (close >= ema9 and close <= ema21) or (math.abs(close - ema9) / ema9 * 100 <= 1)

// Active dip/entry condition depends on toggle
at_dip_entry = grinder_mode ? in_cloud : at_dip_entry_v2

vcp_pass = atr_pct >= atr_min and above_52wl >= low52_min

vol_ma      = ta.sma(volume, vol_ma_len)
vol_ratio   = volume / vol_ma
is_ep_surge     = vol_ratio >= ep_vol_mult   and close > open
is_distribution = vol_ratio >= dist_vol_mult  and close < open
is_healthy_dip  = vol_ratio <= dip_vol_mult   and dist_ema9 >= 0 and dist_ema9 <= 5

bench_close = request.security(bench_sym, timeframe.period, close)
stock_return_1mo = (close - close[grinder_outperf_look]) / close[grinder_outperf_look] * 100
bench_return_1mo = (bench_close - bench_close[grinder_outperf_look]) / bench_close[grinder_outperf_look] * 100
grinder_outperformance = stock_return_1mo - bench_return_1mo

is_low_atr       = atr_pct <= grinder_atr_max
is_high_bounce   = cloud_bounces >= grinder_bounce_min
is_long_ride      = ride_count >= grinder_ride_min
is_outperforming = grinder_outperformance >= grinder_outperf_min

// Grinder setup only evaluated when toggle is ON
// Cloud bounce count removed as hard gate (low-ATR grinders may show very few "official"
// bounces simply because price rides EMA9 continuously rather than dipping to EMA21 and back).
// Bounce count is still calculated/plotted for visual reference, not used as a filter here.
grinder_setup = grinder_mode and is_low_atr and is_long_ride and is_outperforming and at_dip_entry and stack_aligned

vol_color = is_ep_surge     ? color.new(color.orange, 0)  :
             is_distribution ? color.new(color.red, 0)     :
             is_healthy_dip  ? color.new(color.teal, 20)   :
             color.new(color.gray, 50)

plot(ride_count,          "Weeks Riding EMA21",      display=display.none)
plot(ema9_pct,            "EMA9 % Above (60 bars)",  display=display.none)
plot(cloud_bounces,       "Cloud Bounces (90 bars)",  display=display.none)
plot(dist_ema9,           "Distance from EMA9 %",    display=display.none)
plot(medium_ride  ? 1:0,  "Medium Ride (4wk+)",       display=display.none)
plot(long_ride    ? 1:0,  "Long Ride (8wk+)",          display=display.none)
plot(at_dip_entry ? 1:0,  "At Entry Zone (mode-dependent)", display=display.none)
plot(at_deep_dip  ? 1:0,  "At EMA21 Deep Dip",        display=display.none)
plot(stack_aligned? 1:0,  "EMA Stack Aligned",         display=display.none)
plot(atr_pct,             "ATR % (14)",               display=display.none)
plot(above_52wl,          "% Above 52W Low",          display=display.none)
plot(vcp_pass     ? 1:0,  "VCPSwing Filter Pass",      display=display.none)
plot(vol_ratio,           "Volume Ratio (vs 50MA)",   display=display.none)
plot(is_ep_surge    ? 1:0,"EP Volume Surge",           display=display.none)
plot(is_distribution? 1:0,"Distribution Volume",       display=display.none)
plot(is_healthy_dip ? 1:0,"Healthy Dip Volume",        display=display.none)

plot(grinder_outperformance,   "Grinder: Outperformance % (1mo)", display=display.none)
plot(is_outperforming ? 1:0,   "Grinder: Outperformance Pass",     display=display.none)
plot(is_low_atr       ? 1:0,   "Grinder: Low ATR Pass",            display=display.none)
plot(is_high_bounce   ? 1:0,   "Grinder: High Bounce Pass (informational)", display=display.none)
plot(is_long_ride     ? 1:0,   "Grinder: Long Ride Pass",          display=display.none)
plot(grinder_setup    ? 1:0,   "Grinder Setup",                    display=display.none)
plot(in_cloud         ? 1:0,   "In Cloud (EMA9-21)",               display=display.none)
plot(grinder_mode     ? 1:0,   "Grinder Mode Active",              display=display.none)

bgcolor(grinder_setup ? color.new(color.blue, 80) : (not grinder_mode and at_dip_entry and stack_aligned and is_healthy_dip) ? color.new(color.green, 75) : na)

ema9_plot  = plot(ema9,  color=color.green,  linewidth=2, title="EMA9")
ema21_plot = plot(ema21, color=color.blue,   linewidth=2, title="EMA21")
plot(ema50, color=color.orange, linewidth=1, title="EMA50")

fill(ema9_plot, ema21_plot, color=color.new(color.gray, 85), title="EMA9-21 Cloud")

if grinder_mode and grinder_setup and not grinder_setup[1]
    label.new(bar_index, low * 0.97, "GRINDER\nSETUP", style=label.style_label_up,
              color=color.blue, textcolor=color.white, size=size.small)
````
