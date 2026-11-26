# ART + ORB Suggestions

- url: https://www.tradingview.com/script/2HhOaZlu-ART-ORB-Suggestions/
- type: indicator
- pine_id: PUB;7b901b1acd914a65af493c0ffaf5c56f
- version: 1.0

## Description

buy sell suggestions based on compression and expansion

## Source Code

````pine


//@version=6



indicator("ART + ORB Suggestions", shorttitle="ART_ORB", overlay=true, max_labels_count=200)



//--------------------------------------------------



// Inputs



//--------------------------------------------------



fastLen         = input.int(9, "Fast EMA", minval=1)



midLen          = input.int(21, "Mid EMA", minval=1)



slowLen         = input.int(50, "Slow EMA", minval=1)



rsiLen          = input.int(14, "RSI Length", minval=1)



atrLen          = input.int(14, "ATR Length", minval=1)



bbLen           = input.int(20, "BB Length", minval=1)



bbMult          = input.float(2.0, "BB Mult", minval=0.1)



volLen          = input.int(20, "Volume Z Length", minval=5)



persistLen      = input.int(20, "Persistence Lookback", minval=5)



orbMinutes      = input.int(30, "Opening Range Minutes", minval=5, step=5)



sessionInput    = input.session("0930-1600", "Session")



tensionThresh   = input.float(65.0, "Tension Threshold", minval=0, maxval=100)



bullBiasThresh  = input.float(15.0, "Bull Bias Threshold", minval=0, maxval=100)



bearBiasThresh  = input.float(-15.0, "Bear Bias Threshold", minval=-100, maxval=0)



useVolume       = input.bool(true, "Use Volume Filter")



showBG          = input.bool(true, "Show Background Regime")



showORB         = input.bool(true, "Show ORB Levels")



showLabels      = input.bool(true, "Show Buy/Sell Labels")



confirmClose    = input.bool(true, "Require Bar Close Beyond ORB")



//--------------------------------------------------



// Helpers



//--------------------------------------------------



clamp(x, lo, hi) =>



    math.max(lo, math.min(hi, x))



normalize_signed(x, scale) =>



    clamp(x / scale, -1.0, 1.0)



normalize_unsigned(x, scale) =>



    clamp(x / scale, 0.0, 1.0)



zscore(src, len) =>



    mean = ta.sma(src, len)



    std  = ta.stdev(src, len)



    std == 0.0 ? 0.0 : (src - mean) / std



percent_rank_simple(src, len) =>



    float count = 0.0



    for i = 0 to len - 1



        count += src >= src[i] ? 1.0 : 0.0



    count / len



//--------------------------------------------------



// Core calculations



//--------------------------------------------------



emaFast = ta.ema(close, fastLen)



emaMid  = ta.ema(close, midLen)



emaSlow = ta.ema(close, slowLen)



rsiVal  = ta.rsi(close, rsiLen)



atrVal  = ta.atr(atrLen)



volZ    = zscore(volume, volLen)



basis   = ta.sma(close, bbLen)



dev     = ta.stdev(close, bbLen) * bbMult



bbUpper = basis + dev



bbLower = basis - dev



bbWidth = basis != 0.0 ? (bbUpper - bbLower) / basis : 0.0



atrPct  = atrVal / close



fastSlope = emaFast - emaFast[1]



midSlope  = emaMid - emaMid[1]



slowSlope = emaSlow - emaSlow[1]



trendStackBull = emaFast > emaMid and emaMid > emaSlow



trendStackBear = emaFast < emaMid and emaMid < emaSlow



trendSlopeScore =



     0.40 * normalize_signed(fastSlope / close, 0.0020) +



     0.35 * normalize_signed(midSlope / close, 0.0015) +



     0.25 * normalize_signed(slowSlope / close, 0.0010)



trendStackScore =



     trendStackBull ? 1.0 :



     trendStackBear ? -1.0 : 0.0



biasRaw =



     0.55 * trendSlopeScore +



     0.25 * trendStackScore +



     0.20 * normalize_signed(rsiVal - 50.0, 20.0)



biasScore = 100.0 * clamp(biasRaw, -1.0, 1.0)



// Compression / expansion



bbRank          = percent_rank_simple(bbWidth, 100)



atrRank         = percent_rank_simple(atrPct, 100)



compression     = 1.0 - (0.6 * bbRank + 0.4 * atrRank)



atrROC          = ta.roc(atrVal, 5)



expansionImpulse = normalize_unsigned(math.max(atrROC, 0), 20)



// Coupling approximation



