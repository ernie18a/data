# NIL - Dynamic Timeframe EMA

- url: https://www.tradingview.com/script/mpCUHUrl-NIL-Dynamic-Timeframe-EMA/
- type: indicator
- pine_id: PUB;5b3c8c7bc47943d48b84404f371a032a
- version: 1.0

## Description

[b]NIL - Dynamic Timeframe EMA (Limited)[/b]

This indicator automatically plots higher-timeframe EMAs (1H, 1D, 1W, 1M) on [i]any[/i] chart timeframe while keeping your chart clean and professional.

It intelligently calculates the correct EMA length based on the current bar duration and [b]automatically hides[/b] any EMA that matches or is lower than the chart's timeframe (no more redundant or flat lines).

Perfect for intraday traders who want to see daily, weekly, and monthly EMA context without manual adjustments.

═

[b]█ OVERVIEW[/b]

The script converts standard time-based EMAs into dynamic periods:
• 1-hour EMA
• 1-day EMA  
• 1-week EMA
• 1-month EMA

It uses approximate trading minutes (390 min per day, 21 trading days per month) for accurate calculations across all timeframes — from seconds to monthly charts.

[b]Key Smart Feature:[/b]
The indicator automatically hides EMAs that are no longer meaningful:
• On 1H or higher → 1H EMA is hidden
• On Daily or higher → 1H + 1D EMAs are hidden
• On Weekly or higher → 1H + 1D + 1W EMAs are hidden
• On Monthly → only 1M EMA remains (if enabled)

This prevents visual clutter and keeps the chart focused.

═

[b]█ FEATURES[/b]
[list]
[*] Fully automatic period calculation based on current timeframe
[*] Smart show/hide logic — no redundant lines
[*] Dynamic info table showing actual periods used
[*] Capping system to respect Pine Script's 5000-bar limit (configurable)
[*] Clean, customizable colors and display options
[*] Works on all timeframes (seconds, minutes, daily, weekly, monthly)
[/list]

═

[b]█ HOW TO USE[/b]

1. Add the indicator to any chart
2. Enable/disable each EMA via the inputs
3. Adjust colors as desired
4. (Optional) Increase "Max EMA Lookback" if working on very low timeframes

The top-right table will always show you:
• Which EMAs are active
• The exact period used for each
• Whether the period was capped

[b]Best Use Cases:[/b]
• Intraday trading with higher-timeframe context
• Swing trading on lower timeframes
• Quickly assessing trend alignment across multiple time horizons

═

[b]█ INPUTS[/b]

[b]Display[/b]
• Show 1H EMA, Show 1D EMA, Show 1W EMA, Show 1M EMA

[b]Colors[/b]
• Individual color selection for each EMA line

[b]Limits[/b]
• Max EMA Lookback — protects against Pine Script calculation limits (default 5000)

═

[b]█ NOTES & LIMITATIONS[/b]

• Calculations are performed on the chart's native data (not using request.security() — faster, no repainting).
• Uses standard trading session approximations (390 minutes/day).
• Very high periods on extremely low timeframes (e.g. 1-second) are automatically capped.

Enjoy cleaner charts with meaningful higher-timeframe EMAs!

Feel free to leave feedback or suggestions for future improvements.

## Source Code

````pine
//@version=5
indicator("@NIL - Dynamic Timeframe EMA (Limited)", shorttitle="@NIL - Dynamic TF EMA", overlay=true, max_bars_back=5000)

// ── INPUTS ─────────────────────────────────────────────────────────────────────
show1H = input.bool(true,  "Show 1H EMA", group="Display")
show1D = input.bool(true,  "Show 1D EMA", group="Display")
show1W = input.bool(true,  "Show 1W EMA", group="Display")
show1M = input.bool(true,  "Show 1M EMA", group="Display")

col1H = input.color(color.blue,   "1H EMA Color", group="Colors")
col1D = input.color(color.orange, "1D EMA Color", group="Colors")
col1W = input.color(color.green,  "1W EMA Color", group="Colors")
col1M = input.color(color.red,    "1M EMA Color", group="Colors")

maxLookback = input.int(5000, "Max EMA Lookback (to avoid 5000-bar limit)", minval=100, maxval=10000, group="Limits")

