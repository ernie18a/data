# Support Resistance Reversal [erdensedat]

- url: https://www.tradingview.com/script/DGwvLHp3-Support-Resistance-Reversal-erdensedat/
- type: indicator
- pine_id: PUB;72bb20af49074640a69075f4be30badd
- version: 1.0

## Description

Overview
The Support Resistance Reversal [erdensedat] is a highly advanced, institutional-grade Price Action and Liquidity Engine. Designed to filter out market noise, it focuses on tracking genuine liquidity sweeps, volatility compression, and momentum shifts. Instead of plotting a chaotic heatmap of every minor pivot, this system intelligently isolates only the most relevant unbroken structures to provide high-probability breakout and reversal signals.

Core Mechanics
The "Rule of 3" Target System: The indicator keeps the chart exceptionally clean by only displaying up to three active pairs of lines at any given time:
The latest freshly formed Pivot structure.
The closest historically unbroken Resistance (HH) above the current price.
The closest historically unbroken Support (LL) below the current price.
Double Layer Tracking: Each support/resistance is drawn as a double-layered zone (a solid line from the main pivot wick, and a dashed line from the subsequent confirmation candle). This allows the system to distinguish between minor liquidity sweeps (touching only the dashed line) and structural breaks (body closes beyond the solid line).
Fade-Out Memory: When a level is definitively broken by a candle body, it doesn't just disappear. It fades into a transparent state, acting as a historical footprint of where liquidity was absorbed.
Advanced Institutional Engines
Dynamic EQ (Equilibrium) Wall: The system calculates the exact midpoint (EQ) between the active Resistance and Support. Every time the price tests the EQ and fails to close beyond it, the EQ line thickens, visually representing a growing psychological barrier and liquidity compression.
POC Magnet (Point of Control): Within the active high/low range, the system dynamically tracks where the highest trading volume is occurring. This is plotted as a yellow dotted line, acting as the true gravitational center (magnet) of the current range, offering a prime Take Profit target.
FVG Imbalance Tracker: Automatically detects unmitigated Fair Value Gaps (FVGs) in the background. If a sweep signal occurs exactly inside one of these institutional voids, the signal is upgraded to an [A++] setup, indicating strong institutional backing.
MTF Liquidity Matrix: Projects Higher Timeframe (e.g., 4H) pivot structures directly onto your lower timeframe chart as thick dashed lines, ensuring you never trade blindly against macro liquidity pools.
Pro Features (Experimental Triggers)
These engines provide deep analytical insights into how a level is reacting, rather than just if it reacted:

Level Aging (Cold Breakouts): Tracks how long a level has been untouched. If a level survives for over 50 bars (customizable) and is finally broken, it fires a blue/fuchsia Diamond signal, indicating a "Vacuum Breakout" where old limit orders have decayed.
Volatility Spring (Compression): If the price remains trapped between the active top and bottom for a prolonged period, kinetic energy builds up. When the price finally breaks out, it prints a "SPRING" alert, catching violent volatility expansions.
Ghost Lines (Asymmetric Voids): Spots areas where the price reversed just before hitting your main liquidity lines. Plotted as purple dotted lines, these highlight hidden, front-run liquidity pockets.
High-Velocity Sweeps (Wick Velocity): Measures the wick-to-body ratio of rejection candles. If the price touches a line and violently rejects (leaving a massive wick and tiny body), it prints a yellow X-Cross, signaling aggressive institutional absorption.
Triple Sweep Exhaustion: If a dashed line is tested and rejected 3 times within a rapid 10-bar window, and the 3rd rejection candle has a healthy body size in the reversal direction, it triggers an immediate BUY/SELL text signal, anticipating an exhausted side of the market.
Dynamic Trendlines & Auto Risk/Reward
Upon confirming a valid setup, the system generates a Momentum Vector (Trendline) originating from the signal wick:

The line dynamically tracks the highs/lows of subsequent candles.
It automatically calculates the Risk/Reward (RR) ratio based on the entry close price, the wick stop-loss, and the opposing EQ/POC target.
Momentum Fading: If the trend loses momentum (slope flattens), the arrow and its label (showing "Strong" or "Weak" + RR) begin to fade out into transparency, keeping your chart clean from dead trades. Staggered labels prevent overlap during consecutive signals.
Strict Validation Rules
To prevent fake-outs, all standard triangle and text signals require strict candle body alignment:

BUY signals will only fire if the signal candle closes Green (Close > Open).
SELL signals will only fire if the signal candle closes Red (Close < Open).
Comprehensive Alert System
Fully modular alert conditions are built into the settings, allowing you to create custom server-side alerts for:

