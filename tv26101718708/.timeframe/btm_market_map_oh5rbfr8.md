# BTM Market Map

- url: https://www.tradingview.com/script/Oh5rBfr8-BTM-Market-Map/
- type: indicator
- pine_id: PUB;83b764659ca44160a2696f8d3a622311
- version: 1.0

## Description

BTM Market Map

BTM Market Map is a market-context indicator for intraday XAUUSD (gold), designed for 5-minute and 15-minute charts during the London and New York sessions. It does not generate buy or sell signals. It maps market structure, liquidity and session context on the chart and summarises the current state in a dashboard, so the market can be read at a glance.

WHAT IT SHOWS

Market structure
• Swing highs and lows are found with pivots (5 bars left / 5 bars right by default) and labelled HH, HL, LH or LL.
• BULL / BEAR CHOCH marks the first close through the last opposing swing (change of character).
• BULL / BEAR BOS marks the close beyond the prior extreme that confirms the new direction (break of structure).

Pullback zones
• After a BOS, or after a new higher low / lower high in an established trend, a zone is drawn around that swing point, sized by ATR (0.5 x ATR(14) each side by default).
• Zones are named on the chart (BULL ZONE / BEAR ZONE, or DEMAND ZONE / SUPPLY ZONE) with the setup type (BOS or CONT), and expire after a set number of bars.

Liquidity levels and sweeps
• Previous day high/low, Asian session high/low (23:00-07:00 UK), previous week high/low, and equal highs/lows.
• A sweep is labelled when price wicks through a level and closes back inside it: previous day high/low, Asian high/low, equal highs/lows, and the London high/low during the New York window.

Session context
• London session and New York window shading.
• Session VWAP anchored at the London open, with ±1 standard deviation bands.
• US news windows in New York time (follows US daylight saving): first-Friday NFP proxy plus your own release and FOMC dates.

DASHBOARD
• Higher-timeframe trend (1H EMA 20/50 by default) and its strength (EMA gap measured in ATR).
• Choppiness Index: trending or choppy.
• Current structure: bullish, bearish or neutral.
• Active bull and bear zones, with price range and whether they have been touched.
• Levels swept today.
• Price above or below the session VWAP.
• ATR(14) and its percentile against recent London sessions.
• Current session and news-window status.
Position (9 options), text size, column width, colours and border thickness are all adjustable.

ALERTS
Price entered bull/bear zone, break of structure, change of character, previous-day high/low sweep, Asian high/low sweep, equal high/low sweep, London high/low sweep in the New York window, and news window starting. Set alerts to "Once Per Bar Close".

NOTES
• Higher-timeframe values (trend EMAs, ATR, Choppiness, previous day and week levels) use the last completed bar, so they do not repaint.
• Swing labels need the right-side pivot bars to confirm, so they appear 5 bars after the swing and are drawn back at the swing bar.
• On spot gold, VWAP is weighted by your broker's tick volume.
• News dates are entered manually; the first-Friday NFP rule is an approximation.
• Every layer can be switched on or off in the settings.

This indicator is a charting and analysis tool. It does not give trading advice or signals, and past structure does not predict future price.

## Source Code

````pine
//@version=6
// BTM Market Map: market-context dashboard for XAUUSD, built on the V20 structure
// engine. No orders and no buy/sell signals.
//
// Shows market structure (HH/HL/LH/LL, CHOCH, BOS), pullback zones, liquidity
// levels, sweeps, session VWAP and news windows, plus a status dashboard and
// alerts. Each layer can be switched off under Display.
indicator("BTM Market Map",
     shorttitle="BTM",
     overlay=true,
     max_bars_back=500,
     max_labels_count=500,
     max_lines_count=500,
     max_boxes_count=50)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
gStr = "Structure & Zones"

leftBars  = input.int(5, "Pivot Left", minval=1, group=gStr)
rightBars = input.int(5, "Pivot Right", minval=1, group=gStr)
zoneATRLen  = input.int(14, "Pullback Zone ATR Length", group=gStr)
zoneATRMult = input.float(0.5, "Pullback Zone ATR Size", step=0.1, group=gStr)
maxBarsAfterSetup = input.int(80, "Zone Expires After (bars)", minval=1, group=gStr)
recentStructureBars = input.int(60, "Fresh HH/LL Lookback", minval=1, group=gStr)

