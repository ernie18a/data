# JRC ONE v1.1 - Execution & Validation

- url: https://www.tradingview.com/script/pIRRVvou-JRC-ONE-v1-1-Execution-Validation/
- type: indicator
- pine_id: PUB;f7f0c456a6e64192a0dbea7aa8085d52
- version: 1.0

## Description

JRC ONE v1.1 - Execution & Validation

JRC ONE combines a session-level map, confirmed higher-timeframe bias, two retest setup types, risk/cost gates, and an internal execution simulation. It is an indicator, not an automated order system or a TradingView strategy. Its purpose is to separate a confirmed plan from a subsequently accepted simulated fill, and to make rejected plans and dataset limitations visible.

The source describes an original synthesis of JRC/PRB/SRT concepts; no LuxAlgo source is used. The heatmap is derived from confirmed price pivots and volume/touch heuristics, not order-book liquidity, true delta, or a probability of success.

QUICK START
1. Use standard 1-5 minute candlesticks on a US stock/ETF with America/New_York exchange timezone. Other instruments, chart types and intervals are blocked from accepting plans.
2. Enable extended-session data. Premarket data is required by default. Load enough history for the prior regular session, opening range, volume baseline and 300-bar warm-up.
3. Keep the bias timeframe above the chart timeframe; default is 15 minutes.
4. Set the validation dates and realistic cost assumptions. Defaults cover 2026, use 1 slippage tick, a 2-tick full spread and 1 basis point fee per side.
5. Start with Compact dashboard. Use Detailed for statistics and coverage, the last-10-trades ledger for records, and rejection diagnostics for blocked setups.

CONTEXT AND LEVELS
Bias uses the last completed higher-timeframe close and EMA 9/20. Bullish means close > EMA 9 > EMA 20; bearish is the reverse. Mixed bias does not start a setup. Historical offsets with lookahead_on are used for this completed higher-timeframe context.

The map includes previous regular-session high/low (PDH/PDL), premarket high/low (PMH/PML), 09:30-09:35 opening-range high/low (ORH/ORL), and confirmed swing high/low (SH/SL). Session levels are calculated in a one-minute source context. Levels within two ticks are merged and labels identify their components. Label spacing may move captions vertically while the price line stays at its actual level.

Pivot strength defaults to three bars on either side. A pivot is only known after its right-hand confirmation bars; zones originate at that confirmation, not retroactively at the pivot. Zones expire after 390 elapsed minutes or invalidate when price closes beyond the outer boundary. Supply/demand strength is a visual score based on volume and repeat touches. Colors, visibility caps and heatmap filters affect rendering only; hiding a zone does not remove it from obstacle calculations.

VWAP can reset by New York calendar day (default) or at the regular-session opening. EMA 9 and 20 provide local trend context. RVOL compares the current bar's volume with the preceding 20 regular-session bar volumes, not a time-of-day seasonal average.

SETUP A: BREAK AND RETEST
Price closes across a mapped level in the higher-timeframe bias direction. Breakout RVOL must reach the threshold, default 1.5, and the breakout must not be too extended. A later candle retests a band around the level and closes on the intended side. By default, retest volume must be below breakout volume. A still-later candle closes beyond the retest candle's extreme with a directional body. The confirmation must also agree with local VWAP and EMA 9/20 ordering.

SETUP B: SWEEP, RECLAIM AND RETEST
Price penetrates a mapped level by at least the configured ATR fraction, closes back across it with a directional body, and closes in the appropriate half of the candle range. It then requires a later holding retest and a still-later close beyond the retest candle's extreme. The sweep path does not use the continuation RVOL, quiet-retest or local VWAP/EMA gate, but still follows the confirmed higher-timeframe bias.

Both paths freeze ATR when armed. Default retest half-width is 0.25 ATR, minimum sweep penetration 0.10 ATR, failure distance 0.5 ATR, setup life 15 minutes, and confirmation time after retest 5 minutes. Bias changes or failure/expiry invalidate a setup. Default maximum entry extension is 1.5 frozen ATR. When both paths qualify at the same level, Sweep wins by default; this is configurable. The script arms one candidate at a time using its mapped-level evaluation order.

SESSIONS AND PLAN LIMITS
Default signal windows are 09:35-11:00 and 14:00-15:30, New York time, weekdays within the regular session. Afternoon signals can be disabled. The default daily cap is two confirmed PLANS, not two filled trades; zero removes the cap. Cooldown defaults to five minutes. A used level/direction is not reused that day even if its confirmed plan later fails fill validation. Pending setups clear when their signal window/date ends or a plan/guide becomes active.

RISK AND TARGETS
A stop uses the setup's tracked extreme plus a frozen-ATR buffer, default 0.20 ATR. Price risk must satisfy minimum tick distance and maximum ATR distance. Targets are limited by the nearest mapped level or opposing supply/demand zone and an ATR clearance buffer, and by the maximum gross target multiple, default 2.5R.

Plans must meet a minimum NET reward/total stop-loss ratio, default 1.5. The calculation includes configured fees and modeled adverse stop execution. There is also a maximum modeled costs/price-risk gate, default 25%. Targets and stops are rounded to instrument ticks. These gates are checked again at the modeled entry price.

PLAN VERSUS SIMULATED FILL
PLAN labels and alerts are committed at a confirmed bar close. They freeze the intended stop/target. A fill is modeled at a later bar's OPEN, default next bar open plus zero extra delay bars. This fill is only evaluated and reported at that later bar's CLOSE, so it is not an intrabar execution alert.

The modeled market entry includes adverse half-spread plus slippage, rounded up to whole ticks. A plan may be rejected for a gap past its stop/target, changed bias, excessive extension, unsuitable stop distance, costs, insufficient net reward, expiration, or a changed session/date. Default maximum fill wait is 15 minutes. Only one simulated guide is active at a time.

A newly modeled open fill may hit its stop or target on the same bar. If both are touched, the simulation chooses STOP FIRST and counts an ambiguous bar. Stop exits account for adverse opening gaps and configured market-fill costs. Target exits assume the target price. Regular-session/date exits are also modeled. If the final session bar is missing, an exit uses a later available open rather than inventing a previous-close fill. No pyramiding, partial fills, order book or broker execution is modeled.

DASHBOARD AND VALIDATION
Compact mode shows GO, WAIT or NO GO with a reason and bias or current stop/target.
GO means a NEW bar-close-confirmed plan. It does not mean a filled order, and an existing guide does not keep GO active.
WAIT covers setup development, bar confirmation, pending fill or guide management.
NO GO includes unsupported context, signal-window restrictions, rejections, date restrictions and the daily cap.

Detailed mode can show per-setup closed counts, win percentage, average net R, total closed R, R-based profit factor, closed-trade drawdown, maximum loss streak, requested versus loaded date coverage, first eligibility, open guides, outcomes and rejection counts. The default small-sample warning threshold is 100 closed trades; crossing that threshold is not evidence of reliability.

Net trade R divides net price profit/loss after modeled fees by the entry-to-original-stop PRICE distance. This differs from the plan eligibility ratio, whose denominator includes modeled stop execution and fees. Drawdown is based on accumulated CLOSED-trade R, not mark-to-market equity or dollar account drawdown. An active guide is excluded from closed statistics.

The requested default test range is 2026-01-01 inclusive through 2027-01-01 exclusive. Align end dates to a bar boundary. The dashboard flags incomplete loaded coverage. Results can change when chart history, symbol, timeframe, session settings, dates or inputs change. This publication does not claim a verified win rate or profitable performance.

LEDGER AND EXPORT
Show last 10 closed trades displays the newest records in the center and replaces the main dashboard. Rejection diagnostics list codes 1-9: invalidated, expired, bias changed, extended entry, stop distance, net reward, costs, session/date/gap, and used level. Some diagnostics count evaluated bars/events rather than unique trades.

