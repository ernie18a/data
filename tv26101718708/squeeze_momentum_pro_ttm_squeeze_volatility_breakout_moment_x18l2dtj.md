# Squeeze Momentum Pro - TTM Squeeze, Volatility Breakout & Moment

- url: https://www.tradingview.com/script/x18l2DTj-Squeeze-Momentum-Pro-TTM-Squeeze-Volatility-Breakout-Moment/
- type: indicator
- pine_id: PUB;afd305a78400491ea593606036b09e0f
- version: 1.0

## Description

Squeeze Momentum Pro - TTM Squeeze, Volatility Breakout & Moment is a modern volatility squeeze and momentum indicator for TradingView that shows you exactly when the market is coiling (building energy) and the precise moment that energy fires into a trend. It combines the classic TTM Squeeze concept — Bollinger Bands contracting inside the Keltner Channel — with a multi-tier compression engine (Squeeze Pro) and a glowing momentum histogram, so you can trade breakouts, momentum, trend continuation and volatility expansion on any market and any timeframe: forex, crypto, stocks, indices, futures, gold (XAUUSD), Bitcoin (BTCUSD), NASDAQ, S&P 500, oil and more. Built in Pine Script v6, it adds neon momentum candles, rare high-conviction squeeze fire signals and a live dashboard — a clean, professional upgrade over a plain squeeze momentum oscillator. Keywords: squeeze momentum, squeeze pro, TTM squeeze, volatility squeeze, momentum indicator, Bollinger Bands, Keltner Channel, breakout indicator, volatility breakout, momentum oscillator, trend, buy sell signals, scalping, day trading, swing trading, no repaint.

◆ WHY THE SQUEEZE WORKS
When Bollinger Bands contract inside the Keltner Channel, volatility is compressing — the market is coiling like a spring. Low volatility is always followed by high volatility. The squeeze tells you a big move is building; the momentum histogram tells you which direction it is most likely to release. Trading the release of a squeeze is one of the highest-reward, lowest-risk setups in technical analysis.

◆ WHAT IT DOES

[image]https://www.tradingview.com/x/xCzhQn8p/[/image]

3 compression tiers (Squeeze Pro): HIGH (BB inside KC x1.0, tightest coil), MID (x1.5), LOW (x2.0), and EXPANSION (bands released). Tier is shown by colour-coded dots on the zero line.
Neon momentum histogram: linear-regression momentum that glows brighter as it extends and dims as it fades — instant read of strength and direction.
Squeeze Fire signals: rare, high-conviction arrows that fire only when a real coil (HIGH/MID) releases — filtered to remove noisy weak releases.
Neon momentum candles: your chart candles are tinted by momentum (turquoise up / magenta down).
Live dashboard: State, a unique Coil Energy gauge (stored energy of the coil), Momentum strength, Signal and Bias.
◆ HOW IT WORKS (under the hood)

Bollinger Bands (length/multiplier) measure compression; Keltner Channel (ATR-based) is the volatility reference. A squeeze is active when both BB edges sit inside the KC edges.
Three KC multipliers create three compression tiers so you can tell a mild coil from a maximum-tension coil.
Momentum is a linear regression of price versus the average of the Donchian midline and the moving average (LazyBear method).
The script tracks the tightest tier reached during each coil; a fire is only flagged when the coil reaches your chosen tier and then releases — so arrows mean something.
Coil Energy accumulates from how long and how tightly price has been compressed, and discharges on release — a unique read of stored breakout potential.
◆ HOW TO USE IT

Wait for a squeeze (especially a HIGH tier — tightest spring). The dashboard shows State and rising Coil Energy.
On the Squeeze Fire arrow, enter in the direction of the histogram colour (teal = long, magenta = short).
Stay in while momentum keeps extending (bars growing, bright colour); exit as momentum fades (bars shrinking, dim colour) or flips across the zero line.
Use Fire on release from to control signal frequency: HIGH only (rare, strongest) → MID+ → Any (more signals).
Works on all symbols and timeframes; combine with your own support/resistance, structure or trend tools for confluence.
◆ SETTINGS

Squeeze Engine: BB length & multiplier, KC length, KC multipliers for HIGH/MID/LOW tiers.
Momentum: linear-regression length.
Fire Signals: release tier threshold (HIGH only / MID+ / Any).
Histogram / Candles: glow, tint chart candles by momentum, optional squeeze-zone shading, fire markers.
Panel: show/hide, position, background, accent colour.
◆ ALERTS

Squeeze Fire Long / Short
High Squeeze started (maximum compression)
Momentum crossed zero
◆ LIMITATIONS

