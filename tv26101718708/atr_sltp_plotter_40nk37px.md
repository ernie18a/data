# ATR SL/TP Plotter

- url: https://www.tradingview.com/script/40NK37PX-ATR-SL-TP-Plotter/
- type: indicator
- pine_id: PUB;0c469ebb7d934951a39a6603209b23cf
- version: 1.0

## Description

[b]ATR SL/TP Plotter[/b] is a visual risk-management overlay that turns a single ATR reading and a user-defined risk percentage into a complete trade plan: one entry line, one Stop Loss, three scalable Take Profit targets, a shaded reward-versus-risk diagram, and the exact position size that keeps loss exposure equal to the chosen percentage of account balance. Every level is recomputed each bar from volatility rather than from a fixed pip distance, so the plan adapts to regime changes automatically.

[b]Why This Combination[/b]

This indicator ties four elements that are commonly handled by separate tools into a single overlay:

[list]
[*]An ATR-driven stop that scales with current volatility, not with a fixed pip input.
[*]Three independent Take Profit targets (TP1 / TP2 / TP3) so a partial-exit ladder can be modelled directly on the chart.
[*]A visibly-shaded Risk:Reward box — red for the risk leg (entry to SL), green for the reward leg (entry to TP1, with lighter shading out to TP3) — so the geometric R:R is legible before any number is read.
[*]A position-size calculator that consumes the same ATR-based SL distance together with account balance and risk percentage, so the size shown is internally consistent with the drawn stop.
[/list]

Keeping these four pieces in one script ensures that the SL distance used to draw the stop and the SL distance used to size the position are always the same value.

[b]What It Does[/b]

[list]
[*]Detects trade direction automatically via an EMA(20) / EMA(50) state on the previous bar, or accepts a manual Long / Short override.
[*]Computes SL = entry ± ATR × SL-multiplier, and TP1 / TP2 / TP3 = entry ± ATR × their respective multipliers.
[*]Draws entry, SL, and three TP lines with labels; optionally repeats the drawing on the last N bars for history.
[*]Draws a filled Risk:Reward box on the last bar with distinct shading for the SL zone and each TP zone.
[*]Computes position size as (account balance × risk %) / SL distance and displays it on a compact dashboard together with entry price, SL price, ATR value, R:R ratio (TP1 over SL), TP1/TP2/TP3 prices, and the risk amount in account currency.
[*]Fires alerts when the EMA-based auto direction flips to Long or to Short.
[/list]

[b]How It Works[/b]

[b]Direction[/b]

In Auto mode, direction is Long when EMA(20) is greater than EMA(50) evaluated on [i]close[1][/i] (the previously closed bar), and Short otherwise. Using the closed bar avoids the flicker that comes from evaluating EMAs on a still-forming bar. The Long / Short inputs bypass the EMA state entirely for discretionary setups.

[b]Levels[/b]

ATR is Pine's built-in [i]ta.atr(period)[/i]. For a Long trade the SL sits ATR × SL-multiplier below the current close, and TP1/TP2/TP3 sit ATR × their multipliers above. For a Short trade the signs are reversed. Because ATR itself is recomputed bar-by-bar, all levels move with current volatility; a quiet range produces tight levels and an expanding range widens them automatically.

[b]Risk:Reward box[/b]

On the last bar the script draws four filled boxes anchored at the current bar_index: one from entry down to SL (red, risk), one from entry to TP1 (solid green, primary reward), one from TP1 to TP2 (lighter green), and one from TP2 to TP3 (lightest green). The R:R label shows (TP1 distance) / (SL distance) — i.e. the conservative reward ratio based on the first target.

[b]Position size[/b]

Risk amount = balance × risk %. Position size = risk amount / SL distance. The number is reported in the same unit as the price series, so on a 5-digit FX chart it reads as price units per one unit of risk currency; on a stock chart it reads as share count that would lose exactly the risk amount if the stop is hit. The calculation intentionally does not attempt to convert across account currencies — that depends on the user's broker and is better handled externally.

[b]Non-repainting behaviour[/b]

Direction comes from [i]close[1][/i] so it does not flip intrabar. The SL/TP levels themselves do update with the current close, which is the correct behaviour for a live risk-management overlay — freezing them to a past close would hide real changes in the volatility environment.

[b]How To Use[/b]

