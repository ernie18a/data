# BNS Jump Statistic & RV Decomposition

- url: https://www.tradingview.com/script/1YGkNn85-BNS-Jump-Statistic-RV-Decomposition/
- type: indicator
- pine_id: PUB;9b7687bda86d4cf38780ffa0b0a71a70
- version: 1.0

## Description

[b]BNS Jump Statistic & RV Decomposition[/b]

A jump-detection oscillator that splits realized variance into a continuous (diffusive) component and a jump component, using the bipower variation framework of Barndorff-Nielsen and Shephard. It answers a specific question: how much of recent volatility is everyday noise, and how much is sudden, discontinuous moves?

[b]How it works[/b]
Over a rolling window of length N, three quantities are computed from log returns:
[list]
[*]Realized Variance (RV) — the sum of squared returns. Captures everything: continuous variance plus any jumps.
[*]Bipower Variation (BV) — the (π/2)-scaled sum of |r_t|·|r_{t−1}|. Asymptotically robust to jumps, so it captures only the continuous part.
[*]Jump component (J) — max(RV − BV, 0), the variance left over after subtracting the continuous estimate.
[/list]
The Relative Jump (RJ) ratio is J / RV — the share of variance attributable to jumps. Bounded between 0 and 1: zero means all-continuous, one means all-jump.
The BNS z-statistic (ratio form, with the Huang–Tauchen adjustment) tests whether the jump component is statistically significant. It uses tripower quarticity for a robust standard error:
[pine]z = √N · RJ / √( θ · max(1, TQ/BV²) ),  with θ = π²/4 + π − 5[/pine]
Under the null of no jumps, z is asymptotically standard normal. Critical values at 1.96, 2.58, and 3.09 correspond to 95%, 99%, and 99.9% confidence.

[b]How to read it[/b]
[list]
[*]Columns show the RJ ratio. Cool cyan when variance is mostly continuous; amber and rose as the jump share rises.
[*]Smoothed line is a 3-bar EMA of RJ, layered with a soft glow. The line color tracks the regime — useful for spotting persistent jump activity versus one-off spikes.
[*]Reference levels at 20%, 50%, and 80% mark the continuous threshold, the regime boundary, and the extreme zone.
[*]Markers above the pane fire on bars where the BNS test is significant: a circle at 95%, a triangle at 99%, a diamond at 99.9%.
[*]Background tint reflects the regime state (CONTINUOUS, MIXED, or JUMP), with hysteresis so it doesn't flicker on borderline bars.
[*]Status table in the top-right shows the latest RV, BV, jump component, RJ, z-statistic, and current significance level.
[/list]

[b]Inputs[/b]
[list]
[*]Window Length — bars used to compute RV and BV. 22 ≈ one trading month on daily. Default 22.
[*]Source — input series. Default close.
[*]Significance thresholds — z-values for 95%, 99%, and 99.9% confidence. Defaults 1.96, 2.58, 3.09.
[*]Regime thresholds — RJ levels marking the continuous and jump regimes. Defaults 0.20 and 0.50.
[*]Display toggles — status table, regime tint, significance markers, and reference levels.
[/list]

[b]Built-in alerts[/b]
[list]
[*]Significant Jump (95%) — z crosses above 1.96
[*]Strong Jump (99%) — z crosses above 2.58
[*]Extreme Jump (99.9%) — z crosses above 3.09
[*]Entered Jump Regime
[*]Returned to Continuous Regime
[/list]
All alerts fire on the rising edge of their event — one notification per transition rather than one per bar while the condition holds.

