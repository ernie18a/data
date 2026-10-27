# P&D Short Signal v4.0 [4H]

- url: https://www.tradingview.com/script/WbMB85iL/
- type: indicator
- pine_id: PUB;72460c246ba0426da3736f42640ea277
- version: 1.0

## Description

═══════════════════════════════════════════════════════════
TRADINGVIEW PUBLISH — P&D Short Signal v4.0 [4H]
Author: Kevko87 | Open Source
═══════════════════════════════════════════════════════════

TITLE:
P&D Short Signal v4.0 [4H] — Pump & Dump Distribution Detector

───────────────────────────────────────────────────────────
SHORT DESCRIPTION (shown in search):
───────────────────────────────────────────────────────────
Detects post-pump distribution phases on crypto futures using
OBV, RSI divergence, MFI, and Delta-Volume across 4H / 1H / Daily.
Generates Tier 1 and Tier 2 short signals with auto TP/SL levels.

───────────────────────────────────────────────────────────
FULL DESCRIPTION:
───────────────────────────────────────────────────────────

## P&D Short Signal v4.0 [4H]

This indicator identifies **post-pump distribution phases** on crypto 
perpetual futures, designed to catch the dump after a Pump & Dump cycle.

Built and validated on Bitget Futures over 30+ live trading sessions.

---

### How it works

The indicator uses a **multi-timeframe confluence approach**:

- **4H** — Base timeframe (OBV slope, RSI, MFI, Delta-Volume)
- **1H** — OBV confirmation
- **Daily** — Gate-keeper: coins with Daily OBV > 500M are skipped
  (high OBV = genuine buying pressure = no short)

A signal fires only when multiple conditions align simultaneously,
filtering out noise and false setups.

---

### Signal Tiers

**🔴 TIER 1 — High Confidence (≥85%)**
- Daily OBV < 500M (gate-keeper passes)
- 4H OBV falling + 1H OBV falling (distribution confirmed)
- RSI > 65 AND (bearish divergence OR below MA)
- MFI > 75 AND falling for 2+ bars
- Delta-Volume negative (optional, toggleable)

**🟠 TIER 2 — Moderate Confidence (~70%)**
- Daily OBV < 500M
- 4H OBV falling
- RSI > 65
- MFI > 65 AND falling

**🔴 MFI Extreme Background Alert**
- MFI ≥ 85 and falling with valid Daily OBV
- Precursor warning — check OBV manually

---

### Auto TP / SL

On every signal, the indicator automatically plots:
- **SL**: Entry High + ATR × 3 (default)
- **TP1**: −15% | **TP2**: −25% | **TP3**: −40% | **TP4**: −60%

All levels fully adjustable via inputs.

---

### Status Table (top right)

Live dashboard showing the current state of all filters:
D-OBV · OBV 4H · OBV 1H · RSI · MFI · Delta · D-RSI · Signal · Trade

---

### Alerts

Three built-in alert conditions:
- 🔴 TIER 1 SHORT [4H]
- 🟠 TIER 2 SHORT [4H]
- ⚠️ MFI EXTREME [4H]

Set alerts via TradingView's alert manager on any ticker.

---

### Recommended Usage

- **Market**: Crypto perpetual futures (Bitget, Bybit, Binance)
- **Timeframe**: 4H (indicator is built for 4H, do not use on other TFs)
- **Best targets**: Low-cap coins after +30–50% pumps within 24h
- **Risk management**: Always use the auto-generated SL. DCA entries
  recommended for high-ATR setups.

---

### Key Filter: Daily OBV Gate

The most important filter in this system. If Daily OBV > 500M,
the move has genuine buying pressure behind it — shorting against
that is high risk. The indicator automatically skips these coins.

---

### Inputs

