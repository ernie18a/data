# TPO Untapped nPOCs

- url: https://www.tradingview.com/script/lGY6gmHZ-TPO-Untapped-nPOCs/
- type: indicator
- pine_id: PUB;3a6018f768854f5ea519e3ed6f0378e0
- version: 5.0

## Description

TPO Untapped nPOCs calculates TPO profiles using 30-minute blocks and displays Point of Control levels that have not yet been revisited.

Features:

• Three adjustable profile time spans, defaulting to 1D, 1W and 1M
• Automatic row sizing based on the ticker’s minimum tick
• Adjustable calculation accuracy
• Custom colors and level limits
• Configurable retention after a level is filled
• Alerts for new and tapped nPOCs

The indicator reconstructs TPO data from 30-minute price ranges, so results may differ slightly from other Market Profile tools.

## Source Code

````pine
//@version=6
indicator("TPO Untapped nPOCs", "TPO nPOCs", overlay = true,
     max_lines_count = 500, max_labels_count = 500)

//=============================================================================
// INPUTS
//=============================================================================

const string BLOCK_TF = "30"
const int BLOCK_SECONDS = 30 * 60
const int MAX_PROFILE_ROWS = 10000

int chartSeconds = timeframe.in_seconds()

groupCalculation = "TPO calculation"
targetRows = input.int(1000, "Automatic target rows", minval = 20, maxval = 1000, group = groupCalculation, display = display.none,
     tooltip = "The script automatically converts each completed profile's range into approximately this many rows, then rounds the row size to a valid multiple of the ticker's minimum tick. 500 is the default high-accuracy setting; values approaching 1000 require more calculation time.")
filledRetentionBars = input.int(1, "Candles to keep after fill", minval = 0, maxval = 20, group = groupCalculation, display = display.none,
     tooltip = "After an nPOC is first touched, it remains visible through this many additional candles of the selected fill retention timeframe.")
fillAnchorTimeframeInput = input.timeframe("1D", "Fill retention timeframe", group = groupCalculation, display = display.none,
     tooltip = "Select the candle timeframe used for the post-fill countdown. The default is 1D; leave it empty to use the chart timeframe.")
string fillAnchorTimeframe = fillAnchorTimeframeInput == "" ? timeframe.period : fillAnchorTimeframeInput

groupDaily = "Profile 1 nPOCs"
dailyTimeframe = input.timeframe("1D", "Time span", group = groupDaily, display = display.none)
showDaily = input.bool(true, "Show", group = groupDaily, inline = "D1")
dailyColor = input.color(color.rgb(255, 170, 0), "", group = groupDaily, inline = "D1")
maxDaily = input.int(200, "Maximum active levels", minval = 1, maxval = 250, group = groupDaily, display = display.none)

groupWeekly = "Profile 2 nPOCs"
weeklyTimeframe = input.timeframe("1W", "Time span", group = groupWeekly, display = display.none)
showWeekly = input.bool(true, "Show", group = groupWeekly, inline = "W1")
weeklyColor = input.color(color.rgb(0, 188, 212), "", group = groupWeekly, inline = "W1")
maxWeekly = input.int(100, "Maximum active levels", minval = 1, maxval = 125, group = groupWeekly, display = display.none)

groupMonthly = "Profile 3 nPOCs"
monthlyTimeframe = input.timeframe("1M", "Time span", group = groupMonthly, display = display.none)
showMonthly = input.bool(true, "Show", group = groupMonthly, inline = "M1")
monthlyColor = input.color(color.rgb(224, 64, 251), "", group = groupMonthly, inline = "M1")
maxMonthly = input.int(50, "Maximum active levels", minval = 1, maxval = 75, group = groupMonthly, display = display.none)

groupStyle = "Style"
lineWidth = input.int(1, "Line width", minval = 1, maxval = 4, group = groupStyle, display = display.none)
lineStyleInput = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = groupStyle, display = display.none)
rightExtensionBars = input.int(35, "Level extension (bars)", minval = 1, maxval = 500, group = groupStyle, display = display.none,
     tooltip = "Number of chart candles that active nPOC levels and their labels extend to the right.")
showLabels = input.bool(true, "Show timeframe labels", group = groupStyle)
levelsPerSide = input.int(3, "Nearest unfilled levels per side", minval = 1, maxval = 75, group = groupStyle, display = display.none,
     tooltip = "Applies independently to every enabled profile. A value of 5 shows up to five unfilled nPOCs above current price and five below it for each profile category.")

