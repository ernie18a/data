# ATC MACD Evolved

- url: https://www.tradingview.com/script/nR9D23dI-ATC-MACD-Evolved/
- type: indicator
- pine_id: PUB;85d56c6fecb4457992c73eca3fc5bd24
- version: 1.0

## Description

What It Is

ATC MACD Evolved is a precision-engineered rebuild of the classic Moving Average Convergence Divergence indicator. It keeps the familiar MACD structure traders already know — fast EMA, slow EMA, signal line, histogram — and replaces every weak link in that structure with a cleaner, more reliable equivalent. The result is a MACD that reads momentum more clearly, lies less often, and tells you not just what is happening but how significant it actually is.

This is not a MACD with extra features stacked on top. It is a MACD built the right way from the foundation up.

________________________________________

Who It's Built For

ATC MACD Evolved is built for the active retail trader who already knows what MACD is, has probably used it before, and has run into its most common frustrations — late crossovers, noisy histogram readings, and signal lines that lag at the worst possible moment. If you have ever watched a MACD crossover fire and then immediately reverse, this indicator was built in response to exactly that experience.

________________________________________

Core Concept
MACD measures the distance between two exponential moving averages of price — a faster one (default 12 periods) and a slower one (default 26 periods). When the fast EMA pulls ahead of the slow EMA, momentum is building. When it falls behind, momentum is fading. The gap between the two is the MACD line. The signal line smooths that gap to make crossovers more readable. The histogram is the gap between the MACD line and the signal line — it expands when momentum is accelerating and compresses when it is slowing.

That is the retail MACD. It works. But it has three structural problems. The signal line uses EMA smoothing, which lags and causes late crossovers. The histogram has no scale reference, so you cannot tell whether a reading is large or small for the instrument you are trading. And the divergence logic, when it exists at all in retail tools, is not filtered — it fires constantly and most of those signals are noise.

ATC MACD Evolved solves all three.

________________________________________

The Upgrades

HMA Signal Line

The signal line is replaced with a Hull Moving Average of the same default length. HMA is specifically designed to reduce lag while maintaining smoothness. In practice this means crossovers occur closer to the actual momentum shift rather than well after it has already occurred. The MACD line itself remains a standard EMA-based calculation — the HMA is applied only to the signal line, which is the part of the system most responsible for late signals.

Standard-Deviation-Normalized Histogram

Every histogram print is measured against the instrument's own historical standard deviation over the last 200 bars. This produces a normalized strength score — call it the histogram Z-score — that tells you objectively whether the current histogram reading is strong, moderate, or weak relative to what this instrument normally produces at this timeframe. A histogram bar that looks big might actually be ordinary. A histogram bar that looks small might be historically significant. The normalization removes that ambiguity.

The histogram is then rendered in one of eight visual states based on direction, strength, and whether momentum is accelerating or fading. Strong bullish prints glow at full opacity. Weak prints render faded. Fading momentum mid-trend is visually distinct from genuine weakness. You can read the state of momentum at a glance without needing to interpret numbers.

Conservative Pivot-Confirmed Divergence Engine

Divergence is off by default. When enabled, it does not fire on every wiggle. It requires confirmed price pivots — actual swing highs and lows — before comparing histogram behavior at those pivots. The pivot confirmation is hard: the engine waits for the required number of bars on both sides of the pivot to confirm before flagging anything. It also enforces minimum and maximum bar separation between pivots, rejecting micro-divergences that form on adjacent bars and stale divergences where the pivots are too far apart to be meaningful. There is also an optional same-side-of-zero filter, which requires both histogram pivots to be on the same side of the zero line — bear divergence requires both readings above zero, bull divergence requires both below. This filter alone eliminates a large category of false divergence signals that retail tools produce constantly.

________________________________________

Chart Visuals

MACD Line — Electric Blue The core momentum line. Tracks the spread between the fast and slow EMA.

Signal Line — Gold The HMA-smoothed signal. Crossovers between the MACD line and signal line are primary signals.

