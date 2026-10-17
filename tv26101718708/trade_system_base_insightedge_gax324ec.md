# Trade System Base [InsightEdge]

- url: https://www.tradingview.com/script/GaX324Ec-Trade-System-Base-InsightEdge/
- type: indicator
- pine_id: PUB;18fcf9141e6c4bbabfb7c6959de45218
- version: 1.0

## Description

Trade System Base [InsightEdge]

Starter chart script for the published Trade System library (InsightEdge / TradeSystem / 1).

This indicator does not generate its own setups. You replace the signal block with your rules. The library then creates limit orders, monitors fills and exits, draws risk boxes, and updates the trade table.

═══════════════════════════════════════
HOW TO USE
═══════════════════════════════════════

1. Add this script to your chart.
2. Open the source and find the YOUR SIGNAL section.
3. Set createBuy / buyEntry / buyStop and createSell / sellEntry / sellStop from your logic.
4. Keep this order every bar: create (or cancel) → monitor → updateTable.
5. Tune Window, Trade Monitor, Orders, Trade Table, and Fill Label in the settings.

The script imports:

    import InsightEdge/TradeSystem/1 as ts

The library must already be published under InsightEdge. If you use a fork under another account, change only the username in that import.

═══════════════════════════════════════
WHAT THE LIBRARY DOES
═══════════════════════════════════════

• Creates limit buys and sells from the prices you pass in
• Buy fills when a later bar trades down to entry; sell fills when a later bar trades up to entry
• The create bar itself cannot fill
• Monitors stop, 1R / 2R / 3R targets, optional break-even, expiry, and max-stop skip
• Draws waiting and open trade boxes, entry/stop/target lines, and optional fill labels
• Builds a configurable stats table (created, filled, win rate, P/L model, and more)

═══════════════════════════════════════
ENTRY AND STOP MODEL
═══════════════════════════════════════

• Buy entry = entry + entry buffer
• Sell entry = entry − entry buffer
• Buy stop = stop − stop buffer
• Sell stop = stop + stop buffer
• Invalid risk (distance ≤ 0) is skipped and not monitored
• Dollar rows use the script’s lot-size model; they are not a broker statement

═══════════════════════════════════════
TRADE MONITOR
═══════════════════════════════════════

Fills, stops, and targets are tested on the Trade Monitor timeframe. Leave it blank to use the chart timeframe. Turn Use Unfinished Candle on to include the forming monitor bar, or off to wait for that bar to close.

═══════════════════════════════════════
NOTES
═══════════════════════════════════════

• One create per side per bar
• create and cancel for the same side should not both be true on one bar
• Results are a model of these rules, not live broker fills
• For education and research only. Past results do not guarantee future results.

Author: InsightEdge
Library: InsightEdge/TradeSystem/1
Version: Base template 1.0.0

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © InsightEdge

//@version=6
//@description Starter chart script for the published Trade System library. Wire your own buy and sell signals, then let the library create limit orders, monitor fills and exits, and update the stats table. Results are a model of these rules, not broker fills and not a promise of profit.

