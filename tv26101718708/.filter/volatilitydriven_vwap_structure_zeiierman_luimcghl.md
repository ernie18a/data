# Volatility-Driven VWAP Structure (Zeiierman)

- url: https://www.tradingview.com/script/LUiMCGHl-Volatility-Driven-VWAP-Structure-Zeiierman/
- type: indicator
- pine_id: PUB;95978394b48141ce9b6e790f4cb5ef80
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Volatility-Driven VWAP Structure (Zeiierman)[/b] is a VWAP-based market structure tool that adapts its regime logic using volatility, Z-score normalization, and reversal-anchored VWAP profiles.

The script builds a rolling VWAP structure and adjusts its transition distance using an adaptive volatility engine. The result is a dynamic structure line that shifts only when VWAP displacement is strong enough relative to current volatility conditions.

When a structure reversal occurs, the script resets an anchored VWAP profile from that point and builds deviation bands around it, allowing traders to track the active post-reversal value area.
[image]https://www.tradingview.com/x/o8PYXehH/[/image]
█ [b]How It Works[/b]

⚪ [b]Rolling VWAP Base[/b]
The script first calculates a rolling VWAP using price multiplied by volume over the selected lookback period.
[pine]float rollingVwap = math.sum(src * volume, vwapLengthInput) / math.sum(volume, vwapLengthInput)[/pine]
This creates a volume-weighted fair value line that updates continuously without relying on fixed session, daily, weekly, or monthly anchors.

⚪ [b]Adaptive Volatility Engine[/b]
The structure step is not fixed. It is based on ATR, a slow ATR comparison, and a Z-score volatility reading.
[pine]float atrZ = atrDev != 0 ? (atrFast - atrMean) / atrDev : 0.0
float volRatio = atrSlow != 0 ? atrFast / atrSlow : 1.0[/pine]
This allows the script to identify whether volatility is currently expanding or contracting compared to its recent behavior.

⚪ [b]Sigmoid Volatility Mapping[/b]
The volatility ratio and Z-score are blended into a sigmoid function.
[pine]float sigmoidInput = 4.0 * (volRatio - 1.0) + 0.75 * atrZClamped
float sigmoid = 1.0 / (1.0 + math.exp(-sigmoidInput))[/pine]
The sigmoid smooths extreme volatility changes, converting them into a controlled, adaptive multiplier.

This helps prevent the structure from becoming too sensitive during noise while still expanding during stronger volatility regimes.

⚪ [b]VWAP Structure Engine[/b]
The rolling VWAP is compared against adaptive upper and lower structure levels.

When VWAP expands far enough beyond the current structure range, the script shifts the structure higher or lower.
[pine]float upsideExpansion   = rollingVwap - (structureUpper + structureStep)
float downsideExpansion = (structureLower - structureStep) - rollingVwap[/pine]
If the expansion is strong enough, a new structure direction is assigned:
[pine]int nextDirection = expandsHigher ? 1 : expandsLower ? -1 : direction[/pine]
This creates bullish and bearish VWAP structure regimes based on volume-weighted displacement, not just candle closes.

⚪ [b]Structure Mean[/b]
The main plotted line is the midpoint of the active VWAP structure range.
[pine]float structureMid = (structureUpper + structureLower) / 2.0[/pine]
[b]This line acts as the active structure mean:[/b]
[list]
[*]When the regime is bullish, it uses the bullish color.
[*]When the regime is bearish, it uses the bearish color.
[/list]
⚪ [b]Reversal-Anchored VWAP Profile[/b]
Every time the VWAP structure reverses, a new anchored VWAP profile begins.
[pine]bool anchorReset = isReversed or na(anchorSumPV)[/pine]
[b]From that reversal point, the script accumulates:[/b]
[list]
[*]price × volume
[*]volume
[*]price² × volume
[/list]
These values are used to calculate the active anchored VWAP and its weighted deviation.
[pine]float anchoredVwap = anchorSumV != 0 ? anchorSumPV / anchorSumV : na
float anchoredDev  = not na(anchoredVar) ? math.sqrt(math.max(anchoredVar, 0)) : na[/pine]
This creates a fresh value profile after every structural shift.

