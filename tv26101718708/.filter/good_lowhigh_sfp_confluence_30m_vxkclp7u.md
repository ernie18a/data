# Good Low/High + SFP Confluence [30m]

- url: https://www.tradingview.com/script/VXKcLP7u-Good-Low-High-SFP-Confluence-30m/
- type: indicator
- pine_id: PUB;c15f9365c3b24f9dbf4fc3aa9e6ea38a
- version: 1.0

## Description

Good Low / Good High — Full Confluence System v1.3
TPO Confirmation · SFP · MA50 · Fibonacci 0.618 · POC Approximation

 Educational purposes only. This indicator does not constitute financial advice. Past signals do not guarantee future results. Always manage your own risk.

───

What it does:
This indicator identifies high-probability turning points by combining five confluence elements on the 30-minute chart. It's built around the concept of TPO Good Lows and Good Highs — the idea that a price extreme only "matters" if the market spends meaningful time accepting it. One-candle wicks don't count.

The five elements:

 TPO Good Low / Good High — A swing extreme is classified as Good when price holds near that level for a configurable number of candles (default: 2). If price abandons the level too quickly, it's flagged as Bad — meaning expect a return visit to form a proper low or high.

 Swing Failure Pattern (SFP) — Detects stop hunts: a wick beyond the prior swing extreme that closes back inside. Bullish SFP = liquidity grab below prior low with a close above. Bearish SFP = grab above prior high with a close below.

 Moving Average (default: 50 EMA) — Trend filter. Signals in the direction of the MA carry higher weight in the confluence score.

 Fibonacci 0.618 — Dynamic retracement levels calculated from the recent swing range. Both the bearish (sell zone) and bullish (buy zone) 0.618 levels are plotted and factored into confluence.

 POC Approximation — Estimates the Point of Control (highest-volume price) over a configurable lookback by dividing the range into buckets and summing volume. Not a true TPO/market profile POC — it's an approximation, but it's surprisingly effective at identifying value.

The signal hierarchy:

| Signal                    | Meaning                                                         |
| ------------------------- | --------------------------------------------------------------- |
| ⚠️ Bad Low / Bad High     | One-wick extreme — expect return                                |
| ✅ Good Low / 🔴 Good High | Accepted extreme — possible reversal zone                       |
| SFP ▲ / SFP ▼             | Stop hunt with close-back — potential trap                      |

| 🔥 FULL CONFLUENCE        | SFP fires inside MA + POC + Fib alignment — highest probability |

Full confluence signals also draw a zone box and flash background color so they're impossible to miss.

Best used on: 30-minute BTC/liquid crypto or futures. Tune the ATR tolerance and confluence proximity for your instrument.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════════
// Good Low / Good High — Full Confluence System v1.2
// TPO Confirmation + SFP + MA50 + Fibonacci 0.618 + POC Approximation
//
// Trading Group — TPO Good Low / Good High
// FIXES v1.2:
//   - Upgraded to //@version=6
//   - alertcondition messages use const strings only (no input concatenation)
//   - Removed invalid colspan from table.cell
//   - Moved f_poc, ta.highest, ta.lowest outside conditional scopes
//
// DESIGNED FOR: 30-Minute chart | BTC / liquid crypto or futures
// ═══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator("Good Low/High + SFP Confluence [30m]", overlay=true, max_labels_count=300, max_lines_count=300, max_boxes_count=100)

// ─── INPUTS ───────────────────────────────────────────────────────────────────

var string G1 = "TPO Settings"
confirm_bars   = input.int(2,    "Min Candles → Good Low/High",   minval=1, maxval=6,   group=G1, tooltip="How many 30m candles must hold near the extreme to qualify as a Good Low or High")
swing_lookback = input.int(5,    "Swing Detection Lookback",       minval=2, maxval=20,  group=G1)
atr_tol_mult   = input.float(0.35,"ATR Tolerance (fraction)",      minval=0.1, maxval=2, group=G1, step=0.05)

