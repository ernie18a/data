# JANETV2.0 MINICRORE)

- url: https://www.tradingview.com/script/BHv2f0Vf-JANETV2-0-MINICRORE/
- type: indicator
- pine_id: PUB;754ee3fc80324468a803e6b5d7775ae8
- version: 1.0

## Description

# JANETV2.0 MINICRORE(Pine Script v6)


---

## What This Indicator Does

JANETV2.0 MINICRORE combines multi-timeframe trend bias, institutional activity detection, demand/supply zones, and LOC/POC levels — all on one chart. It is designed for NSE/Nifty options trading on TradingView.

---

## Features

### A. JANETV2.0 MINICRORE Trend (Candle Coloring)
Candles are colored based on combined Higher Timeframe + current timeframe bias:

| Color | Meaning |
|-------|---------|
| 🟢 Lime Green | Strong Bullish (HTF + LTF both bullish) |
| 🔴 Red | Strong Bearish (HTF + LTF both bearish) |
| 🟠 Orange | Mixed (HTF and LTF disagree) |
| ⬜ Gray | Neutral |
| 🔵 Dark Navy Blue | **Institutional BUY** (overrides trend color) |
| 🔴 Dark Blood Red | **Institutional SELL** (overrides trend color) |

---

### B. Institutional Candles
Detects large institutional activity — highest priority in candle coloring.

**Institutional BUY (Dark Navy Blue candle):**
- Bullish candle (close > open)
- Volume > 2× the 20-bar average
- Body size > 0.6× ATR(14)
- Price above EMA 20
- Marked with ▲ "I-BUY" label below bar

**Institutional SELL (Dark Blood Red candle):**
- Bearish candle (close < open)
- Volume > 2× the 20-bar average
- Body size > 0.6× ATR(14)
- Price below EMA 20
- Marked with ▼ "I-SELL" label above bar

> Adjust sensitivity via inputs: **Volume Multiplier** and **Min Body/ATR ratio**

---

### C. LOC / POC Lines
**LOC = Level of Control | POC = Point of Control**
Approximated using VWAP (Volume Weighted Average Price) per timeframe — the price level where the most volume traded.

| Line | Color | Timeframe |
|------|-------|-----------|
| 4HR LOC | 🔵 Blue | 4-Hour VWAP |
| 1D LOC | 🟡 Yellow | Daily VWAP |
| Weekly LOC | 🟣 Purple | Weekly VWAP |
| Monthly LOC | 🟠 Orange | Monthly VWAP |

Lines are drawn as **step lines** — they stay flat within each period and step when the new period begins.

Current LOC values are shown live in the **info table** (top-right corner).

---

### D. Sell Zones (2 per timeframe, above LOC)

Two sell/resistance zones are drawn **above each LOC** using ATR-based spacing:

| Zone | Position | Color |
|------|----------|-------|
| S1 (closer) | LOC + Gap | Lighter shade |
| S2 (further) | LOC + Gap + Width | Darker shade |

| Timeframe | Sell Zone Color |
|-----------|----------------|
| 4HR | 🔴 Red |
| 1D | 🟤 Maroon |
| Weekly | 🟣 Purple |
| Monthly | 🟠 Orange |

---

### E. Buy Zones (2 per timeframe, below LOC)

Two buy/support zones are drawn **below each LOC**:

| Zone | Position | Color |
|------|----------|-------|
| B1 (closer) | LOC − Gap | Lighter shade |
| B2 (further) | LOC − Gap − Width | Darker shade |

| Timeframe | Buy Zone Color |
|-----------|---------------|
| 4HR | 🟢 Lime |
| 1D | 🩵 Teal |
| Weekly | 🔵 Blue |
| Monthly | 🟡 Yellow |

---

### F. JANETV2.0 MINICRORE Zones (Order Blocks)
Auto-detects institutional order blocks from recent price action:
- **Demand Zone (green)** — last down candle before a significant up move
- **Supply Zone (red)** — last up candle before a significant down move

