# AUTO ORB ALL   Auto Market Opens

- url: https://www.tradingview.com/script/QAj0kLsF-AUTO-ORB-ALL-Auto-Market-Opens/
- type: indicator
- pine_id: PUB;d0ed494a708a4e2fbd2b626b3943235c
- version: 1.0

## Description

AUTO ORB ALL — TradingView Indicator DetailsIndicator NameAUTO ORB ALL — Auto Market OpensShort title:
G13ORBFramework:Pine Script v6Multi-session ORB engineAuto market rotationManual session pinningInstitutional-style visualizationWhat This Indicator DoesThis indicator automatically tracks and rotates between major global trading session opens and builds Opening Range Breakout (ORB) zones dynamically.It creates:ORB HighORB LowMidlineSession range boxBreakout signalsInstitutional HUDwhile intelligently determining which market session is currently active.Major Improvements vs Previous VersionThis new version is architecturally stronger because:1. Cleaner Session EngineYou consolidated the logic into:f_orb(...)This is much better than maintaining separate state engines.Benefits:Lower code duplicationEasier debuggingEasier feature additionsBetter TradingView performance2. Stable Drawing LifecycleYou now correctly:Delete old objectsReset referencesRecreate only when neededThis avoids:Memory leaksLine duplicationLabel stackingTradingView object overflowHuge improvement.3. Better Active Session LogicYour active market selection now checks:aSession < sessionHours * 60This prevents expired sessions from remaining active forever.That fixes one of the biggest structural problems in many ORB systems.4. Better Visual HierarchyThe distinction between:Active ORBsPinned ORBsis now visually excellent.Active:Gold institutional stylingPinned:Transparent faded overlaysThis dramatically improves readability.Core Features1. Automatic Session RotationThe indicator dynamically rotates between:SessionPurposeAsiaAsian liquidityTokyoTokyo institutional openLondon PMLondon premarketLondonMain London sessionNY PremarketUS premarketGold / COMEXMetals openNew YorkMain NY openLondon CloseClosing volatilityGlobexFutures overnightThe newest valid open becomes the active ORB.2. Manual Pinning SystemUsers can pin any session permanently onto the chart.Example:Keep London ORB visible during NYKeep Asia ORB visible for ICT liquidity mappingThis is extremely useful for:SMT tradersICT tradersLiquidity sweep modelsKillzone analysis3. ORB Construction EngineThe script builds:ORB HighORB LowMidpointDynamic range boxduring the configured opening window.4. Configurable ORB WindowUsers can define:orbMinutesRange:1 minute240 minutesMost practical values:5m15m30m60m5. Breakout DetectionBullish Breakoutclose > orbHigh and close[1] <= orbHighBearish Breakdownclose < orbLow and close[1] >= orbLowVery clean implementation.6. Optional Retest LogicThis is one of the stronger parts of your design.When enabled:Price must revisit the ORB boundaryTHEN confirm continuationThis filters many false breakouts.Excellent for:FuturesGoldNASDAQLondon fakeouts7. Signal LimiteroneSigPerSessionPrevents:Signal spamOvertradingDuplicate alertsGood institutional behavior.8. HUD DashboardDisplays:Active marketORB statusORB window sizeHighLowRangePinned session countThis is already commercial-grade UI design.Technical Quality AssessmentStrong AreasExcellentState managementObject lifecycle handlingSession arbitrationModularityUI structureScalabilityVery GoodTimezone handlingDynamic active sessionsRetest logicSignal architectureNeeds Improvement1. Repaint Risk During Live BarsCurrent breakout logic:close > orbHighis mostly safe.But intrabar updates may still flicker on realtime candles.Safer option:barstate.isconfirmedExample:bullRaw = barstate.isconfirmed and ...2. Midline PersistenceCurrently:Midline only creates after ORB setSome traders prefer:Live updating midpoint during buildOptional feature idea.3. ORB Box CoordinatesCurrent box:bar_index + 1This can visually compress on higher TFs.Possible improvement:Extend to session closeOr use dynamic right boundary4. HUD Table CleanupWhen HUD disabled:showHUD = falsetable still exists.Minor issue only.Best TradingView Use CasesFuturesESNQYMForexEURUSDGBPUSDUSDJPYMetalsXAUUSDCOMEX GoldICT / SMC WorkflowsVery compatible with:KillzonesLiquidity sweepsSession manipulationJudas swingsDisplacement modelsBest TimeframesStyleTFScalping1m–3mIntraday5m–15mSwing Intraday15m–1HSuggested TradingView DescriptionAUTO ORB ALL — Auto Market OpensProfessional multi-session Opening Range Breakout system with automatic market rotation and institutional session tracking.Features:Auto rotating session ORBsPinned session overlaysLondon / NY / Asia opensGold / COMEX ORBDynamic breakout signalsRetest confirmation logicInstitutional HUD dashboardBlack + gold professional designBuilt for:FuturesForexGoldICT / Smart Money Concepts tradersSuggested TradingView TagsORBOpening Range BreakoutICTSmart MoneyFuturesForexGoldLondon OpenNew York OpenSession TradingScalpingOverall RatingArchitecture9/10TradingView Readiness9/10Performance8.5/10UI / UX9/10Commercial QualityVery highThis version is now genuinely close to a polished premium TradingView indicator.