var string G2 = "SFP (Swing Failure Pattern)"
sfp_lookback   = input.int(10,   "SFP Prior Swing Lookback",       minval=3, maxval=30,  group=G2)
sfp_min_wick   = input.float(0.3,"Min Wick Size (ATR fraction)",   minval=0.1, maxval=3, group=G2, tooltip="Minimum wick beyond the swept level to qualify as SFP")

var string G3 = "Moving Average"
ma_len         = input.int(50,   "MA Length",                      minval=5, maxval=200, group=G3)
ma_type        = input.string("EMA", "MA Type", options=["EMA","SMA","WMA"],             group=G3)

var string G4 = "Fibonacci"
fib_lookback   = input.int(50,   "Fib Swing Lookback (bars)",      minval=10, maxval=200, group=G4)
show_fib       = input.bool(true,"Show 0.618 Fib Level",                                 group=G4)

var string G5 = "POC Approximation"
poc_lookback   = input.int(100,  "POC Volume Lookback (bars)",     minval=20, maxval=500, group=G5)
poc_buckets    = input.int(20,   "Price Buckets",                  minval=10, maxval=50,  group=G5, tooltip="Number of price levels to divide the range into for POC calculation")
show_poc       = input.bool(true,"Show POC Level",                                        group=G5)

var string G6 = "Confluence Zone"
conf_atr_dist  = input.float(0.5,"Confluence Proximity (ATR)",     minval=0.1, maxval=3,  group=G6, tooltip="How close levels must be to each other to count as confluence")
min_confluence = input.int(2,    "Min Levels for Confluence Zone", minval=1, maxval=3,    group=G6, tooltip="How many of MA/POC/Fib must align to trigger a confluence zone")

var string G7 = "Visuals"
show_good_lows  = input.bool(true, "Show Good Lows",   group=G7)
show_good_highs = input.bool(true, "Show Good Highs",  group=G7)
show_bad_lows   = input.bool(true, "Show Bad Lows",    group=G7)
show_bad_highs  = input.bool(true, "Show Bad Highs",   group=G7)
show_sfp        = input.bool(true, "Show SFP Signals", group=G7)
show_full_signal= input.bool(true, "Show Full Confluence Signals", group=G7)

// ─── COLORS ──────────────────────────────────────────────────────────────────
col_good_low    = color.new(color.lime,    0)
col_good_high   = color.new(color.red,     0)
col_bad_low     = color.new(color.orange,  0)
col_bad_high    = color.new(color.orange,  0)
col_sfp_bull    = color.new(color.aqua,    0)
col_sfp_bear    = color.new(color.fuchsia, 0)
col_full_bull   = color.new(color.lime,   10)
col_full_bear   = color.new(color.red,    10)
col_ma          = color.new(color.yellow,  0)
col_fib         = color.new(color.purple, 20)
col_poc         = color.new(color.blue,   20)

// ─── MOVING AVERAGE ───────────────────────────────────────────────────────────
ma_val = switch ma_type
    "EMA" => ta.ema(close, ma_len)
    "SMA" => ta.sma(close, ma_len)
    "WMA" => ta.wma(close, ma_len)
    =>       ta.ema(close, ma_len)

plot(ma_val, title="MA50", color=col_ma, linewidth=1)

// ─── ATR ─────────────────────────────────────────────────────────────────────
atr_val   = ta.atr(14)
atr_tol   = atr_val * atr_tol_mult
conf_dist = atr_val * conf_atr_dist

// ─── FIBONACCI 0.618 ─────────────────────────────────────────────────────────
fib_high     = ta.highest(high, fib_lookback)
fib_low      = ta.lowest(low,   fib_lookback)
fib_618      = fib_high - (fib_high - fib_low) * 0.618
fib_618_bull = fib_low  + (fib_high - fib_low) * 0.618

plot(show_fib ? fib_618      : na, title="Fib 0.618 (Bear)", color=col_fib, linewidth=1, style=plot.style_linebr)
plot(show_fib ? fib_618_bull : na, title="Fib 0.618 (Bull)", color=color.new(color.purple, 50), linewidth=1, style=plot.style_linebr)

