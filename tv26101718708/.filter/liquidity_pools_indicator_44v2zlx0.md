# Liquidity Pools  Indicator

- url: https://www.tradingview.com/script/44V2zlx0-Liquidity-Pools-Indicator/
- type: indicator
- pine_id: PUB;61030cab30df4b73bf3b42864d8776ab
- version: 2.0

## Description

Liquidity Pools · BSL / SSL**

> *Liquidity is not a concept. It is the destination.*

---

**What is Liquidity?**

Every time a trader places a stop loss, they create liquidity. Stop losses sitting above swing highs are buy orders waiting to be triggered — that is Buy-Side Liquidity. Stop losses sitting below swing lows are sell orders waiting to be triggered — that is Sell-Side Liquidity.

Smart money and institutions need these pools to fill their large orders. They push price toward these clusters, trigger the stops, fill their positions against the crowd, and then reverse. This indicator maps exactly where those pools are sitting on your chart in real time.

---

**What It Plots**

🔵 **BSL — Buy-Side Liquidity**
Dotted blue line above every swing high. A cluster of buy stop orders rests here. Price is magnetically drawn to these levels before institutions distribute their positions.

🔴 **SSL — Sell-Side Liquidity**
Dotted red line below every swing low. A cluster of sell stop orders rests here. Price hunts these levels before institutions accumulate their positions.

🟡 **EQH · BSL — Equal Highs**
When two swing highs form at nearly the same price level, they are marked in gold as Equal Highs. This means double the stop cluster at one price — the highest conviction sell target on the chart. These are your A+ setups.

🟡 **EQL · SSL — Equal Lows**
When two swing lows form at nearly the same price level, they are marked in gold as Equal Lows. Double stop cluster below — the highest conviction buy target. Always watch these first.

⚡ **Sweep Detection**
When price breaks through a liquidity level and triggers those stops, the level turns faded and dashed, and the candle gets a background highlight. This is the most important signal in the indicator — a swept level means the hunt is complete and the real move is about to begin.

---

**How To Read The Chart**

Think of it this way. At any moment there are two types of levels on your chart:

**Active levels** — shown as solid or dotted lines. These are unswept pools. Price will seek these out.

**Swept levels** — shown as faded dashed lines. These pools have been consumed. They no longer attract price. Ignore them.

Your job is simple. Know where the nearest unswept BSL and SSL are relative to current price. That tells you where price wants to go next.

---

**How To Trade With It — Step by Step**

**Step 1 — Identify the draw**
Look at the chart and find the nearest unswept SSL below price and BSL above price. Ask yourself: which one is price more likely to reach first? That is your directional bias for the session.

**Step 2 — Prioritise EQH and EQL**
If there is an EQL (gold) below and a regular SSL (red) below, price will most likely go for the EQL first. Gold levels are always higher priority than regular levels because they hold more stops.

**Step 3 — Wait for the sweep**
Do not enter when price is simply approaching a level. Wait for price to actually break through it, trigger the stops, and then show a rejection. The sweep candle highlight tells you exactly when this happens.

**Step 4 — Drop to your entry timeframe**
Once the sweep candle fires on your main chart, drop to a lower timeframe (5 minute or 1 minute). Look for a structure break or displacement candle in the opposite direction. That is your entry signal.

**Step 5 — Target the opposite pool**
If you entered long after an SSL sweep, your take profit target is the nearest active BSL above. If you entered short after a BSL sweep, your target is the nearest active SSL below. Let price seek the next pool.

---

**Real Example — How A Trade Looks**

Price is trending down. You see an EQL (gold equal lows) sitting below. Price pushes down, pierces through those equal lows, triggers all the sell stops, then immediately reverses with a strong bullish candle — the sweep candle fires (background turns red). You drop to the 1 minute chart, see a bullish structure break, and enter long. Your target is the BSL sitting above. Price delivers.

That is the complete setup from start to finish.

