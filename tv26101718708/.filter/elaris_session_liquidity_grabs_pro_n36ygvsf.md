# Elaris Session Liquidity Grabs Pro

- url: https://www.tradingview.com/script/n36ygVsf-Elaris-Session-Liquidity-Grabs-Pro/
- type: indicator
- pine_id: PUB;916f93729f714e2da4e483ef4cf125c3
- version: 1.0

## Description

# Elaris Session Liquidity Grabs Pro

Elaris Session Liquidity Grabs Pro is a professional session-based liquidity sweep and reversal detection tool designed for traders who focus on smart money concepts, stop hunts, failed breakouts, and institutional liquidity behavior.

The indicator automatically builds key liquidity ranges from major global trading sessions including London, New York, and Asia, then detects high-probability liquidity grabs when price sweeps session highs or lows and rejects back into range.

Unlike basic sweep indicators, this tool includes advanced filtering systems designed to reduce noise and focus on stronger reversal conditions using ATR displacement, candle strength analysis, EMA trend filtering, and optional volume confirmation.

Built for active intraday traders, scalpers, and smart money traders, the indicator provides a clean visual framework for identifying areas where liquidity may have been engineered before a market reversal or continuation move.

━━━━━━━━━━━━━━━━━━
FEATURES
━━━━━━━━━━━━━━━━━━

• Automatic London, New York, and Asia session ranges
• Session high/low liquidity tracking
• Bullish and bearish liquidity grab detection
• Wick sweep and close-break detection modes
• ATR-based sweep validation filters
• Strong displacement candle confirmation
• EMA trend filter for directional bias
• Volume confirmation filter
• Optional cooldown system to reduce signal clustering
• Session equilibrium (midline) plotting
• Clean session range visualization
• Professional dashboard panel
• Dark mode and light mode support
• Alert conditions for automation and notifications
• Non-repainting confirmed signals

━━━━━━━━━━━━━━━━━━
HOW IT WORKS
━━━━━━━━━━━━━━━━━━

The indicator builds liquidity ranges from selected market sessions and monitors price action after those sessions complete.

When price aggressively sweeps a session high or low and then rejects back into the range, the indicator identifies it as a potential liquidity grab event.

Examples:
• Price sweeps above London High and closes back below → potential bearish liquidity grab
• Price sweeps below New York Low and closes back above → potential bullish liquidity grab

Additional confirmation filters help reduce weak or low-quality signals by requiring stronger candle displacement, trend alignment, and optional volume expansion.

━━━━━━━━━━━━━━━━━━
BEST USE CASES
━━━━━━━━━━━━━━━━━━

• Smart money trading concepts
• Session liquidity trading
• Stop hunt reversals
• Scalping and intraday trading
• ICT-style trading approaches
• Breakout failure detection
• Market manipulation detection

━━━━━━━━━━━━━━━━━━
RECOMMENDED MARKETS
━━━━━━━━━━━━━━━━━━

• Crypto Futures
• Forex
• Indices
• Gold and Commodities

━━━━━━━━━━━━━━━━━━
RECOMMENDED TIMEFRAMES
━━━━━━━━━━━━━━━━━━

• 1 Minute
• 3 Minute
• 5 Minute
• 15 Minute

━━━━━━━━━━━━━━━━━━
NON-REPAINTING
━━━━━━━━━━━━━━━━━━

This indicator is designed to be non-repainting.

Signals are confirmed only after candle close and session levels are finalized after the session completes. No future data is used.

━━━━━━━━━━━━━━━━━━
NOTES
━━━━━━━━━━━━━━━━━━

This tool is designed to assist with identifying liquidity behavior and market structure reactions. It should be used alongside proper risk management, higher timeframe analysis, and additional trade confirmation techniques.

No indicator guarantees profitability or win rate consistency across all market conditions.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © ElarisGroup

//@version=6
indicator(
     "Elaris Session Liquidity Grabs Pro",
     shorttitle = "Elaris SLG Pro",
     overlay = true,
     max_boxes_count = 300,
     max_lines_count = 300,
     max_labels_count = 300
)

//====================================================
// INPUTS
//====================================================

//----------------------------------------------------
// Session Settings
//----------------------------------------------------
groupSession = "Sessions"

