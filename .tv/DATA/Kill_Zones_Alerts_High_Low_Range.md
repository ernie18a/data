<!-- tradingview-pine-id: PUB;7edd1369595d4c84b088dcf9b29ed7bb -->
<!-- tradingviewscripts-format: 1 -->
# Kill Zones + Alerts + High Low + Range

Source: https://www.tradingview.com/script/hJtMbHGs-Kill-Zones-by-Esha/

## Description

Kill Zones + Alerts + High Low + Range.
Opening-range breakout strategies
Liquidity-sweep setups
Market-structure shifts
Order blocks
Fair-value gaps
Session continuation strategies
Session reversal strategies

---

## Source Code

````pine
//@version=6
indicator(
     title = "Kill Zones + Alerts + High Low + Range",
     shorttitle = "Kill Zones HL Range",
     overlay = true,
     max_lines_count = 500,
     max_labels_count = 500
)

//=====================================================================
// GENERAL SETTINGS
//=====================================================================

string GROUP_GENERAL = "01. General"

string sessionTimezone = input.string(
     "America/New_York",
     "Session Timezone",
     options = [
          "America/New_York",
          "Asia/Kolkata",
          "Etc/UTC"
     ],
     group = GROUP_GENERAL,
     tooltip =
          "Default session times use New York local time.\n" +
          "America/New_York automatically adjusts for US DST."
)

bool enableAdvanceAlerts = input.bool(
     true,
     "Enable 5-Minute Advance Alerts",
     group = GROUP_GENERAL
)

bool enableStartAlerts = input.bool(
     true,
     "Enable Kill Zone Start Alerts",
     group = GROUP_GENERAL
)

bool showAdvanceMarker = input.bool(
     true,
     "Show 5-Minute Warning Marker",
     group = GROUP_GENERAL
)

bool showKillZoneLabels = input.bool(
     true,
     "Show Kill Zone Captions",
     group = GROUP_GENERAL
)

//=====================================================================
// RANGE / POINT SETTINGS
//=====================================================================

string GROUP_RANGE = "02. Range and Points"

float pointSize = input.float(
     0.01,
     "One Point Equals",
     minval = 0.00001,
     step = 0.001,
     group = GROUP_RANGE,
     tooltip =
          "For Gold, use 0.01 when a $1.00 move equals 100 points.\n" +
          "Example: 2350.00 to 2354.50 = 4.50 price range = 450 points."
)

string rangeDisplayMode = input.string(
     "Both",
     "Caption Range Display",
     options = [
          "Points",
          "Price",
          "Both"
     ],
     group = GROUP_RANGE
)

bool roundPoints = input.bool(
     true,
     "Round Points to Whole Number",
     group = GROUP_RANGE
)

bool showHighLowInCaption = input.bool(
     false,
     "Show High and Low in Caption",
     group = GROUP_RANGE
)

//=====================================================================
// NEW YORK SETTINGS
//=====================================================================

string GROUP_NY = "03. New York"

bool doNYOpen = input.bool(
     true,
     "NY Kill Zone On",
     group = GROUP_NY
)

bool doNYSession = input.bool(
     true,
     "NY Full Session On",
     group = GROUP_NY
)

string nyKillZone = input.session(
     "0800-0810",
     "NY Kill Zone",
     group = GROUP_NY
)

string nyFullSession = input.session(
     "0800-1700",
     "NY Full Session",
     group = GROUP_NY
)

string nyAdvanceSession = input.session(
     "0755-0800",
     "NY 5-Minute Warning",
     group = GROUP_NY
)

color nyColor = input.color(
     color.white,
     "NY Color",
     group = GROUP_NY
)

//=====================================================================
// TOKYO SETTINGS
//=====================================================================

string GROUP_TOKYO = "04. Tokyo"

bool doTokyoOpen = input.bool(
     true,
     "Tokyo Kill Zone On",
     group = GROUP_TOKYO
)

bool doTokyoSession = input.bool(
     true,
     "Tokyo Full Session On",
     group = GROUP_TOKYO
)

string tokyoKillZone = input.session(
     "1900-1910",
     "Tokyo Kill Zone",
     group = GROUP_TOKYO
)

string tokyoFullSession = input.session(
     "1900-0400",
     "Tokyo Full Session",
     group = GROUP_TOKYO
)

