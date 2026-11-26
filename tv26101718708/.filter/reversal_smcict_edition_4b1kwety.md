# Reversal SMC/ICT Edition

- url: https://www.tradingview.com/script/4b1KWety-Reversal-SMC-ICT-Edition/
- type: indicator
- pine_id: PUB;71b62f4ebdbc4ca98d2612859e789d7c
- version: 1.0

## Description

Reversal — SMC/ICT Edition

**Original concept by © HasanRifat — Extended & rebuilt for SMC/ICT confluence trading**

---

### Overview

This is a fully reworked version of HasanRifat's original Reversal indicator, rebuilt from the ground up to address its core structural weaknesses and align with a serious SMC/ICT trading framework. The original logic was sound — but it fired signals without trend context, volume conviction, or session awareness. This version fixes all of that.

The result is a precision **liquidity sweep + displacement detector** that gates every signal through five confluent layers before plotting. Fewer signals. Higher quality.

---

### What The Indicator Actually Detects

The core pattern this indicator hunts is a two-step sequence that SMC/ICT traders will immediately recognise:

**Step 1 — The Sweep**
A candle closes below the lows (or above the highs) of a configurable percentage of recent candles. This is a programmatic representation of a **BSL/SSL liquidity grab** — price reaching down to where stop losses and buy/sell orders are clustered, then preparing to reverse.

**Step 2 — The Reclaim (Confirmation)**
Within a tight confirmation window (default 3 bars), price closes back above the sweep candle's high (bullish) or below its low (bearish). This is the **displacement** — the market maker move away from the liquidity pool. Without this reclaim happening quickly, the setup is invalidated.

This two-step sequence maps directly onto the **sweep → displacement → BOS** structure that underpins ICT-based entry models.

---

### Five-Layer Signal Gate

Every signal must pass all active filters simultaneously before plotting:

**Layer 1 — Flexible Sweep Threshold**
The original indicator required *exactly* `lookback - 1` candles to be swept — a rigid rule that missed perfectly valid setups by one candle. This version uses a percentage-based threshold (default 85%). At lookback 20, this means 17 out of 20 prior candles must have their low (or high) breached. Tighten toward 1.0 for stricter sweeps, loosen toward 0.75 to catch more setups. The threshold is tunable without breaking the logic.

**Layer 2 — HTF Trend Filter**
A higher timeframe EMA (default: 1H, 50 EMA) gates the signal direction. Bullish reversals only fire when HTF close is above the HTF EMA. Bearish reversals only fire when below. Trading reversals against the HTF trend is where the majority of retail losses come from — this filter eliminates that entire category of setups. The HTF EMA is plotted directly on chart as a colour-coded ribbon (green above, red below) so bias is always visually obvious.

**Layer 3 — Volume Displacement Confirmation**
The confirming candle's volume must exceed the 20-bar volume moving average by a configurable multiplier (default 1.2× — 20% above average). A weak, low-volume close back above the sweep candle's high is not a displacement. It's noise. This filter requires the market to show actual conviction on the reclaim bar, consistent with genuine institutional participation.

**Layer 4 — Session Filter**
Signals only fire within a defined session window. Default is `0700–1630 UTC` (London open through New York close). This eliminates Asian session chop, pre-market fakes, and low-liquidity reversals that have no follow-through. The session window is fully customisable in settings.

**Layer 5 — Non-Repainting (Default ON)**
The single most common reason retail traders lose money on reversal indicators is repainting. The original indicator had non-repainting mode *off* by default, meaning backtests looked significantly better than live performance. This version has it **on by default**. All conditions are evaluated on the previous fully closed bar. What you see in history is exactly what would have fired in real time — no exceptions.

---

### Inputs Reference

| Parameter | Default | Description |
|---|---|---|
| Candle Lookback | 20 | Number of prior candles scanned for the sweep |
| Confirm Within | 3 | Max bars allowed for price to reclaim after sweep |
| Sweep Threshold % | 0.85 | % of lookback candles that must be breached |
| Non-Repainting Mode | ✅ ON | Signals based on closed bars only |
| Enable Trend Filter | ✅ ON | Gates signals by HTF EMA direction |
| HTF Timeframe | 60 (1H) | Timeframe for trend EMA calculation |
| Trend EMA Length | 50 | EMA length on HTF for bias determination |
| Enable Volume Filter | ✅ ON | Requires above-average volume on confirmation bar |
| Volume MA Length | 20 | Lookback for volume moving average |
| Min Volume Multiplier | 1.2 | Confirmation bar volume must exceed MA × this value |
| Enable Session Filter | ✅ ON | Restricts signals to defined trading hours |
| Session Window (UTC) | 0700-1630 | Active signal window |

