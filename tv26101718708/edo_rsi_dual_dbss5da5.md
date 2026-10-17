# Edo RSI Dual

- url: https://www.tradingview.com/script/DBss5Da5-Edo-RSI-Dual/
- type: indicator
- pine_id: PUB;6bd2b41448f847baa6f543a4fcbe4048
- version: 1.0

## Description

Edo RSI Dual — Five-Zone RSI System with Filtered Diamond Crosses, Momentum Histogram and Real-Time Dashboard

The classic Wilder RSI is one of the most widely used oscillators in technical analysis, but its traditional binary reading — overbought versus oversold — leaves out a large part of the information the oscillator actually contains. An RSI at 65 is not the same as an RSI at 75, and a cross inside the neutral zone does not carry the same significance as a cross in extreme territory.

Edo RSI Dual was built to address that. It coordinates two RSI readings of opposite nature on the same panel, splits the structural RSI into a five-zone dynamic colour scheme, filters cross signals by zone, and condenses the full reading into a real-time dashboard. The result is an oscillator that keeps the familiarity of the classic RSI but adds a contextual layer that makes every cross, every zone and every histogram bar interpretable within a coloured map.


THE TWO LAYERS

RSI 14 — Structural layer
The standard 14-period Wilder RSI. Width 2. Coloured dynamically according to the zone it currently sits in (five different shades). Acts as the structural momentum reference and defines the bias of the market on the analysed timeframe.

RSI 2 — Reactive layer
The 2-period Connors RSI. Width 1. Fixed gold colour. Sweeps the 0–100 range with rapid jumps and reaches extremes in very few bars. Its purpose is not to be read in isolation but to interact with the structural RSI 14 to produce filtered crosses.

Both lines share the standard RSI 0–100 axis, but their behaviour is radically different: the RSI 14 moves smoothly while the RSI 2 oscillates with sharp jumps. That tempo difference is what makes their crosses meaningful.


THE FIVE-ZONE COLOR SYSTEM

Edo RSI Dual splits the 0–100 RSI 14 range into five colour bands. Each band has a specific reading and colour, and the line transitions colour in real time as it moves between zones.

— RSI 14 ≥ Overbought Level → Dark red — Stretched bullish momentum
— 60 ≤ RSI 14 < OB → Light red — Approaching overbought
— 40 < RSI 14 < 60 → Dark teal — Neutral
— OS < RSI 14 ≤ 40 → Light green — Approaching oversold
— RSI 14 ≤ Oversold Level → Dark green — Stretched bearish momentum

The colour scheme is contrarian to the directional bias: overbought is painted red (potential sell zone) and oversold green (potential buy zone). This convention is consistent across the indicator: RSI 14 line, momentum histogram, dashboard state row and signal filters.

The transition between zones is one of the key visual elements. By colour alone, you can tell at a glance which segment of the range the oscillator currently sits in without having to read the numeric value.


MOMENTUM HISTOGRAM (RSI 14 vs 50)

The histogram is calculated as RSI 14 − 50. Above zero means the RSI sits above its centerline (predominant bullish strength); below zero means the opposite.

The histogram inherits the same five-zone palette as the RSI 14 line. Bars are painted in solid red when the RSI 14 is in overbought, faded red when near OB, grey in the neutral zone, faded green near OS and solid green in oversold. This turns the histogram into a simultaneous double reading: direction (side of the zero line) and zone (palette).


SLOW LINES

Two dashed slow lines act as a smoothing reference layer over the main RSI lines:

— Slow RSI 14 — SMA of the RSI 14, default period 14, drawn in faded teal and dashed style.
— Slow RSI 2 — SMA of the RSI 2, default period 14, drawn in faded gold and dashed style.

The slow lines do not generate signals on their own. They provide a visual reference of the average bias of each oscillator: when the RSI 14 main line sits above its slow line, structural momentum is in an expansive phase; below, it is contractive. The same applies to the RSI 2 with the caveat that its volatility makes the reading less stable.


DIAMOND SIGNALS — FILTERED CROSSES

The signal system is built on a strict premise: a cross between RSI 2 and RSI 14 is only relevant when it occurs inside an extreme zone. All other crosses are ignored.

