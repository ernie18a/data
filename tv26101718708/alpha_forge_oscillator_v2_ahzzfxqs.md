# Alpha Forge Oscillator v2

- url: https://www.tradingview.com/script/AHzzFxqs-Alpha-Forge-Oscillator-v2/
- type: indicator
- pine_id: PUB;dfa419252ad64d47add95cad81624224
- version: 1.0

## Description

Alpha Forge Oscillator is an open-source momentum and pressure visualization tool designed to provide additional context below the price chart.

The script displays directional momentum, signal-line behavior, and changes in momentum expansion or contraction. It can be used alongside price action, trend tools, or other indicators to study whether momentum is rising, falling, flattening, or changing direction.

This script is provided for educational chart analysis. It does not predict future price movement and does not provide trading advice.

What It Shows

The oscillator is designed to display several types of momentum information:

Directional bias
Momentum expansion
Momentum contraction
Signal-line relationship
Possible exhaustion conditions
Bullish or bearish pressure changes

The goal is to provide a visual way to study internal momentum behavior, not to generate guaranteed trading outcomes.

How To Read It

When the oscillator rises, bullish momentum is increasing according to the script’s formula.

When the oscillator falls, bearish momentum is increasing according to the script’s formula.

When the oscillator flattens or contracts, momentum may be weakening or becoming less directional.

Bullish Context

Bullish momentum context may be present when the oscillator is above its center area, above its signal layer, or expanding upward.

Bearish Context

Bearish momentum context may be present when the oscillator is below its center area, below its signal layer, or expanding downward.

Mixed Context

Mixed or neutral context may be present when the oscillator is flat, compressed, near its center area, or frequently crossing its signal layer.

Using The Oscillator With Price

The oscillator can be used as supporting context when reviewing price action.

For example, users may compare:

Price direction versus oscillator direction
Trend movement versus momentum movement
Signal-line crosses
Momentum expansion versus contraction
Possible divergence between price and oscillator behavior

The oscillator should not be used as the only reason for entering or exiting a trade.

Companion Use

This oscillator can be used alongside the Alpha Forge Core indicator or as a standalone momentum display.

When used with the Core indicator, the main chart provides trend and structure context, while the oscillator provides momentum context.

When used by itself, the oscillator can help users study pressure shifts and momentum behavior below the chart.

Possible Use Cases

Momentum review
Trend-context confirmation
Divergence study
Exhaustion study
Continuation or reversal research
Comparing price movement with internal pressure

These use cases are for chart study only and should be combined with independent analysis.

Markets And Timeframes

The oscillator can be applied to different markets, including stocks, crypto, forex, and indices.

It can also be used on different timeframes. Lower timeframes may produce more frequent movement, while higher timeframes may produce smoother readings.

Important Notes

This script is open source.

It is for educational and research use.

It does not provide financial advice.

It does not guarantee signal accuracy.

It does not guarantee future results.

It should not be used as the only basis for trading decisions.

All colors, labels, lines, and visual states are based on the script’s programmed conditions and should be interpreted as informational chart context only.

## Source Code

````pine
//@version=6
indicator("Alpha Forge Oscillator v2", shorttitle="AFO2", overlay=false, precision=3)

//============================
// INPUTS
//============================
groupMode   = "Mode"
groupVisual = "Visuals"
groupLevels = "Levels"
groupDash   = "Dashboard"
groupAlerts = "Alerts"

mode = input.string("Day", "Mode", options=["Scalp", "Day", "Swing"], group=groupMode)

showHistogram   = input.bool(true, "Show Histogram", group=groupVisual)
showSignalLine  = input.bool(true, "Show Signal Line", group=groupVisual)
showMarkers     = input.bool(true, "Show Markers", group=groupVisual)
showBgFill      = input.bool(true, "Show Zone Fill", group=groupVisual)
showStrengthBar = input.bool(true, "Show Strength Bar", group=groupVisual)

extremeLevel = input.float(1.75, "Extreme Level", minval=0.5, step=0.05, group=groupLevels)
warnLevel    = input.float(1.00, "Warning Level", minval=0.2, step=0.05, group=groupLevels)

showDashboard = input.bool(true, "Show Dashboard", group=groupDash)
dashboardSize = input.string("Small", "Dashboard Size", options=["Small", "Medium", "Large"], group=groupDash)

enableZeroCrossAlerts = input.bool(true, "Enable Zero Cross Alerts", group=groupAlerts)
enableSignalAlerts    = input.bool(true, "Enable Signal Cross Alerts", group=groupAlerts)
enableReversalAlerts  = input.bool(true, "Enable Reversal Setup Alerts", group=groupAlerts)

//============================
// MODE PRESETS
//============================
int trendLen = switch mode
    "Scalp" => 21
    "Day"   => 34
    => 55

