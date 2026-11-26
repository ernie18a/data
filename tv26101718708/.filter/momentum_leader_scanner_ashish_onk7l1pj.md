# Momentum Leader Scanner - Ashish

- url: https://www.tradingview.com/script/OnK7L1PJ-Momentum-Leader-Scanner-Ashish/
- type: indicator
- pine_id: PUB;9c8e1c2524444840b42627aa33fa04d5
- version: 1.0

## Description

Momentum Leader Scanner — a systematic tool for catching high-conviction momentum stocks after their initial breakout (EP candle), while they consolidate quietly in the EMA9/21 cloud before the next leg up. Combines relative strength vs. benchmark, proximity to 52-week highs, and a low-volume pullback filter to surface coiled setups — then locks a precise breakout trigger price the moment a setup is confirmed, so you can place your entry order in advance instead of reacting after the move has already started.

How it works
The script anchors its analysis to the most recent qualifying EP candle (a single-day move of 8%+ by default) and measures the stock's outperformance against a benchmark (default: NIFTYMIDSML400) since that candle — not over an arbitrary fixed window. This avoids one EP candle alone inflating a "strength" reading; the outperformance has to be sustained after the move, not just caused by it.

A setup requires four conditions together:

Outperformance vs benchmark since the EP candle exceeds a minimum threshold (default 10%)
Proximity to 52-week high (default within 20%) — confirming the stock hasn't lost its leadership
A qualifying EP candle within the detection window
A healthy pullback — price sitting inside the EMA9/EMA21 cloud (with a small tolerance for wick excursions) while the EMA9 > EMA21 > EMA50 stack stays intact, on below-average volume

When all four align, the script locks a breakout trigger price — the highest high since the EP candle — letting you pre-place a GTT order rather than waiting for a confirmed close above resistance, which is often a day or more late.
What it's good for
Catching stocks in the "coil after the jump" phase: violent move, quiet digestion, then continuation. It explicitly tracks how many separate EP candles have fired (visible as a diagnostic) so you can judge whether a stock had one clean catalyst or has been repeatedly volatile.
What it isn't built for
Slow, low-volatility grinders that never have a sharp EP candle (a different system altogether), and stocks that move too fast and too cleanly to ever pull back into the cloud on a daily timeframe.
Status
Actively used and refined against live market data — published as-is for traders who understand swing/momentum trading and want to incorporate systematic outperformance and pullback logic into their own process. Not financial advice; verify every signal against your own risk management before acting on it.

## Source Code

````pine
//@version=6
indicator("Momentum Leader Scanner", overlay=true)

ema9_len    = input.int(9,  "EMA 9")
ema21_len   = input.int(21, "EMA 21")
ema50_len   = input.int(50, "EMA 50")
outperf_min      = input.float(10.0, "Min Outperformance vs Benchmark % (since EP candle)")
ath_proximity    = input.float(20.0, "Max % Below ATH (52W High)")
ep_candle_min    = input.float(8.0, "Min EP Candle % (single day)")
ep_lookback      = input.int(20, "EP Candle Detection Window (bars, for finding a NEW EP candle)")
ep_max_age       = input.int(90, "Max Age of Locked EP Candle Before Reset (bars)")
vol_ma_len    = input.int(50,    "Volume MA Length")
dip_vol_mult  = input.float(0.6, "Pullback Volume Threshold (vs 50MA)")
sl_lookback   = input.int(4, "Stop Loss Lookback (days) - low of last N days")
bench_sym = input.symbol("NSE:NIFTYMIDSML400", "Benchmark Symbol for Outperformance")
cloud_wick_tol = input.float(1.5, "Cloud Wick Tolerance % (allow minor excursions)")

ema9  = ta.ema(close, ema9_len)
ema21 = ta.ema(close, ema21_len)
ema50 = ta.ema(close, ema50_len)

bench_close = request.security(bench_sym, timeframe.period, close)

daily_pct_change = (close - close[1]) / close[1] * 100

var int   ep_anchor_bars_ago = na
var float ep_anchor_pct      = na
var int   ep_candle_count    = 0

found_new_ep = false
new_ep_pct = 0.0
for i = 0 to ep_lookback - 1
    chg = (close[i] - close[i+1]) / close[i+1] * 100
    if chg >= ep_candle_min and i == 0
        found_new_ep := true
        new_ep_pct := chg

if found_new_ep
    ep_anchor_bars_ago := 0
    ep_anchor_pct      := new_ep_pct
    ep_candle_count     += 1
else if not na(ep_anchor_bars_ago)
    ep_anchor_bars_ago += 1

if not na(ep_anchor_bars_ago) and ep_anchor_bars_ago > ep_max_age
    ep_anchor_bars_ago := na
    ep_anchor_pct      := na
    ep_candle_count     := 0

has_ep_candle = not na(ep_anchor_bars_ago)
ep_candle_pct = nz(ep_anchor_pct)
ep_bars_ago   = nz(ep_anchor_bars_ago)

