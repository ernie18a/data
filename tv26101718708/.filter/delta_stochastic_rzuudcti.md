# DELTA Stochastic

- url: https://www.tradingview.com/script/rZUUDctI-DELTA-Stochastic/
- type: indicator
- pine_id: PUB;fdaf20bc479944209bba46a4408b7fdd
- version: 4.0

## Description

🔵 DELTA Stochastic** is a self-configuring stochastic oscillator that selects the right variant, OB/OS thresholds, trend filter, and signal parameters automatically based on what you're trading and what timeframe you're on. Drop it on a chart and it works — no manual tuning required.

* * *

### Why another stochastic?

The classic stochastic has two failure modes:

1. **Wrong speed** — a 14,3,3 stoch is too slow for scalping and too noisy for swing trading. Most traders pick one and use it everywhere.
2. **Catching falling knives** — mean-reversion setups against a strong trend destroy accounts. Most stochastics don't know which direction the trend is going.

DELTA Stochastic solves both by auto-routing the lead variant to the chart timeframe and gating signals with a trend EMA filter.

* * *

### Auto-Routing — One Lead Line Per Chart

| Timeframe | Lead stochastic | Settings |
| --- | --- | --- |
| ≤ 5m (fast) | Fast StochRSI | 3,3,14,14 |
| 15m–2H (medium) | Standard Stoch | 14,3,3 |
| 4H+ / Daily (slow) | Slow StochRSI | 5,5,21,21 |

You always see one clean K/D pair. No multi-line clutter. No averaging that dilutes signals.

* * *

### 5 Asset Presets

Preset routing adjusts OB/OS thresholds, cooldown, trend filter, and EMA length per asset class:

* **X-ETF** — leveraged ETFs (SOXL, TQQQ, etc.) · tight 80/20 zones · fast 20-EMA filter
* **STK** — stocks (AAPL, PLTR, etc.) · 75/25 zones · 50-EMA filter
* **ETF** — non-leveraged funds (SPY, QQQ) · 75/25 · 50-EMA filter
* **Met** — miners and metals (AG, SLV, NUGT, GDX) · wider 73/27 zones
* **CPT** — crypto (BTC, ETH) · 78/22 · trend filter OFF by default

Detection is fully automatic. A 🎯 in the info table means auto-detected. ✋ means manually overridden.

* * *

### 3 Signal Types

🟢 **BUY triangle** — K crosses above D inside the OS zone (with trend filter agreement)🔴 **SELL triangle** — K crosses below D inside the OB zone (with trend filter agreement)💎 **S-BUY / S-SELL** — cross + divergence within the lookback window = highest conviction setup

Plain triangles = watch. 💎 labels = act with conviction.

* * *

### Momentum K Line Coloring

Default mode mirrors SMTF-style trend coloring:

* 🟢 **Green** = K above D and rising — bullish momentum flowing
* 🔴 **Red** = K below D and falling — bearish momentum flowing
* 🟡 **Yellow** = flat or transitioning — wait

Alternative modes: **Zone** (OB=red / OS=green) or **Flat Cyan** (monochrome).

* * *

### Divergence Engine

Ported from **tista's "Stochastic RSI Divergences"** (MPL 2.0, attribution preserved).

Detects all four divergence types — regular bullish/bearish and hidden bullish/bearish — on the smoothed lead K. Pivot lookback of 5 bars on each side = **repaint-free signals** (fires 5 bars late, never redraws history).

Divergences feed directly into the 💎 Strong Signal logic — a cross that agrees with a recent divergence upgrades to S-BUY or S-SELL automatically.

* * *

### Info Table (top-right)

Shows live: preset, TF tier, K value + zone status, last signal, and signal count today.

* * *

### Alerts

Six alert conditions: BUY · SELL · S-BUY · S-SELL · Bull Divergence · Bear Divergence

All alerts respect the signal cooldown — no duplicate alerts in choppy zones. Wire to TradersPost, Telegram, or any webhook-compatible service.

* * *

### Part of the DELTA Trading Suite

DELTA Stochastic is designed to run alongside **🔺 DELTA Go Desk** (master dashboard) and includes a Go Desk integration hook for future confluence scoring.
-------------------------------------------------------------------------------------------
🔵 DELTA Stochastic — Quick Start Guide

**Part of the DELTA Trading Suite · PJ_FatCat (DELTA Trading)***v2.13+ · Pine Script v6 · TradingView*

* * *

## What It Does in 30 Seconds

DELTA Stochastic automatically selects the right stochastic variant for your asset and timeframe — one clean K/D pair, three signal types, and a divergence engine underneath. Drop it on any chart and it routes itself.

* * *

## The 3 Signal Types

| Signal | What it means | How to act |
| --- | --- | --- |
| 🟢 **BUY triangle** | K crosses above D inside the OS zone | Entry candidate — confirm with trend tint |
| 🔴 **SELL triangle** | K crosses below D inside the OB zone | Exit/short candidate |
| 💎 **S-BUY / S-SELL** | Cross + divergence within 10 bars | Highest conviction — size up |

> **Rule of thumb:** Plain triangles = watch. 💎 labels = act.

* * *

## 5-Minute Setup

### Step 1 — Load the indicator

Add `🔵 DELTA Stochastic` to any chart. It auto-detects everything.

### Step 2 — Check the info table (top-right of pane)

| Table field | What to look for |
| --- | --- |
| **Preset** | 🎯 = auto-detected · ✋ = manual override needed |
| **Lead** | Which stochastic is active (Fast StochRSI / Standard Stoch / Slow StochRSI) |
| **K value** | Live K reading + zone status (OVERBOUGHT / OVERSOLD / Bullish / Bearish) |
| **Signal** | Last signal fired this session |
| **Today** | Count of buys and sells fired today |

### Step 3 — Confirm the preset is right

* On SOXL/TQQQ → should show **X-ETF 🎯**
* On AAPL/AMZN → should show **STK 🎯**
* On AG/SLV/NUGT → should show **Met 🎯**
* On BTC/ETH → should show **CPT 🎯**
* On SPY/QQQ → should show **ETF 🎯**

If wrong: Settings → **Instrument** → pick the right one manually.

### Step 4 — Confirm Auto-Apply is ON

Settings → **🎯 Auto-Apply Preset** → ON ✅

This is the master switch. OFF = fully manual, you're on your own for all 6 parameters.

* * *

## The K Line Colors

Default mode is **Momentum** (SMTF-style):

| Color | Meaning |
| --- | --- |
| 🟢 **Green** | K > D and rising — bullish momentum flowing |
| 🔴 **Red** | K < D and falling — bearish momentum flowing |
| 🟡 **Yellow** | Flat or transitioning — stand aside |

Alternative modes (Settings → **K Line Color Mode**):

* **Zone** — green in OS, red in OB (pure mean-reversion view)
* **Flat Cyan** — monochrome, no dynamic color

* * *

