# Market Quality Score Pro

- url: https://www.tradingview.com/script/SnHeX1ol-Market-Quality-Score-Pro/
- type: indicator
- pine_id: PUB;fead3b332e904427973015a36ed798f2
- version: 2.0

## Description

Market Quality Score Pro is a multi-factor scoring indicator that helps you evaluate stocks, ETFs, indices, bonds, crypto, forex, and commodities with one unified framework. It combines relative strength, trend quality, and (where available) fundamental quality into a normalized score from 0.00 to 1.00, then translates that score into practical signal zones such as Watch, Buy, Strong Buy, or Avoid.

The indicator is designed to adapt to different instrument types automatically. For stocks, it can include earnings growth, revenue growth, and return on equity, while for ETFs, indices, bonds, and many other instruments it focuses more on relative strength, benchmark comparison, trend structure, and data quality.

Key features:
[list]
[*]Multi-factor total score from 0.00 to 1.00.
[*]Relative strength model based on 12-month ex-last-month, 6-month, 3-month, distance to 52-week high, and RS-line slope.
[*]Trend quality model based on SMA200, 50/200 structure, and drawdown control.
[*]Fundamental quality block for equities using EPS growth, revenue growth, and ROE where valid data exists.
[*]Automatic benchmark selection by market and region, with optional manual override.
[*]Coverage and confidence logic to reduce overconfidence when data is incomplete.
[*]Safety filter for trend condition, drawdown quality, and tradability.
[*]Signal markers for Buy, Strong Buy, Exit, and Divergence.
[*]Informative table with benchmark, market regime, history quality, score components, and model status.
[/list]

How to read it:
[list]
[*]Above 0.50: instrument becomes interesting.
[*]Above 0.65: enters the buy zone if additional gates and filters are satisfied.
[*]Above 0.80: strong candidate with stricter confirmation logic.
[*]Below 0.30: weak zone or avoid area.
[/list]

This script is not a standalone trading system and should not be used in isolation. Signals are strongest when read together with price structure, liquidity, market regime, and upcoming event risk such as earnings releases

## Source Code

````pine
//@version=6
string APP_TITLE      = "Market Quality Score Pro"
string APP_SHORTTITLE = "MQSP"

indicator(APP_TITLE, shorttitle=APP_SHORTTITLE, overlay=false, precision=2)

// === TEXTKONSTANTEN =========================================================
var string DEFAULT_BENCHMARK    = "SPY"

var string S_EMPTY              = ""
var string S_AUTO               = "Auto"
var string S_MANUELL            = "Manual"

var string S_AKTIE_IN           = "Stock"
var string S_ETF_INDEX_IN       = "ETF/Index"
var string S_ANLEIHE_IN         = "Bond"
var string S_OTHER_IN           = "Forex/Crypto/Commodity"

var string S_MODE_AKTIE         = "STOCK"
var string S_MODE_ETF           = "ETF"
var string S_MODE_INDEX         = "INDEX"
var string S_MODE_BOND          = "BOND"
var string S_MODE_KRYPTO        = "CRYPTO"
var string S_MODE_FOREX         = "FOREX"
var string S_MODE_ROHSTOFF      = "COMMODITY"

var string S_TOPRIGHT           = "topright"
var string S_MIDDLERIGHT        = "middleright"
var string S_BOTTOMRIGHT        = "bottomright"
var string S_TOPLEFT            = "topleft"
var string S_MIDDLELEFT         = "middleleft"
var string S_BOTTOMLEFT         = "bottomleft"

var string S_TINY               = "tiny"
var string S_SMALL              = "small"
var string S_NORMAL             = "normal"
var string S_LARGE              = "large"

var string S_DASH               = "-"
var string S_NA                 = "–"
var string S_PLUS               = "+"
var string S_PERCENT            = " %"
var string S_MULT               = "x"

var string S_HIST_FULL          = "Complete"
var string S_HIST_LIMITED       = "Limited"
var string S_HIST_SHORT         = "Too short"

var string S_MARKET_POSITIVE    = "Positive"
var string S_MARKET_WEAK        = "Weak"

var string S_FILTER_PASS        = "✓ PASSED"
var string S_FILTER_FAIL        = "✗ FAILED"
var string S_FILTER_TREND_OK    = "✓ TREND OK"
var string S_FILTER_TREND_WEAK  = "✗ WEAK TREND"
var string S_FILTER_BENCH_MISSING = "⚠ BENCHMARK MISSING"

var string S_REC_AVOID          = "SELL / AVOID"
var string S_REC_BUY_STRONG     = "BUY - Strong signal"
var string S_REC_BUY_GOOD       = "BUY - Good signal"
var string S_REC_WATCH          = "WATCH"
var string S_REC_WEAK_DATA      = "WEAK DATA"
var string S_REC_NEUTRAL        = "NEUTRAL - Wait"

var string S_ACT_AVOID          = "Avoid – score too weak for entry"
var string S_ACT_BUY_STRONG     = "Build position (6-8% portfolio)"
var string S_ACT_BUY_GOOD       = "Build position (3-5% portfolio)"
var string S_ACT_WATCH          = "Add to watchlist, do not buy"
var string S_ACT_WEAK_DATA      = "Do not trade – insufficient data/history"
var string S_ACT_NEUTRAL        = "Wait – do not open a new position"

var string S_EARN_RECENT        = "Reported recently"
var string S_EARN_TODAY         = "⚠ TODAY"
var string S_IN_PREFIX          = "In "
var string S_IN_SUFFIX          = " days"

var string S_VOL_BIO            = "T"
var string S_VOL_MRD            = "B"
var string S_VOL_MIO            = "M"
var string S_CHECK              = "✓"
var string S_CROSS              = "✗"
var string S_TREND_SMA200       = " SMA200  "
var string S_TREND_GC           = " GC  "
var string S_TREND_DD           = " DD"

var string G_HELP               = "📖 Help & Explanations"
var string G_MARKET             = "🌍 Market Logic"
var string G_SETTINGS           = "⚙️ General Settings"
var string G_THRESHOLDS         = "📊 Thresholds"
var string G_FILTER             = "🛡️ Safety Filter"
var string G_DISPLAY            = "🖥️ Display"

var string I_HELP_CHART         = "ℹ️ Explanation: Chart lines"
var string I_HELP_SIGNALE       = "ℹ️ Explanation: Chart signals"
var string I_HELP_EMPFEHLUNG    = "ℹ️ Explanation: Recommendation"
var string I_HELP_ACTION        = "ℹ️ Explanation: Suggested action"

var string I_BENCH_MODE         = "Benchmark Mode"
var string I_BENCH_MANUAL       = "Manual Benchmark"
var string I_W_RS               = "Relative Strength Weight"
var string I_W_EARN             = "Earnings Quality Weight"
var string I_W_TREND            = "Trend Quality Weight"
var string I_THR_STRONG         = "Strong Buy Threshold"
var string I_THR_GOOD           = "Buy Threshold"
var string I_THR_WATCH          = "Watch Threshold"
var string I_THR_FAIL           = "Sell/Avoid Threshold"
var string I_USE_FILTER         = "Enable Safety Filter"
var string I_MAX_DD             = "Max. 60-day drawdown (%)"
var string I_MIN_VOL            = "Min. daily turnover (USD)"
var string I_ASSET_MODE         = "Instrument Mode"
var string I_MIN_COV_BUY        = "Min. coverage for buy"
var string I_MIN_COV_WATCH      = "Min. coverage for watch"
var string I_MIN_HIST           = "Min. history for full mode"
var string I_STRICT_BENCH       = "Benchmark required for buy"
var string I_TABLE_POS          = "Table Position"
var string I_TABLE_SIZE         = "Table Font Size"
var string I_SHOW_BG            = "Show Background Color"
var string I_SHOW_LEGEND        = "Show Chart Legend"

var string PLOT_EARN_SOON       = "Earnings < 5 days"
var string PLOT_EARN_WINDOW     = "Earnings < 14 days"
var string PLOT_BG_MARKET       = "Market Background"

var string SIG_BUY              = "✓ BUY SIGNAL"
var string SIG_EXIT             = "⚠ EXIT"
var string SIG_BUY_STRONG       = "★ STRONG BUY SIGNAL"
var string SIG_DIVERGENZ        = "⚠ DIVERGENCE"

var string ROW_SEKTOR           = "  Sector"
var string ROW_INDUSTRIE        = "  Industry"
var string ROW_MODUS            = "  Mode"
var string ROW_HISTORIE         = "  History"
var string ROW_COVERAGE         = "  Data Coverage / Model Confidence"
var string ROW_GESAMT           = "  Total Score"
var string ROW_RS               = "  Relative Strength"
var string ROW_TREND            = "  Trend Quality"
var string ROW_DIST_ATH         = "  Distance to 52-week high"
var string ROW_BENCHMARK        = "  Benchmark"
var string ROW_FILTER           = "  Safety Filter"
var string ROW_MARKTREGIME      = "  Market Regime"
var string ROW_EMPFEHLUNG       = "  Recommendation"
var string ROW_ACTION           = "  Action"
var string ROW_KURVEN           = "  Lines"
var string ROW_KURVEN_VALUES    = "① Score  ② RS  ③ Earnings  ④ Momentum"
var string ROW_SIGNALE         = "  Signals"
var string ROW_SIGNALE_VALUES  = "↑ Buy   ↓ Exit   ★ Strong   ▽ Divergence"

var string ROW_EARNINGS_EQUITY  = "  Next earnings release"
var string ROW_EARNINGS_GENERIC = "  Next company event"
var string ROW_EARN_EQUITY      = "  Earnings Quality"
var string ROW_EARN_GENERIC     = "  Fundamentals"
var string ROW_EPS_EQUITY       = "  EPS growth (1Y)"
var string ROW_EPS_GENERIC      = "  EPS growth"
var string ROW_REV_EQUITY       = "  Revenue growth (1Y)"
var string ROW_REV_GENERIC      = "  Revenue growth"
var string ROW_ROE_EQUITY       = "  Return on equity"
var string ROW_ROE_GENERIC      = "  Return on capital"
var string ROW_DE_EQUITY        = "  Leverage (D/E)"
var string ROW_DE_GENERIC       = "  Leverage"
var string ROW_FCF              = "  Free cash flow yield"
var string ROW_PEG              = "  Valuation vs. growth"

var string ROW_VOL_EQUITY       = "  Trading volume (20D avg)"
var string ROW_VOL_ETF          = "  Trading volume (20D avg)"
var string ROW_VOL_BOND         = "  Tradability / Volume"
var string ROW_VOL_INDEX        = "  Volume / Tradability"
var string ROW_VOL_OTHER        = "  Volume / Tradability"

var string MODE_SECTOR_BOND     = "BOND / FIXED INCOME"
var string MODE_SECTOR_ETF      = "ETF / INDEX"
var string MODE_SECTOR_FOREX    = "FOREX MARKET"
var string MODE_SECTOR_KRYPTO   = "CRYPTO MARKET"
var string MODE_SECTOR_ROHSTOFF = "COMMODITY MARKET"
var string MODE_SECTOR_OTHER    = "OTHER MARKET"

