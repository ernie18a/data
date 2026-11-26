# Multi-Benchmark Mean-Reversion Map + Triangulation

- url: https://www.tradingview.com/script/xSYsL4mY-Multi-Benchmark-Mean-Reversion-Map-Triangulation/
- type: indicator
- pine_id: PUB;685795527eae4fd88e912b1c3fb8f643
- version: 2.0

## Description

Multi-Benchmark Mean-Reversion Map + Triangulation (MR+T)

The Multi-Benchmark Mean-Reversion Map + Triangulation (MR+T) is an advanced cross-sectional analysis dashboard designed to track statistical exhaustion, macro-driven capital flows, and relative value.

Instead of evaluating an asset in a vacuum, this indicator normalizes asset performance across a matrix of multiple foundational global benchmarks: Debased Fiat (USD), Broad Equities (SPY), Hard Money (Gold), and Energy/Commodities (Brent Crude). By triangulating these distinct macro lenses simultaneously, the script helps traders strip out market noise and separate idiosyncratic asset strength from broad macro shifts.

The Core Innovation: Flexible Universes (Sectors, Stocks, or Both)
A key feature of the script provided in this indicator is its Dual-Persistent Universe Engine. Through a single master switch in the settings, you can completely re-contextualize the dashboard without losing your inputs:

    • Sectors Mode (Macro Cross-Sectional): Tracks a curated, highly representative macro basket of sector ETFs (Technology, Energy, Biotech, Financials, Utilities, etc.) alongside Bitcoin. This mode maps institutional sector rotation as capital flows across the economy.

    • Stocks Mode (Custom Portfolio Basket): Instantly shifts the entire cross-sectional engine to read your own hand-picked portfolio names. Input your 12 favorite stock tickers once, and the script dynamically calculates statistical extensions, oversold conditions, and relative rotation rankings across your custom universe.

    • Per-Row Mode (The Hybrid Mix): Gives you the freedom to blend asset classes (e.g., tracking a specific stock right next to a broader macro sector ETF). When a mixed universe is detected, the cross-sectional synthesis layers gracefully stand down to avoid mathematical mismatching, while individual row metrics—such as specific Z-scores, multi-benchmark conviction, and exhaustion signals—remain completely active.

Mapping Dashboard Insights Directly to Your Main Chart
To get the maximum analytical utility out of this system, you can perfectly synchronize the dashboard rows with the exact asset you are actively trading. By opening the indicator settings and navigating to the 8. Universe section, you can customize any of the 12 available slots to match your specific portfolio holdings or targeted sector ETFs.

When you pull up a specific stock or sector on your main TradingView chart, ensuring that same ticker is active in the script creates a seamless, dual-frame analysis window. While your main window tracks absolute price action and traditional candle patterns, the indicator pane below isolates that very same asset's relative value—mapping its real-time mean reversion, exhaustion levels, and multi-benchmark conviction matrix right beneath its price chart.

Key Use Cases & Analytical Benefits

1. Multi-Benchmark Triangulation (Filtering False Breakouts)
Evaluating a stock against only the S&P 500 can create blind spots. If the S&P 500 is plunging due to a macro liquidity squeeze, a stock might look exceptionally strong relatively, even if it is losing absolute purchasing power. By viewing each asset through four distinct macroeconomic lenses simultaneously, you get a "true" read on strength. High-conviction setups occur when an asset registers concurrent extreme readings across the core voting benchmarks.

2. Identifying Statistical Exhaustion Zones
The indicator converts price ratios into smoothed, volatility-adjusted Z-scores based on a customizable rolling lookback window:

    • Overextended & Undervalued z-score zones: Flagged when an asset stretches beyond standard statistical thresholds (+1.5 and -1.5 standard deviations).

    • Danger and Opportunity Bands: Highlight deep macro overextension and undervaluation zones (drawn from +2.0 to +3.5 and -2 to -3.5 standard deviations) to indicate severe historical premium or discount.

    • Extreme standard deviations cross: Triggered when an asset reverses (crosses) the -2.0 and + 2 standard deviations level. 

3. Systematic Capital Rotation Tracking

When an asset triggers an extreme crossover signal on your primary benchmark, the script prints immediate visual alerts (▲/▼) in the monitoring panel. If one asset is systematically reverting downward out of overextension while another is turning up from undervaluation, the dashboard synthesizes this real-time dynamic into an active, conviction-backed Rotation Verdict.

Clean HUD Design: The "Fintech Grey-Field"

To solve the "spaghetti chart" dilemma common to multi-line indicators, MR+T introduces a Grey-Field Mode:

    • Neutral State: When assets are trading within their normal statistical bands, their plot lines rest in a muted, unobtrusive neutral grey.

    • Exhaustion State: As an asset begins to detach from its mean and enter an overextended or undervalued zone, its line dynamically blends into its vibrant, signature sector color.

    • Actionable Visuals: This allows you to keep the indicator loaded as a clean bottom pane that only commands your visual attention when an asset hits a critical, actionable extreme. You can also lock up to two custom Focus Lines to remain fully illuminated at all times.

How It Works (Under the Hood)

    • Ratio Generation: The script fetches daily close data for your selected universe and divides it by the active macro benchmark. A custom USD Penalty input allows you to apply a fixed percentage haircut to model structural currency debasement and purchasing power loss.

    • Dual Smoothing Process: The raw price ratio is smoothed via an EMA to eliminate hyper-short-term noise, passed into a rolling Simple Moving Average (SMA) and Standard Deviation calculation to generate a clean, normalized Z-score, and then smoothed a final time for fluid line trajectories.

    • The Triangulation Matrix: While the visual line plots track your selected Primary Benchmark, the on-screen table keeps a constant, real-time eye on all core macro frames, tallying a dynamic Conviction Score based on concurrent multi-benchmark agreement.

Disclaimer & TradingView Compliance
This indicator is designed purely for quantitative research, data synthesis, and educational purposes. It displays statistical deviations and relative values based on historical data. It does not provide financial advice, trading signals, or guarantees of future profitability.

## Source Code

````pine
//@version=6
indicator("Multi-Benchmark Mean-Reversion Map + Triangulation", shorttitle="MR+T", 
     overlay=false, max_lines_count=500)

// =====================================================
// 🎨 THEME
// =====================================================
color C_BG       = #0B1215
color C_HEAD     = #101920
color C_TXT      = #E0E0E0
color C_GOLD     = #E8B53D
color C_DIM      = #7A8896
color C_RED      = #E5575E
color C_GREEN    = #35C281
color C_AMBER    = #E89B3D
color C_CYAN     = #35B6C9
color C_YELLOW   = #C9CC4D
// =====================================================
// 🎨 SECTOR COLORS
// =====================================================
color COL_XLK = #35B6C9
color COL_XLE = #EE6352
color COL_GDX = #E8B53D
color COL_XBI = #9B7BE0
color COL_XLF = #4E8FE0
color COL_XLV = #4FBF7B
color COL_XLU = #9DB3C2
color COL_XLP = #BCB2A6
color COL_XLY = #F0608C
color COL_XLI = #C9CC4D
color COL_XLB = #2FB89E
color COL_BTC = #F7931A

// =====================================================
// ⚙️ INPUTS
// =====================================================
string GRP_BENCHMARK = "1. Primary Benchmark"

string benchmark_type = input.string("USD (debased)", "Primary Benchmark", 
     options=["USD (debased)", "Brent Crude", "SPY", "Gold"], 
     group=GRP_BENCHMARK,
     tooltip="Benchmark that the plotted LINES, cross signals (▲/▼), extreme threshold, signal, and rotation verdict are all measured against. The triangulation grid ignores this — it always shows USD, SPY, Gold and Brent together. Only signal is changed.")

float usd_penalty = input.float(-12.0, "USD Debasement Penalty (%)", 
     minval=-50, maxval=0, step=0.5, group=GRP_BENCHMARK,
     tooltip="Fixed haircut (%) applied to the USD benchmark to model debasement / loss of purchasing power. Downstream: it shifts every USD z-score — so it always moves the USD column in the grid, and it moves the plotted lines, signals and verdict whenever Primary Benchmark = USD.\nRange: \n0 = treat USD as stable;\n-8 to -15 reflects typical broad-money debasement (default -12);\nbeyond roughly -20 models aggressive currency loss.")

string GRP_CONFIG = "2. Calculation"
int ratio_lookback = input.int(200, "Ratio Lookback (days)", 
     minval=50, maxval=500, group=GRP_CONFIG,
     tooltip="Window (days) for each z-score's mean and standard deviation — the core normalisation.\n\nLarger = slower, steadier baseline with fewer extremes; smaller = more reactive with more frequent extremes.\n\nRange (trading days):\n ~50-100 = fast/tactical,\n ~150-250 = balanced (default 200, ≈ 9-12 months),\n ~300-500 = slow structural baseline.")
int ratio_smooth = input.int(10, "Ratio Smoothing (EMA bars)", 
     minval=1, maxval=50, group=GRP_CONFIG,
     tooltip="EMA length on the raw price ratio BEFORE the z-score is built.\n\nHigher = smoother but more lag; 1 = off.\n\nRange:\n 1 = raw,\n ~5-15 = light (default 10),\n ~20-50 = heavy / very laggy.")
int z_smooth = input.int(20, "Z-Score Smoothing (EMA bars)", 
     minval=1, maxval=100, group=GRP_CONFIG,
     tooltip="Final EMA applied to the z-score output, after the ratio smoothing above. \n\nHigher = cleaner lines and steadier signals/bands, but more lag. \n\nRange:\n 1 = off,\n ~10-20 = clean (default 20),\n ~30-100 = very smooth but slow to react.")

