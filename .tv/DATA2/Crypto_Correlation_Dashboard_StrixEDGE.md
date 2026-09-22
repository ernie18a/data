<!-- tradingview-pine-id: PUB;ef609b6ade71499da0924d2879703464 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Crypto Correlation Dashboard [StrixEDGE]

Source: https://www.tradingview.com/script/eLrbEagy-Crypto-Correlation-Dashboard-StrixEDGE/

## Description

Overview

A real-time Pearson correlation matrix built for crypto portfolio analysis. Tracks the statistical co-movement between up to 6 assets across selectable timeframes, using log-return correlation — not raw price correlation — to avoid the inflated readings that plague most correlation tools.

Whether you're managing a multi-asset portfolio, hunting pairs trades, or monitoring regime shifts, this dashboard tells you exactly when diversification is real and when it's an illusion.

🔍 What Makes This Different

Most correlation indicators on TradingView calculate Pearson r on raw closing prices. That's a statistical mistake: two assets trending upward will always show near-perfect correlation on price, even if their returns are completely independent. This indicator correlates **logarithmic returns**, which isolates actual co-movement from shared trend bias.

The multi-timeframe engine uses a period-scaling method through `request.security` that preserves mathematical accuracy when projecting higher-timeframe correlations onto lower-timeframe charts — consuming only 6 security calls total, leaving headroom for other indicators on your layout.

⚡ Key Features

6×6 Correlation Matrix
Full heatmap-style matrix covering all 15 unique pair combinations (C(6,2)). Color intensity maps directly to correlation strength: teal for strong positive, red for strong negative, neutral gray for uncorrelated pairs. Diagonal cells are blanked — no wasted space showing you that BTC correlates with BTC.

Multi-Timeframe Support
Select from Chart / 1H / 4H / 1D / 1W directly in settings. The lookback period auto-scales to the target timeframe resolution, so "20 periods on Daily" means 20 trading days regardless of your chart timeframe.

Rolling Correlation Chart
Select any pair (Leg A / Leg B) and track its correlation coefficient over time as a continuous line. Shaded fill between the line and zero gives an instant visual read of direction and magnitude. A dynamic label on the last bar displays the current ρ value.

Aggregate Statistics Bar
Footer row shows AVG / MIN / MAX across all 15 pairs at a glance. When the minimum correlation drops to or below your threshold, a ⚠ BREAKDOWN tag appears.

Three Independent Alert Conditions
- Pair Breakdown — fires when any single pair falls to or below your threshold
- Average Breakdown — fires when the market-wide average correlation collapses
- Rolling Crossunder — fires when your selected pair crosses under the threshold

📐 How to Use

Portfolio Diversification Check
Add your held assets as Symbols 1–6. If the matrix is mostly dark teal (all pairs > 0.7), your portfolio moves as a single block — you're concentrated, not diversified. Look for pairs with low or negative correlation to add genuine hedging value.

Regime Change Detection
Monitor the AVG stat in the footer. A sudden drop in average correlation often precedes volatility expansion, sector rotation, or flight-to-quality moves. The average breakdown alert automates this surveillance.

Pairs Trading
Identify pairs with historically high correlation (> 0.8). When their rolling correlation temporarily collapses, it may signal a mean-reversion opportunity. Use the rolling chart to time entries and the crossunder alert for notifications.

Risk Management
During market stress, correlations tend to spike toward 1.0 across the board ("correlation breakdown to the upside"). When the matrix turns uniformly teal, portfolio risk is higher than position sizing alone suggests.

⚙️ Settings