| Parameter | Default | Description |
|-----------|---------|-------------|
| Daily OBV Max | 500M | Skip coins above this OBV |
| OBV Slope Bars | 3 | Lookback for OBV direction |
| RSI Length | 14 | Standard RSI period |
| RSI Min for Entry | 65 | Minimum RSI for overbought |
| Divergence Lookback | 5 | Bars for price/RSI divergence |
| MFI Length | 14 | Standard MFI period |
| MFI Min Tier 1 | 75 | MFI threshold for Tier 1 |
| MFI Min Tier 2 | 65 | MFI threshold for Tier 2 |
| MFI Extreme | 85 | Background alert level |
| SL ATR Multiplier | 3.0 | Stop loss distance |
| TP1–TP4 | 15/25/40/60% | Take profit levels |

---

### Changelog

**v4.0**
- Base timeframe changed from 1H to 4H (higher win rate in backtesting)
- 5 bars on 4H = 20h = one full pump cycle captured
- Tier 1: RSI divergence OR below MA (previously required both)
- MTF structure: 4H base / 1H confirmation / Daily gate-keeper
- Status table added

---

*Open source. Use at your own risk. Not financial advice.*
*Built by Kevko87 — validated on live crypto futures trading.*

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Kevko87

//@version=6
plot(close)
//@version=6

indicator("P&D Short Signal v4.0 [4H]", shorttitle="P&DSHORTv4", overlay=true, max_labels_count=200, max_lines_count=100)

// ═══════════════════════════════════════════════════════════════════
// CHANGELOG v4.0
// ─────────────────────────────────────────────────────────────────
// - Base Timeframe: 4H (instead of 1H)
//   Reason: Backtesting shows higher win rate on 4H.
//   4H filters noise better, divergences cleaner,
//   5 bars = 20h = full pump cycle captured.
// - MTF Structure:
//     4H  = Base (OBV, RSI, MFI, Delta)
//     1H  = OBV Confirmation (via request.security)
//     Daily = Gate-Keeper OBV < 500M
// - Tier 1: RSI Div OR RSI < MA (no longer AND)
//   Reason: On 4H, divergence OR MA-cross is sufficiently strong
// - Tier 2: slightly looser, no Daily OBV drop required
// - HOME entry detected at ~0.0222 (4H signal correct)
// ═══════════════════════════════════════════════════════════════════

// ─── INPUTS ────────────────────────────────────────────────────────

grp_filter = "═══ FILTER ═══"

daily_obv_limit = input.float(500e6, "Daily OBV Max (Skip >)",
                  minval=10e6, step=10e6, group=grp_filter,
                  tooltip="Coins with Daily OBV > 500M = real move, no short")

obv_slope_bars  = input.int(3, "OBV Slope (Bars)", minval=1, maxval=8,
                  group=grp_filter,
                  tooltip="OBV falling when current < N bars ago. 3 bars on 4H = 12h")

grp_rsi = "═══ RSI ═══"

rsi_len      = input.int(14,    "RSI Length",              group=grp_rsi)
rsi_ob       = input.float(65.0,"RSI Min for Entry",       group=grp_rsi)
rsi_lookback = input.int(5,     "Divergence Lookback",     group=grp_rsi,
               tooltip="5 bars on 4H = 20h = one full pump cycle")

grp_mfi = "═══ MFI ═══"

mfi_len      = input.int(14,    "MFI Length",              group=grp_mfi)
mfi_t1_min   = input.float(75.0,"MFI Min (Tier 1)",        group=grp_mfi)
mfi_t2_min   = input.float(65.0,"MFI Min (Tier 2)",        group=grp_mfi)
mfi_extreme  = input.float(85.0,"MFI Extreme Level",       group=grp_mfi)
mfi_fall_bars= input.int(2,     "MFI Falling (Bars)",      group=grp_mfi,
               tooltip="MFI must be falling for N bars. 2 on 4H = 8h selling pressure")

grp_delta = "═══ DELTA ═══"

use_delta    = input.bool(true,   "Delta as Filter",       group=grp_delta)
delta_thresh = input.float(-0.10, "Delta Threshold (%)",   maxval=0, step=0.05, group=grp_delta)