Standard Breakouts/Retests
Sweep & Reverses
High-Velocity Sweeps
Cold Level Breakouts
Triple Sweep Exhaustions
Simply set up a single "Confirmed Buy Alert" or "Confirmed Sell Alert" in TradingView, and the engine will route the notifications based on your exact toggle preferences.

Disclaimer: This script is provided for educational and informational purposes only. It is not financial or investment advice. Trading in financial markets involves a significant risk of loss. Always perform your own backtesting, risk management, and due diligence before executing any trades using live capital. Past performance is not indicative of future results.

## Source Code

````pine
//@version=6
indicator("Support Resistance Reversal [erdensedat]", overlay = true, max_lines_count = 500)

// --- WATERMARK ---
var table wmTable = table.new(position.bottom_right, 1, 1)
if barstate.islast
    table.cell(wmTable, 0, 0, "erdensedat", text_color=color.new(color.gray, 80), text_size=size.huge)

// --- ALERTS SETTINGS ---
grpAlerts = "Alert Conditions"
alertStd = input.bool(true, "Standard Breakout/Retest Alerts", group=grpAlerts, tooltip="Alerts for regular body closes crossing the active lines.")
alertSwp = input.bool(true, "Sweep & Reverse Alerts", group=grpAlerts, tooltip="Alerts when price wicks a line and closes back in the opposite direction.")
alertHv = input.bool(true, "High Velocity Sweep Alerts", group=grpAlerts, tooltip="Alerts for sweeps where the wick is significantly larger than the body.")
alertCold = input.bool(true, "Cold Breakout Alerts", group=grpAlerts, tooltip="Alerts when an old/decayed level is broken.")
alertTriple = input.bool(true, "Triple Sweep Alerts", group=grpAlerts, tooltip="Alerts when a dashed line is tested and rejected 3 times in a short window.")

// --- END-GAME FEATURES & INPUTS ---
grpEndGame = "End-Game Features"
usePoc = input.bool(true, "1. Dynamic POC Magnet", group=grpEndGame, tooltip="Displays the highest volume price level (POC) in the active range.")
colorPoc = input.color(color.new(color.yellow, 0), "POC Line Color", group=grpEndGame)
pocStyleStr = input.string("Dotted", "POC Line Style", options=["Solid", "Dashed", "Dotted"], group=grpEndGame)
pocStyle = pocStyleStr == "Solid" ? line.style_solid : pocStyleStr == "Dashed" ? line.style_dashed : line.style_dotted

useFvg = input.bool(true, "2. FVG Imbalance Tracker", group=grpEndGame, tooltip="Draws unmitigated FVG gaps and marks signals inside them as A++.")
useMtf = input.bool(true, "3. MTF Liquidity Matrix", group=grpEndGame, tooltip="Displays higher timeframe (HTF) support/resistance levels as thick lines.")
htfRes = input.timeframe("240", "HTF Resolution", group=grpEndGame)
useRr = input.bool(true, "4. Auto RR Assistant", group=grpEndGame, tooltip="Calculates Risk/Reward (RR) ratio for signals and displays it on the trend arrows.")
useTrendlines = input.bool(true, "5. Show Momentum Trendlines", group=grpEndGame, tooltip="Toggles the visibility of dynamic trendlines (arrows) and their labels.")

// --- PRO FEATURES & INPUTS ---
grpPro = "Pro Features (Experimental)"
useDecay = input.bool(true, "1. Level Aging (Cold Breakouts)", group=grpPro, tooltip="Fires a diamond signal when old (decayed) levels are broken.")
decayBars = input.int(50, "Cold Level Threshold (Bars)", group=grpPro)

useSpring = input.bool(true, "2. Volatility Spring (Compression)", group=grpPro, tooltip="Displays a SPRING alert on breakout when price compresses between two main levels for a long time.")
springBars = input.int(20, "Min Bars in Range for Spring", group=grpPro)

useGhost = input.bool(true, "3. Ghost Lines (Asymmetric Void)", group=grpPro, tooltip="Draws purple dotted lines at weak points where price reverses before reaching the main support/resistance. These are hidden liquidities.")

useWickVel = input.bool(true, "4. Wick Velocity (High Energy Sweep)", group=grpPro, tooltip="Fires an xcross signal on high velocity (fast) rejections with strong wicks.")
wickRatio = input.float(2.0, "Min Wick/Body Ratio", group=grpPro)

minSweepBodyRatio = input.float(0.25, "Min Body Ratio for Triple Sweep Signal", group=grpPro, tooltip="Minimum required ratio of body size to total candle size to trigger a BUY/SELL on a triple sweep.")