string dailyLevelText = dailyTimeframe + " nPOC"
string weeklyLevelText = weeklyTimeframe + " nPOC"
string monthlyLevelText = monthlyTimeframe + " nPOC"

// Configure the matching webhook URL in TradingView's Create Alert dialog.
// The role ID is not a webhook credential and is required in the JSON body.
const string DISCORD_ROLE_ID = "1539583727355568208"
const int MAX_ALERT_LEVELS_SHOWN = 12

f_discord_message(string headline, string detailsText, int eventTime, string roleId) =>
    string dateText = str.format_time(eventTime, "yyyy-MM-dd", syminfo.timezone)
    "{\"content\":\"" + headline + "\\n" + detailsText + "\\nDate: " + dateText + "\\n\\n<@&" + roleId + ">\",\"allowed_mentions\":{\"parse\":[],\"roles\":[\"" + roleId + "\"]}}"

// The queue survives realtime rollback so first touches remain remembered
// across every execution of the same developing bar.
varip array<string> queuedTapLabels = array.new_string()
varip array<float> queuedTapPrices = array.new_float()
varip int queuedTapBarIndex = na

//=============================================================================
// TYPES AND STATE
//=============================================================================

type TpoProfile
    int periodKey
    int startTime
    array<float> highs
    array<float> lows

type NakedLevel
    float price
    int bornTime
    int filledAnchorKey
    int lastCountedAnchorKey
    int completedAnchorBars
    line lineId
    label labelId

var TpoProfile dailyProfile = TpoProfile.new(na, na, array.new_float(), array.new_float())
var TpoProfile weeklyProfile = TpoProfile.new(na, na, array.new_float(), array.new_float())
var TpoProfile monthlyProfile = TpoProfile.new(na, na, array.new_float(), array.new_float())

var array<NakedLevel> dailyLevels = array.new<NakedLevel>()
var array<NakedLevel> weeklyLevels = array.new<NakedLevel>()
var array<NakedLevel> monthlyLevels = array.new<NakedLevel>()

//=============================================================================
// HELPERS
//=============================================================================

f_lineStyle(string styleName) =>
    switch styleName
        "Solid" => line.style_solid
        "Dotted" => line.style_dotted
        => line.style_dashed

f_isCalendarTimeframe(simple string timeframeString) =>
    str.contains(timeframeString, "D") or
     str.contains(timeframeString, "W") or
     str.contains(timeframeString, "M")

f_isCompatibleProfileTimeframe(simple string timeframeString) =>
    int profileSeconds = timeframe.in_seconds(timeframeString)
    not na(profileSeconds) and profileSeconds >= BLOCK_SECONDS and
     (f_isCalendarTimeframe(timeframeString) or profileSeconds % BLOCK_SECONDS == 0)

f_isCompatibleFillAnchor(simple string timeframeString) =>
    int anchorSeconds = timeframe.in_seconds(timeframeString)
    int processingSeconds = math.min(chartSeconds, BLOCK_SECONDS)
    not na(anchorSeconds) and anchorSeconds >= processingSeconds and
     (f_isCalendarTimeframe(timeframeString) or anchorSeconds % processingSeconds == 0)

