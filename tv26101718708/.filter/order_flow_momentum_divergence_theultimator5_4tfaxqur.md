# Order Flow Momentum Divergence [theUltimator5]

- url: https://www.tradingview.com/script/4TFAxqur-Order-Flow-Momentum-Divergence-theUltimator5/
- type: indicator
- pine_id: PUB;8da03ec97d294c8ba78c2a4d695a2eef
- version: 1.0

## Description

This indicator is the [b]Order Flow Momentum Divergence (OFMD)
[/b]
Most momentum indicators tell you what price has already done (lagging indicators).  This indicator is an attempt at a leading indicator by monitoring order flow momentum through volume footprint, comparing it to price momentum, and tracking divergences.

Price momentum indicators -> RSI, MACD, stochastics, all of them lag. They are derivatives of the close. When RSI is overbought, it means price has been going up. That's it. It tells you nothing about whether the actual buying pressure behind that move is still present, exhausted, or already reversing.

Footprint delta alone has the opposite problem. It's noisy, spiky, and hard to read directionally across timeframes. A single bar with massive positive delta doesn't tell you much in isolation.

What OFMD is actually solving is the confirmation gap. Specifically: is the order flow that drove a price move still supporting it, or has it quietly shifted while price continues on inertia?

When Flow Momentum and Price Momentum agree, the move has both structural and transactional backing. When they diverge, particularly when Flow Momentum turns while Price Momentum hasn't yet, you're seeing a potential early warning that the fuel behind the move is changing before price reflects it. 

In plain terms: most traders get stopped out or give back gains because they're reading price alone.  They're not reading what's happening inside the price. OFMD attempts to surface that internal picture and put it on the same scale as a familiar momentum oscillator so the two can be directly compared bar by bar.

[b]IMPORTANT - Before reading further, this indicator uses the volume footprint, which requires (at the time of creating the indicator) a premium TradingView subscription.  If you do not have a access to the volume footprint function, this indicator will not function as intended.[/b]

[b]HOW IT WORKS[/b]

OFMD runs two signals in parallel.
1) The first is Flow Momentum: a net bias score built by running footprint delta through 100 Hull Moving Averages simultaneously (lengths 2 through 101), normalizing each, and averaging the result. The output is a single -100 to +100 value that represents the aggregate directional lean of order flow across all measured timeframes at once.

2) The second is Price Momentum: a standard 7-period RSI rescaled to the same -100 to +100 range for direct comparison.

When these two signals diverge, Flow Momentum rising while Price Momentum falls, or vice versa, the indicator flags it. That divergence is the signal. The fill between the two lines intensifies as the gap widens. The chart overlay bands extend from price proportionally to signal strength, giving you a visual anchor directly on the candles without needing to cross-reference the sub-pane.
[image]https://www.tradingview.com/x/Z5STbQkO/[/image]

[b]Sub-Pane Series[/b]

[i]Show Flow Momentum Line[/i] - The purple line. Displays the aggregate order flow bias score derived from footprint delta. Opacity scales with signal strength; it fades when bias is weak and near zero, and becomes fully opaque as conviction builds.

[i]Show Price Momentum Line[/i] - The yellow line. A 7-period RSI stretched to -100/+100 so it sits on the same scale as Flow Momentum. Crossing zero means RSI has crossed 50.  It is simply a shifted visual of RSI to match the order flow momentum in order to visually watch bullish/bearish crossings.

[i]Show Divergence Fill[/i] - Fills the area between the two lines. Color is green for bullish divergence (Flow Momentum leading up) and red for bearish (Flow Momentum leading down). Opacity increases as the gap between the signals widens. Both lines need to be enabled for the fill to render.

[i]Show Difference Histogram [b](Disabled by default)[/b][/i] - Plots the raw arithmetic difference between Flow Momentum and Price Momentum as a histogram. Green bars mean flow is ahead of price; red bars mean price is ahead of flow. Useful for gauging divergence magnitude at a glance without reading the lines themselves.
[image]https://www.tradingview.com/x/1bKKAtvW/[/image]

