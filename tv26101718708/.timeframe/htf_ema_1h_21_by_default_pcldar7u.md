# HTF EMA (1H 21 by default)

- url: https://www.tradingview.com/script/pCLDaR7U-HTF-EMA-1H-21-by-default/
- type: indicator
- pine_id: PUB;49f3c390b7c243dca65f5230cb17c0f9
- version: 1.0

## Description

Plot a higher-timeframe EMA on your current chart without the stair-stepping. Set it to a 1H 21 EMA by default, or any timeframe/length you want.
Three modes:

Live (HTF) — the true HTF EMA, but developing in real time. It slides intrabar using the live price and locks to the exact stepped value at each HTF close. Current whenever you look at it, no jump at the bar roll. Non-repainting.
Exact (HTF) — the confirmed HTF EMA through the last closed higher-timeframe bar. Stair-steps by design; updates only at each HTF close. Zero future bleed.
Smooth (scaled) — rebuilds the EMA natively on your chart timeframe by scaling the length to the timeframe ratio (a 21 EMA on 1H becomes ~84 on a 15m). Curves smoothly but is an approximation and drifts slightly from the true line.

Pick Live if you want an accurate, always-current HTF EMA that doesn't repaint. Pick Exact if you only care about confirmed closes. Pick Smooth if you want a clean curve and can tolerate minor drift.

## Source Code

````pine
//@version=6
indicator("HTF EMA (1H 21 by default)", overlay=true)

// ─── Inputs ──────────────────────────────────────────────
i_htf   = input.timeframe("60", "Source timeframe")
i_len   = input.int(21, "EMA length", minval=1)
i_mode  = input.string("Live (HTF)", "Mode", options=["Live (HTF)", "Exact (HTF)", "Smooth (scaled)"])
i_col   = input.color(color.orange, "Color")
i_width = input.int(2, "Line width", minval=1, maxval=4)

// ─── Confirmed HTF EMA ───────────────────────────────────
// The true hourly EMA, confirmed through the last CLOSED HTF
// bar. lookahead_off = no future bleed, no repaint. On its own
// this stair-steps (only moves at each HTF close).
htfEma = request.security(syminfo.tickerid, i_htf, ta.ema(close, i_len), lookahead = barmerge.lookahead_off)

// ─── Live (HTF): same EMA, but developing ────────────────
// One EMA step using the live price as the forming HTF bar's
// close:  EMA_now = a*close + (1-a)*EMA_prevHTF,  a = 2/(len+1).
// htfEma supplies EMA_prevHTF (the value through the last closed
// HTF bar), so as price moves intrabar this slides, and at the
// HTF close (close == the bar's close) it equals exactly the
// value the stepped line lands on. Updates every chart bar, so
// it's current whenever you check it; no jump at the HTF roll.
// Non-repainting (uses lookahead_off htfEma + the bar's own close).
alpha   = 2.0 / (i_len + 1)
liveEma = alpha * close + (1.0 - alpha) * htfEma

// ─── Smooth: rebuild the EMA natively on chart TF ────────
// Scale the length by the timeframe ratio so a 21-period hourly
// EMA becomes an equivalent length on the current chart
// (21 * 3600/900 = 84 on a 15m). Curves smoothly but is an
// approximation — tracks the hourly line and drifts a bit.
htf_sec   = timeframe.in_seconds(i_htf)
chart_sec = timeframe.in_seconds(timeframe.period)
scaledLen = math.max(1, math.round(i_len * (htf_sec / chart_sec)))
smoothEma = ta.ema(close, scaledLen)

// ─── Pick + plot ─────────────────────────────────────────
plotVal = i_mode == "Exact (HTF)" ? htfEma : i_mode == "Smooth (scaled)" ? smoothEma : liveEma
plot(plotVal, "HTF EMA", color = i_col, linewidth = i_width)
````
