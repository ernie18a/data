# Daily 200 EMA Break-Retest-Reclaim Swing Strategy

- url: https://www.tradingview.com/script/vAjCqGaT-Daily-200-EMA-Break-Retest-Reclaim-Swing-Strategy/
- type: indicator
- pine_id: PUB;7d0e9d32fc414f81907c44e63962602b
- version: 1.0

## Description

[b]# Daily 200 EMA Break-Retest-Reclaim Script — How to Use It
[/b]
The purpose of this script is to help identify stocks or ETFs that are reacting around the **daily 200 EMA**, which is a major long-term trend level. The script is not meant to be used as a blind buy/sell signal. It is designed to alert me when price is setting up around the 200 EMA so I can review the chart and decide whether the trade fits my process.

The main idea is:

> **The daily 200 EMA gives me the location. The break, retest, hold, displacement, and continuation give me the trade.**

This is a swing-style setup, especially useful for options trades where I want to catch a larger move after price reclaims or rejects a major trend level.

---

# Core Strategy Logic

The script is built around the **daily 200 EMA**.

A bullish setup happens when price breaks above, reclaims, or bounces from the daily 200 EMA, then holds that level and continues higher.

A bearish setup happens when price breaks below, rejects, or loses the daily 200 EMA, then fails to reclaim it and continues lower.

I should not enter just because price touches the 200 EMA. The 200 EMA is only the area of interest. I still need confirmation.

The clean bullish sequence is:

> Price approaches the daily 200 EMA → breaks above it or bounces from it → pulls back/retests → holds above it → shows displacement → continues higher.

The clean bearish sequence is:

> Price approaches the daily 200 EMA → breaks below it or rejects from underneath → pulls back/retests → fails to reclaim → shows displacement lower → continues down.

---

# How I Should Use the Script

The script should be used as a **watchlist and alert tool**, not as an automatic entry system.

When the script gives a signal, I should ask:

1. Is price reacting at or near the daily 200 EMA?
2. Did price break, reclaim, reject, or hold the 200 EMA?
3. Is there a clean retest?
4. Is there displacement away from the level?
5. Is price holding the retest area?
6. Are the filters supporting the trade?
7. Is the broader market aligned with the direction of the trade?
8. Is there enough room to the next target to justify the risk?

The signal gets my attention. The chart still has to prove the trade.

---

# Main Filters and What They Mean

## 1. Daily 200 EMA

The 200 EMA is the main level. It acts like dynamic support or resistance.

If price is above the 200 EMA, the broader trend is more bullish.

If price is below the 200 EMA, the broader trend is more bearish.

But the script is not just asking, “Is price above or below the 200?” It is looking for meaningful behavior around the level: break, retest, reclaim, hold, rejection, or continuation.

---

## 2. 200 EMA Slope Filter

The slope filter checks whether the 200 EMA itself is rising, falling, or flat.

A rising 200 EMA supports bullish trades.

A falling 200 EMA supports bearish trades.

A flat 200 EMA means the stock may be in a choppy or undecided zone.

This matters because a bullish break above a rising 200 EMA is usually stronger than a bullish break above a flat or falling 200 EMA. A bearish breakdown below a falling 200 EMA is usually stronger than a breakdown below a flat or rising 200 EMA.

My rule:

> A trade is stronger when price direction and 200 EMA slope agree.

Example:

* Price breaks above 200 EMA and 200 EMA is sloping up = stronger bullish setup.
* Price breaks below 200 EMA and 200 EMA is sloping down = stronger bearish setup.
* Price is chopping around a flat 200 EMA = lower-quality setup.

---

## 3. 21 EMA Trend Filter

The 21 EMA is a shorter-term trend filter. It helps determine whether momentum is starting to support the move.

For bullish trades, I want price above the 21 EMA, or I want the 21 EMA starting to turn higher.

For bearish trades, I want price below the 21 EMA, or I want the 21 EMA starting to turn lower.

