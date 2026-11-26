# ATR Dashboard Only

- url: https://www.tradingview.com/script/wVvfqGBY-ATR-Dashboard-Only/
- type: indicator
- pine_id: PUB;1dae2142efc14518b2ebc7cb11c86f6a
- version: 1.0

## Description

A Clean Daily ATR dashboard designed for options traders to manage trades with[b] 25%, 50%, 75%, and 100%[/b] ATR targets, keeping charts free of clutter.

This indicator is not an entry signal. This indicator is intended for educational purposes and should be used alongside your own trading plan and risk management

## Source Code

````pine
//@version=6
indicator(
     "ATR Dashboard Only",
     shorttitle = "ATR Dashboard",
     overlay = true
)

//====================================================
// 1. SETTINGS
//====================================================

groupATR = "ATR Dashboard"

atrLength = input.int(
     14,
     "Daily ATR Length",
     minval = 1,
     group = groupATR
)

showDashboard = input.bool(
     true,
     "Show Dashboard",
     group = groupATR
)

dashboardChoice = input.string(
     "Bottom Right",
     "Dashboard Position",
     options = [
         "Top Right",
         "Middle Right",
         "Bottom Right",
         "Top Left",
         "Middle Left",
         "Bottom Left"
     ],
     group = groupATR
)

dashboardPosition = switch dashboardChoice
    "Top Right"    => position.top_right
    "Middle Right" => position.middle_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Middle Left"  => position.middle_left
    => position.bottom_left

//====================================================
// 2. STANDARD PRICE DATA
//====================================================

regularTicker = ticker.new(
     syminfo.prefix,
     syminfo.ticker,
     session.regular
)