// --- STANDARD INPUTS ---
leftLen = input.int(15, "Pivot Left Length")
rightLen = input.int(15, "Pivot Right Length")
sameLevelPct = input.float(0.1, "Same Level Threshold (%)") / 100
tooClosePct = input.float(0.05, "Wick Too Close Threshold (%)", tooltip="If solid and dashed lines are too close, the 2nd line is drawn from the 2nd candle's body.") / 100
fadeTransp = input.int(70, "Faded Line Transparency", minval=0, maxval=100)

lblSizeInput = input.string("Normal", "Trend Label Size", options=["Tiny", "Small", "Normal", "Large"])
lblSize = lblSizeInput == "Tiny" ? size.tiny : lblSizeInput == "Small" ? size.small : lblSizeInput == "Large" ? size.large : size.normal

colorPl = input.color(#089981, "Pivot Low Line Color")
colorPh = input.color(#f23645, "Pivot High Line Color")
colorSweep = input.color(color.new(color.orange, 0), "Sweep Marker Color")
colorEq = input.color(color.new(color.gray, 0), "EQ Line Color")

type PivotData
    float val1
    float val2
    int time1
    int time2
    int bar1
    int bar2
    bool isPl
    int id
    int firstDashedSweepBar
    int dashedSweepCount

var activePivots = array.new<PivotData>()
var int globalId = 0

// Pivot Detection
pl = ta.pivotlow(low, leftLen, rightLen)
ph = ta.pivothigh(high, leftLen, rightLen)

f_isSameLevel(float newVal, bool isPl) =>
    bool same = false
    if activePivots.size() > 0
        for i = 0 to activePivots.size() - 1
            p = activePivots.get(i)
            if p.isPl == isPl
                if (math.abs(newVal - p.val1) / p.val1) <= sameLevelPct or (math.abs(newVal - p.val2) / p.val2) <= sameLevelPct
                    same := true
    same

// --- FVG LOGIC ---
type FVGData
    float top
    float bot
    bool isBull
    box b
    int barIndex

var activeFVGs = array.new<FVGData>()

if useFvg
    // Bullish FVG
    if low > high[2]
        b = box.new(bar_index[2], low, bar_index, high[2], bgcolor=color.new(colorPl, 85), border_color=na)
        activeFVGs.push(FVGData.new(low, high[2], true, b, bar_index))
    // Bearish FVG
    if high < low[2]
        b = box.new(bar_index[2], high, bar_index, low[2], bgcolor=color.new(colorPh, 85), border_color=na)
        activeFVGs.push(FVGData.new(high, low[2], false, b, bar_index))

    // Mitigate/Remove FVGs
    if activeFVGs.size() > 0
        for i = activeFVGs.size() - 1 to 0
            f = activeFVGs.get(i)
            if f.isBull and low < f.bot
                f.b.delete()
                activeFVGs.remove(i)
            else if not f.isBull and high > f.top
                f.b.delete()
                activeFVGs.remove(i)
            else
                f.b.set_right(bar_index)

f_isInFVG(float pPrice) =>
    bool inFvg = false
    if activeFVGs.size() > 0
        for i = 0 to activeFVGs.size() - 1
            f = activeFVGs.get(i)
            if pPrice <= f.top and pPrice >= f.bot
                inFvg := true
    inFvg

// --- MTF LOGIC ---
htfPl = request.security(syminfo.tickerid, htfRes, ta.pivotlow(low, 5, 5))
htfPh = request.security(syminfo.tickerid, htfRes, ta.pivothigh(high, 5, 5))
var float lastHtfPl = na
var float lastHtfPh = na
if not na(htfPl)
    lastHtfPl := htfPl
if not na(htfPh)
    lastHtfPh := htfPh

var line l_htfPl = line.new(na, na, na, na, xloc=xloc.bar_time, color=color.new(colorPl, 30), width=3, style=line.style_dashed)
var line l_htfPh = line.new(na, na, na, na, xloc=xloc.bar_time, color=color.new(colorPh, 30), width=3, style=line.style_dashed)

if useMtf and not na(lastHtfPl)
    l_htfPl.set_xy1(time[10], lastHtfPl)
    l_htfPl.set_xy2(time, lastHtfPl)
else
    l_htfPl.set_color(na)

if useMtf and not na(lastHtfPh)
    l_htfPh.set_xy1(time[10], lastHtfPh)
    l_htfPh.set_xy2(time, lastHtfPh)
else
    l_htfPh.set_color(na)

// --- GHOST LINES TRACKING ---
var float ghostTop = na
var int ghostTopTime = na
var float ghostBot = na
var int ghostBotTime = na

bool tripleSweepBuySig = false
bool tripleSweepSellSig = false

// --- PIVOT LOW LOGIC ---
if not na(pl)
    pivotLowVal = low[rightLen]
    nextBarLow = low[rightLen - 1]
    isSame = f_isSameLevel(pivotLowVal, true)
    
    if not isSame and nextBarLow >= pivotLowVal
        val1 = pivotLowVal
        val2 = nextBarLow
        if math.abs(val2 - val1) / val1 <= tooClosePct
            val2 := math.min(open[rightLen - 1], close[rightLen - 1])
            
        globalId += 1
        activePivots.push(PivotData.new(val1, val2, time[rightLen], time[rightLen - 1], bar_index[rightLen], bar_index[rightLen - 1], true, globalId, na, 0))
    else if isSame and useGhost
        ghostBot := pivotLowVal
        ghostBotTime := time[rightLen]

// --- PIVOT HIGH LOGIC ---
if not na(ph)
    pivotHighVal = high[rightLen]
    nextBarHigh = high[rightLen - 1]
    isSame = f_isSameLevel(pivotHighVal, false)
    
    if not isSame and nextBarHigh <= pivotHighVal
        val1 = pivotHighVal
        val2 = nextBarHigh
        if math.abs(val2 - val1) / val1 <= tooClosePct
            val2 := math.max(open[rightLen - 1], close[rightLen - 1])
            
        globalId += 1
        activePivots.push(PivotData.new(val1, val2, time[rightLen], time[rightLen - 1], bar_index[rightLen], bar_index[rightLen - 1], false, globalId, na, 0))
    else if isSame and useGhost
        ghostTop := pivotHighVal
        ghostTopTime := time[rightLen]

// --- CHECK SWEEPS & BREAKOUTS ---
if activePivots.size() > 0
    for i = activePivots.size() - 1 to 0
        p = activePivots.get(i)
        
        broken1 = false
        
        if p.isPl
            if low < p.val1 and close >= p.val1 and bar_index > p.bar1
                label.new(time, low, text="x", style=label.style_none, textcolor=colorSweep, size=size.normal, xloc=xloc.bar_time)
            else if low < p.val2 and close >= p.val2 and bar_index > p.bar2
                label.new(time, low, text="+", style=label.style_none, textcolor=colorSweep, size=size.tiny, xloc=xloc.bar_time)
                
                if na(p.firstDashedSweepBar) or (bar_index - p.firstDashedSweepBar > 10)
                    p.firstDashedSweepBar := bar_index
                    p.dashedSweepCount := 1
                else
                    p.dashedSweepCount += 1
                    if p.dashedSweepCount >= 3
                        bodySize = math.abs(close - open)
                        candleSize = high - low
                        if bodySize >= candleSize * minSweepBodyRatio and close > open
                            label.new(time, low, text="BUY", style=label.style_label_up, color=colorPl, textcolor=color.white, size=size.tiny, xloc=xloc.bar_time)
                            tripleSweepBuySig := true
                            p.dashedSweepCount := 0 
                
            if close < p.val1 and bar_index > p.bar1
                broken1 := true
                
            if broken1
                label.new(time, high, text="Break", style=label.style_label_down, color=color.new(color.black, 100), textcolor=colorPh, size=size.tiny, xloc=xloc.bar_time)
                line.new(p.time1, p.val1, time, p.val1, xloc=xloc.bar_time, color=color.new(colorPl, fadeTransp), style=line.style_solid)
                line.new(p.time2, p.val2, time, p.val2, xloc=xloc.bar_time, color=color.new(colorPl, fadeTransp), style=line.style_dashed)
                activePivots.remove(i)
        else
            if high > p.val1 and close <= p.val1 and bar_index > p.bar1
                label.new(time, high, text="x", style=label.style_none, textcolor=colorSweep, size=size.normal, xloc=xloc.bar_time)
            else if high > p.val2 and close <= p.val2 and bar_index > p.bar2
                label.new(time, high, text="+", style=label.style_none, textcolor=colorSweep, size=size.tiny, xloc=xloc.bar_time)
                
                if na(p.firstDashedSweepBar) or (bar_index - p.firstDashedSweepBar > 10)
                    p.firstDashedSweepBar := bar_index
                    p.dashedSweepCount := 1
                else
                    p.dashedSweepCount += 1
                    if p.dashedSweepCount >= 3
                        bodySize = math.abs(close - open)
                        candleSize = high - low
                        if bodySize >= candleSize * minSweepBodyRatio and close < open
                            label.new(time, high, text="SELL", style=label.style_label_down, color=colorPh, textcolor=color.white, size=size.tiny, xloc=xloc.bar_time)
                            tripleSweepSellSig := true
                            p.dashedSweepCount := 0 
                
            if close > p.val1 and bar_index > p.bar1
                broken1 := true
                
            if broken1
                label.new(time, low, text="Break", style=label.style_label_up, color=color.new(color.black, 100), textcolor=colorPl, size=size.tiny, xloc=xloc.bar_time)
                line.new(p.time1, p.val1, time, p.val1, xloc=xloc.bar_time, color=color.new(colorPh, fadeTransp), style=line.style_solid)
                line.new(p.time2, p.val2, time, p.val2, xloc=xloc.bar_time, color=color.new(colorPh, fadeTransp), style=line.style_dashed)
                activePivots.remove(i)

// --- FIND THE 3 TARGETS ---
PivotData latestP = na
PivotData nearestPh = na
PivotData nearestPl = na

int maxId = -1
float minPhDist = 9999999.0
float minPlDist = 9999999.0

if activePivots.size() > 0
    for i = 0 to activePivots.size() - 1
        p = activePivots.get(i)
        if p.id > maxId
            maxId := p.id
            latestP := p

    for i = 0 to activePivots.size() - 1
        p = activePivots.get(i)
        if na(latestP) or p.id != latestP.id
            if not p.isPl
                dist = math.abs(p.val1 - close)
                if dist < minPhDist
                    minPhDist := dist
                    nearestPh := p
            if p.isPl
                dist = math.abs(p.val1 - close)
                if dist < minPlDist
                    minPlDist := dist
                    nearestPl := p

float activeTop = na
float activeBot = na

if not na(latestP)
    if latestP.isPl
        activeBot := latestP.val1
    else
        activeTop := latestP.val1

if not na(nearestPh)
    if na(activeTop) or nearestPh.val1 < activeTop
        activeTop := nearestPh.val1

if not na(nearestPl)
    if na(activeBot) or nearestPl.val1 > activeBot
        activeBot := nearestPl.val1

// --- POC LOGIC ---
var float pocPrice = na
var float maxVol = 0
var int pocStartTime = na

if not na(activeTop) and not na(activeBot)
    bool isNewRange = na(pocStartTime) or (activeTop != activeTop[1]) or (activeBot != activeBot[1])
    if isNewRange
        maxVol := 0
        pocStartTime := time
    
    if volume > maxVol
        maxVol := volume
        pocPrice := hl2

// --- EQ LOGIC ---
var float currentEq = na
var int eqWidth = 1
var int lastBounceDir = 0
var int eqStartTime = na

float newEq = na
if not na(activeTop) and not na(activeBot)
    newEq := (activeTop + activeBot) / 2

if not na(newEq) and (na(currentEq) or math.abs(newEq - currentEq) > 0.0001)
    currentEq := newEq
    eqWidth := 1
    lastBounceDir := 0
    eqStartTime := time

if not na(activeBot) and low <= activeBot
    lastBounceDir := 1
if not na(activeTop) and high >= activeTop
    lastBounceDir := -1

var int lastEqTestBar = na
if not na(currentEq)
    if lastBounceDir == 1
        if high >= currentEq and close < currentEq and bar_index > lastEqTestBar
            eqWidth := math.min(eqWidth + 1, 10)
            lastEqTestBar := bar_index
    else if lastBounceDir == -1
        if low <= currentEq and close > currentEq and bar_index > lastEqTestBar
            eqWidth := math.min(eqWidth + 1, 10)
            lastEqTestBar := bar_index

// --- VOLATILITY SPRING LOGIC ---
var int rangeStartBar = na
if (not na(activeTop) and activeTop != activeTop[1]) or (not na(activeBot) and activeBot != activeBot[1])
    rangeStartBar := bar_index

bool springBreakUp = false
bool springBreakDown = false
if useSpring and not na(rangeStartBar) and (bar_index - rangeStartBar) >= springBars
    if close > activeTop and close[1] <= activeTop
        springBreakUp := true
        rangeStartBar := bar_index
    if close < activeBot and close[1] >= activeBot
        springBreakDown := true
        rangeStartBar := bar_index

// --- DRAW ACTIVE LINES ---
var line l_latest1 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_solid)
var line l_latest2 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dashed)
var line l_ph1 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_solid)
var line l_ph2 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dashed)
var line l_pl1 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_solid)
var line l_pl2 = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dashed)
var line l_eq = line.new(na, na, na, na, xloc=xloc.bar_time, style=line.style_dotted)
var line l_poc = line.new(na, na, na, na, xloc=xloc.bar_time, width=2)
var line l_ghostTop = line.new(na, na, na, na, xloc=xloc.bar_time, color=color.new(color.purple, 40), style=line.style_dotted)
var line l_ghostBot = line.new(na, na, na, na, xloc=xloc.bar_time, color=color.new(color.purple, 40), style=line.style_dotted)

