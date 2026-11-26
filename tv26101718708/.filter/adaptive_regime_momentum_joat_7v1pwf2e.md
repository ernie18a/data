# Adaptive Regime Momentum [JOAT]

- url: https://www.tradingview.com/script/7v1PWf2e-Adaptive-Regime-Momentum-JOAT/
- type: strategy
- pine_id: PUB;e1e48354907e4210bf1fec7a80bb0773
- version: 1.0

## Description

[b]Adaptive Regime Momentum [JOAT][/b]

[b]Introduction[/b]

The majority of publicly available trend-following strategies rely on one of two entry mechanisms: a moving average crossover, or a price-versus-MA relationship. These are valid starting points, but they share a common weakness — they fire signals based on a single confirmatory condition that can be triggered by brief, low-conviction price moves. A single bar pushing above a moving average while volume is thin and the MA is barely sloping is not the same market condition as a sustained directional move with volume behind it and a clearly sloping MA. Yet a simple strategy would treat both identically.

Adaptive Regime Momentum [JOAT] is a trend-following strategy that requires three independent conditions to align before generating an entry signal. These three layers — MA slope confirmation over multiple consecutive bars, price position relative to the MA, and a volume-based demand filter — must all agree simultaneously. The result is a strategy that generates fewer signals but with higher internal consistency between entry conditions. It is designed for liquid markets on daily or higher timeframes where each component is reliably measurable.

This is an [i]overlay[/i] strategy — all visuals are plotted directly on the price chart.

[image]https://www.tradingview.com/x/QrTzIwP3/[/image]
---

[b]Strategy Properties[/b]

The following default settings are used for all backtests unless modified:

[list]
[*][b]Initial capital:[/b] $10,000
[*][b]Position sizing:[/b] 5% of equity per trade
[*][b]Commission:[/b] 0.05% per side
[*][b]Pyramiding:[/b] 0 (only one open position at a time; new signals are ignored while a position is active)
[*][b]Stop loss:[/b] 2.5x ATR below the entry price (long), 2.5x ATR above the entry price (short), calculated from [i]strategy.position_avg_price[/i]
[*][b]Take profit:[/b] 4.0x ATR above the entry price (long), 4.0x ATR below the entry price (short), calculated from [i]strategy.position_avg_price[/i]
[*][b]Trail / slope exit:[/b] Position is closed early if price crosses to the wrong side of ComboMA ± 1.5x ATR, or if the MA slope reverses direction
[/list]

The stop and take profit are anchored to [b]strategy.position_avg_price[/b] — the actual average fill price of the position — rather than the signal bar's close. This ensures that in backtesting, stop and TP distances are measured from where the trade was actually opened, not from a theoretical signal level.

These are backtesting defaults only. They do not represent a recommendation for live trading position sizing or risk management.

---

[b]Core Concepts[/b]

[b]Signal 1 — ComboMA Slope Confirmation (Structural Momentum)[/b]

The ComboMA is a blend of two moving averages:
[list]
[*][b]ALMA[/b] (Arnaud Legoux Moving Average) — a smooth MA with reduced lag, fitting to recent price without overreacting to single bars
[*][b]ZLMA[/b] (Zero-Lag Moving Average) — a lag-compensated MA designed to reduce the delay between price movement and MA response
[/list]

The two are blended into a single ComboMA value. The slope of this composite is then evaluated not just on the current bar, but across the last [b]N consecutive bars[/b] (default: 3). A slope is only confirmed as UP if [i]all[/i] of the last 3 bars showed a positive slope. A slope is only confirmed as DOWN if all 3 bars showed a negative slope. A single slope fluctuation — even if the most recent bar shows a positive slope — does not trigger confirmation unless all N bars agree.

This multi-bar slope confirmation is the primary mechanism that distinguishes this strategy from a simple MA-based entry. A one-bar slope flip that immediately reverses is filtered out. Only a sustained slope direction triggers the first condition.

[b]Signal 2 — Price vs. ComboMA (Real-Time Confirmation)[/b]

