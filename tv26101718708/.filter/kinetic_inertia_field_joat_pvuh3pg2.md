# Kinetic Inertia Field [JOAT]

- url: https://www.tradingview.com/script/pvuh3pg2-Kinetic-Inertia-Field-JOAT/
- type: indicator
- pine_id: PUB;59b28afd125a4286b1718e3fe0087820
- version: 1.0

## Description

[b]Kinetic Inertia Field [JOAT][/b]

[b]Introduction[/b]

Kinetic Inertia Field models price like a noisy particle using velocity, acceleration, jerk, kinetic energy, potential displacement, and equilibrium deviation.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/8Nn2bBtI/[/image]

[b]Core Concepts[/b]

[b]1. Velocity and Acceleration[/b]

Log returns are normalized by volatility to create velocity, then differentiated into acceleration and jerk.

[b]2. Kinetic Energy[/b]

Inverse volatility acts as a mass proxy and squared velocity creates energy context.

[b]3. Equilibrium Displacement[/b]

A regression/VWAP blend creates a fair path and ATR-normalized displacement.

[b]4. Inertia Field[/b]

Energy, acceleration, and displacement combine into inertial up, inertial down, or elastic state.

[pine]
kineticEnergy = 0.5 * mass * velocity * velocity
[/pine]

[b]Features[/b]

[list]
[*]Velocity, acceleration, and jerk model
[*]Kinetic and potential energy scoring
[*]Regression/VWAP equilibrium
[*]Energy rails and impulse trace
[*]K+ and K- labels plus snapback markers
[/list]

[b]Input Parameters[/b]

[list]
[*]Velocity smoothing
[*]Volatility memory
[*]Equilibrium horizon
[*]Energy and inertia gates
[*]Cooldown and display toggles
[/list]


[b]How to Use This Script[/b]

Use K+ and K- as confirmed high-energy state changes. Gold markers show elastic snapback conditions.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

KIF is original in applying kinetic energy, potential displacement, and inertia scoring to price-state analysis.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Kinetic Inertia Field [JOAT]", shorttitle="KIF [JOAT]", overlay=true, max_bars_back=800, max_lines_count=120, max_labels_count=80)

// Kinetic Inertia Field [JOAT]
// Price is modeled like a noisy particle: velocity, acceleration, jerk, kinetic energy, and equilibrium displacement.
// The indicator stays visually quiet: a dynamic equilibrium line, energy rails, candle state, and sparse impulse events.

string gModel = "Kinetic Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int velLen = input.int(8, "Velocity smoothing", minval=2, maxval=50, group=gModel)
int volLen = input.int(40, "Volatility memory", minval=15, maxval=200, group=gModel)
int eqLen = input.int(89, "Equilibrium horizon", minval=30, maxval=260, group=gModel)
float energyGate = input.float(62.0, "Energy gate", minval=35, maxval=90, step=1, group=gSignal)
float inertiaGate = input.float(58.0, "Inertia gate", minval=35, maxval=90, step=1, group=gSignal)
int cooldown = input.int(12, "Signal cooldown", minval=1, maxval=100, group=gSignal)
bool showRails = input.bool(true, "Show kinetic rails", group=gVisual)
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

zscore(float src, int len) =>
    float basis = ta.sma(src, len)
    float dev = ta.stdev(src, len)
    dev == 0.0 ? 0.0 : (src - basis) / dev

fmt(float x) =>
    str.tostring(x, "#.0")

float logRet = math.log(close / close[1])
float vol = ta.stdev(logRet, volLen)
float atr = ta.atr(14)
int accelLen = math.max(2, int(velLen / 2))
float velocityRaw = safeDiv(logRet, math.max(vol, 0.000001))
float velocity = ta.ema(velocityRaw, velLen)
float acceleration = ta.ema(velocity - velocity[1], accelLen)
float jerk = ta.ema(acceleration - acceleration[1], 3)
float mass = safeDiv(1.0, math.max(vol * math.sqrt(252), 0.000001))
float kineticEnergy = 0.5 * mass * velocity * velocity
float energyNorm = clamp(zscore(kineticEnergy, volLen) * 14 + 50, 0, 100)

float regEq = ta.linreg(close, eqLen, 0)
float vwapEq = ta.vwap(hlc3)
float equilibrium = ta.ema(regEq * 0.62 + vwapEq * 0.38, 5)
float displacement = safeDiv(close - equilibrium, math.max(atr, syminfo.mintick))
float potentialEnergy = displacement * displacement * 0.5
float potentialNorm = clamp(zscore(potentialEnergy, volLen) * 12 + 50, 0, 100)
float inertiaScore = clamp(50 + velocity * 12 + acceleration * 22 + jerk * 16 + math.sign(displacement) * math.min(math.abs(displacement) * 7, 18), 0, 100)
float fieldScore = clamp(energyNorm * 0.35 + inertiaScore * 0.40 + potentialNorm * 0.25, 0, 100)

