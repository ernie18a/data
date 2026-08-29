<!-- tradingview-pine-id: PUB;794fab5cb5674a48af85c302bc8c9e33 -->
<!-- tradingviewscripts-format: 1 -->
# Long/Short Watchlist Scanner v2.3

Source: https://www.tradingview.com/script/ozgT3YxN-BEC-Scanner/

## Description

A good way to scan for bacon egg and cheeses. The best way to scan for bacon egg and cheese. No one does a bacon egg and cheese like this guy.

---

## Source Code

````pine
//@version=6
indicator("Long/Short Watchlist Scanner v2.3", shorttitle = "LS Scan23", overlay = true, dynamic_requests = true)

//=============================================================================
// INPUTS
//=============================================================================

string GROUP_DAILY   = "Daily Settings"
string GROUP_SYMBOLS = "Scanner Symbols"
string GROUP_ENTRY   = "Entry Engine"
string GROUP_ALERTS  = "Alerts"
string GROUP_LAYOUT  = "Scanner Layout"

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
     tooltip = "Update this level manually each trading day, then recreate the TradingView alert."
)

bool enableSymbol1 = input.bool(true, "Enable 1", inline = "S1", group = GROUP_SYMBOLS)
string symbol1 = input.symbol("AMEX:SPY", "", inline = "S1", group = GROUP_SYMBOLS)

bool enableSymbol2 = input.bool(true, "Enable 2", inline = "S2", group = GROUP_SYMBOLS)
string symbol2 = input.symbol("NASDAQ:QQQ", "", inline = "S2", group = GROUP_SYMBOLS)

bool enableSymbol3 = input.bool(true, "Enable 3", inline = "S3", group = GROUP_SYMBOLS)
string symbol3 = input.symbol("NASDAQ:NVDA", "", inline = "S3", group = GROUP_SYMBOLS)

bool enableSymbol4 = input.bool(true, "Enable 4", inline = "S4", group = GROUP_SYMBOLS)
string symbol4 = input.symbol("NASDAQ:TSLA", "", inline = "S4", group = GROUP_SYMBOLS)

bool enableSymbol5 = input.bool(true, "Enable 5", inline = "S5", group = GROUP_SYMBOLS)
string symbol5 = input.symbol("NASDAQ:AAPL", "", inline = "S5", group = GROUP_SYMBOLS)

bool enableSymbol6 = input.bool(true, "Enable 6", inline = "S6", group = GROUP_SYMBOLS)
string symbol6 = input.symbol("NASDAQ:AMD", "", inline = "S6", group = GROUP_SYMBOLS)

bool enableSymbol7 = input.bool(true, "Enable 7", inline = "S7", group = GROUP_SYMBOLS)
string symbol7 = input.symbol("NASDAQ:META", "", inline = "S7", group = GROUP_SYMBOLS)

bool enableSymbol8 = input.bool(true, "Enable 8", inline = "S8", group = GROUP_SYMBOLS)
string symbol8 = input.symbol("NASDAQ:AMZN", "", inline = "S8", group = GROUP_SYMBOLS)

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
     group = GROUP_ENTRY
)

float touchBufferAtr = input.float(
     0.10,
     "Support/resistance touch buffer (ATR)",
     minval = 0.00,
     step = 0.05,
     group = GROUP_ENTRY
)

float maxUndercutAtr = input.float(
     0.15,
     "Maximum support undercut/resistance break (ATR)",
     minval = 0.00,
     step = 0.05,
     group = GROUP_ENTRY
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
     "Enable setup-forming alerts",
     group = GROUP_ALERTS
)

int setupAlertScore = input.int(
     70,
     "Setup-forming alert score",
     minval = 0,
     maxval = 100,
     group = GROUP_ALERTS
)

bool enableConfirmedAlerts = input.bool(
     true,
     "Enable confirmed-entry alerts",
     group = GROUP_ALERTS
)

int confirmedAlertScore = input.int(
     80,
     "Confirmed-entry alert score",
     minval = 0,
     maxval = 100,
     group = GROUP_ALERTS
)

string scannerPosition = input.string(
     "Bottom Center",
     "Table position",
     options = ["Top Left", "Top Center", "Top Right", "Bottom Left", "Bottom Center", "Bottom Right"],
     group = GROUP_LAYOUT
)

bool showSupportDistance = input.bool(
     true,
     "Show support/resistance distance",
     group = GROUP_LAYOUT
)

//=============================================================================
// CONSTANTS AND COMMON ES FILTER
//=============================================================================

string TIMEZONE           = "America/New_York"
string PREMARKET_SESSION  = "0400-0930:23456"
string LOCKOUT_SESSION    = "0930-1000:23456"
string TRADE_SESSION      = "1000-1600:23456"
string POSTMARKET_SESSION = "1600-2000:23456"
string ENTRY_TIMEFRAME    = "5"

bool chartIsFiveMinute =
     timeframe.isminutes and
     timeframe.multiplier == 5

float esPriceFiveMinute = request.security(
     esSymbol,
     ENTRY_TIMEFRAME,
     close,
     gaps = barmerge.gaps_off,
     lookahead = barmerge.lookahead_off,
     calc_bars_count = 500
)

bool smashlevelEntered =
     smashLevel > 0

bool esAvailable =
     smashlevelEntered and
     not na(esPriceFiveMinute)

bool esAboveSmashlevel =
     esAvailable and
     esPriceFiveMinute >= smashLevel

bool esBelowSmashlevel =
     esAvailable and
     esPriceFiveMinute <= smashLevel

//=============================================================================
// HELPERS
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

f_display_symbol(string fullSymbol) =>
    string result = fullSymbol
    result := str.replace_all(result, "NASDAQ:", "")
    result := str.replace_all(result, "NYSE:", "")
    result := str.replace_all(result, "AMEX:", "")
    result := str.replace_all(result, "BATS:", "")
    result := str.replace_all(result, "CBOE:", "")
    result

f_level_name(int levelCode) =>
    levelCode == 1
     ? "5M"
     : levelCode == 2
     ? "VWAP"
     : levelCode == 3
     ? "10M"
     : "—"

f_level_text(
     int levelCode,
     float levelDistance
) =>
    string levelName = f_level_name(levelCode)
    levelCode == 0 or na(levelDistance)
     ? "—"
     : showSupportDistance
     ? levelName + " " + str.tostring(levelDistance, "0.00") + "A"
     : levelName

f_alert_level_text(
     int levelCode,
     float levelDistance
) =>
    levelCode == 0 or na(levelDistance)
     ? "—"
     : f_level_name(levelCode) + " " + str.tostring(levelDistance, "0.00") + "A"

f_direction(
     int longCount,
     int shortCount
) =>
    longCount > shortCount
     ? 1
     : shortCount > longCount
     ? -1
     : 0

f_entry_data_displayable(int sessionCode) =>
    sessionCode == 1 or sessionCode == 2 or sessionCode == 3

//=============================================================================
// STOCK ENGINE — FIXED FIVE-MINUTE EXTENDED-SESSION CONTEXT
//=============================================================================

