# Fair Value Gap (FVG) Detector - Smart Money Concepts

- url: https://www.tradingview.com/script/Xd5p5WYx/
- type: indicator
- pine_id: PUB;516957d504ba420e9a5a960b42ffa29a
- version: 1.0

## Description

Detects Fair Value Gaps (FVG) - price gaps that haven't been filled yet. Popular concept in Smart Money trading.

HOW IT WORKS:
- Bullish FVG: Green boxes show upward gaps
- Bearish FVG: Red boxes show downward gaps
- Gaps often act as support/resistance zones

SETTINGS:
- Toggle bullish/bearish FVG display
- Adjust box extension length
- Customize colors

BEST FOR:
- Smart Money Concepts traders
- Price action analysis
- Support/resistance zones
- Reversal/continuation setups

Use FVGs as confluence with your strategy, not standalone signals.

## Source Code

````pine
//@version=6
indicator("Fair Value Gap Detector", overlay=true, max_boxes_count=50)

// ===== CONFIGURACIÓN =====
show_bullish = input.bool(true, "Show Bullish FVG", group="Display")
show_bearish = input.bool(true, "Show Bearish FVG", group="Display")
box_extend = input.int(20, "Box Extension (bars)", minval=1, group="Display")

bullish_color = input.color(color.new(color.green, 80), "Bullish FVG Color", group="Colors")
bearish_color = input.color(color.new(color.red, 80), "Bearish FVG Color", group="Colors")

// ===== DETECCIÓN FVG =====
// Bullish FVG: gap entre high[2] y low (vela actual)
// Significa que hay espacio sin llenar - precio saltó hacia arriba
bullish_fvg = low > high[2]
fvg_high_bull = low
fvg_low_bull = high[2]

// Bearish FVG: gap entre low[2] y high (vela actual)
// Precio saltó hacia abajo dejando gap
bearish_fvg = high < low[2]
fvg_high_bear = low[2]
fvg_low_bear = high

// ===== DIBUJAR CAJAS FVG =====
if bullish_fvg and show_bullish
    box.new(
        left=bar_index, 
        top=fvg_high_bull, 
        right=bar_index + box_extend, 
        bottom=fvg_low_bull,
        border_color=color.new(color.green, 50),
        bgcolor=bullish_color,
        border_width=1
    )

if bearish_fvg and show_bearish
    box.new(
        left=bar_index, 
        top=fvg_high_bear, 
        right=bar_index + box_extend, 
        bottom=fvg_low_bear,
        border_color=color.new(color.red, 50),
        bgcolor=bearish_color,
        border_width=1
    )

// ===== ALERTAS =====
alertcondition(bullish_fvg, "Bullish FVG", "Bullish Fair Value Gap detected")
alertcondition(bearish_fvg, "Bearish FVG", "Bearish Fair Value Gap detected")
````
