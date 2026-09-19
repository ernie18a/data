<!-- tradingview-pine-id: PUB;76a4a4cb432749079917fb383231f1f4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PA Patterns Strategy v2

Source: https://www.tradingview.com/script/OqjKbuRp-Patterns-Strategy-v1/

## Description

### 1. What the strategy does

This is a **price-action pattern strategy** that detects four patterns:

* **Bullish Engulfing** → long setup
* **Bearish Engulfing** → short setup
* **Morning Star** → long setup
* **Evening Star** → short setup

The strategy then creates an entry trigger, stop loss, and profit targets for the detected pattern. 

---

### 2. Bullish Engulfing

For a bullish engulfing setup, the script looks for:

* Previous candle is bearish.
* Current candle is bullish.
* Current candle's body is large enough according to the minimum-body setting.
* The current candle completely engulfs the previous candle's body when strict engulfing is enabled.
* The current close can also be required to finish beyond the previous candle's open.

Once detected:

**Entry:** above the engulfing candle's high
**SL:** below the engulfing candle's low, with optional use of both candles
**Target:** normally 1.5R for TP1 and 2R for the final target.  

---

### 3. Bearish Engulfing

The opposite structure is used:

* Previous candle is bullish.
* Current candle is bearish.
* Current candle has sufficient body strength.
* Current candle engulfs the previous candle's body.
* The close can be required to finish below the previous candle's open.

**Entry:** below the engulfing candle's low
**SL:** above the engulfing candle's high
**Target:** 1.5R and 2R by default. 

---

### 4. Morning Star

The strategy uses a **three-candle pattern**:

1. Strong bearish first candle.
2. Small-body middle candle.
3. Strong bullish third candle.
4. Third candle must recover at least the configured penetration percentage of the first candle's body.

The default settings require:

* Middle candle body ≤ 35% of its range.
* Outer candles body ≥ 55%.
* Third candle penetration = 50%.

**Entry:** above the third candle's high
**SL:** below the entire three-candle pattern
**Target:** 1.5R / 2R.  

---

### 5. Evening Star

This is the reverse of the Morning Star:

1. Strong bullish first candle.
2. Small middle candle.
3. Strong bearish third candle.
4. Third candle penetrates sufficiently into the first candle.

**Entry:** below the third candle's low
**SL:** above the entire pattern
**Target:** 1.5R / 2R. 

---

## 6. Entry mechanism

There are **two entry modes**.

### Stop Order

The strategy places a resting order at the breakout level.

For example:

**Bullish pattern → price must break the trigger above the pattern.**

### Market on Break

The strategy waits until price actually breaks the trigger and then enters on the next bar.

So the two modes behave differently in backtesting. 

There is also an **entry buffer**, meaning the trigger can be placed a few ticks beyond the pattern high/low.

---

## 7. Pending setup expiration

After a pattern appears, the setup does **not remain active forever**.

Default:

**5 bars**

If price doesn't trigger the entry within those bars, the pending setup is cancelled.

There is also an option to cancel the setup if the stop-loss level breaks before the entry occurs. 

---

## 8. Stop-loss protection

The strategy has a minimum stop-distance rule.

If the calculated SL is too close to the entry, it automatically pushes the SL farther away to satisfy the minimum number of ticks.

This prevents extremely small stop distances. 

---

## 9. Profit management

The default structure is:

**Entry → 1.5R TP1 → 2R final TP**

At TP1:

* 50% of the position is closed by default.
* The remaining position continues toward TP2.
* Stop loss can automatically move toward break-even.

The break-even adjustment has its own tick offset.  

So conceptually:

**Risk = 1R**

If your entry-to-SL distance is 20 points:

* TP1 = +30 points
* TP2 = +40 points

with the default 1.5R / 2R settings.

---

## 10. Daily trading restrictions

The script has several controls:

* Maximum trades per day
* Maximum number of losses per day
* Only the first pattern of the day
* Long trades on/off
* Short trades on/off
* Trading session restriction
* Close trade at session end
* EMA trend filter

The default maximum trades per day is **1**. 

This is important because even if several patterns appear, the strategy can prevent additional trades once the daily limit has been reached.

---

## 11. EMA trend filter

The strategy can optionally use an EMA as a directional filter.

Default EMA:

**200 EMA**

When enabled:

* Long setups require price above the EMA.
* Short setups require price below the EMA.

When disabled, the EMA does not filter the trades.  

---

