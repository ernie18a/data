# GBM Projection Cone (Ito)

- url: https://www.tradingview.com/script/BuGgbYp3-GBM-Projection-Cone-Ito/
- type: indicator
- pine_id: PUB;a9ce527488bf4551b20b0b9c72400e34
- version: 1.0

## Description

[b]GBM Projection Cone (Itō)[/b]

A geometric Brownian motion probability cone derived analytically from Itō's lemma — no random simulation required, no path-to-path variance, identical output on every reload. The cone shows where price should be in the future under a GBM model fitted to the recent log-return distribution.
The output is three concentric ±σ bands (68%, 95%, 99.7%), the arithmetic-mean path, and the Itō-corrected median path. The visible gap between mean and median is the Jensen gap — the systematic divergence that pure-arithmetic forecasting hides and lognormal compounding requires you to acknowledge.

[b]How it works[/b]

Applying Itō's lemma to f(S, t) = ln(S):
[pine]d(ln S) = (μ − σ²/2) dt + σ dW[/pine]
so under GBM the log-price is normally distributed:
[pine]ln(S_t) ~ N(ln S₀ + (μ − σ²/2)·t,  σ²·t)[/pine]

Drift μ and volatility σ are estimated from the most recent N bars of log-returns (sample mean and sample standard deviation). Percentile bands at ±kσ come straight out of the normal CDF in log-space and exponentiate back to price-space, giving the asymmetric cone characteristic of GBM.
Two center lines are computed because they answer different questions:[list]
[*]Arithmetic mean path — E[S_t] = S₀·exp(μ·t). The ensemble average across all GBM paths.
[*]Itō-corrected median path — S₀·exp((μ − σ²/2)·t). The most probable single trajectory.[/list]

The mean is always above the median by Jensen's inequality, with the gap widening as volatility rises. Both are plotted so the gap is always visible.
An optional Monte Carlo overlay simulates independent GBM paths via Box-Muller normal sampling. It's there for pedagogical comparison against the closed form, not for production analysis — Monte Carlo paths re-roll on every reload. Off by default.

[b]How to read it[/b]

The cone shows the analytical confidence regions of the projected price distribution:[list]
[*]±1σ (68.3%) — the central body of likely outcomes
[*]±2σ (95.4%) — out to the edge of normal-regime expectations
[*]±3σ (99.7%) — beyond which an excursion would be unusually extreme under the assumed GBM dynamics[/list]

Inner bands are drawn thicker and more saturated; outer bands are thin and translucent. Endpoint labels at the right edge mark the projected price at each ±σ level at the cone's terminal bar.
The two center paths — mean (default amber) and median (default off-white) — diverge as time and volatility accumulate. Reading the divergence: a wide Jensen gap means the asset is in a high-volatility regime where ensemble-average forecasts overstate where any individual trajectory is likely to land. The median is the more honest answer for a single realised path.
The bottom-right parameter table reports estimated μ, σ, the Itō correction (−σ²/2), and the resulting Itō drift (μ − σ²/2). When the Itō drift turns negative while μ is still positive, volatility drag is overwhelming directional drift — the asset is positive-EV in expectation but negative-EV in the most-probable case.

[b]Inputs[/b][list]
[*]Estimation window — bars used to estimate μ and σ from observed log-returns. Default 20. Smaller windows track the recent regime; larger smooth out noise.
[*]Projection bars — how many bars ahead to project. Default 20. Cone width grows with σ√t — longer horizons fan out faster under high volatility.
[*]Bands — toggle ±1σ, ±2σ, ±3σ independently. Defaults: 1σ and 2σ on, 3σ off.
[*]Mean path — show the arithmetic expected-value path. Default on.
[*]Median path — show the Itō-corrected median path. Default on.
[*]Endpoint labels — price labels at the right edge of each band. Default on.
[*]Parameter table — bottom-right μ/σ/Itō readout. Default on.
[*]Monte Carlo overlay — draw N random GBM realisations for comparison. Default off, non-deterministic.
[*]Path count — number of MC paths when overlay is on. Default 20.
[*]Colors — cone, mean path, median path.[/list]

