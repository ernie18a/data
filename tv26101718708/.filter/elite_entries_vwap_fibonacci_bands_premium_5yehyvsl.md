# Elite Entries VWAP Fibonacci Bands Premium

- url: https://www.tradingview.com/script/5YEHyvSL-Elite-Entries-VWAP-Fibonacci-Bands-Premium/
- type: indicator
- pine_id: PUB;4bf4e772949e4526a8ffc9b07d9b5c28
- version: 1.0

## Description

**Elite Entries VWAP Fibonacci Bands Premium**

Elite Entries VWAP Fibonacci Bands Premium is an overlay indicator that combines anchored VWAP, volatility-based Fibonacci bands, 23.6 reaction zones, optional breakout filters, and shared trailing-stop tools.

The workflow connects three decisions: where price is trading relative to volume-weighted value, how price responds at a defined zone, and how an accepted signal is managed afterward.

**Acknowledgment**

Credit to **Zimmermann Trading** for inspiring the code and the development of this indicator. That inspiration is acknowledged with appreciation. This acknowledgment does not imply affiliation or endorsement.

**VWAP and Fibonacci Framework**

The central VWAP accumulates typical price, weighted by volume, from a selected timeframe reset or date anchor.

The outer bands use volume-weighted population standard deviation multiplied by a configurable factor. Intermediate bands divide that distance using five configurable ratios, defaulting to:

0.236, 0.382, 0.500, 0.618, and 0.786.

These are ratios within a volatility-based envelope rather than retracements drawn between a selected swing high and swing low. The bands develop as new price and volume data arrive.

**23.6 Reaction Zones**

Two boundaries surround each fixed 23.6 band. Their half-width can use ATR or a specified number of minimum ticks. The reaction zones remain anchored to 0.236 even when the other Fibonacci ratios are customized.

Four optional signal types describe price behavior at these zones:

- **Hold:** Price tests a zone and closes within the permitted defense boundary. Conservative, Balanced, and Aggressive sensitivity settings change the required approach and closing position.
- **Reject:** Price approaches from outside the zone, touches it, and closes on the defended side of its core with matching candle direction.
- **BK+RT:** A close beyond an outer boundary arms a potential return across the zone’s core within the selected bar window. This label represents the break-and-reclaim condition.
- **Accept:** Price meets the required number of consecutive closes beyond an outer boundary after a fresh break. The break candle counts toward the total; a setting of one permits acceptance on that candle.

Reaction signals share a cooldown. When several conditions qualify, priority is BK+RT, Reject, Hold, then Accept. Labels identify the accepted condition without displaying projected targets.

**Breakout Signals and Context Filters**

Optional BRK signals identify confirmed chart-bar closes across enabled VWAP or Fibonacci levels. Crossings caused solely by an anchor reset are excluded.

Breakouts can be filtered using:

- A configurable fast/slow moving-average cloud.
- Multi-timeframe Gann HiLo direction and price position.
- Selected New York, London, or Asian session VWAPs.

These filters apply to BRK signals. The 23.6 reaction signals use their own zone conditions.

The moving-average choices include EMA, SMA, WMA, HMA, RMA, T3, and HEMA. HEMA uses Heikin Ashi closes as its trend input. Session times and timezone are configurable; the default timezone is America/New_York.

**Risk Management Tools**

All accepted signal types can start one shared ATR-based or tick-based trailing stop.

The trail initializes from the standard candle’s confirmed close, including when the chart uses Heikin Ashi candles. Repeated same-direction signals do not reset the original entry.

The stop is evaluated against the standard candle close:

- A long trail ends when a later confirmed candle closes strictly below the previous stop.
- A short trail ends when a later confirmed candle closes strictly above the previous stop.
- Wick breaches and closes exactly on the stop keep the trail active.

The previous stop is checked before calculating the next trailing level. The stop can tighten but does not loosen as ATR changes.

Active-trade gating is enabled by default. While a trail is active, it blocks all new accepted signals and their alerts. A stop-exit candle cannot immediately start another trail.

These are calculated chart references. The indicator does not submit broker orders, track actual account positions, or guarantee execution at a displayed stop.

**Getting Started**

1. Select the VWAP anchor and verify the session timezone.
2. Choose the 23.6 zone width using ATR or ticks.
3. Enable the individual reaction signals you want to display.
4. Enable BRK separately if desired, then select any breakout filters.
5. Configure the shared risk tools and chart appearance.

The reaction-zone master switch is enabled by default, but Hold, Reject, BK+RT, and Accept are individually disabled. The master BREAK switch is also disabled. Enable the desired signal types before expecting signal labels.

Current defaults include a 14-period zone ATR with a 0.5 half-width multiplier, a five-bar reclaim window, one-close acceptance, and a three-bar cooldown. Risk management defaults to ATR 14 with a 1.5 multiplier. The alternative tick-distance settings default to 40 ticks.

**Confirmation, Timeframes, and Alerts**

BRK signals require chart-bar confirmation. When risk management is enabled, reaction signals also require confirmation, even if their separate confirmation checkbox is unchecked.

With risk management and reaction confirmation both disabled, reaction signals can appear provisionally during an open candle and disappear before close or after reload.

Higher-timeframe MA and Gann values use the preceding completed requested candle. Lower-timeframe calculations sample the last available intrabar; they do not reconstruct every intrabar event.

Signal alerts are disabled by default. Enable the desired signal and its alert switch, then create a TradingView alert using “Any alert() function call.” Recreate alerts after changing the script or its settings.

**Use and Limitations**

Use standard time-based candles for the publication chart and signal evaluation. Although risk calculations request standard prices, Heikin Ashi chart prices still affect the band and signal calculations.

