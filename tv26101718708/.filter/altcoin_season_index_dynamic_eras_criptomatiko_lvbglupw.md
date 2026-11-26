# Altcoin Season Index [Dynamic Eras] | CriptoMatiko

- url: https://www.tradingview.com/script/lvBglupw-Altcoin-Season-Index-Dynamic-Eras-CriptoMatiko/
- type: indicator
- pine_id: PUB;91f81443acfa4e4984f09cebb70042c5
- version: 1.0

## Description

The Altcoin Season Index [Dynamic Eras] measures the percentage of top altcoins that have outperformed Bitcoin over a configurable rolling window (default: 90 days). Values above 75 indicate Altcoin Season; values below 25 indicate Bitcoin Season.

─────────────────────────────────────────────
WHAT MAKES THIS VERSION DIFFERENT
─────────────────────────────────────────────

Most Altcoin Season Index implementations use a fixed basket of coins evaluated against a static lookback window. This version solves two problems with that approach:

**1. Dynamic Eras — basket that reflects each market cycle**

The top altcoins in 2020 are not the same as in 2024. Including dead projects (LUNA, FTT) or irrelevant coins in later periods creates misleading signals. This script uses 6 time-based baskets:

- Era 1 (before Oct 2020): 20 coins — pre-DeFi legacy basket
- Era 2 (Oct 2020 – Oct 2021): 25 coins — DeFi Summer + Bull Run
- Era 3 (Oct 2021 – Oct 2022): 25 coins — Cycle top + early bear
- Era 4 (Oct 2022 – Oct 2023): 25 coins — Bear Market survivors
- Era 5 (Oct 2023 – Oct 2024): 30 coins — Recovery + ETF + Halving
- Era 6 (Oct 2024+): 30 coins — AI & Meme narrative leaders

**2. Variable denominator**

The denominator changes with each era (20 / 25 / 30) to match the actual basket size, keeping the 0–100 scale consistent and meaningful across all historical periods.

Total tracked assets: 40 (BTC + 39 altcoins across 5 tiers: established majors, DeFi, L2s, AI, Meme).

─────────────────────────────────────────────
TECHNICAL IMPLEMENTATION
─────────────────────────────────────────────

Performance for each asset is calculated WITHIN the daily context of request.security() — not on the chart's current timeframe. This ensures the 90-day rolling window always measures 90 calendar days, whether you are viewing a 1H or 1W chart. The calculation is: (close - close[win]) / close[win] * 100, evaluated daily.

─────────────────────────────────────────────
HOW TO READ IT
─────────────────────────────────────────────

- Above 75 → Altcoin Season: more than 75% of the active basket outperformed BTC in the last 90 days
- Below 25 → Bitcoin Season: Bitcoin dominates; most altcoins underperform
- 25–75 → Neutral: mixed conditions, no clear rotation signal

─────────────────────────────────────────────
INPUTS
─────────────────────────────────────────────

Model Settings:
- Comparison Window (days): rolling lookback period (default 90)

Regime Thresholds:
- Altcoin Season Threshold: upper boundary (default 75)
- Bitcoin Season Threshold: lower boundary (default 25)

Visual:
- Show Background Zones: highlights Altcoin Season and Bitcoin Season zones
- Show Status Table: toggles the bottom-right info panel

─────────────────────────────────────────────
STATUS TABLE
─────────────────────────────────────────────

- Index: current index value (0–100)
- Regime: ALTCOIN SEASON / NEUTRAL / BITCOIN SEASON
- Era / Basket: current era number and active coin count
- Data: LIVE when price feeds are connected, WAITING otherwise

─────────────────────────────────────────────
CHART ANNOTATIONS
─────────────────────────────────────────────

The circles on the lower pane mark historical extreme readings — index peaks above 75 (Altcoin Season) and troughs below 25 (Bitcoin Season). The arrows on the price chart illustrate the directional moves that followed those extremes, showing the historical correlation between extreme index readings and subsequent price reversals.

─────────────────────────────────────────────
NOTES
─────────────────────────────────────────────

Methodology inspired by the original Altcoin Season Index by BlockchainCenter.net. This is an independent open-source implementation with an expanded basket (40 assets vs the original 50 by market cap) and dynamic era logic.

For educational purposes only. Not financial advice.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © CriptoMatiko

