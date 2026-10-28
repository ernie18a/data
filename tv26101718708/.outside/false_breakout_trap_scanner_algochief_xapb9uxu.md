# False Breakout Trap Scanner [AlgoChief] 

- url: https://www.tradingview.com/script/xaPB9uXU-False-Breakout-Trap-Scanner-AlgoChief/
- type: indicator
- pine_id: PUB;80502439ec07414aa365f73ce4aedc28
- version: 1.0

## Description

🔵 Overview

In liquid markets, price frequently makes a deceptive move beyond a key structural level — a swing high or swing low — only to reverse sharply. These moves, commonly called liquidity sweeps or stop hunts, collect resting orders before the real directional move begins.

This open-source screener detects these traps automatically across multiple symbols and timeframes simultaneously. It combines three technical filters — structural breakout detection, price reclaim confirmation, and Fibonacci retracement entry zones — and fires a signal only when all three align.

⚡ Trap Classification

Trap-A — Aggressive Rejection Price breaks a structural level and fully reclaims it within the very next candle. This is the sharpest and most decisive form of false breakout, indicating strong absorption of liquidity.

Trap-B — Gradual Return Price reclaims the broken level over 2 to 5 candles. This slower return still confirms structural failure but with softer momentum. Both types offer valid entry opportunities — Trap-A simply carries more urgency.

🟠 Long Setup (Bull Trap Logic)

Price sweeps below a confirmed swing low, triggering sell-side stop losses
Price closes back above the swept level within 5 candles — the move is classified as a false breakdown
Price pulls back into the 0.618 to 1.0 Fibonacci retracement zone drawn from the recent swing high to the new sweep low
A long entry signal fires at this retracement
Stop loss is placed just below the 1.0 level (below the sweep low). Target is the previous structural high or a predefined risk-reward ratio such as 1:2 or 1:3.

🟣 Short Setup (Bear Trap Logic)

Price sweeps above a confirmed swing high, triggering buy-side stop losses
Price closes back below the swept level within 5 candles — the move is classified as a false breakout
Price pulls back into the 0.618 to 1.0 Fibonacci retracement zone drawn from the recent swing low to the new sweep high
A short entry signal fires at this retracement
Stop loss is placed just above the 1.0 level (above the sweep high). Target is the previous structural low or a predefined reward ratio.

📡 Screener Table

Monitors up to 10 user-defined symbol and timeframe pairs simultaneously. For each slot the table displays:

• Ticker and Exchange • Daily % change (color-coded green/red) • Timeframe • Trap Direction — ▲ Long or ▼ Short • Trap Speed — Trap-A or Trap-B • Entry Price at signal • Signal Age — how long ago the trap fired (e.g. 2h 15m ago)

Layout can be set to Basic (single column) or Compact (two columns side-by-side) to fit different screen setups.

🎨 Visual Features

• Amber-orange Fibonacci zones for long traps • Violet-purple Fibonacci zones for short traps • All historical zones remain visible on the chart — you can set the maximum number to display • Fibonacci level labels at 0.618, 0.786, and 1.000 with exact price printed on the zone • Triangle signal markers on the chart at each entry point • Fully customizable table position, size, and layout

⚙️ Settings Guide

Detection Settings → Pivot Lookback Period: Controls how sensitive swing high and low detection is. Lower values detect shorter-term pivots. Default is 10. → Fib Entry Window (Bars): How many candles after trap confirmation the Fibonacci zone remains active. Default is 10. → Pivot Scan Mode: All scans every detected pivot. Limited restricts scanning to the N most recent pivots only.

Visual Settings → Toggle zones, level labels, and signal markers independently → Max Historical Zones: How many past Fibonacci zones stay visible on the chart → Table on Chart: Toggle between overlay on chart or pinned to corner → Table Position, Size, and Layout: Full control over screener table appearance

Symbol Watchlist → 10 slots with independently configurable symbol and timeframe per slot → Works on any asset class — forex, crypto, commodities, indices, stocks

Alerts → Fires when all three conditions are met — sweep, reclaim, and Fibonacci entry → Frequency options: All, Once Per Bar, Once Per Bar Close

📌 How to Use

- Add the indicator to your chart on any symbol
- Open Settings → Symbol Watchlist and configure your 10 symbols and timeframes
- Watch the screener table for active signals (▲ or ▼ with entry price)
- When a row lights up, switch to that symbol's chart to see the Fibonacci zone
- Enter near the 0.618 to 0.786 area with stop beyond the 1.0 level
- Enable alerts to be notified automatically without watching the screen

⚠️ Disclaimer

