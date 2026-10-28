# Minervini Pro System V3 - Technical Entry Exit

- url: https://www.tradingview.com/script/b18pSTyQ-Minervini-Pro-System-V3-Technical-Entry-Exit/
- type: indicator
- pine_id: PUB;a47de0323ec049869a0cff1cd410c420
- version: 2.0

## Description

Below is a **step-by-step user manual** for using your **Minervini Pro System V3 indicator** in TradingView.

# Minervini Pro System V3 — How to Use

> **Important:** This indicator is a **technical screening and trade-management assistant**. It does **not guarantee profit**. Use it with fundamentals, market context, position sizing, and stop-loss discipline.

***

# 1. Correct Chart Setup

Before using the indicator, always set:

## Timeframe

Use:

```text
1D / Daily chart
```

This is very important because the indicator is based on:

*   50 DMA
*   150 DMA
*   200 DMA
*   52-week high/low
*   Daily volume
*   Daily breakout levels

Do **not** use it mainly on 5-min, 15-min, or hourly charts unless you intentionally want short-term signals.

***

## Chart Type

Use:

```text
Candlestick chart
```

Also keep **Volume** visible at the bottom.

***

# 2. What the Lines Mean

The indicator plots these lines:

## Blue Line — 50 DMA

This is the short-to-medium-term trend.

A strong stock should usually stay above this line.

***

## Orange Line — 150 DMA

This is the intermediate trend.

It helps confirm that the stock is not just having a short-term bounce.

***

## Red Line — 200 DMA

This is the long-term trend.

A stock above a rising 200 DMA is generally in a stronger long-term structure.

***

## Purple Line — 21 EMA

This is a shorter-term trend guide.

It helps identify weakening momentum after entry.

***

## Green Line — Pivot / Breakout Level

This is the recent high/pivot area.

A breakout above this level is important.

***

## Yellow Line — Active Trailing Stop

This appears after an entry signal.

It acts as a technical trailing stop reference.

***

# 3. Dashboard Meaning

The dashboard gives a checklist.

## Trend Template

Shows:

```text
PASS / FAIL
```

### PASS means:

*   Price is above 50, 150, and 200 DMA
*   50 DMA is above 150 and 200 DMA
*   150 DMA is above 200 DMA
*   200 DMA is rising
*   Price is near its 52-week high
*   Price is well above its 52-week low

### How to use:

```text
FAIL = Ignore or wait
PASS = Continue analysis
```

***

## RS vs Index

Shows:

```text
STRONG / WEAK
```

This compares the stock against Nifty.

### How to use:

```text
STRONG = stock is outperforming the market
WEAK = avoid or lower priority
```

Minervini-style trading prefers **leaders**, not laggards.

***

## VCP Tightness

Shows:

```text
YES / NO
```

This checks whether volatility is contracting.

### YES means:

The stock may be forming a tighter base or VCP-style setup.

***

## Volume Dry-Up

Shows:

```text
YES / NO
```

This checks whether recent volume is reducing.

### Good sign:

```text
Price tightens while volume reduces
```

This can mean selling pressure is reducing.

***

## Not Extended

Shows:

```text
YES / NO
```

This checks if price is not too far above the 50 DMA.

### How to use:

```text
YES = better risk/reward
NO = stock may be extended; wait
```

***

## Market Health

Shows:

```text
OK / BAD
```

This checks whether Nifty is in a healthy trend.

### If Market Health is BAD:

Be careful with new trades. Breakouts fail more often in weak markets.

***

## Weekly Trend

Shows:

```text
OK / BAD
```

This checks if the weekly trend supports the daily setup.

A good daily setup is stronger when weekly trend is also OK.

***

## Breakout

Shows:

```text
YES / NO
```

### YES means:

Price is breaking above the recent pivot/high.

For action, you ideally want:

```text
Breakout YES + Volume confirmation + Strong close
```

***

## Score

Shows:

```text
0 to 100
```

### Interpretation:

```text
80+     = Excellent technical setup
65–79   = Good watchlist candidate
Below 65 = Weak / wait
```

Do not trade only because of score. Use it as a ranking tool.

***

## Trade State

Shows:

```text
IN TRADE / NO TRADE
```

This is the indicator’s internal trade-state simulation after an entry signal.

***

## Entry Type

Shows:

```text
Early VCP
Breakout
Retest
None
```

This tells you which type of entry signal was triggered.

***

# 4. Entry Signals

The indicator gives three types of entries.

***

## E-VCP — Early VCP Entry

Shown as:

```text
E-VCP
```

Usually appears as a yellow circle.

### Meaning:

The stock is tightening and starting to move before the main breakout.

### Use for:

*   Aggressive entry
*   Smaller stop-loss
*   Early positioning

### Be careful:

This has a higher chance of false signals.

Use only if:

```text
Trend Template = PASS
RS = STRONG
VCP Tightness = YES
Volume Dry-Up = YES
Not Extended = YES
```

***

## BO — Breakout Entry

Shown as:

```text
BO
```

Usually appears as a green triangle.

### Meaning:

Price has broken above the pivot/resistance level with volume confirmation.

### This is the most important signal.

For now, this should be your main focus.

Use only if:

```text
Score is 80+
Volume is strong
Market Health is OK
Stop-loss is manageable
```

***

## RT — Retest Entry

Shown as:

```text
RT
```

Usually appears as a teal diamond.

### Meaning:

The stock broke out earlier and is now retesting the pivot area.

### Use for:

*   Conservative entry
*   Avoiding chase
*   Entering after confirmation

Good retest behavior:

```text
Pullback has lower volume
Price holds pivot
Price stays above 50 DMA
Stock resumes upward
```

***

# 5. Exit Signal

The indicator shows:

```text
EXIT
```

Usually as a red triangle down.

### EXIT can appear when:

*   Price breaks the active trailing stop
*   Price falls below pivot and 50 DMA
*   Price weakens below 21 EMA
*   A high-volume bearish candle appears

### How to use:

If you are in the trade, treat EXIT seriously.

At minimum:

```text
Review position immediately
```

If the setup has clearly failed:

```text
Exit or reduce position as per your trading plan
```

***

# 6. Best Workflow

Use the indicator in this sequence.

***

## Step 1: Open the stock on Daily chart

Check only liquid NSE stocks first.

Avoid very illiquid stocks.

***

## Step 2: Check Dashboard

Look for:

```text
Trend Template = PASS
RS vs Index = STRONG
VCP Tightness = YES
Not Extended = YES
Market Health = OK
Weekly Trend = OK
Score = 80+
```

***

## Step 3: Wait for Entry Signal

Preferred priority:

```text
BO = best beginner signal
RT = conservative signal
E-VCP = advanced/aggressive signal
```

For now, focus mainly on:

```text
BO with Score 80+
```

***

## Step 4: Check Stop-Loss

Before entering, ask:

```text
Where is my stop-loss?
How much will I lose if wrong?
Is risk below 7–8%?
```

If the stop-loss is too far, skip the trade.

***

## Step 5: Manage the Trade

After entry:

*   Watch the yellow trailing stop line
*   Watch the green pivot line
*   Watch the 21 EMA
*   Watch for EXIT signal
*   Avoid averaging down

***

# 7. Simple Decision Rules

Use these rules:

```text
Trend Template FAIL = Ignore
Trend Template PASS only = Watch
Score 65–79 = Watchlist
Score 80+ = High priority
BO + Score 80+ + Volume = Possible trade
EXIT = Review / protect capital
```

***

# 8. Best Beginner Rule

For now, use this simple rule:

```text
Only consider BO signals when:
Trend Template = PASS
RS = STRONG
Score = 80+
Market Health = OK
Not Extended = YES
```

Ignore Early VCP until you are more comfortable.

***

# 9. Manual Checks Before Trading

The indicator checks technicals only.

Before entering, manually check:

```text
Quarterly profit growth
Sales growth
EPS growth
Operating margin trend
ROE / ROCE
Debt level
Promoter pledge
Cash flow
Sector strength
Recent news or catalyst
```

Avoid technically good stocks with poor fundamentals unless you are trading very short-term with strict risk.

***

# 10. Dashboard Position Setting

You added a setting for dashboard position.

To change it:

1.  Click indicator settings
2.  Go to **Inputs**
3.  Find:

```text
Dashboard Position
```

4.  Choose:

```text
Top Center
Top Right
```

Recommended:

```text
Top Center
```

***

# 11. Recommended Settings

## Balanced Settings

Use this first:

```text
Pivot Lookback: 20
Average Volume Length: 50
Breakout Volume Multiplier: 1.5
Early VCP Volume Multiplier: 1.1
ATR Length: 14
Max Extension From 50 DMA: 15
Stop Lookback: 8
Trailing Stop Lookback: 10
Market Filter: ON
Weekly Filter: ON
Dashboard Position: Top Center
```

***

## Conservative Settings

Use this if too many false signals appear:

```text
Pivot Lookback: 30
Breakout Volume Multiplier: 2.0
Max Extension From 50 DMA: 10
Stop Lookback: 10
Trailing Stop Lookback: 10
```

***

# 12. What to Expect

## Expect fewer good signals

Good Minervini-style setups are rare.

That is normal.

***

## Expect false breakouts

No indicator avoids all false breakouts.

That is why stop-loss is important.

***

## Expect better results in strong markets

When Nifty is healthy, breakouts work better.

When market health is bad, reduce risk.

***

# 13. Final Summary

Use the indicator like this:

```text
Dashboard = Quality checklist
Green/blue background = Technical strength
BO = Breakout entry
RT = Retest entry
E-VCP = Early/aggressive entry
Yellow line = Trailing stop reference
EXIT = Risk warning
Score = Setup quality ranking
```

Best possible setup:

```text
Trend Template PASS
RS STRONG
VCP Tightness YES
Volume Dry-Up YES
Not Extended YES
Market Health OK
Weekly Trend OK
Score 80+
BO signal
Good fundamentals
Manageable stop-loss
```

## Source Code