string tokyoAdvanceSession = input.session(
     "1855-1900",
     "Tokyo 5-Minute Warning",
     group = GROUP_TOKYO
)

color tokyoColor = input.color(
     color.maroon,
     "Tokyo Color",
     group = GROUP_TOKYO
)

//=====================================================================
// LONDON SETTINGS
//=====================================================================

string GROUP_LONDON = "05. London"

bool doLondonOpen = input.bool(
     true,
     "London Kill Zone On",
     group = GROUP_LONDON
)

bool doLondonSession = input.bool(
     true,
     "London Full Session On",
     group = GROUP_LONDON
)

string londonKillZone = input.session(
     "0300-0310",
     "London Kill Zone",
     group = GROUP_LONDON
)

string londonFullSession = input.session(
     "0300-1200",
     "London Full Session",
     group = GROUP_LONDON
)

string londonAdvanceSession = input.session(
     "0255-0300",
     "London 5-Minute Warning",
     group = GROUP_LONDON
)

color londonColor = input.color(
     color.olive,
     "London Color",
     group = GROUP_LONDON
)

//=====================================================================
// DISPLAY SETTINGS
//=====================================================================

string GROUP_DISPLAY = "06. Display"

bool showKillZoneLevels = input.bool(
     true,
     "Show Kill Zone High/Low",
     group = GROUP_DISPLAY
)

int killZoneTransparency = input.int(
     20,
     "Kill Zone Background Transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_DISPLAY
)

int sessionTransparency = input.int(
     85,
     "Full Session Background Transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_DISPLAY
)

int levelTransparency = input.int(
     0,
     "High/Low Line Transparency",
     minval = 0,
     maxval = 100,
     group = GROUP_DISPLAY
)

int levelWidth = input.int(
     2,
     "High/Low Line Width",
     minval = 1,
     maxval = 4,
     group = GROUP_DISPLAY
)

string levelStyleInput = input.string(
     "Solid",
     "High/Low Line Style",
     options = [
          "Solid",
          "Dashed",
          "Dotted"
     ],
     group = GROUP_DISPLAY
)

levelStyle =
     levelStyleInput == "Dashed" ? line.style_dashed :
     levelStyleInput == "Dotted" ? line.style_dotted :
     line.style_solid

color alertMarkerColor = input.color(
     color.yellow,
     "Advance Alert Marker Color",
     group = GROUP_DISPLAY
)

//=====================================================================
// TIME CONSTANTS
//=====================================================================

int ONE_DAY_MS = 24 * 60 * 60 * 1000

//=====================================================================
// SESSION FUNCTIONS
//=====================================================================

inSession(string sessionValue) =>
    not na(
         time(
              timeframe.period,
              sessionValue,
              sessionTimezone
         )
    )

sessionStarts(string sessionValue) =>
    bool activeNow = inSession(sessionValue)
    bool activeBefore = activeNow[1]

    activeNow and not activeBefore

sessionEnds(string sessionValue) =>
    bool activeNow = inSession(sessionValue)
    bool activeBefore = activeNow[1]

    not activeNow and activeBefore

// Creates the next future timestamp for the supplied local time.
nextLocalTimestamp(int targetHour, int targetMinute) =>
    int candidate = timestamp(
         sessionTimezone,
         year(time, sessionTimezone),
         month(time, sessionTimezone),
         dayofmonth(time, sessionTimezone),
         targetHour,
         targetMinute
    )

    if candidate <= time
        int nextDayReference = time + ONE_DAY_MS

        candidate := timestamp(
             sessionTimezone,
             year(nextDayReference, sessionTimezone),
             month(nextDayReference, sessionTimezone),
             dayofmonth(nextDayReference, sessionTimezone),
             targetHour,
             targetMinute
        )

    candidate

//=====================================================================
// RANGE CAPTION FUNCTIONS
//=====================================================================

formatPoints(float pointsValue) =>
    roundPoints
         ? str.tostring(math.round(pointsValue))
         : str.tostring(pointsValue, "#.##")