Data Window plots expose closed-trade records on exit bars. If your TradingView plan supports chart CSV export, filter rows with Closed trade ID to reconstruct the available ledger. Times are Unix milliseconds. Setup code 1 = break/retest, 2 = sweep. Side 1 = long, -1 = short. Exit code 1 = stop, 2 = target, 3 = session, 4 = delayed session, 5 = date.

ALERTS
Choose Any alert() function call for a detailed confirmed PLAN message, or JRC ONE Long plan / JRC ONE Short plan with Once per bar close. Use one route to avoid duplicates. Alerts describe plans, not executed fills; actual execution price and costs need separate validation. Recreate alerts after changing inputs because TradingView stores their configuration.

LIMITATIONS
The simulation uses historical OHLCV and simplified execution assumptions. It does not model queue position, available liquidity, partial fills, short availability, borrow costs or broker-specific behavior. Lower-timeframe/session data availability, market data revisions and the loaded dataset can affect output. Confirmed pivots are delayed by design. Heat scores are visual heuristics. Defaults are experimental and require out-of-sample evaluation; no live-trading performance is established by this publication.

## Source Code

````pine
//@version=6
indicator("JRC ONE v1.1 - Execution & Validation", "JRC ONE v1.1", overlay=true, max_boxes_count=50, max_labels_count=200, max_lines_count=30)
// Original synthesis of the reviewed JRC/PRB/SRT concepts; no LuxAlgo source used.
// US equities, standard 1-5 minute candles, extended-session data recommended.
// Plans are confirmed at bar close. Fills are modeled at a later bar open and reported at that bar close.
// This is an indicator simulation, not an order system. No intrabar fill alerts are implied.

string g1 = "Context and sessions"
string contextTF = input.timeframe("15", "Confirmed bias timeframe", group=g1)
string morning = input.session("0935-1100", "Morning signals (New York)", group=g1)
bool afternoonOn = input.bool(true, "Enable afternoon signals", group=g1)
string afternoon = input.session("1400-1530", "Afternoon signals (New York)", group=g1)
bool requirePM = input.bool(true, "Require premarket data", group=g1)
bool rthVwap = input.bool(false, "Anchor VWAP at 09:30 (off: New York day)", group=g1)
string g2 = "Setup rules - experimental defaults"
bool enableBreak = input.bool(true, "Break and retest", group=g2)
bool enableSweep = input.bool(true, "Sweep, reclaim and retest", group=g2)
int pivotLen = input.int(3, "Confirmed pivot strength", minval=2, maxval=10, group=g2)
float breakRV = input.float(1.5, "Minimum breakout RVOL", minval=0, step=0.1, group=g2)
bool quietTouch = input.bool(true, "Continuation retest volume below breakout volume", group=g2)
float tolATR = input.float(0.25, "Retest half-width / frozen ATR", minval=0.05, step=0.05, group=g2)
float sweepATR = input.float(0.10, "Minimum sweep penetration / ATR", minval=0, step=0.05, group=g2)
float failureATR = input.float(0.5, "Failure distance / frozen ATR", minval=0.1, step=0.1, group=g2)
int expiryMin = input.int(15, "Setup expires after minutes", minval=2, maxval=120, group=g2)
int confirmMin = input.int(5, "Confirm within minutes after retest", minval=1, maxval=30, group=g2)
float maxExtension = input.float(1.5, "Maximum entry extension / frozen ATR", minval=0.25, step=0.25, group=g2)
int cap = input.int(2, "Maximum confirmed plans per day (0 = unlimited)", minval=0, maxval=20, group=g2)
int cooldownMin = input.int(5, "Cooldown minutes", minval=0, maxval=60, group=g2)
string g3 = "Risk and outcome simulation"
float stopBuffer = input.float(0.20, "Stop buffer / frozen ATR", minval=0.05, step=0.05, group=g3)
float minR = input.float(1.5, "Minimum NET reward / total stop risk", minval=0.5, step=0.25, group=g3)
float maxR = input.float(2.5, "Maximum target / risk", minval=0.5, step=0.25, group=g3)
float roomBuffer = input.float(0.05, "Target before obstacle / ATR", minval=0, step=0.05, group=g3)
float maxRiskATR = input.float(3.0, "Maximum stop distance / frozen ATR", minval=0.5, step=0.25, group=g3)
int slipTicks = input.int(1, "Simulated slippage ticks per market fill", minval=0, group=g3)
float feeBps = input.float(1.0, "Simulated fee basis points per side", minval=0, step=0.1, group=g3)
string gExec = "Execution model"
int delayBars = input.int(0, "Extra bars of fill delay (0 = next bar open)", minval=0, maxval=5, group=gExec)
int spreadTicks = input.int(2, "Full bid/ask spread in ticks", minval=0, group=gExec)
int minimumStopTicks = input.int(4, "Minimum stop distance in ticks", minval=1, group=gExec)
float maxCostRisk = input.float(0.25, "Maximum estimated costs / price risk", minval=0.01, step=0.05, group=gExec)
int maxFillWait = input.int(15, "Cancel unfilled plan after minutes", minval=1, maxval=120, group=gExec)
string overlapPriority = input.string("Sweep", "When both setups qualify", options=["Sweep", "Break/retest"], group=gExec)
string gTest = "Validation and date range"
int testStart = input.time(timestamp("01 Jan 2026 00:00 -0500"), "Test start (inclusive)", group=gTest)
int testEnd = input.time(timestamp("01 Jan 2027 00:00 -0500"), "Test end (exclusive; align to bar boundary)", group=gTest)
int warmupBars = input.int(300, "Warm-up chart bars before accepting plans", minval=50, maxval=5000, group=gTest)
int sampleWarning = input.int(100, "Small-sample warning below closed trades", minval=10, group=gTest)
bool showLedger = input.bool(false, "Show last 10 closed trades (center)", group=gTest)
bool showDiagnostics = input.bool(false, "Show rejection breakdown (bottom left)", group=gTest)
string g4 = "Display"
bool showMap = input.bool(true, "Show merged key levels", group=g4)
bool showZones = input.bool(true, "Show supply/demand heatmap", group=g4)
bool showAverages = input.bool(true, "Show VWAP and EMA 9/20", group=g4)
bool showPanel = input.bool(true, "Show dashboard", group=g4)
bool showStats = input.bool(true, "Show simulated outcomes", group=g4)
string panelPos = input.string("Bottom Right", "Dashboard position", options=["Top Right", "Bottom Right", "Bottom Left"], group=g4)
string gColors = "Colors - signals and dashboard"
color bull = input.color(color.rgb(0,190,150), "Bullish", group=gColors)
color bear = input.color(color.rgb(240,85,105), "Bearish", group=gColors)
color signalText = input.color(color.white, "Signal label text", group=gColors)
color warningColor = input.color(color.orange, "Waiting / mixed bias", group=gColors)
color panelText = input.color(color.white, "Dashboard values", group=gColors)
color mutedText = input.color(color.silver, "Dashboard captions / statistics", group=gColors)
color panelBg = input.color(color.new(color.rgb(18,23,31),8), "Dashboard background", group=gColors)
color panelBorder = input.color(color.new(color.gray,65), "Dashboard border", group=gColors)
string gLines = "Colors - averages and risk guides"
color vwapColor = input.color(color.aqua, "VWAP", group=gLines)
color fastColor = input.color(color.white, "EMA 9", group=gLines)
color slowColor = input.color(color.orange, "EMA 20", group=gLines)
color entryColor = input.color(color.white, "Entry reference", group=gLines)
color stopColor = input.color(color.rgb(240,85,105), "Stop / invalidation", group=gLines)
color targetColor = input.color(color.rgb(0,190,150), "Target", group=gLines)
string gLevels = "Colors - key levels"
color pdhColor = input.color(color.rgb(255,90,110), "Previous-day high", group=gLevels)
color pdlColor = input.color(color.rgb(50,210,140), "Previous-day low", group=gLevels)
color pmhColor = input.color(color.rgb(255,170,40), "Premarket high", group=gLevels)
color pmlColor = input.color(color.rgb(70,155,255), "Premarket low", group=gLevels)
color orhColor = input.color(color.rgb(255,220,70), "Opening-range high", group=gLevels)
color orlColor = input.color(color.rgb(65,215,235), "Opening-range low", group=gLevels)
color shColor = input.color(color.rgb(210,110,255), "Swing high", group=gLevels)
color slColor = input.color(color.rgb(95,225,205), "Swing low", group=gLevels)
int levelWidth = input.int(2, "Level line width", minval=1, maxval=4, group=gLevels)
string levelFont = input.string("Small", "Level label size", options=["Tiny","Small","Normal"], group=gLevels)
float labelGapATR = input.float(0.6, "Minimum label spacing / ATR", minval=0, maxval=3, step=0.1, group=gLevels)
string gHeat = "Heatmap levels - display only"
string heatMode = input.string("All active", "Zone display", options=["All active","Nearest per side"], group=gHeat)
int heatCount = input.int(6, "Maximum visible zones (nearest first)", minval=1, maxval=12, group=gHeat)
int minHeat = input.int(0, "Minimum visual strength", minval=0, maxval=100, group=gHeat)
float heatDistance = input.float(0, "Maximum distance / ATR (0 = unlimited)", minval=0, step=1, group=gHeat)
int weakAlpha = input.int(90, "Weak-zone transparency", minval=0, maxval=100, group=gHeat)
int strongAlpha = input.int(55, "Strong-zone transparency", minval=0, maxval=100, group=gHeat)
bool heatLabels = input.bool(true, "Zone strength and price labels", group=gHeat)
color weakSupply = input.color(color.rgb(115,45,90), "Supply - weak", group=gHeat)
color strongSupply = input.color(color.rgb(255,65,100), "Supply - strong", group=gHeat)
color weakDemand = input.color(color.rgb(25,95,105), "Demand - weak", group=gHeat)
color strongDemand = input.color(color.rgb(0,235,170), "Demand - strong", group=gHeat)
color heatText = input.color(color.white, "Zone label text", group=gHeat)
bool levelBands = input.bool(true, "Heat bands around key levels", group=gHeat)
float bandATR = input.float(0.08, "Key-level band half-width / ATR", minval=0.01, maxval=0.5, step=0.01, group=gHeat)
int bandAlpha = input.int(88, "Key-level band transparency", minval=0, maxval=100, group=gHeat)
int mapBars = input.int(60, "Key-level heatmap length (chart bars)", minval=5, maxval=500, group=gHeat)
string dashboardMode = input.string("Compact", "Dashboard mode", options=["Compact", "Detailed"], group=g4)
// Visual strength is a volume/touch heuristic, never a probability or order-book measurement.
// All heatmap options and color controls affect rendering only, not entries or obstacles.