The 21 EMA helps confirm that the move away from the 200 EMA has short-term momentum behind it.

My rule:

> The 200 EMA gives me the major level. The 21 EMA helps confirm whether shorter-term trend is supporting the move.

---

## 4. Volume Confirmation

The volume filter checks whether the move around the 200 EMA is happening with stronger-than-normal participation.

A break or reclaim on weak volume is less trustworthy.

A break, reclaim, or rejection on strong volume is more meaningful.

For bullish trades, I want volume to expand as price breaks above or reclaims the 200 EMA.

For bearish trades, I want volume to expand as price breaks below or rejects from the 200 EMA.

My rule:

> A strong candle with weak volume is less convincing. A strong candle with strong volume is better confirmation.

Volume helps show whether institutions or larger traders may be participating in the move.

---

## 5. SPY/QQQ Market Alignment

This filter checks whether the broader market agrees with the direction of the trade.

For bullish trades, it is better when SPY and/or QQQ are also bullish, reclaiming key levels, or trading above their own major moving averages.

For bearish trades, it is better when SPY and/or QQQ are weak, rejecting, or trading below key levels.

This helps prevent taking bullish trades in a weak market or bearish trades in a strong market.

My rule:

> I want the stock setup and the market environment pointing in the same direction.

Example:

* A stock gives a bullish 200 EMA reclaim, and QQQ is also strong = better long setup.
* A stock gives a bullish 200 EMA reclaim, but QQQ is selling off hard = lower-quality setup.
* A stock gives a bearish 200 EMA rejection, and SPY/QQQ are also weak = better put setup.

---

## 6. Chop / Whipsaw Protection

The chop filter helps identify when price is just bouncing back and forth around the 200 EMA without clean direction.

This is important because the 200 EMA can become a trap zone. Price may break above it, fail, break below it, reclaim, then chop sideways.

That is not the environment I want.

My rule:

> If price is repeatedly crossing above and below the 200 EMA without follow-through, I should avoid the trade.

A clean setup should show price making a decision.

For bullish trades, I want price to reclaim the 200 EMA and hold above it.

For bearish trades, I want price to lose the 200 EMA and stay below it.

No clean hold = no trade.

---

# Signal Grades

The script may grade signals as **A+**, **B**, or **C** based on how many filters agree.

## A+ Signal

An A+ signal means most or all major filters agree.

A bullish A+ setup may include:

* Price reclaims or bounces from the daily 200 EMA.
* Price holds the retest.
* 200 EMA slope supports the direction.
* Price is aligned with the 21 EMA.
* Volume confirms the move.
* SPY/QQQ are aligned.
* Price is not chopping around the level.
* There is room to the next target.

This is the highest-quality setup.

My mindset:

> A+ means I can pay closer attention and consider a cleaner options setup, but I still need chart confirmation before entry.

## B Signal

A B signal means the setup is decent, but not perfect.

Maybe price reclaimed the 200 EMA and held, but volume is average.

Or maybe the stock setup is clean, but SPY/QQQ are mixed.

Or maybe the 200 EMA slope is flat, but price action is showing strength.

My mindset:

> B means the setup is tradable only if the chart structure is clean and risk/reward makes sense.

## C Signal

A C signal means there is some kind of setup, but the trade has missing confirmation.

Maybe price touched the 200 EMA but did not clearly hold.

Maybe price is chopping.

Maybe volume is weak.

Maybe the market is not aligned.

My mindset:

> C means watch only. Do not force the trade.

---

# Best Way to Employ the Script

I should use the script in three stages:

## Stage 1 — Daily Chart Location

First, I use the daily chart to identify the setup around the 200 EMA.

I want to see whether price is:

* Approaching the 200 EMA
* Bouncing from the 200 EMA
* Breaking above the 200 EMA
* Retesting the 200 EMA
* Rejecting from the 200 EMA
* Breaking below the 200 EMA

