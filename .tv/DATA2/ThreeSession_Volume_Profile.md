<!-- tradingview-pine-id: PUB;00c7118da10849dbae702598af568f58 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Three-Session Volume Profile

Source: https://www.tradingview.com/script/CDfsfyDO-Three-Session-Volume-Profile/

## Description

Overview
Three-Session Volume Profile divides intraday trading into three independently configurable sessions: Asia, London, and New York. Instead of combining the entire trading day into one profile, the indicator resets its calculations at the beginning of each session and displays a separate Volume Profile, Point of Control, Value Area, VWAP, and optional deviation bands for each period.

This structure is intended for traders who analyze how price and volume distribution change as market participation moves between global trading sessions. Each session is treated as its own auction, making it possible to compare where volume was accepted during one session with how price behaves during the next.

The default schedules use the America/New_York time zone:

Asia: 18:00–03:00
London: 03:00–09:30
New York: 09:30–16:00
All schedules and the time zone are configurable. The America/New_York setting automatically accounts for daylight-saving changes.

Why the components are combined
The Volume Profile, session VWAP, and deviation bands are not calculated as unrelated indicators. They all use the same independently resetting session windows.

The Volume Profile describes how the session’s volume was distributed across price. VWAP provides the session’s volume-weighted mean price, while the deviation bands describe dispersion around that mean. Together, they provide two complementary views of the same session:

Volume Profile identifies price areas with relatively high or low participation.
POC identifies the profile row containing the most allocated volume.
VAH and VAL define the boundaries of the selected value area.
VWAP represents the session’s volume-weighted average price.
Deviation bands provide context for how far price is trading from the session’s weighted mean.
The purpose of this combination is to provide a consistent session-based framework rather than merge unrelated studies.

Volume Profile calculation
For each active session, the indicator tracks the session high, low, and volume. The complete session range is divided into a configurable number of equally sized price rows.

Because standard chart data does not provide the exact price of every transaction, each chart bar’s volume is allocated across the profile rows intersected by that bar’s high-low range. The allocation is proportional to the amount of the bar’s range overlapping each row. A bar with no measurable range has its volume assigned to the row containing its representative price.

The profile is recalculated when the session’s price range expands. This keeps the rows distributed across the complete developing session range.

The Rows setting controls profile resolution and supports values from 12 to 200. More rows provide finer price segmentation but also increase calculation requirements. The profile is based on chart bars rather than tick-by-tick or lower-timeframe transaction data, so changing the chart timeframe can change the resulting distribution.

POC and Value Area calculation
The Point of Control, or POC, is the midpoint of the profile row containing the greatest allocated volume.

The Value Area begins at the POC row. The calculation then compares the next available row above and below the current Value Area and adds the side containing more volume. This process continues until the selected percentage of total session volume has been included.

The resulting levels are:

VAH: Upper boundary of the Value Area
VAL: Lower boundary of the Value Area
POC: Midpoint of the highest-volume profile row
The default Value Area contains 70% of session volume, but this percentage can be adjusted.

Developing and completed levels
While a session is active, the developing VAH, VAL, and POC can be displayed. These levels update as new price and volume information enters the session.

When the session ends, the final profile and levels are stored as completed session values. The number of completed profiles retained for each session can be controlled from the settings.

Developing values are expected to move. A new session high or low changes the profile range and can cause all rows to be redistributed. Completed levels remain fixed unless the chart data, timeframe, symbol, session schedule, or indicator settings are changed.

Session VWAP and deviation bands
The optional VWAP calculation resets independently at the beginning of each session. It uses HLC3 as the representative bar price and weights it by volume.

The session VWAP is calculated as:

Volume-weighted price sum ÷ Session volume sum

The standard deviation calculation is also volume-weighted. The selected multiplier is applied above and below VWAP to produce the upper and lower bands.

These bands are descriptive measurements of session dispersion. They are not automatic overbought or oversold signals.

Profile placement
Each profile can be positioned on either side of its own session:

Left: Anchors the profile to the session opening edge and extends it to the right.
Right: Anchors the profile to the session closing or current edge and extends it to the left.
This setting refers to the boundaries of each session, not the far-left or far-right edge of the visible chart.

