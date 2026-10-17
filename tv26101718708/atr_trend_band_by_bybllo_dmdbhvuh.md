# ATR Trend Band by Bybllo

- url: https://www.tradingview.com/script/dMdBHvUH/
- type: indicator
- pine_id: PUB;46b90ac7ef6940c99296ded9755e5c98
- version: 2.0

## Description

ATR Trend Band by Bybllo
This indicator plots a smoothed trend line (the "rope") that only moves once price has traveled beyond an ATR-based threshold from its last position, so small back-and-forth noise is absorbed and the line only steps in the direction of a genuine move. Around that rope line, a stepped upper/lower band tracks the highs and lows of the current directional leg, and the space between the rope and each band is filled with a true color gradient — strong color near the band, fading to transparent near the rope — so the current trend direction and its "room" are visible at a glance. When the rope's direction flips, a short transition window is highlighted with its own color and an optional cloud, so brief reversals or whipsaws are visually distinguished from an established trend.
Key Features

ATR-threshold "rope" smoother: the center line only moves once price has moved beyond (ATR length × ATR multiplier) from the line's current value, filtering out minor noise while still reacting to genuine directional moves.
Stepped upper/lower band that resets to the current high/low on a fresh directional leg and then expands to track the extremes of that leg, with the opposite band computed as rope ± the ATR threshold.
True gradient cloud fill between the rope and each band, with an adjustable steepness control for how quickly the color fades toward the rope line.
Distinct up / down / transition coloring on the rope line and the outer band lines, so the current trend direction is clear without reading numbers.
Optional transition-zone cloud that highlights the short window right after a directional flip, before the new trend is considered established.
Real-price calculation via request.security() keeps the indicator consistent regardless of chart type (Heikin Ashi, Renko, etc.).

How to Use

Treat the rope line's color and slope as the current trend direction; a color change (through the transition color) signals a potential shift in direction.
Use the stepped band as a dynamic support/resistance reference for the current leg — price re-testing the band without breaking the rope's direction can be read as a continuation, while a rope flip against the band suggests the leg may be ending.
Lower the "Gradient Steepness" input for a shorter, more intense color burst near the band edges, or raise it for a smoother gradient spread across the full band width.
Turn on "Show Transition Cloud" if you want the brief post-flip window visually flagged, which can help you avoid reacting to whipsaws immediately after a direction change.
Adjust "ATR Length" and "ATR Multiplier" together to control how sensitive the rope is: a smaller multiplier reacts faster but flips more often, while a larger multiplier is slower but more stable.

Notes

The gradient fill relies on Pine's built-in fill() gradient feature, which is supported across all account tiers (free and paid).
The transition window auto-clears after 5 bars if the rope has not resumed its prior direction, so it always reflects a short, recent window rather than an indefinitely "stuck" state.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Bybllo