---

**Settings Guide**

| Setting | What It Does | Recommended |
|---|---|---|
| Lookback Length | How many bars back to track levels | 106 (default) |
| Swing Pivot Bars | How sensitive the swing detection is | 5 for intraday, 10 for swing |
| EQH/EQL Tolerance % | How close two levels must be to qualify as equal | 0.03% default |
| Keep Swept Levels | Show faded levels after sweep for context | Off for clean charts |
| Highlight Sweep Candle | Colour the bar where the liquidity grab happens | Always ON |
| EQH/EQL Zone Boxes | Gold shaded zone between equal levels | ON for visibility |
| Info Panel | Live count of active and swept levels | ON |

---

**Tips**

- **Higher timeframe first.** Always identify BSL and SSL on the 1 hour chart before dropping to lower timeframes. The 1 hour pools are the ones institutions care about.

- **Equal levels over regular levels.** If you only have time to watch one setup, watch the EQH and EQL levels. They have the highest probability of producing a clean sweep and reversal.

- **A swept level is dead.** Once a level is swept and turns faded, stop watching it. Price has already taken what it needed from that pool. Focus on the next active level.

- **Patience is the edge.** This indicator does not give you an entry signal directly. It gives you the map. Your edge is waiting at the right location for the sweep confirmation, not chasing price.

- **Works on all markets.** Forex, indices, crypto, commodities — wherever stops exist, liquidity exists. The 106-bar lookback works across all timeframes.

---

**Best Used With**
A Market Structure Break (MSB) indicator on the same chart. Liquidity pools tell you where price is going. Market structure tells you when the move has begun. Together they form a complete trading system.

---

**Subtitle (for TradingView subtitle field)**

> Map buy-side and sell-side liquidity pools, equal highs and lows, and sweep detection — built for ICT and SMC structure traders on any market and timeframe.

## Source Code

````pine
//@version=6
indicator("15M Liquidity Trade Permission", "15M LIQ TP", overlay=true, max_lines_count=50, max_labels_count=100, max_bars_back=5000)

//━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━
grpMain = "Main"
tradeMode = input.string("Neutral", "Trade Mode", options=["Neutral", "Looking for Long", "Looking for Short"], group=grpMain)
profile   = input.string("EUR/USD", "Pair Profile", options=["EUR/USD", "GBP/USD", "USD/CHF", "USD/JPY", "EUR/JPY", "Custom"], group=grpMain)
liqTF     = input.timeframe("15", "Liquidity Timeframe", group=grpMain)

grpPair = "Pair Settings"
customPip        = input.float(0.0001, "Custom Pip Size", step=0.00001, group=grpPair)
customDangerPips = input.float(15.0, "Custom Danger Pips", step=0.5, group=grpPair)

grpLiq = "Liquidity Detection"
pivotLen         = input.int(4, "15M Pivot Strength", minval=2, maxval=20, group=grpLiq)
eqTolerancePips  = input.float(2.0, "EQH/EQL Tolerance", minval=0.1, step=0.1, group=grpLiq)
sweepBufferPips  = input.float(0.3, "Sweep Buffer", minval=0.1, step=0.1, group=grpLiq)
maxStoredLevels  = input.int(30, "Max Stored Levels", minval=10, maxval=100, group=grpLiq)

grpPriority = "Liquidity Priority"
majorScore       = input.int(70, "Major Liquidity Score = NO TRADE", minval=40, maxval=120, group=grpPriority)
mediumScore      = input.int(45, "Medium Liquidity Score = WAIT", minval=20, maxval=100, group=grpPriority)
baseSwingScore   = input.int(15, "Normal BSL/SSL Score", minval=0, maxval=50, group=grpPriority)
eqBonusScore     = input.int(30, "EQH/EQL Bonus Score", minval=0, maxval=60, group=grpPriority)
touchBonusScore  = input.int(12, "Repeated Level Bonus", minval=0, maxval=50, group=grpPriority)
dangerBonusScore = input.int(15, "Inside Danger Zone Bonus", minval=0, maxval=50, group=grpPriority)