// ── HELPER: Current bar duration in trading minutes ───────────────────────────
getBarMinutes() =>
    // More accurate calculation using built-in timeframe variables
    if timeframe.isseconds
        timeframe.multiplier / 60.0
    else if timeframe.isminutes
        timeframe.multiplier
    else if timeframe.isdaily
        timeframe.multiplier * 390    // 6.5 trading hours
    else if timeframe.isweekly
        timeframe.multiplier * 5 * 390
    else if timeframe.ismonthly
        timeframe.multiplier * 21 * 390   // approx 21 trading days
    else
        1  // fallback

// ── CONSTANTS ─────────────────────────────────────────────────────────────────
MINUTES_PER_HOUR  = 60
MINUTES_PER_DAY   = 390
MINUTES_PER_WEEK  = 5 * MINUTES_PER_DAY
MINUTES_PER_MONTH = 21 * MINUTES_PER_DAY

// ── CALCULATIONS ──────────────────────────────────────────────────────────────
barMin = getBarMinutes()

period1H_raw = math.round(MINUTES_PER_HOUR  / barMin)
period1D_raw = math.round(MINUTES_PER_DAY   / barMin)
period1W_raw = math.round(MINUTES_PER_WEEK  / barMin)
period1M_raw = math.round(MINUTES_PER_MONTH / barMin)

// Safe periods (capped)
p1H = math.max(1, math.min(maxLookback, period1H_raw))
p1D = math.max(1, math.min(maxLookback, period1D_raw))
p1W = math.max(1, math.min(maxLookback, period1W_raw))
p1M = math.max(1, math.min(maxLookback, period1M_raw))

// ── Determine if we should show each EMA (hide when chart TF >= target TF) ──
showPlot1H = show1H and not (timeframe.isintraday and timeframe.multiplier >= 60) and not timeframe.isdaily and not timeframe.isweekly and not timeframe.ismonthly
showPlot1D = show1D and not (timeframe.isdaily and timeframe.multiplier >= 1) and not timeframe.isweekly and not timeframe.ismonthly
showPlot1W = show1W and not (timeframe.isweekly and timeframe.multiplier >= 1) and not timeframe.ismonthly
showPlot1M = show1M and not (timeframe.ismonthly and timeframe.multiplier >= 1)

// ── EMAs (always calculated, but plotted conditionally) ───────────────────────
ema1H = ta.ema(close, p1H)
ema1D = ta.ema(close, p1D)
ema1W = ta.ema(close, p1W)
ema1M = ta.ema(close, p1M)

// ── PLOTS ─────────────────────────────────────────────────────────────────────
plot(showPlot1H ? ema1H : na, title="1H EMA", color=col1H, linewidth=2)
plot(showPlot1D ? ema1D : na, title="1D EMA", color=col1D, linewidth=2)
plot(showPlot1W ? ema1W : na, title="1W EMA", color=col1W, linewidth=2)
plot(showPlot1M ? ema1M : na, title="1M EMA", color=col1M, linewidth=2)

// ── INFO TABLE ────────────────────────────────────────────────────────────────
var table infoTable = table.new(position.top_right, columns = 2, rows = 5, bgcolor = color.new(color.black, 80), border_width = 1)

if barstate.islast
    table.cell(infoTable, 0, 0, "Cycle",  text_color = color.white, text_size = size.small)
    table.cell(infoTable, 1, 0, "Period", text_color = color.white, text_size = size.small)
    
    row = 1
    
    if showPlot1H
        table.cell(infoTable, 0, row, "1H", text_color = col1H, text_size = size.small)
        table.cell(infoTable, 1, row, str.tostring(p1H) + (period1H_raw > maxLookback ? " (capped)" : ""), text_color = col1H, text_size = size.small)
        row += 1
    
    if showPlot1D
        table.cell(infoTable, 0, row, "1D", text_color = col1D, text_size = size.small)
        table.cell(infoTable, 1, row, str.tostring(p1D) + (period1D_raw > maxLookback ? " (capped)" : ""), text_color = col1D, text_size = size.small)
        row += 1
    
    if showPlot1W
        table.cell(infoTable, 0, row, "1W", text_color = col1W, text_size = size.small)
        table.cell(infoTable, 1, row, str.tostring(p1W) + (period1W_raw > maxLookback ? " (capped)" : ""), text_color = col1W, text_size = size.small)
        row += 1
    
    if showPlot1M
        table.cell(infoTable, 0, row, "1M", text_color = col1M, text_size = size.small)
        table.cell(infoTable, 1, row, str.tostring(p1M) + (period1M_raw > maxLookback ? " (capped)" : ""), text_color = col1M, text_size = size.small)
````