//@version=6
// ══════════════════════════════════════════════════════════════════
// ATR Trend Band by Bybllo
// ══════════════════════════════════════════════════════════════════
// OVERVIEW
// This indicator plots a smoothed trend line (the "rope") that only
// moves once price has traveled beyond an ATR-based threshold from
// its last position, so small back-and-forth noise is absorbed and
// the line only steps in the direction of a genuine move. Around
// that rope line, a stepped upper/lower band tracks the highs and
// lows of the current directional leg, and the space between the
// rope and each band is filled with a true color gradient - strong
// color near the band, fading to transparent near the rope - so the
// current trend direction and its "room" are visible at a glance.
// When the rope's direction flips, a short transition window is
// highlighted with its own color and an optional cloud, so brief
// reversals or whipsaws are visually distinguished from an
// established trend.
//
// WHY A "ROPE" INSTEAD OF A STANDARD MOVING AVERAGE
// A normal moving average moves on every single bar, which means it
// constantly wiggles with short-term noise and gives no clean signal
// for when a move has actually become significant. The rope line in
// this indicator behaves differently: it only advances once price
// has traveled further than (ATR Length x ATR Multiplier) away from
// the rope's current value. Until that threshold is crossed, the
// rope simply holds still - it does not creep toward price the way
// an EMA or SMA would. This means every single step the rope takes
// represents a real, ATR-scaled move, not noise, which is what makes
// its color and slope usable as a clean trend read at a glance.
//
// HOW THE STEPPED BAND IS BUILT
// While the rope holds a given direction, the band on the "active"
// side (upper band while trending up, lower band while trending
// down) expands to track the running high/low of that directional
// leg - it widens as the leg extends but never contracts mid-leg.
// The opposite ("inactive") band is instead pinned at a fixed
// distance from the rope (rope +/- the ATR threshold), since there's
// no directional leg on that side to track. The moment the rope's
// direction flips, both bands reset and the roles of "active" and
// "inactive" side swap, so the band always represents the extremes
// of the leg currently in progress.
//
// GRADIENT CLOUD FILL
// The area between the rope and each band is filled using Pine's
// native true-gradient fill() feature: color intensity is strongest
// right at the band edge and fades to fully transparent as it
// approaches the rope line, rather than being a single flat color
// across the whole band width. The "Gradient Steepness" input
// controls how quickly that fade happens - a low value concentrates
// the strong color into a narrow strip right at the band edge (a
// sharp, high-contrast look), while a value near 1.0 spreads the
// color gradually across the entire band (a soft, gentle look).
//
// TRANSITION ZONE HANDLING
// When the rope changes direction, the indicator doesn't immediately
// treat it as a fully "established" new trend - it flags a short
// transition window (colored separately from both the up and down
// colors) so you can visually tell a fresh, unconfirmed flip apart
// from a trend that's been running for a while. If price flips back
// to the prior direction while still inside this window, the
// transition is cancelled and the original direction resumes
// cleanly. If the new direction instead holds, the transition clears
// automatically. As a safety cap, the transition window also expires
// on its own after 5 bars even if direction hasn't resolved either
// way, so the chart never gets stuck showing a "transition" state
// indefinitely.
//
// CHART-TYPE COMPATIBILITY
// Price and ATR are both pulled via request.security() against the
// plain underlying ticker rather than read directly off the chart,
// so the rope, band, and threshold values are identical whether your
// chart is displaying candlesticks, Heikin Ashi, Renko, or any other
// non-standard chart type.
//
// HOW TO USE
// - Treat the rope line's color and slope as the current trend
//   direction; a color change (through the transition color) signals
//   a potential shift in direction.
// - Use the stepped band as a dynamic support/resistance reference
//   for the current leg - price re-testing the band without breaking
//   the rope's direction can be read as a continuation, while a rope
//   flip against the band suggests the leg may be ending.
// - Lower the "Gradient Steepness" input for a shorter, more intense
//   color burst near the band edges, or raise it for a smoother
//   gradient spread across the full band width.
// - Turn on "Show Transition Cloud" if you want the brief post-flip
//   window visually flagged, which can help you avoid reacting to
//   whipsaws immediately after a direction change.
// - Adjust "ATR Length" and "ATR Multiplier" together to control how
//   sensitive the rope is: a smaller multiplier reacts faster but
//   flips more often, while a larger multiplier is slower but more
//   stable.
//
// NOTES
// - The gradient fill relies on Pine's built-in fill() gradient
//   feature, which is supported across all account tiers (free and
//   paid).
// - The transition window auto-clears after 5 bars if the rope has
//   not resumed its prior direction, so it always reflects a short,
//   recent window rather than an indefinitely "stuck" state.
//
// DISCLAIMER
// For educational and informational purposes only. This is not
// financial advice. Past performance does not guarantee future
// results. Always verify how the rope and bands behave on your
// specific symbol and timeframe before relying on them for live
// trading.
// ══════════════════════════════════════════════════════════════════
indicator("ATR Trend Band by Bybllo", overlay = true)

// ═══════════════════════════════
// INPUTS
// ═══════════════════════════════
var g1 = "Parameters"
multi = input.float(1.25, "ATR Multiplier", step = 0.1, minval = 0.1, group = g1)
len   = input.int(23,    "ATR Length",     minval = 1, group = g1)

var g2 = "Display"
show_cloud    = input.bool(true, "Show Transition Cloud", group = g2)
show_gradient = input.bool(true, "Show Gradient Cloud",    group = g2)
grad_steepness = input.float(0.3, "Gradient Steepness", minval = 0.05, maxval = 1.0, step = 0.05, group = g2, tooltip = "Lower values concentrate the color intensity closer to the edges over a short distance, creating a steeper gradient (1.0 = a gentle gradient spread across the full width)")

