<!-- tradingview-pine-id: PUB;edbee32b8a69456b9a72aff6c7e0e4d2 -->
<!-- tradingviewscripts-format: 1 -->
# Long/Short Trade Dashboard v4 - Entry Signals

Source: https://www.tradingview.com/script/m5I7O8zO-BEC-MACHINE/

## Description

The literal bacon egg and cheese machine. Do you like bacon and eggs? Sometimes cheese even though it makes you feel bad? Download this script and all your bacon and egg dreams will come true.

---

## Source Code

````pine
//@version=6
indicator("Long/Short Trade Dashboard v4 - Entry Signals", shorttitle = "TradeDash4", overlay = true, dynamic_requests = true)

//=============================================================================
// INPUTS
//=============================================================================

string GROUP_DAILY  = "Daily Settings"
string GROUP_ENTRY  = "Entry Signal"
string GROUP_ALERTS = "Alerts"
string GROUP_LAYOUT = "Dashboard Layout"

string esSymbol = input.symbol(
     "CME_MINI:ES1!",
     "ES continuous symbol",
     group = GROUP_DAILY
)

float smashLevel = input.float(
     0.00,
     "ES Smashlevel",
     minval = 0.00,
     step = 0.25,
     group = GROUP_DAILY,
     tooltip = "Update this level manually each trading day."
)

int entryAtrLength = input.int(
     14,
     "5-minute ATR length",
     minval = 1,
     group = GROUP_ENTRY
)

float maxSupportDistanceAtr = input.float(
     0.40,
     "Maximum support/resistance distance (ATR)",
     minval = 0.05,
     step = 0.05,
     group = GROUP_ENTRY,
     tooltip = "At least one eligible support or resistance must be within this distance."
)

float touchBufferAtr = input.float(
     0.10,
     "Support/resistance touch buffer (ATR)",
     minval = 0.00,
     step = 0.05,
     group = GROUP_ENTRY,
     tooltip = "A candle can count as interacting when its low/high comes this close to support/resistance."
)

float maxUndercutAtr = input.float(
     0.15,
     "Maximum support undercut/resistance break (ATR)",
     minval = 0.00,
     step = 0.05,
     group = GROUP_ENTRY,
     tooltip = "A deeper support undercut or resistance breakout disqualifies the entry."
)

float confluenceDistanceAtr = input.float(
     0.20,
     "Support/resistance confluence distance (ATR)",
     minval = 0.00,
     step = 0.05,
     group = GROUP_ENTRY
)

float fullVwapScoreDistanceAtr = input.float(
     0.50,
     "Full VWAP extension score through (ATR)",
     minval = 0.00,
     step = 0.05,
     group = GROUP_ENTRY
)

float hardVwapExtensionAtr = input.float(
     1.00,
     "Hard VWAP extension limit (ATR)",
     minval = 0.10,
     step = 0.05,
     group = GROUP_ENTRY,
     tooltip = "No long can be approved too far above VWAP and no short can be approved too far below VWAP."
)

int watchScoreThreshold = input.int(
     60,
     "WATCH score threshold",
     minval = 0,
     maxval = 100,
     group = GROUP_ENTRY
)

int approvalScoreThreshold = input.int(
     80,
     "APPROVED score threshold",
     minval = 0,
     maxval = 100,
     group = GROUP_ENTRY
)

bool enableSetupAlerts = input.bool(
     true,
     "Enable 70+ setup-forming alerts",
     group = GROUP_ALERTS,
     tooltip = "Intrabar warning when either the long or short five-condition filter is complete, no hard disqualifier is active, and its live five-minute score reaches the selected threshold."
)

int setupAlertScore = input.int(
     70,
     "Setup-forming alert score",
     minval = 0,
     maxval = 100,
     group = GROUP_ALERTS
)

bool enableApprovedAlerts = input.bool(
     true,
     "Enable confirmed-entry alerts",
     group = GROUP_ALERTS,
     tooltip = "Confirmed alert when a five-minute candle closes with the setup fully approved."
)

int confirmedAlertScore = input.int(
     80,
     "Confirmed-entry alert score",
     minval = 0,
     maxval = 100,
     group = GROUP_ALERTS,
     tooltip = "The setup must also pass the stricter APPROVED entry rules. A value below the APPROVED threshold will not loosen those rules."
)

string dashboardLayout = input.string(
     "Desktop",
     "Layout",
     options = ["Desktop", "Mobile"],
     group = GROUP_LAYOUT,
     tooltip = "Desktop displays the dashboard at the top-right. Mobile displays it at the top-center."
)

bool showLiveValues = input.bool(
     true,
     "Show live values",
     group = GROUP_LAYOUT
)

//=============================================================================
// SESSION SETTINGS
//=============================================================================

string TIMEZONE        = "America/New_York"
string TRADE_SESSION   = "1000-1600:23456"
string ENTRY_TIMEFRAME = "5"

bool intradayChart =
     timeframe.isintraday

bool inRegularSession =
     intradayChart and
     session.ismarket

bool newRegularSession =
     intradayChart and
     session.isfirstbar_regular

bool tradingAllowed =
     intradayChart and
     not na(time(timeframe.period, TRADE_SESSION, TIMEZONE))

int newYorkDate =
     year(time, TIMEZONE) * 10000 +
     month(time, TIMEZONE) * 100 +
     dayofmonth(time, TIMEZONE)

bool newCalendarDay =
     bar_index == 0 or
     newYorkDate != newYorkDate[1]

//=============================================================================
// ENTRY HELPER FUNCTIONS
//=============================================================================

f_zone_distance(
     float price,
     float zoneTop,
     float zoneBottom
) =>
    price > zoneTop
     ? price - zoneTop
     : price < zoneBottom
     ? zoneBottom - price
     : 0.0

f_zone_gap(
     float firstTop,
     float firstBottom,
     float secondTop,
     float secondBottom
) =>
    firstTop < secondBottom
     ? secondBottom - firstTop
     : secondTop < firstBottom
     ? firstBottom - secondTop
     : 0.0

//=============================================================================
// FIXED 5-MINUTE ENTRY ENGINE
//=============================================================================