if not na(latestP)
    l_latest1.set_xy1(latestP.time1, latestP.val1)
    l_latest1.set_xy2(time, latestP.val1)
    l_latest1.set_color(latestP.isPl ? colorPl : colorPh)
    l_latest2.set_xy1(latestP.time2, latestP.val2)
    l_latest2.set_xy2(time, latestP.val2)
    l_latest2.set_color(latestP.isPl ? colorPl : colorPh)
else
    l_latest1.set_color(na)
    l_latest2.set_color(na)

if not na(nearestPh)
    l_ph1.set_xy1(nearestPh.time1, nearestPh.val1)
    l_ph1.set_xy2(time, nearestPh.val1)
    l_ph1.set_color(colorPh)
    l_ph2.set_xy1(nearestPh.time2, nearestPh.val2)
    l_ph2.set_xy2(time, nearestPh.val2)
    l_ph2.set_color(colorPh)
else
    l_ph1.set_color(na)
    l_ph2.set_color(na)

if not na(nearestPl)
    l_pl1.set_xy1(nearestPl.time1, nearestPl.val1)
    l_pl1.set_xy2(time, nearestPl.val1)
    l_pl1.set_color(colorPl)
    l_pl2.set_xy1(nearestPl.time2, nearestPl.val2)
    l_pl2.set_xy2(time, nearestPl.val2)
    l_pl2.set_color(colorPl)