[b]Built-in alerts[/b][list]
[*]Volatility spike — σ rises above 1.5× its rolling average
[*]Drift turned negative — μ crosses below zero
[*]Drift turned positive — μ crosses above zero
[*]Itō drift crossed below zero — μ − σ²/2 turns negative (volatility drag now outpaces drift)
[*]Itō drift crossed above zero — μ − σ²/2 recovers above zero[/list]
The Itō-drift alerts are the more practically useful pair. A positive arithmetic μ with negative Itō drift describes the textbook scenario where a volatile asset has positive expected return but a negative typical return — the regime where naïve EV calculations mislead position sizing.

[b]Notes[/b]

GBM is a model. Real returns aren't truly lognormal — they exhibit fat tails, autocorrelation, and volatility clustering that GBM's i.i.d. assumption can't capture. The cone is calibrated to what the recent N bars would project forward if returns continued behaving as estimated; the more the underlying violates the model's assumptions, the less the cone reflects realised probabilities.
That said, GBM remains useful as a baseline. Most options-pricing intuition, microstructure tooling, and risk-management frameworks assume GBM-like dynamics. The cone gives you the model's own opinion about where price is likely to go — informative even when the model is wrong, because the direction and magnitude of disagreement between cone and realised price is itself signal.
The closed-form derivation is deterministic on purpose. Two reloads of the same chart produce identical cones; two reloads with the Monte Carlo overlay produce visibly different paths. For production analysis, leave Monte Carlo off. To teach yourself how MC converges to the closed form, turn it on and watch the random paths fill the bands as you increase path count.
The Itō correction (−σ²/2) is small for low-volatility assets and dominant for high-volatility ones. On a daily chart of a major equity index it's a fraction of a basis point per day; on a high-frequency crypto chart it can outweigh the directional drift entirely. The parameter table makes this visible.
This is a diagnostic tool, not a signal generator. It tells you what GBM thinks the next N bars look like.

[i]Five years of work on a trading system left me with dozens of indicators that ultimately didn't earn a place in the final build. They're not failures — they're tools that solved problems I no longer needed solved. So instead of shelving them, I'm publishing the majority of them open-source.
If you're a discretionary trader, take what's useful. If you're a systems builder, the source is yours to dissect, modify, and improve. The best return on five years of work is for it to keep working — for someone.
If you use this script — or part of it — in your own work, please credit the original with a link back to my profile.
Note: these indicators have been updated to Pine Script v6 — some manually, some with AI assistance.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeSymbiotic
// If you are using (part of) this PineScript - please give credits with tag.

// ─────────────────────────────────────────────────────────────────────────────
//                GBM Projection Cone (Itō)
//                ───────────────────────────
//   Derives the GBM probability cone analytically from Itō's lemma rather
//   than simulating random paths.  Applying Itō's lemma to f(S,t) = ln(S):
//     d(ln S) = (μ − σ²/2) dt + σ dW
//   so ln(S_t) ~ N(ln S₀ + (μ−σ²/2)t, σ²t).  Percentile bands come
//   straight out of the lognormal CDF — no Monte Carlo required, fully
//   deterministic, same cone on every reload.
//
//   Three concentric bands (±1σ / ±2σ / ±3σ, 68 / 95 / 99.7 %) use the
//   suite's tier-weight convention (thin outer → thick inner).  The
//   arithmetic mean path (E[S_t] = S₀·exp(μ·t)) and the Itō-corrected
//   median path (S₀·exp((μ−σ²/2)·t)) overlay the cone so the Jensen gap
//   between them is always visible.
//
//   An optional Monte Carlo overlay draws random GBM realisations via
//   Box-Muller normal sampling — useful for comparing simulation against
//   the closed form, but off by default because it is non-deterministic.
//
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("GBM Projection Cone (Itō)", shorttitle="GBM", overlay=true, max_polylines_count=60, max_labels_count=20)

// ── Inputs ───────────────────────────────────────────────────────────────────
lookback = input.int(20, "Estimation window", minval=5, maxval=500, group="Model", tooltip="Number of bars used to estimate drift (μ) and volatility (σ) from observed log-returns. Smaller windows track the recent regime; larger windows smooth out noise.")
n_proj   = input.int(20, "Projection bars",   minval=1, maxval=100, group="Model", tooltip="How many bars ahead to project the cone. Width grows with σ√t — longer horizons fan out faster under high volatility.")