| Parameter | Default | Description |
|---|---|---|
| Symbols 1–6 | BTC, ETH, SOL, BNB, XRP, ADA | Any tradable asset — crypto, forex, equities, commodities |
| Lookback Period | 20 | Number of target-TF bars for Pearson calculation |
| Timeframe | Chart | Correlation resolution: Chart / 1H / 4H / 1D / 1W |
| Breakdown Alert ≤ | 0.30 | Threshold for all three alert conditions |
| Rolling Pair | 1 × 2 | Which pair (by index) to plot on the rolling chart |
| Matrix Position | Top Right | Table placement on the pane |
| Colors | Brand defaults | Full control over positive, negative, neutral, header, and accent colors |

🧠 Technical Notes

- Log returns `ln(close / close[1])` are used instead of simple returns for better statistical properties (additivity, normality approximation).
- TF scaling: When the selected timeframe exceeds the chart timeframe, the lookback is multiplied by the bar ratio. Pearson r is invariant under uniform observation duplication, so accuracy is preserved.
- Security calls: 6 total (one per symbol), well within Pine's 40-call limit.
- Symbol parsing: Automatically strips exchange prefixes (Binance, Bybit, Coinbase, OKX, etc.) and quote currencies (USDT, USD, BUSD, USDC) for clean matrix labels.
- Works on any asset class — not limited to crypto despite the default symbols.

⚠️ Limitations

- Selecting a timeframe **lower** than your chart TF (e.g., "1H" on a Daily chart) will not produce hourly-resolution correlation. The multiplier floors at 1 and you get chart-TF correlation. For true 1H correlation, view on a 1H chart.
- Pearson correlation measures **linear** relationships. Non-linear dependencies (tail risk, asymmetric co-movement during crashes) require different tools.
- Past correlation does not guarantee future correlation. Regime shifts can invalidate historical readings without warning — which is exactly why the breakdown alerts exist.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Crypto Correlation Dashboard [StrixEDGE]", "Crypto Correlation Dashboard [StrixEDGE]", overlay = false, precision = 4)

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  INPUTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GRP_SYM  = "⚡ SYMBOLS"
i_sym1   = input.symbol("BINANCE:BTCUSDT",  "Symbol 1", group = GRP_SYM)
i_sym2   = input.symbol("BINANCE:ETHUSDT",  "Symbol 2", group = GRP_SYM)
i_sym3   = input.symbol("BINANCE:SOLUSDT",  "Symbol 3", group = GRP_SYM)
i_sym4   = input.symbol("BINANCE:BNBUSDT",  "Symbol 4", group = GRP_SYM)
i_sym5   = input.symbol("BINANCE:XRPUSDT",  "Symbol 5", group = GRP_SYM)
i_sym6   = input.symbol("BINANCE:ADAUSDT",  "Symbol 6", group = GRP_SYM)

GRP_CORR = "📐 CORRELATION"
i_period = input.int(20, "Lookback Period", minval = 5, maxval = 500, group = GRP_CORR, tooltip = "Number of target-TF bars used to compute Pearson correlation.\nInternally scaled by the chart-to-TF bar ratio.")
i_tf     = input.string("Chart", "Timeframe", options = ["Chart", "1H", "4H", "1D", "1W"], group = GRP_CORR, tooltip = "Correlation timeframe. 'Chart' uses the chart's own resolution.\nOther selections fetch data via request.security and auto-scale the period.")
i_thresh = input.float(0.3, "Breakdown Alert ≤", minval = -1.0, maxval = 1.0, step = 0.05, group = GRP_CORR, tooltip = "Alert fires when any pair's correlation drops to or below this level.")

GRP_ROLL = "📈 ROLLING CHART"
i_showRoll = input.bool(true, "Show Rolling Correlation", group = GRP_ROLL)
i_rollA    = input.int(1, "Pair Leg A (1–6)", minval = 1, maxval = 6, group = GRP_ROLL)
i_rollB    = input.int(2, "Pair Leg B (1–6)", minval = 1, maxval = 6, group = GRP_ROLL)

GRP_VIS  = "🎨 DISPLAY"
i_tblPos = input.string("Top Right", "Matrix Position", options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group = GRP_VIS)