## 12. Position sizing

There are two approaches.

### Fixed lots

The strategy trades a fixed number of lots.

Default:

**1 lot × 65 units = 65 units**

### Risk-based sizing

You can instead specify how much of your equity you want to risk per trade.

The position size is then calculated from:

**Account equity + risk percentage + distance to SL + lot size**

It rounds the quantity to whole lots.  

---

## 13. White candle feature

This is one of the important visual features of your script.

When a valid pattern is detected, the pattern candle can be painted **white**.

For two-candle patterns:

**Both candles can be highlighted.**

For three-candle patterns:

**All three candles can be highlighted.**

You can independently control this feature from the Visuals settings. 

---

## 14. Chart markings

The script can display:

* Bullish triangle
* Bearish triangle
* Pattern name
* Entry/trigger level
* Entry price
* Stop loss
* TP1
* TP2
* EMA when trend filtering is enabled

The levels make it possible to visually follow the entire trade from setup → entry → SL/TP. 

---

## 15. Dashboard

The top-right dashboard shows the current strategy state.

It can tell you:

* **LONG**
* **SHORT**
* **Pending Long**
* **Pending Short**
* **Flat**

It also displays:

* Trades today
* Losses today
* Last pattern
* Current 1R risk
* Net profit

When DEBUG is enabled, it additionally shows:

* Signals detected
* Orders placed
* Fills
* Expired setups
* Invalidated setups
* Blocked setups
* Last reason a setup was skipped. 

---

## 16. Alerts

The script has alerts for each individual pattern:

* Bullish Engulfing
* Bearish Engulfing
* Morning Star
* Evening Star

It also has general long/short setup alerts.

The alert message can include the pattern, trigger price and SL. 

---

### Overall flow

The strategy essentially works like this:

**Find pattern → check filters → calculate trigger → calculate SL → create pending setup → wait for breakout → enter → manage TP1 → move SL toward BE → target TP2 or SL → enforce daily limits.**

So this is **not simply a candle-pattern indicator**. It is a complete **backtesting/trading strategy with order management, risk sizing, daily limits, visual signals, dashboard and alerts**.

---

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  PATTERNS STRATEGY v1  (Engulfing + Morning/Evening Star)
//
//  Pattern              Entry                      Stop Loss          Target
//  ------------------------------------------------------------------------
//  Bullish Engulfing    Break of engulfing HIGH     Engulfing LOW      1.5R-2R
//  Bearish Engulfing    Break of engulfing LOW      Engulfing HIGH     1.5R-2R
//  Morning Star         Break of 3rd candle HIGH    Pattern LOW        1.5R-2R
//  Evening Star         Break of 3rd candle LOW     Pattern HIGH       1.5R-2R
//
//  v2 changes: rebuilt order engine (orders re-issued every bar while
//  pending), Market-on-break entry mode, qty safety clamps, and a DEBUG
//  panel that counts signals / orders / fills / cancels.
//
//  v2.1 changes: fixed-lot position sizing (defaults to whole lots of 65,
//  matching NSE Nifty 50 lot size as of Jan 2026), max trades/day default
//  changed to 1.
// ═══════════════════════════════════════════════════════════════════════════

strategy(
     title                   = "PA Patterns Strategy v2",
     shorttitle              = "PA Patterns v2",
     overlay                 = true,
     initial_capital         = 100000,
     default_qty_type        = strategy.percent_of_equity,
     default_qty_value       = 10,
     pyramiding              = 0,
     calc_on_order_fills     = false,
     process_orders_on_close = false,
     commission_type         = strategy.commission.percent,
     commission_value        = 0.03,
     slippage                = 1,
     margin_long             = 0,
     margin_short            = 0,
     max_labels_count        = 500,
     max_lines_count         = 500)

// ───────────────────────────────────────────────────────────────────────────
//  ① PATTERN DETECTION
// ───────────────────────────────────────────────────────────────────────────
gP = "① Patterns"
useEngulf      = input.bool (true,  "Enable Engulfing patterns",              group = gP)
useStar        = input.bool (true,  "Enable Morning / Evening Star",          group = gP)
minEngBodyPct  = input.float(50.0,  "Engulfing: min body % of candle range",  minval = 10, maxval = 100, step = 5, group = gP)
strictEngulf   = input.bool (true,  "Engulfing: body must FULLY engulf prior body", group = gP)
engNeedClose   = input.bool (true,  "Engulfing: close beyond prior open",     group = gP)
smallBodyPct   = input.float(35.0,  "Star: middle candle max body %",         minval = 5,  maxval = 60, group = gP)
strongBodyPct  = input.float(55.0,  "Star: outer candles min body %",         minval = 20, maxval = 90, group = gP)
penetrationPct = input.float(50.0,  "Star: required penetration %",           minval = 20, maxval = 100, group = gP)