[b]Chart Overlay[/b]

[i]Band Mode[/i] — Controls which overlay band or combination of bands is drawn on the price chart.

[list=1]
[*][i]Bias Band[/i]: a single band anchored to a short EMA of price, offset proportionally to Flow Momentum strength. Color shifts from purple at maximum bearish bias through neutral at zero to green at maximum bullish bias. This band tells you where order flow bias is pointing relative to current price.  This line acts as a price continuation indicator.
[image]https://www.tradingview.com/x/TOEvAS7b/[/image]

[*][i]Divergence Band[/i]: This plots the offset proportionally to the gap between Flow Momentum and Price Momentum rather than to either signal individually. Color shifts from deep orange when price momentum is leading to electric blue when flow momentum is leading. This band is suppressed when both signals are on the same side but not in strong agreement, to avoid noise. When both signals agree strongly, the Divergence Band inherits the Bias Band's color and position.
[image]https://www.tradingview.com/x/1v3ih1QP/[/image]

[*][i]Combined [b](default)[/b][/i]:  renders both bands simultaneously. The Bias Band fill and the Divergence Band fill are independent in this mode. Only one line is ever drawn on the chart - the Divergence Band line, which adopts the Bias Band's color when signals are strongly aligned.
[image]https://www.tradingview.com/x/wllk2yEH/[/image]
[/list]


[b]Other toggles[/b]

[i]Enable Chart Overlay [/i]- Master switch for everything drawn on the price chart. Turning this off leaves the sub-pane intact and removes all overlay rendering.

[i]Show Bias Band Line [/i]- Toggles the outer line of the Bias Band. Only applies when Band Mode is set to Bias Band; in Combined mode the Divergence Band line covers this role.

[i]Show Bias Band Fill[/i] - Toggles the fill between the Bias Band line and its anchor. Fill opacity is zero when bias is within ±20 and ramps to full as bias approaches ±100, so weak signals don't clutter the chart.

[i]Show Divergence Band Line[/i] - Toggles the outer line of the Divergence Band. This is the only line that renders in Combined mode.

[i]Show Divergence Band Fill[/i] - Toggles the fill between the Divergence Band line and its anchor. Like the Bias Band fill, opacity is gated - it stays invisible until the divergence gap exceeds 20, then ramps proportionally. Suppressed entirely when both signals share the same sign but lack strong conviction.

[i]Show Background Highlight[/i] - Tints the chart background green during bullish divergence and red during bearish divergence. Only activates when the gap between the two signals exceeds 50, so it fires on meaningful separations rather than routine noise. Opacity scales with gap size up to a ceiling.
[image]https://www.tradingview.com/x/NyVSLA08/[/image]

[b]Overlay Smoothing[/b]

[i]Smooth Overlay Bands (EMA) [b](Enabled by default)[/b][/i] - Applies an EMA to the four overlay band position values before they are plotted. This reduces bar-to-bar jitter on the chart overlay without touching any of the sub-pane calculations. Flow Momentum, Price Momentum, and the histogram are unaffected.
When the overlay bands aren't smoothed, the response time for divergences is quicker, but the overlay chart is noisy and can produce more false signals.
[image]https://www.tradingview.com/x/ehWB8G22/[/image]
[image]https://www.tradingview.com/x/fL4BkWW5/[/image]

[i]Smoothing Length [/i]- The EMA period applied to the overlay bands when smoothing is enabled. Default is 5. Lower values track price more closely with more noise; higher values produce cleaner bands with more lag. The useful range is roughly 3 to 15 for most instruments and timeframes.

## Source Code

````pine
//@version=6
indicator("Order Flow Momentum Divergence [theUltimator5]", overlay=false, max_lines_count=500)

// ============================================================================
// INPUT GROUPS
// ============================================================================

