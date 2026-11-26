# Tidal Volume Oscillator [JOAT]

- url: https://www.tradingview.com/script/F9wbW2sl-Tidal-Volume-Oscillator-JOAT/
- type: indicator
- pine_id: PUB;4f789e3c0f4e4bca8e7902a5a77e4da0
- version: 1.0

## Description

[b]Tidal Volume Oscillator [JOAT][/b]

[b]Introduction[/b]

The Tidal Volume Oscillator is a separate-pane oscillator that attempts to answer a single question: is the current price movement being carried by genuine volume participation, or is it occurring on weak flow? It constructs a volume-weighted momentum score, normalizes it to a bounded range of −100 to +100, applies a Fourier-inspired exponential decay smoothing pass to reduce noise without introducing phase lag, and then scales the result with an adaptive trend filter. A flow momentum line tracks the acceleration of the oscillator itself. A divergence engine scans for all four divergence types simultaneously — regular bullish, regular bearish, hidden bullish, and hidden bearish — and plots them directly in the oscillator panel.

The indicator does not predict future price. It contextualizes current price movement relative to volume behavior and flags when price action and volume-weighted momentum are moving in opposite directions, which historically precedes changes in directional character — though not always, and not reliably in all instruments or conditions.

---
[image]https://www.tradingview.com/x/6RTl5gUa/[/image]
[b]Core Concepts[/b]

[b]The VZO Foundation[/b]

The Volume Zone Oscillator (VZO) is an established concept that categorizes volume as positive or negative based on the direction of price change, then computes a ratio of positive to negative volume over a rolling window. This indicator rebuilds that concept from the ground up using a different normalization approach:

[list]
[*][b]Relative Volume:[/b] Instead of using raw volume, the oscillator first normalizes each bar's volume against a rolling SMA of volume. This produces a relative volume reading — a value above 1.0 means the bar traded heavier than average, below 1.0 means lighter. This step removes the absolute scale of volume from the calculation, allowing the oscillator to behave comparably across instruments with vastly different volume profiles and across timeframes where absolute volume differs by orders of magnitude.
[*][b]Volume-Weighted Momentum:[/b] The price change on each bar is smoothed via EMA, and the relative volume is separately smoothed via EMA. Multiplying these two smoothed values produces a volume-weighted momentum signal. This is then smoothed again to form a base momentum reading.
[*][b]RSI-Style Normalization:[/b] Positive and negative portions of the base momentum are separated, each independently smoothed, and their ratio is fed into an RSI-style formula: [pine]vzo = 100 * (ratio - 1) / (ratio + 1)[/pine]. This bounds the oscillator strictly between −100 and +100 and gives it a symmetric zero-line structure where positive values indicate dominant upward volume momentum and negative values indicate dominant downward volume momentum.
[/list]

[b]Fourier Exponential Decay Smoothing[/b]

After the initial VZO is computed, a second smoothing pass is applied using exponential decay weights. For each bar, the contribution of each of the prior N bars is weighted by [pine]exp(-i / (len * 0.3))[/pine], where [pine]i[/pine] is the number of bars back. This means the most recent bar carries maximum weight and each earlier bar contributes exponentially less. The window clips naturally as the weights approach zero.

The result is a smoothing pass that is inspired by frequency-domain thinking: it emphasizes recent values and de-emphasizes older values in a continuous decay rather than in the binary on/off fashion of a simple rolling average. The smoothed output tracks the oscillator's underlying shape while suppressing high-frequency noise without the phase shift that a centered moving average would introduce.

[b]ADF Trend Filter[/b]

An adaptive multiplier is derived by comparing a short SMA and a long SMA of price, normalizing their difference by the rolling standard deviation of price over a matching window. This produces a dimensionless value that reflects the strength of the current trend relative to recent volatility — conceptually analogous to the logic behind an Augmented Dickey-Fuller trend test applied in a simplified real-time form.