The Maximum width setting controls the profile’s horizontal display width in chart bars. It changes only the visual width and does not affect the underlying volume calculations.

How to use the indicator
1. Configure the time zone
Select the time zone used to interpret all three schedules. America/New_York is suitable when session times should follow Eastern Time and adjust automatically for daylight saving.

Use a fixed UTC offset only when daylight-saving adjustment is not desired.

2. Configure the sessions
Set the opening and closing time for Asia, London, and New York. Overnight schedules, such as 18:00–03:00, are supported.

The sessions may overlap if desired. When they overlap, each session continues to calculate independently.

3. Select profile resolution
Increase the number of rows for more detailed price segmentation. Lower values produce broader profile levels and require fewer calculations.

Profile precision also depends on the chart timeframe. Lower chart timeframes generally provide more granular source bars, while higher timeframes provide a broader approximation.

4. Select the Value Area percentage
The standard default is 70%. Increasing the percentage produces a wider Value Area, while reducing it produces a narrower area around the POC.

5. Choose completed or developing levels
Developing levels can be used to observe how the current session’s distribution changes. Completed levels provide fixed references from prior sessions.

Traders may examine whether price:

Accepts or rejects a previous session’s Value Area
Rotates around a prior POC
Moves from one session’s value region toward another
Holds above or below a prior VAH or VAL
Trades near or away from the active session VWAP
These are contextual observations rather than predefined entry or exit signals.

6. Enable VWAP and deviation bands if needed
VWAP can provide a session-weighted reference price alongside the distribution-based profile. Deviation bands can be enabled to visualize dispersion around that reference.

Interpretation
A wide section of the profile represents a row receiving relatively more allocated volume. A narrow section represents relatively less allocated volume.

POC and Value Area levels identify areas of historical participation, but they do not guarantee future support or resistance. Their interpretation depends on market structure, volatility, liquidity, instrument type, and the trader’s broader methodology.

On centralized futures markets, the script uses the exchange-reported volume available on the chart. On markets where only tick volume is available, the profile reflects that data instead of centralized transaction volume.

Recalculation and limitations
The indicator does not request future data or use lookahead calculations. Completed sessions are based only on bars belonging to those sessions.

Developing profiles and levels update during the active bar as its high, low, and volume change. This is normal real-time recalculation and should not be interpreted as a fixed signal.

The profile is an approximation created from chart-bar ranges and volume. It is not a tick-level bid/ask profile, footprint chart, or reconstruction of individual transactions. Results can differ from volume-profile tools that use lower-timeframe or transaction-level data.

This indicator is an analytical tool and does not provide trade entries, exits, profit projections, or guarantees of future performance.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Tradedailywithseb

//@version=6
indicator("Three-Session Volume Profile", "3S VP", overlay = true, max_lines_count = 500, max_polylines_count = 100, calc_bars_count = 20000)

// --- Constants ---
const string SESSIONS_GROUP = "Sessions"
const string PROFILE_GROUP = "Volume Profile"
const string LEVELS_GROUP = "Levels"
const string VWAP_GROUP = "VWAP & Deviation Bands"
const string STYLE_GROUP = "Style"
const string TIMEZONE_TOOLTIP = "IANA time zone used to interpret all three session schedules. America/New_York follows Eastern Standard Time and automatically adjusts for daylight saving time."
const string SESSION_TOOLTIP = "Trading session in HHMM-HHMM format. Overnight sessions are supported."
const string ROWS_TOOLTIP = "Number of price rows used by each session profile. Higher values provide more price detail but require more calculations."
const string WIDTH_TOOLTIP = "Maximum histogram width in chart bars. Each row is scaled relative to the session's highest-volume row."
const string HISTORY_TOOLTIP = "Number of completed profiles retained for each of the three sessions."
const string VALUE_AREA_TOOLTIP = "Percentage of session volume included in the value area around the point of control."
const string DEVELOPING_TOOLTIP = "Shows horizontal VAH, VAL, and POC lines while a session is still developing."
const string VWAP_TOOLTIP = "Shows a separately anchored VWAP for every active session, with historical segments retained."
const string DEVIATION_TOOLTIP = "Multiplier applied to the session's volume-weighted standard deviation."

