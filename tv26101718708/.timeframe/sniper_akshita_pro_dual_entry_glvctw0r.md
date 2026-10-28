# Sniper Akshita Pro - Dual Entry

- url: https://www.tradingview.com/script/glVCtW0R-Sniper-Akshita-Pro-Dual-Entry/
- type: indicator
- pine_id: PUB;23b65de24c2e4a6dac8248397a68942b
- version: 1.0

## Description

Sniper Akshita Pro – Dual Entry
Sniper Akshita Pro is a multi-timeframe intraday confirmation indicator designed to identify liquidity traps around a predefined opening range and then wait for structure, displacement, delta pressure and Fair Value Gap confirmation before presenting an entry opportunity.
The main objective of the script is not to predict every breakout. Instead, it attempts to filter low-quality breakout signals and focus on situations where liquidity has been taken from both sides of an important range before a directional move develops.
Core Concept
The indicator first defines the opening one-hour range from 03:30 to 04:30 Asia/Kolkata time. After this range is completed, the system watches the 5-minute structure for liquidity sweeps above and below the range.
A wick above the range high followed by a close back below the range is considered a potential high-side liquidity sweep. A wick below the range low followed by a close back above the range is considered a potential low-side liquidity sweep.    Pasted markdown
The script is particularly interested in a two-sided liquidity event. For example, if the market first sweeps the range high and later sweeps the range low, the system begins looking for a potential bullish reversal. The opposite sequence prepares the system for a potential bearish reversal.
A sweep by itself is not treated as an entry.
After the liquidity event, the indicator requires confirmation from displacement, market structure and delta pressure.
Displacement is measured using ATR and candle body percentage. By default, the candle body must be at least 0.60 × ATR and approximately 60% of the candle range. This helps avoid treating weak candles as genuine displacement.    Pasted markdown
Market structure confirmation is based on an MSS-style break of recent highs or lows. The default structure lookback is five bars. A bullish setup requires price to close above the recent structure high, while a bearish setup requires price to close below the recent structure low.    Pasted markdown
Delta Confirmation
The script also uses an estimated buying/selling-pressure delta. It evaluates where price closes inside the candle range and combines that information with volume. Positive strong delta supports bullish confirmation, while negative strong delta supports bearish confirmation.    Pasted markdown
Important: this is not exchange-level bid/ask order-flow delta. It is an estimated pressure model derived from candle structure and available volume. It should therefore be used as a confirmation filter rather than interpreted as true footprint delta.
Primary Fair Value Gap
One of the main features of this indicator is Primary FVG selection.
During a displacement leg, several Fair Value Gaps can sometimes form. Entering from the first or nearest FVG can result in an unnecessarily large stop-out if price makes a deeper retracement before continuing.
Sniper Akshita Pro therefore scans multiple FVGs after confirmation and attempts to select a more meaningful Primary FVG.
In a bullish setup, when multiple valid FVGs occur, the script gives preference to the deeper/lower FVG. In a bearish setup, it gives preference to the higher FVG. The FVG must also satisfy a minimum ATR-based size requirement.    Pasted markdown
This Primary FVG becomes the main retracement zone used for entry confirmation.
Dual Entry Concept
The indicator is designed around two possible execution styles:
- 1M Entry: an earlier, more aggressive entry after the confirmed 5-minute setup when the Primary FVG is retested and 1-minute rejection/delta confirms.
- 5M Entry: a slower, more conservative confirmation based on the 5-minute Primary FVG retest, candle direction and delta confirmation.
This allows traders to compare whether they prefer earlier entries with tighter risk or slower entries with stronger confirmation.
Default Settings
Opening Range: 03:30–04:30 Asia/Kolkata
Setup Timeframe: 5 minutes
ATR Length: 14
Displacement Threshold: 0.60 ATR
Minimum Candle Body: 60%
MSS Lookback: 5 bars
Confirmation Window: 12 bars after the second sweep
Primary FVG Scan: 3 bars
Minimum FVG Size: 0.05 ATR
5M Delta Average: 20
5M Delta Strength: 1.00
1M Delta Average: 20
1M Delta Strength: 0.80
These parameters are adjustable and should be optimized carefully for the instrument being traded rather than assumed to work equally well on every market.    Pasted markdown
Suggested Markets
The concept was primarily developed for intraday testing on instruments such as XAUUSD and crude oil/CL-type markets, where liquidity sweeps and displacement around important session ranges can be relevant.
However, users should independently forward-test and backtest the script before applying it to any instrument.
How I Use It
The intended sequence is:
Opening Range → Liquidity Sweep / Fakeout → Opposite-Side Liquidity Event → Displacement → MSS → Strong Delta → Primary FVG → Retest → 1M or 5M Confirmation.
A signal should therefore be interpreted as the result of several filters aligning rather than as a standalone buy/sell recommendation.
Important Limitations
This indicator does not guarantee that a liquidity sweep will reverse the market. Strong trends can continue through liquidity levels without reversing.
Delta is estimated and is not true exchange bid/ask delta.
Higher-timeframe 5-minute conditions may change while the active 5-minute candle is still forming. For disciplined use, traders may choose to wait for the relevant 5-minute candle to close before acting on higher-timeframe confirmation.
No indicator can eliminate false breakouts, slippage, volatility, news risk or execution risk.
This script should be considered a research and confirmation tool, not a complete trading system.
Feedback Welcome
This is an actively developing project. I am specifically interested in feedback regarding Primary FVG selection, double-sweep detection, 1-minute versus 5-minute entries, delta thresholds, false-signal filtering, and performance across different instruments and market conditions.
If you test the indicator, constructive feedback and examples of both successful and failed setups are welcome.
Disclaimer
For educational and research purposes only. This indicator does not constitute financial advice or a recommendation to buy or sell any financial instrument. Always use independent analysis and appropriate risk management.