f_stock_engine() =>
    //--------------------------------------------------------------------------
    // Session state
    //--------------------------------------------------------------------------

    bool engineInRegularSession =
         session.ismarket

    bool engineNewRegularSession =
         session.isfirstbar_regular

    bool enginePremarket =
         not na(time(timeframe.period, PREMARKET_SESSION, TIMEZONE))

    bool engineLockout =
         not na(time(timeframe.period, LOCKOUT_SESSION, TIMEZONE))

    bool engineTradingAllowed =
         not na(time(timeframe.period, TRADE_SESSION, TIMEZONE))

    bool enginePostmarket =
         not na(time(timeframe.period, POSTMARKET_SESSION, TIMEZONE))

    int engineSessionCode =
         engineTradingAllowed
         ? 2
         : enginePremarket
         ? 0
         : engineLockout
         ? 1
         : enginePostmarket
         ? 3
         : 4

    int engineNewYorkDate =
         year(time, TIMEZONE) * 10000 +
         month(time, TIMEZONE) * 100 +
         dayofmonth(time, TIMEZONE)

    bool engineNewCalendarDay =
         bar_index == 0 or
         engineNewYorkDate != engineNewYorkDate[1]

    //--------------------------------------------------------------------------
    // Extended-hours 10-minute Ripster 8/9 cloud
    //--------------------------------------------------------------------------

    string engineExtendedTicker =
         ticker.modify(syminfo.tickerid, session = session.extended)

    [engineEma8TenMinute, engineEma9TenMinute] = request.security(
         engineExtendedTicker,
         "10",
         [ta.ema(hl2, 8), ta.ema(hl2, 9)],
         gaps = barmerge.gaps_off,
         lookahead = barmerge.lookahead_off,
         calc_bars_count = 500
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

    if engineNewCalendarDay
        engineCumulativePriceVolume := na
        engineCumulativeVolume := na

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
    // Directional stock-condition counts; shared ES condition is added outside
    //--------------------------------------------------------------------------

    int engineLongBaseCount =
         (engineTradingAllowed ? 1 : 0) +
         (engineCloudBullish ? 1 : 0) +
         (engineAboveOpeningLevel ? 1 : 0) +
         (engineAboveVWAP ? 1 : 0)

    int engineShortBaseCount =
         (engineTradingAllowed ? 1 : 0) +
         (engineCloudBearish ? 1 : 0) +
         (engineBelowOpeningLevel ? 1 : 0) +
         (engineBelowVWAP ? 1 : 0)

    //--------------------------------------------------------------------------
    // Shared five-minute entry data
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
         math.max(engineEma8TenMinute, engineEma9TenMinute)

    float tenMinuteCloudBottom =
         math.min(engineEma8TenMinute, engineEma9TenMinute)

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
    // LONG ENGINE — eligible supports
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
    // LONG ENGINE — nearest support
    //--------------------------------------------------------------------------

    int bestSupportCode = 0
    float bestSupportDistanceAtr = na
    float selectedSupportTop = na
    float selectedSupportBottom = na
    float previousSupportTop = na
    float previousSupportBottom = na

    // Exact-tie priority: 5M, then VWAP, then 10M.
    if fiveMinuteSupportEligible
        bestSupportCode := 1
        bestSupportDistanceAtr := fiveMinuteDistanceAtr
        selectedSupportTop := fiveMinuteCloudTop
        selectedSupportBottom := fiveMinuteCloudBottom
        previousSupportTop := fiveMinuteCloudTop[1]
        previousSupportBottom := fiveMinuteCloudBottom[1]

    if vwapSupportEligible and
       (
            na(bestSupportDistanceAtr) or
            vwapDistanceAtr < bestSupportDistanceAtr
       )
        bestSupportCode := 2
        bestSupportDistanceAtr := vwapDistanceAtr
        selectedSupportTop := engineRegularSessionVWAP
        selectedSupportBottom := engineRegularSessionVWAP
        previousSupportTop := engineRegularSessionVWAP[1]
        previousSupportBottom := engineRegularSessionVWAP[1]

    if tenMinuteSupportEligible and
       (
            na(bestSupportDistanceAtr) or
            tenMinuteDistanceAtr < bestSupportDistanceAtr
       )
        bestSupportCode := 3
        bestSupportDistanceAtr := tenMinuteDistanceAtr
        selectedSupportTop := tenMinuteCloudTop
        selectedSupportBottom := tenMinuteCloudBottom
        previousSupportTop := tenMinuteCloudTop[1]
        previousSupportBottom := tenMinuteCloudBottom[1]

    bool supportFound =
         bestSupportCode != 0 and
         not na(bestSupportDistanceAtr) and
         not na(selectedSupportTop) and
         not na(selectedSupportBottom)

    bool supportNearby =
         supportFound and
         bestSupportDistanceAtr <= maxSupportDistanceAtr

    //--------------------------------------------------------------------------
    // LONG ENGINE — interaction, response, and failure
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
         low <= selectedSupportTop + touchBufferPrice

    bool previousSupportTouch =
         supportFound and
         not na(previousSupportTop) and
         not na(previousTouchBufferPrice) and
         low[1] <= previousSupportTop + previousTouchBufferPrice

    bool recentSupportTouch =
         currentSupportTouch or
         previousSupportTouch

    bool priceAboveSelectedSupport =
         supportFound and
         close >= selectedSupportTop

    bool bullishReclaimResponse =
         priceAboveSelectedSupport and
         close > open

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
         low < selectedSupportBottom - maxUndercutPrice

    bool previousSupportFailure =
         supportFound and
         not na(previousSupportBottom) and
         not na(previousMaxUndercutPrice) and
         low[1] < previousSupportBottom - previousMaxUndercutPrice

    bool supportFailure =
         currentSupportFailure or
         previousSupportFailure

    //--------------------------------------------------------------------------
    // LONG ENGINE — VWAP extension and confluence
    //--------------------------------------------------------------------------

    float vwapExtensionAtr =
         entryDataAvailable
         ? (close - engineRegularSessionVWAP) /
           atrFiveMinute
         : na

    bool controlledVwapExtension =
         not na(vwapExtensionAtr) and
         vwapExtensionAtr <= fullVwapScoreDistanceAtr

    bool excessiveVwapExtension =
         not na(vwapExtensionAtr) and
         vwapExtensionAtr > hardVwapExtensionAtr

    bool supportConfluence = false

    if supportFound
        if bestSupportCode != 1 and fiveMinuteSupportEligible
            float gapToFiveMinute =
                 f_zone_gap(
                      selectedSupportTop,
                      selectedSupportBottom,
                      fiveMinuteCloudTop,
                      fiveMinuteCloudBottom
                 ) / atrFiveMinute

            supportConfluence :=
                 supportConfluence or
                 gapToFiveMinute <= confluenceDistanceAtr

        if bestSupportCode != 2 and vwapSupportEligible
            float gapToVwap =
                 f_zone_gap(
                      selectedSupportTop,
                      selectedSupportBottom,
                      engineRegularSessionVWAP,
                      engineRegularSessionVWAP
                 ) / atrFiveMinute

            supportConfluence :=
                 supportConfluence or
                 gapToVwap <= confluenceDistanceAtr

        if bestSupportCode != 3 and tenMinuteSupportEligible
            float gapToTenMinute =
                 f_zone_gap(
                      selectedSupportTop,
                      selectedSupportBottom,
                      tenMinuteCloudTop,
                      tenMinuteCloudBottom
                 ) / atrFiveMinute

            supportConfluence :=
                 supportConfluence or
                 gapToTenMinute <= confluenceDistanceAtr

    //--------------------------------------------------------------------------
    // LONG ENGINE — mirrored 100-point score
    //--------------------------------------------------------------------------

    int longLocationPoints =
         not supportNearby
         ? 0
         : bestSupportDistanceAtr <= 0.10
         ? 40
         : bestSupportDistanceAtr <= 0.20
         ? 30
         : bestSupportDistanceAtr <= 0.30
         ? 20
         : 10

    int longInteractionPoints = recentSupportTouch ? 15 : 0
    int longResponsePoints = bullishReclaimResponse ? 15 : 0
    int longFiveMinuteTrendPoints = fiveMinuteCloudBullish ? 15 : 0
    int longConfluencePoints = supportConfluence ? 10 : 0
    int longVwapExtensionPoints = controlledVwapExtension ? 5 : 0

    int engineLongEntryScore =
         longLocationPoints +
         longInteractionPoints +
         longResponsePoints +
         longFiveMinuteTrendPoints +
         longConfluencePoints +
         longVwapExtensionPoints

    bool longHardPass =
         entryDataAvailable and
         supportNearby and
         not supportFailure and
         not excessiveVwapExtension

    //--------------------------------------------------------------------------
    // SHORT ENGINE — eligible resistances
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
    // SHORT ENGINE — nearest resistance
    //--------------------------------------------------------------------------

    int bestResistanceCode = 0
    float bestResistanceDistanceAtr = na
    float selectedResistanceTop = na
    float selectedResistanceBottom = na
    float previousResistanceTop = na
    float previousResistanceBottom = na

    // Exact-tie priority: 5M, then VWAP, then 10M.
    if fiveMinuteResistanceEligible
        bestResistanceCode := 1
        bestResistanceDistanceAtr := fiveMinuteResistanceDistanceAtr
        selectedResistanceTop := fiveMinuteCloudTop
        selectedResistanceBottom := fiveMinuteCloudBottom
        previousResistanceTop := fiveMinuteCloudTop[1]
        previousResistanceBottom := fiveMinuteCloudBottom[1]

    if vwapResistanceEligible and
       (
            na(bestResistanceDistanceAtr) or
            vwapResistanceDistanceAtr < bestResistanceDistanceAtr
       )
        bestResistanceCode := 2
        bestResistanceDistanceAtr := vwapResistanceDistanceAtr
        selectedResistanceTop := engineRegularSessionVWAP
        selectedResistanceBottom := engineRegularSessionVWAP
        previousResistanceTop := engineRegularSessionVWAP[1]
        previousResistanceBottom := engineRegularSessionVWAP[1]

    if tenMinuteResistanceEligible and
       (
            na(bestResistanceDistanceAtr) or
            tenMinuteResistanceDistanceAtr < bestResistanceDistanceAtr
       )
        bestResistanceCode := 3
        bestResistanceDistanceAtr := tenMinuteResistanceDistanceAtr
        selectedResistanceTop := tenMinuteCloudTop
        selectedResistanceBottom := tenMinuteCloudBottom
        previousResistanceTop := tenMinuteCloudTop[1]
        previousResistanceBottom := tenMinuteCloudBottom[1]

    bool resistanceFound =
         bestResistanceCode != 0 and
         not na(bestResistanceDistanceAtr) and
         not na(selectedResistanceTop) and
         not na(selectedResistanceBottom)

    bool resistanceNearby =
         resistanceFound and
         bestResistanceDistanceAtr <= maxSupportDistanceAtr

    //--------------------------------------------------------------------------
    // SHORT ENGINE — interaction, response, and failure
    //--------------------------------------------------------------------------

    bool currentResistanceTouch =
         resistanceFound and
         not na(touchBufferPrice) and
         high >= selectedResistanceBottom - touchBufferPrice

    bool previousResistanceTouch =
         resistanceFound and
         not na(previousResistanceBottom) and
         not na(previousTouchBufferPrice) and
         high[1] >= previousResistanceBottom - previousTouchBufferPrice

    bool recentResistanceTouch =
         currentResistanceTouch or
         previousResistanceTouch

    bool priceBelowSelectedResistance =
         resistanceFound and
         close <= selectedResistanceBottom

    bool bearishRejectionResponse =
         priceBelowSelectedResistance and
         close < open

    bool currentResistanceFailure =
         resistanceFound and
         not na(maxUndercutPrice) and
         high > selectedResistanceTop + maxUndercutPrice

    bool previousResistanceFailure =
         resistanceFound and
         not na(previousResistanceTop) and
         not na(previousMaxUndercutPrice) and
         high[1] > previousResistanceTop + previousMaxUndercutPrice

    bool resistanceFailure =
         currentResistanceFailure or
         previousResistanceFailure

    //--------------------------------------------------------------------------
    // SHORT ENGINE — downside VWAP extension and confluence
    //--------------------------------------------------------------------------

    float shortVwapExtensionAtr =
         entryDataAvailable
         ? (engineRegularSessionVWAP - close) /
           atrFiveMinute
         : na

    bool controlledShortVwapExtension =
         not na(shortVwapExtensionAtr) and
         shortVwapExtensionAtr <= fullVwapScoreDistanceAtr

    bool excessiveShortVwapExtension =
         not na(shortVwapExtensionAtr) and
         shortVwapExtensionAtr > hardVwapExtensionAtr

    bool resistanceConfluence = false

    if resistanceFound
        if bestResistanceCode != 1 and fiveMinuteResistanceEligible
            float gapToFiveMinuteResistance =
                 f_zone_gap(
                      selectedResistanceTop,
                      selectedResistanceBottom,
                      fiveMinuteCloudTop,
                      fiveMinuteCloudBottom
                 ) / atrFiveMinute

            resistanceConfluence :=
                 resistanceConfluence or
                 gapToFiveMinuteResistance <= confluenceDistanceAtr

        if bestResistanceCode != 2 and vwapResistanceEligible
            float gapToVwapResistance =
                 f_zone_gap(
                      selectedResistanceTop,
                      selectedResistanceBottom,
                      engineRegularSessionVWAP,
                      engineRegularSessionVWAP
                 ) / atrFiveMinute

            resistanceConfluence :=
                 resistanceConfluence or
                 gapToVwapResistance <= confluenceDistanceAtr

        if bestResistanceCode != 3 and tenMinuteResistanceEligible
            float gapToTenMinuteResistance =
                 f_zone_gap(
                      selectedResistanceTop,
                      selectedResistanceBottom,
                      tenMinuteCloudTop,
                      tenMinuteCloudBottom
                 ) / atrFiveMinute

            resistanceConfluence :=
                 resistanceConfluence or
                 gapToTenMinuteResistance <= confluenceDistanceAtr

    //--------------------------------------------------------------------------
    // SHORT ENGINE — mirrored 100-point score
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

    int shortInteractionPoints = recentResistanceTouch ? 15 : 0
    int shortResponsePoints = bearishRejectionResponse ? 15 : 0
    int shortFiveMinuteTrendPoints = fiveMinuteCloudBearish ? 15 : 0
    int shortConfluencePoints = resistanceConfluence ? 10 : 0
    int shortVwapExtensionPoints = controlledShortVwapExtension ? 5 : 0

    int engineShortEntryScore =
         shortLocationPoints +
         shortInteractionPoints +
         shortResponsePoints +
         shortFiveMinuteTrendPoints +
         shortConfluencePoints +
         shortVwapExtensionPoints

    bool shortHardPass =
         entryDataAvailable and
         resistanceNearby and
         not resistanceFailure and
         not excessiveShortVwapExtension

    // Pack the three qualification booleans for each direction into one int.
    // Hundreds = hard pass, tens = recent touch, ones = response.
    int longFlags =
         (longHardPass ? 100 : 0) +
         (recentSupportTouch ? 10 : 0) +
         (bullishReclaimResponse ? 1 : 0)

    int shortFlags =
         (shortHardPass ? 100 : 0) +
         (recentResistanceTouch ? 10 : 0) +
         (bearishRejectionResponse ? 1 : 0)

    [close, engineSessionCode, engineLongBaseCount, engineShortBaseCount, engineLongEntryScore, bestSupportCode, bestSupportDistanceAtr, longFlags, engineShortEntryScore, bestResistanceCode, bestResistanceDistanceAtr, shortFlags]

//=============================================================================
// REQUEST ALL EIGHT SYMBOLS
// Scalar tuples are used here instead of requested UDT objects. This keeps the
// scanner lightweight and avoids object-history/runtime issues while remaining
// below Pine's aggregate tuple-element limit.
//=============================================================================

string extendedSymbol1 = ticker.modify(symbol1, session = session.extended)
string extendedSymbol2 = ticker.modify(symbol2, session = session.extended)
string extendedSymbol3 = ticker.modify(symbol3, session = session.extended)
string extendedSymbol4 = ticker.modify(symbol4, session = session.extended)
string extendedSymbol5 = ticker.modify(symbol5, session = session.extended)
string extendedSymbol6 = ticker.modify(symbol6, session = session.extended)
string extendedSymbol7 = ticker.modify(symbol7, session = session.extended)
string extendedSymbol8 = ticker.modify(symbol8, session = session.extended)

[p1, session1, longBase1, shortBase1, longScore1Raw, longLevel1, longDistance1, longFlags1Raw, shortScore1Raw, shortLevel1, shortDistance1, shortFlags1Raw] = request.security(extendedSymbol1, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p2, session2, longBase2, shortBase2, longScore2Raw, longLevel2, longDistance2, longFlags2Raw, shortScore2Raw, shortLevel2, shortDistance2, shortFlags2Raw] = request.security(extendedSymbol2, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p3, session3, longBase3, shortBase3, longScore3Raw, longLevel3, longDistance3, longFlags3Raw, shortScore3Raw, shortLevel3, shortDistance3, shortFlags3Raw] = request.security(extendedSymbol3, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p4, session4, longBase4, shortBase4, longScore4Raw, longLevel4, longDistance4, longFlags4Raw, shortScore4Raw, shortLevel4, shortDistance4, shortFlags4Raw] = request.security(extendedSymbol4, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p5, session5, longBase5, shortBase5, longScore5Raw, longLevel5, longDistance5, longFlags5Raw, shortScore5Raw, shortLevel5, shortDistance5, shortFlags5Raw] = request.security(extendedSymbol5, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p6, session6, longBase6, shortBase6, longScore6Raw, longLevel6, longDistance6, longFlags6Raw, shortScore6Raw, shortLevel6, shortDistance6, shortFlags6Raw] = request.security(extendedSymbol6, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p7, session7, longBase7, shortBase7, longScore7Raw, longLevel7, longDistance7, longFlags7Raw, shortScore7Raw, shortLevel7, shortDistance7, shortFlags7Raw] = request.security(extendedSymbol7, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)
[p8, session8, longBase8, shortBase8, longScore8Raw, longLevel8, longDistance8, longFlags8Raw, shortScore8Raw, shortLevel8, shortDistance8, shortFlags8Raw] = request.security(extendedSymbol8, ENTRY_TIMEFRAME, f_stock_engine(), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, calc_bars_count = 1000)

int longScore1 = nz(longScore1Raw, 0)
int shortScore1 = nz(shortScore1Raw, 0)
int longFlags1 = nz(longFlags1Raw, 0)
int shortFlags1 = nz(shortFlags1Raw, 0)
bool longHardPass1 = longFlags1 >= 100
bool longTouch1 = longFlags1 % 100 >= 10
bool longResponse1 = longFlags1 % 10 == 1
bool shortHardPass1 = shortFlags1 >= 100
bool shortTouch1 = shortFlags1 % 100 >= 10
bool shortResponse1 = shortFlags1 % 10 == 1

int longScore2 = nz(longScore2Raw, 0)
int shortScore2 = nz(shortScore2Raw, 0)
int longFlags2 = nz(longFlags2Raw, 0)
int shortFlags2 = nz(shortFlags2Raw, 0)
bool longHardPass2 = longFlags2 >= 100
bool longTouch2 = longFlags2 % 100 >= 10
bool longResponse2 = longFlags2 % 10 == 1
bool shortHardPass2 = shortFlags2 >= 100
bool shortTouch2 = shortFlags2 % 100 >= 10
bool shortResponse2 = shortFlags2 % 10 == 1

int longScore3 = nz(longScore3Raw, 0)
int shortScore3 = nz(shortScore3Raw, 0)
int longFlags3 = nz(longFlags3Raw, 0)
int shortFlags3 = nz(shortFlags3Raw, 0)
bool longHardPass3 = longFlags3 >= 100
bool longTouch3 = longFlags3 % 100 >= 10
bool longResponse3 = longFlags3 % 10 == 1
bool shortHardPass3 = shortFlags3 >= 100
bool shortTouch3 = shortFlags3 % 100 >= 10
bool shortResponse3 = shortFlags3 % 10 == 1

int longScore4 = nz(longScore4Raw, 0)
int shortScore4 = nz(shortScore4Raw, 0)
int longFlags4 = nz(longFlags4Raw, 0)
int shortFlags4 = nz(shortFlags4Raw, 0)
bool longHardPass4 = longFlags4 >= 100
bool longTouch4 = longFlags4 % 100 >= 10
bool longResponse4 = longFlags4 % 10 == 1
bool shortHardPass4 = shortFlags4 >= 100
bool shortTouch4 = shortFlags4 % 100 >= 10
bool shortResponse4 = shortFlags4 % 10 == 1

int longScore5 = nz(longScore5Raw, 0)
int shortScore5 = nz(shortScore5Raw, 0)
int longFlags5 = nz(longFlags5Raw, 0)
int shortFlags5 = nz(shortFlags5Raw, 0)
bool longHardPass5 = longFlags5 >= 100
bool longTouch5 = longFlags5 % 100 >= 10
bool longResponse5 = longFlags5 % 10 == 1
bool shortHardPass5 = shortFlags5 >= 100
bool shortTouch5 = shortFlags5 % 100 >= 10
bool shortResponse5 = shortFlags5 % 10 == 1

int longScore6 = nz(longScore6Raw, 0)
int shortScore6 = nz(shortScore6Raw, 0)
int longFlags6 = nz(longFlags6Raw, 0)
int shortFlags6 = nz(shortFlags6Raw, 0)
bool longHardPass6 = longFlags6 >= 100
bool longTouch6 = longFlags6 % 100 >= 10
bool longResponse6 = longFlags6 % 10 == 1
bool shortHardPass6 = shortFlags6 >= 100
bool shortTouch6 = shortFlags6 % 100 >= 10
bool shortResponse6 = shortFlags6 % 10 == 1

int longScore7 = nz(longScore7Raw, 0)
int shortScore7 = nz(shortScore7Raw, 0)
int longFlags7 = nz(longFlags7Raw, 0)
int shortFlags7 = nz(shortFlags7Raw, 0)
bool longHardPass7 = longFlags7 >= 100
bool longTouch7 = longFlags7 % 100 >= 10
bool longResponse7 = longFlags7 % 10 == 1
bool shortHardPass7 = shortFlags7 >= 100
bool shortTouch7 = shortFlags7 % 100 >= 10
bool shortResponse7 = shortFlags7 % 10 == 1

int longScore8 = nz(longScore8Raw, 0)
int shortScore8 = nz(shortScore8Raw, 0)
int longFlags8 = nz(longFlags8Raw, 0)
int shortFlags8 = nz(shortFlags8Raw, 0)
bool longHardPass8 = longFlags8 >= 100
bool longTouch8 = longFlags8 % 100 >= 10
bool longResponse8 = longFlags8 % 10 == 1
bool shortHardPass8 = shortFlags8 >= 100
bool shortTouch8 = shortFlags8 % 100 >= 10
bool shortResponse8 = shortFlags8 % 10 == 1

//=============================================================================
// DIRECTIONAL COUNTS
//=============================================================================

int longCount1 = longBase1 + (esAboveSmashlevel ? 1 : 0)
int longCount2 = longBase2 + (esAboveSmashlevel ? 1 : 0)
int longCount3 = longBase3 + (esAboveSmashlevel ? 1 : 0)
int longCount4 = longBase4 + (esAboveSmashlevel ? 1 : 0)
int longCount5 = longBase5 + (esAboveSmashlevel ? 1 : 0)
int longCount6 = longBase6 + (esAboveSmashlevel ? 1 : 0)
int longCount7 = longBase7 + (esAboveSmashlevel ? 1 : 0)
int longCount8 = longBase8 + (esAboveSmashlevel ? 1 : 0)

int shortCount1 = shortBase1 + (esBelowSmashlevel ? 1 : 0)
int shortCount2 = shortBase2 + (esBelowSmashlevel ? 1 : 0)
int shortCount3 = shortBase3 + (esBelowSmashlevel ? 1 : 0)
int shortCount4 = shortBase4 + (esBelowSmashlevel ? 1 : 0)
int shortCount5 = shortBase5 + (esBelowSmashlevel ? 1 : 0)
int shortCount6 = shortBase6 + (esBelowSmashlevel ? 1 : 0)
int shortCount7 = shortBase7 + (esBelowSmashlevel ? 1 : 0)
int shortCount8 = shortBase8 + (esBelowSmashlevel ? 1 : 0)

bool allLong1 = longCount1 == 5
bool allLong2 = longCount2 == 5
bool allLong3 = longCount3 == 5
bool allLong4 = longCount4 == 5
bool allLong5 = longCount5 == 5
bool allLong6 = longCount6 == 5
bool allLong7 = longCount7 == 5
bool allLong8 = longCount8 == 5

bool allShort1 = shortCount1 == 5
bool allShort2 = shortCount2 == 5
bool allShort3 = shortCount3 == 5
bool allShort4 = shortCount4 == 5
bool allShort5 = shortCount5 == 5
bool allShort6 = shortCount6 == 5
bool allShort7 = shortCount7 == 5
bool allShort8 = shortCount8 == 5

//=============================================================================
// LONG QUALIFICATION STATES
//=============================================================================

bool longSetupQualified1 = enableSymbol1 and allLong1 and longHardPass1 and longScore1 >= setupAlertScore
bool longSetupQualified2 = enableSymbol2 and allLong2 and longHardPass2 and longScore2 >= setupAlertScore
bool longSetupQualified3 = enableSymbol3 and allLong3 and longHardPass3 and longScore3 >= setupAlertScore
bool longSetupQualified4 = enableSymbol4 and allLong4 and longHardPass4 and longScore4 >= setupAlertScore
bool longSetupQualified5 = enableSymbol5 and allLong5 and longHardPass5 and longScore5 >= setupAlertScore
bool longSetupQualified6 = enableSymbol6 and allLong6 and longHardPass6 and longScore6 >= setupAlertScore
bool longSetupQualified7 = enableSymbol7 and allLong7 and longHardPass7 and longScore7 >= setupAlertScore
bool longSetupQualified8 = enableSymbol8 and allLong8 and longHardPass8 and longScore8 >= setupAlertScore

bool longLiveQualified1 = enableSymbol1 and allLong1 and longHardPass1 and longScore1 >= approvalScoreThreshold
bool longLiveQualified2 = enableSymbol2 and allLong2 and longHardPass2 and longScore2 >= approvalScoreThreshold
bool longLiveQualified3 = enableSymbol3 and allLong3 and longHardPass3 and longScore3 >= approvalScoreThreshold
bool longLiveQualified4 = enableSymbol4 and allLong4 and longHardPass4 and longScore4 >= approvalScoreThreshold
bool longLiveQualified5 = enableSymbol5 and allLong5 and longHardPass5 and longScore5 >= approvalScoreThreshold
bool longLiveQualified6 = enableSymbol6 and allLong6 and longHardPass6 and longScore6 >= approvalScoreThreshold
bool longLiveQualified7 = enableSymbol7 and allLong7 and longHardPass7 and longScore7 >= approvalScoreThreshold
bool longLiveQualified8 = enableSymbol8 and allLong8 and longHardPass8 and longScore8 >= approvalScoreThreshold

bool longConfirmedQualified1 = longLiveQualified1 and longScore1 >= confirmedAlertScore and longTouch1 and longResponse1
bool longConfirmedQualified2 = longLiveQualified2 and longScore2 >= confirmedAlertScore and longTouch2 and longResponse2
bool longConfirmedQualified3 = longLiveQualified3 and longScore3 >= confirmedAlertScore and longTouch3 and longResponse3
bool longConfirmedQualified4 = longLiveQualified4 and longScore4 >= confirmedAlertScore and longTouch4 and longResponse4
bool longConfirmedQualified5 = longLiveQualified5 and longScore5 >= confirmedAlertScore and longTouch5 and longResponse5
bool longConfirmedQualified6 = longLiveQualified6 and longScore6 >= confirmedAlertScore and longTouch6 and longResponse6
bool longConfirmedQualified7 = longLiveQualified7 and longScore7 >= confirmedAlertScore and longTouch7 and longResponse7
bool longConfirmedQualified8 = longLiveQualified8 and longScore8 >= confirmedAlertScore and longTouch8 and longResponse8

//=============================================================================
// SHORT QUALIFICATION STATES
//=============================================================================

bool shortSetupQualified1 = enableSymbol1 and allShort1 and shortHardPass1 and shortScore1 >= setupAlertScore
bool shortSetupQualified2 = enableSymbol2 and allShort2 and shortHardPass2 and shortScore2 >= setupAlertScore
bool shortSetupQualified3 = enableSymbol3 and allShort3 and shortHardPass3 and shortScore3 >= setupAlertScore
bool shortSetupQualified4 = enableSymbol4 and allShort4 and shortHardPass4 and shortScore4 >= setupAlertScore
bool shortSetupQualified5 = enableSymbol5 and allShort5 and shortHardPass5 and shortScore5 >= setupAlertScore
bool shortSetupQualified6 = enableSymbol6 and allShort6 and shortHardPass6 and shortScore6 >= setupAlertScore
bool shortSetupQualified7 = enableSymbol7 and allShort7 and shortHardPass7 and shortScore7 >= setupAlertScore
bool shortSetupQualified8 = enableSymbol8 and allShort8 and shortHardPass8 and shortScore8 >= setupAlertScore

bool shortLiveQualified1 = enableSymbol1 and allShort1 and shortHardPass1 and shortScore1 >= approvalScoreThreshold
bool shortLiveQualified2 = enableSymbol2 and allShort2 and shortHardPass2 and shortScore2 >= approvalScoreThreshold
bool shortLiveQualified3 = enableSymbol3 and allShort3 and shortHardPass3 and shortScore3 >= approvalScoreThreshold
bool shortLiveQualified4 = enableSymbol4 and allShort4 and shortHardPass4 and shortScore4 >= approvalScoreThreshold
bool shortLiveQualified5 = enableSymbol5 and allShort5 and shortHardPass5 and shortScore5 >= approvalScoreThreshold
bool shortLiveQualified6 = enableSymbol6 and allShort6 and shortHardPass6 and shortScore6 >= approvalScoreThreshold
bool shortLiveQualified7 = enableSymbol7 and allShort7 and shortHardPass7 and shortScore7 >= approvalScoreThreshold
bool shortLiveQualified8 = enableSymbol8 and allShort8 and shortHardPass8 and shortScore8 >= approvalScoreThreshold

bool shortConfirmedQualified1 = shortLiveQualified1 and shortScore1 >= confirmedAlertScore and shortTouch1 and shortResponse1
bool shortConfirmedQualified2 = shortLiveQualified2 and shortScore2 >= confirmedAlertScore and shortTouch2 and shortResponse2
bool shortConfirmedQualified3 = shortLiveQualified3 and shortScore3 >= confirmedAlertScore and shortTouch3 and shortResponse3
bool shortConfirmedQualified4 = shortLiveQualified4 and shortScore4 >= confirmedAlertScore and shortTouch4 and shortResponse4
bool shortConfirmedQualified5 = shortLiveQualified5 and shortScore5 >= confirmedAlertScore and shortTouch5 and shortResponse5
bool shortConfirmedQualified6 = shortLiveQualified6 and shortScore6 >= confirmedAlertScore and shortTouch6 and shortResponse6
bool shortConfirmedQualified7 = shortLiveQualified7 and shortScore7 >= confirmedAlertScore and shortTouch7 and shortResponse7
bool shortConfirmedQualified8 = shortLiveQualified8 and shortScore8 >= confirmedAlertScore and shortTouch8 and shortResponse8

//=============================================================================
// ALERT ARMING — FIVE-MINUTE CHART ONLY
//=============================================================================

bool longSetupAlertState1 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified1
bool longSetupAlertState2 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified2
bool longSetupAlertState3 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified3
bool longSetupAlertState4 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified4
bool longSetupAlertState5 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified5
bool longSetupAlertState6 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified6
bool longSetupAlertState7 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified7
bool longSetupAlertState8 = enableSetupAlerts and chartIsFiveMinute and longSetupQualified8

bool shortSetupAlertState1 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified1
bool shortSetupAlertState2 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified2
bool shortSetupAlertState3 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified3
bool shortSetupAlertState4 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified4
bool shortSetupAlertState5 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified5
bool shortSetupAlertState6 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified6
bool shortSetupAlertState7 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified7
bool shortSetupAlertState8 = enableSetupAlerts and chartIsFiveMinute and shortSetupQualified8

bool longConfirmedAlertState1 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified1
bool longConfirmedAlertState2 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified2
bool longConfirmedAlertState3 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified3
bool longConfirmedAlertState4 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified4
bool longConfirmedAlertState5 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified5
bool longConfirmedAlertState6 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified6
bool longConfirmedAlertState7 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified7
bool longConfirmedAlertState8 = enableConfirmedAlerts and chartIsFiveMinute and longConfirmedQualified8

bool shortConfirmedAlertState1 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified1
bool shortConfirmedAlertState2 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified2
bool shortConfirmedAlertState3 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified3
bool shortConfirmedAlertState4 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified4
bool shortConfirmedAlertState5 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified5
bool shortConfirmedAlertState6 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified6
bool shortConfirmedAlertState7 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified7
bool shortConfirmedAlertState8 = enableConfirmedAlerts and chartIsFiveMinute and shortConfirmedQualified8

//=============================================================================
// SEPARATE INTRABAR SETUP LATCHES — LONG
//=============================================================================

varip bool longSetupLatch1 = false
varip bool longSetupLatch2 = false
varip bool longSetupLatch3 = false
varip bool longSetupLatch4 = false
varip bool longSetupLatch5 = false
varip bool longSetupLatch6 = false
varip bool longSetupLatch7 = false
varip bool longSetupLatch8 = false

if barstate.isnew
    longSetupLatch1 := longSetupAlertState1[1]
    longSetupLatch2 := longSetupAlertState2[1]
    longSetupLatch3 := longSetupAlertState3[1]
    longSetupLatch4 := longSetupAlertState4[1]
    longSetupLatch5 := longSetupAlertState5[1]
    longSetupLatch6 := longSetupAlertState6[1]
    longSetupLatch7 := longSetupAlertState7[1]
    longSetupLatch8 := longSetupAlertState8[1]

if not longSetupAlertState1
    longSetupLatch1 := false
if not longSetupAlertState2
    longSetupLatch2 := false
if not longSetupAlertState3
    longSetupLatch3 := false
if not longSetupAlertState4
    longSetupLatch4 := false
if not longSetupAlertState5
    longSetupLatch5 := false
if not longSetupAlertState6
    longSetupLatch6 := false
if not longSetupAlertState7
    longSetupLatch7 := false
if not longSetupAlertState8
    longSetupLatch8 := false

bool newLongSetup1 = longSetupAlertState1 and not longSetupLatch1
bool newLongSetup2 = longSetupAlertState2 and not longSetupLatch2
bool newLongSetup3 = longSetupAlertState3 and not longSetupLatch3
bool newLongSetup4 = longSetupAlertState4 and not longSetupLatch4
bool newLongSetup5 = longSetupAlertState5 and not longSetupLatch5
bool newLongSetup6 = longSetupAlertState6 and not longSetupLatch6
bool newLongSetup7 = longSetupAlertState7 and not longSetupLatch7
bool newLongSetup8 = longSetupAlertState8 and not longSetupLatch8

if newLongSetup1
    longSetupLatch1 := true
if newLongSetup2
    longSetupLatch2 := true
if newLongSetup3
    longSetupLatch3 := true
if newLongSetup4
    longSetupLatch4 := true
if newLongSetup5
    longSetupLatch5 := true
if newLongSetup6
    longSetupLatch6 := true
if newLongSetup7
    longSetupLatch7 := true
if newLongSetup8
    longSetupLatch8 := true

//=============================================================================
// SEPARATE INTRABAR SETUP LATCHES — SHORT
//=============================================================================

varip bool shortSetupLatch1 = false
varip bool shortSetupLatch2 = false
varip bool shortSetupLatch3 = false
varip bool shortSetupLatch4 = false
varip bool shortSetupLatch5 = false
varip bool shortSetupLatch6 = false
varip bool shortSetupLatch7 = false
varip bool shortSetupLatch8 = false

if barstate.isnew
    shortSetupLatch1 := shortSetupAlertState1[1]
    shortSetupLatch2 := shortSetupAlertState2[1]
    shortSetupLatch3 := shortSetupAlertState3[1]
    shortSetupLatch4 := shortSetupAlertState4[1]
    shortSetupLatch5 := shortSetupAlertState5[1]
    shortSetupLatch6 := shortSetupAlertState6[1]
    shortSetupLatch7 := shortSetupAlertState7[1]
    shortSetupLatch8 := shortSetupAlertState8[1]

if not shortSetupAlertState1
    shortSetupLatch1 := false
if not shortSetupAlertState2
    shortSetupLatch2 := false
if not shortSetupAlertState3
    shortSetupLatch3 := false
if not shortSetupAlertState4
    shortSetupLatch4 := false
if not shortSetupAlertState5
    shortSetupLatch5 := false
if not shortSetupAlertState6
    shortSetupLatch6 := false
if not shortSetupAlertState7
    shortSetupLatch7 := false
if not shortSetupAlertState8
    shortSetupLatch8 := false

bool newShortSetup1 = shortSetupAlertState1 and not shortSetupLatch1
bool newShortSetup2 = shortSetupAlertState2 and not shortSetupLatch2
bool newShortSetup3 = shortSetupAlertState3 and not shortSetupLatch3
bool newShortSetup4 = shortSetupAlertState4 and not shortSetupLatch4
bool newShortSetup5 = shortSetupAlertState5 and not shortSetupLatch5
bool newShortSetup6 = shortSetupAlertState6 and not shortSetupLatch6
bool newShortSetup7 = shortSetupAlertState7 and not shortSetupLatch7
bool newShortSetup8 = shortSetupAlertState8 and not shortSetupLatch8

if newShortSetup1
    shortSetupLatch1 := true
if newShortSetup2
    shortSetupLatch2 := true
if newShortSetup3
    shortSetupLatch3 := true
if newShortSetup4
    shortSetupLatch4 := true
if newShortSetup5
    shortSetupLatch5 := true
if newShortSetup6
    shortSetupLatch6 := true
if newShortSetup7
    shortSetupLatch7 := true
if newShortSetup8
    shortSetupLatch8 := true

//=============================================================================
// CONFIRMED FIVE-MINUTE CLOSE TRANSITIONS
//=============================================================================

bool newLongConfirmed1 = barstate.isconfirmed and longConfirmedAlertState1 and not longConfirmedAlertState1[1]
bool newLongConfirmed2 = barstate.isconfirmed and longConfirmedAlertState2 and not longConfirmedAlertState2[1]
bool newLongConfirmed3 = barstate.isconfirmed and longConfirmedAlertState3 and not longConfirmedAlertState3[1]
bool newLongConfirmed4 = barstate.isconfirmed and longConfirmedAlertState4 and not longConfirmedAlertState4[1]
bool newLongConfirmed5 = barstate.isconfirmed and longConfirmedAlertState5 and not longConfirmedAlertState5[1]
bool newLongConfirmed6 = barstate.isconfirmed and longConfirmedAlertState6 and not longConfirmedAlertState6[1]
bool newLongConfirmed7 = barstate.isconfirmed and longConfirmedAlertState7 and not longConfirmedAlertState7[1]
bool newLongConfirmed8 = barstate.isconfirmed and longConfirmedAlertState8 and not longConfirmedAlertState8[1]

bool newShortConfirmed1 = barstate.isconfirmed and shortConfirmedAlertState1 and not shortConfirmedAlertState1[1]
bool newShortConfirmed2 = barstate.isconfirmed and shortConfirmedAlertState2 and not shortConfirmedAlertState2[1]
bool newShortConfirmed3 = barstate.isconfirmed and shortConfirmedAlertState3 and not shortConfirmedAlertState3[1]
bool newShortConfirmed4 = barstate.isconfirmed and shortConfirmedAlertState4 and not shortConfirmedAlertState4[1]
bool newShortConfirmed5 = barstate.isconfirmed and shortConfirmedAlertState5 and not shortConfirmedAlertState5[1]
bool newShortConfirmed6 = barstate.isconfirmed and shortConfirmedAlertState6 and not shortConfirmedAlertState6[1]
bool newShortConfirmed7 = barstate.isconfirmed and shortConfirmedAlertState7 and not shortConfirmedAlertState7[1]
bool newShortConfirmed8 = barstate.isconfirmed and shortConfirmedAlertState8 and not shortConfirmedAlertState8[1]

//=============================================================================
// BATCHED DYNAMIC ALERT MESSAGES
//=============================================================================

f_alert_line(
     string eventName,
     string fullSymbol,
     string directionText,
     int score,
     float price,
     int levelCode,
     float levelDistance,
     bool longDirection
) =>
    string levelKind = longDirection ? "Support " : "Resistance "
    str.format("{0} - {1} | {2} | Score {3}/100 | Price {4} | {5}{6}", eventName, f_display_symbol(fullSymbol), directionText, str.tostring(score), str.tostring(price, "0.00"), levelKind, f_alert_level_text(levelCode, levelDistance))

string setupBatch = ""
string confirmedBatch = ""

if newLongSetup1
    setupBatch += f_alert_line("SETUP FORMING", symbol1, "LONG", longScore1, p1, longLevel1, longDistance1, true) + "\n"
if newLongSetup2
    setupBatch += f_alert_line("SETUP FORMING", symbol2, "LONG", longScore2, p2, longLevel2, longDistance2, true) + "\n"
if newLongSetup3
    setupBatch += f_alert_line("SETUP FORMING", symbol3, "LONG", longScore3, p3, longLevel3, longDistance3, true) + "\n"
if newLongSetup4
    setupBatch += f_alert_line("SETUP FORMING", symbol4, "LONG", longScore4, p4, longLevel4, longDistance4, true) + "\n"
if newLongSetup5
    setupBatch += f_alert_line("SETUP FORMING", symbol5, "LONG", longScore5, p5, longLevel5, longDistance5, true) + "\n"
if newLongSetup6
    setupBatch += f_alert_line("SETUP FORMING", symbol6, "LONG", longScore6, p6, longLevel6, longDistance6, true) + "\n"
if newLongSetup7
    setupBatch += f_alert_line("SETUP FORMING", symbol7, "LONG", longScore7, p7, longLevel7, longDistance7, true) + "\n"
if newLongSetup8
    setupBatch += f_alert_line("SETUP FORMING", symbol8, "LONG", longScore8, p8, longLevel8, longDistance8, true) + "\n"

if newShortSetup1
    setupBatch += f_alert_line("SETUP FORMING", symbol1, "SHORT", shortScore1, p1, shortLevel1, shortDistance1, false) + "\n"
if newShortSetup2
    setupBatch += f_alert_line("SETUP FORMING", symbol2, "SHORT", shortScore2, p2, shortLevel2, shortDistance2, false) + "\n"
if newShortSetup3
    setupBatch += f_alert_line("SETUP FORMING", symbol3, "SHORT", shortScore3, p3, shortLevel3, shortDistance3, false) + "\n"
if newShortSetup4
    setupBatch += f_alert_line("SETUP FORMING", symbol4, "SHORT", shortScore4, p4, shortLevel4, shortDistance4, false) + "\n"
if newShortSetup5
    setupBatch += f_alert_line("SETUP FORMING", symbol5, "SHORT", shortScore5, p5, shortLevel5, shortDistance5, false) + "\n"
if newShortSetup6
    setupBatch += f_alert_line("SETUP FORMING", symbol6, "SHORT", shortScore6, p6, shortLevel6, shortDistance6, false) + "\n"
if newShortSetup7
    setupBatch += f_alert_line("SETUP FORMING", symbol7, "SHORT", shortScore7, p7, shortLevel7, shortDistance7, false) + "\n"
if newShortSetup8
    setupBatch += f_alert_line("SETUP FORMING", symbol8, "SHORT", shortScore8, p8, shortLevel8, shortDistance8, false) + "\n"

if newLongConfirmed1
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol1, "LONG", longScore1, p1, longLevel1, longDistance1, true) + "\n"
if newLongConfirmed2
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol2, "LONG", longScore2, p2, longLevel2, longDistance2, true) + "\n"
if newLongConfirmed3
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol3, "LONG", longScore3, p3, longLevel3, longDistance3, true) + "\n"
if newLongConfirmed4
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol4, "LONG", longScore4, p4, longLevel4, longDistance4, true) + "\n"
if newLongConfirmed5
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol5, "LONG", longScore5, p5, longLevel5, longDistance5, true) + "\n"
if newLongConfirmed6
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol6, "LONG", longScore6, p6, longLevel6, longDistance6, true) + "\n"
if newLongConfirmed7
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol7, "LONG", longScore7, p7, longLevel7, longDistance7, true) + "\n"
if newLongConfirmed8
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol8, "LONG", longScore8, p8, longLevel8, longDistance8, true) + "\n"

