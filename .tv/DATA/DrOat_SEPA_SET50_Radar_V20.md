<!-- tradingview-pine-id: PUB;30af7e5b747441eaa4534246f933d320 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Dr.Oat SEPA SET50 Radar V2.0

Source: https://www.tradingview.com/script/jmwoXJnK/

## Description

# Dr.Oat SEPA SET50 Radar V2.0

**Dr.Oat SEPA SET50 Radar** is a quantitative screening tool designed to scan SET50 stocks using a rules-based framework inspired by SEPA and Stage 2 trend principles.

The indicator focuses on identifying stocks that are:

* In a strong Stage 2 uptrend
* Forming a constructive volatility contraction structure
* Approaching a potential Pivot Point
* Breaking out with expanding volume
* Becoming extended beyond an ideal entry zone

All calculations are performed on the **Daily timeframe**, regardless of the chart timeframe currently being viewed.

Because of Pine Script request limitations, the SET50 universe is divided into two groups:

**SET50 A:** Stocks 1–25
**SET50 B:** Stocks 26–50

For complete SET50 coverage, add the indicator to the chart twice and select one group for each instance.

---

# Dashboard Columns

## SEPA

SEPA is the overall setup score from 0 to 100.

The score currently combines:

* Trend Template Quality
* VCP Structure
* Volume Quality
* Pivot Position
* Breakout Quality

Daily RSI is **not included** in the SEPA Score.

A higher score indicates that more elements of the setup are aligned.

General interpretation:

**90–100:** Very Strong Setup
**80–89:** Strong Setup
**70–79:** Developing / Watch
**Below 70:** Lower Priority

A high SEPA Score does not automatically mean the stock should be bought.

Always review the price chart and risk/reward before entering a trade.

---

# TT — Trend Template

TT represents the number of Stage 2 Trend Template conditions currently satisfied.

The current model uses **7 conditions**.

### 1. Price Above SMA150 and SMA200

The current closing price must be above both the 150-day and 200-day simple moving averages.

### 2. SMA150 Above SMA200

The intermediate-term moving average must be above the long-term moving average.

### 3. SMA200 Rising

The current SMA200 must be above its value approximately 22 trading days ago.

This helps confirm that the long-term trend is rising.

### 4. SMA50 Above SMA150 and SMA200

The short-term moving average must be above both the intermediate and long-term averages.

### 5. Price at Least 25% Above the 52-Week Low

The current price must have advanced sufficiently from its 52-week low.

### 6. Price Within 25% of the 52-Week High

The current price should remain relatively close to its 52-week high.

### 7. Price Above SMA50

The current closing price must be above the 50-day moving average.

When the Dashboard shows:

**TT = 7/7**

the stock currently satisfies all Trend Template conditions used by this model.

---

# VCP Score

The VCP Score is a quantitative approximation of a **Volatility Contraction Pattern**.

The script does not attempt to visually recognize a classical VCP exactly as a discretionary trader would.

Instead, it evaluates several measurable characteristics:

* Base Depth
* Short-Term Range Contraction
* ATR Contraction
* Volume Dry-Up
* Right-Side Tightness

The maximum score is 100.

General interpretation:

**VCP >= 70:** Constructive contraction characteristics are developing

**VCP >= 80:** Stronger volatility contraction structure

The VCP Score should be treated as a screening tool rather than a definitive pattern-recognition signal.

Always inspect the actual chart before trading.

---

# RSI(D)

RSI(D) displays the Daily Relative Strength Index.

Default setting:

**RSI Length = 14**

RSI is displayed for momentum information only.

RSI is:

* NOT used in the Trend Template
* NOT used in the VCP Score
* NOT used in the SEPA Score

General interpretation:

**RSI below 50:** Weak or neutral momentum

**RSI 50–60:** Improving momentum

**RSI 60–70:** Strong momentum

**RSI 70–80:** Very strong momentum

**RSI above 80:** Extremely strong momentum; check whether price is becoming extended

A high RSI is not automatically considered a sell signal.

Strong market leaders can remain at elevated RSI levels for extended periods.

---

# PIVOT%

PIVOT% shows the percentage distance between the current price and the calculated Pivot Point.

Example:

**-1.20%**

The current price is approximately 1.2% below the Pivot.

Example:

**+0.50%**

The stock is approximately 0.5% above the Pivot.

Values close to zero are particularly useful when monitoring potential breakout setups.

Default settings:

**READY Zone:** Within 5% below the Pivot

**Maximum Chase:** 3% above the Pivot

If price advances too far above the Pivot, the system classifies the stock as **EXTENDED**.

---

# RVOL

RVOL represents Relative Volume.

It compares current daily volume with the 50-day average volume.

Examples:

**RVOL = 0.50x**

