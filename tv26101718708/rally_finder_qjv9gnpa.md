# Rally Finder

- url: https://www.tradingview.com/script/Qjv9gnpA-Rally-Finder/
- type: indicator
- pine_id: PUB;1c4c258da692449eadba21c10ab2399f
- version: 2.0

## Description

📌 [b]Description:[/b]

Rally Finder is a simple tool that marks where price has rallied by a chosen multiple from its base. It helps you quickly spot explosive moves on any chart, such as 5x, 10x or 100x runs, without measuring them by hand.

📌 [b]How It Works:[/b]

1. [b]Base Tracking:[/b]
The script tracks the lowest close since the last signal and uses it as the base.

2. [b]Rally Detection:[/b]
When price reaches the chosen multiple of the base (default 5x), a signal is printed.
You can choose the target price:
- [b]High[/b] (default): includes wicks.
- [b]Close[/b]: only counts if the bar closes at or above the target.

3. [b]Reset:[/b]
After a signal, the base resets to that bar's close, and tracking starts again from there. If price falls below the new base, the base moves down to the new lowest close.
This means large rallies can print multiple signals. With the default 5x, signals appear at roughly 5x, 25x and 125x from the original base.

📌 [b]Visual Representation:[/b]

- [b]🔥 xN Label:[/b] Shown above the signal bar with the actual multiple reached.
- [b]BASE Label:[/b] Marks the lowest close the rally started from. (Can be toggled.)
- [b]Dashed Line:[/b] Connects the base to the signal bar. (Can be toggled.)

📌 [b]Settings:[/b]

- [b]Rally Multiplier (x):[/b] The multiple required to trigger a signal (default 5).
- [b]Target Price:[/b] High or Close.
- [b]Show Base Label / Draw Line:[/b] Turn visual elements on or off.

📌 [b]Usage:[/b]

- Works on any market and timeframe. Weekly and monthly charts are best for spotting long-term multi-bagger runs.
- Useful for studying past explosive moves, comparing how often an asset makes big rallies, or setting alerts when a new one happens.
- Built-in alert ([b]Rally Hit[/b]) notifies you when a new rally signal occurs.

📌 [b]Note:[/b]

This indicator marks rallies after they happen. It is not a buy or sell signal by itself.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © rikyu04

//@version=6
indicator(title="Rally Finder", overlay=true, max_labels_count=500, max_lines_count=500)

// ==========================================
// Settings
// ==========================================
multInput   = input.float(5.0, "Rally Multiplier (x)", minval=1.1, step=0.5, tooltip="Mark when price reaches this multiple of the base (lowest close).")
targetInput = input.string("High", "Target Price", options=["High", "Close"], tooltip="High: includes wicks. Close: only counts if the bar closes at or above the target.")
showBase    = input.bool(true, "Show Base Label")
showLine    = input.bool(true, "Draw Line from Base to Target")

// ==========================================
// Base tracking (lowest close since the last signal)
// ==========================================
var float baseClose    = na
var int   baseCloseBar = na

// ==========================================
// Rally detection (uses the base from previous bars only)
// ==========================================
float targetPrice = targetInput == "High" ? high : close
float ratio       = targetPrice / baseClose
bool  rallyHit    = not na(baseClose) and baseClose > 0 and ratio >= multInput

if rallyHit
    // Mark the target bar with the actual multiple reached
    label.new(bar_index, targetPrice, "🔥 x" + str.tostring(ratio, "#.#"), color=color.new(color.orange, 30), textcolor=color.white, style=label.style_label_down, size=size.normal)
    
    // Mark the base (lowest close)
    if showBase
        label.new(baseCloseBar, baseClose, "BASE", color=color.new(color.teal, 30), textcolor=color.white, style=label.style_label_up, size=size.small)
    
    // Connect base to target
    if showLine
        line.new(baseCloseBar, baseClose, bar_index, targetPrice, color=color.orange, style=line.style_dashed, width=1)
    
    // Reset: start tracking a new base from this bar's close
    baseClose    := close
    baseCloseBar := bar_index

// ==========================================
// Base update (after detection, so a bar can never trigger from its own close)
// ==========================================
else if na(baseClose) or close < baseClose
    baseClose    := close
    baseCloseBar := bar_index

// Alert
alertcondition(rallyHit, title="Rally Hit", message="{{ticker}}: price reached the rally multiple from its base. Close: {{close}}")
````
