# iFCPO Regime Meter

- url: https://www.tradingview.com/script/vkSoMJYZ-iFCPO-Regime-Meter/
- type: indicator
- pine_id: PUB;c52aa7c5256e42dabd7993e606167eac
- version: 3.0

## Description

iFCPO Regime Meter — Dual gate trade filter for FCPO.

Combines two research-anchored conditions:
1. ADX(14) >= 15 (W32 cutoff) — trend strength minimum
2. Close > D1 EMA200 (W33) — bullish regime

Both ON = TRADE OK (green bg). Either ON = PARTIAL (amber). Both OFF = AVOID (red). Outputs adx_ok/regime_ok/both_ok booleans for chaining.

FREE indicator from iFCPO — Malaysia palm-oil futures trading platform.

## Source Code

````pine
//@version=6
// iFCPO Regime Meter — ADX strength + D1 EMA200 dual gate
// Tier: FREE | Category: Trend | Free-Tier GATE layer
// Research anchor: W32 (ADX>=15 confirmed marginal noise floor) + W33 (D1 EMA200 = irreplaceable bias)
// W34 confirmed: position vs EMA200 = the only valid form (slope-based gate fires near zero trades)
// Pair with: wick-hunter-lite (entry trigger), session-law-enforcer (window), holiday-skip (block), mpob-cycle-clock + soyoil-spread (macro framing)
indicator("iFCPO Regime Meter", "iFCPO Regm", overlay = true)

// ── Inputs ──
adx_cut       = input.int(15, "ADX cutoff (W32)", minval = 5, maxval = 40, group = "Filters")
ema_period_d1 = input.int(200, "D1 EMA period (W33)", minval = 50, maxval = 400, group = "Filters")
show_table    = input.bool(true, "Show research stats table", group = "Display")
show_ema_line = input.bool(true, "Plot D1 EMA200 line",       group = "Display")
table_pos     = input.string("top_left", "Table position", options = ["top_right","top_left","bottom_right","bottom_left"], group = "Display")

// ── Calculations ──
[di_p, di_m, adxv] = ta.dmi(14, 14)
// Use [1] inside security() to lock to confirmed daily bar — prevents intraday repaint on today's still-forming D1 candle
ema_d1 = request.security(syminfo.tickerid, "D", ta.ema(close, ema_period_d1)[1], lookahead = barmerge.lookahead_off)

adx_ok    = adxv >= adx_cut
adx_rising = adxv > adxv[3]
regime_ok = close > ema_d1
both_ok   = adx_ok and regime_ok

// ── Distance from EMA200 in points ──
dist_from_ema = close - ema_d1
dist_pct = ema_d1 > 0 ? (dist_from_ema / ema_d1) * 100 : na

// ── Regime persistence (bars since regime flip) ──
regime_flipped = ta.change(regime_ok ? 1 : 0) != 0
var int bars_in_regime = 0
bars_in_regime := regime_flipped ? 0 : bars_in_regime + 1

// ── Visualization ──
plot(show_ema_line ? ema_d1 : na, "D1 EMA200", color = color.new(#3B82F6, 0), linewidth = 2)

// Background tinted by composite regime state
bg_col = both_ok ? color.new(#1FC77E, 92) : adx_ok or regime_ok ? color.new(#E0B544, 95) : color.new(#FF3B5C, 95)
bgcolor(bg_col, title = "Regime")

// ── Status table ──
tbl_pos = table_pos == "top_right" ? position.top_right : table_pos == "top_left" ? position.top_left : table_pos == "bottom_right" ? position.bottom_right : position.bottom_left
var table tbl = table.new(tbl_pos, 2, 9, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • Regime Meter", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    // ADX strength
    adx_col = adx_ok ? #1FC77E : #FF3B5C
    adx_lbl = "ADX " + str.tostring(adxv, "#.#") + (adx_rising ? " ▲" : " ▼")
    table.cell(tbl, 0, 1, adx_lbl, text_color = color.white, text_size = size.tiny)
    table.cell(tbl, 1, 1, adx_ok ? "ON (>=" + str.tostring(adx_cut) + ")" : "OFF", text_color = adx_col, text_size = size.tiny)
    // D1 EMA200 position
    reg_col = regime_ok ? #1FC77E : #FF3B5C
    table.cell(tbl, 0, 2, "D1 EMA200", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, regime_ok ? "above" : "below", text_color = reg_col, text_size = size.tiny)
    // Distance from EMA
    dist_col = math.abs(dist_pct) > 5 ? #E0B544 : color.new(color.white, 30)
    table.cell(tbl, 0, 3, "Distance", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, str.tostring(dist_from_ema, "+#.##;-#.##") + " (" + str.tostring(dist_pct, "+#.#;-#.#") + "%)", text_color = dist_col, text_size = size.tiny)
    // DI direction
    di_diff = di_p - di_m
    di_col = di_diff > 0 ? #1FC77E : #FF3B5C
    di_lbl = di_diff > 0 ? "+DI lead" : "-DI lead"
    table.cell(tbl, 0, 4, "DI direction", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, di_lbl + " (" + str.tostring(math.abs(di_diff), "#.#") + ")", text_color = di_col, text_size = size.tiny)
    // Bars in regime
    table.cell(tbl, 0, 5, "Regime age", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, str.tostring(bars_in_regime) + " bars", text_color = color.new(color.white, 80), text_size = size.tiny)
    // Decision
    overall_col = both_ok ? #1FC77E : adx_ok or regime_ok ? #E0B544 : #FF3B5C
    overall_lbl = both_ok ? "★ TRADE OK" : adx_ok or regime_ok ? "PARTIAL" : "AVOID"
    table.cell(tbl, 0, 6, "Decision", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 6, overall_lbl, text_color = overall_col, text_size = size.small)
    // Research provenance
    table.cell(tbl, 0, 7, "W32+W33 KPI", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 7, "EMA200 irreplaceable", text_color = color.new(color.white, 80), text_size = size.tiny)
    // Pair-with
    table.cell(tbl, 0, 8, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 8, "wick-hunter, session-law", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Alerts ──
alertcondition(both_ok and not (both_ok[1]), title = "Regime TRADE OK", message = "iFCPO Regime flipped to TRADE OK — ADX>=cutoff and above D1 EMA200.")
alertcondition(not both_ok and (both_ok[1]), title = "Regime AVOID", message = "iFCPO Regime degraded — close attention required.")

// ── Chainable boolean outputs ──
plot(adxv,                "adx",            display = display.data_window)
plot(adx_ok ? 1 : 0,      "adx_ok",         display = display.data_window)
plot(regime_ok ? 1 : 0,   "regime_ok",      display = display.data_window)
plot(both_ok ? 1 : 0,     "both_ok",        display = display.data_window)
plot(dist_from_ema,       "dist_from_ema",  display = display.data_window)
plot(bars_in_regime,      "bars_in_regime", display = display.data_window)
````
