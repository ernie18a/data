# CCI - Country Crisis Index

- url: https://www.tradingview.com/script/QfAT7uty-CCI-Country-Crisis-Index/
- type: indicator
- pine_id: PUB;3726a8124d50463782977b59fee378a7
- version: 1.0

## Description

Country Crisis Index (CCI) — Real-Time Country-Level Risk Dashboard

The Country Crisis Index answers one question: how bad is it HERE, specifically?

While global indices tell you what the world is doing, CCI drills into a single country's stress across six dimensions — equity markets, currency flight, inflation, sovereign credit, external vulnerability, and political sentiment — and compresses it into a single 0-100 score with actionable trading guidance.

🔢 Six Scoring Modules

Module	Weight	What It Captures
M1 Domestic Equity Stress	0-20	Benchmark z-score, bank/benchmark ratio, smallcap rotation, VIX, sector breadth
M2 Currency & Capital Flow	0-20	FX rate-of-change (1/3/5-bar with decay), FX z-score, yield spikes, sovereign spread, DXY-adjusted move
M3 Inflation & Cost of Living	0-15	Oil-in-local-currency, gold-in-local breakout, wheat, copper, natural gas
M4 Sovereign & Credit Risk	0-20	Sovereign spread level + momentum, bank sector weakness, HYG credit, correlation break
M5 External Vulnerability	0-15	Oil import stress, trade partner z-score, US 10Y momentum, DXY strength
M6 Political & Sentiment	0-10	VIX event risk, PSU/private divergence, smallcap drawdown, sustained volatility
🚦 Five Threat Levels

L0 CALM (0-19) — Full deployment. Business as usual.
L1 ALERT (20-39) — Something twitching. Tighten stops.
L2 WARNING (40-59) — Hedge the book. Rotate to quality.
L3 DANGER (60-79) — Capital preservation mode. Cut weak names.
L4 CRISIS (80-100) — Maximum defensive. Survive first, profit later.
📊 9-Row Dashboard

The table packs everything a trader needs into a single glance:

Score & Level — CCI value with threat classification and country code
Signal & Direction — Action signal (DEPLOY → EXIT ALL) with crisis momentum (SURGING / RISING / FLAT / COOLING / RETREATING)
7-Bar Sparkline — Colour-coded trend: red = crisis rising, green = easing, gray = steady. Includes Δ7 and Δ1 deltas
Exposure — Recommended portfolio allocation percentage with guidance text
Driver — Which module is dominant plus active feed tags (Bank↓, Oil(52H), VIX↑, etc.)
Mood — 3-line editorial combining observation + reaction + insight, with 465+ sentence combinations adapting to timeframe, threat level, and trend direction
Currency — Local exchange rate (e.g., ₹84.35/$), FX direction, sovereign spread, target stock move
Indices — 7-index heatmap with last session % change and ▲/▼ arrows
Status — Market open/closed with distinct colours for after hours, holidays, and weekends (OHLC-verified, not just clock-based)
🌏 10 Country Profiles

Select from the dropdown: India (default, fully implemented), United States, United Kingdom, Japan, Germany, China, Australia, Brazil, South Korea, Turkey.

Each profile maps 11 country-specific symbols plus configuration flags for FX direction, emerging market volatility scaling, oil importer weighting, timezone, and market hours.

⚙️ Key Mechanics

Asymmetric Smoothing — Crisis rises fast (3-bar EMA), eases slowly (10-bar EMA). Designed to catch the elevator down but not the escalator up.
Convergence Multiplier — When 3+ modules fire simultaneously, the score amplifies (1.15x to 1.5x). Multi-front stress is worse than the sum of parts.
EM Volatility Scaling — Emerging market FX thresholds are scaled wider (India 1.2x, Turkey 1.8x) because a 1% move in the rupee is not the same as 1% in the dollar.
Timeframe Adaptive — Works on any chart timeframe. All data feeds use chart resolution. Mood text adapts language for intraday scalpers, daily swing traders, and weekly allocators.
Holiday Detection — Uses OHLC stale-data verification, not just clock hours. Correctly identifies exchange holidays even on 24/7 chart symbols.
📡 Webhook JSON Export

Full indicator state exported as JSON via TradingView alerts — score, all six module values, 22 price feeds, Δ7/Δ1 deltas, dominant driver, exposure, session status, mood text, sub-headline, and multi-sentence narrative. Ready for downstream apps, dashboards, or notification systems.

🔗 Companion to WCI

CCI is designed to work alongside the World Crisis Index (WCI). WCI answers "how bad is the world?" — CCI answers "how bad is it here?" Together they give you global macro context and country-specific risk in one view. Default table positions avoid overlap (WCI top-right, CCI bottom-right).

Data: 22 of 40 request.security() calls. No repainting. Pine Script v6.

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
// CCI — Country Crisis Index
// Version 1.0 | Pine Script v6
//
// A country-level crisis indicator that complements the WCI (World Crisis
// Index). WCI answers "how bad is the world?" — CCI answers "how bad is it
// HERE specifically?"
//
// Architecture: 6 modules measuring different dimensions of country-specific
// stress, producing a 0–100 composite score with asymmetric smoothing.
//
// Modules:
//   M1 — Domestic Equity Stress  (0–20 pts)
//   M2 — Currency & Capital Flow (0–20 pts)
//   M3 — Inflation & Cost of Living (0–15 pts)
//   M4 — Sovereign & Credit Risk (0–20 pts)
//   M5 — External Vulnerability  (0–15 pts)
//   M6 — Political & Sentiment   (0–10 pts)
//
// Total CCI: 0–100 (before convergence boost, capped at 100)
//
// Supported Countries (Phase 1: India fully implemented):
//   India (default), United States, United Kingdom, Japan, Germany,
//   China, Australia, Brazil, South Korea, Turkey
//
// Data Budget: 22 of 40 request.security() calls used (18 remaining)
//
// Designed to run alongside WCI on the same chart without overlap.
// ══════════════════════════════════════════════════════════════════════════════

//@version=6
indicator(
  title           = "CCI — Country Crisis Index",
  shorttitle      = "CCI",
  overlay         = false,
  max_bars_back   = 500,
  max_lines_count = 50,
  max_labels_count= 50,
  max_boxes_count = 50
)

// ══════════════════════════════════════════════════════════════════════════════
// SECTION 2: USER INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── COUNTRY ──────────────────────────────────────────────
i_country = input.string("India", "Country",
             options = ["India", "United States", "United Kingdom", "Japan",
                        "Germany", "China", "Australia", "Brazil",
                        "South Korea", "Turkey"],
             group = "Country",
             tooltip = "Selects all feeds, thresholds, and session hours for the chosen country.")

// ── DISPLAY ──────────────────────────────────────────────
i_showTable     = input.bool(true,  "Show Crisis Dashboard Table",       group = "Display")
i_showBg        = input.bool(true,  "Show Background Colour",            group = "Display")
i_showModules   = input.bool(true,  "Show Module Stacked Area",          group = "Display")
i_showMood      = input.bool(true,  "Show Mood Line in Dashboard",       group = "Display")
i_showSparkline = input.bool(true,  "Show 7-Bar Sparkline in Dashboard", group = "Display")
i_showSignal    = input.bool(true,  "Show Action Signal in Dashboard",   group = "Display")
i_tablePos      = input.string("Bottom Right", "Table Position",
                   options = ["Top Right","Top Left","Bottom Right","Bottom Left"],
                   group = "Display",
                   tooltip = "Default Bottom Right to avoid overlap with WCI (Top Right).")

// ── SENSITIVITY ──────────────────────────────────────────
i_zLookback = input.int(100, "Z-Score Lookback (bars)", minval = 50, maxval = 500, group = "Sensitivity")
i_cciL1     = input.int(20,  "CCI Level 1 Threshold",   minval = 5,  maxval = 40,  group = "Sensitivity")
i_cciL2     = input.int(40,  "CCI Level 2 Threshold",   minval = 20, maxval = 55,  group = "Sensitivity")
i_cciL3     = input.int(60,  "CCI Level 3 Threshold",   minval = 40, maxval = 75,  group = "Sensitivity")
i_cciL4     = input.int(80,  "CCI Level 4 Threshold",   minval = 60, maxval = 95,  group = "Sensitivity")

// ── EXPOSURE ─────────────────────────────────────────────
i_riskTolerance = input.string("Moderate", "Risk Appetite",
                   options = ["Conservative","Moderate","Aggressive"],
                   group = "Exposure",
                   tooltip = "Shifts the exposure curve. Conservative reduces earlier.")

// ── ALERTS ───────────────────────────────────────────────
i_alertL1     = input.bool(true,  "Alert on Level 1 (Alert)",   group = "Alerts")
i_alertL2     = input.bool(true,  "Alert on Level 2 (Warning)", group = "Alerts")
i_alertL3     = input.bool(true,  "Alert on Level 3 (Danger)",  group = "Alerts")
i_alertL4     = input.bool(true,  "Alert on Level 4 (Crisis)",  group = "Alerts")
i_alertChange = input.bool(true,  "Alert on Level Change",      group = "Alerts")
i_alertJSON   = input.bool(false, "Webhook JSON Export",         group = "Alerts",
                 tooltip = "Fires a JSON alert with full CCI data. Set webhook URL in TradingView alert dialog.")
i_jsonInterval = input.int(15, "JSON Export Interval (minutes)", group = "Alerts",
                  minval = 5, maxval = 60, step = 5,
                  tooltip = "How often the webhook fires on the live bar. Also fires on bar close and reload.")


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 3: COUNTRY PROFILES
// ══════════════════════════════════════════════════════════════════════════════
// Each country maps to a set of TradingView symbols + configuration flags.
// Phase 1: India fully verified. Others: best-guess symbols, verify on TV.

// ── 3.1 Benchmark Index ─────────────────────────────────
string sym_bench = switch i_country
    "India"          => "NSE:NIFTY"
    "United States"  => "SP:SPX"
    "United Kingdom" => "TVC:UKX"
    "Japan"          => "TVC:NI225"
    "Germany"        => "XETR:DAX"
    "China"          => "SSE:000001"
    "Australia"      => "ASX:XJO"
    "Brazil"         => "BMFBOVESPA:IBOV"
    "South Korea"    => "KRX:KOSPI"
    "Turkey"         => "BIST:XU100"
    => "NSE:NIFTY"

// ── 3.2 Banking / Financial Sector ──────────────────────
string sym_bank = switch i_country
    "India"          => "NSE:BANKNIFTY"
    "United States"  => "AMEX:XLF"
    "United Kingdom" => "LSE:BARC"
    "Japan"          => "TSE:8306"
    "Germany"        => "XETR:DBK"
    "China"          => "SSE:000037"
    "Australia"      => "ASX:XFJ"
    "Brazil"         => "BMFBOVESPA:IFNC"
    "South Korea"    => "KRX:091170"
    "Turkey"         => "BIST:XBANK"
    => "NSE:BANKNIFTY"

// ── 3.3 Tech / Growth Sector ────────────────────────────
string sym_tech = switch i_country
    "India"          => "NSE:CNXIT"
    "United States"  => "AMEX:XLK"
    "United Kingdom" => "LSE:IUKD"
    "Japan"          => "TSE:9984"
    "Germany"        => "XETR:TEC0"
    "China"          => "SSE:000906"
    "Australia"      => "ASX:XTX"
    "Brazil"         => "BMFBOVESPA:IBOV"
    "South Korea"    => "KRX:091160"
    "Turkey"         => "BIST:XTEK"
    => "NSE:CNXIT"

// ── 3.4 Smallcap / Midcap (Risk Appetite) ───────────────
string sym_small = switch i_country
    "India"          => "NSE:CNXSMALLCAP"
    "United States"  => "AMEX:IWM"
    "United Kingdom" => "TVC:MCX"
    "Japan"          => "TSE:2516"
    "Germany"        => "XETR:MDAX"
    "China"          => "SSE:000905"
    "Australia"      => "ASX:XSO"
    "Brazil"         => "BMFBOVESPA:SMLL"
    "South Korea"    => "KRX:KOSDAQ"
    "Turkey"         => "BIST:XTUMY"
    => "NSE:CNXSMALLCAP"

// ── 3.5 Local VIX / Volatility ──────────────────────────
string sym_vix = switch i_country
    "India"          => "NSE:INDIAVIX"
    "United States"  => "TVC:VIX"
    "United Kingdom" => "TVC:VIX"
    "Japan"          => "TVC:VIX"
    "Germany"        => "XETR:V1X"
    "China"          => "TVC:VIX"
    "Australia"      => "TVC:VIX"
    "Brazil"         => "TVC:VIX"
    "South Korea"    => "TVC:VIX"
    "Turkey"         => "TVC:VIX"
    => "NSE:INDIAVIX"

// ── 3.6 Currency vs USD ─────────────────────────────────
string sym_fx = switch i_country
    "India"          => "FX:USDINR"
    "United States"  => "TVC:DXY"
    "United Kingdom" => "FX:GBPUSD"
    "Japan"          => "FX:USDJPY"
    "Germany"        => "FX:EURUSD"
    "China"          => "FX_IDC:USDCNY"
    "Australia"      => "FX:AUDUSD"
    "Brazil"         => "FX:USDBRL"
    "South Korea"    => "FX:USDKRW"
    "Turkey"         => "FX:USDTRY"
    => "FX:USDINR"

// ── 3.7 Local 10-Year Yield ─────────────────────────────
string sym_10y = switch i_country
    "India"          => "TVC:IN10Y"
    "United States"  => "TVC:US10Y"
    "United Kingdom" => "TVC:GB10Y"
    "Japan"          => "TVC:JP10Y"
    "Germany"        => "TVC:DE10Y"
    "China"          => "TVC:CN10Y"
    "Australia"      => "TVC:AU10Y"
    "Brazil"         => "TVC:BR10Y"
    "South Korea"    => "TVC:KR10Y"
    "Turkey"         => "TVC:TR10Y"
    => "TVC:IN10Y"

// ── 3.8 Local 2-Year Yield (or fallback to US02Y) ──────
string sym_2y = switch i_country
    "India"          => "TVC:US02Y"
    "United States"  => "TVC:US02Y"
    "United Kingdom" => "TVC:GB02Y"
    "Japan"          => "TVC:JP02Y"
    "Germany"        => "TVC:DE02Y"
    "China"          => "TVC:US02Y"
    "Australia"      => "TVC:AU02Y"
    "Brazil"         => "TVC:US02Y"
    "South Korea"    => "TVC:US02Y"
    "Turkey"         => "TVC:US02Y"
    => "TVC:US02Y"

// ── 3.9 Trade Partner Index ─────────────────────────────
string sym_trade = switch i_country
    "India"          => "SSE:000001"
    "United States"  => "SSE:000001"
    "United Kingdom" => "XETR:DAX"
    "Japan"          => "SSE:000001"
    "Germany"        => "SSE:000001"
    "China"          => "SP:SPX"
    "Australia"      => "SSE:000001"
    "Brazil"         => "SSE:000001"
    "South Korea"    => "SSE:000001"
    "Turkey"         => "XETR:DAX"
    => "SSE:000001"

// ── 3.10 Trade Partner Currency ─────────────────────────
string sym_tradefx = switch i_country
    "India"          => "FX_IDC:USDCNY"
    "United States"  => "FX_IDC:USDCNY"
    "United Kingdom" => "FX:EURUSD"
    "Japan"          => "FX_IDC:USDCNY"
    "Germany"        => "FX_IDC:USDCNY"
    "China"          => "FX:USDJPY"
    "Australia"      => "FX_IDC:USDCNY"
    "Brazil"         => "FX_IDC:USDCNY"
    "South Korea"    => "FX_IDC:USDCNY"
    "Turkey"         => "FX:EURUSD"
    => "FX_IDC:USDCNY"

// ── 3.11 Alternative Sector (PSU Banks for India, etc.) ──
string sym_alt = switch i_country
    "India"          => "NSE:CNXPSUBANK"
    "United States"  => "AMEX:XLE"
    "United Kingdom" => "LSE:LLOY"
    "Japan"          => "TSE:8316"
    "Germany"        => "XETR:SX7E"
    "China"          => "SSE:000300"
    "Australia"      => "ASX:XMJ"
    "Brazil"         => "BMFBOVESPA:VALE3"
    "South Korea"    => "KRX:005930"
    "Turkey"         => "BIST:THYAO"
    => "NSE:CNXPSUBANK"

// ── 3.12 Additional Sector 5 ────────────────────────────
string sym_sect5 = switch i_country
    "India"          => "NSE:CNXPHARMA"
    "United States"  => "AMEX:XLV"
    "United Kingdom" => "LSE:AZN"
    "Japan"          => "TSE:7203"
    "Germany"        => "XETR:VOW3"
    "China"          => "SSE:000913"
    "Australia"      => "ASX:XHJ"
    "Brazil"         => "BMFBOVESPA:PETR4"
    "South Korea"    => "KRX:005380"
    "Turkey"         => "BIST:XSGRT"
    => "NSE:CNXPHARMA"

