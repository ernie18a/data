# WirezardStrategyTester

- url: https://www.tradingview.com/script/lfiaoBD1-WirezardStrategyTester/
- type: strategy
- pine_id: PUB;1029f4abbfc34912bcf8dc7351c82bcb
- version: 4.0

## Description

WirezardStrategyTester v1.0.0 | Pine Script v6 | Overlay + Strategy

[b]What it does
[/b]Six indicators (RSI, Impulse MACD, VIDYA, Volume, Market Depth Proxy, Sector Strength) are combined into a single score (-100 to +100). Strong BUY at ≥+60, Strong SELL at ≤-60 when RSI, MACD, and Volume agree.

[b]Features[/b]
Dual-mode: overlay indicator or backtestable strategy
Timeframe-adaptive (intraday ×0.7, daily ×1.0, weekly/monthly ×1.5)
Auto sector ETF mapping for ~300 US tickers
Anti-repaint (confirmed bars, lookahead_off)
Low-volume guard (signals off when volume < 10% of 50-bar SMA)
Live dashboard table + built-in alerts

[b]Limitations[/b]
Market Depth is price-action only (no Level 2). Sector detection is US-focused; use manual ETF override for others. Backtest results do not guarantee future performance.

## Source Code

````pine
// ================================================================================================
// WirezardStrategyTester - Multi-Dimensional Technical Analysis System
// ================================================================================================
// Version      : 1.3.0
// Date         : 2026-10-10   (first release 1.0.0 on 2026-03-14)
// Author       : WirezardStrategyTester
// Platform     : TradingView Pine Script v6
// ================================================================================================
// Description  :
//   A professional-grade stock analysis tool that synthesizes RSI, Impulse MACD, VIDYA, Volume,
//   market depth proxies, and sector strength into high-conviction BUY and SELL signals.
//   All indicator parameters auto-adapt to the user-selected TradingView timeframe.
//   Can be used as an overlay indicator OR as a backtestable strategy (toggle via input).
//
// Signal Scoring Weights (daily; intraday and weekly shift weight, see Section 2):
//   RSI           : 20 pts   (overbought/oversold + trend alignment)
//   Impulse MACD  : 25 pts   (Elder Impulse histogram state + crossover)
//   VIDYA         : 20 pts   (slope direction + price vs VIDYA position)
//   Volume        : 15 pts   (volume spike confirmation + OBV direction)
//   Market Depth  : 10 pts   (ATR-relative spread + wick rejection proxy)
//   Sector Strength: 10 pts  (sector ETF relative strength vs SPY; 0 for unmapped tickers)
//   Composite     : sum normalised to -100 (max bearish) .. +100 (max bullish)
//
// Signals (evaluated on closed bars when "Use Confirmed Bars Only" is on, the default):
//   STRONG BUY  : composite >= +60 AND RSI, MACD, VIDYA all bullish AND volume above its MA
//   STRONG SELL : composite <= -60 AND RSI, MACD, VIDYA all bearish AND volume above its MA
//   EXIT_LONG   : long, and a STRONG SELL or composite < -20 at bar close
//   EXIT_SHORT  : short, and a STRONG BUY or composite > +20 at bar close
//   Dashboard label when no signal: Weak Bull (> +30), Weak Bear (< -30), else Neutral.
//
// Webhook (payload v2, Section 5A): every BUY / SELL / EXIT_LONG / EXIT_SHORT sends one
// JSON body with the composite, each component, the gates and bar times. Two alert routes:
//   A. "alert() function calls only" + Message {{alert_message}}            (can also send STATE)
//   B. "Order fills only"            + Message {{strategy.order.alert_message}} (Strategy Mode ON)
// Use one route per alert. Re-create alerts after updating the script.
//
// Changelog:
//   v1.3.0 - Webhook payload v2 (2026-10-10). Both alert routes now send the same JSON:
//            alert() calls (BUY / SELL / EXIT_LONG / EXIT_SHORT from a position tracker that
//            mirrors the strategy, plus an optional once-per-bar-close STATE snapshot, off by
//            default) and order fills (alert_message on every order call). Pick one route.
//            The payload carries the composite, every component, the gates, bar open/close time
//            and the sector mode. The v1 fields (symbol, exchange, signal, score, price, timeframe,
//            timestamp, strength, sector) are still sent, so existing receivers keep working;
//            "score" is 0 and "strength" 3 by default (input "Send fixed v1 score/strength").
//            Fixes: score-based exits (score < -20 / > +20) now wait for bar close (they could
//            fire intrabar with calc_on_every_tick); unmapped tickers no longer borrow the XLK
//            override's sector score (input "Neutral sector for unmapped tickers", default on).
//            Webhook setup: see Section 5A (route A: alert() calls + {{alert_message}};
//            route B: order fills + {{strategy.order.alert_message}}).
//   v1.2.0 - Fixed webhook delivery: dual-path alert system. alert() calls fire the JSON payload
//            directly (resolves {{alert_message}}), and strategy.entry/close carry alert_message
//            for order-fill events. Added process_orders_on_close=true, exit order webhooks,
//            and strength field to JSON payload.
//            Webhook setup: Create Alert → Message: {{alert_message}}
//   v1.1.1 - Added webhook alert support: alert() with JSON payload on BUY/SELL signals.
//            alert_message in strategy.entry() for order-fill webhooks.
//   v1.0.0 - Initial release. Full indicator suite, scoring engine, adaptive timeframe logic,
//            dashboard table, and strategy/indicator dual-mode.
//          - Auto sector-ETF detection via syminfo.ticker lookup against comprehensive SPDR
//            sector ETF mappings. Replaced free-text sector input with auto/manual toggle.
//            Added non-US market warning label. Unknown ticker fell back to the Custom Sector ETF
//            (non-US at 50% weight); v1.3.0 scores unknown tickers' sector as 0 by default.
// ================================================================================================

//@version=6
strategy(
     title               = "WirezardStrategyTester v1.3.0",
     shorttitle           = "WZST",
     overlay              = true,
     pyramiding           = 0,
     default_qty_type     = strategy.percent_of_equity,
     default_qty_value    = 10,
     commission_type      = strategy.commission.percent,
     commission_value     = 0.1,
     slippage             = 2,
     max_bars_back        = 500,
     calc_on_every_tick   = true,
     process_orders_on_close = true
     )

// ================================================================================================
// SECTION 1: INPUTS & SETTINGS
// ================================================================================================

// --- Mode Control ---
var string GRP_MODE = "Script Mode"
i_strategyMode      = input.bool(true,  "Enable Strategy Mode (entries/exits)",
                                 tooltip = "ON = strategy entries/exits fire (backtest + order-fill webhooks, route B). OFF = indicator-only, no orders; webhooks then need route A (alert() calls).",
                                 group   = GRP_MODE)
i_useConfirmedBars  = input.bool(true,  "Use Confirmed Bars Only (anti-repaint)",
                                 tooltip = "Signals only trigger on fully closed bars. Prevents repainting but delays by 1 bar.",
                                 group   = GRP_MODE)

// --- Timeframe Override ---
var string GRP_TF = "Timeframe Settings"
i_tfOverride        = input.bool(false, "Manual Timeframe Override",
                                 tooltip = "Enable to fix indicator lengths regardless of chart timeframe.",
                                 group   = GRP_TF)
i_tfCategory        = input.string("Daily", "Manual Timeframe Category",
                                   options  = ["Intraday", "Daily", "Weekly"],
                                   tooltip  = "Only used when Manual Override is enabled.",
                                   group    = GRP_TF)

// --- RSI Settings ---
var string GRP_RSI = "RSI Settings"
i_rsiLen            = input.int(14,   "RSI Length",          minval=2,  maxval=50,  group=GRP_RSI)
i_rsiOB             = input.int(70,   "Overbought Level",    minval=55, maxval=90,  group=GRP_RSI)
i_rsiOS             = input.int(30,   "Oversold Level",      minval=10, maxval=45,  group=GRP_RSI)
i_rsiSmooth         = input.bool(false, "Smooth RSI (3-bar EMA)",
                                 tooltip = "Apply 3-bar EMA smoothing to RSI. Reduces noise on intraday.",
                                 group   = GRP_RSI)