// Calculates the POC from completed 30-minute blocks.
// Each block adds one TPO to every price row its high-low range traversed.
// A difference array keeps the work proportional to blocks + rows rather than
// blocks x rows. In a POC tie, the row closest to the profile midpoint wins;
// an exact remaining tie is resolved in favor of the higher row.
f_calculatePoc(array<float> profileHighs, array<float> profileLows, float minimumTick) =>
    float poc = na
    float pocRowLow = na
    float pocRowHigh = na
    int blockCount = array.size(profileHighs)

    if blockCount > 0
        float profileLow = array.min(profileLows)
        float profileHigh = array.max(profileHighs)
        float rangeTicks = math.max((profileHigh - profileLow) / minimumTick, 1.0)
        float rawTicksPerRow = math.max(rangeTicks / targetRows, 1.0)
        float roundingIncrement = rawTicksPerRow < 100.0 ? 5.0 : 50.0 * math.pow(10.0, math.floor(math.log10(rawTicksPerRow / 100.0)))
        float automaticTicksPerRow = math.max(math.round(rawTicksPerRow / roundingIncrement) * roundingIncrement, 1.0)
        float rowSize = automaticTicksPerRow * minimumTick
        float anchor = math.floor(profileLow / rowSize) * rowSize
        int rowCount = int(math.floor((profileHigh - anchor) / rowSize)) + 1

        if rowCount > MAX_PROFILE_ROWS
            runtime.error("The automatic TPO row calculation produced too many rows for this profile.")

        array<int> differences = array.new_int(rowCount + 1, 0)

        for i = 0 to blockCount - 1
            int lowIndex = int(math.floor((array.get(profileLows, i) - anchor) / rowSize))
            int highIndex = int(math.floor((array.get(profileHighs, i) - anchor) / rowSize))
            lowIndex := math.max(0, math.min(rowCount - 1, lowIndex))
            highIndex := math.max(0, math.min(rowCount - 1, highIndex))

            array.set(differences, lowIndex, array.get(differences, lowIndex) + 1)
            if highIndex + 1 < array.size(differences)
                array.set(differences, highIndex + 1, array.get(differences, highIndex + 1) - 1)

        int runningCount = 0
        int bestCount = -1
        int bestIndex = 0
        float profileMidpoint = (profileLow + profileHigh) * 0.5
        float bestDistance = 1e100

        for row = 0 to rowCount - 1
            runningCount += array.get(differences, row)
            float rowMidpoint = anchor + (row + 0.5) * rowSize
            float distance = math.abs(rowMidpoint - profileMidpoint)
            bool winsTie = runningCount == bestCount and (distance < bestDistance or (distance == bestDistance and row > bestIndex))

            if runningCount > bestCount or winsTie
                bestCount := runningCount
                bestIndex := row
                bestDistance := distance

        pocRowLow := anchor + bestIndex * rowSize
        pocRowHigh := pocRowLow + rowSize
        poc := (pocRowLow + pocRowHigh) * 0.5

    [poc, pocRowLow, pocRowHigh]

f_resetProfile(TpoProfile profile) =>
    array.clear(profile.highs)
    array.clear(profile.lows)
    profile.periodKey := na
    profile.startTime := na
    0

f_rollProfile(TpoProfile profile, int newPeriodKey, int boundaryTime, float minimumTick) =>
    bool completed = false
    float poc = na
    float pocRowLow = na
    float pocRowHigh = na

    if na(profile.periodKey)
        profile.periodKey := newPeriodKey
        profile.startTime := boundaryTime
    else if newPeriodKey != profile.periodKey
        if array.size(profile.highs) > 0
            [calculatedPoc, calculatedRowLow, calculatedRowHigh] = f_calculatePoc(profile.highs, profile.lows, minimumTick)
            poc := calculatedPoc
            pocRowLow := calculatedRowLow
            pocRowHigh := calculatedRowHigh
            completed := true

        array.clear(profile.highs)
        array.clear(profile.lows)
        profile.periodKey := newPeriodKey
        profile.startTime := boundaryTime

    [completed, poc, pocRowLow, pocRowHigh]

f_appendBlock(TpoProfile profile, float blockHigh, float blockLow) =>
    array.push(profile.highs, blockHigh)
    array.push(profile.lows, blockLow)
    0

f_finishProfile(TpoProfile profile, int blockCloseTime, int periodCloseTime, float minimumTick) =>
    bool completed = false
    float poc = na
    float pocRowLow = na
    float pocRowHigh = na

    if not na(periodCloseTime) and blockCloseTime >= periodCloseTime and array.size(profile.highs) > 0
        [calculatedPoc, calculatedRowLow, calculatedRowHigh] = f_calculatePoc(profile.highs, profile.lows, minimumTick)
        poc := calculatedPoc
        pocRowLow := calculatedRowLow
        pocRowHigh := calculatedRowHigh
        completed := true
        f_resetProfile(profile)

    [completed, poc, pocRowLow, pocRowHigh]

