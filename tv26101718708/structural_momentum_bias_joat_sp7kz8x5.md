# Structural Momentum Bias [JOAT]

- url: https://www.tradingview.com/script/SP7kz8x5-Structural-Momentum-Bias-JOAT/
- type: indicator
- pine_id: PUB;0529371069794e48ad1fb95c811f7e59
- version: 1.0

## Description

[b]Structural Momentum Bias [JOAT][/b]

[b]Introduction[/b]

Structural Momentum Bias is an overlay indicator that combines pivot-based market structure classification with a double-smoothed momentum band system to identify the current market regime and its directional bias. The indicator continuously tracks swing highs and lows, classifies them as higher highs, lower highs, higher lows, or lower lows, and scores momentum strength on a 0-5 scale using band position and structure alignment. A break-of-structure detection system marks confirmed liquidity shifts in real time.

The core problem this indicator addresses is the disconnect between price structure and momentum. Many traders either follow structure without measuring momentum strength, or use oscillators without understanding what market structure those signals occur within. This indicator unifies both, producing a regime label (Bullish, Bearish, or Ranging) backed by a quantified score. A regime classification without a corresponding score is ambiguous. A score without regime context is incomplete. Together they provide a clearer picture of where the market is and how strongly it is in that state.

[image]https://www.tradingview.com/x/OLOz1rr8/[/image]
[b]Core Concepts[/b]

[b]1. Double-Smoothed Baseline (SMEMA)[/b]

The baseline uses a two-pass smoothing method: an EMA applied to price, followed by an SMA applied to that EMA. This reduces noise while maintaining responsiveness. It outperforms a simple MA in choppy markets because the double-pass eliminates high-frequency oscillations that cause false regime flips. The baseline slope (rising or falling) is one input into the regime classification.

[b]2. Dynamic Step Channel[/b]

The channel bands are not fixed multiples of ATR. Instead, they use the 100-bar average of the high-low range as the step unit, producing three tiers of bands above and below the baseline. This approach adapts to each instrument's natural swing amplitude without requiring manual calibration per market. Each band tier has a gradient color that intensifies as price approaches that level from within the channel, providing visual distance context.

[b]3. Pivot-Based Structure Classification[/b]

Swing highs and lows are identified using confirmed pivots (lookback left and right bars). The indicator classifies the relationship between successive pivots as HH (higher high), LH (lower high), HL (higher low), or LL (lower low). These four states are combined to determine whether structure is bullish (HH + HL), bearish (LH + LL), or mixed. Importantly, pivot detection is offset by the lookback period, so no repainting occurs — a pivot is only confirmed when enough subsequent bars have closed to validate it.

[b]4. Momentum Strength Score (0-5)[/b]

The score adds one point for each of: price above band tier 1, price above band tier 2, price above band tier 3, higher high present, and higher low present (inverted for bearish scoring). This produces a 0-5 integer that quantifies how strongly the market is expressing the current regime. A score of 5 in a bullish regime means price is extended above all three band tiers with confirmed higher highs and higher lows — a strongly trending condition. A score of 1 or 2 suggests marginal or weakening conditions.

[b]5. Break of Structure (BOS) Detection[/b]

A bullish BOS is confirmed when price closes above the most recent swing high on a confirmed bar. A bearish BOS is confirmed when price closes below the most recent swing low. The BOS line is drawn from the pivot bar to the current bar and extends right, with a thick transparent shadow line providing visual depth. BOS detection only fires on barstate.isconfirmed, preventing any repainting.

[b]Features[/b]

[list]
[*][b]Regime Dashboard:[/b] 9-row dark-themed table showing regime, baseline direction, bull score, bear score, structure state, ATR, and last BOS
[*][b]Dynamic Momentum Bands:[/b] Six gradient-colored bands (three above, three below) that visually represent price position within the momentum channel
[*][b]SMEMA Baseline:[/b] Color-coded by regime, changes in real time as regime shifts
[*][b]Break of Structure Lines:[/b] Thin solid + thick ghost dual-line rendering at confirmed structural breaks, extending to the current bar
[*][b]Confirmed Pivot Dots:[/b] Small circles at each confirmed swing high and low, plotted at the exact pivot bar
[*][b]Bar Coloring:[/b] Candles are colored by current regime state
[*][b]Band Fill Gradients:[/b] Fill between band tiers intensifies based on price proximity
[/list]

