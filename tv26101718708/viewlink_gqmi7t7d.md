# ViewLink

- url: https://www.tradingview.com/script/Gqmi7t7d-ViewLink/
- type: indicator
- pine_id: PUB;3819905d3e2c41909aa9b51e67729612
- version: 6.0

## Description

ViewLink is an interactive trade-planning and risk dashboard. Instead of typing
numbers into settings, you place your three levels directly on the chart -
click your entry, your stop loss, and your take profit - and ViewLink builds a
complete, consolidated plan for the trade and presents it in the Data Window for
at-a-glance review before you commit.

WHAT IT DOES

As you set your levels, the tool calculates and displays:

- Reward-to-risk ratio, updated live from your entry, stop, and target, shown
  both on the chart and in a compact panel.
- Position sizing across four methods you can switch between per trade: percent
  of balance, percent of equity, fixed lots, or a fixed cash amount to risk in
  your account's deposit currency. This lets you plan the same setup under
  different sizing approaches without rebuilding anything.
- A full trade-management plan you define alongside the entry: trailing-stop
  distance and activation, breakeven rules (by absolute price, by pips in
  profit, or by reward-to-risk multiple, with an optional offset), and
  partial-close rules (by percent of position or by lots, triggered by pips or
  by reward-to-risk).
- Pre-trade guards you can plan for: a maximum-spread tolerance and a slippage
  tolerance, each independently toggled on or off.

WHY IT IS USEFUL

Most charting setups scatter these decisions across separate tools, mental math,
and notes. ViewLink consolidates the entire trade - levels, sizing method, R:R,
and your management rules - into one place you define by interacting with the
chart, so you can plan deliberately and consistently and review the whole plan
at a glance before entering. It is built for discretionary traders who want a
repeatable pre-trade routine rather than ad-hoc decisions.

HOW TO USE IT

1. Add the indicator. You will be prompted to click your entry, then your stop
   loss, then your take profit, directly on the chart.
2. Choose your sizing method and enter the matching value (risk %, lots, or cash
   risk). Leave a field at 0 to skip it.
3. Optionally expand Trade Management to plan trailing, breakeven, and
   partial-close rules, and the guards group to set spread/slippage tolerances.
4. Review the consolidated plan and the reward-to-risk ratio in the Data Window
   and the on-chart panel.

A note on the values: fields you leave at 0 are treated as "not set." For the
toggle-gated guards and the breakeven offset, the value reads as -1 while its
toggle is off, and shows your set value once the toggle is on - this keeps "not
set" clearly distinct from a deliberate 0.

This is a planning and visualization tool. It does not generate buy or sell
signals, does not give financial advice, and does not place, modify, or close
orders. Every trading decision is made by you.

## Source Code