Histogram Columns The gap between the MACD line and signal line, rendered in color-coded columns with a visual scale multiplier applied for readability (default 1.75x). This multiplier is display-only and does not affect any calculations, alerts, or HUD values. The columns use eight visual states driven by direction, normalized strength, and slope:

•	Bright green, full opacity — bullish, accelerating, strong

•	Green, slightly faded — bullish, accelerating, moderate strength

•	Green, heavily faded — bullish but statistically weak (watch for stall)

•	Green, partial fade — bullish but decelerating (momentum losing steam)

•	Bright red, full opacity — bearish, accelerating, strong

•	Red, slightly faded — bearish, accelerating, moderate

•	Red, heavily faded — bearish but weak (bear pressure fading)

•	Red, partial fade — bearish but decelerating (recovery building)

MACD / Signal Cloud A filled region between the MACD line and signal line that changes color and opacity based on the combined state of both lines relative to each other and to the zero line. Darker and more saturated when both are on the same side and in agreement. Lighter and more transparent during transitional phases.

Momentum Background A subtle background tint across the full panel — green when MACD is above signal, red when below. The tint is stronger when the MACD line is also above zero (bull control) and lighter when it is below (recovery or transition). This gives you an immediate panel-level read on regime without needing to look at individual lines.

Zero-Line Glow The zero line is rendered with a colored glow that reflects the current histogram direction — green when histogram is positive, red when negative. This provides a subtle but consistent reference point for zero-line crossover events.

Crossover Dots At every signal-line crossover, a dot and surrounding glow appear on the MACD line. The glow renders first so the sharp dot remains visually dominant. Bull crossovers are green, bear crossovers are red.

Divergence Labels (optional) When divergence is enabled and a confirmed pivot-to-pivot divergence is detected, a BULL DIV or BEAR DIV label appears on the histogram at the pivot bar. Labels are placed on the visually scaled histogram so they align with the displayed columns.

________________________________________

The HUD

The HUD is a live data panel rendered in the corner of the indicator panel. It updates on every bar close and gives you a structured summary of the indicator's current state without needing to read individual lines and columns manually.

MACD — The raw MACD line value at four decimal places.

Signal — The HMA signal line value at four decimal places.

Hist Strength — The normalized Z-score of the current histogram print. Positive values indicate bullish histogram, negative bearish. The magnitude tells you how significant the print is relative to this instrument's normal range. A value above +1.5 or below -1.5 is statistically strong.

Strength — A plain-language classification of the Z-score reading: Strong, Moderate, or Weak. Strong means the current histogram print is beyond 1.5 standard deviations from zero. Moderate is between 0.5 and 1.5. Weak is below 0.5 and is the zone where momentum signals should be treated with caution.

State — A four-state momentum classification based on the position of the MACD line relative to signal and relative to zero:

•	Bull Control — MACD above signal AND above zero. Full bullish regime.

•	Bull Recovery — MACD above signal but below zero. Recovering from bearish territory.

•	Bear Pressure — MACD below signal but above zero. Weakening from bullish territory.

•	Bear Control — MACD below signal AND below zero. Full bearish regime.

Divergence — When the divergence engine is enabled, this field shows the current status: Watching (monitoring for pivots), Bull Div @ Pivot (confirmed bullish divergence at last pivot), or Bear Div @ Pivot (confirmed bearish divergence at last pivot). When the engine is off, this field shows Off.

Hist Visual — The current histogram visual scale multiplier. Displayed as a reminder that the histogram is scaled for readability only. All calculations use the true unscaled histogram values.

________________________________________

Alerts

ATC MACD Evolved includes eight configurable alert conditions:

MACD Bull Cross — Fires when the MACD line crosses above the HMA signal line.

MACD Bear Cross — Fires when the MACD line crosses below the HMA signal line.

MACD Zero Cross Up — Fires when the MACD line crosses above the zero line.

MACD Zero Cross Down — Fires when the MACD line crosses below the zero line.

Strong Bull Histogram — Fires on the first bar where the normalized histogram strength enters the strong zone on the positive side. This is a momentum acceleration alert, not a crossover.

Strong Bear Histogram — Fires on the first bar where normalized histogram strength enters the strong zone on the negative side.