// ─── POC APPROXIMATION ────────────────────────────────────────────────────────
// FIX #7: f_poc called every bar (not inside conditional) for consistency
// The function iterates buckets to find the highest-volume price zone
f_poc(lookback, buckets) =>
    h = ta.highest(high, lookback)
    l = ta.lowest(low,   lookback)
    bucket_size = (h - l) / buckets
    max_vol   = 0.0
    poc_price = (h + l) / 2
    for b = 0 to buckets - 1
        bucket_low  = l + b * bucket_size
        bucket_high = bucket_low + bucket_size
        bucket_vol  = 0.0
        for i = 0 to lookback - 1
            if high[i] >= bucket_low and low[i] <= bucket_high
                bucket_vol += volume[i]
        if bucket_vol > max_vol
            max_vol   := bucket_vol
            poc_price := bucket_low + bucket_size / 2
    poc_price

// FIX #7: Call f_poc every bar — store in var, only update every 5 bars for perf
var float poc_val = na
float poc_raw = f_poc(poc_lookback, poc_buckets)
if bar_index % 5 == 0 or barstate.islast
    poc_val := poc_raw

plot(show_poc ? poc_val : na, title="POC (approx)", color=col_poc, linewidth=2, style=plot.style_linebr)

// ─── VAH / VAL (outside conditional) ─────────────────────────────────────────
// FIX #8 & #9: ta.highest and ta.lowest moved outside conditional scope
h_range   = ta.highest(high, poc_lookback)
l_range   = ta.lowest(low,   poc_lookback)

var float vah       = na
var float val_level = na
if bar_index % 5 == 0 or barstate.islast
    vah       := l_range + (h_range - l_range) * 0.70
    val_level := l_range + (h_range - l_range) * 0.30

// ─── PIVOT DETECTION ──────────────────────────────────────────────────────────
pivot_low  = ta.pivotlow( low,  swing_lookback, swing_lookback)
pivot_high = ta.pivothigh(high, swing_lookback, swing_lookback)

// ─── TPO GOOD/BAD LOW STATE ──────────────────────────────────────────────────
var float tracked_low      = na
var int   low_count        = 0
var bool  low_confirmed    = false
var bool  low_bad_flagged  = false
var int   low_start_bar    = na

var float tracked_high     = na
var int   high_count       = 0
var bool  high_confirmed   = false
var bool  high_bad_flagged = false
var int   high_start_bar   = na

if not na(pivot_low)
    tracked_low     := pivot_low
    low_count       := 1
    low_confirmed   := false
    low_bad_flagged := false
    low_start_bar   := bar_index - swing_lookback

if not na(pivot_high)
    tracked_high      := pivot_high
    high_count        := 1
    high_confirmed    := false
    high_bad_flagged  := false
    high_start_bar    := bar_index - swing_lookback

bool low_holding  = not na(tracked_low)  and low  <= tracked_low  + atr_tol and not low_confirmed
bool high_holding = not na(tracked_high) and high >= tracked_high - atr_tol and not high_confirmed

if low_holding  and bar_index > low_start_bar  and na(pivot_low)
    low_count  += 1
if high_holding and bar_index > high_start_bar and na(pivot_high)
    high_count += 1

bool price_left_low  = not na(tracked_low)  and low  > tracked_low  + atr_tol and not low_confirmed
bool price_left_high = not na(tracked_high) and high < tracked_high - atr_tol and not high_confirmed

bool new_good_low  = low_holding  and low_count  >= confirm_bars and not low_confirmed
bool new_good_high = high_holding and high_count >= confirm_bars and not high_confirmed
bool new_bad_low   = price_left_low  and low_count  < confirm_bars and not low_bad_flagged
bool new_bad_high  = price_left_high and high_count < confirm_bars and not high_bad_flagged

if new_good_low
    low_confirmed := true
