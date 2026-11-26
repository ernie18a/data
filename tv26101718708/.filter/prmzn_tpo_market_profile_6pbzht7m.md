# PRMZN TPO Market Profile

- url: https://www.tradingview.com/script/6PBzhT7m-prmzn-tpo-market-profile/
- type: indicator
- pine_id: PUB;1464893cd6ea4eb381b9cb0e4fb5033a
- version: 2.0

## Description

PRMZN TPO — Market Profile
A clean, beginner-friendly TPO (Time Price Opportunity) / Market Profile tool for intraday traders. It builds a letter-based distribution of where price spent time, then derives the key auction levels — POC, Value Area, Initial Balance, single prints and profile shape — for the daily session or for the individual Asia / London / New York sessions.
What it does
The trading period is divided into time blocks (default 30 minutes), and each block is assigned a letter (A, B, C…). For every price row that a block trades through, that letter is recorded. The result is a horizontal histogram of activity:
POC (Point of Control) — the most-traded price row, the fair-value magnet of the session.
Value Area (VAH / VAL) — the range containing 70% of activity (configurable), where the bulk of business was done.
Initial Balance — the high/low of the first hour, the opening auction reference.
Single prints — rows touched only once, marking fast impulsive moves and imbalances.
Profile shape — automatic P (short-cover) / b (liquidation) / D (balance) classification.

## Source Code

````pine
//@version=6
indicator(
     "PRMZN TPO Pro v3 - Market Profile",
     shorttitle = "PRMZN TPO Pro",
     overlay = true,
     max_boxes_count = 500,
     max_lines_count = 500,
     max_labels_count = 500,
     max_bars_back = 5000
)

// Professional market profile toolkit.
// Focus: clean developing profile, Prior day profiles, key levels, and Market Context.
// TPO rows are approximated from each chart bar's high-low range. Use lower chart timeframes for better precision.

//==============================================================================
// Inputs
//==============================================================================

gProfile = "1. Profile"
profileModeInput = input.string("Daily", "Profile period", options = ["Daily", "Session (Asia/London/NY)", "Custom session"], group = gProfile)
blockMinInput = input.int(30, "TPO block, minutes", minval = 1, maxval = 240, group = gProfile)
ibMinInput = input.int(60, "Initial Balance, minutes", minval = 5, maxval = 240, group = gProfile)
confirmAlertsInput = input.bool(true, "Confirm alerts on bar close", group = gProfile)

gSessions = "2. Sessions"
dstSummerInput = input.bool(false, "Summer DST: shift London and NY -1h", group = gSessions, tooltip = "Use this when London and New York open one hour earlier by UTC. Tokyo is not shifted.")
sessionTzInput = input.string("UTC", "Session timezone", options = ["UTC", "America/New_York", "Europe/London", "Asia/Tokyo"], group = gSessions)
asiaSessionInput = input.session("0000-0900", "Asia (Tokyo)", group = gSessions)
londonSessionInput = input.session("0800-1600", "London", group = gSessions)
nySessionInput = input.session("1300-2200", "New York", group = gSessions)
showAsiaInput = input.bool(true, "Show Asia", group = gSessions)
showLondonInput = input.bool(true, "Show London", group = gSessions)
showNyInput = input.bool(true, "Show New York", group = gSessions)
compositeInSessionInput = input.bool(false, "Show full-day composite in Session mode", group = gSessions)
customSessionInput = input.session("0800-1300", "Custom session window", group = gSessions)
customTzInput = input.string("UTC", "Custom timezone", options = ["UTC", "America/New_York", "Europe/London", "Asia/Tokyo"], group = gSessions)

gGrid = "3. Grid"
stepModeInput = input.string("Auto", "Row step mode", options = ["Auto", "Manual ticks"], group = gGrid)
atrLengthInput = input.int(14, "ATR length fallback", minval = 2, maxval = 100, group = gGrid)
targetRowsInput = input.int(44, "Target rows in Auto mode", minval = 15, maxval = 100, group = gGrid)
manualTickStepInput = input.int(100, "Manual step, ticks", minval = 1, maxval = 5000, group = gGrid)
maxRowsInput = input.int(220, "Max stored rows", minval = 40, maxval = 300, group = gGrid)
valueAreaPctInput = input.float(70.0, "Value Area %", minval = 50.0, maxval = 90.0, step = 1.0, group = gGrid)

gRender = "4. Render"
visualPresetInput = input.string("Pro", "Visual preset", options = ["Clean", "Pro", "Full"], group = gRender)
renderModeInput = input.string("Blocks", "Render mode", options = ["Blocks", "Letters"], group = gRender)
letterSizeInput = input.string("Tiny", "Letter size", options = ["Tiny", "Small", "Normal"], group = gRender)
blockWidthInput = input.int(22, "Current profile width", minval = 5, maxval = 120, group = gRender)
priorBlockWidthInput = input.int(10, "Prior profile width", minval = 3, maxval = 60, group = gRender)
renderRowsInput = input.int(150, "Max visible rows per profile", minval = 30, maxval = 260, group = gRender)
showSinglePrintsInput = input.bool(false, "Single prints in Daily/Custom", group = gRender)
showSessionSinglePrintsInput = input.bool(false, "Single prints in Session mode", group = gRender)
showIbInput = input.bool(true, "Initial Balance lines in Daily/Custom", group = gRender)
showOpenInput = input.bool(true, "Open marker", group = gRender)
showValueAreaBgInput = input.bool(true, "Value Area shading in Daily/Custom", group = gRender)
showLabelsInput = input.bool(true, "Level labels", group = gRender)
showEquilibriumInput = input.bool(true, "Show excess / poor high-low hints", group = gRender)
extendLevelsInput = input.bool(false, "Extend current levels right", group = gRender)
lettersOnHistoryInput = input.bool(false, "Letters on history profiles", group = gRender)
detailProfilesInput = input.int(5, "Prior day profiles", minval = 1, maxval = 8, group = gRender)
profileOffsetInput = input.int(3, "Profile offset, bars", minval = 0, maxval = 50, group = gRender)

