# Daily High Low Extended Boxes

- url: https://www.tradingview.com/script/8iRM8JIc-Daily-High-Low-Extended-Boxes/
- type: indicator
- pine_id: PUB;5712d4c0a0a14c47a45ac91dc4cc38f1
- version: 4.0

## Description

This indicator is a self updating (every day) indicator that proactively draws boxes for the highs and lows of each day. 
It comes with 3 current days in a row boxes already standard drawn.
The first box is White and starts at beginning of day trading and then spans 72 hours or 3 days. 
Then the second box starts at beginning of day trading for the second day and spans 72 hours or 3 days.
Then the 3rd box starts at beginning of day trading for the second day and spans 72 hours or 3 days.
There are options to have up to 10 days in a row and you can pick a different color for your extra boxes.
This prevents incorrect drawing of boxes and accidentally moving them if not locked.

For those that know how to trade the two box method of trading, this is a perfect tool for you as you will already know where institutional buyers are buying and selling by giving you several days of high probability buy and sell levels. Every day you should have two upper and two lower levels as your guide and this tool saves you time. Just turn it on and they are already populated instantly.
The very top level is where institutional traders sold their longs or took shorts. The very bottom level is where institutional traders had the most buys or sold their shorts. By having the previous days levels as well it gives you 2 good top levels and 2 good lower levels.
If the traded asset exceeds the top level or exceeds the lower level, dont chase just simply dont trade. Come back the next day and assess the new box.
Also included is a midline for each box that can be turned on and off, this will help you if you are getting into a trade late. 
Using other indicators, if you are climbing above the midline, play with caution, but you could take a long. Same for the area below the midline, you could possibly take a short depending on your Stochastic and what it shows or any other indicators of your choosing. 
This is not a playbook but a helpful tool to determine market levels and significant reversal points that are purely and without a doubt institutional. That is where you want to trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © cryptograndpa

// Modified to support New York, London, and Asia session-aligned daily ranges.

//@version=6
indicator(
     "Daily High Low Extended Boxes - Live Sessions",
     overlay=true,
     max_boxes_count=20,
     max_lines_count=20)

// =====================================================
// COMPILER OUTPUT
// =====================================================
plot(na, title="Internal Output", display=display.none)

// =====================================================
// CONSTANTS
// =====================================================

// Box is always 36 hours wide.
int BOX_LENGTH_MS = 36 * 60 * 60 * 1000

// High / Low actively develops during first 24 hours.
int LIVE_LENGTH_MS = 24 * 60 * 60 * 1000

// =====================================================
// GENERAL SETTINGS
// =====================================================

boxesToKeep = input.int(
     3,
     "Number of Boxes",
     minval=3,
     maxval=10,
     group="General")

borderWidth = input.int(
     2,
     "Border Width",
     minval=1,
     maxval=5,
     group="General")

showHighLow = input.bool(
     true,
     "Show High / Low Values",
     group="General")

showMidline = input.bool(
     true,
     "Show 50% Midlines",
     group="General")

midlineColor = color.rgb(190, 190, 190)

// =====================================================
// TRADING SESSION
// =====================================================

sessionChoice = input.string(
     "New York",
     "Trading Session",
     options=[
         "New York",
         "London",
         "Asia"
     ],
     group="Trading Session")

// =====================================================
// SESSION TIMEZONE
// =====================================================
//
// Each session operates from its OWN local timezone.
//
// New York:
// America/New_York
//
// London:
// Europe/London
//
// Asia:
// Asia/Tokyo
//
// IANA timezones allow regional DST handling.
// =====================================================

string sessionTimezone = switch sessionChoice
    "New York" => "America/New_York"
    "London"   => "Europe/London"
    "Asia"     => "Asia/Tokyo"
    => "America/New_York"

// =====================================================
// SESSION OPENING TIME
// =====================================================

int sessionHour = switch sessionChoice
    "New York" => 9
    "London"   => 8
    "Asia"     => 9
    => 9

int sessionMinute = switch sessionChoice
    "New York" => 30
    "London"   => 0
    "Asia"     => 0
    => 30

// =====================================================
// BOX 1 - WHITE
// =====================================================

box1Color = color.white

box1Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 1 - White")

// =====================================================
// BOX 2 - YELLOW
// =====================================================

box2Color = color.yellow

box2Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 2 - Yellow")

// =====================================================
// BOX 3 - BLUE
// =====================================================

box3Color = color.blue

box3Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 3 - Blue")

