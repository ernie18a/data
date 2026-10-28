# Aquila Reale Correlations v1.1

- url: https://www.tradingview.com/script/ZkxSzD1Q/
- type: indicator
- pine_id: PUB;ddd7dfd4f9b94ad38c4e5342c456e3fd
- version: 1.0

## Description

🦅 AQUILA REALE CORRELATIONS v1.1

Inter-market correlation dashboard for any two assets, with multi-timeframe analysis, spread monitoring, and regime detection.

═══════════════════════════════════════════════════
📊 WHAT THIS INDICATOR DOES
═══════════════════════════════════════════════════

Calculates the Pearson correlation coefficient between two user-defined assets across 4 timeframes simultaneously (15M, 1H, 4H, Daily) and presents the result in a single-glance dashboard.

Default configuration: XAUUSD vs WTI (FP Markets), but fully configurable for any pair — Gold/DXY, BTC/SPX, EUR/USD vs DXY, equities vs bonds, etc.

The dashboard provides:

- Multi-timeframe correlation matrix with regime classification (STRONG DIRECT / WEAK DIRECT / NEUTRAL / WEAK INVERSE / STRONG INVERSE) on 15M, 1H, 4H, and Daily

- Aggregate count to identify if the correlation regime is consistent across timeframes or in transition

- Spread analysis (ratio Asset1 / Asset2) with deviation from medium-term (EMA50) and long-term (EMA200) averages, plus configurable historical thresholds

- Regime verdict: DIRECT / INVERSE / NEUTRAL / AMBIGUOUS, declared only when ≥3 of 4 timeframes are aligned

- Pre-configured alerts for regime shifts, spread extremes, and 4H correlation crossings


═══════════════════════════════════════════════════
🎯 USE CASES
═══════════════════════════════════════════════════

1. Detect regime shifts: Know when historically uncorrelated assets are temporarily moving in lockstep, or vice versa.

2. Validate macro thesis: Confirm your inter-market reading with a numeric measure across multiple timeframes.

3. Identify spread extremes: Spot when asset relationships are stretched (e.g. Gold/Oil ratio above 40 historically signals macroeconomic stress).

4. Filter trade signals: Use the regime verdict as a context filter for other strategies and indicators.


═══════════════════════════════════════════════════
⚙️ SETTINGS
═══════════════════════════════════════════════════

- Symbols: Asset 1 and Asset 2 (any TradingView symbol)
- Correlation period: Default 50 candles (lower = reactive but noisy; higher = stable but lagging)
- Strong/Neutral thresholds: Configurable correlation cutoffs (defaults 0.5 / 0.2)
- Spread EMAs: Fast and slow EMAs applied to the asset ratio
- Historical spread thresholds: Customizable per asset pair
- Layout: 3 sections individually toggleable, 9 position options on the chart


═══════════════════════════════════════════════════
📌 IMPORTANT NOTES ON INTERPRETATION
═══════════════════════════════════════════════════

- Correlation is a STATISTICAL measure, not a directional trading signal. A strong inverse correlation does not mean "go long one and short the other" — it means the two assets are moving in opposite directions over the lookback window.

- Strong correlations across multiple timeframes suggest a stable regime; mixed readings across timeframes indicate transition or noise.

- For Gold/WTI specifically: the historical baseline correlation is weakly DIRECT (approximately +0.3 to +0.5). Strong INVERSE readings typically reflect temporary supply-side shocks affecting only one asset (e.g. geopolitical events impacting oil supply) and tend to revert over time.

- Correlation is a LAGGING indicator. A change in market regime is reflected in the rolling coefficient only after several candles. Use it for context, not for timing entries.

- The "AMBIGUOUS" verdict is informative: it tells you the correlation structure is not stable, and inter-market signals should be treated with extra caution.


═══════════════════════════════════════════════════
⚠️ WARNINGS AND DISCLAIMERS
═══════════════════════════════════════════════════

NOT FINANCIAL ADVICE
This script is for educational and informational purposes only. It does not constitute financial, investment, or trading advice. Nothing in this indicator should be interpreted as a recommendation to buy, sell, or hold any financial instrument.