gLevels = "5. Levels and Alerts"
showNakedPocInput = input.bool(true, "Naked POC in Daily/Custom", group = gLevels)
showTestedPocInput = input.bool(false, "Keep tested naked POCs", group = gLevels)
levelMemoryInput = input.int(45, "Naked POC memory, periods", minval = 1, maxval = 250, group = gLevels)
showPriorLevelsInput = input.bool(true, "Prior day levels", group = gLevels)
priorLevelsLookbackInput = input.int(3, "Prior level sets", minval = 1, maxval = 10, group = gLevels)
showPriorRangeInput = input.bool(true, "Prior high / low", group = gLevels)
alertPocTouchInput = input.bool(true, "Alert: current POC touched", group = gLevels)
alertVaBreakInput = input.bool(true, "Alert: VAH/VAL break", group = gLevels)
alertNakedPocTouchInput = input.bool(true, "Alert: naked POC touched", group = gLevels)

gDash = "6. Dashboard"
showDashboardInput = input.bool(true, "Market Context dashboard", group = gDash)
dashboardPosInput = input.string("top_right", "Dashboard position", options = ["top_right", "bottom_right", "bottom_left", "top_left"], group = gDash)
showHealthInput = input.bool(true, "Show health row", group = gDash)

gColors = "7. Colors"
pocColorInput = input.color(color.rgb(255, 200, 60), "POC", group = gColors)
vaColorInput = input.color(color.rgb(220, 220, 220), "Value Area", group = gColors)
tpoColorInput = input.color(color.rgb(112, 128, 144), "TPO outside VA", group = gColors)
singlePrintColorInput = input.color(color.rgb(255, 99, 71), "Single print", group = gColors)
ibColorInput = input.color(color.rgb(120, 120, 130), "Initial Balance", group = gColors)
openColorInput = input.color(color.rgb(30, 144, 255), "Open marker", group = gColors)
valueAreaBgColorInput = input.color(color.rgb(18, 26, 20), "Value Area shading", group = gColors)
compositeColorInput = input.color(color.rgb(150, 130, 200), "Composite accent", group = gColors)
asiaColorInput = input.color(color.rgb(120, 160, 255), "Asia accent", group = gColors)
londonColorInput = input.color(color.rgb(0, 200, 120), "London accent", group = gColors)
nyColorInput = input.color(color.rgb(255, 140, 60), "New York accent", group = gColors)
textColorInput = input.color(color.white, "Text", group = gColors)

//==============================================================================
// Timeframe gate and constants
//==============================================================================

bool isIntraday = timeframe.isintraday
int tfMinutes = int(timeframe.in_seconds() / 60)
bool tfAllowed = isIntraday and tfMinutes <= 30

int blockMs = blockMinInput * 60 * 1000
int ibMs = ibMinInput * 60 * 1000
int staleMs = 24 * 60 * 60 * 1000

bool modeDaily = profileModeInput == "Daily"
bool modeSession = profileModeInput == "Session (Asia/London/NY)"
bool modeCustom = profileModeInput == "Custom session"

//==============================================================================
// Types
//==============================================================================

type TpoProfile
    bool valid = false
    bool capped = false
    float step = na
    float rowBottom = na
    int startBar = na
    int endBar = na
    int startTime = na
    int endTime = na
    array<string> letters
    array<int> counts
    float ibHigh = na
    float ibLow = na
    float openPrice = na
    float periodHigh = na
    float periodLow = na
    int pocRow = 0
    int valRow = 0
    int vahRow = 0
    int maxCount = 0
    int totalTpo = 0
    float pocPrice = na
    float vahPrice = na
    float valPrice = na
    bool poorHigh = false
    bool poorLow = false

type TpoLevelRec
    int startTime = na
    int endTime = na
    float poc = na
    float vah = na
    float val = na
    bool tested = false
    int testTime = na

type TpoStream
    bool active = false
    color accent = na
    string name = ""
    TpoProfile cur
    array<TpoProfile> historyProfiles
    array<TpoLevelRec> historyLevels

//==============================================================================
// Helpers
//==============================================================================

f_table_pos(string pos) =>
    switch pos
        "top_left" => position.top_left
        "bottom_left" => position.bottom_left
        "bottom_right" => position.bottom_right
        => position.top_right

f_text_size(string value) =>
    switch value
        "Small" => size.small
        "Normal" => size.normal
        => size.tiny

f_letter(int index) =>
    string upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    string lower = "abcdefghijklmnopqrstuvwxyz"
    string result = "+"
    if index >= 0 and index < 26
        result := str.substring(upper, index, index + 1)
    else if index >= 26 and index < 52
        result := str.substring(lower, index - 26, index - 25)
    result

f_new_profile() =>
    TpoProfile p = TpoProfile.new()
    p.letters := array.new<string>()
    p.counts := array.new<int>()
    p

f_new_stream(bool active, color accent, string name) =>
    TpoStream s = TpoStream.new()
    s.active := active
    s.accent := accent
    s.name := name
    s.cur := f_new_profile()
    s.historyProfiles := array.new<TpoProfile>()
    s.historyLevels := array.new<TpoLevelRec>()
    s

