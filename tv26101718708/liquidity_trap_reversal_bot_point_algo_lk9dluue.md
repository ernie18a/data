# Liquidity Trap & Reversal bot [Point algo]

- url: https://www.tradingview.com/script/LK9dLUUE-Liquidity-Trap-Reversal-bot-Point-algo/
- type: indicator
- pine_id: PUB;54a21ce20038419abee087515702e133
- version: 1.0

## Description

The Psychology of the Liquidity Trap

Retail traders are taught to place their Stop Losses just above previous swing highs or just below previous swing lows. Market makers and institutional algorithms often drive price into these "pockets of liquidity" to fill their own large orders. This script identifies the specific 111% – 113% "Sweet Spot" where these traps frequently occur.

The 111% Liquidity Trap & Reversal is a structural tool that maps out these institutional "Stop Run" zones and provides execution signals when price fails to sustain a breakout and returns to its previous range.

[b]How the Logic Works[/b]
1. Swing Identification: The script finds significant Pivot Highs and Lows based on a user-defined lookback period.

2. The Trap Zone: It calculates the Fibonacci-derived extensions specifically favored by institutional models:
[list]
[*]111% – 113%: The primary "Trap Zone" where price often wicks into before reversing.
[*]127.2%: The secondary "Deep Sweep" level.
[/list]

3. The Reversal Signal: A "REVERSAL" signal is triggered only if price penetrates the 111% zone and then crosses back inside the original pivot level. This confirms the "Sweep" and a shift in momentum.

4. Breakout/Breakdown (BO/BD): To provide a complete picture of market structure, the script also marks successful breakouts where price closes decisively beyond the pivot without reversing.

[b]Key Features[/b]
[list]
[*]Visual Trap Zones: Red (Short) and Lime (Long) zones plotted as step-lines for a clean, non-repainting view of where the traps are set.
[*]Dual-Signal Logic: Differentiates between a failed breakout (Reversal) and a successful trend continuation (BO/BD).
[*]Institutional Extensions: Uses the 1.11 and 1.13 ratios, which are mathematically grounded in price-action theory but often overlooked by standard Fibonacci tools.
[/list]