This multiplier is kept close to 1.0 intentionally. Its role is not to dramatically change the oscillator's value but to apply a mild scaling that slightly amplifies the VZO when trend conditions are strong and slightly suppresses it during choppy, mean-reverting conditions. The effect is subtle but helps the oscillator's readings align better with the underlying market character.

[b]Final Blended VZO[/b]

The final oscillator value blends the EMA-smoothed VZO and the Fourier-smoothed VZO according to a blend parameter, scales the result by the ADF multiplier, and clamps the output to the [−100, +100] range. The blend parameter controls how much weight goes to the Fourier-smoothed version versus the EMA-smoothed version, allowing the user to tune between responsiveness and smoothness.

[b]Flow Momentum Line[/b]

A secondary line is plotted alongside the main oscillator, computed as:

[pine]flow_momentum = (vzo - ema(vzo, lookback)) * 0.5[/pine]

This measures the rate of change of the oscillator — its acceleration — and scales it to stay visually proportional. When the flow momentum line is rising, the oscillator is accelerating upward. When it is falling, the oscillator is losing momentum regardless of its absolute level. Crossovers between the oscillator and the flow momentum line can highlight inflection points in volume-weighted momentum.

[b]Divergence Engine[/b]

The divergence engine uses pivot high and pivot low detection to identify four divergence types:

[list]
[*][b]Regular Bullish Divergence:[/b] Price makes a lower low while the oscillator makes a higher low. Suggests weakening downward volume participation on the new price low.
[*][b]Regular Bearish Divergence:[/b] Price makes a higher high while the oscillator makes a lower high. Suggests weakening upward volume participation on the new price high.
[*][b]Hidden Bullish Divergence:[/b] Price makes a higher low while the oscillator makes a lower low. Often associated with pullbacks within an established uptrend where volume momentum remains stronger than the pullback's depth implies.
[*][b]Hidden Bearish Divergence:[/b] Price makes a lower high while the oscillator makes a higher high. Often associated with rallies within an established downtrend where volume momentum is failing to confirm the price bounce.
[/list]

The engine uses [pine]ta.valuewhen[/pine] to retrieve the oscillator's value at the most recent prior pivot of the same type, then compares it to the current pivot. Lines and labels are drawn directly in the oscillator pane, keeping all divergence context in a single panel.

[b]Dynamic Color Blending[/b]

The oscillator line and histogram (if enabled) use color blending that responds to both the direction of the oscillator and the intensity of the flow momentum. Colors transition smoothly between bull and bear palettes as conditions shift, with intensity modulated by momentum acceleration. This avoids binary color flips and gives a continuous visual read of the oscillator's strength and direction.

---

[b]Features[/b]

[list]
[*]Relative-volume-normalized VZO foundation — removes absolute volume scale bias
[*]RSI-style normalization producing a symmetric −100 to +100 oscillator
[*]Fourier exponential decay smoothing pass for noise reduction without phase lag
[*]ADF-inspired adaptive trend multiplier for regime-sensitive scaling
[*]Blended output combining EMA and Fourier smoothing with user-adjustable weighting
[*]Flow momentum line showing oscillator acceleration
[*]Full four-type divergence engine: regular bull/bear and hidden bull/bear
[*]Divergence lines and labels rendered directly in the oscillator pane
[*]Dynamic color blending based on direction and momentum intensity
[*]Overbought/oversold level lines at user-defined thresholds (default ±80)
[*]Fully toggleable visual components including divergence types individually
[/list]

---

[b]Input Parameters[/b]