var string MODE_INDUSTRY_BOND   = "RATE-SENSITIVE FIXED-INCOME INSTRUMENT"
var string MODE_INDUSTRY_ETF    = "PASSIVE / MARKET-BASED INSTRUMENT"
var string MODE_INDUSTRY_FOREX  = "CURRENCY PAIR / FX INSTRUMENT"
var string MODE_INDUSTRY_KRYPTO = "DIGITAL ASSET"
var string MODE_INDUSTRY_ROHSTOFF = "PHYSICAL OR FUTURES-BASED COMMODITY"
var string MODE_INDUSTRY_OTHER  = "NON-CORPORATE INSTRUMENT"

var string LEGEND_TITLE         = "── MQSP – LEGEND ──"
var string LEGEND_1             = "① Yellow = Total score (0.00–1.00)"
var string LEGEND_2             = "② Blue = Price strength"
var string LEGEND_3             = "③ Orange = Company quality"
var string LEGEND_4             = "④ White = Score momentum"
var string LEGEND_5             = "↑green buy · ↓red exit · ★ strong"
var string LEGEND_6             = "▽orange = Divergence warning"

var string ALERT_TITLE_STRONG_BUY = "Strong buy signal"
var string ALERT_MSG_STRONG_BUY   = "MQSP: Strong buy signal active"
var string ALERT_TITLE_GOOD_BUY   = "Buy signal"
var string ALERT_MSG_GOOD_BUY     = "MQSP: Buy signal active"
var string ALERT_TITLE_SELL       = "Sell signal"
var string ALERT_MSG_SELL         = "MQSP: Sell / Avoid"

var string HLINE_STRONG         = "Score >= 0.80"
var string HLINE_GOOD           = "Score >= 0.65"
var string HLINE_WATCH          = "Score >= 0.50"
var string HLINE_FAIL           = "Score < 0.30"

var string S_GT_50_PERCENT      = ">50 %"
var string S_SPACE              = ""