Current volume is approximately 50% of the 50-day average.

This can be useful when looking for Volume Dry-Up before a breakout.

**RVOL = 1.00x**

Current volume is approximately equal to average volume.

**RVOL = 1.50x**

Current volume is approximately 50% above the 50-day average.

The default model requires approximately:

**RVOL >= 1.50x**

as part of breakout confirmation.

---

# STATUS

The Radar classifies each stock into one of five statuses.

## BREAKOUT

The stock:

* Passes the Trend Template
* Meets the minimum VCP requirement
* Trades above the Pivot
* Remains within the maximum chase zone
* Has sufficient Relative Volume

These stocks deserve immediate chart review.

BREAKOUT is not an automatic buy order.

Risk/reward and technical stop placement should still be evaluated.

---

## READY

The stock:

* Passes the Trend Template
* Meets the minimum VCP requirement
* Is trading close to, but still below, the Pivot

READY stocks are particularly useful for building a focused watchlist before a potential breakout.

Example:

**PIVOT% = -0.80%**

The stock is approximately 0.8% below its Pivot.

---

## DEVELOP

The stock is in a valid Stage 2 trend but is not yet classified as READY or BREAKOUT.

The setup may still be developing.

These stocks can remain on the watchlist for further observation.

---

## EXTENDED

The stock remains in a strong trend but has advanced beyond the configured Maximum Chase distance above its Pivot.

This status is designed as a warning:

**Do Not Chase**

EXTENDED does not necessarily mean the stock is weak.

It means the current entry location may offer an unfavorable risk/reward profile.

---

## SKIP

The stock does not currently meet the required trend/setup conditions.

It can generally be removed from the immediate trading focus.

---

# Installation

Open TradingView and go to:

**Pine Editor**

Create a new indicator and paste the complete:

**Dr.Oat SEPA SET50 Radar V2.0**

script.

Then select:

**Save → Add to chart**

---

# Recommended Setup — Radar A

Open Indicator Settings and select:

**SET50 Group:**
SET50 A (1-25)

**Display Mode:**
Qualified Only

**Maximum Rows:**
15

**Dashboard Position:**
Top Right

---

# Recommended Setup — Radar B

Add the same indicator to the chart a second time.

Then select:

**SET50 Group:**
SET50 B (26-50)

**Display Mode:**
Qualified Only

**Maximum Rows:**
15

**Dashboard Position:**
Bottom Right

This allows the two instances to cover the complete SET50 universe.

---

# Display Modes

## Qualified Only

Displays stocks where:

**TT = 7/7**

and

**VCP Score >= Minimum VCP Score**

This is the recommended default mode.

---

## READY + BREAKOUT

Displays only stocks currently classified as:

**READY**

or

**BREAKOUT**

This is particularly useful for daily trade preparation.

---

## All 25

Displays all stocks in the selected group.

This mode is useful for:

* Verifying data
* Comparing scores
* Reviewing developing stocks
* Troubleshooting the scanner

---

# Recommended Daily Workflow

Start by opening both SET50 Radar A and Radar B.

Then review stocks in the following order.

### 1. BREAKOUT

Check whether any stock is breaking above its Pivot with expanding volume.

### 2. READY

Identify stocks positioned just below their Pivot.

### 3. SEPA Score

Within the same status category, prioritize higher SEPA Scores.

### 4. Trend Template

Prefer stocks showing:

**TT = 7/7**

### 5. VCP Score

Review whether the stock is showing constructive contraction behavior.

### 6. PIVOT%

Determine how close the stock is to the breakout level.

### 7. RVOL

Before breakout, lower volume may indicate constructive Volume Dry-Up.

During breakout, rising RVOL can help confirm demand.

### 8. Review the Actual Chart

Always inspect:

* Base structure
* Pivot quality
* Price action
* Volume behavior
* Overhead supply
* Distance from moving averages

### 9. Define Entry, Stop and Position Size

The Radar is a screening tool.

Trade execution and risk management should be decided separately.

---

# Example Interpretation

Example:

**ADVANC**

SEPA = 91
TT = 7/7
VCP = 84
RSI(D) = 65
PIVOT% = -0.80%
RVOL = 0.55x
STATUS = READY

Interpretation:

ADVANC currently satisfies all Trend Template conditions.

Its quantitative VCP characteristics are constructive.

The price is approximately 0.8% below the Pivot.

Relative Volume is low, suggesting reduced trading activity ahead of the potential breakout.

The next step is to monitor whether price breaks the Pivot with expanding volume.

---

Another example:

**DELTA**

SEPA = 94
TT = 7/7
VCP = 88
RSI(D) = 72
PIVOT% = +0.50%
RVOL = 1.85x
STATUS = BREAKOUT

Interpretation:

The stock satisfies the Trend Template and VCP requirements.