// --- Impulse MACD Settings ---
var string GRP_MACD = "Impulse MACD Settings"
i_macdFast          = input.int(12,  "MACD Fast EMA",        minval=2,  maxval=50,  group=GRP_MACD)
i_macdSlow          = input.int(26,  "MACD Slow EMA",        minval=5,  maxval=100, group=GRP_MACD)
i_macdSignal        = input.int(9,   "MACD Signal EMA",      minval=2,  maxval=50,  group=GRP_MACD)
i_macdEmaLen        = input.int(13,  "Elder EMA Length",     minval=5,  maxval=50,
                                 tooltip = "EMA used in Elder Impulse system for slope coloring.",
                                 group   = GRP_MACD)

// --- VIDYA Settings ---
var string GRP_VIDYA = "VIDYA Settings"
i_vidyaLen          = input.int(14,  "VIDYA Period",         minval=2,  maxval=50,  group=GRP_VIDYA)
i_vidyaCmoLen       = input.int(9,   "CMO Length (Volatility Index)", minval=2, maxval=30,
                                 tooltip = "Chande Momentum Oscillator length. Controls how fast VIDYA adapts.",
                                 group   = GRP_VIDYA)
i_vidyaSource       = input.source(close, "VIDYA Source",    group=GRP_VIDYA)

// --- Volume Settings ---
var string GRP_VOL = "Volume Settings"
i_volMaLen          = input.int(20,  "Volume MA Length",     minval=5,  maxval=100, group=GRP_VOL)
i_volSpikeMulti     = input.float(1.5,"Volume Spike Multiplier", minval=1.0, maxval=5.0, step=0.1,
                                 tooltip = "Volume must exceed this multiple of Volume MA to confirm signals.",
                                 group   = GRP_VOL)
i_volLowWarn        = input.float(0.1,"Low Volume Warning Threshold",
                                 minval=0.01, maxval=0.5, step=0.01,
                                 tooltip = "If current volume < this fraction of 50-bar average, suppress signals.",
                                 group   = GRP_VOL)

// --- Market Depth Proxy Settings ---
var string GRP_MD = "Market Depth Proxy Settings"
i_atrLen            = input.int(14,  "ATR Length (Depth Proxy)", minval=2, maxval=50, group=GRP_MD)
i_spreadThresh      = input.float(0.5,"Tight Spread Threshold (ATR ratio)",
                                 minval=0.1, maxval=2.0, step=0.1,
                                 tooltip = "High-Low range < this * ATR = tight spread (liquid). Used in depth score.",
                                 group   = GRP_MD)
i_wickThresh        = input.float(0.3,"Wick Rejection Threshold (body ratio)",
                                 minval=0.1, maxval=0.9, step=0.05,
                                 tooltip = "Wick > this fraction of bar range signals price rejection.",
                                 group   = GRP_MD)

// --- Sector Strength Settings ---
var string GRP_SECT = "Sector Strength Settings"
i_autoSector        = input.bool(true, "Auto-detect Sector ETF (US stocks)",
                                 tooltip = "Automatically selects the SPDR sector ETF based on the ticker symbol. Disable to use a custom ETF for non-US or unlisted tickers.",
                                 group   = GRP_SECT)
i_sectorOverride    = input.string("XLK", "Custom Sector ETF (override or non-US)",
                                 tooltip = "Used when auto-detect is OFF, or when the ticker is not found in the US sector map. Examples: XLK=Tech, XLF=Financials, XLE=Energy, XLV=Healthcare, XLY=Consumer Disc, XLI=Industrials, XLB=Materials, XLRE=Real Estate, XLU=Utilities, XLP=Consumer Staples.",
                                 group   = GRP_SECT)
i_spyTicker         = input.symbol("SPY",  "Benchmark ETF Ticker",
                                 tooltip = "Market benchmark for relative strength calculation. Default SPY.",
                                 group   = GRP_SECT)
i_sectorLookback    = input.int(20,   "Sector RS Lookback",    minval=5, maxval=100,
                                 tooltip = "Bars over which sector ETF performance is compared vs benchmark.",
                                 group   = GRP_SECT)
i_sectorWeight      = input.float(1.0, "Sector Score Multiplier", minval=0.0, maxval=2.0, step=0.1,
                                 tooltip = "Scale sector contribution. Set 0 to disable sector scoring.",
                                 group   = GRP_SECT)
i_unmappedNeutral   = input.bool(true, "Neutral sector for unmapped tickers",
                                 tooltip = "ON = a ticker missing from the sector map scores 0 for sector (its real sector is unknown). OFF = score it against the Custom Sector ETF (v1.2 behaviour, e.g. a healthcare name scored on XLK).",
                                 group   = GRP_SECT)

// --- Signal Thresholds ---
var string GRP_SIG = "Signal Thresholds"
i_buyThresh         = input.int(60,  "BUY Score Threshold",   minval=40, maxval=95,  group=GRP_SIG)
i_sellThresh        = input.int(-60, "SELL Score Threshold",  minval=-95, maxval=-40, group=GRP_SIG)
i_requireVolConf    = input.bool(true, "Require Volume Confirmation",
                                 tooltip = "If enabled, signals require volume > Volume MA to be valid.",
                                 group   = GRP_SIG)
i_requireCoreAlign  = input.bool(true, "Require Core Indicator Alignment (RSI+MACD+VIDYA)",
                                 tooltip = "BUY requires RSI, MACD, and VIDYA all bullish. SELL requires all bearish.",
                                 group   = GRP_SIG)

// --- Alert / Webhook Settings ---
var string GRP_ALERT = "Alert & Webhook"
i_enableAlerts      = input.bool(true,  "Enable Webhook Alerts (JSON payload)",
                                 tooltip = "Builds the v2 JSON for BUY / SELL / EXIT_LONG / EXIT_SHORT. Route A: alert condition 'alert() function calls only', Message {{alert_message}}. Route B: 'Order fills only', Message {{strategy.order.alert_message}}. Pick one.",
                                 group   = GRP_ALERT)
i_alertState        = input.bool(false, "Send STATE snapshot every bar close",
                                 tooltip = "One STATE payload per closed bar, whether or not a signal fired (route A only). Useful for measuring the composite on every bar, not just on signals. Its 'signal' field is 'STATE', so leave OFF unless your receiver accepts that value.",
                                 group   = GRP_ALERT)
i_v1FixedScore      = input.bool(true, "Send fixed v1 score/strength (score 0, strength 3)",
                                 tooltip = "ON = the v1 'score' field is always 0 and 'strength' always 3, for receivers that act on 'score' and should not change when you upgrade. The live composite is always in 'composite'. OFF = 'score' carries the composite and 'strength' its magnitude 0-10.",
                                 group   = GRP_ALERT)

// --- Visual Settings ---
var string GRP_VIS = "Visual Settings"
i_showTable         = input.bool(true,  "Show Dashboard Table",           group=GRP_VIS)
i_showLabels        = input.bool(true,  "Show BUY/SELL Labels",           group=GRP_VIS)
i_showBgColor       = input.bool(true,  "Highlight Signal Bars (Background)", group=GRP_VIS)
i_showVidya         = input.bool(true,  "Show VIDYA Line",                group=GRP_VIS)
i_tablePos          = input.string("Top Right", "Dashboard Position",
                                   options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"],
                                   group   = GRP_VIS)
i_labelOffset       = input.int(5, "Label Bar Offset", minval=0, maxval=20,
                                 tooltip = "Distance of BUY/SELL label from the bar high/low.",
                                 group   = GRP_VIS)

// ================================================================================================
// SECTION 1B: AUTO SECTOR ETF DETECTION
// ================================================================================================
// Maps syminfo.ticker to the appropriate SPDR Select Sector ETF using pipe-delimited lookup
// strings per sector. str.contains() is used for O(1)-equivalent lookup within each sector group.
//
// Lookup strings are formatted as "|TICKER|" to prevent partial-match false positives
// (e.g., "|MA|" matching "AMAT"). Each ticker is wrapped with pipes on both sides.
//
// Fallback priority:
//   1. Auto-detect OFF  => use i_sectorOverride directly
//   2. Auto-detect ON, ticker found in map => use mapped ETF
//   3. Auto-detect ON, ticker not found, exchange is US => "fallback-us"
//   4. Auto-detect ON, ticker not found, exchange is non-US => "fallback-nonus"
//   For 3 and 4 the sector score is 0 by default ("Neutral sector for unmapped tickers"); turn
//   that off to score against i_sectorOverride instead (non-US at 50% weight).
//
// NOTE: Sector ETF mappings cover the most common US large/mid-cap tickers. Less common or
// newly listed tickers (e.g. PLTR, DDOG, ILMN, ALAB) are unmapped and score sector 0. Add them
// to the strings below to give them a sector score.

