# Delta Pressure Gauge [JOAT]

- url: https://www.tradingview.com/script/Ozmyallz-Delta-Pressure-Gauge-JOAT/
- type: indicator
- pine_id: PUB;0dbdcc042fdc465f9a8e4013fbe2e377
- version: 1.0

## Description

[b]Delta Pressure Gauge [JOAT][/b]

[b]Introduction[/b]

Delta Pressure Gauge is a pane-based oscillator that constructs a volume-weighted directional wave from bar-by-bar delta estimation, normalized using a rolling maximum to ensure consistent scaling across all instruments and timeframes. The oscillator measures the pressure imbalance between buying volume and selling volume, smoothed into a wave that reveals accumulation and distribution phases with high visual clarity. The indicator includes a money flow pressure line, a cumulative windowed delta cloud, divergence detection, and crossover signal dots.

Traditional volume indicators — OBV, CMF, MFI — measure volume flows using raw or price-weighted calculations that are difficult to compare across instruments or timeframes because their absolute values depend on the asset's volume profile. Delta Pressure Gauge normalizes everything to a -1 to +1 scale using a rolling maximum, producing readings that are immediately interpretable regardless of whether the asset trades 100 shares or 100 million. The wave design provides a visual rhythm that makes accumulation and distribution phases recognizable at a glance.

[image]https://www.tradingview.com/x/lsaAJJEz/[/image]

[b]Core Concepts[/b]

[b]1. Body-Quality Weighted Bar Delta[/b]

Each bar contributes a delta value based on direction (bullish = +volume, bearish = -volume) multiplied by the bar's body quality ratio (body size divided by total range). A full-body bar contributes 100% of its volume to delta. A doji bar with no body contributes 0%. This filtering reduces the noise contribution of indecision bars that add volume without directional information.

[pine]
body_qual = math.abs(close - open) / math.max(high - low, syminfo.mintick)
bar_delta = bar_dir * volume * body_qual
[/pine]

[b]2. Rolling Maximum Normalization[/b]

The raw wave EMA is normalized by dividing by the rolling maximum absolute value over the normalization window. Unlike percentile-based normalization, rolling maximum works reliably from the first bar, requires no minimum warmup period, and produces values that are always within the -1 to +1 range:

[pine]
norm_ref = ta.highest(math.abs(raw_wave), i_norm)
wt1 = raw_wave / math.max(nz(norm_ref, 1.0), 1.0)
[/pine]

[b]3. Windowed Cumulative Delta[/b]

Rather than using an all-time cumulative delta (which grows without bound and becomes dominated by early bars), the cumulative component uses a 30-bar rolling sum. This produces a medium-term delta bias that reflects the recent directional commitment of volume participants.

[b]4. Money Flow Pressure Line[/b]

A separate money flow calculation weights volume by the ratio of price movement to range: (close - open) / range × volume. This captures the efficiency of price movement relative to its volume cost — high-momentum bars have larger weights than range-bound bars.

[b]5. Divergence Detection[/b]

Bullish divergence is detected when the delta wave makes a higher low while price makes a lower low. Bearish divergence is the mirror. Detection uses confirmed pivot points on the wave with persistent previous-pivot storage, avoiding any ta.valuewhen type compatibility issues. Divergence lines are rendered directly on the oscillator pane.

[b]Features[/b]

[list]
[*][b]Wave Oscillator:[/b] Gradient area fill between wave and zero, color-coded by direction and intensity
[*][b]Signal Line:[/b] Smoothed signal with direction-colored rendering
[*][b]Histogram:[/b] Four-state colored momentum bars showing wave-signal separation and its rate of change
[*][b]Crossover Dots:[/b] Large circles with glow rings at every wave/signal crossover
[*][b]Zero-Line Cross Dots:[/b] Small markers when wave crosses the zero line
[*][b]Overbought/Oversold Extreme Dots:[/b] Markers at extreme readings
[*][b]Divergence Triangles and Lines:[/b] Yellow markers and connecting lines when divergence is detected
[*][b]Cumulative Delta Cloud:[/b] Area fill showing 30-bar rolling delta direction
[*][b]Money Flow Line:[/b] Purple secondary line for cross-confirmation
[*][b]Volume Surge Markers:[/b] Cross markers when volume exceeds 2x average
[*][b]12-Row Dashboard:[/b] Pressure state, wave values, histogram, signals, cumulative delta, money flow, volume ratio, divergence state
[/list]