Bear Divergence — Fires when the divergence engine confirms a bearish pivot-to-pivot divergence. Requires divergence to be enabled in settings.

Bull Divergence — Fires when the divergence engine confirms a bullish pivot-to-pivot divergence. Requires divergence to be enabled in settings.

________________________________________

How to Trade With ATC MACD Evolved

ATC MACD Evolved is a momentum and trend-following tool. It measures momentum quality, not price targets. Use it to confirm conditions that support entry, to gauge how much conviction exists behind a move, and to identify early signs of momentum exhaustion before a reversal becomes obvious.

Step 1 — Read the State first

Before looking at any crossover or histogram reading, check the HUD State field. Bull Control and Bear Control are the regimes where signals from this indicator carry the most weight. Bull Recovery and Bear Pressure are transitional — signals are valid but require more supporting evidence from price action or other tools.

Step 2 — Read the Histogram Strength

Check the Strength field in the HUD. A Strong reading means the histogram print is statistically significant for this instrument. A Weak reading means momentum is not confirmed — crossovers in weak histogram territory are lower conviction and should be weighted accordingly. Do not trade crossovers in Weak zones the same way you trade them in Strong zones.

Step 3 — Confirm the crossover

When the MACD line crosses the HMA signal line, a crossover dot and glow appear on the chart. The most reliable crossovers occur when the histogram is transitioning from a faded state (decelerating) to an accelerating state on the opposite side — you will see the histogram columns shift from a partial-opacity color to a full-opacity color in the new direction. Crossovers that occur with immediately Strong normalized readings are the cleanest setups.

Step 4 — Check the zero-line position

A bullish crossover above the zero line (Bull Control state) is generally stronger than one below zero (Bull Recovery). Both are valid, but the zero-line position tells you whether you are trading with the prevailing macro momentum or against it. Trade Bull Control crossovers with more size or fewer confirmations required. Trade Bull Recovery crossovers as potential turning-point setups that still need price structure support.

Step 5 — Use zero-line crossovers as trend confirmation

When the MACD line itself crosses the zero line, it marks a shift in the medium-term trend relationship between the fast and slow EMAs. Zero cross up, combined with a MACD-above-signal condition, is a two-layer confirmation of a building trend. Zero cross alerts are most useful as trend-start confirmation rather than entry triggers on their own.

Step 6 — If divergence is enabled, treat it as a caution flag

A divergence label on ATC MACD Evolved is not a buy or sell signal. It is a structural warning. Bearish divergence — price making a higher high while the histogram makes a lower high — means upside momentum is not confirming price action. This creates a fragile structure. Bullish divergence is the mirror: price making a lower low while histogram makes a higher low, indicating selling pressure is not accelerating with price. In both cases, wait for a crossover or a failed new extreme in price to act on the divergence flag.

Step 7 — Watch the histogram fade for exits

When you are in a trade and the histogram shifts from a Strong or Moderate state to a Weak state — visible as the column opacity dropping and the Strength field reading Weak — that is a warning that momentum is stalling. It is not an exit trigger by itself, but it is a cue to tighten your stop or reduce exposure. When the histogram then begins fading (decelerating) in the current direction, watch for a crossover as confirmation of a regime shift.

________________________________________

Recommended Instruments and Timeframes

ATC MACD Evolved is validated and performs well on liquid instruments with consistent volume profiles. Futures markets including ES, NQ, MES, MNQ, CL, and GC are the primary intended instruments. It is equally well-suited to major equity ETFs such as SPY and QQQ, and to major forex pairs including EURUSD, GBPUSD, and USDJPY. The normalization engine adapts to the volatility characteristics of each instrument, so the same threshold settings can be used across markets without manual adjustment.

Recommended timeframes are 5-minute through 4-hour for active trading and 1-hour through Daily for trend context and confirmation. The 200-bar normalization lookback is calibrated for these timeframes. On very short timeframes below 5 minutes, consider increasing the normalization lookback to maintain statistical stability. On weekly or monthly charts, the tool still functions correctly but is better used as a macro context layer than an entry trigger.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ==========================================================================
//@version=6
indicator("ATC MACD Evolved", shorttitle="ATC MACD Evolved", overlay=false, precision=4, max_labels_count=100, max_lines_count=50)