f_copy_profile(TpoProfile src) =>
    TpoProfile dst = TpoProfile.new()
    dst.valid := src.valid
    dst.capped := src.capped
    dst.step := src.step
    dst.rowBottom := src.rowBottom
    dst.startBar := src.startBar
    dst.endBar := src.endBar
    dst.startTime := src.startTime
    dst.endTime := src.endTime
    dst.letters := array.copy(src.letters)
    dst.counts := array.copy(src.counts)
    dst.ibHigh := src.ibHigh
    dst.ibLow := src.ibLow
    dst.openPrice := src.openPrice
    dst.periodHigh := src.periodHigh
    dst.periodLow := src.periodLow
    dst.pocRow := src.pocRow
    dst.valRow := src.valRow
    dst.vahRow := src.vahRow
    dst.maxCount := src.maxCount
    dst.totalTpo := src.totalTpo
    dst.pocPrice := src.pocPrice
    dst.vahPrice := src.vahPrice
    dst.valPrice := src.valPrice
    dst.poorHigh := src.poorHigh
    dst.poorLow := src.poorLow
    dst

f_shift_session(string sessionText, bool shiftEarlier) =>
    string result = sessionText
    if shiftEarlier and str.length(sessionText) == 9
        int startHour = int(str.tonumber(str.substring(sessionText, 0, 2)))
        int startMinute = int(str.tonumber(str.substring(sessionText, 2, 4)))
        int endHour = int(str.tonumber(str.substring(sessionText, 5, 7)))
        int endMinute = int(str.tonumber(str.substring(sessionText, 7, 9)))
        startHour := (startHour + 23) % 24
        endHour := (endHour + 23) % 24
        string sh = (startHour < 10 ? "0" : "") + str.tostring(startHour)
        string sm = (startMinute < 10 ? "0" : "") + str.tostring(startMinute)
        string eh = (endHour < 10 ? "0" : "") + str.tostring(endHour)
        string em = (endMinute < 10 ? "0" : "") + str.tostring(endMinute)
        result := sh + sm + "-" + eh + em
    result

f_finalize_profile(TpoProfile p, float valueAreaPct) =>
    int rowCount = array.size(p.counts)
    int poc = 0
    int maxCount = 0
    int total = 0
    if rowCount > 0
        float center = (rowCount - 1) / 2.0
        float bestDistance = 1000000.0
        for row = 0 to rowCount - 1
            int count = array.get(p.counts, row)
            total += count
            float dist = math.abs(row - center)
            bool betterCount = count > maxCount
            bool equalBetterLocation = count == maxCount and dist < bestDistance
            if betterCount or equalBetterLocation
                maxCount := count
                bestDistance := dist
                poc := row

    int lowRow = poc
    int highRow = poc
    int cumulative = maxCount
    float target = total * valueAreaPct / 100.0
    int guard = 0
    while cumulative < target and guard < rowCount
        int upCount = highRow < rowCount - 1 ? array.get(p.counts, highRow + 1) : -1
        int downCount = lowRow > 0 ? array.get(p.counts, lowRow - 1) : -1
        if upCount == -1 and downCount == -1
            guard := rowCount
        else if upCount > downCount
            highRow += 1
            cumulative += math.max(upCount, 0)
        else if downCount > upCount
            lowRow -= 1
            cumulative += math.max(downCount, 0)
        else
            bool canUp = upCount >= 0
            bool canDown = downCount >= 0
            if canUp
                highRow += 1
                cumulative += upCount
            if canDown and cumulative < target
                lowRow -= 1
                cumulative += downCount
        guard += 1

    p.pocRow := poc
    p.valRow := lowRow
    p.vahRow := highRow
    p.maxCount := maxCount
    p.totalTpo := total
    p.poorHigh := rowCount > 0 and array.get(p.counts, rowCount - 1) > 1
    p.poorLow := rowCount > 0 and array.get(p.counts, 0) > 1
    if rowCount > 0 and not na(p.rowBottom) and not na(p.step)
        p.pocPrice := p.rowBottom + (poc + 0.5) * p.step
        p.vahPrice := p.rowBottom + (highRow + 1.0) * p.step
        p.valPrice := p.rowBottom + lowRow * p.step

f_profile_shape(TpoProfile p) =>
    string result = "D balance"
    int rowCount = array.size(p.counts)
    if rowCount >= 5 and p.maxCount > 0
        float thin = p.maxCount * 0.15
        int lowerTail = 0
        bool lowerDone = false
        for i = 0 to rowCount - 1
            if not lowerDone
                if array.get(p.counts, i) <= thin
                    lowerTail += 1
                else
                    lowerDone := true
        int upperTail = 0
        bool upperDone = false
        for i = 0 to rowCount - 1
            int row = rowCount - 1 - i
            if not upperDone
                if array.get(p.counts, row) <= thin
                    upperTail += 1
                else
                    upperDone := true
        float pocLocation = rowCount > 1 ? p.pocRow / (rowCount - 1.0) : 0.5
        int minTail = int(math.max(2.0, rowCount * 0.12))
        if pocLocation >= 0.55 and lowerTail > upperTail and lowerTail >= minTail
            result := "P short cover"
        else if pocLocation <= 0.45 and upperTail > lowerTail and upperTail >= minTail
            result := "b liquidation"
    result

