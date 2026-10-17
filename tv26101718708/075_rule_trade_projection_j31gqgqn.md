# 0.75% Rule - Trade Projection

- url: https://www.tradingview.com/script/J31GqGqn-0-75-Rule-Trade-Projection/
- type: indicator
- pine_id: PUB;66647b7cbc8449aeab7f8940210fb9c6
- version: 4.0

## Description

A position-sizing and reward-projection overlay for discretionary traders.
You place an entry and a stop on the chart, and the script returns the
position size that risks a fixed fraction of your account, then projects
your reward targets as R-multiples. Direction (long or short) is inferred
from where you click. The focus is getting currency-correct sizing right
with as little input as possible, and catching the sizing mistakes that
quietly distort risk.

📊 What it does
- Sizes the trade so the entry-to-stop distance equals a fixed percentage
  of account equity. Default is 0.75%, a conservative fixed-fractional
  risk rule, but the percentage is adjustable.
- Reports the result in the correct unit for the instrument: lots and
  units for forex, or contracts/shares sized off point value elsewhere.
- Projects a configurable number of reward targets spaced in R-multiples
  (1R, 2R, 3R ...), each labeled with its R-multiple and the reward amount
  in your account currency.
- Draws the risk zone (entry to stop) and reward zones, plus an info panel
  summarizing account, risk, direction, stop distance, size and R:R.

⚙️ How it works
- Risk amount = account size x risk %. Position size = risk amount /
  (stop distance x point value x conversion rate). For forex this is
  converted into standard lots.
- Direction is read from the two clicks: a stop below entry is a long,
  a stop above entry is a short.
- Instrument detection is automatic (forex, JPY pairs, metals, index,
  crypto) via symbol info, with a manual override if you need it.
- Account-to-quote currency conversion is explicit and manual. The
  account-currency dropdown is a display label only; the single field
  that adjusts lot size is the conversion rate. The panel flags the two
  mistakes that actually distort risk: leaving the rate at 1.0 on a
  mismatched pair, and applying a non-1.0 rate when the currencies match.
- An optional ATR-based stop can override the clicked stop (length and
  multiplier adjustable). Direction still comes from your clicks.
- Repaint-free by construction: no higher-timeframe requests, entry and
  stop are static prices, and all drawing is deterministic.

📋 How to use it
1. Add the script. It prompts you to click an entry price, then a stop.
2. Set account size and risk % in settings (default 0.75%).
3. If your account currency differs from the pair's quote currency, enter
   the conversion rate (account currency per one unit of quote currency).
   The panel warns you when a rate is needed.
4. Read position size, R:R and target levels from the panel and on-chart
   labels.
5. For a new setup, open the indicator menu, choose Reset points, then
   re-click entry and stop. The Re-arm toggle pauses the current
   projection so a stale setup cannot mislead you.

## Notes
- This is a planning and risk-discipline tool, not a signal generator and
  not financial advice. It does not place trades.
- For non-forex instruments, sanity-check the point value against your
  broker's contract specs before trusting the size.
- Inputs are absolute prices, so after switching symbols you may need to
  re-click entry and stop. The script detects an off-scale setup and
  prompts you.

## Source Code

````pine
//@version=6

// ============================================================
//  0.75% Rule - Trade Projection
//  Risk-discipline tool.
//
//  Place Entry + Stop on the chart, get position size and an
//  R-multiple projection. Direction is inferred from the clicks.
//
//  Design (locked):
//   - No security() calls. Nothing to repaint, no cross-rate fetch.
//   - Repaint-free by construction: entry/stop are static prices,
//     all drawing is deterministic.
//   - Zero-input common case: instrument auto-detected.
//   - Instructions live at the point of confusion (tooltips +
//     on-chart guidance label).
// ============================================================

indicator("0.75% Rule - Trade Projection", shorttitle="0.75% Projection", overlay=true, max_lines_count=100, max_boxes_count=100, max_labels_count=100)

// ------------------------------------------------------------
//  INPUTS
// ------------------------------------------------------------