string tz = "America/New_York"
bool chartOK = chart.is_standard and timeframe.isminutes and timeframe.multiplier <= 5
bool marketOK = (syminfo.type == "stock" or syminfo.type == "fund" or syminfo.type == "dr") and syminfo.timezone == "America/New_York"
var int firstLoadedTime = time
bool inTest = time >= testStart and time_close <= testEnd
bool warmedUp = bar_index >= warmupBars
if barstate.isfirst and testEnd <= testStart
    runtime.error("Test end must be later than test start.")
bool htfOK = timeframe.in_seconds(contextTF) > timeframe.in_seconds()
int dayKey = year(time,tz)*10000 + month(time,tz)*100 + dayofmonth(time,tz)
bool newDay = barstate.isfirst or dayKey != dayKey[1]
bool inRTH = session.ismarket and not na(time(timeframe.period,"0930-1600:23456",tz))
bool inAM = not na(time(timeframe.period,morning+":23456",tz))
bool inPMWindow = afternoonOn and not na(time(timeframe.period,afternoon+":23456",tz))
int window = inAM ? 1 : inPMWindow ? 2 : 0
bool inWindow = inRTH and window != 0
bool lastRTH = inRTH and (session.islastbar_regular or time_close >= timestamp(tz,year(time,tz),month(time,tz),dayofmonth(time,tz),16,0))
float atr = ta.atr(14)
float ema9 = ta.ema(close,9)
float ema20 = ta.ema(close,20)
[hc,h9,h20] = request.security(syminfo.tickerid,htfOK ? contextTF : timeframe.period,[close[1],ta.ema(close,9)[1],ta.ema(close,20)[1]],lookahead=barmerge.lookahead_on)
int bias = hc > h9 and h9 > h20 ? 1 : hc < h9 and h9 < h20 ? -1 : 0

// Compute exact session boundaries in the one-minute source context.
f_levels() =>
    int k = year(time,tz)*10000 + month(time,tz)*100 + dayofmonth(time,tz)
    bool reset = barstate.isfirst or k != k[1]
    bool regular = session.ismarket and not na(time("1","0930-1600:23456",tz))
    bool pre = not na(time("1","0400-0930:23456",tz))
    bool opening = not na(time("1","0930-0935:23456",tz))
    var float rh = na
    var float rl = na
    var float pdh = na
    var float pdl = na
    var float pmh = na
    var float pml = na
    var float oh = na
    var float ol = na
    var bool seenOpen = false
    var bool orReady = false
    if reset
        if seenOpen
            pdh := rh
            pdl := rl
        else if not na(rh)
            // A partial RTH day without its opening bar must not leave stale PDH/PDL.
            pdh := na
            pdl := na
        rh := na
        rl := na
        pmh := na
        pml := na
        oh := na
        ol := na
        seenOpen := false
        orReady := false
    if regular
        if hour(time,tz) == 9 and minute(time,tz) == 30
            seenOpen := true
        rh := math.max(nz(rh,high),high)
        rl := math.min(nz(rl,low),low)
    if pre
        pmh := math.max(nz(pmh,high),high)
        pml := math.min(nz(pml,low),low)
    if opening
        oh := math.max(nz(oh,high),high)
        ol := math.min(nz(ol,low),low)
    if not opening and opening[1] and seenOpen and not reset
        orReady := true
    [pdh,pdl,pre ? na : pmh,pre ? na : pml,orReady ? oh : na,orReady ? ol : na]
[pdh,pdl,pmh,pml,orh,orl] = request.security(syminfo.tickerid,"1",f_levels(),lookahead=barmerge.lookahead_off)
var float pv = 0.0
var float vv = 0.0
if newDay or (rthVwap and inRTH and not inRTH[1])
    pv := 0
    vv := 0
if not rthVwap or inRTH
    pv += hlc3*nz(volume)
    vv += nz(volume)
float vwap = vv > 0 ? pv/vv : na
var vols = array.new_float()
float baseVol = array.size(vols) == 20 ? array.avg(vols) : na
float rvol = baseVol > 0 ? volume/baseVol : na
if barstate.isconfirmed and inRTH and not na(volume)
    array.push(vols,volume)
    if array.size(vols) > 20
        array.shift(vols)
bool ready = marketOK and chartOK and htfOK and warmedUp and atr > 0 and not na(rvol) and not na(vwap) and not na(pdh) and not na(orh) and (not requirePM or not na(pmh))
if barstate.isfirst and maxR < minR
    runtime.error("Maximum target R must be at least minimum available R.")

// Pivot-derived zones are price structure, not order-book liquidity or true delta.
type Zone
    float top
    float bottom
    int side
    int born
    box drawing
    float strength = 35.0
    int lastTouch = na