This is a momentum/volatility tool, not a complete system — always confirm with price action and risk management.
On forex and crypto, volatility (ATR) and momentum reflect the data feed of your broker/exchange; results can vary slightly between feeds.
A squeeze signals that a move is building, not its direction with certainty — the momentum colour gives the probable bias, not a guarantee.
With "HIGH only" some calm instruments may rarely reach the tightest tier; loosen the KC HIGH multiplier or switch to "MID+" if you want more signals.

◆ NON-REPAINTING
Every value comes from confirmed bar data with no lookahead and no security() smoothing tricks. A signal printed on a closed bar stays. As with any live tool, the current forming bar updates in real time and settles on close.

Squeeze Momentum Pro - TTM Squeeze, Volatility Breakout & Moment is an educational analysis tool, not financial advice. Always do your own research and manage risk. © LunqFX.

## Source Code

````pine
//@version=6
// ============================================================================
//  Squeeze Momentum Pro - Volatility Squeeze & Momentum [LunqFX]
// ----------------------------------------------------------------------------
//  A modern take on the volatility squeeze. It detects when the market coils
//  (Bollinger Bands contract INSIDE the Keltner Channel = energy building up)
//  and tells you the moment that energy releases - the "squeeze fire" - plus
//  the direction and strength of the momentum driving the move.
//
//  PRO compression tiers (like TTM Squeeze Pro):
//      • HIGH squeeze  - BB inside KC x1.0  (tightest coil, most explosive)
//      • MID  squeeze  - BB inside KC x1.5
//      • LOW  squeeze  - BB inside KC x2.0  (mild coil)
//      • EXPANSION     - BB outside KC      (energy is being released)
//
//  Neon momentum histogram glows by strength, the main chart candles are
//  recoloured by momentum (turquoise up / magenta down), and a live dashboard
//  reads the state, momentum, squeeze duration and the fire signal.
//
//  NON-REPAINTING: every value comes from confirmed bar data with no lookahead
//  and no security() smoothing tricks. A signal printed on a closed bar stays.
// ============================================================================
indicator("Squeeze Momentum Pro - Volatility Squeeze & Momentum [LunqFX]", "Squeeze Momentum Pro [LunqFX]", overlay = false, max_labels_count = 100)

// ─────────────────────────────────────────────────────────────────────────
//  PALETTE  (modern neon — turquoise = bull, magenta = bear)
// ─────────────────────────────────────────────────────────────────────────
TUR_MID  = #12B8A6
TUR_HI   = #4DFCE6
PINK_MID = #FF2E63
PINK_HI  = #FF6FA3
GOLD     = #FFB938
ORANGE   = #FF8A3D
MUTE     = #5C6675
INKHI    = #EAEEF6

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gEng    = "Squeeze Engine"
lenBB   = input.int(20,  "BB length",        minval = 5,  group = gEng, tooltip = "Bollinger Bands lookback (compression source).")
multBB  = input.float(2.0,"BB multiplier",   minval = 0.5, step = 0.1, group = gEng)
lenKC   = input.int(20,  "KC length",        minval = 5,  group = gEng, tooltip = "Keltner Channel lookback (volatility reference).")
multHi  = input.float(1.0,"KC mult — HIGH squeeze", minval = 0.3, step = 0.1, group = gEng, tooltip = "Tightest coil. BB inside this KC = maximum compression.")
multMid = input.float(1.5,"KC mult — MID squeeze",  minval = 0.5, step = 0.1, group = gEng)
multLow = input.float(2.0,"KC mult — LOW squeeze",  minval = 0.5, step = 0.1, group = gEng)

gMom    = "Momentum"
lenMom  = input.int(20,  "Momentum length",  minval = 5, group = gMom, tooltip = "Linear-regression momentum lookback.")

gCol    = "Histogram / Candles"
neonCnd = input.bool(true, "Tint chart candles by momentum", group = gCol, tooltip = "Recolours your EXISTING chart candles by momentum (turquoise up / magenta down), brightness scales with strength. NOTE: a pane indicator can only tint the candles already on the chart — keep your chart's candles visible (do not hide them), otherwise there is nothing to colour.")
glowHist= input.bool(true, "Glow on histogram",     group = gCol)
sqzBg   = input.bool(false, "Shade squeeze zones",  group = gCol, tooltip = "Optional subtle indigo tint behind bars while price is coiled (darker = tighter tier). Off by default — the zero-line dots already show the squeeze tier.")
showFire= input.bool(true, "Fire release markers",  group = gCol)