// ================================================================================================
// SECTION 1C: SECTOR ETF RESOLUTION FUNCTION
// ================================================================================================
// f_getSectorETF() returns a tuple:
//   [etfSymbol (string), detectionMode (string), isKnownTicker (bool), isNonUS (bool)]
//
// detectionMode values: "auto" | "manual" | "fallback-us" | "fallback-nonus"
//
// All sector list strings are declared as local variables inside the function body.
// This avoids Pine Script global-scope line-length limits that cause
// "end of line without line continuation" syntax errors on long string concatenations.

f_getSectorETF() =>
    // Perform lookup only when auto-detect is enabled
    if not i_autoSector
        // Manual override: user has full control
        [i_sectorOverride, "manual", true, false]
    else
        // Helper: wrap ticker in pipes for unambiguous substring matching
        // (prevents "|MA|" from matching inside "|AMAT|")
        _t = "|" + syminfo.ticker + "|"

        // --- XLK: Technology ---
        _xlkList = "|AAPL|MSFT|NVDA|GOOGL|GOOG|META|AVGO|ORCL|AMD|QCOM|TXN|" + "|INTC|CSCO|IBM|HPQ|HPE|AMAT|LRCX|KLAC|MU|MRVL|ADI|NXPI|" + "|SWKS|QRVO|CRM|NOW|ADBE|INTU|ANSS|CDNS|SNPS|CTSH|ACN|EPAM|" + "|IT|LDOS|SAIC|DXC|WDC|STX|NTAP|PSTG|KEYS|JNPR|ZBRA|FFIV|" + "|CDW|JKHY|GPN|FIS|FISV|PYPL|GDDY|AKAM|VRT|SMCI|GLW|TEL|" + "|APH|FSLR|ENPH|STM|ON|MPWR|WOLF|ALGN|V|MA|"

        // --- XLF: Financials ---
        _xlfList = "|JPM|BAC|WFC|GS|MS|C|BLK|SCHW|AXP|COF|USB|TFC|PNC|BK|" + "|STT|MTB|RF|CFG|HBAN|KEY|FITB|NTRS|WAL|ZION|FHN|CMA|WTFC|" + "|BOKF|EWBC|WBS|UMBF|TCBI|FFIN|IBCP|UMPQ|CVBF|CATY|MCO|" + "|SPGI|ICE|CME|NDAQ|CBOE|MSCI|VRSK|FDS|WTW|AON|MMC|AJG|" + "|BRO|GL|MET|PRU|AIG|ALL|TRV|PGR|CB|HIG|AFG|CINF|WRB|" + "|RNR|RE|MKL|"

        // --- XLV: Health Care ---
        _xlvList = "|UNH|JNJ|LLY|ABBV|MRK|TMO|ABT|DHR|PFE|BMY|AMGN|GILD|" + "|ISRG|MDT|ELV|HCA|SYK|BDX|ZBH|BSX|EW|HOLX|BAX|RMD|DXCM|" + "|IDXX|PODD|INSP|IRTC|NVCR|NVAX|MRNA|BNTX|REGN|VRTX|BIIB|" + "|ALNY|SRPT|RARE|IONS|FOLD|ACAD|BEAM|EDIT|CRSP|NTLA|KYMR|" + "|RCKT|BLUE|SGMO|ARWR|DRNA|AKRO|IMVT|ITCI|MTD|A|WAT|IQV|" + "|ICLR|CRL|MEDP|PEN|XRAY|HSIC|PDCO|NVST|ZTS|HUM|CI|CNC|" + "|CVS|MOH|WCG|ABC|MCK|CAH|DGX|LH|"

        // --- XLE: Energy ---
        _xleList = "|XOM|CVX|COP|EOG|SLB|PXD|MPC|PSX|VLO|OXY|HES|DVN|HAL|" + "|BKR|FANG|APA|MRO|CRC|SM|RRC|EQT|AR|CTRA|MTDR|ESTE|CPE|" + "|NOG|VTLE|TALO|SBOW|OVV|CLR|WLL|PBF|CLMT|PARR|CAPL|DINO|" + "|TPL|BSM|SWN|KOS|BTE|CNQ|SU|IMO|CVE|VET|ERF|"

        // --- XLI: Industrials ---
        _xliList = "|CAT|DE|HON|UPS|RTX|LMT|BA|GE|MMM|EMR|ETN|ITW|PH|ROK|" + "|FTV|FAST|GWW|AIT|NDSN|MAS|WMS|XYL|ROP|CARR|OTIS|AME|" + "|GNRC|WAB|TT|JCI|CSX|UNP|NSC|CP|CN|GXO|XPO|SAIA|ODFL|" + "|LSTR|JBHT|WERN|KNX|CHRW|EXPD|HXL|TDG|HEI|HEICO|DRS|BAH|" + "|CACI|MANT|ACCO|AVY|BMS|SON|IP|PKG|WRK|SEE|SLGN|BERY|" + "|BALL|ATI|HWM|AA|CRS|KALU|NUE|STLD|CLF|X|RS|CMC|" + "|MLM|VMC|SUM|EXP|"

        // --- XLY: Consumer Discretionary ---
        _xlyList = "|AMZN|TSLA|HD|MCD|NKE|SBUX|TJX|LOW|BKNG|CMG|GM|F|ORLY|" + "|AZO|ROST|DLTR|DG|KMX|AN|PAG|LAD|ABG|GPI|LKQ|CVNA|VRM|" + "|GRMN|EBAY|ETSY|CHWY|WOOF|RH|WSM|BBY|ULTA|SIG|KSS|M|JWN|" + "|GPS|PVH|HBI|RL|LEVI|UAA|UA|CROX|SKX|DECK|BOOT|MTN|EXPE|" + "|TRIP|ABNB|LYFT|UBER|DASH|DKNG|MGM|LVS|WYNN|CZR|PENN|" + "|NCLH|CCL|RCL|MAR|HLT|H|IHG|CHH|DRI|YUM|QSR|JACK|WEN|" + "|SHAK|WING|DNUT|BROS|RUTH|EAT|CHUY|CAKE|TXRH|BJRI|DINE|" + "|KRUS|LOCO|"

        // --- XLP: Consumer Staples ---
        _xlpList = "|WMT|PG|KO|PEP|COST|PM|MO|CL|MDLZ|KHC|GIS|K|CAG|CPB|" + "|SJM|HSY|MKC|CHD|CLX|KMB|EL|COTY|SPB|PRGO|USFD|SYY|PFGC|" + "|CHEF|INGR|CALM|PPC|TSN|HRL|POST|LANC|THS|FLO|JJSF|SMPL|" + "|UTZ|NOMD|ANDE|MGPI|WDFC|CELH|VITL|MNST|KDP|FIZZ|COKE|" + "|CCEP|SAM|BUD|STZ|"

        // --- XLU: Utilities ---
        _xluList = "|NEE|DUK|SO|D|AEP|EXC|SRE|PCG|ED|XEL|WEC|ES|ETR|FE|" + "|CMS|DTE|AEE|LNT|EVRG|NI|PNW|OGE|IDA|OTTR|HE|MGEE|AVA|" + "|NWE|PNM|BKH|SWX|NJR|SR|ATO|UGI|OKE|KMI|WMB|EPD|ET|" + "|MMP|PAA|TRGP|PAGP|DCP|MPLX|NGL|GEL|ENLC|AM|LNG|CQP|NFE|"

        // --- XLRE: Real Estate ---
        _xlreList = "|AMT|PLD|CCI|EQIX|PSA|O|WELL|AVB|EQR|VTR|SPG|EXR|IRM|" + "|ARE|BXP|VICI|WY|FRT|KIM|REG|ROIC|SITC|AKR|PECO|BDN|CUZ|" + "|HIW|PGRE|SLG|OFC|ELS|SUI|UDR|CPT|MAA|NHI|NNN|LXP|STAG|" + "|WPC|STOR|EPRT|GTY|FCPT|ADC|ESRT|ARCC|FSK|ORCC|OBDC|HTGC|" + "|TCPC|PFLT|NMFC|"

        // --- XLB: Materials ---
        _xlbList = "|LIN|APD|ECL|SHW|DD|NEM|FCX|PPG|VMC|MLM|EMN|CE|MOS|CF|" + "|FMC|IFF|ALB|LYB|WLK|OLN|RPM|SEE|SON|PKG|IP|WRK|ATI|CMC|" + "|X|STLD|CLF|CRS|KALU|HAYN|MTRN|ARNC|AA|ASH|HXL|CBT|TROX|" + "|VNTR|IOSP|SCCO|MP|"

        // Check each sector's list in priority order
        _isXLK  = str.contains(_xlkList,  _t)
        _isXLF  = str.contains(_xlfList,  _t)
        _isXLV  = str.contains(_xlvList,  _t)
        _isXLE  = str.contains(_xleList,  _t)
        _isXLI  = str.contains(_xliList,  _t)
        _isXLY  = str.contains(_xlyList,  _t)
        _isXLP  = str.contains(_xlpList,  _t)
        _isXLU  = str.contains(_xluList,  _t)
        _isXLRE = str.contains(_xlreList, _t)
        _isXLB  = str.contains(_xlbList,  _t)

        _found = _isXLK or _isXLF or _isXLV or _isXLE or _isXLI or _isXLY or _isXLP or _isXLU or _isXLRE or _isXLB

        _mappedETF = _isXLK ? "XLK" : _isXLF ? "XLF" : _isXLV ? "XLV" : _isXLE ? "XLE" : _isXLI ? "XLI" : _isXLY ? "XLY" : _isXLP ? "XLP" : _isXLU ? "XLU" : _isXLRE ? "XLRE" : _isXLB ? "XLB" : ""

        if _found
            // Ticker found in the US sector map — use the mapped ETF
            [_mappedETF, "auto", true, false]
        else
            // Ticker not found — check if exchange appears to be a US market
            // syminfo.prefix holds the exchange prefix (e.g., NASDAQ, NYSE, AMEX, CBOE)
            _isUSExchange = syminfo.prefix == "NASDAQ" or syminfo.prefix == "NYSE" or syminfo.prefix == "AMEX" or syminfo.prefix == "NYSE ARCA" or syminfo.prefix == "CBOE" or syminfo.prefix == "BATS" or syminfo.prefix == "NYSE MKT"
            if _isUSExchange
                // US exchange but ticker not in map — use manual override, flag as fallback
                [i_sectorOverride, "fallback-us", false, false]
            else
                // Non-US exchange — use manual override, apply 50% weight reduction
                [i_sectorOverride, "fallback-nonus", false, true]