float bandMult = switch mode
    "Scalp" => 1.00
    "Day"   => 1.25
    => 1.50

int oscSmooth = switch mode
    "Scalp" => 3
    "Day"   => 5
    => 8

int sigSmooth = switch mode
    "Scalp" => 2
    "Day"   => 4
    => 6

//============================
// COLORS
//============================
bull    = color.rgb(0, 255, 187)
bear    = color.rgb(255, 70, 70)
neutral = color.rgb(140, 140, 155)

dashTextSize = dashboardSize == "Small" ? size.tiny : dashboardSize == "Medium" ? size.small : size.normal

//============================
// CORE MATCHING ENGINE
//============================
lag   = math.floor((trendLen - 1) / 2)
basis = ta.ema(close + (close - close[lag]), trendLen)

atrVal = ta.atr(trendLen)
vol    = ta.highest(atrVal, trendLen * 3) * bandMult

rawOsc = vol != 0 ? (close - basis) / vol : 0.0
osc    = ta.ema(rawOsc, oscSmooth)
sig    = ta.ema(osc, sigSmooth)
hist   = osc - sig

//============================
// STATES
//============================
bullBias = osc > 0
bearBias = osc < 0

bullCrossZero = ta.crossover(osc, 0)
bearCrossZero = ta.crossunder(osc, 0)

bullCrossSig = ta.crossover(osc, sig)
bearCrossSig = ta.crossunder(osc, sig)

histRisingBull  = hist > 0 and hist > hist[1]
histFallingBear = hist < 0 and hist < hist[1]

bullContinuation = bullBias and osc > sig and histRisingBull
bearContinuation = bearBias and osc < sig and histFallingBear

bullReversalSetup = osc < -warnLevel and osc > osc[1] and osc[1] < osc[2]
bearReversalSetup = osc > warnLevel and osc < osc[1] and osc[1] > osc[2]

bullExtreme = osc < -extremeLevel
bearExtreme = osc > extremeLevel

//============================
// STRENGTH MODEL
//============================
strengthRaw = math.min(1.0, math.abs(osc) / extremeLevel)
strengthPct = math.round(strengthRaw * 100)

strengthText =
     bullBias ? (strengthPct >= 75 ? "Strong Bull" : strengthPct >= 40 ? "Bull Bias" : "Weak Bull") :
     bearBias ? (strengthPct >= 75 ? "Strong Bear" : strengthPct >= 40 ? "Bear Bias" : "Weak Bear") :
     "Neutral"

oscColor =
     bullBias ? (strengthPct >= 75 ? bull : color.new(bull, 20)) :
     bearBias ? (strengthPct >= 75 ? bear : color.new(bear, 20)) :
     neutral

histColor =
     hist >= 0 ? (histRisingBull ? color.new(bull, 15) : color.new(bull, 45)) :
     (histFallingBear ? color.new(bear, 15) : color.new(bear, 45))

sigColor = color.new(color.white, 25)

//============================
// LEVELS
//============================
hline(0, "Zero", color=color.new(color.gray, 45))
hline(warnLevel, "+Warn", color=color.new(bull, 75))
hline(-warnLevel, "-Warn", color=color.new(bear, 75))
hline(extremeLevel, "+Extreme", color=color.new(bull, 85))
hline(-extremeLevel, "-Extreme", color=color.new(bear, 85))

//============================
// MAIN PLOTS
//============================
zeroPlot = plot(0, display=display.none)
oscPlot  = plot(osc, "Oscillator", color=oscColor, linewidth=2)
sigPlot  = plot(showSignalLine ? sig : na, "Signal", color=sigColor, linewidth=1)
histPlot = plot(showHistogram ? hist : na, "Histogram", style=plot.style_columns, color=histColor)

//============================
// BACKGROUND FILL
//============================
fill(
     oscPlot,
     zeroPlot,
     color = showBgFill
         ? (bullBias ? color.new(bull, 90) : bearBias ? color.new(bear, 90) : color.new(neutral, 95))
         : na
)

//============================
// STRENGTH BAR
//============================
strengthBarTop = 2.2
strengthBarBottom = 1.60

strengthBasePlot = plot(showStrengthBar ? strengthBarBottom : na, display=display.none)
strengthTopPlot  = plot(showStrengthBar ? strengthBarTop : na, display=display.none)

// Full faint band
fill(strengthBasePlot, strengthTopPlot, color=color.new(neutral, 92))

// Direction/intensity overlay
strengthLevel = strengthBarBottom + (strengthBarTop - strengthBarBottom) * strengthRaw
strengthFillPlot = plot(showStrengthBar ? strengthLevel : na, display=display.none)

