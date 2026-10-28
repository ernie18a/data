# DAX VSTOXX Pre-Market Panel

- url: https://www.tradingview.com/script/1fWDHDgW-DAX-VSTOXX-Pre-Market-Panel/
- type: indicator
- pine_id: PUB;442fe492f79046acb753ddc3fb713402
- version: 2.0

## Description

# DAX VSTOXX Pre-Market Panel

## What this indicator does

This panel displays a real-time pre-market dashboard for DAX40 intraday traders, built on a statistical correlation study between the **VSTOXX volatility index (FVS1!)** and the **DAX40 cash session result**.

The core insight: when VSTOXX falls during the trading session, the DAX tends to rise — and vice versa. This inverse relationship is statistically robust and forms the backbone of the day-type classification shown in the panel.

---

## Statistical Foundation

**Dataset:** 68 trading days | January–May 2026 | 1H session data

| Predictor | Correlation r | r² (variance explained) |
|---|---|---|
| VSTOXX Δ | -0.771 | 0.594 |
| Brent Δ% | -0.608 | 0.369 |
| DE 10Y Δ (bp) | -0.558 | 0.311 |
| Combined model | — | 0.693 |

**Regression formula:** `DAX Δ (pts) = -160 × VSTOXX Δ + 19`

**Combined model:** `DAX Δ = -160 × VSTOXX - 1.9 × DE10Y(bp) - 5.1 × Brent(%) + 19`

The p-value for the VSTOXX/DAX relationship is `1.47e-14` — statistically near-certain, not a coincidence.

---

## VSTOXX Delta Thresholds

All thresholds are data-derived from the historical dataset, not arbitrary:

| VSTOXX Session Δ | Bull% | Range% | Bear% | Avg DAX Δ | Signal |
|---|---|---|---|---|---|
| < -1.50 | 100% | 0% | 0% | +516 pts | STRONG BULL |
| -1.50 to -0.70 | 33% | 67% | 0% | +102 pts | BULL / RANGE |
| -0.70 to -0.35 | 47% | 47% | 6% | +156 pts | BULL BIAS |
| ± 0.35 (neutral) | 27% | 65% | 8% | +23 pts | RANGE |
| +0.35 to +0.70 | 8% | 69% | 23% | -51 pts | RANGE / BEAR BIAS |
| +0.70 to +1.50 | 0% | 40% | 60% | -180 pts | BEAR TREND |
| > +1.50 | 0% | 14% | 86% | -340 pts | STRONG BEAR |

---

## Panel Sections Explained

### PRE-MARKET (available from 08:00 CET)

**VSTOXX @ 08:00**
The absolute VSTOXX level at Frankfurt pre-open. Determines the volatility class and expected session range:
- < 20 → Low volatility, expected range ~239 pts
- 20–25 → Medium, expected range ~342 pts
- 25–35 → High, expected range ~500+ pts
- > 35 → Extreme, expected range ~700+ pts

**Expected session range**
Historical average DAX high–low range (09:00–17:30 XETR cash) for the given VSTOXX level class. This is a pre-market estimate, not a live calculation.

**Frankfurt delta (08:00 → 09:00)**
VSTOXX movement during the Frankfurt pre-open hour. This is the **earliest directional signal** (r² = 0.22). A drop of more than 0.30 points suggests bull bias; a rise above 0.30 suggests bear bias. Updates live during the 08:00–09:00 window, then freezes.

**Daily delta (prev close → now)**
Total VSTOXX change since yesterday's 17:00 close. This is what your watchlist/broker dashboard shows as the daily percentage change. Gives overnight context.

### SESSION (available from 09:00 CET)

**VSTOXX Session delta (09:00 → now)**
The primary predictor (r² = 0.594). Measures VSTOXX movement from the cash market open. Updates every bar throughout the session.

**DAGTYPE (Day type)**
Automatic classification based on the session delta and the calibrated thresholds:
`STRONG BULL / BULL TREND / BULL BIAS / RANGE / BEAR BIAS / BEAR TREND / STRONG BEAR`

Green = bullish, Red = bearish, Yellow = range/neutral.

**DAX Verwachting (DAX Expected)**
Regression-based point estimate for the DAX session result (open → close).
Formula: `DAX Δ = -160 × (VSTOXX session Δ) + 19`

