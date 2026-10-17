# Adaptive Channel Reaction

- url: https://www.tradingview.com/script/EOpgzDa4-Adaptive-Channel-Reaction/
- type: indicator
- pine_id: PUB;34cff4dd5dcd4ee3b0a22e87f9146ddb
- version: 1.0

## Description

Adaptive Channel Reaction (ACR) is a price-channel analysis indicator designed to identify structured support and resistance channels from confirmed swing points and evaluate price reactions around those boundaries.
The indicator is intended to help traders study channel behavior, lower-boundary reactions, upper-boundary reactions, structural breaks, and potential continuation after an upside channel breakout. It is an indicator, not an automated trading strategy, and it does not predict future price movement.
How it works
ACR builds channels from the two most recently confirmed swing highs and swing lows. In Parallel mode, the boundaries are calculated from the slopes of the swing structures. In Range mode, horizontal support and resistance boundaries are used instead.
Candidate channels are filtered using several structural checks:
- Minimum channel width relative to ATR.
- Geometric agreement between the upper and lower boundaries.
- A channel-quality calculation based on geometry and independent price reactions near both boundaries.
- Touch separation logic to reduce repeated counting of adjacent candles as separate reactions.
ATR is used as a volatility-normalization mechanism so that channel width, penetration limits, break buffers, and reaction tolerances adapt to the instrument being analyzed.
Entry logic
The lower section of an active channel is treated as a reaction area rather than as one exact price.
Three entry-confirmation modes are available:
- Confirmed Rejection — requires price to interact with the lower reaction area, remain within the allowed penetration distance, close back inside the channel, and satisfy the configured lower-wick requirement.
- Close Back Inside — requires interaction with the lower area and a close back inside the channel.
- Touch Only — the most permissive mode and reacts to a qualified lower-area interaction.
Optional bullish-candle and EMA filters are available. They are disabled by default and are not required by the core channel logic.
Exit logic
ACR provides three exit modes:
- Adaptive — evaluates upper-channel rejection while allowing a sufficiently strong upside breakout to remain active. If the breakout subsequently fails and price closes back inside the channel by the configured amount, an exit can be generated.
- Upper Rejection — exits after a qualified rejection near the upper channel boundary.
- Upper Line Touch — exits when price reaches the upper boundary.
The Adaptive mode is designed to distinguish between a simple reaction at channel resistance and an expansion move through the upper boundary.
Channel breaks
Channel breaks are not based solely on an intrabar penetration. The indicator evaluates confirmed closes outside the channel using an ATR-based buffer.
Normal breaks can require multiple consecutive closes and directional follow-through. A substantially deeper ATR-based break can bypass the normal confirmation sequence so that unusually strong structural failures are not ignored.
Channel strength
In addition to the geometric relationship between the channel boundaries, ACR evaluates independent interactions with the upper and lower sides of the structure.
A cooldown between counted reactions helps prevent several neighboring candles from artificially inflating the channel-strength calculation. The weaker side of the channel limits the reaction-quality component, so a structure that is respected repeatedly on only one side does not automatically receive a maximum reaction score.
Channel lifetime
Channels are not intended to remain active indefinitely. The script can retire structures that become excessively old, remain without relevant interaction for too long, or expand to an excessive width relative to ATR.
Finished channels can remain visible for historical context. Active-channel projection is visual only and does not create historical trading signals.
Confirmed swings and visual behavior
The script uses confirmed swing points. Because a swing requires bars to form on both sides before confirmation, channel identification includes an unavoidable confirmation delay.
Channel lines may visually begin from their structural swing anchors to make the price structure easier to interpret. However, BUY, SELL, and BREAK conditions are evaluated only after the channel has actually been confirmed. Historical line placement should therefore not be interpreted as evidence that the channel was known at the earlier anchor bars.
Main inputs
Users can configure:
- Channel type
- Swing length
- Geometry tolerance
- Minimum channel quality
- ATR-normalized minimum width
- Reaction-strength weighting
- Touch tolerance and touch count
- Lower reaction zone
- Maximum lower-boundary penetration
- Rejection-wick requirements
- Optional bullish-candle and EMA filters
- Adaptive exit behavior
- Break buffers and confirmation requirements
- Channel lifetime
- Historical channel display and visual projection
Alerts
Alert conditions are provided for:
- BUY
- SELL
- BREAK
Optional alert() messages are also available for webhook-based workflows. Users should configure and test their own alert and automation setup before relying on it.
Originality
ACR is not a simple fixed-width channel or a standard moving-average crossover system. Its purpose is to combine confirmed swing geometry, volatility-normalized channel validation, independent boundary-reaction scoring, lower-channel rejection logic, adaptive breakout handling, and confirmed channel-break logic into one price-structure workflow.
The channel-quality model is designed to evaluate not only whether two boundaries can mathematically be drawn, but also whether price has demonstrated meaningful interaction with both sides of the structure.
Limitations
- Confirmed pivots introduce delay because swing points cannot be identified until subsequent bars have formed.
- Channel analysis is inherently sensitive to the selected swing length and market structure.
- A channel that worked historically may fail when volatility or market regime changes.
- BUY, SELL, and BREAK markers are analytical conditions, not guaranteed trade outcomes.
- The indicator does not account for commissions, slippage, liquidity, position sizing, or portfolio risk.
- This is an indicator, not a backtested strategy, so its markers should not be interpreted as strategy-performance statistics.
- Historical visual channel extensions do not imply that the structure was available to the indicator before confirmation.
ACR is intended to support independent technical analysis and risk management. It does not forecast future prices or guarantee profitable outcomes.