// --- Sub-Pane Series ---
show_delta_bias   = input.bool(true,  "Show Flow Momentum Line",
     tooltip="Plots the net order flow bias derived from footprint delta across 100 HMA lengths. Purple line in the sub-pane.",
     group="Sub-Pane Series")

show_momentum     = input.bool(true,  "Show Price Momentum Line",
     tooltip="Plots a scaled RSI (range: -100 to +100) as a measure of price momentum. Gold line in the sub-pane.",
     group="Sub-Pane Series")

show_series_fill  = input.bool(true,  "Show Divergence Fill",
     tooltip="Fills the area between the Flow Momentum and Price Momentum lines. Color intensity reflects divergence strength. Only visible when both lines are enabled.",
     group="Sub-Pane Series")

show_diff_hist    = input.bool(false, "Show Difference Histogram",
     tooltip="Plots a histogram of the raw gap between Flow Momentum and Price Momentum. Green bars = flow momentum leading; red bars = price momentum leading.",
     group="Sub-Pane Series")

// --- Chart Overlay ---
// Band Mode at top so the user knows which band controls apply before seeing them
band_mode         = input.string("Combined", "Band Mode",
     options=["Bias Band", "Divergence Band", "Combined"],
     tooltip="Bias Band: shows a price-offset band driven by Flow Momentum alone.\nDivergence Band: shows a band driven by the divergence between Flow Momentum and Price Momentum.\nCombined: shows both bands simultaneously, with the Divergence Band merging into the Bias Band when signals align strongly.",
     group="Chart Overlay")

show_bias_band    = band_mode == "Bias Band" or band_mode == "Combined"
show_diff_band    = band_mode == "Divergence Band" or band_mode == "Combined"
show_combined     = band_mode == "Combined"

show_overlay      = input.bool(true,  "Enable Chart Overlay",
     tooltip="Master toggle for all chart overlay effects (bands, fills, background). Disabling this hides everything drawn on the price chart.",
     group="Chart Overlay")

show_bias_line    = input.bool(true,  "Show Bias Band Line",
     tooltip="Shows the outer line of the Bias Band on the chart. The line color shifts from magenta (bearish bias) to lime (bullish bias).",
     group="Chart Overlay")

show_bias_fill    = input.bool(true,  "Show Bias Band Fill",
     tooltip="Fills the area between the Bias Band line and its anchor. Opacity increases as bias strength grows beyond ±20.",
     group="Chart Overlay")

show_diff_line    = input.bool(true,  "Show Divergence Band Line",
     tooltip="Shows the outer line of the Divergence Band on the chart. Color shifts from deep orange (price momentum leading) to electric blue (flow momentum leading).",
     group="Chart Overlay")

show_diff_fill    = input.bool(true,  "Show Divergence Band Fill",
     tooltip="Fills the area between the Divergence Band line and its anchor. Hidden when both signals share the same sign but are not strongly aligned.",
     group="Chart Overlay")

show_bg_highlight = input.bool(false, "Show Background Highlight",
     tooltip="Tints the chart background green during bullish divergence and red during bearish divergence, when the gap between the two signals exceeds the threshold of 50.",
     group="Chart Overlay")

// --- Overlay Smoothing ---
smooth_overlay    = input.bool(true,  "Smooth Overlay Bands (EMA)",
     tooltip="Applies an EMA to the overlay band positions to reduce bar-to-bar noise on the chart. Does not affect the sub-pane lines.",
     group="Overlay Smoothing")

smooth_len        = input.int(5,      "Smoothing Length",
     minval=2, maxval=50,
     tooltip="Number of bars used for the overlay EMA smoothing. Lower values = more reactive; higher values = smoother but more lag.",
     group="Overlay Smoothing")

// ============================================================================
// CONSTANTS
// ============================================================================
rsi_len       = 7
bg_threshold  = 50
band_ema_len  = 5

