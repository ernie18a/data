# Entropic Liquidity Manifold [JOAT]

- url: https://www.tradingview.com/script/hS6j7P50-Entropic-Liquidity-Manifold-JOAT/
- type: indicator
- pine_id: PUB;d57bd712b8504522a6d6c86cac7b78d8
- version: 1.0

## Description

[b]Entropic Liquidity Manifold [JOAT][/b]

[b]Introduction[/b]

Entropic Liquidity Manifold builds an adaptive POC-style liquidity mean using volume density, auction entropy, displacement, and release scoring.

This open-source indicator is designed as a context tool, not a standalone trading system. It focuses on explaining the current market state with restrained visuals and confirmed-bar logic where signals are used.

[image]https://www.tradingview.com/x/EKvDDxQG/[/image]

[b]Core Concepts[/b]

[b]1. Adaptive Manifold[/b]

The equilibrium updates faster when density and entropy rise.

[b]2. Volume Density[/b]

Volume divided by bar range estimates participation concentration.

[b]3. Auction Entropy[/b]

Close location identifies whether the auction is balanced or directional.

[b]4. Absorption vs Release[/b]

High density with balance supports absorption, while displacement with direction supports release.

[pine]
manifold := manifold + adaptiveAlpha * (hlc3 - manifold)
[/pine]

[b]Features[/b]

[list]
[*]Adaptive liquidity mean
[*]Upper and lower shelves
[*]Entropy trace
[*]Absorption node markers
[*]L+ and L- release labels
[/list]

[b]Input Parameters[/b]

[list]
[*]Density and entropy memory
[*]Release and absorption gates
[*]Cooldown
[*]Manifold, candle, and HUD toggles
[*]HUD position selector
[/list]


[b]How to Use This Script[/b]

Use the manifold as an adaptive auction reference. Absorption nodes mark balance; L+ and L- mark confirmed directional release.

[b]Limitations[/b]

[list]
[*]The script uses historical OHLCV data and cannot know future prices.
[*]Signals and states can be late during fast reversals because confirmed-bar logic is used to reduce repainting.
[*]Model outputs should be interpreted with market context, risk controls, and independent analysis.
[*]No visual state should be treated as a certain trade outcome.
[/list]

[b]Originality Statement[/b]

ELM is original in combining adaptive equilibrium, density, entropy, displacement, and release scoring.

[b]Disclaimer[/b]

This indicator is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. All calculations are derived from historical market data and may produce inaccurate readings in some market conditions. No indicator can predict future market behavior. Use proper risk management and independent judgment.

-Made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Entropic Liquidity Manifold [JOAT]", shorttitle="ELM [JOAT]", overlay=true, max_bars_back=900, max_lines_count=120, max_labels_count=80)

// Entropic Liquidity Manifold [JOAT]
// Adaptive equilibrium is updated faster when volume concentration rises, producing a dynamic POC-style manifold.
// Entropy, density, and auction displacement separate absorption from true liquidity release.

string gModel = "Liquidity Model"
string gSignal = "Signal Gates"
string gVisual = "Visual System"
int memoryLen = input.int(80, "Density memory", minval=20, maxval=260, group=gModel)
int entropyLen = input.int(34, "Entropy memory", minval=10, maxval=120, group=gModel)
float releaseGate = input.float(68.0, "Release gate", minval=45, maxval=90, step=1, group=gSignal)
float absorbGate = input.float(62.0, "Absorption gate", minval=45, maxval=90, step=1, group=gSignal)
int cooldown = input.int(12, "Signal cooldown", minval=1, maxval=100, group=gSignal)
bool showManifold = input.bool(true, "Show liquidity manifold", group=gVisual)
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

float atr = ta.atr(14)
float barRange = math.max(high - low, syminfo.mintick)
float closeLocation = ((close - low) - (high - close)) / barRange
float dollarDensity = nz(volume, 0) / math.max(barRange, syminfo.mintick)
float densityZ = zscore(dollarDensity, memoryLen)
float volZ = zscore(nz(volume, 0), memoryLen)
float entropyRaw = 1.0 - math.abs(closeLocation)
float entropy = clamp(ta.ema(entropyRaw, entropyLen), 0, 1)
float directedAuction = ta.ema(closeLocation * nz(volume, 0), 8) / math.max(ta.ema(nz(volume, 0), 8), 1)
float participation = clamp(densityZ * 14 + volZ * 8 + 50, 0, 100)

var float manifold = na
float adaptAlpha = clamp(0.035 + math.max(densityZ, 0) * 0.018 + entropy * 0.030, 0.025, 0.22)
manifold := na(manifold) ? hlc3 : manifold + adaptAlpha * (hlc3 - manifold)