// =====================================================
// BOX 4
// =====================================================

box4Color = input.color(
     color.orange,
     "Color",
     group="Box 4")

box4Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 4")

// =====================================================
// BOX 5
// =====================================================

box5Color = input.color(
     color.aqua,
     "Color",
     group="Box 5")

box5Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 5")

// =====================================================
// BOX 6
// =====================================================

box6Color = input.color(
     color.fuchsia,
     "Color",
     group="Box 6")

box6Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 6")

// =====================================================
// BOX 7
// =====================================================

box7Color = input.color(
     color.lime,
     "Color",
     group="Box 7")

box7Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 7")

// =====================================================
// BOX 8
// =====================================================

box8Color = input.color(
     color.red,
     "Color",
     group="Box 8")

box8Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 8")

// =====================================================
// BOX 9
// =====================================================

box9Color = input.color(
     color.purple,
     "Color",
     group="Box 9")

box9Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 9")

// =====================================================
// BOX 10
// =====================================================

box10Color = input.color(
     color.gray,
     "Color",
     group="Box 10")

box10Trans = input.int(
     85,
     "Transparency",
     minval=0,
     maxval=100,
     group="Box 10")

// =====================================================
// BOX COLOR FUNCTION
// =====================================================

getBoxColor(int position) =>
    color result = color.gray

    if position == 1
        result := box1Color
    else if position == 2
        result := box2Color
    else if position == 3
        result := box3Color
    else if position == 4
        result := box4Color
    else if position == 5
        result := box5Color
    else if position == 6
        result := box6Color
    else if position == 7
        result := box7Color
    else if position == 8
        result := box8Color
    else if position == 9
        result := box9Color
    else if position == 10
        result := box10Color

    result

// =====================================================
// BOX TRANSPARENCY FUNCTION
// =====================================================

getBoxTransparency(int position) =>
    int result = 85

    if position == 1
        result := box1Trans
    else if position == 2
        result := box2Trans
    else if position == 3
        result := box3Trans
    else if position == 4
        result := box4Trans
    else if position == 5
        result := box5Trans
    else if position == 6
        result := box6Trans
    else if position == 7
        result := box7Trans
    else if position == 8
        result := box8Trans
    else if position == 9
        result := box9Trans
    else if position == 10
        result := box10Trans

    result

// =====================================================
// SESSION-ALIGNED 24-HOUR PERIOD
// =====================================================
//
// Determine the local calendar date according to the
// selected trading session.
// =====================================================

int localYear = year(time, sessionTimezone)
int localMonth = month(time, sessionTimezone)
int localDay = dayofmonth(time, sessionTimezone)

// Today's selected-session opening timestamp.
int todaySessionOpen = timestamp(
     sessionTimezone,
     localYear,
     localMonth,
     localDay,
     sessionHour,
     sessionMinute)

// If this chart bar occurred before today's session
// opening, it belongs to the session that started on
// the previous local calendar date.
bool beforeSessionOpen =
     time < todaySessionOpen

int sessionAnchor = beforeSessionOpen ?
     timestamp(
         sessionTimezone,
         localYear,
         localMonth,
         localDay - 1,
         sessionHour,
         sessionMinute) :
     todaySessionOpen

// =====================================================
// NEW SESSION DETECTION
// =====================================================

bool newSessionDay =
     not na(sessionAnchor[1]) and
     sessionAnchor != sessionAnchor[1]

// =====================================================
// ACTIVE BOX STATE
// =====================================================
//
// These values belong ONLY to the newest session box.
// =====================================================

var float activeHigh = na
var float activeLow = na
var int activeStart = na

// =====================================================
// ARRAYS
// =====================================================

var array<box> dailyBoxes =
     array.new<box>()

var array<line> middleLines =
     array.new<line>()

// =====================================================
// FIRST SESSION INITIALIZATION
// =====================================================
//
// This lets the current developing session appear
// immediately when the indicator is initialized.
// =====================================================

