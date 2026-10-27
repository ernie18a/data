# MINICRORE V2.0

- url: https://www.tradingview.com/script/eiN0D01A-MINICRORE-V2-0/
- type: indicator
- pine_id: PUB;852b6da551954ebe889da29e37294348
- version: 2.0

## Description

================================================================================
       COMPLETE HOW-TO-USE GUIDE
                    ATP Pro v2  |  Pine Script v6
================================================================================

  ZONES: 4 Levels  |  SIGNALS: Buy & Sell  |  ALERTS: 4 Types  |  MTF: 1H 4H D W

================================================================================
  SECTION 1 — OVERVIEW & INSTALLATION
================================================================================

WHAT IS THIS INDICATOR?
------------------------
(ATP Pro v2) is a professional-grade TradingView indicator
that replicates the . It identifies high-probability supply
and demand zones across multiple levels, detects trade traps, and provides
multi-timeframe trend analysis — all in one Pine Script v6 script.

HOW TO INSTALL ON TRADINGVIEW (8 Steps)
-----------------------------------------
  1. Open TradingView.com and load any futures chart (e.g. M2K1! Russell Micro)
  2. Click Pine Script Editor at the bottom of the screen
  3. Click New → Blank Script — delete all existing code
  4. Open the file ATP_Pro_v2_FINAL.pine and copy ALL the code
  5. Paste the code into the Pine Script Editor
  6. Click Save and name it: Ghost Trade Pro Clone
  7. Click Add to Chart — the indicator appears immediately
  8. Right-click the indicator name → Settings to customize

================================================================================
  SECTION 2 — UNDERSTANDING THE 4 ZONES
================================================================================

The indicator draws 4 distinct zone types matching exactly:

  ┌─────────────┬───────────────┬──────────────┬──────────────────────────────┐
  │ Zone Label  │ Color         │ Direction    │ What It Means                │
  ├─────────────┼───────────────┼──────────────┼──────────────────────────────┤
  │ GHST_TRP1   │ Salmon / Red  │ Supply (Sell)│ Primary swing high resistance│
  │ GHST_TRP2   │ Dark Red      │ Supply (Sell)│ Tighter secondary supply zone│
  │ GHST_LVT    │ Green         │ Demand (Buy) │ Primary swing low support    │
  │ GHST_BE     │ Teal / Cyan   │ Demand (Buy) │ Break-even precise entry zone│
  └─────────────┴───────────────┴──────────────┴──────────────────────────────┘

TRP1 — Primary Supply Zone (Red/Salmon)
  What it is:  Most recent 20-bar swing high. Price rejected here before.
  What to do:  When price returns → SELL. Wait for bearish candle + volume
               spike inside the zone before entering short.

TRP2 — Secondary Supply Zone (Dark Red)
  What it is:  Tighter inner band inside TRP1. Confirmed by 40-bar swing high.
               Stronger signal than TRP1 alone.
  What to do:  If price stalls inside TRP2, higher-confidence short entry.
               Tighter stop loss possible.

GHST_LVT — Primary Demand Zone (Green)
  What it is:  Most recent 20-bar swing low. Price bounced from here before.
               Buyers are likely to defend it again.
  What to do:  When price returns → BUY. Wait for bullish candle + volume
               spike inside the zone before entering long.

GHST_BE — Break-Even Zone (Teal/Cyan)
  What it is:  Tightest inner zone inside LVT. Confirmed by 40-bar swing low.
               Most precise bounce level.
  What to do:  Ideal for tight stop entries. Highest-confidence long entry
               with minimal risk when price bounces from BE specifically.

================================================================================
  SECTION 3 — DOT LINES, CHANNEL & MOVING AVERAGES
================================================================================

DOTTED CIRCLE LINES
--------------------
Horizontal dotted lines with circle markers (●) span the entire chart.
These represent key price levels extending into the future.

  GREEN dotted  →  Supply swing high  →  Upper resistance, price rejects here
  RED dotted    →  Demand swing low   →  Lower support, price bounces here
  ORANGE dotted →  Midpoint level     →  50% between supply/demand, pivot point

  ● Circle markers appear every 10 bars along each line as visual anchors.

