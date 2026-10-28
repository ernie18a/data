# Triple RSI  Stochastic Hybrid MTF  Smooth

- url: https://www.tradingview.com/script/VEYlsnq8/
- type: indicator
- pine_id: PUB;372c8308bffb45e1b86448d7e1b8a12b
- version: 1.0

## Description

# Triple RSI + Stochastic Hybrid MTF — Smooth

## Overview

Triple RSI + Stochastic Hybrid MTF — Smooth is a multi-timeframe momentum oscillator designed to combine RSI and Stochastic information into a single adaptive Hybrid line.

The indicator displays up to three independent Hybrid oscillators:

* Hybrid 1 — Chart timeframe
* Hybrid 2 — Higher timeframe x5
* Hybrid 3 — Higher timeframe x15

Each Hybrid combines RSI and Stochastic momentum into one normalized 0–100 oscillator. Each Hybrid has its own independently configurable RSI length, Stochastic length, %K smoothing, RSI weighting, signal length, signal smoothing, signal method, timeframe, and MTF smoothing settings.

The goal is to make short-term momentum and higher-timeframe momentum visible in the same oscillator pane.

---

## What Does the Indicator Show?

The indicator displays three possible Hybrid momentum lines.

### Hybrid 1 — Chart Timeframe

Hybrid 1 is calculated on the selected chart timeframe.

It combines:

* RSI
* Stochastic price position
* Stochastic %K smoothing
* Adjustable RSI/Stochastic weighting

The default configuration is:

* RSI Length: 9
* Stochastic Length: 9
* %K Smoothing: 3
* RSI Weight: 50%

This means the Hybrid is initially composed of approximately 50% RSI and 50% Stochastic information.

The timeframe can be set independently through the Hybrid 1 timeframe input.

---

### Hybrid 2 — Higher Timeframe

Hybrid 2 retrieves the Hybrid calculation from a selectable higher timeframe using TradingView's `request.security()` mechanism.

The default timeframe is 5 minutes.

The resulting higher-timeframe Hybrid is then smoothed using the configurable MTF smoothing settings.

Default:

* Timeframe: 5 minutes
* RSI Length: 9
* Stochastic Length: 9
* %K Smoothing: 3
* RSI Weight: 50%
* MTF Smooth: 5
* MTF Smooth Method: EMA

This provides a higher-timeframe momentum reference without requiring a separate oscillator pane.

---

### Hybrid 3 — Higher Timeframe

Hybrid 3 works in the same way as Hybrid 2 but uses a higher timeframe.

The default timeframe is 15 minutes.

Default:

* Timeframe: 15 minutes
* RSI Length: 9
* Stochastic Length: 9
* %K Smoothing: 3
* RSI Weight: 50%
* MTF Smooth: 8
* MTF Smooth Method: EMA

Hybrid 3 is intended to provide a slower and broader momentum reference.

---

# How the Hybrid Is Calculated

The Hybrid is not a simple RSI and not a standard Stochastic.

First, an RSI value is calculated:

RSI = Relative Strength Index of the selected source.

A Stochastic component is then calculated from the selected source relative to the highest high and lowest low over the selected Stochastic length.

The Stochastic component is smoothed using the selected %K smoothing length.

The final Hybrid value is a weighted combination of the two:

Hybrid = RSI × RSI Weight + Stochastic × (1 − RSI Weight)

The RSI Weight input determines the balance between the two components.

For example:

* 100% RSI = RSI-dominant Hybrid
* 75% RSI = mostly RSI
* 50% RSI = balanced RSI/Stochastic Hybrid
* 25% RSI = mostly Stochastic
* 0% RSI = Stochastic-dominant Hybrid

This allows the oscillator to be adapted from a more RSI-oriented momentum tool to a more Stochastic-oriented momentum tool.

---

# Signal Lines

Each Hybrid has its own Signal line.

The Signal line is calculated from the corresponding Hybrid and can use:

* EMA
* SMA
* WMA
* RMA

Signal length and additional Signal smoothing can be adjusted independently for each Hybrid.

The Signal line acts as a momentum reference for the corresponding Hybrid.

A faster Signal setting produces more responsive crosses.

A slower Signal setting produces fewer but generally smoother crossings.

---

# Cross Dots

The colored dots identify crossings between a Hybrid line and its corresponding Signal line.

### Green / Bullish Dot