if newShortConfirmed1
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol1, "SHORT", shortScore1, p1, shortLevel1, shortDistance1, false) + "\n"
if newShortConfirmed2
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol2, "SHORT", shortScore2, p2, shortLevel2, shortDistance2, false) + "\n"
if newShortConfirmed3
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol3, "SHORT", shortScore3, p3, shortLevel3, shortDistance3, false) + "\n"
if newShortConfirmed4
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol4, "SHORT", shortScore4, p4, shortLevel4, shortDistance4, false) + "\n"
if newShortConfirmed5
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol5, "SHORT", shortScore5, p5, shortLevel5, shortDistance5, false) + "\n"
if newShortConfirmed6
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol6, "SHORT", shortScore6, p6, shortLevel6, shortDistance6, false) + "\n"
if newShortConfirmed7
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol7, "SHORT", shortScore7, p7, shortLevel7, shortDistance7, false) + "\n"
if newShortConfirmed8
    confirmedBatch += f_alert_line("ENTRY CONFIRMED", symbol8, "SHORT", shortScore8, p8, shortLevel8, shortDistance8, false) + "\n"

if setupBatch != ""
    alert(setupBatch, alert.freq_all)

if confirmedBatch != ""
    alert(confirmedBatch, alert.freq_once_per_bar_close)

