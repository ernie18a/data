# Session Auction & Volume Profiles [AxeAlgo]

- url: https://www.tradingview.com/script/hnSxpXHt-Session-Auction-Volume-Profiles-AxeAlgo/
- type: indicator
- pine_id: PUB;c62f119b2a164ca988b16ea8c95122d6
- version: 1.0

## Description

Session Auction & Volume Profiles [AxeAlgo] is a multi-session volume profiling and Auction Market Theory (AMT) analytical tool built for intraday and swing traders across all liquid markets, including Crypto, Forex, Indices, and Commodities.

The script segments the trading day into major global auction blocks (Asia, London, and New York) and computes the true distribution of traded volume at each price level. By identifying where the market established equilibrium (acceptance) versus where it rejected prices (excess), the indicator provides objective structural benchmarks based on foundational market profile concepts pioneered by J. Peter Steidlmayer and James Dalton.


[b]UNDERLYING METHODOLOGY & AUCTION THEORY[/b]

Financial markets are continuous double-auction mechanisms whose primary objective is to facilitate trade. Price is an advertising mechanism that moves to find volume, and volume represents the validation of price.

[b]1. Value Area (70% Rule): [/b]
The Value Area identifies the price range where approximately 70% of the session's volume traded (one standard deviation of normal volume distribution). Prices accepted inside this band represent fair value where two-way trade facilitation occurs smoothly.

[b]2. Point of Control (POC): [/b]
The Point of Control marks the single price bin with the highest accumulated traded volume during the session. It acts as the market's primary equilibrium node and frequently serves as a gravitational benchmark or support/resistance level in subsequent auctions.

[b]3. Developing Point of Control (dPOC): [/b]
A live tracking path showing where the peak volume is actively migrating during the active trading session. A developing POC shifting higher indicates progressive buying acceptance, while a developing POC migrating lower indicates aggressive selling acceptance.

[b]4. Session Initial Balance (IB): [/b]
Defined as the high, low, and 50% midpoint established during the first 60 minutes of a session. In Auction Market Theory, the Initial Balance sets the baseline range of the session. Breakouts beyond this range reflect initiative market activity (Trend Days), while containment inside reflects responsive, rotational activity (Range Days).

[b]5. Virgin Naked POC (vPOC) Magnet Tracking: [/b]
A Virgin POC is a Point of Control that has never been retested by future price action. Because institutional traders treat untested volume peaks as unfinished liquidity references, these levels serve as strong forward reference magnets until price mitigates them.

[b]6. Prior Session Corridor: [/b]
Projects the previous session's Value Area High (pVAH), Value Area Low (pVAL), and Point of Control (pPOC) forward into the active trading day. This gives traders an immediate benchmark for evaluating value migration (higher value, lower value, or overlapping value).


[b]KEY FEATURES[/b]

[b]1. Independent Multi-Session Architecture[/b]
Supports dedicated schedules and custom color schemes for Asia (Tokyo), London, and New York. Each session is calculated independently using retrospective candle arrays, ensuring mathematical precision even across session changeovers and time zone differences.

[b]2. Full-Span Volume Profile Histogram[/b]
Renders a horizontal price-volume distribution directly on the completed session. Uses two-tone volume delta shading (gold for net buying volume, red for net selling volume), a highlighted solid gold Point of Control bar, and soft visible tail bins outside the Value Area so the full volume bell curve is visible without missing bars.

[b]3. Shaded Value Area Canvas[/b]
Draws a subtle, non-intrusive shaded zone across the 70% Value Area corridor with dashed boundary lines marking Value Area High and Value Area Low. Historical session text is disabled by default to keep chart candles clean and unobstructed.

[b]4. Non-Colliding Dynamic Labels[/b]
All right-axis price benchmarks (dPOC, Initial Balance, and Prior Session Corridor) are staggered at distinct forward offsets, encased in clean dark canvas tags to eliminate text overlapping and label clutter.

[b]5. Quantitative Session Status Mini-HUD[/b]
An uncluttered heads-up display anchored to the top-right corner of the chart, reporting:
- Active Session State (Asia, London, New York, or Inter-Session)
- 70% Value Area Range (Current corridor boundaries)
- Initial Balance Status (Active 60-minute countdown, Range Coiling, or Breakout Direction)
- Key Reference Level (Active POC or dPOC benchmark)
- Untested Virgin POC Count (Number of active forward magnets)

[b]6. Built-in Alert Conditions[/b]
Includes standard alerts for Session Openings, Session Completion and Profile Fixation, and Initial Balance Bullish/Bearish range breakouts.


[b]HOW TO USE THIS INDICATOR[/b]

- Rotational Trading (Inside Value):
When price opens or rotates inside the prior session's Value Area, the market is balanced. Traders typically look for responsive setups, fading session extremes back toward the Point of Control.

- Initiative Breakout Trading (Outside Value):
When price breaks out and accepts above the prior Value Area High or below the Value Area Low with sustained volume, it indicates directional conviction. Traders look for trend continuation retests of the broken Value Area boundary.

- Initial Balance Expansion:
If price expands beyond the first 60-minute Initial Balance high or low, it signals initiative participation. The 50% Initial Balance midpoint (Half-Back) frequently serves as dynamic support or resistance during trend pullbacks.

- Virgin POC Magnet Targets:
Untested forward rays represent historical liquidity pools. When price approaches an unmitigated vPOC line, monitor for sharp reactions or liquidity sweeps. Once touched, the ray automatically erases to keep your chart uncluttered.


[b]INPUT CONFIGURATION GUIDE[/b]

- Session Configuration: Toggle individual sessions on or off and set custom time windows (defaulted to UTC).
- Value Area Volume %: Set the statistical Value Area width (default 70%).
- Volume Profile Price Bins: Adjust the granularity of horizontal profile rows (16 to 64 bins, default 32).
- Volume Profile Scope: Display the most recent completed profile or show profiles across all active sessions.
- Outside Value Area Bars: Choose between Soft Two-Tone Delta, Muted Institutional Slate, or Full Saturation for profile bins outside the 70% Value Area.
- Initial Balance (IB 60m): Enable or disable the first-hour bracket and select between Compact Tags, Full Descriptive Text, or Lines Only.
- Virgin Naked POC Tracking: Toggle forward rays, configure the maximum active rays, and set auto-mitigation cleanup.
- HUD Position and Sizing: Select between Top Right, Top Left, Bottom Right, or Bottom Left, and adjust text sizing.