Price has moved approximately 0.5% above the Pivot.

Relative Volume is approximately 85% above the 50-day average.

The system therefore classifies the stock as a potential BREAKOUT.

The trader should still evaluate the actual chart, technical stop level and risk/reward before taking a position.

---

# Limitations

Dr.Oat SEPA SET50 Radar is a **screening and decision-support tool**.

It does not evaluate:

* Earnings growth
* Revenue growth
* ROE
* Fundamental quality
* Valuation
* Company-specific news
* Market regime
* Foreign investor flow
* Earnings catalysts
* Portfolio-level risk

A READY or BREAKOUT signal should therefore not be interpreted as an automatic recommendation to buy.

The purpose of the Radar is to reduce the SET50 universe from 50 stocks to a much smaller list of technically interesting candidates that deserve further analysis.

---

# Core Workflow

**Scan → Rank → Focus → Review Chart → Manage Risk**

The goal is not to predict which stock will rise.

The goal is to systematically identify stocks showing the strongest combination of trend, contraction, proximity to a Pivot and volume behavior, then focus attention only on the highest-quality candidates.

---

## Source Code

````pine
//@version=6
indicator("Dr.Oat SEPA SET50 Radar V2.0", shorttitle="OAT SET50 RADAR", overlay=true, dynamic_requests=true)

// ============================================================================
// DR.OAT SEPA SET50 RADAR V2.0
// ============================================================================
//
// HOW TO USE
//
// Add this indicator TWICE:
//
// Instance 1
// SET50 Group        = SET50 A (1-25)
// Dashboard Position = Top Right
//
// Instance 2
// SET50 Group        = SET50 B (26-50)
// Dashboard Position = Bottom Right
//
// All stock calculations use DAILY timeframe.
//
// RSI(D):
// - Information only
// - NOT used in Trend Template
// - NOT used in VCP Score
// - NOT used in SEPA Score
//
// STATUS
// 0 = SKIP
// 1 = DEVELOP
// 2 = READY
// 3 = BREAKOUT
// 4 = EXTENDED
//
// ============================================================================


// ============================================================================
// 1. RADAR SETTINGS
// ============================================================================

groupRadar = "1. SET50 Radar"

radarGroup = input.string(
     "SET50 A (1-25)",
     "SET50 Group",
     options=["SET50 A (1-25)", "SET50 B (26-50)"],
     group=groupRadar
)

displayMode = input.string(
     "Qualified Only",
     "Display Mode",
     options=["Qualified Only", "READY + BREAKOUT", "All 25"],
     group=groupRadar
)

maxDisplayRows = input.int(
     15,
     "Maximum Rows",
     minval=5,
     maxval=25,
     group=groupRadar
)

panelPosition = input.string(
     "Top Right",
     "Dashboard Position",
     options=["Top Right", "Bottom Right", "Top Left", "Bottom Left"],
     group=groupRadar
)


// ============================================================================
// 2. TREND TEMPLATE SETTINGS
// ============================================================================

groupTrend = "2. Trend Template"

sma50Len = input.int(
     50,
     "SMA 50",
     minval=1,
     group=groupTrend
)

sma150Len = input.int(
     150,
     "SMA 150",
     minval=1,
     group=groupTrend
)

sma200Len = input.int(
     200,
     "SMA 200",
     minval=1,
     group=groupTrend
)

sma200SlopeBars = input.int(
     22,
     "SMA200 Rising Lookback",
     minval=1,
     group=groupTrend
)

low52Multiplier = input.float(
     1.25,
     "Minimum vs 52W Low",
     step=0.05,
     group=groupTrend
)

high52Multiplier = input.float(
     0.75,
     "Minimum vs 52W High",
     step=0.05,
     group=groupTrend
)


// ============================================================================
// 3. VCP SETTINGS
// ============================================================================

groupVCP = "3. VCP"

baseLookback = input.int(
     65,
     "Base Lookback",
     minval=20,
     maxval=130,
     group=groupVCP
)

minBaseDepth = input.float(
     10.0,
     "Minimum Base Depth %",
     step=1.0,
     group=groupVCP
)

maxBaseDepth = input.float(
     35.0,
     "Maximum Base Depth %",
     step=1.0,
     group=groupVCP
)

vcpMinScore = input.float(
     70.0,
     "Minimum VCP Score",
     step=5.0,
     group=groupVCP
)

volumeDryThreshold = input.float(
     0.65,
     "Current RVOL Dry-Up",
     step=0.05,
     group=groupVCP
)

avgVolumeDryThreshold = input.float(
     0.80,
     "Vol10 / Vol50 Dry-Up",
     step=0.05,
     group=groupVCP
)


// ============================================================================
// 4. PIVOT / BREAKOUT SETTINGS
// ============================================================================