grpVol = "Volume Strength"
useVolumeStrength = input.bool(true, "Use 15M Pivot Volume Strength", group=grpVol)
volLen            = input.int(20, "15M Volume SMA Length", minval=5, maxval=100, group=grpVol)
highVolMult       = input.float(1.5, "High Volume Multiplier", minval=1.0, step=0.1, group=grpVol)
lowVolMult        = input.float(0.75, "Low Volume Multiplier", minval=0.1, step=0.05, group=grpVol)
highVolScore      = input.int(25, "High Volume Score", minval=0, maxval=60, group=grpVol)
normalVolScore    = input.int(10, "Normal Volume Score", minval=0, maxval=40, group=grpVol)
lowVolScore       = input.int(0, "Low Volume Score", minval=0, maxval=30, group=grpVol)

grpStable = "Stability"
useConfirmedOnly = input.bool(true, "Stable Mode: Confirmed Candles Only", group=grpStable)
tradeOnWait      = input.bool(false, "Treat WAIT As Trade Allowed", group=grpStable)

grpVisual = "Visuals"
showLines          = input.bool(true, "Show Nearby Liquidity Lines", group=grpVisual)
showPanel          = input.bool(true, "Show Trade Permission Panel", group=grpVisual)
showOnlyThreatSide = input.bool(false, "Show Only Threat-Side Liquidity", group=grpVisual)
showSignalLabels   = input.bool(true, "Show TRADE / NO TRADE Labels", group=grpVisual)

//━━━━━━━━━━━━━━━━━━━
// PAIR SETTINGS
//━━━━━━━━━━━━━━━━━━━
float pip =
     profile == "USD/JPY" or profile == "EUR/JPY" ? 0.01 :
     profile == "Custom" ? customPip :
     0.0001

float dangerPips =
     profile == "EUR/USD" ? 15.0 :
     profile == "GBP/USD" ? 20.0 :
     profile == "USD/CHF" ? 15.0 :
     profile == "USD/JPY" ? 18.0 :
     profile == "EUR/JPY" ? 25.0 :
     customDangerPips

toPips(float x) =>
    math.abs(x) / pip

// Stable price source.
// On live candle, use previous confirmed close so the panel does not float.
float stableClose = useConfirmedOnly and not barstate.isconfirmed ? close[1] : close

//━━━━━━━━━━━━━━━━━━━
// 15M PIVOTS + 15M VOLUME
//━━━━━━━━━━━━━━━━━━━
ph = request.security(syminfo.tickerid, liqTF, ta.pivothigh(high, pivotLen, pivotLen), barmerge.gaps_off, barmerge.lookahead_off)
pl = request.security(syminfo.tickerid, liqTF, ta.pivotlow(low, pivotLen, pivotLen), barmerge.gaps_off, barmerge.lookahead_off)

phVol = request.security(syminfo.tickerid, liqTF, not na(ta.pivothigh(high, pivotLen, pivotLen)) ? volume[pivotLen] : na, barmerge.gaps_off, barmerge.lookahead_off)
plVol = request.security(syminfo.tickerid, liqTF, not na(ta.pivotlow(low, pivotLen, pivotLen)) ? volume[pivotLen] : na, barmerge.gaps_off, barmerge.lookahead_off)

volAvg15 = request.security(syminfo.tickerid, liqTF, ta.sma(volume, volLen), barmerge.gaps_off, barmerge.lookahead_off)

newPH = not na(ph) and na(ph[1])
newPL = not na(pl) and na(pl[1])

//━━━━━━━━━━━━━━━━━━━
// ARRAYS
//━━━━━━━━━━━━━━━━━━━
var float[] levels = array.new_float()
var int[] sides = array.new_int()
var string[] names = array.new_string()
var int[] baseScores = array.new_int()
var float[] volRatios = array.new_float()
var int[] touches = array.new_int()