else
    l_pl1.set_color(na)
    l_pl2.set_color(na)

if not na(currentEq)
    l_eq.set_xy1(eqStartTime, currentEq)
    l_eq.set_xy2(time, currentEq)
    l_eq.set_color(colorEq)
    l_eq.set_width(eqWidth)
else
    l_eq.set_color(na)

if usePoc and not na(pocPrice) and not na(pocStartTime)
    l_poc.set_xy1(pocStartTime, pocPrice)
    l_poc.set_xy2(time, pocPrice)
    l_poc.set_color(colorPoc)
    l_poc.set_style(pocStyle)
else
    l_poc.set_color(na)

if useGhost and not na(ghostTop)
    l_ghostTop.set_xy1(ghostTopTime, ghostTop)
    l_ghostTop.set_xy2(time, ghostTop)
else
    l_ghostTop.set_color(na)

if useGhost and not na(ghostBot)
    l_ghostBot.set_xy1(ghostBotTime, ghostBot)
    l_ghostBot.set_xy2(time, ghostBot)
else
    l_ghostBot.set_color(na)


// --- RAW TRADING SIGNALS EVALUATION ---
var float pendingBuyLvl = na
var float pendingSellLvl = na

bool buySig = false, sellSig = false
bool sweepBuySig = false, sweepSellSig = false
bool hvBuySig = false, hvSellSig = false
bool coldBuySig = false, coldSellSig = false

