<!-- tradingview-pine-id: PUB;607fa037f9e841d98368720be87a1e69 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# 6/7 Currency Breakout + 4/7 Hold

Source: https://www.tradingview.com/script/qNpQ9GYs-6-7-Currency-Breakout-4-7-Hold/

## Description

This indicator identifies real-time currency strength and weakness by monitoring session breakouts across all seven major pairs connected to each currency.

It tracks AUD, CAD, CHF, EUR, GBP, JPY, NZD and USD and compares price against the previous completed session's high and low.

Signal logic:

A breakout is confirmed when price closes above the previous session high or below the previous session low.
The direction of each pair is converted into strength or weakness for the individual currency.
A currency must have at least 6 of its 7 pairs aligned in the same direction.
At the time of confirmation, at least 4 of the 7 pairs must still be holding outside their respective breakout levels in the same direction.
This holding filter helps reject signals where several pairs already broke out but have since returned inside the previous session range.
A signal is displayed only once per currency per session.

---

## Source Code

````pine
//@version=6
indicator("6/7 Currency Breakout + 4/7 Hold", overlay=true, max_labels_count=500)

//====================================================
// SETTINGS
//====================================================

feed = input.string("FOREXCOM", "Forex Feed")

asiaSession = input.session("0000-0800", "Asia Session")
londonSession = input.session("0800-1300", "London Session")
newYorkSession = input.session("1300-1700", "New York Session")

sessionTimeZone = input.string("America/New_York", "Session Time Zone")

requiredBreakouts = input.int(6, "Required Breakouts", minval=1, maxval=7)
requiredHolding = input.int(4, "Required Pairs Still Holding", minval=1, maxval=7)

//====================================================
// PAIR BREAKOUT FUNCTION
//
// breakDir:
//  1 = pair has broken previous session HIGH
// -1 = pair has broken previous session LOW
//
// holdDir:
//  1 = currently CLOSE still above previous session HIGH
// -1 = currently CLOSE still below previous session LOW
//  0 = currently back inside range
//====================================================

f_pairState() =>
    bool inAsia = not na(time(timeframe.period, asiaSession, sessionTimeZone))
    bool inLondon = not na(time(timeframe.period, londonSession, sessionTimeZone))
    bool inNewYork = not na(time(timeframe.period, newYorkSession, sessionTimeZone))

    int sessionId = 0

    if inAsia
        sessionId := 1
    else if inLondon
        sessionId := 2
    else if inNewYork
        sessionId := 3

    var int oldSessionId = 0

    var float sessionHigh = na
    var float sessionLow = na

    var float previousHigh = na
    var float previousLow = na

    var int breakoutDir = 0

    bool sessionChanged = sessionId != oldSessionId

    //================================================
    // NEW SESSION
    //================================================

    if sessionChanged
        if oldSessionId != 0 and not na(sessionHigh) and not na(sessionLow)
            previousHigh := sessionHigh
            previousLow := sessionLow

        if sessionId != 0
            sessionHigh := high
            sessionLow := low
        else
            sessionHigh := na
            sessionLow := na

        breakoutDir := 0
        oldSessionId := sessionId

    else
        if sessionId != 0
            if na(sessionHigh)
                sessionHigh := high
            else
                sessionHigh := math.max(sessionHigh, high)

            if na(sessionLow)
                sessionLow := low
            else
                sessionLow := math.min(sessionLow, low)

    //================================================
    // RECORD CONFIRMED BREAKOUT
    //================================================

    if sessionId != 0 and not na(previousHigh) and not na(previousLow)
        if close > previousHigh
            breakoutDir := 1
        else if close < previousLow
            breakoutDir := -1

    //================================================
    // IS PRICE STILL HOLDING OUTSIDE?
    //================================================

    int holdDir = 0

    if sessionId != 0 and not na(previousHigh) and not na(previousLow)
        if close > previousHigh
            holdDir := 1
        else if close < previousLow
            holdDir := -1

    [breakoutDir, holdDir]

//====================================================
// REQUEST ALL 28 PAIRS
//====================================================

// AUD
[audcadBreak, audcadHold] = request.security(feed + ":AUDCAD", timeframe.period, f_pairState())
[audchfBreak, audchfHold] = request.security(feed + ":AUDCHF", timeframe.period, f_pairState())
[audjpyBreak, audjpyHold] = request.security(feed + ":AUDJPY", timeframe.period, f_pairState())
[audnzdBreak, audnzdHold] = request.security(feed + ":AUDNZD", timeframe.period, f_pairState())
[audusdBreak, audusdHold] = request.security(feed + ":AUDUSD", timeframe.period, f_pairState())

