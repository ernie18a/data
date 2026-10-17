# MACD Crossover Strategy [Long/Short]

- url: https://www.tradingview.com/script/EmvVsgot/
- type: strategy
- pine_id: PUB;aaff60a90e4b4044bfbb56a2f91572f8
- version: 1.0

## Description

MACD Crossover Strategy [Long/Short]

A clean, fully configurable MACD-based strategy built on Pine Script v6.
Supports two entry modes, independent Long/Short toggles, and four alert conditions — ready for both backtesting and live trading.

━━━━━━━━━━━━━━━━━━━━━━━
🔹 ENTRY CONDITIONS (selectable)
━━━━━━━━━━━━━━━━━━━━━━━
- MACDxSignal — Enter when the MACD line crosses the Signal line.
  Fast, reactive. Suitable for trending markets.

- HistCross0 — Enter when the Histogram crosses zero.
  Slightly smoother signal. Helps reduce noise in choppy conditions.

━━━━━━━━━━━━━━━━━━━━━━━
🔹 FEATURES
━━━━━━━━━━━━━━━━━━━━━━━
- Independent Long / Short toggles
  → Disable either direction to run a one-sided strategy.
  → When one side is off, the opposite signal still closes the open position.

- Lot Size input
  → Set a fixed quantity per entry.

- Commission & Slippage
  → Defaults: 0.1% commission, 2 ticks slippage.
  → Edit directly in the script, or override via Strategy Properties tab.

- Visual entry markers
  → Green ▲ for Long entries, Red ▼ for Short entries, plotted on the MACD pane.

━━━━━━━━━━━━━━━━━━━━━━━
🔹 ALERT CONDITIONS (4 total)
━━━━━━━━━━━━━━━━━━━━━━━
- 🟢 Long Entry — Long signal triggered
- 🔴 Short Entry — Short signal triggered
- 📈 Hist Rising — Histogram switched from falling to rising
- 📉 Hist Falling — Histogram switched from rising to falling

━━━━━━━━━━━━━━━━━━━━━━━
🔹 SETTINGS
━━━━━━━━━━━━━━━━━━━━━━━
- Fast Length: 12 (default)
- Slow Length: 26 (default)
- Signal Length: 9 (default)
- Oscillator / Signal MA Type: EMA or SMA

━━━━━━━━━━━━━━━━━━━━━━━
⚠️ DISCLAIMER
━━━━━━━━━━━━━━━━━━━━━━━
This script is for educational and backtesting purposes only.
Past performance does not guarantee future results.
Always apply proper risk management before using any strategy in live markets.

## Source Code

````pine
//@version=6

// ── MACD Settings ─────────────────────────────────────────────────────────
float  sourceInput  = input.source(close,  "Source",           group = "📊 MACD")
int    fastLenInput = input.int(12, "Fast Length",   minval = 1, group = "📊 MACD")
int    slowLenInput = input.int(26, "Slow Length",   minval = 1, group = "📊 MACD")
int    sigLenInput  = input.int(9,  "Signal Length", minval = 1, group = "📊 MACD")
string oscTypeInput = input.string("EMA", "Oscillator MA Type", ["EMA", "SMA"], group = "📊 MACD", display = display.none)
string sigTypeInput = input.string("EMA", "Signal MA Type",     ["EMA", "SMA"], group = "📊 MACD", display = display.none)

// ── Strategy Settings ─────────────────────────────────────────────────────
string entryInput = input.string("MACDxSignal", "Entry Condition",
     options = ["MACDxSignal", "HistCross0"], group = "⚙️ Strategy",
     tooltip = "MACDxSignal: MACD line crosses Signal line / HistCross0: Histogram crosses zero")
bool  longInput  = input.bool(true,  "Enable Long",                             group = "⚙️ Strategy")
bool  shortInput = input.bool(true,  "Enable Short",                            group = "⚙️ Strategy")
float qtyInput   = input.float(1.0,  "Lot Size",    minval = 0.01, step = 0.01, group = "⚙️ Strategy")

// commission_value / slippage require const float — edit directly below
// These can also be adjusted via TradingView's Strategy Properties tab
strategy("MACD Crossover Strategy [Long/Short]", "MACD X [L/S]",
     overlay           = false,
     commission_type   = strategy.commission.percent,
     commission_value  = 0.1,
     slippage          = 2,
     default_qty_type  = strategy.fixed,
     default_qty_value = 1)

// ── MA Function ───────────────────────────────────────────────────────────
ma(float source, int length, simple string maType) =>
    switch maType
        "EMA" => ta.ema(source, length)
        "SMA" => ta.sma(source, length)

// ── MACD Calculation ──────────────────────────────────────────────────────
float maFast = ma(sourceInput, fastLenInput, oscTypeInput)
float maSlow = ma(sourceInput, slowLenInput, oscTypeInput)
float macd   = maFast - maSlow
float signal = ma(macd, sigLenInput, sigTypeInput)
float hist   = macd - signal
color hColor = hist >= 0 ? hist > hist[1] ? #26a69a : #b2dfdb : hist > hist[1] ? #ffcdd2 : #ff5252

// ── Entry Signals ─────────────────────────────────────────────────────────
bool longSignal  = entryInput == "MACDxSignal" ? ta.crossover(macd, signal)  : ta.crossover(hist, 0)
bool shortSignal = entryInput == "MACDxSignal" ? ta.crossunder(macd, signal) : ta.crossunder(hist, 0)

// ── Entry / Exit ──────────────────────────────────────────────────────────
if longSignal
    if longInput
        strategy.entry("Long", strategy.long,  qty = qtyInput)
    else if strategy.position_size < 0
        strategy.close("Short")

if shortSignal
    if shortInput
        strategy.entry("Short", strategy.short, qty = qtyInput)
    else if strategy.position_size > 0
        strategy.close("Long")

// ── Alert Conditions ──────────────────────────────────────────────────────
alertcondition(longSignal,                "🟢 Long Entry",   "MACD: Long entry signal triggered")
alertcondition(shortSignal,               "🔴 Short Entry",  "MACD: Short entry signal triggered")
alertcondition(hist[1] >= 0 and hist < 0, "📉 Hist Falling", "MACD Histogram: switched from rising to falling")
alertcondition(hist[1] <= 0 and hist > 0, "📈 Hist Rising",  "MACD Histogram: switched from falling to rising")

// ── Plots ─────────────────────────────────────────────────────────────────
hline(0, "Zero", #787b8680)
plot(hist,   "Histogram",   hColor,      style = plot.style_columns)
plot(macd,   "MACD",        color.blue)
plot(signal, "Signal Line", #ff6d00)

plotshape(longSignal  and longInput,  "Long Signal",  shape.triangleup,   location.bottom, color.new(color.green, 0), size = size.small)
plotshape(shortSignal and shortInput, "Short Signal", shape.triangledown, location.top,    color.new(color.red,   0), size = size.small)
````