[list=1]
[*]Add the indicator to the chart you want to trade. The default ATR(14) with SL ×1.5 and TP ×1 / ×2 / ×3 is a neutral starting point for most liquid markets.
[*]Read the Risk:Reward box first. If the green reward zone to TP1 is visibly smaller than the red risk zone, the trade's geometric R:R is below 1:1 — usually a reason to wait or widen the target.
[*]Tune the multipliers to your style. Tighter entries (for range trades or scalps) often use SL ×1.0 with TP ×1 / ×1.5 / ×2. Longer swings typically widen SL to ×2 and push TP3 out to ×4 or ×5.
[*]Enter the same balance and risk percentage you actually use. The dashboard's Size field is only meaningful when those two inputs reflect your real account.
[*]Override direction manually when you have a discretionary thesis that conflicts with the EMA reading — this is what the Long / Short modes are for.
[*]Combine with your own entry trigger. This tool does not decide [i]when[/i] to enter; it only describes what the trade plan looks like once you have decided.
[/list]

[b]Settings[/b]

[list]
[*][b]Direction[/b] — Auto / Long / Short.
[*][b]Show on[/b] — Last Bar Only, or Last N Bars (1–20).
[*][b]ATR Period[/b] — Default 14.
[*][b]SL Multiplier[/b] — Default 1.5, range 0.5–5.0.
[*][b]TP1 / TP2 / TP3 Multiplier[/b] — Defaults 1.0 / 2.0 / 3.0, each 0.1–10.0.
[*][b]Account Balance[/b] — Default 10,000 in account currency.
[*][b]Risk %[/b] — Default 1.0%, range 0.1–10.0.
[*][b]Table Position / Size[/b] — Nine positions, three sizes.
[*][b]Show R:R Box / Show TP/SL Lines[/b] — Independent toggles.
[/list]

[b]Alerts[/b]

[list]
[*][b]Direction: Long[/b] — fires when auto-detected direction flips from Short to Long.
[*][b]Direction: Short[/b] — fires when auto-detected direction flips from Long to Short.
[/list]

[b]Limitations[/b]

[list]
[*]This is a visualisation and sizing tool. It does not forecast price direction, does not place orders, and does not guarantee any outcome.
[*]The SL and TP levels are ATR-based geometric plots of where a stop or target [i]would[/i] sit — they are not executed orders. Actual fills depend on broker spread, slippage, and execution, none of which this script models.
[*]The auto-direction flag is an EMA(20)/EMA(50) state on the previous bar. It is a simple bias indicator, not a trade entry signal, and can lag sharply after fast reversals; use the Long/Short manual override when the EMA reading disagrees with your own analysis.
[*]SL/TP multipliers are fixed scalars on ATR — they do not adapt per regime. In gap-prone or news-driven markets the same ATR × SL multiplier can be too tight (stopped out on noise) or too wide (unfavourable R:R). Tune the multipliers to the instrument and session.
[*]Position size is computed as risk amount divided by SL distance in price units. It does not convert across account currencies, does not include commission or swap, and assumes the SL fills exactly at the plotted price.
[*]ATR needs at least [i]ATR Period[/i] bars of history to produce a stable reading; on newly listed symbols or very short histories, early bars will show degraded or N/A ATR values.
[/list]

[b]Disclaimer[/b]

This is a risk-management visualisation tool. It does not generate trade signals, does not place orders, and does not guarantee any outcome. Users remain fully responsible for entry decisions, broker execution, and the accuracy of account-balance and risk inputs.

## Source Code

````pine
// ============================================================================
// ATR SL/TP Plotter — Visual Risk Management Tool
// ============================================================================
//
// WHAT IT DOES:
//   Automatically calculates and displays Stop Loss, Take Profit levels (3 TPs),
//   Risk:Reward ratio, and position sizing based on ATR volatility.
//   Includes a visual R:R box and a compact info dashboard.
//
// HOW IT WORKS:
//   1. Detects trade direction via EMA(20)/EMA(50) crossover (or manual override)
//   2. Calculates ATR-based SL/TP levels with configurable multipliers
//   3. Draws entry, SL, TP1/TP2/TP3 lines and R:R visualization box
//   4. Computes position size based on account balance and risk percentage
//
// NON-REPAINTING:
//   Auto direction uses close[1] (previous confirmed bar) for EMA calculation.
//   SL/TP levels update with the current close — this is expected behavior
//   for a real-time risk management tool.
//
// ============================================================================

//@version=6
indicator("ATR SL/TP Plotter", overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=100)

// ============================================================================
// Color Constants
// ============================================================================