// ==========================================================================
// Section B — Inputs
// ==========================================================================
grpMACD = "MACD Parameters"
fastLen = input.int(12, "Fast EMA", minval=2, group=grpMACD)
slowLen = input.int(26, "Slow EMA", minval=3, group=grpMACD)
sigLen  = input.int(9, "Signal (HMA)", minval=2, group=grpMACD, tooltip="ATC MACD Evolved upgrade: HMA replaces classic EMA signal line. Cleaner crossovers with less lag.")
macdSrc = input.source(close, "Price Source", group=grpMACD)

grpNorm = "Histogram Normalization"
zLen    = input.int(100, "Strength Lookback", minval=50, group=grpNorm, tooltip="Optimized default: 100 bars based on QQQ 5-minute RTH grid testing. Bars used to estimate the histogram's own standard deviation on this instrument/timeframe.")
zStrong = input.float(1.5, "Strong Print Threshold", minval=0.5, step=0.1, group=grpNorm, tooltip="Histogram prints beyond this normalized value render in full-opacity color.")
zFade   = input.float(0.5, "Weak Print Threshold", minval=0.0, step=0.1, group=grpNorm, tooltip="Histogram prints below this normalized value render in faded color — insignificant momentum.")

grpDiv = "Divergence Engine (Conservative)"
enableDiv   = input.bool(false, "Enable Divergence Labels", group=grpDiv, tooltip="Off by default. When enabled, only confirmed pivot-to-pivot divergences appear.")
pivL        = input.int(5, "Pivot Left Bars", minval=2, group=grpDiv)
pivR        = input.int(5, "Pivot Right Bars", minval=2, group=grpDiv, tooltip="Divergence is delayed by this many bars — required for pivot confirmation.")
minBarSep   = input.int(8, "Min Bars Between Pivots", minval=3, group=grpDiv, tooltip="Blocks micro-divergence on adjacent pivots.")
maxBarSep   = input.int(60, "Max Bars Between Pivots", minval=10, group=grpDiv, tooltip="Pivots further apart than this are considered stale and ignored.")
requireSide = input.bool(true, "Require Same Side of Zero", group=grpDiv, tooltip="Bear div requires both histogram pivots > 0; bull div requires both < 0. Filters noise.")

grpVisual = "Premium Visual System"
showCloud          = input.bool(true, "Show MACD / Signal Cloud", group=grpVisual)
cloudStrongTransp  = input.int(48, "Cloud Strong Transparency", minval=0, maxval=100, group=grpVisual, tooltip="Lower value = brighter cloud. Applies when MACD state and zero-line location are aligned.")
cloudSoftTransp    = input.int(64, "Cloud Soft Transparency", minval=0, maxval=100, group=grpVisual, tooltip="Lower value = brighter cloud. Applies during recovery/pressure transition states.")
showStateBg        = input.bool(true, "Show Momentum Background", group=grpVisual)
showZeroGlow       = input.bool(true, "Show Zero-Line Glow", group=grpVisual)
showCrossDots      = input.bool(true, "Show Crossover Dots", group=grpVisual)
histWidth          = input.int(2, "Histogram Column Width", minval=1, maxval=5, group=grpVisual)
macdWidth          = input.int(3, "MACD Line Width", minval=1, maxval=5, group=grpVisual)
sigWidth           = input.int(2, "Signal Line Width", minval=1, maxval=5, group=grpVisual)

grpScale = "Visual Scaling"
histVisualScale = input.float(1.75, "Histogram Visual Scale", minval=0.25, maxval=5.0, step=0.25, group=grpScale, tooltip="Visual-only multiplier for the plotted histogram. It does not change MACD logic, alerts, HUD values, or divergence calculations.")
showScaleInHUD  = input.bool(true, "Show Histogram Scale in HUD", group=grpScale)

