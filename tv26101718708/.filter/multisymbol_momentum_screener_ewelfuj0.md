# Multi-Symbol Momentum Screener

- url: https://www.tradingview.com/script/ewELfUj0-Multi-Symbol-Momentum-Screener/
- type: indicator
- pine_id: PUB;32950167ee0a4849be82636a4e31ffec
- version: 1.0

## Description

[b]Multi-Symbol Momentum Screener[/b] ranks 20 instruments at once by decomposing each symbol's current-timeframe state into three independent, explicitly-normalised axes — Momentum, Trend, and Volatility — and then cross-checks every result against a higher-timeframe Daily direction derived from the same data. The output is a single sortable heatmap in which conflicts between intraday momentum and the daily bias are flagged as "Divergence" rather than hidden inside a composite number.

[b]Why This Combination[/b]

Most single-axis screeners answer only one question ("Is RSI overbought?" or "Is ADX strong?"), which is why a high RSI reading on one pair often coexists with a weak trend and average volatility — a situation that does not warrant attention but looks attractive in a single-metric dashboard. The three axes chosen here are intentionally disjoint:

[list]
[*][b]Momentum[/b] measures how stretched price is relative to its own recent history (RSI plus percentile-ranked Rate-of-Change).
[*][b]Trend[/b] measures directional persistence using the EMA spread and Wilder's ADX, which is independent of where RSI currently sits.
[*][b]Volatility[/b] measures whether ATR is expanding or contracting relative to its own 50-bar mean, independent of direction and momentum.
[/list]

A symbol that scores highly across all three axes is simultaneously stretched, trending, and in an expanding-volatility regime — a profile that is meaningfully rarer (and more actionable) than any single component in isolation. The Daily direction column then adds a coarse higher-timeframe check without inflating the composite score, so the user can see when current-timeframe strength is fighting the daily trend.

[b]What It Does[/b]

[list]
[*]Scans 20 symbols from a preset (FX Majors & Minors / Crypto Top 20 / US Stocks Top 20) or a Custom slot list.
[*]Produces four numbers per symbol: Momentum (0–100), Trend (0–100), Volatility (0–100), and a weighted Total Score (0–100).
[*]Adds a Daily-timeframe direction column (Up / Down / Flat) computed on each symbol's own chart.
[*]Classifies the current state into nine mutually-exclusive signal labels (Strong Up, Momentum Up, Moderate Up, Flat, Moderate Down, Strong Down, Weak, and two Divergence states).
[*]Sorts the table automatically by Total Score or by any single axis.
[/list]

[b]How It Works[/b]

Each symbol consumes two [i]request.security()[/i] calls — one on the chart timeframe and one on the Daily — for a total of exactly 40 calls, which is the per-indicator ceiling that applies on every TradingView plan.

[b]Axis formulas[/b]

[list]
[*][b]Momentum[/b] = mean of RSI(14) and percentrank(ROC(10), 100). RSI is already bounded to 0–100, and percentile-ranking a 10-bar ROC over the last 100 bars forces the second component onto the same scale. This avoids the common failure mode where a raw ROC is added to RSI and produces wildly different ranges across FX and crypto.
[*][b]Trend[/b] = mean of an EMA-spread component and ADX(14). The EMA-spread component is 50 + (EMA20 − EMA50) / EMA50 × 100 × 20, clamped to 0–100. ADX(14) is already 0–100. Averaging the two gives equal weight to "how far apart the EMAs are" (direction) and "how persistently price has been trending" (strength).
[*][b]Volatility[/b] = (ATR(14) / SMA(ATR, 50)) × 50, clamped to 0–100. A reading of 50 means current ATR equals its 50-bar average; 100 means ATR is at least 2× its average; 25 means ATR has halved.
[/list]

[b]Total Score[/b] is the weight-normalised average of the three axes. All weights are user-configurable between 0 and 3; if all three are set to zero the indicator falls back to equal weights rather than producing a division by zero.

[b]Non-repainting[/b]

Every [i]ta.*[/i] read inside the security expression is shifted by [1] (previous confirmed bar) and the call is made with [i]lookahead = barmerge.lookahead_on[/i]. This is the standard pattern that guarantees displayed values do not change after the bar closes.

[b]Signal classification[/b]

The 9-pattern mapping combines Total Score thresholds (≥70, 50–69, <50) with Daily direction (Up / Flat / Down). Two cells are deliberately labelled "Divergence": high score on the chart timeframe with a bearish Daily, and low score with a bullish Daily. These are the two states where current-timeframe and higher-timeframe readings are in direct conflict.

[b]How To Use[/b]

[list=1]
[*]Add the indicator to any chart. The default preset loads 20 major and minor FX pairs; switch to Crypto Top 20 or US Stocks Top 20 from the Preset dropdown, or choose Custom and type your own tickers into the 20 slots.
[*]Read the sorted table from the top. The highest-ranked symbol is the one whose three axes best satisfy your current weighting.
[*]Check the Daily column before acting. A high Total Score with a bearish Daily direction will appear as "Divergence" in the Signal column — a warning that current-timeframe strength may be counter-trend relative to the daily bias.
[*]Open the chart of the symbol you want to study and run your own entry logic there. This indicator is a ranking and filtering tool; it does not place or suggest trades.
[*]Use the Score and Divergence alerts to be notified when any symbol crosses your chosen threshold or enters a divergent state, so you do not have to keep the chart open.
[/list]

