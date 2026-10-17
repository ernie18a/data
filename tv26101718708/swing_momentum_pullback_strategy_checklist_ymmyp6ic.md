# Swing Momentum Pullback Strategy + Checklist

- url: https://www.tradingview.com/script/yMmyP6Ic-Swing-Momentum-Pullback-Strategy-Checklist/
- type: indicator
- pine_id: PUB;5a89b02c87d84b08aadd3b012fb943d4
- version: 1.0

## Description

Swing Momentum Pullback Strategy + Checklist

This indicator is a complete swing trading system designed to help traders identify 
trend breakouts and low-risk momentum pullbacks, optimized for the Daily Timeframe.

The script combines a long-term trend filter, automated resistance detection, and 
specific entry triggers into a single chart overlay, along with a real-time Strategy 
Checklist Dashboard that confirms setups at a glance.

─────────────────────────────────
🎯 CORE COMPONENTS
─────────────────────────────────

▸ Trend Filter (Purple Line)
  200-period Simple Moving Average (SMA). Acts as the long-term trend filter. 
  Long setups are only considered when price is above this line.

▸ Momentum Guide (Orange Line)
  8-period Exponential Moving Average (EMA). Tracks short-term momentum. 
  In strong trends, price tends to "ride" this line. Entries are sought when 
  price pulls back to test this area.

▸ Multi-Month Resistance Line (Orange Horizontal)
  Automatically plots the highest price over a user-defined lookback period (in months). 
  Instantly visualizes the key resistance level a stock must break out above.

▸ Strategy Checklist Dashboard
  A real-time table that evaluates Trend, Resistance, and Momentum conditions to 
  display a clear ✅ ENTER, 🚀 GAP UP, or ⏳ WAIT signal.

─────────────────────────────────
🛠 HOW IT WORKS — TWO SETUPS
─────────────────────────────────

1. The Daily Gap Up ("GAP" Label)
   Fires when a stock gaps up with strong overnight momentum.
   • Open is at least X% above the prior day's Close (adjustable, default 3%)
   • Open is above the prior day's High
   • Price must be above the 200 SMA
   → Marked with a green "GAP" label on the chart

2. The Trend Pullback ("ENTER" Signal)
   A trend-following entry to join an existing move at lower risk.
   • Stock is in an uptrend (above 200 SMA)
   • Price dips down to touch or test the 8 EMA
   • Candle shows a pullback (red candle or lower close) — confirms we're buying 
     a dip, not chasing a top
   → Dashboard "Action Signal" turns orange and displays ✅ ENTER

─────────────────────────────────
📋 CHECKLIST DASHBOARD — READINGS
─────────────────────────────────

Trend (> 200 SMA):
  🟢 Bullish  — Price is in an uptrend. Safe to look for entries.
  🔴 Bearish  — Price is below the 200 SMA. Stay out.

Above Resistance?:
  🟢 Breakout — Price has cleared the multi-month resistance line.
  ⚪ ---      — Price is currently below the key breakout level.

Near 8 EMA?:
  🟢 Yes      — Price is near the value zone for a potential pullback entry.

Action Signal:
  🚀 GAP UP   — Strong momentum gap detected.
  ✅ ENTER    — Valid pullback entry confirmed.
  ⏳ WAIT     — No qualifying setup on the current bar.

─────────────────────────────────
⚙️ SETTINGS
─────────────────────────────────

- Momentum EMA Length       — Default: 8. Controls pullback line sensitivity.
- Trend SMA Length          — Default: 200. Long-term trend filter period.
- Gap Up % Threshold        — Default: 3.0%. Minimum overnight gap to trigger signal.
- Resistance Lookback (Mo.) — Default: 3. Months used to find the key resistance level.
- Table Position            — Move the checklist dashboard to any corner of your chart.

─────────────────────────────────
⚠️ DISCLAIMER
─────────────────────────────────

For educational purposes only. Not financial advice. 
Always manage your risk and use a stop loss.

## Source Code

````pine
//@version=6
indicator('Swing Momentum Pullback Strategy + Checklist', overlay = true)

// --- 1. Settings ---
emaLength = input.int(8, title = 'Momentum EMA Length (Orange)')
smaLength = input.int(200, title = 'Trend SMA Length (Purple)')
gapThreshold = input.float(3.0, title = 'Gap Up % Threshold') / 100
resMonths = input.int(3, title = 'Resistance Lookback (Months)', minval = 1)
resLookbackBars = resMonths * 21
tablePos = input.string('Bottom Right', 'Table Position', options = ['Top Right', 'Bottom Right', 'Top Left', 'Bottom Left'])

