# Stan Weinstein Stage & Base Counter/EMA/% Distance from EMA

- url: https://www.tradingview.com/script/0TNIVi9z-Stan-Weinstein-Stage-Base-Counter-EMA-Distance-from-EMA/
- type: indicator
- pine_id: PUB;cc88beee902d4e06ba3e6b05a6ca2a70
- version: 1.0

## Description

Stan Weinstein Stage & Base Counter/EMA/% Distance from EMA

## Source Code

````pine
//@version=6
indicator("Stan Weinstein Stage & Base Counter (Smooth EMA Edition)", overlay=true, max_lines_count=500, max_labels_count=500)

// --- Inputs ---
maLength       = input.int(30, title="Stage MA Length (Weinstein Uses 30)", minval=1)
breakPct       = input.float(20.0, title="Min % Rally to Qualify Next Base", minval=5.0)
volMult        = input.float(1.3, title="Volume Multiplier for Breakouts", minval=1.0)
tablePosInput  = input.string("Top Right", title="Dashboard Position", options=["Top Right", "Bottom Right", "Top Left", "Bottom Left", "Middle Right"])

// --- 1. Smoothed Native EMA Calculations ---
// If we are on a Daily chart, calculate natively for a perfect smooth line. Otherwise, fetch daily data.
ema10_raw  = ta.ema(close, 10)
ema21_raw  = ta.ema(close, 21)
ema55_raw  = ta.ema(close, 55)
ema200_raw = ta.ema(close, 200)

smoothEma10  = timeframe.isdaily ? ema10_raw  : request.security(syminfo.tickerid, "D", ema10_raw, gaps=barmerge.gaps_off)
smoothEma21  = timeframe.isdaily ? ema21_raw  : request.security(syminfo.tickerid, "D", ema21_raw, gaps=barmerge.gaps_off)
smoothEma55  = timeframe.isdaily ? ema55_raw  : request.security(syminfo.tickerid, "D", ema55_raw, gaps=barmerge.gaps_off)
smoothEma200 = timeframe.isdaily ? ema200_raw : request.security(syminfo.tickerid, "D", ema200_raw, gaps=barmerge.gaps_off)

// Plot the smoothed lines
plot(smoothEma10,  title="Daily EMA 10",  color=color.new(color.aqua, 30),   linewidth=1)
plot(smoothEma21,  title="Daily EMA 21",  color=color.new(color.yellow, 30), linewidth=1)
plot(smoothEma55,  title="Daily EMA 55",  color=color.new(color.orange, 30), linewidth=2)
plot(smoothEma200, title="Daily EMA 200", color=color.new(color.purple, 30), linewidth=3)

// --- 2. Structural Parameters for Weekly Timeframe ---
int lookbackPeriod = 20   
int minBaseWidth   = 3    

// --- 3. Moving Average & Slope Tracking ---
stageMA = ta.sma(close, maLength)
maSlope = stageMA - stageMA[1]

maUp4Weeks   = maSlope > 0 and maSlope[1] > 0 and maSlope[2] > 0 and maSlope[3] > 0
maDown4Weeks = maSlope < 0 and maSlope[1] < 0 and maSlope[2] < 0 and maSlope[3] < 0
maFlattening = ta.range(maSlope, 4) < ta.sma(high - low, lookbackPeriod) * 0.05 

plot(stageMA, title="30-MA Stage Line", color=(maSlope > 0 ? color.green : color.red), linewidth=3)

// --- 4. Fixed Structural Breakout/Breakdown Anchors ---
var float trackedHigh = na
var float trackedLow  = na
var int barsInStructure = 0

highestHigh = ta.highest(high, lookbackPeriod)
lowestLow   = ta.lowest(low, lookbackPeriod)
volMA       = ta.sma(volume, 20)

if ta.change(highestHigh) != 0 or na(trackedHigh)
    trackedHigh := highestHigh[1]
    barsInStructure := 0
else
    barsInStructure += 1

if ta.change(lowestLow) != 0 or na(trackedLow)
    trackedLow := lowestLow[1]

isUpsideBreakout   = ta.crossover(close, trackedHigh) and (volume > volMA * volMult) and (close > open)
isDownsideBreakdown = ta.crossunder(close, trackedLow)