// CAD
[cadchfBreak, cadchfHold] = request.security(feed + ":CADCHF", timeframe.period, f_pairState())
[cadjpyBreak, cadjpyHold] = request.security(feed + ":CADJPY", timeframe.period, f_pairState())

// CHF
[chfjpyBreak, chfjpyHold] = request.security(feed + ":CHFJPY", timeframe.period, f_pairState())

// EUR
[euraudBreak, euraudHold] = request.security(feed + ":EURAUD", timeframe.period, f_pairState())
[eurcadBreak, eurcadHold] = request.security(feed + ":EURCAD", timeframe.period, f_pairState())
[eurchfBreak, eurchfHold] = request.security(feed + ":EURCHF", timeframe.period, f_pairState())
[eurgbpBreak, eurgbpHold] = request.security(feed + ":EURGBP", timeframe.period, f_pairState())
[eurjpyBreak, eurjpyHold] = request.security(feed + ":EURJPY", timeframe.period, f_pairState())
[eurnzdBreak, eurnzdHold] = request.security(feed + ":EURNZD", timeframe.period, f_pairState())
[eurusdBreak, eurusdHold] = request.security(feed + ":EURUSD", timeframe.period, f_pairState())

// GBP
[gbpaudBreak, gbpaudHold] = request.security(feed + ":GBPAUD", timeframe.period, f_pairState())
[gbpcadBreak, gbpcadHold] = request.security(feed + ":GBPCAD", timeframe.period, f_pairState())
[gbpchfBreak, gbpchfHold] = request.security(feed + ":GBPCHF", timeframe.period, f_pairState())
[gbpjpyBreak, gbpjpyHold] = request.security(feed + ":GBPJPY", timeframe.period, f_pairState())
[gbpnzdBreak, gbpnzdHold] = request.security(feed + ":GBPNZD", timeframe.period, f_pairState())
[gbpusdBreak, gbpusdHold] = request.security(feed + ":GBPUSD", timeframe.period, f_pairState())

// NZD
[nzdcadBreak, nzdcadHold] = request.security(feed + ":NZDCAD", timeframe.period, f_pairState())
[nzdchfBreak, nzdchfHold] = request.security(feed + ":NZDCHF", timeframe.period, f_pairState())
[nzdjpyBreak, nzdjpyHold] = request.security(feed + ":NZDJPY", timeframe.period, f_pairState())
[nzdusdBreak, nzdusdHold] = request.security(feed + ":NZDUSD", timeframe.period, f_pairState())

// USD
[usdcadBreak, usdcadHold] = request.security(feed + ":USDCAD", timeframe.period, f_pairState())
[usdchfBreak, usdchfHold] = request.security(feed + ":USDCHF", timeframe.period, f_pairState())
[usdjpyBreak, usdjpyHold] = request.security(feed + ":USDJPY", timeframe.period, f_pairState())

//====================================================
// HELPERS
//====================================================

f_baseStrong(int state) =>
    state == 1 ? 1 : 0

f_baseWeak(int state) =>
    state == -1 ? 1 : 0

f_quoteStrong(int state) =>
    state == -1 ? 1 : 0

f_quoteWeak(int state) =>
    state == 1 ? 1 : 0

//====================================================
// AUD BREAKOUT COUNTS
//====================================================

audStrong =
     f_baseStrong(audcadBreak) +
     f_baseStrong(audchfBreak) +
     f_baseStrong(audjpyBreak) +
     f_baseStrong(audnzdBreak) +
     f_baseStrong(audusdBreak) +
     f_quoteStrong(euraudBreak) +
     f_quoteStrong(gbpaudBreak)

audWeak =
     f_baseWeak(audcadBreak) +
     f_baseWeak(audchfBreak) +
     f_baseWeak(audjpyBreak) +
     f_baseWeak(audnzdBreak) +
     f_baseWeak(audusdBreak) +
     f_quoteWeak(euraudBreak) +
     f_quoteWeak(gbpaudBreak)

audStrongHold =
     f_baseStrong(audcadHold) +
     f_baseStrong(audchfHold) +
     f_baseStrong(audjpyHold) +
     f_baseStrong(audnzdHold) +
     f_baseStrong(audusdHold) +
     f_quoteStrong(euraudHold) +
     f_quoteStrong(gbpaudHold)

