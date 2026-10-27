# GOLDM Regime Detector v2.0

- url: https://www.tradingview.com/script/YGblmdQg-GOLDM-Regime-Detector-v2-0/
- type: indicator
- pine_id: PUB;d39ef3b7b78047cc83bf43e09c4bd089
- version: 1.0

## Description

## **GOLDM Regime Detector v2.0**

**Institutional-Grade Options Selling Framework for MCX Gold Mini**

---

### **Overview**

GOLDM Regime Detector v2.0 is a **rule-based decision engine** built for systematic option sellers operating in **MCX Gold Mini (GOLDM)**.

Unlike traditional indicators that generate isolated signals, this framework continuously evaluates market structure and outputs a **complete trading stance** — covering **regime, structure, strike placement, position sizing, and exits**.

The objective is simple:

> **Trade the right structure, in the right environment, with controlled risk.**

---

### **Regime Architecture**

The model classifies market conditions into four execution states:

* **Regime 1 — Premium Selling (Full Size)**
  Range-bound market with stable volatility
  → Deploy **Iron Condors / Strangles**

* **Regime 2 — Directional Selling (Full Size)**
  Orderly trend with controlled volatility
  → Deploy **Credit Spreads aligned with trend**

* **Regime 3 — Reduced Exposure (Half Size)**
  Suboptimal or uncertain conditions
  → Trade **wider strikes with reduced capital**

* **Regime 4 — Defensive Mode**
  Volatility expansion or structural break
  → **No new exposure — manage or exit existing positions**

---

### **Model Construction**

The system integrates multiple dimensions of market behavior:

* **Trend** → EMA slope + ADX (direction + strength)
* **Volatility** → ATR percentile + expansion dynamics
* **Positioning** → Bollinger %B (range vs extremes)
* **Time Risk** → Days to Expiry (DTE constraints)
* **Event Risk** → Manual override for macro events

Each regime is triggered only when conditions align across these factors, ensuring **context-aware execution rather than reactive trading**.

---

### **Strike Engineering**

All strike levels are **systematically derived from ATR**, ensuring consistency across volatility regimes:

* Dynamic distance from spot based on regime quality
* Wider strikes in adverse conditions
* Rounded to **MCX-standard 500 intervals**

This removes discretionary bias from strike selection and aligns risk with market conditions.

---

### **Embedded Risk Framework**

The script includes a predefined exit structure:

* **Profit Capture** → 40–50% premium decay
* **Stop Loss** → Premium expansion threshold (2× entry)
* **Time Exit** → Forced closure near expiry
* **Regime Transition** → Automatic shift to defensive posture
* **Partial Management** → Profit lock-in with trailing logic

---

### **Execution Interface**

* Real-time **regime classification**
* **Suggested structure** (IC / spreads)
* **Strike levels plotted on chart**
* **Confidence score**
* **DTE and event warnings**
* Fully integrated **decision dashboard**

---

### **Usage Guidelines**

* Apply on **MCX:GOLDM1! or front-month futures**
* Optimized for **Daily timeframe**
* Execute systematically — **regime → structure → strikes → risk management**
* Designed for traders prioritizing **process over prediction**

---

### **Positioning**

This framework is built for traders who:

* Prefer **structured decision-making over discretionary trading**
* Want **consistency across market regimes**
* Understand that **edge comes from execution discipline, not prediction**

---

### **Disclaimer**

This tool provides a structured framework for decision-making.
Execution, risk management, and capital allocation remain the responsibility of the user.

---

## Source Code

