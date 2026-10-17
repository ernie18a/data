# [3Commas] Geometric Grid Machine - Indicator

- url: https://www.tradingview.com/script/W5yjoacy-3Commas-Geometric-Grid-Machine-Indicator/
- type: indicator
- pine_id: PUB;13f8e6b1b00e4459a14bd60bf182d071
- version: 1.0

## Description

[3Commas] Geometric Grid Machine — Indicator

🔷 What it does:
This indicator visualizes a geometric grid trading system on liquid range-bound instruments. It pre-computes 56 price levels between a configurable High and Low boundary using geometric spacing (≈ 0.6% step), tracks a virtual deal lifecycle as price crosses through levels, and displays a live on-chart stats card with virtual P&L, drawdown, fill count, win rate, and profit factor. Webhook-ready alerts are exposed for integration with an external grid bot. No orders are placed by the indicator itself — it is a pure signal and visualization layer.

56 geometrically-spaced levels rendered as horizontal lines on chart
Buy / Sell event labels on every close-cross through a grid level
Trailing up shifts grid when price exceeds High + 3% threshold
Virtual P&L tracker matching the Strategy version's accounting
Stats card displaying Grid Fills, Win Rate, Profit Factor live on chart

🔷 Who is it for:
Range-bound market traders who want a visual grid overlay for manual or bot-assisted trading.
Bot operators who automate grid execution through webhook integration with a connected bot.
Free-tier TradingView users who want access to the same grid logic as the Strategy version without requiring backtest functionality.
Volatility harvesters who profit from oscillations rather than directional moves.

🔷 How does it work:
Long Entry Signal: When close crosses down through an unfilled grid level, the indicator marks a Buy fill at that level with a small label on the chart. The level becomes "filled" in the virtual deal state, recording the buy price and quantity for later P&L calculation.
Short Entry: Not used — this is a long-only grid visualizer.
Exit Management: For each filled level, when close crosses up through the next level above, the indicator marks a Sell fill at that target. The virtual P&L for that grid round-trip is computed as (sellLvl − buyLvl) × qty and added to the running stats. The level is reopened for another buy.
Trailing Up: If close exceeds the current High by 3%, the entire grid shifts upward by 50% of the range. Levels recalculate to the new High/Low. Existing filled levels continue tracking their original buy prices — the shift only affects future fills.

🔷 Why it's unique:
Geometric distribution — constant percentage step across the entire range (≈ 0.6% per step in default config) rather than constant absolute spacing. This is structurally fairer when the instrument is far from zero and mirrors the model used by professional grid bots.
Live virtual P&L stats — most grid indicators just draw the lines. This one runs a virtual deal accounting layer that tracks every Buy / Sell pairing and computes realized P&L in real time. The stats card matches the Strategy version's metrics closely (modulo commission, which is not factored in the indicator).
Bot Integration — entry and exit alerts ship with webhook-ready JSON payloads. Two alert events (grid_start on first bar in window, grid_shift_up on trailing event) enable an external bot to mirror state changes.

🔷 What you'll see on the chart:
Red line (top) — Grid High boundary
Green line (bottom) — Grid Low boundary
Aqua lines (middle) — All 54 intermediate grid levels
Aqua "Buy L_X" label — Close crossed down through level X, virtual buy placed
Fuchsia "Sell L_X +N.NN" label — Close crossed up through level X+1, virtual sell with realized P&L
Stats card (top-left, configurable) — Live virtual results: Net P&L, Max Drawdown, Grid Fills, Win Rate, Profit Factor
Orange warning label — Appears if chart is on a timeframe other than the recommended 15m
Watermark (top-right, configurable) — Optional brand text overlay for screenshots

