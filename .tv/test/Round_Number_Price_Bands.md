<!-- tradingview-pine-id: PUB;915cb3b5c90340108f31d18ae962e207 -->
<!-- tradingviewscripts-format: 1 -->
# Round Number Price Bands

Source: https://www.tradingview.com/script/NwGkDM7F-Round-Number-Price-Bands/

## Description

Highlight color bands at price levels

For any time frame.

---

## Source Code

````pine
//@version=6
indicator("Round Number Price Bands", overlay=true, max_boxes_count=500, max_labels_count=500)

// ---- Inputs ----
priceStart   = input.float(50, "Price Range Start")
priceEnd     = input.float(500, "Price Range End")
roundStep    = input.float(50, "Round Number Step (e.g. 50 = every $50)", minval=0.01)

customLevelsStr = input.string("", "Extra Custom Levels (comma-separated, e.g. 55.50,78.50)")

instrumentType = input.string("Auto", "Instrument Type", options=["Auto", "Futures", "Stock"])
futuresTicks   = input.int(2, "Futures: Ticks Above/Below", minval=1)
stockCents     = input.float(0.05, "Stock: $ Above/Below", minval=0.01, step=0.01)

bandColor    = input.color(color.new(color.blue, 0), "Band Color")
shadePct     = input.float(0, "Lighten (+) / Darken (-) %", minval=-100, maxval=100, step=5)
transparency = input.int(85, "Transparency", minval=0, maxval=100)
borderColor  = input.color(color.new(color.gray, 0), "Border Color")

labelText  = input.string("", "Label Text (blank = show price)")
labelPos   = input.string("Right", "Label X Position", options=["Left", "Center", "Right"])
labelColor = input.color(color.black, "Label Text Color")
labelSize  = input.string(size.small, "Label Size", options=[size.tiny, size.small, size.normal, size.large])

// ---- Determine offset (tick/cent buffer) ----
isFutures = instrumentType == "Auto" ? syminfo.type == "futures" : instrumentType == "Futures"
offset = isFutures ? syminfo.mintick * futuresTicks : stockCents

// ---- Lighten/Darken function ----
shadeColor(col, pct) =>
    r = color.r(col)
    g = color.g(col)
    b = color.b(col)
    if pct > 0
        r := r + (255 - r) * pct / 100
        g := g + (255 - g) * pct / 100
        b := b + (255 - b) * pct / 100
    else if pct < 0
        r := r * (100 + pct) / 100
        g := g * (100 + pct) / 100
        b := b * (100 + pct) / 100
    color.rgb(math.round(r), math.round(g), math.round(b))

finalColor = color.new(shadeColor(bandColor, shadePct), transparency)

// ---- Build level list ----
var float[] levels = array.new_float()

buildLevels() =>
    array.clear(levels)
    // round-number levels across the range
    if roundStep > 0 and priceEnd > priceStart
        lvl = math.ceil(priceStart / roundStep) * roundStep
        while lvl <= priceEnd
            array.push(levels, lvl)
            lvl += roundStep
    // custom extra levels
    if str.length(customLevelsStr) > 0
        parts = str.split(customLevelsStr, ",")
        for p in parts
            trimmed = str.trim(p)
            if str.length(trimmed) > 0
                val = str.tonumber(trimmed)
                if not na(val)
                    array.push(levels, val)

// ---- Draw once on first bar, extend both directions ----
if barstate.isfirst
    buildLevels()
    for lvl in levels
        top = lvl + offset
        bottom = lvl - offset
        box.new(left=bar_index, top=top, right=bar_index, bottom=bottom, extend=extend.both, bgcolor=finalColor, border_color=borderColor)

        xPos = labelPos == "Left" ? bar_index - 500 : labelPos == "Right" ? bar_index + 500 : bar_index
        txt = str.length(labelText) > 0 ? labelText : str.tostring(lvl)
        label.new(x=xPos, y=lvl, text=txt, xloc=xloc.bar_index, style=label.style_label_center, textcolor=labelColor, size=labelSize, color=color.new(color.white, 100))
````