show_3sig = input.bool(false, "±3σ  (99.7 %)", group="Bands")
show_2sig = input.bool(true,  "±2σ  (95.4 %)", group="Bands")
show_1sig = input.bool(true,  "±1σ  (68.3 %)", group="Bands")

show_mean   = input.bool(true, "Mean path (arithmetic EV)", group="Paths", tooltip="E[S_t] = S₀·exp(μ·t). The ensemble average across all GBM paths. Always above the median because of Jensen's inequality; the gap widens as volatility rises.")
show_median = input.bool(true, "Median path (Itō)",         group="Paths", tooltip="S₀·exp((μ − σ²/2)·t). The most probable single trajectory. Lower than the mean in every regime — the −σ²/2 Itō correction accounts for the asymmetry introduced by log-normal compounding.")
show_labels = input.bool(true, "Endpoint labels",           group="Paths")
show_table  = input.bool(true, "Parameter table",           group="Paths")

show_mc = input.bool(false, "Monte Carlo overlay", group="Monte Carlo", tooltip="Simulates independent GBM realisations using Box-Muller normal sampling. Non-deterministic — paths change on every reload. Compare to the analytical cone to see how well random simulation approximates the closed form.")
n_mc    = input.int(20, "Path count", minval=5, maxval=50, step=5, group="Monte Carlo")

