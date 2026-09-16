<!-- tradingview-pine-id: PUB;c67a231e502d4facbab8217994529119 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Triple VWAP - Session Weekly Monthly

Source: https://www.tradingview.com/script/dNHPV0gX-Triple-VWAP-Session-Weekly-Monthly/

## Description

This indicator as been tested in these assets

[symbol="CAPITALCOM:GER40"]CAPITALCOM:GER40[/symbol] 
[symbol="CAPITALCOM:NAS100"]CAPITALCOM:NAS100[/symbol] 
[symbol="CAPITALCOM:SPX500"]CAPITALCOM:SPX500[/symbol] 

Triple VWAP is a TradingView indicator that combines Session VWAP, Weekly VWAP and Monthly VWAP into one chart.

Each VWAP can be configured independently. The indicator supports standard deviation or percentage bands, with up to three customizable band levels. Source, offset, calculation timeframe, band visibility, fills and other settings can be adjusted separately for Session, Weekly and Monthly VWAP.

The 1 standard deviation bands can help identify areas of value, rotation and deviation from VWAP. Price holding around VWAP can indicate balance, while sustained movement outside the bands can provide context for momentum, acceptance and possible continuation.

The three VWAPs can also be used together to identify confluence between short-term and higher-timeframe value areas.

Example trade: GER40 5-minute chart.[image]https://www.tradingview.com/x/11hKW5fG/[/image]

In the example, price sold off into an area where the Weekly VWAP and Session VWAP were closely aligned. This created a higher-confluence support area.

Price reacted from the VWAP zone and began moving back above the levels. The long entry was taken after the bullish reaction and confirmation.
The setup was based on:

Price reaching the Weekly and Session VWAP confluence.
The area holding as support.
Price reclaiming the VWAP area.
Bullish confirmation before entering.

The VWAP itself is not treated as an automatic entry signal. The setup combines location, timeframe confluence, price reaction and confirmation.

This indicator is intended as a reference tool for market structure, value, mean reversion, support and resistance, and trend analysis. It should be used together with appropriate risk management and additional market analysis.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Dragner24
//@version=6
indicator("Triple VWAP - Session Weekly Monthly", shorttitle="Triple VWAP", overlay=true, timeframe="", timeframe_gaps=true)
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// MPL-2.0
//@version=6
// --- Constants ---
string STANDARD_DEVIATION = "Standard Deviation"
string PERCENTAGE = "Percentage"
string SESSION_GROUP = "SESSION VWAP"
string WEEKLY_GROUP = "WEEKLY VWAP"
string MONTHLY_GROUP = "MONTHLY VWAP"
string STYLE_GROUP = "STYLE"

// --- Session inputs ---
sessionEnabled = input.bool(true, "Enable Session VWAP", group=SESSION_GROUP)
sessionHideDwm = input.bool(false, "Hide VWAP on 1D or Above", group=SESSION_GROUP)
sessionSource = input.source(hlc3, "Source", group=SESSION_GROUP)
sessionOffset = input.int(0, "Offset", group=SESSION_GROUP)
sessionMode = input.string(STANDARD_DEVIATION, "Bands Calculation Mode", options=[STANDARD_DEVIATION, PERCENTAGE], group=SESSION_GROUP)
sessionShow1 = input.bool(true, "Band #1", group=SESSION_GROUP, inline="S1")
sessionMult1 = input.float(1.0, "Multiplier", minval=0.0, step=0.5, group=SESSION_GROUP, inline="S1")
sessionShow2 = input.bool(false, "Band #2", group=SESSION_GROUP, inline="S2")
sessionMult2 = input.float(2.0, "Multiplier", minval=0.0, step=0.5, group=SESSION_GROUP, inline="S2")
sessionShow3 = input.bool(false, "Band #3", group=SESSION_GROUP, inline="S3")
sessionMult3 = input.float(3.0, "Multiplier", minval=0.0, step=0.5, group=SESSION_GROUP, inline="S3")
sessionTf = input.timeframe("", "Calculation Timeframe", group=SESSION_GROUP)
sessionWait = input.bool(true, "Wait for Timeframe Closes", group=SESSION_GROUP)