The second condition requires that price is currently on the correct side of the ComboMA:
[list]
[*]For a long: close > ComboMA
[*]For a short: close < ComboMA
[/list]

This condition is evaluated at the current bar, providing real-time confirmation that price is aligned with the structural slope direction. The MA slope could be upward from prior bars, but if price has already pulled back below the MA, the second condition vetoes the entry. Both the historical slope and the current price position must agree.

[b]Signal 3 — Volume RSI (Demand Pressure Validation)[/b]

Volume RSI is RSI applied to raw volume over an 8-bar period, then divided by 50. A result above 1.0 (the default threshold) means the Volume RSI is above 50 — indicating that volume activity on recent bars has been relatively elevated compared to the preceding period.

[list]
[*]For a long entry: Volume RSI / 50 must exceed the threshold
[*]For a short entry: same condition applies
[/list]

Volume RSI does not confirm direction — it confirms [i]participation[/i]. A move accompanied by above-average volume has more demand/supply backing than a low-volume drift. When volume is below threshold, the third condition is not met and no entry is generated, even if slope and price position align.

[b]RSI Filter[/b]

An additional RSI filter is applied to the close:
[list]
[*]RSI(14) must be above 50 for long entries
[*]RSI(14) must be below 50 for short entries
[/list]

This acts as a momentum gating condition — confirming that short-term momentum is consistent with the trade direction before entry is permitted.

[b]Non-Repainting Execution[/b]

All entry conditions are gated by [b]barstate.isconfirmed[/b]. No signal is generated until the current bar has fully closed. This prevents intra-bar signal flickering and ensures that the backtest accurately represents what would have been traded on confirmed bar closes.

---

[b]Exit Logic[/b]

The strategy uses a layered exit system combining fixed risk-defined targets with adaptive trend exits:

[b]Fixed exits (via strategy.exit):[/b]
[list]
[*]Stop loss at 2.5x ATR from entry price
[*]Take profit at 4.0x ATR from entry price
[/list]

[b]Trail exits (via strategy.close):[/b]
[list]
[*]Price closes beyond ComboMA ± 1.5x ATR on the wrong side
[*]The ComboMA slope reverses (multi-bar confirmation fails in the opposite direction)
[/list]

The trail exit allows winning positions to exit earlier if the trend deteriorates before reaching the fixed take profit, while the fixed TP provides a defined maximum target. The stop loss is the unconditional floor regardless of trail conditions.

---

[b]ATR Shadow Visual[/b]

The chart displays two layers of ATR bands around the ComboMA:
[list]
[*]Inner band: ComboMA ± 1x ATR
[*]Outer band: ComboMA ± 2x ATR
[/list]

These bands give a visual read of how extended price is from the MA relative to recent volatility, and where the trail exit threshold sits (1.5x ATR, between the two bands). They are visual aids only and do not affect strategy logic.

---

[b]Performance Table[/b]

A table is displayed on the chart showing current strategy metrics:

[list]
[*]Net P&L
[*]Open P&L (current unrealized)
[*]Win Rate
[*]Average winning trade
[*]Average losing trade
[*]Maximum drawdown
[*]Total trades
[*]Current position direction
[*]Current MA slope status
[/list]

---

[b]Features[/b]

[list]
[*]Three-layer entry confirmation: multi-bar MA slope, price vs. MA, and Volume RSI
[*]RSI momentum filter as an additional gating condition
[*]ALMA + ZLMA blend for the ComboMA, reducing lag without sacrificing smoothness
[*]Multi-bar slope confirmation preventing single-bar slope flickers from triggering entries
[*]ATR-based stop and take profit anchored to actual fill price via strategy.position_avg_price
[*]Trail exit on slope reversal or price-vs-MA breach
[*]Non-repainting: all signals confirmed via barstate.isconfirmed
[*]Pyramiding disabled — one position at a time
[*]ATR shadow bands for visual context around the ComboMA
[*]Live performance table with key metrics
[/list]

---

[b]Input Parameters[/b]

