<!-- tradingview-pine-id: PUB;f8ae7dff518f42bca59e7c3c8334f3a3 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# FW_ML

Source: https://www.tradingview.com/script/2yU2QBRZ-FW-ML/

## Description

A+ Key Trading Levels Pro

A+ Key Trading Levels Pro is an intraday trading indicator designed to give traders a clean, quick view of important support/resistance levels and overall directional alignment.

The indicator automatically plots several commonly watched market levels directly on the chart:

Previous Day High and Low
Previous Week High and Low
Premarket High and Low
First 5-Minute High and Low

Each level extends across the chart and can be customized by color, thickness, line style, label size, and label transparency. Price labels can also display the exact dollar value of each level for faster chart reading.

The indicator also includes a compact A+ Trade Checklist designed to help traders quickly evaluate bullish or bearish alignment without cluttering the chart.

The checklist evaluates:

Previous Day range
Premarket range
Previous Week range
First 5-Minute range
VWAP
1-Minute 9 EMA

Bullish conditions display in green, bearish conditions display in red, and neutral or inside conditions remain neutral.

When all six bullish criteria align, the checklist displays:

A+ CALL

When all six bearish criteria align, the checklist displays:

A+ PUT

The purpose of the checklist is not to generate automatic trade entries, but to provide a fast visual summary of market structure and directional confluence.

Key Features
Automatic intraday support and resistance levels
Previous day and previous week levels
Premarket high and low
Opening 5-minute range
Full-width horizontal levels
Exact price labels
Transparent label option
Customizable colors and line styles
Compact A+ checklist
Bullish and bearish directional scoring
VWAP confirmation
1-minute 9 EMA confirmation
Designed for intraday trading on liquid stocks and ETFs
Suggested Use

This indicator is primarily intended for intraday traders looking for confluence around major market levels. It can be used to quickly identify whether price is trading above, below, or inside important reference areas before considering a trade setup.

For example, a trader may use an A+ CALL reading as confirmation that multiple bullish conditions are aligned, while an A+ PUT reading indicates bearish alignment.

It should be used alongside proper risk management, price action, volume, market context, and the trader’s own strategy.

Important Note

The first 5-minute levels are based on the opening 9:30 AM–9:35 AM Eastern Time candle. Premarket levels are calculated from the 4:00 AM–9:30 AM Eastern Time session, so extended-hours data should be enabled when applicable.

This indicator is for informational and educational purposes only and does not constitute financial advice or guarantee future results.

For the TradingView title, I’d use:

A+ Key Trading Levels Pro | PDH/PDL + PM + 5M + Checklist

And for the short description:

Clean intraday key levels with previous day/week, premarket, opening 5-minute range, VWAP, 9 EMA, and a compact bullish/bearish A+ checklist.

---

## Source Code

````pine
//@version=6
indicator(
     "FW_ML",
     shorttitle="FW_ML",
     overlay=true,
     max_lines_count=50,
     max_labels_count=50)

//====================================================================
// PRICE LEVEL SETTINGS
//====================================================================

showPDH = input.bool(
     true,
     "Previous Day High",
     group="PRICE LEVELS",
     display=display.none)

showPDL = input.bool(
     true,
     "Previous Day Low",
     group="PRICE LEVELS",
     display=display.none)

showPWH = input.bool(
     true,
     "Previous Week High",
     group="PRICE LEVELS",
     display=display.none)

showPWL = input.bool(
     true,
     "Previous Week Low",
     group="PRICE LEVELS",
     display=display.none)

showPMH = input.bool(
     true,
     "Premarket High",
     group="PRICE LEVELS",
     display=display.none)

showPML = input.bool(
     true,
     "Premarket Low",
     group="PRICE LEVELS",
     display=display.none)

show5Min = input.bool(
     true,
     "First 5-Minute High / Low",
     group="PRICE LEVELS",
     display=display.none)


//====================================================================
// LINE APPEARANCE
//====================================================================

lineWidth = input.int(
     3,
     "Line Thickness",
     minval=1,
     maxval=6,
     group="LINE APPEARANCE",
     display=display.none)

lineStyleInput = input.string(
     "Solid",
     "Line Style",
     options=["Solid", "Dashed", "Dotted"],
     group="LINE APPEARANCE",
     display=display.none)

