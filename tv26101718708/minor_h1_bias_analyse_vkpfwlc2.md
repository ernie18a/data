# Minor H1 BIAS Analyse

- url: https://www.tradingview.com/script/vkPFwlc2/
- type: indicator
- pine_id: PUB;8024ecbd349941368d951fb6d45ad6a7
- version: 1.0

## Description

## 1. Purpose of the Script

The **Minor H1 BIAS Analyse** is designed to determine the short-term directional market BIAS.

It does not provide entries. Instead, it evaluates several trend, momentum, and structure conditions and classifies the market as:

Long
Short
Neutral

The script should therefore be used as a directional filter together with a separate entry strategy.

---

## 2. Structure of the Minor BIAS

The Minor BIAS is based on five components:

EMA Trend
Price vs EMA
Current Candle Direction
Previous H1 High / Low Break
Market Structure Break

Each bullish condition adds one point to the Bull Score.

Each bearish condition adds one point to the Bear Score.

The maximum possible score is:

5 Long
5 Short

---

## 3. EMA Trend

The script uses two exponential moving averages:

Fast EMA: 20
Slow EMA: 50

If the Fast EMA is above the Slow EMA:

+1 Long

If the Fast EMA is below the Slow EMA:

+1 Short

This represents the basic trend direction.

---

## 4. ATR Neutral Buffer

The script uses an optional ATR buffer around the EMAs.

Default settings:

ATR Length: 14
ATR Multiplier: 0.20

The buffer creates a neutral zone around the EMAs.

Price must move clearly above or below both EMAs before the condition becomes bullish or bearish.

This helps filter small movements and market noise.

---

## 5. Price vs EMA

For a bullish condition, price must close above both EMAs plus the ATR Buffer.

Result:

+1 Long

For a bearish condition, price must close below both EMAs minus the ATR Buffer.

Result:

+1 Short

If price remains inside the buffer area:

No Score

The dashboard displays:

Inside Buffer

---

## 6. Current Candle Direction

The script also evaluates the current candle.

Bullish Candle:

Close above Open
+1 Long

Bearish Candle:

Close below Open
+1 Short

Doji:

No Score

This adds a simple momentum component to the BIAS.

---

## 7. Previous H1 High / Low Break

The script checks whether price closes above or below the previous candle.

Close above Previous High:

+1 Long

Close below Previous Low:

+1 Short

No Break:

No Score

This filter can be enabled or disabled in the settings.

The script uses the candle close, not only the wick.

---

## 8. Market Structure

The script also analyzes the previous market structure.

Default Lookback:

5 candles

It calculates:

Structure High
Structure Low

If price closes above the Structure High:

Bullish Structure Break
+1 Long

If price closes below the Structure Low:

Bearish Structure Break
+1 Short

If neither level is broken:

Range
No Score

---

## 9. Score System

The final Minor BIAS is calculated from the Bull Score and Bear Score.

Possible Long points:

EMA Trend
Price vs EMA
Bullish Candle
Previous High Break
Bullish Structure Break

Possible Short points:

EMA Trend
Price vs EMA
Bearish Candle
Previous Low Break
Bearish Structure Break

A minimum of three points is required.

---

## 10. Minor LONG

The Minor BIAS becomes Long when:

Bull Score is at least 3

and

Bull Score is greater than Bear Score.

Example:

Bull Score: 4
Bear Score: 1

Result:

MINOR LONG

---

## 11. Minor SHORT

The Minor BIAS becomes Short when:

Bear Score is at least 3

and

Bear Score is greater than Bull Score.

Example:

Bull Score: 1
Bear Score: 4

Result:

MINOR SHORT

---

## 12. Neutral

If neither side reaches the required conditions, the BIAS remains Neutral.

Example:

Bull Score: 2
Bear Score: 2

Result:

NEUTRAL

Neutral therefore represents an unclear or mixed market situation.

---

## 13. Dashboard

The dashboard shows the current state of every component.

It contains:

BIAS
EMA Trend
Price vs EMA
H1 Candle
Previous H1 Break
Structure
ATR Buffer

It also displays the current:

Bull Score / Bear Score

Example:

4 / 1

This makes it possible to understand why the current BIAS is Long, Short, or Neutral.

---

## 14. Chart Visualization

The script can display:

Fast EMA
Slow EMA
Previous H1 High / Low
Structure High / Low
BIAS Background
BIAS Label
Dashboard

Each visualization can be enabled or disabled individually.

The calculations continue to work even when the corresponding chart elements are hidden.

---

## 15. Alerts

The script includes alerts for:

Minor H1 LONG
Minor H1 SHORT
Minor H1 NEUTRAL