[b]Input Parameters[/b]

[list]
[*]Wave Channel Length: Fast EMA for wave construction (default: 10)
[*]Wave Average Length: Signal line smoothing period (default: 21)
[*]Rolling Norm Window: Window for rolling maximum normalization (default: 100)
[*]Overbought/Oversold levels: Four configurable threshold lines
[*]Divergence pivot lookback settings
[/list]

[image]https://www.tradingview.com/x/V5KwkcOC/[/image]

[b]How to Use This Indicator[/b]

[b]Crossover Dots as Momentum Shifts[/b]
When the wave crosses above the signal line (green dot), buying pressure is accelerating relative to the smoothed baseline. This confirms a momentum pickup. The opposite for bearish crosses. These signals are strongest when they occur near or below the oversold line.

[b]Zero-Line Confirmation[/b]
The wave crossing zero from below indicates that aggregate buying pressure over the wave window has turned net positive. This is a regime confirmation, not an entry signal in isolation, but it supports bullish bias when aligned with price structure.

[b]Divergence at Extremes[/b]
Divergence is most meaningful when the wave is at or near an overbought or oversold extreme. A bullish divergence from the oversold zone (yellow triangle pointing up) suggests the distribution of buying pressure is shifting despite continued price weakness.

[b]Cumulative Delta Direction[/b]
The blue-purple cloud shows whether the 30-bar rolling delta is net positive or negative. When the wave crosses bullishly and the cumulative delta is also positive, both the momentum and the persistent pressure agree.

[b]Limitations[/b]

[list]
[*]This indicator uses close-open direction to estimate bar delta. True bid-ask volume data (available only through specialized data providers) would be more precise. On instruments with significant wick activity (doji bars), this estimation introduces noise
[*]Normalization by rolling maximum means a single extreme bar sets the scale for the entire norm window. One unusually large volume bar will compress all surrounding readings
[*]Divergence detection requires enough bars for pivot confirmation. The pivot right-side lookback introduces a lag in divergence signals
[*]This indicator measures volume pressure proxies, not actual institutional activity. Large volume does not always reflect institutional intent
[/list]

[b]Originality Statement[/b]

The body-quality weighting applied before delta smoothing is a deliberate design choice that reduces doji noise in a way that raw-volume or typical-price approaches do not. The rolling maximum normalization (rather than percentile or z-score) was chosen specifically because it operates reliably from the first bar without a warmup cliff, making the indicator immediately usable on limited datasets. The combination of a wave oscillator, cumulative delta cloud, and money flow line on a single pane provides three independent perspectives on the same underlying volume pressure question.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. Volume pressure readings are estimates derived from OHLCV data. They do not represent actual order flow or institutional positioning. Past divergence patterns do not predict future price reactions. Always apply appropriate risk management.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Delta Pressure Gauge [JOAT]", shorttitle="DPG [JOAT]", overlay=false, precision=4,
         max_lines_count=200)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_w  = "Wave Settings"
