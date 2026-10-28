# Machine Learning: Volume-Weighted Mean Reversion [Dots3Red]

- url: https://www.tradingview.com/script/RWKiQsBq-Machine-Learning-Volume-Weighted-Mean-Reversion-Dots3Red/
- type: indicator
- pine_id: PUB;b1dc8a1108c245d3a7ffd595545d51ce
- version: 1.0

## Description

█ [b]MACHINE LEARNING: VOLUME-WEIGHTED MEARN REVERSION KERNEL REGRESSION[/b]

[b]Nadaraya-Watson kernel regression is a non-parametric machine learning method.[/b] Unlike moving averages which apply fixed, predefined weights to historical bars, kernel regression [i]derives[/i] each bar's weight from a mathematical function — the kernel — that measures how relevant that bar is to the current estimate. No hardcoded coefficients. No assumed shape. The model adapts purely from the data.

[b]This script[/b] introduces a fundamental extension to the standard method: [b]volume as a second weighting dimension[/b]. The result is a regression curve that gravitates toward price levels where real market participation occurred — not toward price levels where a clock happened to tick.

█ [b]WHY KERNEL REGRESSION IS MACHINE LEARNING[/b]
The term machine learning describes algorithms that derive structure from data rather than from manually specified rules. Kernel regression satisfies this definition formally. The estimator computes:
[b]ŷ = Σ [ w(i) × close[i] ] / Σ [ w(i) ][/b][i][/i]
where each weight w(i) is determined by a kernel function — not by the programmer. The model decides, from the data, how much each historical bar should influence the current estimate. This is the same mathematical family as K-Nearest Neighbors, which weights neighbors by proximity. It is cited as a foundational non-parametric ML method in Bishop (2006) and Hastie et al. (2009), and is described as an attention mechanism in deep learning literature — the same concept behind transformer models. The claim is accurate, not cosmetic.


█ [b]THE CORE INNOVATION — VOLUME WEIGHTING[/b]
Every existing Nadaraya-Watson implementation on TradingView uses a pure time kernel:
•  [b]Standard NW:[/b]  w(i) = K(i/h)
This means a bar with 10,000 shares traded and a bar with 10,000,000 shares traded receive [i]identical weight[/i] if they are the same number of bars away. A thin overnight drift and a high-volume institutional session influence the regression equally. That is statistically incorrect — volume is a direct measure of how much informational content a price bar carries.

This script uses a volume-weighted kernel:
•  [b]This script:[/b]  w(i) = vol_norm(i) × K(i/h)
where vol_norm(i) is the bar's volume normalized against the peak volume in the lookback window, raised to a configurable power exponent. The regression estimate is therefore:
[b]ŷ = Σ [ vol_norm(i) × K(i/h) × close[i] ] / Σ [ vol_norm(i) × K(i/h) ][/b][i][/i]

High-volume bars anchor the curve. Low-volume bars — thin sessions, overnight drift, holiday trading — contribute minimally. The regression finds where the market [i]actually agreed[/i] on price, not just where the clock recorded a tick.

█ [b]THREE KERNEL FUNCTIONS[/b]
All three apply the same volume weighting. The choice controls how rapidly influence decays with time distance:
•  [b]Rational Quadratic[/b] (default) — heavier tail than Gaussian. Bars from 40–60 periods ago still contribute meaningfully if they had high volume. Best for daily and weekly charts where old high-volume levels remain structurally relevant.
•  [b]Gaussian[/b] — standard bell curve decay. Weight drops sharply with distance. Best for intraday charts where recency matters more than historical anchors.
•  [b]Epanechnikov[/b] — hard cutoff at the bandwidth boundary. Anything beyond h periods receives zero weight. Produces the most locally sensitive regression. Best for fast charts requiring tight responsiveness.

█ [b]SIGNAL LOGIC[/b]
The envelope bands are placed at a configurable multiple of ATR, standard deviation, or a fixed percentage above and below the regression line. Three band width methods are available to match different volatility contexts.

