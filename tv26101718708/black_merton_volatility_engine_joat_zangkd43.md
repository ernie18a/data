# Black Merton Volatility Engine [JOAT]

- url: https://www.tradingview.com/script/zaNGKD43-Black-Merton-Volatility-Engine-JOAT/
- type: indicator
- pine_id: PUB;fab235622d284034839291b58296c30a
- version: 1.0

## Description

[b]Black Merton Volatility Engine [JOAT][/b]

[b]Introduction[/b]

Black Merton Volatility Engine blends multiple realized-volatility estimators with expected-move rails, cone rank, jump pressure, and tail-state classification.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/QfBkQu8g/[/image]

[b]Core Concepts[/b]

[b]1. Composite Realized Volatility[/b]

Close-to-close, Parkinson, Garman-Klass, Rogers-Satchell, and Yang-Zhang-style estimates contribute to the volatility state.

[b]2. Volatility Cone[/b]

Current volatility is ranked against a historical cone to identify squeeze and shock conditions.

[b]3. Expected Move Rails[/b]

Annualized volatility is converted into a multi-day expected move around price.

[b]4. Tail and Jump Pressure[/b]

Large returns, rail breaches, and volatility divergence contribute to tail and jump states.

[pine]
expectedMove = close * realizedVol * math.sqrt(days / 252)
[/pine]

[b]Features[/b]

[list]
[*]Composite realized volatility
[*]Expected-move rails
[*]Squeeze and shock regimes
[*]Gamma pin, tail shock, clean expansion, and jump labels
[*]Movable quant HUD
[/list]

[b]Input Parameters[/b]

[list]
[*]Fast, base, and slow vol windows
[*]Vol cone window
[*]Expected move days
[*]Squeeze and shock percentiles
[*]Cooldown and display toggles
[/list]


[b]How to Use This Script[/b]

Use the rails as volatility context. Squeeze, shock, tail, and jump states describe volatility conditions, not a certain direction.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

BMV is original in blending several volatility estimators, cone ranking, jump pressure, and expected-move visualization.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Black Merton Volatility Engine [JOAT]", shorttitle="BMV [JOAT]", overlay=true, max_bars_back=1000, max_lines_count=180, max_labels_count=100)


string gModel = "Volatility Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int fastLen = input.int(10, "Fast realized vol", minval=3, maxval=60, group=gModel)
int baseLen = input.int(30, "Base realized vol", minval=10, maxval=120, group=gModel)
int slowLen = input.int(90, "Slow realized vol", minval=30, maxval=260, group=gModel)
int coneLen = input.int(180, "Vol cone window", minval=60, maxval=600, group=gModel)
float moveDays = input.float(5.0, "Expected move days", minval=1, maxval=30, step=1, group=gModel)
float squeezePct = input.float(0.25, "Cone squeeze percentile", minval=0.05, maxval=0.50, step=0.01, group=gSignal)
float shockPct = input.float(0.80, "Cone shock percentile", minval=0.50, maxval=0.98, step=0.01, group=gSignal)
int cooldown = input.int(10, "Signal cooldown", minval=1, maxval=80, group=gSignal)
bool showMoveRails = input.bool(true, "Show expected move rails", group=gVisual)
bool paintBars = input.bool(true, "Paint bars", group=gVisual)
bool showDashboard = input.bool(true, "Show quant HUD", group=gVisual)
string hudLoc = input.string("Top Right", "HUD position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group=gVisual)

color C_BULL = #00ffd5
color C_BEAR = #ff00f2
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

fmtPct(float x) =>
    str.tostring(x * 100.0, "#.##") + "%"

float logR = math.log(close / close[1])
float ccFast = ta.stdev(logR, fastLen) * math.sqrt(252)
float ccBase = ta.stdev(logR, baseLen) * math.sqrt(252)
float ccSlow = ta.stdev(logR, slowLen) * math.sqrt(252)
float parkinson = math.sqrt(ta.sma(math.pow(math.log(high / low), 2), baseLen) / (4.0 * math.log(2.0))) * math.sqrt(252)
float gkTerm = 0.5 * math.pow(math.log(high / low), 2) - (2.0 * math.log(2.0) - 1.0) * math.pow(math.log(close / open), 2)
float garmanKlass = math.sqrt(math.max(ta.sma(gkTerm, baseLen), 0)) * math.sqrt(252)
float realizedVol = ta.ema((ccBase + parkinson + garmanKlass) / 3.0, 5)
float volOfVol = ta.stdev(realizedVol, baseLen)
float volRank = safeDiv(realizedVol - ta.lowest(realizedVol, coneLen), math.max(ta.highest(realizedVol, coneLen) - ta.lowest(realizedVol, coneLen), 0.000001))
float volCarry = ccFast - ccSlow
float expectedMove = close * realizedVol * math.sqrt(moveDays / 252.0)
float upperMove = close + expectedMove
float lowerMove = close - expectedMove
float gammaProxy = safeDiv(math.abs(close - ta.ema(close, 20)), expectedMove)
float skewProxy = safeDiv((close - low) - (high - close), math.max(high - low, syminfo.mintick))

bool squeeze = volRank <= squeezePct and volCarry < 0
bool shock = volRank >= shockPct and volCarry > 0
bool expansionRaw = barstate.isconfirmed and squeeze[1] and not squeeze and ccFast > ccBase
bool compressionRaw = barstate.isconfirmed and shock[1] and not shock and ccFast < ccBase
var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool expansionEvent = cooled and expansionRaw
bool compressionEvent = cooled and compressionRaw
if expansionEvent or compressionEvent
    lastSignal := bar_index

color theme = shock ? C_BEAR : squeeze ? C_GOLD : volCarry > 0 ? C_BLUE : C_BULL
pUp = plot(showMoveRails ? upperMove : na, "BMV upper expected move", color=color.new(theme, 58))
pDn = plot(showMoveRails ? lowerMove : na, "BMV lower expected move", color=color.new(theme, 58))
plot(showMoveRails ? close : na, "BMV spot spine", color=color.new(C_TEXT, 55))
fill(pUp, pDn, color=color.new(theme, 92), title="BMV expected move field")
plotshape(expansionEvent, "BMV volatility expansion", shape.labelup, location.belowbar, color=color.new(C_BULL, 8), text="Expand", textcolor=C_BG, size=size.tiny)
plotshape(compressionEvent, "BMV volatility compression", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 8), text="Compress", textcolor=C_TEXT, size=size.tiny)
barcolor(paintBars ? shock ? color.new(C_BEAR, 62) : squeeze ? color.new(C_GOLD, 72) : volCarry > 0 ? color.new(C_BLUE, 78) : color.new(C_BULL, 82) : na)