REGRESSION CHANNEL LINES (the diagonal blue lines)
----------------------------------------------------
Three diagonal lines form a price channel using linear regression:

  Upper Line   (Blue)        →  Regression of highs  →  Upper channel boundary
  Middle Line  (Light Blue)  →  Regression of close  →  Trend direction midline
  Lower Line   (Blue)        →  Regression of lows   →  Lower channel boundary

  HOW TO USE:
  • Price bouncing off lower channel  =  Buy opportunity
  • Price hitting upper channel       =  Sell opportunity
  • Price breaking outside channel    =  Potential trend change

MOVING AVERAGES (3 Lines)
--------------------------
  ┌────────────┬──────┬────────┬────────┬──────────────────────────┐
  │ MA         │ Type │ Length │ Color  │ Purpose                  │
  ├────────────┼──────┼────────┼────────┼──────────────────────────┤
  │ Fast EMA   │ EMA  │ 9      │ Red    │ Immediate momentum       │
  │ Mid EMA    │ EMA  │ 21     │ Blue   │ Short-term trend filter  │
  │ Slow SMA   │ SMA  │ 50     │ Blue   │ Major trend confirmation │
  └────────────┴──────┴────────┴────────┴──────────────────────────┘

  GOLDEN RULE: Only BUY when Fast EMA > Mid EMA > Slow SMA (all up).
               Only SELL when Fast EMA < Mid EMA < Slow SMA (all down).

================================================================================
  SECTION 4 — TRADING SIGNALS
================================================================================

THE 4 SIGNAL TYPES
-------------------
  ┌─────────────┬────────────────────┬────────┬──────────────────────────────────┐
  │ Signal      │ Shape              │ Color  │ Trigger Condition                │
  ├─────────────┼────────────────────┼────────┼──────────────────────────────────┤
  │ BUY         │ Label Up Arrow     │ Green  │ Demand zone + volume + uptrend   │
  │ SELL        │ Label Down Arrow   │ Red    │ Supply zone + volume + downtrend │
  │ BULL TRAP   │ Triangle Down      │ Orange │ Higher high but closes bearish   │
  │ BEAR TRAP   │ Triangle Up        │ Purple │ Lower low but closes bullish     │
  └─────────────┴────────────────────┴────────┴──────────────────────────────────┘

THE PERFECT BUY SETUP — Step by Step
--------------------------------------
  [1]  Price drops into GREEN demand zone (GHST_LVT or GHST_BE)
  [2]  Volume bar spikes — volume > 1.5x the 20-bar average
  [3]  A bullish candle closes INSIDE the demand zone
  [4]  All 3 MAs aligned upward: Fast EMA > Mid EMA > Slow SMA
  [5]  BUY label appears on the chart
  [6]  ENTER LONG — stop below the zone, target at TRP1 supply above

THE PERFECT SELL SETUP — Step by Step
---------------------------------------
  [1]  Price rallies into RED supply zone (GHST_TRP1 or GHST_TRP2)
  [2]  Volume bar spikes — volume > 1.5x the 20-bar average
  [3]  A bearish candle closes INSIDE the supply zone
  [4]  All 3 MAs aligned downward: Fast EMA < Mid EMA < Slow SMA
  [5]  SELL label appears on the chart
  [6]  ENTER SHORT — stop above the zone, target at LVT demand below

================================================================================
  SECTION 5 — TRADE TRAPS
================================================================================

BULL TRAP  (Orange Triangle Down)
-----------------------------------
  What it is:  Price breaks above a previous high (looks like a breakout),
               then closes as a large bearish (red) candle.
               Bulls are trapped long at the highs.

  WHAT YOU SEE:                    YOUR ACTION:
  • Price spikes above resistance  • DO NOT buy the breakout
  • Large RED candle closes below  • Wait for next bearish candle + volume
  • Orange triangle appears        • Short the rejection at TRP1 zone
  • GHST_TRP1 label fires          • Target: LVT demand zone below