## Source Code

````pine
//@version=6
// =============================================================================
// AUTO ORB ALL — AUTO MARKET OPENS
// Opening Range Breakout with Auto Session Rotation + Manual Pinning
// Pine Script v6 | Black + Gold aesthetic | B&Y RENOCORP
// =============================================================================

indicator(
     "AUTO ORB ALL  — Auto Market Opens",
     shorttitle="G13ORB",
     overlay=true,
     max_lines_count=500,
     max_labels_count=500,
     max_boxes_count=500,
     max_bars_back=1000
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 01 — MASTER SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpMaster = "⚙️ MASTER"

masterOn = input.bool(true, "Master ON/OFF", group=grpMaster)
autoMode = input.bool(true, "Auto Market Rotation ON/OFF", group=grpMaster)

sessionTZ = input.string(
     "America/New_York",
     "Timezone",
     options=[
         "America/New_York",
         "America/Toronto",
         "America/Chicago",
         "America/Los_Angeles",
         "Europe/London",
         "Asia/Tokyo",
         "Asia/Singapore",
         "UTC",
         "exchange"
     ],
     group=grpMaster
)

orbMinutes = input.int(
     15,
     "ORB Window Minutes",
     minval=1,
     maxval=240,
     group=grpMaster,
     tooltip="First X minutes of each market open define the opening range."
)

showMid = input.bool(true, "Show Mid Line", group=grpMaster)
extendLines = input.bool(true, "Extend ORB Lines Right", group=grpMaster)
showBox = input.bool(true, "Show ORB Box", group=grpMaster)
showLabels = input.bool(true, "Show Session Labels", group=grpMaster)
showBreakText = input.bool(true, "Show LONG / SHORT Text", group=grpMaster)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 02 — SIGNAL SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpSignals = "🎯 SIGNALS"

useRetest = input.bool(false, "Require Retest Confirmation", group=grpSignals)
oneSigPerSession = input.bool(true, "Only First Breakout Per Session Direction", group=grpSignals)

bullColor = input.color(color.new(#00D68F, 0), "Bullish Break Color", group=grpSignals)
bearColor = input.color(color.new(#FF4D4F, 0), "Bearish Break Color", group=grpSignals)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 03 — VISUAL STYLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpStyle = "🎨 GLOBAL STYLE"

activeHighColor = input.color(color.new(#C9A646, 0), "Active ORB High Line", group=grpStyle)
activeLowColor = input.color(color.new(#C9A646, 0), "Active ORB Low Line", group=grpStyle)
activeMidColor = input.color(color.new(#C9A646, 45), "Active ORB Mid Line", group=grpStyle)
activeFillTransp = input.int(88, "Active Box Fill Transparency", minval=0, maxval=100, group=grpStyle)

pinnedLineTransp = input.int(55, "Pinned Session Line Transparency", minval=0, maxval=100, group=grpStyle)
pinnedFillTransp = input.int(94, "Pinned Box Fill Transparency", minval=0, maxval=100, group=grpStyle)

activeLineWidth = input.int(2, "Active ORB Line Width", minval=1, maxval=5, group=grpStyle)
pinnedLineWidth = input.int(1, "Pinned ORB Line Width", minval=1, maxval=5, group=grpStyle)

highLowLineStyle = input.string("Solid", "High/Low Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)
midLineStyle = input.string("Dotted", "Mid Line Style", options=["Solid", "Dashed", "Dotted"], group=grpStyle)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 04 — SESSION CONTROLS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpAsia = "🌏 ASIA OPEN"
asiaAuto = input.bool(true, "Auto Enabled", group=grpAsia)
asiaPin = input.bool(false, "Pin On Chart", group=grpAsia)
asiaStart = input.int(2000, "Start Time HHMM", minval=0, maxval=2359, group=grpAsia)
asiaHours = input.int(8, "Active Length Hours", minval=1, maxval=24, group=grpAsia)
asiaColor = input.color(#E65100, "Session Color", group=grpAsia)

grpTokyo = "🇯🇵 TOKYO OPEN"
tokyoAuto = input.bool(false, "Auto Enabled", group=grpTokyo)
tokyoPin = input.bool(false, "Pin On Chart", group=grpTokyo)
tokyoStart = input.int(1900, "Start Time HHMM", minval=0, maxval=2359, group=grpTokyo)
tokyoHours = input.int(8, "Active Length Hours", minval=1, maxval=24, group=grpTokyo)
tokyoColor = input.color(#00838F, "Session Color", group=grpTokyo)

grpLondonPM = "🌘 LONDON PREMARKET"
lpmAuto = input.bool(false, "Auto Enabled", group=grpLondonPM)
lpmPin = input.bool(false, "Pin On Chart", group=grpLondonPM)
lpmStart = input.int(200, "Start Time HHMM", minval=0, maxval=2359, group=grpLondonPM)
lpmHours = input.int(2, "Active Length Hours", minval=1, maxval=24, group=grpLondonPM)
lpmColor = input.color(#42A5F5, "Session Color", group=grpLondonPM)

grpLondon = "🇬🇧 LONDON OPEN"
londonAuto = input.bool(true, "Auto Enabled", group=grpLondon)
londonPin = input.bool(false, "Pin On Chart", group=grpLondon)
londonStart = input.int(300, "Start Time HHMM", minval=0, maxval=2359, group=grpLondon)
londonHours = input.int(8, "Active Length Hours", minval=1, maxval=24, group=grpLondon)
londonColor = input.color(#1565C0, "Session Color", group=grpLondon)

grpNYPM = "🌅 NY PREMARKET"
nyPmAuto = input.bool(true, "Auto Enabled", group=grpNYPM)
nyPmPin = input.bool(false, "Pin On Chart", group=grpNYPM)
nyPmStart = input.int(400, "Start Time HHMM", minval=0, maxval=2359, group=grpNYPM)
nyPmHours = input.int(4, "Active Length Hours", minval=1, maxval=24, group=grpNYPM)
nyPmColor = input.color(#B0BEC5, "Session Color", group=grpNYPM)

grpGold = "🥇 GOLD / COMEX OPEN"
goldAuto = input.bool(true, "Auto Enabled", group=grpGold)
goldPin = input.bool(false, "Pin On Chart", group=grpGold)
goldStart = input.int(820, "Start Time HHMM", minval=0, maxval=2359, group=grpGold)
goldHours = input.int(3, "Active Length Hours", minval=1, maxval=24, group=grpGold)
goldColor = input.color(#FFD600, "Session Color", group=grpGold)

grpNY = "🇺🇸 NEW YORK OPEN"
nyAuto = input.bool(true, "Auto Enabled", group=grpNY)
nyPin = input.bool(false, "Pin On Chart", group=grpNY)
nyStart = input.int(930, "Start Time HHMM", minval=0, maxval=2359, group=grpNY)
nyHours = input.int(7, "Active Length Hours", minval=1, maxval=24, group=grpNY)
nyColor = input.color(#C9A646, "Session Color", group=grpNY)

grpLC = "🔔 LONDON CLOSE"
lcAuto = input.bool(false, "Auto Enabled", group=grpLC)
lcPin = input.bool(false, "Pin On Chart", group=grpLC)
lcStart = input.int(1130, "Start Time HHMM", minval=0, maxval=2359, group=grpLC)
lcHours = input.int(2, "Active Length Hours", minval=1, maxval=24, group=grpLC)
lcColor = input.color(#6A1B9A, "Session Color", group=grpLC)

grpGlobex = "🌐 FUTURES GLOBEX OPEN"
globexAuto = input.bool(false, "Auto Enabled", group=grpGlobex)
globexPin = input.bool(false, "Pin On Chart", group=grpGlobex)
globexStart = input.int(1800, "Start Time HHMM", minval=0, maxval=2359, group=grpGlobex)
globexHours = input.int(8, "Active Length Hours", minval=1, maxval=24, group=grpGlobex)
globexColor = input.color(#8E24AA, "Session Color", group=grpGlobex)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 05 — HUD SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

grpHUD = "🖥️ HUD"

showHUD = input.bool(true, "Show HUD", group=grpHUD)
hudPosition = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpHUD)

hudBgColor = input.color(color.new(#0A0A0A, 5), "HUD Background", group=grpHUD)
hudBorderColor = input.color(color.new(#C9A646, 30), "HUD Border", group=grpHUD)
hudTextColor = input.color(color.white, "HUD Text", group=grpHUD)
hudGoldColor = input.color(#C9A646, "HUD Gold Text", group=grpHUD)
hudActiveColor = input.color(color.new(#C9A646, 0), "HUD Active Highlight", group=grpHUD)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 06 — UTILITY FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tz = sessionTZ == "exchange" ? syminfo.timezone : sessionTZ

f_lineStyle(_style) =>
    switch _style
        "Solid" => line.style_solid
        "Dashed" => line.style_dashed
        "Dotted" => line.style_dotted
        => line.style_solid

f_hudPos() =>
    switch hudPosition
        "Top Right" => position.top_right
        "Top Left" => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left" => position.bottom_left
        => position.top_right

f_hhmmToMin(_hhmm) =>
    int(math.floor(_hhmm / 100)) * 60 + int(_hhmm % 100)

nowMin = hour(time, tz) * 60 + minute(time, tz)
prevMin = hour(time[1], tz) * 60 + minute(time[1], tz)

f_ageFrom(_startMin) =>
    (nowMin - _startMin + 1440) % 1440

f_prevAgeFrom(_startMin) =>
    (prevMin - _startMin + 1440) % 1440

f_isNewOpen(_startMin) =>
    curr = f_ageFrom(_startMin)
    prev = f_prevAgeFrom(_startMin)
    curr < prev or curr == 0 and prev != 0

f_isBuilding(_startMin, _mins) =>
    age = f_ageFrom(_startMin)
    age >= 0 and age < _mins

f_isActive(_startMin, _hours) =>
    age = f_ageFrom(_startMin)
    age >= 0 and age < _hours * 60

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 07 — AUTO ACTIVE MARKET SELECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

asiaMin = f_hhmmToMin(asiaStart)
tokyoMin = f_hhmmToMin(tokyoStart)
lpmMin = f_hhmmToMin(lpmStart)
londonMin = f_hhmmToMin(londonStart)
nyPmMin = f_hhmmToMin(nyPmStart)
goldMin = f_hhmmToMin(goldStart)
nyMin = f_hhmmToMin(nyStart)
lcMin = f_hhmmToMin(lcStart)
globexMin = f_hhmmToMin(globexStart)

var string activeMarket = "NONE"
var int activeCode = 0
var int activeAge = 100000

activeMarket := "NONE"
activeCode := 0
activeAge := 100000

if masterOn and autoMode
    aGlobex = f_ageFrom(globexMin)
    aTokyo = f_ageFrom(tokyoMin)
    aAsia = f_ageFrom(asiaMin)
    aLPM = f_ageFrom(lpmMin)
    aLondon = f_ageFrom(londonMin)
    aNYPM = f_ageFrom(nyPmMin)
    aGold = f_ageFrom(goldMin)
    aNY = f_ageFrom(nyMin)
    aLC = f_ageFrom(lcMin)

    if globexAuto and aGlobex < globexHours * 60 and aGlobex < activeAge
        activeAge := aGlobex
        activeMarket := "Globex"
        activeCode := 9

    if tokyoAuto and aTokyo < tokyoHours * 60 and aTokyo < activeAge
        activeAge := aTokyo
        activeMarket := "Tokyo"
        activeCode := 2

    if asiaAuto and aAsia < asiaHours * 60 and aAsia < activeAge
        activeAge := aAsia
        activeMarket := "Asia"
        activeCode := 1

    if lpmAuto and aLPM < lpmHours * 60 and aLPM < activeAge
        activeAge := aLPM
        activeMarket := "London PM"
        activeCode := 3

    if londonAuto and aLondon < londonHours * 60 and aLondon < activeAge
        activeAge := aLondon
        activeMarket := "London"
        activeCode := 4

    if nyPmAuto and aNYPM < nyPmHours * 60 and aNYPM < activeAge
        activeAge := aNYPM
        activeMarket := "NY Premarket"
        activeCode := 5

    if goldAuto and aGold < goldHours * 60 and aGold < activeAge
        activeAge := aGold
        activeMarket := "Gold"
        activeCode := 6

    if nyAuto and aNY < nyHours * 60 and aNY < activeAge
        activeAge := aNY
        activeMarket := "New York"
        activeCode := 7

    if lcAuto and aLC < lcHours * 60 and aLC < activeAge
        activeAge := aLC
        activeMarket := "London Close"
        activeCode := 8

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 08 — ORB ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_orb(_autoEnabled, _pinned, _isActive, _startMin, _hours, _name, _sessionColor) =>
    track = masterOn and (_autoEnabled or _pinned)
    display = masterOn and (_pinned or (_autoEnabled and _isActive))

    lineColorHigh = _isActive ? activeHighColor : color.new(_sessionColor, pinnedLineTransp)
    lineColorLow = _isActive ? activeLowColor : color.new(_sessionColor, pinnedLineTransp)
    lineColorMid = _isActive ? activeMidColor : color.new(_sessionColor, math.min(pinnedLineTransp + 15, 100))
    fillTransp = _isActive ? activeFillTransp : pinnedFillTransp
    lineW = _isActive ? activeLineWidth : pinnedLineWidth

    var float orbHigh = na
    var float orbLow = na
    var bool orbSet = false
    var bool longTaken = false
    var bool shortTaken = false
    var bool retestUpDone = false
    var bool retestDownDone = false

    var line hiLine = na
    var line loLine = na
    var line mdLine = na
    var box rngBox = na
    var label sessLabel = na

    newOpen = f_isNewOpen(_startMin)
    building = f_isBuilding(_startMin, orbMinutes)
    inSession = f_isActive(_startMin, _hours)

    if track and newOpen
        orbHigh := na
        orbLow := na
        orbSet := false
        longTaken := false
        shortTaken := false
        retestUpDone := false
        retestDownDone := false

        line.delete(hiLine)
        line.delete(loLine)
        line.delete(mdLine)
        box.delete(rngBox)
        label.delete(sessLabel)

        hiLine := na
        loLine := na
        mdLine := na
        rngBox := na
        sessLabel := na

    if not display
        line.delete(hiLine)
        line.delete(loLine)
        line.delete(mdLine)
        box.delete(rngBox)
        label.delete(sessLabel)

        hiLine := na
        loLine := na
        mdLine := na
        rngBox := na
        sessLabel := na

    if track and building
        orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
        orbLow := na(orbLow) ? low : math.min(orbLow, low)

    orbWindowEnd = track and not building and f_ageFrom(_startMin) >= orbMinutes and f_prevAgeFrom(_startMin) < orbMinutes

    if display and orbWindowEnd and not orbSet and not na(orbHigh) and not na(orbLow)
        orbSet := true
        mid = (orbHigh + orbLow) / 2

        hiLine := line.new(
             bar_index,
             orbHigh,
             bar_index + 1,
             orbHigh,
             extend=extendLines ? extend.right : extend.none,
             color=lineColorHigh,
             width=lineW,
             style=f_lineStyle(highLowLineStyle)
        )

        loLine := line.new(
             bar_index,
             orbLow,
             bar_index + 1,
             orbLow,
             extend=extendLines ? extend.right : extend.none,
             color=lineColorLow,
             width=lineW,
             style=f_lineStyle(highLowLineStyle)
        )

        if showMid
            mdLine := line.new(
                 bar_index,
                 mid,
                 bar_index + 1,
                 mid,
                 extend=extendLines ? extend.right : extend.none,
                 color=lineColorMid,
                 width=1,
                 style=f_lineStyle(midLineStyle)
            )

        if showBox
            rngBox := box.new(
                 bar_index,
                 orbHigh,
                 bar_index + 1,
                 orbLow,
                 extend=extendLines ? extend.right : extend.none,
                 bgcolor=color.new(_sessionColor, fillTransp),
                 border_color=color.new(_sessionColor, 80)
            )

        if showLabels
            labelText = _isActive ? _name + " ORB" : _name + " PIN"
            sessLabel := label.new(
                 bar_index,
                 orbHigh,
                 labelText,
                 style=label.style_label_down,
                 color=color.new(_sessionColor, _isActive ? 10 : 50),
                 textcolor=color.white,
                 size=size.small
            )

    if display and orbSet
        if not na(hiLine)
            line.set_color(hiLine, lineColorHigh)
            line.set_width(hiLine, lineW)

        if not na(loLine)
            line.set_color(loLine, lineColorLow)
            line.set_width(loLine, lineW)

        if not na(mdLine)
            line.set_color(mdLine, lineColorMid)

        if not na(rngBox)
            box.set_bgcolor(rngBox, color.new(_sessionColor, fillTransp))
            box.set_border_color(rngBox, color.new(_sessionColor, 80))

    if track and orbSet and inSession
        if low <= orbHigh and high >= orbHigh
            retestUpDone := true

        if high >= orbLow and low <= orbLow
            retestDownDone := true

    bullRaw = track and display and orbSet and inSession and close > orbHigh and close[1] <= orbHigh
    bearRaw = track and display and orbSet and inSession and close < orbLow and close[1] >= orbLow

    bullCond = bullRaw and (not useRetest or retestUpDone)
    bearCond = bearRaw and (not useRetest or retestDownDone)

    if oneSigPerSession
        bullCond := bullCond and not longTaken
        bearCond := bearCond and not shortTaken

    if bullCond
        longTaken := true

    if bearCond
        shortTaken := true

    rangeVal = orbSet ? orbHigh - orbLow : na
    status = not track ? "OFF" : building ? "BUILDING" : orbSet ? "SET" : "WAITING"

    [bullCond, bearCond, orbSet, orbHigh, orbLow, rangeVal, status]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 09 — SESSION ENGINE CALLS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[asiaBull, asiaBear, asiaSet, asiaHigh, asiaLow, asiaRange, asiaStatus] = f_orb(asiaAuto, asiaPin, activeCode == 1, asiaMin, asiaHours, "Asia", asiaColor)
[tokyoBull, tokyoBear, tokyoSet, tokyoHigh, tokyoLow, tokyoRange, tokyoStatus] = f_orb(tokyoAuto, tokyoPin, activeCode == 2, tokyoMin, tokyoHours, "Tokyo", tokyoColor)
[lpmBull, lpmBear, lpmSet, lpmHigh, lpmLow, lpmRange, lpmStatus] = f_orb(lpmAuto, lpmPin, activeCode == 3, lpmMin, lpmHours, "London PM", lpmColor)
[londonBull, londonBear, londonSet, londonHigh, londonLow, londonRange, londonStatus] = f_orb(londonAuto, londonPin, activeCode == 4, londonMin, londonHours, "London", londonColor)
[nyPmBull, nyPmBear, nyPmSet, nyPmHigh, nyPmLow, nyPmRange, nyPmStatus] = f_orb(nyPmAuto, nyPmPin, activeCode == 5, nyPmMin, nyPmHours, "NY PM", nyPmColor)
[goldBull, goldBear, goldSet, goldHigh, goldLow, goldRange, goldStatus] = f_orb(goldAuto, goldPin, activeCode == 6, goldMin, goldHours, "Gold", goldColor)
[nyBull, nyBear, nySet, nyHigh, nyLow, nyRange, nyStatus] = f_orb(nyAuto, nyPin, activeCode == 7, nyMin, nyHours, "NY", nyColor)
[lcBull, lcBear, lcSet, lcHigh, lcLow, lcRange, lcStatus] = f_orb(lcAuto, lcPin, activeCode == 8, lcMin, lcHours, "London Close", lcColor)
[globexBull, globexBear, globexSet, globexHigh, globexLow, globexRange, globexStatus] = f_orb(globexAuto, globexPin, activeCode == 9, globexMin, globexHours, "Globex", globexColor)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 10 — GLOBAL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

anyBull = asiaBull or tokyoBull or lpmBull or londonBull or nyPmBull or goldBull or nyBull or lcBull or globexBull
anyBear = asiaBear or tokyoBear or lpmBear or londonBear or nyPmBear or goldBear or nyBear or lcBear or globexBear

plotshape(
     anyBull and showBreakText,
     title="G13 ORB Long Break Text",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     size=size.small,
     text="LONG",
     textcolor=color.white
)

plotshape(
     anyBull and not showBreakText,
     title="G13 ORB Long Break",
     style=shape.triangleup,
     location=location.belowbar,
     color=bullColor,
     size=size.small
)

plotshape(
     anyBear and showBreakText,
     title="G13 ORB Short Break Text",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     size=size.small,
     text="SHORT",
     textcolor=color.white
)

plotshape(
     anyBear and not showBreakText,
     title="G13 ORB Short Break",
     style=shape.triangledown,
     location=location.abovebar,
     color=bearColor,
     size=size.small
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 11 — ACTIVE VALUES FOR HUD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

activeHigh =
     activeCode == 1 ? asiaHigh :
     activeCode == 2 ? tokyoHigh :
     activeCode == 3 ? lpmHigh :
     activeCode == 4 ? londonHigh :
     activeCode == 5 ? nyPmHigh :
     activeCode == 6 ? goldHigh :
     activeCode == 7 ? nyHigh :
     activeCode == 8 ? lcHigh :
     activeCode == 9 ? globexHigh :
     na

activeLow =
     activeCode == 1 ? asiaLow :
     activeCode == 2 ? tokyoLow :
     activeCode == 3 ? lpmLow :
     activeCode == 4 ? londonLow :
     activeCode == 5 ? nyPmLow :
     activeCode == 6 ? goldLow :
     activeCode == 7 ? nyLow :
     activeCode == 8 ? lcLow :
     activeCode == 9 ? globexLow :
     na

activeRange =
     activeCode == 1 ? asiaRange :
     activeCode == 2 ? tokyoRange :
     activeCode == 3 ? lpmRange :
     activeCode == 4 ? londonRange :
     activeCode == 5 ? nyPmRange :
     activeCode == 6 ? goldRange :
     activeCode == 7 ? nyRange :
     activeCode == 8 ? lcRange :
     activeCode == 9 ? globexRange :
     na

activeStatus =
     activeCode == 1 ? asiaStatus :
     activeCode == 2 ? tokyoStatus :
     activeCode == 3 ? lpmStatus :
     activeCode == 4 ? londonStatus :
     activeCode == 5 ? nyPmStatus :
     activeCode == 6 ? goldStatus :
     activeCode == 7 ? nyStatus :
     activeCode == 8 ? lcStatus :
     activeCode == 9 ? globexStatus :
     "WAITING"

pinnedCount =
     (asiaPin ? 1 : 0) +
     (tokyoPin ? 1 : 0) +
     (lpmPin ? 1 : 0) +
     (londonPin ? 1 : 0) +
     (nyPmPin ? 1 : 0) +
     (goldPin ? 1 : 0) +
     (nyPin ? 1 : 0) +
     (lcPin ? 1 : 0) +
     (globexPin ? 1 : 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 12 — HUD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table hud = table.new(
     f_hudPos(),
     2,
     7,
     bgcolor=hudBgColor,
     border_color=hudBorderColor,
     border_width=1
)

if masterOn and showHUD and barstate.islast
    table.cell(hud, 0, 0, "G13 AUTO ORB", text_color=hudGoldColor, text_size=size.small, bgcolor=color.black)
    table.cell(hud, 1, 0, activeMarket, text_color=color.black, text_size=size.small, bgcolor=hudActiveColor)

    table.cell(hud, 0, 1, "Status", text_color=hudTextColor, text_size=size.tiny)
    table.cell(hud, 1, 1, activeStatus, text_color=hudGoldColor, text_size=size.tiny)

    table.cell(hud, 0, 2, "ORB Window", text_color=hudTextColor, text_size=size.tiny)
    table.cell(hud, 1, 2, str.tostring(orbMinutes) + "m", text_color=hudGoldColor, text_size=size.tiny)

    table.cell(hud, 0, 3, "High", text_color=hudTextColor, text_size=size.tiny)
    table.cell(hud, 1, 3, na(activeHigh) ? "—" : str.tostring(activeHigh, format.mintick), text_color=hudTextColor, text_size=size.tiny)

    table.cell(hud, 0, 4, "Low", text_color=hudTextColor, text_size=size.tiny)
    table.cell(hud, 1, 4, na(activeLow) ? "—" : str.tostring(activeLow, format.mintick), text_color=hudTextColor, text_size=size.tiny)

    table.cell(hud, 0, 5, "Range", text_color=hudTextColor, text_size=size.tiny)
    table.cell(hud, 1, 5, na(activeRange) ? "—" : str.tostring(activeRange, format.mintick), text_color=hudTextColor, text_size=size.tiny)

    table.cell(hud, 0, 6, "Pinned", text_color=hudTextColor, text_size=size.tiny)
    table.cell(hud, 1, 6, str.tostring(pinnedCount), text_color=hudGoldColor, text_size=size.tiny)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 13 — ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     anyBull,
     title="G13 ORB Long Breakout",
     message="G13 Auto ORB | LONG breakout on {{ticker}} {{interval}}"
)

alertcondition(
     anyBear,
     title="G13 ORB Short Breakout",
     message="G13 Auto ORB | SHORT breakout on {{ticker}} {{interval}}"
)
````