## Source Code

````pine
//@version=6
indicator(
     "Adaptive Channel Reaction",
     shorttitle = "ACR",
     overlay = true,
     max_lines_count = 500,
     max_bars_back = 500)

// ============================================================================
// GROUPS
// ============================================================================

var string G1 = "[1] Channel Detection"
var string G2 = "[2] Channel Strength"
var string G3 = "[3] Entry"
var string G4 = "[4] Exit & Break"
var string G5 = "[5] Display"
var string G6 = "[6] Alerts"

// ============================================================================
// [1] CHANNEL DETECTION
// ============================================================================

chMode = input.string(
     "Parallel (sloped)",
     "Channel Type",
     options = ["Parallel (sloped)", "Range (flat)"],
     group = G1)

pivLen = input.int(
     7,
     "Swing Length",
     minval = 2,
     group = G1)

tolMult = input.float(
     0.25,
     "Geometry Tolerance",
     minval = 0.05,
     maxval = 1.0,
     step = 0.05,
     group = G1)

minQuality = input.float(
     60.0,
     "Minimum Channel Quality",
     minval = 0,
     maxval = 100,
     step = 5,
     group = G1)

minW = input.float(
     2.0,
     "Minimum Width (x ATR)",
     minval = 0.5,
     step = 0.25,
     group = G1)

atrLen = input.int(
     14,
     "ATR Length",
     minval = 1,
     group = G1)

maxChannelAge = input.int(
     140,
     "Maximum Channel Age (bars)",
     minval = 30,
     maxval = 500,
     group = G1)

maxNoInteractionBars = input.int(
     55,
     "Maximum Bars Without Interaction",
     minval = 15,
     maxval = 200,
     group = G1)

maxEffectiveWidthATR = input.float(
     8.0,
     "Maximum Effective Width (x ATR)",
     minval = 3.0,
     maxval = 20.0,
     step = 0.5,
     group = G1)

// ============================================================================
// [2] CHANNEL STRENGTH
// ============================================================================

strengthWeight = input.float(
     25.0,
     "Reaction Strength Weight (%)",
     minval = 0,
     maxval = 50,
     step = 5,
     group = G2)

touchToleranceATR = input.float(
     0.20,
     "Touch Tolerance (x ATR)",
     minval = 0.05,
     maxval = 1.0,
     step = 0.05,
     group = G2)

targetTouches = input.int(
     3,
     "Target Touches Per Side",
     minval = 2,
     maxval = 6,
     group = G2)

touchCooldown = input.int(
     3,
     "Touch Cooldown (bars)",
     minval = 1,
     maxval = 20,
     group = G2)

strengthLookback = input.int(
     180,
     "Strength Lookback",
     minval = 50,
     maxval = 350,
     group = G2)

// ============================================================================
// [3] ENTRY
// ============================================================================

entryMode = input.string(
     "Confirmed Rejection",
     "Entry Confirmation",
     options = [
         "Confirmed Rejection",
         "Close Back Inside",
         "Touch Only"
     ],
     group = G3)

entryZonePct = input.float(
     12.0,
     "Lower Reaction Zone (%)",
     minval = 0,
     maxval = 30,
     step = 1,
     group = G3)

maxPenetration = input.float(
     0.35,
     "Maximum Penetration (x ATR)",
     minval = 0,
     step = 0.05,
     group = G3)

minWickPct = input.float(
     20.0,
     "Minimum Lower Wick (%)",
     minval = 0,
     maxval = 100,
     step = 5,
     group = G3)

requireBullClose = input.bool(
     false,
     "Require Bullish Candle",
     group = G3)

useEma = input.bool(
     false,
     "Use EMA Trend Filter",
     group = G3)

emaLen = input.int(
     200,
     "EMA Length",
     minval = 1,
     group = G3,
     active = useEma)

// ============================================================================
// [4] EXIT & BREAK
// ============================================================================

exitMode = input.string(
     "Adaptive",
     "Exit Mode",
     options = [
         "Adaptive",
         "Upper Rejection",
         "Upper Line Touch"
     ],
     group = G4)

upperZonePct = input.float(
     10.0,
     "Upper Reaction Zone (%)",
     minval = 0,
     maxval = 30,
     step = 1,
     group = G4)

breakoutBuffer = input.float(
     0.15,
     "Breakout Hold Buffer (x ATR)",
     minval = 0,
     step = 0.05,
     group = G4)

breakoutBodyPct = input.float(
     55.0,
     "Minimum Breakout Body (%)",
     minval = 10,
     maxval = 100,
     step = 5,
     group = G4)