groupPivot = "4. Pivot / Breakout"

pivotLookback = input.int(
     20,
     "Pivot Lookback",
     minval=5,
     group=groupPivot
)

readyDistance = input.float(
     5.0,
     "READY Zone Below Pivot %",
     step=0.5,
     group=groupPivot
)

breakoutRVOL = input.float(
     1.50,
     "Breakout Minimum RVOL",
     step=0.10,
     group=groupPivot
)

maxChasePct = input.float(
     3.0,
     "Maximum Chase Above Pivot %",
     step=0.5,
     group=groupPivot
)

rsiLength = input.int(
     14,
     "Daily RSI Length",
     minval=2,
     group=groupPivot
)


// ============================================================================
// 5. COLORS
// ============================================================================

cBG = color.rgb(16, 19, 26)
cBG2 = color.rgb(24, 29, 39)
cHeader = color.rgb(34, 40, 54)

cWhite = color.rgb(238, 241, 247)
cGray = color.rgb(145, 154, 168)

cGreen = color.rgb(42, 207, 132)
cGreen2 = color.rgb(74, 235, 155)

cYellow = color.rgb(255, 197, 61)
cOrange = color.rgb(255, 143, 61)
cRed = color.rgb(255, 82, 90)

cBlue = color.rgb(78, 163, 255)
cPurple = color.rgb(178, 124, 255)


// ============================================================================
// 6. HELPER FUNCTIONS
// ============================================================================

f_clamp(float value, float minimum, float maximum) =>
    math.max(minimum, math.min(maximum, value))


f_statusText(int sig) =>
    string result = "SKIP"
    if sig == 3
        result := "BREAKOUT"
    else if sig == 2
        result := "READY"
    else if sig == 1
        result := "DEVELOP"
    else if sig == 4
        result := "EXTENDED"
    result


f_statusColor(int sig) =>
    color result = cRed
    if sig == 3
        result := cGreen2
    else if sig == 2
        result := cYellow
    else if sig == 1
        result := cBlue
    else if sig == 4
        result := cOrange
    result


f_scoreColor(float value) =>
    color result = cRed
    if value >= 90
        result := cGreen2
    else if value >= 80
        result := cGreen
    else if value >= 70
        result := cYellow
    else if value >= 50
        result := cOrange
    result


f_priority(int sig) =>
    int result = 0
    if sig == 3
        result := 4
    else if sig == 2
        result := 3
    else if sig == 1
        result := 2
    else if sig == 4
        result := 1
    result


f_shortSymbol(string symbol) =>
    str.replace_all(symbol, "SET:", "")


f_panelPosition(string p) =>
    string result = position.top_right
    if p == "Bottom Right"
        result := position.bottom_right
    else if p == "Top Left"
        result := position.top_left
    else if p == "Bottom Left"
        result := position.bottom_left
    result


// ============================================================================
// 7. DAILY SEPA ENGINE
// ============================================================================

