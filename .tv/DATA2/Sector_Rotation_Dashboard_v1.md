<!-- tradingview-pine-id: PUB;6643520b656b4b13a184b5b3e2d8e5c8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Sector Rotation Dashboard v1

Source: https://www.tradingview.com/script/dAOscEaH-Sector-Rotation-Dashboard-v1/

## Description

The Sector Rotation Dashboard is a market-ranking tool designed to show which major U.S. equity sectors are currently demonstrating the strongest relative strength and momentum versus the broader market.
It compares the 11 major sector ETFs—such as Technology, Energy, Financials, Health Care, Industrials and others—against SPY as the broad-market benchmark. Each sector receives a score based on a combination of short- and medium-term relative strength, absolute momentum, trend quality, trading volume, and recent acceleration. The sectors are then ranked from strongest to weakest.
In isolation, the dashboard is best used as a top-down screening tool, not as a standalone trade signal. Its purpose is to answer:
Which parts of the market are attracting leadership right now, and which sectors are weakening?

A high-ranking sector with strong positive relative strength versus SPY is showing market leadership. A sector moving rapidly up the rankings may be entering an emerging leadership phase. Conversely, a sector falling down the table or showing negative relative strength is losing momentum versus the broader market.
The most useful columns are:
- Rank — where the sector currently sits versus the other 10 sectors.
- Score — the combined strength score; higher means stronger overall technical leadership.
- RS 1M — approximately one-month performance relative to SPY.
- RS 3M — approximately three-month performance relative to SPY.
- RVOL — current volume relative to its normal volume.
- State — a simplified classification such as LEADER, WATCH, NEUTRAL, or WEAK.
The strongest situation is generally when several factors agree: the sector is near the top of the ranking, its score is high, both short- and medium-term relative strength are positive, and the ranking is improving rather than deteriorating.
For example, if Energy is ranked #1, has a score above 70, positive 1-month and 3-month relative strength versus SPY, and is maintaining or improving its rank, the dashboard is indicating that Energy is currently one of the strongest areas of the market. That does not mean every energy stock will outperform, but it identifies the sector as a logical area for further research.
A practical way to use the dashboard on its own is to review it once a week and focus attention on:
- sectors ranked near the top,
- sectors moving quickly upward,
- sectors transitioning from WATCH toward LEADER,
- and sectors where short-term strength is beginning to confirm longer-term strength.
The dashboard is therefore best thought of as a market map. It narrows the universe from thousands of stocks down to a handful of sectors where leadership is currently concentrated. From there, a user can choose to investigate industry groups or individual companies within those sectors.
Its main limitation is that it is primarily a confirmation tool. Because relative strength and momentum need time to develop, it may identify a sector after the initial breakout has already started. That is why the later industry- and stock-level breakout tools are useful companions, but the Sector Rotation Dashboard can still be used effectively by itself as a weekly market-leadership screen.
This is general information only and not financial advice. For personal guidance, please talk to a licensed professional.

This is the first indicator I've created so go easy on me!! The next one I'm working on hopes to identify which industries within sectors are driving the broader index to increase (or decrease).

---

## Source Code

````pine
//@version=6
indicator("Sector Rotation Dashboard v1", overlay = true, dynamic_requests = true)

// ============================================================================
// SETTINGS
// ============================================================================
string TF = input.timeframe("D", "Calculation timeframe")

int shortLen = input.int(21, "Short momentum", minval = 5)
int mediumLen = input.int(63, "Medium momentum", minval = 20)
int emaLen = input.int(20, "Fast EMA", minval = 5)
int smaLen = input.int(50, "Medium SMA", minval = 20)
int longLen = input.int(200, "Long SMA", minval = 100)
int volLen = input.int(20, "Volume average", minval = 5)

// ============================================================================
// UNIVERSE
// ============================================================================
var array<string> symbols = array.from(
     "AMEX:XLC",
     "AMEX:XLY",
     "AMEX:XLP",
     "AMEX:XLE",
     "AMEX:XLF",
     "AMEX:XLV",
     "AMEX:XLI",
     "AMEX:XLB",
     "AMEX:XLRE",
     "AMEX:XLK",
     "AMEX:XLU")

var array<string> names = array.from(
     "Communication",
     "Discretionary",
     "Staples",
     "Energy",
     "Financials",
     "Health Care",
     "Industrials",
     "Materials",
     "Real Estate",
     "Technology",
     "Utilities")

int N = array.size(symbols)

// ============================================================================
// HELPERS
// ============================================================================

// Cross-sectional percentile rank.
// Best value approaches 100; weakest approaches 0.
f_pct_rank(array<float> values, int idx) =>
    float target = array.get(values, idx)
    int valid = 0
    int below = 0

    for j = 0 to array.size(values) - 1
        float other = array.get(values, j)
        if not na(other)
            valid += 1
            if target > other
                below += 1

    valid > 1 ? 100.0 * below / (valid - 1) : 50.0

f_color(float score) =>
    score >= 70 ? color.rgb(0, 120, 75) :
     score >= 55 ? color.rgb(155, 120, 0) :
     score >= 40 ? color.rgb(75, 75, 75) :
                   color.rgb(145, 35, 35)

