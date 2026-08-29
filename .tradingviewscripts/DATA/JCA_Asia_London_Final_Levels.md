<!-- tradingview-pine-id: PUB;3bba56826d2e4efc8afd5727a690d2cb -->
<!-- tradingviewscripts-format: 1 -->
# JCA Asia & London Final Levels

Source: https://www.tradingview.com/script/wlhv1guC-JCA-Levels/

## Description

JCA Levels automatically plots the completed Asia High, Asia Low, London High, and London Low to highlight key session liquidity levels. Designed to keep your charts clean while providing important price reference points for any trading strategy. Customize session times, colors, labels, and line width to fit your workflow.

---

## Source Code

````pine
//@version=6
indicator(
     "JCA Asia & London Final Levels",
     shorttitle="JCA Levels",
     overlay=true,
     max_lines_count=20,
     max_labels_count=20
)

//════════════════════════════════════════════════════════════════════
// SETTINGS
//════════════════════════════════════════════════════════════════════

string groupSessions = "Session Settings"
string groupDisplay = "Display Settings"
string groupColors = "Colors"

string sessionTimeZone = input.string(
     "America/New_York",
     "Session Time Zone",
     options=[
          "America/New_York",
          "America/Chicago",
          "Europe/London",
          "Etc/UTC"
     ],
     group=groupSessions
)

string asiaSession = input.session(
     "1800-0300",
     "Asia Session",
     group=groupSessions
)

string londonSession = input.session(
     "0300-0800",
     "London Session",
     group=groupSessions
)

int lineEndHour = input.int(
     16,
     "Lines End Hour",
     minval=9,
     maxval=23,
     group=groupSessions
)

bool showAsia = input.bool(
     true,
     "Show Asia High and Low",
     group=groupDisplay
)

bool showLondon = input.bool(
     true,
     "Show London High and Low",
     group=groupDisplay
)

bool showLabels = input.bool(
     true,
     "Show Labels",
     group=groupDisplay
)

int labelOffset = input.int(
     3,
     "Label Offset in Bars",
     minval=1,
     maxval=25,
     group=groupDisplay
)

int lineWidth = input.int(
     2,
     "Line Width",
     minval=1,
     maxval=5,
     group=groupDisplay
)

color asiaHighColor = input.color(
     color.aqua,
     "Asia High",
     group=groupColors
)

color asiaLowColor = input.color(
     color.blue,
     "Asia Low",
     group=groupColors
)

color londonHighColor = input.color(
     color.lime,
     "London High",
     group=groupColors
)

color londonLowColor = input.color(
     color.green,
     "London Low",
     group=groupColors
)

//════════════════════════════════════════════════════════════════════
// SESSION DETECTION
//════════════════════════════════════════════════════════════════════

bool inAsia = not na(
     time(
          timeframe.period,
          asiaSession,
          sessionTimeZone
     )
)

bool inLondon = not na(
     time(
          timeframe.period,
          londonSession,
          sessionTimeZone
     )
)

bool asiaStarted = inAsia and not inAsia[1]
bool asiaEnded = not inAsia and inAsia[1]

bool londonStarted = inLondon and not inLondon[1]
bool londonEnded = not inLondon and inLondon[1]

//════════════════════════════════════════════════════════════════════
// BUILD SESSION VALUES
//════════════════════════════════════════════════════════════════════

var float asiaHigh = na
var float asiaLow = na
var int asiaStartTime = na

var float londonHigh = na
var float londonLow = na
var int londonStartTime = na

if asiaStarted
    asiaHigh := high
    asiaLow := low
    asiaStartTime := time

else if inAsia
    asiaHigh := math.max(
         nz(asiaHigh, high),
         high
    )

    asiaLow := math.min(
         nz(asiaLow, low),
         low
    )

if londonStarted
    londonHigh := high
    londonLow := low
    londonStartTime := time

else if inLondon
    londonHigh := math.max(
         nz(londonHigh, high),
         high
    )

    londonLow := math.min(
         nz(londonLow, low),
         low
    )

//════════════════════════════════════════════════════════════════════
// LINE AND LABEL OBJECTS
//════════════════════════════════════════════════════════════════════

var line asiaHighLine = na
var line asiaLowLine = na
var line londonHighLine = na
var line londonLowLine = na

var label asiaHighLabel = na
var label asiaLowLabel = na
var label londonHighLabel = na
var label londonLowLabel = na

// Delete yesterday's complete set when a new Asia session starts.
if asiaStarted
    if not na(asiaHighLine)
        line.delete(asiaHighLine)

    if not na(asiaLowLine)
        line.delete(asiaLowLine)

    if not na(londonHighLine)
        line.delete(londonHighLine)

    if not na(londonLowLine)
        line.delete(londonLowLine)

    if not na(asiaHighLabel)
        label.delete(asiaHighLabel)

    if not na(asiaLowLabel)
        label.delete(asiaLowLabel)

    if not na(londonHighLabel)
        label.delete(londonHighLabel)

    if not na(londonLowLabel)
        label.delete(londonLowLabel)

    asiaHighLine := na
    asiaLowLine := na
    londonHighLine := na
    londonLowLine := na

    asiaHighLabel := na
    asiaLowLabel := na
    londonHighLabel := na
    londonLowLabel := na