[b]Notes[/b]
The decomposition is a property of the chosen window. Different lengths give different splits; shorter windows are more responsive but noisier. The z-statistic is asymptotic, so very short windows can produce inflated values — treat anything below N=10 with care.
Bipower variation is robust to jumps in theory but sensitive to microstructure noise on very fine timeframes. Daily and 5-minute-and-up tend to behave well.
This is a diagnostic tool, not a signal generator. It tells you when variance is being driven by jumps rather than diffusion.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//                  BNS Jump Statistic & RV Decomposition
//                  ──────────────────────────────────────
//   Decomposes realized variance into continuous (diffusive) and jump
//   components using bipower variation, following Barndorff-Nielsen and
//   Shephard. The Relative Jump (RJ) ratio shows what fraction of variance
//   is attributable to jumps; the BNS z-statistic (ratio form) tests
//   significance against the no-jump null using tripower quarticity for a
//   robust standard error.
//
//   Reference:
//     Barndorff-Nielsen, O. E. & Shephard, N. (2006).
//     Econometrics of Testing for Jumps in Financial Economics Using
//     Bipower Variation. Journal of Financial Econometrics, 4(1), 1–30.
//
//   License : MPL-2.0
//   Version : 1.0
// ─────────────────────────────────────────────────────────────────────────────

indicator("BNS Jump Statistic & RV Decomposition", "BNS Jump", overlay=false, format=format.percent, precision=1)


// ── Inputs ───────────────────────────────────────────────────────────────────
length    = input.int(22, "Window Length", minval=5, maxval=500, group="Calculation", tooltip="Bars used to compute realized variance and bipower variation. 22 ≈ one trading month on daily.")
src       = input.source(close, "Source", group="Calculation")

z_warn    = input.float(1.96, "Significant (95%)", minval=0.5, step=0.1, group="Significance Thresholds", tooltip="z-statistic level for a significant jump under the no-jump null. 1.96 ≈ 95% confidence.")
z_strong  = input.float(2.58, "Strong (99%)",      minval=0.5, step=0.1, group="Significance Thresholds", tooltip="z-statistic level for a strongly significant jump. 2.58 ≈ 99%.")
z_extreme = input.float(3.09, "Extreme (99.9%)",   minval=0.5, step=0.1, group="Significance Thresholds", tooltip="z-statistic level for an extreme jump. 3.09 ≈ 99.9%.")

regime_lo = input.float(0.20, "Continuous Threshold", minval=0.0, maxval=1.0, step=0.05, group="Regime", tooltip="RJ below this marks the continuous regime (low jump activity).")
regime_hi = input.float(0.50, "Jump Threshold",       minval=0.0, maxval=1.0, step=0.05, group="Regime", tooltip="RJ above this marks the jump-dominated regime.")

show_table  = input.bool(true, "Show Status Table",         group="Display")
show_bg     = input.bool(true, "Tint Background by Regime", group="Display")
show_marks  = input.bool(true, "Show Significance Markers", group="Display")
show_levels = input.bool(true, "Show Reference Levels",     group="Display")


// ── Palette ──────────────────────────────────────────────────────────────────
//   Cool cyan when variance is mostly continuous; warm rose when jumps dominate; amber bridges the middle so the gradient interpolates cleanly.
col_cool      = #26c6da
col_cool_dim  = #4dd0e1
col_warm_mid  = #ffa726
col_warm      = #ff5252
col_extreme   = #c2185b
col_neutral   = #78909c


// ── Returns ──────────────────────────────────────────────────────────────────
r     = math.log(src) - math.log(src[1])
abs_r = math.abs(r)


// ── Realized Variance ────────────────────────────────────────────────────────
//   RV_t = Σ r²_{t-i} for i = 0..N-1
rv = math.sum(r * r, length)


// ── Bipower Variation ────────────────────────────────────────────────────────
//   BV_t = (π/2) × Σ |r_i| × |r_{i-1}|
mu1_inv_sq = math.pi / 2.0
bv         = mu1_inv_sq * math.sum(abs_r * abs_r[1], length - 1)


