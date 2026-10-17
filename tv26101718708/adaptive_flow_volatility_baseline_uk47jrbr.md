# Adaptive Flow & Volatility Baseline

- url: https://www.tradingview.com/script/uK47JrbR-Adaptive-Flow-Volatility-Baseline/
- type: indicator
- pine_id: PUB;10eb4abced72414fb95c4b85a4397926
- version: 1.0

## Description

Most retail indicators fail because they ask a single, one-dimensional question: What is the price doing?

The One Line is a multi-factor state machine designed to filter out the noise that traps retail traders. Instead of relying on lagging moving averages, it requires the mathematical confluence of price expansion, directional money flow, higher-timeframe alignment, and implied volatility (VIX) to validate a trend. If the institutional data does not support the move, the indicator stays flat, keeping you out of the chop.

Core Mechanics
Under the hood, this script processes four institutional data pillars into a single, easy-to-read baseline:

[list]
[*]Adaptive Efficiency Smoothing (KAMA): The baseline blends a VWMA and SMA, dynamically adjusted by Kaufman’s Efficiency Ratio (ER). During strong trends, the line tracks price closely. When the market turns into a noisy, inefficient mess, the alpha drops and the line goes completely flat.
[*]
[*]Directional Volume Flow (VFI): Rather than using raw volume—which can be easily skewed by a single block trade—the model calculates a Volume Flow Indicator (VFI). It caps anomalous volume spikes and tracks whether the underlying money flow is actually accumulating or distributing.
[*]
[*]Macro IV Filter (VIX): Equities do not move in a vacuum. The model continuously pulls real-time VIX data. A bullish breakout will only trigger if the VIX is in a state of crush (falling), and a bearish breakdown requires the VIX to be expanding.
[*]
[*]Non-Repainting MTF Trend: A strict, non-repainting higher-timeframe filter ensures you are never taking intraday signals against the macro structural trend.
[/list]

How to Read the Chart
The indicator operates in three distinct regimes, represented by the color of the baseline and the surrounding volatility cloud (fueled by an exponentially smoothed ATR).

[list]
[*]Green (Bullish Regime): Price has broken above the upper volatility band, VFI shows net accumulation, the higher-timeframe trend is up, and the VIX is cooperating. Action: Look for long entries on pullbacks to the baseline.
[*]
[*]Red (Bearish Regime): Price has broken below the lower volatility band, VFI shows net distribution, the higher-timeframe trend is down, and the VIX is expanding. Action: Look for short entries or put options.
[*]
[*]Gray (Chop / Trap Zone): The market is mathematically inefficient. This triggers when price reverts inside the bands, volume dries up, or a structural divergence occurs (e.g., price is rising but VFI money flow suddenly turns negative). Action: Capital preservation. Sit on your hands.
[/list]

Trading Playbook & Best Practices
[list=1]
[*]The "Trap" Exit: The smartest feature of this indicator is its dynamic reversion. If you are in a valid Green trend, but the underlying money flow (VFI) suddenly flips negative, the line will instantly turn Gray. Do not wait for price to hit your stop-loss. If the line turns gray, the institutional support for the move has vanished. Exit or trim your position.
[*]
[*]Asset Class: This model was built specifically for highly liquid, volume-heavy instruments like SPY, QQQ, and ES/NQ futures.
[*]
[*]Timeframes: It thrives on the 3-minute, 5-minute, and 15-minute charts. (Ensure the "Macro Timeframe" input is set appropriately higher than your chart timeframe, e.g., a 30m MTF on a 5m chart).
[*]
[/list]
Trade the regime, not the noise.

## Source Code

````pine
//@version=6
indicator("One Line [Advanced Volatility]", overlay=true)

// --- Inputs ---
grpCore = "Core Settings"
src = input.source(close, title="Source", group=grpCore)
length = input.int(20, title="Core Loop Length", group=grpCore)

grpMTF = "Higher Timeframe Filter"
useMTF = input.bool(true, title="Enable MTF Filter?", group=grpMTF)
mtfResolution = input.timeframe("30", title="Macro Timeframe", group=grpMTF)

grpVol = "Volume Flow & IV Context"
vfiLength = input.int(89, title="VFI Length (Intraday)", group=grpVol, tooltip="89 is highly responsive for intraday flows. 130 is standard for daily.")
useVIX = input.bool(true, title="Enable VIX Filter?", group=grpVol)
vixTicker = input.symbol("TVC:VIX", title="VIX Ticker", group=grpVol)

