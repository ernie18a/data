# NQ ICT Semi-Auto Strategy v1

- url: https://www.tradingview.com/script/iDLfHxHr-NQ-ICT-Semi-Auto-Strategy-v1/
- type: strategy
- pine_id: PUB;f903ef9087b0485d84d388c0f6a00501
- version: 1.0

## Description

NQ ICT TRADING STRATEGY DOCUMENT

1) IDENTITY
Instrument: NQ / US100
Confirmation Market: SP500
Style: ICT Scalping / Intraday
Main Session: New York Open
Secondary Session: New York PM only if model is clean
Primary Goal: A+ setups only, consistency, capital preservation, clean payouts

--------------------------------------------------
2) CORE PHILOSOPHY
I do not chase price.
I let price reach liquidity or a PD Array, then I wait for:
- liquidity sweep
- displacement
- market structure shift
- FVG / OTE entry
- SP500 confirmation
- macro alignment

Macro gives me the side.
ICT gives me the narrative.
Execution happens only after confirmation.

--------------------------------------------------
3) WEEKLY MACRO BIAS
Every weekend I check:

A) Macro Inputs
- COT
- US02Y
- US10Y
- WTI Oil
- DXY

B) Price Inputs
- US100 Weekly / Daily
- SP500 Weekly / Daily

C) Weekly Bias Rules

Bearish Weekly Bias:
- US02Y rising
- Oil rising
- DXY rising
- US100 Daily/Weekly weak
- SP500 Daily/Weekly weak

Bullish Weekly Bias:
- US02Y falling
- Oil stable or falling
- DXY weak
- US100 reclaiming key levels
- SP500 supportive

Mixed Weekly Bias:
- COT supportive but macro bearish
- US100 and SP500 in range
- conflicting signals

Weekly conclusion must be one of:
- Buy dips
- Sell rallies
- Mixed / range conditions

--------------------------------------------------
4) ICT HIGHER TIME FRAME FRAMEWORK
Before every trading day I define:

- Weekly High
- Weekly Low
- Previous Day High (PDH)
- Previous Day Low (PDL)
- Buy-side liquidity (BSL)
- Sell-side liquidity (SSL)
- Main Dealing Range
- Premium / Discount
- HTF PD Arrays
- Draw on Liquidity

Main questions:
1. Where is liquidity?
2. What is price drawing toward?
3. Is price in premium or discount?
4. Is there SMT with SP500?
5. Are we near a meaningful PD Array?

--------------------------------------------------
5) DAILY INTRADAY BIAS
Before NY Open I check:

- US100
- SP500
- NVDA
- WTI
- DXY
- US02Y

Bearish Intraday Bias:
- NQ weak
- SP500 weak
- NVDA weak
- Oil strong
- DXY strong
- Yields strong

Bullish Intraday Bias:
- NQ strong
- SP500 strong
- NVDA strong
- Oil stable or weak
- DXY weak
- Yields weak

Mixed / No Trade Bias:
- NQ and SP500 not aligned
- price stuck in the middle of the dealing range
- no displacement
- sloppy tape

--------------------------------------------------
6) MAIN ICT SETUPS

SETUP A: BEARISH PREMIUM REVERSAL

Conditions:
- Weekly bias bearish or mixed-bearish
- Price reaches premium
- Price sweeps buy-side liquidity
- SP500 confirms weakness or SMT bearish divergence appears
- Clear bearish displacement
- Bearish MSS on M1 or M5
- Entry on bearish FVG or OTE retracement

Entry:
- Sell only after confirmation
- Prefer entry after return into FVG / OTE zone

Stop:
- Above the sweep high
- Above invalidation level

Targets:
- Internal sell-side liquidity
- Equal lows
- SSL
- PDL
- Range low
- HTF draw on liquidity

--------------------------------------------------
SETUP B: BULLISH DISCOUNT REVERSAL

Conditions:
- Weekly bias bullish or mixed with bullish reaction
- Price reaches discount
- Price sweeps sell-side liquidity
- SP500 confirms strength or SMT bullish divergence appears
- Clear bullish displacement
- Bullish MSS on M1 or M5
- Entry on bullish FVG or OTE retracement

Entry:
- Buy only after confirmation
- Prefer entry after return into FVG / OTE zone

Stop:
- Below sweep low
- Below invalidation level

Targets:
- Internal buy-side liquidity
- Equal highs
- BSL
- PDH
- Range high
- HTF draw on liquidity