var g3 = "Colors"
up_col  = input.color(color.yellow,           "Up",         group = g3)
dn_col  = input.color(color.fuchsia,          "Down",       group = g3)
fl_col  = input.color(#1848cc,                "Transition", group = g3)
cld_col = input.color(color.new(#1848cc, 80), "Cloud",      group = g3)
up_cloud_col = input.color(#C1440E, "Up Cloud Color",   group = g3)
dn_cloud_col = input.color(#00591F, "Down Cloud Color", group = g3)
up_line_col  = input.color(#E74C3C, "Up Line Color",    group = g3)
dn_line_col  = input.color(#2ECC71, "Down Line Color",  group = g3)

// ═══════════════════════════════
// Force real market prices regardless of chart type (Heikin Ashi,
// Renko, etc.) via request.security (ATR is also computed from real
// prices, so it's pulled the same way)
// ═══════════════════════════════
t = ticker.new(syminfo.prefix, syminfo.ticker)
[rh, rl, rc, ratr] = request.security(t, timeframe.period, [high, low, close, ta.atr(len)])

// ═══════════════════════════════
// ATR THRESHOLD
// ═══════════════════════════════
threshold = ratr * multi

// ═══════════════════════════════
// ROPE SMOOTHER
// ═══════════════════════════════
var float rope = na
rope := na(rope) ? rc : rope + math.max(math.abs(rc - rope) - threshold, 0) * math.sign(rc - rope)

// ═══════════════════════════════
// DIRECTION AND TRANSITION DETECTION
// ═══════════════════════════════
var int  last_dir      = 0
var bool in_transition = false
var int  trans_bars    = 0

if rope != rope[1]
    new_dir = rope > rope[1] ? 1 : -1
    if last_dir != 0 and new_dir != last_dir
        in_transition := true
        trans_bars    := 0
    else if in_transition and new_dir == last_dir
        in_transition := false
        trans_bars    := 0
    last_dir := new_dir

if in_transition
    trans_bars += 1
    if trans_bars > 5
        in_transition := false
        trans_bars    := 0

is_up = last_dir >= 0
col   = in_transition ? fl_col : is_up ? up_col : dn_col

// ═══════════════════════════════
// STEPPED UPPER/LOWER TRACKING
// ═══════════════════════════════
var float upper = na
var float lower = na

if last_dir != last_dir[1]
    upper := rh
    lower := rl
else
    upper := math.max(upper, rh)
    lower := math.min(lower, rl)

opp_upper = rope + threshold
opp_lower = rope - threshold

final_upper = is_up ? upper : opp_upper
final_lower = is_up ? opp_lower : lower

// ═══════════════════════════════
// MAIN LINES
// ═══════════════════════════════
// When the center line (Mid) is yellow (up_col) -> orange; otherwise (transition/down color) -> green
mid_is_yellow = col == up_col
whole_line_col = mid_is_yellow ? up_line_col : dn_line_col

p_upper = plot(final_upper, "Upper", color = whole_line_col, linewidth = 2)
p_mid   = plot(rope,        "Mid",   color = col, linewidth = 3)
p_lower = plot(final_lower, "Lower", color = whole_line_col, linewidth = 2)

// ═══════════════════════════════
// TRUE GRADIENT (uses Pine's built-in fill() gradient feature -
// supported on all account tiers, free and premium)
// ═══════════════════════════════
// When the center line is yellow, both the upper and lower sides use orange; otherwise both use green (no separate up/down distinction)
whole_cloud_col = mid_is_yellow ? up_cloud_col : dn_cloud_col
whole_fade_col  = color.new(whole_cloud_col, 100)

// Gradient control: color changes rapidly only within the grad_steepness proportion near the edge, while the rest stays transparent
up_fade_point = final_upper - (final_upper - rope) * grad_steepness
dn_fade_point = final_lower + (rope - final_lower) * grad_steepness

// Upper segment (Upper -> Mid): uses whole_cloud_col, strongest near Upper and fading to transparent quickly over a short distance
fill(p_upper, p_mid, final_upper, up_fade_point, show_gradient ? whole_cloud_col : na, show_gradient ? whole_fade_col : na, title = "Upper Gradient")

// Lower segment (Mid -> Lower): uses whole_cloud_col, transparent near Mid and intensifying quickly over a short distance near Lower
fill(p_mid, p_lower, dn_fade_point, final_lower, show_gradient ? whole_fade_col : na, show_gradient ? whole_cloud_col : na, title = "Lower Gradient")

// ═══════════════════════════════
// TRANSITION ZONE CLOUD
// ═══════════════════════════════
hu = plot(final_upper, color = in_transition and show_cloud ? color.new(fl_col, 100) : na, editable = false)
hl = plot(final_lower, color = in_transition and show_cloud ? color.new(fl_col, 100) : na, editable = false)
fill(hu, hl, in_transition and show_cloud ? cld_col : na, title = "Transition Cloud")
````