// --- 5. TRUE WEINSTEIN STATE MACHINE ENGINE ---
var int marketStage = 1 
int prevStage = marketStage

if marketStage == 1
    if isUpsideBreakout and close > stageMA
        marketStage := 2
else if marketStage == 2
    if (close < stageMA and maFlattening) or (isDownsideBreakdown and maSlope <= 0)
        marketStage := 3
    else if isDownsideBreakdown and close < stageMA and maDown4Weeks
        marketStage := 4
else if marketStage == 3
    if isDownsideBreakdown or (close < stageMA and maDown4Weeks)
        marketStage := 4
    else if isUpsideBreakout and close > stageMA and maUp4Weeks
        marketStage := 2
else if marketStage == 4
    if close > stageMA and maFlattening and not maDown4Weeks
        marketStage := 1

bool stage1Trigger = (marketStage == 1) and (prevStage != 1)
bool stage2Trigger = (marketStage == 2) and (prevStage != 2)
bool stage3Trigger = (marketStage == 3) and (prevStage != 3)
bool stage4Trigger = (marketStage == 4) and (prevStage != 4)

// --- 6. Base Support & Resistance Tracking Channel ---
var line resLine = na
var line supLine = na

if ta.change(highestHigh) != 0
    resLine := line.new(x1=bar_index[lookbackPeriod], y1=highestHigh[1], x2=bar_index, y2=highestHigh[1], color=color.new(color.blue, 50), width=1, style=line.style_dashed)
else
    line.set_x2(resLine, bar_index)

if ta.change(lowestLow) != 0
    supLine := line.new(x1=bar_index[lookbackPeriod], y1=lowestLow[1], x2=bar_index, y2=lowestLow[1], color=color.new(color.orange, 50), width=1, style=line.style_dashed)
else
    line.set_x2(supLine, bar_index)

// --- 7. Refined Base Counting Engine ---
var int baseCount = 0
var float lastBreakoutPrice = 0.0
var int barsSinceLastBreakout = 0

barsSinceLastBreakout += 1

bool triggerBase1 = false
bool triggerBase2 = false
bool triggerBase3 = false
bool triggerBase4Plus = false
bool triggerBreakdown = false

if isUpsideBreakout and barsSinceLastBreakout >= minBaseWidth
    if stage2Trigger
        baseCount := 1
        lastBreakoutPrice := close
        barsSinceLastBreakout := 0
        triggerBase1 := true
    else if marketStage == 2 and baseCount > 0
        pctChangeFromLastBase = ((close - lastBreakoutPrice) / lastBreakoutPrice) * 100
        if pctChangeFromLastBase >= breakPct
            baseCount += 1
            lastBreakoutPrice := close
            barsSinceLastBreakout := 0
            if baseCount == 2
                triggerBase2 := true
            else if baseCount == 3
                triggerBase3 := true
            else if baseCount >= 4
                triggerBase4Plus := true

if stage4Trigger or isDownsideBreakdown
    if baseCount > 0
        triggerBreakdown := true
    baseCount := 0
    lastBreakoutPrice := 0.0
    barsSinceLastBreakout := 0

// --- 8. SMART PLOTSHAPE OVERLAP ENGINE ---
string belowCandleText = ""
color belowCandleColor = color.green

if stage2Trigger and triggerBase1
    belowCandleText := "S2/B1"
    belowCandleColor := color.green
else if stage1Trigger
    belowCandleText := "S1"
    belowCandleColor := color.gray
else if stage2Trigger
    belowCandleText := "S2"
    belowCandleColor := color.green
else if triggerBase1
    belowCandleText := "B1"
    belowCandleColor := color.green
else if triggerBase2
    belowCandleText := "B2"
    belowCandleColor := color.blue
else if triggerBase3
    belowCandleText := "B3"
    belowCandleColor := color.blue
else if triggerBase4Plus
    belowCandleText := "B4"
    belowCandleColor := color.orange

string aboveCandleText = ""
color aboveCandleColor = color.red

if stage4Trigger and triggerBreakdown
    aboveCandleText := "S4/BB"
    aboveCandleColor := color.red
else if stage3Trigger
    aboveCandleText := "S3"
    aboveCandleColor := color.orange
else if stage4Trigger
    aboveCandleText := "S4"
    aboveCandleColor := color.red