var zones = array.new<Zone>()
float ph = ta.pivothigh(high,pivotLen,pivotLen)
float pl = ta.pivotlow(low,pivotLen,pivotLen)
var float sh = na
var float sl = na
if barstate.isconfirmed
    if array.size(zones) > 0
        for i = array.size(zones)-1 to 0
            Zone z = array.get(zones,i)
            if (z.side == 1 ? close > z.top : close < z.bottom) or time_close-z.born > 390*60000
                box.delete(z.drawing)
                array.remove(zones,i)
            else if high>=z.bottom and low<=z.top and (na(z.lastTouch) or bar_index-z.lastTouch>2)
                z.strength := math.min(100.0,z.strength+5.0)
                z.lastTouch := bar_index
    for side in array.from(1,-1)
        float p = side == 1 ? ph : pl
        if not na(p) and atr[pivotLen] > 0
            if side == 1
                sh := p
            else
                sl := p
            float half = math.max(syminfo.mintick,atr[pivotLen]*0.12)
            if side == 1 ? close <= p+half : close >= p-half
                box b = box.new(bar_index,p+half,bar_index+1,p-half,extend=extend.right,bgcolor=na,border_color=na)
                array.push(zones,Zone.new(p+half,p-half,side,time_close,b,math.min(70.0,35.0+math.max(0.0,nz(rvol[pivotLen],1.0)-1.0)*15.0)))
                if array.size(zones)>12
                    Zone old = array.shift(zones)
                    box.delete(old.drawing)

// Deduplicate equal levels before setup evaluation and rendering.
var levels = array.new_float()
var names = array.new_string()
array.clear(levels)
array.clear(names)
raw = array.from(pdh,pdl,pmh,pml,orh,orl,sh,sl)
captions = array.from("PDH","PDL","PMH","PML","ORH","ORL","SH","SL")
for i=0 to 7
    float p = array.get(raw,i)
    if not na(p)
        int found = -1
        if array.size(levels)>0
            for j=0 to array.size(levels)-1
                if math.abs(array.get(levels,j)-p)<=syminfo.mintick*2
                    found := j
        if found == -1
            array.push(levels,p)
            array.push(names,array.get(captions,i))
        else
            array.set(names,found,array.get(names,found)+"/"+array.get(captions,i))

type Setup
    int side
    int kind
    float level
    string name
    float frozenATR
    float extreme
    float originVol
    int born
    int bornBar
    int touchTime = na
    int touchBar = na
    float trigger = na
var pending = array.new<Setup>()
var usedLevels = array.new_float()
var usedSides = array.new_int()
var int signalsToday = 0
var int lastSignalTime = na
var int tradeSide = 0
var int tradeKind = 0
var int tradeBorn = na
var float entry = na
var float stop = na
var float target = na
var float risk = na
var float entryFee = na
var string lastOutcome = "No completed guide"
var counts = array.new_int(2,0)
var wins = array.new_int(2,0)
var netRs = array.new_float(2,0.0)
var int ambiguous = 0
var string stage = "WAIT: setup"
var string activeSetup = "None"
var string tradeSetup = "None"
bool longSignal = false
bool shortSignal = false
float signalR = na
// Round spread + slippage adversely to whole ticks for market fills.
float slip = math.ceil(slipTicks + spreadTicks * 0.5) * syminfo.mintick
f_netReward(int side, float e, float st, float tg) =>
    float stopFill = st - side * slip
    float netReward = (tg-e)*side - (math.abs(e)+math.abs(tg))*feeBps/10000
    float totalLoss = (e-stopFill)*side + (math.abs(e)+math.abs(stopFill))*feeBps/10000
    totalLoss > 0 ? netReward/totalLoss : -1.0
f_costFraction(int side, float e, float st) =>
    float priceRisk = (e-st)*side
    priceRisk > 0 ? (slip+(math.abs(e)+math.abs(st-side*slip))*feeBps/10000)/priceRisk : 1e10

type EntryPlan
    int side
    int kind
    float level
    float atrValue
    float stopPrice
    float targetPrice
    int signalBar
    int signalTime
    int signalDay
    int signalWindow
    string description
var EntryPlan queued = na
var int entryTime = na
var int tradeSignalTime = na
var int tradeID = 0
var float entryNetRR = na
var float cumulativeR = 0.0
var float peakR = 0.0
var float maxDrawdownR = 0.0
var float positiveR = 0.0
var float negativeR = 0.0
var int lossStreak = 0
var int maxLossStreak = 0
var int delayedSessionExits = 0
var int firstFillTime = na
var int lastExitTime = na
var int firstEligibleTime = na
var int lastTestBarTime = na
var candidates = array.new_int(2,0)
var confirmations = array.new_int(2,0)
var rejectedBySetup = array.new_int(2,0)
var rejected = array.new_int(9,0)
var int overlappingCandidates = 0
var int rvolBlocks = 0
var int quietBlocks = 0
var int trendBlocks = 0
var string lastReject = "None"
var ledgerID = array.new_int()
var ledgerSignalTime = array.new_int()
var ledgerEntryTime = array.new_int()
var ledgerExitTime = array.new_int()
var ledgerKind = array.new_int()
var ledgerSide = array.new_int()
var ledgerEntry = array.new_float()
var ledgerStop = array.new_float()
var ledgerTarget = array.new_float()
var ledgerExit = array.new_float()
var ledgerR = array.new_float()
var ledgerReason = array.new_string()
float exportID = na
float exportSignalTime = na
float exportEntryTime = na
float exportExitTime = na
float exportKind = na
float exportSide = na
float exportEntry = na
float exportStop = na
float exportTarget = na
float exportExit = na
float exportR = na
float exportReason = na
int fillDirection = 0
int rejectionCode = 0
bool exitedThisBar = false
f_reject(int code, int kind) =>
    array.set(rejected,code-1,array.get(rejected,code-1)+1)
    array.set(rejectedBySetup,kind-1,array.get(rejectedBySetup,kind-1)+1)

f_used(float p,int d) =>
    bool hit = false
    if array.size(usedLevels)>0
        for i=0 to array.size(usedLevels)-1
            if array.get(usedSides,i)==d and math.abs(array.get(usedLevels,i)-p)<=syminfo.mintick*2
                hit := true
    hit
f_obstacle(int d,float e) =>
    float nearest = na
    if array.size(levels)>0
        for p in levels
            if (p-e)*d>syminfo.mintick
                nearest := na(nearest) ? p : d==1 ? math.min(nearest,p) : math.max(nearest,p)
    if array.size(zones)>0
        for z in zones
            if z.side==d and (d==1 ? z.top>=e : z.bottom<=e)
                float edge = d==1 ? math.max(e,z.bottom) : math.min(e,z.top)
                nearest := na(nearest) ? edge : d==1 ? math.min(nearest,edge) : math.max(nearest,edge)
    nearest