f_sepaEngine() =>

    // ------------------------------------------------------------------------
    // MOVING AVERAGES
    // ------------------------------------------------------------------------

    float sma50 = ta.sma(close, sma50Len)
    float sma150 = ta.sma(close, sma150Len)
    float sma200 = ta.sma(close, sma200Len)

    // ------------------------------------------------------------------------
    // 52-WEEK RANGE
    // ------------------------------------------------------------------------

    float high52 = ta.highest(high, 252)
    float low52 = ta.lowest(low, 252)

    // ------------------------------------------------------------------------
    // TREND TEMPLATE
    // 7 CONDITIONS
    // ------------------------------------------------------------------------

    bool t1 = close > sma150 and close > sma200
    bool t2 = sma150 > sma200
    bool t3 = sma200 > sma200[sma200SlopeBars]
    bool t4 = sma50 > sma150 and sma50 > sma200
    bool t5 = close >= low52 * low52Multiplier
    bool t6 = close >= high52 * high52Multiplier
    bool t7 = close > sma50

    int tt = 0

    if t1
        tt += 1

    if t2
        tt += 1

    if t3
        tt += 1

    if t4
        tt += 1

    if t5
        tt += 1

    if t6
        tt += 1

    if t7
        tt += 1

    bool trendPass = tt == 7
    float trendScore = float(tt) / 7.0 * 100.0

    // ------------------------------------------------------------------------
    // RSI DAY
    // INFORMATION ONLY
    // ------------------------------------------------------------------------

    float dailyRSI = ta.rsi(close, rsiLength)

    // ------------------------------------------------------------------------
    // VOLUME
    // ------------------------------------------------------------------------

    float vol10 = ta.sma(volume, 10)
    float vol50 = ta.sma(volume, 50)

    float rvol = na
    float vol10Ratio = na

    if vol50 > 0
        rvol := volume / vol50
        vol10Ratio := vol10 / vol50

    bool volumeDryUp = false

    if not na(rvol) and not na(vol10Ratio)
        volumeDryUp := rvol < volumeDryThreshold and vol10Ratio < avgVolumeDryThreshold

    // ------------------------------------------------------------------------
    // BASE DEPTH
    // ------------------------------------------------------------------------

    float baseHigh = ta.highest(high, baseLookback)
    float baseLow = ta.lowest(low, baseLookback)

    float baseDepth = na

    if baseHigh > 0
        baseDepth := (baseHigh - baseLow) / baseHigh * 100.0

    bool baseDepthOK = false

    if not na(baseDepth)
        baseDepthOK := baseDepth >= minBaseDepth and baseDepth <= maxBaseDepth

    // ------------------------------------------------------------------------
    // RANGE CONTRACTION
    // ------------------------------------------------------------------------

    float high10 = ta.highest(high, 10)
    float low10 = ta.lowest(low, 10)

    float high20 = ta.highest(high, 20)
    float low20 = ta.lowest(low, 20)

    float high40 = ta.highest(high, 40)
    float low40 = ta.lowest(low, 40)

    float range10 = na
    float range20 = na
    float range40 = na

    if close > 0
        range10 := (high10 - low10) / close * 100.0
        range20 := (high20 - low20) / close * 100.0
        range40 := (high40 - low40) / close * 100.0

    bool contract1 = false
    bool contract2 = false

    if not na(range10) and not na(range20)
        contract1 := range10 < range20 * 0.75

    if not na(range20) and not na(range40)
        contract2 := range20 < range40 * 0.85

    // ------------------------------------------------------------------------
    // ATR CONTRACTION
    // ------------------------------------------------------------------------

    float atr5 = ta.atr(5)
    float atr20 = ta.atr(20)
    float atr50 = ta.atr(50)

    bool atrContract1 = atr5 < atr20 * 0.85
    bool atrContract2 = atr20 < atr50

    bool rightSideTight = false

    if not na(range10) and not na(range20)
        rightSideTight := range10 < range20 * 0.75

    // ------------------------------------------------------------------------
    // VCP SCORE
    //
    // Base Depth         20
    // Range Contract     25
    // ATR Contract       20
    // Volume Dry-Up      20
    // Right Side Tight   15
    //                    ---
    //                    100
    // ------------------------------------------------------------------------

    float vcp = 0.0

    if baseDepthOK
        vcp += 20.0

    if contract1
        vcp += 12.5

    if contract2
        vcp += 12.5

    if atrContract1
        vcp += 10.0

    if atrContract2
        vcp += 10.0

    if volumeDryUp
        vcp += 20.0

    if rightSideTight
        vcp += 15.0

    // ------------------------------------------------------------------------
    // PIVOT
    // ------------------------------------------------------------------------

    float pivot = ta.highest(high[1], pivotLookback)

    float pivotDistance = na

    if pivot > 0
        pivotDistance := (close / pivot - 1.0) * 100.0

    bool nearPivot = false
    bool validBreakoutZone = false
    bool breakoutVolume = false

    if not na(pivotDistance)
        nearPivot := pivotDistance <= 0 and pivotDistance >= -readyDistance
        validBreakoutZone := pivotDistance > 0 and pivotDistance <= maxChasePct

    if not na(rvol)
        breakoutVolume := rvol >= breakoutRVOL

    // ------------------------------------------------------------------------
    // STATUS
    // ------------------------------------------------------------------------

    bool breakout = trendPass and vcp >= vcpMinScore and validBreakoutZone and breakoutVolume
    bool ready = trendPass and vcp >= vcpMinScore and nearPivot

    bool extended = false

    if trendPass and not na(pivotDistance)
        extended := pivotDistance > maxChasePct

    bool developing = trendPass and not breakout and not ready and not extended

    int signal = 0

    if breakout
        signal := 3
    else if ready
        signal := 2
    else if extended
        signal := 4
    else if developing
        signal := 1

    // ------------------------------------------------------------------------
    // SEPA SCORE
    //
    // Trend     30
    // VCP       30
    // Volume    15
    // Pivot     15
    // Breakout  10
    //
    // RSI NOT INCLUDED
    // ------------------------------------------------------------------------

    float trendComponent = trendScore / 100.0 * 30.0
    float vcpComponent = vcp / 100.0 * 30.0

    float volumeComponent = 0.0

    if breakout
        volumeComponent := 15.0
    else if volumeDryUp
        volumeComponent := 15.0
    else if not na(rvol) and rvol < 1.0
        volumeComponent := 7.5

    float pivotComponent = 0.0

    if nearPivot
        pivotComponent := 15.0
    else if validBreakoutZone
        pivotComponent := 15.0
    else if not na(pivotDistance)
        if pivotDistance >= -10.0 and pivotDistance < -readyDistance
            pivotComponent := 7.5

    float breakoutComponent = 0.0

    if breakout
        breakoutComponent := 10.0
    else if validBreakoutZone and not na(rvol)
        if rvol >= 1.20
            breakoutComponent := 5.0

    float sepa = trendComponent + vcpComponent + volumeComponent + pivotComponent + breakoutComponent

    sepa := f_clamp(sepa, 0.0, 100.0)

    // IMPORTANT: KEEP TUPLE ON ONE LINE
    [sepa, float(tt), vcp, dailyRSI, pivotDistance, rvol, float(signal), baseDepth]