GRP_CLR  = "🎨 COLORS"
i_posClr    = input.color(#00BFA5, "Strong Positive",  group = GRP_CLR)
i_negClr    = input.color(#FF1744, "Strong Negative",  group = GRP_CLR)
i_neutClr   = input.color(#455A64, "Neutral Zone",     group = GRP_CLR)
i_hdrBg     = input.color(#0D1117, "Header / Panel",   group = GRP_CLR)
i_accent    = input.color(#00E5FF, "Accent (Brand)",   group = GRP_CLR)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TIMEFRAME RESOLUTION & PERIOD SCALING
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  When the target TF > chart TF, request.security returns a "step" series
//  (same value repeated for each intra-bar). ta.correlation's Pearson r is
//  invariant to uniform duplication, so scaling the lookback by the bar-count
//  ratio preserves the result.  When target TF ≤ chart TF, multiplier = 1.
// ────────────────────────────────────────────────────────────────────────────

activeTF = switch i_tf
    "1H" => "60"
    "4H" => "240"
    "1D" => "D"
    "1W" => "W"
    =>      timeframe.period

chartSecs  = timeframe.in_seconds()
tfSecs     = timeframe.in_seconds(activeTF)
tfMult     = math.max(1, int(math.round(tfSecs / chartSecs)))
adjPeriod  = i_period * tfMult


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  DATA FETCH  (6 request.security calls)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[c1, c1p] = request.security(i_sym1, activeTF, [close, close[1]])
[c2, c2p] = request.security(i_sym2, activeTF, [close, close[1]])
[c3, c3p] = request.security(i_sym3, activeTF, [close, close[1]])
[c4, c4p] = request.security(i_sym4, activeTF, [close, close[1]])
[c5, c5p] = request.security(i_sym5, activeTF, [close, close[1]])
[c6, c6p] = request.security(i_sym6, activeTF, [close, close[1]])


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  LOG RETURNS  (preferred over simple returns for correlation stability)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

r1 = nz(math.log(c1 / c1p))
r2 = nz(math.log(c2 / c2p))
r3 = nz(math.log(c3 / c3p))
r4 = nz(math.log(c4 / c4p))
r5 = nz(math.log(c5 / c5p))
r6 = nz(math.log(c6 / c6p))


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CORRELATION MATRIX  —  15 unique pairs (C(6,2))
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

cr12 = ta.correlation(r1, r2, adjPeriod)
cr13 = ta.correlation(r1, r3, adjPeriod)
cr14 = ta.correlation(r1, r4, adjPeriod)
cr15 = ta.correlation(r1, r5, adjPeriod)
cr16 = ta.correlation(r1, r6, adjPeriod)
cr23 = ta.correlation(r2, r3, adjPeriod)
cr24 = ta.correlation(r2, r4, adjPeriod)
cr25 = ta.correlation(r2, r5, adjPeriod)
cr26 = ta.correlation(r2, r6, adjPeriod)
cr34 = ta.correlation(r3, r4, adjPeriod)
cr35 = ta.correlation(r3, r5, adjPeriod)
cr36 = ta.correlation(r3, r6, adjPeriod)
cr45 = ta.correlation(r4, r5, adjPeriod)
cr46 = ta.correlation(r4, r6, adjPeriod)
cr56 = ta.correlation(r5, r6, adjPeriod)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  HELPER FUNCTIONS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ── Symmetric lookup: f_corr(i, j) == f_corr(j, i) ──────────────────────────
f_corr(int i, int j) =>
    int a = math.min(i, j)
    int b = math.max(i, j)
    a == b                 ? 1.0  :
     a == 0 and b == 1     ? cr12 :
     a == 0 and b == 2     ? cr13 :
     a == 0 and b == 3     ? cr14 :
     a == 0 and b == 4     ? cr15 :
     a == 0 and b == 5     ? cr16 :
     a == 1 and b == 2     ? cr23 :
     a == 1 and b == 3     ? cr24 :
     a == 1 and b == 4     ? cr25 :
     a == 1 and b == 5     ? cr26 :
     a == 2 and b == 3     ? cr34 :
     a == 2 and b == 4     ? cr35 :
     a == 2 and b == 5     ? cr36 :
     a == 3 and b == 4     ? cr45 :
     a == 3 and b == 5     ? cr46 :
     a == 4 and b == 5     ? cr56 :
     na

// ── Extract short ticker from full symbol string ─────────────────────────────
f_short(string full) =>
    string s = full
    // Strip exchange prefix
    s := str.replace_all(s, "BINANCE:",   "")
    s := str.replace_all(s, "BYBIT:",     "")
    s := str.replace_all(s, "COINBASE:",  "")
    s := str.replace_all(s, "KRAKEN:",    "")
    s := str.replace_all(s, "OKX:",       "")
    s := str.replace_all(s, "BITSTAMP:",  "")
    s := str.replace_all(s, "KUCOIN:",    "")
    s := str.replace_all(s, "MEXC:",      "")
    s := str.replace_all(s, "CRYPTO:",    "")
    s := str.replace_all(s, "HUOBI:",     "")
    s := str.replace_all(s, "BITFINEX:",  "")
    s := str.replace_all(s, "GATEIO:",    "")
    s := str.replace_all(s, "BINGX:",     "")
    s := str.replace_all(s, "BITGET:",    "")
    s := str.replace_all(s, "PHEMEX:",    "")
    // Strip quote-currency suffixes (order matters — longest first)
    if str.endswith(s, "USDT.P")
        s := str.substring(s, 0, str.length(s) - 6)
    else if str.endswith(s, "USDTPERP")
        s := str.substring(s, 0, str.length(s) - 8)
    else if str.endswith(s, "USDT")
        s := str.substring(s, 0, str.length(s) - 4)
    else if str.endswith(s, "BUSD")
        s := str.substring(s, 0, str.length(s) - 4)
    else if str.endswith(s, "PERP")
        s := str.substring(s, 0, str.length(s) - 4)
    else if str.endswith(s, "TUSD")
        s := str.substring(s, 0, str.length(s) - 4)
    else if str.endswith(s, "USDC")
        s := str.substring(s, 0, str.length(s) - 4)
    else if str.endswith(s, "DAI")
        s := str.substring(s, 0, str.length(s) - 3)
    else if str.endswith(s, "USD")
        s := str.substring(s, 0, str.length(s) - 3)
    else if str.endswith(s, "BTC")
        s := str.substring(s, 0, str.length(s) - 3)
    else if str.endswith(s, "ETH")
        s := str.substring(s, 0, str.length(s) - 3)
    s

// Cached short names
n1 = f_short(i_sym1)
n2 = f_short(i_sym2)
n3 = f_short(i_sym3)
n4 = f_short(i_sym4)
n5 = f_short(i_sym5)
n6 = f_short(i_sym6)

f_name(int i) =>
    switch i
        0 => n1
        1 => n2
        2 => n3
        3 => n4
        4 => n5
        => n6

// ── Cell color: gradient mapped to correlation intensity ─────────────────────
f_cellClr(float val) =>
    float v = math.max(-1.0, math.min(1.0, nz(val, 0.0)))
    v >= 0 ? color.from_gradient(v, 0, 1, i_neutClr, i_posClr) :
             color.from_gradient(v, -1, 0, i_negClr, i_neutClr)

// ── Text color: ensure readability against cell background ──────────────────
f_txtClr(float val) =>
    float v = math.abs(nz(val, 0.0))
    v > 0.6 ? color.white : color.new(color.white, 15)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  TABLE POSITION RESOLVER
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

tblPos = switch i_tblPos
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    =>                 position.bottom_right


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  AGGREGATE STATS  (computed every bar for alerts; table uses last-bar values)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

float sumCorr = nz(cr12) + nz(cr13) + nz(cr14) + nz(cr15) + nz(cr16) + nz(cr23) + nz(cr24) + nz(cr25) + nz(cr26) + nz(cr34) + nz(cr35) + nz(cr36) + nz(cr45) + nz(cr46) + nz(cr56)
float avgCorr = sumCorr / 15.0

float minCorr = math.min(
     math.min(math.min(math.min(nz(cr12), nz(cr13)), math.min(nz(cr14), nz(cr15))), math.min(math.min(nz(cr16), nz(cr23)), math.min(nz(cr24), nz(cr25)))),
     math.min(math.min(math.min(nz(cr26), nz(cr34)), math.min(nz(cr35), nz(cr36))), math.min(math.min(nz(cr45), nz(cr46)), nz(cr56))))

float maxCorr = math.max(
     math.max(math.max(math.max(nz(cr12), nz(cr13)), math.max(nz(cr14), nz(cr15))), math.max(math.max(nz(cr16), nz(cr23)), math.max(nz(cr24), nz(cr25)))),
     math.max(math.max(math.max(nz(cr26), nz(cr34)), math.max(nz(cr35), nz(cr36))), math.max(math.max(nz(cr45), nz(cr46)), nz(cr56))))


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  CORRELATION MATRIX TABLE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Layout (7 cols × 9 rows):
//    Row 0 : Title bar  [merged across all cols]
//    Row 1 : Column headers  (" ", S1, S2, S3, S4, S5, S6)
//    Rows 2-7 : Matrix body  (row header + 6 correlation cells)
//    Row 8 : Stats footer  [merged]
// ────────────────────────────────────────────────────────────────────────────

var tbl = table.new(tblPos, 7, 9, border_width = 1, border_color = color.new(i_hdrBg, 40), frame_width = 2, frame_color = i_accent)

if barstate.islast

    // ── Row 0: Title bar ─────────────────────────────────────────────────────
    string tfLabel = i_tf == "Chart" ? timeframe.period : i_tf
    string title   = "⚡ STRIXEDGE CORRELATION  │  " + tfLabel + "  │  " + str.tostring(i_period) + "P"
    table.cell(tbl, 0, 0, title, text_color = i_accent, bgcolor = i_hdrBg, text_size = size.small, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 0, 6, 0)

    // ── Row 1: Column headers ────────────────────────────────────────────────
    table.cell(tbl, 0, 1, "", bgcolor = i_hdrBg, text_size = size.small)
    for col = 0 to 5
        table.cell(tbl, col + 1, 1, f_name(col), text_color = i_accent, bgcolor = color.new(i_hdrBg, 15), text_size = size.small, text_halign = text.align_center)

    // ── Rows 2–7: Matrix body ────────────────────────────────────────────────
    for row = 0 to 5
        // Row header
        table.cell(tbl, 0, row + 2, f_name(row), text_color = i_accent, bgcolor = color.new(i_hdrBg, 15), text_size = size.small, text_halign = text.align_right)

        for col = 0 to 5
            float val    = f_corr(row, col)
            bool  isDiag = row == col

            color  bg  = isDiag ? color.new(i_hdrBg, 25) : f_cellClr(val)
            string txt = isDiag ? "━━━" : str.tostring(val, "#.##")
            color  tc  = isDiag ? color.new(i_accent, 60) : f_txtClr(val)

            table.cell(tbl, col + 1, row + 2, txt, text_color = tc, bgcolor = bg, text_size = size.small, text_halign = text.align_center)

    // ── Row 8: Stats footer ──────────────────────────────────────────────────
    color  statClr  = avgCorr <= i_thresh ? i_negClr : i_posClr
    string alertTag = minCorr <= i_thresh ? "  ⚠ BREAKDOWN" : ""
    string statsStr = "AVG " + str.tostring(avgCorr, "#.###") + "  │  MIN " + str.tostring(minCorr, "#.##") + "  │  MAX " + str.tostring(maxCorr, "#.##") + alertTag

    table.cell(tbl, 0, 8, statsStr, text_color = statClr, bgcolor = i_hdrBg, text_size = size.tiny, text_halign = text.align_left)
    table.merge_cells(tbl, 0, 8, 6, 8)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  ROLLING CORRELATION CHART
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Plots the rolling Pearson r for a user-selected pair.
//  Shaded fill between the line and zero for quick visual read.
// ────────────────────────────────────────────────────────────────────────────

// Guard: force different legs
int legA = math.max(0, math.min(5, i_rollA - 1))
int legB = math.max(0, math.min(5, i_rollB - 1))
legB := legA == legB ? (legA + 1) % 6 : legB

float rollVal = f_corr(legA, legB)
color rollClr = nz(rollVal) >= 0 ? i_posClr : i_negClr

// Main correlation line
pRoll = plot(i_showRoll ? rollVal : na, "Rolling ρ", color = rollClr, linewidth = 2)

// Zero baseline (invisible — used for fill anchor)
pZero = plot(i_showRoll ? 0.0 : na, "Zero", color = color.new(color.white, 100), display = display.none)

// Shaded fill
fill(pRoll, pZero, color = color.new(rollClr, 88), title = "Correlation Fill")

// Reference lines
hline( 0.0,      "Zero",       color = color.new(color.white, 80), linestyle = hline.style_dashed)
hline( i_thresh, "Threshold",  color = color.new(i_negClr, 60),    linestyle = hline.style_dotted)
hline(-i_thresh, "–Threshold", color = color.new(i_negClr, 60),    linestyle = hline.style_dotted)
hline( 1.0,      "+1",         color = color.new(color.white, 92), linestyle = hline.style_dotted)
hline(-1.0,      "–1",         color = color.new(color.white, 92), linestyle = hline.style_dotted)

// Subtle pane background
bgcolor(color.new(i_hdrBg, 92))

// Dynamic pair label on the last bar
if barstate.islast and i_showRoll
    string pairLabel = f_name(legA) + " × " + f_name(legB) + "  ρ = " + str.tostring(rollVal, "#.####")
    label.new(bar_index, nz(rollVal, 0), pairLabel, style = label.style_label_left, color = color.new(i_hdrBg, 20), textcolor = i_accent, size = size.small)


// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  BREAKDOWN ALERTS
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//  Three independent alert conditions so users can subscribe granularly:
//    1. Any single pair drops below threshold
//    2. Market-wide average drops below threshold
//    3. The selected rolling pair crosses under threshold
// ────────────────────────────────────────────────────────────────────────────

bool anyBreak = nz(cr12) <= i_thresh or nz(cr13) <= i_thresh or nz(cr14) <= i_thresh or nz(cr15) <= i_thresh or nz(cr16) <= i_thresh or nz(cr23) <= i_thresh or nz(cr24) <= i_thresh or nz(cr25) <= i_thresh or nz(cr26) <= i_thresh or nz(cr34) <= i_thresh or nz(cr35) <= i_thresh or nz(cr36) <= i_thresh or nz(cr45) <= i_thresh or nz(cr46) <= i_thresh or nz(cr56) <= i_thresh

bool avgBreak = avgCorr <= i_thresh

alertcondition(anyBreak,                           "⚡ Pair Breakdown",     "[StrixEDGE] One or more pair correlations dropped to or below threshold")
alertcondition(avgBreak,                           "⚡ Avg Breakdown",      "[StrixEDGE] Average market correlation dropped to or below threshold")
alertcondition(ta.crossunder(rollVal, i_thresh),   "⚡ Rolling Crossunder", "[StrixEDGE] Rolling pair correlation crossed under threshold")

// ══════════════════════════════════════════════════════════════════════════════
//  END
// ══════════════════════════════════════════════════════════════════════════════
````
