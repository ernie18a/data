# CTZ Accumulation/Distribution

- url: https://www.tradingview.com/script/kMKeZbHR-CTZ-Accumulation-Distribution/
- type: indicator
- pine_id: PUB;a5ebbeb4a37c41cf98b2d1ba3b8cdb18
- version: 1.0

## Description

**CTZ Accumulation/Distribution**

A volume-based indicator that tracks whether money is flowing into or out of an asset by measuring where price closes within each bar's range, weighted by volume.

**How it works**

Each bar, a Money Flow Multiplier is calculated from the close's position between the high and low (–1 to +1). This is multiplied by volume to produce Money Flow Volume, which is added to a running cumulative total — the A/D line. Closes near the high on heavy volume push the line up (accumulation); closes near the low on heavy volume push it down (distribution).

**Features**

- **A/D Line with trend colouring** — teal when above the signal EMA, red when below, giving an at-a-glance read on money flow direction
- **Signal EMA (default 21)** — smooths the A/D line and acts as a trend filter; crosses can be used as early momentum shifts
- **Automatic divergence detection** — pivot-based logic flags bullish divergence (price makes a lower low while A/D makes a higher low = hidden accumulation) and bearish divergence (price makes a higher high while A/D makes a lower high = distribution into strength)
- **Built-in alerts** — divergence signals and signal-line crosses in both directions

**How to use it**

Confirmation: when price and the A/D line rise together, the uptrend is supported by real buying pressure. When they fall together, the downtrend is genuine.

Divergence: when price and the A/D line disagree, treat it as an early warning. Bull labels suggest smart money is accumulating into weakness; Bear labels suggest distribution into rising prices. These work best on higher timeframes and near key levels — not as standalone entries.

**Settings**

Signal EMA length, pivot lookback (sensitivity of divergence detection), and max bars between pivots (how far apart two pivots can be and still count as a divergence) are all adjustable.

**Limitations**

The A/D line ignores gaps between bars — an asset gapping up overnight registers nothing if it then closes mid-range. Pivot-confirmed divergence labels print a few bars after the pivot by design. Best used alongside momentum tools (RSI, MFI) rather than in isolation.

## Source Code

````pine
//@version=6
indicator("CTZ Accumulation/Distribution", shorttitle="CTZ A/D", format=format.volume)

// ── Inputs ─────────────────────────────────────────────
showSignal = input.bool(true,  "Show Signal EMA",        group="Display")
sigLen     = input.int(21,     "Signal EMA Length",      minval=1, group="Display")
showDiv    = input.bool(true,  "Show Divergences",       group="Divergence")
pivotLen   = input.int(5,      "Pivot Lookback",         minval=2, group="Divergence")
divRange   = input.int(60,     "Max Bars Between Pivots", minval=10, group="Divergence")

// ── A/D Calculation ────────────────────────────────────
// Money Flow Multiplier: ((C - L) - (H - C)) / (H - L)
mfm = high == low ? 0.0 : ((close - low) - (high - close)) / (high - low)
mfv = mfm * volume
var float ad = 0.0
ad += mfv

sig = ta.ema(ad, sigLen)

// ── Plots ──────────────────────────────────────────────
adColor = ad > sig ? color.new(color.teal, 0) : color.new(color.red, 0)
plot(ad,  "A/D Line", color=adColor, linewidth=2)
plot(showSignal ? sig : na, "Signal EMA", color=color.new(color.orange, 30))

// ── Divergence Detection ───────────────────────────────
plLow  = ta.pivotlow(low, pivotLen, pivotLen)
phHigh = ta.pivothigh(high, pivotLen, pivotLen)

var float lastPriceLow = na
var float lastAdLow    = na
var int   lastLowBar   = na
var float lastPriceHigh = na
var float lastAdHigh    = na
var int   lastHighBar   = na

bullDiv = false
bearDiv = false

if not na(plLow)
    adAtPivot = ad[pivotLen]
    if not na(lastPriceLow) and (bar_index - lastLowBar) <= divRange
        // price lower low, A/D higher low
        if plLow < lastPriceLow and adAtPivot > lastAdLow
            bullDiv := true
    lastPriceLow := plLow
    lastAdLow    := adAtPivot
    lastLowBar   := bar_index

if not na(phHigh)
    adAtPivot = ad[pivotLen]
    if not na(lastPriceHigh) and (bar_index - lastHighBar) <= divRange
        // price higher high, A/D lower high
        if phHigh > lastPriceHigh and adAtPivot < lastAdHigh
            bearDiv := true
    lastPriceHigh := phHigh
    lastAdHigh    := adAtPivot
    lastHighBar   := bar_index

plotshape(showDiv and bullDiv ? ad[pivotLen] : na, "Bull Div", style=shape.labelup,   location=location.absolute, color=color.new(color.teal, 0), text="Bull", textcolor=color.white, size=size.tiny, offset=-pivotLen)
plotshape(showDiv and bearDiv ? ad[pivotLen] : na, "Bear Div", style=shape.labeldown, location=location.absolute, color=color.new(color.red, 0),  text="Bear", textcolor=color.white, size=size.tiny, offset=-pivotLen)

// ── Alerts ─────────────────────────────────────────────
alertcondition(bullDiv, "A/D Bullish Divergence", "Price LL vs A/D HL — accumulation divergence")
alertcondition(bearDiv, "A/D Bearish Divergence", "Price HH vs A/D LH — distribution divergence")
alertcondition(ta.crossover(ad, sig),  "A/D Cross Above Signal", "A/D crossed above signal EMA")
alertcondition(ta.crossunder(ad, sig), "A/D Cross Below Signal", "A/D crossed below signal EMA")
````