//=============================================================================
// TABLE COLORS
//=============================================================================

color headerBackground        = color.rgb(27, 30, 36)
color bullishBackground       = color.rgb(30, 91, 67)
color strongBullishBackground = color.rgb(19, 121, 76)
color bearishBackground       = color.rgb(108, 48, 57)
color strongBearishBackground = color.rgb(151, 43, 56)
color watchBackground         = color.rgb(161, 104, 31)
color neutralBackground       = color.rgb(74, 78, 87)
color disabledBackground      = color.rgb(48, 51, 58)
color primaryText             = color.white
color borderColor             = color.rgb(62, 66, 75)

//=============================================================================
// TABLE TEXT AND COLOR HELPERS
//=============================================================================

f_bias_text(
     bool enabled,
     int sessionCode,
     int longCount,
     int shortCount
) =>
    not enabled
     ? "OFF"
     : sessionCode == 0
     ? "PRE"
     : sessionCode == 1
     ? "LOCKED"
     : sessionCode == 3
     ? "POST"
     : sessionCode == 4
     ? "CLOSED"
     : longCount > shortCount
     ? "LONG"
     : shortCount > longCount
     ? "SHORT"
     : "MIXED"

f_bias_color(
     bool enabled,
     int sessionCode,
     int longCount,
     int shortCount
) =>
    int direction = f_direction(longCount, shortCount)
    not enabled
     ? disabledBackground
     : sessionCode == 0
     ? neutralBackground
     : sessionCode == 1
     ? watchBackground
     : sessionCode == 3
     ? neutralBackground
     : sessionCode == 4
     ? disabledBackground
     : direction == 1
     ? longCount == 5 ? strongBullishBackground : bullishBackground
     : direction == -1
     ? shortCount == 5 ? strongBearishBackground : bearishBackground
     : watchBackground

