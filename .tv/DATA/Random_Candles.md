<!-- tradingview-pine-id: PUB;dc6790f193664f1cb02f2db93b504ade -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Random Candles

Source: https://www.tradingview.com/script/w2kivT79-Random-Candles/

## Description

**What if the patterns you see in the market aren't as meaningful as you think?**

This indicator generates a completely random price series, tick by tick, and displays it as candles.

There is no market data being used to determine the direction of the next tick. There is no trend-following logic, no support/resistance calculation, no order flow, no indicators, and no hidden trading strategy deciding where price should go.

**The price is random.**

And yet, look at the chart.

You will often see things that look surprisingly familiar:

* Trends
* Support and resistance
* Breakouts
* Pullbacks
* Consolidation
* Higher highs and higher lows
* Lower highs and lower lows
* Reversals
* Channels
* Double tops and bottoms
* Candle patterns
* "Strong" moves followed by retracements

You can even draw trendlines and horizontal levels on a completely random chart and find that price appears to respect them.

That is the point of this experiment.

---

## Why does this matter?

As traders, we are extremely good at finding patterns in noisy data.

Give us a chart and our brains will naturally try to explain what happened:

*"Price rejected resistance."*

*"The trend is clearly bullish."*

*"This was a liquidity sweep."*

*"The breakout failed."*

*"The market is accumulating."*

*"The reversal was confirmed by the structure."*

But if a visually convincing version of these events can emerge from a process that contains **no market information whatsoever**, we should at least question how much information our eyes are actually extracting from a chart.

This doesn't prove that markets are completely random.

It does, however, demonstrate something important:

> **A pattern looking meaningful does not necessarily mean that the pattern contains predictive information.**

---

## Try it yourself

Instead of taking my word for it, put the indicator on a chart and watch it.

Change the **Resolution** input to increase the number of simulated ticks.

Then start looking for setups.

Draw your support and resistance levels.

Find your favorite candlestick patterns.

Look for trends.

Pretend you don't know that the candles are random.

You may find yourself doing exactly what you normally do on a real market.

That's the experiment.

---

## What this indicator is — and isn't

This is **not** a realistic market simulator.

It does not attempt to reproduce volatility distributions, correlations, order-book dynamics, news reactions, market microstructure, or other properties of real financial markets.

It is intentionally much simpler:

**Start from the previous close → randomly move up or down by one tick → repeat.**

The purpose is not to recreate the market.

The purpose is to create a visually convincing random price path and see how much structure our brains can find inside it.

---

## The uncomfortable question

If a completely random process can produce charts that look remarkably similar to real markets, how much of what we call a "setup" is actually predictive information...

...and how much is simply our brain finding structure in noise?

Maybe your strategy works.

Maybe there is a genuine edge.

Or maybe you have discovered a beautiful explanation for something that was going to happen anyway.

**Don't take this indicator as proof that trading strategies are useless.**

Use it as a reason to demand stronger evidence.

Backtest.

Out-of-sample test.

Forward test.

Test across different markets and regimes.

And most importantly, ask yourself:

**Does my strategy actually predict the future, or does it simply explain the past?**

---

*This indicator is an experiment in randomness, pattern recognition, and the limits of visual interpretation. If it makes you question your own chart analysis, then it has done its job.*

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © scourgeofgodx

//@version=6
indicator("Random Candles")

enum timezonesEnum
    los_angeles = "America/Los_Angeles"
    chicago = "America/Chicago"
    new_york = "America/New_York"
    london = "Europe/London"
    berlin = "Europe/Berlin"
    istanbul = "Europe/Istanbul"
    dubai = "Asia/Dubai"
    kolkata = "Asia/Kolkata"
    bangkok = "Asia/Bangkok"
    shanghai = "Asia/Shanghai"
    tokyo = "Asia/Tokyo"
    sydney = "Australia/Sydney"
    UTC_M12 = "UTC-12"
    UTC_M11 = "UTC-11"
    UTC_M10 = "UTC-10"
    UTC_M9  = "UTC-9"
    UTC_M8  = "UTC-8"
    UTC_M7  = "UTC-7"
    UTC_M6  = "UTC-6"
    UTC_M5  = "UTC-5"
    UTC_M4  = "UTC-4"
    UTC_M3  = "UTC-3"
    UTC_M2  = "UTC-2"
    UTC_M1  = "UTC-1"
    UTC_0   = "UTC"
    UTC_P1  = "UTC+1"
    UTC_P2  = "UTC+2"
    UTC_P3  = "UTC+3"
    UTC_P4  = "UTC+4"
    UTC_P5  = "UTC+5"
    UTC_P6  = "UTC+6"
    UTC_P7  = "UTC+7"
    UTC_P8  = "UTC+8"
    UTC_P9  = "UTC+9"
    UTC_P10 = "UTC+10"
    UTC_P11 = "UTC+11"
    UTC_P12 = "UTC+12"
    UTC_P13 = "UTC+13"
    UTC_P14 = "UTC+14"

var op = open
var hi = open
var lo = open
var cl = open

ticks = int(math.random(6, 18))
sh_ticks = int(math.random(300, 600))
h_ticks = int(math.random(50, 150))

res = input.int(10,"Resolution", tooltip = "This will increase the number of ticks being simulated, you can think of it as volume", minval = 1)
super_high_ses = input.session("0930-0945", "Super High Volume Session")
high_ses = input.session("0945-1630", "High Volume Session")
tmzone = input.enum(timezonesEnum.new_york, "Timezone")

sh_ses = not na(time(timeframe.period, super_high_ses, str.tostring(tmzone)))
h_ses = not na(time(timeframe.period, high_ses, str.tostring(tmzone)))

if sh_ses
    ticks := sh_ticks
else if h_ses
    ticks := h_ticks

timeframe_mult = timeframe.in_seconds(timeframe.period) / timeframe.in_seconds("1")
ticks := int(ticks*timeframe_mult)

ticks *= res

hi := cl[1]
lo := cl[1]

for i = 0 to ticks
    random_ = math.random(-1,1)
    if random_ > 0
        cl += syminfo.mintick
    else if random_ < 0
        cl -= syminfo.mintick

    hi := math.max(cl, hi)
    lo := math.min(cl, lo)

plotcandle(cl[1], hi, lo, cl, "Candle", cl > cl[1] ? color.teal : color.red, cl > cl[1] ? color.teal : color.red)
````