[list]
[*][b]VZO Length:[/b] Primary lookback for the volume-weighted momentum and normalization calculations (default: 14)
[*][b]Smoothing Length:[/b] Short EMA length used in the initial volume-weighted momentum construction (default: 5)
[*][b]Signal Length:[/b] EMA length applied to the final VZO for the signal/flow line (default: 9)
[*][b]Fourier Window:[/b] Number of bars used in the exponential decay smoothing pass (default: 20)
[*][b]Fourier Blend:[/b] Proportion of the final output taken from the Fourier-smoothed VZO versus the EMA-smoothed VZO (default: 0.4, meaning 40% Fourier / 60% EMA)
[*][b]Overbought Level:[/b] Upper reference line threshold (default: +80)
[*][b]Oversold Level:[/b] Lower reference line threshold (default: −80)
[*][b]Pivot Bars:[/b] Number of bars on each side required to confirm a pivot high or low for divergence detection
[*][b]Visual Toggles:[/b] Individual controls for divergence types (regular bull, regular bear, hidden bull, hidden bear), flow momentum line, bar coloring, and OB/OS lines
[/list]

---

[b]How to Use[/b]

[b]Reading the oscillator:[/b] Values above zero indicate that volume-weighted momentum favors buyers over the lookback window. Values below zero indicate it favors sellers. The magnitude reflects how dominant one side is. A reading of +60 is meaningfully different from +20 — the former suggests strong participation on the upside, the latter suggests modest positive lean.

[b]Overbought/oversold levels:[/b] The default ±80 levels are deliberately set wide. Reaching ±80 indicates a statistically strong skew in volume momentum, not simply a directional bias. A reading at +85 that begins to decline is worth noting; a reading that has been above +80 for many bars without declining suggests strong persistent flow, not an automatic reversal condition.

[b]Flow momentum line:[/b] Use the flow momentum line to identify when the oscillator is accelerating or decelerating. If the oscillator is above zero but the flow momentum line is falling and crossing below the oscillator, volume-weighted momentum is losing strength even if it has not crossed zero. This can be an early warning of a fading move.

[b]Divergences:[/b] Divergence signals appear as labeled lines in the oscillator pane. They flag a disagreement between price structure and volume momentum structure. Regular divergences are typically associated with potential trend reversal conditions; hidden divergences are typically associated with trend continuation conditions during a pullback. Neither type is a standalone entry signal — they require context from price structure, higher timeframe trend, and other confirmation.

[b]Combining types:[/b] A regular bearish divergence occurring while the oscillator is above +60 and the flow momentum line is declining is a more compelling condition than a divergence occurring at a neutral oscillator reading. Look for confluence between divergence signals, oscillator level, and flow momentum direction.

[b]Timeframe notes:[/b] On lower timeframes, the divergence engine will fire frequently and many signals will resolve as noise. On higher timeframes, divergence signals are structurally more significant but rarer. The Fourier blend and VZO length should be calibrated to the timeframe being traded.

---

[b]Limitations[/b]

[list]
[*]This indicator does not predict future price movement. All readings are computed from past and current bar data.
[*]Volume data quality varies significantly across instruments and data providers. On instruments with unreliable, synthetic, or missing volume data (some forex pairs, certain CFDs, spread-betting instruments), the oscillator's readings will be distorted or meaningless.
[*]Divergences are detected only at confirmed pivot points, which by definition require a lookback into past bars. A divergence signal will appear after the pivot is confirmed, not at the pivot bar itself. This is inherent to pivot-based divergence detection and is not a bug.
[*]Hidden divergences can occur frequently during strong trends and produce many signals that resolve without follow-through on shorter timeframes.
[*]The ADF-inspired filter is a simplified heuristic, not a formal statistical test. It does not guarantee that the adaptive scaling accurately reflects whether a market is trending or mean-reverting at any given moment.
[*]The Fourier exponential decay smoothing is not a formal frequency-domain Fourier transform. The term is used descriptively to indicate the exponential weighting pattern, not to imply that the calculation resolves into sinusoidal components.
[*]Extreme or sustained overbought/oversold readings do not guarantee a reversal. Strong trends can keep the oscillator pinned at extremes for extended periods.
[*]The oscillator is bounded at ±100 by construction. This means that at extreme readings, additional strengthening of volume momentum does not move the line further — the clamping obscures incremental changes at extremes.
[*]Past divergence performance on a given instrument is not indicative of future performance.
[/list]