The daily chart tells me where the important level is.

---

## Stage 2 — Confirmation

Once price reacts around the 200 EMA, I look for confirmation.

Confirmation can come from:

* A strong displacement candle
* A close above the 200 EMA for bullish trades
* A close below the 200 EMA for bearish trades
* A retest that holds
* A higher low after reclaiming the 200 EMA
* A lower high after rejecting the 200 EMA
* Volume expansion
* SPY/QQQ alignment

A conservative version of the strategy waits for a **daily close** back above the 200 EMA before considering calls.

For puts, a conservative version waits for a **daily close** below the 200 EMA before considering bearish trades.

---

## Stage 3 — Entry Timing

The daily chart gives the setup, but I do not have to enter directly from the daily candle.

A better process is:

> Daily chart gives the level and bias. Lower timeframe gives the entry.

After the daily setup appears, I can drop to the 1H, 30-minute, 15-minute, or 5-minute chart to find the actual entry.

For my style, I should still look for:

> Break → retest → hold → continuation.

Or:

> Displacement → fair value gap/retest → hold → continuation.

The script helps me find the opportunity, but my entry should still be based on price action.

---

# Bullish Trade Example

A bullish setup would look like this:

1. Stock has been trading below or near the daily 200 EMA.
2. Price breaks above the 200 EMA with a strong candle.
3. Volume is stronger than normal.
4. The 200 EMA is flat or starting to slope up.
5. Price pulls back to retest the 200 EMA.
6. The retest holds.
7. Price starts pushing higher again.
8. SPY/QQQ are also strong or at least not fighting the move.
9. I look for calls or a call debit spread with enough time.

Entry idea:

> Enter after the retest holds and price starts continuing higher.

Stop idea:

> Invalidation is below the retest low or below the 200 EMA reclaim area.

Target idea:

> Prior swing high, gap fill, liquidity level, or next resistance area.

---

# Bearish Trade Example

A bearish setup would look like this:

1. Stock is trading near the daily 200 EMA.
2. Price breaks below the 200 EMA or rejects from underneath it.
3. Volume expands on the move lower.
4. The 200 EMA is flat or sloping down.
5. Price retests the 200 EMA from below.
6. Price fails to reclaim it.
7. Price starts pushing lower again.
8. SPY/QQQ are also weak.
9. I look for puts or a put debit spread with enough time.

Entry idea:

> Enter after the failed retest and continuation lower.

Stop idea:

> Invalidation is above the retest high or above the 200 EMA reclaim area.

Target idea:

> Prior swing low, unfilled gap, liquidity level, or next support area.

---

# When to Ignore the Signal

I should ignore or downgrade the signal when:

* Price is chopping back and forth across the 200 EMA.
* The 200 EMA is flat and price has no displacement.
* Volume is weak.
* SPY/QQQ are moving against the trade.
* The stock has no room to the next target.
* The option spread is too wide.
* The contract is too expensive relative to my account plan.
* The setup requires me to chase after the move has already happened.
* There is no clear stop/invalidation level.
* The signal is only a touch of the 200 EMA, not a confirmed hold or rejection.

The biggest mistake would be treating the script like a “buy calls now” or “buy puts now” signal.

The script is really saying:

> “Pay attention. Price is reacting around an important level.”

---

# Options Notes

Because this setup is based on the daily 200 EMA, I should usually think of it as a swing setup, not a same-day scalp.

That means I should be careful with short-dated options.

For better structure, I can consider:

* ATM contracts
* Slightly ITM contracts
* Debit spreads
* Enough expiration time for the move to develop

The chart can be right, but the option can still lose if the move is too slow and theta eats the contract.

My rule:

> If I am trading a daily 200 EMA setup, I need to give the trade enough time to work.

---

# Simple Checklist

Before taking a trade from the script, I should be able to say yes to most of these:

* Is price reacting at the daily 200 EMA?
* Did price break, reclaim, reject, or hold the level?
* Did price retest and hold?
* Is there displacement away from the level?
* Is the 200 EMA slope supporting the trade?
* Is the 21 EMA supporting the short-term trend?
* Is volume confirming the move?
* Are SPY/QQQ aligned?
* Is price avoiding chop around the 200 EMA?
* Do I have a clear stop?
* Do I have a clear target?
* Is the risk/reward worth the trade?
* Am I entering on confirmation instead of chasing?

---

# Bottom-Line Rule

The daily 200 EMA script is a **major-level reaction tool**.

It helps me find stocks where price may be shifting from bearish to bullish, or bullish to bearish, around one of the most important moving averages on the chart.

## Source Code

````pine
//@version=6
indicator("Daily 200 EMA Break-Retest-Reclaim Swing Strategy", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================================
// INPUTS
//====================================================================

// Higher timeframe EMA settings
emaTf      = input.timeframe("D", "Higher Timeframe For 200 EMA")
emaLength  = input.int(200, "200 EMA Length", minval=1)

// Retest zone
zonePercent = input.float(0.50, "Retest Zone Around 200 EMA (%)", step=0.05) / 100

// Setup timing
breakLookback = input.int(80, "Max Bars After Break To Watch", minval=5)

// Confirmation mode
confirmMode = input.string(
     "Break Previous Candle High + Above 200 EMA",
     "Bullish Confirmation Mode",
     options=[
         "Close Back Above 200 EMA",
         "Bullish Engulfing + Above 200 EMA",
         "Break Previous Candle High + Above 200 EMA",
         "Higher High + Higher Low + Above 200 EMA"
     ]
)

// Filters
useSlopeFilter       = input.bool(true, "Require 200 EMA Flat/Rising?")
slopeLookback        = input.int(10, "200 EMA Slope Lookback", minval=1)

useDailyReclaim      = input.bool(true, "Require Daily Close/Reclaim Above 200 EMA?")
useConfirmedDaily    = input.bool(false, "Use Prior Confirmed Daily Close?")

useVolumeFilter      = input.bool(true, "Require Volume Confirmation?")
volumeTf             = input.timeframe("D", "Volume Confirmation Timeframe")
volumeLength         = input.int(20, "Volume Average Length", minval=1)
volumeMultiplier     = input.float(1.10, "Volume Multiplier", step=0.05)

useMarketFilter      = input.bool(true, "Require Market Alignment?")
marketSymbol         = input.symbol("SPY", "Market Alignment Symbol")
marketEmaLength      = input.int(200, "Market EMA Length", minval=1)

use21Filter          = input.bool(true, "Require Close Above 21 EMA?")
ema21Length          = input.int(21, "Lower Timeframe EMA Length", minval=1)

useChopFilter        = input.bool(true, "Avoid Choppy 200 EMA Crosses?")
chopLookback         = input.int(50, "Chop Lookback Bars", minval=5)
maxCrossesAllowed    = input.int(4, "Max Crosses Allowed In Chop Lookback", minval=1)

// Display settings
show200Ema       = input.bool(true, "Show Daily 200 EMA?")
show21Ema        = input.bool(true, "Show 21 EMA?")
showRetestZone   = input.bool(true, "Show Retest Zone?")
showStopLine     = input.bool(true, "Show Suggested Stop?")
showDailyTargets = input.bool(true, "Show Prior Daily High/Low?")
showBackground   = input.bool(true, "Highlight Active Setup?")
showTable        = input.bool(true, "Show Filter Status Table?")

//====================================================================
// HIGHER TIMEFRAME DATA
//====================================================================

htfClose = request.security(
     syminfo.tickerid,
     emaTf,
     close,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

htfHigh = request.security(
     syminfo.tickerid,
     emaTf,
     high,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

htfLow = request.security(
     syminfo.tickerid,
     emaTf,
     low,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

htf200Ema = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, emaLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

priorConfirmedDailyClose = request.security(
     syminfo.tickerid,
     emaTf,
     close[1],
     barmerge.gaps_off,
     barmerge.lookahead_off
)

priorConfirmedDailyEma = request.security(
     syminfo.tickerid,
     emaTf,
     ta.ema(close, emaLength)[1],
     barmerge.gaps_off,
     barmerge.lookahead_off
)

priorDailyHigh = request.security(
     syminfo.tickerid,
     "D",
     high[1],
     barmerge.gaps_off,
     barmerge.lookahead_off
)

priorDailyLow = request.security(
     syminfo.tickerid,
     "D",
     low[1],
     barmerge.gaps_off,
     barmerge.lookahead_off
)

//====================================================================
// LOWER TIMEFRAME DATA
//====================================================================

ema21 = ta.ema(close, ema21Length)

//====================================================================
// RETEST ZONE
//====================================================================

zoneHigh = htf200Ema * (1 + zonePercent)
zoneLow  = htf200Ema * (1 - zonePercent)

inRetestZone = high >= zoneLow and low <= zoneHigh

//====================================================================
// 200 EMA SLOPE FILTER
//====================================================================

emaSlopeFlatOrRising = htf200Ema >= htf200Ema[slopeLookback]
slopeFilterOk = useSlopeFilter ? emaSlopeFlatOrRising : true

//====================================================================
// DAILY RECLAIM FILTER
//====================================================================

currentDailyReclaim = htfClose > htf200Ema
confirmedDailyReclaim = priorConfirmedDailyClose > priorConfirmedDailyEma

dailyReclaimOk = useDailyReclaim ? (useConfirmedDaily ? confirmedDailyReclaim : currentDailyReclaim) : true

//====================================================================
// VOLUME FILTER
//====================================================================

volumeOnTf = request.security(
     syminfo.tickerid,
     volumeTf,
     volume,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

avgVolumeOnTf = request.security(
     syminfo.tickerid,
     volumeTf,
     ta.sma(volume, volumeLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

volumeOk = useVolumeFilter ? volumeOnTf > avgVolumeOnTf * volumeMultiplier : true

//====================================================================
// MARKET ALIGNMENT FILTER
//====================================================================

marketClose = request.security(
     marketSymbol,
     "D",
     close,
     barmerge.gaps_off,
     barmerge.lookahead_off
)

marketEma = request.security(
     marketSymbol,
     "D",
     ta.ema(close, marketEmaLength),
     barmerge.gaps_off,
     barmerge.lookahead_off
)

marketOk = useMarketFilter ? marketClose > marketEma : true

//====================================================================
// CHOP / WHIPSAW FILTER
//====================================================================

crossAbove200 = ta.crossover(close, htf200Ema)
crossBelow200 = ta.crossunder(close, htf200Ema)

crossEvent = crossAbove200 or crossBelow200 ? 1.0 : 0.0
crossCount = math.sum(crossEvent, chopLookback)

chopOk = useChopFilter ? crossCount <= maxCrossesAllowed : true

//====================================================================
// BREAK BELOW 200 EMA STATE TRACKING
//====================================================================

breakBelow200 = ta.crossunder(close, htf200Ema)

var int breakBar = na
var bool retestSeen = false
var float breakdownLow = na
var float retestLow = na
var float lastStopLevel = na

if breakBelow200
    breakBar := bar_index
    retestSeen := false
    breakdownLow := low
    retestLow := na

breakActive = not na(breakBar) and bar_index - breakBar <= breakLookback

if breakActive
    breakdownLow := na(breakdownLow) ? low : math.min(breakdownLow, low)

if breakActive and bar_index > breakBar and inRetestZone
    retestSeen := true
    retestLow := na(retestLow) ? low : math.min(retestLow, low)

if not breakActive
    breakBar := na
    retestSeen := false
    breakdownLow := na
    retestLow := na

//====================================================================
// BULLISH CONFIRMATION LOGIC
//====================================================================

bullishCandle = close > open

bullishEngulfing =
     close > open and
     close[1] < open[1] and
     close >= open[1] and
     open <= close[1]

breakPreviousHigh =
     close > high[1] and
     close > open

higherHigh = high > high[1]
higherLow  = low > low[1]

closeBackAbove200 = close > htf200Ema

confirmation =
     confirmMode == "Close Back Above 200 EMA" ? bullishCandle and closeBackAbove200 :
     confirmMode == "Bullish Engulfing + Above 200 EMA" ? bullishEngulfing and closeBackAbove200 :
     confirmMode == "Break Previous Candle High + Above 200 EMA" ? breakPreviousHigh and closeBackAbove200 :
     confirmMode == "Higher High + Higher Low + Above 200 EMA" ? higherHigh and higherLow and closeBackAbove200 :
     false

ema21Ok = use21Filter ? close > ema21 : true

//====================================================================
// FILTERED SIGNAL
//====================================================================

baseSignal =
     breakActive and
     retestSeen and
     confirmation

allRequiredFiltersOk =
     slopeFilterOk and
     dailyReclaimOk and
     volumeOk and
     marketOk and
     ema21Ok and
     chopOk

bullishSignal = baseSignal and allRequiredFiltersOk

//====================================================================
// SIGNAL GRADING
//====================================================================

score = 0

score += closeBackAbove200 ? 1 : 0
score += retestSeen ? 1 : 0
score += emaSlopeFlatOrRising ? 1 : 0
score += volumeOnTf > avgVolumeOnTf * volumeMultiplier ? 1 : 0
score += marketClose > marketEma ? 1 : 0
score += close > ema21 ? 1 : 0
score += crossCount <= maxCrossesAllowed ? 1 : 0

signalGrade =
     score >= 6 ? "A+" :
     score >= 4 ? "B" :
     "C"

//====================================================================
// STOP LEVEL
//====================================================================

suggestedStop = na(retestLow) ? breakdownLow : math.min(retestLow, breakdownLow)

if bullishSignal
    lastStopLevel := suggestedStop

// Reset setup after signal
if bullishSignal
    breakBar := na
    retestSeen := false
    breakdownLow := na
    retestLow := na

//====================================================================
// PLOTS
//====================================================================

plot(
     show200Ema ? htf200Ema : na,
     title="Daily 200 EMA",
     color=color.orange,
     linewidth=3
)

plot(
     show21Ema ? ema21 : na,
     title="Lower Timeframe 21 EMA",
     color=color.aqua,
     linewidth=1
)

zoneHighPlot = plot(
     showRetestZone ? zoneHigh : na,
     title="200 EMA Retest Zone High",
     color=color.new(color.orange, 75)
)

zoneLowPlot = plot(
     showRetestZone ? zoneLow : na,
     title="200 EMA Retest Zone Low",
     color=color.new(color.orange, 75)
)

fill(
     zoneHighPlot,
     zoneLowPlot,
     color=color.new(color.orange, 90),
     title="200 EMA Retest Zone"
)

plot(
     showDailyTargets ? priorDailyHigh : na,
     title="Prior Daily High / Upside Liquidity",
     color=color.new(color.green, 20),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showDailyTargets ? priorDailyLow : na,
     title="Prior Daily Low / Downside Liquidity",
     color=color.new(color.red, 20),
     linewidth=1,
     style=plot.style_linebr
)

plot(
     showStopLine ? lastStopLevel : na,
     title="Suggested Stop Level",
     color=color.red,
     linewidth=2,
     style=plot.style_linebr
)

//====================================================================
// VISUAL SIGNALS
//====================================================================

plotshape(
     breakBelow200,
     title="Break Below 200 EMA",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.small,
     text="Break\n200"
)

plotshape(
     breakActive and inRetestZone and not bullishSignal,
     title="Retest Zone",
     style=shape.circle,
     location=location.belowbar,
     color=color.yellow,
     size=size.tiny,
     text="Retest"
)

plotshape(
     bullishSignal and signalGrade == "A+",
     title="A+ Bullish 200 EMA Reclaim",
     style=shape.labelup,
     location=location.belowbar,
     color=color.lime,
     textcolor=color.black,
     size=size.normal,
     text="A+\nCALL"
)

plotshape(
     bullishSignal and signalGrade == "B",
     title="B Bullish 200 EMA Reclaim",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.normal,
     text="B\nCALL"
)

plotshape(
     bullishSignal and signalGrade == "C",
     title="C Bullish 200 EMA Reclaim",
     style=shape.labelup,
     location=location.belowbar,
     color=color.gray,
     textcolor=color.white,
     size=size.normal,
     text="C\nWATCH"
)

bgcolor(
     showBackground and breakActive and retestSeen ? color.new(color.green, 88) : na,
     title="Active 200 EMA Setup Background"
)

//====================================================================
// FILTER STATUS TABLE
//====================================================================

var table statusTable = table.new(position.top_right, 2, 9, border_width=1)

// Table colors
headerBg  = color.new(color.white, 0)
labelBg   = color.new(color.silver, 10)
okBg      = color.new(color.lime, 20)
failBg    = color.new(color.red, 20)
warnBg    = color.new(color.yellow, 10)
neutralBg = color.new(color.silver, 20)

if showTable and barstate.islast
    table.cell(statusTable, 0, 0, "Filter", text_color=color.black, bgcolor=headerBg)
    table.cell(statusTable, 1, 0, "Status", text_color=color.black, bgcolor=headerBg)

    table.cell(statusTable, 0, 1, "200 EMA Slope", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 1, slopeFilterOk ? "OK" : "Fail", text_color=color.black, bgcolor=slopeFilterOk ? okBg : failBg)

    table.cell(statusTable, 0, 2, "Daily Reclaim", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 2, dailyReclaimOk ? "OK" : "Fail", text_color=color.black, bgcolor=dailyReclaimOk ? okBg : failBg)

    table.cell(statusTable, 0, 3, "Volume", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 3, volumeOk ? "OK" : "Fail", text_color=color.black, bgcolor=volumeOk ? okBg : failBg)

    table.cell(statusTable, 0, 4, "Market", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 4, marketOk ? "OK" : "Fail", text_color=color.black, bgcolor=marketOk ? okBg : failBg)

    table.cell(statusTable, 0, 5, "21 EMA", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 5, ema21Ok ? "OK" : "Fail", text_color=color.black, bgcolor=ema21Ok ? okBg : failBg)

    table.cell(statusTable, 0, 6, "Chop", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 6, chopOk ? "OK" : "Fail", text_color=color.black, bgcolor=chopOk ? okBg : failBg)

    table.cell(statusTable, 0, 7, "Setup Active", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 7, breakActive ? "Yes" : "No", text_color=color.black, bgcolor=breakActive ? warnBg : neutralBg)

    table.cell(statusTable, 0, 8, "Grade", text_color=color.black, bgcolor=labelBg)
    table.cell(statusTable, 1, 8, signalGrade, text_color=color.black, bgcolor=score >= 6 ? okBg : score >= 4 ? warnBg : neutralBg)

//====================================================================
// ALERTS
//====================================================================

alertcondition(
     breakBelow200,
     title="Break Below Daily 200 EMA",
     message="Price broke below the higher timeframe 200 EMA."
)

alertcondition(
     breakActive and inRetestZone,
     title="Retest Of Daily 200 EMA Zone",
     message="Price is retesting the higher timeframe 200 EMA zone."
)

alertcondition(
     bullishSignal,
     title="Bullish 200 EMA Break-Retest-Reclaim Signal",
     message="Bullish 200 EMA reclaim swing setup detected."
)
````