NO GUARANTEE OF FUTURE BEHAVIOR
Past correlation patterns do not guarantee future behavior. Asset relationships change over time, especially in response to macroeconomic regime shifts, central bank policy changes, geopolitical events, and structural market changes.

USE AT YOUR OWN RISK
Trading financial instruments (stocks, forex, crypto, futures, CFDs, commodities) carries a high level of risk and may not be suitable for all investors. Before making any trading decision you should carefully consider your investment objectives, level of experience, and risk appetite. You may sustain a loss of some or all of your initial capital.

NOT A STANDALONE SYSTEM
This indicator does NOT generate buy/sell signals. It provides context for macro analysis. Always combine it with your own technical analysis, fundamental analysis, and proper risk management.

DO YOUR OWN RESEARCH
Always cross-check signals against multiple tools and your own market analysis. Do not rely on a single indicator for trading decisions. Past performance shown in any chart or example is not indicative of future results.

DATA LIMITATIONS
Correlation calculations rely on accurate price data from the broker/exchange feed. Results may vary across different data providers. Volume data on forex and CFD instruments comes from individual brokers and may not reflect true market activity.

NO AFFILIATION
The author is not affiliated with TradingView, any broker, exchange, or financial institution. This script is independent and provided free of charge.

LIABILITY
The author shall not be held liable for any loss or damage, including but not limited to financial losses, arising from the use of this indicator. By using this script you accept full responsibility for your trading and investment decisions.

PAPER TRADE FIRST
Always test any indicator and the strategies built around it on a demo account or with paper trading before risking real capital.

By using this indicator you acknowledge that you have read, understood, and accepted all the above terms.


═══════════════════════════════════════════════════
💬 FEEDBACK
═══════════════════════════════════════════════════

This is v1.1, the first public release. Feedback is welcome — please leave a comment if you find bugs, have suggestions, or want to share your results with different asset pairs.

Happy charting! 🦅 Born to fly, born to dare.

## Source Code

````pine
//@version=5
// ═══════════════════════════════════════════════════════════════
//  🦅 AQUILA REALE - CORRELATIONS v1.1
//  © giua64 — 2026
//
//  Inter-market correlation dashboard for any two assets.
//  Default: XAUUSD vs WTI (FP Markets), but fully configurable
//  for any pair (Gold/DXY, BTC/SPX, EUR/USD vs DXY, etc.).
//
//  ─────────────────────────────────────────────────────────────
//  WHAT IT DOES
//  ─────────────────────────────────────────────────────────────
//  Calculates the Pearson correlation coefficient between two
//  user-defined assets across 4 timeframes simultaneously
//  (15M, 1H, 4H, Daily) and classifies each as DIRECT, INVERSE,
//  or NEUTRAL based on configurable thresholds.
//
//  Also computes the spread (ratio) between the two assets,
//  with deviation from medium and long-term EMAs, and flags
//  historical extremes (configurable).
//
//  Provides a single-glance VERDICT on the dominant correlation
//  regime: DIRECT / INVERSE / NEUTRAL / AMBIGUOUS.
//
//  ─────────────────────────────────────────────────────────────
//  HOW TO USE
//  ─────────────────────────────────────────────────────────────
//  1. Add the indicator to any chart (timeframe doesn't matter,
//     correlations are calculated on fixed timeframes internally).
//  2. Configure Asset 1 and Asset 2 in the settings.
//  3. Read the dashboard:
//     - 4 timeframe correlations
//     - Aggregate count (Dir / Inv / Neut)
//     - Spread vs historical ranges
//     - Regime verdict
//  4. Use alerts to be notified when the regime changes.
//
//  ─────────────────────────────────────────────────────────────
//  INTERPRETATION NOTES
//  ─────────────────────────────────────────────────────────────
//  - Correlation is a STATISTICAL measure, not a trading signal.
//  - High inverse/direct correlation across multiple timeframes
//    indicates a stable regime; mixed signals indicate transition.
//  - For Gold/WTI specifically: historical baseline is weakly
//    DIRECT (+0.3 / +0.5). Strong INVERSE readings typically
//    reflect temporary supply-side shocks affecting only one asset.
//
//  ─────────────────────────────────────────────────────────────
//  DISCLAIMER
//  ─────────────────────────────────────────────────────────────
//  This script is for educational and informational purposes only.
//  It does NOT constitute financial advice. Past correlation
//  patterns do not guarantee future behavior. Always conduct your
//  own analysis and risk management before any trading decision.
// ═══════════════════════════════════════════════════════════════
indicator("🦅 Aquila Reale Correlations v1.1", overlay=true, max_bars_back=1000)

