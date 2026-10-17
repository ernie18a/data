# NQ Okawa Mini Levels

- url: https://www.tradingview.com/script/J18pfHgM-NQ-Okawa-Mini-Levels/
- type: indicator
- pine_id: PUB;99bebf3f67404f2dbbaba6f6e330a3cf
- version: 1.0

## Description

Simple price points that Okakla uses for trade entries.

## Source Code

````pine
//@version=6
indicator("NQ Okawa Mini Levels", overlay=true, max_lines_count=250, max_labels_count=250)

var bool initialized = false

if not initialized and barstate.islastconfirmedhistory

    center = int(math.floor(close / 100.0) * 100)

    for i = -20 to 20

        base = center + i * 100

        levels = array.from(
             base + 20,
             base + 33,
             base + 44,
             base + 66,
             base + 80)

        for j = 0 to 4

            lvl = array.get(levels, j)

            clr =
                 j == 0 ? color.rgb(243,187,33) :
                 j == 4 ? color.blue :
                 color.gray

            wd =
                 j == 0 or j == 4 ? 2 : 1

            line.new(
                 bar_index - 500,
                 lvl,
                 bar_index + 500,
                 lvl,
                 extend = extend.both,
                 color = clr,
                 width = wd)

            label.new(
                 bar_index,
                 lvl,
                 "Mini",
                 style = label.style_label_left,
                 color = clr,
                 textcolor = color.white,
                 size = size.tiny)

    initialized := true
````