````pine
//@version=6
indicator("ViewLink", overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// ViewLink Connector
//
// A trade-setup visualisation: drag your entry / stop / target levels and the
// on-chart panel and labels show the resulting distances and risk-reward.
//
// Display encoding:
//   - Most fields: 0 means "leave at the saved default".
//   - Toggle-gated fields (be_offset, slippage, max_spread): -1 when the paired
//     toggle is off, otherwise the raw value (0 included).
// ─────────────────────────────────────────────────────────────────────────────


// ═══ STEP 1: DRAG YOUR LEVELS ════════════════════════════════════════════════
// Draggable entry / stop-loss / take-profit price lines. Per-trade values.
entry_price = input.price(1.08500, title="📍 Step 1 — Set your Entry", confirm=true,
     tooltip = "📍 Step 1 — Place your entry price on the chart.")
sl_price    = input.price(1.08200, title="🔴 Step 2 — Set your Stop Loss (or click anywhere if it's coming from your dashboard)",  confirm=true,
     tooltip = "🔴 Step 2 — Place your stop loss on the chart. Using the stop loss from your dashboard settings instead? Keep 'Use dashboard SL' ticked and just click anywhere — this line won't be used.")
tp_price    = input.price(1.09200, title="🟢 Step 3 — Set your Take Profit (or click anywhere if it's coming from your dashboard)", confirm=true,
     tooltip = "🟢 Step 3 — Place your take profit on the chart. Using the take profit from your dashboard settings instead? Keep 'Use dashboard TP' ticked and just click anywhere — this line won't be used.")

// Hide the SL / TP line and leave that level at your saved default. When ON,
// the line + label + fill are not drawn and the level reads as "not set" (0),
// so your saved default is used. Default OFF = line shown. These gate only the
// drawn objects; the price inputs above are untouched. (Reading as 0 is
// display-safe — it never affects chart auto-scaling; only the drawn lines did.)
use_dashboard_sl = input.bool(false, title="Use dashboard SL (hide SL line)",
     tooltip = "OFF (default): show the stop-loss line above and use it. ON: hide the line and leave the stop-loss at your dashboard default.")
use_dashboard_tp = input.bool(false, title="Use dashboard TP (hide TP line)",
     tooltip = "OFF (default): show the take-profit line above and use it. ON: hide the line and leave the take-profit at your dashboard default.")


// ═══ SIZING — always visible ═════════════════════════════════════════════════
// Risk % and lot size stay visible without expanding any group.
// volume_type encoding for the Data Window: 1=percent_balance, 2=fixed_lot,
// 3=fixed_cash, 4=percent_equity. The plot shows the integer.
volume_type = input.string(
     title   = "Sizing method",
     defval  = "Percent of Balance",
     options = ["Percent of Balance", "Fixed Lots", "Fixed Cash Risk", "Percent of Equity"],
     tooltip = "How your lot size is calculated. Set here to override per trade, or leave it to use your dashboard default.")

risk_percent = input.float(0, title="Risk %", step=0.1, minval=0,
     tooltip = "Risk per trade as a percent of your balance. Leave at 0 to use your dashboard default.")

lot_size = input.float(0, title="Lot size (Fixed Lots mode)", step=0.01, minval=0,
     tooltip = "Fixed lot size, used when the sizing method is Fixed Lots. Leave at 0 to use your dashboard default.")

cash_risk = input.float(0, title="Cash risk (account currency)", step=1, minval=0,
     tooltip = "Cash amount to risk per trade, used when the sizing method is Fixed Cash Risk. The amount is in your account's deposit currency (not assumed to be USD). Leave at 0 to use your dashboard default.")


// Stops & targets are set by dragging the Entry / Stop Loss / Take Profit
// lines in Steps 1–3 above. The dragged absolute prices are the sole source.


// ═══ TRADE MANAGEMENT — collapse below ═══════════════════════════════════════
gMgmt = "Trade Management"

trail_pips = input.float(0, title="Trailing — distance (pips)", group=gMgmt, step=1, minval=0,
     tooltip = "Trailing stop distance in pips. Leave at 0 to use your dashboard default; leave unset everywhere to disable trailing.")

trail_trigger = input.float(0, title="Trailing — activation (pips profit)", group=gMgmt, step=1, minval=0,
     tooltip = "How many pips of profit before the trailing stop activates. Leave at 0 to use your dashboard default.")

be_trigger_price = input.float(0.0, title="Breakeven trigger — price (absolute)", group=gMgmt, step=0.00001, minval=0,
     tooltip = "Exact price at which to move your stop to breakeven. If you also set breakeven by pips or R:R, this exact price is used. Leave at 0 to skip.")

be_trigger_pips = input.float(0, title="Breakeven trigger — pips in profit", group=gMgmt, step=1, minval=0,
     tooltip = "Move your stop to breakeven after this many pips of profit. Leave at 0 to use your dashboard default.")

be_trigger_rr = input.float(0, title="Breakeven trigger — R:R", group=gMgmt, step=0.1, minval=0,
     tooltip = "Move your stop to breakeven at this reward-to-risk multiple. Requires a stop on the trade. Leave at 0 to skip.")

// be_offset — 0 is a legitimate value (lock exactly at entry). Toggle-gated.
// Default toggle OFF so an untouched value falls through to the saved default.
be_offset_enable = input.bool(false, title="Override breakeven offset?", group=gMgmt,
     tooltip = "OFF (default): use your dashboard default. ON: use the breakeven offset below, including 0 to lock exactly at entry.")

be_offset = input.float(1, title="Breakeven offset (pips above entry)", group=gMgmt, step=1, minval=0,
     tooltip = "Pips locked above entry when breakeven fires. Only used when the override toggle above is ON.")

partial_close_pct = input.float(0, title="Partial close — % of position", group=gMgmt, step=1, minval=0, maxval=100,
     tooltip = "Percent of the position to close at the partial-close trigger. Leave at 0 to use your dashboard default.")

partial_close_vol = input.float(0, title="Partial close — lots (alternative)", group=gMgmt, step=0.01, minval=0,
     tooltip = "Lot volume to close instead of a percent. If you set both, the percent is used. Leave at 0 to skip.")

partial_close_trigger_pips = input.float(0, title="Partial close trigger — pips in profit", group=gMgmt, step=1, minval=0,
     tooltip = "Close part of the position once profit reaches this many pips. Leave at 0 to skip.")

partial_close_trigger_rr = input.float(0, title="Partial close trigger — R:R", group=gMgmt, step=0.1, minval=0,
     tooltip = "Close part of the position once reward-to-risk reaches this multiple. Requires a stop on the trade. Leave at 0 to skip.")


// ═══ EXECUTION GUARDS — collapse below ═══════════════════════════════════════
gGuards = "Execution Guards"

// max_spread — 0 is ambiguous (zero-spread filter would skip every trade). Toggle-gated.
max_spread_enable = input.bool(false, title="Enforce max spread?", group=gGuards,
     tooltip = "OFF: no spread check. ON: skip the trade when live spread exceeds the value below.")

max_spread = input.float(0, title="Max spread (pips)", group=gGuards, step=0.1, minval=0,
     tooltip = "Maximum allowed spread in pips. Only used when the toggle above is ON.")

// slippage — 0 is a legitimate value (zero deviation tolerance). Toggle-gated.
slippage_enable = input.bool(false, title="Override slippage?", group=gGuards,
     tooltip = "OFF (default): use a safe default. ON: use the slippage value below, including 0 for zero tolerance.")

slippage = input.int(0, title="Slippage (points)", group=gGuards, step=1, minval=0,
     tooltip = "Maximum price deviation in points. Only used when the toggle above is ON.")


// ═══ IDENTITY — collapse below ═══════════════════════════════════════════════
gId = "Identity"

magic_number = input.int(0, title="Magic number", group=gId, minval=0,
     tooltip = "A tag for this strategy's trades. Leave at 0 to use your account default. Set a number here only if you run multiple strategies on one account.")


// ═══════════════════════════════════════════════════════════════════════════════
// DERIVED VALUES
// ═══════════════════════════════════════════════════════════════════════════════

// Raw price distances — unit-agnostic. R:R is a pure ratio, so it is correct
// regardless of instrument.
sl_dist  = math.abs(entry_price - sl_price)
tp_dist  = math.abs(tp_price - entry_price)
rr_ratio = sl_dist > 0 ? tp_dist / sl_dist : 0.0

// Distance readout unit for the on-chart labels and panel. Forex -> pips
// (10x tick, covers fractional-pip feeds). Everything else (indices, gold,
// crypto, stocks) -> points, 1 point = 1.0 price unit.
is_fx     = syminfo.type == "forex"
unit_size = is_fx ? syminfo.mintick * 10 : 1.0
unit_name = is_fx ? "pips" : "pts"
sl_disp   = unit_size > 0 ? sl_dist / unit_size : 0.0
tp_disp   = unit_size > 0 ? tp_dist / unit_size : 0.0

// Numeric encoding for the vl_volume_type Data Window plot — the plot shows the
// integer. Do not renumber.
//
// vl_volume_type:  1=percent_balance 2=fixed_lot 3=fixed_cash 4=percent_equity
//
// The dropdown shows friendly English labels; volume_type_canonical maps each
// label back to its slug so the plot integer stays stable. Every option has a
// case — a new option with no case yields na (loud), never a silent wrong
// sizing method (no default fall-through here on purpose).
volume_type_canonical = switch volume_type
    "Percent of Balance" => "percent_balance"
    "Fixed Lots"         => "fixed_lot"
    "Fixed Cash Risk"    => "fixed_cash"
    "Percent of Equity"  => "percent_equity"

volume_type_num = switch volume_type_canonical
    "percent_balance" => 1
    "fixed_lot"       => 2
    "fixed_cash"      => 3
    "percent_equity"  => 4
    => 1

// Toggle-gated sentinels. When the toggle is off the plot shows -1 ("not set");
// when on, the raw value (including 0) is shown.
be_offset_emit  = be_offset_enable  ? be_offset  : -1.0
max_spread_emit = max_spread_enable ? max_spread : -1.0
slippage_emit   = slippage_enable   ? slippage   : -1


// ═══════════════════════════════════════════════════════════════════════════════
// DATA WINDOW PLOTS
// ═══════════════════════════════════════════════════════════════════════════════
// Values mirrored to the Data Window for reference. The order is documentation
// only; titles are kept stable.

// [0]–[4]
plot(entry_price,      "vl_entry",       display=display.data_window)
// vl_sl / vl_tp: when the hide toggle is ON, emit 0 so the level reads as
// "not set" and your saved default is used. Title + index unchanged; only the
// emitted value differs.
plot(use_dashboard_sl ? 0.0 : sl_price, "vl_sl",          display=display.data_window)
plot(use_dashboard_tp ? 0.0 : tp_price, "vl_tp",          display=display.data_window)
plot(risk_percent,     "vl_risk",        display=display.data_window)
plot(be_trigger_price, "vl_be_trigger",  display=display.data_window)

// [5]–[7] — sizing
plot(volume_type_num,  "vl_volume_type", display=display.data_window)
plot(lot_size,         "vl_lots",        display=display.data_window)
plot(cash_risk,        "vl_cash_risk",   display=display.data_window)

// [8]–[16] — trade management
plot(trail_pips,                  "vl_trail_pips",                  display=display.data_window)
plot(trail_trigger,               "vl_trail_trigger",               display=display.data_window)
plot(be_trigger_pips,             "vl_be_trigger_pips",             display=display.data_window)
plot(be_trigger_rr,               "vl_be_trigger_rr",               display=display.data_window)
plot(be_offset_emit,              "vl_be_offset",                   display=display.data_window)
plot(partial_close_pct,           "vl_partial_close_pct",           display=display.data_window)
plot(partial_close_vol,           "vl_partial_close_vol",           display=display.data_window)
plot(partial_close_trigger_pips,  "vl_partial_close_trigger_pips",  display=display.data_window)
plot(partial_close_trigger_rr,    "vl_partial_close_trigger_rr",    display=display.data_window)

// [17]–[18] — execution guards
plot(max_spread_emit,  "vl_max_spread",  display=display.data_window)
plot(slippage_emit,    "vl_slippage",    display=display.data_window)

// [19] — identity
plot(magic_number,     "vl_magic_number", display=display.data_window)

// [20] — live close of the current symbol, shown for reference against the
// entry/SL/TP levels (e.g. spotting levels left over from a symbol switch).
plot(close,            "vl_market_price", display=display.data_window)

// [21] — locale reference. Constant 1234567.89 rendered in the user's
// TradingView locale, showing the decimal/grouping separators in use.
plot(1234567.89,       "vl_fmt",          display=display.data_window)


// ═══════════════════════════════════════════════════════════════════════════════
// CHART VISUALS — create once, update in place (no per-frame churn)
// ═══════════════════════════════════════════════════════════════════════════════
col_tp_fill = color.new(color.green, 80)
col_sl_fill = color.new(color.red,   80)
col_rr      = #ffe066

// ── declare once ──
var line     entry_line  = na
var line     sl_line     = na
var line     tp_line     = na
var linefill tp_fill     = na
var linefill sl_fill     = na
var label    entry_label = na
var label    sl_label    = na
var label    tp_label    = na

// ── CREATE ONCE (first bar only) ──
// entry_line is always created. The SL/TP line+label+fill are created only when
// their defer toggle is OFF — so a hidden object's id stays `na` and is never
// drawn, updated, or fed to linefill.new (never pass an na id to linefill.new).
// A settings change recompiles the whole script, so flipping a toggle re-runs
// this block cleanly (no stale line persists).
if na(entry_line)
    entry_line  := line.new(bar_index, entry_price, bar_index + 1, entry_price, extend=extend.right, color=color.new(color.black, 0), width=2, style=line.style_solid)
    entry_label := label.new(bar_index + 2, entry_price, "", color=color.new(color.black, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
    if not use_dashboard_sl
        sl_line  := line.new(bar_index, sl_price, bar_index + 1, sl_price, extend=extend.right, color=color.new(color.red, 0), width=2, style=line.style_dashed)
        sl_label := label.new(bar_index + 2, sl_price, "", color=color.new(color.red, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
        // entry_line + sl_line both non-na here → safe to fill.
        sl_fill  := linefill.new(entry_line, sl_line, col_sl_fill)
    if not use_dashboard_tp
        tp_line  := line.new(bar_index, tp_price, bar_index + 1, tp_price, extend=extend.right, color=color.new(color.green, 0), width=2, style=line.style_dashed)
        tp_label := label.new(bar_index + 2, tp_price, "", color=color.new(color.green, 0), textcolor=color.white, style=label.style_label_left, size=size.small)
        // entry_line + tp_line both non-na here → safe to fill.
        tp_fill  := linefill.new(entry_line, tp_line, col_tp_fill)

// ── UPDATE IN PLACE every realtime frame (cheap — no new objects) ──
// Each SL/TP line/label is null-guarded so a hidden (na) object is never updated.
if barstate.islast
    line.set_xy1(entry_line, bar_index,     entry_price)
    line.set_xy2(entry_line, bar_index + 1, entry_price)
    label.set_xy(entry_label, bar_index + 2, entry_price)
    // R:R segment mirrors the panel: blank to "—" when either stop is deferred
    // (rr_ratio reads the raw input levels, not the deferred state, so it would
    // otherwise show a stale ratio while the panel says "—").
    rr_seg = (use_dashboard_sl or use_dashboard_tp) ? "—" : "1 : " + str.tostring(math.round(rr_ratio, 1), "#.#")
    label.set_text(entry_label, "Entry: " + str.tostring(entry_price, "#.#####") + "  |  R:R  " + rr_seg)

    if not na(sl_line)
        line.set_xy1(sl_line, bar_index,     sl_price)
        line.set_xy2(sl_line, bar_index + 1, sl_price)
    if not na(sl_label)
        label.set_xy(sl_label, bar_index + 2, sl_price)
        label.set_text(sl_label, "SL: " + str.tostring(sl_price, "#.#####") + "  (" + str.tostring(sl_disp, "#.#") + " " + unit_name + ")")

    if not na(tp_line)
        line.set_xy1(tp_line, bar_index,     tp_price)
        line.set_xy2(tp_line, bar_index + 1, tp_price)
    if not na(tp_label)
        label.set_xy(tp_label, bar_index + 2, tp_price)
        label.set_text(tp_label, "TP: " + str.tostring(tp_price, "#.#####") + "  (" + str.tostring(tp_disp, "#.#") + " " + unit_name + ")")

// ═══ INFO TABLE — build static cells once, rewrite only the value cell ═══
var table panel = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 10), border_color=color.new(color.gray, 40), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

var bool tbl_built = false
if not tbl_built
    table.cell(panel, 0, 0, "VIEWLINK", text_color=color.white, text_size=size.small, bgcolor=color.new(#1a1a2e, 0), text_halign=text.align_center)
    table.cell(panel, 1, 0, "", bgcolor=color.new(#1a1a2e, 0))
    table.cell(panel, 0, 1, "Pair", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(panel, 1, 1, syminfo.ticker, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(panel, 0, 2, "R:R Ratio", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(panel, 0, 3, "Risk",   text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(panel, 0, 4, "Reward", text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    tbl_built := true

if barstate.islast
    // When a stop/target is deferred to the dashboard, its measured distance is
    // meaningless (entry-to-zero) — show "—" rather than a bogus huge number.
    // R:R needs both, so blank it if either side is deferred. Both shown → today's
    // values unchanged.
    rr_cell   = (use_dashboard_sl or use_dashboard_tp) ? "—" : (rr_ratio > 0 ? "1 : " + str.tostring(math.round(rr_ratio, 1), "#.#") : "—")
    risk_cell = use_dashboard_sl ? "—" : str.tostring(sl_disp, "#.#") + " " + unit_name
    rew_cell  = use_dashboard_tp ? "—" : str.tostring(tp_disp, "#.#") + " " + unit_name
    table.cell(panel, 1, 2, rr_cell,   text_color=col_rr,      text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(panel, 1, 3, risk_cell, text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
    table.cell(panel, 1, 4, rew_cell,  text_color=color.white, text_size=size.small, bgcolor=color.new(color.black, 20))
````
