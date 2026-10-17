# For-Loop Consensus MA | MiesOnCharts

- url: https://www.tradingview.com/script/sO3DaS7o-For-Loop-Consensus-MA-MiesOnCharts/
- type: indicator
- pine_id: PUB;1b6e59612ee44fb49d30e65932e06763
- version: 1.0

## Description

For-Loop Consensus MA

[b]Overview[/b]
For-Loop Consensus MA is a trend indicator that replaces a single moving average with an ensemble of exponential moving averages (EMAs) and asks them to "vote" on the direction of the market. Instead of committing to one length -- where a value of 20 and a value of 50 can disagree and either can be wrong at any given time -- it evaluates many lengths at once and only signals a trend when a large majority of them agree. The result is a single line whose colour reflects the level of agreement across the whole set of lookbacks.

[b]The idea behind it[/b]
A recurring problem with moving-average trend tools is parameter sensitivity: the "best" length is only known in hindsight and changes with market conditions. A short EMA reacts quickly but whipsaws in noise; a long EMA is stable but late. Picking one is a compromise.

This indicator borrows a concept from statistics and machine learning known as model averaging (also called ensembling or bagging): rather than trusting one model, you build many variations of it and combine their outputs. The aggregate is generally more robust than any single member, because the idiosyncratic errors of individual lengths tend to cancel out while the shared trend signal reinforces.

Two things are aggregated here:

The line itself -- the average of all EMAs in the ensemble, producing a smoothed consensus curve.

The direction vote -- the fraction of EMAs that price is currently trading above.

[b]How it works[/b]
The script uses a for loop to construct and maintain a series of EMAs spanning a range of lengths:

It steps from Min EMA Length to Max EMA Length in increments of Length Step (for example 20, 40, 60… 140).

Each EMA is computed manually from its smoothing factor alpha = 2 / (length + 1), and its running value is stored in a persistent array -- one slot per length -- so every member carries its state forward bar to bar.

On each bar the loop does two things: it sums the EMA values (to build the consensus line), and it counts how many EMAs price closes above (to build the vote).
From these:

Consensus line = the mean of all EMAs in the ensemble.
Vote share = number of EMAs price is above ÷ total number of EMAs, a value between 0 and 1.
Signal logic

The vote share drives the trend state through a symmetric threshold:

Bullish when the vote share is greater than or equal to the Supermajority Vote Share input (default 0.7) -- i.e. at least 70% of the lookbacks agree price is in an uptrend. The line turns green.

Bearish when the vote share is at or below its mirror (1 - threshold, so 0.3 at the default) -- at least 70% agree on a downtrend. The line turns red.

Neutral in between, when the ensemble is split and no supermajority exists. The line is grey, indicating indecision or a ranging market.

Requiring a supermajority rather than a simple majority is deliberate: it filters out the marginal, split-vote conditions where moving averages are least reliable, and only commits to a trend colour when the evidence across timescales is broad.

[b]Inputs[/b]
Source -- the price series the EMAs are built from (default: close).
Min EMA Length / Max EMA Length -- the shortest and longest lookbacks in the ensemble. A wider span blends more timescales.

Length Step -- the spacing between ensemble members. A smaller step packs in more EMAs (finer, heavier); a larger step uses fewer.

Supermajority Vote Share -- how strong the agreement must be before a trend is declared. Higher values (e.g. 0.8) demand stronger consensus and produce fewer, more selective signals; lower values (e.g. 0.6) are more responsive but less discriminating.

[b]How to use it[/b]
Trend context -- read the colour of the line as a regime filter. Green suggests a broad-based uptrend across lookbacks; red a broad downtrend; grey a lack of consensus where trend-following is riskier.

Trend confirmation -- the line can be used alongside price structure or other tools to confirm that a move is supported across multiple horizons rather than by one arbitrary length.
Neutral zones -- grey stretches highlight indecision and can be treated as periods to stand aside or tighten expectations.
Two alert conditions are included -- Consensus MA Long (bullish) and Consensus MA Short (bearish) -- so the trend states can be wired to TradingView alerts.

[b]Notes and limitations[/b]
Like all moving-average-based tools, this indicator is reactive: it describes the trend that price is already in and will lag turning points. It does not predict future prices.
Signals reflect agreement among lagging averages, so expect the trend colour to change after a reversal has begun, not before it.

Wider length ranges and larger supermajority thresholds increase robustness at the cost of responsiveness. There is no universally correct setting; adjust to the instrument and timeframe you trade.

This script is a decision-support tool, not a standalone trading system and not financial advice. It does not include risk management and makes no representation about future performance. 

Test any settings on your market before relying on them.

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
// FOR-LOOP CONSENSUS MA  (overlay)
// Model: model averaging / ensemble learning. Instead of picking ONE moving
// average length, a for loop maintains an ensemble of EMAs
// from lenMin to lenMax (state held in an array, one slot per length) and
// averages them into a single consensus line. A second pass counts how many
// ensemble members price is above the "vote share" and the line only
// turns bullish/bearish when a supermajority of lookbacks agree.

// ─────────────────────────────────────────────────────────────────────────────
indicator("For-Loop Consensus MA", overlay = true)

src     = input.source(close, "Source")
lenMin  = input.int(20,  "Min EMA Length", minval = 2)
lenMax  = input.int(150, "Max EMA Length", minval = 10)
stepLen = input.int(20,  "Length Step", minval = 1)
voteThr = input.float(0.7, "Supermajority Vote Share", minval = 0.5, maxval = 1.0, step = 0.05)

int nModels = math.floor((lenMax - lenMin) / stepLen) + 1

// One persistent EMA state per ensemble member
var array<float> emaState = array.new_float(nModels, na)

float sumMA = 0.0
float votes = 0.0

for k = 0 to nModels - 1
    L     = lenMin + k * stepLen
    alpha = 2.0 / (L + 1)
    prev  = array.get(emaState, k)
    e     = na(prev) ? src : alpha * src + (1 - alpha) * prev
    array.set(emaState, k, e)
    sumMA += e
    votes += src > e ? 1 : 0

consensus = sumMA / nModels
voteShare = votes / nModels          // 0..1: fraction of lookbacks calling "up"

bullish = voteShare >= voteThr
bearish = voteShare <= 1 - voteThr

col = bullish ? color.new(color.rgb(0, 255, 21), 0) : bearish ? color.new(color.rgb(255, 0, 0), 0) : color.new(color.gray, 20)

plot(consensus, "Consensus MA", color = col, linewidth = 3)

alertcondition(bullish, "Consensus MA Long",  "Consensus turned bullish")
alertcondition(bearish, "Consensus MA Short", "Consensus turned bearish")
````