string GRP_THRESH = "3. Thresholds"
float extreme_z = input.float(2.0, "EXTREME threshold", 
     minval=1.5, maxval=3.0, step=0.1, group=GRP_THRESH,
     tooltip="z-level for a statistically EXTREME reading. Sets the CROSS-SIGNAL trigger — ▲/▼ fire when the primary line crosses ± this value — it drives the Signal column and rotation verdict. It is the solid upper and lower line and the default 'full colour' and reference point of the grey-field. \n\nRange:\n ~1.5-1.8 = more signals (earlier, noisier reversals),\n 2.0 = standard, the rare ~2.5% tail (default),\n ~2.5-3.0 = only the most extreme reversals.")
float overextended_z = input.float(1.5, "OVEREXTENDED z-score", 
     minval=1.0, maxval=3.0, step=0.1, group=GRP_THRESH,
     tooltip="z-level that marks a sector OVEREXTENDED. This is the conviction UP-vote threshold — a benchmark votes 'overbought'. It drives every conviction score, the 'Stretched' total, the rotation verdict and the dashed reference line. Also the default start of the grey-field colour reveal. \n\nRange:\n ~1.0-1.3 = sensitive (flags often, earlier signals),\n 1.5 = standard, the top ~7% of readings (default),\n ~2.0-3.0 = strict (rare flags). \n\nKeep below EXTREME.")
float undervalued_z = input.float(-1.5, "UNDERVALUED z-score", 
     maxval=-1.0, minval=-3.0, step=0.1, group=GRP_THRESH,
     tooltip="z-level that marks a sector UNDERVALUED. This is the conviction DOWN-vote threshold — a benchmark votes 'oversold'. It drives every conviction score, the 'Oversold' total, the rotation verdict and the dashed reference line. Also the default start of the grey-field color reveal. \n\nRange:\n ~-1.0 to -1.3 = sensitive,\n -1.5 = standard (default),\n ~-2.0 to -3.0 = strict (rare flags).")

string GRP_SIGNAL = "4. Cross Signals"
int signal_window = input.int(10, "Signal Freshness Window (bars)", 
     minval=1, maxval=200, group=GRP_SIGNAL,
     tooltip="How many bars a cross signal stays visible in the table after it fires, then clears to —. \n\nCrosses are detected against the EXTREME ±z level (Thresholds), on the primary-benchmark line. The rotation verdict only counts a sector's ▲/▼ leg while its signal is still fresh, so this also controls how long a named rotation stays on the verdict line. \n\nRange (chart bars;\n on a daily chart 1 bar = 1 day):\n ~5 = only very fresh (about 1 week),\n 10 = about 2 weeks (default), \n~20-40 = keeps rotations on screen for weeks, \n100+ = effectively persistent.")

string GRP_LINE = "5. Line Style — Fintech Grey-Field"
bool greyfield_on = input.bool(true, "Grey-field mode (reveal colour in zones)", 
     group=GRP_LINE, 
     tooltip="Lines rest in neutral grey and light up to their sector colour as |z| enters the extended zones. Turn off for classic all-colour lines.")
color grey_field_col = input.color(#6E7884, "Resting line colour", group=GRP_LINE,
     tooltip="Visual only — the neutral colour lines rest at before they reveal. No effect on calculations.")
int rest_transp = input.int(55, "Resting transparency", 
     minval=0, maxval=100, step=1, group=GRP_LINE,
     tooltip="Transparency of the grey resting state. \nHigher = fainter calm lines. \n\nRange:\n 0 = solid grey,\n ~55 = calm (default),\n ~75-90 = ghostly / barely there.")
float reveal_start = input.float(1.5, "Reveal start (|z|)", 
     minval=0.0, maxval=4.0, step=0.1, group=GRP_LINE,
     tooltip="Below this |z| the line is full grey; colour begins blending in above it. \n\nRange:\n ~1.0 = colour warms in early (more colour on chart),\n 1.5 = starts at the overextended line (default),\n ~2.0+ = stays grey until near extreme. \n\nKeep below Full colour.")
float reveal_full = input.float(2.0, "Full colour (|z|)", 
     minval=0.5, maxval=5.0, step=0.1, group=GRP_LINE,
     tooltip="At/above this |z| the line is fully its sector colour and opaque. \n\nRange:\n ~1.5 = ignites quickly,\n 2.0 = at the extreme line (default),\n ~2.5-3.0 = only the sharpest moves fully light up. \n\nKeep above Reveal start.")
string focus1 = input.string("01", "Focus line (always lit) set to row", 
     options=["None","01","02","03","04","05","06","07","08","09","10","11","12"], 
     group=GRP_LINE,
     tooltip="Forces the line on this ROW NUMBER to full colour at all times, overriding the grey-field reveal — keeps one position lit whatever symbol it holds. \n\nThe number is the fixed row position shown in the table's left column. It is a stable ADDRESS, not a ranking: row 01 is not 'best' and row 12 is not 'worst' — the rows always appear in the same order. \n\nVisual only — does not change conviction, signals or the verdict.")
string focus2 = input.string("03", "Focus line (always lit) set to row", 
     options=["None","01","02","03","04","05","06","07","08","09","10","11","12"], 
     group=GRP_LINE,
     tooltip="Forces the line on this ROW NUMBER to full colour at all times, overriding the grey-field reveal — keeps one position lit whatever symbol it holds. \n\nThe number is the fixed row position shown in the table's left column. It is a stable ADDRESS, not a ranking: row 01 is not 'best' and row 12 is not 'worst' — the rows always appear in the same order. \n\nVisual only — does not change conviction, signals or the verdict.")

string GRP_BANDS = "6. Danger / Opportunity Bands"
bool show_bands = input.bool(true, "Show Danger / Opportunity Bands", group=GRP_BANDS,
     tooltip="Shaded zones set beyond the extreme line. Upper (red) = deep overextension / danger. Lower (green) = deep undervaluation / opportunity. \n\nNote: users may want to set this to fit thier z-score buy and sell levels.")
float danger_inner = input.float(2.0, "Danger — inner edge (+)", 
     minval=2.0, maxval=6.0, step=0.1, group=GRP_BANDS,
     tooltip="Visual band edge only — sets where the shaded zone is drawn. No effect on z-scores, signals, conviction or the verdict. \n\nNote: users may want to set this to fit thier z-score sell level.")
float danger_outer = input.float(3.5, "Danger — outer edge (+)", 
     minval=2.0, maxval=6.0, step=0.1, group=GRP_BANDS,
     tooltip="Visual band edge only — no effect on z-scores, signals, conviction or the verdict.")
float opp_inner = input.float(-2.0, "Opportunity — inner edge (−)", 
     minval=-6.0, maxval=-2.0, step=0.1, group=GRP_BANDS,
     tooltip="Visual band edge only — sets where the shaded zone is drawn. No effect on z-scores, signals, conviction or the verdict.\n\nNote: users may want to set this to fit thier z-score buy level.")
float opp_outer = input.float(-3.5, "Opportunity — outer edge (−)", 
     minval=-6.0, maxval=-2.0, step=0.1, group=GRP_BANDS,
     tooltip="Visual band edge only — no effect on z-scores, signals, conviction or the verdict.")
color danger_col = input.color(#E5575E, "Danger fill color", group=GRP_BANDS,
     tooltip="Visual only — band fill colour. No effect on calculations.")
color opp_col = input.color(#35C281, "Opportunity fill color", group=GRP_BANDS,
     tooltip="Visual only — band fill colour. No effect on calculations.")
int band_transp = input.int(70, "Band fill transparency", 
     minval=0, maxval=100, step=1, group=GRP_BANDS,
     tooltip="0 = solid, ~70 = subtle (default), 100 = invisible. Lower toward 50-60 for a bolder zone, raise toward 90 for a whisper.")

string GRP_TABLE = "7. Table Layout"
string table_mode = input.string("Compact", "Table mode (height)", 
     options=["Full", "Compact", "Grid only"], group=GRP_TABLE)
float hdr_row_h = input.float(4.2, "Row height % — header/verdict", 
     minval=0.5, maxval=15.0, step=0.1, group=GRP_TABLE, inline="rowh",
     tooltip="Row height as % of pane. LEFT = header / verdict / chrome rows. RIGHT = the triangulation grid rows. Lower both to shrink the table when it sits as a thin bottom pane. Too low for the text size will clip. Typical: ~1.2-1.5 = tight (bottom strip), ~2-3 = comfortable (defaults 3.0 / 2.0), ~4+ = spacious; below ~1 may clip text.")
float tri_row_h = input.float(3.4, "grid", 
     minval=0.5, maxval=10.0, step=0.1, group=GRP_TABLE, inline="rowh")
bool show_narrative = input.bool(true, "Show Narrative Synthesis", group=GRP_TABLE,
     tooltip="Shows the 'Analytical Read' text block. Only takes effect in FULL table mode.")
bool show_triangulation = input.bool(true, "Show Triangulation Panel", group=GRP_TABLE,
     tooltip="Shows the per-sector grid: each sector's z under USD/SPY/Gold/Brent, its conviction (how many of the 3 voting benchmarks — USD, SPY, Gold — agree) and its cross signal.")