◆ Bull Diamond — Gold
Plotted when:
— The RSI 2 crosses above the RSI 14 (bullish cross)
— The RSI 14 sits in the oversold zone (RSI 14 ≤ Oversold Level)

◆ Bear Diamond — Crimson
Plotted when:
— The RSI 2 crosses below the RSI 14 (bearish cross)
— The RSI 14 sits in the overbought zone (RSI 14 ≥ Overbought Level)

The diamond is drawn at the RSI 2 value on the cross bar, inside the corresponding extreme zone. Every signal is recorded in the dashboard with its type and the number of bars since it appeared, allowing recent signals to be distinguished from older ones that may have lost contextual validity.


BACKGROUND BIAS AND MIDLINE

Background bias colours the panel background according to the RSI 14 position relative to the 50 line. Faint green when RSI 14 is above 50 (active bullish bias), faint red when below (active bearish bias). The colour transparency is high so it does not interfere with line and histogram readability.

The 50 midline is drawn as a horizontal grey dotted line and serves both as the visual reference of the histogram axis and as the bias threshold.


OB/OS ZONES

The extreme zones are defined by two configurable parameters: Overbought Level (default 70) and Oversold Level (default 30). Each level is drawn as a dashed horizontal line in red and green respectively, and the area between each level and the panel edge is filled with a faded shade of the corresponding colour. The fill bands serve two purposes: they visually frame the extreme zones and act as the validation area for the Diamond Signals.


REAL-TIME DASHBOARD

The dashboard condenses the full reading of the indicator into a compact panel that updates bar by bar. Eight rows:

— Edo RSI Dual — Header
— RSI 14 — Numeric value with state [OB / NEU / OS]
— RSI 2 — Numeric value with state [OB / NEU / OS] (internal thresholds 90/10)
— Momentum — RSI 14 − 50 difference with sign
— State — Zone label (Overbought, Near OB, Neutral, Near OS, Oversold)
— Signal — Last detected Diamond signal (◆ BULL OS, ◆ BEAR OB, or —)
— Signal Age — Bars since the last signal. Highlighted in green if ≤ 3 bars
— Footer — "◆ Cross in OB/OS Zone"

Position is configurable in any of the four corners. Theme switches between Dark and Light.


ALERTS

Three configurable alert conditions:

— Bull Cross ◆ (OS) — RSI 2 bullish cross over RSI 14 inside the oversold zone
— Bear Cross ◆ (OB) — RSI 2 bearish cross under RSI 14 inside the overbought zone
— Momentum Zero Cross — RSI 14 crosses the 50 midline (directional bias change)

The first two correspond directly to the Diamond Signals. The third captures any change of momentum sign relative to the midline regardless of whether a Diamond is triggered.


CONFIGURATION

— Display: independent toggles for RSI 14, RSI 2, slow lines, momentum histogram, OB/OS zones, background bias, midline, Diamond signals and dashboard
— Levels: Overbought (range 50–95, default 70) and Oversold (range 5–50, default 30)
— Slow Lines: independent SMA periods for RSI 14 and RSI 2 (range 2–50, default 14)
— Dashboard: position (Top Right / Top Left / Bottom Right / Bottom Left) and theme (Dark / Light)


HOW TO READ IT

A clean reading follows three steps.

1 — Read the zone first
The RSI 14 colour tells you immediately where the oscillator stands. Red shades mean stretched bullish momentum, green shades mean stretched bearish momentum. Neutral teal means there is no extreme bias to act on.

2 — Watch the RSI 2 inside the extreme zones
When the RSI 14 enters overbought or oversold, the RSI 2 becomes the trigger. Crosses between the two lines outside extreme zones are filtered out — they will not produce a Diamond. Inside the extreme zones, a cross is meaningful and the indicator marks it visibly.

3 — Use the dashboard for context
State and Signal Age give you the current zone and how long ago the last signal fired. A recent signal (≤ 3 bars) carries fresh contextual relevance; an older signal may have already been consumed by price.


OPEN SOURCE