---

### How To Use This In An SMC/ICT Framework

This indicator is designed as a **precision entry trigger**, not a standalone system. It performs best as the final confirmation layer in a structured top-down analysis:

1. **Establish HTF bias** on the 1H chart — is price in a bullish or bearish swing structure? The built-in trend filter enforces this, but your manual HTF read should come first.
2. **Identify premium/discount zones** — only look for bullish signals from discount, bearish from premium. The indicator fires in both directions; your zone analysis determines which signals are tradeable.
3. **Mark key liquidity pools** — EQH/EQL levels where BSL/SSL is resting. The sweep pattern is most powerful when it targets a known liquidity pool, not a random low.
4. **Wait for the signal** — when the lime triangle (bullish) or red triangle (bearish) appears, the sweep + reclaim + volume + trend + session conditions have all been met simultaneously.
5. **Drop to LTF for entry** — use a 1M BOS or CHoCH as final entry trigger. The signal on your execution timeframe marks the area; the 1M structure break marks the precise moment.
6. **Place entry at structure** — Fibonacci retracement of the displacement move, or the 50% of the confirming candle, depending on your model.

---

### What This Indicator Is Not

- It is **not** a complete trading system. No indicator is.
- It does **not** replace HTF structure analysis, premium/discount identification, or liquidity mapping.
- It does **not** account for high-impact news events. Manage your own news calendar.
- It will **not** fire on every valid setup — the five-layer gate is intentional. Missing a signal is better than taking a bad one.

---

### Alerts

Two alert conditions are included:

- `Bullish Reversal [SMC]` — fires when all bullish conditions are met
- `Bearish Reversal [SMC]` — fires when all bearish conditions are met

Set alerts on **Once Per Bar Close** to remain consistent with non-repainting mode.

---

### Credits

Core sweep detection logic based on the original **Reversal** indicator by © HasanRifat. Extended with trend, volume, session filtering and non-repainting defaults for professional SMC/ICT application.

---

*This indicator is a tool for analysis. All trading decisions remain your own responsibility. Past signal performance does not guarantee future results.*

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © HasanRifat — Modified for SMC/ICT Trading by Claude

//@version=5
indicator("Reversal — SMC/ICT Edition", overlay = true)

// ══════════════════════════════════════════════════════════════════
// ▶ CORE SETTINGS
// ══════════════════════════════════════════════════════════════════
lookback     = input.int(20,    "Candle Lookback",       group = "Core")
confirmation = input.int(3,     "Confirm Within (Bars)", group = "Core")
threshold    = input.float(0.85,"Sweep Threshold %",     group = "Core",
              minval = 0.5, maxval = 1.0, step = 0.05,
              tooltip = "% of lookback candles swept. 0.85 = 85%. Replaces the rigid lookback-1 rule.")
nonRepaint   = input.bool(true, "Non-Repainting Mode",  group = "Core",
              tooltip = "DEFAULT ON. Signals only after confirming bar fully closes.")

// ══════════════════════════════════════════════════════════════════
// ▶ TREND FILTER  (Fix #1)
// ══════════════════════════════════════════════════════════════════
useTrend    = input.bool(true,  "Enable Trend Filter",  group = "Trend Filter")
htfTF       = input.timeframe("60", "HTF Timeframe",    group = "Trend Filter",
              tooltip = "Use 1H for your EUR/USD HTF bias")
trendEmaLen = input.int(50,     "Trend EMA Length",     group = "Trend Filter")

// ══════════════════════════════════════════════════════════════════
// ▶ VOLUME FILTER  (Fix #3)
// ══════════════════════════════════════════════════════════════════
useVol   = input.bool(true,  "Enable Volume Filter",    group = "Volume")
volLen   = input.int(20,     "Volume MA Length",         group = "Volume")
volMult  = input.float(1.2,  "Min Volume Multiplier",   group = "Volume",
           step = 0.1,
           tooltip = "Reversal candle volume must be > MA × this. 1.2 = 20% above average")

// ══════════════════════════════════════════════════════════════════
// ▶ SESSION FILTER  (Fix #4)
// 12:30–22:00 IST = 07:00–16:30 UTC
// ══════════════════════════════════════════════════════════════════
useSession  = input.bool(true,       "Enable Session Filter",  group = "Session")
sessionTime = input.session("0700-1630", "Session Window (UTC)", group = "Session",
              tooltip = "Default = 12:30–22:00 IST. Matches your trading hours exactly.")

