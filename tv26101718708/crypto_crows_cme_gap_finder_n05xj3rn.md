# Crypto Crows CME Gap Finder

- url: https://www.tradingview.com/script/N05xj3Rn-Crypto-Crows-CME-Gap-Finder/
- type: indicator
- pine_id: PUB;f3786b54ec5f4cec992cc8dce25014c9
- version: 1.0

## Description

A simple indicator to find the CME gaps that haven't yet filled.
OnlyProTraders.com

## Source Code

````pine
//@version=6
indicator("Crypto Crows CME Gap Finder", "CME Gaps", overlay=true,
          max_boxes_count=500, max_labels_count=500)

// ───── INPUTS ─────
gFilt = "Gap Detection"
minGapPct   = input.float(0.10, "Minimum Gap Size (%)", minval=0.0, step=0.05, group=gFilt)
weekendOnly = input.bool(false, "Weekend Gaps Only (Fri close → Sun/Mon open)", group=gFilt)
maxGaps     = input.int(50, "Max Gaps to Track", minval=1, maxval=500, group=gFilt)

gDisp = "Display"
extendRight = input.bool(true, "Extend Gaps Right", group=gDisp)
showLabels  = input.bool(true, "Show Gap-Size Labels", group=gDisp)

gCol = "Colors"
upGapBg     = input.color(color.new(color.lime, 78), "Up Gap Fill",     group=gCol)
dnGapBg     = input.color(color.new(color.red,  78), "Down Gap Fill",   group=gCol)
upGapBorder = input.color(color.new(color.lime, 30), "Up Gap Border",   group=gCol)
dnGapBorder = input.color(color.new(color.red,  30), "Down Gap Border", group=gCol)

// ───── GAP STATE ─────
type Gap
    box   bx
    label lbl
    float originalTop
    float originalBottom
    float top
    float bottom
    bool  isUp

var array<Gap> gaps = array.new<Gap>()

// ───── DETECT NEW GAP ─────
prevHigh = high[1]
prevLow  = low[1]

gapUpRaw   = low > prevHigh
gapDownRaw = high < prevLow

prevClose = close[1]
upGapPct   = (prevClose != 0 and gapUpRaw)   ? (low  - prevHigh) / prevClose * 100 : 0.0
downGapPct = (prevClose != 0 and gapDownRaw) ? (prevLow - high)  / prevClose * 100 : 0.0
gapPct     = gapUpRaw ? upGapPct : downGapPct

prevDow = dayofweek(time[1])
curDow  = dayofweek(time)
isWeekendGap = (prevDow == dayofweek.friday and (curDow == dayofweek.sunday or curDow == dayofweek.monday))

sizeOK = gapPct >= minGapPct
filterOK = (not weekendOnly or isWeekendGap)

gapUp   = gapUpRaw   and sizeOK and filterOK
gapDown = gapDownRaw and sizeOK and filterOK

if (gapUp or gapDown) and barstate.isconfirmed
    isUp     = gapUp
    topPrice = isUp ? low      : prevLow
    botPrice = isUp ? prevHigh : high
    bgC      = isUp ? upGapBg     : dnGapBg
    bdC      = isUp ? upGapBorder : dnGapBorder

    newBox = box.new(
         left         = bar_index - 1,
         top          = topPrice,
         right        = bar_index,
         bottom       = botPrice,
         bgcolor      = bgC,
         border_color = bdC,
         border_width = 1,
         extend       = extendRight ? extend.right : extend.none)

    label newLbl = na
    if showLabels
        newLbl := label.new(
             x         = bar_index,
             y         = isUp ? topPrice : botPrice,
             text      = (isUp ? "▲ " : "▼ ") + str.tostring(gapPct, "#.##") + "%",
             style     = isUp ? label.style_label_down : label.style_label_up,
             color     = color.new(isUp ? color.lime : color.red, 40),
             textcolor = color.white,
             size      = size.small)

    array.push(gaps, Gap.new(newBox, newLbl, topPrice, botPrice, topPrice, botPrice, isUp))

    if array.size(gaps) > maxGaps
        old = array.shift(gaps)
        box.delete(old.bx)
        if not na(old.lbl)
            label.delete(old.lbl)

// ───── PARTIAL & FULL FILL TRACKING ─────
if array.size(gaps) > 0
    for i = array.size(gaps) - 1 to 0
        g = array.get(gaps, i)

        if g.isUp
            if low < g.top and low > g.originalBottom
                g.top := low
                box.set_top(g.bx, g.top)
                if not na(g.lbl)
                    label.set_y(g.lbl, g.top)
            if low <= g.originalBottom
                box.delete(g.bx)
                if not na(g.lbl)
                    label.delete(g.lbl)
                array.remove(gaps, i)
        else
            if high > g.bottom and high < g.originalTop
                g.bottom := high
                box.set_bottom(g.bx, g.bottom)
                if not na(g.lbl)
                    label.set_y(g.lbl, g.bottom)
            if high >= g.originalTop
                box.delete(g.bx)
                if not na(g.lbl)
                    label.delete(g.lbl)
                array.remove(gaps, i)

// ───── ALERTS ─────
alertcondition(gapUp   and barstate.isconfirmed, "New CME Up Gap",   "CME up gap detected")
alertcondition(gapDown and barstate.isconfirmed, "New CME Down Gap", "CME down gap detected")
````