// ── Tripower Quarticity (robust variance for the test statistic) ─────────────
//   TQ_t = N × μ_{4/3}^{-3} × Σ |r|^{4/3} × |r_{-1}|^{4/3} × |r_{-2}|^{4/3} μ_{4/3} = 2^{2/3} · Γ(7/6) / √π ≈ 0.83098, so μ_{4/3}^{-3} ≈ 1.7425.
mu43_inv3 = 1.7425
abs_r_43  = math.pow(abs_r, 4.0 / 3.0)
tq        = length * mu43_inv3 * math.sum(abs_r_43 * abs_r_43[1] * abs_r_43[2], length - 2)


// ── Decomposition ────────────────────────────────────────────────────────────
jump = math.max(0.0, rv - bv)                  // truncated jump component
cont = bv                                       // continuous component
rj_raw     = rv > 0 ? (rv - bv) / rv : 0.0      // signed; used in the test
rj_display = rv > 0 ? jump / rv      : 0.0      // truncated; plotted


// ── BNS z-statistic (ratio form, Huang-Tauchen adjustment) ───────────────────
//   z = √N · RJ / √( θ · max(1, TQ/BV²) ),    θ = π²/4 + π − 5 ≈ 0.6090
theta = math.pow(math.pi, 2) / 4.0 + math.pi - 5.0
infl  = bv > 0 ? math.max(1.0, tq / (bv * bv)) : 1.0
z     = bv > 0 ? math.sqrt(length) * rj_raw / math.sqrt(theta * infl) : 0.0


// ── Smoothing ────────────────────────────────────────────────────────────────
rj_smooth = ta.ema(rj_display, 3)


// ── Regime state machine (with hysteresis around the band midpoint) ──────────
mid = (regime_lo + regime_hi) / 2.0
var string regime = "CONTINUOUS"
regime := rj_smooth <= regime_lo                        ? "CONTINUOUS" :
          rj_smooth >= regime_hi                        ? "JUMP"       :
          (regime == "JUMP"       and rj_smooth > mid)  ? "JUMP"       :
          (regime == "CONTINUOUS" and rj_smooth < mid)  ? "CONTINUOUS" :
                                                          "MIXED"


// ── Significance flags (banded so each shape fires alone) ────────────────────
sig_95  = z >= z_warn    and z < z_strong
sig_99  = z >= z_strong  and z < z_extreme
sig_999 = z >= z_extreme


// ── Reference levels ─────────────────────────────────────────────────────────
hl_disp = show_levels ? display.all : display.none
hline(regime_lo, "Continuous threshold", color=color.new(col_cool,    55), linestyle=hline.style_dashed, display=hl_disp)
hline(regime_hi, "Jump threshold",       color=color.new(col_warm,    55), linestyle=hline.style_dashed, display=hl_disp)
hline(0.80,      "Extreme zone",         color=color.new(col_extreme, 70), linestyle=hline.style_dotted, display=hl_disp)


// ── RJ columns coloured by intensity (3-stop gradient through amber) ─────────
col_rj = rj_display < 0.35
       ? color.from_gradient(rj_display, 0.0,  0.35, col_cool,     col_warm_mid)
       : color.from_gradient(rj_display, 0.35, 1.0,  col_warm_mid, col_warm)
plot(rj_display, "RJ Ratio", color=color.new(col_rj, 20), style=plot.style_columns, linewidth=1)


// ── RJ smoothed line with layered glow ───────────────────────────────────────
col_line = rj_smooth < 0.40
         ? color.from_gradient(rj_smooth, 0.0,  0.40, col_cool,     col_warm_mid)
         : color.from_gradient(rj_smooth, 0.40, 0.80, col_warm_mid, col_warm)
plot(rj_smooth, "RJ Smoothed (halo)", color=color.new(col_line, 88), linewidth=8)
plot(rj_smooth, "RJ Smoothed (glow)", color=color.new(col_line, 70), linewidth=5)
plot(rj_smooth, "RJ Smoothed",        color=color.new(col_line, 15), linewidth=2)


