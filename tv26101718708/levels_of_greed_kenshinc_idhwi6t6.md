# Levels of Greed (KenshinC)

- url: https://www.tradingview.com/script/IdHWI6t6-Levels-of-Greed-KenshinC/
- type: indicator
- pine_id: PUB;acdd272c71954150b5d4ea471d776bfe
- version: 1.0

## Description

// ─────────────────────────────────────────────────────────────────────────────
//        [b]            🔥 LEVELS OF GREED (KenshinC) 🔥[/b]
// ─────────────────────────────────────────────────────────────────────────────
//
//   Tired of guessing when the market is getting dangerously euphoric?
//   Want to see the invisible force of greed directly on your chart?
//
//   Levels of Greed is a powerful psychological visualization tool that 
//   divides the price range from a major low to extreme greed levels into 
//   9 clear emotional stages — from "😌 Calm" all the way to "💀 Extreme Greed".
//
//   Each level has increasing line thickness and emotional labels, making it 
//   incredibly easy to read market sentiment at a glance.
//
//   Whether you're a scalper, swing trader, or long-term holder, this indicator 
//   helps you:
//   • Spot when greed is taking over the market
//   • Avoid buying at emotional peaks
//   • Recognize potential topping zones
//   • Stay disciplined during euphoric rallies
//
[b]//   Features:[/b]
//   • 3 Calculation Modes: Auto • Manual • Dynamic by Market Cap
//   • Custom Start Date (default: BTC 2022 bottom)
//   • Two display modes: "Cool Guys Mode" (with emojis) & "Serious Guys Mode"
//   • Clean, extendable horizontal levels with dynamic thickness
//   • Works on Bitcoin, altcoins, and any other asset
//
//   "In crypto, price is just a number. 
//    Greed is the real driver."
//
//   Built with passion by KenshinC 🇻🇳
//
// ─────────────────────────────────────────────────────────────────────────────

## Source Code

````pine
//@version=5
indicator("Levels of Greed (KenshinC)", overlay=true, max_labels_count=500, max_lines_count=500)

// ── Inputs ─────────────────────────────────────
calc_mode     = input.string(defval="Manual", options=["Auto", "Manual", "Dynamic by Market Cap"], title="Calculation Mode")

// Auto Mode
length        = input.int(defval=500, minval=50, maxval=2000, title="Length (used in Auto mode)")

// Multiplier
multiplier    = input.float(defval=10.0, minval=2.0, maxval=100.0, step=0.5, title="Multiplier")

// Manual Mode
manual_low    = input.float(defval=15760.0, title="Manual Low Price (default = 2022 Low)")

// Start Date - Default is the lowest price day of BTC in 2022 (Nov 21, 2022)
start_date    = input.time(defval=timestamp("2022-11-21"), title="Start Date (lines begin from this date)")

display_mode  = input.string(defval="Cool Guys Mode", options=["Cool Guys Mode", "Serious Guys Mode"], title="Label Display Mode")

// ── Determine fixed_low based on mode ─────────────────────────
fixed_low = switch calc_mode
    "Auto"                  => nz(ta.lowest(low, length)[1], ta.lowest(low, length))
    "Dynamic by Market Cap" => manual_low   // You can improve this logic later if needed
    => manual_low

fixed_high = fixed_low * multiplier

step_size = (fixed_high - fixed_low) / 9

greed_level_1 = fixed_low + 1 * step_size
greed_level_2 = fixed_low + 2 * step_size
greed_level_3 = fixed_low + 3 * step_size
greed_level_4 = fixed_low + 4 * step_size
greed_level_5 = fixed_low + 5 * step_size
greed_level_6 = fixed_low + 6 * step_size
greed_level_7 = fixed_low + 7 * step_size
greed_level_8 = fixed_low + 8 * step_size
greed_level_9 = fixed_low + 9 * step_size

greed_levels_color = color.new(color.green, 0)

// ── Calculate x_start from Start Date ─────────────────
var int x_start = na
if barstate.isfirst or ta.change(start_date) != 0
    for i = 0 to 5000
        if time[i] <= start_date and (i == 0 or time[i+1] > start_date)
            x_start := bar_index - i
            break

x_start := na(x_start) ? bar_index - 730 : x_start

// ── Variables ──────────────────────────────────
var line base_line = na
var line l1 = na
var line l2 = na
var line l3 = na
var line l4 = na
var line l5 = na
var line l6 = na
var line l7 = na
var line l8 = na
var line l9 = na
var line top_line = na