Two signal modes are available:
•  [b]Reversion mode[/b] (default) — a signal fires when price crosses [i]back through[/i] the band after an extension. The ▲ label appears on the bar where price returns inside the lower band. The ▼ label appears on the bar where price returns inside the upper band. This confirms reversion has begun rather than anticipating it.

•  [b]Extension mode[/b] — enable [i]Signal on extension close[/i] to fire a signal the moment price closes outside a band. This is an early warning — useful for alerts before the reversion bar arrives.
Additional signal filters: minimum bars between signals to prevent repeat firing, optional slope direction gate so signals only fire when the regression slope agrees with the signal direction.

█ [b]WHAT YOU SEE ON THE CHART[/b]
[b]Regression line[/b]
The volume-weighted fair value curve. Cyan when slope is rising, magenta when falling. This is where the model estimates price should be given the recent history of high-participation price levels.

[b]Envelope bands[/b]
Upper and lower boundaries built from ATR, standard deviation, or a fixed percentage. The upper band is tinted red — resistance zone. The lower band is tinted green — support zone.

[b]Bar coloring — 4 states[/b]
•  Bright red — price closed above the upper band. Extended, statistically stretched above fair value.
•  Bright green — price closed below the lower band. Extended, statistically stretched below fair value.
•  Dim silver — price inside bands, regression rising or falling, i.e normal bullish or bearish context.

The contrast between fully saturated outside-band bars and dimmed inside-band bars makes overextension immediately visible without reading the scale.

[b]Signal labels[/b]
▲ REVERT or ▼ REVERT with VW=XX% showing the volume weight of the signal bar. A signal at VW=85% fired on a high-participation bar. A signal at VW=9% fired on a thin bar — lower confidence.

[b]Signal bar highlighting[/b]
Two additional layers available: a background flash on the signal bar and a thick vertical line through the bar's full range. Both are independently toggleable. The vertical line uses width=4 — the maximum Pine Script allows — making the signal bar visually distinct even when zoomed out.

[b]Dashboard[/b]
Displays: current regression value, slope direction, band width, Bar Vol Weight meter (▰▰▰▱▱▱) showing how much influence the current bar has on the regression, active kernel type, volume weighting status, percentage distance from the regression midline, and non-repainting mode status.


█ [b]NON-REPAINTING[/b]
When [i]Non-Repainting Mode[/i] is enabled (default), all calculations use a [1] bar offset. The current bar's close does not enter its own regression estimate. Historical signals visible on closed bars will not change as new bars form. Disable this to see a predictive (repainting) version where the current bar participates in its own estimate — useful for visual exploration but not recommended for backtesting or alerts.


█ [b]HOW TO USE[/b]
[b]Core use case — mean reversion[/b]
This is a mean reversion tool. It works best when price is oscillating rather than trending directionally. The recommended workflow:
1 — Confirm a ranging regime with a separate regime classifier before acting on signals.
2 — Wait for price to reach or pierce the upper or lower band (bars turn bright red or green).
3 — Check the VW% in the signal label. Higher volume weight on the signal bar = higher confidence.
4 — Enter on the reversion signal (▲ or ▼ label). Stop beyond the wick of the signal bar.
5 — Target the regression midline as the primary exit. The [i]% from mid[/i] dashboard row tracks progress in real time.

[image]https://www.tradingview.com/x/vhtAvvsq/[/image]

[b]Timeframe guidance[/b]
The volume-weighting advantage increases with timeframe because higher timeframes produce more meaningful volume data per bar. H4 and Daily are the strongest timeframes for this tool. For intraday use, reduce the [i]Volume Weight Power[/i] to 0.3–0.5 to soften the impact of individual volume spikes.