// For Auto RR
var float lastSigSl = na
float currentSl = na

if not na(pendingBuyLvl)
    if close > pendingBuyLvl and close > open
        buySig := true
    pendingBuyLvl := na

if not na(pendingSellLvl)
    if close < pendingSellLvl and close < open
        sellSig := true
    pendingSellLvl := na

f_evalSigs(PivotData p) =>
    bSig = false, sSig = false
    swBuy = false, swSell = false
    float pBuy = na, float pSell = na
    hvBuy = false, hvSell = false
    coldBuy = false, coldSell = false
    float sl = na
    
    if not na(p) and bar_index > p.bar1
        isCold = useDecay and (bar_index - p.bar1) > decayBars
        if p.isPl
            if low < p.val1 and close > p.val2
                if close > open
                    bSig := true
                    sl := low
                    if isCold
                        coldBuy := true
                else
                    pBuy := p.val2
            
            if low < p.val1 and close > open and close <= p.val2
                swBuy := true
                sl := low
                wick = math.min(open, close) - low
                body = math.abs(close - open)
                if useWickVel and (body == 0 or wick / body >= wickRatio)
                    hvBuy := true

        else
            if high > p.val1 and close < p.val2
                if close < open
                    sSig := true
                    sl := high
                    if isCold
                        coldSell := true
                else
                    pSell := p.val2
                    
            if high > p.val1 and close < open and close >= p.val2
                swSell := true
                sl := high
                wick = high - math.max(open, close)
                body = math.abs(close - open)
                if useWickVel and (body == 0 or wick / body >= wickRatio)
                    hvSell := true
                
    [bSig, sSig, swBuy, swSell, pBuy, pSell, hvBuy, hvSell, coldBuy, coldSell, sl]

[b1, s1, swb1, sws1, pb1, ps1, hvb1, hvs1, cb1, cs1, sl1] = f_evalSigs(latestP)
[b2, s2, swb2, sws2, pb2, ps2, hvb2, hvs2, cb2, cs2, sl2] = f_evalSigs(nearestPh)
[b3, s3, swb3, sws3, pb3, ps3, hvb3, hvs3, cb3, cs3, sl3] = f_evalSigs(nearestPl)