[list]
[*][b]ALMA / ZLMA settings[/b] — length, offset, and sigma for each MA component
[*][b]Slope Confirm Bars[/b] (default 3) — consecutive bars of slope agreement required for confirmation
[*][b]Volume RSI Length[/b] (default 8) — RSI period applied to volume
[*][b]Volume Threshold[/b] (default 1.0) — Volume RSI / 50 minimum for the demand filter
[*][b]RSI Length[/b] (default 14) — RSI period for the momentum filter
[*][b]ATR Length[/b] — period for ATR used in stop, TP, trail, and visual bands
[*][b]Stop Multiplier[/b] (default 2.5) — ATR multiplier for the fixed stop loss
[*][b]TP Multiplier[/b] (default 4.0) — ATR multiplier for the fixed take profit
[*][b]Trail Multiplier[/b] (default 1.5) — ATR multiplier for the trail exit threshold
[/list]

---

[b]How to Use[/b]

[list]
[*]Apply to daily or higher timeframes on liquid instruments. Volume RSI is most meaningful where volume data is consistent and representative of actual market participation.
[*]Allow the chart to load sufficient historical bars before evaluating backtest results. The ComboMA slope confirmation requires multiple bars of agreement, and early bars in the dataset may not reflect the strategy's typical behavior. Aim for at least several hundred bars of data for meaningful backtest statistics.
[*]Review the performance table while backtesting to understand average win size relative to average loss, drawdown, and total trade count. A strategy with very few trades may show favorable metrics by chance rather than edge — consider whether the trade count is sufficient to draw conclusions.
[*]The default 5% equity position size produces moderate equity curve sensitivity. Smaller sizes will reduce drawdown and return proportionally; larger sizes will amplify both.
[*]Commission is set to 0.05% per side (0.1% round trip) by default. Adjust this to match your actual trading costs. Higher commission rates — especially relevant for frequent-trading timeframes — will reduce net results.
[*]Do not optimize parameters on the same data you use to evaluate performance. Optimization on historical data produces settings tuned to past noise, not future edge.
[*]The trail exit on slope reversal means that strongly trending markets where the MA briefly flattens before resuming may see early exits. This is the tradeoff for using slope as an exit condition.
[/list]

---

[b]Limitations[/b]

[list]
[*]Backtest results are calculated on historical data and do not guarantee future performance. Market conditions change, and a strategy that performed well in a particular regime may perform differently as conditions evolve.
[*]The Volume RSI filter requires reliable volume data. This strategy is [b]not recommended[/b] for synthetic instruments, CFDs where volume represents contracts rather than underlying market activity, or very short intraday timeframes where volume is fragmented and noisy. On such instruments, the third entry condition may be meaningless or misleading.
[*]The multi-bar slope confirmation requirement means the strategy will miss fast, sharp trend initiations where the MA slope has not yet had N bars to confirm. This is a deliberate tradeoff — reducing false entries at the cost of some late entries on fast moves.
[*]Pyramiding is disabled. The strategy will not add to winning positions. This limits upside during strongly trending markets where additional entries might be beneficial, but it also limits drawdown from compounding positions that subsequently reverse.
[*]ATR-based stops and TPs are fixed at entry. They do not adjust after the trade is open (apart from the trail exit). If volatility expands significantly after entry, a 2.5x ATR stop that was appropriate at entry may become relatively tight.
[*]The performance table reflects cumulative backtest results as of the current bar. Results will vary across different lookback windows and instruments.
[*]Default capital of $10,000 with 5% equity sizing means each trade risks approximately $500 before the stop is hit (assuming stop is the loss floor). This is a backtesting convention — it is not a recommendation for live account sizing.
[*]No strategy produces guaranteed results. The three-layer entry system improves internal signal consistency but cannot eliminate the inherent uncertainty of financial markets.
[/list]

---

[b]Originality Statement[/b]