//━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━
getVolRatio(float v) =>
    float result = 1.0
    if not na(v) and not na(volAvg15) and volAvg15 != 0.0
        result := v / volAvg15
    result

getVolScore(float ratio) =>
    int result = 0
    if useVolumeStrength
        if ratio >= highVolMult
            result := highVolScore
        else if ratio <= lowVolMult
            result := lowVolScore
        else
            result := normalVolScore
    result

getVolText(float ratio) =>
    string result = "Vol Off"
    if useVolumeStrength
        if ratio >= highVolMult
            result := "High Vol"
        else if ratio <= lowVolMult
            result := "Low Vol"
        else
            result := "Normal Vol"
    result

findDuplicate(float price, int side) =>
    int found = -1
    if array.size(levels) > 0
        for i = 0 to array.size(levels) - 1
            if array.get(sides, i) == side and toPips(array.get(levels, i) - price) <= eqTolerancePips
                found := i
    found

trimArrays() =>
    if array.size(levels) > maxStoredLevels
        array.shift(levels)
        array.shift(sides)
        array.shift(names)
        array.shift(baseScores)
        array.shift(volRatios)
        array.shift(touches)
    0

addOrUpdateLevel(float price, int side, string name, float volRatio) =>
    int existing = findDuplicate(price, side)

    int newBaseScore = baseSwingScore
    if name == "EQH" or name == "EQL"
        newBaseScore += eqBonusScore

    if existing == -1
        array.push(levels, price)
        array.push(sides, side)
        array.push(names, name)
        array.push(baseScores, newBaseScore)
        array.push(volRatios, volRatio)
        array.push(touches, 1)
        trimArrays()
    else
        float oldPrice = array.get(levels, existing)
        string oldName = array.get(names, existing)
        int oldScore = array.get(baseScores, existing)
        int oldTouches = array.get(touches, existing)
        float oldVolRatio = array.get(volRatios, existing)

        float updatedPrice = side == 1 ? math.max(oldPrice, price) : math.min(oldPrice, price)

        string updatedName = oldName
        if name == "EQH" or oldName == "EQH"
            updatedName := "EQH"
        if name == "EQL" or oldName == "EQL"
            updatedName := "EQL"

        int updatedScore = math.max(oldScore, newBaseScore)
        if oldTouches >= 1
            updatedScore += touchBonusScore

        float updatedVolRatio = math.max(oldVolRatio, volRatio)

        array.set(levels, existing, updatedPrice)
        array.set(names, existing, updatedName)
        array.set(baseScores, existing, updatedScore)
        array.set(volRatios, existing, updatedVolRatio)
        array.set(touches, existing, oldTouches + 1)

    0

deleteLevel(int i) =>
    array.remove(levels, i)
    array.remove(sides, i)
    array.remove(names, i)
    array.remove(baseScores, i)
    array.remove(volRatios, i)
    array.remove(touches, i)
    0

getLevelScore(int i, float distPips) =>
    int score = array.get(baseScores, i)
    float ratio = array.get(volRatios, i)

    score += getVolScore(ratio)

    if not na(distPips) and distPips <= dangerPips
        score += dangerBonusScore

    score

getStrength(int score) =>
    string result = "Minor"
    if score >= majorScore
        result := "Major"
    else if score >= mediumScore
        result := "Medium"
    result

getPermission(int score, bool insideDanger) =>
    string result = "TRADE"
    if insideDanger
        if score >= majorScore
            result := "NO TRADE"
        else if score >= mediumScore
            result := tradeOnWait ? "TRADE" : "WAIT"
        else
            result := "TRADE"
    result