showLondon      = input.bool(true,  "Enable London Session", group=groupSession)
showNewYork     = input.bool(true,  "Enable New York Session", group=groupSession)
showAsia        = input.bool(false, "Enable Asia Session", group=groupSession)

londonSession   = input.session("0700-1000", "London Range", group=groupSession)
newYorkSession  = input.session("1330-1600", "New York Range", group=groupSession)
asiaSession     = input.session("0000-0300", "Asia Range", group=groupSession)

sessionTimezone = input.string("Etc/UTC", "Session Timezone",
 options = [
     "Etc/UTC",
     "Europe/London",
     "America/New_York",
     "Asia/Dubai",
     "Asia/Tokyo"
 ], group=groupSession)

//----------------------------------------------------
// Liquidity Logic
//----------------------------------------------------
groupLogic = "Liquidity Grab Logic"

sweepMode = input.string(
     "Wick Sweep",
     "Sweep Detection",
     options = ["Wick Sweep", "Close Break"],
     group = groupLogic
)

confirmCloseBackInside = input.bool(true, "Require Close Back Inside Range", group=groupLogic)

minSweepAtr = input.float(
     0.10,
     "Minimum Sweep Distance (ATR)",
     minval = 0.0,
     step = 0.01,
     tooltip = "Filters tiny fake sweeps",
     group = groupLogic
)

atrLength = input.int(14, "ATR Length", minval=1, group=groupLogic)

useTrendFilter = input.bool(false, "Enable EMA Trend Filter", group=groupLogic)
emaLength      = input.int(200, "EMA Length", minval=1, group=groupLogic)

useVolumeFilter = input.bool(false, "Enable Volume Filter", group=groupLogic)
volumeMultiplier = input.float(
     1.2,
     "Volume vs SMA",
     step = 0.1,
     minval = 0.1,
     group = groupLogic
)

volumeLength = input.int(20, "Volume SMA Length", minval=1, group=groupLogic)

//----------------------------------------------------
// Visualization
//----------------------------------------------------
groupVisual = "Visual Settings"

extendLines     = input.int(120, "Extend Session Levels (Bars)", minval=5, maxval=500, group=groupVisual)
showBoxes       = input.bool(true, "Show Session Boxes", group=groupVisual)
showMidline     = input.bool(true, "Show Session Midline", group=groupVisual)
showLabels      = input.bool(true, "Show Liquidity Labels", group=groupVisual)
showSignals     = input.bool(true, "Show Signal Markers", group=groupVisual)
showDashboard   = input.bool(true, "Show Dashboard", group=groupVisual)

themeMode = input.string(
     "Dark",
     "Theme",
     options = ["Dark", "Light"],
     group = groupVisual
)

//====================================================
// COLORS
//====================================================

isDark = themeMode == "Dark"

bullColor = color.rgb(0, 214, 143)
bearColor = color.rgb(255, 82, 82)

neutralColor = isDark ? color.rgb(160, 160, 160) : color.rgb(90, 90, 90)

londonColor = color.new(color.rgb(255, 193, 7), 82)
newYorkColor = color.new(color.rgb(0, 174, 255), 82)
asiaColor = color.new(color.rgb(186, 104, 200), 85)

dashboardBg = isDark ? color.rgb(18, 18, 18) : color.rgb(245, 245, 245)
dashboardText = isDark ? color.white : color.black

//====================================================
// CALCULATIONS
//====================================================

atr = ta.atr(atrLength)
ema = ta.ema(close, emaLength)

volSma = ta.sma(volume, volumeLength)

volumeValid = not useVolumeFilter or volume > volSma * volumeMultiplier

bullTrendValid = not useTrendFilter or close > ema
bearTrendValid = not useTrendFilter or close < ema

//====================================================
// SESSION DETECTION
//====================================================

inLondon = not na(time(timeframe.period, londonSession, sessionTimezone))
inNewYork = not na(time(timeframe.period, newYorkSession, sessionTimezone))
inAsia = not na(time(timeframe.period, asiaSession, sessionTimezone))

newLondon = inLondon and not inLondon[1]
newNewYork = inNewYork and not inNewYork[1]
newAsia = inAsia and not inAsia[1]

//====================================================
// STORAGE
//====================================================

