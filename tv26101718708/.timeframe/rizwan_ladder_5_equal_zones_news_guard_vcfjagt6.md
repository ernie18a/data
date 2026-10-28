# Rizwan Ladder | 5 Equal Zones + News Guard

- url: https://www.tradingview.com/script/VcfjAGt6-Rizwan-Ladder-5-Equal-Zones-News-Guard/
- type: indicator
- pine_id: PUB;0f4f4c6750cb465a8300bbf2e81691d7
- version: 1.0

## Description

Rizwan Ladder | 5 Equal Zones + News Guard maps the recent trading range into five evenly spaced, colour-coded levels, helping traders visualise price location and potential reaction areas.

• Green: Range low
• Light green: Lower quarter
• Yellow: Midpoint
• Orange: Upper quarter
• Red: Range high

The default lookback is five daily candles, adjustable from 2 to 20. Zone thickness adapts to ATR, with customisable settings for volatility, price labels and zone extension.

News Guard highlights user-defined time windows with background shading and “NEWS FREEZE” labels. It is a visual reminder only: it does not access live economic news, freeze levels or block trades.

Levels include the developing daily candle and can move as the range changes. The indicator displays the current ladder rather than historical signals. Buy/sell labels identify areas to watch, not confirmed entries or guaranteed support and resistance.

## Source Code

````pine
//@version=6
indicator(
     "Rizwan Ladder | 5 Equal Zones + News Guard",
     overlay = true,
     max_boxes_count = 50,
     max_labels_count = 50
)

//=====================================================================
// LADDER SETTINGS
//=====================================================================

groupLadder = "Ladder Settings"

lookbackDays = input.int(
     5,
     "Range Lookback (Trading Days)",
     minval = 2,
     maxval = 20,
     group = groupLadder
)

zoneThickness = input.float(
     0.60,
     "Zone Width / Thickness (ATR)",
     minval = 0.10,
     maxval = 3.0,
     step = 0.10,
     group = groupLadder
)

atrTimeframe = input.timeframe(
     "30",
     "ATR Timeframe",
     group = groupLadder
)

atrLength = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = groupLadder
)

extendZones = input.bool(
     true,
     "Extend Zones Both Ways",
     group = groupLadder
)

showPrices = input.bool(
     true,
     "Show Zone Prices",
     group = groupLadder
)

//=====================================================================
// NEWS GUARD SETTINGS
//=====================================================================

groupNews = "News Guard Settings"

enableNewsGuard = input.bool(
     true,
     "Enable News Guard",
     group = groupNews
)

newsTz = input.string(
     "Europe/London",
     "Timezone",
     options = [
         "Europe/London",
         "UTC",
         "America/New_York"
     ],
     group = groupNews
)

// Same windows as your previous News Guard
newsSession1 = input.session(
     "1315-1345:23456",
     "13:30 Major US News Window",
     group = groupNews
)

newsSession2 = input.session(
     "1830-2000:23456",
     "FOMC / Fed Window",
     group = groupNews
)

//=====================================================================
// NEWS GUARD LOGIC
//=====================================================================

inNews1 =
     not na(
         time(
             timeframe.period,
             newsSession1,
             newsTz
         )
     )

inNews2 =
     not na(
         time(
             timeframe.period,
             newsSession2,
             newsTz
         )
     )

isNewsActive =
     enableNewsGuard and
     (inNews1 or inNews2)

// Light red chart background during News Guard
bgcolor(
     isNewsActive
         ? color.new(color.red, 92)
         : na,
     title = "News Guard Background"
)

//=====================================================================
// ATR
//=====================================================================