getPanelColor(string permission) =>
    color result = color.gray
    if permission == "TRADE"
        result := color.green
    else if permission == "WAIT"
        result := color.orange
    else if permission == "NO TRADE"
        result := color.red
    else if permission == "SELECT MODE"
        result := color.gray
    result

//━━━━━━━━━━━━━━━━━━━
// ADD LIQUIDITY LEVELS
//━━━━━━━━━━━━━━━━━━━
var float lastPH = na
var float lastPL = na

if newPH
    float ratioPH = getVolRatio(phVol)
    addOrUpdateLevel(ph, 1, "BSL", ratioPH)

    if not na(lastPH) and toPips(ph - lastPH) <= eqTolerancePips
        addOrUpdateLevel(math.max(ph, lastPH), 1, "EQH", ratioPH)

    lastPH := ph

if newPL
    float ratioPL = getVolRatio(plVol)
    addOrUpdateLevel(pl, -1, "SSL", ratioPL)

    if not na(lastPL) and toPips(pl - lastPL) <= eqTolerancePips
        addOrUpdateLevel(math.min(pl, lastPL), -1, "EQL", ratioPL)

    lastPL := pl

//━━━━━━━━━━━━━━━━━━━
// DELETE SWEPT LEVELS — CONFIRMED ONLY
//━━━━━━━━━━━━━━━━━━━
if not useConfirmedOnly or barstate.isconfirmed
    int idx = 0
    while idx < array.size(levels)
        float p = array.get(levels, idx)
        int s = array.get(sides, idx)

        bool swept = s == 1 ? high >= p + sweepBufferPips * pip : low <= p - sweepBufferPips * pip

        if swept
            deleteLevel(idx)
        else
            idx += 1

//━━━━━━━━━━━━━━━━━━━
// FIND NEAREST ABOVE / BELOW USING STABLE CLOSE
//━━━━━━━━━━━━━━━━━━━
float nearestAbove = na
float nearestBelow = na

string aboveName = "None"
string belowName = "None"

int aboveIndex = -1
int belowIndex = -1

if array.size(levels) > 0
    for i = 0 to array.size(levels) - 1
        float p = array.get(levels, i)
        int s = array.get(sides, i)
        string n = array.get(names, i)

        if s == 1 and p > stableClose
            if na(nearestAbove) or p < nearestAbove
                nearestAbove := p
                aboveName := n
                aboveIndex := i

        if s == -1 and p < stableClose
            if na(nearestBelow) or p > nearestBelow
                nearestBelow := p
                belowName := n
                belowIndex := i

aboveDist = na(nearestAbove) ? na : toPips(nearestAbove - stableClose)
belowDist = na(nearestBelow) ? na : toPips(stableClose - nearestBelow)

aboveScore = aboveIndex == -1 ? na : getLevelScore(aboveIndex, aboveDist)
belowScore = belowIndex == -1 ? na : getLevelScore(belowIndex, belowDist)

aboveStrength = na(aboveScore) ? "None" : getStrength(aboveScore)
belowStrength = na(belowScore) ? "None" : getStrength(belowScore)

aboveVolText = aboveIndex == -1 ? "None" : getVolText(array.get(volRatios, aboveIndex))
belowVolText = belowIndex == -1 ? "None" : getVolText(array.get(volRatios, belowIndex))

aboveInsideDanger = not na(aboveDist) and aboveDist <= dangerPips
belowInsideDanger = not na(belowDist) and belowDist <= dangerPips

abovePermission = na(aboveScore) ? "TRADE" : getPermission(aboveScore, aboveInsideDanger)
belowPermission = na(belowScore) ? "TRADE" : getPermission(belowScore, belowInsideDanger)

//━━━━━━━━━━━━━━━━━━━
// RAW PERMISSION
//━━━━━━━━━━━━━━━━━━━
bool isLongMode  = tradeMode == "Looking for Long"
bool isShortMode = tradeMode == "Looking for Short"

string rawPermission = "SELECT MODE"

if isLongMode
    rawPermission := belowPermission
