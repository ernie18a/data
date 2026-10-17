# [3Commas] UNI Vault Grid - UNI - Indicator

- url: https://www.tradingview.com/script/DFvuYOz7-3Commas-UNI-Vault-Grid-UNI-Indicator/
- type: indicator
- pine_id: PUB;bbfbae1a6a3b4e80ac43c8e612a5a3be
- version: 1.0

## Description

[3Commas] UNI Vault Grid — UNI — Indicator

🔷 What it does:
This indicator is the visual + signal-only companion to the static geometric grid strategy for Uniswap (UNI/USDT). It draws all 57 grid levels on the chart, fires Buy and Sell signals on each close-cross event, tracks a virtual P&L card (simulating what the matching strategy would have done), and ships webhook alerts for routing signals to a connected grid bot. Use it when you want the grid logic running on your chart without strategy.* engine — for visual confirmation, manual entries, or external bot routing.
  - 57 geometrically-spaced levels between Low (2.979) and High (4.171) drawn as horizontal lines
  - Buy / Sell labels printed at each level on cross events
  - Virtual P&L tracker mirrors the strategy version's bookkeeping
  - Static range — grid does NOT shift up when price exits the band (trailing-up disabled)
  - Webhook-ready alert payload for connected grid bot

🔷 Who is it for:
  Traders who want to visualize the grid and signal layer on their chart without running the strategy engine.
  Bot operators routing signals from TradingView alerts to a connected grid bot via webhook.
  Discretionary swing traders who want grid levels as decision support while executing manually.
  Users comparing live signal flow against backtested behavior of the matching strategy publication.

🔷 How does it work:
  Grid Construction: On the first bar, the indicator pre-computes 57 price levels between Low (2.979) and High (4.171) using geometric spacing (≈ 0.61% step). Each level is drawn as a horizontal line — green for the lowest, red for the highest, aqua for the middle levels.
  Signal Generation: On every confirmed bar, the indicator checks each level for a close-cross-down (Buy signal) or close-cross-up (Sell signal) against the next level above. A label is printed at the level on each cross. Buy labels are aqua, Sell labels are fuchsia and include the realized virtual P&L.
  Virtual P&L Tracker: The indicator maintains its own bookkeeping that mirrors the strategy version — when a Buy level fills, qty is recorded; when the next-up Sell level crosses, the per-level P&L is added to the virtual net. Stats card displays Net P&L, Max Drawdown, Total Fills, Win Rate, and Profit Factor.
  Webhook Alerts: A grid_start JSON payload (Bot ID, Email Token, Pair) is fired once when the first bar enters the configured backtest window. This is informational — grid bots are typically configured on the bot interface directly.

🔷 Why it's unique:
  Identical grid math to the strategy publication — same 57 levels, same step, same cross-detection logic. The virtual P&L card lets you see live what the strategy version is doing in backtest, but on an indicator pane (no strategy.* engine, no order fills).
  Static range fidelity — no trailing-up. The grid stays locked exactly where you configured it, which makes risk envelope easy to reason about before deploying capital.
  Brand watermark + stats overlay — consistent visual layer with all other 3Commas Vault Grid publications.

