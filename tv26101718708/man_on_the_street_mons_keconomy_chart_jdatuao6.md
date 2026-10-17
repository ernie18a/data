# Man on the Street (MonS) K-Economy Chart

- url: https://www.tradingview.com/script/JdAtUao6-Man-on-the-Street-MonS-K-Economy-Chart/
- type: indicator
- pine_id: PUB;ac10a265908c442a93ce2dd53aa9c441
- version: 1.0

## Description

This index, which I’m calling the Man on the Street (MonS) Index, is designed to track the "K-Shaped" divergence between the high-flying stock market and the lived reality of the American consumer.

While the major indices are driven by a handful of tech giants, the MonS Index monitors ten "canaries in the coal mine" across two critical pillars of the real economy:

Section 1: Discretionary Habits (The Wallet Test) DPZ / SBUX / CMG: The ultimate proxies for "stomach share." If consumers cut their $7 latte or $15 bowl, the discretionary squeeze is real.

STZ (Modelo/Corona): Tracks "vice" spending—usually the last habit to go.

ULTA: Monitors the "Lipstick Effect"—where shoppers buy small luxuries when they can't afford big ones.

Section 1: Mid-Market Reality (The Structural Test) WHR (Whirlpool): A high-conviction "big-ticket" signal. If people stop replacing appliances, the consumer is tapped out.

CTAS (Cintas): Tracks workforce health. If fewer uniforms and mats are being delivered, people aren't at work.

FL / KSS: Traditional mid-tier retail. These track the hollowing out of the middle-class shopper.

BBY (Best Buy): The "wait until next year" gauge for high-end tech and home theater.

The Thesis: We are looking for a "Snap Back." When the MonS Index sags while the SPY/QQQ stays vertical, it signals a mechanical disconnect that eventually must resolve. We stay in cash and wait for the "Pixels" to meet the "Pavement."

## Source Code

````pine
//@version=6
indicator("Man on the Street (MonS) Index v2.3", overlay=true)

// 1. Placement Setting
posInput = input.string("Bottom Left", "Table Placement", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

table_pos = position.top_right
if posInput == "Top Left"
    table_pos := position.top_left
if posInput == "Bottom Right"
    table_pos := position.bottom_right
if posInput == "Bottom Left"
    table_pos := position.bottom_left

// 2. Create the Table
var table heartbeatTable = table.new(table_pos, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

if barstate.islast
    table.cell(heartbeatTable, 0, 0, "DAILY HABITS (1-5)", text_color=color.white, text_size=size.small)
    table.cell(heartbeatTable, 1, 0, "STREET REALITY (6-10)", text_color=color.white, text_size=size.small)
    
    // Column 1: Habits
    table.cell(heartbeatTable, 0, 1, "1. Domino's (DPZ)", text_color=color.orange, text_halign=text.align_left)
    table.cell(heartbeatTable, 0, 2, "2. Starbucks (SBUX)", text_color=color.green, text_halign=text.align_left)
    table.cell(heartbeatTable, 0, 3, "3. Chipotle (CMG)", text_color=color.red, text_halign=text.align_left)
    table.cell(heartbeatTable, 0, 4, "4. Modelo/Corona (STZ)", text_color=color.yellow, text_halign=text.align_left)
    table.cell(heartbeatTable, 0, 5, "5. Ulta Beauty (ULTA)", text_color=color.fuchsia, text_halign=text.align_left)
    
    // Column 2: Reality
    table.cell(heartbeatTable, 1, 1, "6. Whirlpool (WHR)", text_color=color.white, text_halign=text.align_left)
    table.cell(heartbeatTable, 1, 2, "7. Cintas (CTAS)", text_color=color.aqua, text_halign=text.align_left)
    table.cell(heartbeatTable, 1, 3, "8. Foot Locker (FL)", text_color=color.orange, text_halign=text.align_left)
    table.cell(heartbeatTable, 1, 4, "9. Kohl's (KSS)", text_color=color.silver, text_halign=text.align_left)
    table.cell(heartbeatTable, 1, 5, "10. Best Buy (BBY)", text_color=color.orange, text_halign=text.align_left)
````