// --- 2. Indicators ---
ema8 = ta.ema(close, emaLength)
sma200 = ta.sma(close, smaLength)

// Dynamic resistance: highest high over the lookback window (excludes current bar)
resistanceLevel = ta.highest(high, resLookbackBars)[1]

// --- 3. Conditions ---
bool isUptrend = close > sma200

// Gap Up: opens above prior close by threshold AND above prior high, while in uptrend
bool isGapUp = open > close[1] * (1 + gapThreshold) and open > high[1] and isUptrend

// Pullback to 8 EMA in an uptrend, confirmed by a red or lower close
bool isDip = close < open or close < close[1]
bool isPullback = isUptrend and low <= ema8 and close > ema8 and isDip

// --- 4. Visuals ---
plot(ema8, color = color.new(color.orange, 0), linewidth = 2, title = '8 EMA')
plot(sma200, color = color.new(color.purple, 0), linewidth = 3, title = '200 SMA')

// Gap Up label
if isGapUp
    label.new(bar_index, high, 'GAP', color = color.green, textcolor = color.white, style = label.style_label_down, size = size.small)

// Single extending horizontal resistance line (redrawn on last bar only)
var line resLine = na
if barstate.islast
    if not na(resLine)
        line.delete(resLine)
    resLine := line.new(bar_index, resistanceLevel, bar_index + 1, resistanceLevel, xloc.bar_index, extend.both, color = color.new(color.orange, 0), width = 2)
    resLine

// --- 5. Dashboard Table ---
string pos = switch tablePos
    'Top Right' => position.top_right
    'Bottom Right' => position.bottom_right
    'Top Left' => position.top_left
    'Bottom Left' => position.bottom_left

var table dashboard = table.new(pos, 2, 5, border_width = 1)

if barstate.islast
    // Header row
    table.cell(dashboard, 0, 0, 'Setup Checklist', bgcolor = color.gray, text_color = color.white, text_size = size.small, width = 12)
    table.cell(dashboard, 1, 0, 'Status', bgcolor = color.gray, text_color = color.white, text_size = size.small, width = 8)

    // Row 1 — Trend Filter
    table.cell(dashboard, 0, 1, 'Trend (> 200 SMA)', bgcolor = color.new(color.black, 90), text_size = size.small, text_halign = text.align_left)
    table.cell(dashboard, 1, 1, isUptrend ? '✅ Bullish' : '❌ Bearish', bgcolor = isUptrend ? color.new(color.green, 80) : color.new(color.red, 80), text_color = color.white, text_size = size.small)

    // Row 2 — Resistance Breakout
    bool isAboveRes = close > resistanceLevel
    table.cell(dashboard, 0, 2, 'Above Resistance?', bgcolor = color.new(color.black, 90), text_size = size.small, text_halign = text.align_left)
    table.cell(dashboard, 1, 2, isAboveRes ? '✅ Breakout' : '---', bgcolor = isAboveRes ? color.new(color.green, 80) : color.new(color.gray, 80), text_color = color.white, text_size = size.small)

    // Row 3 — EMA Proximity
    bool isNearEMA = math.abs(close - ema8) / close < 0.015
    table.cell(dashboard, 0, 3, 'Near 8 EMA?', bgcolor = color.new(color.black, 90), text_size = size.small, text_halign = text.align_left)
    table.cell(dashboard, 1, 3, isNearEMA or low <= ema8 ? '✅ Yes' : '---', bgcolor = isNearEMA or low <= ema8 ? color.new(color.green, 80) : color.new(color.gray, 80), text_color = color.white, text_size = size.small)

    // Row 4 — Action Signal
    table.cell(dashboard, 0, 4, 'Action Signal', bgcolor = color.new(color.black, 90), text_size = size.small, text_halign = text.align_left)
    if isGapUp and isAboveRes
        table.cell(dashboard, 1, 4, '🚀 GAP UP', bgcolor = color.green, text_color = color.white, text_size = size.small)
    else if isPullback
        table.cell(dashboard, 1, 4, '✅ ENTER', bgcolor = color.orange, text_color = color.white, text_size = size.small)
    else
        table.cell(dashboard, 1, 4, '⏳ WAIT', bgcolor = color.gray, text_color = color.white, text_size = size.small)
````