A bullish dot appears when the Hybrid moves from below or equal to the Signal line to above it.

This indicates that momentum has crossed upward relative to its Signal line.

### Red / Bearish Dot

A bearish dot appears when the Hybrid moves from above or equal to the Signal line to below it.

This indicates that momentum has crossed downward relative to its Signal line.

The cross detection is based directly on the difference between the Hybrid and Signal series:

Hybrid − Signal

A bullish cross occurs when this difference changes from zero/negative to positive.

A bearish cross occurs when the difference changes from zero/positive to negative.

The dots therefore respond directly to the current Hybrid and Signal settings.

---

# Momentum Levels

The oscillator uses a normalized 0–100 scale.

The default levels are:

* 0 — Extreme lower boundary
* 10 — Lower reference
* 30 — Oversold reference
* 50 — Midline / neutral reference
* 70 — Overbought reference
* 90 — Upper reference
* 100 — Extreme upper boundary

All levels are independently adjustable.

The 50 level can be used as the primary momentum balance line.

Above 50 generally means that the Hybrid is showing positive momentum.

Below 50 generally means that the Hybrid is showing negative momentum.

The 30 and 70 levels can be used as traditional oversold/overbought references.

The 10 and 90 levels provide additional extreme-zone information.

---

# How to Read the Three Hybrids Together

The main purpose of the three Hybrid lines is to compare momentum across different timeframes.

A simple interpretation is:

### Bullish Momentum Alignment

When:

* Hybrid 1 is above its Signal
* Hybrid 2 is above its Signal
* Hybrid 3 is above its Signal

momentum is aligned positively across the three selected timeframes.

This can be used as confirmation for long setups.

### Bearish Momentum Alignment

When:

* Hybrid 1 is below its Signal
* Hybrid 2 is below its Signal
* Hybrid 3 is below its Signal

momentum is aligned negatively across the three selected timeframes.

This can be used as confirmation for short setups.

### Pullback Environment

A common use is to wait for the higher-timeframe Hybrids to maintain their direction while the lower-timeframe Hybrid temporarily moves against them.

For example:

Higher timeframes remain bullish:

* Hybrid 3 > Signal 3
* Hybrid 2 > Signal 2

while Hybrid 1 temporarily falls below Signal 1.

If Hybrid 1 then crosses back above Signal 1, the cross can be interpreted as a potential momentum re-entry trigger in the direction of the higher-timeframe momentum.

The opposite logic can be applied for short setups.

---

# Example Long Setup

One possible momentum-based workflow:

1. Check Hybrid 3 for the broader momentum direction.
2. Check Hybrid 2 for intermediate momentum confirmation.
3. Prefer long setups when both higher-timeframe Hybrids are above their Signals.
4. Wait for Hybrid 1 to pull back.
5. Look for Hybrid 1 to cross back above Signal 1.
6. A green Hybrid 1 cross dot marks the momentum crossover.
7. Additional confirmation can come from the 50 level or from price structure.
8. The actual trade entry, stop loss and position size should be determined using the trader's own risk-management rules.

The indicator itself does not place trades.

---

# Example Short Setup

The inverse workflow can be used for short setups:

1. Check Hybrid 3 for broader bearish momentum.
2. Check Hybrid 2 for intermediate bearish momentum.
3. Prefer short setups when both higher-timeframe Hybrids are below their Signals.
4. Wait for Hybrid 1 to rally against the higher-timeframe direction.
5. Look for Hybrid 1 to cross back below Signal 1.
6. A red Hybrid 1 cross dot marks the bearish momentum crossover.
7. Additional confirmation can come from the 50 level or price structure.
8. Apply independent risk-management rules before entering a trade.

---

# Using the 50 Level

The 50 level can be used as a neutral momentum filter.

### Above 50

The Hybrid is in the upper half of its normalized range.

This can support a bullish momentum interpretation, particularly when the Hybrid is also above its Signal.

### Below 50

The Hybrid is in the lower half of its normalized range.

This can support a bearish momentum interpretation, particularly when the Hybrid is also below its Signal.

A stronger momentum condition can therefore be defined by combining:

Direction + Signal Cross + 50-Level Position.

For example:

Bullish:

Hybrid > Signal and Hybrid > 50

Bearish:

Hybrid < Signal and Hybrid < 50

This is a confirmation framework, not a guaranteed trading signal.