// ── 3.13 Additional Sector 6 ────────────────────────────
string sym_sect6 = switch i_country
    "India"          => "NSE:CNXAUTO"
    "United States"  => "AMEX:XLE"
    "United Kingdom" => "LSE:SHEL"
    "Japan"          => "TSE:6758"
    "Germany"        => "XETR:SIE"
    "China"          => "SSE:000932"
    "Australia"      => "ASX:XEJ"
    "Brazil"         => "BMFBOVESPA:ITUB4"
    "South Korea"    => "KRX:000660"
    "Turkey"         => "BIST:XILTM"
    => "NSE:CNXAUTO"

// ── 3.14 Additional Sector 7 ────────────────────────────
string sym_sect7 = switch i_country
    "India"          => "NSE:CNXMETAL"
    "United States"  => "AMEX:XLI"
    "United Kingdom" => "LSE:RIO"
    "Japan"          => "TSE:8058"
    "Germany"        => "XETR:BAS"
    "China"          => "SSE:000936"
    "Australia"      => "ASX:XMJ"
    "Brazil"         => "BMFBOVESPA:BBDC4"
    "South Korea"    => "KRX:051910"
    "Turkey"         => "BIST:XKMYA"
    => "NSE:CNXMETAL"

// ── 3.15 Configuration Flags ────────────────────────────

// FX inversion: true when pair is LOCAL/USD (falling = weakness)
// false when pair is USD/LOCAL (rising = local weakness)
bool fx_invert = switch i_country
    "United States"  => true
    "United Kingdom" => true
    "Germany"        => true
    "Australia"      => true
    => false

// Emerging market volatility multiplier (EM needs wider bands)
float em_mult = switch i_country
    "India"          => 1.2
    "Brazil"         => 1.5
    "Turkey"         => 1.8
    "China"          => 1.3
    "South Korea"    => 1.1
    => 1.0

// Oil import dependency (true = net importer, amplifies oil stress)
bool is_oil_importer = switch i_country
    "United States"  => false
    "United Kingdom" => false
    "Australia"      => false
    "Brazil"         => false
    => true

// Country code for display and webhook
string country_code = switch i_country
    "India"          => "IN"
    "United States"  => "US"
    "United Kingdom" => "UK"
    "Japan"          => "JP"
    "Germany"        => "DE"
    "China"          => "CN"
    "Australia"      => "AU"
    "Brazil"         => "BR"
    "South Korea"    => "KR"
    "Turkey"         => "TR"
    => "IN"

// Timezone for session detection
string country_tz = switch i_country
    "India"          => "Asia/Kolkata"
    "United States"  => "America/New_York"
    "United Kingdom" => "Europe/London"
    "Japan"          => "Asia/Tokyo"
    "Germany"        => "Europe/Berlin"
    "China"          => "Asia/Shanghai"
    "Australia"      => "Australia/Sydney"
    "Brazil"         => "America/Sao_Paulo"
    "South Korea"    => "Asia/Seoul"
    "Turkey"         => "Europe/Istanbul"
    => "Asia/Kolkata"

// Market hours (local time, approximate)
int mkt_open_h = switch i_country
    "India"          => 9
    "United States"  => 9
    "United Kingdom" => 8
    "Japan"          => 9
    "Germany"        => 9
    "China"          => 9
    "Australia"      => 10
    "Brazil"         => 10
    "South Korea"    => 9
    "Turkey"         => 10
    => 9

int mkt_close_h = switch i_country
    "India"          => 15
    "United States"  => 16
    "United Kingdom" => 16
    "Japan"          => 15
    "Germany"        => 17
    "China"          => 15
    "Australia"      => 16
    "Brazil"         => 17
    "South Korea"    => 15
    "Turkey"         => 18
    => 15

// Short name for benchmark display
string bench_label = switch i_country
    "India"          => "NIFTY"
    "United States"  => "SPX"
    "United Kingdom" => "FTSE"
    "Japan"          => "NKY"
    "Germany"        => "DAX"
    "China"          => "SHC"
    "Australia"      => "ASX"
    "Brazil"         => "IBOV"
    "South Korea"    => "KOSPI"
    "Turkey"         => "BIST"
    => "NIFTY"

// Short sector labels
string bank_label = switch i_country
    "India" => "BankNF"
    "United States" => "XLF"
    "United Kingdom" => "Banks"
    "Japan" => "Banks"
    "Germany" => "Banks"
    => "Banks"

string tech_label = switch i_country
    "India" => "IT"
    "United States" => "XLK"
    "United Kingdom" => "Tech"
    "Japan" => "Tech"
    "Germany" => "Tech"
    => "Tech"

string small_label = switch i_country
    "India" => "SmCap"
    "United States" => "IWM"
    "United Kingdom" => "FTSE250"
    "Japan" => "Mothers"
    "Germany" => "MDAX"
    => "SmCap"

string sect5_label = switch i_country
    "India" => "Pharma"
    "United States" => "Health"
    "United Kingdom" => "Pharma"
    "Japan" => "Auto"
    "Germany" => "Auto"
    "China" => "Consum"
    "Australia" => "Health"
    "Brazil" => "Energy"
    "South Korea" => "Auto"
    "Turkey" => "Insur"
    => "Pharma"

string sect6_label = switch i_country
    "India" => "Auto"
    "United States" => "Energy"
    "United Kingdom" => "Energy"
    "Japan" => "Electr"
    "Germany" => "Indust"
    "China" => "Constr"
    "Australia" => "Energy"
    "Brazil" => "FinSvc"
    "South Korea" => "Chips"
    "Turkey" => "Manuf"
    => "Auto"

string sect7_label = switch i_country
    "India" => "Metal"
    "United States" => "Indust"
    "United Kingdom" => "Mining"
    "Japan" => "Trading"
    "Germany" => "Chem"
    "China" => "Defens"
    "Australia" => "Mining"
    "Brazil" => "FinSvc"
    "South Korea" => "Batt"
    "Turkey" => "Chem"
    => "Metal"

string fx_label = switch i_country
    "India" => "INR"
    "United States" => "DXY"
    "United Kingdom" => "GBP"
    "Japan" => "JPY"
    "Germany" => "EUR"
    "China" => "CNY"
    "Australia" => "AUD"
    "Brazil" => "BRL"
    "South Korea" => "KRW"
    "Turkey" => "TRY"
    => "INR"

// Local currency symbol for display
string fx_sym = switch i_country
    "India"          => "₹"
    "United States"  => "$"
    "United Kingdom" => "£"
    "Japan"          => "¥"
    "Germany"        => "€"
    "China"          => "CN¥"
    "Australia"      => "A$"
    "Brazil"         => "R$"
    "South Korea"    => "₩"
    "Turkey"         => "₺"
    => "₹"


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 4: HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

f_zscore(float src, int len) =>
    float avg = ta.sma(src, len)
    float std = ta.stdev(src, len)
    std != 0.0 ? (src - avg) / std : 0.0

f_roc(float src, int len) =>
    src[len] != 0.0 ? (src - src[len]) / src[len] * 100.0 : 0.0

f_vel_zscore(float src, int lookback) =>
    float ret5 = nz(src) != 0.0 and nz(src[5]) != 0.0 ? math.log(src / src[5]) : 0.0
    f_zscore(ret5, lookback)

f_safe_div(float a, float b) =>
    (b != 0.0 and not na(b)) ? a / b : 0.0

f_normalise(float raw, float raw_max, float target_max) =>
    raw_max > 0 ? math.min(raw / raw_max * target_max, target_max) : 0.0

f_pct_str(float v) =>
    (v >= 0 ? "+" : "") + str.tostring(math.round(v, 1)) + "%"

f_pts_str(float v, float mx) =>
    str.tostring(math.round(v, 1)) + "/" + str.tostring(math.round(mx))

f_table_pos(string pos) =>
    switch pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        => position.bottom_right

// Format sector cell: label + arrow + last close %
f_sect_txt(string lbl, float roc) =>
    string arrow = roc > 0.01 ? "▲" : roc < -0.01 ? "▼" : "—"
    lbl + "\n" + arrow + f_pct_str(roc)

// Daily ROC tracker — uses var + timeframe.change("D") so it shows
// the last trading session's % change on ANY chart timeframe (intraday/daily/weekly).
// Each call site gets its own var instances in Pine v6.
f_daily_roc(float src) =>
    var float _curr = na
    var float _prev = na
    if timeframe.change("D")
        _prev := _curr
        _curr := src
    else
        _curr := src
    na(_prev) or _prev == 0.0 ? 0.0 : (_curr - _prev) / _prev * 100.0

// Sparkline: map CCI value to Unicode block character (8-level relative height)
f_spark_char(float val, float lo, float hi) =>
    float _rng = hi - lo
    int idx = _rng > 0.0 ? math.min(math.floor((val - lo) / _rng * 8.0), 7) : 3
    switch idx
        7 => "█"
        6 => "▇"
        5 => "▆"
        4 => "▅"
        3 => "▄"
        2 => "▃"
        1 => "▂"
        => "▁"

