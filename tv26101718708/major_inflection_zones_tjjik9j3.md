# Major Inflection Zones

- url: https://www.tradingview.com/script/tjjik9j3-Major-Inflection-Zones/
- type: indicator
- pine_id: PUB;234a975a226c4ba3a42342a8ef62a5b4
- version: 1.0

## Description

[b]Major Inflection Zones[/b]
[i]A market structure tool that automatically detects when the market is "sleeping" — moving sideways with low energy — and draws boxes around those quiet periods. When price finally wakes up and breaks out of the box, the indicator flags it as a potential major move. Think of it like drawing a fence around a sleeping bull; when the bull breaks through the fence, you know something big is happening.[/i]
[b]What This Actually Does (In Plain English)[/b]
Markets spend most of their time moving sideways — what traders call "consolidation" or "chop." During these periods, buyers and sellers are roughly balanced, and price bounces around in a range. The ADX (Average Directional Index) is a built-in indicator that measures trend strength. When ADX is low, there's no trend — the market is asleep. When ADX spikes, a trend is waking up.
This indicator:
[list]
[*]Watches ADX continuously to spot when it drops below a "sleep threshold"
[*]When ADX is sleeping, it tracks the highest high and lowest low of that quiet period
[*]Draws a box around that range and extends it forward in time
[*]When ADX wakes up (crosses above a "wake threshold"), it finalizes the box
[*]If price then breaks out of the box, it colors the box and fires a signal
[*]The box stops extending and gets "locked" at the breakout bar
[/list]
[b]The Core Concept: Energy → Consolidation → Explosion[/b]
[list]
[*][b]Low Energy (ADX below threshold):[/b] The market is building up pressure like a coiled spring. No one is in control yet. This is when the indicator starts tracking the range.
[*][b]Consolidation Box Forms:[/b] The indicator draws a rectangle from the start of the low-energy period to the current bar, showing the "sleeping range."
[*][b]Energy Returns (ADX above threshold):[/b] The spring is releasing. The box finalizes and the indicator waits for price to pick a direction.
[*][b]Breakout:[/b] Price escapes the box. The indicator colors the box green (up) or red (down) and fires an arrow signal.
[/list]
[b]All The Settings Explained[/b]
[i]ADX Detection[/i]
[list]
[*][b]ADX Length:[/b] How many bars ADX looks at to calculate trend strength. Default 33. Shorter (14) = more sensitive, catches quicker shifts between chop and trend. Longer (50) = smoother, only catches major regime changes.
[*][b]ADX Low Threshold:[/b] The "sleep" level. When ADX drops below this, consolidation tracking begins. Default 5. Very low — this catches only the quietest, most exhausted markets. Raise to 10–15 if you want to catch more consolidation periods (but they'll be less significant).
[*][b]ADX High Threshold:[/b] The "wake" level. When ADX rises above this, the consolidation period ends and the box finalizes. Default 10. This must be higher than the low threshold. The gap between low and high creates a "dead zone" where the indicator is deciding whether the market is truly waking up or just twitching in its sleep.
[/list]
[i]Consolidation Requirements[/i]
[list]
[*][b]Minimum Consolidation Bars:[/b] How long the market must be quiet before a box is worth drawing. Default 30. This filters out tiny 5-bar pauses that aren't significant. Raise to 50+ for only major structural consolidations. Lower to 15 if you want to catch smaller pauses (more signals, less significance).
[/list]
[b]How To Read The Chart[/b]
[list]
[*][b]Blue Boxes (Extending Right):[/b] Active consolidation zones. The market is currently quiet within this range. The box extends to the right because the consolidation is ongoing — the indicator doesn't know when it will end. These are "watch and wait" zones.
[*][b]Green Boxes (Locked):[/b] A consolidation zone where price broke out [b]upward[/b]. The right edge is snapped to the breakout bar. This was a sleeping range that became support — once broken upward, it often acts as a floor on pullbacks.
[*][b]Red Boxes (Locked):[/b] A consolidation zone where price broke out [b]downward[/b]. The right edge is snapped to the breakout bar. This was a sleeping range that became resistance — once broken downward, it often acts as a ceiling on bounces.
[*][b]Green Arrow (Below Bar):[/b] Upward breakout signal. Price closed above the top of a finalized consolidation zone. Potential bullish move beginning.
[*][b]Red Arrow (Above Bar):[/b] Downward breakout signal. Price closed below the bottom of a finalized consolidation zone. Potential bearish move beginning.
[*][b]Purple Line (Sub-panel):[/b] The raw ADX value for reference. You can see it dipping below the red threshold (consolidation starts) and rising above the green threshold (consolidation ends).
[/list]
[b]Practical Trading Strategies[/b]
[i]The "Breakout Follow" Play (Beginner-Friendly)[/i]
[list]
[*]Wait for a [b]green or red arrow[/b] to appear
[*]This means price just escaped a significant consolidation zone
[*]Enter in the breakout direction on the next bar or on a pullback to the broken box edge
[*]Stop-loss: Just inside the opposite edge of the box (below the box top for longs, above the box bottom for shorts)
[*]Target: The height of the box projected from the breakout point (if box was $5 tall, target $5 beyond the breakout)
[*]This is classic "range expansion" trading — the market was coiled, now it's moving
[/list]
[i]The "Box Edge Bounce" Play[/i]
[list]
[*]When price approaches a [b]locked green box[/b] from above (pulling back to it)
[*]The top edge of that green box often acts as support — it was resistance before, now it's support
[*]Look for bullish candle patterns at the box edge (hammer, engulfing, strong close)
[*]Enter long with stop-loss just below the box
[*]Same logic in reverse for red boxes — their bottom edge often acts as resistance on bounces
[/list]
[i]The "Consolidation Accumulation" Play (Advanced)[/i]
[list]
[*]When a [b]blue box[/b] is active and extending (market still quiet)
[*]If you have a directional bias from higher timeframes, you can position inside the box before the breakout
[*]Place a buy order near the box bottom and a sell order near the box top
[*]When one triggers, cancel the other and ride the breakout
[*]Risk: The market might break out in the "wrong" direction or chop longer than expected
[*]Only for patient traders with strong higher-timeframe conviction
[/list]
[i]The "ADX Filter" Approach[/i]
[list]
[*]Use the purple ADX line as a [b]trade filter[/b]
[*]When ADX is below the low threshold (red line) — [b]do not trend-trade[/b]. The market is asleep. Use range-bound strategies or wait.
[*]When ADX is between thresholds — cautious. The market is stirring but not committed.
[*]When ADX is above the high threshold (green line) — [b]trend-trading is viable[/b]. Momentum exists. Follow breakouts and hold positions longer.
[/list]
[b]Important Things To Know[/b]
[list]
[*][b]ADX Is Not Directional:[/b] ADX only measures [b]strength[/b], not direction. A high ADX means a strong trend — but it could be up OR down. The breakout direction (green vs red arrow) tells you which way the market chose. Never assume ADX rising means bullish — it just means "something is happening."
[*][b]Boxes Are Memory-Limited:[/b] The indicator stores active boxes in an array and removes them when broken. There is no hard limit, but very long charts with many unbroken boxes may slow performance. The locked (broken) boxes remain on chart as historical reference.
[*][b]The Gap Between Thresholds Matters:[/b] Low=5 and High=10 creates a 5-point "decision zone." If you set Low=15 and High=20, the market must be very quiet to start tracking and moderately energetic to finalize. This catches fewer but more significant consolidations. If you set Low=5 and High=50, almost every pause will create a box but few will ever finalize — not useful.
[*][b]Minimum Bars Filters Noise:[/b] The 30-bar minimum prevents tiny 3-bar pauses from cluttering your chart. On a 1-minute chart, 30 bars is 30 minutes — reasonable. On a daily chart, 30 bars is a month and a half — very significant. Adjust this to your timeframe.
[*][b]Breakouts Can Be False:[/b] A breakout arrow fires immediately when close crosses the box edge. But price can immediately retreat back into the box. This is a "fakeout." No indicator can prevent this. Use the box edge as your stop-loss reference — if price re-enters the box, your stop is hit.
[*][b]Boxes Extend Until Broken or ADX Wakes:[/b] An active blue box keeps extending right every bar until either (a) ADX rises above the high threshold (finalizing it for breakout watch), or (b) price breaks out (locking it). If neither happens for hundreds of bars, the box just keeps growing — this is normal and reflects a very long, quiet market.
[*][b]No Repainting:[/b] Once a box is drawn, its left, top, and bottom edges are fixed. The right edge extends forward until locked. Breakout signals use confirmed close prices. Historical boxes and signals do not shift.
[*][b]The DMI Calculation Uses Fixed Parameters:[/b] The code calls ta.dmi(adx_len, 1) — the "1" is the smoothing factor for DI+ and DI-. This is hardcoded and not user-adjustable in this version. It produces a very responsive ADX.
[/list]
[b]Common Mistakes To Avoid[/b]
[list]
[*][b]Trading Every Breakout:[/b] Not all breakouts lead to sustained trends. A breakout from a 10-bar micro-consolidation is less significant than one from a 100-bar major base. Check the box's horizontal width — wider boxes = more significant.
[*][b]Ignoring Volume:[/b] The indicator doesn't use volume. A breakout on massive volume is much more reliable than one on thin volume. Add volume confirmation manually — look for 2× average volume on breakout bars.
[*][b]Forgetting Higher Timeframe Context:[/b] A breakout on the 15-minute chart might just be noise within a larger daily consolidation. Check if your current blue box aligns with a bigger box on a higher timeframe — those are the highest-probability setups.
[*][b]Chasing Late Breakouts:[/b] The best entries are near the box edge when the breakout first fires. Entering 10+ bars after the arrow often means the move has already extended and is due for a pullback.
[*][b]Using Default Settings on All Timeframes:[/b] ADX 33 with thresholds 5/10 works well on daily and 4-hour charts. On 1-minute charts, you may want ADX 14 with thresholds 10/20 for faster reaction. On weekly charts, ADX 50 with thresholds 3/8 catches only major secular shifts.
[*][b]Expecting Instant Finalization:[/b] ADX can stay below the low threshold for extended periods. The indicator patiently waits. Don't force trades inside blue boxes — the whole point is to wait for the breakout.
[/list]

## Source Code

````pine
//@version=5
indicator("Major Inflection Zones", overlay=true)

// Inputs
adx_len = input.int(33, title="ADX Length", minval=1)
adx_low_thresh = input.int(5, title="ADX Low Threshold", minval=1)
adx_high_thresh = input.int(10, title="ADX High Threshold", minval=1)
min_cons_bars = input.int(30, title="Minimum Consolidation Bars", minval=1)

// Calculate ADX

[_,_,adx_val] = ta.dmi(adx_len,1)

// Variables for tracking consolidation periods
var bool in_consolidation = false
var float cons_high = na
var float cons_low = na
var int cons_start = na

// Array to store active zone boxes
var array<box> active_zones = array.new<box>()

// Breakout flags
bool up_break = false
bool down_break = false

// Logic to detect start, update, and end of consolidation
if not in_consolidation and adx_val < adx_low_thresh
    in_consolidation := true
    cons_high := high
    cons_low := low
    cons_start := bar_index

if in_consolidation
    cons_high := math.max(cons_high, high)
    cons_low := math.min(cons_low, low)

if in_consolidation and adx_val > adx_high_thresh
    in_consolidation := false
    if bar_index - cons_start >= min_cons_bars
        // Create a new box for the zone, extending to the right
        new_box = box.new(left=cons_start, top=cons_high, right=bar_index, bottom=cons_low,
                          border_color=color.blue, bgcolor=color.new(color.blue, 90),
                          extend=extend.right, border_width=1)
        array.push(active_zones, new_box)

// Check each active zone for breaks on every bar
if array.size(active_zones) > 0
    for i = array.size(active_zones) - 1 to 0
        zone_box = array.get(active_zones, i)
        zone_top = box.get_top(zone_box)
        zone_bottom = box.get_bottom(zone_box)
        if close > zone_top
            up_break := true
            box.set_border_color(zone_box, color.green)
            box.set_bgcolor(zone_box, color.new(color.green, 90))
            box.set_extend(zone_box, extend.none)
            box.set_right(zone_box, bar_index)
            array.remove(active_zones, i)
        else if close < zone_bottom
            down_break := true
            box.set_border_color(zone_box, color.red)
            box.set_bgcolor(zone_box, color.new(color.red, 90))
            box.set_extend(zone_box, extend.none)
            box.set_right(zone_box, bar_index)
            array.remove(active_zones, i)

// Plot breakout arrows
plotshape(up_break, title="Up Breakout", style=shape.labelup, location=location.belowbar, color=color.green, size=size.normal)
plotshape(down_break, title="Down Breakout", style=shape.labeldown, location=location.abovebar, color=color.red, size=size.normal)

// Plot ADX for reference (optional)
plot(adx_val, title="ADX", color=color.purple)
hline(adx_low_thresh, "Low Thresh", color=color.red)
hline(adx_high_thresh, "High Thresh", color=color.green)// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Cmo22
````