For the short description/title area, I’d use:
“Liquidity Sweep + 5M Displacement/MSS + Delta + Primary FVG with 1M & 5M Dual Entry Confirmation.”

## Source Code

````pine
//@version=6
indicator("Sniper Akshita Pro - Dual Entry", overlay=true,
     max_boxes_count=20, max_lines_count=100, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupRange = "01. Opening Range"
rangeSession = input.session("0330-0430", "Opening 1H Range", group=groupRange)
sessionTZ    = input.string("Asia/Kolkata", "Timezone", group=groupRange)

groupSetup = "02. 5M Setup"
atrLen      = input.int(14, "ATR Length", group=groupSetup)
dispATR     = input.float(0.60, "Displacement Body ATR", step=0.05, group=groupSetup)
bodyPctMin  = input.float(0.60, "Minimum Body %", step=0.05, group=groupSetup)
mssLookback = input.int(5, "MSS Lookback", minval=2, group=groupSetup)
confirmBars = input.int(12, "Bars After 2nd Sweep", minval=1, group=groupSetup)

groupFVG = "03. Primary FVG"
fvgScanBars = input.int(3, "FVG Scan Bars", minval=1, maxval=8, group=groupFVG)
minFvgATR   = input.float(0.05, "Minimum FVG ATR", step=0.01, group=groupFVG)

groupDelta = "04. Delta"
deltaLen5  = input.int(20, "5M Delta Average", group=groupDelta)
deltaMult5 = input.float(1.00, "5M Delta Strength", step=0.10, group=groupDelta)
deltaLen1  = input.int(20, "1M Delta Average", group=groupDelta)
deltaMult1 = input.float(0.80, "1M Delta Strength", step=0.10, group=groupDelta)

groupVisual = "05. Display"
showRange    = input.bool(true, "Opening Range", group=groupVisual)
showSweeps   = input.bool(true, "Fakeout", group=groupVisual)
showBreakout = input.bool(true, "Breakout", group=groupVisual)
showFVG      = input.bool(true, "Primary FVG", group=groupVisual)
show1M       = input.bool(true, "1M Entry", group=groupVisual)
show5M       = input.bool(true, "5M Entry", group=groupVisual)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5 MINUTE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

f_engine5m() =>
    atr = ta.atr(atrLen)

    candleRange = math.max(high - low, syminfo.mintick)
    body = math.abs(close - open)
    bodyPct = body / candleRange

    pressure = ((close - low) - (high - close)) / candleRange
    delta = volume * pressure
    deltaAvg = ta.sma(math.abs(delta), deltaLen5)

    bullDelta = delta > 0 and math.abs(delta) >= deltaAvg * deltaMult5
    bearDelta = delta < 0 and math.abs(delta) >= deltaAvg * deltaMult5

    inRange = not na(time(timeframe.period, rangeSession, sessionTZ))
    startRange = inRange and not inRange[1]

    var float rHigh = na
    var float rLow = na

    var bool highSwept = false
    var bool lowSwept = false

    var int candidateDir = 0
    var int secondSweepBar = na

    var int direction = 0
    var int confirmationBar = na
    var int setupID = 0

    var float candidateTop = na
    var float candidateBottom = na
    var float candidateMid = na

    var float primaryTop = na
    var float primaryBottom = na
    var bool primaryReady = false

    var bool used5 = false

    if startRange
        rHigh := high
        rLow := low

        highSwept := false
        lowSwept := false

        candidateDir := 0
        secondSweepBar := na

        direction := 0
        confirmationBar := na

        candidateTop := na
        candidateBottom := na
        candidateMid := na

        primaryTop := na
        primaryBottom := na
        primaryReady := false

        used5 := false

    else if inRange
        rHigh := math.max(nz(rHigh, high), high)
        rLow := math.min(nz(rLow, low), low)

    rangeReady = not inRange and not na(rHigh) and not na(rLow)

    highSweep = rangeReady and high > rHigh and close < rHigh
    lowSweep  = rangeReady and low < rLow and close > rLow

    oldHigh = highSwept
    oldLow  = lowSwept

    // High swept first, then low swept = possible LONG reversal
    if lowSweep and oldHigh
        candidateDir := 1
        secondSweepBar := bar_index

    // Low swept first, then high swept = possible SHORT reversal
    if highSweep and oldLow
        candidateDir := -1
        secondSweepBar := bar_index

    if highSweep
        highSwept := true

    if lowSweep
        lowSwept := true

    bullDisp =
         close > open and
         body >= atr * dispATR and
         bodyPct >= bodyPctMin

    bearDisp =
         close < open and
         body >= atr * dispATR and
         bodyPct >= bodyPctMin

    priorHigh = ta.highest(high[1], mssLookback)
    priorLow  = ta.lowest(low[1], mssLookback)

    bullMSS = close > priorHigh
    bearMSS = close < priorLow

    barsAfterSweep = not na(secondSweepBar) ? bar_index - secondSweepBar : 9999

    validWindow =
         barsAfterSweep >= 0 and
         barsAfterSweep <= confirmBars

    bullConfirm =
         candidateDir == 1 and
         validWindow and
         bullDisp and
         bullMSS and
         bullDelta

    bearConfirm =
         candidateDir == -1 and
         validWindow and
         bearDisp and
         bearMSS and
         bearDelta

    if bullConfirm
        direction := 1
        confirmationBar := bar_index
        setupID += 1

        candidateTop := na
        candidateBottom := na
        candidateMid := na

        primaryTop := na
        primaryBottom := na
        primaryReady := false
        used5 := false

    if bearConfirm
        direction := -1
        confirmationBar := bar_index
        setupID += 1

        candidateTop := na
        candidateBottom := na
        candidateMid := na

        primaryTop := na
        primaryBottom := na
        primaryReady := false
        used5 := false

    bullGap = low - high[2]
    bearGap = low[2] - high

    bullFVG =
         low > high[2] and
         bullGap >= atr * minFvgATR

    bearFVG =
         high < low[2] and
         bearGap >= atr * minFvgATR

    scanning =
         not na(confirmationBar) and
         bar_index >= confirmationBar and
         bar_index - confirmationBar <= fvgScanBars

    // Bullish move: choose deepest/lower valid FVG
    if scanning and direction == 1 and bullFVG
        tempBottom = high[2]
        tempTop = low
        tempMid = (tempTop + tempBottom) / 2

        if na(candidateMid) or tempMid < candidateMid
            candidateTop := tempTop
            candidateBottom := tempBottom
            candidateMid := tempMid

    // Bearish move: choose highest valid FVG
    if scanning and direction == -1 and bearFVG
        tempTop = low[2]
        tempBottom = high
        tempMid = (tempTop + tempBottom) / 2

        if na(candidateMid) or tempMid > candidateMid
            candidateTop := tempTop
            candidateBottom := tempBottom
            candidateMid := tempMid

    lockPrimary =
         not na(confirmationBar) and
         bar_index - confirmationBar >= fvgScanBars and
         not primaryReady

    if lockPrimary and not na(candidateMid)
        primaryTop := candidateTop
        primaryBottom := candidateBottom
        primaryReady := true

    primaryMid =
         primaryReady ?
         (primaryTop + primaryBottom) / 2 :
         na

    bullRetest =
         primaryReady and
         direction == 1 and
         low <= primaryTop and
         high >= primaryBottom

    bearRetest =
         primaryReady and
         direction == -1 and
         high >= primaryBottom and
         low <= primaryTop

    buy5 =
         not used5 and
         bullRetest and
         close > primaryMid and
         close > open and
         bullDelta

    sell5 =
         not used5 and
         bearRetest and
         close < primaryMid and
         close < open and
         bearDelta

    if buy5 or sell5
        used5 := true

    [
        rHigh,
        rLow,
        highSweep,
        lowSweep,
        bullConfirm,
        bearConfirm,
        direction,
        primaryTop,
        primaryBottom,
        primaryReady,
        setupID,
        buy5,
        sell5
    ]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// GET 5M DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[
    rangeHigh5,
    rangeLow5,
    highSweepRaw,
    lowSweepRaw,
    bullBreakRaw,
    bearBreakRaw,
    direction5,
    fvgTop5,
    fvgBottom5,
    fvgReady5,
    setupID5,
    buy5Raw,
    sell5Raw
] = request.security(
    syminfo.tickerid,
    "5",
    f_engine5m(),
    gaps=barmerge.gaps_off,
    lookahead=barmerge.lookahead_off
)