breakoutReturnBuffer = input.float(
     0.05,
     "Breakout Failure Buffer (x ATR)",
     minval = 0,
     maxval = 1,
     step = 0.05,
     group = G4)

upperRejectWickPct = input.float(
     25.0,
     "Upper Rejection Wick (%)",
     minval = 0,
     maxval = 100,
     step = 5,
     group = G4)

brkMult = input.float(
     0.30,
     "Break Buffer (x ATR)",
     minval = 0,
     step = 0.05,
     group = G4)

breakConfirmBars = input.int(
     2,
     "Break Confirmation Bars",
     minval = 1,
     maxval = 4,
     group = G4)

breakMinBodyPct = input.float(
     30.0,
     "Minimum Break Candle Body (%)",
     minval = 0,
     maxval = 100,
     step = 5,
     group = G4)

deepBreakATR = input.float(
     0.80,
     "Immediate Deep Break (x ATR)",
     minval = 0.30,
     maxval = 3.0,
     step = 0.05,
     group = G4)

useStop = input.bool(
     true,
     "Exit On Downside Break",
     group = G4)

lockWhileLong = input.bool(
     true,
     "Lock Channel While Trade Is Open",
     group = G4)

// ============================================================================
// [5] DISPLAY
// ============================================================================

showMarks = input.bool(
     true,
     "Show BUY / SELL / BREAK",
     group = G5)

showHist = input.bool(
     true,
     "Keep Old Channels",
     group = G5)

maxHist = input.int(
     15,
     "Old Channels Kept",
     minval = 1,
     maxval = 100,
     group = G5,
     active = showHist)

visualForwardBars = input.int(
     18,
     "Visual Forward Extension",
     minval = 0,
     maxval = 100,
     group = G5,
     tooltip =
     "Extends both active and finished channel lines forward by this many bars. " +
     "This is visual only and does not change BUY / SELL / BREAK logic.")

maxVisualLength = input.int(
     160,
     "Maximum Visual Channel Length",
     minval = 50,
     maxval = 500,
     group = G5,
     tooltip =
     "Maximum total visual length of a channel, including forward extension.")

preventNegativeProjection = input.bool(
     true,
     "Prevent Negative Price Projection",
     group = G5)

