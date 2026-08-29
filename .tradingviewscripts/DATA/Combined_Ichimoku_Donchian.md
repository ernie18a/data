<!-- tradingview-pine-id: PUB;52c83a6c50ff4f10962146a558e7ea15 -->
<!-- tradingviewscripts-format: 1 -->
# Combined Ichimoku & Donchian

Source: https://www.tradingview.com/script/JbtJsoe0-Ichimoku-w-Donchian-Signal/

## Description

Overview
The Combined Ichimoku & Donchian indicator merges the trend-following depth of the classic Ichimoku system with the mechanical Break of Structure (BOS) tracking of Donchian Channels. This tool allows traders to spot objective price breakouts via Donchian bands while filtering and confirming those moves using key dynamic levels and equilibrium lines from the Ichimoku framework.

Key Features
Classic Ichimoku Suite: Plots the Tenkan-sen, Kijun-sen, Senkou Span Cloud, and Chikou Span with fully customizable periods and offsets.

Donchian Ribbon: Displays a multi-speed channel system using fast and slow bands to visualize market volatility, ranges, and momentum expansion.

State-Machine Breakout Signals: Tracks structural breaks dynamically, signaling fresh breakouts while filtering out consecutive redundancy via an internal state machine.

Alert Automation: Built-in triggers for automated tracking or notifications when a primary Donchian breakout occurs.

Possible Use
While the Donchian channel acts as an objective trigger for a Break of Structure (BOS), combine these breakouts with Ichimoku structural confirmations to increase reliability:

Long Entry Confirmation: Look for a green breakout triangle where price closes above the upper channel band, ideally confirmed when the breakout occurs above the Ichimoku Cloud or features a bullish Tenkan/Kijun cross.

Short Entry Confirmation: Look for a red breakout triangle where price closes below the lower channel band, ideally confirmed when the breakdown happens below the Ichimoku Cloud with a bearish Chikou Span position.

---

## Source Code

````pine
//@version=6
indicator("Combined Ichimoku & Donchian", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// 1. INPUTS
// ==========================================
grp_ichimoku = "Ichimoku Settings"
tenkanLen = input.int(9, "Tenkan-sen Period", minval=1, group=grp_ichimoku)
kijunLen  = input.int(26, "Kijun-sen Period", minval=1, group=grp_ichimoku)
senkouB   = input.int(52, "Senkou Span B Period", minval=1, group=grp_ichimoku)
disp      = input.int(26, "Displacement", minval=1, group=grp_ichimoku)
showTenkan = input.bool(true, "Show Tenkan", group=grp_ichimoku)
showKijun  = input.bool(true, "Show Kijun", group=grp_ichimoku)
showCloud  = input.bool(true, "Show Cloud", group=grp_ichimoku)
showChikou = input.bool(true, "Show Chikou Span", group=grp_ichimoku)

grp_donchian = "Donchian Settings"
dcLenFast = input.int(20, "Fast Band Period", group=grp_donchian)
dcLenSlow = input.int(50, "Slow Band Period", group=grp_donchian)
dcBreakLen = input.int(20, "Breakout Channel Period", group=grp_donchian)
showDC = input.bool(true, "Show Donchian Ribbon", group=grp_donchian)

// ==========================================
// 2. CALCULATIONS
// ==========================================

// Ichimoku
get_donchian(len) => math.avg(ta.highest(high, len), ta.lowest(low, len))
tenkan = get_donchian(tenkanLen)
kijun  = get_donchian(kijunLen)
spanA  = math.avg(tenkan, kijun)
spanB  = get_donchian(senkouB)

// Donchian Ribbon
dcUpperFast = ta.highest(high, dcLenFast)
dcLowerFast = ta.lowest(low, dcLenFast)
dcUpperSlow = ta.highest(high, dcLenSlow)
dcLowerSlow = ta.lowest(low, dcLenSlow)

// Donchian Breakout Logic
dcBreakUpper = ta.highest(high, dcBreakLen)[1]
dcBreakLower = ta.lowest(low, dcBreakLen)[1]

// ==========================================
// 3. PLOTTING
// ==========================================
// Ichimoku Plots
plot(showTenkan ? tenkan : na, color=color.blue, title="Tenkan-sen")
plot(showKijun ? kijun : na, color=color.red, title="Kijun-sen")
p1 = plot(showCloud ? spanA : na, offset=disp-1, color=color.green, title="Span A")
p2 = plot(showCloud ? spanB : na, offset=disp-1, color=color.red, title="Span B")
fill(p1, p2, color=spanA > spanB ? color.new(color.green, 90) : color.new(color.red, 90))
plot(showChikou ? close : na, offset=-disp+1, color=color.purple, title="Chikou Span")

// Donchian Ribbon Plots
p_uf = plot(showDC ? dcUpperFast : na, color=color.new(color.gray, 60), title="Fast Upper")
p_lf = plot(showDC ? dcLowerFast : na, color=color.new(color.gray, 60), title="Fast Lower")
p_us = plot(showDC ? dcUpperSlow : na, color=color.new(color.gray, 80), title="Slow Upper")
p_ls = plot(showDC ? dcLowerSlow : na, color=color.new(color.gray, 80), title="Slow Lower")

// Ribbon Shading
fill(p_uf, p_us, color=showDC ? color.new(color.gray, 85) : na, title="Upper Ribbon Shading")
fill(p_lf, p_ls, color=showDC ? color.new(color.gray, 85) : na, title="Lower Ribbon Shading")

// ==========================================
// 4. SIGNAL STATE MACHINE
// ==========================================
var int lastSignal = 0
bool longBreakout  = close > dcBreakUpper
bool shortBreakout = close < dcBreakLower

bool triggerLong  = longBreakout and lastSignal != 1
bool triggerShort = shortBreakout and lastSignal != -1

if triggerLong
    lastSignal := 1
if triggerShort
    lastSignal := -1

// ==========================================
// 5. ALERTS & VISUALS
// ==========================================
plotshape(triggerLong, style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny, title="Long Breakout")
plotshape(triggerShort, style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny, title="Short Breakout")

alertcondition(triggerLong, title="Donchian Long Entry", message="First Long Breakout Triggered")
alertcondition(triggerShort, title="Donchian Short Entry", message="First Short Breakout Triggered")
````