Edo RSI Dual is published as a free open source indicator. The full Pine Script is publicly accessible on TradingView for study, adaptation and integration into any workflow. Part of the Edolab Markets free tools ecosystem alongside Edo EMA Core Cross, Edo Sentiment Map, Edo SuperTrend Core, Edo TRIX Core Cross, Edo Multi Stoch and Edo ZigZag Auto Fib SR.


This indicator is a technical analysis tool for educational and informational purposes only. It does not generate automatic buy or sell signals and should not be considered financial advice. Trading financial markets involves significant risk of capital loss. Past performance does not guarantee future results. Always use proper risk management.

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
indicator("Edo RSI Dual", shorttitle="Edo RSI Dual", overlay=false, max_lines_count=500)

// ======================================
// INPUTS — DISPLAY
// ======================================
showRSI14     = input.bool(true,  "Show RSI 14",                 group="Display")
showRSI2      = input.bool(true,  "Show RSI 2",                  group="Display")
showSlowLines = input.bool(true,  "Show Slow Lines (SMA)",       group="Display")
showHist      = input.bool(true,  "Show Momentum Histogram",     group="Display")
showZones     = input.bool(true,  "Show OB/OS Zones",            group="Display")
showBgBias    = input.bool(true,  "Show Background Bias",        group="Display")
showMid       = input.bool(true,  "Show Midline (50)",           group="Display")
showSignals   = input.bool(true,  "Show Diamond Signals",        group="Display")
showTable     = input.bool(true,  "Show Dashboard",              group="Display")
tablePosInput = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Display")
themeInput    = input.string("Dark", "Dashboard Theme", options=["Dark","Light"], group="Display")

// ======================================
// INPUTS — LEVELS
// ======================================
obLevel = input.int(70, "Overbought Level", minval=50, maxval=95, group="Levels")
osLevel = input.int(30, "Oversold Level",   minval=5,  maxval=50, group="Levels")

// ======================================
// INPUTS — SLOW LINES
// ======================================
slowLen14 = input.int(14, "RSI 14 Slow SMA Period", minval=2, maxval=50, group="Slow Lines")
slowLen2  = input.int(14, "RSI 2 Slow SMA Period",  minval=2, maxval=50, group="Slow Lines")

// ======================================
// CALCULATIONS
// ======================================
rsi14    = ta.rsi(close, 14)
rsi2     = ta.rsi(close, 2)
momentum = rsi14 - 50

slowRSI14 = ta.sma(rsi14, slowLen14)
slowRSI2  = ta.sma(rsi2,  slowLen2)

