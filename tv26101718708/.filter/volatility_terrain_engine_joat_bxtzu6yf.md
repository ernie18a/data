# Volatility Terrain Engine [JOAT]

- url: https://www.tradingview.com/script/BXtZu6Yf-Volatility-Terrain-Engine-JOAT/
- type: indicator
- pine_id: PUB;54de02578b094bbaaa300f06de2baee2
- version: 1.0

## Description

[b]Volatility Terrain Engine [JOAT][/b]

[b]Introduction[/b]

Volatility Terrain Engine is a pane-based oscillator that measures the current volatility regime using the ratio between a fast ATR and a slow ATR, combined with a percentile rank of current volatility within a historical window. The indicator classifies every bar into one of three states — Expansion, Compression, or Transition — and identifies squeeze conditions (volatility compressing well below its average) and expansion bursts (volatility accelerating rapidly). The oscillator, centered at zero, makes it immediately clear whether volatility is expanding or contracting relative to its baseline.

Volatility regime is one of the most underappreciated dimensions of market analysis. A trend-following strategy applied during volatility compression produces poor results because the market is not moving directionally with sufficient energy. A mean-reversion strategy applied during volatility expansion gets stopped out repeatedly because the market is generating outsized moves. Identifying the current volatility terrain before applying any strategy is a prerequisite for selecting the appropriate approach.

[image]https://www.tradingview.com/x/C00TJ9gB/[/image]

[b]Core Concepts[/b]

[b]1. Fast/Slow ATR Ratio[/b]

The primary oscillator compares a short-period ATR (default 14) against a long-period ATR (default 100). Their ratio, centered at 1.0, is shifted to center at 0.0 by subtracting 1. Values above 0 mean recent volatility is expanding relative to the longer-term baseline; values below 0 mean it is contracting. This ratio is more informative than ATR alone because it provides context — the same ATR value means different things in a historically volatile versus historically calm market.

[b]2. Percentile Rank[/b]

The ATR percentile rank answers: where does today's volatility sit within its historical distribution? A 90th percentile reading means volatility is higher than 90% of observations in the lookback period. This is used to classify whether the current environment is historically extreme or within normal parameters.

[b]3. Squeeze and Expansion Burst Detection[/b]

A squeeze is defined as fast ATR falling below 82% of slow ATR and also below its own 20-bar average. This double condition filters single-bar dips. A squeeze represents stored energy — the market is coiling. An expansion burst is defined as the ATR ratio exceeding 1.25 with the fast ATR making successive higher values. This marks the initial stages of a volatility explosion.

[b]4. Signal Line and Histogram[/b]

The oscillator is triple-processed: EMA of ratio → SMA signal → histogram. The histogram shows the divergence between the oscillator and its signal, providing a leading read on whether volatility momentum is building or fading.

[b]Features[/b]

[list]
[*][b]Volatility Regime Oscillator:[/b] Gradient-colored histogram bars centered at zero
[*][b]Squeeze Detection:[/b] Dashboard alert and dot marker when squeeze conditions are active
[*][b]Expansion Burst Markers:[/b] Dot markers when volatility breaks out from compression
[*][b]ATR Percentile Band:[/b] Normalized ATR rank plotted as a secondary line
[*][b]Zone Fills:[/b] Expansion and compression zones filled with transparent color
[*][b]8-Row Dashboard:[/b] Regime, ATR values, ratio, percentile rank, squeeze status, oscillator values
[/list]

[b]Input Parameters[/b]

[list]
[*]Fast ATR Period: Short-term volatility measurement (default: 14)
[*]Slow ATR Period: Long-term volatility baseline (default: 100)
[*]Percentile Lookback: Historical window for rank calculation (default: 252)
[*]Signal Smoothing: Signal line period (default: 9)
[*]Expansion, Compression, and Transition color inputs
[/list]

[b]How to Use This Indicator[/b]