[b]Settings[/b]

[list]
[*][b]Preset[/b] — FX Majors & Minors / Crypto Top 20 / US Stocks Top 20 / Custom.
[*][b]Symbol 1–20[/b] — Editable when Preset = Custom. Leaving a slot blank skips it.
[*][b]RSI Length / ROC Length[/b] — Defaults 14 / 10.
[*][b]Fast EMA / Slow EMA / ADX Length[/b] — Defaults 20 / 50 / 14.
[*][b]ATR Length / ATR SMA Length[/b] — Defaults 14 / 50.
[*][b]Momentum / Trend / Volatility Weight[/b] — Range 0–3, default 1.0 each.
[*][b]D1 Fast EMA / D1 Slow EMA / D1 Flat Threshold[/b] — Defaults 20 / 50 / 0.1%.
[*][b]Score Alert Threshold / Enable Divergence Alert[/b] — Defaults 70 / On.
[*][b]Table Position / Size / Max Rows / Sort By[/b] — Nine positions, three sizes, 5–20 rows, four sort options.
[/list]

[b]Platform Note[/b]

Because the indicator uses exactly 40 [i]request.security()[/i] calls (20 symbols × 2 timeframes), it fits the limit on every current TradingView plan. If a "Too many requests" message appears, switch to the Custom preset and leave unused slots blank — empty slots are skipped and free up calls.

[b]Limitations[/b]

[list]
[*]This indicator ranks and classifies symbols from past price data only. It does not forecast future prices and does not guarantee profit.
[*]Scores and signal labels are sensitive to the chosen inputs (RSI/ROC/EMA/ADX/ATR periods and the three axis weights). Results change materially with different settings — backtest and adjust to your own markets before acting on the output.
[*]The script needs enough historical bars to compute the longest lookback (default: 100 bars for ROC percentile-ranking and 50 bars for the ATR SMA). On very new symbols or low-history feeds, early bars will show N/A until the lookbacks fill.
[*]The ATR SMA Length is fixed at 50 by default; in abnormally quiet markets the Volatility score will sit near 50 and carry less information until the ratio moves.
[*]When all 20 symbols return N/A simultaneously (e.g., weekend FX close), the table displays a "Market may be closed" footer. Scores do not update until data resumes.
[*]The 40 [i]request.security()[/i] calls are the hard platform ceiling. Do not attempt to add more timeframes or symbols; empty Custom slots are skipped, but the 40-call structure itself cannot be extended.
[/list]

[b]Disclaimer[/b]

This is a screening and classification tool. It does not forecast price, does not place orders, and makes no claim about future returns. Scores describe the most recently completed bar only. Always conduct your own analysis and apply your own risk management.

## Source Code

````pine
// ============================================================================
// Multi-Symbol Momentum Screener
// ============================================================================
// WHAT: Scans 20 symbols simultaneously, scoring each on three axes
//       (Momentum / Trend / Volatility) to produce a 0-100 composite score.
//       Includes Daily direction column and 9-pattern signal classification.
//
// HOW:  Each symbol uses 2 request.security() calls (current TF + D1).
//       Scores are computed INSIDE the security expression via tuple return,
//       then assembled into a sorted heatmap table.
//
// NON-REPAINTING: All ta.* outputs are shifted by [1] (confirmed bar only).
//       Combined with lookahead = barmerge.lookahead_on, this ensures
//       the displayed values never change after the bar closes.
//
// request.security() BUDGET: 20 symbols x 2 TFs = 40 calls (Standard limit).
//       No room for additional security calls. Do NOT add more.
// ============================================================================

//@version=6
indicator("Multi-Symbol Momentum Screener", overlay = true, max_bars_back = 500)

// ──────────────────────────────────────────────────────────────────────────────
// Color Constants
// ──────────────────────────────────────────────────────────────────────────────
C_STRONG_BULL = #26a69a
C_BULL        = #4caf50
C_NEUTRAL     = #ff9800
C_BEAR        = #ef5350
C_STRONG_BEAR = #b71c1c
C_UP          = #26a69a
C_DOWN        = #ef5350
C_FLAT        = #787b86
C_HEADER_BG   = #1e222d
C_HEADER_TEXT  = #d1d4dc
C_ROW_ODD     = #1e222d
C_ROW_EVEN    = #131722
C_FOOTER_BG   = #1e222d
C_FOOTER_TEXT  = #787b86
C_DIVERG      = #ff9800

// ──────────────────────────────────────────────────────────────────────────────
// Inputs — Group 1: Watchlist
// ──────────────────────────────────────────────────────────────────────────────
GRP_WL = "Watchlist"
i_preset = input.string("FX Majors & Minors", "Preset", options = ["FX Majors & Minors", "Crypto Top 20", "US Stocks Top 20", "Custom"], group = GRP_WL, tooltip = "Select a preset watchlist or choose Custom to set your own symbols")