f_five_minute_entry_engine() =>
    //--------------------------------------------------------------------------
    // Five-minute session state
    //--------------------------------------------------------------------------

    bool engineInRegularSession =
         session.ismarket

    bool engineNewRegularSession =
         session.isfirstbar_regular

    bool engineTradingAllowed =
         not na(time(timeframe.period, TRADE_SESSION, TIMEZONE))

    int engineNewYorkDate =
         year(time, TIMEZONE) * 10000 +
         month(time, TIMEZONE) * 100 +
         dayofmonth(time, TIMEZONE)

    bool engineNewCalendarDay =
         bar_index == 0 or
         engineNewYorkDate != engineNewYorkDate[1]

    //--------------------------------------------------------------------------
    // Fixed 10-minute Ripster 8/9 EMA cloud
    //--------------------------------------------------------------------------

    float engineEma8TenMinute = request.security(
         syminfo.tickerid,
         "10",
         ta.ema(hl2, 8),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
    )

    float engineEma9TenMinute = request.security(
         syminfo.tickerid,
         "10",
         ta.ema(hl2, 9),
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
    )

    bool engineCloudAvailable =
         not na(engineEma8TenMinute) and
         not na(engineEma9TenMinute)

    bool engineCloudBullish =
         engineCloudAvailable and
         engineEma8TenMinute >= engineEma9TenMinute

    bool engineCloudBearish =
         engineCloudAvailable and
         engineEma8TenMinute < engineEma9TenMinute

    //--------------------------------------------------------------------------
    // 9:30 regular-session open
    //--------------------------------------------------------------------------

    var float engineRegularSessionOpen = na

    if engineNewCalendarDay
        engineRegularSessionOpen := na

    if engineNewRegularSession
        engineRegularSessionOpen := open

    bool engineOpenAvailable =
         engineInRegularSession and
         not na(engineRegularSessionOpen)

    bool engineAboveOpeningLevel =
         engineOpenAvailable and
         close >= engineRegularSessionOpen

    bool engineBelowOpeningLevel =
         engineOpenAvailable and
         close <= engineRegularSessionOpen

    //--------------------------------------------------------------------------
    // Persistent regular-session VWAP calculated on five-minute bars
    //--------------------------------------------------------------------------

    var float engineCumulativePriceVolume = na
    var float engineCumulativeVolume = na

    float engineCurrentBarVolume =
         nz(volume, 0.0)

    if engineNewRegularSession
        engineCumulativePriceVolume :=
             hlc3 * engineCurrentBarVolume

        engineCumulativeVolume :=
             engineCurrentBarVolume

    else if engineInRegularSession
        engineCumulativePriceVolume :=
             nz(engineCumulativePriceVolume, 0.0) +
             hlc3 * engineCurrentBarVolume

        engineCumulativeVolume :=
             nz(engineCumulativeVolume, 0.0) +
             engineCurrentBarVolume

    float engineRegularSessionVWAP =
         not na(engineCumulativeVolume) and
         engineCumulativeVolume > 0
         ? engineCumulativePriceVolume /
           engineCumulativeVolume
         : na

    bool engineVwapAvailable =
         not na(engineRegularSessionVWAP)

    bool engineAboveVWAP =
         engineVwapAvailable and
         close >= engineRegularSessionVWAP

    bool engineBelowVWAP =
         engineVwapAvailable and
         close <= engineRegularSessionVWAP

    //--------------------------------------------------------------------------
    // ES above Smashlevel
    //--------------------------------------------------------------------------

    float engineEsPrice = request.security(
         esSymbol,
         ENTRY_TIMEFRAME,
         close,
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off
    )

    bool engineSmashlevelEntered =
         smashLevel > 0

    bool engineEsAvailable =
         engineSmashlevelEntered and
         not na(engineEsPrice)

    bool engineEsAboveSmashlevel =
         engineEsAvailable and
         engineEsPrice >= smashLevel

    bool engineEsBelowSmashlevel =
         engineEsAvailable and
         engineEsPrice <= smashLevel

    //--------------------------------------------------------------------------
    // Five-condition directional qualification used by the entry engine
    //--------------------------------------------------------------------------

    bool engineAllLongConditions =
         engineTradingAllowed and
         engineCloudBullish and
         engineAboveOpeningLevel and
         engineAboveVWAP and
         engineEsAboveSmashlevel

    bool engineAllShortConditions =
         engineTradingAllowed and
         engineCloudBearish and
         engineBelowOpeningLevel and
         engineBelowVWAP and
         engineEsBelowSmashlevel

    //--------------------------------------------------------------------------
    // Five-minute entry data
    //--------------------------------------------------------------------------

    float ema8FiveMinute =
         ta.ema(hl2, 8)

    float ema9FiveMinute =
         ta.ema(hl2, 9)

    float atrFiveMinute =
         ta.atr(entryAtrLength)

    float fiveMinuteCloudTop =
         math.max(ema8FiveMinute, ema9FiveMinute)

    float fiveMinuteCloudBottom =
         math.min(ema8FiveMinute, ema9FiveMinute)

    float tenMinuteCloudTop =
         math.max(
              engineEma8TenMinute,
              engineEma9TenMinute
         )

    float tenMinuteCloudBottom =
         math.min(
              engineEma8TenMinute,
              engineEma9TenMinute
         )

    bool atrAvailable =
         not na(atrFiveMinute) and
         atrFiveMinute > 0

    bool fiveMinuteCloudAvailable =
         not na(ema8FiveMinute) and
         not na(ema9FiveMinute)

    bool fiveMinuteCloudBullish =
         fiveMinuteCloudAvailable and
         ema8FiveMinute >= ema9FiveMinute

    bool fiveMinuteCloudBearish =
         fiveMinuteCloudAvailable and
         ema8FiveMinute < ema9FiveMinute

    bool entryDataAvailable =
         atrAvailable and
         engineCloudAvailable and
         engineVwapAvailable

    //--------------------------------------------------------------------------
    // Eligible supports
    //--------------------------------------------------------------------------

    bool fiveMinuteSupportEligible =
         entryDataAvailable and
         fiveMinuteCloudBullish

    bool vwapSupportEligible =
         entryDataAvailable

    bool tenMinuteSupportEligible =
         entryDataAvailable and
         engineCloudBullish

    float fiveMinuteDistanceAtr =
         fiveMinuteSupportEligible
         ? f_zone_distance(
              close,
              fiveMinuteCloudTop,
              fiveMinuteCloudBottom
           ) / atrFiveMinute
         : na

    float vwapDistanceAtr =
         vwapSupportEligible
         ? math.abs(
              close - engineRegularSessionVWAP
           ) / atrFiveMinute
         : na

    float tenMinuteDistanceAtr =
         tenMinuteSupportEligible
         ? f_zone_distance(
              close,
              tenMinuteCloudTop,
              tenMinuteCloudBottom
           ) / atrFiveMinute
         : na

    //--------------------------------------------------------------------------
    // Nearest support selection
    //--------------------------------------------------------------------------

    int bestSupportCode =
         0

    float bestSupportDistanceAtr =
         na

    float selectedSupportTop =
         na

    float selectedSupportBottom =
         na

    float previousSupportTop =
         na

    float previousSupportBottom =
         na

    // Priority for exact ties:
    // 1 = 5M cloud, 2 = VWAP, 3 = 10M cloud.

    if fiveMinuteSupportEligible
        bestSupportCode :=
             1

        bestSupportDistanceAtr :=
             fiveMinuteDistanceAtr

        selectedSupportTop :=
             fiveMinuteCloudTop

        selectedSupportBottom :=
             fiveMinuteCloudBottom

        previousSupportTop :=
             fiveMinuteCloudTop[1]

        previousSupportBottom :=
             fiveMinuteCloudBottom[1]

    if vwapSupportEligible and
       (
            na(bestSupportDistanceAtr) or
            vwapDistanceAtr < bestSupportDistanceAtr
       )

        bestSupportCode :=
             2

        bestSupportDistanceAtr :=
             vwapDistanceAtr

        selectedSupportTop :=
             engineRegularSessionVWAP

        selectedSupportBottom :=
             engineRegularSessionVWAP

        previousSupportTop :=
             engineRegularSessionVWAP[1]

        previousSupportBottom :=
             engineRegularSessionVWAP[1]

    if tenMinuteSupportEligible and
       (
            na(bestSupportDistanceAtr) or
            tenMinuteDistanceAtr < bestSupportDistanceAtr
       )

        bestSupportCode :=
             3

        bestSupportDistanceAtr :=
             tenMinuteDistanceAtr

        selectedSupportTop :=
             tenMinuteCloudTop

        selectedSupportBottom :=
             tenMinuteCloudBottom

        previousSupportTop :=
             tenMinuteCloudTop[1]

        previousSupportBottom :=
             tenMinuteCloudBottom[1]

    bool supportFound =
         bestSupportCode != 0 and
         not na(bestSupportDistanceAtr) and
         not na(selectedSupportTop) and
         not na(selectedSupportBottom)

    bool supportNearby =
         supportFound and
         bestSupportDistanceAtr <=
         maxSupportDistanceAtr

    //--------------------------------------------------------------------------
    // Support interaction
    //--------------------------------------------------------------------------

    float touchBufferPrice =
         atrAvailable
         ? touchBufferAtr * atrFiveMinute
         : na

    float previousTouchBufferPrice =
         atrAvailable and
         not na(atrFiveMinute[1])
         ? touchBufferAtr * atrFiveMinute[1]
         : na

    bool currentSupportTouch =
         supportFound and
         not na(touchBufferPrice) and
         low <= selectedSupportTop +
         touchBufferPrice

    bool previousSupportTouch =
         supportFound and
         not na(previousSupportTop) and
         not na(previousTouchBufferPrice) and
         low[1] <= previousSupportTop +
         previousTouchBufferPrice

    bool recentSupportTouch =
         currentSupportTouch or
         previousSupportTouch

    bool priceAboveSelectedSupport =
         supportFound and
         close >= selectedSupportTop

    bool bullishReclaimResponse =
         priceAboveSelectedSupport and
         close > open

    //--------------------------------------------------------------------------
    // Support failure
    //--------------------------------------------------------------------------

    float maxUndercutPrice =
         atrAvailable
         ? maxUndercutAtr * atrFiveMinute
         : na

    float previousMaxUndercutPrice =
         atrAvailable and
         not na(atrFiveMinute[1])
         ? maxUndercutAtr * atrFiveMinute[1]
         : na

    bool currentSupportFailure =
         supportFound and
         not na(maxUndercutPrice) and
         low < selectedSupportBottom -
         maxUndercutPrice

    bool previousSupportFailure =
         supportFound and
         not na(previousSupportBottom) and
         not na(previousMaxUndercutPrice) and
         low[1] < previousSupportBottom -
         previousMaxUndercutPrice

    bool supportFailure =
         currentSupportFailure or
         previousSupportFailure

    //--------------------------------------------------------------------------
    // VWAP extension
    //--------------------------------------------------------------------------

    float vwapExtensionAtr =
         entryDataAvailable
         ? (close - engineRegularSessionVWAP) /
           atrFiveMinute
         : na

    bool controlledVwapExtension =
         not na(vwapExtensionAtr) and
         vwapExtensionAtr <=
         fullVwapScoreDistanceAtr

    bool excessiveVwapExtension =
         not na(vwapExtensionAtr) and
         vwapExtensionAtr >
         hardVwapExtensionAtr

    //--------------------------------------------------------------------------
    // Support confluence
    //--------------------------------------------------------------------------

    bool supportConfluence =
         false

    if supportFound
        if bestSupportCode != 1 and
           fiveMinuteSupportEligible

            float gapToFiveMinute =
                 f_zone_gap(
                      selectedSupportTop,
                      selectedSupportBottom,
                      fiveMinuteCloudTop,
                      fiveMinuteCloudBottom
                 ) / atrFiveMinute

            supportConfluence :=
                 supportConfluence or
                 gapToFiveMinute <=
                 confluenceDistanceAtr

        if bestSupportCode != 2 and
           vwapSupportEligible

            float gapToVwap =
                 f_zone_gap(
                      selectedSupportTop,
                      selectedSupportBottom,
                      engineRegularSessionVWAP,
                      engineRegularSessionVWAP
                 ) / atrFiveMinute

            supportConfluence :=
                 supportConfluence or
                 gapToVwap <=
                 confluenceDistanceAtr

        if bestSupportCode != 3 and
           tenMinuteSupportEligible

            float gapToTenMinute =
                 f_zone_gap(
                      selectedSupportTop,
                      selectedSupportBottom,
                      tenMinuteCloudTop,
                      tenMinuteCloudBottom
                 ) / atrFiveMinute

            supportConfluence :=
                 supportConfluence or
                 gapToTenMinute <=
                 confluenceDistanceAtr

    //--------------------------------------------------------------------------
    // 100-point entry score
    //--------------------------------------------------------------------------

    int locationPoints =
         not supportNearby
         ? 0
         : bestSupportDistanceAtr <= 0.10
         ? 40
         : bestSupportDistanceAtr <= 0.20
         ? 30
         : bestSupportDistanceAtr <= 0.30
         ? 20
         : 10

    int interactionPoints =
         recentSupportTouch
         ? 15
         : 0

    int responsePoints =
         bullishReclaimResponse
         ? 15
         : 0

    int fiveMinuteTrendPoints =
         fiveMinuteCloudBullish
         ? 15
         : 0

    int confluencePoints =
         supportConfluence
         ? 10
         : 0

    int vwapExtensionPoints =
         controlledVwapExtension
         ? 5
         : 0

    int engineEntryScore =
         locationPoints +
         interactionPoints +
         responsePoints +
         fiveMinuteTrendPoints +
         confluencePoints +
         vwapExtensionPoints

    //--------------------------------------------------------------------------
    // Long entry qualification logic
    //--------------------------------------------------------------------------

    bool engineEntryDisqualified =
         not engineAllLongConditions or
         not entryDataAvailable or
         excessiveVwapExtension or
         not supportNearby or
         supportFailure

    bool engineEntryApproved =
         not engineEntryDisqualified and
         engineEntryScore >= approvalScoreThreshold and
         recentSupportTouch and
         bullishReclaimResponse

    bool engineEntryWatch =
         not engineEntryDisqualified and
         not engineEntryApproved and
         engineEntryScore >= watchScoreThreshold

    //--------------------------------------------------------------------------
    // Eligible resistances for short entries
    //--------------------------------------------------------------------------

    bool fiveMinuteResistanceEligible =
         entryDataAvailable and
         fiveMinuteCloudBearish

    bool vwapResistanceEligible =
         entryDataAvailable

    bool tenMinuteResistanceEligible =
         entryDataAvailable and
         engineCloudBearish

    float fiveMinuteResistanceDistanceAtr =
         fiveMinuteResistanceEligible
         ? f_zone_distance(
              close,
              fiveMinuteCloudTop,
              fiveMinuteCloudBottom
           ) / atrFiveMinute
         : na

    float vwapResistanceDistanceAtr =
         vwapResistanceEligible
         ? math.abs(
              close - engineRegularSessionVWAP
           ) / atrFiveMinute
         : na

    float tenMinuteResistanceDistanceAtr =
         tenMinuteResistanceEligible
         ? f_zone_distance(
              close,
              tenMinuteCloudTop,
              tenMinuteCloudBottom
           ) / atrFiveMinute
         : na

    //--------------------------------------------------------------------------
    // Nearest resistance selection
    //--------------------------------------------------------------------------

    int bestResistanceCode =
         0

    float bestResistanceDistanceAtr =
         na

    float selectedResistanceTop =
         na

    float selectedResistanceBottom =
         na

    float previousResistanceTop =
         na

    float previousResistanceBottom =
         na

    // Priority for exact ties:
    // 1 = 5M cloud, 2 = VWAP, 3 = 10M cloud.

    if fiveMinuteResistanceEligible
        bestResistanceCode :=
             1

        bestResistanceDistanceAtr :=
             fiveMinuteResistanceDistanceAtr

        selectedResistanceTop :=
             fiveMinuteCloudTop

        selectedResistanceBottom :=
             fiveMinuteCloudBottom

        previousResistanceTop :=
             fiveMinuteCloudTop[1]

        previousResistanceBottom :=
             fiveMinuteCloudBottom[1]

    if vwapResistanceEligible and
       (
            na(bestResistanceDistanceAtr) or
            vwapResistanceDistanceAtr < bestResistanceDistanceAtr
       )

        bestResistanceCode :=
             2

        bestResistanceDistanceAtr :=
             vwapResistanceDistanceAtr

        selectedResistanceTop :=
             engineRegularSessionVWAP

        selectedResistanceBottom :=
             engineRegularSessionVWAP

        previousResistanceTop :=
             engineRegularSessionVWAP[1]

        previousResistanceBottom :=
             engineRegularSessionVWAP[1]

    if tenMinuteResistanceEligible and
       (
            na(bestResistanceDistanceAtr) or
            tenMinuteResistanceDistanceAtr < bestResistanceDistanceAtr
       )

        bestResistanceCode :=
             3

        bestResistanceDistanceAtr :=
             tenMinuteResistanceDistanceAtr

        selectedResistanceTop :=
             tenMinuteCloudTop

        selectedResistanceBottom :=
             tenMinuteCloudBottom

        previousResistanceTop :=
             tenMinuteCloudTop[1]

        previousResistanceBottom :=
             tenMinuteCloudBottom[1]

    bool resistanceFound =
         bestResistanceCode != 0 and
         not na(bestResistanceDistanceAtr) and
         not na(selectedResistanceTop) and
         not na(selectedResistanceBottom)

    bool resistanceNearby =
         resistanceFound and
         bestResistanceDistanceAtr <=
         maxSupportDistanceAtr

    //--------------------------------------------------------------------------
    // Resistance interaction and bearish rejection
    //--------------------------------------------------------------------------

    bool currentResistanceTouch =
         resistanceFound and
         not na(touchBufferPrice) and
         high >= selectedResistanceBottom -
         touchBufferPrice

    bool previousResistanceTouch =
         resistanceFound and
         not na(previousResistanceBottom) and
         not na(previousTouchBufferPrice) and
         high[1] >= previousResistanceBottom -
         previousTouchBufferPrice

    bool recentResistanceTouch =
         currentResistanceTouch or
         previousResistanceTouch

    bool priceBelowSelectedResistance =
         resistanceFound and
         close <= selectedResistanceBottom

    bool bearishRejectionResponse =
         priceBelowSelectedResistance and
         close < open

    //--------------------------------------------------------------------------
    // Resistance failure
    //--------------------------------------------------------------------------

    bool currentResistanceFailure =
         resistanceFound and
         not na(maxUndercutPrice) and
         high > selectedResistanceTop +
         maxUndercutPrice

    bool previousResistanceFailure =
         resistanceFound and
         not na(previousResistanceTop) and
         not na(previousMaxUndercutPrice) and
         high[1] > previousResistanceTop +
         previousMaxUndercutPrice

    bool resistanceFailure =
         currentResistanceFailure or
         previousResistanceFailure

    //--------------------------------------------------------------------------
    // Downside VWAP extension
    //--------------------------------------------------------------------------

    float shortVwapExtensionAtr =
         entryDataAvailable
         ? (engineRegularSessionVWAP - close) /
           atrFiveMinute
         : na

    bool controlledShortVwapExtension =
         not na(shortVwapExtensionAtr) and
         shortVwapExtensionAtr <=
         fullVwapScoreDistanceAtr

    bool excessiveShortVwapExtension =
         not na(shortVwapExtensionAtr) and
         shortVwapExtensionAtr >
         hardVwapExtensionAtr

    //--------------------------------------------------------------------------
    // Resistance confluence
    //--------------------------------------------------------------------------

    bool resistanceConfluence =
         false

    if resistanceFound
        if bestResistanceCode != 1 and
           fiveMinuteResistanceEligible

            float gapToFiveMinuteResistance =
                 f_zone_gap(
                      selectedResistanceTop,
                      selectedResistanceBottom,
                      fiveMinuteCloudTop,
                      fiveMinuteCloudBottom
                 ) / atrFiveMinute

            resistanceConfluence :=
                 resistanceConfluence or
                 gapToFiveMinuteResistance <=
                 confluenceDistanceAtr

        if bestResistanceCode != 2 and
           vwapResistanceEligible

            float gapToVwapResistance =
                 f_zone_gap(
                      selectedResistanceTop,
                      selectedResistanceBottom,
                      engineRegularSessionVWAP,
                      engineRegularSessionVWAP
                 ) / atrFiveMinute

            resistanceConfluence :=
                 resistanceConfluence or
                 gapToVwapResistance <=
                 confluenceDistanceAtr

        if bestResistanceCode != 3 and
           tenMinuteResistanceEligible

            float gapToTenMinuteResistance =
                 f_zone_gap(
                      selectedResistanceTop,
                      selectedResistanceBottom,
                      tenMinuteCloudTop,
                      tenMinuteCloudBottom
                 ) / atrFiveMinute

            resistanceConfluence :=
                 resistanceConfluence or
                 gapToTenMinuteResistance <=
                 confluenceDistanceAtr

    //--------------------------------------------------------------------------
    // Mirrored 100-point short entry score
    //--------------------------------------------------------------------------

    int shortLocationPoints =
         not resistanceNearby
         ? 0
         : bestResistanceDistanceAtr <= 0.10
         ? 40
         : bestResistanceDistanceAtr <= 0.20
         ? 30
         : bestResistanceDistanceAtr <= 0.30
         ? 20
         : 10

    int shortInteractionPoints =
         recentResistanceTouch
         ? 15
         : 0

    int shortResponsePoints =
         bearishRejectionResponse
         ? 15
         : 0

    int shortFiveMinuteTrendPoints =
         fiveMinuteCloudBearish
         ? 15
         : 0

    int shortConfluencePoints =
         resistanceConfluence
         ? 10
         : 0

    int shortVwapExtensionPoints =
         controlledShortVwapExtension
         ? 5
         : 0

    int engineShortEntryScore =
         shortLocationPoints +
         shortInteractionPoints +
         shortResponsePoints +
         shortFiveMinuteTrendPoints +
         shortConfluencePoints +
         shortVwapExtensionPoints

    //--------------------------------------------------------------------------
    // Short entry qualification logic
    //--------------------------------------------------------------------------

    bool engineShortEntryDisqualified =
         not engineAllShortConditions or
         not entryDataAvailable or
         excessiveShortVwapExtension or
         not resistanceNearby or
         resistanceFailure

    bool engineShortEntryApproved =
         not engineShortEntryDisqualified and
         engineShortEntryScore >= approvalScoreThreshold and
         recentResistanceTouch and
         bearishRejectionResponse

    bool engineShortEntryWatch =
         not engineShortEntryDisqualified and
         not engineShortEntryApproved and
         engineShortEntryScore >= watchScoreThreshold

    [engineRegularSessionVWAP, engineEntryScore, bestSupportCode, bestSupportDistanceAtr, engineEntryDisqualified, engineEntryApproved, engineEntryWatch, engineShortEntryScore, bestResistanceCode, bestResistanceDistanceAtr, engineShortEntryDisqualified, engineShortEntryApproved, engineShortEntryWatch]