// --- 1. Higher Timeframe Context (Non-Repainting) ---
var bool macroTrendBullish = true
if useMTF
    // Safely request the MTF state from the last closed bar
    [mtfClose, mtfEMA] = request.security(syminfo.tickerid, mtfResolution, [close[1], ta.ema(close, 50)[1]], lookahead = barmerge.lookahead_on)
    macroTrendBullish := mtfClose > mtfEMA

// --- 2. Macro IV (VIX) Filter ---
// We pull VIX on the *current* chart timeframe to track real-time IV crush/expansion
var float vixVal = na
var float vixEMA = na
if useVIX
    [v, vEma] = request.security(vixTicker, timeframe.period, [close, ta.ema(close, 20)])
    vixVal := v
    vixEMA := vEma

// VIX Logic: Falling VIX supports equities (Bullish). Rising VIX supports equities selling off (Bearish).
bool vixSupportsBull = useVIX ? (vixVal < vixEMA) : true 
bool vixSupportsBear = useVIX ? (vixVal > vixEMA) : true 

// --- 3. Volume Flow Indicator (VFI) ---
// Calculates directional money flow by capping anomalous volume spikes
mf = hlc3 - hlc3[1]
volSMA = ta.sma(volume, vfiLength)
volCap = volSMA * 2.5 // Cap max volume to prevent single-bar distortions
vma = volume > volCap ? volCap : volume

// Assign volume to positive or negative flow
dirVol = mf > 0 ? vma : (mf < 0 ? -vma : 0)
// Smooth the final VFI ratio
vfi = ta.ema(math.sum(dirVol, vfiLength) / volSMA, 3)

// --- 4. Adaptive Hybrid Core (VWMA & KAMA) ---
baseVWMA = ta.vwma(src, length)
baseSMA = ta.sma(src, length)
coreBlend = math.avg(baseSMA, baseVWMA)

// Efficiency Ratio for adaptive smoothing
noise = math.sum(math.abs(src - src[1]), length)
signal = math.abs(src - src[length])
er = noise == 0 ? 0.0 : signal / noise
alpha = math.pow(er * (2.0 / 3.0 - 2.0 / 31.0) + (2.0 / 31.0), 2)

var float adaptiveBaseline = na
adaptiveBaseline := na(adaptiveBaseline[1]) ? coreBlend : adaptiveBaseline[1] + alpha * (coreBlend - adaptiveBaseline[1])

// --- 5. Volatility Expansion Bands ---
volatilityBuffer = ta.ema(ta.atr(length), 5) * 0.75
upperThreshold = adaptiveBaseline + volatilityBuffer
lowerThreshold = adaptiveBaseline - volatilityBuffer

// --- 6. Advanced Regime State Machine ---
var int regime = 0 // 1 = Bullish, -1 = Bearish, 0 = Chop

// Confluence: Price Breakout + Directional Money Flow + IV Alignment + MTF Trend
bool bullishBreakout = close > upperThreshold and vfi > 0 and macroTrendBullish and vixSupportsBull
bool bearishBreakout = close < lowerThreshold and vfi < 0 and not macroTrendBullish and vixSupportsBear

if bullishBreakout
    regime := 1
else if bearishBreakout
    regime := -1
// Dynamic chop reversion based on market inefficiency (ER drops) or structural VFI breakdown
else if er < 0.2 or (regime == 1 and vfi < 0) or (regime == -1 and vfi > 0)
    regime := 0 

// --- Plots & Presentation ---
lineColor = regime == 1 ? color.green : (regime == -1 ? color.red : color.gray)

// Main clean line plot
plot(adaptiveBaseline, title="One Line", color=lineColor, linewidth=3)

// Ultra-faint coaxial cloud to define the structural "Chop Zone"
p1 = plot(upperThreshold, title="Upper Chop Limit", color=color.new(color.gray, 92), linewidth=1)
p2 = plot(lowerThreshold, title="Lower Chop Limit", color=color.new(color.gray, 92), linewidth=1)
fill(p1, p2, color=regime == 0 ? color.new(color.gray, 96) : (regime == 1 ? color.new(color.green, 96) : color.new(color.red, 96)), title="Chop Zone Fill")
````