Zones extend to the right. Lookback and ATR threshold are adjustable.

---

### G. Market Phase Labels
Detects and labels market phase changes on the chart:

| Label | Meaning |
|-------|---------|
| ACCUMULATION | Tight range, low volatility — institutions loading |
| EXPANSION | Trending, wide range — breakout in progress |
| ACCUM+TRAP | Accumulation + stop hunt wicks — trap detected |
| COMPRESS+TRAP | Expansion + wicks — fake breakout / liquidity grab |

Labels only print when the phase **changes** (no clutter).

---

### H. BUY / SELL Signals
Fires only when ALL three conditions align:
- HTF bias confirmed (price above/below HTF EMA 50)
- EMA 9 crosses EMA 20 (current TF)
- Market is NOT in Accumulation phase

---

## Settings Reference

### JANETV2.0 MINICRORE Trend
| Setting | Default | Description |
|---------|---------|-------------|
| HTF Timeframe | 15m | Timeframe for trend bias filter |
| Fast EMA | 9 | Short EMA |
| Slow EMA | 20 | Long EMA |
| HTF EMA | 50 | EMA used on HTF for bias |
| Color candles | ON | Toggle candle coloring |

### Institutional
| Setting | Default | Description |
|---------|---------|-------------|
| Show Institutional Candles | ON | Toggle dark blue/red candles |
| Volume Multiplier | 2.0× | Min volume vs 20-bar SMA |
| Min Body/ATR ratio | 0.6 | Min candle body relative to ATR |

### JANETV2.0 MINICRORE Zones
| Setting | Default | Description |
|---------|---------|-------------|
| Order Block Lookback | 10 bars | How far back to detect OBs |
| Show Demand Zones | ON | Green demand boxes |
| Show Supply Zones | ON | Red supply boxes |
| Extend zones right | 40 bars | How far zones extend |
| Min ATR multiplier | 0.5 | Min move to qualify as OB |

### LOC/POC Levels
| Setting | Default | Description |
|---------|---------|-------------|
| 4HR/1D/Weekly/Monthly | ON | Toggle each timeframe |
| Zone Gap from LOC | 0.3 ATR | Space between LOC and Zone 1 |
| Zone Width | 0.7 ATR | Height of each zone |
| Extend zones right | 50 bars | How far zones extend |

### Market Phase
| Setting | Default | Description |
|---------|---------|-------------|
| Show Phase Labels | ON | Toggle phase change labels |
| Phase Length | 20 bars | Lookback for range/ATR comparison |

---

## How to Use

1. **Open TradingView** → Pine Script Editor (bottom panel)
2. Paste the full contents of `JANETV2.0 MINICRORE`
3. Click **Add to chart**
4. Recommended chart timeframes: **1m, 3m, 5m, 15m**
5. Set HTF Timeframe input to one step above your chart (e.g. 15m on a 5m chart)

### Trading Checklist
- [ ] Is the candle color bullish (green/dark blue)?
- [ ] Is price above the LOC for your timeframe?
- [ ] Is price inside a Buy Zone (B1 or B2)?
- [ ] Is the phase EXPANSION (not accumulation)?
- [ ] Is there an I-BUY dark blue candle confirming entry?

---

## Color Quick Reference

```
Dark Navy Blue candle  → Institutional Buy
Dark Blood Red candle  → Institutional Sell
Blue line              → 4HR LOC/POC
Yellow line            → 1D LOC/POC
Purple line            → Weekly LOC/POC
Orange line            → Monthly LOC/POC
Red boxes (S1/S2)      → Sell zones above LOC
Green boxes (B1/B2)    → Buy zones below LOC
Green shaded boxes     → Demand order blocks
Red shaded boxes       → Supply order blocks
```

---

## Notes
- LOC/POC is approximated via **VWAP** — not a full volume profile. For exact POC, use TradingView's built-in Volume Profile indicator alongside this.
- Zone sizes scale with **ATR** of the respective timeframe — wider on higher timeframes, tighter on lower.
- All zones redraw on each new bar close (barstate.islast).
- Works on any NSE/BSE symbol or index (Nifty, BankNifty, stocks).

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © minicrore