// =====================================================
// 8. UNIVERSE — master switch + dual persistent inputs
// =====================================================
// Each row carries TWO symbols that both persist: a SECTOR field (left) and a
// STOCK field (right). The master switch decides which the whole table reads —
// so you type your portfolio once and flip anytime with no re-entry.
//   • Sectors  → every row uses its sector field   (cross-sectional read live)
//   • Stocks   → every row uses its stock field    (cross-sectional read live,
//                                                    now across YOUR basket)
//   • Per-row  → each row follows its own "use" tick → free mixing. A mixed set
//                isn't one comparable universe, so the cross-sectional layer
//                (rotation + counts + ranking) auto-stands-down; per-row reads
//                (z, conviction, bands, signal) stay fully live.
string GRP_UNI = "8. Universe"
string universe_mode = input.string("Sectors", "Universe mode (master switch)", 
     options=["Sectors", "Stocks", "Per-row"], group=GRP_UNI,
     tooltip="MASTER SWITCH for what the twelve rows track.\n\n• Sectors — every row uses its sector ETF (left field). Original cross-sectional read across the sector set.\n\n• Stocks — every row uses your stock (right field). Type your portfolio once; it persists, so you flip here with no re-entry. The rotation verdict and stretched/oversold counts now run across YOUR twelve names.\n\n• Per-row — each row follows its own 'use' tick, so you can mix sectors and stocks. Because a mixed set isn't one comparable universe, the cross-sectional layer auto-stands-down and the verdict greys to 'mixed universe'; the per-row reads (z-scores, conviction, bands, signal) stay fully live. Conviction is per-row and always valid.\n\nBoth fields on every row are saved by TradingView, so nothing is overwritten when you switch.")

// Each row on one line: [sector picker] [stock picker] [show] [use]
// Row 1 — Technology
string sym_sec_xlk = input.symbol("AMEX:XLK",        "Technology",  inline="x1", group=GRP_UNI)
string sym_stk_xlk = input.symbol("NASDAQ:NVDA",     "↳",           inline="x1", group=GRP_UNI)
bool   show_xlk    = input.bool(true,  "",        inline="x1", group=GRP_UNI)
bool   use_stk_xlk = input.bool(false, "",         inline="x1", group=GRP_UNI)
// Row 2 — Energy
string sym_sec_xle = input.symbol("AMEX:XLE",        "Energy",      inline="x2", group=GRP_UNI)
string sym_stk_xle = input.symbol("NYSE:XOM",        "↳",           inline="x2", group=GRP_UNI)
bool   show_xle    = input.bool(true,  "",        inline="x2", group=GRP_UNI)
bool   use_stk_xle = input.bool(false, "",         inline="x2", group=GRP_UNI)
// Row 3 — Gold Miners
string sym_sec_gdx = input.symbol("AMEX:GDX",        "Gold Miners", inline="x3", group=GRP_UNI)
string sym_stk_gdx = input.symbol("NYSE:NEM",        "↳",           inline="x3", group=GRP_UNI)
bool   show_gdx    = input.bool(true,  "",        inline="x3", group=GRP_UNI)
bool   use_stk_gdx = input.bool(false, "",         inline="x3", group=GRP_UNI)
// Row 4 — Biotech
string sym_sec_xbi = input.symbol("AMEX:XBI",        "Biotech",     inline="x4", group=GRP_UNI)
string sym_stk_xbi = input.symbol("NASDAQ:VRTX",     "↳",           inline="x4", group=GRP_UNI)
bool   show_xbi    = input.bool(true,  "",        inline="x4", group=GRP_UNI)
bool   use_stk_xbi = input.bool(false, "",         inline="x4", group=GRP_UNI)
// Row 5 — Financials
string sym_sec_xlf = input.symbol("AMEX:XLF",        "Financials",  inline="x5", group=GRP_UNI)
string sym_stk_xlf = input.symbol("NYSE:JPM",        "↳",           inline="x5", group=GRP_UNI)
bool   show_xlf    = input.bool(true,  "",        inline="x5", group=GRP_UNI)
bool   use_stk_xlf = input.bool(false, "",         inline="x5", group=GRP_UNI)
// Row 6 — Healthcare
string sym_sec_xlv = input.symbol("AMEX:XLV",        "Healthcare",  inline="x6", group=GRP_UNI)
string sym_stk_xlv = input.symbol("NYSE:LLY",        "↳",           inline="x6", group=GRP_UNI)
bool   show_xlv    = input.bool(true,  "",        inline="x6", group=GRP_UNI)
bool   use_stk_xlv = input.bool(false, "",         inline="x6", group=GRP_UNI)
// Row 7 — Utilities
string sym_sec_xlu = input.symbol("AMEX:XLU",        "Utilities",   inline="x7", group=GRP_UNI)
string sym_stk_xlu = input.symbol("NYSE:NEE",        "↳",           inline="x7", group=GRP_UNI)
bool   show_xlu    = input.bool(true,  "",        inline="x7", group=GRP_UNI)
bool   use_stk_xlu = input.bool(false, "",         inline="x7", group=GRP_UNI)
// Row 8 — Consumer Staples
string sym_sec_xlp = input.symbol("AMEX:XLP",        "Cons Staples", inline="x8", group=GRP_UNI)
string sym_stk_xlp = input.symbol("NASDAQ:WMT",        "↳",           inline="x8", group=GRP_UNI)
bool   show_xlp    = input.bool(true,  "",        inline="x8", group=GRP_UNI)
bool   use_stk_xlp = input.bool(false, "",         inline="x8", group=GRP_UNI)
// Row 9 — Consumer Discretionary
string sym_sec_xly = input.symbol("AMEX:XLY",        "Cons Disc",   inline="x9", group=GRP_UNI)
string sym_stk_xly = input.symbol("NASDAQ:AMZN",     "↳",           inline="x9", group=GRP_UNI)
bool   show_xly    = input.bool(true,  "",        inline="x9", group=GRP_UNI)
bool   use_stk_xly = input.bool(false, "",         inline="x9", group=GRP_UNI)
// Row 10 — Industrials
string sym_sec_xli = input.symbol("AMEX:XLI",        "Industrials", inline="x10", group=GRP_UNI)
string sym_stk_xli = input.symbol("NYSE:CAT",        "↳",           inline="x10", group=GRP_UNI)
bool   show_xli    = input.bool(true,  "",        inline="x10", group=GRP_UNI)
bool   use_stk_xli = input.bool(false, "",         inline="x10", group=GRP_UNI)
// Row 11 — Materials
string sym_sec_xlb = input.symbol("AMEX:XLB",        "Materials",   inline="x11", group=GRP_UNI)
string sym_stk_xlb = input.symbol("NASDAQ:LIN",        "↳",           inline="x11", group=GRP_UNI)
bool   show_xlb    = input.bool(true,  "",        inline="x11", group=GRP_UNI)
bool   use_stk_xlb = input.bool(false, "",         inline="x11", group=GRP_UNI)
// Row 12 — Bitcoin
string sym_sec_btc = input.symbol("BINANCE:BTCUSD", "BTC",     inline="x12", group=GRP_UNI)
string sym_stk_btc = input.symbol("NASDAQ:MSTR",     "↳",           inline="x12", group=GRP_UNI)
bool   show_btc    = input.bool(true,  "",        inline="x12", group=GRP_UNI)
bool   use_stk_btc = input.bool(false, "",         inline="x12", group=GRP_UNI)

// =====================================================
// 🌐 UNIVERSE RESOLUTION (active symbol, coherence, labels)
// =====================================================
// Resolve each row to its active symbol per the master switch, detect whether
// the resulting set is mixed (per-row only), and build display labels/codes.
f_clean_sym(string s) =>
    int p = str.pos(s, ":")
    na(p) ? s : str.substring(s, p + 1)

bool m_stocks = universe_mode == "Stocks"
bool m_perrow = universe_mode == "Per-row"

// per-row: does this row resolve to its STOCK field?
bool us_xlk = m_stocks or (m_perrow and use_stk_xlk)
bool us_xle = m_stocks or (m_perrow and use_stk_xle)
bool us_gdx = m_stocks or (m_perrow and use_stk_gdx)
bool us_xbi = m_stocks or (m_perrow and use_stk_xbi)
bool us_xlf = m_stocks or (m_perrow and use_stk_xlf)
bool us_xlv = m_stocks or (m_perrow and use_stk_xlv)
bool us_xlu = m_stocks or (m_perrow and use_stk_xlu)
bool us_xlp = m_stocks or (m_perrow and use_stk_xlp)
bool us_xly = m_stocks or (m_perrow and use_stk_xly)
bool us_xli = m_stocks or (m_perrow and use_stk_xli)
bool us_xlb = m_stocks or (m_perrow and use_stk_xlb)
bool us_btc = m_stocks or (m_perrow and use_stk_btc)

// active symbol per row
string sym_xlk = us_xlk ? sym_stk_xlk : sym_sec_xlk
string sym_xle = us_xle ? sym_stk_xle : sym_sec_xle
string sym_gdx = us_gdx ? sym_stk_gdx : sym_sec_gdx
string sym_xbi = us_xbi ? sym_stk_xbi : sym_sec_xbi
string sym_xlf = us_xlf ? sym_stk_xlf : sym_sec_xlf
string sym_xlv = us_xlv ? sym_stk_xlv : sym_sec_xlv
string sym_xlu = us_xlu ? sym_stk_xlu : sym_sec_xlu
string sym_xlp = us_xlp ? sym_stk_xlp : sym_sec_xlp
string sym_xly = us_xly ? sym_stk_xly : sym_sec_xly
string sym_xli = us_xli ? sym_stk_xli : sym_sec_xli
string sym_xlb = us_xlb ? sym_stk_xlb : sym_sec_xlb
string sym_btc = us_btc ? sym_stk_btc : sym_sec_btc

// coherence: mixed only when BOTH a stock-row and a sector-row are present
bool any_stock  = us_xlk or us_xle or us_gdx or us_xbi or us_xlf or us_xlv or us_xlu or us_xlp or us_xly or us_xli or us_xlb or us_btc
bool any_sector = (not us_xlk) or (not us_xle) or (not us_gdx) or (not us_xbi) or (not us_xlf) or (not us_xlv) or (not us_xlu) or (not us_xlp) or (not us_xly) or (not us_xli) or (not us_xlb) or (not us_btc)
bool universe_mixed = any_stock and any_sector

// (row labels are built after the fetch, below, so they can include instrument names)