atr = request.security(
     syminfo.tickerid,
     atrTimeframe,
     ta.atr(atrLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

zoneHalf =
     math.max(
         (atr * zoneThickness) / 2.0,
         syminfo.mintick * 5
     )

//=====================================================================
// 5-DAY HIGH / LOW
//=====================================================================

// Uses current live 5-day trading range
rangeHigh = request.security(
     syminfo.tickerid,
     "D",
     ta.highest(high, lookbackDays),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

rangeLow = request.security(
     syminfo.tickerid,
     "D",
     ta.lowest(low, lookbackDays),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//=====================================================================
// FIVE EQUAL LADDER LEVELS
//=====================================================================

priceRange = rangeHigh - rangeLow

// 5 zones = 4 equal gaps
ladderStep = priceRange / 4.0

level1 = rangeLow
level2 = rangeLow + ladderStep
level3 = rangeLow + ladderStep * 2.0
level4 = rangeLow + ladderStep * 3.0
level5 = rangeHigh

//=====================================================================
// BOX VARIABLES
//=====================================================================

var box box1 = na
var box box2 = na
var box box3 = na
var box box4 = na
var box box5 = na

//=====================================================================
// DISPLAY SETTINGS
//=====================================================================

zoneExtend =
     extendZones
         ? extend.both
         : extend.none

leftBar =
     math.max(
         0,
         bar_index - 25
     )

rightBar =
     bar_index + 25

//=====================================================================
// NEWS TEXT
//=====================================================================

newsText =
     isNewsActive
         ? "  ⚠ NEWS FREEZE"
         : ""

//=====================================================================
// DELETE + REDRAW LADDER
//=====================================================================

if barstate.islast and
   not na(rangeHigh) and
   not na(rangeLow) and
   priceRange > 0

    // Delete old boxes
    if not na(box1)
        box.delete(box1)

    if not na(box2)
        box.delete(box2)

    if not na(box3)
        box.delete(box3)

    if not na(box4)
        box.delete(box4)

    if not na(box5)
        box.delete(box5)

    //-------------------------------------------------------------
    // ZONE 1 — GREEN — 5 DAY SWING LOW
    //-------------------------------------------------------------

    text1 =
         "LADDER 1 • STRONG BUY / 5D LOW" +
         (showPrices
             ? "\n" + str.tostring(level1, format.mintick)
             : "") +
         newsText

    box1 := box.new(
         left = leftBar,
         top = level1 + zoneHalf,
         right = rightBar,
         bottom = level1 - zoneHalf,
         border_color =
             isNewsActive
                 ? color.gray
                 : color.green,
         border_width = 2,
         bgcolor =
             isNewsActive
                 ? color.new(color.gray, 75)
                 : color.new(color.green, 78),
         extend = zoneExtend,
         text = text1,
         text_color = color.white,
         text_size = size.small,
         text_halign = text.align_right,
         text_valign = text.align_center
     )

    //-------------------------------------------------------------
    // ZONE 2 — LIGHT GREEN
    //-------------------------------------------------------------

    text2 =
         "LADDER 2 • LOWER BUY ZONE" +
         (showPrices
             ? "\n" + str.tostring(level2, format.mintick)
             : "") +
         newsText

    box2 := box.new(
         left = leftBar,
         top = level2 + zoneHalf,
         right = rightBar,
         bottom = level2 - zoneHalf,
         border_color =
             isNewsActive
                 ? color.gray
                 : color.rgb(100, 220, 100),
         border_width = 2,
         bgcolor =
             isNewsActive
                 ? color.new(color.gray, 75)
                 : color.new(color.rgb(100, 220, 100), 78),
         extend = zoneExtend,
         text = text2,
         text_color = color.white,
         text_size = size.small,
         text_halign = text.align_right,
         text_valign = text.align_center
     )

    //-------------------------------------------------------------
    // ZONE 3 — YELLOW — EXACT MIDDLE
    //-------------------------------------------------------------

    text3 =
         "LADDER 3 • MIDDLE" +
         (showPrices
             ? "\n" + str.tostring(level3, format.mintick)
             : "") +
         newsText

    box3 := box.new(
         left = leftBar,
         top = level3 + zoneHalf,
         right = rightBar,
         bottom = level3 - zoneHalf,
         border_color =
             isNewsActive
                 ? color.orange
                 : color.yellow,
         border_width = 2,
         bgcolor =
             isNewsActive
                 ? color.new(color.gray, 65)
                 : color.new(color.yellow, 75),
         extend = zoneExtend,
         text = text3,
         text_color =
             isNewsActive
                 ? color.orange
                 : color.black,
         text_size = size.small,
         text_halign = text.align_right,
         text_valign = text.align_center
     )

    //-------------------------------------------------------------
    // ZONE 4 — ORANGE
    //-------------------------------------------------------------

    text4 =
         "LADDER 4 • UPPER SELL ZONE" +
         (showPrices
             ? "\n" + str.tostring(level4, format.mintick)
             : "") +
         newsText

    box4 := box.new(
         left = leftBar,
         top = level4 + zoneHalf,
         right = rightBar,
         bottom = level4 - zoneHalf,
         border_color =
             isNewsActive
                 ? color.gray
                 : color.orange,
         border_width = 2,
         bgcolor =
             isNewsActive
                 ? color.new(color.gray, 75)
                 : color.new(color.orange, 78),
         extend = zoneExtend,
         text = text4,
         text_color = color.white,
         text_size = size.small,
         text_halign = text.align_right,
         text_valign = text.align_center
     )

    //-------------------------------------------------------------
    // ZONE 5 — RED — 5 DAY SWING HIGH
    //-------------------------------------------------------------

    text5 =
         "LADDER 5 • STRONG SELL / 5D HIGH" +
         (showPrices
             ? "\n" + str.tostring(level5, format.mintick)
             : "") +
         newsText

    box5 := box.new(
         left = leftBar,
         top = level5 + zoneHalf,
         right = rightBar,
         bottom = level5 - zoneHalf,
         border_color =
             isNewsActive
                 ? color.gray
                 : color.red,
         border_width = 2,
         bgcolor =
             isNewsActive
                 ? color.new(color.gray, 75)
                 : color.new(color.red, 78),
         extend = zoneExtend,
         text = text5,
         text_color = color.white,
         text_size = size.small,
         text_halign = text.align_right,
         text_valign = text.align_center
     )
````
