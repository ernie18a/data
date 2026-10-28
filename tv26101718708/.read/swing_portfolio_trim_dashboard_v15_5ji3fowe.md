# Swing Portfolio Trim Dashboard v1.5

- url: https://www.tradingview.com/script/5JI3foWE-Swing-Portfolio-Trim-Dashboard-v1-5/
- type: indicator
- pine_id: PUB;d322b2ad15e44ac4b93d79461bc0d9c8
- version: 1.0

## Description

**Swing Portfolio Trim Dashboard**

A technical portfolio-ranking tool designed for swing traders who typically hold positions for roughly **1–3 months** and need a systematic way to decide which holdings to trim, exit, hold, or continue riding.

The indicator is designed for portfolios containing many positions and focuses entirely on **price action, momentum, trend strength, volatility-adjusted performance, and technical deterioration** rather than fundamentals.

### Technical Score

Every holding receives a **0–100 Technical Score** based on:

* **10-day raw momentum — 5%**
* **20-day raw momentum — 10%**
* **50-day raw momentum — 15%**
* **10-day volatility-adjusted momentum — 2.5%**
* **20-day volatility-adjusted momentum — 7.5%**
* **50-day volatility-adjusted momentum — 15%**
* **10/20/50 EMA trend structure — 20%**
* **ATR-normalized trend health — 25%**

Raw momentum captures absolute leadership, while volatility-adjusted momentum helps normalize comparisons between securities with very different volatility profiles.

This is particularly useful when comparing ordinary stocks, ETFs, and higher-volatility instruments within the same portfolio.

### Portfolio Relative Ranking

Momentum components are converted into **cross-sectional percentile ranks relative to the other securities in the portfolio**.

A stock ranking highly therefore means it is technically stronger than most of the alternatives currently held.

**Tech#** represents this overall ranking:

* **#1 = strongest holding**
* Higher numbers = progressively weaker holdings

### Multi-Horizon Momentum

The model uses three time horizons:

* **10D** — short-term acceleration/deceleration
* **20D** — current swing momentum
* **50D** — broader swing trend

The shorter 10-day horizon receives less weight to reduce sensitivity to temporary price noise.

### Volatility Normalization

The dashboard uses realized volatility and ATR so that securities with very different volatility characteristics can be compared more fairly.

For example, a +10% move in a low-volatility ETF may represent much stronger risk-adjusted momentum than the same +10% move in a highly volatile leveraged product.

### Trend Score

Trend strength is evaluated using:

* Price above EMA10
* Price above EMA20
* Price above EMA50
* EMA10 above EMA20
* EMA20 above EMA50
* Rising EMA20
* Rising EMA50

A **Trend score of 100** represents a very strong and well-structured swing trend.

### ATR20

**ATR20** measures the stock's distance from its 20-day EMA in ATR units:

`(Price - EMA20) / ATR(14)`

Examples:

* **+2.0** = price is 2 ATR above EMA20
* **+0.2** = slightly above EMA20
* **-0.5** = modestly below EMA20
* **-1.0** = meaningful technical damage
* **-2.0** = severe deterioration relative to normal volatility

Using ATR allows the model to distinguish normal volatility from genuinely abnormal price deterioration.

### Score Deterioration

The dashboard tracks how Technical Score changes over time.

**Δ5**

`Current Score - Score 5 trading days ago`

**Δ10**

`Current Score - Score 10 trading days ago`

Negative values indicate deterioration.

For example:

`Δ5 = -12`

means the Technical Score has fallen 12 points during the last five trading sessions.

### RankΔ5

**RankΔ5** measures how the security's portfolio ranking changed during the last five sessions.

Negative values mean the stock is being overtaken by other holdings.

This can help distinguish between:

* a stock whose own technical condition is breaking down, and
* a stock that remains healthy but is losing relative leadership.

### Action Engine

Each security receives an Action classification:

**EXIT**
Severe technical weakness with confirmed longer-term trend damage.

**TRIM**
Weak portfolio ranking combined with confirmed EMA/ATR deterioration.

**TRIM WATCH**
A weak holding approaching or beginning a technical breakdown.

**DETERIORATING**
Momentum or relative ranking is deteriorating, but the underlying price trend has not yet broken enough to justify an automatic trim.

**HOLD**
Technical condition remains acceptable.

