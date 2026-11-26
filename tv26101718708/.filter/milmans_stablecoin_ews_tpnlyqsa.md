# Milman's Stablecoin EWS

- url: https://www.tradingview.com/script/TPNlyQsA-Milman-s-Stablecoin-EWS/
- type: indicator
- pine_id: PUB;00d212d3f76045f6ad65866734d870c1
- version: 1.0

## Description

Milman's Stablecoin Early Warning System (EWS)

Monitors total stablecoin market cap supply dynamics as a leading indicator of crypto market capitulation. When stablecoin supply contracts — rather than growing or rotating — it signals capital is leaving the crypto ecosystem entirely, not just rotating to safety. Historically, this has preceded major capitulation events by days to weeks.
The indicator tracks three escalating warning stages:
Stage 1 (Yellow) — Supply growth rate slowing. Earliest signal, potentially months of lead time. Mirrors the 2021 pattern where growth decelerated months before the actual market top.
Stage 2 (Orange) — Active contraction confirmed. ROC crosses below the contraction threshold. Mirrors the 2018 pattern where USDT contraction gave approximately one month of warning before capitulation.
Stage 3 / Critical (Red + Triangle) — Supply prints a new lower low below the recent swing range. Per the 2022 LUNA precedent, capitulation followed within days of this signal firing.
Additional signals: Blue diamonds mark instances where USDC supply leads USDT into a lower low — the pattern observed in 2022 where USDC warned before the broader collapse. A purple background indicates BTC is simultaneously trading below its 100-week moving average, the highest-confidence confluence condition.

Settings
Parameter -- Default -- Description 
ROC Period -- 7 days -- Lookback for rate-of-change calculation
Lower Low Lookback -- 30 days -- Window for Stage 3 swing low detection
Z-Score Lookback -- 90 days -- Normalization window for the main signal line
Stage 1 ROC Threshold -- -0.3% -- Growth slowing trigger
Stage 2 ROC Threshold-- -1.5% -- Active contraction trigger 
BTC 100W MA Highlight -- On -- Purple background when BTC below 100-week MA 
Show USDT/USDC Split -- On -- Plots individual stablecoin ROC lines

Notes
Best used as confluence alongside existing market structure analysis. Signals are most reliable on the daily timeframe. Historical data prior to 2020 is limited by stablecoin market size and data availability. Not financial advice.
Inspired by analysis from Blockchain Backer's January 2026 newsletter on stablecoin supply dynamics.

## Source Code

````pine
//@version=6
indicator("Milman's Stablecoin EWS", overlay=false, max_bars_back=1000)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════
grp1 = "Core Settings"
roc_period     = input.int(7,   "ROC Period (days)",              minval=1,  maxval=30,  group=grp1)
swing_lookback = input.int(30,  "Lower Low Lookback (days)",      minval=10, maxval=90,  group=grp1)
z_lookback     = input.int(90,  "Z-Score Lookback (days)",        minval=20, maxval=365, group=grp1)

grp2 = "Stage Thresholds"
slow_threshold = input.float(-0.3, "Stage 1 ROC: Growth Slowing (%)",    minval=-5,  maxval=0, step=0.1, group=grp2)
cont_threshold = input.float(-1.5, "Stage 2 ROC: Active Contraction (%)", minval=-10, maxval=0, step=0.1, group=grp2)

grp3 = "Confluence Filters"
show_btc_ma = input.bool(true, "Highlight BTC below 100W MA", group=grp3)
show_split  = input.bool(true, "Show USDT / USDC separately", group=grp3)

// ═══════════════════════════════════════════════════════════
// DATA
// ═══════════════════════════════════════════════════════════
stable_mc = request.security("CRYPTOCAP:STABLE.C", timeframe.period, close)
usdt_mc   = request.security("CRYPTOCAP:USDT",        timeframe.period, close)
usdc_mc   = request.security("CRYPTOCAP:USDC",        timeframe.period, close)

// FIX: use tuple request instead of boolean expression inside security call
[btc_w_close, btc_w_ma100] = request.security("BITSTAMP:BTCUSD", "W", [close, ta.sma(close, 100)])
btc_below_100w = btc_w_close < btc_w_ma100

// ═══════════════════════════════════════════════════════════
// CORE METRICS
// ═══════════════════════════════════════════════════════════
roc_stable = ta.roc(stable_mc, roc_period)
roc_usdt   = ta.roc(usdt_mc,   roc_period)
roc_usdc   = ta.roc(usdc_mc,   roc_period)

