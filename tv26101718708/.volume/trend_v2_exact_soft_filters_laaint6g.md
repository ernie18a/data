# Trend V2 Exact + Soft Filters

- url: https://www.tradingview.com/script/LaAiNT6G-Trend-V2-Exact-Soft-Filters/
- type: indicator
- pine_id: PUB;3f330b9baa1645e7b3fcf0e508d83afa
- version: 1.0

## Description

**Trend V2 Exact + Soft Filters**

Trend V2 Exact + Soft Filters is a precision-based momentum and confirmation indicator designed to identify high-probability market turning points with clarity and structure. Built around a smoothed correlation trend engine, it delivers both early warnings and confirmed signals while maintaining strict control over signal quality.

At its core, the indicator plots two key lines:

* **Purple Line** – a smoothed representation of trend momentum
* **Yellow Line** – a signal line used for confirmation and timing

These lines operate within a structured zone system, allowing the script to detect when price action reaches statistically significant extremes before triggering any signals.

---

### 🔍 How It Works

The logic follows a two-stage process:

**1. Setup (Weak Signals)**
A potential trade is identified when:

* The Yellow line enters a defined extreme zone (overbought or oversold)
* The Purple line reaches a deeper threshold (“touch level”)

This creates a *“ready state”*, displayed as **Weak Buy (WB)** or **Weak Sell (WS)** signals. These are early warnings — not confirmations.

**2. Confirmation (Strong Signals)**
A trade is only confirmed when:

* The Purple line crosses the Yellow line *after* the setup is armed
* Optional filters (if enabled) agree with the direction

This produces **Strong Buy (SB)** or **Strong Sell (SS)** signals — the primary entries.

---

### ⚙️ Smart Signal Control

To improve reliability without over-filtering, the script includes optional **Soft Filters**:

* **Turn Filter** – ensures momentum is actually shifting direction
* **Volume Filter** – checks whether volume supports the move
* **Liquidity Filter** – evaluates participation using volume-based proxies

Each filter can be enabled or disabled depending on your trading style, allowing full control between responsiveness and confirmation strength.

---

🔁 Anti-Repaint & Signal Flow

The indicator uses a strict event-state system:

* Signals are only triggered once per cycle
* Buy and sell signals alternate (no stacking)
* Setups must fully complete before confirmation

This ensures clean, non-redundant signals and avoids noise in ranging conditions.

---

📊 Visual Structure

* Clear upper and lower bands highlight extreme conditions
* Strength and touch levels are plotted for transparency
* Signals are minimal, clean, and easy to read on any timeframe

---

✅ Best Use

Trend V2 is ideal for:

* Intraday and swing trading
* Identifying reversals and continuation entries
* Traders who want **early context (weak signals)** + **confirmed execution (strong signals)**

---

⚠️ Notes

This is a confirmation tool, not a standalone strategy. It performs best when combined with market structure, support/resistance, or higher timeframe bias.

---

Designed for traders who value precision, structure, and control over raw signal frequency.

## Source Code

````pine
//@version=6
indicator("Trend V2 Exact + Soft Filters", shorttitle="Confirm", format=format.price, precision=2, timeframe="", timeframe_gaps=true)

//----------------------------------------------------
// Inputs
//----------------------------------------------------
period    = input.int(14, "Length", minval=2)
smoothLen = input.int(6, "Purple Smoothing Length", minval=1)
signalLen = input.int(10, "Yellow Signal Length", minval=1)

sellStrengthLevel = input.float(67.0, "Sell: Yellow Above", step=0.5)
sellTouchLevel    = input.float(75.0, "Sell: Purple Touch Above", step=0.5)

buyStrengthLevel  = input.float(-67.0, "Buy: Yellow Below", step=0.5)
buyTouchLevel     = input.float(-75.0, "Buy: Purple Touch Below", step=0.5)

showWeakSignals   = input.bool(true, "Show Weak Signals")
showStrongSignals = input.bool(true, "Show Strong Signals")

// Soft filters
useTurnFilter      = input.bool(true, "Use Purple Turn Filter")
turnLookback       = input.int(1, "Turn Lookback", minval=1)

useVolumeFilter    = input.bool(false, "Use Volume Direction Filter")
volLookback        = input.int(1, "Volume Lookback", minval=1)

useLiquidityFilter = input.bool(false, "Use Liquidity Direction Filter")
liqMode            = input.string("Volume x True Range", "Liquidity Proxy", options=["Volume x True Range", "Volume x Close"])
liqLookback        = input.int(1, "Liquidity Lookback", minval=1)