````pine
//@version=5
indicator("Minervini Pro System V3 - Technical Entry Exit", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// INPUTS
//====================================================
indexSymbol      = input.symbol("NSE:NIFTY", "Market Index for RS / Market Health")
pivotLen         = input.int(20, "Breakout Pivot Lookback", minval=10, maxval=80)
volLen           = input.int(50, "Average Volume Length", minval=10, maxval=200)
volMultiplier    = input.float(1.5, "Breakout Volume Multiplier", minval=1.0, step=0.1)
earlyVolMult     = input.float(1.1, "Early VCP Volume Multiplier", minval=0.5, step=0.1)

atrLen           = input.int(14, "ATR Length", minval=5, maxval=50)
tightShort       = input.int(20, "Short Tightness Lookback", minval=5, maxval=50)
tightLong        = input.int(60, "Long Tightness Lookback", minval=30, maxval=150)

maxExtension50   = input.float(15.0, "Max Extension From 50 DMA %", minval=3.0, step=0.5)
stopLookback     = input.int(8, "Initial Stop Swing Low Lookback", minval=3, maxval=30)
trailLookback    = input.int(10, "Trailing Stop Lookback", minval=3, maxval=30)

retestWindow     = input.int(8, "Retest Window After Breakout", minval=2, maxval=30)
retestTolerance  = input.float(2.0, "Retest Tolerance % Around Pivot", minval=0.5, step=0.5)

useMarketFilter  = input.bool(true, "Use Market Health Filter")
useWeeklyFilter  = input.bool(true, "Use Weekly Trend Filter")
showDashboard    = input.bool(true, "Show Dashboard")
showScore        = input.bool(true, "Show Setup Score")

dashboardPosition = input.string("Top Center", "Dashboard Position", options=["Top Right", "Top Center", "Bottom Right", "Bottom Center"])
dashPos = dashboardPosition == "Top Right" ? position.top_right : dashboardPosition == "Top Center" ? position.top_center : dashboardPosition == "Bottom Right" ? position.bottom_right : position.bottom_center

//====================================================
// HELPER
//====================================================
btoi(x) =>
    x ? 1 : 0

//====================================================
// MOVING AVERAGES
//====================================================
sma50  = ta.sma(close, 50)
sma150 = ta.sma(close, 150)
sma200 = ta.sma(close, 200)
ema21  = ta.ema(close, 21)

plot(sma50,  title="50 DMA",  color=color.blue, linewidth=2)
plot(sma150, title="150 DMA", color=color.orange, linewidth=2)
plot(sma200, title="200 DMA", color=color.red, linewidth=2)
plot(ema21,  title="21 EMA",  color=color.purple, linewidth=1)

//====================================================
// TREND TEMPLATE
//====================================================
tt1 = close > sma150 and close > sma200
tt2 = sma150 > sma200
tt3 = sma200 > sma200[20]
tt4 = sma50 > sma150 and sma50 > sma200
tt5 = close > sma50

hh52 = ta.highest(high, 252)
ll52 = ta.lowest(low, 252)

tt6 = close >= hh52 * 0.75
tt7 = close >= ll52 * 1.30

trendPass = tt1 and tt2 and tt3 and tt4 and tt5 and tt6 and tt7

//====================================================
// MARKET HEALTH
//====================================================
idxClose  = request.security(indexSymbol, timeframe.period, close)
idxSma50  = request.security(indexSymbol, timeframe.period, ta.sma(close, 50))
idxSma200 = request.security(indexSymbol, timeframe.period, ta.sma(close, 200))

marketHealthy = idxClose > idxSma50 and idxClose > idxSma200 and idxSma50 > idxSma200
marketOK = useMarketFilter ? marketHealthy : true

//====================================================
// RELATIVE STRENGTH VS INDEX
//====================================================
rsLine = close / idxClose
rsMA50 = ta.sma(rsLine, 50)
rsStrong = rsLine > rsMA50 and rsLine > rsLine[20]

//====================================================
// WEEKLY CONFIRMATION
//====================================================
wClose = request.security(syminfo.tickerid, "W", close)
wSma10 = request.security(syminfo.tickerid, "W", ta.sma(close, 10))
wSma30 = request.security(syminfo.tickerid, "W", ta.sma(close, 30))

weeklyStrong = wClose > wSma10 and wSma10 > wSma30
weeklyOK = useWeeklyFilter ? weeklyStrong : true

//====================================================
// VCP / TIGHTNESS APPROXIMATION
//====================================================
rangeShort = ta.highest(high, tightShort) - ta.lowest(low, tightShort)
rangeLong  = ta.highest(high, tightLong) - ta.lowest(low, tightLong)

rangeContracting = rangeShort < rangeLong * 0.55

atrPercent = ta.atr(atrLen) / close * 100
atrAvg = ta.sma(atrPercent, 50)
atrContracting = atrPercent < atrAvg

closeTightness = math.abs(close - close[1]) / close * 100
avgCloseTightness = ta.sma(closeTightness, 20)
tightCloses = closeTightness < avgCloseTightness

vcpTight = rangeContracting and atrContracting and tightCloses

//====================================================
// VOLUME CONDITIONS
//====================================================
avgVol = ta.sma(volume, volLen)
volumeBreakout = volume > avgVol * volMultiplier
volumeEarly = volume > avgVol * earlyVolMult

volumeDryUp = ta.sma(volume, 10) < ta.sma(volume, 50)

//====================================================
// EXTENSION CONTROL
//====================================================
extensionFrom50 = (close - sma50) / sma50 * 100
notExtended = extensionFrom50 <= maxExtension50 and extensionFrom50 > -3

//====================================================
// PIVOT / BREAKOUT LEVEL
//====================================================
pivotHigh = ta.highest(high[1], pivotLen)
breakoutNow = close > pivotHigh and close > open
strongClose = close > low + (high - low) * 0.60

plot(pivotHigh, title="Pivot / Breakout Level", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)

//====================================================
// BASE PRO CANDIDATE
//====================================================
proCandidate = trendPass and rsStrong and vcpTight and notExtended and marketOK and weeklyOK

//====================================================
// ENTRY TYPES
//====================================================

// 1. Early VCP Entry
earlyTriggerLevel = ta.highest(high[1], 5)
earlyVCPEntry = proCandidate and close > earlyTriggerLevel and volumeEarly and volumeDryUp[1]

// 2. Classic Breakout Entry
breakoutEntry = proCandidate and breakoutNow and volumeBreakout and strongClose

// 3. Retest Entry
recentBreakout = ta.barssince(breakoutEntry) <= retestWindow
nearPivot = low <= pivotHigh * (1 + retestTolerance / 100) and close >= pivotHigh * (1 - retestTolerance / 100)
retestEntry = proCandidate and recentBreakout and nearPivot and close > sma50 and close > open

// Combined Entry
entrySignalRaw = earlyVCPEntry or breakoutEntry or retestEntry

//====================================================
// TRADE STATE SIMULATION
//====================================================
var bool inTrade = false
var float entryPrice = na
var float initialStop = na
var float activeStop = na
var float activePivot = na
var string entryType = "None"

newEntry = entrySignalRaw and not inTrade

swingStop = ta.lowest(low, stopLookback)
trailCandidate = ta.lowest(low, trailLookback)

if newEntry
    inTrade := true
    entryPrice := close
    initialStop := swingStop
    activeStop := swingStop
    activePivot := pivotHigh
    entryType := earlyVCPEntry ? "Early VCP" : breakoutEntry ? "Breakout" : "Retest"

if inTrade
    activeStop := math.max(activeStop, trailCandidate)

//====================================================
// EXIT CONDITIONS
//====================================================
exitStop = inTrade and close < activeStop
exitBelowPivot = inTrade and close < activePivot and close < sma50
exitBelow21 = inTrade and close < ema21 and close < close[1]
exitDistribution = inTrade and close < open and volume > avgVol * 1.5 and close < close[1]

exitSignal = exitStop or exitBelowPivot or exitBelow21 or exitDistribution

if exitSignal
    inTrade := false
    entryPrice := na
    initialStop := na
    activeStop := na
    activePivot := na
    entryType := "None"

//====================================================
// RISK / REWARD INFO
//====================================================
riskPercent = newEntry and swingStop > 0 ? (close - swingStop) / close * 100 : na
riskOK = not na(riskPercent) ? riskPercent <= 8 : true

//====================================================
// SCORE
//====================================================
score = 0
score += trendPass ? 25 : 0
score += rsStrong ? 15 : 0
score += vcpTight ? 15 : 0
score += volumeDryUp ? 10 : 0
score += notExtended ? 10 : 0
score += marketOK ? 10 : 0
score += weeklyOK ? 10 : 0
score += breakoutNow ? 5 : 0

excellentSetup = score >= 80
goodSetup = score >= 65 and score < 80

//====================================================
// VISUAL BACKGROUNDS
//====================================================
bgcolor(trendPass ? color.new(color.green, 91) : na)
bgcolor(proCandidate ? color.new(color.blue, 88) : na)
bgcolor(excellentSetup ? color.new(color.lime, 88) : na)

//====================================================
// ENTRY / EXIT PLOTS
//====================================================
plotshape(earlyVCPEntry and not inTrade[1], title="Early VCP Entry", style=shape.circle, location=location.belowbar, color=color.yellow, size=size.small, text="E-VCP")
plotshape(breakoutEntry and not inTrade[1], title="Breakout Entry", style=shape.triangleup, location=location.abovebar, color=color.lime, size=size.normal, text="BO")
plotshape(retestEntry and not inTrade[1], title="Retest Entry", style=shape.diamond, location=location.belowbar, color=color.teal, size=size.small, text="RT")

plotshape(exitSignal, title="Exit Signal", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.normal, text="EXIT")

//====================================================
// STOP LINES
//====================================================
plot(inTrade ? activeStop : na, title="Active Trailing Stop", color=color.yellow, linewidth=2, style=plot.style_linebr)
plot(inTrade ? activePivot : na, title="Active Pivot", color=color.green, linewidth=1, style=plot.style_linebr)

//====================================================
// SCORE LABEL
//====================================================
plotshape(showScore and excellentSetup and not inTrade, title="Excellent Setup", style=shape.labelup, location=location.belowbar, color=color.green, text="A+", textcolor=color.white, size=size.tiny)
plotshape(showScore and goodSetup and not excellentSetup and not inTrade, title="Good Setup", style=shape.labelup, location=location.belowbar, color=color.blue, text="B+", textcolor=color.white, size=size.tiny)

//====================================================
// DASHBOARD
//====================================================
var table dash = table.new(dashPos, 2, 12, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Minervini V3", bgcolor=color.black, text_color=color.white)
    table.cell(dash, 1, 0, "Status", bgcolor=color.black, text_color=color.white)

    table.cell(dash, 0, 1, "Trend Template")
    table.cell(dash, 1, 1, trendPass ? "PASS" : "FAIL", text_color=trendPass ? color.lime : color.red)

    table.cell(dash, 0, 2, "RS vs Index")
    table.cell(dash, 1, 2, rsStrong ? "STRONG" : "WEAK", text_color=rsStrong ? color.lime : color.red)

    table.cell(dash, 0, 3, "VCP Tightness")
    table.cell(dash, 1, 3, vcpTight ? "YES" : "NO", text_color=vcpTight ? color.lime : color.red)

    table.cell(dash, 0, 4, "Volume Dry-Up")
    table.cell(dash, 1, 4, volumeDryUp ? "YES" : "NO", text_color=volumeDryUp ? color.lime : color.red)

    table.cell(dash, 0, 5, "Not Extended")
    table.cell(dash, 1, 5, notExtended ? "YES" : "NO", text_color=notExtended ? color.lime : color.red)

    table.cell(dash, 0, 6, "Market Health")
    table.cell(dash, 1, 6, marketOK ? "OK" : "BAD", text_color=marketOK ? color.lime : color.red)

    table.cell(dash, 0, 7, "Weekly Trend")
    table.cell(dash, 1, 7, weeklyOK ? "OK" : "BAD", text_color=weeklyOK ? color.lime : color.red)

    table.cell(dash, 0, 8, "Breakout")
    table.cell(dash, 1, 8, breakoutNow ? "YES" : "NO", text_color=breakoutNow ? color.lime : color.gray)

    table.cell(dash, 0, 9, "Score")
    table.cell(dash, 1, 9, str.tostring(score) + "/100", text_color=score >= 80 ? color.lime : score >= 65 ? color.orange : color.red)

    table.cell(dash, 0, 10, "Trade State")
    table.cell(dash, 1, 10, inTrade ? "IN TRADE" : "NO TRADE", text_color=inTrade ? color.lime : color.gray)

    table.cell(dash, 0, 11, "Entry Type")
    table.cell(dash, 1, 11, entryType, text_color=color.white)

//====================================================
// ALERTS
//====================================================
alertcondition(earlyVCPEntry, title="Early VCP Entry", message="Early VCP entry signal")
alertcondition(breakoutEntry, title="Breakout Entry", message="Breakout entry signal")
alertcondition(retestEntry, title="Retest Entry", message="Retest entry signal")
alertcondition(exitSignal, title="Exit Signal", message="Exit signal triggered")
alertcondition(proCandidate, title="Pro Candidate", message="Minervini Pro Candidate")
alertcondition(excellentSetup, title="Excellent Setup Score", message="Excellent setup score 80+")
````