roc_mean = ta.sma(roc_stable, z_lookback)
roc_std  = ta.stdev(roc_stable, z_lookback)
z_score  = roc_std != 0 ? (roc_stable - roc_mean) / roc_std : 0

// ═══════════════════════════════════════════════════════════
// LOWER LOW DETECTION
// FIX: apply [1] offset AFTER ta.lowest, not before
// ═══════════════════════════════════════════════════════════
prior_low_stable = ta.lowest(stable_mc, swing_lookback)[1]
prior_low_usdc   = ta.lowest(usdc_mc,   swing_lookback)[1]
prior_low_usdt   = ta.lowest(usdt_mc,   swing_lookback)[1]

lower_low_total = stable_mc < prior_low_stable and roc_stable < 0
lower_low_usdc  = usdc_mc   < prior_low_usdc   and roc_usdc  < 0
lower_low_usdt  = usdt_mc   < prior_low_usdt   and roc_usdt  < 0

// ═══════════════════════════════════════════════════════════
// THREE-STAGE SIGNAL SYSTEM
// ═══════════════════════════════════════════════════════════
stage3 = lower_low_total
stage2 = roc_stable < cont_threshold and not stage3
stage1 = roc_stable < slow_threshold and roc_stable >= cont_threshold and not stage3

usdc_leading_warn = lower_low_usdc and not lower_low_usdt

// ═══════════════════════════════════════════════════════════
// PLOTS
// ═══════════════════════════════════════════════════════════
hline(0,    "Zero",              color=color.gray,   linestyle=hline.style_dashed)
hline(-2.0, "Z = -2",            color=color.orange, linestyle=hline.style_dotted, linewidth=1)
hline(-2.5, "Z = -2.5 (Extreme)",color=color.red,    linestyle=hline.style_dotted, linewidth=1)

plot(z_score, "Z-Score (Combined Stable MC)", linewidth=2,
     color = stage3 ? color.red : stage2 ? color.orange : stage1 ? color.yellow : color.new(color.purple, 20))

plot(show_split ? roc_usdt : na, "USDT 7d ROC", color=color.new(color.teal, 40), linewidth=1)
plot(show_split ? roc_usdc : na, "USDC 7d ROC", color=color.new(color.blue, 40), linewidth=1)

bgcolor(stage3 ? color.new(color.red,    55) : na, title="Stage 3: Lower Low (CRITICAL)")
bgcolor(stage2 ? color.new(color.orange, 72) : na, title="Stage 2: Active Contraction")
bgcolor(stage1 ? color.new(color.yellow, 82) : na, title="Stage 1: Growth Slowing")
bgcolor(show_btc_ma and btc_below_100w ? color.new(color.purple, 91) : na, title="BTC below 100W MA")

plotshape(stage3 and not stage3[1], "New Lower Low Signal",
          shape.triangledown, location.top, color.red, size=size.small)
plotshape(usdc_leading_warn and not usdc_leading_warn[1], "USDC Leads Lower Low",
          shape.diamond, location.bottom, color.blue, size=size.tiny)

// ═══════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════
alertcondition(stage3 and not stage3[1],
  "🚨 STAGE 3 — Supply Lower Low (Days to Capitulation?)",
  "Combined stablecoin supply printed a new lower low. Per 2022 precedent, capitulation followed within days.")

alertcondition(stage3 and btc_below_100w and not (stage3[1] and btc_below_100w[1]),
  "🔴 CRITICAL CONFLUENCE — Lower Low + BTC below 100W MA",
  "Stablecoin lower low AND Bitcoin below 100-week MA simultaneously — highest historical risk combination.")

alertcondition(usdc_leading_warn and not usdc_leading_warn[1],
  "🔵 USDC Lower Low (Leading Signal)",
  "USDC supply hit a new low while USDT has not yet. Per 2022, USDC led the warning before broader collapse.")

alertcondition(stage2 and not stage2[1],
  "⚠️ STAGE 2 — Active Stablecoin Contraction",
  "Combined stablecoin ROC crossed below contraction threshold. 2018 pattern: ~1 month warning from here.")

alertcondition(stage1 and not stage1[1],
  "📉 STAGE 1 — Supply Growth Slowing",
  "Stablecoin ROC turning negative. Early warning stage — months of lead time in prior cycles.")

alertcondition(roc_usdc < cont_threshold and not (roc_usdc[1] < cont_threshold),
  "⚠️ USDC Contraction Active",
  "USDC supply actively contracting. USDC gave pre-capitulation warning in 2022 before USDT did.")
````
