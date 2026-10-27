# Half Life Mean Reversion

- url: https://www.tradingview.com/script/ACuUl4xF-Half-Life-Mean-Reversion/
- type: indicator
- pine_id: PUB;8452094fa63f48f6b9b540de67dfb1e3
- version: 3.0

## Description

Its a tool for those who work in statistical arbitrage/pair trading in stocks or asset classes.

a high correlation between two assets does not mean, they will be "mean reverting" too.

half life tells us if they are mean reverting. lower half life is better.

Half life of mean reversion = time taken by the "price ratio" of two assets, to revert back, to half way to its mean.

script takes 3 lookback periods and calculates the half life of all 3 periods. Then gives it an acceptance score. lower is better.

run for different pairs and chose the one with least acceptance scores

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LogicMonsters

//@version=6
indicator("RDSS MeanReversion Timescale")
plot(close)
var lookback1 = input.int(300, step = 10)
var lookback2 = input.int(600, step = 10)
var lookback3 = input.int(900, step = 10)

 //= input.int(100, "Hedge Ratio Length", minval=20)
// adfLength   = lookback1//input.int(100, "ADF Length", minval=30)
// hedgeLength = adfLength

numSymbol = input.symbol("CRYPTO:BTCUSD", "Numerator", group = "PAIR 1")
denSymbol = input.symbol("CRYPTO:ETHUSD",  "Denominator", group = "PAIR 1")

numSymbol2 = input.symbol("CRYPTO:SOLUSD", "Numerator", group = "PAIR 2")
denSymbol2 = input.symbol("CRYPTO:XRPUSD",  "Denominator", group = "PAIR 2")

numSymbol3 = input.symbol("TVC:GOLD", "Numerator", group = "PAIR 3")
denSymbol3 = input.symbol("TVC:SILVER",  "Denominator", group = "PAIR 3")

numSymbol4 = input.symbol("DJ:DJI", "Numerator", group = "PAIR 4")
denSymbol4 = input.symbol("NASDAQ:NXTQ",  "Denominator", group = "PAIR 4")

numSymbol5 = input.symbol("CRYPTO:BNBUSD", "Numerator", group = "PAIR 5")
denSymbol5 = input.symbol("CRYPTO:BTCUSD",  "Denominator", group = "PAIR 5")

// numSymbol6 = input.symbol("NSE:HINDPETRO", "Numerator", group = "PAIR 6")
// denSymbol6 = input.symbol("NSE:BPCL",  "Denominator", group = "PAIR 6")


// numSymbol7 = input.symbol("NSE:TVSMOTOR", "Numerator", group = "PAIR 7")
// denSymbol7 = input.symbol("NSE:HEROMOTOCO",  "Denominator", group = "PAIR 7")

// numSymbol8 = input.symbol("NSE:HDFCLIFE", "Numerator", group = "PAIR 8")
// denSymbol8 = input.symbol("NSE:ICICIPRULI",  "Denominator", group = "PAIR 8")

// numSymbol9 = input.symbol("NSE:TCS", "Numerator", group = "PAIR 9")
// denSymbol9 = input.symbol("NSE:NAUKRI",  "Denominator", group = "PAIR 9")

// numSymbol10 = input.symbol("NSE:HDFCAMC", "Numerator", group = "PAIR 10")
// denSymbol10 = input.symbol("NSE:NAM_INDIA",  "Denominator", group = "PAIR 10")