else if isShortMode
    rawPermission := abovePermission
else
    rawPermission := "SELECT MODE"

string rawReason = "Select Long or Short mode"

if isLongMode
    rawReason := na(belowDist) ? "TRADE: no SSL/EQL below nearby" :
         belowPermission == "NO TRADE" ? "NO TRADE: major SSL/EQL below may be swept first" :
         belowPermission == "WAIT" ? "WAIT: medium SSL/EQL below; not clean enough" :
         "TRADE: below liquidity is minor or not dangerous"

if isShortMode
    rawReason := na(aboveDist) ? "TRADE: no BSL/EQH above nearby" :
         abovePermission == "NO TRADE" ? "NO TRADE: major BSL/EQH above may be swept first" :
         abovePermission == "WAIT" ? "WAIT: medium BSL/EQH above; not clean enough" :
         "TRADE: above liquidity is minor or not dangerous"

//━━━━━━━━━━━━━━━━━━━
// STABLE LOCKED PANEL STATE
//━━━━━━━━━━━━━━━━━━━
var string stablePermission = "SELECT MODE"
var string stableReason = "Select Long or Short mode"

var string stableAboveText = "None"
var string stableBelowText = "None"
var string stableMagnet = "None"

if not useConfirmedOnly or barstate.isconfirmed
    stablePermission := rawPermission
    stableReason := rawReason

    stableAboveText := na(aboveDist) ? "None" : aboveName + " " + str.tostring(aboveDist, "#.1") + "p | " + aboveStrength + " | " + str.tostring(aboveScore) + " | " + aboveVolText
    stableBelowText := na(belowDist) ? "None" : belowName + " " + str.tostring(belowDist, "#.1") + "p | " + belowStrength + " | " + str.tostring(belowScore) + " | " + belowVolText

    if not na(aboveScore) and not na(belowScore)
        stableMagnet := aboveScore > belowScore ? "Above" : belowScore > aboveScore ? "Below" : "Balanced"
    else if not na(aboveScore)
        stableMagnet := "Above"
    else if not na(belowScore)
        stableMagnet := "Below"
    else
        stableMagnet := "None"

//━━━━━━━━━━━━━━━━━━━
// DRAW LINES
//━━━━━━━━━━━━━━━━━━━
var line aboveLine = na
var line belowLine = na
var label aboveLabel = na
var label belowLabel = na

bool showAbove = showLines and not na(nearestAbove) and (not showOnlyThreatSide or isShortMode or tradeMode == "Neutral")
bool showBelow = showLines and not na(nearestBelow) and (not showOnlyThreatSide or isLongMode or tradeMode == "Neutral")

if showAbove
    color cA = getPanelColor(abovePermission)
    string txtA = aboveName + " | " + str.tostring(aboveDist, "#.1") + "p | " + aboveStrength + " | " + str.tostring(aboveScore) + " | " + aboveVolText

    if na(aboveLine)
        aboveLine := line.new(bar_index, nearestAbove, bar_index + 1, nearestAbove, extend=extend.right, color=cA, width=2)
    else
        line.set_y1(aboveLine, nearestAbove)
        line.set_y2(aboveLine, nearestAbove)
        line.set_color(aboveLine, cA)

    if na(aboveLabel)
        aboveLabel := label.new(bar_index, nearestAbove, txtA, style=label.style_label_down, color=cA, textcolor=color.white, size=size.small)
    else
        label.set_x(aboveLabel, bar_index)
        label.set_y(aboveLabel, nearestAbove)
        label.set_text(aboveLabel, txtA)
        label.set_color(aboveLabel, cA)
else
    if not na(aboveLine)
        line.delete(aboveLine)
        aboveLine := na
    if not na(aboveLabel)
        label.delete(aboveLabel)
        aboveLabel := na