[b]Input Parameters[/b]

[b]Structure Settings:[/b]
[list]
[*]Pivot Lookback: Number of bars left and right required to confirm a pivot (default: 5)
[*]Baseline Length: Period for the SMEMA double-smoothed baseline (default: 10)
[*]Show Structure Breaks: Toggle BOS line rendering
[/list]

[b]Visual Settings:[/b]
[list]
[*]Dashboard toggle and position
[*]Momentum Bands toggle
[*]Bullish, Bearish, and Ranging color inputs
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the Regime[/b]
The dashboard label and bar coloring immediately show the current regime. Bullish requires the baseline to be rising and a momentum score of 2 or more.

[b]Step 2: Assess Score Strength[/b]
A score of 4-5 indicates a well-developed trend with band extension and confirmed structure. A score of 1-2 suggests the regime is marginal and may not sustain.

[b]Step 3: Watch for BOS Events[/b]
A BOS in the direction of the regime adds confirmation that a structural shift has occurred. A counter-regime BOS is an early warning that conditions may be changing.

[b]Step 4: Use Bands for Context[/b]
Price returning to the baseline from above in a bullish regime is a potential pullback entry area. Price extending above band tier 2 or 3 suggests overextension.

[b]Limitations[/b]

[list]
[*]The pivot confirmation delay (lookback bars) means BOS signals and pivot markers appear several bars after the actual swing point. This is a deliberate design choice to prevent repainting
[*]The regime score of 2 as the minimum threshold for classification means borderline conditions will oscillate between Ranging and a directional regime on consecutive bars
[*]The SMEMA baseline is smoother than a standard EMA but still lags price. In fast-moving markets this lag may cause regime flips after significant portions of a move have already occurred
[*]Band width is determined by the 100-bar average of bar ranges. In markets with sudden volatility regime changes (such as after news releases), the bands may not reflect the new volatility environment for many bars
[/list]

[b]Originality Statement[/b]

This indicator is original in its specific combination of elements and the scoring framework it produces. The justification for combining structure detection with a band-based scoring system is that neither component alone provides actionable context. Structure alone (HH/HL) says direction but not strength. Bands alone say relative position but not structural validity. The 0-5 score synthesizes both into a single conviction metric. The double-smoothed baseline (EMA of EMA, then SMA) is a deliberate design choice that reduces false regime flips without the extreme lag of longer single-pass averages. The dynamic step channel uses bar range (not ATR) as its unit, which scales naturally with each instrument's price action characteristics.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice or a recommendation to buy or sell any financial instrument. Past structural patterns do not guarantee their repetition. A bullish regime classification does not predict future price direction. Always apply proper risk management. The author is not responsible for any trading losses.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Structural Momentum Bias [JOAT]", shorttitle="SMB [JOAT]", overlay=true,
         max_lines_count=300, max_boxes_count=200, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp_s  = "Structure Settings"
i_piv  = input.int(5,  "Pivot Lookback",    minval=2,  maxval=15, group=grp_s)
i_slen = input.int(10, "Baseline Length",   minval=5,  maxval=50, group=grp_s)
i_bos  = input.bool(true, "Show Structure Breaks", group=grp_s)

grp_v  = "Visual Settings"
i_dash = input.bool(true,  "Show Dashboard",    group=grp_v)
i_band = input.bool(true,  "Show Momentum Bands", group=grp_v)
i_dpos = input.string("Top Right", "Dashboard Position",
         options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=grp_v)