// =====================
// PRICE DATA
// =====================
numPrice = request.security(numSymbol, timeframe.period, close)
denPrice = request.security(denSymbol, timeframe.period, close)
numPrice2 = request.security(numSymbol2, timeframe.period, close)
denPrice2 = request.security(denSymbol2, timeframe.period, close)
numPrice3 = request.security(numSymbol3, timeframe.period, close)
denPrice3 = request.security(denSymbol3, timeframe.period, close)
numPrice4 = request.security(numSymbol4, timeframe.period, close)
denPrice4 = request.security(denSymbol4, timeframe.period, close)
numPrice5 = request.security(numSymbol5, timeframe.period, close)
denPrice5 = request.security(denSymbol5, timeframe.period, close)
// numPrice6 = request.security(numSymbol6, timeframe.period, close)
// denPrice6 = request.security(denSymbol6, timeframe.period, close)
// numPrice7 = request.security(numSymbol7, timeframe.period, close)
// denPrice7 = request.security(denSymbol7, timeframe.period, close)
// numPrice8 = request.security(numSymbol8, timeframe.period, close)
// denPrice8 = request.security(denSymbol8, timeframe.period, close)
// numPrice9 = request.security(numSymbol9, timeframe.period, close)
// denPrice9 = request.security(denSymbol9, timeframe.period, close)
// numPrice10 = request.security(numSymbol10, timeframe.period, close)
// denPrice10 = request.security(denSymbol10, timeframe.period, close)

var string[] numsymbolArr = array.from(numSymbol, numSymbol2, numSymbol3, numSymbol4, numSymbol5)//, numSymbol6, numSymbol7, numSymbol8, numSymbol9, numSymbol10)
var string[] densymbolArr = array.from(denSymbol, denSymbol2, denSymbol3, denSymbol4, denSymbol5)//, denSymbol6, denSymbol7, denSymbol8, denSymbol9, denSymbol10)
var float[] numpriceArr = array.from(numPrice, numPrice2, numPrice3, numPrice4, numPrice5)//, numPrice6, numPrice7, numPrice8, numPrice9, numPrice10)
var float[] denPriceArr = array.from(denPrice, denPrice2, denPrice3, denPrice4, denPrice5)//, denPrice6, denPrice7, denPrice8, denPrice9, denPrice10)


//var int[] lookbakArr = array.from(lookback, lookback2, lookback3, lookback4, lookback5, lookback6, lookback7, lookback8, lookback9, lookback10)

// =====================
// Z-SCORE
// =====================
f_Zscore(NP, DP, LB) =>
    R = NP/DP
    //MR = ta.sma(R, LB)
    STD = ta.stdev(R, LB)
    //ZS = (R - MR) / STD
    [R, STD]
[ratio, stdR] = f_Zscore(numPrice, denPrice, lookback1)
[ratio2, stdR2] = f_Zscore(numPrice2, denPrice2, lookback1)
[ratio3, stdR3] = f_Zscore(numPrice3, denPrice3, lookback1)
[ratio4, stdR4] = f_Zscore(numPrice4, denPrice4, lookback1)
[ratio5, stdR5] = f_Zscore(numPrice5, denPrice5, lookback1)
// [ratio6, stdR6] = f_Zscore(numPrice6, denPrice6, lookback1)
// [ratio7, stdR7] = f_Zscore(numPrice7, denPrice7, lookback1)
// [ratio8, stdR8] = f_Zscore(numPrice8, denPrice8, lookback1)
// [ratio9, stdR9] = f_Zscore(numPrice9, denPrice9, lookback1)
// [ratio10, stdR10] = f_Zscore(numPrice10, denPrice10, lookback1)

[ratio_2, stdR_2] = f_Zscore(numPrice, denPrice, lookback2)
[ratio2_2, stdR2_2] = f_Zscore(numPrice2, denPrice2, lookback2)
[ratio3_2, stdR3_2] = f_Zscore(numPrice3, denPrice3, lookback2)
[ratio4_2, stdR4_2] = f_Zscore(numPrice4, denPrice4, lookback2)
[ratio5_2, stdR5_2] = f_Zscore(numPrice5, denPrice5, lookback2)
// [ratio6_2, stdR6_2] = f_Zscore(numPrice6, denPrice6, lookback2)
// [ratio7_2, stdR7_2] = f_Zscore(numPrice7, denPrice7, lookback2)
// [ratio8_2, stdR8_2] = f_Zscore(numPrice8, denPrice8, lookback2)
// [ratio9_2, stdR9_2] = f_Zscore(numPrice9, denPrice9, lookback2)
// [ratio10_2, stdR10_2] = f_Zscore(numPrice10, denPrice10, lookback2)