Standard MA-based trend strategies treat a single bar's price-vs-MA relationship as sufficient for entry. ARM's primary differentiation is the [b]multi-bar slope confirmation requirement[/b]: the ComboMA slope must be consistently positive (or negative) across N consecutive bars before the first condition is met. A one-bar slope deviation — common during consolidations and brief retracements — does not trigger entry. Only a [i]sustained[/i] slope direction qualifies.

The ComboMA itself is a blend of ALMA and ZLMA, combining the smoothness and Gaussian weighting of ALMA with the lag-compensation of ZLMA. Neither is used in isolation because each has a specific weakness: ALMA can lag on sharp moves; ZLMA can be sensitive to noise. The blend leverages the strengths of both while partially offsetting their weaknesses.

The three-layer confirmation architecture — slope duration, price position, and demand validation — requires agreement across genuinely different measurement types: structural momentum over time, current price location, and volume activity. These are not three views of the same quantity. The stop and TP placement using [b]strategy.position_avg_price[/b] rather than the signal bar close is a practical accuracy measure: in backtesting, it means risk distances are calculated from the price at which the trade was actually filled, not from where the signal was generated, which can differ from the fill price particularly on gap opens.

---

[b]Disclaimer[/b]

This strategy is provided for educational and informational purposes only. It does not constitute financial advice, investment advice, or a recommendation to buy or sell any security. Backtested results are hypothetical and do not reflect actual trading. Hypothetical performance results have inherent limitations and do not account for execution slippage, liquidity constraints, or the psychological challenges of live trading. All trading involves risk, including the possible loss of principal. Always conduct your own research and consult a qualified financial professional before making any trading or investment decisions.

-Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
strategy("Adaptive Regime Momentum [JOAT]", shorttitle="ARM [JOAT]", overlay=true,
  default_qty_type=strategy.percent_of_equity,
  default_qty_value=5,
  commission_type=strategy.commission.percent,
  commission_value=0.05,
  initial_capital=10000,
  max_labels_count=100,
  pyramiding=0)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grpMA   = "Signal 1 — Composite MA"
maLen   = input.int(34, "MA Length", minval=5, maxval=200, group=grpMA)
almaOff = input.float(0.85, "ALMA Offset", minval=0.0, maxval=1.0, step=0.01, group=grpMA)
almaSig = input.float(6.0, "ALMA Sigma", minval=1.0, maxval=20.0, step=0.5, group=grpMA)
slopeConfirm = input.int(3, "Slope Confirm Bars", minval=1, maxval=10, group=grpMA)

grpVol  = "Signal 3 — Volume RSI"
volRsiLen  = input.int(8, "Volume RSI Length", minval=2, maxval=30, group=grpVol)
volThresh  = input.float(1.0, "Volume RSI Threshold (x50)", minval=0.5, maxval=3.0, step=0.05, group=grpVol)

grpRSI  = "RSI Filter"
rsiLen  = input.int(14, "RSI Length", minval=2, maxval=50, group=grpRSI)
rsiBullMin = input.int(50, "RSI Bull Minimum", minval=40, maxval=65, group=grpRSI)
rsiBearMax = input.int(50, "RSI Bear Maximum", minval=35, maxval=60, group=grpRSI)

grpExit = "Exit Settings"
atrLen     = input.int(14, "ATR Length", minval=1, maxval=50, group=grpExit)
stopMult   = input.float(2.5, "ATR Stop Multiplier",   minval=0.5, maxval=10.0, step=0.1, group=grpExit)
tpMult     = input.float(4.0, "ATR Take Profit Mult",  minval=0.5, maxval=20.0, step=0.1, group=grpExit)
trailMult  = input.float(1.5, "ATR Trail Multiplier",  minval=0.5, maxval=5.0,  step=0.1, group=grpExit)

grpFilt = "Trade Filters"
useVolFilter  = input.bool(true,  "Use Volume Filter",   group=grpFilt)
useRSIFilter  = input.bool(true,  "Use RSI Filter",      group=grpFilt)
longEnabled   = input.bool(true,  "Enable Long Trades",  group=grpFilt)
shortEnabled  = input.bool(true,  "Enable Short Trades", group=grpFilt)