f_score_text(
     bool enabled,
     int sessionCode,
     int longCount,
     int shortCount,
     int longScore,
     int shortScore
) =>
    bool displayable =
         enabled and
         f_entry_data_displayable(sessionCode)

    int direction =
         f_direction(longCount, shortCount)

    not displayable
     ? "—"
     : direction == 1
     ? str.tostring(longScore)
     : direction == -1
     ? str.tostring(shortScore)
     : "L" + str.tostring(longScore) + "/S" + str.tostring(shortScore)

f_level_display_text(
     bool enabled,
     int sessionCode,
     int longCount,
     int shortCount,
     int longLevelCode,
     float longDistanceAtr,
     int shortLevelCode,
     float shortDistanceAtr
) =>
    bool displayable =
         enabled and
         f_entry_data_displayable(sessionCode)

    int direction =
         f_direction(longCount, shortCount)

    string result = "—"

    if displayable
        if direction == 1
            result := f_level_text(longLevelCode, longDistanceAtr)
        else if direction == -1
            result := f_level_text(shortLevelCode, shortDistanceAtr)
        else
            bool longAvailable =
                 longLevelCode != 0 and
                 not na(longDistanceAtr)

            bool shortAvailable =
                 shortLevelCode != 0 and
                 not na(shortDistanceAtr)

            if longAvailable and shortAvailable
                result :=
                     longDistanceAtr <= shortDistanceAtr
                     ? "L " + f_level_text(longLevelCode, longDistanceAtr)
                     : "S " + f_level_text(shortLevelCode, shortDistanceAtr)
            else if longAvailable
                result := "L " + f_level_text(longLevelCode, longDistanceAtr)
            else if shortAvailable
                result := "S " + f_level_text(shortLevelCode, shortDistanceAtr)

    result