---

# Using the 30 and 70 Levels

The 30 and 70 levels provide additional momentum context.

A move below 30 can indicate that momentum has entered a relatively weak or oversold area.

A move above 70 can indicate that momentum has entered a relatively strong or overbought area.

These levels should not automatically be interpreted as reversal signals.

A strong trend can remain above 70 or below 30 for an extended period.

Therefore, the direction of the Hybrid, its Signal relationship, and the higher-timeframe Hybrids should be considered together.

---

# Recommended Multi-Timeframe Workflow

For short-term trading, a practical configuration is:

Chart timeframe:
1 minute

Hybrid 1:
1 minute

Hybrid 2:
5 minutes

Hybrid 3:
15 minutes

This creates a three-layer momentum structure:

1-minute = execution momentum

5-minute = intermediate momentum

15-minute = higher-timeframe momentum

The lower timeframe can be used for timing while the higher timeframes provide directional context.

For example:

15M bullish → 5M bullish → wait for 1M pullback → 1M bullish Signal cross → potential long setup.

The inverse can be used for short setups.

---

# What Information Does the Indicator Use?

The indicator primarily uses price-derived information.

The Hybrid calculation uses:

* Selected price source
* RSI
* Highest high over the Stochastic lookback
* Lowest low over the Stochastic lookback
* Stochastic calculation
* Stochastic smoothing
* RSI/Stochastic weighting

The Signal calculation uses the resulting Hybrid series.

The MTF versions retrieve the Hybrid calculation from their selected higher timeframe using TradingView's `request.security()` functionality.

The indicator does not directly use:

* Order flow
* Level 2 data
* Bid/ask volume
* Market profile
* Fundamental data
* News
* Economic calendar data
* Open interest
* Institutional positioning

It is a price-derived momentum oscillator.

---

# What the Indicator Is Designed For

This indicator is designed primarily for:

* Momentum analysis
* Multi-timeframe momentum comparison
* Pullback identification
* Momentum crossover timing
* Trend-direction confirmation
* Short-term and intraday trading analysis

It can be used on different markets and timeframes, but parameter optimization should be performed for the specific instrument and trading timeframe.

---

# Important Interpretation

A cross dot does not automatically mean "buy" or "sell."

A bullish cross means that the Hybrid has crossed above its Signal.

A bearish cross means that the Hybrid has crossed below its Signal.

The quality of a setup depends on the surrounding market structure, timeframe alignment, volatility, trend conditions and risk management.

A stronger approach is to treat the dots as momentum timing information rather than standalone trade signals.

---

# Example Confirmation Framework

### Long Bias

Prefer long setups when:

* Hybrid 3 > Signal 3
* Hybrid 2 > Signal 2
* Price structure supports an upside move
* Hybrid 1 pulls back
* Hybrid 1 crosses back above Signal 1
* Hybrid 1 is preferably above or recovering through 50

### Short Bias

Prefer short setups when:

* Hybrid 3 < Signal 3
* Hybrid 2 < Signal 2
* Price structure supports a downside move
* Hybrid 1 rallies into the pullback
* Hybrid 1 crosses back below Signal 1
* Hybrid 1 is preferably below or falling through 50

This approach uses the higher-timeframe Hybrids for directional context and the lower-timeframe Hybrid for timing.

---

# Important Limitations

This indicator is an analytical tool and does not predict future prices with certainty.

Higher-timeframe values are obtained using TradingView's multi-timeframe data functionality. The behavior of higher-timeframe values can differ from lower-timeframe calculations, particularly while the higher-timeframe candle is still forming.

Cross dots represent mathematical momentum crossings. They are not guaranteed entry signals and should not be interpreted as guaranteed profitable trades.

No indicator can eliminate market risk.

Always evaluate price structure, volatility, liquidity, spread, execution conditions and position sizing before entering a trade.

---

## Summary

Triple RSI + Stochastic Hybrid MTF — Smooth combines RSI and Stochastic momentum into three configurable multi-timeframe Hybrid oscillators.

The core concept is:

**Higher Timeframe Direction → Lower Timeframe Pullback → Signal Cross → Momentum Confirmation**

Hybrid 3 provides the broadest momentum context.

Hybrid 2 provides intermediate momentum context.

Hybrid 1 provides the most responsive momentum information for timing.