// Resolve sector ETF (called once; results used throughout the script)
[resolvedSectorETF, sectorDetectMode, sectorTickerKnown, isNonUS] = f_getSectorETF()

// Effective sector weight: halved for non-US tickers to reduce unreliable cross-market sector scoring
effectiveSectorWeight = isNonUS ? i_sectorWeight * 0.5 : i_sectorWeight

// ================================================================================================
// SECTION 2: TIMEFRAME DETECTION & ADAPTIVE PARAMETER SCALING
// ================================================================================================

// Detect timeframe category
_isTfIntraday = timeframe.isintraday
_isTfDaily    = timeframe.isdaily or timeframe.isweekly == false and timeframe.isintraday == false
_isTfWeekly   = timeframe.isweekly or timeframe.ismonthly

// Map manual override category
_manualIntraday = i_tfCategory == "Intraday"
_manualDaily    = i_tfCategory == "Daily"
_manualWeekly   = i_tfCategory == "Weekly"

// Resolved category (override or auto-detect)
tfIsIntraday = i_tfOverride ? _manualIntraday : _isTfIntraday
tfIsWeekly   = i_tfOverride ? _manualWeekly   : _isTfWeekly
tfIsDaily    = i_tfOverride ? _manualDaily    : (not tfIsIntraday and not tfIsWeekly)

// Adaptive RSI length
// Intraday: faster (shorter) | Weekly: slower (longer)
adaptRsiLen = i_tfOverride ? i_rsiLen : tfIsIntraday ? math.max(7, math.round(i_rsiLen * 0.7)) : tfIsWeekly ? math.min(21, math.round(i_rsiLen * 1.5)) : i_rsiLen

// Adaptive MACD lengths
adaptMacdFast   = i_tfOverride ? i_macdFast : tfIsIntraday ? math.max(5, math.round(i_macdFast * 0.7)) : tfIsWeekly ? math.min(21, math.round(i_macdFast * 1.5)) : i_macdFast

adaptMacdSlow   = i_tfOverride ? i_macdSlow : tfIsIntraday ? math.max(13, math.round(i_macdSlow * 0.7)) : tfIsWeekly ? math.min(52, math.round(i_macdSlow * 1.5)) : i_macdSlow

adaptMacdSignal = i_tfOverride ? i_macdSignal : tfIsIntraday ? math.max(5, math.round(i_macdSignal * 0.7)) : tfIsWeekly ? math.min(21, math.round(i_macdSignal * 1.5)) : i_macdSignal

adaptEmaLen     = i_tfOverride ? i_macdEmaLen : tfIsIntraday ? math.max(5, math.round(i_macdEmaLen * 0.7)) : tfIsWeekly ? math.min(26, math.round(i_macdEmaLen * 1.5)) : i_macdEmaLen

// Adaptive VIDYA length
adaptVidyaLen   = i_tfOverride ? i_vidyaLen : tfIsIntraday ? math.max(7, math.round(i_vidyaLen * 0.7)) : tfIsWeekly ? math.min(21, math.round(i_vidyaLen * 1.5)) : i_vidyaLen

adaptVidyaCmoLen = i_tfOverride ? i_vidyaCmoLen : tfIsIntraday ? math.max(5, math.round(i_vidyaCmoLen * 0.7)) : tfIsWeekly ? math.min(21, math.round(i_vidyaCmoLen * 1.5)) : i_vidyaCmoLen

// Adaptive Volume MA length
adaptVolMaLen   = i_tfOverride ? i_volMaLen : tfIsIntraday ? math.max(10, math.round(i_volMaLen * 0.75)) : tfIsWeekly ? math.min(50, math.round(i_volMaLen * 1.5)) : i_volMaLen

// Adaptive ATR length
adaptAtrLen     = i_tfOverride ? i_atrLen : tfIsIntraday ? math.max(7, math.round(i_atrLen * 0.7)) : tfIsWeekly ? math.min(26, math.round(i_atrLen * 1.5)) : i_atrLen

// Adaptive score weights per timeframe
// Intraday: heavier volume weight | Weekly: heavier sector + trend weight
wRsi    = tfIsIntraday ? 18 : tfIsWeekly ? 18 : 20
wMacd   = tfIsIntraday ? 22 : tfIsWeekly ? 22 : 25
wVidya  = tfIsIntraday ? 15 : tfIsWeekly ? 22 : 20
wVol    = tfIsIntraday ? 20 : tfIsWeekly ? 10 : 15
wDepth  = tfIsIntraday ? 12 : tfIsWeekly ? 8  : 10
wSector = tfIsIntraday ? 8  : tfIsWeekly ? 15 : 10

// Total weight reference (used to normalize if needed)
wTotal  = wRsi + wMacd + wVidya + wVol + wDepth + wSector  // daily 100, intraday 95, weekly 95

// ================================================================================================
// SECTION 3: INDICATOR CALCULATIONS
// ================================================================================================

// === 3A: RSI ===
// Standard Wilder RSI with optional 3-bar EMA smoothing
rsiRaw = ta.rsi(close, adaptRsiLen)
rsiVal = i_rsiSmooth ? ta.ema(rsiRaw, 3) : rsiRaw

// RSI directional states
rsiBullish  = rsiVal > 50 and rsiVal < i_rsiOB   // above midline, not overbought
rsiBearish  = rsiVal < 50 and rsiVal > i_rsiOS   // below midline, not oversold
rsiOS       = rsiVal <= i_rsiOS                   // oversold — potential BUY setup
rsiOB       = rsiVal >= i_rsiOB                   // overbought — potential SELL setup
rsiRising   = rsiVal > rsiVal[1]
rsiFalling  = rsiVal < rsiVal[1]

// RSI divergence detection (simple 5-bar lookback)
// Bullish divergence: price makes lower low but RSI makes higher low
priceLL     = low < ta.lowest(low, 5)[1]
rsiHL       = rsiVal > ta.lowest(rsiVal, 5)[1]
rsiBullDiv  = priceLL and rsiHL and rsiVal < 50

// Bearish divergence: price makes higher high but RSI makes lower high
priceHH     = high > ta.highest(high, 5)[1]
rsiLH       = rsiVal < ta.highest(rsiVal, 5)[1]
rsiBearDiv  = priceHH and rsiLH and rsiVal > 50

