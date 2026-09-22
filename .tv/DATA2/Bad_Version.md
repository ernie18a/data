<!-- tradingview-pine-id: PUB;d4c9e149941a49a4a05c041959b86c6e -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Bad Version

Source: https://www.tradingview.com/script/uuz1ddXA-HD-Volatility-Engine/

## Description

Heavy Diligence Volatility Engine — HDVE v1.0

HDVE is designed to help identify when momentum may be starting to change. It does not tell you to buy or sell. It gives you another layer of information so you know when something on the chart deserves more attention.

The easiest way to read it is by looking at the arrows. Pot Mom ↑ signals a potential upside momentum change, while Pot Mom ↓ signals a potential downside momentum change. When a second arrow appears — ↑↑ or ↓↓ — HDVE has also detected stronger recent volume participation. That’s all you need to know to start using it.

How to use HDVE

HDVE is not designed to make a trading decision by itself. It is meant to be another layer of information.

Here is how I would use the tool to help me make a decision:

If I am considering Calls and HDCE is showing multiple bullish signals pointing in the same direction, then HDVE produces a green Pot Mom, that supports the idea. If HDCE is showing bullish confluence but HDVE begins producing bearish Pot Moms, that conflict matters too. It may be enough to make me wait rather than force an entry.

The same applies once I am already in a trade. If I am in Calls and a red Pot Mom appears near resistance, that is not an automatic exit signal. It tells me to reassess the position. I may look at structure, VWAP, volume, HDCE, nearby support or resistance, and whether the original trade thesis is still intact.

Sometimes the most useful thing an indicator can tell you is not “take this trade.” Sometimes it is “not yet” or “something may be changing.”

How the Heavy Diligence tools work together

The tools are designed to answer different questions.

HDTL helps identify where important structural decision areas are.

HDCE helps evaluate whether enough signals are pointing in the same direction — directional confluence — to consider a trade.

HDVE helps identify whether momentum may be beginning to change.

In simple terms:

HDTL identifies the levels.
HDCE shows the combined directional signals.
HDVE points to potential changes in momentum.

That is where I believe the real value is. The tools are not meant to replace each other. They are designed to give you different types of information that can be viewed together.

Recent Volume Context

HDVE includes a Recent Volume Context feature because meaningful volume does not always appear on the exact candle where momentum changes.

Sometimes volume enters first, price consolidates, and the momentum shift appears later.

That is why the second arrow matters. It tells you the Pot Mom appeared with stronger recent participation behind it.

Conservative and Aggressive Modes

HDVE includes two modes.

Conservative is the recommended setting, especially for new users. It is designed to be more selective and produce fewer observations.

Aggressive allows earlier and more frequent observations. Before using Aggressive mode, I would strongly recommend going back through previous charts and reviewing how those additional signals behave.

HDVE v1.0 was designed and tested around the 3-minute chart using standard candlesticks.

Other timeframes and alternative candle types may behave differently and should not be assumed to produce the same results.

Final thought

The goal was never to build something that predicts the market.

The goal was:

Better information. Faster. Easier to understand.

Sometimes HDVE may help identify an opportunity. Sometimes it may help you avoid one. Sometimes it may tell you that an existing trade deserves another look.

The indicator provides information.

The trader still makes the decision.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © heavydiligence

//@version=6
indicator("Bad Version")
plot(close)
````