f_status(float score) =>
    score >= 70 ? "LEADER" :
     score >= 55 ? "WATCH" :
     score >= 40 ? "NEUTRAL" :
                   "WEAK"

// ============================================================================
// SPY DATA
// ============================================================================
[spyC, spy21, spy63] = request.security(
     "AMEX:SPY",
     TF,
     [close, close[shortLen], close[mediumLen]],
     barmerge.gaps_off,
     barmerge.lookahead_off)

// ============================================================================
// ARRAYS
// ============================================================================
array<float> ret21      = array.new<float>(N, na)
array<float> ret63      = array.new<float>(N, na)
array<float> rs21       = array.new<float>(N, na)
array<float> rs63       = array.new<float>(N, na)
array<float> accel      = array.new<float>(N, na)
array<float> rvol       = array.new<float>(N, na)

array<float> trendPts   = array.new<float>(N, na)
array<float> scores     = array.new<float>(N, na)

// ============================================================================
// COLLECT DATA
// ============================================================================
for i = 0 to N - 1

    string sym = array.get(symbols, i)

    [c, c21, c63, ema20, sma50, sma200, vol, avgVol] =
         request.security(
             sym,
             TF,
             [
                 close,
                 close[shortLen],
                 close[mediumLen],
                 ta.ema(close, emaLen),
                 ta.sma(close, smaLen),
                 ta.sma(close, longLen),
                 volume,
                 ta.sma(volume, volLen)
             ],
             barmerge.gaps_off,
             barmerge.lookahead_off)

    float r21 = c / c21 - 1.0
    float r63 = c / c63 - 1.0

    float spyR21 = spyC / spy21 - 1.0
    float spyR63 = spyC / spy63 - 1.0

    float rel21 = (1.0 + r21) / (1.0 + spyR21) - 1.0
    float rel63 = (1.0 + r63) / (1.0 + spyR63) - 1.0

    float acceleration = rel21 - rel63 / 3.0
    float relativeVol = avgVol != 0 ? vol / avgVol : na

    float trend = 0.0
    trend += c > ema20 ? 5.0 : 0.0
    trend += ema20 > sma50 ? 5.0 : 0.0
    trend += sma50 > sma200 ? 5.0 : 0.0

    array.set(ret21, i, r21)
    array.set(ret63, i, r63)
    array.set(rs21, i, rel21)
    array.set(rs63, i, rel63)
    array.set(accel, i, acceleration)
    array.set(rvol, i, relativeVol)
    array.set(trendPts, i, trend)

// ============================================================================
// SCORE
// Technical score = 80 points.
// Fund-flow enhancement adds the remaining 20 in version 2.
// Here it is rescaled to 100.
// ============================================================================
for i = 0 to N - 1

    float rsScore =
         f_pct_rank(rs21, i) * 0.15 +
         f_pct_rank(rs63, i) * 0.10

    float momentumScore =
         f_pct_rank(ret21, i) * 0.10 +
         f_pct_rank(ret63, i) * 0.10

    float trendScore = array.get(trendPts, i)

    float volumeScore =
         f_pct_rank(rvol, i) * 0.10

    float accelerationScore =
         f_pct_rank(accel, i) * 0.05

    // Maximum raw = 80.
    float rawScore =
         rsScore +
         momentumScore +
         trendScore +
         volumeScore +
         accelerationScore

    float score100 = rawScore / 80.0 * 100.0

    array.set(scores, i, score100)

// ============================================================================
// RANK FUNCTION
// ============================================================================
f_rank(array<float> values, int idx) =>
    float target = array.get(values, idx)
    int rank = 1

    for j = 0 to array.size(values) - 1
        if array.get(values, j) > target
            rank += 1

    rank

// ============================================================================
// DASHBOARD
// ============================================================================
var table dash = table.new(
     position.top_right,
     8,
     13,
     frame_color = color.rgb(80, 80, 80),
     frame_width = 1)

if barstate.islast

    table.cell(dash, 0, 0, "Rank", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 1, 0, "ETF", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 2, 0, "Sector", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 3, 0, "Score", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 4, 0, "RS 1M", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 5, 0, "RS 3M", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 6, 0, "RVOL", bgcolor = color.black, text_color = color.white)
    table.cell(dash, 7, 0, "State", bgcolor = color.black, text_color = color.white)

    // Print rows in rank order.
    for desiredRank = 1 to N

        int found = 0

        for i = 0 to N - 1
            if f_rank(scores, i) == desiredRank
                found := i

        float score = array.get(scores, found)
        color bg = f_color(score)

        table.cell(dash, 0, desiredRank, str.tostring(desiredRank),
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 1, desiredRank,
             str.replace(array.get(symbols, found), "AMEX:", ""),
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 2, desiredRank,
             array.get(names, found),
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 3, desiredRank,
             str.tostring(score, "#.0"),
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 4, desiredRank,
             str.tostring(array.get(rs21, found) * 100, "#.00") + "%",
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 5, desiredRank,
             str.tostring(array.get(rs63, found) * 100, "#.00") + "%",
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 6, desiredRank,
             str.tostring(array.get(rvol, found), "#.00"),
             bgcolor = bg, text_color = color.white)

        table.cell(dash, 7, desiredRank,
             f_status(score),
             bgcolor = bg, text_color = color.white)
````
