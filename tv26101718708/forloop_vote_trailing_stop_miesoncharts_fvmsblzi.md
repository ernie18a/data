# For-Loop Vote Trailing Stop | MiesOnCharts

- url: https://www.tradingview.com/script/fVmsblzi-For-Loop-Vote-Trailing-Stop-MiesOnCharts/
- type: indicator
- pine_id: PUB;434e026192224974baad041369328a24
- version: 1.0

## Description

[b]For-Loop Vote Trailing Stop[/b]

[b]Overview[/b]

For-Loop Vote Trailing Stop is a trend-following tool that combines two ideas: [b]a multi-horizon momentum vote[/b] to decide the direction of the market, and an ATR-based ratcheting trailing stop to ride and eventually exit the move. Rather than judging momentum from a single lookback, it polls dozens of horizons at once and lets them vote; the winning side then sets a stop line that trails price and only flips when the opposite side wins the election.

The script plots as a single stop line that sits below price in an uptrend and above price in a downtrend, changing colour and side when the regime turns.

The script is designed and tuned for the 1D (daily) timeframe, though its inputs are fully adjustable for other timeframes.

[b]The idea behind it[/b]

Momentum measured over one lookback is fragile: a 10-bar reading and a 60-bar reading frequently disagree, and whichever you pick can be caught out by the other's timescale. This indicator treats direction as an election across horizons instead of a single measurement.

For every horizon from the minimum to the maximum, it asks a simple yes/no question is price higher now than it was that many bars ago? Each horizon casts a vote of +1 (higher) or −1 (lower). Summing and normalising these votes produces a single momentum score between −1 and +1 that reflects how broadly the move is supported across timescales. A score near +1 means price is up over nearly every horizon (a broad, persistent advance); near −1 means the opposite; near 0 means the horizons are split and there is no coherent trend.

That breadth-of-momentum score is more robust than any one lookback because agreement across many horizons is harder to fake than a single reading, and disagreement is surfaced honestly as a neutral score rather than hidden inside one arbitrary length.

[b]How it works[/b]

1. The vote

A for loop runs from Min Horizon to Max Horizon, comparing the source against its value "i" bars ago and adding +1 or −1 for each horizon. The total is divided by the number of horizons, giving a normalised score in the range [−1, +1].

2. The regime.

The score is compared against two thresholds:

-- If it reaches the Long Threshold, the regime turns long.

-- If it falls to the Short Threshold, the regime turns short.

-- Between the thresholds the current regime is held, the tool does not flip on marginal readings.

3. The trailing stop

An offset equal to ATR Multiplier × ATR is placed on the correct side of price:

-- On a fresh long signal the stop is set below price; while the long regime persists it only ever ratchets upward, locking in progress and never loosening.

-- On a fresh short signal the stop is set above price; while short it only ratchets downward.

-- The regime flips, and the stop jumps to the other side when the opposite threshold is met.

Because the stop can only tighten in the direction of the trend, it behaves like a one-way ratchet that follows favourable moves and holds its ground against pullbacks until the vote itself reverses.

[b]Signal logic and markers[/b]

-- The stop line is green while the regime is long (plotted beneath price) and red while short (plotted above price).

-- A green up-triangle marks each flip to long; a red down-triangle marks each flip to short.

-- Two alert conditions, Vote Stop Long and Vote Stop Short, fire on those flips so the regime changes can be wired to TradingView alerts.

[b]Inputs[/b]

-- Source : the price series the vote is measured on (default: hl2, the bar midpoint, which is slightly steadier than close).

-- Min Horizon / Max Horizon : the shortest and longest lookbacks in the vote. A wider span blends more timescales into the score.

-- Long Threshold : how strong the bullish vote must be to turn the regime long. Higher values demand broader agreement before committing.

-- Short Threshold : how weak (negative) the vote must be to turn the regime short.

-- ATR Length : the lookback for the Average True Range used to size the stop offset.

-- ATR Multiplier : how far the stop sits from price, in ATR units. Larger values give the trend more room to breathe (fewer, later exits); smaller values keep the stop tighter (quicker exits, more flips).

Note that the two thresholds are independent, so the tool can be set asymmetrically for example, requiring a stronger vote to enter long than to flip short, or vice versa to reflect a directional bias or differing conviction on each side.

[b]How to use it[/b]

-- Trend direction and stop management :  the line's side and colour give the current regime at a glance, while its level offers a systematic, volatility-scaled trailing reference that adapts as ATR expands and contracts.

-- Entries and exits : the flip markers indicate when broad momentum has changed sides; the trailing line indicates where that thesis would be invalidated.

-- Volatility awareness : because the offset is ATR-based, the stop automatically widens in turbulent conditions and tightens in calm ones, rather than using a fixed distance.

