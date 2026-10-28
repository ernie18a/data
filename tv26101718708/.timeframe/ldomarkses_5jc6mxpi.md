# LDO-Mark-SES

- url: https://www.tradingview.com/script/5jC6MXpI-LDO-Mark-SES/
- type: indicator
- pine_id: PUB;a335877ee5c84e2380d8b97fe5a26ba0
- version: 1.0

## Description

LDO-Mark-SES: Session Volume Profiles + Brinks Box

WHY IT WAS BUILT
To see at a glance where each trading session did its business: the prices where Asia, London and New York traded the most volume, and the range of the first hour of the New York open. Everything is drawn on the chart in one clean overlay.

WHAT IT SHOWS
- Session volume profiles for Asia (09:00-17:00 Tokyo), London (08:00-17:00 London) and New York (09:30-17:00 New York). Each histogram sits over its own session's candles, with a heading at the session open.
- POC (point of control): the price where the session traded the most volume.
- VAH / VAL (value area high / low): the band where about 70% of the session's volume traded.
- Live session profile: the session in progress, updated every minute. Its lines are dashed and its histogram fainter, because the levels are still moving. At the session close it is replaced by the finished profile.
- Brinks box: the high-to-low range of the first hour of the New York cash open, 09:00-10:00 New York (14:00-15:00 UK for most of the year). The previous box stays on the chart until the new one has formed. Its high and low extend to the right as lines until then, so you can compare the two.

HOW IT WORKS
- Volume at each price is estimated from 1-minute candles, spread evenly across each candle's range. It is an estimate, not tick-by-tick data.
- Session hours are set in each exchange's own time zone, so daylight-saving changes are handled automatically whatever time zone your chart uses.
- Crypto has no cash open. On crypto charts the Brinks box is drawn on the same clock as a convention.

SETTINGS
1. Sessions
   - A tick box on each row shows or hides that session: Asia, London, NY.
   - Each row also sets the session hours, time zone and heading colour.
   - Brinks row: on/off, clock (New York 09:00-10:00 or London 14:00-15:00) and box colour.
2. Volume profile
   - Histograms on/off, live session profile on/off, and how many past sessions to keep.
   - Price rows, value area %, position (over the session, or beside its close) and width.
   - Colours inside and outside the value area, and transparency for finished and live profiles.
3. POC / VAH / VAL lines
   - Colour, line type and thickness for each line.
   - Tags on/off and tag size.
   - Optionally extend each POC to the right until price touches it.
4. Brinks box
   - Border thickness, fill colour and opacity.
   - Extend high & low lines on/off, plus their colour, line type and thickness.
   - Text colour, and optional B.H / B.L tags for the Brinks high and low.
5. Advanced
   - Calculation depth and label placement. The defaults suit most charts.

