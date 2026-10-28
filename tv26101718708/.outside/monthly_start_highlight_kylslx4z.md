# Monthly Start Highlight

- url: https://www.tradingview.com/script/KYlsLx4z-Monthly-Start-Highlight/
- type: indicator
- pine_id: PUB;925b63b66bbd44dc9b07adc196749eb0
- version: 1.0

## Description

[b]Stop squinting at faint grid lines. See monthly boundaries instantly.[/b]

This indicator draws a bold, glowing vertical line on the first trading day of every month — so you can spot monthly transitions at a glance, even on cluttered charts.

[b]What's different?[/b]
TradingView's default session breaks are thin, grey, and blend into the background. This script makes the start of each month impossible to miss with a thick, bright line plus a soft halo effect behind it.

[b]What you get[/b]
[list]
[*]A fat, customizable vertical line on the 1st market day of each month
[*]Optional glow layer for depth against busy indicators
[*]Optional background tint on that first candle
[*]A floating month label at the top of your chart (toggle it off if you prefer clean)
[/list]

[b]Why traders care[/b]
Monthly opens often act as key psychological levels. Whether you're tracking macro cycles, option expiration flows, or just measuring your monthly P&L — knowing exactly where the month flipped helps.

[b]Inputs[/b]
[list]
[*]Line Color — pick whatever pops on your theme
[*]Glow — halo behind the line for extra contrast
[*]Line Width — go subtle or go thick
[*]Show Month Label — year-month tag at the top
[*]Highlight 1st Day Background — soft tint on the opening candle
[/list]

[b]Best on[/b]
Daily charts and higher timeframes. Works on anything, but shines on D/W/M.

Drop a like if it saves your eyes. Questions or feature requests hit the comments.

## Source Code

````pine
//@version=5
indicator("Monthly Start Highlight", overlay=true)

// ── Inputs ──
lineColor  = input.color(#FF6B35, "Line Color")           // Bright orange-red
glowColor  = input.color(color.new(#FF6B35, 70), "Glow")  // Soft halo behind it
lineWidth  = input.int(3, "Line Width", minval=1, maxval=4)
showLabel  = input.bool(true, "Show Month Label at Top")
showBg     = input.bool(true, "Highlight 1st Day Background")

// ── Detect first trading day of new month ──
isNewMonth = month(time) != month(time[1]) or barstate.isfirst

// ── Background highlight for the whole first day ──
bgcolor(showBg and isNewMonth ? color.new(lineColor, 90) : na)

// ── Draw the vertical line with a "glow" effect ──
if isNewMonth
    // Thick glow layer (behind)
    line.new(
         x1     = bar_index,
         y1     = high,
         x2     = bar_index,
         y2     = low,
         xloc   = xloc.bar_index,
         extend = extend.both,
         color  = glowColor,
         style  = line.style_solid,
         width  = 8)
    
    // Bright core line (front)
    line.new(
         x1     = bar_index,
         y1     = high,
         x2     = bar_index,
         y2     = low,
         xloc   = xloc.bar_index,
         extend = extend.both,
         color  = lineColor,
         style  = line.style_solid,
         width  = lineWidth)
    
    // Month label floating at the top
    if showLabel
        label.new(
             x        = bar_index,
             y        = high,
             text     = str.tostring(year(time)) + "-" + str.tostring(month(time)),
             xloc     = xloc.bar_index,
             yloc     = yloc.price,
             color    = lineColor,
             textcolor= color.white,
             size     = size.small,
             style    = label.style_label_down)
````