````pine
// ============================================================================
// GOLDM REGIME DETECTOR v2.0
// Options Selling Decision System for MCX Gold Mini
// ============================================================================
// CHANGES FROM v1:
//   - NO "NO SELL" regime. Replaced with HALF SIZE (50% qty)
//   - Indicative strike levels for every regime (ATR-based)
//   - Exit rules: profit target, stop loss, time-based, regime-shift
//
// APPLY TO: MCX:GOLDM1! (continuous) or nearest month futures — DAILY ONLY
//
// REGIMES:
//   1 = SELL PREMIUM (100% qty) — Strangle / Iron Condor
//   2 = DIRECTIONAL SELL (100% qty) — Credit spread with trend
//   3 = HALF SIZE (50% qty) — Conditions suboptimal but tradeable
//   4 = DEFENSIVE — Adjust existing positions
//
// STRIKE LOGIC:
//   CE strike = Close + (strike_multiplier × ATR)
//   PE strike = Close - (strike_multiplier × ATR)
//   Rounded to nearest 500 (MCX GOLDM strike interval)
//
// EXIT RULES (built into dashboard):
//   - Profit: close at 50% of max premium (Regime 1), 40% (Regime 2/3)
//   - Stop Loss: close if premium doubles (2x entry) 
//   - Time: close if DTE ≤ 5 regardless of P&L
//   - Regime Shift: close/adjust if regime flips to DEFENSIVE
//   - Partial: at 30% profit, trail remaining to breakeven
// ============================================================================

