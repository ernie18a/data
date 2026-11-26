# NEIL'S Dual MACD (5min & 15min)

- url: https://www.tradingview.com/script/A80z7arp-NEIL-S-Dual-MACD-5min-15min/
- type: indicator
- pine_id: PUB;53d091def51448a79a062addcd9c92cb
- version: 1.0

## Description

⏱️ Multi-Timeframe MACD — Smarter, Faster Analysis

This indicator is built to simplify one of the most common challenges traders face: constantly switching between timeframes to confirm MACD signals.

Instead of flipping between the 5-minute and 15-minute charts, this tool brings both together into a single view—allowing you to analyze momentum, trend direction, and signal alignment without interrupting your workflow.

🚀 Why This Indicator?

Many traders rely on multi-timeframe confirmation to improve accuracy, but the process of switching charts can be slow, distracting, and inefficient.

This indicator solves that problem by integrating MACD data from both 5-minute and 15-minute timeframes directly onto your current chart, helping you stay focused and react faster to market movements.

🔑 Key Features

⚡ Dual Timeframe MACD in One View
Monitor both 5m and 15m MACD simultaneously without changing charts

📉 Stronger Signal Confirmation
Quickly identify when both timeframes align for higher-probability setups

⏳ Time Efficiency
Eliminates repetitive timeframe switching and speeds up analysis

📊 Improved Market Clarity
Understand momentum shifts across timeframes at a glance

🧠 Better Decision-Making
Helps traders stay disciplined by relying on structured, multi-timeframe confirmation

🎯 How It Helps You

By combining multiple timeframe insights into one chart, this indicator allows you to:

Spot early momentum shifts on the lower timeframe
Confirm trend direction with the higher timeframe
Avoid weak or conflicting signals
Stay consistent in your trading process
👤 Who Is This For?

✔ Scalpers and intraday traders
✔ Traders using MACD for entries and confirmations
✔ Anyone practicing multi-timeframe analysis
✔ Traders who want a faster and cleaner workflow

⚠️ Important Note

This indicator is designed as a decision-support tool, not a standalone trading system. Always combine it with proper risk management and your overall trading strategy.

## Source Code

````pine
//@version=5
indicator(title="Dual MACD (5min & 15min)", shorttitle="Dual MACD", overlay=false)

// ─────────────────────────────────────────────
// INPUTS — 5-min MACD
// ─────────────────────────────────────────────
grp5 = "5-Min MACD Settings"
fast5   = input.int(12, "Fast Length",   minval=1, group=grp5)
slow5   = input.int(26, "Slow Length",   minval=1, group=grp5)
signal5 = input.int(9,  "Signal Length", minval=1, group=grp5)
src5    = input.source(close, "Source",  group=grp5)
show5   = input.bool(true, "Show 5-Min MACD", group=grp5)

// ─────────────────────────────────────────────
// INPUTS — 15-min MACD
// ─────────────────────────────────────────────
grp15 = "15-Min MACD Settings"
fast15   = input.int(12, "Fast Length",   minval=1, group=grp15)
slow15   = input.int(26, "Slow Length",   minval=1, group=grp15)
signal15 = input.int(9,  "Signal Length", minval=1, group=grp15)
src15    = input.source(close, "Source",  group=grp15)
show15   = input.bool(true, "Show 15-Min MACD", group=grp15)

// ─────────────────────────────────────────────
// INPUTS — Colors
// ─────────────────────────────────────────────
grpVis = "Visual Settings"
col5Line  = input.color(color.new(#00bcd4, 0), "5-Min MACD Line",    group=grpVis)
colSig5   = input.color(color.new(#e91e63, 0), "5-Min Signal Line",  group=grpVis)
col15Line = input.color(color.new(#ff9800, 0), "15-Min MACD Line",   group=grpVis)
colSig15  = input.color(color.new(#9c27b0, 0), "15-Min Signal Line", group=grpVis)

// ─────────────────────────────────────────────
// MACD CALCULATIONS
// ─────────────────────────────────────────────

// 5-min MACD
[macdLine5, signalLine5, _hist5] = request.security(
     syminfo.tickerid, "5",
     ta.macd(src5, fast5, slow5, signal5),
     lookahead=barmerge.lookahead_off)

// 15-min MACD — lookahead_on for smooth real-time line
[macdLine15, signalLine15, _hist15] = request.security(
     syminfo.tickerid, "15",
     ta.macd(src15, fast15, slow15, signal15),
     lookahead=barmerge.lookahead_on)

// ─────────────────────────────────────────────
// PLOTS — 5-min MACD lines
// ─────────────────────────────────────────────
plot(show5 ? macdLine5   : na, title="5-Min MACD Line", color=col5Line, linewidth=2)
plot(show5 ? signalLine5 : na, title="5-Min Signal",    color=colSig5,  linewidth=1)

// ─────────────────────────────────────────────
// PLOTS — 15-min MACD lines
// ─────────────────────────────────────────────
plot(show15 ? macdLine15   : na, title="15-Min MACD Line", color=col15Line, linewidth=2)
plot(show15 ? signalLine15 : na, title="15-Min Signal",    color=colSig15,  linewidth=1)

// ─────────────────────────────────────────────
// ZERO LINE
// ─────────────────────────────────────────────
hline(0, "Zero Line", color=color.new(color.gray, 40), linestyle=hline.style_dashed, linewidth=1)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(ta.crossover(macdLine5, signalLine5),    title="5-Min Bullish Cross",  message="5-Min MACD crossed ABOVE signal — Bullish")
alertcondition(ta.crossunder(macdLine5, signalLine5),   title="5-Min Bearish Cross",  message="5-Min MACD crossed BELOW signal — Bearish")

alertcondition(ta.crossover(macdLine15, signalLine15),  title="15-Min Bullish Cross", message="15-Min MACD crossed ABOVE signal — Bullish")
alertcondition(ta.crossunder(macdLine15, signalLine15), title="15-Min Bearish Cross", message="15-Min MACD crossed BELOW signal — Bearish")
````