**RECOVERING**
A historically weak holding whose technical score is improving materially.

**LEADER**
A top-ranked holding with strong trend structure.

### Trim Priority

Technical Score and Trim Priority are deliberately separate.

**Technical Score** answers:

> How strong is this holding today?

**Trim Priority** answers:

> If I need to reduce positions, which holding deserves attention first?

Trim Priority combines:

* **65% current technical weakness**
* **25% 5-day score deterioration**
* **10% 10-day score deterioration**

However, the dashboard does **not** blindly rank positions by this number.

The Action Engine takes priority.

Sell-eligible states are considered first:

**EXIT → TRIM → TRIM WATCH**

Trim Priority then helps rank securities within those groups.

This prevents an improving laggard from being sold before a genuinely broken position.

### Trim# vs Tech#

The dashboard contains two different rankings:

**Tech#**
Ranks holdings from technically strongest to weakest.

**Trim#**
Ranks holdings according to which positions should be reviewed first when reducing exposure.

These numbers may differ substantially because Trim# also considers deterioration, trend damage, and recovery.

### SPY / QQQ Comparison

The Diagnostics view also displays relative 20-day performance versus:

* SPY
* QQQ

These values are informational and currently **do not affect the Technical Score**, allowing securities from different sectors and asset exposures to compete primarily on their own technical characteristics.

### Portfolio Management Use

The dashboard is designed to answer a practical question:

> If I own 30–40 positions and need to remove 3–4 names, where should I look first?

Rather than manually reviewing every chart, the trader can begin with the highest-ranked **EXIT / TRIM / TRIM WATCH** candidates and then examine the underlying technical evidence.

The indicator is calculated from **daily data** and is intended primarily for decisions made after the daily close rather than intraday trading.

The portfolio ticker list can be edited directly from the indicator settings, allowing holdings to be added or removed without rewriting the Pine Script.

**This indicator is a technical decision-support and portfolio-ranking tool. It is not financial advice and should not be used as a standalone trading or risk-management system.**

## Source Code

````pine
//@version=6
indicator("Swing Portfolio Trim Dashboard v1.5", shorttitle="TrimDash", overlay=true, max_bars_back=300, calc_bars_count=300)


// ============================================================================
// INPUTS
// ============================================================================

string symbolsInput = input.text_area(
     "SOXL,SMH,MU,STX,GLW,CRDO,ARM,LITE,AMAT,COHR,AAOI,CBRS,NOK,MRVL,ALAB,HPE,DELL,INTC,ENPH,ZNOG,NESR,MPC,NFLX,PLTR,IGV,TEM,ARKG,CIBR,MRNA,PURR,TNA,UGL,AGQ,GDXU,LPLA",
     "Portfolio tickers",
     tooltip="Comma-separated TradingView symbols. Add/remove holdings here. Maximum 38 portfolio symbols."
)

string spySymbol = input.symbol("AMEX:SPY", "SPY benchmark")
string qqqSymbol = input.symbol("NASDAQ:QQQ", "QQQ benchmark")

string viewMode = input.string(
     "Trim",
     "Dashboard view",
     options=["Trim", "Diagnostics"]
)

int rowsInput = input.int(
     38,
     "Rows to show",
     minval=5,
     maxval=38
)


// ============================================================================
// TECHNICAL SCORE WEIGHTS
//
// RAW MOMENTUM = 30%
// 10D = 5%
// 20D = 10%
// 50D = 15%
//
// VOL-ADJUSTED MOMENTUM = 25%
// VA10 = 2.5%
// VA20 = 7.5%
// VA50 = 15%
//
// TREND STRUCTURE = 20%
// ATR-NORMALIZED HEALTH = 25%
//
// TOTAL = 100%
// ============================================================================

float W_R10 = 0.05
float W_R20 = 0.10
float W_R50 = 0.15

float W_VA10 = 0.025
float W_VA20 = 0.075
float W_VA50 = 0.15

float W_TREND = 0.20
float W_ATR = 0.25


// ============================================================================
// DATA OBJECT
// ============================================================================

type Packet
    float r10
    float r20
    float r50

    float va10
    float va20
    float va50

    float trend
    float atrHealth

    float d20
    float d50

    float r10_5
    float r20_5
    float r50_5

    float va10_5
    float va20_5
    float va50_5

    float trend_5
    float atrHealth_5

    float r10_10
    float r20_10
    float r50_10

    float va10_10
    float va20_10
    float va50_10

    float trend_10
    float atrHealth_10