## Trend Filter (Default ON for all non-crypto)

The trend filter blocks counter-trend signals:

* **BUY signals only fire when price is ABOVE the trend EMA**
* **SELL signals only fire when price is BELOW the trend EMA**

This is the #1 protection against catching falling knives. Leave it ON unless you're testing raw stochastic crosses.

> ⚠️ **CPT (crypto) only:** Trend filter defaults OFF. Silvia P8 showed it doesn't help on BTC.

* * *

## Auto-Routing Logic

| Chart timeframe | Lead stochastic selected | Why |
| --- | --- | --- |
| ≤ 5m | Fast StochRSI (3,3,14,14) | Speed for scalps |
| 15m – 2H | Standard Stoch (14,3,3) | Balanced noise/speed |
| 4H+ / Daily | Slow StochRSI (5,5,21,21) | Structure, fewer false signals |

Override: Settings → **Timeframe Tier** or **Lead Stochastic** → select manually.

* * *

## Per-Asset Preset Defaults

| Preset | OB/OS | Cooldown | Trend Filter | EMA | Notes |
| --- | --- | --- | --- | --- | --- |
| **X-ETF** | 80/20 | 6 bars | ✅ ON (20-EMA) | 20  | Fast-trending leveraged |
| **CPT** | 78/22 | 8 bars | ❌ OFF | 50  | Crypto — Silvia P8 |
| **STK** | 75/25 | 4 bars | ✅ ON (50-EMA) | 50  | Standard stocks |
| **ETF** | 75/25 | 5 bars | ✅ ON (50-EMA) | 50  | Non-leveraged funds |
| **Met** | 73/27 | 5 bars | ✅ ON (50-EMA) | 50  | Miners / metals (wider zones) |

> All presets are Silvia-validation pending (Project 14e). Treat as smart defaults, not gospel.

* * *

## The Divergence Engine

Ported from tista's "Stochastic RSI Divergences" (MPL 2.0). Runs on a smoothed version of the lead K line.

| Divergence type | What it signals |
| --- | --- |
| **Bull (regular)** | Price making lower lows, K making higher lows → reversal up |
| **Bear (regular)** | Price making higher highs, K making lower highs → reversal down |
| **Bull (hidden)** | Price higher low, K lower low → uptrend continuation |
| **Bear (hidden)** | Price lower high, K higher high → downtrend continuation |

**Key setting:** Pivot Lookback Right (default 5) = signals fire 5 bars late, but are **repaint-free**.

Enable divergence lines: Settings → **Show Divergence Lines** → ON (off by default to keep pane clean).

* * *

## RSI Overlay Line

Optional dashed RSI(14) line on the same 0-100 scale. Mirrors the K line color mode.

**Why it's useful:** When K and RSI agree (both green rising / both red falling) = momentum confluence. When they disagree = one is transitioning ahead of the other = potential turn warning.

* * *

## Alerts Setup

Six alert conditions available:

| Alert name | When it fires |
| --- | --- |
| `BUY Signal` | Any BUY (plain or strong) |
| `SELL Signal` | Any SELL (plain or strong) |
| `STRONG BUY (cross + divergence)` | 💎 S-BUY only |
| `STRONG SELL (cross + divergence)` | 💎 S-SELL only |
| `Bullish Divergence` | Any bull divergence confirmed |
| `Bearish Divergence` | Any bear divergence confirmed |

**Alert cooldown is automatic** — baked into the same signal cooldown logic. No duplicate alerts in choppy zones.

* * *

## Go Desk Integration Hook

Settings → **🔵 DELTA Stoch Active (Go Desk hook)** → ON

Turn this on when DELTA Stochastic is on your chart. A future Go Desk version will read this flag to incorporate stochastic confluence into its overall signal score.

No functional effect in the current Go Desk version — it's a reserved wire.

* * *

## Quick Troubleshooting

| Problem | Fix |
| --- | --- |
| No signals firing | Check trend filter isn't blocking everything. Try Settings → Trend Filter → OFF temporarily to test. |
| Too many signals | Increase signal cooldown (default 6). Try 8–10 for noisy assets. |
| Wrong preset auto-detected | Settings → Instrument → manually select correct preset. |
| Signals firing mid-zone | Check Zone Tolerance isn't set too high (default 0). |
| K line is all yellow | Usually means the asset is in consolidation. This is correct behavior. |
| Divergence labels showing too early | Increase Pivot Lookback Right (increases confirmation delay). |

* * *

*For strategy context, backtest results, and validation status see DELTA_MASTER.md**Author: PJ_FatCat (DELTA Trading) — //@PJ_FatCat

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Divergence engine adapted from "Stochastic RSI Divergences" by © tista (MPL 2.0)
//
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  DELTA Stochastic                                                          ║
// ║  Part of the DELTA Trading Suite                                           ║
// ╠══════════════════════════════════════════════════════════════════════════════╣
// ║  Author:    PJ_FatCat (DELTA Trading) — //@PJ_FatCat                      ║
// ║  Version:   2.30                                                            ║
// ║  Pine:      v6                                                             ║
// ╠══════════════════════════════════════════════════════════════════════════════╣
// ║  v2.30 Changes:                                                            ║
// ║  • Table gaps eliminated: border_width=0, frame_width=2                  ║
// ║    Cell borders were creating visible gaps between rows — removed.        ║
// ║  • Quick Start label: switched to var label + delete/recreate pattern     ║
// ║    Prevents label accumulation on live chart repaints.                   ║
// ╚══════════════════════════════════════════════════════════════════════════════╝

//@version=6
indicator(title="🔵 DELTA Stochastic", shorttitle="🔵 DELTA Stochastic", format=format.price, precision=2, overlay=false, max_lines_count=500)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 1 — GROUPS
// ═══════════════════════════════════════════════════════════════════════════════
var string g_setup   = "━━━  SETUP  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
var string g_sig     = "━━━  SIGNALS  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
var string g_div     = "━━━  DIVERGENCE ENGINE  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
var string g_disp    = "━━━  DISPLAY  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 2 — SETUP INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string inst_badge = input.string("Auto", "Instrument",
     options=["Auto", "STK", "ETF", "X-ETF", "Met", "CPT"],
     group=g_setup,
     tooltip="WHAT: Asset preset selector.\n\nAuto = reads the ticker and routes to the correct stochastic variant and OB/OS thresholds automatically.\n\nUSE: Leave on Auto. Override only if the auto-detect misidentifies the asset.\n\nTIP: 🎯 in the table = auto-detected. ✋ = manually set.")

bool route_apply = input.bool(true, "🎯 Auto-Apply Preset",
     group=g_setup,
     tooltip="WHAT: Master routing switch.\n\nUSE: ON recommended. Selects the right stochastic speed and OB/OS levels for the detected asset + timeframe.\n\nTIP: OFF = full manual control via the override inputs below.")

