# Coil & Fire - Ashish

- url: https://www.tradingview.com/script/MoRiEBJZ-Coil-Fire-Ashish/
- type: indicator
- pine_id: PUB;cc505fb951164cf681e295fa312f3f74
- version: 1.0

## Description

*Updated version of Momentum Scanner*

Finds stocks that had a strong explosive move (EP candle), are now coiling quietly near their EMAs, and marks the exact entry and stop-loss levels based on the most recent low-volume healthy-dip candle.
How it works:
Screens for stocks with a recent 8%+ single-day move that are outperforming their benchmark since that move, holding above the EMA9/21 cloud with the trend structure intact, and showing genuinely quiet volume on the pullback. When all conditions align, it marks a teal bar — a low-volume healthy-dip candle sitting within 5% above EMA9. The high of that bar is your entry. The low is your stop-loss. Purple dots show the entry level. Red dots show the stop.
Orange background = price has crossed the entry level. Yellow background = setup is valid, waiting for the trigger.
What's different from Momentum Scanner:
Entry and stop-loss are now anchored to the most recent teal bar rather than a historical coil-high level, so levels are always close to current price. Volume comparison for the teal bar now uses a 10-day average instead of 50-day, making it more responsive to recent trading activity rather than a long historical baseline.
Note: Indicators are tools, not oracles — every signal still requires human judgment, risk management, and context before any trade is taken.

## Source Code

````pine
//@version=6
indicator("Coil & Fire", overlay=true)

ema9_len         = input.int(9,    "EMA 9")
ema21_len        = input.int(21,   "EMA 21")
ema50_len        = input.int(50,   "EMA 50")
outperf_min      = input.float(10.0, "Min Outperformance vs Benchmark % (since EP candle)")
ath_proximity    = input.float(20.0, "Max % Below ATH (52W High)")
ep_candle_min    = input.float(8.0,  "Min EP Candle % (single day)")
ep_lookback      = input.int(20,   "EP Candle Detection Window (bars)")
ep_max_age       = input.int(90,   "Max Age of Locked EP Candle Before Reset (bars)")
vol_ma_len       = input.int(50,   "Volume MA Length (for EP/Distribution detection)")
teal_vol_ma_len  = input.int(10,   "Teal Bar Volume MA Length (for healthy dip detection)")
dip_vol_mult     = input.float(0.5, "Healthy Dip Threshold (vs Teal Vol MA)")
ep_vol_mult      = input.float(3.0, "EP Surge Multiplier (vs 50MA)")
dist_vol_mult    = input.float(2.0, "Distribution Multiplier (vs 50MA)")
bench_sym        = input.symbol("NSE:NIFTYMIDSML400", "Benchmark Symbol")
cloud_wick_tol   = input.float(1.5, "Cloud Wick Tolerance %")
teal_lookback    = input.int(10,   "Teal Bar Lookback (bars)")
teal_dist_max    = input.float(5.0, "Teal Bar Max Dist from EMA9 %")

// --- EMAs ---
ema9  = ta.ema(close, ema9_len)
ema21 = ta.ema(close, ema21_len)
ema50 = ta.ema(close, ema50_len)

// --- Benchmark ---
bench_close = request.security(bench_sym, timeframe.period, close)

// --- Volume MAs ---
vol_ma      = ta.sma(volume, vol_ma_len)       // 50-day for EP/distribution
vol_ma_10   = ta.sma(volume, teal_vol_ma_len)  // 10-day for teal bar
vol_ratio   = volume / vol_ma                  // vs 50-day
vol_ratio_10 = volume / vol_ma_10             // vs 10-day

// --- Distance from EMAs ---
dist_ema9  = (close - ema9)  / ema9  * 100
dist_ema21 = (close - ema21) / ema21 * 100

// --- Volume states ---
is_ep_surge     = vol_ratio >= ep_vol_mult    and close > open
is_distribution = vol_ratio >= dist_vol_mult  and close < open
is_teal         = vol_ratio_10 <= dip_vol_mult and dist_ema9 >= 0 and dist_ema9 <= teal_dist_max

// --- EP candle anchor ---
var int   ep_anchor_bars_ago  = na
var float ep_anchor_pct       = na
var int   ep_candle_count     = 0
var float ep_cluster_gain_pct = 0.0

found_new_ep = false
new_ep_pct   = 0.0
for i = 0 to ep_lookback - 1
    chg = (close[i] - close[i+1]) / close[i+1] * 100
    if chg >= ep_candle_min and i == 0
        found_new_ep := true
        new_ep_pct   := chg

if found_new_ep
    ep_cluster_gain_pct += new_ep_pct
    ep_anchor_bars_ago  := 0
    ep_anchor_pct       := new_ep_pct
    ep_candle_count     += 1
else if not na(ep_anchor_bars_ago)
    ep_anchor_bars_ago += 1

if not na(ep_anchor_bars_ago) and ep_anchor_bars_ago > ep_max_age
    ep_anchor_bars_ago  := na
    ep_anchor_pct       := na
    ep_candle_count     := 0
    ep_cluster_gain_pct := 0.0

has_ep_candle = not na(ep_anchor_bars_ago)
ep_candle_pct = nz(ep_anchor_pct)
ep_bars_ago   = nz(ep_anchor_bars_ago)

// --- Outperformance since EP candle ---
stock_return   = has_ep_candle ? (close - close[ep_bars_ago]) / close[ep_bars_ago] * 100 : na
bench_return   = has_ep_candle ? (bench_close - bench_close[ep_bars_ago]) / bench_close[ep_bars_ago] * 100 : na
outperformance = has_ep_candle ? stock_return - bench_return : na
outperf_pass   = has_ep_candle and outperformance >= outperf_min