// short codes for the rotation verdict
string code_xlk = us_xlk ? f_clean_sym(sym_stk_xlk) : "XLK"
string code_xle = us_xle ? f_clean_sym(sym_stk_xle) : "XLE"
string code_gdx = us_gdx ? f_clean_sym(sym_stk_gdx) : "GDX"
string code_xbi = us_xbi ? f_clean_sym(sym_stk_xbi) : "XBI"
string code_xlf = us_xlf ? f_clean_sym(sym_stk_xlf) : "XLF"
string code_xlv = us_xlv ? f_clean_sym(sym_stk_xlv) : "XLV"
string code_xlu = us_xlu ? f_clean_sym(sym_stk_xlu) : "XLU"
string code_xlp = us_xlp ? f_clean_sym(sym_stk_xlp) : "XLP"
string code_xly = us_xly ? f_clean_sym(sym_stk_xly) : "XLY"
string code_xli = us_xli ? f_clean_sym(sym_stk_xli) : "XLI"
string code_xlb = us_xlb ? f_clean_sym(sym_stk_xlb) : "XLB"
string code_btc = us_btc ? f_clean_sym(sym_stk_btc) : "BTC"

// row-1 name for the (Full-mode) narrative line
string r1_name = us_xlk ? f_clean_sym(sym_stk_xlk) : "AI Infra (XLK)"

// =====================================================
// 🔄 FETCH ROW PRICES (once) — active symbol per row
// =====================================================
f_get_close(string sym) =>
    request.security(sym, "D", close, ignore_invalid_symbol=true)

// price + instrument name in ONE security call (no extra call vs close-only)
f_get_meta(string sym) =>
    request.security(sym, "D", [close, syminfo.description], ignore_invalid_symbol=true)

[xlk_px, xlk_desc] = f_get_meta(sym_xlk)
[xle_px, xle_desc] = f_get_meta(sym_xle)
[gdx_px, gdx_desc] = f_get_meta(sym_gdx)
[xbi_px, xbi_desc] = f_get_meta(sym_xbi)
[xlf_px, xlf_desc] = f_get_meta(sym_xlf)
[xlv_px, xlv_desc] = f_get_meta(sym_xlv)
[xlu_px, xlu_desc] = f_get_meta(sym_xlu)
[xlp_px, xlp_desc] = f_get_meta(sym_xlp)
[xly_px, xly_desc] = f_get_meta(sym_xly)
[xli_px, xli_desc] = f_get_meta(sym_xli)
[xlb_px, xlb_desc] = f_get_meta(sym_xlb)
[btc_px, btc_desc] = f_get_meta(sym_btc)

// =====================================================
// 🔄 FETCH ALL FOUR BENCHMARKS
// =====================================================
float bench_usd   = 1.0 + (usd_penalty / 100.0)
float bench_brent = f_get_close("TVC:UKOIL")
float bench_spy   = f_get_close("AMEX:SPY")
float bench_gold  = f_get_close("TVC:GOLD")

// =====================================================
// 🏷️ ROW LABELS (ticker · name)
// =====================================================
// Sector-default rows keep the curated short name ("XLK · Technology").
// Stock / custom rows show the cleaned ticker + the instrument's own name
// from syminfo.description, capped so long fund names don't bloat the table.
// (raise / lower the 22 below to taste; set to a big number to never cap.)
f_lbl(bool isstock, string sec, string secdef, string nice, string active, string desc) =>
    string tk = f_clean_sym(active)
    string nm = na(desc) ? "" : (str.length(desc) > 22 ? str.substring(desc, 0, 21) + "…" : desc)
    (not isstock and sec == secdef) ? "■ " + nice : (nm == "" ? "■ " + tk : "■ " + tk + " · " + nm)

string lbl_xlk = f_lbl(us_xlk, sym_sec_xlk, "AMEX:XLK",        "XLK · Technology",             sym_xlk, xlk_desc)
string lbl_xle = f_lbl(us_xle, sym_sec_xle, "AMEX:XLE",        "XLE · Energy",                 sym_xle, xle_desc)
string lbl_gdx = f_lbl(us_gdx, sym_sec_gdx, "AMEX:GDX",        "GDX · Gold Miners",            sym_gdx, gdx_desc)
string lbl_xbi = f_lbl(us_xbi, sym_sec_xbi, "AMEX:XBI",        "XBI · Biotech",                sym_xbi, xbi_desc)
string lbl_xlf = f_lbl(us_xlf, sym_sec_xlf, "AMEX:XLF",        "XLF · Financials",             sym_xlf, xlf_desc)
string lbl_xlv = f_lbl(us_xlv, sym_sec_xlv, "AMEX:XLV",        "XLV · Healthcare",             sym_xlv, xlv_desc)
string lbl_xlu = f_lbl(us_xlu, sym_sec_xlu, "AMEX:XLU",        "XLU · Utilities",              sym_xlu, xlu_desc)
string lbl_xlp = f_lbl(us_xlp, sym_sec_xlp, "AMEX:XLP",        "XLP · Consumer Staples",       sym_xlp, xlp_desc)
string lbl_xly = f_lbl(us_xly, sym_sec_xly, "AMEX:XLY",        "XLY · Consumer Discretionary", sym_xly, xly_desc)
string lbl_xli = f_lbl(us_xli, sym_sec_xli, "AMEX:XLI",        "XLI · Industrials",            sym_xli, xli_desc)
string lbl_xlb = f_lbl(us_xlb, sym_sec_xlb, "AMEX:XLB",        "XLB · Materials",              sym_xlb, xlb_desc)
string lbl_btc = f_lbl(us_btc, sym_sec_btc, "BINANCE:BTCUSD",  "BTC · Bitcoin",                sym_btc, btc_desc)

// =====================================================
// 🧮 GENERIC Z-SCORE FUNCTION
// =====================================================
f_smooth(float src, int len) =>
    ta.ema(src, len)

f_zscore_against(float px, float bench) =>
    if na(px) or na(bench) or bench == 0
        na
    else
        float raw_ratio = px / bench
        float smoothed  = ta.ema(raw_ratio, ratio_smooth)
        float mean      = ta.sma(smoothed, ratio_lookback)
        float stdev     = ta.stdev(smoothed, ratio_lookback)
        float z         = stdev > 0 ? (smoothed - mean) / stdev : 0.0
        float z_out     = f_smooth(z, z_smooth)
        z_out

// =====================================================
// 🧮 COMPUTE Z-SCORES FOR ALL ROWS × ALL BENCHMARKS
// =====================================================
// Tech
float xlk_usd   = f_zscore_against(xlk_px, bench_usd)
float xlk_brent = f_zscore_against(xlk_px, bench_brent)
float xlk_spy   = f_zscore_against(xlk_px, bench_spy)
float xlk_gold  = f_zscore_against(xlk_px, bench_gold)

// Energy
float xle_usd   = f_zscore_against(xle_px, bench_usd)
float xle_brent = f_zscore_against(xle_px, bench_brent)
float xle_spy   = f_zscore_against(xle_px, bench_spy)
float xle_gold  = f_zscore_against(xle_px, bench_gold)

// Gold Miners
float gdx_usd   = f_zscore_against(gdx_px, bench_usd)
float gdx_brent = f_zscore_against(gdx_px, bench_brent)
float gdx_spy   = f_zscore_against(gdx_px, bench_spy)
float gdx_gold  = f_zscore_against(gdx_px, bench_gold)

// Biotech
float xbi_usd   = f_zscore_against(xbi_px, bench_usd)
float xbi_brent = f_zscore_against(xbi_px, bench_brent)
float xbi_spy   = f_zscore_against(xbi_px, bench_spy)
float xbi_gold  = f_zscore_against(xbi_px, bench_gold)

// Financials
float xlf_usd   = f_zscore_against(xlf_px, bench_usd)
float xlf_brent = f_zscore_against(xlf_px, bench_brent)
float xlf_spy   = f_zscore_against(xlf_px, bench_spy)
float xlf_gold  = f_zscore_against(xlf_px, bench_gold)

// Healthcare
float xlv_usd   = f_zscore_against(xlv_px, bench_usd)
float xlv_brent = f_zscore_against(xlv_px, bench_brent)
float xlv_spy   = f_zscore_against(xlv_px, bench_spy)
float xlv_gold  = f_zscore_against(xlv_px, bench_gold)

// Utilities
float xlu_usd   = f_zscore_against(xlu_px, bench_usd)
float xlu_brent = f_zscore_against(xlu_px, bench_brent)
float xlu_spy   = f_zscore_against(xlu_px, bench_spy)
float xlu_gold  = f_zscore_against(xlu_px, bench_gold)

// Staples
float xlp_usd   = f_zscore_against(xlp_px, bench_usd)
float xlp_brent = f_zscore_against(xlp_px, bench_brent)
float xlp_spy   = f_zscore_against(xlp_px, bench_spy)
float xlp_gold  = f_zscore_against(xlp_px, bench_gold)

// Consumer Discretionary
float xly_usd   = f_zscore_against(xly_px, bench_usd)
float xly_brent = f_zscore_against(xly_px, bench_brent)
float xly_spy   = f_zscore_against(xly_px, bench_spy)
float xly_gold  = f_zscore_against(xly_px, bench_gold)

// Industrials
float xli_usd   = f_zscore_against(xli_px, bench_usd)
float xli_brent = f_zscore_against(xli_px, bench_brent)
float xli_spy   = f_zscore_against(xli_px, bench_spy)
float xli_gold  = f_zscore_against(xli_px, bench_gold)

// Materials
float xlb_usd   = f_zscore_against(xlb_px, bench_usd)
float xlb_brent = f_zscore_against(xlb_px, bench_brent)
float xlb_spy   = f_zscore_against(xlb_px, bench_spy)
float xlb_gold  = f_zscore_against(xlb_px, bench_gold)