stock_return = has_ep_candle ? (close - close[ep_bars_ago]) / close[ep_bars_ago] * 100 : na
bench_return = has_ep_candle ? (bench_close - bench_close[ep_bars_ago]) / bench_close[ep_bars_ago] * 100 : na
outperformance = has_ep_candle ? stock_return - bench_return : na
outperf_pass = has_ep_candle and outperformance >= outperf_min

ath_52w = ta.highest(high, 252)
pct_below_ath = (ath_52w - close) / ath_52w * 100
ath_pass = pct_below_ath <= ath_proximity

vol_ma    = ta.sma(volume, vol_ma_len)
vol_ratio = volume / vol_ma

stack_intact = ema9 > ema21 and ema21 > ema50

cloud_upper = ema9  * (1 + cloud_wick_tol / 100)
cloud_lower = ema21 * (1 - cloud_wick_tol / 100)
in_cloud = stack_intact and close <= cloud_upper and close >= cloud_lower

dist_ema21 = (close - ema21) / ema21 * 100
dist_ema9  = (close - ema9)  / ema9  * 100

low_vol_pullback = vol_ratio <= dip_vol_mult
healthy_pullback = in_cloud and low_vol_pullback

sl_level = ta.lowest(low, sl_lookback)
risk_pct = (close - sl_level) / close * 100

momentum_leader_setup = outperf_pass and ath_pass and has_ep_candle and healthy_pullback

var float locked_trigger_price = na
var int   locked_trigger_bar   = na
setup_first_fired = momentum_leader_setup and not momentum_leader_setup[1]

coil_high = ep_bars_ago >= 1 ? ta.highest(high, ep_bars_ago) : high

if setup_first_fired
    locked_trigger_price := coil_high
    locked_trigger_bar   := bar_index

coil_invalidated = not momentum_leader_setup and not momentum_leader_setup[1] and not momentum_leader_setup[2]
if coil_invalidated
    locked_trigger_price := na
    locked_trigger_bar   := na

gtt_trigger_price = locked_trigger_price
has_active_trigger = not na(locked_trigger_price)

trigger_hit = has_active_trigger and close > locked_trigger_price

ready_to_fire = trigger_hit

plot(outperformance,        "Outperformance vs Benchmark % (since EP)", display=display.none)
plot(outperf_pass ? 1:0,    "Outperformance Pass",              display=display.none)
plot(pct_below_ath,         "% Below ATH",                      display=display.none)
plot(ath_pass ? 1:0,        "ATH Proximity Pass",                display=display.none)
plot(has_ep_candle ? 1:0,   "Has Recent EP Candle",              display=display.none)
plot(ep_candle_pct,         "EP Candle Size %",                  display=display.none)
plot(ep_bars_ago,           "EP Candle Bars Ago",                display=display.none)
plot(ep_candle_count,       "EP Candle Count (diagnostic)",      display=display.none)
plot(dist_ema21,            "Distance from EMA21 % (diagnostic)", display=display.none)
plot(dist_ema9,             "Distance from EMA9 % (diagnostic)",  display=display.none)
plot(stack_intact ? 1:0,    "EMA Stack Intact (9>21>50)",         display=display.none)
plot(in_cloud ? 1:0,        "In EMA9-21 Cloud",                   display=display.none)
plot(vol_ratio,             "Volume Ratio (vs 50MA)",            display=display.none)
plot(healthy_pullback ? 1:0,"Healthy Pullback (Cloud + Low Vol)", display=display.none)
plot(sl_level,              "Suggested SL (Low of Nd)",          display=display.none)
plot(risk_pct,              "Risk % to SL",                      display=display.none)
plot(momentum_leader_setup ? 1:0, "Momentum Leader Setup",       display=display.none)
plot(gtt_trigger_price,     "GTT Trigger Price (locked coil high)", display=display.none)
plot(trigger_hit ? 1:0,     "Trigger Hit (after-the-fact, for log)", display=display.none)
plot(ready_to_fire ? 1:0,   "READY — Setup + Trigger",            display=display.none)

bgcolor(ready_to_fire ? color.new(color.orange, 70) :
        momentum_leader_setup ? color.new(color.yellow, 85) : na)

plot(ema9,  color=color.green,  linewidth=1)
plot(ema21, color=color.blue,   linewidth=2)
plot(ema50, color=color.orange, linewidth=1)
plot(sl_level, "SL Line", color=color.red, style=plot.style_circles, linewidth=1)

p_ema9 = plot(ema9, "EMA9 (cloud)", display=display.none)
p_ema21 = plot(ema21, "EMA21 (cloud)", display=display.none)
fill(p_ema9, p_ema21, color=color.new(color.blue, 90))

plot(has_active_trigger ? locked_trigger_price : na, "GTT Trigger Line",
     color=color.purple, style=plot.style_circles, linewidth=2)

if setup_first_fired
    label.new(bar_index, low * 0.97, "ML SETUP\nGTT: " + str.tostring(coil_high, "#.##"),
              style=label.style_label_up, color=color.yellow, textcolor=color.black, size=size.small)

if ready_to_fire and not ready_to_fire[1]
    label.new(bar_index, low * 0.95, "TRIGGER\nHIT", style=label.style_label_up,
              color=color.orange, textcolor=color.white, size=size.small)
````