[b]DISCLAIMER & TRANSPARENCY[/b]

This indicator is an analytical tool designed for market structure evaluation and volume profiling. It does not provide financial advice, trading signals, or guarantees of profit. All calculations are strictly non-repainting and execute on confirmed candle closes. Past volume distribution is no guarantee of future market direction. Always manage risk responsibly and combine volume analysis with your broader trading framework.

## Source Code

````pine
//@version=6
indicator("Session Auction & Volume Profiles [AxeAlgo]", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═════════════════════════════════════════════════════════════════════════════
// AXEALGO · SESSION AUCTION & VOLUME PROFILES (OPEN SOURCE CORE EDITION)
// ─────────────────────────────────────────────────────────────────────────────
// Auction Market Theory (AMT) & Multi-Session Volume Profiling Framework
//
// Features in this Free Core Edition:
// 1. Multi-Session Volume Profiling (Asia / Tokyo, London, New York)
// 2. Developing & Fixed Value Area (70% VAH / VAL) & Point of Control (POC)
// 3. Two-Tone Volume Footprint Histogram with Customizable Granular Price Bins
// 4. Luminous Point of Control (POC) Peak Volume Level Highlight
// 5. Session Initial Balance (IB 60m) High, Low & 50% Half-Back Benchmarks
// 6. Virgin Naked POC (vPOC) Forward Magnet Tracking with Auto-Mitigation
// 7. Prior Session Value Area Reference Corridor (pVAH / pPOC / pVAL)
// 8. Live Developing Point of Control (dPOC) Real-Time Path Tracking
// 9. Staggered Non-Colliding Level Labels (Zero Chart Clutter)
// 10. Compact Quantitative Session Status Mini-HUD
// 11. Signature AxeAlgo Royal Gold Luxury Aesthetic Palette
//
// Designed to provide institutional-grade session profiling on any timeframe
// without repainting, giving every trader access to pure Auction Market Theory.
// ═════════════════════════════════════════════════════════════════════════════

// ── 1. INPUT SETTINGS ────────────────────────────────────────────────────────
g_sess  = "1. Session Configuration & Schedules"
useAsia = input.bool(true, "Enable Asia / Tokyo Session", group = g_sess)
tAsia   = input.session("1900-0200:1234567", "Asia Session Time (UTC)", group = g_sess)
cAsia   = input.color(#E8DFC8, "Asia Theme Color (Champagne Ivory)", group = g_sess)

useLon  = input.bool(true, "Enable London Session", group = g_sess)
tLon    = input.session("0700-1500:1234567", "London Session Time (UTC)", group = g_sess)
cLon    = input.color(#D4AF37, "London Theme Color (Classic Gold)", group = g_sess)

useNy   = input.bool(true, "Enable New York Session", group = g_sess)
tNy     = input.session("1230-2000:1234567", "New York Session Time (UTC)", group = g_sess)
cNy     = input.color(#B8860B, "New York Theme Color (Rich Gold)", group = g_sess)

tzInput = input.string("UTC", "Session Timezone", options = ["UTC", "America/New_York", "Europe/London", "Asia/Tokyo", "Exchange"], group = g_sess)

g_amt   = "2. Auction Market Theory (AMT) & Value Area"
maxSessions      = input.int(3, "Max Historical Sessions Displayed", minval = 1, maxval = 10, group = g_amt, tooltip = "Keeps only the most recent N sessions on the chart to prevent cluttering past price action")
vaPercent        = input.float(70.0, "Value Area Volume %", minval = 50.0, maxval = 95.0, step = 1.0, group = g_amt) / 100.0
profileBins      = input.int(32, "Volume Profile Price Bins", minval = 16, maxval = 64, step = 4, group = g_amt, tooltip = "Granularity of price levels inside the session range")
histDisplay      = input.string("Most Recent Session", "Volume Profile Scope", options = ["Most Recent Session", "All Active Sessions", "None"], group = g_amt, tooltip = "'Most Recent Session' keeps only the latest completed profile histogram, keeping older sessions sleek and uncluttered")
histWidthPct     = input.int(25, "Histogram Max Width (% of session)", minval = 10, maxval = 60, group = g_amt)
histAlign        = input.string("Right", "Volume Profile Placement", options = ["Right", "Left"], group = g_amt)
histTransp       = input.int(55, "Histogram Fill Transparency %", minval = 20, maxval = 90, step = 5, group = g_amt)
outVaStyle       = input.string("Soft Two-Tone Delta", "Outside Value Area Bars", options = ["Soft Two-Tone Delta", "Muted Institutional Slate", "Same as Value Area"], group = g_amt, tooltip = "Controls visibility of volume bins outside the 70% Value Area. 'Soft Two-Tone Delta' keeps buying/selling volume colors visible with soft transparency so bars are never blacked out or missing.")
showVaZone       = input.bool(true, "Shade Value Area (VAH to VAL)", group = g_amt)
showVahValLabels = input.bool(false, "Show VAH / VAL Text in Boxes", group = g_amt, tooltip = "Toggles text labels inside the Value Area box. Disabled by default for clean candles.")
showPocText      = input.bool(false, "Show Historical POC Text Badges", group = g_amt, tooltip = "Toggles text on historical POC lines. Disabled by default to keep chart uncluttered.")
showDevPoc       = input.bool(true, "Show Live Developing POC (dPOC)", group = g_amt, tooltip = "Plots a live developing POC line along with price for the active session")
showPriorVa      = input.bool(true, "Draw Prior Session Value Area Corridor (pVAH/pPOC/pVAL)", group = g_amt, tooltip = "Projects prior session Value Area levels forward as an institutional reference corridor during active trading")
showPriorVaLabels= input.bool(true, "Show Prior Value Area Text Labels", group = g_amt, tooltip = "When disabled, keeps the shaded Value Area corridor on chart while removing the text labels for maximum candle cleanliness.")

g_ib             = "3. Session Initial Balance (IB 60m)"
showIb           = input.bool(true, "Draw Session Initial Balance (First 60m)", group = g_ib, tooltip = "Plots the high, low, and 50% half-back of the first hour of trading, the foundational benchmark of Dalton's Day-Type classification")
levelLabelFormat = input.string("Compact Tags", "Level Label Text Style", options = ["Compact Tags", "Full Descriptive Text", "Off (Lines Only)"], group = g_ib, tooltip = "'Compact Tags' shortens labels to concise tags (IB-H, IB-L, dPOC, pPOC) with non-overlapping staggered offsets to eliminate text collisions.")

g_vpoc           = "4. Virgin Naked POC (vPOC) Tracking"
showVpoc         = input.bool(true, "Track Virgin Naked POCs (Forward Rays)", group = g_vpoc)
hideMitigatedVpoc= input.bool(true, "Auto-Erase Mitigated vPOCs", group = g_vpoc, tooltip = "Automatically erases rays once tested by price, keeping ONLY active, untested reference levels on chart")
maxVpocs         = input.int(3, "Max Active vPOC Rays on Chart", minval = 1, maxval = 8, group = g_vpoc)
vpocMaxAgeBars   = input.int(350, "vPOC Max Age Lookback (Bars)", minval = 100, maxval = 2000, group = g_vpoc, tooltip = "Erases untested vPOC lines older than this many bars so ancient levels from months ago don't clutter the chart")
vpocStyle        = input.string("Dashed", "vPOC Ray Style", options = ["Solid", "Dashed", "Dotted"], group = g_vpoc)
vpocWidth        = input.int(2, "vPOC Ray Width", minval = 1, maxval = 4, group = g_vpoc)

g_hud            = "5. Quantitative Session Status HUD"
showHud          = input.bool(true, "Show Session Status Mini-HUD", group = g_hud, tooltip = "Displays a streamlined, luxury heads-up display with live session state, value area boundaries, and Initial Balance progress.")
hudPos           = input.string("Top Right", "HUD Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = g_hud)
hudSize          = input.string("Small", "HUD Size", options = ["Tiny", "Small", "Normal"], group = g_hud)

g_cols           = "6. AxeAlgo Royal Gold Palette"
colPoc           = input.color(#D4AF37, "Point of Control (POC) Color", group = g_cols)
colDevPoc        = input.color(#FFD400, "Developing POC (dPOC) Color", group = g_cols)
colVpoc          = input.color(#FFD400, "Virgin Naked POC Color", group = g_cols)
colIb            = input.color(#D4AF37, "Initial Balance (IB) Bracket Color", group = g_cols)
colPriorVa       = input.color(#C9A227, "Prior Value Area Corridor Color", group = g_cols)
colBuyDelta      = input.color(#D4AF37, "Profile Bullish Volume Accent (Royal Gold)", group = g_cols)
colSellDelta     = input.color(#B91C1C, "Profile Bearish Volume Accent (Royal Red)", group = g_cols)

// AxeAlgo Standing Royal Gold Brand Tokens
color cGoldPrimary = #B8860B
color cGoldClassic = #D4AF37
color cGoldBright  = #FFD400
color cGoldAntique = #C9A227
color cGoldIvory   = #E8DFC8
color cGoldMuted   = #C9B37E
color cDarkCanvas  = #0E171D

// ── 2. TYPE DEFINITIONS ──────────────────────────────────────────────────────
type SessionData
    string  name
    color   baseCol
    int     startIdx
    int     startTime
    int     endIdx
    float   sessHigh
    float   sessLow
    float   sessOpen
    float   totalVol
    float   buyVol
    float   sellVol
    float   pocPrice
    float   vahPrice
    float   valPrice
    float   ibHigh
    float   ibLow
    float   ibMid

type VpocRay
    int     startBar
    float   price
    string  sessionName
    line    rayLine
    label   rayLbl
    bool    mitigated

// ── 3. STATE ARRAYS & PERSISTENCE ────────────────────────────────────────────
var array<SessionData> completedSessions = array.new<SessionData>()
var array<VpocRay>     activeVpocs       = array.new<VpocRay>()
var array<box>         activeVaBoxes     = array.new<box>()
var array<box>         activeHistBoxes   = array.new<box>()
var array<line>        activeLines       = array.new<line>()
var array<label>       activeLabels      = array.new<label>()

// Prior session Value Area memory
var float priorVah = na
var float priorVal = na
var float priorPoc = na

// Live developing POC tracking
var line  devPocLine  = na
var label devPocLabel = na

// Active Initial Balance (IB 60m) drawing objects
var line  ibLineH = na
var line  ibLineL = na
var line  ibLineM = na
var label ibLblH  = na
var label ibLblL  = na
var label ibLblM  = na

// Prior session Value Area corridor drawing objects
var box   pVaBox   = na
var line  pVaLineH = na
var line  pVaLineL = na
var line  pVaLineP = na
var label pVaLblH  = na
var label pVaLblL  = na
var label pVaLblP  = na

// ── 4. HELPER FUNCTIONS ──────────────────────────────────────────────────────
f_inSession(string _sess, string _tz) =>
    not na(time(timeframe.period, _sess, _tz))

f_buildLevelLabel(string _compactTag, string _fullTag, float _val) =>
    switch levelLabelFormat
        "Compact Tags"          => _compactTag + " " + str.tostring(_val, "#.##")
        "Full Descriptive Text" => _fullTag + " " + str.tostring(_val, "#.##")
        => ""

f_getLineStyle(string _style) =>
    switch _style
        "Solid"  => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_dashed

f_getTablePos(string _pos) =>
    switch _pos
        "Top Right"    => position.top_right
        "Bottom Right" => position.bottom_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_getTableSize(string _size) =>
    switch _size
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        => size.small

// ── 5. SESSION TIMING ENGINE ─────────────────────────────────────────────────
bool inAsia = useAsia and f_inSession(tAsia, tzInput)
bool inLon  = useLon  and f_inSession(tLon, tzInput)
bool inNy   = useNy   and f_inSession(tNy, tzInput)

bool asiaStart = inAsia and not inAsia[1]
bool lonStart  = inLon  and not inLon[1]
bool nyStart   = inNy   and not inNy[1]

bool asiaEnd   = not inAsia and inAsia[1]
bool lonEnd    = not inLon  and inLon[1]
bool nyEnd     = not inNy   and inNy[1]

bool inAnySession       = inAsia or inLon or inNy
bool anySessionStarting = asiaStart or lonStart or nyStart

// Determine active session name & theme color
string currentSessionName = inNy ? "New York" : inLon ? "London" : inAsia ? "Asia" : "Inter-Session"
color  currentSessionCol  = inNy ? cNy : inLon ? cLon : inAsia ? cAsia : cGoldMuted

// ── 6. REAL-TIME INTRA-SESSION METRICS ACCUMULATION ──────────────────────────
var int   curSessStartBar = 0
var int   curSessTime     = 0
var float curSessHigh     = na
var float curSessLow      = na
var float curSessOpen     = na
var float curSessTotVol   = 0.0
var float curSessBuyVol   = 0.0
var float curSessSellVol  = 0.0

// Session Initial Balance (IB 60m) State
var float ibHigh         = na
var float ibLow          = na
var float ibMid          = na
var bool  ibEstablished  = false

float barVol   = nz(volume, 1.0)
float barRange = high - low

// Estimate bar delta based on price action location inside bar
float bodySpan   = math.abs(close - open)
float barDelta   = barRange > 0 ? (close - open) / barRange * barVol : 0.0
float estBuyVol  = math.max(0.0, (barVol + barDelta) * 0.5)
float estSellVol = math.max(0.0, (barVol - barDelta) * 0.5)

// Intra-session Bar Arrays for High-Precision Retrospective Distribution
var float[] sessBarHighs = array.new_float(0)
var float[] sessBarLows  = array.new_float(0)
var float[] sessBarBuys  = array.new_float(0)
var float[] sessBarSells = array.new_float(0)

// Reset state at session open
if anySessionStarting
    curSessStartBar := bar_index
    curSessTime     := time
    curSessHigh     := high
    curSessLow      := low
    curSessOpen     := open
    curSessTotVol   := barVol
    curSessBuyVol   := estBuyVol
    curSessSellVol  := estSellVol
    ibHigh          := high
    ibLow           := low
    ibMid           := (high + low) * 0.5
    ibEstablished   := false

    array.clear(sessBarHighs)
    array.clear(sessBarLows)
    array.clear(sessBarBuys)
    array.clear(sessBarSells)
    array.push(sessBarHighs, high)
    array.push(sessBarLows, low)
    array.push(sessBarBuys, estBuyVol)
    array.push(sessBarSells, estSellVol)

else if inAnySession
    curSessHigh    := math.max(nz(curSessHigh, high), high)
    curSessLow     := math.min(nz(curSessLow, low), low)
    curSessTotVol  += barVol
    curSessBuyVol  += estBuyVol
    curSessSellVol += estSellVol

    array.push(sessBarHighs, high)
    array.push(sessBarLows, low)
    array.push(sessBarBuys, estBuyVol)
    array.push(sessBarSells, estSellVol)

    // Accumulate Initial Balance during first 60 minutes
    if (time - curSessTime) <= 3600000
        ibHigh := math.max(nz(ibHigh, high), high)
        ibLow  := math.min(nz(ibLow, low), low)
        ibMid  := (ibHigh + ibLow) * 0.5
    else
        ibEstablished := true

// ── 7. VOLUME PROFILE & VALUE AREA CALCULATION ENGINE ─────────────────────────
f_computeProfileAndVa(float _sHigh, float _sLow, float[] _bH, float[] _bL, float[] _bBuy, float[] _bSell) =>
    int   nBins   = profileBins
    float rng     = _sHigh - _sLow
    float binStep = rng > 0 ? rng / nBins : syminfo.mintick

    float[] binTotVol  = array.new_float(nBins, 0.0)
    float[] binBuyVol  = array.new_float(nBins, 0.0)
    float[] binSellVol = array.new_float(nBins, 0.0)
    float[] binMidPx   = array.new_float(nBins, 0.0)

    for i = 0 to nBins - 1
        array.set(binMidPx, i, _sLow + (i + 0.5) * binStep)

    int barCount = array.size(_bH)
    if barCount > 0 and rng > 0
        for b = 0 to barCount - 1
            float bh = array.get(_bH, b)
            float bl = array.get(_bL, b)
            float bBuy = array.get(_bBuy, b)
            float bSell = array.get(_bSell, b)
            float bTot = bBuy + bSell

            int minBin = math.max(0, math.min(nBins - 1, int(math.floor((bl - _sLow) / binStep))))
            int maxBin = math.max(0, math.min(nBins - 1, int(math.floor((bh - _sLow) / binStep))))
            int span = maxBin - minBin + 1

            float allocBuy  = bBuy / span
            float allocSell = bSell / span
            float allocTot  = bTot / span

            for k = minBin to maxBin
                array.set(binTotVol, k, array.get(binTotVol, k) + allocTot)
                array.set(binBuyVol, k, array.get(binBuyVol, k) + allocBuy)
                array.set(binSellVol, k, array.get(binSellVol, k) + allocSell)

    int pocBin = 0
    float maxVol = 0.0
    for i = 0 to nBins - 1
        float v = array.get(binTotVol, i)
        if v > maxVol
            maxVol := v
            pocBin := i

    float pocPx = array.get(binMidPx, pocBin)

    float totProfileVol = array.sum(binTotVol)
    float targetVaVol   = totProfileVol * vaPercent
    float currentVaVol  = maxVol

    int vaUpperBin = pocBin
    int vaLowerBin = pocBin

    while currentVaVol < targetVaVol and (vaUpperBin < nBins - 1 or vaLowerBin > 0)
        float nextAboveVol = vaUpperBin < nBins - 1 ? array.get(binTotVol, vaUpperBin + 1) : 0.0
        float nextBelowVol = vaLowerBin > 0 ? array.get(binTotVol, vaLowerBin - 1) : 0.0

        if nextAboveVol >= nextBelowVol and vaUpperBin < nBins - 1
            vaUpperBin += 1
            currentVaVol += nextAboveVol
        else if vaLowerBin > 0
            vaLowerBin -= 1
            currentVaVol += nextBelowVol
        else if vaUpperBin < nBins - 1
            vaUpperBin += 1
            currentVaVol += nextAboveVol
        else
            break

    float vahPx = array.get(binMidPx, vaUpperBin) + (binStep * 0.5)
    float valPx = array.get(binMidPx, vaLowerBin) - (binStep * 0.5)

    [pocPx, vahPx, valPx, binTotVol, binBuyVol, binSellVol, binMidPx, binStep, maxVol]

// Live Developing Point of Control (dPOC)
var float curDevPoc = na
if inAnySession and showDevPoc and array.size(sessBarHighs) > 0 and not na(curSessHigh) and not na(curSessLow) and (curSessHigh > curSessLow)
    [livePoc, _, _, _, _, _, _, _, _] = f_computeProfileAndVa(curSessHigh, curSessLow, sessBarHighs, sessBarLows, sessBarBuys, sessBarSells)
    curDevPoc := livePoc

    int dPocX = bar_index + 3
    if not na(devPocLine)
        line.set_x2(devPocLine, dPocX)
        line.set_y1(devPocLine, curDevPoc)
        line.set_y2(devPocLine, curDevPoc)
        if not na(devPocLabel)
            label.set_x(devPocLabel, dPocX)
            label.set_y(devPocLabel, curDevPoc)
            label.set_text(devPocLabel, f_buildLevelLabel("dPOC", "Developing POC", curDevPoc))
    else
        devPocLine  := line.new(curSessStartBar, curDevPoc, dPocX, curDevPoc, color = colDevPoc, width = 1, style = line.style_dashed)
        devPocLabel := label.new(dPocX, curDevPoc, f_buildLevelLabel("dPOC", "Developing POC", curDevPoc), color = color.new(cDarkCanvas, 25), textcolor = colDevPoc, style = label.style_label_left, size = size.tiny)
else if not inAnySession and not na(devPocLine)
    line.delete(devPocLine)
    label.delete(devPocLabel)
    devPocLine  := na
    devPocLabel := na

// ── 8. SESSION COMPLETION & VALUE AREA PROFILE RENDERER ──────────────────────
f_renderSession(string _name, color _col, int _sB, int _eB, float _sH, float _sL, float _sO, float _sC, float[] _bH, float[] _bL, float[] _bBuy, float[] _bSell) =>
    float outPoc = na
    float outVah = na
    float outVal = na

    if _eB > _sB and (_sH - _sL) > 0
        [sessionPoc, sessionVah, sessionVal, binTot, binBuy, binSell, binMid, binStep, maxBinVol] = f_computeProfileAndVa(_sH, _sL, _bH, _bL, _bBuy, _bSell)
        outPoc := sessionPoc
        outVah := sessionVah
        outVal := sessionVal

        // 1. Draw Value Area Shaded Zone (Luxury Dark Canvas)
        if showVaZone
            string vaTxt = showVahValLabels ? "VAH " + str.tostring(sessionVah, "#.##") + "  ·  VAL " + str.tostring(sessionVal, "#.##") : ""
            box vaBox = box.new(
              _sB, sessionVah, _eB, sessionVal,
              bgcolor     = color.new(_col, 93),
              border_color= color.new(_col, 75),
              border_width= 1,
              border_style= line.style_dotted,
              text        = vaTxt,
              text_color  = color.new(cGoldIvory, 20),
              text_size   = size.tiny,
              text_halign = text.align_left,
              text_valign = text.align_top
              )
            array.push(activeVaBoxes, vaBox)
            while array.size(activeVaBoxes) > maxSessions
                box.delete(array.shift(activeVaBoxes))

        // 2. VAH & VAL Boundary Dashed Corridor Lines
        line vahLine = line.new(_sB, sessionVah, _eB, sessionVah, color = color.new(_col, 45), width = 1, style = line.style_dashed)
        line valLine = line.new(_sB, sessionVal, _eB, sessionVal, color = color.new(_col, 45), width = 1, style = line.style_dashed)
        array.push(activeLines, vahLine)
        array.push(activeLines, valLine)

        // 3. Fixed Point of Control (POC) Line
        line pocLine = line.new(_sB, sessionPoc, _eB, sessionPoc, color = colPoc, width = 2, style = line.style_solid)
        array.push(activeLines, pocLine)

        if showPocText
            label pocLbl = label.new(
              _sB, sessionPoc,
              f_buildLevelLabel("POC", "Point of Control", sessionPoc),
              color     = #00000000,
              textcolor = colPoc,
              style     = label.style_label_right,
              size      = size.tiny
              )
            array.push(activeLabels, pocLbl)

        // 4. Register Virgin Naked POC (vPOC) Forward Ray
        if showVpoc
            line vpocLine = line.new(
              _eB, sessionPoc, _eB + 8, sessionPoc,
              color = colVpoc,
              width = vpocWidth,
              style = f_getLineStyle(vpocStyle)
              )
            label vpocLbl = label.new(
              _eB + 8, sessionPoc,
              "vPOC (" + _name + ") " + str.tostring(sessionPoc, "#.##"),
              color     = color.new(cDarkCanvas, 25),
              textcolor = colVpoc,
              style     = label.style_label_left,
              size      = size.tiny
              )
            VpocRay vRay = VpocRay.new(_eB, sessionPoc, _name, vpocLine, vpocLbl, false)
            array.push(activeVpocs, vRay)

        // 5. Draw Two-Tone Volume Profile Histogram
        if histDisplay != "None" and maxBinVol > 0
            if histDisplay == "Most Recent Session"
                while array.size(activeHistBoxes) > 0
                    box.delete(array.shift(activeHistBoxes))

            int sessBarSpan = _eB - _sB
            int maxHistBars = math.max(4, int(sessBarSpan * (histWidthPct / 100.0)))
            float halfH     = binStep * 0.40
            int nBins       = profileBins

            for b = 0 to nBins - 1
                float bTot = array.get(binTot, b)
                if bTot > 0
                    float bBuy  = array.get(binBuy, b)
                    float bSell = array.get(binSell, b)
                    float midY  = array.get(binMid, b)

                    int barLength = math.max(1, int(math.round((bTot / maxBinVol) * maxHistBars)))
                    int bLeft     = histAlign == "Right" ? _eB - barLength : _sB
                    int bRight    = histAlign == "Right" ? _eB : _sB + barLength

                    bool isInsideVa = (midY >= sessionVal and midY <= sessionVah)
                    bool isPocBin   = (bTot == maxBinVol or math.abs(midY - sessionPoc) <= (binStep * 0.51))

                    // Fully visible two-tone bins with high contrast
                    color binColor = bBuy >= bSell ? color.new(colBuyDelta, math.min(80, histTransp + 15)) : color.new(colSellDelta, math.min(80, histTransp + 15))
                    if isPocBin
                        binColor := color.new(colDevPoc, math.max(10, histTransp - 25))
                    else if isInsideVa
                        binColor := bBuy >= bSell ? color.new(colBuyDelta, histTransp) : color.new(colSellDelta, histTransp)
                    else if outVaStyle == "Muted Institutional Slate"
                        binColor := color.new(#787B86, math.min(75, histTransp + 5))
                    else if outVaStyle == "Same as Value Area"
                        binColor := bBuy >= bSell ? color.new(colBuyDelta, histTransp) : color.new(colSellDelta, histTransp)

                    box hBox = box.new(left = bLeft, top = midY + halfH, right = bRight, bottom = midY - halfH, border_width = 0, bgcolor = binColor)
                    array.push(activeHistBoxes, hBox)
                    if histDisplay == "All Active Sessions" and array.size(activeHistBoxes) > maxSessions * profileBins
                        box.delete(array.shift(activeHistBoxes))

        // FIFO Pruning
        while array.size(activeLines) > maxSessions * 4
            line.delete(array.shift(activeLines))
        while array.size(activeLabels) > maxSessions * 2
            label.delete(array.shift(activeLabels))

    [outPoc, outVah, outVal]

// Session Completion Events
bool sessionJustEnded = false
if asiaEnd and barstate.isconfirmed
    [pPocA, pVahA, pValA] = f_renderSession("Asia", cAsia, curSessStartBar, bar_index, curSessHigh, curSessLow, curSessOpen, close, sessBarHighs, sessBarLows, sessBarBuys, sessBarSells)
    if not na(pPocA)
        priorPoc := pPocA
        priorVah := pVahA
        priorVal := pValA
    sessionJustEnded := true
    curDevPoc := na

if lonEnd and barstate.isconfirmed
    [pPocL, pVahL, pValL] = f_renderSession("London", cLon, curSessStartBar, bar_index, curSessHigh, curSessLow, curSessOpen, close, sessBarHighs, sessBarLows, sessBarBuys, sessBarSells)
    if not na(pPocL)
        priorPoc := pPocL
        priorVah := pVahL
        priorVal := pValL
    sessionJustEnded := true
    curDevPoc := na

if nyEnd and barstate.isconfirmed
    [pPocN, pVahN, pValN] = f_renderSession("New York", cNy, curSessStartBar, bar_index, curSessHigh, curSessLow, curSessOpen, close, sessBarHighs, sessBarLows, sessBarBuys, sessBarSells)
    if not na(pPocN)
        priorPoc := pPocN
        priorVah := pVahN
        priorVal := pValN
    sessionJustEnded := true
    curDevPoc := na

// ── 9. SESSION INITIAL BALANCE (IB 60m) VISUAL BRACKET ───────────────────────
if inAnySession and showIb and not na(ibHigh) and not na(ibLow)
    int x1 = curSessStartBar
    // Non-colliding staggered offset (bar_index + 6)
    int x2 = bar_index + 6

    if not na(ibLineH)
        line.set_x2(ibLineH, x2)
        line.set_y1(ibLineH, ibHigh)
        line.set_y2(ibLineH, ibHigh)
        line.set_x2(ibLineL, x2)
        line.set_y1(ibLineL, ibLow)
        line.set_y2(ibLineL, ibLow)
        line.set_x2(ibLineM, x2)
        line.set_y1(ibLineM, ibMid)
        line.set_y2(ibLineM, ibMid)

        if not na(ibLblH)
            label.set_x(ibLblH, x2)
            label.set_y(ibLblH, ibHigh)
            label.set_text(ibLblH, f_buildLevelLabel("IB-H", "Initial Balance High", ibHigh))
            label.set_x(ibLblL, x2)
            label.set_y(ibLblL, ibLow)
            label.set_text(ibLblL, f_buildLevelLabel("IB-L", "Initial Balance Low", ibLow))
            label.set_x(ibLblM, x2)
            label.set_y(ibLblM, ibMid)
            label.set_text(ibLblM, f_buildLevelLabel("IB-Mid", "Initial Balance 50%", ibMid))
    else
        ibLineH := line.new(x1, ibHigh, x2, ibHigh, color = colIb, width = 1, style = line.style_solid)
        ibLineL := line.new(x1, ibLow,  x2, ibLow,  color = colIb, width = 1, style = line.style_solid)
        ibLineM := line.new(x1, ibMid,  x2, ibMid,  color = color.new(colIb, 40), width = 1, style = line.style_dotted)

        ibLblH  := label.new(x2, ibHigh, f_buildLevelLabel("IB-H", "Initial Balance High", ibHigh), color = #00000000, textcolor = colIb, style = label.style_label_left, size = size.tiny)
        ibLblL  := label.new(x2, ibLow,  f_buildLevelLabel("IB-L", "Initial Balance Low", ibLow),   color = #00000000, textcolor = colIb, style = label.style_label_left, size = size.tiny)
        ibLblM  := label.new(x2, ibMid,  f_buildLevelLabel("IB-Mid", "Initial Balance 50%", ibMid), color = #00000000, textcolor = color.new(colIb, 30), style = label.style_label_left, size = size.tiny)

else if not inAnySession and not na(ibLineH)
    line.delete(ibLineH)
    line.delete(ibLineL)
    line.delete(ibLineM)
    label.delete(ibLblH)
    label.delete(ibLblL)
    label.delete(ibLblM)
    ibLineH := na
    ibLineL := na
    ibLineM := na
    ibLblH  := na
    ibLblL  := na
    ibLblM  := na

// ── 10. PRIOR SESSION VALUE AREA CORRIDOR PROJECTION ─────────────────────────
if inAnySession and showPriorVa and not na(priorVah) and not na(priorVal) and not na(priorPoc)
    int pX1 = curSessStartBar
    // Non-colliding staggered offset (bar_index + 11) - placed further right to avoid IB collision
    int pX2 = bar_index + 11

    if not na(pVaBox)
        box.set_top(pVaBox, priorVah)
        box.set_bottom(pVaBox, priorVal)
        box.set_left(pVaBox, pX1)
        box.set_right(pVaBox, pX2)

        line.set_x2(pVaLineH, pX2)
        line.set_y1(pVaLineH, priorVah)
        line.set_y2(pVaLineH, priorVah)
        line.set_x2(pVaLineL, pX2)
        line.set_y1(pVaLineL, priorVal)
        line.set_y2(pVaLineL, priorVal)
        line.set_x2(pVaLineP, pX2)
        line.set_y1(pVaLineP, priorPoc)
        line.set_y2(pVaLineP, priorPoc)

        if showPriorVaLabels and not na(pVaLblH)
            label.set_x(pVaLblH, pX2)
            label.set_y(pVaLblH, priorVah)
            label.set_text(pVaLblH, f_buildLevelLabel("pVAH", "Prior VAH", priorVah))
            label.set_x(pVaLblL, pX2)
            label.set_y(pVaLblL, priorVal)
            label.set_text(pVaLblL, f_buildLevelLabel("pVAL", "Prior VAL", priorVal))
            label.set_x(pVaLblP, pX2)
            label.set_y(pVaLblP, priorPoc)
            label.set_text(pVaLblP, f_buildLevelLabel("pPOC", "Prior POC", priorPoc))
    else
        pVaBox   := box.new(pX1, priorVah, pX2, priorVal, bgcolor = color.new(colPriorVa, 95), border_color = color.new(colPriorVa, 80), border_width = 1, border_style = line.style_dotted)
        pVaLineH := line.new(pX1, priorVah, pX2, priorVah, color = color.new(colPriorVa, 35), width = 1, style = line.style_dashed)
        pVaLineL := line.new(pX1, priorVal, pX2, priorVal, color = color.new(colPriorVa, 35), width = 1, style = line.style_dashed)
        pVaLineP := line.new(pX1, priorPoc, pX2, priorPoc, color = color.new(colPriorVa, 20), width = 1, style = line.style_dotted)

        if showPriorVaLabels
            pVaLblH := label.new(pX2, priorVah, f_buildLevelLabel("pVAH", "Prior VAH", priorVah), color = color.new(cDarkCanvas, 25), textcolor = color.new(colPriorVa, 20), style = label.style_label_left, size = size.tiny)
            pVaLblL := label.new(pX2, priorVal, f_buildLevelLabel("pVAL", "Prior VAL", priorVal), color = color.new(cDarkCanvas, 25), textcolor = color.new(colPriorVa, 20), style = label.style_label_left, size = size.tiny)
            pVaLblP := label.new(pX2, priorPoc, f_buildLevelLabel("pPOC", "Prior POC", priorPoc), color = color.new(cDarkCanvas, 25), textcolor = color.new(colPriorVa, 10), style = label.style_label_left, size = size.tiny)

else if not inAnySession and not na(pVaBox)
    box.delete(pVaBox)
    line.delete(pVaLineH)
    line.delete(pVaLineL)
    line.delete(pVaLineP)
    label.delete(pVaLblH)
    label.delete(pVaLblL)
    label.delete(pVaLblP)
    pVaBox   := na
    pVaLineH := na
    pVaLineL := na
    pVaLineP := na
    pVaLblH  := na
    pVaLblL  := na
    pVaLblP  := na

// ── 11. VIRGIN NAKED POC (vPOC) FORWARD TRACKING & AUTO-MITIGATION ───────────
var int unmitigatedCount = 0
if showVpoc and array.size(activeVpocs) > 0 and barstate.isconfirmed
    unmitigatedCount := 0
    for i = array.size(activeVpocs) - 1 to 0
        VpocRay r = array.get(activeVpocs, i)
        if not r.mitigated
            unmitigatedCount += 1
            // Check if price penetrates vPOC level (Mitigation)
            if low <= r.price and high >= r.price
                r.mitigated := true
                alert("AxeAlgo AMT: Virgin Naked POC Mitigated! " + r.sessionName + " vPOC reached at " + str.tostring(r.price, "#.##"), alert.freq_once_per_bar_close)
                if hideMitigatedVpoc
                    line.delete(r.rayLine)
                    label.delete(r.rayLbl)
                    array.remove(activeVpocs, i)
                else
                    line.set_x2(r.rayLine, bar_index)
                    line.set_color(r.rayLine, color.new(cGoldMuted, 65))
                    line.set_style(r.rayLine, line.style_dotted)
                    label.set_x(r.rayLbl, bar_index)
                    label.set_text(r.rayLbl, "✓ Hit " + r.sessionName + " vPOC [" + str.tostring(r.price, "#.##") + "]")
                    label.set_textcolor(r.rayLbl, cGoldMuted)
                    label.set_color(r.rayLbl, color.new(cDarkCanvas, 30))
            else if (bar_index - r.startBar) > vpocMaxAgeBars
                line.delete(r.rayLine)
                label.delete(r.rayLbl)
                array.remove(activeVpocs, i)
            else
                int vpocX = bar_index + 7
                line.set_x2(r.rayLine, vpocX)
                label.set_x(r.rayLbl, vpocX)
                label.set_text(r.rayLbl, "vPOC (" + r.sessionName + ") " + str.tostring(r.price, "#.##"))
                label.set_textcolor(r.rayLbl, colVpoc)
                label.set_color(r.rayLbl, color.new(cDarkCanvas, 25))

    while array.size(activeVpocs) > maxVpocs
        VpocRay oldR = array.shift(activeVpocs)
        line.delete(oldR.rayLine)
        label.delete(oldR.rayLbl)

// ── 12. QUANTITATIVE SESSION STATUS MINI-HUD ─────────────────────────────────
var table hudTable = table.new(position = f_getTablePos(hudPos), columns = 2, rows = 6, bgcolor = color.new(cDarkCanvas, 8), border_width = 1, border_color = color.new(cGoldPrimary, 60), frame_width = 1, frame_color = color.new(cGoldPrimary, 40))

if showHud and barstate.islast
    var string tSize = f_getTableSize(hudSize)

    // Row 0: Brand Header
    table.cell(hudTable, 0, 0, "AXEALGO · AUCTION VAULT", bgcolor = color.new(cGoldPrimary, 25), text_color = cGoldBright, text_size = tSize)
    table.cell(hudTable, 1, 0, "AMT CORE", bgcolor = color.new(cGoldPrimary, 25), text_color = cGoldBright, text_size = tSize)

    // Row 1: Active Session State
    string sessStateText = inAnySession ? currentSessionName + " (Active)" : "Inter-Session Closed"
    color  sessStateCol  = inAnySession ? currentSessionCol : cGoldMuted
    table.cell(hudTable, 0, 1, "Session State", text_color = cGoldMuted, text_size = tSize)
    table.cell(hudTable, 1, 1, sessStateText, text_color = sessStateCol, text_size = tSize)

    // Row 2: 70% Value Area Range
    string vaRangeText = not na(priorVah) and not na(priorVal) ? str.tostring(priorVal, "#.##") + " - " + str.tostring(priorVah, "#.##") : "Calculating..."
    table.cell(hudTable, 0, 2, "Value Area (70%)", text_color = cGoldMuted, text_size = tSize)
    table.cell(hudTable, 1, 2, vaRangeText, text_color = cGoldClassic, text_size = tSize)

    // Row 3: Initial Balance (60m)
    int minsPassed = int((time - curSessTime) / 60000)
    int minsLeft   = math.max(0, 60 - minsPassed)
    string ibStatus = ibEstablished ? (close > ibHigh ? "Expanded High (Trend)" : close < ibLow ? "Expanded Low (Trend)" : "Inside Range (Rotational)") : ("Forming (" + str.tostring(minsLeft) + "m left)")
    color  ibCol    = ibEstablished ? (close > ibHigh ? #10B981 : close < ibLow ? #B91C1C : cGoldBright) : cGoldMuted
    table.cell(hudTable, 0, 3, "Initial Balance (60m)", text_color = cGoldMuted, text_size = tSize)
    table.cell(hudTable, 1, 3, ibStatus, text_color = ibCol, text_size = tSize)

    // Row 4: Key Reference (POC)
    string pocText = not na(curDevPoc) ? "dPOC " + str.tostring(curDevPoc, "#.##") : not na(priorPoc) ? "pPOC " + str.tostring(priorPoc, "#.##") : "None"
    table.cell(hudTable, 0, 4, "Key Reference (POC)", text_color = cGoldMuted, text_size = tSize)
    table.cell(hudTable, 1, 4, pocText, text_color = cGoldBright, text_size = tSize)

    // Row 5: Active vPOC Magnets
    string vText = str.tostring(unmitigatedCount) + " Untested Magnet" + (unmitigatedCount == 1 ? "" : "s")
    table.cell(hudTable, 0, 5, "Active vPOC Magnets", text_color = cGoldMuted, text_size = tSize)
    table.cell(hudTable, 1, 5, vText, text_color = unmitigatedCount > 0 ? cGoldBright : cGoldMuted, text_size = tSize)

// ── 13. ALERT CONDITIONS ─────────────────────────────────────────────────────
bool crossIbH = ta.crossover(high, ibHigh)
bool crossIbL = ta.crossunder(low, ibLow)
bool ibBreakoutBull = inAnySession and ibEstablished and crossIbH
bool ibBreakoutBear = inAnySession and ibEstablished and crossIbL

alertcondition(anySessionStarting, "Session Opened", "AxeAlgo AMT: Major Trading Session Opened")
alertcondition(sessionJustEnded, "Session Closed & Profile Fixed", "AxeAlgo AMT: Session Completed & Volume Profile Fixed")
alertcondition(ibBreakoutBull, "Initial Balance Bullish Expansion", "AxeAlgo AMT: Price extended above 60-minute Initial Balance High")
alertcondition(ibBreakoutBear, "Initial Balance Bearish Expansion", "AxeAlgo AMT: Price extended below 60-minute Initial Balance Low")

var table wm = table.new(position.bottom_center, 2, 1, frame_width = 1, border_width = 0)
if barstate.islast
    dark       = true
    wm_bg      = dark ? color.new(#14110B, 0) : color.new(#F2EAD3, 0)
    wm_dot_col = dark ? color.new(#D4AF37, 15) : color.new(#B8860B, 10)
    wm_txt_col = dark ? color.new(#C9B37E, 0) : color.new(#7A6423, 0)
    wm_frm_col = dark ? color.new(#D4AF37, 60) : color.new(#B8860B, 60)

    table.set_frame_color(wm, wm_frm_col)
    table.cell(wm, 0, 0, " ◆ ", bgcolor = wm_bg, text_color = wm_dot_col, text_size = size.small, text_formatting = text.format_bold)
    table.cell(wm, 1, 0, " A X E A L G O ", bgcolor = wm_bg, text_color = wm_txt_col, text_size = size.small, text_formatting = text.format_bold)
````