Results depend on available history, usable volume, timeframe selection, and data revisions. Developing levels can move while a candle is open. No universal non-repainting, signal-accuracy, or profitability claim is made.

## Source Code

````pine
//@version=6
indicator("Elite Entries VWAP Fibonacci Bands Premium", overlay=true, max_lines_count=500, max_labels_count=500)

const string GA = "01 - VWAP & Fibonacci Framework"
anchorMode = input.string("Timeframe", "Anchor Method", options=["Timeframe", "Date"], group=GA)
anchorTf = input.timeframe("D", "Anchor Timeframe", group=GA, tooltip="Reset period must be at least the chart timeframe.")
anchorAt = input.time(timestamp("01 Jan 2025 00:00 UTC"), "Anchor Date", group=GA, tooltip="Starts on the first available bar at or after this timestamp; unavailable earlier history cannot be recovered.")
deviationScale = input.float(3.0, "Std Dev Multiplier", minval=0.1, step=0.1, group=GA, tooltip="Outer-band distance is this factor times volume-weighted population standard deviation of typical price.")
ratioText = input.string("0.236,0.382,0.5,0.618,0.786", "Fib Levels (comma-separated)", group=GA, tooltip="Five increasing positive ratios. The 23.6 reaction zones always use 0.236, independently of these ratios. Labels and alerts show actual ratios.")

const string GS = "02 - Session Context"
sessionSource = input.source(hlc3, "Session VWAP Source", group=GS)
sessionZone = input.string("America/New_York", "Session Time Zone", group=GS, tooltip="An IANA timezone follows its daylight-saving rules.")
nyWindow = input.session("0930-1600", "New York Session", group=GS)
londonWindow = input.session("0300-0600", "London Session", group=GS)
asiaWindow = input.session("2000-0000", "Asian / Tokyo Session", group=GS)
sessionFilter = input.bool(false, "Use Session VWAPs as BREAK Filter", group=GS, tooltip="BRK only. The 23.6 reaction signals use their own conditions.")
selectNy = input.bool(false, "Filter BRKs with New York VWAP", group=GS)
selectLondon = input.bool(false, "Filter BRKs with London VWAP", group=GS)
selectAsia = input.bool(false, "Filter BRKs with Asian VWAP", group=GS)
sessionRule = input.string("All Selected", "Multiple VWAP Rule", options=["All Selected", "Any Selected"], group=GS, tooltip="All requires every selected VWAP to be available and passed. Any requires one pass. No selections bypasses the filter.")

const string GM = "03 - Trend & Direction Filters"
cloudFilterInput = input.bool(false, "Use MA Cloud as a FILTER", group=GM, tooltip="BRK only. Requires cloud direction and price beyond both MAs.")
maSource = input.source(close, "Cloud Source", group=GM)
fastKindInput = input.string("EMA", "Fast MA Type", options=["EMA", "SMA", "WMA", "HMA", "RMA", "T3", "HEMA"], group=GM)
fastLengthInput = input.int(9, "Fast MA Length", minval=1, group=GM)
fastTfInput = input.timeframe("", "Fast MA Timeframe", group=GM, tooltip="Blank = chart; higher = preceding completed candle; lower = last available intrabar.")
fastT3Input = input.float(0.70, "Fast T3 Factor", minval=0, maxval=1, step=0.05, group=GM)
slowKindInput = input.string("EMA", "Slow MA Type", options=["EMA", "SMA", "WMA", "HMA", "RMA", "T3", "HEMA"], group=GM)
slowLengthInput = input.int(50, "Slow MA Length", minval=1, group=GM)
slowTfInput = input.timeframe("15", "Slow MA Timeframe", group=GM, tooltip="Blank = chart; higher = preceding completed candle; lower = last available intrabar.")
slowT3Input = input.float(0.70, "Slow T3 Factor", minval=0, maxval=1, step=0.05, group=GM)
gannFilter = input.bool(false, "Use Gann High Low as FILTER", group=GM)
gannTfInput = input.timeframe("2", "Gann Timeframe", group=GM, tooltip="Same confirmation/final-intrabar rules as the MA inputs.")
gannHighLength = input.int(10, "Gann HIGH Period", minval=1, group=GM)
gannLowLength = input.int(10, "Gann LOW Period", minval=1, group=GM)

const string GE = "04 - 23.6 Reaction Zone"
reactionEnabled = input.bool(false, "Enable 23.6 Reaction Zone Signals", group=GE)
zoneWidthMode = input.string("ATR", "23.6 Zone Width Mode", options=["ATR", "Ticks"], group=GE)
zoneAtrLength = input.int(14, "23.6 Zone ATR Length", minval=1, group=GE)
zoneAtrFactor = input.float(0.15, "ATR Half-Width Multiplier", minval=0.01, step=0.01, group=GE)
zoneHalfTicks = input.int(16, "23.6 Zone Half-Width Ticks", minval=1, group=GE)
reactionConfirmed = input.bool(true, "Confirm 23.6 Zone Signals on Candle Close", group=GE, tooltip="OFF allows provisional intrabar labels/alerts. Risk management forces candle-close confirmation for every signal.")
holdEnabled = input.bool(false, "Signal: HOLD", group=GE, tooltip="Approach and permitted closing position define zone defense; candle color is irrelevant.")
holdMode = input.string("Balanced", "HOLD Sensitivity", options=["Conservative", "Balanced", "Aggressive"], group=GE, tooltip="Conservative: outside approach and core-side close. Balanced: outside approach and preserve far edge. Aggressive: core-side approach and preserve far edge.")
rejectEnabled = input.bool(false, "Signal: 23.6 Zone Rejections", group=GE, tooltip="Outside approach, touch, same-side core close, and matching candle direction.")
reclaimEnabled = input.bool(false, "Signal: Break + Reclaim", group=GE, tooltip="A boundary break arms a return across the core on a later bar within the window.")
reclaimBars = input.int(20, "Break + Reclaim Window (bars)", minval=1, maxval=200, group=GE)
acceptEnabled = input.bool(false, "Signal: 23.6 Zone Acceptance", group=GE)
acceptCloses = input.int(2, "Acceptance Consecutive Closes", minval=1, maxval=5, group=GE, tooltip="Consecutive closes beyond a fresh boundary break; includes the break bar.")
reactionCooldown = input.int(3, "Signal Cooldown (bars)", minval=0, maxval=100, group=GE, tooltip="Accepted reaction signals must be more than this many bars apart.")
reactionAlerts = input.bool(false, "Enable 23.6 Reaction Signal Alerts", group=GE)

