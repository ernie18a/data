# NY Midnight Open (TDO)

- url: https://www.tradingview.com/script/cSHBASGn-ny-midnight-open-tdo/
- type: indicator
- pine_id: PUB;ad04ba3dc54a4feaa53d54a9fe517816
- version: 2.0

## Description

This indicator plots the [b]New York Midnight Open[/b], the opening price at [b]00:00 New York local time[/b].

The midnight opening price is widely used in ICT / Smart Money Concepts as an intraday reference level for evaluating price delivery, daily bias, premium/discount positioning, liquidity runs, and session expansion. The level is especially relevant during the London and New York trading sessions. ICT Trading

The indicator displays a single violet horizontal line beginning at [b]00:00 New York time[/b] and extending until [b]23:00 Kyiv time[/b]. Only the current trading day's level is shown to keep the chart clean.

The script uses the America/New_York and Europe/Kyiv time zones, allowing daylight-saving time changes to be handled automatically.

[b]Features:[/b]
[list]
[*]New York Midnight Open at 00:00 ET
[*]Current day only
[*]Violet TDO reference line
[*]TDO label displayed above the right side of the line
[*]Automatic New York and Kyiv DST handling
[*]Suitable for Forex, Gold, indices, futures and other intraday markets
[/list]

[b]Trading interpretation[/b]

In ICT-style analysis, the Midnight Open can be used as a reference point for daily directional context. Traders may observe whether price is trading above or below the level, how London reacts around it, and whether price later retraces toward or expands away from the Midnight Open. ICT Trading

The indicator does not generate buy or sell signals and should be used as a contextual reference level alongside market structure, liquidity, session timing and your own risk-management rules.

## Source Code

````pine
//@version=6
indicator("True Daily Open — NY 00:00", overlay = true, max_lines_count = 10, max_labels_count = 10)

// ─────────────────────────────────────────────────────────────────────────────
// Settings
// ─────────────────────────────────────────────────────────────────────────────
string NY_TZ   = "America/New_York"
string KYIV_TZ = "Europe/Kyiv"

color tdoColor = input.color(#7C4DFF, "TDO Color")
int   lineWidth = input.int(1, "Line Width", minval = 1, maxval = 5)

// ─────────────────────────────────────────────────────────────────────────────
// Get exact NY 00:00 open from 1-minute data
// ─────────────────────────────────────────────────────────────────────────────
f_tdo_price() =>
    bool isNYMidnight =
         hour(time, NY_TZ) == 0 and
         minute(time, NY_TZ) == 0

    ta.valuewhen(isNYMidnight, open, 0)

f_tdo_time() =>
    bool isNYMidnight =
         hour(time, NY_TZ) == 0 and
         minute(time, NY_TZ) == 0

    ta.valuewhen(isNYMidnight, time, 0)

// Exact TDO from 1-minute timeframe
[tdoPrice, tdoTime] = request.security(
     syminfo.tickerid,
     "1",
     [f_tdo_price(), f_tdo_time()],
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

// ─────────────────────────────────────────────────────────────────────────────
// Detect new TDO
// ─────────────────────────────────────────────────────────────────────────────
bool newTDO =
     not na(tdoTime) and
     (na(tdoTime[1]) or tdoTime != tdoTime[1])

// ─────────────────────────────────────────────────────────────────────────────
// Store ONLY current day's objects
// ─────────────────────────────────────────────────────────────────────────────
var line  currentTDOLine  = na
var label currentTDOLabel = na

// ─────────────────────────────────────────────────────────────────────────────
// Create current day's TDO
// ─────────────────────────────────────────────────────────────────────────────
if newTDO

    // Delete previous day's objects
    if not na(currentTDOLine)
        line.delete(currentTDOLine)

    if not na(currentTDOLabel)
        label.delete(currentTDOLabel)

    // Kyiv calendar date at NY midnight
    int kyivYear  = year(tdoTime, KYIV_TZ)
    int kyivMonth = month(tdoTime, KYIV_TZ)
    int kyivDay   = dayofmonth(tdoTime, KYIV_TZ)

    // End of line = 23:00 Kyiv
    int lineEnd = timestamp(
         KYIV_TZ,
         kyivYear,
         kyivMonth,
         kyivDay,
         23,
         0,
         0
    )

    // Violet TDO line
    currentTDOLine := line.new(
         x1 = tdoTime,
         y1 = tdoPrice,
         x2 = lineEnd,
         y2 = tdoPrice,
         xloc = xloc.bar_time,
         extend = extend.none,
         color = tdoColor,
         width = lineWidth
    )

    // TDO label at the right side, above the line
    currentTDOLabel := label.new(
         x = lineEnd,
         y = tdoPrice,
         text = "TDO",
         xloc = xloc.bar_time,
         yloc = yloc.price,
         style = label.style_label_lower_left,
         color = color.new(tdoColor, 100),
         textcolor = tdoColor,
         size = size.small
    )
````