// RSI score: -wRsi to +wRsi (±20 daily)
// +20: oversold + rising + bullish divergence | -20: overbought + falling + bearish divergence
rsiScore = 0.0
if rsiBullish or rsiOS
    rsiScore := rsiOS ? (rsiRising ? float(wRsi) : float(wRsi) * 0.7) : (rsiRising ? float(wRsi) * 0.8 : float(wRsi) * 0.5)
    if rsiBullDiv
        rsiScore := math.min(float(wRsi), rsiScore * 1.2)
else if rsiBearish or rsiOB
    rsiScore := rsiOB ? (rsiFalling ? -float(wRsi) : -float(wRsi) * 0.7) : (rsiFalling ? -float(wRsi) * 0.8 : -float(wRsi) * 0.5)
    if rsiBearDiv
        rsiScore := math.max(-float(wRsi), rsiScore * 1.2)

// Boolean alignment flags for "core alignment" requirement
rsiBullFlag = rsiScore > 0
rsiBearFlag = rsiScore < 0

// === 3B: IMPULSE MACD (Elder's Impulse System) ===
// Elder Impulse: bar is colored based on EMA direction AND MACD histogram direction
// Green = both rising (buy impulse), Red = both falling (sell impulse), Blue = mixed

macdFastEma = ta.ema(close, adaptMacdFast)
macdSlowEma = ta.ema(close, adaptMacdSlow)
macdLine    = macdFastEma - macdSlowEma
signalLine  = ta.ema(macdLine, adaptMacdSignal)
macdHist    = macdLine - signalLine

// Elder EMA slope direction
elderEma    = ta.ema(close, adaptEmaLen)
elderUp     = elderEma > elderEma[1]
elderDown   = elderEma < elderEma[1]

// Histogram direction
histRising  = macdHist > macdHist[1]
histFalling = macdHist < macdHist[1]
histPositive = macdHist > 0
histNegative = macdHist < 0

// Impulse state
impulseGreen = elderUp   and histRising    // Strong bull impulse
impulseRed   = elderDown and histFalling   // Strong bear impulse
impulseBlue  = not impulseGreen and not impulseRed  // Neutral/mixed

// MACD crossover signals
macdCrossUp   = ta.crossover(macdLine,  signalLine)
macdCrossDown = ta.crossunder(macdLine, signalLine)

// MACD histogram momentum shift (weakening momentum warning)
histMomShiftBull = histNegative and histRising and macdHist > macdHist[2]  // histogram turning from deep negative
histMomShiftBear = histPositive and histFalling and macdHist < macdHist[2]

// MACD score: -wMacd to +wMacd (±25 daily)
macdScore = 0.0
if impulseGreen
    macdScore := float(wMacd)
    if macdCrossUp
        macdScore := math.min(float(wMacd), macdScore * 1.1)
else if impulseRed
    macdScore := -float(wMacd)
    if macdCrossDown
        macdScore := math.max(-float(wMacd), macdScore * 1.1)
else
    // Partial credit for partial alignment
    if histPositive and elderUp
        macdScore := float(wMacd) * 0.5
    else if histNegative and elderDown
        macdScore := -float(wMacd) * 0.5
    else if histMomShiftBull
        macdScore := float(wMacd) * 0.3
    else if histMomShiftBear
        macdScore := -float(wMacd) * 0.3

macdBullFlag = macdScore > 0
macdBearFlag = macdScore < 0

// === 3C: VIDYA (Variable Index Dynamic Average) ===
// VIDYA uses CMO as a volatility index. High CMO = fast smoothing, Low CMO = slow smoothing
// Formula: VIDYA[i] = close[i] * k * |CMO/100| + VIDYA[i-1] * (1 - k * |CMO/100|)
// where k = 2 / (vidyaLen + 1)  (equivalent to EMA alpha)

cmoUp   = math.max(i_vidyaSource - i_vidyaSource[1], 0)
cmoDn   = math.max(i_vidyaSource[1] - i_vidyaSource, 0)
cmoSumUp = math.sum(cmoUp, adaptVidyaCmoLen)
cmoSumDn = math.sum(cmoDn, adaptVidyaCmoLen)
cmoVal  = (cmoSumUp - cmoSumDn) / (cmoSumUp + cmoSumDn + 1e-10) * 100  // -100 to +100, avoid div/0

vidyaK  = 2.0 / (adaptVidyaLen + 1)
vidyaAlpha = vidyaK * math.abs(cmoVal / 100)

// VIDYA calculation using var for persistence across bars
var float vidya = na
vidya := na(vidya[1]) ? i_vidyaSource : (i_vidyaSource * vidyaAlpha + vidya[1] * (1.0 - vidyaAlpha))

// VIDYA directional signals
vidyaSlope  = vidya - vidya[1]
vidyaUp     = vidyaSlope > 0
vidyaDown   = vidyaSlope < 0
priceAbove  = close > vidya
priceBelow  = close < vidya

// VIDYA acceleration (slope accelerating = strengthening trend)
vidyaAccelUp   = vidyaUp and vidyaSlope > vidyaSlope[1]
vidyaAccelDown = vidyaDown and vidyaSlope < vidyaSlope[1]

// VIDYA score: -wVidya to +wVidya (±20 daily)
vidyaScore = 0.0
if vidyaUp and priceAbove
    vidyaScore := float(wVidya)
    if not vidyaAccelUp
        vidyaScore := float(wVidya) * 0.7  // trend exists but losing momentum
else if vidyaDown and priceBelow
    vidyaScore := -float(wVidya)
    if not vidyaAccelDown
        vidyaScore := -float(wVidya) * 0.7
else if vidyaUp and priceBelow
    vidyaScore := float(wVidya) * 0.3  // VIDYA bullish but price below — partial
else if vidyaDown and priceAbove
    vidyaScore := -float(wVidya) * 0.3

vidyaBullFlag = vidyaScore > 0
vidyaBearFlag = vidyaScore < 0

// === 3D: VOLUME ANALYSIS ===
// Volume MA, spike detection, OBV proxy, and low-volume warning

volSma      = ta.sma(volume, adaptVolMaLen)
vol50Sma    = ta.sma(volume, 50)  // 50-bar average for low-volume warning
volSpike    = volume > volSma * i_volSpikeMulti
volAboveMa  = volume > volSma
lowVolWarning = volume < vol50Sma * i_volLowWarn  // abnormally low volume

// OBV (On-Balance Volume) proxy
var float obvVal = 0.0
obvVal := close > close[1] ? obvVal + volume : close < close[1] ? obvVal - volume : obvVal

obvSma      = ta.sma(obvVal, adaptVolMaLen)
obvBullish  = obvVal > obvSma and obvVal > obvVal[1]   // OBV above its MA and rising
obvBearish  = obvVal < obvSma and obvVal < obvVal[1]   // OBV below its MA and falling

// Volume delta proxy (buying vs selling pressure on current bar)
// Proxy: if close is in upper half of bar range => buying pressure, lower half => selling
barRange    = high - low
midBar      = low + barRange * 0.5
volBuyPressure  = barRange > 0 ? (close - low)  / barRange : 0.5  // 0 to 1, higher = more buying
volSellPressure = barRange > 0 ? (high - close) / barRange : 0.5  // 0 to 1, higher = more selling

// Volume score: -wVol to +wVol (±15 daily)
volScore = 0.0
if not lowVolWarning
    if volAboveMa and obvBullish and volBuyPressure > 0.5
        volScore := volSpike ? float(wVol) : float(wVol) * 0.7
    else if volAboveMa and obvBullish
        volScore := float(wVol) * 0.5
    else if volAboveMa and obvBearish and volSellPressure > 0.5
        volScore := volSpike ? -float(wVol) : -float(wVol) * 0.7
    else if volAboveMa and obvBearish
        volScore := -float(wVol) * 0.5
    else
        volScore := 0.0  // volume below MA — no contribution

volBullFlag = volScore > 0
volBearFlag = volScore < 0

// Volume confirmation flag (used in core alignment check)
volConfirmed = volAboveMa and not lowVolWarning

// === 3E: MARKET DEPTH PROXY ===
// TradingView has no real Level 2 / order book data. We use price action proxies:
// 1. High-Low range relative to ATR (tight spread = liquid market, supports directional move)
// 2. Upper/lower wick as rejection proxy (large wick = order absorption / price rejection)
// 3. Bar body direction vs. wick asymmetry (institutional absorption pattern)
// NOTE: These are proxies only. They approximate depth-like conditions using price action.

atrVal      = ta.atr(adaptAtrLen)
barSpread   = high - low
spreadRatio = atrVal > 0 ? barSpread / atrVal : 1.0

// Tight spread = liquid conditions (supports a clean directional move)
tightSpread = spreadRatio < i_spreadThresh

