# Ultimate Multi-Timeframe ORB Suite 

- url: https://www.tradingview.com/script/M3P0fNAM-Ultimate-Multi-Timeframe-ORB-Suite/
- type: indicator
- pine_id: PUB;32a4faf911304847a000462afe8b6192
- version: 1.0

## Description

Ultimate Multi-Timeframe ORB Suite 

The Ultimate Multi-Timeframe ORB Suite brings institutional-style Opening Range Breakout analysis to any market and any timeframe.

Unlike traditional ORB indicators that are limited to the opening bell, this indicator allows traders to define their own "opening range" inside virtually any higher timeframe, making it ideal for crypto, stocks, forex, and futures markets.

---

## Key Features

### Multi-Timeframe ORB Engine

Choose any parent timeframe:

• 15m
• 30m
• 1H
• 2H
• 4H
• Daily
• Weekly

The indicator automatically detects the start of each new higher timeframe candle and builds a custom Opening Range.

---

### Custom Opening Range Duration

Define exactly how long the opening range should last:

• 5 Minutes
• 10 Minutes
• 15 Minutes
• 30 Minutes
• 45 Minutes
• 1 Hour
• Or any custom duration

Examples:

• 4H candle with first 15 minutes as the ORB.
• Daily candle with first 1 hour as the ORB.
• Weekly candle with first 4 hours as the ORB.

This transforms the classic Opening Range Breakout concept into a continuous volatility expansion tool.

---

## Dynamic OR Levels

The indicator automatically plots:

✓ OR High
✓ OR Low
✓ Optional Midline
✓ Shaded Opening Range Zone

Levels extend forward throughout the active cycle, providing clear areas of support and resistance.

---

## Smart Breakout Detection

Bullish breakout:

Price closes above the OR High.

Bearish breakout:

Price closes below the OR Low.

Signals are only generated once per breakout to help reduce noise.

---

## Trend Filtering

Optional EMA trend filter allows traders to align breakouts with the prevailing trend.

Long signals:

Price above EMA.

Short signals:

Price below EMA.

EMA length is fully customizable.

---

## Volume Confirmation

Optional volume filter helps identify stronger momentum moves.

Breakouts are only confirmed when volume exceeds the moving average volume by a user-defined multiplier.

This helps avoid many low-conviction breakouts.

---

## Signal Visualization

Bullish Breakouts:

▲ Green triangle below bars.

Bearish Breakouts:

▼ Red triangle above bars.

Designed to provide clear entries without cluttering the chart.

---

## Real-Time Statistics Dashboard

Displays:

• Current OR High
• Current OR Low

The dashboard updates continuously and remains visible in the upper-right corner.

---

## Built-In Alerts

Create TradingView alerts for:

✓ Bullish ORB Breakout

✓ Bearish ORB Breakout

Alerts include the current symbol and trigger once per confirmed bar close.

---

## Markets

Designed for:

• Cryptocurrency
• Stocks
• Futures
• Forex
• Indices

Works especially well on:

• 1H ORBs
• 4H ORBs
• Daily ORBs
• Weekly ORBs

---

## Strategy Ideas

### Classic ORB

Breakout above OR High → Long

Breakout below OR Low → Short

---

### Trend-Following ORB

Combine with EMA filter to trade only in the direction of the dominant trend.

---

### Momentum ORB

Enable volume confirmation to focus on higher-quality expansions.

---

### Crypto 24/7 ORB

A popular setup:

Parent timeframe: 4H

Opening range duration: 15 minutes

Trend filter: 50 EMA

This approach effectively treats every new 4-hour candle as a fresh opportunity and can be used throughout the day, not just during traditional market opens.

---

The Ultimate Multi-Timeframe ORB Suite is built around one core principle:

**Volatility expands from balance.**

Instead of limiting Opening Range Breakouts to the opening bell, this indicator allows traders to capture volatility expansion anywhere, on any timeframe, in any market.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © itsjustAL

