# Sector Rotation Dashboard v1

- url: https://www.tradingview.com/script/dAOscEaH-Sector-Rotation-Dashboard-v1/
- type: indicator
- pine_id: PUB;6643520b656b4b13a184b5b3e2d8e5c8
- version: 2.0

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

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nugoir

//@version=6
indicator("Sector Rotation Dashboard v2.3.2", overlay=true, dynamic_requests=true)

// ============================================================================
// SETTINGS
// ============================================================================
string TF = input.timeframe("D", "Calculation timeframe")

int shortLen  = input.int(21, "Short momentum", minval=5)
int mediumLen = input.int(63, "Medium momentum", minval=20)
int emaLen    = input.int(20, "Fast EMA", minval=5)
int smaLen    = input.int(50, "Medium SMA", minval=20)
int longLen   = input.int(200, "Long SMA", minval=100)
int volLen    = input.int(20, "Volume average", minval=5)

int weekBars  = 5
int monthBars = 20

// ============================================================================
// UNIVERSE
// ============================================================================
var array<string> symbols = array.from("AMEX:XLC", "AMEX:XLY", "AMEX:XLP", "AMEX:XLE", "AMEX:XLF", "AMEX:XLV", "AMEX:XLI", "AMEX:XLB", "AMEX:XLRE", "AMEX:XLK", "AMEX:XLU")

var array<string> names = array.from("Communication", "Discretionary", "Staples", "Energy", "Financials", "Health Care", "Industrials", "Materials", "Real Estate", "Technology", "Utilities")

int N = array.size(symbols)

// ============================================================================
// COLORS
// ============================================================================
color leaderColor        = color.rgb(0, 125, 80)
color watchColor         = color.rgb(170, 130, 0)
color neutralColor       = color.rgb(72, 72, 72)
color weakColor          = color.rgb(155, 40, 40)
color acceleratingColor  = color.rgb(0, 135, 125)
color emergingColor      = color.rgb(0, 120, 105)
color earlyColor         = color.rgb(45, 105, 160)
color deterioratingColor = color.rgb(190, 55, 45)

// ============================================================================
// HELPERS
// ============================================================================

f_pct_rank(array<float> values, int idx) =>
    float target = array.get(values, idx)
    int valid = 0
    int below = 0

    for j = 0 to array.size(values) - 1
        float other = array.get(values, j)

        if not na(other)
            valid += 1

            if not na(target) and target > other
                below += 1

    float result = 50.0

    if valid > 1
        result := 100.0 * below / (valid - 1)

    result


// Unique rank.
// If two scores are identical, the ETF earlier in the fixed universe
// receives the better rank.
// Therefore ranks 1 through 11 are always unique.
f_unique_rank(array<float> values, int idx) =>
    float target = array.get(values, idx)
    int rank = 1

    for j = 0 to array.size(values) - 1
        if j != idx
            float other = array.get(values, j)

            if not na(target) and not na(other)
                bool higher = other > target
                bool tied = math.abs(other - target) < 0.0000001
                bool winsTie = tied and j < idx

                if higher or winsTie
                    rank += 1

    rank


f_signed_int(int value) =>
    string result = str.tostring(value)

    if value > 0
        result := "+" + str.tostring(value)

    result


f_signed_1(float value) =>
    string result = "-"

    if not na(value)
        result := str.tostring(value, "#.0")

        if value > 0
            result := "+" + str.tostring(value, "#.0")

    result


f_signed_pct(float value) =>
    string result = "-"

    if not na(value)
        result := str.tostring(value * 100.0, "#.00") + "%"

        if value > 0
            result := "+" + str.tostring(value * 100.0, "#.00") + "%"

    result


// ============================================================================
// SYMBOL DATA FUNCTION
// ============================================================================

f_symbol_data() =>
    float ema20 = ta.ema(close, emaLen)
    float sma50 = ta.sma(close, smaLen)
    float sma200 = ta.sma(close, longLen)
    float avgVol = ta.sma(volume, volLen)

    float ema20W1 = ema20[weekBars]
    float sma50W1 = sma50[weekBars]
    float sma200W1 = sma200[weekBars]
    float avgVolW1 = avgVol[weekBars]

    float ema20W4 = ema20[monthBars]
    float sma50W4 = sma50[monthBars]
    float sma200W4 = sma200[monthBars]
    float avgVolW4 = avgVol[monthBars]

    [close, close[shortLen], close[mediumLen], ema20, sma50, sma200, volume, avgVol, close[weekBars], close[weekBars + shortLen], close[weekBars + mediumLen], ema20W1, sma50W1, sma200W1, volume[weekBars], avgVolW1, close[monthBars], close[monthBars + shortLen], close[monthBars + mediumLen], ema20W4, sma50W4, sma200W4, volume[monthBars], avgVolW4]

