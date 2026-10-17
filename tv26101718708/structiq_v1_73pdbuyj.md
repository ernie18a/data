# StructIQ V1

- url: https://www.tradingview.com/script/73PdBuyj-StructIQ-V1/
- type: indicator
- pine_id: PUB;4a29eeee96014afe89f78202e1cb458f
- version: 1.0

## Description

[b]Designed exclusively for intraday trading on Indian indices such as Nifty, Bank Nifty, and Sensex.[/b]
[b]
StructIQ — Market Structure & Liquidity Signals[/b]
StructIQ is an intraday indicator that combines market structure and liquidity concepts into clear trade setups. It identifies Liquidity Sweeps, Change of Character (CHoCH) and Break of Structure (BOS), with defined Entry, Risk and Target levels.

Its visual layout makes each trade easy to follow, using shaded risk/reward boxes, BUY/SELL signals and outcome labels.

[b]Key Features[/b]
Three entry conditions: Enable Liquidity Sweep, CHoCH and BOS individually to match your trading approach.
Sweep confirmation: Optionally wait for price to close beyond the sweep candle’s high or low within a configurable confirmation window.
Strong BOS filter: Filter BOS entries using candle-body strength and closing position within the candle’s range.
Defined trade levels: Risk levels use confirmed swings and relevant candle extremes, with an optional buffer. Targets follow your selected reward-to-risk ratio.
Trade history: Display recent trades across a configurable session window, with WIN, LOSS, SESSION and CHECK labels.
Performance dashboard: View setup-wise win/loss results, win rate, session-exit R and total gross R.
Session controls and alerts: Set entry hours, optional morning-only entries, session square-off and signal alerts.


[b]How to Use[/b]
Apply StructIQ to a standard intraday candlestick chart, select your preferred entry conditions and adjust the reward-to-risk ratio. Signals are confirmed at candle close, and the indicator tracks one active trade at a time.

Compare filters individually while keeping the timeframe, session and reward-to-risk settings consistent. The accompanying index charts illustrate the indicator’s presentation on Sensex and Bank Nifty.

[b]Understanding the Results[/b]
WIN means the target was touched; LOSS means the risk level was touched. SESSION records a session exit. CHECK means both risk and target were touched within the same candle, so their order cannot be determined.

Win rate includes only WIN/LOSS outcomes. Gross R includes session exits but excludes CHECK and open trades. Results are candle-based estimates before trading costs, not Strategy Tester results. Historical performance does not guarantee future outcomes.

## Source Code

````pine
//@version=6
indicator("VP SMC • StructIQ V1", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500)

//────────────────────────────────────
// INPUTS
//────────────────────────────────────
string g1 = "01 • Entry Conditions"
int swingLen = input.int(3, "Swing confirmation bars", minval=1, group=g1)
bool useSweep = input.bool(true, "Liquidity Sweep", group=g1)
bool useChoch = input.bool(true, "CHoCH", group=g1)
bool useBos = input.bool(true, "BOS", group=g1)

string g2 = "02 • Entry Quality Filters"
bool confirmSweep = input.bool(true, "Confirm sweep before entry", group=g2)
int sweepWindow = input.int(3, "Sweep confirmation window • candles",
     minval=1, maxval=10, group=g2)
bool strongBos = input.bool(true, "Strong BOS candle filter", group=g2)
float minBody = input.float(60, "BOS minimum body • % of range",
     minval=10, maxval=100, step=5, group=g2)
float closeEdge = input.float(25, "BOS close within edge • %",
     minval=5, maxval=50, step=5, group=g2)
bool morningOnly = input.bool(false, "Test morning entries only • 09:30–12:00",
     group=g2)

string g3 = "03 • Trade Management"
float rr = input.float(1.0, "Reward / Risk",
     minval=0.5, step=0.25, group=g3)