var float londonHigh = na
var float londonLow = na
var float londonMid = na

var float nyHigh = na
var float nyLow = na
var float nyMid = na

var float asiaHigh = na
var float asiaLow = na
var float asiaMid = na

//====================================================
// OBJECT STORAGE
//====================================================

var box londonBox = na
var box nyBox = na
var box asiaBox = na

var line londonHighLine = na
var line londonLowLine = na
var line londonMidLine = na

var line nyHighLine = na
var line nyLowLine = na
var line nyMidLine = na

var line asiaHighLine = na
var line asiaLowLine = na
var line asiaMidLine = na

//====================================================
// SESSION BUILDING
//====================================================

//----------------------------------------------------
// London
//----------------------------------------------------
if showLondon
    if newLondon
        londonHigh := high
        londonLow := low

        if not na(londonBox)
            box.delete(londonBox)

        londonBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             bgcolor = londonColor,
             border_color = color.new(color.yellow, 30)
        )

    if inLondon
        londonHigh := math.max(nz(londonHigh, high), high)
        londonLow := math.min(nz(londonLow, low), low)

        londonMid := (londonHigh + londonLow) / 2.0

        if showBoxes and not na(londonBox)
            box.set_right(londonBox, bar_index)
            box.set_top(londonBox, londonHigh)
            box.set_bottom(londonBox, londonLow)

    if not inLondon and inLondon[1]
        londonHighLine := line.new(
             bar_index,
             londonHigh,
             bar_index + extendLines,
             londonHigh,
             color = color.yellow,
             width = 1
        )

        londonLowLine := line.new(
             bar_index,
             londonLow,
             bar_index + extendLines,
             londonLow,
             color = color.yellow,
             width = 1
        )

        if showMidline
            londonMidLine := line.new(
                 bar_index,
                 londonMid,
                 bar_index + extendLines,
                 londonMid,
                 color = color.new(color.yellow, 40),
                 style = line.style_dashed
            )

//----------------------------------------------------
// New York
//----------------------------------------------------
if showNewYork
    if newNewYork
        nyHigh := high
        nyLow := low

        if not na(nyBox)
            box.delete(nyBox)

        nyBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             bgcolor = newYorkColor,
             border_color = color.new(color.aqua, 20)
        )

    if inNewYork
        nyHigh := math.max(nz(nyHigh, high), high)
        nyLow := math.min(nz(nyLow, low), low)

        nyMid := (nyHigh + nyLow) / 2.0

        if showBoxes and not na(nyBox)
            box.set_right(nyBox, bar_index)
            box.set_top(nyBox, nyHigh)
            box.set_bottom(nyBox, nyLow)

    if not inNewYork and inNewYork[1]
        nyHighLine := line.new(
             bar_index,
             nyHigh,
             bar_index + extendLines,
             nyHigh,
             color = color.aqua,
             width = 1
        )

        nyLowLine := line.new(
             bar_index,
             nyLow,
             bar_index + extendLines,
             nyLow,
             color = color.aqua,
             width = 1
        )

        if showMidline
            nyMidLine := line.new(
                 bar_index,
                 nyMid,
                 bar_index + extendLines,
                 nyMid,
                 color = color.new(color.aqua, 40),
                 style = line.style_dashed
            )

//----------------------------------------------------
// Asia
//----------------------------------------------------
if showAsia
    if newAsia
        asiaHigh := high
        asiaLow := low

        if not na(asiaBox)
            box.delete(asiaBox)

        asiaBox := box.new(
             left = bar_index,
             top = high,
             right = bar_index,
             bottom = low,
             bgcolor = asiaColor,
             border_color = color.new(color.purple, 20)
        )

    if inAsia
        asiaHigh := math.max(nz(asiaHigh, high), high)
        asiaLow := math.min(nz(asiaLow, low), low)

        asiaMid := (asiaHigh + asiaLow) / 2.0

        if showBoxes and not na(asiaBox)
            box.set_right(asiaBox, bar_index)
            box.set_top(asiaBox, asiaHigh)
            box.set_bottom(asiaBox, asiaLow)

    if not inAsia and inAsia[1]
        asiaHighLine := line.new(
             bar_index,
             asiaHigh,
             bar_index + extendLines,
             asiaHigh,
             color = color.purple,
             width = 1
        )

        asiaLowLine := line.new(
             bar_index,
             asiaLow,
             bar_index + extendLines,
             asiaLow,
             color = color.purple,
             width = 1
        )

        if showMidline
            asiaMidLine := line.new(
                 bar_index,
                 asiaMid,
                 bar_index + extendLines,
                 asiaMid,
                 color = color.new(color.purple, 40),
                 style = line.style_dashed
            )