const string GB = "05 - Breakout Signals"
breakEnabled = input.bool(false, "Enable BREAK signals", group=GB)
breakCenter = input.bool(false, "Use VWAP Central Level", group=GB)
breakBands = input.bool(false, "Use Fib Bands", group=GB)
breakUpper = input.bool(false, "Signal on Upper Fib Bands", group=GB)
breakLower = input.bool(false, "Signal on Lower Fib Bands", group=GB)
breakAlerts = input.bool(false, "Enable BRK Alerts", group=GB, tooltip="Alerts only for accepted breakout signals. Active-trade gating also blocks these alerts.")

const string GT = "06 - Risk Management Tools"
trailEnabled = input.bool(true, "Enable Risk Management for All Signals", group=GT, tooltip="BRK, HOLD, REJECT, RECLAIM/FAIL, and ACCEPT can start one shared ATR/tick trail from confirmed standard close. Exit only when a later standard candle closes strictly below the prior long stop or above the prior short stop. Wick breaches and equal closes keep it active. Calculated reference, not an order.")
trailMode = input.string("ATR", "TSL Mode", options=["ATR", "Ticks"], group=GT)
trailAtrLength = input.int(14, "ATR Period", minval=1, group=GT)
trailAtrFactor = input.float(1.5, "ATR Factor", minval=0.1, step=0.1, group=GT)
trailTicks = input.int(50, "Tick TSL Distance", minval=1, group=GT)
trailGate = input.bool(true, "Block All New Signals While Trail Is Active", group=GT, tooltip="When enabled, blocks every new signal and its alert until the active trail ends. OFF allows opposite-direction replacement; same-direction events do not reset entry. Exit bars never restart a trail.")