cone_col   = input.color(#2196f3, "Cone",        group="Colors")
mean_col   = input.color(#f9a825, "Mean path",   group="Colors")
median_col = input.color(#eceff1, "Median path", group="Colors")

// ── Model ────────────────────────────────────────────────────────────────────
log_ret = math.log(close / close[1])
mu_bar  = ta.sma(log_ret, lookback)
var_bar = ta.variance(log_ret, lookback)
sig_bar = math.sqrt(math.max(var_bar, 0.0))
ito_mu  = mu_bar - var_bar / 2.0

// ── Box-Muller normal sampler ─────────────────────────────────────────────────
f_normal() =>
    u1 = math.random(1e-9, 1.0 - 1e-9)
    u2 = math.random(0.0, 1.0)
    math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)

// ── Right-edge label helper ───────────────────────────────────────────────────
f_lbl(ts, price, txt, col, trans) =>
    label.new(ts, price, txt + "  " + str.tostring(price, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(col, trans), textcolor=color.white, size=size.small)

// ── Drawing registries ────────────────────────────────────────────────────────
var polyline[] g_pls = array.new<polyline>(0)
var label[]    g_lbs = array.new<label>(0)
var table      g_tbl = na

// ── Rebuild at barstate.islast ────────────────────────────────────────────────
if barstate.islast and not na(mu_bar) and not na(sig_bar)

    // Delete previous drawings
    n_pl = array.size(g_pls)
    if n_pl > 0
        for i = 0 to n_pl - 1
            polyline.delete(array.get(g_pls, i))
    array.clear(g_pls)

    n_lb = array.size(g_lbs)
    if n_lb > 0
        for i = 0 to n_lb - 1
            label.delete(array.get(g_lbs, i))
    array.clear(g_lbs)

    s0      = close
    bar_dur = math.max(time - time[1], 1)   // ms per bar; derives natural spacing from the chart

    // ── Build forward path arrays ─────────────────────────────────────────────
    pts_mean   = array.new<chart.point>(n_proj + 1)
    pts_median = array.new<chart.point>(n_proj + 1)
    pts_u1 = array.new<chart.point>(n_proj + 1)
    pts_l1 = array.new<chart.point>(n_proj + 1)
    pts_u2 = array.new<chart.point>(n_proj + 1)
    pts_l2 = array.new<chart.point>(n_proj + 1)
    pts_u3 = array.new<chart.point>(n_proj + 1)
    pts_l3 = array.new<chart.point>(n_proj + 1)

    for n = 0 to n_proj
        ts    = time + n * bar_dur
        sqn   = math.sqrt(n)
        e_ito = ito_mu * n
        sprd  = sig_bar * sqn

        array.set(pts_mean,   n, chart.point.from_time(ts, s0 * math.exp(mu_bar * n)))
        array.set(pts_median, n, chart.point.from_time(ts, s0 * math.exp(e_ito)))
        array.set(pts_u1,     n, chart.point.from_time(ts, s0 * math.exp(e_ito + 1.0 * sprd)))
        array.set(pts_l1,     n, chart.point.from_time(ts, s0 * math.exp(e_ito - 1.0 * sprd)))
        array.set(pts_u2,     n, chart.point.from_time(ts, s0 * math.exp(e_ito + 2.0 * sprd)))
        array.set(pts_l2,     n, chart.point.from_time(ts, s0 * math.exp(e_ito - 2.0 * sprd)))
        array.set(pts_u3,     n, chart.point.from_time(ts, s0 * math.exp(e_ito + 3.0 * sprd)))
        array.set(pts_l3,     n, chart.point.from_time(ts, s0 * math.exp(e_ito - 3.0 * sprd)))

    // ── Draw cones (outermost first so inner cones layer on top) ──────────────
    if show_3sig
        c3 = array.new<chart.point>(0)
        for n = 0 to n_proj
            array.push(c3, array.get(pts_u3, n))
        for n = 0 to n_proj
            array.push(c3, array.get(pts_l3, n_proj - n))
        array.push(g_pls, polyline.new(c3, xloc=xloc.bar_time, closed=true, fill_color=color.new(cone_col, 92), line_color=color.new(cone_col, 68), line_width=1))

    if show_2sig
        c2 = array.new<chart.point>(0)
        for n = 0 to n_proj
            array.push(c2, array.get(pts_u2, n))
        for n = 0 to n_proj
            array.push(c2, array.get(pts_l2, n_proj - n))
        array.push(g_pls, polyline.new(c2, xloc=xloc.bar_time, closed=true, fill_color=color.new(cone_col, 85), line_color=color.new(cone_col, 52), line_width=2))

    if show_1sig
        c1 = array.new<chart.point>(0)
        for n = 0 to n_proj
            array.push(c1, array.get(pts_u1, n))
        for n = 0 to n_proj
            array.push(c1, array.get(pts_l1, n_proj - n))
        array.push(g_pls, polyline.new(c1, xloc=xloc.bar_time, closed=true, fill_color=color.new(cone_col, 76), line_color=color.new(cone_col, 38), line_width=3))

    // ── Draw center lines ──────────────────────────────────────────────────────
    if show_mean
        array.push(g_pls, polyline.new(pts_mean,   xloc=xloc.bar_time, line_color=color.new(mean_col,   10), line_width=2))
    if show_median
        array.push(g_pls, polyline.new(pts_median, xloc=xloc.bar_time, line_color=color.new(median_col, 15), line_width=2))

    // ── Monte Carlo paths ──────────────────────────────────────────────────────
    if show_mc
        for p = 0 to n_mc - 1
            mc_pts   = array.new<chart.point>(n_proj + 1)
            mc_price = s0
            array.set(mc_pts, 0, chart.point.from_time(time, mc_price))
            for n = 1 to n_proj
                mc_price := mc_price * math.exp(ito_mu + sig_bar * f_normal())
                array.set(mc_pts, n, chart.point.from_time(time + n * bar_dur, mc_price))
            array.push(g_pls, polyline.new(mc_pts, xloc=xloc.bar_time, line_color=color.new(cone_col, 80), line_width=1))

    // ── Endpoint labels ───────────────────────────────────────────────────────
    if show_labels
        ts_e    = time + n_proj * bar_dur
        sqnp    = math.sqrt(n_proj)
        e_ito_e = ito_mu * n_proj
        sprd_e  = sig_bar * sqnp

        if show_3sig
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e + 3.0 * sprd_e), "+3σ",  cone_col, 62))
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e - 3.0 * sprd_e), "-3σ",  cone_col, 62))
        if show_2sig
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e + 2.0 * sprd_e), "+2σ",  cone_col, 48))
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e - 2.0 * sprd_e), "-2σ",  cone_col, 48))
        if show_1sig
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e + 1.0 * sprd_e), "+1σ",  cone_col, 35))
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e - 1.0 * sprd_e), "-1σ",  cone_col, 35))
        if show_median
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(e_ito_e),                "med",  median_col, 30))
        if show_mean
            array.push(g_lbs, f_lbl(ts_e, s0 * math.exp(mu_bar * n_proj),        "mean", mean_col,   15))

    // ── Parameter table ───────────────────────────────────────────────────────
    if show_table
        if na(g_tbl)
            g_tbl := table.new(position.bottom_right, 2, 5, frame_color=color.new(color.gray, 55), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)
        hdr    = color.new(color.black, 78)
        lbl_bg = color.new(color.black, 85)
        val_bg = color.new(color.black, 72)

        table.cell(g_tbl, 0, 0, "GBM",    text_color=color.gray,  text_size=size.small, bgcolor=hdr)
        table.cell(g_tbl, 1, 0, str.tostring(lookback) + "b · " + str.tostring(n_proj) + "b fwd", text_color=color.gray, text_size=size.small, bgcolor=hdr)

        mu_str   = (mu_bar >= 0 ? "+" : "") + str.tostring(math.round(mu_bar  * 100, 4)) + "%"
        sig_str  = str.tostring(math.round(sig_bar * 100, 4)) + "%"
        corr_str = str.tostring(math.round(-var_bar / 2.0 * 100, 4)) + "%"
        ito_str  = (ito_mu >= 0 ? "+" : "") + str.tostring(math.round(ito_mu  * 100, 4)) + "%"

        table.cell(g_tbl, 0, 1, "Drift μ",       text_color=color.gray,  text_size=size.small, bgcolor=lbl_bg)
        table.cell(g_tbl, 1, 1, mu_str,           text_color=color.white, text_size=size.small, bgcolor=val_bg)
        table.cell(g_tbl, 0, 2, "Volatility σ",   text_color=color.gray,  text_size=size.small, bgcolor=lbl_bg)
        table.cell(g_tbl, 1, 2, sig_str,          text_color=color.white, text_size=size.small, bgcolor=val_bg)
        table.cell(g_tbl, 0, 3, "Itō correction", text_color=color.gray,  text_size=size.small, bgcolor=lbl_bg)
        table.cell(g_tbl, 1, 3, corr_str,         text_color=color.white, text_size=size.small, bgcolor=val_bg)
        table.cell(g_tbl, 0, 4, "Itō drift",      text_color=color.gray,  text_size=size.small, bgcolor=lbl_bg)
        ito_bg = ito_mu >= 0 ? color.new(#26a69a, 40) : color.new(#ef5350, 40)
        table.cell(g_tbl, 1, 4, ito_str,          text_color=color.white, text_size=size.small, bgcolor=ito_bg)

// ── Alerts ────────────────────────────────────────────────────────────────────
vol_spike = not na(sig_bar) and sig_bar > ta.sma(sig_bar, lookback) * 1.5
drift_neg = not na(mu_bar)  and mu_bar < 0 and mu_bar[1] >= 0
drift_pos = not na(mu_bar)  and mu_bar > 0 and mu_bar[1] <= 0
ito_neg   = not na(ito_mu)  and ito_mu < 0 and ito_mu[1] >= 0
ito_pos   = not na(ito_mu)  and ito_mu > 0 and ito_mu[1] <= 0

alertcondition(vol_spike and not vol_spike[1], "Volatility spike",            "{{ticker}} — GBM volatility spiked above 1.5x its rolling average on {{interval}}")
alertcondition(drift_neg,                      "Drift turned negative",        "{{ticker}} — estimated drift μ crossed below zero on {{interval}}")
alertcondition(drift_pos,                      "Drift turned positive",        "{{ticker}} — estimated drift μ crossed above zero on {{interval}}")
alertcondition(ito_neg,                        "Itō drift crossed below zero", "{{ticker}} — Itō drift (μ - σ²/2) crossed below zero: volatility drag now outpaces drift on {{interval}}")
alertcondition(ito_pos,                        "Itō drift crossed above zero", "{{ticker}} — Itō drift (μ - σ²/2) recovered above zero on {{interval}}")
````