audWeakHold =
     f_baseWeak(audcadHold) +
     f_baseWeak(audchfHold) +
     f_baseWeak(audjpyHold) +
     f_baseWeak(audnzdHold) +
     f_baseWeak(audusdHold) +
     f_quoteWeak(euraudHold) +
     f_quoteWeak(gbpaudHold)

//====================================================
// CAD
//====================================================

cadStrong =
     f_quoteStrong(audcadBreak) +
     f_baseStrong(cadchfBreak) +
     f_baseStrong(cadjpyBreak) +
     f_quoteStrong(eurcadBreak) +
     f_quoteStrong(gbpcadBreak) +
     f_quoteStrong(nzdcadBreak) +
     f_quoteStrong(usdcadBreak)

cadWeak =
     f_quoteWeak(audcadBreak) +
     f_baseWeak(cadchfBreak) +
     f_baseWeak(cadjpyBreak) +
     f_quoteWeak(eurcadBreak) +
     f_quoteWeak(gbpcadBreak) +
     f_quoteWeak(nzdcadBreak) +
     f_quoteWeak(usdcadBreak)

cadStrongHold =
     f_quoteStrong(audcadHold) +
     f_baseStrong(cadchfHold) +
     f_baseStrong(cadjpyHold) +
     f_quoteStrong(eurcadHold) +
     f_quoteStrong(gbpcadHold) +
     f_quoteStrong(nzdcadHold) +
     f_quoteStrong(usdcadHold)

cadWeakHold =
     f_quoteWeak(audcadHold) +
     f_baseWeak(cadchfHold) +
     f_baseWeak(cadjpyHold) +
     f_quoteWeak(eurcadHold) +
     f_quoteWeak(gbpcadHold) +
     f_quoteWeak(nzdcadHold) +
     f_quoteWeak(usdcadHold)

//====================================================
// CHF
//====================================================

chfStrong =
     f_quoteStrong(audchfBreak) +
     f_quoteStrong(cadchfBreak) +
     f_baseStrong(chfjpyBreak) +
     f_quoteStrong(eurchfBreak) +
     f_quoteStrong(gbpchfBreak) +
     f_quoteStrong(nzdchfBreak) +
     f_quoteStrong(usdchfBreak)

chfWeak =
     f_quoteWeak(audchfBreak) +
     f_quoteWeak(cadchfBreak) +
     f_baseWeak(chfjpyBreak) +
     f_quoteWeak(eurchfBreak) +
     f_quoteWeak(gbpchfBreak) +
     f_quoteWeak(nzdchfBreak) +
     f_quoteWeak(usdchfBreak)

chfStrongHold =
     f_quoteStrong(audchfHold) +
     f_quoteStrong(cadchfHold) +
     f_baseStrong(chfjpyHold) +
     f_quoteStrong(eurchfHold) +
     f_quoteStrong(gbpchfHold) +
     f_quoteStrong(nzdchfHold) +
     f_quoteStrong(usdchfHold)

chfWeakHold =
     f_quoteWeak(audchfHold) +
     f_quoteWeak(cadchfHold) +
     f_baseWeak(chfjpyHold) +
     f_quoteWeak(eurchfHold) +
     f_quoteWeak(gbpchfHold) +
     f_quoteWeak(nzdchfHold) +
     f_quoteWeak(usdchfHold)

//====================================================
// EUR
//====================================================

eurStrong =
     f_baseStrong(euraudBreak) +
     f_baseStrong(eurcadBreak) +
     f_baseStrong(eurchfBreak) +
     f_baseStrong(eurgbpBreak) +
     f_baseStrong(eurjpyBreak) +
     f_baseStrong(eurnzdBreak) +
     f_baseStrong(eurusdBreak)

eurWeak =
     f_baseWeak(euraudBreak) +
     f_baseWeak(eurcadBreak) +
     f_baseWeak(eurchfBreak) +
     f_baseWeak(eurgbpBreak) +
     f_baseWeak(eurjpyBreak) +
     f_baseWeak(eurnzdBreak) +
     f_baseWeak(eurusdBreak)

eurStrongHold =
     f_baseStrong(euraudHold) +
     f_baseStrong(eurcadHold) +
     f_baseStrong(eurchfHold) +
     f_baseStrong(eurgbpHold) +
     f_baseStrong(eurjpyHold) +
     f_baseStrong(eurnzdHold) +
     f_baseStrong(eurusdHold)