if new_good_high
    high_confirmed := true
if new_bad_low
    low_bad_flagged := true
if new_bad_high
    high_bad_flagged := true

// ─── SFP DETECTION ───────────────────────────────────────────────────────────
prior_low_for_sfp  = ta.lowest(low[1],   sfp_lookback)
prior_high_for_sfp = ta.highest(high[1], sfp_lookback)

sfp_bull = low  < prior_low_for_sfp  and close > prior_low_for_sfp  and (prior_low_for_sfp  - low)  >= atr_val * sfp_min_wick
sfp_bear = high > prior_high_for_sfp and close < prior_high_for_sfp and (high - prior_high_for_sfp) >= atr_val * sfp_min_wick

// ─── CONFLUENCE DETECTION ────────────────────────────────────────────────────
f_near(price, level) =>
    not na(level) and math.abs(price - level) <= conf_dist

bool near_ma_bull  = f_near(close, ma_val) and close >= ma_val - conf_dist
bool near_poc_bull = f_near(close, poc_val) and not na(poc_val)
bool near_fib_bull = f_near(close, fib_618_bull)
int  bull_conf_score    = (near_ma_bull ? 1 : 0) + (near_poc_bull ? 1 : 0) + (near_fib_bull ? 1 : 0)
bool in_bull_confluence = bull_conf_score >= min_confluence

bool near_ma_bear  = f_near(close, ma_val) and close <= ma_val + conf_dist
bool near_poc_bear = f_near(close, poc_val) and not na(poc_val)
bool near_fib_bear = f_near(close, fib_618)
int  bear_conf_score    = (near_ma_bear ? 1 : 0) + (near_poc_bear ? 1 : 0) + (near_fib_bear ? 1 : 0)
bool in_bear_confluence = bear_conf_score >= min_confluence

// ─── FULL CONFLUENCE SIGNALS ─────────────────────────────────────────────────
bool full_bull_signal = show_full_signal and sfp_bull and in_bull_confluence
bool full_bear_signal = show_full_signal and sfp_bear and in_bear_confluence

// ─── LABELS ──────────────────────────────────────────────────────────────────
if new_good_low and show_good_lows
    label.new(bar_index, tracked_low - atr_val,
         text  = "✅ GOOD LOW\n" + str.tostring(low_count) + " candles\n" + str.tostring(tracked_low, "#.##"),
         color = col_good_low, textcolor = color.black,
         style = label.style_label_up, size = size.small)

if new_good_high and show_good_highs
    label.new(bar_index, tracked_high + atr_val,
         text  = "🔴 GOOD HIGH\n" + str.tostring(high_count) + " candles\n" + str.tostring(tracked_high, "#.##"),
         color = col_good_high, textcolor = color.white,
         style = label.style_label_down, size = size.small)

if new_bad_low and show_bad_lows
    label.new(bar_index, tracked_low - atr_val,
         text  = "⚠️ BAD LOW\nExpect return\n" + str.tostring(tracked_low, "#.##"),
         color = col_bad_low, textcolor = color.black,
         style = label.style_label_up, size = size.tiny)

if new_bad_high and show_bad_highs
    label.new(bar_index, tracked_high + atr_val,
         text  = "⚠️ BAD HIGH\nExpect return\n" + str.tostring(tracked_high, "#.##"),
         color = col_bad_high, textcolor = color.black,
         style = label.style_label_down, size = size.tiny)

if sfp_bull and show_sfp
    _conf_txt = in_bull_confluence ? " 🔥CONF" : ""
    label.new(bar_index, low - atr_val * 0.5,
         text  = "SFP ▲" + _conf_txt + "\n" + str.tostring(close, "#.##"),
         color = in_bull_confluence ? col_full_bull : col_sfp_bull,
         textcolor = color.black,
         style = label.style_label_up, size = size.small)