if na(activeStart)

    activeStart := sessionAnchor
    activeHigh := high
    activeLow := low

    int initialRight =
         activeStart + BOX_LENGTH_MS

    float initialMidpoint =
         (activeHigh + activeLow) / 2.0

    string initialText = ""

    if showHighLow
        initialText :=
             "H: " +
             str.tostring(
                 activeHigh,
                 format.mintick) +
             "\nL: " +
             str.tostring(
                 activeLow,
                 format.mintick)

    box initialBox = box.new(
         left=activeStart,
         top=activeHigh,
         right=initialRight,
         bottom=activeLow,
         xloc=xloc.bar_time,
         border_color=color.blue,
         border_width=borderWidth,
         bgcolor=color.new(color.blue, 85),
         text=initialText,
         text_color=color.blue,
         text_size=size.tiny)

    array.push(
         dailyBoxes,
         initialBox)

    color initialMidColor =
         showMidline ?
         midlineColor :
         color.new(midlineColor, 100)

    line initialLine = line.new(
         x1=activeStart,
         y1=initialMidpoint,
         x2=initialRight,
         y2=initialMidpoint,
         xloc=xloc.bar_time,
         color=initialMidColor,
         style=line.style_dashed,
         width=1)

    array.push(
         middleLines,
         initialLine)

// =====================================================
// NEW SESSION -> CREATE NEW BOX IMMEDIATELY
// =====================================================
//
// Previous script:
//
// Wait for the 24-hour candle to finish,
// THEN create its box.
//
// New script:
//
// Session opens,
// THEN create its box immediately.
//
// This is the major behavioral change.
// =====================================================

else if newSessionDay

    // Start new active 24-hour range.
    activeStart := sessionAnchor
    activeHigh := high
    activeLow := low

    // Fixed 36-hour horizontal box length.
    int newRight =
         activeStart + BOX_LENGTH_MS

    float newMidpoint =
         (activeHigh + activeLow) / 2.0

    string newText = ""

    if showHighLow
        newText :=
             "H: " +
             str.tostring(
                 activeHigh,
                 format.mintick) +
             "\nL: " +
             str.tostring(
                 activeLow,
                 format.mintick)

    // -------------------------------------------------
    // CREATE NEW LIVE BOX
    // -------------------------------------------------

    box newBox = box.new(
         left=activeStart,
         top=activeHigh,
         right=newRight,
         bottom=activeLow,
         xloc=xloc.bar_time,
         border_color=color.blue,
         border_width=borderWidth,
         bgcolor=color.new(color.blue, 85),
         text=newText,
         text_color=color.blue,
         text_size=size.tiny)

    array.push(
         dailyBoxes,
         newBox)

    // -------------------------------------------------
    // CREATE NEW LIVE MIDPOINT
    // -------------------------------------------------

    color activeMidColor =
         showMidline ?
         midlineColor :
         color.new(midlineColor, 100)

    line newMidline = line.new(
         x1=activeStart,
         y1=newMidpoint,
         x2=newRight,
         y2=newMidpoint,
         xloc=xloc.bar_time,
         color=activeMidColor,
         style=line.style_dashed,
         width=1)

    array.push(
         middleLines,
         newMidline)

    // -------------------------------------------------
    // REMOVE OLDEST BOX IF NEEDED
    // -------------------------------------------------

    if array.size(dailyBoxes) > boxesToKeep

        box oldestBox =
             array.shift(dailyBoxes)

        box.delete(oldestBox)

    // -------------------------------------------------
    // REMOVE MATCHING OLDEST MIDPOINT
    // -------------------------------------------------

    if array.size(middleLines) > boxesToKeep

        line oldestLine =
             array.shift(middleLines)

        line.delete(oldestLine)

// =====================================================
// IS CURRENT BOX STILL LIVE?
// =====================================================
//
// Vertical range can change only during:
//
// session start -> session start + 24 hours
// =====================================================

bool activeWindow =
     not na(activeStart) and
     time >= activeStart and
     time < activeStart + LIVE_LENGTH_MS

// =====================================================
// 1-MINUTE INTRABAR DATA
// =====================================================
//
// On chart timeframes ABOVE one minute, request all
// available 1-minute highs/lows contained inside the
// current chart bar.
//
// On a 1-minute chart, normal chart high/low is already
// one-minute data.
// =====================================================

array<float> minuteHighs =
     request.security_lower_tf(
         syminfo.tickerid,
         "1",
         high,
         ignore_invalid_timeframe=true)

array<float> minuteLows =
     request.security_lower_tf(
         syminfo.tickerid,
         "1",
         low,
         ignore_invalid_timeframe=true)

array<int> minuteTimes =
     request.security_lower_tf(
         syminfo.tickerid,
         "1",
         time,
         ignore_invalid_timeframe=true)

// =====================================================
// PROCESS 1-MINUTE HIGH / LOW DATA
// =====================================================