//====================================================
// SWEEP LOGIC
//====================================================

wickSweepHigh(level) =>
    high > level and close < level

wickSweepLow(level) =>
    low < level and close > level

closeBreakHigh(level) =>
    close > level

closeBreakLow(level) =>
    close < level

isHighSweep(level) =>
    sweepMode == "Wick Sweep"
         ? wickSweepHigh(level)
         : closeBreakHigh(level)

isLowSweep(level) =>
    sweepMode == "Wick Sweep"
         ? wickSweepLow(level)
         : closeBreakLow(level)

//====================================================
// LIQUIDITY GRABS
//====================================================

londonBuyGrab = showLondon and not inLondon and not na(londonLow) and isLowSweep(londonLow) and math.abs(londonLow - low) >= atr * minSweepAtr and volumeValid and bullTrendValid and (not confirmCloseBackInside or close > londonLow)

londonSellGrab = showLondon and not inLondon and not na(londonHigh) and isHighSweep(londonHigh) and math.abs(high - londonHigh) >= atr * minSweepAtr and volumeValid and bearTrendValid and (not confirmCloseBackInside or close < londonHigh)

nyBuyGrab = showNewYork and not inNewYork and not na(nyLow) and isLowSweep(nyLow) and math.abs(nyLow - low) >= atr * minSweepAtr and volumeValid and bullTrendValid and (not confirmCloseBackInside or close > nyLow)

nySellGrab = showNewYork and not inNewYork and not na(nyHigh) and isHighSweep(nyHigh) and math.abs(high - nyHigh) >= atr * minSweepAtr and volumeValid and bearTrendValid and (not confirmCloseBackInside or close < nyHigh)

asiaBuyGrab = showAsia and not inAsia and not na(asiaLow) and isLowSweep(asiaLow) and math.abs(asiaLow - low) >= atr * minSweepAtr and volumeValid and bullTrendValid and (not confirmCloseBackInside or close > asiaLow)

asiaSellGrab = showAsia and not inAsia and not na(asiaHigh) and isHighSweep(asiaHigh) and math.abs(high - asiaHigh) >= atr * minSweepAtr and volumeValid and bearTrendValid and (not confirmCloseBackInside or close < asiaHigh)

//====================================================
// ADVANCED SIGNAL FILTERS
//====================================================

groupAdvanced = "Advanced Filters"

cooldownBars = input.int(
     15,
     "Signal Cooldown Bars",
     minval = 1,
     tooltip = "Minimum bars between signals",
     group = groupAdvanced
)

minDisplacementAtr = input.float(
     0.35,
     "Minimum Candle Displacement (ATR)",
     minval = 0.1,
     step = 0.05,
     tooltip = "Requires strong rejection candle",
     group = groupAdvanced
)

minBodyPercent = input.float(
     55.0,
     "Minimum Candle Body %",
     minval = 1,
     maxval = 100,
     step = 1,
     tooltip = "Avoid weak indecision candles",
     group = groupAdvanced
)

requireOppositeClose = input.bool(
     true,
     "Require Strong Reversal Close",
     group = groupAdvanced
)

allowOnlyOutsideSession = input.bool(
     true,
     "Only Signal Outside Sessions",
     group = groupAdvanced
)

//====================================================
// CANDLE QUALITY
//====================================================

candleRange = high - low
candleBody = math.abs(close - open)

bodyPercent = candleRange > 0 ? (candleBody / candleRange) * 100 : 0

bullishDisplacement = (close - low) >= atr * minDisplacementAtr

bearishDisplacement = (high - close) >= atr * minDisplacementAtr

strongBullClose = close > open and bullishDisplacement and bodyPercent >= minBodyPercent

strongBearClose = close < open and bearishDisplacement and bodyPercent >= minBodyPercent

//====================================================
// SESSION FILTER
//====================================================

