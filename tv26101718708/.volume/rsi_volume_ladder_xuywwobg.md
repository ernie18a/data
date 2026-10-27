# RSI Volume Ladder

- url: https://www.tradingview.com/script/XuywwObg-RSI-Volume-Ladder/
- type: strategy
- pine_id: PUB;d487c5468f7547aa8addb2516580580e
- version: 1.0

## Description

A long-only pyramiding strategy that scales into corrections using RSI oversold conditions confirmed by above-average volume. Each subsequent entry requires a meaningful price drop from the previous fill, with an asymmetric exit structure: Take Profit anchored to the average entry, Stop Loss anchored to the lowest fill. Built for traders who want to systematically dollar-cost into pullbacks within an uptrend, with clearly defined risk per pyramid stack.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ORIGINALITY — WHAT MAKES THIS DIFFERENT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Five specific mechanics that, in this combination, distinguish this script from other averaging-down systems published on TradingView:

[b]- ASYMMETRIC EXIT ANCHORING[/b]
Take Profit is calculated from the average entry price of the pyramid — so winners run from the averaged-down cost basis. Stop Loss is calculated from the LOWEST entry price among all open positions — so the absolute worst-case loss is bounded by your deepest fill, not your average. This asymmetry is the key to making pyramiding viable: averaging works for you on the upside without inflating downside risk.

[b]- PRICE-DROP GATE FOR EACH PYRAMID LEG[/b]
Every subsequent entry requires both a fresh RSI + volume signal AND a configurable minimum price drop from the previous fill (default 1.5%). This prevents stacking three positions within a tight range during a slow grind down — pyramiding only triggers on meaningful pullbacks, forcing real averaging instead of cosmetic averaging.

[b]- ASYMMETRIC COOLDOWN ON EXIT[/b]
After a Stop Loss, the strategy waits N bars (default 3) before allowing new entries — blocks the "catch the falling knife" pattern where RSI stays oversold for many bars during a cascade. After a Take Profit, cooldown is configurable separately and defaults to 0, because a successful exit signals continued mean-reversion behavior worth participating in.

[b]- ENTRY-TIMING SAFETY[/b]
Exit detection runs at the top of the bar evaluation, BEFORE the entry check. This means a Stop Loss hit on a bar cannot trigger a new entry on the same bar — even if RSI is still deeply oversold and volume is elevated. The cooldown counter is set before the entry logic ever sees the bar, eliminating a subtle but realistic execution problem in pyramiding systems.

[b]- VISUAL EXIT CLASSIFICATION[/b]
When the position closes, the script automatically classifies the exit as TP or SL by measuring distance from actual fill price to each pre-set level, and renders a fuchsia or red cross at the exit price. No look-ahead, no estimation — the classification uses the closed trade's recorded exit price.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
CREDITS & FOUNDATIONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]This script builds on established methodologies with original Pine v5 implementation of every layer:[/b]

- RSI — Wilder, 1978 (standard implementation via ta.rsi)
- Volume confirmation — classical technical analysis
- Pyramiding / scaling-in — standard portfolio management technique (Tharp, Elder)
- Dollar-cost averaging principles — long-standing investment methodology

[i]ALL CODE in this script was written from scratch. No code has been copied from other public or private scripts. The five mechanics listed under ORIGINALITY above are original combinations and implementations.[/i]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW THE STRATEGY WORKS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]ENTRY CONDITIONS (all must be true):[/b]
- RSI below the configurable oversold threshold (default 30)
- Volume above SMA × configurable multiplier (default 1.5× of SMA20)
- For pyramiding: price must be at least X% below the last fill (default 1.5%)
- Cooldown not active from the previous exit
- Open positions count below the pyramiding cap (default 3)

[b]PYRAMID BUILDING:[/b]
Up to 3 long positions can be opened. Each new entry independently re-checks all conditions — the RSI + volume signal must reappear, AND the price drop gate must be satisfied. Position size per entry is fixed (default 5% of equity), so a full three-position stack uses approximately 15% of equity.