plot(realizedVol * close, "BMV realized vol scaled", color=color.new(theme, 100), display=display.none)

alertcondition(expansionEvent, "BMV Vol Expansion [JOAT]", "Black Merton Volatility Engine expansion event")
alertcondition(compressionEvent, "BMV Vol Compression [JOAT]", "Black Merton Volatility Engine compression event")


float fastSlowRatio = safeDiv(ccFast, ccSlow)
float baseSlowRatio = safeDiv(ccBase, ccSlow)
float rsTerm = math.log(high / close) * math.log(high / open) + math.log(low / close) * math.log(low / open)
float rogersSatchell = math.sqrt(math.max(ta.sma(rsTerm, baseLen), 0)) * math.sqrt(252)
float overnight = math.log(open / close[1])
float openClose = math.log(close / open)
float yzProxy = math.sqrt(math.max(ta.variance(overnight, baseLen) + 0.34 * ta.variance(openClose, baseLen) + 0.66 * ta.sma(rsTerm, baseLen), 0)) * math.sqrt(252)
float compositeVol = ta.ema((realizedVol + rogersSatchell + yzProxy) / 3.0, 5)
float volTrend = ta.ema(realizedVol - realizedVol[5], 5)
float moveBreachUp = close > upperMove[1] ? 1.0 : 0.0
float moveBreachDn = close < lowerMove[1] ? 1.0 : 0.0
float breachRate = ta.sma(moveBreachUp + moveBreachDn, 40)
float jumpReturn = math.abs(logR) - ta.sma(math.abs(logR), baseLen)
float jumpPressure = clamp(safeDiv(jumpReturn, math.max(ta.stdev(math.abs(logR), baseLen), 0.000001)) * 18 + math.max(yzProxy - realizedVol, 0) * 160, 0, 100)
float tailPressure = clamp(volRank * 40 + math.max(fastSlowRatio - 1, 0) * 28 + breachRate * 45 + math.abs(skewProxy) * 10 + jumpPressure * 0.35, 0, 100)
float compressionQuality = clamp((1 - volRank) * 55 + math.max(1 - fastSlowRatio, 0) * 30 - breachRate * 20, 0, 100)
float expansionQuality = clamp(volRank * 42 + math.max(fastSlowRatio - 1, 0) * 32 + math.max(volTrend, 0) * 190 + math.max(compositeVol - realizedVol, 0) * 120, 0, 100)
float volGrade = clamp(compressionQuality * 0.35 + expansionQuality * 0.35 + (100 - tailPressure) * 0.30, 0, 100)
float gammaZone = clamp(100 - gammaProxy * 35, 0, 100)
float volRiskPremiumProxy = clamp((compositeVol - ccBase) * 220 + volRank * 30, -100, 100)
float outerExpectedMove = close * compositeVol * math.sqrt(moveDays / 252.0)
float outerUpperMove = close + outerExpectedMove
float outerLowerMove = close - outerExpectedMove
bool gammaPin = barstate.isconfirmed and gammaZone > 70 and squeeze
bool tailShock = barstate.isconfirmed and tailPressure > 72 and shock
bool cleanExpansion = barstate.isconfirmed and expansionQuality > 70 and not tailShock
bool jumpShock = barstate.isconfirmed and jumpPressure > 70
bool gammaPinEvent = gammaPin and not gammaPin[1]
bool tailShockEvent = tailShock and not tailShock[1]
bool cleanExpansionEvent = cleanExpansion and not cleanExpansion[1]
bool jumpShockEvent = jumpShock and not jumpShock[1]