string tf_override = input.string("Auto", "Timeframe Tier",
     options=["Auto", "Fast (3m)", "Medium (1H)", "Slow (1D)"],
     group=g_setup,
     tooltip="WHAT: Which speed tier of stochastic settings to use.\n\nAuto = detects from chart TF: ≤5m→Fast · 15m-2H→Medium · 4H+→Slow.\n\nUSE: Leave on Auto. Override for e.g. swing analysis on a fast chart.\n\nTIP: Active tier always shown in the table.")

string lead_override = input.string("Auto", "Lead Stochastic",
     options=["Auto", "Fast StochRSI", "Standard Stoch", "Slow StochRSI"],
     group=g_setup,
     tooltip="WHAT: Which stochastic variant is THE lead line on this chart.\n\nAuto routing:\n• Fast tier (3m) → Fast StochRSI (3,3,14,14) — speed for scalps\n• Medium tier (1H) → Standard Stoch (14,3,3) — balanced noise/speed\n• Slow tier (1D) → Slow StochRSI (5,5,21,21) — structure over noise\n\nUSE: Leave on Auto. Override if you prefer a specific variant.\n\nTIP: One lead line = one clear signal. This replaces the old 3-line composite.")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 3 — ASSET + TF ROUTING
// ═══════════════════════════════════════════════════════════════════════════════

// --- Ticker lists (self-contained copy — keep in sync with Go Desk manually) ---
var _xetf_list = array.from(
    "TQQQ", "SQQQ", "SOXL", "SOXS", "LABU", "LABD", "FAS", "FAZ", "DPST", "DRN", "DRV",
    "YINN", "YANG", "TNA", "TZA", "SPXL", "SPXU", "TMF", "TMV", "GDXU", "GDXD",
    "GUSH", "DRIP", "ERX", "ERY", "UCO", "SCO", "BOIL", "KOLD", "NUGT", "DUST", "JNUG", "JDST",
    "AGQ", "ZSL", "BITX", "ETHU", "CONL", "MAGX", "QLD", "ROM", "TBT", "UVXY", "UVIX", "SVIX",
    "UPRO", "SPXS", "UDOW", "SDOW", "UMDD", "SMDD", "URTY", "SRTY",
    "FNGU", "FNGD", "TECL", "TECS", "CURE", "PILL", "DFEN", "WEBS",
    "NAIL", "RETL", "MIDU", "BERZ", "HIBL", "HIBS")

var _miner_list = array.from(
    "AG", "AYA", "SLVP", "GDXJ", "MAKO", "SILJ", "SGDJ", "CGLCF", "PPTA", "RVLGF", "ITRG", "NXGCF",
    "SSRM", "AAGFF", "AUMBF", "GGPSF", "SLVR", "SKE", "REDLF", "PGLDF", "WGXRF", "NFGC", "HSLV", "EQX",
    "STLRF", "HYMC", "WRLGF", "PAAS", "LIT", "WPM", "UUUU", "EXK", "FNV", "CDE", "BTG", "NEM",
    "B", "GMTLF", "TECK", "REMX", "AA", "AEM", "ION", "PZG", "MUX", "ALB", "ASM", "TUNG",
    "MP", "CCJ", "GPHOF", "FCX", "HL", "SVM", "GDX", "GDXU", "SCCO", "COPX", "PICK", "XME",
    "URA", "URNM", "NLR", "SIL", "USAR", "ALM", "SRHYY", "NMG", "KALU", "CENX", "HWM", "MTUS",
    "OKLO", "SMR", "NNE", "LEU", "X", "NUE", "STLD", "CLF", "MT", "SLX", "NUKZ",
    "SYAAF", "GDXD", "NUGT", "DUST", "JNUG", "JDST", "AGQ", "ZSL", "SLX")

_is_xetf  = array.indexof(_xetf_list,  syminfo.ticker) >= 0
_is_miner = array.indexof(_miner_list, syminfo.ticker) >= 0

_route_auto  = syminfo.type == "crypto" ? "CPT" : _is_xetf ? "X-ETF" : _is_miner ? "Met" : syminfo.type == "fund" ? "ETF" : "STK"
asset_preset = inst_badge == "Auto" ? _route_auto : inst_badge
is_auto_preset = inst_badge == "Auto"

// --- TF tier detection ---
_tf_mins = timeframe.in_seconds() / 60
_tf_auto = _tf_mins <= 5 ? "fast" : _tf_mins <= 120 ? "medium" : "slow"
tf_tier  = tf_override == "Auto" ? _tf_auto : tf_override == "Fast (3m)" ? "fast" : tf_override == "Medium (1H)" ? "medium" : "slow"

// --- Lead routing: which stochastic variant runs on this chart ---
// Auto: fast tier → Fast StochRSI · medium tier → Standard Stoch · slow tier → Slow StochRSI
_lead_auto = tf_tier == "fast" ? "Fast StochRSI" : tf_tier == "medium" ? "Standard Stoch" : "Slow StochRSI"
lead_mode  = lead_override == "Auto" ? _lead_auto : lead_override

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 4 — PRESET PARAMETERS
// ═══════════════════════════════════════════════════════════════════════════════

// OB/OS thresholds per asset preset
_ob = asset_preset == "X-ETF" ? 80 : asset_preset == "CPT" ? 78 : asset_preset == "Met" ? 73 : 75
_os = asset_preset == "X-ETF" ? 20 : asset_preset == "CPT" ? 22 : asset_preset == "Met" ? 27 : 25

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 5 — LEAD STOCHASTIC CALCULATION (one variant, routed)
// ═══════════════════════════════════════════════════════════════════════════════

// Fast StochRSI — 3,3,14,14 (scalping speed)
_rsi_f    = ta.rsi(close, 14)
_fk_raw   = ta.sma(ta.stoch(_rsi_f, _rsi_f, _rsi_f, 14), 3)
fast_k    = _fk_raw
fast_d    = ta.sma(_fk_raw, 3)

// Standard Stoch — 14,3,3 (balanced)
_sk_raw   = ta.sma(ta.stoch(close, high, low, 14), 3)
std_k     = _sk_raw
std_d     = ta.sma(_sk_raw, 3)

// Slow StochRSI — 5,5,21,21 (structural)
_rsi_s    = ta.rsi(close, 21)
_slk_raw  = ta.sma(ta.stoch(_rsi_s, _rsi_s, _rsi_s, 21), 5)
slow_k    = _slk_raw
slow_d    = ta.sma(_slk_raw, 5)

// Route to the lead
lead_k = lead_mode == "Fast StochRSI" ? fast_k : lead_mode == "Standard Stoch" ? std_k : slow_k
lead_d = lead_mode == "Fast StochRSI" ? fast_d : lead_mode == "Standard Stoch" ? std_d : slow_d

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 6 — SIGNAL ENGINE
// ═══════════════════════════════════════════════════════════════════════════════
bool show_signals = input.bool(true, "Show Buy/Sell Triangles", group=g_sig,
     tooltip="WHAT: The core graphical signals.\n\n🟢 Triangle up = K crossed above D while inside the OS zone → BUY signal\n🔴 Triangle down = K crossed below D while inside the OB zone → SELL signal\n\nUSE: ON. These are the primary act-on signals of the indicator.\n\nTIP: Crosses OUTSIDE the OB/OS zones are ignored on purpose — mid-range crosses are noise.")