// ============================================================================
// FUNCTIONS
// ============================================================================
f_score(float val) =>
    (nz(val, 50.0) / 50.0) - 1.0

f_net_bias(float src) =>
    float t = 0.0
    t += f_score(nz(ta.hma(src,   2), 50.0)) + f_score(nz(ta.hma(src,   3), 50.0)) + f_score(nz(ta.hma(src,   4), 50.0)) + f_score(nz(ta.hma(src,   5), 50.0)) + f_score(nz(ta.hma(src,   6), 50.0))
    t += f_score(nz(ta.hma(src,   7), 50.0)) + f_score(nz(ta.hma(src,   8), 50.0)) + f_score(nz(ta.hma(src,   9), 50.0)) + f_score(nz(ta.hma(src,  10), 50.0)) + f_score(nz(ta.hma(src,  11), 50.0))
    t += f_score(nz(ta.hma(src,  12), 50.0)) + f_score(nz(ta.hma(src,  13), 50.0)) + f_score(nz(ta.hma(src,  14), 50.0)) + f_score(nz(ta.hma(src,  15), 50.0)) + f_score(nz(ta.hma(src,  16), 50.0))
    t += f_score(nz(ta.hma(src,  17), 50.0)) + f_score(nz(ta.hma(src,  18), 50.0)) + f_score(nz(ta.hma(src,  19), 50.0)) + f_score(nz(ta.hma(src,  20), 50.0)) + f_score(nz(ta.hma(src,  21), 50.0))
    t += f_score(nz(ta.hma(src,  22), 50.0)) + f_score(nz(ta.hma(src,  23), 50.0)) + f_score(nz(ta.hma(src,  24), 50.0)) + f_score(nz(ta.hma(src,  25), 50.0)) + f_score(nz(ta.hma(src,  26), 50.0))
    t += f_score(nz(ta.hma(src,  27), 50.0)) + f_score(nz(ta.hma(src,  28), 50.0)) + f_score(nz(ta.hma(src,  29), 50.0)) + f_score(nz(ta.hma(src,  30), 50.0)) + f_score(nz(ta.hma(src,  31), 50.0))
    t += f_score(nz(ta.hma(src,  32), 50.0)) + f_score(nz(ta.hma(src,  33), 50.0)) + f_score(nz(ta.hma(src,  34), 50.0)) + f_score(nz(ta.hma(src,  35), 50.0)) + f_score(nz(ta.hma(src,  36), 50.0))
    t += f_score(nz(ta.hma(src,  37), 50.0)) + f_score(nz(ta.hma(src,  38), 50.0)) + f_score(nz(ta.hma(src,  39), 50.0)) + f_score(nz(ta.hma(src,  40), 50.0)) + f_score(nz(ta.hma(src,  41), 50.0))
    t += f_score(nz(ta.hma(src,  42), 50.0)) + f_score(nz(ta.hma(src,  43), 50.0)) + f_score(nz(ta.hma(src,  44), 50.0)) + f_score(nz(ta.hma(src,  45), 50.0)) + f_score(nz(ta.hma(src,  46), 50.0))
    t += f_score(nz(ta.hma(src,  47), 50.0)) + f_score(nz(ta.hma(src,  48), 50.0)) + f_score(nz(ta.hma(src,  49), 50.0)) + f_score(nz(ta.hma(src,  50), 50.0)) + f_score(nz(ta.hma(src,  51), 50.0))
    t += f_score(nz(ta.hma(src,  52), 50.0)) + f_score(nz(ta.hma(src,  53), 50.0)) + f_score(nz(ta.hma(src,  54), 50.0)) + f_score(nz(ta.hma(src,  55), 50.0)) + f_score(nz(ta.hma(src,  56), 50.0))
    t += f_score(nz(ta.hma(src,  57), 50.0)) + f_score(nz(ta.hma(src,  58), 50.0)) + f_score(nz(ta.hma(src,  59), 50.0)) + f_score(nz(ta.hma(src,  60), 50.0)) + f_score(nz(ta.hma(src,  61), 50.0))
    t += f_score(nz(ta.hma(src,  62), 50.0)) + f_score(nz(ta.hma(src,  63), 50.0)) + f_score(nz(ta.hma(src,  64), 50.0)) + f_score(nz(ta.hma(src,  65), 50.0)) + f_score(nz(ta.hma(src,  66), 50.0))
    t += f_score(nz(ta.hma(src,  67), 50.0)) + f_score(nz(ta.hma(src,  68), 50.0)) + f_score(nz(ta.hma(src,  69), 50.0)) + f_score(nz(ta.hma(src,  70), 50.0)) + f_score(nz(ta.hma(src,  71), 50.0))
    t += f_score(nz(ta.hma(src,  72), 50.0)) + f_score(nz(ta.hma(src,  73), 50.0)) + f_score(nz(ta.hma(src,  74), 50.0)) + f_score(nz(ta.hma(src,  75), 50.0)) + f_score(nz(ta.hma(src,  76), 50.0))
    t += f_score(nz(ta.hma(src,  77), 50.0)) + f_score(nz(ta.hma(src,  78), 50.0)) + f_score(nz(ta.hma(src,  79), 50.0)) + f_score(nz(ta.hma(src,  80), 50.0)) + f_score(nz(ta.hma(src,  81), 50.0))
    t += f_score(nz(ta.hma(src,  82), 50.0)) + f_score(nz(ta.hma(src,  83), 50.0)) + f_score(nz(ta.hma(src,  84), 50.0)) + f_score(nz(ta.hma(src,  85), 50.0)) + f_score(nz(ta.hma(src,  86), 50.0))
    t += f_score(nz(ta.hma(src,  87), 50.0)) + f_score(nz(ta.hma(src,  88), 50.0)) + f_score(nz(ta.hma(src,  89), 50.0)) + f_score(nz(ta.hma(src,  90), 50.0)) + f_score(nz(ta.hma(src,  91), 50.0))
    t += f_score(nz(ta.hma(src,  92), 50.0)) + f_score(nz(ta.hma(src,  93), 50.0)) + f_score(nz(ta.hma(src,  94), 50.0)) + f_score(nz(ta.hma(src,  95), 50.0)) + f_score(nz(ta.hma(src,  96), 50.0))
    t += f_score(nz(ta.hma(src,  97), 50.0)) + f_score(nz(ta.hma(src,  98), 50.0)) + f_score(nz(ta.hma(src,  99), 50.0)) + f_score(nz(ta.hma(src, 100), 50.0)) + f_score(nz(ta.hma(src, 101), 50.0))
    t / 100.0

