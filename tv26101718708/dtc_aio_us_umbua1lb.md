# DTC AIO [US] 

- url: https://www.tradingview.com/script/umbuA1Lb-DTC-AIO-US/
- type: indicator
- pine_id: PUB;01e99d24ae584396a1a4b6add59fbf97
- version: 3.0

## Description

Why this is one tool, not a bundle of indicators

A stock's chart alone cannot tell you whether it is a genuine market leader. A rising 50-day average looks the same whether the earnings behind it are accelerating or shrinking; a strong-looking breakout looks the same whether the whole sector is moving or just that one ticker. Answering "is this a leader worth trading" requires checking several unrelated data sources against each other at the same time — the company's actual earnings, its price behavior relative to the market, how it behaves specifically when the market is under stress, and how it stacks up against the handful of stocks that compete with it. None of those four checks alone is reliable; a stock can look strong on any one of them and still not be a real leader. This script exists because doing that cross-check by hand — pulling up earnings, then flipping to a relative-strength chart, then manually building a peer watchlist — is slow and easy to skip. It runs all four checks against the same symbol on the same chart, automatically, and only then hands you the price-structure tools (moving averages, an anchored VWAP, pattern markers) needed to time an entry once that leadership case is actually made. The scoring engines are the reason this script exists; the timing tools are there so you are not forced to add three more indicators once you have your answer.

The four leadership checks

- Earnings engine. Quarterly or annual earnings and sales are pulled from TradingView's financial data and laid out in a MarketSmith-style grid: the primary metric (earnings per share, or net income if you prefer), its year-over-year percentage change, sales, and the sales percentage change, with optional gross-margin and return-on-equity rows. Year-over-year is measured against the same period one year earlier so seasonal businesses compare fairly. A year-over-year change measured off a negative prior-year base is flagged with a "#", the standard convention for marking a percentage that would otherwise be misleading (e.g. earnings improving from -$1.00 to -$0.10 is not really a "-90%" move).