gCtx = "Context"

tradeSession = input.session("0700-1200", "London Session (UK time)", group=gCtx)
nySession = input.session("0845-1100", "New York Window (New York time)", group=gCtx)
htfTF = input.timeframe("60", "Trend Timeframe", group=gCtx)
htfFastLen = input.int(20, "Trend Fast EMA", group=gCtx)
htfSlowLen = input.int(50, "Trend Slow EMA", group=gCtx)
strongTrendMult = input.float(0.25, "Strong Trend: EMA Gap x Trend ATR", step=0.05, group=gCtx)
chopLen = input.int(14, "Choppiness Length (trend timeframe)", minval=2, group=gCtx)
chopMax = input.float(61.8, "Choppiness: trending below", step=0.1, group=gCtx)
eqPivotLen = input.int(3, "Equal H/L Pivot Length", minval=1, group=gCtx)
eqTolATR = input.float(0.1, "Equal H/L Tolerance (x ATR 200)", step=0.05, group=gCtx)
volLookback = input.int(20, "ATR Percentile: Sessions to Compare", minval=5, group=gCtx)

gNews = "US News Windows (New York time)"

autoNFP = input.bool(true, "Treat first Friday of the month as NFP", group=gNews,
     tooltip="Proxy only. NFP is occasionally released on the second Friday; add those dates to the list below.")
releaseDates = input.text_area("", "08:30 ET release dates (YYYY-MM-DD, comma separated)", group=gNews,
     tooltip="CPI, PCE, retail sales, GDP, off-schedule NFP, etc. Dates are New York dates.")
releaseWindow = input.session("0800-0845", "08:30 ET window", group=gNews)
fomcDates = input.text_area("", "FOMC decision dates (YYYY-MM-DD, comma separated)", group=gNews)
fomcWindow = input.session("1330-1430", "FOMC window", group=gNews)

gDash = "Dashboard"

showDashboard = input.bool(true, "Show dashboard", group=gDash)
dashPos = input.string("Top right", "Position", group=gDash,
     options=["Top left", "Top center", "Top right", "Middle left", "Middle center", "Middle right", "Bottom left", "Bottom center", "Bottom right"])