// ============================================================================
// FOOTPRINT DATA
// ============================================================================
var float fp_heatmap = 50.0

footprint reqFP = request.footprint(100, 70)
if not na(reqFP)
    fp_delta          = reqFP.delta()
    volume_row pocRow = reqFP.poc()
    fp_heatmap       := math.max(0, math.min(100, (fp_delta / ta.hma(math.abs(fp_delta + 0.0001), 14) * 50) + 50))

// ============================================================================
// CORE CALCULATIONS
// ============================================================================
float delta_bias    = f_net_bias(fp_heatmap) * 100.0   // Order flow bias, -100 to +100
float price_mom     = (ta.rsi(close, rsi_len) - 50.0) * 2.0  // Scaled RSI, -100 to +100

float delta_smooth  = ta.ema(delta_bias, 4)
float mom_smooth    = ta.ema(price_mom,  4)

bool delta_rising   = delta_smooth > delta_smooth[1]
bool delta_falling  = delta_smooth < delta_smooth[1]
bool mom_rising     = mom_smooth   > mom_smooth[1]
bool mom_falling    = mom_smooth   < mom_smooth[1]

// Divergence conditions
bool bull_div = delta_rising  and mom_falling and delta_bias > price_mom  // Delta bias leading up, momentum lagging
bool bear_div = delta_falling and mom_rising  and delta_bias < price_mom  // Delta bias leading down, momentum lagging
bool diverging = bull_div or bear_div