//----------------------------------------------------
// Core calculation
//----------------------------------------------------
tsiRaw = ta.correlation(close, bar_index, period)
tsi    = ta.ema(tsiRaw, smoothLen)
signal = ta.ema(tsi, signalLen)

purple = tsi * 100.0
yellow = signal * 100.0

//----------------------------------------------------
// Soft filters
//----------------------------------------------------
purpleTurningUp   = purple > purple[turnLookback]
purpleTurningDown = purple < purple[turnLookback]

turnBuyOk  = not useTurnFilter or purpleTurningUp
turnSellOk = not useTurnFilter or purpleTurningDown

volRising  = volume > volume[volLookback]
volFalling = volume < volume[volLookback]

volBuyOk  = not useVolumeFilter or volRising
volSellOk = not useVolumeFilter or volFalling

trueRange = ta.tr(true)
liqRaw    = liqMode == "Volume x True Range" ? volume * trueRange : volume * close

liqRising  = liqRaw > liqRaw[liqLookback]
liqFalling = liqRaw < liqRaw[liqLookback]

liqBuyOk  = not useLiquidityFilter or liqRising
liqSellOk = not useLiquidityFilter or liqFalling

buyFilterOk  = turnBuyOk and volBuyOk and liqBuyOk
sellFilterOk = turnSellOk and volSellOk and liqSellOk

//----------------------------------------------------
// Exact event-state logic
//----------------------------------------------------
sellZone  = yellow >= sellStrengthLevel
buyZone   = yellow <= buyStrengthLevel

sellTouch = purple >= sellTouchLevel
buyTouch  = purple <= buyTouchLevel

sellCross = ta.crossunder(purple, yellow)
buyCross  = ta.crossover(purple, yellow)

var bool sellReady = false
var bool buyReady  = false
var int lastSignal = 0   // 1 = last buy, -1 = last sell, 0 = none

// Arm setup (never blocked by filters)
if lastSignal != -1 and sellZone and sellTouch
    sellReady := true

if lastSignal != 1 and buyZone and buyTouch
    buyReady := true

// Weak setup signals
weakSell = sellReady and lastSignal != -1
weakBuy  = buyReady and lastSignal != 1

// Strong trigger = first valid cross after armed
strongSell = sellReady and lastSignal != -1 and sellCross and sellFilterOk
strongBuy  = buyReady and lastSignal != 1 and buyCross and buyFilterOk

// Alternate lock
if strongSell
    lastSignal := -1
    sellReady := false
    buyReady := false

if strongBuy
    lastSignal := 1
    buyReady := false
    sellReady := false

//----------------------------------------------------
// Plots
//----------------------------------------------------
purplePlot = plot(purple, "Purple", color=#7E57C2, linewidth=2)
yellowPlot = plot(yellow, "Yellow", color=color.orange, linewidth=2)

hline(0, "Middle", color=color.new(color.gray, 60))
hline(100, "Upper Band", color=color.new(color.green, 80))
hline(-100, "Lower Band", color=color.new(color.red, 80))

hline(sellStrengthLevel, "Sell Strength", color=color.new(color.red, 50), linestyle=hline.style_dashed)
hline(sellTouchLevel, "Sell Touch", color=color.new(color.red, 0), linestyle=hline.style_dotted)
hline(buyStrengthLevel, "Buy Strength", color=color.new(color.green, 50), linestyle=hline.style_dashed)
hline(buyTouchLevel, "Buy Touch", color=color.new(color.green, 0), linestyle=hline.style_dotted)

plotshape(showStrongSignals and strongBuy,  title="SB", style=shape.triangleup,   location=location.bottom, color=color.green, size=size.tiny, text="SB")
plotshape(showStrongSignals and strongSell, title="SS", style=shape.triangledown, location=location.top,    color=color.red,   size=size.tiny, text="SS")

plotshape(showWeakSignals and weakBuy and not weakBuy[1],   title="WB", style=shape.circle, location=location.bottom, color=color.new(color.green, 65), size=size.tiny, text="WB")
plotshape(showWeakSignals and weakSell and not weakSell[1], title="WS", style=shape.circle, location=location.top,    color=color.new(color.red, 65), size=size.tiny, text="WS")

// Alerts
alertcondition(strongBuy, "Strong Buy", "TSI V2 Soft Filters Strong Buy")
alertcondition(strongSell, "Strong Sell", "TSI V2 Soft Filters Strong Sell")
alertcondition(showWeakSignals and weakBuy and not weakBuy[1], "Weak Buy", "TSI V2 Soft Filters Weak Buy")
alertcondition(showWeakSignals and weakSell and not weakSell[1], "Weak Sell", "TSI V2 Soft Filters Weak Sell")
````
