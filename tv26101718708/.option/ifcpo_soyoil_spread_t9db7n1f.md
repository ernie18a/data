# iFCPO Soyoil Spread

- url: https://www.tradingview.com/script/T9Db7n1f-iFCPO-Soyoil-Spread/
- type: indicator
- pine_id: PUB;7779379a1bc542d49eba1a33d32cfc12
- version: 2.0

## Description

iFCPO Soyoil Spread — z-score divergence between FCPO (Bursa Crude Palm Oil Futures) and CBOT soybean oil (ZL/BO).

WHY IT MATTERS
FCPO and soybean oil are 0.85+ correlated long-run (substitute oils in the global vegetable-oil complex). When the FCPO/BO ratio z-score blows out beyond ±2σ over a 50-day lookback, FCPO is statistically rich or cheap vs the global benchmark. Mean-reversion bias kicks in.

HOW TO USE
- z > +2: FCPO over-extended vs BO — bias short / fade longs
- z < −2: FCPO cheap vs BO — bias long / fade shorts
- |z| < 1: ignore — pairs are tracking normally
- 1 < |z| < 2: stretched, watch for reversal

This is a CONTEXT layer — it modifies conviction. NEVER trade z alone. Pair with iFCPO Wick Hunter (entries) + iFCPO Regime Meter (regime) + iFCPO Session Law (timing).

KPIs
- Lookback: 50 daily bars (configurable)
- Extreme threshold: ±2σ (configurable)
- Symbol: CBOT:ZL1! (TradingView's continuous front-month soybean oil)

OUTPUTS
Dimensionless ratio z (FCPO close / BO close), mean / ±1σ / ±2σ hlines, color-graded line (red rich / green cheap / amber stretched), tinted background at extremes, full status table top-right (FCPO, BO, z, state, pair-with).

Open-source. Part of the iFCPO free hero stack.

## Source Code

````pine
//@version=6
// iFCPO Soyoil/FCPO Spread — CBOT BO ↔ FCPO log-ratio z-score divergence
// Tier: FREE | Category: Cross-Market | Free-Tier CONTEXT layer (silent)
// Heuristic: FCPO and CBOT soybean oil (ZL/BO) tend to co-move (palm/soy substitution dynamics).
// We compute log(FCPO_close / BO_close) z-score over the lookback — log-ratio neutralises scale and the
// z-score measures dislocation around the rolling sample mean. Note: cross-currency arb is imperfect
// (FCPO is RM/MT, ZL is USD¢/lb, USDMYR drift can move the mean) — read as STATISTICAL stretch only.
// Z > +2 = FCPO stretched rich vs BO; Z < -2 = FCPO stretched cheap vs BO; mean-reversion bias.
// USE AS CONVICTION MODIFIER ONLY — not an entry signal. Pair with wick-hunter-lite for actual triggers.
indicator("iFCPO Soyoil Spread", "iFCPO Soy", overlay = false)

// ── Inputs ──
bo_sym       = input.symbol("CBOT:ZL1!", "CBOT Soybean Oil (ZL = continuous)", group = "Symbols",
   tooltip = "TV uses ZL for soybean oil (BO is the legacy floor code). ZL1! is the continuous front-month.")
z_period     = input.int(50, "Z-score lookback (bars)", minval = 10, group = "Stats")
extreme_z    = input.float(2.0, "Extreme z threshold", minval = 1.0, maxval = 4.0, step = 0.5, group = "Stats")
show_table   = input.bool(true, "Show stats table", group = "Display")

// ── Pull both daily closes via [1] inside security() — confirmed bar, no intraday repaint ──
bo     = request.security(bo_sym,           "D", close[1], lookahead = barmerge.lookahead_off)
fcpo_d = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)

// ── Log-ratio z-score (scale-neutral) ──
// log(FCPO/BO) makes the math dimensionally consistent and the z-score measures dislocation around the rolling mean.
log_ratio  = (bo > 0 and fcpo_d > 0) ? math.log(fcpo_d / bo) : na
ratio_mean = ta.sma(log_ratio, z_period)
ratio_std  = ta.stdev(log_ratio, z_period)
z = ratio_std > 0 ? (log_ratio - ratio_mean) / ratio_std : na
ratio = bo > 0 ? fcpo_d / bo : na  // raw ratio kept for table display

// ── Visualization ──
extreme_high = z >= extreme_z
extreme_low  = z <= -extreme_z
moderate_high = z >= 1 and not extreme_high
moderate_low  = z <= -1 and not extreme_low

z_col = extreme_high ? #FF3B5C : extreme_low ? #1FC77E : moderate_high ? color.new(#E0B544, 40) : moderate_low ? color.new(#1FC77E, 40) : color.new(color.gray, 30)

plot(z, "Spread Z-score", color = z_col, linewidth = 2)
hline( extreme_z, "Extreme high (FCPO rich vs BO)", color = color.new(#FF3B5C, 50), linestyle = hline.style_dashed)
hline(-extreme_z, "Extreme low (FCPO cheap vs BO)", color = color.new(#1FC77E, 50), linestyle = hline.style_dashed)
hline( 1.0, "+1 sigma", color = color.new(#E0B544, 70), linestyle = hline.style_dotted)
hline(-1.0, "-1 sigma", color = color.new(#E0B544, 70), linestyle = hline.style_dotted)
hline( 0.0, "Mean", color = color.new(color.gray, 50))

// Background tint when z extreme (silent, light)
bgcolor(extreme_high ? color.new(#FF3B5C, 92) : extreme_low ? color.new(#1FC77E, 92) : na, title = "Extreme z")

// ── Status table ──
var table tbl = table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • Soyoil Spread", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 1, "FCPO", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, str.tostring(fcpo_d, "#.##"), text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 0, 2, "CBOT BO (ZL)", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, str.tostring(bo, "#.##"), text_color = color.white, text_size = size.tiny)
    z_lbl = str.tostring(z, "+#.##;-#.##")
    table.cell(tbl, 0, 3, "Spread z", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, z_lbl, text_color = z_col, text_size = size.small)
    state_lbl = extreme_high ? "★ FCPO RICH (mean-revert short bias)" : extreme_low ? "★ FCPO CHEAP (mean-revert long bias)" : moderate_high or moderate_low ? "Stretched (1σ)" : "Normal range"
    state_col = extreme_high ? #FF3B5C : extreme_low ? #1FC77E : color.new(color.white, 60)
    table.cell(tbl, 0, 4, "State", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, state_lbl, text_color = state_col, text_size = size.tiny)
    table.cell(tbl, 0, 5, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, "wick, regime, myr-context", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Chainable boolean outputs ──
plot(z,                      "spread_z",      display = display.data_window)
plot(ratio,                  "fcpo_bo_ratio", display = display.data_window)
plot(extreme_high ? 1 : 0,   "z_extreme_high", display = display.data_window)
plot(extreme_low ? 1 : 0,    "z_extreme_low",  display = display.data_window)
plot(bo,                     "bo_close",       display = display.data_window)
````