//@version=6
indicator("JANETV2.0 MINICRORE)",
     shorttitle="JANETV2.0 MINICRORE", overlay=true,
     max_boxes_count=500, max_labels_count=200, max_lines_count=50)

// ═══════════════════════════════════════════════════════════════════
//  INPUTS — JANETV2.0 TREND
// ═══════════════════════════════════════════════════════════════════
htfRes      = input.timeframe("15",   "HTF Timeframe (trend bias)",  group="GTI Trend")
emaFast     = input.int(9,            "Fast EMA",                     group="GTI Trend")
emaSlow     = input.int(20,           "Slow EMA",                     group="GTI Trend")
emaHTF      = input.int(50,           "HTF EMA (bias filter)",        group="GTI Trend")
showCandles = input.bool(true,        "Color candles by bias",        group="GTI Trend")

// ═══════════════════════════════════════════════════════════════════
//  INPUTS — INSTITUTIONAL CANDLES
// ═══════════════════════════════════════════════════════════════════
showInst    = input.bool(true,  "Show Institutional Candles",        group="Institutional")
instVolMult = input.float(2.0,  "Volume Multiplier (× 20-bar SMA)", group="Institutional")
instBodyPct = input.float(0.6,  "Min Body / ATR ratio",              group="Institutional")

// ═══════════════════════════════════════════════════════════════════
//  INPUTS — GHOST ZONES (ORDER BLOCKS)
// ═══════════════════════════════════════════════════════════════════
zoneLen = input.int(10,    "Order Block Lookback (bars)", group="Ghost Zones")
showDem = input.bool(true, "Show Demand Zones",           group="Ghost Zones")
showSup = input.bool(true, "Show Supply Zones",           group="Ghost Zones")
zoneExt = input.int(40,    "Extend zones right (bars)",   group="Ghost Zones")
minMove = input.float(0.5, "Min ATR multiplier for OB",   group="Ghost Zones")

// ═══════════════════════════════════════════════════════════════════
//  INPUTS — MARKET PHASE
// ═══════════════════════════════════════════════════════════════════
showPhase = input.bool(true, "Show Phase Labels", group="Market Phase")
phaseLen  = input.int(20,    "Phase Length",      group="Market Phase")

// ═══════════════════════════════════════════════════════════════════
//  INPUTS — LOC / POC LEVELS + ZONES
// ═══════════════════════════════════════════════════════════════════
showH4LOC = input.bool(true,  "4HR  LOC/POC + Zones",     group="LOC/POC Levels")
showD1LOC = input.bool(true,  "1D   LOC/POC + Zones",     group="LOC/POC Levels")
showWkLOC = input.bool(true,  "Weekly LOC/POC + Zones",   group="LOC/POC Levels")
showMoLOC = input.bool(true,  "Monthly LOC/POC + Zones",  group="LOC/POC Levels")
zGap      = input.float(0.3,  "Gap from LOC (ATR mult)",  group="LOC/POC Levels")
zWidth    = input.float(0.7,  "Zone width (ATR mult)",    group="LOC/POC Levels")
pocExt    = input.int(50,     "Extend zones right (bars)", group="LOC/POC Levels")

// ═══════════════════════════════════════════════════════════════════
//  CORE CALCULATIONS
// ═══════════════════════════════════════════════════════════════════
atr      = ta.atr(14)
emaF     = ta.ema(close, emaFast)
emaS     = ta.ema(close, emaSlow)
volAvg   = ta.sma(volume, 20)
bodySize = math.abs(close - open)
ema20    = ta.ema(close, 20)

// ── HTF Trend Bias ────────────────────────────────────────────────
htfClose  = request.security(syminfo.tickerid, htfRes, close)
htfEma50  = request.security(syminfo.tickerid, htfRes, ta.ema(close, emaHTF))