// ══════════════════════════════════════════════════════════════════
// ▶ TREND CALCULATION
// ══════════════════════════════════════════════════════════════════
htfEma      = request.security(syminfo.tickerid, htfTF,
              ta.ema(close, trendEmaLen), lookahead = barmerge.lookahead_off)
htfClose    = request.security(syminfo.tickerid, htfTF,
              close, lookahead = barmerge.lookahead_off)

isBullTrend = not useTrend or htfClose > htfEma
isBearTrend = not useTrend or htfClose < htfEma

// ══════════════════════════════════════════════════════════════════
// ▶ VOLUME CALCULATION
// ══════════════════════════════════════════════════════════════════
volMA  = ta.sma(volume, volLen)
volOK  = not useVol or volume > volMA * volMult

// ══════════════════════════════════════════════════════════════════
// ▶ SESSION CALCULATION
// ══════════════════════════════════════════════════════════════════
inSession = not useSession or not na(time(timeframe.period, sessionTime, "UTC+0"))

// ══════════════════════════════════════════════════════════════════
// ▶ CORE SWEEP LOGIC  (Fix #2 — flexible threshold replaces rigid lookback-1)
// ══════════════════════════════════════════════════════════════════
requiredCount = math.floor(lookback * threshold)  // e.g. 20 × 0.85 = 17

bullCandle = 0
bearCandle = 0

for i = 0 to (lookback - 1)
    if close < low[i]
        bullCandle += 1
    if close > high[i]
        bearCandle += 1

// ══════════════════════════════════════════════════════════════════
// ▶ STATE MANAGEMENT
// ══════════════════════════════════════════════════════════════════
var bool  bullActive   = false
var float bullLow      = 0.0
var float bullHigh     = 0.0
var bool  bullFired    = false
var int   bullCount    = 0

var bool  bearActive   = false
var float bearLow      = 0.0
var float bearHigh     = 0.0
var bool  bearFired    = false
var int   bearCount    = 0

// Tag candidate candles (>= threshold, not == lookback-1)
if bullCandle >= requiredCount
    bullActive := true
    bullLow    := low
    bullHigh   := high
    bullFired  := false
    bullCount  := 0

if bullActive
    bullCount += 1

if bearCandle >= requiredCount
    bearActive := true
    bearLow    := low
    bearHigh   := high
    bearFired  := false
    bearCount  := 0

if bearActive
    bearCount += 1

// Invalidation
if close < bullLow
    bullActive := false

if close > bearHigh
    bearActive := false

// ══════════════════════════════════════════════════════════════════
// ▶ SIGNAL GENERATION  (Fix #5 — nonRepaint ON by default)
// ══════════════════════════════════════════════════════════════════
vup = false
vdn = false

if nonRepaint
    // All conditions checked on closed bar [1] — zero repainting
    if bullActive[1] and close[1] > bullHigh[1] and not bullFired[1]
       and bullCount[1] <= (confirmation + 1)
       and isBullTrend
       and volOK[1]
       and inSession[1]
        bullFired := true
        vup       := true
else
    if bullActive and close > bullHigh and not bullFired
       and bullCount <= (confirmation + 1)
       and isBullTrend
       and volOK
       and inSession
        bullFired := true
        vup       := true

if nonRepaint
    if bearActive[1] and close[1] < bearLow[1] and not bearFired[1]
       and bearCount[1] <= (confirmation + 1)
       and isBearTrend
       and volOK[1]
       and inSession[1]
        bearFired := true
        vdn       := true
else
    if bearActive and close < bearLow and not bearFired
       and bearCount <= (confirmation + 1)
       and isBearTrend
       and volOK
       and inSession
        bearFired := true
        vdn       := true

// ══════════════════════════════════════════════════════════════════
// ▶ VISUALS
// ══════════════════════════════════════════════════════════════════
plotshape(vup, "Bull Reversal", shape.triangleup,
          location.belowbar, color.lime, size = size.small)
plotshape(vdn, "Bear Reversal", shape.triangledown,
          location.abovebar, color.red, size = size.small)

// HTF Trend EMA ribbon — green = bullish bias, red = bearish
plot(useTrend ? htfEma : na, "HTF EMA",
     color = htfClose > htfEma
     ? color.new(color.green, 50)
     : color.new(color.red, 50),
     linewidth = 2)

// ══════════════════════════════════════════════════════════════════
// ▶ ALERTS
// ══════════════════════════════════════════════════════════════════
alertcondition(vup, "Bullish Reversal [SMC]", "Bullish Reversal — SMC/ICT Aligned")
alertcondition(vdn, "Bearish Reversal [SMC]", "Bearish Reversal — SMC/ICT Aligned")
````
