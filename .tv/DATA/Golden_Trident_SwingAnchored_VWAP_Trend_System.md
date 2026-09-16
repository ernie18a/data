<!-- tradingview-pine-id: PUB;7048e9ec73e74f55b07069d07979524a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Golden Trident | Swing-Anchored VWAP Trend System

Source: https://www.tradingview.com/script/Eq4kPrrJ-Golden-Trident-Swing-Anchored-VWAP-Trend-System/

## Description

Golden Trident is a long-only, daily-timeframe trend-following strategy built specifically for XAUUSD (spot gold). Rather than relying on a lagging moving-average crossover or a single volatility band, it reads market structure directly — tracking swing highs and lows to determine trend direction — and pairs that with a volume-weighted anchor price that resets at every structural trend change. This gives the strategy a "fair value" reference line that adapts to each new trend leg rather than dragging a fixed-length average behind it.

The strategy is deliberately long-only. Gold has spent most of its liquid trading history in a secular uptrend, and countertrend short entries were found to meaningfully drag down both total return and risk-adjusted performance without adding diversification benefit — so the system simply steps to the sidelines when structure turns bearish, rather than fighting the dominant trend.

Position sizing is intentionally simple: a fixed percentage of equity per trade, compounding as equity grows. Risk management is handled by a single wide "catastrophe" stop rather than a tight trailing stop — the strategy is designed to exit on genuine trend reversal, not to be shaken out by normal daily noise.

How It Works

[*]Swing Structure (Trigger): The strategy tracks rolling swing highs and lows over a configurable lookback. When the most recent extreme is a new high, structure is bullish; when it's a new low, structure is bearish.
[*]Anchored VWAP (Trend Reference): Each time structure flips, the volume-weighted average price calculation resets and begins accumulating fresh from that point — producing a trend-relative fair-value line rather than a static average.
[*]EMA200 Filter (Structure Confirmation): Long entries additionally require price to be trading above the 200-period EMA, keeping trades aligned with the macro trend.
[*]Chop Filter (Volatility Gate): Entries are blocked when recent price range is too narrow relative to ATR — this avoids entering on structural "flips" that occur during sideways consolidation, where they're most likely to reverse immediately.
[*]Exit: Positions close purely on structural trend reversal. No trailing stop is used, since research during development found trailing exits tended to cap winning trades prematurely without meaningfully reducing losses.
[*]Backstop Stop: A wide ATR-based stop exists purely as disaster protection for extreme, unexpected moves — it is not intended to be part of normal trade management.

Features