if barstate.isconfirmed
    if newDay
        signalsToday := 0
        array.clear(usedLevels)
        array.clear(usedSides)
    if inTest
        lastTestBarTime := time_close
    if ready and inTest and inWindow and na(firstEligibleTime)
        firstEligibleTime := time
    // A plan uses only information frozen on its confirmation bar.
    // At a later bar close we model that bar's OPEN fill, without consulting its high/low.
    if not na(queued)
        EntryPlan q = queued
        bool planExpired = time-q.signalTime > maxFillWait*60000
        bool planSessionInvalid = dayKey!=q.signalDay or not inRTH or window!=q.signalWindow or not inTest or not marketOK
        if planExpired or planSessionInvalid
            rejectionCode := 8
            f_reject(8,q.kind)
            lastReject := planExpired ? "Fill wait expired" : "Fill session/date changed"
            queued := na
        else if bar_index >= q.signalBar+1+delayBars
            float e = q.side==1 ? math.ceil((open+slip)/syminfo.mintick)*syminfo.mintick : math.floor((open-slip)/syminfo.mintick)*syminfo.mintick
            float r = (e-q.stopPrice)*q.side
            float netRR = f_netReward(q.side,e,q.stopPrice,q.targetPrice)
            bool priceValid = r>0 and (q.targetPrice-e)*q.side>0
            bool extensionOK = math.abs(e-q.level)<=maxExtension*q.atrValue
            bool riskOK = r>=minimumStopTicks*syminfo.mintick and r<=maxRiskATR*q.atrValue
            bool costsOK = f_costFraction(q.side,e,q.stopPrice)<=maxCostRisk
            bool biasOK = bias[1]==q.side
            if priceValid and extensionOK and riskOK and costsOK and netRR>=minR and biasOK
                tradeSide := q.side
                tradeKind := q.kind
                tradeSetup := q.description
                tradeBorn := bar_index
                entryTime := time
                tradeSignalTime := q.signalTime
                entry := e
                stop := q.stopPrice
                target := q.targetPrice
                risk := r
                entryFee := math.abs(e)*feeBps/10000
                entryNetRR := netRR
                tradeID += 1
                fillDirection := q.side
                if na(firstFillTime)
                    firstFillTime := time
                label.new(bar_index,q.side==1 ? low : high,"SIM FILL #"+str.tostring(tradeID)+"\n"+(q.side==1 ? "LONG " : "SHORT ")+str.tostring(e,format.mintick)+" | "+str.tostring(netRR,"#.##")+" net RR",style=q.side==1 ? label.style_label_up : label.style_label_down,color=q.side==1 ? bull : bear,textcolor=signalText,size=size.small)
            else
                rejectionCode := not priceValid ? 8 : not biasOK ? 3 : not extensionOK ? 4 : not riskOK ? 5 : not costsOK ? 7 : 6
                f_reject(rejectionCode,q.kind)
                lastReject := not priceValid ? "Gap past stop/target" : not biasOK ? "Bias changed before fill" : not extensionOK ? "Fill extended" : not riskOK ? "Fill stop distance" : not costsOK ? "Fill costs too large" : "Fill net reward too low"
            queued := na
    // Open fills can hit a stop/target on the SAME bar. Both-hit bars use stop first.
    if tradeSide!=0 and bar_index>=tradeBorn
        bool priorEnded = newDay or (not inRTH and inRTH[1])
        bool pastEnd = time>=testEnd or time_close>testEnd
        bool stopHit = not priorEnded and not pastEnd and (tradeSide==1 ? low<=stop : high>=stop)
        bool targetHit = not priorEnded and not pastEnd and (tradeSide==1 ? high>=target : low<=target)
        bool dateExit = time_close>=testEnd
        if stopHit or targetHit or priorEnded or lastRTH or dateExit or pastEnd
            // Missing last-session bars never receive a retroactive previous-close fill.
            float exitPrice = priorEnded or pastEnd ? open-tradeSide*slip : stopHit ? (tradeSide==1 ? math.min(open,stop) : math.max(open,stop))-tradeSide*slip : targetHit ? target : close-tradeSide*slip
            int exitTime = priorEnded or pastEnd ? time : time_close
            float fees = entryFee+math.abs(exitPrice)*feeBps/10000
            float netR = ((exitPrice-entry)*tradeSide-fees)/risk
            int k = tradeKind-1
            array.set(counts,k,array.get(counts,k)+1)
            array.set(wins,k,array.get(wins,k)+(netR>0 ? 1 : 0))
            array.set(netRs,k,array.get(netRs,k)+netR)
            ambiguous += stopHit and targetHit ? 1 : 0
            delayedSessionExits += priorEnded ? 1 : 0
            cumulativeR += netR
            peakR := math.max(peakR,cumulativeR)
            maxDrawdownR := math.max(maxDrawdownR,peakR-cumulativeR)
            positiveR += math.max(netR,0)
            negativeR += math.max(-netR,0)
            lossStreak := netR<0 ? lossStreak+1 : 0
            maxLossStreak := math.max(maxLossStreak,lossStreak)
            string reason = priorEnded ? "Delayed session exit" : pastEnd ? "Date exit at open" : stopHit ? "Stop" : targetHit ? "Target" : dateExit ? "Date exit" : "Session exit"
            lastOutcome := reason+" "+str.tostring(netR,"#.##")+"R"
            lastExitTime := exitTime
            exportID := tradeID
            exportSignalTime := tradeSignalTime
            exportEntryTime := entryTime
            exportExitTime := exitTime
            exportKind := tradeKind
            exportSide := tradeSide
            exportEntry := entry
            exportStop := stop
            exportTarget := target
            exportExit := exitPrice
            exportR := netR
            exportReason := priorEnded ? 4 : pastEnd ? 5 : stopHit ? 1 : targetHit ? 2 : dateExit ? 5 : 3
            array.push(ledgerID,tradeID)
            array.push(ledgerSignalTime,tradeSignalTime)
            array.push(ledgerEntryTime,entryTime)
            array.push(ledgerExitTime,exitTime)
            array.push(ledgerKind,tradeKind)
            array.push(ledgerSide,tradeSide)
            array.push(ledgerEntry,entry)
            array.push(ledgerStop,stop)
            array.push(ledgerTarget,target)
            array.push(ledgerExit,exitPrice)
            array.push(ledgerR,netR)
            array.push(ledgerReason,reason)
            if array.size(ledgerID)>10
                array.shift(ledgerID)
                array.shift(ledgerSignalTime)
                array.shift(ledgerEntryTime)
                array.shift(ledgerExitTime)
                array.shift(ledgerKind)
                array.shift(ledgerSide)
                array.shift(ledgerEntry)
                array.shift(ledgerStop)
                array.shift(ledgerTarget)
                array.shift(ledgerExit)
                array.shift(ledgerR)
                array.shift(ledgerReason)
            tradeSide := 0
            exitedThisBar := true
    if (newDay or not inWindow or not inTest or window!=window[1]) and array.size(pending)>0
        for abandoned in pending
            f_reject(8,abandoned.kind)
        rejectionCode := 8
        lastReject := "Setup session/date ended"
    if newDay or not inWindow or not inTest or window!=window[1] or tradeSide!=0 or not na(queued)
        array.clear(pending)
    stage := not marketOK ? "UNSUPPORTED: US STOCK / ETF ONLY" : not chartOK ? "USE STANDARD 1-5m" : not htfOK ? "RAISE BIAS TIMEFRAME" : not warmedUp ? "WAIT: warm-up" : not inTest ? "OUTSIDE TEST DATES" : not ready ? "WAIT: data / opening range" : tradeSide!=0 ? "SIM GUIDE ACTIVE" : not na(queued) ? "PLAN: waiting for open" : not inWindow ? "OUTSIDE SIGNAL WINDOW" : cap>0 and signalsToday>=cap ? "DAILY PLAN CAP" : not na(lastSignalTime) and time_close-lastSignalTime<cooldownMin*60000 ? "WAIT: cooldown" : "WAIT: setup"
    activeSetup := tradeSide!=0 ? tradeSetup : not na(queued) ? queued.description : "None"
    bool canWork = ready and inTest and inWindow and not lastRTH and time_close<testEnd and tradeSide==0 and na(queued) and not exitedThisBar and (cap==0 or signalsToday<cap) and (na(lastSignalTime) or time_close-lastSignalTime>=cooldownMin*60000)
    if canWork and array.size(pending)>0
        for i=array.size(pending)-1 to 0
            Setup s = array.get(pending,i)
            bool failed = s.side==1 ? low<s.level-s.frozenATR*failureATR : high>s.level+s.frozenATR*failureATR
            bool expired = time_close-s.born>expiryMin*60000 or (not na(s.touchTime) and time_close-s.touchTime>confirmMin*60000)
            if failed or expired or bias!=s.side
                rejectionCode := failed ? 1 : expired ? 2 : 3
                f_reject(rejectionCode,s.kind)
                lastReject := failed ? "Setup invalidated" : expired ? "Setup expired" : "Setup bias changed"
                stage := lastReject
                array.remove(pending,i)
            else if bar_index>s.bornBar
                s.extreme := s.side==1 ? math.min(s.extreme,low) : math.max(s.extreme,high)
                activeSetup := s.name+(s.kind==1 ? " break/retest" : " sweep/retest")
                bool touched = low<=s.level+s.frozenATR*tolATR and high>=s.level-s.frozenATR*tolATR
                bool held = (close-s.level)*s.side>0
                bool quiet = s.kind==2 or not quietTouch or volume<s.originVol
                quietBlocks += na(s.touchBar) and touched and held and not quiet ? 1 : 0
                if na(s.touchBar) and touched and held and quiet
                    s.touchBar := bar_index
                    s.touchTime := time_close
                    s.trigger := s.side==1 ? high : low
                stage := na(s.touchBar) ? "WAIT: retest" : "WAIT: confirmation"
                bool confirmed = not na(s.touchBar) and bar_index>s.touchBar and (close-s.trigger)*s.side>0 and (close-open)*s.side>0
                bool trendOK = s.kind==2 or (s.side==1 ? close>vwap and ema9>ema20 : close<vwap and ema9<ema20)
                trendBlocks += confirmed and not trendOK ? 1 : 0
                if confirmed and trendOK and tradeSide==0 and na(queued)
                    float e = s.side==1 ? math.ceil((close+slip)/syminfo.mintick)*syminfo.mintick : math.floor((close-slip)/syminfo.mintick)*syminfo.mintick
                    float st = s.side==1 ? math.floor((s.extreme-s.frozenATR*stopBuffer)/syminfo.mintick)*syminfo.mintick : math.ceil((s.extreme+s.frozenATR*stopBuffer)/syminfo.mintick)*syminfo.mintick
                    float r = (e-st)*s.side
                    float obstacle = f_obstacle(s.side,e)
                    float distance = na(obstacle) ? maxR*r : math.min(maxR*r,(obstacle-e)*s.side-s.frozenATR*roomBuffer)
                    float tg = s.side==1 ? math.floor((e+distance)/syminfo.mintick)*syminfo.mintick : math.ceil((e-distance)/syminfo.mintick)*syminfo.mintick
                    float netRR = f_netReward(s.side,e,st,tg)
                    bool extensionOK = math.abs(e-s.level)<=maxExtension*s.frozenATR
                    bool riskOK = r>=minimumStopTicks*syminfo.mintick and r<=maxRiskATR*s.frozenATR
                    bool costsOK = f_costFraction(s.side,e,st)<=maxCostRisk
                    if extensionOK and riskOK and costsOK and netRR>=minR and not f_used(s.level,s.side)
                        queued := EntryPlan.new(s.side,s.kind,s.level,s.frozenATR,st,tg,bar_index,time_close,dayKey,window,activeSetup)
                        signalR := netRR
                        lastSignalTime := time_close
                        signalsToday += 1
                        array.set(confirmations,s.kind-1,array.get(confirmations,s.kind-1)+1)
                        array.push(usedLevels,s.level)
                        array.push(usedSides,s.side)
                        longSignal := s.side==1
                        shortSignal := s.side==-1
                        stage := "PLAN: next open + "+str.tostring(delayBars)+" bars"
                        label.new(bar_index,s.side==1 ? low : high,"PLAN "+(s.side==1 ? "LONG" : "SHORT")+"\n"+s.name+" | "+str.tostring(netRR,"#.##")+" net RR",style=s.side==1 ? label.style_label_up : label.style_label_down,color=color.new(s.side==1 ? bull : bear,45),textcolor=signalText,size=size.tiny)
                    else
                        rejectionCode := not extensionOK ? 4 : not riskOK ? 5 : not costsOK ? 7 : netRR<minR ? 6 : 9
                        f_reject(rejectionCode,s.kind)
                        lastReject := not extensionOK ? "Plan extended" : not riskOK ? "Plan stop distance" : not costsOK ? "Plan costs too large" : netRR<minR ? "Plan net reward too low" : "Level already used"
                        stage := "REJECT: "+lastReject
                    array.remove(pending,i)
    if tradeSide!=0 or not na(queued)
        array.clear(pending)
    if canWork and tradeSide==0 and na(queued) and array.size(pending)==0 and bias!=0 and array.size(levels)>0
        for i=0 to array.size(levels)-1
            float p = array.get(levels,i)
            bool stable = not na(close[1])
            bool swept = bias==1 ? low<p-atr*sweepATR and close>p and close>open and close>=(high+low)/2 : high>p+atr*sweepATR and close<p and close<open and close<=(high+low)/2
            bool broke = bias==1 ? close>p and close[1]<=p : close<p and close[1]>=p
            rvolBlocks += enableBreak and broke and (na(rvol) or rvol<breakRV) ? 1 : 0
            bool eligibleBreak = enableBreak and broke and rvol>=breakRV and math.abs(close-p)<=atr*maxExtension
            bool eligibleSweep = enableSweep and swept
            bool overlap = eligibleBreak and eligibleSweep
            int kind = overlap ? (overlapPriority=="Sweep" ? 2 : 1) : eligibleSweep ? 2 : eligibleBreak ? 1 : 0
            if stable and kind!=0 and not f_used(p,bias)
                overlappingCandidates += overlap ? 1 : 0
                array.set(candidates,kind-1,array.get(candidates,kind-1)+1)
                array.push(pending,Setup.new(bias,kind,p,array.get(names,i),atr,kind==1 ? p : bias==1 ? low : high,volume,time_close,bar_index))
                if not str.contains(stage,"REJECT")
                    stage := "WAIT: retest"
                activeSetup := array.get(names,i)+(kind==1 ? " break/retest" : " sweep/retest")
                break
    if tradeSide!=0 and ((entry-stop)*tradeSide<=0 or (target-entry)*tradeSide<=0 or entryNetRR<minR-0.000001)
        runtime.error("Risk invariant failed: invalid simulated fill.")

