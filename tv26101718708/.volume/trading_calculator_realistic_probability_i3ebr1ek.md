# Trading Calculator - Realistic Probability

- url: https://www.tradingview.com/script/i3ebr1ek-Trading-Calculator-Realistic-Probability/
- type: indicator
- pine_id: PUB;2df24f618f7d4137a90dd652a0de84c0
- version: 1.0

## Description

Trading Calculator – Realistic Probability

Trading Calculator is a real-time probability engine designed to estimate whether price is statistically more likely to move upward or downward from the current market condition.

Unlike traditional oscillators that simply show overbought or oversold momentum, this indicator performs a historical pattern comparison using live RSI, Stochastic, and MFI momentum structures, then searches for similar market states in past data.

For every historical condition that closely resembles the current one, the script evaluates:

whether price reached an upside ATR-based target first, or
whether price reached a downside ATR-based target first,

within a defined number of future candles.

This creates a realistic probabilistic framework based on actual historical outcomes rather than simple momentum interpretation.

The result is displayed in a real-time calculator table directly on the chart showing:

• Bullish Probability
• Bearish Probability
• Current Market Bias
• Upside Price Target
• Downside Price Target
• Historical Similar Cases Count
• Neutral Cases Ignored

Core Methodology

The indicator continuously measures the current momentum signature by averaging:

RSI (Relative Strength Index)
Stochastic Oscillator
Money Flow Index

This creates a live momentum fingerprint of the current candle environment.

The script then scans hundreds of prior candles to detect moments where this momentum fingerprint was statistically similar.

For each matching case, the indicator performs a forward simulation:

Did price hit +ATR target before -ATR target?

This forward ATR target test allows the calculator to produce actionable directional probabilities instead of vague oscillator readings.

Why this is different

Most indicators only tell traders whether momentum is bullish or bearish.

Trading Calculator attempts to answer the more practical trading question:

“Given the current chart condition, what historically happened next most often?”

This transforms the chart into a probability decision tool rather than a simple visual indicator.

Main Features
Real-time bullish vs bearish probability calculation
Historical pattern recognition engine
ATR-based realistic target simulation
Dynamic market bias detection
Fully customizable table size and position
Works on any timeframe
Continuously updates with every candle movement
Best Use

Designed for:

directional intraday bias
scalping confirmation
swing entry filtering
avoiding low probability setups
adding statistical confirmation before trade execution

This is not a lagging signal indicator.

It is a live probabilistic trading calculator built to convert current market structure into historical odds.

## Source Code

````pine
//@version=5
indicator("Trading Calculator - Realistic Probability", overlay=true, max_bars_back=1000)

// Inputs
lookback     = input.int(500, "Historical Lookback", minval=100, maxval=1000)
horizon      = input.int(20, "Prediction Horizon - candles", minval=5, maxval=100)
atrLen       = input.int(14, "ATR Length")
targetATR    = input.float(1.0, "Target ATR Multiplier", step=0.25)
similarity   = input.float(6.0, "Similarity Sensitivity", step=0.5)
tfInput      = input.timeframe("", "Timeframe vide = graphique actuel")

tf = tfInput == "" ? timeframe.period : tfInput

// Data
srcClose = request.security(syminfo.tickerid, tf, close, lookahead=barmerge.lookahead_on)
srcHigh  = request.security(syminfo.tickerid, tf, high, lookahead=barmerge.lookahead_on)
srcLow   = request.security(syminfo.tickerid, tf, low, lookahead=barmerge.lookahead_on)

rsi = request.security(syminfo.tickerid, tf, ta.rsi(close, 14), lookahead=barmerge.lookahead_on)
sto = request.security(syminfo.tickerid, tf, ta.stoch(close, high, low, 14), lookahead=barmerge.lookahead_on)
mfi = request.security(syminfo.tickerid, tf, ta.mfi(close, 14), lookahead=barmerge.lookahead_on)
atr = request.security(syminfo.tickerid, tf, ta.atr(atrLen), lookahead=barmerge.lookahead_on)

// Current condition score
score = math.avg(rsi, sto, mfi)

// Current targets
upTarget   = srcClose + atr * targetATR
downTarget = srcClose - atr * targetATR

bullWins = 0
bearWins = 0
neutralCases = 0
matchedCases = 0

// Historical test:
// When past conditions looked similar to now,
// did price hit +ATR target first or -ATR target first?
for i = horizon + 1 to lookback
    pastScore = math.avg(rsi[i], sto[i], mfi[i])
    isSimilar = math.abs(score - pastScore) <= similarity

    if isSimilar
        matchedCases += 1

        pastEntry = srcClose[i]
        pastATR   = atr[i]

        pastUpTarget = pastEntry + pastATR * targetATR
        pastDownTarget = pastEntry - pastATR * targetATR

        int outcome = 0

        for j = i - 1 to i - horizon
            if outcome == 0
                hitUp = srcHigh[j] >= pastUpTarget
                hitDown = srcLow[j] <= pastDownTarget

                if hitUp and not hitDown
                    outcome := 1

                else if hitDown and not hitUp
                    outcome := -1

                else if hitUp and hitDown
                    outcome := 0

        if outcome == 1
            bullWins += 1
        else if outcome == -1
            bearWins += 1
        else
            neutralCases += 1

validCases = bullWins + bearWins

bullProb = validCases > 0 ? bullWins / validCases * 100 : na
bearProb = validCases > 0 ? bearWins / validCases * 100 : na

bias = bullProb > bearProb ? "HAUSSE" : bearProb > bullProb ? "BAISSE" : "NEUTRE"
biasColor = bullProb > bearProb ? color.lime : bearProb > bullProb ? color.red : color.gray

// Table
var table t = table.new(position.middle_right, 2, 9, bgcolor=color.black, border_width=1)

if barstate.islast
    table.cell(t, 0, 0, "TRADING", text_color=color.white, bgcolor=color.blue)
    table.cell(t, 1, 0, "CALCULATOR", text_color=color.white, bgcolor=color.blue)

    table.cell(t, 0, 1, "Probabilité hausse", text_color=color.white)
    table.cell(t, 1, 1, na(bullProb) ? "N/A" : str.tostring(math.round(bullProb, 1)) + "%", text_color=color.lime)

    table.cell(t, 0, 2, "Probabilité baisse", text_color=color.white)
    table.cell(t, 1, 2, na(bearProb) ? "N/A" : str.tostring(math.round(bearProb, 1)) + "%", text_color=color.red)

    table.cell(t, 0, 3, "Biais", text_color=color.white)
    table.cell(t, 1, 3, bias, text_color=color.white, bgcolor=biasColor)

    table.cell(t, 0, 4, "Target hausse", text_color=color.white)
    table.cell(t, 1, 4, str.tostring(math.round(upTarget, 2)), text_color=color.lime)

    table.cell(t, 0, 5, "Target baisse", text_color=color.white)
    table.cell(t, 1, 5, str.tostring(math.round(downTarget, 2)), text_color=color.red)

    table.cell(t, 0, 6, "Horizon", text_color=color.white)
    table.cell(t, 1, 6, str.tostring(horizon) + " bougies", text_color=color.yellow)

    table.cell(t, 0, 7, "Cas similaires", text_color=color.white)
    table.cell(t, 1, 7, str.tostring(matchedCases), text_color=color.white)

    table.cell(t, 0, 8, "Neutres ignorés", text_color=color.white)
    table.cell(t, 1, 8, str.tostring(neutralCases), text_color=color.gray)

// Plot targets
plot(upTarget, "Upside Target", color=color.lime)
plot(downTarget, "Downside Target", color=color.red)
````