[b]EXIT LOGIC:[/b]
Both legs run as an OCO (one-cancels-other) bracket:

Take Profit = average entry × (1 + tpPercent / 100), default +4%
Stop Loss = lowest entry × (1 − slPercent / 100), default −3%
All positions close together when either level is hit. The TP/SL levels update on every bar as the pyramid grows — average shifts on each new fill, lowest fill anchors deeper if a new low is hit.

COOLDOWN MECHANISM:
On exit, the strategy records the bar index and exit type. While [pine]bar_index − lastExitBar ≤ requiredCooldown[/pine], new entries are blocked. The required cooldown differs by exit type (default 3 bars after SL, 0 bars after TP), reflecting that an SL exit often happens during continuing weakness, while a TP exit signals healthy mean reversion.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]VISUALIZATION[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ENTRY ARROWS — blue triangles below each fill, labeled Long_1 / Long_2 / Long_3 with the order price
AVERAGE ENTRY LINE — blue, updates as the pyramid grows (staircase pattern)
TAKE PROFIT LINE — fuchsia, updates with the average
STOP LOSS LINE — red, anchored to the lowest fill (steps down only if a deeper entry occurs)
EXIT CROSS — fuchsia at TP hit, red at SL hit, placed at the actual exit price
The line style is [pine]plot.style_linebr[/pine], which connects within an open position and breaks cleanly between positions — making each pyramid cycle visually self-contained on the chart.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]HOW TO USE IT[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This is a complete entry + exit strategy, but it is NOT a turn-it-on-and-walk-away system. Use it as a framework to test and adapt to your specific instrument:

- Load on a liquid asset with mean-reverting behavior in an uptrend. The strategy was developed on crypto majors (BTC, ETH) and major equity indices.
Start with the default parameters and run the Strategy Tester on at least 6 months of history. 
- Pay attention to:
• Net Profit and Max Drawdown ratio
• Average loss vs. average win
• Whether losing streaks cluster during specific market regimes
Tune to your instrument's volatility:
• Higher-volatility assets (alt-coins, small caps) → increase dropPercent (2-3%), increase slPercent (4-6%)
• Lower-volatility assets (BTC, indices) → decrease dropPercent (1-1.5%), tighter slPercent (2-3%)
• Higher timeframes (1h, 4h) → wider TP/SL to match bar range
- Consider adding an external trend filter for your live use. The strategy will pyramid into any oversold reading regardless of higher-timeframe context. Adding an EMA200 filter (only enter if price > EMA200) materially changes the risk profile on instruments prone to extended downtrends.
- Treat the strategy output as a structured framework for your dip-buying process, not as a guaranteed system. Combine with your own market analysis, position sizing, and broader risk management.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]INPUTS WORTH KNOWING[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RSI Length (default 14) and Oversold threshold (default 30) — standard RSI configuration. Lower threshold = fewer, deeper-oversold entries.
Volume SMA length (default 20) and Multiplier (default 1.5×) — volume confirmation strength. Higher multiplier = only enter on standout volume spikes, fewer entries.
Min drop between pyramid entries (default 1.5%) — prevents tight clustering. Higher = waits for deeper pullbacks before adding.
Max pyramid positions (default 3) — caps the stack. Note: pyramiding=3 is also set in the strategy() header.
Take Profit % from average (default 4%) — anchored to running average entry price.
Stop Loss % from lowest fill (default 3%) — anchored to the deepest entry, shared across all open positions.
Cooldown after SL (default 3 bars) — blocks the falling-knife pattern after a stop-out.
Cooldown after TP (default 0 bars) — re-enter immediately after a successful exit.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]REALISTIC EXPECTATIONS[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pyramiding into corrections is a well-known approach with well-known limitations. The strategy works best when:

The underlying asset has a structural uptrend
Volatility produces regular pullbacks of meaningful depth
The market is not in a sustained bear regime

What this strategy provides:

A disciplined framework for scaling into pullbacks instead of single-shot entries
Asymmetric exit anchoring that lets winners run from the averaged cost basis
Built-in protection against catching the falling knife via cooldown
Transparent visualization of each pyramid leg, exit, and risk level

What it does NOT provide:

Protection from prolonged bear trends (averaging down into a structural decline is the dominant failure mode of this entire strategy family)
A guaranteed profitable system
A signal generator for assets that don't mean-revert
A replacement for your own market analysis, position sizing, or higher-timeframe context

Treat the output as ONE structured input in your trading process. The biggest risk to your account using a pyramiding strategy is mis-applying it to a downtrending asset — always confirm regime alignment before going live.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[b]TECHNICAL NOTES & DISCLOSURES[/b]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[b]NO REPAINT[/b]. Uses process_orders_on_close=true — all orders execute on confirmed bar close. No request.security() calls, no lookahead_on, no barmerge.lookahead_on.
[b]REALISTIC EXECUTION[/b]. Default commission 0.05% per trade (typical crypto exchange taker fee). Position sizing in % of equity, not fixed contracts. Initial capital 10,000.
[b]DATA USED[/b]: only standard Pine inputs — open, high, low, close, volume. Indicators: RSI, SMA of volume. No external feeds, no security() calls, no synthetic data.
[b]PERFORMANCE[/b]: max_labels_count=500. Pyramiding capped at 3. No unbounded growth of internal objects.
[b]ASSETS[/b]: developed on crypto majors and tested across 5m, 15m timeframes. Works on equities and forex but parameters were tuned on crypto and may need adjustment for assets with different intraday behavior.
[b]EDUCATIONAL AND ANALYTICAL TOOL[/b]. Intended for traders who understand pyramiding mechanics and the inherent risk of averaging-down strategies, and who want a structured framework to test on their own instruments.
[b]OPEN SOURCE[/b]. Read the code, learn from it, fork it. Feedback and bug reports welcome in the comments.

Check my profile for other published scripts.

## Source Code

````pine
// @version=5
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wielkieef

strategy("RSI Volume Ladder", overlay=true, 
     pyramiding=3, 
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity, 
     default_qty_value=2,
     commission_type=strategy.commission.percent,
     commission_value=0.05,
     process_orders_on_close=true,
     max_labels_count=500)

// === PARAMETRY WEJŚCIA ===
rsiLength     = input.int(14,  "RSI długość",                group="RSI")
rsiOversold   = input.int(30,  "RSI wyprzedanie",            group="RSI")

volLength     = input.int(20,  "Volume SMA długość",         group="Wolumen")
volMultiplier = input.float(1.5,"Mnożnik wysokiego wolumenu",step=0.1, minval=1.0, group="Wolumen")

// === PIRAMIDOWANIE ===
dropPercent   = input.float(1.5,"Min spadek od ostatniego wejścia (%)", step=0.1, group="Piramidowanie")
maxPositions  = input.int(3,    "Max liczba pozycji", minval=1, maxval=3, group="Piramidowanie")

// === EXIT ===
tpPercent     = input.float(4.0,"Take Profit od śr. ceny (%)",          step=0.1, group="Exit")
slPercent     = input.float(3.0,"Stop Loss od najniższej pozycji (%)",  step=0.1, group="Exit")

// === COOLDOWN ===
cooldownAfterSL = input.int(3, "Cooldown po SL (świece)", minval=0, group="Cooldown")
cooldownAfterTP = input.int(0, "Cooldown po TP (świece)", minval=0, group="Cooldown")

// === KOLORY ===
entryArrowColor = input.color(color.blue,    "Strzałka wejścia", group="Kolory")
entryLineColor  = input.color(color.blue,    "Linia wejścia",    group="Kolory")
tpLineColor     = input.color(color.fuchsia, "Linia TP",         group="Kolory")
slLineColor     = input.color(color.red,     "Linia SL",         group="Kolory")
tpHitColor      = input.color(color.fuchsia, "Krzyżyk TP",       group="Kolory")
slHitColor      = input.color(color.red,     "Krzyżyk SL",       group="Kolory")
lineWidth       = 2
hitLineWidth    = 8

// === WSKAŹNIKI ===
rsiValue    = ta.rsi(close, rsiLength)
volSMA      = ta.sma(volume, volLength)
highVolume  = volume > volSMA * volMultiplier
oversold    = rsiValue < rsiOversold
entrySignal = oversold and highVolume

// === ŚLEDZENIE POZYCJI ===
var float lowestEntryPrice = na
var float lastEntryPrice   = na
var int   openEntries      = 0
var float tpPrice          = na
var float slPrice          = na
var int   lastExitBar      = -9999
var bool  lastExitWasSL    = false

// === WYKRYWANIE EXIT (NA POCZĄTKU BARU – przed canEnter) ===
exitedThisBar = strategy.closedtrades > 0 and strategy.closedtrades.exit_bar_index(strategy.closedtrades - 1) == bar_index and strategy.position_size == 0

exitHitPrice = float(na)
tpHit = false
slHit = false

if exitedThisBar
    realExitPrice = strategy.closedtrades.exit_price(strategy.closedtrades - 1)
    prevTP = tpPrice[1]
    prevSL = slPrice[1]
    if not na(prevTP) and not na(prevSL)
        if math.abs(realExitPrice - prevTP) <= math.abs(realExitPrice - prevSL)
            tpHit := true
        else
            slHit := true
    exitHitPrice  := realExitPrice
    lastExitBar   := bar_index
    lastExitWasSL := slHit
    tpPrice       := na
    slPrice       := na
    // Reset pozycji od razu, żeby canEnter widział czysty stan
    lowestEntryPrice := na
    lastEntryPrice   := na
    openEntries      := 0

// === COOLDOWN CHECK ===
barsSinceExit    = bar_index - lastExitBar
requiredCooldown = lastExitWasSL ? cooldownAfterSL : cooldownAfterTP
cooldownActive   = barsSinceExit <= requiredCooldown

// === LOGIKA WEJŚCIA ===
priceDroppedEnough = na(lastEntryPrice) or close < lastEntryPrice * (1 - dropPercent / 100)
canEnter = openEntries < maxPositions and entrySignal and priceDroppedEnough and not cooldownActive

if canEnter
    strategy.entry("Long_" + str.tostring(openEntries + 1), strategy.long)
    lowestEntryPrice := na(lowestEntryPrice) ? close : math.min(lowestEntryPrice, close)
    lastEntryPrice   := close
    openEntries      += 1

// === AKTUALIZACJA TP/SL ===
if strategy.position_size > 0
    tpPrice := strategy.position_avg_price * (1 + tpPercent / 100)
    slPrice := lowestEntryPrice * (1 - slPercent / 100)
    strategy.exit("Exit", stop=slPrice, limit=tpPrice)

// === WIZUALIZACJA ===
// Strzałka wejścia — niebieska
plotshape(canEnter, "Wejście", shape.triangleup, location.belowbar, entryArrowColor, size=size.small, text="BUY", textcolor=entryArrowColor)

// Linie wejścia / TP / SL
plot(strategy.position_size > 0 ? strategy.position_avg_price : na, "Średnia cena (entry)", entryLineColor, lineWidth, plot.style_linebr)
plot(strategy.position_size > 0 ? tpPrice : na, "Take Profit", tpLineColor, lineWidth, plot.style_linebr)
plot(strategy.position_size > 0 ? slPrice : na, "Stop Loss",   slLineColor, lineWidth, plot.style_linebr)

// Krzyżyk w punkcie zamknięcia pozycji
plot(tpHit ? exitHitPrice : na, "Trafienie TP", color=tpHitColor, style=plot.style_cross, linewidth=hitLineWidth)
plot(slHit ? exitHitPrice : na, "Trafienie SL", color=slHitColor, style=plot.style_cross, linewidth=hitLineWidth)
````
