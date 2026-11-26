# Delta Pressure Ledger [JOAT]

- url: https://www.tradingview.com/script/UnVcd3kd-Delta-Pressure-Ledger-JOAT/
- type: indicator
- pine_id: PUB;75eb4ae17c234d60bcb66accbc5992af
- version: 1.0

## Description

[b]Delta Pressure Ledger [JOAT][/b]

[b]Introduction[/b]

Delta Pressure Ledger is an open-source lower-pane pressure model built entirely from chart-derived proxies. It combines anchored VWAP context, candle pressure, volume impulse, crowding stretch, volatility pressure, and settlement skew into a normalized composite ledger that classifies whether pressure is balanced, directional, crowded, or stressed.

The problem this script solves is hidden market pressure. Many traders rely on unavailable data feeds or vendor-only metrics to estimate crowding or liquidation risk. Delta Pressure Ledger uses only chart-accessible inputs and standardizes them through z-score normalization so pressure states can still be read in a consistent way across instruments.

[image]https://www.tradingview.com/x/ALBgBgeq/[/image]

[b]Core Concepts[/b]

[b]1. Chart-Derived Pressure Proxy[/b]

The script estimates directional pressure from candle settlement, intrabar range occupation, and volume impulse rather than external order flow feeds.

[b]2. Anchored VWAP Context[/b]

Pressure is interpreted relative to anchored value, allowing the user to distinguish directional expansion from overstretched crowding.

[b]3. Z-Score Normalization[/b]

All sub-engines are normalized over a configurable lookback, which makes the composite reading more portable across symbols and timeframes.

[b]4. Crowding and Stress Logic[/b]

The script tracks when price and derived sentiment become stretched enough to imply elevated liquidation or unwind risk.

[b]5. Composite Verdict[/b]

Pressure, crowding, volatility, and skew are merged into one verdict state so the user can quickly determine whether the market is orderly, imbalanced, or stressed.

[b]Features[/b]

[list]
[*][b]Anchored VWAP context:[/b] Session, weekly, or monthly value anchor
[*][b]Pressure engine:[/b] Candle and volume-derived directional pressure model
[*][b]Crowding engine:[/b] Stretch and behavioral excess detection
[*][b]Volatility and skew layers:[/b] Pressure quality and instability are separated from raw direction
[*][b]Normalized composite score:[/b] All sub-engines standardized into one comparable ledger
[*][b]Risk meter:[/b] Liquidation-style stress estimate derived from crowding and instability
[*][b]Confirmed-bar transitions:[/b] State changes and alerts are held to confirmed bars
[*][b]Top-right dashboard:[/b] Regime, pressure, crowding, volatility, risk, composite score, and last confirmed flip
[/list]

[b]How to Use This Indicator[/b]

[b]Step 1: Read the composite verdict[/b]
The verdict gives the fastest summary of whether the market is balanced, directionally pressured, or entering a crowded stress state.

[b]Step 2: Separate pressure from crowding[/b]
A bullish pressure reading with low crowding is different from a bullish pressure reading with extreme crowding and high risk.

[b]Step 3: Respect risk transitions[/b]
When the risk meter moves into elevated territory, directional continuation setups deserve more caution.

[b]Indicator Limitations[/b]

[list]
[*]This script uses chart-derived proxies rather than exchange-level liquidation or true open-interest feeds
[*]Normalized readings can still behave differently across asset classes with unusual volume structure
[*]Stress conditions can remain elevated for extended periods during strong trends
[*]The script classifies pressure and risk context; it does not execute trades by itself
[/list]

[b]Originality Statement[/b]

Delta Pressure Ledger is original in the way it builds a portable, chart-derived pressure and crowding framework without depending on unavailable external feeds, while still organizing the result into a normalized composite and risk ledger.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice. Derived pressure and crowding models can be wrong, especially during atypical market events. Use proper risk management and independent judgment.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Delta Pressure Ledger [JOAT]", shorttitle="DPL [JOAT]", overlay=false, max_bars_back=3000, precision=2)
//=============================================================================
// Utility Functions
//=============================================================================

f_clamp(float value, float lo, float hi) =>
    math.max(lo, math.min(hi, value))

f_safeDiv(float num, float den) =>
    den != 0.0 ? num / den : 0.0

