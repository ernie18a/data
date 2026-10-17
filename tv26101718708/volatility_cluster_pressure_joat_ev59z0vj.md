# Volatility Cluster Pressure [JOAT]

- url: https://www.tradingview.com/script/ev59z0vJ-Volatility-Cluster-Pressure-JOAT/
- type: indicator
- pine_id: PUB;d1d2f8dea09949e285acb2d9dfb1b7bd
- version: 1.0

## Description

[b]Volatility Cluster Pressure [JOAT][/b]

[b]Introduction[/b]

Volatility Cluster Pressure tracks EWMA variance, realized volatility, vol-of-vol, jump intensity, compression, expansion, and unstable cluster states.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/VzJhGhS3/[/image]

[b]Core Concepts[/b]

[b]1. EWMA Variance[/b]

A recursive lambda model emphasizes recent returns while retaining volatility memory.

[b]2. Volatility Rank[/b]

EWMA volatility is ranked within a historical window.

[b]3. Jump Intensity[/b]

Absolute return deviations identify abnormal movement relative to recent behavior.

[b]4. Pressure Rails[/b]

Volatility and instability expand adaptive pressure rails around price.

[pine]
ewmaVar := lambda * ewmaVar + (1 - lambda) * logRet * logRet
[/pine]

[b]Features[/b]

[list]
[*]EWMA/GARCH-style variance pressure
[*]Volatility rank and vol-of-vol
[*]Jump z-score
[*]Compression, expansion, and unstable states
[*]Adaptive pressure rails and HUD
[/list]

[b]Input Parameters[/b]

[list]
[*]Cluster window and EWMA lambda
[*]Cluster pressure and compression gates
[*]Cooldown
[*]Rails, candles, and HUD toggles
[*]HUD position selector
[/list]


[b]How to Use This Script[/b]

Use VCP to understand volatility conditions before interpreting signals. Compression, expansion, and unstable states describe risk environment.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

VCP is original in combining recursive variance, vol rank, jump pressure, instability, and adaptive rails.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Volatility Cluster Pressure [JOAT]", shorttitle="VCP [JOAT]", overlay=true, max_bars_back=1000, max_lines_count=120, max_labels_count=80)

// Volatility Cluster Pressure [JOAT]
// EWMA/GARCH-style variance pressure, vol-of-vol, and jump intensity are translated into clean expected-pressure rails.
// The model highlights compression, expansion, and unstable cluster transitions without flooding the chart.