// Current map only: historical zone origins remain the confirmation bars.
f_levelColor(string name) =>
    str.startswith(name,"PDH") ? pdhColor : str.startswith(name,"PDL") ? pdlColor : str.startswith(name,"PMH") ? pmhColor : str.startswith(name,"PML") ? pmlColor : str.startswith(name,"ORH") ? orhColor : str.startswith(name,"ORL") ? orlColor : str.startswith(name,"SH") ? shColor : slColor
var rays = array.new_line()
var tags = array.new_label()
var bands = array.new_box()
if barstate.islast
    for ray in rays
        line.delete(ray)
    for tag in tags
        label.delete(tag)
    for band in bands
        box.delete(band)
    array.clear(rays)
    array.clear(tags)
    array.clear(bands)
    if showMap and array.size(levels)>0
        levelOrder = array.sort_indices(levels,order.ascending)
        float lastLabelY = na
        for i in levelOrder
            float p = array.get(levels,i)
            float labelY = na(lastLabelY) or not (atr>0) ? p : math.max(p,lastLabelY+atr*labelGapATR)
            lastLabelY := labelY
            string caption = array.get(names,i)
            color c = f_levelColor(caption)
            int left = math.max(0,bar_index-mapBars)
            array.push(rays,line.new(left,p,bar_index+3,p,color=c,width=levelWidth))
            if labelY>p+syminfo.mintick
                array.push(rays,line.new(bar_index+1,p,bar_index+3,labelY,color=color.new(c,35),style=line.style_dotted))
            array.push(tags,label.new(bar_index+3,labelY,caption+" "+str.tostring(p,format.mintick),style=label.style_label_right,color=color.new(c,80),textcolor=c,size=levelFont=="Tiny" ? size.tiny : levelFont=="Normal" ? size.normal : size.small))
            if levelBands and atr>0
                array.push(bands,box.new(left,p+atr*bandATR,bar_index+3,p-atr*bandATR,bgcolor=color.new(c,bandAlpha),border_color=na))
    if array.size(zones)>0
        // Distance order keeps the nearest eligible levels visible when the cap is reached.
        distances = array.new_float()
        for z in zones
            float dist = z.side==1 ? math.max(0,z.bottom-close) : math.max(0,close-z.top)
            array.push(distances,dist)
            box.set_bgcolor(z.drawing,na)
            box.set_border_color(z.drawing,na)
            box.set_text(z.drawing,"")
        sortedIndices = array.sort_indices(distances,order.ascending)
        int shown = 0
        bool supplyShown = false
        bool demandShown = false
        for index in sortedIndices
            Zone z = array.get(zones,index)
            float dist = array.get(distances,index)
            bool sideAllowed = heatMode=="All active" or (z.side==1 ? not supplyShown : not demandShown)
            bool eligible = z.strength>=minHeat and (heatDistance==0 or dist<=atr*heatDistance)
            bool visible = showZones and sideAllowed and eligible and shown<heatCount
            if visible
                color base = color.from_gradient(z.strength,0,100,z.side==1 ? weakSupply : weakDemand,z.side==1 ? strongSupply : strongDemand)
                int transparency = int(math.round(weakAlpha+(strongAlpha-weakAlpha)*z.strength/100.0))
                box.set_right(z.drawing,bar_index+3)
                box.set_bgcolor(z.drawing,color.new(base,transparency))
                box.set_border_color(z.drawing,color.new(base,math.max(0,transparency-25)))
                box.set_text(z.drawing,heatLabels ? (z.side==1 ? "SUPPLY " : "DEMAND ")+str.tostring(z.strength,"#")+"/100 | "+str.tostring((z.top+z.bottom)/2,format.mintick) : "")
                box.set_text_color(z.drawing,heatText)
                box.set_text_size(z.drawing,size.tiny)
                box.set_text_halign(z.drawing,text.align_left)
                box.set_text_valign(z.drawing,text.align_center)
                shown += 1
                supplyShown := supplyShown or z.side==1
                demandShown := demandShown or z.side==-1