// ============================================================================
// 8. SET50 CONSTITUENTS — JUL-DEC 2026
// ============================================================================

// Group A
var string[] SET50_A = array.from("SET:ADVANC", "SET:AOT", "SET:AWC", "SET:BANPU", "SET:BBL", "SET:BCP", "SET:BDMS", "SET:BEM", "SET:BH", "SET:BJC", "SET:CCET", "SET:COM7", "SET:CPALL", "SET:CPF", "SET:CPN", "SET:CRC", "SET:DELTA", "SET:EGCO", "SET:GPSC", "SET:GULF", "SET:HMPRO", "SET:IVL", "SET:KBANK", "SET:KKP", "SET:KTB")

// Group B
var string[] SET50_B = array.from("SET:KTC", "SET:LH", "SET:MINT", "SET:MRDIYT", "SET:MTC", "SET:OR", "SET:OSP", "SET:PTT", "SET:PTTEP", "SET:PTTGC", "SET:RATCH", "SET:SCB", "SET:SCC", "SET:SCGP", "SET:TCAP", "SET:TFG", "SET:THAI", "SET:TIDLOR", "SET:TISCO", "SET:TLI", "SET:TOP", "SET:TRUE", "SET:TTB", "SET:TU", "SET:WHA")


// ============================================================================
// 9. RESULT ARRAYS
// ============================================================================

var string[] arrSymbol = array.new_string()

var float[] arrSepa = array.new_float()
var float[] arrTT = array.new_float()
var float[] arrVCP = array.new_float()
var float[] arrRSI = array.new_float()
var float[] arrPivotDist = array.new_float()
var float[] arrRVOL = array.new_float()
var float[] arrSignal = array.new_float()
var float[] arrBaseDepth = array.new_float()


// ============================================================================
// 10. DASHBOARD
// ============================================================================

string dashboardPosition = f_panelPosition(panelPosition)

var table radar = table.new(
     dashboardPosition,
     8,
     28,
     bgcolor=cBG,
     frame_color=color.new(cWhite, 70),
     frame_width=1,
     border_color=color.new(cWhite, 90),
     border_width=1
)


// ============================================================================
// 11. CLEAR RESULT ARRAYS
// ============================================================================

if barstate.islast
    array.clear(arrSymbol)
    array.clear(arrSepa)
    array.clear(arrTT)
    array.clear(arrVCP)
    array.clear(arrRSI)
    array.clear(arrPivotDist)
    array.clear(arrRVOL)
    array.clear(arrSignal)
    array.clear(arrBaseDepth)


// ============================================================================
// 12. REQUEST 25 SET50 STOCKS
// ============================================================================