// ============================================================================
// SPY DATA
// ============================================================================

[spyC, spy21, spy63, spyCW1, spy21W1, spy63W1, spyCW4, spy21W4, spy63W4] = request.security("AMEX:SPY", TF, [close, close[shortLen], close[mediumLen], close[weekBars], close[weekBars + shortLen], close[weekBars + mediumLen], close[monthBars], close[monthBars + shortLen], close[monthBars + mediumLen]], barmerge.gaps_off, barmerge.lookahead_off)

float spyRet21 = spyC / spy21 - 1.0
float spyRet63 = spyC / spy63 - 1.0

float spyRet21W1 = spyCW1 / spy21W1 - 1.0
float spyRet63W1 = spyCW1 / spy63W1 - 1.0

float spyRet21W4 = spyCW4 / spy21W4 - 1.0
float spyRet63W4 = spyCW4 / spy63W4 - 1.0

// ============================================================================
// CURRENT ARRAYS
// ============================================================================

array<float> ret21 = array.new<float>(N, na)
array<float> ret63 = array.new<float>(N, na)

array<float> rs21 = array.new<float>(N, na)
array<float> rs63 = array.new<float>(N, na)

array<float> accel = array.new<float>(N, na)
array<float> rvol = array.new<float>(N, na)
array<float> trendPts = array.new<float>(N, na)

array<float> scores = array.new<float>(N, na)

// ============================================================================
// ONE WEEK AGO ARRAYS
// ============================================================================

array<float> ret21W1 = array.new<float>(N, na)
array<float> ret63W1 = array.new<float>(N, na)

array<float> rs21W1 = array.new<float>(N, na)
array<float> rs63W1 = array.new<float>(N, na)

array<float> accelW1 = array.new<float>(N, na)
array<float> rvolW1 = array.new<float>(N, na)
array<float> trendPtsW1 = array.new<float>(N, na)

array<float> scoresW1 = array.new<float>(N, na)

// ============================================================================
// FOUR WEEKS AGO ARRAYS
// ============================================================================

array<float> ret21W4 = array.new<float>(N, na)
array<float> ret63W4 = array.new<float>(N, na)

array<float> rs21W4 = array.new<float>(N, na)
array<float> rs63W4 = array.new<float>(N, na)

array<float> accelW4 = array.new<float>(N, na)
array<float> rvolW4 = array.new<float>(N, na)
array<float> trendPtsW4 = array.new<float>(N, na)

array<float> scoresW4 = array.new<float>(N, na)

// ============================================================================
// COLLECT DATA
// ============================================================================

for i = 0 to N - 1

    string sym = array.get(symbols, i)

    [c, c21, c63, ema20, sma50, sma200, vol, avgVol, cW1, c21W1, c63W1, ema20W1, sma50W1, sma200W1, volW1, avgVolW1, cW4, c21W4, c63W4, ema20W4, sma50W4, sma200W4, volW4, avgVolW4] = request.security(sym, TF, f_symbol_data(), barmerge.gaps_off, barmerge.lookahead_off, ignore_invalid_symbol=true)

    // ------------------------------------------------------------------------
    // CURRENT
    // ------------------------------------------------------------------------

    float r21 = c / c21 - 1.0
    float r63 = c / c63 - 1.0

    float rel21 = (1.0 + r21) / (1.0 + spyRet21) - 1.0
    float rel63 = (1.0 + r63) / (1.0 + spyRet63) - 1.0

    float acceleration = rel21 - rel63 / 3.0
    float relativeVol = avgVol != 0 ? vol / avgVol : na

    float trend = 0.0

    if c > ema20
        trend += 5.0

    if ema20 > sma50
        trend += 5.0

    if sma50 > sma200
        trend += 5.0

    array.set(ret21, i, r21)
    array.set(ret63, i, r63)
    array.set(rs21, i, rel21)
    array.set(rs63, i, rel63)
    array.set(accel, i, acceleration)
    array.set(rvol, i, relativeVol)
    array.set(trendPts, i, trend)

    // ------------------------------------------------------------------------
    // ONE WEEK AGO
    // ------------------------------------------------------------------------

    float r21_1 = cW1 / c21W1 - 1.0
    float r63_1 = cW1 / c63W1 - 1.0

    float rel21_1 = (1.0 + r21_1) / (1.0 + spyRet21W1) - 1.0
    float rel63_1 = (1.0 + r63_1) / (1.0 + spyRet63W1) - 1.0

    float acceleration1 = rel21_1 - rel63_1 / 3.0
    float relativeVol1 = avgVolW1 != 0 ? volW1 / avgVolW1 : na

    float trend1 = 0.0

    if cW1 > ema20W1
        trend1 += 5.0

    if ema20W1 > sma50W1
        trend1 += 5.0

    if sma50W1 > sma200W1
        trend1 += 5.0

    array.set(ret21W1, i, r21_1)
    array.set(ret63W1, i, r63_1)
    array.set(rs21W1, i, rel21_1)
    array.set(rs63W1, i, rel63_1)
    array.set(accelW1, i, acceleration1)
    array.set(rvolW1, i, relativeVol1)
    array.set(trendPtsW1, i, trend1)

    // ------------------------------------------------------------------------
    // FOUR WEEKS AGO
    // ------------------------------------------------------------------------

    float r21_4 = cW4 / c21W4 - 1.0
    float r63_4 = cW4 / c63W4 - 1.0

    float rel21_4 = (1.0 + r21_4) / (1.0 + spyRet21W4) - 1.0
    float rel63_4 = (1.0 + r63_4) / (1.0 + spyRet63W4) - 1.0

    float acceleration4 = rel21_4 - rel63_4 / 3.0
    float relativeVol4 = avgVolW4 != 0 ? volW4 / avgVolW4 : na

    float trend4 = 0.0

    if cW4 > ema20W4
        trend4 += 5.0

    if ema20W4 > sma50W4
        trend4 += 5.0

    if sma50W4 > sma200W4
        trend4 += 5.0

    array.set(ret21W4, i, r21_4)
    array.set(ret63W4, i, r63_4)
    array.set(rs21W4, i, rel21_4)
    array.set(rs63W4, i, rel63_4)
    array.set(accelW4, i, acceleration4)
    array.set(rvolW4, i, relativeVol4)
    array.set(trendPtsW4, i, trend4)