🔷 Considerations Before Using the Indicator:
Market & Timeframe: This indicator is highly timeframe-sensitive and is calibrated for a 15-minute chart. Fill density and overall virtual P&L depend directly on how often close crosses grid levels, which is governed by bar duration. Higher timeframes (1h+) will show far fewer fills; lower timeframes (1m, 5m) increase fills but slow chart performance. The runtime warning label flags any TF other than 15m so you always know whether the displayed stats are comparable to the canonical Strategy version reference.
Limitations: The indicator does not place orders. It tracks a "virtual deal" state on chart for visualization purposes only — actual execution must be done through a connected bot or manually. The strategy carries no stop loss; if price breaks below the grid's Low boundary, all filled levels accumulate unrealized loss in the virtual tracker until either the average is recovered through subsequent bounces or the user manually closes positions. Sustained one-way trends (especially downtrends) will produce maximum drawdown without the trailing-up feature triggering.
Virtual P&L Accuracy: The on-chart stats card uses a simplified internal accounting model — it does not factor exchange commission or slippage. Realized profit is computed as the raw (sellLvl − buyLvl) × qty. Use the Strategy version for fee-adjusted backtest results.
Backtesting & Demo Testing: Always validate the grid range and step size on historical data for the specific instrument you intend to trade. Each instrument has a different volatility profile, and the optimal grid parameters vary accordingly. The companion Strategy version of this script is available on the same profile for full backtest analysis with realistic commissions and slippage.
Parameter Adjustments: Grid range (High/Low) and level count should be re-tuned per instrument volatility. Wider ranges and more levels for highly volatile assets; tighter setups for stable ranges. Trail-up threshold and shift magnitude control how aggressively the grid follows trends — increase threshold for less responsive grids, decrease for more reactive ones.

🔷 Backtest Validation:
This indicator shares identical grid logic with the Strategy version of the same framework, available on this profile for full historical performance review with realistic commission and slippage:
Strategy version: https://www.tradingview.com/script/8N8DT3Pv-Geometric-Grid-Machine-3Commas/
Reference results from the Strategy version on BYBIT:HYPEUSDT.P, 15m chart, tested period Feb 11 — May 13, 2026:
Net Profit: +244.05 USDT (+12.20%)   |   Max Drawdown: 118.35 USDT (5.45%)   |   Total Trades: 1,765   |   Win Rate: 59.04% (1,042 / 1,765)   |   Profit Factor: 1.903
The reference window captures a sideways-to-mildly-bullish phase on HYPE — the structurally ideal regime for grid strategies. Refer to the Strategy publication for the complete equity curve, trade-by-trade breakdown, and Strategy Tester report.

🔷 How to Use It:
🔸 Adjust Settings: Set the grid High and Low boundaries based on the instrument's observed range over the past 1–3 months. Use 50–80 levels for high-volatility altcoins, 30–50 for major pairs. The amount per level should be sized so that filling the entire ladder does not exceed your risk budget. Always confirm you are on a 15-minute chart — the runtime warning label will flag mismatches.
🔸 Visual Confirmation: Use the on-chart grid lines and Buy/Sell labels to verify that the active virtual deal aligns with your bot's actual position. The indicator's virtual deal state is a 1-to-1 mirror of the Strategy version's grid logic (minus commission), so any major divergence between chart visuals and bot position is a flag for investigation.
🔸 Create alerts to trigger the connected bot: Two alert events are exposed by the indicator — "grid_start" fires once when the first bar enters the configured backtest window, and "grid_shift_up" fires every time the trailing-up mechanic moves the grid. Configure both alerts in TradingView with the webhook URL pointing to your bot's signal endpoint. The Bot ID, Email Token, and Pair label can be set in the script's inputs. Note that grid bots are typically configured directly within the bot interface, so these alerts are primarily informational for monitoring purposes.

🔷 INDICATOR SETTINGS
Grid High Price — Upper boundary of the grid range.
Grid Low Price — Lower boundary of the grid range.
Grid Levels — Total number of price levels between Low and High (default 56).
Grid Mode — Distribution of levels: Geometric (constant % spacing) or Arithmetic (constant absolute spacing).
Amount per Level (USDT, ref) — Reference notional for virtual P&L calculation.
Trailing Up — Enable grid shift when price exceeds the High threshold.
Trail Up Threshold % — Percentage above High at which trailing-up triggers.
Shift Up Magnitude % — How much of the current range to shift when trailing-up fires.
Limit by Date Range — Constrain virtual backtest to a specific date window.
Initial Capital (ref for % calc) — Reference capital base for percentage metrics in the stats card.
Show grid lines on chart — Toggle visual display of all level lines.
Show fill labels on chart — Toggle Buy / Sell event labels.
Recommended TF (for warning) — Timeframe baseline for the runtime mismatch warning (default 15m).
Stats card / Watermark — Display layer controls for on-chart virtual backtest summary and branding.

Webhook — Bot ID, Email Token, and Pair label for connected bot signal routing.

👨🏻‍💻💭 We hope this tool helps enhance your trading. Your feedback is invaluable, so feel free to share any suggestions for improvements or new features you'd like to see implemented.
__
The information and publications within the 3Commas TradingView account are not meant to be and do not constitute financial, investment, trading, or other types of advice or recommendations supplied or endorsed by 3Commas and any of the parties acting on behalf of 3Commas, including its employees, contractors, ambassadors, etc.