float signal_gap  = math.abs(delta_bias - price_mom)
float gap_norm    = math.min(signal_gap / 100.0, 1.0)
int   div_transp  = diverging ? int(math.max(10.0, 100.0 - gap_norm * 85.0)) : 100

color bull_col  = color.rgb(0,   255, 100)
color bear_col  = color.rgb(255, 30,  80)
color invisible = color.new(color.white, 100)

// Sub-pane fill color — brightens as divergence gap widens
color div_fill_col = bull_div ? color.new(bull_col, div_transp)
                   : bear_div ? color.new(bear_col, div_transp)
                   : invisible

// Delta bias line opacity — fades toward zero when bias is weak
float delta_abs    = math.abs(delta_bias)
float delta_transp = math.max(0.0, 50.0 - (math.min(delta_abs, 40.0) / 40.0) * 50.0)
color delta_col    = color.new(color.rgb(180, 100, 255), int(delta_transp))

float raw_diff      = delta_bias - price_mom
color hist_col      = raw_diff >= 0 ? color.new(color.green, 20) : color.new(color.red, 20)

// ============================================================================
// OVERLAY BAND CALCULATIONS
// ============================================================================
float tr_pct      = (high - low) / close
float band_basis  = ta.ema(close, band_ema_len)

// --- Bias Band ---
// Outer line offset is proportional to delta bias strength
float bias_norm         = delta_bias / 100.0
float bias_offset       = bias_norm * tr_pct * (show_combined ? 8.0 : 16.0)
float bias_band_line    = band_basis * (1.0 + bias_offset)

// Anchor sits at a fixed ±20% of the bias side
float bias_anchor_norm  = math.sign(delta_bias) * 0.20
float bias_anchor_line  = band_basis * (1.0 + bias_anchor_norm * tr_pct * 8.0)

// Bias band color: magenta (bearish) → lime (bullish)
float bias_t    = (delta_bias / 100.0 + 1.0) / 2.0
int   bias_r    = int(math.round(255.0 + (0.0   - 255.0) * bias_t))
int   bias_g    = int(math.round(0.0   + (255.0 - 0.0)   * bias_t))
int   bias_b    = int(math.round(255.0 + (0.0   - 255.0) * bias_t))

// Fill opacity earned only beyond ±20 bias
float bias_earned = delta_bias >= -20.0 and delta_bias <= 20.0 ? 0.0
                  : delta_bias > 20.0 ? (delta_bias - 20.0) / 80.0
                  : (math.abs(delta_bias) - 20.0) / 80.0

color bias_line_col   = color.new(color.rgb(bias_r, bias_g, bias_b), 0)
color bias_fill_col   = color.new(color.rgb(bias_r, bias_g, bias_b), int((1.0 - bias_earned) * 100.0))
color bias_invis_col  = color.new(color.rgb(bias_r, bias_g, bias_b), 100)

// --- Diff Band ---
// Outer line offset is proportional to the divergence between delta bias and momentum
float diff_val          = delta_bias - price_mom
float diff_norm_clamped = math.max(-1.0, math.min(1.0, diff_val / 100.0))

bool both_positive  = delta_bias >= 0.0 and price_mom >= 0.0
bool both_negative  = delta_bias <  0.0 and price_mom <  0.0
bool same_side      = both_positive or both_negative

// Both_strong: signals agree AND are both beyond ±30 — diff band merges with bias band
bool both_strong    = show_combined and (
     (both_positive and delta_bias > 30.0 and price_mom > 30.0) or
     (both_negative and delta_bias < -30.0 and price_mom < -30.0))