BEAR TRAP  (Purple Triangle Up)
---------------------------------
  What it is:  Price breaks below a previous low (looks like a breakdown),
               then closes as a large bullish (green) candle.
               Bears are trapped short at the lows.

  WHAT YOU SEE:                    YOUR ACTION:
  • Price spikes below support     • DO NOT short the breakdown
  • Large GREEN candle closes above• Wait for next bullish candle + volume
  • Purple triangle appears        • Long the bounce at LVT/BE demand zone
  • GHST_BE label fires            • Target: TRP1 supply zone above

================================================================================
  SECTION 6 — INFO PANEL & MTF TABLE
================================================================================

INFO PANEL (Top Right Corner)
-------------------------------
Real-time dashboard showing all key data in one place:

  ┌─────────────┬──────────────────────────────────────────────────┐
  │ Row         │ What It Shows                                    │
  ├─────────────┼──────────────────────────────────────────────────┤
  │ PRICE       │ Current market price                             │
  │ TREND       │ UPTREND ↑ / DOWNTREND ↓ / RANGING ↔             │
  │ ZONE        │ Which zone price is in (SUPPLY / DEMAND / NONE)  │
  │ VOLUME      │ SPIKE ↑ or NORMAL                                │
  │ SIGNAL      │ BUY ↑ / SELL ↓ / WAIT                           │
  │ TRAP        │ BULL TRAP / BEAR TRAP / NONE                     │
  │ ATR         │ Current volatility value (use for stop sizing)   │
  │ EMA 9/21    │ Fast and Mid EMA values                          │
  └─────────────┴──────────────────────────────────────────────────┘

  QUICK CHECK: Before any trade, panel should show:
  → TREND matches your direction
  → ZONE shows SUPPLY or DEMAND
  → VOLUME shows SPIKE
  → SIGNAL shows BUY or SELL
  → TRAP shows NONE

MTF TABLE (Middle Right — Multi-Timeframe)
-------------------------------------------
Shows trend bias across 4 timeframes simultaneously:

  ┌────────────┬──────────────────────────────┬──────────────────┐
  │ Timeframe  │ How Calculated               │ Arrow Up = Buy   │
  ├────────────┼──────────────────────────────┼──────────────────┤
  │ 1H         │ 50 EMA vs 200 EMA            │ 50 EMA > 200 EMA │
  │ 4H         │ Price vs 50 EMA              │ Close > 50 EMA   │
  │ D          │ Price vs 200 SMA             │ Close > 200 SMA  │
  │ W          │ Fast MA vs Slow MA           │ EMA9 > SMA50     │
  └────────────┴──────────────────────────────┴──────────────────┘

  BEST TRADES: All 4 arrows point same direction
  4x UP   ↑↑↑↑  =  Strongest buy environment
  4x DOWN ↓↓↓↓  =  Strongest sell environment
  MIXED   ↑↓↑↓  =  Avoid or reduce position size

================================================================================
  SECTION 7 — SETTINGS REFERENCE
================================================================================

ZONE SETTINGS
--------------
  TRP1 Supply Lookback  default: 20   M2K11 rec: 15-20  (bars to find swing high)
  TRP2 Supply Lookback  default: 40   M2K11 rec: 30-40  (broader confirmation)
  TRP1 Demand Lookback  default: 20   M2K11 rec: 15-20  (bars to find swing low)
  TRP2 Demand Lookback  default: 40   M2K11 rec: 30-40  (broader confirmation)
  Zone Width (ATR x)    default: 0.3  M2K11 rec: 0.25-0.40 (height of boxes)

VOLUME & ATR SETTINGS
----------------------
  Volume Avg Length     default: 20   Tight: 20    Volatile: 10-15 (faster)
  Spike Multiplier      default: 1.5  Tight: 1.3   Volatile: 2.0 (only big)
  ATR Length            default: 14   Tight: 14    Volatile: 10 (reactive)

MOVING AVERAGE SETTINGS
------------------------
  ┌──────────┬─────────┬──────────────┬────────────────┬──────────────┐
  │ MA       │ Default │ Scalping     │ Day Trading    │ Swing        │
  │          │         │ (1-5 min)    │ (15m-1H)       │ (4H-D)       │
  ├──────────┼─────────┼──────────────┼────────────────┼──────────────┤
  │ Fast EMA │ 9       │ 5            │ 9              │ 20           │
  │ Mid EMA  │ 21      │ 13           │ 21             │ 50           │
  │ Slow SMA │ 50      │ 34           │ 50             │ 200          │
  └──────────┴─────────┴──────────────┴────────────────┴──────────────┘

