# BTC Trump China Visit

- url: https://www.tradingview.com/script/66ewVO5B-BTC-Trump-China-Visit/
- type: indicator
- pine_id: PUB;90e9e85e217440b6b144221c36fa6bd8
- version: 1.0

## Description

This script visualizes a concrete BTC price scenario built around the Trump–Xi Beijing meeting on May 15.

What's plotted:
• $79,000–$80,000 liquidity zone (Phase 1 target — sweep before May 9)
• $84,000 level (Phase 2 — speculative weekend pump on Trump media)
• May 15 vertical line — the meeting date, expected local top
• Post-May 15 slow bleed zone (Phase 3)
• Probability table: 80% slow bleed / 10% real deal rally / 10% sharp dump

The thesis: markets overpriced ceasefire signals. China won't concede before the visit — they need Trump coming to them, not the other way around. Euphoria peaks into the meeting. Reality hits after. Same mechanics as the October 2025 APEC setup, where BTC dropped from $111K to $108.5K on no joint press conference.

This is not "if we go up we go up" analysis. Concrete levels, concrete timing, full accountability.

## Source Code

````pine
//@version=6
indicator("BTC — Trump China Visit", overlay=true, max_boxes_count=10, max_lines_count=20, max_labels_count=30)

liq_low    = 79000.0
liq_high   = 80000.0
pump_level = 84000.0

box.new(bar_index - 100, liq_high, bar_index + 80, liq_low, border_color=color.red, border_width=1, bgcolor=color.new(color.red, 85))
line.new(bar_index - 100, liq_high, bar_index + 80, liq_high, color=color.red, width=2, style=line.style_dashed)
line.new(bar_index - 100, liq_low,  bar_index + 80, liq_low,  color=color.red, width=2, style=line.style_dashed)
label.new(bar_index + 5, (liq_high + liq_low) / 2, "⚡ LIQUIDITY ZONE $79–80K\nPhase 1: Sweep into Friday", style=label.style_label_left, color=color.new(color.red, 20), textcolor=color.white)

line.new(bar_index - 100, pump_level, bar_index + 80, pump_level, color=color.teal, width=2, style=line.style_dotted)
label.new(bar_index + 5, pump_level, "🎯 $84,000 — Weekend Pump\nPhase 2: Trump media euphoria — local TOP", style=label.style_label_left, color=color.new(color.teal, 20), textcolor=color.white)

line.new(bar_index + 50, liq_low - 3000, bar_index + 50, pump_level + 3000, color=color.orange, width=2)
label.new(bar_index + 50, pump_level + 2000, "⚠️ MAY 15\nTrump–Xi Beijing", style=label.style_label_down, color=color.orange, textcolor=color.black)

box.new(bar_index + 50, pump_level, bar_index + 80, liq_high, border_color=color.orange, border_width=1, bgcolor=color.new(color.orange, 85))
label.new(bar_index + 65, (pump_level + liq_high) / 2, "📉 SLOW BLEED\n80% prob", style=label.style_label_center, color=color.new(color.orange, 20), textcolor=color.white)

label.new(bar_index + 15, liq_low - 1500, "📅 Phase 1: May 9\nDown to $79–80K", style=label.style_label_up, color=color.new(color.red, 20), textcolor=color.white, size=size.small)
label.new(bar_index + 33, pump_level + 1200, "📅 Phase 2: May 10–11\nPump to $84K", style=label.style_label_down, color=color.new(color.teal, 20), textcolor=color.white, size=size.small)
label.new(bar_index + 65, liq_high + 500, "📅 Phase 3: After May 15\nSlow bleed, no upside", style=label.style_label_down, color=color.new(color.orange, 20), textcolor=color.white, size=size.small)

var t = table.new(position.top_right, 2, 4, bgcolor=color.new(color.black, 30), border_color=color.gray, border_width=1, frame_color=color.gray, frame_width=1)
if barstate.islast
    table.cell(t, 0, 0, "SCENARIO", text_color=color.yellow, text_size=size.small)
    table.cell(t, 1, 0, "PROB",     text_color=color.yellow, text_size=size.small)
    table.cell(t, 0, 1, "Slow bleed after May 15",    text_color=color.white, text_size=size.small)
    table.cell(t, 1, 1, "80%", text_color=color.red,   text_size=size.small)
    table.cell(t, 0, 2, "Real deal → rally",           text_color=color.white, text_size=size.small)
    table.cell(t, 1, 2, "10%", text_color=color.green, text_size=size.small)
    table.cell(t, 0, 3, "China rebuffs → dump",        text_color=color.white, text_size=size.small)
    table.cell(t, 1, 3, "10%", text_color=color.orange, text_size=size.small)
````