// Wick analysis
upperWick   = high  - math.max(open, close)
lowerWick   = math.min(open, close) - low
bodySize    = math.abs(close - open)

// Wick rejection: large wick relative to bar range signals price was rejected at that level
upperWickRej = barRange > 0 ? upperWick / barRange > i_wickThresh : false  // upper wick rejection = bearish
lowerWickRej = barRange > 0 ? lowerWick / barRange > i_wickThresh : false  // lower wick rejection = bullish

// Bar body dominance (bullish bar: close > open with small wicks)
bullBody = close > open and bodySize > barRange * 0.5  // strong bull candle
bearBody = close < open and bodySize > barRange * 0.5  // strong bear candle

// Depth proxy score: -wDepth to +wDepth (±10 daily)
depthScore = 0.0
if bullBody
    depthScore := tightSpread ? float(wDepth) : float(wDepth) * 0.6
    if lowerWickRej
        depthScore := math.min(float(wDepth), depthScore * 1.2)  // lower wick = demand absorption
else if bearBody
    depthScore := tightSpread ? -float(wDepth) : -float(wDepth) * 0.6
    if upperWickRej
        depthScore := math.max(-float(wDepth), depthScore * 1.2) // upper wick = supply absorption
else
    // Doji / indecision bar
    if lowerWickRej and not upperWickRej
        depthScore := float(wDepth) * 0.3   // demand showing at lows
    else if upperWickRej and not lowerWickRej
        depthScore := -float(wDepth) * 0.3  // supply showing at highs

// === 3F: SECTOR STRENGTH ===
// Pull the resolved sector ETF and SPY performance, compare relative strength.
// Relative Strength = (Sector% Change) - (SPY% Change) over lookback period.
// The sector ETF is resolved automatically via f_getSectorETF() above (Section 1C).

[sectorClose, sectorVol] = request.security(resolvedSectorETF, timeframe.period,
                                             [close, volume], lookahead=barmerge.lookahead_off)
spyClose = request.security(i_spyTicker, timeframe.period, close,
                              lookahead=barmerge.lookahead_off)

// Validate that sector data loaded (non-na)
sectorDataValid = not na(sectorClose) and not na(spyClose) and not na(sectorClose[i_sectorLookback]) and not na(spyClose[i_sectorLookback])

// Percentage change over lookback for sector vs SPY
sectorPctChg = sectorDataValid ? (sectorClose - sectorClose[i_sectorLookback]) / sectorClose[i_sectorLookback] * 100 : 0.0
spyPctChg    = sectorDataValid ? (spyClose - spyClose[i_sectorLookback]) / spyClose[i_sectorLookback] * 100 : 0.0

// Relative strength: positive = sector outperforming, negative = underperforming
sectorRS        = sectorPctChg - spyPctChg

// Smooth RS with a short EMA to reduce noise
sectorRsSmooth  = ta.ema(sectorRS, 3)

// Sector strength threshold: >1% outperformance = strong sector, <-1% = weak
sectorStrong    = sectorRsSmooth > 1.0
sectorWeak      = sectorRsSmooth < -1.0
sectorNeutral   = not sectorStrong and not sectorWeak

// Sector score: capped at wSector pts (scaled by effective weight multiplier)
// effectiveSectorWeight is 50% of i_sectorWeight for non-US tickers
sectorRawScore  = sectorDataValid ? (sectorStrong ? float(wSector) : sectorWeak ? -float(wSector) : sectorRsSmooth * float(wSector) / 2.0) : 0.0

// Unmapped tickers ("fallback-*") would otherwise be scored on the Custom Sector ETF (XLK by
// default) — a healthcare or industrial name scored on tech strength. Neutral unless opted out.
sectorUnmapped  = sectorDetectMode == "fallback-us" or sectorDetectMode == "fallback-nonus"
sectorScore     = sectorUnmapped and i_unmappedNeutral ? 0.0 : math.max(-float(wSector), math.min(float(wSector), sectorRawScore * effectiveSectorWeight))

// ================================================================================================
// SECTION 4: COMPOSITE SIGNAL SCORING ENGINE
// ================================================================================================

// Sum all component scores
compositeScore = rsiScore + macdScore + vidyaScore + volScore + depthScore + sectorScore

// Normalize to -100 / +100 scale
// wTotal approximates 100 but may vary with timeframe weights; normalize accordingly
normalizedScore = math.max(-100.0, math.min(100.0, compositeScore / float(wTotal) * 100.0))

// === Core Alignment Check ===
// For strong signals, RSI + MACD + VIDYA must all agree
coreAlignBull = rsiBullFlag and macdBullFlag and vidyaBullFlag
coreAlignBear = rsiBearFlag and macdBearFlag and vidyaBearFlag

// Volume confirmation gate
volGate = not i_requireVolConf or volConfirmed

// Core alignment gate
coreGateBull = not i_requireCoreAlign or coreAlignBull
coreGateBear = not i_requireCoreAlign or coreAlignBear

// === Signal Generation ===
// Use barstate.isconfirmed to prevent repainting when the option is enabled
barConfirmed = i_useConfirmedBars ? barstate.isconfirmed : true

rawBuySignal  = normalizedScore >= float(i_buyThresh)  and volGate and coreGateBull and not lowVolWarning
rawSellSignal = normalizedScore <= float(i_sellThresh) and volGate and coreGateBear and not lowVolWarning

buySignal  = rawBuySignal  and barConfirmed
sellSignal = rawSellSignal and barConfirmed

// Signal strength bucket (1–5 scale based on normalized score magnitude)
signalMagnitude = math.abs(normalizedScore)
sigStrength = signalMagnitude >= 90 ? 5 : signalMagnitude >= 80 ? 4 : signalMagnitude >= 70 ? 3 : signalMagnitude >= 60 ? 2 : 1

// Color intensity based on strength
buyColor  = sigStrength == 5 ? color.new(color.lime, 0) : sigStrength == 4 ? color.new(color.green, 0) : sigStrength == 3 ? color.new(color.green, 20) : color.new(color.green, 40)

sellColor = sigStrength == 5 ? color.new(color.red, 0) : sigStrength == 4 ? color.new(color.red, 10) : sigStrength == 3 ? color.new(color.red, 25) : color.new(color.red, 40)

// ================================================================================================
// REFINED SECTION 5: VISUALIZATION (CLEANER UI)
// ================================================================================================

// New Filter Logic: Only show the first signal in a sequence to reduce noise
var bool lastWasBuy = false
var bool lastWasSell = false

if buySignal
    lastWasSell := false
if sellSignal
    lastWasBuy := false

// Determine if we should plot based on noise reduction settings
bool displayBuy  = buySignal  and (not lastWasBuy)
bool displaySell = sellSignal and (not lastWasSell)

if displayBuy
    lastWasBuy := true
if displaySell
    lastWasSell := true

// ================================================================================================
// SECTION 5A: WEBHOOK ALERTS (PAYLOAD v2)
// ================================================================================================
// Two routes carry the same JSON — pick ONE per alert (both = duplicate webhooks):
//   A. "alert() function calls only"  + Message: {{alert_message}}
//      Sends BUY/SELL/EXIT_* events and, if enabled, the STATE snapshot.
//   B. "Order fills only"             + Message: {{strategy.order.alert_message}}
//      Sends BUY/SELL/EXIT_* when the strategy fills (Strategy Mode must be ON). No STATE.
// Either way: Trigger = Once per bar close, Webhook URL = your receiver.
// An alert snapshots the script version it was created with — after pasting a new version,
// delete and re-create the alerts.
//
// Events (all on confirmed bars only):
//   BUY / SELL           — entry (a SELL while long also closes the long, as the strategy does)
//   EXIT_LONG/EXIT_SHORT — score crossed back past -20 / +20 without an opposite signal
//   STATE                — optional snapshot every bar close (i_alertState)
//
// v1 fields stay first and keep their meaning: signal = BUY|SELL (STATE for snapshots),
// timestamp = alert time (ms). With "Send fixed v1 score/strength" ON (default) score = 0 and
// strength = 3, matching a fixed-text v1 alert template, so a receiver that acts on "score"
// sees no change on upgrade. The live composite is always in "composite"; v1 receivers that
// ignore unknown fields are unaffected by the v2 additions.