f_zscore(float src, int length) =>
    float basis = ta.sma(src, length)
    float spread = ta.stdev(src, length)
    not na(basis) and not na(spread) and spread != 0.0 ? (src - basis) / spread : 0.0

f_stateColor(int stateCode, color bull, color bear, color accent, color amber, color neutral) =>
    color resolved = color.new(neutral, 0)
    if stateCode == 3
        resolved := color.new(bull, 0)
    else if stateCode == 2
        resolved := color.new(accent, 0)
    else if stateCode == 1
        resolved := color.new(bull, 0)
    else if stateCode == -1
        resolved := color.new(bear, 0)
    else if stateCode == -2
        resolved := color.new(amber, 0)
    else if stateCode == -3
        resolved := color.new(bear, 0)
    resolved

f_metricColor(float value, float neutralBand, color bull, color bear, color neutral) =>
    color resolved = color.new(neutral, 0)
    if value > neutralBand
        resolved := color.from_gradient(value, neutralBand, neutralBand * 3.0, neutral, bull)
    else if value < -neutralBand
        resolved := color.from_gradient(value, -neutralBand * 3.0, -neutralBand, bear, neutral)
    resolved

//=============================================================================
// Inputs
//=============================================================================

string grpCalc = "Calculation"
string grpNorm = "Normalization"
string grpVis = "Visuals"
string grpZone = "Zones"
string grpDash = "Dashboard"
string grpAlert = "Alerts"

srcInput = input.source(hlc3, "Source", group=grpCalc, tooltip="Primary price source used by the crowding and skew models.")
pressureLen = input.int(18, "Pressure Length", minval=3, maxval=100, group=grpCalc, tooltip="Smoothing and memory for the pressure engine.")
crowdLen = input.int(14, "Crowding Length", minval=3, maxval=100, group=grpCalc, tooltip="RSI and extension memory for crowding detection.")
volLen = input.int(34, "Volatility Length", minval=5, maxval=200, group=grpCalc, tooltip="ATR baseline memory for volatility pressure.")
skewLen = input.int(16, "Skew Length", minval=3, maxval=100, group=grpCalc, tooltip="Smoothing memory for candle settlement skew.")
normLen = input.int(50, "Normalization Period", minval=10, maxval=300, group=grpNorm, tooltip="Z-score period used to normalize all sub-engines.")
smoothLen = input.int(5, "Signal Smoothing", minval=1, maxval=20, group=grpNorm, tooltip="Light smoothing applied to the plotted series.")
atrLen = input.int(14, "ATR Length", minval=3, maxval=100, group=grpNorm, tooltip="ATR length used for distance normalization.")
vwapMode = input.string("Session", "Anchored VWAP", options=["Session", "Week", "Month"], group=grpNorm, tooltip="Select the anchored VWAP used as the contextual anchor.")

bullWeight = input.float(0.38, "Pressure Weight", minval=0.0, maxval=1.0, step=0.01, group=grpNorm)
crowdWeight = input.float(0.24, "Crowding Weight", minval=0.0, maxval=1.0, step=0.01, group=grpNorm)
volWeight = input.float(0.20, "Volatility Weight", minval=0.0, maxval=1.0, step=0.01, group=grpNorm)
skewWeight = input.float(0.18, "Skew Weight", minval=0.0, maxval=1.0, step=0.01, group=grpNorm)

showBackground = input.bool(true, "Show Background Regime", group=grpVis)
showZones = input.bool(true, "Show Zones", group=grpVis)
showDash = input.bool(true, "Show Dashboard", group=grpDash)
showAlerts = input.bool(true, "Enable Confirmed Alerts", group=grpAlert)
showStressRibbon = input.bool(true, "Show Risk Ribbon", group=grpVis)