plot(showAverages ? vwap : na,"VWAP",vwapColor,2)
plot(showAverages ? ema9 : na,"EMA 9",fastColor,1)
plot(showAverages ? ema20 : na,"EMA 20",slowColor,1)
plot(tradeSide!=0 ? entry : na,"Entry reference",entryColor,2,plot.style_linebr)
plot(tradeSide!=0 ? stop : na,"Invalidation",stopColor,2,plot.style_linebr)
plot(tradeSide!=0 ? target : na,"Target",targetColor,2,plot.style_linebr)
plot(longSignal ? 1 : shortSignal ? -1 : 0,"Signal direction",display=display.data_window)
plot(signalR,"Plan net reward / total stop risk",display=display.data_window)

// CSV export: one complete trade record on each exit bar. Times are Unix milliseconds.
plot(fillDirection,"Simulated fill direction",display=display.data_window)
plot(exportID,"Closed trade ID",display=display.data_window)
plot(exportSignalTime,"Trade signal time ms",display=display.data_window)
plot(exportEntryTime,"Trade entry time ms",display=display.data_window)
plot(exportExitTime,"Trade exit time ms",display=display.data_window)
plot(exportKind,"Trade setup 1=retest 2=sweep",display=display.data_window)
plot(exportSide,"Trade side 1=long -1=short",display=display.data_window)
plot(exportEntry,"Trade entry price",display=display.data_window)
plot(exportStop,"Trade original stop",display=display.data_window)
plot(exportTarget,"Trade target price",display=display.data_window)
plot(exportExit,"Trade exit price",display=display.data_window)
plot(exportR,"Trade net R",display=display.data_window)
plot(exportReason,"Exit reason 1=stop 2=target 3=session 4=delayed session 5=date",display=display.data_window)
plot(rejectionCode,"Rejection code (see diagnostic table)",display=display.data_window)
plot(cumulativeR,"Cumulative closed-trade R",display=display.data_window)
plot(maxDrawdownR,"Maximum closed-trade drawdown R",display=display.data_window)

var table panel = table.new(panelPos=="Top Right" ? position.top_right : panelPos=="Bottom Left" ? position.bottom_left : position.bottom_right,2,20,bgcolor=panelBg,border_color=panelBorder,frame_color=panelBorder,frame_width=1,border_width=1)
var table ledger = table.new(position.middle_center,8,11,bgcolor=panelBg,border_color=panelBorder,border_width=1)
var table diagnostics = table.new(position.bottom_left,2,17,bgcolor=panelBg,border_color=panelBorder,border_width=1)
f_row(int row,string title,string value,color c) =>
    table.cell(panel,0,row,title,text_color=mutedText,text_size=size.tiny)
    table.cell(panel,1,row,value,text_color=c,text_size=size.tiny)
f_stats(int k) =>
    int n = array.get(counts,k)
    n==0 ? "0 closed" : str.tostring(n)+" | "+str.tostring(100.0*array.get(wins,k)/n,"#")+"% | "+str.tostring(array.get(netRs,k)/n,"#.##")+"R"
f_date(int t) =>
    na(t) ? "--" : str.format_time(t,"yy-MM-dd HH:mm",tz)
f_diag(int row,string title,string value) =>
    table.cell(diagnostics,0,row,title,text_color=mutedText,text_size=size.tiny)
    table.cell(diagnostics,1,row,value,text_color=panelText,text_size=size.tiny)