int zone_tolerance_in = input.int(0, "Zone Tolerance (± points)", group=g_sig, minval=0, maxval=10,
     tooltip="WHAT: How many points OUTSIDE the strict OB/OS zone still counts as a valid cross.\n\nAuto-Apply presets:\n• X-ETF: 0 · CPT: 3 · STK: 0 · ETF: 0 · Met: 2\n\nUSE: Default 0. Only used when Auto-Apply is OFF. Increase to 3-5 if you're missing signals in fast-moving assets that barely dip into the zone.\n\nTIP: Higher tolerance = more signals but more false positives.")

int signal_cooldown_in = input.int(6, "Signal Cooldown (bars)", group=g_sig, minval=0, maxval=50,
     tooltip="WHAT: Minimum bars between consecutive BUY signals (or consecutive SELL signals). Prevents signal spam in choppy zones.\n\nAuto-Apply presets:\n• X-ETF: 6 · CPT: 8 · STK: 4 · ETF: 5 · Met: 5\n\nUSE: Default 6. Only used when Auto-Apply is OFF. Set to 0 to disable cooldown entirely. Higher = fewer but cleaner signals. Applies to both chart signals AND webhook alerts.")

bool use_trend_filter_in = input.bool(true, "🎯 Trend Filter", group=g_sig,
     tooltip="WHAT: Rejects BUY signals when price is below the EMA (downtrend), and rejects SELL signals when price is above the EMA (uptrend).\n\nAuto-Apply presets (v2.7):\n• X-ETF: ON  (fast 20-EMA — leveraged movers trend hard)\n• STK:   ON  (50-EMA — validated on AMZN 1H test)\n• ETF:   ON  (50-EMA)\n• Met:   ON  (50-EMA — miners trend when they move)\n• CPT:   OFF (P8: BTC entry-limited, filter no help)\n\nUSE: Only affects behavior when Auto-Apply is OFF.\n\nTIP: ON = only take signals ALIGNED with the higher-timeframe trend. This is the #1 fix for catching-falling-knives failure mode of stochastic mean-reversion.")

int trend_ema_len_in = input.int(50, "Trend Filter EMA Length", group=g_sig, minval=10, maxval=200,
     tooltip="EMA length for the trend filter.\n\nAuto-Apply presets:\n• X-ETF: 20 (fast trend read for leveraged movers)\n• CPT:   50\n• STK:   50 (standard swing trend)\n• ETF:   50\n• Met:   50\n\nUSE: Only used when Auto-Apply is OFF.")

bool show_strong = input.bool(true, "Show Strong Signals 💎", group=g_sig,
     tooltip="WHAT: S-BUY / S-SELL labels when a buy/sell cross fires within 10 bars of a confirmed divergence in the same direction.\n\nUSE: ON. Cross + divergence agreement is the highest-conviction setup this indicator produces.\n\nTIP: Strong signals are rarer but meaningfully more reliable than plain crosses.")

int strong_window_in = input.int(10, "Strong Signal Window (bars)", group=g_sig, minval=1, maxval=50,
     tooltip="WHAT: Maximum bars between a divergence and a cross for them to combine into a Strong signal.\n\nAuto-Apply presets:\n• X-ETF: 10 · CPT: 20 · STK: 15 · ETF: 12 · Met: 15\n\nUSE: Default 10. Only used when Auto-Apply is OFF. Wider = more strong signals but weaker linkage.")

bool show_trend_tint = input.bool(true, "Trend Tint Background", group=g_sig,
     tooltip="WHAT: Faint background color showing momentum regime — green when K is above D and above 50, red when K is below D and below 50, neutral otherwise.\n\nUSE: ON. This is the 'trend forming' visual — the background shifts as momentum builds, before signals fire.\n\nTIP: Tint + rising K = trend building. Signal against the tint = counter-trend, size down.")

// --- Per-preset signal config baselines (v2.3 → resolved after _in inputs) ---
// Silvia Project 14e will validate these baselines with backtests.
// route_apply=ON → preset baseline used · route_apply=OFF → user _in values used
_p_trend    = asset_preset != "CPT"                                            // trend filter ON for STK/ETF/X-ETF/Met · OFF only for CPT (P8 BTC entry-limited)
_p_cooldown = asset_preset == "X-ETF" ? 6 : asset_preset == "CPT" ? 8 : asset_preset == "STK" ? 4 : asset_preset == "Met" ? 5 : 5
_p_ztol     = asset_preset == "CPT"   ? 3 : asset_preset == "Met" ? 2 : 0
_p_emalen   = asset_preset == "X-ETF" ? 20 : 50
_p_strongw  = asset_preset == "X-ETF" ? 10 : asset_preset == "CPT" ? 20 : asset_preset == "STK" ? 15 : asset_preset == "ETF" ? 12 : 15

// Resolve final values — preset when Auto-Apply ON, user input when OFF
use_trend_filter = route_apply ? _p_trend    : use_trend_filter_in
signal_cooldown  = route_apply ? _p_cooldown : signal_cooldown_in
zone_tolerance   = route_apply ? _p_ztol     : zone_tolerance_in
trend_ema_len    = route_apply ? _p_emalen   : trend_ema_len_in
strong_window    = route_apply ? _p_strongw  : strong_window_in

// --- Cross detection (only inside zones + optional trend filter) ---
cross_up   = ta.crossover(lead_k,  lead_d)
cross_dn   = ta.crossunder(lead_k, lead_d)
// ta.ema() needs simple int — pre-compute the two used EMAs, select per bar.
// Custom user EMA length only applies when Auto-Apply is OFF; falls back to 50.
_ema_20     = ta.ema(close, 20)
_ema_50     = ta.ema(close, 50)
_ema_user   = ta.ema(close, 50)  // user override slot — reserved, defaults to 50
_trend_ema  = route_apply ? (asset_preset == "X-ETF" ? _ema_20 : _ema_50) : _ema_user
_trend_ok_bull = use_trend_filter ? close > _trend_ema : true
_trend_ok_bear = use_trend_filter ? close < _trend_ema : true

// Raw signals (before cooldown)
buy_raw    = show_signals and cross_up and lead_k <= _os + zone_tolerance and _trend_ok_bull
sell_raw   = show_signals and cross_dn and lead_k >= _ob - zone_tolerance and _trend_ok_bear