[b]Notes and limitations[/b]

-- This is a [b]reactive, trend-following[/b] tool. It follows momentum that is already underway and will change sides after a reversal has begun, not before it. It does not predict future prices.

-- In ranging or choppy markets the vote can oscillate around the thresholds, producing repeated flips ("whipsaw"). Wider horizon spans, more separated thresholds, and a larger ATR multiplier reduce this at the cost of responsiveness.

-- The stop is a calculated reference level, not a guaranteed exit price; actual fills depend on your broker, slippage, and market conditions.

-- There is no universally correct setting; the horizon range, thresholds, and ATR multiplier should be adjusted to the instrument and timeframe you trade.

[b]Originality[/b]

This is not a standard ATR trailing stop or SuperTrend clone. The direction that governs the stop is not derived from a single moving average or band, but from a cross-sectional vote computed in a loop across many momentum horizons. The ensemble vote and the ratcheting ATR stop are combined into one tool: the breadth of momentum decides the regime, and the volatility-scaled stop expresses that regime as an adaptive, one-way trailing level.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only and does not constitute financial, investment, or trading advice, nor a recommendation to buy or sell any asset. It is a decision-support tool, not a trading system, and the trailing stop it draws is a reference level, not an order or a guaranteed exit. Trading and investing carry substantial risk, including the possible loss of all capital. Past behaviour of any indicator or market is not indicative of future results, and no representation is made that its signals will be profitable. You are solely responsible for your own trading decisions and should conduct your own research and consult a licensed financial professional where appropriate. The author accepts no liability for any loss or damage arising from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MiesOnCharts

//   __  __ _           
//  |  \/  (_) ___  ___ 
//  | |\/| | |/ _ \/ __|
//  | |  | | |  __/\__ \
//  |_|  |_|_|\___||___/

//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// FOR-LOOP VOTE TRAILING STOP
// Overview: majority voting over horizons. A for loop compares close against
// close[i] for every horizon i in [a, b], scoring +1 / −1 per comparison.
// The normalized sum is a robust, multi-horizon momentum vote.
// The vote then DRIVES a trailing stop:
// the stop ratchets while the vote stays past the threshold, and the regime
// flips only when the opposite camp wins the election.

// ─────────────────────────────────────────────────────────────────────────────
indicator("For-Loop Vote Trailing Stop | Mies", overlay = true, max_labels_count = 500, timeframe ="", timeframe_gaps = true)

src    = input.source(hl2, "Source")
a      = input.int(1,  "Min Horizon (bars)", minval = 1)
b      = input.int(70, "Max Horizon (bars)", minval = 5)
thrUp  = input.float(0.6,  "Long Threshold",  minval = 0.0, maxval = 1.0, step = 0.05)
thrDn  = input.float(-0.2, "Short Threshold", minval = -1.0, maxval = 0.0, step = 0.05)
atrLen = input.int(14, "ATR Length (stop offset)", minval = 1)
atrK   = input.float(1.75, "ATR Multiplier", minval = 0.5, step = 0.25)

// ── Multi-horizon vote ───────────────────────────────────────────────────────
float score = 0.0
for i = a to b
    score += src > src[i] ? 1 : -1
score /= (b - a + 1)                 // normalized to [-1, +1]

// ── Regime + ratcheting stop ─────────────────────────────────────────────────
atrOff = atrK * ta.atr(atrLen)
var int   dir  = 0
var float stop = na

longSig  = score >= thrUp
shortSig = score <= thrDn

if longSig and dir != 1
    dir  := 1
    stop := src - atrOff
else if shortSig and dir != -1
    dir  := -1
    stop := src + atrOff
else if dir == 1
    stop := math.max(stop, src - atrOff)
else if dir == -1
    stop := math.min(stop, src + atrOff)

isUp = dir == 1
plot(stop, "Vote Stop", color = isUp ? color.new(color.rgb(0, 255, 21), 0) : color.new(color.rgb(255, 0, 0), 0),
     linewidth = 2, style = plot.style_linebr)

flipUp = dir == 1 and dir[1] != 1
flipDn = dir == -1 and dir[1] != -1
plotshape(flipUp, "Vote Long",  shape.triangleup,   location.belowbar, color.new(color.rgb(0, 255, 21), 0), size = size.small)
plotshape(flipDn, "Vote Short", shape.triangledown, location.abovebar, color.new(color.rgb(255, 0, 0), 0), size = size.small)

alertcondition(flipUp, "Vote Stop Long",  "Multi-horizon vote crossed long threshold")
alertcondition(flipDn, "Vote Stop Short", "Multi-horizon vote crossed short threshold")
````