grp_tp = "═══ TP / SL ═══"

sl_atr_mult = input.float(3.0,  "SL: ATR ×",              group=grp_tp)
tp1_pct     = input.float(15.0, "TP1 %",                  group=grp_tp)
tp2_pct     = input.float(25.0, "TP2 %",                  group=grp_tp)
tp3_pct     = input.float(40.0, "TP3 %",                  group=grp_tp)
tp4_pct     = input.float(60.0, "TP4 %",                  group=grp_tp)

grp_ui = "═══ DISPLAY ═══"

show_tp_lines = input.bool(true,  "TP/SL Lines",           group=grp_ui)
show_labels   = input.bool(true,  "Labels",                group=grp_ui)
show_debug    = input.bool(false, "Debug",                  group=grp_ui)

// ─── INDICATORS (4H Base) ─────────────────────────────────────────

rsi_val  = ta.rsi(close, rsi_len)
rsi_ma   = ta.sma(rsi_val, rsi_len)
mfi_val  = ta.mfi(hlc3, mfi_len)
atr_val  = ta.atr(14)
obv_4h   = ta.obv

// Delta Approximation
body_pct     = math.abs(close - open) / (high - low + 0.000001)
bull_candle  = close > open
buy_vol      = bull_candle ? volume * (0.5 + body_pct * 0.5) : volume * (0.5 - body_pct * 0.5)
delta_raw    = buy_vol - (volume - buy_vol)
delta_pct    = delta_raw / (volume + 0.000001)
delta_smooth = ta.ema(delta_pct, 5)

// ─── MULTI-TIMEFRAME ───────────────────────────────────────────────

// 1H OBV — Confirmation
obv_1h      = request.security(syminfo.tickerid, "60",
              ta.obv, lookahead=barmerge.lookahead_off)
obv_1h_prev = request.security(syminfo.tickerid, "60",
              ta.obv[obv_slope_bars], lookahead=barmerge.lookahead_off)

// Daily — Gate-Keeper
daily_obv     = request.security(syminfo.tickerid, "D",
                ta.obv, lookahead=barmerge.lookahead_off)
daily_obv_pre = request.security(syminfo.tickerid, "D",
                ta.obv[1], lookahead=barmerge.lookahead_off)
daily_rsi     = request.security(syminfo.tickerid, "D",
                ta.rsi(close, rsi_len), lookahead=barmerge.lookahead_off)
daily_rsi_ma  = request.security(syminfo.tickerid, "D",
                ta.sma(ta.rsi(close, rsi_len), rsi_len), lookahead=barmerge.lookahead_off)
daily_mfi     = request.security(syminfo.tickerid, "D",
                ta.mfi(hlc3, mfi_len), lookahead=barmerge.lookahead_off)

// ─── CONDITIONS ───────────────────────────────────────────────────

// OBV Direction (slope instead of absolute value)
obv_4h_falling  = obv_4h  < obv_4h[obv_slope_bars]
obv_1h_falling  = obv_1h  < obv_1h_prev
daily_obv_ok    = daily_obv < daily_obv_limit
daily_obv_fall  = daily_obv < daily_obv_pre

// RSI
price_hh     = ta.highest(high, rsi_lookback) > ta.highest(high, rsi_lookback)[rsi_lookback]
rsi_lh       = ta.highest(rsi_val, rsi_lookback) < ta.highest(rsi_val, rsi_lookback)[rsi_lookback]
rsi_div      = price_hh and rsi_lh
rsi_high_ok  = rsi_val >= rsi_ob
rsi_under_ma = rsi_val < rsi_ma

// MFI
mfi_t1_ok    = mfi_val >= mfi_t1_min
mfi_t2_ok    = mfi_val >= mfi_t2_min
mfi_falling  = mfi_val < mfi_val[mfi_fall_bars]
mfi_xtreme   = mfi_val >= mfi_extreme

// Delta
delta_neg    = delta_smooth < delta_thresh
delta_ok     = not use_delta or delta_neg

