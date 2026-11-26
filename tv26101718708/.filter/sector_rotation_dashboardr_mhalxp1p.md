# Sector Rotation Dashboardr

- url: https://www.tradingview.com/script/mhalxp1P-Sector-Rotation-Dashboardr/
- type: indicator
- pine_id: PUB;d80aa513f92d43488810202b646148a2
- version: 3.0

## Description

[b]Sector Rotation Dashboard[/b]

Understanding where institutional money is moving before and after the opening bell gives traders a massive edge. This indicator is a real-time capital rotation tracker that maps the relative performance of all 11 Select Sector SPDR ETFs (representing the entire S&P 500) across all trading sessions.

Unlike standard dashboards that only look at regular market data, this script dynamically loops in premarket and after-hours data, updating relative performance calculations dynamically on every tick.

[b]How It Works[/b]
The script actively fetches performance data by comparing the current extended hours or regular session price against the previous regular session close. It automatically pulls and handles 11 critical market sectors:

Technology (XLK)

Financials (XLF)

Health Care (XLV)

Consumer Discretionary (XLY)

Consumer Staples (XLP)

Energy (XLE)

Utilities (XLU)

Industrials (XLI)

Materials (XLB)

Real Estate (XLRE)

Communication Services (XLC)

[b]Key Features[/b]
Live Session Tracking: Built-in intelligence automatically detects whether the market is in Premarket Hours, Regular Market Hours, or After Hours based on exchange times.

Real-time Bubble Sort Engine: The script actively sorts the 11 sectors from strongest to weakest on the last bar, so the leading sectors are always pushed to the top of your UI.

Automated Capital Rotation Insight: At the bottom of the table, a dynamic AI-style macro text block summarizes the state of the market. For example, it might read: "During Premarket Hours, capital is rotating heavily into Technology (XLK)... Conversely, liquidity is draining from Utilities (XLU)."

Fully Customizable UI: Change the dashboard placement (Top Right, Bottom Left, etc.) and text scaling seamlessly via the script settings to perfectly fit your workspace layout.

[b]How to Trade with It[/b]
Spot Early Momentum (Premarket): Look at the dashboard 30–60 minutes before the open. If Defensive sectors (XLU, XLP) are leading while Aggressive sectors (XLK, XLY) are bleeding liquidity, expect a risk-off environment at the opening bell.

Relative Strength / Weakness Trading: When looking for long setups, focus on individual stocks inside the top 2 leading sectors. For shorting or put options, look at names within the lagging bottom sectors.

Identify Intraday Rotations: Watch for shifts during regular market hours where a beaten-down sector suddenly starts climbing the ladder, signaling algorithmic or institutional accumulation.

Developer Note: Uses optimized request.security structures to pull seamless extended historical data without dragging down chart loading speeds or causing layout shifting.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════════════════════════
//  SECTOR ROTATION DASHBOARD
//  Author  : Blk0ut
//  Purpose : Identifies institutional capital rotation across all 11 SPDR
//            sector ETFs by combining relative strength, Chaikin Money Flow,
//            volume-surge analysis, trend structure, and a futures-vs-ETF
//            divergence layer (ES1! / NQ1!) to surface smart-money signals.
// ══════════════════════════════════════════════════════════════════════════════
indicator("Sector Rotation Dashboardr", shorttitle="SR Dash", overlay=false,
          max_lines_count=500, max_labels_count=500, max_boxes_count=100)


// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────
grp1 = "Performance Lookbacks"
i_p1  = input.int(1,  "Short  (days)", minval=1, maxval=5,   group=grp1, tooltip="1-day return")
i_p2  = input.int(5,  "Medium (days)", minval=2, maxval=15,  group=grp1, tooltip="5-day return")
i_p3  = input.int(20, "Long   (days)", minval=5, maxval=60,  group=grp1, tooltip="20-day return")


grp2 = "Signal Parameters"
i_rsLen   = input.int(20,  "Relative Strength Period", minval=5,  group=grp2)
i_volLen  = input.int(20,  "Volume MA Period",         minval=5,  group=grp2)
i_cmfLen  = input.int(14,  "CMF Period",               minval=5,  group=grp2)
i_emaFast = input.int(20,  "Fast EMA",                 minval=5,  group=grp2)
i_emaSlow = input.int(50,  "Slow EMA",                 minval=10, group=grp2)