//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// SCRIPT : Altcoin Season Index [Dynamic Eras] | CriptoMatiko
// SHORT  : CM - ALSI
// AUTHOR : Vernon_CriptoMatiko
// METHOD : Measures the % of top altcoins that outperformed Bitcoin over a
//          rolling window of 90 days (default). Uses Dynamic Eras to prevent
//          survivor bias and maintain relevance in each market cycle.
//          Methodology inspired by BlockchainCenter's Altcoin Season Index.
//          Total tracked assets: 40 (BTC + 39 altcoins).
//          Active basket per era: 20 (Era 1), 25 (Eras 2-4), 30 (Eras 5-6).
//
// TECHNICAL NOTE: Each asset's performance is calculated WITHIN the daily
//          context of request.security(), ensuring the window always looks
//          back N calendar days — regardless of the chart's active timeframe.
// ─────────────────────────────────────────────────────────────────────────────

indicator("Altcoin Season Index [Dynamic Eras] | CriptoMatiko", shorttitle="CM - ALSI", overlay=false, precision=0)

// ═══════════════════════════════════════════════════════════════════════════════
// 1. INPUTS
// ═══════════════════════════════════════════════════════════════════════════════
grp_model  = "Model Settings"
win        = input.int(90, "Comparison Window (days)", minval=10, maxval=365,
              tooltip="Rolling window in days to compare altcoin performance vs Bitcoin. Default: 90 days (BlockchainCenter methodology).",
              group=grp_model)

grp_zones  = "Regime Thresholds"
th_alt     = input.int(75, "Altcoin Season Threshold", minval=50, maxval=100,
              tooltip="Values above this level indicate altcoin dominance over Bitcoin.",
              group=grp_zones)
th_btc     = input.int(25, "Bitcoin Season Threshold", minval=0, maxval=50,
              tooltip="Values below this level indicate Bitcoin dominance.",
              group=grp_zones)

grp_vis    = "Visual"
show_zones = input.bool(true, "Show Background Zones", group=grp_vis)
show_table = input.bool(true, "Show Status Table",     group=grp_vis)

// ═══════════════════════════════════════════════════════════════════════════════
// 2. DATA — 40 request.security() calls = BTC + 39 altcoins
//
//    perf_d() is evaluated WITHIN each asset's daily context inside
//    request.security(). This ensures close[win] always looks back
//    win calendar days, regardless of the chart's active timeframe.
// ═══════════════════════════════════════════════════════════════════════════════
perf_d() =>
    val = (close - close[win]) / close[win] * 100
    na(val) ? -9999.0 : val

// Reference
p_btc  = request.security("BINANCE:BTCUSDT",   "D", perf_d(), ignore_invalid_symbol=true)

