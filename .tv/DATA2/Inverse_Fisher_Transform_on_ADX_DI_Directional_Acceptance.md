<!-- tradingview-pine-id: PUB;4363e4c8119c4841b5eccec3a104d66f -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Inverse Fisher Transform on ADX DI (Directional Acceptance)

Source: https://www.tradingview.com/script/EPyog179-Inverse-Fisher-Transform-on-ADX-DI-Directional-Acceptance/

## Description

[*] **Purpose** — Implements an Inverse Fisher Transform (IFT) on the ADX Directional Index spread (plusDI − minusDI) to produce a bounded, smoothed oscillator that highlights directional dominance and makes extreme directional shifts easier to spot.  
[*] **Core signal** — Uses the DMI spread as the raw input; positive values indicate upward directional dominance, negative values indicate downward dominance, and the IFT maps those tendencies into a compact \([-1, +1]\) range.  
[*] **Normalization** — Normalizes the DI spread over a rolling window (`normLen`) by computing the windowed minimum and maximum, then rescales to \([0,1]\) and remaps to \([-1,1]\) so the IFT receives a stable, comparable input across different instruments and timeframes.  
[*] **Clamping for stability** — Clamps the normalized input to \([-0.999, 0.999]\) before applying the exponential-based IFT formula to avoid numerical overflow and to keep the transform well-behaved near the boundaries.  
[*] **Inverse Fisher Transform math** — Applies the standard IFT formula \((e^{2x}-1)/(e^{2x}+1)\) which accentuates extremes and compresses mid-range values, improving the visual separation between neutral and strong directional conditions.  
[*] **Pre- and final smoothing** — Offers a two-stage smoothing approach: optional pre-smoothing of the normalized input to reduce spikes, followed by a final smoothing (RMA/EMA/WMA) of the IFT output to control responsiveness versus noise.  
[*] **Smoothing options** — Supports Wilder RMA for trend stability, EMA for responsiveness, and WMA for weighted recency; this flexibility lets traders tune the indicator to their preferred balance of lag and sensitivity.  
[*] **Visual enhancements** — Plots the smoothed IFT line with color coding for positive/negative values, optional histogram columns, horizontal threshold lines (e.g., ±0.5), and a filled area to emphasize the relationship to zero.  
[*] **Alerting and signals** — Includes `alertcondition` triggers for crossings of the upper/lower thresholds and zero, enabling automated notifications when directional acceptance shifts materially in either direction.  
[*] **Edge-case handling** — Gracefully handles flat normalization windows by returning a neutral midpoint (0.5 normalized) and uses a tiny epsilon-like clamp to avoid division-by-zero or degenerate outputs.  
[*] **Tuning guidance** — Recommends larger `normLen` for less sensitivity to short-term swings, smaller smoothing lengths for faster signals, and threshold adjustments per instrument and timeframe to reduce false signals.  
[*] **Performance considerations** — Keeps computations lightweight (min/max, simple transforms, standard moving averages) so the script runs efficiently even on lower timeframes or long historical ranges.  
[*] **Interpretation tips** — Readings above the upper threshold indicate accepted upward dominance (bullish bias), readings below the lower threshold indicate accepted downward dominance (bearish bias), and zero crossings suggest shifts in directional control.  
[*] **Extensions and variants** — Can be extended with percentile-based normalization, multi-timeframe DI inputs, ADX overlay for trend strength context, or adaptive thresholds; these additions can improve robustness but may increase complexity and computation.  
[*] **Practical use** — Best used as a directional-confirmation tool alongside price action or trend filters; avoid using it as a lone entry signal on highly mean-reverting instruments without additional confirmation.

---

## Source Code

````pine
//@version=6
indicator("Inverse Fisher Transform on ADX DI (Directional Acceptance)", overlay=false)

// ───── Inputs ─────
diLen       = input.int(14, "DI Length", minval=1)
adxSmooth   = input.int(14, "ADX Smoothing", minval=1)
normLen     = input.int(50, "Normalization Length", minval=5)
smoothLen   = input.int(5, "IFT RMA Smoothing", minval=1)

// ───── Directional Movement Index ─────
[plusDI, minusDI, _] = ta.dmi(diLen, adxSmooth)

// ───── Directional Dominance (Spread) ─────
diSpread = plusDI - minusDI

// ───── Normalize Spread ─────
lowS  = ta.lowest(diSpread, normLen)
highS = ta.highest(diSpread, normLen)

norm = highS != lowS ? (diSpread - lowS) / (highS - lowS) : 0.5

// Map to centered range [-1, +1]
x = 2 * norm - 1

// Clamp for numerical stability
x := math.max(math.min(x, 0.999), -0.999)

// ───── Inverse Fisher Transform ─────
iftRaw = (math.exp(2 * x) - 1) / (math.exp(2 * x) + 1)

// ───── Wilder smoothing (authority) ─────
iftDI = ta.rma(iftRaw, smoothLen)

// ───── Plot ─────
plot(iftDI, "IFT ADX Directional Acceptance", color=color.fuchsia, linewidth=2)

hline(0,    "Neutral", color=color.new(#f5eeee, 70))
hline(0.5,  "+0.5 Accepted Upward Dominance", color=color.new(color.green, 80))
hline(-0.5, "-0.5 Accepted Downward Dominance", color=color.new(color.red, 80))
````
