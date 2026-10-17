# Wave Oscillator

- url: https://www.tradingview.com/script/lSyOilRH-Wave-Oscillator/
- type: indicator
- pine_id: PUB;5db07928e3104ca19037b45fea2bfb78
- version: 1.0

## Description

wave high low detector pro

wave high low detector is a bounded oscillator designed to help identify potential local high and low areas using momentum, rsi behavior, pivot confirmation, candle rejection, divergence, atr exhaustion, structure breaks, cooldown logic and quality scoring.

the oscillator moves between 0 and 100.

a value near 100 means price is trading close to the upper part of its recent range or showing strong upside momentum.

a value near 0 means price is trading close to the lower part of its recent range or showing strong downside momentum.

the script does not predict the future and does not guarantee market tops or bottoms. it is a technical analysis tool that marks possible early and confirmed high or low references. every signal should be confirmed with price action, market structure, volume, trend context and risk management.

main idea

the indicator separates high and low detection into two signal types:

early high and early low

confirmed high and confirmed low

early signals are faster and more reactive. they appear when the oscillator leaves an extreme zone and the selected filters agree.

confirmed signals are slower but more selective. they use pivot confirmation and additional context to validate a stronger high or low reference.

this design allows the trader to choose between speed and confirmation.

what the indicator shows

wave oscillator

high zone

low zone

balance zone

early high markers

early low markers

confirmed high markers

confirmed low markers

quality score labels

bull and bear gradient fill

optional glow

right-side zone labels

dashboard with state, value, score and mode

separate alerts for early and confirmed signals

how high and low detection works

an early high appears when the oscillator leaves the upper zone after being stretched upward.

an early low appears when the oscillator leaves the lower zone after being stretched downward.

a confirmed high appears only when a pivot high is confirmed and the score is strong enough.

a confirmed low appears only when a pivot low is confirmed and the score is strong enough.

confirmed signals are placed back on the pivot location, so they naturally appear with a delay. this is normal because pivots need future bars to confirm the local high or low.

quality score

the score rates the quality of a potential high or low from 0 to 100.

the score can include:

extreme oscillator condition

super extreme oscillator condition

oscillator slope reversal

wick rejection

atr exhaustion

divergence

structure break

pivot confirmation

a higher score means more conditions agree. a lower score means the setup is weaker or less complete.

the score is not a trade signal by itself. it is only a filter that helps compare the quality of different high and low references.

input guide

engine

source

selects the price source used by the rsi engine.

common choices are close, open, high, low, hl2, hlc3 or ohlc4.

length sensitivity

controls how many bars are used by the oscillator engine.

lower values make the wave faster and more reactive.

higher values make the wave smoother and slower.

smoothing

smooths the oscillator.

higher values reduce noise but add delay.

lower values react faster but may produce more signals.

engine

selects the oscillator calculation method.

momentum wave

uses a stochastic-style high and low range calculation. this is the most direct mode for high and low detection.

rsi

uses a smoothed rsi. this mode reads momentum exhaustion rather than pure range position.

blend

combines rsi and range position. this gives a balanced reading between momentum and high or low range behavior.

levels

overbought high zone

sets the upper zone where price is considered stretched toward the high area.

default logic usually works around 80.

oversold low zone

sets the lower zone where price is considered stretched toward the low area.

default logic usually works around 20.

show midline

shows or hides the 50 balance line.

above 50, the oscillator is generally stronger.

below 50, the oscillator is generally weaker.

high low detector

detection mode

controls the signal strictness.

fast

more reactive. it allows earlier signals with fewer confirmations.

balanced

uses a middle approach between speed and confirmation.

confirmed

stricter and slower. it requires stronger confirmation and higher score quality.

show early high low

shows or hides early high and early low markers.

show confirmed high low

shows or hides confirmed high and confirmed low markers.

balanced minimum score

sets the minimum score used in balanced mode.

higher values reduce signals.

lower values increase signals.

pivot left bars

sets how many bars to the left are used to confirm a pivot.

higher values make pivots more important but slower.

pivot right bars

sets how many bars to the right are required to confirm a pivot.

