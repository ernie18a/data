# Order Block AI [PickMyTrade]

- url: https://www.tradingview.com/script/0bvhsx2x-Order-Block-AI-PickMyTrade/
- type: indicator
- pine_id: PUB;a81029387895400e80d66459dc982479
- version: 1.0

## Description

Most Order Block indicators draw zones and leave you guessing which ones to trade. Order Block AI adds a machine learning engine that learns from every historical order block retest on your chart — comparing current market conditions to past setups and returning a data-driven confidence score before you enter.

The core engine is [b]K-Nearest Neighbors (KNN)[/b] with Lorentzian distance. Rather than applying fixed rules, it stores every past order block retest as a feature vector — RSI level, volume strength, and ADX trend reading at the moment of retest. It then records what happened: did price reach the take profit or reverse to the stop? On each new signal, the model finds the K most similar historical episodes and votes on the likely outcome. The confidence % you see on the label is the model's output — not a static threshold, but a score that adapts as new market data resolves.

────────────────────────────────────

[b]3 Layers of Confirmation[/b]

[b]Layer 1 · Market Structure[/b]
Pivot-based detection of confirmed swing highs and lows:
[list]
[*] BOS (Break of Structure) — trend continuation
[*] CHoCH (Change of Character) — first counter-trend break, potential reversal
[/list]

[b]Layer 2 · Order Block + Liquidity Sweep[/b]
[list]
[*] Bullish OB — last bearish candle before a bullish structure break
[*] Bearish OB — last bullish candle before a bearish structure break
[*] Liquidity Sweep — wick beyond last swing that closes back inside (stop hunt)
[/list]
A signal requires price to actively retest the OB zone. No retest = no signal.

[b]Layer 3 · KNN Classification[/b]
When a retest occurs, the KNN engine retrieves the K most similar historical setups using Lorentzian distance — a log-space metric that handles outliers better than standard Euclidean distance. The confidence score reflects how many of those K analogues resolved in the signal direction. The model updates continuously as past signals resolve, meaning it gets more informed over time without any manual adjustment.

[b]Signal fires only when all 3 align:[/b]
[i]CHoCH or Liquidity Sweep → Order Block Retest → KNN Confidence ≥ Threshold[/i]

────────────────────────────────────

[b]Non-Repainting[/b]
Pivots require full left + right bar confirmation before any signal is issued. The label appears at the confirmed bar — what you see is what was tradeable at the time.

────────────────────────────────────

[b]Settings[/b]

[b]Market Structure[/b]
[list]
[*] Pivot Left / Right Bars — confirmation bars for swing detection
[/list]

[b]Order Blocks[/b]
[list]
[*] Show/hide zones, bull and bear colors
[/list]

[b]Fair Value Gaps[/b]
[list]
[*] Show/hide 3-candle imbalance zones (visual context only — does not affect signals)
[/list]

[b]KNN Engine[/b]
[list]
[*] [b]K Neighbors[/b] — how many historical analogues vote on the signal (default 5)
[*] [b]History Length[/b] — maximum past signals stored for KNN learning (default 200)
[*] [b]Min Confidence[/b] — minimum fraction of K neighbors that must agree to fire a signal (default 0.60)
[*] [b]Outcome Bars[/b] — bars after a historical signal to evaluate its outcome (default 20)
[/list]

[b]Risk Management[/b]
[list]
[*] ATR Stop Multiplier and R:R Ratio — used by the KNN engine to score whether past signals reached TP or SL
[/list]

[b]Display[/b]
[list]
[*] [b]Zen Mode[/b] — hides all visuals except entry signal labels
[*] Show/hide BOS and CHoCH structure labels
[/list]

────────────────────────────────────

[b]Alerts[/b]
[list]
[*] OB AI Long Signal
[*] OB AI Short Signal
[/list]

────────────────────────────────────

[b]Notes[/b]
[list]
[*] The KNN engine improves as it accumulates more resolved historical setups — give it time on the first load
[*] Works on any symbol and timeframe
[*] Lower the confidence threshold to see more signals; raise it to filter more aggressively
[*] Fair Value Gap zones are displayed as context — they do not affect signal logic
[/list]

────────────────────────────────────

[b]Risk Disclosure[/b]
Confidence scores reflect the frequency of past patterns in the KNN training history — they do not guarantee future outcomes. Use in combination with your own position sizing and risk management. Not financial advice.

## Source Code

````pine
//@version=6
indicator("Order Block AI [PickMyTrade]",
    overlay          = true,
    max_labels_count = 300,
    max_lines_count  = 200,
    max_boxes_count  = 100)

// ═══════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════
var string G_STRUCT = "Market Structure"
var string G_OB     = "Order Blocks"
var string G_FVG    = "Fair Value Gaps"
var string G_KNN    = "KNN · ML Engine"
var string G_RISK   = "Risk Management"
var string G_DISP   = "Display"

