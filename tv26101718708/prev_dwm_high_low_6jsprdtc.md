# Prev D/W/M High Low 

- url: https://www.tradingview.com/script/6jsPRDtc-Prev-D-W-M-High-Low/
- type: indicator
- pine_id: PUB;d5b5574d5c1345bf8772fef68559a866
- version: 1.0

## Description

It reflects the PDH,PDL, PWH, PWL, PMH and PML levels. It doesn't reflect the accurate data on weekends. It will update the data the moment Market opens on Monday or after a holiday.

## Source Code

````pine
//@version=5
indicator("Prev D/W/M High Low + Labels", overlay=true)

// ───── GET PREVIOUS LEVELS ─────
pdHigh = request.security(syminfo.tickerid, "D", high[1])
pdLow  = request.security(syminfo.tickerid, "D", low[1])

pwHigh = request.security(syminfo.tickerid, "W", high[1])
pwLow  = request.security(syminfo.tickerid, "W", low[1])

pmHigh = request.security(syminfo.tickerid, "M", high[1])
pmLow  = request.security(syminfo.tickerid, "M", low[1])

// how far right label should sit
offsetBars = 10

// ───── FUNCTION TO DRAW LINE + LABEL ─────
drawLevel(level, txt, lineColor) =>
    var line ln = na
    var label lb = na
    
    // create once
    if barstate.isfirst
        ln := line.new(bar_index, level, bar_index+1, level,
             extend=extend.right, width=2, color=lineColor)
             
        lb := label.new(bar_index, level, txt,
             style=label.style_label_left,
             textcolor=color.white,
             color=lineColor,
             size=size.small)

    // update line every bar
    line.set_xy1(ln, bar_index, level)
    line.set_xy2(ln, bar_index+1, level)

    // move label ONLY on last bar → keeps it on right edge
    if barstate.islast
        label.set_xy(lb, bar_index + offsetBars, level)
        label.set_text(lb, txt)

// ───── DRAW ALL LEVELS ─────
// Previous Day (GREEN)
drawLevel(pdHigh, "PDH", color.blue)
drawLevel(pdLow,  "PDL", color.blue)

// Previous Week (ORANGE)
drawLevel(pwHigh, "PWH", color.navy)
drawLevel(pwLow,  "PWL", color.navy)

// Previous Month (RED)
drawLevel(pmHigh, "PMH", color.maroon)
drawLevel(pmLow,  "PML", color.maroon)
````
