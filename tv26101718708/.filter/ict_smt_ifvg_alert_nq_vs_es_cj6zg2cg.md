# ICT SMT + IFVG Alert [NQ vs ES]

- url: https://www.tradingview.com/script/cj6zg2Cg-ICT-SMT-IFVG-Alert-NQ-vs-ES/
- type: indicator
- pine_id: PUB;5d2b31b537a6447c86c156cbc9c53899
- version: 1.0

## Description

motion model set plus ifvg
used to get alerts when setups are forming

## Source Code

````pine
// ============================================================
// ICT True SMT Divergence + IFVG Confluence Alert
// NQ vs ES — Auto-detects which chart you're on
//
// BULLISH: One index takes a swing low, the other doesn't
//          + Inverse FVG (IFVG) on 1m or 3m confirms
//          + Optional: Supporting 5m+ SMT
//
// BEARISH: One index takes a swing high, the other doesn't
//          + Inverse FVG (IFVG) on 1m or 3m confirms
//          + Optional: Supporting 5m+ SMT
// ============================================================
//@version=5
indicator("ICT SMT + IFVG Alert [NQ vs ES]", overlay=true, max_bars_back=500)

// ─────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────
smt_lookback   = input.int(10,   "SMT Swing Lookback (bars)",   minval=3,  maxval=50,  group="SMT Settings")
htf_lookback   = input.int(20,   "HTF SMT Lookback (bars 5m+)", minval=5,  maxval=100, group="SMT Settings")
ifvg_min_pts   = input.float(2.0,"Min IFVG Size (points)",      minval=0.5,            group="IFVG Settings")
show_htf_only  = input.bool(false,"Only alert when HTF SMT also present", group="Alert Settings")

// ─────────────────────────────────────────
// AUTO-DETECT: Which chart am I on?
// ─────────────────────────────────────────
is_nq = str.contains(syminfo.ticker, "NQ")
is_es = str.contains(syminfo.ticker, "ES")

comp_symbol = is_nq ? "CME_MINI:ES1!" : "CME_MINI:NQ1!"

[comp_open, comp_high, comp_low, comp_close] = request.security(comp_symbol, timeframe.period, [open, high, low, close], lookahead=barmerge.lookahead_off)

[comp_high_5m, comp_low_5m] = request.security(comp_symbol, "5", [high, low], lookahead=barmerge.lookahead_off)

