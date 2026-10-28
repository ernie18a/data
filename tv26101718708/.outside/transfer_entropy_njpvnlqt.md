# Transfer Entropy

- url: https://www.tradingview.com/script/njpVNLQT-Transfer-Entropy/
- type: indicator
- pine_id: PUB;738d49584f7047438bc6ec59f5db1cec
- version: 1.0

## Description

[b]Transfer Entropy[/b]

A directional information flow detector for two assets, based on Thomas Schreiber's 2000 formulation. Transfer Entropy measures how much knowing the recent past of one series reduces uncertainty about the next move of another — beyond what the second series' own past already explains. Unlike correlation, it's asymmetric: TE(Y → X) and TE(X → Y) are different quantities, so it can speak to lead-lag in a way correlation can't.

[b]How it works[/b]

Log returns from both series are symbolized into binary up/down moves. Over a rolling window of N bars, the script estimates the joint distribution of past pairs and future moves, then computes the conditional mutual information that defines TE in bits.
To separate genuine information flow from finite-sample noise, the same calculation is repeated with the reference series circularly shifted by various offsets within the window — surrogates that preserve each series' marginal distribution but break the temporal coupling between them. The mean of those surrogate estimates is the noise floor, which gets subtracted from the raw value to produce Effective Transfer Entropy (Marschinski & Kantz, 2002).
Both directions — Y→X and X→Y — are computed every bar. The main plot is net flow: inflow minus outflow.

[b]How to read it[/b]

The colored area is net information flow.
[list]
[*]Above zero in cyan: the reference symbol's recent moves carry useful information about the chart symbol's next move.
[*]Below zero in amber: the chart symbol is leading the reference.
[/list]
The thinner lines on either side are the individual directional components — inflow plotted positive, outflow plotted as its negative for visual symmetry around zero.
The dotted band is the average noise floor. Flow inside the band is statistically indistinguishable from chance; flow outside it isn't. A faint background tint marks bars where net flow has cleared the band.

[b]Inputs[/b]

[list]
[*]Reference symbol — the second asset (Y). Information flow is measured between this and the chart symbol (X). Default AMEX:SPY.
[*]Window length — number of triplets feeding the joint-distribution estimate. The 8-cell histogram needs many times that to stabilize; 150–300 is reasonable for most markets. Default 200.
[*]Source — input series for the chart symbol's log returns. Default close.
[*]Significance surrogates — number of circular-shift surrogates averaged into the noise floor. More = more stable significance test at modestly higher compute. Default 3.
[*]Visuals — toggles for net flow, directional flows, noise floor band, glow, and regime tint, plus customizable colors for inflow, outflow, and neutral states.
[/list]
[b]Built-in alerts[/b]
[list]
[*]Lead flip — Reference leading — net flow crosses above zero
[*]Lead flip — Chart leading — net flow crosses below zero
[*]Significant inflow — net flow rises above the noise floor
[*]Significant outflow — net flow drops below the negative noise floor
[/list]
[b]Notes[/b]

Pick reference symbols with overlapping trading hours. When one series is closed and the other isn't, the closed series' price forward-fills, which shows up as a run of zero returns and biases the estimate.
The binary symbolization (up vs not-up) is intentionally crude. It's robust, requires no parameter tuning, and matches Schreiber's original formulation — but it discards magnitude. For pairs where the size of a move matters more than its direction, this measure won't capture it.
This is a diagnostic tool, not a signal generator. It tells you which side of a pair is leading.

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
//                          Transfer Entropy
//                          ─────────────────
//   Schreiber's information-theoretic measure of directional information
//   flow between two assets. Quantifies how much knowing the recent past of
//   the reference symbol reduces uncertainty about the next move of the
//   chart symbol — beyond what the chart symbol's own past already explains.
//
//   Asymmetric: TE(Y→X) ≠ TE(X→Y), so it can speak to lead-lag in a way
//   correlation can't. Significance is established with circular-shift
//   surrogates (Marschinski & Kantz 2002 Effective Transfer Entropy).
//
//   Reference: Schreiber, T. (2000). "Measuring Information Transfer."
//              Physical Review Letters 85(2): 461–464.
//
//   Author : TradeSymbiotic
//   License: MPL-2.0
//   Version: 1.0
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Transfer Entropy", shorttitle="TE", overlay=false, format=format.price, precision=4, max_bars_back=1100)

