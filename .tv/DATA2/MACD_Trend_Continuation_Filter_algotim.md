<!-- tradingview-pine-id: PUB;ac722662be0b42a89f7e423ede6eb4e0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# MACD Trend Continuation Filter [algotim]

Source: https://www.tradingview.com/script/kCOvQQAB-MACD-Trend-Continuation-Filter-algotim/

## Description

MACD Trend Continuation Signals with Trend Strength and Session Validation is a trend-following indicator designed to reduce false MACD crossover signals by requiring confirmation from market direction, trend strength, and trading session activity before generating a signal.

Instead of treating every MACD crossover equally, the indicator applies a sequential validation process so that signals are only produced when momentum develops in the direction of the prevailing trend during active market sessions.

Problem Statement
Standard MACD crossover strategies often generate numerous signals during ranging markets, weak trends, or periods of reduced market participation. While many of these crossovers satisfy the basic MACD conditions, they frequently lack the broader context needed to support a higher-probability continuation move.

This indicator addresses that issue by combining momentum, trend direction, trend strength, and session timing into a single validation workflow. The objective is not to increase the number of signals, but to improve their selectivity by filtering out conditions that commonly produce lower-quality entries.

Methodology
The indicator evaluates each setup through four consecutive validation stages.

Stage 1 – Momentum Trigger
The process begins with a traditional MACD crossover.
A bullish setup requires the MACD line to cross above the signal line while both remain below the zero line, indicating that bullish momentum is emerging from previously negative momentum.
A bearish setup requires the MACD line to cross below the signal line while both remain above the zero line, indicating weakening bullish momentum before potential downside continuation.

Stage 2 – Trend Direction
After a valid MACD crossover is detected, price location relative to the selected EMA determines the higher-level trend.
Long signals require price above the EMA.
Short signals require price below the EMA.
This prevents taking counter-trend MACD crossovers.

Stage 3 – Trend Strength
The indicator then evaluates ADX.
Signals are only accepted when ADX exceeds the user-defined threshold, indicating that directional movement has sufficient strength. When enabled, this filter attempts to reduce signals generated during low-volatility consolidation periods.

Stage 4 – Session Validation
Finally, signals are restricted to the selected trading sessions.

By default, only London and New York sessions are considered valid. These periods generally coincide with higher market participation and increased liquidity compared with quieter trading hours.

Only when all four stages agree is a signal plotted.

Signal Workflow
Bullish Signal
MACD crosses above its signal line.
MACD remains below zero.
Price trades above the EMA trend filter.
ADX exceeds the minimum strength threshold (optional).
The current bar occurs during an enabled trading session (optional).
A bullish signal is displayed.

Bearish Signal
MACD crosses below its signal line.
MACD remains above zero.
Price trades below the EMA trend filter.
ADX exceeds the minimum strength threshold (optional).
The current bar occurs during an enabled trading session (optional).
A bearish signal is displayed.

Why This Indicator Is Different
Many MACD-based scripts generate signals immediately after every crossover.

This indicator instead applies a layered validation process where each filter serves a distinct analytical purpose:
MACD identifies the momentum shift.
The EMA confirms the broader directional bias.
ADX measures whether the market is exhibiting sufficient directional strength.
The session filter limits signals to predefined periods of higher market activity.

Rather than operating as independent indicators displayed together, these components form a sequential decision process where each stage must validate the previous one before a signal is produced.

Inputs
The indicator allows customization of:
MACD fast, slow, and signal periods
EMA length
ADX length
Minimum ADX threshold
London session
New York session
Enable/disable ADX filtering
Enable/disable session filtering

Alerts
Built-in alert conditions include:
Bullish Signal
Bearish Signal
Alerts trigger only after all enabled validation stages have been satisfied.

Practical Usage
The indicator is intended for traders who prefer trading with the prevailing market direction rather than reacting to every MACD crossover.
Because multiple filters must align, signal frequency is intentionally lower than a standard MACD indicator. Traders may use the signals alongside their own price action analysis, support and resistance levels, or risk management rules.

Limitations
Signals are generated only after bar confirmation.
Strong trends may still produce losing trades during rapid market reversals.
Session filtering may exclude valid opportunities occurring outside the selected trading hours.
ADX measures trend strength but does not indicate future price direction.
The indicator is designed as a confirmation tool and should not be relied upon as the sole basis for trading decisions.