These can be used to receive a TradingView notification when the directional BIAS changes.

---

## 16. Meaning for Trading

The Minor BIAS should not be treated as an entry signal.

A simple trading rule would be:

**MINOR LONG:** Prefer Long setups.

**MINOR SHORT:** Prefer Short setups.

**NEUTRAL:** Wait for clearer conditions.

The actual entry should come from a separate trading setup.

---

## 17. BIAS Strength

The score can also be used to estimate the strength of the current direction.

3 Points:

Valid directional confirmation

4 Points:

Strong confirmation

5 Points:

Very strong alignment

For example:

5 / 0 Long

represents stronger bullish confirmation than:

3 / 2 Long

even though both are classified as MINOR LONG.

---

## 18. Important Timeframe Note

The current script uses the timeframe of the active chart.

That means the calculations are only truly based on H1 when the indicator is used on a **1-hour chart**.

If the script is placed on M5 or M1, the calculations also use M5 or M1 data.

For a true H1 BIAS that remains identical on every chart, the calculations would need to use fixed 60-minute data.

---

## 19. Conclusion

The **Minor H1 BIAS Analyse** is a score-based directional filter.

It combines:

Trend
Price Position
Momentum
Previous Candle Break
Market Structure

At least three confirmations are required for a directional BIAS.

The final result is:

MINOR LONG
MINOR SHORT
NEUTRAL

Its purpose is to identify the stronger short-term market direction before a separate entry setup is considered.

++ This was only used on NQ ++

## Source Code