f_open_location(TpoProfile currentProfile, TpoProfile priorProfile) =>
    string result = "New auction"
    if priorProfile.valid and not na(currentProfile.openPrice) and not na(priorProfile.vahPrice) and not na(priorProfile.valPrice)
        if currentProfile.openPrice > priorProfile.periodHigh
            result := "Gap above range"
        else if currentProfile.openPrice < priorProfile.periodLow
            result := "Gap below range"
        else if currentProfile.openPrice > priorProfile.vahPrice
            result := "Above prior value"
        else if currentProfile.openPrice < priorProfile.valPrice
            result := "Below prior value"
        else
            result := "Inside prior value"
    result

f_value_status(TpoProfile profile) =>
    string result = "Building"
    if profile.valid and not na(profile.vahPrice) and not na(profile.valPrice)
        if close > profile.vahPrice
            result := "Above value"
        else if close < profile.valPrice
            result := "Below value"
        else
            result := "Inside value"
    result

f_ib_extension(TpoProfile profile) =>
    string result = "IB forming"
    if profile.valid and not na(profile.ibHigh) and not na(profile.ibLow) and not na(profile.periodHigh) and not na(profile.periodLow)
        bool up = profile.periodHigh > profile.ibHigh
        bool down = profile.periodLow < profile.ibLow
        if up and down
            result := "Both sides"
        else if up
            result := "Upside"
        else if down
            result := "Downside"
        else
            result := "None"
    result

f_last_profile(TpoStream TpoStream) =>
    TpoProfile result = f_new_profile()
    if array.size(TpoStream.historyProfiles) > 0
        result := array.get(TpoStream.historyProfiles, array.size(TpoStream.historyProfiles) - 1)
    result

f_add_bar_to_profile(TpoProfile p, float step, float barHigh, float barLow, int blockIndex, int maxRows) =>
    if array.size(p.counts) == 0
        p.rowBottom := math.floor(barLow / step) * step
        array.push(p.letters, "")
        array.push(p.counts, 0)

    int growDownGuard = 0
    while barLow < p.rowBottom and array.size(p.counts) < maxRows and growDownGuard < maxRows
        array.unshift(p.letters, "")
        array.unshift(p.counts, 0)
        p.rowBottom -= step
        growDownGuard += 1

    int growUpGuard = 0
    while barHigh >= p.rowBottom + array.size(p.counts) * step and array.size(p.counts) < maxRows and growUpGuard < maxRows
        array.push(p.letters, "")
        array.push(p.counts, 0)
        growUpGuard += 1

    if array.size(p.counts) >= maxRows and (barLow < p.rowBottom or barHigh >= p.rowBottom + array.size(p.counts) * step)
        p.capped := true

    string letter = f_letter(blockIndex)
    int lowIndex = math.max(0, int(math.floor((barLow - p.rowBottom) / step)))
    int highIndex = math.min(array.size(p.counts) - 1, int(math.floor((barHigh - p.rowBottom) / step)))
    if highIndex >= lowIndex
        for row = lowIndex to highIndex
            string rowLetters = array.get(p.letters, row)
            if not str.contains(rowLetters, letter)
                array.set(p.letters, row, rowLetters + letter)
                array.set(p.counts, row, array.get(p.counts, row) + 1)

f_start_profile(TpoStream TpoStream, float step, int maxRows) =>
    TpoStream.cur := f_new_profile()
    TpoStream.cur.valid := true
    TpoStream.cur.step := step
    TpoStream.cur.startTime := time
    TpoStream.cur.startBar := bar_index
    TpoStream.cur.ibHigh := high
    TpoStream.cur.ibLow := low
    TpoStream.cur.openPrice := open
    TpoStream.cur.periodHigh := high
    TpoStream.cur.periodLow := low
    f_add_bar_to_profile(TpoStream.cur, step, high, low, 0, maxRows)

f_archive_stream(TpoStream TpoStream, float valueAreaPct, int levelMemory, int detailProfiles) =>
    if TpoStream.cur.valid and array.size(TpoStream.cur.counts) > 0
        TpoStream.cur.endBar := math.max(TpoStream.cur.startBar, bar_index - 1)
        TpoStream.cur.endTime := time[1]
        f_finalize_profile(TpoStream.cur, valueAreaPct)
        TpoLevelRec level = TpoLevelRec.new(TpoStream.cur.startTime, time[1], TpoStream.cur.pocPrice, TpoStream.cur.vahPrice, TpoStream.cur.valPrice, false, na)
        array.push(TpoStream.historyLevels, level)
        while array.size(TpoStream.historyLevels) > levelMemory
            array.shift(TpoStream.historyLevels)
        array.push(TpoStream.historyProfiles, f_copy_profile(TpoStream.cur))
        while array.size(TpoStream.historyProfiles) > math.max(0, detailProfiles - 1)
            array.shift(TpoStream.historyProfiles)

f_update_stream(TpoStream TpoStream, bool inNow, bool wasIn, bool forceNew, float step, int maxRows, float valueAreaPct, int levelMemory, int detailProfiles) =>
    if TpoStream.active
        bool stale = TpoStream.cur.valid and not na(TpoStream.cur.startTime) and time - TpoStream.cur.startTime > staleMs
        bool startNew = inNow and (forceNew or not wasIn or stale)
        if startNew
            if TpoStream.cur.valid and not stale
                f_archive_stream(TpoStream, valueAreaPct, levelMemory, detailProfiles)
            f_start_profile(TpoStream, step, maxRows)
        else if inNow and TpoStream.cur.valid and not na(TpoStream.cur.step) and array.size(TpoStream.cur.counts) > 0
            TpoStream.cur.periodHigh := math.max(TpoStream.cur.periodHigh, high)
            TpoStream.cur.periodLow := math.min(TpoStream.cur.periodLow, low)
            if not na(TpoStream.cur.startTime) and time < TpoStream.cur.startTime + ibMs
                TpoStream.cur.ibHigh := math.max(TpoStream.cur.ibHigh, high)
                TpoStream.cur.ibLow := math.min(TpoStream.cur.ibLow, low)
            int blockIndex = math.max(0, int((time - TpoStream.cur.startTime) / blockMs))
            f_add_bar_to_profile(TpoStream.cur, TpoStream.cur.step, high, low, blockIndex, maxRows)