f_state_text(
     bool enabled,
     int sessionCode,
     int longCount,
     int shortCount,
     bool longSetup,
     bool shortSetup,
     bool longLive,
     bool shortLive,
     bool longConfirmed,
     bool shortConfirmed
) =>
    int direction =
         f_direction(longCount, shortCount)

    bool relevantConfirmed =
         direction == 1
         ? longConfirmed
         : direction == -1
         ? shortConfirmed
         : false

    bool relevantLive =
         direction == 1
         ? longLive
         : direction == -1
         ? shortLive
         : false

    bool relevantSetup =
         direction == 1
         ? longSetup
         : direction == -1
         ? shortSetup
         : false

    bool relevantFiveOfFive =
         direction == 1
         ? longCount == 5
         : direction == -1
         ? shortCount == 5
         : false

    not enabled
     ? "OFF"
     : sessionCode == 0
     ? "PRE"
     : sessionCode == 1
     ? "LOCKED"
     : sessionCode == 3
     ? "POST"
     : sessionCode == 4
     ? "CLOSED"
     : not esAvailable
     ? "SET ES"
     : relevantConfirmed and barstate.isconfirmed
     ? "CONFIRMED"
     : relevantLive
     ? "80+ LIVE"
     : relevantSetup
     ? "FORMING"
     : relevantFiveOfFive
     ? "5/5"
     : "WAIT"