var label lbl1 = na
var label lbl2 = na
var label lbl3 = na
var label lbl4 = na
var label lbl5 = na
var label lbl6 = na
var label lbl7 = na
var label lbl8 = na
var label lbl9 = na

// ── Update condition ───────────────────────────
low_changed    = not na(fixed_low) and ta.change(fixed_low) != 0
start_changed  = ta.change(start_date) != 0
multi_changed  = ta.change(multiplier) != 0
manual_changed = ta.change(manual_low) != 0
mode_changed   = calc_mode != calc_mode[1]

update_now     = barstate.isfirst or low_changed or start_changed or multi_changed or manual_changed or mode_changed

// ── Draw Lines ─────────────────────────────────
if update_now
    line.delete(base_line)
    line.delete(l1)
    line.delete(l2)
    line.delete(l3)
    line.delete(l4)
    line.delete(l5)
    line.delete(l6)
    line.delete(l7)
    line.delete(l8)
    line.delete(l9)
    line.delete(top_line)

    x_end = bar_index + 100

    base_line := line.new(x_start, fixed_low,  x_end, fixed_low,  extend=extend.both, color=greed_levels_color, width=1)
    l1        := line.new(x_start, greed_level_1, x_end, greed_level_1, extend=extend.both, color=greed_levels_color, width=1)
    l2        := line.new(x_start, greed_level_2, x_end, greed_level_2, extend=extend.both, color=greed_levels_color, width=2)
    l3        := line.new(x_start, greed_level_3, x_end, greed_level_3, extend=extend.both, color=greed_levels_color, width=3)
    l4        := line.new(x_start, greed_level_4, x_end, greed_level_4, extend=extend.both, color=greed_levels_color, width=4)
    l5        := line.new(x_start, greed_level_5, x_end, greed_level_5, extend=extend.both, color=greed_levels_color, width=5)
    l6        := line.new(x_start, greed_level_6, x_end, greed_level_6, extend=extend.both, color=greed_levels_color, width=6)
    l7        := line.new(x_start, greed_level_7, x_end, greed_level_7, extend=extend.both, color=greed_levels_color, width=7)
    l8        := line.new(x_start, greed_level_8, x_end, greed_level_8, extend=extend.both, color=greed_levels_color, width=8)
    l9        := line.new(x_start, greed_level_9, x_end, greed_level_9, extend=extend.both, color=greed_levels_color, width=9)
    top_line  := line.new(x_start, fixed_high, x_end, fixed_high, extend=extend.both, color=greed_levels_color, width=1)

// ── Create Labels once ─────────────────────────
if update_now
    label.delete(lbl1)
    label.delete(lbl2)
    label.delete(lbl3)
    label.delete(lbl4)
    label.delete(lbl5)
    label.delete(lbl6)
    label.delete(lbl7)
    label.delete(lbl8)
    label.delete(lbl9)

    coolmode = display_mode == "Cool Guys Mode"
    offset = 8

    if coolmode
        lbl1 := label.new(bar_index + offset, greed_level_1, "😌 Calm",           style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl2 := label.new(bar_index + offset, greed_level_2, "🤔 Thinking",       style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl3 := label.new(bar_index + offset, greed_level_3, "🤨 Excited",        style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl4 := label.new(bar_index + offset, greed_level_4, "😮 Thrilled",       style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl5 := label.new(bar_index + offset, greed_level_5, "🤬 Greed",          style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl6 := label.new(bar_index + offset, greed_level_6, "😖 Eager",          style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl7 := label.new(bar_index + offset, greed_level_7, "😱 Frenzy",         style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl8 := label.new(bar_index + offset, greed_level_8, "😵 Crazy",          style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl9 := label.new(bar_index + offset, greed_level_9, "💀 Extreme Greed",  style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
    else
        lbl1 := label.new(bar_index + offset, greed_level_1, "1", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl2 := label.new(bar_index + offset, greed_level_2, "2", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl3 := label.new(bar_index + offset, greed_level_3, "3", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl4 := label.new(bar_index + offset, greed_level_4, "4", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl5 := label.new(bar_index + offset, greed_level_5, "5", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl6 := label.new(bar_index + offset, greed_level_6, "6", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl7 := label.new(bar_index + offset, greed_level_7, "7", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl8 := label.new(bar_index + offset, greed_level_8, "8", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)
        lbl9 := label.new(bar_index + offset, greed_level_9, "9", style=label.style_label_left, textcolor=color.white, color=color.black, size=size.small)

// ── Debug plots ────────────────────────────────
plot(fixed_low,  title="Fixed Low",  color=color.red,   linewidth=1)
plot(fixed_high, title="Fixed High", color=color.orange, linewidth=1)
````