//@version=6
indicator("Ultimate Multi-Timeframe ORB Suite [LuxAlgo]", shorttitle="MTF ORB Suite", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// --- Group Name ---
// Core Settings
grp_core = "Core Settings"
htf_res = input.timeframe("240", "Parent Timeframe", group=grp_core)
orb_duration = input.int(15, "ORB Duration (mins)", group=grp_core)

grp_display = "Display Settings"
show_mid = input.bool(true, "Show Midline", group=grp_display)
orb_color = input.color(#089981, "Bullish Color", group=grp_display)
orb_bear_color = input.color(#f23645, "Bearish Color", group=grp_display)
orb_bg_color = input.color(color.new(#5b9cf6, 90), "Background Color", group=grp_display)

grp_filters = "Filters"
use_ema_filter = input.bool(true, "Use EMA Filter", group=grp_filters)
ema_len = input.int(50, "EMA Length", group=grp_filters)
use_vol_filter = input.bool(false, "Use Volume Filter", group=grp_filters)
vol_mult = input.float(1.5, "Volume Multiplier", group=grp_filters)

grp_stats = "Statistics"
show_stats = input.bool(true, "Show Stats Table", group=grp_stats)

// --- Logic ---
var float or_high = na
var float or_low = na
var float or_mid = na
var bool in_or = false
var bool or_formed = false

// Detect HTF start
htf_start = ta.change(time(htf_res)) != 0

if htf_start
    in_or := true
    or_high := high
    or_low := low
    or_formed := false

// Check if OR duration has passed
time_passed = (time - nz(time[1], time)) / 60000
var float accum_time = 0.0

if htf_start
    accum_time := time_passed
else if in_or
    accum_time += time_passed

if in_or and accum_time >= orb_duration
    in_or := false
    or_formed := true
    or_mid := (or_high + or_low) / 2

if in_or
    or_high := math.max(or_high, high)
    or_low := math.min(or_low, low)

// Visuals
var box or_box = na
var line h_line = na
var line l_line = na
var line m_line = na

if or_formed and not or_formed[1]
    or_box := box.new(time[1], or_high, time + 86400000, or_low, xloc=xloc.bar_time, border_color=color.new(chart.fg_color, 80), bgcolor=orb_bg_color)
    h_line := line.new(time[1], or_high, time + 86400000, or_high, xloc=xloc.bar_time, color=orb_color)
    l_line := line.new(time[1], or_low, time + 86400000, or_low, xloc=xloc.bar_time, color=orb_bear_color)
    if show_mid
        m_line := line.new(time[1], or_mid, time + 86400000, or_mid, xloc=xloc.bar_time, color=color.gray, style=line.style_dashed)

if or_formed
    if not na(or_box)
        box.set_right(or_box, time)
    if not na(h_line)
        line.set_x2(h_line, time)
    if not na(l_line)
        line.set_x2(l_line, time)
    if show_mid and not na(m_line)
        line.set_x2(m_line, time)

// Filters
ema = ta.ema(close, ema_len)
avg_vol = ta.sma(volume, 20)

bull_filter = not use_ema_filter or close > ema
bear_filter = not use_ema_filter or close < ema
vol_filter = not use_vol_filter or volume > avg_vol * vol_mult

// Signals
bull_break = or_formed and close > or_high and close[1] <= or_high and bull_filter and vol_filter
bear_break = or_formed and close < or_low and close[1] >= or_low and bear_filter and vol_filter

plotshape(bull_break, "Bull Break", shape.triangleup, location.belowbar, orb_color, size=size.small)
plotshape(bear_break, "Bear Break", shape.triangledown, location.abovebar, orb_bear_color, size=size.small)

// Alerts
if bull_break
    alert("Bullish ORB Breakout on " + syminfo.ticker, alert.freq_once_per_bar_close)
if bear_break
    alert("Bearish ORB Breakout on " + syminfo.ticker, alert.freq_once_per_bar_close)

// Stats Table
var table tb = table.new(position.top_right, 2, 2, bgcolor=color.new(chart.bg_color, 10), border_width=1, border_color=color.gray)
if show_stats and barstate.islast
    table.cell(tb, 0, 0, "Current OR High", text_color=chart.fg_color)
    table.cell(tb, 1, 0, str.tostring(or_high), text_color=orb_color)
    table.cell(tb, 0, 1, "Current OR Low", text_color=chart.fg_color)
    table.cell(tb, 1, 1, str.tostring(or_low), text_color=orb_bear_color)
````