// Cooldown gate — suppress if a same-direction signal fired within cooldown window
bars_since_buy  = ta.barssince(buy_raw[1])
bars_since_sell = ta.barssince(sell_raw[1])
buy_sig    = buy_raw  and (signal_cooldown == 0 or na(bars_since_buy)  or bars_since_buy  > signal_cooldown)
sell_sig   = sell_raw and (signal_cooldown == 0 or na(bars_since_sell) or bars_since_sell > signal_cooldown)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 7 — DIVERGENCE ENGINE (ported from © tista, MPL 2.0)
// ═══════════════════════════════════════════════════════════════════════════════
bool show_div = input.bool(true, "Enable Divergence Engine", group=g_div,
     tooltip="WHAT: Pivot-based divergence detection on the lead K line.\n\nUSE: ON recommended. Divergence marks momentum failure at extremes — the earliest reliable reversal warning.\n\nTIP: Signals confirm 5 bars after the pivot (repaint-safe).")

bool plot_bull     = input.bool(true,  "Regular Bullish",  group=g_div, inline="rb",
     tooltip="Price lower low + oscillator higher low = reversal up warning.")
bool plot_bear     = input.bool(true,  "Regular Bearish",  group=g_div, inline="rb")
bool plot_hid_bull = input.bool(true,  "Hidden Bullish",   group=g_div, inline="hb",
     tooltip="Price higher low + oscillator lower low = uptrend continuation signal.")
bool plot_hid_bear = input.bool(true,  "Hidden Bearish",   group=g_div, inline="hb")

int  lbL        = input.int(5,   "Pivot Lookback Left",  group=g_div, minval=1)
int  lbR        = input.int(5,   "Pivot Lookback Right", group=g_div, minval=1,
     tooltip="Bars to the right before a pivot confirms. 5 = signal fires 5 bars late but never repaints.")
int  rangeUpper = input.int(100, "Max Lookback Range",   group=g_div, minval=1)
int  rangeLower = input.int(10,  "Min Lookback Range",   group=g_div, minval=1)

bool show_div_lines = input.bool(false, "Show Divergence Lines", group=g_div,
     tooltip="WHAT: Draws the pivot-connecting line spanning the divergence window.\n\nUSE: OFF by default — labels alone mark the signal. Enable to visualize the full span.")

// Divergence osc = lead K with extra smoothing for stable pivots
int div_d_period = input.int(5, "Divergence Smoothing", group=g_div, minval=1,
     tooltip="Extra smoothing on the lead K before pivot detection. Default 5 = stable pivots, fewer false divergences.")
div_osc = ta.sma(lead_k, div_d_period)
osc = div_osc

plFound = not na(ta.pivotlow(osc,  lbL, lbR))
phFound = not na(ta.pivothigh(osc, lbL, lbR))

_inRange(cond) =>
    bars = ta.barssince(cond)
    rangeLower <= bars and bars <= rangeUpper

// Regular Bullish — price LL, osc HL
oscHL_rb   = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceLL_rb = low[lbR]  < ta.valuewhen(plFound, low[lbR],  1)
bullCond   = show_div and plot_bull and priceLL_rb and oscHL_rb and plFound

// Regular Bearish — price HH, osc LH
oscLH_rbe  = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceHH_rb = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCond   = show_div and plot_bear and priceHH_rb and oscLH_rbe and phFound

// Hidden Bullish — price HL, osc LL
oscLL_hb   = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and _inRange(plFound[1])
priceHL_hb = low[lbR]  > ta.valuewhen(plFound, low[lbR],  1)
hidBullCond = show_div and plot_hid_bull and priceHL_hb and oscLL_hb and plFound

// Hidden Bearish — price LH, osc HH
oscHH_hbe  = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and _inRange(phFound[1])
priceLH_hb = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hidBearCond = show_div and plot_hid_bear and priceLH_hb and oscHH_hbe and phFound

anyBullDiv = bullCond or hidBullCond
anyBearDiv = bearCond or hidBearCond

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 8 — STRONG SIGNALS (cross + recent divergence agreement)
// ═══════════════════════════════════════════════════════════════════════════════
bars_since_bull_div = ta.barssince(anyBullDiv)
bars_since_bear_div = ta.barssince(anyBearDiv)

strong_buy  = show_strong and buy_sig  and bars_since_bull_div <= strong_window
strong_sell = show_strong and sell_sig and bars_since_bear_div <= strong_window

// Regular signals suppress when strong version fires (no double-marking)
plain_buy  = buy_sig  and not strong_buy
plain_sell = sell_sig and not strong_sell

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 9 — DISPLAY INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
string k_color_mode = input.string("Momentum", "K Line Color Mode",
     options=["Momentum", "Zone", "Flat Cyan"],
     group=g_disp,
     tooltip="WHAT: How the K line colors itself.\n\n📈 Momentum (default) — matches SMTF-style trend coloring:\n   🟢 Green = K > D and rising (bullish flow)\n   🔴 Red   = K < D and falling (bearish flow)\n   🟡 Yellow= flat/transitioning\n\n📊 Zone — colors by OB/OS position (mean-reversion view):\n   🟢 Green = in OS zone\n   🔴 Red   = in OB zone\n   🟡 Yellow= middle band\n\n⚪ Flat Cyan — monochrome, no dynamic coloring\n\nUSE: Momentum is default because it aligns with actual price flow — red line = something is falling, green = something is rising. This intuition matches most traders.\n\nTIP: Zone mode is useful if you\'re a pure mean-reversion trader (buy the OS, sell the OB regardless of trend).")

bool godesk_active = input.bool(false, "🔵 DELTA Stoch Active (Go Desk hook)", group=g_disp,
     tooltip="WHAT: Reserved flag for future Go Desk integration.\n\nWhen ON, this signals that DELTA Stochastic is active on the chart. A future Go Desk version will read this flag to incorporate stoch signals into its confluence score, similar to how me2 integration works today.\n\nUSE: OFF by default — no functional effect until Go Desk hook is implemented.\n\nTIP: Turn ON when you want Go Desk to eventually acknowledge this indicator's signals.")

bool show_rsi   = input.bool(true, "Show RSI Line", group=g_disp,
     tooltip="WHAT: Raw RSI(14) plotted on the same 0-100 scale as a dashed line, colored to match your K Line Color Mode.\n\nUSE: ON by default. RSI acts as a slower structural confirmation of the K line.\n\nTIP: When K and RSI colors agree (both green rising, both red falling), momentum has confluence across timeframes = higher confidence. When they disagree, one is transitioning ahead of the other = potential turn.")
bool show_table = input.bool(true, "Show Info Table", group=g_disp,
     tooltip="Shows active preset, TF tier, lead variant, and last signal.")
string tbl_size = input.string("small", "Table Text Size", group=g_disp,
     options=["tiny", "small", "normal"])
string tbl_pos  = input.string("Bottom Left", "Table Position", group=g_disp,
     options=["Top Left", "Top Center", "Top Right",
              "Middle Left", "Middle Center", "Middle Right",
              "Bottom Left", "Bottom Center", "Bottom Right"],
     tooltip="WHAT: Where the info table is anchored on the chart.\n\nUSE: Default is Top Right. Move if it overlaps your price labels or other indicators.")