i_n1   = input.int(10,  "Wave Channel Length",  minval=2,  maxval=50,  group=grp_w)
i_n2   = input.int(21,  "Wave Average Length",  minval=5,  maxval=100, group=grp_w)
i_norm = input.int(100, "Rolling Norm Window",  minval=20, maxval=300, group=grp_w)
i_ob1  = input.float( 0.55, "Overbought 1",     minval=0.1, maxval=1.5, step=0.05, group=grp_w)
i_ob2  = input.float( 0.80, "Overbought 2",     minval=0.2, maxval=2.0, step=0.05, group=grp_w)
i_os1  = input.float(-0.55, "Oversold 1",       minval=-1.5, maxval=-0.1, step=0.05, group=grp_w)
i_os2  = input.float(-0.80, "Oversold 2",       minval=-2.0, maxval=-0.2, step=0.05, group=grp_w)

grp_d  = "Divergence"
i_div  = input.bool(true, "Show Divergence Signals", group=grp_d)
i_pl   = input.int(5, "Pivot Left Bars",  minval=2, maxval=15, group=grp_d)
i_pr   = input.int(5, "Pivot Right Bars", minval=2, maxval=15, group=grp_d)

grp_v  = "Visual Settings"
i_dash = input.bool(true, "Show Dashboard", group=grp_v)
i_dpos = input.string("Top Right", "Dashboard Position",
         options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp_v)