[b]Quick-start settings by asset class[/b]
•  Stocks daily: Window=100, Bandwidth=8, Vol Power=1.0, ATR×2.0
•  Crypto daily: Window=80, Bandwidth=6, Vol Power=0.7, ATR×1.8
•  Forex H4: Window=100, Bandwidth=10, Vol Power=1.0, ATR×1.5
•  Indices H1: Window=120, Bandwidth=12, Vol Power=0.8, Stdev×2.0


█ [b]SETTINGS REFERENCE[/b]

[b]Kernel Settings[/b]
•  [i]Lookback Window[/i] — number of historical bars in the regression. Larger = smoother, more lag.
•  [i]Bandwidth (h)[/i] — controls how fast kernel weight decays with time. Higher = older bars still contribute.
•  [i]Kernel Type[/i] — Gaussian / Rational Quadratic / Epanechnikov. See kernel section above.
•  [i]RQ Alpha (α)[/i] — Rational Quadratic only. Lower = smoother mixture of length scales.
•  [i]Non-Repainting Mode[/i] — uses [1] offset. Recommended ON for backtesting.

[b]Volume Weighting[/b]
•  [i]Enable Volume Weighting[/i] — toggle the core innovation on or off. OFF = standard NW.
•  [i]Volume Normalization Window[/i] — peak volume reference window. Match or exceed the lookback window.
•  [i]Volume Weight Power[/i] — exponent on the volume weight. 1.0 = linear. 2.0 = quadratic. 0.5 = softer.
•  [i]Volume Weight Floor[/i] — minimum weight for any bar. Prevents zero-volume bars from being ignored entirely.

[b]Envelope Bands[/b]
•  [i]Band Width Method[/i] — ATR (volatility-adaptive), Stdev (statistical), or Percent (fixed).
•  [i]ATR Length[/i] — period for ATR calculation.
•  [i]ATR / Stdev Mult[/i] — multiplier applied to ATR or standard deviation.
•  [i]Percent Offset %[/i] — used when Percent method is selected.

[b]Signals[/b]
•  [i]Signal on band crossover[/i] — enable signals on band cross events.
•  [i]Signal on extension close[/i] — fire signal when price closes outside a band (early warning mode).
•  [i]Require slope change[/i] — only signal when regression slope direction agrees.
•  [i]Min bars between signals[/i] — gap guard to prevent repeat signals.

[b]Visuals[/b]
•  [i]Dashboard[/i] — regression stats and live metrics table.
•  [i]Signal labels[/i] — ▲/▼ REVERT labels with volume weight percentage.
•  [i]Band fill[/i] — fill between upper and lower bands.
•  [i]Background flash[/i] — bright background color on signal bars.
•  [i]Vertical line on signal bar[/i] — thick line through full bar height at signal.
•  [i]Large dot marker[/i] — additional plotchar layer on signal bars.
•  [i]Dashboard position[/i] — Top Right / Top Left / Bottom Right / Bottom Left.


█ [b]ALERTS[/b]
Seven alert conditions are available:
•  Long signal — reversion through lower band
•  Short signal — reversion through upper band
•  Any signal — either direction
•  Extended below lower band — early warning before reversion fires
•  Extended above upper band — early warning before reversion fires
•  Regression slope turned bullish
•  Regression slope turned bearish

█ [b]DISCLAIMER[/b]
This indicator is a decision-support tool. It does not constitute financial advice and does not guarantee future results. Past statistical patterns do not predict future price behavior. Always use proper risk management.

Method: Nadaraya-Watson Kernel Regression (Non-Parametric ML)
Innovation: Volume × Time Kernel Weighting
Kernels: Gaussian · Rational Quadratic · Epanechnikov
Signals: Mean Reversion (band crossover or extension)
Repainting: Configurable — non-repainting mode available

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Dots3Red
// TradingView: https://www.tradingview.com/u/Dots3Red/

//@version=6
indicator("Machine Learning: Volume-Weighted Mean Reversion Kernel [Dots3Red]",
          overlay=true, max_bars_back=1000,  max_labels_count=50, max_lines_count=10)