//════════════════════════════════════════════════════════════════════
// DRAW FINAL ASIA LEVELS
//════════════════════════════════════════════════════════════════════

if asiaEnded and showAsia and not na(asiaHigh) and not na(asiaLow)
    int tradingDayEnd = timestamp(
         sessionTimeZone,
         year(time, sessionTimeZone),
         month(time, sessionTimeZone),
         dayofmonth(time, sessionTimeZone),
         lineEndHour,
         0
    )

    asiaHighLine := line.new(
         x1=asiaStartTime,
         y1=asiaHigh,
         x2=tradingDayEnd,
         y2=asiaHigh,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=asiaHighColor,
         width=lineWidth
    )

    asiaLowLine := line.new(
         x1=asiaStartTime,
         y1=asiaLow,
         x2=tradingDayEnd,
         y2=asiaLow,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=asiaLowColor,
         width=lineWidth
    )

    if showLabels
        asiaHighLabel := label.new(
             x=bar_index + labelOffset,
             y=asiaHigh,
             text="ASIA HIGH",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=asiaHighColor,
             textcolor=color.white,
             size=size.small
        )

        asiaLowLabel := label.new(
             x=bar_index + labelOffset,
             y=asiaLow,
             text="ASIA LOW",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=asiaLowColor,
             textcolor=color.white,
             size=size.small
        )

//════════════════════════════════════════════════════════════════════
// DRAW FINAL LONDON LEVELS
//════════════════════════════════════════════════════════════════════

if londonEnded and showLondon and not na(londonHigh) and not na(londonLow)
    int tradingDayEnd = timestamp(
         sessionTimeZone,
         year(time, sessionTimeZone),
         month(time, sessionTimeZone),
         dayofmonth(time, sessionTimeZone),
         lineEndHour,
         0
    )

    londonHighLine := line.new(
         x1=londonStartTime,
         y1=londonHigh,
         x2=tradingDayEnd,
         y2=londonHigh,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=londonHighColor,
         width=lineWidth
    )

    londonLowLine := line.new(
         x1=londonStartTime,
         y1=londonLow,
         x2=tradingDayEnd,
         y2=londonLow,
         xloc=xloc.bar_time,
         extend=extend.none,
         color=londonLowColor,
         width=lineWidth
    )

    if showLabels
        londonHighLabel := label.new(
             x=bar_index + labelOffset,
             y=londonHigh,
             text="LONDON HIGH",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=londonHighColor,
             textcolor=color.white,
             size=size.small
        )

        londonLowLabel := label.new(
             x=bar_index + labelOffset,
             y=londonLow,
             text="LONDON LOW",
             xloc=xloc.bar_index,
             yloc=yloc.price,
             style=label.style_label_left,
             color=londonLowColor,
             textcolor=color.white,
             size=size.small
        )

//════════════════════════════════════════════════════════════════════
// KEEP LABELS BESIDE CURRENT PRICE ACTION
//════════════════════════════════════════════════════════════════════

if showLabels
    if not na(asiaHighLabel)
        label.set_x(
             asiaHighLabel,
             bar_index + labelOffset
        )

    if not na(asiaLowLabel)
        label.set_x(
             asiaLowLabel,
             bar_index + labelOffset
        )

    if not na(londonHighLabel)
        label.set_x(
             londonHighLabel,
             bar_index + labelOffset
        )

    if not na(londonLowLabel)
        label.set_x(
             londonLowLabel,
             bar_index + labelOffset
        )

//════════════════════════════════════════════════════════════════════
// SWEEP ALERTS
//════════════════════════════════════════════════════════════════════

bool asiaHighSwept =
     not inAsia and
     not na(asiaHigh) and
     high > asiaHigh and
     close < asiaHigh

bool asiaLowSwept =
     not inAsia and
     not na(asiaLow) and
     low < asiaLow and
     close > asiaLow

bool londonHighSwept =
     not inLondon and
     not na(londonHigh) and
     high > londonHigh and
     close < londonHigh

bool londonLowSwept =
     not inLondon and
     not na(londonLow) and
     low < londonLow and
     close > londonLow

alertcondition(
     asiaHighSwept,
     title="Asia High Swept",
     message="Price swept the completed Asia High and closed below it."
)

alertcondition(
     asiaLowSwept,
     title="Asia Low Swept",
     message="Price swept the completed Asia Low and closed above it."
)

alertcondition(
     londonHighSwept,
     title="London High Swept",
     message="Price swept the completed London High and closed below it."
)

alertcondition(
     londonLowSwept,
     title="London Low Swept",
     message="Price swept the completed London Low and closed above it."
)

//════════════════════════════════════════════════════════════════════
// JERRICA & CO. ANALYTICS
//════════════════════════════════════════════════════════════════════
````
