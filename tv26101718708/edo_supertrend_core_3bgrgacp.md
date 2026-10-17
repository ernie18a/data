# Edo SuperTrend Core

- url: https://www.tradingview.com/script/3bGRGaCp-Edo-SuperTrend-Core/
- type: indicator
- pine_id: PUB;6e2f069d059f4645b49e92c7060ed931
- version: 1.0

## Description

Edo SuperTrend Core — Clean Single-Line SuperTrend with RSI Trend Confirmation, Directional Intensity Fill and Trend Duration Counter

SuperTrend, created by Olivier Seban, is one of the most widespread trend-following indicators: it uses the Average True Range (ATR), introduced by J. Welles Wilder, to build a dynamic trailing stop that switches sides when price crosses it. It is clear and effective, but it has a known limitation: in sideways or noisy markets it produces false flips —trend changes that reverse within a few bars— and, drawn the classic way with its two bands, it clutters the chart.

Edo SuperTrend Core was built to solve those two things. It keeps the original SuperTrend algorithm, but adds a momentum confirmation filter that requires the RSI to agree before accepting a trend change, and simplifies the representation to a single line with an intensity fill and a duration counter. The goal is a clean trend reading with fewer false turns, without giving up the classic logic.

Edo SuperTrend Core does not generate automatic buy or sell signals: it visualizes the state and the maturity of the trend so the trader can integrate it into their own judgment.

WHAT THE INDICATOR DOES

The indicator combines four elements on a single layer. The SuperTrend line is a single dynamic level that acts at once as a trend reference and as the flip level, the closing price that, if crossed, would change the trend. The RSI confirmation filter requires momentum to agree in order to validate a trend change. The directional intensity fill, between price and the line, highlights the phase of the move. And the duration counter shows how many bars the current trend has been active.

CONCEPTUAL CALCULATION BASIS

The base is the classic SuperTrend: the ATR measures volatility and, from a multiple of that ATR, a dynamic level is computed that sits below price in an uptrend and above price in a downtrend. In the classic implementation two bands are plotted; here only the active level is shown, which keeps the chart cleaner.

On top of that base, Edo SuperTrend Core adds its own layer: when the SuperTrend signals a trend change, that change is only accepted if the 14-period RSI confirms it, above 50 to validate a bullish turn and below 50 to validate a bearish one. If momentum does not agree, the indicator keeps the previous trend. This filter is the central difference versus a standard SuperTrend: it discards part of the flips that noise generates in sideways markets. The basic reading is direct: with the SuperTrend below price the trend is bullish, and with the SuperTrend above price, bearish.

SENSITIVITY PROFILES

A single selector adjusts the behavior of the SuperTrend by modifying the internal ATR parameters. The Fast profile uses ATR 7 and factor 2.0: higher sensitivity, reacts sooner and produces more changes, useful on lower timeframes. The Balanced profile uses ATR 10 and factor 2.3: it is the default setting, balancing reactivity and stability. The Slow profile uses ATR 14 and factor 3.0: smoother and more stable detection, with fewer turns, useful on higher timeframes.

INTENSITY FILL

Between price and the SuperTrend line a fill is drawn whose color follows the direction of the trend and whose opacity is configurable. Its purpose is to make the phase and the magnitude of the separation between price and level visible at a glance: the greater the distance, the more extended the move is relative to its trailing stop. The RSI, besides filtering the trend changes, provides the momentum context that accompanies that phase, whether expansion, consolidation or exhaustion.

TREND DURATION COUNTER

Each time the trend changes, the indicator writes at the midpoint of the previous leg the number of bars that trend lasted. It is a purely informative figure that helps judge the maturity of the move: a trend that has already accumulated many more bars than the previous ones may be more extended, whereas a freshly started one is barely beginning to develop.

ALERTS

Edo SuperTrend Core includes four alert conditions configurable from the standard TradingView alerts dialog, split into two levels according to the momentum filter. The confirmed bullish trend change fires when the flip to bullish has passed the RSI filter, with momentum agreeing; it is the indicator's definitive trend signal. The confirmed bearish trend change is its downside equivalent. The raw flip up warns that price has crossed the SuperTrend line upward, still pending RSI confirmation, and serves as an early warning of a possible turn not yet validated; the raw flip down is its bearish equivalent. The confirmed and raw pair lets the trader choose their level of anticipation: the raw flip warns sooner but may reverse, while the confirmed one arrives a step later but has already filtered out part of the false turns.

HOW TO READ IT

The position of the line relative to price defines the trend and its side, and the color confirms the state at a glance. When a trend change occurs it is worth remembering that it has already passed the RSI filter, that is, that momentum was agreeing: turns confirmed by momentum tend to be more reliable than a pure SuperTrend flip. The fill and the separation between price and line indicate whether the move is expanding or losing strength. The duration counter places the current trend against the previous ones, and a trend well above the usual duration invites watching the flip level more closely. That flip level, the level of the line, is the closing price that would change the trend and serves as a dynamic stop reference.

ORIGINALITY AND JUSTIFICATION

Olivier Seban's SuperTrend and Wilder's RSI and ATR are public-domain classics, and Edo SuperTrend Core names and credits them without reservation. What it adds over a standard SuperTrend is specific: an RSI confirmation filter that discards part of the false flips of the classic SuperTrend in sideways markets, a single-line representation instead of the two bands, an intensity fill that makes the phase of the move legible, and a duration counter that adds a maturity reading. The combination of momentum filter, phase reading and duration is what distinguishes this version, not the base algorithm.