float smtf_k_src = input.source(close, "SMTF Stoch K (source)", group=g_disp,
     tooltip="WHAT: Wire in the Smart Multi-TF Stochastic K line (by kompas2024) for composite scoring.\n\nUSE: Click the dropdown and select 'SMTF Stoch: SMART STOCH' — that is the K line. The other options (in Russian) are signal plots, not the K line:\n  ВХОД ЛОНГ = Entry Long\n  ВЫХОД/РАЗВОРОТ = Exit/Reversal\n  ВХОД В ЛОНГ = Rocket Long Entry\n  ВЫХОД! = Exit Alert\n\nONE-TIME SETUP: TradingView remembers your selection — you only need to pick this once per chart. It will not reset unless you add the indicator fresh to a new chart.\n\nTIP: SMTF K adds up to ±3 pts: direction (±1) + vs midline 50 (±1) + OB/OS zone (±1).")
bool smtf_wired = input.bool(false, "✅ SMTF Wired (enable SMTF scoring)", group=g_disp,
     tooltip="WHAT: Tells the score engine that SMTF Stoch K is properly wired above.\n\nUSE: Turn ON only after you have selected the SMTF K source above. Default OFF = SMTF contributes 0 pts to the score, no breakage.\n\nWHY: Auto-detection of the source was unreliable — this explicit toggle is the clean fix.")
bool show_quickstart = input.bool(true, "📋 Show Quick Start Guide", group=g_disp,
     tooltip="WHAT: Displays a setup checklist on the chart for new users.\n\nUSE: Turn OFF once you have completed the two-indicator setup. The guide explains how to install and wire SMTF Stochastic alongside DELTA Stochastic.\n\nTIP: You only need to do this setup once per chart — TradingView remembers the source selection.")

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10 — PLOTS
// ═══════════════════════════════════════════════════════════════════════════════