makeRangeCaption(
     string sessionName,
     float zoneHigh,
     float zoneLow
) =>
    float priceRange = zoneHigh - zoneLow
    float pointsRange = priceRange / pointSize

    string caption = sessionName + " KZ"

    if rangeDisplayMode == "Price"
        caption +=
             "\nRange: " +
             str.tostring(priceRange, format.mintick)

    else if rangeDisplayMode == "Points"
        caption +=
             "\nPoints: " +
             formatPoints(pointsRange)

    else
        caption +=
             "\nRange: " +
             str.tostring(priceRange, format.mintick) +
             "\nPoints: " +
             formatPoints(pointsRange)

    if showHighLowInCaption
        caption +=
             "\nH: " +
             str.tostring(zoneHigh, format.mintick) +
             "\nL: " +
             str.tostring(zoneLow, format.mintick)

    caption

//=====================================================================
// ACTIVE SESSION CONDITIONS
//=====================================================================

bool inNYKillZone =
     doNYOpen and inSession(nyKillZone)

bool inTokyoKillZone =
     doTokyoOpen and inSession(tokyoKillZone)

bool inLondonKillZone =
     doLondonOpen and inSession(londonKillZone)

bool nyKillZoneStarted =
     doNYOpen and sessionStarts(nyKillZone)

bool tokyoKillZoneStarted =
     doTokyoOpen and sessionStarts(tokyoKillZone)

bool londonKillZoneStarted =
     doLondonOpen and sessionStarts(londonKillZone)

bool nyKillZoneEnded =
     doNYOpen and sessionEnds(nyKillZone)

bool tokyoKillZoneEnded =
     doTokyoOpen and sessionEnds(tokyoKillZone)

bool londonKillZoneEnded =
     doLondonOpen and sessionEnds(londonKillZone)

//=====================================================================
// FULL SESSION CONDITIONS
//=====================================================================

bool inNYSession =
     doNYSession and inSession(nyFullSession)

bool inTokyoSession =
     doTokyoSession and inSession(tokyoFullSession)

bool inLondonSession =
     doLondonSession and inSession(londonFullSession)

//=====================================================================
// FIVE-MINUTE ADVANCE ALERTS
//=====================================================================

bool nyAdvanceAlert =
     enableAdvanceAlerts and
     doNYOpen and
     sessionStarts(nyAdvanceSession)

bool tokyoAdvanceAlert =
     enableAdvanceAlerts and
     doTokyoOpen and
     sessionStarts(tokyoAdvanceSession)

bool londonAdvanceAlert =
     enableAdvanceAlerts and
     doLondonOpen and
     sessionStarts(londonAdvanceSession)

bool anyAdvanceAlert =
     nyAdvanceAlert or
     tokyoAdvanceAlert or
     londonAdvanceAlert

//=====================================================================
// NEW YORK RANGE
// NY levels continue until Tokyo starts at 19:00.
//=====================================================================

var float nyHigh = na
var float nyLow = na

var line nyHighLine = na
var line nyLowLine = na
var label nyCaption = na

if nyKillZoneStarted
    nyHigh := high
    nyLow := low

    int nyLineEnd = nextLocalTimestamp(19, 0)

    if showKillZoneLevels
        nyHighLine := line.new(
             x1 = time,
             y1 = nyHigh,
             x2 = nyLineEnd,
             y2 = nyHigh,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = color.new(
                  nyColor,
                  levelTransparency
             ),
             width = levelWidth,
             style = levelStyle
        )

        nyLowLine := line.new(
             x1 = time,
             y1 = nyLow,
             x2 = nyLineEnd,
             y2 = nyLow,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = color.new(
                  nyColor,
                  levelTransparency
             ),
             width = levelWidth,
             style = levelStyle
        )

    if showKillZoneLabels
        nyCaption := label.new(
             x = time,
             y = nyHigh,
             text = makeRangeCaption(
                  "NY",
                  nyHigh,
                  nyLow
             ),
             xloc = xloc.bar_time,
             style = label.style_label_down,
             color = nyColor,
             textcolor = color.black,
             size = size.small
        )

if inNYKillZone
    nyHigh := na(nyHigh)
         ? high
         : math.max(nyHigh, high)

    nyLow := na(nyLow)
         ? low
         : math.min(nyLow, low)

    if showKillZoneLevels
        if not na(nyHighLine)
            line.set_y1(nyHighLine, nyHigh)
            line.set_y2(nyHighLine, nyHigh)

        if not na(nyLowLine)
            line.set_y1(nyLowLine, nyLow)
            line.set_y2(nyLowLine, nyLow)

    if showKillZoneLabels and not na(nyCaption)
        label.set_y(nyCaption, nyHigh)
        label.set_text(
             nyCaption,
             makeRangeCaption(
                  "NY",
                  nyHigh,
                  nyLow
             )
        )

