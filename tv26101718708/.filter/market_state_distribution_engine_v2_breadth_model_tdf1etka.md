# Market State Distribution Engine v2 [Breadth Model]

- url: https://www.tradingview.com/script/TDF1eTka-Market-State-Distribution-Engine-v2-Breadth-Model/
- type: indicator
- pine_id: PUB;e0e4acf6acbc4f47b21e11ae79516ce5
- version: 2.0

## Description

Market State Distribution [Trade_Logic1019]

Market State Distribution is a breadth-based market internals indicator designed to visualize the balance between demand and supply using underlying participation, structural strength, and leadership behavior.
Rather than relying on price alone, the model aggregates multiple internal components into a normalized framework to help evaluate whether conditions are improving, weakening, or transitioning.
This script is intended for educational and informational purposes only. It does not provide financial advice or standalone trading signals.
________________________________________
 Overview
Market State Distribution is built to help evaluate underlying market conditions using internal breadth data.
Instead of focusing on a single metric, the model combines multiple internal inputs into a unified structure. This allows users to assess whether internal conditions appear:
•	Supportive 
•	Weakening 
•	Mixed or transitional 
The goal is to provide a simplified view of broader market conditions.
________________________________________
 Quick Read Guide
•	Demand > Supply → Internal conditions are more supportive 
•	Supply > Demand → Internal conditions are weaker 
•	Crossovers → Potential internal shifts in control 
•	Expansion state → Early-stage improvement environment 
•	Trend state → Sustained participation and stronger conditions 
•	Demand ≈ Supply → Mixed / lower conviction environment 
This indicator is designed as a context tool, not a signal generator.
________________________________________
 Data Inputs
The model uses breadth-style market internals as its primary inputs. By default, these include:
•	Percent of symbols above intermediate-term moving average (INDEX:S5FI) 
•	Percent of symbols above longer-term moving average (INDEX:S5TH) 
•	New highs minus new lows (INDEX:NYHL) 
These inputs are used to approximate:
•	Participation (breadth of strength) 
•	Structural strength (trend stability) 
•	Leadership behavior (expansion vs deterioration) 
Some data inputs may require specific Trading View subscriptions.
Users may substitute equivalent symbols depending on availability.
________________________________________
 Core Model Components
Participation Strength
Measures how broadly strength is distributed across the market using intermediate-term breadth data.
Higher values suggest broader participation; lower values suggest narrowing conditions.
Structural Strength
Represents longer-term trend alignment using broader participation above long-term averages.
Helps assess whether underlying structure is supportive or deteriorating.
Leadership Behavior
Uses new highs vs new lows data to evaluate whether leadership is expanding or weakening.
Provides confirmation beyond participation metrics alone.
________________________________________
 State Modeling
The indicator transforms the underlying inputs into normalized components and combines them into a synthetic state model.
The model estimates the relative distribution of:
•	Trend 
•	Expansion 
•	Decay 
•	Transition 
These are descriptive categories designed to reflect current internal conditions, not predict future price movement.
________________________________________
 Demand vs Supply Framework
The core output of the indicator is the relationship between Demand and Supply:
•	Demand = Trend + Expansion components 
•	Supply = Decay component 
Interpretation (contextual, not prescriptive):
•	Demand > Supply → Internal conditions may be more supportive 
•	Supply > Demand → Internal conditions may be weaker 
•	Demand ≈ Supply → Conditions may be mixed or transitional (lower conviction environment) 
This framework is intended to help interpret internal market tone.
________________________________________
 State Classification
The indicator classifies the current environment into one of four states:
•	Trend 
•	Expansion 
•	Decay 
•	Transition 
These labels summarize which internal condition appears most dominant.
________________________________________
 Shift Detection
The model evaluates changes in the Demand/Supply relationship to identify internal shifts:
•	Demand crossing above Supply → Improving conditions 
•	Supply crossing above Demand → Deteriorating conditions 
•	No crossover → No significant change 
This is designed to highlight internal shifts, not generate trade signals.
________________________________________
 Visualization
Primary Lines
•	Demand 
•	Supply 
These are plotted in a separate pane to visualize internal strength vs deterioration over time.
Summary Table (Optional)
Provides a structured overview of:
•	Control (Demand vs Supply dominance) 
•	Breadth condition 
•	Market condition 
•	State classification 
•	Shift 
•	Read (contextual interpretation) 
•	Bias (contextual framing) 
Optional end-of-line labels can be enabled for clarity.
________________________________________
 How to Use