// Bitcoin
float btc_usd   = f_zscore_against(btc_px, bench_usd)
float btc_brent = f_zscore_against(btc_px, bench_brent)
float btc_spy   = f_zscore_against(btc_px, bench_spy)
float btc_gold  = f_zscore_against(btc_px, bench_gold)

// =====================================================
// 🔧 PRIMARY BENCHMARK SELECTION (for chart and main table)
// =====================================================
float xlk_z = benchmark_type == "USD (debased)" ? xlk_usd : 
              benchmark_type == "Brent Crude" ? xlk_brent : 
              benchmark_type == "SPY" ? xlk_spy : xlk_gold
float xle_z = benchmark_type == "USD (debased)" ? xle_usd : 
              benchmark_type == "Brent Crude" ? xle_brent : 
              benchmark_type == "SPY" ? xle_spy : xle_gold
float gdx_z = benchmark_type == "USD (debased)" ? gdx_usd : 
              benchmark_type == "Brent Crude" ? gdx_brent : 
              benchmark_type == "SPY" ? gdx_spy : gdx_gold
float xbi_z = benchmark_type == "USD (debased)" ? xbi_usd : 
              benchmark_type == "Brent Crude" ? xbi_brent : 
              benchmark_type == "SPY" ? xbi_spy : xbi_gold
float xlf_z = benchmark_type == "USD (debased)" ? xlf_usd : 
              benchmark_type == "Brent Crude" ? xlf_brent : 
              benchmark_type == "SPY" ? xlf_spy : xlf_gold
float xlv_z = benchmark_type == "USD (debased)" ? xlv_usd : 
              benchmark_type == "Brent Crude" ? xlv_brent : 
              benchmark_type == "SPY" ? xlv_spy : xlv_gold
float xlu_z = benchmark_type == "USD (debased)" ? xlu_usd : 
              benchmark_type == "Brent Crude" ? xlu_brent : 
              benchmark_type == "SPY" ? xlu_spy : xlu_gold
float xlp_z = benchmark_type == "USD (debased)" ? xlp_usd : 
              benchmark_type == "Brent Crude" ? xlp_brent : 
              benchmark_type == "SPY" ? xlp_spy : xlp_gold
float xly_z = benchmark_type == "USD (debased)" ? xly_usd : 
              benchmark_type == "Brent Crude" ? xly_brent : 
              benchmark_type == "SPY" ? xly_spy : xly_gold
float xli_z = benchmark_type == "USD (debased)" ? xli_usd : 
              benchmark_type == "Brent Crude" ? xli_brent : 
              benchmark_type == "SPY" ? xli_spy : xli_gold
float xlb_z = benchmark_type == "USD (debased)" ? xlb_usd : 
              benchmark_type == "Brent Crude" ? xlb_brent : 
              benchmark_type == "SPY" ? xlb_spy : xlb_gold
float btc_z = benchmark_type == "USD (debased)" ? btc_usd : 
              benchmark_type == "Brent Crude" ? btc_brent : 
              benchmark_type == "SPY" ? btc_spy : btc_gold

string benchmark_label = benchmark_type == "USD (debased)" ? "USD " + str.tostring(usd_penalty, "#.#") + "%" : benchmark_type == "Brent Crude" ? "Brent (UKOIL)" : benchmark_type == "SPY" ? "SPY" : "Gold"

// =====================================================
// 🎚️ GREY-FIELD LINE COLOUR (fintech reveal)
// =====================================================
// Lines rest in neutral grey and reveal their sector colour as |z|
// climbs from reveal_start → reveal_full. Focused rows stay full.
f_focus(string code) =>
    focus1 == code or focus2 == code

f_line_col(float z, color base, bool focused) =>
    color full = color.new(base, 0)
    color rest = color.new(grey_field_col, rest_transp)
    color out = full
    if greyfield_on and not focused
        float d = na(z) ? 0.0 : math.abs(z)
        out := color.from_gradient(d, reveal_start, reveal_full, rest, full)
    out

// =====================================================
// 📈 PLOTS
// =====================================================
plot(show_xlk ? xlk_z : na, "XLK", color=f_line_col(xlk_z, COL_XLK, f_focus("01")), linewidth=1)
plot(show_xle ? xle_z : na, "XLE", color=f_line_col(xle_z, COL_XLE, f_focus("02")), linewidth=1)
plot(show_gdx ? gdx_z : na, "GDX", color=f_line_col(gdx_z, COL_GDX, f_focus("03")), linewidth=1)
plot(show_xbi ? xbi_z : na, "XBI", color=f_line_col(xbi_z, COL_XBI, f_focus("04")), linewidth=1)
plot(show_xlf ? xlf_z : na, "XLF", color=f_line_col(xlf_z, COL_XLF, f_focus("05")), linewidth=1)
plot(show_xlv ? xlv_z : na, "XLV", color=f_line_col(xlv_z, COL_XLV, f_focus("06")), linewidth=1)
plot(show_xlu ? xlu_z : na, "XLU", color=f_line_col(xlu_z, COL_XLU, f_focus("07")), linewidth=1)
plot(show_xlp ? xlp_z : na, "XLP", color=f_line_col(xlp_z, COL_XLP, f_focus("08")), linewidth=1)
plot(show_xly ? xly_z : na, "XLY", color=f_line_col(xly_z, COL_XLY, f_focus("09")), linewidth=1)
plot(show_xli ? xli_z : na, "XLI", color=f_line_col(xli_z, COL_XLI, f_focus("10")), linewidth=1)
plot(show_xlb ? xlb_z : na, "XLB", color=f_line_col(xlb_z, COL_XLB, f_focus("11")), linewidth=1)
plot(show_btc ? btc_z : na, "BTC", color=f_line_col(btc_z, COL_BTC, f_focus("12")), linewidth=1)

// =====================================================
// 🏷️ END-OF-LINE TAGS (the two focused rows)
// =====================================================
// A small tag at each focused line's last value: "NN  ticker" in the row's
// colour, so the always-lit lines are identifiable at the right edge.
f_focus_pick(string fsel) =>
    float z = na
    color c = C_DIM
    string cd = ""
    if fsel == "01"
        z := show_xlk ? xlk_z : na
        c := COL_XLK
        cd := code_xlk
    else if fsel == "02"
        z := show_xle ? xle_z : na
        c := COL_XLE
        cd := code_xle
    else if fsel == "03"
        z := show_gdx ? gdx_z : na
        c := COL_GDX
        cd := code_gdx
    else if fsel == "04"
        z := show_xbi ? xbi_z : na
        c := COL_XBI
        cd := code_xbi
    else if fsel == "05"
        z := show_xlf ? xlf_z : na
        c := COL_XLF
        cd := code_xlf
    else if fsel == "06"
        z := show_xlv ? xlv_z : na
        c := COL_XLV
        cd := code_xlv
    else if fsel == "07"
        z := show_xlu ? xlu_z : na
        c := COL_XLU
        cd := code_xlu
    else if fsel == "08"
        z := show_xlp ? xlp_z : na
        c := COL_XLP
        cd := code_xlp
    else if fsel == "09"
        z := show_xly ? xly_z : na
        c := COL_XLY
        cd := code_xly
    else if fsel == "10"
        z := show_xli ? xli_z : na
        c := COL_XLI
        cd := code_xli
    else if fsel == "11"
        z := show_xlb ? xlb_z : na
        c := COL_XLB
        cd := code_xlb
    else if fsel == "12"
        z := show_btc ? btc_z : na
        c := COL_BTC
        cd := code_btc
    [z, c, cd]

[f1z, f1c, f1cd] = f_focus_pick(focus1)
[f2z, f2c, f2cd] = f_focus_pick(focus2)

var label lab_f1 = na
var label lab_f2 = na
if barstate.islast
    label.delete(lab_f1)
    lab_f1 := (focus1 == "None" or na(f1z)) ? na : label.new(bar_index + 2, f1z, focus1, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(f1c, 80), textcolor=f1c, size=size.small)
    label.delete(lab_f2)
    lab_f2 := (focus2 == "None" or na(f2z)) ? na : label.new(bar_index + 2, f2z, focus2, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(f2c, 80), textcolor=f2c, size=size.small)

hline(0, "Mean", color=color.new(C_YELLOW, 30), linestyle=hline.style_solid)
hline(overextended_z, "Overextended", color=color.new(C_RED, 30), linestyle=hline.style_dashed)
hline(undervalued_z, "Undervalued", color=color.new(C_GREEN, 30), linestyle=hline.style_dashed)
hline(extreme_z, "Extreme +", color=color.new(C_RED, 0), linestyle=hline.style_solid)
hline(-extreme_z, "Extreme -", color=color.new(C_GREEN, 0), linestyle=hline.style_solid)

// =====================================================
// 🚨 DANGER / OPPORTUNITY BANDS
// =====================================================
// Danger (red):        deep overextension,  +danger_inner → +danger_outer
// Opportunity (green): deep undervaluation,   opp_inner   →   opp_outer
// Boundary lines kept invisible (fills carry the zone); reduces hline clutter.
color dgr_line = color.new(danger_col, 100)
color opp_line = color.new(opp_col, 100)

h_danger_in  = hline(danger_inner, "Danger Inner (+)", color=dgr_line, linestyle=hline.style_dotted, linewidth=1)
h_danger_out = hline(danger_outer, "Danger Outer (+)", color=dgr_line, linestyle=hline.style_dotted, linewidth=1)
fill(h_danger_in, h_danger_out, color=show_bands ? color.new(danger_col, band_transp) : na, title="Danger Band (+)")

h_opp_in  = hline(opp_inner, "Opportunity Inner (−)", color=opp_line, linestyle=hline.style_dotted, linewidth=1)
h_opp_out = hline(opp_outer, "Opportunity Outer (−)", color=opp_line, linestyle=hline.style_dotted, linewidth=1)
fill(h_opp_in, h_opp_out, color=show_bands ? color.new(opp_col, band_transp) : na, title="Opportunity Band (−)")