Notes
This script is intended for educational and analytical purposes. It visualizes a structured validation process that combines momentum, trend direction, trend strength, and trading session timing into a single signal-generation workflow. As with any technical indicator, outputs should be evaluated within a broader trading plan that includes appropriate risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © algotim

//@version=6
indicator('MACD Trend Continuation Filter [algotim]', overlay = true)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
fastLength   = input.int(12, "MACD Fast Length")
slowLength   = input.int(26, "MACD Slow Length")
signalLength = input.int(9, "MACD Signal Length")

emaLength = input.int(200, "EMA Length")

// Session Filter
useSessionFilter = input.bool(true, "Use Session Filter")

londonSession  = input.session("0800-1700", "London Session (UTC)")
newYorkSession = input.session("1300-2200", "New York Session (UTC)")

// ADX Filter
useADX = input.bool(true, "Use ADX Filter")
adxLength = input.int(14, "ADX Length")
adxThreshold = input.float(20.0, "ADX Threshold", step=0.1)

//━━━━━━━━━━━━━━━━━━━
// EMA TREND FILTER
//━━━━━━━━━━━━━━━━━━━
ema200 = ta.ema(close, emaLength)

plot(
     ema200,
     title="200 EMA",
     color=color.orange,
     linewidth=2)

//━━━━━━━━━━━━━━━━━━━
// MACD CALCULATION
//━━━━━━━━━━━━━━━━━━━
[macdLine, signalLine, histLine] =
     ta.macd(close, fastLength, slowLength, signalLength)

//━━━━━━━━━━━━━━━━━━━
// ADX FILTER
//━━━━━━━━━━━━━━━━━━━
[plusDI, minusDI, adxValue] =
     ta.dmi(adxLength, adxLength)

adxFilter =
     not useADX or adxValue > adxThreshold

//━━━━━━━━━━━━━━━━━━━
// SESSION FILTER
//━━━━━━━━━━━━━━━━━━━
inLondon =
     not na(time(timeframe.period, londonSession, "UTC"))

inNewYork =
     not na(time(timeframe.period, newYorkSession, "UTC"))

sessionFilter =
     not useSessionFilter or (inLondon or inNewYork)

//━━━━━━━━━━━━━━━━━━━
// BULLISH / BEARISH CONDITIONS
//━━━━━━━━━━━━━━━━━━━

// Bullish signal when:
// 1. MACD crosses above Signal
// 2. MACD is below zero
// 3. Price is above EMA trend filter
// 4. Session filter passes
// 5. ADX confirms trend strength
bullishSignal =
     ta.crossover(macdLine, signalLine) and
     macdLine < 0 and
     close > ema200 and
     sessionFilter and
     adxFilter

// Bearish signal when:
// 1. MACD crosses below Signal
// 2. MACD is above zero
// 3. Price is below EMA trend filter
// 4. Session filter passes
// 5. ADX confirms trend strength
bearishSignal =
     ta.crossunder(macdLine, signalLine) and
     macdLine > 0 and
     close < ema200 and
     sessionFilter and
     adxFilter

//━━━━━━━━━━━━━━━━━━━
// SIGNAL PLOTS
//━━━━━━━━━━━━━━━━━━━
plotshape(
     bullishSignal,
     title="Bullish Signal",
     location=location.belowbar,
     style=shape.labelup,
     color=color.green,
     text="BULL",
     textcolor=color.white,
     size=size.small)

plotshape(
     bearishSignal,
     title="Bearish Signal",
     location=location.abovebar,
     style=shape.labeldown,
     color=color.red,
     text="BEAR",
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━━
// ALERT CONDITIONS
//━━━━━━━━━━━━━━━━━━━
alertcondition(
     bullishSignal,
     title="Bullish Signal Alert",
     message="Bullish Signal: MACD crossed above Signal below zero, price above EMA, session and ADX filters passed.")

alertcondition(
     bearishSignal,
     title="Bearish Signal Alert",
     message="Bearish Signal: MACD crossed below Signal above zero, price below EMA, session and ADX filters passed.")

//━━━━━━━━━━━━━━━━━━━
// SESSION HIGHLIGHT
//━━━━━━━━━━━━━━━━━━━
bgcolor(
     useSessionFilter and sessionFilter
     ? color.new(color.blue, 95)
     : na)

//━━━━━━━━━━━━━━━━━━━
// OPTIONAL ADX DISPLAY
//━━━━━━━━━━━━━━━━━━━
plot(
     useADX ? adxValue : na,
     title="ADX Value",
     color=color.gray,
     linewidth=1,
     display=display.none)
````
