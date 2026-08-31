<!-- tradingview-pine-id: PUB;0a0138f7b7be44c8b5a9c46f5e1a8271 -->
<!-- tradingviewscripts-format: 1 -->
# TRADLEWARE-Ichimoku TK-Cross + MFI SOL

Source: https://www.tradingview.com/script/71yKm18B-TRADLEWARE-Ichimoku-TK-Cross-MFI-SOL/

## Description

[image]https://www.tradingview.com/x/lXP6qZzo/[/image]

Ichimoku TK-Cross + Money Flow Index

This strategy uses the classic Ichimoku Cloud system to catch confirmed trend entries on a high-volatility altcoin, with a volume-based filter added to screen out low-conviction fakeouts.

How it works

Ichimoku Kinko Hyo ("one-glance equilibrium chart") is a trend system built from a few moving-midpoint lines. The Tenkan (short-term, plotted in blue) and Kijun (medium-term, plotted in orange) lines are each the midpoint of the highest high and lowest low over their own lookback window — similar in spirit to a moving average, but based on the range rather than the close. Two further lines, Senkou A and B, are projected forward to form the "cloud" (Kumo): a band that acts as dynamic support and resistance, shaded teal when it's bullish (Senkou A above Senkou B) and red when bearish.

On top of this, the Money Flow Index (MFI) — a volume-weighted version of RSI — checks that money is actually flowing into the asset, not just that price has moved.

Entry

A long position is opened when all three conditions are true simultaneously:

[*] The blue Tenkan line crosses above the orange Kijun line (a bullish momentum shift)
[*] Price is above the cloud, which should be shaded teal at this point (the broader trend is confirmed bullish)
[*] The Money Flow Index is above 50 (volume-weighted money flow is positive, not just price drifting up on thin conviction)

The MFI filter exists specifically because this asset is prone to fakeout breakouts — moves that clear the cloud on price alone but aren't backed by real buying volume.

Exit

The position is closed when price closes back below the orange Kijun line — the "equilibrium" level the whole system is built around. An optional stop-loss (on by default) sits at the bottom of the cloud: if price loses the entire cloud — meaning it closes below whichever of the teal/red Senkou lines is lower — the broader trend structure itself has broken, not just short-term momentum.

Parameters

[*] Tenkan length: 20
[*] Kijun length: 60
[*] Senkou B length: 120 (the cloud is projected forward by the Kijun length, the classic convention)
[*] MFI length: 14
[*] MFI minimum: 50 (stable across a 50-60 range in testing, not a fragile single value)
[*] Stop-loss at cloud bottom: on by default, can be disabled
[*] Label offset (ATR multiples): purely cosmetic — controls how far the BUY/SELL text labels sit from the candles so they don't overlap TradingView's own trade markers
[*] Start/End date range inputs let you restrict the backtest window without editing code

Position sizing is set to 99.95% of equity per trade rather than a full 100%. That small gap is deliberate: on this timeframe, sizing at exactly 100% causes TradingView to occasionally generate tiny extra "Margin call" rows in the trade list from floating-point rounding after commission — enough of them, on this script, to noticeably distort the displayed win rate. The 0.05% gap removes those artifacts; the effect on actual results is negligible.

Costs modelled

0.1% commission per side, 3 ticks slippage, fills at next bar's open.

Intended assets and timeframe

4-hour bars. Designed and tested in Python on SOL/USDT, then validated against a live TradingView backtest on BINANCE:SOLUSDT — entry and exit prices matched to the cent on the large majority of trades. Parameters were tuned specifically for SOL's volatility profile and are not expected to carry over unchanged to other assets.

---

## Source Code

````pine
//@version=6
// Author: cs_lev
// Strategy: Ichimoku (TK-cross + MFI) — SOL
// Hypothesis: On a high-volatility alt, a Tenkan/Kijun bullish cross while price is above the
//             cloud marks a confirmed momentum trend entry. A Money Flow Index gate (MFI>50)
//             requires volume-weighted money flow to be positive, filtering the low-conviction
//             fakeouts SOL is prone to. Exit when price closes back below the Kijun (equilibrium).
// Assumed regime: trending; sits out / takes small losses in sustained downtrends (long-only).
// Timeframe: 4H (designed and validated on 4-hour bars — apply on a 4H SOL chart).
// Assets: SOL/USDT (this config is SOL-specific; parameters were tuned for SOL's
//         volatility and are not expected to transfer to other assets unchanged).