f_state_color(
     bool enabled,
     int sessionCode,
     int longCount,
     int shortCount,
     bool longSetup,
     bool shortSetup,
     bool longLive,
     bool shortLive,
     bool longConfirmed,
     bool shortConfirmed
) =>
    int direction =
         f_direction(longCount, shortCount)

    bool relevantConfirmed =
         direction == 1
         ? longConfirmed
         : direction == -1
         ? shortConfirmed
         : false

    bool relevantLive =
         direction == 1
         ? longLive
         : direction == -1
         ? shortLive
         : false

    bool relevantSetup =
         direction == 1
         ? longSetup
         : direction == -1
         ? shortSetup
         : false

    bool relevantFiveOfFive =
         direction == 1
         ? longCount == 5
         : direction == -1
         ? shortCount == 5
         : false

    not enabled
     ? disabledBackground
     : sessionCode == 0
     ? neutralBackground
     : sessionCode == 1
     ? watchBackground
     : sessionCode == 3
     ? neutralBackground
     : sessionCode == 4
     ? disabledBackground
     : not esAvailable
     ? neutralBackground
     : relevantConfirmed or relevantLive
     ? direction == 1 ? strongBullishBackground : strongBearishBackground
     : relevantSetup
     ? watchBackground
     : relevantFiveOfFive
     ? direction == 1 ? bullishBackground : bearishBackground
     : neutralBackground