dashSize = input.string("Small", "Text size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=gDash)
dashWidth = input.float(0, "Column width (% of chart, 0 = auto)", minval=0, maxval=50, step=1, group=gDash)
dashBg = input.color(#1565C0, "Background", group=gDash)
dashHeaderBg = input.color(#0A2E6E, "Header background", group=gDash)
dashLabelBg = input.color(#1565C0, "Label column background", group=gDash)
dashText = input.color(color.white, "Text and border", group=gDash)
dashBorder = input.int(2, "Border thickness", minval=0, maxval=5, group=gDash)

gDisp = "Display"

showStructure = input.bool(true, "Structure labels (HH/HL/LH/LL, CHOCH, BOS)", group=gDisp)
showSweeps = input.bool(true, "Sweep labels", group=gDisp)
showPullbackZone = input.bool(true, "Pullback zones", group=gDisp)
showZoneNames = input.bool(true, "Name zones on chart", group=gDisp)
zoneNaming = input.string("Bull / Bear", "Zone names", options=["Bull / Bear", "Demand / Supply"], group=gDisp)
zoneTextSize = input.string("Small", "Zone name size", options=["Tiny", "Small", "Normal", "Large"], group=gDisp)
zoneTextColor = input.color(color.white, "Zone name colour", group=gDisp)
showDayLevels = input.bool(true, "Previous day and Asian levels", group=gDisp)
showWeekly = input.bool(true, "Previous week high/low", group=gDisp)
showLondonRange = input.bool(false, "London high/low", group=gDisp)
showEqLevels = input.bool(true, "Equal highs/lows", group=gDisp)
showVWAP = input.bool(true, "Session VWAP", group=gDisp)
showSessions = input.bool(true, "Shade London and New York", group=gDisp)
showNews = input.bool(true, "Shade news windows", group=gDisp)

//━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━
f_chop(n) =>
    rng = ta.highest(high, n) - ta.lowest(low, n)
    trSum = math.sum(ta.tr(true), n)
    rng > 0 ? 100 * math.log10(trSum / rng) / math.log10(n) : 100.0

f_pad2(v) =>
    v < 10 ? "0" + str.tostring(v) : str.tostring(v)

f_size(s) =>
    s == "Auto" ? size.auto : s == "Tiny" ? size.tiny : s == "Normal" ? size.normal : s == "Large" ? size.large : s == "Huge" ? size.huge : size.small

bullName = zoneNaming == "Bull / Bear" ? "BULL ZONE" : "DEMAND ZONE"
bearName = zoneNaming == "Bull / Bear" ? "BEAR ZONE" : "SUPPLY ZONE"
zoneTxtSize = f_size(zoneTextSize)

//━━━━━━━━━━━━━━━━━━━
// TREND TIMEFRAME (last completed bar, no repaint)
//━━━━━━━━━━━━━━━━━━━
[htfFast, htfSlow, htfATR, htfChop] = request.security(syminfo.tickerid, htfTF,
     [ta.ema(close, htfFastLen)[1], ta.ema(close, htfSlowLen)[1], ta.atr(14)[1], f_chop(chopLen)[1]],
     lookahead=barmerge.lookahead_on)

htfBull = htfFast > htfSlow
htfBear = htfFast < htfSlow
trendGapATR = htfATR > 0 ? math.abs(htfFast - htfSlow) / htfATR : na
strongTrend = not na(trendGapATR) and trendGapATR > strongTrendMult
chopOK = not na(htfChop) and htfChop < chopMax

//━━━━━━━━━━━━━━━━━━━
// SESSIONS
//━━━━━━━━━━━━━━━━━━━
londonSession = not na(time(timeframe.period, tradeSession, "Europe/London"))
nyWindow = not na(time(timeframe.period, nySession, "America/New_York"))

lonStart = londonSession and not londonSession[1]
lonEnd = londonSession[1] and not londonSession

bgcolor(showSessions and londonSession ? color.new(color.yellow, 92) : na, title="London Session")
bgcolor(showSessions and nyWindow ? color.new(color.blue, 92) : na, title="New York Window")

var float lonHigh = na
var float lonLow = na

if lonStart
    lonHigh := high
    lonLow := low
else if londonSession
    lonHigh := math.max(lonHigh, high)
    lonLow := math.min(lonLow, low)

plot(showLondonRange ? lonHigh : na, "London High", color=color.new(color.yellow, 30), style=plot.style_linebr)
plot(showLondonRange ? lonLow : na, "London Low", color=color.new(color.yellow, 30), style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━
// NEWS WINDOWS (New York time, follows US daylight saving)
//━━━━━━━━━━━━━━━━━━━
nyDateKey = str.tostring(year(time, "America/New_York")) + "-" +
     f_pad2(month(time, "America/New_York")) + "-" +
     f_pad2(dayofmonth(time, "America/New_York"))

isFirstFriday = dayofweek(time, "America/New_York") == dayofweek.friday and dayofmonth(time, "America/New_York") <= 7

releaseDay = (autoNFP and isFirstFriday) or str.contains(releaseDates, nyDateKey)
fomcDay = str.contains(fomcDates, nyDateKey)

inReleaseWindow = not na(time(timeframe.period, releaseWindow, "America/New_York"))
inFomcWindow = not na(time(timeframe.period, fomcWindow, "America/New_York"))

newsWindow = (releaseDay and inReleaseWindow) or (fomcDay and inFomcWindow)
newsWindowStart = newsWindow and not newsWindow[1]

bgcolor(showNews and newsWindow ? color.new(color.purple, 85) : na, title="News Window")

//━━━━━━━━━━━━━━━━━━━
// PREVIOUS DAY / WEEK HIGH / LOW
//━━━━━━━━━━━━━━━━━━━
[prevDayHigh, prevDayLow] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead=barmerge.lookahead_on)
[prevWeekHigh, prevWeekLow] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead=barmerge.lookahead_on)

plot(showDayLevels ? prevDayHigh : na, "Previous Day High", color=color.orange, linewidth=2)
plot(showDayLevels ? prevDayLow : na, "Previous Day Low", color=color.aqua, linewidth=2)
plot(showWeekly ? prevWeekHigh : na, "Previous Week High", color=color.new(color.orange, 40), linewidth=1, style=plot.style_stepline)
plot(showWeekly ? prevWeekLow : na, "Previous Week Low", color=color.new(color.aqua, 40), linewidth=1, style=plot.style_stepline)

//━━━━━━━━━━━━━━━━━━━
// ASIAN HIGH / LOW
//━━━━━━━━━━━━━━━━━━━
asianSession = not na(time(timeframe.period, "2300-0700", "Europe/London"))

var float asianHigh = na
var float asianLow  = na

asianStart = asianSession and not asianSession[1]

if asianStart
    asianHigh := high
    asianLow := low

if asianSession
    asianHigh := math.max(asianHigh, high)
    asianLow := math.min(asianLow, low)

plot(showDayLevels ? asianHigh : na, "Asian High", color=color.red, linewidth=2)
plot(showDayLevels ? asianLow : na, "Asian Low", color=color.lime, linewidth=2)

//━━━━━━━━━━━━━━━━━━━
// EQUAL HIGHS / LOWS
//━━━━━━━━━━━━━━━━━━━
atr200 = ta.atr(200)
eqPL = ta.pivotlow(low, eqPivotLen, eqPivotLen)
eqPH = ta.pivothigh(high, eqPivotLen, eqPivotLen)

var float lastEqPL = na
var float lastEqPH = na
var float eqlLevel = na
var float eqhLevel = na

if not na(eqPL)
    if not na(lastEqPL) and math.abs(eqPL - lastEqPL) <= eqTolATR * atr200
        eqlLevel := math.min(eqPL, lastEqPL)
    lastEqPL := eqPL

if not na(eqPH)
    if not na(lastEqPH) and math.abs(eqPH - lastEqPH) <= eqTolATR * atr200
        eqhLevel := math.max(eqPH, lastEqPH)
    lastEqPH := eqPH

plot(showEqLevels ? eqlLevel : na, "Equal Lows", color=color.new(color.lime, 30), style=plot.style_linebr)
plot(showEqLevels ? eqhLevel : na, "Equal Highs", color=color.new(color.red, 30), style=plot.style_linebr)

//━━━━━━━━━━━━━━━━━━━
// LIQUIDITY SWEEPS
//━━━━━━━━━━━━━━━━━━━
newDay = ta.change(time("D")) != 0

var bool pdhSwept = false
var bool pdlSwept = false
var bool asiaHighSwept = false
var bool asiaLowSwept = false
var bool eqhSwept = false
var bool eqlSwept = false
var bool lonHighSwept = false
var bool lonLowSwept = false

if newDay
    pdhSwept := false
    pdlSwept := false
    asiaHighSwept := false
    asiaLowSwept := false
    eqhSwept := false
    eqlSwept := false
    lonHighSwept := false
    lonLowSwept := false

pdhSweep = not pdhSwept and high > prevDayHigh and close < prevDayHigh
pdlSweep = not pdlSwept and low < prevDayLow and close > prevDayLow

asianHighSweep = londonSession and not asiaHighSwept and high > asianHigh and close < asianHigh
asianLowSweep  = londonSession and not asiaLowSwept and low < asianLow and close > asianLow

lonHighSweep = nyWindow and not lonHighSwept and high > lonHigh and close < lonHigh
lonLowSweep  = nyWindow and not lonLowSwept and low < lonLow and close > lonLow

eqhSweep = not na(eqhLevel) and high > eqhLevel and close < eqhLevel
eqlSweep = not na(eqlLevel) and low < eqlLevel and close > eqlLevel

if pdhSweep
    pdhSwept := true
    if showSweeps
        label.new(bar_index, high, "PDH SWEEP", style=label.style_label_down, color=color.orange, textcolor=color.white)

if pdlSweep
    pdlSwept := true
    if showSweeps
        label.new(bar_index, low, "PDL SWEEP", style=label.style_label_up, color=color.aqua, textcolor=color.black)

if asianHighSweep
    asiaHighSwept := true
    if showSweeps
        label.new(bar_index, high, "ASIAN HIGH\nSWEEP", style=label.style_label_down, color=color.red, textcolor=color.white)

if asianLowSweep
    asiaLowSwept := true
    if showSweeps
        label.new(bar_index, low, "ASIAN LOW\nSWEEP", style=label.style_label_up, color=color.lime, textcolor=color.black)

if lonHighSweep
    lonHighSwept := true
    if showSweeps
        label.new(bar_index, high, "LONDON HIGH\nSWEEP", style=label.style_label_down, color=color.yellow, textcolor=color.black)

if lonLowSweep
    lonLowSwept := true
    if showSweeps
        label.new(bar_index, low, "LONDON LOW\nSWEEP", style=label.style_label_up, color=color.yellow, textcolor=color.black)

// An equal high/low is used once: swept (wick through, close back) or broken (close through).
if eqhSweep
    eqhSwept := true
    eqhLevel := na
    if showSweeps
        label.new(bar_index, high, "EQH SWEEP", style=label.style_label_down, color=color.red, textcolor=color.white)
else if not na(eqhLevel) and close > eqhLevel
    eqhLevel := na

if eqlSweep
    eqlSwept := true
    eqlLevel := na
    if showSweeps
        label.new(bar_index, low, "EQL SWEEP", style=label.style_label_up, color=color.lime, textcolor=color.black)
else if not na(eqlLevel) and close < eqlLevel
    eqlLevel := na

//━━━━━━━━━━━━━━━━━━━
// STRUCTURE ENGINE
//━━━━━━━━━━━━━━━━━━━
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

var float lastHigh = na
var float prevHigh = na
var float lastLow = na
var float prevLow = na

var float HH = na
var float HL = na
var float LH = na
var float LL = na

var int lastHHBar = na
var int lastLLBar = na

bool newHLPivot = false
bool newLHPivot = false

var int structureState = 0
var bool bullCHOCHPrinted = false
var bool bearCHOCHPrinted = false

if not na(ph)
    prevHigh := lastHigh
    lastHigh := ph

    if not na(prevHigh)
        if ph > prevHigh
            HH := ph
            lastHHBar := bar_index - rightBars

            if showStructure
                label.new(bar_index - rightBars, ph, "HH", style=label.style_label_down, color=color.green, textcolor=color.white)
        else
            LH := ph
            newLHPivot := true

            if showStructure
                label.new(bar_index - rightBars, ph, "LH", style=label.style_label_down, color=color.red, textcolor=color.white)

if not na(pl)
    prevLow := lastLow
    lastLow := pl

    if not na(prevLow)
        if pl > prevLow
            HL := pl
            newHLPivot := true

            if showStructure
                label.new(bar_index - rightBars, pl, "HL", style=label.style_label_up, color=color.green, textcolor=color.white)
        else
            LL := pl
            lastLLBar := bar_index - rightBars

            if showStructure
                label.new(bar_index - rightBars, pl, "LL", style=label.style_label_up, color=color.red, textcolor=color.white)

if structureState == 0
    if not na(HH) and not na(HL)
        structureState := 1

    if not na(LL) and not na(LH)
        structureState := 2

bullCHOCH = structureState == 2 and not na(LH) and close > LH and not bullCHOCHPrinted
bearCHOCH = structureState == 1 and not na(HL) and close < HL and not bearCHOCHPrinted

if bullCHOCH
    structureState := 3
    bullCHOCHPrinted := true
    bearCHOCHPrinted := false

    if showStructure
        label.new(bar_index, high, "BULL CHOCH", style=label.style_label_down, color=color.green, textcolor=color.white)

if bearCHOCH
    structureState := 4
    bearCHOCHPrinted := true
    bullCHOCHPrinted := false

    if showStructure
        label.new(bar_index, low, "BEAR CHOCH", style=label.style_label_up, color=color.red, textcolor=color.white)


bullBOS = structureState == 3 and not na(HH) and close > HH
bearBOS = structureState == 4 and not na(LL) and close < LL

if bullBOS
    structureState := 1
    bullCHOCHPrinted := false

    if showStructure
        label.new(bar_index, high, "BULL BOS", style=label.style_label_down, color=color.lime, textcolor=color.black)

if bearBOS
    structureState := 2
    bearCHOCHPrinted := false

    if showStructure
        label.new(bar_index, low, "BEAR BOS", style=label.style_label_up, color=color.maroon, textcolor=color.white)

//━━━━━━━━━━━━━━━━━━━
// FLOW
//━━━━━━━━━━━━━━━━━━━
var bool bullishFlow = false
var bool bearishFlow = false

if bullBOS
    bullishFlow := true
    bearishFlow := false

if bearBOS
    bearishFlow := true
    bullishFlow := false

if bullCHOCH
    bearishFlow := false

if bearCHOCH
    bullishFlow := false

freshHH = not na(lastHHBar) and bar_index - lastHHBar <= recentStructureBars
freshLL = not na(lastLLBar) and bar_index - lastLLBar <= recentStructureBars

//━━━━━━━━━━━━━━━━━━━
// PULLBACK ZONES
//━━━━━━━━━━━━━━━━━━━
zoneATR = ta.atr(zoneATRLen)
zoneSize = zoneATR * zoneATRMult

var float bullZoneTop = na
var float bullZoneBottom = na
var float bearZoneTop = na
var float bearZoneBottom = na

var int lastBullSetupBar = na
var int lastBearSetupBar = na

var string bullSetupType = "NONE"
var string bearSetupType = "NONE"

var box bullZoneBox = na
var box bearZoneBox = na

// First touch of each zone, for the alert
var bool bullTouched = false
var bool bearTouched = false

if bullBOS and not na(HL)
    bullZoneTop := HL + zoneSize
    bullZoneBottom := HL - zoneSize
    lastBullSetupBar := bar_index
    bullSetupType := "BOS"
    bullTouched := false

    box.delete(bullZoneBox)

    if showPullbackZone
        bullZoneBox := box.new(bar_index, bullZoneTop, bar_index + 50, bullZoneBottom, bgcolor=color.new(color.lime, 88), border_color=color.lime,
             text=showZoneNames ? bullName + " · BOS" : "", text_color=zoneTextColor, text_size=zoneTxtSize, text_halign=text.align_right, text_valign=text.align_center)

if bearBOS and not na(LH)
    bearZoneTop := LH + zoneSize
    bearZoneBottom := LH - zoneSize
    lastBearSetupBar := bar_index
    bearSetupType := "BOS"
    bearTouched := false

    box.delete(bearZoneBox)

    if showPullbackZone
        bearZoneBox := box.new(bar_index, bearZoneTop, bar_index + 50, bearZoneBottom, bgcolor=color.new(color.red, 88), border_color=color.red,
             text=showZoneNames ? bearName + " · BOS" : "", text_color=zoneTextColor, text_size=zoneTxtSize, text_halign=text.align_right, text_valign=text.align_center)

if bullishFlow and newHLPivot and freshHH and not na(HL)
    bullZoneTop := HL + zoneSize
    bullZoneBottom := HL - zoneSize
    lastBullSetupBar := bar_index
    bullSetupType := "CONT"
    bullTouched := false

    box.delete(bullZoneBox)

    if showPullbackZone
        bullZoneBox := box.new(bar_index, bullZoneTop, bar_index + 50, bullZoneBottom, bgcolor=color.new(color.green, 88), border_color=color.green,
             text=showZoneNames ? bullName + " · CONT" : "", text_color=zoneTextColor, text_size=zoneTxtSize, text_halign=text.align_right, text_valign=text.align_center)

if bearishFlow and newLHPivot and freshLL and not na(LH)
    bearZoneTop := LH + zoneSize
    bearZoneBottom := LH - zoneSize
    lastBearSetupBar := bar_index
    bearSetupType := "CONT"
    bearTouched := false

    box.delete(bearZoneBox)

    if showPullbackZone
        bearZoneBox := box.new(bar_index, bearZoneTop, bar_index + 50, bearZoneBottom, bgcolor=color.new(color.red, 88), border_color=color.red,
             text=showZoneNames ? bearName + " · CONT" : "", text_color=zoneTextColor, text_size=zoneTxtSize, text_halign=text.align_right, text_valign=text.align_center)

if not na(bullZoneBox)
    box.set_right(bullZoneBox, bar_index + 50)

if not na(bearZoneBox)
    box.set_right(bearZoneBox, bar_index + 50)

// Expire old zones
barsSinceBullSetup = not na(lastBullSetupBar) ? bar_index - lastBullSetupBar : na
barsSinceBearSetup = not na(lastBearSetupBar) ? bar_index - lastBearSetupBar : na

if not na(barsSinceBullSetup) and barsSinceBullSetup > maxBarsAfterSetup
    bullZoneTop := na
    bullZoneBottom := na
    bullSetupType := "NONE"
    box.delete(bullZoneBox)

if not na(barsSinceBearSetup) and barsSinceBearSetup > maxBarsAfterSetup
    bearZoneTop := na
    bearZoneBottom := na
    bearSetupType := "NONE"
    box.delete(bearZoneBox)

priceInBullZone = not na(bullZoneTop) and low <= bullZoneTop and high >= bullZoneBottom
priceInBearZone = not na(bearZoneTop) and high >= bearZoneBottom and low <= bearZoneTop

bullTouch = priceInBullZone and not bullTouched
bearTouch = priceInBearZone and not bearTouched

if bullTouch
    bullTouched := true

if bearTouch
    bearTouched := true

//━━━━━━━━━━━━━━━━━━━
// SESSION VWAP (anchored at the London open)
//━━━━━━━━━━━━━━━━━━━
// Weighted by the feed's volume: broker tick volume on spot XAUUSD.
[sessVWAP, vwapUpper, vwapLower] = ta.vwap(hlc3, lonStart, 1.0)

plot(showVWAP ? sessVWAP : na, "Session VWAP", color=color.fuchsia, linewidth=2)
plot(showVWAP ? vwapUpper : na, "VWAP +1 SD", color=color.new(color.fuchsia, 60))
plot(showVWAP ? vwapLower : na, "VWAP -1 SD", color=color.new(color.fuchsia, 60))

//━━━━━━━━━━━━━━━━━━━
// ATR VS RECENT LONDON SESSIONS
//━━━━━━━━━━━━━━━━━━━
atr14 = ta.atr(14)

var array<float> sessATR = array.new<float>()
var float sessATRSum = 0.0
var int sessATRCount = 0

if lonStart
    sessATRSum := 0.0
    sessATRCount := 0

if londonSession
    sessATRSum += atr14
    sessATRCount += 1

if lonEnd and sessATRCount > 0 and not na(sessATRSum)
    array.push(sessATR, sessATRSum / sessATRCount)
    if array.size(sessATR) > volLookback
        array.shift(sessATR)

//━━━━━━━━━━━━━━━━━━━
// ALERTS (create with "Once Per Bar Close" to avoid intrabar flicker)
//━━━━━━━━━━━━━━━━━━━
alertcondition(bullTouch, "Price entered bull pullback zone", "{{ticker}}: price entered the bull pullback zone")
alertcondition(bearTouch, "Price entered bear pullback zone", "{{ticker}}: price entered the bear pullback zone")
alertcondition(bullBOS or bearBOS, "Break of structure", "{{ticker}}: break of structure")
alertcondition(bullCHOCH or bearCHOCH, "Change of character", "{{ticker}}: change of character")
alertcondition(pdhSweep or pdlSweep, "Previous-day high/low sweep", "{{ticker}}: previous-day high/low swept")
alertcondition(asianHighSweep or asianLowSweep, "Asian high/low sweep", "{{ticker}}: Asian high/low swept")
alertcondition(eqhSweep or eqlSweep, "Equal high/low sweep", "{{ticker}}: equal highs/lows swept")
alertcondition(lonHighSweep or lonLowSweep, "London high/low sweep (NY)", "{{ticker}}: London high/low swept in the New York window")
alertcondition(newsWindowStart, "News window starting", "{{ticker}}: US news window starting")

//━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━
dashPosition = switch dashPos
    "Top left" => position.top_left
    "Top center" => position.top_center
    "Middle left" => position.middle_left
    "Middle center" => position.middle_center
    "Middle right" => position.middle_right
    "Bottom left" => position.bottom_left
    "Bottom center" => position.bottom_center
    "Bottom right" => position.bottom_right
    => position.top_right
dashTextSize = f_size(dashSize)
tfLabel = htfTF == "60" ? "1H" : htfTF == "240" ? "4H" : (htfTF == "D" or htfTF == "1D") ? "1D" : htfTF

var table dash = table.new(dashPosition, 2, 11, bgcolor=dashBg, frame_color=dashText, frame_width=dashBorder, border_color=dashText, border_width=dashBorder)

f_row(r, name, value) =>
    table.cell(dash, 0, r, name, width=dashWidth, text_color=dashText, bgcolor=dashLabelBg, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, r, value, width=dashWidth, text_color=dashText, bgcolor=dashBg, text_halign=text.align_left, text_size=dashTextSize)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "BTM Market Map", width=dashWidth, text_color=dashText, bgcolor=dashHeaderBg, text_halign=text.align_left, text_size=dashTextSize)
    table.cell(dash, 1, 0, syminfo.ticker + " " + timeframe.period, width=dashWidth, text_color=dashText, bgcolor=dashHeaderBg, text_halign=text.align_left, text_size=dashTextSize)
    f_row(1, "Trend (" + tfLabel + ")", htfBull ? "Bull" : htfBear ? "Bear" : "Flat")
    f_row(2, "Trend strength", na(trendGapATR) ? "-" : str.tostring(trendGapATR, "#.##") + " x ATR" + (strongTrend ? " (strong)" : " (weak)"))
    f_row(3, "Choppiness", na(htfChop) ? "-" : str.tostring(htfChop, "#.#") + (chopOK ? " trending" : " choppy"))
    f_row(4, "Structure", bullishFlow ? "Bullish" : bearishFlow ? "Bearish" : "Neutral")
    bullTxt = na(bullZoneTop) ? "-" : str.tostring(bullZoneBottom, format.mintick) + " - " + str.tostring(bullZoneTop, format.mintick) + " " + bullSetupType + (bullTouched ? " (touched)" : "")
    bearTxt = na(bearZoneTop) ? "-" : str.tostring(bearZoneBottom, format.mintick) + " - " + str.tostring(bearZoneTop, format.mintick) + " " + bearSetupType + (bearTouched ? " (touched)" : "")
    f_row(5, zoneNaming == "Bull / Bear" ? "Bull zone" : "Demand zone", bullTxt)
    f_row(6, zoneNaming == "Bull / Bear" ? "Bear zone" : "Supply zone", bearTxt)
    sweepTxt = ""
    sweepTxt += pdhSwept ? "PDH " : ""
    sweepTxt += pdlSwept ? "PDL " : ""
    sweepTxt += asiaHighSwept ? "Asia H " : ""
    sweepTxt += asiaLowSwept ? "Asia L " : ""
    sweepTxt += eqhSwept ? "EQH " : ""
    sweepTxt += eqlSwept ? "EQL " : ""
    sweepTxt += lonHighSwept ? "Lon H " : ""
    sweepTxt += lonLowSwept ? "Lon L " : ""
    f_row(7, "Swept today", sweepTxt == "" ? "none" : sweepTxt)
    f_row(8, "Session VWAP", na(sessVWAP) ? "-" : (close > sessVWAP ? "Above " : "Below ") + str.tostring(sessVWAP, format.mintick))
    float atrPct = na
    if array.size(sessATR) > 0
        cnt = 0
        for j = 0 to array.size(sessATR) - 1
            if array.get(sessATR, j) <= atr14
                cnt += 1
        atrPct := 100.0 * cnt / array.size(sessATR)
    f_row(9, "ATR(14)", str.tostring(atr14, format.mintick) + (na(atrPct) ? "" : " (" + str.tostring(atrPct, "#") + "th pct)"))
    sessTxt = newsWindow ? "NEWS WINDOW" : londonSession ? "London" : nyWindow ? "New York" : "Off-session"
    f_row(10, "Session", sessTxt)
````