CHANNEL SETTINGS
-----------------
  Channel Length        default: 50   Lower = tighter channel, Higher = smoother

================================================================================
  SECTION 8 — RISK MANAGEMENT & POSITION SIZING
================================================================================

STOP LOSS RULES
----------------
  • Place stop OUTSIDE the zone — beyond the edge, not at it
  • BUY trades: stop below the bottom of GHST_BE (teal) zone
  • SELL trades: stop above the top of GHST_TRP1 (red) zone
  • Formula: stop = zone edge + 1x ATR value from panel

TAKE PROFIT RULES
------------------
  • Primary target: opposite zone (buy LVT → take profit at TRP1)
  • Scale out: take 50% at zone midline, let 50% run to full target
  • Secondary target: regression channel upper/lower line
  • Minimum Risk/Reward required: 1:1.5 (never accept less)

POSITION SIZING FOR M2K11 (Russell Micro)
------------------------------------------
  Note: 1 point on M2K11 = $5.  A 20-point stop = $100 risk per contract.

  ┌─────────────┬───────────────────┬─────────────┬─────────────┐
  │ Account     │ Risk Per Trade 2% │ Stop (pts)  │ Contracts   │
  ├─────────────┼───────────────────┼─────────────┼─────────────┤
  │ $5,000      │ $100              │ 20 pts      │ 1 contract  │
  │ $10,000     │ $200              │ 20 pts      │ 2 contracts │
  │ $25,000     │ $500              │ 20 pts      │ 5 contracts │
  │ $50,000     │ $1,000            │ 20 pts      │ 10 contracts│
  └─────────────┴───────────────────┴─────────────┴─────────────┘

  RULE: Never risk more than 2% of account on any single trade.

================================================================================
  SECTION 9 — PRE-TRADE CHECKLIST
================================================================================

Complete ALL items before EVERY trade. If fewer than 8/10 pass → DON'T trade.

  [ ] 1.  Price is at a clear supply or demand zone (TRP1, TRP2, LVT, or BE)
  [ ] 2.  Volume spike confirmed (Info panel shows SPIKE)
  [ ] 3.  Moving averages aligned with trade direction
  [ ] 4.  MTF table shows at least 3 of 4 arrows in trade direction
  [ ] 5.  No active Bull or Bear trap (panel shows NONE)
  [ ] 6.  Reversal candle present inside the zone
  [ ] 7.  Stop loss level identified (beyond zone + 1x ATR)
  [ ] 8.  Take profit target at opposite zone identified
  [ ] 9.  Risk/Reward is at least 1:1.5
  [ ] 10. Position size calculated (max 2% account risk)

================================================================================
  SECTION 10 — COMMON MISTAKES TO AVOID
================================================================================

  ┌────────────────────────────────┬──────────────────────────────────────────┐
  │ MISTAKE                        │ CORRECT APPROACH                         │
  ├────────────────────────────────┼──────────────────────────────────────────┤
  │ Trading without volume spike   │ Only enter when panel shows SPIKE        │
  │ Buying into a Bull Trap signal │ Orange triangle = skip or short instead  │
  │ Ignoring the MTF table         │ Need 3+ arrows in your direction         │
  │ Stop too tight (inside zone)   │ Place stop beyond zone + 1 ATR           │
  │ Taking partial zone signals    │ ALL 10 checklist items must pass         │
  │ Overtrading (forcing setups)   │ Max 2-3 high quality trades per day      │
  │ Moving stop to BE too fast     │ Move stop only after 1:1 achieved        │
  │ Trading against MTF trend      │ Trade only with the dominant trend       │
  └────────────────────────────────┴──────────────────────────────────────────┘

================================================================================
  QUICK REFERENCE — SIGNAL CHEAT SHEET