const string GD = "07 - Chart Appearance"
drawNy = input.bool(true, "Show New York Session VWAP", group=GD)
drawLondon = input.bool(false, "Show London Session VWAP", group=GD)
drawAsia = input.bool(false, "Show Asian Session VWAP", group=GD)
extendSessions = input.bool(true, "Extend Completed Session VWAP", group=GD, tooltip="Extends final session values visually; BRK filters use accumulated values regardless of visibility.")
nyColor = input.color(color.yellow, "New York VWAP Color", group=GD)
londonColor = input.color(color.rgb(64, 128, 255), "London VWAP Color", group=GD)
asiaColor = input.color(color.rgb(128, 0, 192), "Asian VWAP Color", group=GD)
sessionWidth = input.int(2, "Session VWAP Width", minval=1, maxval=5, group=GD)
ratioPercent = input.bool(false, "Show Fib Label as %", group=GD)
ratioColor1 = input.color(color.new(color.rgb(64, 128, 255), 40), "Ratio 1 Color", group=GD)
ratioColor2 = input.color(color.new(color.rgb(128, 0, 192), 40), "Ratio 2 Color", group=GD)
ratioColor3 = input.color(color.new(color.white, 40), "Ratio 3 Color", group=GD)
ratioColor4 = input.color(color.new(color.rgb(0, 255, 213), 40), "Ratio 4 Color", group=GD)
ratioColor5 = input.color(color.new(color.rgb(255, 51, 204), 40), "Ratio 5 Color", group=GD)
labelRatio1 = input.bool(true, "Show Label Ratio 1", group=GD)
labelRatio2 = input.bool(true, "Show Label Ratio 2", group=GD)
labelRatio3 = input.bool(true, "Show Label Ratio 3", group=GD)
labelRatio4 = input.bool(true, "Show Label Ratio 4", group=GD)
labelRatio5 = input.bool(true, "Show Label Ratio 5", group=GD)
drawZones = input.bool(true, "Show Dynamic 23.6 Reaction Zone Lines", group=GD, tooltip="Two boundaries around each fixed 0.236 band, independent of custom Fibonacci ratios. No fill.")
drawCore = input.bool(true, "Show 23.6 Reaction Core Lines", group=GD)
zoneHistory = input.int(100, "Zone Line History Bars", minval=10, maxval=120, group=GD, tooltip="Four segments per bar; at most 480 retained lines.")
zoneStroke = input.int(1, "Zone Boundary Line Width", minval=1, maxval=4, group=GD)
zoneStrokeStyle = input.string("Solid", "Zone Boundary Line Style", options=["Solid", "Dashed", "Dotted"], group=GD)
zoneFade = input.int(15, "Zone Boundary Transparency", minval=0, maxval=100, group=GD)
reactionLabels = input.bool(true, "Show 23.6 Reaction Signal Labels", group=GD)
reactionSize = input.string("Small", "23.6 Reaction Signal Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group=GD)
drawCloud = input.bool(true, "Show MA Cloud Fill", group=GD)
drawMaLines = input.bool(false, "Show MA Fast/Slow Lines", group=GD)
drawGann = input.bool(false, "Plot Gann High Low", group=GD)
gannBullColor = input.color(color.rgb(0, 255, 213), "Bullish Gann Color", group=GD)
gannBearColor = input.color(color.rgb(255, 51, 204), "Bearish Gann Color", group=GD)
gannStroke = input.int(2, "Gann Width", minval=1, maxval=5, group=GD)
tagLevels = input.bool(false, "Print Level Tag Labels", group=GD)
minimalDisplay = input.bool(false, "Signal-Only Mode", group=GD)
centerInMinimal = input.bool(true, "Show Centerline in Signal-Only Mode", group=GD)
drawBandFill = input.bool(true, "Show Background Fill Colors", group=GD)
allowCloudFill = input.bool(true, "Allow MA Cloud Fill Color", group=GD)
bullColor = input.color(color.rgb(0, 255, 213), "Upper Band Color", group=GD)
centerColor = input.color(color.white, "VWAP Color", group=GD)
bearColor = input.color(color.rgb(255, 51, 204), "Lower Band Color", group=GD)
cloudCandles = input.bool(false, "Color Candles by Cloud Direction", group=GD)

// Explicit state objects separate accumulation, setup memory, and trade state.
type WeightedState
    float weight = 0.0
    float mean = na
    float centeredSum = 0.0

method clear(WeightedState self) =>
    self.weight := 0.0
    self.mean := na
    self.centeredSum := 0.0

// Weighted Welford: update the centered second moment without subtracting
// two large squared-price totals.
method accumulate(WeightedState self, float sample, float weight) =>
    if not na(sample) and not na(weight) and weight > 0
        float oldMean = self.weight > 0 ? self.mean : sample
        float newWeight = self.weight + weight
        float shift = sample - oldMean
        float newMean = oldMean + shift * weight / newWeight
        self.centeredSum += weight * shift * (sample - newMean)
        self.mean := newMean
        self.weight := newWeight
    self.mean

type SessionState
    WeightedState samples
    int cycle = na

method evaluate(SessionState self, simple string window, simple string zone, float sample) =>
    bool inside = not na(time(timeframe.period, window, zone))
    int startHour = int(str.tonumber(str.substring(window, 0, 2)))
    int startMinute = int(str.tonumber(str.substring(window, 2, 4)))
    int todayStart = timestamp(zone, year(time, zone), month(time, zone), dayofmonth(time, zone), startHour, startMinute)
    // Local noon minus 24 hours identifies the previous calendar date across
    // DST changes without passing an out-of-range day into timestamp().
    int previousDate = timestamp(zone, year(time, zone), month(time, zone), dayofmonth(time, zone), 12, 0) - 86400000
    int previousStart = timestamp(zone, year(previousDate, zone), month(previousDate, zone), dayofmonth(previousDate, zone), startHour, startMinute)
    int key = time >= todayStart ? todayStart : previousStart
    if inside
        if na(self.cycle) or key != self.cycle
            self.samples.clear()
            self.cycle := key
        self.samples.accumulate(sample, volume)
    [self.samples.mean, inside]

// Three generalized double-EMA stages give the classic T3 formula.
generalizedEma(float source, simple int length, simple float factor) =>
    float first = ta.ema(source, length)
    float second = ta.ema(first, length)
    (1 + factor) * first - factor * second

averageValue(float source, simple int length, simple string kind, simple float factor) =>
    switch kind
        "SMA" => ta.sma(source, length)
        "WMA" => ta.wma(source, length)
        "HMA" => ta.hma(source, length)
        "RMA" => ta.rma(source, length)
        "T3" => generalizedEma(generalizedEma(generalizedEma(source, length, factor), length, factor), length, factor)
        => ta.ema(source, length)

requestedAverage(float source, simple int length, simple string kind, simple string requestedTf, simple float factor) =>
    string resolved = requestedTf == "" ? timeframe.period : requestedTf
    string symbol = kind == "HEMA" ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid
    float answer = na
    if timeframe.in_seconds(resolved) > timeframe.in_seconds()
        if kind == "HEMA"
            answer := request.security(symbol, resolved, ta.ema(close, length)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
        else
            answer := request.security(symbol, resolved, averageValue(source, length, kind, factor)[1], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
    else if timeframe.in_seconds(resolved) < timeframe.in_seconds()
        if kind == "HEMA"
            array<float> samples = request.security_lower_tf(symbol, resolved, ta.ema(close, length))
            answer := samples.size() > 0 ? samples.last() : na
        else
            array<float> samples = request.security_lower_tf(symbol, resolved, averageValue(source, length, kind, factor))
            answer := samples.size() > 0 ? samples.last() : na
    else if kind == "HEMA"
        answer := request.security(symbol, resolved, ta.ema(close, length), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
    else
        answer := averageValue(source, length, kind, factor)
    answer

gannValue(simple int highLength, simple int lowLength) =>
    float ceiling = ta.sma(high, highLength)
    float floor = ta.sma(low, lowLength)
    var int direction = 1
    if not na(ceiling[1]) and not na(floor[1])
        if close > ceiling[1]
            direction := 1
        else if close < floor[1]
            direction := -1
    [direction == 1 ? floor : ceiling, direction]

completedGann(simple int highLength, simple int lowLength) =>
    [level, direction] = gannValue(highLength, lowLength)
    [level[1], direction[1]]

requestedGann(simple string requestedTf, simple int highLength, simple int lowLength) =>
    string resolved = requestedTf == "" ? timeframe.period : requestedTf
    float answer = na
    int direction = na
    if timeframe.in_seconds(resolved) > timeframe.in_seconds()
        [level, state] = request.security(syminfo.tickerid, resolved, completedGann(highLength, lowLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_on)
        answer := level
        direction := state
    else if timeframe.in_seconds(resolved) < timeframe.in_seconds()
        [levels, states] = request.security_lower_tf(syminfo.tickerid, resolved, gannValue(highLength, lowLength))
        if levels.size() > 0
            answer := levels.last()
            direction := states.last()
    else
        [level, state] = gannValue(highLength, lowLength)
        answer := level
        direction := state
    [answer, direction]

ratioName(float ratio) =>
    str.tostring(ratio, "0.###")

type ReactionState
    float priorCore = na
    float priorTop = na
    float priorBottom = na
    int reclaimDirection = 0
    int breakBar = na
    int acceptanceDirection = 0
    int outsideCloses = 0

method forget(ReactionState self) =>
    self.reclaimDirection := 0
    self.breakBar := na
    self.acceptanceDirection := 0
    self.outsideCloses := 0

// Candidate priority: 1 reclaim, 2 rejection, 3 hold, 4 acceptance.
// Acceptance and reclaim permissions are consumed only by selected events.
method inspect(ReactionState self, float core, float halfWidth, bool reset, bool enabled) =>
    float top = core + halfWidth
    float bottom = core - halfWidth
    bool historyReady = not reset and not na(core) and not na(self.priorCore) and not na(close[1])
    int eventKind = 0
    int direction = 0
    if not historyReady or not enabled
        self.forget()
    else
        // Snapshot prior reclaim permission before a new opposite-edge break
        // can arm its replacement on this same candle.
        int priorReclaim = self.reclaimDirection
        int priorBreakBar = self.breakBar
        bool priorReclaimValid = priorReclaim != 0 and bar_index > priorBreakBar and bar_index - priorBreakBar <= reclaimBars
        bool brokeUp = close > top and close[1] <= self.priorTop
        bool brokeDown = close < bottom and close[1] >= self.priorBottom
        if brokeUp or brokeDown
            self.reclaimDirection := brokeUp ? -1 : 1
            self.breakBar := bar_index
            self.acceptanceDirection := brokeUp ? 1 : -1
            self.outsideCloses := 1
        else if self.acceptanceDirection != 0
            bool staysOutside = self.acceptanceDirection == 1 ? close > top : close < bottom
            self.outsideCloses := staysOutside ? self.outsideCloses + 1 : 0
            if not staysOutside
                self.acceptanceDirection := 0
        if self.reclaimDirection != 0 and bar_index - self.breakBar > reclaimBars
            self.reclaimDirection := 0
        bool crossUp = close > core and close[1] <= self.priorCore
        bool crossDown = close < core and close[1] >= self.priorCore
        bool reclaimUp = priorReclaimValid and priorReclaim == 1 and crossUp
        bool reclaimDown = priorReclaimValid and priorReclaim == -1 and crossDown
        bool touch = low <= top and high >= bottom
        bool fromAbove = close[1] > self.priorTop
        bool fromBelow = close[1] < self.priorBottom
        bool rejectUp = touch and fromAbove and close > core and close > open
        bool rejectDown = touch and fromBelow and close < core and close < open
        bool holdUp = touch and (holdMode == "Aggressive" ? close[1] >= self.priorCore : fromAbove) and (holdMode == "Conservative" ? close >= core : close >= bottom)
        bool holdDown = touch and (holdMode == "Aggressive" ? close[1] <= self.priorCore : fromBelow) and (holdMode == "Conservative" ? close <= core : close <= top)
        if reclaimEnabled and (reclaimUp or reclaimDown)
            eventKind := 1
            direction := reclaimUp ? 1 : -1
        else if rejectEnabled and (rejectUp or rejectDown)
            eventKind := 2
            direction := rejectUp ? 1 : -1
        else if holdEnabled and (holdUp != holdDown)
            eventKind := 3
            direction := holdUp ? 1 : -1
        else if acceptEnabled and self.acceptanceDirection != 0 and self.outsideCloses >= acceptCloses
            eventKind := 4
            direction := self.acceptanceDirection
    self.priorCore := core
    self.priorTop := top
    self.priorBottom := bottom
    [eventKind, direction]

method consume(ReactionState self, int kind) =>
    if kind == 1
        self.reclaimDirection := 0
        self.acceptanceDirection := 0
        self.outsideCloses := 0
    else if kind == 4
        self.forget()

type TrailState
    int direction = 0
    float entry = na
    int entryBar = na
    float stop = na

method endTrade(TrailState self) =>
    self.direction := 0
    self.entry := na
    self.entryBar := na
    self.stop := na

method beginTrade(TrailState self, int direction, float entry, float distance) =>
    self.direction := direction
    self.entry := entry
    self.entryBar := bar_index
    self.stop := math.round_to_mintick(entry - direction * distance)

// Data acquisition is separate from candidates, accepted events, and visuals.
float fastMa = requestedAverage(maSource, fastLengthInput, fastKindInput, fastTfInput, fastT3Input)
float slowMa = requestedAverage(maSource, slowLengthInput, slowKindInput, slowTfInput, slowT3Input)
[gannLevel, gannDirection] = requestedGann(gannTfInput, gannHighLength, gannLowLength)
string standardTicker = ticker.new(syminfo.prefix, syminfo.ticker, syminfo.session)
[standardClose, standardAtr] = request.security(standardTicker, timeframe.period, [close, ta.atr(trailAtrLength)], gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
float rawDistance = trailMode == "Ticks" ? trailTicks * syminfo.mintick : standardAtr * trailAtrFactor
float distance = not na(rawDistance) ? math.max(syminfo.mintick, rawDistance) : na
bool riskReady = not na(standardClose) and not na(distance) and distance > 0
float chartZoneAtr = ta.atr(zoneAtrLength)
float halfWidth = zoneWidthMode == "Ticks" ? zoneHalfTicks * syminfo.mintick : chartZoneAtr * zoneAtrFactor
halfWidth := not na(halfWidth) ? math.max(syminfo.mintick, halfWidth) : na

if barstate.isfirst
    if anchorMode == "Timeframe" and timeframe.in_seconds(anchorTf) < timeframe.in_seconds()
        runtime.error("The reset timeframe must be at least the chart timeframe.")
    if not chart.is_standard and not chart.is_heikinashi
        runtime.error("Use a standard time-based chart or Heikin Ashi. Other synthetic bar mappings are unsupported.")

var array<float> ratios = array.new<float>()
if barstate.isfirst
    array<string> tokens = str.split(str.replace_all(ratioText, " ", ""), ",")
    if tokens.size() != 5
        runtime.error("Enter exactly five increasing positive Fibonacci ratios.")
    float previous = 0
    for token in tokens
        float value = str.tonumber(token)
        if na(value) or value <= previous
            runtime.error("Fibonacci ratios must be numeric, positive, and strictly increasing.")
        ratios.push(value)
        previous := value

var WeightedState anchored = WeightedState.new()
bool anchorBoundary = timeframe.change(anchorTf)
bool collecting = anchorMode == "Timeframe" or time >= anchorAt
bool anchorReset = anchorMode == "Timeframe" ? (barstate.isfirst or anchorBoundary) : (collecting and (barstate.isfirst or time[1] < anchorAt))
if anchorReset
    anchored.clear()
if collecting
    anchored.accumulate(hlc3, volume)
float center = anchored.mean
float spread = anchored.weight > 0 ? deviationScale * math.sqrt(math.max(0, anchored.centeredSum / anchored.weight)) : na
bool bandsReady = not na(center) and not na(spread) and spread > 0
float upper236 = bandsReady ? center + spread * 0.236 : na
float lower236 = bandsReady ? center - spread * 0.236 : na
array<float> upper = array.new<float>(5, na)
array<float> lower = array.new<float>(5, na)
for slot = 0 to 4
    upper.set(slot, bandsReady ? center + spread * ratios.get(slot) : na)
    lower.set(slot, bandsReady ? center - spread * ratios.get(slot) : na)

var SessionState ny = SessionState.new(WeightedState.new())
var SessionState london = SessionState.new(WeightedState.new())
var SessionState asia = SessionState.new(WeightedState.new())
[nyVwap, insideNy] = ny.evaluate(nyWindow, sessionZone, sessionSource)
[londonVwap, insideLondon] = london.evaluate(londonWindow, sessionZone, sessionSource)
[asiaVwap, insideAsia] = asia.evaluate(asiaWindow, sessionZone, sessionSource)

// Test the confirmed standard close against the prior stop before ratcheting.
// Wick breaches and equality do not exit; the entry bar cannot stop itself out.
var TrailState trade = TrailState.new()
int heldDirection = trailEnabled ? trade.direction : 0
bool tradeAtOpen = heldDirection != 0
bool stopped = false
if not trailEnabled
    trade.endTrade()
else if barstate.isconfirmed and tradeAtOpen and bar_index > trade.entryBar
    stopped := heldDirection == 1 ? standardClose < trade.stop : standardClose > trade.stop
    if stopped
        trade.endTrade()
    else if riskReady
        float nextStop = math.round_to_mintick(standardClose - heldDirection * distance)
        trade.stop := heldDirection == 1 ? math.max(trade.stop, nextStop) : math.min(trade.stop, nextStop)

bool tradeLocked = trailGate and tradeAtOpen
bool managedSignals = trailEnabled
bool reactionClosePass = barstate.isconfirmed or (not reactionConfirmed and not managedSignals)
bool reactionAllowed = reactionEnabled and not tradeLocked and not stopped and bandsReady and not na(halfWidth)
var ReactionState upperMemory = ReactionState.new()
var ReactionState lowerMemory = ReactionState.new()
[upperKind, upperDirection] = upperMemory.inspect(upper236, halfWidth, anchorReset, reactionAllowed)
[lowerKind, lowerDirection] = lowerMemory.inspect(lower236, halfWidth, anchorReset, reactionAllowed)
bool chooseUpper = upperKind != 0 and (lowerKind == 0 or upperKind <= lowerKind)
int reactionKind = chooseUpper ? upperKind : lowerKind
int reactionDirection = chooseUpper ? upperDirection : lowerDirection
var int lastReactionBar = na
bool cooldownPass = na(lastReactionBar) or bar_index - lastReactionBar > reactionCooldown
if not reactionClosePass or not cooldownPass or (managedSignals and not riskReady)
    reactionKind := 0
    reactionDirection := 0

bool cloudBull = not na(fastMa) and not na(slowMa) and fastMa > slowMa
bool cloudBear = not na(fastMa) and not na(slowMa) and fastMa < slowMa
bool fullBull = cloudBull and close > fastMa and close > slowMa
bool fullBear = cloudBear and close < fastMa and close < slowMa
bool gannBull = not gannFilter or (gannDirection == 1 and close > gannLevel)
bool gannBear = not gannFilter or (gannDirection == -1 and close < gannLevel)
bool bullBreakContext = (not cloudFilterInput or fullBull) and gannBull
bool bearBreakContext = (not cloudFilterInput or fullBear) and gannBear
array<bool> selected = array.from(selectNy, selectLondon, selectAsia)
array<float> sessionValues = array.from(nyVwap, londonVwap, asiaVwap)
int selectedCount = 0
int bullishPasses = 0
int bearishPasses = 0
for slot = 0 to 2
    if selected.get(slot)
        selectedCount += 1
        float value = sessionValues.get(slot)
        if not na(value)
            bullishPasses += close > value ? 1 : 0
            bearishPasses += close < value ? 1 : 0
bool bullSession = not sessionFilter or selectedCount == 0 or (sessionRule == "All Selected" ? bullishPasses == selectedCount : bullishPasses > 0)
bool bearSession = not sessionFilter or selectedCount == 0 or (sessionRule == "All Selected" ? bearishPasses == selectedCount : bearishPasses > 0)

// Compare prices to the band's values from their corresponding bars.
// New-anchor gaps do not constitute crosses.
var array<float> previousLevels = array.new<float>(11, na)
array<float> levels = array.new<float>(11, na)
array<string> names = array.new<string>(11, "")
levels.set(0, breakCenter ? center : na)
names.set(0, "VWAP")
for slot = 0 to 4
    levels.set(slot + 1, breakBands and breakUpper ? upper.get(slot) : na)
    levels.set(slot + 6, breakBands and breakLower ? lower.get(slot) : na)
    names.set(slot + 1, "Upper " + ratioName(ratios.get(slot)))
    names.set(slot + 6, "Lower " + ratioName(ratios.get(slot)))
float upLevel = na
float downLevel = na
string upName = ""
string downName = ""
for slot = 0 to 10
    float current = levels.get(slot)
    float previous = previousLevels.get(slot)
    bool upCross = not anchorReset and not na(current) and not na(previous) and close > current and close[1] <= previous
    bool downCross = not anchorReset and not na(current) and not na(previous) and close < current and close[1] >= previous
    if upCross and (na(upLevel) or current > upLevel)
        upLevel := current
        upName := names.get(slot)
    if downCross and (na(downLevel) or current < downLevel)
        downLevel := current
        downName := names.get(slot)
    previousLevels.set(slot, current)
bool entryWindow = barstate.isconfirmed and not stopped and (not trailEnabled or riskReady)
bool brkUp = entryWindow and breakEnabled and not tradeLocked and not na(upLevel) and bullBreakContext and bullSession
bool brkDown = entryWindow and breakEnabled and not tradeLocked and not na(downLevel) and bearBreakContext and bearSession
// All accepted signal families share the same risk engine.
bool longEntry = brkUp or (reactionKind != 0 and reactionDirection == 1)
bool shortEntry = brkDown or (reactionKind != 0 and reactionDirection == -1)
if longEntry and shortEntry
    brkUp := false
    brkDown := false
    reactionKind := 0
    reactionDirection := 0
    longEntry := false
    shortEntry := false

if reactionKind != 0
    lastReactionBar := bar_index
    if chooseUpper
        upperMemory.consume(reactionKind)
    else
        lowerMemory.consume(reactionKind)
if trailEnabled and barstate.isconfirmed and riskReady and not stopped
    int entryDirection = longEntry ? 1 : shortEntry ? -1 : 0
    // Repeated same-direction events do not move the frozen entry snapshot.
    if entryDirection != 0 and trade.direction != entryDirection
        trade.beginTrade(entryDirection, standardClose, distance)

// Plots carry long history; bounded objects carry recent reaction boundaries.
bool fullDisplay = not minimalDisplay
plot(fullDisplay and (extendSessions or insideNy) and drawNy ? nyVwap : na, "New York Session VWAP", color=nyColor, linewidth=sessionWidth, style=plot.style_linebr)
plot(fullDisplay and (extendSessions or insideLondon) and drawLondon ? londonVwap : na, "London Session VWAP", color=londonColor, linewidth=sessionWidth, style=plot.style_linebr)
plot(fullDisplay and (extendSessions or insideAsia) and drawAsia ? asiaVwap : na, "Asian Session VWAP", color=asiaColor, linewidth=sessionWidth, style=plot.style_linebr)
centerPlot = plot(fullDisplay or centerInMinimal ? center : na, "Anchored VWAP", color=centerColor, linewidth=2, style=plot.style_linebr)
outerUpPlot = plot(fullDisplay and bandsReady ? center + spread : na, "Outer Upper Band", color=bullColor, linewidth=2, style=plot.style_linebr)
outerDownPlot = plot(fullDisplay and bandsReady ? center - spread : na, "Outer Lower Band", color=bearColor, linewidth=2, style=plot.style_linebr)
fill(outerUpPlot, centerPlot, color=fullDisplay and drawBandFill ? color.new(bullColor, 90) : na)
fill(outerDownPlot, centerPlot, color=fullDisplay and drawBandFill ? color.new(bearColor, 90) : na)
plot(fullDisplay and (drawCore or ratios.get(0) != 0.236) ? upper.get(0) : na, "Upper Ratio 1", color=ratioColor1, linewidth=2, style=plot.style_linebr)
plot(fullDisplay ? upper.get(1) : na, "Upper Ratio 2", color=ratioColor2, style=plot.style_linebr)
plot(fullDisplay ? upper.get(2) : na, "Upper Ratio 3", color=ratioColor3, style=plot.style_linebr)
plot(fullDisplay ? upper.get(3) : na, "Upper Ratio 4", color=ratioColor4, style=plot.style_linebr)
plot(fullDisplay ? upper.get(4) : na, "Upper Ratio 5", color=ratioColor5, style=plot.style_linebr)
plot(fullDisplay and (drawCore or ratios.get(0) != 0.236) ? lower.get(0) : na, "Lower Ratio 1", color=ratioColor1, linewidth=2, style=plot.style_linebr)
plot(fullDisplay ? lower.get(1) : na, "Lower Ratio 2", color=ratioColor2, style=plot.style_linebr)
plot(fullDisplay ? lower.get(2) : na, "Lower Ratio 3", color=ratioColor3, style=plot.style_linebr)
plot(fullDisplay ? lower.get(3) : na, "Lower Ratio 4", color=ratioColor4, style=plot.style_linebr)
plot(fullDisplay ? lower.get(4) : na, "Lower Ratio 5", color=ratioColor5, style=plot.style_linebr)
plot(fullDisplay and drawCore and ratios.get(0) != 0.236 ? upper236 : na, "Upper 23.6 Reaction Core", color=ratioColor1, linewidth=2, style=plot.style_linebr)
plot(fullDisplay and drawCore and ratios.get(0) != 0.236 ? lower236 : na, "Lower 23.6 Reaction Core", color=ratioColor1, linewidth=2, style=plot.style_linebr)
fastPlot = plot(fullDisplay and drawCloud ? fastMa : na, "Fast MA", color=drawMaLines ? color.rgb(64, 128, 255) : color.new(color.white, 100), linewidth=2, style=plot.style_linebr)
slowPlot = plot(fullDisplay and drawCloud ? slowMa : na, "Slow MA", color=drawMaLines ? color.rgb(128, 0, 192) : color.new(color.white, 100), linewidth=2, style=plot.style_linebr)
fill(fastPlot, slowPlot, color=fullDisplay and drawCloud and drawBandFill and allowCloudFill ? color.new(color.white, 92) : na)
plot(fullDisplay and drawGann ? gannLevel : na, "Gann HiLo", color=gannDirection == 1 ? gannBullColor : gannBearColor, linewidth=gannStroke, style=plot.style_steplinebr)
barcolor(cloudCandles ? (cloudBull ? color.new(bullColor, 60) : cloudBear ? color.new(bearColor, 60) : color.new(color.gray, 60)) : na)
plot(trailEnabled and trade.direction == 1 ? trade.stop : na, "Long Trail", color=bullColor, linewidth=2, style=plot.style_steplinebr)
plot(trailEnabled and trade.direction == -1 ? trade.stop : na, "Short Trail", color=bearColor, linewidth=2, style=plot.style_steplinebr)

array<float> edges = array.from(upper236 + halfWidth, upper236 - halfWidth, lower236 + halfWidth, lower236 - halfWidth)
var array<float> previousEdges = array.new<float>(4, na)
var array<line> boundarySegments = array.new<line>()
if anchorReset or not fullDisplay or not drawZones
    while boundarySegments.size() > 0
        line.delete(boundarySegments.shift())
else
    for slot = 0 to 3
        float previous = previousEdges.get(slot)
        float current = edges.get(slot)
        if not na(previous) and not na(current)
            while boundarySegments.size() >= zoneHistory * 4
                line.delete(boundarySegments.shift())
            line segment = line.new(bar_index - 1, previous, bar_index, current, color=color.new(ratioColor1, zoneFade), width=zoneStroke, style=zoneStrokeStyle == "Dashed" ? line.style_dashed : zoneStrokeStyle == "Dotted" ? line.style_dotted : line.style_solid)
            boundarySegments.push(segment)
for slot = 0 to 3
    previousEdges.set(slot, edges.get(slot))

var array<label> lastBandLabels = array.new<label>()
if barstate.islast
    while lastBandLabels.size() > 0
        label.delete(lastBandLabels.shift())
    if fullDisplay
        array<bool> drawLabels = array.from(labelRatio1, labelRatio2, labelRatio3, labelRatio4, labelRatio5)
        array<color> labelColors = array.from(ratioColor1, ratioColor2, ratioColor3, ratioColor4, ratioColor5)
        for slot = 0 to 4
            if drawLabels.get(slot) and not na(upper.get(slot))
                string ratioLabelText = ratioPercent ? str.tostring(ratios.get(slot) * 100, "0.##") + "%" : ratioName(ratios.get(slot))
                lastBandLabels.push(label.new(bar_index + 1, upper.get(slot), ratioLabelText, color=labelColors.get(slot), textcolor=color.white, style=label.style_label_left))
                lastBandLabels.push(label.new(bar_index + 1, lower.get(slot), ratioLabelText, color=labelColors.get(slot), textcolor=color.white, style=label.style_label_left))

// One short caption is shared by 23.6 labels and their alert messages.
string reactionCaption = reactionKind == 1 ? "BK+RT" : reactionKind == 2 ? "Reject" : reactionKind == 3 ? "Hold" : reactionKind == 4 ? "Accept" : ""
if reactionKind != 0
    if reactionLabels
        string markerSize = reactionSize == "Tiny" ? size.tiny : reactionSize == "Small" ? size.small : reactionSize == "Normal" ? size.normal : reactionSize == "Large" ? size.large : size.huge
        label.new(bar_index, reactionDirection == 1 ? low : high, reactionCaption, color=reactionDirection == 1 ? bullColor : bearColor, textcolor=reactionDirection == 1 ? color.black : color.white, style=reactionDirection == 1 ? label.style_label_up : label.style_label_down, size=markerSize)
if brkUp or brkDown
    label.new(bar_index, tagLevels and fullDisplay ? (brkUp ? upLevel : downLevel) : (brkUp ? low : high), "BRK" + (tagLevels and fullDisplay ? " " + (brkUp ? upName : downName) : ""), color=brkUp ? bullColor : bearColor, textcolor=color.white, style=brkUp ? label.style_label_up : label.style_label_down, size=size.small)
// Aggregate notifications so later events on the same update are not lost.
// Explicit gates define closed-bar timing. varip suppresses repeated live-bar
// provisional messages only; historical bars cannot reproduce tick messages.
string messages = ""
if breakAlerts and (brkUp or brkDown)
    messages += (brkUp ? "BRK bullish: " + upName : "BRK bearish: " + downName) + "\n"
if reactionAlerts and reactionKind != 0
    messages += reactionCaption + "\n"
varip bool provisionalSent = false
if barstate.isnew
    provisionalSent := false
if str.length(messages) > 0 and (barstate.isconfirmed or not provisionalSent)
    alert(syminfo.ticker + " / " + timeframe.period + "\n" + messages, alert.freq_all)
    if not barstate.isconfirmed
        provisionalSent := true
````