**1e uur DAX (First hour DAX)**
DAX price change from session open (09:00) to 10:00 close. Historical accuracy: **73% correct** directional match with the full session close. Available from 10:00 CET.

### MACRO (available from 08:00 CET)

Two supplementary macro inputs that add predictive power on top of VSTOXX:

**Brent Δ% (08:00 → now)**
Brent crude oil percentage change since 08:00. Rising oil = inflationary pressure = bearish for DAX (r² = 0.37). Green = oil falling = DAX bullish context.

**DE 10Y Δ bp (08:00 → now)**
German 10-year Bund yield change in basis points since 08:00. Rising yields = higher discount rates = bearish for DAX valuations (r² = 0.31). Green = yields falling = DAX bullish context.

---

## Color Logic (consistent throughout)

| Color | Meaning |
|---|---|
| 🟢 Green | Bullish for DAX |
| 🔴 Red | Bearish for DAX |
| 🟡 Yellow | Neutral / Range |
| Grey | No data yet |

---

## Setup Instructions

**Required chart:** Germany 40 Cash CFD (IG Markets or equivalent) — **15M timeframe**

> ⚠️ This indicator **must be applied to a 24/7 CFD chart** (not the XETR cash chart). The XETR cash market only opens at 09:00 CET, which means the 08:00 VSTOXX capture is impossible on that chart. The CFD chart runs around the clock, allowing pre-market data to be captured correctly.

**Data sources pulled automatically:**
- `EUREX:FVS1!` — VSTOXX continuous futures
- `TVC:DE10Y` — German 10Y Bund yield
- `OANDA:UKOIL_USD` — Brent crude CFD (real-time, no 15-minute delay)

**Settings (all adjustable in indicator inputs):**
- VSTOXX symbol (default: `EUREX:FVS1!`)
- DE 10Y symbol (default: `TVC:DE10Y`)
- Brent symbol (default: `OANDA:UKOIL_USD`)
- Timezone (default: `Europe/Amsterdam`)
- Frankfurt threshold: 0.30 (first directional signal)
- Bias threshold: 0.35
- Trend threshold: 0.70
- Strong signal threshold: 1.50
- Table position: top-right, top-left, bottom-right, bottom-left
- Background color: on/off

---

## How to Use in Practice

**Before 08:00 CET:** Panel shows "waiting" — no actionable data yet.

**08:00 CET — Frankfurt opens:**
- Check VSTOXX @ 08:00 level → determine volatility class and expected range
- Monitor Frankfurt delta as it builds live → first directional hint
- Check Brent and DE 10Y direction for macro context

**08:00–09:00 CET — Frankfurt hour:**
- If Frankfurt delta > +0.30: bear bias forming
- If Frankfurt delta < -0.30: bull bias forming
- If within ±0.30: neutral, wait for session confirmation

**09:00–09:15 CET — Observation window (no trades):**
- Watch opening bar direction
- Does it confirm or contradict the Frankfurt signal?

**09:15+ CET — Session active:**
- Session delta starts building → day type classification activates
- DAX Expected updates with every VSTOXX tick
- Strong signals (|delta| > 1.50) have 85–100% historical precision

**10:00 CET:**
- First hour result confirms or rejects the pre-market bias
- 73% historical directional accuracy with full session close

---

## Alerts

Four built-in alerts:
1. **Frankfurt BULL signal** — VSTOXX Frankfurt delta crosses below threshold
2. **Frankfurt BEAR signal** — VSTOXX Frankfurt delta crosses above threshold
3. **BULL TREND confirmed** — Session delta crosses into BULL TREND / STRONG BULL zone
4. **BEAR TREND confirmed** — Session delta crosses into BEAR TREND / STRONG BEAR zone

---

## Important Notes

- **Gray zone (±0.35 neutral):** Within this range, VSTOXX alone is insufficient. Use Brent and DE 10Y for additional context. When in doubt, classify as RANGE and trade selectively or not at all.
- **Regression formula accuracy:** r² = 0.594 means VSTOXX explains ~59% of daily DAX variance. The remaining 41% is driven by news, earnings, geopolitics, and other factors not captured in this model.
- **Lead-lag is zero:** Statistical testing confirms that yesterday's VSTOXX, S&P500, or VIX has no meaningful predictive power for today's DAX session. Markets discount overnight information immediately at the open.
- **Recalibration:** Thresholds are based on 68 trading days (January–May 2026). Recalibrate monthly by re-running the correlation analysis on fresh data to ensure thresholds remain accurate as market regimes evolve.