// =====================================================
// 🔧 CLASSIFICATION HELPERS
// =====================================================
f_z_classification(float z) =>
    string cls = "NEUTRAL"
    if not na(z)
        if z >= extreme_z
            cls := "EXTREME +"
        else if z >= overextended_z
            cls := "OVEREXTENDED"
        else if z <= -extreme_z
            cls := "EXTREME -"
        else if z <= undervalued_z
            cls := "UNDERVALUED"
        else if z > 0
            cls := "Above mean"
        else
            cls := "Below mean"
    cls

f_z_color(float z) =>
    color col = C_DIM
    if not na(z)
        if z >= extreme_z
            col := C_RED
        else if z >= overextended_z
            col := color.new(C_RED, 30)
        else if z <= -extreme_z
            col := C_GREEN
        else if z <= undervalued_z
            col := color.new(C_GREEN, 30)
        else if math.abs(z) < 0.5
            col := C_DIM
        else
            col := C_TXT
    col

// =====================================================
// 🔧 TRIANGULATION CONVICTION
// =====================================================
// Conviction = how many of the 3 voting benchmarks (USD / SPY / Gold) agree.
// Brent is shown in the table for energy/materials context but does NOT vote.
// Returns 0-3 for over/under counts. PER-ROW — valid in mixed universe too.
f_triangulation_score(float zu, float zs, float zg) =>
    int over_count  = 0
    int under_count = 0
    if not na(zu)
        if zu >= overextended_z
            over_count := over_count + 1
        if zu <= undervalued_z
            under_count := under_count + 1
    if not na(zs)
        if zs >= overextended_z
            over_count := over_count + 1
        if zs <= undervalued_z
            under_count := under_count + 1
    if not na(zg)
        if zg >= overextended_z
            over_count := over_count + 1
        if zg <= undervalued_z
            under_count := under_count + 1
    [over_count, under_count]

f_conviction_label(int over, int under) =>
    string lbl = "—"
    if over >= 3
        lbl := "HIGH ↑ (3/3)"
    else if under >= 3
        lbl := "HIGH ↓ (3/3)"
    else if over == 2
        lbl := "MED ↑ (2/3)"
    else if under == 2
        lbl := "MED ↓ (2/3)"
    else if over == 1
        lbl := "LOW ↑ (1/3)"
    else if under == 1
        lbl := "LOW ↓ (1/3)"
    lbl

f_conviction_color(int over, int under) =>
    color col = C_DIM
    if over >= 3
        col := C_RED
    else if under >= 3
        col := C_GREEN
    else if over == 2
        col := color.new(C_RED, 30)
    else if under == 2
        col := color.new(C_GREEN, 30)
    col

// =====================================================
// 🔔 CROSS-SIGNAL HELPERS
// =====================================================
// Bullish: primary-benchmark line crosses UP through -extreme_z
// Bearish: primary-benchmark line crosses DOWN through +extreme_z
// A fired signal stays "fresh" for signal_window bars, then clears to —
// PER-ROW — a row crosses its OWN extreme, so valid in mixed universe too.
f_cross_state(float z, float ext, int window) =>
    var int last_bar = na
    var int last_dir = 0
    if ta.crossover(z, -ext)
        last_bar := bar_index
        last_dir := 1
    if ta.crossunder(z, ext)
        last_bar := bar_index
        last_dir := -1
    int age = na(last_bar) ? na : bar_index - last_bar
    bool fresh = not na(age) and age <= window
    [fresh ? last_dir : 0, fresh ? age : na]

f_signal_label(int dir, int age) =>
    string s = "—"
    if dir == 1
        s := "▲ " + (age == 0 ? "now" : str.tostring(age) + "b")
    else if dir == -1
        s := "▼ " + (age == 0 ? "now" : str.tostring(age) + "b")
    s

f_signal_color(int dir) =>
    dir == 1 ? C_GREEN : dir == -1 ? C_RED : C_DIM

// =====================================================
// 🔔 COMPUTE CROSS SIGNALS (every bar, primary benchmark)
// =====================================================
[xlk_sig, xlk_age] = f_cross_state(xlk_z, extreme_z, signal_window)
[xle_sig, xle_age] = f_cross_state(xle_z, extreme_z, signal_window)
[gdx_sig, gdx_age] = f_cross_state(gdx_z, extreme_z, signal_window)
[xbi_sig, xbi_age] = f_cross_state(xbi_z, extreme_z, signal_window)
[xlf_sig, xlf_age] = f_cross_state(xlf_z, extreme_z, signal_window)
[xlv_sig, xlv_age] = f_cross_state(xlv_z, extreme_z, signal_window)
[xlu_sig, xlu_age] = f_cross_state(xlu_z, extreme_z, signal_window)
[xlp_sig, xlp_age] = f_cross_state(xlp_z, extreme_z, signal_window)
[xly_sig, xly_age] = f_cross_state(xly_z, extreme_z, signal_window)
[xli_sig, xli_age] = f_cross_state(xli_z, extreme_z, signal_window)
[xlb_sig, xlb_age] = f_cross_state(xlb_z, extreme_z, signal_window)
[btc_sig, btc_age] = f_cross_state(btc_z, extreme_z, signal_window)

// =====================================================
// 🔧 CONVICTION PAIRS (global — USD/SPY/Gold vote, shared by verdict + table)
// =====================================================
[xlk_over, xlk_under] = f_triangulation_score(xlk_usd, xlk_spy, xlk_gold)
[xle_over, xle_under] = f_triangulation_score(xle_usd, xle_spy, xle_gold)
[gdx_over, gdx_under] = f_triangulation_score(gdx_usd, gdx_spy, gdx_gold)
[xbi_over, xbi_under] = f_triangulation_score(xbi_usd, xbi_spy, xbi_gold)
[xlf_over, xlf_under] = f_triangulation_score(xlf_usd, xlf_spy, xlf_gold)
[xlv_over, xlv_under] = f_triangulation_score(xlv_usd, xlv_spy, xlv_gold)
[xlu_over, xlu_under] = f_triangulation_score(xlu_usd, xlu_spy, xlu_gold)
[xlp_over, xlp_under] = f_triangulation_score(xlp_usd, xlp_spy, xlp_gold)
[xly_over, xly_under] = f_triangulation_score(xly_usd, xly_spy, xly_gold)
[xli_over, xli_under] = f_triangulation_score(xli_usd, xli_spy, xli_gold)
[xlb_over, xlb_under] = f_triangulation_score(xlb_usd, xlb_spy, xlb_gold)
[btc_over, btc_under] = f_triangulation_score(btc_usd, btc_spy, btc_gold)

// =====================================================
// 📊 SYNTHESIS COUNTS (using primary benchmark) — cross-sectional
// =====================================================
float max_pos_z = -999.0
string max_pos_name = ""
float max_neg_z = 999.0
string max_neg_name = ""

if not na(xlk_z)
    if xlk_z > max_pos_z
        max_pos_z := xlk_z
        max_pos_name := lbl_xlk
    if xlk_z < max_neg_z
        max_neg_z := xlk_z
        max_neg_name := lbl_xlk

if not na(xle_z)
    if xle_z > max_pos_z
        max_pos_z := xle_z
        max_pos_name := lbl_xle
    if xle_z < max_neg_z
        max_neg_z := xle_z
        max_neg_name := lbl_xle

if not na(gdx_z)
    if gdx_z > max_pos_z
        max_pos_z := gdx_z
        max_pos_name := lbl_gdx
    if gdx_z < max_neg_z
        max_neg_z := gdx_z
        max_neg_name := lbl_gdx

if not na(xbi_z)
    if xbi_z > max_pos_z
        max_pos_z := xbi_z
        max_pos_name := lbl_xbi
    if xbi_z < max_neg_z
        max_neg_z := xbi_z
        max_neg_name := lbl_xbi

if not na(xlf_z)
    if xlf_z > max_pos_z
        max_pos_z := xlf_z
        max_pos_name := lbl_xlf
    if xlf_z < max_neg_z
        max_neg_z := xlf_z
        max_neg_name := lbl_xlf

if not na(xlv_z)
    if xlv_z > max_pos_z
        max_pos_z := xlv_z
        max_pos_name := lbl_xlv
    if xlv_z < max_neg_z
        max_neg_z := xlv_z
        max_neg_name := lbl_xlv

if not na(xlu_z)
    if xlu_z > max_pos_z
        max_pos_z := xlu_z
        max_pos_name := lbl_xlu
    if xlu_z < max_neg_z
        max_neg_z := xlu_z
        max_neg_name := lbl_xlu

if not na(xlp_z)
    if xlp_z > max_pos_z
        max_pos_z := xlp_z
        max_pos_name := lbl_xlp
    if xlp_z < max_neg_z
        max_neg_z := xlp_z
        max_neg_name := lbl_xlp

if not na(xly_z)
    if xly_z > max_pos_z
        max_pos_z := xly_z
        max_pos_name := lbl_xly
    if xly_z < max_neg_z
        max_neg_z := xly_z
        max_neg_name := lbl_xly

if not na(xli_z)
    if xli_z > max_pos_z
        max_pos_z := xli_z
        max_pos_name := lbl_xli
    if xli_z < max_neg_z
        max_neg_z := xli_z
        max_neg_name := lbl_xli

if not na(xlb_z)
    if xlb_z > max_pos_z
        max_pos_z := xlb_z
        max_pos_name := lbl_xlb
    if xlb_z < max_neg_z
        max_neg_z := xlb_z
        max_neg_name := lbl_xlb

if not na(btc_z)
    if btc_z > max_pos_z
        max_pos_z := btc_z
        max_pos_name := lbl_btc
    if btc_z < max_neg_z
        max_neg_z := btc_z
        max_neg_name := lbl_btc

