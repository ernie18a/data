# Hysteresis VWAP Regime Bands [ATC]

- url: https://www.tradingview.com/script/z4dN46L6-Hysteresis-VWAP-Regime-Bands-ATC/
- type: indicator
- pine_id: PUB;37ce5e59225949ff854c58ba1758312a
- version: 1.0

## Description

[b]Hysteresis VWAP Regime Bands [ATC][/b] is a VWAP-based market context indicator designed to help traders read price location, VWAP extension, and volatility structure more clearly.

This script plots an anchored VWAP with ±1SD and ±2SD bands, then adds two differentiating context layers:

1.	A hysteresis-based price-location classifier that helps reduce noisy zone flicker around VWAP band boundaries. 

2.	A rolling Z-score VWAP bandwidth regime classifier that identifies whether the VWAP envelope is compressed, normal, or expanded compared to recent conditions. 

This is not a buy/sell signal generator. It is a structured VWAP context tool intended to help traders understand where price is trading relative to volume-weighted value.

________________________________________

[b]What Makes This Different From Standard VWAP Bands[/b]

Most VWAP band indicators simply plot VWAP and deviation bands. This script adds stabilized interpretation logic on top of the bands.

[b]1. Hysteresis-Based Price Zones[/b]

Standard band logic can become noisy when price hovers near +1SD, -1SD, +2SD, or -2SD. A simple raw comparison may flip the displayed state back and forth every few bars.
This script uses a configurable Price-Zone Hysteresis Buffer. Price must clear a VWAP band boundary by a defined margin before the zone state updates. This helps create cleaner, more stable zone readings.

[b]2. VWAP Bandwidth Regime Classification[/b]

The script also measures the current width of the VWAP envelope and compares it to its own rolling baseline using a Z-score.

[b]This creates three bandwidth regimes:[/b]

•	Compressed Width — the VWAP envelope is unusually narrow. 
•	Normal Width — the VWAP envelope is near its recent baseline. 
•	Expanded Width — the VWAP envelope is unusually wide. 

This helps traders distinguish whether the market is operating in a tighter value structure or a wider, more volatile structure.

Together, these two additions turn VWAP bands from simple plotted levels into a more complete VWAP context framework.

________________________________________

[b]Core Components[/b]

[b]VWAP Line[/b]

The VWAP line is the central volume-weighted value reference for the selected anchor period. It represents the average price weighted by traded volume.

Price above VWAP means price is trading above volume-weighted value.

Price below VWAP means price is trading below volume-weighted value.

A rising VWAP suggests value is moving higher.

A falling VWAP suggests value is moving lower.

VWAP can act as a trend anchor, mean-reversion reference, or decision level depending on the structure of the session.

________________________________________

[b]±1SD Bands[/b]

The ±1 standard deviation bands define the inner VWAP value envelope.

Price between +1SD and -1SD is closer to central VWAP value.

Price holding above +1SD shows upper-side acceptance.

Price holding below -1SD shows lower-side acceptance.

These bands are often useful for identifying whether price is still trading near value or 
beginning to move directionally away from value.

________________________________________

[b]±2SD Bands[/b]

The ±2 standard deviation bands define the outer VWAP envelope.

Price beyond +2SD is in an upper extension area.

Price beyond -2SD is in a lower extension area.

These zones can indicate strong directional movement or stretched price location. They should not be treated as automatic reversal signals. Strong trend sessions can continue to hold near or beyond outer VWAP bands for extended periods.

________________________________________

[b]Price-Location Zones[/b]

The script classifies price into five VWAP location zones:

[b]Above +2SD — Upper Extreme[/b]

Price is trading beyond the upper outer VWAP band. This is an extended upper location relative to VWAP.
This may represent strong upside momentum, but it can also mean the move is becoming stretched. Traders should avoid assuming that upper extreme automatically means reversal.

________________________________________

[b]Above +1SD — Upper Bias[/b]

Price is trading above the inner upper VWAP band but below the outer upper band.
This shows price is accepting above central value. In a strong session, this can support a bullish continuation context.

________________________________________

[b]Mid-Band — Neutral[/b]