[ratio_3, stdR_3] = f_Zscore(numPrice, denPrice, lookback3)
[ratio2_3, stdR2_3] = f_Zscore(numPrice2, denPrice2, lookback3)
[ratio3_3, stdR3_3] = f_Zscore(numPrice3, denPrice3, lookback3)
[ratio4_3, stdR4_3] = f_Zscore(numPrice4, denPrice4, lookback3)
[ratio5_3, stdR5_3] = f_Zscore(numPrice5, denPrice5, lookback3)
// [ratio6_3, stdR6_3] = f_Zscore(numPrice6, denPrice6, lookback3)
// [ratio7_3, stdR7_3] = f_Zscore(numPrice7, denPrice7, lookback3)
// [ratio8_3, stdR8_3] = f_Zscore(numPrice8, denPrice8, lookback3)
// [ratio9_3, stdR9_3] = f_Zscore(numPrice9, denPrice9, lookback3)
// [ratio10_3, stdR10_3] = f_Zscore(numPrice10, denPrice10, lookback3)


// AVGSTD = (stdR + stdR_2 + stdR_3)/3
// AVGSTD2 = (stdR2 + stdR2_2 + stdR2_3)/3
// AVGSTD3 = (stdR3 + stdR3_2 + stdR3_3)/3
// AVGSTD4 = (stdR4 + stdR4_2 + stdR4_3)/3
// AVGSTD5 = (stdR5 + stdR5_2 + stdR5_3)/3
// AVGSTD6 = (stdR6 + stdR6_2 + stdR6_3)/3
// AVGSTD7 = (stdR7 + stdR7_2 + stdR7_3)/3
// AVGSTD8 = (stdR8 + stdR8_2 + stdR8_3)/3
// AVGSTD9 = (stdR9 + stdR9_2 + stdR9_3)/3
// AVGSTD10 = (stdR10 + stdR10_2 + stdR10_3)/3

// Function to calculate Half-Life of mean reversion
calc_halflife(float series, int lookback) =>
    // 1. Calculate change in series (delta y)
    delta_y = series - series[1]
    // 2. Lagged series (y_t-1)
    y_lag = series[1]
    
    // 3. Linear Regression: delta_y = alpha + beta * y_lag
    // We need the slope (beta)
    float sumX  = 0.0
    float sumY  = 0.0
    float sumXY = 0.0
    float sumX2 = 0.0
    
    for i = 0 to lookback - 1
        x = y_lag[i]
        y = delta_y[i]
        sumX  += x
        sumY  += y
        sumXY += x * y
        sumX2 += x * x
        
    float beta = (lookback * sumXY - sumX * sumY) / (lookback * sumX2 - sumX * sumX)
    
    // 4. Calculate Half-life: -ln(2) / beta
    // beta must be negative for mean reversion
    float hl = beta < 0 ? -math.log(2) / beta : na
    hl

hl_value = calc_halflife(ratio, lookback1)
hl_value2 = calc_halflife(ratio2, lookback1)
hl_value3 = calc_halflife(ratio3, lookback1)
hl_value4 = calc_halflife(ratio4, lookback1)
hl_value5 = calc_halflife(ratio5, lookback1)
// hl_value6 = calc_halflife(ratio6, lookback1)
// hl_value7 = calc_halflife(ratio7, lookback1)
// hl_value8 = calc_halflife(ratio8, lookback1)
// hl_value9 = calc_halflife(ratio9, lookback1)
// hl_value10 = calc_halflife(ratio10, lookback1)

hl_value_2 = calc_halflife(ratio_2, lookback2)
hl_value2_2 = calc_halflife(ratio2_2, lookback2)
hl_value3_2 = calc_halflife(ratio3_2, lookback2)
hl_value4_2 = calc_halflife(ratio4_2, lookback2)
hl_value5_2 = calc_halflife(ratio5_2, lookback2)
// hl_value6_2 = calc_halflife(ratio6_2, lookback2)
// hl_value7_2 = calc_halflife(ratio7_2, lookback2)
// hl_value8_2 = calc_halflife(ratio8_2, lookback2)
// hl_value9_2 = calc_halflife(ratio9_2, lookback2)
// hl_value10_2 = calc_halflife(ratio10_2, lookback2)