float buffer = input.float(0.0, "Risk buffer • points", minval=0, group=g3)
bool useSession = input.bool(true, "Use entry session", group=g3)
string entrySession = input.session("0930-1500", "Entry session", group=g3)
string tz = input.string("Asia/Kolkata", "Timezone", group=g3)
bool squareOff = input.bool(true, "Session square-off", group=g3)
int exitHour = input.int(15, "Square-off hour", minval=0, maxval=23, group=g3)
int exitMinute = input.int(25, "Square-off minute", minval=0, maxval=59, group=g3)

string g4 = "04 • Display"
int keepSessions = input.int(30, "Trading sessions to display",
     minval=1, maxval=100, group=g4)
int maxTrades = input.int(150, "Maximum displayed trades",
     minval=10, maxval=160, group=g4)
bool showBoxes = input.bool(true, "Risk / Reward boxes", group=g4)
bool showLines = input.bool(true, "Entry / Risk / Target lines", group=g4)
bool showTags = input.bool(true, "Active price tags", group=g4)
bool showReason = input.bool(true, "Setup on entry label", group=g4)
bool showCard = input.bool(true, "Dashboard", group=g4)
bool lightTheme = input.bool(true, "Light chart theme", group=g4)
int transparency = input.int(89, "Box transparency",
     minval=70, maxval=98, group=g4)
float labelGap = input.float(0.35, "Label spacing • ATR",
     minval=0.1, step=0.05, group=g4)