[host_high_5m, host_low_5m] = request.security(syminfo.tickerid, "5", [high, low], lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────
// SWING HIGHS & LOWS
// ─────────────────────────────────────────
host_swing_low  = ta.lowest(low,  smt_lookback)[1]
host_swing_high = ta.highest(high, smt_lookback)[1]

comp_swing_low  = ta.lowest(comp_low,  smt_lookback)[1]
comp_swing_high = ta.highest(comp_high, smt_lookback)[1]

host_htf_swing_low   = ta.lowest(host_low_5m,  htf_lookback)[1]
host_htf_swing_high  = ta.highest(host_high_5m, htf_lookback)[1]
comp_htf_swing_low   = ta.lowest(comp_low_5m,  htf_lookback)[1]
comp_htf_swing_high  = ta.highest(comp_high_5m, htf_lookback)[1]

// ─────────────────────────────────────────
// SMT DIVERGENCE
// ─────────────────────────────────────────
bull_smt_caseA = low  < host_swing_low  and comp_low  > comp_swing_low
bull_smt_caseB = comp_low < comp_swing_low and low  > host_swing_low
bull_smt       = bull_smt_caseA or bull_smt_caseB

bear_smt_caseA = high > host_swing_high and comp_high < comp_swing_high
bear_smt_caseB = comp_high > comp_swing_high and high < host_swing_high
bear_smt       = bear_smt_caseA or bear_smt_caseB

// ─────────────────────────────────────────
// HTF SMT (5m+)
// ─────────────────────────────────────────
bull_htf_smt_caseA = host_low_5m  < host_htf_swing_low  and comp_low_5m  > comp_htf_swing_low
bull_htf_smt_caseB = comp_low_5m  < comp_htf_swing_low  and host_low_5m  > host_htf_swing_low
bull_htf_smt       = bull_htf_smt_caseA or bull_htf_smt_caseB

bear_htf_smt_caseA = host_high_5m > host_htf_swing_high and comp_high_5m < comp_htf_swing_high
bear_htf_smt_caseB = comp_high_5m > comp_htf_swing_high and host_high_5m < host_htf_swing_high
bear_htf_smt       = bear_htf_smt_caseA or bear_htf_smt_caseB

// ─────────────────────────────────────────
// IFVG — INVERSE FAIR VALUE GAP
// ─────────────────────────────────────────
bear_gap_top    = low[2]
bear_gap_bot    = high[4]
bear_gap_size   = bear_gap_top - bear_gap_bot
prior_bear_fvg  = bear_gap_size >= ifvg_min_pts

price_entered_bear_gap = low[1] <= bear_gap_top and low[1] >= bear_gap_bot
price_holds_above      = close   >= bear_gap_bot

bull_ifvg = prior_bear_fvg and price_entered_bear_gap and price_holds_above

bull_gap_bot    = high[2]
bull_gap_top    = low[4]
bull_gap_size   = bull_gap_top - bull_gap_bot
prior_bull_fvg  = bull_gap_size >= ifvg_min_pts

price_entered_bull_gap = high[1] >= bull_gap_bot and high[1] <= bull_gap_top
price_holds_below      = close   <= bull_gap_top

bear_ifvg = prior_bull_fvg and price_entered_bull_gap and price_holds_below

// ─────────────────────────────────────────
// CONFLUENCE CONDITIONS
// ─────────────────────────────────────────
bull_base       = bull_smt and bull_ifvg
bear_base       = bear_smt and bear_ifvg

bull_with_htf   = bull_base and bull_htf_smt
bear_with_htf   = bear_base and bear_htf_smt

bull_alert_cond = show_htf_only ? bull_with_htf : bull_base
bear_alert_cond = show_htf_only ? bear_with_htf : bear_base

// ─────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────
alertcondition(bull_alert_cond,
     title   = "🟢 BULL SMT + IFVG",
     message = "ICT BULLISH SETUP\nSMT Divergence: One index took the low, other held\nBullish IFVG confirmed\nChart: {{ticker}} | TF: {{interval}} | Price: {{close}}")

alertcondition(bear_alert_cond,
     title   = "🔴 BEAR SMT + IFVG",
     message = "ICT BEARISH SETUP\nSMT Divergence: One index took the high, other held\nBearish IFVG confirmed\nChart: {{ticker}} | TF: {{interval}} | Price: {{close}}")

alertcondition(bull_with_htf,
     title   = "🟢 BULL SMT + IFVG + HTF Confirmed",
     message = "ICT BULLISH SETUP — FULL STACK\nSMT (1m/3m) + IFVG + 5m HTF SMT all confirmed\nChart: {{ticker}} | TF: {{interval}} | Price: {{close}}")

alertcondition(bear_with_htf,
     title   = "🔴 BEAR SMT + IFVG + HTF Confirmed",
     message = "ICT BEARISH SETUP — FULL STACK\nSMT (1m/3m) + IFVG + 5m HTF SMT all confirmed\nChart: {{ticker}} | TF: {{interval}} | Price: {{close}}")

// ─────────────────────────────────────────
// VISUAL MARKERS
// ─────────────────────────────────────────
plotshape(bull_alert_cond,
          title="Bull SMT+IFVG",
          style=shape.triangleup,
          location=location.belowbar,
          color=bull_with_htf ? color.new(color.lime, 0) : color.new(color.aqua, 20),
          size=size.small)

plotshape(bear_alert_cond,
          title="Bear SMT+IFVG",
          style=shape.triangledown,
          location=location.abovebar,
          color=bear_with_htf ? color.new(color.red, 0) : color.new(color.orange, 20),
          size=size.small)

plotshape(bull_htf_smt and not bull_alert_cond,
          title="HTF Bull SMT only",
          style=shape.circle,
          location=location.belowbar,
          color=color.new(color.gray, 50),
          size=size.tiny)

plotshape(bear_htf_smt and not bear_alert_cond,
          title="HTF Bear SMT only",
          style=shape.circle,
          location=location.abovebar,
          color=color.new(color.gray, 50),
          size=size.tiny)
````