float displacement = safeDiv(close - manifold, math.max(atr, syminfo.mintick))
float densityWidth = atr * (0.65 + clamp(participation / 100, 0, 1.5) * 0.65 + entropy * 0.30)
float upperShelf = manifold + densityWidth
float lowerShelf = manifold - densityWidth
float entropyTrace = manifold + (entropy - 0.5) * atr * 0.9
float auctionPressure = clamp(50 + directedAuction * 42 + displacement * 8 + densityZ * 6, 0, 100)
float absorptionScore = clamp(entropy * 45 + participation * 0.35 - math.abs(displacement) * 9 + (barRange < ta.sma(barRange, memoryLen) ? 12 : 0), 0, 100)
float releaseScore = clamp((1 - entropy) * 35 + participation * 0.30 + math.abs(displacement) * 18 + math.abs(directedAuction) * 25, 0, 100)

int regime = auctionPressure > 58 and close > manifold ? 1 : auctionPressure < 42 and close < manifold ? -1 : 0
color theme = regime == 1 ? C_BULL : regime == -1 ? C_BEAR : absorptionScore >= absorbGate ? C_GOLD : C_BLUE
bool absorption = barstate.isconfirmed and absorptionScore >= absorbGate and math.abs(displacement) < 0.85 and participation > 54
bool upsideRelease = barstate.isconfirmed and releaseScore >= releaseGate and close > upperShelf and directedAuction > 0
bool downsideRelease = barstate.isconfirmed and releaseScore >= releaseGate and close < lowerShelf and directedAuction < 0

var int lastSignal = na
bool cooled = na(lastSignal) or bar_index - lastSignal >= cooldown
bool absorbEvent = cooled and absorption and not absorption[1]
bool upEvent = cooled and upsideRelease and not upsideRelease[1]
bool downEvent = cooled and downsideRelease and not downsideRelease[1]
if absorbEvent or upEvent or downEvent
    lastSignal := bar_index

pMid = plot(showManifold ? manifold : na, "ELM adaptive liquidity mean", color=color.new(theme, 5), linewidth=2)
pUp = plot(showManifold ? upperShelf : na, "ELM upper liquidity shelf", color=color.new(theme, 70))
pDn = plot(showManifold ? lowerShelf : na, "ELM lower liquidity shelf", color=color.new(theme, 70))
plot(showManifold ? entropyTrace : na, "ELM entropy trace", color=color.new(C_GOLD, 30), linewidth=2)
fill(pUp, pDn, color=color.new(theme, 92), title="ELM liquidity manifold")
plotshape(upEvent, "ELM upside release", shape.labelup, location.belowbar, color=color.new(C_BULL, 0), text="L+", textcolor=C_BG, size=size.tiny)
plotshape(downEvent, "ELM downside release", shape.labeldown, location.abovebar, color=color.new(C_BEAR, 0), text="L-", textcolor=C_TEXT, size=size.tiny)
plotshape(absorbEvent, "ELM absorption node", shape.circle, location.belowbar, color=color.new(C_GOLD, 0), size=size.tiny)
barcolor(paintBars ? upEvent ? C_BULL : downEvent ? C_BEAR : absorption ? color.new(C_GOLD, 68) : regime == 1 ? color.new(C_BULL, 78) : regime == -1 ? color.new(C_BEAR, 78) : na : na)

var table hud = na
if showDashboard and barstate.islast
    if na(hud)
        hud := table.new(hudPos, 2, 7, bgcolor=color.new(C_BG, 8), border_color=color.new(C_TEXT, 82), border_width=1, frame_color=color.new(theme, 65), frame_width=1)
    table.cell(hud, 0, 0, "ENTROPY", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 1, 0, "ELM", text_color=C_TEXT, bgcolor=color.new(theme, 68), text_size=size.small)
    table.cell(hud, 0, 1, "State", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 1, upsideRelease ? "Release Up" : downsideRelease ? "Release Down" : absorption ? "Absorb" : "Balance", text_color=theme, text_size=size.small)
    table.cell(hud, 0, 2, "Auction", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 2, str.tostring(auctionPressure, "#.0"), text_color=auctionPressure >= 55 ? C_BULL : auctionPressure <= 45 ? C_BEAR : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 3, "Density", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 3, str.tostring(participation, "#.0"), text_color=participation >= 65 ? C_GOLD : C_BLUE, text_size=size.small)
    table.cell(hud, 0, 4, "Entropy", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 4, str.tostring(entropy * 100, "#.0"), text_color=entropy >= 0.62 ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 5, "Absorb", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 5, str.tostring(absorptionScore, "#.0"), text_color=absorptionScore >= absorbGate ? C_GOLD : C_MUTED, text_size=size.small)
    table.cell(hud, 0, 6, "Release", text_color=color.new(C_TEXT, 22), text_size=size.small)
    table.cell(hud, 1, 6, str.tostring(releaseScore, "#.0"), text_color=releaseScore >= releaseGate ? theme : C_MUTED, text_size=size.small)

alertcondition(upEvent, "ELM Upside Release [JOAT]", "Entropic Liquidity Manifold upside release")
alertcondition(downEvent, "ELM Downside Release [JOAT]", "Entropic Liquidity Manifold downside release")
alertcondition(absorbEvent, "ELM Absorption [JOAT]", "Entropic Liquidity Manifold absorption node")
````