if activeWindow

    int minuteCount =
         array.size(minuteTimes)

    // If 1-minute intrabars are available, process
    // every available minute independently.
    if minuteCount > 0

        for i = 0 to minuteCount - 1

            int minuteTime =
                 array.get(
                     minuteTimes,
                     i)

            // Only include minutes belonging to the
            // first 24 hours of THIS session box.
            bool minuteInsideWindow =
                 minuteTime >= activeStart and
                 minuteTime <
                 activeStart + LIVE_LENGTH_MS

            if minuteInsideWindow

                float minuteHigh =
                     array.get(
                         minuteHighs,
                         i)

                float minuteLow =
                     array.get(
                         minuteLows,
                         i)

                activeHigh :=
                     na(activeHigh) ?
                     minuteHigh :
                     math.max(
                         activeHigh,
                         minuteHigh)

                activeLow :=
                     na(activeLow) ?
                     minuteLow :
                     math.min(
                         activeLow,
                         minuteLow)

    // Also incorporate the current chart bar.
    //
    // This keeps the developing realtime bar responsive.
    activeHigh :=
         na(activeHigh) ?
         high :
         math.max(
             activeHigh,
             high)

    activeLow :=
         na(activeLow) ?
         low :
         math.min(
             activeLow,
             low)

// =====================================================
// UPDATE ACTIVE BOX
// =====================================================
//
// The LAST array element is always the newest box.
//
// Only that box is allowed to change vertically.
// =====================================================

int currentBoxCount =
     array.size(dailyBoxes)

if currentBoxCount > 0 and activeWindow

    int lastBoxIndex =
         currentBoxCount - 1

    box liveBox =
         array.get(
             dailyBoxes,
             lastBoxIndex)

    // -------------------------------------------------
    // UPDATE TOP
    // -------------------------------------------------

    box.set_top(
         liveBox,
         activeHigh)

    // -------------------------------------------------
    // UPDATE BOTTOM
    // -------------------------------------------------

    box.set_bottom(
         liveBox,
         activeLow)

    // -------------------------------------------------
    // KEEP RIGHT SIDE FIXED AT 36 HOURS
    // -------------------------------------------------

    box.set_right(
         liveBox,
         activeStart + BOX_LENGTH_MS)

    // -------------------------------------------------
    // UPDATE HIGH / LOW TEXT
    // -------------------------------------------------

    string liveText = ""

    if showHighLow
        liveText :=
             "H: " +
             str.tostring(
                 activeHigh,
                 format.mintick) +
             "\nL: " +
             str.tostring(
                 activeLow,
                 format.mintick)

    box.set_text(
         liveBox,
         liveText)

    // -------------------------------------------------
    // UPDATE MIDPOINT
    // -------------------------------------------------

    int currentLineCount =
         array.size(middleLines)

    if currentLineCount > 0

        int lastLineIndex =
             currentLineCount - 1

        line liveMidline =
             array.get(
                 middleLines,
                 lastLineIndex)

        float liveMidpoint =
             (activeHigh + activeLow) / 2.0

        line.set_y1(
             liveMidline,
             liveMidpoint)

        line.set_y2(
             liveMidline,
             liveMidpoint)

        line.set_x1(
             liveMidline,
             activeStart)

        line.set_x2(
             liveMidline,
             activeStart + BOX_LENGTH_MS)

// =====================================================
// UPDATE BOX 1-10 APPEARANCE
// =====================================================
//
// The colors continue to work chronologically.
//
// Box 1 = oldest visible box.
// Last box = newest/live box.
// =====================================================

int boxCount =
     array.size(dailyBoxes)

if boxCount > 0

    for i = 0 to boxCount - 1

        box currentBox =
             array.get(
                 dailyBoxes,
                 i)

        int position =
             i + 1

        color currentColor =
             getBoxColor(
                 position)

        int currentTransparency =
             getBoxTransparency(
                 position)

        box.set_border_color(
             currentBox,
             currentColor)

        box.set_border_width(
             currentBox,
             borderWidth)

        box.set_bgcolor(
             currentBox,
             color.new(
                 currentColor,
                 currentTransparency))

        box.set_text_color(
             currentBox,
             currentColor)

// =====================================================
// UPDATE MIDLINE VISIBILITY
// =====================================================

int lineCount =
     array.size(middleLines)

if lineCount > 0

    for i = 0 to lineCount - 1

        line currentLine =
             array.get(
                 middleLines,
                 i)

        if showMidline

            line.set_color(
                 currentLine,
                 midlineColor)

        else

            line.set_color(
                 currentLine,
                 color.new(
                     midlineColor,
                     100))
````