if sfp_bear and show_sfp
    _conf_txt = in_bear_confluence ? " 🔥CONF" : ""
    label.new(bar_index, high + atr_val * 0.5,
         text  = "SFP ▼" + _conf_txt + "\n" + str.tostring(close, "#.##"),
         color = in_bear_confluence ? col_full_bear : col_sfp_bear,
         textcolor = color.white,
         style = label.style_label_down, size = size.small)

// ─── CONFLUENCE ZONE BOXES ───────────────────────────────────────────────────
if full_bull_signal
    box.new(bar_index - 1, close + conf_dist, bar_index + 8, close - conf_dist,
         bgcolor = color.new(color.lime, 80), border_color = color.lime, border_width = 1)

if full_bear_signal
    box.new(bar_index - 1, close + conf_dist, bar_index + 8, close - conf_dist,
         bgcolor = color.new(color.red, 80), border_color = color.red, border_width = 1)

// ─── BACKGROUND ──────────────────────────────────────────────────────────────
bgcolor(full_bull_signal ? color.new(color.lime,   75) : na, title="Full Bull BG")
bgcolor(full_bear_signal ? color.new(color.red,    75) : na, title="Full Bear BG")
bgcolor(sfp_bull and not in_bull_confluence ? color.new(color.aqua,    90) : na, title="SFP Bull BG")
bgcolor(sfp_bear and not in_bear_confluence ? color.new(color.fuchsia, 90) : na, title="SFP Bear BG")

// ─── PLOTSHAPES ──────────────────────────────────────────────────────────────
plotshape(full_bull_signal,                               title="Full Bull Signal", location=location.belowbar, style=shape.triangleup,   color=col_full_bull, size=size.large)
plotshape(full_bear_signal,                               title="Full Bear Signal", location=location.abovebar, style=shape.triangledown, color=col_full_bear, size=size.large)
plotshape(sfp_bull and not full_bull_signal and show_sfp, title="SFP Bullish",      location=location.belowbar, style=shape.triangleup,   color=col_sfp_bull,  size=size.normal)
plotshape(sfp_bear and not full_bear_signal and show_sfp, title="SFP Bearish",      location=location.abovebar, style=shape.triangledown, color=col_sfp_bear,  size=size.normal)
plotshape(new_good_low  and show_good_lows,               title="Good Low",         location=location.belowbar, style=shape.circle,       color=col_good_low,  size=size.small)
plotshape(new_good_high and show_good_highs,              title="Good High",        location=location.abovebar, style=shape.circle,       color=col_good_high, size=size.small)
plotshape(new_bad_low   and show_bad_lows,                title="Bad Low",          location=location.belowbar, style=shape.xcross,       color=col_bad_low,   size=size.tiny)
plotshape(new_bad_high  and show_bad_highs,               title="Bad High",         location=location.abovebar, style=shape.xcross,       color=col_bad_high,  size=size.tiny)

// ─── ALERT CONDITIONS ────────────────────────────────────────────────────────
// FIX #1-4: alertcondition message must be const string — no input variable concatenation
// Set your ticker in the TradingView alert dialog under "Alert Name"

alertcondition(full_bull_signal,
     title   = "🔥 FULL BULL — SFP + Confluence",
     message = '{"signal":"FULL_BULL","timeframe":"30m","note":"SFP bull fired in confluence zone — HIGH PROBABILITY LONG. Check MA/POC/Fib alignment."}')

alertcondition(full_bear_signal,
     title   = "🔥 FULL BEAR — SFP + Confluence",
     message = '{"signal":"FULL_BEAR","timeframe":"30m","note":"SFP bear fired in confluence zone — HIGH PROBABILITY SHORT. Check MA/POC/Fib alignment."}')

alertcondition(new_good_low,
     title   = "✅ Good Low Confirmed",
     message = '{"signal":"GOOD_LOW","timeframe":"30m","note":"Good Low confirmed — price accepted at extreme, expect higher."}')

alertcondition(new_good_high,
     title   = "🔴 Good High Confirmed",
     message = '{"signal":"GOOD_HIGH","timeframe":"30m","note":"Good High confirmed — price accepted at extreme, expect lower."}')