Price is trading between +1SD and -1SD.
This is the central VWAP value zone. Price is closer to volume-weighted fair value, and directional conviction may be weaker unless there is clear price action confirmation.

________________________________________

[b]Below -1SD — Lower Bias[/b]

Price is trading below the inner lower VWAP band but above the outer lower band.
This shows price is accepting below central value. In a weak session, this can support a bearish continuation context.

________________________________________

[b]Below -2SD — Lower Extreme[/b]

Price is trading beyond the lower outer VWAP band. This is an extended lower location relative to VWAP.
This may represent strong downside pressure, but it can also mean price is stretched to the downside. It should be interpreted with confirmation.

________________________________________

[b]Bandwidth Regime[/b]

The bandwidth regime measures the width between the outer VWAP bands and normalizes it against recent conditions.

The script calculates the current VWAP envelope width as a percentage of VWAP, then compares that value to its own rolling mean and standard deviation.

This creates a normalized bandwidth Z-score.

[b]Compressed Width[/b]

The VWAP envelope is unusually narrow compared to recent conditions.
This may suggest a more balanced, contained, or compressed environment. Compression does not predict direction by itself. It simply tells you that the VWAP structure is tighter than normal.

________________________________________

[b]Normal Width[/b]

The VWAP envelope is near its recent baseline.
This suggests that current VWAP band width is within a typical range relative to recent conditions.

________________________________________

[b]Expanded Width[/b]

The VWAP envelope is unusually wide compared to recent conditions.
This may suggest increased price dispersion, volatility, or stronger directional movement. Expanded width also means risk can be wider, so chasing late moves may become less attractive.

________________________________________

[b]Color and Visual Interpretation[/b]

The color system is designed to make the VWAP structure easier to read at a glance. Colors are not standalone trade signals. They are visual context cues.
________________________________________

[b]Cyan / Blue — VWAP and Central Value[/b]

The bright cyan VWAP line is the central fair-value reference.
How to interpret it:

•	Price above VWAP = trading above volume-weighted value 
•	Price below VWAP = trading below volume-weighted value 
•	Rising VWAP = value is moving higher 
•	Falling VWAP = value is moving lower 

The blue/cyan fill between +1SD and -1SD represents the central VWAP value area.

________________________________________

[b]Green / Mint — Upper VWAP Structure[/b]

Green or mint colors represent upper VWAP structure.

This includes:

•	Upper VWAP bands 
•	Upper-side price zones 
•	Upper extension areas 
•	Bullish or upside location context 

How to interpret it:

•	Price above +1SD shows upper-side acceptance. 
•	Price between +1SD and +2SD shows price is elevated above value. 
•	Price above +2SD shows upper extension. 

Green does not automatically mean buy. It means price is trading in the upper VWAP structure.

________________________________________

[b]Pink / Red — Lower VWAP Structure[/b]

Pink or red colors represent lower VWAP structure.

This includes:

•	Lower VWAP bands 
•	Lower-side price zones 
•	Lower extension areas 
•	Bearish or downside location context 

How to interpret it:

•	Price below -1SD shows lower-side acceptance. 
•	Price between -1SD and -2SD shows price is depressed below value. 
•	Price below -2SD shows lower extension. 

Red does not automatically mean short. It means price is trading in the lower VWAP structure.

________________________________________

[b]Blue / Cyan Fill — Neutral Value Zone[/b]

The area between +1SD and -1SD is lightly filled with a blue/cyan tint.

How to interpret it:

•	Price inside this area is closer to volume-weighted value. 
•	This zone often reflects more balanced conditions. 
•	Directional conviction may be weaker unless price breaks and holds outside the inner bands. 
•	Traders may use this area to identify chop, mean reversion, or developing acceptance near VWAP. 

________________________________________

[b]Green Fill — Upper Extension Zone[/b]

The area between +1SD and +2SD may be filled with a green tint.

How to interpret it:

•	Price holding in this area shows upper-side acceptance. 
•	During strong sessions, pullbacks toward +1SD can act as continuation areas. 
•	If price loses +1SD and cannot reclaim it, upper-side acceptance may be weakening. 

________________________________________

[b]Red Fill — Lower Extension Zone[/b]