f_test_naked_pocs(TpoStream TpoStream) =>
    bool touchedNow = false
    if array.size(TpoStream.historyLevels) > 0
        for i = 0 to array.size(TpoStream.historyLevels) - 1
            TpoLevelRec level = array.get(TpoStream.historyLevels, i)
            if not level.tested and not na(level.poc) and low <= level.poc and high >= level.poc
                level.tested := true
                level.testTime := time
                touchedNow := true
    touchedNow

//==============================================================================
// Step calculation and session state
//==============================================================================

float dailyRangeAvg = request.security(syminfo.tickerid, "D", ta.sma(high - low, 5)[1], lookahead = barmerge.lookahead_off)
float dailyAtr = request.security(syminfo.tickerid, "D", ta.atr(atrLengthInput)[1], lookahead = barmerge.lookahead_off)
float referenceRange = not na(dailyRangeAvg) and dailyRangeAvg > 0 ? dailyRangeAvg : (not na(dailyAtr) and dailyAtr > 0 ? dailyAtr : syminfo.mintick * 1000)
float autoStep = math.max(syminfo.mintick, math.round((referenceRange / math.max(10, targetRowsInput)) / syminfo.mintick) * syminfo.mintick)
float stepNow = stepModeInput == "Manual ticks" ? math.max(syminfo.mintick, manualTickStepInput * syminfo.mintick) : autoStep

string londonSessionEffective = f_shift_session(londonSessionInput, dstSummerInput)
string nySessionEffective = f_shift_session(nySessionInput, dstSummerInput)

bool inAsiaRaw = not na(time(timeframe.period, asiaSessionInput, sessionTzInput))
bool inLondonRaw = not na(time(timeframe.period, londonSessionEffective, sessionTzInput))
bool inNyRaw = not na(time(timeframe.period, nySessionEffective, sessionTzInput))
bool inCustomRaw = not na(time(timeframe.period, customSessionInput, customTzInput))

bool inDaily = tfAllowed
bool inAsia = tfAllowed and inAsiaRaw
bool inLondon = tfAllowed and inLondonRaw
bool inNy = tfAllowed and inNyRaw
bool inCustom = tfAllowed and inCustomRaw
bool newExchangeDay = tfAllowed and timeframe.change("D")

//==============================================================================
// Streams
//==============================================================================

var TpoStream dailyStream = f_new_stream(false, compositeColorInput, "Day")
var TpoStream asiaStream = f_new_stream(false, asiaColorInput, "Asia")
var TpoStream londonStream = f_new_stream(false, londonColorInput, "London")
var TpoStream nyStream = f_new_stream(false, nyColorInput, "NY")
var TpoStream customStream = f_new_stream(false, pocColorInput, "Custom")

dailyStream.active := modeDaily or (modeSession and compositeInSessionInput)
asiaStream.active := modeSession and showAsiaInput
londonStream.active := modeSession and showLondonInput
nyStream.active := modeSession and showNyInput
customStream.active := modeCustom

var bool wasDaily = false
var bool wasAsia = false
var bool wasLondon = false
var bool wasNy = false
var bool wasCustom = false

bool previousDaily = wasDaily
bool previousAsia = wasAsia
bool previousLondon = wasLondon
bool previousNy = wasNy
bool previousCustom = wasCustom

bool nakedPocTouched = false

if tfAllowed
    f_update_stream(dailyStream, dailyStream.active and inDaily, previousDaily, newExchangeDay, stepNow, maxRowsInput, valueAreaPctInput, levelMemoryInput, detailProfilesInput)
    f_update_stream(asiaStream, asiaStream.active and inAsia, previousAsia, false, stepNow, maxRowsInput, valueAreaPctInput, levelMemoryInput, detailProfilesInput)
    f_update_stream(londonStream, londonStream.active and inLondon, previousLondon, false, stepNow, maxRowsInput, valueAreaPctInput, levelMemoryInput, detailProfilesInput)
    f_update_stream(nyStream, nyStream.active and inNy, previousNy, false, stepNow, maxRowsInput, valueAreaPctInput, levelMemoryInput, detailProfilesInput)
    f_update_stream(customStream, customStream.active and inCustom, previousCustom, false, stepNow, maxRowsInput, valueAreaPctInput, levelMemoryInput, detailProfilesInput)

    if showNakedPocInput and modeDaily
        nakedPocTouched := f_test_naked_pocs(dailyStream)
    if showNakedPocInput and modeCustom
        nakedPocTouched := f_test_naked_pocs(customStream) or nakedPocTouched

wasDaily := dailyStream.active and inDaily
wasAsia := asiaStream.active and inAsia
wasLondon := londonStream.active and inLondon
wasNy := nyStream.active and inNy
wasCustom := customStream.active and inCustom

//==============================================================================
// Drawing
//==============================================================================

var array<box> boxes = array.new<box>()
var array<line> lines = array.new<line>()
var array<label> labels = array.new<label>()

f_clear_drawings() =>
    if array.size(boxes) > 0
        for i = 0 to array.size(boxes) - 1
            box.delete(array.get(boxes, i))
        array.clear(boxes)
    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))
        array.clear(lines)
    if array.size(labels) > 0
        for i = 0 to array.size(labels) - 1
            label.delete(array.get(labels, i))
        array.clear(labels)