eurWeakHold =
     f_baseWeak(euraudHold) +
     f_baseWeak(eurcadHold) +
     f_baseWeak(eurchfHold) +
     f_baseWeak(eurgbpHold) +
     f_baseWeak(eurjpyHold) +
     f_baseWeak(eurnzdHold) +
     f_baseWeak(eurusdHold)

//====================================================
// GBP
//====================================================

gbpStrong =
     f_quoteStrong(eurgbpBreak) +
     f_baseStrong(gbpaudBreak) +
     f_baseStrong(gbpcadBreak) +
     f_baseStrong(gbpchfBreak) +
     f_baseStrong(gbpjpyBreak) +
     f_baseStrong(gbpnzdBreak) +
     f_baseStrong(gbpusdBreak)

gbpWeak =
     f_quoteWeak(eurgbpBreak) +
     f_baseWeak(gbpaudBreak) +
     f_baseWeak(gbpcadBreak) +
     f_baseWeak(gbpchfBreak) +
     f_baseWeak(gbpjpyBreak) +
     f_baseWeak(gbpnzdBreak) +
     f_baseWeak(gbpusdBreak)

gbpStrongHold =
     f_quoteStrong(eurgbpHold) +
     f_baseStrong(gbpaudHold) +
     f_baseStrong(gbpcadHold) +
     f_baseStrong(gbpchfHold) +
     f_baseStrong(gbpjpyHold) +
     f_baseStrong(gbpnzdHold) +
     f_baseStrong(gbpusdHold)

gbpWeakHold =
     f_quoteWeak(eurgbpHold) +
     f_baseWeak(gbpaudHold) +
     f_baseWeak(gbpcadHold) +
     f_baseWeak(gbpchfHold) +
     f_baseWeak(gbpjpyHold) +
     f_baseWeak(gbpnzdHold) +
     f_baseWeak(gbpusdHold)

//====================================================
// JPY
//====================================================

jpyStrong =
     f_quoteStrong(audjpyBreak) +
     f_quoteStrong(cadjpyBreak) +
     f_quoteStrong(chfjpyBreak) +
     f_quoteStrong(eurjpyBreak) +
     f_quoteStrong(gbpjpyBreak) +
     f_quoteStrong(nzdjpyBreak) +
     f_quoteStrong(usdjpyBreak)

jpyWeak =
     f_quoteWeak(audjpyBreak) +
     f_quoteWeak(cadjpyBreak) +
     f_quoteWeak(chfjpyBreak) +
     f_quoteWeak(eurjpyBreak) +
     f_quoteWeak(gbpjpyBreak) +
     f_quoteWeak(nzdjpyBreak) +
     f_quoteWeak(usdjpyBreak)

jpyStrongHold =
     f_quoteStrong(audjpyHold) +
     f_quoteStrong(cadjpyHold) +
     f_quoteStrong(chfjpyHold) +
     f_quoteStrong(eurjpyHold) +
     f_quoteStrong(gbpjpyHold) +
     f_quoteStrong(nzdjpyHold) +
     f_quoteStrong(usdjpyHold)

jpyWeakHold =
     f_quoteWeak(audjpyHold) +
     f_quoteWeak(cadjpyHold) +
     f_quoteWeak(chfjpyHold) +
     f_quoteWeak(eurjpyHold) +
     f_quoteWeak(gbpjpyHold) +
     f_quoteWeak(nzdjpyHold) +
     f_quoteWeak(usdjpyHold)

//====================================================
// NZD
//====================================================

nzdStrong =
     f_quoteStrong(audnzdBreak) +
     f_quoteStrong(eurnzdBreak) +
     f_quoteStrong(gbpnzdBreak) +
     f_baseStrong(nzdcadBreak) +
     f_baseStrong(nzdchfBreak) +
     f_baseStrong(nzdjpyBreak) +
     f_baseStrong(nzdusdBreak)

nzdWeak =
     f_quoteWeak(audnzdBreak) +
     f_quoteWeak(eurnzdBreak) +
     f_quoteWeak(gbpnzdBreak) +
     f_baseWeak(nzdcadBreak) +
     f_baseWeak(nzdchfBreak) +
     f_baseWeak(nzdjpyBreak) +
     f_baseWeak(nzdusdBreak)