plot(showMoveRails ? close + expectedMove * 0.50 : na, "BMV inner upper move", color=color.new(theme, 80))
plot(showMoveRails ? close - expectedMove * 0.50 : na, "BMV inner lower move", color=color.new(theme, 80))
plot(showMoveRails ? outerUpperMove : na, "BMV composite upper move", color=color.new(C_BLUE, 65))
plot(showMoveRails ? outerLowerMove : na, "BMV composite lower move", color=color.new(C_BLUE, 65))
plot(volGrade, "BMV volatility grade hidden", color=color.new(theme, 100), display=display.none)
plot(jumpPressure, "BMV jump pressure hidden", color=color.new(C_BEAR, 100), display=display.none)
plot(volRiskPremiumProxy, "BMV vol premium proxy hidden", color=color.new(C_GOLD, 100), display=display.none)
plotshape(gammaPinEvent, "BMV gamma pin", shape.labelup, location.belowbar, color=color.new(C_GOLD, 6), text="Pin", textcolor=C_BG, size=size.tiny)
plotshape(tailShockEvent, "BMV tail shock", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 6), text="Tail", textcolor=C_TEXT, size=size.tiny)
plotshape(cleanExpansionEvent, "BMV clean expansion", shape.labelup, location.belowbar, color=color.new(C_BULL, 6), text="Clean", textcolor=C_BG, size=size.tiny)
plotshape(jumpShockEvent, "BMV jump shock", shape.labeldown, location.abovebar, color=color.new(C_BLUE, 5), text="Jump", textcolor=C_TEXT, size=size.tiny)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 8, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "BLACK-MERTON", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "BMV", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "Regime", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, tailShock ? "Tail Shock" : gammaPin ? "Gamma Pin" : cleanExpansion ? "Expansion" : squeeze ? "Squeeze" : shock ? "Shock" : "Normal", text_color=tailShock or shock ? C_BEAR : gammaPin or squeeze ? C_GOLD : cleanExpansion ? C_BULL : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 2, "Real Vol", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, fmtPct(realizedVol), text_color=theme, text_size=size.small)
    table.cell(hud, 0, 3, "Composite", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, fmtPct(compositeVol), text_color=compositeVol > realizedVol ? C_BEAR : C_BULL, text_size=size.small)
    table.cell(hud, 0, 4, "Vol Rank", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(volRank * 100.0, "#.0"), text_color=volRank >= shockPct ? C_BEAR : volRank <= squeezePct ? C_GOLD : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 5, "Tail", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(tailPressure, "#.0"), text_color=tailPressure >= 70 ? C_BEAR : tailPressure <= 35 ? C_BULL : C_GOLD, text_size=size.small)
    table.cell(hud, 0, 6, "Jump", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(jumpPressure, "#.0"), text_color=jumpPressure >= 70 ? C_BEAR : jumpPressure <= 35 ? C_BULL : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 7, "Grade", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 7, str.tostring(volGrade, "#.0"), text_color=volGrade >= 65 ? C_BULL : volGrade <= 40 ? C_BEAR : C_GOLD, text_size=size.small)

alertcondition(gammaPinEvent, "BMV Gamma Pin [JOAT]", "Black Merton Volatility Engine gamma pin state")
alertcondition(tailShockEvent, "BMV Tail Shock [JOAT]", "Black Merton Volatility Engine tail shock state")
alertcondition(cleanExpansionEvent, "BMV Clean Expansion [JOAT]", "Black Merton Volatility Engine clean expansion state")
alertcondition(jumpShockEvent, "BMV Jump Shock [JOAT]", "Black Merton Volatility Engine jump shock state")
````