grp3 = "Display"
i_showFut  = input.bool(true,  "Show Futures Divergence Row",   group=grp3)
i_showLeg  = input.bool(true,  "Show Legend",                   group=grp3)
i_tblPos   = input.string("Top Right", "Table Position",
              options=["Top Right","Top Left","Bottom Right","Bottom Left"], group=grp3)

// NEW: table font size selector
i_fontSize = input.string("Small", "Table font size",
              options = ["Tiny","Small","Normal","Large"], group=grp3)

f_font_size(sz) =>
    sz == "Tiny"   ? size.tiny  :
     sz == "Small" ? size.small :
     sz == "Normal"? size.normal:
                     size.large

fontSize = f_font_size(i_fontSize)


// ─────────────────────────────────────────────────────────────────────────────
//  THEME  /  PALETTE
// ─────────────────────────────────────────────────────────────────────────────
BULL_STR  = color.new(#00e676, 0)
BULL_MED  = color.new(#69f0ae, 0)
BULL_LITE = color.new(#b9f6ca, 20)
BEAR_STR  = color.new(#ff1744, 0)
BEAR_MED  = color.new(#ff5252, 0)
BEAR_LITE = color.new(#ff8a80, 20)
NEUTRAL   = color.new(#78909c, 0)
TITLE_BG  = color.new(#0d1b3e, 0)
HDR_BG    = color.new(#1a237e, 0)
ROW_EVEN  = color.new(#0d1117, 0)
ROW_ODD   = color.new(#161b22, 0)
TXT_WHITE = color.new(#ffffff, 0)
TXT_BLUE  = color.new(#90caf9, 0)
TXT_GOLD  = color.new(#ffd54f, 0)
ACCENT    = color.new(#1565c0, 0)
VOL_HIGH  = color.new(#1a237e, 0)
VOL_LOW   = color.new(#263238, 0)


// ─────────────────────────────────────────────────────────────────────────────
//  TABLE POSITION HELPER
// ─────────────────────────────────────────────────────────────────────────────
tblPos() =>
    switch i_tblPos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>               position.top_right


// ─────────────────────────────────────────────────────────────────────────────
//  DATA FETCHING  –  all ETFs + benchmark + futures
// ─────────────────────────────────────────────────────────────────────────────
f_sec(sym) =>
    request.security(sym, timeframe.period,
                     [close, open, high, low, volume],
                     lookahead=barmerge.lookahead_off)


// Benchmark
[spy_c, spy_o, spy_h, spy_l, spy_v] = f_sec("SPY")


// ── 11 SPDR Sector ETFs ──────────────────────────────────────────────────────
[xlk_c,  xlk_o,  xlk_h,  xlk_l,  xlk_v]  = f_sec("XLK")   // Technology
[xlf_c,  xlf_o,  xlf_h,  xlf_l,  xlf_v]  = f_sec("XLF")   // Financials
[xle_c,  xle_o,  xle_h,  xle_l,  xle_v]  = f_sec("XLE")   // Energy
[xlv_c,  xlv_o,  xlv_h,  xlv_l,  xlv_v]  = f_sec("XLV")   // Health Care
[xli_c,  xli_o,  xli_h,  xli_l,  xli_v]  = f_sec("XLI")   // Industrials
[xly_c,  xly_o,  xly_h,  xly_l,  xly_v]  = f_sec("XLY")   // Cons. Discret.
[xlp_c,  xlp_o,  xlp_h,  xlp_l,  xlp_v]  = f_sec("XLP")   // Cons. Staples
[xlb_c,  xlb_o,  xlb_h,  xlb_l,  xlb_v]  = f_sec("XLB")   // Materials
[xlre_c, xlre_o, xlre_h, xlre_l, xlre_v] = f_sec("XLRE")  // Real Estate
[xlu_c,  xlu_o,  xlu_h,  xlu_l,  xlu_v]  = f_sec("XLU")   // Utilities
[xlc_c,  xlc_o,  xlc_h,  xlc_l,  xlc_v]  = f_sec("XLC")   // Communication


// ── Futures ───────────────────────────────────────────────────────────────────
[es_c,  es_o,  es_h,  es_l,  es_v]  = f_sec("ES1!")   // S&P 500 Futures
[nq_c,  nq_o,  nq_h,  nq_l,  nq_v]  = f_sec("NQ1!")   // Nasdaq-100 Futures
[ym_c,  ym_o,  ym_h,  ym_l,  ym_v]  = f_sec("YM1!")   // Dow Futures
[rty_c, rty_o, rty_h, rty_l, rty_v] = f_sec("RTY1!")  // Russell 2000 Futures


// ─────────────────────────────────────────────────────────────────────────────
//  CORE ANALYTICAL FUNCTIONS
// ─────────────────────────────────────────────────────────────────────────────


// — % return over N bars
f_perf(c, len) =>
    na(c[len]) ? 0.0 : (c / c[len] - 1.0) * 100.0


// — Relative Strength ratio vs benchmark  (RS Line momentum)
f_rsLine(c, bench, len) =>
    ratio = c / bench
    rsma_fast = ta.sma(ratio, len)
    rsma_slow = ta.sma(ratio, len * 3)
    rsma_slow != 0 ? (rsma_fast / rsma_slow - 1.0) : 0.0


// — Chaikin Money Flow (institutional accumulation/distribution proxy)
f_cmf(c, h, l, v, len) =>
    hl_range = h - l
    mfm = hl_range != 0 ? ((c - l) - (h - c)) / hl_range : 0.0
    mfv = mfm * v
    vol_sum = math.sum(v, len)
    vol_sum != 0 ? math.sum(mfv, len) / vol_sum : 0.0


// — Volume ratio (current vs average)
f_volRatio(v, len) =>
    avg = ta.sma(v, len)
    avg != 0 ? v / avg : 1.0


// — Trend structure: +1 bull / -1 bear / 0 neutral
f_trend(c, fast, slow) =>
    emaF = ta.ema(c, fast)
    emaS = ta.ema(c, slow)
    c > emaF and emaF > emaS ? 1 : c < emaF and emaF < emaS ? -1 : 0


// — Price/volume divergence within current session (institutional footprint)
f_pvDiv(c, o, h, l, v, volLen) =>
    body      = math.abs(c - o)
    spread    = h - l
    upperWick = h - math.max(c, o)
    lowerWick = math.min(c, o) - l
    volSpike  = v / ta.sma(v, volLen)
    // High-volume narrow-body bar = potential absorption / reversal signal
    absorption = volSpike > 1.5 and spread != 0 and body / spread < 0.35
    // Closing strength: close in upper 60% on high volume = smart buy
    closeStr  = spread != 0 ? (c - l) / spread : 0.5
    smartBuy  = volSpike > 1.2 and closeStr > 0.60 and c > o
    smartSell = volSpike > 1.2 and closeStr < 0.40 and c < o
    pvScore   = smartBuy ? 1.0 : smartSell ? -1.0 : absorption ? 0.0 : 0.0
    [pvScore, absorption]


// — Composite score  –3 to +3 mapped to rotation conviction
f_score(rs, cmf, volRatio, trend, pvScore) =>
    s = 0.0
    // Relative strength contribution
    s += rs > 0.02 ? 1.0 : rs > 0.005 ? 0.5 : rs < -0.02 ? -1.0 : rs < -0.005 ? -0.5 : 0.0
    // CMF contribution
    s += cmf > 0.07 ? 1.0 : cmf > 0.02 ? 0.5 : cmf < -0.07 ? -1.0 : cmf < -0.02 ? -0.5 : 0.0
    // Volume surge contribution
    s += volRatio > 1.5 ? 0.5 : volRatio < 0.6 ? -0.3 : 0.0
    // Trend contribution
    s += float(trend) * 0.5
    // Price/volume divergence
    s += pvScore * 0.5
    math.max(-3.0, math.min(3.0, s))


// ─────────────────────────────────────────────────────────────────────────────
//  FUTURES DIVERGENCE – Smart money positioning signal
// ─────────────────────────────────────────────────────────────────────────────
es_perf   = f_perf(es_c,  i_p1)
spy_perf  = f_perf(spy_c, i_p1)
nq_perf   = f_perf(nq_c,  i_p1)
xlk_perf1 = f_perf(xlk_c, i_p1)
ym_perf   = f_perf(ym_c,  i_p1)
rty_perf  = f_perf(rty_c, i_p1)

es_div  = es_perf  - spy_perf       // ES vs SPY
nq_div  = nq_perf  - xlk_perf1      // NQ vs XLK (tech proxy)

// Composite futures bias
fut_composite = (es_div + nq_div) / 2.0
fut_bias = fut_composite > 0.25  ? "🟢 FUTURES LEADING  → Institutional BULLISH bias" :
           fut_composite < -0.25 ? "🔴 FUTURES LAGGING  → Institutional BEARISH bias" :
                                   "⚪ Futures in-line with cash  |  No clear bias"
fut_bias_clr = fut_composite > 0.25  ? BULL_STR :
               fut_composite < -0.25 ? BEAR_STR : NEUTRAL


// ─────────────────────────────────────────────────────────────────────────────
//  COMPUTE ALL SECTOR METRICS
// ─────────────────────────────────────────────────────────────────────────────
f_sectorMetrics(c, o, h, l, v, bench) =>
    p1  = f_perf(c, i_p1)
    p5  = f_perf(c, i_p2)
    p20 = f_perf(c, i_p3)
    rs  = f_rsLine(c, bench, i_rsLen)
    cmf = f_cmf(c, h, l, v, i_cmfLen)
    vr  = f_volRatio(v, i_volLen)
    tr  = f_trend(c, i_emaFast, i_emaSlow)
    [pvScore, _] = f_pvDiv(c, o, h, l, v, i_volLen)
    sc  = f_score(rs, cmf, vr, tr, pvScore)
    [p1, p5, p20, rs, cmf, vr, tr, sc]


[xlk_p1,  xlk_p5,  xlk_p20,  xlk_rs,  xlk_cmf,  xlk_vr,  xlk_tr,  xlk_sc]  = f_sectorMetrics(xlk_c,  xlk_o,  xlk_h,  xlk_l,  xlk_v,  spy_c)
[xlf_p1,  xlf_p5,  xlf_p20,  xlf_rs,  xlf_cmf,  xlf_vr,  xlf_tr,  xlf_sc]  = f_sectorMetrics(xlf_c,  xlf_o,  xlf_h,  xlf_l,  xlf_v,  spy_c)
[xle_p1,  xle_p5,  xle_p20,  xle_rs,  xle_cmf,  xle_vr,  xle_tr,  xle_sc]  = f_sectorMetrics(xle_c,  xle_o,  xle_h,  xle_l,  xle_v,  spy_c)
[xlv_p1,  xlv_p5,  xlv_p20,  xlv_rs,  xlv_cmf,  xlv_vr,  xlv_tr,  xlv_sc]  = f_sectorMetrics(xlv_c,  xlv_o,  xlv_h,  xlv_l,  xlv_v,  spy_c)
[xli_p1,  xli_p5,  xli_p20,  xli_rs,  xli_cmf,  xli_vr,  xli_tr,  xli_sc]  = f_sectorMetrics(xli_c,  xli_o,  xli_h,  xli_l,  xli_v,  spy_c)
[xly_p1,  xly_p5,  xly_p20,  xly_rs,  xly_cmf,  xly_vr,  xly_tr,  xly_sc]  = f_sectorMetrics(xly_c,  xly_o,  xly_h,  xly_l,  xly_v,  spy_c)
[xlp_p1,  xlp_p5,  xlp_p20,  xlp_rs,  xlp_cmf,  xlp_vr,  xlp_tr,  xlp_sc]  = f_sectorMetrics(xlp_c,  xlp_o,  xlp_h,  xlp_l,  xlp_v,  spy_c)
[xlb_p1,  xlb_p5,  xlb_p20,  xlb_rs,  xlb_cmf,  xlb_vr,  xlb_tr,  xlb_sc]  = f_sectorMetrics(xlb_c,  xlb_o,  xlb_h,  xlb_l,  xlb_v,  spy_c)
[xlre_p1, xlre_p5, xlre_p20, xlre_rs, xlre_cmf, xlre_vr, xlre_tr, xlre_sc] = f_sectorMetrics(xlre_c, xlre_o, xlre_h, xlre_l, xlre_v, spy_c)
[xlu_p1,  xlu_p5,  xlu_p20,  xlu_rs,  xlu_cmf,  xlu_vr,  xlu_tr,  xlu_sc]  = f_sectorMetrics(xlu_c,  xlu_o,  xlu_h,  xlu_l,  xlu_v,  spy_c)
[xlc_p1,  xlc_p5,  xlc_p20,  xlc_rs,  xlc_cmf,  xlc_vr,  xlc_tr,  xlc_sc]  = f_sectorMetrics(xlc_c,  xlc_o,  xlc_h,  xlc_l,  xlc_v,  spy_c)


// ─────────────────────────────────────────────────────────────────────────────
//  DISPLAY HELPERS
// ─────────────────────────────────────────────────────────────────────────────
f_perfBg(p) =>
    p > 2.0  ? BULL_STR  :    p > 0.5  ? BULL_MED  :    p > 0.0  ? BULL_LITE :    p > -0.5 ? BEAR_LITE :    p > -2.0 ? BEAR_MED  :               BEAR_STR

f_scoreBg(s) =>
    s >= 2.0  ? BULL_STR  :
     s >= 1.0  ? BULL_MED  :
     s >= 0.5  ? BULL_LITE :
     s >= -0.5 ? color.new(#424242, 0) :
     s >= -1.0 ? BEAR_LITE :
     s >= -2.0 ? BEAR_MED  :
                 BEAR_STR

f_volBg(vr, rowBg) =>
    vr > 1.5 ? VOL_HIGH :
     vr < 0.65 ? VOL_LOW  :
                 rowBg

f_trendStr(tr) =>
    tr == 1 ? "▲ Bull" : tr == -1 ? "▼ Bear" : "→ Side"

f_trendClr(tr) =>
    tr == 1 ? BULL_MED : tr == -1 ? BEAR_MED : NEUTRAL

f_rotationLabel(sc, rs, cmf, vr) =>
    highVol = vr > 1.3
    sc >= 2.0  and highVol ? "▲▲ STRONG INFLOW"  :
     sc >= 2.0             ? "▲  INFLOW"         :
     sc >= 1.0  and highVol ? "↑  ACCUMULATION +" :
     sc >= 1.0             ? "↑  ACCUMULATION"   :
     sc >= 0.5             ? "→  MILD STRENGTH"  :
     sc >= -0.5            ? "─  NEUTRAL"        :
     sc >= -1.0            ? "↓  DISTRIBUTION"   :
     sc >= -1.0 and highVol ? "↓  DISTRIBUTION +" :
     sc >= -2.0 and highVol ? "▼  OUTFLOW +"      :
     sc >= -2.0            ? "▼  OUTFLOW"        :
     highVol               ? "▼▼ STRONG OUTFLOW +" :
                             "▼▼ STRONG OUTFLOW"

f_rotationClr(sc) =>
    sc >= 2.0  ? BULL_STR  :
     sc >= 1.0  ? BULL_MED  :
     sc >= 0.5  ? BULL_LITE :
     sc >= -0.5 ? NEUTRAL   :
     sc >= -1.0 ? BEAR_LITE :
     sc >= -2.0 ? BEAR_MED  :
                  BEAR_STR

f_cmfLabel(cmf) =>
    cmf > 0.10 ? "+" + str.tostring(cmf, "#.###") :
                  str.tostring(cmf, "#.###")


// ─────────────────────────────────────────────────────────────────────────────
//  BUILD TABLE
// ─────────────────────────────────────────────────────────────────────────────
// Rows: 0=title, 1=col headers, 2-12=sectors (11), 13=SPY benchmark,
//       14=futures div, 15=legend (optional)
TOTAL_ROWS = 16
TOTAL_COLS = 11

var table tbl = table.new(tblPos(), TOTAL_COLS, TOTAL_ROWS,
                          bgcolor      = ROW_EVEN,
                          border_width = 1,
                          border_color = color.new(#303030, 0),
                          frame_width  = 2,
                          frame_color  = color.new(#1a237e, 0))


if barstate.islast

    // ROW 0 : Main Title
    table.cell(tbl, 0,  0, "⚡  SMART MONEY SECTOR ROTATION  ──  " + str.format("{0,date,MMM dd, yyyy}", time),
               text_color=TXT_GOLD, bgcolor=TITLE_BG, text_size=fontSize,
               text_halign=text.align_left)
    for ci = 1 to TOTAL_COLS - 1
        table.cell(tbl, ci, 0, "", bgcolor=TITLE_BG)

    // ROW 1 : Column Headers
    cols = array.from("SECTOR", "ETF", "1D %", "5D %", "20D %", "RS Line",
                      "Vol Ratio", "CMF", "Trend", "Score", "🔄 ROTATION SIGNAL")
    for ci = 0 to TOTAL_COLS - 1
        table.cell(tbl, ci, 1, array.get(cols, ci),
                   text_color=TXT_WHITE, bgcolor=HDR_BG, text_size=fontSize)

    // DATA ARRAYS
    sectorNames = array.from("Technology", "Financials", "Energy", "Health Care",
                             "Industrials", "Cons. Discret.", "Cons. Staples",
                             "Materials", "Real Estate", "Utilities", "Comm. Svcs.")
    etfNames    = array.from("XLK", "XLF", "XLE", "XLV", "XLI",
                             "XLY", "XLP", "XLB", "XLRE", "XLU", "XLC")

    p1arr  = array.from(xlk_p1,  xlf_p1,  xle_p1,  xlv_p1,  xli_p1,
                        xly_p1,  xlp_p1,  xlb_p1,  xlre_p1, xlu_p1,  xlc_p1)
    p5arr  = array.from(xlk_p5,  xlf_p5,  xle_p5,  xlv_p5,  xli_p5,
                        xly_p5,  xlp_p5,  xlb_p5,  xlre_p5, xlu_p5,  xlc_p5)
    p20arr = array.from(xlk_p20, xlf_p20, xle_p20, xlv_p20, xli_p20,
                        xly_p20, xlp_p20, xlb_p20, xlre_p20, xlu_p20, xlc_p20)
    rsarr  = array.from(xlk_rs,  xlf_rs,  xle_rs,  xlv_rs,  xli_rs,
                        xly_rs,  xlp_rs,  xlb_rs,  xlre_rs, xlu_rs,  xlc_rs)
    cmfarr = array.from(xlk_cmf, xlf_cmf, xle_cmf, xlv_cmf, xli_cmf,
                        xly_cmf, xlp_cmf, xlb_cmf, xlre_cmf, xlu_cmf, xlc_cmf)
    vrarr  = array.from(xlk_vr,  xlf_vr,  xle_vr,  xlv_vr,  xli_vr,
                        xly_vr,  xlp_vr,  xlb_vr,  xlre_vr, xlu_vr,  xlc_vr)

    float t_xlk  = float(xlk_tr)
    float t_xlf  = float(xlf_tr)
    float t_xle  = float(xle_tr)
    float t_xlv  = float(xlv_tr)
    float t_xli  = float(xli_tr)
    float t_xly  = float(xly_tr)
    float t_xlp  = float(xlp_tr)
    float t_xlb  = float(xlb_tr)
    float t_xlre = float(xlre_tr)
    float t_xlu  = float(xlu_tr)
    float t_xlc  = float(xlc_tr)

    trarr  = array.from(t_xlk, t_xlf, t_xle, t_xlv, t_xli, t_xly, t_xlp, t_xlb, t_xlre, t_xlu, t_xlc)
    scarr  = array.from(xlk_sc,  xlf_sc,  xle_sc,  xlv_sc,  xli_sc,
                        xly_sc,  xlp_sc,  xlb_sc,  xlre_sc, xlu_sc,  xlc_sc)

    // ROWS 2–12 : Sectors
    for i = 0 to 10
        row   = i + 2
        rowBg = i % 2 == 0 ? ROW_EVEN : ROW_ODD

        sc_v  = array.get(scarr,  i)
        rs_v  = array.get(rsarr,  i)
        cmf_v = array.get(cmfarr, i)
        vr_v  = array.get(vrarr,  i)
        tr_v  = int(array.get(trarr, i))
        p1_v  = array.get(p1arr,  i)
        p5_v  = array.get(p5arr,  i)
        p20_v = array.get(p20arr, i)

        table.cell(tbl, 0,  row, array.get(sectorNames, i),
                   text_color=TXT_WHITE,  bgcolor=rowBg,          text_size=fontSize, text_halign=text.align_left)
        table.cell(tbl, 1,  row, array.get(etfNames, i),
                   text_color=TXT_BLUE,   bgcolor=rowBg,          text_size=fontSize)
        table.cell(tbl, 2,  row, str.tostring(p1_v,  "#.##") + "%",
                   text_color=TXT_WHITE,  bgcolor=f_perfBg(p1_v),  text_size=fontSize)
        table.cell(tbl, 3,  row, str.tostring(p5_v,  "#.##") + "%",
                   text_color=TXT_WHITE,  bgcolor=f_perfBg(p5_v),  text_size=fontSize)
        table.cell(tbl, 4,  row, str.tostring(p20_v, "#.##") + "%",
                   text_color=TXT_WHITE,  bgcolor=f_perfBg(p20_v), text_size=fontSize)
        table.cell(tbl, 5,  row, str.tostring(rs_v, "#.####"),
                   text_color=TXT_WHITE,  bgcolor=f_perfBg(rs_v * 100), text_size=fontSize)
        table.cell(tbl, 6,  row, str.tostring(vr_v, "#.##") + "x",
                   text_color=TXT_WHITE,  bgcolor=f_volBg(vr_v, rowBg), text_size=fontSize)
        table.cell(tbl, 7,  row, f_cmfLabel(cmf_v),
                   text_color=TXT_WHITE,  bgcolor=f_perfBg(cmf_v * 150), text_size=fontSize)
        table.cell(tbl, 8,  row, f_trendStr(tr_v),
                   text_color=f_trendClr(tr_v), bgcolor=rowBg,    text_size=fontSize)
        table.cell(tbl, 9,  row, str.tostring(sc_v, "#.#"),
                   text_color=TXT_WHITE,  bgcolor=f_scoreBg(sc_v), text_size=fontSize)
        table.cell(tbl, 10, row, f_rotationLabel(sc_v, rs_v, cmf_v, vr_v),
                   text_color=f_rotationClr(sc_v), bgcolor=rowBg,  text_size=fontSize, text_halign=text.align_left)

    // ROW 13 : SPY Benchmark
    spy_p1  = f_perf(spy_c, i_p1)
    spy_p5  = f_perf(spy_c, i_p2)
    spy_p20 = f_perf(spy_c, i_p3)
    spy_vr  = f_volRatio(spy_v, i_volLen)
    spy_cmf = f_cmf(spy_c, spy_h, spy_l, spy_v, i_cmfLen)
    spy_tr  = f_trend(spy_c, i_emaFast, i_emaSlow)

    table.cell(tbl, 0, 13, "── BENCHMARK",
               text_color=TXT_GOLD,  bgcolor=TITLE_BG, text_size=fontSize, text_halign=text.align_left)
    table.cell(tbl, 1, 13, "SPY",
               text_color=TXT_GOLD,  bgcolor=TITLE_BG, text_size=fontSize)
    table.cell(tbl, 2, 13, str.tostring(spy_p1,  "#.##") + "%",
               text_color=TXT_WHITE, bgcolor=f_perfBg(spy_p1),  text_size=fontSize)
    table.cell(tbl, 3, 13, str.tostring(spy_p5,  "#.##") + "%",
               text_color=TXT_WHITE, bgcolor=f_perfBg(spy_p5),  text_size=fontSize)
    table.cell(tbl, 4, 13, str.tostring(spy_p20, "#.##") + "%",
               text_color=TXT_WHITE, bgcolor=f_perfBg(spy_p20), text_size=fontSize)
    table.cell(tbl, 5, 13, "─ BENCHMARK ─",
               text_color=TXT_GOLD,  bgcolor=TITLE_BG, text_size=fontSize)
    table.cell(tbl, 6, 13, str.tostring(spy_vr, "#.##") + "x",
               text_color=TXT_WHITE, bgcolor=f_volBg(spy_vr, TITLE_BG), text_size=fontSize)
    table.cell(tbl, 7, 13, f_cmfLabel(spy_cmf),
               text_color=TXT_WHITE, bgcolor=f_perfBg(spy_cmf * 150), text_size=fontSize)
    table.cell(tbl, 8, 13, f_trendStr(spy_tr),
               text_color=f_trendClr(spy_tr), bgcolor=TITLE_BG, text_size=fontSize)
    table.cell(tbl, 9, 13, "─",
               text_color=TXT_GOLD,  bgcolor=TITLE_BG, text_size=fontSize)
    table.cell(tbl, 10,13, "Broad Market Reference",
               text_color=TXT_GOLD,  bgcolor=TITLE_BG, text_size=fontSize, text_halign=text.align_left)

    // ROW 14 : Futures Divergence
    if i_showFut
        es_d_str  = (es_div  >= 0 ? "+" : "") + str.tostring(es_div,  "#.##") + "%"
        nq_d_str  = (nq_div  >= 0 ? "+" : "") + str.tostring(nq_div,  "#.##") + "%"
        rty_d     = rty_perf - spy_perf
        rty_d_str = (rty_d   >= 0 ? "+" : "") + str.tostring(rty_d,   "#.##") + "%"

        table.cell(tbl, 0, 14, "⚡ FUTURES SIGNAL",
                   text_color=TXT_GOLD, bgcolor=TITLE_BG, text_size=fontSize, text_halign=text.align_left)
        table.cell(tbl, 1, 14, "Div vs Cash",
                   text_color=TXT_BLUE, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 2, 14, "ES: " + es_d_str,
                   text_color=fut_composite > 0 ? BULL_MED : BEAR_MED, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 3, 14, "NQ: " + nq_d_str,
                   text_color=nq_div  > 0 ? BULL_MED : BEAR_MED, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 4, 14, "RTY: " + rty_d_str,
                   text_color=rty_d   > 0 ? BULL_MED : BEAR_MED, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 5, 14, "Composite Δ:",
                   text_color=TXT_BLUE, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 6, 14, str.tostring(fut_composite, "#.##") + "%",
                   text_color=fut_bias_clr, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 7, 14, "",
                   text_color=TXT_WHITE, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 8, 14, "",
                   text_color=TXT_WHITE, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 9, 14, "",
                   text_color=TXT_WHITE, bgcolor=TITLE_BG, text_size=fontSize)
        table.cell(tbl, 10,14, fut_bias,
                   text_color=fut_bias_clr, bgcolor=TITLE_BG, text_size=fontSize, text_halign=text.align_left)

    // ROW 15 : Legend
    if i_showLeg
        legend_items = array.from(
          "COLUMNS:  1D/5D/20D = % Return  |  RS Line = Relative Strength vs SPY  |  Vol Ratio = vs 20-bar avg",
          "CMF = Chaikin Money Flow (+ = institutional buying  |  - = institutional selling)",
          "Trend = Price vs EMA20/50 structure  |  Score = Composite signal (-3 to +3)",
          "ROTATION:  ▲▲ STRONG INFLOW = high-conviction accumulation with vol surge",
          "           ▲  INFLOW = accumulation phase  |  ↑ ACCUMULATION = building position",
          "           ─  NEUTRAL = no directional bias  |  ↓ DISTRIBUTION = smart selling",
          "           ▼  OUTFLOW = distribution phase  |  ▼▼ STRONG OUTFLOW = panic/institutional exit",
          "FUTURES:  Positive divergence (futures > cash) = institutional leading bids",
          "          Negative divergence (futures < cash) = institutional leading offers",
          "RISK NOTE: This indicator is for educational analysis only. Not financial advice.",
          "")
        for li = 0 to 10
            legRow = 15
            lclr   = li < 3 ? TXT_BLUE : li < 7 ? TXT_WHITE : li < 9 ? TXT_GOLD : color.new(color.red, 20)
            legBg  = color.new(#0a0a14, 0)
            if li == 0
                table.cell(tbl, 0, legRow, array.get(legend_items, li),
                           text_color=lclr, bgcolor=legBg, text_size=fontSize, text_halign=text.align_left)
                for ci = 1 to TOTAL_COLS - 1
                    table.cell(tbl, ci, legRow, "", bgcolor=legBg)


// BACKGROUND PLOT (keeps the pane active)
hline(0, color=color.new(color.gray, 90), linestyle=hline.style_dotted)
plot(0, display=display.none, title="Anchor")
````