if nyKillZoneEnded and showKillZoneLabels and not na(nyCaption)
    label.set_text(
         nyCaption,
         makeRangeCaption(
              "NY",
              nyHigh,
              nyLow
         )
    )

//=====================================================================
// TOKYO RANGE
// Tokyo levels continue until London starts at 03:00.
//=====================================================================

var float tokyoHigh = na
var float tokyoLow = na

var line tokyoHighLine = na
var line tokyoLowLine = na
var label tokyoCaption = na

if tokyoKillZoneStarted
    tokyoHigh := high
    tokyoLow := low

    int tokyoLineEnd = nextLocalTimestamp(3, 0)

    if showKillZoneLevels
        tokyoHighLine := line.new(
             x1 = time,
             y1 = tokyoHigh,
             x2 = tokyoLineEnd,
             y2 = tokyoHigh,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = color.new(
                  tokyoColor,
                  levelTransparency
             ),
             width = levelWidth,
             style = levelStyle
        )

        tokyoLowLine := line.new(
             x1 = time,
             y1 = tokyoLow,
             x2 = tokyoLineEnd,
             y2 = tokyoLow,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = color.new(
                  tokyoColor,
                  levelTransparency
             ),
             width = levelWidth,
             style = levelStyle
        )

    if showKillZoneLabels
        tokyoCaption := label.new(
             x = time,
             y = tokyoHigh,
             text = makeRangeCaption(
                  "TOKYO",
                  tokyoHigh,
                  tokyoLow
             ),
             xloc = xloc.bar_time,
             style = label.style_label_down,
             color = tokyoColor,
             textcolor = color.white,
             size = size.small
        )

if inTokyoKillZone
    tokyoHigh := na(tokyoHigh)
         ? high
         : math.max(tokyoHigh, high)

    tokyoLow := na(tokyoLow)
         ? low
         : math.min(tokyoLow, low)

    if showKillZoneLevels
        if not na(tokyoHighLine)
            line.set_y1(tokyoHighLine, tokyoHigh)
            line.set_y2(tokyoHighLine, tokyoHigh)

        if not na(tokyoLowLine)
            line.set_y1(tokyoLowLine, tokyoLow)
            line.set_y2(tokyoLowLine, tokyoLow)

    if showKillZoneLabels and not na(tokyoCaption)
        label.set_y(tokyoCaption, tokyoHigh)
        label.set_text(
             tokyoCaption,
             makeRangeCaption(
                  "TOKYO",
                  tokyoHigh,
                  tokyoLow
             )
        )

if tokyoKillZoneEnded and showKillZoneLabels and not na(tokyoCaption)
    label.set_text(
         tokyoCaption,
         makeRangeCaption(
              "TOKYO",
              tokyoHigh,
              tokyoLow
         )
    )

//=====================================================================
// LONDON RANGE
// London levels continue until New York starts at 08:00.
//=====================================================================

var float londonHigh = na
var float londonLow = na

var line londonHighLine = na
var line londonLowLine = na
var label londonCaption = na

if londonKillZoneStarted
    londonHigh := high
    londonLow := low

    int londonLineEnd = nextLocalTimestamp(8, 0)

    if showKillZoneLevels
        londonHighLine := line.new(
             x1 = time,
             y1 = londonHigh,
             x2 = londonLineEnd,
             y2 = londonHigh,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = color.new(
                  londonColor,
                  levelTransparency
             ),
             width = levelWidth,
             style = levelStyle
        )

        londonLowLine := line.new(
             x1 = time,
             y1 = londonLow,
             x2 = londonLineEnd,
             y2 = londonLow,
             xloc = xloc.bar_time,
             extend = extend.none,
             color = color.new(
                  londonColor,
                  levelTransparency
             ),
             width = levelWidth,
             style = levelStyle
        )

    if showKillZoneLabels
        londonCaption := label.new(
             x = time,
             y = londonHigh,
             text = makeRangeCaption(
                  "LONDON",
                  londonHigh,
                  londonLow
             ),
             xloc = xloc.bar_time,
             style = label.style_label_down,
             color = londonColor,
             textcolor = color.white,
             size = size.small
        )