// ============================================================================
// HELPERS
// ============================================================================

f_clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))


// 100 = strongest
// 0 = weakest

f_percentRank(array<float> values, float value) =>
    float result = na

    if not na(value)
        int validCount = 0
        int belowCount = 0

        for x in values
            if not na(x)
                validCount += 1

                if x < value
                    belowCount += 1

        if validCount > 1
            result := 100.0 * float(belowCount) / float(validCount - 1)
        else
            result := 50.0

    result


// Rank 1 = strongest

f_rankDesc(array<float> values, float value) =>
    int result = na

    if not na(value)
        result := 1

        for x in values
            if not na(x) and x > value
                result += 1

    result


// ============================================================================
// ACTION SORT TIER
//
// IMPORTANT:
//
// EXIT / TRIM / TRIM WATCH are true sell-eligible tiers.
//
// DETERIORATING is now a WARNING, so it shares the same sorting tier as HOLD.
// It therefore does NOT automatically outrank every HOLD.
//
// 7 EXIT
// 6 TRIM
// 5 TRIM WATCH
// 3 DETERIORATING
// 3 HOLD
// 2 RECOVERING
// 1 LEADER
// 0 NO DATA
// ============================================================================

f_tierCode(string action) =>
    switch action
        "EXIT" => 7
        "TRIM" => 6
        "TRIM WATCH" => 5
        "DETERIORATING" => 3
        "HOLD" => 3
        "RECOVERING" => 2
        "LEADER" => 1
        "NO DATA" => 0
        => 0


// ============================================================================
// DAILY CALCULATION
// ============================================================================

f_packet() =>

    // ------------------------------------------------------------------------
    // EMA + ATR
    // ------------------------------------------------------------------------

    float ema10 = ta.ema(close, 10)
    float ema20 = ta.ema(close, 20)
    float ema50 = ta.ema(close, 50)

    float atr14 = ta.atr(14)


    // ------------------------------------------------------------------------
    // RAW MOMENTUM
    // ------------------------------------------------------------------------

    float r10 = 100.0 * (close / close[10] - 1.0)
    float r20 = 100.0 * (close / close[20] - 1.0)
    float r50 = 100.0 * (close / close[50] - 1.0)


    // ------------------------------------------------------------------------
    // VOLATILITY-ADJUSTED MOMENTUM
    // ------------------------------------------------------------------------

    float dailyLogReturn = math.log(close / close[1])

    float vol10 = ta.stdev(dailyLogReturn, 10) * math.sqrt(10.0)
    float vol20 = ta.stdev(dailyLogReturn, 20) * math.sqrt(20.0)
    float vol50 = ta.stdev(dailyLogReturn, 50) * math.sqrt(50.0)

    float va10 = na
    float va20 = na
    float va50 = na

    if not na(vol10) and vol10 > 0
        va10 := math.log(close / close[10]) / vol10

    if not na(vol20) and vol20 > 0
        va20 := math.log(close / close[20]) / vol20

    if not na(vol50) and vol50 > 0
        va50 := math.log(close / close[50]) / vol50


    // ------------------------------------------------------------------------
    // TREND STRUCTURE
    //
    // MAXIMUM = 25 POINTS
    //
    // Price > EMA10       3
    // Price > EMA20       5
    // Price > EMA50       5
    // EMA10 > EMA20       3
    // EMA20 > EMA50       3
    // EMA20 rising        3
    // EMA50 rising        3
    // ------------------------------------------------------------------------

    float trendPts = 0.0

    if close > ema10
        trendPts += 3.0

    if close > ema20
        trendPts += 5.0

    if close > ema50
        trendPts += 5.0

    if ema10 > ema20
        trendPts += 3.0

    if ema20 > ema50
        trendPts += 3.0

    if ema20 > ema20[5]
        trendPts += 3.0

    if ema50 > ema50[5]
        trendPts += 3.0

    float trend = 100.0 * trendPts / 25.0


    // ------------------------------------------------------------------------
    // ATR-NORMALIZED DISTANCE
    //
    // d20 = -1.5 means price is 1.5 ATR below EMA20
    // ------------------------------------------------------------------------

    float d20 = na
    float d50 = na

    if not na(atr14) and atr14 > 0
        d20 := (close - ema20) / atr14
        d50 := (close - ema50) / atr14


    // ------------------------------------------------------------------------
    // ATR HEALTH
    //
    // EMA20
    // >= EMA20 = 100
    // -1 ATR = 50
    // -2 ATR = 0
    //
    // EMA50
    // >= EMA50 = 100
    // -3 ATR = 0
    // ------------------------------------------------------------------------

    float h20 = na
    float h50 = na

    if not na(d20)
        h20 := f_clamp(100.0 + math.min(d20, 0.0) * 50.0, 0.0, 100.0)

    if not na(d50)
        h50 := f_clamp(100.0 + math.min(d50, 0.0) * 33.3333, 0.0, 100.0)

    float atrHealth = na

    if not na(h20) and not na(h50)
        atrHealth := 0.60 * h20 + 0.40 * h50


    // ------------------------------------------------------------------------
    // RETURN OBJECT
    // ------------------------------------------------------------------------

    Packet.new(
         r10,
         r20,
         r50,

         va10,
         va20,
         va50,

         trend,
         atrHealth,

         d20,
         d50,

         r10[5],
         r20[5],
         r50[5],

         va10[5],
         va20[5],
         va50[5],

         trend[5],
         atrHealth[5],

         r10[10],
         r20[10],
         r50[10],

         va10[10],
         va20[10],
         va50[10],

         trend[10],
         atrHealth[10]
    )