Note:
If macro is bearish, this setup is scalp only, not swing conviction.

--------------------------------------------------
SETUP C: RANGE EXTREME REVERSAL

Conditions:
- Market is in accumulation / chop / range
- No clear trend day
- Price reaches edge of range only
- Sweep occurs at edge
- MSS confirms reversal

Rules:
- Buy low of range only
- Sell high of range only
- No entries in the middle of the range

Targets:
- Midpoint first
- Opposite side of range second

--------------------------------------------------
7) AMD MODEL
I only want to execute after the market shows:

A = Accumulation
M = Manipulation (liquidity sweep)
D = Distribution (displacement in real direction)

Rule:
No entry during accumulation.
Wait for manipulation and then confirmation of distribution.

--------------------------------------------------
8) SMT MODEL WITH SP500

Bearish SMT:
- NQ makes a higher high
- SP500 fails to make a higher high
- Look for sell after sweep + displacement + MSS

Bullish SMT:
- NQ makes a lower low
- SP500 fails to make a lower low
- Look for buy after sweep + displacement + MSS

Rule:
SMT is confirmation, not entry by itself.

--------------------------------------------------
9) ENTRY TRIGGER RULES
I do not enter because price touched a zone.
I only enter if I have at least:

1. Liquidity sweep
2. Displacement
3. MSS
4. Return to FVG or OTE
5. SP500 confirmation or at least no contradiction

If these are not present:
NO TRADE

--------------------------------------------------
10) RISK RULES
Standard risk per trade: 0.5%
Maximum risk per idea: 1%
Maximum daily loss: 1%
Maximum number of trades per day: 2

Hard rules:
- No revenge trading
- No increasing risk after a loss
- No more than 1% risk on the same trade idea
- Respect firm rules regarding maximum single trade / same idea risk

--------------------------------------------------
11) MANAGEMENT RULES

A+ ICT Setup:
- No break-even at 1R
- Move stop to break-even at 1.5R
- First partial at 2R or at a key liquidity target
- Partial size: 20% to 30% only
- Leave a runner for HTF draw on liquidity
- Trail behind structure

Normal Setup:
- Partial allowed at 1R
- Move to break-even at 1.5R
- No early full close unless tape becomes sloppy

Messy / Headline Market:
- Take smaller targets
- Accept BE if necessary
- No forcing runners
- Focus on preserving capital

--------------------------------------------------
12) NO TRADE CONDITIONS
I do not trade if:

- Price is in the middle of the dealing range
- NQ and SP500 are not aligned
- No displacement
- No MSS
- Major news is about to release
- Tape is extremely sloppy
- I am stressed, tired, emotional, or distracted
- I already took 2 losses
- Setup is not A+ quality

--------------------------------------------------
13) HIGH IMPACT NEWS RULES
Important events:
- FOMC
- CPI
- PPI
- NFP
- Powell speeches
- Major war/oil headlines

Rules:
- No trade before major release
- Wait 5 to 15 minutes after release
- Let news high and low form
- Trade only if structure appears after volatility
- No guessing direction before confirmation

--------------------------------------------------
14) SESSION RULES

New York Open:
- Main execution window
- Best time for sweep + displacement model
- Do not chase first impulse candle
- Wait for model to develop

New York PM:
- Trade only if there is a clean continuation or clean reversal
- Otherwise skip

Monday Rule:
- Monday is not a forcing day
- If unclear, no trade
- Better to preserve capital than start the week with damage

--------------------------------------------------
15) WEEKEND PREP TEMPLATE

Weekly Bias:
...

COT:
- Nasdaq Mini:
- SP500:

Macro:
- US02Y:
- US10Y:
- Oil:
- DXY:

Price Structure:
- US100 Weekly:
- US100 Daily:
- SP500 Weekly:
- SP500 Daily:

Main Draw on Liquidity:
...

Key Weekly Levels:
...

Best Weekly Scenario:
...

Worst Weekly Scenario:
...

What to avoid:
...

--------------------------------------------------
16) DAILY PREP TEMPLATE

Date:
...

Macro Bias Today:
...

Price Bias Today:
...

Session:
...

Main Levels:
- Weekly High:
- Weekly Low:
- PDH:
- PDL:
- BSL:
- SSL:

Main PD Arrays:
...

Draw on Liquidity:
...

Preferred Setup:
...

No Trade If:
...

Risk Today:
0.5%

Max Trades:
2

--------------------------------------------------
17) POST-TRADE JOURNAL TEMPLATE