strategy(title="TRADLEWARE-Ichimoku TK-Cross + MFI SOL", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=99.95,         // not 100 — see note below
     // On this script specifically, 100% produces ~10 margin-call artifact trades against
     // only ~27 real ones (4H bars generate far more rounding events than daily), which
     // corrupts the displayed win rate by ~14 points (e.g. 52% real -> 38% shown). 99.95%
     // clears the rounding headroom and removes the artifacts entirely; the PnL cost is
     // ~1% total, well within normal backtest noise. This is a deliberate exception — do
     // NOT copy 99.95 onto the Gaussian Channel scripts, where margin-call counts are small
     // (2-4) and the "keep 100%, ignore the noise" default is still the more honest choice.
     // See pinescript-conventions.md's "Margin-call micro-trades" section.
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     slippage=3,
     pyramiding=0,
     calc_on_every_tick=false,
     process_orders_on_close=false)   // fill at next bar's open — matches the Python engine

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Date range — integer year/month/day fields (input.time() does not reliably
// trigger recalculation in TradingView). Defaults match the Python SOL window.
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
startYear  = input.int(2022, "Start year",  minval=2000, maxval=2099, group="Date Range")
startMonth = input.int(1,    "Start month", minval=1,    maxval=12,   group="Date Range")
startDay   = input.int(1,    "Start day",   minval=1,    maxval=31,   group="Date Range")
endYear    = input.int(2099, "End year",    minval=2000, maxval=2099, group="Date Range")
endMonth   = input.int(12,   "End month",   minval=1,    maxval=12,   group="Date Range")
endDay     = input.int(31,   "End day",     minval=1,    maxval=31,   group="Date Range")
timeCondition = time >= timestamp(startYear, startMonth, startDay, 0, 0) and time <= timestamp(endYear, endMonth, endDay, 23, 59)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Inputs — SOL 4h validated config
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
tenkanLen  = input.int(20,  "Tenkan length",   minval=1, group="Ichimoku")
kijunLen   = input.int(60,  "Kijun length",    minval=1, group="Ichimoku")
senkouBLen = input.int(120, "Senkou B length", minval=1, group="Ichimoku")
// Cloud projection (and Chikou lag). Classic = kijun; we keep that tie.
displacement = kijunLen

mfiLen = input.int(14, "MFI length", minval=1, group="Money Flow Filter")
mfiMin = input.float(50.0, "MFI minimum (money flow gate)", minval=0, maxval=100, group="Money Flow Filter",
     tooltip="Require MFI > this on the entry bar. 50 = positive money flow. Validated improvement on SOL 4h; stable across 50–60.")

useStopLoss = input.bool(true, "Stop-loss at cloud bottom", group="Stop Loss")

// Push the BUY/SELL labels away from the candles so they don't sit under
// TradingView's own entry/exit markers. Scaled by ATR so the gap adapts to volatility.
labelOffsetMult = input.float(1.5, "Label offset (ATR multiples)", minval=0, step=0.5, group="Labels",
     tooltip="Distance the BUY/SELL labels are placed below/above the bar, in ATR(14) multiples. Increase if they still overlap TV's markers.")

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Ichimoku lines
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
midpoint(int len) => (ta.highest(high, len) + ta.lowest(low, len)) / 2.0

tenkan = midpoint(tenkanLen)
kijun  = midpoint(kijunLen)

// Leading spans, computed "now". Projected forward `displacement` bars for display.
leadA = (tenkan + kijun) / 2.0
leadB = midpoint(senkouBLen)

// The cloud the price is interacting with AT the current bar is the lead line
// computed `displacement` bars ago — i.e. leadA[displacement]. This matches the
// Python .shift(displacement) and is lookahead-safe (no future data used).
cloudTopNow    = math.max(leadA[displacement], leadB[displacement])
cloudBottomNow = math.min(leadA[displacement], leadB[displacement])

mfi = ta.mfi(hlc3, mfiLen)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Plotting
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
plot(tenkan, "Tenkan", color=color.new(#2962FF, 0), linewidth=1)
plot(kijun,  "Kijun",  color=color.new(#FF6D00, 0), linewidth=2)

// Cloud, drawn displaced forward (standard Ichimoku display).
pA = plot(leadA, "Senkou A", offset=displacement, color=color.new(#26A69A, 50))
pB = plot(leadB, "Senkou B", offset=displacement, color=color.new(#EF5350, 50))
fill(pA, pB, color = leadA > leadB ? color.new(#26A69A, 80) : color.new(#EF5350, 80), title="Kumo")

// MFI is a separate-pane oscillator and cannot be drawn on an overlay strategy.
// To see it, add TradingView's built-in "Money Flow Index" (length 14) in its own pane.

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Trading logic
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
tkCrossUp  = ta.crossover(tenkan, kijun)
aboveCloud = close > cloudTopNow
mfiOk      = mfi > mfiMin

// Entry: TK bullish cross, price above the cloud, money flow positive.
longCondition = tkCrossUp and aboveCloud and mfiOk and timeCondition

// Exit: price closes below the equilibrium line (Kijun).
exitCondition = close < kijun and timeCondition

if longCondition and strategy.position_size == 0
    strategy.entry("Long", strategy.long)

if exitCondition and strategy.position_size > 0
    strategy.close("Long")

// Stop: bottom of the cloud (regime broken if price loses the whole Kumo).
if useStopLoss and strategy.position_size > 0
    strategy.exit("Stop", from_entry="Long", stop=cloudBottomNow)

//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
// Trade labels — drawn when the position actually changes (matches next-open fills)
//-----------------------------------------------------------------------------------------------------------------------------------------------------------------
positionJustOpened = strategy.position_size > 0 and strategy.position_size[1] == 0
positionJustClosed = strategy.position_size == 0 and strategy.position_size[1] > 0

labelOffset = labelOffsetMult * ta.atr(14)

if positionJustOpened
    // BUY label sits BELOW the low; style_label_up points its arrow up at the bar.
    label.new(bar_index, low - labelOffset,
              "BUY @ " + str.tostring(open, format.mintick),
              color=color.new(color.green, 20), textcolor=color.white,
              style=label.style_label_up, size=size.small)

if positionJustClosed
    lastTrade = strategy.closedtrades - 1
    entryPx   = strategy.closedtrades.entry_price(lastTrade)
    exitPx    = strategy.closedtrades.exit_price(lastTrade)
    pnlPct    = (exitPx - entryPx) / entryPx * 100
    pnlStr    = (pnlPct >= 0 ? "+" : "") + str.tostring(math.round(pnlPct, 2)) + "%"
    // SELL label sits ABOVE the high; style_label_down points its arrow down at the bar.
    label.new(bar_index, high + labelOffset,
              "SELL @ " + str.tostring(exitPx, format.mintick) + "\nP&L: " + pnlStr,
              color=color.new(color.red, 20), textcolor=color.white,
              style=label.style_label_down, size=size.small)
````