lineStyle = line.style_solid

if lineStyleInput == "Dashed"
    lineStyle := line.style_dashed

else if lineStyleInput == "Dotted"
    lineStyle := line.style_dotted


//====================================================================
// LEVEL COLORS
//====================================================================

pdhColor = input.color(
     color.rgb(255, 170, 0),
     "Previous Day High",
     group="LEVEL COLORS",
     display=display.none)

pdlColor = input.color(
     color.rgb(255, 215, 0),
     "Previous Day Low",
     group="LEVEL COLORS",
     display=display.none)

pwhColor = input.color(
     color.rgb(0, 255, 140),
     "Previous Week High",
     group="LEVEL COLORS",
     display=display.none)

pwlColor = input.color(
     color.rgb(0, 210, 150),
     "Previous Week Low",
     group="LEVEL COLORS",
     display=display.none)

pmhColor = input.color(
     color.rgb(60, 180, 255),
     "Premarket High",
     group="LEVEL COLORS",
     display=display.none)

pmlColor = input.color(
     color.rgb(30, 110, 255),
     "Premarket Low",
     group="LEVEL COLORS",
     display=display.none)

fiveHighColor = input.color(
     color.rgb(220, 110, 255),
     "5-Minute High",
     group="LEVEL COLORS",
     display=display.none)

fiveLowColor = input.color(
     color.rgb(180, 60, 255),
     "5-Minute Low",
     group="LEVEL COLORS",
     display=display.none)


//====================================================================
// PRICE LABEL SETTINGS
//====================================================================

showLabels = input.bool(
     true,
     "Show Price Labels",
     group="PRICE LABELS",
     display=display.none)

transparentLabels = input.bool(
     true,
     "Transparent Labels",
     group="PRICE LABELS",
     display=display.none)

showPrices = input.bool(
     true,
     "Display Price After Label",
     group="PRICE LABELS",
     display=display.none)

labelOffset = input.int(
     5,
     "Label Distance Right",
     minval=1,
     maxval=50,
     group="PRICE LABELS",
     display=display.none)

labelSizeInput = input.string(
     "Small",
     "Label Size",
     options=["Tiny", "Small", "Normal"],
     group="PRICE LABELS",
     display=display.none)

labelSize = size.small

if labelSizeInput == "Tiny"
    labelSize := size.tiny

else if labelSizeInput == "Normal"
    labelSize := size.normal


//====================================================================
// SESSION SETTINGS
//====================================================================

premarketSession = input.session(
     "0400-0930",
     "Premarket Session",
     group="SESSIONS",
     display=display.none)


//====================================================================
// A+ CHECKLIST SETTINGS
//====================================================================

showChecklist = input.bool(
     true,
     "Show A+ Checklist",
     group="A+ CHECKLIST",
     display=display.none)

checklistPositionInput = input.string(
     "Top Left",
     "Checklist Position",
     options=[
          "Top Left",
          "Top Right",
          "Bottom Left",
          "Bottom Right"
     ],
     group="A+ CHECKLIST",
     display=display.none)

checklistSizeInput = input.string(
     "Tiny",
     "Checklist Size",
     options=[
          "Tiny",
          "Small",
          "Normal"
     ],
     group="A+ CHECKLIST",
     display=display.none)

bullColor = input.color(
     color.rgb(25, 170, 90),
     "CALL / Bullish Color",
     group="A+ CHECKLIST",
     display=display.none)

bearColor = input.color(
     color.rgb(235, 55, 70),
     "PUT / Bearish Color",
     group="A+ CHECKLIST",
     display=display.none)

neutralColor = input.color(
     color.rgb(50, 55, 65),
     "Neutral Color",
     group="A+ CHECKLIST",
     display=display.none)


//====================================================================
// CHECKLIST POSITION
//====================================================================

checklistPosition = position.top_left

if checklistPositionInput == "Top Right"
    checklistPosition := position.top_right

else if checklistPositionInput == "Bottom Left"
    checklistPosition := position.bottom_left

else if checklistPositionInput == "Bottom Right"
    checklistPosition := position.bottom_right


//====================================================================
// CHECKLIST TEXT SIZE
//====================================================================