REQUIREMENTS
- Intraday charts of 1 minute or higher, with standard candles.
- The Brinks box draws on timeframes that divide an hour evenly (1, 3, 5, 15, 30 and 60 minutes). On 15m it is exactly four candles.
- A small note at the bottom left reports any session skipped because 1-minute history did not cover it completely. This is normal for the oldest session on the chart..

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/ MPL-2.0
//@version=6
// LDO-Mark-SES — Indicator version 1.17
// v1.17: the previous Brinks box and its high/low lines stay until the new box has formed (15:00 UK), then the old one is removed.
// v1.16: Brinks shows only the latest box (Days setting removed); clearer names for the extended high/low lines.
// v1.15: "NY" row label; Brinks row gains its colour swatch (box border) for consistency with the session rows.
// v1.14: Sessions section first, with an on/off tick box on each session row and a Brinks row; Show section removed.
// v1.13: settings regrouped (Show, Session times, Volume profile, Lines, Brinks, Advanced) with one-row controls; Brinks border / fill / ray / text colours and thickness.
// v1.12: Display group with on/off switches for Asia, London, New York and Brinks.
// v1.11: Brinks H/L rays stop a set number of hours after the close (default 2h, max 7h = New York close), never crossing the next Asia/London profiles.
// v1.10: Brinks box (first hour of the NY cash open, 09:00-10:00 New York or 14:00-15:00 London); plain high/low, no profile.
// v1.9: live (developing) profile for the session in progress, recalculated every closed minute; completed-profile maths unchanged.
// v1.8: profile drawn over its own session by default (heading at the session open); v1.7 maths unchanged.
// v1.7: exact one-minute session sampling, full-session lines and TradingView VA rules.
// Volume-at-price is estimated uniformly inside each one-minute candle range.
// Completed POC / VAH / VAL span the actual session. Only POC may extend right.
// An extended POC retracts to its session close after a confirmed touch/crossing.
indicator("LDO-Mark-SES v1.17", "LDO-Mark-SES v1.17", overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// --- Settings (grouped and ordered as they appear in the Settings dialog) ---
string G_TIMES = "1. Sessions (exchange clock)"
string G_PROFILE = "2. Volume profile"
string G_LEVELS = "3. POC / VAH / VAL lines"
string G_BRINKS = "4. Brinks box"
string G_ADVANCED = "5. Advanced"

// 1. Sessions: tick box | hours | time zone | heading colour. Hours are in each exchange's own time zone, so daylight saving is automatic
bool showAsiaInput = input.bool(true, "Asia", inline="asia", group=G_TIMES)
string asiaSessionInput = input.session("0900-1700", "", inline="asia", group=G_TIMES)
string asiaTimezoneInput = input.string("Asia/Tokyo", "", inline="asia", group=G_TIMES)
color asiaColorInput = input.color(#4db6ac, "", inline="asia", group=G_TIMES, tooltip="Tick box = show or hide this session (profile, lines and live profile).\nHours | time zone (IANA name) | heading colour.\n09:00-17:00 Tokyo = 01:00-09:00 UK in summer, 00:00-08:00 UK in winter (Japan has no daylight saving).")
bool showLondonInput = input.bool(true, "London", inline="london", group=G_TIMES)
string londonSessionInput = input.session("0800-1700", "", inline="london", group=G_TIMES)
string londonTimezoneInput = input.string("Europe/London", "", inline="london", group=G_TIMES)
color londonColorInput = input.color(#f0a44b, "", inline="london", group=G_TIMES, tooltip="Hours | time zone | heading colour.\n08:00-17:00 UK all year.")
bool showNewYorkInput = input.bool(true, "NY", inline="newyork", group=G_TIMES)
string newYorkSessionInput = input.session("0930-1700", "", inline="newyork", group=G_TIMES)
string newYorkTimezoneInput = input.string("America/New_York", "", inline="newyork", group=G_TIMES)
color newYorkColorInput = input.color(#9b7ede, "", inline="newyork", group=G_TIMES, tooltip="Hours | time zone | heading colour.\n09:30-17:00 New York = 14:30-22:00 UK, or 13:30-21:00 UK in the weeks when US and UK clocks change on different dates.")
bool showBrinksInput = input.bool(true, "Brinks", inline="brinks", group=G_TIMES)
string brinksModeInput = input.string("New York 09:00-10:00", "", options=["New York 09:00-10:00", "London 14:00-15:00"], inline="brinks", group=G_TIMES)
color brinksBorderColorInput = input.color(#ffb300, "", inline="brinks", group=G_TIMES, tooltip="Brinks = first hour of the New York cash open (Tino / Traders Reality). A plain high/low box, no profile. Crypto perps have no cash open; the clock is a convention.\nNew York 09:00-10:00 follows US daylight saving: 14:00-15:00 UK, or 13:00-14:00 UK in the weeks when US and UK clocks change on different dates. London 14:00-15:00 is fixed UK time.\nColour = box border. Border thickness, fill, ray and text colours are in section 4.")

// 2. Volume profile
bool showProfilesInput = input.bool(true, "Histograms", inline="parts", group=G_PROFILE)
bool showLiveInput = input.bool(true, "Live session profile", inline="parts", group=G_PROFILE, tooltip="Histograms off keeps the POC / VAH / VAL lines and hides the volume bars.\nLive session profile = the session in progress, drawn from its open and updated every closed minute; dashed, provisional lines. Replaced by the normal profile at the session close.")
int profilesToKeepInput = input.int(9, "Past sessions shown", minval=1, maxval=20, group=G_PROFILE, tooltip="How many completed session profiles stay on the chart. High price-row counts may lower this to stay within TradingView's drawing limit.")
int binsInput = input.int(40, "Price rows", minval=8, maxval=60, inline="rows", group=G_PROFILE)
float valueAreaPercentInput = input.float(70.0, "Value area %", minval=50.0, maxval=99.0, step=1.0, inline="rows", group=G_PROFILE)
string profilePlacementInput = input.string("Over session", "Position", options=["Over session", "After session close"], inline="position", group=G_PROFILE)
int sessionWidthPercentInput = input.int(40, "Width %", minval=5, maxval=100, inline="position", group=G_PROFILE, tooltip="Over session: the histogram sits over its own candles, heading at the session open. Width % = widest row as a share of the session length.\nAfter session close: histogram parked beside the close (width and offset in section 5).")
color valueAreaVolumeColorInput = input.color(#00838f, "Inside value area", inline="colours", group=G_PROFILE)
color outsideVolumeColorInput = input.color(#787b86, "Outside", inline="colours", group=G_PROFILE)
int profileTransparencyInput = input.int(35, "Transparency", minval=0, maxval=95, inline="transparency", group=G_PROFILE)
int liveTransparencyInput = input.int(65, "Live", minval=0, maxval=95, inline="transparency", group=G_PROFILE, tooltip="Transparency of completed profiles, and of the live profile (fainter so it reads as provisional).")

// 3. POC / VAH / VAL lines: colour | line type | thickness
color pocColorInput = input.color(#7e57c2, "POC", inline="poc", group=G_LEVELS)
string pocStyleInput = input.string("Solid", "", options=["Solid", "Dashed", "Dotted"], inline="poc", group=G_LEVELS)
int pocWidthInput = input.int(4, "", minval=1, maxval=5, inline="poc", group=G_LEVELS)
color vahColorInput = input.color(#26a69a, "VAH", inline="vah", group=G_LEVELS)
string vahStyleInput = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="vah", group=G_LEVELS)
int vahWidthInput = input.int(2, "", minval=1, maxval=5, inline="vah", group=G_LEVELS)
color valColorInput = input.color(#26a69a, "VAL", inline="val", group=G_LEVELS)
string valStyleInput = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="val", group=G_LEVELS)
int valWidthInput = input.int(2, "", minval=1, maxval=5, inline="val", group=G_LEVELS, tooltip="Each row: colour | line type | thickness. Live-session lines are always dashed.")
bool showLocalLabelsInput = input.bool(true, "POC / VAH / VAL tags", inline="tags", group=G_LEVELS)
string localLabelSizeInput = input.string("Small", "Size", options=["Tiny", "Small", "Normal"], inline="tags", group=G_LEVELS)
bool extendPocInput = input.bool(false, "Extend POC until price touches it", inline="extend", group=G_LEVELS)
bool showExtendedPocLabelsInput = input.bool(true, "Name it", inline="extend", group=G_LEVELS, tooltip="Extend: each POC runs right until a later confirmed candle touches or crosses it (wicks and gaps count), then returns to its session. VAH and VAL never extend.\nName it: label each extended POC with its session and price.")

// 4. Brinks box (on/off, clock and colour are in section 1). The previous box stays until the new one has formed.
int brinksBorderWidthInput = input.int(1, "Border", minval=1, maxval=4, inline="border", group=G_BRINKS)
color brinksFillColorInput = input.color(#ffb300, "Fill", inline="border", group=G_BRINKS)
int brinksFillInput = input.int(15, "Opacity %", minval=0, maxval=60, inline="border", group=G_BRINKS, tooltip="Border thickness | fill colour | fill opacity. The border colour is the swatch on the Brinks row in section 1.")
bool showBrinksRaysInput = input.bool(true, "Extend high & low lines", inline="rays", group=G_BRINKS, tooltip="When the Brinks hour ends (15:00 UK), its high and low carry on to the right as two lines until the next Brinks box has formed (15:00 UK the next day), so you can see whether price comes back to them or breaks them. They run across the Asia and London profiles by design.")
color brinksRayColorInput = input.color(#ffb300, "Line", inline="raystyle", group=G_BRINKS)
string brinksRayStyleInput = input.string("Dotted", "", options=["Solid", "Dashed", "Dotted"], inline="raystyle", group=G_BRINKS)
int brinksRayWidthInput = input.int(1, "", minval=1, maxval=4, inline="raystyle", group=G_BRINKS, tooltip="High & low lines: colour | line type | thickness.")
color brinksTextColorInput = input.color(#ffb300, "Text", inline="text", group=G_BRINKS)
bool showBrinksLevelsInput = input.bool(false, "B.H / B.L tags", inline="text", group=G_BRINKS, tooltip="Text colour for the BRINKS tag and the B.H / B.L tags. B.H / B.L label the Brinks high and low at the end of their lines.")

// 5. Advanced
int historyBarsInput = input.int(600, "Bars to calculate", minval=100, maxval=5000, group=G_ADVANCED)
int profileWidthInput = input.int(5, "After-close width (bars)", minval=1, maxval=20, inline="afterclose", group=G_ADVANCED)
int profileOffsetInput = input.int(1, "Offset", minval=0, maxval=50, inline="afterclose", group=G_ADVANCED, tooltip="Only used when Position = After session close.")
int extendedLabelOffsetInput = input.int(5, "Extended POC names: offset", minval=1, maxval=60, inline="extlabels", group=G_ADVANCED)
int extendedLabelColumnsInput = input.int(4, "Columns", minval=1, maxval=8, inline="extlabels", group=G_ADVANCED)
int extendedLabelColumnSpacingInput = input.int(22, "Column spacing (bars)", minval=8, maxval=80, inline="extlabels2", group=G_ADVANCED)
float extendedLabelSeparationInput = input.float(1.5, "Min gap (ATR)", minval=0.1, maxval=10.0, step=0.1, inline="extlabels2", group=G_ADVANCED, tooltip="Where extended-POC names sit, and how they step into columns when prices are close.")
bool overSession = profilePlacementInput == "Over session"
string localLabelSize = localLabelSizeInput == "Normal" ? size.normal : localLabelSizeInput == "Tiny" ? size.tiny : size.small
int barMilliseconds = int(timeframe.in_seconds(timeframe.period) * 1000)
float labelSeparation = math.max(nz(ta.atr(14), syminfo.mintick * 20) * extendedLabelSeparationInput, syminfo.mintick * 8)

lineStyle(string selectedStyle) =>
    selectedStyle == "Dashed" ? line.style_dashed : selectedStyle == "Dotted" ? line.style_dotted : line.style_solid

// Local markers stay with their profile; active POCs can outlive the profile display.
type PocLevel
    line drawing
    label tag
    label extensionTag
    int localEndTime
    int sessionEndBar
    int sessionEndTime
    bool active
    bool profileVisible
    string sessionTitle

type SessionProfile
    array<box> boxes
    line vah
    line val
    label title
    label vahTag
    label valTag
    PocLevel poc

var array<SessionProfile> profiles = array.new<SessionProfile>()
var array<PocLevel> pocLevels = array.new<PocLevel>()

removeOldProfile(SessionProfile profile) =>
    if array.size(profile.boxes) > 0
        for boxIndex = 0 to array.size(profile.boxes) - 1
            box.delete(array.get(profile.boxes, boxIndex))
    line.delete(profile.vah)
    line.delete(profile.val)
    label.delete(profile.title)
    label.delete(profile.vahTag)
    label.delete(profile.valTag)
    PocLevel profilePoc = profile.poc
    label.delete(profilePoc.tag)
    profilePoc.tag := na
    profilePoc.profileVisible := false

localTag(int tagTime, float price, string levelType, color levelColor, string sessionTitle) =>
    label.new(tagTime, price, showLocalLabelsInput ? levelType : "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(chart.bg_color, showLocalLabelsInput ? 15 : 100), textcolor=levelColor, size=localLabelSize, textalign=text.align_left, tooltip=sessionTitle + "\n" + levelType + ": " + str.tostring(price, format.mintick))

// --- Profile maths (shared by completed and live profiles) ---
computeProfile(array<float> lowsArray, array<float> highsArray, array<float> opensArray, array<float> closesArray, array<float> volumesArray) =>
    int sessionBarCount = array.size(lowsArray)
    float profileLow = array.min(lowsArray)
    float profileHigh = array.max(highsArray)
    float rowHeight = math.max((profileHigh - profileLow) / binsInput, syminfo.mintick)
    array<float> buyRowsArray = array.new<float>(binsInput, 0.0)
    array<float> sellRowsArray = array.new<float>(binsInput, 0.0)
    array<float> totalRowsArray = array.new<float>(binsInput, 0.0)

    for barOffset = 0 to sessionBarCount - 1
        float barLow = array.get(lowsArray, barOffset)
        float barHigh = array.get(highsArray, barOffset)
        float barOpen = array.get(opensArray, barOffset)
        float barClose = array.get(closesArray, barOffset)
        float barVolume = array.get(volumesArray, barOffset)
        float barRange = barHigh - barLow
        float buyShare = barRange > 0 ? math.min(math.max((barClose - barLow) / barRange, 0.0), 1.0) : (barClose >= barOpen ? 1.0 : 0.0)

        if barRange <= syminfo.mintick * 0.5
            int rowIndex = int(math.floor((barClose - profileLow) / rowHeight))
            rowIndex := math.min(math.max(rowIndex, 0), binsInput - 1)
            array.set(buyRowsArray, rowIndex, array.get(buyRowsArray, rowIndex) + barVolume * buyShare)
            array.set(sellRowsArray, rowIndex, array.get(sellRowsArray, rowIndex) + barVolume * (1.0 - buyShare))
        else
            for rowIndex = 0 to binsInput - 1
                float rowBottom = profileLow + rowHeight * rowIndex
                float rowTop = rowBottom + rowHeight
                float overlap = math.max(0.0, math.min(barHigh, rowTop) - math.max(barLow, rowBottom))
                if overlap > 0
                    float rowVolume = barVolume * overlap / barRange
                    array.set(buyRowsArray, rowIndex, array.get(buyRowsArray, rowIndex) + rowVolume * buyShare)
                    array.set(sellRowsArray, rowIndex, array.get(sellRowsArray, rowIndex) + rowVolume * (1.0 - buyShare))

    float totalVolume = 0.0
    float peakRowVolume = 0.0
    int pocIndex = 0
    for rowIndex = 0 to binsInput - 1
        float rowVolume = array.get(buyRowsArray, rowIndex) + array.get(sellRowsArray, rowIndex)
        array.set(totalRowsArray, rowIndex, rowVolume)
        totalVolume += rowVolume
        if rowVolume > peakRowVolume
            peakRowVolume := rowVolume
            pocIndex := rowIndex

    int valueAreaLowIndex = pocIndex
    int valueAreaHighIndex = pocIndex
    float valueAreaVolume = array.get(totalRowsArray, pocIndex)
    float valueAreaTarget = totalVolume * valueAreaPercentInput / 100.0
    while valueAreaVolume < valueAreaTarget and (valueAreaLowIndex > 0 or valueAreaHighIndex < binsInput - 1)
        float belowVolume = valueAreaLowIndex > 0 ? array.get(totalRowsArray, valueAreaLowIndex - 1) : -1.0
        float aboveVolume = valueAreaHighIndex < binsInput - 1 ? array.get(totalRowsArray, valueAreaHighIndex + 1) : -1.0
        int aboveDistance = valueAreaHighIndex + 1 - pocIndex
        int belowDistance = pocIndex - (valueAreaLowIndex - 1)
        bool chooseAbove = aboveVolume > belowVolume or (aboveVolume == belowVolume and aboveDistance <= belowDistance)
        float chosenVolume = chooseAbove ? aboveVolume : belowVolume
        // TradingView: stop before a candidate would exceed the remaining target.
        if valueAreaVolume + chosenVolume > valueAreaTarget
            break
        if chooseAbove and valueAreaHighIndex < binsInput - 1
            valueAreaHighIndex += 1
            valueAreaVolume += chosenVolume
        else if valueAreaLowIndex > 0
            valueAreaLowIndex -= 1
            valueAreaVolume += chosenVolume
        else
            break
    [totalRowsArray, profileLow, profileHigh, rowHeight, pocIndex, valueAreaLowIndex, valueAreaHighIndex, valueAreaVolume, totalVolume, peakRowVolume]

// --- Profile builder ---
drawSessionProfile(array<float> lowsArray, array<float> highsArray, array<float> opensArray, array<float> closesArray, array<float> volumesArray, int startBar, int endBar, int sessionStartTime, int sessionEndTime, string sessionName, string sessionTimezone, color sessionColor) =>
    int sessionBarCount = array.size(lowsArray)
    if sessionBarCount > 0
        [totalRowsArray, profileLow, profileHigh, rowHeight, pocIndex, valueAreaLowIndex, valueAreaHighIndex, valueAreaVolume, totalVolume, peakRowVolume] = computeProfile(lowsArray, highsArray, opensArray, closesArray, volumesArray)
        int profileStart = overSession ? startBar : endBar + profileOffsetInput
        int maxProfileWidth = overSession ? math.max(1, int(math.round((endBar - startBar + 1) * sessionWidthPercentInput / 100.0))) : profileWidthInput
        if totalVolume > 0 and peakRowVolume > 0
            int liveReserve = showLiveInput ? 3 * binsInput : 0
            int profileLimit = math.max(1, math.min(profilesToKeepInput, int(math.floor((480.0 - liveReserve) / binsInput))))
            while array.size(profiles) >= profileLimit
                removeOldProfile(array.shift(profiles))
            array<box> sessionBoxes = array.new<box>()
            // Width always represents total row volume. The computed VA row indices
            // also define the VAH/VAL lines, so shading and boundaries agree exactly.
            for rowIndex = 0 to binsInput - 1
                float rowVolume = array.get(totalRowsArray, rowIndex)
                if showProfilesInput and rowVolume > 0
                    int totalWidth = math.max(1, int(math.round(rowVolume / peakRowVolume * maxProfileWidth)))
                    float rowBottom = profileLow + rowHeight * rowIndex
                    float rowTop = rowBottom + rowHeight
                    bool insideValueArea = rowIndex >= valueAreaLowIndex and rowIndex <= valueAreaHighIndex
                    color rowColor = insideValueArea ? valueAreaVolumeColorInput : outsideVolumeColorInput
                    array.push(sessionBoxes, box.new(profileStart, rowTop, profileStart + totalWidth, rowBottom, xloc=xloc.bar_index, border_color=color.new(rowColor, profileTransparencyInput), border_width=1, bgcolor=color.new(rowColor, profileTransparencyInput)))

            float pocPrice = profileLow + rowHeight * (pocIndex + 0.5)
            float valueAreaLow = profileLow + rowHeight * valueAreaLowIndex
            float valueAreaHigh = profileLow + rowHeight * (valueAreaHighIndex + 1)
            string sessionDate = str.format_time(sessionStartTime, "dd MMM", sessionTimezone)
            string sessionTitle = sessionDate + " " + sessionName
            // Markers sit across the histogram so all three levels form one visible group.
            // Time coordinates avoid age limits for POCs that remain extended for many bars.
            int localStartTime = sessionStartTime
            int localEndTime = sessionEndTime
            int tagTime = overSession ? sessionEndTime : sessionEndTime + (profileOffsetInput + profileWidthInput) * barMilliseconds
            line pocLine = line.new(localStartTime, pocPrice, localEndTime, pocPrice, xloc=xloc.bar_time, extend=extendPocInput ? extend.right : extend.none, color=pocColorInput, style=lineStyle(pocStyleInput), width=pocWidthInput)
            line vahLine = line.new(localStartTime, valueAreaHigh, localEndTime, valueAreaHigh, xloc=xloc.bar_time, extend=extend.none, color=vahColorInput, style=lineStyle(vahStyleInput), width=vahWidthInput)
            line valLine = line.new(localStartTime, valueAreaLow, localEndTime, valueAreaLow, xloc=xloc.bar_time, extend=extend.none, color=valColorInput, style=lineStyle(valStyleInput), width=valWidthInput)
            label pocTag = localTag(tagTime, pocPrice, "POC", pocColorInput, sessionTitle)
            label vahTag = localTag(tagTime, valueAreaHigh, "VAH", vahColorInput, sessionTitle)
            label valTag = localTag(tagTime, valueAreaLow, "VAL", valColorInput, sessionTitle)
            label extendedPocTag = na
            if extendPocInput and showExtendedPocLabelsInput
                extendedPocTag := label.new(sessionEndTime, pocPrice, "", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(chart.bg_color, 15), textcolor=pocColorInput, size=size.small, textalign=text.align_left)
            PocLevel poc = PocLevel.new(pocLine, pocTag, extendedPocTag, localEndTime, endBar, sessionEndTime, extendPocInput, true, sessionTitle)
            array.push(pocLevels, poc)
            string sessionTooltip = sessionTitle + " completed session (1-minute OHLCV estimate)\n" + str.format_time(sessionStartTime, "HH:mm", sessionTimezone) + "–" + str.format_time(sessionEndTime, "HH:mm", sessionTimezone) + " " + sessionTimezone + "\nVA volume: " + str.tostring(100.0 * valueAreaVolume / totalVolume, "#.##") + "%\nPOC: " + str.tostring(pocPrice, format.mintick) + "\nVAH: " + str.tostring(valueAreaHigh, format.mintick) + "\nVAL: " + str.tostring(valueAreaLow, format.mintick)
            label sessionLabel = label.new(profileStart, profileHigh + rowHeight, sessionName + "\n" + sessionDate, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(sessionColor, 15), style=label.style_label_down, textcolor=color.white, size=size.small, tooltip=sessionTooltip)
            array.push(profiles, SessionProfile.new(sessionBoxes, vahLine, valLine, sessionLabel, vahTag, valTag, poc))
            // At most 300 extended POCs, <= 20 local POC tags, and <= 60 session/VA labels.
            if array.size(pocLevels) > 300
                PocLevel oldestPoc = array.shift(pocLevels)
                line.delete(oldestPoc.drawing)
                label.delete(oldestPoc.tag)
                label.delete(oldestPoc.extensionTag)

    array.clear(lowsArray)
    array.clear(highsArray)
    array.clear(opensArray)
    array.clear(closesArray)
    array.clear(volumesArray)

// --- One-minute session state ---
// Chart candles are never used to estimate a fraction of a boundary candle.
if not timeframe.isintraday or timeframe.in_seconds() < 60 or not chart.is_standard
    runtime.error("Use standard time-based intraday candles of one minute or longer.")

sessionBounds(string sessionHours, string zone) =>
    int sh = int(str.tonumber(str.substring(sessionHours, 0, 2)))
    int sm = int(str.tonumber(str.substring(sessionHours, 2, 4)))
    int eh = int(str.tonumber(str.substring(sessionHours, 5, 7)))
    int em = int(str.tonumber(str.substring(sessionHours, 7, 9)))
    int localMinute = hour(time, zone) * 60 + minute(time, zone)
    bool overnight = eh * 60 + em <= sh * 60 + sm
    int dayShift = overnight and localMinute < sh * 60 + sm ? -1 : 0
    int startStamp = timestamp(zone, year(time, zone), month(time, zone), dayofmonth(time, zone) + dayShift, sh, sm)
    int endStamp = timestamp(zone, year(time, zone), month(time, zone), dayofmonth(time, zone) + dayShift + (overnight ? 1 : 0), eh, em)
    bool inside = not na(time("1", sessionHours, zone))
    [inside ? startStamp : int(na), inside ? endStamp : int(na)]

sampleData() =>
    [aStart, aEnd] = sessionBounds(asiaSessionInput, asiaTimezoneInput)
    [lStart, lEnd] = sessionBounds(londonSessionInput, londonTimezoneInput)
    [nStart, nEnd] = sessionBounds(newYorkSessionInput, newYorkTimezoneInput)
    [time, time_close, open, high, low, close, volume, aStart, aEnd, lStart, lEnd, nStart, nEnd]

[minuteTimes, minuteCloses, minuteOpens, minuteHighs, minuteLows, minutePrices, minuteVolumes, asiaStarts, asiaEnds, londonStarts, londonEnds, nyStarts, nyEnds] = request.security_lower_tf(syminfo.tickerid, "1", sampleData(), ignore_invalid_timeframe=true, calc_bars_count=100000)

type SessionState
    array<float> lows
    array<float> highs
    array<float> opens
    array<float> closes
    array<float> volumes
    array<box> liveBoxes
    line livePoc
    line liveVah
    line liveVal
    label liveTitle
    label livePocTag
    label liveVahTag
    label liveValTag
    int startTime = na
    int endTime = na
    int lastClose = na
    int startBar = na
    int endBar = na
    bool complete = false

newState() =>
    SessionState.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<box>())

var SessionState asia = newState()
var SessionState london = newState()
var SessionState newYork = newState()
var int skippedProfiles = 0
var int unavailableBars = 0

method finish(SessionState state, string name, string zone, color heading) =>
    bool valid = state.complete and state.lastClose == state.endTime
    if valid
        drawSessionProfile(state.lows, state.highs, state.opens, state.closes, state.volumes, state.startBar, state.endBar, state.startTime, state.endTime, name, zone, heading)
    else
        array.clear(state.lows)
        array.clear(state.highs)
        array.clear(state.opens)
        array.clear(state.closes)
        array.clear(state.volumes)
    state.startTime := na
    state.endTime := na
    state.lastClose := na
    valid ? 0 : 1

method ingest(SessionState state, int t, int tc, float o, float h, float l, float c, float v, int startStamp, int endStamp, string name, string zone, color heading) =>
    int skipped = 0
    if not na(state.startTime) and (t >= state.endTime or (not na(startStamp) and startStamp != state.startTime))
        skipped += state.finish(name, zone, heading)
    if not na(startStamp)
        if na(state.startTime)
            state.startTime := startStamp
            state.endTime := endStamp
            state.startBar := bar_index
            state.complete := t == startStamp
        else if t != state.lastClose
            state.complete := false
        state.complete := state.complete and not na(v) and v >= 0 and tc == t + 60000
        array.push(state.lows, l)
        array.push(state.highs, h)
        array.push(state.opens, o)
        array.push(state.closes, c)
        array.push(state.volumes, nz(v, 0.0))
        state.lastClose := tc
        state.endBar := bar_index
        if tc == state.endTime
            skipped += state.finish(name, zone, heading)
    skipped

int firstProcessedBar = math.max(0, last_bar_index - historyBarsInput + 1)
if bar_index >= firstProcessedBar
    if timeframe.in_seconds() == 60
        if barstate.isconfirmed
            [asiaStart, asiaEnd] = sessionBounds(asiaSessionInput, asiaTimezoneInput)
            [ls, le] = sessionBounds(londonSessionInput, londonTimezoneInput)
            [ns, ne] = sessionBounds(newYorkSessionInput, newYorkTimezoneInput)
            if showAsiaInput
                skippedProfiles += asia.ingest(time, time_close, open, high, low, close, volume, asiaStart, asiaEnd, "Asia", asiaTimezoneInput, asiaColorInput)
            if showLondonInput
                skippedProfiles += london.ingest(time, time_close, open, high, low, close, volume, ls, le, "London", londonTimezoneInput, londonColorInput)
            if showNewYorkInput
                skippedProfiles += newYork.ingest(time, time_close, open, high, low, close, volume, ns, ne, "New York", newYorkTimezoneInput, newYorkColorInput)
    else if array.size(minuteTimes) > 0
        for i = 0 to array.size(minuteTimes) - 1
            int t = array.get(minuteTimes, i)
            int tc = array.get(minuteCloses, i)
            float o = array.get(minuteOpens, i)
            float h = array.get(minuteHighs, i)
            float l = array.get(minuteLows, i)
            float c = array.get(minutePrices, i)
            float v = array.get(minuteVolumes, i)
            // Closed intrabars only; rollback rebuilds the open chart candle each tick.
            if not barstate.isrealtime or tc <= timenow
                if showAsiaInput
                    skippedProfiles += asia.ingest(t, tc, o, h, l, c, v, array.get(asiaStarts, i), array.get(asiaEnds, i), "Asia", asiaTimezoneInput, asiaColorInput)
                if showLondonInput
                    skippedProfiles += london.ingest(t, tc, o, h, l, c, v, array.get(londonStarts, i), array.get(londonEnds, i), "London", londonTimezoneInput, londonColorInput)
                if showNewYorkInput
                    skippedProfiles += newYork.ingest(t, tc, o, h, l, c, v, array.get(nyStarts, i), array.get(nyEnds, i), "New York", newYorkTimezoneInput, newYorkColorInput)
    else if barstate.isconfirmed
        unavailableBars += 1

// --- Live (developing) session profile ---
// Redrawn on the last bar only. Rollback discards drawings made on earlier ticks of the open candle.
method clearLive(SessionState state) =>
    if array.size(state.liveBoxes) > 0
        for boxIndex = 0 to array.size(state.liveBoxes) - 1
            box.delete(array.get(state.liveBoxes, boxIndex))
        array.clear(state.liveBoxes)
    line.delete(state.livePoc)
    line.delete(state.liveVah)
    line.delete(state.liveVal)
    label.delete(state.liveTitle)
    label.delete(state.livePocTag)
    label.delete(state.liveVahTag)
    label.delete(state.liveValTag)

method drawLive(SessionState state, string name, string zone, color heading) =>
    state.clearLive()
    if showLiveInput and not na(state.startTime) and array.size(state.lows) > 0
        [rows, liveLow, liveHigh, liveRowHeight, livePocIndex, liveVaLowIndex, liveVaHighIndex, liveVaVolume, liveTotal, livePeak] = computeProfile(state.lows, state.highs, state.opens, state.closes, state.volumes)
        if liveTotal > 0 and livePeak > 0
            // Width is scaled to the full session length so the profile does not stretch as the session runs.
            int sessionBars = math.max(1, int(math.round((state.endTime - state.startTime) / barMilliseconds)))
            int liveMaxWidth = overSession ? math.max(1, int(math.round(sessionBars * sessionWidthPercentInput / 100.0))) : profileWidthInput
            int liveStart = overSession ? state.startBar : bar_index + profileOffsetInput
            if showProfilesInput
                for rowIndex = 0 to binsInput - 1
                    float rowVolume = array.get(rows, rowIndex)
                    if rowVolume > 0
                        int rowWidth = math.max(1, int(math.round(rowVolume / livePeak * liveMaxWidth)))
                        float rowBottom = liveLow + liveRowHeight * rowIndex
                        bool insideValueArea = rowIndex >= liveVaLowIndex and rowIndex <= liveVaHighIndex
                        color rowColor = insideValueArea ? valueAreaVolumeColorInput : outsideVolumeColorInput
                        array.push(state.liveBoxes, box.new(liveStart, rowBottom + liveRowHeight, liveStart + rowWidth, rowBottom, xloc=xloc.bar_index, border_color=color.new(rowColor, liveTransparencyInput), border_width=1, bgcolor=color.new(rowColor, liveTransparencyInput)))
            float pocPrice = liveLow + liveRowHeight * (livePocIndex + 0.5)
            float valueAreaLow = liveLow + liveRowHeight * liveVaLowIndex
            float valueAreaHigh = liveLow + liveRowHeight * (liveVaHighIndex + 1)
            string sessionDate = str.format_time(state.startTime, "dd MMM", zone)
            string liveTitle = sessionDate + " " + name + " LIVE"
            state.livePoc := line.new(state.startTime, pocPrice, time_close, pocPrice, xloc=xloc.bar_time, color=pocColorInput, style=line.style_dashed, width=pocWidthInput)
            state.liveVah := line.new(state.startTime, valueAreaHigh, time_close, valueAreaHigh, xloc=xloc.bar_time, color=vahColorInput, style=line.style_dashed, width=vahWidthInput)
            state.liveVal := line.new(state.startTime, valueAreaLow, time_close, valueAreaLow, xloc=xloc.bar_time, color=valColorInput, style=line.style_dashed, width=valWidthInput)
            state.livePocTag := localTag(time_close, pocPrice, "POC", pocColorInput, liveTitle)
            state.liveVahTag := localTag(time_close, valueAreaHigh, "VAH", vahColorInput, liveTitle)
            state.liveValTag := localTag(time_close, valueAreaLow, "VAL", valColorInput, liveTitle)
            string liveTooltip = liveTitle + " (provisional, recalculated every closed minute)" + (state.complete ? "" : "\nPartial: calculation history starts after the session open") + "\nSo far: " + str.format_time(state.startTime, "HH:mm", zone) + "–" + str.format_time(state.lastClose, "HH:mm", zone) + " " + zone + ", session ends " + str.format_time(state.endTime, "HH:mm", zone) + "\nVA volume: " + str.tostring(100.0 * liveVaVolume / liveTotal, "#.##") + "%\nPOC: " + str.tostring(pocPrice, format.mintick) + "\nVAH: " + str.tostring(valueAreaHigh, format.mintick) + "\nVAL: " + str.tostring(valueAreaLow, format.mintick)
            state.liveTitle := label.new(liveStart, liveHigh + liveRowHeight, name + " LIVE" + (state.complete ? "" : " (partial)") + "\n" + sessionDate, xloc=xloc.bar_index, yloc=yloc.price, color=color.new(heading, 45), style=label.style_label_down, textcolor=color.white, size=size.small, tooltip=liveTooltip)

if barstate.islast
    asia.drawLive("Asia", asiaTimezoneInput, asiaColorInput)
    london.drawLive("London", londonTimezoneInput, londonColorInput)
    newYork.drawLive("New York", newYorkTimezoneInput, newYorkColorInput)

// --- Brinks box ---
// First hour of the New York cash open. Plain high/low from chart candles; frozen at the window close.
// Drawn only when the chart timeframe divides 60 minutes, so the box is whole candles (15m = four).
type BrinksBox
    box area
    line highRay
    line lowRay
    float top
    float bottom
    int endTime
    bool closed = false

var array<BrinksBox> brinksBoxes = array.new<BrinksBox>()
var label brinksHighTag = na
var label brinksLowTag = na
bool brinksNewYork = brinksModeInput == "New York 09:00-10:00"
string brinksSession = brinksNewYork ? "0900-1000" : "1400-1500"
string brinksZone = brinksNewYork ? "America/New_York" : "Europe/London"
int chartSeconds = timeframe.in_seconds()
bool brinksTimeframeOk = chartSeconds <= 3600 and 3600 % chartSeconds == 0
bool inBrinks = showBrinksInput and brinksTimeframeOk and not na(time(timeframe.period, brinksSession, brinksZone))
color brinksFillColor = color.new(brinksFillColorInput, 100 - brinksFillInput)

if inBrinks and not inBrinks[1]
    // Only the newest box carries the BRINKS tag.
    if array.size(brinksBoxes) > 0
        box.set_text(array.last(brinksBoxes).area, "")
    box area = box.new(time, high, time_close, low, xloc=xloc.bar_time, border_color=brinksBorderColorInput, border_width=brinksBorderWidthInput, bgcolor=brinksFillColor, text="BRINKS", text_size=size.tiny, text_color=brinksTextColorInput, text_halign=text.align_left, text_valign=text.align_top)
    array.push(brinksBoxes, BrinksBox.new(area, na, na, high, low, time_close))
    // The previous box stays while the new one forms (at most two boxes).
    while array.size(brinksBoxes) > 2
        BrinksBox oldest = array.shift(brinksBoxes)
        box.delete(oldest.area)
        line.delete(oldest.highRay)
        line.delete(oldest.lowRay)
else if inBrinks and array.size(brinksBoxes) > 0
    // Live while the hour is open.
    BrinksBox current = array.last(brinksBoxes)
    current.top := math.max(current.top, high)
    current.bottom := math.min(current.bottom, low)
    current.endTime := time_close
    box.set_top(current.area, current.top)
    box.set_bottom(current.area, current.bottom)
    box.set_right(current.area, current.endTime)

// First bar after the window: freeze the new box, start its high/low lines and remove the previous box.
if not inBrinks and inBrinks[1] and array.size(brinksBoxes) > 0
    BrinksBox finished = array.last(brinksBoxes)
    if not finished.closed
        finished.closed := true
        while array.size(brinksBoxes) > 1
            BrinksBox previous = array.shift(brinksBoxes)
            box.delete(previous.area)
            line.delete(previous.highRay)
            line.delete(previous.lowRay)
        if showBrinksRaysInput
            finished.highRay := line.new(finished.endTime, finished.top, time_close, finished.top, xloc=xloc.bar_time, color=brinksRayColorInput, style=lineStyle(brinksRayStyleInput), width=brinksRayWidthInput)
            finished.lowRay := line.new(finished.endTime, finished.bottom, time_close, finished.bottom, xloc=xloc.bar_time, color=brinksRayColorInput, style=lineStyle(brinksRayStyleInput), width=brinksRayWidthInput)

// High/low lines run to the current bar until their box is replaced.
if array.size(brinksBoxes) > 0
    for b in brinksBoxes
        if b.closed and not na(b.highRay)
            line.set_x2(b.highRay, time_close)
            line.set_x2(b.lowRay, time_close)

if barstate.islast
    label.delete(brinksHighTag)
    label.delete(brinksLowTag)
    if showBrinksLevelsInput and array.size(brinksBoxes) > 0
        // Tag the most recent completed box (during the Brinks hour that is still the previous one).
        BrinksBox latest = array.last(brinksBoxes)
        if not latest.closed and array.size(brinksBoxes) > 1
            latest := array.get(brinksBoxes, array.size(brinksBoxes) - 2)
        if latest.closed
            int tagX = showBrinksRaysInput ? time_close : latest.endTime
            string brinksTip = "Brinks " + str.format_time(latest.endTime - 3600000, "dd MMM HH:mm", "Europe/London") + "-" + str.format_time(latest.endTime, "HH:mm", "Europe/London") + " UK (" + str.format_time(latest.endTime - 3600000, "HH:mm", "America/New_York") + "-" + str.format_time(latest.endTime, "HH:mm", "America/New_York") + " New York)"
            brinksHighTag := label.new(tagX, latest.top, "B.H", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=brinksTextColorInput, size=size.tiny, tooltip=brinksTip + "\nHigh: " + str.tostring(latest.top, format.mintick))
            brinksLowTag := label.new(tagX, latest.bottom, "B.L", xloc=xloc.bar_time, yloc=yloc.price, style=label.style_label_left, color=color.new(chart.bg_color, 100), textcolor=brinksTextColorInput, size=size.tiny, tooltip=brinksTip + "\nLow: " + str.tostring(latest.bottom, format.mintick))

var table coverage = table.new(position.bottom_left, 1, 1)
if barstate.islast
    string message = skippedProfiles > 0 or unavailableBars > 0 ? "1m data: " + str.tostring(skippedProfiles) + " incomplete sessions skipped; " + str.tostring(unavailableBars) + " chart bars unavailable" : ""
    string brinksNote = showBrinksInput and not brinksTimeframeOk ? "Brinks hidden: use a timeframe that divides 60 minutes (1, 3, 5, 15, 30, 60m)" : ""
    message := message + (message != "" and brinksNote != "" ? "\n" : "") + brinksNote
    table.cell(coverage, 0, 0, message, text_color=color.new(chart.fg_color, 25), text_size=size.tiny, bgcolor=color.new(chart.bg_color, 85))

// --- Optional POC extension lifecycle ---
// VAH and VAL never enter this logic. Breaks confirm at the candle close.
if array.size(pocLevels) > 0
    for pocIndex = array.size(pocLevels) - 1 to 0
        PocLevel poc = array.get(pocLevels, pocIndex)
        if poc.active and barstate.isconfirmed and time_close > poc.sessionEndTime
            float price = line.get_y1(poc.drawing)
            bool wickOrBodyHit = false
            bool gapCrossed = false
            if timeframe.in_seconds() == 60 and time >= poc.sessionEndTime
                wickOrBodyHit := low <= price and high >= price
                gapCrossed := not na(close[1]) and ((close[1] < price and open > price) or (close[1] > price and open < price))
            else if array.size(minuteTimes) > 0
                for i = 0 to array.size(minuteTimes) - 1
                    if array.get(minuteTimes, i) >= poc.sessionEndTime
                        float minuteOpen = array.get(minuteOpens, i)
                        float previousClose = i > 0 ? array.get(minutePrices, i - 1) : close[1]
                        wickOrBodyHit := wickOrBodyHit or (array.get(minuteLows, i) <= price and array.get(minuteHighs, i) >= price)
                        gapCrossed := gapCrossed or (not na(previousClose) and ((previousClose < price and minuteOpen > price) or (previousClose > price and minuteOpen < price)))
                        if wickOrBodyHit or gapCrossed
                            break
            if wickOrBodyHit or gapCrossed
                line.set_extend(poc.drawing, extend.none)
                line.set_x2(poc.drawing, poc.localEndTime)
                poc.active := false
                label.delete(poc.extensionTag)
                poc.extensionTag := na
        // Once its profile has left the display and its extension is broken,
        // remove the orphan marker instead of leaving unexplained historical lines.
        if not poc.active and not poc.profileVisible
            line.delete(poc.drawing)
            label.delete(poc.tag)
            label.delete(poc.extensionTag)
            array.remove(pocLevels, pocIndex)

// --- POC labels ---
// All three local tags stay beside their profile. Only the separate extension tag moves.
if barstate.islast and array.size(pocLevels) > 0
    array<float> placedPrices = array.new<float>()
    array<int> placedColumns = array.new<int>()
    for pocIndex = array.size(pocLevels) - 1 to 0
        PocLevel poc = array.get(pocLevels, pocIndex)
        float price = line.get_y1(poc.drawing)
        if poc.active and not na(poc.extensionTag)
            int chosenColumn = 0
            if showExtendedPocLabelsInput
                for candidateColumn = 0 to extendedLabelColumnsInput - 1
                    bool occupied = false
                    if array.size(placedPrices) > 0
                        for placedIndex = 0 to array.size(placedPrices) - 1
                            if array.get(placedColumns, placedIndex) == candidateColumn and math.abs(price - array.get(placedPrices, placedIndex)) < labelSeparation
                                occupied := true
                                break
                    chosenColumn := candidateColumn
                    if not occupied
                        break
                array.push(placedPrices, price)
                array.push(placedColumns, chosenColumn)
            int labelTime = time_close + (extendedLabelOffsetInput + chosenColumn * extendedLabelColumnSpacingInput) * barMilliseconds
            label.set_xy(poc.extensionTag, labelTime, price)
            label.set_text(poc.extensionTag, showExtendedPocLabelsInput ? poc.sessionTitle + "\nPOC " + str.tostring(price, format.mintick) : "")
            label.set_color(poc.extensionTag, color.new(chart.bg_color, showExtendedPocLabelsInput ? 15 : 100))
            label.set_size(poc.extensionTag, size.small)
            label.set_tooltip(poc.extensionTag, poc.sessionTitle + "\nPOC: " + str.tostring(price, format.mintick) + "\nExtends until a subsequent confirmed wick touch or crossing.")
````