// === TOOLTIPS ============================================
var string tt_bench = "Here you choose the benchmark against which the instrument is measured.\n\nWhy is this important?\nThe benchmark mainly affects relative strength and market regime. The script therefore checks not only whether price is rising, but whether it performs better than the selected comparison market.\n\nExamples:\n• SPY = broad US equity market\n• DAX = German equity market\n• ACWI = global equity market\n\nImportant: An unsuitable benchmark does not make relative strength technically wrong, but it does make it less meaningful."
var string tt_w_rs = "The weight of relative strength in the total score.\n\nHow does it work?\nThe total score is built from multiple components. This weight determines how strongly price action counts relative to the other components.\n\nDefault:\n0.50 = 50% weight.\nHigher = price behavior matters more.\nLower = fundamentals and trend receive relatively more influence.\n\nUseful for:\nUsers who deliberately want to weight momentum and market strength more heavily."
var string tt_w_earn = "The weight of earnings quality in the total score.\n\nWhat is behind it?\nThis block evaluates not the price, but the quality of the company. It uses earnings growth, revenue growth, and return on equity.\n\nDefault:\n0.35 = 35% weight.\nHigher = the script gives stronger preference to companies with good numbers.\n\nUseful for:\nUsers who care less about pure price momentum and more about business substance."
var string tt_w_trend = "The weight of trend quality in the total score.\n\nWhat does this block check?\nWhether the price is technically in a healthy uptrend. This includes being above the SMA200, a golden cross, and a limited pullback from the recent high.\n\nDefault:\n0.15 = 15% weight.\nHigher = the script becomes more cautious with damaged trends.\n\nThis component acts more like a technical safety net than a growth factor."
var string tt_thr_S = "The threshold for a strong buy signal.\n\nHow is it used?\nIf the total score exceeds this value and the required safety conditions are met, the script classifies the instrument as especially strong.\n\nDefault:\n0.80.\nThis is intentionally set high. A value above 0.80 usually means price, trend, and data quality are all very strong at the same time.\n\nHigher = rarer, stricter.\nLower = more frequent, but less selective."
var string tt_thr_A = "The threshold for a normal buy signal.\n\nHow is it used?\nFrom this level onward, an instrument is considered buyable as long as the additional safety rules also fit.\n\nDefault:\n0.65.\nThis is the main threshold for a potential entry.\n\nIn practice:\nBetween 0.65 and 0.79 = good candidate.\nFrom 0.80 onward = especially strong candidate."
var string tt_thr_B = "The threshold for 'Watch'.\n\nHow should this be read?\nFrom this level onward, an instrument is interesting, but not yet strong enough for a clear buy signal. This is typically a watchlist zone.\n\nDefault:\n0.50.\nBelow that, quality is usually too mixed. Above it, an instrument may develop toward a buy signal."
var string tt_thr_F = "The lower threshold for weak instruments.\n\nHow should this be read?\nIf the total score falls below this value, price, trend, or company data currently argue against an entry.\n\nDefault:\n0.30.\nThis does not automatically mean 'sell immediately', but it is clearly the weak zone of the model."
var string tt_filter = "Whether the safety filter should be active.\n\nHow does the filter work?\nBefore a buy signal is allowed, the script checks whether important minimum conditions are met. These mainly include an intact trend and an acceptable pullback from the recent high. For stocks, tradability via average daily turnover is also included. For ETFs, volume may also be useful. For indices, volume is usually not used as a hard minimum condition.\n\nPurpose of the filter:\nA high score alone should not be enough if an instrument is technically damaged or hard to trade.\n\nRecommendation:\nLeave it enabled for most users."
var string tt_max_dd = "The maximum allowed pullback from the last 60-day high.\n\nHow is it calculated?\nThe script compares the current price with the highest price of the last 60 trading days. This results in the drawdown in percent.\n\nExample:\nIf the price was 100 at the high and is 78 today, the drawdown is -22%.\n\nBenefit:\nThis filters out instruments that, despite a good score, are currently stuck in a clear downward move."
var string tt_min_vol = "The minimum average daily turnover an instrument should reach for the safety filter.\n\nHow is it calculated?\nThe script roughly uses price x volume and averages it over 20 trading days.\n\nWhy is this important?\nHigh trading turnover usually means better tradability. When turnover is very low, even a medium-sized buy or sell order can noticeably move the price.\n\nImportant:\nFor classic stocks this value is especially important. It can also be useful for ETFs. For indices it is often not meaningful because an index itself is usually not a directly tradable instrument."
var string tt_tbl_pos = "The position of the info table in the chart.\n\nThis has no influence on the calculation, only on the display. If the table covers important areas, simply choose another position."
var string tt_tbl_sz = "The font size of the info table.\n\nThis is also only a display setting. 'small' is usually a good default, while 'large' is more comfortable on large monitors."
var string tt_show_bg = "Whether the background should show the instrument signal or rather the market environment.\n\nIf enabled:\nThe background follows the current verdict of the script more closely.\n\nIf disabled:\nThe background mainly shows the market regime, meaning whether the selected benchmark is in a strong or weak phase."
var string tt_chart = "① The yellow line is the total score from 0.00 to 1.00.\n② The blue line shows relative strength.\n③ The orange line shows earnings quality.\n④ The white line shows score momentum.\n\nHow should it be read?\nThe main line shows the final result. The other lines explain why the rating is high or low.\n\nImportant:\nThe calculations are based on daily data, even if your visible chart uses a different timeframe."
var string tt_signale = "Green upward arrow:\nThe total score has crossed above the buy threshold.\n\nLarge green arrow:\nThe strong buy threshold has been crossed.\n\nRed downward arrow:\nThe total score has fallen back below the buy threshold.\n\nOrange triangle:\nDivergence warning. The price is still making a new high, but internal strength is already fading.\n\nImportant:\nNever read these signals in isolation. Always read them together with the score, the table, and the market environment."
var string tt_empfehlung = "The summarized verdict of the script.\n\nHow is it formed?\nThe recommendation is based on the total score, the configured thresholds, and the active safety rules. In v2, data coverage, history, and depending on the mode the validity of the benchmark are also taken into account.\n\nIn practice:\n'Buy' does not mean certainty, but that the instrument currently satisfies the model rules. 'Weak data' means the model is deliberately holding back.\n\nImportant:\nThe model verdict is based on available market and fundamental data. If source data is faulty, incomplete, or delayed, individual metrics can look unexpected even if the calculation itself is correct."
var string tt_action = "A practical action suggestion matching the current recommendation.\n\nHow should this be understood?\nThe texts are not rigid instructions, but a structured translation of the signal into a possible action: buy, watch, wait, or do not trade.\n\nThe mentioned portfolio percentages are only rough guidelines for risk management and will not fit every user equally."
var string tt_earn_days = "This row shows the next known company event, where that is meaningfully available for the instrument.\n\nFor stocks:\nThis usually means the next earnings release.\n\nFor ETFs, indices, and other markets:\nSuch dates are often not available or not equally meaningful for the model. In that case, the display remains empty or neutral.\n\nHow should it be read?\nA nearby event can create additional uncertainty and stronger price swings for stocks."
var string tt_master = "The total score of the model on a scale from 0.00 to 1.00.\n\nHow is it calculated?\nThe score is built from the active components:\n• Relative strength\n• Earnings quality\n• Trend quality\nThe default weights are 50% / 35% / 15%. In v2, only components for which actually usable data exists are scored.\n\nHow should the value be read?\nThe higher, the better. From 0.50 an instrument becomes interesting, from 0.65 it enters the buy zone, and from 0.80 the signal becomes especially strong.\n\nImportant:\nA high score is only especially robust if coverage, confidence, history, and the supplied data itself are plausible. The script can calculate everything mathematically correctly and still produce unexpected values when the underlying source data is faulty, incomplete, or delayed."
var string tt_rs = "Relative strength, or price strength.\n\nHow is it calculated?\nFive partial components are included:\n• 12-month performance excluding the last month = 40%\n• 6-month performance = 20%\n• 3-month performance = 15%\n• Proximity to the 52-week high = 15%\n• Development of the RS line versus the benchmark = 10%\n\nImportant:\nIn v2, only what is actually available is scored. If some sub-components are missing, the data coverage of this block declines.\n\nHow should the value be read?\nA high RS value means the instrument currently shows strong price behavior relative to its own history and to the selected benchmark."
var string tt_trend = "The technical trend quality of the instrument.\n\nHow is it calculated?\nThree conditions are included:\n• Price above SMA200 = 40%\n• 50-day average above 200-day average (golden cross) = 30%\n• Pullback from the 60-day high still within the allowed range = 30%\n\nHow should the display be read?\n✓ means: condition fulfilled.\n✗ means: condition not fulfilled.\n\nA high trend score does not automatically mean 'buy signal', but it shows that the instrument looks technically healthier than one in a downtrend."
var string tt_earn = "This row shows the fundamental quality of the instrument, where such company data is meaningfully available.\n\nFor stocks:\nThe value is based on earnings growth, revenue growth, and return on equity.\n\nFor ETFs, indices, and many other markets:\nSuch fundamental data is often not directly comparable or not appropriate. In that case, the script deliberately does not show a full fundamental score here.\n\nHow should it be read?\nHigh value = better fundamental company quality from the model's perspective.\nNo value = not automatically bad, but often simply not appropriate for that instrument type."
var string tt_eps = "The year-over-year earnings-per-share growth, where the data feed provides usable values.\n\nWhat does this mean?\nEPS stands for earnings per share. The comparison shows how strongly this value has increased or decreased versus the same period last year.\n\nImportant:\nThis metric is mainly meaningful for stocks. For ETFs, indices, and many other markets it is usually not appropriate or not available.\n\nHow should it be read?\nPositive is usually good, strongly negative is a warning sign. Always read it together with the data basis and the other fundamental values."
var string tt_rev = "The year-over-year revenue growth.\n\nWhat is revenue?\nRevenue is the money a company takes in from its products or services before costs are deducted.\n\nImportant:\nThis metric is mainly meaningful for stocks. For ETFs, indices, and many other markets it is usually not appropriate or not available.\n\nHow should it be read?\nRising revenue often points to demand or growth. Falling revenue can be an early warning sign."
var string tt_roe = "Return on equity, usually based on the last 12 months.\n\nWhat is the idea behind it?\nIt shows how efficiently a company earns money with the capital of its owners.\n\nImportant:\nThis metric is mainly meaningful for stocks. For ETFs, indices, and many other markets it is usually not directly appropriate.\n\nHow should it be read?\nHigher is often better. Very low or negative values are usually weak. Very high values, however, can also be influenced by high leverage."
var string tt_de = "The debt-to-equity ratio.\n\nWhat is the idea behind it?\nIt relates the debt of a company to its equity.\n\nImportant:\nThis metric is mainly meaningful for stocks. For ETFs, indices, and many other markets it is often not appropriate or not directly comparable.\n\nHow should it be read?\nLower is often more stable. High values usually mean more financial leverage and therefore potentially more risk."
var string tt_sektor = "The economic sector of the company.\n\nWhy is this important?\nMetrics are not interpreted equally across all industries. High leverage can be normal for banks, but less so for software companies. The sector therefore helps put numbers like ROE and D/E into a more realistic context."
var string tt_industrie = "The more specific sub-industry within the sector.\n\nBenefit:\nIt helps you better understand how the company actually makes its money. This is especially useful when two firms belong to the same sector but operate with very different business models."
var string tt_peg = "The PEG ratio. This metric is informational and does not directly feed into the score.\n\nWhat is the idea behind it?\nIt combines valuation and growth, simplified as P/E divided by EPS growth.\n\nImportant:\nThis metric is mainly meaningful for stocks. For ETFs, indices, and many other markets it is usually not appropriate or not reliable.\n\nHow should it be read?\nLower is usually cheaper relative to growth. Very high or missing values should be interpreted with caution."
var string tt_fcf = "The cash flow yield based on free cash flow.\n\nWhat is the idea behind it?\nIt compares free cash flow with the company's current market value.\n\nImportant:\nThis metric is mainly meaningful for stocks. For ETFs, indices, and many other markets it is usually not appropriate.\n\nHow should it be read?\nHigher is often better. Negative values mean there is currently no positive free cash flow."
var string tt_dist = "The distance of the current price to the 52-week high.\n\nHow is it calculated?\nCurrent price relative to the highest price of the last 252 trading days.\n\nHow should it be read?\nA small distance often indicates strength. A large distance usually shows that the instrument is trading well below earlier highs.\n\nImportant:\nNot every instrument near its high is automatically attractive, but strong instruments statistically often trade closer to their highs than weak ones."
var string tt_vol = "The average daily turnover over the last 20 trading days, where it is meaningfully available for the instrument.\n\nHow is it calculated?\nRoughly price x volume, averaged over 20 days.\n\nHow should it be read?\nHigh value = usually better tradability.\nLow value = higher execution and slippage risk.\n\nImportant:\nFor stocks and many ETFs this value is useful. For indices or some other markets it is often not meaningful or only meaningful with limitations."
var string tt_filter_row = "The result of the safety check.\n\nWhat is checked?\nDepending on the instrument, mainly:\n• trend above the long-term average\n• pullback from the recent high still within the allowed range\n• for stocks additionally sufficient average daily turnover\n• for ETFs optionally tradability as well\n\nHow should it be read?\n✓ PASSED = the minimum conditions for buy signals are fulfilled.\n✗ FAILED = at least one safety condition blocks the buy signal.\n✓ TREND OK = for markets without a classic tradability filter, the technical minimum state is fulfilled.\n⚠ BENCHMARK MISSING = an important comparison market is missing for parts of the logic."
var string tt_markt_regime = "It shows the general market environment (market regime) of the selected benchmark.\n\nHow is it calculated?\nThe benchmark is compared with its 200-day average.\n• above SMA200 = rather supportive market environment\n• below SMA200 = rather weak market environment\n\nHow should it be read?\nPositive = the overall market provides more tailwind.\nNegative = the overall market provides more headwind.\n\nWhy is this important?\nBuy signals often work better in strong overall markets than in weak ones."
var string tt_score_mom = "The score momentum of the total score.\n\nHow is it calculated?\nToday's total score minus the total score from 20 trading days ago.\n\nHow should it be read?\n• Positive = the score has improved over recent weeks\n• Negative = the score has deteriorated\n• Near zero = little change\n\nUse:\nThis is an early indicator of acceleration or fatigue, but not a standalone buy signal."
var string tt_earnings_zone = "They mark the period before earnings.\n\nWhy is this important?\nShortly before earnings, price risk often increases because new company numbers and outlooks are released.\n\nHow should the colors be read?\nYellow = the date is getting closer.\nOrange = very close, elevated risk.\n\nIn practice:\nMany users avoid new entries right before earnings."
var string tt_divergenz = "A divergence warning.\n\nHow does it arise in the script?\nThe signal appears when price makes a new 20-day high while the total score has recently been falling and is not yet completely weak.\n\nWhat does that mean conceptually?\nThe price still looks strong on the surface, but the internal quality of the signal is already deteriorating.\n\nThis is not an automatic sell command, but it is a clear hint of weakening internal strength."
var string tt_rib_master = "The thick main line is the model's total score between 0.00 and 1.00.\n\nIt is the summary of all active components and therefore the most important line in the pane.\n\nThe higher the line, the better the instrument according to the script rules."
var string tt_rib_rs = "The blue line shows relative strength.\n\nIt is its own sub-score from 0.00 to 1.00 and measures how strong price behavior is relative to its history and to the benchmark.\n\nBecause it has a default weight of 50%, it is the most important individual component."
var string tt_rib_earn = "The orange line shows earnings quality, or fundamental quality.\n\nIt is based on EPS growth, revenue growth, and ROE. When fundamental data is missing, v2 may omit it rather than pretending to provide a full-quality statement."
var string tt_rib_mom = "The white line shows score momentum.\n\nUnlike the other lines, it moves around the zero line. Positive means the score is better than 20 trading days ago. Negative means it has weakened.\n\nThis line is especially useful for spotting early improvements or first signs of fatigue."
var string tt_mode = "The mode determines what kind of instrument the script is looking at.\n\nPossible cases:\n• Stock = single company\n• ETF = exchange-traded fund\n• Index = market barometer such as DAX or S&P 500\n• Bond = rate-sensitive fixed-income instrument\n• Other market = e.g. forex, crypto, or commodities\n\nWhy is this important?\nNot every type of instrument has the same data. Stocks often have fundamentals and earnings dates. ETFs, indices, and bonds instead mainly use market, trend, and benchmark logic. The mode ensures that the script does not force metrics where they do not fit conceptually.\n\nHow is it determined?\nIn auto mode, the script uses information such as exchange, symbol type, description, and available metadata. This lets it distinguish stocks, ETFs, indices, bonds, and other markets more cleanly than before.\n\nHow should it be read?\nThe displayed mode is the basis for which parts of the model are scored and which rows in the table are meaningfully shown."
var string tt_cov = "Data coverage and model confidence.\n\nWhat does it show?\nThe first value shows how many of the relevant pieces of information for this instrument are currently actually usable. The second value combines that data coverage with the available price history into a cautious model confidence value.\n\nHow is it determined?\nDifferent building blocks count depending on the instrument:\n• Stock: relative strength + earnings quality + trend\n• ETF: relative strength + trend\n• Index: relative strength + trend\n• Bond: relative strength + trend\n• Other market: relative strength + trend\n\nImportant:\nHigh values mainly mean that the model is working on a broader and technically more usable data base. This is not a direct seal of quality for the conceptual plausibility of every individual fundamental metric.\n\nHow should it be read?\nHigh values = more stable calculation base.\nLow values = read the result more cautiously, even if the total score looks decent."
var string tt_hist = "The history status of the instrument.\n\nHow is it evaluated?\nThe script checks whether enough price history is available for 63, 126, 200, and 252 trading days. Only with sufficient history can relative strength, trend, and distances be calculated cleanly.\n\nHow should it be read?\n• Complete = good data base\n• Limited = some parts are usable, others only with limitations\n• Too short = the signal is significantly less reliable"

// === HILFE & ERKLAERUNGEN ===================================================
i_help_chart   = input.bool(false, I_HELP_CHART, tooltip=tt_chart, group=G_HELP)
i_help_signale = input.bool(false, I_HELP_SIGNALE, tooltip=tt_signale, group=G_HELP)
i_help_empfehlung = input.bool(false, I_HELP_EMPFEHLUNG, tooltip=tt_empfehlung, group=G_HELP)
i_help_action  = input.bool(false, I_HELP_ACTION, tooltip=tt_action, group=G_HELP)

// === INPUTS =================================================================
bench_mode      = input.string(S_AUTO, I_BENCH_MODE, options=[S_AUTO, S_MANUELL], group=G_MARKET)
bench_manual    = input.symbol(DEFAULT_BENCHMARK, I_BENCH_MANUAL, group=G_MARKET)

w_rs            = input.float(0.50, I_W_RS, step=0.05, minval=0, maxval=1, tooltip=tt_w_rs, group=G_SETTINGS)
w_earn          = input.float(0.35, I_W_EARN, step=0.05, minval=0, maxval=1, tooltip=tt_w_earn, group=G_SETTINGS)
w_trend         = input.float(0.15, I_W_TREND, step=0.05, minval=0, maxval=1, tooltip=tt_w_trend, group=G_SETTINGS)

thr_S           = input.float(0.80, I_THR_STRONG, step=0.05, tooltip=tt_thr_S, group=G_THRESHOLDS)
thr_A           = input.float(0.65, I_THR_GOOD, step=0.05, tooltip=tt_thr_A, group=G_THRESHOLDS)
thr_B           = input.float(0.50, I_THR_WATCH, step=0.05, tooltip=tt_thr_B, group=G_THRESHOLDS)
thr_F           = input.float(0.30, I_THR_FAIL, step=0.05, tooltip=tt_thr_F, group=G_THRESHOLDS)