// ============================================================================
// TECHNICAL SCORE
// ============================================================================

f_score(
     float pr10,
     float pr20,
     float pr50,
     float pva10,
     float pva20,
     float pva50,
     float trend,
     float atrHealth
) =>
    float result = na

    bool valid = not na(pr10) and not na(pr20) and not na(pr50) and not na(pva10) and not na(pva20) and not na(pva50) and not na(trend) and not na(atrHealth)

    if valid
        result := W_R10 * pr10 + W_R20 * pr20 + W_R50 * pr50 + W_VA10 * pva10 + W_VA20 * pva20 + W_VA50 * pva50 + W_TREND * trend + W_ATR * atrHealth

    result


// ============================================================================
// FORMATTING
// ============================================================================

f_fmt1(float x) =>
    string result = "na"

    if not na(x)
        result := str.tostring(x, "#.0")

    result


f_fmtPct(float x) =>
    string result = "na"

    if not na(x)
        result := str.tostring(x, "#.0") + "%"

    result


f_fmtSigned(float x) =>
    string result = "na"

    if not na(x)
        string prefix = ""

        if x > 0
            prefix := "+"

        result := prefix + str.tostring(x, "#.0")

    result


f_fmtRank(int x) =>
    string result = "na"

    if not na(x)
        result := str.tostring(x)

    result


f_scoreBg(float score) =>
    color result = color.new(color.gray, 80)

    if not na(score)
        if score >= 75
            result := color.new(color.green, 72)
        else if score >= 55
            result := color.new(color.green, 86)
        else if score >= 40
            result := color.new(color.orange, 80)
        else
            result := color.new(color.red, 78)

    result


f_deltaBg(float x) =>
    color result = color.new(color.gray, 92)

    if not na(x)
        if x <= -12
            result := color.new(color.red, 65)
        else if x <= -8
            result := color.new(color.orange, 72)
        else if x >= 8
            result := color.new(color.green, 75)
        else if x >= 5
            result := color.new(color.green, 88)

    result


f_actionBg(string action) =>
    color result = color.new(color.gray, 88)

    switch action
        "EXIT" =>
            result := color.new(color.red, 35)

        "TRIM" =>
            result := color.new(color.red, 55)

        "TRIM WATCH" =>
            result := color.new(color.orange, 58)

        "DETERIORATING" =>
            result := color.new(color.orange, 78)

        "RECOVERING" =>
            result := color.new(color.aqua, 78)

        "LEADER" =>
            result := color.new(color.green, 62)

        "NO DATA" =>
            result := color.new(color.gray, 70)

        =>
            result := color.new(color.gray, 88)

    result


// ============================================================================
// BUILD SYMBOL LIST
// ============================================================================

var array<string> symbols = array.new<string>()