// Request both directional engines from one fixed five-minute context.
[regularSessionVWAP, entryScoreRaw, bestSupportCode, bestSupportDistanceAtr, entryDisqualified, entryApproved, entryWatch, shortEntryScoreRaw, bestResistanceCode, bestResistanceDistanceAtr, shortEntryDisqualified, shortEntryApproved, shortEntryWatch] = request.security(syminfo.tickerid, ENTRY_TIMEFRAME, f_five_minute_entry_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

int entryScore =
     nz(entryScoreRaw, 0)

int shortEntryScore =
     nz(shortEntryScoreRaw, 0)

//=============================================================================
// PARAMETER 1 - 9:30 TO 10:00 LOCKOUT
//=============================================================================

bool timeBullish =
     tradingAllowed

//=============================================================================
// PARAMETER 2 - ACTIVE 10-MINUTE RIPSTER 8/9 EMA CLOUD
//=============================================================================

float ema8TenMinute = request.security(
     syminfo.tickerid,
     "10",
     ta.ema(hl2, 8),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

float ema9TenMinute = request.security(
     syminfo.tickerid,
     "10",
     ta.ema(hl2, 9),
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

bool cloudAvailable =
     intradayChart and
     not na(ema8TenMinute) and
     not na(ema9TenMinute)

bool cloudBullish =
     cloudAvailable and
     ema8TenMinute >= ema9TenMinute

bool cloudBearish =
     cloudAvailable and
     ema8TenMinute < ema9TenMinute

//=============================================================================
// PARAMETER 3 - 9:30 REGULAR-SESSION OPEN
//=============================================================================

var float regularSessionOpen = na

if newCalendarDay
    regularSessionOpen := na

if newRegularSession
    regularSessionOpen := open

bool openAvailable =
     inRegularSession and
     not na(regularSessionOpen)

bool aboveOpeningLevel =
     openAvailable and
     close >= regularSessionOpen

bool belowOpeningLevel =
     openAvailable and
     close <= regularSessionOpen

//=============================================================================
// PARAMETER 4 - FIXED 5-MINUTE PERSISTENT RTH VWAP (INTERNAL ONLY)
//=============================================================================

bool vwapAvailable =
     not na(regularSessionVWAP)

bool aboveVWAP =
     vwapAvailable and
     close >= regularSessionVWAP

bool belowVWAP =
     vwapAvailable and
     close <= regularSessionVWAP

//=============================================================================
// PARAMETER 5 - ES ABOVE SMASHLEVEL
//=============================================================================

float esPrice = request.security(
     esSymbol,
     timeframe.period,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off
)

bool smashlevelEntered =
     smashLevel > 0

bool esAvailable =
     smashlevelEntered and
     not na(esPrice)

bool esAboveSmashlevel =
     esAvailable and
     esPrice >= smashLevel

bool esBelowSmashlevel =
     esAvailable and
     esPrice <= smashLevel

//=============================================================================
// OVERALL DIRECTIONAL STATUS
//=============================================================================

bool allDataAvailable =
     cloudAvailable and
     openAvailable and
     vwapAvailable and
     esAvailable

bool allLongConditions =
     tradingAllowed and
     cloudBullish and
     aboveOpeningLevel and
     aboveVWAP and
     esAboveSmashlevel

bool allShortConditions =
     tradingAllowed and
     cloudBearish and
     belowOpeningLevel and
     belowVWAP and
     esBelowSmashlevel

int bullishCount =
     (timeBullish       ? 1 : 0) +
     (cloudBullish      ? 1 : 0) +
     (aboveOpeningLevel ? 1 : 0) +
     (aboveVWAP         ? 1 : 0) +
     (esAboveSmashlevel ? 1 : 0)

int bearishCount =
     (timeBullish       ? 1 : 0) +
     (cloudBearish      ? 1 : 0) +
     (belowOpeningLevel ? 1 : 0) +
     (belowVWAP         ? 1 : 0) +
     (esBelowSmashlevel ? 1 : 0)

//=============================================================================
// COLORS
//=============================================================================

color headerBackground =
     color.rgb(27, 30, 36)

// Slightly quieter colors for the five component conditions.
color bullishBackground =
     color.rgb(24, 104, 72)

color bearishBackground =
     color.rgb(137, 48, 59)

color watchBackground =
     color.rgb(161, 104, 31)

// Stronger colors reserved for LONG and ENTRY.
color strongBullishBackground =
     color.rgb(19, 121, 76)

color strongBearishBackground =
     color.rgb(157, 45, 57)

color strongWatchBackground =
     color.rgb(173, 111, 28)

color neutralBackground =
     color.rgb(74, 78, 87)

color primaryText =
     color.white

color borderColor =
     color.rgb(62, 66, 75)

//=============================================================================
// STATUS TEXT
//=============================================================================

string timeStatus =
     not intradayChart
     ? "N/A"
     : tradingAllowed
     ? "ALLOWED"
     : inRegularSession
     ? "LOCKED"
     : "CLOSED"

string timeDetail =
     tradingAllowed
     ? "10-4 ET"
     : inRegularSession
     ? "9:30-10"
     : "RTH"

string cloudStatus =
     not cloudAvailable
     ? "N/A"
     : cloudBullish
     ? "BULLISH"
     : "BEARISH"

string cloudDetail =
     not cloudAvailable
     ? "10M EMA"
     : cloudBullish
     ? "8 > 9"
     : "8 < 9"

string openStatus =
     not openAvailable
     ? "N/A"
     : aboveOpeningLevel
     ? "ABOVE"
     : "BELOW"

string openDetail =
     openAvailable
     ? str.tostring(
          regularSessionOpen,
          format.mintick
       )
     : "9:30 OPEN"

string vwapStatus =
     not vwapAvailable
     ? "N/A"
     : aboveVWAP
     ? "ABOVE"
     : "BELOW"

string vwapDetail =
     vwapAvailable
     ? str.tostring(
          regularSessionVWAP,
          format.mintick
       )
     : "RTH VWAP"

string esStatus =
     not smashlevelEntered
     ? "SET LEVEL"
     : not esAvailable
     ? "N/A"
     : esAboveSmashlevel
     ? "ABOVE"
     : "BELOW"

float esDistanceFromLevel =
     esAvailable
     ? esPrice - smashLevel
     : na

string esDetail =
     esAvailable
     ? (
          esDistanceFromLevel >= 0
          ? "+"
          : ""
       ) +
       str.tostring(
            esDistanceFromLevel,
            "0.00"
       )
     : "DAILY INPUT"

string overallStatus =
     not intradayChart
     ? "N/A"
     : not inRegularSession
     ? "CLOSED"
     : not tradingAllowed
     ? "LOCKED"
     : not allDataAvailable
     ? "INCOMPLETE"
     : allLongConditions
     ? "LONG"
     : allShortConditions
     ? "SHORT"
     : "MIXED"

string overallDetail =
     "L" +
     str.tostring(bullishCount) +
     " / S" +
     str.tostring(bearishCount)

//=============================================================================
// ENTRY SCORE TEXT
//=============================================================================

string entryScoreText =
     str.tostring(entryScore) +
     "/100"

string bestSupportShort =
     bestSupportCode == 1
     ? "5M"
     : bestSupportCode == 2
     ? "VWAP"
     : bestSupportCode == 3
     ? "10M"
     : "NONE"

bool entrySupportFound =
     bestSupportCode != 0 and
     not na(bestSupportDistanceAtr)

string entrySupportTextDesktop =
     entrySupportFound
     ? bestSupportShort +
       "  |  " +
       str.tostring(
            bestSupportDistanceAtr,
            "0.00"
       ) +
       " ATR"
     : "SUPPORT N/A"

string entrySupportTextMobile =
     entrySupportFound
     ? bestSupportShort +
       " / " +
       str.tostring(
            bestSupportDistanceAtr,
            "#.00"
       ) +
       "A"
     : "N/A"

string entrySupportText =
     dashboardLayout == "Desktop"
     ? entrySupportTextDesktop
     : entrySupportTextMobile

string shortEntryScoreText =
     str.tostring(shortEntryScore) +
     "/100"

string bestResistanceShort =
     bestResistanceCode == 1
     ? "5M"
     : bestResistanceCode == 2
     ? "VWAP"
     : bestResistanceCode == 3
     ? "10M"
     : "NONE"

bool entryResistanceFound =
     bestResistanceCode != 0 and
     not na(bestResistanceDistanceAtr)

string entryResistanceTextDesktop =
     entryResistanceFound
     ? bestResistanceShort +
       "  |  " +
       str.tostring(
            bestResistanceDistanceAtr,
            "0.00"
       ) +
       " ATR"
     : "RESIST N/A"

string entryResistanceTextMobile =
     entryResistanceFound
     ? bestResistanceShort +
       " / " +
       str.tostring(
            bestResistanceDistanceAtr,
            "#.00"
       ) +
       "A"
     : "N/A"

string entryResistanceText =
     dashboardLayout == "Desktop"
     ? entryResistanceTextDesktop
     : entryResistanceTextMobile

//=============================================================================
// TWO-STAGE LONG + SHORT ALERT ENGINE
//=============================================================================

// Alerts are intentionally armed only on a five-minute chart so the live score,
// interaction, and confirmation all use the engine's native timeframe.
bool alertChartIsFiveMinute =
     timeframe.isminutes and
     timeframe.multiplier == 5

//-------------------------------------------------------------------------
// LONG STAGE 1 - live setup-forming alert
//-------------------------------------------------------------------------

bool setupFormingAlertState =
     enableSetupAlerts and
     alertChartIsFiveMinute and
     not entryDisqualified and
     entryScore >= setupAlertScore

varip bool setupFormingAlertLatched = false

if barstate.isnew
    setupFormingAlertLatched := setupFormingAlertState[1]

if not setupFormingAlertState
    setupFormingAlertLatched := false

bool newSetupFormingAlert =
     setupFormingAlertState and
     not setupFormingAlertLatched

if newSetupFormingAlert
    setupFormingAlertLatched := true

//-------------------------------------------------------------------------
// LONG STAGE 2 - confirmed five-minute close
//-------------------------------------------------------------------------

bool approvedAlertState =
     enableApprovedAlerts and
     alertChartIsFiveMinute and
     entryApproved and
     entryScore >= confirmedAlertScore

bool newApprovedEntryAlert =
     barstate.isconfirmed and
     approvedAlertState and
     not approvedAlertState[1]

//-------------------------------------------------------------------------
// SHORT STAGE 1 - live setup-forming alert
//-------------------------------------------------------------------------

bool shortSetupFormingAlertState =
     enableSetupAlerts and
     alertChartIsFiveMinute and
     not shortEntryDisqualified and
     shortEntryScore >= setupAlertScore

varip bool shortSetupFormingAlertLatched = false

if barstate.isnew
    shortSetupFormingAlertLatched := shortSetupFormingAlertState[1]

if not shortSetupFormingAlertState
    shortSetupFormingAlertLatched := false

bool newShortSetupFormingAlert =
     shortSetupFormingAlertState and
     not shortSetupFormingAlertLatched

if newShortSetupFormingAlert
    shortSetupFormingAlertLatched := true

//-------------------------------------------------------------------------
// SHORT STAGE 2 - confirmed five-minute close
//-------------------------------------------------------------------------

bool shortApprovedAlertState =
     enableApprovedAlerts and
     alertChartIsFiveMinute and
     shortEntryApproved and
     shortEntryScore >= confirmedAlertScore

bool newShortApprovedEntryAlert =
     barstate.isconfirmed and
     shortApprovedAlertState and
     not shortApprovedAlertState[1]

//-------------------------------------------------------------------------
// Alert messages
//-------------------------------------------------------------------------

string alertSupportDistanceText =
     not na(bestSupportDistanceAtr)
     ? str.tostring(bestSupportDistanceAtr, "0.00") + " ATR"
     : "N/A"

string alertResistanceDistanceText =
     not na(bestResistanceDistanceAtr)
     ? str.tostring(bestResistanceDistanceAtr, "0.00") + " ATR"
     : "N/A"

string setupFormingAlertMessage =
     syminfo.ticker +
     " LONG SETUP FORMING" +
     "\nLive score: " +
     str.tostring(entryScore) +
     "/100" +
     "\nPrice: " +
     str.tostring(close, format.mintick) +
     "\nSupport: " +
     bestSupportShort +
     "\nDistance: " +
     alertSupportDistanceText +
     "\nStatus: all 5 long conditions green"

string approvedEntryAlertMessage =
     syminfo.ticker +
     " LONG ENTRY CONFIRMED" +
     "\nClosing score: " +
     str.tostring(entryScore) +
     "/100" +
     "\nPrice: " +
     str.tostring(close, format.mintick) +
     "\nSupport: " +
     bestSupportShort +
     "\nDistance: " +
     alertSupportDistanceText +
     "\nES: " +
     str.tostring(esPrice, format.mintick) +
     " vs " +
     str.tostring(smashLevel, format.mintick)

string shortSetupFormingAlertMessage =
     syminfo.ticker +
     " SHORT SETUP FORMING" +
     "\nLive score: " +
     str.tostring(shortEntryScore) +
     "/100" +
     "\nPrice: " +
     str.tostring(close, format.mintick) +
     "\nResistance: " +
     bestResistanceShort +
     "\nDistance: " +
     alertResistanceDistanceText +
     "\nStatus: all 5 short conditions red"

string shortApprovedEntryAlertMessage =
     syminfo.ticker +
     " SHORT ENTRY CONFIRMED" +
     "\nClosing score: " +
     str.tostring(shortEntryScore) +
     "/100" +
     "\nPrice: " +
     str.tostring(close, format.mintick) +
     "\nResistance: " +
     bestResistanceShort +
     "\nDistance: " +
     alertResistanceDistanceText +
     "\nES: " +
     str.tostring(esPrice, format.mintick) +
     " vs " +
     str.tostring(smashLevel, format.mintick)

alertcondition(
     newSetupFormingAlert,
     title = "Long Setup Forming 70+",
     message = "{{ticker}} LONG SETUP FORMING at {{close}}. Live long entry score has reached the setup threshold."
)

alertcondition(
     newApprovedEntryAlert,
     title = "Long Entry Confirmed 80+",
     message = "{{ticker}} LONG ENTRY CONFIRMED at {{close}}. Open the chart for the closing score and support details."
)

alertcondition(
     newShortSetupFormingAlert,
     title = "Short Setup Forming 70+",
     message = "{{ticker}} SHORT SETUP FORMING at {{close}}. Live short entry score has reached the setup threshold."
)

alertcondition(
     newShortApprovedEntryAlert,
     title = "Short Entry Confirmed 80+",
     message = "{{ticker}} SHORT ENTRY CONFIRMED at {{close}}. Open the chart for the closing score and resistance details."
)

if newSetupFormingAlert
    alert(
         setupFormingAlertMessage,
         alert.freq_once_per_bar
    )

if newApprovedEntryAlert
    alert(
         approvedEntryAlertMessage,
         alert.freq_once_per_bar_close
    )

if newShortSetupFormingAlert
    alert(
         shortSetupFormingAlertMessage,
         alert.freq_once_per_bar
    )

if newShortApprovedEntryAlert
    alert(
         shortApprovedEntryAlertMessage,
         alert.freq_once_per_bar_close
    )

//=============================================================================
// STATUS COLORS
//=============================================================================

color timeColor =
     not intradayChart
     ? neutralBackground
     : tradingAllowed
     ? bullishBackground
     : bearishBackground

color cloudColor =
     not cloudAvailable
     ? neutralBackground
     : cloudBullish
     ? bullishBackground
     : bearishBackground

color openColor =
     not openAvailable
     ? neutralBackground
     : aboveOpeningLevel
     ? bullishBackground
     : bearishBackground

color vwapColor =
     not vwapAvailable
     ? neutralBackground
     : aboveVWAP
     ? bullishBackground
     : bearishBackground

color esColor =
     not esAvailable
     ? neutralBackground
     : esAboveSmashlevel
     ? bullishBackground
     : bearishBackground

color overallColor =
     not intradayChart
     ? neutralBackground
     : not inRegularSession
     ? strongBearishBackground
     : not tradingAllowed
     ? strongBearishBackground
     : not allDataAvailable
     ? neutralBackground
     : allLongConditions
     ? strongBullishBackground
     : allShortConditions
     ? strongBearishBackground
     : strongWatchBackground

color entryScoreColor =
     entryScore >= approvalScoreThreshold
     ? strongBullishBackground
     : entryScore >= watchScoreThreshold
     ? strongWatchBackground
     : strongBearishBackground

// For the short row, a qualifying/high score is intentionally red because red
// represents actionable downside bias rather than a failed condition.
color shortEntryScoreColor =
     shortEntryScore >= approvalScoreThreshold
     ? strongBearishBackground
     : shortEntryScore >= watchScoreThreshold
     ? strongWatchBackground
     : neutralBackground

//=============================================================================
// CLEAN 3 x 4 DIRECTIONAL DASHBOARD
//=============================================================================

var table dashboard = table.new(
     position.top_right,
     3,
     4,
     bgcolor = color.new(headerBackground, 5),
     frame_color = borderColor,
     frame_width = 1,
     border_color = borderColor,
     border_width = 1
)

//-----------------------------------------------------------------------------
// Compact two-line condition cell
//-----------------------------------------------------------------------------

f_condition_cell(
     int column,
     int row,
     string label,
     string status,
     string detail,
     color background,
     bool emphasize
) =>
    string separator =
         dashboardLayout == "Desktop"
         ? "  |  "
         : " / "

    string cellText =
         showLiveValues and
         detail != ""
         ? label +
           "\n" +
           status +
           separator +
           detail
         : label +
           "\n" +
           status

    table.cell(
         dashboard,
         column,
         row,
         cellText,
         bgcolor = background,
         text_color = primaryText,
         text_size = emphasize and
                     dashboardLayout == "Desktop"
                     ? size.small
                     : size.tiny,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

//=============================================================================
// DRAW DASHBOARD
//=============================================================================

if barstate.islast
    table.set_position(
         dashboard,
         dashboardLayout == "Desktop"
         ? position.top_right
         : position.top_center
    )

    table.clear(
         dashboard,
         0,
         0,
         2,
         3
    )

    //-------------------------------------------------------------------------
    // ROW 1
    //-------------------------------------------------------------------------

    f_condition_cell(
         0,
         0,
         "TIME",
         timeStatus,
         timeDetail,
         timeColor,
         false
    )

    f_condition_cell(
         1,
         0,
         "10M CLOUD",
         cloudStatus,
         cloudDetail,
         cloudColor,
         false
    )

    f_condition_cell(
         2,
         0,
         "OPEN",
         openStatus,
         openDetail,
         openColor,
         false
    )

    //-------------------------------------------------------------------------
    // ROW 2
    //-------------------------------------------------------------------------

    f_condition_cell(
         0,
         1,
         "VWAP",
         vwapStatus,
         vwapDetail,
         vwapColor,
         false
    )

    f_condition_cell(
         1,
         1,
         "ES LEVEL",
         esStatus,
         esDetail,
         esColor,
         false
    )

    f_condition_cell(
         2,
         1,
         "BIAS",
         overallStatus,
         overallDetail,
         overallColor,
         true
    )

    //-------------------------------------------------------------------------
    // ROW 3 - LONG / CALL ENTRY SCORE
    //-------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         2,
         "LONG",
         bgcolor = entryScoreColor,
         text_color = primaryText,
         text_size = size.tiny,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

    table.cell(
         dashboard,
         1,
         2,
         entryScoreText,
         bgcolor = entryScoreColor,
         text_color = primaryText,
         text_size = dashboardLayout == "Desktop"
                     ? size.normal
                     : size.small,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

    table.cell(
         dashboard,
         2,
         2,
         showLiveValues
         ? entrySupportText
         : "",
         bgcolor = entryScoreColor,
         text_color = primaryText,
         text_size = size.tiny,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

    //-------------------------------------------------------------------------
    // ROW 4 - SHORT / PUT ENTRY SCORE
    //-------------------------------------------------------------------------

    table.cell(
         dashboard,
         0,
         3,
         "SHORT",
         bgcolor = shortEntryScoreColor,
         text_color = primaryText,
         text_size = size.tiny,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

    table.cell(
         dashboard,
         1,
         3,
         shortEntryScoreText,
         bgcolor = shortEntryScoreColor,
         text_color = primaryText,
         text_size = dashboardLayout == "Desktop"
                     ? size.normal
                     : size.small,
         text_halign = text.align_center,
         text_valign = text.align_center
    )

    table.cell(
         dashboard,
         2,
         3,
         showLiveValues
         ? entryResistanceText
         : "",
         bgcolor = shortEntryScoreColor,
         text_color = primaryText,
         text_size = size.tiny,
         text_halign = text.align_center,
         text_valign = text.align_center
    )
````