checklistTextSize = size.tiny

if checklistSizeInput == "Small"
    checklistTextSize := size.small

else if checklistSizeInput == "Normal"
    checklistTextSize := size.normal


//====================================================================
// PREVIOUS DAY HIGH / LOW
//====================================================================

previousDayHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

previousDayLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)


//====================================================================
// PREVIOUS WEEK HIGH / LOW
//====================================================================

previousWeekHigh = request.security(
     syminfo.tickerid,
     "W",
     high[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)

previousWeekLow = request.security(
     syminfo.tickerid,
     "W",
     low[1],
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_on)


//====================================================================
// PREMARKET HIGH / LOW
//====================================================================

inPremarket = not na(
     time(
          timeframe.period,
          premarketSession,
          "America/New_York"))

newPremarket =
     inPremarket and
     not inPremarket[1]

var float premarketHigh = na
var float premarketLow = na

if newPremarket
    premarketHigh := high
    premarketLow := low

if inPremarket

    premarketHigh := math.max(
         nz(premarketHigh, high),
         high)

    premarketLow := math.min(
         nz(premarketLow, low),
         low)


//====================================================================
// FIRST 5-MINUTE HIGH / LOW
// 9:30 AM - 9:35 AM EASTERN
//====================================================================

fiveMinuteHighRaw = request.security(
     syminfo.tickerid,
     "5",
     hour(time, "America/New_York") == 9 and
     minute(time, "America/New_York") == 30
          ? high
          : na,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off)

fiveMinuteLowRaw = request.security(
     syminfo.tickerid,
     "5",
     hour(time, "America/New_York") == 9 and
     minute(time, "America/New_York") == 30
          ? low
          : na,
     gaps=barmerge.gaps_on,
     lookahead=barmerge.lookahead_off)

var float opening5High = na
var float opening5Low = na

newDay =
     ta.change(time("D")) != 0

if newDay
    opening5High := na
    opening5Low := na

if not na(fiveMinuteHighRaw)
    opening5High := fiveMinuteHighRaw

if not na(fiveMinuteLowRaw)
    opening5Low := fiveMinuteLowRaw


//====================================================================
// VWAP
//====================================================================

vwapValue = ta.vwap(hlc3)


//====================================================================
// 1-MINUTE 9 EMA
//====================================================================

ema1Minute9 = request.security(
     syminfo.tickerid,
     "1",
     ta.ema(close, 9),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)


//====================================================================
// LABEL TEXT FUNCTION
//====================================================================

f_labelText(name, price) =>

    string result = name

    if showPrices
        result :=
             name +
             "  $" +
             str.tostring(
                  price,
                  format.mintick)

    result


//====================================================================
// LINE OBJECTS
//====================================================================

var line pdhLine = na
var line pdlLine = na

var line pwhLine = na
var line pwlLine = na

var line pmhLine = na
var line pmlLine = na

var line fiveHighLine = na
var line fiveLowLine = na


//====================================================================
// LABEL OBJECTS
//====================================================================

var label pdhLabel = na
var label pdlLabel = na

var label pwhLabel = na
var label pwlLabel = na

var label pmhLabel = na
var label pmlLabel = na

var label fiveHighLabel = na
var label fiveLowLabel = na


//====================================================================
// DRAW PRICE LEVELS
//====================================================================

if barstate.islast

    //--------------------------------------------------------------
    // DELETE OLD LINES
    //--------------------------------------------------------------

    line.delete(pdhLine)
    line.delete(pdlLine)

    line.delete(pwhLine)
    line.delete(pwlLine)

    line.delete(pmhLine)
    line.delete(pmlLine)

    line.delete(fiveHighLine)
    line.delete(fiveLowLine)


    //--------------------------------------------------------------
    // DELETE OLD LABELS
    //--------------------------------------------------------------

    label.delete(pdhLabel)
    label.delete(pdlLabel)

    label.delete(pwhLabel)
    label.delete(pwlLabel)

    label.delete(pmhLabel)
    label.delete(pmlLabel)

    label.delete(fiveHighLabel)
    label.delete(fiveLowLabel)


    //================================================================
    // PREVIOUS DAY HIGH
    //================================================================

    if showPDH and not na(previousDayHigh)

        pdhLine := line.new(
             x1=bar_index - 1,
             y1=previousDayHigh,
             x2=bar_index,
             y2=previousDayHigh,
             extend=extend.both,
             color=pdhColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            pdhLabel := label.new(
                 x=bar_index + labelOffset,
                 y=previousDayHigh,
                 text=f_labelText(
                      "Prev Day High",
                      previousDayHigh),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(pdhColor, 100)
                      : pdhColor,
                 textcolor=transparentLabels
                      ? pdhColor
                      : color.black,
                 size=labelSize)


    //================================================================
    // PREVIOUS DAY LOW
    //================================================================

    if showPDL and not na(previousDayLow)

        pdlLine := line.new(
             x1=bar_index - 1,
             y1=previousDayLow,
             x2=bar_index,
             y2=previousDayLow,
             extend=extend.both,
             color=pdlColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            pdlLabel := label.new(
                 x=bar_index + labelOffset,
                 y=previousDayLow,
                 text=f_labelText(
                      "Prev Day Low",
                      previousDayLow),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(pdlColor, 100)
                      : pdlColor,
                 textcolor=transparentLabels
                      ? pdlColor
                      : color.black,
                 size=labelSize)


    //================================================================
    // PREVIOUS WEEK HIGH
    //================================================================

    if showPWH and not na(previousWeekHigh)

        pwhLine := line.new(
             x1=bar_index - 1,
             y1=previousWeekHigh,
             x2=bar_index,
             y2=previousWeekHigh,
             extend=extend.both,
             color=pwhColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            pwhLabel := label.new(
                 x=bar_index + labelOffset,
                 y=previousWeekHigh,
                 text=f_labelText(
                      "Prev Week High",
                      previousWeekHigh),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(pwhColor, 100)
                      : pwhColor,
                 textcolor=transparentLabels
                      ? pwhColor
                      : color.black,
                 size=labelSize)


    //================================================================
    // PREVIOUS WEEK LOW
    //================================================================

    if showPWL and not na(previousWeekLow)

        pwlLine := line.new(
             x1=bar_index - 1,
             y1=previousWeekLow,
             x2=bar_index,
             y2=previousWeekLow,
             extend=extend.both,
             color=pwlColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            pwlLabel := label.new(
                 x=bar_index + labelOffset,
                 y=previousWeekLow,
                 text=f_labelText(
                      "Prev Week Low",
                      previousWeekLow),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(pwlColor, 100)
                      : pwlColor,
                 textcolor=transparentLabels
                      ? pwlColor
                      : color.white,
                 size=labelSize)


    //================================================================
    // PREMARKET HIGH
    //================================================================

    if showPMH and not na(premarketHigh)

        pmhLine := line.new(
             x1=bar_index - 1,
             y1=premarketHigh,
             x2=bar_index,
             y2=premarketHigh,
             extend=extend.both,
             color=pmhColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            pmhLabel := label.new(
                 x=bar_index + labelOffset,
                 y=premarketHigh,
                 text=f_labelText(
                      "PM High",
                      premarketHigh),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(pmhColor, 100)
                      : pmhColor,
                 textcolor=transparentLabels
                      ? pmhColor
                      : color.black,
                 size=labelSize)


    //================================================================
    // PREMARKET LOW
    //================================================================

    if showPML and not na(premarketLow)

        pmlLine := line.new(
             x1=bar_index - 1,
             y1=premarketLow,
             x2=bar_index,
             y2=premarketLow,
             extend=extend.both,
             color=pmlColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            pmlLabel := label.new(
                 x=bar_index + labelOffset,
                 y=premarketLow,
                 text=f_labelText(
                      "PM Low",
                      premarketLow),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(pmlColor, 100)
                      : pmlColor,
                 textcolor=transparentLabels
                      ? pmlColor
                      : color.white,
                 size=labelSize)


    //================================================================
    // 5-MINUTE HIGH
    //================================================================

    if show5Min and not na(opening5High)

        fiveHighLine := line.new(
             x1=bar_index - 1,
             y1=opening5High,
             x2=bar_index,
             y2=opening5High,
             extend=extend.both,
             color=fiveHighColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            fiveHighLabel := label.new(
                 x=bar_index + labelOffset,
                 y=opening5High,
                 text=f_labelText(
                      "5M High",
                      opening5High),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(fiveHighColor, 100)
                      : fiveHighColor,
                 textcolor=transparentLabels
                      ? fiveHighColor
                      : color.white,
                 size=labelSize)


    //================================================================
    // 5-MINUTE LOW
    //================================================================

    if show5Min and not na(opening5Low)

        fiveLowLine := line.new(
             x1=bar_index - 1,
             y1=opening5Low,
             x2=bar_index,
             y2=opening5Low,
             extend=extend.both,
             color=fiveLowColor,
             style=lineStyle,
             width=lineWidth)

        if showLabels

            fiveLowLabel := label.new(
                 x=bar_index + labelOffset,
                 y=opening5Low,
                 text=f_labelText(
                      "5M Low",
                      opening5Low),
                 style=transparentLabels
                      ? label.style_none
                      : label.style_label_left,
                 color=transparentLabels
                      ? color.new(fiveLowColor, 100)
                      : fiveLowColor,
                 textcolor=transparentLabels
                      ? fiveLowColor
                      : color.white,
                 size=labelSize)


//====================================================================
// A+ CHECKLIST CONDITIONS
//====================================================================

// PREVIOUS DAY

prevDayBull =
     not na(previousDayHigh) and
     close > previousDayHigh

prevDayBear =
     not na(previousDayLow) and
     close < previousDayLow


// PREMARKET

premarketBull =
     not na(premarketHigh) and
     close > premarketHigh

premarketBear =
     not na(premarketLow) and
     close < premarketLow


// PREVIOUS WEEK

prevWeekBull =
     not na(previousWeekHigh) and
     close > previousWeekHigh

prevWeekBear =
     not na(previousWeekLow) and
     close < previousWeekLow


// FIRST 5 MINUTES

fiveMinuteBull =
     not na(opening5High) and
     close > opening5High

fiveMinuteBear =
     not na(opening5Low) and
     close < opening5Low


// VWAP

vwapBull =
     not na(vwapValue) and
     close > vwapValue

vwapBear =
     not na(vwapValue) and
     close < vwapValue


// 1-MINUTE 9 EMA

emaBull =
     not na(ema1Minute9) and
     close > ema1Minute9

emaBear =
     not na(ema1Minute9) and
     close < ema1Minute9


//====================================================================
// CALL SCORE
//====================================================================

callScore =
     (prevDayBull ? 1 : 0) +
     (premarketBull ? 1 : 0) +
     (prevWeekBull ? 1 : 0) +
     (fiveMinuteBull ? 1 : 0) +
     (vwapBull ? 1 : 0) +
     (emaBull ? 1 : 0)


//====================================================================
// PUT SCORE
//====================================================================

putScore =
     (prevDayBear ? 1 : 0) +
     (premarketBear ? 1 : 0) +
     (prevWeekBear ? 1 : 0) +
     (fiveMinuteBear ? 1 : 0) +
     (vwapBear ? 1 : 0) +
     (emaBear ? 1 : 0)


//====================================================================
// A+ CONDITIONS
//====================================================================

aPlusCall =
     callScore == 6

aPlusPut =
     putScore == 6


//====================================================================
// STATUS TEXT FUNCTIONS
//====================================================================

f_rangeText(bull, bear) =>

    string result = "Inside"

    if bull
        result := "Above"

    else if bear
        result := "Below"

    result


f_singleText(bull, bear) =>

    string result = "Neutral"

    if bull
        result := "Above"

    else if bear
        result := "Below"

    result


f_statusColor(bull, bear) =>

    color result = neutralColor

    if bull
        result := bullColor

    else if bear
        result := bearColor

    result


//====================================================================
// PROFESSIONAL CHECKLIST COLORS
//====================================================================

tableBackground =
     color.rgb(27, 30, 37)

tableLabelBackground =
     color.rgb(34, 38, 46)

tableTextColor =
     color.rgb(245, 245, 245)

labelTextColor =
     color.rgb(220, 225, 235)

headerNeutral =
     color.rgb(55, 60, 70)


//====================================================================
// A+ CHECKLIST TABLE
//====================================================================

var table checklistTable = table.new(
     checklistPosition,
     2,
     7,
     bgcolor=tableBackground,
     frame_color=color.new(
          color.white,
          80),
     frame_width=1,
     border_color=color.new(
          color.white,
          90),
     border_width=1)


//====================================================================
// DRAW CHECKLIST
//====================================================================

if barstate.islast and showChecklist

    //--------------------------------------------------------------
    // HEADER
    //--------------------------------------------------------------

    string headerStatus = "WAIT"

    color headerColor =
         headerNeutral


    if aPlusCall

        headerStatus :=
             "A+ CALL"

        headerColor :=
             bullColor


    else if aPlusPut

        headerStatus :=
             "A+ PUT"

        headerColor :=
             bearColor


    else if callScore > putScore

        headerStatus :=
             "CALL " +
             str.tostring(callScore) +
             "/6"


    else if putScore > callScore

        headerStatus :=
             "PUT " +
             str.tostring(putScore) +
             "/6"


    //--------------------------------------------------------------
    // HEADER CELLS
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         0,
         "A+ CHECK",
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=headerColor)

    table.cell(
         checklistTable,
         1,
         0,
         headerStatus,
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=headerColor)


    //--------------------------------------------------------------
    // PREVIOUS DAY
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         1,
         "Prev Day",
         text_color=labelTextColor,
         text_size=checklistTextSize,
         bgcolor=tableLabelBackground)

    table.cell(
         checklistTable,
         1,
         1,
         f_rangeText(
              prevDayBull,
              prevDayBear),
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=f_statusColor(
              prevDayBull,
              prevDayBear))


    //--------------------------------------------------------------
    // PREMARKET
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         2,
         "Pre-Market",
         text_color=labelTextColor,
         text_size=checklistTextSize,
         bgcolor=tableLabelBackground)

    table.cell(
         checklistTable,
         1,
         2,
         f_rangeText(
              premarketBull,
              premarketBear),
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=f_statusColor(
              premarketBull,
              premarketBear))


    //--------------------------------------------------------------
    // PREVIOUS WEEK
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         3,
         "Prev Week",
         text_color=labelTextColor,
         text_size=checklistTextSize,
         bgcolor=tableLabelBackground)

    table.cell(
         checklistTable,
         1,
         3,
         f_rangeText(
              prevWeekBull,
              prevWeekBear),
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=f_statusColor(
              prevWeekBull,
              prevWeekBear))


    //--------------------------------------------------------------
    // FIRST 5 MINUTES
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         4,
         "5 Min",
         text_color=labelTextColor,
         text_size=checklistTextSize,
         bgcolor=tableLabelBackground)

    table.cell(
         checklistTable,
         1,
         4,
         f_rangeText(
              fiveMinuteBull,
              fiveMinuteBear),
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=f_statusColor(
              fiveMinuteBull,
              fiveMinuteBear))


    //--------------------------------------------------------------
    // VWAP
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         5,
         "VWAP",
         text_color=labelTextColor,
         text_size=checklistTextSize,
         bgcolor=tableLabelBackground)

    table.cell(
         checklistTable,
         1,
         5,
         f_singleText(
              vwapBull,
              vwapBear),
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=f_statusColor(
              vwapBull,
              vwapBear))


    //--------------------------------------------------------------
    // 1-MINUTE 9 EMA
    //--------------------------------------------------------------

    table.cell(
         checklistTable,
         0,
         6,
         "1M 9 EMA",
         text_color=labelTextColor,
         text_size=checklistTextSize,
         bgcolor=tableLabelBackground)

    table.cell(
         checklistTable,
         1,
         6,
         f_singleText(
              emaBull,
              emaBear),
         text_color=tableTextColor,
         text_size=checklistTextSize,
         bgcolor=f_statusColor(
              emaBull,
              emaBear))


//====================================================================
// HIDE CHECKLIST WHEN DISABLED
//====================================================================

if barstate.islast and not showChecklist

    for row = 0 to 6

        table.cell(
             checklistTable,
             0,
             row,
             "",
             bgcolor=color.new(
                  color.black,
                  100))

        table.cell(
             checklistTable,
             1,
             row,
             "",
             bgcolor=color.new(
                  color.black,
                  100))
````