// OB/OS bands (plot-based — hline can't take series)
// OB/OS reference lines — hidden by default (100% transparent) — zone fills carry the visual
// User can re-enable via Style panel: OB Level / OS Level → adjust color opacity
_band_color = color.new(#787B86, 100)
p_ob = plot(_ob, title="OB Level", color=_band_color, linewidth=1)
p_50 = plot(50,  title="Midline",  color=color.new(#787B86, 85), linewidth=1)
p_os = plot(_os, title="OS Level", color=_band_color, linewidth=1)
// Zone fills at 88% alpha (=12% visible opacity per user spec)
fill(p_ob, p_50, color=color.new(#FF5252, 88), title="OB Zone Fill")
fill(p_50, p_os, color=color.new(#00C853, 88), title="OS Zone Fill")

// Trend tint background
_tint = show_trend_tint ?
     (lead_k > lead_d and lead_k > 50 ? color.new(#00C853, 85) :
      lead_k < lead_d and lead_k < 50 ? color.new(#FF5252, 85) : na) : na
bgcolor(_tint, title="Trend Tint")

// Lead K/D lines — THE two lines
// K line color — three modes:
// Momentum (default) = matches SMTF flow: rising above D → green, falling below D → red
// Zone               = mean-reversion: OB zone → red, OS zone → green
// Flat Cyan          = monochrome
// v2.12: flat band added — K change within ±1pt = neutral/yellow
_k_delta = lead_k - lead_k[1]
_k_rising  = lead_k > lead_d and _k_delta >  1.0
_k_falling = lead_k < lead_d and _k_delta < -1.0

_color_momentum = _k_rising  ? color.new(#00C853, 0) :
                  _k_falling ? color.new(#FF5252, 0) :
                               color.new(#FFD600, 0)

_color_zone = lead_k >= _ob ? color.new(#FF5252, 0) :
              lead_k <= _os ? color.new(#00C853, 0) :
                              color.new(#FFD600, 0)

// OB/OS zone override applied AFTER mode selection — always red at OB, green at OS
_k_color_base = k_color_mode == "Momentum" ? _color_momentum : k_color_mode == "Zone" ? _color_zone : color.new(#00BCD4, 0)
_k_color = lead_k >= _ob ? color.new(#FF5252, 0) : lead_k <= _os ? color.new(#00C853, 0) : _k_color_base

// K line — line.new() per-bar segment for true dynamic thickness (v2.14)
// width=3 when directional (rising or falling), width=1 when flat/yellow
// _k_color already computed above — reused directly
_k_width = (_k_rising or _k_falling) ? 3 : 1
if not na(lead_k[1])
    line.new(bar_index[1], lead_k[1], bar_index, lead_k,
         color=_k_color, width=_k_width, style=line.style_solid)

// D line — muted gray, thin, structural reference
plot(lead_d, title="D (lead)", color=color.new(#787B86, 20), linewidth=1)

// RSI (optional, faded)
// RSI line — mirrors K line color mode, dashed, thin, full opacity
_rsi_val = ta.rsi(close, 14)
// v2.12: flat band for RSI too — change within ±0.5pt = neutral/yellow
_rsi_delta   = _rsi_val - _rsi_val[1]
_rsi_rising  = _rsi_delta >  0.5
_rsi_falling = _rsi_delta < -0.5

_rsi_color_momentum = _rsi_rising  ? color.new(#00C853, 0) : _rsi_falling ? color.new(#FF5252, 0) : color.new(#FFD600, 0)
_rsi_color_zone     = _rsi_val >= 70 ? color.new(#FF5252, 0) : _rsi_val <= 30 ? color.new(#00C853, 0) : color.new(#FFD600, 0)
_rsi_color = k_color_mode == "Momentum" ? _rsi_color_momentum : k_color_mode == "Zone" ? _rsi_color_zone : color.new(#00BCD4, 0)

// RSI line — single plot, dynamic color, linewidth 1, circles for dashed effect
plot(show_rsi ? _rsi_val : na, title="RSI", color=_rsi_color, linewidth=2, style=plot.style_line)

// ── Buy/Sell triangles ──
plotshape(plain_buy  ? lead_k : na, title="BUY",  style=shape.triangleup,
     location=location.bottom, color=color.new(#00C853, 0), size=size.small)
plotshape(plain_sell ? lead_k : na, title="SELL", style=shape.triangledown,
     location=location.top, color=color.new(#FF5252, 0), size=size.small)

// ── Strong signals ──
plotshape(strong_buy  ? lead_k : na, title="S-BUY",  text="S-BUY",  style=shape.labelup,
     location=location.bottom, color=#1B6B2E, textcolor=color.white, size=size.small)
plotshape(strong_sell ? lead_k : na, title="S-SELL", text="S-SELL", style=shape.labeldown,
     location=location.top, color=#8B1A1A, textcolor=color.white, size=size.small)

// ── Divergence lines (default hidden) ──
noneColor = color.new(color.white, 100)
_bull_line_color = show_div_lines ? color.new(#1B6B2E, 0) : noneColor
_bear_line_color = show_div_lines ? color.new(#8B1A1A, 0) : noneColor
plot(plFound ? osc[lbR] : na, offset=-lbR, title="Bull Div Line",
     linewidth=2, color=bullCond or hidBullCond ? _bull_line_color : noneColor)
plot(phFound ? osc[lbR] : na, offset=-lbR, title="Bear Div Line",
     linewidth=2, color=bearCond or hidBearCond ? _bear_line_color : noneColor)

// ── Divergence labels ──
plotshape(bullCond    ? osc[lbR] : na, offset=-lbR, title="Reg Bull Label",
     text="Bull",   style=shape.labelup,   location=location.absolute,
     color=#1B6B2E, textcolor=color.white, size=size.tiny)
plotshape(bearCond    ? osc[lbR] : na, offset=-lbR, title="Reg Bear Label",
     text="Bear",   style=shape.labeldown, location=location.absolute,
     color=#8B1A1A, textcolor=color.white, size=size.tiny)
plotshape(hidBullCond ? osc[lbR] : na, offset=-lbR, title="Hid Bull Label",
     text="H Bull", style=shape.labelup,   location=location.absolute,
     color=#1B6B2E, textcolor=color.white, size=size.tiny)
plotshape(hidBearCond ? osc[lbR] : na, offset=-lbR, title="Hid Bear Label",
     text="H Bear", style=shape.labeldown, location=location.absolute,
     color=#8B1A1A, textcolor=color.white, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10.6 — COMPOSITE SCORE ENGINE (±15 max)
// ═══════════════════════════════════════════════════════════════════════════════
// Weights: K/RSI/zone/tint = 1pt · BUY/Div = 2pt · S-BUY = 3pt · SMTF = up to ±3
// SMTF scored only if smtf_k_src is wired (not close) — detection via na-safe check
_smtf_wired = smtf_wired  // explicit toggle — replaces broken auto-detect
// Detect mismatch: source appears wired (not close) but toggle is OFF → warn in table
_smtf_src_is_close = na(smtf_k_src) or (smtf_k_src >= close * 0.999 and smtf_k_src <= close * 1.001)
_smtf_warn = not smtf_wired and not _smtf_src_is_close
_smtf_rising  = _smtf_wired and smtf_k_src > smtf_k_src[1]
_smtf_falling = _smtf_wired and smtf_k_src < smtf_k_src[1]
_smtf_above50 = _smtf_wired and smtf_k_src > 50
_smtf_below50 = _smtf_wired and smtf_k_src < 50
_smtf_os      = _smtf_wired and smtf_k_src < 30
_smtf_ob      = _smtf_wired and smtf_k_src > 70

// --- Bull score components ---
_sc_b_kdir   = lead_k > lead_d          ? 1 : 0   // K above D
_sc_b_krising = _k_rising               ? 1 : 0   // K fat-rising
_sc_b_kos    = lead_k <= _os            ? 1 : 0   // K in OS zone
_sc_b_tint   = (lead_k > lead_d and lead_k > 50) ? 1 : 0  // tint green
_sc_b_rsi    = _rsi_rising              ? 1 : 0   // RSI rising
_sc_b_buy    = (plain_buy or strong_buy) ? (strong_buy ? 3 : 2) : 0
_sc_b_div    = anyBullDiv               ? 2 : 0   // bull divergence
_sc_b_smtf   = (_smtf_rising ? 1 : 0) + (_smtf_above50 ? 1 : 0) + (_smtf_os ? 1 : 0)

// --- Bear score components ---
_sc_r_kdir   = lead_k < lead_d          ? 1 : 0
_sc_r_kfall  = _k_falling               ? 1 : 0
_sc_r_kob    = lead_k >= _ob            ? 1 : 0
_sc_r_tint   = (lead_k < lead_d and lead_k < 50) ? 1 : 0
_sc_r_rsi    = _rsi_falling             ? 1 : 0
_sc_r_sell   = (plain_sell or strong_sell) ? (strong_sell ? 3 : 2) : 0
_sc_r_div    = anyBearDiv               ? 2 : 0
_sc_r_smtf   = (_smtf_falling ? 1 : 0) + (_smtf_below50 ? 1 : 0) + (_smtf_ob ? 1 : 0)

score_bull = _sc_b_kdir + _sc_b_krising + _sc_b_kos + _sc_b_tint + _sc_b_rsi + _sc_b_buy + _sc_b_div + _sc_b_smtf
score_bear = _sc_r_kdir + _sc_r_kfall  + _sc_r_kob + _sc_r_tint + _sc_r_rsi + _sc_r_sell + _sc_r_div + _sc_r_smtf
score_net  = score_bull - score_bear  // range: -15 to +15

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 10.5 — DAILY SIGNAL COUNTERS (for info table)
// ═══════════════════════════════════════════════════════════════════════════════
// Reset counters at start of each day
var int buys_today  = 0
var int sells_today = 0
_new_day = ta.change(time("D")) != 0
if _new_day
    buys_today  := 0
    sells_today := 0
if plain_buy or strong_buy
    buys_today += 1
if plain_sell or strong_sell
    sells_today += 1

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11 — INFO TABLE
// ═══════════════════════════════════════════════════════════════════════════════
if show_table and barstate.islast
    tbl_sz  = tbl_size == "tiny" ? size.tiny : tbl_size == "normal" ? size.normal : size.small
    tbl_pos_resolved = tbl_pos == "Top Left"       ? position.top_left    :
                       tbl_pos == "Top Center"     ? position.top_center  :
                       tbl_pos == "Middle Left"    ? position.middle_left :
                       tbl_pos == "Middle Center"  ? position.middle_center:
                       tbl_pos == "Middle Right"   ? position.middle_right :
                       tbl_pos == "Bottom Left"    ? position.bottom_left  :
                       tbl_pos == "Bottom Center"  ? position.bottom_center:
                       tbl_pos == "Bottom Right"   ? position.bottom_right :
                       position.top_right
    bg_dark  = color.rgb(20, 20, 20, 0)
    bg_head  = color.rgb(0, 188, 212, 0)

    var table tbl = table.new(tbl_pos_resolved, 2, 7,
         border_width=0, frame_color=#00BCD4, frame_width=2)

    // Row 0 — name + preset + TF
    preset_icon = is_auto_preset ? " 🎯" : " ✋"
    tf_label    = tf_tier == "fast" ? "3m" : tf_tier == "medium" ? "1H" : "1D"
    table.cell(tbl, 0, 0, "DELTA Stoch", text_color=color.white, bgcolor=bg_head,
         text_size=tbl_sz, text_halign=text.align_left)
    _smtf_pts_str = smtf_wired ? "" : "  ⚠️ -3pts"
    table.cell(tbl, 1, 0, asset_preset + preset_icon + " · " + tf_label + _smtf_pts_str,
         text_color=color.white, bgcolor=bg_head, text_size=tbl_sz, text_halign=text.align_right)

    // Row 1 — Score bar (moved to top for immediate visibility)
    _bar_filled = math.max(0, math.min(10, math.round((score_net + 15) * 10 / 30)))
    _bar_str = ""
    for _i = 1 to 10
        _bar_str := _bar_str + (_i <= _bar_filled ? "█" : "░")
    _max_pts = smtf_wired ? 15 : 12
    _bar_net_str = (score_net >= 0 ? "+" : "") + str.tostring(score_net) + "/" + str.tostring(_max_pts)
    _bar_col = score_net > 3 ? #00C853 : score_net < -3 ? #FF5252 : #FFD600
    _score_bg = _smtf_warn ? color.rgb(80, 70, 0, 0) : bg_dark
    table.cell(tbl, 0, 1, "Score", text_color=color.white, bgcolor=_score_bg,
         text_size=tbl_sz, text_halign=text.align_left)
    table.cell(tbl, 1, 1, _bar_str + "  " + _bar_net_str,
         text_color=_bar_col, bgcolor=_score_bg, text_size=tbl_sz, text_halign=text.align_right)

    // Row 3 — Lead variant
    table.cell(tbl, 0, 3, "Lead", text_color=color.white, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_left)
    table.cell(tbl, 1, 3, lead_mode, text_color=#00BCD4, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_right)

    // Row 4 — K value + zone status
    zone_str   = lead_k >= _ob ? "OVERBOUGHT" : lead_k <= _os ? "OVERSOLD" :
                 lead_k > lead_d ? "Bullish" : "Bearish"
    zone_color = lead_k >= _ob ? #FF5252 : lead_k <= _os ? #00C853 :
                 lead_k > lead_d ? #00C853 : #FF5252
    table.cell(tbl, 0, 4, "K", text_color=color.white, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_left)
    table.cell(tbl, 1, 4, str.tostring(math.round(lead_k, 1)) + "  " + zone_str,
         text_color=zone_color, bgcolor=bg_dark, text_size=tbl_sz, text_halign=text.align_right)

    // Row 2 — Last signal
    last_sig_str = strong_buy ? "💎 S-BUY" : strong_sell ? "💎 S-SELL" :
                   plain_buy ? "🟢 BUY" : plain_sell ? "🔴 SELL" :
                   anyBullDiv ? "Bull Div" : anyBearDiv ? "Bear Div" : "—"
    last_sig_color = strong_buy or plain_buy or anyBullDiv ? #00C853 :
                     strong_sell or plain_sell or anyBearDiv ? #FF5252 : color.white
    table.cell(tbl, 0, 2, "Signal", text_color=color.white, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_left)
    table.cell(tbl, 1, 2, last_sig_str, text_color=last_sig_color, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_right)

    // Row 5 — Signal count today
    today_str = "🟢 " + str.tostring(buys_today) + "  🔴 " + str.tostring(sells_today)
    _today_col = buys_today > sells_today ? #00C853 : sells_today > buys_today ? #FF5252 : color.white
    table.cell(tbl, 0, 5, "Today", text_color=color.white, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_left)
    table.cell(tbl, 1, 5, today_str, text_color=_today_col, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_right)

    // Row 6 — Bull/Bear split (Today-style format: 🟢 N · 🔴 N)
    _bb_str = "🟢 " + str.tostring(score_bull) + "  🔴 " + str.tostring(score_bear)
    _bb_col = score_bull > score_bear ? #00C853 : score_bear > score_bull ? #FF5252 : color.white
    table.cell(tbl, 0, 6, "Now B/B", text_color=color.white, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_left)
    table.cell(tbl, 1, 6, _bb_str, text_color=_bb_col, bgcolor=bg_dark,
         text_size=tbl_sz, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11.1 — QUICK START SETUP GUIDE
// ═══════════════════════════════════════════════════════════════════════════════
// Displays a dismissible setup checklist for new users.
// Turn OFF "Show Quick Start Guide" in DISPLAY settings once setup is complete.
var label _qs_label = na
if barstate.islast
    label.delete(_qs_label)
    if show_quickstart
        _qs_txt = "━━  DELTA STOCHASTIC — QUICK START  ━━\n" +
             "This indicator works standalone (±12 pts max score)\n" +
             "or paired with SMTF Stoch for full ±15 pts.\n\n" +
             "── OPTIONAL: ADD SMTF FOR FULL SCORING ──\n" +
             "1. In TradingView, search Indicators for:\n" +
             "   \"Smart Multi-TF Stochastic\"\n" +
             "   by kompas2024\n" +
             "2. Add it to THE SAME PANE as DELTA Stochastic\n" +
             "3. Open DELTA Stochastic settings → DISPLAY\n" +
             "4. Set \"SMTF Stoch K (source)\" to:\n" +
             "   SMTF Stoch: SMART STOCH  ← pick this one\n" +
             "   (ignore the Russian-labeled options)\n" +
             "5. Enable \"✅ SMTF Wired\" toggle → OK\n\n" +
             "Once done: turn OFF \"Show Quick Start Guide\"\n" +
             "in DISPLAY settings to dismiss this label."
        _qs_label := label.new(bar_index, 50, text=_qs_txt,
             style=label.style_label_left, color=color.rgb(20, 20, 20, 0),
             textcolor=color.white, size=size.normal, textalign=text.align_left)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 11.5 — GO DESK OUTPUT WIRE
// ═══════════════════════════════════════════════════════════════════════════════
// Exports score_net (-15..+15) as a hidden plot for Go Desk to read via
// input.source(). display.none = invisible on chart, still available as source.
// Part 2 (Go Desk input.source + weighting logic) deferred — audit plot budget first.
plot(score_net, title="Score Net (Go Desk wire)", display=display.none)

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION 12 — ALERT CONDITIONS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(plain_buy or strong_buy,
     title="BUY Signal",
     message="DELTA Stoch — {{ticker}} BUY: K crossed above D in oversold zone ({{close}})")

alertcondition(plain_sell or strong_sell,
     title="SELL Signal",
     message="DELTA Stoch — {{ticker}} SELL: K crossed below D in overbought zone ({{close}})")

alertcondition(strong_buy,
     title="STRONG BUY (cross + divergence)",
     message="DELTA Stoch — {{ticker}} S-BUY: oversold cross with bullish divergence confluence ({{close}})")

alertcondition(strong_sell,
     title="STRONG SELL (cross + divergence)",
     message="DELTA Stoch — {{ticker}} S-SELL: overbought cross with bearish divergence confluence ({{close}})")

alertcondition(anyBullDiv,
     title="Bullish Divergence",
     message="DELTA Stoch — {{ticker}} bullish divergence confirmed ({{close}})")

alertcondition(anyBearDiv,
     title="Bearish Divergence",
     message="DELTA Stoch — {{ticker}} bearish divergence confirmed ({{close}})")
````