hl_value_3 = calc_halflife(ratio_3, lookback3)
hl_value2_3 = calc_halflife(ratio2_3, lookback3)
hl_value3_3 = calc_halflife(ratio3_3, lookback3)
hl_value4_3 = calc_halflife(ratio4_3, lookback3)
hl_value5_3 = calc_halflife(ratio5_3, lookback3)
// hl_value6_3 = calc_halflife(ratio6_3, lookback3)
// hl_value7_3 = calc_halflife(ratio7_3, lookback3)
// hl_value8_3 = calc_halflife(ratio8_3, lookback3)
// hl_value9_3 = calc_halflife(ratio9_3, lookback3)
// hl_value10_3 = calc_halflife(ratio10_3, lookback3)

// calc_pair_score(float corr, float hl, float std) =>
//     float score = na

//     // === VALIDITY CHECK ===
//     if not na(corr) and not na(hl) and not na(std) and hl > 0 and std > 0

//         // === 1. CORRELATION SCORE (target 0.85) ===
//         // penalize if too far from 0.85
//         corrTarget = 0.90
//         corrScore = 1 - math.abs(corr - corrTarget) / 0.15
//         corrScore := math.max(corrScore, 0)  // clamp to 0

//         // === 2. HALF-LIFE SCORE (lower is better) ===
//         // normalize using inverse
//         hlScore = 1 / hl

//         // === 3. STD SCORE (higher is better) ===
//         stdScore = std

//         // === NORMALIZATION (important for stability) ===
//         hlScore  := hlScore * 100        // scale up
//         stdScore := stdScore / 10        // scale down if needed

//         // === FINAL WEIGHTED SCORE ===
//         score := corrScore * 0.4 + hlScore * 0.3 + stdScore * 0.3

//     score
// SCORE = calc_pair_score(0.92, hl_value, AVGSTD)
// SCORE2 = calc_pair_score(0.92, hl_value2, AVGSTD2)
// SCORE3 = calc_pair_score(0.92, hl_value3, AVGSTD3)
// SCORE4 = calc_pair_score(0.89, hl_value4, AVGSTD4)
// SCORE5 = calc_pair_score(0.92, hl_value5, AVGSTD5)
// SCORE6 = calc_pair_score(0.92, hl_value6, AVGSTD6)
// SCORE7 = calc_pair_score(0.92, hl_value7, AVGSTD7)
// SCORE8 = calc_pair_score(0.92, hl_value8, AVGSTD8)
// SCORE9 = calc_pair_score(0.92, hl_value9, AVGSTD9)
// SCORE10 = calc_pair_score(0.92, hl_value10, AVGSTD10)

//hl_value_median = ta.median(hl_value, hl_value_3)
//var float acceptanceratio = 0.0

GroupScore(a, b, c)=>
    // Mean
    avg = (a + b + c) / 3.0
    // Standard deviation
    variance = (math.pow(a - avg, 2) + math.pow(b - avg, 2) + math.pow(c - avg, 2)) / 3.0
    stdev = math.sqrt(variance)
    // Final score
    score = avg + stdev
    score
//var float acceptanceratio = 0.0
acceptanceratio = GroupScore(hl_value, hl_value_2, hl_value_3)//lower score is better
acceptanceratio2 = GroupScore(hl_value2, hl_value2_2, hl_value2_3)
acceptanceratio3 = GroupScore(hl_value3, hl_value3_2, hl_value3_3)
acceptanceratio4 = GroupScore(hl_value4, hl_value4_2, hl_value4_3)
acceptanceratio5 = GroupScore(hl_value5, hl_value5_2, hl_value5_3)
// acceptanceratio6 = GroupScore(hl_value6, hl_value6_2, hl_value6_3)
// acceptanceratio7 = GroupScore(hl_value7, hl_value7_2, hl_value7_3)
// acceptanceratio8 = GroupScore(hl_value8, hl_value8_2, hl_value8_3)
// acceptanceratio9 = GroupScore(hl_value9, hl_value9_2, hl_value9_3)
// acceptanceratio10 = GroupScore(hl_value10, hl_value10_2, hl_value10_3)

