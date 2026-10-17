# Liquidity Zones - Swing Highs & Lows

- url: https://www.tradingview.com/script/2XEqUhv9/
- type: indicator
- pine_id: PUB;faae7102336a43f68e7a79bbb0948e37
- version: 1.0

## Description

Automatically marks swing high and swing low zones where liquidity accumulates. These zones often act as support and resistance.

HOW IT WORKS:
- Red lines = Swing Highs (potential resistance)
- Green lines = Swing Lows (potential support)
- Adjustable swing detection sensitivity
- Lines extend forward to show active zones

SETTINGS:
- Swing Detection Length: Higher = fewer, stronger zones
- Toggle highs/lows display
- Adjust line extension
- Customize colors

BEST FOR:
- Support/Resistance identification
- Liquidity sweep setups
- Breakout/breakdown trading
- Price action analysis

Use with price action and volume for best results.

## Source Code

````pine
//@version=6
indicator("Liquidity Zones - Swing Points", overlay=true)

// ===== CONFIGURACIÓN =====
swing_length = input.int(10, "Swing Detection Length", minval=3, maxval=50, group="Settings")
show_highs = input.bool(true, "Show Swing Highs", group="Display")
show_lows = input.bool(true, "Show Swing Lows", group="Display")
extend_lines = input.int(20, "Extend Lines (bars)", minval=1, maxval=100, group="Display")

high_color = input.color(color.new(color.red, 20), "High Zone Color", group="Colors")
low_color = input.color(color.new(color.green, 20), "Low Zone Color", group="Colors")

// ===== DETECCIÓN SWING POINTS =====
// Swing High: precio más alto en ventana de barras
swing_high = ta.pivothigh(high, swing_length, swing_length)
// Swing Low: precio más bajo en ventana de barras  
swing_low = ta.pivotlow(low, swing_length, swing_length)

// ===== DIBUJAR LÍNEAS HORIZONTALES =====
if not na(swing_high) and show_highs
    line.new(
        x1=bar_index - swing_length, 
        y1=swing_high,
        x2=bar_index - swing_length + extend_lines,
        y2=swing_high,
        color=high_color,
        width=2,
        style=line.style_solid
    )
    label.new(
        x=bar_index - swing_length,
        y=swing_high,
        text="HH",
        style=label.style_label_down,
        color=color.new(color.red, 30),
        textcolor=color.white,
        size=size.tiny
    )

if not na(swing_low) and show_lows
    line.new(
        x1=bar_index - swing_length,
        y1=swing_low,
        x2=bar_index - swing_length + extend_lines,
        y2=swing_low,
        color=low_color,
        width=2,
        style=line.style_solid
    )
    label.new(
        x=bar_index - swing_length,
        y=swing_low,
        text="LL",
        style=label.style_label_up,
        color=color.new(color.green, 30),
        textcolor=color.white,
        size=size.tiny
    )

// ===== ALERTAS =====
alertcondition(not na(swing_high), "Swing High Formed", "New swing high detected")
alertcondition(not na(swing_low), "Swing Low Formed", "New swing low detected")
````