grpColors = "ATC Premium Colors"
macdCol = input.color(#00A6FF, "MACD Line — Electric Blue", group=grpColors)
sigCol  = input.color(#F5C542, "Signal Line — ATC Gold", group=grpColors)
bullCol = input.color(#00E676, "Bullish Histogram — Bright Green", group=grpColors)
bearCol = input.color(#FF3B3B, "Bearish Histogram — Bright Red", group=grpColors)
neutCol = input.color(#8A8F98, "Neutral / Grid", group=grpColors)
bgBull  = input.color(#003D2B, "Bull Background Tint", group=grpColors)
bgBear  = input.color(#4A1010, "Bear Background Tint", group=grpColors)

grpHUD = "HUD"
showHUD  = input.bool(true, "Show HUD", group=grpHUD)
hudPos   = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpHUD)
hudTheme = input.string("Dark", "HUD Theme", options=["Dark", "Light"], group=grpHUD)

// ==========================================================================
// Section C — Core Calculations
// ==========================================================================
fastEma = ta.ema(macdSrc, fastLen)
slowEma = ta.ema(macdSrc, slowLen)
macd    = fastEma - slowEma

// ==========================================================================
// Section D — Enhancement Layer
// ==========================================================================
// D1 — HMA signal line
signal = ta.hma(macd, sigLen)
hist   = macd - signal

// D2 — Standard-deviation-normalized histogram strength
histStd = ta.stdev(hist, zLen)
histZ   = histStd > 0.0 ? hist / histStd : 0.0

absZ   = math.abs(histZ)
rising = hist > nz(hist[1], hist)

// Histogram state buckets
histBullStrong = hist >= 0.0 and rising and absZ >= zStrong
histBullMed    = hist >= 0.0 and rising and absZ >= zFade and absZ < zStrong
histBullWeak   = hist >= 0.0 and absZ < zFade
histBullFade   = hist >= 0.0 and not rising and absZ >= zFade

histBearStrong = hist < 0.0 and not rising and absZ >= zStrong
histBearMed    = hist < 0.0 and not rising and absZ >= zFade and absZ < zStrong
histBearWeak   = hist < 0.0 and absZ < zFade
histBearFade   = hist < 0.0 and rising and absZ >= zFade

color histColor = if histBullStrong
    bullCol
else if histBullMed
    color.new(bullCol, 15)
else if histBullWeak
    color.new(bullCol, 68)
else if histBullFade
    color.new(bullCol, 45)
else if histBearStrong
    bearCol
else if histBearMed
    color.new(bearCol, 15)
else if histBearWeak
    color.new(bearCol, 68)
else
    color.new(bearCol, 45)

// Visual-only histogram scaling
histPlot = hist * histVisualScale

// Premium cloud and background colors
isBullState = macd > signal
isBearState = macd < signal
isAboveZero = macd > 0.0
isBelowZero = macd < 0.0

color cloudColor = if isBullState and isAboveZero
    color.new(bullCol, cloudStrongTransp)
else if isBullState and isBelowZero
    color.new(bullCol, cloudSoftTransp)
else if isBearState and isBelowZero
    color.new(bearCol, cloudStrongTransp)
else
    color.new(bearCol, cloudSoftTransp)

color stateBgColor = if isBullState and isAboveZero
    color.new(bgBull, 84)
else if isBullState and isBelowZero
    color.new(bgBull, 91)
else if isBearState and isBelowZero
    color.new(bgBear, 84)
else
    color.new(bgBear, 91)

color zeroGlowColor = if hist >= 0.0
    color.new(bullCol, 75)
else
    color.new(bearCol, 75)

// ==========================================================================
// Section E — Conservative Pivot-Confirmed Divergence
// ==========================================================================
var float prevPHPrice = na
var float prevPHHist  = na
var int   prevPHBar   = na
var float prevPLPrice = na
var float prevPLHist  = na
var int   prevPLBar   = na

ph = ta.pivothigh(high, pivL, pivR)
pl = ta.pivotlow(low, pivL, pivR)

bearDiv = false
bullDiv = false

if not na(ph)
    curPHPrice = high[pivR]
    curPHHist  = hist[pivR]
    curPHBar   = bar_index - pivR

    if not na(prevPHPrice) and not na(prevPHBar)
        phBarSep = curPHBar - prevPHBar
        phSideOK = not requireSide or (curPHHist > 0.0 and prevPHHist > 0.0)

        if phBarSep >= minBarSep and phBarSep <= maxBarSep and phSideOK
            if curPHPrice > prevPHPrice and curPHHist < prevPHHist
                bearDiv := true

    prevPHPrice := curPHPrice
    prevPHHist  := curPHHist
    prevPHBar   := curPHBar

if not na(pl)
    curPLPrice = low[pivR]
    curPLHist  = hist[pivR]
    curPLBar   = bar_index - pivR

    if not na(prevPLPrice) and not na(prevPLBar)
        plBarSep = curPLBar - prevPLBar
        plSideOK = not requireSide or (curPLHist < 0.0 and prevPLHist < 0.0)

        if plBarSep >= minBarSep and plBarSep <= maxBarSep and plSideOK
            if curPLPrice < prevPLPrice and curPLHist > prevPLHist
                bullDiv := true

    prevPLPrice := curPLPrice
    prevPLHist  := curPLHist
    prevPLBar   := curPLBar

// ==========================================================================
// Section F — Event Conditions
// ==========================================================================
macdBullX     = ta.crossover(macd, signal)
macdBearX     = ta.crossunder(macd, signal)
zeroCrossUp   = ta.crossover(macd, 0.0)
zeroCrossDown = ta.crossunder(macd, 0.0)

// ==========================================================================
// Section G — Premium Plotting System
// ==========================================================================
bgcolor(showStateBg ? stateBgColor : na)

pZeroGlow = plot(showZeroGlow ? 0.0 : na, title="Zero Glow", color=zeroGlowColor, linewidth=5)
hline(0.0, "Zero", color=color.new(neutCol, 25), linestyle=hline.style_dashed)

pHist = plot(histPlot, "Histogram — Visual Scaled", color=histColor, style=plot.style_columns, linewidth=histWidth)
pMACD = plot(macd, "MACD", color=macdCol, linewidth=macdWidth)
pSIG  = plot(signal, "Signal", color=sigCol, linewidth=sigWidth)

fill(pMACD, pSIG, color=showCloud ? cloudColor : na, title="MACD Signal Cloud")

plot(showCrossDots and macdBullX ? macd : na, title="Bull Cross Glow", style=plot.style_circles, color=color.new(bullCol, 70), linewidth=9)
plot(showCrossDots and macdBearX ? macd : na, title="Bear Cross Glow", style=plot.style_circles, color=color.new(bearCol, 70), linewidth=9)

plot(showCrossDots and macdBullX ? macd : na, title="Bull Cross Dot", style=plot.style_circles, color=color.new(bullCol, 0), linewidth=5)
plot(showCrossDots and macdBearX ? macd : na, title="Bear Cross Dot", style=plot.style_circles, color=color.new(bearCol, 0), linewidth=5)

// Divergence labels are placed on the visually scaled histogram so they align with displayed histogram columns.
if enableDiv and bearDiv
    label.new(bar_index - pivR, histPlot[pivR], "BEAR\nDIV", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_down, color=color.new(bearCol, 0), textcolor=color.white, size=size.small)

if enableDiv and bullDiv
    label.new(bar_index - pivR, histPlot[pivR], "BULL\nDIV", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_up, color=color.new(bullCol, 0), textcolor=color.black, size=size.small)

// ==========================================================================
// Section H — Premium HUD
// ==========================================================================
var table hud = na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    hudPosition = if hudPos == "Top Right"
        position.top_right
    else if hudPos == "Top Left"
        position.top_left
    else if hudPos == "Bottom Right"
        position.bottom_right
    else
        position.bottom_left

    bgColor      = hudTheme == "Dark" ? #101216 : #FAFAFA
    headerColor  = hudTheme == "Dark" ? #171B22 : #ECEFF3
    txColor      = hudTheme == "Dark" ? color.white : #222222
    dimColor     = hudTheme == "Dark" ? color.new(color.white, 35) : color.new(#222222, 35)
    borderColor  = hudTheme == "Dark" ? color.new(sigCol, 45) : color.new(macdCol, 55)

    hudRows = showScaleInHUD ? 8 : 7
    hud := table.new(hudPosition, 2, hudRows, bgcolor=bgColor, border_width=1, border_color=borderColor)

    string momState = if macd > signal and macd > 0.0
        "Bull Control"
    else if macd > signal and macd < 0.0
        "Bull Recovery"
    else if macd < signal and macd > 0.0
        "Bear Pressure"
    else
        "Bear Control"

    color momColor = if macd > signal and macd > 0.0
        bullCol
    else if macd > signal and macd < 0.0
        color.new(bullCol, 15)
    else if macd < signal and macd > 0.0
        color.new(bearCol, 15)
    else
        bearCol

    string zStrength = if absZ >= zStrong
        "Strong"
    else if absZ >= zFade
        "Moderate"
    else
        "Weak"

    color zColor = if absZ >= zStrong
        hist >= 0.0 ? bullCol : bearCol
    else if absZ >= zFade
        txColor
    else
        dimColor

    string histZText = histZ >= 0.0 ? "+" + str.tostring(histZ, "#.##") : str.tostring(histZ, "#.##")
    string divText = enableDiv ? (bearDiv ? "Bear Div @ Pivot" : bullDiv ? "Bull Div @ Pivot" : "Watching") : "Off"
    color divColor = bearDiv ? bearCol : bullDiv ? bullCol : dimColor

    table.cell(hud, 0, 0, "MACD", text_color=sigCol, bgcolor=headerColor, text_size=size.small)
    table.cell(hud, 1, 0, "Evolved v1.2.1", text_color=macdCol, bgcolor=headerColor, text_size=size.small)

    table.cell(hud, 0, 1, "MACD", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 1, str.tostring(macd, "#.####"), text_color=macdCol, bgcolor=bgColor, text_size=size.small)

    table.cell(hud, 0, 2, "Signal", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(signal, "#.####"), text_color=sigCol, bgcolor=bgColor, text_size=size.small)

    table.cell(hud, 0, 3, "Hist Strength", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 3, histZText, text_color=zColor, bgcolor=bgColor, text_size=size.small)

    table.cell(hud, 0, 4, "Strength", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 4, zStrength, text_color=zColor, bgcolor=bgColor, text_size=size.small)

    table.cell(hud, 0, 5, "State", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 5, momState, text_color=momColor, bgcolor=color.new(momColor, 86), text_size=size.small)

    table.cell(hud, 0, 6, "Divergence", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
    table.cell(hud, 1, 6, divText, text_color=divColor, bgcolor=bgColor, text_size=size.small)

    if showScaleInHUD
        table.cell(hud, 0, 7, "Hist Visual", text_color=dimColor, bgcolor=bgColor, text_size=size.small)
        table.cell(hud, 1, 7, "x" + str.tostring(histVisualScale, "#.##"), text_color=txColor, bgcolor=bgColor, text_size=size.small)

// ==========================================================================
// Section I — Alerts
// ==========================================================================
alertcondition(macdBullX, "MACD Bull Cross", "ATC MACD: Bullish signal-line crossover")
alertcondition(macdBearX, "MACD Bear Cross", "ATC MACD: Bearish signal-line crossover")
alertcondition(zeroCrossUp, "MACD Zero Cross Up", "ATC MACD: MACD line crossed above zero")
alertcondition(zeroCrossDown, "MACD Zero Cross Down", "ATC MACD: MACD line crossed below zero")
alertcondition(histBullStrong and not histBullStrong[1], "Strong Bull Histogram", "ATC MACD: Histogram print exceeded positive strong threshold")
alertcondition(histBearStrong and not histBearStrong[1], "Strong Bear Histogram", "ATC MACD: Histogram print exceeded negative strong threshold")
alertcondition(enableDiv and bearDiv, "Bear Divergence", "ATC MACD: Confirmed bearish divergence")
alertcondition(enableDiv and bullDiv, "Bull Divergence", "ATC MACD: Confirmed bullish divergence")
````
