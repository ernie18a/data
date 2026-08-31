<!-- tradingview-pine-id: PUB;LlfWVG7VZFoyKNEaq6GsE0D2XoueWvaI -->
<!-- tradingviewscripts-format: 1 -->
# Zahorchak Measure

Source: https://www.tradingview.com/script/6aLn4Qkl-Zahorchak-Measure/

## Description

Creator: Michael G. Zahorchak.

References:

[*] The Art of Low Risk Investing by Michael G. Zahorchak, 1977. Unfortunately, it's all but impossible to find a copy these days.
[*] The Complete Guide to Market Breadth Indicators by Gregory L. Morris, 2006. A fantastic resource for those interested in Technical Analysis or creating their own trend based system.
[*] Two articles by Greg Morris on the Zahorchak Measure. I can't link to them under the House Rules, but they are easily searchable.

The Zahorchak Measure (ZM) is designed to give you a market bias (either uptrend or downtrend) which you can use to determine a trade bias for ETF's or stocks.

ZM works by taking multiple moving averages of the NYSE Composite, a moving average of the NYSE advance decline line, and examining the relationship between those elements. Broadly, the market is considered to be in a uptrend when ZM is above zero, and a downtrend when below. However, there are many ways to interpret the indicator.

The version created by Greg Morris is more akin to a binary indicator in that ZM jumps from number to number. This version is smoothed to create an oscillator as it reduces whipsaws (at the expense of lag). You can set the EMA Length to 1 to go back to the original.

Some notes:

[*] Michael Zahorchak called it the "Zahorchak Method", whereas Greg Morris uses the term "Measure". I'm not totally clear on the change, but Mr. Morris made some changes (covered below), so that may explain the altered name.
[*] The original indicator used moving averages of 5, 15, and 40 weeks. I have converted these to daily numbers as that's the time frame I most commonly trade. You can convert the numbers back by dividing by 5.
[*] The original indicator used the Dow Industrials for the moving averages, however Greg Morris switched to the NYSE Composite due to the advance decline line being based on the NYSE.
[*] Greg Morris removed the 5 period moving average of the NYSE Composite, as it created increased volatility at market tops and bottoms. I tested ZM with the 5 period MA added back in, and I believe removing it creates a superior indicator.
[*] I've added both Multi Time Frame functionality, and the ability to alter moving average lengths. Play around and see what you can come up with.
[*] ZM oscillates between -10 and +10. There are some interesting levels creating between these two numbers (apart from the obvious zero level) - see what you can come up with.

All credit goes to Michael Zahorchak and Greg Morris for the indicator creation. I have simply reproduced their work for the TradingView community as this great indicator wasn't available.

Any queries let me know in the comments or PM me.

DD.

---

## Source Code

````pine
//@version=4
study("Zahorchak Measure", overlay=false)

// ==================================================================================================================================================================
// Scoring Inputs
Points = input(1.0, title="Point Value", type=input.float, step=0.1) // Change the value of the points assigned to signals.

length = input(10, "EMA Length for Smoothing") // Change the value of the moving average length.

CurrentRes = input(true, title="Use Current Chart Resolution?") // Use the current chart resolution if selected.
CustomRes  = input("240", title="Custom Timeframe? Uncheck Box Above (E.g. 1M, 5D, 240 = 4Hours)") // Determines the resolution used if the above setting is not selected.

res = CurrentRes ? timeframe.period : CustomRes

Weight1 = input(1.0, title="NASDAQ Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the NASDAQ Index
Weight2 = input(1.0, title="S&P 500 Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the S&P 500 Index
Weight3 = input(1.0, title="S&P 100 Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the S&P 100 Index
Weight4 = input(1.0, title="Russell 2000 Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the Russell 2000 Index
Weight5 = input(1.0, title="Russell 2000 Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the Russell 2000 Index
Weight6 = input(1.0, title="Russell 2000 Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the Russell 2000 Index
Weight7 = input(1.0, title="Russell 2000 Importance Weight", type=input.float, step=0.1) // Determines the weighting assigned to the Russell 2000 Index

sym1 = input(title="NYSE Composite", type=input.symbol, defval="TVC:NYA") // Sets the Index used for Symbol 1

// ==================================================================================================================================================================+
// Setting up Indexes for Calcs
sym1_ = security(sym1, res, close)

// ==================================================================================================================================================================+
// NYSE AD Line
sym(s) => security(s, timeframe.period, close)

difference = (sym("USI:ADVN.NY") - sym("USI:DECL.NY"))/(sym("USI:UNCH.NY") + 1)

adline = cum(difference > 0 ? sqrt(difference) : -sqrt(-difference))

sma_ad = sma(adline, 75)

// ==================================================================================================================================================================+
// NYSE MA's

short = sma(sym1_, 25)
medium = sma(sym1_, 75)
long = sma(sym1_, 200)

// ==================================================================================================================================================================
// ---------- Scoring script ---------- //
// == Helpers ==
resolve(src, default) => na(src) ? default : src

calc_1(previousVal) =>

    positive = sym1_ > short
    negative = sym1_ < short
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score
    
calc_2(previousVal) =>

    positive = sym1_ > medium
    negative = sym1_ < medium
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score
    
calc_3(previousVal) =>

    positive = sym1_ > long
    negative = sym1_ < long
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score

calc_4(previousVal) =>

    positive = short > medium
    negative = short < medium
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score

calc_5(previousVal) =>

    positive = medium > long
    negative = medium < long
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score

calc_6(previousVal) =>

    positive = short > long
    negative = short < long
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score

calc_7(previousVal) =>

    positive = adline > sma_ad
    negative = adline < sma_ad
    
    score = resolve(previousVal, 0)
    score := (positive) ? Points : score
    score := (negative) ? -Points : score

// == plot score ==
calc1_Score() =>
    calc1_S = 0.0
    calc1_S := calc_1(calc1_S[1])

calc2_Score() =>
    calc2_S = 0.0
    calc2_S := calc_2(calc2_S[1])

calc3_Score() =>
    calc3_S = 0.0
    calc3_S := calc_3(calc3_S[1])

calc4_Score() =>
    calc4_S = 0.0
    calc4_S := calc_4(calc4_S[1])

calc5_Score() =>
    calc5_S = 0.0
    calc5_S := calc_5(calc5_S[1])

calc6_Score() =>
    calc6_S = 0.0
    calc6_S := calc_6(calc6_S[1])

calc7_Score() =>
    calc7_S = 0.0
    calc7_S := calc_7(calc7_S[1])

totalScore() =>
    tS = (Weight1 * calc1_Score())
    tS := tS + (Weight2 * calc2_Score())
    tS := tS + (Weight3 * calc3_Score())
    tS := tS + (Weight4 * calc4_Score())
    tS := tS + (Weight5 * calc5_Score())
    tS := tS + (Weight6 * calc6_Score())
    tS := tS + (Weight7 * calc7_Score())

maxScore = Points * (Weight1 + Weight2 + Weight3 + Weight4 + Weight5 + Weight6 + Weight7)
normalizedScore = security(syminfo.tickerid, res, 10 * totalScore() / maxScore)

normalizedScore_smooth = ema(normalizedScore, length)

// ==================================================================================================================================================================+
// Plots
base = hline(0, linewidth=2, title="Base")
plot(normalizedScore_smooth, color=color.blue, linewidth=2, title="Zahorchak Measure")
````