grpVis  = "Visual"
showTbl   = input.bool(true, "Show Performance Table", group=grpVis)
showBG    = input.bool(true, "Trade Background Tint",  group=grpVis)
showATR   = input.bool(true, "Show ATR Shadow",        group=grpVis)

// ─────────────────────────────────────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────────────────────────────────────
bullColor  = color.rgb(92, 240, 215)
bearColor  = color.rgb(179, 42, 195)
neutralCol = color.rgb(130, 140, 160)
bgDark     = color.rgb(10, 14, 22)
textLight  = color.rgb(220, 225, 235)
textDim    = color.rgb(100, 110, 130)
winColor   = color.rgb(50, 220, 100)
lossColor  = color.rgb(255, 80, 80)

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL 1 — COMPOSITE MA (ALMA + ZLMA BLEND)
// ─────────────────────────────────────────────────────────────────────────────
src       = close
almaLine  = ta.alma(src, maLen, almaOff, almaSig)
zlmaRaw   = 2.0 * ta.ema(src, maLen) - ta.ema(ta.ema(src, maLen), maLen)
zlmaLine  = ta.ema(zlmaRaw, maLen)
comboMA   = (almaLine + zlmaLine) / 2.0

maSlope   = comboMA - comboMA[1]
maSlopeUp   = maSlope > 0
maSlopeDn   = maSlope < 0

// Confirm slope direction over N bars
slopeUpCount = 0
slopeDnCount = 0
for si = 0 to slopeConfirm - 1
    if (comboMA[si] - comboMA[si + 1]) > 0
        slopeUpCount += 1
    if (comboMA[si] - comboMA[si + 1]) < 0
        slopeDnCount += 1

slopeConfirmedUp = slopeUpCount >= slopeConfirm
slopeConfirmedDn = slopeDnCount >= slopeConfirm

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL 2 — PRICE vs COMBO MA + CLOSE POSITION
// ─────────────────────────────────────────────────────────────────────────────
priceAboveMA = close > comboMA
priceBelowMA = close < comboMA

// ─────────────────────────────────────────────────────────────────────────────
// SIGNAL 3 — VOLUME RSI CONFIRMATION
// ─────────────────────────────────────────────────────────────────────────────
volumeRSI = ta.rsi(volume, volRsiLen) / 50.0
volConfirm = not useVolFilter or volumeRSI > volThresh

// ─────────────────────────────────────────────────────────────────────────────
// RSI FILTER
// ─────────────────────────────────────────────────────────────────────────────
rsiVal    = ta.rsi(close, rsiLen)
rsiBull   = not useRSIFilter or rsiVal > rsiBullMin
rsiBear   = not useRSIFilter or rsiVal < rsiBearMax

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY CONDITIONS (non-repainting via barstate.isconfirmed)
// ─────────────────────────────────────────────────────────────────────────────
atr14 = ta.atr(atrLen)

longCondition  = slopeConfirmedUp and priceAboveMA and volConfirm and rsiBull  and longEnabled  and barstate.isconfirmed
shortCondition = slopeConfirmedDn and priceBelowMA and volConfirm and rsiBear  and shortEnabled and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// EXIT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
longExitCond  = (close < comboMA - atr14 * trailMult or maSlopeDn)  and barstate.isconfirmed
shortExitCond = (close > comboMA + atr14 * trailMult or maSlopeUp)  and barstate.isconfirmed

// ─────────────────────────────────────────────────────────────────────────────
// STRATEGY EXECUTION
// ─────────────────────────────────────────────────────────────────────────────
if longCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

if shortCondition and strategy.position_size == 0
    strategy.entry("Short", strategy.short)

if strategy.position_size > 0 and strategy.position_avg_price > 0
    strategy.exit("Long TP/SL", "Long",
      stop  = strategy.position_avg_price - stopMult * atr14,
      limit = strategy.position_avg_price + tpMult   * atr14)