// --- Inputs ---
timezoneInput = input.string("America/New_York", "Session time zone", tooltip = TIMEZONE_TOOLTIP, group = SESSIONS_GROUP)
asiaSessionInput = input.session("1800-0300", "Asia", tooltip = SESSION_TOOLTIP, group = SESSIONS_GROUP)
londonSessionInput = input.session("0300-0930", "London", tooltip = SESSION_TOOLTIP, group = SESSIONS_GROUP)
newYorkSessionInput = input.session("0930-1600", "New York", tooltip = SESSION_TOOLTIP, group = SESSIONS_GROUP)

showProfilesInput = input.bool(true, "Show volume profiles", tooltip = "Displays a separate horizontal volume histogram for each session.", group = PROFILE_GROUP)
rowCountInput = input.int(24, "Rows", minval = 12, maxval = 200, tooltip = ROWS_TOOLTIP, group = PROFILE_GROUP)
profileWidthInput = input.int(24, "Maximum width", minval = 4, maxval = 60, tooltip = WIDTH_TOOLTIP, group = PROFILE_GROUP)
profilePlacementInput = input.string("Right", "Profile placement", options = ["Left", "Right"], tooltip = "Anchors each histogram to the left or right edge of its session.", group = PROFILE_GROUP)
profilesToKeepInput = input.int(4, "Completed profiles per session", minval = 1, maxval = 4, tooltip = HISTORY_TOOLTIP, group = PROFILE_GROUP)
valueAreaPercentInput = input.float(70.0, "Value area volume %", minval = 1.0, maxval = 100.0, step = 1.0, tooltip = VALUE_AREA_TOOLTIP, group = PROFILE_GROUP)

showCompletedLevelsInput = input.bool(true, "Show completed VAH, VAL, and POC", tooltip = "Keeps the final value-area and point-of-control levels across each completed session.", group = LEVELS_GROUP)
showDevelopingLevelsInput = input.bool(true, "Show developing VAH, VAL, and POC", tooltip = DEVELOPING_TOOLTIP, group = LEVELS_GROUP)

showVwapInput = input.bool(false, "Show session VWAP", tooltip = VWAP_TOOLTIP, group = VWAP_GROUP)
showDeviationBandsInput = input.bool(false, "Show standard deviation bands", tooltip = "Shows upper and lower volume-weighted deviation bands around each session VWAP.", group = VWAP_GROUP)
deviationMultiplierInput = input.float(1.0, "Deviation multiplier", minval = 0.1, step = 0.1, tooltip = DEVIATION_TOOLTIP, group = VWAP_GROUP)

