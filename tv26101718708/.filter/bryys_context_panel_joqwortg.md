# Bryy's Context Panel

- url: https://www.tradingview.com/script/JOqwOrtG-Bryy-s-Context-Panel/
- type: indicator
- pine_id: PUB;9dd1ee7a5a074c389e3b880006080962
- version: 18.0

## Description

Bryy’s Context Panel is a compact multi-symbol market context panel built to help traders monitor broader market and sector alignment without leaving their main execution chart.

The indicator checks selected symbols against configurable moving averages and adaptive VWAP, then displays a simple visual status for each metric:

✓ = price is above the selected metric
✕ = price is below the selected metric
- = data is unavailable or the metric is not applicable

The default use case is staying on a futures execution chart while monitoring external ETF context such as SOXX, QQQ, and SPY. This can help traders quickly see whether semiconductor, Nasdaq, and broad-market context are aligned or conflicting.

Main Features:

• Monitor up to 5 custom symbols
• Default focus on SOXX / QQQ / SPY market context
• Configurable SMA or EMA
• Three customizable moving average slots
• Optional custom timeframe per moving average
• Adaptive VWAP logic:
- Intraday charts: RTH Daily VWAP
- Daily charts: Week-Open VWAP
- Weekly charts: Month-Open VWAP
- Monthly+ charts: VWAP hidden in Auto mode
• Horizontal or vertical panel layout
• Adjustable panel size and placement
• Dark, light, and custom color themes
• Designed to be lightweight, clean, and fast

Intended Use:

This indicator is designed as a context scanner, not a buy/sell signal system.

It is meant to help answer questions like:

• Is SOXX supporting or fighting the trade idea?
• Is QQQ aligned with the current futures move?
• Is SPY confirming broader market direction?
• Are key context symbols above or below their short-term, medium-term, and longer-term reference levels?

The goal is to provide quick external market context while keeping the main chart clean.

Important Notes:

For US ETF symbols, the scanner is designed around regular-session context. When used outside regular market hours, values may reflect the most recent regular-session data depending on TradingView’s symbol/session handling.

VWAP depends on volume, so ETF symbols are generally better suited than non-volume index symbols for this tool.

This script does not predict price movement, generate entries, or provide financial advice. It is intended to support discretionary analysis by showing clear market context in a compact panel.

## Source Code

````pine
//@version=6
// Bryy's Context Panel
// Version 1.56 - Stable Table Lifecycle + Lightweight Updates
indicator("Bryy's Context Panel", overlay=true, dynamic_requests=true)

// -------------------------
// Groups
// -------------------------
const string GP_PLACEMENT = "Placement"
const string GP_STRENGTH = "Momentum Rows"
const string GP_METRICS = "Metrics"
const string GP_SYM1 = "Symbol 1"
const string GP_SYM2 = "Symbol 2"
const string GP_SYM3 = "Symbol 3"
const string GP_STYLE = "Style"

// -------------------------
// Tooltip - search "TT_" to edit this description
// -------------------------
const string TT_ATR_DISTANCE = "Applies ATR(14)-normalized distance tiers to both SMAs and VWAP. I is below 0.10 ATR, II is 0.10 to below 0.35, III is 0.35 to below 0.75, IV is 0.75 to below 1.50, and V is 1.50 ATR or more."
const string TT_MOMENTUM_ROWS = "Ranks symbols by raw percentage change over the selected window. It measures momentum, not MA/VWAP structure, and does not adjust for differences in volatility. Differences of 0.01 percentage points or less are shown as ties on every momentum timeframe."

// -------------------------
// Stability limits
// -------------------------
// 1,000 bars supports SMA lengths up to 1,000.
const int MA_REQUEST_BARS = 1000
// Used when chart price/ATR are needed but no chart-timeframe SMA is enabled.
const int CHART_PRICE_ATR_REQUEST_BARS = 50
// One-minute session bundle. 1,000 bars covers one complete 04:00-20:00 equity extended session.
const int SESSION_REQUEST_BARS = 1000
// Covers previous daily/weekly anchors and a complete month of daily bars for M-VWAP.
const int DAILY_REQUEST_BARS = 35

// TradingView marks Bar Replay charts by including "replay" in the chart ticker ID.
// Keep this dynamic instead of using `var`, so entering or leaving Replay updates
// the request path without requiring the indicator to be removed and re-added.
bool isReplay = str.contains(syminfo.tickerid, "replay")

// -------------------------
// Distance settings
// -------------------------
const int ATR_LENGTH = 14
const float DISTANCE_CLOSEST_ATR = 0.10
const float DISTANCE_CLOSE_ATR = 0.35
const float DISTANCE_MID_ATR = 0.75
const float DISTANCE_SUPER_FAR_ATR = 1.50
const float MOMENTUM_TIE_TOLERANCE = 0.01

// -------------------------
// Style settings
// -------------------------
themeOpt = input.string("Dark", "Panel Theme", options=["Dark", "Light"], group=GP_STYLE, display=display.none)
boldText = input.bool(true, "Bold Text", group=GP_STYLE, display=display.none)

aboveColor = input.color(color.rgb(76, 175, 80), "Above", group=GP_STYLE, inline="BASE", display=display.none)
belowColor = input.color(color.rgb(242, 54, 69), "Below", group=GP_STYLE, inline="BASE", display=display.none)

baseColor = themeOpt == "Dark" ? color.rgb(0, 0, 0) : color.white
textColor = themeOpt == "Dark" ? color.white : color.black
panelTextFormatting = boldText ? text.format_bold : text.format_none
errorBgColor = color.gray
spacerBg = color.new(baseColor, 100)
spacerText = color.new(textColor, 100)

