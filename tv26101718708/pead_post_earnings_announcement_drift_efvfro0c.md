# PEAD - Post Earnings Announcement Drift

- url: https://www.tradingview.com/script/efVFRo0C-PEAD-Post-Earnings-Announcement-Drift/
- type: strategy
- pine_id: PUB;d87984ae0a3f4d3798877d438835cfa5
- version: 1.0

## Description

* **Entry Logic (Concordant Signal):** The strategy waits for both the fundamental data, namely the earnings surprise, and the market reaction to move in the same direction. If a company reports earnings above expectations and the stock price reacts positively, this is called a **“concordant signal”**, and a long position is opened.

* **Behavior of Institutional Investors:** As noted in the source, institutional investors update their models and adjust their positions not within minutes, but through a process that takes **weeks**. This gradual trading process creates sustained buying pressure on the price, causing it to “drift” upward.

* **Duration of the Rally:** Research shows that this drift can continue for approximately **60 trading days** — around 3 months. For this reason, the strategy recommends holding the position for 60 days without setting any take-profit or stop-loss level.

* **Market Inefficiency:** Under the Efficient Market Hypothesis, all information should normally be reflected in prices immediately. However, PEAD is a **market inefficiency** documented since 1968 that violates this principle due to factors such as the slow reaction of institutions, analysts gradually revising their forecasts, and transaction costs.

In short, because it takes time for large institutional players to update their models and build substantial positions gradually in the market, you are able to benefit from this “slow” information-processing process and ride the rally.

## Source Code

````pine
//@version=6
strategy(
     "PEAD - Post Earnings Announcement Drift",
     overlay=true,
     initial_capital=100000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=100,
     pyramiding=0,
     commission_type=strategy.commission.percent,
     commission_value=0.05
)

holdBars        = input.int(60, "Holding period, bars", minval=1)
minSurprisePct  = input.float(5.0, "Min EPS surprise %", step=0.5)
minReactionPct  = input.float(0.0, "Min price reaction %", step=0.25)
allowShorts     = input.bool(false, "Enable short PEAD")
reactionMode    = input.string(
     "Next daily bar",
     "Reaction confirmation",
     options=["Next daily bar", "Earnings bar"]
)

actual = request.earnings(
     syminfo.tickerid,
     earnings.actual,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off
)

estimate = request.earnings(
     syminfo.tickerid,
     earnings.estimate,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off
)

hasReport = not na(actual) and not na(estimate) and math.abs(estimate) > 0
surprisePct = hasReport ? 100.0 * (actual - estimate) / math.abs(estimate) : na

surpriseDir =
     hasReport and surprisePct >= minSurprisePct ? 1 :
     hasReport and surprisePct <= -minSurprisePct ? -1 :
     0

barReactionPct = 100.0 * (close / close[1] - 1.0)

var int pendingDir = 0
var int pendingBar = na

bool longSignal = false
bool shortSignal = false

if reactionMode == "Earnings bar"
    longSignal := surpriseDir == 1 and barReactionPct >= minReactionPct
    shortSignal := allowShorts and surpriseDir == -1 and barReactionPct <= -minReactionPct

if reactionMode == "Next daily bar"
    if not na(pendingBar) and bar_index == pendingBar + 1
        longSignal := pendingDir == 1 and barReactionPct >= minReactionPct
        shortSignal := allowShorts and pendingDir == -1 and barReactionPct <= -minReactionPct
        pendingDir := 0
        pendingBar := na

    if hasReport
        pendingDir := surpriseDir
        pendingBar := bar_index

if longSignal
    strategy.entry("PEAD Long", strategy.long)

if shortSignal
    strategy.entry("PEAD Short", strategy.short)

barsHeld = strategy.opentrades > 0 ? bar_index - strategy.opentrades.entry_bar_index(0) : na

if strategy.position_size > 0 and barsHeld >= holdBars
    strategy.close("PEAD Long")

if strategy.position_size < 0 and barsHeld >= holdBars
    strategy.close("PEAD Short")

plotshape(hasReport, title="Earnings report", style=shape.circle, location=location.belowbar, size=size.tiny, color=color.gray)
plotshape(longSignal, title="PEAD long", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(shortSignal, title="PEAD short", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

plot(surprisePct, title="EPS surprise %", display=display.data_window)
plot(barReactionPct, title="Price reaction %", display=display.data_window)
````