⚪ [b]Anchored Deviation Bands[/b]
The script plots one or two deviation bands around the reversal-anchored VWAP.
[pine]float anchorUpper1 = anchoredVwap + anchoredDev * bandMult1
float anchorLower1 = anchoredVwap - anchoredDev * bandMult1[/pine]
These bands help visualize the active post-reversal value area and potential stretched-price zones.

█ [b]How to Use[/b]

⚪ [b]Read the Structure Mean[/b]
[list]
[*][b]Bullish color →[/b] VWAP structure is in an upward regime
[*][b]Bearish color →[/b] VWAP structure is in a downward regime
[/list]
[image]https://www.tradingview.com/x/G35JxIF2/[/image]
The structure mean can be used as a dynamic guide for trend bias, continuation, regime changes, and identifying good areas to look for retests on the mean.
[image]https://www.tradingview.com/x/WC84A4bw/[/image]
⚪ [b]Watch for Structure Reversals[/b]
A reversal occurs when the adaptive VWAP structure changes direction.

These reversals reset the anchored VWAP profile, marking the start of a new active value phase.
[image]https://www.tradingview.com/x/yL8C0Csm/[/image]

⚪ [b]Use the Anchored VWAP[/b]
After a reversal, the anchored VWAP shows the volume-weighted average price from that new structure point.
[list]
[*][b]Price above anchored VWAP →[/b] stronger bullish control
[*][b]Price below anchored VWAP →[/b] stronger bearish control
[/list]
[image]https://www.tradingview.com/x/07sMa8xX/[/image]

⚪ [b]Use the Deviation Bands[/b]
The deviation bands show how far the price has moved from the active anchored VWAP.
[list]
[*][b]Band 1 →[/b] normal value expansion
[*][b]Band 2 →[/b] stronger price extension
[/list]
Touches of the outer bands can be used to identify extended conditions, reaction zones, or continuation pressure.
[image]https://www.tradingview.com/x/mOUvEJaR/[/image]
█ [b]Settings[/b]
[list]
[*][b]Rolling VWAP Length:[/b] Controls the lookback period for the rolling VWAP calculation.
[*][b]Structure Multiplier:[/b] Controls how wide the adaptive structure transitions are.
[*][b]Volatility Length:[/b] Controls the ATR length used in the volatility engine.
[*][b]Band 1 Multiplier:[/b] Controls the first anchored VWAP deviation band.
[*][b]Band 2 Multiplier:[/b] Controls the second anchored VWAP deviation band.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Volatility-Driven VWAP Structure (Zeiierman)", overlay = true)
//}