## Source Code

````pine
//@version=6
// =====================================================================
//  [3Commas] Geometric Grid Machine — Indicator
//  Companion to the Strategy version with identical grid logic.
// ---------------------------------------------------------------------
//  ⚠️ RECOMMENDED TIMEFRAME: 15 minutes
//
//  Identical grid mechanics to the Strategy version:
//    - 56 geometrically-spaced levels between Low (29.73) and High (41.31)
//    - Buy on close-cross-down through unfilled level
//    - Sell on close-cross-up through next level
//    - Trailing up shifts grid when price breaks above High +3%
//
//  Use cases:
//    - Visual signal confirmation for connected grid bot execution
//    - On-chart grid overlay for any pair / range
//    - Live virtual P&L tracker for grid strategies
//
//  Visual layer:
//    - 56 horizontal grid lines (red top, green bottom, aqua middle)
//    - Buy / Sell signal labels on each cross event
//    - Stats card with virtual P&L, DD, Trades, Win Rate, PF
//    - Brand watermark
// =====================================================================

indicator(
     title              = "[3Commas] Geometric Grid Machine — Indicator",
     shorttitle         = "Grid Indicator",
     overlay            = true,
     max_lines_count    = 200,
     max_labels_count   = 500,
     max_bars_back      = 500)

// =====================================================================
//                              INPUTS
// =====================================================================
highPx     = input.float(41.31, "Grid High Price",                    step = 0.01, group = "Grid Range")
lowPx      = input.float(29.73, "Grid Low Price",                     step = 0.01, group = "Grid Range")
levels     = input.int  (56,    "Grid Levels",     minval = 2, maxval = 100,        group = "Grid Range")
gridMode   = input.string("Geometric", "Grid Mode", options = ["Geometric","Arithmetic"], group = "Grid Range")

amountPerLevel = input.float(28.15, "Amount per Level (USDT, ref)", minval = 0.01, step = 0.01, group = "Sizing")

trailUp       = input.bool (true, "Trailing Up — shift grid when price exceeds High", group = "Behavior")
trailUpThr    = input.float(3.0,  "Trail Up Threshold % above High",  minval = 0.1, step = 0.1, group = "Behavior")
trailShiftPct = input.float(50,   "Shift Up Magnitude % of range",    minval = 1, maxval = 100, step = 1, group = "Behavior")

useDates = input.bool(true, "Limit by Date Range",                                                  group = "Backtest Period")
startTs  = input.time(timestamp("2026-02-11 00:00 +0000"), "Start", group = "Backtest Period")
endTs    = input.time(timestamp("2026-05-13 00:00 +0000"), "End",   group = "Backtest Period")
inWindow = (not useDates) or (time >= startTs and time <= endTs)

initCapital = input.float(2000, "Initial Capital (USDT, ref for % calc)", minval = 1, group = "Virtual Backtest")

botId      = input.string("12345678",         "Bot ID",                                      group = "Webhook (Grid Bot)")
emailToken = input.string("YOUR_EMAIL_TOKEN", "Email Token",                                 group = "Webhook (Grid Bot)")
pairLabel  = input.string("USDT_HYPE",        "Pair (Bot format: QUOTE_BASE)",               group = "Webhook (Grid Bot)")

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

// Compute level prices
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
//                       TRAILING UP — shift grid
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
    // --- SELL pass: close crossed up through filled level's sell target ---
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
                    label.new(bar_index, sellLvl, "Sell L" + str.tostring(i) + "\n+" + str.tostring(pnl, "0.00"),
                         style = label.style_label_down, color = color.new(color.fuchsia, 20),
                         textcolor = color.white, size = size.tiny, yloc = yloc.price)

    // --- BUY pass: close crossed down through unfilled level ---
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
gridShiftMsg = '{"message_type":"bot","bot_id":' + botId + ',"email_token":"' + emailToken + '","action":"grid_shift_up","pair":"' + pairLabel + '"}'

var bool startedNotified = false
if (not startedNotified) and inWindow and barstate.isconfirmed
    alert(gridStartMsg, alert.freq_once_per_bar_close)
    startedNotified := true

var float prevHigh = curHigh
if trailUp and curHigh != prevHigh and barstate.isconfirmed
    alert(gridShiftMsg, alert.freq_once_per_bar_close)
    prevHigh := curHigh
````