use_filter      = input.bool(true, I_USE_FILTER, tooltip=tt_filter, group=G_FILTER)
max_dd60d_pct   = input.float(-25.0, I_MAX_DD, step=1, tooltip=tt_max_dd, group=G_FILTER)
min_avg_vol_usd = input.float(5e6, I_MIN_VOL, step=1e6, tooltip=tt_min_vol, group=G_FILTER)

asset_mode_in   = input.string(S_AUTO, I_ASSET_MODE, options=[S_AUTO, S_AKTIE_IN, S_ETF_INDEX_IN, S_ANLEIHE_IN, S_OTHER_IN], tooltip=tt_mode, group=G_MARKET)
min_cov_buy     = input.float(0.70, I_MIN_COV_BUY, step=0.05, minval=0, maxval=1, tooltip=tt_cov, group=G_MARKET)
min_cov_watch   = input.float(0.45, I_MIN_COV_WATCH, step=0.05, minval=0, maxval=1, tooltip=tt_cov, group=G_MARKET)
min_hist_bars   = input.int(252, I_MIN_HIST, minval=50, tooltip=tt_hist, group=G_MARKET)
strict_bench    = input.bool(true, I_STRICT_BENCH, tooltip=tt_bench, group=G_MARKET)

table_pos       = input.string(S_TOPRIGHT, I_TABLE_POS, options=[S_TOPRIGHT, S_MIDDLERIGHT, S_BOTTOMRIGHT, S_TOPLEFT, S_MIDDLELEFT, S_BOTTOMLEFT], tooltip=tt_tbl_pos, group=G_DISPLAY)
table_sz        = input.string(S_SMALL, I_TABLE_SIZE, options=[S_TINY, S_SMALL, S_NORMAL, S_LARGE], tooltip=tt_tbl_sz, group=G_DISPLAY)
show_bg         = input.bool(false, I_SHOW_BG, tooltip=tt_show_bg, group=G_DISPLAY)
show_legend     = input.bool(false, I_SHOW_LEGEND, group=G_DISPLAY)