This tool is for educational and analytical purposes only. It does not constitute financial advice. All trading decisions are the sole responsibility of the trader. Past performance of any pattern does not guarantee future results. Always apply proper risk management before entering any trade.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════
// False Breakout Trap Scanner [AlgoChief]
//
// Original work by AlgoChief — open-source under Mozilla Public
// License 2.0  https://mozilla.org/MPL/2.0/
//
// CONCEPT
// ───────
// Price often makes a deceptive move beyond a key structural level
// (swing high / swing low) only to snap back quickly.  These "liquidity
// traps" — engineered by larger participants to sweep stop-loss orders —
// frequently precede strong reversals.
//
// This tool identifies two trap speeds:
//   Trap A — Price reclaims the broken level within the VERY NEXT candle
//   Trap B — Price reclaims the broken level within 2-5 candles
//
// After reclaim, the script draws a Fibonacci retracement zone (0.618–1.0)
// and waits for price to pull back into it.  When it does, an entry signal
// fires and the screener table updates in real-time.
//
// SCREENER
// ────────
// Simultaneously monitors up to 10 user-defined symbol/timeframe pairs.
// Displays: Symbol · Exchange · Daily% · Timeframe · Trap Direction ·
//           Trap Speed · Entry Price · Signal Age
// ═══════════════════════════════════════════════════════════════════

//@version=6
indicator("False Breakout Trap Scanner [AlgoChief] ",
     overlay    = true,
     max_lines_count  = 500,
     max_boxes_count  = 500,
     max_labels_count = 500)

// ───────────────────────────────────────────────────────────────────
// ░░  GROUP LABELS
// ───────────────────────────────────────────────────────────────────
GRP_LOGIC   = "⚙️ Detection Settings"
GRP_DISPLAY = "🎨 Visual Settings"
GRP_SYM     = "📡 Symbol Watchlist"
GRP_ALERT   = "🔔 Alert Settings"

// ───────────────────────────────────────────────────────────────────
// ░░  DETECTION SETTINGS
// ───────────────────────────────────────────────────────────────────
i_swingLen      = input.int   (10,    "Pivot Lookback Period",          minval=2,  maxval=50,  group=GRP_LOGIC)
i_fibWindow     = input.int   (10,    "Fib Entry Window (Bars)",        minval=1,  maxval=50,  group=GRP_LOGIC,
     tooltip="Max bars after trap confirmation that Fibonacci zone stays active")
i_lookbackMode  = input.string("All", "Pivot Scan Mode",                options=["All","Limited"], group=GRP_LOGIC,
     tooltip="All = scan every pivot | Limited = scan only N most-recent pivots")
i_lookbackMax   = input.int   (3,     "Max Pivots to Scan",             minval=1,  maxval=20,  group=GRP_LOGIC,
     tooltip="Active only when Pivot Scan Mode = Limited")
i_confirmCandle = input.bool  (true,  "Candle Reversal Confirmation",   group=GRP_LOGIC,
     tooltip="Prevents falling knives! Long requires green bullish candle with lower wick rejection; Short requires red bearish candle.")
i_cooldownBars  = input.int   (8,     "Cooldown Bars Between Signals",  minval=1,  maxval=30,  group=GRP_LOGIC,
     tooltip="Prevents messy overlapping zones and signal spam during choppy consolidation")
i_minAtrMult    = input.float (1.0,   "Min Swing Size (ATR Multiple)",  minval=0.0, step=0.2,  group=GRP_LOGIC,
     tooltip="Filters out tiny noisy micro-swings. Swings must be at least N * ATR high.")
i_useEmaTrend   = input.bool  (false, "Trend Filter (200 EMA)",         group=GRP_LOGIC,
     tooltip="Optional: Only take Longs above 200 EMA and Shorts below 200 EMA to avoid counter-trend losses")

// ───────────────────────────────────────────────────────────────────
// ░░  VISUAL SETTINGS
// ───────────────────────────────────────────────────────────────────
i_showZones    = input.bool  (true,  "Show Fibonacci Entry Zones",       group=GRP_DISPLAY)
i_showLevels   = input.bool  (true,  "Show Fib Level Labels on Zones",   group=GRP_DISPLAY)
i_showSignals  = input.bool  (true,  "Show Signal Markers on Chart",     group=GRP_DISPLAY)
i_maxZones     = input.int   (10,   "Max Historical Zones to Display",   minval=1, maxval=50, group=GRP_DISPLAY,
     tooltip="How many past Fibonacci zones to keep visible on the chart")
i_tableOnChart = input.bool  (true,  "Table: Overlay on Chart",          group=GRP_DISPLAY,
     tooltip="On = table appears on the chart | Off = table pinned to bottom-right")