//@version=6
indicator("GOLDM Regime Detector v2.0", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — TREND
// ─────────────────────────────────────────────────────────────────────────────

grp_trend   = "1. TREND"
ema_len     = input.int(50, "EMA Length", minval=10, maxval=200, group=grp_trend)
ema_slope_lookback = input.int(5, "Slope Lookback (bars)", minval=2, maxval=20, group=grp_trend)
adx_len     = input.int(14, "ADX Length", group=grp_trend)
adx_no_trend = input.float(20.0, "ADX: No Trend (<)", minval=10, maxval=30, group=grp_trend)
adx_strong   = input.float(30.0, "ADX: Strong Trend (>)", minval=20, maxval=50, group=grp_trend)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — VOLATILITY
// ─────────────────────────────────────────────────────────────────────────────

grp_vol     = "2. VOLATILITY"
atr_len     = input.int(14, "ATR Length (fast)", group=grp_vol)
atr_slow    = input.int(50, "ATR Length (slow)", group=grp_vol)
atr_rank_lookback = input.int(252, "ATR Percentile Lookback", minval=60, maxval=500, group=grp_vol)
vol_exp_high = input.float(1.5, "Vol Expansion Danger (>)", minval=1.1, maxval=3.0, step=0.1, group=grp_vol)
atr_pct_low  = input.float(25.0, "ATR Pctile: Cheap (<)", minval=5, maxval=40, group=grp_vol)
atr_pct_sell_min = input.float(30.0, "ATR Pctile: Comfortable (≥)", minval=10, maxval=50, group=grp_vol)
atr_pct_sell_max = input.float(70.0, "ATR Pctile: Comfortable (≤)", minval=50, maxval=90, group=grp_vol)
atr_pct_extreme  = input.float(85.0, "ATR Pctile: Extreme (>)", minval=70, maxval=99, group=grp_vol)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — RANGE
// ─────────────────────────────────────────────────────────────────────────────

grp_range   = "3. RANGE"
bb_len      = input.int(20, "Bollinger Length", group=grp_range)
bb_mult     = input.float(2.0, "Bollinger Multiplier", group=grp_range)
bb_low      = input.float(0.20, "BB %B: Range Low (≥)", minval=0.0, maxval=0.5, step=0.05, group=grp_range)
bb_high     = input.float(0.80, "BB %B: Range High (≤)", minval=0.5, maxval=1.0, step=0.05, group=grp_range)
bb_extreme_low  = input.float(0.05, "BB %B: Extreme Low (<)", minval=0.0, maxval=0.2, step=0.01, group=grp_range)
bb_extreme_high = input.float(0.95, "BB %B: Extreme High (>)", minval=0.8, maxval=1.0, step=0.01, group=grp_range)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — STRIKE SELECTION
// ─────────────────────────────────────────────────────────────────────────────

grp_strike  = "4. STRIKES"
strike_interval = input.int(500, "MCX Strike Interval", group=grp_strike, tooltip="GOLDM strikes are in multiples of 500")

// ATR multipliers for strike distance by regime
r1_strike_mult = input.float(1.5, "Regime 1: Strike Distance (×ATR)", minval=0.5, maxval=3.0, step=0.1, group=grp_strike, tooltip="Strangle legs. Higher = wider, less premium, safer")
r2_strike_mult = input.float(1.0, "Regime 2: Sell Strike (×ATR)", minval=0.5, maxval=2.5, step=0.1, group=grp_strike, tooltip="Directional sell side distance from spot")
r3_strike_mult = input.float(2.0, "Regime 3: Half-Size Strike (×ATR)", minval=1.0, maxval=4.0, step=0.1, group=grp_strike, tooltip="Wider strikes when conditions are poor")
hedge_offset   = input.int(2500, "Hedge Wing Offset (from sell strike)", minval=500, maxval=5000, step=500, group=grp_strike, tooltip="Distance of buy leg from sell leg for spreads/IC")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — EXIT RULES
// ─────────────────────────────────────────────────────────────────────────────

grp_exit    = "5. EXIT RULES"
profit_r1   = input.float(50.0, "Regime 1: Profit Target (%)", minval=20, maxval=80, group=grp_exit, tooltip="Close when premium decays to this % of entry")
profit_r2   = input.float(40.0, "Regime 2/3: Profit Target (%)", minval=20, maxval=80, group=grp_exit)
stop_mult   = input.float(2.0, "Stop Loss: Premium Multiple (×)", minval=1.5, maxval=4.0, step=0.5, group=grp_exit, tooltip="Close if premium reaches this multiple of entry. 2x = premium doubled")
trail_trigger = input.float(30.0, "Trail: Trigger at % profit", minval=10, maxval=50, group=grp_exit, tooltip="When this much profit is captured, trail remaining to breakeven")
dte_force_close = input.int(5, "Force Close DTE (≤)", minval=1, maxval=10, group=grp_exit, tooltip="Close ALL positions when DTE hits this")

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS — EXPIRY & EVENT
// ─────────────────────────────────────────────────────────────────────────────

grp_dte     = "6. EXPIRY"
expiry_date = input.time(timestamp("2026-04-28"), "Current Month Expiry Date", group=grp_dte)
dte_cutoff  = input.int(10, "DTE: No new FULL-SIZE positions below", minval=3, maxval=20, group=grp_dte)

grp_event   = "7. EVENT OVERRIDE"
event_flag  = input.bool(false, "⚠ EVENT FLAG (FOMC/CPI/RBI within 3 days)", group=grp_event)

grp_display = "8. DISPLAY"
show_strikes = input.bool(true, "Show Strike Levels on Chart", group=grp_display)
show_bg      = input.bool(true, "Show Regime Background", group=grp_display)
show_table   = input.bool(true, "Show Dashboard Table", group=grp_display)
show_exit    = input.bool(true, "Show Exit Rules in Dashboard", group=grp_display)

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS — CORE SIGNALS
// ─────────────────────────────────────────────────────────────────────────────

// --- TREND ---
ema50       = ta.ema(close, ema_len)
ema_slope   = (ema50 - ema50[ema_slope_lookback]) / ema_slope_lookback
ema_slope_pct = (ema_slope / ema50) * 100

float trend_dir = 0.0
if ema_slope_pct > 0.05
    trend_dir := 1.0
else if ema_slope_pct < -0.05
    trend_dir := -1.0

// --- ADX ---
[diplus, diminus, adx_val] = ta.dmi(adx_len, adx_len)

// --- ATR & VOLATILITY ---
atr_fast    = ta.atr(atr_len)
atr_slow_val = ta.atr(atr_slow)
vol_expansion = atr_fast / atr_slow_val

// ATR Percentile Rank
atr_pctile = 0.0
count_below = 0
for i = 1 to atr_rank_lookback
    if atr_fast[i] < atr_fast
        count_below += 1
atr_pctile := (count_below / atr_rank_lookback) * 100

// ATR spike (3-bar jump)
atr_pctile_3ago = 0.0
count_below_3 = 0
for i = 1 to atr_rank_lookback
    if atr_fast[i] < atr_fast[3]
        count_below_3 += 1
atr_pctile_3ago := (count_below_3 / atr_rank_lookback) * 100
atr_pctile_jump = atr_pctile - atr_pctile_3ago

// --- BOLLINGER %B ---
bb_basis = ta.sma(close, bb_len)
bb_dev   = bb_mult * ta.stdev(close, bb_len)
bb_upper = bb_basis + bb_dev
bb_lower = bb_basis - bb_dev
pct_b    = (close - bb_lower) / (bb_upper - bb_lower)

// --- RSI ---
rsi_val  = ta.rsi(close, 14)

// --- VOLUME ---
vol_sma  = ta.sma(volume, 20)
vol_ratio = volume / vol_sma

// --- DTE ---
dte = math.max(0, math.ceil((expiry_date - time) / (1000 * 60 * 60 * 24)))

// ─────────────────────────────────────────────────────────────────────────────
// CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────

bool is_no_trend     = adx_val < adx_no_trend
bool is_trending     = adx_val >= adx_no_trend
bool is_strong_trend = adx_val >= adx_strong

bool vol_adequate    = atr_pctile >= atr_pct_sell_min and atr_pctile <= atr_pct_sell_max
bool vol_rich        = atr_pctile > atr_pct_sell_max and atr_pctile <= atr_pct_extreme
bool vol_too_cheap   = atr_pctile < atr_pct_low
bool vol_extreme     = atr_pctile > atr_pct_extreme

bool vol_stable      = vol_expansion >= 0.8 and vol_expansion <= 1.2
bool vol_expanding   = vol_expansion > vol_exp_high

bool price_mid_range = pct_b >= bb_low and pct_b <= bb_high
bool price_extreme   = pct_b > bb_extreme_high or pct_b < bb_extreme_low

bool dte_ok          = dte > dte_cutoff
bool dte_danger      = dte <= dte_force_close
bool dte_reduced     = dte <= dte_cutoff and dte > dte_force_close

// Transition triggers for Regime 4
bool adx_breakout = ta.crossover(adx_val, adx_no_trend + 5)
bool vol_spike    = atr_pctile_jump > 15
bool bb_breakout  = (pct_b > bb_extreme_high and pct_b[1] <= bb_extreme_high) or (pct_b < bb_extreme_low and pct_b[1] >= bb_extreme_low)

// ─────────────────────────────────────────────────────────────────────────────
// REGIME CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────────

// REGIME 1: SELL PREMIUM (100% qty)
// No trend + adequate/rich vol + stable expansion + price mid-range + DTE ok + no event
bool r1_cond = is_no_trend and (vol_adequate or vol_rich) and not vol_expanding and price_mid_range and dte_ok and not event_flag

// REGIME 2: DIRECTIONAL SELL (100% qty)
// Trend exists, orderly + vol adequate+ + not exploding + DTE ok
bool r2_cond = is_trending and (vol_adequate or vol_rich) and not vol_expanding and dte_ok and not (event_flag and vol_rich)

// REGIME 4: DEFENSIVE (transition alert)
bool r4_cond = (adx_breakout or vol_spike or bb_breakout)

// REGIME 3: HALF SIZE (50% qty) — everything else
// This is the KEY CHANGE: instead of sitting out, we trade at half size with wider strikes
// Conditions that push to half-size:
//   - vol too cheap (thin premium → wider strikes, less qty)
//   - vol extreme + expanding (dangerous → wider strikes, less qty)  
//   - DTE in caution zone (10-5 days)
//   - event flag on (uncertainty → reduce size)
//   - strong trend + expanding vol
//   - price at extremes

// PRIORITY: 4 > 1 > 2 > 3
int regime = 0
string regime_label = ""
color regime_color = color.gray
int qty_pct = 50  // default half

if r4_cond
    regime := 4
    regime_label := "⚠ DEFENSIVE"
    regime_color := color.orange
    qty_pct := 0  // don't add, only adjust
else if r1_cond
    regime := 1
    regime_label := "SELL PREMIUM"
    regime_color := color.green
    qty_pct := 100
else if r2_cond
    regime := 2
    if trend_dir > 0
        regime_label := "SELL PUTS ▲"
    else if trend_dir < 0
        regime_label := "SELL CALLS ▼"
    else
        regime_label := "DIRECTIONAL SELL"
    regime_color := color.blue
    qty_pct := 100
else
    regime := 3
    regime_label := "HALF SIZE"
    regime_color := color.yellow
    qty_pct := 50

// DTE override: force close zone
bool force_close = dte_danger
if force_close
    regime_label := "⏰ FORCE CLOSE (DTE≤" + str.tostring(dte_force_close) + ")"
    regime_color := color.fuchsia

// ─────────────────────────────────────────────────────────────────────────────
// STRIKE CALCULATION
// ─────────────────────────────────────────────────────────────────────────────

// Round to nearest MCX strike interval
round_strike(float val) =>
    math.round(val / strike_interval) * strike_interval

// Current ATR in strike terms
float atr_val = atr_fast

// Sell strikes by regime
float ce_sell = 0.0
float pe_sell = 0.0
float ce_buy  = 0.0  // hedge wing
float pe_buy  = 0.0  // hedge wing

if regime == 1
    // Strangle: both sides at r1_strike_mult × ATR
    ce_sell := round_strike(close + r1_strike_mult * atr_val)
    pe_sell := round_strike(close - r1_strike_mult * atr_val)
    ce_buy  := ce_sell + hedge_offset
    pe_buy  := pe_sell - hedge_offset

else if regime == 2
    if trend_dir > 0
        // Uptrend: sell puts (below), buy further put for hedge
        pe_sell := round_strike(close - r2_strike_mult * atr_val)
        pe_buy  := pe_sell - hedge_offset
        ce_sell := 0
        ce_buy  := 0
    else if trend_dir < 0
        // Downtrend: sell calls (above), buy further call for hedge
        ce_sell := round_strike(close + r2_strike_mult * atr_val)
        ce_buy  := ce_sell + hedge_offset
        pe_sell := 0
        pe_buy  := 0
    else
        // Flat trending (ADX > 20 but no clear slope) — treat like regime 1 but tighter
        ce_sell := round_strike(close + r2_strike_mult * atr_val)
        pe_sell := round_strike(close - r2_strike_mult * atr_val)
        ce_buy  := ce_sell + hedge_offset
        pe_buy  := pe_sell - hedge_offset

else if regime == 3
    // HALF SIZE: wider strikes for safety margin
    ce_sell := round_strike(close + r3_strike_mult * atr_val)
    pe_sell := round_strike(close - r3_strike_mult * atr_val)
    ce_buy  := ce_sell + hedge_offset
    pe_buy  := pe_sell - hedge_offset

else if regime == 4
    // Defensive: show where you SHOULD be, not where to enter
    ce_sell := round_strike(close + r3_strike_mult * atr_val)
    pe_sell := round_strike(close - r3_strike_mult * atr_val)
    ce_buy  := ce_sell + hedge_offset
    pe_buy  := pe_sell - hedge_offset

// ─────────────────────────────────────────────────────────────────────────────
// CONFIDENCE SCORE
// ─────────────────────────────────────────────────────────────────────────────

float confidence = 0.0

if regime == 1
    confidence := 50.0
    if atr_pctile > 50
        confidence += 15
    if adx_val < 15
        confidence += 10
    if pct_b > 0.35 and pct_b < 0.65
        confidence += 10
    if vol_expansion < 1.0
        confidence += 10
    if dte > 20
        confidence += 5

else if regime == 2
    confidence := 40.0
    if atr_pctile > 50
        confidence += 15
    if vol_expansion < 1.1
        confidence += 10
    if dte > 20
        confidence += 10
    if (trend_dir > 0 and rsi_val > 50 and rsi_val < 70) or (trend_dir < 0 and rsi_val < 50 and rsi_val > 30)
        confidence += 15

else if regime == 3
    confidence := 30.0
    if atr_pctile > 40
        confidence += 10
    if not vol_expanding
        confidence += 10
    if dte > 15
        confidence += 10

confidence := math.min(confidence, 100)

// ─────────────────────────────────────────────────────────────────────────────
// VISUAL OUTPUT — CHART
// ─────────────────────────────────────────────────────────────────────────────

// Background
bgcolor(show_bg ? color.new(regime_color, 88) : na)

// 50 EMA
plot(ema50, "50 EMA", color=color.new(color.yellow, 30), linewidth=2)

// Bollinger Bands
p_bb_upper = plot(bb_upper, "BB Upper", color=color.new(color.gray, 60))
p_bb_lower = plot(bb_lower, "BB Lower", color=color.new(color.gray, 60))
fill(p_bb_upper, p_bb_lower, color=color.new(color.gray, 92))

// Strike levels on chart (last bar only for clarity)
plot(show_strikes and ce_sell > 0 ? ce_sell : na, "CE Sell Strike", color=color.new(color.red, 40), linewidth=1, style=plot.style_circles)
plot(show_strikes and pe_sell > 0 ? pe_sell : na, "PE Sell Strike", color=color.new(color.green, 40), linewidth=1, style=plot.style_circles)
plot(show_strikes and ce_buy > 0 ? ce_buy : na, "CE Buy Strike (hedge)", color=color.new(color.red, 70), linewidth=1, style=plot.style_cross)
plot(show_strikes and pe_buy > 0 ? pe_buy : na, "PE Buy Strike (hedge)", color=color.new(color.green, 70), linewidth=1, style=plot.style_cross)

// Regime change labels
regime_changed = regime != regime[1]
if regime_changed and barstate.isconfirmed
    lbl = regime == 4 ? "⚠ ADJUST" : regime == 3 ? "½ SIZE" : regime_label
    label.new(bar_index, high * 1.002, lbl,
         style=label.style_label_down,
         color=regime_color,
         textcolor=color.white,
         size=size.small)

// DTE warnings
if dte == dte_cutoff and barstate.isconfirmed
    label.new(bar_index, low * 0.998, "DTE=" + str.tostring(dte) + " (half only)",
         style=label.style_label_up, color=color.orange, textcolor=color.white, size=size.tiny)

if dte == dte_force_close and barstate.isconfirmed
    label.new(bar_index, low * 0.997, "⏰ FORCE CLOSE",
         style=label.style_label_up, color=color.fuchsia, textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD TABLE
// ─────────────────────────────────────────────────────────────────────────────

if show_table and barstate.islast
    int total_rows = show_exit ? 22 : 16
    var table dash = table.new(position.top_right, 2, total_rows,
         bgcolor=color.new(color.black, 10),
         border_color=color.new(color.gray, 60),
         border_width=1,
         frame_color=color.new(color.gray, 40),
         frame_width=2)

    int r = 0

    // ── HEADER ──
    table.cell(dash, 0, r, "GOLDM REGIME", text_color=color.white, text_size=size.normal, bgcolor=color.new(regime_color, 20))
    table.cell(dash, 1, r, regime_label, text_color=color.white, text_size=size.normal, bgcolor=color.new(regime_color, 20))
    r += 1

    // ── SIGNALS ──
    table.cell(dash, 0, r, "DTE", text_color=color.gray, text_size=size.small)
    dte_text = str.tostring(dte)
    if force_close
        dte_text += " ⏰ CLOSE ALL"
    else if dte_reduced
        dte_text += " (half only)"
    table.cell(dash, 1, r, dte_text, text_color=force_close ? color.fuchsia : dte_reduced ? color.orange : color.green, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "ADX", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(adx_val, "#.0") + (is_no_trend ? " (flat)" : is_strong_trend ? " (STRONG)" : " (trend)"),
         text_color=is_no_trend ? color.green : is_strong_trend ? color.red : color.yellow, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "Trend", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, trend_dir > 0 ? "▲ UP" : trend_dir < 0 ? "▼ DOWN" : "— FLAT",
         text_color=trend_dir > 0 ? color.green : trend_dir < 0 ? color.red : color.gray, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "ATR Pctile", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(atr_pctile, "#.0") + "%",
         text_color=vol_too_cheap ? color.red : vol_extreme ? color.red : vol_adequate ? color.green : vol_rich ? color.yellow : color.gray, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "ATR (₹)", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(atr_fast, "#"), text_color=color.white, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "Vol Expansion", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(vol_expansion, "#.00") + "x",
         text_color=vol_expanding ? color.red : vol_stable ? color.green : color.yellow, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "BB %B", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(pct_b, "#.00"),
         text_color=price_extreme ? color.red : price_mid_range ? color.green : color.yellow, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "RSI", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(rsi_val, "#.0"),
         text_color=rsi_val > 70 ? color.red : rsi_val < 30 ? color.red : color.gray, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "Qty", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(qty_pct) + "%",
         text_color=qty_pct == 100 ? color.green : qty_pct == 50 ? color.yellow : color.red, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "Confidence", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, str.tostring(confidence, "#") + "%",
         text_color=confidence > 70 ? color.green : confidence > 50 ? color.yellow : color.red, text_size=size.small)
    r += 1

    table.cell(dash, 0, r, "Event", text_color=color.gray, text_size=size.small)
    table.cell(dash, 1, r, event_flag ? "⚠ ON" : "OFF",
         text_color=event_flag ? color.red : color.green, text_size=size.small)
    r += 1

    // ── STRIKES SECTION ──
    table.cell(dash, 0, r, "──── STRIKES ────", text_color=color.aqua, text_size=size.small)
    table.cell(dash, 1, r, "", text_size=size.small)
    r += 1

    if ce_sell > 0
        table.cell(dash, 0, r, "Sell CE", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, str.tostring(ce_sell, "#") + (ce_buy > 0 ? " / Buy " + str.tostring(ce_buy, "#") : ""),
             text_color=color.red, text_size=size.small)
    else
        table.cell(dash, 0, r, "Sell CE", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "— (skip, uptrend)", text_color=color.gray, text_size=size.small)
    r += 1

    if pe_sell > 0
        table.cell(dash, 0, r, "Sell PE", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, str.tostring(pe_sell, "#") + (pe_buy > 0 ? " / Buy " + str.tostring(pe_buy, "#") : ""),
             text_color=color.green, text_size=size.small)
    else
        table.cell(dash, 0, r, "Sell PE", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "— (skip, downtrend)", text_color=color.gray, text_size=size.small)
    r += 1

    // Structure name
    table.cell(dash, 0, r, "Structure", text_color=color.gray, text_size=size.small)
    string struct_name = ""
    if regime == 1
        struct_name := ce_sell > 0 and pe_sell > 0 ? "Iron Condor" : "Spread"
    else if regime == 2
        if trend_dir > 0
            struct_name := "Bull Put Spread"
        else if trend_dir < 0
            struct_name := "Bear Call Spread"
        else
            struct_name := "Iron Condor (tight)"
    else if regime == 3
        struct_name := "Wide Iron Condor (½ qty)"
    else if regime == 4
        struct_name := "ADJUST — roll/close"
    table.cell(dash, 1, r, struct_name, text_color=color.aqua, text_size=size.small)
    r += 1

    // ── EXIT RULES ──
    if show_exit
        table.cell(dash, 0, r, "──── EXIT RULES ────", text_color=color.orange, text_size=size.small)
        table.cell(dash, 1, r, "", text_size=size.small)
        r += 1

        float target_pct = regime == 1 ? profit_r1 : profit_r2

        table.cell(dash, 0, r, "Profit Target", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "Close at " + str.tostring(100 - target_pct, "#") + "% decay\n(premium drops to " + str.tostring(target_pct, "#") + "% of entry)", text_color=color.green, text_size=size.small)
        r += 1

        table.cell(dash, 0, r, "Stop Loss", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "Close if premium hits " + str.tostring(stop_mult, "#.0") + "× entry\n(single leg, not combined)", text_color=color.red, text_size=size.small)
        r += 1

        table.cell(dash, 0, r, "Trail", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "At " + str.tostring(trail_trigger, "#") + "% profit → trail SL\nto breakeven on rest", text_color=color.yellow, text_size=size.small)
        r += 1

        table.cell(dash, 0, r, "Time Exit", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "Close ALL at DTE ≤ " + str.tostring(dte_force_close), text_color=color.fuchsia, text_size=size.small)
        r += 1

        table.cell(dash, 0, r, "Regime Exit", text_color=color.gray, text_size=size.small)
        table.cell(dash, 1, r, "If regime → DEFENSIVE:\n• Tested leg: close or roll\n• Untested: let decay / trail", text_color=color.orange, text_size=size.small)
        r += 1

// ─────────────────────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(regime == 1 and regime[1] != 1, "→ SELL PREMIUM (100%)", "GOLDM Regime 1: Sell Strangle/IC at full size")
alertcondition(regime == 2 and regime[1] != 2, "→ DIRECTIONAL SELL (100%)", "GOLDM Regime 2: Sell directional spread at full size")
alertcondition(regime == 3 and regime[1] != 3, "→ HALF SIZE (50%)", "GOLDM Regime 3: Conditions sub-optimal, trade at 50% qty with wider strikes")
alertcondition(regime == 4, "→ DEFENSIVE", "GOLDM Regime 4: ADJUST existing positions — vol spike or trend breakout")
alertcondition(dte == dte_force_close, "⏰ FORCE CLOSE DTE", "GOLDM: DTE hit force-close level. Exit ALL positions.")
alertcondition(dte == dte_cutoff, "DTE Cutoff", "GOLDM: DTE at cutoff — half size only for new positions")

// ─────────────────────────────────────────────────────────────────────────────
// DATA WINDOW EXPORT
// ─────────────────────────────────────────────────────────────────────────────

plot(regime * 1.0, "Regime #", display=display.data_window)
plot(adx_val, "ADX", display=display.data_window)
plot(atr_pctile, "ATR Pctile", display=display.data_window)
plot(atr_fast, "ATR ₹", display=display.data_window)
plot(vol_expansion, "Vol Expansion", display=display.data_window)
plot(pct_b, "BB %B", display=display.data_window)
plot(rsi_val, "RSI", display=display.data_window)
plot(dte * 1.0, "DTE", display=display.data_window)
plot(confidence, "Confidence %", display=display.data_window)
plot(trend_dir, "Trend Dir", display=display.data_window)
plot(ce_sell, "CE Sell Strike", display=display.data_window)
plot(pe_sell, "PE Sell Strike", display=display.data_window)
plot(ce_buy, "CE Buy Hedge", display=display.data_window)
plot(pe_buy, "PE Buy Hedge", display=display.data_window)
plot(qty_pct * 1.0, "Qty %", display=display.data_window)
````