color buyColor = input.color(#009688, "Buy / Reward", group=g4)
color sellColor = input.color(#E74C3C, "Sell / Risk", group=g4)
color entryColor = input.color(#2962FF, "Entry", group=g4)

//────────────────────────────────────
// RECORD TYPE
//────────────────────────────────────
type Trade
    int sessionNo
    int side
    int startTime
    int startBar
    float entry
    float risk
    float target
    int setupId
    string setup
    string result
    float pnlR
    line entryLine
    line riskLine
    line targetLine
    box rewardBox
    box riskBox
    label entryLabel
    label exitLabel

deleteTrade(Trade t) =>
    if not na(t.entryLine)
        line.delete(t.entryLine)
    if not na(t.riskLine)
        line.delete(t.riskLine)
    if not na(t.targetLine)
        line.delete(t.targetLine)
    if not na(t.rewardBox)
        box.delete(t.rewardBox)
    if not na(t.riskBox)
        box.delete(t.riskBox)
    if not na(t.entryLabel)
        label.delete(t.entryLabel)
    if not na(t.exitLabel)
        label.delete(t.exitLabel)

priceText(float p) =>
    na(p) ? "—" : str.tostring(p, format.mintick)

rText(float value) =>
    (value > 0 ? "+" : "") + str.tostring(value, "#.##") + "R"

rateText(int wins, int losses) =>
    wins + losses > 0 ?
         str.tostring(100.0 * wins / (wins + losses), "#.0") + "%" : "—"

//────────────────────────────────────
// STATE
//────────────────────────────────────
var array<Trade> trades = array.new<Trade>()
var Trade current = na
var bool active = false

var label entryTag = na
var label riskTag = na
var label targetTag = na

var float swingHigh = na
var float swingLow = na
var bool highBroken = false
var bool lowBroken = false
var bool highSwept = false
var bool lowSwept = false
var int trend = 0
var int sessionNo = 1

// Pending sweep confirmation.
var int pendingSide = 0
var int pendingBar = na
var float pendingTrigger = na
var float pendingExtreme = na
var float pendingSwing = na

//────────────────────────────────────
// SERIES / SESSION
//────────────────────────────────────
float ph = ta.pivothigh(high, swingLen, swingLen)
float pl = ta.pivotlow(low, swingLen, swingLen)
float atr = ta.atr(14)
float gap = math.max(nz(atr, high - low), syminfo.mintick) * labelGap

int dateKey = year(time, tz) * 10000 +
     month(time, tz) * 100 + dayofmonth(time, tz)
bool newDay = not na(dateKey[1]) and dateKey != dateKey[1]

bool normalSession = not useSession or
     not na(time(timeframe.period, entrySession, tz))
bool morningSession = not morningOnly or
     not na(time(timeframe.period, "0930-1200", tz))
bool inSession = normalSession and morningSession

int cutoff = timestamp(tz, year(time, tz), month(time, tz),
     dayofmonth(time, tz), exitHour, exitMinute)
bool cutoffReached = squareOff and
     not na(time_close) and time_close >= cutoff

float candleRange = high - low
float candleBody = math.abs(close - open)
float bodyPercent = candleRange > 0 ?
     100.0 * candleBody / candleRange : 0.0

bool strongBull = candleRange > 0 and close > open and
     bodyPercent >= minBody and
     close >= high - candleRange * closeEdge / 100.0

bool strongBear = candleRange > 0 and close < open and
     bodyPercent >= minBody and
     close <= low + candleRange * closeEdge / 100.0

bool buySignal = false
bool sellSignal = false
bool winSignal = false
bool lossSignal = false
bool checkSignal = false
bool sessionSignal = false

//────────────────────────────────────
// CONFIRMED CANDLE LOGIC
//────────────────────────────────────
if barstate.isconfirmed
    if newDay
        sessionNo += 1
        pendingSide := 0

    bool exitedNow = false
    bool previousSessionExit = false
    float exitPrice = na
    string exitResult = ""

    // Fallback if the prior session has no cutoff candle.
    if active and squareOff and newDay
        active := false
        exitedNow := true
        previousSessionExit := true
        sessionSignal := true
        exitPrice := close[1]
        exitResult := "SESSION"

    // No exit check on the entry candle.
    if active and bar_index > current.startBar
        bool hitRisk = current.side == 1 ?
             low <= current.risk : high >= current.risk
        bool hitTarget = current.side == 1 ?
             high >= current.target : low <= current.target

        if hitRisk and hitTarget
            active := false
            exitedNow := true
            checkSignal := true
            exitPrice := close
            exitResult := "CHECK"
        else if hitRisk
            active := false
            exitedNow := true
            lossSignal := true
            exitPrice := current.risk
            exitResult := "LOSS"
        else if hitTarget
            active := false
            exitedNow := true
            winSignal := true
            exitPrice := current.target
            exitResult := "WIN"
        else if cutoffReached
            active := false
            exitedNow := true
            sessionSignal := true
            exitPrice := close
            exitResult := "SESSION"

    // Extend drawings until exit.
    if active or exitedNow
        int rightTime = previousSessionExit ?
             nz(time_close[1], time[1]) : nz(time_close, time)
        rightTime := math.max(rightTime, current.startTime + 1)

        if not na(current.entryLine)
            line.set_x2(current.entryLine, rightTime)
        if not na(current.riskLine)
            line.set_x2(current.riskLine, rightTime)
        if not na(current.targetLine)
            line.set_x2(current.targetLine, rightTime)
        if not na(current.rewardBox)
            box.set_right(current.rewardBox, rightTime)
        if not na(current.riskBox)
            box.set_right(current.riskBox, rightTime)

    if exitedNow
        current.result := exitResult

        float riskDistance = math.abs(current.entry - current.risk)
        float actualRR = math.abs(current.target - current.entry) / riskDistance

        current.pnlR := checkSignal ? na :
             winSignal ? actualRR :
             lossSignal ? -1.0 :
             current.side * (exitPrice - current.entry) / riskDistance

        color resultColor = winSignal ? buyColor :
             lossSignal ? sellColor :
             checkSignal ? #D97706 : #64748B

        string resultText = winSignal ?
             "WIN  " + rText(current.pnlR) :
             lossSignal ? "LOSS  -1R" :
             checkSignal ? "CHECK" :
             "SESSION  " + rText(current.pnlR)

        current.exitLabel := label.new(
             x=previousSessionExit ? time[1] : time,
             y=exitPrice + (current.side == 1 ? gap : -gap),
             text=resultText,
             xloc=xloc.bar_time,
             style=current.side == 1 ?
                 label.style_label_down : label.style_label_up,
             color=resultColor, textcolor=color.white, size=size.small)

        if not na(current.rewardBox)
            box.set_border_color(current.rewardBox, color.new(resultColor, 35))
        if not na(current.riskBox)
            box.set_border_color(current.riskBox, color.new(resultColor, 35))

        if not na(entryTag)
            label.delete(entryTag)
        if not na(riskTag)
            label.delete(riskTag)
        if not na(targetTag)
            label.delete(targetTag)
        entryTag := na
        riskTag := na
        targetTag := na

        pendingSide := 0
        alert(exitResult + " | " + syminfo.ticker,
             alert.freq_once_per_bar_close)

    // Breaks use previously confirmed swings.
    bool breakUp = not na(swingHigh) and not highBroken and
         close > swingHigh and close[1] <= swingHigh
    bool breakDown = not na(swingLow) and not lowBroken and
         close < swingLow and close[1] >= swingLow

    bool bullChoch = breakUp and trend == -1
    bool bearChoch = breakDown and trend == 1
    bool bullBos = breakUp and trend != -1
    bool bearBos = breakDown and trend != 1

    bool bullSweep = not na(swingLow) and not lowBroken and
         not lowSwept and low < swingLow and
         close > swingLow and close > open
    bool bearSweep = not na(swingHigh) and not highBroken and
         not highSwept and high > swingHigh and
         close < swingHigh and close < open

    if breakUp
        highBroken := true
        trend := 1
    if breakDown
        lowBroken := true
        trend := -1
    if bullSweep
        lowSwept := true
    if bearSweep
        highSwept := true

    bool canEnter = not active and not exitedNow and
         inSession and not cutoffReached

    bool confirmedBullSweep = false
    bool confirmedBearSweep = false
    float confirmedSweepRisk = na

    // Do not queue setups during active trades or outside entry hours.
    if active or exitedNow or not inSession or cutoffReached
        pendingSide := 0

    // Process a sweep registered on an earlier candle.
    if confirmSweep and useSweep and canEnter and pendingSide != 0
        int elapsed = bar_index - pendingBar
        bool invalidated = pendingSide == 1 ?
             low < pendingExtreme : high > pendingExtreme

        if elapsed > sweepWindow or invalidated
            pendingSide := 0
        else if elapsed >= 1
            bool trigger = pendingSide == 1 ?
                 close > pendingTrigger : close < pendingTrigger

            if trigger
                confirmedBullSweep := pendingSide == 1
                confirmedBearSweep := pendingSide == -1

                confirmedSweepRisk := pendingSide == 1 ?
                     math.min(pendingSwing, pendingExtreme) :
                     math.max(pendingSwing, pendingExtreme)

                pendingSide := 0

    // Register a fresh sweep, then wait for a later candle.
    if confirmSweep and useSweep and canEnter and
         not confirmedBullSweep and not confirmedBearSweep
        if bullSweep and not bearSweep
            pendingSide := 1
            pendingBar := bar_index
            pendingTrigger := high
            pendingExtreme := low
            pendingSwing := swingLow
        else if bearSweep and not bullSweep
            pendingSide := -1
            pendingBar := bar_index
            pendingTrigger := low
            pendingExtreme := high
            pendingSwing := swingHigh

    bool sweepLong = useSweep and
         (confirmSweep ? confirmedBullSweep : bullSweep)
    bool sweepShort = useSweep and
         (confirmSweep ? confirmedBearSweep : bearSweep)

    bool chochLong = useChoch and bullChoch
    bool chochShort = useChoch and bearChoch

    bool bosLong = useBos and bullBos and
         (not strongBos or strongBull)
    bool bosShort = useBos and bearBos and
         (not strongBos or strongBear)

    bool longSetup = sweepLong or chochLong or bosLong
    bool shortSetup = sweepShort or chochShort or bosShort

    int newSide = 0
    int newSetupId = 0
    float newRisk = na
    string newSetup = ""

    // Attribution priority: SWEEP > CHoCH > BOS.
    if canEnter and longSetup and not shortSetup and not na(swingLow)
        newSide := 1
        newSetupId := sweepLong ? 0 : chochLong ? 1 : 2
        newSetup := sweepLong ?
             (confirmSweep ? "SWEEP CONFIRMED" : "SWEEP") :
             chochLong ? "CHoCH" : "BOS"

        float baseRisk = sweepLong and confirmSweep ?
             confirmedSweepRisk : swingLow

        newRisk := math.round_to_mintick(math.min(baseRisk, low) - buffer)

        if close - newRisk <= syminfo.mintick
            newSide := 0

    if canEnter and shortSetup and not longSetup and not na(swingHigh)
        newSide := -1
        newSetupId := sweepShort ? 0 : chochShort ? 1 : 2
        newSetup := sweepShort ?
             (confirmSweep ? "SWEEP CONFIRMED" : "SWEEP") :
             chochShort ? "CHoCH" : "BOS"

        float baseRisk = sweepShort and confirmSweep ?
             confirmedSweepRisk : swingHigh

        newRisk := math.round_to_mintick(math.max(baseRisk, high) + buffer)

        if newRisk - close <= syminfo.mintick
            newSide := 0

    if newSide != 0
        while array.size(trades) >= maxTrades
            Trade removed = array.shift(trades)
            deleteTrade(removed)

        current := Trade.new()
        current.sessionNo := sessionNo
        current.side := newSide
        current.startTime := time
        current.startBar := bar_index
        current.entry := close
        current.risk := newRisk
        current.target := math.round_to_mintick(
             close + newSide * math.abs(close - newRisk) * rr)
        current.setupId := newSetupId
        current.setup := newSetup
        current.result := "ACTIVE"
        current.pnlR := na

        active := true
        pendingSide := 0
        buySignal := newSide == 1
        sellSignal := newSide == -1

        int initialRight = math.max(nz(time_close, time), time + 1)

        if showBoxes
            current.rewardBox := box.new(
                 left=time, top=math.max(current.entry, current.target),
                 right=initialRight, bottom=math.min(current.entry, current.target),
                 xloc=xloc.bar_time,
                 border_color=color.new(buyColor, 65),
                 bgcolor=color.new(buyColor, transparency))

            current.riskBox := box.new(
                 left=time, top=math.max(current.entry, current.risk),
                 right=initialRight, bottom=math.min(current.entry, current.risk),
                 xloc=xloc.bar_time,
                 border_color=color.new(sellColor, 65),
                 bgcolor=color.new(sellColor, transparency))

        if showLines
            current.entryLine := line.new(
                 time, current.entry, initialRight, current.entry,
                 xloc=xloc.bar_time, color=entryColor, width=2)
            current.riskLine := line.new(
                 time, current.risk, initialRight, current.risk,
                 xloc=xloc.bar_time, color=sellColor, style=line.style_dashed)
            current.targetLine := line.new(
                 time, current.target, initialRight, current.target,
                 xloc=xloc.bar_time, color=buyColor, style=line.style_dashed)

        string sideText = newSide == 1 ? "BUY" : "SELL"

        current.entryLabel := label.new(
             x=time, y=newSide == 1 ? low - gap : high + gap,
             text=sideText + (showReason ? "\n" + newSetup : ""),
             xloc=xloc.bar_time,
             style=newSide == 1 ? label.style_label_up : label.style_label_down,
             color=newSide == 1 ? buyColor : sellColor,
             textcolor=color.white, size=size.small)

        if showTags
            entryTag := label.new(
                 bar_index + 3, current.entry,
                 "ENTRY  " + priceText(current.entry),
                 style=label.style_label_left, color=entryColor,
                 textcolor=color.white, size=size.small)
            riskTag := label.new(
                 bar_index + 3, current.risk,
                 "RISK  " + priceText(current.risk),
                 style=label.style_label_left, color=sellColor,
                 textcolor=color.white, size=size.small)
            targetTag := label.new(
                 bar_index + 3, current.target,
                 "TARGET  " + priceText(current.target),
                 style=label.style_label_left, color=buyColor,
                 textcolor=color.white, size=size.small)

        array.push(trades, current)

        alert(sideText + " | " + syminfo.ticker +
             " | " + newSetup +
             " | Entry " + priceText(current.entry) +
             " | Risk " + priceText(current.risk) +
             " | Target " + priceText(current.target),
             alert.freq_once_per_bar_close)

    // Remove expired completed records.
    bool pruning = true
    while pruning and array.size(trades) > 0
        Trade oldest = array.get(trades, 0)
        if oldest.sessionNo <= sessionNo - keepSessions and
             oldest.result != "ACTIVE"
            Trade removed = array.shift(trades)
            deleteTrade(removed)
        else
            pruning := false

    // Newly confirmed pivots become usable next candle.
    if not na(ph)
        swingHigh := ph
        highBroken := false
        highSwept := false
    if not na(pl)
        swingLow := pl
        lowBroken := false
        lowSwept := false

//────────────────────────────────────
// ACTIVE TAGS
//────────────────────────────────────
if barstate.islast and active
    if not na(entryTag)
        label.set_x(entryTag, bar_index + 3)
    if not na(riskTag)
        label.set_x(riskTag, bar_index + 3)
    if not na(targetTag)
        label.set_x(targetTag, bar_index + 3)

//────────────────────────────────────
// DASHBOARD
//────────────────────────────────────
var table card = table.new(position.top_right, 3, 12,
     frame_width=1, border_width=1)

if barstate.isfirst
    table.merge_cells(card, 0, 0, 2, 0)

if barstate.islast
    if showCard
        array<int> setupWins = array.new<int>(3, 0)
        array<int> setupLosses = array.new<int>(3, 0)
        array<float> setupR = array.new<float>(3, 0.0)

        int wins = 0
        int losses = 0
        int checks = 0
        int sessionExits = 0
        float totalR = 0.0
        float sessionR = 0.0

        if array.size(trades) > 0
            for i = 0 to array.size(trades) - 1
                Trade t = array.get(trades, i)
                int id = t.setupId

                if t.result == "WIN"
                    wins += 1
                    array.set(setupWins, id, array.get(setupWins, id) + 1)
                else if t.result == "LOSS"
                    losses += 1
                    array.set(setupLosses, id, array.get(setupLosses, id) + 1)
                else if t.result == "CHECK"
                    checks += 1
                else if t.result == "SESSION"
                    sessionExits += 1
                    sessionR += nz(t.pnlR)

                if not na(t.pnlR)
                    totalR += t.pnlR
                    array.set(setupR, id, array.get(setupR, id) + t.pnlR)

        color bg = lightTheme ? #F8FAFC : #111827
        color fg = lightTheme ? #0F172A : #E2E8F0
        color muted = lightTheme ? #64748B : #94A3B8

        table.set_bgcolor(card, bg)
        table.set_frame_color(card, color.new(muted, 55))
        table.set_border_color(card, color.new(muted, 80))

        string status = "WAITING"
        string setup = "—"
        color statusColor = muted

        if active
            status := current.side == 1 ? "LONG ACTIVE" : "SHORT ACTIVE"
            setup := current.setup
            statusColor := current.side == 1 ? buyColor : sellColor
        else if pendingSide != 0
            status := "SWEEP PENDING"
            setup := pendingSide == 1 ? "BULLISH" : "BEARISH"
            statusColor := #D97706

        table.cell(card, 0, 0,
             "VP SMC • PRECISION • " + str.tostring(keepSessions) + " SESSIONS",
             bgcolor=#1E293B, text_color=color.white, text_size=size.small)

        table.cell(card, 0, 1, "STATUS", text_color=muted, text_size=size.small)
        table.cell(card, 1, 1, status, text_color=statusColor, text_size=size.small)
        table.cell(card, 2, 1, setup, text_color=fg, text_size=size.small)

        table.cell(card, 0, 2, "WIN / LOSS", text_color=muted, text_size=size.small)
        table.cell(card, 1, 2,
             str.tostring(wins) + " / " + str.tostring(losses),
             text_color=fg, text_size=size.small)
        table.cell(card, 2, 2, rateText(wins, losses),
             text_color=buyColor, text_size=size.small)

        table.cell(card, 0, 3, "TOTAL R • GROSS",
             text_color=muted, text_size=size.small)
        table.cell(card, 1, 3, rText(totalR),
             text_color=totalR >= 0 ? buyColor : sellColor, text_size=size.small)
        table.cell(card, 2, 3, "Incl. session exits",
             text_color=muted, text_size=size.small)

        table.cell(card, 0, 4, "SESSION EXITS",
             text_color=muted, text_size=size.small)
        table.cell(card, 1, 4, str.tostring(sessionExits),
             text_color=fg, text_size=size.small)
        table.cell(card, 2, 4, rText(sessionR),
             text_color=sessionR >= 0 ? buyColor : sellColor, text_size=size.small)

        table.cell(card, 0, 5, "SETUP", bgcolor=#1E293B,
             text_color=color.white, text_size=size.small)
        table.cell(card, 1, 5, "W / L • WR", bgcolor=#1E293B,
             text_color=color.white, text_size=size.small)
        table.cell(card, 2, 5, "GROSS R", bgcolor=#1E293B,
             text_color=color.white, text_size=size.small)

        for id = 0 to 2
            int w = array.get(setupWins, id)
            int l = array.get(setupLosses, id)
            float valueR = array.get(setupR, id)
            string name = id == 0 ? "SWEEP" : id == 1 ? "CHoCH" : "BOS"

            table.cell(card, 0, id + 6, name,
                 text_color=fg, text_size=size.small)
            table.cell(card, 1, id + 6,
                 str.tostring(w) + "/" + str.tostring(l) +
                 " • " + rateText(w, l),
                 text_color=fg, text_size=size.small)
            table.cell(card, 2, id + 6, rText(valueR),
                 text_color=valueR >= 0 ? buyColor : sellColor,
                 text_size=size.small)

        table.cell(card, 0, 9, "TRADES / CHECK",
             text_color=muted, text_size=size.small)
        table.cell(card, 1, 9,
             str.tostring(array.size(trades)) + " / " + str.tostring(checks),
             text_color=fg, text_size=size.small)
        table.cell(card, 2, 9, "RR 1:" + str.tostring(rr, "#.##"),
             text_color=fg, text_size=size.small)

        table.cell(card, 0, 10, "FILTERS",
             text_color=muted, text_size=size.small)
        table.cell(card, 1, 10, confirmSweep ? "SWEEP CONF ON" : "SWEEP CONF OFF",
             text_color=fg, text_size=size.small)
        table.cell(card, 2, 10, strongBos ? "BOS FILTER ON" : "BOS FILTER OFF",
             text_color=fg, text_size=size.small)

        table.cell(card, 0, 11, "ENTRY HOURS",
             text_color=muted, text_size=size.small)
        table.cell(card, 1, 11,
             morningOnly ? "MORNING ONLY" : useSession ? entrySession : "ALL HOURS",
             text_color=fg, text_size=size.small)
        table.cell(card, 2, 11, "CHECK excluded",
             text_color=muted, text_size=size.small)
    else
        table.clear(card, 0, 0, 2, 11)

//────────────────────────────────────
// ALERTS
//────────────────────────────────────
alertcondition(buySignal, "BUY", "VP SMC BUY | {{ticker}} | {{close}}")
alertcondition(sellSignal, "SELL", "VP SMC SELL | {{ticker}} | {{close}}")
alertcondition(winSignal, "WIN", "VP SMC target reached | {{ticker}}")
alertcondition(lossSignal, "LOSS", "VP SMC risk reached | {{ticker}}")
alertcondition(checkSignal, "CHECK",
     "VP SMC risk and target touched in the same candle | {{ticker}}")
alertcondition(sessionSignal, "SESSION CLOSED",
     "VP SMC session closed | {{ticker}}")
````