// diff_hidden: same side but weaker/conflicting direction — suppress the fill
bool diff_hidden    = not both_strong and (
     (both_negative and delta_smooth > mom_smooth) or
     (both_positive and mom_smooth > delta_smooth))

float diff_band_line    = diff_hidden ? close
                         : both_strong ? bias_band_line
                         : band_basis * (1.0 + diff_norm_clamped * tr_pct * 8.0)

float diff_anchor_line  = diff_hidden ? close
                         : both_strong ? bias_anchor_line
                         : band_basis * (1.0 + math.sign(diff_val) * 0.20 * tr_pct * 8.0)

// Diff band color: deep orange (momentum leading) → electric blue (delta leading)
float diff_t    = same_side ? 0.5 : (diff_norm_clamped + 1.0) / 2.0
int   diff_r    = int(math.round(255.0 + (0.0   - 255.0) * diff_t))
int   diff_g    = int(math.round(80.0  + (120.0 - 80.0)  * diff_t))
int   diff_b    = int(math.round(0.0   + (255.0 - 0.0)   * diff_t))

float diff_earned = math.abs(diff_val) <= 20.0 ? 0.0
                  : (math.abs(diff_val) - 20.0) / 80.0

color diff_line_col   = both_strong ? bias_line_col  : color.new(color.rgb(diff_r, diff_g, diff_b), 0)
color diff_fill_col   = both_strong ? bias_fill_col
                      : same_side   ? color.new(color.black, 100)
                      : color.new(color.rgb(diff_r, diff_g, diff_b), int((1.0 - diff_earned) * 100.0))
color diff_invis_col  = both_strong ? bias_invis_col : color.new(color.rgb(diff_r, diff_g, diff_b), 100)

// --- Apply Smoothing ---
float final_bias_line   = smooth_overlay ? ta.ema(bias_band_line,  smooth_len) : bias_band_line
float final_bias_anchor = smooth_overlay ? ta.ema(bias_anchor_line, smooth_len) : bias_anchor_line
float final_diff_line   = smooth_overlay ? ta.ema(diff_band_line,   smooth_len) : diff_band_line
float final_diff_anchor = smooth_overlay ? ta.ema(diff_anchor_line, smooth_len) : diff_anchor_line

// ============================================================================
// OVERLAY PLOTS — BIAS BAND
// ============================================================================
bool draw_bias_band = show_overlay and show_bias_band
// In Combined mode the Diff Band line covers the Bias Band line (and inherits its
// color via both_strong), so suppress the Bias Band line to avoid two lines on chart.
bool bias_line_visible = draw_bias_band and show_bias_line and not show_combined

p_bias_line   = plot(bias_line_visible ? final_bias_line   : na,
     "Bias Band",        color=bias_line_col,  linewidth=1, force_overlay=true)
p_bias_anchor = plot(draw_bias_band    ? final_bias_anchor  : na,
     "Bias Anchor",      color=bias_invis_col, linewidth=1, force_overlay=true, display=display.none)

fill(p_bias_line, p_bias_anchor,
     top_value    = delta_bias >= 0 ? final_bias_line   : final_bias_anchor,
     bottom_value = delta_bias >= 0 ? final_bias_anchor : final_bias_line,
     top_color    = delta_bias >= 0 ? (show_bias_fill and draw_bias_band ? bias_fill_col  : bias_invis_col) : bias_invis_col,
     bottom_color = delta_bias >= 0 ? bias_invis_col    : (show_bias_fill and draw_bias_band ? bias_fill_col : bias_invis_col))

// ============================================================================
// OVERLAY PLOTS — DIFF BAND
// ============================================================================
bool draw_diff_band = show_overlay and show_diff_band
bool diff_line_on = draw_diff_band and show_diff_line
bool is_div_mode  = band_mode == "Divergence Band"
bool is_comb_mode = band_mode == "Combined"