// -------------------------
// Placement settings
// -------------------------
panelY = input.string("Bottom", "Vertical Position", options=["Top", "Middle", "Bottom"], group=GP_PLACEMENT, display=display.none)
panelX = input.string("Left", "Horizontal Position", options=["Left", "Center", "Right"], group=GP_PLACEMENT, display=display.none)
panelSizeOpt = input.string("Normal", "Panel Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GP_PLACEMENT, display=display.none)

verticalOffset = input.int(0, "Vertical Offset", minval=0, maxval=10, group=GP_PLACEMENT, inline="OFFSETS", display=display.none, active=panelY != "Middle")
horizontalOffset = input.int(0, "Horizontal Offset", minval=0, maxval=10, group=GP_PLACEMENT, inline="OFFSETS", display=display.none, active=panelX != "Center")

// -------------------------
// Momentum settings
// -------------------------
showStrengthRow1 = input.bool(false, "Momentum Row 1", group=GP_STRENGTH, inline="STR1", display=display.none)
strengthMode1 = input.string("M5", "", options=["M1", "M5", "M15", "H1", "1D", "1W"], group=GP_STRENGTH, inline="STR1", tooltip=TT_MOMENTUM_ROWS, display=display.none, active=showStrengthRow1)

showStrengthRow2 = input.bool(true, "Momentum Row 2", group=GP_STRENGTH, inline="STR2", display=display.none)
strengthMode2 = input.string("M15", "", options=["M1", "M5", "M15", "H1", "1D", "1W"], group=GP_STRENGTH, inline="STR2", tooltip=TT_MOMENTUM_ROWS, display=display.none, active=showStrengthRow2)

showStrengthRow3 = input.bool(true, "Momentum Row 3", group=GP_STRENGTH, inline="STR3", display=display.none)
strengthMode3 = input.string("1D", "", options=["M1", "M5", "M15", "H1", "1D", "1W"], group=GP_STRENGTH, inline="STR3", tooltip=TT_MOMENTUM_ROWS, display=display.none, active=showStrengthRow3)

// -------------------------
// Metrics settings
// -------------------------
useATRDistanceTiers = input.bool(true, "ATR Distance Tiers", group=GP_METRICS, tooltip=TT_ATR_DISTANCE, display=display.none)

showMA1 = input.bool(true, "SMA 1", group=GP_METRICS, inline="MA1", display=display.none)
ma1Len = input.int(9, "Length", minval=1, maxval=1000, group=GP_METRICS, inline="MA1", display=display.none)
ma1TfInput = input.timeframe("", "TF", group=GP_METRICS, inline="MA1", display=display.none)

showMA2 = input.bool(true, "SMA 2", group=GP_METRICS, inline="MA2", display=display.none)
ma2Len = input.int(21, "Length", minval=1, maxval=1000, group=GP_METRICS, inline="MA2", display=display.none)
ma2TfInput = input.timeframe("", "TF", group=GP_METRICS, inline="MA2", display=display.none)

showMA3 = input.bool(true, "SMA 3", group=GP_METRICS, inline="MA3", display=display.none)
ma3Len = input.int(50, "Length", minval=1, maxval=1000, group=GP_METRICS, inline="MA3", display=display.none)
ma3TfInput = input.timeframe("", "TF", group=GP_METRICS, inline="MA3", display=display.none)

showVWAP = input.bool(true, "Show VWAP", group=GP_METRICS, display=display.none)

// -------------------------
// Symbols
// -------------------------
showSym1 = input.bool(true, "Show Symbol 1", group=GP_SYM1, display=display.none)
label1 = input.string("SOXX", "Label", group=GP_SYM1, inline="S1", display=display.none, active=showSym1)
sym1 = input.symbol("NASDAQ:SOXX", "Ticker", group=GP_SYM1, inline="S1", display=display.none, active=showSym1)

showSym2 = input.bool(true, "Show Symbol 2", group=GP_SYM2, display=display.none)
label2 = input.string("QQQ", "Label", group=GP_SYM2, inline="S2", display=display.none, active=showSym2)
sym2 = input.symbol("NASDAQ:QQQ", "Ticker", group=GP_SYM2, inline="S2", display=display.none, active=showSym2)

showSym3 = input.bool(true, "Show Symbol 3", group=GP_SYM3, display=display.none)
label3 = input.string("SPY", "Label", group=GP_SYM3, inline="S3", display=display.none, active=showSym3)
sym3 = input.symbol("AMEX:SPY", "Ticker", group=GP_SYM3, inline="S3", display=display.none, active=showSym3)

// -------------------------
// U.S. equity sessions and automatic host-chart detection
// -------------------------
const string PREMARKET_SESSION = "0400-0930:23456"
const string RTH_SESSION = "0930-1600:23456"
const string POSTMARKET_SESSION = "1600-2000:23456"
const string EXTENDED_SESSION = "0400-2000:23456"
const string US_EQUITY_TIMEZONE = "America/New_York"

// On most U.S. futures, including MES/MNQ, TradingView names the full electronic
// session "regular" and the shorter cash-hours subsession "us_regular".
// On stocks/ETFs, the chart session is "regular" or "extended".
// The host chart therefore controls which session SOXX/QQQ/SPY requests use.
bool hostChartUsesETH = syminfo.type == "futures" ? syminfo.session == "regular" : syminfo.session == session.extended

// -------------------------
// Final timeframes and modes
// -------------------------
ma1Tf = ma1TfInput == "" ? timeframe.period : ma1TfInput
ma2Tf = ma2TfInput == "" ? timeframe.period : ma2TfInput
ma3Tf = ma3TfInput == "" ? timeframe.period : ma3TfInput

autoVwapMode = timeframe.isintraday ? "Intraday" : timeframe.isdaily ? "Week Open" : timeframe.isweekly ? "Month Open" : "Off"
finalVwapMode = autoVwapMode
vwapVisible = showVWAP and finalVwapMode != "Off"

row1IsDaily = showStrengthRow1 and strengthMode1 == "1D"
row2IsDaily = showStrengthRow2 and strengthMode2 == "1D"
row3IsDaily = showStrengthRow3 and strengthMode3 == "1D"
row1IsWeekly = showStrengthRow1 and strengthMode1 == "1W"
row2IsWeekly = showStrengthRow2 and strengthMode2 == "1W"
row3IsWeekly = showStrengthRow3 and strengthMode3 == "1W"
row1IsRecent = showStrengthRow1 and strengthMode1 != "1D" and strengthMode1 != "1W"
row2IsRecent = showStrengthRow2 and strengthMode2 != "1D" and strengthMode2 != "1W"
row3IsRecent = showStrengthRow3 and strengthMode3 != "1D" and strengthMode3 != "1W"
needsAnchorStrength = row1IsDaily or row2IsDaily or row3IsDaily or row1IsWeekly or row2IsWeekly or row3IsWeekly
needsRecentStrength = row1IsRecent or row2IsRecent or row3IsRecent
needsSessionRequest = (vwapVisible and finalVwapMode == "Intraday") or needsRecentStrength
needsDailyRequest = needsAnchorStrength or finalVwapMode == "Week Open" or finalVwapMode == "Month Open"

// -------------------------
// Position and size
// -------------------------
panelPos = switch
    panelY == "Top" and panelX == "Left" => position.top_left
    panelY == "Top" and panelX == "Center" => position.top_center
    panelY == "Top" and panelX == "Right" => position.top_right
    panelY == "Middle" and panelX == "Left" => position.middle_left
    panelY == "Middle" and panelX == "Center" => position.middle_center
    panelY == "Middle" and panelX == "Right" => position.middle_right
    panelY == "Bottom" and panelX == "Left" => position.bottom_left
    panelY == "Bottom" and panelX == "Center" => position.bottom_center
    => position.bottom_right

txtSize = switch panelSizeOpt
    "Tiny" => size.tiny
    "Small" => size.tiny
    "Normal" => size.small
    "Large" => size.normal
    => size.large

isCompact = panelSizeOpt == "Tiny"
vOffset = panelY == "Middle" ? 0 : verticalOffset
hOffset = panelX == "Center" ? 0 : horizontalOffset
startCol = panelX == "Left" ? hOffset : 0
startRow = panelY == "Top" ? vOffset : 0

strengthRowCount = (showStrengthRow1 ? 1 : 0) + (showStrengthRow2 ? 1 : 0) + (showStrengthRow3 ? 1 : 0)
strengthExtraRows = strengthRowCount > 0 ? strengthRowCount * 2 : 0
contentStartRow = startRow + strengthExtraRows
horizontalCols = 1 + (showMA1 ? 1 : 0) + (showMA2 ? 1 : 0) + (showMA3 ? 1 : 0) + (vwapVisible ? 1 : 0)

// -------------------------
// Calculation helpers
// -------------------------
f_ma(_src, _len) =>
    ta.sma(_src, _len)

isFullTickerId(_s) =>
    _s != "" and str.contains(_s, ":")

// Calculates the intraday VWAP used by the panel in whichever timeframe context calls it.
// RTH mode: standard RTH VWAP from 09:30.
// ETH mode: premarket VWAP from 04:00 before the open, then a fresh RTH VWAP
// from 09:30 that remains displayed through the 16:00-20:00 postmarket.
f_selected_intraday_vwap(_useExtended) =>
    bool inPremarket = _useExtended and not na(time("", PREMARKET_SESSION, US_EQUITY_TIMEZONE))
    bool inRth = not na(time("", RTH_SESSION, US_EQUITY_TIMEZONE))
    bool inPostmarket = _useExtended and not na(time("", POSTMARKET_SESSION, US_EQUITY_TIMEZONE))

    bool prevInPremarket = bar_index > 0 ? inPremarket[1] : false
    bool prevInRth = bar_index > 0 ? inRth[1] : false
    bool newPremarket = inPremarket and (not prevInPremarket or timeframe.change("D"))
    bool newRth = inRth and (not prevInRth or timeframe.change("D"))

    var float premarketPV = na
    var float premarketVol = na
    var float rthPV = na
    var float rthVol = na

    if newPremarket
        premarketPV := hlc3 * volume
        premarketVol := volume
    else if inPremarket
        premarketPV := nz(premarketPV) + hlc3 * volume
        premarketVol := nz(premarketVol) + volume

    if newRth
        rthPV := hlc3 * volume
        rthVol := volume
    else if inRth
        rthPV := nz(rthPV) + hlc3 * volume
        rthVol := nz(rthVol) + volume

    float premarketVwap = not na(premarketVol) and premarketVol > 0 ? premarketPV / premarketVol : na
    float rthVwap = not na(rthVol) and rthVol > 0 ? rthPV / rthVol : na

    _useExtended ? (inPremarket ? premarketVwap : (inRth or inPostmarket ? rthVwap : na)) : (inRth ? rthVwap : na)

// Precise one-minute session bundle.
// RTH charts use 09:30-16:00. ETH charts use the ETF's 04:00-20:00 session.
// Intraday momentum follows the selected session continuously; the VWAP itself
// switches from premarket VWAP to a fresh RTH VWAP at 09:30.
f_intraday_bundle_1m(_needVwap, _useExtended, _use1, _mode1, _use2, _mode2, _use3, _mode3) =>
    // The longest conditional history reference in this context is 60 one-minute bars.
    // Size these buffers explicitly so a live H1 window cannot exceed a buffer that
    // TradingView inferred from earlier historical executions.
    max_bars_back(open, 60)
    max_bars_back(time, 60)

    bool inSess = _useExtended ? not na(time("", EXTENDED_SESSION, US_EQUITY_TIMEZONE)) : not na(time("", RTH_SESSION, US_EQUITY_TIMEZONE))
    bool prevInSess = bar_index > 0 ? inSess[1] : false
    bool newSess = inSess and (session.isfirstbar or not prevInSess or timeframe.change("D"))

    float sessionVwap = _needVwap ? f_selected_intraday_vwap(_useExtended) : na
    bool vwapIsPremarket = _useExtended and not na(time("", PREMARKET_SESSION, US_EQUITY_TIMEZONE))

    int sessionStartTime = ta.valuewhen(newSess, time, 0)
    float sessionOpen = ta.valuewhen(newSess, open, 0)
    float elapsedMinutes = inSess and not na(sessionStartTime) ? (time - sessionStartTime) / 60000.0 : na

    float reference1 = na
    float reference2 = na
    float reference3 = na
    bool full1 = not _use1
    bool full2 = not _use2
    bool full3 = not _use3

    if inSess and not na(elapsedMinutes) and not na(sessionOpen)
        if _use1
            if _mode1 == "M1"
                full1 := elapsedMinutes >= 1 and not na(time[1]) and time[1] >= sessionStartTime
                reference1 := full1 ? open[1] : sessionOpen
            else if _mode1 == "M5"
                full1 := elapsedMinutes >= 5 and not na(time[5]) and time[5] >= sessionStartTime
                reference1 := full1 ? open[5] : sessionOpen
            else if _mode1 == "M15"
                full1 := elapsedMinutes >= 15 and not na(time[15]) and time[15] >= sessionStartTime
                reference1 := full1 ? open[15] : sessionOpen
            else if _mode1 == "H1"
                full1 := elapsedMinutes >= 60 and not na(time[60]) and time[60] >= sessionStartTime
                reference1 := full1 ? open[60] : sessionOpen

        if _use2
            if _mode2 == "M1"
                full2 := elapsedMinutes >= 1 and not na(time[1]) and time[1] >= sessionStartTime
                reference2 := full2 ? open[1] : sessionOpen
            else if _mode2 == "M5"
                full2 := elapsedMinutes >= 5 and not na(time[5]) and time[5] >= sessionStartTime
                reference2 := full2 ? open[5] : sessionOpen
            else if _mode2 == "M15"
                full2 := elapsedMinutes >= 15 and not na(time[15]) and time[15] >= sessionStartTime
                reference2 := full2 ? open[15] : sessionOpen
            else if _mode2 == "H1"
                full2 := elapsedMinutes >= 60 and not na(time[60]) and time[60] >= sessionStartTime
                reference2 := full2 ? open[60] : sessionOpen

        if _use3
            if _mode3 == "M1"
                full3 := elapsedMinutes >= 1 and not na(time[1]) and time[1] >= sessionStartTime
                reference3 := full3 ? open[1] : sessionOpen
            else if _mode3 == "M5"
                full3 := elapsedMinutes >= 5 and not na(time[5]) and time[5] >= sessionStartTime
                reference3 := full3 ? open[5] : sessionOpen
            else if _mode3 == "M15"
                full3 := elapsedMinutes >= 15 and not na(time[15]) and time[15] >= sessionStartTime
                reference3 := full3 ? open[15] : sessionOpen
            else if _mode3 == "H1"
                full3 := elapsedMinutes >= 60 and not na(time[60]) and time[60] >= sessionStartTime
                reference3 := full3 ? open[60] : sessionOpen

    float strength1 = _use1 and not na(reference1) and reference1 != 0 ? ((close / reference1) - 1.0) * 100.0 : na
    float strength2 = _use2 and not na(reference2) and reference2 != 0 ? ((close / reference2) - 1.0) * 100.0 : na
    float strength3 = _use3 and not na(reference3) and reference3 != 0 ? ((close / reference3) - 1.0) * 100.0 : na

    [sessionVwap, strength1, strength2, strength3, full1, full2, full3, vwapIsPremarket]

// Five-minute replay fallback for selected-session VWAP and momentum.
// It is requested in Replay whenever either intraday VWAP or intraday momentum
// is enabled, so the fallback context is available before realtime-like updates.
// Live charts do not request it.
f_intraday_bundle_5m(_needVwap, _useExtended, _use1, _mode1, _use2, _mode2, _use3, _mode3) =>
    // The five-minute fallback references up to 12 bars. A 60-bar buffer keeps the
    // fallback aligned with the primary one-minute bundle while remaining small.
    max_bars_back(open, 60)
    max_bars_back(time, 60)

    bool inSess = _useExtended ? not na(time("", EXTENDED_SESSION, US_EQUITY_TIMEZONE)) : not na(time("", RTH_SESSION, US_EQUITY_TIMEZONE))
    bool prevInSess = bar_index > 0 ? inSess[1] : false
    bool newSess = inSess and (session.isfirstbar or not prevInSess or timeframe.change("D"))

    float sessionVwap = _needVwap ? f_selected_intraday_vwap(_useExtended) : na
    bool vwapIsPremarket = _useExtended and not na(time("", PREMARKET_SESSION, US_EQUITY_TIMEZONE))

    int sessionStartTime = ta.valuewhen(newSess, time, 0)
    float sessionOpen = ta.valuewhen(newSess, open, 0)
    float elapsedMinutes = inSess and not na(sessionStartTime) ? (time - sessionStartTime) / 60000.0 : na

    float reference1 = na
    float reference2 = na
    float reference3 = na
    bool full1 = not _use1
    bool full2 = not _use2
    bool full3 = not _use3

    if inSess and not na(elapsedMinutes) and not na(sessionOpen)
        if _use1
            if _mode1 == "M5"
                full1 := elapsedMinutes >= 5 and not na(time[1]) and time[1] >= sessionStartTime
                reference1 := full1 ? open[1] : sessionOpen
            else if _mode1 == "M15"
                full1 := elapsedMinutes >= 15 and not na(time[3]) and time[3] >= sessionStartTime
                reference1 := full1 ? open[3] : sessionOpen
            else if _mode1 == "H1"
                full1 := elapsedMinutes >= 60 and not na(time[12]) and time[12] >= sessionStartTime
                reference1 := full1 ? open[12] : sessionOpen

        if _use2
            if _mode2 == "M5"
                full2 := elapsedMinutes >= 5 and not na(time[1]) and time[1] >= sessionStartTime
                reference2 := full2 ? open[1] : sessionOpen
            else if _mode2 == "M15"
                full2 := elapsedMinutes >= 15 and not na(time[3]) and time[3] >= sessionStartTime
                reference2 := full2 ? open[3] : sessionOpen
            else if _mode2 == "H1"
                full2 := elapsedMinutes >= 60 and not na(time[12]) and time[12] >= sessionStartTime
                reference2 := full2 ? open[12] : sessionOpen

        if _use3
            if _mode3 == "M5"
                full3 := elapsedMinutes >= 5 and not na(time[1]) and time[1] >= sessionStartTime
                reference3 := full3 ? open[1] : sessionOpen
            else if _mode3 == "M15"
                full3 := elapsedMinutes >= 15 and not na(time[3]) and time[3] >= sessionStartTime
                reference3 := full3 ? open[3] : sessionOpen
            else if _mode3 == "H1"
                full3 := elapsedMinutes >= 60 and not na(time[12]) and time[12] >= sessionStartTime
                reference3 := full3 ? open[12] : sessionOpen

    float strength1 = _use1 and not na(reference1) and reference1 != 0 ? ((close / reference1) - 1.0) * 100.0 : na
    float strength2 = _use2 and not na(reference2) and reference2 != 0 ? ((close / reference2) - 1.0) * 100.0 : na
    float strength3 = _use3 and not na(reference3) and reference3 != 0 ? ((close / reference3) - 1.0) * 100.0 : na

    [sessionVwap, strength1, strength2, strength3, full1, full2, full3, vwapIsPremarket]

f_daily_bundle() =>
    bool newWeek = timeframe.change("W")
    bool newMonth = timeframe.change("M")

    var float weekPV = na
    var float weekVol = na
    var float monthPV = na
    var float monthVol = na

    if newWeek or na(weekPV) or na(weekVol)
        weekPV := hlc3 * volume
        weekVol := volume
    else
        weekPV := nz(weekPV) + hlc3 * volume
        weekVol := nz(weekVol) + volume

    if newMonth or na(monthPV) or na(monthVol)
        monthPV := hlc3 * volume
        monthVol := volume
    else
        monthPV := nz(monthPV) + hlc3 * volume
        monthVol := nz(monthVol) + volume

    float previousDailyClose = close[1]
    float previousWeeklyClose = ta.valuewhen(newWeek, close[1], 0)
    float weekVwap = not na(weekVol) and weekVol > 0 ? weekPV / weekVol : na
    float monthVwap = not na(monthVol) and monthVol > 0 ? monthPV / monthVol : na

    [previousDailyClose, previousWeeklyClose, weekVwap, monthVwap]

// -------------------------
// Replay-aware request helpers
// -------------------------
f_request_chart_bundle(_dataSym, _useExtended, _needsPrice, _needsAtr, _needChartVwap, _ma1OnChart, _ma2OnChart, _ma3OnChart) =>
    float reqPx = na
    float reqAtr = na
    float reqChartVwap = na
    float reqMa1 = na
    float reqMa2 = na
    float reqMa3 = na

    if isReplay
        [pxValue, atrValue, chartVwapValue, ma1Value, ma2Value, ma3Value] = request.security(_dataSym, timeframe.period, [_needsPrice ? close : float(na), _needsAtr ? ta.atr(ATR_LENGTH) : float(na), _needChartVwap ? f_selected_intraday_vwap(_useExtended) : float(na), _ma1OnChart ? f_ma(close, ma1Len) : float(na), _ma2OnChart ? f_ma(close, ma2Len) : float(na), _ma3OnChart ? f_ma(close, ma3Len) : float(na)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
        reqPx := pxValue
        reqAtr := atrValue
        reqChartVwap := chartVwapValue
        reqMa1 := ma1Value
        reqMa2 := ma2Value
        reqMa3 := ma3Value
    else
        [pxValue, atrValue, chartVwapValue, ma1Value, ma2Value, ma3Value] = request.security(_dataSym, timeframe.period, [_needsPrice ? close : float(na), _needsAtr ? ta.atr(ATR_LENGTH) : float(na), _needChartVwap ? f_selected_intraday_vwap(_useExtended) : float(na), _ma1OnChart ? f_ma(close, ma1Len) : float(na), _ma2OnChart ? f_ma(close, ma2Len) : float(na), _ma3OnChart ? f_ma(close, ma3Len) : float(na)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=MA_REQUEST_BARS)
        reqPx := pxValue
        reqAtr := atrValue
        reqChartVwap := chartVwapValue
        reqMa1 := ma1Value
        reqMa2 := ma2Value
        reqMa3 := ma3Value

    [reqPx, reqAtr, reqChartVwap, reqMa1, reqMa2, reqMa3]

f_request_price_atr_vwap(_dataSym, _useExtended, _needsAtr, _needChartVwap) =>
    float reqPx = na
    float reqAtr = na
    float reqChartVwap = na

    if isReplay
        [pxValue, atrValue, chartVwapValue] = request.security(_dataSym, timeframe.period, [close, _needsAtr ? ta.atr(ATR_LENGTH) : float(na), _needChartVwap ? f_selected_intraday_vwap(_useExtended) : float(na)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
        reqPx := pxValue
        reqAtr := atrValue
        reqChartVwap := chartVwapValue
    else if _needChartVwap
        [pxValue, atrValue, chartVwapValue] = request.security(_dataSym, timeframe.period, [close, _needsAtr ? ta.atr(ATR_LENGTH) : float(na), f_selected_intraday_vwap(_useExtended)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=MA_REQUEST_BARS)
        reqPx := pxValue
        reqAtr := atrValue
        reqChartVwap := chartVwapValue
    else
        [pxValue, atrValue] = request.security(_dataSym, timeframe.period, [close, _needsAtr ? ta.atr(ATR_LENGTH) : float(na)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=CHART_PRICE_ATR_REQUEST_BARS)
        reqPx := pxValue
        reqAtr := atrValue

    [reqPx, reqAtr, reqChartVwap]

f_request_ma_bundle(_dataSym, _tf, _len) =>
    float reqMa = na
    float reqAtr = na

    if isReplay
        [maValue, atrValue] = request.security(_dataSym, _tf, [f_ma(close, _len), useATRDistanceTiers ? ta.atr(ATR_LENGTH) : float(na)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
        reqMa := maValue
        reqAtr := atrValue
    else
        [maValue, atrValue] = request.security(_dataSym, _tf, [f_ma(close, _len), useATRDistanceTiers ? ta.atr(ATR_LENGTH) : float(na)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=MA_REQUEST_BARS)
        reqMa := maValue
        reqAtr := atrValue

    [reqMa, reqAtr]

f_request_session_bundle(_dataSym, _useExtended) =>
    float reqVwap = na
    float reqRecent1 = na
    float reqRecent2 = na
    float reqRecent3 = na
    bool reqFull1 = not row1IsRecent
    bool reqFull2 = not row2IsRecent
    bool reqFull3 = not row3IsRecent
    bool reqVwapIsPremarket = false

    if isReplay
        [vwapValue, recent1Value, recent2Value, recent3Value, full1Value, full2Value, full3Value, vwapIsPremarketValue] = request.security(_dataSym, "1", f_intraday_bundle_1m(vwapVisible and finalVwapMode == "Intraday", _useExtended, row1IsRecent, strengthMode1, row2IsRecent, strengthMode2, row3IsRecent, strengthMode3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

        reqVwap := vwapValue
        reqRecent1 := recent1Value
        reqRecent2 := recent2Value
        reqRecent3 := recent3Value
        reqFull1 := full1Value
        reqFull2 := full2Value
        reqFull3 := full3Value
        reqVwapIsPremarket := vwapIsPremarketValue

        if needsRecentStrength or (vwapVisible and finalVwapMode == "Intraday")
            [vwapValue5, recent1Value5, recent2Value5, recent3Value5, full1Value5, full2Value5, full3Value5, vwapIsPremarketValue5] = request.security(_dataSym, "5", f_intraday_bundle_5m(vwapVisible and finalVwapMode == "Intraday", _useExtended, row1IsRecent, strengthMode1, row2IsRecent, strengthMode2, row3IsRecent, strengthMode3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

            if na(reqVwap)
                reqVwap := vwapValue5
                reqVwapIsPremarket := vwapIsPremarketValue5
            if row1IsRecent and na(reqRecent1)
                if strengthMode1 == "M1"
                    reqFull1 := true
                else
                    reqRecent1 := recent1Value5
                    reqFull1 := full1Value5
            if row2IsRecent and na(reqRecent2)
                if strengthMode2 == "M1"
                    reqFull2 := true
                else
                    reqRecent2 := recent2Value5
                    reqFull2 := full2Value5
            if row3IsRecent and na(reqRecent3)
                if strengthMode3 == "M1"
                    reqFull3 := true
                else
                    reqRecent3 := recent3Value5
                    reqFull3 := full3Value5
    else
        [vwapValue, recent1Value, recent2Value, recent3Value, full1Value, full2Value, full3Value, vwapIsPremarketValue] = request.security(_dataSym, "1", f_intraday_bundle_1m(vwapVisible and finalVwapMode == "Intraday", _useExtended, row1IsRecent, strengthMode1, row2IsRecent, strengthMode2, row3IsRecent, strengthMode3), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=SESSION_REQUEST_BARS)
        reqVwap := vwapValue
        reqRecent1 := recent1Value
        reqRecent2 := recent2Value
        reqRecent3 := recent3Value
        reqFull1 := full1Value
        reqFull2 := full2Value
        reqFull3 := full3Value
        reqVwapIsPremarket := vwapIsPremarketValue

    [reqVwap, reqRecent1, reqRecent2, reqRecent3, reqFull1, reqFull2, reqFull3, reqVwapIsPremarket]

f_request_daily_bundle(_dataSym) =>
    float reqPreviousDailyClose = na
    float reqPreviousWeeklyClose = na
    float reqWeekVwap = na
    float reqMonthVwap = na

    if isReplay
        [dailyCloseValue, weeklyCloseValue, weekVwapValue, monthVwapValue] = request.security(_dataSym, "D", f_daily_bundle(), gaps=barmerge.gaps_off, lookahead=timeframe.isintraday ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true)
        reqPreviousDailyClose := dailyCloseValue
        reqPreviousWeeklyClose := weeklyCloseValue
        reqWeekVwap := weekVwapValue
        reqMonthVwap := monthVwapValue
    else
        [dailyCloseValue, weeklyCloseValue, weekVwapValue, monthVwapValue] = request.security(_dataSym, "D", f_daily_bundle(), gaps=barmerge.gaps_off, lookahead=timeframe.isintraday ? barmerge.lookahead_on : barmerge.lookahead_off, ignore_invalid_symbol=true, calc_bars_count=DAILY_REQUEST_BARS)
        reqPreviousDailyClose := dailyCloseValue
        reqPreviousWeeklyClose := weeklyCloseValue
        reqWeekVwap := weekVwapValue
        reqMonthVwap := monthVwapValue

    [reqPreviousDailyClose, reqPreviousWeeklyClose, reqWeekVwap, reqMonthVwap]

f_symbol_all(_sym, _enabled) =>
    float px = na
    float chartAtr = na
    float chartVwapFallback = na

    float ma1Val = na
    float ma2Val = na
    float ma3Val = na
    float atr1Val = na
    float atr2Val = na
    float atr3Val = na
    float vwapVal = na

    float dailyStrength = na
    float weeklyStrength = na
    float recent1 = na
    float recent2 = na
    float recent3 = na
    bool recentFull1 = not row1IsRecent
    bool recentFull2 = not row2IsRecent
    bool recentFull3 = not row3IsRecent
    bool vwapIsPremarket = false

    bool ma1Valid = false
    bool ma2Valid = false
    bool ma3Valid = false
    bool vwapValid = false

    bool aboveMA1 = false
    bool aboveMA2 = false
    bool aboveMA3 = false
    bool aboveVWAP = false

    float ma1DistanceAtr = na
    float ma2DistanceAtr = na
    float ma3DistanceAtr = na
    float vwapDistanceAtr = na

    if _enabled and isFullTickerId(_sym)
        // TradingView Bar Replay can return/stall `na` values when request.security()
        // uses a constructed ticker ID with a custom session. In Replay, use the
        // stable raw symbol ID instead. Raw U.S. equity symbols resolve to their
        // regular session, so Replay intentionally uses RTH data for reliability.
        // Live charts keep the full automatic RTH/ETH behavior unchanged.
        bool effectiveUseExtended = hostChartUsesETH and not isReplay
        chartDataSym = isReplay ? _sym : ticker.modify(_sym, effectiveUseExtended ? session.extended : session.regular)
        regularDataSym = isReplay ? _sym : ticker.modify(_sym, session.regular)

        bool ma1OnChart = showMA1 and ma1Tf == timeframe.period
        bool ma2OnChart = showMA2 and ma2Tf == timeframe.period
        bool ma3OnChart = showMA3 and ma3Tf == timeframe.period
        int chartMaCount = (ma1OnChart ? 1 : 0) + (ma2OnChart ? 1 : 0) + (ma3OnChart ? 1 : 0)
        bool needsChartPrice = showMA1 or showMA2 or showMA3 or vwapVisible or needsAnchorStrength
        bool needsChartAtr = useATRDistanceTiers and (chartMaCount > 0 or vwapVisible)
        bool needsChartVwapFallback = vwapVisible and finalVwapMode == "Intraday"

        if chartMaCount > 0
            [pxChartRequest, chartAtrRequest, chartVwapRequest, ma1ChartRequest, ma2ChartRequest, ma3ChartRequest] = f_request_chart_bundle(chartDataSym, effectiveUseExtended, needsChartPrice, needsChartAtr, needsChartVwapFallback, ma1OnChart, ma2OnChart, ma3OnChart)
            px := pxChartRequest
            chartAtr := chartAtrRequest
            chartVwapFallback := chartVwapRequest
            ma1Val := ma1OnChart ? ma1ChartRequest : ma1Val
            ma2Val := ma2OnChart ? ma2ChartRequest : ma2Val
            ma3Val := ma3OnChart ? ma3ChartRequest : ma3Val
            atr1Val := ma1OnChart ? chartAtrRequest : atr1Val
            atr2Val := ma2OnChart ? chartAtrRequest : atr2Val
            atr3Val := ma3OnChart ? chartAtrRequest : atr3Val
        else if needsChartPrice
            [pxChartRequest, chartAtrRequest, chartVwapRequest] = f_request_price_atr_vwap(chartDataSym, effectiveUseExtended, needsChartAtr, needsChartVwapFallback)
            px := pxChartRequest
            chartAtr := chartAtrRequest
            chartVwapFallback := chartVwapRequest

        if showMA1 and not ma1OnChart
            [ma1Request, atr1Request] = f_request_ma_bundle(chartDataSym, ma1Tf, ma1Len)
            ma1Val := ma1Request
            atr1Val := atr1Request

        if showMA2 and not ma2OnChart
            [ma2Request, atr2Request] = f_request_ma_bundle(chartDataSym, ma2Tf, ma2Len)
            ma2Val := ma2Request
            atr2Val := atr2Request

        if showMA3 and not ma3OnChart
            [ma3Request, atr3Request] = f_request_ma_bundle(chartDataSym, ma3Tf, ma3Len)
            ma3Val := ma3Request
            atr3Val := atr3Request

        if needsSessionRequest
            [sessionVwapRequest, recent1Request, recent2Request, recent3Request, recentFull1Request, recentFull2Request, recentFull3Request, sessionVwapIsPremarket] = f_request_session_bundle(chartDataSym, effectiveUseExtended)
            if finalVwapMode == "Intraday"
                vwapVal := not na(sessionVwapRequest) ? sessionVwapRequest : chartVwapFallback
            recent1 := recent1Request
            recent2 := recent2Request
            recent3 := recent3Request
            recentFull1 := recentFull1Request
            recentFull2 := recentFull2Request
            recentFull3 := recentFull3Request
            vwapIsPremarket := sessionVwapIsPremarket
        else if finalVwapMode == "Intraday"
            vwapVal := chartVwapFallback

        if needsDailyRequest
            [previousDailyClose, previousWeeklyClose, weekVwapRequest, monthVwapRequest] = f_request_daily_bundle(regularDataSym)

            if finalVwapMode == "Week Open"
                vwapVal := weekVwapRequest
            else if finalVwapMode == "Month Open"
                vwapVal := monthVwapRequest

            dailyStrength := needsAnchorStrength and not na(px) and not na(previousDailyClose) and previousDailyClose != 0 ? ((px / previousDailyClose) - 1.0) * 100.0 : na
            weeklyStrength := needsAnchorStrength and not na(px) and not na(previousWeeklyClose) and previousWeeklyClose != 0 ? ((px / previousWeeklyClose) - 1.0) * 100.0 : na

        if showMA1
            ma1Valid := not na(px) and not na(ma1Val)
            aboveMA1 := ma1Valid and px > ma1Val
            ma1DistanceAtr := useATRDistanceTiers and ma1Valid and not na(atr1Val) and atr1Val > 0 ? math.abs(px - ma1Val) / atr1Val : na

        if showMA2
            ma2Valid := not na(px) and not na(ma2Val)
            aboveMA2 := ma2Valid and px > ma2Val
            ma2DistanceAtr := useATRDistanceTiers and ma2Valid and not na(atr2Val) and atr2Val > 0 ? math.abs(px - ma2Val) / atr2Val : na

        if showMA3
            ma3Valid := not na(px) and not na(ma3Val)
            aboveMA3 := ma3Valid and px > ma3Val
            ma3DistanceAtr := useATRDistanceTiers and ma3Valid and not na(atr3Val) and atr3Val > 0 ? math.abs(px - ma3Val) / atr3Val : na

        if vwapVisible
            vwapValid := not na(px) and not na(vwapVal)
            aboveVWAP := vwapValid and px > vwapVal
            vwapDistanceAtr := useATRDistanceTiers and vwapValid and not na(chartAtr) and chartAtr > 0 ? math.abs(px - vwapVal) / chartAtr : na

    [ma1Valid, aboveMA1, ma1DistanceAtr, ma2Valid, aboveMA2, ma2DistanceAtr, ma3Valid, aboveMA3, ma3DistanceAtr, vwapValid, aboveVWAP, vwapDistanceAtr, dailyStrength, weeklyStrength, recent1, recent2, recent3, recentFull1, recentFull2, recentFull3, vwapIsPremarket]

// -------------------------
// Active symbols and data
// -------------------------
activeSym1 = showSym1 and isFullTickerId(sym1)
activeSym2 = showSym2 and isFullTickerId(sym2)
activeSym3 = showSym3 and isFullTickerId(sym3)
activeCount = (activeSym1 ? 1 : 0) + (activeSym2 ? 1 : 0) + (activeSym3 ? 1 : 0)

string strengthRankingGap = "   "

labelDisp1 = label1 == "" ? "S1" : label1
labelDisp2 = label2 == "" ? "S2" : label2
labelDisp3 = label3 == "" ? "S3" : label3

[ma1Valid1, aboveMA1_1, ma1Dist1, ma2Valid1, aboveMA2_1, ma2Dist1, ma3Valid1, aboveMA3_1, ma3Dist1, vwapValid1, aboveVWAP1, vwapDist1, dailyStrength1, weeklyStrength1, recentRow1Strength1, recentRow2Strength1, recentRow3Strength1, recentFullRow1_1, recentFullRow2_1, recentFullRow3_1, vwapIsPremarket1] = f_symbol_all(sym1, activeSym1)
[ma1Valid2, aboveMA1_2, ma1Dist2, ma2Valid2, aboveMA2_2, ma2Dist2, ma3Valid2, aboveMA3_2, ma3Dist2, vwapValid2, aboveVWAP2, vwapDist2, dailyStrength2, weeklyStrength2, recentRow1Strength2, recentRow2Strength2, recentRow3Strength2, recentFullRow1_2, recentFullRow2_2, recentFullRow3_2, vwapIsPremarket2] = f_symbol_all(sym2, activeSym2)
[ma1Valid3, aboveMA1_3, ma1Dist3, ma2Valid3, aboveMA2_3, ma2Dist3, ma3Valid3, aboveMA3_3, ma3Dist3, vwapValid3, aboveVWAP3, vwapDist3, dailyStrength3, weeklyStrength3, recentRow1Strength3, recentRow2Strength3, recentRow3Strength3, recentFullRow1_3, recentFullRow2_3, recentFullRow3_3, vwapIsPremarket3] = f_symbol_all(sym3, activeSym3)

row1Strength1 = strengthMode1 == "1D" ? dailyStrength1 : strengthMode1 == "1W" ? weeklyStrength1 : recentRow1Strength1
row1Strength2 = strengthMode1 == "1D" ? dailyStrength2 : strengthMode1 == "1W" ? weeklyStrength2 : recentRow1Strength2
row1Strength3 = strengthMode1 == "1D" ? dailyStrength3 : strengthMode1 == "1W" ? weeklyStrength3 : recentRow1Strength3

row2Strength1 = strengthMode2 == "1D" ? dailyStrength1 : strengthMode2 == "1W" ? weeklyStrength1 : recentRow2Strength1
row2Strength2 = strengthMode2 == "1D" ? dailyStrength2 : strengthMode2 == "1W" ? weeklyStrength2 : recentRow2Strength2
row2Strength3 = strengthMode2 == "1D" ? dailyStrength3 : strengthMode2 == "1W" ? weeklyStrength3 : recentRow2Strength3

row3Strength1 = strengthMode3 == "1D" ? dailyStrength1 : strengthMode3 == "1W" ? weeklyStrength1 : recentRow3Strength1
row3Strength2 = strengthMode3 == "1D" ? dailyStrength2 : strengthMode3 == "1W" ? weeklyStrength2 : recentRow3Strength2
row3Strength3 = strengthMode3 == "1D" ? dailyStrength3 : strengthMode3 == "1W" ? weeklyStrength3 : recentRow3Strength3

row1WindowFull = not row1IsRecent or ((not activeSym1 or recentFullRow1_1) and (not activeSym2 or recentFullRow1_2) and (not activeSym3 or recentFullRow1_3))
row2WindowFull = not row2IsRecent or ((not activeSym1 or recentFullRow2_1) and (not activeSym2 or recentFullRow2_2) and (not activeSym3 or recentFullRow2_3))
row3WindowFull = not row3IsRecent or ((not activeSym1 or recentFullRow3_1) and (not activeSym2 or recentFullRow3_2) and (not activeSym3 or recentFullRow3_3))

row1Label = row1IsRecent and not row1WindowFull ? strengthMode1 + "*" : strengthMode1
row2Label = row2IsRecent and not row2WindowFull ? strengthMode2 + "*" : strengthMode2
row3Label = row3IsRecent and not row3WindowFull ? strengthMode3 + "*" : strengthMode3

// Populate and structurally initialize the table on the last confirmed historical
// bar before realtime begins, then continue updating it on the live last bar.
// This commits the merged-cell layout before intrabar rollback starts.
bool shouldRenderPanel = barstate.islastconfirmedhistory or barstate.islast

// -------------------------
// Momentum ranking helpers
// -------------------------
f_strength_value(_idx, _s1, _s2, _s3) =>
    _idx == 1 ? _s1 : _idx == 2 ? _s2 : _idx == 3 ? _s3 : na

f_name_for_index(_idx) =>
    _idx == 1 ? labelDisp1 : _idx == 2 ? labelDisp2 : _idx == 3 ? labelDisp3 : ""

f_rank_indices(_enabled, _s1, _s2, _s3) =>
    int rank1 = 0
    int rank2 = 0
    int rank3 = 0

    if shouldRenderPanel and _enabled
        array<int> indices = array.new_int()
        array<float> scores = array.new_float()

        if activeSym1
            array.push(indices, 1)
            array.push(scores, na(_s1) ? -1.0e10 : _s1)
        if activeSym2
            array.push(indices, 2)
            array.push(scores, na(_s2) ? -1.0e10 : _s2)
        if activeSym3
            array.push(indices, 3)
            array.push(scores, na(_s3) ? -1.0e10 : _s3)

        int count = array.size(indices)

        if count > 1
            for i = 0 to count - 2
                for j = i + 1 to count - 1
                    float leftScore = array.get(scores, i)
                    float rightScore = array.get(scores, j)

                    if rightScore > leftScore
                        int leftIndex = array.get(indices, i)
                        int rightIndex = array.get(indices, j)

                        array.set(indices, i, rightIndex)
                        array.set(indices, j, leftIndex)
                        array.set(scores, i, rightScore)
                        array.set(scores, j, leftScore)

        rank1 := count > 0 ? array.get(indices, 0) : 0
        rank2 := count > 1 ? array.get(indices, 1) : 0
        rank3 := count > 2 ? array.get(indices, 2) : 0

    [rank1, rank2, rank3]

f_rank_at(_position, _r1, _r2, _r3) =>
    _position == 1 ? _r1 : _position == 2 ? _r2 : _position == 3 ? _r3 : 0

f_strength_separator(_leftIdx, _rightIdx, _s1, _s2, _s3) =>
    float leftStrength = f_strength_value(_leftIdx, _s1, _s2, _s3)
    float rightStrength = f_strength_value(_rightIdx, _s1, _s2, _s3)

    na(leftStrength) or na(rightStrength) ? "·" : math.abs(leftStrength - rightStrength) <= MOMENTUM_TIE_TOLERANCE ? "=" : ">"

[row1Rank1, row1Rank2, row1Rank3] = f_rank_indices(showStrengthRow1, row1Strength1, row1Strength2, row1Strength3)
[row2Rank1, row2Rank2, row2Rank3] = f_rank_indices(showStrengthRow2, row2Strength1, row2Strength2, row2Strength3)
[row3Rank1, row3Rank2, row3Rank3] = f_rank_indices(showStrengthRow3, row3Strength1, row3Strength2, row3Strength3)

// -------------------------
// Display helpers
// -------------------------
distanceStatusBg(_above, _valid, _distanceAtr) =>
    if not _valid
        errorBgColor
    else if useATRDistanceTiers and na(_distanceAtr)
        errorBgColor
    else
        _above ? aboveColor : belowColor

distanceStatusText(_above, _valid, _distanceAtr) =>
    if not _valid
        "Error"
    else if not useATRDistanceTiers
        _above ? "✓" : "X"
    else if na(_distanceAtr)
        "Error"
    else if _distanceAtr < DISTANCE_CLOSEST_ATR
        "I"
    else if _distanceAtr < DISTANCE_CLOSE_ATR
        "II"
    else if _distanceAtr < DISTANCE_MID_ATR
        "III"
    else if _distanceAtr < DISTANCE_SUPER_FAR_ATR
        "IV"
    else
        "V"

symHdr = isCompact ? "Sym" : "Symbol"
ma1Hdr = isCompact ? str.tostring(ma1Len) : str.tostring(ma1Len) + "MA"
ma2Hdr = isCompact ? str.tostring(ma2Len) : str.tostring(ma2Len) + "MA"
ma3Hdr = isCompact ? str.tostring(ma3Len) : str.tostring(ma3Len) + "MA"

bool displayedVwapIsPremarket = finalVwapMode == "Intraday" and hostChartUsesETH and not isReplay and not na(time("", PREMARKET_SESSION, US_EQUITY_TIMEZONE))

vwapHdrFull = finalVwapMode == "Intraday" ? (displayedVwapIsPremarket ? "P-VWAP" : "D-VWAP") : finalVwapMode == "Week Open" ? "W-VWAP" : finalVwapMode == "Month Open" ? "M-VWAP" : "VWAP"
vwapHdrMini = finalVwapMode == "Intraday" ? (displayedVwapIsPremarket ? "PV" : "DV") : finalVwapMode == "Week Open" ? "WV" : finalVwapMode == "Month Open" ? "MV" : "VW"
vwapHdr = isCompact ? vwapHdrMini : vwapHdrFull

// -------------------------
// Table
// -------------------------
const int MAX_COLS = 20
const int MAX_ROWS = 24

// Keep the table nonexistent during the historical startup pass. It is created
// and fully populated together on a committed last-history/confirmed execution.
// After initialization, realtime updates use cell setters for only the dynamic
// text/background values instead of redefining every cell on every tick.
var table t = na
var bool panelInitialized = false

drawCell(_c, _r, _txt, _bg, _align) =>
    table.cell(t, _c, _r, _txt, bgcolor=_bg, text_color=textColor, text_size=txtSize, text_halign=_align, text_formatting=panelTextFormatting)

updateCell(_c, _r, _txt, _bg) =>
    table.cell_set_text(t, _c, _r, _txt)
    table.cell_set_bgcolor(t, _c, _r, _bg)

drawSpacer(_c, _r) =>
    table.cell(t, _c, _r, " ", bgcolor=spacerBg, text_color=spacerText, text_size=txtSize)

drawTightSpacer(_c, _r) =>
    table.cell(t, _c, _r, "", height=0.35, bgcolor=spacerBg, text_color=spacerText, text_size=size.tiny)

f_strength_ranking_text(_r1, _r2, _r3, _s1, _s2, _s3) =>
    string rankingText = ""

    for rank = 1 to 3
        if rank <= activeCount
            int idx = f_rank_at(rank, _r1, _r2, _r3)

            if rank == 1
                rankingText := f_name_for_index(idx)
            else
                int previousIdx = f_rank_at(rank - 1, _r1, _r2, _r3)
                string separator = f_strength_separator(previousIdx, idx, _s1, _s2, _s3)
                rankingText := rankingText + strengthRankingGap + separator + strengthRankingGap + f_name_for_index(idx)

    rankingText

drawStrengthRow(_row, _rowLabel, _r1, _r2, _r3, _s1, _s2, _s3) =>
    int r = startRow + _row
    string rankingText = f_strength_ranking_text(_r1, _r2, _r3, _s1, _s2, _s3)

    if horizontalCols > 1
        drawCell(startCol, r, _rowLabel, baseColor, text.align_center)
        drawCell(startCol + 1, r, rankingText, baseColor, text.align_center)
    else
        drawCell(startCol, r, _rowLabel + strengthRankingGap + rankingText, baseColor, text.align_center)

updateStrengthRow(_row, _rowLabel, _r1, _r2, _r3, _s1, _s2, _s3) =>
    int r = startRow + _row
    string rankingText = f_strength_ranking_text(_r1, _r2, _r3, _s1, _s2, _s3)

    if horizontalCols > 1
        table.cell_set_text(t, startCol, r, _rowLabel)
        table.cell_set_text(t, startCol + 1, r, rankingText)
    else
        table.cell_set_text(t, startCol, r, _rowLabel + strengthRankingGap + rankingText)

drawStrengthSpacer(_row) =>
    for gapCol = startCol to startCol + horizontalCols - 1
        drawTightSpacer(gapCol, startRow + _row)

drawStrengthRows() =>
    int row = 0

    if showStrengthRow1
        drawStrengthRow(row, row1Label, row1Rank1, row1Rank2, row1Rank3, row1Strength1, row1Strength2, row1Strength3)
        drawStrengthSpacer(row + 1)
        row += 2

    if showStrengthRow2
        drawStrengthRow(row, row2Label, row2Rank1, row2Rank2, row2Rank3, row2Strength1, row2Strength2, row2Strength3)
        drawStrengthSpacer(row + 1)
        row += 2

    if showStrengthRow3
        drawStrengthRow(row, row3Label, row3Rank1, row3Rank2, row3Rank3, row3Strength1, row3Strength2, row3Strength3)
        drawStrengthSpacer(row + 1)

updateStrengthRows() =>
    int row = 0

    if showStrengthRow1
        updateStrengthRow(row, row1Label, row1Rank1, row1Rank2, row1Rank3, row1Strength1, row1Strength2, row1Strength3)
        row += 2

    if showStrengthRow2
        updateStrengthRow(row, row2Label, row2Rank1, row2Rank2, row2Rank3, row2Strength1, row2Strength2, row2Strength3)
        row += 2

    if showStrengthRow3
        updateStrengthRow(row, row3Label, row3Rank1, row3Rank2, row3Rank3, row3Strength1, row3Strength2, row3Strength3)

drawHorizontalHeader() =>
    int c = startCol
    int r = contentStartRow

    drawCell(c, r, symHdr, baseColor, text.align_left)
    c += 1

    if showMA1
        drawCell(c, r, ma1Hdr, baseColor, text.align_center)
        c += 1

    if showMA2
        drawCell(c, r, ma2Hdr, baseColor, text.align_center)
        c += 1

    if showMA3
        drawCell(c, r, ma3Hdr, baseColor, text.align_center)
        c += 1

    if vwapVisible
        drawCell(c, r, vwapHdr, baseColor, text.align_center)

updateDynamicHeader() =>
    if vwapVisible
        int c = startCol + 1 + (showMA1 ? 1 : 0) + (showMA2 ? 1 : 0) + (showMA3 ? 1 : 0)
        table.cell_set_text(t, c, contentStartRow, vwapHdr)

drawHorizontalRow(_row, _label, _m1Valid, _m1Above, _m1Distance, _m2Valid, _m2Above, _m2Distance, _m3Valid, _m3Above, _m3Distance, _vwapValid, _vwapAbove, _vwapDistance) =>
    int c = startCol
    int r = contentStartRow + _row

    drawCell(c, r, _label, baseColor, text.align_left)
    c += 1

    if showMA1
        drawCell(c, r, distanceStatusText(_m1Above, _m1Valid, _m1Distance), distanceStatusBg(_m1Above, _m1Valid, _m1Distance), text.align_center)
        c += 1

    if showMA2
        drawCell(c, r, distanceStatusText(_m2Above, _m2Valid, _m2Distance), distanceStatusBg(_m2Above, _m2Valid, _m2Distance), text.align_center)
        c += 1

    if showMA3
        drawCell(c, r, distanceStatusText(_m3Above, _m3Valid, _m3Distance), distanceStatusBg(_m3Above, _m3Valid, _m3Distance), text.align_center)
        c += 1

    if vwapVisible
        drawCell(c, r, distanceStatusText(_vwapAbove, _vwapValid, _vwapDistance), distanceStatusBg(_vwapAbove, _vwapValid, _vwapDistance), text.align_center)

updateHorizontalRow(_row, _m1Valid, _m1Above, _m1Distance, _m2Valid, _m2Above, _m2Distance, _m3Valid, _m3Above, _m3Distance, _vwapValid, _vwapAbove, _vwapDistance) =>
    int c = startCol + 1
    int r = contentStartRow + _row

    if showMA1
        updateCell(c, r, distanceStatusText(_m1Above, _m1Valid, _m1Distance), distanceStatusBg(_m1Above, _m1Valid, _m1Distance))
        c += 1

    if showMA2
        updateCell(c, r, distanceStatusText(_m2Above, _m2Valid, _m2Distance), distanceStatusBg(_m2Above, _m2Valid, _m2Distance))
        c += 1

    if showMA3
        updateCell(c, r, distanceStatusText(_m3Above, _m3Valid, _m3Distance), distanceStatusBg(_m3Above, _m3Valid, _m3Distance))
        c += 1

    if vwapVisible
        updateCell(c, r, distanceStatusText(_vwapAbove, _vwapValid, _vwapDistance), distanceStatusBg(_vwapAbove, _vwapValid, _vwapDistance))

drawEdgeSpacers(_contentCols, _contentRows) =>
    if panelY == "Top" and vOffset > 0
        for rr = 0 to vOffset - 1
            for cc = startCol to startCol + _contentCols - 1
                drawSpacer(cc, rr)

    if panelY == "Bottom" and vOffset > 0
        for rr = startRow + _contentRows to startRow + _contentRows + vOffset - 1
            for cc = startCol to startCol + _contentCols - 1
                drawSpacer(cc, rr)

    if panelX == "Left" and hOffset > 0
        for cc = 0 to hOffset - 1
            for rr = startRow to startRow + _contentRows - 1
                drawSpacer(cc, rr)

    if panelX == "Right" and hOffset > 0
        for cc = startCol + _contentCols to startCol + _contentCols + hOffset - 1
            for rr = startRow to startRow + _contentRows - 1
                drawSpacer(cc, rr)

initializePanel() =>
    if activeCount == 0
        drawCell(startCol, startRow, "No symbols enabled", baseColor, text.align_left)
        drawEdgeSpacers(1, 1)
    else
        drawStrengthRows()

        if horizontalCols > 2
            int mergeRow = 0

            if showStrengthRow1
                table.merge_cells(t, startCol + 1, startRow + mergeRow, startCol + horizontalCols - 1, startRow + mergeRow)
                mergeRow += 2

            if showStrengthRow2
                table.merge_cells(t, startCol + 1, startRow + mergeRow, startCol + horizontalCols - 1, startRow + mergeRow)
                mergeRow += 2

            if showStrengthRow3
                table.merge_cells(t, startCol + 1, startRow + mergeRow, startCol + horizontalCols - 1, startRow + mergeRow)

        drawHorizontalHeader()

        int row = 1

        if activeSym1
            drawHorizontalRow(row, labelDisp1, ma1Valid1, aboveMA1_1, ma1Dist1, ma2Valid1, aboveMA2_1, ma2Dist1, ma3Valid1, aboveMA3_1, ma3Dist1, vwapValid1, aboveVWAP1, vwapDist1)
            row += 1

        if activeSym2
            drawHorizontalRow(row, labelDisp2, ma1Valid2, aboveMA1_2, ma1Dist2, ma2Valid2, aboveMA2_2, ma2Dist2, ma3Valid2, aboveMA3_2, ma3Dist2, vwapValid2, aboveVWAP2, vwapDist2)
            row += 1

        if activeSym3
            drawHorizontalRow(row, labelDisp3, ma1Valid3, aboveMA1_3, ma1Dist3, ma2Valid3, aboveMA2_3, ma2Dist3, ma3Valid3, aboveMA3_3, ma3Dist3, vwapValid3, aboveVWAP3, vwapDist3)

        int panelRows = strengthExtraRows + 1 + activeCount
        drawEdgeSpacers(horizontalCols, panelRows)

updatePanel() =>
    if activeCount > 0
        updateStrengthRows()
        updateDynamicHeader()

        int row = 1

        if activeSym1
            updateHorizontalRow(row, ma1Valid1, aboveMA1_1, ma1Dist1, ma2Valid1, aboveMA2_1, ma2Dist1, ma3Valid1, aboveMA3_1, ma3Dist1, vwapValid1, aboveVWAP1, vwapDist1)
            row += 1

        if activeSym2
            updateHorizontalRow(row, ma1Valid2, aboveMA1_2, ma1Dist2, ma2Valid2, aboveMA2_2, ma2Dist2, ma3Valid2, aboveMA3_2, ma3Dist2, vwapValid2, aboveVWAP2, vwapDist2)
            row += 1

        if activeSym3
            updateHorizontalRow(row, ma1Valid3, aboveMA1_3, ma1Dist3, ma2Valid3, aboveMA2_3, ma2Dist3, ma3Valid3, aboveMA3_3, ma3Dist3, vwapValid3, aboveVWAP3, vwapDist3)

// -------------------------
// Draw latest state
// -------------------------
// Creation and first population happen together on a committed execution.
// Subsequent last-bar executions update only dynamic cell content/backgrounds.
bool tableInitReady = barstate.islastconfirmedhistory or (barstate.islast and barstate.isconfirmed)

if tableInitReady and na(t)
    t := table.new(panelPos, MAX_COLS, MAX_ROWS, frame_width=0, border_width=0, force_overlay=true)
    initializePanel()
    panelInitialized := true
else if barstate.islast and panelInitialized and not na(t)
    updatePanel()
````