if b1 or b2 or b3
    buySig := true
if s1 or s2 or s3
    sellSig := true
if swb1 or swb2 or swb3
    sweepBuySig := true
if sws1 or sws2 or sws3
    sweepSellSig := true
if hvb1 or hvb2 or hvb3
    hvBuySig := true
if hvs1 or hvs2 or hvs3
    hvSellSig := true
if cb1 or cb2 or cb3
    coldBuySig := true
if cs1 or cs2 or cs3
    coldSellSig := true

if not na(sl1)
    currentSl := sl1
else if not na(sl2)
    currentSl := sl2
else if not na(sl3)
    currentSl := sl3

if not na(pb1)
    pendingBuyLvl := pb1
if not na(pb2)
    pendingBuyLvl := pb2
if not na(pb3)
    pendingBuyLvl := pb3

if not na(ps1)
    pendingSellLvl := ps1
if not na(ps2)
    pendingSellLvl := ps2
if not na(ps3)
    pendingSellLvl := ps3

bool anyBuy = buySig or sweepBuySig or hvBuySig or coldBuySig or tripleSweepBuySig
bool anySell = sellSig or sweepSellSig or hvSellSig or coldSellSig or tripleSweepSellSig

// --- DYNAMIC TRENDLINE & AUTO RR LOGIC ---
type ActiveTrend
    int startBar
    int startTime
    float startY
    int dir
    line tl
    label lbl
    float maxSlope
    int offsetMult
    float sl
    float tp
    bool fvgBoost

var activeTrends = array.new<ActiveTrend>()

if useTrendlines
    if anyBuy
        float tpLevel = not na(activeTop) ? activeTop : (not na(currentEq) ? currentEq : na)
        bool isFvg = useFvg and f_isInFVG(low)
        tl = line.new(x1=time, y1=low, x2=time, y2=low, xloc=xloc.bar_time, color=colorPl, style=line.style_arrow_right, width=2)
        lbl = label.new(x=time, y=low, text="Strong", xloc=xloc.bar_time, color=color.new(color.black, 100), style=label.style_label_up, textcolor=colorPl, size=lblSize)
        activeTrends.push(ActiveTrend.new(bar_index, time, low, 1, tl, lbl, 0.0, activeTrends.size() % 3, currentSl, tpLevel, isFvg))

    if anySell
        float tpLevel = not na(activeBot) ? activeBot : (not na(currentEq) ? currentEq : na)
        bool isFvg = useFvg and f_isInFVG(high)
        tl = line.new(x1=time, y1=high, x2=time, y2=high, xloc=xloc.bar_time, color=colorPh, style=line.style_arrow_right, width=2)
        lbl = label.new(x=time, y=high, text="Strong", xloc=xloc.bar_time, color=color.new(color.black, 100), style=label.style_label_down, textcolor=colorPh, size=lblSize)
        activeTrends.push(ActiveTrend.new(bar_index, time, high, -1, tl, lbl, 0.0, activeTrends.size() % 3, currentSl, tpLevel, isFvg))