i_piv_left   = input.int  (10,    "Pivot Left Bars",    minval=3,  maxval=50,  group=G_STRUCT, tooltip="Left confirmation bars for swing high/low detection")
i_piv_right  = input.int  (10,    "Pivot Right Bars",   minval=3,  maxval=50,  group=G_STRUCT, tooltip="Right confirmation bars — signal is delayed by this many bars (non-repainting)")
i_show_ob    = input.bool (true,  "Show Order Blocks",              group=G_OB)
i_ob_bull_c  = input.color(color.new(#2196F3, 80), "Bull OB",      group=G_OB)
i_ob_bear_c  = input.color(color.new(#FF5252, 80), "Bear OB",      group=G_OB)
i_show_fvg   = input.bool (true,  "Show Fair Value Gaps",           group=G_FVG)
i_fvg_bull_c = input.color(color.new(#26A69A, 80), "Bull FVG",     group=G_FVG)
i_fvg_bear_c = input.color(color.new(#EF5350, 80), "Bear FVG",     group=G_FVG)
i_k          = input.int  (5,     "K Neighbors",        minval=3,  maxval=15,  group=G_KNN, tooltip="Number of nearest historical analogues to vote on the signal")
i_knn_len    = input.int  (200,   "History Length",     minval=50, maxval=500, group=G_KNN, tooltip="Maximum past signals stored for KNN learning")
i_conf_min   = input.float(0.60,  "Min Confidence",     minval=0.5, maxval=1.0, step=0.05,  group=G_KNN, tooltip="Minimum fraction of K neighbors that must agree to trigger an entry")
i_out_bars   = input.int  (20,    "Outcome Bars",       minval=5,  maxval=50,  group=G_KNN, tooltip="Bars after a historical signal to evaluate its outcome (TP reached = success)")
i_sl_mult    = input.float(1.5,   "SL ATR Multiplier",  minval=0.5, maxval=5.0, step=0.25, group=G_RISK)
i_rr         = input.float(2.0,   "R:R Ratio",          minval=1.0, maxval=10.0, step=0.5, group=G_RISK, tooltip="Take profit = SL distance × R:R")
i_zen        = input.bool (false, "Zen Mode",                        group=G_DISP, tooltip="Hide all visuals except entry signal labels")
i_show_str   = input.bool (true,  "Show Structure Labels",           group=G_DISP)

// ═══════════════════════════════════════════════════════════════
// BASE CALCULATIONS
// ═══════════════════════════════════════════════════════════════
_atr       = ta.atr(14)
_rsi       = ta.rsi(close, 14)
_vol_avg   = ta.sma(volume, 20)
_vol_ratio = volume / (_vol_avg + 1e-10)

_tr   = math.max(high - low, math.abs(high - close[1]), math.abs(low - close[1]))
_dmp  = high - high[1] > low[1] - low ? math.max(high - high[1], 0.0) : 0.0
_dmm  = low[1] - low > high - high[1] ? math.max(low[1] - low, 0.0) : 0.0
_atr14 = ta.rma(_tr, 14)
_dip  = ta.rma(_dmp, 14) / (_atr14 + 1e-10) * 100
_dim  = ta.rma(_dmm, 14) / (_atr14 + 1e-10) * 100
_dx   = math.abs(_dip - _dim) / (_dip + _dim + 1e-10) * 100
_adx  = ta.rma(_dx, 14)

// ═══════════════════════════════════════════════════════════════
// MARKET STRUCTURE — Pivots, BOS, CHoCH
// ═══════════════════════════════════════════════════════════════
_ph = ta.pivothigh(high, i_piv_left, i_piv_right)
_pl = ta.pivotlow (low,  i_piv_left, i_piv_right)

var float last_ph    = na
var float last_pl    = na
var bool  in_uptrend = false
var bool  in_dntrend = false

ph_confirmed = not na(_ph)
pl_confirmed = not na(_pl)

if ph_confirmed
    last_ph := _ph
if pl_confirmed
    last_pl := _pl

_cross_bull = ta.crossover (close, last_ph)
_cross_bear = ta.crossunder(close, last_pl)
bos_bull  = not na(last_ph) and _cross_bull
bos_bear  = not na(last_pl) and _cross_bear

choch_bull = bos_bull and in_dntrend
choch_bear = bos_bear and in_uptrend

if bos_bull
    in_uptrend := true
    in_dntrend := false
if bos_bear
    in_dntrend := true
    in_uptrend := false

if i_show_str and not i_zen
    if choch_bull
        label.new(bar_index, low - _atr * 1.2, "CHoCH ▲",
            color=color.new(#26A69A,65), textcolor=#26A69A,
            style=label.style_label_up, size=size.tiny)
    else if bos_bull
        label.new(bar_index, low - _atr * 0.6, "BOS",
            color=color.new(#26A69A,80), textcolor=#26A69A,
            style=label.style_label_up, size=size.tiny)
    if choch_bear
        label.new(bar_index, high + _atr * 1.2, "CHoCH ▼",
            color=color.new(#EF5350,65), textcolor=#EF5350,
            style=label.style_label_down, size=size.tiny)
    else if bos_bear
        label.new(bar_index, high + _atr * 0.6, "BOS",
            color=color.new(#EF5350,80), textcolor=#EF5350,
            style=label.style_label_down, size=size.tiny)

// ═══════════════════════════════════════════════════════════════
// ORDER BLOCKS
// ═══════════════════════════════════════════════════════════════
var float ob_bull_hi = na
var float ob_bull_lo = na
var float ob_bear_hi = na
var float ob_bear_lo = na
var box   ob_bull_bx = na
var box   ob_bear_bx = na

if bos_bull or choch_bull
    for i = 1 to 10
        if close[i] < open[i]
            ob_bull_hi := high[i]
            ob_bull_lo := low[i]
            break
    if i_show_ob and not i_zen and not na(ob_bull_hi)
        box.delete(ob_bull_bx)
        ob_bull_bx := box.new(bar_index - 1, ob_bull_hi, bar_index + 40, ob_bull_lo,
            border_color=color.new(#2196F3, 40), bgcolor=i_ob_bull_c)

if bos_bear or choch_bear
    for i = 1 to 10
        if close[i] > open[i]
            ob_bear_hi := high[i]
            ob_bear_lo := low[i]
            break
    if i_show_ob and not i_zen and not na(ob_bear_hi)
        box.delete(ob_bear_bx)
        ob_bear_bx := box.new(bar_index - 1, ob_bear_hi, bar_index + 40, ob_bear_lo,
            border_color=color.new(#FF5252, 40), bgcolor=i_ob_bear_c)

// ═══════════════════════════════════════════════════════════════
// FAIR VALUE GAPS
// ═══════════════════════════════════════════════════════════════
bull_fvg = low > high[2] and (low - high[2]) > _atr * 0.1
bear_fvg = high < low[2] and (low[2] - high) > _atr * 0.1

var box fvg_bull_bx = na
var box fvg_bear_bx = na

if i_show_fvg and not i_zen
    if bull_fvg
        box.delete(fvg_bull_bx)
        fvg_bull_bx := box.new(bar_index - 2, low, bar_index + 30, high[2],
            border_color=color.new(#26A69A, 50), bgcolor=i_fvg_bull_c)
    if bear_fvg
        box.delete(fvg_bear_bx)
        fvg_bear_bx := box.new(bar_index - 2, low[2], bar_index + 30, high,
            border_color=color.new(#EF5350, 50), bgcolor=i_fvg_bear_c)

// ═══════════════════════════════════════════════════════════════
// LIQUIDITY SWEEPS
// ═══════════════════════════════════════════════════════════════
sweep_bull = not na(last_pl) and low < last_pl and close > last_pl
sweep_bear = not na(last_ph) and high > last_ph and close < last_ph

// ═══════════════════════════════════════════════════════════════
// ORDER BLOCK RETEST CHECK
// ═══════════════════════════════════════════════════════════════
ob_bull_touch = not na(ob_bull_hi) and low <= ob_bull_hi and close >= ob_bull_lo - _atr * 0.5
ob_bear_touch = not na(ob_bear_lo) and high >= ob_bear_lo and close <= ob_bear_hi + _atr * 0.5

// ═══════════════════════════════════════════════════════════════
// KNN · LORENTZIAN ML ENGINE
// ═══════════════════════════════════════════════════════════════
var float[] h_f1  = array.new_float(0)
var float[] h_f2  = array.new_float(0)
var float[] h_f3  = array.new_float(0)
var int[]   h_lbl = array.new_int(0)

var int[]   p_dir   = array.new_int(0)
var int[]   p_bar   = array.new_int(0)
var float[] p_entry = array.new_float(0)
var float[] p_tp    = array.new_float(0)
var float[] p_sl    = array.new_float(0)
var float[] p_f1    = array.new_float(0)
var float[] p_f2    = array.new_float(0)
var float[] p_f3    = array.new_float(0)

if array.size(p_bar) > 0
    for i = array.size(p_bar) - 1 to 0
        if bar_index - array.get(p_bar, i) >= i_out_bars
            dir = array.get(p_dir, i)
            tp  = array.get(p_tp, i)
            sl  = array.get(p_sl, i)
            outcome = 0
            if dir == 1
                outcome := high >= tp ? 1 : (low <= sl ? -1 : 0)
            else
                outcome := low <= tp ? -1 : (high >= sl ? 1 : 0)
            result = (dir == 1 and outcome == 1) or (dir == -1 and outcome == -1) ? 1 : 0
            array.push(h_f1,  array.get(p_f1, i))
            array.push(h_f2,  array.get(p_f2, i))
            array.push(h_f3,  array.get(p_f3, i))
            array.push(h_lbl, result)
            if array.size(h_f1) > i_knn_len
                array.shift(h_f1)
                array.shift(h_f2)
                array.shift(h_f3)
                array.shift(h_lbl)
            array.remove(p_dir,   i)
            array.remove(p_bar,   i)
            array.remove(p_entry, i)
            array.remove(p_tp,    i)
            array.remove(p_sl,    i)
            array.remove(p_f1,    i)
            array.remove(p_f2,    i)
            array.remove(p_f3,    i)

cur_f1 = _rsi / 100.0
cur_f2 = math.min(_vol_ratio, 5.0) / 5.0
cur_f3 = math.min(_adx / 50.0, 1.0)

lor(a1, a2, b1, b2, c1, c2) => math.log(1.0 + math.abs(a1 - a2)) + math.log(1.0 + math.abs(b1 - b2)) + math.log(1.0 + math.abs(c1 - c2))

knn_conf() =>
    n = math.min(array.size(h_f1), array.size(h_lbl))
    if n < i_k
        0.0
    else
        tmp_d = array.copy(h_f1)
        tmp_l = array.copy(h_lbl)
        for j = 0 to n - 1
            d = lor(cur_f1, array.get(h_f1, j),
                    cur_f2, array.get(h_f2, j),
                    cur_f3, array.get(h_f3, j))
            array.set(tmp_d, j, d)
        wins  = 0
        total = 0
        for _ = 0 to math.min(i_k, n) - 1
            min_i = 0
            min_v = array.get(tmp_d, 0)
            for j = 1 to array.size(tmp_d) - 1
                if array.get(tmp_d, j) < min_v
                    min_v := array.get(tmp_d, j)
                    min_i := j
            wins  += array.get(tmp_l, min_i)
            total += 1
            array.remove(tmp_d, min_i)
            array.remove(tmp_l, min_i)
        total > 0 ? wins / total : 0.0

// ═══════════════════════════════════════════════════════════════
// SIGNAL GENERATION
// ═══════════════════════════════════════════════════════════════
bull_trigger = (choch_bull or sweep_bull) and ob_bull_touch
bear_trigger = (choch_bear or sweep_bear) and ob_bear_touch

var float _conf_long  = 0.0
var float _conf_short = 0.0

long_sig  = false
short_sig = false

if bull_trigger
    c = knn_conf()
    _conf_long := c
    long_sig   := c >= i_conf_min

if bear_trigger
    c = knn_conf()
    _conf_short := c
    short_sig   := c >= i_conf_min

if long_sig
    float _sl = low - _atr * i_sl_mult
    float _tp = low + _atr * i_sl_mult * i_rr
    array.push(p_dir,   1)
    array.push(p_bar,   bar_index)
    array.push(p_entry, close)
    array.push(p_tp,    _tp)
    array.push(p_sl,    _sl)
    array.push(p_f1,    cur_f1)
    array.push(p_f2,    cur_f2)
    array.push(p_f3,    cur_f3)

if short_sig
    float _sl = high + _atr * i_sl_mult
    float _tp = high - _atr * i_sl_mult * i_rr
    array.push(p_dir,   -1)
    array.push(p_bar,   bar_index)
    array.push(p_entry, close)
    array.push(p_tp,    _tp)
    array.push(p_sl,    _sl)
    array.push(p_f1,    cur_f1)
    array.push(p_f2,    cur_f2)
    array.push(p_f3,    cur_f3)

// ═══════════════════════════════════════════════════════════════
// SIGNAL LABELS
// ═══════════════════════════════════════════════════════════════
var label _lbl_long  = na
var label _lbl_short = na

if long_sig
    label.delete(_lbl_long)
    _lbl_long := label.new(
        x         = bar_index,
        y         = low - _atr * 3.0,
        text      = "OB Long\n" + str.tostring(math.round(_conf_long * 100)) + "% confidence",
        color     = color.new(#2196F3, 60),
        textcolor = #2196F3,
        style     = label.style_label_up,
        size      = size.small)

if short_sig
    label.delete(_lbl_short)
    _lbl_short := label.new(
        x         = bar_index,
        y         = high + _atr * 3.0,
        text      = "OB Short\n" + str.tostring(math.round(_conf_short * 100)) + "% confidence",
        color     = color.new(#FF5252, 60),
        textcolor = #FF5252,
        style     = label.style_label_down,
        size      = size.small)

// ═══════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(long_sig,  "OB AI Long Signal",  "Order Block AI [PickMyTrade] — Long signal triggered")
alertcondition(short_sig, "OB AI Short Signal", "Order Block AI [PickMyTrade] — Short signal triggered")
````