// ============================================================================
// TRADE SYSTEM BASE — InsightEdge
// ============================================================================
//
// OWNER / USERNAME
// ================
// Author: InsightEdge
// TradingView username: InsightEdge
// Library: InsightEdge/TradeSystem/1
// This file: chart indicator template that imports that library
//
// WHAT THIS FILE IS
// =================
// A ready chart script. It does not invent setups. You replace the signal
// block below with your own rules, then call create, monitor, and updateTable
// through the published library.
//
// The library (TradeSystem.pine) must already be published on TradingView under
// the InsightEdge account. Publication title for the library is Trade System.
// Import path used here:
//
//     import InsightEdge/TradeSystem/1 as ts
//
// If you fork the library under another account, change InsightEdge in that
// import line to your username. Keep the /1 version until you publish a newer
// library version and intentionally bump it.
//
// HOW TO COPY AND USE
// ===================
// 1. Open TradingView → Pine Editor.
// 2. Create a new indicator (or open this file) and paste the full contents.
// 3. Confirm the first lines show:
//        //@version=6
//        indicator("Trade System Base [InsightEdge]", ...)
//        import InsightEdge/TradeSystem/1 as ts
// 4. Save, then Add to chart.
// 5. In the signal block (marked YOUR SIGNAL below), set:
//        createBuy / buyEntry / buyStop
//        createSell / sellEntry / sellStop
//    Optional: cancelBuy / cancelSell to drop a same-bar waiting order.
// 6. Keep this call order every bar:
//        create (or cancel) → monitor → updateTable
// 7. Adjust Window, Trade Monitor, Orders, Trade Table, and Fill Label inputs
//    from the chart settings panel. Those values are packed into ts.TradeSettings.
//
// LIBRARY API USED HERE
// =====================
// ts.newManager()
//     One manager per script. Keep it in a var.
// tm.create(cfg, side, entryPx, stopPx)
//     Creates a limit. Buy fills when a later bar trades down to entry.
//     Sell fills when a later bar trades up to entry.
//     The create bar itself cannot fill.
// tm.created(side)
//     True if that side was already created on this bar.
// tm.cancel(side)
//     Removes a waiting order created on this bar only.
// tm.monitor(cfg, atr, high, low)
//     Tests fills, stops, and targets against the monitor candle.
// tm.updateTable(cfg)
//     Draws the stats table. Call once per bar.
//
// ENTRY AND STOP RULES (LIBRARY)
// ==============================
// Buy entry  = entryPx + entry buffer
// Sell entry = entryPx - entry buffer
// Buy stop   = stopPx  - stop buffer
// Sell stop  = stopPx  + stop buffer
// Invalid distance (risk <= 0) is skipped and not monitored.
// Targets default to 1R / 2R / 3R from risk unless your script overwrites
// the trade's tp fields after create while the trade is still WAITING.
//
// TRADE MONITOR
// =============
// The library cannot call request.security(). This chart script loads the
// monitor timeframe and passes high/low into tm.monitor().
// Leave Trade Monitor Timeframe blank to use the chart timeframe.
// Use Unfinished Candle On = forming monitor bar; Off = last closed monitor bar.
//
// LIMITATIONS
// ===========
// • This is a rules model, not a broker fill log.
// • One create per side per bar is enforced by the library.
// • create and cancel for the same side should not both be true on one bar.
// • Past results do not guarantee future results. For education and research only.
//
// VERSION
// =======
// Base template 1.0.0 — pairs with InsightEdge/TradeSystem/1
//
// ============================================================================

indicator("Trade System Base [InsightEdge]", shorttitle = "Trades", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)
import InsightEdge/TradeSystem/1 as ts

// ─── Window ───────────────────────────────────────────────────────────────────
string group_window = "Window"
int lookback_bars = input.int(0, "Lookback Bars", minval = 0, group = group_window, tooltip = "Only track bars inside this distance from the last bar. 0 uses the full chart. The table still draws on the last bar.")

string group_monitor = "Trade Monitor"
string monitor_tf = input.timeframe("", "Trade Monitor Timeframe", group = group_monitor, tooltip = "Timeframe whose candles test fills, stops, and targets. Leave it on the chart timeframe, or pick a lower one for a tighter read.")
bool use_unfinished = input.bool(false, "Use Unfinished Candle", group = group_monitor, tooltip = "On uses the forming monitor candle (candle 0). Off uses the last closed monitor candle (candle 1).")