if inLondonKillZone
    londonHigh := na(londonHigh)
         ? high
         : math.max(londonHigh, high)

    londonLow := na(londonLow)
         ? low
         : math.min(londonLow, low)

    if showKillZoneLevels
        if not na(londonHighLine)
            line.set_y1(londonHighLine, londonHigh)
            line.set_y2(londonHighLine, londonHigh)

        if not na(londonLowLine)
            line.set_y1(londonLowLine, londonLow)
            line.set_y2(londonLowLine, londonLow)

    if showKillZoneLabels and not na(londonCaption)
        label.set_y(londonCaption, londonHigh)
        label.set_text(
             londonCaption,
             makeRangeCaption(
                  "LONDON",
                  londonHigh,
                  londonLow
             )
        )

if londonKillZoneEnded and showKillZoneLabels and not na(londonCaption)
    label.set_text(
         londonCaption,
         makeRangeCaption(
              "LONDON",
              londonHigh,
              londonLow
         )
    )

//=====================================================================
// BACKGROUND COLORS
//=====================================================================

color sessionBackground =
     inNYKillZone
         ? color.new(nyColor, killZoneTransparency)
     : inTokyoKillZone
         ? color.new(tokyoColor, killZoneTransparency)
     : inLondonKillZone
         ? color.new(londonColor, killZoneTransparency)
     : inNYSession
         ? color.new(nyColor, sessionTransparency)
     : inTokyoSession
         ? color.new(tokyoColor, sessionTransparency)
     : inLondonSession
         ? color.new(londonColor, sessionTransparency)
     : na

bgcolor(sessionBackground)

//=====================================================================
// FIVE-MINUTE WARNING MARKERS
//=====================================================================

plotshape(
     showAdvanceMarker and nyAdvanceAlert,
     title = "NY Starts in 5 Minutes",
     text = "NY\n5 MIN",
     style = shape.labelup,
     location = location.belowbar,
     color = alertMarkerColor,
     textcolor = color.black,
     size = size.tiny
)

plotshape(
     showAdvanceMarker and tokyoAdvanceAlert,
     title = "Tokyo Starts in 5 Minutes",
     text = "TOKYO\n5 MIN",
     style = shape.labelup,
     location = location.belowbar,
     color = alertMarkerColor,
     textcolor = color.black,
     size = size.tiny
)

plotshape(
     showAdvanceMarker and londonAdvanceAlert,
     title = "London Starts in 5 Minutes",
     text = "LONDON\n5 MIN",
     style = shape.labelup,
     location = location.belowbar,
     color = alertMarkerColor,
     textcolor = color.black,
     size = size.tiny
)

//=====================================================================
// ADVANCE ALERT CONDITIONS
//=====================================================================

alertcondition(
     nyAdvanceAlert,
     title = "NY Kill Zone Starts in 5 Minutes",
     message =
          "New York Kill Zone starts in 5 minutes on {{ticker}}. " +
          "Current price: {{close}}."
)

alertcondition(
     tokyoAdvanceAlert,
     title = "Tokyo Kill Zone Starts in 5 Minutes",
     message =
          "Tokyo Kill Zone starts in 5 minutes on {{ticker}}. " +
          "Current price: {{close}}."
)

alertcondition(
     londonAdvanceAlert,
     title = "London Kill Zone Starts in 5 Minutes",
     message =
          "London Kill Zone starts in 5 minutes on {{ticker}}. " +
          "Current price: {{close}}."
)

alertcondition(
     anyAdvanceAlert,
     title = "Any Kill Zone Starts in 5 Minutes",
     message =
          "A configured Kill Zone starts in 5 minutes on {{ticker}}. " +
          "Current price: {{close}}."
)

//=====================================================================
// EXACT START ALERT CONDITIONS
//=====================================================================

alertcondition(
     enableStartAlerts and nyKillZoneStarted,
     title = "NY Kill Zone Started",
     message =
          "New York Kill Zone has started on {{ticker}}. " +
          "Current price: {{close}}."
)

alertcondition(
     enableStartAlerts and tokyoKillZoneStarted,
     title = "Tokyo Kill Zone Started",
     message =
          "Tokyo Kill Zone has started on {{ticker}}. " +
          "Current price: {{close}}."
)

alertcondition(
     enableStartAlerts and londonKillZoneStarted,
     title = "London Kill Zone Started",
     message =
          "London Kill Zone has started on {{ticker}}. " +
          "Current price: {{close}}."
)
````