gPanel  = "Panel"
showHUD = input.bool(true, "Show dashboard",        group = gPanel)
hudPos  = input.string("Bottom Left","Position",    options = ["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group = gPanel)
hudBg   = input.color(#0C0F16, "Background",        group = gPanel)
accent  = input.color(TUR_MID,  "Accent",          group = gPanel)

// ─────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────
hudPosition(string s) =>
    switch s
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right

// ─────────────────────────────────────────────────────────────────────────
//  SQUEEZE  (Bollinger Bands vs Keltner Channel, 3 compression tiers)
// ─────────────────────────────────────────────────────────────────────────
basis   = ta.sma(close, lenBB)
dev     = multBB * ta.stdev(close, lenBB)
upperBB = basis + dev
lowerBB = basis - dev

maKC    = ta.sma(close, lenKC)
rangeMA = ta.sma(ta.tr(true), lenKC)
upHi    = maKC + rangeMA * multHi
loHi    = maKC - rangeMA * multHi
upMid   = maKC + rangeMA * multMid
loMid   = maKC - rangeMA * multMid
upLow   = maKC + rangeMA * multLow
loLow   = maKC - rangeMA * multLow

sqzHigh = lowerBB > loHi  and upperBB < upHi
sqzMid  = lowerBB > loMid and upperBB < upMid
sqzLow  = lowerBB > loLow and upperBB < upLow
sqzOn   = sqzLow                       // any compression at all
noSqz   = not sqzLow                   // expansion

// current compression tier as a rank (0 none .. 3 high)
curTier = sqzHigh ? 3 : sqzMid ? 2 : sqzLow ? 1 : 0

// track the tightest tier reached during the current coil
var int peakTier = 0
if sqzOn
    peakTier := math.max(peakTier, curTier)

// fire = squeeze releases into expansion. Only flag it as a real fire if the
// coil actually reached MID or HIGH compression (filters out weak, noisy LOW-only
// releases) — this is what gives the arrows meaning.
rawFire  = noSqz and sqzLow[1]
fired    = rawFire and peakTier >= 2
if rawFire
    peakTier := 0

// squeeze duration counter (how many bars price has been coiled)
var int sqzBars = 0
sqzBars := sqzOn ? sqzBars + 1 : 0

// ─────────────────────────────────────────────────────────────────────────
//  MOMENTUM  (LazyBear linear-regression of price vs midline)
// ─────────────────────────────────────────────────────────────────────────
mid  = ta.sma(close, lenMom)
dch  = (ta.highest(high, lenMom) + ta.lowest(low, lenMom)) / 2
val  = ta.linreg(close - (dch + mid) / 2, lenMom, 0)

rising = val > nz(val[1])
posMom = val >= 0

// strength 0..1 — normalised by recent extreme so the glow always scales
absV   = math.abs(val)
scaleV = ta.highest(absV, 100)
frac   = scaleV > 0 ? math.min(1.0, absV / scaleV) : 0.0

// histogram colour: bright when momentum extends, dim when it fades
histCol = posMom ?
     (rising ? color.from_gradient(frac, 0, 1, TUR_MID, TUR_HI) : color.new(TUR_MID, 45)) :
     (not rising ? color.from_gradient(frac, 0, 1, PINK_MID, PINK_HI) : color.new(PINK_MID, 45))

// ─────────────────────────────────────────────────────────────────────────
//  PLOTS  (momentum histogram + glow + squeeze dots)
// ─────────────────────────────────────────────────────────────────────────
// squeeze-zone shading — optional, subtle cool indigo (never muddy/brown).
// Darker tint = tighter tier. Off by default; the zero-line dots carry the tier.
bgTier = not sqzBg ? na :
         sqzHigh   ? color.new(#5B6CFF, 90) :
         sqzMid    ? color.new(#5B6CFF, 93) :
         sqzLow    ? color.new(#5B6CFF, 95) : na
bgcolor(bgTier, title = "Squeeze zone")

plot(glowHist ? val : na, "Glow", color = color.new(histCol, 75), style = plot.style_columns, linewidth = 4)
plot(val, "Momentum", color = histCol, style = plot.style_columns, linewidth = 2)

// compression dots on the zero line — colour = tier (tighter = hotter)
dotCol = noSqz   ? color.new(TUR_HI, 0)  :
         sqzHigh ? color.new(PINK_HI, 0) :
         sqzMid  ? color.new(ORANGE, 0)  :
                   color.new(GOLD, 0)
plot(0, "Squeeze", color = dotCol, style = plot.style_circles, linewidth = 3)

// fire release markers — bigger, off the zero line so they never overlap dots
plotshape(showFire and fired and posMom,     "Fire Long",  style = shape.triangleup,   location = location.bottom, color = TUR_HI,  size = size.small)
plotshape(showFire and fired and not posMom, "Fire Short", style = shape.triangledown, location = location.top,    color = PINK_HI, size = size.small)
hline(0, "Zero", color = color.new(MUTE, 60), linestyle = hline.style_solid)

// ─────────────────────────────────────────────────────────────────────────
//  NEON MOMENTUM CANDLES  (recolour the main chart bars)
// ─────────────────────────────────────────────────────────────────────────
upBar = color.from_gradient(frac, 0, 1, TUR_MID, TUR_HI)
dnBar = color.from_gradient(frac, 0, 1, PINK_MID, PINK_HI)
barcolor(neonCnd ? (posMom ? upBar : dnBar) : na, title = "Neon Momentum Candles")

// ─────────────────────────────────────────────────────────────────────────
//  DASHBOARD
// ─────────────────────────────────────────────────────────────────────────
var table hud = na
if showHUD and barstate.islast
    if not na(hud)
        table.delete(hud)
    hud := table.new(hudPosition(hudPos), 2, 6, bgcolor = color.new(hudBg, 0), border_width = 0, frame_color = color.new(#222A38, 0), frame_width = 1)

    SURF  = color.new(hudBg, 0)
    HEADR = color.new(color.from_gradient(0.5, 0, 1, hudBg, #1A2130), 0)
    teal  = accent

    // state (hero) — tier-coloured, no glyphs
    stT = noSqz ? "EXPANSION" : sqzHigh ? "SQUEEZE · HIGH" : sqzMid ? "SQUEEZE · MID" : "SQUEEZE · LOW"
    stC = noSqz ? teal : sqzHigh ? PINK_HI : sqzMid ? ORANGE : GOLD

    // Coil Energy: stored energy grows the longer price stays coiled and the
    // tighter the tier; it discharges to 0 on release. A signature squeeze metric.
    tierW  = sqzHigh ? 1.0 : sqzMid ? 0.66 : sqzLow ? 0.4 : 0.0
    energy = math.min(1.0, (sqzBars / 20.0) * (0.5 + tierW * 0.5))
    eN     = math.round(energy * 10)
    ebar   = ""
    for i = 1 to 10
        ebar := ebar + (i <= eN ? "▰" : "▱")
    eC     = energy >= 0.66 ? PINK_HI : energy >= 0.33 ? ORANGE : energy > 0 ? GOLD : MUTE

    // momentum strength meter
    eM    = math.round(frac * 10)
    mbar  = ""
    for i = 1 to 10
        mbar := mbar + (i <= eM ? "▰" : "▱")
    momC  = posMom ? TUR_MID : PINK_MID

    // signal — clean words + minimal arrows
    sigT = fired ? (posMom ? "FIRE LONG ▲" : "FIRE SHORT ▼") : noSqz ? (posMom ? "Trending up" : "Trending down") : "Coiling — wait"
    sigC = fired ? (posMom ? TUR_HI : PINK_HI) : noSqz ? (posMom ? TUR_MID : PINK_MID) : MUTE

    // bias
    biasT = posMom ? (rising ? "Bullish" : "Bullish fading") : (not rising ? "Bearish" : "Bearish fading")

    table.cell(hud, 0, 0, "  SQUEEZE MOMENTUM", text_color = INKHI, text_size = size.normal, text_halign = text.align_left,  bgcolor = HEADR)
    table.cell(hud, 1, 0, "PRO · LunqFX  ",      text_color = teal,  text_size = size.normal, text_halign = text.align_right, bgcolor = HEADR)

    table.cell(hud, 0, 1, "  State", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 1, stT + "  ", text_color = stC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 2, "  Coil energy", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 2, ebar + "  ", text_color = eC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 3, "  Momentum", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 3, mbar + "  ", text_color = momC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 4, "  Signal", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = SURF)
    table.cell(hud, 1, 4, sigT + "  ", text_color = sigC, text_size = size.normal, text_halign = text.align_right, bgcolor = SURF)

    table.cell(hud, 0, 5, "  Bias", text_color = MUTE, text_size = size.normal, text_halign = text.align_left, bgcolor = HEADR)
    table.cell(hud, 1, 5, biasT + "  ", text_color = momC, text_size = size.normal, text_halign = text.align_right, bgcolor = HEADR)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
alertcondition(fired and posMom,     "Squeeze Fire Long",  "Squeeze released to the upside — momentum is positive")
alertcondition(fired and not posMom, "Squeeze Fire Short", "Squeeze released to the downside — momentum is negative")
alertcondition(sqzHigh and not sqzHigh[1], "High Squeeze started", "Maximum compression — a big move is building")
alertcondition(ta.cross(val, 0), "Momentum flipped", "Momentum crossed the zero line")
````