// Make 5M events appear only once
highSweep5 = highSweepRaw and not highSweepRaw[1]
lowSweep5  = lowSweepRaw and not lowSweepRaw[1]

bullBreak5 = bullBreakRaw and not bullBreakRaw[1]
bearBreak5 = bearBreakRaw and not bearBreakRaw[1]

buy5Signal  = buy5Raw and not buy5Raw[1]
sell5Signal = sell5Raw and not sell5Raw[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1 MINUTE ENTRY CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

range1 = math.max(high - low, syminfo.mintick)

pressure1 =
     ((close - low) - (high - close)) /
     range1

delta1 = volume * pressure1

deltaAvg1 =
     ta.sma(math.abs(delta1), deltaLen1)

bullDelta1 =
     delta1 > 0 and
     math.abs(delta1) >= deltaAvg1 * deltaMult1

bearDelta1 =
     delta1 < 0 and
     math.abs(delta1) >= deltaAvg1 * deltaMult1

fvgMid5 =
     fvgReady5 ?
     (fvgTop5 + fvgBottom5) / 2 :
     na

touchLong1 =
     fvgReady5 and
     direction5 == 1 and
     low <= fvgTop5 and
     high >= fvgBottom5

touchShort1 =
     fvgReady5 and
     direction5 == -1 and
     high >= fvgBottom5 and
     low <= fvgTop5

bullReject1 =
     touchLong1 and
     close > fvgMid5 and
     close > open and
     bullDelta1

bearReject1 =
     touchShort1 and
     close < fvgMid5 and
     close < open and
     bearDelta1

var int lastBuy1Setup = na
var int lastSell1Setup = na

buy1Signal =
     bullReject1 and
     (na(lastBuy1Setup) or setupID5 != lastBuy1Setup)

sell1Signal =
     bearReject1 and
     (na(lastSell1Setup) or setupID5 != lastSell1Setup)

if buy1Signal
    lastBuy1Setup := setupID5

if sell1Signal
    lastSell1Setup := setupID5

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROFESSIONAL VISUALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(
     showRange ? rangeHigh5 : na,
     "Opening Range High",
     color=color.new(color.gray, 15),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showRange ? rangeLow5 : na,
     "Opening Range Low",
     color=color.new(color.gray, 15),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showFVG and fvgReady5 ? fvgTop5 : na,
     "Primary FVG Top",
     color=color.new(color.silver, 25),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showFVG and fvgReady5 ? fvgBottom5 : na,
     "Primary FVG Bottom",
     color=color.new(color.silver, 25),
     linewidth=1,
     style=plot.style_linebr
)

plotshape(
     showSweeps and highSweep5,
     title="High Fakeout",
     style=shape.circle,
     location=location.abovebar,
     size=size.tiny,
     color=color.new(color.red, 10)
)

plotshape(
     showSweeps and lowSweep5,
     title="Low Fakeout",
     style=shape.circle,
     location=location.belowbar,
     size=size.tiny,
     color=color.new(color.teal, 10)
)

plotshape(
     showBreakout and bullBreak5,
     title="Bull Breakout",
     text="BO",
     style=shape.labelup,
     location=location.belowbar,
     size=size.tiny,
     color=color.new(color.teal, 20),
     textcolor=color.white
)

plotshape(
     showBreakout and bearBreak5,
     title="Bear Breakout",
     text="BO",
     style=shape.labeldown,
     location=location.abovebar,
     size=size.tiny,
     color=color.new(color.red, 20),
     textcolor=color.white
)

plotshape(
     show1M and buy1Signal,
     title="1M Buy",
     text="1B",
     style=shape.labelup,
     location=location.belowbar,
     size=size.tiny,
     color=color.new(color.teal, 0),
     textcolor=color.white
)

plotshape(
     show1M and sell1Signal,
     title="1M Sell",
     text="1S",
     style=shape.labeldown,
     location=location.abovebar,
     size=size.tiny,
     color=color.new(color.red, 0),
     textcolor=color.white
)

plotshape(
     show5M and buy5Signal,
     title="5M Buy",
     text="5B",
     style=shape.labelup,
     location=location.belowbar,
     size=size.small,
     color=color.new(color.teal, 0),
     textcolor=color.white
)

plotshape(
     show5M and sell5Signal,
     title="5M Sell",
     text="5S",
     style=shape.labeldown,
     location=location.abovebar,
     size=size.small,
     color=color.new(color.red, 0),
     textcolor=color.white
)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     buy1Signal,
     "Sniper Akshita 1M BUY",
     "1M BUY: 5M setup + Primary FVG retest + 1M bullish delta confirmation."
)

alertcondition(
     sell1Signal,
     "Sniper Akshita 1M SELL",
     "1M SELL: 5M setup + Primary FVG retest + 1M bearish delta confirmation."
)

alertcondition(
     buy5Signal,
     "Sniper Akshita 5M BUY",
     "5M BUY: Primary FVG retest confirmed on 5-minute setup."
)

alertcondition(
     sell5Signal,
     "Sniper Akshita 5M SELL",
     "5M SELL: Primary FVG retest confirmed on 5-minute setup."
)
````