This indicator is designed as a market context tool.
A typical workflow may include:
1.	Applying the indicator to a broad market index 
2.	Observing whether Demand or Supply is dominant 
3.	Reviewing the state table for context 
4.	Combining insights with price structure, volatility, and risk management 
The objective is to support contextual awareness—not replace independent analysis.
________________________________________
 Configurable Inputs
Data Sources
•	Custom breadth symbols for participation, structure, and leadership inputs 
Logic Settings
•	Smoothing length 
•	Control gap threshold 
•	Demand strength/weakness levels 
•	Decay dominance level 
Display Options
•	Show/hide summary table 
•	Show/hide line labels 
•	Show/hide reference levels 
•	Table size customization 
________________________________________
 Important Notes
•	This script is provided for educational and informational purposes only 
•	It does not provide financial advice or trade recommendations 
•	It does not execute trades or manage positions 
•	Outputs are descriptive, not predictive 
•	Historical behavior does not guarantee future results 
•	Data availability may vary depending on your Trading View plan 
All trading decisions should be made using independent judgment and appropriate risk management.

## Source Code

````pine
// This script is published for educational and informational purposes only.
// 2026 [Trade_Logic1019]
// It is provided as open-source and free to use, modify, and distribute.
//
// Description:
// The Market State Distribution Engine is a breadth-based analytical tool
// designed to visualize the relative balance between demand and supply
// conditions in the broader market. It combines percent of S&P 500 stocks
// above their 50- and 200-day moving averages with NYSE new highs minus new
// lows into a single normalized breadth composite.
//
// v2.1 changes:
// - Demand and Supply are now exact mirrors of one composite (Supply = 100 - Demand),
//   so the 50 line is a true equilibrium. In v2 a neutral market read as
//   "Demand Dominant" because Demand summed two scores and Supply used one.
// - Normalization ranges are centered so neutral inputs map to 50.
// - Participation momentum (change in % above 50 MA) drives the EXPANSION state
//   instead of inflating the Demand line.
// - Fixed: Bias field was blank in the DECAY state.
// - Table reads the last confirmed bar by default (no intraday flip-flopping).
// - Demand Curl Up marker implemented; duplicate plots removed.
//
// This script does NOT provide financial advice, trading signals, or guarantees
// of performance. It is intended to be used as a contextual framework to assist
// in market analysis and should not be relied upon for standalone decision-making.
//
// Data Sources:
// - Percent of S&P 500 stocks above 50 MA (INDEX:S5FI)
// - Percent of S&P 500 stocks above 200 MA (INDEX:S5TH)
// - NYSE New Highs minus New Lows (INDEX:NYHL) -- note: NYSE universe, not S&P 500
//
// Users should verify data availability and accuracy depending on their data provider.
//
// License:
// This script is open-source under the Mozilla Public License 2.0 (MPL 2.0).
// https://mozilla.org/MPL/2.0/

//@version=6
indicator("Market State Distribution Engine v2.1 [Breadth Model]", shorttitle="MSDE v2.1", overlay=false)

//==================================================
// INPUTS
//==================================================
groupData = "Data Sources"
sym50   = input.symbol("INDEX:S5FI", "Percent Above 50", group=groupData)
sym200  = input.symbol("INDEX:S5TH", "Percent Above 200", group=groupData)
symNHNL = input.symbol("INDEX:NYHL", "NH-NL", group=groupData)

groupScale = "Normalization (range midpoint = neutral)"
s50Lo  = input.float(25.0,   "% Above 50 MA: Low",   group=groupScale)
s50Hi  = input.float(75.0,   "% Above 50 MA: High",  group=groupScale)
s200Lo = input.float(30.0,   "% Above 200 MA: Low",  group=groupScale)
s200Hi = input.float(70.0,   "% Above 200 MA: High", group=groupScale)
nhnlLo = input.float(-100.0, "NH-NL: Low",           group=groupScale)
nhnlHi = input.float(100.0,  "NH-NL: High",          group=groupScale)

groupWeights = "Composite Weights"
w50  = input.float(0.45, "Weight: Participation (50 MA)", minval=0.0, group=groupWeights)
w200 = input.float(0.40, "Weight: Structure (200 MA)",    minval=0.0, group=groupWeights)
wNH  = input.float(0.15, "Weight: Leadership (NH-NL)",    minval=0.0, group=groupWeights)