f_addLevel(array<NakedLevel> levels, float price, int bornTime, string levelText, color levelColor, int maximumLevels) =>
    if not na(price)
        int drawingEndIndex = bar_index + rightExtensionBars
        line newLine = line.new(bar_index, price, drawingEndIndex, price,
             xloc = xloc.bar_index, extend = extend.none, color = levelColor,
             style = f_lineStyle(lineStyleInput), width = lineWidth)

        label newLabel = na
        if showLabels
            newLabel := label.new(drawingEndIndex, price, levelText,
                 xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_left,
                 color = color.new(levelColor, 100), textcolor = levelColor,
                 textalign = text.align_left, size = size.tiny)

        array.push(levels, NakedLevel.new(price, bornTime, na, na, 0, newLine, newLabel))

        if array.size(levels) > maximumLevels
            NakedLevel oldest = array.shift(levels)
            line.delete(oldest.lineId)
            if not na(oldest.labelId)
                label.delete(oldest.labelId)
    0

f_queueTap(array<string> tapLabels, array<float> tapPrices, string levelText, float levelPrice) =>
    bool alreadyQueued = false
    int queuedCount = array.size(tapPrices)

    if queuedCount > 0
        for queueIndex = 0 to queuedCount - 1
            bool sameLabel = array.get(tapLabels, queueIndex) == levelText
            bool samePrice = math.abs(array.get(tapPrices, queueIndex) - levelPrice) <= syminfo.mintick * 0.5
            alreadyQueued := alreadyQueued or (sameLabel and samePrice)

    if not alreadyQueued
        array.push(tapLabels, levelText)
        array.push(tapPrices, levelPrice)

    not alreadyQueued

f_processTouches(array<NakedLevel> levels, float candleHigh, float candleLow, int candleTime, int candleCloseTime, int candleBarIndex, int anchorKey, int anchorCloseTime, bool candleConfirmed, string levelText, array<string> tapLabels, array<float> tapPrices) =>
    bool tappedAny = false
    int i = array.size(levels) - 1

    while i >= 0
        NakedLevel level = array.get(levels, i)
        bool alreadyFilled = not na(level.filledAnchorKey)
        bool deleteLevel = false

        if not alreadyFilled
            bool eligible = candleTime >= level.bornTime
            bool touched = eligible and candleHigh >= level.price and candleLow <= level.price
            if touched
                level.filledAnchorKey := anchorKey
                level.lastCountedAnchorKey := anchorKey
                level.completedAnchorBars := 0
                line.set_x2(level.lineId, candleBarIndex)
                if not na(level.labelId)
                    label.delete(level.labelId)
                    level.labelId := na
                tappedAny := true
                f_queueTap(tapLabels, tapPrices, levelText, level.price)
                deleteLevel := candleConfirmed and filledRetentionBars == 0 and candleCloseTime >= anchorCloseTime
        else
            bool anchorCandleClosed = candleConfirmed and candleCloseTime >= anchorCloseTime
            if anchorCandleClosed
                if anchorKey == level.filledAnchorKey
                    deleteLevel := filledRetentionBars == 0
                else if anchorKey != level.lastCountedAnchorKey
                    level.completedAnchorBars += 1
                    level.lastCountedAnchorKey := anchorKey
                    deleteLevel := level.completedAnchorBars >= filledRetentionBars

        if deleteLevel
            line.delete(level.lineId)
            if not na(level.labelId)
                label.delete(level.labelId)
            array.remove(levels, i)

        i -= 1

    tappedAny

// Selects the requested number of nearest unfilled levels above and below the
// current price for one profile category.
f_selectNearestOnEachSide(array<NakedLevel> levels, float referencePrice, int maximumCount, array<bool> selectedLevels) =>
    array<float> aboveDistances = array.new_float()
    array<int> aboveLevelIndices = array.new_int()
    array<float> belowDistances = array.new_float()
    array<int> belowLevelIndices = array.new_int()
    int levelCount = array.size(levels)

    if levelCount > 0
        for i = 0 to levelCount - 1
            NakedLevel level = array.get(levels, i)

            if na(level.filledAnchorKey)
                float distance = level.price - referencePrice

                if distance > 0
                    array.push(aboveDistances, distance)
                    array.push(aboveLevelIndices, i)
                else if distance < 0
                    array.push(belowDistances, -distance)
                    array.push(belowLevelIndices, i)

    int aboveCount = array.size(aboveDistances)
    if maximumCount > 0 and aboveCount > 0
        array<int> sortedAbove = array.sort_indices(aboveDistances, order.ascending)
        int selectionCount = math.min(maximumCount, aboveCount)

        for rank = 0 to selectionCount - 1
            int candidateIndex = array.get(sortedAbove, rank)
            int levelIndex = array.get(aboveLevelIndices, candidateIndex)
            array.set(selectedLevels, levelIndex, true)

    int belowCount = array.size(belowDistances)
    if maximumCount > 0 and belowCount > 0
        array<int> sortedBelow = array.sort_indices(belowDistances, order.ascending)
        int selectionCount = math.min(maximumCount, belowCount)

        for rank = 0 to selectionCount - 1
            int candidateIndex = array.get(sortedBelow, rank)
            int levelIndex = array.get(belowLevelIndices, candidateIndex)
            array.set(selectedLevels, levelIndex, true)

    0

