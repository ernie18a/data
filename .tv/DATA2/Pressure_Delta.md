<!-- tradingview-pine-id: PUB;819219f9d89f45d3b50fb3c68b4a3308 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Pressure Delta

Source: https://www.tradingview.com/script/M2EkLc09-Pressure-Delta/

## Description

Pressure Delta is a volume-weighted candle-pressure indicator designed to identify directional participation and unusually strong buying or selling activity. It estimates buy and sell pressure from the candle's closing position and wick structure, distributes the candle's volume according to that estimated pressure, and then normalizes the resulting directional delta against average volume. The indicator combines Pressure, Relative Volume Delta, Relative Volume Percentage, Delta Spike and Relative Volume to distinguish ordinary price movement from high-volume directional events.

The most useful way to think about it is:
 Pressure = direction
 RVoL = participation
 RVoL Δ = directional participation
 RVoL % = imbalance
 Spike = unusualness

1. The core idea: estimating buy vs. sell pressure
The script first examines the candle:
high
low
open
close
volume
It calculates the candle's range:
candleRange = high - low
Then it asks two questions:
Where did the candle close within its range?
closeRatio = (close - low) / range
A close near the high gives a value close to 1.
A close near the low gives a value close to 0.
It also examines the wicks:
wickBias = (lowerWick - upperWick) / range
A relatively large lower wick contributes bullish pressure, while a relatively large upper wick contributes bearish pressure.
Those two components are then combined:
buyPressureRaw =
    60% × close location
  + 40% × wick bias
So the indicator gives 60% weight to where the candle closes and 40% weight to the wick structure.

2. Pressure
This is probably the most intuitive component.
pressureFinal = buyPressureRaw × 100
So it produces a number between approximately:
0% → 100%
Conceptually:
0–20% → very strong selling pressure
20–40% → bearish pressure
40–50% → mildly bearish/neutral
50–60% → mildly bullish
60–70% → bullish
70–85% → strong bullish pressure
85–100% → very strong bullish pressure
Your chart labels the last 7 candles with this value.
The colors reinforce the interpretation:
🟢 >60 = bullish
🟡 40–60 = neutral/mixed
🔴 <40 = bearish
Example
Suppose a candle:
opens at 100
trades to 95
trades to 108
closes at 107
The close is very near the high, and the candle may have a relatively meaningful lower wick.
The algorithm therefore might calculate something like:
Pressure = 82%
That means:
"Based on this candle's structure, the indicator estimates strong buying dominance."
It does not mean that exactly 82% of actual trades were buys.

3. Estimated buy and sell volume
The script takes the estimated pressure and applies it to the candle's volume:
buyVol  = buyPressureRaw × volume
sellVol = sellPressureRaw × volume
For example, imagine:
Volume = 1,000,000
and:
Pressure = 70%
The script estimates:
Buy volume  ≈ 700,000
Sell volume ≈ 300,000
Then:
netDelta = buyVol - sellVol
giving:
+400,000
Again, this is modelled volume, not exchange-reported buy/sell volume.

4. RVoL — Relative Volume
The script calculates a 20-bar average volume:
avgVol = ta.sma(volume, 20)
Then:
rvol = volume / avgVol
So if:
Current volume = 2,000,000
and:
20-bar average = 1,000,000
then:
RVoL = 2.0x
Meaning:
The current candle traded approximately twice the normal volume.
This is useful because pressure by itself isn't necessarily meaningful.
A candle showing 80% pressure on extremely low volume is very different from an 80% pressure candle occurring on 3× normal volume.

5. RVoL Δ — probably one of the most important readings
The script calculates:
rvolBuy  = buyVol / avgVol
rvolSell = sellVol / avgVol
and:
rvDelta = rvolBuy - rvolSell
This combines directional pressure + abnormal volume.
For example:
Scenario A
Pressure = 70%
RVoL = 1×
You might get a relatively modest positive RVoL Delta.
Scenario B
Pressure = 70%
RVoL = 3×
The RVoL Delta becomes much larger.
That's because the second candle has substantially more volume behind the estimated buying pressure.
So conceptually:
RVoL Δ attempts to measure the strength of directional volume pressure relative to normal volume.
Your alerts use thresholds of:
5, 6 and 7
So you're essentially saying:
"Alert me when estimated buying pressure is not only positive, but exceptionally large relative to normal volume."