The area between -1SD and -2SD may be filled with a red tint.

How to interpret it:

•	Price holding in this area shows lower-side acceptance. 
•	During weak sessions, pullbacks toward -1SD can act as continuation areas. 
•	If price reclaims -1SD and holds above it, lower-side pressure may be weakening. 

________________________________________

[b]Violet / Purple — Compressed Width[/b]

Violet or purple represents a compressed VWAP bandwidth regime.

How to interpret it:

•	VWAP bands are tighter than normal. 
•	Price may be in a more balanced or contained structure. 
•	Volatility is relatively compressed. 
•	Compression can precede expansion, but it does not predict direction. 
Compression means the VWAP envelope is narrow, not necessarily bullish or bearish.

________________________________________

[b]Amber / Orange — Expanded Width[/b]

Amber or orange represents an expanded VWAP bandwidth regime.

How to interpret it:

•	VWAP bands are wider than normal. 
•	Price dispersion has increased. 
•	Volatility or directional movement may be elevated. 
•	Risk may be wider because price is moving across a larger structure. 
•	Late entries after a large move may require more caution. 

Expansion means the VWAP envelope is wide. It does not automatically mean the move is over.

________________________________________

[b]Background Tints[/b]

The script can apply subtle background tints for extreme price zones or bandwidth regimes.

How to interpret them:

•	Green tint = upper extreme or strong upper-side context 
•	Red tint = lower extreme or strong lower-side context 
•	Violet tint = compressed bandwidth regime 
•	Amber tint = expanded bandwidth regime 

If an extreme price zone and a bandwidth regime occur at the same time, the script prioritizes the more immediate price-location context so the chart remains readable.

________________________________________

[b]HUD Display[/b]

The HUD provides a compact summary of the current VWAP structure.

It includes:

•	VWAP Regime — current anchor mode and source price 
•	VWAP — current VWAP value 
•	+1SD / -1SD — current inner band values 
•	+2SD / -2SD — current outer band values 
•	Price Zone — current hysteresis-confirmed VWAP location 
•	Band Regime — current bandwidth regime and width Z-score 
•	Use — reminder that this is a context tool and should be confirmed with price action 

The two most important HUD fields are Price Zone and Band Regime.

________________________________________

[b]Price Zone[/b]
This shows where price is trading relative to the VWAP bands.
Because the zone logic uses hysteresis, it does not flip on every minor touch of a band. Price must move beyond the band boundary by the configured buffer before the state changes.

________________________________________

[b]Band Regime[/b]
This shows whether the VWAP envelope is compressed, normal, or expanded compared to recent conditions.
This helps traders understand whether price is moving inside a tight VWAP structure or a wider volatility structure.

________________________________________

[b]Anchor Modes[/b]
The script supports three anchor modes.
Session
VWAP resets at the selected regular trading session. This is the default mode and is best suited for intraday trading.
The default session is 0930–1600 New York time.
The session reset logic is designed to work whether extended-hours bars are visible or hidden. This helps keep the session VWAP behavior consistent on regular-hours-only charts.

________________________________________

[b]Week[/b]
VWAP resets at the start of a new week.
This can be useful for traders who want broader weekly value context on intraday or lower-timeframe charts.

________________________________________

[b]Month[/b]
VWAP resets at the start of a new month.
This can be useful for traders monitoring broader monthly value structure.

________________________________________

[b]Source Price Options[/b]
The VWAP source can be configured as:
•	hlc3 — average of high, low, and close 
•	hl2 — average of high and low 
•	ohlc4 — average of open, high, low, and close 
•	close — close-only source 
For most intraday use, hlc3 is a balanced default.

________________________________________

[b]Alerts[/b]

The script includes alert conditions for:
•	VWAP Cross 
•	+1SD Cross 
•	-1SD Cross 
•	+2SD Cross 
•	-2SD Cross 
•	VWAP Zone Change 
•	VWAP Bandwidth Regime Change 

The zone-change and regime-change alerts are the most specific to this script’s added logic. They are based on stabilized state models rather than raw band touches alone.
________________________________________

[b]How to Use It[/b]

Use this indicator as a VWAP context layer, not as a standalone trading system.