int regime = inertiaScore > inertiaGate and velocity > 0 and acceleration > 0 ? 1 : inertiaScore < 100 - inertiaGate and velocity < 0 and acceleration < 0 ? -1 : 0
float railWidth = atr * (0.75 + clamp(energyNorm / 100, 0, 1.25) * 0.75 + math.min(math.abs(displacement), 2.5) * 0.18)
float upperRail = equilibrium + railWidth
float lowerRail = equilibrium - railWidth
float impulseTrace = equilibrium + clamp(velocity + acceleration, -3.0, 3.0) * atr * 0.18
color theme = regime == 1 ? C_BULL : regime == -1 ? C_BEAR : energyNorm >= energyGate ? C_GOLD : C_BLUE

var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool longImpulse = barstate.isconfirmed and cooled and regime == 1 and energyNorm >= energyGate and close > upperRail[1]
bool shortImpulse = barstate.isconfirmed and cooled and regime == -1 and energyNorm >= energyGate and close < lowerRail[1]
bool meanSnapLong = barstate.isconfirmed and cooled and displacement < -1.5 and acceleration > 0 and close > lowerRail
bool meanSnapShort = barstate.isconfirmed and cooled and displacement > 1.5 and acceleration < 0 and close < upperRail
if longImpulse or shortImpulse or meanSnapLong or meanSnapShort
    lastSignal := bar_index

pEq = plot(showRails ? equilibrium : na, "KIF equilibrium", color=color.new(theme, 5), linewidth=2)
pUp = plot(showRails ? upperRail : na, "KIF upper energy rail", color=color.new(theme, 68))
pDn = plot(showRails ? lowerRail : na, "KIF lower energy rail", color=color.new(theme, 68))
plot(showRails ? impulseTrace : na, "KIF impulse trace", color=color.new(C_GOLD, 25), linewidth=2)
fill(pUp, pDn, color=color.new(theme, 92), title="KIF kinetic field")
plotshape(longImpulse, "KIF bullish inertial break", shape.labelup, location.belowbar, color=color.new(C_BULL, 0), text="K+", textcolor=C_BG, size=size.tiny)
plotshape(shortImpulse, "KIF bearish inertial break", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 0), text="K-", textcolor=C_TEXT, size=size.tiny)
plotshape(meanSnapLong, "KIF long snapback", shape.circle, location.belowbar, color=color.new(C_GOLD, 0), size=size.tiny)
plotshape(meanSnapShort, "KIF short snapback", shape.circle, location.abovebar, color=color.new(C_GOLD, 0), size=size.tiny)
barcolor(paintBars ? regime == 1 ? color.new(C_BULL, 72) : regime == -1 ? color.new(C_BEAR, 72) : energyNorm >= energyGate ? color.new(C_GOLD, 76) : na : na)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 7, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "KINETIC", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "KIF", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "Regime", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, regime == 1 ? "Inertial Up" : regime == -1 ? "Inertial Down" : "Elastic", text_color=theme, text_size=size.small)
    table.cell(hud, 0, 2, "Velocity", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, fmt(velocity * 10), text_color=velocity >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 3, "Accel", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, fmt(acceleration * 20), text_color=acceleration >= 0 ? C_BULL : C_BEAR, text_size=size.small)
    table.cell(hud, 0, 4, "Energy", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, fmt(energyNorm), text_color=energyNorm >= energyGate ? C_GOLD : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 5, "Inertia", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, fmt(inertiaScore), text_color=inertiaScore >= 55 ? C_BULL : inertiaScore <= 45 ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 6, "Field", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, fmt(fieldScore), text_color=fieldScore >= 65 ? C_BULL : fieldScore <= 40 ? C_BEAR : C_GOLD, text_size=size.small)

alertcondition(longImpulse, "KIF Bullish Inertia [JOAT]", "Kinetic Inertia Field bullish inertial break")
alertcondition(shortImpulse, "KIF Bearish Inertia [JOAT]", "Kinetic Inertia Field bearish inertial break")
alertcondition(meanSnapLong or meanSnapShort, "KIF Elastic Snapback [JOAT]", "Kinetic Inertia Field elastic snapback")
````