higher values make confirmed signals more reliable but delayed.

cooldown between signals

sets the minimum number of bars between repeated signals of the same type.

this helps reduce signal spam.

show quality score labels

shows or hides score labels near early and confirmed markers.

optional filters

use divergence in score

adds divergence logic to the quality score.

bearish divergence can strengthen a confirmed high.

bullish divergence can strengthen a confirmed low.

wick rejection filter

requires a rejection wick before accepting signals.

for highs, the script looks for upper wick rejection.

for lows, the script looks for lower wick rejection.

min wick percent of candle

sets the minimum wick size needed for the wick rejection filter.

higher values make the filter stricter.

lower values allow more signals.

atr exhaustion filter

requires price to be extended away from a moving average by an atr-based distance.

this helps focus on stronger exhaustion moves.

atr length

sets the atr calculation length.

atr exhaustion multiplier

sets how far price must extend from the average before the atr exhaustion filter confirms.

structure break filter

requires a short structure break to confirm the signal.

for highs, price should break below recent structure.

for lows, price should break above recent structure.

structure break lookback

sets how many bars are used to define the recent structure level.

visuals

glow

turns the glow effect around the wave on or off.

glow intensity

controls the strength of the glow.

bull bear gradient fill

fills the area between the wave and the midline with a bull or bear gradient.

fill transparency

controls how visible the gradient fill is.

higher transparency makes the fill lighter.

lower transparency makes the fill stronger.

tint high low zones

adds a faint background tint to the high and low areas.

color theme

selects the visual color style.

wizard

default bright cyan and red style.

ice

cool blue theme.

inferno

warm orange and red theme.

toxic

green and purple style.

markers

show high low markers

turns all markers on or off.

marker labels

selects the marker text style.

high low

uses early high, early low, confirmed high and confirmed low style labels.

buy sell

uses early buy, early sell, confirmed buy and confirmed sell style labels.

these labels are visual references only, not automatic entries.

show zone labels right

shows high, low and balance labels on the right side of the oscillator.

dashboard

show dashboard

shows or hides the dashboard.

position

selects the dashboard location.

the dashboard displays:

current state

current oscillator value

high score

low score

detection mode

signal types

early high

an early high appears when the wave leaves the high zone and the high score passes the selected requirements.

this means upside pressure may be weakening.

it is not a guaranteed top.

early low

an early low appears when the wave leaves the low zone and the low score passes the selected requirements.

this means downside pressure may be weakening.

it is not a guaranteed bottom.

confirmed high

a confirmed high appears when a pivot high is confirmed and the score is strong enough.

this signal is more selective but appears later.

confirmed low

a confirmed low appears when a pivot low is confirmed and the score is strong enough.

this signal is more selective but appears later.

how to use the alerts

the script includes separate alert conditions:

early high

early low

confirmed high

confirmed low

any early high or low

any confirmed high or low

for fast monitoring, use early alerts.

for cleaner monitoring, use confirmed alerts.

for fewer alerts, use only any confirmed high or low.

recommended anti-spam setup:

use confirmed signals only

increase cooldown between signals

use balanced or confirmed mode

keep pivot right bars at 3 or higher

increase the minimum score if there are too many signals

recommended beginner alert setup:

start with any confirmed high or low

use balanced mode

set cooldown between signals to 8 or more

keep score labels enabled

avoid using every alert condition at the same time

beginner tutorial

step 1: start with balanced mode

balanced mode is the best starting point because it avoids being too fast or too strict.

step 2: keep the default high and low zones

use 80 for the high zone and 20 for the low zone.

this gives a clean first reading.

step 3: watch the wave position

when the wave is above 80, price is stretched toward the high area.

when the wave is below 20, price is stretched toward the low area.

when the wave is around 50, the market is more balanced.

step 4: understand early signals

early signals are warnings.

early high means a possible local top area may be forming.

early low means a possible local bottom area may be forming.

do not enter a trade only because an early signal appears.

step 5: understand confirmed signals

confirmed signals are more selective.

confirmed high means a pivot high has been validated.

confirmed low means a pivot low has been validated.

these signals are slower because the script waits for confirmation.