// Position tracker mirroring Section 7 (independent of i_strategyMode, so alerts work with
// strategy mode OFF). Updated on confirmed bars only — Pine rolls var state back on
// unconfirmed realtime ticks, so intrabar values never stick.
var int vPos = 0   // 1 long, -1 short, 0 flat
string evAction = na
if barstate.isconfirmed
    exitLongNow  = vPos == 1  and normalizedScore < -20
    exitShortNow = vPos == -1 and normalizedScore > 20
    if buySignal and vPos != 1
        evAction := "BUY"
        vPos     := 1
    else if sellSignal and vPos != -1
        evAction := "SELL"
        vPos     := -1
    else if exitLongNow
        evAction := "EXIT_LONG"
        vPos     := 0
    else if exitShortNow
        evAction := "EXIT_SHORT"
        vPos     := 0

f_num(float v, int dp) =>
    na(v) ? "null" : str.tostring(math.round(v, dp))

f_bool(bool b) =>
    b ? "true" : "false"

sigLabel = buySignal ? "STRONG BUY" : sellSignal ? "STRONG SELL" : normalizedScore > 30 ? "Weak Bull" : normalizedScore < -30 ? "Weak Bear" : "Neutral"
impulseState = impulseGreen ? "green" : impulseRed ? "red" : "blue"

// eventType: "BUY" | "SELL" | "EXIT_LONG" | "EXIT_SHORT" | "STATE"
f_buildPayload(string eventType) =>
    legacySignal = eventType == "BUY" or eventType == "EXIT_SHORT" ? "BUY" : eventType == "SELL" or eventType == "EXIT_LONG" ? "SELL" : "STATE"
    kind         = eventType == "STATE" ? "STATE" : (eventType == "BUY" or eventType == "SELL") ? "ENTRY" : "EXIT"
    "{" +
     "\"symbol\":\""     + syminfo.ticker + "\"," +
     "\"exchange\":\""   + syminfo.prefix + "\"," +
     "\"signal\":\""     + legacySignal   + "\"," +
     "\"score\":"      + (i_v1FixedScore ? "0" : f_num(normalizedScore, 2)) + "," +
     "\"price\":"        + f_num(close, 4) + "," +
     "\"timeframe\":\""  + timeframe.period + "\"," +
     "\"timestamp\":"    + str.tostring(timenow) + "," +
     "\"strength\":"   + (i_v1FixedScore ? "3" : str.tostring(math.round(math.abs(normalizedScore) / 10))) + "," +
     "\"sector\":\""     + resolvedSectorETF + "\"," +
     "\"v\":2," +
     "\"script\":\"WZST\",\"script_version\":\"1.3.0\"," +
     "\"type\":\""       + kind + "\"," +
     "\"action\":\""     + (eventType == "STATE" ? "NONE" : eventType) + "\"," +
     "\"position\":"     + str.tostring(vPos) + "," +
     "\"bar_time\":"     + str.tostring(time) + "," +
     "\"bar_close_time\":" + str.tostring(time_close) + "," +
     "\"confirmed\":"    + f_bool(barstate.isconfirmed) + "," +
     "\"tf_category\":\"" + (tfIsIntraday ? "intraday" : tfIsWeekly ? "weekly" : "daily") + "\"," +
     "\"ohlcv\":{\"o\":" + f_num(open, 4) + ",\"h\":" + f_num(high, 4) + ",\"l\":" + f_num(low, 4) + ",\"c\":" + f_num(close, 4) + ",\"v\":" + f_num(volume, 0) + "}," +
     "\"composite\":"    + f_num(normalizedScore, 2) + "," +
     "\"composite_raw\":" + f_num(compositeScore, 2) + "," +
     "\"label\":\""      + sigLabel + "\"," +
     "\"components\":{" +
         "\"rsi\":{\"v\":" + f_num(rsiVal, 2) + ",\"len\":" + str.tostring(adaptRsiLen) + ",\"pts\":" + f_num(rsiScore, 2) + ",\"bull_div\":" + f_bool(rsiBullDiv) + ",\"bear_div\":" + f_bool(rsiBearDiv) + "}," +
         "\"macd\":{\"line\":" + f_num(macdLine, 4) + ",\"signal\":" + f_num(signalLine, 4) + ",\"hist\":" + f_num(macdHist, 4) + ",\"impulse\":\"" + impulseState + "\",\"pts\":" + f_num(macdScore, 2) + "}," +
         "\"vidya\":{\"v\":" + f_num(vidya, 4) + ",\"slope\":" + f_num(vidyaSlope, 4) + ",\"pts\":" + f_num(vidyaScore, 2) + "}," +
         "\"volume\":{\"ratio\":" + f_num(volSma > 0 ? volume / volSma : na, 3) + ",\"low_vol\":" + f_bool(lowVolWarning) + ",\"obv_bull\":" + f_bool(obvBullish) + ",\"obv_bear\":" + f_bool(obvBearish) + ",\"pts\":" + f_num(volScore, 2) + "}," +
         "\"depth\":{\"spread_atr\":" + f_num(spreadRatio, 3) + ",\"pts\":" + f_num(depthScore, 2) + "}," +
         "\"sector\":{\"etf\":\"" + resolvedSectorETF + "\",\"mode\":\"" + sectorDetectMode + "\",\"valid\":" + f_bool(sectorDataValid) + ",\"rs\":" + f_num(sectorRsSmooth, 3) + ",\"pts\":" + f_num(sectorScore, 2) + "}" +
     "}," +
     "\"gates\":{\"core_bull\":" + f_bool(coreAlignBull) + ",\"core_bear\":" + f_bool(coreAlignBear) + ",\"vol_gate\":" + f_bool(volGate) + ",\"buy_thresh\":" + str.tostring(i_buyThresh) + ",\"sell_thresh\":" + str.tostring(i_sellThresh) + "}," +
     "\"atr\":" + f_num(atrVal, 4) +
     "}"

if i_enableAlerts and not na(evAction)
    alert(f_buildPayload(evAction), alert.freq_once_per_bar_close)
if i_enableAlerts and i_alertState and barstate.isconfirmed
    alert(f_buildPayload("STATE"), alert.freq_once_per_bar_close)

// --- 5B: VIDYA Overlay ---
vidyaColor  = vidyaUp ? color.new(color.teal, 0) : color.new(color.orange, 0)
plot(i_showVidya ? vidya : na, title="VIDYA", color=vidyaColor, linewidth=2)

// --- 5C: COMBINED SIGNAL LABELS (REDUCED NOISE) ---
// Merges shapes and text into a single cohesive label
if i_showLabels and displayBuy
    label.new(bar_index, low,
              text   = "▲ BUY",
              color  = buyColor,
              style  = label.style_label_up,
              textcolor = color.white,
              size   = size.small)

if i_showLabels and displaySell
    label.new(bar_index, high,
              text   = "▼ SELL",
              color  = sellColor,
              style  = label.style_label_down,
              textcolor = color.white,
              size   = size.small)

// --- 5D: OPTIONAL WARNINGS ---
// Only shows if volume is dangerously low, otherwise stays hidden
if lowVolWarning and barstate.isconfirmed and volume > 0
    label.new(bar_index, high,
              text      = "!",
              color      = color.new(color.gray, 70),
              style      = label.style_label_down,
              textcolor  = color.white,
              size       = size.tiny,
              tooltip    = "Low Volume Warning")

// --- 5E: BACKGROUND HIGHLIGHT ---
bgBuyColor  = color.new(color.green, 92) // Increased transparency (92) for less visual "weight"
bgSellColor = color.new(color.red,   92)
bgcolor(i_showBgColor and displayBuy  ? bgBuyColor  : na, title="BUY Bar Highlight")
bgcolor(i_showBgColor and displaySell ? bgSellColor : na, title="SELL Bar Highlight")

// ================================================================================================
// SECTION 6: DASHBOARD TABLE
// ================================================================================================

// Helper: convert boolean to colored status string
f_status(bullFlag, bearFlag) =>
    bullFlag ? "BULL" : bearFlag ? "BEAR" : "NEUT"

f_stateColor(bullFlag, bearFlag) =>
    bullFlag ? color.new(color.green, 20) : bearFlag ? color.new(color.red, 20) : color.new(color.gray, 30)

f_scoreColor(score, maxScore) =>
    ratio = score / maxScore
    ratio > 0.5 ? color.new(color.green, 10) : ratio > 0 ? color.new(color.green, 50) : ratio < -0.5 ? color.new(color.red, 10) : ratio < 0 ? color.new(color.red, 50) : color.new(color.gray, 30)

// Table position mapping
tblPos = i_tablePos == "Top Right" ? position.top_right : i_tablePos == "Top Left" ? position.top_left : i_tablePos == "Bottom Right" ? position.bottom_right : position.bottom_left