// Tier 1 — High liquidity, historical presence (10 alts)
p_eth  = request.security("BINANCE:ETHUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_bnb  = request.security("BINANCE:BNBUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_xrp  = request.security("BINANCE:XRPUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_sol  = request.security("BINANCE:SOLUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_ada  = request.security("BINANCE:ADAUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_doge = request.security("BINANCE:DOGEUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_trx  = request.security("BINANCE:TRXUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_dot  = request.security("BINANCE:DOTUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_link = request.security("BINANCE:LINKUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_ltc  = request.security("BINANCE:LTCUSDT",   "D", perf_d(), ignore_invalid_symbol=true)

// Tier 2 — Established altcoins (10 alts)
p_bch  = request.security("BINANCE:BCHUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_atom = request.security("BINANCE:ATOMUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_vet  = request.security("BINANCE:VETUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_uni  = request.security("BINANCE:UNIUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_xlm  = request.security("BINANCE:XLMUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_etc  = request.security("BINANCE:ETCUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_fil  = request.security("BINANCE:FILUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_near = request.security("BINANCE:NEARUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_avax = request.security("BINANCE:AVAXUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_icp  = request.security("BINANCE:ICPUSDT",   "D", perf_d(), ignore_invalid_symbol=true)

// Tier 3 — Mid-era relevance (8 alts)
p_algo = request.security("BINANCE:ALGOUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_pol  = request.security("BINANCE:POLUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_shib = request.security("BINANCE:SHIBUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_ton  = request.security("BINANCE:TONUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_neo  = request.security("BINANCE:NEOUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_xtz  = request.security("BINANCE:XTZUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_eos  = request.security("BINANCE:EOSUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_aave = request.security("BINANCE:AAVEUSDT",  "D", perf_d(), ignore_invalid_symbol=true)

// Tier 4 — L2 narrative + new L1s 2022+ (4 alts)
p_arb  = request.security("BINANCE:ARBUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_op   = request.security("BINANCE:OPUSDT",    "D", perf_d(), ignore_invalid_symbol=true)
p_apt  = request.security("BINANCE:APTUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_sui  = request.security("BINANCE:SUIUSDT",   "D", perf_d(), ignore_invalid_symbol=true)

// Tier 5 — AI, Meme and 2024+ narrative leaders (7 alts)
p_pepe = request.security("BINANCE:PEPEUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_tao  = request.security("BINANCE:TAOUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_rndr = request.security("BINANCE:RENDERUSDT","D", perf_d(), ignore_invalid_symbol=true)
p_fet  = request.security("BINANCE:FETUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_inj  = request.security("BINANCE:INJUSDT",   "D", perf_d(), ignore_invalid_symbol=true)
p_hbar = request.security("BINANCE:HBARUSDT",  "D", perf_d(), ignore_invalid_symbol=true)
p_wld  = request.security("BINANCE:WLDUSDT",   "D", perf_d(), ignore_invalid_symbol=true)

// ═══════════════════════════════════════════════════════════════════════════════
// 3. DYNAMIC ERAS — Dynamic basket per market cycle
// ═══════════════════════════════════════════════════════════════════════════════
t2 = timestamp(2020, 10, 1, 0, 0) // Oct 2020
t3 = timestamp(2021, 10, 1, 0, 0) // Oct 2021
t4 = timestamp(2022, 10, 1, 0, 0) // Oct 2022
t5 = timestamp(2023, 10, 1, 0, 0) // Oct 2023
t6 = timestamp(2024, 10, 1, 0, 0) // Oct 2024

check(p) => p > p_btc ? 1.0 : 0.0

float wins  = 0.0
float denom = 20.0

// ERA 1: Before Oct 2020 — 20 coins (pre-DeFi market)
if time < t2
    wins  := check(p_eth)  + check(p_xrp)  + check(p_bch)  + check(p_bnb)  + check(p_dot)  +
             check(p_link) + check(p_ltc)  + check(p_ada)  + check(p_xlm)  + check(p_eos)  +
             check(p_trx)  + check(p_atom) + check(p_neo)  + check(p_xtz)  + check(p_vet)  +
             check(p_uni)  + check(p_fil)  + check(p_doge) + check(p_algo) + check(p_etc)
    denom := 20.0

// ERA 2: Oct 2020 — Oct 2021 — 25 coins (DeFi Summer + Bull Run)
else if time >= t2 and time < t3
    wins  := check(p_eth)  + check(p_bnb)  + check(p_xrp)  + check(p_ada)  + check(p_dot)  +
             check(p_doge) + check(p_link) + check(p_ltc)  + check(p_bch)  + check(p_uni)  +
             check(p_xlm)  + check(p_atom) + check(p_vet)  + check(p_icp)  + check(p_fil)  +
             check(p_etc)  + check(p_algo) + check(p_trx)  + check(p_neo)  + check(p_xtz)  +
             check(p_eos)  + check(p_avax) + check(p_sol)  + check(p_aave) + check(p_pol)
    denom := 25.0

// ERA 3: Oct 2021 — Oct 2022 — 25 coins (Cycle top + early bear)
else if time >= t3 and time < t4
    wins  := check(p_eth)  + check(p_bnb)  + check(p_xrp)  + check(p_ada)  + check(p_sol)  +
             check(p_doge) + check(p_dot)  + check(p_avax) + check(p_link) + check(p_ltc)  +
             check(p_algo) + check(p_bch)  + check(p_pol)  + check(p_xlm)  + check(p_vet)  +
             check(p_icp)  + check(p_fil)  + check(p_atom) + check(p_trx)  + check(p_etc)  +
             check(p_near) + check(p_uni)  + check(p_shib) + check(p_aave) + check(p_eos)
    denom := 25.0

// ERA 4: Oct 2022 — Oct 2023 — 25 coins (Bear Market)
else if time >= t4 and time < t5
    wins  := check(p_eth)  + check(p_bnb)  + check(p_xrp)  + check(p_ada)  + check(p_sol)  +
             check(p_doge) + check(p_pol)  + check(p_dot)  + check(p_shib) + check(p_trx)  +
             check(p_avax) + check(p_uni)  + check(p_ltc)  + check(p_link) + check(p_atom) +
             check(p_etc)  + check(p_xlm)  + check(p_algo) + check(p_icp)  + check(p_fil)  +
             check(p_near) + check(p_bch)  + check(p_arb)  + check(p_apt)  + check(p_op)
    denom := 25.0

// ERA 5: Oct 2023 — Oct 2024 — 30 coins (Recovery + ETF + Halving)
else if time >= t5 and time < t6
    wins  := check(p_eth)  + check(p_bnb)  + check(p_xrp)  + check(p_sol)  + check(p_ada)  +
             check(p_doge) + check(p_trx)  + check(p_ton)  + check(p_pol)  + check(p_dot)  +
             check(p_ltc)  + check(p_bch)  + check(p_shib) + check(p_link) + check(p_avax) +
             check(p_xlm)  + check(p_atom) + check(p_icp)  + check(p_apt)  + check(p_arb)  +
             check(p_near) + check(p_sui)  + check(p_pepe) + check(p_inj)  + check(p_hbar) +
             check(p_fet)  + check(p_tao)  + check(p_op)   + check(p_uni)  + check(p_aave)
    denom := 30.0

// ERA 6: Oct 2024+ — 30 coins (AI & Meme Era)
else
    wins  := check(p_eth)  + check(p_bnb)  + check(p_sol)  + check(p_xrp)  + check(p_doge) +
             check(p_ton)  + check(p_trx)  + check(p_ada)  + check(p_avax) + check(p_shib) +
             check(p_link) + check(p_bch)  + check(p_dot)  + check(p_near) + check(p_uni)  +
             check(p_sui)  + check(p_pepe) + check(p_apt)  + check(p_tao)  + check(p_rndr) +
             check(p_fet)  + check(p_inj)  + check(p_hbar) + check(p_wld)  + check(p_arb)  +
             check(p_op)   + check(p_pol)  + check(p_atom) + check(p_xlm)  + check(p_icp)
    denom := 30.0

index = (wins / denom) * 100.0

// ═══════════════════════════════════════════════════════════════════════════════
// 4. PLOT
// ═══════════════════════════════════════════════════════════════════════════════
co_green = color.rgb(0, 200, 150)                 // CriptoMatiko green
co_dark  = color.rgb(13, 27, 42)                  // CriptoMatiko dark navy
co_alt   = color.new(color.rgb(220, 38, 38),  85) // Altcoin season zone (red)
co_btc   = color.new(color.rgb(247, 147, 26), 85) // Bitcoin season zone (BTC orange)

plot(index, "Altcoin Season Index", color=co_green, linewidth=2)

h_top = hline(th_alt, "Altcoin Season Threshold", color.gray, hline.style_dotted)
h_bot = hline(th_btc, "Bitcoin Season Threshold",  color.gray, hline.style_dotted)

fill(h_top, hline(100), color=show_zones ? co_alt : na, title="Altcoin Season Zone")
fill(h_bot, hline(0),   color=show_zones ? co_btc : na, title="Bitcoin Season Zone")

// ═══════════════════════════════════════════════════════════════════════════════
// 5. STATUS TABLE
// ═══════════════════════════════════════════════════════════════════════════════
var table tbl = table.new(position.bottom_right, 2, 5, border_width=1)

if barstate.islast and show_table
    regime_txt = index >= th_alt ? "ALTCOIN SEASON" : index <= th_btc ? "BITCOIN SEASON" : "NEUTRAL"
    regime_col = index >= th_alt ? color.rgb(220, 38, 38) : index <= th_btc ? color.rgb(247, 147, 26) : color.gray

    era_num  = time < t2 ? "1" : time < t3 ? "2" : time < t4 ? "3" : time < t5 ? "4" : time < t6 ? "5" : "6"
    basket_n = time < t2 ? "20" : time < t5 ? "25" : "30"

    // Header
    table.cell(tbl, 0, 0, "CM - ALSI",   bgcolor=co_green, text_color=co_dark, text_size=size.small)
    table.cell(tbl, 1, 0, "Educational", bgcolor=co_green, text_color=co_dark, text_size=size.tiny)

    // Index value
    table.cell(tbl, 0, 1, "Index",       bgcolor=co_dark, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 1, str.tostring(index, "#"), bgcolor=regime_col, text_color=color.white, text_size=size.small)

    // Regime
    table.cell(tbl, 0, 2, "Regime",      bgcolor=co_dark, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(tbl, 1, 2, regime_txt,    bgcolor=co_dark, text_color=regime_col,  text_size=size.small)

    // Era and active basket
    table.cell(tbl, 0, 3, "Era / Basket",     bgcolor=co_dark, text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 3, "Era " + era_num + " · " + basket_n + " coins", bgcolor=co_dark, text_color=color.gray, text_size=size.tiny)

    // Data status
    is_live = not na(p_btc) and not na(p_eth)
    table.cell(tbl, 0, 4, "Data",        bgcolor=co_dark, text_color=color.white, text_size=size.tiny, text_halign=text.align_left)
    table.cell(tbl, 1, 4, is_live ? "LIVE" : "WAITING", bgcolor=is_live ? co_green : color.red, text_color=is_live ? co_dark : color.white, text_size=size.tiny)
````