// --- ATH proximity ---
ath_52w       = ta.highest(high, 252)
pct_below_ath = (ath_52w - close) / ath_52w * 100
ath_pass      = pct_below_ath <= ath_proximity

// --- EMA stack and cloud ---
stack_intact = ema9 > ema21 and ema21 > ema50
cloud_upper  = ema9  * (1 + cloud_wick_tol / 100)
cloud_lower  = ema21 * (1 - cloud_wick_tol / 100)
in_cloud     = stack_intact and close <= cloud_upper and close >= cloud_lower

low_vol_pullback = vol_ratio_10 <= dip_vol_mult
healthy_pullback = in_cloud and low_vol_pullback

// --- SL reference ---
sl_level = ta.lowest(low, 4)
risk_pct  = (close - sl_level) / close * 100

// --- Teal bar entry/SL ---
var float teal_entry     = na
var float teal_sl        = na
var int   teal_bar_index = na

if is_teal
    teal_entry     := high
    teal_sl        := low
    teal_bar_index := bar_index

teal_valid    = not na(teal_entry) and (bar_index - teal_bar_index) <= teal_lookback
entry_trigger = teal_valid and close > teal_entry and not is_teal

// --- Setup and trigger ---
momentum_leader_setup = outperf_pass and ath_pass and has_ep_candle and healthy_pullback and teal_valid
ready_to_fire         = momentum_leader_setup and entry_trigger

// ═══════════════════════════════════════════════════════════
// SCREENER OUTPUTS
// ═══════════════════════════════════════════════════════════
plot(outperformance,              "Outperformance vs Benchmark % (since EP)", display=display.none)
plot(outperf_pass ? 1:0,          "Outperformance Pass",                      display=display.none)
plot(pct_below_ath,               "% Below ATH",                              display=display.none)
plot(ath_pass ? 1:0,              "ATH Proximity Pass",                       display=display.none)
plot(has_ep_candle ? 1:0,         "Has Recent EP Candle",                     display=display.none)
plot(ep_candle_pct,               "EP Candle Size %",                         display=display.none)
plot(ep_bars_ago,                 "EP Candle Bars Ago",                       display=display.none)
plot(ep_candle_count,             "EP Candle Count",                          display=display.none)
plot(ep_cluster_gain_pct,         "EP Cluster Gain % (total)",                display=display.none)
plot(dist_ema21,                  "Distance from EMA21 %",                    display=display.none)
plot(dist_ema9,                   "Distance from EMA9 %",                     display=display.none)
plot(stack_intact ? 1:0,          "EMA Stack Intact (9>21>50)",               display=display.none)
plot(in_cloud ? 1:0,              "In EMA9-21 Cloud",                         display=display.none)
plot(vol_ratio,                   "Volume Ratio vs 50MA",                     display=display.none)
plot(vol_ratio_10,                "Volume Ratio vs 10MA (teal ref)",          display=display.none)
plot(is_teal ? 1:0,               "Is Teal Bar",                              display=display.none)
plot(teal_valid ? 1:0,            "Teal Bar Valid (within lookback)",         display=display.none)
plot(teal_entry,                  "Teal Entry Level",                         display=display.none)
plot(teal_sl,                     "Teal SL Level",                            display=display.none)
plot(healthy_pullback ? 1:0,      "Healthy Pullback (Cloud + Low Vol)",       display=display.none)
plot(sl_level,                    "Suggested SL (Low of 4d)",                 display=display.none)
plot(risk_pct,                    "Risk % to SL",                             display=display.none)
plot(momentum_leader_setup ? 1:0, "Momentum Leader Setup",                    display=display.none)
plot(entry_trigger ? 1:0,         "Entry Trigger (Cross Teal High)",          display=display.none)
plot(ready_to_fire ? 1:0,         "READY — Setup + Trigger",                  display=display.none)

// ═══════════════════════════════════════════════════════════
// VISUALS
// ═══════════════════════════════════════════════════════════
bgcolor(ready_to_fire ? color.new(color.orange, 70) :
        momentum_leader_setup ? color.new(color.yellow, 85) : na)

plot(ema9,  color=color.green,  linewidth=1, title="EMA9")
plot(ema21, color=color.blue,   linewidth=2, title="EMA21")
plot(ema50, color=color.orange, linewidth=1, title="EMA50")

p_ema9  = plot(ema9,  "EMA9 (cloud)",  display=display.none)
p_ema21 = plot(ema21, "EMA21 (cloud)", display=display.none)
fill(p_ema9, p_ema21, color=color.new(color.blue, 90))

plot(teal_valid ? teal_entry : na, "Entry Level (Teal Bar High)",
     color=color.purple, style=plot.style_circles, linewidth=2)

plot(teal_valid ? teal_sl : na, "SL Level (Teal Bar Low)",
     color=color.red, style=plot.style_circles, linewidth=1)

if momentum_leader_setup and not momentum_leader_setup[1]
    label.new(bar_index, low * 0.97,
              "ML SETUP\nE: "  + str.tostring(teal_entry, "#.##") +
              "\nSL: " + str.tostring(teal_sl,   "#.##"),
              style=label.style_label_up, color=color.yellow,
              textcolor=color.black, size=size.small)

if ready_to_fire and not ready_to_fire[1]
    label.new(bar_index, low * 0.95, "TRIGGER\nHIT",
              style=label.style_label_up, color=color.orange,
              textcolor=color.white, size=size.small)
````
