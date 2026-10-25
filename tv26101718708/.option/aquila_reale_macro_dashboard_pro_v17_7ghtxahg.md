# Aquila Reale  Macro Dashboard PRO v1.7

- url: https://www.tradingview.com/script/7gHtXAhG/
- type: indicator
- pine_id: PUB;e756c0af2c08445fb2d02c7dfabf9d4c
- version: 4.0

## Description

🦅 AQUILA REALE — MACRO DASHBOARD PRO
"Born to fly, born to dare"

A complete macro overview in a single table, with automatic interpretation of each asset's impact on Gold price and a final ACTIONABLE trade signal that resolves conflicts intelligently between macro tailwinds and price-action reality.

═══════════════════════════════════════════
📊 WHAT IT SHOWS
═══════════════════════════════════════════

For each of 12 macro assets, the dashboard displays:
- Current value (live intraday)
- Daily change %
- Auto-interpreted status (e.g. "VERY STRONG", "HIGH FEAR", "STAGFLATIONARY")
- 🥇 Gold impact (green = pro-Gold, red = anti-Gold, gray = neutral)

═══════════════════════════════════════════
📋 ASSETS COVERED (12 + 2 derived)
═══════════════════════════════════════════

US MACRO:
- DXY (Dollar Index)
- US10Y / US20Y / US30Y (Treasury yields)
- USIRYY (CPI Inflation YoY)
- S5TH (S&P 500 stocks above 200dma — market breadth)

ASIA:
- USDJPY (Yen strength)
- NI225 (Nikkei 225)
- HSI (Hang Seng Index)

SENTIMENT:
- VIX (CBOE Volatility Index — fear gauge)

GLOBAL:
- URTH (iShares MSCI World ETF)

GEOPOLITICAL:
- USDCNH (Offshore Chinese Yuan)

COMMODITIES:
- XAUUSD (Gold spot)
- USOIL (WTI Crude Oil spot)

DERIVED:
- Gold/Oil ratio (with historical valuation reading)
- Macro Scenario (synthesis of WTI level + Gold direction + yields)

═══════════════════════════════════════════
🎯 FINAL SYNTHESIS (3 dedicated rows)
═══════════════════════════════════════════

💬 SCENARIO — One of 6 macro readings:
   • STAGFLATIONARY (yield squeeze, no Gold longs)
   • GOLD HEDGE ACTIVE (inflation trade pro-Gold)
   • RISK-OFF (cautious flight-to-safety)
   • REFLATIONARY (broad pro-Gold)
   • RISK-ON (anti-Gold)
   • MIXED (no clear regime)

💎 MACRO BIAS — Aggregate score (±13) across all assets

🎯 TRADE SIGNAL — Final actionable verdict combining BIAS + SCENARIO:
   • 🚀 LONG STRONG / ▲ LONG OK
   • ⚠️ LONG CAUTIOUS
   • ⏸️ WAIT (yield squeeze / mixed signals)
   • 🛑 NO LONG / STAY OUT / SHORT BIAS

═══════════════════════════════════════════
🧠 KEY LOGIC INNOVATION
═══════════════════════════════════════════

Equity indices (NKY/HSI/URTH) only count as pro-Gold when VIX > 22 (true flight-to-safety). This prevents the dashboard from misreading a "bonds beat all" regime as pro-Gold — a common flaw in naive aggregations.