f_can_box() => array.size(boxes) < 492
f_can_line() => array.size(lines) < 492
f_can_label() => array.size(labels) < 492

f_draw_profile_histogram(TpoProfile p, bool isCurrent, color accent, string tag, bool drawBody, bool drawIb, bool drawVaBg, bool drawSinglePrints) =>
    if p.valid and array.size(p.counts) > 0 and not na(p.step) and not na(p.rowBottom)
        f_finalize_profile(p, valueAreaPctInput)
        int rowCount = array.size(p.counts)
        int xStart = p.startBar
        int xEnd = isCurrent ? bar_index : (not na(p.endBar) ? p.endBar : bar_index)
        int xAnchor = xStart + profileOffsetInput
        int xLineRight = extendLevelsInput ? bar_index + 4 : xEnd
        int xLabel = xLineRight + 2
        int visibleRows = math.min(rowCount, renderRowsInput)
        int firstVisible = math.max(0, int(math.floor((rowCount - visibleRows) / 2.0)))
        int lastVisible = math.min(rowCount - 1, firstVisible + visibleRows - 1)

        if drawVaBg and not na(p.vahPrice) and not na(p.valPrice) and f_can_box()
            array.push(boxes, box.new(xStart, p.vahPrice, xEnd, p.valPrice, xloc = xloc.bar_index, bgcolor = color.new(valueAreaBgColorInput, 62), border_color = color.new(valueAreaBgColorInput, 100)))

        if drawBody and rowCount > 0
            for row = firstVisible to lastVisible
                int count = array.get(p.counts, row)
                if count > 0
                    float rowLow = p.rowBottom + row * p.step
                    float rowHigh = rowLow + p.step
                    float rowMid = rowLow + p.step / 2.0
                    bool isPoc = row == p.pocRow
                    bool inValueArea = row >= p.valRow and row <= p.vahRow
                    bool isSinglePrint = count == 1
                    bool inIb = not na(p.ibHigh) and not na(p.ibLow) and rowMid <= p.ibHigh and rowMid >= p.ibLow
                    color rowColor = isPoc ? pocColorInput : isSinglePrint ? singlePrintColorInput : inIb ? ibColorInput : inValueArea ? vaColorInput : tpoColorInput

                    if renderModeInput == "Blocks"
                        if f_can_box()
                            int baseWidth = isCurrent ? blockWidthInput : priorBlockWidthInput
                            int width = math.max(1, int(math.round(baseWidth * count / math.max(1, p.maxCount))))
                            color fillColor = isPoc ? pocColorInput : inValueArea ? accent : tpoColorInput
                            int transparency = isCurrent ? (isPoc ? 18 : inValueArea ? 58 : 82) : (isPoc ? 35 : inValueArea ? 76 : 90)
                            array.push(boxes, box.new(xAnchor, rowHigh, xAnchor + width, rowLow, xloc = xloc.bar_index, bgcolor = color.new(fillColor, transparency), border_color = color.new(color.black, 50), border_width = 1))
                    else if f_can_label()
                        array.push(labels, label.new(xAnchor, rowMid, array.get(p.letters, row), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 100), textcolor = rowColor, size = f_text_size(letterSizeInput)))

                    if drawSinglePrints and isSinglePrint and isCurrent and f_can_line()
                        array.push(lines, line.new(xStart, rowMid, xLineRight, rowMid, xloc = xloc.bar_index, color = color.new(singlePrintColorInput, 60), width = 1, style = line.style_dotted))

        if f_can_line()
            array.push(lines, line.new(xStart, p.pocPrice, xLineRight, p.pocPrice, xloc = xloc.bar_index, color = pocColorInput, width = 2))
        if f_can_line()
            array.push(lines, line.new(xStart, p.vahPrice, xLineRight, p.vahPrice, xloc = xloc.bar_index, color = color.new(vaColorInput, 35), width = 1))
        if f_can_line()
            array.push(lines, line.new(xStart, p.valPrice, xLineRight, p.valPrice, xloc = xloc.bar_index, color = color.new(vaColorInput, 35), width = 1))

        if showLabelsInput and f_can_label()
            array.push(labels, label.new(xLabel, p.pocPrice, tag + " POC " + str.tostring(p.pocPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(accent, 30), textcolor = textColorInput, size = size.small))
            if isCurrent and f_can_label()
                array.push(labels, label.new(xLabel, p.vahPrice, tag + " VAH " + str.tostring(p.vahPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaColorInput, 82), textcolor = textColorInput, size = size.tiny))
            if isCurrent and f_can_label()
                array.push(labels, label.new(xLabel, p.valPrice, tag + " VAL " + str.tostring(p.valPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(vaColorInput, 82), textcolor = textColorInput, size = size.tiny))

        if drawIb and not na(p.ibHigh) and not na(p.ibLow)
            if f_can_line()
                array.push(lines, line.new(xStart, p.ibHigh, xLineRight, p.ibHigh, xloc = xloc.bar_index, color = ibColorInput, width = 1, style = line.style_dashed))
            if f_can_line()
                array.push(lines, line.new(xStart, p.ibLow, xLineRight, p.ibLow, xloc = xloc.bar_index, color = ibColorInput, width = 1, style = line.style_dashed))

        if showOpenInput and isCurrent and not na(p.openPrice) and f_can_label()
            array.push(labels, label.new(xStart, p.openPrice, "O", xloc = xloc.bar_index, style = label.style_label_right, color = color.new(openColorInput, 25), textcolor = color.white, size = size.tiny))

        if showEquilibriumInput and isCurrent
            if p.poorHigh and f_can_label()
                float highHint = p.rowBottom + rowCount * p.step
                array.push(labels, label.new(xStart, highHint, "Poor high", xloc = xloc.bar_index, style = label.style_label_down, color = color.new(singlePrintColorInput, 25), textcolor = textColorInput, size = size.tiny))
            if p.poorLow and f_can_label()
                array.push(labels, label.new(xStart, p.rowBottom, "Poor low", xloc = xloc.bar_index, style = label.style_label_up, color = color.new(singlePrintColorInput, 25), textcolor = textColorInput, size = size.tiny))

f_draw_naked_pocs(TpoStream TpoStream) =>
    if array.size(TpoStream.historyLevels) > 0
        for i = 0 to array.size(TpoStream.historyLevels) - 1
            TpoLevelRec level = array.get(TpoStream.historyLevels, i)
            if not na(level.poc) and not na(level.startTime)
                bool shouldShow = not level.tested or showTestedPocInput
                if shouldShow
                    int endTime = level.tested and not na(level.testTime) ? level.testTime : time
                    color levelColor = level.tested ? color.new(pocColorInput, 78) : color.new(pocColorInput, 0)
                    if f_can_line()
                        array.push(lines, line.new(level.startTime, level.poc, endTime, level.poc, xloc = xloc.bar_time, color = levelColor, width = level.tested ? 1 : 2, style = line.style_solid))
                    if showLabelsInput and not level.tested and f_can_label()
                        array.push(labels, label.new(endTime, level.poc, "Naked POC " + str.tostring(level.poc, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color.new(pocColorInput, 20), textcolor = textColorInput, size = size.tiny))

f_draw_prior_levels(TpoStream TpoStream) =>
    if showPriorLevelsInput and array.size(TpoStream.historyProfiles) > 0
        int firstIndex = math.max(0, array.size(TpoStream.historyProfiles) - priorLevelsLookbackInput)
        for i = firstIndex to array.size(TpoStream.historyProfiles) - 1
            TpoProfile prior = array.get(TpoStream.historyProfiles, i)
            f_finalize_profile(prior, valueAreaPctInput)
            bool mostRecent = i == array.size(TpoStream.historyProfiles) - 1
            int x1 = not na(prior.endBar) ? prior.endBar : bar_index
            int x2 = bar_index + 8
            int fade = mostRecent ? 12 : 72
            if f_can_line()
                array.push(lines, line.new(x1, prior.pocPrice, x2, prior.pocPrice, xloc = xloc.bar_index, color = color.new(pocColorInput, fade), width = mostRecent ? 2 : 1, style = line.style_solid))
            if f_can_line()
                array.push(lines, line.new(x1, prior.vahPrice, x2, prior.vahPrice, xloc = xloc.bar_index, color = color.new(vaColorInput, fade + 10), width = 1, style = line.style_dashed))
            if f_can_line()
                array.push(lines, line.new(x1, prior.valPrice, x2, prior.valPrice, xloc = xloc.bar_index, color = color.new(vaColorInput, fade + 10), width = 1, style = line.style_dashed))
            if showPriorRangeInput and f_can_line()
                array.push(lines, line.new(x1, prior.periodHigh, x2, prior.periodHigh, xloc = xloc.bar_index, color = color.new(singlePrintColorInput, fade + 18), width = 1, style = line.style_dotted))
            if showPriorRangeInput and f_can_line()
                array.push(lines, line.new(x1, prior.periodLow, x2, prior.periodLow, xloc = xloc.bar_index, color = color.new(singlePrintColorInput, fade + 18), width = 1, style = line.style_dotted))
            if mostRecent and showLabelsInput and f_can_label()
                array.push(labels, label.new(x2 + 1, prior.pocPrice, "pPOC " + str.tostring(prior.pocPrice, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(pocColorInput, 15), textcolor = textColorInput, size = size.tiny))
            if mostRecent and showLabelsInput and showPriorRangeInput and f_can_label()
                array.push(labels, label.new(x2 + 1, prior.periodHigh, "PDH " + str.tostring(prior.periodHigh, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(singlePrintColorInput, 25), textcolor = textColorInput, size = size.tiny))
            if mostRecent and showLabelsInput and showPriorRangeInput and f_can_label()
                array.push(labels, label.new(x2 + 1, prior.periodLow, "PDL " + str.tostring(prior.periodLow, format.mintick), xloc = xloc.bar_index, style = label.style_label_left, color = color.new(singlePrintColorInput, 25), textcolor = textColorInput, size = size.tiny))

f_draw_stream(TpoStream TpoStream, bool drawIb, bool drawVaBg, bool drawSinglePrints, bool withHistory) =>
    if TpoStream.active
        if withHistory and array.size(TpoStream.historyProfiles) > 0
            for i = 0 to array.size(TpoStream.historyProfiles) - 1
                bool drawPriorBody = renderModeInput == "Blocks" or lettersOnHistoryInput or visualPresetInput == "Full"
                f_draw_profile_histogram(array.get(TpoStream.historyProfiles, i), false, TpoStream.accent, TpoStream.name, drawPriorBody, false, false, false)
        f_draw_profile_histogram(TpoStream.cur, true, TpoStream.accent, TpoStream.name, true, drawIb, drawVaBg, drawSinglePrints)

if barstate.islast and tfAllowed
    f_clear_drawings()
    bool drawIb = showIbInput and not modeSession
    bool drawVaBg = showValueAreaBgInput and not modeSession
    bool drawSinglePrintsDaily = showSinglePrintsInput
    bool drawSinglePrintsSession = showSessionSinglePrintsInput
    if modeDaily
        if showNakedPocInput
            f_draw_naked_pocs(dailyStream)
        f_draw_prior_levels(dailyStream)
        f_draw_stream(dailyStream, drawIb, drawVaBg, drawSinglePrintsDaily, detailProfilesInput > 1)
    else if modeCustom
        if showNakedPocInput
            f_draw_naked_pocs(customStream)
        f_draw_prior_levels(customStream)
        f_draw_stream(customStream, drawIb, drawVaBg, drawSinglePrintsDaily, detailProfilesInput > 1)
    else if modeSession
        if compositeInSessionInput and dailyStream.active
            f_draw_stream(dailyStream, false, false, false, false)
        f_draw_stream(asiaStream, false, false, drawSinglePrintsSession, false)
        f_draw_stream(londonStream, false, false, drawSinglePrintsSession, false)
        f_draw_stream(nyStream, false, false, drawSinglePrintsSession, false)

//==============================================================================
// Active profile, alerts, and dashboard
//==============================================================================

f_active_profile() =>
    TpoProfile active = dailyStream.cur
    if modeSession
        if inNy and nyStream.cur.valid
            active := nyStream.cur
        else if inLondon and londonStream.cur.valid
            active := londonStream.cur
        else if inAsia and asiaStream.cur.valid
            active := asiaStream.cur
        else if compositeInSessionInput and dailyStream.cur.valid
            active := dailyStream.cur
    else if modeCustom
        active := customStream.cur
    active

TpoProfile activeProfile = f_active_profile()
bool activeValid = tfAllowed and activeProfile.valid and array.size(activeProfile.counts) > 0
if activeValid
    f_finalize_profile(activeProfile, valueAreaPctInput)

bool confirmed = not confirmAlertsInput or barstate.isconfirmed
bool currentPocTouched = activeValid and low <= activeProfile.pocPrice and high >= activeProfile.pocPrice
bool vahBreak = activeValid and close > activeProfile.vahPrice and close[1] <= activeProfile.vahPrice
bool valBreak = activeValid and close < activeProfile.valPrice and close[1] >= activeProfile.valPrice

alertcondition(alertPocTouchInput and confirmed and currentPocTouched, "PRMZN TPO: Current POC touched", "Price touched the active profile POC.")
alertcondition(alertVaBreakInput and confirmed and vahBreak, "PRMZN TPO: VAH break", "Price closed above active profile VAH.")
alertcondition(alertVaBreakInput and confirmed and valBreak, "PRMZN TPO: VAL break", "Price closed below active profile VAL.")
alertcondition(alertNakedPocTouchInput and confirmed and nakedPocTouched, "PRMZN TPO: Naked POC touched", "Price touched a stored naked POC.")

var table dashboard = table.new(f_table_pos(dashboardPosInput), 2, 10, border_width = 1)

if barstate.islast and showDashboardInput
    color headerBg = color.new(color.black, 0)
    color keyBg = color.new(color.black, 65)
    color valueBg = color.new(color.black, 78)
    table.cell(dashboard, 0, 0, "Market Context", text_color = textColorInput, bgcolor = headerBg, text_size = size.small)
    table.cell(dashboard, 1, 0, modeDaily ? "Daily Pro" : modeSession ? "Sessions" : "Custom", text_color = textColorInput, bgcolor = headerBg, text_size = size.small)
    if not tfAllowed
        table.cell(dashboard, 0, 1, "Timeframe", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 1, "M30 or lower", text_color = color.new(color.red, 0), bgcolor = valueBg, text_size = size.tiny)
    else if not activeValid
        table.cell(dashboard, 0, 1, "Status", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 1, "Building", text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
    else
        int singlePrintCount = 0
        for row = 0 to array.size(activeProfile.counts) - 1
            if array.get(activeProfile.counts, row) == 1
                singlePrintCount += 1
        string shapeText = f_profile_shape(activeProfile)
        string healthText = activeProfile.capped ? "Row cap hit" : array.size(activeProfile.counts) > renderRowsInput ? "Render capped" : "OK"
        TpoProfile priorForContext = modeCustom ? f_last_profile(customStream) : f_last_profile(dailyStream)
        string openLocation = f_open_location(activeProfile, priorForContext)
        string valueStatus = f_value_status(activeProfile)
        string ibExtension = f_ib_extension(activeProfile)
        float dayRange = not na(activeProfile.periodHigh) and not na(activeProfile.periodLow) ? activeProfile.periodHigh - activeProfile.periodLow : na
        string valueRangeText = str.tostring(activeProfile.valPrice, format.mintick) + " - " + str.tostring(activeProfile.vahPrice, format.mintick)
        table.cell(dashboard, 0, 1, "Open Location", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 1, openLocation, text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 2, "Value Status", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 2, valueStatus, text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 3, "POC", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 3, str.tostring(activeProfile.pocPrice, format.mintick), text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 4, "Value Area", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 4, valueRangeText, text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 5, "IB Extension", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 5, ibExtension, text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 6, "Profile Type", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 6, shapeText, text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 7, "Range", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 7, str.tostring(dayRange, format.mintick), text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 8, "Single prints", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 8, str.tostring(singlePrintCount), text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
        table.cell(dashboard, 0, 9, showHealthInput ? "Health" : "Rows", text_color = textColorInput, bgcolor = keyBg, text_size = size.tiny)
        table.cell(dashboard, 1, 9, showHealthInput ? healthText : str.tostring(array.size(activeProfile.counts)), text_color = textColorInput, bgcolor = valueBg, text_size = size.tiny)
````