---

[b]Originality Statement[/b]

The VZO concept is established in the public domain. This implementation departs from the standard in several meaningful ways. Using relative volume (each bar's volume divided by a rolling SMA of volume) rather than raw volume removes the absolute scale of volume from the oscillator's behavior — a standard VZO applied to a futures contract and a low-float equity will behave differently purely due to volume magnitude; this version will not. The RSI-style normalization of the volume-weighted momentum ratio is retained from the VZO concept but is applied to a momentum signal constructed differently from the standard signed-volume approach. The Fourier exponential decay smoothing layer is an original addition: it is not a standard EMA, WMA, or VWMA — it applies a decaying weight function that is conceptually distinct from any standard Pine Script built-in smoothing function, producing a cleaner oscillator output with less phase distortion than an equivalent EMA. The ADF-inspired adaptive multiplier is a real-time regime-sensitivity mechanism not present in any standard oscillator. The four-type divergence engine built into the same panel, detecting all four divergence classes simultaneously using pivot comparison logic, provides complete divergence coverage without requiring additional scripts or manual line drawing. The combination of these elements — relative-volume normalization, Fourier decay smoothing, adaptive trend scaling, blended output, flow momentum line, and full-coverage divergence detection — into a single oscillator panel represents an original synthesis that is not replicated by any standard built-in indicator.

---

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Trading involves substantial risk of loss. Past performance of any indicator or strategy is not indicative of future results. Always conduct your own research and consult a qualified financial professional before making any trading decisions.

[i]-Made with passion by officialjackofalltrades[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Tidal Volume Oscillator [JOAT]", shorttitle="TVO [JOAT]", overlay=false, max_labels_count=100)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpVZO   = "VZO Core"
length   = input.int(14, "VZO Length", minval=3, maxval=100, group=grpVZO)
smoothing = input.int(5, "Smoothing", minval=1, maxval=30, group=grpVZO)
signalLen = input.int(9, "Signal Length", minval=1, maxval=50, group=grpVZO)

grpFour  = "Fourier Smoothing"
fourLen  = input.int(20, "Fourier Window", minval=5, maxval=60, group=grpFour)
fourBlend = input.float(0.4, "Fourier Blend (0-1)", minval=0.0, maxval=1.0, step=0.05, group=grpFour)

grpMom   = "Flow Momentum"
momentumLookback = input.int(8, "Momentum Lookback", minval=2, maxval=30, group=grpMom)
obLevel  = input.float(80.0, "Overbought Level", minval=50.0, maxval=99.0, group=grpMom)
osLevel  = input.float(-80.0, "Oversold Level", minval=-99.0, maxval=-50.0, group=grpMom)

grpDiv   = "Divergence Engine"
showDiv  = input.bool(true, "Show Divergences", group=grpDiv)
leftBars = input.int(5, "Pivot Left Bars", minval=1, maxval=20, group=grpDiv)
rightBars = input.int(3, "Pivot Right Bars", minval=1, maxval=10, group=grpDiv)

grpVis   = "Visual"
showTbl  = input.bool(true, "Show Info Table", group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
bullColor  = color.rgb(92, 240, 215)
bearColor  = color.rgb(179, 42, 195)
neutralCol = color.rgb(130, 140, 160)
bgDark     = color.rgb(10, 14, 22)
textLight  = color.rgb(220, 225, 235)
textDim    = color.rgb(100, 110, 130)
divBullC   = color.rgb(50, 220, 120)
divBearC   = color.rgb(255, 80, 80)
hidBullC   = color.rgb(100, 180, 255)
hidBearC   = color.rgb(255, 160, 50)

// ─────────────────────────────────────────────────────────────────────────────
// VZO CORE CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
rel_volume     = volume / math.max(ta.sma(volume, length), 0.0001)
price_change   = close - close[1]
smoothed_vol   = ta.ema(rel_volume, smoothing)
smoothed_chg   = ta.ema(price_change, smoothing)
base_momentum  = ta.ema(smoothed_chg * smoothed_vol, smoothing)

pos_mom = ta.ema(math.max(base_momentum, 0.0), length)
neg_mom = ta.ema(math.abs(math.min(base_momentum, 0.0)), length)

ratio   = neg_mom > 0.00001 ? pos_mom / neg_mom : (pos_mom > 0.00001 ? 100.0 : 1.0)
vzo_ema = 100.0 * (ratio - 1.0) / (ratio + 1.0)

// ─────────────────────────────────────────────────────────────────────────────
// FOURIER EXPONENTIAL-DECAY SMOOTHING
// ─────────────────────────────────────────────────────────────────────────────
fourier_smooth(src_val, fLen) =>
    float sumV = 0.0
    float wSum = 0.0
    for i = 0 to fLen - 1
        w = math.exp(-float(i) / (float(fLen) * 0.3))
        sumV += nz(src_val[i]) * w
        wSum += w
    wSum > 0.0 ? sumV / wSum : src_val

vzo_fourier = fourier_smooth(vzo_ema, math.min(fourLen, bar_index + 1))

// ─────────────────────────────────────────────────────────────────────────────
// ADF TREND FILTER (multiplier for adaptive blending)
// ─────────────────────────────────────────────────────────────────────────────
adf_filter(src_val, window) =>
    sma_s = ta.sma(src_val, math.max(1, window / 3))
    sma_l = ta.sma(src_val, window)
    vol   = ta.stdev(src_val, window)
    ts    = vol > 0.0 ? (sma_s - sma_l) / vol : 0.0
    1.0 + math.max(-0.1, math.min(0.1, ts * 0.2))

adf_mult = adf_filter(vzo_ema, length)

// ─────────────────────────────────────────────────────────────────────────────
// FINAL VZO — BLEND EMA + FOURIER, SCALE BY ADF, CLAMP
// ─────────────────────────────────────────────────────────────────────────────
vzo_blend = (vzo_ema * (1.0 - fourBlend) + vzo_fourier * fourBlend) * adf_mult
vzo       = math.max(-100.0, math.min(100.0, vzo_blend))
signal    = ta.sma(vzo, signalLen)

// ─────────────────────────────────────────────────────────────────────────────
// FLOW MOMENTUM LINE
// ─────────────────────────────────────────────────────────────────────────────
flow_momentum       = (vzo - ta.ema(vzo, momentumLookback)) * 0.5
momentum_strength   = math.abs(ta.change(vzo, 3))
ms_highest          = ta.highest(momentum_strength, 50)
intensity           = ms_highest > 0.0 ? math.min(1.0, momentum_strength / ms_highest) : 0.0

// ─────────────────────────────────────────────────────────────────────────────
// DYNAMIC COLOR BLENDING
// ─────────────────────────────────────────────────────────────────────────────
get_dynamic_color(is_bull, strength) =>
    primary   = is_bull ? bullColor : bearColor
    secondary = is_bull ? color.rgb(50, 200, 160) : color.rgb(220, 80, 160)
    r = int(float(color.r(primary)) * (1.0 - strength) + float(color.r(secondary)) * strength)
    g = int(float(color.g(primary)) * (1.0 - strength) + float(color.g(secondary)) * strength)
    b = int(float(color.b(primary)) * (1.0 - strength) + float(color.b(secondary)) * strength)
    color.rgb(r, g, b)

isBull    = vzo >= 0.0
dynColor  = get_dynamic_color(isBull, intensity)
flowColor = flow_momentum >= 0.0 ? color.new(bullColor, 50) : color.new(bearColor, 50)

// ─────────────────────────────────────────────────────────────────────────────
// DIVERGENCE ENGINE — 4 TYPES
// ─────────────────────────────────────────────────────────────────────────────
pl = ta.pivotlow(vzo, leftBars, rightBars)
ph = ta.pivothigh(vzo, leftBars, rightBars)

// Bool conditions required by ta.valuewhen
plCond = not na(pl)
phCond = not na(ph)

// Current pivot prices at pivot bar (shifted back by rightBars)
plPrice = ta.valuewhen(plCond, low[rightBars], 0)
phPrice = ta.valuewhen(phCond, high[rightBars], 0)
plVZO   = ta.valuewhen(plCond, vzo[rightBars], 0)
phVZO   = ta.valuewhen(phCond, vzo[rightBars], 0)

prevPlPrice = ta.valuewhen(plCond, low[rightBars], 1)
prevPhPrice = ta.valuewhen(phCond, high[rightBars], 1)
prevPlVZO   = ta.valuewhen(plCond, vzo[rightBars], 1)
prevPhVZO   = ta.valuewhen(phCond, vzo[rightBars], 1)

// Regular Bullish: price lower low + osc higher low
bull_div = showDiv and not na(pl) and
  plPrice < prevPlPrice and plVZO > prevPlVZO

// Hidden Bullish: price higher low + osc lower low
hid_bull_div = showDiv and not na(pl) and
  plPrice > prevPlPrice and plVZO < prevPlVZO

// Regular Bearish: price higher high + osc lower high
bear_div = showDiv and not na(ph) and
  phPrice > prevPhPrice and phVZO < prevPhVZO

// Hidden Bearish: price lower high + osc higher high
hid_bear_div = showDiv and not na(ph) and
  phPrice < prevPhPrice and phVZO > prevPhVZO

// Divergence label placement
if bull_div
    label.new(bar_index - rightBars, vzo[rightBars] - 8.0,
      text="Bull Div", style=label.style_label_up,
      color=color.new(divBullC, 20), textcolor=bgDark, size=size.tiny)

if hid_bull_div
    label.new(bar_index - rightBars, vzo[rightBars] - 8.0,
      text="H.Bull", style=label.style_label_up,
      color=color.new(hidBullC, 20), textcolor=bgDark, size=size.tiny)

if bear_div
    label.new(bar_index - rightBars, vzo[rightBars] + 8.0,
      text="Bear Div", style=label.style_label_down,
      color=color.new(divBearC, 20), textcolor=color.white, size=size.tiny)

if hid_bear_div
    label.new(bar_index - rightBars, vzo[rightBars] + 8.0,
      text="H.Bear", style=label.style_label_down,
      color=color.new(hidBearC, 20), textcolor=bgDark, size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
// VZO FLIP SIGNAL MARKERS
// ─────────────────────────────────────────────────────────────────────────────
vzoFlipBull  = ta.crossover(vzo, signal)  and barstate.isconfirmed
vzoFlipBear  = ta.crossunder(vzo, signal) and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
// Reference levels
hline(0,  "Zero",        color=color.new(neutralCol, 60), linestyle=hline.style_solid,  linewidth=1)
hline(obLevel,  "OB",   color=color.new(bearColor, 60),  linestyle=hline.style_dashed, linewidth=1)
hline(osLevel,  "OS",   color=color.new(bullColor, 60),  linestyle=hline.style_dashed, linewidth=1)
hline(100, "OB Max",    color=color.new(bearColor, 85),  linestyle=hline.style_dotted, linewidth=1)
hline(-100, "OS Min",   color=color.new(bullColor, 85),  linestyle=hline.style_dotted, linewidth=1)

// OB/OS zones (fill anchors)
pOB_top = plot(100.0,    "OB Top",     display=display.none)
pOB_bot = plot(obLevel,  "OB Bottom",  display=display.none)
pOS_top = plot(osLevel,  "OS Top",     display=display.none)
pOS_bot = plot(-100.0,   "OS Bottom",  display=display.none)
pZero   = plot(0.0,      "Zero Ref",   display=display.none)

fill(pOB_top, pOB_bot, 100.0, obLevel,   color.new(bearColor, 88), color.new(bearColor, 95))
fill(pOS_top, pOS_bot, osLevel, -100.0,   color.new(bullColor, 95), color.new(bullColor, 88))

// Flow momentum
pFlow   = plot(flow_momentum, "Flow Momentum", color=flowColor, linewidth=1, style=plot.style_area)
fill(pFlow, pZero, flow_momentum, 0.0, color.new(bullColor, 80), color.new(bearColor, 80))

// Main VZO and signal
pVZO    = plot(vzo,    "VZO",    color=dynColor,                    linewidth=2)
pSignal = plot(signal, "Signal", color=color.new(neutralCol, 30),  linewidth=1, style=plot.style_linebr)

// VZO vs Signal gradient fill
fill(pVZO, pSignal, vzo, signal,
  vzo > signal ? color.new(bullColor, 75) : color.new(bearColor, 75),
  vzo > signal ? color.new(bullColor, 90) : color.new(bearColor, 90))

// VZO flip circles
plotshape(vzoFlipBull, title="Flip Bull", style=shape.circle, location=location.absolute,
  color=bullColor, size=size.tiny, offset=0)
plotshape(vzoFlipBear, title="Flip Bear", style=shape.circle, location=location.absolute,
  color=bearColor, size=size.tiny, offset=0)

// ─────────────────────────────────────────────────────────────────────────────
// DIVERGENCE STATE TRACKING
// ─────────────────────────────────────────────────────────────────────────────
var string lastDivState = "None"
if bull_div
    lastDivState := "Bull Div"
else if hid_bull_div
    lastDivState := "Hidden Bull"
else if bear_div
    lastDivState := "Bear Div"
else if hid_bear_div
    lastDivState := "Hidden Bear"

// ─────────────────────────────────────────────────────────────────────────────
// INFO TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = na
if showTbl
    if na(tbl)
        tbl := table.new(position.top_right, 2, 6,
          bgcolor=color.new(bgDark, 15),
          border_color=color.new(neutralCol, 70),
          border_width=1,
          frame_color=color.new(neutralCol, 50),
          frame_width=1)

    table.cell(tbl, 0, 0, "TVO [JOAT]", text_color=textLight,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=bullColor,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    vzoDispCol = vzo > 0 ? bullColor : bearColor
    table.cell(tbl, 0, 1, "VZO", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(vzo, "#.##"), text_color=vzoDispCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 2, "Signal", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    sigDispCol = signal > 0 ? bullColor : bearColor
    table.cell(tbl, 1, 2, str.tostring(signal, "#.##"), text_color=sigDispCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(tbl, 0, 3, "Flow", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    flowDispCol = flow_momentum >= 0 ? bullColor : bearColor
    table.cell(tbl, 1, 3, str.tostring(flow_momentum, "#.##"), text_color=flowDispCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    regStr = vzo > 20 ? "BULLISH" : vzo < -20 ? "BEARISH" : "NEUTRAL"
    regCol = vzo > 20 ? bullColor : vzo < -20 ? bearColor : neutralCol
    table.cell(tbl, 0, 4, "Regime", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 4, regStr, text_color=regCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    divCol = lastDivState == "Bull Div" or lastDivState == "Hidden Bull" ? bullColor :
             lastDivState != "None" ? bearColor : textDim
    table.cell(tbl, 0, 5, "Divergence", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(tbl, 1, 5, lastDivState, text_color=divCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(vzoFlipBull, title="TVO [JOAT] Bull Cross",  message="TVO [JOAT]: VZO crossed above Signal on {{ticker}}.")
alertcondition(vzoFlipBear, title="TVO [JOAT] Bear Cross",  message="TVO [JOAT]: VZO crossed below Signal on {{ticker}}.")
alertcondition(bull_div,    title="TVO [JOAT] Bull Div",    message="TVO [JOAT]: Bullish divergence detected on {{ticker}}.")
alertcondition(bear_div,    title="TVO [JOAT] Bear Div",    message="TVO [JOAT]: Bearish divergence detected on {{ticker}}.")
````