// Sparkline: directional background colour (bar-to-bar momentum)
// Rising CCI = crisis worsening = red tones; Falling = easing = green tones
f_spark_dir_bg(float delta) =>
    switch
        delta > 3.0  => color.new(#cc0000, 0)   // fast rising — crisis surging
        delta > 0.5  => color.new(#cc5500, 0)   // rising — crisis worsening
        delta < -3.0 => color.new(#1b5e20, 0)   // fast falling — crisis retreating
        delta < -0.5 => color.new(#2d8659, 0)   // falling — crisis easing
        => color.new(#555555, 0)                 // steady


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 5: DATA FEEDS — request.security() CALLS
// ══════════════════════════════════════════════════════════════════════════════
// 22 calls total. All use "" timeframe (chart-adaptive).

// ── Slot 1: Benchmark Index (close, high, low) — 1 call ──
[bench_c, bench_h, bench_l] = request.security(sym_bench, "", [close, high, low], lookahead = barmerge.lookahead_off)

// ── Slot 2: Banking Sector — 1 call (total: 2) ──
bank_c = request.security(sym_bank, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 3: Tech Sector — 1 call (total: 3) ──
tech_c = request.security(sym_tech, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 4: Smallcap — 1 call (total: 4) ──
small_c = request.security(sym_small, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 5: Local VIX — 1 call (total: 5) ──
vix_c = request.security(sym_vix, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 6: Currency vs USD — 1 call (total: 6) ──
fx_c = request.security(sym_fx, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 7: Local 10Y Yield — 1 call (total: 7) ──
y10_c = request.security(sym_10y, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 8: Local/US 2Y Yield — 1 call (total: 8) ──
y2_c = request.security(sym_2y, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 9: Crude Oil — 1 call (total: 9) ──
oil_c = request.security("NYMEX:CL1!", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 10: Gold — 1 call (total: 10) ──
gold_c = request.security("COMEX:GC1!", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 11: Wheat — 1 call (total: 11) ──
wheat_c = request.security("CBOT:ZW1!", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 12: Natural Gas — 1 call (total: 12) ──
gas_c = request.security("NYMEX:NG1!", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 13: Copper — 1 call (total: 13) ──
copper_c = request.security("COMEX:HG1!", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 14: Trade Partner Index — 1 call (total: 14) ──
trade_c = request.security(sym_trade, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 15: Trade Partner Currency — 1 call (total: 15) ──
tradefx_c = request.security(sym_tradefx, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 16: US 10Y Yield — 1 call (total: 16) ──
us10y_c = request.security("TVC:US10Y", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 17: DXY — 1 call (total: 17) ──
dxy_c = request.security("TVC:DXY", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 18: HYG Credit ETF — 1 call (total: 18) ──
hyg_c = request.security("AMEX:HYG", "", close, lookahead = barmerge.lookahead_off)

// ── Slot 19: Alternative Sector — 1 call (total: 19) ──
alt_c = request.security(sym_alt, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 20: Sector 5 — 1 call (total: 20) ──
sect5_c = request.security(sym_sect5, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 21: Sector 6 — 1 call (total: 21) ──
sect6_c = request.security(sym_sect6, "", close, lookahead = barmerge.lookahead_off)

// ── Slot 22: Sector 7 — 1 call (total: 22) ──
sect7_c = request.security(sym_sect7, "", close, lookahead = barmerge.lookahead_off)

// ── Market Activity Filter ──────────────────────────────
bool _mkt_active = na(bench_c[1]) or
     bench_c != bench_c[1] or vix_c != vix_c[1] or
     fx_c != fx_c[1] or oil_c != oil_c[1] or
     close != close[1]


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 6: DERIVED DATA & COMPUTED FEEDS
// ══════════════════════════════════════════════════════════════════════════════

// ── FX Stress ROC (normalised so positive = local currency weakening) ──
float _fx_roc1_raw = f_roc(fx_c, 1)
float _fx_roc3_raw = f_roc(fx_c, 3)
float _fx_roc5_raw = f_roc(fx_c, 5)

// Invert for LOCAL/USD pairs (GBPUSD, EURUSD, AUDUSD, DXY for US)
float fx_roc1 = fx_invert ? -_fx_roc1_raw : _fx_roc1_raw
float fx_roc3 = fx_invert ? -_fx_roc3_raw : _fx_roc3_raw
float fx_roc5 = fx_invert ? -_fx_roc5_raw : _fx_roc5_raw

// ── FX Z-Score (in stress direction) ──
float _fx_z_raw = f_zscore(fx_c, i_zLookback)
float fx_z = fx_invert ? -_fx_z_raw : _fx_z_raw

// ── Oil in Local Currency ──
// For USD/LOCAL pairs: oil_local = oil * fx (e.g., oil * USDINR)
// For LOCAL/USD pairs: oil_local = oil / fx (e.g., oil / GBPUSD)
float oil_local = fx_invert ? f_safe_div(oil_c, fx_c) : oil_c * fx_c

// ── Gold in Local Currency ──
float gold_local = fx_invert ? f_safe_div(gold_c, fx_c) : gold_c * fx_c

// ── Sovereign Spread (Local 10Y minus US 10Y) ──
float sov_spread = nz(y10_c) - nz(us10y_c)

// ── Sector Ratios (vs Benchmark) ──
float bank_ratio = f_safe_div(bank_c, bench_c)
float tech_ratio = f_safe_div(tech_c, bench_c)
float small_ratio = f_safe_div(small_c, bench_c)
float alt_ratio = f_safe_div(alt_c, bench_c)

// ── DXY-Adjusted FX Move ──
// How much of the FX move is country-specific vs global dollar strength
float dxy_roc1 = f_roc(dxy_c, 1)
float dxy_adj_fx = fx_roc1 - (fx_invert ? -dxy_roc1 : dxy_roc1)

// ── VIX Ratios ──
float vix_sma20 = ta.sma(vix_c, 20)
float vix_sma50 = ta.sma(vix_c, 50)
float vix_ratio20 = f_safe_div(vix_c, vix_sma20)
float vix_ratio50 = f_safe_div(vix_c, vix_sma50)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 7: MODULE 1 — DOMESTIC EQUITY STRESS (0–20 pts)
// ══════════════════════════════════════════════════════════════════════════════
// Benchmark crash, banking weakness, risk-off rotation, local fear gauge.

// 7.1 Benchmark Z-Score (velocity — sudden crash)
float _m1_bench_z = f_vel_zscore(bench_c, i_zLookback)
float _m1_bench_pts = switch
    _m1_bench_z <= -3.0 => 5.0
    _m1_bench_z <= -2.0 => 3.5
    _m1_bench_z <= -1.5 => 2.0
    _m1_bench_z <= -1.0 => 1.0
    => 0.0

// 7.2 Bank vs Benchmark Ratio (banks underperforming = credit stress)
float _m1_bank_roc = f_roc(bank_ratio, 5)
float _m1_bank_pts = switch
    _m1_bank_roc <= -3.0 => 4.0
    _m1_bank_roc <= -2.0 => 3.0
    _m1_bank_roc <= -1.0 => 1.5
    _m1_bank_roc <= -0.5 => 0.5
    => 0.0

// 7.3 Smallcap vs Benchmark Ratio (risk-off rotation)
float _m1_small_roc = f_roc(small_ratio, 5)
float _m1_small_pts = switch
    _m1_small_roc <= -4.0 => 4.0
    _m1_small_roc <= -2.5 => 3.0
    _m1_small_roc <= -1.5 => 1.5
    _m1_small_roc <= -0.5 => 0.5
    => 0.0

// 7.4 Local VIX Spike
float _m1_vix_pts = switch
    vix_ratio20 >= 1.40 => 4.0
    vix_ratio20 >= 1.25 => 3.0
    vix_ratio20 >= 1.15 => 1.5
    vix_ratio20 >= 1.05 => 0.5
    => 0.0

// 7.5 Sector Breadth (how many sectors falling simultaneously)
float _m1_tech_roc = f_roc(tech_c, 5)
bool _m1_bank_dn = _m1_bank_roc < -0.5 or f_roc(bank_c, 5) < -1.0
bool _m1_tech_dn = _m1_tech_roc < -1.0
bool _m1_small_dn = _m1_small_roc < -0.5 or f_roc(small_c, 5) < -1.5
int _m1_breadth = (_m1_bank_dn ? 1 : 0) + (_m1_tech_dn ? 1 : 0) + (_m1_small_dn ? 1 : 0)
float _m1_breadth_pts = switch _m1_breadth
    3 => 3.0
    2 => 1.5
    1 => 0.5
    => 0.0

float M1_SCORE = math.min(_m1_bench_pts + _m1_bank_pts + _m1_small_pts + _m1_vix_pts + _m1_breadth_pts, 20.0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 8: MODULE 2 — CURRENCY & CAPITAL FLOW (0–20 pts)
// ══════════════════════════════════════════════════════════════════════════════
// Currency depreciation, yield spike, sovereign spread, capital flight.

// 8.1 FX ROC (multi-bar with decay, like WCI's FX module)
// Scale thresholds by EM multiplier (wider bands for volatile EM currencies)
float _fx_thresh1 = 0.6 * em_mult
float _fx_thresh2 = 1.0 * em_mult
float _fx_thresh3 = 1.5 * em_mult

// 1-bar ROC
float _m2_fx1_pts = switch
    fx_roc1 >= _fx_thresh2 => 2.0
    fx_roc1 >= _fx_thresh1 => 1.0
    => 0.0

// 3-bar ROC (× 0.8 decay)
float _m2_fx3_pts = switch
    fx_roc3 >= _fx_thresh3 => 2.0 * 0.8
    fx_roc3 >= _fx_thresh2 => 1.0 * 0.8
    => 0.0

// 5-bar ROC (× 0.6 decay)
float _m2_fx5_pts = switch
    fx_roc5 >= 2.0 * em_mult => 2.0 * 0.6
    fx_roc5 >= 1.5 * em_mult => 1.0 * 0.6
    => 0.0

float _m2_fx_pts = math.min(_m2_fx1_pts + _m2_fx3_pts + _m2_fx5_pts, 6.0)

// 8.2 FX Z-Score (historical context)
float _m2_fxz_pts = switch
    fx_z >= 2.5 => 4.0
    fx_z >= 2.0 => 3.0
    fx_z >= 1.5 => 1.5
    fx_z >= 1.0 => 0.5
    => 0.0

// 8.3 Local 10Y Yield Spike (foreign selling or inflation panic)
float _m2_y10_roc = f_roc(y10_c, 5)
float _m2_yield_pts = switch
    _m2_y10_roc >= 5.0 => 4.0
    _m2_y10_roc >= 3.0 => 2.5
    _m2_y10_roc >= 1.5 => 1.0
    => 0.0

// 8.4 Sovereign Spread Widening (local 10Y - US 10Y expanding)
float _m2_spread_roc = sov_spread - nz(sov_spread[5])
float _m2_spread_pts = switch
    _m2_spread_roc >= 0.30 => 3.0
    _m2_spread_roc >= 0.15 => 1.5
    _m2_spread_roc >= 0.05 => 0.5
    => 0.0

// 8.5 DXY-Adjusted FX Move (India-specific weakness vs just dollar strength)
float _m2_adj_pts = switch
    dxy_adj_fx >= 0.8 => 3.0
    dxy_adj_fx >= 0.4 => 1.5
    dxy_adj_fx >= 0.2 => 0.5
    => 0.0

float M2_SCORE = math.min(_m2_fx_pts + _m2_fxz_pts + _m2_yield_pts + _m2_spread_pts + _m2_adj_pts, 20.0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 9: MODULE 3 — INFLATION & COST OF LIVING (0–15 pts)
// ══════════════════════════════════════════════════════════════════════════════
// Oil in local currency, gold hoarding, food price spike, industrial costs.

// 9.1 Oil in Local Currency Z-Score
float _m3_oil_z = f_zscore(oil_local, i_zLookback)
float _m3_oil_z_pts = switch
    _m3_oil_z >= 2.5 => 4.0
    _m3_oil_z >= 2.0 => 3.0
    _m3_oil_z >= 1.5 => 1.5
    _m3_oil_z >= 1.0 => 0.5
    => 0.0

// 9.2 Oil in Local Currency ROC (5-bar)
float _m3_oil_roc = f_roc(oil_local, 5)
float _m3_oil_roc_pts = switch
    _m3_oil_roc >= 8.0 => 3.0
    _m3_oil_roc >= 5.0 => 2.0
    _m3_oil_roc >= 3.0 => 1.0
    => 0.0

// Oil import amplifier (India imports 85% of oil)
float _m3_oil_pts = is_oil_importer ? math.min(_m3_oil_z_pts + _m3_oil_roc_pts, 7.0) : math.min((_m3_oil_z_pts + _m3_oil_roc_pts) * 0.6, 4.0)

// 9.3 Gold in Local Currency Breakout (domestic hoarding signal)
float _m3_gold_z = f_zscore(gold_local, i_zLookback)
float _m3_gold_pts = switch
    _m3_gold_z >= 2.5 => 3.0
    _m3_gold_z >= 2.0 => 2.0
    _m3_gold_z >= 1.5 => 1.0
    => 0.0

// 9.4 Wheat/Food Commodity Spike
float _m3_wheat_z = f_zscore(wheat_c, i_zLookback)
float _m3_wheat_roc = f_roc(wheat_c, 10)
float _m3_wheat_pts = switch
    _m3_wheat_z >= 2.0 and _m3_wheat_roc >= 5.0 => 3.0
    _m3_wheat_z >= 2.0 => 2.0
    _m3_wheat_z >= 1.5 => 1.0
    _m3_wheat_roc >= 8.0 => 1.5
    => 0.0

// 9.5 Industrial Costs (copper + gas combo)
float _m3_cu_z = f_zscore(copper_c, i_zLookback)
float _m3_gas_z = f_zscore(gas_c, i_zLookback)
float _m3_ind_pts = (math.abs(_m3_cu_z) >= 2.0 ? 1.0 : 0.0) + (_m3_gas_z >= 2.0 ? 1.0 : 0.0)

float M3_SCORE = math.min(_m3_oil_pts + _m3_gold_pts + _m3_wheat_pts + _m3_ind_pts, 15.0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 10: MODULE 4 — SOVEREIGN & CREDIT RISK (0–20 pts)
// ══════════════════════════════════════════════════════════════════════════════
// Government creditworthiness, banking health, default risk signals.

// 10.1 Sovereign Spread Level (how far above historical average)
float _m4_spread_z = f_zscore(sov_spread, i_zLookback)
float _m4_spread_lvl_pts = switch
    _m4_spread_z >= 2.5 => 5.0
    _m4_spread_z >= 2.0 => 3.5
    _m4_spread_z >= 1.5 => 2.0
    _m4_spread_z >= 1.0 => 1.0
    => 0.0

// 10.2 Sovereign Spread ROC (widening velocity)
float _m4_spread_roc5 = sov_spread - nz(sov_spread[5])
float _m4_spread_roc_pts = switch
    _m4_spread_roc5 >= 0.40 => 4.0
    _m4_spread_roc5 >= 0.25 => 2.5
    _m4_spread_roc5 >= 0.10 => 1.0
    => 0.0

// 10.3 Bank Sector Relative Weakness (declining ratio = banking stress)
float _m4_bank_z = f_zscore(bank_ratio, i_zLookback)
float _m4_bank_pts = switch
    _m4_bank_z <= -2.0 => 4.0
    _m4_bank_z <= -1.5 => 2.5
    _m4_bank_z <= -1.0 => 1.0
    => 0.0

// 10.4 HYG Credit Stress (credit ETF declining = risk aversion)
float _m4_hyg_z = f_zscore(hyg_c, i_zLookback)
float _m4_hyg_pts = switch
    _m4_hyg_z <= -2.5 => 4.0
    _m4_hyg_z <= -2.0 => 3.0
    _m4_hyg_z <= -1.5 => 1.5
    _m4_hyg_z <= -1.0 => 0.5
    => 0.0

// 10.5 Correlation Break: Stocks + Bonds Both Falling (liquidity crisis)
float _m4_bench_roc5 = f_roc(bench_c, 5)
float _m4_y10_roc5 = f_roc(y10_c, 5)
// Bonds falling = yields RISING, so y10_roc positive = bond prices falling
// Stocks falling = bench_roc negative
bool _m4_corr_break = _m4_bench_roc5 < -2.0 and _m4_y10_roc5 > 2.0
float _m4_corr_pts = _m4_corr_break ? 3.0 : (_m4_bench_roc5 < -1.0 and _m4_y10_roc5 > 1.0 ? 1.0 : 0.0)

float M4_SCORE = math.min(_m4_spread_lvl_pts + _m4_spread_roc_pts + _m4_bank_pts + _m4_hyg_pts + _m4_corr_pts, 20.0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 11: MODULE 5 — EXTERNAL VULNERABILITY (0–15 pts)
// ══════════════════════════════════════════════════════════════════════════════
// Exposure to global shocks: oil, trade partners, Fed tightening, dollar.

// 11.1 Oil Import Vulnerability
float _m5_oil_z = f_zscore(oil_c, i_zLookback)
float _m5_oil_weight = is_oil_importer ? 1.0 : 0.4
float _m5_oil_pts = switch
    _m5_oil_z >= 2.0 => 4.0 * _m5_oil_weight
    _m5_oil_z >= 1.5 => 2.5 * _m5_oil_weight
    _m5_oil_z >= 1.0 => 1.0 * _m5_oil_weight
    => 0.0

// 11.2 Trade Partner Stress (e.g., Shanghai decline for India)
float _m5_trade_z = f_vel_zscore(trade_c, i_zLookback)
float _m5_trade_pts = switch
    _m5_trade_z <= -2.5 => 3.0
    _m5_trade_z <= -1.5 => 2.0
    _m5_trade_z <= -1.0 => 1.0
    => 0.0

// 11.3 US 10Y ROC (Fed tightening = EM capital outflow)
float _m5_us10y_roc = f_roc(us10y_c, 10)
float _m5_fed_pts = switch
    _m5_us10y_roc >= 8.0 => 3.0
    _m5_us10y_roc >= 5.0 => 2.0
    _m5_us10y_roc >= 3.0 => 1.0
    => 0.0

// 11.4 DXY Strength (strong dollar = capital outflow from EM)
float _m5_dxy_z = f_zscore(dxy_c, i_zLookback)
float _m5_dxy_pts = switch
    _m5_dxy_z >= 2.0 => 3.0
    _m5_dxy_z >= 1.5 => 2.0
    _m5_dxy_z >= 1.0 => 1.0
    => 0.0

// 11.5 Trade Partner FX Stress (e.g., CNY devaluation = competitive threat)
float _m5_tfx_roc = f_roc(tradefx_c, 5)
float _m5_tfx_pts = switch
    math.abs(_m5_tfx_roc) >= 2.0 => 2.0
    math.abs(_m5_tfx_roc) >= 1.0 => 1.0
    => 0.0

float M5_SCORE = math.min(_m5_oil_pts + _m5_trade_pts + _m5_fed_pts + _m5_dxy_pts + _m5_tfx_pts, 15.0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 12: MODULE 6 — POLITICAL & SENTIMENT (0–10 pts)
// ══════════════════════════════════════════════════════════════════════════════
// Event risk pricing, institutional stress, retail panic.

// 12.1 VIX Spike + Market Flat = Event Risk Pricing
float _m6_bench_roc1 = f_roc(bench_c, 1)
bool _m6_event_risk = vix_ratio20 >= 1.15 and math.abs(_m6_bench_roc1) < 0.5
float _m6_event_pts = _m6_event_risk ? 3.0 : (vix_ratio20 >= 1.10 and math.abs(_m6_bench_roc1) < 1.0 ? 1.5 : 0.0)

// 12.2 PSU vs Private Bank Divergence (India-specific: government bank stress)
// alt_ratio = alt_c / bench_c. For India, alt = PSU banks.
// Declining alt_ratio while bank_ratio holds = PSU-specific stress = fiscal signal
float _m6_alt_roc = f_roc(alt_ratio, 10)
float _m6_alt_pts = switch
    _m6_alt_roc <= -5.0 => 2.0
    _m6_alt_roc <= -2.5 => 1.0
    => 0.0

// 12.3 Smallcap Drawdown Depth (retail panic indicator)
float _m6_small_hi52 = ta.highest(small_c, 252)
float _m6_small_dd = _m6_small_hi52 != 0.0 ? (small_c - _m6_small_hi52) / _m6_small_hi52 * 100.0 : 0.0
float _m6_dd_pts = switch
    _m6_small_dd <= -25.0 => 3.0
    _m6_small_dd <= -15.0 => 2.0
    _m6_small_dd <= -8.0  => 1.0
    => 0.0

// 12.4 Sustained VIX Elevation (plateau, not spike — uncertainty regime)
bool _m6_vix_sustained = vix_c > vix_sma20 and vix_c[5] > nz(vix_sma20[5]) and vix_c[10] > nz(ta.sma(vix_c, 20)[10])
float _m6_sustain_pts = _m6_vix_sustained ? 2.0 : (vix_c > vix_sma20 and vix_c[3] > nz(ta.sma(vix_c, 20)[3]) ? 1.0 : 0.0)

float M6_SCORE = math.min(_m6_event_pts + _m6_alt_pts + _m6_dd_pts + _m6_sustain_pts, 10.0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 13: CCI COMPOSITE SCORE + SMOOTHING
// ══════════════════════════════════════════════════════════════════════════════

// ── Convergence Multiplier ──────────────────────────────
int _conv_count = (M1_SCORE > 1.0 ? 1 : 0) + (M2_SCORE > 1.0 ? 1 : 0) +
                  (M3_SCORE > 1.0 ? 1 : 0) + (M4_SCORE > 1.0 ? 1 : 0) +
                  (M5_SCORE > 1.0 ? 1 : 0) + (M6_SCORE > 0.5 ? 1 : 0)

float _conv_boost = switch _conv_count
    6 => 1.50
    5 => 1.35
    4 => 1.25
    3 => 1.15
    => 1.00

float CCI_RAW = math.min((M1_SCORE + M2_SCORE + M3_SCORE + M4_SCORE + M5_SCORE + M6_SCORE) * _conv_boost, 100.0)

// ── Asymmetric Smoothing (fast up α=0.5, slow down α=0.18) ──
var float CCI_SCORE = 0.0
float _sm_alpha = CCI_RAW > nz(CCI_SCORE[1], CCI_RAW) ? 2.0 / 4.0 : 2.0 / 11.0
CCI_SCORE := _sm_alpha * CCI_RAW + (1.0 - _sm_alpha) * nz(CCI_SCORE[1], CCI_RAW)

// ── Threat Level ────────────────────────────────────────
int THREAT_LEVEL = switch
    CCI_SCORE >= i_cciL4 => 4
    CCI_SCORE >= i_cciL3 => 3
    CCI_SCORE >= i_cciL2 => 2
    CCI_SCORE >= i_cciL1 => 1
    => 0

string LVL_NAME = switch THREAT_LEVEL
    4 => "CRISIS"
    3 => "DANGER"
    2 => "WARNING"
    1 => "ALERT"
    => "CALM"

// ── Stage Direction ─────────────────────────────────────
float _trend_smooth = ta.sma(CCI_RAW, 3)
float _trend_delta = _trend_smooth - nz(_trend_smooth[3], _trend_smooth)

string STAGE_DIR = switch
    _trend_delta >= 8.0                                => "SURGING"
    _trend_delta >= 4.0                                => "RISING"
    _trend_delta <= -8.0                               => "RETREATING"
    _trend_delta <= -4.0                               => "COOLING"
    THREAT_LEVEL >= 3 and math.abs(_trend_delta) < 2.0 => "ELEVATED"
    => "STEADY"


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 14: DOMINANT MODULE & CLASSIFICATION
// ══════════════════════════════════════════════════════════════════════════════

// Per-module tags
string _tag_m1 = "Equity"
string _tag_m2 = "Currency"
string _tag_m3 = "Inflation"
string _tag_m4 = "Sovereign"
string _tag_m5 = "External"
string _tag_m6 = "Political"

string _lbl_m1 = "Equity Stress"
string _lbl_m2 = "Currency Flight"
string _lbl_m3 = "Inflation Shock"
string _lbl_m4 = "Sovereign Risk"
string _lbl_m5 = "External Shock"
string _lbl_m6 = "Political Risk"

// Find top score
float _dom_max = math.max(M1_SCORE, math.max(M2_SCORE, math.max(M3_SCORE, math.max(M4_SCORE, math.max(M5_SCORE, M6_SCORE)))))
float _act_thresh = _dom_max * 0.25

// Active modules
bool _m1_act = M1_SCORE >= _act_thresh and M1_SCORE > 0
bool _m2_act = M2_SCORE >= _act_thresh and M2_SCORE > 0
bool _m3_act = M3_SCORE >= _act_thresh and M3_SCORE > 0
bool _m4_act = M4_SCORE >= _act_thresh and M4_SCORE > 0
bool _m5_act = M5_SCORE >= _act_thresh and M5_SCORE > 0
bool _m6_act = M6_SCORE >= _act_thresh and M6_SCORE > 0
int _act_count = (_m1_act ? 1 : 0) + (_m2_act ? 1 : 0) + (_m3_act ? 1 : 0) +
                 (_m4_act ? 1 : 0) + (_m5_act ? 1 : 0) + (_m6_act ? 1 : 0)

// Dominant module name
string DOM_SHORT = switch
    _dom_max <= 0.0      => "—"
    _dom_max == M1_SCORE => "M1 Equity"
    _dom_max == M2_SCORE => "M2 Currency"
    _dom_max == M3_SCORE => "M3 Inflation"
    _dom_max == M4_SCORE => "M4 Sovereign"
    _dom_max == M5_SCORE => "M5 External"
    _dom_max == M6_SCORE => "M6 Political"
    => "—"

string DOM_LABEL = switch
    _dom_max <= 0.0      => ""
    _dom_max == M1_SCORE => _lbl_m1
    _dom_max == M2_SCORE => _lbl_m2
    _dom_max == M3_SCORE => _lbl_m3
    _dom_max == M4_SCORE => _lbl_m4
    _dom_max == M5_SCORE => _lbl_m5
    _dom_max == M6_SCORE => _lbl_m6
    => ""

string DOM_SCORE_TXT = switch
    _dom_max <= 0.0      => ""
    _dom_max == M1_SCORE => f_pts_str(M1_SCORE, 20)
    _dom_max == M2_SCORE => f_pts_str(M2_SCORE, 20)
    _dom_max == M3_SCORE => f_pts_str(M3_SCORE, 15)
    _dom_max == M4_SCORE => f_pts_str(M4_SCORE, 20)
    _dom_max == M5_SCORE => f_pts_str(M5_SCORE, 15)
    _dom_max == M6_SCORE => f_pts_str(M6_SCORE, 10)
    => ""

// Breadth tag
string BREADTH_TAG = switch
    _act_count >= 5 => " [SYSTEMIC]"
    _act_count >= 4 => " [BROAD]"
    _act_count >= 3 => " [" + str.tostring(_act_count) + "/6]"
    => ""

// ── Feed-Level Detection (52-week levels for driver tags) ──
float _oil_hi52  = ta.highest(oil_c, 252)
float _oil_lo52  = ta.lowest(oil_c, 252)
string _oil_lvl  = not na(oil_c) ? (oil_c >= _oil_hi52 * 0.99 ? "52H" : oil_c <= _oil_lo52 * 1.01 ? "52L" : "") : ""

float _gold_hi52 = ta.highest(gold_c, 252)
string _gold_lvl = not na(gold_c) ? (gold_c >= _gold_hi52 * 0.99 ? "52H" : "") : ""

float _vix_hi52  = ta.highest(vix_c, 252)
string _vix_lvl  = not na(vix_c) ? (vix_c >= _vix_hi52 * 0.95 ? "52H" : "") : ""

float _wh_hi52   = ta.highest(wheat_c, 252)
string _wh_lvl   = not na(wheat_c) ? (wheat_c >= _wh_hi52 * 0.99 ? "52H" : "") : ""

// ── Driver Tags (feed abbreviations with levels) ──
string _drv_bank = _m1_bank_pts >= 1.5 ? " · " + bank_label + "↓" : ""
string _drv_small = _m1_small_pts >= 1.5 ? " · " + small_label + "↓" : ""
string _drv_fx = _m2_fx_pts >= 2.0 ? " · " + fx_label + "↓" : ""
string _drv_oil = _m3_oil_pts >= 2.0 ? " · Oil" + (_oil_lvl != "" ? "(" + _oil_lvl + ")" : "") : (_oil_lvl != "" ? " · Oil(" + _oil_lvl + ")" : "")
string _drv_gold = _m3_gold_pts >= 1.0 ? " · Gold" + (_gold_lvl != "" ? "(" + _gold_lvl + ")" : "") : (_gold_lvl != "" ? " · Gold(" + _gold_lvl + ")" : "")
string _drv_vix = _m1_vix_pts >= 1.5 ? " · VIX" + (_vix_lvl != "" ? "(" + _vix_lvl + ")" : "") : (_vix_lvl != "" ? " · VIX(" + _vix_lvl + ")" : "")
string _drv_spread = _m4_spread_lvl_pts >= 2.0 ? " · Spread↑" : ""
string _drv_hyg = _m4_hyg_pts >= 1.5 ? " · HYG↓" : ""
string _drv_wheat = _m3_wheat_pts >= 1.0 ? " · Wheat" + (_wh_lvl != "" ? "(" + _wh_lvl + ")" : "") : ""
string DRIVER_TAGS = _drv_bank + _drv_small + _drv_fx + _drv_oil + _drv_gold + _drv_vix + _drv_spread + _drv_hyg + _drv_wheat
// Clean leading " · "
string DRIVER_TAGS_CLEAN = str.startswith(DRIVER_TAGS, " · ") ? str.substring(DRIVER_TAGS, 3) : DRIVER_TAGS


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 15: EXPOSURE ENGINE (simplified)
// ══════════════════════════════════════════════════════════════════════════════

// Base exposure from CCI score
float _exp_base = switch
    CCI_SCORE >= 85 => 5.0
    CCI_SCORE >= 70 => 15.0
    CCI_SCORE >= 55 => 30.0
    CCI_SCORE >= 40 => 50.0
    CCI_SCORE >= 25 => 70.0
    CCI_SCORE >= 15 => 85.0
    => 100.0

// Risk appetite shift
float _exp_shift = switch i_riskTolerance
    "Conservative" => -10.0
    "Aggressive"   => 10.0
    => 0.0

float EXPOSURE_PCT = math.max(5.0, math.min(100.0, _exp_base + _exp_shift))

// Exposure text + direction
string EXPOSURE_TEXT = str.tostring(math.round(EXPOSURE_PCT)) + "%"
string EXPOSURE_DIR = EXPOSURE_PCT > nz(EXPOSURE_PCT[1], EXPOSURE_PCT) + 1 ? "EXPANDING" :
     EXPOSURE_PCT < nz(EXPOSURE_PCT[1], EXPOSURE_PCT) - 1 ? "CONTRACTING" : "STABLE"

// Stage number (maps direction to integer for JSON)
int STAGE_NUM = switch STAGE_DIR
    "SURGING"    => 4
    "RISING"     => 3
    "FLAT"       => 2
    "COOLING"    => 1
    "RETREATING" => 0
    => 2

// ── Action Signal ───────────────────────────────────────
string ACTION_SIG = switch
    CCI_SCORE >= 80 => "EXIT ALL"
    CCI_SCORE >= 65 => "REDUCE"
    CCI_SCORE >= 50 => "HEDGE"
    CCI_SCORE >= 35 => "CAUTIOUS"
    CCI_SCORE >= 20 => "SELECTIVE"
    => "DEPLOY"


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 16: MOOD TEXT — INDIA-SPECIFIC EDITORIAL
// ══════════════════════════════════════════════════════════════════════════════
// Compositional mood: [observation] + [reaction] + optional [insight]
// Observation = what is happening (single/dual/broad/systemic).
// Reaction = so what (threat level × trend group × timeframe).
// Both halves rotate independently via bar_index modulo.
// Structure mirrors WCI: driver-indexed obs, pair-indexed duals, trend-aware reactions.

int _rot_a = bar_index % 5
int _rot_b = (bar_index + 2) % 5

// -- Mood: Trend grouping (0=UP, 1=FLAT, 2=DOWN) --
int _mood_tgrp = switch STAGE_DIR
    "SURGING"    => 0
    "RISING"     => 0
    "COOLING"    => 2
    "RETREATING" => 2
    => 1

// -- Mood: Driver index (0=M1..5=M6) --
int _mood_drv = switch
    _dom_max == M1_SCORE => 0
    _dom_max == M2_SCORE => 1
    _dom_max == M3_SCORE => 2
    _dom_max == M4_SCORE => 3
    _dom_max == M5_SCORE => 4
    => 5

// -- Mood: Dual pair ID (0-14, for C(6,2)=15 pairs) --
int _mood_pair = switch
    _m1_act and _m2_act => 0
    _m1_act and _m3_act => 1
    _m1_act and _m4_act => 2
    _m1_act and _m5_act => 3
    _m1_act and _m6_act => 4
    _m2_act and _m3_act => 5
    _m2_act and _m4_act => 6
    _m2_act and _m5_act => 7
    _m2_act and _m6_act => 8
    _m3_act and _m4_act => 9
    _m3_act and _m5_act => 10
    _m3_act and _m6_act => 11
    _m4_act and _m5_act => 12
    _m4_act and _m6_act => 13
    => 14

// ── Mood Observation Builder Functions ──────────────────
// Single: 6 drivers × 5 rotations = 30 sentences
// Dual: 15 pairs × 5 rotations = 75 sentences
// Broad: 6 drivers × 5 rotations = 30 sentences
// Systemic: 6 drivers × 5 rotations = 30 sentences

f_init_obs_single(array<string> a) =>
    // M1 Equity (driver 0, idx 0-4)
    array.push(a, "Local equities taking heat, benchmark sliding.")
    array.push(a, "Bank index underperforming, credit concerns surfacing.")
    array.push(a, "Smallcaps bleeding while large caps hold, risk-off rotation live.")
    array.push(a, "Sector breadth narrowing, fewer names holding up the index.")
    array.push(a, "Benchmark velocity z-score flagging unusual selling pressure.")
    // M2 Currency (driver 1, idx 5-9)
    array.push(a, "Rupee under pressure, capital outflow signal building.")
    array.push(a, "Currency weakening beyond what the dollar explains.")
    array.push(a, "Bond yields spiking, foreign investors heading for the exit.")
    array.push(a, "Sovereign spread widening, country risk premium rising.")
    array.push(a, "Multi-day currency slide picking up momentum.")
    // M3 Inflation (driver 2, idx 10-14)
    array.push(a, "Oil in local currency terms hitting uncomfortable levels.")
    array.push(a, "Gold hoarding signal, domestic investors hedging inflation.")
    array.push(a, "Food commodity prices elevated, cost of living pressure real.")
    array.push(a, "Import bill climbing as both oil and currency work against us.")
    array.push(a, "Inflation proxy rising while currency weakens, double squeeze.")
    // M4 Sovereign (driver 3, idx 15-19)
    array.push(a, "Sovereign credit spread flashing wider, risk premium climbing.")
    array.push(a, "Banks underperforming the market, institutional stress visible.")
    array.push(a, "Credit markets tightening alongside equity weakness.")
    array.push(a, "Bonds and stocks falling together, liquidity starting to crack.")
    array.push(a, "Yield curve stress building, the bond market is not comfortable.")
    // M5 External (driver 4, idx 20-24)
    array.push(a, "Global headwinds hitting through trade and commodity channels.")
    array.push(a, "Trade partner slowdown spilling over, export outlook dimming.")
    array.push(a, "Fed tightening pulling capital, emerging markets under pressure.")
    array.push(a, "Dollar strength creating capital flight conditions.")
    array.push(a, "External vulnerability score elevated, multiple channels active.")
    // M6 Sentiment (driver 5, idx 25-29)
    array.push(a, "VIX elevated with the market barely moving, event risk being priced.")
    array.push(a, "Smallcap drawdown deepening, retail sentiment collapsing.")
    array.push(a, "PSU-private divergence widening, political risk creeping into markets.")
    array.push(a, "Sustained VIX elevation, the kind that precedes regime shifts.")
    array.push(a, "Sentiment indicators flashing distress before the price confirms it.")

f_init_obs_dual(array<string> a) =>
    // Pair 0: M1+M2 Equity+Currency (idx 0-4)
    array.push(a, "Equities down and currency weakening, classic EM stress pattern.")
    array.push(a, "Banks leading the decline while rupee slides, credit and FX together.")
    array.push(a, "Benchmark falling as capital exits, equity and FX confirming each other.")
    array.push(a, "Stocks weak and rupee under pressure, the twin-deficit fear trade.")
    array.push(a, "Equity sell-off with currency flight, FIIs heading for the door.")
    // Pair 1: M1+M3 Equity+Inflation (idx 5-9)
    array.push(a, "Equity crash with oil-in-rupee terms at uncomfortable highs.")
    array.push(a, "Inflation pressure meeting equity weakness, stagflation flavour.")
    array.push(a, "Stocks falling while input costs rise, margin squeeze hitting corporates.")
    array.push(a, "Benchmark dropping and commodity costs climbing, growth-inflation trap.")
    array.push(a, "Equities weak and cost-of-living surging, consumer spending at risk.")
    // Pair 2: M1+M4 Equity+Sovereign (idx 10-14)
    array.push(a, "Stocks falling and bonds selling off too, nowhere to hide locally.")
    array.push(a, "Equity weakness confirmed by sovereign spread widening, risk premium rising.")
    array.push(a, "Banking stress in equities meeting credit risk in bonds, financial system under watch.")
    array.push(a, "Stock market distress alongside sovereign deterioration, institutional capital nervous.")
    array.push(a, "Equities and credit both flashing, the kind that makes FIIs reassess allocation.")
    // Pair 3: M1+M5 Equity+External (idx 15-19)
    array.push(a, "External shock hitting while domestic equities already stressed.")
    array.push(a, "Trade partner stress coinciding with domestic equity weakness.")
    array.push(a, "Global headwinds amplifying local equity sell-off, correlation spike.")
    array.push(a, "Dollar surge pulling capital while benchmark slides, external meets domestic.")
    array.push(a, "Equity weakness with trade channel stress, export-sensitive sectors at risk.")
    // Pair 4: M1+M6 Equity+Sentiment (idx 20-24)
    array.push(a, "Smallcap massacre alongside VIX spike, retail and institutional both running.")
    array.push(a, "Benchmark falling while sentiment collapses, fear feeding on itself.")
    array.push(a, "Equity breadth collapsing with event risk elevated, markets pricing the worst.")
    array.push(a, "Stock slide and VIX divergence, the market expects more downside than it shows.")
    array.push(a, "Equity weakness confirmed by sentiment breakdown, no bottom-fishing signal yet.")
    // Pair 5: M2+M3 Currency+Inflation (idx 25-29)
    array.push(a, "Oil spike hitting an already weak currency, import cost explosion.")
    array.push(a, "Currency sliding while commodities surge, the current account nightmare.")
    array.push(a, "Rupee weakness meeting inflation pressure, RBI in an impossible position.")
    array.push(a, "Food and energy costs rising in local terms, real income getting crushed.")
    array.push(a, "FX depreciation amplifying imported inflation, the EM cost-of-living trap.")
    // Pair 6: M2+M4 Currency+Sovereign (idx 30-34)
    array.push(a, "Currency flight meeting sovereign spread widening, capital leaving the country.")
    array.push(a, "Rupee and sovereign risk both flashing, bond market pricing fiscal concern.")
    array.push(a, "FX weakness with credit risk rising, the combination that triggers rating reviews.")
    array.push(a, "Currency under pressure and sovereign spreads moving, external debt burden growing.")
    array.push(a, "Capital account stress meeting fiscal risk, policy credibility on the line.")
    // Pair 7: M2+M5 Currency+External (idx 35-39)
    array.push(a, "Dollar surge and local currency weakness, double capital outflow.")
    array.push(a, "Fed tightening meeting rupee slide, classic emerging market squeeze.")
    array.push(a, "External vulnerability hitting the currency, FX reserves under watch.")
    array.push(a, "Trade partner slowdown with currency flight, export and capital both at risk.")
    array.push(a, "DXY strength with EM FX weakness, global dollar shortage hurting us.")
    // Pair 8: M2+M6 Currency+Sentiment (idx 40-44)
    array.push(a, "Currency sliding while VIX signals event risk, markets bracing for a policy shock.")
    array.push(a, "Rupee weakness with sentiment collapsing, FII and retail both losing confidence.")
    array.push(a, "FX under pressure and sentiment deteriorating, the kind that feeds on itself.")
    array.push(a, "Currency stress meeting political uncertainty, markets hate the combination.")
    array.push(a, "Sustained rupee slide with elevated fear gauge, intervention expectations building.")
    // Pair 9: M3+M4 Inflation+Sovereign (idx 45-49)
    array.push(a, "Banking stress plus inflation, the worst combination for monetary policy.")
    array.push(a, "Inflation surging while sovereign risk climbs, fiscal space shrinking.")
    array.push(a, "Cost-of-living crisis meeting credit deterioration, growth outlook darkening.")
    array.push(a, "Commodity inflation with sovereign spread widening, RBI trapped between growth and stability.")
    array.push(a, "Bond market stress and inflation both elevated, the stagflation cocktail.")
    // Pair 10: M3+M5 Inflation+External (idx 50-54)
    array.push(a, "Commodity prices surging while external channels flash, terms of trade shock.")
    array.push(a, "Oil and dollar both rising, the double import cost hit for India.")
    array.push(a, "Global inflation transmission meeting external vulnerability, no domestic shelter.")
    array.push(a, "Trade partner stress with commodity inflation, export weakness meets cost surge.")
    array.push(a, "External shock amplifying imported inflation, policy tools losing effectiveness.")
    // Pair 11: M3+M6 Inflation+Sentiment (idx 55-59)
    array.push(a, "Inflation biting while sentiment collapses, consumer confidence cratering.")
    array.push(a, "Cost-of-living surge with fear gauge elevated, household budgets under assault.")
    array.push(a, "Rising prices meeting political uncertainty, the combination that changes elections.")
    array.push(a, "Inflation pressure and VIX spiking, markets expecting policy intervention.")
    array.push(a, "Food-energy squeeze with retail sentiment breakdown, ground-level stress visible.")
    // Pair 12: M4+M5 Sovereign+External (idx 60-64)
    array.push(a, "Sovereign risk rising with external pressure, the rating downgrade scenario.")
    array.push(a, "Credit deterioration meeting global headwinds, institutional capital repositioning.")
    array.push(a, "External vulnerability confirmed by sovereign spread widening, country risk premium jump.")
    array.push(a, "Fed squeeze meeting local credit stress, the emerging market funding crisis pattern.")
    array.push(a, "DXY strength with sovereign risk, dollar-denominated debt becoming expensive.")
    // Pair 13: M4+M6 Sovereign+Sentiment (idx 65-69)
    array.push(a, "Sovereign risk rising while equity market sends distress signals.")
    array.push(a, "Credit stress and VIX both elevated, institutional and retail fear aligned.")
    array.push(a, "Bond market deterioration with sentiment collapse, no safe haven domestically.")
    array.push(a, "Sovereign spread widening meets political uncertainty, markets pricing regime risk.")
    array.push(a, "Credit and sentiment both flashing, the kind of confluence that triggers rating agency calls.")
    // Pair 14: M5+M6 External+Sentiment (idx 70-74)
    array.push(a, "External vulnerability confirmed by domestic sentiment breakdown.")
    array.push(a, "Global headwinds meeting local fear, the contagion channel is open.")
    array.push(a, "Trade stress with VIX elevated, external shock amplified by domestic panic.")
    array.push(a, "Dollar strength and sentiment collapse, capital leaving on two legs.")
    array.push(a, "External pressure meeting event risk, the market is pricing in something we have not seen yet.")

f_init_obs_broad(array<string> a) =>
    // Driver 0: M1 Equity leading (idx 0-4)
    array.push(a, "Equity shock at the centre of a widening domestic crisis.")
    array.push(a, "Benchmark collapse dragging banks, currency, and sentiment with it.")
    array.push(a, "Stock market leading a three-front meltdown, contagion spreading.")
    array.push(a, "Equities the trigger, but currency and credit now confirming broader stress.")
    array.push(a, "Equity-led crisis broadening across asset classes, breadth collapsing everywhere.")
    // Driver 1: M2 Currency leading (idx 5-9)
    array.push(a, "Currency leading a three-front situation, banks and inflation following.")
    array.push(a, "Rupee weakness cascading into equities and sovereign risk, FX the epicentre.")
    array.push(a, "Capital flight driving a multi-front deterioration, FX reserves under pressure.")
    array.push(a, "Currency crisis broadening, equity and bond markets both catching the fever.")
    array.push(a, "FX the first domino, now equities and credit falling in sequence.")
    // Driver 2: M3 Inflation leading (idx 10-14)
    array.push(a, "Inflation pressure with currency and equity stress, policy credibility test.")
    array.push(a, "Cost-of-living crisis radiating into markets, broad-based pain.")
    array.push(a, "Oil-rupee-equity triangle active, every hedge is expensive here.")
    array.push(a, "Commodity shock hitting currency and equities, the import-dependent economy trap.")
    array.push(a, "Inflation-led crisis, the kind that forces RBI to choose between growth and stability.")
    // Driver 3: M4 Sovereign leading (idx 15-19)
    array.push(a, "Sovereign risk at the core, equity and currency stress following.")
    array.push(a, "Credit deterioration driving a broad crisis, bond market leading the fear.")
    array.push(a, "Banking system stress radiating outward, equity and FX catching the contagion.")
    array.push(a, "Sovereign spread at crisis levels, markets questioning fiscal sustainability.")
    array.push(a, "Credit-led deterioration broadening, no domestic asset class safe.")
    // Driver 4: M5 External leading (idx 20-24)
    array.push(a, "External shock cascading into currency and sovereign risk channels.")
    array.push(a, "Global headwinds creating a multi-front domestic crisis.")
    array.push(a, "Dollar-Fed squeeze hitting equity, FX, and credit simultaneously.")
    array.push(a, "Trade channel stress broadening into a full domestic crisis pattern.")
    array.push(a, "External vulnerability turning into broad domestic contagion.")
    // Driver 5: M6 Sentiment leading (idx 25-29)
    array.push(a, "Sentiment collapse broadening into equities and currency, fear is contagious.")
    array.push(a, "VIX-led crisis expanding, event risk now hitting real asset prices.")
    array.push(a, "Political uncertainty cascading across markets, broad-based risk-off.")
    array.push(a, "Sentiment the epicentre, but equities and currency confirming the fear is real.")
    array.push(a, "Domestic panic spreading across three fronts, the self-fulfilling crisis.")

f_init_obs_sys(array<string> a) =>
    // Driver 0: M1 Equity leading (idx 0-4)
    array.push(a, "Full-spectrum country crisis. Equities leading the collapse across every module.")
    array.push(a, "Systemic breakdown led by equity markets. Every asset class confirming.")
    array.push(a, "This is not a correction. Equity-led country crisis, all modules firing.")
    array.push(a, "Complete equity meltdown radiating into FX, bonds, and commodities.")
    array.push(a, "Stock market seizure triggering systemic contagion, central bank intervention territory.")
    // Driver 1: M2 Currency leading (idx 5-9)
    array.push(a, "Currency collapse driving full systemic crisis. Every module in the red.")
    array.push(a, "Rupee in free-fall, equity crash, sovereign stress, inflation spike. All connected.")
    array.push(a, "FX crisis cascading everywhere. This is the scenario that triggers emergency meetings.")
    array.push(a, "Currency-led systemic event. Balance of payments crisis territory.")
    array.push(a, "Complete FX-driven meltdown. Every domestic asset repricing simultaneously.")
    // Driver 2: M3 Inflation leading (idx 10-14)
    array.push(a, "Inflation shock driving full systemic crisis. Stagflation confirmed.")
    array.push(a, "Cost explosion across all channels. Currency, equities, credit all breaking together.")
    array.push(a, "Commodity-inflation crisis going systemic. Real economy and financial economy both seizing.")
    array.push(a, "Inflation the trigger for a complete market breakdown. Policy toolkit exhausted.")
    array.push(a, "Full inflation-driven crisis. Every module confirming the cost-of-living catastrophe.")
    // Driver 3: M4 Sovereign leading (idx 15-19)
    array.push(a, "Sovereign credit crisis going systemic. Government borrowing costs at emergency levels.")
    array.push(a, "Banking system at the centre of a full country crisis. Every asset class in distress.")
    array.push(a, "Credit markets seizing, dragging everything else down. Liquidity crisis.")
    array.push(a, "Sovereign-led systemic event. Rating downgrade is not a risk, it is a certainty.")
    array.push(a, "Complete credit market breakdown. Equity, FX, inflation all confirming the severity.")
    // Driver 4: M5 External leading (idx 20-24)
    array.push(a, "External shock triggering full domestic systemic event. No decoupling.")
    array.push(a, "Global crisis transmission at maximum. Every domestic channel overwhelmed.")
    array.push(a, "Dollar-Fed-trade triple whammy creating a full country crisis. Historic stress levels.")
    array.push(a, "External forces driving a systemic breakdown. Domestic policy cannot offset this.")
    array.push(a, "Full external contagion. Currency, equities, bonds, inflation all in crisis simultaneously.")
    // Driver 5: M6 Sentiment leading (idx 25-29)
    array.push(a, "Sentiment collapse driving full systemic crisis. Panic is the dominant force.")
    array.push(a, "Fear-driven meltdown across every module. Markets in total capitulation.")
    array.push(a, "Political crisis cascading into full economic crisis. Every metric at extremes.")
    array.push(a, "VIX-led systemic event. The kind of panic that creates its own economic damage.")
    array.push(a, "Complete sentiment-driven crisis. Self-fulfilling prophecy in real time.")


// ── Mood Reaction Builder Functions (3 timeframes) ──────
// Structure: 5 levels × 3 trend groups (rising/flat/cooling) × 5 rotations = 75 per timeframe
// Index: THREAT_LEVEL * 15 + _mood_tgrp * 5 + _rot_b

f_init_rct_daily(array<string> a) =>
    // L0 CALM + Rising
    array.push(a, "All domestic gauges quiet. Steady as she goes.")
    array.push(a, "Nothing on the country radar. Normal positioning.")
    array.push(a, "Country risk flat. Focus on stock-picking, not macro.")
    array.push(a, "Clean domestic backdrop. Let winners run.")
    array.push(a, "No country-level stress. Business as usual.")
    // L0 CALM + Flat
    array.push(a, "Full send. Enjoy the quiet domestic backdrop.")
    array.push(a, "The boring country risk reading is the profitable one.")
    array.push(a, "Nothing to see domestically. That IS the good news.")
    array.push(a, "Zero stress across the board. Harvest the calm.")
    array.push(a, "Country risk dead flat. Build positions, not hedges.")
    // L0 CALM + Cooling
    array.push(a, "Whatever that was, it is packing up. Carry on.")
    array.push(a, "Scare is over. Back to business.")
    array.push(a, "Yesterday headline, today footnote. Risk fading fast.")
    array.push(a, "All dressed up for trouble that never arrived.")
    array.push(a, "The cloud passed. Full speed ahead.")
    // L1 ALERT + Rising
    array.push(a, "Something twitching domestically. Tighten stops, nothing dramatic.")
    array.push(a, "Early warning, not action. Watch the next few sessions.")
    array.push(a, "Mild country stress, keep an eye on the rupee and banks.")
    array.push(a, "First cracks showing. Not panic, but not ignore either.")
    array.push(a, "Country risk rising from zero. Note it, do not react yet.")
    // L1 ALERT + Flat
    array.push(a, "Lingering but contained. Manageable for now.")
    array.push(a, "A dull ache that will not quit. Keep watching.")
    array.push(a, "Hanging around like a guest who will not leave.")
    array.push(a, "Not growing, not going. Patience.")
    array.push(a, "Persistent but not escalating. Watch the signal row.")
    // L1 ALERT + Cooling
    array.push(a, "Was worse, now easing. Glance over your shoulder.")
    array.push(a, "Temperature dropping. Jacket can come off soon.")
    array.push(a, "Whatever spooked the market is losing interest.")
    array.push(a, "Fading back toward normal. Almost there.")
    array.push(a, "Gone as fast as it came. Back to business.")
    // L2 WARNING + Rising
    array.push(a, "This is accelerating. Check signal row now.")
    array.push(a, "Real and getting realer. Defensive posture.")
    array.push(a, "This has momentum. Do not fight it, hedge it.")
    array.push(a, "Not a drill. The numbers are speaking clearly.")
    array.push(a, "The train is moving. Decide now, not later.")
    // L2 WARNING + Flat
    array.push(a, "Stuck in the mud. Nothing resolving.")
    array.push(a, "Going nowhere fast. Patience is the only trade.")
    array.push(a, "Frozen, nothing resolving. Wait for a break.")
    array.push(a, "Market holding its breath. So should you.")
    array.push(a, "Gridlocked. Wait until this breaks one way.")
    // L2 WARNING + Cooling
    array.push(a, "Past the peak, maybe. Do not rush.")
    array.push(a, "Easing off but not over. Stay cautious.")
    array.push(a, "Worst may be done, MAY. Let it prove itself.")
    array.push(a, "Cooling, not cold. Patience still needed.")
    array.push(a, "Do not rush back in. Let it cool properly.")
    // L3 DANGER + Rising
    array.push(a, "Serious and getting worse. Full defence mode.")
    array.push(a, "This has real teeth. Protect what you have.")
    array.push(a, "Capital preservation is the only priority now.")
    array.push(a, "Markets in freefall. Survival first, strategy later.")
    array.push(a, "The only chapter right now is preservation.")
    // L3 DANGER + Flat
    array.push(a, "Grinding pain across the board. No heroes here.")
    array.push(a, "Locked at dangerous levels. No bottom-fishing.")
    array.push(a, "Sustained destruction. The hardest thing is doing nothing.")
    array.push(a, "The market is not crashing, it is living here now.")
    array.push(a, "Running a marathon of pain. Endurance test.")
    // L3 DANGER + Cooling
    array.push(a, "Peak fear may have passed. Do not trust it yet.")
    array.push(a, "Fever breaking, maybe. The ICU is not the lobby.")
    array.push(a, "Coming down from serious heat. Do not sprint back.")
    array.push(a, "First signs of easing. Trust, but verify.")
    array.push(a, "Storm losing intensity. Stay locked down anyway.")
    // L4 CRISIS + Rising
    array.push(a, "Preserve everything. Nothing is worth the risk.")
    array.push(a, "The kind of event that gets a Wikipedia page.")
    array.push(a, "No playbook exists. Patience and time.")
    array.push(a, "Historic territory. Survival is the strategy.")
    array.push(a, "Your only job: be around when markets recover.")
    // L4 CRISIS + Flat
    array.push(a, "Peak destruction on pause. Not better, not worse.")
    array.push(a, "The world holding its breath. Stay flat.")
    array.push(a, "Unprecedented territory. Caution above all.")
    array.push(a, "Endurance test at the extremes. Survival mode.")
    array.push(a, "Off the map. Wait for dawn.")
    // L4 CRISIS + Cooling
    array.push(a, "The longest recovery starts here. Walk, do not run.")
    array.push(a, "Dawn after the longest night. Walk, do not sprint.")
    array.push(a, "The bottom may be in. Give it weeks to confirm.")
    array.push(a, "Normal is being redefined. Stay patient.")
    array.push(a, "Extreme is breaking. Rebuild gently.")

f_init_rct_intra(array<string> a) =>
    // L0 CALM + Rising
    array.push(a, "Clean tape. Ride your setup, trail the stop.")
    array.push(a, "No stress signals. Let momentum do the work.")
    array.push(a, "Zero heat. Full size, ride it.")
    array.push(a, "All clear. The trend is yours this session.")
    array.push(a, "Nothing on the radar. Push the winners.")
    // L0 CALM + Flat
    array.push(a, "Session calm. Domestic flows normal, trade your setup.")
    array.push(a, "No intraday country stress. Clean tape for scalping.")
    array.push(a, "All quiet on the domestic front. Normal session mechanics.")
    array.push(a, "No local macro disruption. Focus on price action.")
    array.push(a, "Domestic gauges flat. Trade the chart, not the news.")
    // L0 CALM + Cooling
    array.push(a, "Session stress fading. Resume normal positioning.")
    array.push(a, "Intraday panic was a false start. Carry on.")
    array.push(a, "Session normalising. Whatever that was, it is over.")
    array.push(a, "Back to clean tape. Fear was priced, now unwinding.")
    array.push(a, "Intraday noise clearing. Trade the levels.")
    // L1 ALERT + Rising
    array.push(a, "Mild session stress. Keep stops tight, watch FII flow.")
    array.push(a, "Something moving this session. Not alarm but note it.")
    array.push(a, "Intraday twitch in country risk. Reduce size, stay nimble.")
    array.push(a, "Session building some domestic heat. Trade smaller.")
    array.push(a, "Early session stress. Do not chase, let it come to you.")
    // L1 ALERT + Flat
    array.push(a, "Session stuck in mild alert. Smaller size, wider stops.")
    array.push(a, "Intraday country risk lingering. Not scary, just present.")
    array.push(a, "Session on low simmer. Be aware, not afraid.")
    array.push(a, "Persistent mild stress this session. Manage, do not panic.")
    array.push(a, "Session holding alert level. Nothing to do but wait.")
    // L1 ALERT + Cooling
    array.push(a, "Session stress fading. Normal size returning.")
    array.push(a, "Intraday scare passing. Resume normal operations.")
    array.push(a, "Session calming down. Stops can loosen.")
    array.push(a, "Country risk backing off this session. Good sign.")
    array.push(a, "Intraday alert dissolving. Back to tape reading.")
    // L2 WARNING + Rising
    array.push(a, "Session getting spicy. Hedge your intraday longs now.")
    array.push(a, "Intraday stress rising. Flatten discretionary, keep hedges.")
    array.push(a, "Country risk building this session. Close weak positions.")
    array.push(a, "Mid-session stress. Take profits on anything extended.")
    array.push(a, "Intraday warning level. Not the session for hero trades.")
    // L2 WARNING + Flat
    array.push(a, "Session stuck in warning territory. Patience, not panic.")
    array.push(a, "Intraday stress plateaued. Hold hedges, wait for direction.")
    array.push(a, "Session grinding at warning level. No new longs.")
    array.push(a, "Stuck in the intraday mud. Wait for the break.")
    array.push(a, "Session warning holding. Discipline over conviction.")
    // L2 WARNING + Cooling
    array.push(a, "Session stress easing. Do not rush to add back.")
    array.push(a, "Intraday peak may be in. Let it confirm.")
    array.push(a, "Session cooling off. Slowly, carefully rebuild.")
    array.push(a, "Warning fading intraday. Take the gift, stay cautious.")
    array.push(a, "Worst of the session may be done. Still, no heroes.")
    // L3 DANGER + Rising
    array.push(a, "Ugly session. Flatten or hedge everything that is not core.")
    array.push(a, "Intraday crisis building. Cut losses, protect what matters.")
    array.push(a, "This session is dangerous. Reduce to flat if you can.")
    array.push(a, "Real-time country stress. Capital preservation this session.")
    array.push(a, "Session in danger zone. Exit weak names, hedge the rest.")
    // L3 DANGER + Flat
    array.push(a, "Session locked at danger level. Flat is the best trade.")
    array.push(a, "Intraday destruction on pause. Do not mistake pause for recovery.")
    array.push(a, "Session grinding at extreme levels. Endurance, not action.")
    array.push(a, "Dangerous session holding. Cash is the position.")
    array.push(a, "Session at the floor. Wait for clarity, not hope.")
    // L3 DANGER + Cooling
    array.push(a, "Session danger easing. Do not catch the falling knife, let it land.")
    array.push(a, "Intraday crisis maybe peaking. Still too early to add.")
    array.push(a, "Session pulling back from extremes. Verify before acting.")
    array.push(a, "Danger fading this session. Recovery trades need patience.")
    array.push(a, "Session coming off the boil. One swallow does not make a summer.")
    // L4 CRISIS + Rising
    array.push(a, "Session meltdown. Get flat. Do not try to catch this knife.")
    array.push(a, "Intraday crisis. Everything is correlated to the downside.")
    array.push(a, "Full session panic. Protect capital, trade only after clarity.")
    array.push(a, "Emergency session. Square everything, wait for the dust.")
    array.push(a, "This is the session that goes in the history books. Be flat.")
    // L4 CRISIS + Flat
    array.push(a, "Session locked in full crisis. Nothing to do but survive.")
    array.push(a, "Intraday historic levels holding. Cash only.")
    array.push(a, "Session at extremes, no movement. The calm of total fear.")
    array.push(a, "Crisis session frozen. Wait for a circuit breaker or close.")
    array.push(a, "Session in uncharted territory. Flat and patient.")
    // L4 CRISIS + Cooling
    array.push(a, "Session crisis easing. Do not rush. Verify the recovery.")
    array.push(a, "Intraday meltdown possibly peaking. Give it time.")
    array.push(a, "Session coming down from extreme. Walk, do not run.")
    array.push(a, "Crisis session showing first signs of relief. Stay cautious.")
    array.push(a, "Session recovering from the brink. Rebuild only with proof.")

f_init_rct_weekly(array<string> a) =>
    // L0 CALM + Rising
    array.push(a, "Country risk structurally low. Full allocation appropriate.")
    array.push(a, "No systemic domestic stress. Build positions patiently.")
    array.push(a, "Weekly view clean. Structural longs are comfortable here.")
    array.push(a, "Country backdrop supportive. Stay invested, harvest dividends.")
    array.push(a, "Multi-week country calm. Portfolio construction over trading.")
    // L0 CALM + Flat
    array.push(a, "Dead calm on the country risk front. Let compounding work.")
    array.push(a, "Structural backdrop quiet. Allocation decisions can wait.")
    array.push(a, "Weekly country risk non-event. Focus on bottom-up picks.")
    array.push(a, "Zero structural stress. The ideal environment for long-term positions.")
    array.push(a, "Country risk flat for weeks. Enjoy the boring profit machine.")
    // L0 CALM + Cooling
    array.push(a, "Whatever structural stress existed is fading. Rebuild confidence.")
    array.push(a, "Weekly view clearing after a scare. Add back methodically.")
    array.push(a, "Structural concern dissolving. Full allocation becoming appropriate again.")
    array.push(a, "Multi-week healing visible. Patience paying off.")
    array.push(a, "Country risk fading on the weekly. Green light returning.")
    // L1 ALERT + Rising
    array.push(a, "Early structural stress forming. Monitor, do not yet rotate.")
    array.push(a, "Weekly country risk ticking up. Review sector allocation.")
    array.push(a, "First signs on the weekly. Not action yet, but plan for it.")
    array.push(a, "Structural early warning. Identify what to cut if it escalates.")
    array.push(a, "Weekly alert level. Start building a defence plan.")
    // L1 ALERT + Flat
    array.push(a, "Structural alert lingering. Not urgent, but plan B ready.")
    array.push(a, "Weekly country risk stuck at low alert. Watch, do not act.")
    array.push(a, "Persistent mild structural stress. Keep the hedge playbook updated.")
    array.push(a, "Weekly alert holding. Not enough to rotate, enough to notice.")
    array.push(a, "Structural hum of concern. Background noise for now.")
    // L1 ALERT + Cooling
    array.push(a, "Structural alert fading. Ease back into full allocation.")
    array.push(a, "Weekly risk backing off. Whatever it was, it is losing steam.")
    array.push(a, "Structural concern dissolving. False alarm becoming likely.")
    array.push(a, "Weekly alert retreating. Normal allocation resuming.")
    array.push(a, "Country risk stepping down on the weekly. Good sign.")
    // L2 WARNING + Rising
    array.push(a, "Multi-week country stress building. Rotate to defensive sectors.")
    array.push(a, "Weekly warning. Time to underweight domestic risk assets.")
    array.push(a, "Structural deterioration visible. Raise cash methodically.")
    array.push(a, "This is a multi-week warning. Reduce, do not add.")
    array.push(a, "Weekly view says caution. Position for more weakness ahead.")
    // L2 WARNING + Flat
    array.push(a, "Structural warning holding. No resolution in sight.")
    array.push(a, "Weekly stress stuck at warning. Patience, defensive tilt.")
    array.push(a, "Multi-week grind at elevated risk. Wait for the resolution.")
    array.push(a, "Structural stalemate. Defensive positioning until it breaks.")
    array.push(a, "Weekly view says wait. Neither add nor panic.")
    // L2 WARNING + Cooling
    array.push(a, "Multi-week warning easing. Early recovery signs.")
    array.push(a, "Structural stress showing first cracks. Slowly rebuild.")
    array.push(a, "Weekly peak may be in. Cautious re-entry possible.")
    array.push(a, "Country risk coming off multi-week highs. Verify before acting.")
    array.push(a, "Structural healing starting. Do not rush, let it prove itself.")
    // L3 DANGER + Rising
    array.push(a, "Structural country crisis. Minimum domestic exposure.")
    array.push(a, "Weekly danger zone. This is not a dip to buy, it is regime change.")
    array.push(a, "Multi-week collapse pattern. Only hold absolute conviction names.")
    array.push(a, "Structural breakdown. Cash and international diversification.")
    array.push(a, "Weekly view is ugly. This takes weeks to resolve, not days.")
    // L3 DANGER + Flat
    array.push(a, "Structural crisis entrenched. Maximum caution sustained.")
    array.push(a, "Weekly danger holding. The new normal is ugly. Adapt.")
    array.push(a, "Multi-week structural damage ongoing. No bottom in sight.")
    array.push(a, "Country crisis becoming structural. Allocation review mandatory.")
    array.push(a, "Weekly danger plateau. This is not consolidation, it is damage.")
    // L3 DANGER + Cooling
    array.push(a, "Multi-week crisis showing first signs of easing. Do not trust it yet.")
    array.push(a, "Structural danger cooling. The fever breaks slowly.")
    array.push(a, "Weekly peak possibly in. Recovery will be measured in months.")
    array.push(a, "Country crisis may be peaking on the weekly. Verify before adding.")
    array.push(a, "Structural damage easing. The scar tissue will take time.")
    // L4 CRISIS + Rising
    array.push(a, "Structural crisis. Maximum defensive, consider international havens.")
    array.push(a, "Multi-week country meltdown. Cash is a position. Use it.")
    array.push(a, "This is the generational crisis everyone plans for but nobody expects.")
    array.push(a, "Weekly crisis peak. Everything domestic is discounted. Preserve first.")
    array.push(a, "Structural collapse. The recovery will take quarters, not weeks.")
    // L4 CRISIS + Flat
    array.push(a, "Historic weekly crisis holding. There is no precedent. Preserve capital.")
    array.push(a, "Structural meltdown on pause. The damage is done. Wait for rebuilding.")
    array.push(a, "Country crisis at extreme, holding. Zero domestic risk until clarity.")
    array.push(a, "Weekly crisis plateau. This is the bottom OR the beginning. Cash only.")
    array.push(a, "Structural extremes holding. Only international diversification makes sense.")
    // L4 CRISIS + Cooling
    array.push(a, "The longest structural recovery starts here. Walk, do not run.")
    array.push(a, "Dawn after the longest night. Structural healing needs months.")
    array.push(a, "Weekly crisis breaking. Give it weeks to confirm before adding.")
    array.push(a, "Generational bottom may be forming. Patience, not aggression.")
    array.push(a, "Extreme is breaking on the weekly. Rebuild gently over quarters.")


// ── Mood Insight Function ───────────────────────────────
// Country-specific editorial line based on which feeds are at extremes.
f_cci_insight(float oil_z, float gold_z, float fx_roc5_v, float bank_roc,
              float small_dd, float vix_rat, float spread_z, float spread_roc,
              float hyg_z, float wheat_z, float us10y_roc, float dxy_z_v,
              float bench_roc1) =>
    string out = ""
    if oil_z >= 2.0 and fx_roc5_v >= 1.5
        out := "Oil-rupee double whammy — current account deficit widening. RBI reserves under watch."
    else if bank_roc <= -2.0 and spread_z >= 1.5
        out := "Banks leading the decline while sovereign risk climbs. NPA cycle fears meet fiscal stress."
    else if fx_roc5_v >= 2.0 and dxy_z_v >= 1.5
        out := "Dollar surge pulling money out. FII exodus accelerating. Intervention watch."
    else if small_dd <= -20.0 and vix_rat >= 1.2
        out := "Smallcap carnage while VIX elevated. Retail investors getting flushed out."
    else if wheat_z >= 2.0 and oil_z >= 1.5
        out := "Food and energy both surging. Real economy pain before it shows in GDP."
    else if gold_z >= 2.0 and fx_roc5_v >= 1.0
        out := "Gold in local currency breaking records. Domestic hoarding signal, inflation hedge demand surging."
    else if spread_roc >= 0.25 and hyg_z <= -1.5
        out := "Credit markets and sovereign spread both flashing. Institutional money is pricing in deterioration."
    else if us10y_roc >= 5.0 and fx_roc5_v >= 1.0
        out := "Fed tightening meeting local currency weakness. Classic emerging market squeeze pattern."
    else if vix_rat >= 1.3 and math.abs(bench_roc1) < 0.5
        out := "VIX spiking but market flat. Event risk being priced. Election? Policy? RBI decision?"
    else if bank_roc <= -1.5 and small_dd <= -10.0
        out := "Banks and smallcaps both weak. Credit tightening flowing through to the real economy."
    else if oil_z >= 2.0
        out := "Oil at elevated levels. For a country that imports 85% of its crude, this is a slow-burn crisis."
    else if fx_roc5_v >= 1.5
        out := "Multi-session currency pressure. Not a one-day blip, this is sustained capital movement."
    else if spread_z >= 2.0
        out := "Sovereign risk premium at unusual levels. Bond market saying something equity market has not heard yet."
    else if dxy_z_v >= 2.0
        out := "Dollar index at extremes. Every emerging market feels this. Flows follow the dollar, not fundamentals."
    else if gold_z >= 2.0
        out := "Gold demand surging domestically. When the population hedges, they see something the market does not."
    out


// ── Mood Assembly ───────────────────────────────────────
// Build arrays on first bar, pick sentences based on rotation + state.

var array<string> _obs_single = array.new<string>(0)
var array<string> _obs_dual   = array.new<string>(0)
var array<string> _obs_broad  = array.new<string>(0)
var array<string> _obs_sys    = array.new<string>(0)

var array<string> _rct_daily  = array.new<string>(0)
var array<string> _rct_intra  = array.new<string>(0)
var array<string> _rct_weekly = array.new<string>(0)

if barstate.isfirst
    f_init_obs_single(_obs_single)
    f_init_obs_dual(_obs_dual)
    f_init_obs_broad(_obs_broad)
    f_init_obs_sys(_obs_sys)
    f_init_rct_daily(_rct_daily)
    f_init_rct_intra(_rct_intra)
    f_init_rct_weekly(_rct_weekly)

// Select observation: driver-indexed (single/broad/sys), pair-indexed (dual)
string _mood_obs = switch
    _act_count >= 5 => array.get(_obs_sys,    _mood_drv  * 5 + _rot_a)
    _act_count >= 3 => array.get(_obs_broad,  _mood_drv  * 5 + _rot_a)
    _act_count == 2 => array.get(_obs_dual,   _mood_pair * 5 + _rot_a)
    _act_count == 1 => array.get(_obs_single, _mood_drv  * 5 + _rot_a)
    => ""

// Select reaction: threat level × trend group × rotation (75 per timeframe)
// Index: THREAT_LEVEL * 15 + _mood_tgrp * 5 + _rot_b
int _tf_secs = timeframe.in_seconds()
int _rct_idx = THREAT_LEVEL * 15 + _mood_tgrp * 5 + _rot_b
string _mood_rct = _tf_secs <= 14400 ? array.get(_rct_intra, _rct_idx) :
     _tf_secs >= 604800 ? array.get(_rct_weekly, _rct_idx) :
     array.get(_rct_daily, _rct_idx)

// Insight line
string _mood_insight = f_cci_insight(_m3_oil_z, _m3_gold_z, fx_roc5, _m1_bank_roc,
                        _m6_small_dd, vix_ratio20, _m4_spread_z, _m4_spread_roc5,
                        _m4_hyg_z, _m3_wheat_z, _m5_us10y_roc, _m5_dxy_z,
                        _m6_bench_roc1)

// Combine: observation + reaction + optional insight (handles empty obs gracefully)
string _mood_top = _mood_obs != "" ? _mood_obs + "\n" + _mood_rct : _mood_rct
string MOOD_TEXT = _mood_insight != "" ? _mood_top + "\n" + _mood_insight : _mood_top


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 17: COLOUR DEFINITIONS
// ══════════════════════════════════════════════════════════════════════════════

color C_BG_L0 = color.new(color.gray,   85)
color C_BG_L1 = color.new(color.yellow, 75)
color C_BG_L2 = color.new(color.orange, 70)
color C_BG_L3 = color.new(color.red,    65)
color C_BG_L4 = color.new(#990000,      55)
color C_NONE  = color.new(color.white, 100)

color C_TBL_DARK  = #1a1a2e
color C_TBL_L0    = #2d2d3d
color C_TBL_L1    = color.new(#b8860b, 0)
color C_TBL_L2    = color.new(#cc5500, 0)
color C_TBL_L3    = color.new(#cc0000, 0)
color C_TBL_L4    = color.new(#800000, 0)
color C_TXT_W     = color.white
color C_TXT_LGRAY = color.new(#cccccc, 0)

// Module fill colours (distinct from WCI)
color C_M1_FILL = color.new(#8e44ad, 55)   // purple  — Equity
color C_M2_FILL = color.new(#16a085, 55)   // teal    — Currency
color C_M3_FILL = color.new(#d35400, 55)   // orange  — Inflation
color C_M4_FILL = color.new(#2980b9, 55)   // blue    — Sovereign
color C_M5_FILL = color.new(#c0392b, 55)   // red     — External
color C_M6_FILL = color.new(#f39c12, 55)   // gold    — Political

color C_LINE_L0 = color.new(color.gray,   30)
color C_LINE_L1 = color.new(color.yellow, 10)
color C_LINE_L2 = color.new(color.orange, 10)
color C_LINE_L3 = color.new(color.red,    10)
color C_LINE_L4 = color.new(#ff0000,       0)

f_bg_colour(int lvl) =>
    switch lvl
        4 => C_BG_L4
        3 => C_BG_L3
        2 => C_BG_L2
        1 => C_BG_L1
        => C_BG_L0

f_tbl_colour(int lvl) =>
    switch lvl
        4 => C_TBL_L4
        3 => C_TBL_L3
        2 => C_TBL_L2
        1 => C_TBL_L1
        => C_TBL_L0

f_line_colour(int lvl) =>
    switch lvl
        4 => C_LINE_L4
        3 => C_LINE_L3
        2 => C_LINE_L2
        1 => C_LINE_L1
        => C_LINE_L0

f_dir_colour(string dir) =>
    switch dir
        "SURGING"    => color.new(#990000, 0)
        "RISING"     => color.new(#cc5500, 0)
        "ELEVATED"   => color.new(#cc7700, 0)
        "COOLING"    => color.new(#228B22, 0)
        "RETREATING" => color.new(#006400, 0)
        => C_TBL_DARK

f_exposure_bg(float pct) =>
    switch
        pct >= 90  => color.new(#228B22, 0)
        pct >= 70  => color.new(#6B8E23, 0)
        pct >= 50  => color.new(#cc8800, 0)
        pct >= 30  => color.new(#cc5500, 0)
        pct >= 10  => color.new(#cc0000, 0)
        => color.new(#800000, 0)

// Sector heatmap colour (1-bar ROC based)
f_sector_colour(float roc) =>
    switch
        roc >= 1.5  => color.new(#006400, 0)
        roc >= 0.3  => color.new(#228B22, 0)
        roc >= -0.3 => color.new(#555555, 0)
        roc >= -1.5 => color.new(#cc5500, 0)
        => color.new(#cc0000, 0)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 18: SESSION DETECTION
// ══════════════════════════════════════════════════════════════════════════════

// Session open/closed using timezone + stale data check + date gap detection
int _now_h = hour(timenow, country_tz)
bool _in_session = _now_h >= mkt_open_h and _now_h < mkt_close_h

// ── OHLC Stale Detection (matches WCI pattern) ──
// If benchmark C, H, L are ALL identical to previous bar → feed is replaying
// old data, market is not actually trading. Works on any chart timeframe,
// including 24/7 charts (crypto/forex) where bars exist every day.
bool _bench_stale = barstate.islast and
     bench_c == nz(bench_c[1]) and bench_h == nz(bench_h[1]) and bench_l == nz(bench_l[1])

// Bar freshness: is the last bar actually from today (in country timezone)?
// Both sides in country_tz so chart symbol timezone doesn't cause false gaps.
bool _bar_is_today = dayofmonth(time, country_tz) == dayofmonth(timenow, country_tz) and
     month(time, country_tz) == month(timenow, country_tz) and
     year(time) == year(timenow)

// Day of week
int _dow = dayofweek(timenow, country_tz)
bool _weekend = _dow == dayofweek.saturday or _dow == dayofweek.sunday

// Live detection: bar is from today + session hours + OHLC not stale
bool _mkt_live = barstate.islast and _bar_is_today and _in_session and not _bench_stale

// Holiday detection: weekday + past market open hour + EITHER:
//   (a) no bar for today at all (daily chart, exchange didn't open), OR
//   (b) bar exists but OHLC is stale during session hours (intraday/crypto chart)
bool _is_holiday = barstate.islast and not _weekend and _now_h >= mkt_open_h and
     (not _bar_is_today or (_bench_stale and _in_session))

// Final session status
string SESSION_STATUS = barstate.islast ?
     (_mkt_live ? "OPEN" : "CLOSED") : ""

string SESSION_TEXT = _weekend ? "CLOSED (Weekend)" :
     (_is_holiday ? "CLOSED (Holiday)" :
      SESSION_STATUS == "CLOSED" ? "CLOSED (After Hours)" : SESSION_STATUS)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 19: VISUAL OUTPUT — BACKGROUND + STACKED AREA + SCORE LINE
// ══════════════════════════════════════════════════════════════════════════════

// 19.1 Background Colour
bgcolor(i_showBg ? f_bg_colour(THREAT_LEVEL) : C_NONE, title = "Crisis Level Background")

// 19.2 Stacked Fill Area (6 modules)
float stack_m6 = i_showModules ? M6_SCORE : na
float stack_m5 = i_showModules ? M6_SCORE + M5_SCORE : na
float stack_m4 = i_showModules ? M6_SCORE + M5_SCORE + M4_SCORE : na
float stack_m3 = i_showModules ? M6_SCORE + M5_SCORE + M4_SCORE + M3_SCORE : na
float stack_m2 = i_showModules ? M6_SCORE + M5_SCORE + M4_SCORE + M3_SCORE + M2_SCORE : na
float stack_m1 = i_showModules ? M6_SCORE + M5_SCORE + M4_SCORE + M3_SCORE + M2_SCORE + M1_SCORE : na

p_top  = plot(i_showModules ? stack_m1 : na, "Stack Top (M1)", color = color.new(color.white, 100), linewidth = 1, display = display.none)
p_m2   = plot(i_showModules ? stack_m2 : na, "Stack M2",       color = color.new(color.white, 100), linewidth = 1, display = display.none)
p_m3   = plot(i_showModules ? stack_m3 : na, "Stack M3",       color = color.new(color.white, 100), linewidth = 1, display = display.none)
p_m4   = plot(i_showModules ? stack_m4 : na, "Stack M4",       color = color.new(color.white, 100), linewidth = 1, display = display.none)
p_m5   = plot(i_showModules ? stack_m5 : na, "Stack M5",       color = color.new(color.white, 100), linewidth = 1, display = display.none)
p_m6   = plot(i_showModules ? stack_m6 : na, "Stack M6",       color = color.new(color.white, 100), linewidth = 1, display = display.none)
p_zero = plot(i_showModules ? 0.0      : na, "Stack Base",     color = color.new(color.white, 100), linewidth = 1, display = display.none)

fill(p_top,  p_m2,   color = C_M1_FILL, title = "M1 Equity Stress")
fill(p_m2,   p_m3,   color = C_M2_FILL, title = "M2 Currency Flight")
fill(p_m3,   p_m4,   color = C_M3_FILL, title = "M3 Inflation Shock")
fill(p_m4,   p_m5,   color = C_M4_FILL, title = "M4 Sovereign Risk")
fill(p_m5,   p_m6,   color = C_M5_FILL, title = "M5 External Vuln")
fill(p_m6,   p_zero, color = C_M6_FILL, title = "M6 Political Risk")

// 19.3 CCI Score Line
plot(CCI_SCORE, "CCI Score", color = f_line_colour(THREAT_LEVEL), linewidth = 3)

// 19.4 Threshold Reference Lines
hline(i_cciL2, "Level 2 — Warning", color.new(color.orange, 40), linestyle = hline.style_dashed)
hline(i_cciL3, "Level 3 — Danger",  color.new(color.red,    40), linestyle = hline.style_dashed)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 20: DASHBOARD TABLE
// ══════════════════════════════════════════════════════════════════════════════

// 20.1 Table Setup
var table _tbl = table.new(f_table_pos(i_tablePos), 9, 9, bgcolor = #1a1a2e,
     frame_width = 1, frame_color = #444466, border_width = 1, border_color = #cccccc)

// ── Indices Row: Daily ROC (runs every bar, uses var persistence) ──
float _dr_bench = f_daily_roc(bench_c)
float _dr_bank  = f_daily_roc(bank_c)
float _dr_tech  = f_daily_roc(tech_c)
float _dr_small = f_daily_roc(small_c)
float _dr_s5    = f_daily_roc(sect5_c)
float _dr_s6    = f_daily_roc(sect6_c)
float _dr_s7    = f_daily_roc(sect7_c)

if barstate.islast and i_showTable

    // ── Row 0: CCI Score + Level + Country ──────────────
    string _r0_text = "CCI [" + country_code + "]  " +
         str.tostring(math.round(CCI_SCORE, 1)) + "  " + LVL_NAME
    table.cell(_tbl, 0, 0, _r0_text, text_color = C_TXT_W,
         bgcolor = f_tbl_colour(THREAT_LEVEL), text_size = size.small,
         text_halign = text.align_center)
    table.merge_cells(_tbl, 0, 0, 8, 0)

    // ── Row 1: Signal + Direction ───────────────────────
    if i_showSignal
        string _r1_text = ACTION_SIG + "  " + STAGE_DIR + "  " + EXPOSURE_TEXT
        table.cell(_tbl, 0, 1, "Signal", text_color = C_TXT_LGRAY,
             bgcolor = C_TBL_DARK, text_size = size.small)
        table.cell(_tbl, 1, 1, _r1_text, text_color = C_TXT_W,
             bgcolor = f_dir_colour(STAGE_DIR), text_size = size.small)
        table.merge_cells(_tbl, 1, 1, 8, 1)
    else
        table.cell(_tbl, 0, 1, "", bgcolor = C_TBL_DARK, text_size = size.small)
        table.merge_cells(_tbl, 0, 1, 8, 1)

    // ── Row 2: 7-Bar Colour-Coded Sparkline + Δ7/Δ1 ──────
    // Background = directional (fast rising/rising/steady/falling/fast falling)
    // Text = block height (8-level), colour = yellow above midpoint, cyan below
    if i_showSparkline
        float _sv0 = nz(CCI_SCORE[6])
        float _sv1 = nz(CCI_SCORE[5])
        float _sv2 = nz(CCI_SCORE[4])
        float _sv3 = nz(CCI_SCORE[3])
        float _sv4 = nz(CCI_SCORE[2])
        float _sv5 = nz(CCI_SCORE[1])
        float _sv6 = nz(CCI_SCORE)
        float _slo = math.min(_sv0, math.min(_sv1, math.min(_sv2, math.min(_sv3, math.min(_sv4, math.min(_sv5, _sv6))))))
        float _shi = math.max(_sv0, math.max(_sv1, math.max(_sv2, math.max(_sv3, math.max(_sv4, math.max(_sv5, _sv6))))))
        float _smid = (_slo + _shi) / 2.0

        // Bar-to-bar deltas for directional colour (bar before _sv0 = CCI_SCORE[7])
        float _dd0 = _sv0 - nz(CCI_SCORE[7])
        float _dd1 = _sv1 - _sv0
        float _dd2 = _sv2 - _sv1
        float _dd3 = _sv3 - _sv2
        float _dd4 = _sv4 - _sv3
        float _dd5 = _sv5 - _sv4
        float _dd6 = _sv6 - _sv5

        // Text colour: yellow if above midpoint (high crisis), cyan if below
        color _st0 = _sv0 > _smid ? #ffdd00 : #00ddff
        color _st1 = _sv1 > _smid ? #ffdd00 : #00ddff
        color _st2 = _sv2 > _smid ? #ffdd00 : #00ddff
        color _st3 = _sv3 > _smid ? #ffdd00 : #00ddff
        color _st4 = _sv4 > _smid ? #ffdd00 : #00ddff
        color _st5 = _sv5 > _smid ? #ffdd00 : #00ddff
        color _st6 = _sv6 > _smid ? #ffdd00 : #00ddff

        table.cell(_tbl, 0, 2, "7-Bar", text_color = C_TXT_LGRAY,
             bgcolor = f_spark_dir_bg(_dd6), text_size = size.small)
        table.cell(_tbl, 1, 2, f_spark_char(_sv0, _slo, _shi), bgcolor = f_spark_dir_bg(_dd0), text_color = _st0, text_size = size.large)
        table.cell(_tbl, 2, 2, f_spark_char(_sv1, _slo, _shi), bgcolor = f_spark_dir_bg(_dd1), text_color = _st1, text_size = size.large)
        table.cell(_tbl, 3, 2, f_spark_char(_sv2, _slo, _shi), bgcolor = f_spark_dir_bg(_dd2), text_color = _st2, text_size = size.large)
        table.cell(_tbl, 4, 2, f_spark_char(_sv3, _slo, _shi), bgcolor = f_spark_dir_bg(_dd3), text_color = _st3, text_size = size.large)
        table.cell(_tbl, 5, 2, f_spark_char(_sv4, _slo, _shi), bgcolor = f_spark_dir_bg(_dd4), text_color = _st4, text_size = size.large)
        table.cell(_tbl, 6, 2, f_spark_char(_sv5, _slo, _shi), bgcolor = f_spark_dir_bg(_dd5), text_color = _st5, text_size = size.large)
        table.cell(_tbl, 7, 2, f_spark_char(_sv6, _slo, _shi), bgcolor = f_spark_dir_bg(_dd6), text_color = _st6, text_size = size.large)

        // Delta cell: Δ7 + Δ1 (negative = crisis dropped = green, positive = crisis rose = red)
        float _sd7 = -(nz(CCI_SCORE) - nz(CCI_SCORE[6]))
        float _sd1 = -(nz(CCI_SCORE) - nz(CCI_SCORE[1]))
        string _sd7_str = "Δ7:" + (_sd7 >= 0 ? "+" : "") + str.tostring(math.round(_sd7, 1))
        string _sd1_str = "Δ1:" + (_sd1 >= 0 ? "+" : "") + str.tostring(math.round(_sd1, 1))
        color _sd_txt = _sd7 > 0 ? #69f0ae : _sd7 < -3 ? #ff5252 : #aaaaaa
        table.cell(_tbl, 8, 2, _sd7_str + "\n" + _sd1_str, bgcolor = C_TBL_DARK, text_color = _sd_txt, text_size = size.small)
    else
        table.cell(_tbl, 0, 2, "", bgcolor = C_TBL_DARK, text_size = size.small)
        table.merge_cells(_tbl, 0, 2, 8, 2)

    // ── Row 3: Exposure ─────────────────────────────────
    string _r3_text = EXPOSURE_TEXT + " — " +
         (EXPOSURE_PCT >= 85 ? "Full deployment" :
          EXPOSURE_PCT >= 60 ? "Moderate caution" :
          EXPOSURE_PCT >= 35 ? "Reduced exposure" :
          EXPOSURE_PCT >= 15 ? "Heavy defensive" : "Maximum defensive")
    table.cell(_tbl, 0, 3, "Exposure", text_color = C_TXT_LGRAY,
         bgcolor = C_TBL_DARK, text_size = size.small)
    table.cell(_tbl, 1, 3, _r3_text, text_color = C_TXT_W,
         bgcolor = f_exposure_bg(EXPOSURE_PCT), text_size = size.small)
    table.merge_cells(_tbl, 1, 3, 8, 3)

    // ── Row 4: Driver ───────────────────────────────────
    string _r4_text = DOM_SHORT + "  " + DOM_SCORE_TXT + BREADTH_TAG +
         (DRIVER_TAGS_CLEAN != "" ? "\n" + DRIVER_TAGS_CLEAN : "")
    table.cell(_tbl, 0, 4, "Driver", text_color = C_TXT_LGRAY,
         bgcolor = C_TBL_DARK, text_size = size.small)
    table.cell(_tbl, 1, 4, _r4_text, text_color = C_TXT_W,
         bgcolor = f_tbl_colour(THREAT_LEVEL), text_size = size.small)
    table.merge_cells(_tbl, 1, 4, 8, 4)

    // ── Row 5: Mood ─────────────────────────────────────
    if i_showMood
        table.cell(_tbl, 0, 5, "Mood", text_color = C_TXT_LGRAY,
             bgcolor = C_TBL_DARK, text_size = size.small)
        table.cell(_tbl, 1, 5, MOOD_TEXT, text_color = color.new(#333333, 0),
             bgcolor = color.new(#f5f5f0, 0), text_size = size.small)
        table.merge_cells(_tbl, 1, 5, 8, 5)
    else
        table.cell(_tbl, 0, 5, "", bgcolor = C_TBL_DARK, text_size = size.small)
        table.merge_cells(_tbl, 0, 5, 8, 5)

    // ── Row 6: Currency ─────────────────────────────────
    // Show rate as local-currency-per-dollar (e.g. ₹84.35/$)
    // For USD/local pairs: fx_c is already local/dollar
    // For local/USD pairs (GBP, EUR, AUD): invert to get local/dollar
    // For US (DXY): show index level directly
    float _r6_rate = i_country == "United States" ? fx_c : (fx_invert ? f_safe_div(1.0, fx_c) : fx_c)
    int _r6_dec = _r6_rate >= 100 ? 1 : _r6_rate >= 10 ? 2 : 4
    string _r6_rate_str = i_country == "United States" ?
         "DXY: " + str.tostring(math.round(nz(_r6_rate), 1)) :
         fx_sym + str.tostring(math.round(nz(_r6_rate), _r6_dec)) + "/$"
    float _r6_fx_roc = fx_roc5
    float _r6_spread = sov_spread
    float _r6_own = dxy_adj_fx
    string _r6_fx_dir = _r6_fx_roc > 0.3 ? "▼ Weak" : _r6_fx_roc < -0.3 ? "▲ Strong" : "— Stable"
    string _r6_text = _r6_rate_str + " (" + _r6_fx_dir + " " + f_pct_str(-_r6_fx_roc) + ")" +
         "  |  Spread: " + str.tostring(math.round(_r6_spread, 2)) +
         "  |  Target Stock: " + f_pct_str(-_r6_own)
    table.cell(_tbl, 0, 6, "Currency", text_color = C_TXT_LGRAY,
         bgcolor = C_TBL_DARK, text_size = size.small)
    table.cell(_tbl, 1, 6, _r6_text, text_color = C_TXT_W,
         bgcolor = _r6_fx_roc > 1.0 ? color.new(#cc0000, 0) :
                   _r6_fx_roc > 0.3 ? color.new(#cc5500, 0) : C_TBL_DARK,
         text_size = size.small)
    table.merge_cells(_tbl, 1, 6, 8, 6)

    // ── Row 7: Indices (7-Index Heatmap with arrows) ──────
    // Uses f_daily_roc() computed at main scope — shows last session's % change

    table.cell(_tbl, 0, 7, "Indices", text_color = C_TXT_LGRAY,
         bgcolor = C_TBL_DARK, text_size = size.small)
    table.cell(_tbl, 1, 7, f_sect_txt(bench_label, _dr_bench),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_bench),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 2, 7, f_sect_txt(bank_label, _dr_bank),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_bank),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 3, 7, f_sect_txt(tech_label, _dr_tech),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_tech),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 4, 7, f_sect_txt(small_label, _dr_small),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_small),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 5, 7, f_sect_txt(sect5_label, _dr_s5),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_s5),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 6, 7, f_sect_txt(sect6_label, _dr_s6),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_s6),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 7, 7, f_sect_txt(sect7_label, _dr_s7),
         text_color = C_TXT_W, bgcolor = f_sector_colour(_dr_s7),
         text_size = size.small, text_halign = text.align_center)
    table.cell(_tbl, 8, 7, "", bgcolor = f_sector_colour(_dr_s7), text_size = size.small)
    table.merge_cells(_tbl, 7, 7, 8, 7)

    // ── Row 8: Status ───────────────────────────────────
    // Coloured BACKGROUND: green=open, red=closed, amber=holiday, blue-gray=weekend
    color _r8_bg = SESSION_STATUS == "OPEN" ? color.new(#4CAF50, 0) :
         _is_holiday ? color.new(#FF8F00, 0) :
         _weekend ? color.new(#546E7A, 0) :
         color.new(#E53935, 0)
    string _r8_text = i_country + " Market: " + SESSION_TEXT
    table.cell(_tbl, 0, 8, "Status", text_color = C_TXT_LGRAY,
         bgcolor = C_TBL_DARK, text_size = size.tiny)
    table.cell(_tbl, 1, 8, _r8_text, text_color = #ffffff,
         bgcolor = _r8_bg, text_size = size.small, text_font_family = font.family_monospace)
    table.merge_cells(_tbl, 1, 8, 8, 8)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 21: WEBHOOK JSON EXPORT
// ══════════════════════════════════════════════════════════════════════════════
// Fires on bar close + every N minutes on live bar + on chart reload.

var int _json_last_fire = 0
int _json_interval_ms = i_jsonInterval * 60 * 1000
bool _json_bar_close = barstate.isconfirmed
bool _json_live_tick = barstate.islast and (timenow - _json_last_fire >= _json_interval_ms)
bool _json_fire = i_alertJSON and (_json_bar_close or _json_live_tick)

if _json_fire and barstate.isrealtime
    _json_last_fire := timenow

// ── JSON Builder Functions (keep main body under statement limit) ──

// Top-level scores + metadata (matches WCI field coverage)
f_build_json_scores(float cci, float raw, int tl, string lv, string dir, int stg,
                    string act, float exp, string expDir, int conv, float boost,
                    float d7, float d1, string dom, string domS, int actCnt,
                    float m1, float m2, float m3, float m4, float m5, float m6,
                    string mood, string ses) =>
    string j = '{'
    j += '"ticker":"' + syminfo.ticker + '"'
    j += ',"country":"' + country_code + '"'
    j += ',"cci":' + str.tostring(math.round(cci, 1))
    j += ',"cciRaw":' + str.tostring(math.round(raw, 1))
    j += ',"tl":' + str.tostring(tl)
    j += ',"lv":"' + lv + '"'
    j += ',"dir":"' + dir + '"'
    j += ',"stg":' + str.tostring(stg)
    j += ',"act":"' + act + '"'
    j += ',"exp":' + str.tostring(math.round(exp))
    j += ',"expDir":"' + expDir + '"'
    j += ',"conv":' + str.tostring(conv)
    j += ',"boost":' + str.tostring(math.round(boost, 2))
    j += ',"d7":' + str.tostring(math.round(d7, 1))
    j += ',"d1":' + str.tostring(math.round(d1, 1))
    j += ',"dom":"' + dom + '"'
    j += ',"domS":"' + domS + '"'
    j += ',"actCnt":' + str.tostring(actCnt)
    j += ',"ses":"' + ses + '"'
    j += ',"mood":"' + str.replace_all(mood, '"', "'") + '"'
    j += ',"m1":{"s":' + str.tostring(math.round(m1, 1)) + '}'
    j += ',"m2":{"s":' + str.tostring(math.round(m2, 1)) + '}'
    j += ',"m3":{"s":' + str.tostring(math.round(m3, 1)) + '}'
    j += ',"m4":{"s":' + str.tostring(math.round(m4, 1)) + '}'
    j += ',"m5":{"s":' + str.tostring(math.round(m5, 1)) + '}'
    j += ',"m6":{"s":' + str.tostring(math.round(m6, 1)) + '}'
    j

// Raw prices for all 22 feeds
f_build_json_prices(float bench, float bank, float tech, float small_v,
                    float vix, float fx, float y10, float y2,
                    float oil, float gold, float wheat, float gas, float copper,
                    float trade, float tradefx, float us10y, float dxy, float hyg,
                    float alt, float s5, float s6, float s7) =>
    string j = ',"px":{'
    j += '"bench":' + str.tostring(math.round(nz(bench), 2))
    j += ',"bank":' + str.tostring(math.round(nz(bank), 2))
    j += ',"tech":' + str.tostring(math.round(nz(tech), 2))
    j += ',"small":' + str.tostring(math.round(nz(small_v), 2))
    j += ',"vix":' + str.tostring(math.round(nz(vix), 2))
    j += ',"fx":' + str.tostring(math.round(nz(fx), 4))
    j += ',"y10":' + str.tostring(math.round(nz(y10), 3))
    j += ',"y2":' + str.tostring(math.round(nz(y2), 3))
    j += ',"oil":' + str.tostring(math.round(nz(oil), 2))
    j += ',"gold":' + str.tostring(math.round(nz(gold), 2))
    j += ',"wheat":' + str.tostring(math.round(nz(wheat), 1))
    j += ',"gas":' + str.tostring(math.round(nz(gas), 3))
    j += ',"copper":' + str.tostring(math.round(nz(copper), 3))
    j += ',"trade":' + str.tostring(math.round(nz(trade), 1))
    j += ',"tradefx":' + str.tostring(math.round(nz(tradefx), 4))
    j += ',"us10y":' + str.tostring(math.round(nz(us10y), 3))
    j += ',"dxy":' + str.tostring(math.round(nz(dxy), 2))
    j += ',"hyg":' + str.tostring(math.round(nz(hyg), 2))
    j += ',"alt":' + str.tostring(math.round(nz(alt), 2))
    j += ',"sect5":' + str.tostring(math.round(nz(s5), 2))
    j += ',"sect6":' + str.tostring(math.round(nz(s6), 2))
    j += ',"sect7":' + str.tostring(math.round(nz(s7), 2))
    j += '}'
    j

// Editorial: subhead + narrative
f_build_json_editorial(string subhead, string narrative) =>
    string _sh = str.replace_all(subhead, '"', "'")
    string _nr = str.replace_all(narrative, '"', "'")
    string j = ',"subhead":"' + _sh + '"'
    j += ',"narrative":"' + _nr + '"'
    j += '}'
    j

// ── Sub-Headline Builder ────────────────────────────────
string _json_sub_retreat = switch
    _act_count >= 4 => "Country stress receding as " + str.tostring(_act_count) + " modules ease"
    STAGE_DIR == "RETREATING" and THREAT_LEVEL >= 3 => "Crisis intensity falling, risk gauges pulling back"
    STAGE_DIR == "RETREATING" => "Threat receding as domestic indicators unwind"
    STAGE_DIR == "COOLING" and THREAT_LEVEL >= 3 => "Crisis momentum slowing, markets searching for a floor"
    => "Pressure easing, risk appetite returning cautiously"

string _json_sub_m1 = switch
    _m1_bench_pts >= 3.5 => bench_label + " in free-fall, equity shock at domestic epicentre"
    _m1_bank_pts >= 3.0 => "Banking sector leading domestic equity decline, credit stress signal"
    _m1_small_pts >= 3.0 => "Smallcap rout deepens as risk appetite evaporates"
    => "Domestic equity stress building across sectors"

string _json_sub_m2 = switch
    fx_roc5 >= 2.0 * em_mult => fx_label + " in sustained decline, capital flight accelerating"
    _m2_yield_pts >= 2.5 => "Bond yields surging as foreign investors exit domestic debt"
    _m2_spread_pts >= 1.5 => "Sovereign spread widening sharply, country risk repricing"
    => "Currency and capital flow stress building"

string _json_sub_m3 = switch
    _m3_oil_pts >= 5.0 => "Oil-in-" + fx_label + " at crisis levels, import bill surging"
    _m3_gold_pts >= 2.0 => "Gold demand surging in local currency, inflation hedge in overdrive"
    _m3_wheat_pts >= 2.0 => "Food commodity spike threatening cost of living stability"
    => "Inflation and cost-of-living pressure building"

string _json_sub_m4 = switch
    _m4_corr_pts >= 3.0 => "Stocks and bonds falling together, liquidity crisis pattern"
    _m4_spread_lvl_pts >= 3.5 => "Sovereign risk premium at alarming levels"
    _m4_bank_pts >= 2.5 => "Banking sector under structural stress, credit channel impaired"
    => "Sovereign and credit risk indicators deteriorating"

string _json_sub_m5 = switch
    _m5_oil_pts >= 3.0 and _m5_fed_pts >= 2.0 => "Oil shock meets Fed tightening, classic EM vulnerability"
    _m5_trade_pts >= 2.0 => "Trade partner slowdown creating external headwinds"
    _m5_dxy_pts >= 2.0 => "Dollar strength creating EM capital outflow conditions"
    => "External vulnerability channels activating"

string JSON_SUBHEAD = switch
    THREAT_LEVEL == 0 => i_country + " markets steady, all crisis gauges reading calm"
    (STAGE_DIR == "RETREATING" or STAGE_DIR == "COOLING") and THREAT_LEVEL <= 2 => _json_sub_retreat
    _act_count >= 4 => "Full-spectrum " + i_country + " crisis, " + str.tostring(_act_count) + " modules firing"
    _act_count >= 3 => "Broad " + i_country + " stress, three-front crisis pattern"
    _dom_max == M1_SCORE => _json_sub_m1
    _dom_max == M2_SCORE => _json_sub_m2
    _dom_max == M3_SCORE => _json_sub_m3
    _dom_max == M4_SCORE => _json_sub_m4
    _dom_max == M5_SCORE => _json_sub_m5
    _dom_max == M6_SCORE => "Political uncertainty elevating domestic risk premium"
    => i_country + " risk conditions under review"

// ── Narrative Builder ───────────────────────────────────
float _json_d7 = -(nz(CCI_SCORE) - nz(CCI_SCORE[6]))
string _json_lead = "The " + i_country + " Crisis Index " +
     (math.abs(_json_d7) >= 3.0 ? (_json_d7 < 0 ? "rose " + str.tostring(math.abs(math.round(_json_d7, 1))) + " points to " : "fell " + str.tostring(math.abs(math.round(_json_d7, 1))) + " points to ") :
      (_json_d7 < 0 ? "edged higher to " : _json_d7 > 0 ? "eased to " : "held at ")) +
     str.tostring(math.round(CCI_SCORE, 1)) +
     ", " + (LVL_NAME == "CALM" ? "remaining in Calm territory" : "in " + LVL_NAME + " territory") +
     ". "

string _json_s_m1 = not _m1_act ? "" :
     bench_label + " showing stress" +
     (_m1_bench_pts >= 3.0 ? " with velocity z-score at " + str.tostring(math.round(_m1_bench_z, 1)) : "") +
     (_m1_breadth >= 2 ? ", " + str.tostring(_m1_breadth) + " of 3 sectors declining in sync" : "") + ". "

string _json_s_m2 = not _m2_act ? "" :
     fx_label + " " + (fx_roc5 >= 1.0 ? "weakened " + f_pct_str(-fx_roc5) + " over five sessions" : "under pressure") +
     (_m2_yield_pts >= 1.0 ? ", local 10Y yields rising" : "") +
     (_m2_spread_pts >= 1.0 ? ", sovereign spread widening" : "") + ". "

string _json_s_m3 = not _m3_act ? "" :
     "Inflation proxy " + (is_oil_importer ? "elevated as oil-in-" + fx_label + " rises" : "building on commodity prices") +
     (_m3_gold_pts >= 1.0 ? ", gold demand surging in local terms" : "") + ". "

string _json_s_m4 = not _m4_act ? "" :
     "Sovereign credit risk " + (_m4_spread_lvl_pts >= 3.0 ? "at alarming levels" : "building") +
     (_m4_corr_pts >= 2.0 ? ", stocks and bonds falling together in a liquidity squeeze" : "") +
     (_m4_bank_pts >= 2.0 ? ", banking sector under institutional stress" : "") + ". "

string _json_s_m5 = not _m5_act ? "" :
     "External vulnerability " + (_m5_oil_pts >= 2.0 ? "led by oil import stress" : "activating through trade channels") +
     (_m5_fed_pts >= 1.5 ? ", Fed tightening pulling EM capital" : "") +
     (_m5_dxy_pts >= 1.5 ? ", dollar strength creating outflow conditions" : "") + ". "

string _json_s_m6 = not _m6_act ? "" :
     "Sentiment deteriorating" +
     (_m6_small_dd <= -15.0 ? ", smallcap drawdown at " + str.tostring(math.round(_m6_small_dd, 1)) + "%" : "") +
     (vix_ratio20 >= 1.2 ? ", VIX elevated relative to norm" : "") + ". "

string _json_s_conv = _conv_count >= 3 ?
     str.tostring(_conv_count) + " modules firing simultaneously, convergence multiplier at " +
     str.tostring(math.round(_conv_boost, 2)) + "x. " : ""

string _json_s_outlook = STAGE_DIR == "RETREATING" ? "Risk receding, outlook improving cautiously. " :
     STAGE_DIR == "COOLING" ? "Momentum slowing, watching for stabilisation. " :
     STAGE_DIR == "SURGING" ? "Crisis accelerating, defensive posture warranted. " :
     STAGE_DIR == "RISING" ? "Stress building, monitor for escalation. " :
     "Conditions stable, maintaining current stance. "

string JSON_NARRATIVE = _json_lead + _json_s_m1 + _json_s_m2 + _json_s_m3 +
     _json_s_m4 + _json_s_m5 + _json_s_m6 + _json_s_conv + _json_s_outlook

// ── Deltas for JSON ─────────────────────────────────────
float _json_d7_v = -(nz(CCI_SCORE) - nz(CCI_SCORE[6]))
float _json_d1_v = -(nz(CCI_SCORE) - nz(CCI_SCORE[1]))

// ── Fire Alert ──────────────────────────────────────────
if _json_fire
    string _j_scores = f_build_json_scores(CCI_SCORE, CCI_RAW, THREAT_LEVEL, LVL_NAME,
         STAGE_DIR, STAGE_NUM, ACTION_SIG, EXPOSURE_PCT, EXPOSURE_DIR,
         _conv_count, _conv_boost, _json_d7_v, _json_d1_v,
         DOM_SHORT, DOM_SCORE_TXT, _act_count,
         M1_SCORE, M2_SCORE, M3_SCORE, M4_SCORE, M5_SCORE, M6_SCORE,
         MOOD_TEXT, SESSION_TEXT)
    string _j_prices = f_build_json_prices(bench_c, bank_c, tech_c, small_c,
         vix_c, fx_c, y10_c, y2_c,
         oil_c, gold_c, wheat_c, gas_c, copper_c,
         trade_c, tradefx_c, us10y_c, dxy_c, hyg_c,
         alt_c, sect5_c, sect6_c, sect7_c)
    string _j_editorial = f_build_json_editorial(JSON_SUBHEAD, JSON_NARRATIVE)
    string _j_full = _j_scores + _j_prices + _j_editorial
    alert(_j_full, alert.freq_all)


// ══════════════════════════════════════════════════════════════════════════════
// SECTION 22: ALERT CONDITIONS
// ══════════════════════════════════════════════════════════════════════════════

string _a_crisis = DOM_LABEL
string _a_dir    = STAGE_DIR
string _a_gate   = EXPOSURE_TEXT
string _a_score  = str.tostring(math.round(CCI_SCORE, 1))

if i_alertL1 and THREAT_LEVEL >= 1 and THREAT_LEVEL[1] < 1
    alert("CCI [" + country_code + "] ALERT: " + _a_score + " | " + _a_crisis + " | " + _a_gate, alert.freq_once_per_bar)

if i_alertL2 and THREAT_LEVEL >= 2 and THREAT_LEVEL[1] < 2
    alert("CCI [" + country_code + "] WARNING: " + _a_score + " | " + _a_crisis + " | " + _a_dir + " | " + _a_gate, alert.freq_once_per_bar)

if i_alertL3 and THREAT_LEVEL >= 3 and THREAT_LEVEL[1] < 3
    alert("CCI [" + country_code + "] DANGER: " + _a_score + " | " + _a_crisis + " | " + _a_dir + " | " + _a_gate, alert.freq_once_per_bar)

if i_alertL4 and THREAT_LEVEL >= 4 and THREAT_LEVEL[1] < 4
    alert("CCI [" + country_code + "] CRISIS: " + _a_score + " | " + _a_crisis + " | " + _a_dir + " | " + _a_gate, alert.freq_once_per_bar)

if i_alertChange and THREAT_LEVEL != THREAT_LEVEL[1]
    alert("CCI [" + country_code + "] Level: " + str.tostring(THREAT_LEVEL[1]) + " -> " + str.tostring(THREAT_LEVEL) + " | " + _a_score + " | " + _a_dir, alert.freq_once_per_bar)


// ══════════════════════════════════════════════════════════════════════════════
// END OF CCI v1.0
// ══════════════════════════════════════════════════════════════════════════════
````