// --- Risk ---
var string g_risk = "Risk"
account_size = input.float(100000.0, "Account size", minval=0.0, group=g_risk, tooltip="Your account balance in your account currency.")
risk_pct     = input.float(0.75, "Risk %", minval=0.0, step=0.05, group=g_risk, tooltip="Risk per trade. The 0.75% Rule default.")
entry        = input.price(0.0, "Entry", confirm=true, group=g_risk, tooltip="Click your intended entry on the chart.")
stop         = input.price(0.0, "Stop", confirm=true, group=g_risk, tooltip="Click your stop. Direction is inferred: stop below entry = long, above = short.")
rearm        = input.bool(false, "Re-arm - disarm current Entry/Stop", group=g_risk, tooltip="Pause the projection and stop using the current clicks. Pine Script can't clear a price input from code (a TradingView limit), so this can't auto-blank the fields. What it does: refuse the stored Entry/Stop so a stale setup can't mislead you. To place a fresh trade: open the menu on the indicator (its title on the chart) -> Reset points, then re-click Entry and Stop - then switch Re-arm off.")

// --- Stop mode (optional) ---
var string g_stop = "Stop mode (optional)"
use_atr_stop = input.bool(false, "Use ATR stop", group=g_stop, tooltip="Override the clicked stop with an ATR-based distance. Direction still comes from your Entry/Stop clicks.")
atr_len      = input.int(14, "ATR length", minval=1, group=g_stop, tooltip="Lookback for the ATR used when 'Use ATR stop' is on.")
atr_mult     = input.float(1.5, "ATR multiplier", minval=0.0, step=0.1, group=g_stop, tooltip="Stop distance = ATR × this multiplier.")

// --- Targets ---
var string g_tgt = "Targets"
num_targets = input.int(3, "Number of targets", minval=1, maxval=10, group=g_tgt, tooltip="How many reward targets to project.")
target_step = input.float(1.0, "R per target", minval=0.1, step=0.1, group=g_tgt, tooltip="R-multiple spacing between targets. 1.0 → 1R, 2R, 3R …")

// --- Instrument (sizing) ---
var string g_inst = "Instrument (sizing)"
instrument_mode    = input.string("Auto", "Instrument mode", options=["Auto", "Forex - standard (0.0001 pip)", "Forex - JPY pairs (0.01 pip)", "Metals (Gold/Silver)", "Index", "Crypto", "Custom"], group=g_inst, tooltip="Leave on Auto. Only change if sizing looks wrong. Metals size off point value, like indices.")
custom_point_value = input.float(1.0, "Custom point value", minval=0.0, group=g_inst, tooltip="Value of a 1.0 price move per 1 unit/contract, in quote currency. Only used when mode = Custom.")

// --- Account ⇄ quote conversion ---
//  The dropdown is a LABEL + validator. It does NOT size positions.
//  The 'Conversion rate' below is the only input that adjusts lots for currency.
var string g_ccy = "Account ⇄ quote conversion"
account_ccy        = input.string("USD", "Account currency (label only)", options=["USD", "EUR", "GBP", "JPY", "CHF", "AUD", "CAD", "NZD"], group=g_ccy, tooltip="DISPLAY LABEL ONLY — changing this does NOT change your lot size. It sets the currency symbol shown on the panel and flags when a conversion is needed. The number that actually sizes the trade is 'Conversion rate' below.")
conversion_rate    = input.float(1.0, "Conversion rate (the sizing lever)", minval=0.0, group=g_ccy, tooltip="THIS is what adjusts lots for currency. Enter: account currency per 1 unit of the pair's quote currency. EUR account on EURUSD (quote USD) → EUR per USD ≈ 0.92. Use current spot — precision isn't critical, a few % drift barely moves your risk. The errors that matter are leaving it at 1.0 on a mismatched pair, or inverting it (0.92 vs 1.087). Leave at 1.0 only when account currency already matches the quote currency.")

// --- Appearance ---
var string g_app = "Appearance"
show_panel    = input.bool(true, "Show info panel", group=g_app, tooltip="Toggle the summary table in the corner.")
show_watermark = input.bool(true, "Show watermark", group=g_app, tooltip="Subtle 'The 0.75% Rule' brand watermark in the corner. Turn off for a clean chart.")
label_size_in = input.string("Normal", "Label size", options=["Small", "Normal", "Large"], group=g_app, tooltip="Size of the on-chart price / R labels.")
proj_bars     = input.int(40, "Projection width (bars)", minval=5, maxval=300, group=g_app, tooltip="How far to the right the zones are drawn.")
show_summary  = input.bool(true, "Show on-chart summary", group=g_app, tooltip="Compact size / risk / R:R block anchored at the entry. Stays in the image when a screenshot crops the corner panel. Turn off for a clean chart.")
panel_opacity = input.int(10, "Panel background opacity", minval=0, maxval=100, group=g_app, tooltip="Transparency of the info panel background. 0 = solid (most readable over busy price action), higher values let candles show through. Default 10 reads like a native TradingView widget.")