else if triggerBreakdown
    aboveCandleText := "BB"
    aboveCandleColor := color.red

// Hide labels completely if we leave the Weekly timeframe
bool allowLabels = timeframe.isweekly

bool showBullishLabel = allowLabels and (belowCandleText != "")
bool showBearishLabel = allowLabels and (aboveCandleText != "")

plotshape(showBullishLabel, title="Bullish Events", style=shape.triangleup, location=location.belowbar, color=belowCandleColor, size=size.small, text="")
plotshape(showBearishLabel, title="Bearish Events", style=shape.triangledown, location=location.abovebar, color=aboveCandleColor, size=size.small, text="")

if showBullishLabel
    label.new(bar_index, low, text=belowCandleText, style=label.style_none, textcolor=belowCandleColor, yloc=yloc.belowbar)

if showBearishLabel
    label.new(bar_index, high, text=aboveCandleText, style=label.style_none, textcolor=aboveCandleColor, yloc=yloc.abovebar)

// --- 9. Refactored Dashboard Calculations ---
weeklyStage     = timeframe.isweekly ? marketStage : request.security(syminfo.tickerid, "W", marketStage)
weeklyBaseCount = timeframe.isweekly ? baseCount   : request.security(syminfo.tickerid, "W", baseCount)

dClose   = timeframe.isdaily ? close       : request.security(syminfo.tickerid, "D", close)
dEma10   = smoothEma10
dEma21   = smoothEma21
dEma55   = smoothEma55
dEma200  = smoothEma200

dDist10  = ((dClose - dEma10) / dEma10) * 100
dDist21  = ((dClose - dEma21) / dEma21) * 100
dDist55  = ((dClose - dEma55) / dEma55) * 100
dDist200 = ((dClose - dEma200) / dEma200) * 100

// --- 10. Dashboard Positioning Logic ---
tablePosition = switch tablePosInput
    "Top Right"    => position.top_right
    "Bottom Right" => position.bottom_right
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    "Middle Right" => position.middle_right
    => position.top_right

var table displayTable = table.new(position = tablePosition, columns = 2, rows = 6, bgcolor = color.new(color.black, 100), border_width = 1, border_color=color.new(color.gray, 100))

if barstate.islast
    table.cell(displayTable, 0, 0, "Current Stage (Weekly)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))
    table.cell(displayTable, 1, 0, weeklyStage == 2 ? "STAGE 2 (Uptrend)" : weeklyStage == 4 ? "STAGE 4 (Markdown)" : weeklyStage == 3 ? "STAGE 3 (Distribution)" : "STAGE 1 (Accumulation)", bgcolor=weeklyStage == 2 ? color.new(color.green, 40) : weeklyStage == 4 ? color.new(color.red, 40) : weeklyStage == 3 ? color.new(color.orange, 40) : color.new(color.gray, 40), text_color=color.white, text_size=size.small)
    
    table.cell(displayTable, 0, 1, "Weekly Base Count", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))
    table.cell(displayTable, 1, 1, weeklyBaseCount == 0 ? "Reset / None" : "Base " + str.tostring(weeklyBaseCount), bgcolor=weeklyBaseCount >= 4 ? color.new(color.orange, 40) : color.new(color.blue, 40), text_color=color.white, text_size=size.small)
    
    table.cell(displayTable, 0, 2, "EMA 10 Distance (Daily %)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))
    table.cell(displayTable, 1, 2, str.tostring(dDist10, "#.##") + "%", bgcolor=dDist10 >= 0 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)
    
    table.cell(displayTable, 0, 3, "EMA 21 Distance (Daily %)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))
    table.cell(displayTable, 1, 3, str.tostring(dDist21, "#.##") + "%", bgcolor=dDist21 >= 0 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)
    
    table.cell(displayTable, 0, 4, "EMA 55 Distance (Daily %)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))
    table.cell(displayTable, 1, 4, str.tostring(dDist55, "#.##") + "%", bgcolor=dDist55 >= 0 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)
    
    table.cell(displayTable, 0, 5, "EMA 200 Distance (Daily %)", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 100))
    table.cell(displayTable, 1, 5, str.tostring(dDist200, "#.##") + "%", bgcolor=dDist200 >= 0 ? color.new(color.green, 60) : color.new(color.red, 60), text_color=color.white, text_size=size.small)
````