// Unselected unfilled levels remain stored and continue to be checked for
// touches, but their line and label are made transparent. Retained filled
// levels stay visible independently of the unfilled-level limit.
f_applyVisibility(array<NakedLevel> levels, array<bool> selectedLevels, color levelColor, int rightSideBarIndex) =>
    int levelCount = array.size(levels)

    if levelCount > 0
        for i = 0 to levelCount - 1
            NakedLevel level = array.get(levels, i)
            bool retainedFill = not na(level.filledAnchorKey)
            bool shouldShow = retainedFill or array.get(selectedLevels, i)
            color displayColor = retainedFill ? color.new(levelColor, 50) : shouldShow ? levelColor : color.new(levelColor, 100)

            if not retainedFill
                line.set_x2(level.lineId, rightSideBarIndex)
                if not na(level.labelId)
                    label.set_x(level.labelId, rightSideBarIndex)

            line.set_color(level.lineId, displayColor)
            if not na(level.labelId)
                label.set_textcolor(level.labelId, displayColor)

    0

//=============================================================================
// 30-MINUTE DATA
//=============================================================================

bool calendarChartTimeframe = timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly
bool compatibleTimeframe = not na(chartSeconds) and
     (calendarChartTimeframe or BLOCK_SECONDS % chartSeconds == 0 or chartSeconds % BLOCK_SECONDS == 0)

if barstate.isfirst and not compatibleTimeframe
    runtime.error("Use a time-based chart timeframe that aligns with the 30-minute TPO blocks.")

if barstate.isfirst and not f_isCompatibleProfileTimeframe(dailyTimeframe)
    runtime.error("Profile 1 must be at least 30 minutes and align with 30-minute blocks, or use a calendar day, week, or month span.")

if barstate.isfirst and not f_isCompatibleProfileTimeframe(weeklyTimeframe)
    runtime.error("Profile 2 must be at least 30 minutes and align with 30-minute blocks, or use a calendar day, week, or month span.")

if barstate.isfirst and not f_isCompatibleProfileTimeframe(monthlyTimeframe)
    runtime.error("Profile 3 must be at least 30 minutes and align with 30-minute blocks, or use a calendar day, week, or month span.")

if barstate.isfirst and not f_isCompatibleFillAnchor(fillAnchorTimeframe)
    runtime.error("The fill retention timeframe must be equal to or higher than the script's processing timeframe and align with it.")

bool useIntrabarArrays = chartSeconds > BLOCK_SECONDS