================================================================================

  AT GREEN DEMAND ZONE (LVT or BE):
    Need: Bullish candle + Volume spike + MAs up + 3+ MTF arrows up
    Do:   BUY  |  Stop: below zone  |  Target: TRP1 supply above

  AT RED SUPPLY ZONE (TRP1 or TRP2):
    Need: Bearish candle + Volume spike + MAs down + 3+ MTF arrows down
    Do:   SELL  |  Stop: above zone  |  Target: LVT demand below

  ORANGE TRIANGLE (Bull Trap):
    Do NOT buy the breakout → Look to short the rejection instead

  PURPLE TRIANGLE (Bear Trap):
    Do NOT short the breakdown → Look to buy the bounce instead

  MTF ALL UP ↑↑↑↑:    Strongest buy environment — trade full size
  MTF ALL DOWN ↓↓↓↓:  Strongest sell environment — trade full size
  MTF MIXED ↑↓:       Reduce size or skip entirely

================================================================================

                        THE GOLDEN RULE

          ZONE  +  VOLUME  +  TREND  =  HIGH PROBABILITY TRADE

     If any one of these three is missing — wait for a better setup.

================================================================================
  ATP Pro v2  |  Pine Script v6  |  TradingView
================================================================================

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © minicrore
//@version=6
indicator("MINICRORE V2.0", shorttitle="MINICRORE V2.0", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ============================================================================
// INPUTS
// ============================================================================

// Zone lookback periods
lbSupply1 = input.int(20, "TRP1 Supply Lookback",  group="Zone Settings", minval=5,  maxval=200)
lbSupply2 = input.int(40, "TRP2 Supply Lookback",  group="Zone Settings", minval=10, maxval=300)
lbDemand1 = input.int(20, "TRP1 Demand Lookback",  group="Zone Settings", minval=5,  maxval=200)
lbDemand2 = input.int(40, "TRP2 Demand Lookback",  group="Zone Settings", minval=10, maxval=300)
zoneBuffer = input.float(0.3, "Zone Width (ATR multiplier)", group="Zone Settings", minval=0.1, maxval=2.0, step=0.1)

// Channel / trend lines
chLen      = input.int(50, "Channel Length (bars)", group="Channel", minval=10, maxval=200)

// Moving averages
maFast     = input.int(9,   "Fast MA",  group="Moving Averages", minval=2,  maxval=100)
maMid      = input.int(21,  "Mid MA",   group="Moving Averages", minval=5,  maxval=200)
maSlow     = input.int(50,  "Slow MA",  group="Moving Averages", minval=10, maxval=500)

// Volume profile
volLen     = input.int(20, "Volume Avg Length", group="Volume", minval=5, maxval=100)
volMult    = input.float(1.5, "Spike Multiplier", group="Volume", minval=1.0, maxval=5.0, step=0.1)

// ATR
atrLen     = input.int(14, "ATR Length", group="ATR", minval=1, maxval=50)

// Display toggles
showZones  = input.bool(true, "Show Supply/Demand Zones",  group="Display")
showDots   = input.bool(true, "Show Circle Dot Lines",     group="Display")
showCh     = input.bool(true, "Show Channel Lines",        group="Display")
showMAs    = input.bool(true, "Show Moving Averages",      group="Display")
showVol    = input.bool(true, "Show Volume Highlight",     group="Display")
showLabels = input.bool(true, "Show Zone Labels",          group="Display")
showPanel  = input.bool(true, "Show Info Panel",           group="Display")

// Colors matching Ghost Trade Pro exactly
colSupply1 = input.color(color.new(color.red,   75), "Supply TRP1 Color", group="Colors")
colSupply2 = input.color(color.new(color.red,   85), "Supply TRP2 Color", group="Colors")
colDemand1 = input.color(color.new(color.green, 75), "Demand LVT Color",  group="Colors")
colDemand2 = input.color(color.new(color.teal,  70), "Demand BE Color",   group="Colors")
colDotLine = input.color(color.new(color.green, 40), "Dot Line Color",    group="Colors")
colCh1     = input.color(color.blue,                 "Channel Line 1",    group="Colors")
colCh2     = input.color(color.new(color.blue,  30), "Channel Line 2",    group="Colors")

// ============================================================================
// CORE CALCULATIONS
// ============================================================================

atrVal  = ta.atr(atrLen)
zoneH   = atrVal * zoneBuffer

// Moving averages
ma1 = ta.ema(close, maFast)
ma2 = ta.ema(close, maMid)
ma3 = ta.sma(close, maSlow)

// Volume
avgVol   = ta.sma(volume, volLen)
volSpike = volume > avgVol * volMult

// ── SUPPLY ZONES (TRP1 & TRP2) ──────────────────────────────────────────────
// TRP1: most recent swing high
swingHi1 = ta.highest(high, lbSupply1)
isNewHi1 = high == swingHi1 and high > high[1] and high > high[2]

// TRP2: broader swing high
swingHi2 = ta.highest(high, lbSupply2)
isNewHi2 = high == swingHi2 and high > ta.highest(high[1], lbSupply2 - 1)

// ── DEMAND ZONES (LVT / BE) ──────────────────────────────────────────────────
// LVT: most recent swing low
swingLo1 = ta.lowest(low, lbDemand1)
isNewLo1 = low == swingLo1 and low < low[1] and low < low[2]

// BE: broader swing low
swingLo2 = ta.lowest(low, lbDemand2)
isNewLo2 = low == swingLo2 and low < ta.lowest(low[1], lbDemand2 - 1)

// ── CHANNEL LINES ─────────────────────────────────────────────────────────────
// Upper channel = regression high, lower = regression low
chHigh = ta.highest(high, chLen)
chLow  = ta.lowest(low,  chLen)

// Linear regression for diagonal channel lines
regLine  = ta.linreg(close, chLen, 0)
regHigh  = ta.linreg(high,  chLen, 0)
regLow   = ta.linreg(low,   chLen, 0)

// ── TRAP SIGNALS ─────────────────────────────────────────────────────────────
bodySize     = math.abs(close - open)
zoneRange    = math.max(chHigh - chLow, atrVal)
bullTrap     = high > high[1] and close < open and bodySize > zoneRange * 0.4 and volume > avgVol
bearTrap     = low  < low[1]  and close > open and bodySize > zoneRange * 0.4 and volume > avgVol

// ── TREND ─────────────────────────────────────────────────────────────────────
uptrend   = ma1 > ma2 and ma2 > ma3
downtrend = ma1 < ma2 and ma2 < ma3

// ── SIGNALS ──────────────────────────────────────────────────────────────────
buySignal  = isNewLo1 and volSpike and close > open and uptrend
sellSignal = isNewHi1 and volSpike and close < open and downtrend
alertBuy   = buySignal  and not buySignal[1]
alertSell  = sellSignal and not sellSignal[1]

// ============================================================================
// PLOTS — all top-level, ternary for visibility toggle
// ============================================================================

// Moving averages (diagonal lines like the blue lines in the chart)
plot(showMAs ? ma1 : na, "Fast EMA",  color=color.new(color.red,  20), linewidth=1)
plot(showMAs ? ma2 : na, "Mid EMA",   color=color.new(color.blue, 20), linewidth=2)
plot(showMAs ? ma3 : na, "Slow SMA",  color=color.new(color.blue,  0), linewidth=2)

// Regression channel lines (the main diagonal blue lines)
plot(showCh ? regHigh : na, "Reg High", color=colCh1, linewidth=2)
plot(showCh ? regLine : na, "Reg Mid",  color=color.new(colCh2, 50), linewidth=1)
plot(showCh ? regLow  : na, "Reg Low",  color=colCh2, linewidth=2)

// Volume highlight
barcolor(showVol and volSpike ? color.new(color.blue, 50) : na, title="Vol Spike")

// Buy/Sell signals
plotshape(alertBuy,  "BUY",  style=shape.labelup,   location=location.belowbar, color=color.new(color.green,0), textcolor=color.white, text="BUY",  size=size.small)
plotshape(alertSell, "SELL", style=shape.labeldown,  location=location.abovebar, color=color.new(color.red,  0), textcolor=color.white, text="SELL", size=size.small)

// Trap signals  
plotshape(bullTrap, "Bull Trap", style=shape.triangledown, location=location.abovebar, color=color.orange, size=size.tiny)
plotshape(bearTrap, "Bear Trap", style=shape.triangleup,   location=location.belowbar, color=color.fuchsia, size=size.tiny)

// ============================================================================
// DYNAMIC OBJECTS
// ============================================================================

// ── SUPPLY ZONE BANDS (the wide red/salmon horizontal bands) ─────────────────
if showZones
    // TRP1 — wide salmon supply band at swing high
    if isNewHi1
        // Main supply box
        box.new(bar_index - lbSupply1, swingHi1 + zoneH,
                bar_index,             swingHi1 - zoneH,
                border_color=color.new(color.red, 80),
                bgcolor=colSupply1,
                xloc=xloc.bar_index,
                extend=extend.right)
        if showLabels
            label.new(bar_index, swingHi1 + zoneH * 2, "GHST_TRP1",
                      color=color.new(color.red, 40),
                      style=label.style_label_left,
                      textcolor=color.white, size=size.tiny)

    // TRP2 — inner tighter supply band
    if isNewHi2
        box.new(bar_index - lbSupply2, swingHi2 + zoneH * 0.4,
                bar_index,             swingHi2 - zoneH * 0.4,
                border_color=color.new(color.red, 60),
                bgcolor=colSupply2,
                xloc=xloc.bar_index,
                extend=extend.right)
        if showLabels
            label.new(bar_index, swingHi2 - zoneH * 1.5, "GHST_TRP2",
                      color=color.new(color.maroon, 40),
                      style=label.style_label_left,
                      textcolor=color.white, size=size.tiny)

    // ── DEMAND ZONE BANDS (green/teal horizontal bands) ─────────────────────
    // LVT — main demand zone
    if isNewLo1
        box.new(bar_index - lbDemand1, swingLo1 + zoneH,
                bar_index,             swingLo1 - zoneH,
                border_color=color.new(color.green, 80),
                bgcolor=colDemand1,
                xloc=xloc.bar_index,
                extend=extend.right)
        if showLabels
            label.new(bar_index, swingLo1 - zoneH * 2, "GHST_LVT",
                      color=color.new(color.green, 40),
                      style=label.style_label_left,
                      textcolor=color.white, size=size.tiny)

    // BE — break-even / tighter demand zone (cyan/teal band)
    if isNewLo2
        box.new(bar_index - lbDemand2, swingLo2 + zoneH * 0.4,
                bar_index,             swingLo2 - zoneH * 0.4,
                border_color=color.new(color.teal, 60),
                bgcolor=colDemand2,
                xloc=xloc.bar_index,
                extend=extend.right)
        if showLabels
            label.new(bar_index, swingLo2 + zoneH * 2, "GHST_BE",
                      color=color.new(color.teal, 30),
                      style=label.style_label_left,
                      textcolor=color.white, size=size.tiny)

// ── DOTTED CIRCLE LINES (the horizontal dotted lines with circles) ────────────
// These represent multi-timeframe levels extending across the chart
if showDots
    // Upper dot line — supply level (green dotted line across chart)
    if isNewHi1 or isNewHi2
        line.new(bar_index - 1, swingHi1, bar_index, swingHi1,
                 color=color.new(color.green, 30), width=1, style=line.style_dotted)

    // Lower dot line — demand level (red dotted line across chart)
    if isNewLo1 or isNewLo2
        line.new(bar_index - 1, swingLo1, bar_index, swingLo1,
                 color=color.new(color.red, 30), width=1, style=line.style_dotted)

    // Mid dot line — orange midlevel (the orange horizontal line)
    midLevel = (swingHi1 + swingLo1) / 2
    line.new(bar_index - 1, midLevel, bar_index, midLevel,
             color=color.new(color.orange, 20), width=2, style=line.style_dotted)

    // Circle markers on dot lines every N bars
    if bar_index % 10 == 0
        label.new(bar_index, swingHi1, "●",
                  color=color.new(color.green, 100),
                  textcolor=color.new(color.green, 30),
                  style=label.style_none, size=size.tiny)
        label.new(bar_index, swingLo1, "●",
                  color=color.new(color.red, 100),
                  textcolor=color.new(color.red, 30),
                  style=label.style_none, size=size.tiny)
        label.new(bar_index, midLevel, "●",
                  color=color.new(color.orange, 100),
                  textcolor=color.new(color.orange, 30),
                  style=label.style_none, size=size.tiny)

// ── TRAP LABELS ────────────────────────────────────────────────────────────────
if bullTrap
    label.new(bar_index, high + atrVal * 0.5, "GHST_TRP1",
              color=color.new(color.red, 40),
              style=label.style_label_down,
              textcolor=color.white, size=size.tiny)

if bearTrap
    label.new(bar_index, low - atrVal * 0.5, "GHST_BE",
              color=color.new(color.green, 40),
              style=label.style_label_up,
              textcolor=color.white, size=size.tiny)

// ============================================================================
// ALERTS
// ============================================================================

if alertBuy
    alert("BUY " + syminfo.tickerid + " — Demand LVT Zone + Volume", alert.freq_once_per_bar_close)
if alertSell
    alert("SELL " + syminfo.tickerid + " — Supply TRP1 Zone + Volume", alert.freq_once_per_bar_close)
if bullTrap
    alert("BULL TRAP " + syminfo.tickerid, alert.freq_once_per_bar_close)
if bearTrap
    alert("BEAR TRAP " + syminfo.tickerid, alert.freq_once_per_bar_close)

// ============================================================================
// INFO PANEL
// ============================================================================

if showPanel
    var table panel = table.new(position.top_right, 2, 8,
                                border_color=color.gray, border_width=1,
                                frame_color=color.gray,  frame_width=1)

    color bgA = color.rgb(20, 20, 40)
    color bgB = color.rgb(40, 40, 60)

    string trendTxt = uptrend ? "UPTREND ↑" : downtrend ? "DOWNTREND ↓" : "RANGING ↔"
    color  trendClr = uptrend ? color.green  : downtrend ? color.red     : color.yellow

    string zoneTxt  = isNewHi1 ? "SUPPLY TRP1" : isNewHi2 ? "SUPPLY TRP2" :
                      isNewLo1 ? "DEMAND LVT"  : isNewLo2 ? "DEMAND BE"   : "NO ZONE"
    color  zoneClr  = (isNewHi1 or isNewHi2) ? color.red :
                      (isNewLo1 or isNewLo2) ? color.green : color.gray

    string volTxt   = volSpike ? "SPIKE ↑" : "NORMAL"
    color  volClr   = volSpike ? color.blue : color.gray

    string trapTxt  = bullTrap ? "BULL TRAP ⚠" : bearTrap ? "BEAR TRAP ⚠" : "NONE"
    color  trapClr  = (bullTrap or bearTrap) ? color.orange : color.gray

    string sigTxt   = alertBuy ? "BUY ↑" : alertSell ? "SELL ↓" : "WAIT"
    color  sigClr   = alertBuy ? color.green : alertSell ? color.red : color.gray

    table.cell(panel, 0, 0, "PRICE",   text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 0, str.tostring(close, format.price), text_color=color.white, bgcolor=bgB)
    table.cell(panel, 0, 1, "TREND",   text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 1, trendTxt,  text_color=trendClr,    bgcolor=bgB)
    table.cell(panel, 0, 2, "ZONE",    text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 2, zoneTxt,   text_color=zoneClr,     bgcolor=bgB)
    table.cell(panel, 0, 3, "VOLUME",  text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 3, volTxt,    text_color=volClr,      bgcolor=bgB)
    table.cell(panel, 0, 4, "SIGNAL",  text_color=color.gray,  bgcolor=bgA)
    table.cell(panel, 1, 4, sigTxt,    text_color=sigClr,      bgcolor=bgB)
    table.cell(panel, 0, 5, "TRAP",    text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 5, trapTxt,   text_color=trapClr,     bgcolor=bgB)
    table.cell(panel, 0, 6, "ATR",     text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 6, str.tostring(math.round(atrVal, 2)), text_color=color.white, bgcolor=bgB)
    table.cell(panel, 0, 7, "EMA9/21", text_color=color.white, bgcolor=bgA)
    table.cell(panel, 1, 7, str.tostring(math.round(ma1, 1)) + " / " + str.tostring(math.round(ma2, 1)), text_color=color.white, bgcolor=bgB)
````