alertcondition(new_bad_low,
     title   = "⚠️ Bad Low — Expect Return",
     message = '{"signal":"BAD_LOW","timeframe":"30m","note":"Bad Low — only 1 candle at extreme. Expect price to return and put in a better low."}')

alertcondition(new_bad_high,
     title   = "⚠️ Bad High — Expect Return",
     message = '{"signal":"BAD_HIGH","timeframe":"30m","note":"Bad High — only 1 candle at extreme. Expect price to return and put in a better high."}')

alertcondition(sfp_bull,
     title   = "SFP Bullish",
     message = '{"signal":"SFP_BULL","timeframe":"30m","note":"Bullish SFP — stop hunt below prior low, closed above. Check confluence score."}')

alertcondition(sfp_bear,
     title   = "SFP Bearish",
     message = '{"signal":"SFP_BEAR","timeframe":"30m","note":"Bearish SFP — stop hunt above prior high, closed below. Check confluence score."}')

// ─── INFO TABLE ──────────────────────────────────────────────────────────────
// FIX #5: Removed invalid colspan argument from table.cell
var table t = table.new(position.top_right, 2, 10, bgcolor=color.new(color.black, 65), border_width=1, border_color=color.gray)

if barstate.islast
    // Header row — two cells instead of colspan
    table.cell(t, 0, 0, "Good Low/High System", text_color=color.white,  text_size=size.large, bgcolor=color.new(color.navy, 30))
    table.cell(t, 1, 0, "v1.2 | 30m",           text_color=color.yellow, text_size=size.large, bgcolor=color.new(color.navy, 30))

    // MA
    ma_status = close > ma_val ? "▲ ABOVE" : "▼ BELOW"
    ma_col    = close > ma_val ? color.lime : color.red
    table.cell(t, 0, 1, "MA" + str.tostring(ma_len), text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 1, str.tostring(ma_val, "#.##") + " " + ma_status, text_color=ma_col, text_size=size.normal)

    // POC
    table.cell(t, 0, 2, "POC (approx)", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 2, not na(poc_val) ? str.tostring(poc_val, "#.##") : "calc...", text_color=col_poc, text_size=size.normal)

    // Fib levels
    table.cell(t, 0, 3, "Fib 0.618 Bear", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 3, str.tostring(fib_618, "#.##"), text_color=col_fib, text_size=size.normal)
    table.cell(t, 0, 4, "Fib 0.618 Bull", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 4, str.tostring(fib_618_bull, "#.##"), text_color=color.new(color.purple, 30), text_size=size.normal)

    // Confluence scores
    bull_col = bull_conf_score >= min_confluence ? color.lime : color.gray
    bear_col = bear_conf_score >= min_confluence ? color.red  : color.gray
    table.cell(t, 0, 5, "Bull Confluence", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 5, str.tostring(bull_conf_score) + "/3 " + (in_bull_confluence ? "✅" : ""), text_color=bull_col, text_size=size.normal)
    table.cell(t, 0, 6, "Bear Confluence", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 6, str.tostring(bear_conf_score) + "/3 " + (in_bear_confluence ? "🔴" : ""), text_color=bear_col, text_size=size.normal)

    // Tracked levels
    table.cell(t, 0, 7, "Tracked Low",  text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 7, not na(tracked_low) ? str.tostring(tracked_low, "#.##") + " (" + str.tostring(low_count) + "c)" : "—", text_color=color.lime, text_size=size.normal)
    table.cell(t, 0, 8, "Tracked High", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 8, not na(tracked_high) ? str.tostring(tracked_high, "#.##") + " (" + str.tostring(high_count) + "c)" : "—", text_color=color.red, text_size=size.normal)

    // VAH / VAL
    table.cell(t, 0, 9, "VAH / VAL", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 9, not na(vah) ? str.tostring(vah, "#.##") + " / " + str.tostring(val_level, "#.##") : "calc...", text_color=color.yellow, text_size=size.normal)
````
