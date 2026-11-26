# ATR Daily Time Frame Display Box

- url: https://www.tradingview.com/script/7pyA67mS-ATR-Daily-Time-Frame-Display-Box/
- type: indicator
- pine_id: PUB;6ab0c65693eb41c3a380dc17c06b99e1
- version: 2.0

## Description

ATR Display Box
A clean, minimal ATR display that sits in the corner of your chart without getting in the way.
The indicator pulls ATR from the daily timeframe regardless of what chart you're on — so whether you're on a 1 minute, 5 minute, or any intraday timeframe, you're always seeing the true daily ATR value. No more manually switching timeframes or calculating inflated period numbers to approximate a daily ATR on lower timeframes.
Features:

Always references the daily timeframe for accurate ATR readings
Adjustable ATR period (7, 9, 14 or any value you choose)
Compact table display — stays out of the way of your chart
Fully customisable: position, background colour, text colour, border colour
Adjustable decimal places to suit any instrument

Best used for:

Gauging daily range on futures (ES, NQ, CL, GC etc.)
Setting realistic profit targets and stop distances based on true daily range
Quick reference during intraday trading without cluttering your chart

Works on any instrument and any timeframe.

## Source Code

````pine
//@version=5
indicator(title="ATR Display Box (Daily)", overlay=true)

// ─── INPUTS ──────────────────────────────────────────────────────────────────
atrPeriod     = input.int(7,     title="ATR Period",     minval=1)
decimalPlaces = input.int(2,     title="Decimal Places", minval=0, maxval=8)
showLabel     = input.bool(true, title="Show 'ATR' Label")

tablePos = input.string("Bottom Right", title="Table Position",
     options=["Bottom Left", "Bottom Right", "Top Left", "Top Right", "Middle Left", "Middle Right"])

bgCol     = input.color(color.new(color.black, 15), title="Background Colour")
borderCol = input.color(color.new(color.gray, 40),  title="Border Colour")
labelCol  = input.color(color.new(color.gray, 20),  title="Label Text Colour")
valueCol  = input.color(color.white,                 title="Value Text Colour")

// ─── LOGIC — always pulls from Daily timeframe ───────────────────────────────
atrValue = request.security(syminfo.tickerid, "D", ta.atr(atrPeriod))

posMap = tablePos == "Bottom Left"  ? position.bottom_left  :
         tablePos == "Bottom Right" ? position.bottom_right :
         tablePos == "Top Left"     ? position.top_left     :
         tablePos == "Top Right"    ? position.top_right    :
         tablePos == "Middle Left"  ? position.middle_left  :
                                      position.middle_right

// ─── TABLE ───────────────────────────────────────────────────────────────────
var table atrTable = table.new(posMap, 2, 1,
     bgcolor      = bgCol,
     border_color = borderCol,
     border_width = 1,
     frame_color  = borderCol,
     frame_width  = 1)

if barstate.islast
    if showLabel
        table.cell(atrTable, 0, 0,
             text       = "ATR(" + str.tostring(atrPeriod) + "D)",
             text_color = labelCol,
             text_size  = size.small,
             bgcolor    = bgCol)
    table.cell(atrTable, 1, 0,
         text       = str.tostring(math.round(atrValue, decimalPlaces)),
         text_color = valueCol,
         text_size  = size.normal,
         bgcolor    = bgCol)
````