if strategy.position_size < 0 and strategy.position_avg_price > 0
    strategy.exit("Short TP/SL", "Short",
      stop  = strategy.position_avg_price + stopMult * atr14,
      limit = strategy.position_avg_price - tpMult   * atr14)

if longExitCond and strategy.position_size > 0
    strategy.close("Long", comment="L-Exit")

if shortExitCond and strategy.position_size < 0
    strategy.close("Short", comment="S-Exit")

// ─────────────────────────────────────────────────────────────────────────────
// SMOOTH COLOR TRANSITION
// ─────────────────────────────────────────────────────────────────────────────
targetR     = maSlopeUp ? float(color.r(bullColor)) : float(color.r(bearColor))
targetG     = maSlopeUp ? float(color.g(bullColor)) : float(color.g(bearColor))
targetB     = maSlopeUp ? float(color.b(bullColor)) : float(color.b(bearColor))
smoothR     = ta.ema(targetR, 12)
smoothG     = ta.ema(targetG, 12)
smoothB     = ta.ema(targetB, 12)
smoothColor = color.rgb(int(smoothR), int(smoothG), int(smoothB))

// ─────────────────────────────────────────────────────────────────────────────
// ATR SHADOW LAYERS
// ─────────────────────────────────────────────────────────────────────────────
shadow1U = comboMA + 1.0 * atr14
shadow1L = comboMA - 1.0 * atr14
shadow2U = comboMA + 2.0 * atr14
shadow2L = comboMA - 2.0 * atr14

// ─────────────────────────────────────────────────────────────────────────────
// PLOTS
// ─────────────────────────────────────────────────────────────────────────────
pMA    = plot(comboMA, "Combo MA", color=smoothColor, linewidth=2)
pAlma  = plot(almaLine, "ALMA",   color=color.new(smoothColor, 60), linewidth=1)
pZLMA  = plot(zlmaLine, "ZLMA",   color=color.new(smoothColor, 60), linewidth=1)

pSh2U  = plot(showATR ? shadow2U : na, "ATR Shadow 2 Upper", display=display.none)
pSh2L  = plot(showATR ? shadow2L : na, "ATR Shadow 2 Lower", display=display.none)
pSh1U  = plot(showATR ? shadow1U : na, "ATR Shadow 1 Upper", display=display.none)
pSh1L  = plot(showATR ? shadow1L : na, "ATR Shadow 1 Lower", display=display.none)

fill(pSh2U, pSh2L, shadow2U, shadow2L,
     showATR ? color.new(smoothColor, 93) : na, showATR ? color.new(smoothColor, 93) : na)
fill(pSh1U, pSh1L, shadow1U, shadow1L,
     showATR ? color.new(smoothColor, 82) : na, showATR ? color.new(smoothColor, 82) : na)

// ─────────────────────────────────────────────────────────────────────────────
// TRADE BACKGROUND TINT
// ─────────────────────────────────────────────────────────────────────────────
inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0
bgcolor(showBG and inLong  ? color.new(bullColor, 95) : na)
bgcolor(showBG and inShort ? color.new(bearColor, 95) : na)

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY / EXIT LABELS
// ─────────────────────────────────────────────────────────────────────────────
if longCondition and strategy.position_size == 0
    label.new(bar_index, low - atr14 * 1.5,
      text="▲ LONG\nVol: " + str.tostring(volumeRSI, "#.##"),
      style=label.style_label_up,
      color=color.new(bullColor, 15),
      textcolor=bgDark,
      size=size.small)