// CONCEPT BEHIND
// ═══════════════════════════════════════════════════════════════════════
// Standard Nadaraya-Watson kernel regression weights each historical bar
// purely by its TIME distance from the current bar:
//
//   w(i) = K(i/h)          ← pure time kernel
//
// This means a bar with 10K volume and a bar with 10M volume receive
// identical weight if they are the same number of bars away.
//
// This script replaces that with a VOLUME-WEIGHTED kernel:
//
//   w(i) = vol_norm(i) × K(i/h)    ← volume × time kernel
//
// where vol_norm(i) is the normalized volume of bar[i] relative to the
// peak volume over the lookback window. High-volume bars anchor the
// regression. Low-volume drift (thin overnight moves, holiday sessions)
// has minimal influence.
//
// The regression estimate is therefore:
//
//   ŷ = Σ [ vol_norm(i) × K(i/h) × close[i] ]
//       ─────────────────────────────────────────
//       Σ [ vol_norm(i) × K(i/h) ]
//
// Three kernels available:
//   Gaussian:           K = exp(-(i/h)²)
//   Rational Quadratic: K = (1 + i²/(2αh²))^(-α)    ← default, heavier tail
//   Epanechnikov:       K = max(0, 1 - (i/h)²)       ← compact support
//
// Non-repainting: all computations use [1] offset — the current bar does
// not influence its own estimate.
// ═══════════════════════════════════════════════════════════════════════