// ── Inputs ───────────────────────────────────────────────────────────────────
ref_sym         = input.symbol("AMEX:SPY", "Reference symbol", group="Calculation",
    tooltip="The second asset (Y). Information flow is measured between this and the chart symbol (X). Pick assets that trade during overlapping hours — when one is closed, its price forward-fills, which biases the estimate.")

window_len      = input.int(200, "Window length (bars)", minval=50, maxval=1000, group="Calculation",
    tooltip="Number of triplets used to estimate joint probabilities. Binary symbolization fills an 8-cell histogram, so the window should be many times that. 150–300 is a reasonable range for most markets.")

src_x           = input.source(close, "Source", group="Calculation")

n_surrogates    = input.int(3, "Significance surrogates", minval=1, maxval=5, group="Calculation",
    tooltip="Number of circular-shift surrogates averaged into the noise floor. Surrogates break the time alignment of the pair, so any TE they show is finite-sample bias. More surrogates = more stable significance test.")

show_net        = input.bool(true,  "Show net information flow",          group="Visuals")
show_directional= input.bool(true,  "Show directional flows",             group="Visuals")
show_sig_band   = input.bool(true,  "Show noise floor band",              group="Visuals")
show_glow       = input.bool(true,  "Glow effect on net flow",            group="Visuals")
show_regime     = input.bool(true,  "Background tint on significant flow", group="Visuals")

inflow_color    = input.color(#00bcd4, "Inflow (Y → X)",  group="Visuals",
    tooltip="Color when the reference asset is leading the chart asset.")
outflow_color   = input.color(#ff9800, "Outflow (X → Y)", group="Visuals",
    tooltip="Color when the chart asset is leading the reference asset.")