string gModel = "Volatility Cluster Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int len = input.int(80, "Cluster window", minval=30, maxval=260, group=gModel)
float lambda = input.float(0.94, "EWMA lambda", minval=0.80, maxval=0.99, step=0.01, group=gModel)
float clusterGate = input.float(68.0, "Cluster pressure gate", minval=45, maxval=90, step=1, group=gSignal)
float compressionGate = input.float(34.0, "Compression gate", minval=10, maxval=50, step=1, group=gSignal)
int cooldown = input.int(12, "Signal cooldown", minval=1, maxval=100, group=gSignal)
bool showRails = input.bool(true, "Show pressure rails", group=gVisual)
bool paintBars = input.bool(true, "Paint candles", group=gVisual)
bool showDashboard = input.bool(true, "Show quant HUD", group=gVisual)
string hudLoc = input.string("Top Right", "HUD position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)

color C_BULL = #00ffd5
color C_BEAR = #ff2af4
color C_GOLD = #ffb300
color C_BLUE = #4f7cff
color C_BG = #080a12
color C_TEXT = #ffffff
color C_MUTED = #607d8b
hudPos = hudLoc == "Top Left" ? position.top_left : hudLoc == "Bottom Right" ? position.bottom_right : hudLoc == "Bottom Left" ? position.bottom_left : position.top_right

clamp(float x, float lo, float hi) =>
    math.max(lo, math.min(hi, x))

safeDiv(float n, float d) =>
    d == 0.0 ? 0.0 : n / d

float logRet = math.log(close / close[1])
var float ewmaVar = na
ewmaVar := na(ewmaVar) ? logRet * logRet : lambda * ewmaVar + (1.0 - lambda) * logRet * logRet
float ewmaVol = math.sqrt(math.max(ewmaVar, 0)) * math.sqrt(252)
float realizedVol = ta.stdev(logRet, len) * math.sqrt(252)
float volOfVol = ta.stdev(ewmaVol, len)
float volRank = safeDiv(ewmaVol - ta.lowest(ewmaVol, len), math.max(ta.highest(ewmaVol, len) - ta.lowest(ewmaVol, len), 0.000001))
float volSlope = ta.ema(ewmaVol - ewmaVol[5], 5)
float jump = math.abs(logRet) - ta.sma(math.abs(logRet), len)
float jumpZ = safeDiv(jump, math.max(ta.stdev(math.abs(logRet), len), 0.000001))
float clusterPressure = clamp(volRank * 45 + safeDiv(ewmaVol, math.max(realizedVol, 0.000001)) * 18 + math.max(volSlope, 0) * 350 + math.max(jumpZ, 0) * 7, 0, 100)
float compressionScore = clamp((1.0 - volRank) * 55 + math.max(-volSlope, 0) * 420 - math.max(jumpZ, 0) * 10, 0, 100)
float instability = clamp(volOfVol * 260 + math.abs(jumpZ) * 12 + math.abs(ewmaVol - realizedVol) * 90, 0, 100)
float atr = ta.atr(14)
float center = ta.ema(close, 34)
float railWidth = close * ewmaVol * math.sqrt(5.0 / 252.0)
float pressureWidth = math.max(railWidth, atr * 0.60) * (0.85 + instability / 180.0)
float upperRail = center + pressureWidth
float lowerRail = center - pressureWidth
float innerUpper = center + pressureWidth * 0.50
float innerLower = center - pressureWidth * 0.50

bool compression = barstate.isconfirmed and compressionScore <= compressionGate and volRank < 0.35
bool expansion = barstate.isconfirmed and clusterPressure >= clusterGate and volSlope > 0
bool unstable = barstate.isconfirmed and instability >= 70
int regime = expansion ? 1 : unstable ? -1 : compression ? 2 : 0
color theme = regime == 1 ? C_BULL : regime == -1 ? C_BEAR : regime == 2 ? C_GOLD : C_BLUE

var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool expansionEvent = cooled and expansion and not expansion[1]
bool compressionEvent = cooled and compression and not compression[1]
bool unstableEvent = cooled and unstable and not unstable[1]
if expansionEvent or compressionEvent or unstableEvent
    lastSignal := bar_index

pUp = plot(showRails ? upperRail : na, "VCP upper cluster rail", color=color.new(theme, 68))
pDn = plot(showRails ? lowerRail : na, "VCP lower cluster rail", color=color.new(theme, 68))
pInnerUp = plot(showRails ? innerUpper : na, "VCP inner upper", color=color.new(theme, 84))
pInnerDn = plot(showRails ? innerLower : na, "VCP inner lower", color=color.new(theme, 84))
plot(showRails ? center : na, "VCP volatility center", color=color.new(theme, 8), linewidth=2)
fill(pUp, pDn, color=color.new(theme, 94), title="VCP cluster pressure field")
fill(pInnerUp, pInnerDn, color=color.new(theme, 89), title="VCP inner pressure field")
plotshape(expansionEvent, "VCP expansion", shape.labelup, location.belowbar, color=color.new(C_BULL, 0), text="V+", textcolor=C_BG, size=size.tiny)
plotshape(compressionEvent, "VCP compression", shape.circle, location.belowbar, color=color.new(C_GOLD, 0), size=size.tiny)
plotshape(unstableEvent, "VCP unstable cluster", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 0), text="V!", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? expansion ? color.new(C_BULL, 72) : unstable ? color.new(C_BEAR, 68) : compression ? color.new(C_GOLD, 76) : na : na)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 7, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "VOL CLUSTER", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "VCP", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "State", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, expansion ? "Expansion" : unstable ? "Unstable" : compression ? "Compression" : "Normal", text_color=theme, text_size=size.small)
    table.cell(hud, 0, 2, "EWMA Vol", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(ewmaVol * 100, "#.0") + "%", text_color=theme, text_size=size.small)
    table.cell(hud, 0, 3, "Vol Rank", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(volRank * 100, "#.0"), text_color=volRank >= 0.70 ? C_BEAR : volRank <= 0.30 ? C_GOLD : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 4, "Pressure", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(clusterPressure, "#.0"), text_color=clusterPressure >= clusterGate ? C_BULL : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 5, "Instability", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(instability, "#.0"), text_color=instability >= 70 ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 6, "Jump Z", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(jumpZ, "#.00"), text_color=math.abs(jumpZ) >= 2 ? C_BEAR : C_BLUE, text_size=size.small)

alertcondition(expansionEvent, "VCP Expansion [JOAT]", "Volatility Cluster Pressure expansion")
alertcondition(compressionEvent, "VCP Compression [JOAT]", "Volatility Cluster Pressure compression")
alertcondition(unstableEvent, "VCP Unstable Cluster [JOAT]", "Volatility Cluster Pressure unstable cluster")
````