- Relative strength versus the market. A relative-strength line is built by dividing the stock's price by a benchmark's price (SPY by default), then scaling that ratio so it plots alongside the stock's own price. A one-year percentile rank of that ratio produces a 1-99 "RS Rating" — this is the same underlying idea used by IBD's RS Rating (how a stock's performance ranks against the rest of the market over the past year), calculated independently here from price data rather than licensed from any provider.

- Relative strength during stress ("Panic RS"). This checks something the plain RS line does not: whether the stock is holding above its own short-term average on days when the benchmark itself is below its own short-term average — in other words, is this stock outperforming specifically while the broad market is under pressure. That is a materially different (and rarer) signal than simply outperforming during a rally, and it is flagged with its own marker.

- Burst score (volatility regime). Instead of a single volatility number like ATR, this counts how many days over a chosen lookback (3 months to 3 years) closed up 5%, 10% and 17% or more, then combines those three counts into one score. A stock that regularly produces large up-days behaves very differently from one that grinds slowly upward even if their average volatility looks similar, and that difference is often visible in this count before it shows up in a standard momentum indicator.

- Automatic peer comparison. The stock's industry (or sector, as a fallback) is matched against a built-in map of roughly 60 US industry groups, each with a curated list of representative peer tickers, and a comparison table is built automatically from that group — day, 1-month and 3-month return, relative volume, and an RS column for each peer, with the current symbol pinned at the top. The RS column ranks each peer's 3-month return against the OTHER peers actually shown in the table (a 0-100 scale, highest = strongest of the group) — a peer-group-relative read, deliberately not the same 1-year-vs-market calculation the main RS Rating uses, since ranking a handful of direct competitors against each other is the more useful comparison in a table built specifically to check group leadership. You are not expected to build or maintain your own watchlist of comparable stocks; the peer set is derived from the symbol you already have on the chart.

Timing tools (used once the leadership case is made, not standalone)

- Four configurable moving averages (simple, exponential or weighted; independent length, color and width) for the standard support/trend read.
- An anchored VWAP measured from the most recent all-time high forward, giving a volume-weighted "fair value" line for the current up-leg rather than an arbitrary fixed lookback.
- Average daily range percentage and relative volume, so a breakout can be judged against the stock's own normal range and normal volume rather than an absolute number.
- Pattern markers: inside bars, a simplified pocket-pivot flag (an up day of 5%+ on above-threshold volume), the lowest-volume day over a lookback (often precedes a move), "three weeks tight" closes (three consecutive weekly closes within a volatility-scaled band of each other, an IBD base-tightening pattern), and swing high/low pivot labels with optional percentage change between them.

Compact dashboard

A small, repositionable table (top-right by default) puts the numbers behind the leadership read in one place: RS Rating, relative volume, average daily range %, 3-month return, the burst score, and float %. A stretched average daily range (7% or more) or an already-extended 3-month return (80% or more) is flagged in red with a ⚠ marker as a "this has probably already moved a lot" caution. Market cap, free float, and average dollar volume are available as the earnings table's configurable top-left header cell instead of a separate panel, so they sit next to the earnings grid they help contextualize.

How to use it

1. Add it to a daily chart of a US stock.
2. Check the earnings grid and the RS line/rating first: you want rising year-over-year earnings and sales together with relative strength making new highs against the benchmark.
3. Check whether the Panic RS markers and burst score are present — that tells you whether the leadership is showing up specifically during market weakness, and whether the stock has the range profile of an actual leader rather than a slow grinder.
4. Check the peer table to confirm the stock is leading its own group, not just riding the index up.
5. Once those four checks line up, use the moving-average stack, the anchored VWAP and the pattern markers to time an entry near support, sizing with the daily-range and relative-volume readings.
6. Every block has its own on/off toggle, so the dashboard can be reduced to only the checks you personally use.

Notes

- Earnings, sales, margin, return on equity, and the market-cap/float figures come from TradingView's financial data and are only as complete as that data is for a given symbol; missing values show a dash rather than a misleading zero.
- Defaults assume US equities on a daily timeframe with a broad-market benchmark; the script will run on other markets and timeframes, but those defaults are US-equity-specific and not tuned for anything else.
- Tables and colors adapt automatically to a light or dark chart background.
- Open-source. Every input has a plain-language label and tooltip, so reading Pine is not required to use it.
- For educational and informational purposes only. Not financial advice.

## Source Code

````pine
//@version=6
// DTC AIO [US] — compact dashboard
// License: MPL-2.0 (https://mozilla.org/MPL/2.0/)

indicator('DTC [US]', overlay=true, behind_chart=false, max_lines_count=500, max_labels_count=500, max_boxes_count=500, dynamic_requests=true)

// =============================================================================
// INPUTS — grouped; corner placement only (no theme picker)
// =============================================================================
string gLayout = 'US Dashboard & Layout'
bool showMetricLegends = input.bool(true, 'Show hover legends (ⓘ)', group=gLayout, tooltip='Hover an info icon for a one-line metric explanation.')
bool showVolumeTable = input.bool(true, 'Show RVol / Volume table', group=gLayout, tooltip='Displays the dedicated RVol, current volume, and average volume table.')
string volumeTablePosition = input.string('Top Center', 'RVol / Volume table position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=gLayout)
string dashboardPosition = input.string('Top Right', 'Dashboard position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=gLayout, tooltip='Position of the compact dashboard.')
string earningsTableCorner = input.string('Middle Right', 'Earnings table position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=gLayout, tooltip='Position of the quarterly earnings table.')
string tableTextSize = input.string('Small', 'Universal table text size', options=['Tiny', 'Small', 'Normal'], group=gLayout, tooltip='Applies to the dashboard, RVol/Volume, and earnings tables.')
string chartLabelTextSize = input.string('Small', 'Chart label text size', options=['Tiny', 'Small', 'Normal'], group=gLayout)

string gSignals = 'US Leadership & Market Context'
bool showRsLeadership = input.bool(true, 'Show RS leadership', group=gSignals)
int rsLeadershipLength = input.int(63, 'RS / price high lookback (days)', minval=20, maxval=252, group=gSignals, tooltip='RS new high uses closing stock/index ratios; price high uses daily highs over the same prior window.')
bool showMarketTrend = input.bool(true, 'Show SPX / QQQ trend', group=gSignals, tooltip='Trend compares daily close with 21 EMA and 50 SMA; it is context, not a trade instruction.')
bool showAtrExtension = input.bool(true, 'Show ATR extension from 21 EMA', group=gSignals)
float atrExtensionCaution = input.float(3.0, 'Extension caution (ATR units)', minval=0.5, maxval=10, step=0.5, group=gSignals, tooltip='Highlights positive extension at or above this value; no universal threshold predicts a reversal.')

string gNoGap = 'No Gap Candles'
bool showNoGapCandles = input.bool(false, 'Show No Gap Candles', group=gNoGap, tooltip='Draws synthetic candles using the previous close as the open; indicator signals still use original OHLC prices.')
bool ngApplyToDayOpenOnly = input.bool(false, 'Apply To Day Open Only', group=gNoGap, tooltip='Only adjusts opens after a time gap greater than the threshold below.')
float ngDayChangeHourThreshold = input.float(6.0, 'Day Open Gap Threshold (Hours)', minval=0.0, group=gNoGap, tooltip='Elapsed hours between candle opening timestamps; this is a time-gap filter, not exchange session detection.')
bool ngShowPriceLine = input.bool(false, 'Show Current Price Line', group=gNoGap, tooltip='Shows a dotted current-price line while No Gap Candles is enabled.')
color ngBullishColor = input.color(color.rgb(41, 98, 255), 'Bullish Candle', group=gNoGap, inline='ngcolors')
color ngBearishColor = input.color(color.rgb(255, 82, 82), 'Bearish Candle', group=gNoGap, inline='ngcolors')

string gEarn = 'Earnings Table'
bool earningsTableEnabled = input.bool(false, 'Show table', group=gEarn)
string earningsPeriod = input.string('FQ', 'Period', options=['FQ', 'FY'], group=gEarn)
int earningsQuarters = input.int(4, 'Quarters shown', minval=4, maxval=8, group=gEarn)
string earningsTopLeft = input.string('FF', 'Top-left cell', options=['FF', 'Mcap'], group=gEarn)
bool earningsMiniMode = input.bool(false, 'Mini mode (YoY% only)', group=gEarn)
string earningsGrowthBasis = input.string('YoY', 'Growth basis', options=['YoY', 'QoQ'], group=gEarn)
bool showModelForecast = input.bool(false, 'Show Earnings/Sales Forecast', group=gEarn, tooltip='Transparent mechanical estimate from historical quarterly data. Not analyst consensus.')
string forecastMethod = input.string('YoY Growth', 'Forecast Method', options=['YoY Growth', 'Average Growth', 'Linear Trend', 'Conservative', 'Base', 'Aggressive'], group=gEarn)
int forecastQuarters = input.int(4, 'Forecast history quarters', minval=2, maxval=8, group=gEarn)
string forecastScenario = input.string('Base', 'Scenario', options=['Bear', 'Base', 'Bull'], group=gEarn)
bool showFYForecast = input.bool(false, 'Show FY Forecast', group=gEarn)
color forecastValueColor = input.color(color.new(#7aa2f7, 0), 'Forecast Value Color', group=gEarn)
float forecastBearAdjustment = input.float(-10.0, 'Bear growth adjustment (%)', minval=-100, maxval=100, step=1, group=gEarn)
float forecastBaseAdjustment = input.float(0.0, 'Base growth adjustment (%)', minval=-100, maxval=100, step=1, group=gEarn)
float forecastBullAdjustment = input.float(10.0, 'Bull growth adjustment (%)', minval=-100, maxval=100, step=1, group=gEarn)

string gMA = 'Moving Averages'
bool showMA1 = input.bool(true, 'MA 1', group=gMA, inline='ma1')
int ma1Len = input.int(10, '', group=gMA, inline='ma1')
string ma1Type = input.string('EMA', '', options=['SMA', 'EMA', 'WMA'], group=gMA, inline='ma1')
color ma1Color = input.color(color.new(#60a5fa, 0), '', group=gMA, inline='ma1')
int ma1Width = input.int(1, '', minval=1, maxval=4, group=gMA, inline='ma1')
bool showMA2 = input.bool(true, 'MA 2', group=gMA, inline='ma2')
int ma2Len = input.int(20, '', group=gMA, inline='ma2')
string ma2Type = input.string('EMA', '', options=['SMA', 'EMA', 'WMA'], group=gMA, inline='ma2')
color ma2Color = input.color(color.new(#f59e0b, 0), '', group=gMA, inline='ma2')
int ma2Width = input.int(1, '', minval=1, maxval=4, group=gMA, inline='ma2')
bool showMA3 = input.bool(true, 'MA 3', group=gMA, inline='ma3')
int ma3Len = input.int(50, '', group=gMA, inline='ma3')
string ma3Type = input.string('EMA', '', options=['SMA', 'EMA', 'WMA'], group=gMA, inline='ma3')
color ma3Color = input.color(color.new(#34d399, 0), '', group=gMA, inline='ma3')
int ma3Width = input.int(1, '', minval=1, maxval=4, group=gMA, inline='ma3')
bool showMA4 = input.bool(true, 'MA 4', group=gMA, inline='ma4')
int ma4Len = input.int(200, '', group=gMA, inline='ma4')
string ma4Type = input.string('EMA', '', options=['SMA', 'EMA', 'WMA'], group=gMA, inline='ma4')
color ma4Color = input.color(color.new(#f87171, 0), '', group=gMA, inline='ma4')
int ma4Width = input.int(2, '', minval=1, maxval=4, group=gMA, inline='ma4')

string gRS = '📈 Relative Strength'
string rsBenchmarkInput = input.symbol('SP:SPX', 'Benchmark', group=gRS, tooltip='S&P 500 cash index (SP:SPX) by default; used for the stock/index relative-strength ratio.')
bool showPanicRS = input.bool(false, 'Outperformance markers', group=gRS)
string panicIndexSymbol = input.symbol('SP:SPX', 'Panic index', group=gRS, tooltip='S&P 500 by default; marks daily stock strength while the index trades below its EMA.')
int panicEmaLen = input.int(20, 'Panic EMA', minval=1, group=gRS, inline='panicema')
int panicMarkerTransparency = input.int(15, 'Marker transparency', minval=0, maxval=100, step=5, group=gRS, tooltip='0 is fully opaque; 100 is invisible. Color adapts to the chart background.')

string gMom = '🌡️ Volatility'
int adrLength = input.int(14, 'ADR period (days)', minval=1, group=gMom)
int atrLength = input.int(14, 'ATR period (days)', minval=1, group=gMom, tooltip='Wilder-smoothed daily true range, including overnight gaps.')
string gVol = '📊 Volume & RVol'
string rvolDisplayMode = input.string('Percent', 'RVol value format', options=['Percent', 'Multiple'], group=gVol, tooltip='Displays the same RVol calculation as percent or a multiple.')
int relVolLen = input.int(21, 'RVol lookback (days)', minval=1, group=gVol)
string burstPeriod = input.string('3 Years', 'Burst lookback', options=['3 Months', '6 Months', '1 Year', '3 Years'], group=gMom, tooltip='Lookback window for counting burst days (5%/10%/17% moves). Shorter = more recent momentum, longer = track record view.')

string gPat = '🧩 Patterns'
bool showInsideBar = input.bool(false, 'Inside bar', group=gPat, inline='ib')
color insideBarColor = input.color(color.new(#d4a017, 0), '', group=gPat, inline='ib')
bool showPocketPivots = input.bool(true, 'Pocket pivots', group=gPat, inline='pp')
int pocketPivotMinVol = input.int(500000, 'Min vol', minval=0, step=100000, group=gPat, inline='pp', tooltip='Minimum daily volume for a pocket pivot to qualify.')
bool showLowestVolume = input.bool(true, 'Lowest-volume day', group=gPat, inline='lv')
int lowestVolumeLookback = input.int(20, 'lookback', minval=10, maxval=50, group=gPat, inline='lv')



string gVwap = '📏 Anchored VWAP'
bool showAnchoredVWAP = input.bool(false, 'Show', group=gVwap, inline='vwap')
int vwapWidth = input.int(2, 'Line thickness', minval=1, maxval=4, group=gVwap)

string gLab = '🏷️ Chart Labels'
bool enableArrowDisplay = input.bool(false, 'EPS arrows', group=gLab, inline='earrow')
bool useQoQForArrow = input.bool(false, 'QoQ', group=gLab, inline='earrow')
bool showSalesArrow = input.bool(false, 'Sales', group=gLab, inline='earrow')
bool enableDailyMoveLabel = input.bool(true, 'Day range % label', group=gLab, inline='dlopt')
bool showPDL = input.bool(true, 'Show PDL', group=gLab, inline='dlopt', tooltip='Show Previous Day range % alongside current day range in the label.')

string gHL = 'High/Low Points'
bool   hlShowPoints  = input.bool(false, 'Display H/L points', group=gHL)
int    hlPivotLen    = input.int(9, 'Pivot length', minval=2, maxval=30, group=gHL)
bool   hlShowPct     = input.bool(false, '% change', group=gHL)
color  hlPctPosColor = input.color(color.new(#39d353, 0), '+ %', group=gHL, inline='hlc')
color  hlPctNegColor = input.color(color.new(#ff5252, 0), '− %', group=gHL, inline='hlc')

string gPS = 'Position Sizing'
bool   psEnabled     = input.bool(false,  'Enable', group=gPS, tooltip='Calculates share quantity and capital allocation for four SL scenarios using your capital and risk-per-trade settings. Works best on the daily chart.')
float  psCapital     = input.float(100000, 'Capital (USD)', minval=1000, step=10000, group=gPS)
float  psRiskPct     = input.float(0.25,  'Risk per trade (%)', minval=0.05, maxval=5.0, step=0.05, group=gPS, tooltip='Max % of capital you are willing to lose on this trade.')
string psDirection   = input.string('Long', 'Direction', options=['Long', 'Short'], group=gPS)
bool   psShowLod     = input.bool(true,  'LOD',  group=gPS, inline='psshow')
bool   psShowPdl     = input.bool(true,  'PDL',  group=gPS, inline='psshow')
bool   psShowSl1     = input.bool(true,  'SL 1', group=gPS, inline='psshow')
bool   psShowSl2     = input.bool(true,  'SL 2', group=gPS, inline='psshow')
float  psSl1Pct      = input.float(2.0,   'SL 1 (%)', minval=0.1, maxval=30.0, step=0.1, group=gPS, inline='pssl')
float  psSl2Pct      = input.float(5.0,   'SL 2 (%)', minval=0.1, maxval=30.0, step=0.1, group=gPS, inline='pssl')
float  psMaxAllocPct = input.float(20.0,  'Warn alloc > (%)', minval=1.0, maxval=100.0, step=1.0, group=gPS, tooltip='Alloc % turns red when it exceeds this value.')

string gWM = 'Watermark'
bool showWatermark = input.bool(true, 'Show watermark', group=gWM)
bool wmShowTF = input.bool(true, 'Timeframe', group=gWM, inline='wmopt')
bool wmShowChange = input.bool(true, 'Day change%', group=gWM, inline='wmopt')
string wmSignature = input.string('DTC', 'Signature', group=gWM)
string wmTextSize = input.string('Large', 'Ticker size', options=['Small', 'Normal', 'Large', 'Huge'], group=gWM, tooltip='Size of the main ticker symbol in the watermark.')

string wmPosition = input.string('Bottom Center', 'Watermark position', options=['Top Left', 'Top Center', 'Top Right', 'Middle Left', 'Middle Center', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], group=gWM)

// =============================================================================
// Visual theme — inferred from chart background only
// =============================================================================
f_chart_is_dark() =>
    bg = chart.bg_color
    color.r(bg) + color.g(bg) + color.b(bg) <= 400

bool isDark = f_chart_is_dark()

color cleanTableBg          = isDark ? color.new(#101827, 12) : color.new(#ffffff, 8)
color cleanTableAltBg       = isDark ? color.new(#1b2638, 12) : color.new(#eef3f9, 8)
color cleanTableHeaderBg    = isDark ? color.new(#243a55, 0) : color.new(#dce8f5, 0)
color cleanTableText        = isDark ? color.new(#eaeaea, 0) : color.new(#1c1c1c, 0)
color cleanTableHeaderText  = cleanTableText
color usAccent = isDark ? #7dd3fc : #0369a1
color cleanTableBorder      = isDark ? #333333 : #cccccc
color cleanTablePositive    = isDark ? color.new(#26c96f, 0) : color.new(#0d6b2a, 0)
color cleanTableNegative    = isDark ? color.new(#ff5252, 0) : color.new(#c00000, 0)

color cleanTableAlert = isDark ? color.new(#ffcc66, 0) : color.new(#9a3412, 0)
color panicRsMarkerColor = isDark ? color.new(#ffffff, panicMarkerTransparency) : color.new(#1c1c1c, panicMarkerTransparency)

getCorner(string c) =>
    c == 'Top Right' ? position.top_right : position.bottom_right

// Full position map for earnings table & watermark
getTablePosition(string pos) =>
    switch pos
        'Top Left' => position.top_left
        'Top Center' => position.top_center
        'Top Right' => position.top_right
        'Middle Left' => position.middle_left
        'Middle Center' => position.middle_center
        'Middle Right' => position.middle_right
        'Bottom Left' => position.bottom_left
        'Bottom Center' => position.bottom_center
        'Bottom Right' => position.bottom_right
        => position.bottom_center

f_text_size(string s) =>
    s == 'Tiny' ? size.tiny : s == 'Normal' ? size.normal : size.small

string dashSz  = f_text_size(tableTextSize)
string labelSz  = f_text_size(chartLabelTextSize)

wm_getTimeFrame() =>
    float wm_tf = timeframe.multiplier
    string wm_tfstr = ''
    if timeframe.isseconds
        wm_tfstr := 's'
    if timeframe.isminutes
        if wm_tf >= 60
            wm_tf := wm_tf / 60
            wm_tfstr := 'h'
        else
            wm_tfstr := 'm'
    if timeframe.isdaily
        wm_tfstr := 'D'
    if timeframe.isweekly
        wm_tfstr := 'W'
    if timeframe.ismonthly
        wm_tfstr := 'M'
    [wm_tfstr, str.tostring(wm_tf)]

// MA helpers — inlined per slot so series state lives at top level, not in a function scope

formatVolume(float vol) =>
    na(vol) ? '-' : vol >= 1000000000 ? str.format('{0,number,0.00} B', vol / 1000000000) : vol >= 1000000 ? str.format('{0,number,0.00} M', vol / 1000000) : vol >= 1000 ? str.format('{0,number,0.00} K', vol / 1000) : str.format('{0,number,0}', vol)

f_table_row_bg(int row) =>
    row % 2 == 0 ? cleanTableBg : cleanTableAltBg

// Benchmark ticker is now set directly via input.symbol() — no mapping needed.



// === Optional No Gap Candles (visual only; original OHLC remains untouched) ===
float ngHoursSinceLastCandle = na(time[1]) ? na : (time - time[1]) / 3600000.0
bool ngRemoveGap = not ngApplyToDayOpenOnly or (not na(ngHoursSinceLastCandle) and ngHoursSinceLastCandle > ngDayChangeHourThreshold)
float ngOpen = ngRemoveGap and not na(close[1]) ? close[1] : open
float ngClose = close
// Include the synthetic open in the wick range, even when it lies outside the real bar.
float ngHigh = math.max(high, ngOpen, ngClose)
float ngLow = math.min(low, ngOpen, ngClose)
color ngCandleColor = ngClose >= ngOpen ? ngBullishColor : ngBearishColor

plotcandle(showNoGapCandles ? ngOpen : na, showNoGapCandles ? ngHigh : na, showNoGapCandles ? ngLow : na, showNoGapCandles ? ngClose : na, title='DTC No Gap Candles', color=ngCandleColor, bordercolor=ngCandleColor, wickcolor=ngCandleColor, editable=false)

var line ngCurrentPriceLine = na
if barstate.islast
    if showNoGapCandles and ngShowPriceLine
        if na(ngCurrentPriceLine)
            ngCurrentPriceLine := line.new(bar_index, close, bar_index + 1, close, extend=extend.both, style=line.style_dotted, width=1, color=ngCandleColor)
        else
            line.set_xy1(ngCurrentPriceLine, bar_index, close)
            line.set_xy2(ngCurrentPriceLine, bar_index + 1, close)
            line.set_color(ngCurrentPriceLine, ngCandleColor)
    else if not na(ngCurrentPriceLine)
        line.delete(ngCurrentPriceLine)
        ngCurrentPriceLine := na

// === Moving averages (user colors) ===
float ma1 = ma1Type == 'EMA' ? ta.ema(close, ma1Len) : ma1Type == 'WMA' ? ta.wma(close, ma1Len) : ta.sma(close, ma1Len)
float ma2 = ma2Type == 'EMA' ? ta.ema(close, ma2Len) : ma2Type == 'WMA' ? ta.wma(close, ma2Len) : ta.sma(close, ma2Len)
float ma3 = ma3Type == 'EMA' ? ta.ema(close, ma3Len) : ma3Type == 'WMA' ? ta.wma(close, ma3Len) : ta.sma(close, ma3Len)
float ma4 = ma4Type == 'EMA' ? ta.ema(close, ma4Len) : ma4Type == 'WMA' ? ta.wma(close, ma4Len) : ta.sma(close, ma4Len)
plot(showMA1 ? ma1 : na, color=ma1Color, title='MA 1', linewidth=ma1Width)
plot(showMA2 ? ma2 : na, color=ma2Color, title='MA 2', linewidth=ma2Width)
plot(showMA3 ? ma3 : na, color=ma3Color, title='MA 3', linewidth=ma3Width)
plot(showMA4 ? ma4 : na, color=ma4Color, title='MA 4', linewidth=ma4Width)

// === ADR & relative volume (intraday TF) ===
float adr = ta.sma(high - low, adrLength)
float adrPercent = adr / close * 100
[rvol_tf_vol, rvol_tf_avg] = request.security(syminfo.tickerid, 'D', [volume, ta.sma(volume[1], relVolLen)], lookahead=barmerge.lookahead_off)
float rvol_tf_pct = rvol_tf_avg > 0 ? math.round((rvol_tf_vol / rvol_tf_avg) * 100) : na
bool rvolIsExtreme = not na(rvol_tf_pct) and rvol_tf_pct >= 300

f_volume_display(float v) =>
    na(v) ? '-' : v >= 1000000 ? str.tostring(math.round(v / 1000000, 2)) + ' Mil' : str.tostring(math.round(v / 1000, 2)) + 'k'

float _atr14 = ta.atr(14)

// Marker lanes use the displayed wick range, including synthetic no-gap opens.
float displayedCandleLow = showNoGapCandles ? ngLow : low
float displayedCandleHigh = showNoGapCandles ? ngHigh : high
float candleMarkerPad = math.max(nz(_atr14, high - low) * 0.25, (displayedCandleHigh - displayedCandleLow) * 0.08, syminfo.mintick * 10)

// === Patterns ===
// Pocket pivot concept credit: Manas Arora. The existing definition is
// preserved, but the signal is now generated only on the daily timeframe.
bool isInsideBar = high < high[1] and low > low[1]
color insideBarCol = insideBarColor
float dailyMovePP = (close / close[1] - 1) * 100
bool isPocketPivot = timeframe.isdaily and dailyMovePP >= 5.0 and volume >= pocketPivotMinVol

// Purple pocket-pivot dots sit below the displayed wick, including no-gap candles.
bool showPocketPivotMarker = showPocketPivots and isPocketPivot
float pocketPivotMarkerY = displayedCandleLow - candleMarkerPad
plotshape(showPocketPivotMarker ? pocketPivotMarkerY : na, title='Pocket pivot', style=shape.circle, location=location.absolute, color=color.new(#7c3aed, 0), size=size.tiny)

[dailyVolume, panicStockEma] = request.security(syminfo.tickerid, 'D', [volume, ta.ema(close, panicEmaLen)], lookahead=barmerge.lookahead_off)
float currentVolume = volume
bool hasDailyData = not na(dailyVolume) and dailyVolume > 0
float volumeToUse = hasDailyData ? dailyVolume : currentVolume
int availableBars = bar_index + 1
int effectiveLookback = math.min(lowestVolumeLookback, availableBars)
float lowestVolCandidate = ta.lowest(volumeToUse, effectiveLookback)
int lowestVolOffsetCandidate = ta.lowestbars(volumeToUse, effectiveLookback)
float lowestVol = na
int lowestVolBarIndex = na
if not na(volumeToUse) and effectiveLookback > 0
    lowestVol := lowestVolCandidate
    if not na(lowestVol) and lowestVol > 0 and not na(lowestVolOffsetCandidate)
        lowestVolBarIndex := bar_index - lowestVolOffsetCandidate
bool isLowestVolume = showLowestVolume and not na(volumeToUse) and not na(lowestVol) and lowestVol > 0 and not na(lowestVolBarIndex) and bar_index >= lowestVolBarIndex and math.abs(volumeToUse - lowestVol) < 0.0001
color activeBarColor = na
if showInsideBar and isInsideBar
    activeBarColor := insideBarCol
barcolor(activeBarColor, title='Pattern highlights')
if isLowestVolume and (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
    label.new(bar_index, displayedCandleLow - candleMarkerPad * (showPocketPivotMarker ? 2.5 : 1.5), text=formatVolume(volumeToUse), style=label.style_none, color=color.new(color.black, 100), textcolor=cleanTableText, size=labelSz, xloc=xloc.bar_index, yloc=yloc.price)

// === Anchored VWAP ===
var float allTimeHigh = high
var int anchorBarIndex = na
var float cumulativeTPV = 0.0
var float cumulativeVolume = 0.0
bool isNewATH = high > allTimeHigh
if isNewATH
    allTimeHigh := high
    anchorBarIndex := bar_index
    float tp = (high + low + close) / 3.0
    cumulativeTPV := tp * volume
    cumulativeVolume := volume
else if not na(anchorBarIndex) and bar_index >= anchorBarIndex
    float tp2 = (high + low + close) / 3.0
    cumulativeTPV += tp2 * volume
    cumulativeVolume += volume
float anchorVWAP = na
if not na(anchorBarIndex) and bar_index >= anchorBarIndex and cumulativeVolume > 0
    anchorVWAP := cumulativeTPV / cumulativeVolume
color vwapCol = cleanTableText
plot(showAnchoredVWAP and not na(anchorVWAP) ? anchorVWAP : na, title='Anchored VWAP', color=vwapCol, linewidth=vwapWidth)

// Daily RS is calculated inside the daily stock context, including its benchmark request.
// Ranking the ratio here avoids ranking repeated daily samples on intraday charts.
f_us_daily_rs() =>
    float indexClose = request.security(rsBenchmarkInput, 'D', close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
    float ratio = indexClose > 0 ? close / indexClose : na
    float priorRsHigh = ta.highest(ratio[1], rsLeadershipLength)
    float priorPriceHigh = ta.highest(high[1], rsLeadershipLength)
    bool ready = not na(ratio[rsLeadershipLength]) and not na(high[rsLeadershipLength])
    bool rsHigh = ready and not na(ratio) and ratio > priorRsHigh
    bool priceHigh = ready and high > priorPriceHigh
    [ta.percentrank(ratio, 63), ready, rsHigh, rsHigh and not priceHigh]

[rs_rating, usRsReady, usRsNewHigh, usRsLeading] = request.security(syminfo.tickerid, 'D', f_us_daily_rs(), lookahead=barmerge.lookahead_off)

// === Panic RS (single marker style) ===
[panicIndexClose, panicIndexEma] = request.security(panicIndexSymbol, 'D', [close, ta.ema(close, panicEmaLen)])
bool isPanicRelativeStrength = panicIndexClose < panicIndexEma and close > panicStockEma
plotshape(showPanicRS and isPanicRelativeStrength and timeframe.isdaily ? displayedCandleHigh + candleMarkerPad : na, style=shape.cross, location=location.absolute, color=panicRsMarkerColor, size=size.tiny, title='Panic RS')

// === Financial series (dashboard, arrows, earnings table) ===
string financial01 = 'EPS'
string financial02 = 'Sales ($M)'
string financial01id = 'EARNINGS_PER_SHARE_DILUTED'
string financial02id = 'TOTAL_REVENUE'

float epsFinancialRaw = request.financial(syminfo.tickerid, financial01id, earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)
float salesFinancialRaw = request.financial(syminfo.tickerid, financial02id, earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)
float rev = salesFinancialRaw
float finData1 = epsFinancialRaw
float finData2 = salesFinancialRaw

int datasize = earningsQuarters + 5
var array<int> earningsDate = array.new_int(datasize)
var array<float> arrayFinData1 = array.new_float(datasize)
var array<float> arrayFinData2 = array.new_float(datasize)
var float lastRevSnapshot = na

f_array_int(array<int> arrayId, int val) =>
    array.unshift(arrayId, val)
    array.pop(arrayId)

f_array_float(array<float> arrayId, float val) =>
    array.unshift(arrayId, val)
    array.pop(arrayId)

bool hasRevData = not na(rev)
bool isNewEarningsPrint = hasRevData and (na(lastRevSnapshot) or rev != lastRevSnapshot)
if isNewEarningsPrint
    lastRevSnapshot := rev
    f_array_int(earningsDate, time)
    f_array_float(arrayFinData1, finData1)
    f_array_float(arrayFinData2, finData2)

f_yoy_change(float current, float previous) =>
    previous <= 0 ? na : (current - previous) / math.abs(previous) * 100

f_qoq_change(float current, float previous) =>
    previous == 0 ? na : (current - previous) / math.abs(previous) * 100

// Model forecast helpers. Financial arrays are newest-first; only completed
// observations already delivered by request.financial() are used.
f_average_yoy(array<float> vals, int history) =>
    float total = 0.0
    int samples = 0
    int maxPairs = math.min(history, array.size(vals) - 4)
    if maxPairs > 0
        for i = 0 to maxPairs - 1
            float cur = array.get(vals, i)
            float prior = array.get(vals, i + 4)
            if not na(cur) and not na(prior) and cur > 0 and prior > 0
                total += (cur / prior - 1) * 100
                samples += 1
    samples > 0 ? total / samples : na

f_safe_yoy(float current, float previous) =>
    not na(current) and not na(previous) and current > 0 and previous > 0 ? (current / previous - 1) * 100 : na

f_linear_growth(array<float> vals, int history) =>
    float sumX = 0.0
    float sumY = 0.0
    float sumXY = 0.0
    float sumXX = 0.0
    int samples = 0
    int maxPoints = math.min(history, array.size(vals))
    if maxPoints > 0
        for i = 0 to maxPoints - 1
            float value = array.get(vals, maxPoints - 1 - i)
            if not na(value) and value > 0
                float x = i
                sumX += x
                sumY += value
                sumXY += x * value
                sumXX += x * x
                samples += 1
    float denom = samples * sumXX - sumX * sumX
    float slope = samples >= 3 and denom != 0 ? (samples * sumXY - sumX * sumY) / denom : na
    float latest = array.get(vals, 0)
    not na(slope) and not na(latest) and latest > 0 ? slope / latest * 100 : na

f_forecast_rate(array<float> vals, string method, int history, float bearAdj, float baseAdj, float bullAdj, string scenario) =>
    float yoy = array.size(vals) > 4 ? f_safe_yoy(array.get(vals, 0), array.get(vals, 4)) : na
    float avg = f_average_yoy(vals, history)
    float linear = f_linear_growth(vals, history)
    float selected = switch method
        'YoY Growth' => yoy
        'Average Growth' => avg
        'Linear Trend' => linear
        'Conservative' => na(avg) ? na : avg + bearAdj
        'Aggressive' => na(avg) ? na : avg + bullAdj
        => na(avg) ? na : avg + baseAdj
    float scenarioAdj = method == 'Conservative' or method == 'Base' or method == 'Aggressive' ? 0 : scenario == 'Bear' ? bearAdj : scenario == 'Bull' ? bullAdj : baseAdj
    not na(selected) ? math.max(-95, selected + scenarioAdj) : na

float forecastSalesRate = f_forecast_rate(arrayFinData2, forecastMethod, forecastQuarters, forecastBearAdjustment, forecastBaseAdjustment, forecastBullAdjustment, forecastScenario)
float forecastEpsRate = f_forecast_rate(arrayFinData1, forecastMethod, forecastQuarters, forecastBearAdjustment, forecastBaseAdjustment, forecastBullAdjustment, forecastScenario)
float latestSales = array.get(arrayFinData2, 0)
float latestEps = array.get(arrayFinData1, 0)
float forecastSales = not na(latestSales) and latestSales > 0 and not na(forecastSalesRate) ? latestSales * (1 + forecastSalesRate / 100) : na
// EPS forecasts are deliberately withheld when the latest actual is zero or negative.
float forecastEps = not na(latestEps) and latestEps > 0 and not na(forecastEpsRate) ? latestEps * (1 + forecastEpsRate / 100) : na
bool enoughFYHistory = array.size(arrayFinData1) >= 8 and not na(array.get(arrayFinData1, 3)) and not na(array.get(arrayFinData2, 3))
float fySalesEstimate = enoughFYHistory and not na(forecastSales) ? array.get(arrayFinData2, 0) + array.get(arrayFinData2, 1) + array.get(arrayFinData2, 2) + forecastSales : na
float fyEpsEstimate = enoughFYHistory and not na(forecastEps) ? array.get(arrayFinData1, 0) + array.get(arrayFinData1, 1) + array.get(arrayFinData1, 2) + forecastEps : na

f_forecast_value(float value, string finID, string naText) =>
    float div = finID == 'EPS' ? 1 : 1000000
    string fmt = finID == 'EPS' ? '#.#' : '#,###.#'
    na(value) ? naText : str.tostring(value / div, fmt)

f_forecast_growth(float value) =>
    na(value) ? 'Insufficient data' : str.format('{0,number,+0.0;-0.0}%', value)

// Cache YoY/QoQ — only recompute when new earnings arrive (quarterly), not every bar
var float eps_yoy_q0   = na
var float sales_yoy_q0 = na
var float eps_qoq_q0   = na
var float sales_qoq_q0 = na

if isNewEarningsPrint
    float eps_q0   = array.get(arrayFinData1, 0)
    float sales_q0 = array.get(arrayFinData2, 0)
    float eps_q1   = array.get(arrayFinData1, 1)
    float sales_q1 = array.get(arrayFinData2, 1)
    float eps_q4   = array.get(arrayFinData1, 4)
    float sales_q4 = array.get(arrayFinData2, 4)
    eps_yoy_q0   := f_yoy_change(eps_q0, eps_q4)
    sales_yoy_q0 := f_yoy_change(sales_q0, sales_q4)
    eps_qoq_q0   := f_qoq_change(eps_q0, eps_q1)
    sales_qoq_q0 := f_qoq_change(sales_q0, sales_q1)

ft(table _t, int col, int row, string val) =>
    table.cell(_t, col, row, val, bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=dashSz)

ftdate(table _t, int col, int row, string val) =>
    string v = str.contains(val, '70') ? '' : val
    table.cell(_t, col, row, v, bgcolor=f_table_row_bg(row - 1), text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left)

fcell(string finID, table _t, int col, int row, array<float> vals, int idx) =>
    float div = finID == 'EPS' ? 1 : 1000000
    string sfx = finID == 'EPS' or finID == financial02 ? '' : ' M'
    string fmt = finID == 'EPS' ? '#.#' : finID == financial02 ? '#,###.#' : '#,##0'
    float v = array.get(vals, idx) / div
    table.cell(_t, col, row, na(v) ? '' : str.tostring(v, fmt) + sfx, text_color=cleanTableText, text_size=dashSz, bgcolor=f_table_row_bg(row - 1))

fyoy(table _t, int col, int row, array<float> vals, int idx, int cmpr) =>
    float dif = 0.0
    string sym = ''
    float val1 = array.get(vals, idx)
    float val2 = array.get(vals, idx + cmpr)
    val1 := val1 == 0 ? 1 : val1
    val2 := math.round(val2, 1) == 0 or math.round(val2, 1) == -0 ? 0.1 : val2
    dif := math.round((val1 - val2) / math.abs(val2) * 100)
    sym := na(dif) ? '' : dif > 0 ? '+' + str.tostring(dif) + '%' : str.tostring(dif) + '%'
    color tc = na(dif) ? cleanTableText : dif > 0 ? cleanTablePositive : dif < 0 ? cleanTableNegative : cleanTableText
    string disp = na(dif) or sym == '' ? '-' : sym
    table.cell(_t, col, row, disp, text_halign=text.align_right, text_color=tc, text_size=dashSz, bgcolor=f_table_row_bg(row - 1))

float free_float_raw = request.financial(syminfo.tickerid, 'FLOAT_SHARES_OUTSTANDING', 'FY', ignore_invalid_symbol=true)
float outstanding = request.financial(syminfo.tickerid, 'TOTAL_SHARES_OUTSTANDING', 'FY', ignore_invalid_symbol=true)
var string validated_ff = ''
var string validated_mc = ''
if barstate.islast
    float ff = na(free_float_raw) or free_float_raw <= 0 ? na : free_float_raw * close
    validated_ff := na(ff) or ff <= 0 ? '' : '$' + formatVolume(ff)
    float mc = na(outstanding) or outstanding <= 0 ? na : outstanding * close
    validated_mc := na(mc) or mc <= 0 ? '' : '$' + formatVolume(mc)

// === Burst score ===
// Concept credit: finallynitin
f_get_burst_cutoff_time(string period) =>
    y = year(timenow)
    m = month(timenow)
    d = dayofmonth(timenow)
    switch period
        '3 Months' => m := m - 3
        '6 Months' => m := m - 6
        '1 Year' => y := y - 1
        => y := y - 3
    if m <= 0
        y := y - 1
        m := m + 12
    timestamp(y, m, d, 0, 0)

// All rolling calculations execute in daily context, even on weekly/intraday charts.
f_us_daily_metrics() =>
    int cutoff = f_get_burst_cutoff_time(burstPeriod)
    float move = close[1] > 0 ? (close / close[1] - 1) * 100 : na
    float c5 = ta.cum(time >= cutoff and move >= 5 ? 1.0 : 0.0)
    float c10 = ta.cum(time >= cutoff and move >= 10 ? 1.0 : 0.0)
    float c17 = ta.cum(time >= cutoff and move >= 17 ? 1.0 : 0.0)
    float downVol = math.sum(close < close[1] ? volume : 0.0, 50)
    float upVol = math.sum(close > close[1] ? volume : 0.0, 50)
    float peak = ta.highest(high, 64)
    float peakReturn = close[63] > 0 ? (peak / close[63] - 1) * 100 : na
    [ta.atr(atrLength), close, ta.sma(high - low, adrLength), ta.sma(close * volume, 20), ta.ema(close, 21), downVol > 0 ? upVol / downVol : na, peakReturn, math.round(c5 / 5 + c10 / 2 + c17 / 0.5)]

[usDailyAtr, usDailyClose, usDailyAdr, usDailyDollarVol, usDailyEma21, usDailyUdRatio, usDailyPeakReturn, usDailyBurst] = request.security(syminfo.tickerid, 'D', f_us_daily_metrics(), lookahead=barmerge.lookahead_off)
// Current daily values can develop until the session closes; no future lookahead.
[usSpxClose, usSpxEma21, usSpxSma50] = request.security('SP:SPX', 'D', [close, ta.ema(close, 21), ta.sma(close, 50)], lookahead=barmerge.lookahead_off)
[usQqqClose, usQqqEma21, usQqqSma50] = request.security('NASDAQ:QQQ', 'D', [close, ta.ema(close, 21), ta.sma(close, 50)], lookahead=barmerge.lookahead_off)
float usAtrExtension = usDailyAtr > 0 ? (usDailyClose - usDailyEma21) / usDailyAtr : na

f_us_trend(float c, float ema21, float sma50) =>
    na(c) or na(ema21) or na(sma50) ? '-' : c > ema21 and c > sma50 ? 'Above both' : c < ema21 and c < sma50 ? 'Below both' : 'Mixed'

f_us_trend_color(float c, float ema21, float sma50) =>
    na(c) or na(ema21) or na(sma50) ? cleanTableText : c > ema21 and c > sma50 ? cleanTablePositive : c < ema21 and c < sma50 ? cleanTableNegative : cleanTableAlert

// State-aware help explains the current reading, rather than only its formula.
f_us_trend_help(string market, float c, float ema21, float sma50) =>
    string state = f_us_trend(c, ema21, sma50)
    string meaning = state == '-' ? 'Insufficient daily data; wait for a valid reading.' : state == 'Above both' ? 'Above daily 21 EMA and 50 SMA: supportive context for long setups; confirm stock strength and an entry with defined risk.' : state == 'Below both' ? 'Below daily 21 EMA and 50 SMA: weak context for new longs; be selective and watch failed rallies.' : c > ema21 ? 'Above 21 EMA but not above 50 SMA: short-term recovery with longer-term resistance; seek confirmation before adding long exposure.' : c > sma50 ? 'Above 50 SMA but not above 21 EMA: short-term weakness within a stronger intermediate trend; watch whether support holds.' : 'At a key average: trend is unresolved; wait for a clearer close and stock-level confirmation.'
    market + ' — ' + meaning

f_us_extension_help(float extension) =>
    na(extension) ? 'Insufficient daily data to measure distance from the 21 EMA.' : extension >= atrExtensionCaution ? 'At or above your extension threshold: price is stretched above the daily 21 EMA; avoid chasing and assess pullback risk.' : extension > 0 ? 'Above the daily 21 EMA, below your extension threshold: assess entry and stop distance; this alone does not establish a low-risk entry.' : extension < 0 ? 'Below the daily 21 EMA: short-term weakness; look for support or a reclaim before considering new long exposure.' : 'At the daily 21 EMA: watch the reaction at this level and confirm with price and volume.'

float usDailyAtrPct = usDailyClose > 0 ? usDailyAtr / usDailyClose * 100 : na
float usDailyAdrPct = usDailyClose > 0 ? usDailyAdr / usDailyClose * 100 : na

f_us_metric(table t, int row, string title, string value, color valueColor, string explanation) =>
    color bg = f_table_row_bg(row - 1)
    table.cell(t, 0, row, title, bgcolor=bg, text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left, tooltip=explanation)
    table.cell(t, 1, row, value, bgcolor=bg, text_color=valueColor, text_size=dashSz, text_halign=text.align_right, tooltip=explanation)
    table.cell(t, 2, row, showMetricLegends ? 'ⓘ' : '', bgcolor=bg, text_color=usAccent, text_size=dashSz, tooltip=showMetricLegends ? explanation : '')

// === US stock dashboard ===
var table compactDashboard = table.new(getTablePosition(dashboardPosition), 3, 22, bgcolor=cleanTableBg, frame_color=cleanTableBorder, frame_width=1, border_width=0)
var table earningsTable = table.new(getTablePosition(earningsTableCorner), 5, 21, bgcolor=cleanTableBg, frame_width=0, border_width=0)
var table wm_table1 = table.new(getTablePosition(wmPosition), 4, 1, bgcolor=color.new(color.white, 100), border_width=0, border_color=color.new(color.white, 100))

var table volumeTable = table.new(getTablePosition(volumeTablePosition), 2, 4, bgcolor=color.new(color.white, 100), frame_color=color.new(color.white, 100), frame_width=0, border_color=color.new(color.white, 100), border_width=0)

if barstate.islast
    float threeMonthReturnFinal = usDailyPeakReturn
    float burst_score_compact = usDailyBurst

    float ff = na(free_float_raw) or free_float_raw <= 0 ? na : free_float_raw / (outstanding > 0 ? outstanding : 1) * 100

    float atrPct  = usDailyAtrPct
    float udRatio = usDailyUdRatio

    bool adrCaution = usDailyAdrPct >= 7
    bool peakCaution  = not na(threeMonthReturnFinal) and threeMonthReturnFinal >= 80

    string rsValue        = na(rs_rating) ? '-' : str.format('{0,number,0}', rs_rating)
    string adrValue       = str.format('{0,number,0.0}%', usDailyAdrPct) + (adrCaution ? ' ⚠' : '')
    string atrPctValue    = str.format('{0,number,0.00}%', atrPct)
    string threeMonthText = na(threeMonthReturnFinal) ? '-' : str.format('{0,number,0.00}%', threeMonthReturnFinal) + (peakCaution ? ' ⚠' : '')
    string burstValue     = str.tostring(math.round(burst_score_compact))
    string floatValue     = na(ff) ? '-' : str.format('{0,number,0.0}%', ff)
    string udValue        = na(udRatio) ? '-' : str.tostring(udRatio, '0.0')

    color adrRowColor = adrCaution ? cleanTableNegative : cleanTableText
    color mmRowColor  = peakCaution ? cleanTableNegative : cleanTableText

    // Label/value/help columns distinguish the US stock dashboard.
    table.clear(compactDashboard, 0, 0, 2, 21)
    table.merge_cells(compactDashboard, 0, 0, 2, 0)
    table.cell(compactDashboard, 0, 0, 'DTC US  |  ' + syminfo.ticker, bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=dashSz, text_halign=text.align_left, tooltip='US stock metrics; daily volatility rows are marked (D).')
    f_us_metric(compactDashboard, 1, 'RS rank', rsValue, usAccent, '63-day percentile of the stock/benchmark ratio in its own history; not a cross-stock RS rating.')
    f_us_metric(compactDashboard, 2, 'ATR% (D)', atrPctValue, usAccent, 'Daily Wilder ATR divided by daily close × 100; measures volatility including overnight gaps.')
    f_us_metric(compactDashboard, 3, 'ATR $ (D)', na(usDailyAtr) ? '-' : '$' + str.tostring(usDailyAtr, '#.##'), cleanTableText, 'Average daily true range in dollars; measures movement, not direction.')
    f_us_metric(compactDashboard, 4, 'ADR% (D)', adrValue, adrRowColor, 'Average daily high-low range divided by daily close × 100; excludes overnight gaps.')
    f_us_metric(compactDashboard, 5, '3M peak (D)', threeMonthText, mmRowColor, 'Highest daily high across today and the prior 63 sessions versus the close 63 sessions ago; needs full history.')
    f_us_metric(compactDashboard, 6, 'Burst', burstValue, cleanTableText, 'Weighted counts of daily 5%, 10% and 17% close-to-close moves over the selected calendar lookback.')
    f_us_metric(compactDashboard, 7, 'Float %', floatValue, cleanTableText, 'Reported float shares as a percentage of total shares outstanding.')
    f_us_metric(compactDashboard, 8, 'U/D vol', udValue, cleanTableText, 'Up-close daily volume divided by down-close daily volume over 50 sessions.')
    f_us_metric(compactDashboard, 9, 'Mkt cap', outstanding > 0 ? '$' + formatVolume(outstanding * usDailyClose) : '-', cleanTableText, 'Reported shares outstanding × current price, displayed in USD.')
    f_us_metric(compactDashboard, 10, '$Vol 20D', na(usDailyDollarVol) ? '-' : '$' + formatVolume(usDailyDollarVol), cleanTableText, '20-day average of daily close × volume in USD; a liquidity estimate.')
    if showRsLeadership
        string leadershipText = not usRsReady ? '-' : usRsLeading ? 'RS LEADING' : usRsNewHigh ? 'RS NEW HIGH' : 'No new high'
        f_us_metric(compactDashboard, 11, 'RS leadership', leadershipText, usRsNewHigh ? cleanTablePositive : cleanTableText, not usRsReady ? 'Insufficient daily history for the selected lookback.' : usRsLeading ? 'RS breaks its prior high before price: potential early leadership; watch for a price setup and volume confirmation.' : usRsNewHigh ? 'RS at a fresh lookback high with a price breakout: leadership confirmation; check extension and entry risk.' : 'No fresh RS high: leadership breakout is unconfirmed; this does not automatically make the stock weak.')
    if showMarketTrend
        f_us_metric(compactDashboard, 12, 'SPX trend', f_us_trend(usSpxClose, usSpxEma21, usSpxSma50), f_us_trend_color(usSpxClose, usSpxEma21, usSpxSma50), f_us_trend_help('SPX / broad US market', usSpxClose, usSpxEma21, usSpxSma50))
        f_us_metric(compactDashboard, 13, 'QQQ trend', f_us_trend(usQqqClose, usQqqEma21, usQqqSma50), f_us_trend_color(usQqqClose, usQqqEma21, usQqqSma50), f_us_trend_help('QQQ / Nasdaq-100', usQqqClose, usQqqEma21, usQqqSma50))
    if showAtrExtension
        string extensionText = na(usAtrExtension) ? '-' : str.format('{0,number,+0.00;-0.00} ATR', usAtrExtension)
        f_us_metric(compactDashboard, 14, '21 EMA ext.', extensionText, usAtrExtension >= atrExtensionCaution ? cleanTableAlert : cleanTableText, f_us_extension_help(usAtrExtension))
    if showMetricLegends
        table.cell(compactDashboard, 0, 20, '● PP ⓘ', bgcolor=cleanTableHeaderBg, text_color=#a78bfa, text_size=dashSz, tooltip='Purple dot: existing daily 5% move plus minimum-volume screen; not the classic pocket-pivot volume rule.')
        table.cell(compactDashboard, 1, 20, '+ RS ⓘ', bgcolor=cleanTableHeaderBg, text_color=cleanTableText, text_size=dashSz, tooltip='Cross: stock above its EMA while the selected panic index is below its EMA.')
    table.merge_cells(compactDashboard, 0, 21, 2, 21)
    table.cell(compactDashboard, 0, 21, 'Benchmark: ' + rsBenchmarkInput, bgcolor=cleanTableHeaderBg, text_color=usAccent, text_size=dashSz, tooltip='RS benchmark defaults to the S&P 500 cash index.')

    // === Position Sizing ===
    // Concept credit: eeeshanc9
    if psEnabled
        bool   psIsLong  = psDirection == 'Long'
        float  psEntry   = close
        float  psRiskAmt = psCapital * psRiskPct / 100

        // LOD (Long) / HOD (Short)
        float psLodSl    = psIsLong ? low  : high
        float psLodSlPct = psEntry > 0 ? math.abs(psEntry - psLodSl) / psEntry * 100 : na
        float psLodQty   = (not na(psLodSlPct) and psLodSlPct > 0) ? math.floor(psRiskAmt / (psEntry * psLodSlPct / 100)) : na
        float psLodAlloc = not na(psLodQty) ? psLodQty * psEntry / psCapital * 100 : na

        // PDL (Long) / PDH (Short)
        float psPdlSl    = psIsLong ? low[1] : high[1]
        float psPdlSlPct = (psEntry > 0 and not na(psPdlSl)) ? math.abs(psEntry - psPdlSl) / psEntry * 100 : na
        float psPdlQty   = (not na(psPdlSlPct) and psPdlSlPct > 0) ? math.floor(psRiskAmt / (psEntry * psPdlSlPct / 100)) : na
        float psPdlAlloc = not na(psPdlQty) ? psPdlQty * psEntry / psCapital * 100 : na

        // SL 1 (user %)
        float psSl1Qty   = psEntry > 0 ? math.floor(psRiskAmt / (psEntry * psSl1Pct / 100)) : na
        float psSl1Alloc = not na(psSl1Qty) ? psSl1Qty * psEntry / psCapital * 100 : na

        // SL 2 (user %)
        float psSl2Qty   = psEntry > 0 ? math.floor(psRiskAmt / (psEntry * psSl2Pct / 100)) : na
        float psSl2Alloc = not na(psSl2Qty) ? psSl2Qty * psEntry / psCapital * 100 : na

        // Alloc warning colors
        color psLodColor = (not na(psLodAlloc) and psLodAlloc > psMaxAllocPct) ? cleanTableNegative : cleanTableText
        color psPdlColor = (not na(psPdlAlloc) and psPdlAlloc > psMaxAllocPct) ? cleanTableNegative : cleanTableText
        color psSl1Color = (not na(psSl1Alloc) and psSl1Alloc > psMaxAllocPct) ? cleanTableNegative : cleanTableText
        color psSl2Color = (not na(psSl2Alloc) and psSl2Alloc > psMaxAllocPct) ? cleanTableNegative : cleanTableText

        // Position-sizing section below stock metrics.
        table.merge_cells(compactDashboard, 0, 15, 2, 15)
        table.cell(compactDashboard, 0, 15, 'RISK / SHARES', bgcolor=cleanTableHeaderBg, text_color=usAccent, text_size=dashSz)

        // PS rows start at 16, packed — skipped rows invisible (border_width=0)
        int cdRow = 16
        if psShowLod
            string psLodStr = na(psLodQty) ? 'LOD  -' : 'LOD ' + str.tostring(math.round(psLodQty)) + ' Qty ' + str.format('{0,number,0.0}%', psLodAlloc)
            table.merge_cells(compactDashboard, 0, cdRow, 1, cdRow)
            table.cell(compactDashboard, 2, cdRow, showMetricLegends ? 'ⓘ' : '', text_color=usAccent, text_size=dashSz, tooltip='Shares and allocation using the current bar low (long) or high (short) as stop.')
            table.cell(compactDashboard, 0, cdRow, psLodStr, text_color=psLodColor, text_size=dashSz, text_halign=text.align_left)
            cdRow += 1
        if psShowPdl
            string psPdlStr = na(psPdlQty) ? 'PDL  -' : 'PDL ' + str.tostring(math.round(psPdlQty)) + ' Qty ' + str.format('{0,number,0.0}%', psPdlAlloc)
            table.merge_cells(compactDashboard, 0, cdRow, 1, cdRow)
            table.cell(compactDashboard, 2, cdRow, showMetricLegends ? 'ⓘ' : '', text_color=usAccent, text_size=dashSz, tooltip='Shares and allocation using the prior bar low (long) or high (short) as stop.')
            table.cell(compactDashboard, 0, cdRow, psPdlStr, text_color=psPdlColor, text_size=dashSz, text_halign=text.align_left)
            cdRow += 1
        if psShowSl1
            string psSl1Str = na(psSl1Qty) ? 'SL1  -' : 'SL1 ' + str.tostring(math.round(psSl1Qty)) + ' Qty ' + str.format('{0,number,0.0}%', psSl1Alloc)
            table.merge_cells(compactDashboard, 0, cdRow, 1, cdRow)
            table.cell(compactDashboard, 2, cdRow, showMetricLegends ? 'ⓘ' : '', text_color=usAccent, text_size=dashSz, tooltip='Shares and allocation at the configured SL1 percentage stop.')
            table.cell(compactDashboard, 0, cdRow, psSl1Str, text_color=psSl1Color, text_size=dashSz, text_halign=text.align_left)
            cdRow += 1
        if psShowSl2
            string psSl2Str = na(psSl2Qty) ? 'SL2  -' : 'SL2 ' + str.tostring(math.round(psSl2Qty)) + ' Qty ' + str.format('{0,number,0.0}%', psSl2Alloc)
            table.merge_cells(compactDashboard, 0, cdRow, 1, cdRow)
            table.cell(compactDashboard, 2, cdRow, showMetricLegends ? 'ⓘ' : '', text_color=usAccent, text_size=dashSz, tooltip='Shares and allocation at the configured SL2 percentage stop.')
            table.cell(compactDashboard, 0, cdRow, psSl2Str, text_color=psSl2Color, text_size=dashSz, text_halign=text.align_left)

    if earningsTableEnabled
        table.clear(earningsTable, 0, 0)
        int firstDataRow = 1
        if not earningsMiniMode
            ft(earningsTable, 0, 0, earningsTopLeft == 'FF' ? validated_ff : earningsTopLeft == 'Mcap' ? validated_mc : '')
            ft(earningsTable, 1, 0, financial01)
            ft(earningsTable, 2, 0, earningsPeriod == 'FY' ? 'YoY' : '%Chg')
            ft(earningsTable, 3, 0, financial02)
            ft(earningsTable, 4, 0, earningsPeriod == 'FY' ? 'YoY' : '%Chg')
        else
            ft(earningsTable, 0, 0, earningsTopLeft == 'FF' ? validated_ff : earningsTopLeft == 'Mcap' ? validated_mc : '')
            ft(earningsTable, 2, 0, 'EPS YoY')
            ft(earningsTable, 4, 0, 'Sales YoY')
        for i = 0 to earningsQuarters - 1
            int dateVal = array.get(earningsDate, i)
            string dateStr = str.format('{0, date, MMM-yy}', dateVal)
            ftdate(earningsTable, 0, i + firstDataRow, dateStr)
            if not earningsMiniMode
                fcell(financial01, earningsTable, 1, i + firstDataRow, arrayFinData1, i)
                fyoy(earningsTable, 2, i + firstDataRow, arrayFinData1, i, earningsPeriod == 'FY' ? 1 : 4)
                fcell(financial02, earningsTable, 3, i + firstDataRow, arrayFinData2, i)
                fyoy(earningsTable, 4, i + firstDataRow, arrayFinData2, i, earningsPeriod == 'FY' ? 1 : 4)
            else
                fyoy(earningsTable, 2, i + firstDataRow, arrayFinData1, i, earningsPeriod == 'FY' ? 1 : 4)
                fyoy(earningsTable, 4, i + firstDataRow, arrayFinData2, i, earningsPeriod == 'FY' ? 1 : 4)
        if showModelForecast
            int forecastHeaderRow = earningsQuarters + firstDataRow
            int forecastValueRow = forecastHeaderRow + 1
            string forecastTitle = 'FORECAST'
            table.merge_cells(earningsTable, 0, forecastHeaderRow, 4, forecastHeaderRow)
            table.cell(earningsTable, 0, forecastHeaderRow, forecastTitle, bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=dashSz, text_halign=text.align_center)
            string epsForecastText = f_forecast_value(forecastEps, 'EPS', 'Insufficient data')
            string salesForecastText = f_forecast_value(forecastSales, 'Sales', 'Insufficient data')
            string epsForecastGrowth = not na(latestEps) and latestEps > 0 ? f_forecast_growth(forecastEpsRate) : 'NM'
            string salesForecastGrowth = f_forecast_growth(forecastSalesRate)
            color epsForecastGrowthColor = not na(forecastEpsRate) and latestEps > 0 ? (forecastEpsRate > 0 ? cleanTablePositive : forecastEpsRate < 0 ? cleanTableNegative : cleanTableText) : cleanTableText
            color salesForecastGrowthColor = na(forecastSalesRate) ? cleanTableText : forecastSalesRate > 0 ? cleanTablePositive : forecastSalesRate < 0 ? cleanTableNegative : cleanTableText
            ftdate(earningsTable, 0, forecastValueRow, 'Next Q (E)')
            table.cell(earningsTable, 1, forecastValueRow, epsForecastText, text_color=forecastValueColor, text_size=dashSz, bgcolor=f_table_row_bg(forecastValueRow - 1))
            table.cell(earningsTable, 2, forecastValueRow, epsForecastGrowth, text_halign=text.align_right, text_color=epsForecastGrowthColor, text_size=dashSz, bgcolor=f_table_row_bg(forecastValueRow - 1))
            table.cell(earningsTable, 3, forecastValueRow, salesForecastText, text_color=forecastValueColor, text_size=dashSz, bgcolor=f_table_row_bg(forecastValueRow - 1))
            table.cell(earningsTable, 4, forecastValueRow, salesForecastGrowth, text_halign=text.align_right, text_color=salesForecastGrowthColor, text_size=dashSz, bgcolor=f_table_row_bg(forecastValueRow - 1))
            if showFYForecast and enoughFYHistory
                int fyHeaderRow = forecastValueRow + 1
                int fyValueRow = fyHeaderRow + 1
                table.merge_cells(earningsTable, 0, fyHeaderRow, 4, fyHeaderRow)
                table.cell(earningsTable, 0, fyHeaderRow, 'FY ESTIMATE', bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=dashSz, text_halign=text.align_center)
                ftdate(earningsTable, 0, fyValueRow, 'FY (E)')
                table.cell(earningsTable, 1, fyValueRow, f_forecast_value(fyEpsEstimate, 'EPS', 'Insufficient data'), text_color=forecastValueColor, text_size=dashSz, bgcolor=f_table_row_bg(fyValueRow - 1))
                table.cell(earningsTable, 3, fyValueRow, f_forecast_value(fySalesEstimate, 'Sales', 'Insufficient data'), text_color=forecastValueColor, text_size=dashSz, bgcolor=f_table_row_bg(fyValueRow - 1))
    else
        table.clear(earningsTable, 0, 0, 4, 20)

    // Dedicated RVol/volume table. Its two-column layout keeps it distinct
    // from the compact dashboard while using the same DTC table theme.
    table.clear(volumeTable, 0, 0, 1, 3)
    if showVolumeTable
        table.merge_cells(volumeTable, 0, 0, 1, 0)
        table.cell(volumeTable, 0, 0, 'RVOL / VOLUME', bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=dashSz, text_halign=text.align_center)
        string volumeRvolBase = na(rvol_tf_pct) ? '-' : rvolDisplayMode == 'Multiple' ? str.format('{0,number,0.0}x', rvol_tf_pct / 100) : str.format('{0,number,0}%', rvol_tf_pct)
        string volumeRvolText = volumeRvolBase + (rvolIsExtreme ? ' ⚡' : '')
        color volumeRvolColor = na(rvol_tf_pct) ? cleanTableText : rvolIsExtreme ? cleanTablePositive : rvol_tf_pct <= 20 ? cleanTableNegative : cleanTableText
        color volumeCurrentColor = rvolIsExtreme ? cleanTablePositive : cleanTableText
        table.cell(volumeTable, 0, 1, 'RVol', bgcolor=f_table_row_bg(0), text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left, tooltip='Volume divided by the average of prior daily sessions; 100% equals 1x.')
        table.cell(volumeTable, 1, 1, '  ' + volumeRvolText, bgcolor=f_table_row_bg(0), text_color=volumeRvolColor, text_size=dashSz, text_halign=text.align_right, tooltip='Volume divided by the average of prior daily sessions; 100% equals 1x.')
        table.cell(volumeTable, 0, 2, 'Volume', bgcolor=f_table_row_bg(1), text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left, tooltip='Current daily traded share volume; develops until the session closes.')
        table.cell(volumeTable, 1, 2, '  ' + f_volume_display(rvol_tf_vol), bgcolor=f_table_row_bg(1), text_color=volumeCurrentColor, text_size=dashSz, text_halign=text.align_right, tooltip='Current daily traded share volume; develops until the session closes.')
        table.cell(volumeTable, 0, 3, 'Avg Vol', bgcolor=f_table_row_bg(2), text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left, tooltip='Average volume of the prior configured number of daily sessions.')
        table.cell(volumeTable, 1, 3, '  ' + f_volume_display(rvol_tf_avg), bgcolor=f_table_row_bg(2), text_color=cleanTableText, text_size=dashSz, text_halign=text.align_right, tooltip='Average volume of the prior configured number of daily sessions.')


    if showWatermark
        string wmSep = ' | '
        string wm_str1 = syminfo.basecurrency != '' ? syminfo.basecurrency + wmSep + syminfo.currency : syminfo.ticker
        [wm_tfstr, wm_periodNum] = wm_getTimeFrame()
        float wm_chg = na(close[1]) or close[1] == 0 ? na : math.round((close / close[1] - 1) * 100, 2)
        string wm_chgStr = na(wm_chg) ? '' : str.format('{0,number,+0.##;-0.##}%', wm_chg)
        table.cell(wm_table1, 0, 0, '', text_color=cleanTableText, width=0, text_size=size.small)
        string wmSz = wmTextSize == 'Huge' ? size.huge : wmTextSize == 'Normal' ? size.normal : wmTextSize == 'Small' ? size.small : size.large
        table.cell(wm_table1, 1, 0, wm_str1 + (wmShowTF ? ' ' + wm_periodNum + wm_tfstr : ''), width=0, text_color=cleanTableText, text_size=wmSz)
        table.cell(wm_table1, 2, 0, wmShowChange ? wm_chgStr : '', width=0, text_color=na(wm_chg) ? cleanTableText : wm_chg > 0 ? cleanTablePositive : cleanTableNegative, text_size=size.small)
        table.cell(wm_table1, 3, 0, wmSignature, text_color=cleanTableText, width=0, text_size=size.small)
    else
        table.clear(wm_table1, 0, 0, 3, 0)

// === Earnings arrows ===
if enableArrowDisplay and isNewEarningsPrint
    float epsVal = useQoQForArrow ? eps_qoq_q0 : eps_yoy_q0
    float salesVal = useQoQForArrow ? sales_qoq_q0 : sales_yoy_q0
    string epsText = na(epsVal) ? 'N/A' : str.tostring(epsVal, '0') + '%'
    string salesText = na(salesVal) ? 'N/A' : str.tostring(salesVal, '0') + '%'
    string displayText = 'EPS ' + epsText + (showSalesArrow ? '\nSales ' + salesText : '')
    bool epsPos = not na(epsVal) and epsVal >= 0
    color displayColor = na(epsVal) ? cleanTableText : epsPos ? cleanTablePositive : cleanTableNegative
    label.new(bar_index, low, text=displayText, style=label.style_label_up, color=color.new(cleanTablePositive, 100), textcolor=displayColor, size=labelSz, xloc=xloc.bar_index, yloc=yloc.belowbar)

// === Daily range label ===
// Concept credit: VCPSwing
// Fetch at top level (never inside barstate.islast) — Pine evaluates request.security every bar regardless.
[_dl_dh_sec, _dl_dl_sec, _dl_dh1_sec, _dl_dl1_sec] = request.security(syminfo.tickerid, 'D', [high, low, high[1], low[1]])
float _dl_dh  = timeframe.isdaily ? high    : _dl_dh_sec
float _dl_dl  = timeframe.isdaily ? low     : _dl_dl_sec
float _dl_dh1 = timeframe.isdaily ? high[1] : _dl_dh1_sec
float _dl_dl1 = timeframe.isdaily ? low[1]  : _dl_dl1_sec

var label dailyMoveLabel = na
if enableDailyMoveLabel and barstate.islast
    float curMove  = na(_dl_dl)  or _dl_dl  == 0 ? na : (_dl_dh  - _dl_dl)  / _dl_dl  * 100
    float prevMove = na(_dl_dl1) or _dl_dl1 == 0 ? na : (_dl_dh1 - _dl_dl1) / _dl_dl1 * 100
    string t1 = na(curMove)  ? 'DL N/A'  : str.format('DL {0,number,+0.00;-0.00}%',  curMove)
    string t2 = na(prevMove) ? 'PDL N/A' : str.format('PDL {0,number,+0.00;-0.00}%', prevMove)
    string labelText = showPDL ? t1 + '\n' + t2 : t1
    label.delete(dailyMoveLabel)
    dailyMoveLabel := label.new(bar_index, high, text=labelText, style=label.style_label_up, color=cleanTableBg, textcolor=cleanTableText, size=labelSz, xloc=xloc.bar_index, yloc=yloc.abovebar)

// =============================================================================
// H/L PIVOT PRICE POINTS
// =============================================================================
var array<float> pivotHighValues = array.new_float(0)
var array<float> pivotLowValues  = array.new_float(0)
string _hlSz = labelSz

// Series functions must run every bar for correct internal state — not inside the guard below
float pivotHigh = ta.pivothigh(high, hlPivotLen, hlPivotLen)
float pivotLow  = ta.pivotlow(low,   hlPivotLen, hlPivotLen)

if hlShowPoints and not timeframe.isweekly
    if not na(pivotHigh)
        array.unshift(pivotHighValues, high[hlPivotLen])
        string textHigh = hlShowPct ? str.tostring(high[hlPivotLen], '0.00') + '\n' : str.tostring(high[hlPivotLen], '0.00')
        label.new(bar_index - hlPivotLen, array.get(pivotHighValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, text=textHigh, textcolor=cleanTableText, size=_hlSz)
    if not na(pivotLow)
        array.unshift(pivotLowValues, low[hlPivotLen])
        string textLow = '\n' + str.tostring(low[hlPivotLen], '0.00')
        label.new(bar_index - hlPivotLen, array.get(pivotLowValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, text=textLow, textcolor=cleanTableText, color=color.rgb(0, 0, 0, 100), size=_hlSz)
    float pHigh = array.size(pivotHighValues) > 0 ? array.get(pivotHighValues, 0) : na
    float pLow  = array.size(pivotLowValues)  > 0 ? array.get(pivotLowValues,  0) : na
    float prcVarHigh = not na(pHigh) and not na(pLow) and pLow != 0 ? (pHigh - pLow) / pLow * 100 : na
    float prcVarLow  = not na(pLow) and not na(pHigh) and pHigh != 0 ? (pLow / pHigh - 1.0) * 100 : na
    if hlShowPct and not na(pivotHigh) and not na(prcVarHigh)
        string prcVarHighText = prcVarHigh >= 0 ? '+' + str.tostring(prcVarHigh, '0.0') + '%' : str.tostring(prcVarHigh, '0.0') + '%'
        color  colorPctUp     = prcVarHigh >= 0 ? hlPctPosColor : hlPctNegColor
        label.new(bar_index - hlPivotLen, array.get(pivotHighValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, text=prcVarHighText, textcolor=colorPctUp, size=_hlSz)
    if hlShowPct and not na(pivotLow) and not na(prcVarLow)
        string prcVarLowText = prcVarLow >= 0 ? '+' + str.tostring(prcVarLow, '0.0') + '%' : str.tostring(prcVarLow, '0.0') + '%'
        color  colorPctDn    = prcVarLow >= 0 ? hlPctPosColor : hlPctNegColor
        label.new(bar_index - hlPivotLen, array.get(pivotLowValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, text='\n\n\n' + prcVarLowText, textcolor=colorPctDn, color=color.rgb(0, 0, 0, 100), size=_hlSz)
````