i_tablePos     = input.string("Top Right", "Table Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center",
              "Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group=GRP_DISPLAY)
i_tableSize    = input.string("Small", "Table Size",
     options=["Auto","Tiny","Small","Normal","Large","Huge"], group=GRP_DISPLAY)
i_tableLayout  = input.string("Basic", "Table Layout",
     options=["Basic","Compact"], group=GRP_DISPLAY,
     tooltip="Basic = single column | Compact = two columns side-by-side")
i_numWatch     = input.int   (10, "Watchlist Size", minval=2, maxval=20, step=2, group=GRP_DISPLAY)

// ───────────────────────────────────────────────────────────────────
// ░░  SYMBOL WATCHLIST  (10 slots)
// ───────────────────────────────────────────────────────────────────
i_sym1  = input.symbol("OANDA:XAUUSD",     "Symbol 1 (Gold 15m)",    group=GRP_SYM)
i_tf1   = input.timeframe("15",            "TF 1",                   group=GRP_SYM)
i_sym2  = input.symbol("OANDA:XAUUSD",     "Symbol 2 (Gold 1H)",     group=GRP_SYM)
i_tf2   = input.timeframe("60",            "TF 2",                   group=GRP_SYM)
i_sym3  = input.symbol("FX:EURUSD",        "Symbol 3 (EURUSD 15m)",  group=GRP_SYM)
i_tf3   = input.timeframe("15",            "TF 3",                   group=GRP_SYM)
i_sym4  = input.symbol("FX:EURUSD",        "Symbol 4 (EURUSD 1H)",   group=GRP_SYM)
i_tf4   = input.timeframe("60",            "TF 4",                   group=GRP_SYM)
i_sym5  = input.symbol("FX:GBPUSD",        "Symbol 5 (GBPUSD 15m)",  group=GRP_SYM)
i_tf5   = input.timeframe("15",            "TF 5",                   group=GRP_SYM)
i_sym6  = input.symbol("FX:GBPUSD",        "Symbol 6 (GBPUSD 1H)",   group=GRP_SYM)
i_tf6   = input.timeframe("60",            "TF 6",                   group=GRP_SYM)
i_sym7  = input.symbol("BINANCE:BTCUSDT",  "Symbol 7 (BTC 1H)",      group=GRP_SYM)
i_tf7   = input.timeframe("60",            "TF 7",                   group=GRP_SYM)
i_sym8  = input.symbol("BINANCE:ETHUSDT",  "Symbol 8 (ETH 1H)",      group=GRP_SYM)
i_tf8   = input.timeframe("60",            "TF 8",                   group=GRP_SYM)
i_sym9  = input.symbol("CAPITALCOM:US100", "Symbol 9 (Nasdaq 15m)",  group=GRP_SYM)
i_tf9   = input.timeframe("15",            "TF 9",                   group=GRP_SYM)
i_sym10 = input.symbol("FX:USDJPY",        "Symbol 10 (USDJPY 15m)", group=GRP_SYM)
i_tf10  = input.timeframe("15",            "TF 10",                  group=GRP_SYM)

// ───────────────────────────────────────────────────────────────────
// ░░  ALERT SETTINGS
// ───────────────────────────────────────────────────────────────────
i_alertOn   = input.bool  (true, "Enable Alerts", group=GRP_ALERT)
i_alertFreq = input.string("Once Per Bar", "Alert Frequency",
     options=["All","Once Per Bar","Once Per Bar Close"], group=GRP_ALERT)

// ───────────────────────────────────────────────────────────────────
// ░░  COLOUR PALETTE  — AlgoChief theme
//     Bull = amber-orange  |  Bear = electric violet
//     Neutral = slate grey
// ───────────────────────────────────────────────────────────────────
C_BULL_BRIGHT  = #FF8C00    // amber-orange for bull signals
C_BEAR_BRIGHT  = #8B00FF    // electric violet for bear signals
C_BULL_ZONE1   = color.new(#FF8C00, 82)   // 0.0–0.618 fib (lightest)
C_BULL_ZONE2   = color.new(#FFB347, 70)   // 0.618–0.786 fib (medium)
C_BULL_ZONE3   = color.new(#FF4500, 55)   // 0.786–1.0  fib (darkest)
C_BEAR_ZONE1   = color.new(#9B59B6, 82)
C_BEAR_ZONE2   = color.new(#7B2FBE, 70)
C_BEAR_ZONE3   = color.new(#4A0080, 55)
C_TBL_HEADER   = color.new(#0A1628, 0)    // deep navy
C_TBL_SUBHDR   = color.new(#0D2137, 0)
C_TBL_BULL_ROW = color.new(#0D1F0D, 0)
C_TBL_BEAR_ROW = color.new(#1A0A28, 0)
C_TBL_NONE_ROW = color.new(#0A1118, 0)
C_TEXT         = color.new(#D4D4D4, 0)
C_AMBER        = color.new(#FFB300, 0)
C_LIME         = color.new(#76FF03, 0)
C_CRIMSON      = color.new(#FF1744, 0)
C_BORDER       = color.new(#263238, 0)

// ───────────────────────────────────────────────────────────────────
// ░░  HELPER FUNCTIONS
// ───────────────────────────────────────────────────────────────────

// Resolve table position string → built-in position constant
resolvePos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

// Resolve table size string → built-in size constant
resolveSize(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>         size.auto

// Extract exchange prefix from "EXCHANGE:TICKER" format
exchOf(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 0) : "—"

// Extract ticker from "EXCHANGE:TICKER" format
tickerOf(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

// Format a bar-count into a human-readable elapsed time string
elapsedTime(bars, tf) =>
    secs  = timeframe.in_seconds(tf)
    mins  = math.round(math.abs(bars) * secs / 60)
    out   = ""
    if mins < 60
        out := str.tostring(mins) + "m"
    else if mins < 1440
        h   = math.floor(mins / 60)
        m   = mins - h * 60
        out := str.tostring(h) + "h " + str.tostring(m) + "m"
    else
        d   = math.floor(mins / 1440)
        h   = math.floor((mins - d * 1440) / 60)
        out := str.tostring(d) + "d " + str.tostring(h) + "h"
    out + " ago"

// Convert raw TF string to readable label
tfReadable(tf) =>
    switch tf
        "1"   => "1m"
        "3"   => "3m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "45"  => "45m"
        "60"  => "1H"
        "120" => "2H"
        "240" => "4H"
        "360" => "6H"
        "720" => "12H"
        "D"   => "1D"
        "W"   => "1W"
        "M"   => "1M"
        =>       tf

tfFull(tf) =>
    switch tf
        "1"   => "1 Minute"
        "3"   => "3 Minutes"
        "5"   => "5 Minutes"
        "15"  => "15 Minutes"
        "30"  => "30 Minutes"
        "45"  => "45 Minutes"
        "60"  => "1 Hour"
        "120" => "2 Hours"
        "240" => "4 Hours"
        "360" => "6 Hours"
        "720" => "12 Hours"
        "D"   => "Daily"
        "W"   => "Weekly"
        "M"   => "Monthly"
        =>       tf + " Min"

// ───────────────────────────────────────────────────────────────────
// ░░  CORE TRAP DETECTION
//
//  Returns [direction, trapSpeed, entryPrice, ageBars]
//    direction  :  1 = Long Trap | -1 = Short Trap | 0 = None
//    trapSpeed  :  1 = Trap-A (1 bar)  | 2 = Trap-B (2-5 bars)
//    entryPrice :  close at signal bar
//    ageBars    :  bars elapsed since last valid signal
// ───────────────────────────────────────────────────────────────────
detectTrap(pivotLen, fibWindow, maxPivots, scanMode, confirmCandle, cooldownBars, minAtrMult, useEmaTrend) =>
    atrVal = ta.atr(14)
    ema200 = ta.ema(close, 200)

    // ── Pivot detection ──────────────────────────────────────────
    pivHigh = ta.pivothigh(high, pivotLen, pivotLen)
    pivLow  = ta.pivotlow (low,  pivotLen, pivotLen)

    var float anchorHigh = na   // most recent confirmed swing high
    var float anchorLow  = na   // most recent confirmed swing low
    var int   pivHCount  = 0
    var int   pivLCount  = 0

    // Filter pivots by ATR height so tiny micro-spikes don't create false anchors
    if not na(pivHigh)
        recentLow = ta.lowest(low, pivotLen * 2)
        if (pivHigh - recentLow) >= (minAtrMult * atrVal)
            if scanMode == "All" or pivHCount < maxPivots
                anchorHigh := pivHigh
                pivHCount  += 1

    if not na(pivLow)
        recentHigh = ta.highest(high, pivotLen * 2)
        if (recentHigh - pivLow) >= (minAtrMult * atrVal)
            if scanMode == "All" or pivLCount < maxPivots
                anchorLow  := pivLow
                pivLCount  += 1

    // ── Trap tracking state ───────────────────────────────────────
    var int   sweepLowBar     = na    // bar when price swept below anchorLow
    var float sweepLowLevel   = na    // the structural low that was swept
    var float sweepLowAnchorH = na    // paired swing high (for Fib calculation)

    var int   sweepHighBar    = na
    var float sweepHighLevel  = na
    var float sweepHighAnchorL = na

    // ── Signal state ──────────────────────────────────────────────
    var int   lastSigBar  = na
    var int   sigDir      = 0
    var int   sigSpeed    = 0
    var float sigEntry    = na

    // ─── LONG TRAP: bear sweep below swing low → price reclaims → Fib pullback ───
    if not na(anchorLow) and not na(anchorHigh)
        if low < anchorLow and close[1] >= anchorLow
            sweepLowBar     := bar_index
            sweepLowLevel   := anchorLow
            sweepLowAnchorH := anchorHigh

    // Active sweep & reclaim tracking
    if not na(sweepLowBar) and not na(sweepLowLevel)
        barsSinceSweep = bar_index - sweepLowBar
        priceReclaimed = close > sweepLowLevel

        // Invalidation 1: Exceeded time window or fell way below sweep level
        if barsSinceSweep > (fibWindow + 5) or close < (sweepLowLevel - 3.0 * atrVal)
            sweepLowBar := na

        if not na(sweepLowBar) and priceReclaimed and barsSinceSweep >= 1 and barsSinceSweep <= 5
            rng  = sweepLowAnchorH - sweepLowLevel
            f618 = sweepLowAnchorH - 0.618 * rng
            f100 = sweepLowLevel

            // Invalidation 2: If price closed back below 1.0 (sweep low) -> SL hit / setup dead!
            if close < f100
                sweepLowBar := na
            else
                // Entry filters:
                // 1. Price entered 0.618-1.0 retracement
                inZone = low <= f618 and close >= f100

                // 2. Candle confirmation: MUST close green (bullish) with lower rejection wick
                candleOk = not confirmCandle or (close > open and (close - low) >= (high - low) * 0.25)

                // 3. Trend filter: 200 EMA
                trendOk = not useEmaTrend or (close > ema200)

                // 4. Cooldown: prevent cluster spam
                cooldownOk = na(lastSigBar) or (bar_index - lastSigBar >= cooldownBars)

                if inZone and candleOk and trendOk and cooldownOk and barsSinceSweep <= fibWindow
                    if na(lastSigBar) or bar_index > lastSigBar
                        sigDir      := 1
                        sigSpeed    := barsSinceSweep == 1 ? 1 : 2
                        sigEntry    := close
                        lastSigBar  := bar_index
                        sweepLowBar := na   // reset to avoid duplicate triggers

    // ─── SHORT TRAP: bull sweep above swing high → price falls back → Fib pullback ───
    if not na(anchorHigh) and not na(anchorLow)
        if high > anchorHigh and close[1] <= anchorHigh
            sweepHighBar      := bar_index
            sweepHighLevel    := anchorHigh
            sweepHighAnchorL  := anchorLow

    if not na(sweepHighBar) and not na(sweepHighLevel)
        barsSinceSweep = bar_index - sweepHighBar
        priceReclaimed = close < sweepHighLevel

        // Invalidation 1: Exceeded time window or blew way past high
        if barsSinceSweep > (fibWindow + 5) or close > (sweepHighLevel + 3.0 * atrVal)
            sweepHighBar := na

        if not na(sweepHighBar) and priceReclaimed and barsSinceSweep >= 1 and barsSinceSweep <= 5
            rng  = sweepHighLevel - sweepHighAnchorL
            f618 = sweepHighAnchorL + 0.618 * rng
            f100 = sweepHighLevel

            // Invalidation 2: If price closed back above 1.0 -> SL hit / setup dead!
            if close > f100
                sweepHighBar := na
            else
                inZone = high >= f618 and close <= f100

                // Candle confirmation: MUST close red (bearish) with upper rejection wick
                candleOk = not confirmCandle or (close < open and (high - close) >= (high - low) * 0.25)

                trendOk = not useEmaTrend or (close < ema200)
                cooldownOk = na(lastSigBar) or (bar_index - lastSigBar >= cooldownBars)

                if inZone and candleOk and trendOk and cooldownOk and barsSinceSweep <= fibWindow
                    if na(lastSigBar) or bar_index > lastSigBar
                        sigDir       := -1
                        sigSpeed     := barsSinceSweep == 1 ? 1 : 2
                        sigEntry     := close
                        lastSigBar   := bar_index
                        sweepHighBar := na

    ageBars = na(lastSigBar) ? na : bar_index - lastSigBar
    [sigDir, sigSpeed, sigEntry, ageBars]

// ───────────────────────────────────────────────────────────────────
// ░░  ON-CHART DETECTION  (current symbol / timeframe)
// ───────────────────────────────────────────────────────────────────
maxPiv = i_lookbackMode == "All" ? 999 : i_lookbackMax

[cDir, cSpeed, cEntry, cAge] = detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend)

// ─── Track swing anchors for Fibonacci drawing ───────────────────
var float chartSwH = na
var float chartSwL = na
ph0 = ta.pivothigh(high, i_swingLen, i_swingLen)
pl0 = ta.pivotlow (low,  i_swingLen, i_swingLen)
if not na(ph0)
    chartSwH := ph0
if not na(pl0)
    chartSwL := pl0

// ─── Fibonacci zone drawing — ALL historical signals kept visible ─
// Uses box arrays so every past zone remains on the chart.
// Only the oldest zones are pruned when maxZones is exceeded.
var array<box>   bullZoneA = array.new<box>()
var array<box>   bullZoneB = array.new<box>()
var array<box>   bullZoneC = array.new<box>()
var array<box>   bearZoneA = array.new<box>()
var array<box>   bearZoneB = array.new<box>()
var array<box>   bearZoneC = array.new<box>()
var array<label> fibLabels = array.new<label>()

pruneBulk(arr, maxN) =>
    while array.size(arr) > maxN
        box.delete(array.shift(arr))

pruneLbls(arr, maxN) =>
    while array.size(arr) > maxN
        label.delete(array.shift(arr))

if i_showZones and cDir != 0 and cAge == 0 and not na(chartSwH) and not na(chartSwL)
    rng  = chartSwH - chartSwL
    endB = bar_index + i_fibWindow   // zone extends forward by fibWindow bars

    if cDir == 1
        // Long trap zones (price pulled from high toward swept low)
        f0   = chartSwH
        f618 = chartSwH - 0.618 * rng
        f786 = chartSwH - 0.786 * rng
        f100 = chartSwL

        b1 = box.new(bar_index, f0,   endB, f618, bgcolor=C_BULL_ZONE1, border_color=color.new(C_BULL_BRIGHT, 60), border_width=1)
        b2 = box.new(bar_index, f618, endB, f786, bgcolor=C_BULL_ZONE2, border_color=color.new(C_BULL_BRIGHT, 40), border_width=1)
        b3 = box.new(bar_index, f786, endB, f100, bgcolor=C_BULL_ZONE3, border_color=color.new(C_BULL_BRIGHT, 20), border_width=1)
        array.push(bullZoneA, b1)
        array.push(bullZoneB, b2)
        array.push(bullZoneC, b3)

        if i_showLevels
            l1 = label.new(endB, f618, "0.618 — " + str.tostring(f618, format.mintick),
                 style=label.style_label_left, color=color.new(C_BULL_BRIGHT, 80),
                 textcolor=color.new(C_BULL_BRIGHT, 0), size=size.tiny)
            l2 = label.new(endB, f786, "0.786 — " + str.tostring(f786, format.mintick),
                 style=label.style_label_left, color=color.new(C_BULL_BRIGHT, 80),
                 textcolor=color.new(C_BULL_BRIGHT, 0), size=size.tiny)
            l3 = label.new(endB, f100, "1.000 — " + str.tostring(f100, format.mintick),
                 style=label.style_label_left, color=color.new(C_BULL_BRIGHT, 80),
                 textcolor=color.new(C_BULL_BRIGHT, 0), size=size.tiny)
            array.push(fibLabels, l1)
            array.push(fibLabels, l2)
            array.push(fibLabels, l3)

    if cDir == -1
        // Short trap zones
        f0   = chartSwL
        f618 = chartSwL + 0.618 * rng
        f786 = chartSwL + 0.786 * rng
        f100 = chartSwH

        b1 = box.new(bar_index, f0,   endB, f618, bgcolor=C_BEAR_ZONE1, border_color=color.new(C_BEAR_BRIGHT, 60), border_width=1)
        b2 = box.new(bar_index, f618, endB, f786, bgcolor=C_BEAR_ZONE2, border_color=color.new(C_BEAR_BRIGHT, 40), border_width=1)
        b3 = box.new(bar_index, f786, endB, f100, bgcolor=C_BEAR_ZONE3, border_color=color.new(C_BEAR_BRIGHT, 20), border_width=1)
        array.push(bearZoneA, b1)
        array.push(bearZoneB, b2)
        array.push(bearZoneC, b3)

        if i_showLevels
            l1 = label.new(endB, f618, "0.618 — " + str.tostring(f618, format.mintick),
                 style=label.style_label_left, color=color.new(C_BEAR_BRIGHT, 80),
                 textcolor=color.new(C_BEAR_BRIGHT, 0), size=size.tiny)
            l2 = label.new(endB, f786, "0.786 — " + str.tostring(f786, format.mintick),
                 style=label.style_label_left, color=color.new(C_BEAR_BRIGHT, 80),
                 textcolor=color.new(C_BEAR_BRIGHT, 0), size=size.tiny)
            l3 = label.new(endB, f100, "1.000 — " + str.tostring(f100, format.mintick),
                 style=label.style_label_left, color=color.new(C_BEAR_BRIGHT, 80),
                 textcolor=color.new(C_BEAR_BRIGHT, 0), size=size.tiny)
            array.push(fibLabels, l1)
            array.push(fibLabels, l2)
            array.push(fibLabels, l3)

    // Prune old zones beyond user-defined limit
    pruneBulk(bullZoneA, i_maxZones)
    pruneBulk(bullZoneB, i_maxZones)
    pruneBulk(bullZoneC, i_maxZones)
    pruneBulk(bearZoneA, i_maxZones)
    pruneBulk(bearZoneB, i_maxZones)
    pruneBulk(bearZoneC, i_maxZones)
    pruneLbls(fibLabels, i_maxZones * 3)

// ─── Signal markers ───────────────────────────────────────────────
var label sigMark = na
if i_showSignals and cDir != 0 and cAge == 0
    mTxt   = cDir == 1 ? "▲  LONG TRAP\nTrap-" + (cSpeed == 1 ? "A" : "B") : "▼  SHORT TRAP\nTrap-" + (cSpeed == 1 ? "A" : "B")
    mColor = cDir == 1 ? color.new(C_BULL_BRIGHT, 0) : color.new(C_BEAR_BRIGHT, 0)
    mStyle = cDir == 1 ? label.style_label_up : label.style_label_down
    mY     = cDir == 1 ? low * 0.9998 : high * 1.0002
    label.delete(sigMark)
    sigMark := label.new(bar_index, mY, mTxt,
         style=mStyle, color=mColor, textcolor=color.white,
         size=size.small, textalign=text.align_center)

plotshape(i_showSignals and cDir ==  1 and cAge == 0,
     "Bull Trap Entry", shape.triangleup,   location.belowbar,
     color.new(C_BULL_BRIGHT, 0), size=size.small)
plotshape(i_showSignals and cDir == -1 and cAge == 0,
     "Bear Trap Entry", shape.triangledown, location.abovebar,
     color.new(C_BEAR_BRIGHT, 0), size=size.small)

// ───────────────────────────────────────────────────────────────────
// ░░  MULTI-SYMBOL SECURITY REQUESTS
//     One request.security call per symbol — returns [dir, speed, entry, age]
// ───────────────────────────────────────────────────────────────────
[d1,  sp1,  e1,  a1]  = request.security(i_sym1,  i_tf1,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d2,  sp2,  e2,  a2]  = request.security(i_sym2,  i_tf2,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d3,  sp3,  e3,  a3]  = request.security(i_sym3,  i_tf3,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d4,  sp4,  e4,  a4]  = request.security(i_sym4,  i_tf4,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d5,  sp5,  e5,  a5]  = request.security(i_sym5,  i_tf5,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d6,  sp6,  e6,  a6]  = request.security(i_sym6,  i_tf6,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d7,  sp7,  e7,  a7]  = request.security(i_sym7,  i_tf7,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d8,  sp8,  e8,  a8]  = request.security(i_sym8,  i_tf8,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d9,  sp9,  e9,  a9]  = request.security(i_sym9,  i_tf9,  detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)
[d10, sp10, e10, a10] = request.security(i_sym10, i_tf10, detectTrap(i_swingLen, i_fibWindow, maxPiv, i_lookbackMode, i_confirmCandle, i_cooldownBars, i_minAtrMult, i_useEmaTrend), lookahead=barmerge.lookahead_off)

// Daily % change
dc1  = request.security(i_sym1,  "D", (close - close[1]) / close[1] * 100)
dc2  = request.security(i_sym2,  "D", (close - close[1]) / close[1] * 100)
dc3  = request.security(i_sym3,  "D", (close - close[1]) / close[1] * 100)
dc4  = request.security(i_sym4,  "D", (close - close[1]) / close[1] * 100)
dc5  = request.security(i_sym5,  "D", (close - close[1]) / close[1] * 100)
dc6  = request.security(i_sym6,  "D", (close - close[1]) / close[1] * 100)
dc7  = request.security(i_sym7,  "D", (close - close[1]) / close[1] * 100)
dc8  = request.security(i_sym8,  "D", (close - close[1]) / close[1] * 100)
dc9  = request.security(i_sym9,  "D", (close - close[1]) / close[1] * 100)
dc10 = request.security(i_sym10, "D", (close - close[1]) / close[1] * 100)

// Pack into arrays
w_dirs   = array.from(d1,  d2,  d3,  d4,  d5,  d6,  d7,  d8,  d9,  d10)
w_speeds = array.from(sp1, sp2, sp3, sp4, sp5, sp6, sp7, sp8, sp9, sp10)
w_entries= array.from(e1,  e2,  e3,  e4,  e5,  e6,  e7,  e8,  e9,  e10)
w_ages   = array.from(a1,  a2,  a3,  a4,  a5,  a6,  a7,  a8,  a9,  a10)
w_dcs    = array.from(dc1, dc2, dc3, dc4, dc5, dc6, dc7, dc8, dc9, dc10)
w_syms   = array.from(i_sym1,  i_sym2,  i_sym3,  i_sym4,  i_sym5,
                      i_sym6,  i_sym7,  i_sym8,  i_sym9,  i_sym10)
w_tfs    = array.from(i_tf1,  i_tf2,  i_tf3,  i_tf4,  i_tf5,
                      i_tf6,  i_tf7,  i_tf8,  i_tf9,  i_tf10)

// ───────────────────────────────────────────────────────────────────
// ░░  SCREENER TABLE
//
//  Columns (9): # | Ticker | Exchange | Daily% | TF | Dir | Speed | Entry | Age
//  Compact mode pairs two symbols per row (18 columns total)
// ───────────────────────────────────────────────────────────────────
N_COLS = 9
numWatch    = math.min(i_numWatch, 10)
isCompact   = i_tableLayout == "Compact"
totalCols   = isCompact ? N_COLS * 2 : N_COLS
totalRows   = (isCompact ? math.ceil(numWatch / 2) : numWatch) + 2   // title + subhdr + data

tblAnchor = i_tableOnChart ? resolvePos(i_tablePos) : position.bottom_right
tblSz     = resolveSize(i_tableSize)

var table watchTbl = table.new(tblAnchor, totalCols, totalRows,
     border_color=C_BORDER, border_width=1,
     frame_color=C_TBL_HEADER, frame_width=2)

colHeaders = array.from("#", "Ticker", "Exchange", "Daily%", "TF", "Dir", "Speed", "Entry", "Age")

if barstate.islast
    // ── Title row ─────────────────────────────────────────────────
    table.cell(watchTbl, 0, 0, "⚡  [AlgoChief]  False Breakout Trap Scanner  ⚡",
         text_color=C_AMBER, bgcolor=C_TBL_HEADER,
         text_size=tblSz, text_halign=text.align_center)
    table.merge_cells(watchTbl, 0, 0, totalCols - 1, 0)

    // ── Column header row ─────────────────────────────────────────
    for c = 0 to N_COLS - 1
        table.cell(watchTbl, c, 1, array.get(colHeaders, c),
             text_color=C_AMBER, bgcolor=C_TBL_SUBHDR,
             text_size=tblSz, text_halign=text.align_center)
    if isCompact
        for c = 0 to N_COLS - 1
            table.cell(watchTbl, N_COLS + c, 1, array.get(colHeaders, c),
                 text_color=C_AMBER, bgcolor=C_TBL_SUBHDR,
                 text_size=tblSz, text_halign=text.align_center)

    // ── Data rows ─────────────────────────────────────────────────
    for i = 0 to numWatch - 1
        dir   = array.get(w_dirs,    i)
        spd   = array.get(w_speeds,  i)
        ent   = array.get(w_entries, i)
        age   = array.get(w_ages,    i)
        dc    = array.get(w_dcs,     i)
        sym   = array.get(w_syms,    i)
        tf    = array.get(w_tfs,     i)

        ticker  = tickerOf(sym)
        exch    = exchOf(sym)
        tfShort = tfReadable(tf)

        dcTxt   = not na(dc)  ? (dc >= 0 ? "+" : "") + str.tostring(dc, "#.##") + "%" : "—"
        dcClr   = not na(dc) and dc >= 0 ? C_LIME : C_CRIMSON

        dirTxt  = dir ==  1 ? "▲" : dir == -1 ? "▼" : "·"
        dirClr  = dir ==  1 ? C_LIME : dir == -1 ? C_CRIMSON : color.gray

        spdTxt  = dir != 0 ? "Trap-" + (spd == 1 ? "A" : "B") : "—"
        spdClr  = dir != 0 ? C_TEXT : color.gray

        entTxt  = not na(ent) and dir != 0 ? str.tostring(ent, "#.#####") : "—"
        ageTxt  = not na(age) and dir != 0 ? elapsedTime(age, tf) : "—"
        ageClr  = not na(age) and age <= 1 ? C_LIME : C_AMBER

        rowBg   = dir ==  1 ? C_TBL_BULL_ROW : dir == -1 ? C_TBL_BEAR_ROW : C_TBL_NONE_ROW

        colOff = isCompact ? (i % 2) * N_COLS : 0
        rowIdx = isCompact ? math.floor(i / 2) + 2 : i + 2

        table.cell(watchTbl, colOff + 0, rowIdx, str.tostring(i + 1), text_color=C_TEXT,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_center)
        table.cell(watchTbl, colOff + 1, rowIdx, ticker,               text_color=C_TEXT,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_left)
        table.cell(watchTbl, colOff + 2, rowIdx, exch,                 text_color=C_TEXT,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_center)
        table.cell(watchTbl, colOff + 3, rowIdx, dcTxt,                text_color=dcClr,   bgcolor=rowBg, text_size=tblSz, text_halign=text.align_right)
        table.cell(watchTbl, colOff + 4, rowIdx, tfShort,              text_color=C_TEXT,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_center)
        table.cell(watchTbl, colOff + 5, rowIdx, dirTxt,               text_color=dirClr,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_center)
        table.cell(watchTbl, colOff + 6, rowIdx, spdTxt,               text_color=spdClr,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_center)
        table.cell(watchTbl, colOff + 7, rowIdx, entTxt,               text_color=C_TEXT,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_right)
        table.cell(watchTbl, colOff + 8, rowIdx, ageTxt,               text_color=ageClr,  bgcolor=rowBg, text_size=tblSz, text_halign=text.align_right)

// ───────────────────────────────────────────────────────────────────
// ░░  ALERTS
// ───────────────────────────────────────────────────────────────────
aFreq = i_alertFreq == "All" ? alert.freq_all : i_alertFreq == "Once Per Bar Close" ? alert.freq_once_per_bar_close : alert.freq_once_per_bar

if i_alertOn and cAge == 0
    tfStr  = tfFull(timeframe.period)
    ticker = syminfo.ticker
    if cDir == 1
        alert("🟠 Bull Trap detected on " + ticker + " (" + tfStr + ")  |  Trap-" + (cSpeed == 1 ? "A" : "B") + "  |  Entry: " + str.tostring(cEntry, format.mintick), aFreq)
    if cDir == -1
        alert("🟣 Bear Trap detected on " + ticker + " (" + tfStr + ")  |  Trap-" + (cSpeed == 1 ? "A" : "B") + "  |  Entry: " + str.tostring(cEntry, format.mintick), aFreq)
````
