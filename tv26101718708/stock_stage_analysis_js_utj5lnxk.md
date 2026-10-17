# Stock Stage Analysis [JS]

- url: https://www.tradingview.com/script/utj5LNxK/
- type: indicator
- pine_id: PUB;75de4927adc640059db90eba7ebf959f
- version: 1.0

## Description

This indicator classifies a stock into four stages:

Stage 1 — Basing / Consolidation
The stock is not in a clear uptrend or downtrend. The long-term moving average is relatively flat, the moving averages are compressed, and price is moving inside a defined range.

Stage 2 — Advancing / Accumulation
This is the preferred environment for long-side pullback setups. Price is above key moving averages, the moving averages are properly aligned, the slow MA is rising, and the stock is trading closer to its highs than its lows.

Stage 3 — Topping / Distribution
The stock recently had a strong Stage 2 structure, but the trend is losing quality. This is where late entries become dangerous and risk management becomes more important.

Stage 4 — Declining / Weakness
The stock is in a weak technical structure. Price is below key moving averages, the moving averages are negatively aligned, and the slow MA is falling. Long pullback setups should generally be avoided.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JS_TechTrading

//@version=6
indicator("Stock Stage Analysis [JS]", shorttitle="Stage Analysis [JS]", overlay=true, max_labels_count=100)

// ------------------------------------------------------------
// Stock Stage Analysis [JS]
// A visual stage analysis tool for identifying:
// Stage 1 = Basing / Consolidation
// Stage 2 = Advancing / Accumulation
// Stage 3 = Topping / Distribution
// Stage 4 = Declining / Weakness
//
// Designed as an educational trend filter for pullback and swing trading.
// ------------------------------------------------------------

// === Inputs ===
preset = input.string(
     "Daily 50/150/200",
     "Moving Average Preset",
     options=["Daily 50/150/200", "Weekly 10/30/40", "Custom"]
)

customFastLen = input.int(50, "Custom Fast MA", minval=1)
customMidLen  = input.int(150, "Custom Mid MA", minval=1)
customSlowLen = input.int(200, "Custom Slow MA", minval=1)

fastLen = preset == "Weekly 10/30/40" ? 10 : preset == "Daily 50/150/200" ? 50 : customFastLen
midLen  = preset == "Weekly 10/30/40" ? 30 : preset == "Daily 50/150/200" ? 150 : customMidLen
slowLen = preset == "Weekly 10/30/40" ? 40 : preset == "Daily 50/150/200" ? 200 : customSlowLen

slopeLookback     = input.int(21, "MA Slope Lookback", minval=1)
rangeLookback     = input.int(252, "52-Week Range Lookback", minval=50)
baseRangeLookback = input.int(80, "Stage 1 Base Range Lookback", minval=20)
recentStage2Bars  = input.int(100, "Recent Stage 2 Lookback", minval=20)

stage2MinScore = input.int(7, "Minimum Stage 2 Score", minval=1, maxval=8)
stage4MinScore = input.int(6, "Minimum Stage 4 Score", minval=1, maxval=8)

minAboveLowPct   = input.float(25.0, "Minimum % Above 52-Week Low", minval=0.0)
maxBelowHighPct  = input.float(25.0, "Maximum % Below 52-Week High", minval=0.0)
flatSlopePct     = input.float(3.0, "Flat MA Threshold %", minval=0.1)
baseRangeMaxPct  = input.float(35.0, "Maximum Base Range %", minval=1.0)

showMA      = input.bool(true, "Show Moving Averages")
showBg      = input.bool(true, "Color Background By Stage")
showTable   = input.bool(true, "Show Stage Interpretation Table")
showMarkers = input.bool(true, "Show Stage Change Markers")

// === Moving Averages ===
maFast = ta.sma(close, fastLen)
maMid  = ta.sma(close, midLen)
maSlow = ta.sma(close, slowLen)

// === 52-Week Range ===
rangeHigh = ta.highest(high, rangeLookback)
rangeLow  = ta.lowest(low, rangeLookback)

// === Base Range ===
baseHigh = ta.highest(high, baseRangeLookback)
baseLow  = ta.lowest(low, baseRangeLookback)
baseRangePct = not na(baseHigh) and not na(baseLow) and baseLow != 0 ? (baseHigh - baseLow) / baseLow * 100.0 : na

