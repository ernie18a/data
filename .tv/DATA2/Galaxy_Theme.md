<!-- tradingview-pine-id: PUB;2fb93921556e4a5790574ad5060a5b84 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Galaxy Theme

Source: https://www.tradingview.com/script/R2xTr9Sp-Galaxy-Theme/

## Description

Galaxy Theme — a purely cosmetic starfield overlay.

WHAT IT DOES
Draws a 10x10 grid of star glyphs across the chart using a fully transparent
table, so your candles, drawings and other indicators remain completely
visible underneath. There is no calculation, no signal, and no market data
involved — it is decoration only.

HOW IT WORKS
A table is created with a 100% transparent background and no borders. Each
cell is populated with a star character at varying sizes and opacities to
give a sense of depth. Because it uses a table rather than plotted objects,
it never interferes with price scaling, and it costs effectively nothing in
runtime.

HOW TO USE IT
Add it to any chart on any timeframe. It pairs well with dark chart themes.
If you use other table-based indicators (HUDs, dashboards), place those in a
different screen corner so the two don't overlap.

NOTES
This script produces no buy or sell signals and makes no claim about market
direction. It is a visual theme only.

DISCLAIMER
For educational and decorative purposes only. Nothing here is financial
advice, a recommendation, or a solicitation to trade. Trading carries risk
of loss.

---

## Source Code

````pine
//@version=6
indicator("Galaxy Theme", overlay=true)

// Create a 10x10 grid. The table background is 100% transparent so your candles remain completely visible!
var table space = table.new(position.top_left, 10, 10, bgcolor=color.new(color.black, 100), border_width=0)

// Deterministic seeds so the stars stay perfectly still and don't flicker when the price moves
var int seed1 = 17
var int seed2 = 23

if barstate.islast
    for r = 0 to 9
        for c = 0 to 9
            // Complex pseudo-randomization for a highly natural scatter effect
            int starRand = (r * seed1 + c * seed2) % 12
            
            string stardust = ""
            color starColor = color.new(color.white, 100)
            string tSize = size.small
            
            // Organic placement using varied line breaks (\n) and spacing so it doesn't look like a grid
            if starRand == 0
                stardust := "✦"
                starColor := color.new(#babbff, 30) // Soft glowing purple
                tSize := size.normal
            else if starRand == 1
                stardust := " \n\n ★"
                starColor := color.new(color.white, 50)
            else if starRand == 2
                stardust := "      ·"
                starColor := color.new(#ffd1ff, 30) // Faint pink nebula dust
            else if starRand == 3
                stardust := " \n ✦ \n "
                starColor := color.new(#9bf6ff, 30) // Distant cyan twinkle
            else if starRand == 5
                stardust := "★\n\n"
                starColor := color.new(color.white, 60)
                tSize := size.tiny
            else if starRand == 7
                stardust := "   ·   "
                starColor := color.new(#c8b6ff, 40) // Lavender
            else
                // Leave empty cells to create the dark void of deep space
                stardust := ""
            
            // THE MAGIC TRICK: width=10.0 and height=10.0 forces each cell to stretch.
            // 10 cells x 10% = exactly 100% full screen coverage edge-to-edge!
            table.cell(space, c, r, text=stardust, text_color=starColor, text_size=tSize, width=10.0, height=10.0)
````