// ======================================
// THEME COLORS (dashboard)
// ======================================
isDark   = themeInput == "Dark"
bgHeader = isDark ? color.new(#5B9FAD, 20)     : color.new(#5B9FAD, 40)
bgCell   = isDark ? color.new(color.black, 70) : color.new(color.white, 10)
bgFooter = isDark ? color.new(color.black, 80) : color.new(color.gray,  80)
txtMuted = isDark ? color.new(color.gray, 20)  : color.new(color.gray, 30)

// ======================================
// PALETTE — 5-ZONE RSI 14 (CONTRARIAN SCHEME)
// RSI ≥ OB   → dark red    (sell signal)
// 60 ≤ RSI   → light red   (near OB)
// 40 < RSI   → teal        (neutral)
// OS < RSI   → light green (near OS)
// RSI ≤ OS   → dark green  (buy signal)
// ======================================
colRSI_OB      = color.new(#C73535, 0)
colRSI_NearOB  = color.new(#E8A0A0, 0)
colRSI_Neutral = color.new(#1A5F7A, 0)
colRSI_NearOS  = color.new(#7FDD8F, 0)
colRSI_OS      = color.new(#1FA64B, 0)

colorRSI2    = color.new(#E6B800, 0)
colorBull    = color.new(#1FA64B, 0)
colorBear    = color.new(#C73535, 0)
colorNeu     = isDark ? color.new(color.gray, 40) : color.new(color.gray, 30)
colorGold    = color.new(#FFD700, 0)
colorCrimson = color.new(#DC143C, 0)

colSlow14 = color.new(#1A5F7A, 30)
colSlow2  = color.new(#E6B800, 30)

// ======================================
// DYNAMIC ZONE FUNCTIONS
// ======================================
f_zoneColor(v) => v >= obLevel ? colRSI_OB : v >= 60 ? colRSI_NearOB : v > 40 ? colRSI_Neutral : v > osLevel ? colRSI_NearOS : colRSI_OS
f_zoneState(v) => v >= obLevel ? "Overbought" : v >= 60 ? "Near OB" : v > 40 ? "Neutral" : v > osLevel ? "Near OS" : "Oversold"

colorRSI14Dynamic = f_zoneColor(rsi14)

histColor = rsi14 >= obLevel ? color.new(#C73535, 40) : rsi14 >= 60 ? color.new(#E8A0A0, 40) : rsi14 > 40 ? color.new(color.gray, 60) : rsi14 > osLevel ? color.new(#7FDD8F, 40) : color.new(#1FA64B, 40)

// ======================================
// SIGNAL LOGIC — DIAMONDS ONLY
// ======================================
bullCrossRaw = ta.crossover(rsi2,  rsi14)
bearCrossRaw = ta.crossunder(rsi2, rsi14)

rsi14OB = rsi14 >= obLevel
rsi14OS = rsi14 <= osLevel

bullDiamond = bullCrossRaw and rsi14OS
bearDiamond = bearCrossRaw and rsi14OB

var int    barsSinceSignal = na
var string lastSignalType  = "—"
var color  lastSignalCol   = color.new(color.gray, 50)

if bullDiamond
    barsSinceSignal := 0
    lastSignalType  := "◆ BULL (OS)"
    lastSignalCol   := colorGold
else if bearDiamond
    barsSinceSignal := 0
    lastSignalType  := "◆ BEAR (OB)"
    lastSignalCol   := colorCrimson
else
    barsSinceSignal := na(barsSinceSignal) ? na : barsSinceSignal + 1

// ======================================
// BACKGROUND BIAS
// ======================================
bgBiasColor = rsi14 > 50 ? color.new(#1FA64B, 95) : rsi14 < 50 ? color.new(#C73535, 95) : na
bgcolor(showBgBias ? bgBiasColor : na, title="Bias Background")

// ======================================
// ZONES
// ======================================
obLineH = hline(obLevel, "OB", color=color.new(#C73535, 60), linestyle=hline.style_dashed)
osLineH = hline(osLevel, "OS", color=color.new(#1FA64B, 60), linestyle=hline.style_dashed)
topH    = hline(100, color=color.new(color.red,   100))
botH    = hline(0,   color=color.new(color.green, 100))
hline(50, "Mid", color=showMid ? color.new(color.gray, 70) : color.new(color.gray, 100), linestyle=hline.style_dotted)

fill(topH,    obLineH, color=showZones ? color.new(#C73535, 88) : na, title="OB Zone")
fill(osLineH, botH,    color=showZones ? color.new(#1FA64B, 88) : na, title="OS Zone")

// ======================================
// HISTOGRAM — RSI 14 momentum vs 50
// ======================================
plot(showHist ? momentum : na, title="RSI 14 Momentum (vs 50)", style=plot.style_histogram, color=histColor, linewidth=4)

hline(0, color=color.new(color.gray, 80), linestyle=hline.style_solid)

// ======================================
// RSI LINES
// ======================================
plot(showRSI14 ? rsi14 : na, title="RSI 14", color=colorRSI14Dynamic, linewidth=2)
plot(showRSI2  ? rsi2  : na, title="RSI 2",  color=colorRSI2,         linewidth=1)

// ======================================
// SLOW LINES — dashed by default (line.new)
// ======================================
if barstate.isconfirmed and showSlowLines and showRSI14 and not na(slowRSI14) and not na(slowRSI14[1])
    line.new(bar_index - 1, slowRSI14[1], bar_index, slowRSI14, color=colSlow14, style=line.style_dashed, width=2)

if barstate.isconfirmed and showSlowLines and showRSI2 and not na(slowRSI2) and not na(slowRSI2[1])
    line.new(bar_index - 1, slowRSI2[1], bar_index, slowRSI2, color=colSlow2, style=line.style_dashed, width=2)

// ======================================
// SIGNALS — DIAMONDS IN OB/OS ZONES
// ======================================
plotshape(showSignals and bullDiamond ? rsi2 : na, title="Bull Cross ◆ (OS Zone)", style=shape.diamond, location=location.absolute, color=colorGold,    size=size.small)
plotshape(showSignals and bearDiamond ? rsi2 : na, title="Bear Cross ◆ (OB Zone)", style=shape.diamond, location=location.absolute, color=colorCrimson, size=size.small)

// ======================================
// ALERTS
// ======================================
alertcondition(bullDiamond,           title="Bull Cross ◆ (OS)",   message="Edo RSI Dual — Confirmed Bull Cross in OS Zone ◆")
alertcondition(bearDiamond,           title="Bear Cross ◆ (OB)",   message="Edo RSI Dual — Confirmed Bear Cross in OB Zone ◆")
alertcondition(ta.cross(momentum, 0), title="Momentum Zero Cross", message="Edo RSI Dual — RSI 14 crossed the 50 midline")

// ======================================
// DASHBOARD
// ======================================
f_stateLabel(val, ob, os) => val >= ob ? "OB" : val <= os ? "OS" : "NEU"
f_stateColorBasic(val, ob, os) => val >= ob ? colorBear : val <= os ? colorBull : colorNeu

tablePos = tablePosInput == "Top Right" ? position.top_right : tablePosInput == "Top Left" ? position.top_left : tablePosInput == "Bottom Right" ? position.bottom_right : position.bottom_left

var table dash = table.new(tablePos, 2, 8, border_width=1, border_color=color.new(color.gray, 50))

if showTable and barstate.islast

    table.cell(dash, 0, 0, "Edo RSI Dual", text_color=color.white, bgcolor=bgHeader, text_size=size.small)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "RSI 14", text_color=isDark ? color.new(#4A9FB8, 0) : color.new(#0E3A4E, 0), bgcolor=bgCell, text_size=size.small)
    table.cell(dash, 1, 1, str.tostring(rsi14, "#.##") + "  [" + f_stateLabel(rsi14, obLevel, osLevel) + "]", text_color=f_stateColorBasic(rsi14, obLevel, osLevel), bgcolor=bgCell, text_size=size.small)

    table.cell(dash, 0, 2, "RSI 2", text_color=isDark ? colorRSI2 : color.new(#8B6F00, 0), bgcolor=bgCell, text_size=size.small)
    table.cell(dash, 1, 2, str.tostring(rsi2, "#.##") + "  [" + f_stateLabel(rsi2, 90, 10) + "]", text_color=f_stateColorBasic(rsi2, 90, 10), bgcolor=bgCell, text_size=size.small)

    table.cell(dash, 0, 3, "Momentum", text_color=txtMuted, bgcolor=bgCell, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(momentum, "+#.##;-#.##"), text_color=momentum > 0 ? colorBull : momentum < 0 ? colorBear : colorNeu, bgcolor=bgCell, text_size=size.small)

    table.cell(dash, 0, 4, "State", text_color=txtMuted, bgcolor=bgCell, text_size=size.small)
    table.cell(dash, 1, 4, f_zoneState(rsi14), text_color=f_zoneColor(rsi14), bgcolor=bgCell, text_size=size.small)

    table.cell(dash, 0, 5, "Signal", text_color=txtMuted, bgcolor=bgCell, text_size=size.small)
    table.cell(dash, 1, 5, lastSignalType, text_color=lastSignalCol, bgcolor=bgCell, text_size=size.small)

    table.cell(dash, 0, 6, "Signal Age", text_color=txtMuted, bgcolor=bgCell, text_size=size.small)
    table.cell(dash, 1, 6, na(barsSinceSignal) ? "—" : str.tostring(barsSinceSignal) + " bars ago", text_color=na(barsSinceSignal) ? colorNeu : barsSinceSignal <= 3 ? colorBull : colorNeu, bgcolor=bgCell, text_size=size.small)

    table.cell(dash, 0, 7, "◆ Cross in OB/OS Zone", text_color=color.new(color.gray, 40), bgcolor=bgFooter, text_size=size.tiny)
    table.merge_cells(dash, 0, 7, 1, 7)
````
