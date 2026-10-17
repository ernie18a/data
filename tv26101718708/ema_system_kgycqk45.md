# EMA System

- url: https://www.tradingview.com/script/KGYcQK45-EMA-System/
- type: indicator
- pine_id: PUB;28d040b7327e41c9a64084ce24a9289f
- version: 1.0

## Description

This indicator plots three configurable exponential moving averages on the chart. The default values are EMA 34, EMA 89, and EMA 144. The purpose of this tool is to provide a simple visual framework for observing short-term, medium-term, and longer-term trend direction.

Main features:
- Plots three configurable EMA lines.
- Default EMA values are 34, 89, and 144.
- Allows users to show or hide all EMA lines from the input settings.
- EMA colors and line styles can be adjusted from the Style tab.
- The script is designed for visual trend analysis only and does not generate buy or sell signals.

How it works:
- EMA 1 is intended to represent the faster trend component.
- EMA 2 is intended to represent the medium trend component.
- EMA 3 is intended to represent the slower trend component.
- When the faster EMA is above the medium and slower EMAs, traders may interpret the market as being in a stronger upward trend.
- When the faster EMA is below the medium and slower EMAs, traders may interpret the market as being in a stronger downward trend.

How to use:
- Use the EMA stack as trend context.
- Use price interaction with the EMA lines to observe pullbacks or trend continuation areas.
- Use the Show EMA Lines option to quickly hide or display the EMA lines without removing the indicator from the chart.
- This script does not generate buy or sell signals.
- This script does not guarantee future performance.

Limitations:
This indicator only displays EMA lines. It does not include market structure logic, multi-timeframe confirmation, risk management, or backtesting. Users should combine it with their own analysis and risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © FujiwaraTakashi

//@version=6
indicator('EMA System', shorttitle='EMA System', overlay=true)

// ============================================================================
// EMA SETTINGS
// ============================================================================

showEmaLines = input.bool(true, title='Show EMA Lines', tooltip='Toggle the display of EMA lines on the chart.')

emaLength1 = input.int(34, title='EMA 1', inline='EMA_1', display=display.all - display.status_line)
emaLength2 = input.int(89, title='EMA 2', inline='EMA_2', display=display.all - display.status_line)
emaLength3 = input.int(144, title='EMA 3', inline='EMA_3', display=display.all - display.status_line)

// Color settings are controlled from the Style tab.
emaColor1 = color.blue
emaColor2 = color.yellow
emaColor3 = color.green

// ============================================================================
// EMA CALCULATION
// ============================================================================

ema1 = ta.ema(close, emaLength1)
ema2 = ta.ema(close, emaLength2)
ema3 = ta.ema(close, emaLength3)

// ============================================================================
// EMA PLOTS
// ============================================================================

plot(showEmaLines ? ema1 : na, title='Style EMA 1', color=emaColor1, linewidth=1, display=display.all - display.status_line)
plot(showEmaLines ? ema2 : na, title='Style EMA 2', color=emaColor2, linewidth=1, display=display.all - display.status_line)
plot(showEmaLines ? ema3 : na, title='Style EMA 3', color=emaColor3, linewidth=1, display=display.all - display.status_line)
````