A practical workflow:

1.	Start with the VWAP line to identify whether price is above or below volume-weighted value. 

2.	Use the Price Zone to determine whether price is neutral, biased above value, biased below value, or extended. 

3.	Use the Band Regime to determine whether the VWAP envelope is compressed, normal, or expanded. 

4.	Use price action, structure, volume, or your own entry model to confirm trades. 

________________________________________

[b]Practical Interpretation Examples[/b]

[b]Example 1[/b]

Price Zone: Above +1SD — Upper Bias
Band Regime: Expanded Width
This means price is trading above the central VWAP value area while the VWAP envelope is wider than normal.
The context is bullish in location, but risk may also be wider because price dispersion has expanded. In this environment, traders may prefer pullback confirmation instead of chasing after a large move.
________________________________________

[b]Example 2[/b]

Price Zone: Mid-Band — Neutral
Band Regime: Compressed Width
This means price is near VWAP value and the bands are unusually tight.
This often represents a balanced or compressed environment. Traders may wait for price to break and hold outside the inner VWAP bands before treating the move as directional.
________________________________________

[b]Example 3[/b]

Price Zone: Below -2SD — Lower Extreme
Band Regime: Expanded Width
This means price is extended below VWAP while the VWAP envelope is wider than normal.
This may reflect strong downside pressure, but it may also mean short-side chase risk is elevated. Confirmation from price action is important.
________________________________________

[b]Recommended Markets and Timeframes[/b]

This indicator is designed for liquid instruments where VWAP is meaningful, including:
•	Equity index futures 
•	Major ETFs 
•	Liquid large-cap stocks 
•	Major FX pairs 
•	Liquid crypto markets 

Recommended intraday timeframes:
•	1-minute 
•	3-minute 
•	5-minute 
•	15-minute 

Session anchor mode is intended primarily for intraday charts. Weekly and monthly anchors may be useful when viewing broader value structure.

________________________________________

[b]Important Notes[/b]

This indicator does not predict future price movement. It does not issue buy or sell signals. It provides a structured view of VWAP location, VWAP extension, and VWAP bandwidth regime so traders can make more informed decisions within their own strategy.

VWAP bands, price-location zones, and bandwidth regimes should be interpreted as context. Always confirm with price action, volume, risk controls, and your own trading plan.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ATConcepts

// ==========================================================================
// Hysteresis VWAP Regime Bands [ATC] — v2.1
// Part of the ATC Free-Tier Library
//
// Author: Ascend Trading Concepts
// License: Free for personal use. Redistribution requires attribution.
//
// Intended Instruments: All liquid intraday instruments - futures, ETFs, large-cap equities, FX, crypto
// Intended Timeframes: 1m, 3m, 5m, 15m
// Publication Tier: Free
//
// Summary:
// Plots an anchored VWAP with ±1SD and ±2SD bands, then adds two
// differentiating context layers: a hysteresis-based 5-zone price-location
// classifier and a rolling Z-score VWAP bandwidth regime classifier.
//
// The hysteresis feature helps reduce flicker when price is hovering near
// VWAP band boundaries, while the bandwidth regime layer identifies whether
// the VWAP envelope is compressed, normal, or expanded relative to recent
// conditions.
//
// This makes the script more than a standard VWAP Bands indicator. It is a
// stabilized VWAP context framework designed to help traders read price
// location, extension, and volatility state more clearly.
// ==========================================================================
//@version=6
indicator("Hysteresis VWAP Regime Bands [ATC]", shorttitle="HVWAP Regime [ATC]", overlay=true)