---

## Disclaimer

This indicator is a statistical tool based on historical data. Past correlations do not guarantee future results. Always use proper risk management. This is not financial advice.

## Source Code

````pine
//@version=6
indicator("DAX VSTOXX Pre-Market Panel — Definitief", overlay=true)

// ===============================================================
//  DAX VSTOXX PRE-MARKET PANEL  — Definitieve versie
//  Statistische basis: 68 handelsdagen jan–mei 2026
//  VSTOXX r² = 0.594 | + DE10Y r² = 0.669 | + Brent r² = 0.693
//  Regressie: DAX Δ = -160×VSTOXX - 1.9×DE10Ybp - 5.1×Brent% + 19
//  Platform : Germany 40 Cash CFD (IG) — 15M chart
//  Vereiste : 24/7 CFD bars voor FVS1! capture 08:00-09:00
// ===============================================================

// --- INSTELLINGEN ---------------------------------------------
vsym       = input.symbol("EUREX:FVS1!", "VSTOXX symbool",    group="Data")
de10sym    = input.symbol("TVC:DE10Y",   "DE 10Y symbool",    group="Data")
brtsym     = input.symbol("OANDA:UKOIL_USD",   "Brent symbool",     group="Data")
tz         = input.string("Europe/Amsterdam", "Tijdzone",      group="Data")
thr_frankf = input.float(0.30, "Frankfurt drempel", step=0.05, group="Drempelwaarden")
thr_strong = input.float(1.50, "Sterk signaal",     step=0.10, group="Drempelwaarden")
thr_trend  = input.float(0.70, "Trend drempel",     step=0.05, group="Drempelwaarden")
thr_bias   = input.float(0.35, "Bias drempel",      step=0.05, group="Drempelwaarden")
tbl_pos    = input.string("Rechts boven", "Tabel positie",
                           options=["Rechts boven","Links boven","Rechts onder","Links onder"],
                           group="Weergave")
show_bg    = input.bool(true, "Achtergrondkleur tonen", group="Weergave")

// --- DATA (puur 15M) -----------------------------------------
v    = request.security(vsym,    timeframe.period, close, lookahead=barmerge.lookahead_off)
de10 = request.security(de10sym, timeframe.period, close, lookahead=barmerge.lookahead_off)
brt  = request.security(brtsym,  timeframe.period, close, lookahead=barmerge.lookahead_off)

// --- TIJDSHULPERS --------------------------------------------
h       = hour(time, tz)
m       = minute(time, tz)
d       = dayofmonth(time, tz)
new_day  = d != d[1]
new_week = weekofyear(time, tz) != weekofyear(time[1], tz)

// --- TRACKING VARIABELEN ------------------------------------
var float v_at_0800  = na
var float v_at_0900  = na
var float v_dax_open = na
var float v_last17   = na
var float v_prev17   = na
var float v_dax_10   = na
var float de10_open  = na
var float brt_open   = na
var float week_high  = na
var float week_low   = na

// --- DAGELIJKSE RESET ----------------------------------------
if new_week
    week_high  := high
    week_low   := low

if new_day
    v_prev17   := v_last17
    v_at_0800  := na
    v_at_0900  := na
    v_dax_open := na
    de10_open  := na
    brt_open   := na
    v_dax_10   := na

// --- CAPTURE -------------------------------------------------
if h == 8 and na(v_at_0800) and not na(v)
    v_at_0800 := v

if h == 9 and na(v_at_0900) and not na(v)
    v_at_0900 := v

if h == 9 and na(v_dax_open)
    v_dax_open := open

if h == 8 and na(de10_open) and not na(de10)
    de10_open := de10

if h == 8 and na(brt_open) and not na(brt)
    brt_open := brt

if h == 10 and na(v_dax_10) and not na(v_dax_open)
    v_dax_10 := close - v_dax_open

// Capture om 17:30 CET (EUREX officiele slotkoers FVS1!)
// Op 15M chart: bar h==17 m==15 sluit om 17:30
// Week high/low tracking (sessie uren)
if h >= 9 and h <= 17
    if na(week_high) or high > week_high
        week_high := high
    if na(week_low) or low < week_low
        week_low  := low