Date:
Session:
Bias:
Setup Type:
Liquidity Taken:
SMT Present:
Displacement Present:
MSS Present:
Entry Model:
Stop Placement:
Target Model:
Risk %:
Outcome:
Mistake:
Market Condition:
Was this A+?
Lesson:

--------------------------------------------------
18) PERSONAL RULES
- I do not chase missed moves
- I do not trade from the middle of the range
- I do not use break-even as emotional protection
- I only trade A+ ICT models
- No trade is a valid decision
- Payout withdrawals are not losses
- My job is execution, not prediction
- Capital preservation is a win
- I trade process, not emotion

--------------------------------------------------
19) FINAL EXECUTION RULE
For every trade I must know:

- Where liquidity is
- What price is drawing toward
- Whether price is in premium or discount
- Whether SP500 confirms or diverges
- Whether displacement and MSS are present
- Whether the setup is A+

If I do not know these clearly:
NO TRADE

--------------------------------------------------
20) MAIN OBJECTIVE
My objective is not to trade every day.
My objective is to execute only clean ICT setups with discipline,
protect capital,
stay within risk,
and build consistency for long-term payouts.

## Source Code

````pine
//@version=6
strategy("NQ ICT Semi-Auto Strategy v1",
     overlay = true,
     initial_capital = 100000,
     commission_type = strategy.commission.percent,
     commission_value = 0.0,
     pyramiding = 0,
     calc_on_every_tick = false,
     process_orders_on_close = true,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 2)

//---------------------------------------------------------
// Inputs
//---------------------------------------------------------
groupBias   = "Bias / Confirmation"
groupSess   = "Sessions"
groupStruct = "Structure"
groupDisp   = "Displacement / MSS / FVG"
groupRisk   = "Risk / Trade Management"
groupVis    = "Visuals"

manualBias = input.string("Mixed", "Manual Bias", options = ["Bullish", "Bearish", "Mixed", "Neutral"], group = groupBias)
confirmSymbol = input.symbol("CME_MINI:ES1!", "SP500 Confirmation Symbol", group = groupBias)
confirmMode = input.string("Balanced", "Confirmation Mode", options = ["Strict", "Balanced", "Loose"], group = groupBias)
spEmaLen = input.int(20, "SP500 EMA Length", minval = 1, group = groupBias)
smtLookback = input.int(20, "SMT Lookback", minval = 3, group = groupBias)

sessionTZ = input.string("America/New_York", "Session Timezone", group = groupSess)
nyOpenSession = input.session("0930-1130", "NY Open", group = groupSess)
nyPmSession = input.session("1330-1530", "NY PM", group = groupSess)
enablePmSession = input.bool(false, "Enable NY PM", group = groupSess)
blockMonday = input.bool(false, "Block Monday", group = groupSess)

pivotLen = input.int(3, "Pivot Length", minval = 1, group = groupStruct)
midBandPct = input.float(0.10, "Midpoint No-Trade Band %", minval = 0.0, maxval = 0.45, step = 0.01, group = groupStruct)
setupLookback = input.int(6, "Bars Allowed Between Sweep/Disp/MSS", minval = 1, group = groupStruct)

atrLen = input.int(14, "ATR Length", minval = 1, group = groupDisp)
dispATRMult = input.float(1.2, "Displacement ATR Multiplier", minval = 0.1, step = 0.1, group = groupDisp)
minBodyRatio = input.float(0.60, "Min Body / Range Ratio", minval = 0.1, maxval = 1.0, step = 0.05, group = groupDisp)
closeNearPct = input.float(0.25, "Close Near Edge %", minval = 0.05, maxval = 0.5, step = 0.05, group = groupDisp)
minFvgTicks = input.int(8, "Minimum FVG Size (ticks)", minval = 1, group = groupDisp)

maxTradesPerDay = input.int(2, "Max Trades Per Day", minval = 1, group = groupRisk)
maxStopPoints = input.float(80.0, "Max Stop Distance (points)", minval = 0.25, step = 0.25, group = groupRisk)
stopBufferTicks = input.int(4, "Stop Buffer (ticks)", minval = 0, group = groupRisk)
targetRR = input.float(2.0, "Final Target R", minval = 0.5, step = 0.25, group = groupRisk)
breakEvenRR = input.float(1.5, "Break-Even Trigger R", minval = 0.5, step = 0.25, group = groupRisk)