// acceptanceratio = 1/(math.abs(hl_value - hl_value_3) / hl_value_2)
// acceptanceratio2 = 1/(math.abs(hl_value2 - hl_value2_3) / hl_value2_2)
// acceptanceratio3 = 1/(math.abs(hl_value3 - hl_value3_3) / hl_value3_2)
// acceptanceratio4 = 1/(math.abs(hl_value4 - hl_value4_3) / hl_value4_2)
// acceptanceratio5 = 1/(math.abs(hl_value5 - hl_value5_3) / hl_value5_2)
// acceptanceratio6 = 1/(math.abs(hl_value6 - hl_value6_3) / hl_value6_2)
// acceptanceratio7 = 1/(math.abs(hl_value7 - hl_value7_3) / hl_value7_2)
// acceptanceratio8 = 1/(math.abs(hl_value8 - hl_value8_3) / hl_value8_2)
// acceptanceratio9 = 1/(math.abs(hl_value9 - hl_value9_3) / hl_value9_2)
// acceptanceratio10 = 1/(math.abs(hl_value10 - hl_value10_3) / hl_value10_2)

srcArr = array.from(acceptanceratio, acceptanceratio2, acceptanceratio3, acceptanceratio4, acceptanceratio5)//, 
 //acceptanceratio6, acceptanceratio7, acceptanceratio8, acceptanceratio9, acceptanceratio10)

rank_array(srcArr) =>
    int size = array.size(srcArr)
    int[] rankArr = array.new_int(size, 0)

    for i = 0 to size - 1
        float val_i = array.get(srcArr, i)
        int rank = 1

        for j = 0 to size - 1
            float val_j = array.get(srcArr, j)
            if not na(val_j) and val_j < val_i
                rank += 1

        array.set(rankArr, i, rank)

    rankArr
rankArr = rank_array(srcArr)


var table heatmap = table.new(position.bottom_left, 10, 11, border_width=1, border_color = color.black)