// === DAILY-DATEN ============================================================
d_close  = request.security(syminfo.tickerid, "D", close,  lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
d_high   = request.security(syminfo.tickerid, "D", high,   lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
d_low    = request.security(syminfo.tickerid, "D", low,    lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
d_volume = request.security(syminfo.tickerid, "D", volume, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)
float d_bench  = na
d_atr    = request.security(syminfo.tickerid, "D", ta.atr(14), lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off)

// === HILFSFUNKTIONEN ========================================================
winsor(float v, float lo, float hi) =>
    na(v) ? na : math.max(math.min(v, hi), lo)

clamp01(float v) =>
    math.max(math.min(v, 1), 0)

f_bool_score(bool cond, float w) =>
    cond ? w : 0.0

f_has_hist(series float s, int barsBack) =>
    not na(s[barsBack])

// === FARBEN & HILFSFUNKTIONEN ===============================================
color bg_label   = #131722
color bg_value   = #1E222D
color txt_main   = #FFFFFF
color col_none   = #2A2E39
color col_info   = #2962FF
color col_green  = #00C853
color col_lime   = #64DD17
color col_yellow = #FFD600
color col_orange = #FF6D00
color col_red    = #D50000

score_col(float s) =>
    na(s) ? col_none : s >= 0.80 ? col_green : s >= 0.65 ? col_lime : s >= 0.50 ? col_yellow : s >= 0.30 ? col_orange : col_red

f_pct(float v) =>
    na(v) ? S_NA : (v >= 0 ? S_PLUS : S_EMPTY) + str.tostring(v, "0.0") + S_PERCENT

f_mult(float v) =>
    na(v) ? S_NA : str.tostring(v, "0.00") + S_MULT

f_roe(float v) =>
    na(v) ? S_NA : v > 50 ? S_GT_50_PERCENT : (v >= 0 ? S_PLUS : S_EMPTY) + str.tostring(v, "0.0") + S_PERCENT

f_de(float v) =>
    na(v) ? S_NA : str.tostring(v, "0.00") + S_MULT

f_dist(float raw) =>
    if na(raw)
        S_NA
    else
        float pct = (raw - 1.0) * 100.0
        (pct >= 0 ? S_PLUS : S_EMPTY) + str.tostring(pct, "0.0") + S_PERCENT

col_eps(float v) =>
    na(v) ? col_none : v > 25 ? col_green : v >= 0 ? col_yellow : v >= -25 ? col_orange : col_red

col_rev(float v) =>
    na(v) ? col_none : v > 15 ? col_green : v >= 0 ? col_yellow : v >= -15 ? col_orange : col_red

col_roe(float v) =>
    na(v) ? col_none : v > 25 ? col_green : v >= 10 ? col_yellow : v >= 0 ? col_orange : col_red

col_de(float v) =>
    na(v) ? col_none : v < 0.5 ? col_green : v < 1.5 ? col_yellow : v < 3.0 ? col_orange : col_red

col_peg(float v) =>
    na(v) ? col_none : v < 0 ? col_red : v < 1.0 ? col_green : v < 2.0 ? col_yellow : col_orange

col_fcf(float v) =>
    na(v) ? col_none : v > 8 ? col_green : v >= 4 ? col_lime : v >= 0 ? col_orange : col_red

col_dist(float r) =>
    if na(r)
        col_none
    else
        float p = (r - 1.0) * 100.0
        p >= -10.0 ? col_green : p >= -20.0 ? col_yellow : p >= -35.0 ? col_orange : col_red

// === INSTRUMENT-MODUS =======================================================
bool has_sector   = not na(syminfo.sector) and syminfo.sector != ""
bool has_industry = not na(syminfo.industry) and syminfo.industry != ""
bool has_volume   = not na(d_volume)

string ticker_upper      = str.upper(syminfo.ticker)
string tickerid_upper    = str.upper(syminfo.tickerid)
string description_upper = str.upper(syminfo.description)
string type_upper        = str.upper(syminfo.type)
string prefix_upper_mode = str.upper(syminfo.prefix)

bool looks_crypto =
     str.contains(tickerid_upper, "CRYPTO:") or
     type_upper == "CRYPTO" or
     str.contains(description_upper, "BITCOIN") or
     str.contains(description_upper, "ETHEREUM") or
     str.contains(ticker_upper, "BTC") or
     str.contains(ticker_upper, "ETH") or
     str.contains(ticker_upper, "SOL") or
     str.contains(ticker_upper, "XRP") or
     str.contains(ticker_upper, "ADA") or
     str.contains(ticker_upper, "DOGE") or
     str.contains(ticker_upper, "BNB") or
     str.contains(ticker_upper, "AVAX")

bool is_bitcoin =
     str.contains(tickerid_upper, "BTC") or
     str.contains(ticker_upper, "BTC") or
     str.contains(description_upper, "BITCOIN")

bool looks_fx =
     str.contains(tickerid_upper, "FX:") or
     str.contains(tickerid_upper, "OANDA:") or
     str.contains(tickerid_upper, "FOREXCOM:") or
     type_upper == "FOREX"

bool looks_commodity =
     type_upper == "FUTURES" or
     str.contains(description_upper, "GOLD") or
     str.contains(description_upper, "SILVER") or
     str.contains(description_upper, "CRUDE") or
     str.contains(description_upper, "OIL") or
     str.contains(description_upper, "NATURAL GAS")

bool looks_index =
     type_upper == "INDEX" or
     str.contains(tickerid_upper, "TVC:") or
     str.contains(description_upper, "INDEX")

bool looks_bond =
     type_upper == "BOND" or
     str.contains(description_upper, "BOND") or
     str.contains(description_upper, "ANLEIHE") or
     str.contains(description_upper, "TREASURY") or
     str.contains(description_upper, "T-NOTE") or
     str.contains(description_upper, "TREASURY NOTE") or
     str.contains(description_upper, "BUND") or
     str.contains(description_upper, "GILT") or
     str.contains(description_upper, "SCHATZ")

bool looks_etf =
     (type_upper == "FUND" or
     str.contains(description_upper, "ETF") or
     str.contains(description_upper, "ETN")) and not looks_bond

bool looks_stock_by_exchange =
     str.contains(prefix_upper_mode, "NASDAQ") or
     str.contains(prefix_upper_mode, "NYSE") or
     str.contains(prefix_upper_mode, "AMEX") or
     str.contains(prefix_upper_mode, "TSX") or
     str.contains(prefix_upper_mode, "TSXV") or
     str.contains(prefix_upper_mode, "XETR") or
     str.contains(prefix_upper_mode, "FWB") or
     str.contains(prefix_upper_mode, "LSE") or
     str.contains(prefix_upper_mode, "ASX") or
     str.contains(prefix_upper_mode, "NSE") or
     str.contains(prefix_upper_mode, "BSE") or
     str.contains(prefix_upper_mode, "HKEX") or
     str.contains(prefix_upper_mode, "SSE") or
     str.contains(prefix_upper_mode, "SZSE") or
     str.contains(prefix_upper_mode, "KRX") or
     str.contains(prefix_upper_mode, "KOSDAQ") or
     str.contains(prefix_upper_mode, "TWSE") or
     str.contains(prefix_upper_mode, "TPEX") or
     str.contains(prefix_upper_mode, "SGX") or
     str.contains(prefix_upper_mode, "BMV") or
     str.contains(prefix_upper_mode, "BMFBOVESPA") or
     str.contains(prefix_upper_mode, "JSE") or
     str.contains(prefix_upper_mode, "SIX") or
     str.contains(prefix_upper_mode, "OMX")

bool auto_other_like =
     looks_crypto or looks_fx or looks_commodity

bool auto_bond_like =
     not auto_other_like and looks_bond

bool auto_index_like =
     not auto_other_like and not auto_bond_like and looks_index and not looks_etf

bool auto_etf_like =
     not auto_other_like and not auto_bond_like and not auto_index_like and looks_etf

bool auto_equity_like =
     not auto_other_like and not auto_bond_like and not auto_index_like and not auto_etf_like and
     (has_sector or has_industry or looks_stock_by_exchange)

string asset_class =
     looks_crypto      ? S_MODE_KRYPTO :
     looks_fx          ? S_MODE_FOREX :
     looks_commodity   ? S_MODE_ROHSTOFF :
     auto_bond_like    ? S_MODE_BOND :
     auto_index_like   ? S_MODE_INDEX :
     auto_etf_like     ? S_MODE_ETF :
     auto_equity_like  ? S_MODE_AKTIE :
                         S_MODE_ETF

string asset_mode =
     asset_mode_in == S_AKTIE_IN     ? S_MODE_AKTIE :
     asset_mode_in == S_ETF_INDEX_IN ? (asset_class == S_MODE_INDEX ? S_MODE_INDEX : S_MODE_ETF) :
     asset_mode_in == S_ANLEIHE_IN   ? S_MODE_BOND :
     asset_mode_in == S_OTHER_IN     ? asset_class :
                                       asset_class

bool mode_equity    = asset_mode == S_MODE_AKTIE
bool mode_etf       = asset_mode == S_MODE_ETF
bool mode_index     = asset_mode == S_MODE_INDEX
bool mode_bond      = asset_mode == S_MODE_BOND
bool mode_crypto    = asset_mode == S_MODE_KRYPTO
bool mode_fx        = asset_mode == S_MODE_FOREX
bool mode_commodity = asset_mode == S_MODE_ROHSTOFF
bool mode_other     = mode_crypto or mode_fx or mode_commodity

bool use_bench_rs = mode_equity or mode_etf or mode_index or mode_bond or (mode_crypto and not is_bitcoin)

// === BENCHMARK-LOGIK ========================================================
string prefix_upper = str.upper(syminfo.prefix)
string desc_upper   = str.upper(syminfo.description)
string country_upper = str.upper(syminfo.country)
string cur_upper     = str.upper(syminfo.currency)

bool is_japan =
     str.contains(prefix_upper, "TSE") or str.contains(country_upper, "JAPAN") or cur_upper == "JPY"

bool is_korea =
     str.contains(prefix_upper, "KRX") or str.contains(prefix_upper, "KOSDAQ") or
     str.contains(country_upper, "KOREA") or str.contains(country_upper, "SOUTH KOREA") or cur_upper == "KRW"

bool is_china =
     str.contains(prefix_upper, "SSE") or str.contains(prefix_upper, "SZSE") or
     str.contains(country_upper, "CHINA") or cur_upper == "CNY"

bool is_hongkong =
     str.contains(prefix_upper, "HKEX") or str.contains(country_upper, "HONG KONG") or cur_upper == "HKD"

bool is_taiwan =
     str.contains(prefix_upper, "TWSE") or str.contains(prefix_upper, "TPEX") or
     str.contains(country_upper, "TAIWAN") or cur_upper == "TWD"

bool is_india =
     str.contains(prefix_upper, "NSE") or str.contains(prefix_upper, "BSE") or
     str.contains(country_upper, "INDIA") or cur_upper == "INR"

bool is_australia =
     str.contains(prefix_upper, "ASX") or str.contains(country_upper, "AUSTRALIA") or cur_upper == "AUD"

bool is_singapore =
     str.contains(prefix_upper, "SGX") or str.contains(country_upper, "SINGAPORE") or cur_upper == "SGD"

bool is_germany =
     str.contains(prefix_upper, "XETR") or str.contains(prefix_upper, "FWB") or
     str.contains(country_upper, "GERMANY")

bool is_france =
     (str.contains(prefix_upper, "EURONEXT") and str.contains(desc_upper, "PARIS")) or
     str.contains(country_upper, "FRANCE")

bool is_netherlands =
     (str.contains(prefix_upper, "EURONEXT") and str.contains(desc_upper, "AMSTERDAM")) or
     str.contains(country_upper, "NETHERLANDS")

bool is_spain =
     str.contains(prefix_upper, "BME") or str.contains(country_upper, "SPAIN")

bool is_italy =
     str.contains(prefix_upper, "MIL") or str.contains(country_upper, "ITALY")

bool is_switzerland =
     str.contains(prefix_upper, "SIX") or str.contains(country_upper, "SWITZERLAND") or cur_upper == "CHF"

bool is_sweden =
     str.contains(prefix_upper, "OMXSTO") or str.contains(country_upper, "SWEDEN") or cur_upper == "SEK"

bool is_denmark =
     str.contains(prefix_upper, "OMXCOP") or str.contains(country_upper, "DENMARK") or cur_upper == "DKK"

bool is_norway =
     str.contains(prefix_upper, "OSE") or str.contains(country_upper, "NORWAY") or cur_upper == "NOK"

bool is_finland =
     str.contains(prefix_upper, "OMXHEX") or str.contains(country_upper, "FINLAND")

bool is_uk =
     str.contains(prefix_upper, "LSE") or str.contains(country_upper, "UNITED KINGDOM") or
     str.contains(country_upper, "UK") or cur_upper == "GBP"

bool is_canada =
     str.contains(prefix_upper, "TSX") or str.contains(prefix_upper, "TSXV") or
     str.contains(country_upper, "CANADA") or cur_upper == "CAD"

bool is_brazil =
     str.contains(prefix_upper, "BMFBOVESPA") or str.contains(country_upper, "BRAZIL") or cur_upper == "BRL"

bool is_mexico =
     str.contains(prefix_upper, "BMV") or str.contains(country_upper, "MEXICO") or cur_upper == "MXN"

bool is_south_africa =
     str.contains(prefix_upper, "JSE") or str.contains(country_upper, "SOUTH AFRICA") or cur_upper == "ZAR"

bool is_us =
     str.contains(prefix_upper, "NASDAQ") or str.contains(prefix_upper, "NYSE") or
     str.contains(prefix_upper, "AMEX") or str.contains(country_upper, "UNITED STATES")

string auto_bench_primary =
     mode_crypto and not is_bitcoin ? "CRYPTO:BTCUSD" :
     mode_fx or mode_commodity      ? na :
     mode_bond and is_us            ? "TVC:US10Y" :
     mode_bond and is_germany       ? "TVC:DE10Y" :
     mode_bond and is_uk            ? "TVC:UK10Y" :
     mode_bond and is_japan         ? "TVC:JP10Y" :
     mode_bond and is_canada        ? "TVC:CA10Y" :
     mode_bond                      ? "TVC:US10Y" :
     is_us                          ? "SPY" :
     is_canada                      ? "TSX:TSX" :
     is_germany                     ? "XETR:DAX" :
     is_france                      ? "TVC:CAC40" :
     is_netherlands                 ? "EURONEXT:AEX" :
     is_spain                       ? "TVC:IBEX35" :
     is_italy                       ? "TVC:FTMIB" :
     is_switzerland                 ? "TVC:SMI" :
     is_uk                          ? "TVC:UKX" :
     is_sweden                      ? "OMXSTO:OMXS30" :
     is_denmark                     ? "OMXCOP:OMXC25" :
     is_norway                      ? "OSE:OBX" :
     is_finland                     ? "OMXHEX:OMXH25" :
     is_japan                       ? "TVC:NI225" :
     is_korea                       ? "TVC:KOSPI" :
     is_china                       ? "TVC:SHCOMP" :
     is_hongkong                    ? "HSI:HSI" :
     is_taiwan                      ? "TWSE:TAIEX" :
     is_india                       ? "NSE:NIFTY" :
     is_australia                   ? "ASX:XJO" :
     is_singapore                   ? "SGX:STI" :
     is_brazil                      ? "BMFBOVESPA:IBOV" :
     is_mexico                      ? "BMV:ME" :
     is_south_africa                ? "JSE:J200" :
     mode_etf                       ? "ACWI" :
     mode_equity                    ? "ACWI" :
     na

string auto_bench_fallback =
     mode_crypto and not is_bitcoin ? "BTCUSD" :
     mode_fx or mode_commodity      ? na :
     mode_bond                      ? "TVC:US10Y" :
     is_us                          ? "AMEX:SPY" :
     mode_etf                       ? "AMEX:ACWI" :
     mode_equity                    ? "AMEX:ACWI" :
     na

string bench_candidate = bench_mode == S_MANUELL ? str.tostring(bench_manual) : auto_bench_primary

float d_bench_primary =
     not na(bench_candidate) ?
     request.security(bench_candidate, "D", close, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off, ignore_invalid_symbol=true) :
     na

float d_bench_fallback =
     not na(auto_bench_fallback) and na(d_bench_primary) and bench_mode == S_AUTO ?
     request.security(auto_bench_fallback, "D", close, lookahead=barmerge.lookahead_off, gaps=barmerge.gaps_off, ignore_invalid_symbol=true) :
     na

string bench_use =
     bench_mode == S_MANUELL ? str.tostring(bench_manual) :
     not na(d_bench_primary) ? bench_candidate :
     not na(d_bench_fallback) ? auto_bench_fallback :
     na

d_bench := not na(d_bench_primary) ? d_bench_primary : d_bench_fallback

// === HISTORIE ===============================================================
bool hist_252 = f_has_hist(d_close, 252)
bool hist_200 = f_has_hist(d_close, 200)
bool hist_126 = f_has_hist(d_close, 126)
bool hist_63  = f_has_hist(d_close, 63)

bool hist_meets_full =
     min_hist_bars >= 252 ? hist_252 and hist_200 :
     min_hist_bars >= 200 ? hist_200 :
     min_hist_bars >= 126 ? hist_126 :
     hist_63

bool hist_meets_min =
     min_hist_bars >= 252 ? hist_126 and hist_63 :
     min_hist_bars >= 200 ? hist_126 and hist_63 :
     min_hist_bars >= 126 ? hist_63 :
     true

bool hist_ok_full = hist_meets_full
bool hist_ok_min  = hist_meets_min

float hist_score = hist_ok_full ? 1.0 : hist_ok_min ? 0.6 : 0.2
string hist_txt = hist_ok_full ? S_HIST_FULL : hist_ok_min ? S_HIST_LIMITED : S_HIST_SHORT

// === MARKT-REGIME ===========================================================
bench_exists   = not na(d_bench)
bench_sma200   = ta.sma(d_bench, 200)
bench_regime_ok = bench_exists and not na(bench_sma200)

bench_valid = bench_exists
bull_market = bench_regime_ok and d_bench > bench_sma200

// === FAKTOR 1: RELATIVE STAERKE =============================================
ar_12_1 = hist_252 and nz(d_close[252]) != 0 ? (d_close[21] / d_close[252] - 1) * 100 : na
br_12_1 = use_bench_rs and bench_exists and hist_252 and nz(d_bench[252]) != 0 ? (d_bench[21] / d_bench[252] - 1) * 100 : na
ex_12_1 = use_bench_rs ? (not na(ar_12_1) and not na(br_12_1) ? ar_12_1 - br_12_1 : na) : ar_12_1

ar_6m   = hist_126 and nz(d_close[126]) != 0 ? (d_close / d_close[126] - 1) * 100 : na
br_6m   = use_bench_rs and bench_exists and hist_126 and nz(d_bench[126]) != 0 ? (d_bench / d_bench[126] - 1) * 100 : na
ex_6m   = use_bench_rs ? (not na(ar_6m) and not na(br_6m) ? ar_6m - br_6m : na) : ar_6m

ar_3m   = hist_63 and nz(d_close[63]) != 0 ? (d_close / d_close[63] - 1) * 100 : na
br_3m   = use_bench_rs and bench_exists and hist_63 and nz(d_bench[63]) != 0 ? (d_bench / d_bench[63] - 1) * 100 : na
ex_3m   = use_bench_rs ? (not na(ar_3m) and not na(br_3m) ? ar_3m - br_3m : na) : ar_3m

hh_252d   = ta.highest(d_close, 252)
dist_52wh = hist_252 and nz(hh_252d) != 0 ? d_close / hh_252d : na
rs_line = use_bench_rs ? (bench_exists and nz(d_bench) != 0 ? d_close / d_bench : na) : d_close
rs_slope  = not na(rs_line) and not na(rs_line[50]) and nz(rs_line[50]) != 0 ? (rs_line - rs_line[50]) / rs_line[50] * 100 : na

pr_12_1_raw   = ta.percentrank(ex_12_1, 252)
pr_6m_raw     = ta.percentrank(ex_6m, 252)
pr_3m_raw     = ta.percentrank(ex_3m, 252)
pr_dist_raw   = ta.percentrank(dist_52wh, 252)
pr_rslope_raw = ta.percentrank(rs_slope, 252)

pr_12_1   = na(ex_12_1)   ? na : pr_12_1_raw / 100
pr_6m     = na(ex_6m)     ? na : pr_6m_raw / 100
pr_3m     = na(ex_3m)     ? na : pr_3m_raw / 100
pr_dist   = na(dist_52wh) ? na : pr_dist_raw / 100
pr_rslope = na(rs_slope)  ? na : pr_rslope_raw / 100

rs_cov_n = (na(pr_12_1)?0:1) + (na(pr_6m)?0:1) + (na(pr_3m)?0:1) + (na(pr_dist)?0:1) + (na(pr_rslope)?0:1)
rs_cov   = rs_cov_n / 5.0

float rs_score_raw = rs_cov_n > 0 ? clamp01(
     (na(pr_12_1)?0:0.40*pr_12_1) +
     (na(pr_6m)?0:0.20*pr_6m) +
     (na(pr_3m)?0:0.15*pr_3m) +
     (na(pr_dist)?0:0.15*pr_dist) +
     (na(pr_rslope)?0:0.10*pr_rslope)
     ) / ((na(pr_12_1)?0:0.40)+(na(pr_6m)?0:0.20)+(na(pr_3m)?0:0.15)+(na(pr_dist)?0:0.15)+(na(pr_rslope)?0:0.10)) : na

float rs_score_smooth = ta.ema(rs_score_raw, 5)
rs_score = mode_index ? rs_score_smooth : rs_score_raw

// === FAKTOR 2: GEWINN-QUALITAET =============================================
eps_growth_yoy = mode_equity ? request.financial(syminfo.tickerid, "EARNINGS_PER_SHARE_BASIC_ONE_YEAR_GROWTH", "FQ", ignore_invalid_symbol=true) : na

rev_growth_fq  = mode_equity ? request.financial(syminfo.tickerid, "TOTAL_REVENUE_ONE_YEAR_GROWTH", "FQ", ignore_invalid_symbol=true) : na
rev_growth_ttm = mode_equity ? request.financial(syminfo.tickerid, "TOTAL_REVENUE_ONE_YEAR_GROWTH", "TTM", ignore_invalid_symbol=true) : na
rev_growth_yoy = not na(rev_growth_fq) ? rev_growth_fq : not na(rev_growth_ttm) ? rev_growth_ttm : na

roe_ttm  = mode_equity ? request.financial(syminfo.tickerid, "RETURN_ON_EQUITY", "TTM", ignore_invalid_symbol=true) : na
roe_fy   = mode_equity ? request.financial(syminfo.tickerid, "RETURN_ON_EQUITY", "FY", ignore_invalid_symbol=true) : na
ni_ttm   = mode_equity ? request.financial(syminfo.tickerid, "NET_INCOME", "TTM", ignore_invalid_symbol=true) : na
eq_fq    = mode_equity ? request.financial(syminfo.tickerid, "TOTAL_EQUITY", "FQ", ignore_invalid_symbol=true) : na
roe_calc = not na(ni_ttm) and not na(eq_fq) and eq_fq > 0 ? ni_ttm / eq_fq * 100 : na
roe_raw  = not na(roe_ttm) ? roe_ttm : not na(roe_fy) ? roe_fy : roe_calc
roe_capped = winsor(roe_raw, -50, 50)

total_debt = mode_equity ? request.financial(syminfo.tickerid, "TOTAL_DEBT", "FQ", ignore_invalid_symbol=true) : na
total_eq   = mode_equity ? request.financial(syminfo.tickerid, "TOTAL_EQUITY", "FQ", ignore_invalid_symbol=true) : na
de_ratio   = not na(total_debt) and not na(total_eq) and total_eq > 0 ? total_debt / total_eq : na

fcf_ttm   = mode_equity ? request.financial(syminfo.tickerid, "FREE_CASH_FLOW", "TTM", ignore_invalid_symbol=true) : na
shares    = mode_equity ? request.financial(syminfo.tickerid, "TOTAL_SHARES_OUTSTANDING", "FQ", ignore_invalid_symbol=true) : na
mcap_now  = not na(shares) and shares > 0 ? close * shares : na
fcf_yield = not na(fcf_ttm) and not na(mcap_now) and mcap_now > 0 ? fcf_ttm / mcap_now * 100 : na

pe_ratio    = mode_equity ? request.financial(syminfo.tickerid, "PRICE_EARNINGS", "FQ", ignore_invalid_symbol=true) : na
peg_extreme = not na(eps_growth_yoy) and math.abs(eps_growth_yoy) > 100
peg_raw     = not na(pe_ratio) and not na(eps_growth_yoy) and eps_growth_yoy != 0 ? pe_ratio / eps_growth_yoy : na
peg_ratio   = peg_extreme ? na : peg_raw

eps_w     = winsor(eps_growth_yoy, -50, 75)
rev_w     = winsor(rev_growth_yoy, -30, 50)
eps_score = na(eps_w)      ? na : clamp01((eps_w + 50) / 125)
rev_score = na(rev_w)      ? na : clamp01((rev_w + 30) / 80)
roe_score = na(roe_capped) ? na : clamp01(roe_capped / 30)

earn_cov_n        = (na(eps_score)?0:1) + (na(rev_score)?0:1) + (na(roe_score)?0:1)
earn_cov          = earn_cov_n / 3.0
earn_sum_w        = (na(eps_score)?0:0.50) + (na(rev_score)?0:0.30) + (na(roe_score)?0:0.20)
earn_sum          = (na(eps_score)?0:0.50*eps_score) + (na(rev_score)?0:0.30*rev_score) + (na(roe_score)?0:0.20*roe_score)
earn_available_raw = earn_sum_w > 0
earn_available     = mode_equity and earn_available_raw
earn_score         = earn_available ? earn_sum / earn_sum_w : na

// === EARNINGS IN X TAGEN ====================================================
next_earn_ts = mode_equity ? request.financial(syminfo.tickerid, "EARNINGS_RELEASE_NEXT_DATE", "FQ", ignore_invalid_symbol=true) : na
days_to_earn = not na(next_earn_ts) ? math.floor((next_earn_ts - time) / 86400000) : na

is_earn_soon   = mode_equity and not na(days_to_earn) and days_to_earn >= 0 and days_to_earn < 5
is_earn_window = mode_equity and not na(days_to_earn) and days_to_earn >= 0 and days_to_earn < 14

bgcolor(is_earn_soon   ? color.new(color.orange, 85) : na, title=PLOT_EARN_SOON)
bgcolor(is_earn_window ? color.new(color.yellow, 93) : na, title=PLOT_EARN_WINDOW)

// === FAKTOR 3: TREND-QUALITAET ==============================================
sma50d   = ta.sma(d_close, 50)
sma200d  = ta.sma(d_close, 200)
above200 = not na(sma200d) and d_close > sma200d
golden   = not na(sma50d) and not na(sma200d) and sma50d > sma200d
hh_60d   = ta.highest(d_close, 60)
dd_60d   = nz(hh_60d) != 0 ? (d_close / hh_60d - 1) * 100 : na

atr_pct   = nz(d_close) != 0 and not na(d_atr) ? d_atr / d_close * 100 : na
dd_thresh = not na(atr_pct) ? math.min(max_dd60d_pct, -2.5 * atr_pct) : max_dd60d_pct
dd_ok     = not na(dd_60d) and dd_60d >= dd_thresh

trend_cov_n = (not na(sma200d)?1:0) + (not na(sma50d) and not na(sma200d)?1:0) + (not na(hh_60d)?1:0)
trend_cov   = trend_cov_n / 3.0

dist_sma200_pct = not na(sma200d) and sma200d != 0 ? (d_close / sma200d - 1) * 100 : na
ma_spread_pct   = not na(sma50d) and not na(sma200d) and sma200d != 0 ? (sma50d / sma200d - 1) * 100 : na

trend_above_score  = na(dist_sma200_pct) ? na : clamp01((dist_sma200_pct + 10.0) / 20.0)
trend_golden_score = na(ma_spread_pct)   ? na : clamp01((ma_spread_pct + 5.0) / 10.0)
trend_dd_score     = na(dd_60d) or na(dd_thresh) ? na : clamp01((dd_60d - dd_thresh) / math.max(math.abs(dd_thresh), 0.01))

trend_sum_w =
     (na(trend_above_score)  ? 0 : 0.40) +
     (na(trend_golden_score) ? 0 : 0.30) +
     (na(trend_dd_score)     ? 0 : 0.30)

trend_sum =
     (na(trend_above_score)  ? 0 : 0.40 * trend_above_score) +
     (na(trend_golden_score) ? 0 : 0.30 * trend_golden_score) +
     (na(trend_dd_score)     ? 0 : 0.30 * trend_dd_score)

trend_score = trend_sum_w > 0 ? clamp01(trend_sum / trend_sum_w) : na

// === SICHERHEITS-FILTER =====================================================
avg_vol_usd = ta.sma(d_close * d_volume, 20)

bool vol_valid_equity = not na(avg_vol_usd) and avg_vol_usd >= min_avg_vol_usd
bool vol_valid_etf    = not na(avg_vol_usd) and avg_vol_usd >= min_avg_vol_usd

bool filter_pass_equity = vol_valid_equity and dd_ok and above200
bool filter_pass_etf    = (dd_ok and above200) and (not has_volume or vol_valid_etf)
bool filter_pass_bond   = dd_ok and above200
bool filter_pass_index  = dd_ok and above200
bool filter_pass_other  = dd_ok and above200

bool filter_pass =
     mode_equity ? filter_pass_equity :
     mode_etf    ? filter_pass_etf :
     mode_bond   ? filter_pass_bond :
     mode_index  ? filter_pass_index :
     filter_pass_other

// === COVERAGE / CONFIDENCE ==================================================
float cov_rs    = rs_cov
float cov_earn  = mode_equity ? earn_cov : na
float cov_trend = trend_cov

float coverage_total =
     mode_equity ? cov_rs * 0.45 + nz(cov_earn) * 0.35 + cov_trend * 0.20 :
     mode_etf    ? cov_rs * 0.65 + cov_trend * 0.35 :
     mode_bond   ? cov_rs * 0.65 + cov_trend * 0.35 :
     mode_index  ? cov_rs * 0.65 + cov_trend * 0.35 :
     cov_rs * 0.65 + cov_trend * 0.35

float confidence = clamp01(0.50 * coverage_total + 0.50 * hist_score)

bool rs_has_min_data   = not na(rs_score) and cov_rs >= 0.40
bool bench_is_required = mode_equity or mode_etf or mode_index or mode_bond or (mode_crypto and not is_bitcoin)
bool bench_is_usable   = use_bench_rs ? bench_exists : true
bool can_use_rs        = rs_has_min_data and (not use_bench_rs or bench_is_usable)

bool can_use_earn  = mode_equity and earn_available
bool can_use_trend = trend_cov > 0

// === GESAMT-SCORE ===========================================================
float eff_w_rs    = can_use_rs ? w_rs : 0.0
float eff_w_earn  = can_use_earn ? w_earn : 0.0
float eff_w_trend = can_use_trend ? w_trend : 0.0

if not mode_equity
    eff_w_earn := 0.0

float w_sum      = eff_w_rs + eff_w_earn + eff_w_trend
float rs_part    = can_use_rs ? rs_score : 0.0
float earn_part  = can_use_earn ? earn_score : 0.0
float trend_part = can_use_trend ? trend_score : 0.0

float master_raw = w_sum > 0 ? clamp01((eff_w_rs*rs_part + eff_w_earn*earn_part + eff_w_trend*trend_part) / w_sum) : na
float master_smooth = ta.ema(master_raw, 3)
float master        = mode_index ? master_smooth : master_raw

// === GATES ==================================================================
bool gate_hist       = hist_ok_full
bool gate_cov_buy    = coverage_total >= min_cov_buy
bool gate_cov_watch  = coverage_total >= min_cov_watch
bool gate_bench      = bench_is_required ? (strict_bench ? bench_exists : true) : true
bool gate_conf       = confidence >= min_cov_buy
bool gate_conf_watch = confidence >= min_cov_watch

bool gate_strong_rs    = can_use_rs and rs_score >= 0.75
bool gate_strong_trend = can_use_trend and trend_score >= 0.70
bool gate_strong_conf  = confidence >= math.max(min_cov_buy, 0.80)
bool gate_strong_cov   = coverage_total >= math.max(min_cov_buy, 0.80)
bool gate_strong_dd    = dd_60d >= math.max(dd_thresh, -12.0)
bool gate_strong_earn  = not mode_equity or (can_use_earn and earn_score >= 0.60)

bool buy_gate_good =
     gate_hist and
     gate_cov_buy and
     gate_bench and
     gate_conf and
     (not use_filter or filter_pass)

bool buy_gate_strong =
     buy_gate_good and
     gate_strong_rs and
     gate_strong_trend and
     gate_strong_conf and
     gate_strong_cov and
     gate_strong_dd and
     gate_strong_earn

bool watch_gate =
     gate_cov_watch and
     hist_ok_min and
     gate_conf_watch and
     gate_bench

// === BERECHNUNGEN VOR DEN PLOTS =============================================
score_mom_raw = bar_index >= 20 and not na(master) and not na(master[20]) ? master - master[20] : na
score_mom     = ta.sma(score_mom_raw, 3)

bool score_above_A_2bars = master >= thr_A and master[1] >= thr_A
bool score_above_S_2bars = master >= thr_S and master[1] >= thr_S
bool score_rising_3bars  = not na(master) and not na(master[3]) and master > master[3]

// Vorberechnete Hochs für Konsistenz
float price_high_20_prev  = ta.highest(d_close, 20)[1]
float price_high_60_prev  = ta.highest(d_close, 60)[1]
float master_high_20_prev = ta.highest(master, 20)[1]

bool new_price_high_20 = not na(price_high_20_prev) and d_close >= price_high_20_prev
bool new_price_high_60 = not na(price_high_60_prev) and d_close >= price_high_60_prev

bool good_confirm =
     buy_gate_good and
     score_above_A_2bars

bool strong_confirm =
     buy_gate_strong and
     score_above_S_2bars and
     score_rising_3bars and
     score_mom > 0 and
     new_price_high_20

bool score_falling_short = not na(master) and not na(master[3]) and master <= master[3]
bool score_not_confirming_high = not na(master) and not na(master_high_20_prev) and master < master_high_20_prev

divergence_warn =
     hist_ok_min and
     gate_cov_watch and
     new_price_high_20 and
     score_not_confirming_high and
     score_falling_short

// === PLOTS ==================================================================
color master_col = score_col(master)

plot(master, tt_rib_master, color=master_col, linewidth=3)
plot(rs_score, tt_rib_rs, color=color.new(color.blue, 20))
plot(mode_equity and earn_available ? earn_score : na, tt_rib_earn, color=color.new(color.orange, 20))
plot(score_mom, tt_rib_mom, color=color.new(color.white, 20))

// === SIGNALE ================================================================
buy_sig =
     good_confirm and
     not good_confirm[1] and
     not strong_confirm

strong_buy_sig =
     strong_confirm and
     not strong_confirm[1]

exit_sig =
     master < thr_A and
     master[1] >= thr_A and
     hist_ok_min and
     gate_cov_watch

plotshape(buy_sig,         SIG_BUY,        shape.arrowup,      location.bottom, color.new(col_green, 0),  size=size.small,  display=display.pane)
plotshape(exit_sig,        SIG_EXIT,       shape.arrowdown,    location.top,    color.new(col_red, 0),    size=size.small,  display=display.pane)
plotchar(strong_buy_sig,   title=SIG_BUY_STRONG, char="★", location=location.bottom, color=color.new(col_green, 0), size=size.tiny, display=display.pane)
plotshape(divergence_warn, SIG_DIVERGENZ,  shape.triangledown, location.top,    color.new(color.orange, 0), size=size.tiny, display=display.pane)

// === EMPFEHLUNG =============================================================
string tier_txt   = S_REC_AVOID
string action_txt = S_ACT_AVOID
color tier_col    = color.new(#D50000, 0)

if strong_confirm
    tier_txt   := S_REC_BUY_STRONG
    action_txt := S_ACT_BUY_STRONG
    tier_col   := color.new(#00C853, 0)
else if good_confirm
    tier_txt   := S_REC_BUY_GOOD
    action_txt := S_ACT_BUY_GOOD
    tier_col   := color.new(#64DD17, 0)
else if master >= thr_B and watch_gate
    tier_txt   := S_REC_WATCH
    action_txt := S_ACT_WATCH
    tier_col   := color.new(#FFD600, 0)
else if coverage_total < min_cov_watch or not hist_ok_min
    tier_txt   := S_REC_WEAK_DATA
    action_txt := S_ACT_WEAK_DATA
    tier_col   := color.new(#FF6D00, 0)
else if master >= thr_F
    tier_txt   := S_REC_NEUTRAL
    action_txt := S_ACT_NEUTRAL
    tier_col   := color.new(#FF6D00, 0)

// === SCHWELLEN-LINIEN =======================================================
hS = hline(thr_S, HLINE_STRONG, color=color.new(color.green, 30), linestyle=hline.style_dashed, linewidth=2)
hA = hline(thr_A, HLINE_GOOD,   color=color.new(color.green, 50), linestyle=hline.style_dashed)
hB = hline(thr_B, HLINE_WATCH,  color=color.new(color.yellow, 50), linestyle=hline.style_dotted)
hF = hline(thr_F, HLINE_FAIL,   color=color.new(color.red, 50), linestyle=hline.style_dashed)
hZ = hline(0,     S_EMPTY,      color=color.new(color.red, 100), linestyle=hline.style_dotted)
fill(hA, hS, color=color.new(color.green, 90))
fill(hF, hZ, color=color.new(color.red, 93))

// === HINTERGRUND ============================================================
bgcolor(na, title=PLOT_BG_MARKET)

// === ANZEIGEVARIABLEN =======================================================
string peg_txt = na(peg_ratio) ? "–" : f_mult(peg_ratio)
color  peg_bg  = na(peg_ratio) ? col_none : col_peg(peg_ratio)

string fcf_txt = f_pct(fcf_yield)
color  fcf_bg  = na(fcf_yield) ? col_none : col_fcf(fcf_yield)

// === EARNINGS-ANZEIGE =======================================================
string earn_txt = S_NA
color earn_bg   = col_none

if mode_equity and not na(days_to_earn)
    if days_to_earn < 0
        earn_txt := S_EARN_RECENT
        earn_bg  := color.new(#3A3D44, 0)
    else if days_to_earn == 0
        earn_txt := S_EARN_TODAY
        earn_bg  := col_red
    else if days_to_earn <= 9
        earn_txt := S_IN_PREFIX + str.tostring(days_to_earn) + S_IN_SUFFIX
        earn_bg  := col_orange
    else if days_to_earn <= 30
        earn_txt := S_IN_PREFIX + str.tostring(days_to_earn) + S_IN_SUFFIX
        earn_bg  := bg_value
    else
        earn_txt := S_IN_PREFIX + str.tostring(days_to_earn) + S_IN_SUFFIX
        earn_bg  := col_green

string trend_txt =
     (above200 ? S_CHECK : S_CROSS) + S_TREND_SMA200 +
     (golden   ? S_CHECK : S_CROSS) + S_TREND_GC +
     (dd_ok    ? S_CHECK : S_CROSS) + S_TREND_DD

string vol_unit = avg_vol_usd >= 1e12 ? S_VOL_BIO : avg_vol_usd >= 1e9 ? S_VOL_MRD : S_VOL_MIO
vol_div  = avg_vol_usd >= 1e12 ? 1e12 : avg_vol_usd >= 1e9 ? 1e9 : 1e6
vol_txt  = na(avg_vol_usd) ? S_DASH : str.tostring(avg_vol_usd / vol_div, "0.00") + " " + vol_unit
vol_bg   = mode_equity ? (na(avg_vol_usd) or avg_vol_usd < min_avg_vol_usd ? col_red : bg_value) : bg_value

string cov_txt = str.tostring(coverage_total, "0.00") + " / " + str.tostring(confidence, "0.00")
color cov_bg = confidence >= min_cov_buy ? col_green : confidence >= min_cov_watch ? col_yellow : col_orange

// === MODUS-SPEZIFISCHE TABELLENANZEIGE ======================================
string na_mode_txt = S_DASH
color  na_mode_bg  = col_none

string sector_display =
     mode_equity ? (na(syminfo.sector) or syminfo.sector == "" ? S_DASH : str.upper(syminfo.sector)) :
     mode_bond   ? MODE_SECTOR_BOND :
     mode_etf    ? MODE_SECTOR_ETF :
     asset_mode == S_MODE_FOREX    ? MODE_SECTOR_FOREX :
     asset_mode == S_MODE_KRYPTO   ? MODE_SECTOR_KRYPTO :
     asset_mode == S_MODE_ROHSTOFF ? MODE_SECTOR_ROHSTOFF :
     mode_other  ? MODE_SECTOR_OTHER :
     S_DASH

string industry_display =
     mode_equity ? (na(syminfo.industry) or syminfo.industry == "" ? S_DASH : str.upper(syminfo.industry)) :
     mode_bond   ? MODE_INDUSTRY_BOND :
     mode_etf    ? MODE_INDUSTRY_ETF :
     asset_mode == S_MODE_FOREX    ? MODE_INDUSTRY_FOREX :
     asset_mode == S_MODE_KRYPTO   ? MODE_INDUSTRY_KRYPTO :
     asset_mode == S_MODE_ROHSTOFF ? MODE_INDUSTRY_ROHSTOFF :
     mode_other  ? MODE_INDUSTRY_OTHER :
     S_DASH

string earn_score_display = mode_equity and can_use_earn ? str.tostring(earn_score, "0.00") : na_mode_txt
color  earn_score_bg      = mode_equity and can_use_earn ? score_col(earn_score) : na_mode_bg
string eps_txt = f_pct(eps_growth_yoy)
color  eps_bg  = na(eps_growth_yoy) ? col_none : col_eps(eps_growth_yoy)

string rev_txt = f_pct(rev_growth_yoy)
color  rev_bg  = na(rev_growth_yoy) ? col_none : col_rev(rev_growth_yoy)

string roe_txt = f_roe(roe_raw)
color  roe_bg  = na(roe_raw) ? col_none : col_roe(roe_raw)

string de_txt = f_de(de_ratio)
color  de_bg  = na(de_ratio) ? col_none : col_de(de_ratio)

string eps_txt_display = mode_equity ? eps_txt : na_mode_txt
color  eps_bg_display  = mode_equity ? eps_bg  : na_mode_bg

string rev_txt_display = mode_equity ? rev_txt : na_mode_txt
color  rev_bg_display  = mode_equity ? rev_bg  : na_mode_bg

string roe_txt_display = mode_equity ? roe_txt : na_mode_txt
color  roe_bg_display  = mode_equity ? roe_bg  : na_mode_bg

string de_txt_display = mode_equity ? de_txt : na_mode_txt
color  de_bg_display  = mode_equity ? de_bg  : na_mode_bg

string fcf_txt_display = mode_equity ? fcf_txt : na_mode_txt
color  fcf_bg_display  = mode_equity ? fcf_bg  : na_mode_bg

string peg_txt_display = mode_equity ? peg_txt : na_mode_txt
color  peg_bg_display  = mode_equity ? peg_bg  : na_mode_bg

string bench_display = bench_exists and not na(bench_use) ? str.tostring(bench_use) : S_DASH
color  bench_bg      = bench_exists and not na(bench_use) ? bg_value : na_mode_bg

string vol_label =
     mode_equity ? ROW_VOL_EQUITY :
     mode_etf    ? ROW_VOL_ETF :
     mode_bond   ? ROW_VOL_BOND :
     mode_index  ? ROW_VOL_INDEX :
                   ROW_VOL_OTHER

string vol_txt_display =
     (mode_index and na(avg_vol_usd)) ? S_DASH :
     na(avg_vol_usd) ? S_DASH :
     str.tostring(avg_vol_usd / vol_div, "0.00") + S_SPACE + vol_unit

color vol_bg_display =
     mode_equity ? vol_bg :
     mode_etf    ? vol_bg :
     mode_index  ? na_mode_bg :
                   na_mode_bg

string filter_txt = filter_pass ? S_FILTER_PASS : S_FILTER_FAIL
color  filter_bg  = filter_pass ? col_green : col_red

if mode_index or mode_fx or mode_commodity
    filter_txt := filter_pass ? S_FILTER_TREND_OK : S_FILTER_TREND_WEAK
    filter_bg  := filter_pass ? col_green : col_red
else if not bench_exists and strict_bench and bench_is_required
    filter_txt := S_FILTER_BENCH_MISSING
    filter_bg  := col_orange

string earn_row_txt = earn_txt
color  earn_row_bg  = earn_bg

bool use_market_regime = mode_equity or mode_etf or mode_index

string market_regime_txt =
     not use_market_regime ? S_DASH :
     not bench_regime_ok   ? S_DASH :
     bull_market           ? S_MARKET_POSITIVE :
                             S_MARKET_WEAK

color market_regime_bg =
     not use_market_regime ? col_none :
     not bench_regime_ok   ? col_none :
     bull_market           ? col_green :
                             col_red

// === TABELLEN-SETUP =========================================================
tbl_position = switch table_pos
    S_TOPRIGHT    => position.top_right
    S_MIDDLERIGHT => position.middle_right
    S_BOTTOMRIGHT => position.bottom_right
    S_TOPLEFT     => position.top_left
    S_MIDDLELEFT  => position.middle_left
    => position.bottom_left

tbl_size = switch table_sz
    S_TINY   => size.tiny
    S_SMALL  => size.small
    S_NORMAL => size.normal
    => size.large

var table tbl = table.new(position.top_right, 2, 23, border_width=1, border_color=#363A45)

if barstate.islast
    table.set_position(tbl, tbl_position)

string row_earnings_label =
     mode_equity ? ROW_EARNINGS_EQUITY : ROW_EARNINGS_GENERIC

string row_earn_label =
     mode_equity ? ROW_EARN_EQUITY : ROW_EARN_GENERIC

string row_eps_label =
     mode_equity ? ROW_EPS_EQUITY : ROW_EPS_GENERIC

string row_rev_label =
     mode_equity ? ROW_REV_EQUITY : ROW_REV_GENERIC

string row_roe_label =
     mode_equity ? ROW_ROE_EQUITY : ROW_ROE_GENERIC

string row_de_label =
     mode_equity ? ROW_DE_EQUITY : ROW_DE_GENERIC

string row_fcf_label = ROW_FCF
string row_peg_label = ROW_PEG

if barstate.islast
    table.cell(tbl, 0, 0,  ROW_SEKTOR, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 0,  sector_display, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, tooltip=tt_sektor)

    table.cell(tbl, 0, 1,  ROW_INDUSTRIE, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 1,  industry_display, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, tooltip=tt_industrie)

    table.cell(tbl, 0, 2,  ROW_MODUS, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 2,  asset_mode, bgcolor=bg_value, text_color=txt_main, text_size=tbl_size, tooltip=tt_mode)

    table.cell(tbl, 0, 3,  ROW_HISTORIE, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 3,  hist_txt, bgcolor=score_col(hist_score), text_color=txt_main, text_size=tbl_size, tooltip=tt_hist)

    table.cell(tbl, 0, 4,  ROW_COVERAGE, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 4,  cov_txt, bgcolor=cov_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_cov)

    table.cell(tbl, 0, 5,  row_earnings_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 5,  earn_row_txt, bgcolor=earn_row_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_earn_days)

    table.cell(tbl, 0, 6,  ROW_GESAMT, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 6,  na(master) ? S_NA : str.tostring(master, "0.00"), bgcolor=score_col(master), text_color=txt_main, text_size=tbl_size, tooltip=tt_master)

    table.cell(tbl, 0, 7,  ROW_RS, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 7,  can_use_rs ? str.tostring(rs_score, "0.00") : S_NA, bgcolor=can_use_rs ? score_col(rs_score) : na_mode_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_rs)

    table.cell(tbl, 0, 8,  ROW_TREND, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 8,  trend_txt, bgcolor=score_col(trend_score), text_color=txt_main, text_size=tbl_size, tooltip=tt_trend)

    table.cell(tbl, 0, 9,  ROW_DIST_ATH, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 9,  f_dist(dist_52wh), bgcolor=col_dist(dist_52wh), text_color=txt_main, text_size=tbl_size, tooltip=tt_dist)

    table.cell(tbl, 0, 10, row_earn_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 10, earn_score_display, bgcolor=earn_score_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_earn)

    table.cell(tbl, 0, 11, row_eps_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 11, eps_txt_display, bgcolor=eps_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_eps)

    table.cell(tbl, 0, 12, row_rev_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 12, rev_txt_display, bgcolor=rev_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_rev)

    table.cell(tbl, 0, 13, row_roe_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 13, roe_txt_display, bgcolor=roe_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_roe)

    table.cell(tbl, 0, 14, row_de_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 14, de_txt_display, bgcolor=de_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_de)

    table.cell(tbl, 0, 15, row_fcf_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 15, fcf_txt_display, bgcolor=fcf_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_fcf)

    table.cell(tbl, 0, 16, row_peg_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 16, peg_txt_display, bgcolor=peg_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_peg)

    table.cell(tbl, 0, 17, vol_label, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 17, vol_txt_display, bgcolor=vol_bg_display, text_color=txt_main, text_size=tbl_size, tooltip=tt_vol)

    table.cell(tbl, 0, 18, ROW_BENCHMARK, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 18, bench_display, bgcolor=bench_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_bench)

    table.cell(tbl, 0, 19, ROW_MARKTREGIME, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 19, market_regime_txt, bgcolor=market_regime_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_markt_regime)

    table.cell(tbl, 0, 20, ROW_FILTER, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 20, filter_txt, bgcolor=filter_bg, text_color=txt_main, text_size=tbl_size, tooltip=tt_filter_row)

    //table.cell(tbl, 0, 21, ROW_EMPFEHLUNG, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    //table.cell(tbl, 1, 21, tier_txt, bgcolor=tier_col, text_color=txt_main, text_size=tbl_size, tooltip=tt_empfehlung)

    //table.cell(tbl, 0, 22, ROW_ACTION, bgcolor=bg_label, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    //table.cell(tbl, 1, 22, action_txt, bgcolor=bg_value, text_color=txt_main, text_size=tbl_size, tooltip=tt_action)

    table.cell(tbl, 0, 21, ROW_KURVEN,         bgcolor=col_info, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 21, ROW_KURVEN_VALUES, bgcolor=col_info, text_color=txt_main, text_size=tbl_size, tooltip=tt_chart)

    table.cell(tbl, 0, 22, ROW_SIGNALE,        bgcolor=col_info, text_color=txt_main, text_size=tbl_size, text_halign=text.align_left)
    table.cell(tbl, 1, 22, ROW_SIGNALE_VALUES, bgcolor=col_info, text_color=txt_main, text_size=tbl_size, tooltip=tt_signale)

// === CHART-LEGENDE ==========================================================
var table legend = table.new(
     position.bottom_left, 1, 7,
     bgcolor=color.new(color.black, 12),
     border_color=color.new(color.gray, 40), border_width=1,
     frame_color=color.new(color.gray, 40), frame_width=1)

if barstate.islast
    if show_legend
        table.cell(legend, 0, 0, LEGEND_TITLE, text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=color.new(color.blue, 70))
        table.cell(legend, 0, 1, LEGEND_1, text_color=color.yellow, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 2, LEGEND_2, text_color=color.blue, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 3, LEGEND_3, text_color=color.orange, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 4, LEGEND_4, text_color=color.white, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 5, LEGEND_5, text_color=color.lime, text_size=size.small, text_halign=text.align_left)
        table.cell(legend, 0, 6, LEGEND_6, text_color=color.orange, text_size=size.small, text_halign=text.align_left)
    else
        table.clear(legend, 0, 0, 0, 6)

// === ALERTS =================================================================
alertcondition(strong_buy_sig, ALERT_TITLE_STRONG_BUY, ALERT_MSG_STRONG_BUY)
alertcondition(buy_sig,        ALERT_TITLE_GOOD_BUY,   ALERT_MSG_GOOD_BUY)
alertcondition(ta.crossunder(master, thr_F), ALERT_TITLE_SELL, ALERT_MSG_SELL)
````