// ───────────────────────────────────────────────────────────────────────────
//  ② ENTRY / SL / TARGET
// ───────────────────────────────────────────────────────────────────────────
gE = "② Entry / SL / Target"
entryMode      = input.string("Stop order", "Entry mode", options = ["Stop order", "Market on break"], group = gE,
     tooltip = "Stop order  = resting buy/sell stop at the trigger price (exact fills)\nMarket on break = waits for a bar to break the level, enters at next bar open (always executes)")
entryBufTicks  = input.int  (2,    "Entry buffer (ticks beyond trigger)",     minval = 0, group = gE)
slBufTicks     = input.int  (2,    "SL buffer (ticks beyond pattern)",        minval = 0, group = gE)
slWholePattern = input.bool (true, "Engulfing SL uses BOTH candles",          group = gE)
validBars      = input.int  (5,    "Pending entry valid for N bars",          minval = 1, maxval = 50, group = gE)
cancelOnBreak  = input.bool (false,"Cancel pending if SL level breaks first", group = gE)
minStopTicks   = input.int  (5,    "Minimum stop distance (ticks)",           minval = 1, group = gE)

useTP1         = input.bool (true, "Use partial TP1",                         group = gE)
tp1R           = input.float(1.5,  "TP1 (R multiple)",                        minval = 0.5, step = 0.1, group = gE)
tp1Qty         = input.int  (50,   "TP1 size (% of position)",                minval = 1, maxval = 99, group = gE)
tp2R           = input.float(2.0,  "TP2 / final target (R multiple)",         minval = 0.5, step = 0.1, group = gE)
moveBE         = input.bool (true, "Move SL to break-even after TP1",         group = gE)
beOffsetTicks  = input.int  (2,    "Break-even offset (ticks)",               minval = 0, group = gE)

// ───────────────────────────────────────────────────────────────────────────
//  ③ LIMITS & FILTERS
// ───────────────────────────────────────────────────────────────────────────
gL = "③ Limits & Filters"
maxTradesDay   = input.int  (1,    "MAX TRADES PER DAY",                      minval = 1, maxval = 50, group = gL)
maxLossesDay   = input.int  (0,    "Stop trading after N losses (0 = off)",   minval = 0, maxval = 20, group = gL)
onePerDay      = input.bool (false,"Only FIRST pattern of the day",           group = gL)
allowLong      = input.bool (true, "Allow LONG trades",                       group = gL)
allowShort     = input.bool (true, "Allow SHORT trades",                      group = gL)
useSession     = input.bool (false,"Restrict to session",                     group = gL)
sess           = input.session("0915-1500", "Trading session",                group = gL)
closeEOD       = input.bool (false,"Close open trade at session end",         group = gL)
useTrendFilter = input.bool (false,"Only trade with EMA trend",               group = gL)
emaLen         = input.int  (200,  "Trend EMA length",                        minval = 5, group = gL)

// ───────────────────────────────────────────────────────────────────────────
//  ④ POSITION SIZING
// ───────────────────────────────────────────────────────────────────────────
gS = "④ Position Sizing"
useRiskSizing  = input.bool (false, "Size position by risk %",                group = gS)
riskPct        = input.float(1.0,  "Risk per trade (% of equity)",            minval = 0.1, maxval = 100, step = 0.1, group = gS)
lotSize        = input.int  (65,   "Lot size (units per lot)",                minval = 1, group = gS,
     tooltip = "NSE Nifty 50 lot size = 65 units (effective Jan 2026). Change if trading a different instrument.")
fixedLots      = input.int  (1,    "Fixed number of lots (used when risk sizing is OFF)", minval = 1, group = gS)
maxQty         = input.float(0,    "Max units per trade (0 = unlimited)",     minval = 0, group = gS)