step 6: read the score

a score near 50 is weaker.

a score near 65 is more acceptable.

a score above 75 is stronger.

a score above 85 means several filters agree.

step 7: confirm on the price chart

before using any signal, check:

trend direction

support and resistance

market structure

candle close

volume reaction

risk to reward

stop loss location

step 8: avoid overloading the chart

do not turn on every filter at once at the beginning.

start with:

balanced mode

wick rejection filter on

divergence in score on

atr exhaustion filter off

structure break filter off

cooldown enabled

after understanding the tool, activate atr exhaustion or structure break if you want stricter signals.

example 1: early high

price pushes upward and the wave moves above the high zone.

then the wave crosses back below the high zone.

an early high appears.

this means the upward push may be losing strength.

a beginner should wait for price rejection or a lower high before considering a short idea.

example 2: confirmed high

price forms a local high.

a few bars later, the pivot is confirmed.

the indicator prints confirmed high at the pivot location.

this is a stronger reference than an early high, but it appears later.

example 3: early low

price drops and the wave moves below the low zone.

then the wave crosses back above the low zone.

an early low appears.

this means downside pressure may be weakening.

a beginner should wait for support reaction or a higher low before considering a long idea.

example 4: confirmed low

price forms a local low.

a few bars later, the pivot is confirmed.

the indicator prints confirmed low at the pivot location.

this is a stronger reference than an early low, but it appears later.

example 5: using cooldown

if the market is volatile, the wave can create several signals close together.

cooldown prevents repeated signals from appearing too often.

higher cooldown values create a cleaner chart.

lower cooldown values create more frequent signals.

best use cases

spotting potential local highs

spotting potential local lows

detecting exhaustion zones

finding momentum fade areas

confirming high and low references with pivots

filtering noisy oscillator signals

building alerts for reversal watchlists

supporting discretionary trading decisions

important notes

early signals are faster but less confirmed.

confirmed signals are more selective but delayed.

pivot-based confirmation cannot appear instantly.

score is a filter, not a prediction.

buy and sell labels are only visual naming options.

the indicator should be combined with price action, structure, volume and risk management.

risk note

this indicator is for technical analysis and educational market study only. it does not provide financial advice, investment advice or guaranteed trading signals. all signals, markers, scores and alerts are references that require independent confirmation and proper risk management.

## Source Code

````pine
//@version=6
// ════════════════════════════════════════════════════════════════════════
//  WAVE — HIGH / LOW OSCILLATOR
// ════════════════════════════════════════════════════════════════════════
indicator("WAVE — HIGH / LOW OSCILLATOR [WIZARD]", overlay = false, max_labels_count = 200)

// ───────────────────────────── INPUTS ──────────────────────────────────
gE = "🌊 ENGINE"
src    = input.source(close, "Source", group = gE)
len    = input.int(14, "Length (Sensitivity)", minval = 2, maxval = 200, group = gE, tooltip = "Lower = faster & more reactive. Higher = smoother & slower.")
smooth = input.int(5, "Smoothing", minval = 1, maxval = 50, group = gE, tooltip = "Higher = cleaner wave, less noise.")
engine = input.string("Momentum Wave", "Engine", options = ["Momentum Wave", "RSI", "Blend"], group = gE)

gLv = "📐 LEVELS"
obLevel = input.int(80, "Overbought (HIGH zone)", minval = 50, maxval = 100, group = gLv)
osLevel = input.int(20, "Oversold (LOW zone)", minval = 0, maxval = 50, group = gLv)
showMid = input.bool(true, "Show Midline (50)", group = gLv)

gDet = "🎯 HIGH / LOW DETECTOR"
detMode = input.string("Balanced", "Detection Mode", options = ["Fast", "Balanced", "Confirmed"], group = gDet, tooltip = "Fast = early and reactive. Balanced = more filters. Confirmed = stricter and slower.")
showEarlyMarkers = input.bool(true, "Show Early HIGH / LOW", group = gDet)
showConfirmedMarkers = input.bool(true, "Show Confirmed HIGH / LOW", group = gDet)
minScore = input.int(65, "Balanced Minimum Score", minval = 0, maxval = 100, group = gDet)
pivotLeft = input.int(3, "Pivot Left Bars", minval = 1, maxval = 20, group = gDet)
pivotRight = input.int(3, "Pivot Right Bars", minval = 1, maxval = 20, group = gDet)
cooldownBars = input.int(8, "Cooldown Between Signals", minval = 0, maxval = 500, group = gDet)
showScoreLabels = input.bool(true, "Show Quality Score Labels", group = gDet)