6. RVoL %
This calculation is:
rvPct = (rvDelta / rvol) × 100
This is interesting because it normalizes the delta by total relative volume.
Mathematically, it effectively brings you back toward the buy/sell imbalance expressed as a percentage of volume.
For example:
+50%
means the estimated buying component is substantially greater than the estimated selling component.
The indicator colors:
>50% = green
0–50% = yellow
<0% = red
Your alerts are focused on 40% and 50%.

7. Spike
This is designed to identify unusually large directional-volume events.
The script calculates:
avgAbsDelta = ta.sma(math.abs(rvDelta), 5)
Then:
spike = rvDelta / avgAbsDelta
In other words:
How large is the current directional volume delta compared with the average magnitude of the last five deltas?
For example:
Spike = 0.5×
Normal-ish / relatively weak.
Spike = 1×
Around the recent average.
Spike = 2×
Approximately twice the recent average magnitude.
Spike = 4×
A potentially significant directional-volume event.
Your table highlights values above 2×.
One subtle point: because the denominator uses abs(rvDelta) but the numerator retains its sign, a large negative event can produce a strongly negative Spike.

---

## Source Code

````pine
//@version=6
indicator('Pressure Delta', overlay = true)
bgcolor(color.new(#000000, 20), title='Dark Background')

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
volLen = input.int(20, "Volume Avg Length", minval=1, maxval=200)

// ─────────────────────────────────────────────
// 1. VOLUME DELTA (Buy vs Sell volume estimate)
// ─────────────────────────────────────────────
candleRange  = high - low
safeRange    = candleRange == 0 ? 0.0001 : candleRange
closeRatio   = (close - low) / safeRange
upperWick    = high - math.max(open, close)
lowerWick    = math.min(open, close) - low
wickBias     = (lowerWick - upperWick) / safeRange
buyPressureRaw  = math.max(0, math.min(1, (closeRatio * 0.6) + ((wickBias + 1) / 2 * 0.4)))
sellPressureRaw = 1.0 - buyPressureRaw
buyVol  = buyPressureRaw * volume
sellVol = sellPressureRaw * volume
netDelta = buyVol - sellVol

//============================================================================
// VOLUME CALCULATIONS
//============================================================================
avgVol    = ta.sma(volume, volLen)
rvol      = volume / avgVol
rvolBuy   = buyVol / avgVol
rvolSell  = sellVol / avgVol
rvDelta   = rvolBuy - rvolSell
rvPct     = (rvDelta / rvol) * 100

// Spike: current delta vs its recent average magnitude
avgAbsDelta = ta.sma(math.abs(rvDelta), 5)
spike = avgAbsDelta != 0 ? rvDelta / avgAbsDelta : 0

// ─────────────────────────────────────────────
// 2. PRESSURE (0–100 buy dominance)
// ─────────────────────────────────────────────
pressureFinal = buyPressureRaw * 100

//============================================================================
// LABELS
//============================================================================
if barstate.islast
    for i = 0 to 6
        label.new(bar_index - i, high[i],
             str.tostring(pressureFinal[i], '#.##'),
             color     = color.new(color.black, 100),
             textcolor = pressureFinal[i] > 60 ? color.lime : pressureFinal[i] >= 40 ? color.yellow : color.red,
             size      = size.large,
             force_overlay = true)

//============================================================================
// TABLE
//============================================================================

var table infoTable = table.new(position.middle_right, 2, 10, bgcolor = #000000, border_width = 1, border_color = color.white)


table.cell(infoTable, 0, 1, "RVoL Δ", text_color = color.white, bgcolor = color.navy, text_size = size.large)
table.cell(infoTable, 1, 1, str.tostring(rvDelta, "#.##") + "x",
     text_color = color.white, bgcolor = rvDelta > 5 ?  color.teal : rvDelta > 0 ? color.blue : color.maroon, text_size = size.large)

table.cell(infoTable, 0, 0, "Pressure", text_color = color.white, bgcolor = color.navy, text_size = size.large)
table.cell(infoTable, 1, 0, str.tostring(pressureFinal, "#") + "%",
     text_color = color.white, bgcolor = pressureFinal > 60 ? color.teal : pressureFinal > 40 ? color.blue : color.maroon, text_size = size.large)

table.cell(infoTable, 0, 2, "RVoL %",  text_color = color.white,bgcolor = color.navy, text_size = size.large)
table.cell(infoTable, 1, 2, str.tostring(rvPct, "#") + '%',
    text_color = rvPct > 50 ? color.lime : rvPct >= 0 ? color.yellow : color.red, text_size = size.large)

table.cell(infoTable, 0, 3, "Spike",  text_color = color.white, bgcolor = color.navy, text_size = size.large)
table.cell(infoTable, 1, 3, str.tostring(spike, "#.#")  +'x',
    text_color = spike > 2 ? color.lime : spike >= 0 ? color.yellow : color.red, text_size = size.large)

table.cell(infoTable, 0, 5, "RVoL", text_color = color.white, bgcolor = color.navy, text_size = size.large)
table.cell(infoTable, 1, 5, str.tostring(rvol, "#.##") + "x",
     text_color = rvol > 2 ? color.lime : color.red, text_size = size.large)


//------------------------------------------
//   Alerts
//------------------------------------------ 

alertcondition(pressureFinal >= 80, "Buy - PRESS Above 80", "Buy Alert - Pressure is Above 80")
alertcondition(pressureFinal < 80, "Sell - PRESS Below 80", "Sell Alert - Pressure is Below 80")
alertcondition(pressureFinal >= 60, "Buy - PRESS Above 60", "Buy Alert - Pressure is Above 60")
alertcondition(pressureFinal < 60, "Sell - PRESS Below 60", "Sell Alert - Pressure is Below 60")
alertcondition(pressureFinal >= 70, "Buy - PRESS Above 70", "Buy Alert - Pressure is Above 70")
alertcondition(pressureFinal < 70, "Sell - PRESS Below 70", "Sell Alert - Pressure is Below 70")
alertcondition(pressureFinal >= 50, "Buy - PRESS Above 50", "Buy Alert - Pressure is Above 50")
alertcondition(pressureFinal < 50, "Sell - PRESS Below 50", "Sell Alert - Pressure is Below 50")
alertcondition(pressureFinal >= 20, "Buy - PRESS Above 20", "Buy Alert - Pressure is Above 20")
alertcondition(pressureFinal < 20, "Sell - PRESS Below 20", "Sell Alert - Pressure is Below 20")
alertcondition(pressureFinal >= 0, "Buy - PRESS Above 0", "Buy Alert - Pressure is Above 0")
alertcondition(pressureFinal < 0, "Sell - PRESS Below 0", "Sell Alert - Pressure is Below 0")

alertcondition(rvDelta >= 7, "Buy - RV_DEL > 7", "Buy Alert - RVoL Delta is Above 7")
alertcondition(rvDelta < 7, "Sell - RV_DEL < 7", "Sell Alert - RVoL Delta is Below 7")
alertcondition(rvDelta >= 6, "Buy - RV_DEL > 6", "Buy Alert - RVoL Delta is Above 6")
alertcondition(rvDelta < 6, "Sell - RV_DEL < 6", "Sell Alert - RVoL Delta is Below 6")
alertcondition(rvDelta >= 5, "Buy - RV_DEL > 5", "Buy Alert - RVoL Delta is Above 5")
alertcondition(rvDelta < 5,  "Sell - RV_DEL < 5", "Sell Alert - RVoL Delta is Below 5")

alertcondition(rvPct >= 50, "Buy - RV_PCT Above 50", "Buy Alert -  RVoL Percent is Above 50")
alertcondition(rvPct < 50, "Sell - RV_PCT Below 50", "Sell Alert - RVoL Percent is Below 50")
alertcondition(rvPct >= 40, "Buy - RV_PCT Above 40", "Buy Alert -  RVoL Percent is Above 40")
alertcondition(rvPct < 40, "Sell - RV_PCT Below 40", "Sell Alert - RVoL Percent is Below 40")
````