i_sym1  = input.symbol("FX:EURUSD",  "Symbol 1",  group = GRP_WL, tooltip = "Symbol for slot 1. Only used when Preset = Custom")
i_sym2  = input.symbol("FX:GBPUSD",  "Symbol 2",  group = GRP_WL, tooltip = "Symbol for slot 2. Only used when Preset = Custom")
i_sym3  = input.symbol("FX:USDJPY",  "Symbol 3",  group = GRP_WL, tooltip = "Symbol for slot 3. Only used when Preset = Custom")
i_sym4  = input.symbol("FX:AUDUSD",  "Symbol 4",  group = GRP_WL, tooltip = "Symbol for slot 4. Only used when Preset = Custom")
i_sym5  = input.symbol("FX:USDCAD",  "Symbol 5",  group = GRP_WL, tooltip = "Symbol for slot 5. Only used when Preset = Custom")
i_sym6  = input.symbol("FX:USDCHF",  "Symbol 6",  group = GRP_WL, tooltip = "Symbol for slot 6. Only used when Preset = Custom")
i_sym7  = input.symbol("FX:NZDUSD",  "Symbol 7",  group = GRP_WL, tooltip = "Symbol for slot 7. Only used when Preset = Custom")
i_sym8  = input.symbol("FX:EURGBP",  "Symbol 8",  group = GRP_WL, tooltip = "Symbol for slot 8. Only used when Preset = Custom")
i_sym9  = input.symbol("FX:EURJPY",  "Symbol 9",  group = GRP_WL, tooltip = "Symbol for slot 9. Only used when Preset = Custom")
i_sym10 = input.symbol("FX:GBPJPY",  "Symbol 10", group = GRP_WL, tooltip = "Symbol for slot 10. Only used when Preset = Custom")
i_sym11 = input.symbol("FX:AUDJPY",  "Symbol 11", group = GRP_WL, tooltip = "Symbol for slot 11. Only used when Preset = Custom")
i_sym12 = input.symbol("FX:EURAUD",  "Symbol 12", group = GRP_WL, tooltip = "Symbol for slot 12. Only used when Preset = Custom")
i_sym13 = input.symbol("FX:EURCHF",  "Symbol 13", group = GRP_WL, tooltip = "Symbol for slot 13. Only used when Preset = Custom")
i_sym14 = input.symbol("FX:GBPAUD",  "Symbol 14", group = GRP_WL, tooltip = "Symbol for slot 14. Only used when Preset = Custom")
i_sym15 = input.symbol("FX:GBPCAD",  "Symbol 15", group = GRP_WL, tooltip = "Symbol for slot 15. Only used when Preset = Custom")
i_sym16 = input.symbol("FX:CADJPY",  "Symbol 16", group = GRP_WL, tooltip = "Symbol for slot 16. Only used when Preset = Custom")
i_sym17 = input.symbol("FX:NZDJPY",  "Symbol 17", group = GRP_WL, tooltip = "Symbol for slot 17. Only used when Preset = Custom")
i_sym18 = input.symbol("FX:AUDCAD",  "Symbol 18", group = GRP_WL, tooltip = "Symbol for slot 18. Only used when Preset = Custom")
i_sym19 = input.symbol("FX:AUDNZD",  "Symbol 19", group = GRP_WL, tooltip = "Symbol for slot 19. Only used when Preset = Custom")
i_sym20 = input.symbol("FX:GBPCHF",  "Symbol 20", group = GRP_WL, tooltip = "Symbol for slot 20. Only used when Preset = Custom")

// ──────────────────────────────────────────────────────────────────────────────
// Inputs — Group 2: Scoring
// ──────────────────────────────────────────────────────────────────────────────
GRP_SC = "Scoring"
i_rsiLen   = input.int(14,  "RSI Length",       minval = 2,   maxval = 50,  step = 1,   group = GRP_SC, tooltip = "RSI period for Momentum score")
i_rocLen   = input.int(10,  "ROC Length",       minval = 1,   maxval = 50,  step = 1,   group = GRP_SC, tooltip = "Rate of Change period for Momentum score")
i_emaFast  = input.int(20,  "Fast EMA",         minval = 5,   maxval = 100, step = 1,   group = GRP_SC, tooltip = "Fast EMA period for Trend score")
i_emaSlow  = input.int(50,  "Slow EMA",         minval = 10,  maxval = 200, step = 1,   group = GRP_SC, tooltip = "Slow EMA period for Trend score")
i_adxLen   = input.int(14,  "ADX Length",       minval = 2,   maxval = 50,  step = 1,   group = GRP_SC, tooltip = "ADX period for Trend weighting")
i_atrLen   = input.int(14,  "ATR Length",       minval = 2,   maxval = 50,  step = 1,   group = GRP_SC, tooltip = "ATR period for Volatility score")
i_atrSmaLen = input.int(50, "ATR SMA Length",   minval = 10,  maxval = 200, step = 1,   group = GRP_SC, tooltip = "SMA period for ATR normalization")
i_wMom     = input.float(1.0, "Momentum Weight",  minval = 0, maxval = 3,   step = 0.1, group = GRP_SC, tooltip = "Weight for Momentum axis in Total Score")
i_wTrend   = input.float(1.0, "Trend Weight",     minval = 0, maxval = 3,   step = 0.1, group = GRP_SC, tooltip = "Weight for Trend axis in Total Score")
i_wVol     = input.float(1.0, "Volatility Weight", minval = 0, maxval = 3,  step = 0.1, group = GRP_SC, tooltip = "Weight for Volatility axis in Total Score")