// --- Weekly inputs ---
weeklyEnabled = input.bool(true, "Enable Weekly VWAP", group=WEEKLY_GROUP)
weeklyHideDwm = input.bool(false, "Hide VWAP on 1D or Above", group=WEEKLY_GROUP)
weeklySource = input.source(hlc3, "Source", group=WEEKLY_GROUP)
weeklyOffset = input.int(0, "Offset", group=WEEKLY_GROUP)
weeklyMode = input.string(STANDARD_DEVIATION, "Bands Calculation Mode", options=[STANDARD_DEVIATION, PERCENTAGE], group=WEEKLY_GROUP)
weeklyShow1 = input.bool(true, "Band #1", group=WEEKLY_GROUP, inline="W1")
weeklyMult1 = input.float(1.0, "Multiplier", minval=0.0, step=0.5, group=WEEKLY_GROUP, inline="W1")
weeklyShow2 = input.bool(false, "Band #2", group=WEEKLY_GROUP, inline="W2")
weeklyMult2 = input.float(2.0, "Multiplier", minval=0.0, step=0.5, group=WEEKLY_GROUP, inline="W2")
weeklyShow3 = input.bool(false, "Band #3", group=WEEKLY_GROUP, inline="W3")
weeklyMult3 = input.float(3.0, "Multiplier", minval=0.0, step=0.5, group=WEEKLY_GROUP, inline="W3")
weeklyTf = input.timeframe("", "Calculation Timeframe", group=WEEKLY_GROUP)
weeklyWait = input.bool(true, "Wait for Timeframe Closes", group=WEEKLY_GROUP)

// --- Monthly inputs ---
monthlyEnabled = input.bool(true, "Enable Monthly VWAP", group=MONTHLY_GROUP)
monthlyHideDwm = input.bool(false, "Hide VWAP on 1D or Above", group=MONTHLY_GROUP)
monthlySource = input.source(hlc3, "Source", group=MONTHLY_GROUP)
monthlyOffset = input.int(0, "Offset", group=MONTHLY_GROUP)
monthlyMode = input.string(STANDARD_DEVIATION, "Bands Calculation Mode", options=[STANDARD_DEVIATION, PERCENTAGE], group=MONTHLY_GROUP)
monthlyShow1 = input.bool(true, "Band #1", group=MONTHLY_GROUP, inline="M1")
monthlyMult1 = input.float(1.0, "Multiplier", minval=0.0, step=0.5, group=MONTHLY_GROUP, inline="M1")
monthlyShow2 = input.bool(false, "Band #2", group=MONTHLY_GROUP, inline="M2")
monthlyMult2 = input.float(2.0, "Multiplier", minval=0.0, step=0.5, group=MONTHLY_GROUP, inline="M2")
monthlyShow3 = input.bool(false, "Band #3", group=MONTHLY_GROUP, inline="M3")
monthlyMult3 = input.float(3.0, "Multiplier", minval=0.0, step=0.5, group=MONTHLY_GROUP, inline="M3")
monthlyTf = input.timeframe("", "Calculation Timeframe", group=MONTHLY_GROUP)
monthlyWait = input.bool(true, "Wait for Timeframe Closes", group=MONTHLY_GROUP)