The colored cross dots identify changes in the relationship between each Hybrid and its Signal line.

The 50 level provides a neutral momentum reference, while the 30/70 and 10/90 levels provide additional context for weak, strong and extreme momentum conditions.

The indicator is intended to support discretionary technical analysis, not to function as an autonomous trading system.

## Source Code

````pine
//@version=6
indicator("Triple RSI + Stochastic Hybrid MTF — Smooth", "Triple RSI+Stoch Smooth", overlay=false, max_labels_count=500)

//══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
//══════════════════════════════════════════════════════════════════════════════

// RSI + Stochastic Hybrid
f_hybrid(src, rsiLen, stochLen, kSmooth, rsiWeight) =>
    rsiValue = ta.rsi(src, rsiLen)
    lowestLow = ta.lowest(low, stochLen)
    highestHigh = ta.highest(high, stochLen)

    rawStoch = highestHigh != lowestLow ?
         100.0 * (src - lowestLow) / (highestHigh - lowestLow) :
         50.0

    stochK = ta.sma(rawStoch, kSmooth)

    rsiValue * rsiWeight + stochK * (1.0 - rsiWeight)


// Signal
f_signal(src, length, smoothing, method) =>
    base = switch method
        "EMA" => ta.ema(src, length)
        "SMA" => ta.sma(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        => ta.ema(src, length)

    smoothing > 1 ? ta.ema(base, smoothing) : base


// MTF smoothing
f_smooth(src, length, method) =>
    switch method
        "EMA" => ta.ema(src, length)
        "SMA" => ta.sma(src, length)
        "WMA" => ta.wma(src, length)
        "RMA" => ta.rma(src, length)
        "HMA" => ta.hma(src, length)
        => ta.ema(src, length)


//══════════════════════════════════════════════════════════════════════════════
// GENERAL SETTINGS
//══════════════════════════════════════════════════════════════════════════════

grpGeneral = "════════ GENERAL ════════"

src = input.source(close, "Source", group=grpGeneral)

showLevels = input.bool(
     true,
     "Show Levels",
     group=grpGeneral)


//══════════════════════════════════════════════════════════════════════════════
// LEVEL VALUES
//══════════════════════════════════════════════════════════════════════════════

level50 = input.float(
     50.0,
     "50 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)

level30 = input.float(
     30.0,
     "30 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)

level70 = input.float(
     70.0,
     "70 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)

plus40 = input.float(
     90.0,
     "+40 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)

plus80 = input.float(
     100.0,
     "+80 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)

minus40 = input.float(
     10.0,
     "-40 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)

minus80 = input.float(
     0.0,
     "-80 Level",
     minval=0.0,
     maxval=100.0,
     step=0.5,
     group=grpGeneral)


//══════════════════════════════════════════════════════════════════════════════
// LEVEL COLORS
//══════════════════════════════════════════════════════════════════════════════

level50Color = input.color(
     color.gray,
     "50 Color",
     group=grpGeneral)

level30Color = input.color(
     color.orange,
     "30 Color",
     group=grpGeneral)

level70Color = input.color(
     color.orange,
     "70 Color",
     group=grpGeneral)

plus40Color = input.color(
     color.orange,
     "+40 Color",
     group=grpGeneral)

plus80Color = input.color(
     color.red,
     "+80 Color",
     group=grpGeneral)

minus40Color = input.color(
     color.orange,
     "-40 Color",
     group=grpGeneral)

minus80Color = input.color(
     color.red,
     "-80 Color",
     group=grpGeneral)

levelWidth = input.int(
     1,
     "Level Width",
     minval=1,
     maxval=4,
     group=grpGeneral)


//══════════════════════════════════════════════════════════════════════════════
// HYBRID 1 — CHART
//══════════════════════════════════════════════════════════════════════════════

grp1 = "════════ HYBRID 1 — CHART ════════"

enable1 = input.bool(
     true,
     "Enable Hybrid 1",
     group=grp1)

tf1 = input.timeframe(
     "",
     "Timeframe",
     group=grp1)

rsiLen1 = input.int(
     9,
     "RSI Length",
     minval=1,
     group=grp1)

stochLen1 = input.int(
     9,
     "Stochastic Length",
     minval=1,
     group=grp1)

kSmooth1 = input.int(
     3,
     "Stochastic %K Smoothing",
     minval=1,
     group=grp1)

rsiWeight1 = input.float(
     50.0,
     "RSI Weight %",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=grp1)

signalLen1 = input.int(
     3,
     "Signal Length",
     minval=1,
     group=grp1)

signalSmooth1 = input.int(
     1,
     "Signal Smoothing",
     minval=1,
     group=grp1)

signalMethod1 = input.string(
     "EMA",
     "Signal Method",
     options=["EMA", "SMA", "WMA", "RMA"],
     group=grp1)

show1 = input.bool(
     true,
     "Show Hybrid 1",
     group=grp1)

showSignal1 = input.bool(
     true,
     "Show Signal 1",
     group=grp1)

showDots1 = input.bool(
     true,
     "Show Cross Dots 1",
     group=grp1)

hybrid1Color = input.color(
     color.aqua,
     "Hybrid 1 Color",
     group=grp1)

signal1Color = input.color(
     color.white,
     "Signal 1 Color",
     group=grp1)

bullDot1Color = input.color(
     color.lime,
     "Bull Cross Dot",
     group=grp1)

bearDot1Color = input.color(
     color.red,
     "Bear Cross Dot",
     group=grp1)


//──────────────────────────────────────────────────────────────────────────────
// HYBRID 1 CALCULATION
//──────────────────────────────────────────────────────────────────────────────

hybrid1 = f_hybrid(
     src,
     rsiLen1,
     stochLen1,
     kSmooth1,
     rsiWeight1 / 100.0)

signal1 = f_signal(
     hybrid1,
     signalLen1,
     signalSmooth1,
     signalMethod1)


// DIREKTE DIFFERENZ ZWISCHEN DEN SICHTBAREN LINIEN
diff1 = hybrid1 - signal1

// DIREKTER VORZEICHENWECHSEL
crossUp1 = diff1 > 0 and diff1[1] <= 0
crossDown1 = diff1 < 0 and diff1[1] >= 0

// Kreuzungspunkt der beiden sichtbaren Linien
crossPoint1 = hybrid1


//══════════════════════════════════════════════════════════════════════════════
// HYBRID 2 — x5
//══════════════════════════════════════════════════════════════════════════════

grp2 = "════════ HYBRID 2 — x5 ════════"

enable2 = input.bool(
     true,
     "Enable Hybrid 2",
     group=grp2)

tf2 = input.timeframe(
     "5",
     "Timeframe",
     group=grp2)

rsiLen2 = input.int(
     9,
     "RSI Length",
     minval=1,
     group=grp2)

stochLen2 = input.int(
     9,
     "Stochastic Length",
     minval=1,
     group=grp2)

kSmooth2 = input.int(
     3,
     "Stochastic %K Smoothing",
     minval=1,
     group=grp2)

rsiWeight2 = input.float(
     50.0,
     "RSI Weight %",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=grp2)

signalLen2 = input.int(
     3,
     "Signal Length",
     minval=1,
     group=grp2)

signalSmooth2 = input.int(
     1,
     "Signal Smoothing",
     minval=1,
     group=grp2)

signalMethod2 = input.string(
     "EMA",
     "Signal Method",
     options=["EMA", "SMA", "WMA", "RMA"],
     group=grp2)

mtfSmooth2 = input.int(
     5,
     "MTF Smooth",
     minval=1,
     maxval=100,
     group=grp2)

mtfSmoothMethod2 = input.string(
     "EMA",
     "MTF Smooth Method",
     options=["EMA", "SMA", "WMA", "RMA", "HMA"],
     group=grp2)

show2 = input.bool(
     true,
     "Show Hybrid 2",
     group=grp2)

showSignal2 = input.bool(
     true,
     "Show Signal 2",
     group=grp2)

showDots2 = input.bool(
     true,
     "Show Cross Dots 2",
     group=grp2)

hybrid2Color = input.color(
     color.yellow,
     "Hybrid 2 Color",
     group=grp2)

signal2Color = input.color(
     color.orange,
     "Signal 2 Color",
     group=grp2)

bullDot2Color = input.color(
     color.lime,
     "Bull Cross Dot",
     group=grp2)

bearDot2Color = input.color(
     color.red,
     "Bear Cross Dot",
     group=grp2)


//──────────────────────────────────────────────────────────────────────────────
// HYBRID 2 CALCULATION
//──────────────────────────────────────────────────────────────────────────────

hybrid2Raw = request.security(
     syminfo.tickerid,
     tf2,
     f_hybrid(
         src,
         rsiLen2,
         stochLen2,
         kSmooth2,
         rsiWeight2 / 100.0),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

hybrid2 = f_smooth(
     hybrid2Raw,
     mtfSmooth2,
     mtfSmoothMethod2)

signal2 = f_signal(
     hybrid2,
     signalLen2,
     signalSmooth2,
     signalMethod2)


// DIREKTE DIFFERENZ
diff2 = hybrid2 - signal2

// DIREKTER VORZEICHENWECHSEL
crossUp2 = diff2 > 0 and diff2[1] <= 0
crossDown2 = diff2 < 0 and diff2[1] >= 0

// Kreuzungspunkt
crossPoint2 = hybrid2


//══════════════════════════════════════════════════════════════════════════════
// HYBRID 3 — x15
//══════════════════════════════════════════════════════════════════════════════

grp3 = "════════ HYBRID 3 — x15 ════════"

enable3 = input.bool(
     true,
     "Enable Hybrid 3",
     group=grp3)

tf3 = input.timeframe(
     "15",
     "Timeframe",
     group=grp3)

rsiLen3 = input.int(
     9,
     "RSI Length",
     minval=1,
     group=grp3)

stochLen3 = input.int(
     9,
     "Stochastic Length",
     minval=1,
     group=grp3)

kSmooth3 = input.int(
     3,
     "Stochastic %K Smoothing",
     minval=1,
     group=grp3)

rsiWeight3 = input.float(
     50.0,
     "RSI Weight %",
     minval=0.0,
     maxval=100.0,
     step=5.0,
     group=grp3)

signalLen3 = input.int(
     3,
     "Signal Length",
     minval=1,
     group=grp3)

signalSmooth3 = input.int(
     1,
     "Signal Smoothing",
     minval=1,
     group=grp3)

signalMethod3 = input.string(
     "EMA",
     "Signal Method",
     options=["EMA", "SMA", "WMA", "RMA"],
     group=grp3)

mtfSmooth3 = input.int(
     8,
     "MTF Smooth",
     minval=1,
     maxval=100,
     group=grp3)

mtfSmoothMethod3 = input.string(
     "EMA",
     "MTF Smooth Method",
     options=["EMA", "SMA", "WMA", "RMA", "HMA"],
     group=grp3)

show3 = input.bool(
     true,
     "Show Hybrid 3",
     group=grp3)

showSignal3 = input.bool(
     true,
     "Show Signal 3",
     group=grp3)

showDots3 = input.bool(
     true,
     "Show Cross Dots 3",
     group=grp3)

hybrid3Color = input.color(
     color.fuchsia,
     "Hybrid 3 Color",
     group=grp3)

signal3Color = input.color(
     color.blue,
     "Signal 3 Color",
     group=grp3)

bullDot3Color = input.color(
     color.lime,
     "Bull Cross Dot",
     group=grp3)

bearDot3Color = input.color(
     color.red,
     "Bear Cross Dot",
     group=grp3)


//──────────────────────────────────────────────────────────────────────────────
// HYBRID 3 CALCULATION
//──────────────────────────────────────────────────────────────────────────────

hybrid3Raw = request.security(
     syminfo.tickerid,
     tf3,
     f_hybrid(
         src,
         rsiLen3,
         stochLen3,
         kSmooth3,
         rsiWeight3 / 100.0),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

hybrid3 = f_smooth(
     hybrid3Raw,
     mtfSmooth3,
     mtfSmoothMethod3)

signal3 = f_signal(
     hybrid3,
     signalLen3,
     signalSmooth3,
     signalMethod3)


// DIREKTE DIFFERENZ
diff3 = hybrid3 - signal3

// DIREKTER VORZEICHENWECHSEL
crossUp3 = diff3 > 0 and diff3[1] <= 0
crossDown3 = diff3 < 0 and diff3[1] >= 0

// Kreuzungspunkt
crossPoint3 = hybrid3


//══════════════════════════════════════════════════════════════════════════════
// LEVELS
//══════════════════════════════════════════════════════════════════════════════

plot(
     showLevels ? plus80 : na,
     title="+80",
     color=plus80Color,
     linewidth=levelWidth)

plot(
     showLevels ? plus40 : na,
     title="+40",
     color=plus40Color,
     linewidth=levelWidth)

plot(
     showLevels ? level70 : na,
     title="70",
     color=level70Color,
     linewidth=levelWidth)

plot(
     showLevels ? level50 : na,
     title="50",
     color=level50Color,
     linewidth=levelWidth)

plot(
     showLevels ? level30 : na,
     title="30",
     color=level30Color,
     linewidth=levelWidth)

plot(
     showLevels ? minus40 : na,
     title="-40",
     color=minus40Color,
     linewidth=levelWidth)

plot(
     showLevels ? minus80 : na,
     title="-80",
     color=minus80Color,
     linewidth=levelWidth)


//══════════════════════════════════════════════════════════════════════════════
// HYBRID 1 PLOTS
//══════════════════════════════════════════════════════════════════════════════

plot(
     enable1 and show1 ? hybrid1 : na,
     title="Hybrid 1",
     color=hybrid1Color,
     linewidth=2)

plot(
     enable1 and showSignal1 ? signal1 : na,
     title="Signal 1",
     color=signal1Color,
     linewidth=1)


//══════════════════════════════════════════════════════════════════════════════
// HYBRID 2 PLOTS
//══════════════════════════════════════════════════════════════════════════════

plot(
     enable2 and show2 ? hybrid2 : na,
     title="Hybrid 2",
     color=hybrid2Color,
     linewidth=2)

plot(
     enable2 and showSignal2 ? signal2 : na,
     title="Signal 2",
     color=signal2Color,
     linewidth=1)


//══════════════════════════════════════════════════════════════════════════════
// HYBRID 3 PLOTS
//══════════════════════════════════════════════════════════════════════════════

plot(
     enable3 and show3 ? hybrid3 : na,
     title="Hybrid 3",
     color=hybrid3Color,
     linewidth=2)

plot(
     enable3 and showSignal3 ? signal3 : na,
     title="Signal 3",
     color=signal3Color,
     linewidth=1)


//══════════════════════════════════════════════════════════════════════════════
// CROSS DOTS — HYBRID 1
//══════════════════════════════════════════════════════════════════════════════

plot(
     enable1 and showDots1 and (crossUp1 or crossDown1) ?
         crossPoint1 :
         na,
     title="Hybrid 1 Cross Dots",
     style=plot.style_circles,
     linewidth=5,
     color=crossUp1 ? bullDot1Color : bearDot1Color)


//══════════════════════════════════════════════════════════════════════════════
// CROSS DOTS — HYBRID 2
//══════════════════════════════════════════════════════════════════════════════

plot(
     enable2 and showDots2 and (crossUp2 or crossDown2) ?
         crossPoint2 :
         na,
     title="Hybrid 2 Cross Dots",
     style=plot.style_circles,
     linewidth=5,
     color=crossUp2 ? bullDot2Color : bearDot2Color)


//══════════════════════════════════════════════════════════════════════════════
// CROSS DOTS — HYBRID 3
//══════════════════════════════════════════════════════════════════════════════

plot(
     enable3 and showDots3 and (crossUp3 or crossDown3) ?
         crossPoint3 :
         na,
     title="Hybrid 3 Cross Dots",
     style=plot.style_circles,
     linewidth=5,
     color=crossUp3 ? bullDot3Color : bearDot3Color)


//══════════════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════════════

alertcondition(
     enable1 and crossUp1,
     title="Hybrid 1 Bullish Cross",
     message="Hybrid 1 RSI/Stochastic bullish crossover")

alertcondition(
     enable1 and crossDown1,
     title="Hybrid 1 Bearish Cross",
     message="Hybrid 1 RSI/Stochastic bearish crossover")

alertcondition(
     enable2 and crossUp2,
     title="Hybrid 2 Bullish Cross",
     message="Hybrid 2 RSI/Stochastic bullish crossover")

alertcondition(
     enable2 and crossDown2,
     title="Hybrid 2 Bearish Cross",
     message="Hybrid 2 RSI/Stochastic bearish crossover")

alertcondition(
     enable3 and crossUp3,
     title="Hybrid 3 Bullish Cross",
     message="Hybrid 3 RSI/Stochastic bullish crossover")

alertcondition(
     enable3 and crossDown3,
     title="Hybrid 3 Bearish Cross",
     message="Hybrid 3 RSI/Stochastic bearish crossover")
````