The TRADE SIGNAL row resolves the inevitable conflicts between macro bias (what "should" happen) and price action (what's actually happening), using a priority hierarchy where the SCENARIO has veto power over the BIAS score.

═══════════════════════════════════════════
📺 3 VIEW MODES
═══════════════════════════════════════════

- FULL: complete 19-row dashboard
- MINIMAL: only the 3 synthesis rows (SCENARIO + BIAS + SIGNAL)
- COMPACT: only the TRADE SIGNAL (1-line ticker)

Switch on-the-fly via settings — all modes use the same underlying calculations.

═══════════════════════════════════════════
⚙️ CUSTOMIZATION
═══════════════════════════════════════════

- Dark / Light theme
- 9 anchor positions + signed offsets (H/V)
- 4 text sizes (Tiny / Small / Normal / Large)
- Real-time refresh (lookahead_on for intraday)

═══════════════════════════════════════════
⚠️ IMPORTANT DISCLAIMER
═══════════════════════════════════════════

This indicator is for informational and educational purposes only and does not constitute financial advice. Macro readings are simplified models — always combine with your own analysis, risk management, and price action.

NOT suitable for backtesting strategies due to lookahead_on usage (which is intentional for real-time intraday monitoring).

Past performance does not guarantee future results.

═══════════════════════════════════════════

🦅 Born to fly, born to dare.

## Source Code

````pine
//@version=6
// ═══════════════════════════════════════════════════════════════
// 🦅 AQUILA REALE — MACRO DASHBOARD EDU MTF v3.0
// "Born to fly, born to dare"
//
// EDUCATIONAL multi-timeframe macro dashboard for ALL sessions.
// Teaches HOW each asset correlates with Gold, now across 1h / 4h / Daily.
//
// WHAT'S NEW IN v3.0 (multi-timeframe):
//   • 7 CORE assets read on THREE timeframes (1h / 4h / Daily):
//       Gold, DXY, US10Y, USDJPY, USDCHF, VIX, Silver.
//     In FULL mode each shows three 🥇 impact cells (one per TF), so you
//     SEE when an asset pushes Gold one way on 1h but the opposite on D.
//   • 12 SLOW assets stay on Daily only (yields 20/30Y, inflation,
//     breadth, indices, yuan, euro, BTC, oil) — they barely move
//     intraday, so an hourly read would be noise.
//   • Security-call budget: 7×3 + 12×1 = 33 calls (under the 40 limit
//     of Plus/base plans).
//   • MINIMAL mode: triple synthesis — BIAS shown for 1h | 4h | D.
//   • COMPACT mode: single ALIGNMENT light — are the 3 TFs in agreement?
//       🟢 ALIGNED LONG / 🔴 ALIGNED SHORT / ⚠️ CONFLICT (stand aside).
//
// CORRELATION LOGIC:
//   INVERSE to Gold (asset up → Gold down):
//     DXY, yields, breadth, equity indices, USDJPY, USDCHF, BTC.
//   DIRECT with Gold (asset up → Gold up):
//     Inflation, USDCNH, VIX, EURUSD, Silver.
//   SPECIAL: WTI (level-conditional), DXY (VIX-aware two faces).
//
// ⚠️ YIELDS: feed the YIELD (TVC:US10Y etc.), NOT bond futures.
//
// NOTE: live monitoring, not backtesting. Educational tool — the
// TRADE SIGNAL is a macro summary, NOT financial advice.
//
// (c) giua64 — Aquila Reale
// ═══════════════════════════════════════════════════════════════
indicator("🦅 Aquila Reale — Macro Dashboard EDU MTF v3.0", "🦅 Macro MTF", overlay=true)

// ─────────────────────────────────────────────
// INPUT — SYMBOLS (editable)
// ─────────────────────────────────────────────
grp_sym = "Symbols (editable)"
sym_dxy  = input.symbol("DXY",     "DXY — US Dollar Index", group=grp_sym, tooltip="US Dollar. INVERSE to Gold: strong dollar → weak Gold. [MULTI-TF]")
sym_u10  = input.symbol("US10Y",   "US 10Y Yield", group=grp_sym, tooltip="10Y yield. INVERSE: yields up → Gold down. Use the YIELD (TVC), not the future. [MULTI-TF]")
sym_u02  = input.symbol("US02Y",   "US 2Y Yield (Fed gauge)", group=grp_sym, tooltip="2Y yield. The most Fed-sensitive rate: it prices in rate expectations and moves before the 10Y. INVERSE to Gold. Use the YIELD (TVC). [Daily only]")
sym_u20  = input.symbol("US20Y",   "US 20Y Yield", group=grp_sym, tooltip="20Y yield. INVERSE to Gold. [Daily only]")
sym_u30  = input.symbol("US30Y",   "US 30Y Yield", group=grp_sym, tooltip="30Y yield. INVERSE to Gold. [Daily only]")
sym_inf  = input.symbol("USIRYY",  "US Inflation (CPI YoY)", group=grp_sym, tooltip="US CPI. DIRECT: inflation up → Gold up. [Daily only]")
sym_s5   = input.symbol("S5TH",    "S&P 500 Breadth (% > 200dma)", group=grp_sym, tooltip="S&P 500 breadth. INVERSE: strong stocks → Gold down. [Daily only]")
sym_jpy  = input.symbol("USDJPY",  "USD/JPY — Japanese Yen", group=grp_sym, tooltip="Yen (haven). USDJPY up = weak yen = Gold down. INVERSE. [MULTI-TF]")
sym_nky  = input.symbol("NI225",   "Nikkei 225 (Japan)", group=grp_sym, tooltip="Japanese equities. INVERSE, VIX-aware. [Daily only]")
sym_hsi  = input.symbol("HSI",     "Hang Seng (Hong Kong)", group=grp_sym, tooltip="Hong Kong equities. INVERSE, VIX-aware. [Daily only]")
sym_vix  = input.symbol("VIX",     "VIX — Fear Gauge", group=grp_sym, tooltip="Fear gauge. DIRECT: VIX up → Gold up. [MULTI-TF]")
sym_urth = input.symbol("URTH",    "MSCI World ETF", group=grp_sym, tooltip="Global equities. INVERSE, VIX-aware. [Daily only]")
sym_cnh  = input.symbol("USDCNH",  "USD/CNH — Chinese Yuan", group=grp_sym, tooltip="Offshore Yuan. USDCNH up = China stress = DIRECT. [Daily only]")
sym_chf  = input.symbol("USDCHF",  "USD/CHF — Swiss Franc", group=grp_sym, tooltip="Swiss franc (haven). USDCHF down = strong franc = Gold up. INVERSE. [MULTI-TF]")
sym_eur  = input.symbol("EURUSD",  "EUR/USD — Euro", group=grp_sym, tooltip="Euro. EURUSD up = weak dollar = Gold up. DIRECT. [Daily only]")
sym_au   = input.symbol("XAUUSD",  "Gold (reference)", group=grp_sym, tooltip="Gold: reference asset. [MULTI-TF]")
sym_ag   = input.symbol("XAGUSD",  "Silver", group=grp_sym, tooltip="Silver. DIRECT: Gold's twin, confirms it. [MULTI-TF]")
sym_btc  = input.symbol("BTCUSD",  "Bitcoin", group=grp_sym, tooltip="Bitcoin. INVERSE: risk-on → Gold down. [Daily only]")
sym_wti  = input.symbol("USOIL",   "WTI Crude Oil", group=grp_sym, tooltip="WTI crude. SPECIAL: depends on the $100 level. [Daily only]")

// ─────────────────────────────────────────────
// INPUT — TIMEFRAMES (the 3 used for core assets)
// ─────────────────────────────────────────────
grp_tf = "Multi-Timeframe"
tf_fast = input.timeframe("60",  "TF 1 (Fast)",   group=grp_tf, tooltip="Fast timeframe for core assets. Default 1h.")
tf_mid  = input.timeframe("240", "TF 2 (Mid)",    group=grp_tf, tooltip="Mid timeframe. Default 4h.")
tf_slow = input.timeframe("D",   "TF 3 (Slow)",   group=grp_tf, tooltip="Slow timeframe = underlying bias. Default Daily.")

// ─────────────────────────────────────────────
// INPUT — LAYOUT
// ─────────────────────────────────────────────
grp_layout = "Layout"
posOpt  = input.string("Top Right", "Table Position",
     options=["Top Left","Top Center","Top Right","Middle Left","Middle Center","Middle Right","Bottom Left","Bottom Center","Bottom Right"],
     group=grp_layout)
sizeOpt = input.string("Small", "Text Size",
     options=["Tiny","Small","Normal","Large"], group=grp_layout)
themeOpt = input.string("Dark", "Theme", options=["Dark","Light"], group=grp_layout)
i_view_mode = input.string("Full", "View Mode",
     options=["Full","Minimal (synthesis)","Compact (alignment)"],
     group=grp_layout, tooltip="Full = complete dashboard with 3 TFs on core assets | Minimal = BIAS per 1h/4h/D | Compact = alignment light")
i_show_link = input.bool(true, "Show 🔗 LINK education column (Full mode)", group=grp_layout)

grp_off = "Table Position (Offset)"
i_h_off = input.int(0, "Horizontal Offset  (− left | + right)", minval=-60, maxval=60, group=grp_off)
i_v_off = input.int(0, "Vertical Offset  (− up | + down)",       minval=-30, maxval=30, group=grp_off)

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
getPos(p) =>
    switch p
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

getSz(s) =>
    s == "Tiny" ? size.tiny : s == "Small" ? size.small : s == "Large" ? size.large : size.normal

t_sz = getSz(sizeOpt)
bool isDark = themeOpt == "Dark"

// short TF label for headers (e.g. "60"→"1h")
f_tf_label(tf) =>
    switch tf
        "1"   => "1m"
        "5"   => "5m"
        "15"  => "15m"
        "30"  => "30m"
        "60"  => "1h"
        "240" => "4h"
        "D"   => "D"
        "W"   => "W"
        "M"   => "Mo"
        =>       tf

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
C_BULL    = color.rgb(0,   200, 100)
C_BEAR    = color.rgb(220, 40,  60)
C_WARN    = color.rgb(255, 165, 0)
C_HOT     = color.rgb(255, 80,  50)
C_OK      = color.rgb(80,  180, 100)
C_NEUTRAL = color.rgb(120, 120, 120)

C_BG_LIGHT  = isDark ? color.rgb(30, 30, 30) : color.rgb(245, 245, 245)
C_BG_DARK   = isDark ? color.rgb(15, 15, 15) : color.rgb(220, 220, 220)
C_HDR_BG    = isDark ? color.rgb(15, 15, 40) : color.rgb(20, 30, 80)
C_SEC_BG    = isDark ? color.rgb(40, 25, 60) : color.rgb(180, 170, 200)
C_LINK_BG   = isDark ? color.rgb(25, 35, 25) : color.rgb(235, 245, 235)
C_TXT       = isDark ? color.white            : color.black
C_TXT_LBL   = isDark ? color.rgb(180,180,180) : color.rgb(80,80,80)
C_TXT_EDU   = isDark ? color.rgb(150,200,150) : color.rgb(40,90,40)
C_INVIS     = color.new(color.black, 100)

// ─────────────────────────────────────────────
// DATA FETCH
// f_data1: one TF (for slow assets)
// f_data3: three TFs in dedicated calls (for core assets)
// ─────────────────────────────────────────────
f_data1(symbol, tf) =>
    [c, pc] = request.security(symbol, tf, [close, close[1]],
         lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
    chg = (not na(pc)) and pc != 0 ? (c - pc) / pc * 100 : 0.0
    [c, chg]

// ===== CORE ASSETS — 3 timeframes each (7 × 3 = 21 calls) =====
[au_vf,  au_cf]  = f_data1(sym_au,  tf_fast)
[au_vm,  au_cm]  = f_data1(sym_au,  tf_mid)
[au_vs,  au_cs]  = f_data1(sym_au,  tf_slow)

[dxy_vf, dxy_cf] = f_data1(sym_dxy, tf_fast)
[dxy_vm, dxy_cm] = f_data1(sym_dxy, tf_mid)
[dxy_vs, dxy_cs] = f_data1(sym_dxy, tf_slow)

[u10_vf, u10_cf] = f_data1(sym_u10, tf_fast)
[u10_vm, u10_cm] = f_data1(sym_u10, tf_mid)
[u10_vs, u10_cs] = f_data1(sym_u10, tf_slow)

[jpy_vf, jpy_cf] = f_data1(sym_jpy, tf_fast)
[jpy_vm, jpy_cm] = f_data1(sym_jpy, tf_mid)
[jpy_vs, jpy_cs] = f_data1(sym_jpy, tf_slow)

[chf_vf, chf_cf] = f_data1(sym_chf, tf_fast)
[chf_vm, chf_cm] = f_data1(sym_chf, tf_mid)
[chf_vs, chf_cs] = f_data1(sym_chf, tf_slow)

[vix_vf, vix_cf] = f_data1(sym_vix, tf_fast)
[vix_vm, vix_cm] = f_data1(sym_vix, tf_mid)
[vix_vs, vix_cs] = f_data1(sym_vix, tf_slow)

[ag_vf,  ag_cf]  = f_data1(sym_ag,  tf_fast)
[ag_vm,  ag_cm]  = f_data1(sym_ag,  tf_mid)
[ag_vs,  ag_cs]  = f_data1(sym_ag,  tf_slow)

// ===== SLOW ASSETS — Daily only (12 calls) =====
[u02_v, u02_c]   = f_data1(sym_u02, tf_slow)
[u20_v, u20_c]   = f_data1(sym_u20, tf_slow)
[u30_v, u30_c]   = f_data1(sym_u30, tf_slow)
[inf_v, inf_c]   = f_data1(sym_inf, tf_slow)
[s5_v,  s5_c]    = f_data1(sym_s5,  tf_slow)
[nky_v, nky_c]   = f_data1(sym_nky, tf_slow)
[hsi_v, hsi_c]   = f_data1(sym_hsi, tf_slow)
[urth_v, urth_c] = f_data1(sym_urth, tf_slow)
[cnh_v, cnh_c]   = f_data1(sym_cnh, tf_slow)
[eur_v, eur_c]   = f_data1(sym_eur, tf_slow)
[btc_v, btc_c]   = f_data1(sym_btc, tf_slow)
[wti_v, wti_c]   = f_data1(sym_wti, tf_slow)
// (Daily values of the core assets reuse the *_vs / *_cs fetched above)

// ─────────────────────────────────────────────
// EDUCATIONAL PHRASES (EN)
// ─────────────────────────────────────────────
EDU_DXY  = "Dollar up → Gold down"
EDU_YLD  = "Yields up → Gold down"
EDU_U02  = "2Y up = hawkish Fed → Gold down"
EDU_CRV  = "Curve inverted = Fed stress / recession risk"
EDU_INF  = "Inflation up → Gold up"
EDU_BRD  = "Strong stocks → Gold down"
EDU_JPY  = "Up = weak Yen → Gold down"
EDU_EQ   = "Stocks up → Gold down (haven if VIX high)"
EDU_VIX  = "Fear up → Gold up"
EDU_CNH  = "Up = China stress → Gold up"
EDU_CHF  = "Down = strong Franc → Gold up"
EDU_EUR  = "Up = weak Dollar → Gold up"
EDU_AG   = "Gold's twin, confirms it"
EDU_BTC  = "Risk-on: up → Gold down"
EDU_WTI  = "Above $100 + up = stagflation"
EDU_AU   = "Reference"
EDU_RAT  = "Gold rich/cheap vs Oil"

// ─────────────────────────────────────────────
// STATUS FUNCTIONS (use slow-TF value for the Status column)
// ─────────────────────────────────────────────
f_dxy_status(v) =>
    s = "💀 VERY WEAK"
    c = C_BEAR
    if v > 110
        s := "🔥 VERY STRONG"
        c := C_HOT
    else if v > 105
        s := "▲ STRONG"
        c := C_BULL
    else if v > 100
        s := "▬ NEUTRAL"
        c := C_NEUTRAL
    else if v > 95
        s := "▼ WEAK"
        c := C_BEAR
    [s, c]

f_yld_status(v) =>
    s = "💚 LOW"
    c = C_BULL
    if v > 5.5
        s := "🔥 VERY HIGH"
        c := C_HOT
    else if v > 4.4
        s := "⚠️ HIGH"
        c := C_WARN
    else if v > 3.5
        s := "▬ NORMAL"
        c := C_NEUTRAL
    else if v > 2.5
        s := "✓ MEDIUM-LOW"
        c := C_OK
    [s, c]

f_inf_status(v) =>
    s = "✓ AT FED TARGET"
    c = C_OK
    if v > 5
        s := "🔥 OUT OF CONTROL"
        c := C_HOT
    else if v > 4
        s := "⚠️ VERY HIGH"
        c := C_WARN
    else if v > 3
        s := "⚠️ HIGH"
        c := C_WARN
    else if v > 2
        s := "▬ ABOVE FED TARGET"
        c := C_NEUTRAL
    [s, c]

// Yield curve 10Y-2Y status. Negative = inverted (Fed stress / recession signal).
// An inverting curve is generally a risk-off / pro-Gold backdrop over time.
f_curve_status(spread) =>
    s = "▬ FLAT"
    c = C_NEUTRAL
    if spread < -0.5
        s := "🔴 DEEPLY INVERTED"
        c := C_HOT
    else if spread < 0
        s := "⚠️ INVERTED"
        c := C_WARN
    else if spread < 0.5
        s := "▬ FLAT"
        c := C_NEUTRAL
    else if spread < 1.5
        s := "✓ NORMAL"
        c := C_OK
    else
        s := "🟢 STEEP"
        c := C_BULL
    [s, c]

f_brd_status(v) =>
    s = "💀 EXTREME (buy)"
    c = C_BULL
    if v > 80
        s := "🚀 EUPHORIA (sell)"
        c := C_WARN
    else if v > 70
        s := "▲ STRONG BULL"
        c := C_BULL
    else if v > 50
        s := "🟢 WEAK BULL"
        c := C_OK
    else if v > 30
        s := "⚠️ WARNING"
        c := C_WARN
    else if v > 20
        s := "🔴 BEAR"
        c := C_BEAR
    [s, c]

f_jpy_status(v) =>
    s = "💚 YEN STRONG"
    c = C_BULL
    if v > 165
        s := "🔥 YEN COLLAPSED"
        c := C_HOT
    else if v > 155
        s := "⚠️ YEN VERY WEAK"
        c := C_WARN
    else if v > 145
        s := "▬ YEN WEAK"
        c := C_NEUTRAL
    else if v > 135
        s := "✓ YEN NORMAL"
        c := C_OK
    [s, c]

f_chf_status(v) =>
    s = "💚 FRANC VERY STRONG"
    c = C_BULL
    if v > 0.95
        s := "⚠️ FRANC WEAK"
        c := C_WARN
    else if v > 0.90
        s := "▬ FRANC NORMAL"
        c := C_NEUTRAL
    else if v > 0.85
        s := "✓ FRANC FIRM"
        c := C_OK
    [s, c]

f_eur_status(v) =>
    s = "💚 EURO STRONG ($ weak)"
    c = C_BULL
    if v < 1.00
        s := "🔴 EURO WEAK ($ strong)"
        c := C_BEAR
    else if v < 1.05
        s := "▼ EURO SOFT"
        c := C_WARN
    else if v < 1.12
        s := "▬ EURO NORMAL"
        c := C_NEUTRAL
    [s, c]

f_dir_status(ch) =>
    s = "▬ FLAT"
    c = C_NEUTRAL
    if ch > 1.5
        s := "▲▲ STRONG UP"
        c := C_BULL
    else if ch > 0.3
        s := "▲ UP"
        c := C_OK
    else if ch < -1.5
        s := "▼▼ STRONG DOWN"
        c := C_BEAR
    else if ch < -0.3
        s := "▼ DOWN"
        c := C_BEAR
    [s, c]

f_cnh_status(v) =>
    s = "💚 CNH VERY STRONG"
    c = C_BULL
    if v > 7.5
        s := "🔥 CNH UNDER STRESS"
        c := C_HOT
    else if v > 7.3
        s := "⚠️ CNH WEAK"
        c := C_WARN
    else if v > 7.0
        s := "▬ CNH NORMAL"
        c := C_NEUTRAL
    else if v > 6.5
        s := "✓ CNH STRONG"
        c := C_OK
    [s, c]

f_vix_status(v) =>
    s = "💀 EXTREME FEAR"
    c = C_HOT
    if v < 15
        s := "😌 COMPLACENCY"
        c := C_WARN
    else if v < 20
        s := "▬ NORMAL"
        c := C_NEUTRAL
    else if v < 30
        s := "⚠️ ELEVATED FEAR"
        c := C_WARN
    else if v < 40
        s := "🔥 FEAR"
        c := C_BEAR
    [s, c]

// ─────────────────────────────────────────────
// GOLD IMPACT
// ─────────────────────────────────────────────
f_gimpact_inv(chg) =>
    s = 0
    c = C_NEUTRAL
    if chg > 0.3
        s := -1
        c := C_BEAR
    else if chg < -0.3
        s := 1
        c := C_BULL
    [s, c]

f_gimpact_dir(chg) =>
    s = 0
    c = C_NEUTRAL
    if chg > 0.3
        s := 1
        c := C_BULL
    else if chg < -0.3
        s := -1
        c := C_BEAR
    [s, c]

f_gimpact_dxy(chg, vix_lvl) =>
    s = 0
    c = C_NEUTRAL
    if vix_lvl >= 30
        s := 0
        c := C_NEUTRAL
    else if chg > 0.3
        s := -1
        c := C_BEAR
    else if chg < -0.3
        s := 1
        c := C_BULL
    [s, c]

f_gimpact_wti(wti_lvl, wti_chg) =>
    s = 0
    c = C_NEUTRAL
    if wti_lvl > 100 and wti_chg > 0.3
        s := -1
        c := C_BEAR
    else if wti_lvl <= 100 and wti_chg > 0.3
        s := 1
        c := C_BULL
    else if wti_chg < -0.3 and wti_lvl > 100
        s := 1
        c := C_BULL
    else if wti_chg < -0.3 and wti_lvl <= 100
        s := -1
        c := C_BEAR
    [s, c]

f_gimpact_eq(chg, vix_lvl) =>
    s = 0
    c = C_NEUTRAL
    if chg > 0.3
        s := -1
        c := C_BEAR
    else if chg < -0.3 and vix_lvl > 22
        s := 1
        c := C_BULL
    [s, c]

f_gimpact_dir_light(chg) =>
    s = 0
    c = C_NEUTRAL
    if chg > 0.5
        s := 1
        c := C_BULL
    else if chg < -0.5
        s := -1
        c := C_BEAR
    [s, c]

f_bias_aggregate(score) =>
    s = "▬ MIXED"
    c = C_NEUTRAL
    if score >= 8
        s := "🚀 STRONG PRO-GOLD"
        c := C_BULL
    else if score >= 3
        s := "▲ PRO-GOLD"
        c := C_OK
    else if score <= -8
        s := "🔥 STRONG ANTI-GOLD"
        c := C_HOT
    else if score <= -3
        s := "▼ ANTI-GOLD"
        c := C_BEAR
    [s, c]

f_ratio_status(r) =>
    s = "🔴 GOLD VERY EXPENSIVE"
    c = C_HOT
    if r < 15
        s := "🚀 GOLD CHEAP vs OIL"
        c := C_BULL
    else if r < 25
        s := "✓ EQUILIBRIUM"
        c := C_OK
    else if r < 40
        s := "▬ FAIR PRICE"
        c := C_NEUTRAL
    else if r < 60
        s := "⚠️ GOLD EXPENSIVE vs OIL"
        c := C_WARN
    [s, c]

f_scenario(wti, gold_chg, yld10) =>
    s = "▬ MIXED"
    c = C_NEUTRAL
    code = 0
    if wti > 100 and gold_chg < -0.5
        s := "🔥 STAGFLATIONARY (no Gold longs)"
        c := C_HOT
        code := 1
    else if wti > 100 and gold_chg > 0.5
        s := "🚀 GOLD HEDGE ACTIVE"
        c := C_BULL
        code := 2
    else if wti < 100 and gold_chg > 0.5 and yld10 > 4.3
        s := "⚠️ RISK-OFF (cautious)"
        c := C_WARN
        code := 3
    else if wti < 100 and gold_chg > 0.5 and yld10 < 4.3
        s := "▲ REFLATIONARY (pro-Gold)"
        c := C_BULL
        code := 4
    else if wti < 100 and gold_chg < -0.5
        s := "▬ RISK-ON (anti-Gold)"
        c := C_NEUTRAL
        code := 5
    [s, c, code]

f_trade_signal(score, scn_code) =>
    s = "⏸️ WAIT"
    c = C_NEUTRAL
    if scn_code == 1
        s := "⏸️ WAIT (yield squeeze)"
        c := C_WARN
    else if scn_code == 2
        s := score >= 3 ? "🚀 LONG STRONG" : "▲ LONG OK"
        c := score >= 3 ? C_BULL : C_OK
    else if scn_code == 4
        s := score >= 3 ? "🚀 LONG STRONG" : "▲ LONG OK"
        c := score >= 3 ? C_BULL : C_OK
    else if scn_code == 3
        s := "⚠️ LONG CAUTIOUS"
        c := C_WARN
    else if scn_code == 5
        s := "🛑 NO LONG (anti-Gold)"
        c := C_BEAR
    else
        if score >= 8
            s := "🚀 LONG STRONG"
            c := C_BULL
        else if score >= 3
            s := "▲ LONG OK"
            c := C_OK
        else if score <= -8
            s := "🛑 STAY OUT / SHORT BIAS"
            c := C_HOT
        else if score <= -3
            s := "▼ NO LONG"
            c := C_BEAR
        else
            s := "⏸️ WAIT (mixed signals)"
            c := C_NEUTRAL
    [s, c]

f_chg_color(chg) => chg > 0 ? C_BULL : chg < 0 ? C_BEAR : C_NEUTRAL
f_chg_str(chg)   => (chg >= 0 ? "+" : "") + str.tostring(chg, "#.##") + "%"

// per-TF aggregate bias for the 7 core assets (used by Minimal/Compact)
// Each core asset contributes its score on the given TF's change values.
f_core_bias(dxy_chg, u10_chg, jpy_chg, chf_chg, vix_chg, ag_chg, vix_lvl) =>
    [s_dxy, _cd] = f_gimpact_dxy(dxy_chg, vix_lvl)
    [s_u10, _cu] = f_gimpact_inv(u10_chg)
    [s_jpy, _cj] = f_gimpact_inv(jpy_chg)
    [s_chf, _cc] = f_gimpact_inv(chf_chg)
    [s_vix, _cv] = f_gimpact_dir(vix_chg)
    [s_ag,  _ca] = f_gimpact_dir_light(ag_chg)
    s_dxy + s_u10 + s_jpy + s_chf + s_vix + s_ag

// ─────────────────────────────────────────────
// PADDING LOGIC
// ─────────────────────────────────────────────
isLeftAnchor   = posOpt == "Top Left"    or posOpt == "Middle Left"   or posOpt == "Bottom Left"
isRightAnchor  = posOpt == "Top Right"   or posOpt == "Middle Right"  or posOpt == "Bottom Right"
isTopAnchor    = posOpt == "Top Left"    or posOpt == "Top Center"    or posOpt == "Top Right"
isBottomAnchor = posOpt == "Bottom Left" or posOpt == "Bottom Center" or posOpt == "Bottom Right"

var int  h_pad       = 0
var bool pad_on_left = false
h_pad       := 0
pad_on_left := false
if i_h_off < 0 and not isLeftAnchor
    h_pad := math.abs(i_h_off)
    pad_on_left := false
if i_h_off > 0 and not isRightAnchor
    h_pad := i_h_off
    pad_on_left := true

var int  v_pad      = 0
var bool pad_on_top = false
v_pad      := 0
pad_on_top := false
if i_v_off < 0 and not isTopAnchor
    v_pad := math.abs(i_v_off)
    pad_on_top := false
if i_v_off > 0 and not isBottomAnchor
    v_pad := i_v_off
    pad_on_top := true

// VIEW MODE
mode_full    = i_view_mode == "Full"
mode_minimal = i_view_mode == "Minimal (synthesis)"
mode_compact = i_view_mode == "Compact (alignment)"
show_link = mode_full and i_show_link

// FULL columns: Asset | Value | Chg%(D) | Status | 🥇1h | 🥇4h | 🥇D  (+ LINK)
// = 7 base cols (+1 LINK)
VISIBLE_COLS = mode_full ? (show_link ? 8 : 7) : 1
VISIBLE_ROWS = mode_full ? 26 : (mode_minimal ? 3 : 1)
total_cols = VISIBLE_COLS + h_pad
total_rows = VISIBLE_ROWS + v_pad
col_start  = pad_on_left ? h_pad : 0
row_start  = pad_on_top  ? v_pad : 0

lbl_f = f_tf_label(tf_fast)
lbl_m = f_tf_label(tf_mid)
lbl_s = f_tf_label(tf_slow)

// EDU cell helper — LINK column lives at col index 7 in Full
f_edu_cell(t, r, txt) =>
    if show_link
        table.cell(t, col_start + 7, row_start + r, txt, text_color=C_TXT_EDU, bgcolor=C_LINK_BG, text_size=t_sz, text_halign=text.align_left)

// Draws a standard SLOW (Daily-only) asset row.
// Status cell now shows a colored text label (no more empty black hole).
// The 1h/4h cells are kept neutral-gray (not black) to teach "Daily-only".
f_row_slow(t, r, lbl, lbl_bg, valstr, chg, st_txt, st_col, gi_col, edu) =>
    table.cell(t, col_start + 0, row_start + r, lbl, text_color=C_TXT_LBL, bgcolor=lbl_bg, text_size=t_sz)
    table.cell(t, col_start + 1, row_start + r, valstr, text_color=C_TXT, bgcolor=C_BG_LIGHT, text_size=t_sz)
    table.cell(t, col_start + 2, row_start + r, f_chg_str(chg), text_color=f_chg_color(chg), bgcolor=C_BG_LIGHT, text_size=t_sz)
    table.cell(t, col_start + 3, row_start + r, st_txt, text_color=color.white, bgcolor=st_col, text_size=t_sz)
    // slow assets: only Daily cell colored, 1h/4h shown neutral gray (Daily-only)
    table.cell(t, col_start + 4, row_start + r, "·", text_color=color.white, bgcolor=C_NEUTRAL, text_size=t_sz)
    table.cell(t, col_start + 5, row_start + r, "·", text_color=color.white, bgcolor=C_NEUTRAL, text_size=t_sz)
    table.cell(t, col_start + 6, row_start + r, "", bgcolor=gi_col, text_size=t_sz)
    f_edu_cell(t, r, edu)

// ─────────────────────────────────────────────
// TABLE RENDERING
// ─────────────────────────────────────────────
var table tbl = table.new(getPos(posOpt), total_cols, total_rows, border_width=0, frame_width=2, frame_color=color.new(color.gray, 20))

if barstate.islast
    for c = 0 to total_cols - 1
        for r = 0 to total_rows - 1
            isVisibleCell = (c >= col_start and c < col_start + VISIBLE_COLS) and (r >= row_start and r < row_start + VISIBLE_ROWS)
            if not isVisibleCell
                table.cell(tbl, c, r, "    ", bgcolor=C_INVIS, text_color=C_INVIS, text_size=t_sz)

    // ═════ CORE per-TF impact scores (use slow-TF VIX level as regime gate) ═════
    // Gold itself: directional, shown for reference (no score into bias)
    [giauf_s, giauf_c] = f_dir_status(au_cf)
    [giaum_s, giaum_c] = f_dir_status(au_cm)
    [giaus_s, giaus_c] = f_dir_status(au_cs)

    [gidxyf_s, gidxyf_c] = f_gimpact_dxy(dxy_cf, vix_vs)
    [gidxym_s, gidxym_c] = f_gimpact_dxy(dxy_cm, vix_vs)
    [gidxys_s, gidxys_c] = f_gimpact_dxy(dxy_cs, vix_vs)

    [giu10f_s, giu10f_c] = f_gimpact_inv(u10_cf)
    [giu10m_s, giu10m_c] = f_gimpact_inv(u10_cm)
    [giu10s_s, giu10s_c] = f_gimpact_inv(u10_cs)

    [gijpyf_s, gijpyf_c] = f_gimpact_inv(jpy_cf)
    [gijpym_s, gijpym_c] = f_gimpact_inv(jpy_cm)
    [gijpys_s, gijpys_c] = f_gimpact_inv(jpy_cs)

    [gichff_s, gichff_c] = f_gimpact_inv(chf_cf)
    [gichfm_s, gichfm_c] = f_gimpact_inv(chf_cm)
    [gichfs_s, gichfs_c] = f_gimpact_inv(chf_cs)

    [givixf_s, givixf_c] = f_gimpact_dir(vix_cf)
    [givixm_s, givixm_c] = f_gimpact_dir(vix_cm)
    [givixs_s, givixs_c] = f_gimpact_dir(vix_cs)

    [giagf_s, giagf_c] = f_gimpact_dir_light(ag_cf)
    [giagm_s, giagm_c] = f_gimpact_dir_light(ag_cm)
    [giags_s, giags_c] = f_gimpact_dir_light(ag_cs)

    // ═════ SLOW asset impacts (Daily) ═════
    [gi_u20_s, gi_u20_c]   = f_gimpact_inv(u20_c)
    [gi_u30_s, gi_u30_c]   = f_gimpact_inv(u30_c)
    // 2Y: most Fed-sensitive yield, inverse to Gold (scored into the bias)
    [gi_u02_s, gi_u02_c]   = f_gimpact_inv(u02_c)
    // Yield curve 10Y-2Y spread (display + status only, not double-scored into bias)
    curve_spread = u10_vs - u02_v
    [st_crv, col_crv] = f_curve_status(curve_spread)
    [gi_inf_s, gi_inf_c]   = f_gimpact_dir(inf_c)
    [gi_s5_s,  gi_s5_c]    = f_gimpact_inv(s5_c)
    [gi_nky_s, gi_nky_c]   = f_gimpact_eq(nky_c, vix_vs)
    [gi_hsi_s, gi_hsi_c]   = f_gimpact_eq(hsi_c, vix_vs)
    [gi_urth_s, gi_urth_c] = f_gimpact_eq(urth_c, vix_vs)
    [gi_cnh_s, gi_cnh_c]   = f_gimpact_dir(cnh_c)
    [gi_eur_s, gi_eur_c]   = f_gimpact_dir(eur_c)
    [gi_btc_s, gi_btc_c]   = f_gimpact_inv(btc_c)
    [gi_wti_s, gi_wti_c]   = f_gimpact_wti(wti_v, wti_c)

    // ═════ Per-TF total bias (core + slow). Slow assets use their Daily score in all TFs ═════
    slow_sum = gi_u02_s + gi_u20_s + gi_u30_s + gi_inf_s + gi_s5_s + gi_nky_s + gi_hsi_s + gi_urth_s + gi_cnh_s + gi_eur_s + gi_btc_s + gi_wti_s
    core_f = gidxyf_s + giu10f_s + gijpyf_s + gichff_s + givixf_s + giagf_s
    core_m = gidxym_s + giu10m_s + gijpym_s + gichfm_s + givixm_s + giagm_s
    core_s = gidxys_s + giu10s_s + gijpys_s + gichfs_s + givixs_s + giags_s
    bias_f = core_f + slow_sum
    bias_m = core_m + slow_sum
    bias_s = core_s + slow_sum

    [bias_txt_f, bias_col_f] = f_bias_aggregate(bias_f)
    [bias_txt_m, bias_col_m] = f_bias_aggregate(bias_m)
    [bias_txt_s, bias_col_s] = f_bias_aggregate(bias_s)

    // Scenario + trade signal use the SLOW (Daily) values — the underlying bias
    [st_scn, col_scn, scn_code] = f_scenario(wti_v, au_cs, u10_vs)
    [trade_txt, trade_color] = f_trade_signal(bias_s, scn_code)

    // ═════ ALIGNMENT across the 3 TFs (for Compact) ═════
    sign_f = bias_f >= 3 ? 1 : bias_f <= -3 ? -1 : 0
    sign_m = bias_m >= 3 ? 1 : bias_m <= -3 ? -1 : 0
    sign_s = bias_s >= 3 ? 1 : bias_s <= -3 ? -1 : 0
    align_txt = "⚠️ CONFLICT"
    align_col = C_WARN
    if sign_f == 1 and sign_m == 1 and sign_s == 1
        align_txt := "🟢 ALIGNED LONG"
        align_col := C_BULL
    else if sign_f == -1 and sign_m == -1 and sign_s == -1
        align_txt := "🔴 ALIGNED SHORT"
        align_col := C_BEAR
    else if sign_f == 0 and sign_m == 0 and sign_s == 0
        align_txt := "⏸️ NEUTRAL"
        align_col := C_NEUTRAL

    // ═════════════════════════════════════════════
    //  FULL MODE
    // ═════════════════════════════════════════════
    if mode_full
        // ── LOGO ROW (white background, black text) ──
        last_col = show_link ? 7 : 6
        table.merge_cells(tbl, col_start + 0, row_start + 0, col_start + last_col, row_start + 0)
        table.cell(tbl, col_start + 0, row_start + 0, "🦅 AQUILA REALE — MACRO", text_color=color.black, bgcolor=color.white, text_size=t_sz, text_halign=text.align_center)

        // Header
        table.cell(tbl, col_start + 0, row_start + 1, "🦅 MACRO", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 1, "Val(" + lbl_s + ")", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 1, "Chg(" + lbl_s + ")", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 1, "Status", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 1, "🥇" + lbl_f, text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 1, "🥇" + lbl_m, text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 1, "🥇" + lbl_s, text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        if show_link
            table.cell(tbl, col_start + 7, row_start + 1, "🔗 LINK TO GOLD", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz, text_halign=text.align_left)

        // ── CORE row helper (inline, 3 colored TF cells) ──
        // Row 1: DXY
        [st_dxy, col_dxy] = f_dxy_status(dxy_vs)
        table.cell(tbl, col_start + 0, row_start + 2, "🇺🇸 DXY", text_color=C_TXT_LBL, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 2, str.tostring(dxy_vs, "#.##"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 2, f_chg_str(dxy_cs), text_color=f_chg_color(dxy_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 2, st_dxy, text_color=color.white, bgcolor=col_dxy, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 2, "", bgcolor=gidxyf_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 2, "", bgcolor=gidxym_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 2, "", bgcolor=gidxys_c, text_size=t_sz)
        f_edu_cell(tbl, 2, EDU_DXY)

        // Row 2: US10Y
        [st_u10, col_u10] = f_yld_status(u10_vs)
        table.cell(tbl, col_start + 0, row_start + 3, "US10Y", text_color=C_TXT_LBL, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 3, str.tostring(u10_vs, "#.##") + "%", text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 3, f_chg_str(u10_cs), text_color=f_chg_color(u10_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 3, st_u10, text_color=color.white, bgcolor=col_u10, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 3, "", bgcolor=giu10f_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 3, "", bgcolor=giu10m_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 3, "", bgcolor=giu10s_c, text_size=t_sz)
        f_edu_cell(tbl, 3, EDU_YLD)

        // Row: US02Y — the Fed-sensitive 2Y yield (slow)
        [st_u02, col_u02] = f_yld_status(u02_v)
        f_row_slow(tbl, 4, "US02Y", C_BG_LIGHT, str.tostring(u02_v, "#.##") + "%", u02_c, st_u02, col_u02, gi_u02_c, EDU_U02)

        // Row: CURVE 10Y-2Y spread (computed, no extra security call)
        table.cell(tbl, col_start + 0, row_start + 5, "📐 CURVE 10-2", text_color=C_TXT_LBL, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 5, str.tostring(curve_spread, "#.##"), text_color=C_TXT, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 5, "", bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 5, st_crv, text_color=color.white, bgcolor=col_crv, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 5, "·", text_color=color.white, bgcolor=C_NEUTRAL, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 5, "·", text_color=color.white, bgcolor=C_NEUTRAL, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 5, "", bgcolor=col_crv, text_size=t_sz)
        f_edu_cell(tbl, 5, EDU_CRV)

        // Row 3: US20Y (slow)
        [st_u20, col_u20] = f_yld_status(u20_v)
        f_row_slow(tbl, 6, "US20Y", C_BG_LIGHT, str.tostring(u20_v, "#.##") + "%", u20_c, st_u20, col_u20, gi_u20_c, EDU_YLD)

        // Row 4: US30Y (slow)
        [st_u30, col_u30] = f_yld_status(u30_v)
        f_row_slow(tbl, 7, "US30Y", C_BG_LIGHT, str.tostring(u30_v, "#.##") + "%", u30_c, st_u30, col_u30, gi_u30_c, EDU_YLD)

        // Row 5: Inflation (slow)
        [st_inf, col_inf] = f_inf_status(inf_v)
        f_row_slow(tbl, 8, "INFLATION", C_BG_LIGHT, str.tostring(inf_v, "#.#") + "%", inf_c, st_inf, col_inf, gi_inf_c, EDU_INF)

        // Row 6: Breadth (slow)
        [st_brd, col_brd] = f_brd_status(s5_v)
        f_row_slow(tbl, 9, "S&P 200dma", C_BG_LIGHT, str.tostring(s5_v, "#.#") + "%", s5_c, st_brd, col_brd, gi_s5_c, EDU_BRD)

        // Row 7: USDJPY (core)
        [st_jpy, col_jpy] = f_jpy_status(jpy_vs)
        table.cell(tbl, col_start + 0, row_start + 10, "🇯🇵 USDJPY", text_color=C_TXT_LBL, bgcolor=C_SEC_BG, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 10, str.tostring(jpy_vs, "#.##"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 10, f_chg_str(jpy_cs), text_color=f_chg_color(jpy_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 10, st_jpy, text_color=color.white, bgcolor=col_jpy, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 10, "", bgcolor=gijpyf_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 10, "", bgcolor=gijpym_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 10, "", bgcolor=gijpys_c, text_size=t_sz)
        f_edu_cell(tbl, 10, EDU_JPY)

        // Row 8: Nikkei (slow)
        [st_nky, col_nky] = f_dir_status(nky_c)
        f_row_slow(tbl, 11, "🇯🇵 NIKKEI", C_SEC_BG, str.tostring(nky_v, "#"), nky_c, st_nky, col_nky, gi_nky_c, EDU_EQ)

        // Row 9: Hang Seng (slow)
        [st_hsi, col_hsi] = f_dir_status(hsi_c)
        f_row_slow(tbl, 12, "🇭🇰 HANG SENG", C_SEC_BG, str.tostring(hsi_v, "#"), hsi_c, st_hsi, col_hsi, gi_hsi_c, EDU_EQ)

        // Row 10: VIX (core)
        [st_vix, col_vix] = f_vix_status(vix_vs)
        table.cell(tbl, col_start + 0, row_start + 13, "😱 VIX", text_color=C_TXT_LBL, bgcolor=C_SEC_BG, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 13, str.tostring(vix_vs, "#.##"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 13, f_chg_str(vix_cs), text_color=f_chg_color(vix_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 13, st_vix, text_color=color.white, bgcolor=col_vix, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 13, "", bgcolor=givixf_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 13, "", bgcolor=givixm_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 13, "", bgcolor=givixs_c, text_size=t_sz)
        f_edu_cell(tbl, 13, EDU_VIX)

        // Row 11: World (slow)
        [st_urth, col_urth] = f_dir_status(urth_c)
        f_row_slow(tbl, 14, "🌍 WORLD", C_SEC_BG, str.tostring(urth_v, "#.##"), urth_c, st_urth, col_urth, gi_urth_c, EDU_EQ)

        // Row 12: USDCNH (slow)
        [st_cnh, col_cnh] = f_cnh_status(cnh_v)
        f_row_slow(tbl, 15, "🇨🇳 USDCNH", C_SEC_BG, str.tostring(cnh_v, "#.####"), cnh_c, st_cnh, col_cnh, gi_cnh_c, EDU_CNH)

        // Row 13: USDCHF (core)
        [st_chf, col_chf] = f_chf_status(chf_vs)
        table.cell(tbl, col_start + 0, row_start + 16, "🇨🇭 USDCHF", text_color=C_TXT_LBL, bgcolor=C_SEC_BG, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 16, str.tostring(chf_vs, "#.####"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 16, f_chg_str(chf_cs), text_color=f_chg_color(chf_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 16, st_chf, text_color=color.white, bgcolor=col_chf, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 16, "", bgcolor=gichff_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 16, "", bgcolor=gichfm_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 16, "", bgcolor=gichfs_c, text_size=t_sz)
        f_edu_cell(tbl, 16, EDU_CHF)

        // Row 14: EURUSD (slow)
        [st_eur, col_eur] = f_eur_status(eur_v)
        table.cell(tbl, col_start + 0, row_start + 17, "🇪🇺 EURUSD", text_color=C_TXT_LBL, bgcolor=C_SEC_BG, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 17, str.tostring(eur_v, "#.####"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 17, f_chg_str(eur_c), text_color=f_chg_color(eur_c), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 17, st_eur, text_color=color.white, bgcolor=col_eur, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 17, "·", text_color=C_NEUTRAL, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 17, "·", text_color=C_NEUTRAL, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 17, "", bgcolor=gi_eur_c, text_size=t_sz)
        f_edu_cell(tbl, 17, EDU_EUR)

        // Row 15: Gold (core, reference — gray score cells)
        [st_au, col_au] = f_dir_status(au_cs)
        table.cell(tbl, col_start + 0, row_start + 18, "🥇 GOLD", text_color=C_TXT_LBL, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 18, str.tostring(au_vs, "#.##"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 18, f_chg_str(au_cs), text_color=f_chg_color(au_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 18, st_au, text_color=color.white, bgcolor=col_au, text_size=t_sz)
        // Gold's own direction per TF, shown as its dir color (teaching: does price confirm across TFs?)
        table.cell(tbl, col_start + 4, row_start + 18, "", bgcolor=giauf_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 18, "", bgcolor=giaum_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 18, "", bgcolor=giaus_c, text_size=t_sz)
        f_edu_cell(tbl, 18, EDU_AU)

        // Row 16: Silver (core)
        [st_ag, col_ag] = f_dir_status(ag_cs)
        table.cell(tbl, col_start + 0, row_start + 19, "🥈 SILVER", text_color=C_TXT_LBL, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 19, str.tostring(ag_vs, "#.##"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 19, f_chg_str(ag_cs), text_color=f_chg_color(ag_cs), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 19, st_ag, text_color=color.white, bgcolor=col_ag, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 19, "", bgcolor=giagf_c, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 19, "", bgcolor=giagm_c, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 19, "", bgcolor=giags_c, text_size=t_sz)
        f_edu_cell(tbl, 19, EDU_AG)

        // Row 17: Bitcoin (slow)
        [st_btc, col_btc] = f_dir_status(btc_c)
        f_row_slow(tbl, 20, "₿ BITCOIN", C_BG_LIGHT, str.tostring(btc_v, "#"), btc_c, st_btc, col_btc, gi_btc_c, EDU_BTC)

        // Row 18: WTI (slow)
        [st_wti, col_wti] = f_dir_status(wti_c)
        f_row_slow(tbl, 21, "🛢 OIL", C_BG_LIGHT, str.tostring(wti_v, "#.##"), wti_c, st_wti, col_wti, gi_wti_c, EDU_WTI)

        // Row 19: Gold/Oil Ratio (uses Daily values)
        gold_prev_calc  = au_cs != 0 ? au_vs / (1 + au_cs / 100)  : au_vs
        oil_prev_calc   = wti_c != 0 ? wti_v / (1 + wti_c / 100) : wti_v
        ratio_curr      = wti_v > 0 ? au_vs / wti_v : 0.0
        ratio_prev      = oil_prev_calc > 0 ? gold_prev_calc / oil_prev_calc : ratio_curr
        ratio_chg       = ratio_prev > 0 ? (ratio_curr - ratio_prev) / ratio_prev * 100 : 0.0
        [st_rat, col_rat] = f_ratio_status(ratio_curr)
        table.cell(tbl, col_start + 0, row_start + 22, "🥇/🛢 RATIO", text_color=C_TXT_LBL, bgcolor=C_BG_LIGHT, text_size=t_sz)
        table.cell(tbl, col_start + 1, row_start + 22, str.tostring(ratio_curr, "#.#"), text_color=C_TXT, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 2, row_start + 22, f_chg_str(ratio_chg), text_color=f_chg_color(ratio_chg), bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 3, row_start + 22, st_rat, text_color=color.white, bgcolor=col_rat, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 22, "·", text_color=C_NEUTRAL, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 22, "·", text_color=C_NEUTRAL, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 22, "", bgcolor=C_NEUTRAL, text_size=t_sz)
        f_edu_cell(tbl, 22, EDU_RAT)

        // Row 20: SCENARIO
        table.cell(tbl, col_start + 0, row_start + 23, "💬 SCENARIO", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.merge_cells(tbl, col_start + 1, row_start + 23, col_start + 3, row_start + 23)
        table.cell(tbl, col_start + 1, row_start + 23, st_scn, text_color=color.white, bgcolor=col_scn, text_size=t_sz)
        table.merge_cells(tbl, col_start + 4, row_start + 23, col_start + 6, row_start + 23)
        table.cell(tbl, col_start + 4, row_start + 23, "", bgcolor=C_NEUTRAL, text_size=t_sz)
        if show_link
            table.cell(tbl, col_start + 7, row_start + 23, "Macro read (Daily)", text_color=C_TXT_EDU, bgcolor=C_LINK_BG, text_size=t_sz, text_halign=text.align_left)

        // Row 21: MACRO BIAS per TF (the heart of MTF) — 3 colored cells
        table.cell(tbl, col_start + 0, row_start + 24, "💎 BIAS", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.merge_cells(tbl, col_start + 1, row_start + 24, col_start + 3, row_start + 24)
        table.cell(tbl, col_start + 1, row_start + 24, lbl_f + ":" + str.tostring(bias_f) + "  " + lbl_m + ":" + str.tostring(bias_m) + "  " + lbl_s + ":" + str.tostring(bias_s), text_color=color.white, bgcolor=C_BG_DARK, text_size=t_sz)
        table.cell(tbl, col_start + 4, row_start + 24, "", bgcolor=bias_col_f, text_size=t_sz)
        table.cell(tbl, col_start + 5, row_start + 24, "", bgcolor=bias_col_m, text_size=t_sz)
        table.cell(tbl, col_start + 6, row_start + 24, "", bgcolor=bias_col_s, text_size=t_sz)
        if show_link
            table.cell(tbl, col_start + 7, row_start + 24, "Bias per TF (green = pro Gold)", text_color=C_TXT_EDU, bgcolor=C_LINK_BG, text_size=t_sz, text_halign=text.align_left)

        // Row 22: ALIGNMENT + TRADE SIGNAL
        table.cell(tbl, col_start + 0, row_start + 25, "🎯 SIGNAL", text_color=color.white, bgcolor=C_HDR_BG, text_size=t_sz)
        table.merge_cells(tbl, col_start + 1, row_start + 25, col_start + 3, row_start + 25)
        table.cell(tbl, col_start + 1, row_start + 25, trade_txt, text_color=color.white, bgcolor=trade_color, text_size=t_sz)
        table.merge_cells(tbl, col_start + 4, row_start + 25, col_start + 6, row_start + 25)
        table.cell(tbl, col_start + 4, row_start + 25, align_txt, text_color=color.white, bgcolor=align_col, text_size=t_sz)
        if show_link
            table.cell(tbl, col_start + 7, row_start + 25, "Verdict + 3-TF alignment (not advice)", text_color=C_TXT_EDU, bgcolor=C_LINK_BG, text_size=t_sz, text_halign=text.align_left)

    // ═════════════════════════════════════════════
    //  MINIMAL MODE — BIAS per TF stacked
    // ═════════════════════════════════════════════
    else if mode_minimal
        table.cell(tbl, col_start + 0, row_start + 0, "1↦ " + lbl_f + ": " + bias_txt_f + " (" + str.tostring(bias_f) + ")", text_color=color.white, bgcolor=bias_col_f, text_size=t_sz, text_halign=text.align_left)
        table.cell(tbl, col_start + 0, row_start + 1, "2↦ " + lbl_m + ": " + bias_txt_m + " (" + str.tostring(bias_m) + ")", text_color=color.white, bgcolor=bias_col_m, text_size=t_sz, text_halign=text.align_left)
        table.cell(tbl, col_start + 0, row_start + 2, "3↦ " + lbl_s + ": " + bias_txt_s + " (" + str.tostring(bias_s) + ")", text_color=color.white, bgcolor=bias_col_s, text_size=t_sz, text_halign=text.align_left)

    // ═════════════════════════════════════════════
    //  COMPACT MODE — single alignment light
    // ═════════════════════════════════════════════
    else
        table.cell(tbl, col_start + 0, row_start + 0, align_txt, text_color=color.white, bgcolor=align_col, text_size=t_sz, text_halign=text.align_center)
````