ret1   = ta.roc(close, 1)



ret3   = ta.roc(close, 3)



rsiChg = ta.change(rsiVal)



emaGap = (emaFast - emaSlow) / close



corr1 = math.abs(ta.correlation(ret1, rsiChg, 30))



corr2 = math.abs(ta.correlation(ret3, emaGap, 30))



corr3 = math.abs(ta.correlation(ret1, atrPct, 30))



coupling = clamp((corr1 + corr2 + corr3) / 3.0, 0.0, 1.0)



// Persistence



stateSign = biasScore > 10 ? 1 : biasScore < -10 ? -1 : 0



float sameStateCount = 0.0



for i = 0 to persistLen - 1



    pastSign = biasScore[i] > 10 ? 1 : biasScore[i] < -10 ? -1 : 0



    sameStateCount += (pastSign == stateSign and stateSign != 0) ? 1.0 : 0.0



persistence = stateSign == 0 ? 0.0 : sameStateCount / persistLen



volumeScore = useVolume ? normalize_unsigned(math.max(volZ, 0), 2.5) : 0.0



tensionRaw =



     0.30 * compression +



     0.25 * coupling +



     0.20 * persistence +



     0.15 * expansionImpulse +



     0.10 * volumeScore



tensionScore = 100.0 * clamp(tensionRaw, 0.0, 1.0)



//--------------------------------------------------



// Opening Range



//--------------------------------------------------



inSession = not na(time(timeframe.period, sessionInput))



newSession = inSession and not inSession[1]



var float orbHigh = na



var float orbLow  = na



var int sessionStartTime = na



if newSession



    orbHigh := high



    orbLow := low



    sessionStartTime := time



orbActive = inSession and not na(sessionStartTime) and time < sessionStartTime + orbMinutes * 60 * 1000



orbDefined = inSession and not na(sessionStartTime) and time >= sessionStartTime + orbMinutes * 60 * 1000



if orbActive



    orbHigh := math.max(orbHigh, high)



    orbLow := math.min(orbLow, low)



//--------------------------------------------------



// Suggestion logic



//--------------------------------------------------



bullBreak = orbDefined and not na(orbHigh) and (confirmClose ? close > orbHigh : high > orbHigh)



bearBreak = orbDefined and not na(orbLow) and (confirmClose ? close < orbLow : low < orbLow)



buySuggestion = bullBreak and tensionScore >= tensionThresh and biasScore >= bullBiasThresh and emaFast > emaMid



sellSuggestion = bearBreak and tensionScore >= tensionThresh and biasScore <= bearBiasThresh and emaFast < emaMid



// Only fire on first qualifying bar



buyTrigger  = buySuggestion and not buySuggestion[1]



sellTrigger = sellSuggestion and not sellSuggestion[1]



//--------------------------------------------------



// Optional exit-style suggestion markers



//--------------------------------------------------



exitLongSuggestion  = biasScore < 0 or close < emaFast



exitShortSuggestion = biasScore > 0 or close > emaFast



//--------------------------------------------------



// Visuals



//--------------------------------------------------



plot(showORB ? orbHigh : na, "ORB High", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)



plot(showORB ? orbLow : na, "ORB Low", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)



plotshape(showLabels and buyTrigger, title="Buy Suggestion", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), text="BUY", textcolor=color.white, size=size.small)



plotshape(showLabels and sellTrigger, title="Sell Suggestion", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)



plotshape(showLabels and buySuggestion and exitLongSuggestion, title="Long Caution", style=shape.circle, location=location.abovebar, color=color.new(color.yellow, 0), size=size.tiny)



plotshape(showLabels and sellSuggestion and exitShortSuggestion, title="Short Caution", style=shape.circle, location=location.belowbar, color=color.new(color.yellow, 0), size=size.tiny)



// Background regime shading



bgBull = tensionScore >= tensionThresh and biasScore >= bullBiasThresh



bgBear = tensionScore >= tensionThresh and biasScore <= bearBiasThresh



bgcolor(showBG ? bgBull ? color.new(color.green, 88) : bgBear ? color.new(color.red, 88) : na : na)



// Alert conditions



alertcondition(buyTrigger, "BUY Suggestion", "ART + ORB BUY suggestion")



alertcondition(sellTrigger, "SELL Suggestion", "ART + ORB SELL suggestion")



// Hidden plots for data window



plot(tensionScore, "Tension Score", color=color.orange, display=display.data_window)



plot(biasScore, "Bias Score", color=color.blue, display=display.data_window)
````