showPD = input.bool(true, "Plot PDH / PDL / Mid", group = groupVis)
showFVG = input.bool(true, "Plot Active FVG", group = groupVis)
showSignals = input.bool(true, "Plot Signals", group = groupVis)

//---------------------------------------------------------
// Session logic
//---------------------------------------------------------
inNyOpen = not na(time(timeframe.period, nyOpenSession, sessionTZ))
inNyPm   = not na(time(timeframe.period, nyPmSession, sessionTZ))
isMonday = dayofweek == dayofweek.monday

allowedSession = inNyOpen or (enablePmSession and inNyPm)
allowedDay = not (blockMonday and isMonday)
sessionOK = allowedSession and allowedDay

//---------------------------------------------------------
// Daily levels (previous day high/low)
//---------------------------------------------------------
pdh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
pdl = request.security(syminfo.tickerid, "D", low[1], barmerge.gaps_off, barmerge.lookahead_off)
mid = (pdh + pdl) / 2.0
dayRange = math.abs(pdh - pdl)
midBand = dayRange * midBandPct

inPremium = close > mid + midBand
inDiscount = close < mid - midBand
inMidNoTrade = math.abs(close - mid) <= midBand

//---------------------------------------------------------
// Swing structure
//---------------------------------------------------------
var float lastSwingHigh = na
var float lastSwingLow  = na

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

if not na(ph)
    lastSwingHigh := ph
if not na(pl)
    lastSwingLow := pl

sweepHighRef = na(lastSwingHigh) ? pdh : math.max(pdh, lastSwingHigh)
sweepLowRef  = na(lastSwingLow)  ? pdl : math.min(pdl, lastSwingLow)

//---------------------------------------------------------
// Liquidity sweep
//---------------------------------------------------------
buffer = syminfo.mintick * stopBufferTicks

bearSweep = high > sweepHighRef and close < sweepHighRef
bullSweep = low < sweepLowRef and close > sweepLowRef

//---------------------------------------------------------
// Displacement
//---------------------------------------------------------
atr = ta.atr(atrLen)
barRange = high - low
bodySize = math.abs(close - open)
bodyRatio = barRange > 0 ? bodySize / barRange : 0.0

bearDisp = barRange > atr * dispATRMult and bodyRatio >= minBodyRatio and close <= low + (barRange * closeNearPct)
bullDisp = barRange > atr * dispATRMult and bodyRatio >= minBodyRatio and close >= high - (barRange * closeNearPct)

//---------------------------------------------------------
// MSS approximation
//---------------------------------------------------------
bearMss = not na(lastSwingLow) and close < lastSwingLow
bullMss = not na(lastSwingHigh) and close > lastSwingHigh

recentBearSweep = ta.barssince(bearSweep) >= 0 and ta.barssince(bearSweep) <= setupLookback
recentBullSweep = ta.barssince(bullSweep) >= 0 and ta.barssince(bullSweep) <= setupLookback
recentBearDisp  = ta.barssince(bearDisp) >= 0 and ta.barssince(bearDisp) <= setupLookback
recentBullDisp  = ta.barssince(bullDisp) >= 0 and ta.barssince(bullDisp) <= setupLookback
recentBearMss   = ta.barssince(bearMss) >= 0 and ta.barssince(bearMss) <= setupLookback
recentBullMss   = ta.barssince(bullMss) >= 0 and ta.barssince(bullMss) <= setupLookback

//---------------------------------------------------------
// FVG detection
//---------------------------------------------------------
bullFvg = low > high[2]
bearFvg = high < low[2]

bullFvgTop = low
bullFvgBot = high[2]
bearFvgTop = low[2]
bearFvgBot = high

minFvgSize = syminfo.mintick * minFvgTicks
validBullFvg = bullFvg and (bullFvgTop - bullFvgBot >= minFvgSize)
validBearFvg = bearFvg and (bearFvgTop - bearFvgBot >= minFvgSize)