outsideAllSessions = not inLondon and not inNewYork and not inAsia

sessionFilterValid = not allowOnlyOutsideSession or outsideAllSessions

//====================================================
// COOLDOWN SYSTEM
//====================================================

var int lastBuySignalBar = na
var int lastSellSignalBar = na

buyCooldownPassed = na(lastBuySignalBar) or (bar_index - lastBuySignalBar >= cooldownBars)

sellCooldownPassed = na(lastSellSignalBar) or (bar_index - lastSellSignalBar >= cooldownBars)

//====================================================
// FILTERED FINAL SIGNALS
//====================================================

rawBuySignal = londonBuyGrab or nyBuyGrab or asiaBuyGrab

rawSellSignal = londonSellGrab or nySellGrab or asiaSellGrab

buySignal = rawBuySignal and buyCooldownPassed and sessionFilterValid and volumeValid and bullTrendValid and (     not requireOppositeClose or     strongBullClose )

sellSignal = rawSellSignal and sellCooldownPassed and sessionFilterValid and volumeValid and bearTrendValid and (     not requireOppositeClose or     strongBearClose )

//====================================================
// UPDATE COOLDOWNS
//====================================================

if buySignal
    lastBuySignalBar := bar_index

if sellSignal
    lastSellSignalBar := bar_index

//====================================================
// VISUAL SIGNALS
//====================================================

plotshape(
     showSignals and buySignal,
     title = "Bullish Liquidity Grab",
     style = shape.triangleup,
     location = location.belowbar,
     color = bullColor,
     size = size.small,
     text = "BUY"
)

plotshape(
     showSignals and sellSignal,
     title = "Bearish Liquidity Grab",
     style = shape.triangledown,
     location = location.abovebar,
     color = bearColor,
     size = size.small,
     text = "SELL"
)

//====================================================
// LABELS
//====================================================

if showLabels and buySignal
    label.new(
         bar_index,
         low,
         "Liquidity Grab\nBullish Reversal",
         style = label.style_label_up,
         color = bullColor,
         textcolor = color.white,
         size = size.small
    )

if showLabels and sellSignal
    label.new(
         bar_index,
         high,
         "Liquidity Grab\nBearish Reversal",
         style = label.style_label_down,
         color = bearColor,
         textcolor = color.white,
         size = size.small
    )

//====================================================
// EMA
//====================================================

plot(
     useTrendFilter ? ema : na,
     title = "EMA Filter",
     color = neutralColor,
     linewidth = 2
)

//====================================================
// DASHBOARD
//====================================================

var table dashboard = table.new(position.top_right, 2, 6)

if barstate.islast and showDashboard
    table.cell(
         dashboard,
         0,
         0,
         "Elaris SLG Pro",
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         1,
         0,
         timeframe.period,
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         0,
         1,
         "Trend",
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         1,
         1,
         close > ema ? "Bullish" : "Bearish",
         bgcolor = close > ema ? color.new(bullColor, 80) : color.new(bearColor, 80),
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         0,
         2,
         "Volume Filter",
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         1,
         2,
         volumeValid ? "Passed" : "Weak",
         bgcolor = volumeValid ? color.new(bullColor, 85) : color.new(bearColor, 85),
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         0,
         3,
         "London",
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         1,
         3,
         inLondon ? "Active" : "Closed",
         bgcolor = inLondon ? color.new(color.yellow, 80) : dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         0,
         4,
         "New York",
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         1,
         4,
         inNewYork ? "Active" : "Closed",
         bgcolor = inNewYork ? color.new(color.aqua, 80) : dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         0,
         5,
         "Asia",
         bgcolor = dashboardBg,
         text_color = dashboardText
    )

    table.cell(
         dashboard,
         1,
         5,
         inAsia ? "Active" : "Closed",
         bgcolor = inAsia ? color.new(color.purple, 80) : dashboardBg,
         text_color = dashboardText
    )

//====================================================
// ALERTS
//====================================================

alertcondition(
     buySignal,
     title = "Bullish Liquidity Grab",
     message = "Bullish session liquidity grab detected on {{ticker}}"
)

alertcondition(
     sellSignal,
     title = "Bearish Liquidity Grab",
     message = "Bearish session liquidity grab detected on {{ticker}}"
)
````