if shortCondition and strategy.position_size == 0
    label.new(bar_index, high + atr14 * 1.5,
      text="▼ SHORT\nVol: " + str.tostring(volumeRSI, "#.##"),
      style=label.style_label_down,
      color=color.new(bearColor, 15),
      textcolor=color.white,
      size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// PERFORMANCE METRICS
// ─────────────────────────────────────────────────────────────────────────────
totalTrades  = strategy.closedtrades
winTrades    = strategy.wintrades
lossTrades   = strategy.losstrades
winRate      = totalTrades > 0 ? (float(winTrades) / float(totalTrades)) * 100.0 : 0.0
netPnL       = strategy.netprofit
avgWin       = winTrades > 0  ? strategy.grossprofit  / float(winTrades)  : 0.0
avgLoss      = lossTrades > 0 ? strategy.grossloss    / float(lossTrades) : 0.0
maxDD        = strategy.max_drawdown
openPnL      = strategy.openprofit

// ─────────────────────────────────────────────────────────────────────────────
// PERFORMANCE TABLE
// ─────────────────────────────────────────────────────────────────────────────
var table perfTable = na
if showTbl
    if na(perfTable)
        perfTable := table.new(position.bottom_right, 2, 10,
          bgcolor=color.new(bgDark, 15),
          border_color=color.new(neutralCol, 70),
          border_width=1,
          frame_color=color.new(neutralCol, 50),
          frame_width=1)

    table.cell(perfTable, 0, 0, "ARM [JOAT]", text_color=textLight,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(perfTable, 1, 0, syminfo.ticker, text_color=bullColor,
      bgcolor=color.new(bgDark, 5), text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 1, "Net P&L", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    pnlCol = netPnL >= 0 ? winColor : lossColor
    table.cell(perfTable, 1, 1, str.tostring(netPnL, "#.##"), text_color=pnlCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 2, "Open P&L", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    openCol = openPnL >= 0 ? winColor : lossColor
    table.cell(perfTable, 1, 2, str.tostring(openPnL, "#.##"), text_color=openCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 3, "Win Rate", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    wrCol = winRate >= 55 ? winColor : winRate >= 45 ? textLight : lossColor
    table.cell(perfTable, 1, 3, str.tostring(winRate, "#.#") + "%", text_color=wrCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 4, "Avg Win", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(perfTable, 1, 4, str.tostring(avgWin, "#.##"), text_color=winColor,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 5, "Avg Loss", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(perfTable, 1, 5, str.tostring(math.abs(avgLoss), "#.##"), text_color=lossColor,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 6, "Max DD", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    ddCol = math.abs(maxDD) < netPnL * 0.3 ? winColor : lossColor
    table.cell(perfTable, 1, 6, str.tostring(math.abs(maxDD), "#.##"), text_color=ddCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 7, "Trades", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    table.cell(perfTable, 1, 7, str.tostring(totalTrades), text_color=textLight,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 8, "Position", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    posStr = inLong ? "LONG" : inShort ? "SHORT" : "FLAT"
    posCol = inLong ? bullColor : inShort ? bearColor : neutralCol
    table.cell(perfTable, 1, 8, posStr, text_color=posCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

    table.cell(perfTable, 0, 9, "MA Slope", text_color=textDim, text_size=size.tiny,
      text_font_family=font.family_monospace, text_halign=text.align_left)
    slopeStr = slopeConfirmedUp ? "UP" : slopeConfirmedDn ? "DOWN" : "FLAT"
    slopeCol = slopeConfirmedUp ? bullColor : slopeConfirmedDn ? bearColor : neutralCol
    table.cell(perfTable, 1, 9, slopeStr, text_color=slopeCol,
      text_size=size.tiny, text_font_family=font.family_monospace, text_halign=text.align_right)

// ─────────────────────────────────────────────────────────────────────────────
// ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(longCondition  and strategy.position_size == 0, title="ARM [JOAT] Long Entry",  message="ARM [JOAT]: LONG entry on {{ticker}} — momentum regime aligned bullish.")
alertcondition(shortCondition and strategy.position_size == 0, title="ARM [JOAT] Short Entry", message="ARM [JOAT]: SHORT entry on {{ticker}} — momentum regime aligned bearish.")
alertcondition(longExitCond   and strategy.position_size > 0,  title="ARM [JOAT] Long Exit",   message="ARM [JOAT]: LONG exit triggered on {{ticker}}.")
alertcondition(shortExitCond  and strategy.position_size < 0,  title="ARM [JOAT] Short Exit",  message="ARM [JOAT]: SHORT exit triggered on {{ticker}}.")
````