// ═══════════════════════════════════════════════
// INPUT - SYMBOLS
// ═══════════════════════════════════════════════
asset1     = input.symbol("FPMARKETS:XAUUSD", "Asset 1 (primary)", group="Symbols",
     tooltip="The reference asset (usually the one you are trading).\nDefault: XAUUSD on FP Markets.")
asset2     = input.symbol("FPMARKETS:WTI",    "Asset 2 (correlated)",  group="Symbols",
     tooltip="The comparison asset against which to measure correlation.\nDefault: WTI on FP Markets.")

// ═══════════════════════════════════════════════
// INPUT - CORRELATION PARAMETERS
// ═══════════════════════════════════════════════
corrLen    = input.int(50, "Correlation period", minval=10, maxval=200, group="Correlation Parameters",
     tooltip="Number of candles for correlation coefficient calculation.\nDefault 50 = balanced.\nLower values (20) = more reactive but noisy.\nHigher values (100) = more stable but lagging.")
threshStr  = input.float(0.5, "STRONG correlation threshold",   minval=0.3, maxval=0.9, step=0.05, group="Correlation Parameters",
     tooltip="Above this threshold (absolute value) the correlation is considered STRONG.\nDefault 0.5.")
threshWeak = input.float(0.2, "NEUTRAL correlation threshold",  minval=0.1, maxval=0.4, step=0.05, group="Correlation Parameters",
     tooltip="Below this threshold (absolute value) the correlation is considered NEUTRAL (non-informative).\nDefault 0.2.")

// ═══════════════════════════════════════════════
// INPUT - SPREAD CHART
// ═══════════════════════════════════════════════
emaFastLen = input.int(50,  "Fast EMA on spread",  minval=10, group="Spread Asset1/Asset2")
emaSlowLen = input.int(200, "Slow EMA on spread",  minval=50, group="Spread Asset1/Asset2")
spreadHigh = input.float(40.0, "HIGH spread threshold (e.g. Gold/Oil >40)", group="Spread Asset1/Asset2",
     tooltip="For Gold/Oil: >40 is historically extreme (often pre-recession).\nFor other pairs, calibrate based on your pair's historical range.")
spreadLow  = input.float(20.0, "LOW spread threshold (e.g. Gold/Oil <20)", group="Spread Asset1/Asset2",
     tooltip="For Gold/Oil: <20 is historically low (expansion phase).")

// ═══════════════════════════════════════════════
// INPUT - LAYOUT
// ═══════════════════════════════════════════════
sizeOpt    = input.string("small",        "Text size", options=["tiny","small","normal","large"], group="Layout")
posOpt     = input.string("bottom_left",  "Position",  options=["top_left","top_center","top_right","middle_left","middle_center","middle_right","bottom_left","bottom_center","bottom_right"], group="Layout")
showSpread = input.bool(true, "Show SPREAD section", group="Layout")
showVerdict = input.bool(true, "Show VERDICT + Suggestion", group="Layout")