🔷 Considerations Before Using the Indicator:

  Market & Timeframe: Calibrated for a 15-minute chart on UNI/USDT spot pairs. The runtime warning label flags any TF other than 15m. Higher TFs produce far fewer fills; lower TFs (1m, 5m) generate more signals but slow chart rendering.

  Limitations: The indicator does NOT place orders — it only signals. If you wire the alerts to a grid bot, the bot is responsible for executing entries and exits. The virtual P&L card is an in-indicator simulation only, not a real account P&L. It does not include funding, slippage, or partial fills.

  Backtesting & Demo Testing: The strategy version is the canonical reference for realized backtest performance (with commission, slippage, and the strategy engine's order book). This indicator's virtual P&L is a useful estimate but cannot replace the strategy tester report. Demo-trade your bot for at least one month before any live deployment.

  Parameter Adjustments: The grid range, level count, and per-level amount should be re-evaluated for each deployment period. UNI's "fair range" shifts over time — a grid calibrated for one regime may not work for the next. The default 2.979 — 4.171 envelope reflects UNI's recent volatility band as of publication.

🔷 INDICATOR SETTINGS
  Grid High Price — Upper boundary of the grid range (default 4.171).
  Grid Low Price — Lower boundary of the grid range (default 2.979).
  Grid Levels — Total number of price levels (default 57).
  Grid Mode — Geometric (constant % spacing) or Arithmetic (constant absolute spacing).
  Amount per Level (USDT, ref) — Notional per fill (default 175.44) — used for virtual P&L only.
  Trailing Up — Disabled by default. Enables adaptive grid behavior on breakout (off keeps grid static).
  Trail Up Threshold % — % above High at which trailing fires (only used if Trailing Up enabled).
  Shift Up Magnitude % — How much of the current range to shift when trailing-up fires.
  Limit by Date Range — Constrain virtual backtest to a specific date window (default Jan 19 — May 19 2026).
  Initial Capital (USDT, ref for % calc) — Used to convert virtual P&L into a % figure on the stats card.
  Show grid lines on chart — Toggle horizontal level lines (red top, green bottom, aqua middle).
  Show fill labels on chart — Toggle Buy / Sell labels printed on each cross.
  Show stats card — Toggle the on-chart virtual backtest summary.
  Stats card position — Where to anchor the stats card.
  Show watermark — Toggle the brand watermark.
  Watermark text / position / size / transparency — Controls for the watermark overlay.
  Recommended TF (for warning) — Timeframe baseline for runtime warning (default 15m).
  Webhook (Grid Bot) — Bot ID, Email Token, Pair label for signal routing.

🔷 ALERTS
  grid_start — Fires once when the first bar enters the configured backtest window. Webhook-ready JSON payload with Bot ID, Email Token, and Pair label.

🔷 RELATED PUBLICATIONS
  Strategy version (with full Strategy Tester backtest report): [https://www.tradingview.com/script/Dc5iUh2F-3Commas-UNI-Vault-Grid-UNI-USDT/

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.

__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] UNI Vault Grid — UNI — Indicator
//  Companion to the Strategy version with identical grid logic.
// ---------------------------------------------------------------------
//  ⚠️ RECOMMENDED TIMEFRAME: 15 minutes
//
//  Identical static-range grid mechanics to the Strategy version:
//    - 57 geometrically-spaced levels between Low (2.979) and High (4.171)
//    - Buy on close-cross-down through unfilled level
//    - Sell on close-cross-up through next level
//    - NO trailing up — grid stays locked to configured range
//
//  Strategy reference (BYBIT:UNIUSDT, 15m, Jan 19 2026 — May 19 2026, 120 days):
//    See published strategy for full Strategy Tester results.
//
//  Built-in GRID Bot backtest reference (Last 120 days, UNI/USDT):
//    Profit: +23.15%   |   Trades: 1290
//
//  Use cases:
//    - Visual signal confirmation for connected static grid bot
//    - On-chart grid overlay for range-bound UNI
//    - Live virtual P&L tracker for static grid backtesting
//
//  Visual layer:
//    - 57 horizontal grid lines (red top, green bottom, aqua middle)
//    - Buy / Sell signal labels on each cross event
//    - Stats card with virtual P&L, DD, Trades, Win Rate, PF
//    - Brand watermark
// =====================================================================

indicator(
     title              = "[3Commas] UNI Vault Grid — UNI — Indicator",
     shorttitle         = "UNI Vault Ind",
     overlay            = true,
     max_lines_count    = 100,
     max_labels_count   = 500,
     max_bars_back      = 500)

// =====================================================================
//                              INPUTS
// =====================================================================
highPx     = input.float(4.171, "Grid High Price",                    step = 0.001, group = "Grid Range")
lowPx      = input.float(2.979, "Grid Low Price",                     step = 0.001, group = "Grid Range")
levels     = input.int  (57,    "Grid Levels",     minval = 2, maxval = 100,        group = "Grid Range")
gridMode   = input.string("Geometric", "Grid Mode", options = ["Geometric","Arithmetic"], group = "Grid Range")

amountPerLevel = input.float(175.44, "Amount per Level (USDT, ref)", minval = 0.01, step = 0.01, group = "Sizing")

trailUp       = input.bool (false, "Trailing Up — shift grid when price exceeds High", group = "Behavior")
trailUpThr    = input.float(3.0,   "Trail Up Threshold % above High",  minval = 0.1, step = 0.1, group = "Behavior")
trailShiftPct = input.float(50,    "Shift Up Magnitude % of range",    minval = 1, maxval = 100, step = 1, group = "Behavior")

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2026-01-19 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-19 23:59 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

initCapital = input.float(11000, "Initial Capital (USDT, ref for % calc)", minval = 1, group = "Virtual Backtest")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (Grid Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (Grid Bot)")
pairLabel  = input.string("USDT_UNI",         "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (Grid Bot)")

// — Display —
showGridLines  = input.bool(true, "Show grid lines on chart",   group = "Visual Layer")
showFillLabels = input.bool(true, "Show fill labels on chart",  group = "Visual Layer")
showStats      = input.bool(true, "Show stats card",            group = "Display")
statsPosStr    = input.string("top_left", "Stats card position",
     options = ["top_left","top_center","top_right","middle_left","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
showWM         = input.bool(true, "Show watermark",             group = "Display")
wmText         = input.string("3Commas", "Watermark text",      group = "Display")
wmPosStr       = input.string("top_right", "Watermark position",
     options = ["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group = "Display")
wmSizeStr      = input.string("huge", "Watermark size",
     options = ["tiny","small","normal","large","huge"], group = "Display")
wmAlpha        = input.int(70, "Watermark transparency (0=solid)", minval = 0, maxval = 100, group = "Display")

// =====================================================================
//                       TIMEFRAME WARNING
// =====================================================================
recommendedTF = input.timeframe("15", "Recommended TF (for warning)", group = "Timeframe")
tfMismatch = timeframe.period != recommendedTF

var label tfWarn = na
if barstate.islast and tfMismatch
    label.delete(tfWarn)
    tfWarn := label.new(
         x      = bar_index,
         y      = high,
         text   = "⚠ Indicator is calibrated for " + recommendedTF + "m chart.\nCurrent TF: " + timeframe.period + ". Results may differ significantly.",
         style  = label.style_label_down,
         color  = color.new(color.orange, 20),
         textcolor = color.white,
         size   = size.normal,
         yloc   = yloc.abovebar)

// =====================================================================
//                          GRID STATE
// =====================================================================
var float curHigh     = highPx
var float curLow      = lowPx
var array<float> gridLevels  = array.new<float>(levels, 0.0)
var array<bool>  filled      = array.new<bool>(levels, false)
var array<float> fillPrice   = array.new<float>(levels, 0.0)
var array<float> fillQty     = array.new<float>(levels, 0.0)
var array<line>  gridLines   = array.new<line>(0)

f_computeLevels() =>
    for i = 0 to levels - 1
        ratio = i / (levels - 1.0)
        lvl = gridMode == "Geometric"
             ? curLow * math.pow(curHigh / curLow, ratio)
             : curLow + (curHigh - curLow) * ratio
        array.set(gridLevels, i, lvl)

if barstate.isfirst
    f_computeLevels()

// =====================================================================
//                       TRAILING UP — shift grid (off by default)
// =====================================================================
if trailUp and inWindow and close > curHigh * (1.0 + trailUpThr / 100.0)
    rng = curHigh - curLow
    shift = rng * trailShiftPct / 100.0
    curHigh := curHigh + shift
    curLow  := curLow  + shift
    f_computeLevels()

// =====================================================================
//                  VIRTUAL P&L / STATS TRACKER
// =====================================================================
var float vNetProfit   = 0.0
var float vGrossProfit = 0.0
var float vGrossLoss   = 0.0
var int   vTrades      = 0
var int   vWins        = 0
var float vPeakEquity  = 0.0
var float vMaxDD       = 0.0

// =====================================================================
//                       GRID TRADING LOGIC (virtual)
// =====================================================================
if inWindow and barstate.isconfirmed and bar_index > 0
    // SELL pass
    for i = 0 to levels - 2
        if array.get(filled, i)
            sellLvl = array.get(gridLevels, i + 1)
            if close >= sellLvl and close[1] < sellLvl
                buyPx = array.get(fillPrice, i)
                qty   = array.get(fillQty, i)
                pnl   = (sellLvl - buyPx) * qty

                vNetProfit := vNetProfit + pnl
                vTrades    := vTrades + 1
                if pnl >= 0
                    vWins        := vWins + 1
                    vGrossProfit := vGrossProfit + pnl
                else
                    vGrossLoss   := vGrossLoss + math.abs(pnl)

                array.set(filled,    i, false)
                array.set(fillPrice, i, 0.0)
                array.set(fillQty,   i, 0.0)

                if showFillLabels
                    label.new(bar_index, sellLvl, "Sell L" + str.tostring(i) + "\n+" + str.tostring(pnl, "0.0000"),
                         style = label.style_label_down, color = color.new(color.fuchsia, 20),
                         textcolor = color.white, size = size.tiny, yloc = yloc.price)

    // BUY pass
    for i = 0 to levels - 1
        if not array.get(filled, i)
            buyLvl = array.get(gridLevels, i)
            if close <= buyLvl and close[1] > buyLvl
                qty = amountPerLevel / buyLvl
                array.set(filled,    i, true)
                array.set(fillPrice, i, buyLvl)
                array.set(fillQty,   i, qty)

                if showFillLabels
                    label.new(bar_index, buyLvl, "Buy L" + str.tostring(i),
                         style = label.style_label_up, color = color.new(color.aqua, 20),
                         textcolor = color.white, size = size.tiny, yloc = yloc.price)

// Drawdown tracking
vPeakEquity := math.max(vPeakEquity, vNetProfit)
currentDD   = vPeakEquity - vNetProfit
vMaxDD      := math.max(vMaxDD, currentDD)

// =====================================================================
//                       VISUALIZE GRID LINES
// =====================================================================
if barstate.islast and showGridLines
    while array.size(gridLines) > 0
        line.delete(array.pop(gridLines))
    for i = 0 to levels - 1
        lvl = array.get(gridLevels, i)
        isHi = i == levels - 1
        isLo = i == 0
        clr = isHi ? color.new(color.red, 30) : isLo ? color.new(color.green, 30) : color.new(color.aqua, 80)
        wd  = (isHi or isLo) ? 2 : 1
        ln = line.new(bar_index - 1, lvl, bar_index, lvl, color = clr, width = wd, extend = extend.both)
        array.push(gridLines, ln)

// =====================================================================
//                          STATS CARD
// =====================================================================
f_pos(s) =>
    s == "top_left"      ? position.top_left      :
     s == "top_center"    ? position.top_center    :
     s == "top_right"     ? position.top_right     :
     s == "middle_left"   ? position.middle_left   :
     s == "middle_center" ? position.middle_center :
     s == "middle_right"  ? position.middle_right  :
     s == "bottom_left"   ? position.bottom_left   :
     s == "bottom_center" ? position.bottom_center :
     position.bottom_right

f_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

np      = vNetProfit
npPct   = initCapital > 0 ? np / initCapital * 100 : 0.0
dd      = vMaxDD
ddPct   = initCapital > 0 ? dd / initCapital * 100 : 0.0
nTrades = vTrades
wins    = vWins
wrPct   = nTrades > 0 ? wins / nTrades * 100 : 0.0
pf      = vGrossLoss > 0 ? vGrossProfit / vGrossLoss : 0.0

clrPos    = color.new(#00C853, 0)
clrNeg    = color.new(#D50000, 0)
clrNeutral= color.new(#FFFFFF, 10)
clrHdrBg  = color.new(#1E88E5, 10)
clrRowBg  = color.new(#0D1B2A, 25)
clrAltBg  = color.new(#152238, 25)
clrBorder = color.new(#1E88E5, 60)

var table stats = na
if showStats and barstate.islast
    if na(stats)
        stats := table.new(f_pos(statsPosStr), 2, 6, bgcolor = clrRowBg, border_width = 1, border_color = clrBorder, frame_color = clrBorder, frame_width = 1)

    table.cell(stats, 0, 0, "GRID BACKTEST RESULTS", text_color = color.white, text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)
    table.cell(stats, 1, 0, "—",                     text_color = clrHdrBg,   text_size = size.normal, bgcolor = clrHdrBg, text_halign = text.align_center)

    table.cell(stats, 0, 1, "Net P&L",  text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 1, (np >= 0 ? "+" : "") + str.tostring(np, "0.00") + "  (" + (npPct >= 0 ? "+" : "") + str.tostring(npPct, "0.00") + "%)",
         text_color = np >= 0 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 2, "Max Drawdown", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 2, str.tostring(dd, "0.00") + "  (" + str.tostring(ddPct, "0.00") + "%)",
         text_color = clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 3, "Grid Fills", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 3, str.tostring(nTrades), text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

    table.cell(stats, 0, 4, "Win Rate", text_color = clrNeutral, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_left)
    table.cell(stats, 1, 4, str.tostring(wrPct, "0.00") + "%  (" + str.tostring(wins) + "/" + str.tostring(nTrades) + ")",
         text_color = wrPct >= 50 ? clrPos : clrNeg, text_size = size.normal, bgcolor = clrAltBg, text_halign = text.align_right)

    table.cell(stats, 0, 5, "Profit Factor", text_color = clrNeutral, text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_left)
    table.cell(stats, 1, 5, str.tostring(pf, "0.000"), text_color = pf >= 1.5 ? clrPos : (pf >= 1.0 ? clrNeutral : clrNeg), text_size = size.normal, bgcolor = clrRowBg, text_halign = text.align_right)

// =====================================================================
//                          BRAND WATERMARK
// =====================================================================
var table wm = na
if showWM and barstate.islast
    if na(wm)
        wm := table.new(f_pos(wmPosStr), 1, 1, bgcolor = color.new(color.black, 100), border_width = 0)
    table.cell(wm, 0, 0, wmText, text_color = color.new(color.white, wmAlpha), text_size = f_size(wmSizeStr), bgcolor = color.new(color.black, 100))

// =====================================================================
//                          WEBHOOK ALERTS
// =====================================================================
gridStartMsg = '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","action":"grid_start","pair":"' + pairLabel + '"}'

var bool startedNotified = false
if (not startedNotified) and inWindow and barstate.isconfirmed
    alert(gridStartMsg, alert.freq_once_per_bar_close)
    startedNotified := true
````