i_bull = input.color(#00bfa5, "Bullish Color", group=grp_v)
i_bear = input.color(#ef5350, "Bearish Color", group=grp_v)
i_rng  = input.color(#ffd54f, "Ranging Color", group=grp_v)

// ─────────────────────────────────────────────────────────────────────────────
// FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────
// Double-smoothed MA: EMA responsiveness + SMA smoothness
smema(src, len) =>
    ta.sma(ta.ema(src, len), len)

// Percentile-normalized distance from price to a level
dist_pct(src) =>
    d = math.abs(close - src)
    pct_ref = ta.percentile_linear_interpolation(math.abs(close - smema(close, i_slen)), 400, 100)
    math.min(d / math.max(pct_ref, syminfo.mintick), 1.5)

// ─────────────────────────────────────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
// Baseline and dynamic step channel
baseline = smema(close, i_slen)
step     = smema(high - low, 100)

b_up1 = baseline + step
b_up2 = baseline + step * 2
b_up3 = baseline + step * 3
b_dn1 = baseline - step
b_dn2 = baseline - step * 2
b_dn3 = baseline - step * 3

// Confirmed pivot detection — non-repainting
ph = ta.pivothigh(high, i_piv, i_piv)
pl = ta.pivotlow (low,  i_piv, i_piv)

var float ph1 = na
var float ph2 = na
var float pl1 = na
var float pl2 = na
var int   phi = na
var int   pli = na

if not na(ph)
    ph2 := ph1
    ph1 := ph
    phi := bar_index[i_piv]

if not na(pl)
    pl2 := pl1
    pl1 := pl
    pli := bar_index[i_piv]

// Market structure classification
s_hh = not na(ph1) and not na(ph2) and ph1 > ph2
s_lh = not na(ph1) and not na(ph2) and ph1 < ph2
s_ll = not na(pl1) and not na(pl2) and pl1 < pl2
s_hl = not na(pl1) and not na(pl2) and pl1 > pl2

// Trend direction from baseline slope
rising  = baseline > baseline[1]
falling = baseline < baseline[1]

// Additive momentum strength score (0–5)
bull_score = (close > b_up1 ? 1:0) + (close > b_up2 ? 1:0) + (close > b_up3 ? 1:0)
           + (s_hh ? 1:0) + (s_hl ? 1:0)
bear_score = (close < b_dn1 ? 1:0) + (close < b_dn2 ? 1:0) + (close < b_dn3 ? 1:0)
           + (s_ll ? 1:0) + (s_lh ? 1:0)

// Regime classification — only on confirmed bars to prevent repainting
var int regime = 0
if barstate.isconfirmed
    regime := rising and bull_score >= 2 ? 1 : falling and bear_score >= 2 ? -1 : 0

r_col = regime == 1 ? i_bull : regime == -1 ? i_bear : i_rng

// ─────────────────────────────────────────────────────────────────────────────
// STRUCTURE BREAK DETECTION (confirmed bars, non-repainting)
// ─────────────────────────────────────────────────────────────────────────────
var bool bos_bull_active = false
var bool bos_bear_active = false

if barstate.isconfirmed
    if not na(ph1) and close > ph1 and close[1] <= ph1
        bos_bull_active := true
        bos_bear_active := false
    if not na(pl1) and close < pl1 and close[1] >= pl1
        bos_bear_active := true
        bos_bull_active := false

bos_bull = bos_bull_active and bos_bull_active != bos_bull_active[1]
bos_bear = bos_bear_active and bos_bear_active != bos_bear_active[1]

// ─────────────────────────────────────────────────────────────────────────────
// BOS LINE RENDERING
// ─────────────────────────────────────────────────────────────────────────────
var line bos_l1  = na
var line bos_l2  = na
var box  bos_lbl = na

if i_bos
    if bos_bull and not na(phi) and not na(ph1)
        line.delete(bos_l1)
        line.delete(bos_l2)
        box.delete(bos_lbl)
        bos_l1  := line.new(phi, ph1, bar_index, ph1, color=i_bull, width=1,
                            style=line.style_solid)
        bos_l2  := line.new(phi, ph1, bar_index, ph1,
                            color=color.new(i_bull, 65), width=7)
        bos_lbl := box.new(phi, ph1, bar_index, ph1, text="BOS",
                           text_size=size.small, text_color=i_bull,
                           text_halign=text.align_center, text_valign=text.align_bottom,
                           bgcolor=color.new(color.black, 100),
                           border_color=color.new(color.black, 100))

    if bos_bear and not na(pli) and not na(pl1)
        line.delete(bos_l1)
        line.delete(bos_l2)
        box.delete(bos_lbl)
        bos_l1  := line.new(pli, pl1, bar_index, pl1, color=i_bear, width=1,
                            style=line.style_solid)
        bos_l2  := line.new(pli, pl1, bar_index, pl1,
                            color=color.new(i_bear, 65), width=7)
        bos_lbl := box.new(pli, pl1, bar_index, pl1, text="BOS",
                           text_size=size.small, text_color=i_bear,
                           text_halign=text.align_center, text_valign=text.align_top,
                           bgcolor=color.new(color.black, 100),
                           border_color=color.new(color.black, 100))

// Extend active BOS lines on every bar
if not na(bos_l1)
    bos_l1.set_x2(bar_index)
    bos_l2.set_x2(bar_index)
    bos_lbl.set_right(bar_index)

// ─────────────────────────────────────────────────────────────────────────────
// BAND GRADIENT COLORS
// ─────────────────────────────────────────────────────────────────────────────
f_cu1 = i_band ? color.from_gradient(dist_pct(b_up1), 0, 1.0, color.new(i_bull, 97), color.new(i_bull, 38)) : color(na)
f_cu2 = i_band ? color.from_gradient(dist_pct(b_up2), 0, 1.0, color.new(i_bull, 97), color.new(i_bull, 28)) : color(na)
f_cu3 = i_band ? color.from_gradient(dist_pct(b_up3), 0, 1.0, color.new(i_bull, 97), color.new(i_bull, 18)) : color(na)
f_cd1 = i_band ? color.from_gradient(dist_pct(b_dn1), 0, 1.0, color.new(i_bear, 97), color.new(i_bear, 38)) : color(na)
f_cd2 = i_band ? color.from_gradient(dist_pct(b_dn2), 0, 1.0, color.new(i_bear, 97), color.new(i_bear, 28)) : color(na)
f_cd3 = i_band ? color.from_gradient(dist_pct(b_dn3), 0, 1.0, color.new(i_bear, 97), color.new(i_bear, 18)) : color(na)

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
pu3 = plot(b_up3, color=f_cu3, linewidth=1, editable=false)
pu2 = plot(b_up2, color=f_cu2, linewidth=1, editable=false)
pu1 = plot(b_up1, color=f_cu1, linewidth=1, editable=false)
pb  = plot(baseline, "Baseline", color=color.new(r_col, 15), linewidth=2)
pd1 = plot(b_dn1, color=f_cd1, linewidth=1, editable=false)
pd2 = plot(b_dn2, color=f_cd2, linewidth=1, editable=false)
pd3 = plot(b_dn3, color=f_cd3, linewidth=1, editable=false)

fill(pu1, pu2, color=color.new(i_bull, 93), editable=false)
fill(pu2, pu3, color=color.new(i_bull, 89), editable=false)
fill(pd1, pd2, color=color.new(i_bear, 93), editable=false)
fill(pd2, pd3, color=color.new(i_bear, 89), editable=false)

// Candle coloring by regime
barcolor(r_col, editable=false)

// Pivot confirmation circles (offset to confirmed pivot bar)
plotshape(not na(ph) ? ph : na, style=shape.circle, location=location.absolute,
         color=color.new(i_bear, 35), size=size.tiny, offset=-i_piv, editable=false)
plotshape(not na(pl) ? pl : na, style=shape.circle, location=location.absolute,
         color=color.new(i_bull, 35), size=size.tiny, offset=-i_piv, editable=false)

// Trend change diamond on baseline
plotshape(regime != regime[1] and not na(baseline[1]) ? baseline[1] : na,
         location=location.absolute, style=shape.diamond,
         color=chart.fg_color, size=size.tiny, offset=-1, editable=false)

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

    table.cell(_t, 0, 0, "STRUCTURAL MOMENTUM BIAS", bgcolor=C0,
               text_color=color.white, text_size=size.small)
    table.merge_cells(_t, 0, 0, 2, 0)

    table.cell(_t, 0, 1, "Regime", bgcolor=C1, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 1, regime == 1 ? "BULLISH" : regime == -1 ? "BEARISH" : "RANGING",
               bgcolor=C1, text_color=r_col, text_size=size.small)
    table.cell(_t, 2, 1, regime == 1 ? "+" : regime == -1 ? "-" : "~",
               bgcolor=color.new(r_col, 40), text_color=color.white, text_size=size.small)

    table.cell(_t, 0, 2, "Baseline", bgcolor=C2, text_color=color.gray, text_size=size.small)
    table.cell(_t, 1, 2, str.tostring(baseline, format.mintick),
               bgcolor=C2, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 2, rising ? "Rising" : "Falling",
               bgcolor=C2, text_color=rising ? i_bull : i_bear, text_size=size.small)

    table.cell(_t, 0, 3, "Bull Score", bgcolor=C1, text_color=color.gray, text_size=size.small)
    bs_bg = bull_score >= 4 ? color.new(i_bull, 20) : bull_score >= 2 ? color.new(i_bull, 55) : C1
    table.cell(_t, 1, 3, str.tostring(bull_score) + " / 5",
               bgcolor=bs_bg, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 3, bull_score >= 4 ? "Strong" : bull_score >= 2 ? "Moderate" : "Weak",
               bgcolor=C1, text_color=bull_score >= 3 ? i_bull : color.gray, text_size=size.small)

    table.cell(_t, 0, 4, "Bear Score", bgcolor=C2, text_color=color.gray, text_size=size.small)
    rbs_bg = bear_score >= 4 ? color.new(i_bear, 20) : bear_score >= 2 ? color.new(i_bear, 55) : C2
    table.cell(_t, 1, 4, str.tostring(bear_score) + " / 5",
               bgcolor=rbs_bg, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 4, bear_score >= 4 ? "Strong" : bear_score >= 2 ? "Moderate" : "Weak",
               bgcolor=C2, text_color=bear_score >= 3 ? i_bear : color.gray, text_size=size.small)

    table.cell(_t, 0, 5, "Structure", bgcolor=C1, text_color=color.gray, text_size=size.small)
    str_txt = (s_hh ? "HH " : s_lh ? "LH " : "-- ") + (s_hl ? "HL" : s_ll ? "LL" : "--")
    str_col = s_hh and s_hl ? i_bull : s_lh and s_ll ? i_bear : i_rng
    table.cell(_t, 1, 5, str_txt,
               bgcolor=C1, text_color=str_col, text_size=size.small)
    table.merge_cells(_t, 1, 5, 2, 5)

    table.cell(_t, 0, 6, "ATR(14)", bgcolor=C2, text_color=color.gray, text_size=size.small)
    atr14 = ta.atr(14)
    table.cell(_t, 1, 6, str.tostring(atr14, format.mintick),
               bgcolor=C2, text_color=color.white, text_size=size.small)
    table.cell(_t, 2, 6, str.tostring(atr14 / close * 100, "#.##") + "%",
               bgcolor=C2, text_color=color.gray, text_size=size.small)

    table.cell(_t, 0, 7, "Struct Break", bgcolor=C1, text_color=color.gray, text_size=size.small)
    bos_txt = bos_bull_active ? "Bullish" : bos_bear_active ? "Bearish" : "None"
    bos_c   = bos_bull_active ? i_bull : bos_bear_active ? i_bear : color.gray
    table.cell(_t, 1, 7, bos_txt, bgcolor=C1, text_color=bos_c, text_size=size.small)
    table.merge_cells(_t, 1, 7, 2, 7)

    table.cell(_t, 0, 8, "jackofalltrades", bgcolor=C0,
               text_color=color.new(color.white, 60), text_size=size.tiny)
    table.merge_cells(_t, 0, 8, 2, 8)

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bos_bull, "SMB — Bullish Structure Break",
               "Bullish Break of Structure confirmed — {{ticker}} {{interval}}")
alertcondition(bos_bear, "SMB — Bearish Structure Break",
               "Bearish Break of Structure confirmed — {{ticker}} {{interval}}")
alertcondition(regime == 1 and regime[1] != 1,  "SMB — Regime: Bullish",
               "Market regime shifted Bullish — {{ticker}}")
alertcondition(regime == -1 and regime[1] != -1, "SMB — Regime: Bearish",
               "Market regime shifted Bearish — {{ticker}}")
````
