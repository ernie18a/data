# Greer Leap - Self-Optimizing XGBoost Approx & Stats

- url: https://www.tradingview.com/script/Zxyltqya-Greer-Leap-Self-Optimizing-XGBoost-Approx-Stats/
- type: strategy
- pine_id: PUB;a84981c5f1b84f1abc3499021546a487
- version: 7.0

## Description

using the XGBoost for the competition as a test.
Only a test for the Leap competition

## Source Code

````pine
//@version=6
strategy("DEPRECATED - DO NOT USE", overlay=true)

// only trigger once on the very first bar
if bar_index == 0
    strategy.entry("DEMO", strategy.long)

// immediately close it on next bar
if bar_index == 1
    strategy.close("DEMO")

plot(na, display=display.none)
````