// === MA Slope Logic ===
maSlowRising = not na(maSlow[slopeLookback]) and maSlow > maSlow[slopeLookback]
maSlowFalling = not na(maSlow[slopeLookback]) and maSlow < maSlow[slopeLookback]

maSlowSlopePct = not na(maSlow[slopeLookback]) and maSlow[slopeLookback] != 0 ? math.abs(maSlow - maSlow[slopeLookback]) / maSlow[slopeLookback] * 100.0 : na
maSlowFlat = not na(maSlowSlopePct) and maSlowSlopePct <= flatSlopePct

maFastRising = not na(maFast[slopeLookback]) and maFast > maFast[slopeLookback]
maFastFalling = not na(maFast[slopeLookback]) and maFast < maFast[slopeLookback]

// === Stage 2 Criteria ===
c1 = not na(maMid) and close > maMid
c2 = not na(maSlow) and close > maSlow
c3 = not na(maMid) and not na(maSlow) and maMid > maSlow
c4 = maSlowRising
c5 = not na(maFast) and not na(maMid) and not na(maSlow) and maFast > maMid and maFast > maSlow
c6 = not na(maFast) and close > maFast
c7 = not na(rangeLow) and rangeLow != 0 and close >= rangeLow * (1.0 + minAboveLowPct / 100.0)
c8 = not na(rangeHigh) and close >= rangeHigh * (1.0 - maxBelowHighPct / 100.0)

stage2Score =
     (c1 ? 1 : 0) +
     (c2 ? 1 : 0) +
     (c3 ? 1 : 0) +
     (c4 ? 1 : 0) +
     (c5 ? 1 : 0) +
     (c6 ? 1 : 0) +
     (c7 ? 1 : 0) +
     (c8 ? 1 : 0)

isStage2 = stage2Score >= stage2MinScore

// === Stage 4 Criteria ===
w1 = not na(maFast) and close < maFast
w2 = not na(maMid) and close < maMid
w3 = not na(maSlow) and close < maSlow
w4 = not na(maFast) and not na(maMid) and maFast < maMid
w5 = not na(maMid) and not na(maSlow) and maMid < maSlow
w6 = maSlowFalling
w7 = not na(rangeHigh) and close <= rangeHigh * (1.0 - maxBelowHighPct / 100.0)
w8 = maFastFalling

stage4Score =
     (w1 ? 1 : 0) +
     (w2 ? 1 : 0) +
     (w3 ? 1 : 0) +
     (w4 ? 1 : 0) +
     (w5 ? 1 : 0) +
     (w6 ? 1 : 0) +
     (w7 ? 1 : 0) +
     (w8 ? 1 : 0)

isStage4 = stage4Score >= stage4MinScore

// === Stage 1 Logic: Base / Consolidation ===
maCompression = not na(maFast) and not na(maSlow) and close != 0 ? math.abs(maFast - maSlow) / close * 100.0 <= flatSlopePct * 2.0 : false
baseIsTight = not na(baseRangePct) and baseRangePct <= baseRangeMaxPct

isStage1 =
     not isStage2 and
     not isStage4 and
     maSlowFlat and
     maCompression and
     baseIsTight

// === Stage 3 Logic: Topping / Distribution ===
// Stage 3 often appears after a prior Stage 2 uptrend starts losing quality.
recentStage2Score = ta.highest(stage2Score, recentStage2Bars)
hadRecentStage2 = not na(recentStage2Score) and recentStage2Score >= stage2MinScore

isStage3 =
     not isStage2 and
     not isStage4 and
     not isStage1 and
     hadRecentStage2 and
     (
         close < maFast or
         maFastFalling or
         close < maMid
     ) and
     close > maSlow

// === Final Stage Classification ===
stageNumber =
     isStage2 ? 2 :
     isStage4 ? 4 :
     isStage3 ? 3 :
     isStage1 ? 1 :
     0

stageName =
     stageNumber == 1 ? "Stage 1" :
     stageNumber == 2 ? "Stage 2" :
     stageNumber == 3 ? "Stage 3" :
     stageNumber == 4 ? "Stage 4" :
     "Transition"