i_mf   = input.bool(true, "Show Money Flow Line",   group=grp_v)
i_cum  = input.bool(true, "Show Cumulative Delta",  group=grp_v)
i_bull = input.color(#00bfa5, "Accumulation Color", group=grp_v)
i_bear = input.color(#ef5350, "Distribution Color", group=grp_v)
i_div_col = input.color(#ffd54f, "Divergence Color", group=grp_v)

// ─────────────────────────────────────────────────────────────────────────────
// CORE DELTA ENGINE
// Weighted bar delta: direction * volume * body-quality filter
// ─────────────────────────────────────────────────────────────────────────────
bar_rng   = math.max(high - low, syminfo.mintick)
body      = math.abs(close - open)
body_qual = body / bar_rng                                    // 0=doji, 1=full body
bar_dir   = close > open ? 1.0 : close < open ? -1.0 : 0.0
bar_delta = bar_dir * volume * body_qual                      // body-quality weighted delta

// ─────────────────────────────────────────────────────────────────────────────
// WAVE OSCILLATOR (Cipher-B inspired, delta-powered)
// Uses rolling max normalization — works from bar 1, no warmup cliff
// ─────────────────────────────────────────────────────────────────────────────
raw_wave  = ta.ema(bar_delta, i_n1)
norm_ref  = ta.highest(math.abs(raw_wave), i_norm)            // rolling max (never na on bar 1+)
wt1       = raw_wave / math.max(nz(norm_ref, 1.0), 1.0)      // Wave 1: fast — range [-1, +1]
wt2       = ta.sma(wt1, i_n2)                                 // Wave 2: smooth signal
wt_hist   = wt1 - wt2                                         // Histogram: momentum impulse

// ─────────────────────────────────────────────────────────────────────────────
// CUMULATIVE WINDOWED DELTA (30-bar rolling sum, normalized)
// Window-based avoids the runaway scale problem of all-time cumulative
// ─────────────────────────────────────────────────────────────────────────────
cum_w     = math.sum(bar_delta, 30)
cum_max   = ta.highest(math.abs(cum_w), i_norm)
cum_osc   = cum_w / math.max(nz(cum_max, 1.0), 1.0)          // range [-1, +1]

// ─────────────────────────────────────────────────────────────────────────────
// MONEY FLOW PRESSURE LINE
// (close-open) / range × volume → directional volume weighted by price movement
// ─────────────────────────────────────────────────────────────────────────────
mf_raw    = (close - open) / bar_rng * volume
mf_ema    = ta.ema(mf_raw, 21)
mf_max    = ta.highest(math.abs(mf_ema), i_norm)
mf_osc    = mf_ema / math.max(nz(mf_max, 1.0), 1.0)          // range [-1, +1]

// ─────────────────────────────────────────────────────────────────────────────
// PRESSURE REGIME (confirmed bars — non-repainting)
// ─────────────────────────────────────────────────────────────────────────────
var int pressure = 0
if barstate.isconfirmed
    pressure := wt1 > 0.10 and wt1 > wt2 ? 1 : wt1 < -0.10 and wt1 < wt2 ? -1 : 0

pres_col = pressure == 1 ? i_bull : pressure == -1 ? i_bear : color.new(color.gray, 30)

// Volume relative to 20-bar average
vol_avg = ta.sma(volume, 20)
vol_rel = volume / math.max(vol_avg, 1.0)                     // 1.0 = average

// ─────────────────────────────────────────────────────────────────────────────
// CROSSOVER SIGNALS (confirmed bars)
// ─────────────────────────────────────────────────────────────────────────────
var bool cross_bull = false
var bool cross_bear = false
var bool zero_bull  = false
var bool zero_bear  = false

if barstate.isconfirmed
    cross_bull := ta.crossover(wt1,  wt2)
    cross_bear := ta.crossunder(wt1, wt2)
    zero_bull  := ta.crossover(wt1,  0)
    zero_bear  := ta.crossunder(wt1, 0)

// ─────────────────────────────────────────────────────────────────────────────
// DIVERGENCE DETECTION (var-tracking — no ta.valuewhen type issues)
// ─────────────────────────────────────────────────────────────────────────────
d_ph = ta.pivothigh(wt1, i_pl, i_pr)
d_pl = ta.pivotlow (wt1, i_pl, i_pr)

var float prev_wt_pl    = na
var float prev_price_l  = na
var float prev_wt_ph    = na
var float prev_price_h  = na
var bool  bull_div      = false
var bool  bear_div      = false
var int   bull_div_bar  = na
var int   bear_div_bar  = na

if barstate.isconfirmed
    bull_div := false
    bear_div := false

    if not na(d_pl)
        if i_div and not na(prev_wt_pl)
            if d_pl > prev_wt_pl and low[i_pr] < prev_price_l
                bull_div     := true
                bull_div_bar := bar_index[i_pr]
        prev_wt_pl   := d_pl
        prev_price_l := low[i_pr]

    if not na(d_ph)
        if i_div and not na(prev_wt_ph)
            if d_ph < prev_wt_ph and high[i_pr] > prev_price_h
                bear_div     := true
                bear_div_bar := bar_index[i_pr]
        prev_wt_ph   := d_ph
        prev_price_h := high[i_pr]

// ─────────────────────────────────────────────────────────────────────────────
// DIVERGENCE LINES (draw on detection, stored for latest N)
// ─────────────────────────────────────────────────────────────────────────────
var array<line> div_lines = array.new<line>()

if bull_div and not na(bull_div_bar)
    l1 = line.new(bull_div_bar, wt1[i_pr], bar_index, wt1[0],
                  color=i_div_col, width=2, style=line.style_solid)
    l2 = line.new(bull_div_bar, wt1[i_pr], bar_index, wt1[0],
                  color=color.new(i_div_col, 60), width=6)
    div_lines.push(l1)
    div_lines.push(l2)

if bear_div and not na(bear_div_bar)
    l1 = line.new(bear_div_bar, wt1[i_pr], bar_index, wt1[0],
                  color=i_div_col, width=2, style=line.style_solid)
    l2 = line.new(bear_div_bar, wt1[i_pr], bar_index, wt1[0],
                  color=color.new(i_div_col, 60), width=6)
    div_lines.push(l1)
    div_lines.push(l2)

if div_lines.size() > 20
    old = div_lines.shift()
    old.delete()

// ─────────────────────────────────────────────────────────────────────────────
// COLORING
// ─────────────────────────────────────────────────────────────────────────────
// Wave gradient: brighter at extremes, dimmer near zero
wt1_col = wt1 >= 0 ?
     color.from_gradient(math.min(wt1, 1.0),  0, 1.0, color.new(i_bull, 55), i_bull) :
     color.from_gradient(math.max(wt1, -1.0), -1.0, 0, i_bear, color.new(i_bear, 55))

// Histogram: 4-state coloring
hist_col = wt_hist >= 0 and wt_hist > wt_hist[1] ? i_bull :
           wt_hist >= 0 ?                           color.new(i_bull, 45) :
           wt_hist < 0  and wt_hist < wt_hist[1]  ? i_bear :
                                                     color.new(i_bear, 45)

// Signal line gradient
wt2_col = wt2 > 0 ? color.new(i_bull, 30) : color.new(i_bear, 30)

// ─────────────────────────────────────────────────────────────────────────────
// REFERENCE LINES
// ─────────────────────────────────────────────────────────────────────────────
h_ob2  = hline(i_ob2,  "Extreme OB",    color=color.new(i_bear, 40), linestyle=hline.style_dashed, linewidth=1)
h_ob1  = hline(i_ob1,  "OB Zone",       color=color.new(i_bear, 60), linestyle=hline.style_dashed, linewidth=1)
h_zero = hline(0.0,    "Zero Line",     color=color.new(color.gray, 35), linestyle=hline.style_solid, linewidth=1)
h_os1  = hline(i_os1,  "OS Zone",       color=color.new(i_bull, 60), linestyle=hline.style_dashed, linewidth=1)
h_os2  = hline(i_os2,  "Extreme OS",   color=color.new(i_bull, 40), linestyle=hline.style_dashed, linewidth=1)

// Zone fills
fill(h_ob1,  h_ob2,  color=color.new(i_bear, 90))
fill(h_os1,  h_os2,  color=color.new(i_bull, 90))

// ─────────────────────────────────────────────────────────────────────────────
// MAIN PLOTS
// ─────────────────────────────────────────────────────────────────────────────
// Wave area (filled between wave and zero — the signature "Cipher B" look)
p_wave = plot(wt1,  "Delta Wave",   color=wt1_col, linewidth=2)
p_zero = plot(0,    "",             color=na, editable=false)

fill(p_wave, p_zero,
     top_color    = wt1 >= 0 ? color.new(i_bull, 72) : color.new(i_bear, 92),
     bottom_color = wt1 >= 0 ? color.new(i_bull, 92) : color.new(i_bear, 72))

// Signal line
plot(wt2, "Signal", color=wt2_col, linewidth=1)

// Histogram bars (oscillator momentum)
plot(wt_hist, "Histogram", color=hist_col, style=plot.style_columns, linewidth=1)

// Cumulative windowed delta (background context)
plot(i_cum ? cum_osc * 0.45 : na, "Cumulative Delta",
     color=cum_osc > 0 ? color.new(#5c6bc0, 50) : color.new(#7e57c2, 50),
     linewidth=1, style=plot.style_area)

// Money flow pressure
plot(i_mf ? mf_osc * 0.35 : na, "Money Flow",
     color=mf_osc > 0 ? color.new(#26c6da, 55) : color.new(#ef9a9a, 55),
     linewidth=1)

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL DOTS
// ─────────────────────────────────────────────────────────────────────────────
// Wave × Signal crossovers (large circles — the main trade signals)
plotshape(cross_bull ? wt2 : na,
         style=shape.circle, location=location.absolute, size=size.normal,
         color=i_bull, title="Bull Cross Dot")
plotshape(cross_bear ? wt2 : na,
         style=shape.circle, location=location.absolute, size=size.normal,
         color=i_bear, title="Bear Cross Dot")

// Glow ring around crossover dots
plotshape(cross_bull ? wt2 : na,
         style=shape.circle, location=location.absolute, size=size.large,
         color=color.new(i_bull, 70), title="Bull Cross Glow", editable=false)
plotshape(cross_bear ? wt2 : na,
         style=shape.circle, location=location.absolute, size=size.large,
         color=color.new(i_bear, 70), title="Bear Cross Glow", editable=false)

// Zero-line crosses (small dots at the zero line)
plotshape(zero_bull ? 0.0 : na,
         style=shape.circle, location=location.absolute, size=size.tiny,
         color=color.new(i_bull, 20), title="Zero Bull")
plotshape(zero_bear ? 0.0 : na,
         style=shape.circle, location=location.absolute, size=size.tiny,
         color=color.new(i_bear, 20), title="Zero Bear")

// Volume impulse markers (star when volume surges > 2x average)
plotshape(vol_rel > 2.0 ? wt1 : na,
         style=shape.cross, location=location.absolute, size=size.tiny,
         color=color.new(color.white, 25), title="Vol Surge")

// Divergence triangles
plotshape(i_div and bull_div ? wt1[i_pr] : na,
         style=shape.triangleup, location=location.absolute, size=size.small,
         color=i_div_col, offset=-i_pr, title="Bull Divergence")
plotshape(i_div and bear_div ? wt1[i_pr] : na,
         style=shape.triangledown, location=location.absolute, size=size.small,
         color=i_div_col, offset=-i_pr, title="Bear Divergence")

// Overbought / oversold extreme dots on wave
plotshape(wt1 >= i_ob2 ? wt1 : na,
         style=shape.circle, location=location.absolute, size=size.tiny,
         color=color.new(i_bear, 0), title="OB Extreme", editable=false)
plotshape(wt1 <= i_os2 ? wt1 : na,
         style=shape.circle, location=location.absolute, size=size.tiny,
         color=color.new(i_bull, 0), title="OS Extreme", editable=false)

barcolor(pres_col, editable=false)

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
        _t := table.new(dpos, 3, 12,
                        border_width=1, border_color=color.new(color.gray, 75),
                        frame_width=2,  frame_color=color.new(color.gray, 55))

    C0 = color.new(#0a1628, 0)
    C1 = color.new(#0f2341, 0)
    C2 = color.new(#152d52, 0)

    table.cell(_t, 0, 0, "DELTA PRESSURE GAUGE", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    // Pressure regime
    pres_str = pressure == 1 ? "ACCUMULATION" : pressure == -1 ? "DISTRIBUTION" : "NEUTRAL"
    table.cell(_t, 0, 1, "Pressure", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 1, pres_str, bgcolor=C1, text_color=pres_col, text_size=size.small)
    table.cell(_t, 2, 1, pressure == 1 ? "+" : pressure == -1 ? "-" : "~",
               bgcolor=color.new(pres_col, 35), text_color=color.white, text_size=size.small)

    // Wave values
    table.cell(_t, 0, 2, "Wave 1", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, str.tostring(wt1, "#.####"),
               bgcolor=wt1 > 0 ? color.new(i_bull, 50) : color.new(i_bear, 50),
               text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 2, wt1 >= i_ob1 ? "OB" : wt1 <= i_os1 ? "OS" : "—",
               bgcolor=C2, text_color=wt1 >= i_ob1 ? i_bear : wt1 <= i_os1 ? i_bull : color.gray,
               text_size=size.small)

    table.cell(_t, 0, 3, "Wave 2 (Sig)", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 3, str.tostring(wt2, "#.####"),
               bgcolor=C1, text_color=wt2 > 0 ? i_bull : i_bear, text_size=size.small)
    table.merge_cells(_t, 1, 3, 2, 3)

    // Histogram
    table.cell(_t, 0, 4, "Histogram", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 4, str.tostring(wt_hist, "#.####"),
               bgcolor=wt_hist > 0 ? color.new(i_bull, 45) : color.new(i_bear, 45),
               text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 4, wt_hist > wt_hist[1] ? "Rising" : "Falling",
               bgcolor=C2, text_color=wt_hist > wt_hist[1] ? i_bull : i_bear, text_size=size.small)

    // Cross signals
    table.cell(_t, 0, 5, "Last Cross", bgcolor=C1, text_color=color.gray, text_size=size.small)
    last_cross_str = cross_bull ? "Bullish" : cross_bear ? "Bearish" : "None"
    last_cross_col = cross_bull ? i_bull : cross_bear ? i_bear : color.gray
    table.cell(_t, 1, 5, last_cross_str, bgcolor=C1, text_color=last_cross_col, text_size=size.small)
    table.merge_cells(_t, 1, 5, 2, 5)

    // Cumulative delta
    table.cell(_t, 0, 6, "Cum Delta", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 6, str.tostring(cum_osc, "#.####"),
               bgcolor=C2, text_color=cum_osc > 0 ? i_bull : i_bear, text_size=size.small)
    table.merge_cells(_t, 1, 6, 2, 6)

    // Money flow
    table.cell(_t, 0, 7, "Money Flow", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 7, str.tostring(mf_osc, "#.####"),
               bgcolor=C1, text_color=mf_osc > 0 ? i_bull : i_bear, text_size=size.small)
    table.merge_cells(_t, 1, 7, 2, 7)

    // Volume ratio
    table.cell(_t, 0, 8, "Vol Ratio", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 8, str.tostring(vol_rel, "#.##") + "x",
               bgcolor=vol_rel > 2.0 ? color.new(i_bull, 30) : C2,
               text_color=vol_rel > 1.5 ? color.white : color.gray, text_size=size.small)
    table.merge_cells(_t, 1, 8, 2, 8)

    // Divergence
    table.cell(_t, 0, 9, "Divergence", bgcolor=C1, text_color=color.gray, text_size=size.small)
    div_str = bull_div ? "Bullish" : bear_div ? "Bearish" : "None"
    div_col = bull_div ? i_bull : bear_div ? i_bear : color.gray
    table.cell(_t, 1, 9, div_str, bgcolor=bull_div or bear_div ? color.new(i_div_col, 40) : C1,
               text_color=div_col, text_size=size.small)
    table.merge_cells(_t, 1, 9, 2, 9)

    // Zero line
    table.cell(_t, 0, 10, "Zero Cross", bgcolor=C2, text_color=color.gray, text_size=size.small)
    zc_str = zero_bull ? "Bull X" : zero_bear ? "Bear X" : "—"
    zc_col = zero_bull ? i_bull : zero_bear ? i_bear : color.gray
    table.cell(_t, 1, 10, zc_str, bgcolor=C2, text_color=zc_col, text_size=size.small)
    table.merge_cells(_t, 1, 10, 2, 10)

    table.cell(_t, 0, 11, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 11, 2, 11)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(cross_bull, "DPG — Wave Bullish Cross",  "Delta wave crossed above signal — {{ticker}} {{interval}}")
alertcondition(cross_bear, "DPG — Wave Bearish Cross",  "Delta wave crossed below signal — {{ticker}} {{interval}}")
alertcondition(zero_bull,  "DPG — Zero Line Cross Up",  "Delta wave crossed above zero — {{ticker}}")
alertcondition(zero_bear,  "DPG — Zero Line Cross Down","Delta wave crossed below zero — {{ticker}}")
alertcondition(pressure == 1 and pressure[1] != 1,  "DPG — Accumulation State", "Delta pressure shifted to Accumulation — {{ticker}}")
alertcondition(pressure == -1 and pressure[1] != -1, "DPG — Distribution State", "Delta pressure shifted to Distribution — {{ticker}}")
alertcondition(i_div and bull_div, "DPG — Bullish Divergence", "Bullish delta divergence detected — {{ticker}}")
alertcondition(i_div and bear_div, "DPG — Bearish Divergence", "Bearish delta divergence detected — {{ticker}}")
alertcondition(wt1 >= i_ob1, "DPG — Overbought Zone", "Delta wave entered overbought — {{ticker}}")
alertcondition(wt1 <= i_os1, "DPG — Oversold Zone",   "Delta wave entered oversold — {{ticker}}")
````