CONFIGURATION

Profile: Fast, Balanced or Slow, which adjusts the ATR and the factor. Gradient Opacity: the visual intensity of the fill, from 10 to 100%. All calculations adapt automatically to the chart's timeframe.

OPEN SOURCE

Edo SuperTrend Core is published as an open source and free indicator. The full Pine Script is publicly available on TradingView for study, adaptation and integration into any workflow.

This indicator is a technical analysis tool intended exclusively for educational and informational purposes. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading in financial markets carries a significant risk of capital loss. Past results do not guarantee future results. Always use proper risk management.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────
// ███████╗██████╗  ██████╗ ██╗      █████╗ ██████╗
// ██╔════╝██╔══██╗██╔═══██╗██║     ██╔══██╗██╔══██╗
// █████╗  ██║  ██║██║   ██║██║     ███████║██████╔╝
// ██╔══╝  ██║  ██║██║   ██║██║     ██╔══██║██╔══██╗
// ███████╗██████╔╝╚██████╔╝███████╗██║  ██║██████╔╝
// ╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═════╝
// ─────────────────────────────────────────────────────────────────
// ███╗   ███╗ █████╗ ██████╗ ██╗  ██╗███████╗████████╗███████╗
// ████╗ ████║██╔══██╗██╔══██╗██║ ██╔╝██╔════╝╚══██╔══╝██╔════╝
// ██╔████╔██║███████║██████╔╝█████╔╝ █████╗     ██║   ███████╗
// ██║╚██╔╝██║██╔══██║██╔══██╗██╔═██╗ ██╔══╝     ██║   ╚════██║
// ██║ ╚═╝ ██║██║  ██║██║  ██║██║  ██╗███████╗   ██║   ███████║
// ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
// ─────────────────────────────────────────────────────────────────
// © Edolab Markets
//@version=6
// v1.1 — Added alert conditions: confirmed (RSI-filtered) trend changes + raw SuperTrend flips
indicator("Edo SuperTrend Core", overlay=true, max_labels_count=500)

//━━━━━━━━━━ INPUTS
profile = input.string("Balanced","Profile",options=["Fast","Balanced","Slow"])
opacity = input.int(70,"Gradient Opacity",options=[10,20,30,40,50,60,70,80,90,100])

//━━━━━━━━━━ SUPERTREND CONFIG
atrPeriod = profile=="Fast"?7:profile=="Balanced"?10:14
factor = profile=="Fast"?2.0:profile=="Balanced"?2.3:3.0

rsi = ta.rsi(close,14)
atr14 = ta.atr(14)  // extracted to global scope so ta.atr runs every bar (v6 consistency)

//━━━━━━━━━━ SUPERTREND
[st,dir] = ta.supertrend(factor,atrPeriod)
supertrend = barstate.isfirst ? na : st

direction = dir
if dir < 0 and rsi <= 50
    direction := direction[1]
if dir > 0 and rsi >= 50
    direction := direction[1]

//━━━━━━━━━━ COLORS
bullStrong = color.rgb(0,230,118)
bearStrong = color.rgb(255,82,82)

//━━━━━━━━━━ ST LINE
plotBand = plot(supertrend,"SuperTrend",color=direction<0?bullStrong:bearStrong,style=plot.style_linebr,linewidth=3)

// hidden price for gradient
plotPrice = plot(hl2,"",display=display.none)

topValue = math.max(hl2,supertrend)
bottomValue = math.min(hl2,supertrend)

topColor = direction<0 ? color.new(bullStrong,100-opacity) : color.new(bearStrong,100-opacity)
bottomColor = direction<0 ? color.new(bullStrong,90) : color.new(bearStrong,90)

fill(plotBand,plotPrice,topValue,bottomValue,topColor,bottomColor)

//━━━━━━━━━━ TREND COUNTER
var int trendBars = 0
var int startBar = bar_index

trendChange = direction != direction[1]

if trendChange
    duration = trendBars
    midBar = startBar + duration/2
    trendColor = direction[1] < 0 ? bullStrong : bearStrong
    label.new(midBar, direction[1] < 0 ? supertrend + atr14*1.8 : supertrend - atr14*1.8, text=str.tostring(duration), style=label.style_label_center, color=color.new(trendColor,70), textcolor=color.white, size=size.small)
    trendBars := 0
    startBar := bar_index

trendBars += 1

//━━━━━━━━━━ ALERTS
// direction < 0 = bullish (price above the SuperTrend line); confirmed changes are already RSI-filtered
rawBullFlip = dir < 0 and dir[1] >= 0
rawBearFlip = dir > 0 and dir[1] <= 0
alertcondition(trendChange and direction < 0, title="Confirmed Bullish Trend Change", message="Edo SuperTrend Core: confirmed BULLISH trend change (RSI-filtered)")
alertcondition(trendChange and direction > 0, title="Confirmed Bearish Trend Change", message="Edo SuperTrend Core: confirmed BEARISH trend change (RSI-filtered)")
alertcondition(rawBullFlip, title="Raw SuperTrend Flip Up (unfiltered)", message="Edo SuperTrend Core: price crossed the SuperTrend line UP - raw flip, pending RSI confirmation")
alertcondition(rawBearFlip, title="Raw SuperTrend Flip Down (unfiltered)", message="Edo SuperTrend Core: price crossed the SuperTrend line DOWN - raw flip, pending RSI confirmation")
````
