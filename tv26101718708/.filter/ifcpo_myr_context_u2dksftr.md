# iFCPO MYR Context

- url: https://www.tradingview.com/script/U2DKsFTr-iFCPO-MYR-Context/
- type: indicator
- pine_id: PUB;55614166289642a280928e7407d9885b
- version: 2.0

## Description

iFCPO MYR Context — USDMYR strength gauge + 30-day FCPO↔USDMYR correlation flag for Bursa Crude Palm Oil Futures.

WHY IT MATTERS
The Malaysian ringgit drives FCPO export competitiveness. Soft MYR (USDMYR rising) makes Malaysian palm oil cheaper for foreign buyers — bullish FCPO. Strong MYR (USDMYR falling) hurts exporters — bearish FCPO. But the FCPO/MYR relationship isn't always live: when correlation is decoupled (|r| < 0.3), the MYR signal is noise. This indicator gauges both USDMYR strength AND tells you when to listen.

HOW TO USE
- USDMYR > 30-day MA by +0.5%: Soft MYR — FCPO tailwind (bullish bias)
- USDMYR < 30-day MA by −0.5%: Strong MYR — FCPO headwind (bearish bias)
- |corr| > 0.5: Relationship is live — apply MYR bias
- |corr| < 0.3: Decoupled — IGNORE the MYR signal entirely

This is a SIZE / SL MODIFIER — it adjusts conviction, not entries. Pair with iFCPO Wick Hunter (entries) + iFCPO Regime Meter (regime) + iFCPO Session Law (timing).

KPIs
- Lookback: 30 daily bars (configurable)
- Strong correlation threshold: |r| ≥ 0.5
- Default symbol: FX_IDC:USDMYR (free TV symbol)

OUTPUTS
USDMYR daily, % deviation vs 30-day MA, 30-day FCPO↔USDMYR correlation, color-graded line (green soft / red strong / grey neutral), full status table top-right (USDMYR, deviation %, correlation strength, bias, pair-with).

Open-source. Part of the iFCPO free hero stack.

## Source Code

````pine
//@version=6
// iFCPO MYR/FCPO Context — USDMYR strength gauge + 30-day correlation flag
// Tier: FREE | Category: Cross-Market | Free-Tier CONTEXT layer (silent)
// Heuristic: Soft MYR (USDMYR rising) = bullish FCPO (Malaysian palm oil exports cheaper for foreign buyers).
//            Strong MYR (USDMYR falling) = bearish FCPO (export competitiveness reduced).
// This is a macro rule-of-thumb — the correlation flag below tells you whether it's currently active.
// Correlation flag: when |r| > 0.5 over 30 days the relationship matters; when decoupled (|r| < 0.3) ignore the MYR signal.
// USE AS SIZE/SL MODIFIER — not entry. Pair with wick-hunter-lite for actual triggers.
indicator("iFCPO MYR Context", "iFCPO MYR", overlay = false)

// ── Inputs ──
myr_sym       = input.symbol("FX_IDC:USDMYR", "USDMYR symbol", group = "Symbols",
   tooltip = "FX_IDC:USDMYR is the standard free symbol. Fallbacks: OANDA:USDMYR, FX:USDMYR.")
corr_period   = input.int(30, "Correlation lookback (days)", minval = 10, group = "Stats")
strong_corr   = input.float(0.5, "Strong correlation threshold |r|", minval = 0.3, maxval = 0.9, step = 0.05, group = "Stats")
show_table    = input.bool(true, "Show MYR gauge table", group = "Display")
show_myr_line = input.bool(true, "Plot USDMYR line (subplot)", group = "Display")

// ── Pull USDMYR daily — uses [1] inside security() to lock to confirmed daily bar (no intraday repaint)
usdmyr = request.security(myr_sym, "D", close[1], lookahead = barmerge.lookahead_off)