if activeTrends.size() > 0
    for i = activeTrends.size() - 1 to 0
        tr = activeTrends.get(i)
        barsElapsed = bar_index - tr.startBar
        if barsElapsed > 0
            float currentSlope = na
            string strengthTxt = "Weak"
            string rrTxt = ""
            string fvgTxt = tr.fvgBoost ? " [A++]" : ""
            
            if tr.dir == 1 // Buy
                currentSlope := (low - tr.startY) / barsElapsed
                if currentSlope > tr.maxSlope
                    tr.maxSlope := currentSlope
                
                ratio = tr.maxSlope > 0 ? math.max(0, currentSlope / tr.maxSlope) : 0
                transp = 100 - int(ratio * 100)
                strengthTxt := ratio > 0.5 ? "Strong" : "Weak"
                
                if useRr and not na(tr.tp) and not na(tr.sl)
                    float risk = close > tr.sl ? close - tr.sl : 0
                    float reward = tr.tp > close ? tr.tp - close : 0
                    rr = risk > 0 ? reward / risk : 0
                    if rr > 0
                        rrTxt := " | RR: " + str.tostring(rr, "#.##")
                        if rr < 2.0
                            transp := math.max(transp, 60) 
                
                if currentSlope <= 0
                    transp := 100 // Dead trend
                    
                timeStep = time - time[1]
                int projBars = 1 
                int x2 = time + timeStep * projBars
                float y2 = tr.startY + currentSlope * (barsElapsed + projBars)
                
                tr.tl.set_xy2(x2, y2)
                tr.tl.set_color(color.new(colorPl, transp))
                
                // VERTICAL OFFSET TRICK TO PREVENT LABEL OVERLAP
                string prefix = tr.offsetMult == 1 ? "\n" : tr.offsetMult == 2 ? "\n\n" : ""
                int lblX = x2 + timeStep
                tr.lbl.set_xy(lblX, y2)
                tr.lbl.set_text(prefix + strengthTxt + fvgTxt + rrTxt)
                tr.lbl.set_textcolor(color.new(colorPl, transp))
                
                if transp >= 95 and barsElapsed > 5
                    tr.tl.delete()
                    tr.lbl.delete()
                    activeTrends.remove(i)
                    
            else // Sell
                currentSlope := (tr.startY - high) / barsElapsed
                if currentSlope > tr.maxSlope
                    tr.maxSlope := currentSlope
                
                ratio = tr.maxSlope > 0 ? math.max(0, currentSlope / tr.maxSlope) : 0
                transp = 100 - int(ratio * 100)
                strengthTxt := ratio > 0.5 ? "Strong" : "Weak"
                
                if useRr and not na(tr.tp) and not na(tr.sl)
                    float risk = tr.sl > close ? tr.sl - close : 0
                    float reward = close > tr.tp ? close - tr.tp : 0
                    rr = risk > 0 ? reward / risk : 0
                    if rr > 0
                        rrTxt := " | RR: " + str.tostring(rr, "#.##")
                        if rr < 2.0
                            transp := math.max(transp, 60) 
                
                if currentSlope <= 0
                    transp := 100
                    
                timeStep = time - time[1]
                int projBars = 1
                int x2 = time + timeStep * projBars
                float y2 = tr.startY - currentSlope * (barsElapsed + projBars)
                
                tr.tl.set_xy2(x2, y2)
                tr.tl.set_color(color.new(colorPh, transp))
                
                // VERTICAL OFFSET TRICK TO PREVENT LABEL OVERLAP
                string suffix = tr.offsetMult == 1 ? "\n" : tr.offsetMult == 2 ? "\n\n" : ""
                int lblX = x2 + timeStep
                tr.lbl.set_xy(lblX, y2)
                tr.lbl.set_text(strengthTxt + fvgTxt + rrTxt + suffix)
                tr.lbl.set_textcolor(color.new(colorPh, transp))
                
                if transp >= 95 and barsElapsed > 5
                    tr.tl.delete()
                    tr.lbl.delete()
                    activeTrends.remove(i)
else
    if activeTrends.size() > 0
        for i = activeTrends.size() - 1 to 0
            tr = activeTrends.get(i)
            tr.tl.delete()
            tr.lbl.delete()
            activeTrends.remove(i)

// --- PLOTTING FINAL SIGNALS ---
plotshape(coldBuySig, title="Cold Break Buy", style=shape.diamond, location=location.belowbar, color=color.aqua, size=size.small)
plotshape(coldSellSig, title="Cold Break Sell", style=shape.diamond, location=location.abovebar, color=color.fuchsia, size=size.small)

plotshape(hvBuySig, title="HV Sweep Buy", style=shape.xcross, location=location.belowbar, color=color.yellow, size=size.small)
plotshape(hvSellSig, title="HV Sweep Sell", style=shape.xcross, location=location.abovebar, color=color.yellow, size=size.small)

bool isStdBuy = buySig and not coldBuySig and not sweepBuySig
bool isStdSell = sellSig and not coldSellSig and not sweepSellSig
bool isSwpBuy = sweepBuySig and not hvBuySig
bool isSwpSell = sweepSellSig and not hvSellSig

plotshape(isStdBuy, title="Buy Signal", style=shape.triangleup, location=location.belowbar, color=colorPl, size=size.small)
plotshape(isStdSell, title="Sell Signal", style=shape.triangledown, location=location.abovebar, color=colorPh, size=size.small)

plotshape(isSwpBuy, title="Sweep Buy Signal", style=shape.triangleup, location=location.belowbar, color=colorPl, size=size.tiny)
plotshape(isSwpSell, title="Sweep Sell Signal", style=shape.triangledown, location=location.abovebar, color=colorPh, size=size.tiny)

// --- COMBINED ALERTS ---
bool alertBuy = (buySig and alertStd) or (sweepBuySig and alertSwp) or (hvBuySig and alertHv) or (coldBuySig and alertCold) or (tripleSweepBuySig and alertTriple)
bool alertSell = (sellSig and alertStd) or (sweepSellSig and alertSwp) or (hvSellSig and alertHv) or (coldSellSig and alertCold) or (tripleSweepSellSig and alertTriple)

alertcondition(alertBuy, title="Confirmed Buy Alert", message="Pivot System: BUY Signal Generated")
alertcondition(alertSell, title="Confirmed Sell Alert", message="Pivot System: SELL Signal Generated")
````