nzdStrongHold =
     f_quoteStrong(audnzdHold) +
     f_quoteStrong(eurnzdHold) +
     f_quoteStrong(gbpnzdHold) +
     f_baseStrong(nzdcadHold) +
     f_baseStrong(nzdchfHold) +
     f_baseStrong(nzdjpyHold) +
     f_baseStrong(nzdusdHold)

nzdWeakHold =
     f_quoteWeak(audnzdHold) +
     f_quoteWeak(eurnzdHold) +
     f_quoteWeak(gbpnzdHold) +
     f_baseWeak(nzdcadHold) +
     f_baseWeak(nzdchfHold) +
     f_baseWeak(nzdjpyHold) +
     f_baseWeak(nzdusdHold)

//====================================================
// USD
//====================================================

usdStrong =
     f_quoteStrong(audusdBreak) +
     f_quoteStrong(eurusdBreak) +
     f_quoteStrong(gbpusdBreak) +
     f_quoteStrong(nzdusdBreak) +
     f_baseStrong(usdcadBreak) +
     f_baseStrong(usdchfBreak) +
     f_baseStrong(usdjpyBreak)

usdWeak =
     f_quoteWeak(audusdBreak) +
     f_quoteWeak(eurusdBreak) +
     f_quoteWeak(gbpusdBreak) +
     f_quoteWeak(nzdusdBreak) +
     f_baseWeak(usdcadBreak) +
     f_baseWeak(usdchfBreak) +
     f_baseWeak(usdjpyBreak)

usdStrongHold =
     f_quoteStrong(audusdHold) +
     f_quoteStrong(eurusdHold) +
     f_quoteStrong(gbpusdHold) +
     f_quoteStrong(nzdusdHold) +
     f_baseStrong(usdcadHold) +
     f_baseStrong(usdchfHold) +
     f_baseStrong(usdjpyHold)

usdWeakHold =
     f_quoteWeak(audusdHold) +
     f_quoteWeak(eurusdHold) +
     f_quoteWeak(gbpusdHold) +
     f_quoteWeak(nzdusdHold) +
     f_baseWeak(usdcadHold) +
     f_baseWeak(usdchfHold) +
     f_baseWeak(usdjpyHold)

//====================================================
// CURRENT SESSION
//====================================================

bool chartAsia = not na(time(timeframe.period, asiaSession, sessionTimeZone))
bool chartLondon = not na(time(timeframe.period, londonSession, sessionTimeZone))
bool chartNewYork = not na(time(timeframe.period, newYorkSession, sessionTimeZone))

int chartSession = 0

if chartAsia
    chartSession := 1
else if chartLondon
    chartSession := 2
else if chartNewYork
    chartSession := 3

bool newChartSession = chartSession != nz(chartSession[1]) and chartSession != 0

//====================================================
// ONE SIGNAL PER CURRENCY PER SESSION
//====================================================

var bool audFired = false
var bool cadFired = false
var bool chfFired = false
var bool eurFired = false
var bool gbpFired = false
var bool jpyFired = false
var bool nzdFired = false
var bool usdFired = false

if newChartSession
    audFired := false
    cadFired := false
    chfFired := false
    eurFired := false
    gbpFired := false
    jpyFired := false
    nzdFired := false
    usdFired := false

//====================================================
// FINAL SIGNAL
//
// RULE 1:
// 6/7 have confirmed the aligned breakout.
//
// RULE 2:
// At least 4/7 are STILL outside the breakout level.
//====================================================

audStrongSignal = chartSession != 0 and audStrong >= requiredBreakouts and audStrongHold >= requiredHolding and not audFired
audWeakSignal = chartSession != 0 and audWeak >= requiredBreakouts and audWeakHold >= requiredHolding and not audFired

cadStrongSignal = chartSession != 0 and cadStrong >= requiredBreakouts and cadStrongHold >= requiredHolding and not cadFired
cadWeakSignal = chartSession != 0 and cadWeak >= requiredBreakouts and cadWeakHold >= requiredHolding and not cadFired

chfStrongSignal = chartSession != 0 and chfStrong >= requiredBreakouts and chfStrongHold >= requiredHolding and not chfFired
chfWeakSignal = chartSession != 0 and chfWeak >= requiredBreakouts and chfWeakHold >= requiredHolding and not chfFired