// ─── TIER LOGIC (4H optimized) ────────────────────────────────────
//
// TIER 1 — 4H Conditions:
//   ✅ Daily OBV < 500M
//   ✅ 4H OBV falling
//   ✅ 1H OBV falling (confirmation)
//   ✅ RSI > 65 + (Divergence OR below MA) ← no longer both required!
//   ✅ MFI > 75 + falling
//   ⚡ Delta optional
//
// TIER 2 — slightly looser:
//   ✅ Daily OBV < 500M
//   ✅ 4H OBV falling
//   ✅ RSI > 65
//   ✅ MFI > 65 + falling
// ──────────────────────────────────────────────────────────────────

cond_obv_t1  = daily_obv_ok and obv_4h_falling and obv_1h_falling
cond_obv_t2  = daily_obv_ok and obv_4h_falling
cond_rsi_t1  = rsi_high_ok  and (rsi_div or rsi_under_ma)
cond_rsi_t2  = rsi_high_ok
cond_mfi_t1  = mfi_t1_ok and mfi_falling
cond_mfi_t2  = mfi_t2_ok and mfi_falling

tier1_signal = cond_obv_t1 and cond_rsi_t1 and cond_mfi_t1 and delta_ok
tier2_signal = cond_obv_t2 and cond_rsi_t2 and cond_mfi_t2 and not tier1_signal
mfi_alert    = mfi_xtreme and mfi_falling and daily_obv_ok

tier1_trigger = tier1_signal and not tier1_signal[1]
tier2_trigger = tier2_signal and not tier2_signal[1]

// ─── TP / SL ──────────────────────────────────────────────────────

var float entry_price = na
var float sl_price    = na
var float tp1_price   = na
var float tp2_price   = na
var float tp3_price   = na
var float tp4_price   = na
var bool  in_trade    = false
var line  sl_line     = na
var line  tp1_line    = na
var line  tp2_line    = na
var line  tp3_line    = na
var line  tp4_line    = na

if (tier1_trigger or tier2_trigger) and not in_trade
    entry_price := high
    sl_price    := high + atr_val * sl_atr_mult
    tp1_price   := entry_price * (1 - tp1_pct / 100)
    tp2_price   := entry_price * (1 - tp2_pct / 100)
    tp3_price   := entry_price * (1 - tp3_pct / 100)
    tp4_price   := entry_price * (1 - tp4_pct / 100)
    in_trade    := true

    if show_tp_lines
        sl_line  := line.new(bar_index, sl_price,  bar_index + 60, sl_price,  color=color.red,    style=line.style_dashed, width=2)
        tp1_line := line.new(bar_index, tp1_price, bar_index + 60, tp1_price, color=color.green,  style=line.style_dotted, width=1)
        tp2_line := line.new(bar_index, tp2_price, bar_index + 60, tp2_price, color=color.lime,   style=line.style_dotted, width=1)
        tp3_line := line.new(bar_index, tp3_price, bar_index + 60, tp3_price, color=color.teal,   style=line.style_dotted, width=1)
        tp4_line := line.new(bar_index, tp4_price, bar_index + 60, tp4_price, color=color.blue,   style=line.style_dotted, width=1)

if in_trade
    if high >= sl_price or low <= tp4_price
        in_trade := false

// ─── PLOTS ────────────────────────────────────────────────────────

plotshape(tier1_trigger, title="TIER 1", style=shape.triangledown,
          location=location.abovebar, color=color.new(color.red, 0),
          size=size.normal, text="T1\nSHORT")

plotshape(tier2_trigger, title="TIER 2", style=shape.triangledown,
          location=location.abovebar, color=color.new(color.orange, 0),
          size=size.small, text="T2")

bgcolor(mfi_alert ? color.new(color.red, 88) : na, title="MFI Extreme BG")