strengthColor =
     bullBias ? color.new(bull, math.max(5, 75 - int(strengthPct * 0.7))) :
     bearBias ? color.new(bear, math.max(5, 75 - int(strengthPct * 0.7))) :
     color.new(neutral, 80)

fill(strengthBasePlot, strengthFillPlot, color=showStrengthBar ? strengthColor : na)

//============================
// MARKERS
//============================
plotshape(showMarkers and bullCrossZero ? osc : na, title="Bull Zero Cross", style=shape.circle, location=location.absolute, color=bull, size=size.tiny)
plotshape(showMarkers and bearCrossZero ? osc : na, title="Bear Zero Cross", style=shape.circle, location=location.absolute, color=bear, size=size.tiny)

plotshape(showMarkers and bullCrossSig ? osc : na, title="Bull Signal Cross", style=shape.triangleup, location=location.absolute, color=bull, size=size.tiny)
plotshape(showMarkers and bearCrossSig ? osc : na, title="Bear Signal Cross", style=shape.triangledown, location=location.absolute, color=bear, size=size.tiny)

plotshape(showMarkers and bullReversalSetup ? osc : na, title="Bull Reversal Setup", style=shape.diamond, location=location.absolute, color=color.new(bull, 0), size=size.tiny)
plotshape(showMarkers and bearReversalSetup ? osc : na, title="Bear Reversal Setup", style=shape.diamond, location=location.absolute, color=color.new(bear, 0), size=size.tiny)

//============================
// STATUS STRINGS
//============================
biasText =
     bullContinuation ? "Bull Continuation" :
     bearContinuation ? "Bear Continuation" :
     bullBias ? "Bull Bias" :
     bearBias ? "Bear Bias" :
     "Neutral"

stretchText =
     bullExtreme ? "Oversold Extreme" :
     bearExtreme ? "Overbought Extreme" :
     bullReversalSetup ? "Bull Reversal Setup" :
     bearReversalSetup ? "Bear Reversal Setup" :
     "Normal"

//============================
// DASHBOARD
//============================
if showDashboard
    var table info = table.new(position.top_right, 2, 3, bgcolor=color.new(chart.bg_color, 8), border_width=1, border_color=color.new(chart.fg_color, 80), frame_color=color.new(chart.fg_color, 80), frame_width=1)
    if barstate.islast
        table.cell(info, 0, 0, "Metric", text_color=chart.fg_color, text_halign=text.align_center, bgcolor=color.new(neutral, 88), text_size=dashTextSize)
        table.cell(info, 1, 0, "State", text_color=chart.fg_color, text_halign=text.align_center, bgcolor=color.new(neutral, 88), text_size=dashTextSize)

        biasBg =
             bullContinuation ? color.new(bull, 62) :
             bearContinuation ? color.new(bear, 62) :
             bullBias ? color.new(bull, 78) :
             bearBias ? color.new(bear, 78) :
             color.new(neutral, 88)

        table.cell(info, 0, 1, "Bias", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(info, 1, 1, biasText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=biasBg, text_size=dashTextSize)

        stretchBg =
             bullExtreme or bullReversalSetup ? color.new(bull, 78) :
             bearExtreme or bearReversalSetup ? color.new(bear, 78) :
             color.new(neutral, 88)

        table.cell(info, 0, 2, "Stretch", text_color=chart.fg_color, text_halign=text.align_center, text_size=dashTextSize)
        table.cell(info, 1, 2, stretchText, text_color=chart.fg_color, text_halign=text.align_center, bgcolor=stretchBg, text_size=dashTextSize)

//============================
// ALERTS
//============================
alertcondition(enableZeroCrossAlerts and bullCrossZero, "Alpha Forge Osc Bullish Zero Cross", "Alpha Forge Oscillator bullish zero cross on {{ticker}} {{interval}}")
alertcondition(enableZeroCrossAlerts and bearCrossZero, "Alpha Forge Osc Bearish Zero Cross", "Alpha Forge Oscillator bearish zero cross on {{ticker}} {{interval}}")

alertcondition(enableSignalAlerts and bullCrossSig, "Alpha Forge Osc Bullish Signal Cross", "Alpha Forge Oscillator bullish signal cross on {{ticker}} {{interval}}")
alertcondition(enableSignalAlerts and bearCrossSig, "Alpha Forge Osc Bearish Signal Cross", "Alpha Forge Oscillator bearish signal cross on {{ticker}} {{interval}}")

alertcondition(enableReversalAlerts and bullReversalSetup, "Alpha Forge Osc Bullish Reversal Setup", "Alpha Forge Oscillator bullish reversal setup on {{ticker}} {{interval}}")
alertcondition(enableReversalAlerts and bearReversalSetup, "Alpha Forge Osc Bearish Reversal Setup", "Alpha Forge Oscillator bearish reversal setup on {{ticker}} {{interval}}")
````