// =====================================================
// 📊 ROTATION VERDICT (signal-derived, conviction-backed) — cross-sectional
// =====================================================
// Clean rotation = an opposing pair in the Signal column:
//   OUT-leg = bearish reversal (▼, crossed down thru +extreme) backed by overextension conviction (over >= 2)
//   IN-leg  = bullish reversal (▲, crossed up thru -extreme)   backed by undervaluation conviction (under >= 2)
// Headline pair = highest conviction, then most-extreme |z|, on each side.
// Fallback = directional skew from the 3-benchmark conviction counts.
// Stands down when the universe is mixed (see override below).
array<string> _rot_codes = array.from(code_xlk, code_xle, code_gdx, code_xbi, code_xlf, code_xlv, code_xlu, code_xlp, code_xly, code_xli, code_xlb, code_btc)
array<int>   _rot_sig = array.from(xlk_sig, xle_sig, gdx_sig, xbi_sig, xlf_sig, xlv_sig, xlu_sig, xlp_sig, xly_sig, xli_sig, xlb_sig, btc_sig)
array<int>   _rot_ov  = array.from(xlk_over, xle_over, gdx_over, xbi_over, xlf_over, xlv_over, xlu_over, xlp_over, xly_over, xli_over, xlb_over, btc_over)
array<int>   _rot_un  = array.from(xlk_under, xle_under, gdx_under, xbi_under, xlf_under, xlv_under, xlu_under, xlp_under, xly_under, xli_under, xlb_under, btc_under)
array<float> _rot_z   = array.from(xlk_z, xle_z, gdx_z, xbi_z, xlf_z, xlv_z, xlu_z, xlp_z, xly_z, xli_z, xlb_z, btc_z)

string out_leg = ""
string in_leg  = ""
float  out_sc  = -1.0
float  in_sc   = -1.0
int    tri_over_ct  = 0
int    tri_under_ct = 0

for i = 0 to 11
    int   sg = array.get(_rot_sig, i)
    int   ov = array.get(_rot_ov, i)
    int   un = array.get(_rot_un, i)
    float zz = array.get(_rot_z, i)
    float az = na(zz) ? 0.0 : math.abs(zz)
    if ov >= 2
        tri_over_ct := tri_over_ct + 1
    if un >= 2
        tri_under_ct := tri_under_ct + 1
    if sg == -1 and ov >= 2
        float sc = ov * 100.0 + az
        if sc > out_sc
            out_sc  := sc
            out_leg := array.get(_rot_codes, i)
    if sg == 1 and un >= 2
        float sc = un * 100.0 + az
        if sc > in_sc
            in_sc  := sc
            in_leg := array.get(_rot_codes, i)

bool rotation_found = out_leg != "" and in_leg != ""

string regime_synthesis = "BALANCED"
color  synth_col        = C_DIM

if rotation_found
    regime_synthesis := "ROTATION:  " + out_leg + " ▼  →  " + in_leg + " ▲"
    synth_col        := C_AMBER
else if tri_over_ct >= 3 and tri_under_ct >= 3
    regime_synthesis := "DIVERGENCE — stretched both ways, no clean trigger yet"
    synth_col        := color.new(C_AMBER, 25)
else if tri_over_ct >= 3
    regime_synthesis := "BROAD OVEREXTENSION — " + str.tostring(tri_over_ct) + " names stretched"
    synth_col        := C_RED
else if tri_under_ct >= 3
    regime_synthesis := "ACCUMULATION ZONE — " + str.tostring(tri_under_ct) + " names oversold"
    synth_col        := C_GREEN
else if tri_over_ct >= 1 and tri_under_ct >= 1
    regime_synthesis := "MIXED — watching for a rotation trigger"
    synth_col        := color.new(C_AMBER, 40)
else
    regime_synthesis := "BALANCED — no conviction extremes"
    synth_col        := C_DIM

// Mixed-universe override: cross-sectional read stands down, per-row stays live.
if universe_mixed
    regime_synthesis := "MIXED UNIVERSE — per-row read only, cross-sectional paused"
    synth_col        := C_AMBER

// =====================================================
// 📝 NARRATIVE SYNTHESIS (with triangulation awareness)
// =====================================================
string narrative_line1 = ""
string narrative_line2 = ""
string narrative_line3 = ""
string narrative_line4 = ""
string narrative_line5 = ""

// strip the "■ " swatch prefix for prose use
string max_pos_disp = str.replace_all(max_pos_name, "■ ", "")
string max_neg_disp = str.replace_all(max_neg_name, "■ ", "")

if max_pos_z >= extreme_z
    narrative_line1 := "Dominant signal: " + max_pos_disp + " at " + 
         str.tostring(max_pos_z, "#.##") + "σ on " + benchmark_label + " — statistically extreme."
else if max_pos_z >= overextended_z
    narrative_line1 := "Strongest extension: " + max_pos_disp + " at " + 
         str.tostring(max_pos_z, "#.##") + "σ — overextended territory."
else if max_pos_z > 1.0
    narrative_line1 := "Modest leadership: " + max_pos_disp + " at " + 
         str.tostring(max_pos_z, "#.##") + "σ — above mean."
else
    narrative_line1 := "No row showing meaningful extension on primary benchmark."

if max_neg_z <= -extreme_z
    narrative_line2 := "Deepest undervaluation: " + max_neg_disp + " at " + 
         str.tostring(max_neg_z, "#.##") + "σ — statistically extreme undervaluation."
else if max_neg_z <= undervalued_z
    narrative_line2 := "Undervalued: " + max_neg_disp + " at " + 
         str.tostring(max_neg_z, "#.##") + "σ — undervalued zone."
else if max_neg_z < -1.0
    narrative_line2 := "Weakest row: " + max_neg_disp + " at " + 
         str.tostring(max_neg_z, "#.##") + "σ — below mean."
else
    narrative_line2 := "No undervaluation candidates on primary benchmark."

if rotation_found
    narrative_line3 := "Active rotation: " + out_leg + " reverting down out of overextension while " + 
         in_leg + " turns up from undervaluation — a dated, conviction-backed out→in pair."
else if tri_over_ct >= 3
    narrative_line3 := "Cross-sectional pattern: " + str.tostring(tri_over_ct) + 
         " names stretched on 2+ benchmarks — convergent extension; no ▼ cross fired yet."
else if tri_under_ct >= 3
    narrative_line3 := "Cross-sectional pattern: " + str.tostring(tri_under_ct) + 
         " names oversold on 2+ benchmarks — convergent undervaluation; no ▲ cross fired yet."
else if tri_over_ct >= 1 and tri_under_ct >= 1
    narrative_line3 := "Stretch on both sides — no conviction-backed cross pair yet."
else
    narrative_line3 := "Balanced — no conviction extremes. Triangulation may still reveal frame-specific readings."

if xlk_z >= extreme_z
    narrative_line4 := r1_name + " at " + str.tostring(xlk_z, "#.##") + 
         "σ — statistically extreme; triangulation conviction shown below."
else if xlk_z >= overextended_z
    narrative_line4 := r1_name + " at " + str.tostring(xlk_z, "#.##") + 
         "σ — in overextension territory."
else if xlk_z <= undervalued_z
    narrative_line4 := r1_name + " at " + str.tostring(xlk_z, "#.##") + 
         "σ — deep in the undervalued zone."
else if not na(xlk_z)
    narrative_line4 := r1_name + " at " + str.tostring(xlk_z, "#.##") + 
         "σ — within normal range on " + benchmark_label + "."

narrative_line5 := "High-conviction signals require triangulation agreement (3+ benchmarks)"

// Mixed-universe override: neutralise the cross-sectional narrative lines.
if universe_mixed
    narrative_line1 := "Mixed universe — rows hold a custom set of instruments."
    narrative_line2 := "Per-row z-scores, conviction, bands and signals stay valid; read each row on its own."
    narrative_line3 := "Cross-sectional reads paused: rotation, dominant/weakest ranking and the stretched/oversold counts assume one comparable basket."
    narrative_line4 := ""

// =====================================================
// 🎯 DISPLAY TABLE
// =====================================================
var table tbl = table.new(position.middle_right, 7, 50, 
     bgcolor=C_BG, border_width=1, border_color=color.new(C_DIM, 80))