//=============================================================================
// TABLE DRAWING
//=============================================================================

tablePosition =
     scannerPosition == "Top Left"
     ? position.top_left
     : scannerPosition == "Top Center"
     ? position.top_center
     : scannerPosition == "Top Right"
     ? position.top_right
     : scannerPosition == "Bottom Left"
     ? position.bottom_left
     : scannerPosition == "Bottom Center"
     ? position.bottom_center
     : position.bottom_right

var table scanner = table.new(
     tablePosition,
     6,
     9,
     bgcolor = color.new(headerBackground, 5),
     frame_color = borderColor,
     frame_width = 1,
     border_color = borderColor,
     border_width = 1
)

f_table_row(
     int row,
     bool enabled,
     string fullSymbol,
     int sessionCode,
     int longCount,
     int shortCount,
     int longScore,
     int shortScore,
     int longLevelCode,
     float longDistanceAtr,
     int shortLevelCode,
     float shortDistanceAtr,
     bool longSetup,
     bool shortSetup,
     bool longLive,
     bool shortLive,
     bool longConfirmed,
     bool shortConfirmed
) =>
    string conditionsText =
         enabled
         ? "L" + str.tostring(longCount) + "/S" + str.tostring(shortCount)
         : "—"

    string scoreText =
         f_score_text(
              enabled,
              sessionCode,
              longCount,
              shortCount,
              longScore,
              shortScore
         )

    string levelText =
         f_level_display_text(
              enabled,
              sessionCode,
              longCount,
              shortCount,
              longLevelCode,
              longDistanceAtr,
              shortLevelCode,
              shortDistanceAtr
         )

    table.cell(scanner, 0, row, f_display_symbol(fullSymbol), bgcolor = enabled ? headerBackground : disabledBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 1, row, f_bias_text(enabled, sessionCode, longCount, shortCount), bgcolor = f_bias_color(enabled, sessionCode, longCount, shortCount), text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 2, row, conditionsText, bgcolor = enabled ? neutralBackground : disabledBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 3, row, scoreText, bgcolor = enabled ? neutralBackground : disabledBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 4, row, levelText, bgcolor = enabled ? neutralBackground : disabledBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 5, row, f_state_text(enabled, sessionCode, longCount, shortCount, longSetup, shortSetup, longLive, shortLive, longConfirmed, shortConfirmed), bgcolor = f_state_color(enabled, sessionCode, longCount, shortCount, longSetup, shortSetup, longLive, shortLive, longConfirmed, shortConfirmed), text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)

if barstate.islast
    table.set_position(scanner, tablePosition)
    table.clear(scanner, 0, 0, 5, 8)

    table.cell(scanner, 0, 0, "SYMBOL", bgcolor = headerBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 1, 0, "BIAS", bgcolor = headerBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 2, 0, "CONDITIONS", bgcolor = headerBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 3, 0, "SCORE", bgcolor = headerBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 4, 0, "LEVEL", bgcolor = headerBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)
    table.cell(scanner, 5, 0, chartIsFiveMinute ? "STATE" : "USE 5M", bgcolor = chartIsFiveMinute ? headerBackground : watchBackground, text_color = primaryText, text_size = size.tiny, text_halign = text.align_center)

    f_table_row(1, enableSymbol1, symbol1, session1, longCount1, shortCount1, longScore1, shortScore1, longLevel1, longDistance1, shortLevel1, shortDistance1, longSetupQualified1, shortSetupQualified1, longLiveQualified1, shortLiveQualified1, longConfirmedQualified1, shortConfirmedQualified1)
    f_table_row(2, enableSymbol2, symbol2, session2, longCount2, shortCount2, longScore2, shortScore2, longLevel2, longDistance2, shortLevel2, shortDistance2, longSetupQualified2, shortSetupQualified2, longLiveQualified2, shortLiveQualified2, longConfirmedQualified2, shortConfirmedQualified2)
    f_table_row(3, enableSymbol3, symbol3, session3, longCount3, shortCount3, longScore3, shortScore3, longLevel3, longDistance3, shortLevel3, shortDistance3, longSetupQualified3, shortSetupQualified3, longLiveQualified3, shortLiveQualified3, longConfirmedQualified3, shortConfirmedQualified3)
    f_table_row(4, enableSymbol4, symbol4, session4, longCount4, shortCount4, longScore4, shortScore4, longLevel4, longDistance4, shortLevel4, shortDistance4, longSetupQualified4, shortSetupQualified4, longLiveQualified4, shortLiveQualified4, longConfirmedQualified4, shortConfirmedQualified4)
    f_table_row(5, enableSymbol5, symbol5, session5, longCount5, shortCount5, longScore5, shortScore5, longLevel5, longDistance5, shortLevel5, shortDistance5, longSetupQualified5, shortSetupQualified5, longLiveQualified5, shortLiveQualified5, longConfirmedQualified5, shortConfirmedQualified5)
    f_table_row(6, enableSymbol6, symbol6, session6, longCount6, shortCount6, longScore6, shortScore6, longLevel6, longDistance6, shortLevel6, shortDistance6, longSetupQualified6, shortSetupQualified6, longLiveQualified6, shortLiveQualified6, longConfirmedQualified6, shortConfirmedQualified6)
    f_table_row(7, enableSymbol7, symbol7, session7, longCount7, shortCount7, longScore7, shortScore7, longLevel7, longDistance7, shortLevel7, shortDistance7, longSetupQualified7, shortSetupQualified7, longLiveQualified7, shortLiveQualified7, longConfirmedQualified7, shortConfirmedQualified7)
    f_table_row(8, enableSymbol8, symbol8, session8, longCount8, shortCount8, longScore8, shortScore8, longLevel8, longDistance8, shortLevel8, shortDistance8, longSetupQualified8, shortSetupQualified8, longLiveQualified8, shortLiveQualified8, longConfirmedQualified8, shortConfirmedQualified8)
````
