# Scalping Line Strategy

- url: https://www.tradingview.com/script/AO0ks8SJ-Scalping-Line-Strategy/
- type: strategy
- pine_id: PUB;2712731ae6204e71bc0c251902233c59
- version: 1.0

## Description

[b]📌 Scalping Line Strategy – A Precision Crossover System[/b]
[b]🔎 Overview[/b]
The Scalping Line Strategy is a short-term trading system built around the concept of momentum-driven crossovers between a smoothed moving average filter and a fast signal line. It is designed for scalpers and intraday traders who seek clear entry signals, minimal lag, and adaptive filtering to fit volatile market conditions.

At its core, the strategy uses a custom signal line ("Scalping Line"), which is derived from the difference between a double-smoothed moving average and a shorter-period signal line. Trade entries are triggered when this Scalping Line crosses above or below zero, providing a clean and rules-based framework for both long and short setups.

[b]⚙️ Core Logic[/b]
[b]Main Trend Filter[/b] – A double-smoothed moving average is calculated over a configurable period (default 100). This reduces noise and provides a more robust backbone for scalping signals.

[b]Percent-Based Filter[/b] – To avoid false signals, a customizable percentage filter adjusts how closely the system “respects” price deviations from the moving average. This helps filter out insignificant fluctuations.

[b]Signal Line[/b] – A shorter-period simple moving average (default 7) provides faster responsiveness to recent price action.

[b]Scalping Line (SLI)[/b] – Calculated as the difference between the fast signal line and the smoothed moving average. When the SLI crosses zero, it signals a potential momentum shift.

SLI > 0 → Momentum bias is bullish.

SLI < 0 → Momentum bias is bearish.

[b]🎯 Trade Direction & Flexibility[/b]
[b]Trade Direction Control:[/b]
Choose between Long Only, Short Only, or Both to tailor the system to your trading style.

[b]Signal Flip Option:[/b]
By default, long entries occur when the SLI crosses below zero, and shorts when it crosses above zero. This orientation can be flipped, allowing for alternative interpretations of the signals depending on how you want to capture momentum in your market.

[b]🕒 Time Window Filtering[/b]
For intraday traders, a time filter can be enabled to restrict signals to specific trading sessions (e.g., 9 AM – 4 PM EST). This is particularly useful when trading assets such as equities or futures that have strong intraday volatility windows.

[b]📈 Visuals & Clarity[/b]
[b]Scalping Line Plot: [/b]Displayed as a dynamic oscillator around a zero baseline.

[b]Histogram Fill: [/b]Green when above zero (bullish bias), red when below zero (bearish bias).

[b]Signal Markers:[/b] Clear arrows mark long and short entries at crossover points.

[b]Zero Line Reference: [/b]A flat gray line at zero assists in visually gauging momentum shifts.

[b]🚀 Strategy Execution[/b]
[b]Long Entry:[/b] Triggered when SLI crosses below zero (or above zero if flip is enabled) within allowed session hours.

[b]Short Entry:[/b] Triggered when SLI crosses above zero (or below zero if flip is enabled) within allowed session hours.

Built-in Signal Cancels: Pending entries are canceled if conditions are no longer valid, ensuring no stale trades remain active.

[b]✅ Best Use Cases[/b]
Markets: Works across equities, forex, crypto, and futures with sufficient intraday volatility.

[b]Timeframes:[/b] Most effective on 1m to 15m charts for scalping setups, but adaptable to higher frames for swing trading.

[b]Style: [/b]Traders who appreciate simple, rules-based momentum crossovers will find this system easy to follow and highly adaptable.

[b]⚠️ Risk Management Note[/b]
This strategy is strictly an entry signal framework. Position sizing, stop-loss, and take-profit rules must be overlaid based on your risk management style. Always validate results with backtesting and forward testing before applying to live trading accounts.

[b]📜 Final Thoughts[/b]
The Scalping Line Strategy offers a refined, easy-to-interpret approach to intraday trading. By combining smoothed moving averages, adaptive filtering, and flexible signal options, it helps traders identify short-term momentum shifts with clarity and confidence, making it a highly configurable tool for scalping-focused strategies.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nirnaykhatri - Strategy Version (Based on Scalping Line Indicatory By KivancOzbilgic)

//@version=6
strategy("Scalping Line Strategy", overlay=false)