// ------------------------------------------------------------
//  COLORS / STYLE
// ------------------------------------------------------------
col_entry = color.new(color.gray, 0)
col_stop  = color.new(color.red, 0)
col_risk  = color.new(color.red, 78)
col_rew   = color.green
col_txt   = color.white

lbl_size = label_size_in == "Small" ? size.small : label_size_in == "Large" ? size.large : size.normal

// account-currency display symbol (cosmetic only — sizing math rides on conversion_rate)
ccy_sym = switch account_ccy
    "USD" => "$"
    "EUR" => "€"
    "GBP" => "£"
    "JPY" => "¥"
    "CHF" => "CHF "
    "AUD" => "A$"
    "CAD" => "C$"
    "NZD" => "NZ$"
    => account_ccy + " "

// ------------------------------------------------------------
//  CORE MATH
// ------------------------------------------------------------
atr_val = ta.atr(atr_len)                              // computed every bar (required for ta.* funcs)

is_long   = entry > stop                               // direction from the clicks
stop_used = use_atr_stop ? (is_long ? entry - atr_val * atr_mult : entry + atr_val * atr_mult) : stop
stop_dist = math.abs(entry - stop_used)                // price distance, account-agnostic

risk_amount = account_size * risk_pct / 100.0          // account currency

// instrument resolution (no security() — pure syminfo.*)
mode_is_forex  = instrument_mode == "Auto" ? (syminfo.type == "forex") : (instrument_mode == "Forex - standard (0.0001 pip)" or instrument_mode == "Forex - JPY pairs (0.01 pip)")
mode_is_custom = instrument_mode == "Custom"
quote_is_jpy   = instrument_mode == "Forex - JPY pairs (0.01 pip)" or (instrument_mode == "Auto" and syminfo.currency == "JPY")
pip_size       = quote_is_jpy ? 0.01 : 0.0001          // display only, not core math

// point value: NOTE — sanity-check syminfo.pointvalue per asset class
// against a known broker calc before trusting non-forex output.
point_value = mode_is_custom ? custom_point_value : syminfo.pointvalue

// account-currency conversion (purely manual — the user always supplies the rate)
quote_ccy  = syminfo.currency                            // detected; used for the advisory + label only, not the math
ccy_match  = account_ccy == quote_ccy
conv       = conversion_rate                             // applied exactly as entered; 1.0 = no conversion
conv_unset = (not ccy_match) and conversion_rate == 1.0  // mismatch + default rate → advisory flag only
conv_stale = ccy_match and conversion_rate != 1.0        // currencies match but a non-1.0 rate is being applied
conv_warn  = conv_unset or conv_stale
warn_txt   = conv_unset ? "⚠ lots sized at rate 1.0 — set " + account_ccy + " per " + quote_ccy : conv_stale ? "⚠ " + account_ccy + " matches quote — set rate back to 1.0" : ""

// forex sizing (units of base currency)
risk_in_quote  = conv > 0 ? risk_amount / conv : 0.0
position_units = stop_dist > 0 ? risk_in_quote / stop_dist : 0.0
lots           = position_units / 100000.0

// generalized sizing (point-value based)
position_size = (stop_dist > 0 and point_value > 0 and conv > 0) ? risk_amount / (stop_dist * point_value * conv) : 0.0

// stale-input guard — Entry/Stop are absolute prices that persist across symbol
// changes (Pine can't clear a price input from code, and a script can't see what
// symbol a click came from), so on a new symbol they can sit at the wrong level
// and the projection draws against stale prices. The guard bands Entry/Stop against
// a RECENT price window: a setup parked far from current price (the signature of a
// carried-over click from a same-scale pair) lands outside the band and trips a
// re-click prompt. The window scales with timeframe (300 bars), so legitimate
// swing/position setups near current price survive.
//   LIMIT: if two pairs' recent ranges genuinely overlap, price alone can't separate
//   them — the symbol echo on the panel/summary and the Re-arm toggle are the
//   guaranteed catch for that case.
lookback     = 300
recent_hi    = ta.highest(high, lookback)
recent_lo    = ta.lowest(low, lookback)
rng_pad      = math.max((recent_hi - recent_lo) * 0.5, nz(atr_val) * 4.0)   // generous pad so legit setups near price are never flagged
band_hi      = recent_hi + rng_pad
band_lo      = math.max(0.0, recent_lo - rng_pad)
placed       = not na(entry) and not na(stop) and entry != 0.0 and stop != 0.0
stale_inputs = placed and (entry > band_hi or entry < band_lo or stop > band_hi or stop < band_lo)