groupLogic = "Logic"
smoothLen    = input.int(8, "Smoothing", minval=1, group=groupLogic)
impulseLen   = input.int(5, "Participation Momentum Lookback", minval=1, group=groupLogic)
controlGap   = input.float(5.0, "Control Gap", minval=0.0, group=groupLogic)
strongLevel  = input.float(60.0, "Demand Strong Level", minval=0.0, maxval=100.0, group=groupLogic)
weakLevel    = input.float(40.0, "Demand Weak Level", minval=0.0, maxval=100.0, group=groupLogic)
curlLookback = input.int(2, "Curl Lookback", minval=1, group=groupLogic)
curlMaxLevel = input.float(50.0, "Demand Curl Max Level", minval=0.0, maxval=100.0, group=groupLogic)

groupDisplay = "Display"
showTable      = input.bool(true, "Show Table", group=groupDisplay)
useConfirmed   = input.bool(true, "Table Uses Last Confirmed Bar", group=groupDisplay)
showLineTags   = input.bool(true, "Show End-of-Line Labels", group=groupDisplay)
showCurlMarker = input.bool(true, "Show Demand Curl Up Marker", group=groupDisplay)
showRefLevels  = input.bool(false, "Show Strong/Weak Reference Levels", group=groupDisplay)
tableSize      = input.string("Normal", "Table Size", options=["Small", "Normal", "Large"], group=groupDisplay)

//==================================================
// HELPERS
//==================================================
clamp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

scale(x, inMin, inMax) =>
    clamp((x - inMin) / math.max(inMax - inMin, 0.0001), 0.0, 1.0)

//==================================================
// DATA
//==================================================
s50_raw  = request.security(sym50, timeframe.period, close)
s200_raw = request.security(sym200, timeframe.period, close)
nhnl_raw = request.security(symNHNL, timeframe.period, close)

s50  = ta.ema(s50_raw, smoothLen)
s200 = ta.ema(s200_raw, smoothLen)
nhnl = ta.ema(nhnl_raw, smoothLen)

//==================================================
// COMPOSITE (symmetric: neutral inputs -> 50)
//==================================================
partStrong   = scale(s50, s50Lo, s50Hi)
structStrong = scale(s200, s200Lo, s200Hi)
leadStrong   = scale(nhnl, nhnlLo, nhnlHi)

wSum     = math.max(w50 + w200 + wNH, 0.0001)
strength = (w50 * partStrong + w200 * structStrong + wNH * leadStrong) / wSum

demandLine = 100.0 * strength
supplyLine = 100.0 - demandLine

// Participation momentum: change in % of stocks above 50 MA (percentage points)
impulse = s50 - s50[impulseLen]

//==================================================
// STATE CODES (computed every bar so they can be read at any offset)
//==================================================
// stateCode: 1 TREND, 2 EXPANSION, 3 TRANSITION, 4 DECAY
int stateCode = demandLine >= strongLevel and impulse >= 0 ? 1 :
                 demandLine <= weakLevel and impulse <= 0 ? 4 :
                 impulse > 0 ? 2 : 3

// controlCode: 1 Demand Dominant, -1 Supply Dominant, 0 Balanced
int controlCode = demandLine > supplyLine + controlGap ? 1 :
                   supplyLine > demandLine + controlGap ? -1 : 0

// breadthCode: 1 Strong, -1 Weak, 0 Mixed
int breadthCode = demandLine >= strongLevel ? 1 : demandLine <= weakLevel ? -1 : 0

// shiftCode: Demand crossing the 50 equilibrium (same as crossing the Supply line)
int shiftCode = ta.crossover(demandLine, 50.0) ? 1 : ta.crossunder(demandLine, 50.0) ? -1 : 0

//==================================================
// DEMAND CURL UP (demand turns up from a decline while still below the max level)
//==================================================
curlRaw = demandLine < curlMaxLevel and demandLine > demandLine[curlLookback] and demandLine[curlLookback] <= demandLine[curlLookback * 2]
curlUp  = curlRaw and not curlRaw[1]

//==================================================
// PLOTS
//==================================================
plot(demandLine, "Demand", color=color.aqua, linewidth=3)
plot(supplyLine, "Supply", color=color.fuchsia, linewidth=3)

hline(50, "Equilibrium", color=color.gray, linestyle=hline.style_solid, linewidth=2)

plot(showRefLevels ? strongLevel : na, "Strong Zone", color=color.new(color.gray, 60), linewidth=1)
plot(showRefLevels ? weakLevel : na, "Weak Zone", color=color.new(color.gray, 60), linewidth=1)

plotshape(showCurlMarker and curlUp and barstate.isconfirmed, "Demand Curl Up", shape.triangleup, location.bottom, color.aqua, size=size.tiny)

//==================================================
// TEXT MAPPINGS
//==================================================
fControl(c) =>
    c == 1 ? "Demand Dominant" : c == -1 ? "Supply Dominant" : "Balanced"