regularClose = request.security(
     regularTicker,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

//====================================================
// 3. DAILY ATR AND SESSION OPEN
//====================================================

dailyATR = request.security(
     regularTicker,
     "D",
     ta.atr(atrLength)[1],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

sessionOpen = request.security(
     regularTicker,
     "D",
     open,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_on
)

upper25 = sessionOpen + dailyATR * 0.25
upper50 = sessionOpen + dailyATR * 0.50
upper75 = sessionOpen + dailyATR * 0.75
upper100 = sessionOpen + dailyATR

lower25 = sessionOpen - dailyATR * 0.25
lower50 = sessionOpen - dailyATR * 0.50
lower75 = sessionOpen - dailyATR * 0.75
lower100 = sessionOpen - dailyATR

//====================================================
// 4. HELPERS
//====================================================

f_price(float value) =>
    "$" + str.tostring(value, format.mintick)

f_distance(float target, bool upside) =>
    distance = upside ? target - regularClose : regularClose - target

    if distance <= 0
        "Reached"
    else if distance < 1
        str.tostring(math.round(distance * 100)) + " cents"
    else
        "$" + str.tostring(distance, format.mintick)

f_status(float target, bool upside) =>
    reached = upside ? regularClose >= target : regularClose <= target
    reached ? "HIT" : "OPEN"

//====================================================
// 5. DASHBOARD VALUES
//====================================================

bullishSide = regularClose >= sessionOpen

directionText = bullishSide ? "UPSIDE" : "DOWNSIDE"

directionColor =
     bullishSide ?
     color.new(color.green, 15) :
     color.new(color.red, 15)

target25 = bullishSide ? upper25 : lower25
target50 = bullishSide ? upper50 : lower50
target75 = bullishSide ? upper75 : lower75
target100 = bullishSide ? upper100 : lower100

sideIsUpside = bullishSide

//====================================================
// 6. DASHBOARD
//====================================================

var table dashboard = table.new(
     dashboardPosition,
     4,
     7,
     border_width = 1,
     frame_color = color.new(color.white, 70),
     border_color = color.new(color.white, 85)
)

if barstate.islast
    if showDashboard

        table.cell(
             dashboard,
             0,
             0,
             "VMI ATR DASHBOARD",
             text_color = color.white,
             bgcolor = directionColor
        )

        table.cell(
             dashboard,
             1,
             0,
             directionText,
             text_color = color.white,
             bgcolor = directionColor
        )

        table.cell(
             dashboard,
             2,
             0,
             "PRICE",
             text_color = color.white,
             bgcolor = directionColor
        )

        table.cell(
             dashboard,
             3,
             0,
             f_price(regularClose),
             text_color = color.white,
             bgcolor = directionColor
        )

        table.cell(
             dashboard,
             0,
             1,
             "Daily ATR(" + str.tostring(atrLength) + ")",
             text_color = color.white,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             1,
             1,
             f_price(dailyATR),
             text_color = color.white,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             2,
             1,
             "Session Open",
             text_color = color.white,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             3,
             1,
             f_price(sessionOpen),
             text_color = color.white,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             0,
             2,
             "25% ATR",
             text_color = color.black,
             bgcolor = color.yellow
        )

        table.cell(
             dashboard,
             1,
             2,
             f_price(target25),
             text_color = color.black,
             bgcolor = color.yellow
        )

        table.cell(
             dashboard,
             2,
             2,
             f_status(target25, sideIsUpside),
             text_color = color.black,
             bgcolor = color.yellow
        )

        table.cell(
             dashboard,
             3,
             2,
             f_distance(target25, sideIsUpside),
             text_color = color.black,
             bgcolor = color.yellow
        )

        table.cell(
             dashboard,
             0,
             3,
             "50% ATR",
             text_color = color.white,
             bgcolor = color.new(color.green, 10)
        )

        table.cell(
             dashboard,
             1,
             3,
             f_price(target50),
             text_color = color.white,
             bgcolor = color.new(color.green, 10)
        )

        table.cell(
             dashboard,
             2,
             3,
             f_status(target50, sideIsUpside),
             text_color = color.white,
             bgcolor = color.new(color.green, 10)
        )

        table.cell(
             dashboard,
             3,
             3,
             f_distance(target50, sideIsUpside),
             text_color = color.white,
             bgcolor = color.new(color.green, 10)
        )

        table.cell(
             dashboard,
             0,
             4,
             "75% ATR",
             text_color = color.white,
             bgcolor = color.blue
        )

        table.cell(
             dashboard,
             1,
             4,
             f_price(target75),
             text_color = color.white,
             bgcolor = color.blue
        )

        table.cell(
             dashboard,
             2,
             4,
             f_status(target75, sideIsUpside),
             text_color = color.white,
             bgcolor = color.blue
        )

        table.cell(
             dashboard,
             3,
             4,
             f_distance(target75, sideIsUpside),
             text_color = color.white,
             bgcolor = color.blue
        )

        table.cell(
             dashboard,
             0,
             5,
             "100% ATR",
             text_color = color.white,
             bgcolor = color.purple
        )

        table.cell(
             dashboard,
             1,
             5,
             f_price(target100),
             text_color = color.white,
             bgcolor = color.purple
        )

        table.cell(
             dashboard,
             2,
             5,
             f_status(target100, sideIsUpside),
             text_color = color.white,
             bgcolor = color.purple
        )

        table.cell(
             dashboard,
             3,
             5,
             f_distance(target100, sideIsUpside),
             text_color = color.white,
             bgcolor = color.purple
        )

        table.cell(
             dashboard,
             0,
             6,
             "Guide",
             text_color = color.white,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             1,
             6,
             "25 Protect",
             text_color = color.yellow,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             2,
             6,
             "50/75 Profit",
             text_color = color.lime,
             bgcolor = color.new(color.black, 10)
        )

        table.cell(
             dashboard,
             3,
             6,
             "100 Runner",
             text_color = color.purple,
             bgcolor = color.new(color.black, 10)
        )

    else
        table.clear(
             dashboard,
             0,
             0,
             3,
             6
        )
````