// Sector row label: "XLK (auto)", "XLF (manual)", "XLK (fallback)", "XLK (non-US!)"
sectorRowLabel = sectorUnmapped and i_unmappedNeutral ? "unmapped" : sectorDetectMode == "auto" ? resolvedSectorETF + " (auto)" : sectorDetectMode == "manual" ? resolvedSectorETF + " (manual)" : sectorDetectMode == "fallback-us" ? resolvedSectorETF + " (fallback)" : sectorDetectMode == "fallback-nonus" ? resolvedSectorETF + " (non-US!)" : resolvedSectorETF

// Build table on the last bar
var table dashTable = na

if i_showTable and barstate.islast
    // Create fresh table each time (handles resize)
    dashTable := table.new(tblPos, 3, 11,
                           border_width = 1,
                           border_color = color.new(color.gray, 50),
                           frame_width  = 2,
                           frame_color  = color.new(color.navy, 20))

    // Header row
    table.cell(dashTable, 0, 0, "WirezardStrategyTester",
               bgcolor=color.new(color.navy, 20), text_color=color.white,
               text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dashTable, 0, 0, 2, 0)

    // Column headers
    table.cell(dashTable, 0, 1, "Indicator",
               bgcolor=color.new(color.gray, 40), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 1, 1, "State",
               bgcolor=color.new(color.gray, 40), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 1, "Score",
               bgcolor=color.new(color.gray, 40), text_color=color.white, text_size=size.tiny)

    // RSI row
    table.cell(dashTable, 0, 2, "RSI (" + str.tostring(adaptRsiLen) + ")",
               bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 1, 2, f_status(rsiBullFlag, rsiBearFlag),
               bgcolor=f_stateColor(rsiBullFlag, rsiBearFlag), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 2, str.tostring(math.round(rsiScore, 1)),
               bgcolor=f_scoreColor(rsiScore, float(wRsi)), text_color=color.white, text_size=size.tiny)

    // MACD row
    table.cell(dashTable, 0, 3, "I-MACD (" + str.tostring(adaptMacdFast) + "/" + str.tostring(adaptMacdSlow) + ")",
               bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 1, 3, f_status(macdBullFlag, macdBearFlag),
               bgcolor=f_stateColor(macdBullFlag, macdBearFlag), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 3, str.tostring(math.round(macdScore, 1)),
               bgcolor=f_scoreColor(macdScore, float(wMacd)), text_color=color.white, text_size=size.tiny)

    // VIDYA row
    table.cell(dashTable, 0, 4, "VIDYA (" + str.tostring(adaptVidyaLen) + ")",
               bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 1, 4, f_status(vidyaBullFlag, vidyaBearFlag),
               bgcolor=f_stateColor(vidyaBullFlag, vidyaBearFlag), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 4, str.tostring(math.round(vidyaScore, 1)),
               bgcolor=f_scoreColor(vidyaScore, float(wVidya)), text_color=color.white, text_size=size.tiny)

    // Volume row
    table.cell(dashTable, 0, 5, "Volume (" + str.tostring(adaptVolMaLen) + ")",
               bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 1, 5, lowVolWarning ? "LOW!" : f_status(volBullFlag, volBearFlag),
               bgcolor=lowVolWarning ? color.new(color.orange, 20) : f_stateColor(volBullFlag, volBearFlag),
               text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 5, str.tostring(math.round(volScore, 1)),
               bgcolor=f_scoreColor(volScore, float(wVol)), text_color=color.white, text_size=size.tiny)

    // Market Depth row
    table.cell(dashTable, 0, 6, "Depth Proxy",
               bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 1, 6, f_status(depthScore > 0, depthScore < 0),
               bgcolor=f_stateColor(depthScore > 0, depthScore < 0), text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 6, str.tostring(math.round(depthScore, 1)),
               bgcolor=f_scoreColor(depthScore, float(wDepth)), text_color=color.white, text_size=size.tiny)

    // Sector row — shows resolved ETF and detection mode
    // Warning color for fallback and non-US modes to prompt user attention
    sectorRowBg = sectorDetectMode == "auto" ? color.new(color.gray, 70) : sectorDetectMode == "manual" ? color.new(color.gray, 70) : sectorDetectMode == "fallback-us" ? color.new(color.orange, 50) : color.new(color.red, 50)
    table.cell(dashTable, 0, 7, "Sector: " + sectorRowLabel,
               bgcolor=sectorRowBg, text_color=color.white, text_size=size.tiny)
    // Unmapped + neutral: show OFF (score is 0), not the override ETF's BULL/BEAR
    sectorNeutralised = sectorUnmapped and i_unmappedNeutral
    table.cell(dashTable, 1, 7, sectorNeutralised ? "OFF" : sectorDataValid ? f_status(sectorStrong, sectorWeak) : "N/A",
               bgcolor=sectorNeutralised ? color.new(color.gray, 30) : sectorDataValid ? f_stateColor(sectorStrong, sectorWeak) : color.new(color.orange, 30),
               text_color=color.white, text_size=size.tiny)
    table.cell(dashTable, 2, 7, str.tostring(math.round(sectorScore, 1)),
               bgcolor=f_scoreColor(sectorScore, float(wSector)), text_color=color.white, text_size=size.tiny)

    // Sector weight info row (shown when weight is modified by non-US fallback)
    sectorWtText  = isNonUS ? "Sect.Wt: " + str.tostring(effectiveSectorWeight, "#.##") + "x (non-US 50%)" : "Sect.Wt: " + str.tostring(effectiveSectorWeight, "#.##") + "x"
    sectorWtColor = isNonUS ? color.new(color.orange, 30) : color.new(color.gray, 60)
    table.cell(dashTable, 0, 8, sectorWtText,
               bgcolor=sectorWtColor, text_color=color.white,
               text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(dashTable, 0, 8, 2, 8)

    // Composite score row
    compositeColor = normalizedScore >= float(i_buyThresh) ? color.new(color.lime, 10) : normalizedScore <= float(i_sellThresh) ? color.new(color.red, 10) : normalizedScore > 0 ? color.new(color.green, 30) : normalizedScore < 0 ? color.new(color.orange, 30) : color.new(color.gray, 30)
    table.cell(dashTable, 0, 9, "COMPOSITE",
               bgcolor=compositeColor, text_color=color.white, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dashTable, 0, 9, 1, 9)
    table.cell(dashTable, 2, 9, str.tostring(math.round(normalizedScore, 1)),
               bgcolor=compositeColor, text_color=color.white, text_size=size.small)

    // Signal row
    sigText  = sigLabel  // same label the webhook sends (Section 5A)
    sigColor = buySignal ? color.new(color.lime, 0) : sellSignal ? color.new(color.red, 0) : normalizedScore > 30 ? color.new(color.green, 30) : normalizedScore < -30 ? color.new(color.orange, 20) : color.new(color.gray, 30)
    table.cell(dashTable, 0, 10, sigText,
               bgcolor=sigColor, text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(dashTable, 0, 10, 2, 10)

// ================================================================================================
// SECTION 7: STRATEGY ENTRIES & EXITS (OPTIMIZED)
// ================================================================================================
if i_strategyMode
    // Define exit conditions for cleaner readability.
    // The score legs are gated on barConfirmed like the entries: with calc_on_every_tick they
    // used to close intrabar on a passing dip below -20 (v1.2 bug).
    bool exitLong  = sellSignal or (barConfirmed and normalizedScore < -20)
    bool exitShort = buySignal  or (barConfirmed and normalizedScore > 20)

    // --- Entries ---
    // strategy.entry automatically flips positions, so we don't need to check position_size manually.
    // Every order call carries the same v2 payload as Section 5A, so the "Order fills only" route
    // works too ({{strategy.order.alert_message}}). Every call must carry it: TradingView sends an
    // empty body for an order call without alert_message. Use ONE route per alert, never both.
    if buySignal
        strategy.entry("Long", strategy.long, comment="BUY", alert_message=f_buildPayload("BUY"))

    if sellSignal
        strategy.entry("Short", strategy.short, comment="SELL", alert_message=f_buildPayload("SELL"))

    // --- Exits ---
    if exitLong and strategy.position_size > 0
        strategy.close("Long", comment="EXIT_LONG", alert_message=f_buildPayload(sellSignal ? "SELL" : "EXIT_LONG"))

    if exitShort and strategy.position_size < 0
        strategy.close("Short", comment="EXIT_SHORT", alert_message=f_buildPayload(buySignal ? "BUY" : "EXIT_SHORT"))
````