[blockTime, blockCloseTime, blockHigh, blockLow, blockDayKey, blockWeekKey, blockMonthKey, blockFillAnchorKey,
 blockDayClose, blockWeekClose, blockMonthClose, blockFillAnchorClose] = request.security(
     syminfo.tickerid, BLOCK_TF,
     [time, time_close, high, low, time(dailyTimeframe), time(weeklyTimeframe), time(monthlyTimeframe), time(fillAnchorTimeframe),
      time_close(dailyTimeframe), time_close(weeklyTimeframe), time_close(monthlyTimeframe), time_close(fillAnchorTimeframe)],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

[blockTimes, blockCloseTimes, blockHighs, blockLows, blockDayKeys, blockWeekKeys, blockMonthKeys, blockFillAnchorKeys,
 blockDayCloses, blockWeekCloses, blockMonthCloses, blockFillAnchorCloses] = request.security_lower_tf(
     syminfo.tickerid, BLOCK_TF,
     [time, time_close, high, low, time(dailyTimeframe), time(weeklyTimeframe), time(monthlyTimeframe), time(fillAnchorTimeframe),
      time_close(dailyTimeframe), time_close(weeklyTimeframe), time_close(monthlyTimeframe), time_close(fillAnchorTimeframe)],
     ignore_invalid_timeframe = true)

bool dailyCreated = false
bool weeklyCreated = false
bool monthlyCreated = false
bool dailyTapped = false
bool weeklyTapped = false
bool monthlyTapped = false

if na(queuedTapBarIndex) or queuedTapBarIndex != bar_index
    array.clear(queuedTapLabels)
    array.clear(queuedTapPrices)
    queuedTapBarIndex := bar_index

int queuedTapCountBeforeProcessing = array.size(queuedTapPrices)

//=============================================================================
// PROCESSING: CHART TIMEFRAME IS 30 MINUTES OR LOWER
//=============================================================================

if not useIntrabarArrays and barstate.isconfirmed
    int currentDayKey = time(dailyTimeframe)
    int currentWeekKey = time(weeklyTimeframe)
    int currentMonthKey = time(monthlyTimeframe)
    int currentFillAnchorKey = time(fillAnchorTimeframe)
    int currentFillAnchorClose = time_close(fillAnchorTimeframe)

    [dRolled, dRollPoc, dRollLow, dRollHigh] = f_rollProfile(dailyProfile, currentDayKey, time, syminfo.mintick)
    [wRolled, wRollPoc, wRollLow, wRollHigh] = f_rollProfile(weeklyProfile, currentWeekKey, time, syminfo.mintick)
    [mRolled, mRollPoc, mRollLow, mRollHigh] = f_rollProfile(monthlyProfile, currentMonthKey, time, syminfo.mintick)

    if dRolled and showDaily
        f_addLevel(dailyLevels, dRollPoc, time, dailyLevelText, dailyColor, maxDaily)
        dailyCreated := true
    if wRolled and showWeekly
        f_addLevel(weeklyLevels, wRollPoc, time, weeklyLevelText, weeklyColor, maxWeekly)
        weeklyCreated := true
    if mRolled and showMonthly
        f_addLevel(monthlyLevels, mRollPoc, time, monthlyLevelText, monthlyColor, maxMonthly)
        monthlyCreated := true

    dailyTapped := f_processTouches(dailyLevels, high, low, time, time_close, bar_index, currentFillAnchorKey, currentFillAnchorClose, true, dailyLevelText, queuedTapLabels, queuedTapPrices)
    weeklyTapped := f_processTouches(weeklyLevels, high, low, time, time_close, bar_index, currentFillAnchorKey, currentFillAnchorClose, true, weeklyLevelText, queuedTapLabels, queuedTapPrices)
    monthlyTapped := f_processTouches(monthlyLevels, high, low, time, time_close, bar_index, currentFillAnchorKey, currentFillAnchorClose, true, monthlyLevelText, queuedTapLabels, queuedTapPrices)

    bool completedThirtyMinuteBlock = time_close == blockCloseTime

    if completedThirtyMinuteBlock and not na(blockHigh) and not na(blockLow)
        f_appendBlock(dailyProfile, blockHigh, blockLow)
        f_appendBlock(weeklyProfile, blockHigh, blockLow)
        f_appendBlock(monthlyProfile, blockHigh, blockLow)

        [dClosed, dPoc, dRowLow, dRowHigh] = f_finishProfile(dailyProfile, blockCloseTime, blockDayClose, syminfo.mintick)
        [wClosed, wPoc, wRowLow, wRowHigh] = f_finishProfile(weeklyProfile, blockCloseTime, blockWeekClose, syminfo.mintick)
        [mClosed, mPoc, mRowLow, mRowHigh] = f_finishProfile(monthlyProfile, blockCloseTime, blockMonthClose, syminfo.mintick)

        if dClosed and showDaily
            f_addLevel(dailyLevels, dPoc, blockDayClose, dailyLevelText, dailyColor, maxDaily)
            dailyCreated := true
        if wClosed and showWeekly
            f_addLevel(weeklyLevels, wPoc, blockWeekClose, weeklyLevelText, weeklyColor, maxWeekly)
            weeklyCreated := true
        if mClosed and showMonthly
            f_addLevel(monthlyLevels, mPoc, blockMonthClose, monthlyLevelText, monthlyColor, maxMonthly)
            monthlyCreated := true

//=============================================================================
// PROCESSING: CHART TIMEFRAME IS ABOVE 30 MINUTES
//=============================================================================

if useIntrabarArrays and barstate.isconfirmed
    int intrabarCount = array.size(blockTimes)

    if intrabarCount > 0
        for i = 0 to intrabarCount - 1
            int intrabarTime = array.get(blockTimes, i)
            int intrabarClose = array.get(blockCloseTimes, i)
            float intrabarHigh = array.get(blockHighs, i)
            float intrabarLow = array.get(blockLows, i)
            int dayKey = array.get(blockDayKeys, i)
            int weekKey = array.get(blockWeekKeys, i)
            int monthKey = array.get(blockMonthKeys, i)
            int fillAnchorKey = array.get(blockFillAnchorKeys, i)
            int dayClose = array.get(blockDayCloses, i)
            int weekClose = array.get(blockWeekCloses, i)
            int monthClose = array.get(blockMonthCloses, i)
            int fillAnchorClose = array.get(blockFillAnchorCloses, i)

            [dRolled, dRollPoc, dRollLow, dRollHigh] = f_rollProfile(dailyProfile, dayKey, intrabarTime, syminfo.mintick)
            [wRolled, wRollPoc, wRollLow, wRollHigh] = f_rollProfile(weeklyProfile, weekKey, intrabarTime, syminfo.mintick)
            [mRolled, mRollPoc, mRollLow, mRollHigh] = f_rollProfile(monthlyProfile, monthKey, intrabarTime, syminfo.mintick)

            if dRolled and showDaily
                f_addLevel(dailyLevels, dRollPoc, intrabarTime, dailyLevelText, dailyColor, maxDaily)
                dailyCreated := true
            if wRolled and showWeekly
                f_addLevel(weeklyLevels, wRollPoc, intrabarTime, weeklyLevelText, weeklyColor, maxWeekly)
                weeklyCreated := true
            if mRolled and showMonthly
                f_addLevel(monthlyLevels, mRollPoc, intrabarTime, monthlyLevelText, monthlyColor, maxMonthly)
                monthlyCreated := true

            dailyTapped := f_processTouches(dailyLevels, intrabarHigh, intrabarLow, intrabarTime, intrabarClose, bar_index, fillAnchorKey, fillAnchorClose, true, dailyLevelText, queuedTapLabels, queuedTapPrices) or dailyTapped
            weeklyTapped := f_processTouches(weeklyLevels, intrabarHigh, intrabarLow, intrabarTime, intrabarClose, bar_index, fillAnchorKey, fillAnchorClose, true, weeklyLevelText, queuedTapLabels, queuedTapPrices) or weeklyTapped
            monthlyTapped := f_processTouches(monthlyLevels, intrabarHigh, intrabarLow, intrabarTime, intrabarClose, bar_index, fillAnchorKey, fillAnchorClose, true, monthlyLevelText, queuedTapLabels, queuedTapPrices) or monthlyTapped

            f_appendBlock(dailyProfile, intrabarHigh, intrabarLow)
            f_appendBlock(weeklyProfile, intrabarHigh, intrabarLow)
            f_appendBlock(monthlyProfile, intrabarHigh, intrabarLow)

            [dClosed, dPoc, dRowLow, dRowHigh] = f_finishProfile(dailyProfile, intrabarClose, dayClose, syminfo.mintick)
            [wClosed, wPoc, wRowLow, wRowHigh] = f_finishProfile(weeklyProfile, intrabarClose, weekClose, syminfo.mintick)
            [mClosed, mPoc, mRowLow, mRowHigh] = f_finishProfile(monthlyProfile, intrabarClose, monthClose, syminfo.mintick)

            if dClosed and showDaily
                f_addLevel(dailyLevels, dPoc, dayClose, dailyLevelText, dailyColor, maxDaily)
                dailyCreated := true
            if wClosed and showWeekly
                f_addLevel(weeklyLevels, wPoc, weekClose, weeklyLevelText, weeklyColor, maxWeekly)
                weeklyCreated := true
            if mClosed and showMonthly
                f_addLevel(monthlyLevels, mPoc, monthClose, monthlyLevelText, monthlyColor, maxMonthly)
                monthlyCreated := true

// Process the developing realtime candle on every price update so a level
// changes appearance on its first touch. Profile construction remains gated
// by bar confirmation in the sections above.
if barstate.islast and not barstate.isconfirmed
    int liveCandleTime = time
    int liveCandleCloseTime = time_close
    float liveCandleHigh = high
    float liveCandleLow = low
    int liveFillAnchorKey = time(fillAnchorTimeframe)
    int liveFillAnchorClose = time_close(fillAnchorTimeframe)

    if not na(liveCandleTime) and not na(liveCandleHigh) and not na(liveCandleLow) and not na(liveFillAnchorKey) and not na(liveFillAnchorClose)
        dailyTapped := f_processTouches(dailyLevels, liveCandleHigh, liveCandleLow, liveCandleTime, liveCandleCloseTime, bar_index, liveFillAnchorKey, liveFillAnchorClose, false, dailyLevelText, queuedTapLabels, queuedTapPrices)
        weeklyTapped := f_processTouches(weeklyLevels, liveCandleHigh, liveCandleLow, liveCandleTime, liveCandleCloseTime, bar_index, liveFillAnchorKey, liveFillAnchorClose, false, weeklyLevelText, queuedTapLabels, queuedTapPrices)
        monthlyTapped := f_processTouches(monthlyLevels, liveCandleHigh, liveCandleLow, liveCandleTime, liveCandleCloseTime, bar_index, liveFillAnchorKey, liveFillAnchorClose, false, monthlyLevelText, queuedTapLabels, queuedTapPrices)

// Alert immediately when this execution discovers new levels. The varip queue
// survives realtime rollback, so later ticks cannot resend the same span/price.
// Several levels first seen on the same update share one Discord message.
int queuedTapCountAfterProcessing = array.size(queuedTapPrices)
int newlyQueuedTapCount = queuedTapCountAfterProcessing - queuedTapCountBeforeProcessing
if newlyQueuedTapCount > 0
    int firstNewTapIndex = queuedTapCountBeforeProcessing
    string alertHeadline = syminfo.ticker + " crossing " + (newlyQueuedTapCount == 1 ? array.get(queuedTapLabels, firstNewTapIndex) : str.tostring(newlyQueuedTapCount) + " nPOCs")
    string alertDetails = ""
    int displayedTapCount = math.min(newlyQueuedTapCount, MAX_ALERT_LEVELS_SHOWN)

    if newlyQueuedTapCount == 1
        alertDetails := "Price: " + str.tostring(array.get(queuedTapPrices, firstNewTapIndex), format.mintick)
    else
        for displayedIndex = 0 to displayedTapCount - 1
            int tapIndex = firstNewTapIndex + displayedIndex
            string linePrefix = displayedIndex == 0 ? "" : "\\n"
            alertDetails += linePrefix + array.get(queuedTapLabels, tapIndex) + ": " + str.tostring(array.get(queuedTapPrices, tapIndex), format.mintick)
        if newlyQueuedTapCount > displayedTapCount
            alertDetails += "\\n+" + str.tostring(newlyQueuedTapCount - displayedTapCount) + " more nPOCs"

    alert(f_discord_message(alertHeadline, alertDetails, time, DISCORD_ROLE_ID), alert.freq_all)

//=============================================================================
// DISPLAY THE NEAREST UNFILLED LEVELS ABOVE AND BELOW CURRENT PRICE
//=============================================================================

if barstate.islast
    array<bool> dailySelected = array.new_bool(array.size(dailyLevels), false)
    array<bool> weeklySelected = array.new_bool(array.size(weeklyLevels), false)
    array<bool> monthlySelected = array.new_bool(array.size(monthlyLevels), false)

    f_selectNearestOnEachSide(dailyLevels, close, levelsPerSide, dailySelected)
    f_selectNearestOnEachSide(weeklyLevels, close, levelsPerSide, weeklySelected)
    f_selectNearestOnEachSide(monthlyLevels, close, levelsPerSide, monthlySelected)

    int rightSideBarIndex = bar_index + rightExtensionBars
    f_applyVisibility(dailyLevels, dailySelected, dailyColor, rightSideBarIndex)
    f_applyVisibility(weeklyLevels, weeklySelected, weeklyColor, rightSideBarIndex)
    f_applyVisibility(monthlyLevels, monthlySelected, monthlyColor, rightSideBarIndex)

//=============================================================================
// DATA WINDOW
//=============================================================================

plot(array.size(dailyLevels), "Active Profile 1 nPOCs", display = display.data_window, color = na)
plot(array.size(weeklyLevels), "Active Profile 2 nPOCs", display = display.data_window, color = na)
plot(array.size(monthlyLevels), "Active Profile 3 nPOCs", display = display.data_window, color = na)
plot(syminfo.mintick, "Ticker minimum tick", display = display.data_window, color = na)
````