// COLORS
C_UP        = color.new(#00ff66, 0)   
C_DOWN      = color.new(#ff0044, 0)  
C_BULL      = color.new(#00ff66, 0)   
C_BEAR      = color.new(#ff0044, 0)  
C_NEUTRAL   = color.new(#475569, 0)   

// Band fills 
C_BAND_U    = color.new(#00ff66, 92)  
C_BAND_D    = color.new(#ff00aa, 92)  

C_BAR_ABOVE = color.new(#ff0044, 0)   
C_BAR_BELOW = color.new(#00ff66, 0)  

C_BAR_UP    = color.new(#94a3b8, 35)  
C_BAR_DOWN  = color.new(#475569, 40)  

C_TXT       = color.new(#f8fafc, 0)
C_DIM       = color.new(#64748b, 0)
C_BORD      = color.new(#334155, 0)
C_BG        = #131722

//BG coloring
bgcolor(C_BG)


// INPUTS
GRP_KER = "🌊 Kernel Settings"
GRP_VOL = "📊 Volume Weighting"
GRP_BAND= "📐 Envelope Bands"
GRP_SIG = "🚦 Signals"
GRP_VIS = "🎨 Visuals"

// Kernel
win_size    = input.int   (100,  "Lookback Window",        minval=10,  maxval=500,  group=GRP_KER,
              tooltip="Number of historical bars used in the regression. Larger = smoother, more lag.")
bandwidth   = input.float (8.0,  "Bandwidth (h)",          minval=0.5, maxval=50.0, step=0.5, group=GRP_KER,
              tooltip="Controls how quickly kernel weight decays with time distance. Higher = broader influence of distant bars.")
kernel_type = input.string("Rational Quadratic", "Kernel Type",
              options=["Gaussian","Rational Quadratic","Epanechnikov"], group=GRP_KER,
              tooltip="Gaussian: standard bell curve. Rational Quadratic: heavier tail — older high-volume bars still contribute. Epanechnikov: hard cutoff at bandwidth edge.")
rq_alpha    = input.float (1.0,  "RQ Alpha (α)",           minval=0.1, maxval=10.0, step=0.1, group=GRP_KER,
              tooltip="Rational Quadratic only. Controls mixture of length scales. Lower = smoother. Higher = more local.")
non_repaint = input.bool  (true, "Non-Repainting Mode",    group=GRP_KER,
              tooltip="When enabled uses [1] bar offset — current bar does not influence its own estimate. Recommended ON for backtesting.")

// Volume
use_vol_weight  = input.bool  (true,  "Enable Volume Weighting",  group=GRP_VOL,
                  tooltip="The core innovation. When ON bars with higher volume have more influence on the regression estimate.")
vol_norm_window = input.int   (100,   "Volume Normalization Window", minval=10, maxval=500, group=GRP_VOL,
                  tooltip="Peak volume reference window for normalization. Should match or exceed the Lookback Window.")
vol_power       = input.float (1.0,   "Volume Weight Power",        minval=0.1, maxval=3.0, step=0.1, group=GRP_VOL,
                  tooltip="Exponent on volume weight. 1.0 = linear. 2.0 = quadratic (high-volume bars dominate even more). 0.5 = square root (softer weighting).")
vol_floor       = input.float (0.05,  "Volume Weight Floor",        minval=0.0, maxval=0.5, step=0.01, group=GRP_VOL,
                  tooltip="Minimum weight for any bar even if volume was zero. Prevents complete exclusion of low-volume bars.")

// Bands
band_src    = input.string("ATR",    "Band Width Method",  options=["ATR","Stdev","Percent"], group=GRP_BAND,
              tooltip="ATR: volatility-adaptive bands. Stdev: statistical dispersion. Percent: fixed % offset above/below regression.")
atr_len     = input.int   (14,      "ATR Length",          minval=1,  group=GRP_BAND)
atr_mult    = input.float (2.0,     "ATR / Stdev Mult",    minval=0.1, maxval=6.0, step=0.1, group=GRP_BAND)
pct_offset  = input.float (2.0,     "Percent Offset %",    minval=0.1, maxval=20.0, step=0.1, group=GRP_BAND)

// Signals
sig_crossband   = input.bool  (true,  "Signal on band crossover",   group=GRP_SIG,
                  tooltip="Generate signal when price crosses back through upper or lower band.")
require_close   = input.bool  (false, "Signal on extension close",  group=GRP_SIG,
                  tooltip="When ON: signal fires the moment price closes OUTSIDE a band (early warning). When OFF: signal fires when price crosses back INSIDE the band (reversion confirmation). Default OFF is safer.")
sig_slope_chg   = input.bool  (false,  "Require slope change",       group=GRP_SIG,
                  tooltip="Only signal when regression slope changes direction — filters out signals mid-trend.")
sig_gap         = input.int   (5,     "Min bars between signals",    minval=1, maxval=50, group=GRP_SIG)

// Visuals
show_dash       = input.bool  (true,  "Dashboard",                    group=GRP_VIS)
show_sig_labels = input.bool  (true,  "Signal labels",                group=GRP_VIS)
show_fill       = input.bool  (true,  "Band fill",                    group=GRP_VIS)
show_bg_flash   = input.bool  (true,  "Background flash on signal",   group=GRP_VIS, tooltip="Flashes a bright background color on the signal bar — most visible highlight.")
show_sig_line   = input.bool  (true,  "Vertical line on signal bar",  group=GRP_VIS, tooltip="Draws a solid vertical line through the full signal bar from low to high.")
show_sig_char   = input.bool  (false, "Large dot marker on signal",   group=GRP_VIS, tooltip="Plots a large dot character as a second visual layer on the signal bar.")
dash_pos        = input.string("Top Right", "Dashboard position",
                  options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=GRP_VIS)


// VOLUME NORMALIZATION (look-ahead free — uses [1] offset on peak)
// Normalized to [floor, 1] range over the vol_norm_window
vol_peak   = ta.highest(volume[1], vol_norm_window)
vol_norm_raw = volume[1] / math.max(vol_peak, 1.0)
// Apply power and floor
f_vol_w(i) =>
    raw = volume[i] / math.max(ta.highest(volume, vol_norm_window), 1.0)
    w   = math.max(math.pow(raw, vol_power), vol_floor)
    use_vol_weight ? w : 1.0


// KERNEL FUNCTIONS
f_kernel(i, h) =>
    t = i / h
    switch kernel_type
        "Gaussian"           => math.exp(-(t * t))
        "Rational Quadratic" => math.pow(1.0 + (i * i) / (2.0 * rq_alpha * h * h), -rq_alpha)
        "Epanechnikov"       => math.max(0.0, 1.0 - t * t)
        =>                     math.exp(-(t * t))


// ───────────────────────────────────────────────────────────────────────
// VOLUME-WEIGHTED NADARAYA-WATSON REGRESSION
// ───────────────────────────────────────────────────────────────────────
// ŷ = Σ[w(i) × close[i]] / Σ[w(i)]
// where w(i) = vol_norm(i) × K(i/h)
//
// Offset: when non_repaint=true, we start from bar[1] so the current bar
// does not see its own close in the weighted sum.
// ───────────────────────────────────────────────────────────────────────
f_nw_estimate(offset) =>
    float num = 0.0
    float den = 0.0
    for i = offset to win_size - 1 + offset
        float k  = f_kernel(i - offset, bandwidth)
        float vw = f_vol_w(i)
        float w  = k * vw
        num     += w * close[i]
        den     += w
    den > 0.0 ? num / den : close[offset]

offset_val  = non_repaint ? 1 : 0
nw_estimate = f_nw_estimate(offset_val)

// Previous bar's estimate for slope detection
nw_prev     = f_nw_estimate(offset_val + 1)
nw_slope_up = nw_estimate > nw_prev


// ───────────────────────────────────────────────────────────────────────
// ENVELOPE BANDS
// ───────────────────────────────────────────────────────────────────────
atr_val  = ta.atr(atr_len)
bb_std   = ta.stdev(close[offset_val], win_size)

band_half = switch band_src
    "ATR"     => atr_mult * atr_val
    "Stdev"   => atr_mult * bb_std
    "Percent" => nw_estimate * pct_offset / 100.0
    =>           atr_mult * atr_val

upper = nw_estimate + band_half
lower = nw_estimate - band_half


// ───────────────────────────────────────────────────────────────────────
// SIGNAL GENERATION
// ───────────────────────────────────────────────────────────────────────
// TWO signal modes:
//
// Mode A — CROSSOVER (default, require_close = false):
//   Long  fires when close crosses BACK UP through the lower band.
//   Short fires when close crosses BACK DOWN through the upper band.
//   This means the label appears on the reversion bar, not the
//   extension bar. Price must first go BELOW lower (bar colors cyan),
//   then the NEXT bar that closes back above lower gets the ▲ label.
//
// Mode B — OUTSIDE BAND (require_close = true used as "fire immediately"):
//   This mode fires the moment price closes OUTSIDE the band,
//   flagging the extension itself rather than the reversion.
//   Useful for alerting before the reversion rather than on it.
//
// IMPORTANT: if you see price outside the band but no label,
//   you are looking at the EXTENSION bars. The label fires on the
//   REVERSION bar (when close comes back through the band).
//   Bar color tells you the state: bright cyan = extended below lower,
//   bright magenta = extended above upper.

// --- State: is price currently outside a band? ---
bool price_above_upper = close > upper
bool price_below_lower = close < lower

// --- Crossover / crossunder signals (reversion confirmation) ---
bool cross_back_up   = ta.crossover (close, lower)   
bool cross_back_down = ta.crossunder(close, upper)   

// --- require_close wired: when ON, fire on the extension close itself ---
// When OFF (default): fire on the reversion crossover (safer, less lag concern)
bool raw_long  = require_close ? price_below_lower :
                 (cross_back_up   and (not sig_slope_chg or nw_slope_up))
bool raw_short = require_close ? price_above_upper :
                 (cross_back_down and (not sig_slope_chg or not nw_slope_up))

var int last_sig_bar = na
bool can_signal = na(last_sig_bar) or (bar_index - last_sig_bar >= sig_gap)

var int last_dir = 0
bool sig_long  = false
bool sig_short = false

if sig_crossband
    if raw_long and can_signal and last_dir <= 0
        sig_long     := true
        last_dir     := 1
        last_sig_bar := bar_index
    if raw_short and can_signal and last_dir >= 0
        sig_short    := true
        last_dir     := -1
        last_sig_bar := bar_index

// Reset direction when price returns fully inside the bands
if close < upper and close > lower
    if last_dir == 1 and not price_below_lower
        last_dir := 0
    if last_dir == -1 and not price_above_upper
        last_dir := 0


// CURRENT BAR VOLUME WEIGHT (for dashboard)
// How much does this bar contribute to the regression?
cur_vol_weight = f_vol_w(offset_val)

// VISUALIZATION
reg_color = nw_slope_up ? C_UP : C_DOWN
reg_color:=color.new(reg_color, 27)

// Regression line
plot(nw_estimate, "NW Regression",
     color    = reg_color,
     linewidth = 2)

// Upper band
p_upper = plot(upper, "Upper Band",
               color    = color.new(C_BEAR, 40),
               linewidth = 1)

// Lower band
p_lower = plot(lower, "Lower Band",
               color    = color.new(C_BULL, 40),
               linewidth = 1)

// Band fill
fill(p_upper, p_lower, color = show_fill ? (nw_slope_up ? C_BAND_U : C_BAND_D) : na)

// ── Reversion signal triangles ──
// plotshape(sig_long,  "Long Signal",
//           shape.triangleup,   location.belowbar,
//           C_BULL, size=size.small)
// plotshape(sig_short, "Short Signal",
//           shape.triangledown, location.abovebar,
//           C_BEAR, size=size.small)

// ── Signal labels with volume weight context ──
if show_sig_labels and sig_long
    float lbl_y = math.min(low, lower) - atr_val * 5.5
    label.new(bar_index, lbl_y,
              "▲\nREVERT\nVW=" + str.tostring(math.round(cur_vol_weight * 100)) + "%",
              style         = label.style_label_down,
              color         = C_BG,
              textcolor     = color.new(C_BULL, 25),
              size          = size.small,
              force_overlay = true)

if show_sig_labels and sig_short
    float lbl_y = math.max(high, upper) + atr_val * 1.5
    label.new(bar_index, lbl_y,
              "REVERT\nVW=" + str.tostring(math.round(cur_vol_weight * 100)) + "% \n▼",
              style         = label.style_label_down,
              color         = C_BG,
              textcolor     = C_BEAR,
              size          = size.small,
              force_overlay = true)

// ── Bar coloring — regime context 
barcolor(close > upper ? C_BAR_ABOVE :   
         close < lower ? C_BAR_BELOW :   
         nw_slope_up   ? C_BAR_UP    :   
                         C_BAR_DOWN)     

// ── Signal bar highlighting 
// Layer 1: Background flash
bgcolor(show_bg_flash and sig_long  ? color.new(C_BULL, 82) : na, title="Long flash")
bgcolor(show_bg_flash and sig_short ? color.new(C_BEAR, 82) : na, title="Short flash")

if show_sig_line and sig_long
    line.new(bar_index, low  - atr_val * 0.1,
             bar_index, high + atr_val * 0.1,
             xloc=xloc.bar_index,
             color=C_BULL, width=3, style=line.style_solid,
             force_overlay=true)

if show_sig_line and sig_short
    line.new(bar_index, low  - atr_val * 0.1,
             bar_index, high + atr_val * 0.1,
             xloc=xloc.bar_index,
             color=C_BEAR, width=3, style=line.style_solid,
             force_overlay=true)

// DASHBOARD
prob_bar(p) =>
    n = math.round(p * 10)
    str.repeat("▰", math.max(0, n)) + str.repeat("▱", math.max(0, 10 - n))

if show_dash and barstate.islast
    tp = switch dash_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        =>                position.bottom_left

    var table t = table.new(tp, 2, 10,
                  bgcolor      = color.new(#0f172a, 10),
                  border_color = C_BORD, border_width = 2,
                  frame_color  = C_BORD, frame_width  = 2)

    // Row 0 — header
    table.cell(t, 0, 0, "NW VOLUME-WEIGHTED",
               text_color=C_TXT, bgcolor=color.new(#1e293b, 0),
               text_size=size.small, text_halign=text.align_center)
    table.merge_cells(t, 0, 0, 1, 0)

    // Row 1 — regression value
    table.cell(t, 0, 1, "Regression",
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 1, str.tostring(math.round(nw_estimate, 2)),
               text_color=reg_color, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_center)

    // Row 2 — slope
    table.cell(t, 0, 2, "Slope",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 2, nw_slope_up ? "▲ Rising" : "▼ Falling",
               text_color=reg_color, bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_center)

    // Row 3 — band width
    table.cell(t, 0, 3, "Band Width",
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 3, str.tostring(math.round(band_half * 2, 2)),
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_center)

    // Row 4 — current bar volume weight
    table.cell(t, 0, 4, "Bar Vol Weight",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 4, prob_bar(cur_vol_weight) + " " + str.tostring(math.round(cur_vol_weight * 100)) + "%",
               text_color=cur_vol_weight > 0.6 ? C_UP : cur_vol_weight < 0.2 ? C_DOWN : C_DIM,
               bgcolor=color.new(#0f172a, 20),
               text_size=size.tiny, text_halign=text.align_left)

    // Row 5 — kernel type
    table.cell(t, 0, 5, "Kernel",
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 5, kernel_type,
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_center)

    // Row 6 — vol weighting on/off
    table.cell(t, 0, 6, "Vol Weighting",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 6, use_vol_weight ? "ON" : "OFF",
               text_color=use_vol_weight ? C_UP : C_NEUTRAL,
               bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_center)

    // Row 7 — divider
    table.cell(t, 0, 7, "─── Position ───",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 0),
               text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(t, 0, 7, 1, 7)

    // Row 8 — price vs bands
    float pct_from_mid = (close - nw_estimate) / math.max(band_half, 1e-9) * 100
    table.cell(t, 0, 8, "% from mid",
               text_color=C_DIM, bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 8, str.tostring(math.round(pct_from_mid, 1)) + "%",
               text_color=pct_from_mid > 80 ? C_BEAR : pct_from_mid < -80 ? C_BULL : C_DIM,
               bgcolor=color.new(#1e293b, 20),
               text_size=size.small, text_halign=text.align_center)

    // Row 9 — non-repaint mode
    table.cell(t, 0, 9, "Non-Repaint",
               text_color=C_DIM, bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 9, non_repaint ? "ON ✓" : "OFF (predictive)",
               text_color=non_repaint ? C_UP : color.new(#fbbf24, 0),
               bgcolor=color.new(#0f172a, 20),
               text_size=size.small, text_halign=text.align_center)



// ALERTS
alertcondition(sig_long,           "NW-VW Long",         "NW Volume-Weighted: Long signal — price reverted through lower band")
alertcondition(sig_short,          "NW-VW Short",        "NW Volume-Weighted: Short signal — price reverted through upper band")
alertcondition(sig_long or sig_short, "NW-VW Any",       "NW Volume-Weighted: Signal fired")
alertcondition(price_below_lower,  "NW-VW Extended Low", "NW Volume-Weighted: Price extended BELOW lower band — watch for reversion")
alertcondition(price_above_upper,  "NW-VW Extended High","NW Volume-Weighted: Price extended ABOVE upper band — watch for reversion")
alertcondition(nw_slope_up and not nw_slope_up[1],   "NW-VW Slope → Up",   "NW Volume-Weighted: Regression slope turned bullish")
alertcondition(not nw_slope_up and nw_slope_up[1],   "NW-VW Slope → Down", "NW Volume-Weighted: Regression slope turned bearish")
````