// --- Style inputs ---
sessionColor = input.color(#2962FF, "Session VWAP", group=STYLE_GROUP)
sessionBandColor = input.color(#089981, "Session Bands", group=STYLE_GROUP)
sessionShowFill = input.bool(true, "Session Fill", group=STYLE_GROUP)
sessionFillTransparency = input.int(95, "Session Fill Transparency", minval=0, maxval=100, group=STYLE_GROUP)

weeklyColor = input.color(#7E57C2, "Weekly VWAP", group=STYLE_GROUP)
weeklyBandColor = input.color(#F59E0B, "Weekly Bands", group=STYLE_GROUP)
weeklyShowFill = input.bool(true, "Weekly Fill", group=STYLE_GROUP)
weeklyFillTransparency = input.int(95, "Weekly Fill Transparency", minval=0, maxval=100, group=STYLE_GROUP)

monthlyColor = input.color(#EF5350, "Monthly VWAP", group=STYLE_GROUP)
monthlyBandColor = input.color(#14B8A6, "Monthly Bands", group=STYLE_GROUP)
monthlyShowFill = input.bool(true, "Monthly Fill", group=STYLE_GROUP)
monthlyFillTransparency = input.int(95, "Monthly Fill Transparency", minval=0, maxval=100, group=STYLE_GROUP)

// --- VWAP functions ---
f_vwap(string anchor, series float source, bool hideDwm) =>
    bool newPeriod = switch anchor
        "Session" => timeframe.change("D")
        "Week" => timeframe.change("W")
        "Month" => timeframe.change("M")
        => false
    [vwapValue, upperValue, lowerValue] = ta.vwap(source, newPeriod, 1.0)
    bool hidden = hideDwm and timeframe.isdwm
    [hidden ? na : vwapValue, hidden ? na : upperValue, hidden ? na : lowerValue]

f_getVwap(string calculationTf, string anchor, series float source, bool hideDwm, bool waitClose) =>
    string requestTf = calculationTf == "" ? timeframe.period : calculationTf
    float chartSeconds = timeframe.in_seconds()
    float requestSeconds = timeframe.in_seconds(requestTf)
    bool higherTf = requestSeconds > chartSeconds
    [liveVwap, liveUpper, liveLower] = request.security(syminfo.tickerid, requestTf, f_vwap(anchor, source, hideDwm), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    [confirmedVwap, confirmedUpper, confirmedLower] = request.security(syminfo.tickerid, requestTf, f_vwap(anchor, source, hideDwm), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
    if waitClose and higherTf
        [confirmedVwap[1], confirmedUpper[1], confirmedLower[1]]
    else
        [liveVwap, liveUpper, liveLower]

f_bands(float vwapValue, float upperValue, string mode, float multiplier) =>
    float standardDeviation = upperValue - vwapValue
    float bandBasis = mode == STANDARD_DEVIATION ? standardDeviation : vwapValue * 0.01
    [vwapValue + bandBasis * multiplier, vwapValue - bandBasis * multiplier]

// --- Calculations ---
[sessionVwap, sessionUpper, sessionLower] = f_getVwap(sessionTf, "Session", sessionSource, sessionHideDwm, sessionWait)
[sessionUpper1, sessionLower1] = f_bands(sessionVwap, sessionUpper, sessionMode, sessionMult1)
[sessionUpper2, sessionLower2] = f_bands(sessionVwap, sessionUpper, sessionMode, sessionMult2)
[sessionUpper3, sessionLower3] = f_bands(sessionVwap, sessionUpper, sessionMode, sessionMult3)

[weeklyVwap, weeklyUpper, weeklyLower] = f_getVwap(weeklyTf, "Week", weeklySource, weeklyHideDwm, weeklyWait)
[weeklyUpper1, weeklyLower1] = f_bands(weeklyVwap, weeklyUpper, weeklyMode, weeklyMult1)
[weeklyUpper2, weeklyLower2] = f_bands(weeklyVwap, weeklyUpper, weeklyMode, weeklyMult2)
[weeklyUpper3, weeklyLower3] = f_bands(weeklyVwap, weeklyUpper, weeklyMode, weeklyMult3)

[monthlyVwap, monthlyUpper, monthlyLower] = f_getVwap(monthlyTf, "Month", monthlySource, monthlyHideDwm, monthlyWait)
[monthlyUpper1, monthlyLower1] = f_bands(monthlyVwap, monthlyUpper, monthlyMode, monthlyMult1)
[monthlyUpper2, monthlyLower2] = f_bands(monthlyVwap, monthlyUpper, monthlyMode, monthlyMult2)
[monthlyUpper3, monthlyLower3] = f_bands(monthlyVwap, monthlyUpper, monthlyMode, monthlyMult3)

// --- Session plots ---
pSession = plot(sessionEnabled ? sessionVwap : na, "Session VWAP", sessionColor, 2, offset=sessionOffset)
pSessionU1 = plot(sessionEnabled and sessionShow1 ? sessionUpper1 : na, "Session Upper Band 1", sessionBandColor, offset=sessionOffset)
pSessionL1 = plot(sessionEnabled and sessionShow1 ? sessionLower1 : na, "Session Lower Band 1", sessionBandColor, offset=sessionOffset)
pSessionU2 = plot(sessionEnabled and sessionShow2 ? sessionUpper2 : na, "Session Upper Band 2", sessionBandColor, offset=sessionOffset)
pSessionL2 = plot(sessionEnabled and sessionShow2 ? sessionLower2 : na, "Session Lower Band 2", sessionBandColor, offset=sessionOffset)
pSessionU3 = plot(sessionEnabled and sessionShow3 ? sessionUpper3 : na, "Session Upper Band 3", sessionBandColor, offset=sessionOffset)
pSessionL3 = plot(sessionEnabled and sessionShow3 ? sessionLower3 : na, "Session Lower Band 3", sessionBandColor, offset=sessionOffset)
fill(
     pSessionU1,
     pSessionL1,
     sessionShowFill ? color.new(sessionBandColor, sessionFillTransparency) : na,
     title="Session Band 1 Fill")

fill(
     pSessionU2,
     pSessionL2,
     sessionShowFill ? color.new(sessionBandColor, sessionFillTransparency) : na,
     title="Session Band 2 Fill")

fill(
     pSessionU3,
     pSessionL3,
     sessionShowFill ? color.new(sessionBandColor, sessionFillTransparency) : na,
     title="Session Band 3 Fill")

// --- Weekly plots ---
pWeekly = plot(weeklyEnabled ? weeklyVwap : na, "Weekly VWAP", weeklyColor, 2, offset=weeklyOffset)
pWeeklyU1 = plot(weeklyEnabled and weeklyShow1 ? weeklyUpper1 : na, "Weekly Upper Band 1", weeklyBandColor, offset=weeklyOffset)
pWeeklyL1 = plot(weeklyEnabled and weeklyShow1 ? weeklyLower1 : na, "Weekly Lower Band 1", weeklyBandColor, offset=weeklyOffset)
pWeeklyU2 = plot(weeklyEnabled and weeklyShow2 ? weeklyUpper2 : na, "Weekly Upper Band 2", weeklyBandColor, offset=weeklyOffset)
pWeeklyL2 = plot(weeklyEnabled and weeklyShow2 ? weeklyLower2 : na, "Weekly Lower Band 2", weeklyBandColor, offset=weeklyOffset)
pWeeklyU3 = plot(weeklyEnabled and weeklyShow3 ? weeklyUpper3 : na, "Weekly Upper Band 3", weeklyBandColor, offset=weeklyOffset)
pWeeklyL3 = plot(weeklyEnabled and weeklyShow3 ? weeklyLower3 : na, "Weekly Lower Band 3", weeklyBandColor, offset=weeklyOffset)
fill(
     pWeeklyU1,
     pWeeklyL1,
     weeklyShowFill ? color.new(weeklyBandColor, weeklyFillTransparency) : na,
     title="Weekly Band 1 Fill")

fill(
     pWeeklyU2,
     pWeeklyL2,
     weeklyShowFill ? color.new(weeklyBandColor, weeklyFillTransparency) : na,
     title="Weekly Band 2 Fill")

fill(
     pWeeklyU3,
     pWeeklyL3,
     weeklyShowFill ? color.new(weeklyBandColor, weeklyFillTransparency) : na,
     title="Weekly Band 3 Fill")

// --- Monthly plots ---
pMonthly = plot(monthlyEnabled ? monthlyVwap : na, "Monthly VWAP", monthlyColor, 2, offset=monthlyOffset)
pMonthlyU1 = plot(monthlyEnabled and monthlyShow1 ? monthlyUpper1 : na, "Monthly Upper Band 1", monthlyBandColor, offset=monthlyOffset)
pMonthlyL1 = plot(monthlyEnabled and monthlyShow1 ? monthlyLower1 : na, "Monthly Lower Band 1", monthlyBandColor, offset=monthlyOffset)
pMonthlyU2 = plot(monthlyEnabled and monthlyShow2 ? monthlyUpper2 : na, "Monthly Upper Band 2", monthlyBandColor, offset=monthlyOffset)
pMonthlyL2 = plot(monthlyEnabled and monthlyShow2 ? monthlyLower2 : na, "Monthly Lower Band 2", monthlyBandColor, offset=monthlyOffset)
pMonthlyU3 = plot(monthlyEnabled and monthlyShow3 ? monthlyUpper3 : na, "Monthly Upper Band 3", monthlyBandColor, offset=monthlyOffset)
pMonthlyL3 = plot(monthlyEnabled and monthlyShow3 ? monthlyLower3 : na, "Monthly Lower Band 3", monthlyBandColor, offset=monthlyOffset)
fill(
     pMonthlyU1,
     pMonthlyL1,
     monthlyShowFill ? color.new(monthlyBandColor, monthlyFillTransparency) : na,
     title="Monthly Band 1 Fill")

fill(
     pMonthlyU2,
     pMonthlyL2,
     monthlyShowFill ? color.new(monthlyBandColor, monthlyFillTransparency) : na,
     title="Monthly Band 2 Fill")

fill(
     pMonthlyU3,
     pMonthlyL3,
     monthlyShowFill ? color.new(monthlyBandColor, monthlyFillTransparency) : na,
     title="Monthly Band 3 Fill")
````