// ── 30-day MYR strength: % change vs 30-day MA ──
myr_ma = ta.sma(usdmyr, corr_period)
myr_strength_pct = myr_ma > 0 ? ((usdmyr - myr_ma) / myr_ma) * 100 : na
// Positive = USDMYR above MA = MYR weak = bullish FCPO bias

// ── Correlation FCPO ↔ USDMYR over 30 days (both use confirmed daily closes, no repaint) ──
fcpo_d = request.security(syminfo.tickerid, "D", close[1], lookahead = barmerge.lookahead_off)
corr = ta.correlation(fcpo_d, usdmyr, corr_period)
corr_strong = math.abs(corr) >= strong_corr

// ── Bias label ──
myr_bias = myr_strength_pct > 0.5 ? "Soft MYR — bullish FCPO tailwind" : myr_strength_pct < -0.5 ? "Strong MYR — bearish FCPO headwind" : "MYR neutral"
bias_col = myr_strength_pct > 0.5 ? #1FC77E : myr_strength_pct < -0.5 ? #FF3B5C : color.new(color.white, 50)

// ── Correlation usefulness flag ──
corr_lbl = corr_strong ? (corr < 0 ? "INVERSE r=" + str.tostring(corr, "#.##") : "POSITIVE r=" + str.tostring(corr, "#.##")) : "Decoupled (ignore)"
corr_col = corr_strong ? color.new(color.white, 30) : color.new(color.white, 60)

// ── Visualization ──
plot(show_myr_line ? myr_strength_pct : na, "MYR % vs 30-day MA", color = bias_col, linewidth = 2)
hline( 0, "MA",  color = color.new(color.gray, 50))
hline( 1, "Soft MYR (bullish)", color = color.new(#1FC77E, 70), linestyle = hline.style_dotted)
hline(-1, "Strong MYR (bearish)", color = color.new(#FF3B5C, 70), linestyle = hline.style_dotted)

// ── Status table ──
var table tbl = table.new(position.top_right, 2, 6, bgcolor = color.new(color.black, 15), border_width = 1, border_color = color.new(color.gray, 60))
if show_table and barstate.islast
    table.cell(tbl, 0, 0, "iFCPO • MYR Context", bgcolor = color.new(#3B82F6, 30), text_color = color.white, text_size = size.small)
    table.merge_cells(tbl, 0, 0, 1, 0)
    table.cell(tbl, 0, 1, "USDMYR", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 1, str.tostring(usdmyr, "#.####"), text_color = color.white, text_size = size.tiny)
    pct_col = math.abs(myr_strength_pct) > 0.5 ? bias_col : color.new(color.white, 50)
    table.cell(tbl, 0, 2, "vs 30d MA", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 2, str.tostring(myr_strength_pct, "+#.##;-#.##") + "%", text_color = pct_col, text_size = size.tiny)
    table.cell(tbl, 0, 3, "Correlation", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 3, corr_lbl, text_color = corr_col, text_size = size.tiny)
    table.cell(tbl, 0, 4, "Bias", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 4, corr_strong ? myr_bias : "Ignore (decoupled)", text_color = corr_strong ? bias_col : color.new(color.white, 50), text_size = size.small)
    table.cell(tbl, 0, 5, "Pair with", text_color = color.new(color.white, 30), text_size = size.tiny)
    table.cell(tbl, 1, 5, "wick, regime, soyoil-spread", text_color = color.new(#3B82F6, 0), text_size = size.tiny)

// ── Chainable boolean outputs ──
plot(usdmyr,                "usdmyr",          display = display.data_window)
plot(myr_strength_pct,      "myr_pct_vs_ma",   display = display.data_window)
plot(corr,                  "fcpo_myr_corr",   display = display.data_window)
plot(corr_strong ? 1 : 0,   "corr_strong",     display = display.data_window)
plot(myr_strength_pct > 0.5 ? 1 : 0, "myr_soft_bull", display = display.data_window)
plot(myr_strength_pct < -0.5 ? 1 : 0, "myr_strong_bear", display = display.data_window)
````