// ==========================================================================
// Section B — User Inputs
// ==========================================================================
grpHUD = "HUD"
showHUD = input.bool(true, "Show HUD", group=grpHUD, tooltip="Shows the corner HUD with VWAP, zone, and bandwidth regime information.")
hudPos = input.string("Top Right", "HUD Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=grpHUD, tooltip="Selects which chart corner the HUD will use.")
hudTheme = input.string("Dark Glass", "HUD Theme", options=["Dark Glass", "Light"], group=grpHUD, tooltip="Chooses the HUD color theme.")
hudOpacity = input.int(8, "HUD Background Opacity", minval=0, maxval=95, group=grpHUD, tooltip="Higher values make the HUD background more transparent.")

grpVWAP = "VWAP Configuration"
anchorMode = input.string("Session", "Anchor", options=["Session", "Week", "Month"], group=grpVWAP, tooltip="Resets VWAP at the selected anchor boundary.")
srcType = input.string("hlc3", "Source Price", options=["hlc3", "hl2", "ohlc4", "close"], group=grpVWAP, tooltip="Price source used in the VWAP calculation.")
sessDef = input.session("0930-1600", "Session", group=grpVWAP, tooltip="Regular session used when Anchor is set to Session.")
sessTZ = input.string("America/New_York", "Timezone", group=grpVWAP, tooltip="Timezone used for session detection when Anchor is set to Session.")

grpZone = "Price-Zone Logic"
zoneBufferPct = input.float(5.0, "Price-Zone Hysteresis Buffer (%)", minval=0.0, step=0.5, group=grpZone, tooltip="Buffer around band boundaries, measured as a percentage of the 1SD width, to reduce zone flicker.")
showZoneBg = input.bool(true, "Show Extreme Zone Background", group=grpZone, tooltip="Applies a subtle background tint when price is in an extreme VWAP zone.")
zoneBgOpacity = input.int(92, "Extreme Background Opacity", minval=80, maxval=100, group=grpZone, tooltip="Higher values make the extreme-zone background more subtle.")

grpRegime = "Bandwidth Regime"
regimeLookback = input.int(100, "Bandwidth Regime Lookback", minval=25, maxval=500, group=grpRegime, tooltip="Rolling lookback used to normalize VWAP envelope width.")
regimeZThreshold = input.float(0.80, "Expansion / Compression Threshold (Z)", minval=0.20, maxval=3.00, step=0.05, group=grpRegime, tooltip="Z-score level used to classify band width as compressed or expanded.")
regimeHysteresis = input.float(0.20, "Regime Hysteresis (Z)", minval=0.00, maxval=1.00, step=0.05, group=grpRegime, tooltip="Buffer used to prevent the bandwidth regime from flickering around the threshold.")
showRegimeBg = input.bool(true, "Show Regime Background", group=grpRegime, tooltip="Adds a subtle background tint for compression or expansion regimes.")
regimeBgOpacity = input.int(94, "Regime Background Opacity", minval=80, maxval=100, group=grpRegime, tooltip="Higher values make the bandwidth-regime background more subtle.")

grpBand = "Bands"
show1SD = input.bool(true, "Show +/-1SD Bands", group=grpBand, tooltip="Shows the 1 standard-deviation VWAP bands.")
show2SD = input.bool(true, "Show +/-2SD Bands", group=grpBand, tooltip="Shows the 2 standard-deviation VWAP bands.")
showNeutralFill = input.bool(true, "Show Neutral Fill", group=grpBand, tooltip="Fills the area between +1SD and -1SD.")
showOuterFill = input.bool(true, "Show Outer Band Fill", group=grpBand, tooltip="Fills the area between 1SD and 2SD bands.")

grpVisual = "Premium Visuals"
showVwapGlow = input.bool(true, "Show VWAP Glow", group=grpVisual, tooltip="Adds a soft glow layer underneath the VWAP line.")
vwapCoreWidth = input.int(3, "VWAP Core Width", minval=1, maxval=6, group=grpVisual, tooltip="Line width for the primary VWAP line.")
vwapGlowWidth = input.int(8, "VWAP Glow Width", minval=3, maxval=12, group=grpVisual, tooltip="Line width for the VWAP glow layer.")
innerBandWidth = input.int(2, "Inner Band Width", minval=1, maxval=5, group=grpVisual, tooltip="Line width for the +/-1SD bands.")
outerBandWidth = input.int(1, "Outer Band Width", minval=1, maxval=4, group=grpVisual, tooltip="Line width for the +/-2SD bands.")
neutralFillOpacity = input.int(89, "Neutral Fill Opacity", minval=70, maxval=100, group=grpVisual, tooltip="Higher values make the neutral fill more subtle.")
outerFillOpacity = input.int(91, "Outer Fill Opacity", minval=70, maxval=100, group=grpVisual, tooltip="Higher values make the outer band fills more subtle.")

grpColor = "Color Palette"
colVWAP = input.color(#3FD8FF, "VWAP Color", group=grpColor, tooltip="Primary VWAP line color.")
colBull = input.color(#35FFB5, "Upper / Bull Color", group=grpColor, tooltip="Color used for upper zones and bullish context.")
colBear = input.color(#FF4F8B, "Lower / Bear Color", group=grpColor, tooltip="Color used for lower zones and bearish context.")
colNeutral = input.color(#BFC8D8, "Neutral Color", group=grpColor, tooltip="Neutral text and structure color.")
colCompressed = input.color(#9B87FF, "Compressed Regime Color", group=grpColor, tooltip="Color used when VWAP bands are unusually compressed.")
colExpanded = input.color(#FFB84D, "Expanded Regime Color", group=grpColor, tooltip="Color used when VWAP bands are unusually expanded.")

// ==========================================================================
// Section C — Core Calculations
// ==========================================================================
formatPrice(float value) =>
    string txt = "na"
    if not na(value)
        txt := str.tostring(value, format.mintick)
    txt

formatNumber(float value) =>
    string txt = "na"
    if not na(value)
        txt := str.tostring(value, "#.##")
    txt

float srcRaw = close
if srcType == "hlc3"
    srcRaw := hlc3
else if srcType == "hl2"
    srcRaw := hl2
else if srcType == "ohlc4"
    srcRaw := ohlc4
else
    srcRaw := close

bool inSession = not na(time(timeframe.period, sessDef, sessTZ))

bool wasInSession = false
if bar_index > 0
    wasInSession := inSession[1]

bool sessionTransition = inSession and not wasInSession

dayChange = ta.change(time("D"))
weekChange = ta.change(time("W"))
monthChange = ta.change(time("M"))

bool calendarDayChanged = bar_index > 0 and not na(dayChange) and dayChange != 0
bool calendarWeekChanged = bar_index > 0 and not na(weekChange) and weekChange != 0
bool calendarMonthChanged = bar_index > 0 and not na(monthChange) and monthChange != 0

bool firstChartBar = bar_index == 0

bool newSession = inSession and (sessionTransition or calendarDayChanged or firstChartBar)

bool anchorReset = false
if anchorMode == "Session"
    anchorReset := newSession
else if anchorMode == "Week"
    anchorReset := calendarWeekChanged or firstChartBar
else
    anchorReset := calendarMonthChanged or firstChartBar

float src = srcRaw
if anchorMode == "Session" and not inSession
    src := na

[vwapValue, upper1, lower1] = ta.vwap(src, anchorReset, 1.0)

float stdevValue = na
if not na(upper1) and not na(vwapValue)
    stdevValue := upper1 - vwapValue

float upper2 = na
float lower2 = na
if not na(stdevValue) and not na(vwapValue)
    upper2 := vwapValue + stdevValue * 2.0
    lower2 := vwapValue - stdevValue * 2.0

bool haveBands = not na(vwapValue) and not na(upper1) and not na(lower1) and not na(upper2) and not na(lower2) and not na(stdevValue)

// ==========================================================================
// Section D — Differentiation Layer
// ==========================================================================

// Differentiator 1: Hysteresis-based price-location classification.
var string zoneState = "Mid-Band - Neutral"

float zoneBuffer = na
if not na(stdevValue)
    zoneBuffer := math.abs(stdevValue) * zoneBufferPct * 0.01

if haveBands and not na(zoneBuffer)
    if close > upper2 + zoneBuffer
        zoneState := "Above +2SD - Upper Extreme"
    else if close > upper1 + zoneBuffer and close < upper2 - zoneBuffer
        zoneState := "Above +1SD - Upper Bias"
    else if close > lower1 + zoneBuffer and close < upper1 - zoneBuffer
        zoneState := "Mid-Band - Neutral"
    else if close > lower2 + zoneBuffer and close < lower1 - zoneBuffer
        zoneState := "Below -1SD - Lower Bias"
    else if close < lower2 - zoneBuffer
        zoneState := "Below -2SD - Lower Extreme"

color zoneColor = colNeutral
if zoneState == "Above +2SD - Upper Extreme" or zoneState == "Above +1SD - Upper Bias"
    zoneColor := colBull
else if zoneState == "Below -1SD - Lower Bias" or zoneState == "Below -2SD - Lower Extreme"
    zoneColor := colBear

// Differentiator 2: VWAP bandwidth regime classification.
float bandWidthPct = na
if haveBands and vwapValue != 0
    bandWidthPct := ((upper2 - lower2) / math.abs(vwapValue)) * 100.0

float widthMean = ta.sma(bandWidthPct, regimeLookback)
float widthStdev = ta.stdev(bandWidthPct, regimeLookback)

float widthZ = na
if not na(bandWidthPct) and not na(widthMean) and not na(widthStdev) and widthStdev != 0
    widthZ := (bandWidthPct - widthMean) / widthStdev

var string regimeState = "Normal Width"

float expansionTrigger = regimeZThreshold
float compressionTrigger = -regimeZThreshold
float expansionReset = regimeZThreshold - regimeHysteresis
float compressionReset = -regimeZThreshold + regimeHysteresis

if not na(widthZ)
    if widthZ > expansionTrigger
        regimeState := "Expanded Width"
    else if widthZ < compressionTrigger
        regimeState := "Compressed Width"
    else if widthZ < expansionReset and widthZ > compressionReset
        regimeState := "Normal Width"

color regimeColor = colNeutral
if regimeState == "Compressed Width"
    regimeColor := colCompressed
else if regimeState == "Expanded Width"
    regimeColor := colExpanded

// ==========================================================================
// Section E — Premium Visual Rendering
// ==========================================================================
color zoneBg = na
if showZoneBg
    if zoneState == "Above +2SD - Upper Extreme"
        zoneBg := color.new(colBull, zoneBgOpacity)
    else if zoneState == "Below -2SD - Lower Extreme"
        zoneBg := color.new(colBear, zoneBgOpacity)

color regimeBg = na
if showRegimeBg
    if regimeState == "Compressed Width"
        regimeBg := color.new(colCompressed, regimeBgOpacity)
    else if regimeState == "Expanded Width"
        regimeBg := color.new(colExpanded, regimeBgOpacity)

color finalBg = na
if not na(zoneBg)
    finalBg := zoneBg
else
    finalBg := regimeBg

bgcolor(finalBg, title="Zone / Regime Background")

plotVWAPGlow = plot(showVwapGlow ? vwapValue : na, "VWAP Glow", color=color.new(colVWAP, 78), linewidth=vwapGlowWidth, style=plot.style_linebr)
plotVWAP = plot(vwapValue, "VWAP", color=colVWAP, linewidth=vwapCoreWidth, style=plot.style_linebr)

plotUpper1 = plot(show1SD ? upper1 : na, "+1SD", color=color.new(colBull, 18), linewidth=innerBandWidth, style=plot.style_linebr)
plotLower1 = plot(show1SD ? lower1 : na, "-1SD", color=color.new(colBear, 18), linewidth=innerBandWidth, style=plot.style_linebr)

plotUpper2 = plot(show2SD ? upper2 : na, "+2SD", color=color.new(colBull, 52), linewidth=outerBandWidth, style=plot.style_linebr)
plotLower2 = plot(show2SD ? lower2 : na, "-2SD", color=color.new(colBear, 52), linewidth=outerBandWidth, style=plot.style_linebr)

fill(plotUpper1, plotLower1, color=showNeutralFill and show1SD ? color.new(colVWAP, neutralFillOpacity) : na, title="VWAP Neutral Zone")
fill(plotUpper2, plotUpper1, color=showOuterFill and show1SD and show2SD ? color.new(colBull, outerFillOpacity) : na, title="Upper Extension Zone")
fill(plotLower1, plotLower2, color=showOuterFill and show1SD and show2SD ? color.new(colBear, outerFillOpacity) : na, title="Lower Extension Zone")

// ==========================================================================
// Section F — HUD
// ==========================================================================
var table hud = na

if not showHUD and not na(hud)
    table.delete(hud)
    hud := na

if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)

    hudPosition = position.top_right
    if hudPos == "Top Left"
        hudPosition := position.top_left
    else if hudPos == "Bottom Right"
        hudPosition := position.bottom_right
    else if hudPos == "Bottom Left"
        hudPosition := position.bottom_left

    color baseBg = color.rgb(7, 10, 18)
    color hudText = color.rgb(245, 248, 255)
    color hudSub = color.rgb(180, 190, 210)
    color borderCol = color.new(colVWAP, 60)

    if hudTheme == "Light"
        baseBg := color.rgb(250, 252, 255)
        hudText := color.rgb(25, 30, 40)
        hudSub := color.rgb(78, 88, 105)
        borderCol := color.new(colVWAP, 70)

    color hudBg = color.new(baseBg, hudOpacity)
    color zoneChipBg = color.new(zoneColor, 82)
    color regimeChipBg = color.new(regimeColor, 82)

    string anchorText = anchorMode
    if anchorMode == "Session"
        anchorText := "Session | " + sessDef

    string bands1Text = formatPrice(upper1) + " / " + formatPrice(lower1)
    string bands2Text = formatPrice(upper2) + " / " + formatPrice(lower2)
    string regimeText = regimeState + " | Z " + formatNumber(widthZ)

    hud := table.new(hudPosition, 2, 7, bgcolor=hudBg, border_width=1, border_color=borderCol)

    table.cell(hud, 0, 0, "VWAP Regime", text_color=hudText, bgcolor=color.new(colVWAP, 86), text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 0, anchorText + " | " + srcType, text_color=hudText, bgcolor=color.new(colVWAP, 90), text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 1, "VWAP", text_color=hudSub, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 1, formatPrice(vwapValue), text_color=colVWAP, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 2, "+1SD / -1SD", text_color=hudSub, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 2, bands1Text, text_color=hudText, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 3, "+2SD / -2SD", text_color=hudSub, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 3, bands2Text, text_color=hudText, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 4, "Price Zone", text_color=hudSub, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 4, zoneState, text_color=zoneColor, bgcolor=zoneChipBg, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 5, "Band Regime", text_color=hudSub, text_size=size.small, text_halign=text.align_left)
    table.cell(hud, 1, 5, regimeText, text_color=regimeColor, bgcolor=regimeChipBg, text_size=size.small, text_halign=text.align_right)

    table.cell(hud, 0, 6, "Use", text_color=color.new(hudSub, 30), text_size=size.tiny, text_halign=text.align_left)
    table.cell(hud, 1, 6, "Context only - confirm with price action", text_color=color.new(hudSub, 30), text_size=size.tiny, text_halign=text.align_right)

// ==========================================================================
// Section G — Alerts
// ==========================================================================
bool crossVWAP = not na(vwapValue) and ta.cross(close, vwapValue)
bool crossUpper1 = not na(upper1) and ta.cross(close, upper1)
bool crossLower1 = not na(lower1) and ta.cross(close, lower1)
bool crossUpper2 = not na(upper2) and ta.cross(close, upper2)
bool crossLower2 = not na(lower2) and ta.cross(close, lower2)
bool zoneChanged = bar_index > 0 and zoneState != zoneState[1]
bool regimeChanged = bar_index > 0 and regimeState != regimeState[1]

alertcondition(crossVWAP, "VWAP Cross", "Price crossed VWAP on {{ticker}}")
alertcondition(crossUpper1, "+1SD Cross", "Price crossed the +1SD VWAP band on {{ticker}}")
alertcondition(crossLower1, "-1SD Cross", "Price crossed the -1SD VWAP band on {{ticker}}")
alertcondition(crossUpper2, "+2SD Cross", "Price crossed the +2SD VWAP band on {{ticker}}")
alertcondition(crossLower2, "-2SD Cross", "Price crossed the -2SD VWAP band on {{ticker}}")
alertcondition(zoneChanged, "VWAP Zone Change", "VWAP price-location zone changed on {{ticker}}")
alertcondition(regimeChanged, "VWAP Bandwidth Regime Change", "VWAP bandwidth regime changed on {{ticker}}")
````