neutral_color   = input.color(#787b86, "Neutral",         group="Visuals")

src_y = request.security(ref_sym, timeframe.period, src_x, lookahead=barmerge.lookahead_off)

ret_x = nz(math.log(src_x / src_x[1]))
ret_y = nz(math.log(src_y / src_y[1]))

// Schreiber binary symbolization: up = 1, otherwise = 0
sym_x = ret_x > 0 ? 1 : 0
sym_y = ret_y > 0 ? 1 : 0

// ── Transfer Entropy core ────────────────────────────────────────────────────

calc_te(series int target, series int source, simple int N, simple int shift) =>
    triplet_count   = array.new<int>(8, 0)
    target_pair     = array.new<int>(4, 0)
    cross_pair      = array.new<int>(4, 0)
    target_marginal = array.new<int>(2, 0)

    for i = 0 to N - 1
        xn1  = nz(target[i],     0)
        xn   = nz(target[i + 1], 0)
        sidx = shift == 0 ? (i + 1) : (((i + shift) % N) + 1)
        yn   = nz(source[sidx],  0)

        idx3 = xn1 * 4 + xn * 2 + yn
        triplet_count.set  (idx3,         triplet_count.get  (idx3)         + 1)
        target_pair.set    (xn1 * 2 + xn, target_pair.get    (xn1 * 2 + xn) + 1)
        cross_pair.set     (xn  * 2 + yn, cross_pair.get     (xn  * 2 + yn) + 1)
        target_marginal.set(xn,           target_marginal.get(xn)           + 1)

    // TE = Σ p(x',x,y) · log2[ p(x',x,y) · p(x) / ( p(x',x) · p(x,y) ) ]
    float te_bits = 0.0
    for ijk = 0 to 7
        n_xyz = triplet_count.get(ijk)
        if n_xyz > 0
            int i_val = ijk >= 4 ? 1 : 0 
            int j_val = (ijk % 4) >= 2 ? 1 : 0
            int k_val = ijk % 2

            n_xx = target_pair.get    (i_val * 2 + j_val)
            n_xy = cross_pair.get     (j_val * 2 + k_val)
            n_x  = target_marginal.get(j_val)

            if n_xx > 0 and n_xy > 0 and n_x > 0
                ratio   = (1.0 * n_xyz * n_x) / (1.0 * n_xx * n_xy)
                te_bits := te_bits + (1.0 * n_xyz / N) * math.log(ratio) / math.log(2)
    te_bits

noise_floor(series int target, series int source, simple int N, simple int n_surr) =>
    float total = 0.0
    int   count = 0
    if n_surr >= 1
        total := total + calc_te(target, source, N, N / 2)
        count := count + 1
    if n_surr >= 2
        total := total + calc_te(target, source, N, N / 3)
        count := count + 1
    if n_surr >= 3
        total := total + calc_te(target, source, N, 2 * N / 5)
        count := count + 1
    if n_surr >= 4
        total := total + calc_te(target, source, N, N / 4)
        count := count + 1
    if n_surr >= 5
        total := total + calc_te(target, source, N, 3 * N / 7)
        count := count + 1
    count > 0 ? total / count : 0.0

// ── Compute TE in both directions ────────────────────────────────────────────
te_yx_raw = calc_te    (sym_x, sym_y, window_len, 0)
te_xy_raw = calc_te    (sym_y, sym_x, window_len, 0)
floor_yx  = noise_floor(sym_x, sym_y, window_len, n_surrogates)
floor_xy  = noise_floor(sym_y, sym_x, window_len, n_surrogates)

ready  = bar_index > window_len + 1

// Effective TE: clamp at zero so values below the noise floor don't show as flow
ete_yx = ready ? math.max(0.0, te_yx_raw - floor_yx) : na
ete_xy = ready ? math.max(0.0, te_xy_raw - floor_xy) : na

// Net flow: positive = reference leads chart, negative = chart leads reference
net_te      = nz(ete_yx, 0) - nz(ete_xy, 0)
net_te_plot = ready ? net_te : na

// Visual significance band (mean noise floor across both directions)
sig_thresh = ready ? (floor_yx + floor_xy) / 2 : na

// ── Plotting ─────────────────────────────────────────────────────────────────
net_color = net_te > 0 ? inflow_color : outflow_color

abs_net    = math.abs(nz(net_te_plot, 0))
recent_max = math.max(ta.highest(abs_net, 200), 0.0001)
fill_alpha = int(85 - 50 * math.min(1.0, abs_net / recent_max))

p_zero   = plot(0,           color=na, display=display.none, editable=false)
p_anchor = plot(net_te_plot, color=na, display=display.none, editable=false)
fill(p_anchor, p_zero, color=color.new(net_color, fill_alpha), title="Net flow area")

glow_outer_alpha = show_glow and show_net ? 88 : 100
glow_inner_alpha = show_glow and show_net ? 75 : 100
plot(net_te_plot, "Glow outer", color=color.new(net_color, glow_outer_alpha), linewidth=8)
plot(net_te_plot, "Glow inner", color=color.new(net_color, glow_inner_alpha), linewidth=4)

plot(show_net ? net_te_plot : na, "Net flow", color=color.new(net_color, 0), linewidth=2)

dir_alpha = show_directional ? 55 : 100
plot( ete_yx, "ETE (Y → X)", color=color.new(inflow_color,  dir_alpha), linewidth=1)
plot(-ete_xy, "ETE (X → Y)", color=color.new(outflow_color, dir_alpha), linewidth=1)

band_alpha = show_sig_band ? 60 : 100
plot( sig_thresh, "Noise floor +", color=color.new(neutral_color, band_alpha), linewidth=1, style=plot.style_circles)
plot(-sig_thresh, "Noise floor −", color=color.new(neutral_color, band_alpha), linewidth=1, style=plot.style_circles)

hline(0, "Zero", color=color.new(neutral_color, 40), linestyle=hline.style_dotted)

sig_inflow  = ready and net_te >  sig_thresh
sig_outflow = ready and net_te < -sig_thresh
bgcolor(show_regime and sig_inflow  ? color.new(inflow_color,  93) : na, title="Reference-leads regime")
bgcolor(show_regime and sig_outflow ? color.new(outflow_color, 93) : na, title="Chart-leads regime")

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(ta.crossover (net_te_plot, 0), "Lead flip — Reference leading", "{{ticker}}: net information flow turned positive — the reference symbol is now leading.")
alertcondition(ta.crossunder(net_te_plot, 0), "Lead flip — Chart leading", "{{ticker}}: net information flow turned negative — the chart symbol is now leading.")
alertcondition(ta.crossover (net_te_plot,  sig_thresh), "Significant inflow", "{{ticker}}: incoming information flow exceeded the surrogate noise floor.")
alertcondition(ta.crossunder(net_te_plot, -sig_thresh), "Significant outflow", "{{ticker}}: outgoing information flow exceeded the surrogate noise floor.")
````