[*]Swing-structure trend detection (not a lagging indicator crossover)
[*]Self-resetting anchored VWAP trend reference
[*]Optional EMA200 macro trend filter
[*]Optional ATR-based chop/consolidation filter
[*]Configurable backtest date range
[*]Trade outcome visualization (colored boxes showing each closed trade's entry-to-exit range)
[*]Live dashboard showing current structure, volatility state, position size, and open P/L
[*]Gold-themed visual design with gradient trend fill and directional bar coloring

Tips for Use

[*]Timeframe: Designed and tested on the daily chart. Shorter timeframes will likely need proportionally shorter swing/EMA/ATR lengths.
[*]Data quality matters: Backtest only over periods with clean, liquid, consistently-quoted price and volume data. Very long historical ranges on XAUUSD may include gold-standard-era pricing or unreliable volume that will distort results — the built-in date range inputs default to 2010 onward for this reason.
[*]Position sizing: The default equity percentage is aggressive. Test at a lower size first and scale up only after reviewing max drawdown and worst losing-streak length for your specific test window — position sizing should reflect your own risk tolerance, not just backtest profit factor.
[*]Shorting: Short entries exist as a toggle for experimentation, but are off by default based on backtest performance on gold's historical trend bias. Re-enabling changes the strategy's risk profile meaningfully.
[*]Not financial advice: This is a backtesting and educational tool. Past performance on historical data does not guarantee future results.

---

## Source Code

````pine
// ==========================================================================
//  Golden Trident | Swing-Anchored VWAP Trend System
//  Timeframe: Daily (XAUUSD)
//
//  A long-only trend-following strategy for gold. Trend direction is read
//  from swing structure (pivot highs/lows) rather than a lagging
//  crossover indicator, and paired with a volume-weighted anchor price
//  that resets at every structural trend change. An EMA200 filter and an
//  ATR-based chop filter keep entries aligned with the macro trend and
//  out of low-volatility consolidation. Exits are driven purely by
//  structure reversal; a wide ATR backstop exists only as disaster
//  protection, not as an active exit mechanism. Position sizing is a
//  fixed percentage of equity per trade.
// ==========================================================================

//@version=6
strategy("Golden Trident | Swing-Anchored VWAP Trend System", shorttitle="GT_XAU",
     overlay=true, initial_capital=10000, currency=currency.USD,
     default_qty_type=strategy.percent_of_equity, default_qty_value=20,
     commission_value=0.02, slippage=2,
     max_boxes_count=500, max_labels_count=500, max_lines_count=500,
     calc_on_every_tick=false)

// ==========================================================================
// 1. INPUTS
// ==========================================================================

// --- Backtest Range ---
grp_bt        = "Backtest Range"
startTestTime = input.time(timestamp("2010-01-01 00:00"), "Backtest Start", group=grp_bt,
                tooltip="Restricts testing to a period with clean, liquid, consistently-quoted price and volume data.")
endTestTime   = input.time(timestamp("2026-12-31 23:59"), "Backtest End", group=grp_bt)

// --- Swing Structure (Trigger) ---
grp_sw   = "Swing Structure (Trigger)"
swingLen = input.int(30, "Swing Period", minval=2, group=grp_sw,
           tooltip="Bars used to detect swing highs/lows. Larger values identify bigger, less frequent trend changes.")

// --- Direction ---
grp_dir    = "Direction"
allowShort = input.bool(false, "Allow Short Entries?", group=grp_dir,
             tooltip="Off by default. The strategy is designed as long-only, stepping to the sidelines on bearish structure rather than shorting against gold's dominant long-term trend.")

// --- EMA Filter ---
grp_ema = "EMA Filter (Structure)"
emaLen  = input.int(200, "EMA Length", minval=1, group=grp_ema)
useEMA  = input.bool(true, "Require price beyond EMA?", group=grp_ema)

// --- Chop Filter ---
grp_chop   = "Chop Filter"
useChop    = input.bool(true, "Block entries during low volatility?", group=grp_chop,
             tooltip="Blocks new entries when recent range is too narrow relative to ATR, filtering out structure flips that occur during sideways consolidation.")
atrChopLen = input.int(20, "ATR Length (Chop Filter)", minval=1, group=grp_chop)
rangeMult  = input.float(0.8, "Minimum Range x ATR", minval=0.1, step=0.1, group=grp_chop)

// --- Risk Management ---
grp_risk    = "Risk Management"
atrStopLen  = input.int(14, "ATR Length (Backstop)", minval=1, group=grp_risk)
atrStopMult = input.float(8.0, "Backstop Distance (x ATR)", minval=1.0, step=0.5, group=grp_risk,
             tooltip="A wide catastrophe-only stop. The strategy is designed to exit on structure reversal well before this level is reached.")

// --- Visuals ---
grp_vis   = "Visuals"
showTable = input.bool(true, "Show Dashboard", group=grp_vis)
showBoxes = input.bool(true, "Show Trade Outcome Boxes", group=grp_vis)
bullCol   = input.color(#f5b942, "Bullish Color", group=grp_vis)
bearCol   = input.color(#c0392b, "Bearish Color", group=grp_vis)

// ==========================================================================
// 2. BACKTEST RANGE CHECK
// ==========================================================================
inBacktestRange = (time >= startTestTime and time <= endTestTime)

// ==========================================================================
// 3. SWING STRUCTURE
// ==========================================================================
b = bar_index
var float ph  = na
var float pl  = na
var int   phL = 0
var int   plL = 0

ph  := ta.highestbars(high, swingLen) == 0 ? high : ph
pl  := ta.lowestbars(low, swingLen)  == 0 ? low  : pl
phL := ta.highestbars(high, swingLen) == 0 ? b   : phL
plL := ta.lowestbars(low, swingLen)  == 0 ? b    : plL

dir = phL > plL ? 1 : -1

// ==========================================================================
// 4. ANCHORED VWAP
// ==========================================================================
var float cumPV = 0.0
var float cumV  = 0.0

if dir != dir[1]
    cumPV := hlc3 * volume
    cumV  := volume
else
    cumPV := cumPV + hlc3 * volume
    cumV  := cumV + volume

anchoredVWAP = cumV > 0 ? cumPV / cumV : hlc3

emaTrend = ta.ema(close, emaLen)
atrStop  = ta.atr(atrStopLen)

atrChop = ta.atr(atrChopLen)
rangeOK = useChop ? (ta.highest(high, atrChopLen) - ta.lowest(low, atrChopLen)) > atrChop * rangeMult : true

// ==========================================================================
// 5. ENTRY LOGIC
// ==========================================================================
trendLongOK  = useEMA ? close > emaTrend : true
trendShortOK = useEMA ? close < emaTrend : true

longCond  = dir == 1              and trendLongOK  and rangeOK and inBacktestRange
shortCond = allowShort and dir == -1 and trendShortOK and rangeOK and inBacktestRange

longTrigger  = longCond  and not longCond[1]
shortTrigger = shortCond and not shortCond[1]

// ==========================================================================
// 6. EXECUTION
// ==========================================================================
var float backstopLong  = na
var float backstopShort = na

if longTrigger and strategy.position_size <= 0
    backstopLong := close - atrStop * atrStopMult
    strategy.entry("Long", strategy.long, comment="XAU BUY")

if shortTrigger and strategy.position_size >= 0
    backstopShort := close + atrStop * atrStopMult
    strategy.entry("Short", strategy.short, comment="XAU SELL")

if dir == -1 and strategy.position_size > 0
    strategy.close("Long", comment="Structure Flip Exit")

if dir == 1 and strategy.position_size < 0
    strategy.close("Short", comment="Structure Flip Exit")

if strategy.position_size > 0
    strategy.exit("Long Backstop", "Long", stop=backstopLong)

if strategy.position_size < 0
    strategy.exit("Short Backstop", "Short", stop=backstopShort)

// ==========================================================================
// 7. TRADE OUTCOME VISUALIZATION
// ==========================================================================
var float tradeEntryPrice = na
var int   tradeEntryBar   = na
var string tradeDir       = ""

if strategy.position_size != 0 and strategy.position_size[1] == 0
    tradeEntryPrice := close
    tradeEntryBar   := bar_index
    tradeDir        := strategy.position_size > 0 ? "long" : "short"

if strategy.position_size == 0 and strategy.position_size[1] != 0 and showBoxes
    exitPrice = close
    exitBar   = bar_index
    won    = tradeDir == "long" ? (exitPrice > tradeEntryPrice) : (exitPrice < tradeEntryPrice)
    boxCol = won ? bullCol : bearCol
    topP = math.max(tradeEntryPrice, exitPrice)
    botP = math.min(tradeEntryPrice, exitPrice)
    box.new(tradeEntryBar, topP, exitBar, botP, border_width=0, bgcolor=color.new(boxCol, 85))
    line.new(tradeEntryBar, topP, exitBar, topP, color=boxCol, width=1)
    line.new(tradeEntryBar, botP, exitBar, botP, color=boxCol, width=1)

// ==========================================================================
// 8. PLOTTING
// ==========================================================================
trendCol = dir == 1 ? bullCol : bearCol

pVWAP  = plot(anchoredVWAP, "Anchored VWAP", color=trendCol, linewidth=2)
pClose = plot(close, display=display.none)
fill(pVWAP, pClose, color=color.new(trendCol, 90), title="Trend Fill")

plot(useEMA ? emaTrend : na, "EMA200", color=color.new(color.gray, 20), linewidth=1)

if longTrigger and strategy.position_size[1] <= 0
    label.new(bar_index, low, "L", color=bullCol, textcolor=color.white, style=label.style_label_up, size=size.small)

if shortTrigger and strategy.position_size[1] >= 0
    label.new(bar_index, high, "S", color=bearCol, textcolor=color.white, style=label.style_label_down, size=size.small)

barcolor(dir == 1 ? bullCol : bearCol)

// ==========================================================================
// 9. DASHBOARD
// ==========================================================================
if showTable
    var table dash = table.new(position.top_right, 2, 5, frame_color=color.gray, frame_width=1,
         border_width=1, border_color=color.gray, bgcolor=color.new(#1a1a1a, 10))
    if barstate.islast
        table.cell(dash, 0, 0, "GOLDEN TRIDENT", text_color=color.white, bgcolor=color.black)
        table.cell(dash, 1, 0, "STATUS", text_color=color.white, bgcolor=color.black)

        table.cell(dash, 0, 1, "Structure", bgcolor=color.gray, text_color=color.white)
        table.cell(dash, 1, 1, dir == 1 ? "UPTREND" : "DOWNTREND",
             bgcolor = dir == 1 ? bullCol : bearCol, text_color=color.white)

        table.cell(dash, 0, 2, "Volatility", bgcolor=color.gray, text_color=color.white)
        table.cell(dash, 1, 2, rangeOK ? "ACTIVE" : "CHOP",
             bgcolor = rangeOK ? bullCol : color.new(color.gray, 40), text_color=color.white)

        table.cell(dash, 0, 3, "Position Size", bgcolor=color.gray, text_color=color.white)
        table.cell(dash, 1, 3, str.tostring(strategy.position_size, "#.###"),
             bgcolor=color.new(#333333, 0), text_color=color.white)

        pnlPct = strategy.position_size != 0 ?
             (strategy.position_size > 0 ?
                  (close - strategy.position_avg_price) / strategy.position_avg_price * 100 :
                  (strategy.position_avg_price - close) / strategy.position_avg_price * 100) : 0.0
        table.cell(dash, 0, 4, "Open P/L", bgcolor=color.gray, text_color=color.white)
        table.cell(dash, 1, 4, strategy.position_size != 0 ? str.tostring(pnlPct, "#.00") + "%" : "—",
             bgcolor = strategy.position_size == 0 ? color.new(color.gray, 40) : (pnlPct > 0 ? bullCol : bearCol),
             text_color=color.white)
````
