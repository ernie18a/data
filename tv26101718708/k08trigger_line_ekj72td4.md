# K08-Trigger Line

- url: https://www.tradingview.com/script/ekj72Td4-K08-Trigger-Line/
- type: indicator
- pine_id: PUB;13541f7c630348b499d3558264a4212d
- version: 1.0

## Description

# K08 Trigger Line

K08 Trigger Line is a trend-following indicator that combines MACD momentum analysis with a dual Trigger Line system to help identify trend direction and potential entry signals.

### Features

* Built-in MACD momentum engine.
* Dual Trigger Lines (TL1 and TL2).
* Dynamic trend cloud between TL1 and TL2.
* Visual trend confirmation using color changes.
* Buy and sell signal detection based on Trigger Line crossovers.
* Fully customizable parameters.

### How It Works

#### Trigger Line System

* TL1 represents the faster trend response.
* TL2 represents the slower trend response.
* When TL1 crosses above TL2, the market is considered bullish.
* When TL1 crosses below TL2, the market is considered bearish.

#### Trend Cloud

* Green cloud indicates bullish market conditions.
* Red cloud indicates bearish market conditions.
* Cloud color changes automatically when trend direction changes.

#### MACD Confirmation

The integrated MACD module can be used as an additional momentum filter:

* Bullish crossover supports long opportunities.
* Bearish crossover supports short opportunities.
* Combining MACD with Trigger Line signals helps reduce false entries.

### Suggested Usage

Buy Setup:

* TL1 crosses above TL2.
* Green trend cloud appears.
* MACD confirms bullish momentum.

Sell Setup:

* TL1 crosses below TL2.
* Red trend cloud appears.
* MACD confirms bearish momentum.

### Inputs

MACD Settings:

* Fast Average
* Slow Average
* Signal Average

Trigger Line Settings:

* TL1 Period
* TL2 Period
* Bullish Color
* Bearish Color

This indicator is designed to help traders identify trend changes, momentum shifts, and higher-probability trading opportunities using a simple visual framework.

## Source Code

````pine
//@version=6
indicator("K08-Trigger Line", shorttitle="Thinh Trần Trigger Line K08", overlay=true)

// MODULE 1: MACD
//==============================================================================
macd_group = "MACD"
r1 = input.int(12, "Fast avg", minval=2, maxval=200, group=macd_group)
r2 = input.int(26, "Slow avg", minval=2, maxval=200, group=macd_group)
r3 = input.int(9, "Signal avg", minval=2, maxval=200, group=macd_group)

[ml, sl, _] = ta.macd(close, r1, r2, r3)
muaMACD = ta.crossover(ml, sl)
banMACD = ta.crossunder(ml, sl)

// MODULE 2: TRIGGER INDICATOR (TL)
//==============================================================================
trigger_group = "Trigger Indicator (TL)"
p1 = input.int(20, "TL1 Periods", minval=5, maxval=50, group=trigger_group)
p2 = input.int(5, "TL2 Periods", minval=3, maxval=25, group=trigger_group)
tl_up_color = input.color(color.new(color.green, 0), "TL Up Colour", group=trigger_group)
tl_dn_color = input.color(color.new(color.red, 0), "TL Dn Colour", group=trigger_group)

tl1 = ta.linreg(close, p1,0)
tl2 = ta.ema(tl1, p2)
col1 = tl1 > tl2 ? tl_up_color : tl_dn_color

p_tl1 = plot(tl1, "TriggerLine 1", color=col1, linewidth=2)
p_tl2 = plot(tl2, "TriggerLine 2", color=col1, linewidth=1)
fill(p_tl1, p_tl2, color=color.new(col1, 80), title="Trigger Cloud")

buy_trigger = ta.crossover(tl1, tl2)
sell_trigger = ta.crossunder(tl1, tl2)
````