p_diff_div  = plot(diff_line_on and is_div_mode  ? final_diff_line : na,
     "Divergence Band", color=diff_line_col,  linewidth=1, force_overlay=true)
p_diff_comb = plot(diff_line_on and is_comb_mode ? final_diff_line : na,
     "Combined Band",   color=diff_line_col,  linewidth=1, force_overlay=true)
p_diff_bias = plot(diff_line_on and not is_div_mode and not is_comb_mode ? final_diff_line : na,
     "Bias Band Line",  color=diff_line_col,  linewidth=1, force_overlay=true)

// Shared invisible anchor — used by all three fills below
p_diff_anchor = plot(draw_diff_band ? final_diff_anchor : na,
     "Band Anchor", color=diff_invis_col, linewidth=1, force_overlay=true, display=display.none)

// Fill for each labeled plot — only the active mode's fill gets color
color fill_top    = show_diff_fill and draw_diff_band ? diff_fill_col : diff_invis_col
color fill_bottom = show_diff_fill and draw_diff_band ? diff_fill_col : diff_invis_col

fill(p_diff_div, p_diff_anchor,
     top_value    = diff_val >= 0 ? final_diff_line : final_diff_anchor,
     bottom_value = diff_val >= 0 ? final_diff_anchor : final_diff_line,
     top_color    = diff_val >= 0 ? (is_div_mode  ? fill_top : diff_invis_col) : diff_invis_col,
     bottom_color = diff_val >= 0 ? diff_invis_col : (is_div_mode  ? fill_bottom : diff_invis_col))

fill(p_diff_comb, p_diff_anchor,
     top_value    = diff_val >= 0 ? final_diff_line : final_diff_anchor,
     bottom_value = diff_val >= 0 ? final_diff_anchor : final_diff_line,
     top_color    = diff_val >= 0 ? (is_comb_mode ? fill_top : diff_invis_col) : diff_invis_col,
     bottom_color = diff_val >= 0 ? diff_invis_col : (is_comb_mode ? fill_bottom : diff_invis_col))

fill(p_diff_bias, p_diff_anchor,
     top_value    = diff_val >= 0 ? final_diff_line : final_diff_anchor,
     bottom_value = diff_val >= 0 ? final_diff_anchor : final_diff_line,
     top_color    = diff_val >= 0 ? (not is_div_mode and not is_comb_mode ? fill_top : diff_invis_col) : diff_invis_col,
     bottom_color = diff_val >= 0 ? diff_invis_col : (not is_div_mode and not is_comb_mode ? fill_bottom : diff_invis_col))

// ============================================================================
// SUB-PANE PLOTS
// ============================================================================
hline(0, "Zero Line", color=color.new(color.gray, 50), linestyle=hline.style_dashed)

p_delta = plot(show_delta_bias ? delta_bias : na,
     "Flow Momentum", color=delta_col,                   linewidth=1)
p_mom   = plot(show_momentum   ? price_mom  : na,
     "Price Momentum", color=color.rgb(255, 200, 50),    linewidth=1)

fill(p_delta, p_mom,
     color = (show_delta_bias and show_momentum and show_series_fill) ? div_fill_col : invisible)

plot(show_diff_hist ? raw_diff : na,
     "Delta vs Momentum Gap", color=hist_col, style=plot.style_histogram, linewidth=1)

// ============================================================================
// BACKGROUND HIGHLIGHT
// ============================================================================
float ramp_range  = math.max(1.0, 100.0 - bg_threshold)
bool  bg_active   = show_bg_highlight and signal_gap > bg_threshold and diverging
float bg_transp   = math.max(70.0, 100.0 - ((signal_gap - bg_threshold) / ramp_range) * 30.0)

color bg_color = bg_active ?
     (bull_div ? color.new(color.lime, int(bg_transp)) :
      bear_div ? color.new(color.red,  int(bg_transp)) :
      invisible) : invisible

bgcolor(show_overlay ? bg_color : invisible, force_overlay=true)
````