var color C_BUY        = #26a69a
var color C_SELL       = #ef5350
var color C_NEUTRAL_UI = #787b86
var color C_WHITE      = #d1d4dc
var color C_PANEL_BG   = color.new(#131722, 0)
var color C_HEADER_BG  = color.new(#1e222d, 0)
var color C_ROW_BG     = color.new(#16191e, 0)
var color C_ROW_BG2    = color.new(#1a1e27, 0)
var color C_TP_BG      = color.new(#26a69a, 85)
var color C_SL_BG      = color.new(#ef5350, 85)

// ============================================================================
// User Inputs
// ============================================================================

// --- Trade Setup ---
i_direction   = input.string("Auto", "Direction", options=["Auto", "Long", "Short"], group="Trade Setup", tooltip="Auto detects direction using EMA 20/50 crossover. Manual overrides with Long or Short.")
i_showMode    = input.string("Last Bar Only", "Show on", options=["Last Bar Only", "Last N Bars"], group="Trade Setup", tooltip="Display SL/TP lines on the last bar only, or on the last N bars.")
i_nBars       = input.int(5, "N Bars", minval=1, maxval=20, group="Trade Setup", tooltip="Number of recent bars to display levels on (when 'Last N Bars' is selected).")

// --- ATR Settings ---
i_atrPeriod   = input.int(14, "ATR Period", minval=1, maxval=100, group="ATR Settings", tooltip="Lookback period for Average True Range calculation.")
i_slMult      = input.float(1.5, "SL Multiplier", minval=0.5, maxval=5.0, step=0.1, group="ATR Settings", tooltip="ATR multiplier for Stop Loss distance from entry.")
i_tp1Mult     = input.float(1.0, "TP1 Multiplier", minval=0.1, maxval=10.0, step=0.1, group="ATR Settings", tooltip="ATR multiplier for Take Profit 1.")
i_tp2Mult     = input.float(2.0, "TP2 Multiplier", minval=0.1, maxval=10.0, step=0.1, group="ATR Settings", tooltip="ATR multiplier for Take Profit 2.")
i_tp3Mult     = input.float(3.0, "TP3 Multiplier", minval=0.1, maxval=10.0, step=0.1, group="ATR Settings", tooltip="ATR multiplier for Take Profit 3.")

// --- Position Sizing ---
i_balance     = input.float(10000, "Account Balance", minval=100, group="Position Sizing", tooltip="Your account balance in account currency for position size calculation.")
i_riskPct     = input.float(1.0, "Risk %", minval=0.1, maxval=10.0, step=0.1, group="Position Sizing", tooltip="Percentage of account to risk per trade.")

// --- Display ---
i_tablePos    = input.string("Top Right", "Table Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Display", tooltip="Dashboard table position on the chart.")
i_tableSize   = input.string("Small", "Table Size", options=["Small", "Normal", "Large"], group="Display", tooltip="Font size for the dashboard table.")
i_showRRBox   = input.bool(true, "Show R:R Box", group="Display", tooltip="Display colored risk/reward boxes on the chart.")
i_showLines   = input.bool(true, "Show TP/SL Lines", group="Display", tooltip="Display entry, SL, and TP level lines on the chart.")

// ============================================================================
// Helper Functions
// ============================================================================

f_tablePos(pos) =>
    switch pos
        "Top Left"       => position.top_left
        "Top Center"     => position.top_center
        "Top Right"      => position.top_right
        "Middle Left"    => position.middle_left
        "Middle Center"  => position.middle_center
        "Middle Right"   => position.middle_right
        "Bottom Left"    => position.bottom_left
        "Bottom Center"  => position.bottom_center
        "Bottom Right"   => position.bottom_right

f_tableSize(sz) =>
    switch sz
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large

f_formatPrice(val) =>
    str.tostring(val, format.mintick)

// ============================================================================
// Core Calculations
// ============================================================================

ema20 = ta.ema(close[1], 20)
ema50 = ta.ema(close[1], 50)

direction = switch i_direction
    "Long"  =>  1
    "Short" => -1
    =>  nz(ema20) > nz(ema50) ? 1 : -1

prevDirection = switch i_direction
    "Long"  =>  1
    "Short" => -1
    =>  nz(ta.ema(close[2], 20)) > nz(ta.ema(close[2], 50)) ? 1 : -1

dirChanged = direction != prevDirection

atrValue = nz(ta.atr(i_atrPeriod))

entry = close
slDist = atrValue * i_slMult

sl  = direction == 1 ? entry - slDist : entry + slDist
tp1 = direction == 1 ? entry + atrValue * i_tp1Mult : entry - atrValue * i_tp1Mult
tp2 = direction == 1 ? entry + atrValue * i_tp2Mult : entry - atrValue * i_tp2Mult
tp3 = direction == 1 ? entry + atrValue * i_tp3Mult : entry - atrValue * i_tp3Mult

rrRatio  = slDist > 0 ? (atrValue * i_tp1Mult) / slDist : 0.0
riskAmt  = i_balance * i_riskPct / 100.0
posSize  = slDist > 0 ? riskAmt / slDist : 0.0

// ============================================================================
// Drawing Objects — Lines & Labels
// ============================================================================

var line[] lineArr  = array.new_line()
var label[] lblArr  = array.new_label()
var box[] boxArr    = array.new_box()

// Clean up old drawings each bar
if array.size(lineArr) > 0
    for i = array.size(lineArr) - 1 to 0
        line.delete(array.get(lineArr, i))
    array.clear(lineArr)

if array.size(lblArr) > 0
    for i = array.size(lblArr) - 1 to 0
        label.delete(array.get(lblArr, i))
    array.clear(lblArr)

if array.size(boxArr) > 0
    for i = array.size(boxArr) - 1 to 0
        box.delete(array.get(boxArr, i))
    array.clear(boxArr)

// Determine if we should draw on this bar
showOnBar = i_showMode == "Last Bar Only" ? barstate.islast : (bar_index >= last_bar_index - i_nBars + 1)

if i_showLines and showOnBar
    int leftIdx  = bar_index - 1
    int rightIdx = bar_index + 1
    int lblIdx   = bar_index + 9
    // Entry
    array.push(lineArr, line.new(leftIdx, entry, rightIdx, entry, color=C_WHITE, style=line.style_solid, width=2))
    array.push(lblArr, label.new(lblIdx, entry, "Entry " + f_formatPrice(entry), color=color.new(color.white, 100), textcolor=C_WHITE, style=label.style_label_left, size=size.small))
    // SL
    array.push(lineArr, line.new(leftIdx, sl, rightIdx, sl, color=C_SELL, style=line.style_dashed, width=2))
    array.push(lblArr, label.new(lblIdx, sl, "SL " + f_formatPrice(sl), color=color.new(color.white, 100), textcolor=C_SELL, style=label.style_label_left, size=size.small))
    // TP1
    array.push(lineArr, line.new(leftIdx, tp1, rightIdx, tp1, color=C_BUY, style=line.style_solid, width=2))
    array.push(lblArr, label.new(lblIdx, tp1, "TP1 " + f_formatPrice(tp1), color=color.new(color.white, 100), textcolor=C_BUY, style=label.style_label_left, size=size.small))
    // TP2
    array.push(lineArr, line.new(leftIdx, tp2, rightIdx, tp2, color=C_BUY, style=line.style_dashed, width=1))
    array.push(lblArr, label.new(lblIdx, tp2, "TP2 " + f_formatPrice(tp2), color=color.new(color.white, 100), textcolor=C_BUY, style=label.style_label_left, size=size.small))
    // TP3
    array.push(lineArr, line.new(leftIdx, tp3, rightIdx, tp3, color=C_BUY, style=line.style_dotted, width=1))
    array.push(lblArr, label.new(lblIdx, tp3, "TP3 " + f_formatPrice(tp3), color=color.new(color.white, 100), textcolor=C_BUY, style=label.style_label_left, size=size.small))

// ============================================================================
// R:R Box (Last Bar Only)
// ============================================================================

if i_showRRBox and barstate.islast
    int boxLeft  = bar_index - 2
    int boxRight = bar_index + 8
    // Risk box (SL zone)
    array.push(boxArr, box.new(boxLeft, entry, boxRight, sl, border_color=C_SELL, bgcolor=C_SL_BG, border_width=1))
    // Reward box — TP1 zone
    array.push(boxArr, box.new(boxLeft, entry, boxRight, tp1, border_color=C_BUY, bgcolor=C_TP_BG, border_width=1))
    // Reward box — TP2 zone (TP1 to TP2)
    array.push(boxArr, box.new(boxLeft, tp1, boxRight, tp2, border_color=C_BUY, bgcolor=color.new(C_BUY, 92), border_width=1))
    // Reward box — TP3 zone (TP2 to TP3)
    array.push(boxArr, box.new(boxLeft, tp2, boxRight, tp3, border_color=C_BUY, bgcolor=color.new(C_BUY, 95), border_width=1))
    // R:R label (centered outside TP3 box — above for Long, below for Short)
    int boxCenter = math.round((boxLeft + boxRight) / 2)
    string rrText = "R:R " + str.tostring(rrRatio, "#.#") + ":1"
    var lblStyle = label.style_label_down
    if direction == 1
        lblStyle := label.style_label_down
    else
        lblStyle := label.style_label_up
    array.push(lblArr, label.new(boxCenter, tp3, rrText, color=color.new(color.white, 100), textcolor=C_BUY, style=lblStyle, size=size.normal))

// ============================================================================
// Dashboard Table
// ============================================================================

var table dashboard = table.new(f_tablePos(i_tablePos), 4, 7, bgcolor=C_PANEL_BG, border_width=1, border_color=color.new(#2a2e39, 0), frame_width=1, frame_color=color.new(#2a2e39, 0))

if barstate.islast
    tSize = f_tableSize(i_tableSize)
    dirText  = direction == 1 ? "LONG" : "SHORT"
    dirColor = direction == 1 ? C_BUY : C_SELL

    // Row 0: Header (merged across 4 columns)
    table.cell(dashboard, 0, 0, "𝗔𝗧𝗥 𝗦𝗟/𝗧𝗣", text_color=C_WHITE, text_size=tSize, bgcolor=C_HEADER_BG)
    table.merge_cells(dashboard, 0, 0, 3, 0)

    // Row 1: Direction banner (merged)
    table.cell(dashboard, 0, 1, dirText, text_color=dirColor, text_size=size.huge, bgcolor=C_PANEL_BG)
    table.merge_cells(dashboard, 0, 1, 3, 1)

    // Row 2: Entry | price | ATR | value
    table.cell(dashboard, 0, 2, "Entry",                  text_color=C_NEUTRAL_UI, text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 1, 2, f_formatPrice(entry),     text_color=C_WHITE,      text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 2, 2, "ATR",                    text_color=C_NEUTRAL_UI, text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 3, 2, f_formatPrice(atrValue),  text_color=C_WHITE,      text_size=tSize, bgcolor=C_ROW_BG)

    // Row 3: SL | price | Risk | $XX
    table.cell(dashboard, 0, 3, "SL",                     text_color=C_SELL,       text_size=tSize, bgcolor=C_ROW_BG2)
    table.cell(dashboard, 1, 3, f_formatPrice(sl),        text_color=C_SELL,       text_size=tSize, bgcolor=C_ROW_BG2)
    table.cell(dashboard, 2, 3, "Risk",                   text_color=C_NEUTRAL_UI, text_size=tSize, bgcolor=C_ROW_BG2)
    table.cell(dashboard, 3, 3, "$" + str.tostring(riskAmt, "#.##"), text_color=C_SELL, text_size=tSize, bgcolor=C_ROW_BG2)

    // Row 4: TP1 | price | R:R | ratio
    table.cell(dashboard, 0, 4, "TP1",                    text_color=C_BUY,        text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 1, 4, f_formatPrice(tp1),       text_color=C_BUY,        text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 2, 4, "R:R",                    text_color=C_NEUTRAL_UI, text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 3, 4, str.tostring(rrRatio, "#.#") + ":1", text_color=C_BUY, text_size=tSize, bgcolor=C_ROW_BG)

    // Row 5: TP2 | price | TP3 | price
    table.cell(dashboard, 0, 5, "TP2",                    text_color=C_BUY,        text_size=tSize, bgcolor=C_ROW_BG2)
    table.cell(dashboard, 1, 5, f_formatPrice(tp2),       text_color=C_BUY,        text_size=tSize, bgcolor=C_ROW_BG2)
    table.cell(dashboard, 2, 5, "TP3",                    text_color=C_BUY,        text_size=tSize, bgcolor=C_ROW_BG2)
    table.cell(dashboard, 3, 5, f_formatPrice(tp3),       text_color=C_BUY,        text_size=tSize, bgcolor=C_ROW_BG2)

    // Row 6: Size | lots/units | Risk% | value
    table.cell(dashboard, 0, 6, "Size",                   text_color=C_NEUTRAL_UI, text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 1, 6, str.tostring(posSize, "#.##"), text_color=C_WHITE,  text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 2, 6, "Risk%",                  text_color=C_NEUTRAL_UI, text_size=tSize, bgcolor=C_ROW_BG)
    table.cell(dashboard, 3, 6, str.tostring(i_riskPct, "#.#") + "%", text_color=C_WHITE, text_size=tSize, bgcolor=C_ROW_BG)

// ============================================================================
// Alert Conditions
// ============================================================================

alertcondition(dirChanged and direction == 1, "Direction: Long", "Trade direction changed to LONG — {{ticker}} {{interval}}")
alertcondition(dirChanged and direction == -1, "Direction: Short", "Trade direction changed to SHORT — {{ticker}} {{interval}}")

// ============================================================================
// END
// ============================================================================
````