// ============================================================================
// CURRENT SCORE
// ============================================================================

for i = 0 to N - 1

    float rsScore = f_pct_rank(rs21, i) * 0.15 + f_pct_rank(rs63, i) * 0.10

    float momentumScore = f_pct_rank(ret21, i) * 0.10 + f_pct_rank(ret63, i) * 0.10

    float trendScore = array.get(trendPts, i)

    float volumeScore = f_pct_rank(rvol, i) * 0.10

    float accelerationScore = f_pct_rank(accel, i) * 0.05

    float rawScore = rsScore + momentumScore + trendScore + volumeScore + accelerationScore

    float score100 = rawScore / 80.0 * 100.0

    array.set(scores, i, score100)

// ============================================================================
// ONE WEEK AGO SCORE
// ============================================================================

for i = 0 to N - 1

    float rsScore1 = f_pct_rank(rs21W1, i) * 0.15 + f_pct_rank(rs63W1, i) * 0.10

    float momentumScore1 = f_pct_rank(ret21W1, i) * 0.10 + f_pct_rank(ret63W1, i) * 0.10

    float trendScore1 = array.get(trendPtsW1, i)

    float volumeScore1 = f_pct_rank(rvolW1, i) * 0.10

    float accelerationScore1 = f_pct_rank(accelW1, i) * 0.05

    float rawScore1 = rsScore1 + momentumScore1 + trendScore1 + volumeScore1 + accelerationScore1

    float score100_1 = rawScore1 / 80.0 * 100.0

    array.set(scoresW1, i, score100_1)

// ============================================================================
// FOUR WEEKS AGO SCORE
// ============================================================================

for i = 0 to N - 1

    float rsScore4 = f_pct_rank(rs21W4, i) * 0.15 + f_pct_rank(rs63W4, i) * 0.10

    float momentumScore4 = f_pct_rank(ret21W4, i) * 0.10 + f_pct_rank(ret63W4, i) * 0.10

    float trendScore4 = array.get(trendPtsW4, i)

    float volumeScore4 = f_pct_rank(rvolW4, i) * 0.10

    float accelerationScore4 = f_pct_rank(accelW4, i) * 0.05

    float rawScore4 = rsScore4 + momentumScore4 + trendScore4 + volumeScore4 + accelerationScore4

    float score100_4 = rawScore4 / 80.0 * 100.0

    array.set(scoresW4, i, score100_4)

// ============================================================================
// STATE ENGINE
// ============================================================================