stageDescription =
     stageNumber == 1 ? "Basing / Consolidation" :
     stageNumber == 2 ? "Advancing / Accumulation" :
     stageNumber == 3 ? "Topping / Distribution" :
     stageNumber == 4 ? "Declining / Weakness" :
     "Neutral / Mixed Structure"

stageInterpretation =
     stageNumber == 1 ? "Watch for a possible transition, but avoid early assumptions." :
     stageNumber == 2 ? "Primary long-side environment. Pullbacks may become actionable." :
     stageNumber == 3 ? "Trend is losing quality. Manage risk and avoid late entries." :
     stageNumber == 4 ? "Weak structure. Avoid long pullback setups." :
     "No clear stage. Wait for a cleaner structure."

stageColor =
     stageNumber == 1 ? color.new(color.gray, 0) :
     stageNumber == 2 ? color.new(color.green, 0) :
     stageNumber == 3 ? color.new(color.orange, 0) :
     stageNumber == 4 ? color.new(color.red, 0) :
     color.new(color.blue, 0)

// === Plots ===
plot(showMA ? maFast : na, title="Fast MA", color=color.new(color.red, 0), linewidth=2)
plot(showMA ? maMid : na, title="Mid MA", color=color.new(color.purple, 0), linewidth=1)
plot(showMA ? maSlow : na, title="Slow MA", color=color.new(color.blue, 0), linewidth=2)

bgcolor(showBg ? color.new(stageColor, 90) : na)

// === Stage Change Markers ===
stageChanged = stageNumber != stageNumber[1]

plotshape(
     showMarkers and stageChanged and stageNumber == 2,
     title="Stage 2 Start",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.green, 0),
     text="S2",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showMarkers and stageChanged and stageNumber == 4,
     title="Stage 4 Start",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.red, 0),
     text="S4",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showMarkers and stageChanged and stageNumber == 3,
     title="Stage 3 Start",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.new(color.orange, 0),
     text="S3",
     textcolor=color.white,
     size=size.tiny
)

plotshape(
     showMarkers and stageChanged and stageNumber == 1,
     title="Stage 1 Start",
     style=shape.labelup,
     location=location.belowbar,
     color=color.new(color.gray, 0),
     text="S1",
     textcolor=color.white,
     size=size.tiny
)

// === Interpretation Table ===
var table stageTable = table.new(position.top_right, 2, 7, border_width=1)

if barstate.islast and showTable
    table.cell(stageTable, 0, 0, "Stage", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 0, stageName, text_color=color.white, bgcolor=stageColor)

    table.cell(stageTable, 0, 1, "Meaning", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 1, stageDescription, text_color=color.white, bgcolor=color.new(stageColor, 20))

    table.cell(stageTable, 0, 2, "Stage 2 Score", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 2, str.tostring(stage2Score) + " / 8", text_color=color.white, bgcolor=color.new(color.green, 50))

    table.cell(stageTable, 0, 3, "Stage 4 Score", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 3, str.tostring(stage4Score) + " / 8", text_color=color.white, bgcolor=color.new(color.red, 50))

    table.cell(stageTable, 0, 4, "Base Range", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 4, str.tostring(baseRangePct, "#.##") + "%", text_color=color.white, bgcolor=color.new(color.gray, 50))

    table.cell(stageTable, 0, 5, "Slow MA", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 5, maSlowRising ? "Rising" : maSlowFalling ? "Falling" : "Flat", text_color=color.white, bgcolor=color.new(color.blue, 50))

    table.cell(stageTable, 0, 6, "Interpretation", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(stageTable, 1, 6, stageInterpretation, text_color=color.white, bgcolor=color.new(stageColor, 30))

if barstate.islast and not showTable
    table.clear(stageTable, 0, 0)

// === Alerts ===
alertcondition(stageChanged and stageNumber == 2, title="New Stage 2", message="{{ticker}} entered Stage 2: Advancing / Accumulation.")
alertcondition(stageChanged and stageNumber == 3, title="New Stage 3", message="{{ticker}} entered Stage 3: Topping / Distribution.")
alertcondition(stageChanged and stageNumber == 4, title="New Stage 4", message="{{ticker}} entered Stage 4: Declining / Weakness.")
alertcondition(stageChanged and stageNumber == 1, title="New Stage 1", message="{{ticker}} entered Stage 1: Basing / Consolidation.")
````