eurStrongSignal = chartSession != 0 and eurStrong >= requiredBreakouts and eurStrongHold >= requiredHolding and not eurFired
eurWeakSignal = chartSession != 0 and eurWeak >= requiredBreakouts and eurWeakHold >= requiredHolding and not eurFired

gbpStrongSignal = chartSession != 0 and gbpStrong >= requiredBreakouts and gbpStrongHold >= requiredHolding and not gbpFired
gbpWeakSignal = chartSession != 0 and gbpWeak >= requiredBreakouts and gbpWeakHold >= requiredHolding and not gbpFired

jpyStrongSignal = chartSession != 0 and jpyStrong >= requiredBreakouts and jpyStrongHold >= requiredHolding and not jpyFired
jpyWeakSignal = chartSession != 0 and jpyWeak >= requiredBreakouts and jpyWeakHold >= requiredHolding and not jpyFired

nzdStrongSignal = chartSession != 0 and nzdStrong >= requiredBreakouts and nzdStrongHold >= requiredHolding and not nzdFired
nzdWeakSignal = chartSession != 0 and nzdWeak >= requiredBreakouts and nzdWeakHold >= requiredHolding and not nzdFired

usdStrongSignal = chartSession != 0 and usdStrong >= requiredBreakouts and usdStrongHold >= requiredHolding and not usdFired
usdWeakSignal = chartSession != 0 and usdWeak >= requiredBreakouts and usdWeakHold >= requiredHolding and not usdFired

//====================================================
// CLEAN MARKERS
//====================================================

atr = ta.atr(14)

// AUD
if audStrongSignal
    label.new(bar_index, high + atr * 0.15, "● AUD", style=label.style_none, textcolor=color.green, size=size.tiny)
    audFired := true

if audWeakSignal
    label.new(bar_index, low - atr * 0.15, "● AUD", style=label.style_none, textcolor=color.red, size=size.tiny)
    audFired := true

// CAD
if cadStrongSignal
    label.new(bar_index, high + atr * 0.25, "● CAD", style=label.style_none, textcolor=color.green, size=size.tiny)
    cadFired := true

if cadWeakSignal
    label.new(bar_index, low - atr * 0.25, "● CAD", style=label.style_none, textcolor=color.red, size=size.tiny)
    cadFired := true

// CHF
if chfStrongSignal
    label.new(bar_index, high + atr * 0.35, "● CHF", style=label.style_none, textcolor=color.green, size=size.tiny)
    chfFired := true

if chfWeakSignal
    label.new(bar_index, low - atr * 0.35, "● CHF", style=label.style_none, textcolor=color.red, size=size.tiny)
    chfFired := true

// EUR
if eurStrongSignal
    label.new(bar_index, high + atr * 0.45, "● EUR", style=label.style_none, textcolor=color.green, size=size.tiny)
    eurFired := true

if eurWeakSignal
    label.new(bar_index, low - atr * 0.45, "● EUR", style=label.style_none, textcolor=color.red, size=size.tiny)
    eurFired := true

// GBP
if gbpStrongSignal
    label.new(bar_index, high + atr * 0.55, "● GBP", style=label.style_none, textcolor=color.green, size=size.tiny)
    gbpFired := true

if gbpWeakSignal
    label.new(bar_index, low - atr * 0.55, "● GBP", style=label.style_none, textcolor=color.red, size=size.tiny)
    gbpFired := true

// JPY
if jpyStrongSignal
    label.new(bar_index, high + atr * 0.65, "● JPY", style=label.style_none, textcolor=color.green, size=size.tiny)
    jpyFired := true

if jpyWeakSignal
    label.new(bar_index, low - atr * 0.65, "● JPY", style=label.style_none, textcolor=color.red, size=size.tiny)
    jpyFired := true

// NZD
if nzdStrongSignal
    label.new(bar_index, high + atr * 0.75, "● NZD", style=label.style_none, textcolor=color.green, size=size.tiny)
    nzdFired := true

if nzdWeakSignal
    label.new(bar_index, low - atr * 0.75, "● NZD", style=label.style_none, textcolor=color.red, size=size.tiny)
    nzdFired := true

// USD
if usdStrongSignal
    label.new(bar_index, high + atr * 0.85, "● USD", style=label.style_none, textcolor=color.green, size=size.tiny)
    usdFired := true

if usdWeakSignal
    label.new(bar_index, low - atr * 0.85, "● USD", style=label.style_none, textcolor=color.red, size=size.tiny)
    usdFired := true
````