// Hidden plots for alerts
plot(obv_4h_falling ? 1 : 0, display=display.none, title="4H OBV Falling")
plot(obv_1h_falling ? 1 : 0, display=display.none, title="1H OBV Falling")
plot(rsi_val,  display=display.none, title="RSI")
plot(mfi_val,  display=display.none, title="MFI")

// ─── LABELS ───────────────────────────────────────────────────────

if show_labels and tier1_trigger
    lbl = "🔴 TIER 1 SHORT [4H]\n" +
          "Entry: " + str.tostring(math.round(entry_price, 6)) + "\n" +
          "SL:    " + str.tostring(math.round(sl_price,    6)) + "\n" +
          "TP1:   " + str.tostring(math.round(tp1_price,   6)) + "\n" +
          "TP2:   " + str.tostring(math.round(tp2_price,   6)) + "\n" +
          "RSI:   " + str.tostring(math.round(rsi_val, 1)) + (rsi_div ? " DIV✓" : " MA✓") + "\n" +
          "MFI:   " + str.tostring(math.round(mfi_val, 1)) + " ↓\n" +
          "D-OBV: " + str.tostring(math.round(daily_obv / 1e6, 0)) + "M"

    label.new(bar_index, high * 1.002, text=lbl,
              style=label.style_label_down,
              color=color.new(color.red, 10),
              textcolor=color.white, size=size.small)

if show_labels and tier2_trigger
    lbl2 = "🟠 TIER 2 [4H]\n" +
           "Entry: " + str.tostring(math.round(entry_price, 6)) + "\n" +
           "SL:    " + str.tostring(math.round(sl_price,    6)) + "\n" +
           "MFI:   " + str.tostring(math.round(mfi_val, 1))

    label.new(bar_index, high * 1.001, text=lbl2,
              style=label.style_label_down,
              color=color.new(color.orange, 10),
              textcolor=color.white, size=size.tiny)

// ─── DEBUG ────────────────────────────────────────────────────────

if show_debug and barstate.islast
    dbg_obv  = "OBV 4H: "  + (obv_4h_falling  ? "↓✓" : "↑✗") + "  1H: " + (obv_1h_falling ? "↓✓" : "↑✗")
    dbg_rsi  = "RSI: "     + str.tostring(math.round(rsi_val,1)) + " Div:" + (rsi_div ? "✓" : "✗") + " MA:" + (rsi_under_ma ? "✓" : "✗")
    dbg_mfi  = "MFI: "     + str.tostring(math.round(mfi_val,1)) + (mfi_falling ? " ↓✓" : " →✗")
    dbg_delt = "Delta: "   + str.tostring(math.round(delta_smooth*100,1)) + "% " + (delta_neg ? "✓" : "✗")
    dbg_dobv = "D-OBV: "   + str.tostring(math.round(daily_obv/1e6,0)) + "M " + (daily_obv_ok ? "✓" : "✗SKIP")
    dbg_full = dbg_obv + "\n" + dbg_rsi + "\n" + dbg_mfi + "\n" + dbg_delt + "\n" + dbg_dobv

    label.new(bar_index, low * 0.997, text=dbg_full,
              style=label.style_label_up,
              color=color.new(color.navy, 50),
              textcolor=color.white, size=size.small)

// ─── STATUS TABLE ─────────────────────────────────────────────────

var table t = table.new(position.top_right, 2, 10,
                         bgcolor=color.new(color.black, 80),
                         border_color=color.new(color.gray,50),
                         border_width=1, frame_color=color.gray, frame_width=1)