colTop = input.color(
     color.new(#E05A5A, 0),
     "Upper Line",
     group = G5)

colBot = input.color(
     color.new(#3FA37A, 0),
     "Lower Line",
     group = G5)

colFill = input.color(
     color.new(#7A8899, 92),
     "Channel Fill",
     group = G5)

lineW = input.int(
     2,
     "Channel Line Width",
     minval = 1,
     maxval = 5,
     group = G5)

// ============================================================================
// [6] ALERTS
// ============================================================================

useHook = input.bool(
     true,
     "Send Webhook Messages",
     group = G6)

buyMsg = input.text_area(
     "buy",
     "Buy Message",
     group = G6,
     active = useHook)

sellMsg = input.text_area(
     "sell",
     "Sell Message",
     group = G6,
     active = useHook)

brkMsg = input.text_area(
     "sell",
     "Break Exit Message",
     group = G6,
     active = useHook)

// ============================================================================
// BASE
// ============================================================================

bool isRange = chMode == "Range (flat)"

float atr = ta.atr(atrLen)
float ema = ta.ema(close, emaLen)

float ph = ta.pivothigh(high, pivLen, pivLen)
float pl = ta.pivotlow(low, pivLen, pivLen)

// ============================================================================
// HELPERS
// ============================================================================

lineAt(int i1, float v1, int i2, float v2, int x) =>
    i1 == i2 ? v2 : v2 + (v2 - v1) / (i2 - i1) * (x - i2)

clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

// ============================================================================
// SWINGS
// ============================================================================

var int h1i = na
var float h1v = na
var int h2i = na
var float h2v = na

var int l1i = na
var float l1v = na
var int l2i = na
var float l2v = na

// ============================================================================
// CHANNEL STATE
// ============================================================================

var bool chOn = false

var int ah1i = na
var float ah1v = na
var int ah2i = na
var float ah2v = na

var int al1i = na
var float al1v = na
var int al2i = na
var float al2v = na

var float channelATR = na
var float channelGeometryQuality = na
var float channelTouchQuality = na
var float channelQuality = na

var int channelTopTouches = 0
var int channelBotTouches = 0

var int channelID = 0
var int channelStartBar = na

var int resetBar = -1
var int breakBar = -1

var int lastInteractionBar = na
var int lastTopTouchBar = na
var int lastBotTouchBar = na

var int downsideBreakCount = 0
var int upsideBreakCount = 0

// ============================================================================
// TRADE STATE
// ============================================================================

var int pos = 0
var int entryBar = -1
var int tradeChannelID = -1

var bool upperZoneTouched = false
var bool breakoutHoldActive = false

// ============================================================================
// DRAWING STATE
// ============================================================================

var line curTop = na
var line curBot = na
var linefill curFill = na

var int drawH1 = na
var int drawH2 = na
var int drawL1 = na
var int drawL2 = na

var array<line> oldTops = array.new<line>()
var array<line> oldBots = array.new<line>()

// ============================================================================
// CURRENT CHANNEL
// ============================================================================

float topNow = na
float botNow = na

if chOn
    if isRange
        topNow := math.max(ah1v, ah2v)
        botNow := math.min(al1v, al2v)
    else
        topNow := lineAt(ah1i, ah1v, ah2i, ah2v, bar_index)
        botNow := lineAt(al1i, al1v, al2i, al2v, bar_index)

bool validNow =
     chOn and
     not na(topNow) and
     not na(botNow) and
     topNow > botNow

float channelWidth =
     validNow ?
     topNow - botNow :
     na

int channelAge =
     validNow and not na(channelStartBar) ?
     bar_index - channelStartBar :
     0

// ============================================================================
// CANDLE METRICS
// ============================================================================

float candleRange =
     math.max(
         high - low,
         syminfo.mintick)

float bodySize =
     math.abs(close - open)

float bodyPct =
     bodySize /
     candleRange *
     100.0

float lowerWick =
     math.min(open, close) - low

float lowerWickPct =
     lowerWick /
     candleRange *
     100.0

float upperWick =
     high - math.max(open, close)

float upperWickPct =
     upperWick /
     candleRange *
     100.0

// ============================================================================
// LIVE TOUCH STRENGTH
// ============================================================================

float liveTouchTolerance =
     validNow and not na(channelATR) ?
     touchToleranceATR * channelATR :
     na

bool liveTopInteraction =
     validNow and
     high >= topNow - liveTouchTolerance and
     low <= topNow + liveTouchTolerance and
     close <= topNow + liveTouchTolerance

bool liveBotInteraction =
     validNow and
     low <= botNow + liveTouchTolerance and
     high >= botNow - liveTouchTolerance and
     close >= botNow - liveTouchTolerance

if validNow and bar_index >= channelStartBar

    bool newTopTouch =
         liveTopInteraction and
         (na(lastTopTouchBar) or bar_index - lastTopTouchBar >= touchCooldown)

    bool newBotTouch =
         liveBotInteraction and
         (na(lastBotTouchBar) or bar_index - lastBotTouchBar >= touchCooldown)

    if newTopTouch
        channelTopTouches += 1
        lastTopTouchBar := bar_index
        lastInteractionBar := bar_index

    if newBotTouch
        channelBotTouches += 1
        lastBotTouchBar := bar_index
        lastInteractionBar := bar_index

    float liveTopScore =
         math.min(
             100.0,
             channelTopTouches /
             float(targetTouches) *
             100.0)

    float liveBotScore =
         math.min(
             100.0,
             channelBotTouches /
             float(targetTouches) *
             100.0)

    channelTouchQuality :=
         math.min(
             liveTopScore,
             liveBotScore)

    float reactionWeightLive =
         strengthWeight /
         100.0

    channelQuality :=
         channelGeometryQuality *
         (1.0 - reactionWeightLive) +
         channelTouchQuality *
         reactionWeightLive

// ============================================================================
// ENTRY
// ============================================================================

float lowerZoneTop =
     validNow ?
     botNow +
     channelWidth *
     entryZonePct /
     100.0 :
     na

float penetrationBuffer =
     not na(channelATR) ?
     maxPenetration *
     channelATR :
     0.0

bool touchedLowerZone =
     validNow and
     low <= lowerZoneTop

bool penetrationOK =
     validNow and
     low >= botNow - penetrationBuffer

bool closedBackInside =
     validNow and
     close >= botNow

bool lowerWickOK =
     lowerWickPct >= minWickPct

bool bullishCandleOK =
     not requireBullClose or
     close > open

bool emaFilterOK =
     not useEma or
     close > ema

bool confirmedRejection =
     touchedLowerZone and
     penetrationOK and
     closedBackInside and
     lowerWickOK

bool closeBackEntry =
     touchedLowerZone and
     penetrationOK and
     closedBackInside

bool touchEntry =
     touchedLowerZone and
     penetrationOK

bool baseEntry =
     entryMode == "Confirmed Rejection" ? confirmedRejection :
     entryMode == "Close Back Inside" ? closeBackEntry :
     touchEntry

bool finalEntry =
     baseEntry and
     bullishCandleOK and
     emaFilterOK

// ============================================================================
// SIGNALS
// ============================================================================

bool buySig = false
bool sellSig = false
bool brkSig = false

// ============================================================================
// BUY
// ============================================================================

if pos == 0 and validNow and finalEntry and bar_index >= channelStartBar
    buySig := true
    pos := 1
    entryBar := bar_index
    tradeChannelID := channelID
    upperZoneTouched := false
    breakoutHoldActive := false

// ============================================================================
// UPPER REACTION
// ============================================================================

float upperZoneBottom =
     validNow ?
     topNow -
     channelWidth *
     upperZonePct /
     100.0 :
     na

bool reachedUpperArea =
     validNow and
     high >= upperZoneBottom

if pos == 1 and tradeChannelID == channelID and reachedUpperArea
    upperZoneTouched := true

bool upperRejection =
     validNow and
     high >= upperZoneBottom and
     close < topNow and
     upperWickPct >= upperRejectWickPct

// ============================================================================
// BREAKOUT STRENGTH
// ============================================================================

bool strongBullBody =
     close > open and
     bodyPct >= breakoutBodyPct

bool breakoutAboveTop =
     validNow and
     not na(channelATR) and
     close > topNow + breakoutBuffer * channelATR

bool strongBreakout =
     breakoutAboveTop and
     strongBullBody

// ============================================================================
// ADAPTIVE EXIT
// ============================================================================

bool sameTradeChannel =
     pos == 1 and
     tradeChannelID == channelID

bool classicUpperTouch =
     validNow and
     high >= topNow

bool adaptiveExit = false

if sameTradeChannel and bar_index > entryBar

    if exitMode == "Upper Line Touch"
        adaptiveExit := classicUpperTouch

    else if exitMode == "Upper Rejection"
        adaptiveExit := upperRejection

    else

        if strongBreakout
            breakoutHoldActive := true

        if breakoutHoldActive

            bool breakoutFailed =
                 barstate.isconfirmed and
                 close < topNow - breakoutReturnBuffer * channelATR

            if breakoutFailed
                adaptiveExit := true

        else if upperZoneTouched and upperRejection
            adaptiveExit := true

if adaptiveExit
    sellSig := true
    pos := 0
    tradeChannelID := -1
    upperZoneTouched := false
    breakoutHoldActive := false

// ============================================================================
// SMART BREAK
// ============================================================================

bool downBreakRaw = false
bool upBreakRaw = false

if validNow and barstate.isconfirmed and not na(channelATR)
    downBreakRaw := close < botNow - brkMult * channelATR
    upBreakRaw := close > topNow + brkMult * channelATR

if downBreakRaw
    downsideBreakCount += 1
else
    downsideBreakCount := 0

if upBreakRaw
    upsideBreakCount += 1
else
    upsideBreakCount := 0

bool deepDownBreak =
     validNow and
     not na(channelATR) and
     close < botNow - deepBreakATR * channelATR

bool deepUpBreak =
     validNow and
     not na(channelATR) and
     close > topNow + deepBreakATR * channelATR

bool bearishBreakBody =
     close < open and
     bodyPct >= breakMinBodyPct

bool bullishBreakBody =
     close > open and
     bodyPct >= breakMinBodyPct

bool downsideFollowThrough =
     breakConfirmBars <= 1 or
     close <= close[1]

bool upsideFollowThrough =
     breakConfirmBars <= 1 or
     close >= close[1]

bool normalDownBreak =
     downsideBreakCount >= breakConfirmBars and
     bearishBreakBody and
     downsideFollowThrough

bool normalUpBreak =
     upsideBreakCount >= breakConfirmBars and
     bullishBreakBody and
     upsideFollowThrough

bool downsideBreak =
     validNow and
     barstate.isconfirmed and
     (deepDownBreak or normalDownBreak)

bool upsideBreak =
     validNow and
     barstate.isconfirmed and
     (deepUpBreak or normalUpBreak)

bool acceptedUpsideExpansion =
     exitMode == "Adaptive" and
     sameTradeChannel and
     breakoutHoldActive

if sameTradeChannel and upsideBreak and not acceptedUpsideExpansion
    sellSig := true
    pos := 0
    tradeChannelID := -1
    upperZoneTouched := false
    breakoutHoldActive := false

bool confirmedChannelBreak =
     downsideBreak or
     (upsideBreak and not acceptedUpsideExpansion)

if confirmedChannelBreak

    if pos == 1 and tradeChannelID == channelID and useStop and downsideBreak
        brkSig := true
        pos := 0
        tradeChannelID := -1
        upperZoneTouched := false
        breakoutHoldActive := false

    breakBar := bar_index
    resetBar := bar_index

    downsideBreakCount := 0
    upsideBreakCount := 0

    chOn := false

// ============================================================================
// SIMPLE EXPIRATION
// ============================================================================

bool channelTooOld =
     validNow and
     pos == 0 and
     channelAge > maxChannelAge

bool channelTooStale =
     validNow and
     pos == 0 and
     not na(lastInteractionBar) and
     bar_index - lastInteractionBar > maxNoInteractionBars

bool channelTooWide =
     validNow and
     pos == 0 and
     not na(channelATR) and
     channelWidth > maxEffectiveWidthATR * channelATR

bool channelExpired =
     channelTooOld or
     channelTooStale or
     channelTooWide

if channelExpired
    resetBar := bar_index
    downsideBreakCount := 0
    upsideBreakCount := 0
    chOn := false

// ============================================================================
// REGISTER SWINGS
// ============================================================================

bool newSwing = false

if not na(ph)
    h1i := h2i
    h1v := h2v
    h2i := bar_index - pivLen
    h2v := ph
    newSwing := true

if not na(pl)
    l1i := l2i
    l1v := l2v
    l2i := bar_index - pivLen
    l2v := pl
    newSwing := true

// ============================================================================
// CHANNEL CANDIDATE
// ============================================================================

bool haveFourSwings =
     not na(h1i) and
     not na(h2i) and
     not na(l1i) and
     not na(l2i)

bool allAfterReset =
     haveFourSwings and
     math.min(
         math.min(h1i, h2i),
         math.min(l1i, l2i)
     ) > resetBar

bool mayReplace =
     pos == 0 or
     not lockWhileLong

bool evaluateCandidate =
     haveFourSwings and
     allAfterReset and
     not na(atr) and
     (not chOn or (newSwing and mayReplace))

if evaluateCandidate

    float candidateTop = na
    float candidateBot = na
    float candidateWidth = na

    float geometryQuality = 0.0
    float touchQuality = 0.0
    float finalQuality = 0.0

    int topTouchCount = 0
    int botTouchCount = 0

    bool widthOK = false
    bool geometryOK = false

    float candidateATR = atr

    // ------------------------------------------------------------------------
    // RANGE
    // ------------------------------------------------------------------------

    if isRange

        candidateTop := math.max(h1v, h2v)
        candidateBot := math.min(l1v, l2v)

        candidateWidth :=
             candidateTop -
             candidateBot

        widthOK :=
             candidateWidth >=
             minW *
             candidateATR

        float highError =
             candidateWidth > 0 ?
             math.abs(h1v - h2v) /
             candidateWidth :
             1.0

        float lowError =
             candidateWidth > 0 ?
             math.abs(l1v - l2v) /
             candidateWidth :
             1.0

        float avgError =
             (highError + lowError) /
             2.0

        geometryOK :=
             highError <= tolMult and
             lowError <= tolMult

        float normalizedError =
             tolMult > 0 ?
             avgError / tolMult :
             1.0

        geometryQuality :=
             100.0 *
             (1.0 -
             clamp(
                 normalizedError,
                 0.0,
                 1.0))

    // ------------------------------------------------------------------------
    // PARALLEL
    // ------------------------------------------------------------------------

    else

        float highSlope =
             (h2v - h1v) /
             math.max(
                 h2i - h1i,
                 1)

        float lowSlope =
             (l2v - l1v) /
             math.max(
                 l2i - l1i,
                 1)

        candidateTop :=
             lineAt(
                 h1i,
                 h1v,
                 h2i,
                 h2v,
                 bar_index)

        candidateBot :=
             lineAt(
                 l1i,
                 l1v,
                 l2i,
                 l2v,
                 bar_index)

        candidateWidth :=
             candidateTop -
             candidateBot

        widthOK :=
             candidateWidth >=
             minW *
             candidateATR

        int earliestAnchor =
             math.min(
                 math.min(h1i, h2i),
                 math.min(l1i, l2i))

        int latestAnchor =
             math.max(
                 math.max(h1i, h2i),
                 math.max(l1i, l2i))

        int structuralSpan =
             math.max(
                 latestAnchor -
                 earliestAnchor,
                 1)

        float slopeDrift =
             math.abs(
                 highSlope -
                 lowSlope) *
             structuralSpan

        float driftRatio =
             candidateWidth > 0 ?
             slopeDrift /
             candidateWidth :
             1.0

        geometryOK :=
             driftRatio <=
             tolMult

        float normalizedDrift =
             tolMult > 0 ?
             driftRatio /
             tolMult :
             1.0

        geometryQuality :=
             100.0 *
             (1.0 -
             clamp(
                 normalizedDrift,
                 0.0,
                 1.0))

    // ------------------------------------------------------------------------
    // HISTORICAL TOUCH QUALITY
    // ------------------------------------------------------------------------

    int earliestStructureBar =
         math.min(
             math.min(h1i, h2i),
             math.min(l1i, l2i))

    float historicalTouchTolerance =
         touchToleranceATR *
         candidateATR

    int lastTopOffset = na
    int lastBotOffset = na

    for off = 0 to strengthLookback - 1

        int absoluteBar =
             bar_index -
             off

        if absoluteBar >= earliestStructureBar

            float topAtBar =
                 isRange ?
                 candidateTop :
                 lineAt(
                     h1i,
                     h1v,
                     h2i,
                     h2v,
                     absoluteBar)

            float botAtBar =
                 isRange ?
                 candidateBot :
                 lineAt(
                     l1i,
                     l1v,
                     l2i,
                     l2v,
                     absoluteBar)

            bool upperInteraction =
                 high[off] >= topAtBar - historicalTouchTolerance and
                 low[off] <= topAtBar + historicalTouchTolerance and
                 close[off] <= topAtBar + historicalTouchTolerance

            bool lowerInteraction =
                 low[off] <= botAtBar + historicalTouchTolerance and
                 high[off] >= botAtBar - historicalTouchTolerance and
                 close[off] >= botAtBar - historicalTouchTolerance

            bool topSeparated =
                 na(lastTopOffset) or
                 math.abs(
                     off -
                     lastTopOffset) >=
                 touchCooldown

            bool botSeparated =
                 na(lastBotOffset) or
                 math.abs(
                     off -
                     lastBotOffset) >=
                 touchCooldown

            if upperInteraction and topSeparated
                topTouchCount += 1
                lastTopOffset := off

            if lowerInteraction and botSeparated
                botTouchCount += 1
                lastBotOffset := off

    float topTouchScore =
         math.min(
             100.0,
             topTouchCount /
             float(targetTouches) *
             100.0)

    float botTouchScore =
         math.min(
             100.0,
             botTouchCount /
             float(targetTouches) *
             100.0)

    touchQuality :=
         math.min(
             topTouchScore,
             botTouchScore)

    float reactionWeightCandidate =
         strengthWeight /
         100.0

    float geometryWeightCandidate =
         1.0 -
         reactionWeightCandidate

    finalQuality :=
         geometryQuality *
         geometryWeightCandidate +
         touchQuality *
         reactionWeightCandidate

    bool effectiveWidthOK =
         candidateWidth <=
         maxEffectiveWidthATR *
         candidateATR

    bool candidateOK =
         candidateTop > candidateBot and
         widthOK and
         effectiveWidthOK and
         geometryOK and
         finalQuality >= minQuality

    bool priceInsideCandidate =
         candidateOK and
         close >= candidateBot - brkMult * candidateATR and
         close <= candidateTop + brkMult * candidateATR

    if priceInsideCandidate

        bool differentChannel =
             not chOn or
             h1i != ah1i or
             h2i != ah2i or
             l1i != al1i or
             l2i != al2i

        if differentChannel

            chOn := true

            ah1i := h1i
            ah1v := h1v
            ah2i := h2i
            ah2v := h2v

            al1i := l1i
            al1v := l1v
            al2i := l2i
            al2v := l2v

            channelATR :=
                 candidateATR

            channelGeometryQuality :=
                 geometryQuality

            channelTouchQuality :=
                 touchQuality

            channelQuality :=
                 finalQuality

            channelTopTouches :=
                 topTouchCount

            channelBotTouches :=
                 botTouchCount

            channelID += 1
            channelStartBar := bar_index

            lastInteractionBar := bar_index
            lastTopTouchBar := na
            lastBotTouchBar := na

            downsideBreakCount := 0
            upsideBreakCount := 0

// ============================================================================
// RETIRE CURRENT CHANNEL
// ============================================================================

retireCurrent(bool broken) =>

    if not na(curTop)

        // ------------------------------------------------------------
        // IMPORTANT FIX:
        // Finished channels ALSO respect Visual Forward Extension.
        // ------------------------------------------------------------

        int originalX1 =
             line.get_x1(
                 curTop)

        int desiredEndX =
             bar_index +
             visualForwardBars

        // Total visual length remains capped.
        int maxAllowedEndX =
             originalX1 +
             maxVisualLength

        int endX =
             math.min(
                 desiredEndX,
                 maxAllowedEndX)

        // ------------------------------------------------------------
        // Prevent finished channels projecting into invalid prices.
        // ------------------------------------------------------------

        if preventNegativeProjection

            float projectedTop =
                 line.get_price(
                     curTop,
                     endX)

            float projectedBot =
                 line.get_price(
                     curBot,
                     endX)

            float priceFloor =
                 math.max(
                     syminfo.mintick,
                     close * 0.05)

            if projectedTop <= priceFloor or projectedBot <= priceFloor
                endX := bar_index

        float endTop =
             line.get_price(
                 curTop,
                 endX)

        float endBot =
             line.get_price(
                 curBot,
                 endX)

        line.set_xy2(
             curTop,
             endX,
             endTop)

        line.set_xy2(
             curBot,
             endX,
             endBot)

        line.set_style(
             curTop,
             broken ?
             line.style_dashed :
             line.style_dotted)

        line.set_style(
             curBot,
             broken ?
             line.style_dashed :
             line.style_dotted)

        if not na(curFill)
            linefill.delete(
                 curFill)

        if showHist

            array.push(
                 oldTops,
                 curTop)

            array.push(
                 oldBots,
                 curBot)

            if array.size(oldTops) > maxHist

                line.delete(
                     array.shift(
                         oldTops))

                line.delete(
                     array.shift(
                         oldBots))

        else

            line.delete(
                 curTop)

            line.delete(
                 curBot)

// ============================================================================
// DRAW ACTIVE CHANNEL
// ============================================================================

if chOn

    float drawTop =
         isRange ?
         math.max(
             ah1v,
             ah2v) :
         lineAt(
             ah1i,
             ah1v,
             ah2i,
             ah2v,
             bar_index)

    float drawBot =
         isRange ?
         math.min(
             al1v,
             al2v) :
         lineAt(
             al1i,
             al1v,
             al2i,
             al2v,
             bar_index)

    bool newDrawStructure =
         na(curTop) or
         ah1i != drawH1 or
         ah2i != drawH2 or
         al1i != drawL1 or
         al2i != drawL2

    int structuralStart =
         math.min(
             math.min(
                 ah1i,
                 ah2i),
             math.min(
                 al1i,
                 al2i))

    int visualStart =
         math.max(
             structuralStart,
             bar_index -
             maxVisualLength)

    int safeX2 =
         bar_index +
         visualForwardBars

    // Do not exceed maximum total visual length.
    safeX2 :=
         math.min(
             safeX2,
             visualStart +
             maxVisualLength)

    // ========================================================================
    // PREVENT INVALID NEGATIVE PROJECTION
    // ========================================================================

    if not isRange and preventNegativeProjection

        float highSlope =
             (ah2v - ah1v) /
             math.max(
                 ah2i - ah1i,
                 1)

        float lowSlope =
             (al2v - al1v) /
             math.max(
                 al2i - al1i,
                 1)

        float priceFloor =
             math.max(
                 syminfo.mintick,
                 close * 0.05)

        if highSlope < 0

            float barsToFloorTop =
                 (priceFloor - drawTop) /
                 highSlope

            if barsToFloorTop > 0

                int topFloorX =
                     bar_index +
                     int(
                         math.floor(
                             barsToFloorTop))

                safeX2 :=
                     math.min(
                         safeX2,
                         topFloorX)

        if lowSlope < 0

            float barsToFloorBot =
                 (priceFloor - drawBot) /
                 lowSlope

            if barsToFloorBot > 0

                int botFloorX =
                     bar_index +
                     int(
                         math.floor(
                             barsToFloorBot))

                safeX2 :=
                     math.min(
                         safeX2,
                         botFloorX)

        safeX2 :=
             math.max(
                 bar_index,
                 safeX2)

    // ========================================================================
    // CREATE
    // ========================================================================

    if newDrawStructure

        retireCurrent(false)

        float topStart =
             isRange ?
             drawTop :
             lineAt(
                 ah1i,
                 ah1v,
                 ah2i,
                 ah2v,
                 visualStart)

        float botStart =
             isRange ?
             drawBot :
             lineAt(
                 al1i,
                 al1v,
                 al2i,
                 al2v,
                 visualStart)

        float topEnd =
             isRange ?
             drawTop :
             lineAt(
                 ah1i,
                 ah1v,
                 ah2i,
                 ah2v,
                 safeX2)

        float botEnd =
             isRange ?
             drawBot :
             lineAt(
                 al1i,
                 al1v,
                 al2i,
                 al2v,
                 safeX2)

        curTop :=
             line.new(
                 visualStart,
                 topStart,
                 safeX2,
                 topEnd,
                 color = colTop,
                 width = lineW)

        curBot :=
             line.new(
                 visualStart,
                 botStart,
                 safeX2,
                 botEnd,
                 color = colBot,
                 width = lineW)

        curFill :=
             linefill.new(
                 curTop,
                 curBot,
                 colFill)

        drawH1 := ah1i
        drawH2 := ah2i
        drawL1 := al1i
        drawL2 := al2i

    // ========================================================================
    // UPDATE
    // ========================================================================

    else

        float topEnd =
             isRange ?
             drawTop :
             lineAt(
                 ah1i,
                 ah1v,
                 ah2i,
                 ah2v,
                 safeX2)

        float botEnd =
             isRange ?
             drawBot :
             lineAt(
                 al1i,
                 al1v,
                 al2i,
                 al2v,
                 safeX2)

        line.set_xy2(
             curTop,
             safeX2,
             topEnd)

        line.set_xy2(
             curBot,
             safeX2,
             botEnd)

// ============================================================================
// CHANNEL FINISHED
// ============================================================================

else if not na(curTop)

    bool justBroken =
         breakBar ==
         bar_index

    retireCurrent(
         justBroken)

    curTop := na
    curBot := na
    curFill := na

    drawH1 := na
    drawH2 := na
    drawL1 := na
    drawL2 := na

// ============================================================================
// SIGNAL MARKERS
// ============================================================================

plotshape(
     showMarks and buySig,
     title = "BUY",
     style = shape.triangleup,
     location = location.belowbar,
     color = colBot,
     text = "BUY",
     textcolor = colBot,
     size = size.small)

plotshape(
     showMarks and sellSig,
     title = "SELL",
     style = shape.triangledown,
     location = location.abovebar,
     color = colTop,
     text = "SELL",
     textcolor = colTop,
     size = size.small)

plotshape(
     showMarks and brkSig,
     title = "BREAK",
     style = shape.xcross,
     location = location.belowbar,
     color = color.new(#E0A030, 0),
     text = "BREAK",
     textcolor = color.new(#E0A030, 0),
     size = size.small)

// ============================================================================
// ALERTS
// ============================================================================

if useHook

    if buySig
        alert(
             buyMsg,
             alert.freq_once_per_bar)

    if sellSig
        alert(
             sellMsg,
             alert.freq_once_per_bar)

    if brkSig
        alert(
             brkMsg,
             alert.freq_once_per_bar_close)

alertcondition(
     buySig,
     "ACR BUY",
     "Confirmed lower channel reaction - BUY")

alertcondition(
     sellSig,
     "ACR SELL",
     "Upper channel reaction / breakout failure - SELL")

alertcondition(
     brkSig,
     "ACR BREAK",
     "Confirmed downside channel break - EXIT")
````