// ───────────────────────────────────────────────────────────────────────────
//  ⑤ VISUALS / DEBUG
// ───────────────────────────────────────────────────────────────────────────
gV = "⑤ Visuals"
whiteCandles   = input.bool (true,      "Paint pattern candle body WHITE",    group = gV)
colorWhole     = input.bool (true,      "Paint ALL candles of the pattern",   group = gV)
whiteCol       = input.color(color.white,          "Body color",             group = gV)
borderCol      = input.color(color.new(#787b86,0), "Border / wick color",    group = gV)
showMarkers    = input.bool (true,      "Show pattern markers",               group = gV)
showLabels     = input.bool (true,      "Show pattern name labels",           group = gV)
showLevels     = input.bool (true,      "Plot Entry / SL / TP levels",        group = gV)
showTable      = input.bool (true,      "Show dashboard",                     group = gV)
debugMode      = input.bool (true,      "DEBUG: show engine counters",        group = gV)

// ═══════════════════════════════════════════════════════════════════════════
//  CANDLE MEASUREMENTS
// ═══════════════════════════════════════════════════════════════════════════
tick  = syminfo.mintick

body0 = math.abs(close    - open)
body1 = math.abs(close[1] - open[1])
body2 = math.abs(close[2] - open[2])
rng0  = high    - low
rng1  = high[1] - low[1]
rng2  = high[2] - low[2]

bodyPct0 = rng0 > 0 ? body0 / rng0 * 100 : 0.0
bodyPct1 = rng1 > 0 ? body1 / rng1 * 100 : 0.0
bodyPct2 = rng2 > 0 ? body2 / rng2 * 100 : 0.0

bull0 = close    > open
bear0 = close    < open
bull1 = close[1] > open[1]
bear1 = close[1] < open[1]
bull2 = close[2] > open[2]
bear2 = close[2] < open[2]

// ═══════════════════════════════════════════════════════════════════════════
//  PATTERNS
// ═══════════════════════════════════════════════════════════════════════════
engBodyOK = bodyPct0 >= minEngBodyPct

bullEngRaw = useEngulf and bear1 and bull0 and engBodyOK and
     (strictEngulf ? (open < close[1] and close > open[1]) : (open <= close[1] and close >= open[1])) and
     (not engNeedClose or close > open[1])

bearEngRaw = useEngulf and bull1 and bear0 and engBodyOK and
     (strictEngulf ? (open > close[1] and close < open[1]) : (open >= close[1] and close <= open[1])) and
     (not engNeedClose or close < open[1])

smallMiddle = bodyPct1 <= smallBodyPct
strongFirst = bodyPct2 >= strongBodyPct
strongThird = bodyPct0 >= strongBodyPct
midBull = open[2] - body2 * (penetrationPct / 100)
midBear = open[2] + body2 * (penetrationPct / 100)

morningRaw = useStar and bear2 and smallMiddle and strongFirst and bull0 and strongThird and close > midBull
eveningRaw = useStar and bull2 and smallMiddle and strongFirst and bear0 and strongThird and close < midBear

ema     = ta.ema(close, emaLen)
trendUp = not useTrendFilter or close > ema
trendDn = not useTrendFilter or close < ema

wasInSess  = not na(time(timeframe.period, sess))
inSess     = not useSession or wasInSess
sessClosed = useSession and not wasInSess and wasInSess[1]

// ═══════════════════════════════════════════════════════════════════════════
//  DAILY COUNTERS
// ═══════════════════════════════════════════════════════════════════════════
newDay = ta.change(time("D")) != 0

var int  tradesToday   = 0
var int  lossesToday   = 0
var bool firedToday    = false
var int  lastClosedCnt = 0

totalEntries = strategy.opentrades + strategy.closedtrades
newEntries   = totalEntries - nz(totalEntries[1], totalEntries)

if strategy.closedtrades > lastClosedCnt
    for i = lastClosedCnt to strategy.closedtrades - 1
        if strategy.closedtrades.profit(i) < 0
            lossesToday += 1
    lastClosedCnt := strategy.closedtrades

if newEntries > 0
    tradesToday += newEntries

if newDay
    tradesToday := 0
    lossesToday := 0
    firedToday  := false

lossLimitHit = maxLossesDay > 0 and lossesToday >= maxLossesDay
dayLimitHit  = tradesToday >= maxTradesDay or lossLimitHit or (onePerDay and firedToday)

// ═══════════════════════════════════════════════════════════════════════════
//  SIGNALS + LEVELS
// ═══════════════════════════════════════════════════════════════════════════
bullSig = (bullEngRaw or morningRaw) and trendUp and allowLong
bearSig = (bearEngRaw or eveningRaw) and trendDn and allowShort

patName = morningRaw ? "Morning Star"      :
          bullEngRaw ? "Bullish Engulfing" :
          eveningRaw ? "Evening Star"      :
          bearEngRaw ? "Bearish Engulfing" : ""

float sigTrig = na
float sigStop = na

if bullSig
    sigTrig := high + entryBufTicks * tick
    sigStop := (morningRaw ? math.min(low, math.min(low[1], low[2]))
                           : (slWholePattern ? math.min(low, low[1]) : low)) - slBufTicks * tick
    // enforce minimum stop distance
    if sigTrig - sigStop < minStopTicks * tick
        sigStop := sigTrig - minStopTicks * tick

if bearSig
    sigTrig := low - entryBufTicks * tick
    sigStop := (eveningRaw ? math.max(high, math.max(high[1], high[2]))
                           : (slWholePattern ? math.max(high, high[1]) : high)) + slBufTicks * tick
    if sigStop - sigTrig < minStopTicks * tick
        sigStop := sigTrig + minStopTicks * tick

// ═══════════════════════════════════════════════════════════════════════════
//  ORDER ENGINE
// ═══════════════════════════════════════════════════════════════════════════
var int    pendDir  = 0          // 1 = long pending, -1 = short pending, 0 = none
var float  pTrig    = na
var float  pStop    = na
var int    pAge     = 0
var string pName    = ""

// debug counters
var int cSig    = 0
var int cPlaced = 0
var int cFilled = 0
var int cExp    = 0
var int cInv    = 0
var int cBlk    = 0
var string lastSkip = "-"

flat   = strategy.position_size == 0
inLong = strategy.position_size > 0
inShrt = strategy.position_size < 0

// ── 1) fill detection (must run BEFORE anything re-issues an order) ────────
var float actSL   = na
var float actR    = na
var bool  tp1Done = false

if newEntries > 0
    cFilled += 1
    actSL   := pStop
    actR    := math.abs(strategy.position_avg_price - pStop)
    tp1Done := false
    pendDir := 0
    pAge    := 0

// ── 2) ageing / cancellation of a pending order ───────────────────────────
if pendDir != 0
    pAge += 1
    bool expired = pAge > validBars
    bool invalid = cancelOnBreak and (pendDir == 1 ? low <= pStop : high >= pStop)
    bool blockedNow = dayLimitHit or not inSess or newDay or not flat
    if expired or invalid or blockedNow
        strategy.cancel("Long")
        strategy.cancel("Short")
        if expired
            cExp += 1
            lastSkip := "expired"
        else if invalid
            cInv += 1
            lastSkip := "SL broke first"
        else
            cBlk += 1
            lastSkip := "blocked"
        pendDir := 0
        pAge    := 0

// ── 3) position sizing ────────────────────────────────────────────────────
// Always returns a whole multiple of lotSize (matches NSE Nifty 50 lot = 65
// units as of Jan 2026 - see the lotSize input if trading another symbol).
calcQty(float stopDist) =>
    float q = na
    if useRiskSizing and stopDist > 0
        rawLots = (strategy.equity * riskPct / 100) / stopDist / lotSize
        lots    = math.max(1, math.floor(rawLots))     // at least 1 whole lot
        q := lots * lotSize
        if maxQty > 0 and q > maxQty
            q := math.max(lotSize, math.floor(maxQty / lotSize) * lotSize)
    else
        q := fixedLots * lotSize                        // fixed size every trade
    q

// ── 4) arm a new pending setup ────────────────────────────────────────────
canArm = flat and pendDir == 0 and not dayLimitHit and inSess

if (bullSig or bearSig)
    cSig += 1
    if not canArm
        lastSkip := not flat ? "in position" : dayLimitHit ? "day limit" : not inSess ? "out of session" : "pending exists"

if canArm and bullSig and not na(sigTrig)
    pendDir := 1
    pTrig   := sigTrig
    pStop   := sigStop
    pName   := patName
    pAge    := 0
    firedToday := onePerDay ? true : firedToday

if canArm and bearSig and not na(sigTrig) and pendDir == 0
    pendDir := -1
    pTrig   := sigTrig
    pStop   := sigStop
    pName   := patName
    pAge    := 0
    firedToday := onePerDay ? true : firedToday

// ── 5) keep the order alive (re-issued every bar while pending) ───────────
if pendDir != 0 and flat
    float q = calcQty(math.abs(pTrig - pStop))
    if entryMode == "Stop order"
        if pendDir == 1
            strategy.entry("Long",  strategy.long,  qty = q, stop = pTrig, comment = pName)
        else
            strategy.entry("Short", strategy.short, qty = q, stop = pTrig, comment = pName)
        if pAge == 0
            cPlaced += 1
    else
        bool hit = pendDir == 1 ? high >= pTrig : low <= pTrig
        if hit
            if pendDir == 1
                strategy.entry("Long",  strategy.long,  qty = q, comment = pName)
            else
                strategy.entry("Short", strategy.short, qty = q, comment = pName)
            cPlaced += 1

// ═══════════════════════════════════════════════════════════════════════════
//  TRADE MANAGEMENT
// ═══════════════════════════════════════════════════════════════════════════
entryPx = strategy.position_avg_price
rOK     = not na(actR) and actR > 0
tp1Px   = rOK and inLong ? entryPx + actR * tp1R : rOK and inShrt ? entryPx - actR * tp1R : na
tp2Px   = rOK and inLong ? entryPx + actR * tp2R : rOK and inShrt ? entryPx - actR * tp2R : na

if useTP1 and rOK and not tp1Done and not flat
    if (inLong and high >= tp1Px) or (inShrt and low <= tp1Px)
        tp1Done := true
        if moveBE
            actSL := inLong ? entryPx + beOffsetTicks * tick : entryPx - beOffsetTicks * tick

if not flat and rOK
    string fromId = inLong ? "Long" : "Short"
    if useTP1
        strategy.exit("TP1", from_entry = fromId, qty_percent = tp1Qty, limit = tp1Px, stop = actSL, comment_profit = "TP1", comment_loss = "SL")
        strategy.exit("TP2", from_entry = fromId, limit = tp2Px, stop = actSL, comment_profit = "TP2", comment_loss = "SL")
    else
        strategy.exit("TP",  from_entry = fromId, limit = tp2Px, stop = actSL, comment_profit = "TP", comment_loss = "SL")

if closeEOD and sessClosed
    strategy.close_all(comment = "EOD")
    strategy.cancel("Long")
    strategy.cancel("Short")

// ═══════════════════════════════════════════════════════════════════════════
//  WHITE PATTERN CANDLES
// ═══════════════════════════════════════════════════════════════════════════
sigBar   = (bullSig or bearSig) and whiteCandles
twoBar   = sigBar and colorWhole
threeBar = sigBar and colorWhole and (morningRaw or eveningRaw)

plotcandle(open, high, low, close, title = "Pattern Candle",
     color = sigBar ? whiteCol : na, wickcolor = sigBar ? borderCol : na,
     bordercolor = sigBar ? borderCol : na)

barcolor(twoBar   ? whiteCol : na, offset = -1, title = "Pattern Candle -1")
barcolor(threeBar ? whiteCol : na, offset = -2, title = "Pattern Candle -2")

// ═══════════════════════════════════════════════════════════════════════════
//  MARKERS / LABELS / LEVELS
// ═══════════════════════════════════════════════════════════════════════════
plotshape(showMarkers and bullSig, title = "Bull Signal", style = shape.triangleup,
     location = location.belowbar, color = color.new(color.lime, 0), size = size.tiny)
plotshape(showMarkers and bearSig, title = "Bear Signal", style = shape.triangledown,
     location = location.abovebar, color = color.new(color.red, 0), size = size.tiny)

if showLabels and (bullSig or bearSig)
    label.new(bar_index, bullSig ? low : high, patName,
         yloc  = bullSig ? yloc.belowbar : yloc.abovebar,
         style = bullSig ? label.style_label_up : label.style_label_down,
         color = color.new(color.black, 20), textcolor = color.white, size = size.small)

plotTrig = showLevels and pendDir != 0 ? pTrig : na
plotEntr = showLevels and not flat ? entryPx : na
plotStop = showLevels ? (not flat ? actSL : pendDir != 0 ? pStop : na) : na
plotTP1  = showLevels and not flat and useTP1 ? tp1Px : na
plotTP2  = showLevels and not flat ? tp2Px : na

plot(plotTrig, "Trigger", color = color.new(color.orange, 0), style = plot.style_linebr)
plot(plotEntr, "Entry",   color = color.new(color.blue,   0), style = plot.style_linebr)
plot(plotStop, "Stop",    color = color.new(color.red,    0), style = plot.style_linebr)
plot(plotTP1,  "TP1",     color = color.new(color.teal,   0), style = plot.style_linebr)
plot(plotTP2,  "TP2",     color = color.new(color.green,  0), style = plot.style_linebr)
plot(useTrendFilter ? ema : na, "Trend EMA", color = color.new(color.gray, 40))

// ═══════════════════════════════════════════════════════════════════════════
//  DASHBOARD + DEBUG
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 12, border_width = 1)

if showTable and barstate.islast
    stateTxt = inLong ? "LONG" : inShrt ? "SHORT" : pendDir == 1 ? "Pending Long" : pendDir == -1 ? "Pending Short" : "Flat"
    stateCol = inLong ? color.new(color.green, 70) : inShrt ? color.new(color.red, 70) :
               pendDir != 0 ? color.new(color.orange, 70) : color.new(color.gray, 70)

    table.cell(dash, 0, 0, "PA PATTERNS v2", bgcolor = color.new(color.black, 20), text_color = color.white, text_size = size.small)
    table.cell(dash, 1, 0, stateTxt, bgcolor = stateCol, text_color = color.white, text_size = size.small)

    table.cell(dash, 0, 1, "Trades today", text_size = size.small)
    table.cell(dash, 1, 1, str.tostring(tradesToday) + " / " + str.tostring(maxTradesDay), text_size = size.small)

    table.cell(dash, 0, 2, "Losses today", text_size = size.small)
    table.cell(dash, 1, 2, str.tostring(lossesToday) + (maxLossesDay > 0 ? " / " + str.tostring(maxLossesDay) : ""), text_size = size.small)

    table.cell(dash, 0, 3, "Last pattern", text_size = size.small)
    table.cell(dash, 1, 3, pName == "" ? "-" : pName, text_size = size.small)

    table.cell(dash, 0, 4, "Risk (1R)", text_size = size.small)
    table.cell(dash, 1, 4, rOK ? str.tostring(actR, format.mintick) : "-", text_size = size.small)

    table.cell(dash, 0, 5, "Net profit", text_size = size.small)
    table.cell(dash, 1, 5, str.tostring(strategy.netprofit, "#.##"), text_size = size.small,
         text_color = strategy.netprofit >= 0 ? color.green : color.red)

    if debugMode
        table.cell(dash, 0, 6, "— DEBUG —", bgcolor = color.new(color.black, 40), text_color = color.white, text_size = size.small)
        table.cell(dash, 1, 6, "", bgcolor = color.new(color.black, 40), text_size = size.small)

        table.cell(dash, 0, 7,  "Signals seen", text_size = size.small)
        table.cell(dash, 1, 7,  str.tostring(cSig), text_size = size.small)

        table.cell(dash, 0, 8,  "Orders placed", text_size = size.small)
        table.cell(dash, 1, 8,  str.tostring(cPlaced), text_size = size.small)

        table.cell(dash, 0, 9,  "Fills", text_size = size.small)
        table.cell(dash, 1, 9,  str.tostring(cFilled), text_size = size.small)

        table.cell(dash, 0, 10, "Exp / Inv / Blk", text_size = size.small)
        table.cell(dash, 1, 10, str.tostring(cExp) + " / " + str.tostring(cInv) + " / " + str.tostring(cBlk), text_size = size.small)

        table.cell(dash, 0, 11, "Last skip reason", text_size = size.small)
        table.cell(dash, 1, 11, lastSkip, text_size = size.small)

// ═══════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(bullEngRaw, "Bullish Engulfing", "Bullish Engulfing detected")
alertcondition(bearEngRaw, "Bearish Engulfing", "Bearish Engulfing detected")
alertcondition(morningRaw, "Morning Star",      "Morning Star detected")
alertcondition(eveningRaw, "Evening Star",      "Evening Star detected")
alertcondition(bullSig,    "Any Long Setup",    "Long setup armed")
alertcondition(bearSig,    "Any Short Setup",   "Short setup armed")

if bullSig
    alert("LONG setup: " + patName + " | Entry > " + str.tostring(sigTrig, format.mintick) +
          " | SL " + str.tostring(sigStop, format.mintick), alert.freq_once_per_bar_close)
if bearSig
    alert("SHORT setup: " + patName + " | Entry < " + str.tostring(sigTrig, format.mintick) +
          " | SL " + str.tostring(sigStop, format.mintick), alert.freq_once_per_bar_close)
````