if showBelow
    color cB = getPanelColor(belowPermission)
    string txtB = belowName + " | " + str.tostring(belowDist, "#.1") + "p | " + belowStrength + " | " + str.tostring(belowScore) + " | " + belowVolText

    if na(belowLine)
        belowLine := line.new(bar_index, nearestBelow, bar_index + 1, nearestBelow, extend=extend.right, color=cB, width=2)
    else
        line.set_y1(belowLine, nearestBelow)
        line.set_y2(belowLine, nearestBelow)
        line.set_color(belowLine, cB)

    if na(belowLabel)
        belowLabel := label.new(bar_index, nearestBelow, txtB, style=label.style_label_up, color=cB, textcolor=color.white, size=size.small)
    else
        label.set_x(belowLabel, bar_index)
        label.set_y(belowLabel, nearestBelow)
        label.set_text(belowLabel, txtB)
        label.set_color(belowLabel, cB)
else
    if not na(belowLine)
        line.delete(belowLine)
        belowLine := na
    if not na(belowLabel)
        label.delete(belowLabel)
        belowLabel := na

//━━━━━━━━━━━━━━━━━━━
// PANEL — STABLE SIGNAL ONLY
//━━━━━━━━━━━━━━━━━━━
var table panel = table.new(position.top_right, 2, 7, border_width=1)

if showPanel and barstate.islast
    color permissionColor = getPanelColor(stablePermission)

    table.cell(panel, 0, 0, "LIQ SIGNAL", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 0, stablePermission, text_color=color.white, bgcolor=permissionColor)

    table.cell(panel, 0, 1, "Mode", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 1, tradeMode, text_color=color.white, bgcolor=color.black)

    table.cell(panel, 0, 2, "Above", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 2, stableAboveText, text_color=color.white, bgcolor=color.black)

    table.cell(panel, 0, 3, "Below", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 3, stableBelowText, text_color=color.white, bgcolor=color.black)

    table.cell(panel, 0, 4, "Danger", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 4, str.tostring(dangerPips, "#.1") + "p", text_color=color.white, bgcolor=color.black)

    table.cell(panel, 0, 5, "Magnet", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 5, stableMagnet, text_color=color.white, bgcolor=color.black)

    table.cell(panel, 0, 6, "Reason", text_color=color.white, bgcolor=color.black)
    table.cell(panel, 1, 6, stableReason, text_color=color.white, bgcolor=color.black)

//━━━━━━━━━━━━━━━━━━━
// SIGNAL LABELS — CONFIRMED ONLY
//━━━━━━━━━━━━━━━━━━━
var string prevStablePermission = "SELECT MODE"

bool permissionChanged = barstate.isconfirmed and stablePermission != prevStablePermission

if showSignalLabels and permissionChanged
    if stablePermission == "TRADE"
        label.new(bar_index, low, "LIQ TRADE\nALLOWED", style=label.style_label_up, color=color.green, textcolor=color.white, size=size.small)
    else if stablePermission == "WAIT"
        label.new(bar_index, close, "LIQ WAIT", style=label.style_label_left, color=color.orange, textcolor=color.white, size=size.small)
    else if stablePermission == "NO TRADE"
        label.new(bar_index, high, "LIQ NO TRADE", style=label.style_label_down, color=color.red, textcolor=color.white, size=size.small)

if barstate.isconfirmed
    prevStablePermission := stablePermission

//━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━
alertcondition(barstate.isconfirmed and stablePermission == "TRADE" and prevStablePermission != "TRADE", "LIQ TRADE ALLOWED", "Liquidity permission changed to TRADE.")
alertcondition(barstate.isconfirmed and stablePermission == "WAIT" and prevStablePermission != "WAIT", "LIQ WAIT", "Liquidity permission changed to WAIT.")
alertcondition(barstate.isconfirmed and stablePermission == "NO TRADE" and prevStablePermission != "NO TRADE", "LIQ NO TRADE", "Liquidity permission changed to NO TRADE.")
````