if barstate.islast
    for i = 0 to 4
        table.cell(heatmap, 0, i+1, array.get(numsymbolArr, i), bgcolor=color.black, text_color = color.white) 
        table.cell(heatmap, 1, i+1, array.get(densymbolArr, i), bgcolor=color.black, text_color = color.white) 
        table.cell(heatmap, 6, i+1, str.tostring(array.get(rankArr, i)), bgcolor=color.black, text_color = color.white)

    table.cell(heatmap, 0, 0, "Numerator", bgcolor=color.green, text_color = color.white) 
    table.cell(heatmap, 1, 0, "Denominator", bgcolor=color.green, text_color = color.white) 
    table.cell(heatmap, 2, 0, "MR timescale1 : " + str.tostring(lookback1), bgcolor=color.green, text_color = color.white) 
    table.cell(heatmap, 3, 0, "MR timescale2 : " + str.tostring(lookback2), bgcolor=color.green, text_color = color.white) 
    table.cell(heatmap, 4, 0, "MR timescale3 : " + str.tostring(lookback3), bgcolor=color.green, text_color = color.white)
    table.cell(heatmap, 5, 0, "Score(lower is better)", bgcolor=color.green, text_color = color.white)
    table.cell(heatmap, 6, 0, "Rank", bgcolor=color.green, text_color = color.white)


    table.cell(heatmap, 2, 1, str.tostring(hl_value, "0"), bgcolor=color.black, text_color = color.white)  
    table.cell(heatmap, 2, 2, str.tostring(hl_value2, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 2, 3, str.tostring(hl_value3, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 2, 4, str.tostring(hl_value4, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 2, 5, str.tostring(hl_value5, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 2, 6, str.tostring(hl_value6, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 2, 7, str.tostring(hl_value7, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 2, 8, str.tostring(hl_value8, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 2, 9, str.tostring(hl_value9, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 2, 10, str.tostring(hl_value10, "0"), bgcolor=color.black, text_color = color.white)

    table.cell(heatmap, 3, 1, str.tostring(hl_value_2, "0"), bgcolor=color.black, text_color = color.white)  
    table.cell(heatmap, 3, 2, str.tostring(hl_value2_2, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 3, 3, str.tostring(hl_value3_2, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 3, 4, str.tostring(hl_value4_2, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 3, 5, str.tostring(hl_value5_2, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 3, 6, str.tostring(hl_value6_2, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 3, 7, str.tostring(hl_value7_2, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 3, 8, str.tostring(hl_value8_2, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 3, 9, str.tostring(hl_value9_2, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 3, 10, str.tostring(hl_value10_2, "0"), bgcolor=color.black, text_color = color.white)

    table.cell(heatmap, 4, 1, str.tostring(hl_value_3, "0"), bgcolor=color.black, text_color = color.white)  
    table.cell(heatmap, 4, 2, str.tostring(hl_value2_3, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 4, 3, str.tostring(hl_value3_3, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 4, 4, str.tostring(hl_value4_3, "0"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 4, 5, str.tostring(hl_value5_3, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 4, 6, str.tostring(hl_value6_3, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 4, 7, str.tostring(hl_value7_3, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 4, 8, str.tostring(hl_value8_3, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 4, 9, str.tostring(hl_value9_3, "0"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 4, 10, str.tostring(hl_value10_3, "0"), bgcolor=color.black, text_color = color.white)

    table.cell(heatmap, 5, 1, str.tostring(acceptanceratio, "0.00"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 5, 2, str.tostring(acceptanceratio2, "0.00"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 5, 3, str.tostring(acceptanceratio3, "0.00"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 5, 4, str.tostring(acceptanceratio4, "0.00"), bgcolor=color.black, text_color = color.white)
    table.cell(heatmap, 5, 5, str.tostring(acceptanceratio5, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 5, 6, str.tostring(acceptanceratio6, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 5, 7, str.tostring(acceptanceratio7, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 5, 8, str.tostring(acceptanceratio8, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 5, 9, str.tostring(acceptanceratio9, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 5, 10, str.tostring(acceptanceratio10, "0.00"), bgcolor=color.black, text_color = color.white)

    //table.cell(heatmap, 7, 1, na(adf1) ? "NA" : str.tostring(adf1, "#.####") + " (" + f_result(adf1) + ")", bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 2, str.tostring(AVGSTD2, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 3, str.tostring(AVGSTD3, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 4, str.tostring(AVGSTD4, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 5, str.tostring(AVGSTD5, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 6, str.tostring(AVGSTD6, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 7, str.tostring(AVGSTD7, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 8, str.tostring(AVGSTD8, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 9, str.tostring(AVGSTD9, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 6, 10, str.tostring(AVGSTD10, "0.00"), bgcolor=color.black, text_color = color.white)


    // table.cell(heatmap, 3, 1, str.tostring(stdR, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 2, str.tostring(stdR2, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 3, str.tostring(stdR3, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 4, str.tostring(stdR4, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 5, str.tostring(stdR5, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 6, str.tostring(stdR6, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 7, str.tostring(stdR7, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 8, str.tostring(stdR8, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 9, str.tostring(stdR9, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 3, 10, str.tostring(stdR10, "0.00"), bgcolor=color.black, text_color = color.white) 

    // table.cell(heatmap, 7, 1, str.tostring(SCORE, "0.00"), bgcolor=color.black, text_color = color.white) 
    // table.cell(heatmap, 7, 2, str.tostring(SCORE2, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 3, str.tostring(SCORE3, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 4, str.tostring(SCORE4, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 5, str.tostring(SCORE5, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 6, str.tostring(SCORE6, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 7, str.tostring(SCORE7, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 8, str.tostring(SCORE8, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 9, str.tostring(SCORE9, "0.00"), bgcolor=color.black, text_color = color.white)
    // table.cell(heatmap, 7, 10, str.tostring(SCORE10, "0.00"), bgcolor=color.black, text_color = color.white)
````