[b]Compression → Expansion Transition[/b]
The most significant signal is when a squeeze resolves into an expansion burst. This represents a volatility state change — the market has been coiling and is now releasing energy. The direction of that release is not predicted by this indicator; it must be determined using price structure and other context.

[b]Oscillator Zero Cross[/b]
The oscillator crossing from negative to positive territory indicates that short-term volatility has exceeded the long-term baseline. This is not a trade signal — it is a condition indicator confirming that the market is entering a higher-energy phase.

[b]High Percentile + Expansion[/b]
When the oscillator is in expansion territory and the ATR percentile rank is above 80, the market is experiencing historically significant volatility. Stops must be sized accordingly.

[b]Limitations[/b]

[list]
[*]ATR is backward-looking. Sudden volatility spikes from news events will appear in the oscillator only after those bars close
[*]The squeeze condition uses fixed multipliers (0.82 for the ATR ratio threshold). Markets with different typical volatility profiles may require adjustments to these thresholds
[*]The percentile lookback of 252 bars requires approximately one year of daily data or equivalent for the rank to be historically meaningful. On shorter data sets the rank will be computed on whatever bars are available but will be less statistically robust
[*]This indicator classifies current conditions only. It does not predict when a squeeze will resolve or in which direction
[/list]

[b]Originality Statement[/b]

The dual-ATR ratio approach combined with percentile ranking provides more contextual information than either measure alone. The squeeze detection using a double condition (ratio below threshold and below its own moving average) produces more reliable squeeze identification than a single-condition approach. The four-state histogram coloring (expanding positive, fading positive, expanding negative, fading negative) provides more nuanced momentum information than standard positive/negative coloring.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Volatility regime classification does not predict price direction. A squeeze does not guarantee a subsequent expansion, and the direction of any expansion is unknowable from volatility data alone. Always use appropriate risk management.

-Made with passion by officialjackofalltrades

## Source Code

````pine
//@version=6
indicator("Volatility Terrain Engine [JOAT]", shorttitle="VTE [JOAT]", overlay=false, precision=4)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_a  = "ATR Settings"
i_fast = input.int(14,  "Fast ATR Period",     minval=5,  maxval=50,  group=grp_a)
i_slow = input.int(100, "Slow ATR Period",     minval=30, maxval=300, group=grp_a)
i_rank = input.int(252, "Percentile Lookback", minval=50, maxval=500, group=grp_a)
i_sig  = input.int(9,   "Signal Smoothing",    minval=2,  maxval=30,  group=grp_a)

grp_v  = "Visual Settings"
i_dash = input.bool(true, "Show Dashboard", group=grp_v)
i_dpos = input.string("Top Right", "Position",
         options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp_v)