if h == 17 and (m == 15 or m == 30) and not na(v)
    v_last17 := v

// --- VSTOXX BEREKENINGEN ------------------------------------
frankfurt_done = not na(v_at_0900)
frankfurt_live = not na(v_at_0800) and h == 8 and not na(v) ? v - v_at_0800 : not na(v_at_0800) and frankfurt_done ? v_at_0900 - v_at_0800 : na
sessie_delta   = frankfurt_done and not na(v) ? v - v_at_0900 : na
dag_delta      = not na(v_prev17) and not na(v) ? v - v_prev17 : na
dax_1h_delta   = not na(v_dax_10) ? v_dax_10 : not na(v_dax_open) and h >= 10 ? close - v_dax_open : na

// --- MACRO BEREKENINGEN --------------------------------------
// Weekrange berekening
week_range = not na(week_high) and not na(week_low) ? math.round(week_high - week_low) : na
week_range_str = na(week_range) ? "---" : str.tostring(week_range) + " pts"

// Context kleur: <600=ruimte(groen) 600-900=normaal(geel) 900-1200=elevated(oranje) >1200=hoog(rood)
week_range_col = na(week_range) ? color.new(#666666,0) : week_range < 600 ? color.new(#00e676,0) : week_range < 900 ? color.new(#ffcc00,0) : week_range < 1200 ? color.new(#ff9800,0) : color.new(#ff3d57,0)
week_context = na(week_range) ? "" : week_range < 600 ? "  ruimte" : week_range < 900 ? "  normaal" : week_range < 1200 ? "  elevated" : "  hoog"

de10_delta_bp = not na(de10_open) and not na(de10) ? (de10 - de10_open) * 100 : na
brt_delta_pct = not na(brt_open) and not na(brt) and brt_open != 0 ? (brt - brt_open) / brt_open * 100 : na

// --- VOL CLASS -----------------------------------------------
vol_lvl = v_at_0800

vol_class = switch
    na(vol_lvl)  => "---"
    vol_lvl < 16 => "LAAG (<16)"
    vol_lvl < 20 => "LAAG (16-20)"
    vol_lvl < 25 => "MIDDEN (20-25)"
    vol_lvl < 35 => "HOOG (25-35)"
    =>               "EXTREEM (>35)"

// Live dagrange berekening
// Pre-09:00: VSTOXX niveau @ 08:00 (r2=0.31)  formule: 28.6 x niveau - 281
// Post-09:00: |VSTOXX sessie delta| (r2=0.495) formule: 189.4 x |delta| + 199
// Gevalideerd op 7 mei: delta=0.90 -> model 369pts, werkelijk 389pts (5% afwijking)
live_range_val = not na(sessie_delta) ? math.round(189.4 * math.abs(sessie_delta) + 198.6) : not na(v_at_0800) ? math.round(28.6 * v_at_0800 - 281.0) : na
live_range_src = not na(sessie_delta) ? " (live)" : " (08u)"
exp_range = na(live_range_val) ? "---" : str.tostring(live_range_val) + " pts" + live_range_src

// --- FRANKFURT SIGNAAL ---------------------------------------
fd = frankfurt_live

frankf_sig = switch
    na(fd)                    => "wacht..."
    fd < -(thr_frankf + 0.10) => "BULL BIAS sterk"
    fd < -thr_frankf          => "bull licht"
    fd > (thr_frankf + 0.10)  => "BEAR BIAS sterk"
    fd > thr_frankf           => "bear licht"
    =>                           "NEUTRAAL"

// --- DAGTYPE -------------------------------------------------
sd = sessie_delta

dag_type = switch
    na(sd) and frankfurt_done => "pre-sessie"
    na(sd)                    => "voor 09:00"
    sd < -thr_strong          => "STRONG BULL"
    sd < -thr_trend           => "BULL TREND"
    sd < -thr_bias            => "BULL BIAS"
    sd > thr_strong           => "STRONG BEAR"
    sd > thr_trend            => "BEAR TREND"
    sd > thr_bias             => "BEAR BIAS"
    =>                           "RANGE"

// --- DAX VERWACHTING -----------------------------------------
dax_exp_val = not na(sd) ? math.round(-160.1 * sd + 18.8) : na

dax_exp_str = switch
    na(dax_exp_val)  => "---"
    dax_exp_val >= 0 => "+" + str.tostring(dax_exp_val) + " pts"
    =>                  str.tostring(dax_exp_val) + " pts"

// --- EERSTE UUR ----------------------------------------------
confirm_str = switch
    na(dax_1h_delta) and h >= 9 => "wacht op 10:00..."
    na(dax_1h_delta)             => "---"
    dax_1h_delta > 50            => "BULL (+" + str.tostring(math.round(dax_1h_delta)) + ")"
    dax_1h_delta < -50           => "BEAR (" + str.tostring(math.round(dax_1h_delta)) + ")"
    =>                              "NEUTR. (" + str.tostring(math.round(dax_1h_delta)) + ")"

// --- DISPLAY STRINGS -----------------------------------------
fd_teken  = not na(frankfurt_live) and frankfurt_live >= 0 ? "+" : ""
fd_getal  = not na(frankfurt_live) ? str.tostring(frankfurt_live, "#.##") : ""
fd_str    = na(frankfurt_live) ? "wacht op 08:00..." : fd_teken + fd_getal + "  " + frankf_sig

sd_teken  = not na(sessie_delta) and sessie_delta >= 0 ? "+" : ""
sd_getal  = not na(sessie_delta) ? str.tostring(sessie_delta, "#.##") : ""
sd_str    = na(sessie_delta) ? (h >= 9 ? "0.00" : "voor sessie") : sd_teken + sd_getal

ddag_pct  = not na(dag_delta) and not na(v_prev17) and v_prev17 != 0 ? str.tostring(math.round(dag_delta / v_prev17 * 100, 1), "#.#") : ""
ddag_str  = na(dag_delta) ? "---" : (dag_delta >= 0 ? "+" : "") + str.tostring(dag_delta, "#.##") + "  (" + (dag_delta >= 0 ? "+" : "") + ddag_pct + "%)"

v08_str   = na(v_at_0800) ? "wacht op 08:00..." : str.tostring(v_at_0800, "##.##") + "  " + vol_class

week_disp = na(week_range) ? "---" : str.tostring(week_range) + " pts" + week_context

de10_str  = na(de10_delta_bp) ? "wacht op 08:00..." : (de10_delta_bp >= 0 ? "+" : "") + str.tostring(de10_delta_bp, "#.##") + " bp"
brt_str   = na(brt_delta_pct) ? "wacht op 08:00..." : (brt_delta_pct >= 0 ? "+" : "") + str.tostring(brt_delta_pct, "#.##") + "%"

// --- KLEUREN -------------------------------------------------
C_BULL = #00e676
C_BEAR = #ff3d57
C_RNG  = #ffcc00
C_DIM  = #666666
C_WHT  = #e0e0e0
C_BG   = color.new(#141b25, 5)
C_CARD = color.new(#1a2030, 0)
C_HEAD = color.new(#1f4e79, 0)
C_ROW2 = color.new(#0d1520, 0)
C_TINY = color.new(#778899, 0)
C_GRY  = color.new(#c0c0c0, 0)
C_SEC  = color.new(#7799bb, 0)
C_PRP  = color.new(#bb86fc, 0)
C_ORG  = color.new(#ff9800, 0)
C_CYN  = color.new(#00bcd4, 0)

frankf_col  = na(frankfurt_live) ? C_DIM : frankfurt_live < 0 ? C_BULL : frankfurt_live > 0 ? C_BEAR : C_RNG
sessie_col  = na(sessie_delta)   ? C_DIM : sessie_delta   < 0 ? C_BULL : sessie_delta   > 0 ? C_BEAR : C_RNG
ddag_col    = na(dag_delta)      ? C_DIM : dag_delta       < 0 ? C_BULL : dag_delta      > 0 ? C_BEAR : C_RNG
confirm_col = na(dax_1h_delta)   ? C_DIM : dax_1h_delta > 50  ? C_BULL : dax_1h_delta < -50 ? C_BEAR : C_RNG
dax_exp_col = na(dax_exp_val)    ? C_DIM : dax_exp_val > 0    ? C_BULL : dax_exp_val < 0    ? C_BEAR : C_RNG
dag_col     = str.contains(dag_type, "BULL") ? C_BULL : str.contains(dag_type, "BEAR") ? C_BEAR : dag_type == "RANGE" ? C_RNG : C_DIM
vol_col     = na(vol_lvl) ? C_DIM : vol_lvl < 20 ? C_RNG : vol_lvl < 25 ? color.new(#ffaa00, 0) : C_BEAR
v08_col     = na(v_at_0800) ? C_DIM : vol_col
de10_col    = na(de10_delta_bp) ? C_DIM : de10_delta_bp < 0 ? C_BULL : de10_delta_bp > 0 ? C_BEAR : C_RNG
brt_col     = na(brt_delta_pct) ? C_DIM : brt_delta_pct < 0 ? C_BULL : brt_delta_pct > 0 ? C_BEAR : C_RNG

// --- ACHTERGROND --------------------------------------------
bgcolor(show_bg and not na(sessie_delta) ? (str.contains(dag_type, "BULL") ? color.new(C_BULL, 97) : str.contains(dag_type, "BEAR") ? color.new(C_BEAR, 97) : color.new(C_RNG, 98)) : na, title="Dagtype achtergrond")

// --- TABLE POSITIE ------------------------------------------
tbl_position = tbl_pos == "Links boven" ? position.top_left : tbl_pos == "Rechts onder" ? position.bottom_right : tbl_pos == "Links onder" ? position.bottom_left : position.top_right

// --- TABLE (2 kolommen, 17 rijen) — size.normal = ~80% ------
var table t = table.new(tbl_position, 2, 18,
               bgcolor=C_BG, border_color=color.new(#2a3545, 0), border_width=1,
               frame_color=C_HEAD, frame_width=2)

if barstate.islast

    // Rij 0: header
    table.cell(t, 0, 0, "  VSTOXX PRE-MARKET PANEL",
               text_color=C_WHT, bgcolor=C_HEAD, text_size=size.normal, text_halign=text.align_left)
    table.cell(t, 1, 0, timeframe.period + "M  " + syminfo.ticker,
               text_color=color.new(#aaaaaa, 0), bgcolor=C_HEAD, text_size=size.tiny, text_halign=text.align_right)

    // Rij 1: sectie PRE-MARKET
    table.cell(t, 0, 1, "-- PRE-MARKET --",
               text_color=C_SEC, bgcolor=C_ROW2, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 1, "", bgcolor=C_ROW2, text_size=size.tiny)

    // Rij 2: VSTOXX @ 08:00
    table.cell(t, 0, 2, "  VSTOXX @ 08:00", text_color=C_GRY, bgcolor=C_CARD, text_size=size.normal)
    table.cell(t, 1, 2, v08_str,            text_color=v08_col, bgcolor=C_CARD, text_size=size.normal)

    // Rij 3: Verwachte dagrange
    table.cell(t, 0, 3, "  Dagrange verwachting", text_color=C_GRY, bgcolor=C_ROW2, text_size=size.normal)
    table.cell(t, 1, 3, exp_range,              text_color=C_PRP, bgcolor=C_ROW2, text_size=size.normal)

    // Rij 4: Frankfurt delta
    table.cell(t, 0, 4, "  Frankfurt delta (08->09)", text_color=C_GRY, bgcolor=C_CARD, text_size=size.normal)
    table.cell(t, 1, 4, fd_str,                        text_color=frankf_col, bgcolor=C_CARD, text_size=size.normal)

    // Rij 5: Dagelijkse delta
    table.cell(t, 0, 5, "  Dagelijkse delta (prev->nu)", text_color=C_GRY, bgcolor=C_ROW2, text_size=size.normal)
    table.cell(t, 1, 5, ddag_str,                         text_color=ddag_col, bgcolor=C_ROW2, text_size=size.normal)

    // Rij 6: sectie SESSIE
    table.cell(t, 0, 6, "-- SESSIE --",
               text_color=C_SEC, bgcolor=C_ROW2, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 6, "", bgcolor=C_ROW2, text_size=size.tiny)

    // Rij 7: VSTOXX sessie delta
    table.cell(t, 0, 7, "  VSTOXX Sessie delta (09->nu)", text_color=C_GRY, bgcolor=C_CARD, text_size=size.normal)
    table.cell(t, 1, 7, sd_str,                             text_color=sessie_col, bgcolor=C_CARD, text_size=size.normal)

    // Rij 8: Dagtype
    table.cell(t, 0, 8, "  DAGTYPE", text_color=C_GRY, bgcolor=C_ROW2, text_size=size.normal)
    table.cell(t, 1, 8, "  " + dag_type, text_color=dag_col, bgcolor=C_ROW2, text_size=size.large)

    // Rij 9: DAX verwachting
    table.cell(t, 0, 9, "  DAX Verwachting", text_color=C_GRY, bgcolor=C_CARD, text_size=size.normal)
    table.cell(t, 1, 9, dax_exp_str,         text_color=dax_exp_col, bgcolor=C_CARD, text_size=size.normal)

    // Rij 10: Eerste uur DAX
    table.cell(t, 0, 10, "  1e uur DAX (73% correct)", text_color=C_GRY, bgcolor=C_ROW2, text_size=size.normal)
    table.cell(t, 1, 10, confirm_str,                    text_color=confirm_col, bgcolor=C_ROW2, text_size=size.normal)

    // Rij 11: sectie MACRO
    table.cell(t, 0, 11, "-- MACRO --",
               text_color=C_SEC, bgcolor=C_ROW2, text_size=size.small, text_halign=text.align_left)
    table.cell(t, 1, 11, "Brent r2=0.37 | DE10Y r2=0.31",
               text_color=C_TINY, bgcolor=C_ROW2, text_size=size.tiny, text_halign=text.align_right)

    // Rij 12: Brent sessie delta
    table.cell(t, 0, 12, "  Brent Δ% (08->nu)", text_color=C_ORG, bgcolor=C_CARD, text_size=size.normal)
    table.cell(t, 1, 12, brt_str,                text_color=brt_col, bgcolor=C_CARD, text_size=size.normal)

    // Rij 13: DE 10Y sessie delta
    table.cell(t, 0, 13, "  DE 10Y Δ bp (08->nu)", text_color=C_CYN, bgcolor=C_ROW2, text_size=size.normal)
    table.cell(t, 1, 13, de10_str,                   text_color=de10_col, bgcolor=C_ROW2, text_size=size.normal)

    // Rij 14: weekrange
    table.cell(t, 0, 14, "  Week range (ma->nu)", text_color=C_GRY, bgcolor=C_CARD, text_size=size.normal)
    table.cell(t, 1, 14, week_disp, text_color=week_range_col, bgcolor=C_CARD, text_size=size.normal)

    // Rij 15: spacer
    table.cell(t, 0, 15, "", bgcolor=color.new(#0d1117, 0), text_size=size.tiny)
    table.cell(t, 1, 15, "", bgcolor=color.new(#0d1117, 0), text_size=size.tiny)

    // Rij 16: model info
    table.cell(t, 0, 16, "  r2: VST=0.594 | +DE10Y=0.669 | +Brent=0.693",
               text_color=C_TINY, bgcolor=color.new(#0d1117, 0), text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, 16, "n=68 dagen",
               text_color=C_TINY, bgcolor=color.new(#0d1117, 0), text_size=size.tiny, text_halign=text.align_right)

    // Rij 17: footer
    table.cell(t, 0, 17, "  y=-160xVST-1.9xDE10Y-5.1xBrent+19",
               text_color=C_TINY, bgcolor=color.new(#0d1117, 0), text_size=size.tiny, text_halign=text.align_left)
    table.cell(t, 1, 17, "jan-mei 2026",
               text_color=C_TINY, bgcolor=color.new(#0d1117, 0), text_size=size.tiny, text_halign=text.align_right)

// --- ALERTS -------------------------------------------------
alertcondition(not na(frankfurt_live) and frankfurt_live < -thr_frankf and frankfurt_live[1] >= -thr_frankf,
               "Frankfurt BULL signaal", "VSTOXX Frankfurt delta kruist onder drempel")
alertcondition(not na(frankfurt_live) and frankfurt_live > thr_frankf and frankfurt_live[1] <= thr_frankf,
               "Frankfurt BEAR signaal", "VSTOXX Frankfurt delta kruist boven drempel")
alertcondition(not na(sessie_delta) and (dag_type == "BULL TREND" or dag_type == "STRONG BULL"),
               "BULL TREND bevestigd", "VSTOXX sessie-delta bevestigt BULL TREND")
alertcondition(not na(sessie_delta) and (dag_type == "BEAR TREND" or dag_type == "STRONG BEAR"),
               "BEAR TREND bevestigd", "VSTOXX sessie-delta bevestigt BEAR TREND")
````
