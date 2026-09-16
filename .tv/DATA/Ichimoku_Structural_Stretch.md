<!-- tradingview-pine-id: PUB;1c7fd056ab1647edacb9bb550ed0403a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Ichimoku Structural Stretch

Source: https://www.tradingview.com/script/6kdpJFfO-Ichimoku-Structural-Stretch/

## Description

The point of this script is simple. If we think of Ichimoku as assessing momentum from and away from an underlying equilibrium, then how might we look at the chart and spot the underlying phenomenon of a serial equilibrium displacement. 

Price is being pulled away from the fast equilibrium while the fast equilibrium itself is displaced from the slower equilibrium. That's what this oscillator measures.

The is not an RSI or a generic momentum. No attempt to tell you whether to buy. Just a visual summary of the Ichimoku system as a checklist for yourself. 

The signal magnitude is basically ((P-T)/ATR) X (1 + |T - K|/ATR). The percentiles tell you if  this is unusually large compared with this stock’s own history or not?

	​

---

## Source Code

````pine
//@version=6
indicator("Ichimoku Structural Stretch", shorttitle="ISS", overlay=false, precision=2)

// ─────────────────────────────────────────────
// Inputs
// ─────────────────────────────────────────────
tenkanLen   = input.int(18,  "Tenkan Length")
kijunLen    = input.int(52,  "Kijun Length")
atrLen      = input.int(14,  "ATR Length")

lookback    = input.int(104, "Historical Lookback")
gapWeight   = input.float(1.0, "TK Gap Weight", step=0.1)
smoothLen   = input.int(2, "Curve Smoothing")

showSignals = input.bool(true, "Show Historical Extremes")

// ─────────────────────────────────────────────
// Ichimoku
// ─────────────────────────────────────────────
midpoint(len) =>
    (ta.highest(high, len) + ta.lowest(low, len)) / 2.0

tenkan = midpoint(tenkanLen)
kijun  = midpoint(kijunLen)
atr    = ta.atr(atrLen)

// ─────────────────────────────────────────────
// COMPONENT 1:
// Signed price displacement from Tenkan
//
// Below Tenkan = negative
// Above Tenkan = positive
// ─────────────────────────────────────────────
priceStretch = atr != 0 ? (close - tenkan) / atr : 0.0

// ─────────────────────────────────────────────
// COMPONENT 2:
// Accumulated Tenkan-Kijun separation
//
// Absolute because we care about how stretched
// the structure is, not which line is on top.
// ─────────────────────────────────────────────
tkGap = atr != 0 ? math.abs(tenkan - kijun) / atr : 0.0

// ─────────────────────────────────────────────
// STRUCTURAL STRETCH
//
// As TK separation grows, displacement from
// Tenkan becomes increasingly significant.
// ─────────────────────────────────────────────
rawStretch = priceStretch * (1.0 + gapWeight * tkGap)

// Small smoothing only for readability
osc = ta.ema(rawStretch, smoothLen)

// ─────────────────────────────────────────────
// HISTORICAL EXTREMITY
//
// Percentile rank of current ABSOLUTE stretch
// relative to the stock's own prior oscillations.
// ─────────────────────────────────────────────
extremity = ta.percentrank(math.abs(rawStretch), lookback)

// ─────────────────────────────────────────────
// Colors
// Sign ALWAYS follows price vs Tenkan.
// ─────────────────────────────────────────────
curveColor = osc < 0 ? color.red :
             osc > 0 ? color.lime :
             color.gray

plot(osc, "Structural Stretch", color=curveColor, linewidth=3)

// ─────────────────────────────────────────────
// Historical-significance markers
// Yellow = top 10% historical stretch
// Orange = top 5%
// ─────────────────────────────────────────────
notable = extremity >= 90
extreme = extremity >= 95

plot(
     showSignals and notable ? osc : na,
     "90th Percentile",
     style=plot.style_circles,
     color=color.yellow,
     linewidth=2
)

plot(
     showSignals and extreme ? osc : na,
     "95th Percentile",
     style=plot.style_circles,
     color=color.orange,
     linewidth=3
)

// ─────────────────────────────────────────────
// Reference
// ─────────────────────────────────────────────
hline(0, "Tenkan Equilibrium", color=color.gray)
````