asiaColorInput = input.color(#5b9cf6, "Asia", tooltip = "Color used for the Asia profile and levels.", inline = "sessionColors", group = STYLE_GROUP)
londonColorInput = input.color(#ff9800, "London", tooltip = "Color used for the London profile and levels.", inline = "sessionColors", group = STYLE_GROUP)
newYorkColorInput = input.color(#089981, "New York", tooltip = "Color used for the New York profile and levels.", inline = "sessionColors", group = STYLE_GROUP)

// --- Types ---
type SessionState
    array<float> highs
    array<float> lows
    array<float> prices
    array<float> volumes
    array<float> bins
    array<polyline> historicalProfiles
    array<line> historicalLines
    bool isActive
    int startBar
    float profileLow
    float profileHigh
    float rowSize
    float volumeSum
    float priceVolumeSum
    float priceSquaredVolumeSum
    line developingPoc
    line developingVah
    line developingVal
    polyline developingProfile
    polyline developingValueArea

type ProfileData
    array<float> bins
    float lowPrice
    float rowSize
    int pocIndex
    int vaLowIndex
    int vaHighIndex
    float maxVolume
    float poc
    float vah
    float val

// --- Utility Functions ---
newSessionState() =>
    SessionState.new(
      array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(),
      array.new<polyline>(), array.new<line>(), false, na, na, na, na, 0.0, 0.0, 0.0,
      na, na, na, na, na)

deleteDevelopingProfile(SessionState state) =>
    if not na(state.developingProfile)
        polyline.delete(state.developingProfile)
        state.developingProfile := na
    if not na(state.developingValueArea)
        polyline.delete(state.developingValueArea)
        state.developingValueArea := na

deleteDevelopingLines(SessionState state) =>
    if not na(state.developingPoc)
        line.delete(state.developingPoc)
        state.developingPoc := na
    if not na(state.developingVah)
        line.delete(state.developingVah)
        state.developingVah := na
    if not na(state.developingVal)
        line.delete(state.developingVal)
        state.developingVal := na

resetSession(SessionState state) =>
    array.clear(state.highs)
    array.clear(state.lows)
    array.clear(state.prices)
    array.clear(state.volumes)
    array.clear(state.bins)
    state.startBar := bar_index
    state.profileLow := na
    state.profileHigh := na
    state.rowSize := na
    state.volumeSum := 0.0
    state.priceVolumeSum := 0.0
    state.priceSquaredVolumeSum := 0.0

distributeVolume(SessionState state, float barHigh, float barLow, float barPrice, float barVolume) =>
    int rows = array.size(state.bins)
    float safeVolume = nz(barVolume)
    float barRange = barHigh - barLow
    if rows > 0 and safeVolume > 0
        if barRange <= syminfo.mintick * 0.1
            int rowIndex = int(math.floor((barPrice - state.profileLow) / state.rowSize))
            rowIndex := math.max(0, math.min(rows - 1, rowIndex))
            array.set(state.bins, rowIndex, array.get(state.bins, rowIndex) + safeVolume)
        else
            int firstRow = int(math.floor((barLow - state.profileLow) / state.rowSize))
            int lastRow = int(math.floor((barHigh - state.profileLow) / state.rowSize))
            firstRow := math.max(0, math.min(rows - 1, firstRow))
            lastRow := math.max(0, math.min(rows - 1, lastRow))
            for rowIndex = firstRow to lastRow
                float rowBottom = state.profileLow + rowIndex * state.rowSize
                float rowTop = rowBottom + state.rowSize
                float overlap = math.max(0.0, math.min(barHigh, rowTop) - math.max(barLow, rowBottom))
                float allocatedVolume = safeVolume * overlap / barRange
                array.set(state.bins, rowIndex, array.get(state.bins, rowIndex) + allocatedVolume)

rebuildProfile(SessionState state, int rows) =>
    float observedLow = array.min(state.lows)
    float observedHigh = array.max(state.highs)
    float minimumSpan = syminfo.mintick * rows
    float span = math.max(observedHigh - observedLow, minimumSpan)
    float midpoint = (observedHigh + observedLow) * 0.5
    state.profileLow := midpoint - span * 0.5
    state.profileHigh := midpoint + span * 0.5
    state.rowSize := span / rows
    array.clear(state.bins)
    for rowIndex = 0 to rows - 1
        array.push(state.bins, 0.0)
    int sampleCount = array.size(state.highs)
    if sampleCount > 0
        for sampleIndex = 0 to sampleCount - 1
            distributeVolume(
              state,
              array.get(state.highs, sampleIndex),
              array.get(state.lows, sampleIndex),
              array.get(state.prices, sampleIndex),
              array.get(state.volumes, sampleIndex))

updateProfile(SessionState state, int rows, float barHigh, float barLow, float barPrice, float barVolume) =>
    bool needsRebuild = array.size(state.bins) != rows or na(state.profileLow) or barLow < state.profileLow or barHigh > state.profileHigh
    if needsRebuild
        rebuildProfile(state, rows)
    else
        distributeVolume(state, barHigh, barLow, barPrice, barVolume)

getProfileData(SessionState state, float valueAreaFraction) =>
    int rows = array.size(state.bins)
    float maxVolume = 0.0
    int pocIndex = 0
    float totalVolume = 0.0
    if rows > 0
        for rowIndex = 0 to rows - 1
            float rowVolume = array.get(state.bins, rowIndex)
            totalVolume += rowVolume
            if rowVolume > maxVolume
                maxVolume := rowVolume
                pocIndex := rowIndex
    int vaLowIndex = pocIndex
    int vaHighIndex = pocIndex
    float includedVolume = rows > 0 ? array.get(state.bins, pocIndex) : 0.0
    float targetVolume = totalVolume * valueAreaFraction
    if rows > 0
        while includedVolume < targetVolume and (vaLowIndex > 0 or vaHighIndex < rows - 1)
            float lowerVolume = vaLowIndex > 0 ? array.get(state.bins, vaLowIndex - 1) : -1.0
            float upperVolume = vaHighIndex < rows - 1 ? array.get(state.bins, vaHighIndex + 1) : -1.0
            if upperVolume >= lowerVolume and vaHighIndex < rows - 1
                vaHighIndex += 1
                includedVolume += math.max(upperVolume, 0.0)
            else if vaLowIndex > 0
                vaLowIndex -= 1
                includedVolume += math.max(lowerVolume, 0.0)
    float poc = state.profileLow + (pocIndex + 0.5) * state.rowSize
    float vah = state.profileLow + (vaHighIndex + 1.0) * state.rowSize
    float val = state.profileLow + vaLowIndex * state.rowSize
    ProfileData.new(state.bins, state.profileLow, state.rowSize, pocIndex, vaLowIndex, vaHighIndex, maxVolume, poc, vah, val)

getProfilePoints(ProfileData profile, int anchorBar, int maximumWidth, bool placeLeft, int firstRow, int lastRow) =>
    array<chart.point> points = array.new<chart.point>()
    float profileBottom = profile.lowPrice + firstRow * profile.rowSize
    float profileTop = profile.lowPrice + (lastRow + 1) * profile.rowSize
    array.push(points, chart.point.from_index(anchorBar, profileBottom))
    for rowIndex = firstRow to lastRow
        float rowVolume = array.get(profile.bins, rowIndex)
        int scaledWidth = profile.maxVolume > 0 ? math.max(1, int(math.round(maximumWidth * rowVolume / profile.maxVolume))) : 1
        int outerBar = placeLeft ? anchorBar + scaledWidth : anchorBar - scaledWidth
        float rowBottom = profile.lowPrice + rowIndex * profile.rowSize
        float rowTop = rowBottom + profile.rowSize
        array.push(points, chart.point.from_index(outerBar, rowBottom))
        array.push(points, chart.point.from_index(outerBar, rowTop))
    array.push(points, chart.point.from_index(anchorBar, profileTop))
    points

trimHistoricalObjects(SessionState state, int profilesToKeep) =>
    int maximumProfiles = 2 * profilesToKeep
    int maximumLines = 3 * profilesToKeep
    while array.size(state.historicalProfiles) > maximumProfiles
        polyline.delete(array.shift(state.historicalProfiles))
    while array.size(state.historicalLines) > maximumLines
        line.delete(array.shift(state.historicalLines))

updateDevelopingProfile(SessionState state, ProfileData profile, color sessionColor, int maximumWidth, bool showProfile) =>
    deleteDevelopingProfile(state)
    if showProfile
        int availableWidth = math.max(1, math.min(maximumWidth, bar_index - state.startBar + 1))
        bool placeLeft = profilePlacementInput == "Left"
        int anchorBar = placeLeft ? state.startBar : bar_index + 1
        array<chart.point> profilePoints = getProfilePoints(profile, anchorBar, availableWidth, placeLeft, 0, array.size(profile.bins) - 1)
        array<chart.point> valueAreaPoints = getProfilePoints(profile, anchorBar, availableWidth, placeLeft, profile.vaLowIndex, profile.vaHighIndex)
        state.developingProfile := polyline.new(profilePoints, false, true, xloc.bar_index, color.new(sessionColor, 60), color.new(sessionColor, 84), line.style_solid, 1)
        state.developingValueArea := polyline.new(valueAreaPoints, false, true, xloc.bar_index, color.new(sessionColor, 35), color.new(sessionColor, 62), line.style_solid, 1)

createHistoricalProfile(SessionState state, ProfileData profile, color sessionColor, int endBar, int maximumWidth, bool showProfile) =>
    if showProfile
        int availableWidth = math.max(1, math.min(maximumWidth, endBar - state.startBar + 1))
        bool placeLeft = profilePlacementInput == "Left"
        int anchorBar = placeLeft ? state.startBar : endBar + 1
        array<chart.point> profilePoints = getProfilePoints(profile, anchorBar, availableWidth, placeLeft, 0, array.size(profile.bins) - 1)
        array<chart.point> valueAreaPoints = getProfilePoints(profile, anchorBar, availableWidth, placeLeft, profile.vaLowIndex, profile.vaHighIndex)
        polyline profileId = polyline.new(profilePoints, false, true, xloc.bar_index, color.new(sessionColor, 60), color.new(sessionColor, 84), line.style_solid, 1)
        polyline valueAreaId = polyline.new(valueAreaPoints, false, true, xloc.bar_index, color.new(sessionColor, 35), color.new(sessionColor, 62), line.style_solid, 1)
        array.push(state.historicalProfiles, profileId)
        array.push(state.historicalProfiles, valueAreaId)

createHistoricalLevels(SessionState state, ProfileData profile, color sessionColor, int endBar, bool showLevels) =>
    if showLevels
        line pocLine = line.new(state.startBar, profile.poc, endBar + 1, profile.poc, color = sessionColor, width = 2)
        line vahLine = line.new(state.startBar, profile.vah, endBar + 1, profile.vah, color = color.new(sessionColor, 20), style = line.style_dashed)
        line valLine = line.new(state.startBar, profile.val, endBar + 1, profile.val, color = color.new(sessionColor, 20), style = line.style_dashed)
        array.push(state.historicalLines, pocLine)
        array.push(state.historicalLines, vahLine)
        array.push(state.historicalLines, valLine)

updateDevelopingLevels(SessionState state, ProfileData profile, color sessionColor, bool showLevels) =>
    if not showLevels
        deleteDevelopingLines(state)
    else
        if na(state.developingPoc)
            state.developingPoc := line.new(state.startBar, profile.poc, bar_index + 1, profile.poc, color = sessionColor, width = 2)
            state.developingVah := line.new(state.startBar, profile.vah, bar_index + 1, profile.vah, color = color.new(sessionColor, 20), style = line.style_dashed)
            state.developingVal := line.new(state.startBar, profile.val, bar_index + 1, profile.val, color = color.new(sessionColor, 20), style = line.style_dashed)
        line.set_xy1(state.developingPoc, state.startBar, profile.poc)
        line.set_xy2(state.developingPoc, bar_index + 1, profile.poc)
        line.set_xy1(state.developingVah, state.startBar, profile.vah)
        line.set_xy2(state.developingVah, bar_index + 1, profile.vah)
        line.set_xy1(state.developingVal, state.startBar, profile.val)
        line.set_xy2(state.developingVal, bar_index + 1, profile.val)
    0

processSession(SessionState state, bool inSession, color sessionColor) =>
    float sessionVwap = na
    float upperBand = na
    float lowerBand = na
    if inSession
        if not state.isActive
            resetSession(state)
            state.isActive := true
        float barPrice = hlc3
        float barVolume = nz(volume)
        array.push(state.highs, high)
        array.push(state.lows, low)
        array.push(state.prices, barPrice)
        array.push(state.volumes, barVolume)
        state.volumeSum += barVolume
        state.priceVolumeSum += barPrice * barVolume
        state.priceSquaredVolumeSum += barPrice * barPrice * barVolume
        updateProfile(state, rowCountInput, high, low, barPrice, barVolume)
        ProfileData profile = getProfileData(state, valueAreaPercentInput * 0.01)
        if barstate.islast
            updateDevelopingProfile(state, profile, sessionColor, profileWidthInput, showProfilesInput)
        updateDevelopingLevels(state, profile, sessionColor, showDevelopingLevelsInput)
        if state.volumeSum > 0
            sessionVwap := state.priceVolumeSum / state.volumeSum
            float variance = math.max(state.priceSquaredVolumeSum / state.volumeSum - sessionVwap * sessionVwap, 0.0)
            float deviation = math.sqrt(variance) * deviationMultiplierInput
            upperBand := sessionVwap + deviation
            lowerBand := sessionVwap - deviation
    else if state.isActive
        ProfileData profile = getProfileData(state, valueAreaPercentInput * 0.01)
        deleteDevelopingProfile(state)
        deleteDevelopingLines(state)
        createHistoricalProfile(state, profile, sessionColor, bar_index - 1, profileWidthInput, showProfilesInput)
        createHistoricalLevels(state, profile, sessionColor, bar_index - 1, showCompletedLevelsInput)
        trimHistoricalObjects(state, profilesToKeepInput)
        state.isActive := false
        array.clear(state.highs)
        array.clear(state.lows)
        array.clear(state.prices)
        array.clear(state.volumes)
        array.clear(state.bins)
    [sessionVwap, upperBand, lowerBand]

// --- Core Logic ---
var SessionState asiaState = newSessionState()
var SessionState londonState = newSessionState()
var SessionState newYorkState = newSessionState()

bool inAsiaSession = not na(time(timeframe.period, asiaSessionInput, timezoneInput))
bool inLondonSession = not na(time(timeframe.period, londonSessionInput, timezoneInput))
bool inNewYorkSession = not na(time(timeframe.period, newYorkSessionInput, timezoneInput))

[asiaVwap, asiaUpperBand, asiaLowerBand] = processSession(asiaState, inAsiaSession, asiaColorInput)
[londonVwap, londonUpperBand, londonLowerBand] = processSession(londonState, inLondonSession, londonColorInput)
[newYorkVwap, newYorkUpperBand, newYorkLowerBand] = processSession(newYorkState, inNewYorkSession, newYorkColorInput)

// --- Visual Elements ---
asiaVwapPlot = plot(showVwapInput ? asiaVwap : na, "Asia VWAP", color = asiaColorInput, linewidth = 2, style = plot.style_linebr)
asiaUpperPlot = plot(showDeviationBandsInput ? asiaUpperBand : na, "Asia upper deviation", color = color.new(asiaColorInput, 25), style = plot.style_linebr)
asiaLowerPlot = plot(showDeviationBandsInput ? asiaLowerBand : na, "Asia lower deviation", color = color.new(asiaColorInput, 25), style = plot.style_linebr)
fill(asiaUpperPlot, asiaLowerPlot, color = showDeviationBandsInput ? color.new(asiaColorInput, 92) : na, title = "Asia deviation fill")

londonVwapPlot = plot(showVwapInput ? londonVwap : na, "London VWAP", color = londonColorInput, linewidth = 2, style = plot.style_linebr)
londonUpperPlot = plot(showDeviationBandsInput ? londonUpperBand : na, "London upper deviation", color = color.new(londonColorInput, 25), style = plot.style_linebr)
londonLowerPlot = plot(showDeviationBandsInput ? londonLowerBand : na, "London lower deviation", color = color.new(londonColorInput, 25), style = plot.style_linebr)
fill(londonUpperPlot, londonLowerPlot, color = showDeviationBandsInput ? color.new(londonColorInput, 92) : na, title = "London deviation fill")

newYorkVwapPlot = plot(showVwapInput ? newYorkVwap : na, "New York VWAP", color = newYorkColorInput, linewidth = 2, style = plot.style_linebr)
newYorkUpperPlot = plot(showDeviationBandsInput ? newYorkUpperBand : na, "New York upper deviation", color = color.new(newYorkColorInput, 25), style = plot.style_linebr)
newYorkLowerPlot = plot(showDeviationBandsInput ? newYorkLowerBand : na, "New York lower deviation", color = color.new(newYorkColorInput, 25), style = plot.style_linebr)
fill(newYorkUpperPlot, newYorkLowerPlot, color = showDeviationBandsInput ? color.new(newYorkColorInput, 92) : na, title = "New York deviation fill")
````