// readiness guard
ready = not na(entry) and not na(stop) and entry != stop and stop_dist > 0.0 and not stale_inputs and not rearm

// display helpers
unit_word = syminfo.type == "stock" ? "shares" : "units"
size_str = mode_is_forex ? str.tostring(lots, "#.##") + " lots  (" + str.tostring(position_units, "#") + " units)" : str.tostring(position_size, "#.####") + " " + unit_word
size_compact = mode_is_forex ? str.tostring(lots, "#.##") + " lots" : str.tostring(position_size, "#.##") + " " + unit_word
final_R  = num_targets * target_step
rr_str   = str.tostring(final_R, "#.##") + " : 1"
stop_pips = pip_size > 0 ? stop_dist / pip_size : 0.0

// ------------------------------------------------------------
//  DRAWING  (deterministic, redrawn on the last bar only)
// ------------------------------------------------------------
var array<line>  lines  = array.new<line>()
var array<box>   boxes  = array.new<box>()
var array<label> labels = array.new<label>()
var table panel = na
var table footer = na

if barstate.islast
    // --- clear previous objects ---
    for ln in lines
        line.delete(ln)
    array.clear(lines)
    for bx in boxes
        box.delete(bx)
    array.clear(boxes)
    for lb in labels
        label.delete(lb)
    array.clear(labels)

    x1 = bar_index
    x2 = bar_index + proj_bars

    if not ready
        // first-use hand-holding / degenerate-state guidance
        unplaced = na(entry) or na(stop) or entry == stop
        msg = rearm ? "RE-ARM active — projection paused. To re-place: ⋯ menu on the indicator → Reset points, then re-click Entry then Stop. Switch Re-arm off when done." : stale_inputs ? "Entry/Stop don't match " + syminfo.ticker + " — re-click Entry then Stop on this chart" : unplaced ? "Click to set Entry, then Stop →" : "Stop distance is zero — adjust your stop or ATR multiplier"
        array.push(labels, label.new(x1, na(close) ? 0.0 : close, msg, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_left, color=rearm ? color.new(color.orange, 0) : color.new(color.blue, 0), textcolor=color.white, size=size.normal))
    else
        dir = is_long ? 1 : -1

        // --- Entry line + label ---
        array.push(lines,  line.new(x1, entry, x2, entry, xloc=xloc.bar_index, color=col_entry, width=2, extend=extend.right))
        array.push(labels, label.new(x2, entry, "Entry · " + str.tostring(entry, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.gray, 20), textcolor=col_txt, size=lbl_size))

        // --- Direction marker (instant long/short read) ---
        array.push(labels, label.new(x1, entry, "", xloc=xloc.bar_index, yloc=yloc.price, style=is_long ? label.style_triangleup : label.style_triangledown, color=is_long ? color.new(color.lime, 0) : color.new(color.red, 0), size=size.small))

        // --- On-chart summary (hero block, survives screenshot cropping of the panel) ---
        if show_summary
            sum_txt = "0.75% Rule · " + syminfo.ticker + "  ·  " + (is_long ? "LONG" : "SHORT") + "\n" + size_compact + "   ·   risk " + ccy_sym + str.tostring(risk_amount, "#.##") + "\nR : R   " + rr_str + (warn_txt != "" ? "\n" + warn_txt : "")
            array.push(labels, label.new(x1, entry, sum_txt, xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_right, color=color.new(color.blue, 12), textcolor=color.white, size=lbl_size, textalign=text.align_left))

        // --- Stop line + label ---
        array.push(lines,  line.new(x1, stop_used, x2, stop_used, xloc=xloc.bar_index, color=col_stop, width=2, style=line.style_dashed, extend=extend.right))
        array.push(labels, label.new(x2, stop_used, "Stop · " + str.tostring(stop_used, format.mintick) + " · -1R", xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.red, 10), textcolor=col_txt, size=lbl_size))

        // --- Risk zone (entry <-> stop) ---
        array.push(boxes, box.new(x1, math.max(entry, stop_used), x2, math.min(entry, stop_used), xloc=xloc.bar_index, border_color=color.new(color.red, 60), bgcolor=col_risk))

        // --- Reward zones + target lines/labels ---
        prev_price = entry
        for n = 1 to num_targets
            is_final = n == num_targets
            tgt    = entry + dir * n * target_step * stop_dist
            reward = risk_amount * n * target_step
            rmult  = n * target_step
            transp = math.max(35, 85 - n * 12)          // deepens (more opaque) outward

            array.push(boxes, box.new(x1, math.max(prev_price, tgt), x2, math.min(prev_price, tgt), xloc=xloc.bar_index, border_color=color.new(col_rew, 70), bgcolor=color.new(col_rew, transp)))
            array.push(lines, line.new(x1, tgt, x2, tgt, xloc=xloc.bar_index, color=color.new(col_rew, 0), width=is_final ? 3 : 1, extend=extend.right))

            txt = "T" + str.tostring(n) + " · " + str.tostring(tgt, format.mintick) + " · +" + str.tostring(rmult, "#.##") + "R · " + ccy_sym + str.tostring(reward, "#.##") + (is_final ? "  ★ final" : "")
            array.push(labels, label.new(x2, tgt, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(col_rew, is_final ? 0 : 10), textcolor=col_txt, size=lbl_size))

            prev_price := tgt

    // --- watermark (fixed corner — never collides with candles) ---
    if show_watermark and na(footer)
        footer := table.new(position.bottom_right, 1, 1)
        table.cell(footer, 0, 0, "The 0.75% Rule", text_color=color.new(color.gray, 30), text_size=size.small)
    if not show_watermark and not na(footer)
        table.delete(footer)
        footer := na

    // --- info panel ---
    if show_panel and na(panel)
        panel := table.new(position.top_right, 2, 9, bgcolor=color.new(#1e222d, panel_opacity), frame_color=color.new(color.gray, 40), frame_width=1, border_color=color.new(color.gray, 70), border_width=1)
    if not show_panel and not na(panel)
        table.delete(panel)
        panel := na

    if not na(panel)
        table.cell(panel, 0, 0, (rearm ? "RE-ARM" : "0.75% Rule") + " · " + syminfo.ticker, text_color=color.white, text_size=size.small, bgcolor=rearm ? color.new(color.orange, 15) : color.new(color.blue, 25))
        table.merge_cells(panel, 0, 0, 1, 0)

        table.cell(panel, 0, 1, "Account",   text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 1, ccy_sym + str.tostring(account_size, "#"), text_color=col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 2, "Risk %",     text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 2, str.tostring(risk_pct) + "%", text_color=col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 3, "Risk",      text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 3, ready ? ccy_sym + str.tostring(risk_amount, "#.##") : "—", text_color=col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 4, "Direction",   text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 4, ready ? (is_long ? "LONG" : "SHORT") : "—", text_color=ready ? (is_long ? color.lime : color.red) : col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 5, "Stop dist",   text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 5, ready ? (mode_is_forex ? str.tostring(stop_pips, "#.#") + " pips" : str.tostring(stop_dist, format.mintick)) : "—", text_color=col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 6, "Position",     text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 6, ready ? size_str : "—", text_color=col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 7, "R : R",        text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        table.cell(panel, 1, 7, ready ? rr_str : "—", text_color=col_txt, text_size=size.small, text_halign=text.align_right)

        table.cell(panel, 0, 8, "FX conv",       text_color=color.gray,  text_size=size.small, text_halign=text.align_left)
        conv_txt = conv_unset ? "⚠ set " + account_ccy + "/" + quote_ccy : conv_stale ? "⚠ use 1.0 (" + account_ccy + "=quote)" : str.tostring(conversion_rate, "#.####") + (ccy_match ? "  (" + account_ccy + ")" : "  " + account_ccy + "/" + quote_ccy)
        table.cell(panel, 1, 8, conv_txt, text_color=conv_warn ? color.red : col_txt, text_size=size.small, text_halign=text.align_right)
````