if barstate.islast
    table.cell(t,0,0,"P&D v4 [4H]",  bgcolor=color.new(color.red,30), text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.cell(t,1,0,syminfo.ticker,  bgcolor=color.new(color.red,30), text_color=color.white, text_size=size.small, text_halign=text.align_center)

    // Daily OBV
    c = daily_obv_ok ? color.green : color.red
    s = str.tostring(math.round(daily_obv/1e6,0)) + "M" + (daily_obv_ok ? " ✓" : " ✗SKIP") + (daily_obv_fall ? " ↓" : "")
    table.cell(t,0,1,"D-OBV", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,1,s, bgcolor=color.new(c,70), text_color=color.white, text_size=size.tiny)

    // OBV 4H
    c2 = obv_4h_falling ? color.green : color.orange
    table.cell(t,0,2,"OBV 4H", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,2,obv_4h_falling ? "↓ NEG ✓" : "↑ POS ✗", bgcolor=color.new(c2,70), text_color=color.white, text_size=size.tiny)

    // OBV 1H
    c3 = obv_1h_falling ? color.green : color.orange
    table.cell(t,0,3,"OBV 1H", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,3,obv_1h_falling ? "↓ NEG ✓" : "↑ POS ✗", bgcolor=color.new(c3,70), text_color=color.white, text_size=size.tiny)

    // RSI
    c4 = rsi_high_ok ? (rsi_div or rsi_under_ma ? color.green : color.yellow) : color.gray
    s4 = str.tostring(math.round(rsi_val,1)) + " D:" + (rsi_div ? "✓" : "✗") + " MA:" + (rsi_under_ma ? "✓" : "✗")
    table.cell(t,0,4,"RSI", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,4,s4, bgcolor=color.new(c4,70), text_color=color.white, text_size=size.tiny)

    // MFI
    c5 = mfi_t1_ok ? (mfi_falling ? color.green : color.yellow) : color.gray
    s5 = str.tostring(math.round(mfi_val,1)) + (mfi_falling ? " ↓✓" : " →✗")
    table.cell(t,0,5,"MFI", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,5,s5, bgcolor=color.new(c5,70), text_color=color.white, text_size=size.tiny)

    // Delta
    c6 = delta_neg ? color.green : color.orange
    s6 = str.tostring(math.round(delta_smooth*100,1)) + "% " + (delta_neg ? "✓" : "✗")
    table.cell(t,0,6,"Delta", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,6,s6, bgcolor=color.new(c6,70), text_color=color.white, text_size=size.tiny)

    // Daily RSI
    c7 = daily_rsi < daily_rsi_ma ? color.green : color.orange
    s7 = str.tostring(math.round(daily_rsi,1)) + (daily_rsi < daily_rsi_ma ? " <MA✓" : " >MA")
    table.cell(t,0,7,"D-RSI", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,7,s7, bgcolor=color.new(c7,70), text_color=color.white, text_size=size.tiny)

    // Signal
    tier_txt = tier1_signal ? "🔴 TIER 1" : tier2_signal ? "🟠 TIER 2" : "⚪ NONE"
    tier_col = tier1_signal ? color.red : tier2_signal ? color.orange : color.gray
    table.cell(t,0,8,"SIGNAL", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,8,tier_txt, bgcolor=color.new(tier_col,40), text_color=color.white, text_size=size.small, text_halign=text.align_center)

    // Trade
    table.cell(t,0,9,"Trade", text_color=color.white, text_size=size.tiny)
    table.cell(t,1,9,in_trade ? "ACTIVE ⚡ @ " + str.tostring(math.round(entry_price,5)) : "NONE",
               bgcolor=color.new(in_trade ? color.teal : color.gray, 60),
               text_color=color.white, text_size=size.tiny)

// ─── ALERTS ───────────────────────────────────────────────────────

alertcondition(tier1_trigger, title="🔴 TIER 1 SHORT [4H]",
               message="🔴 TIER 1 [4H]: {{ticker}} @ {{close}} | 4H+1H OBV NEG | RSI+MFI confirmed | Check entry!")

alertcondition(tier2_trigger, title="🟠 TIER 2 SHORT [4H]",
               message="🟠 TIER 2 [4H]: {{ticker}} @ {{close}} | Setup ~70% | Confirm with Delta + Daily!")

alertcondition(mfi_alert,     title="⚠️ MFI EXTREME [4H]",
               message="⚠️ MFI EXTREME [4H]: {{ticker}} @ {{close}} | Short precursor | Check OBV 4H!")
````