gFilters = "🧬 OPTIONAL FILTERS"
useDivergence = input.bool(true, "Use Divergence In Score", group = gFilters)
useWickFilter = input.bool(true, "Wick Rejection Filter", group = gFilters)
wickMin = input.float(0.42, "Min Wick % Of Candle", minval = 0.10, maxval = 0.90, step = 0.01, group = gFilters)
useAtrFilter = input.bool(false, "ATR Exhaustion Filter", group = gFilters)
atrLen = input.int(14, "ATR Length", minval = 2, maxval = 100, group = gFilters)
atrMult = input.float(1.0, "ATR Exhaustion ×", minval = 0.1, maxval = 5.0, step = 0.1, group = gFilters)
useStructureFilter = input.bool(false, "Structure Break Filter", group = gFilters)
structureLen = input.int(5, "Structure Break Lookback", minval = 2, maxval = 50, group = gFilters)

gV = "✨ VISUALS"
showGlow   = input.bool(true, "Glow", group = gV)
glowBoost  = input.float(1.0, "Glow Intensity", minval = 0.2, maxval = 2.0, step = 0.1, group = gV)
showFill   = input.bool(true, "Bull/Bear Gradient Fill", group = gV)
fillTransp = input.int(76, "Fill Transparency", minval = 50, maxval = 96, group = gV)
showZones  = input.bool(true, "Tint HIGH / LOW Zones", group = gV)
theme      = input.string("Wizard", "Color Theme", options = ["Wizard", "Ice", "Inferno", "Toxic"], group = gV)

gM = "🎯 MARKERS"
enableMarkers  = input.bool(true, "Show HIGH / LOW Markers", group = gM)
markerStyle    = input.string("HIGH / LOW", "Marker Labels", options = ["HIGH / LOW", "BUY / SELL"], group = gM)
showZoneLabels = input.bool(true, "Show Zone Labels (right)", group = gM)