if barstate.islast
    table.clear(panel,0,0,1,19)
    table.clear(ledger,0,0,7,10)
    table.clear(diagnostics,0,0,1,16)
    int closed = array.sum(counts)
    string pf = negativeR>0 ? str.tostring(positiveR/negativeR,"#.##") : positiveR>0 ? "No losses yet" : "--"
    // GO is a new bar-close-confirmed PLAN, never a stale active-position signal.
    string decision = "WAIT"
    string decisionReason = "Watching for setup"
    bool freshGo = barstate.isconfirmed and (longSignal or shortSignal)
    if not marketOK
        decision := "NO GO"
        decisionReason := "US stocks / ETFs only"
    else if not chartOK
        decision := "NO GO"
        decisionReason := "Use standard 1-5m candles"
    else if not htfOK
        decision := "NO GO"
        decisionReason := "Raise bias timeframe"
    else if not inTest
        decision := "NO GO"
        decisionReason := "Outside test dates"
    else if freshGo
        decision := "GO"
        decisionReason := longSignal ? "LONG plan confirmed" : "SHORT plan confirmed"
    else if tradeSide!=0
        decisionReason := tradeSide==1 ? "Managing LONG guide" : "Managing SHORT guide"
    else if not inWindow
        decision := "NO GO"
        decisionReason := "Outside signal hours"
    else if not warmedUp
        decisionReason := "Warming up"
    else if not ready
        decisionReason := "Waiting for session data"
    else if rejectionCode>0
        decision := "NO GO"
        decisionReason := lastReject
    else if not na(queued)
        decisionReason := "Awaiting simulated fill"
    else if cap>0 and signalsToday>=cap
        decision := "NO GO"
        decisionReason := "Daily plan limit reached"
    else if not na(lastSignalTime) and time_close-lastSignalTime<cooldownMin*60000
        decisionReason := "Cooldown"
    else if not barstate.isconfirmed
        decisionReason := "Waiting for bar close"
    else if bias==0
        decisionReason := "Mixed bias"
    else if stage=="WAIT: retest"
        decisionReason := "Waiting for retest"
    else if stage=="WAIT: confirmation"
        decisionReason := "Waiting for confirmation"
    color decisionColor = decision=="GO" ? bull : decision=="NO GO" ? bear : warningColor
    if showPanel and not showLedger and dashboardMode=="Compact"
        table.cell(panel,0,0,"JRC ONE",text_color=panelText,text_size=size.small,bgcolor=panelBg)
        table.cell(panel,1,0,decision,text_color=decision=="WAIT" ? color.rgb(18,23,31) : color.white,text_size=size.large,bgcolor=color.new(decisionColor,10))
        table.cell(panel,0,1,"Reason",text_color=mutedText,text_size=size.small)
        table.cell(panel,1,1,decisionReason,text_color=panelText,text_size=size.small)
        bool displayRisk = tradeSide!=0 or freshGo and not na(queued)
        float displayStop = tradeSide!=0 ? stop : not na(queued) ? queued.stopPrice : na
        float displayTarget = tradeSide!=0 ? target : not na(queued) ? queued.targetPrice : na
        table.cell(panel,0,2,displayRisk ? "Stop / Target" : "Bias",text_color=mutedText,text_size=size.small)
        table.cell(panel,1,2,displayRisk ? str.tostring(displayStop,format.mintick)+" / "+str.tostring(displayTarget,format.mintick) : (not htfOK ? "--" : bias==1 ? "BULL" : bias==-1 ? "BEAR" : "MIXED")+" | "+contextTF+"m",text_color=panelText,text_size=size.small)
    if showPanel and not showLedger and dashboardMode=="Detailed"
        f_row(0,"JRC ONE v1.1",barstate.isconfirmed ? "BAR CONFIRMED" : "Live bar: wait for close",panelText)
        f_row(1,"State",stage,not marketOK or not chartOK ? bear : warningColor)
        f_row(2,"Market / bias",(marketOK ? "US equity" : "UNSUPPORTED")+" / "+(not htfOK ? "N/A" : bias==1 ? "BULL" : bias==-1 ? "BEAR" : "MIXED"),panelText)
        f_row(3,"Fill model","Next open + "+str.tostring(delayBars)+" bars; SIM ONLY",mutedText)
        f_row(4,"Setup / plans today",activeSetup+" | "+str.tostring(signalsToday)+(cap>0 ? "/"+str.tostring(cap) : ""),panelText)
        f_row(5,"Entry / stop",tradeSide==0 ? "--" : str.tostring(entry,format.mintick)+" / "+str.tostring(stop,format.mintick),panelText)
        f_row(6,"Target / net RR",tradeSide==0 ? "--" : str.tostring(target,format.mintick)+" / "+str.tostring(entryNetRR,"#.##"),panelText)
        if showStats
            f_row(7,"Retest: n / win / avg R",f_stats(0),mutedText)
            f_row(8,"Sweep: n / win / avg R",f_stats(1),mutedText)
            f_row(9,"Total closed R / R PF",str.tostring(cumulativeR,"#.##")+" / "+pf,mutedText)
            f_row(10,"Closed DD R / max losses",str.tostring(maxDrawdownR,"#.##")+" / "+str.tostring(maxLossStreak),mutedText)
            f_row(11,"Requested NY dates",f_date(testStart)+" to "+f_date(testEnd),mutedText)
            f_row(12,"Loaded from / coverage",f_date(firstLoadedTime)+(firstLoadedTime>testStart ? " | PARTIAL START" : " | start loaded")+(time_close<testEnd ? " | PARTIAL END" : ""),warningColor)
            f_row(13,"First eligible / last test bar",f_date(firstEligibleTime)+" / "+f_date(lastTestBarTime),mutedText)
            f_row(14,"Sample / open guide",str.tostring(closed)+(closed<sampleWarning ? " SMALL SAMPLE" : " closed; validate out-of-sample")+(tradeSide!=0 ? " | 1 OPEN" : " | 0 open"),closed<sampleWarning ? warningColor : mutedText)
            f_row(15,"Last outcome",lastOutcome,mutedText)
            f_row(16,"Last rejection",lastReject,warningColor)
            f_row(17,"Armed R/S; rejected R/S",str.tostring(array.get(candidates,0))+"/"+str.tostring(array.get(candidates,1))+"; "+str.tostring(array.get(rejectedBySetup,0))+"/"+str.tostring(array.get(rejectedBySetup,1)),mutedText)
            f_row(18,"Both-hit / delayed session exits",str.tostring(ambiguous)+" / "+str.tostring(delayedSessionExits),warningColor)
            f_row(19,"Costs: slip / spread / fee",str.tostring(slipTicks)+" ticks / "+str.tostring(spreadTicks)+" ticks / "+str.tostring(feeBps)+" bps per side",mutedText)
    if showLedger
        headers = array.from("ID / type","Side","Entry NY","Exit NY","Entry","Exit","Net R","Reason")
        for c=0 to 7
            table.cell(ledger,c,0,array.get(headers,c),text_color=panelText,text_size=size.tiny)
        if array.size(ledgerID)>0
            for n=0 to array.size(ledgerID)-1
                int i = array.size(ledgerID)-1-n
                int row = n+1
                color c = array.get(ledgerR,i)>0 ? bull : bear
                table.cell(ledger,0,row,str.tostring(array.get(ledgerID,i))+" / "+(array.get(ledgerKind,i)==1 ? "R" : "S"),text_color=panelText,text_size=size.tiny)
                table.cell(ledger,1,row,array.get(ledgerSide,i)==1 ? "LONG" : "SHORT",text_color=panelText,text_size=size.tiny)
                table.cell(ledger,2,row,f_date(array.get(ledgerEntryTime,i)),text_color=mutedText,text_size=size.tiny)
                table.cell(ledger,3,row,f_date(array.get(ledgerExitTime,i)),text_color=mutedText,text_size=size.tiny)
                table.cell(ledger,4,row,str.tostring(array.get(ledgerEntry,i),format.mintick),text_color=panelText,text_size=size.tiny)
                table.cell(ledger,5,row,str.tostring(array.get(ledgerExit,i),format.mintick),text_color=panelText,text_size=size.tiny)
                table.cell(ledger,6,row,str.tostring(array.get(ledgerR,i),"#.##"),text_color=c,text_size=size.tiny)
                table.cell(ledger,7,row,array.get(ledgerReason,i),text_color=mutedText,text_size=size.tiny)
    if showDiagnostics and not showLedger
        f_diag(0,"REJECTIONS / evaluated blocks","Count")
        rejectNames = array.from("1 Setup invalidated","2 Setup expired","3 Bias changed","4 Entry extended","5 Stop distance","6 Net reward too low","7 Costs too large","8 Session/date/gap","9 Level used")
        for i=0 to 8
            f_diag(i+1,array.get(rejectNames,i),str.tostring(array.get(rejected,i)))
        f_diag(10,"Armed retest / sweep",str.tostring(array.get(candidates,0))+" / "+str.tostring(array.get(candidates,1)))
        f_diag(11,"Planned retest / sweep",str.tostring(array.get(confirmations,0))+" / "+str.tostring(array.get(confirmations,1)))
        f_diag(12,"Overlaps; priority",str.tostring(overlappingCandidates)+"; "+overlapPriority)
        f_diag(13,"Break RVOL blocks (events)",str.tostring(rvolBlocks))
        f_diag(14,"Quiet retest blocks (bars)",str.tostring(quietBlocks))
        f_diag(15,"VWAP/EMA blocks (bars)",str.tostring(trendBlocks))
        f_diag(16,"CSV: filter Closed trade ID","Exit rows = trade ledger")
if (longSignal or shortSignal) and not na(queued)
    alert("JRC ONE v1.1 PLAN "+(longSignal ? "LONG" : "SHORT")+" | "+syminfo.tickerid+" | "+queued.description+" | Stop "+str.tostring(queued.stopPrice,format.mintick)+" | Target "+str.tostring(queued.targetPrice,format.mintick)+" | Next-open simulation + "+str.tostring(delayBars)+" bars; revalidate actual execution",alert.freq_once_per_bar_close)
alertcondition(longSignal,"JRC ONE Long plan","JRC ONE confirmed LONG PLAN on {{ticker}}. Not an executed fill; revalidate price and costs.")
alertcondition(shortSignal,"JRC ONE Short plan","JRC ONE confirmed SHORT PLAN on {{ticker}}. Not an executed fill; revalidate price and costs.")
````