[b]How to Trade with It[/b]
[#] The Reversal: Look for a "REVERSAL" arrow. This is a high-probability setup indicating that the "Breakout Traders" have been trapped and the market is likely to rotate to the opposite end of the range.

[#] The Breakout (BO/BD): If price crosses the pivot and a "BO" or "BD" label appears without hitting the trap zone first, it signifies structural strength and trend continuation.

[#] Filtering: Use the "Pivot Lookback" setting to switch between Micro-Scalping (Lower numbers) and Macro-Trend analysis (Higher numbers).

Rules :
1. Transparency: All math—from the pivot calculations to the extension percentages—is fully visible in the source code.

2. No "Holy Grail" Claims: This is a technical analysis tool designed to identify historical price patterns. It does not predict future movements with certainty.

## Source Code

````pine
//@version=6
indicator("111% Liquidity Trap & Reversal [Quant]", overlay=true, max_labels_count=500)

// ========================================================================= //
// 1. INPUTS
// ========================================================================= //
grp_piv = "Swing & Pivot Settings"
piv_len = input.int(15, "Pivot Lookback", tooltip="Higher number finds larger macro swings. Lower number finds short-term scalping swings.", group=grp_piv)

// ========================================================================= //
// 2. SWING DETECTION & RANGE MATH
// ========================================================================= //
ph = ta.pivothigh(high, piv_len, piv_len)
pl = ta.pivotlow(low,  piv_len, piv_len)

var float last_ph     = na
var float last_pl     = na
var float swing_range = na

if not na(ph)
    last_ph := ph
    if not na(last_pl)
        swing_range := math.abs(last_ph - last_pl)

if not na(pl)
    last_pl := pl
    if not na(last_ph)
        swing_range := math.abs(last_ph - last_pl)

// ========================================================================= //
// 3. THE INSTITUTIONAL EXTENSIONS (111%, 113%, 127.2%)
// ========================================================================= //
ext_h_111 = last_ph + (swing_range * 0.11)
ext_h_113 = last_ph + (swing_range * 0.13)
ext_h_127 = last_ph + (swing_range * 0.272)

ext_l_111 = last_pl - (swing_range * 0.11)
ext_l_113 = last_pl - (swing_range * 0.13)
ext_l_127 = last_pl - (swing_range * 0.272)

// ========================================================================= //
// 4. PLOTTING THE ZONES
// ========================================================================= //
p_h_111 = plot(not na(swing_range) ? ext_h_111 : na, "High 111%",    color=color.new(color.red,    60), style=plot.style_stepline)
p_h_113 = plot(not na(swing_range) ? ext_h_113 : na, "High 113%",    color=color.new(color.red,    60), style=plot.style_stepline)
p_h_127 = plot(not na(swing_range) ? ext_h_127 : na, "High 127.2%",  color=color.new(color.maroon,  0), style=plot.style_stepline, linewidth=2)
fill(p_h_111, p_h_113, color=color.new(color.red, 85), title="Short Trap Zone")

p_l_111 = plot(not na(swing_range) ? ext_l_111 : na, "Low 111%",     color=color.new(color.lime,   60), style=plot.style_stepline)
p_l_113 = plot(not na(swing_range) ? ext_l_113 : na, "Low 113%",     color=color.new(color.lime,   60), style=plot.style_stepline)
p_l_127 = plot(not na(swing_range) ? ext_l_127 : na, "Low 127.2%",   color=color.new(color.green,   0), style=plot.style_stepline, linewidth=2)
fill(p_l_111, p_l_113, color=color.new(color.lime, 85), title="Long Trap Zone")

plot(not na(swing_range) ? last_ph : na, "Pivot High 100%", color=color.new(color.gray, 50), style=plot.style_stepline)
plot(not na(swing_range) ? last_pl : na, "Pivot Low 100%",  color=color.new(color.gray, 50), style=plot.style_stepline)

// ========================================================================= //
// 5. SIGNAL ENGINE: TURTLE SOUP REVERSAL
// ========================================================================= //
var bool short_trap_armed = false
if high >= ext_h_111
    short_trap_armed := true
if not na(ph)
    short_trap_armed := false

short_signal = short_trap_armed and ta.crossunder(close, last_ph)
if short_signal
    short_trap_armed := false

var bool long_trap_armed = false
if low <= ext_l_111
    long_trap_armed := true
if not na(pl)
    long_trap_armed := false

long_signal = long_trap_armed and ta.crossover(close, last_pl)
if long_signal
    long_trap_armed := false

plotshape(long_signal,  "Sweep Reversal Long",  shape.arrowup,   location.belowbar, color.new(color.lime, 0), size=size.normal, text="REVERSAL")
plotshape(short_signal, "Sweep Reversal Short", shape.arrowdown, location.abovebar, color.new(color.red,  0), size=size.normal, text="REVERSAL")

// ========================================================================= //
// 6. ★ NEW: BREAKOUT & BREAKDOWN SIGNALS
// ========================================================================= //
// BREAKOUT  → close crosses ABOVE the Pivot High (bullish structural break)
// BREAKDOWN → close crosses BELOW the Pivot Low  (bearish structural break)

breakout_signal   = not na(swing_range) and ta.crossover(close,  last_ph)
breakdown_signal  = not na(swing_range) and ta.crossunder(close, last_pl)

// Breakout: arrow UP shown BELOW the bar (same location as a long entry cue)
plotshape(breakout_signal,  "Breakout",  shape.arrowup,   location.belowbar, color.new(color.aqua,   0), size=size.small, text="BO")

// Breakdown: arrow DOWN shown ABOVE the bar (same location as a short entry cue)
plotshape(breakdown_signal, "Breakdown", shape.arrowdown, location.abovebar, color.new(color.orange, 0), size=size.small, text="BD")

// ========================================================================= //
// 7. ALERTS
// ========================================================================= //
alertcondition(long_signal,       "111% Liquidity Long",   "Liquidity swept at the 111% Low Extension. Bullish Reversal triggered.")
alertcondition(short_signal,      "111% Liquidity Short",  "Liquidity swept at the 111% High Extension. Bearish Reversal triggered.")
alertcondition(breakout_signal,   "Pivot High Breakout",   "Close crossed ABOVE the Pivot High. Bullish Breakout confirmed.")
alertcondition(breakdown_signal,  "Pivot Low Breakdown",   "Close crossed BELOW the Pivot Low. Bearish Breakdown confirmed.")
````
