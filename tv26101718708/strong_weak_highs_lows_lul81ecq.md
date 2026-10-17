# Strong Weak Highs Lows

- url: https://www.tradingview.com/script/lUl81ecq-Strong-Weak-Highs-Lows/
- type: indicator
- pine_id: PUB;80378dfadb4f4e74b106defacc3db444
- version: 2.0

## Description

[b]strong Weak Highs & Lows[/b] is a market structure indicator that automatically classifies swing points based on price behavior and trend context. Instead of simply plotting highs and lows, it helps traders distinguish between levels that are likely to hold and levels that are more vulnerable to being broken.

The indicator identifies:

* **WH (Weak High)**
* **SH (Strong High)**
* **WL (Weak Low)**
* **SL (Strong Low)**

This provides a clearer view of liquidity, market intent, and potential breakout targets.

Understanding the Labels

Weak High (WH)

A Weak High is a swing high that has a higher probability of being broken in the future.

Characteristics:

* Usually forms during bullish market conditions.
* Indicates buyers remain in control.
* Often becomes a future liquidity target.

Strong High (SH)

A Strong High is a swing high that successfully rejects price and is more likely to hold.

Characteristics:

* Often forms during bearish conditions.
* Indicates seller presence.
* Acts as a potential resistance level.

Weak Low (WL)

A Weak Low is a swing low that has a higher probability of being broken.

Characteristics:

* Common during bearish trends.
* Indicates continued downside pressure.
* Frequently becomes a liquidity target.

Strong Low (SL)

A Strong Low is a swing low that successfully defends against further selling.

Characteristics:

* Often forms during bullish conditions.
* Indicates buyer strength.
* Acts as potential support.

What the Chart Demonstrates

Using the NVIDIA (NVDA) 1H chart:

📈 During bullish phases, the indicator identified multiple **Weak Highs (WH)** while marking **Strong Lows (SL)** beneath price, highlighting continued buyer dominance.

📉 As momentum weakened, **Strong Highs (SH)** began appearing near market turning points, signaling increasing seller control.

🎯 Weak levels often became natural liquidity targets before price reversed or continued its trend.

🔄 The ongoing alternation between strong and weak swing points provides valuable context for anticipating future market structure developments.

Why This Matters

Many traders focus solely on where highs and lows are located.

Professional price action analysis also considers:

* Which highs are likely to be broken
* Which lows are likely to hold
* Where liquidity is resting
* Where stop orders may be clustered
* Which side currently controls market structure

Strong Weak Highs & Lows helps visualize these concepts automatically.

Features

✔ Automatic swing detection
✔ Strong vs Weak classification
✔ Liquidity target identification
✔ Market structure context
✔ Clean chart visualization
✔ Non-repainting swing confirmation
✔ Multi-timeframe support
✔ Suitable for Smart Money Concepts (SMC)

How to Use

Bullish Environment

* Focus on Strong Lows (SL).
* Expect Weak Highs (WH) to be targeted and potentially broken.
* Look for continuation opportunities after pullbacks.

Bearish Environment

* Focus on Strong Highs (SH).
* Expect Weak Lows (WL) to be targeted and potentially broken.
* Look for selling opportunities during retracements.

Liquidity Analysis

* Weak highs and weak lows often act as future liquidity magnets.
* Use them as potential target zones for trend continuation trades.

Best Applications

* Market Structure Trading
* Smart Money Concepts (SMC)
* Liquidity Analysis
* Swing Trading
* Trend Following
* Intraday Trading
* Higher Timeframe Confirmation


[b]Notes[/b]
Strong and Weak classifications are based on market structure behavior and are not direct buy or sell signals. The indicator is designed to help traders understand the strength behind swing points and improve decision-making around support, resistance, and liquidity.

For best results, combine with:

* Break of Structure (BOS)
* Change of Character (CHoCH)
* Supply & Demand Zones
* Risk Management Rules

Strong Weak Highs & Lows transforms ordinary swing analysis into actionable market structure insight by identifying which levels are likely to hold and which levels are likely to become future liquidity targets.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

//@version=6
indicator('Strong Weak Highs Lows', overlay = true)

swingLen = input.int(5, 'Swing Length')

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow = na
var bool bullish = true

// Simple structure trend
if not na(ph)
    lastHigh := ph
    lastHigh

if not na(pl)
    lastLow := pl
    lastLow

if close > nz(lastHigh)
    bullish := true
    bullish

if close < nz(lastLow)
    bullish := false
    bullish

// Labels
if not na(ph)
    label.new(bar_index - swingLen, ph, bullish ? 'WH' : 'SH', style = label.style_label_down, color = bullish ? color.orange : color.red, textcolor = color.white)

if not na(pl)
    label.new(bar_index - swingLen, pl, bullish ? 'SL' : 'WL', style = label.style_label_up, color = bullish ? color.green : color.yellow, textcolor = color.black)
````