// ─── Orders ───────────────────────────────────────────────────────────────────
string group_trade = "Orders"
bool  show_visuals    = input.bool(true, "Show Trade Drawings", group = group_trade)
bool  show_grayed     = input.bool(true, "Waiting Orders", inline = "pnlv", group = group_trade, tooltip = "Entry-to-stop box while the limit is waiting for a fill.")
bool  show_active     = input.bool(true, "Open Orders", inline = "pnlv", group = group_trade, tooltip = "Entry, stop, and target drawings after the fill.")
bool  hide_closed     = input.bool(true, "Hide Closed", inline = "pnlv", group = group_trade, tooltip = "Remove drawings when the trade ends at the stop, the last enabled target, or break-even.")
bool  show_box_text   = input.bool(true, "Box Text", inline = "pnltxt", group = group_trade, tooltip = "Side, entry, and stop written inside the risk box.")
color text_color      = input.color(#FFFFFFD9, "Text", inline = "pnltxt", group = group_trade, active = show_box_text)
string text_size      = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "pnltxt", group = group_trade, active = show_box_text)
color gray_fill       = input.color(#787B862E, "Waiting Fill", inline = "gpnl", group = group_trade)
color gray_border     = input.color(#787B8673, "Waiting Border", inline = "gpnl", group = group_trade)
bool  hide_buys       = input.bool(false, "Hide Buy Drawings", group = group_trade, tooltip = "Long stats still update.")
bool  hide_sells      = input.bool(false, "Hide Sell Drawings", group = group_trade, tooltip = "Short stats still update.")
float static_tp_pips  = input.float(0, "Static Target (Pips)", minval = 0, step = 0.1, group = group_trade, tooltip = "Count a static win when favorable travel reaches this many pips before the original stop. Break-even closes are left out. 0 turns it off. Forex uses 10x mintick as one pip.")
float sl_buffer_pips  = input.float(0, "Stop Buffer (Pips)", minval = 0, step = 0.1, group = group_trade, tooltip = "Extra distance beyond the stop you pass in. Buy stop = stop - buffer. Sell stop = stop + buffer.")
float entry_buffer_pips = input.float(0, "Entry Buffer (Pips)", minval = 0, step = 0.1, inline = "buf", group = group_trade, tooltip = "Buy entry = entry + buffer. Sell entry = entry - buffer.")
float tp_buffer_pips  = input.float(0, "Target Buffer (Pips)", minval = 0, step = 0.1, inline = "buf", group = group_trade, tooltip = "Pulls each target back toward the entry.")
float max_sl_pips     = input.float(0, "Max Stop (Pips)", minval = 0, step = 0.1, group = group_trade, tooltip = "Skip the order when the stop is wider than this. 0 means no limit. Skipped orders are not monitored.")
bool  expire_by_age   = input.bool(false, "Expire Waiting Orders", group = group_trade, tooltip = "Cancel an unfilled order after the age limit, measured from create().")
float expire_hours    = input.float(24, "Expire After (Hours)", minval = 0.1, step = 0.5, group = group_trade, active = expire_by_age)
bool  be_enabled      = input.bool(false, "Move Stop to Entry", inline = "be", group = group_trade, tooltip = "After this much favorable travel, the stop moves to the entry.")
bool  be_not_sl       = input.bool(true, "Break-even Is Not a Loss", inline = "be", group = group_trade, tooltip = "A break-even close stays on its own row and is left out of wins, losses, and win percent.")
float be_pips         = input.float(10, "Break-even (Pips)", minval = 0, step = 0.1, group = group_trade, active = be_enabled)
float lot_size        = input.float(0.01, "Lot Size", minval = 0.01, step = 0.01, group = group_trade, tooltip = "Scales the dollar rows. At 0.01, a 1.0 price move counts as $1. This is the script's own model, not a broker statement.")

// ─── Table ────────────────────────────────────────────────────────────────────
string group_stats = "Trade Table"
bool   show_table      = input.bool(true, "Show Table", group = group_stats)
string table_title     = input.string("Trades", "Title", group = group_stats, active = show_table)
string table_pos       = input.string("Bottom Right", "Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = group_stats, active = show_table)
string table_size      = input.string("Normal", "Text Size", options = ["Tiny", "Small", "Normal"], group = group_stats, active = show_table)
bool   show_signals    = input.bool(true, "Created", inline = "s1", group = group_stats, active = show_table)
bool   show_activated  = input.bool(true, "Filled", inline = "s1", group = group_stats, active = show_table)
bool   show_fill       = input.bool(false, "Fill %", inline = "s1", group = group_stats, active = show_table, tooltip = "Filled orders divided by created orders.")
bool   show_open       = input.bool(false, "Open", inline = "s1", group = group_stats, active = show_table)
bool   show_winloss    = input.bool(true, "Win / Loss", inline = "s2", group = group_stats, active = show_table)
bool   show_winpct     = input.bool(true, "Win %", inline = "s2", group = group_stats, active = show_table, tooltip = "Wins divided by wins plus losses. Break-even is excluded when Break-even Is Not a Loss is on.")
bool   show_be         = input.bool(false, "Break-even", inline = "s2", group = group_stats, active = show_table)
bool   show_tp1        = input.bool(true, "1:1", inline = "s3", group = group_stats, active = show_table, tooltip = "With 1:2 and 1:3 off, the open box and the winning close stop at 1:1.")
bool   show_tp2        = input.bool(true, "1:2", inline = "s3", group = group_stats, active = show_table, tooltip = "With 1:3 off, the open box and the winning close stop at 1:2.")
bool   show_tp3        = input.bool(false, "1:3", inline = "s3", group = group_stats, active = show_table, tooltip = "The open box and the winning close extend to 1:3.")
bool   show_pnl        = input.bool(true, "P/L $", inline = "s4", group = group_stats, active = show_table)
bool   show_pf         = input.bool(false, "Profit Factor", inline = "s4", group = group_stats, active = show_table)
bool   show_expect     = input.bool(false, "Expectancy $", inline = "s4", group = group_stats, active = show_table)
bool   show_static     = input.bool(false, "Static Target", inline = "s5", group = group_stats, active = show_table)
bool   show_avgpips    = input.bool(false, "Avg Pips", inline = "s5", group = group_stats, active = show_table)
bool   show_expired    = input.bool(false, "Expired", inline = "s5", group = group_stats, active = show_table)
bool   show_skipped    = input.bool(false, "Skipped", inline = "s5", group = group_stats, active = show_table)

// ─── Fill label ───────────────────────────────────────────────────────────────
string group_label = "Fill Label"
bool   show_label   = input.bool(true, "Show", inline = "lb", group = group_label)
string buy_label    = input.string("Buy", "Buy", inline = "lb", group = group_label, active = show_label)
string sell_label   = input.string("Sell", "Sell", inline = "lb", group = group_label, active = show_label)
string label_theme  = input.string("Filled", "Theme", options = ["Filled", "Plain"], inline = "lb2", group = group_label, active = show_label)
string label_size   = input.string("Small", "Size", options = ["Tiny", "Small", "Normal", "Large", "Huge"], inline = "lb2", group = group_label, active = show_label)
float  label_offset = input.float(1.0, "Offset (x ATR)", minval = 0, step = 0.1, group = group_label, active = show_label)

f_settings() =>
    ts.TradeSettings cfg = ts.TradeSettings.new()
    cfg.showTable := show_table
    cfg.showVisuals := show_visuals
    cfg.showGrayed := show_grayed
    cfg.showActive := show_active
    cfg.hideClosed := hide_closed
    cfg.showBoxText := show_box_text
    cfg.textColor := text_color
    cfg.textSize := text_size
    cfg.grayFill := gray_fill
    cfg.grayBorder := gray_border
    cfg.hideBuy := hide_buys
    cfg.hideSell := hide_sells
    cfg.staticTpPips := static_tp_pips
    cfg.slBufferPips := sl_buffer_pips
    cfg.entryBufferPips := entry_buffer_pips
    cfg.tpBufferPips := tp_buffer_pips
    cfg.maxSlPips := max_sl_pips
    cfg.expireByAge := expire_by_age
    cfg.expireHours := expire_hours
    cfg.beEnabled := be_enabled
    cfg.beNotSl := be_not_sl
    cfg.bePips := be_pips
    cfg.lotSize := lot_size
    cfg.tablePos := table_pos
    cfg.tableSize := table_size
    cfg.tableTitle := table_title
    cfg.showSignals := show_signals
    cfg.showActivated := show_activated
    cfg.showFill := show_fill
    cfg.showOpen := show_open
    cfg.showWinLoss := show_winloss
    cfg.showWinPct := show_winpct
    cfg.showBe := show_be
    cfg.showTp1 := show_tp1
    cfg.showTp2 := show_tp2
    cfg.showTp3 := show_tp3
    cfg.showPnlUsd := show_pnl
    cfg.showPf := show_pf
    cfg.showExpect := show_expect
    cfg.showStatic := show_static
    cfg.showAvgPips := show_avgpips
    cfg.showExpired := show_expired
    cfg.showSkipped := show_skipped
    cfg.showEntered := show_label
    cfg.enteredBull := buy_label
    cfg.enteredBear := sell_label
    cfg.enteredSize := label_size
    cfg.enteredOffset := label_offset
    cfg.filledLabels := label_theme == "Filled"
    cfg

// ATR is computed on every bar so the fill-label offset stays stable.
// The monitor timeframe is loaded here. A library cannot call request.security().
float atrNow = ta.atr(14)
[monHigh0, monLow0, monHigh1, monLow1] = request.security(syminfo.tickerid, monitor_tf, [high, low, high[1], low[1]], lookahead = barmerge.lookahead_off)
float monHigh = use_unfinished ? monHigh0 : monHigh1
float monLow = use_unfinished ? monLow0 : monLow1
bool inWindow = lookback_bars <= 0 or bar_index > last_bar_index - lookback_bars
var ts.TradeManager tm = ts.newManager()
ts.TradeSettings cfg = f_settings()

// ─── YOUR SIGNAL ──────────────────────────────────────────────────────────────
// Replace the false flags and na prices with your setup. Keep this order.
// A buy fills when a later bar trades down to buyEntry. Its stop is buyStop.
// A sell fills when a later bar trades up to sellEntry. Its stop is sellStop.
// create and cancel for the same side should not both be true.
// cancel only removes a waiting order created on this bar.
bool createBuy = false
bool cancelBuy = false
float buyEntry = na
float buyStop = na

bool createSell = false
bool cancelSell = false
float sellEntry = na
float sellStop = na

if inWindow and createBuy and not tm.created(ts.TradeSide.BUY)
    tm.create(cfg, ts.TradeSide.BUY, buyEntry, buyStop)
else if inWindow and cancelBuy
    tm.cancel(ts.TradeSide.BUY)

if inWindow and createSell and not tm.created(ts.TradeSide.SELL)
    tm.create(cfg, ts.TradeSide.SELL, sellEntry, sellStop)
else if inWindow and cancelSell
    tm.cancel(ts.TradeSide.SELL)

if inWindow
    tm.monitor(cfg, atrNow, monHigh, monLow)
tm.updateTable(cfg)
````