for i = 0 to 24

    string sym = ""

    if radarGroup == "SET50 A (1-25)"
        sym := array.get(SET50_A, i)
    else
        sym := array.get(SET50_B, i)

    // IMPORTANT:
    // Tuple assignment is intentionally ONE LINE.
    [sepaValue, ttValue, vcpValue, rsiValue, pivotDistValue, rvolValue, signalValue, baseDepthValue] = request.security(sym, "D", f_sepaEngine(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

    if barstate.islast

        float safeSepa = 0.0
        float safeTT = 0.0
        float safeVCP = 0.0
        float safeRSI = 0.0
        float safePivotDist = -999.0
        float safeRVOL = 0.0
        float safeSignal = 0.0
        float safeBaseDepth = 0.0

        if not na(sepaValue)
            safeSepa := sepaValue

        if not na(ttValue)
            safeTT := ttValue

        if not na(vcpValue)
            safeVCP := vcpValue

        if not na(rsiValue)
            safeRSI := rsiValue

        if not na(pivotDistValue)
            safePivotDist := pivotDistValue

        if not na(rvolValue)
            safeRVOL := rvolValue

        if not na(signalValue)
            safeSignal := signalValue

        if not na(baseDepthValue)
            safeBaseDepth := baseDepthValue

        array.push(arrSymbol, sym)
        array.push(arrSepa, safeSepa)
        array.push(arrTT, safeTT)
        array.push(arrVCP, safeVCP)
        array.push(arrRSI, safeRSI)
        array.push(arrPivotDist, safePivotDist)
        array.push(arrRVOL, safeRVOL)
        array.push(arrSignal, safeSignal)
        array.push(arrBaseDepth, safeBaseDepth)


// ============================================================================
// 13. BUILD DASHBOARD
// ============================================================================

if barstate.islast

    int n = array.size(arrSymbol)

    // ------------------------------------------------------------------------
    // COUNTERS
    // ------------------------------------------------------------------------

    int countTT = 0
    int countQualified = 0
    int countBreakout = 0
    int countReady = 0
    int countDevelop = 0
    int countExtended = 0

    if n > 0

        for i = 0 to n - 1

            float ttCounter = array.get(arrTT, i)
            float vcpCounter = array.get(arrVCP, i)
            int sigCounter = int(array.get(arrSignal, i))

            if ttCounter == 7
                countTT += 1

            if ttCounter == 7 and vcpCounter >= vcpMinScore
                countQualified += 1

            if sigCounter == 3
                countBreakout += 1
            else if sigCounter == 2
                countReady += 1
            else if sigCounter == 1
                countDevelop += 1
            else if sigCounter == 4
                countExtended += 1

    // ------------------------------------------------------------------------
    // CLEAR TABLE
    // ------------------------------------------------------------------------

    table.clear(radar, 0, 0, 7, 27)

    // ------------------------------------------------------------------------
    // GROUP NAME
    // ------------------------------------------------------------------------

    string groupName = "SET50 RADAR A"

    if radarGroup == "SET50 B (26-50)"
        groupName := "SET50 RADAR B"

    // ------------------------------------------------------------------------
    // HEADER
    // ------------------------------------------------------------------------

    table.cell(radar, 0, 0, "DR.OAT", bgcolor=cHeader, text_color=cWhite, text_size=size.normal)
    table.cell(radar, 1, 0, groupName, bgcolor=cHeader, text_color=cGreen2, text_size=size.normal)
    table.cell(radar, 2, 0, "", bgcolor=cHeader)
    table.cell(radar, 3, 0, "", bgcolor=cHeader)
    table.cell(radar, 4, 0, "", bgcolor=cHeader)
    table.cell(radar, 5, 0, "", bgcolor=cHeader)
    table.cell(radar, 6, 0, "", bgcolor=cHeader)
    table.cell(radar, 7, 0, "DAILY", bgcolor=cHeader, text_color=cPurple)

    // ------------------------------------------------------------------------
    // SUMMARY
    // ------------------------------------------------------------------------

    table.cell(radar, 0, 1, "TT7 " + str.tostring(countTT), bgcolor=cBG2, text_color=cGreen)
    table.cell(radar, 1, 1, "QUAL " + str.tostring(countQualified), bgcolor=cBG2, text_color=cWhite)
    table.cell(radar, 2, 1, "BO " + str.tostring(countBreakout), bgcolor=cBG2, text_color=cGreen2)
    table.cell(radar, 3, 1, "READY " + str.tostring(countReady), bgcolor=cBG2, text_color=cYellow)
    table.cell(radar, 4, 1, "DEV " + str.tostring(countDevelop), bgcolor=cBG2, text_color=cBlue)
    table.cell(radar, 5, 1, "EXT " + str.tostring(countExtended), bgcolor=cBG2, text_color=cOrange)
    table.cell(radar, 6, 1, "", bgcolor=cBG2)
    table.cell(radar, 7, 1, "", bgcolor=cBG2)

    // ------------------------------------------------------------------------
    // COLUMN HEADERS
    // ------------------------------------------------------------------------

    table.cell(radar, 0, 2, "STOCK", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 1, 2, "SEPA", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 2, 2, "TT", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 3, 2, "VCP", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 4, 2, "RSI(D)", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 5, 2, "PIVOT%", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 6, 2, "RVOL", bgcolor=cHeader, text_color=cGray)
    table.cell(radar, 7, 2, "STATUS", bgcolor=cHeader, text_color=cGray)

    // ========================================================================
    // NO ARRAY SWAPPING
    //
    // We select the best unused stock one row at a time:
    //
    // BREAKOUT
    // READY
    // DEVELOP
    // EXTENDED
    // SKIP
    //
    // Within the same status:
    // Highest SEPA score first.
    // ========================================================================

    bool[] used = array.new_bool(n, false)

    int displayed = 0

    if n > 0

        for row = 0 to maxDisplayRows - 1

            int bestIndex = -1
            int bestPriority = -1
            float bestScore = -1.0

            // ----------------------------------------------------------------
            // FIND BEST UNUSED STOCK
            // ----------------------------------------------------------------

            for i = 0 to n - 1

                bool alreadyUsed = array.get(used, i)

                if not alreadyUsed

                    float currentTT = array.get(arrTT, i)
                    float currentVCP = array.get(arrVCP, i)
                    float currentSEPA = array.get(arrSepa, i)
                    int currentSignal = int(array.get(arrSignal, i))

                    bool qualified = currentTT == 7 and currentVCP >= vcpMinScore

                    bool shouldInclude = false

                    if displayMode == "All 25"
                        shouldInclude := true
                    else if displayMode == "READY + BREAKOUT"
                        shouldInclude := currentSignal == 2 or currentSignal == 3
                    else
                        shouldInclude := qualified

                    if shouldInclude

                        int currentPriority = f_priority(currentSignal)

                        bool better = false

                        if currentPriority > bestPriority
                            better := true
                        else if currentPriority == bestPriority and currentSEPA > bestScore
                            better := true

                        if better
                            bestIndex := i
                            bestPriority := currentPriority
                            bestScore := currentSEPA

            // ----------------------------------------------------------------
            // DRAW BEST STOCK
            // ----------------------------------------------------------------

            if bestIndex >= 0

                array.set(used, bestIndex, true)

                string symbolNow = array.get(arrSymbol, bestIndex)

                float sepaNow = array.get(arrSepa, bestIndex)
                float ttNow = array.get(arrTT, bestIndex)
                float vcpNow = array.get(arrVCP, bestIndex)
                float rsiNow = array.get(arrRSI, bestIndex)
                float pivotNow = array.get(arrPivotDist, bestIndex)
                float rvolNow = array.get(arrRVOL, bestIndex)

                int signalNow = int(array.get(arrSignal, bestIndex))

                // ------------------------------------------------------------
                // COLORS
                // ------------------------------------------------------------

                color rowBG = cBG

                if signalNow == 3
                    rowBG := color.new(cGreen, 86)
                else if signalNow == 2
                    rowBG := color.new(cYellow, 90)
                else if signalNow == 4
                    rowBG := color.new(cOrange, 92)

                color ttColor = cRed

                if ttNow == 7
                    ttColor := cGreen

                color rsiColor = cGray

                if rsiNow >= 80
                    rsiColor := cOrange
                else if rsiNow >= 60
                    rsiColor := cGreen
                else if rsiNow >= 50
                    rsiColor := cYellow

                color pivotColor = cGray

                if pivotNow > 0 and pivotNow <= maxChasePct
                    pivotColor := cGreen2
                else if pivotNow <= 0 and pivotNow >= -readyDistance
                    pivotColor := cYellow
                else if pivotNow > maxChasePct
                    pivotColor := cOrange

                color rvolColor = cWhite

                if rvolNow >= breakoutRVOL
                    rvolColor := cGreen2
                else if rvolNow < volumeDryThreshold
                    rvolColor := cBlue

                // ------------------------------------------------------------
                // PIVOT TEXT
                // ------------------------------------------------------------

                string pivotText = "N/A"

                if pivotNow > -900
                    pivotText := str.tostring(pivotNow, "#.00") + "%"

                // ------------------------------------------------------------
                // TABLE ROW
                // ------------------------------------------------------------

                int tableRow = displayed + 3

                table.cell(radar, 0, tableRow, f_shortSymbol(symbolNow), bgcolor=rowBG, text_color=cWhite)
                table.cell(radar, 1, tableRow, str.tostring(sepaNow, "#"), bgcolor=rowBG, text_color=f_scoreColor(sepaNow))
                table.cell(radar, 2, tableRow, str.tostring(ttNow, "#") + "/7", bgcolor=rowBG, text_color=ttColor)
                table.cell(radar, 3, tableRow, str.tostring(vcpNow, "#"), bgcolor=rowBG, text_color=f_scoreColor(vcpNow))
                table.cell(radar, 4, tableRow, str.tostring(rsiNow, "#.0"), bgcolor=rowBG, text_color=rsiColor)
                table.cell(radar, 5, tableRow, pivotText, bgcolor=rowBG, text_color=pivotColor)
                table.cell(radar, 6, tableRow, str.tostring(rvolNow, "#.00") + "x", bgcolor=rowBG, text_color=rvolColor)
                table.cell(radar, 7, tableRow, f_statusText(signalNow), bgcolor=rowBG, text_color=f_statusColor(signalNow))

                displayed += 1

    // ------------------------------------------------------------------------
    // NO MATCH
    // ------------------------------------------------------------------------

    if displayed == 0

        table.cell(
             radar,
             0,
             3,
             "NO MATCH",
             bgcolor=cBG,
             text_color=cGray
        )

        table.cell(
             radar,
             1,
             3,
             "No stocks meet current filter",
             bgcolor=cBG,
             text_color=cGray
        )
````