bullColor = input.color(#3BE6A8, "Bull Color", group=grpVis)
bearColor = input.color(#FF5B6E, "Bear Color", group=grpVis)
accentColor = input.color(#4CC9F0, "Accent Color", group=grpVis)
amberColor = input.color(#F6C667, "Amber Color", group=grpVis)
neutralColor = input.color(#9AA4B2, "Neutral Color", group=grpVis)
panelColor = input.color(#0E1322, "Panel Color", group=grpVis)
gridColor = input.color(#1B2740, "Grid Color", group=grpVis)
shadowColor = input.color(#070B14, "Shadow Color", group=grpVis)

zoneTransp = input.int(86, "Zone Transparency", minval=0, maxval=100, group=grpZone)
stressZoneTransp = input.int(88, "Stress Transparency", minval=0, maxval=100, group=grpZone)
extremeZoneTransp = input.int(92, "Extreme Transparency", minval=0, maxval=100, group=grpZone)

bullThreshold = input.float(0.85, "Bull Threshold", minval=0.1, maxval=5.0, step=0.05, group=grpNorm)
bearThreshold = input.float(0.85, "Bear Threshold", minval=0.1, maxval=5.0, step=0.05, group=grpNorm)
crowdExtreme = input.float(1.20, "Crowding Extreme", minval=0.1, maxval=4.0, step=0.05, group=grpNorm)
volExpansion = input.float(0.90, "Volatility Expansion", minval=0.1, maxval=4.0, step=0.05, group=grpNorm)
volCompression = input.float(-0.60, "Volatility Compression", minval=-4.0, maxval=4.0, step=0.05, group=grpNorm)
riskCritical = input.float(75.0, "Critical Risk", minval=1.0, maxval=100.0, step=1.0, group=grpNorm)
riskWarning = input.float(55.0, "Warning Risk", minval=1.0, maxval=100.0, step=1.0, group=grpNorm)
stretchCap = input.float(2.2, "VWAP Stretch Cap", minval=0.5, maxval=10.0, step=0.1, group=grpNorm)

//=============================================================================
// Anchored VWAP Context
//=============================================================================

bool newSession = timeframe.change("D")
bool newWeek = timeframe.change("W")
bool newMonth = timeframe.change("M")

var float cumPvSession = 0.0
var float cumVolSession = 0.0
var float cumPvWeek = 0.0
var float cumVolWeek = 0.0
var float cumPvMonth = 0.0
var float cumVolMonth = 0.0

float volumeSafe = nz(volume, 0.0)

if newSession
    cumPvSession := 0.0
    cumVolSession := 0.0
if newWeek
    cumPvWeek := 0.0
    cumVolWeek := 0.0
if newMonth
    cumPvMonth := 0.0
    cumVolMonth := 0.0

cumPvSession += hl2 * volumeSafe
cumVolSession += volumeSafe
cumPvWeek += hl2 * volumeSafe
cumVolWeek += volumeSafe
cumPvMonth += hl2 * volumeSafe
cumVolMonth += volumeSafe

float vwapSession = cumVolSession > 0.0 ? cumPvSession / cumVolSession : hl2
float vwapWeek = cumVolWeek > 0.0 ? cumPvWeek / cumVolWeek : hl2
float vwapMonth = cumVolMonth > 0.0 ? cumPvMonth / cumVolMonth : hl2

float refVwap = switch vwapMode
    "Week" => vwapWeek
    "Month" => vwapMonth
    => vwapSession

float vwapGap = math.abs(close - refVwap)

//=============================================================================
// Candle Structure Proxies
//=============================================================================

float trSafe = math.max(high - low, syminfo.mintick)
float atrNow = math.max(ta.atr(atrLen), syminfo.mintick)
float atrBasis = math.max(ta.sma(ta.atr(atrLen), volLen), syminfo.mintick)

float candleBody = close - open
float candleBodyAbs = math.abs(candleBody)
float candleBodyRatio = candleBodyAbs / trSafe
float bodyTone = candleBody / trSafe

float upperWick = high - math.max(open, close)
float lowerWick = math.min(open, close) - low
float wickBias = f_safeDiv(lowerWick - upperWick, trSafe)
float closePosition = f_safeDiv(close - low, trSafe)

float volumeBase = ta.sma(volumeSafe, pressureLen)
float volumeImpulseRatio = volumeBase > 0.0 ? volumeSafe / volumeBase : 1.0

//=============================================================================
// Pressure Engine
// -----------------------------------------------------------------------------
// A signed candle-pressure proxy that combines candle dominance, volume impulse,
// and contextual distance from the anchored VWAP.
//=============================================================================

float pressureCore = ta.ema(bodyTone * (0.50 + candleBodyRatio) * volumeImpulseRatio * 100.0, pressureLen)
float pressureContext = ta.ema(f_safeDiv(close - refVwap, atrNow) * 18.0, math.max(2, int(math.round(pressureLen * 0.5))))
float ledgerPressureRaw = pressureCore + pressureContext
float ledgerPressureZ = f_zscore(ledgerPressureRaw, normLen)
float ledgerPressureSmoothed = ta.ema(ledgerPressureZ, smoothLen)

//=============================================================================
// Crowding Engine
// -----------------------------------------------------------------------------
// Crowd pressure is modeled as a blend of RSI saturation, VWAP stretch, and
// candle settlement imbalance. Extreme readings imply crowded positioning.
//=============================================================================

float crowdRsi = ta.rsi(srcInput, crowdLen)
float crowdRsiBias = (crowdRsi - 50.0) * 2.0
float crowdStretch = f_safeDiv(close - refVwap, atrNow) * 10.0
float crowdWick = (wickBias * 24.0) + ((closePosition - 0.5) * 8.0)
float ledgerCrowdRaw = ta.ema(crowdRsiBias + crowdStretch + crowdWick, crowdLen)
float ledgerCrowdZ = f_zscore(ledgerCrowdRaw, normLen)
float ledgerCrowdSmoothed = ta.ema(ledgerCrowdZ, smoothLen)

//=============================================================================
// Volatility Pressure Engine
// -----------------------------------------------------------------------------
// Uses ATR expansion/compression and an ATR percentile approximation to detect
// volatility stress. High values suggest expansion and a greater snap risk.
//=============================================================================

float atrRatio = atrNow / atrBasis
float atrPercent = ta.percentrank(atrNow, volLen)
float ledgerVolRaw = ((atrRatio - 1.0) * 100.0) + ((atrPercent - 50.0) * 0.35)
float ledgerVolZ = f_zscore(ledgerVolRaw, normLen)
float ledgerVolSmoothed = ta.ema(ledgerVolZ, smoothLen)

//=============================================================================
// Skew Engine
// -----------------------------------------------------------------------------
// Candle settlement skew measures whether bars close near their highs or lows.
// This is useful for identifying exhaustion, absorption, and failure pressure.
//=============================================================================

float candleSkewRaw = f_safeDiv((close - low) - (high - close), trSafe) * 100.0 + ((closePosition - 0.5) * 12.0)
float ledgerSkewRaw = ta.ema(candleSkewRaw + f_safeDiv(close - refVwap, atrNow) * 7.0, skewLen)
float ledgerSkewZ = f_zscore(ledgerSkewRaw, normLen)
float ledgerSkewSmoothed = ta.ema(ledgerSkewZ, smoothLen)

//=============================================================================
// Composite Ledger Score
// -----------------------------------------------------------------------------
// The composite is a weighted, normalized synthesis of all four sub-engines.
// Positive values imply bullish pressure dominance; negative values imply bear
// pressure dominance.
//=============================================================================

float ledgerCompositeZ = (ledgerPressureSmoothed * bullWeight) +
     (ledgerCrowdSmoothed * crowdWeight) +
     (ledgerVolSmoothed * volWeight) +
     (ledgerSkewSmoothed * skewWeight)

float ledgerCompositeSmoothed = ta.ema(ledgerCompositeZ, smoothLen)
float ledgerCompositeScore = f_clamp(ledgerCompositeSmoothed * 33.0, -100.0, 100.0)

//=============================================================================
// Stress Meter
// -----------------------------------------------------------------------------
// Stress rises when crowding, volatility, VWAP extension, and pressure conflict
// all align. The meter is normalized for display in a single lower pane.
//=============================================================================

float crowdStress = f_clamp(math.abs(ledgerCrowdSmoothed) / crowdExtreme, 0.0, 1.0)
float volStress = f_clamp(ledgerVolSmoothed / volExpansion, 0.0, 1.0)
float stretchStress = f_clamp(f_safeDiv(vwapGap, atrNow) / stretchCap, 0.0, 1.0)
float skewStress = f_clamp(math.abs(ledgerSkewSmoothed) / 1.25, 0.0, 1.0)

float pressureConflict = (ledgerCompositeSmoothed > 0.0 and ledgerPressureSmoothed < -0.10) or
     (ledgerCompositeSmoothed < 0.0 and ledgerPressureSmoothed > 0.10) ? 1.0 : 0.0

float ledgerRiskRaw =
     (crowdStress * 32.0) +
     (volStress * 22.0) +
     (stretchStress * 18.0) +
     (skewStress * 12.0) +
     (pressureConflict * 16.0)

float ledgerRisk = f_clamp(ledgerRiskRaw, 0.0, 100.0)
float ledgerRiskDisplay = (ledgerRisk - 50.0) / 20.0

//=============================================================================
// Regime Classification
// -----------------------------------------------------------------------------
// The confirmed regime updates only when the current bar closes. This prevents
// realtime flicker while keeping the core calculations available intrabar.
//=============================================================================

var int ledgerRegime = 0
var string ledgerVerdict = "Balanced"
var float lastConfirmedFlipPrice = na
var float lastConfirmedComposite = na
var float lastConfirmedRisk = na

bool bullSetup = ledgerCompositeSmoothed >= bullThreshold and ledgerPressureSmoothed > 0.0 and ledgerCrowdSmoothed > -0.20
bool bearSetup = ledgerCompositeSmoothed <= -bearThreshold and ledgerPressureSmoothed < 0.0 and ledgerCrowdSmoothed < 0.20
bool expansionSetup = ledgerVolSmoothed >= volExpansion and math.abs(ledgerCompositeSmoothed) < 0.35
bool compressionSetup = ledgerVolSmoothed <= volCompression and math.abs(ledgerCompositeSmoothed) < 0.35
bool crowdLongSetup = ledgerRisk >= riskCritical and ledgerCompositeSmoothed > 0.0
bool crowdShortSetup = ledgerRisk >= riskCritical and ledgerCompositeSmoothed < 0.0

if barstate.isconfirmed
    if crowdLongSetup
        ledgerRegime := 3
        ledgerVerdict := "Crowded Long"
    else if crowdShortSetup
        ledgerRegime := -3
        ledgerVerdict := "Crowded Short"
    else if expansionSetup
        ledgerRegime := 2
        ledgerVerdict := "Expansion"
    else if compressionSetup
        ledgerRegime := -2
        ledgerVerdict := "Compression"
    else if bullSetup
        ledgerRegime := 1
        ledgerVerdict := "Bull Pressure"
    else if bearSetup
        ledgerRegime := -1
        ledgerVerdict := "Bear Pressure"
    else
        ledgerRegime := 0
        ledgerVerdict := "Balanced"

    int prevRegime = nz(ledgerRegime[1], ledgerRegime)
    if ledgerRegime != prevRegime
        lastConfirmedFlipPrice := close

    lastConfirmedComposite := ledgerCompositeScore
    lastConfirmedRisk := ledgerRisk

color regimeColor = f_stateColor(ledgerRegime, bullColor, bearColor, accentColor, amberColor, neutralColor)

//=============================================================================
// Confirmed Transition Events
// -----------------------------------------------------------------------------
// These are used for alerts only. No retail markers are plotted on-chart.
//=============================================================================

bool bullTransition = barstate.isconfirmed and bar_index > 0 and bullSetup and not bullSetup[1]
bool bearTransition = barstate.isconfirmed and bar_index > 0 and bearSetup and not bearSetup[1]
bool riskTransition = barstate.isconfirmed and ledgerRisk >= riskCritical and nz(ledgerRisk[1], ledgerRisk) < riskCritical
bool compressionTransition = barstate.isconfirmed and bar_index > 0 and compressionSetup and not compressionSetup[1]

alertcondition(showAlerts and bullTransition, title="DPL Bull Pressure", message="Delta Pressure Ledger: Bull pressure confirmed on {{ticker}} {{interval}}")
alertcondition(showAlerts and bearTransition, title="DPL Bear Pressure", message="Delta Pressure Ledger: Bear pressure confirmed on {{ticker}} {{interval}}")
alertcondition(showAlerts and riskTransition, title="DPL Risk Spike", message="Delta Pressure Ledger: Risk spike confirmed on {{ticker}} {{interval}}")
alertcondition(showAlerts and compressionTransition, title="DPL Compression", message="Delta Pressure Ledger: Compression confirmed on {{ticker}} {{interval}}")

//=============================================================================
// Plot Scaling and Baselines
// -----------------------------------------------------------------------------
// The pane keeps the normalized engines in a comparable range. Risk is mapped
// to a z-like display scale for plot clarity, while the dashboard reports the
// raw percent-style stress reading.
//=============================================================================

float plotPressure = ledgerPressureSmoothed
float plotCrowd = ledgerCrowdSmoothed
float plotVol = ledgerVolSmoothed
float plotSkew = ledgerSkewSmoothed
float plotComposite = ledgerCompositeSmoothed
float plotRisk = ledgerRiskDisplay

pZero = plot(0.0, title="Zero", display=display.none)

//=============================================================================
// Zone Guides
// -----------------------------------------------------------------------------
// Optional institutional-style guide bands. These stay confined to the lower
// pane and avoid cluttering the main chart.
//=============================================================================

hlineZero = hline(0.0, "Neutral", color=color.new(gridColor, 35))
hlineBull = hline(bullThreshold, "Bull Threshold", color=color.new(bullColor, 65), linestyle=hline.style_dashed)
hlineBear = hline(-bearThreshold, "Bear Threshold", color=color.new(bearColor, 65), linestyle=hline.style_dashed)
hlineCrowdTop = hline(crowdExtreme, "Crowd High", color=color.new(amberColor, 70), linestyle=hline.style_dotted)
hlineCrowdBot = hline(-crowdExtreme, "Crowd Low", color=color.new(amberColor, 70), linestyle=hline.style_dotted)
hlineRiskTop = hline(riskWarning / 20.0 - 2.5, "Risk Warning", color=color.new(accentColor, 70), linestyle=hline.style_dashed)
hlineRiskCritical = hline(riskCritical / 20.0 - 2.5, "Risk Critical", color=color.new(bearColor, 70), linestyle=hline.style_solid)

color bullZoneColor = showZones ? color.new(bullColor, zoneTransp) : na
color bearZoneColor = showZones ? color.new(bearColor, zoneTransp) : na
color crowdZoneColor = showZones ? color.new(amberColor, stressZoneTransp) : na
color riskZoneColor = showZones ? color.new(bearColor, extremeZoneTransp) : na

fill(hlineBull, hlineZero, color=bullZoneColor, title="Bull Zone")
fill(hlineBear, hlineZero, color=bearZoneColor, title="Bear Zone")
fill(hlineCrowdTop, hlineCrowdBot, color=crowdZoneColor, title="Crowd Corridor")
fill(hlineRiskTop, hlineRiskCritical, color=riskZoneColor, title="Risk Corridor")

//=============================================================================
// Series Visualization
// -----------------------------------------------------------------------------
// Each sub-engine receives its own line. The composite is highlighted more
// strongly, while risk is rendered as a normalized histogram ribbon.
//=============================================================================

color pressurePlotColor = f_metricColor(plotPressure, 0.20, bullColor, bearColor, neutralColor)
color crowdPlotColor = f_metricColor(plotCrowd, 0.20, accentColor, bearColor, neutralColor)
color volPlotColor = f_metricColor(plotVol, 0.20, amberColor, bearColor, neutralColor)
color skewPlotColor = f_metricColor(plotSkew, 0.20, bullColor, amberColor, neutralColor)
color compositePlotColor = ledgerCompositeSmoothed >= 0.0 ?
     color.from_gradient(ledgerCompositeSmoothed, 0.0, 2.5, neutralColor, bullColor) :
     color.from_gradient(ledgerCompositeSmoothed, -2.5, 0.0, bearColor, neutralColor)
color riskPlotColor = color.from_gradient(ledgerRisk, 0.0, 100.0, bullColor, bearColor)

pPressure = plot(plotPressure, "Pressure", color=color.new(pressurePlotColor, 0), linewidth=2)
pCrowd = plot(plotCrowd, "Crowding", color=color.new(crowdPlotColor, 0), linewidth=2)
pVol = plot(plotVol, "Volatility", color=color.new(volPlotColor, 0), linewidth=2)
pSkew = plot(plotSkew, "Skew", color=color.new(skewPlotColor, 0), linewidth=1)
pComposite = plot(plotComposite, "Composite", color=color.new(compositePlotColor, 0), linewidth=3)
pRisk = plot(showStressRibbon ? plotRisk : na, "Risk", color=color.new(riskPlotColor, 0), linewidth=2, style=plot.style_histogram)

// Depth fills between the zero line and the two core readouts.
fill(pComposite, pZero, color=color.new(regimeColor, extremeZoneTransp), title="Composite Cloud")
fill(pPressure, pZero, color=color.new(pressurePlotColor, zoneTransp), title="Pressure Cloud")

// Session anchored reference path. This is a quiet contextual line, not a trade
// marker. It keeps the pressure model honest relative to the day/week/month bias.
float vwapBiasLine = f_clamp(f_safeDiv(close - refVwap, atrNow), -3.0, 3.0)
color vwapBiasColor = vwapBiasLine >= 0.0 ? color.new(bullColor, 55) : color.new(bearColor, 55)
plot(vwapBiasLine, "VWAP Bias", color=vwapBiasColor, linewidth=1, style=plot.style_line)

//=============================================================================
// Background Regime
// -----------------------------------------------------------------------------
// The background is deliberately subtle so the pane remains readable.
//=============================================================================

color bgRegime =
     ledgerRegime == 3 ? color.new(bullColor, 92) :
     ledgerRegime == 2 ? color.new(accentColor, 94) :
     ledgerRegime == 1 ? color.new(bullColor, 95) :
     ledgerRegime == -1 ? color.new(bearColor, 95) :
     ledgerRegime == -2 ? color.new(amberColor, 94) :
     ledgerRegime == -3 ? color.new(bearColor, 92) :
     na

bgcolor(showBackground ? bgRegime : na, title="Regime Background")

//=============================================================================
// Dashboard
// -----------------------------------------------------------------------------
// Top-right compact table showing the current read across all major metrics.
//=============================================================================

var table ledgerDash = table.new(position.top_right, 2, 8, bgcolor=color.new(shadowColor, 8), border_width=1, border_color=color.new(gridColor, 30))

f_cellText(float value) =>
    str.tostring(value, "#.##")

if showDash and barstate.islast
    table.cell(ledgerDash, 0, 0, "DELTA PRESSURE LEDGER", text_color=color.white, text_size=size.small, bgcolor=color.new(panelColor, 0))
    table.cell(ledgerDash, 1, 0, "JOAT", text_color=color.new(accentColor, 0), text_size=size.small, bgcolor=color.new(panelColor, 0))

    table.cell(ledgerDash, 0, 1, "Regime", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 1, ledgerVerdict, text_color=regimeColor, text_size=size.tiny)

    table.cell(ledgerDash, 0, 2, "Pressure", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 2, f_cellText(ledgerPressureSmoothed), text_color=pressurePlotColor, text_size=size.tiny)

    table.cell(ledgerDash, 0, 3, "Crowding", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 3, f_cellText(ledgerCrowdSmoothed), text_color=crowdPlotColor, text_size=size.tiny)

    table.cell(ledgerDash, 0, 4, "Volatility", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 4, f_cellText(ledgerVolSmoothed), text_color=volPlotColor, text_size=size.tiny)

    table.cell(ledgerDash, 0, 5, "Risk", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 5, str.tostring(ledgerRisk, "#.#") + "%", text_color=riskPlotColor, text_size=size.tiny)

    table.cell(ledgerDash, 0, 6, "Composite", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 6, f_cellText(ledgerCompositeScore), text_color=compositePlotColor, text_size=size.tiny)

    string flipText = not na(lastConfirmedFlipPrice) ? str.tostring(lastConfirmedFlipPrice, format.mintick) : "n/a"
    table.cell(ledgerDash, 0, 7, "Last Flip", text_color=color.new(neutralColor, 0), text_size=size.tiny)
    table.cell(ledgerDash, 1, 7, flipText, text_color=color.new(accentColor, 0), text_size=size.tiny)

//=============================================================================
// Additional Guides
// -----------------------------------------------------------------------------
// These hidden plots make it easier to extend the indicator later without
// changing the public visual language.
//=============================================================================

plot(lastConfirmedComposite, "Last Confirmed Composite", display=display.none)
plot(lastConfirmedRisk, "Last Confirmed Risk", display=display.none)
plot(lastConfirmedFlipPrice, "Last Confirmed Flip Price", display=display.none)

//=============================================================================
// Finish
// -----------------------------------------------------------------------------
// No retail markers. No arrows. No clutter.
// The indicator communicates through structure, depth, and state transitions.
//=============================================================================
````