i_exp  = input.color(#ef5350, "Expansion Color",   group=grp_v)
i_com  = input.color(#00bfa5, "Compression Color", group=grp_v)
i_tra  = input.color(#ffd54f, "Transition Color",  group=grp_v)

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
atr_fast  = ta.atr(i_fast)
atr_slow  = ta.atr(i_slow)
atr_ratio = atr_fast / math.max(atr_slow, syminfo.mintick)

// ATR percentile rank — how extreme is current volatility historically
atr_pctl  = ta.percentile_linear_interpolation(atr_fast, i_rank, 100)
atr_rank  = math.min(atr_fast / math.max(atr_pctl, syminfo.mintick), 2.0)

// Centered oscillator (0 = neutral; positive = expansion; negative = compression)
osc_raw   = ta.ema(atr_ratio - 1.0, 3)
osc_sig   = ta.sma(osc_raw, i_sig)
osc_hist  = osc_raw - osc_sig

// Volatility momentum
vol_mom   = atr_ratio - atr_ratio[5]

// Normalized volume impulse
vol_pctl  = ta.percentile_linear_interpolation(volume, 500, 100)
vol_norm  = math.min(volume / math.max(vol_pctl, 1.0), 3.0)

// Squeeze detection: ATR compressing below slow ATR and below its own 20-bar average
atr_ma20   = ta.sma(atr_fast, 20)
squeeze    = atr_fast < atr_slow * 0.82 and atr_fast < atr_ma20

// Expansion burst: ATR expanding rapidly above both references
expansion  = atr_ratio > 1.20 and atr_fast > atr_fast[1] and atr_fast > atr_fast[2]

// Regime classification — confirmed bars only
var int vol_regime = 0
if barstate.isconfirmed
    vol_regime := atr_ratio > 1.12 and osc_raw > osc_sig ? 1 :
                  atr_ratio < 0.88 and osc_raw < osc_sig ? -1 :
                  0

reg_col = vol_regime == 1 ? i_exp : vol_regime == -1 ? i_com : i_tra

// ATR standard deviation channel (for oscillator context bands)
atr_stdev    = ta.stdev(atr_fast, 50)
upper_thresh =  atr_stdev / math.max(atr_slow, syminfo.mintick) * 0.5
lower_thresh = -upper_thresh

// ─────────────────────────────────────────────────────────────────────────────
// HISTOGRAM COLORING
// ─────────────────────────────────────────────────────────────────────────────
hist_col = osc_hist > 0 and osc_raw > 0   ? i_exp
         : osc_hist > 0 and osc_raw <= 0  ? color.new(i_exp,  55)
         : osc_hist <= 0 and osc_raw < 0  ? i_com
         :                                  color.new(i_com,  55)

// Oscillator gradient line
osc_grad = osc_raw > 0
         ? color.from_gradient(math.min(osc_raw * 8, 1.0),  0, 1, color.new(i_exp, 60), i_exp)
         : color.from_gradient(math.max(osc_raw * 8, -1.0), -1, 0, i_com, color.new(i_com, 60))

// ─────────────────────────────────────────────────────────────────────────────
// REFERENCE LINES
// ─────────────────────────────────────────────────────────────────────────────
h_exp  = hline( 0.15, "Expansion Threshold",   color=color.new(i_exp, 55), linestyle=hline.style_dashed)
h_com  = hline(-0.15, "Compression Threshold", color=color.new(i_com, 55), linestyle=hline.style_dashed)
h_zero = hline( 0.0,  "Equilibrium",           color=color.new(color.gray, 50), linestyle=hline.style_solid)

fill(h_exp,  h_zero, color=color.new(i_exp, 93))
fill(h_com,  h_zero, color=color.new(i_com, 93))

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
// Main oscillator histogram
plot(osc_raw, "Volatility Oscillator", color=osc_grad,
     style=plot.style_columns, linewidth=2)

// Signal line
plot(osc_sig, "Signal Line", color=color.new(color.white, 45), linewidth=2)

// Histogram (oscillator minus signal)
plot(osc_hist, "Momentum Histogram", color=hist_col,
     style=plot.style_histogram, linewidth=1)

// ATR rank normalized to oscillator scale (0→1 mapped to -0.3→+0.3)
plot(atr_rank * 0.3 - 0.15, "ATR Rank Band", color=color.new(color.white, 72),
     linewidth=1, style=plot.style_line)

// Squeeze and expansion event dots
plotshape(squeeze and not squeeze[1]   ? 0.0 : na, style=shape.circle,
         location=location.absolute, color=color.new(i_com, 10),
         size=size.small, title="Squeeze Event")
plotshape(expansion and not expansion[1] ? 0.0 : na, style=shape.circle,
         location=location.absolute, color=color.new(i_exp, 10),
         size=size.small, title="Expansion Burst")

// Bar coloring in owning pane
barcolor(reg_col, editable=false)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────
var table _t = na
if i_dash and barstate.islast
    dpos = switch i_dpos
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        =>               position.top_right
    if na(_t)
        _t := table.new(dpos, 3, 9,
                        border_width=1, border_color=color.new(color.gray, 75),
                        frame_width=2,  frame_color=color.new(color.gray, 55))

    C0 = color.new(#0a1628, 0)
    C1 = color.new(#0f2341, 0)
    C2 = color.new(#152d52, 0)

    table.cell(_t, 0, 0, "VOLATILITY TERRAIN ENGINE", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    reg_str = vol_regime == 1 ? "EXPANSION" : vol_regime == -1 ? "COMPRESSION" : "TRANSITION"
    table.cell(_t, 0, 1, "Regime", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 1, reg_str, bgcolor=C1, text_color=reg_col, text_size=size.small)
    table.cell(_t, 2, 1, vol_regime == 1 ? "+" : vol_regime == -1 ? "-" : "~",
               bgcolor=color.new(reg_col, 40), text_color=color.white, text_size=size.small)

    table.cell(_t, 0, 2, "ATR Fast", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, str.tostring(atr_fast, format.mintick),
               bgcolor=C2, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 2, str.tostring(atr_fast / close * 100, "#.##") + "%",
               bgcolor=C2, text_color=color.gray, text_size=size.small)

    table.cell(_t, 0, 3, "Ratio F/S", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 3, str.tostring(atr_ratio, "#.###"),
               bgcolor=C1, text_color=atr_ratio > 1 ? i_exp : i_com, text_size=size.small)
    table.cell(_t, 2, 3, atr_ratio > 1.0 ? "Expanding" : "Contracting",
               bgcolor=C1, text_color=atr_ratio > 1 ? i_exp : i_com, text_size=size.small)

    rank_pct = math.round(atr_rank * 100)
    table.cell(_t, 0, 4, "ATR %ile", bgcolor=C2, text_color=color.gray, text_size=size.small)
    rank_col = rank_pct > 80 ? i_exp : rank_pct < 20 ? i_com : i_tra
    table.cell(_t, 1, 4, str.tostring(rank_pct) + "th",
               bgcolor=C2, text_color=rank_col, text_size=size.small)
    table.merge_cells(_t, 1, 4, 2, 4)

    table.cell(_t, 0, 5, "Squeeze", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 5, squeeze ? "ACTIVE" : "Inactive",
               bgcolor=squeeze ? color.new(i_com, 25) : C1,
               text_color=squeeze ? i_com : color.gray, text_size=size.small)
    table.merge_cells(_t, 1, 5, 2, 5)

    table.cell(_t, 0, 6, "Expansion", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 6, expansion ? "BURST" : "Normal",
               bgcolor=expansion ? color.new(i_exp, 25) : C2,
               text_color=expansion ? i_exp : color.gray, text_size=size.small)
    table.merge_cells(_t, 1, 6, 2, 6)

    table.cell(_t, 0, 7, "Osc / Sig", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 7, str.tostring(osc_raw, "#.####"),
               bgcolor=C1, text_color=osc_raw > osc_sig ? i_exp : i_com, text_size=size.small)
    table.cell(_t, 2, 7, str.tostring(osc_sig, "#.####"),
               bgcolor=C1, text_color=color.gray, text_size=size.small)

    table.cell(_t, 0, 8, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 8, 2, 8)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(vol_regime == 1 and vol_regime[1] != 1,
               "VTE — Expansion Begins", "Volatility Expansion detected — {{ticker}} {{interval}}")
alertcondition(vol_regime == -1 and vol_regime[1] != -1,
               "VTE — Compression Begins", "Volatility Compression detected — {{ticker}} {{interval}}")
alertcondition(squeeze and not squeeze[1],
               "VTE — Squeeze Forming", "Volatility Squeeze forming — {{ticker}}")
alertcondition(expansion and not expansion[1],
               "VTE — Breakout Expansion", "Volatility Breakout Expansion — {{ticker}}")
alertcondition(osc_raw > 0 and osc_raw[1] <= 0,
               "VTE — Osc Crosses Up", "Volatility oscillator crossed above zero — {{ticker}}")
alertcondition(osc_raw < 0 and osc_raw[1] >= 0,
               "VTE — Osc Crosses Down", "Volatility oscillator crossed below zero — {{ticker}}")
````