// ═══════════════════════════════════════════════
// COLORI
// ═══════════════════════════════════════════════
c_hdr   = color.rgb(20,20,60)
c_bg    = color.rgb(40,40,40)
c_txt   = color.white
c_yel   = color.yellow
c_long  = color.new(#00c853, 0)
c_short = color.new(#d50000, 0)
c_neut  = color.rgb(80,80,80)
c_warn  = color.rgb(255,152,0)
c_strong = color.new(#FFD700, 0)

// ═══════════════════════════════════════════════
// HELPERS LAYOUT
// ═══════════════════════════════════════════════
getPos(p) =>
    switch p
        "top_left"      => position.top_left
        "top_center"    => position.top_center
        "top_right"     => position.top_right
        "middle_left"   => position.middle_left
        "middle_center" => position.middle_center
        "middle_right"  => position.middle_right
        "bottom_left"   => position.bottom_left
        "bottom_center" => position.bottom_center
        =>                 position.bottom_right

getSz(s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        =>         size.normal

txtSz  = getSz(sizeOpt)
tabPos = getPos(posOpt)

// ═══════════════════════════════════════════════
// FUNZIONE CORRELAZIONE MTF
// ═══════════════════════════════════════════════
// Calcola la correlazione tra asset1 e asset2 al timeframe specificato.
// Ritorna il coefficient su 'corrLen' candele.
f_corrTF(tf) =>
    c1 = request.security(asset1, tf, close, lookahead=barmerge.lookahead_off)
    c2 = request.security(asset2, tf, close, lookahead=barmerge.lookahead_off)
    ta.correlation(c1, c2, corrLen)

corr_15m = f_corrTF("15")
corr_1h  = f_corrTF("60")
corr_4h  = f_corrTF("240")
corr_D   = f_corrTF("D")

// ═══════════════════════════════════════════════
// FUNZIONE: classificazione correlazione
// ═══════════════════════════════════════════════
// Ritorna [label, color]
f_corrLabel(c) =>
    string lbl = ""
    color  col = c_neut
    if na(c)
        lbl := "—"
        col := c_neut
    else if c >= threshStr
        lbl := "STRONG DIRECT"
        col := c_long
    else if c >= threshWeak
        lbl := "WEAK DIRECT"
        col := color.new(#00c853, 40)
    else if c <= -threshStr
        lbl := "STRONG INVERSE"
        col := c_short
    else if c <= -threshWeak
        lbl := "WEAK INVERSE"
        col := color.new(#d50000, 40)
    else
        lbl := "NEUTRAL"
        col := c_neut
    [lbl, col]

[lbl_15m, col_15m] = f_corrLabel(corr_15m)
[lbl_1h, col_1h] = f_corrLabel(corr_1h)
[lbl_4h, col_4h] = f_corrLabel(corr_4h)
[lbl_D,  col_D]  = f_corrLabel(corr_D)

// ═══════════════════════════════════════════════
// SPREAD CALCOLATO SUL CHART
// ═══════════════════════════════════════════════
// Prendiamo prezzi al timeframe del chart, calcoliamo spread = asset1 / asset2
p1_now = request.security(asset1, timeframe.period, close, lookahead=barmerge.lookahead_off)
p2_now = request.security(asset2, timeframe.period, close, lookahead=barmerge.lookahead_off)
spread = p2_now != 0 ? p1_now / p2_now : na

// Per le EMA dello spread, calcolo lo spread su tutta la serie e poi EMA
p1_series = request.security(asset1, timeframe.period, close, lookahead=barmerge.lookahead_off)
p2_series = request.security(asset2, timeframe.period, close, lookahead=barmerge.lookahead_off)
spread_series = p2_series != 0 ? p1_series / p2_series : na
emaFastSpread = ta.ema(spread_series, emaFastLen)
emaSlowSpread = ta.ema(spread_series, emaSlowLen)

devFast = not na(spread) and not na(emaFastSpread) and emaFastSpread != 0 ? (spread - emaFastSpread) / emaFastSpread * 100 : na
devSlow = not na(spread) and not na(emaSlowSpread) and emaSlowSpread != 0 ? (spread - emaSlowSpread) / emaSlowSpread * 100 : na

f_devStr(d) =>
    na(d) ? "—" : (d > 0 ? "+" : "") + str.tostring(d, "#.##") + "%"
f_devCol(d) =>
    na(d) ? c_neut : d > 1 ? c_long : d < -1 ? c_short : c_neut

f_spreadStatus(s) =>
    string lbl = ""
    color  col = c_neut
    if na(s)
        lbl := "—"
        col := c_neut
    else if s >= spreadHigh
        lbl := "⚠ HIGH (extreme)"
        col := c_warn
    else if s <= spreadLow
        lbl := "⚠ LOW (extreme)"
        col := c_warn
    else
        lbl := "✓ within historical range"
        col := c_long
    [lbl, col]

[spreadLbl, spreadCol] = f_spreadStatus(spread)

// ═══════════════════════════════════════════════
// VERDETTO REGIME
// ═══════════════════════════════════════════════
// Logica:
// - se tutti e 3 i TF sono DIRETTI → regime DIRETTO chiaro
// - se tutti e 3 i TF sono INVERSI → regime INVERSO chiaro
// - se misti o tutti NEUTRI → regime AMBIGUO
f_isDir(c)     => not na(c) and c >= threshWeak
f_isInv(c)     => not na(c) and c <= -threshWeak
f_isNeut(c)    => not na(c) and math.abs(c) < threshWeak

countDir  = (f_isDir(corr_15m) ? 1 : 0) + (f_isDir(corr_1h) ? 1 : 0) + (f_isDir(corr_4h) ? 1 : 0) + (f_isDir(corr_D) ? 1 : 0)
countInv  = (f_isInv(corr_15m) ? 1 : 0) + (f_isInv(corr_1h) ? 1 : 0) + (f_isInv(corr_4h) ? 1 : 0) + (f_isInv(corr_D) ? 1 : 0)
countNeut = (f_isNeut(corr_15m) ? 1 : 0) + (f_isNeut(corr_1h) ? 1 : 0) + (f_isNeut(corr_4h) ? 1 : 0) + (f_isNeut(corr_D) ? 1 : 0)

string verdictTxt = ""
color  verdictCol = c_neut
string suggestion = ""

if countDir >= 3 and countInv == 0
    verdictTxt := "🟢 DIRECT REGIME"
    verdictCol := c_long
    suggestion := "Treat assets as positively correlated"
else if countInv >= 3 and countDir == 0
    verdictTxt := "🔴 INVERSE REGIME"
    verdictCol := c_short
    suggestion := "Treat assets as negatively correlated"
else if countNeut >= 3
    verdictTxt := "⚪ NEUTRAL REGIME"
    verdictCol := c_neut
    suggestion := "Correlation not informative"
else
    verdictTxt := "🟡 AMBIGUOUS REGIME"
    verdictCol := c_warn
    suggestion := "Use caution: regime is shifting"

// ═══════════════════════════════════════════════
// FORMATTING
// ═══════════════════════════════════════════════
f_corrStr(c) => na(c) ? "—" : (c > 0 ? "+" : "") + str.tostring(c, "0.00")

string name1 = syminfo.ticker(asset1)
string name2 = syminfo.ticker(asset2)

// ═══════════════════════════════════════════════
// TABELLA
// ═══════════════════════════════════════════════
// Numero righe variabile in base alle sezioni abilitate (con 4 TF: 15M, 1H, 4H, D)
nRows = 7 + (showSpread ? 4 : 0) + (showVerdict ? 2 : 0)

var table dash = na

if barstate.islast
    table.delete(dash)
    dash := table.new(tabPos, 3, nRows, border_width=1, border_color=color.new(color.gray, 60), frame_color=color.new(color.gray, 40), frame_width=2)

    // Header
    table.cell(dash, 0, 0, "🦅", text_color=color.black, bgcolor=color.white, text_size=size.large, text_halign=text.align_center)
    table.cell(dash, 1, 0, "CORRELATIONS v1.1", text_color=c_txt, bgcolor=c_hdr, text_size=txtSz, text_halign=text.align_center)
    table.cell(dash, 2, 0, name1 + " vs " + name2, text_color=c_yel, bgcolor=c_hdr, text_size=txtSz, text_halign=text.align_center)

    // Sezione correlazione header
    table.cell(dash, 0, 1, "TF",          text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)
    table.cell(dash, 1, 1, "Coefficient", text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)
    table.cell(dash, 2, 1, "Regime",      text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)

    // Riga 15M
    table.cell(dash, 0, 2, "15M", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 1, 2, f_corrStr(corr_15m), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 2, 2, lbl_15m, text_color=c_txt, bgcolor=col_15m, text_size=txtSz)

    // Riga 1H
    table.cell(dash, 0, 3, "1H", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 1, 3, f_corrStr(corr_1h), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 2, 3, lbl_1h, text_color=c_txt, bgcolor=col_1h, text_size=txtSz)

    // Riga 4H
    table.cell(dash, 0, 4, "4H", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 1, 4, f_corrStr(corr_4h), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 2, 4, lbl_4h, text_color=c_txt, bgcolor=col_4h, text_size=txtSz)

    // Riga D
    table.cell(dash, 0, 5, "Daily", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 1, 5, f_corrStr(corr_D), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 2, 5, lbl_D, text_color=c_txt, bgcolor=col_D, text_size=txtSz)

    // Conteggio per leggere a colpo d'occhio
    table.cell(dash, 0, 6, "COUNT", text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)
    table.cell(dash, 1, 6, "Dir:" + str.tostring(countDir) + " Inv:" + str.tostring(countInv) + " Neu:" + str.tostring(countNeut), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
    table.cell(dash, 2, 6, "Period " + str.tostring(corrLen), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)

    // SEZIONE SPREAD (opzionale)
    rowIdx = 7
    if showSpread
        table.cell(dash, 0, rowIdx, "SPREAD", text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)
        table.cell(dash, 1, rowIdx, na(spread) ? "—" : str.tostring(spread, "#.##"), text_color=c_yel, bgcolor=c_bg, text_size=txtSz)
        table.cell(dash, 2, rowIdx, spreadLbl, text_color=c_txt, bgcolor=spreadCol, text_size=txtSz)
        rowIdx += 1

        table.cell(dash, 0, rowIdx, "vs EMA" + str.tostring(emaFastLen), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        table.cell(dash, 1, rowIdx, f_devStr(devFast), text_color=c_txt, bgcolor=f_devCol(devFast), text_size=txtSz)
        table.cell(dash, 2, rowIdx, devFast > 0 ? "above mid trend" : devFast < 0 ? "below mid trend" : "in line", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        rowIdx += 1

        table.cell(dash, 0, rowIdx, "vs EMA" + str.tostring(emaSlowLen), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        table.cell(dash, 1, rowIdx, f_devStr(devSlow), text_color=c_txt, bgcolor=f_devCol(devSlow), text_size=txtSz)
        table.cell(dash, 2, rowIdx, devSlow > 0 ? "above long trend" : devSlow < 0 ? "below long trend" : "in line", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        rowIdx += 1

        table.cell(dash, 0, rowIdx, "OK Range", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        table.cell(dash, 1, rowIdx, str.tostring(spreadLow, "#") + " - " + str.tostring(spreadHigh, "#"), text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        table.cell(dash, 2, rowIdx, "historical thresholds", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        rowIdx += 1

    // SEZIONE VERDETTO (opzionale)
    if showVerdict
        table.cell(dash, 0, rowIdx, "VERDICT", text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)
        table.cell(dash, 1, rowIdx, verdictTxt, text_color=verdictCol == c_warn ? color.black : c_txt, bgcolor=verdictCol, text_size=txtSz)
        table.cell(dash, 2, rowIdx, suggestion, text_color=c_txt, bgcolor=c_hdr, text_size=txtSz)
        rowIdx += 1

        table.cell(dash, 0, rowIdx, "PERIOD", text_color=c_yel, bgcolor=c_hdr, text_size=txtSz)
        table.cell(dash, 1, rowIdx, "50 candles", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)
        table.cell(dash, 2, rowIdx, "configurable", text_color=c_txt, bgcolor=c_bg, text_size=txtSz)

// ═══════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════
alertcondition(countDir >= 3 and countInv == 0,                                "Regime DIRETTO",         "Correlazioni: regime DIRETTO consolidato")
alertcondition(countInv >= 3 and countDir == 0,                                "Regime INVERSO",         "Correlazioni: regime INVERSO consolidato")
alertcondition(countNeut >= 3,                                                 "Regime NEUTRO",          "Correlazioni: regime NEUTRO — WTI non vota")
alertcondition(not na(spread) and spread >= spreadHigh,                        "Extreme HIGH spread",    "Spread above historical high threshold")
alertcondition(not na(spread) and spread <= spreadLow,                         "Extreme LOW spread",     "Spread below historical low threshold")
alertcondition(not na(corr_4h) and corr_4h >= threshStr and corr_4h[1] < threshStr, "Corr 4H enters STRONG DIRECT", "4H correlation crossed above direct threshold")
alertcondition(not na(corr_4h) and corr_4h <= -threshStr and corr_4h[1] > -threshStr, "Corr 4H enters STRONG INVERSE", "4H correlation crossed below inverse threshold")
````