//---------------------------------------------------------
// SP500 confirmation
//---------------------------------------------------------
spClose = request.security(confirmSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
spHigh  = request.security(confirmSymbol, timeframe.period, high,  barmerge.gaps_off, barmerge.lookahead_off)
spLow   = request.security(confirmSymbol, timeframe.period, low,   barmerge.gaps_off, barmerge.lookahead_off)
spEma   = ta.ema(spClose, spEmaLen)

spWeak = spClose < spEma
spStrong = spClose > spEma

nqHigherHigh = high > ta.highest(high[1], smtLookback)
nqLowerLow   = low < ta.lowest(low[1], smtLookback)
spFailsHH    = spHigh <= ta.highest(spHigh[1], smtLookback)
spFailsLL    = spLow >= ta.lowest(spLow[1], smtLookback)

bearSmt = nqHigherHigh and spFailsHH
bullSmt = nqLowerLow and spFailsLL

confirmBear = switch confirmMode
    "Strict"   => spWeak
    "Balanced" => spWeak or bearSmt
    => not spStrong

confirmBull = switch confirmMode
    "Strict"   => spStrong
    "Balanced" => spStrong or bullSmt
    => not spWeak

//---------------------------------------------------------
// Manual bias filter
//---------------------------------------------------------
allowShortBias = manualBias == "Bearish" or manualBias == "Mixed"
allowLongBias  = manualBias == "Bullish" or manualBias == "Mixed"

//---------------------------------------------------------
// Setup state
//---------------------------------------------------------
var float activeBearFvgTop = na
var float activeBearFvgBot = na
var float activeBullFvgTop = na
var float activeBullFvgBot = na
var float pendingShortStop = na
var float pendingLongStop = na
var int   bearSetupBar = na
var int   bullSetupBar = na

newBearSetup = sessionOK and allowShortBias and inPremium and not inMidNoTrade and recentBearSweep and recentBearDisp and recentBearMss and validBearFvg and confirmBear
newBullSetup = sessionOK and allowLongBias  and inDiscount and not inMidNoTrade and recentBullSweep and recentBullDisp and recentBullMss and validBullFvg and confirmBull

if newBearSetup
    activeBearFvgTop := bearFvgTop
    activeBearFvgBot := bearFvgBot
    pendingShortStop := math.max(high, sweepHighRef) + buffer
    bearSetupBar := bar_index

if newBullSetup
    activeBullFvgTop := bullFvgTop
    activeBullFvgBot := bullFvgBot
    pendingLongStop := math.min(low, sweepLowRef) - buffer
    bullSetupBar := bar_index

expireBars = setupLookback * 2

if not na(bearSetupBar) and bar_index - bearSetupBar > expireBars
    activeBearFvgTop := na
    activeBearFvgBot := na
    pendingShortStop := na
    bearSetupBar := na

if not na(bullSetupBar) and bar_index - bullSetupBar > expireBars
    activeBullFvgTop := na
    activeBullFvgBot := na
    pendingLongStop := na
    bullSetupBar := na

//---------------------------------------------------------
// Entry logic
//---------------------------------------------------------
retraceIntoBearFvg = not na(activeBearFvgTop) and high >= activeBearFvgBot and low <= activeBearFvgTop
retraceIntoBullFvg = not na(activeBullFvgTop) and high >= activeBullFvgBot and low <= activeBullFvgTop

stopShortDist = not na(pendingShortStop) ? pendingShortStop - close : na
stopLongDist  = not na(pendingLongStop)  ? close - pendingLongStop : na

validShortStop = not na(stopShortDist) and stopShortDist > syminfo.mintick and stopShortDist <= maxStopPoints
validLongStop  = not na(stopLongDist)  and stopLongDist > syminfo.mintick and stopLongDist <= maxStopPoints

//---------------------------------------------------------
// Trade counter per day
//---------------------------------------------------------
newDay = ta.change(time("D")) != 0
var int tradesToday = 0

if newDay
    tradesToday := 0

openedNewTrade = strategy.position_size != 0 and strategy.position_size[1] == 0
if openedNewTrade
    tradesToday += 1

canTradeMore = tradesToday < maxTradesPerDay
flat = strategy.position_size == 0

enterShort = flat and canTradeMore and sessionOK and retraceIntoBearFvg and validShortStop and allowShortBias and confirmBear
enterLong  = flat and canTradeMore and sessionOK and retraceIntoBullFvg and validLongStop and allowLongBias and confirmBull

if enterShort
    strategy.entry("Short", strategy.short)
    activeBearFvgTop := na
    activeBearFvgBot := na
    bearSetupBar := na

if enterLong
    strategy.entry("Long", strategy.long)
    activeBullFvgTop := na
    activeBullFvgBot := na
    bullSetupBar := na

//---------------------------------------------------------
// Trade management
//---------------------------------------------------------
var float liveLongStop = na
var float liveLongTp   = na
var float liveLongRisk = na

var float liveShortStop = na
var float liveShortTp   = na
var float liveShortRisk = na

newLongPos = strategy.position_size > 0 and strategy.position_size[1] <= 0
newShortPos = strategy.position_size < 0 and strategy.position_size[1] >= 0
flatNow = strategy.position_size == 0

if newLongPos
    liveLongStop := pendingLongStop
    liveLongRisk := strategy.position_avg_price - liveLongStop
    liveLongTp := strategy.position_avg_price + (liveLongRisk * targetRR)
    pendingLongStop := na

if newShortPos
    liveShortStop := pendingShortStop
    liveShortRisk := liveShortStop - strategy.position_avg_price
    liveShortTp := strategy.position_avg_price - (liveShortRisk * targetRR)
    pendingShortStop := na

if strategy.position_size > 0
    beLongTrigger = strategy.position_avg_price + (liveLongRisk * breakEvenRR)
    if high >= beLongTrigger
        liveLongStop := math.max(liveLongStop, strategy.position_avg_price)
    strategy.exit("Long Exit", "Long", stop = liveLongStop, limit = liveLongTp)

if strategy.position_size < 0
    beShortTrigger = strategy.position_avg_price - (liveShortRisk * breakEvenRR)
    if low <= beShortTrigger
        liveShortStop := math.min(liveShortStop, strategy.position_avg_price)
    strategy.exit("Short Exit", "Short", stop = liveShortStop, limit = liveShortTp)

if flatNow
    liveLongStop := na
    liveLongTp := na
    liveLongRisk := na
    liveShortStop := na
    liveShortTp := na
    liveShortRisk := na

//---------------------------------------------------------
// Visuals
//---------------------------------------------------------
p1 = plot(showPD ? pdh : na, "PDH", color = color.red, linewidth = 1, style = plot.style_linebr)
p2 = plot(showPD ? pdl : na, "PDL", color = color.aqua, linewidth = 1, style = plot.style_linebr)
p3 = plot(showPD ? mid : na, "Midpoint", color = color.yellow, linewidth = 1, style = plot.style_linebr)

bgcolor(inPremium ? color.new(color.red, 92) : na)
bgcolor(inDiscount ? color.new(color.green, 92) : na)
bgcolor(inMidNoTrade ? color.new(color.orange, 88) : na)

plot(showFVG ? activeBearFvgTop : na, "Active Bear FVG Top", color = color.new(color.red, 0), style = plot.style_linebr)
plot(showFVG ? activeBearFvgBot : na, "Active Bear FVG Bottom", color = color.new(color.red, 0), style = plot.style_linebr)
plot(showFVG ? activeBullFvgTop : na, "Active Bull FVG Top", color = color.new(color.green, 0), style = plot.style_linebr)
plot(showFVG ? activeBullFvgBot : na, "Active Bull FVG Bottom", color = color.new(color.green, 0), style = plot.style_linebr)

plotshape(showSignals and bearSweep, title = "Bear Sweep", style = shape.triangledown, location = location.abovebar, color = color.red, size = size.tiny, text = "SWP")
plotshape(showSignals and bullSweep, title = "Bull Sweep", style = shape.triangleup, location = location.belowbar, color = color.green, size = size.tiny, text = "SWP")
plotshape(showSignals and bearMss, title = "Bear MSS", style = shape.circle, location = location.abovebar, color = color.maroon, size = size.tiny, text = "MSS")
plotshape(showSignals and bullMss, title = "Bull MSS", style = shape.circle, location = location.belowbar, color = color.lime, size = size.tiny, text = "MSS")
plotshape(showSignals and enterShort, title = "Short Entry", style = shape.labeldown, location = location.abovebar, color = color.red, text = "SHORT")
plotshape(showSignals and enterLong, title = "Long Entry", style = shape.labelup, location = location.belowbar, color = color.green, text = "LONG")

//---------------------------------------------------------
// Alerts
//---------------------------------------------------------
alertcondition(bearSweep, "Bearish Sweep", "Bearish liquidity sweep detected")
alertcondition(bullSweep, "Bullish Sweep", "Bullish liquidity sweep detected")
alertcondition(bearMss, "Bearish MSS", "Bearish MSS detected")
alertcondition(bullMss, "Bullish MSS", "Bullish MSS detected")
alertcondition(newBearSetup, "Bearish Setup Ready", "Bearish ICT setup chain completed")
alertcondition(newBullSetup, "Bullish Setup Ready", "Bullish ICT setup chain completed")
alertcondition(enterShort, "Short Entry", "Short entry triggered")
alertcondition(enterLong, "Long Entry", "Long entry triggered")
````