// ═══════════════════════════════════════════════════════════════════════════════
// 📊 INPUT PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════════

// === Core Indicator Settings ===
src = input.source(close, title="Source", group="📈 Core Settings")
percent = input.float(1.0, "Percent Filter", step=0.1, minval=0, group="📈 Core Settings", tooltip="Percentage threshold for signal filtering")
mainperiod = input.int(100, "Main Period", minval=1, group="📈 Core Settings", tooltip="Main moving average period")
signalperiod = input.int(7, "Signal Period", minval=1, group="📈 Core Settings", tooltip="Signal line moving average period")

// === Strategy Configuration ===
tradeDirection = input.string("Both", "Trade Direction", options=["Long Only", "Short Only", "Both"], group="🎯 Strategy Settings")
flipSignals = input.bool(false, "Flip Entry Signals", group="🎯 Strategy Settings", tooltip="When enabled: Long on cross above zero, Short on cross below zero. When disabled: Long on cross below zero, Short on cross above zero")
enableLongs = tradeDirection == "Long Only" or tradeDirection == "Both"
enableShorts = tradeDirection == "Short Only" or tradeDirection == "Both"

// === Signal Filtering ===
enableTimeFilter = input.bool(false, "Enable Time Filter", group="🕒 Signal Filters")
startHour = input.int(9, "Start Hour", minval=0, maxval=23, group="🕒 Signal Filters")
endHour = input.int(16, "End Hour", minval=0, maxval=23, group="🕒 Signal Filters")

// ═══════════════════════════════════════════════════════════════════════════════
// 🔧 CORE CALCULATIONS (Original Indicator Logic)
// ═══════════════════════════════════════════════════════════════════════════════

// Calculate the main moving average with double smoothing
MA = ta.sma(ta.sma(src, math.ceil(mainperiod / 2)), math.floor(mainperiod / 2) + 1)

// Apply percentage-based signal smoothing
ssMA = MA > close + MA * percent / 100 ? MA : MA < close - MA * percent / 100 ? MA : close

// Calculate signal line
signalline = ta.sma(close, signalperiod)

// Calculate the Scalping Line Indicator (core signal)
ScalpLine = signalline - ssMA

// ═══════════════════════════════════════════════════════════════════════════════
// 📈 ORIGINAL INDICATOR VISUALS (Preserved)
// ═══════════════════════════════════════════════════════════════════════════════

// Plot the original indicator
k1 = plot(ScalpLine, "SLI", color.maroon, 2)
k2 = plot(0, "", color=color.gray)

// Original color logic and fill
color1 = ScalpLine >= 0 ? color.green : color.red
fill(k1, k2, color=color.new(color1, 80))

// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 TRADING LOGIC & SIGNAL GENERATION
// ═══════════════════════════════════════════════════════════════════════════════

// Time filter logic
inTimeWindow = not enableTimeFilter or (hour >= startHour and hour <= endHour)

// Signal generation with crossover detection
longSignal = (flipSignals ? ta.crossover(ScalpLine, 0) : ta.crossunder(ScalpLine, 0)) and enableLongs and inTimeWindow
shortSignal = (flipSignals ? ta.crossunder(ScalpLine, 0) : ta.crossover(ScalpLine, 0)) and enableShorts and inTimeWindow

// ═══════════════════════════════════════════════════════════════════════════════
// 🚀 STRATEGY EXECUTION (Following BB-Strategy Pattern)
// ═══════════════════════════════════════════════════════════════════════════════

// Simple strategy entries following BB-Strategy pattern
if (longSignal)
    strategy.entry("Long", strategy.long, comment="Long Entry")
else
    strategy.cancel(id="Long")
    
if (shortSignal)
    strategy.entry("Short", strategy.short, comment="Short Entry")
else
    strategy.cancel(id="Short")

// ═══════════════════════════════════════════════════════════════════════════════
// 🎨 VISUAL INDICATORS (Simple and Clean)
// ═══════════════════════════════════════════════════════════════════════════════

// Plot entry signals
plotshape(longSignal, title="Long Entry", style=shape.triangleup, location=location.belowbar, color=color.lime, size=size.small)
plotshape(shortSignal, title="Short Entry", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.small)

// Zero line for reference
hline(0, title="Zero Line", color=color.gray, linestyle=hline.style_solid)
````