htfBull   = htfClose > htfEma50
htfBear   = htfClose < htfEma50
ltfBull   = emaF > emaS
ltfBear   = emaF < emaS

strongBull = htfBull and ltfBull
strongBear = htfBear and ltfBear
mixed      = (htfBull and ltfBear) or (htfBear and ltfBull)

// ── Institutional Detection ───────────────────────────────────────
// Dark Blue candle = large bullish candle + high volume + price above EMA20
instBuy  = close > open
         and volume > instVolMult * volAvg
         and bodySize > instBodyPct * atr
         and close > ema20

// Dark Red candle = large bearish candle + high volume + price below EMA20
instSell = close < open
         and volume > instVolMult * volAvg
         and bodySize > instBodyPct * atr
         and close < ema20

// ── LOC / POC (VWAP per timeframe = best volume-weighted price level) ──
h4_loc = request.security(syminfo.tickerid, "240", ta.vwap)
d1_loc = request.security(syminfo.tickerid, "D",   ta.vwap)
wk_loc = request.security(syminfo.tickerid, "W",   ta.vwap)
mo_loc = request.security(syminfo.tickerid, "M",   ta.vwap)

// ATR per timeframe (for proportional zone sizing)
h4_atr = request.security(syminfo.tickerid, "240", ta.atr(14))
d1_atr = request.security(syminfo.tickerid, "D",   ta.atr(14))
wk_atr = request.security(syminfo.tickerid, "W",   ta.atr(14))
mo_atr = request.security(syminfo.tickerid, "M",   ta.atr(14))

// ── Market Phase ──────────────────────────────────────────────────
rangeHigh = ta.highest(high, phaseLen)
rangeLow  = ta.lowest(low,  phaseLen)
rangeSize = rangeHigh - rangeLow
atrAvg    = ta.sma(atr, phaseLen)

wickUp    = high - math.max(close, open)
wickDown  = math.min(close, open) - low
isTrap    = wickUp > bodySize and wickDown > bodySize

isAccum   = rangeSize < 1.5 * atrAvg
isExpand  = rangeSize > 2.5 * atrAvg