f_state(float score, int rankNow, int rankW1, int rankW4, float deltaW1, float deltaW4, float rs1m) =>

    int improvement4 = rankW4 - rankNow

    bool deteriorating = false
    bool accelerating = false
    bool emerging = false
    bool earlyRotation = false

    if score >= 40.0
        if rankNow - rankW4 >= 3 and deltaW4 <= -7.0
            deteriorating := true

        if deltaW4 <= -15.0
            deteriorating := true

    if score >= 75.0 and rankNow <= 3 and deltaW1 > 0.0 and deltaW4 > 0.0
        accelerating := true

    if score >= 65.0 and improvement4 >= 3 and deltaW4 >= 7.0
        emerging := true

    if score >= 40.0 and score < 65.0 and rs1m > 0.0 and improvement4 >= 4 and deltaW4 >= 15.0
        earlyRotation := true

    string state = "WEAK"

    if deteriorating
        state := "DETERIORATING"
    else if accelerating
        state := "ACCELERATING"
    else if emerging
        state := "EMERGING"
    else if score >= 70.0
        state := "LEADER"
    else if earlyRotation
        state := "EARLY ROTATION"
    else if score >= 55.0
        state := "WATCH"
    else if score >= 40.0
        state := "NEUTRAL"
    else
        state := "WEAK"

    state


f_state_color(string state) =>

    color result = weakColor

    if state == "ACCELERATING"
        result := acceleratingColor
    else if state == "EMERGING"
        result := emergingColor
    else if state == "LEADER"
        result := leaderColor
    else if state == "EARLY ROTATION"
        result := earlyColor
    else if state == "WATCH"
        result := watchColor
    else if state == "NEUTRAL"
        result := neutralColor
    else if state == "DETERIORATING"
        result := deterioratingColor
    else
        result := weakColor

    result

// ============================================================================
// DASHBOARD
// ============================================================================

var table dash = table.new(position.top_right, 13, 13, frame_color=color.rgb(80, 80, 80), frame_width=1)

if barstate.islast

    table.cell(dash, 0, 0, "Rank", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "ETF", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 2, 0, "Sector", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 3, 0, "Score", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 4, 0, "Rank -1W", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 5, 0, "Rank -4W", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 6, 0, "ΔRank 4W", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 7, 0, "ΔScore 1W", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 8, 0, "ΔScore 4W", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 9, 0, "RS 1M", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 10, 0, "RS 3M", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 11, 0, "RVOL", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 12, 0, "State", bgcolor=color.black, text_color=color.white)

    for desiredRank = 1 to N

        int found = -1

        for i = 0 to N - 1
            int currentRank = f_unique_rank(scores, i)

            if currentRank == desiredRank
                found := i

        if found >= 0

            float score = array.get(scores, found)
            float score1 = array.get(scoresW1, found)
            float score4 = array.get(scoresW4, found)

            int rankNow = f_unique_rank(scores, found)
            int rankW1 = f_unique_rank(scoresW1, found)
            int rankW4 = f_unique_rank(scoresW4, found)

            int rankImprovement4 = rankW4 - rankNow

            float deltaScore1 = score - score1
            float deltaScore4 = score - score4

            float currentRS21 = array.get(rs21, found)
            float currentRS63 = array.get(rs63, found)
            float currentRVOL = array.get(rvol, found)

            string state = f_state(score, rankNow, rankW1, rankW4, deltaScore1, deltaScore4, currentRS21)

            color bg = f_state_color(state)

            string ticker = str.replace(array.get(symbols, found), "AMEX:", "")

            table.cell(dash, 0, desiredRank, str.tostring(rankNow), bgcolor=bg, text_color=color.white)
            table.cell(dash, 1, desiredRank, ticker, bgcolor=bg, text_color=color.white)
            table.cell(dash, 2, desiredRank, array.get(names, found), bgcolor=bg, text_color=color.white)
            table.cell(dash, 3, desiredRank, str.tostring(score, "#.0"), bgcolor=bg, text_color=color.white)
            table.cell(dash, 4, desiredRank, str.tostring(rankW1), bgcolor=bg, text_color=color.white)
            table.cell(dash, 5, desiredRank, str.tostring(rankW4), bgcolor=bg, text_color=color.white)
            table.cell(dash, 6, desiredRank, f_signed_int(rankImprovement4), bgcolor=bg, text_color=color.white)
            table.cell(dash, 7, desiredRank, f_signed_1(deltaScore1), bgcolor=bg, text_color=color.white)
            table.cell(dash, 8, desiredRank, f_signed_1(deltaScore4), bgcolor=bg, text_color=color.white)
            table.cell(dash, 9, desiredRank, f_signed_pct(currentRS21), bgcolor=bg, text_color=color.white)
            table.cell(dash, 10, desiredRank, f_signed_pct(currentRS63), bgcolor=bg, text_color=color.white)
            table.cell(dash, 11, desiredRank, str.tostring(currentRVOL, "#.00"), bgcolor=bg, text_color=color.white)
            table.cell(dash, 12, desiredRank, state, bgcolor=bg, text_color=color.white)
````