gD = "🧭 DASHBOARD"
showDash = input.bool(true, "Show Dashboard", group = gD)
dashPos  = input.string("Top Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = gD)

// ───────────────────────────── THEME ───────────────────────────────────
themeColors() =>
    cBull = color.rgb(0, 255, 209)
    cBear = color.rgb(255, 59, 92)
    cGold = color.rgb(255, 210, 63)
    if theme == "Ice"
        cBull := color.rgb(120, 220, 255)
        cBear := color.rgb(80, 120, 200)
        cGold := color.rgb(235, 245, 255)
    else if theme == "Inferno"
        cBull := color.rgb(255, 170, 40)
        cBear := color.rgb(255, 60, 60)
        cGold := color.rgb(255, 255, 255)
    else if theme == "Toxic"
        cBull := color.rgb(170, 255, 0)
        cBear := color.rgb(190, 60, 255)
        cGold := color.rgb(220, 255, 120)
    [cBull, cBear, cGold]

[cBull, cBear, cGold] = themeColors()
clampT(x) => int(math.max(0, math.min(100, x)))

f_score(bool extreme, bool superExtreme, bool slopeRev, bool wickOk, bool atrOk, bool divOk, bool structureOk, bool pivotOk) =>
    float s = 0.0
    s += extreme ? 20.0 : 0.0
    s += superExtreme ? 12.0 : 0.0
    s += slopeRev ? 13.0 : 0.0
    s += wickOk ? 15.0 : 0.0
    s += atrOk ? 10.0 : 0.0
    s += divOk ? 15.0 : 0.0
    s += structureOk ? 10.0 : 0.0
    s += pivotOk ? 15.0 : 0.0
    math.min(s, 100.0)

f_modeThreshold() =>
    detMode == "Fast" ? 35.0 : detMode == "Balanced" ? float(minScore) : 75.0

f_confThreshold() =>
    detMode == "Fast" ? 50.0 : detMode == "Balanced" ? float(minScore) : 75.0

// ──────────────────────── OSCILLATOR ENGINE ────────────────────────────

stochRaw = ta.stoch(close, high, low, len)
waveV    = ta.ema(ta.sma(stochRaw, 3), smooth)
rsiV     = ta.rsi(src, len)
rsiS     = ta.ema(rsiV, smooth)
blendV   = ta.ema((rsiV + stochRaw) / 2, smooth)
osc      = engine == "RSI" ? rsiS : engine == "Blend" ? blendV : waveV

// ───────────────────── HIGH / LOW DETECTOR ENGINE ──────────────────────
superOb = obLevel + (100.0 - obLevel) * 0.50
superOs = osLevel * 0.50

oscSlope = osc - osc[1]
oscSlopePrev = osc[1] - osc[2]

atr = ta.atr(atrLen)
emaBase = ta.ema(close, len)
rng = math.max(high - low, syminfo.mintick)
upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low
closePos = (close - low) / rng

prevStructHigh = ta.highest(high[1], structureLen)
prevStructLow = ta.lowest(low[1], structureLen)

pivotHighPrice = ta.pivothigh(high, pivotLeft, pivotRight)
pivotLowPrice = ta.pivotlow(low, pivotLeft, pivotRight)
pivotHighFound = not na(pivotHighPrice)
pivotLowFound = not na(pivotLowPrice)

xUnderOB = ta.crossunder(osc, obLevel)
xOverOS  = ta.crossover(osc, osLevel)

highExtremeNow = ta.highest(osc, len) >= obLevel
lowExtremeNow = ta.lowest(osc, len) <= osLevel
highSuperNow = ta.highest(osc, len) >= superOb
lowSuperNow = ta.lowest(osc, len) <= superOs

highWickOk = upperWick / rng >= wickMin and closePos <= 0.55
lowWickOk = lowerWick / rng >= wickMin and closePos >= 0.45
highAtrOk = high > emaBase + atr * atrMult
lowAtrOk = low < emaBase - atr * atrMult
highStructOk = close < prevStructLow
lowStructOk = close > prevStructHigh
highSlopeOk = oscSlope < 0
lowSlopeOk = oscSlope > 0

pOsc = osc[pivotRight]
pHighWickOk = upperWick[pivotRight] / math.max(high[pivotRight] - low[pivotRight], syminfo.mintick) >= wickMin and ((close[pivotRight] - low[pivotRight]) / math.max(high[pivotRight] - low[pivotRight], syminfo.mintick)) <= 0.55
pLowWickOk = lowerWick[pivotRight] / math.max(high[pivotRight] - low[pivotRight], syminfo.mintick) >= wickMin and ((close[pivotRight] - low[pivotRight]) / math.max(high[pivotRight] - low[pivotRight], syminfo.mintick)) >= 0.45
pHighAtrOk = high[pivotRight] > emaBase[pivotRight] + atr[pivotRight] * atrMult
pLowAtrOk = low[pivotRight] < emaBase[pivotRight] - atr[pivotRight] * atrMult
pHighSlopeOk = osc[pivotRight] < osc[pivotRight + 1]
pLowSlopeOk = osc[pivotRight] > osc[pivotRight + 1]
pHighExtremeOk = pOsc >= obLevel
pLowExtremeOk = pOsc <= osLevel
pHighSuperOk = pOsc >= superOb
pLowSuperOk = pOsc <= superOs

var float lastPivotHighPrice = na
var float lastPivotHighOsc = na
var float lastPivotLowPrice = na
var float lastPivotLowOsc = na

bearDiv = useDivergence and pivotHighFound and not na(lastPivotHighPrice) and high[pivotRight] > lastPivotHighPrice and pOsc < lastPivotHighOsc
bullDiv = useDivergence and pivotLowFound and not na(lastPivotLowPrice) and low[pivotRight] < lastPivotLowPrice and pOsc > lastPivotLowOsc

highScore = f_score(highExtremeNow, highSuperNow, highSlopeOk, highWickOk, highAtrOk, false, highStructOk, false)
lowScore = f_score(lowExtremeNow, lowSuperNow, lowSlopeOk, lowWickOk, lowAtrOk, false, lowStructOk, false)
confHighScore = f_score(pHighExtremeOk, pHighSuperOk, pHighSlopeOk, pHighWickOk, pHighAtrOk, bearDiv, highStructOk, pivotHighFound)
confLowScore = f_score(pLowExtremeOk, pLowSuperOk, pLowSlopeOk, pLowWickOk, pLowAtrOk, bullDiv, lowStructOk, pivotLowFound)

earlyHighFilter = (not useWickFilter or highWickOk) and (not useAtrFilter or highAtrOk) and (not useStructureFilter or highStructOk)
earlyLowFilter = (not useWickFilter or lowWickOk) and (not useAtrFilter or lowAtrOk) and (not useStructureFilter or lowStructOk)
confHighFilter = (not useWickFilter or pHighWickOk) and (not useAtrFilter or pHighAtrOk) and (not useStructureFilter or highStructOk)
confLowFilter = (not useWickFilter or pLowWickOk) and (not useAtrFilter or pLowAtrOk) and (not useStructureFilter or lowStructOk)

earlyHighRaw = xUnderOB and highScore >= f_modeThreshold() and earlyHighFilter
earlyLowRaw = xOverOS and lowScore >= f_modeThreshold() and earlyLowFilter
confirmedHighRaw = pivotHighFound and pHighExtremeOk and confHighScore >= f_confThreshold() and confHighFilter
confirmedLowRaw = pivotLowFound and pLowExtremeOk and confLowScore >= f_confThreshold() and confLowFilter

var int lastEarlyHighBar = na
var int lastEarlyLowBar = na
var int lastConfirmedHighBar = na
var int lastConfirmedLowBar = na

canEarlyHigh = na(lastEarlyHighBar) or bar_index - lastEarlyHighBar > cooldownBars
canEarlyLow = na(lastEarlyLowBar) or bar_index - lastEarlyLowBar > cooldownBars
canConfirmedHigh = na(lastConfirmedHighBar) or bar_index - lastConfirmedHighBar > cooldownBars
canConfirmedLow = na(lastConfirmedLowBar) or bar_index - lastConfirmedLowBar > cooldownBars

earlyHigh = enableMarkers and showEarlyMarkers and barstate.isconfirmed and earlyHighRaw and canEarlyHigh
earlyLow = enableMarkers and showEarlyMarkers and barstate.isconfirmed and earlyLowRaw and canEarlyLow
confirmedHigh = enableMarkers and showConfirmedMarkers and barstate.isconfirmed and confirmedHighRaw and canConfirmedHigh
confirmedLow = enableMarkers and showConfirmedMarkers and barstate.isconfirmed and confirmedLowRaw and canConfirmedLow

if earlyHigh
    lastEarlyHighBar := bar_index
if earlyLow
    lastEarlyLowBar := bar_index
if confirmedHigh
    lastConfirmedHighBar := bar_index
if confirmedLow
    lastConfirmedLowBar := bar_index

if pivotHighFound
    lastPivotHighPrice := high[pivotRight]
    lastPivotHighOsc := pOsc
if pivotLowFound
    lastPivotLowPrice := low[pivotRight]
    lastPivotLowOsc := pOsc

oscCol = color.from_gradient(osc, osLevel, obLevel, cBear, cBull)

// ───────────────────────────── PLOTS ───────────────────────────────────
g = glowBoost
plot(showGlow ? osc : na, "Glow Outer", color = color.new(oscCol, clampT(92 - 5  * g)), linewidth = 5)
plot(showGlow ? osc : na, "Glow Mid",   color = color.new(oscCol, clampT(80 - 8  * g)), linewidth = 4)
plot(showGlow ? osc : na, "Glow Inner", color = color.new(oscCol, clampT(64 - 11 * g)), linewidth = 3)
posc = plot(osc, "Wave", color = color.new(oscCol, 0), linewidth = 2)
plot(osc, "Core Sheen", color = color.new(color.white, 38), linewidth = 1)

pMid = plot(50, "Midline", color = color.new(cGold, showMid ? 55 : 100), linewidth = 1)
pOB  = plot(obLevel, "Overbought", color = color.new(cBull, 40), linewidth = 1)
pOS  = plot(osLevel, "Oversold",   color = color.new(cBear, 40), linewidth = 1)
pTop = plot(100, "Top", color = color.new(color.gray, 100), display = display.none)
pBot = plot(0,   "Bot", color = color.new(color.gray, 100), display = display.none)

ft = showFill ? fillTransp : 100
fill(posc, pMid, top_value = obLevel, bottom_value = osLevel, top_color = color.new(cBull, ft), bottom_color = color.new(cBear, ft), title = "Bull/Bear Fade")

zt = showZones ? 90 : 100
fill(pOB, pTop, color = color.new(cBull, zt), title = "High Zone")
fill(pOS, pBot, color = color.new(cBear, zt), title = "Low Zone")

// ─────────────────── HIGH / LOW REFERENCE MARKERS ──────────────────────
useTrade = markerStyle == "BUY / SELL"

plotshape(earlyHigh and not useTrade, "EARLY HIGH", shape.triangledown, location.top, color = color.new(cGold, 0), text = "e high", textcolor = cGold, size = size.tiny)
plotshape(earlyLow and not useTrade, "EARLY LOW", shape.triangleup, location.bottom, color = color.new(cGold, 0), text = "e low", textcolor = cGold, size = size.tiny)
plotshape(earlyHigh and useTrade, "EARLY SELL", shape.triangledown, location.top, color = color.new(cBear, 0), text = "e sell", textcolor = cBear, size = size.tiny)
plotshape(earlyLow and useTrade, "EARLY BUY", shape.triangleup, location.bottom, color = color.new(cBull, 0), text = "e buy", textcolor = cBull, size = size.tiny)

plotshape(confirmedHigh and not useTrade, "CONFIRMED HIGH", shape.labeldown, location.top, color = color.new(cGold, 0), text = "c high", textcolor = color.black, size = size.tiny, offset = -pivotRight)
plotshape(confirmedLow and not useTrade, "CONFIRMED LOW", shape.labelup, location.bottom, color = color.new(cGold, 0), text = "c low", textcolor = color.black, size = size.tiny, offset = -pivotRight)
plotshape(confirmedHigh and useTrade, "CONFIRMED SELL", shape.labeldown, location.top, color = color.new(cBear, 0), text = "c sell", textcolor = color.white, size = size.tiny, offset = -pivotRight)
plotshape(confirmedLow and useTrade, "CONFIRMED BUY", shape.labelup, location.bottom, color = color.new(cBull, 0), text = "c buy", textcolor = color.black, size = size.tiny, offset = -pivotRight)

// dots on the wave at exact reference points
plot(earlyHigh ? osc : na, "Early High Dot", color = color.new(cGold, 0), style = plot.style_circles, linewidth = 4)
plot(earlyLow ? osc : na, "Early Low Dot", color = color.new(cGold, 0), style = plot.style_circles, linewidth = 4)
plot(confirmedHigh ? pOsc : na, "Confirmed High Dot", color = color.new(cBear, 0), style = plot.style_circles, linewidth = 5, offset = -pivotRight)
plot(confirmedLow ? pOsc : na, "Confirmed Low Dot", color = color.new(cBull, 0), style = plot.style_circles, linewidth = 5, offset = -pivotRight)

// dynamic score labels
if showScoreLabels and earlyHigh
    label.new(bar_index, osc, "early high\n" + str.tostring(highScore, "#") + "/100", style = label.style_label_down, color = color.new(cGold, 18), textcolor = color.black, size = size.tiny)
if showScoreLabels and earlyLow
    label.new(bar_index, osc, "early low\n" + str.tostring(lowScore, "#") + "/100", style = label.style_label_up, color = color.new(cGold, 18), textcolor = color.black, size = size.tiny)
if showScoreLabels and confirmedHigh
    label.new(bar_index - pivotRight, pOsc, "confirmed high\n" + str.tostring(confHighScore, "#") + "/100", style = label.style_label_down, color = color.new(cBear, 10), textcolor = color.white, size = size.tiny)
if showScoreLabels and confirmedLow
    label.new(bar_index - pivotRight, pOsc, "confirmed low\n" + str.tostring(confLowScore, "#") + "/100", style = label.style_label_up, color = color.new(cBull, 10), textcolor = color.black, size = size.tiny)

alertcondition(earlyHigh, "WAVE — EARLY HIGH", "WAVE early high reference formed")
alertcondition(earlyLow, "WAVE — EARLY LOW", "WAVE early low reference formed")
alertcondition(confirmedHigh, "WAVE — CONFIRMED HIGH", "WAVE confirmed high reference formed")
alertcondition(confirmedLow, "WAVE — CONFIRMED LOW", "WAVE confirmed low reference formed")
alertcondition(earlyHigh or earlyLow, "WAVE — ANY EARLY HIGH / LOW", "WAVE early high or early low formed")
alertcondition(confirmedHigh or confirmedLow, "WAVE — ANY CONFIRMED HIGH / LOW", "WAVE confirmed high or confirmed low formed")

// ───────────────────────── ZONE LABELS ─────────────────────────
var label lHi  = na
var label lLo  = na
var label lBal = na
if barstate.islast and showZoneLabels
    x = bar_index + 3
    if na(lHi)
        lHi := label.new(x, obLevel, "HIGH", style = label.style_label_left, color = color.new(cBull, 25), textcolor = color.black, size = size.tiny)
    else
        label.set_xy(lHi, x, obLevel)
    if na(lLo)
        lLo := label.new(x, osLevel, "LOW", style = label.style_label_left, color = color.new(cBear, 25), textcolor = color.white, size = size.tiny)
    else
        label.set_xy(lLo, x, osLevel)
    if na(lBal)
        lBal := label.new(x, 50, "BALANCE", style = label.style_label_left, color = color.new(cGold, 40), textcolor = color.black, size = size.tiny)
    else
        label.set_xy(lBal, x, 50)

// ─────────────────────────── DASHBOARD ─────────────────────────────────
var table dash = na
if showDash and barstate.islast
    pos = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : position.bottom_left
    if na(dash)
        dash := table.new(pos, 2, 6, border_width = 1, border_color = color.new(color.gray, 60), frame_width = 1, frame_color = color.new(cGold, 40))
    bg = color.new(color.black, 12)
    state  = confirmedHigh ? "CONFIRMED HIGH" : confirmedLow ? "CONFIRMED LOW" : earlyHigh ? "EARLY HIGH" : earlyLow ? "EARLY LOW" : osc >= obLevel ? "HIGH ZONE" : osc <= osLevel ? "LOW ZONE" : osc >= 50 ? "BULLISH" : "BEARISH"
    stCol  = confirmedHigh or earlyHigh ? cBear : confirmedLow or earlyLow ? cBull : osc >= obLevel ? cBull : osc <= osLevel ? cBear : osc >= 50 ? cBull : cBear
    table.cell(dash, 0, 0, "WAVE", text_color = color.black, bgcolor = color.new(cGold, 0), text_size = size.small)
    table.cell(dash, 1, 0, "[WIZARD]", text_color = color.black, bgcolor = color.new(cBull, 0), text_size = size.small)
    table.cell(dash, 0, 1, "State", text_color = color.new(cGold, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, state, text_color = stCol, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 2, "Value", text_color = color.new(cGold, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(osc, "#.0"), text_color = color.new(color.white, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 3, "High Score", text_color = color.new(cGold, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, str.tostring(highScore, "#") + "/100", text_color = cBear, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 4, "Low Score", text_color = color.new(cGold, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(lowScore, "#") + "/100", text_color = cBull, bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
    table.cell(dash, 0, 5, "Mode", text_color = color.new(cGold, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, detMode, text_color = color.new(color.white, 0), bgcolor = bg, text_size = size.tiny, text_halign = text.align_right)
````