// ═══════════════════════════════════════════════════════════════════
//  CANDLE COLORING  (priority: Institutional > Trend > Neutral)
// ═══════════════════════════════════════════════════════════════════
instBuyClr  = color.new(#001F5B, 0)   // ■ Dark Navy Blue  = Institutional Buy
instSellClr = color.new(#7B0000, 0)   // ■ Dark Blood Red  = Institutional Sell
bullClr     = color.new(color.lime,   0)
bearClr     = color.new(color.red,    0)
mixClr      = color.new(color.orange, 0)
neutClr     = color.new(color.gray,  60)

candleClr = showInst and instBuy ? instBuyClr : showInst and instSell ? instSellClr : strongBull ? bullClr : strongBear ? bearClr : mixed ? mixClr : neutClr

barcolor(showCandles ? candleClr : na)

// ═══════════════════════════════════════════════════════════════════
//  PLOTS — EMAs
// ═══════════════════════════════════════════════════════════════════
plot(emaF, "EMA Fast",  color=color.new(color.orange, 0), linewidth=1)
plot(emaS, "EMA Slow",  color=color.new(color.green,  0), linewidth=1)

// ═══════════════════════════════════════════════════════════════════
//  PLOTS — LOC/POC LINES (step lines = flat within each TF period)
// ═══════════════════════════════════════════════════════════════════
//  🔵 4HR  = Blue    🟡 1D = Yellow    🟣 Weekly = Purple    🟠 Monthly = Orange
plot(showH4LOC ? h4_loc : na, "4HR LOC/POC",     color=color.new(#2962FF, 40), linewidth=2, style=plot.style_stepline)
plot(showD1LOC ? d1_loc : na, "1D  LOC/POC",     color=color.new(#F9A825, 40), linewidth=2, style=plot.style_stepline)
plot(showWkLOC ? wk_loc : na, "Weekly LOC/POC",  color=color.new(#9C27B0, 40), linewidth=2, style=plot.style_stepline)
plot(showMoLOC ? mo_loc : na, "Monthly LOC/POC", color=color.new(#FF6D00, 40), linewidth=2, style=plot.style_stepline)

// ═══════════════════════════════════════════════════════════════════
//  INSTITUTIONAL SIGNAL MARKERS
// ═══════════════════════════════════════════════════════════════════
plotshape(showInst and instBuy,  "I-Buy",
     shape.triangleup,   location.belowbar,
     color=color.new(#001F5B, 0), textcolor=color.white,
     text="I-BUY", size=size.small)

plotshape(showInst and instSell, "I-Sell",
     shape.triangledown, location.abovebar,
     color=color.new(#7B0000, 0), textcolor=color.white,
     text="I-SELL", size=size.small)

// ═══════════════════════════════════════════════════════════════════
//  BUY / SELL SIGNALS (combined bias + EMA cross + not in accumulation)
// ═══════════════════════════════════════════════════════════════════
buySignal  = strongBull and ta.crossover(emaF,  emaS) and not isAccum
sellSignal = strongBear and ta.crossunder(emaF, emaS) and not isAccum

plotshape(buySignal,  "BUY Signal",
     shape.labelup,   location.belowbar,
     color=color.lime, textcolor=color.black, text="BUY", size=size.small)

plotshape(sellSignal, "SELL Signal",
     shape.labeldown, location.abovebar,
     color=color.red,  textcolor=color.white, text="SELL", size=size.small)

// ═══════════════════════════════════════════════════════════════════
//  MARKET PHASE LABELS
// ═══════════════════════════════════════════════════════════════════
phaseText = isAccum and isTrap ? "ACCUM+TRAP" : isAccum ? "ACCUMULATION" : isExpand and isTrap ? "COMPRESS+TRAP" : isExpand ? "EXPANSION" : ""
phaseCol  = isAccum and isTrap ? color.purple : isAccum ? color.blue : isExpand and isTrap ? color.orange : isExpand ? color.yellow : na

if showPhase and barstate.isconfirmed and phaseText != "" and phaseText != phaseText[1]
    label.new(bar_index, high,
         text=phaseText, color=color.new(phaseCol, 20),
         textcolor=color.white, style=label.style_label_down, size=size.small)

// ═══════════════════════════════════════════════════════════════════
//  ZONES — drawn fresh each bar (barstate.islast)
// ═══════════════════════════════════════════════════════════════════
if barstate.islast

    // ──────────────────────────────────────────────────────────────
    //  A) Ghost Order Block Zones
    // ──────────────────────────────────────────────────────────────
    for i = 1 to zoneLen
        isDOB = close[i] < open[i]
             and close[i-1] > open[i-1]
             and (close[i-1] - open[i-1]) > minMove * atr[i]
        isSOB = close[i] > open[i]
             and close[i-1] < open[i-1]
             and (open[i-1] - close[i-1]) > minMove * atr[i]
        if showDem and isDOB
            box.new(bar_index - i, math.max(open[i], close[i]),
                    bar_index + zoneExt, math.min(open[i], close[i]),
                    border_color=color.new(color.lime, 30),
                    bgcolor=color.new(color.lime, 82), border_width=1)
        if showSup and isSOB
            box.new(bar_index - i, math.max(open[i], close[i]),
                    bar_index + zoneExt, math.min(open[i], close[i]),
                    border_color=color.new(color.red, 30),
                    bgcolor=color.new(color.red, 82), border_width=1)

    // ──────────────────────────────────────────────────────────────
    //  B) 4HR LOC/POC Zones   (Blue = Buy | Red = Sell)
    //     S1 just above LOC, S2 further above
    //     B1 just below LOC, B2 further below
    // ──────────────────────────────────────────────────────────────
    if showH4LOC
        // Sell Zone 1
        box.new(bar_index-1, h4_loc + (zGap + zWidth) * h4_atr,
                bar_index + pocExt, h4_loc + zGap * h4_atr,
                border_color=color.new(color.red, 30),
                bgcolor=color.new(color.red, 80), border_width=1,
                text="4H S1", text_color=color.white, text_size=size.tiny)
        // Sell Zone 2
        box.new(bar_index-1, h4_loc + (zGap + 2 * zWidth) * h4_atr,
                bar_index + pocExt, h4_loc + (zGap + zWidth) * h4_atr,
                border_color=color.new(color.red, 15),
                bgcolor=color.new(color.red, 68), border_width=1,
                text="4H S2", text_color=color.white, text_size=size.tiny)
        // Buy Zone 1
        box.new(bar_index-1, h4_loc - zGap * h4_atr,
                bar_index + pocExt, h4_loc - (zGap + zWidth) * h4_atr,
                border_color=color.new(color.lime, 30),
                bgcolor=color.new(color.lime, 80), border_width=1,
                text="4H B1", text_color=color.white, text_size=size.tiny)
        // Buy Zone 2
        box.new(bar_index-1, h4_loc - (zGap + zWidth) * h4_atr,
                bar_index + pocExt, h4_loc - (zGap + 2 * zWidth) * h4_atr,
                border_color=color.new(color.lime, 15),
                bgcolor=color.new(color.lime, 68), border_width=1,
                text="4H B2", text_color=color.white, text_size=size.tiny)

    // ──────────────────────────────────────────────────────────────
    //  C) 1D LOC/POC Zones   (Maroon = Sell | Teal = Buy)
    // ──────────────────────────────────────────────────────────────
    if showD1LOC
        box.new(bar_index-1, d1_loc + (zGap + zWidth) * d1_atr,
                bar_index + pocExt, d1_loc + zGap * d1_atr,
                border_color=color.new(color.maroon, 30),
                bgcolor=color.new(color.maroon, 80), border_width=1,
                text="1D S1", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, d1_loc + (zGap + 2 * zWidth) * d1_atr,
                bar_index + pocExt, d1_loc + (zGap + zWidth) * d1_atr,
                border_color=color.new(color.maroon, 15),
                bgcolor=color.new(color.maroon, 68), border_width=1,
                text="1D S2", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, d1_loc - zGap * d1_atr,
                bar_index + pocExt, d1_loc - (zGap + zWidth) * d1_atr,
                border_color=color.new(color.teal, 30),
                bgcolor=color.new(color.teal, 80), border_width=1,
                text="1D B1", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, d1_loc - (zGap + zWidth) * d1_atr,
                bar_index + pocExt, d1_loc - (zGap + 2 * zWidth) * d1_atr,
                border_color=color.new(color.teal, 15),
                bgcolor=color.new(color.teal, 68), border_width=1,
                text="1D B2", text_color=color.white, text_size=size.tiny)

    // ──────────────────────────────────────────────────────────────
    //  D) Weekly LOC/POC Zones   (Purple = Sell | Blue = Buy)
    // ──────────────────────────────────────────────────────────────
    if showWkLOC
        box.new(bar_index-1, wk_loc + (zGap + zWidth) * wk_atr,
                bar_index + pocExt, wk_loc + zGap * wk_atr,
                border_color=color.new(color.purple, 30),
                bgcolor=color.new(color.purple, 80), border_width=1,
                text="Wk S1", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, wk_loc + (zGap + 2 * zWidth) * wk_atr,
                bar_index + pocExt, wk_loc + (zGap + zWidth) * wk_atr,
                border_color=color.new(color.purple, 15),
                bgcolor=color.new(color.purple, 68), border_width=1,
                text="Wk S2", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, wk_loc - zGap * wk_atr,
                bar_index + pocExt, wk_loc - (zGap + zWidth) * wk_atr,
                border_color=color.new(color.blue, 30),
                bgcolor=color.new(color.blue, 80), border_width=1,
                text="Wk B1", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, wk_loc - (zGap + zWidth) * wk_atr,
                bar_index + pocExt, wk_loc - (zGap + 2 * zWidth) * wk_atr,
                border_color=color.new(color.blue, 15),
                bgcolor=color.new(color.blue, 68), border_width=1,
                text="Wk B2", text_color=color.white, text_size=size.tiny)

    // ──────────────────────────────────────────────────────────────
    //  E) Monthly LOC/POC Zones   (Orange = Sell | Yellow = Buy)
    // ──────────────────────────────────────────────────────────────
    if showMoLOC
        box.new(bar_index-1, mo_loc + (zGap + zWidth) * mo_atr,
                bar_index + pocExt, mo_loc + zGap * mo_atr,
                border_color=color.new(color.orange, 30),
                bgcolor=color.new(color.orange, 80), border_width=1,
                text="Mo S1", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, mo_loc + (zGap + 2 * zWidth) * mo_atr,
                bar_index + pocExt, mo_loc + (zGap + zWidth) * mo_atr,
                border_color=color.new(color.orange, 15),
                bgcolor=color.new(color.orange, 68), border_width=1,
                text="Mo S2", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, mo_loc - zGap * mo_atr,
                bar_index + pocExt, mo_loc - (zGap + zWidth) * mo_atr,
                border_color=color.new(color.yellow, 30),
                bgcolor=color.new(color.yellow, 80), border_width=1,
                text="Mo B1", text_color=color.white, text_size=size.tiny)
        box.new(bar_index-1, mo_loc - (zGap + zWidth) * mo_atr,
                bar_index + pocExt, mo_loc - (zGap + 2 * zWidth) * mo_atr,
                border_color=color.new(color.yellow, 15),
                bgcolor=color.new(color.yellow, 68), border_width=1,
                text="Mo B2", text_color=color.white, text_size=size.tiny)

// ═══════════════════════════════════════════════════════════════════
//  INFO TABLE (top-right)
// ═══════════════════════════════════════════════════════════════════
var table tbl = table.new(position.top_right, 2, 9,
     bgcolor=color.new(color.black, 60), border_color=color.gray, border_width=1)

if barstate.islast
    bias   = strongBull ? "BULLISH ▲" : strongBear ? "BEARISH ▼" : "MIXED ↔"
    biasCl = strongBull ? color.lime  : strongBear ? color.red   : color.orange
    phase  = isAccum    ? "ACCUM"     : isExpand   ? "EXPAND"    : "NEUTRAL"
    inst   = instBuy    ? "I-BUY  ■" : instSell   ? "I-SELL ■"  : "—"
    instCl = instBuy    ? color.new(#2962FF, 0) :
             instSell   ? color.new(#7B0000, 0) : color.gray

    table.cell(tbl, 0, 0, "GTI v2",    text_color=color.white,  bgcolor=color.new(#1565C0, 30), text_size=size.small)
    table.cell(tbl, 1, 0, syminfo.ticker, text_color=color.yellow, bgcolor=color.new(#1565C0, 30), text_size=size.small)
    table.cell(tbl, 0, 1, "Bias",      text_color=color.gray,   text_size=size.tiny)
    table.cell(tbl, 1, 1, bias,        text_color=biasCl,       text_size=size.small)
    table.cell(tbl, 0, 2, "Phase",     text_color=color.gray,   text_size=size.tiny)
    table.cell(tbl, 1, 2, phase,       text_color=color.yellow, text_size=size.small)
    table.cell(tbl, 0, 3, "Inst",      text_color=color.gray,   text_size=size.tiny)
    table.cell(tbl, 1, 3, inst,        text_color=instCl,       text_size=size.small)
    table.cell(tbl, 0, 4, "4H LOC",    text_color=color.new(#2962FF, 0), text_size=size.tiny)
    table.cell(tbl, 1, 4, str.tostring(math.round(h4_loc, 2)),
               text_color=color.new(#2962FF, 0), text_size=size.small)
    table.cell(tbl, 0, 5, "1D  LOC",   text_color=color.new(#F9A825, 0), text_size=size.tiny)
    table.cell(tbl, 1, 5, str.tostring(math.round(d1_loc, 2)),
               text_color=color.new(#F9A825, 0), text_size=size.small)
    table.cell(tbl, 0, 6, "Wk  LOC",   text_color=color.new(#9C27B0, 0), text_size=size.tiny)
    table.cell(tbl, 1, 6, str.tostring(math.round(wk_loc, 2)),
               text_color=color.new(#9C27B0, 0), text_size=size.small)
    table.cell(tbl, 0, 7, "Mo  LOC",   text_color=color.new(#FF6D00, 0), text_size=size.tiny)
    table.cell(tbl, 1, 7, str.tostring(math.round(mo_loc, 2)),
               text_color=color.new(#FF6D00, 0), text_size=size.small)
    table.cell(tbl, 0, 8, "ATR(14)",   text_color=color.gray,   text_size=size.tiny)
    table.cell(tbl, 1, 8, str.tostring(math.round(atr, 2)),
               text_color=color.white, text_size=size.small)

// ═══════════════════════════════════════════════════════════════════
//  COLOR LEGEND (bottom-left)
// ═══════════════════════════════════════════════════════════════════
var table leg = table.new(position.bottom_left, 2, 10,
     bgcolor=color.new(color.black, 70), border_color=color.gray, border_width=1)

if barstate.islast
    table.cell(leg, 0, 0, "LEGEND",        text_color=color.white,             bgcolor=color.new(color.black,40), text_size=size.tiny)
    table.cell(leg, 1, 0, "",              bgcolor=color.new(color.black,40))
    table.cell(leg, 0, 1, "■ I-BUY",       text_color=color.new(#001F5B,0),    text_size=size.tiny)
    table.cell(leg, 1, 1, "Dark Navy",     text_color=color.new(#001F5B,0),    text_size=size.tiny)
    table.cell(leg, 0, 2, "■ I-SELL",      text_color=color.new(#7B0000,0),    text_size=size.tiny)
    table.cell(leg, 1, 2, "Dark Red",      text_color=color.new(#7B0000,0),    text_size=size.tiny)
    table.cell(leg, 0, 3, "─ 4H LOC",      text_color=color.new(#2962FF,0),    text_size=size.tiny)
    table.cell(leg, 1, 3, "Blue",          text_color=color.new(#2962FF,0),    text_size=size.tiny)
    table.cell(leg, 0, 4, "─ 1D LOC",      text_color=color.new(#F9A825,0),    text_size=size.tiny)
    table.cell(leg, 1, 4, "Yellow",        text_color=color.new(#F9A825,0),    text_size=size.tiny)
    table.cell(leg, 0, 5, "─ Wk LOC",      text_color=color.new(#9C27B0,0),    text_size=size.tiny)
    table.cell(leg, 1, 5, "Purple",        text_color=color.new(#9C27B0,0),    text_size=size.tiny)
    table.cell(leg, 0, 6, "─ Mo LOC",      text_color=color.new(#FF6D00,0),    text_size=size.tiny)
    table.cell(leg, 1, 6, "Orange",        text_color=color.new(#FF6D00,0),    text_size=size.tiny)
    table.cell(leg, 0, 7, "□ S1/S2",       text_color=color.red,               text_size=size.tiny)
    table.cell(leg, 1, 7, "Sell Zones",    text_color=color.red,               text_size=size.tiny)
    table.cell(leg, 0, 8, "□ B1/B2",       text_color=color.lime,              text_size=size.tiny)
    table.cell(leg, 1, 8, "Buy Zones",     text_color=color.lime,              text_size=size.tiny)
    table.cell(leg, 0, 9, "▲▼ Demand/Sup", text_color=color.gray,              text_size=size.tiny)
    table.cell(leg, 1, 9, "Order Blocks",  text_color=color.gray,              text_size=size.tiny)
````