if barstate.islast
    int r = 0
    
    // Header
    table.merge_cells(tbl, 0, r, 6, r)
    table.cell(tbl, 0, r, "◆ Mean-Reversion Map ◆", 
         text_color=C_GOLD, bgcolor=C_HEAD, text_size=size.normal, height=hdr_row_h)
    r := r + 1
    
    // Benchmark label + universe mode
    table.merge_cells(tbl, 0, r, 6, r)
    table.cell(tbl, 0, r, "Primary: " + benchmark_label + 
         "   |   Universe: " + universe_mode + 
         "   |   Conviction: USD · SPY · Gold   (Brent = context)", 
         text_color=C_CYAN, bgcolor=C_HEAD, text_size=size.small, height=hdr_row_h)
    r := r + 1
    
    // Narrative
    if show_narrative and table_mode == "Full"
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, "── ANALYTICAL READ ──", 
             text_color=C_GOLD, bgcolor=C_HEAD, text_size=size.small, height=hdr_row_h)
        r := r + 1
        
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, narrative_line1, 
             text_color=C_TXT, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left, height=hdr_row_h)
        r := r + 1
        
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, narrative_line2, 
             text_color=C_TXT, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left, height=hdr_row_h)
        r := r + 1
        
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, narrative_line3, 
             text_color=C_AMBER, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left, height=hdr_row_h)
        r := r + 1
        
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, narrative_line4, 
             text_color=C_CYAN, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left, height=hdr_row_h)
        r := r + 1
        
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, narrative_line5, 
             text_color=C_DIM, bgcolor=C_HEAD, text_size=size.small, text_halign=text.align_left, height=hdr_row_h)
        r := r + 1
    
    // Regime synthesis (Full + Compact)
    if table_mode != "Grid only"
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, regime_synthesis, 
             text_color=synth_col, bgcolor=C_HEAD, text_size=size.normal, height=hdr_row_h)
        r := r + 1
        
        string _count_txt = universe_mixed ? "Per-row read live · rotation + counts paused (mixed universe)" : "Stretched: " + str.tostring(tri_over_ct) + "   |   Oversold: " + str.tostring(tri_under_ct) + "   (on 2+ of USD/SPY/Gold)"
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, _count_txt, 
             text_color=universe_mixed ? C_DIM : C_TXT, bgcolor=C_HEAD, text_size=size.small, height=hdr_row_h)
        r := r + 1
    
    // TRIANGULATION PANEL
    if show_triangulation
        table.merge_cells(tbl, 0, r, 6, r)
        table.cell(tbl, 0, r, "── TRIANGULATION · conviction = USD/SPY/Gold (Brent· = context) ──", 
             text_color=C_GOLD, bgcolor=C_HEAD, text_size=size.small, height=hdr_row_h)
        r := r + 1
        
        // Column headers
        table.cell(tbl, 0, r, "Row", text_color=C_DIM, bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_left, height=tri_row_h)
        table.cell(tbl, 1, r, "USD", text_color=C_DIM, bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_center, height=tri_row_h)
        table.cell(tbl, 2, r, "SPY", text_color=C_DIM, bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_center, height=tri_row_h)
        table.cell(tbl, 3, r, "Gold", text_color=C_DIM, bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_center, height=tri_row_h)
        table.cell(tbl, 4, r, "Brent·", text_color=color.new(C_DIM, 25), bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_center, height=tri_row_h)
        table.cell(tbl, 5, r, "Conviction", text_color=C_DIM, bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_right, height=tri_row_h)
        table.cell(tbl, 6, r, "Signal", text_color=C_DIM, bgcolor=C_HEAD, 
             text_size=size.small, text_halign=text.align_right, height=tri_row_h)
        r := r + 1
        
        // XLK row
        if show_xlk
            table.cell(tbl, 0, r, "01 " + lbl_xlk, text_color=COL_XLK, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xlk_usd, "#.#"), text_color=f_z_color(xlk_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xlk_brent, "#.#"), text_color=f_z_color(xlk_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xlk_spy, "#.#"), text_color=f_z_color(xlk_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xlk_gold, "#.#"), text_color=f_z_color(xlk_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xlk_over, xlk_under), text_color=f_conviction_color(xlk_over, xlk_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xlk_sig, xlk_age), text_color=f_signal_color(xlk_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLE
        if show_xle
            table.cell(tbl, 0, r, "02 " + lbl_xle, text_color=COL_XLE, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xle_usd, "#.#"), text_color=f_z_color(xle_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xle_brent, "#.#"), text_color=f_z_color(xle_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xle_spy, "#.#"), text_color=f_z_color(xle_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xle_gold, "#.#"), text_color=f_z_color(xle_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xle_over, xle_under), text_color=f_conviction_color(xle_over, xle_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xle_sig, xle_age), text_color=f_signal_color(xle_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // GDX
        if show_gdx
            table.cell(tbl, 0, r, "03 " + lbl_gdx, text_color=COL_GDX, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(gdx_usd, "#.#"), text_color=f_z_color(gdx_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(gdx_brent, "#.#"), text_color=f_z_color(gdx_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(gdx_spy, "#.#"), text_color=f_z_color(gdx_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(gdx_gold, "#.#"), text_color=f_z_color(gdx_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(gdx_over, gdx_under), text_color=f_conviction_color(gdx_over, gdx_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(gdx_sig, gdx_age), text_color=f_signal_color(gdx_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XBI
        if show_xbi
            table.cell(tbl, 0, r, "04 " + lbl_xbi, text_color=COL_XBI, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xbi_usd, "#.#"), text_color=f_z_color(xbi_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xbi_brent, "#.#"), text_color=f_z_color(xbi_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xbi_spy, "#.#"), text_color=f_z_color(xbi_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xbi_gold, "#.#"), text_color=f_z_color(xbi_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xbi_over, xbi_under), text_color=f_conviction_color(xbi_over, xbi_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xbi_sig, xbi_age), text_color=f_signal_color(xbi_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLF
        if show_xlf
            table.cell(tbl, 0, r, "05 " + lbl_xlf, text_color=COL_XLF, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xlf_usd, "#.#"), text_color=f_z_color(xlf_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xlf_brent, "#.#"), text_color=f_z_color(xlf_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xlf_spy, "#.#"), text_color=f_z_color(xlf_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xlf_gold, "#.#"), text_color=f_z_color(xlf_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xlf_over, xlf_under), text_color=f_conviction_color(xlf_over, xlf_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xlf_sig, xlf_age), text_color=f_signal_color(xlf_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLV
        if show_xlv
            table.cell(tbl, 0, r, "06 " + lbl_xlv, text_color=COL_XLV, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xlv_usd, "#.#"), text_color=f_z_color(xlv_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xlv_brent, "#.#"), text_color=f_z_color(xlv_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xlv_spy, "#.#"), text_color=f_z_color(xlv_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xlv_gold, "#.#"), text_color=f_z_color(xlv_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xlv_over, xlv_under), text_color=f_conviction_color(xlv_over, xlv_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xlv_sig, xlv_age), text_color=f_signal_color(xlv_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLU
        if show_xlu
            table.cell(tbl, 0, r, "07 " + lbl_xlu, text_color=COL_XLU, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xlu_usd, "#.#"), text_color=f_z_color(xlu_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xlu_brent, "#.#"), text_color=f_z_color(xlu_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xlu_spy, "#.#"), text_color=f_z_color(xlu_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xlu_gold, "#.#"), text_color=f_z_color(xlu_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xlu_over, xlu_under), text_color=f_conviction_color(xlu_over, xlu_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xlu_sig, xlu_age), text_color=f_signal_color(xlu_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLP
        if show_xlp
            table.cell(tbl, 0, r, "08 " + lbl_xlp, text_color=COL_XLP, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xlp_usd, "#.#"), text_color=f_z_color(xlp_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xlp_brent, "#.#"), text_color=f_z_color(xlp_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xlp_spy, "#.#"), text_color=f_z_color(xlp_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xlp_gold, "#.#"), text_color=f_z_color(xlp_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xlp_over, xlp_under), text_color=f_conviction_color(xlp_over, xlp_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xlp_sig, xlp_age), text_color=f_signal_color(xlp_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLY
        if show_xly
            table.cell(tbl, 0, r, "09 " + lbl_xly, text_color=COL_XLY, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xly_usd, "#.#"), text_color=f_z_color(xly_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xly_brent, "#.#"), text_color=f_z_color(xly_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xly_spy, "#.#"), text_color=f_z_color(xly_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xly_gold, "#.#"), text_color=f_z_color(xly_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xly_over, xly_under), text_color=f_conviction_color(xly_over, xly_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xly_sig, xly_age), text_color=f_signal_color(xly_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLI
        if show_xli
            table.cell(tbl, 0, r, "10 " + lbl_xli, text_color=COL_XLI, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xli_usd, "#.#"), text_color=f_z_color(xli_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xli_brent, "#.#"), text_color=f_z_color(xli_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xli_spy, "#.#"), text_color=f_z_color(xli_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xli_gold, "#.#"), text_color=f_z_color(xli_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xli_over, xli_under), text_color=f_conviction_color(xli_over, xli_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xli_sig, xli_age), text_color=f_signal_color(xli_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // XLB
        if show_xlb
            table.cell(tbl, 0, r, "11 " + lbl_xlb, text_color=COL_XLB, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(xlb_usd, "#.#"), text_color=f_z_color(xlb_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(xlb_brent, "#.#"), text_color=f_z_color(xlb_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(xlb_spy, "#.#"), text_color=f_z_color(xlb_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(xlb_gold, "#.#"), text_color=f_z_color(xlb_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(xlb_over, xlb_under), text_color=f_conviction_color(xlb_over, xlb_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(xlb_sig, xlb_age), text_color=f_signal_color(xlb_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
        
        // BTC
        if show_btc
            table.cell(tbl, 0, r, "12 " + lbl_btc, text_color=COL_BTC, text_size=size.small, text_halign=text.align_left, height=tri_row_h)
            table.cell(tbl, 1, r, str.tostring(btc_usd, "#.#"), text_color=f_z_color(btc_usd), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 4, r, str.tostring(btc_brent, "#.#"), text_color=f_z_color(btc_brent), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 2, r, str.tostring(btc_spy, "#.#"), text_color=f_z_color(btc_spy), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 3, r, str.tostring(btc_gold, "#.#"), text_color=f_z_color(btc_gold), text_size=size.small, text_halign=text.align_center, height=tri_row_h)
            table.cell(tbl, 5, r, f_conviction_label(btc_over, btc_under), text_color=f_conviction_color(btc_over, btc_under), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            table.cell(tbl, 6, r, f_signal_label(btc_sig, btc_age), text_color=f_signal_color(btc_sig), text_size=size.small, text_halign=text.align_right, height=tri_row_h)
            r := r + 1
    
    // Footer
    table.merge_cells(tbl, 0, r, 6, r)
    table.cell(tbl, 0, r, "Lookback: " + str.tostring(ratio_lookback) + "d | Smooth: " + str.tostring(ratio_smooth) + "b | Z-smooth: " + str.tostring(z_smooth) + "b | Signal cross: ±" + str.tostring(extreme_z, "#.#") + "σ (" + str.tostring(signal_window) + "b window) | 15 security calls", 
         text_color=C_DIM, bgcolor=C_HEAD, text_size=size.tiny, height=hdr_row_h)
````