// ──────────────────────────────────────────────────────────────────────────────
// Inputs — Group 3: D1 Direction
// ──────────────────────────────────────────────────────────────────────────────
GRP_D1 = "D1 Direction"
i_d1EmaFast   = input.int(20,    "D1 Fast EMA",        minval = 5,   maxval = 100, step = 1,    group = GRP_D1, tooltip = "Fast EMA period for Daily direction")
i_d1EmaSlow   = input.int(50,    "D1 Slow EMA",        minval = 10,  maxval = 200, step = 1,    group = GRP_D1, tooltip = "Slow EMA period for Daily direction")
i_d1FlatThresh = input.float(0.1, "D1 Flat Threshold", minval = 0,   maxval = 1.0, step = 0.05, group = GRP_D1, tooltip = "EMA divergence below this % is considered Flat")

// ──────────────────────────────────────────────────────────────────────────────
// Inputs — Group 4: Alert
// ──────────────────────────────────────────────────────────────────────────────
GRP_AL = "Alert"
i_alertThresh  = input.int(70,   "Score Alert Threshold", minval = 10, maxval = 100, step = 5, group = GRP_AL, tooltip = "Alert when Total Score exceeds this value")
i_alertDiverg  = input.bool(true, "Enable Divergence Alert", group = GRP_AL, tooltip = "Alert when Score and D1 direction diverge")