// ~~ Tooltips {
t1 = "Number of bars used to calculate the rolling VWAP. Higher values create a slower, smoother VWAP structure. Lower values react faster."
t2 = "Multiplier applied to the adaptive volatility step. Higher values create wider structure transitions. Lower values create more frequent structure shifts."
t3 = "Color used when the VWAP structure is in a bullish regime."
t4 = "Color used when the VWAP structure is in a bearish regime."
t5 = "ATR length used as the base volatility input for the adaptive VWAP structure."
t6 = "Shows or hides the first deviation band around the reversal-anchored VWAP."
t7 = "Shows or hides the second deviation band around the reversal-anchored VWAP."
t8 = "Multiplier for the first anchored VWAP deviation band."
t9 = "Multiplier for the second anchored VWAP deviation band."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Settings {
vwapLengthInput      = input.int(200, "Rolling VWAP Length", minval = 1, group = "VWAP Structure Settings", tooltip = t1)
structureMultInput  = input.float(1.5, "Structure Multiplier", minval = 0.1, step = 0.1, group = "VWAP Structure Settings", tooltip = t2)

atr_ = input.int(14, "Volatility Length", minval = 1, group = "Volatility Engine", tooltip = t5)

showBand1 = input.bool(true, "Show Band 1", group = "Reversal Anchored VWAP", tooltip = t6)
showBand2 = input.bool(true, "Show Band 2", group = "Reversal Anchored VWAP", tooltip = t7)
bandMult1 = input.float(1.0, "Band 1 Multiplier", step = 0.1, group = "Reversal Anchored VWAP", tooltip = t8)
bandMult2 = input.float(2.0, "Band 2 Multiplier", step = 0.1, group = "Reversal Anchored VWAP", tooltip = t9)

bullColorInput = input.color(#00e676, "Bullish Color", group = "Visuals", tooltip = t3)
bearColorInput = input.color(#f23645, "Bearish Color", group = "Visuals", tooltip = t4)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Rolling VWAP {
float src = hlc3
float rollingVwap = math.sum(src * volume, vwapLengthInput) / math.sum(volume, vwapLengthInput)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Sigmoid + Z-score volatility step {
float atrFast = ta.atr(atr_)
float atrSlow = ta.atr(atr_ * 4)

float atrMean = ta.sma(atrFast, vwapLengthInput * 4)
float atrDev  = ta.stdev(atrFast, vwapLengthInput * 4)
float atrZ    = atrDev != 0 ? (atrFast - atrMean) / atrDev : 0.0

float atrZClamped = math.max(math.min(atrZ, 3.0), -3.0)
float volRatio    = atrSlow != 0 ? atrFast / atrSlow : 1.0

float sigmoidInput = 4.0 * (volRatio - 1.0) + 0.75 * atrZClamped
float sigmoid = 1.0 / (1.0 + math.exp(-sigmoidInput))
float adaptiveVolMult = 0.5 + sigmoid * 1.5

float structureStep = atrFast * structureMultInput * adaptiveVolMult
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ VWAP Structure Engine {
var float structureUpper = na
var float structureLower = na
var int   direction      = 0

bool structureReady = not na(rollingVwap) and not na(structureStep) and structureStep > 0

if structureReady
    if na(structureUpper)
        structureUpper := rollingVwap
        structureLower := rollingVwap - structureStep
        direction      := 1
    else
        float upsideExpansion   = rollingVwap - (structureUpper + structureStep)
        float downsideExpansion = (structureLower - structureStep) - rollingVwap

        bool expandsHigher = upsideExpansion > 0
        bool expandsLower  = downsideExpansion > 0

        int nextDirection = expandsHigher ? 1 : expandsLower ? -1 : direction

        if expandsHigher or expandsLower
            float referenceLevel = nextDirection == 1 ? structureUpper : structureLower
            float travelDistance = math.abs(rollingVwap - referenceLevel)
            int transitionSteps  = math.floor(travelDistance / structureStep)

            if nextDirection == 1
                structureLower := structureUpper + (transitionSteps - 1) * structureStep
                structureUpper := structureUpper + transitionSteps * structureStep
            else
                structureUpper := structureLower - (transitionSteps - 1) * structureStep
                structureLower := structureLower - transitionSteps * structureStep

            direction := nextDirection
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Structure Visuals {
bool isChanged  = structureUpper != structureUpper[1] or structureLower != structureLower[1]
bool isReversed = ta.change(direction) != 0
float structureMid = (structureUpper + structureLower) / 2.0

color plotColor = direction == 1 ? bullColorInput : bearColorInput

plot(structureMid, "VWAP Structure Mean", color = plotColor, style = plot.style_line, linestyle = plot.linestyle_dotted, linewidth = 3)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Reversal Anchored VWAP Profile {
var float anchorSumPV  = na
var float anchorSumV   = na
var float anchorSumP2V = na

bool anchorReset = isReversed or na(anchorSumPV)

if anchorReset
    anchorSumPV  := src * volume
    anchorSumV   := volume
    anchorSumP2V := src * src * volume
else
    anchorSumPV  += src * volume
    anchorSumV   += volume
    anchorSumP2V += src * src * volume

float anchoredVwap = anchorSumV != 0 ? anchorSumPV / anchorSumV : na
float anchoredVar  = anchorSumV != 0 ? anchorSumP2V / anchorSumV - math.pow(anchoredVwap, 2) : na
float anchoredDev  = not na(anchoredVar) ? math.sqrt(math.max(anchoredVar, 0)) : na

float anchorUpper1 = anchoredVwap + anchoredDev * bandMult1
float anchorLower1 = anchoredVwap - anchoredDev * bandMult1
float anchorUpper2 = anchoredVwap + anchoredDev * bandMult2
float anchorLower2 = anchoredVwap - anchoredDev * bandMult2

color anchorColor = direction == 1 ? bullColorInput : bearColorInput
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Anchored VWAP Visuals {
plot(anchoredVwap, "Reversal Anchored VWAP", color = color.new(anchorColor, 0), linewidth = 2)

aU1 = plot(showBand1 ? anchorUpper1 : na, "Anchored VWAP Upper 1", color = color.new(anchorColor, 30))
aL1 = plot(showBand1 ? anchorLower1 : na, "Anchored VWAP Lower 1", color = color.new(anchorColor, 30))
fill(aU1, aL1, color.new(anchorColor, 92), "Anchored VWAP Band 1")

aU2 = plot(showBand2 ? anchorUpper2 : na, "Anchored VWAP Upper 2", color = color.new(anchorColor, 55))
aL2 = plot(showBand2 ? anchorLower2 : na, "Anchored VWAP Lower 2", color = color.new(anchorColor, 55))
fill(aU2, aL2, color.new(anchorColor, 95), "Anchored VWAP Band 2")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
bool bullishShift = isReversed and direction == 1
bool bearishShift = isReversed and direction == -1

bool priceCrossesAnchoredVwapUp   = ta.crossover(close, anchoredVwap)
bool priceCrossesAnchoredVwapDown = ta.crossunder(close, anchoredVwap)

bool priceCrossesStructureMeanUp   = ta.crossover(close, structureMid)
bool priceCrossesStructureMeanDown = ta.crossunder(close, structureMid)

bool priceTouchesUpperBand1 = high >= anchorUpper1
bool priceTouchesLowerBand1 = low <= anchorLower1

bool priceTouchesUpperBand2 = high >= anchorUpper2
bool priceTouchesLowerBand2 = low <= anchorLower2

alertcondition(bullishShift, "Bullish VWAP Structure Shift", "Volatility-Driven VWAP Structure shifted bullish.")
alertcondition(bearishShift, "Bearish VWAP Structure Shift", "Volatility-Driven VWAP Structure shifted bearish.")

alertcondition(isReversed, "Any VWAP Structure Reversal", "VWAP structure reversal detected.")

alertcondition(priceCrossesAnchoredVwapUp, "Close Crossed Above Anchored VWAP", "Price crossed above the reversal-anchored VWAP.")
alertcondition(priceCrossesAnchoredVwapDown, "Close Crossed Below Anchored VWAP", "Price crossed below the reversal-anchored VWAP.")

alertcondition(priceCrossesStructureMeanUp, "Close Crossed Above VWAP Structure Mean", "Price crossed above the VWAP structure mean.")
alertcondition(priceCrossesStructureMeanDown, "Close Crossed Below VWAP Structure Mean", "Price crossed below the VWAP structure mean.")

alertcondition(priceTouchesUpperBand1, "Price Touched Upper Band 1", "Price touched the first upper anchored VWAP deviation band.")
alertcondition(priceTouchesLowerBand1, "Price Touched Lower Band 1", "Price touched the first lower anchored VWAP deviation band.")

alertcondition(priceTouchesUpperBand2, "Price Touched Upper Band 2", "Price touched the second upper anchored VWAP deviation band.")
alertcondition(priceTouchesLowerBand2, "Price Touched Lower Band 2", "Price touched the second lower anchored VWAP deviation band.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