// ── Significance markers above the pane ──────────────────────────────────────
mk_disp = show_marks ? display.all : display.none
plotshape(sig_95,  title="Significant (95%)",          style=shape.circle,     location=location.top, color=color.new(col_warm_mid, 25), size=size.tiny,  display=mk_disp)
plotshape(sig_99,  title="Strongly Significant (99%)", style=shape.triangleup, location=location.top, color=color.new(col_warm,     10), size=size.tiny,  display=mk_disp)
plotshape(sig_999, title="Extreme (99.9%)",            style=shape.diamond,    location=location.top, color=color.new(col_extreme,   0), size=size.small, display=mk_disp)


// ── Background tint by regime (very subtle) ──────────────────────────────────
bg_color = not show_bg                  ? na :
           regime == "CONTINUOUS"       ? color.new(col_cool, 94) :
           regime == "JUMP"             ? color.new(col_warm, 91) :
                                          na
bgcolor(bg_color, title="Regime tint")


// ── Status table (current-bar readout, rendered only on the last bar) ────────
var table t = table.new(position.top_right, 2, 8,
                        border_width=0,
                        frame_color=color.new(chart.fg_color, 80),
                        frame_width=1)

if barstate.islast
    if show_table
        string sig_label = sig_999 ? "99.9%" : sig_99 ? "99%" : sig_95 ? "95%" : "—"
        color  reg_color = regime == "CONTINUOUS" ? col_cool : regime == "JUMP" ? col_warm : col_neutral
        color  sig_color = sig_999 ? col_extreme : sig_99 ? col_warm : sig_95 ? col_warm_mid : col_neutral

        table.cell(t, 0, 0, "BNS JUMP / RV", bgcolor=color.new(col_cool, 55), text_color=color.white,    text_size=size.small)
        table.cell(t, 1, 0, "",              bgcolor=color.new(col_cool, 55))

        table.cell(t, 0, 1, "Regime",        text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 1, regime,          text_color=reg_color, text_size=size.small)

        table.cell(t, 0, 2, "RV  (×10⁻⁴)",  text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 2, str.tostring(rv   * 10000.0, "#.###"), text_color=chart.fg_color, text_size=size.small)

        table.cell(t, 0, 3, "BV  (×10⁻⁴)",  text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 3, str.tostring(bv   * 10000.0, "#.###"), text_color=chart.fg_color, text_size=size.small)

        table.cell(t, 0, 4, "Jump (×10⁻⁴)", text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 4, str.tostring(jump * 10000.0, "#.###"), text_color=chart.fg_color, text_size=size.small)

        table.cell(t, 0, 5, "RJ",            text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 5, str.tostring(rj_display * 100.0, "#.##") + "%", text_color=chart.fg_color, text_size=size.small)

        table.cell(t, 0, 6, "z-stat",        text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 6, str.tostring(z, "#.##"), text_color=chart.fg_color, text_size=size.small)

        table.cell(t, 0, 7, "Significance",  text_color=chart.fg_color, text_size=size.small)
        table.cell(t, 1, 7, sig_label,       text_color=sig_color, text_size=size.small)
    else
        table.clear(t, 0, 0, 1, 7)


// ── Alerts (rising-edge transitions only — no spam while state is held) ──────
to_jump       = regime == "JUMP"       and regime[1] != "JUMP"
to_continuous = regime == "CONTINUOUS" and regime[1] != "CONTINUOUS"

alertcondition(ta.crossover(z, z_warn),    title="Significant Jump (95%)", message="BNS z-statistic crossed the 95% threshold — a significant jump is detected in realized variance.")
alertcondition(ta.crossover(z, z_strong),  title="Strong Jump (99%)", message="BNS z-statistic crossed the 99% threshold — a strongly significant jump is detected.")
alertcondition(ta.crossover(z, z_extreme), title="Extreme Jump (99.9%)", message="BNS z-statistic crossed the 99.9% threshold — an extreme jump event is detected.")
alertcondition(to_jump,                    title="Entered Jump Regime", message="Realized variance entered the jump-dominated regime.")
alertcondition(to_continuous,              title="Returned to Continuous", message="Realized variance returned to the continuous (low-jump) regime.")
````