// ──────────────────────────────────────────────────────────────────────────────
// Inputs — Group 5: Display
// ──────────────────────────────────────────────────────────────────────────────
GRP_DS = "Display"
i_tblPos   = input.string("Top Right", "Table Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = GRP_DS, tooltip = "Dashboard position on chart")
i_tblSize  = input.string("Small", "Table Size", options = ["Tiny", "Small", "Normal"], group = GRP_DS, tooltip = "Dashboard text size")
i_showSig  = input.bool(true, "Show Signal Column", group = GRP_DS, tooltip = "Show the Signal column")
i_maxRows  = input.int(20, "Max Rows", minval = 5, maxval = 20, step = 1, group = GRP_DS, tooltip = "Maximum number of symbols to display")
i_sortBy   = input.string("Total Score", "Sort By", options = ["Total Score", "Momentum", "Trend", "Volatility"], group = GRP_DS, tooltip = "Column to sort by")

// ──────────────────────────────────────────────────────────────────────────────
// EMA validation: Fast must be < Slow
// ──────────────────────────────────────────────────────────────────────────────
emaSlowAdj   = i_emaSlow <= i_emaFast ? i_emaFast + 1 : i_emaSlow
d1EmaSlowAdj = i_d1EmaSlow <= i_d1EmaFast ? i_d1EmaFast + 1 : i_d1EmaSlow

// Weight fallback: if all zero, use equal weights
wMomAdj   = (i_wMom + i_wTrend + i_wVol) == 0 ? 1.0 : i_wMom
wTrendAdj = (i_wMom + i_wTrend + i_wVol) == 0 ? 1.0 : i_wTrend
wVolAdj   = (i_wMom + i_wTrend + i_wVol) == 0 ? 1.0 : i_wVol

// ──────────────────────────────────────────────────────────────────────────────
// Preset Switching — sym_1 ~ sym_20 determined BEFORE security calls
// ──────────────────────────────────────────────────────────────────────────────
sym_1  = i_preset == "FX Majors & Minors" ? "FX:EURUSD"  : i_preset == "Crypto Top 20" ? "BINANCE:BTCUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:AAPL"  : i_sym1
sym_2  = i_preset == "FX Majors & Minors" ? "FX:GBPUSD"  : i_preset == "Crypto Top 20" ? "BINANCE:ETHUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:MSFT"  : i_sym2
sym_3  = i_preset == "FX Majors & Minors" ? "FX:USDJPY"  : i_preset == "Crypto Top 20" ? "BINANCE:SOLUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:GOOGL" : i_sym3
sym_4  = i_preset == "FX Majors & Minors" ? "FX:AUDUSD"  : i_preset == "Crypto Top 20" ? "BINANCE:BNBUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:AMZN"  : i_sym4
sym_5  = i_preset == "FX Majors & Minors" ? "FX:USDCAD"  : i_preset == "Crypto Top 20" ? "BINANCE:XRPUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:NVDA"  : i_sym5
sym_6  = i_preset == "FX Majors & Minors" ? "FX:USDCHF"  : i_preset == "Crypto Top 20" ? "BINANCE:ADAUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:META"  : i_sym6
sym_7  = i_preset == "FX Majors & Minors" ? "FX:NZDUSD"  : i_preset == "Crypto Top 20" ? "BINANCE:DOGEUSD" : i_preset == "US Stocks Top 20" ? "NASDAQ:TSLA"  : i_sym7
sym_8  = i_preset == "FX Majors & Minors" ? "FX:EURGBP"  : i_preset == "Crypto Top 20" ? "BINANCE:AVAXUSD" : i_preset == "US Stocks Top 20" ? "NYSE:BRK.B"   : i_sym8
sym_9  = i_preset == "FX Majors & Minors" ? "FX:EURJPY"  : i_preset == "Crypto Top 20" ? "BINANCE:DOTUSD"  : i_preset == "US Stocks Top 20" ? "NYSE:JPM"     : i_sym9
sym_10 = i_preset == "FX Majors & Minors" ? "FX:GBPJPY"  : i_preset == "Crypto Top 20" ? "BINANCE:LINKUSD" : i_preset == "US Stocks Top 20" ? "NYSE:V"       : i_sym10
sym_11 = i_preset == "FX Majors & Minors" ? "FX:AUDJPY"  : i_preset == "Crypto Top 20" ? "BINANCE:MATICUSD": i_preset == "US Stocks Top 20" ? "NYSE:JNJ"     : i_sym11
sym_12 = i_preset == "FX Majors & Minors" ? "FX:EURAUD"  : i_preset == "Crypto Top 20" ? "BINANCE:ATOMUSD" : i_preset == "US Stocks Top 20" ? "NYSE:WMT"     : i_sym12
sym_13 = i_preset == "FX Majors & Minors" ? "FX:EURCHF"  : i_preset == "Crypto Top 20" ? "BINANCE:UNIUSD"  : i_preset == "US Stocks Top 20" ? "NYSE:PG"      : i_sym13
sym_14 = i_preset == "FX Majors & Minors" ? "FX:GBPAUD"  : i_preset == "Crypto Top 20" ? "BINANCE:LTCUSD"  : i_preset == "US Stocks Top 20" ? "NYSE:MA"      : i_sym14
sym_15 = i_preset == "FX Majors & Minors" ? "FX:GBPCAD"  : i_preset == "Crypto Top 20" ? "BINANCE:BCHUSD"  : i_preset == "US Stocks Top 20" ? "NYSE:HD"      : i_sym15
sym_16 = i_preset == "FX Majors & Minors" ? "FX:CADJPY"  : i_preset == "Crypto Top 20" ? "BINANCE:NEARUSD" : i_preset == "US Stocks Top 20" ? "NYSE:DIS"     : i_sym16
sym_17 = i_preset == "FX Majors & Minors" ? "FX:NZDJPY"  : i_preset == "Crypto Top 20" ? "BINANCE:APTUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:NFLX"  : i_sym17
sym_18 = i_preset == "FX Majors & Minors" ? "FX:AUDCAD"  : i_preset == "Crypto Top 20" ? "BINANCE:ARBUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:AMD"   : i_sym18
sym_19 = i_preset == "FX Majors & Minors" ? "FX:AUDNZD"  : i_preset == "Crypto Top 20" ? "BINANCE:OPUSD"   : i_preset == "US Stocks Top 20" ? "NYSE:CRM"     : i_sym19
sym_20 = i_preset == "FX Majors & Minors" ? "FX:GBPCHF"  : i_preset == "Crypto Top 20" ? "BINANCE:FILUSD"  : i_preset == "US Stocks Top 20" ? "NASDAQ:INTC"  : i_sym20

// ──────────────────────────────────────────────────────────────────────────────
// UDT Definition
// ──────────────────────────────────────────────────────────────────────────────
type ScreenerRow
    string symbol
    float  mom_score
    float  trend_score
    float  vol_score
    float  total_score
    float  d1_dir
    string signal

// ──────────────────────────────────────────────────────────────────────────────
// Helper Functions
// ──────────────────────────────────────────────────────────────────────────────

// 3-axis score calculation (runs inside request.security context)
f_calcScores() =>
    float rsi_val   = ta.rsi(close, i_rsiLen)[1]
    float roc_raw   = ta.roc(close, i_rocLen)
    float roc_rank  = ta.percentrank(roc_raw, 100)[1]
    float mom_score = (rsi_val + roc_rank) / 2.0

    float ema_fast  = ta.ema(close, i_emaFast)[1]
    float ema_slow  = ta.ema(close, emaSlowAdj)[1]
    float ema_div   = (ema_fast - ema_slow) / ema_slow * 100.0
    [_, _, adx_raw] = ta.dmi(i_adxLen, i_adxLen)
    float adx_val   = adx_raw[1]
    float ema_component = math.max(0.0, math.min(100.0, 50.0 + ema_div * 20.0))
    float adx_component = adx_val
    float trend_score   = (ema_component + adx_component) / 2.0

    float atr_raw   = ta.atr(i_atrLen)
    float atr_val   = atr_raw[1]
    float atr_sma   = ta.sma(atr_raw, i_atrSmaLen)[1]
    float vol_ratio = nz(atr_val / atr_sma, 1.0)
    float vol_score = math.max(0.0, math.min(100.0, vol_ratio * 50.0))

    [mom_score, trend_score, vol_score]

// D1 direction calculation (runs inside request.security context)
f_calcD1Dir() =>
    float d1_ema_fast = ta.ema(close, i_d1EmaFast)[1]
    float d1_ema_slow = ta.ema(close, d1EmaSlowAdj)[1]
    float d1_div_pct  = math.abs(d1_ema_fast - d1_ema_slow) / d1_ema_slow * 100.0
    float direction   = d1_div_pct < i_d1FlatThresh ? 0.0 : d1_ema_fast > d1_ema_slow ? 1.0 : -1.0
    direction

// Total score with weighted average
f_totalScore(float mom, float trend, float vol) =>
    float w_sum = wMomAdj + wTrendAdj + wVolAdj
    float total = w_sum > 0 ? (mom * wMomAdj + trend * wTrendAdj + vol * wVolAdj) / w_sum : 0.0
    math.max(0.0, math.min(100.0, total))

// 9-pattern signal classification
f_signal(float total, float d1_dir) =>
    string result = ""
    if total >= 70
        result := d1_dir > 0 ? "Strong Up" : d1_dir < 0 ? "Diverg." : "Mom. Up"
    else if total >= 50
        result := d1_dir > 0 ? "Mod. Up" : d1_dir < 0 ? "Mod. Dn" : "Flat"
    else
        result := d1_dir < 0 ? "Strong Dn" : d1_dir > 0 ? "Diverg." : "Weak"
    result

// Heatmap color based on score value
f_scoreColor(float score) =>
    switch
        score >= 80 => C_STRONG_BULL
        score >= 60 => C_BULL
        score >= 40 => C_NEUTRAL
        score >= 20 => C_BEAR
        => C_STRONG_BEAR

// Signal cell colors
f_signalBgColor(string sig) =>
    switch sig
        "Strong Up" => C_STRONG_BULL
        "Mom. Up"   => C_BULL
        "Mod. Up"   => C_BULL
        "Flat"      => C_FLAT
        "Diverg."   => C_DIVERG
        "Mod. Dn"   => C_BEAR
        "Strong Dn" => C_STRONG_BEAR
        "Weak"      => C_FLAT
        => C_FLAT

f_signalTextColor(string sig) =>
    sig == "Diverg." ? color.black : color.white

// Extract short symbol name from full ticker (e.g. "FX:EURUSD" -> "EURUSD")
f_shortName(string full) =>
    int colonPos = str.pos(full, ":")
    colonPos >= 0 ? str.substring(full, colonPos + 1) : full


// ──────────────────────────────────────────────────────────────────────────────
// request.security() x 40 calls — 20 symbols x (current TF + D1)
// ──────────────────────────────────────────────────────────────────────────────

// Symbol 1
[mom_1,  trend_1,  vol_1]  = request.security(sym_1,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_1  = request.security(sym_1,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 2
[mom_2,  trend_2,  vol_2]  = request.security(sym_2,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_2  = request.security(sym_2,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 3
[mom_3,  trend_3,  vol_3]  = request.security(sym_3,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_3  = request.security(sym_3,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 4
[mom_4,  trend_4,  vol_4]  = request.security(sym_4,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_4  = request.security(sym_4,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 5
[mom_5,  trend_5,  vol_5]  = request.security(sym_5,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_5  = request.security(sym_5,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 6
[mom_6,  trend_6,  vol_6]  = request.security(sym_6,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_6  = request.security(sym_6,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 7
[mom_7,  trend_7,  vol_7]  = request.security(sym_7,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_7  = request.security(sym_7,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 8
[mom_8,  trend_8,  vol_8]  = request.security(sym_8,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_8  = request.security(sym_8,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 9
[mom_9,  trend_9,  vol_9]  = request.security(sym_9,  "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_9  = request.security(sym_9,  "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 10
[mom_10, trend_10, vol_10] = request.security(sym_10, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_10 = request.security(sym_10, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 11
[mom_11, trend_11, vol_11] = request.security(sym_11, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_11 = request.security(sym_11, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 12
[mom_12, trend_12, vol_12] = request.security(sym_12, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_12 = request.security(sym_12, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 13
[mom_13, trend_13, vol_13] = request.security(sym_13, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_13 = request.security(sym_13, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 14
[mom_14, trend_14, vol_14] = request.security(sym_14, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_14 = request.security(sym_14, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 15
[mom_15, trend_15, vol_15] = request.security(sym_15, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_15 = request.security(sym_15, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 16
[mom_16, trend_16, vol_16] = request.security(sym_16, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_16 = request.security(sym_16, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 17
[mom_17, trend_17, vol_17] = request.security(sym_17, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_17 = request.security(sym_17, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 18
[mom_18, trend_18, vol_18] = request.security(sym_18, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_18 = request.security(sym_18, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 19
[mom_19, trend_19, vol_19] = request.security(sym_19, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_19 = request.security(sym_19, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// Symbol 20
[mom_20, trend_20, vol_20] = request.security(sym_20, "", f_calcScores(), lookahead = barmerge.lookahead_on)
d1_dir_20 = request.security(sym_20, "D", f_calcD1Dir(), lookahead = barmerge.lookahead_on)

// ──────────────────────────────────────────────────────────────────────────────
// ScreenerRow Array Construction + Sort
// ──────────────────────────────────────────────────────────────────────────────
var array<ScreenerRow> rows = array.new<ScreenerRow>(0)

if barstate.islast
    rows.clear()

    // Helper arrays for batch construction
    symArr   = array.from(sym_1,  sym_2,  sym_3,  sym_4,  sym_5,  sym_6,  sym_7,  sym_8,  sym_9,  sym_10,
                          sym_11, sym_12, sym_13, sym_14, sym_15, sym_16, sym_17, sym_18, sym_19, sym_20)
    momArr   = array.from(mom_1,  mom_2,  mom_3,  mom_4,  mom_5,  mom_6,  mom_7,  mom_8,  mom_9,  mom_10,
                          mom_11, mom_12, mom_13, mom_14, mom_15, mom_16, mom_17, mom_18, mom_19, mom_20)
    trendArr = array.from(trend_1,  trend_2,  trend_3,  trend_4,  trend_5,  trend_6,  trend_7,  trend_8,  trend_9,  trend_10,
                          trend_11, trend_12, trend_13, trend_14, trend_15, trend_16, trend_17, trend_18, trend_19, trend_20)
    volArr   = array.from(vol_1,  vol_2,  vol_3,  vol_4,  vol_5,  vol_6,  vol_7,  vol_8,  vol_9,  vol_10,
                          vol_11, vol_12, vol_13, vol_14, vol_15, vol_16, vol_17, vol_18, vol_19, vol_20)
    d1Arr    = array.from(d1_dir_1,  d1_dir_2,  d1_dir_3,  d1_dir_4,  d1_dir_5,  d1_dir_6,  d1_dir_7,  d1_dir_8,  d1_dir_9,  d1_dir_10,
                          d1_dir_11, d1_dir_12, d1_dir_13, d1_dir_14, d1_dir_15, d1_dir_16, d1_dir_17, d1_dir_18, d1_dir_19, d1_dir_20)

    for i = 0 to 19
        string sym = symArr.get(i)
        if str.length(sym) > 0
            float m = nz(momArr.get(i), 0.0)
            float t = nz(trendArr.get(i), 0.0)
            float v = nz(volArr.get(i), 0.0)
            float d = nz(d1Arr.get(i), 0.0)
            float total = f_totalScore(m, t, v)
            string sig  = f_signal(total, d)
            bool isNa   = na(momArr.get(i))
            rows.push(ScreenerRow.new(sym, isNa ? na : m, isNa ? na : t, isNa ? na : v, isNa ? na : total, isNa ? na : d, isNa ? "N/A" : sig))

    // Sort — bubble sort with array.set() (mandatory for UDT arrays)
    int n = rows.size()
    // Descending by selected score field
    if n > 1
        for i = 0 to n - 2
            for j = i + 1 to n - 1
                ScreenerRow ri = rows.get(i)
                ScreenerRow rj = rows.get(j)
                float val_i = switch i_sortBy
                    "Momentum"   => nz(ri.mom_score, 0.0)
                    "Trend"      => nz(ri.trend_score, 0.0)
                    "Volatility" => nz(ri.vol_score, 0.0)
                    => nz(ri.total_score, 0.0)
                float val_j = switch i_sortBy
                    "Momentum"   => nz(rj.mom_score, 0.0)
                    "Trend"      => nz(rj.trend_score, 0.0)
                    "Volatility" => nz(rj.vol_score, 0.0)
                    => nz(rj.total_score, 0.0)
                if val_j > val_i
                    ScreenerRow tmp = rows.get(i)
                    rows.set(i, rows.get(j))
                    rows.set(j, tmp)

// ──────────────────────────────────────────────────────────────────────────────
// Table Rendering
// ──────────────────────────────────────────────────────────────────────────────

// Map position string to position constant
tblPosition = switch i_tblPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    => position.bottom_right

// Map size string to size constant
tblTextSize = switch i_tblSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    => size.small

int numCols = i_showSig ? 7 : 6

var table tbl = table(na)
if barstate.islast
    if not na(tbl)
        table.delete(tbl)
    tbl := table.new(tblPosition, numCols, 24, border_width = 1)

    // ── Header row ──
    table.cell(tbl, 0, 0, "Symbol", text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)
    table.cell(tbl, 1, 0, "Mom",    text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)
    table.cell(tbl, 2, 0, "Trend",  text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)
    table.cell(tbl, 3, 0, "Vol",    text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)
    table.cell(tbl, 4, 0, "Score",  text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)
    table.cell(tbl, 5, 0, "D1",     text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)
    if i_showSig
        table.cell(tbl, 6, 0, "Signal", text_color = C_HEADER_TEXT, bgcolor = C_HEADER_BG, text_size = tblTextSize, text_halign = text.align_center)

    // ── Data rows ──
    int dispRows = math.min(rows.size(), i_maxRows)
    int allNaCount = 0

    for i = 0 to dispRows - 1
        ScreenerRow r = rows.get(i)
        int row = i + 1
        color rowBg = i % 2 == 0 ? C_ROW_ODD : C_ROW_EVEN
        string shortSym = f_shortName(r.symbol)

        bool isNa = na(r.mom_score)

        // Symbol column
        table.cell(tbl, 0, row, shortSym, text_color = color.white, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_left)

        if isNa
            allNaCount += 1
            // N/A row — grey out all cells
            table.cell(tbl, 1, row, "N/A", text_color = C_FLAT, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_center)
            table.cell(tbl, 2, row, "N/A", text_color = C_FLAT, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_center)
            table.cell(tbl, 3, row, "N/A", text_color = C_FLAT, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_center)
            table.cell(tbl, 4, row, "N/A", text_color = C_FLAT, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_center)
            table.cell(tbl, 5, row, "--",  text_color = C_FLAT, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_center)
            if i_showSig
                table.cell(tbl, 6, row, "N/A", text_color = C_FLAT, bgcolor = rowBg, text_size = tblTextSize, text_halign = text.align_center)
        else
            // Mom
            table.cell(tbl, 1, row, str.tostring(r.mom_score, "#"), text_color = color.white, bgcolor = f_scoreColor(r.mom_score), text_size = tblTextSize, text_halign = text.align_center)
            // Trend
            table.cell(tbl, 2, row, str.tostring(r.trend_score, "#"), text_color = color.white, bgcolor = f_scoreColor(r.trend_score), text_size = tblTextSize, text_halign = text.align_center)
            // Vol
            table.cell(tbl, 3, row, str.tostring(r.vol_score, "#"), text_color = color.white, bgcolor = f_scoreColor(r.vol_score), text_size = tblTextSize, text_halign = text.align_center)
            // Total Score
            table.cell(tbl, 4, row, str.tostring(r.total_score, "#"), text_color = color.white, bgcolor = f_scoreColor(r.total_score), text_size = tblTextSize, text_halign = text.align_center)
            // D1 Direction
            string d1Text   = r.d1_dir > 0 ? "Up" : r.d1_dir < 0 ? "Dn" : "--"
            color  d1Bg     = r.d1_dir > 0 ? C_UP  : r.d1_dir < 0 ? C_DOWN : C_FLAT
            table.cell(tbl, 5, row, d1Text, text_color = color.white, bgcolor = d1Bg, text_size = tblTextSize, text_halign = text.align_center)
            // Signal
            if i_showSig
                table.cell(tbl, 6, row, r.signal, text_color = f_signalTextColor(r.signal), bgcolor = f_signalBgColor(r.signal), text_size = tblTextSize, text_halign = text.align_center)

    // ── Footer row 1: Sort info + TF ──
    int footerRow1 = dispRows + 1
    string sortLabel = i_sortBy == "Total Score" ? "Score" : i_sortBy
    string tfLabel   = timeframe.period
    string footer1   = "Sorted by " + sortLabel + " | TF: " + tfLabel
    table.cell(tbl, 0, footerRow1, footer1, text_color = C_FOOTER_TEXT, bgcolor = C_FOOTER_BG, text_size = tblTextSize, text_halign = text.align_left)
    table.merge_cells(tbl, 0, footerRow1, numCols - 1, footerRow1)

    // ── Footer row 2: Brand + market status ──
    int footerRow2 = dispRows + 2
    string footer2Txt = allNaCount == dispRows ? "Market may be closed | ShigemiQuant" : "ShigemiQuant"
    table.cell(tbl, 0, footerRow2, footer2Txt, text_color = C_FOOTER_TEXT, bgcolor = C_FOOTER_BG, text_size = tblTextSize, text_halign = text.align_left)
    table.merge_cells(tbl, 0, footerRow2, numCols - 1, footerRow2)

// ──────────────────────────────────────────────────────────────────────────────
// Alert Conditions
// ──────────────────────────────────────────────────────────────────────────────
if barstate.islast
    // Score Alert: symbols exceeding threshold
    string scoreAlertMsg = ""
    for i = 0 to rows.size() - 1
        ScreenerRow r = rows.get(i)
        if not na(r.total_score) and r.total_score >= i_alertThresh
            scoreAlertMsg += f_shortName(r.symbol) + "(" + str.tostring(r.total_score, "#") + ") "

    if str.length(scoreAlertMsg) > 0
        alert("Momentum Screener - Score >= " + str.tostring(i_alertThresh) + ": " + scoreAlertMsg, alert.freq_once_per_bar_close)

    // Divergence Alert: Total >= 60 and D1 direction opposite
    if i_alertDiverg
        string divergAlertMsg = ""
        for i = 0 to rows.size() - 1
            ScreenerRow r = rows.get(i)
            if not na(r.total_score) and not na(r.d1_dir)
                bool isDiverg = (r.total_score >= 60 and r.d1_dir < 0) or (r.total_score < 50 and r.d1_dir > 0)
                if isDiverg
                    divergAlertMsg += f_shortName(r.symbol) + "(" + str.tostring(r.total_score, "#") + ") "

        if str.length(divergAlertMsg) > 0
            alert("Momentum Screener - Divergence: " + divergAlertMsg, alert.freq_once_per_bar_close)
````