if barstate.isfirst
    array<string> rawSymbols = str.split(symbolsInput, ",")

    for rawSymbol in rawSymbols
        string cleanSymbol = str.trim(rawSymbol)

        if str.length(cleanSymbol) > 0
            array.push(symbols, cleanSymbol)


int n = array.size(symbols)


if barstate.isfirst
    if n == 0
        runtime.error("Portfolio ticker list is empty.")

    if n > 38
        runtime.error("Maximum 38 portfolio symbols in this version.")


// ============================================================================
// TABLE
// ============================================================================

var table dash = table.new(
     position.top_right,
     13,
     rowsInput + 1,
     border_width=1
)


// ============================================================================
// LAST BAR ONLY
// ============================================================================

if barstate.islast

    // ========================================================================
    // DATA ARRAYS
    // ========================================================================

    array<Packet> packets = array.new<Packet>()
    array<bool> dataReady = array.new<bool>()


    array<float> aR10 = array.new<float>()
    array<float> aR20 = array.new<float>()
    array<float> aR50 = array.new<float>()

    array<float> aVA10 = array.new<float>()
    array<float> aVA20 = array.new<float>()
    array<float> aVA50 = array.new<float>()


    array<float> aR10_5 = array.new<float>()
    array<float> aR20_5 = array.new<float>()
    array<float> aR50_5 = array.new<float>()

    array<float> aVA10_5 = array.new<float>()
    array<float> aVA20_5 = array.new<float>()
    array<float> aVA50_5 = array.new<float>()


    array<float> aR10_10 = array.new<float>()
    array<float> aR20_10 = array.new<float>()
    array<float> aR50_10 = array.new<float>()

    array<float> aVA10_10 = array.new<float>()
    array<float> aVA20_10 = array.new<float>()
    array<float> aVA50_10 = array.new<float>()


    // ========================================================================
    // REQUEST EACH PORTFOLIO SECURITY
    // ========================================================================

    for symbol in symbols

        Packet requestedPacket = request.security(
             symbol,
             "1D",
             f_packet(),
             ignore_invalid_symbol=true,
             calc_bars_count=300
        )


        bool objectExists = not na(requestedPacket)

        Packet p = requestedPacket


        if not objectExists
            p := Packet.new()


        bool ready = false

        if objectExists
            ready := not na(p.r50) and not na(p.va50) and not na(p.atrHealth) and not na(p.r50_10) and not na(p.va50_10) and not na(p.trend_10) and not na(p.atrHealth_10)


        array.push(packets, p)
        array.push(dataReady, ready)


        array.push(aR10, p.r10)
        array.push(aR20, p.r20)
        array.push(aR50, p.r50)

        array.push(aVA10, p.va10)
        array.push(aVA20, p.va20)
        array.push(aVA50, p.va50)


        array.push(aR10_5, p.r10_5)
        array.push(aR20_5, p.r20_5)
        array.push(aR50_5, p.r50_5)

        array.push(aVA10_5, p.va10_5)
        array.push(aVA20_5, p.va20_5)
        array.push(aVA50_5, p.va50_5)


        array.push(aR10_10, p.r10_10)
        array.push(aR20_10, p.r20_10)
        array.push(aR50_10, p.r50_10)

        array.push(aVA10_10, p.va10_10)
        array.push(aVA20_10, p.va20_10)
        array.push(aVA50_10, p.va50_10)


    // ========================================================================
    // SPY + QQQ
    //
    // DISPLAY ONLY
    // ========================================================================

    [spy10, spy20, spy50] = request.security(
         spySymbol,
         "1D",
         [
             100.0 * (close / close[10] - 1.0),
             100.0 * (close / close[20] - 1.0),
             100.0 * (close / close[50] - 1.0)
         ],
         calc_bars_count=100
    )


    [qqq10, qqq20, qqq50] = request.security(
         qqqSymbol,
         "1D",
         [
             100.0 * (close / close[10] - 1.0),
             100.0 * (close / close[20] - 1.0),
             100.0 * (close / close[50] - 1.0)
         ],
         calc_bars_count=100
    )


    // ========================================================================
    // SCORES
    // ========================================================================

    array<float> scores = array.new<float>()
    array<float> scores5 = array.new<float>()
    array<float> scores10 = array.new<float>()


    for i = 0 to n - 1

        Packet p = array.get(packets, i)
        bool ready = array.get(dataReady, i)

        float s = na
        float s5 = na
        float s10 = na


        if ready

            s := f_score(
                 f_percentRank(aR10, p.r10),
                 f_percentRank(aR20, p.r20),
                 f_percentRank(aR50, p.r50),
                 f_percentRank(aVA10, p.va10),
                 f_percentRank(aVA20, p.va20),
                 f_percentRank(aVA50, p.va50),
                 p.trend,
                 p.atrHealth
            )


            s5 := f_score(
                 f_percentRank(aR10_5, p.r10_5),
                 f_percentRank(aR20_5, p.r20_5),
                 f_percentRank(aR50_5, p.r50_5),
                 f_percentRank(aVA10_5, p.va10_5),
                 f_percentRank(aVA20_5, p.va20_5),
                 f_percentRank(aVA50_5, p.va50_5),
                 p.trend_5,
                 p.atrHealth_5
            )


            s10 := f_score(
                 f_percentRank(aR10_10, p.r10_10),
                 f_percentRank(aR20_10, p.r20_10),
                 f_percentRank(aR50_10, p.r50_10),
                 f_percentRank(aVA10_10, p.va10_10),
                 f_percentRank(aVA20_10, p.va20_10),
                 f_percentRank(aVA50_10, p.va50_10),
                 p.trend_10,
                 p.atrHealth_10
            )


        array.push(scores, s)
        array.push(scores5, s5)
        array.push(scores10, s10)


    // ========================================================================
    // TECHNICAL RANKS
    // ========================================================================

    array<int> ranks = array.new<int>()
    array<int> ranks5 = array.new<int>()
    array<int> ranks10 = array.new<int>()


    for i = 0 to n - 1

        float s = array.get(scores, i)
        float s5 = array.get(scores5, i)
        float s10 = array.get(scores10, i)

        array.push(ranks, f_rankDesc(scores, s))
        array.push(ranks5, f_rankDesc(scores5, s5))
        array.push(ranks10, f_rankDesc(scores10, s10))


    // ========================================================================
    // PORTFOLIO CUT-OFFS
    // ========================================================================

    int leaderCut = int(math.ceil(float(n) * 0.20))

    int bottom30Cut = int(math.floor(float(n) * 0.70))
    int bottom25Cut = int(math.floor(float(n) * 0.75))
    int bottom20Cut = int(math.floor(float(n) * 0.80))


    // ========================================================================
    // ACTION + TRIM PRIORITY
    // ========================================================================

    array<float> trimPriorities = array.new<float>()
    array<string> actions = array.new<string>()

    array<float> trimSortKeys = array.new<float>()
    array<float> techSortKeys = array.new<float>()


    for i = 0 to n - 1

        Packet p = array.get(packets, i)

        bool ready = array.get(dataReady, i)

        float s = array.get(scores, i)
        float s5 = array.get(scores5, i)
        float s10 = array.get(scores10, i)

        int rk = array.get(ranks, i)
        int rk5 = array.get(ranks5, i)
        int rk10 = array.get(ranks10, i)


        string action = "NO DATA"

        float trimPriority = 0.0
        float sortKey = 0.0
        float techKey = -1.0


        bool validRow = ready and not na(s) and not na(s5) and not na(s10) and not na(rk) and not na(rk5) and not na(rk10)


        if validRow

            // ----------------------------------------------------------------
            // DETERIORATION
            // ----------------------------------------------------------------

            float scoreDelta5 = s - s5
            float scoreDelta10 = s - s10

            int rankDelta5 = rk5 - rk
            int rankDelta10 = rk10 - rk


            // ----------------------------------------------------------------
            // PORTFOLIO POSITION
            // ----------------------------------------------------------------

            bool bottom30 = rk > bottom30Cut
            bool bottom25 = rk > bottom25Cut
            bool bottom20 = rk > bottom20Cut


            // ----------------------------------------------------------------
            // PRICE DAMAGE
            // ----------------------------------------------------------------

            bool belowEMA20 = false
            bool fastDamage = false
            bool severeDamage = false

            if not na(p.d20)
                belowEMA20 := p.d20 < 0
                fastDamage := p.d20 <= -1.0

            if not na(p.d50)
                severeDamage := p.d50 <= -1.0 and p.trend < 45.0


            // ----------------------------------------------------------------
            // DETERIORATION FLAGS
            //
            // Rapid deterioration:
            //
            // Score falls >= 8 points in 5 days
            // OR rank falls >= 6 places
            // ----------------------------------------------------------------

            bool rapidDeterioration = scoreDelta5 <= -8.0 or rankDelta5 <= -6


            // DETERIORATING now requires weakening PLUS evidence that
            // the stock's current condition is no longer exceptionally healthy.

            bool deteriorationConfirmed = rapidDeterioration and (s < 65.0 or p.trend < 70.0 or belowEMA20)


            // Weak stock materially improving

            bool recovering = s < 55.0 and scoreDelta5 >= 6.0


            // Strong top-quintile holding

            bool leader = rk <= leaderCut and p.trend >= 70.0


            // ----------------------------------------------------------------
            // ACTION ENGINE V1.5
            //
            // EXIT:
            // Bottom 20% + meaningful EMA50 damage + weak trend.
            //
            // TRIM:
            // Bottom 25% AND:
            //   1) >= 1 ATR below EMA20
            //        OR
            //   2) rapid deterioration AND below EMA20
            //
            // This fixes ARM-type false positives:
            // deterioration alone no longer produces TRIM while price is
            // still above EMA20.
            //
            // RECOVERING:
            // Checked before TRIM WATCH to protect improving laggards.
            //
            // TRIM WATCH:
            // Bottom 30% + either below EMA20 OR rapid deterioration.
            //
            // DETERIORATING:
            // Warning only, with confirmation requirement.
            // ----------------------------------------------------------------

            if bottom20 and severeDamage
                action := "EXIT"

            else if bottom25 and (fastDamage or (rapidDeterioration and belowEMA20))
                action := "TRIM"

            else if recovering
                action := "RECOVERING"

            else if bottom30 and (belowEMA20 or rapidDeterioration)
                action := "TRIM WATCH"

            else if deteriorationConfirmed
                action := "DETERIORATING"

            else if leader
                action := "LEADER"

            else
                action := "HOLD"


            // ----------------------------------------------------------------
            // TRIM PRIORITY
            //
            // USED WITHIN SORT TIERS
            //
            // 65% current weakness
            // 25% 5D deterioration
            // 10% 10D deterioration
            // ----------------------------------------------------------------

            float weakness = 100.0 - s

            float d5Severity = f_clamp((s5 - s) / 20.0 * 100.0, -100.0, 100.0)

            float d10Severity = f_clamp((s10 - s) / 30.0 * 100.0, -100.0, 100.0)

            trimPriority := 0.65 * weakness + 0.25 * d5Severity + 0.10 * d10Severity

            trimPriority := f_clamp(trimPriority, 0.0, 100.0)


            // ----------------------------------------------------------------
            // FINAL SORT KEY
            //
            // SELL-ELIGIBLE:
            //
            // EXIT > TRIM > TRIM WATCH
            //
            // DETERIORATING + HOLD:
            //
            // SAME tier.
            // Trim Priority decides which deserves more attention.
            //
            // RECOVERING and LEADER are protected.
            //
            // Tie-break:
            // ATR20 damage then RankDelta5.
            // ----------------------------------------------------------------

            int tier = f_tierCode(action)

            float atrTie = 0.0

            if not na(p.d20)
                atrTie := f_clamp(-p.d20, 0.0, 10.0)

            float rankTie = f_clamp(-float(rankDelta5), 0.0, 50.0)

            sortKey := float(tier) * 1000000.0 + trimPriority * 1000.0 + atrTie * 10.0 + rankTie * 0.1

            techKey := s


        array.push(actions, action)
        array.push(trimPriorities, trimPriority)
        array.push(trimSortKeys, sortKey)
        array.push(techSortKeys, techKey)


    // ========================================================================
    // SORTING
    // ========================================================================

    array<int> trimOrder = array.sort_indices(trimSortKeys, order.descending)

    array<int> techOrder = array.sort_indices(techSortKeys, order.descending)


    // ========================================================================
    // TABLE SETTINGS
    // ========================================================================

    int showRows = math.min(rowsInput, n)

    color headerBg = color.new(color.gray, 60)
    color textCol = chart.fg_color


    table.clear(
         dash,
         0,
         0,
         12,
         rowsInput
    )


    // ========================================================================
    // TRIM VIEW
    // ========================================================================

    if viewMode == "Trim"

        table.cell(dash, 0, 0, "Trim#", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 1, 0, "Tech#", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 2, 0, "Ticker", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 3, 0, "Score", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 4, 0, "Δ5", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 5, 0, "Δ10", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 6, 0, "RankΔ5", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 7, 0, "Trend", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 8, 0, "ATR20", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 9, 0, "Priority", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 10, 0, "Action", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)


        for row = 0 to showRows - 1

            int i = array.get(trimOrder, row)

            Packet p = array.get(packets, i)

            float s = array.get(scores, i)
            float s5 = array.get(scores5, i)
            float s10 = array.get(scores10, i)

            int rk = array.get(ranks, i)
            int rk5 = array.get(ranks5, i)

            float priority = array.get(trimPriorities, i)

            string action = array.get(actions, i)

            string ticker = array.get(symbols, i)


            float delta5 = na

            if not na(s) and not na(s5)
                delta5 := s - s5


            float delta10 = na

            if not na(s) and not na(s10)
                delta10 := s - s10


            float rankChange5 = na

            if not na(rk) and not na(rk5)
                rankChange5 := float(rk5 - rk)


            table.cell(dash, 0, row + 1, str.tostring(row + 1), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 1, row + 1, f_fmtRank(rk), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 2, row + 1, ticker, text_color=textCol, text_size=size.tiny)

            table.cell(dash, 3, row + 1, f_fmt1(s), bgcolor=f_scoreBg(s), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 4, row + 1, f_fmtSigned(delta5), bgcolor=f_deltaBg(delta5), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 5, row + 1, f_fmtSigned(delta10), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 6, row + 1, f_fmtSigned(rankChange5), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 7, row + 1, f_fmt1(p.trend), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 8, row + 1, f_fmt1(p.d20), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 9, row + 1, f_fmt1(priority), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 10, row + 1, action, bgcolor=f_actionBg(action), text_color=textCol, text_size=size.tiny)


    // ========================================================================
    // DIAGNOSTICS VIEW
    // ========================================================================

    else

        table.cell(dash, 0, 0, "Tech#", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 1, 0, "Ticker", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 2, 0, "Score", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 3, 0, "10D", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 4, 0, "20D", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 5, 0, "50D", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 6, 0, "VA10", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 7, 0, "VA20", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 8, 0, "VA50", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 9, 0, "Trend", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 10, 0, "ATR20", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 11, 0, "vsSPY20", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)

        table.cell(dash, 12, 0, "vsQQQ20", bgcolor=headerBg, text_color=textCol, text_size=size.tiny)


        for row = 0 to showRows - 1

            int i = array.get(techOrder, row)

            Packet p = array.get(packets, i)

            float s = array.get(scores, i)

            int rk = array.get(ranks, i)

            string ticker = array.get(symbols, i)


            float pva10 = f_percentRank(aVA10, p.va10)

            float pva20 = f_percentRank(aVA20, p.va20)

            float pva50 = f_percentRank(aVA50, p.va50)


            float vsSpy20 = na

            if not na(p.r20) and not na(spy20)
                vsSpy20 := p.r20 - spy20


            float vsQqq20 = na

            if not na(p.r20) and not na(qqq20)
                vsQqq20 := p.r20 - qqq20


            table.cell(dash, 0, row + 1, f_fmtRank(rk), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 1, row + 1, ticker, text_color=textCol, text_size=size.tiny)

            table.cell(dash, 2, row + 1, f_fmt1(s), bgcolor=f_scoreBg(s), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 3, row + 1, f_fmtPct(p.r10), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 4, row + 1, f_fmtPct(p.r20), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 5, row + 1, f_fmtPct(p.r50), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 6, row + 1, f_fmt1(pva10), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 7, row + 1, f_fmt1(pva20), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 8, row + 1, f_fmt1(pva50), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 9, row + 1, f_fmt1(p.trend), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 10, row + 1, f_fmt1(p.d20), text_color=textCol, text_size=size.tiny)

            table.cell(dash, 11, row + 1, f_fmtSigned(vsSpy20) + "%", text_color=textCol, text_size=size.tiny)

            table.cell(dash, 12, row + 1, f_fmtSigned(vsQqq20) + "%", text_color=textCol, text_size=size.tiny)
````