````pine
//@version=6
indicator("Minor H1 BIAS Analyse", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// Minor H1 BIAS Settings
// ─────────────────────────────────────────────
minorGroup = "Minor H1 BIAS Settings"

fastLen = input.int(20, "H1 Fast EMA Length", minval=1, group=minorGroup)
slowLen = input.int(50, "H1 Slow EMA Length", minval=1, group=minorGroup)

useAtrBuffer = input.bool(true, "Use H1 ATR Neutral Buffer", group=minorGroup)
atrLen = input.int(14, "H1 ATR Length", minval=1, group=minorGroup)
atrMult = input.float(0.20, "ATR Buffer Multiplier", minval=0.0, step=0.05, group=minorGroup)

structureLen = input.int(5, "H1 Structure Lookback", minval=2, group=minorGroup)

usePrevHourBreak = input.bool(true, "Use Previous H1 High / Low Break", group=minorGroup)

// ─────────────────────────────────────────────
// Visualization Settings
// ─────────────────────────────────────────────
visualGroup = "Visualization Settings"

showEMAs = input.bool(true, "Show H1 EMAs", group=visualGroup)
showPrevHourLevels = input.bool(true, "Show Previous H1 High / Low", group=visualGroup)
showStructureLevels = input.bool(false, "Show Structure High / Low", group=visualGroup)
showBackground = input.bool(true, "Show Background BIAS", group=visualGroup)
showDashboard = input.bool(true, "Show Dashboard", group=visualGroup)

// ─────────────────────────────────────────────
// H1 Calculations
// ─────────────────────────────────────────────
emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

atr = ta.atr(atrLen)
buffer = useAtrBuffer ? atr * atrMult : 0.0

prevHigh = high[1]
prevLow = low[1]

// ─────────────────────────────────────────────
// Trend Conditions
// ─────────────────────────────────────────────
emaBull = emaFast > emaSlow
emaBear = emaFast < emaSlow

priceBull = close > emaFast + buffer and close > emaSlow + buffer
priceBear = close < emaFast - buffer and close < emaSlow - buffer

candleBull = close > open
candleBear = close < open

breakPrevHigh = close > prevHigh
breakPrevLow = close < prevLow

// ─────────────────────────────────────────────
// H1 Structure
// ─────────────────────────────────────────────
structureHigh = ta.highest(high[1], structureLen)
structureLow = ta.lowest(low[1], structureLen)

structureBull = close > structureHigh
structureBear = close < structureLow

// ─────────────────────────────────────────────
// Score System
// ─────────────────────────────────────────────
bullScore = 0
bearScore = 0

bullScore += emaBull ? 1 : 0
bullScore += priceBull ? 1 : 0
bullScore += candleBull ? 1 : 0
bullScore += usePrevHourBreak and breakPrevHigh ? 1 : 0
bullScore += structureBull ? 1 : 0

bearScore += emaBear ? 1 : 0
bearScore += priceBear ? 1 : 0
bearScore += candleBear ? 1 : 0
bearScore += usePrevHourBreak and breakPrevLow ? 1 : 0
bearScore += structureBear ? 1 : 0

minorLong = bullScore >= 3 and bullScore > bearScore
minorShort = bearScore >= 3 and bearScore > bullScore
minorNeutral = not minorLong and not minorShort

biasText = minorLong ? "MINOR LONG" : minorShort ? "MINOR SHORT" : "NEUTRAL"
biasColor = minorLong ? color.lime : minorShort ? color.red : color.gray

// ─────────────────────────────────────────────
// Plots
// ─────────────────────────────────────────────
plot(showEMAs ? emaFast : na, "H1 Fast EMA", color=color.orange, linewidth=2)
plot(showEMAs ? emaSlow : na, "H1 Slow EMA", color=color.blue, linewidth=2)

plot(showPrevHourLevels ? prevHigh : na, "Previous H1 High", color=color.new(color.green, 0), linewidth=1, style=plot.style_linebr)
plot(showPrevHourLevels ? prevLow : na, "Previous H1 Low", color=color.new(color.red, 0), linewidth=1, style=plot.style_linebr)

plot(showStructureLevels ? structureHigh : na, "H1 Structure High", color=color.new(color.lime, 40), linewidth=1)
plot(showStructureLevels ? structureLow : na, "H1 Structure Low", color=color.new(color.red, 40), linewidth=1)

bgColor = minorLong ? color.new(color.lime, 88) : minorShort ? color.new(color.red, 88) : color.new(color.gray, 92)
bgcolor(showBackground ? bgColor : na)

// ─────────────────────────────────────────────
// Bias Label
// ─────────────────────────────────────────────
var label biasLabel = na

if barstate.islast
    label.delete(biasLabel)
    biasLabel := label.new(
         bar_index,
         high,
         biasText,
         style=label.style_label_down,
         textcolor=color.white,
         color=biasColor,
         size=size.normal
     )

// ─────────────────────────────────────────────
// Dashboard
// ─────────────────────────────────────────────
var table dash = table.new(position.top_right, 3, 8, border_width=1)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Minor Analyse", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, "Status", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 2, 0, "Score", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 1, "BIAS", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, biasText, text_color=color.white, bgcolor=biasColor)
    table.cell(dash, 2, 1, str.tostring(bullScore) + " / " + str.tostring(bearScore), text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 2, "EMA Trend", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, emaBull ? "Bullish" : emaBear ? "Bearish" : "Neutral", text_color=color.white, bgcolor=emaBull ? color.green : emaBear ? color.red : color.gray)
    table.cell(dash, 2, 2, emaBull ? "+1 Long" : emaBear ? "+1 Short" : "-", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 3, "Price vs EMA", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, priceBull ? "Above EMAs" : priceBear ? "Below EMAs" : "Inside Buffer", text_color=color.white, bgcolor=priceBull ? color.green : priceBear ? color.red : color.gray)
    table.cell(dash, 2, 3, priceBull ? "+1 Long" : priceBear ? "+1 Short" : "-", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 4, "H1 Candle", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, candleBull ? "Bullish" : candleBear ? "Bearish" : "Doji", text_color=color.white, bgcolor=candleBull ? color.green : candleBear ? color.red : color.gray)
    table.cell(dash, 2, 4, candleBull ? "+1 Long" : candleBear ? "+1 Short" : "-", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 5, "Prev H1 Break", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, breakPrevHigh ? "Break High" : breakPrevLow ? "Break Low" : "No Break", text_color=color.white, bgcolor=breakPrevHigh ? color.green : breakPrevLow ? color.red : color.gray)
    table.cell(dash, 2, 5, breakPrevHigh ? "+1 Long" : breakPrevLow ? "+1 Short" : "-", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 6, "Structure", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, structureBull ? "Bullish Break" : structureBear ? "Bearish Break" : "Range", text_color=color.white, bgcolor=structureBull ? color.green : structureBear ? color.red : color.gray)
    table.cell(dash, 2, 6, structureBull ? "+1 Long" : structureBear ? "+1 Short" : "-", text_color=color.white, bgcolor=color.black)

    table.cell(dash, 0, 7, "ATR Buffer", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, useAtrBuffer ? str.tostring(buffer, format.mintick) : "Off", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 2, 7, "Neutral Zone", text_color=color.white, bgcolor=color.black)

// ─────────────────────────────────────────────
// Alerts
// ─────────────────────────────────────────────
alertcondition(minorLong, "Minor H1 LONG", "Minor H1 BIAS is LONG")
alertcondition(minorShort, "Minor H1 SHORT", "Minor H1 BIAS is SHORT")
alertcondition(minorNeutral, "Minor H1 NEUTRAL", "Minor H1 BIAS is NEUTRAL")
````