fBreadth(b) =>
    b == 1 ? "Strong" : b == -1 ? "Weak" : "Mixed"

fCondition(s) =>
    s == 1 ? "Trending" : s == 2 ? "Early Improvement" : s == 4 ? "Breaking Down" : "Choppy"

fState(s) =>
    s == 1 ? "TREND" : s == 2 ? "EXPANSION" : s == 4 ? "DECAY" : "TRANSITION"

fRead(s) =>
    s == 1 ? "Demand is in control and participation is supporting follow-through." :
     s == 2 ? "Participation is improving, but the market is not fully mature yet." :
     s == 4 ? "Supply is in control and weak conditions dominate the tape." :
     "Neither side has clear control, or strength is fading. Conditions remain mixed."

fBias(s) =>
    s == 1 ? "Favorable conditions" : s == 2 ? "Probe selectively" : s == 4 ? "Risk conditions elevated" : "Stay selective"

fShift(x) =>
    x == 1 ? "Improving" : x == -1 ? "Deteriorating" : "No Change"

//==================================================
// COLORS
//==================================================
labelBg = color.rgb(35, 35, 45)
valueBg = color.rgb(26, 26, 34)

fControlBg(c) =>
    c == 1 ? color.rgb(0, 188, 212) : c == -1 ? color.rgb(233, 30, 99) : color.rgb(120, 120, 120)

fBreadthBg(b) =>
    b == 1 ? color.rgb(56, 142, 60) : b == -1 ? color.rgb(198, 40, 40) : color.rgb(251, 140, 0)

fStateBg(s) =>
    s == 1 ? color.rgb(56, 142, 60) : s == 2 ? color.rgb(33, 150, 243) : s == 4 ? color.rgb(216, 27, 96) : color.rgb(251, 140, 0)

fShiftBg(x) =>
    x == 1 ? color.rgb(0, 188, 212) : x == -1 ? color.rgb(233, 30, 99) : color.rgb(90, 90, 90)

//==================================================
// TABLE (reads last confirmed bar on the live bar when enabled)
//==================================================
tableTextSize = tableSize == "Small" ? size.small : tableSize == "Large" ? size.large : size.normal

var table t = table.new(position.top_right, 2, 8, border_width=1)

if barstate.islast and showTable
    off = useConfirmed and not barstate.isconfirmed ? 1 : 0

    sC = stateCode[off]
    cC = controlCode[off]
    bC = breadthCode[off]
    xC = shiftCode[off]
    dV = demandLine[off]
    sV = supplyLine[off]

    table.cell(t, 0, 0, "Control", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 0, fControl(cC), text_color=color.white, bgcolor=fControlBg(cC), text_size=tableTextSize)

    table.cell(t, 0, 1, "Breadth", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 1, fBreadth(bC), text_color=color.white, bgcolor=fBreadthBg(bC), text_size=tableTextSize)

    table.cell(t, 0, 2, "Condition", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 2, fCondition(sC), text_color=color.white, bgcolor=fStateBg(sC), text_size=tableTextSize)

    table.cell(t, 0, 3, "State", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 3, fState(sC), text_color=color.white, bgcolor=fStateBg(sC), text_size=tableTextSize)

    table.cell(t, 0, 4, "Shift", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 4, fShift(xC), text_color=color.white, bgcolor=fShiftBg(xC), text_size=tableTextSize)

    table.cell(t, 0, 5, "Demand / Supply", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 5, str.tostring(dV, "#.0") + " / " + str.tostring(sV, "#.0"), text_color=color.white, bgcolor=valueBg, text_size=tableTextSize)

    table.cell(t, 0, 6, "Read", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 6, fRead(sC), text_color=color.white, bgcolor=valueBg, text_size=tableTextSize)

    table.cell(t, 0, 7, "Bias", text_color=color.white, bgcolor=labelBg, text_size=tableTextSize)
    table.cell(t, 1, 7, fBias(sC), text_color=color.white, bgcolor=valueBg, text_size=tableTextSize)

//==================================================
// END-OF-LINE LABELS
//==================================================
var label lblDemand = na
var label lblSupply = na

if barstate.islast and showLineTags
    label.delete(lblDemand)
    label.delete(lblSupply)

    lblDemand := label.new(bar_index + 1, demandLine, "Demand", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.aqua, textcolor=color.black, size=size.small)
    lblSupply := label.new(bar_index + 1, supplyLine, "Supply", xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=color.fuchsia, textcolor=color.white, size=size.small)
````
