<!-- tradingview-pine-id: PUB;01e99d24ae584396a1a4b6add59fbf97 -->
<!-- tradingviewscripts-format: 1 -->
# DTC AIO [US] v3

Source: https://www.tradingview.com/script/umbuA1Lb-DTC-AIO-US/

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

---

## Source Code

````pine
//@version=6
// DTC AIO [US] — compact dashboard
// License: MPL-2.0 (https://mozilla.org/MPL/2.0/)

indicator('DTC AIO [US] v3', overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, dynamic_requests=true)

// =============================================================================
// INPUTS
// =============================================================================
string gEarn = 'Earnings Table'
bool   earningsTableEnabled = input.bool(true,  'Show table',              group=gEarn)
string earningsPeriod       = input.string('FQ', 'Period',                 options=['FQ', 'FY'], group=gEarn)
int    earningsQuarters     = input.int(4,       'Quarters shown',         minval=4, maxval=8, group=gEarn)
string earningsTopLeft      = input.string('Mcap','Top-left cell',         options=['Quarterly','FF','Mcap','Float %','Avg $ Vol'], group=gEarn)
bool   earningsMiniMode     = input.bool(false,  'Mini mode (YoY% only)',  group=gEarn)

string gDigit = 'Digit Settings'
string primaryEarningsMetric = input.string('EPS',  'Primary metric',         options=['EPS','PAT'],  group=gDigit, tooltip='Use EPS per share or PAT / Net Income in the first earnings column.')
bool   digitMsTable          = input.bool(true,     'MarketSmith layout',     group=gDigit, tooltip='5-column table: Quarterly | primary metric | %Chg | Sales($Mil) | %Chg.')
bool   digitAvoidNA          = input.bool(true,     'Avoid N/A',              group=gDigit, tooltip='Show — instead of N/A where data is missing.')
bool   digitRemoveHash       = input.bool(false,    'Remove #',               group=gDigit, tooltip='When off, YoY% from a negative prior-year EPS is prefixed with # (IBD-style).')
bool   digitShowVsYoY        = input.bool(false,    'Compare vs YoY',         group=gDigit, inline='d2')
bool   digitColYoY           = input.bool(true,     'YoY',                    group=gDigit, inline='d2')
bool   digitColQoQ           = input.bool(false,    'QoQ',                    group=gDigit, inline='d2')
bool   digitShowGrossMargin  = input.bool(false,    'Gross margin',           group=gDigit, inline='d4')
bool   digitShowROE          = input.bool(false,    'Return on equity',       group=gDigit, inline='d4')
// % colors now use the universal green/red (cleanTablePositive/cleanTableNegative)
// defined below — forward references resolved at runtime

string gMA = 'Moving Averages'
bool   showMA1   = input.bool(true,  'MA 1', group=gMA, inline='ma1')
int    ma1Len    = input.int(10,  '',        group=gMA, inline='ma1')
string ma1Type   = input.string('EMA', '',   options=['SMA','EMA','WMA'], group=gMA, inline='ma1')
color  ma1Color  = input.color(color.new(#f5f5f5, 0), '', group=gMA, inline='ma1')
int    ma1Width  = input.int(1,  '',         minval=1, maxval=4, group=gMA, inline='ma1')
bool   showMA2   = input.bool(true,  'MA 2', group=gMA, inline='ma2')
int    ma2Len    = input.int(20,  '',        group=gMA, inline='ma2')
string ma2Type   = input.string('EMA', '',   options=['SMA','EMA','WMA'], group=gMA, inline='ma2')
color  ma2Color  = input.color(color.new(#c8c8c8, 0), '', group=gMA, inline='ma2')
int    ma2Width  = input.int(1,  '',         minval=1, maxval=4, group=gMA, inline='ma2')
bool   showMA3   = input.bool(true,  'MA 3', group=gMA, inline='ma3')
int    ma3Len    = input.int(50,  '',        group=gMA, inline='ma3')
string ma3Type   = input.string('EMA', '',   options=['SMA','EMA','WMA'], group=gMA, inline='ma3')
color  ma3Color  = input.color(color.new(#989898, 0), '', group=gMA, inline='ma3')
int    ma3Width  = input.int(1,  '',         minval=1, maxval=4, group=gMA, inline='ma3')
bool   showMA4   = input.bool(true,  'MA 4', group=gMA, inline='ma4')
int    ma4Len    = input.int(200, '',        group=gMA, inline='ma4')
string ma4Type   = input.string('EMA', '',   options=['SMA','EMA','WMA'], group=gMA, inline='ma4')
color  ma4Color  = input.color(color.new(#686868, 0), '', group=gMA, inline='ma4')
int    ma4Width  = input.int(2,  '',         minval=1, maxval=4, group=gMA, inline='ma4')

string gRS = 'Relative Strength'
string rsBenchmarkInput    = input.symbol('AMEX:SPY', 'Benchmark',          group=gRS, tooltip='US default: SPY. Use QQQ, IWM, etc. as needed.')
bool   showPanicRS         = input.bool(true,  'Outperformance markers',    group=gRS)
string panicIndexSymbol    = input.symbol('AMEX:SPY', 'Panic index',        group=gRS)
int    panicEmaLen         = input.int(20,  'Panic EMA', minval=1,          group=gRS, inline='panicema')
color  panicRsMarkerColor  = input.color(color.new(#94a3b8, 35), '',        group=gRS, inline='panicema')
bool   showRSLine          = input.bool(true,  'RS Line',      group=gRS, inline='rsline', tooltip='IBD-style Relative Strength line scaled to price.')
color  rsLineColor         = input.color(color.new(#22d3ee, 0), '', group=gRS, inline='rsline')
int    rsLineWidth         = input.int(1,  '',  minval=1, maxval=4, group=gRS, inline='rsline')
bool   showRSRatingLabel   = input.bool(true,  'RS rating label', group=gRS)
// hardcoded defaults for removed inputs
int    rsLineOffset        = 80
bool   showRSLineMA        = false
int    rsLineMALen         = 21
string rsLineMAType        = 'EMA'
color  rsLineMAColor       = color.new(#f97316, 0)
bool   fillRSLineMA        = false
color  rsLineFillPos       = color.new(#10b981, 75)
color  rsLineFillNeg       = color.new(#ef4444, 75)
bool   rsPlotNewHigh       = false
string rsNewHighMode       = 'Last bar'
bool   rsPlotNewLow        = false
string rsNewLowMode        = 'Historical'
int    rsHighLookback      = 250
int    rsLowLookback       = 250
color  rsHighDotColor      = color.new(#79d5f2, 40)
color  rsLowDotColor       = color.new(#ff5252, 40)
string rsHighDotSize       = 'Tiny'
string rsLowDotSize        = 'Tiny'
bool   rsRatingOnly        = false

string gMom = 'Volatility'
int    adrLength  = input.int(14, 'ADR period',         minval=1, group=gMom)
int    relVolLen  = input.int(21, 'Rel. volume length', minval=1, group=gMom)
string burstPeriod = input.string('3 Years', 'Burst lookback', options=['3 Months','6 Months','1 Year','3 Years'], group=gMom, tooltip='Lookback window for counting burst days.')

string gPat = 'Patterns'
bool   showInsideBar       = input.bool(true,  'Inside bar',        group=gPat, inline='ib')
color  insideBarColor      = input.color(color.new(#d4a017, 0), '', group=gPat, inline='ib')
bool   showPocketPivots    = input.bool(false, 'Pocket pivots',     group=gPat, inline='pp')
int    pocketPivotMinVol   = input.int(500000, 'Min vol', minval=0, step=100000, group=gPat, inline='pp')
bool   showLowestVolume    = input.bool(false, 'Lowest-volume day', group=gPat, inline='lv')
int    lowestVolumeLookback = input.int(20,   'lookback', minval=10, maxval=50, group=gPat, inline='lv')

string gVwap = 'Anchored VWAP'
bool   showAnchoredVWAP   = input.bool(true, 'Show',  group=gVwap, inline='vwap')
color  anchoredVwapColor  = input.color(color.new(#a3a3a3, 0), '', group=gVwap, inline='vwap')
int    vwapWidth          = input.int(2, 'Width', minval=1, maxval=4, group=gVwap, inline='vwap2')
int    vwapOpacity        = input.int(0, 'Opacity%', minval=0, maxval=90, step=10, group=gVwap, inline='vwap2')

string gLab = 'Labels & Arrows'
bool   enableArrowDisplay   = input.bool(true,  'Primary arrows',     group=gLab, inline='earrow')
bool   useQoQForArrow       = input.bool(false, 'QoQ',                group=gLab, inline='earrow')
bool   showSalesArrow       = input.bool(false, 'Sales',              group=gLab, inline='earrow')
bool   enableDailyMoveLabel = input.bool(true,  'Day range % label',  group=gLab, inline='dlopt')
bool   showPDL              = input.bool(true,  'Show PDL',           group=gLab, inline='dlopt', tooltip='Show Previous Day range % in the label.')

string gHL = 'High/Low points'
bool   hlShowPoints  = input.bool(false, 'Display H/L points',  group=gHL)
int    hlPivotLen    = input.int(9,  'Pivot length', minval=2, maxval=30, group=gHL)
color  hlLabelColor  = input.color(color.new(#eaeaea, 0), 'Label color', group=gHL)
bool   hlShowPct     = input.bool(false, '% change',  group=gHL)
color  hlPctPosColor = input.color(color.new(#2563eb, 0), '+ %', group=gHL, inline='hlc')
color  hlPctNegColor = input.color(color.new(#db2777, 0), '− %', group=gHL, inline='hlc')
string hlLabelSize   = input.string('Small', 'Label size', options=['Tiny','Small','Normal','Large'], group=gHL)

string gWTC = 'Weekly Tight Closes'
bool   wtcShow       = input.bool(false, 'Show weekly tight closes', group=gWTC)
color  wtcColor      = input.color(color.new(#00bcd4, 0), 'Box color', group=gWTC)

string gWM = 'Watermark'
bool   showWatermark = input.bool(true,  'Show watermark', group=gWM)
bool   wmShowTF      = input.bool(true,  'Timeframe',      group=gWM, inline='wmopt')
bool   wmShowChange  = input.bool(true,  'Day change%',    group=gWM, inline='wmopt')
string wmSignature   = input.string('DTC US', 'Signature', group=gWM)
string wmTextSize    = input.string('Large', 'Ticker size', options=['Small','Normal','Large','Huge'], group=gWM)

string gPeers = 'Peer Comparison'
bool   showPeersTable = input.bool(false,  'Show peers table', group=gPeers, tooltip='Auto-detects industry from the built-in US industry map. Current symbol always shown pinned at top.')
bool   peersShow1M    = input.bool(true,   '1M%',  group=gPeers, inline='pret')
bool   peersShow3M    = input.bool(true,   '3M%',  group=gPeers, inline='pret')
bool   peersShowRVol  = input.bool(false,  'RVol', group=gPeers, inline='pret')
bool   peersShowRS    = input.bool(true,   'RS',   group=gPeers, inline='pret')
string peersSortBy    = input.string('3M%',  'Sort by', options=['Day%','1M%','3M%','RS','RVol'], group=gPeers)
int    peersMaxShow   = input.int(6, 'Peers shown', minval=3, maxval=20, group=gPeers, tooltip='Number of peer stocks shown in the table. Keep at 20 or below to stay within the 40 request call limit.')

string gLayout = 'Layout & Display'
string dashboardCorner     = input.string('Bottom Right', 'Dashboard',     options=['Top Right','Bottom Right'], group=gLayout)
string earningsTableCorner = input.string('Middle Left',  'Earnings table', options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'], group=gLayout)
string wmPosition          = input.string('Bottom Center','Watermark',     options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'], group=gLayout)
string peersTablePos       = input.string('Bottom Left',  'Peers table',   options=['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'], group=gLayout)
string dashTextSize        = input.string('Small', 'Dashboard text',  options=['Tiny','Small','Normal'], group=gLayout)
string earnTextSize        = input.string('Small', 'Earnings text',   options=['Tiny','Small','Normal'], group=gLayout)
string labelTextSize       = input.string('Small', 'Label text',      options=['Tiny','Small','Normal'], group=gLayout)
string peersTextSize       = input.string('Small', 'Peers text',      options=['Tiny','Small','Normal'], group=gLayout)

// =============================================================================
// Visual theme — inferred from chart background
// =============================================================================
f_chart_is_dark() =>
    bg = chart.bg_color
    color.r(bg) + color.g(bg) + color.b(bg) <= 400

var bool isDark = f_chart_is_dark()  // chart bg never changes mid-session; compute once

color cleanTableBg         = isDark ? color.new(#0d0d0d, 100) : color.new(#ffffff, 100)
color cleanTableAltBg      = isDark ? color.new(#141414, 100) : color.new(#f0f0f0, 100)
color cleanTableHeaderBg   = isDark ? color.new(#242424, 100) : color.new(#e4e4e4, 100)
color cleanTableText       = isDark ? color.new(#eaeaea, 0) : color.new(#1c1c1c, 0)
color cleanTableHeaderText = cleanTableText
color cleanTableBorder     = isDark ? #333333 : #cccccc
color cleanTablePositive   = color.new(#146b00, 0)
color cleanTableNegative   = color.new(#960505, 0)

getCorner(string c) =>
    c == 'Top Right' ? position.top_right : position.bottom_right

getTablePosition(string pos) =>
    switch pos
        'Top Left'      => position.top_left
        'Top Center'    => position.top_center
        'Top Right'     => position.top_right
        'Middle Left'   => position.middle_left
        'Middle Center' => position.middle_center
        'Middle Right'  => position.middle_right
        'Bottom Left'   => position.bottom_left
        'Bottom Center' => position.bottom_center
        'Bottom Right'  => position.bottom_right
        =>                 position.bottom_center

f_text_size(string s) =>
    s == 'Tiny' ? size.tiny : s == 'Normal' ? size.normal : size.small

string dashSz  = f_text_size(dashTextSize)
string earnSz  = f_text_size(earnTextSize)
string labelSz = f_text_size(labelTextSize)
string peersSz = f_text_size(peersTextSize)

wm_getTimeFrame() =>
    float wm_tf = timeframe.multiplier
    string wm_tfstr = ''
    if timeframe.isseconds
        wm_tfstr := 's'
    if timeframe.isminutes
        if wm_tf >= 60
            wm_tf   := wm_tf / 60
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

getMA(series float src, int len, string type) =>
    type == 'EMA' ? ta.ema(src, len) : type == 'WMA' ? ta.wma(src, len) : ta.sma(src, len)

formatVolume(float vol) =>
    na(vol) ? 'N/A' : vol >= 1000000000 ? str.format('{0,number,0.##} B', vol / 1000000000) : vol >= 1000000 ? str.format('{0,number,0.##} M', vol / 1000000) : vol >= 1000 ? str.format('{0,number,0.##} K', vol / 1000) : str.format('{0,number,0}', vol)

formatMoney(float val) =>
    na(val) ? 'N/A' : val >= 1000000000 ? '$' + str.format('{0,number,0.##} B', val / 1000000000) : val >= 1000000 ? '$' + str.format('{0,number,0.##} M', val / 1000000) : val >= 1000 ? '$' + str.format('{0,number,0.##} K', val / 1000) : '$' + str.format('{0,number,0}', val)

formatPct(float val, string pattern) =>
    na(val) ? 'N/A' : str.tostring(val, pattern) + '%'

f_table_row_bg(int row) =>
    row % 2 == 0 ? cleanTableBg : cleanTableAltBg

f_na_str() =>
    digitAvoidNA ? '-' : 'N/A'

f_pct_color(float pct) =>
    na(pct) ? cleanTableText : pct > 0 ? cleanTablePositive : pct < 0 ? cleanTableNegative : cleanTableText

f_dash_metric_color(float val, bool higherIsGood) =>
    na(val) ? cleanTableText : higherIsGood ? (val > 0 ? cleanTablePositive : val < 0 ? cleanTableNegative : cleanTableText) : (val > 0 ? cleanTableNegative : val < 0 ? cleanTablePositive : cleanTableText)

f_dashboard_metric(table _t, int _col, int _labelRow, int _valueRow, string _label, string _value, color _valueColor) =>
    table.cell(_t, _col, _labelRow, _label,  bgcolor=cleanTableHeaderBg,      text_color=cleanTableHeaderText, text_size=dashSz, text_halign=text.align_center)
    table.cell(_t, _col, _valueRow, _value,  bgcolor=f_table_row_bg(_col + _valueRow), text_color=_valueColor, text_size=dashSz, text_halign=text.align_center)

// =============================================================================
// Moving averages
// =============================================================================
float ma1 = getMA(close, ma1Len, ma1Type)
float ma2 = getMA(close, ma2Len, ma2Type)
float ma3 = getMA(close, ma3Len, ma3Type)
float ma4 = getMA(close, ma4Len, ma4Type)
plot(showMA1 ? ma1 : na, color=ma1Color, title='MA 1', linewidth=ma1Width)
plot(showMA2 ? ma2 : na, color=ma2Color, title='MA 2', linewidth=ma2Width)
plot(showMA3 ? ma3 : na, color=ma3Color, title='MA 3', linewidth=ma3Width)
plot(showMA4 ? ma4 : na, color=ma4Color, title='MA 4', linewidth=ma4Width)

// =============================================================================
// Patterns
// =============================================================================
bool  isInsideBar  = high < high[1] and low > low[1]
float dailyMovePP  = (close / close[1] - 1) * 100
bool  isPocketPivot = dailyMovePP >= 5.0 and volume >= pocketPivotMinVol
plotshape(showPocketPivots and isPocketPivot, title='Pocket pivot', style=shape.circle, location=location.belowbar, color=color.new(#7c3aed, 0), size=size.tiny)

// Three daily calls merged into one tuple — saves 2 unique security requests
[dailyVolume, swingDailyAvgVolForLiq, swingIpoAgeYears] = request.security(syminfo.tickerid, 'D', [volume, ta.sma(volume, relVolLen), (bar_index + 1) / 252.0], lookahead=barmerge.lookahead_off)
float volumeToUse     = not na(dailyVolume) and dailyVolume > 0 ? dailyVolume : volume
int   effectiveLookback = math.min(lowestVolumeLookback, bar_index + 1)
float lowestVol       = na
int   lowestVolBarIndex = na
// showLowestVolume is a static input — guarding here prevents ta.lowest from running every bar when the feature is off
if showLowestVolume and not na(volumeToUse) and effectiveLookback > 0
    float lvc = ta.lowest(volumeToUse, effectiveLookback)
    int   lvo = ta.lowestbars(volumeToUse, effectiveLookback)
    lowestVol := lvc
    if not na(lowestVol) and lowestVol > 0 and not na(lvo)
        lowestVolBarIndex := bar_index - lvo
bool isLowestVolume = showLowestVolume and not na(volumeToUse) and not na(lowestVol) and lowestVol > 0 and not na(lowestVolBarIndex) and bar_index >= lowestVolBarIndex and math.abs(volumeToUse - lowestVol) < 0.0001
color activeBarColor = na
if showInsideBar and isInsideBar
    activeBarColor := insideBarColor
barcolor(activeBarColor, title='Pattern highlights')
if isLowestVolume and (timeframe.isdaily or timeframe.isweekly or timeframe.ismonthly)
    label.new(bar_index, low, text=formatVolume(volumeToUse), style=label.style_label_up, color=color.new(color.black, 15), textcolor=color.white, size=size.tiny, xloc=xloc.bar_index, yloc=yloc.belowbar)

// =============================================================================
// Anchored VWAP
// =============================================================================
var float allTimeHigh      = high
var int   anchorBarIndex   = na
var float cumulativeTPV    = 0.0
var float cumulativeVolume = 0.0
bool isNewATH = high > allTimeHigh
if isNewATH
    allTimeHigh      := high
    anchorBarIndex   := bar_index
    cumulativeTPV    := (high + low + close) / 3.0 * volume
    cumulativeVolume := volume
else if not na(anchorBarIndex) and bar_index >= anchorBarIndex
    cumulativeTPV    += (high + low + close) / 3.0 * volume
    cumulativeVolume += volume
float anchorVWAP = not na(anchorBarIndex) and bar_index >= anchorBarIndex and cumulativeVolume > 0 ? cumulativeTPV / cumulativeVolume : na
color vwapCol = color.new(anchoredVwapColor, vwapOpacity)
plot(showAnchoredVWAP and not na(anchorVWAP) ? anchorVWAP : na, title='Anchored VWAP', color=vwapCol, linewidth=vwapWidth)

// =============================================================================
// RS rating & RS Line
// =============================================================================
string benchmarkTicker = rsBenchmarkInput
float  benchmarkClose  = request.security(benchmarkTicker, timeframe.period, close)
float  rs              = close / benchmarkClose
float  rs_rating       = ta.percentrank(rs, 252)

float _rsBmSma200  = ta.sma(benchmarkClose, 200)
float _rsRefValue  = na(_rsBmSma200) ? benchmarkClose : _rsBmSma200
float rsLineValue  = (close / benchmarkClose) * _rsRefValue * (rsLineOffset / 100.0)
float rsLineMAVal  = rsLineMAType == 'EMA' ? ta.ema(rsLineValue, rsLineMALen) : ta.sma(rsLineValue, rsLineMALen)
color _rsFillCol   = rsLineValue > rsLineMAVal ? rsLineFillPos : rsLineFillNeg
p_rsLine   = plot(showRSLine ? rsLineValue : na, title='RS Line', color=rsLineColor, linewidth=rsLineWidth)
p_rsLineMA = plot(showRSLine and showRSLineMA ? rsLineMAVal : na, title='RS Line MA', color=rsLineMAColor, linewidth=1)
fill(p_rsLine, p_rsLineMA, color=showRSLine and showRSLineMA and fillRSLineMA ? _rsFillCol : color.new(color.black, 100))

var label labRsRatingTitle = na
var label labRsRatingScore = na
if barstate.islast and showRSLine and showRSRatingLabel and not na(rsLineValue) and not na(rs_rating)
    label.delete(labRsRatingTitle)
    label.delete(labRsRatingScore)
    labRsRatingTitle := na
    labRsRatingScore := na
    int rsScore = int(math.round(rs_rating))
    if rsRatingOnly
        labRsRatingScore := label.new(bar_index, rsLineValue, text=str.tostring(rsScore), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textalign=text.align_left, color=color.new(color.black, 100), textcolor=rsLineColor, size=size.large)
    else
        labRsRatingTitle := label.new(bar_index, rsLineValue, text='RS Rating', xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textalign=text.align_left, color=color.new(color.black, 100), textcolor=rsLineColor, size=size.normal)
        labRsRatingScore := label.new(bar_index, rsLineValue, text='\n\n' + str.tostring(rsScore), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, textalign=text.align_left, color=color.new(color.black, 100), textcolor=rsLineColor, size=size.large)

f_rs_eff_lb(int lb) =>
    int cap = timeframe.isweekly and lb >= 250 ? 52 : lb
    math.min(cap, bar_index + 1)

int   rsLbHi   = f_rs_eff_lb(rsHighLookback)
int   rsLbLo   = f_rs_eff_lb(rsLowLookback)
float histRsHi = ta.highest(rsLineValue, rsLbHi)
float histRsLo = ta.lowest(rsLineValue,  rsLbLo)
float histPxHi = ta.highest(high, rsLbHi)
float histPxLo = ta.lowest(low,   rsLbLo)
bool rsAtNH      = showRSLine and not na(rsLineValue) and not na(histRsHi) and rsLineValue >= histRsHi
bool rsAtNL      = showRSLine and not na(rsLineValue) and not na(histRsLo) and rsLineValue <= histRsLo
bool rsHiBeforePx = high < histPxHi
bool rsLoBeforePx = low  > histPxLo

bool rsNH_hist = rsPlotNewHigh and rsAtNH and (rsNewHighMode == 'Historical' or (rsNewHighMode == 'Historical before price' and rsHiBeforePx))
bool rsNH_last = rsPlotNewHigh and barstate.islast and rsAtNH and (rsNewHighMode == 'Last bar' or (rsNewHighMode == 'Last bar before price' and rsHiBeforePx))
bool rsNL_hist = rsPlotNewLow  and rsAtNL and (rsNewLowMode  == 'Historical' or (rsNewLowMode  == 'Historical before price' and rsLoBeforePx))
bool rsNL_last = rsPlotNewLow  and barstate.islast and rsAtNL and (rsNewLowMode  == 'Last bar' or (rsNewLowMode  == 'Last bar before price' and rsLoBeforePx))

plot(rsNH_hist ? rsLineValue : na, title='RS new high (hist)', style=plot.style_circles, linewidth=3, color=rsHighDotColor)
plot(rsNL_hist ? rsLineValue : na, title='RS new low (hist)',  style=plot.style_circles, linewidth=3, color=rsLowDotColor)

f_rs_dot_sz(string s) =>
    s == 'Normal' ? size.normal : s == 'Small' ? size.small : size.tiny

var label labRsHi = na
var label labRsLo = na
if rsNH_last
    label.delete(labRsHi)
    labRsHi := label.new(bar_index, rsLineValue, xloc=xloc.bar_index, yloc=yloc.price, text='', style=label.style_circle, size=f_rs_dot_sz(rsHighDotSize), color=rsHighDotColor, textcolor=color.new(color.white, 100))
if rsNL_last
    label.delete(labRsLo)
    labRsLo := label.new(bar_index, rsLineValue, xloc=xloc.bar_index, yloc=yloc.price, text='', style=label.style_circle, size=f_rs_dot_sz(rsLowDotSize),  color=rsLowDotColor,  textcolor=color.new(color.white, 100))

// =============================================================================
// Panic RS
// =============================================================================
// Panic index: merge 2 calls into one tuple
[panicIndexClose, panicIndexEma] = request.security(panicIndexSymbol, 'D', [close, ta.ema(close, panicEmaLen)])
float panicStockEma   = request.security(syminfo.tickerid,  'D', ta.ema(close, panicEmaLen))
bool  isPanicRS       = panicIndexClose < panicIndexEma and close > panicStockEma
plotshape(showPanicRS and isPanicRS and timeframe.isdaily, style=shape.cross, location=location.abovebar, color=panicRsMarkerColor, size=size.tiny, title='Panic RS')

// =============================================================================
// Financial data
// =============================================================================
bool   primaryIsPat   = primaryEarningsMetric == 'PAT'
string financial01    = primaryIsPat ? 'PAT' : 'EPS'
string financial02id  = 'TOTAL_REVENUE'

float epsFinancialRaw  = request.financial(syminfo.tickerid, 'EARNINGS_PER_SHARE_DILUTED', earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)
float patFinancialRaw  = request.financial(syminfo.tickerid, 'NET_INCOME',                 earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)
float salesFinancialRaw = request.financial(syminfo.tickerid, financial02id,               earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)
// Use gaps_off so the estimate value is carried forward bar-by-bar; this ensures
// the latest known estimate is present on the same bar that financial data prints.
float epsEstimateRaw   = request.earnings(syminfo.tickerid, earnings.estimate, barmerge.gaps_off, ignore_invalid_symbol=true)
float grossProfitRaw   = request.financial(syminfo.tickerid, 'GROSS_PROFIT',     earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)
float roeRaw           = request.financial(syminfo.tickerid, 'RETURN_ON_EQUITY', earningsPeriod, barmerge.gaps_on, ignore_invalid_symbol=true)

float rev      = salesFinancialRaw
float finData1 = primaryIsPat ? math.round(patFinancialRaw / 1000000.0, 2) : epsFinancialRaw
float finData2 = math.round(salesFinancialRaw / 1000000.0, 2)

int datasize = earningsQuarters + 5
var array<int>   earningsDate    = array.new_int(datasize)
var array<float> arrayFinData1   = array.new_float(datasize)
var array<float> arrayFinData2   = array.new_float(datasize)
var array<float> arrayEstimate   = array.new_float(datasize)
var array<float> arrayGrossProfit = array.new_float(datasize)
var array<float> arrayROE        = array.new_float(datasize)
var float lastRevSnapshot   = na
// Track the estimate that was in force just before each earnings print.
// epsEstimateRaw is carried forward (gaps_off), so on the bar before a new
// financial print we capture the consensus estimate for that quarter.
var float lastEstimateBeforePrint = na
if not na(epsEstimateRaw)
    lastEstimateBeforePrint := epsEstimateRaw

f_array_int(array<int> arrayId, int val) =>
    array.unshift(arrayId, val)
    array.pop(arrayId)

f_array_float(array<float> arrayId, float val) =>
    array.unshift(arrayId, val)
    array.pop(arrayId)

bool hasRevData         = not na(rev)
bool isNewEarningsPrint = hasRevData and (na(lastRevSnapshot) or rev != lastRevSnapshot)
if isNewEarningsPrint
    lastRevSnapshot := rev
    f_array_int(earningsDate, time)
    f_array_float(arrayFinData1,    finData1)
    f_array_float(arrayFinData2,    finData2)
    f_array_float(arrayEstimate,    na(lastEstimateBeforePrint) ? na : lastEstimateBeforePrint)
    f_array_float(arrayGrossProfit, na(grossProfitRaw)  ? na : grossProfitRaw)
    f_array_float(arrayROE,         na(roeRaw)          ? na : roeRaw)

float eps_q0 = array.get(arrayFinData1, 0)
float eps_q1 = array.get(arrayFinData1, 1)
float eps_q4 = array.get(arrayFinData1, 4)
float sales_q0 = array.get(arrayFinData2, 0)
float sales_q1 = array.get(arrayFinData2, 1)
float sales_q4 = array.get(arrayFinData2, 4)

f_yoy_change(float current, float previous) =>
    previous <= 0 ? na : (current - previous) / math.abs(previous) * 100

f_qoq_change(float current, float previous) =>
    previous == 0 ? na : (current - previous) / math.abs(previous) * 100

float eps_yoy_q0   = f_yoy_change(eps_q0, eps_q4)
float eps_qoq_q0   = f_qoq_change(eps_q0, eps_q1)
float sales_yoy_q0 = f_yoy_change(sales_q0, sales_q4)
float sales_qoq_q0 = f_qoq_change(sales_q0, sales_q1)

f_yoy_pct(float cur, float prev) =>
    na(cur) or na(prev) or prev == 0 ? na : (cur - prev) / math.abs(prev) * 100

f_yoy_show_hash(float cur, float prev, bool removeHash) =>
    not removeHash and not na(cur) and not na(prev) and prev < 0 and prev != 0

f_cell_pct_ms(table _t, int col, int row, float pct, bool useHash, string naStr, int bgIdx) =>
    string disp = na(pct) ? naStr : (useHash ? '#' : '') + (pct > 0 ? '+' + str.tostring(math.round(pct)) + '%' : str.tostring(math.round(pct)) + '%')
    if not na(pct) and math.round(pct) == 0
        disp := '0%'
    table.cell(_t, col, row, disp, text_halign=text.align_center, text_color=f_pct_color(pct), text_size=earnSz, bgcolor=f_table_row_bg(bgIdx))

f_primary_metric_str(float val) =>
    na(val) ? '' : primaryIsPat ? str.tostring(val, '0.0') : str.tostring(val, '0.##')

fcell_eps_ms(table _t, int col, int row, array<float> vals, int idx, int yCmp) =>
    float c = array.get(vals, idx)
    float p = array.get(vals, idx + yCmp)
    string txt = ''
    if digitShowVsYoY and idx + yCmp < earningsQuarters + 5
        txt := na(c) and na(p) ? '' : na(c) ? f_na_str() : na(p) ? f_primary_metric_str(c) : f_primary_metric_str(c) + ' vs ' + f_primary_metric_str(p)
    else
        txt := f_primary_metric_str(c)
    table.cell(_t, col, row, txt, text_halign=text.align_center, text_color=cleanTableText, text_size=earnSz, bgcolor=f_table_row_bg(row - 1))

fcell_sales_ms(table _t, int col, int row, array<float> vals, int idx, int yCmp) =>
    float c = array.get(vals, idx)
    float p = array.get(vals, idx + yCmp)
    string txt = ''
    if digitShowVsYoY and idx + yCmp < earningsQuarters + 5
        txt := na(c) and na(p) ? '' : na(c) ? f_na_str() : na(p) ? str.tostring(c, '0.0') : str.tostring(c, '0.0') + ' vs ' + str.tostring(p, '0.0')
    else
        txt := na(c) ? '' : str.tostring(c, '0.0')
    table.cell(_t, col, row, txt, text_halign=text.align_center, text_color=cleanTableText, text_size=earnSz, bgcolor=f_table_row_bg(row - 1))

ft(table _t, int col, int row, string val) =>
    table.cell(_t, col, row, val, bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz)

ftdate(table _t, int col, int row, string val) =>
    string v = str.contains(val, '70') ? '' : val
    table.cell(_t, col, row, v, bgcolor=f_table_row_bg(row - 1), text_color=cleanTableText, text_size=earnSz, text_halign=text.align_left)

fyoy(table _t, int col, int row, array<float> vals, int idx, int cmpr) =>
    float val1 = array.get(vals, idx)
    float val2 = array.get(vals, idx + cmpr)
    float dif  = na(val1) or na(val2) or val2 == 0 ? na : (val1 - val2) / math.abs(val2) * 100
    f_cell_pct_ms(_t, col, row, dif, false, f_na_str(), row - 1)

var string validated_ff              = ''
var string validated_mc              = ''
var string validated_float_pct       = ''
var string validated_avg_dollar_vol  = ''

// =============================================================================
// Swing / Dashboard data (top-level for performance)
// =============================================================================
float swingAdrPercent           = 100 * (ta.sma(high / low, adrLength) - 1)
float swingAtr                  = ta.atr(14)
float swingAtrPercent           = swingAtr / close * 100
float swingLodDist              = swingAtr > 0 ? 100 * (close - low) / swingAtr : na
float swingLodPrice             = low
// swingIpoAgeYears, swingDailyAvgVolForLiq declared in tuple above (Patterns section)
// Swing timeframe: merge 3 calls into one tuple — saves 2 unique security requests
[swingTfClose, swingTfVolume, swingAvgVolumeRaw] = request.security(syminfo.tickerid, timeframe.period, [close, volume, ta.sma(volume, relVolLen)], lookahead=barmerge.lookahead_off)
float swingAvgDollarVolumeRaw   = swingTfClose * swingAvgVolumeRaw
float swingRelVolume            = swingAvgVolumeRaw > 0 ? swingTfVolume / swingAvgVolumeRaw * 100 : na
float swingVolumeBuzz           = swingAvgVolumeRaw > 0 ? 100 * (swingTfVolume / swingAvgVolumeRaw - 1) : na
float swingFinancialFloatShares = request.financial(syminfo.tickerid, 'FLOAT_SHARES_OUTSTANDING', 'FY', ignore_invalid_symbol=true)
float swingFinancialTotalShares = request.financial(syminfo.tickerid, 'TOTAL_SHARES_OUTSTANDING', 'FY', ignore_invalid_symbol=true)
float swingSharesFloatRaw       = na(syminfo.shares_outstanding_float) ? swingFinancialFloatShares : syminfo.shares_outstanding_float
float swingTotalSharesRaw       = na(syminfo.shares_outstanding_total) ? swingFinancialTotalShares : syminfo.shares_outstanding_total
float swingMarketCapRaw         = request.financial(syminfo.tickerid, 'MARKET_CAP_BASIC', 'D', ignore_invalid_symbol=true)
float swingMarketCapCalc        = na(swingMarketCapRaw) and not na(swingTotalSharesRaw) ? swingTotalSharesRaw * swingTfClose : swingMarketCapRaw
float swingFloatMarketCap       = swingSharesFloatRaw * swingTfClose
float swingFloatPct             = not na(swingFloatMarketCap) and not na(swingMarketCapCalc) and swingMarketCapCalc > 0 ? swingFloatMarketCap / swingMarketCapCalc * 100 : na
float swingTimePassed           = (timenow - time) / 1000.0
float swingTimeLeft             = (time_close - timenow) / 1000.0
float swingProjectedVolumeRaw   = swingTimeLeft > 0 and swingTimePassed > 0 ? volume + volume / swingTimePassed * swingTimeLeft : volume
float swingUpVol                = close > close[1] ? volume : 0.0
float swingDownVol              = close < close[1] ? volume : 0.0
float swingSumUp                = math.sum(swingUpVol,   50)
float swingSumDown              = math.sum(swingDownVol, 50)
float swingUpDownRatio          = swingSumDown > 0 ? swingSumUp / swingSumDown : na
// 52W high/low: merge 2 calls into one tuple — saves 1 unique security request
[swingFiftyTwoWeekHigh, swingFiftyTwoWeekLow] = request.security(syminfo.tickerid, 'W', [ta.highest(high, 52), ta.lowest(low, 52)], lookahead=barmerge.lookahead_off)
float swingDistFromHigh         = not na(swingFiftyTwoWeekHigh) and swingFiftyTwoWeekHigh > 0 ? 100 * (swingTfClose / swingFiftyTwoWeekHigh - 1) : na
float swingDistFromLow          = not na(swingFiftyTwoWeekLow)  and swingFiftyTwoWeekLow  > 0 ? 100 * (swingTfClose / swingFiftyTwoWeekLow  - 1) : na
// swingDailyAvgVolForLiq declared in the daily tuple at top of Patterns section
float swingLiquidityCap         = swingDailyAvgVolForLiq * 0.01

if barstate.islast
    validated_ff             := na(swingSharesFloatRaw)    or swingSharesFloatRaw    <= 0 ? '' : 'FF ' + formatVolume(swingSharesFloatRaw)
    validated_mc             := na(swingMarketCapCalc)     or swingMarketCapCalc     <= 0 ? '' : 'MCap ' + formatMoney(swingMarketCapCalc)
    validated_float_pct      := na(swingFloatPct)                                         ? '' : 'Float ' + str.tostring(swingFloatPct, '0.0') + '%'
    validated_avg_dollar_vol := na(swingAvgDollarVolumeRaw)                               ? '' : 'Avg$ ' + formatMoney(swingAvgDollarVolumeRaw)

// =============================================================================
// Burst score
// =============================================================================
f_get_burst_cutoff_time(string period) =>
    y = year(timenow)
    m = month(timenow)
    d = dayofmonth(timenow)
    switch period
        '3 Months' => m := m - 3
        '6 Months' => m := m - 6
        '1 Year'   => y := y - 1
        =>            y := y - 3
    if m <= 0
        y := y - 1
        m := m + 12
    timestamp(y, m, d, 0, 0)

var int burst_cutoff_time = f_get_burst_cutoff_time(burstPeriod)
var int count_5p  = 0
var int count_10p = 0
var int count_17p = 0
float daily_move_burst     = (close - close[1]) / close[1] * 100
bool  is_in_burst_lookback = time >= burst_cutoff_time
bool  is_new_day_burst     = ta.change(dayofmonth) != 0
if is_in_burst_lookback and not is_in_burst_lookback[1]
    count_5p  := 0
    count_10p := 0
    count_17p := 0
if is_in_burst_lookback and is_new_day_burst
    if daily_move_burst >= 5
        count_5p  += 1
    if daily_move_burst >= 10
        count_10p += 1
    if daily_move_burst >= 17
        count_17p += 1

// =============================================================================
// US Industry map — auto-detect peers from built-in groups
// syminfo.industry must match a name below for auto-detect to work;
// the loop also finds the ticker directly inside each symbols list (more reliable).
// =============================================================================
type usIndustry
    string   name
    string[] symbols

var indArr = array.from(
    usIndustry.new('Semiconductors',              array.from("NVDA","TSM","AVGO","MU","AMD","ASML","INTC","ARM","KLAC","TXN","MRVL","QCOM","ADI","COHR","MPWR","NXPI")),
    usIndustry.new('Telecom Equipment',           array.from("AAPL","CSCO","NOK","MSI","CIEN","GRMN","ERIC","UI","VSAT","ONDS","VISN","DGII","CALX","HLIT","ARLO","GILT","FEIM","CLFD")),
    usIndustry.new('Internet Content & Information', array.from("GOOG","GOOGL","META","NFLX","SPOT","MSTR","BIDU","TRI","RDDT","VRSN","FWONK","FWONA","RBA","CSGP","CHKP","TME","PINS","IT","MTCH")),
    usIndustry.new('Software - Application',      array.from("MSFT","ORCL","PLTR","PANW","SAP","APP","CRWD","CRM","NOW","CDNS","ADBE","ADP","SNPS","INTU","SNOW","DDOG","NTES","CRWV")),
    usIndustry.new('Internet Retail',             array.from("AMZN","BABA","MELI","SE","EBAY","JD","CPNG","CHWY","VIPS","ETSY","GLBE","RVLV","GIC")),
    usIndustry.new('Auto Manufacturers',          array.from("TSLA","TM","RACE","GM","F","HMC","STLA","RIVN","XPEV","LI","NIO","OSK","VFS","FSS","HOG","BLBD","LCID","PSNY")),
    usIndustry.new('Drug Manufacturers - Major',  array.from("LLY","JNJ","ABBV","MRK","AZN","NVS","NVO","PFE","BMY","VRTX","SNY","GSK","REGN","TAK","ALNY","HLN","ZTS","RPRX")),
    usIndustry.new('Banks - Major',               array.from("JPM","BAC","HSBC","RY","WFC","C","MUFG","TD","SAN","SMFG","BBVA","BMO","MFG","COF","BNS","PNC","USB")),
    usIndustry.new('Oil & Gas Integrated',        array.from("XOM","CVX","SHEL","TTE","BP","PBR","PBR.A","CNQ","EQNR","SU","EOG","IMO","OXY","CVE","DVN","EQT","EC")),
    usIndustry.new('Electronic Components',       array.from("APH","GLW","CLS","NVT","TTMI","VICR","CAMT","BELFB","BELFA","KN","VPG","LPTH","OPTX","MEI")),
    usIndustry.new('Asset Management',            array.from("MS","BLK","UBS","BX","BN","KKR","APO","BAM","AMP","NTRS","RJF","ARES","PFG","TROW","BEN","TPG","CG","OWL","ARCC")),
    usIndustry.new('Data Processing Services',    array.from("PAYX","VRSK","IREN","AKAM","J","WULF","TYL","APLD","GDDY","CIFR","CORZ","GDS","MARA","EXLS","BTDR","CLSK","KC","KEEL")),
    usIndustry.new('Biotechnology',               array.from("AMGN","GILD","ARGX","IQV","NTRA","UTHR","BNTX","MRNA","NBIX","GMAB","BBIO","AXSM","ELAN","SMMT","BMRN","ARWR","KRYS","HALO","TECH")),
    usIndustry.new('Alternative Power Generation',array.from("BIP","TLN","ENLT","FRVO","CWEN","XIFR","RNW","NUCL","PBK")),
    usIndustry.new('Aerospace & Defense',         array.from("GE","RTX","BA","HON","LMT","HWM","GD","NOC","TDG","RKLB","LHX","ESLT","HEI","HEI.A","AXON","TDY","CW","FTAI","TXT")),
    usIndustry.new('Electrical Products',         array.from("GEV","ETN","LITE","AME","ROK","HUBB","FPS","GNRC","APTV","RRX","POWL","AYI","ENS","ENPH","QS","FLNC","BDC","SMR","SEDG")),
    usIndustry.new('Industrial Machinery',        array.from("LRCX","AMAT","PH","TT","JCI","CARR","JBL","DOV","IR","SYM","XYL","WWD","MKSI","VLTO","ENTG","LII","IEX","NDSN","MOD")),
    usIndustry.new('Electronic Production Equipment', array.from("VRT","BE","TER","FLEX","SANM","LFUS","AEIS","VSH","PLXS","AXTI","MDA","LPL","PLUG","OLED","VECO","BHE","AEHR","CTS")),
    usIndustry.new('Investment Banks',            array.from("GS","SCHW","IBKR","BNY","CME","BCS","ICE","HOOD","DB","NDAQ","STT","COIN","CBOE","NMR","TW","LPLA","EVR","FUTU","GLXY")),
    usIndustry.new('Computer Hardware',           array.from("SNDK","ANET","STX","WDC","NTAP","P","LOGI","EXTR","ADTN","SSYS","XRX","BLZE","LTRX","IMMR","QMCO","ALOT","QXL","TACT")),
    usIndustry.new('Information Technology Services', array.from("IBM","ACN","FTNT","NET","INFY","CRDO","WDAY","CTSH","HPQ","WIT","BR","CDW","RBRK","GIB","VIAV","CACI","GWRE","BSY","RIOT")),
    usIndustry.new('Trucking',                    array.from("ODFL","JBHT","XPO","TFII","KNX","SAIA","LSTR","SNDR","ARCB","WERN","MRTN","HTLD","CVLG","ULH","FWRD","PAMT","PAL","ZDAI")),
    usIndustry.new('Aluminum',                    array.from("AA","CENX","CSTM","KALU","TG")),
    usIndustry.new('Medical Specialties',         array.from("TMO","ABT","ISRG","DHR","SYK","MDT","BSX","EW","MDLN","IDXX","BDX","A","WAT","ALC","DXCM","GEHC","RMD","ILMN","MTD")),
    usIndustry.new('Food - Major Diversified',    array.from("KHC","GIS","CAG","CHA","HLF","SMPL","BYND","BGS","OTLY","HAIN","ORIS")),
    usIndustry.new('Other Industrial Metals & Mining', array.from("RIO","SCCO","FCX","CCJ","TECK","CRS","ATI","HBM","MP","NXE","UEC","AUGO","ALM","UUUU","LEU","ERO","DNN","TGB")),
    usIndustry.new('Computer Processing Hardware',     array.from("DELL","SONY","HPE","SMCI","IONQ","ZBRA","QBTS","RGTI","XNDU","NATL","INFQ","OSS","BGIN","EBON","LHSW","QNT")),
    usIndustry.new('Oil & Gas E&P',                   array.from("COP","FANG","WDS","AR","RRC","VIST","MUR","MGY","CNX","CRK","GPOR","WTTR","TALO","NOG","NEXT","XPRO","VET","DEC","HPK")),
    usIndustry.new('Telecom Services',                array.from("TMUS","VZ","T","AMX","VOD","VIV","RCI","TU","SKM","TIGO","TLK","GSAT","TIMB","TKC","LBRDK","LBRDA","AD","TDS","VEON")),
    usIndustry.new('Engineering & Construction',      array.from("PWR","FIX","FER","EME","MTZ","STRL","OTIS","APG","IESC","DY","BLD","LGN","ACM","AGX","STN","ECG","TTEK","FLR","MYRG")),
    usIndustry.new('Beverages - Non-Alcoholic',       array.from("KO","MNST","CCEP","KDP","FMX","COKE","PRMB","CELH","KOF","AKO.B","AKO.A","FIZZ")),
    usIndustry.new('Packaged Software',               array.from("MSFT","ADBE","INTU","CDNS","SNPS","ANSS","TTWO","EA","RBLX","U","DBX","BOX","DOCU","ZI","AZPN","MANH","PCTY","BSY","PTC","SMAR","SPSC","NCNO","CCCS","ALKT","NUAN")),
    usIndustry.new('Software - Infrastructure',       array.from("MSFT","ORCL","VMW","PANW","FTNT","ZS","OKTA","CRWD","S","DDOG","NEWR","DT","RPM","TENB","QLYS","CHKP","CYBR","SAIL","OSPN")),
    usIndustry.new('Health Information Services',     array.from("VEEV","CERN","HCAT","NXGN","PHYC","DOCS","ONEM","AMWL","PHR","RXRX","SDGR","ACCD","ALHC","GDRX","TDOC","HIMS","OPRX")),
    usIndustry.new('Financial Data & Stock Exchanges',array.from("MSCI","SPGI","MCO","FDS","ICE","CME","NDAQ","CBOE","TW","MKT","SSNC","WEX","ENV","ENFN","CWAN","LPLA")),
    usIndustry.new('Specialty Retail',                array.from("HD","LOW","TJX","ULTA","FIVE","OLLI","BOOT","GFF","CASY","DKS","AEO","FL","JWN","M","ANF","GPS","URBN","RVLV","VSCO")),
    usIndustry.new('Restaurants',                     array.from("MCD","SBUX","CMG","YUM","QSR","DPZ","WING","TXRH","DINE","SHAK","CAVA","BROS","JACK","CAKE","EAT","DENN","LOCO","FAT")),
    usIndustry.new('Insurance - Property & Casualty', array.from("BRK.B","BRK.A","PGR","TRV","ALL","CB","CNA","HIG","MKL","RYAN","AON","MMC","WTW","AIG","ACGL","RE","EG","CINF","WRB")),
    usIndustry.new('Medical Devices',                 array.from("ISRG","ABT","MDT","BSX","EW","SYK","ZBH","HOLX","LMAT","AMED","NVCR","AXNX","TMDX","SWAV","INSP","PRCT","ATEC","IRTC","NARI")),
    usIndustry.new('Chemicals - Specialty',           array.from("ECL","SHW","PPG","RPM","HB","AVNT","IOSP","MTRN","CSWI","KWR","ASIX","HWKN","FCPT","CBT","TNC","KLIC","BCPC","SHLX","TROX")),
    usIndustry.new('Real Estate - REIT',              array.from("AMT","PLD","EQIX","CCI","PSA","EXR","VICI","O","SPG","WELL","ARE","DLR","IRM","ESS","MAA","AVB","EQR","NNN","FR")),
    usIndustry.new('Consumer Electronics',            array.from("AAPL","SONY","SNE","GPRO","HEAR","VUZI","KOSS","KODK","UEIC","VOXX","SOND","LOGI","SNX","CDW","SMCI")),
    // ── Sector-level fallbacks (pass 4) — named to match TradingView's syminfo.sector strings ──
    usIndustry.new('__sector:Technology',             array.from("AAPL","MSFT","NVDA","AVGO","ORCL","CRM","AMD","QCOM","TXN","AMAT","LRCX","ADI","KLAC","SNPS","CDNS","MRVL","INTC","PANW","CSCO","IBM")),
    usIndustry.new('__sector:Electronic Technology',  array.from("AAPL","MSFT","NVDA","AVGO","ORCL","CRM","AMD","QCOM","TXN","AMAT","LRCX","ADI","KLAC","SNPS","CDNS","MRVL","INTC","PANW","CSCO","IBM")),
    usIndustry.new('__sector:Communication Services', array.from("GOOG","GOOGL","META","NFLX","DIS","TMUS","CMCSA","VZ","T","CHTR","EA","TTWO","WBD","LYV","PARA","AMC","SIRI","LBRDK")),
    usIndustry.new('__sector:Healthcare',             array.from("LLY","JNJ","ABBV","MRK","TMO","ABT","DHR","ISRG","VRTX","AMGN","BSX","SYK","MDT","REGN","EW","IQV","GILD","HCA","CI","CVS")),
    usIndustry.new('__sector:Health Technology',      array.from("LLY","JNJ","ABBV","MRK","TMO","ABT","DHR","ISRG","VRTX","AMGN","BSX","SYK","MDT","REGN","EW","IQV","GILD","HCA","CI","CVS")),
    usIndustry.new('__sector:Health Services',        array.from("LLY","JNJ","ABBV","MRK","TMO","ABT","DHR","ISRG","VRTX","AMGN","BSX","SYK","MDT","REGN","EW","IQV","GILD","HCA","CI","CVS")),
    usIndustry.new('__sector:Financial Services',     array.from("BRK.B","JPM","V","MA","BAC","WFC","GS","MS","SPGI","BX","KKR","C","AXP","USB","PNC","TFC","COF","SCHW","ICE","CME")),
    usIndustry.new('__sector:Finance',                array.from("BRK.B","JPM","V","MA","BAC","WFC","GS","MS","SPGI","BX","KKR","C","AXP","USB","PNC","TFC","COF","SCHW","ICE","CME")),
    usIndustry.new('__sector:Consumer Cyclical',      array.from("AMZN","TSLA","HD","MCD","NKE","LOW","SBUX","CMG","TJX","BKNG","MAR","HLT","GM","F","ABNB","ROST","ORLY","AZO","YUM","DHI")),
    usIndustry.new('__sector:Consumer Discretionary', array.from("AMZN","TSLA","HD","MCD","NKE","LOW","SBUX","CMG","TJX","BKNG","MAR","HLT","GM","F","ABNB","ROST","ORLY","AZO","YUM","DHI")),
    usIndustry.new('__sector:Retail Trade',           array.from("AMZN","TSLA","HD","MCD","NKE","LOW","SBUX","CMG","TJX","BKNG","MAR","HLT","GM","F","ABNB","ROST","ORLY","AZO","YUM","DHI")),
    usIndustry.new('__sector:Consumer Services',      array.from("AMZN","TSLA","HD","MCD","NKE","LOW","SBUX","CMG","TJX","BKNG","MAR","HLT","GM","F","ABNB","ROST","ORLY","AZO","YUM","DHI")),
    usIndustry.new('__sector:Consumer Defensive',     array.from("WMT","PG","KO","PEP","COST","PM","MO","CL","KMB","GIS","K","HSY","SYY","CAG","CPB","HRL","TSN","KHC","CHD","MNST")),
    usIndustry.new('__sector:Consumer Staples',       array.from("WMT","PG","KO","PEP","COST","PM","MO","CL","KMB","GIS","K","HSY","SYY","CAG","CPB","HRL","TSN","KHC","CHD","MNST")),
    usIndustry.new('__sector:Industrials',            array.from("GE","CAT","RTX","HON","UNP","DE","LMT","BA","UPS","ETN","EMR","ITW","PH","GD","NOC","FDX","TT","MMM","CARR","PWR")),
    usIndustry.new('__sector:Producer Manufacturing', array.from("GE","CAT","RTX","HON","UNP","DE","LMT","BA","UPS","ETN","EMR","ITW","PH","GD","NOC","FDX","TT","MMM","CARR","PWR")),
    usIndustry.new('__sector:Commercial Services',    array.from("GE","CAT","RTX","HON","UNP","DE","LMT","BA","UPS","ETN","EMR","ITW","PH","GD","NOC","FDX","TT","MMM","CARR","PWR")),
    usIndustry.new('__sector:Transportation',         array.from("GE","CAT","RTX","HON","UNP","DE","LMT","BA","UPS","ETN","EMR","ITW","PH","GD","NOC","FDX","TT","MMM","CARR","PWR")),
    usIndustry.new('__sector:Energy',                 array.from("XOM","CVX","COP","EOG","SLB","MPC","PSX","VLO","OXY","PBR","BP","SHEL","HAL","BKR","DVN","FANG","APA","HES","NOG","SM")),
    usIndustry.new('__sector:Energy Minerals',        array.from("XOM","CVX","COP","EOG","SLB","MPC","PSX","VLO","OXY","PBR","BP","SHEL","HAL","BKR","DVN","FANG","APA","HES","NOG","SM")),
    usIndustry.new('__sector:Basic Materials',        array.from("LIN","APD","FCX","NEM","ECL","SHW","NUE","STLD","AA","CF","MOS","IFF","ALB","CE","EMN","AXTA","RPM","FMC","SEE","TROX")),
    usIndustry.new('__sector:Non-Energy Minerals',    array.from("LIN","APD","FCX","NEM","ECL","SHW","NUE","STLD","AA","CF","MOS","IFF","ALB","CE","EMN","AXTA","RPM","FMC","SEE","TROX")),
    usIndustry.new('__sector:Process Industries',     array.from("LIN","APD","FCX","NEM","ECL","SHW","NUE","STLD","AA","CF","MOS","IFF","ALB","CE","EMN","AXTA","RPM","FMC","SEE","TROX")),
    usIndustry.new('__sector:Real Estate',            array.from("PLD","AMT","EQIX","CCI","PSA","SPG","O","WELL","DLR","VICI","AVB","EQR","MAA","EXR","ARE","IRM","WY","CBRE","COLD","SBAC")),
    usIndustry.new('__sector:Utilities',              array.from("NEE","DUK","SO","AEP","EXC","XEL","SRE","PCG","ED","ETR","PPL","FE","WEC","ES","CMS","AEE","LNT","EVRG","NI","PNW")),
    usIndustry.new('Finance & Rental/Leasing',        array.from("V","MA","AXP","URI","STT","IX","RKT","SUNB","SYF","AER","SOFI","KSPI","ALLY","UHAL","UHAL.B","FCFS","CAR","OMF","CACC")),
    usIndustry.new('Apparel & Footwear Retail',       array.from("TJX","ROST","TPR","BURL","GAP","URBN","VSXY","BOOT","ANF","AEO","CPRI","BKE","CRI","WINA","SFIX","CAL","GCO","SCVL","CTRN")),
    usIndustry.new('Home Furnishings',                array.from("SGI","PATK","MBC","LZB","LEG","ARHS","HELE","ETD","XMAX","FLXS"))
    )

// Find which industry the current ticker belongs to — cached on bar 0 only.
// The ticker never changes mid-script; running 400+ string comparisons every bar is wasteful.
var int  foundIdx  = -1
var bool _idxDone  = false
if not _idxDone
    _idxDone := true
    // Pass 1: exact ticker membership (most reliable)
    for [idx, ind] in indArr
        if foundIdx >= 0
            break
        for s in ind.symbols
            if s == syminfo.ticker
                foundIdx := idx
                break
    // Pass 2: fallback — case-insensitive match of syminfo.industry against group name
    if foundIdx < 0 and syminfo.industry != ''
        string _si = str.lower(syminfo.industry)
        for [idx, ind] in indArr
            if foundIdx >= 0
                break
            if str.lower(ind.name) == _si
                foundIdx := idx
                break
    // Pass 3: partial match — industry string contains group name or vice versa
    if foundIdx < 0 and syminfo.industry != ''
        string _si = str.lower(syminfo.industry)
        for [idx, ind] in indArr
            if foundIdx >= 0
                break
            string _gn = str.lower(ind.name)
            if str.contains(_si, _gn) or str.contains(_gn, _si)
                foundIdx := idx
                break
    // Pass 4: sector-level fallback — exact match against __sector: entries
    if foundIdx < 0 and syminfo.sector != ''
        string _sec = '__sector:' + syminfo.sector
        for [idx, ind] in indArr
            if foundIdx >= 0
                break
            if ind.name == _sec
                foundIdx := idx
                break

usIndustry curInd = na
if foundIdx >= 0
    curInd := indArr.get(foundIdx)

// Pre-extract peer symbols into a stable var array.
// This avoids accessing curInd.symbols (a UDT field) inside any code path that
// contains request.security() — with dynamic_requests=true, Pine evaluates all
// such paths on every bar regardless of conditionals, causing na-UDT field errors.
var array<string> _peerSymbols = array.new_string()
var int _prevFoundIdx = -2

if foundIdx != _prevFoundIdx
    _peerSymbols.clear()
    if foundIdx >= 0
        usIndustry _ind = indArr.get(foundIdx)
        for _s in _ind.symbols
            if _s != syminfo.ticker and _peerSymbols.size() < 20
                _peerSymbols.push(_s)
    _prevFoundIdx := foundIdx

f_calc(float c, float ref) => na(ref) or ref == 0 ? na : (c - ref) / ref * 100

// Self metrics (reuse already-computed closes)
float self_day = f_calc(close, close[1])
float self_1m  = f_calc(close, close[21])
float self_3m  = f_calc(close, close[63])
float self_rv  = swingRelVolume

// Daily range label — 4 separate calls merged into one tuple (saves 3 unique requests)
// On daily TF, request.security('D', ...) returns identical values to the native series
[_dl_dh, _dl_dl, _dl_dh1, _dl_dl1] = request.security(syminfo.tickerid, 'D', [high, low, high[1], low[1]])

// =============================================================================
// Peer table helpers
// =============================================================================
f_ppct_str(float v)  => na(v) ? '-' : str.format('{0,number,+0.0;-0.0}%', v)
f_prvol_str(float v) => na(v) ? '-' : str.format('{0,number,0}%', v)
f_prs_str(float v)   => na(v) ? '-' : str.tostring(int(v))
f_ppct_col(float v)  => na(v) ? cleanTableText : v > 0 ? cleanTablePositive : cleanTableNegative
f_prvol_col(float v) => na(v) ? cleanTableText : v > 150 ? cleanTablePositive : v < 80 ? cleanTableNegative : cleanTableText
f_prs_col(float v)   => na(v) ? cleanTableText : v >= 70 ? cleanTablePositive : v <= 40 ? cleanTableNegative : cleanTableText

f_peer_row(table t, int row, string sym, float daychg, float r1m, float r3m, float rv, float rs, bool isSelf) =>
    color bg = isSelf ? cleanTableHeaderBg : f_table_row_bg(row - 2)
    color fg = isSelf ? cleanTableHeaderText : cleanTableText
    table.cell(t, 0, row, sym,                                 bgcolor=bg, text_color=fg,              text_size=earnSz, text_halign=text.align_left)
    table.cell(t, 1, row, f_ppct_str(daychg),                  bgcolor=bg, text_color=f_ppct_col(daychg),   text_size=earnSz, text_halign=text.align_right)
    table.cell(t, 2, row, peersShow1M  ? f_ppct_str(r1m)  : '', bgcolor=bg, text_color=f_ppct_col(r1m),      text_size=earnSz, text_halign=text.align_right)
    table.cell(t, 3, row, peersShow3M  ? f_ppct_str(r3m)  : '', bgcolor=bg, text_color=f_ppct_col(r3m),      text_size=earnSz, text_halign=text.align_right)
    table.cell(t, 4, row, peersShowRVol ? f_prvol_str(rv) : '', bgcolor=bg, text_color=f_prvol_col(rv),      text_size=earnSz, text_halign=text.align_right)
    table.cell(t, 5, row, peersShowRS   ? f_prs_str(rs)   : '', bgcolor=bg, text_color=f_prs_col(rs),        text_size=earnSz, text_halign=text.align_right)

// =============================================================================
// Tables
// =============================================================================
var table compactTable = table.new(getCorner(dashboardCorner), 1, 6, bgcolor=color.new(cleanTableBg, 100), border_width=0)
var table earningsTable    = table.new(getTablePosition(earningsTableCorner), 10, 22, bgcolor=color.new(cleanTableBg, 100), frame_color=cleanTableBorder, frame_width=1, border_color=cleanTableBorder, border_width=1)
var table wm_table1        = table.new(getTablePosition(wmPosition),          4, 1,  bgcolor=color.new(color.white, 100), border_width=0, border_color=color.new(color.white, 100))
var table peersTable       = table.new(getTablePosition(peersTablePos),       6, 23, bgcolor=color.new(cleanTableBg, 100), frame_color=cleanTableBorder, frame_width=1, border_color=cleanTableBorder, border_width=1)

if barstate.islast
    float burst_power_score = math.round(count_5p / 5 + count_10p / 2 + count_17p / 0.5)

    // ── Return periods ──
    int   threeMonthBars          = 63
    float highestHighInPeriod     = not na(close[threeMonthBars]) ? ta.highest(high, threeMonthBars + 1) : na
    float threeMonthReturn        = na(close[threeMonthBars]) or na(highestHighInPeriod) ? na : (highestHighInPeriod / close[threeMonthBars] - 1) * 100
    int   maxLookback             = 200
    float firstClosePrice         = bar_index >= maxLookback ? close[maxLookback] : na
    float highestHighFromListing  = ta.highest(high, maxLookback + 1)
    float returnFromListing       = na(firstClosePrice) or na(highestHighFromListing) or firstClosePrice == 0 ? na : (highestHighFromListing / firstClosePrice - 1) * 100
    float threeMonthReturnFinal   = na(threeMonthReturn) ? returnFromListing : threeMonthReturn

    // Format values for compact table — same caution-flag convention as
    // dtc aio.pine's compact dashboard: a stretched ADR or 3M return gets a
    // ⚠ suffix and the row's text recolored, instead of a plain number.
    bool  adrCaution      = swingAdrPercent >= 7
    bool  threeMonthCaution = not na(threeMonthReturnFinal) and threeMonthReturnFinal >= 80

    string rsValue = str.format('{0,number,0}', rs_rating)
    string rvolValue = na(swingRelVolume) ? '-' : str.format('{0,number,0}%', swingRelVolume)
    string adrValue = str.format('{0,number,0.0}%', swingAdrPercent) + (adrCaution ? ' ⚠' : '')
    string threeMonthValue = na(threeMonthReturnFinal) ? '-' : str.format('{0,number,0.00}%', threeMonthReturnFinal) + (threeMonthCaution ? ' ⚠' : '')
    string burstValue = str.tostring(math.round(burst_power_score))
    string floatPctValue = na(swingFloatPct) ? '-' : str.format('{0,number,0.0}%', swingFloatPct)

    color adrRowColor = adrCaution ? cleanTableNegative : cleanTableText
    color mmRowColor  = threeMonthCaution ? cleanTableNegative : cleanTableText

    // Update compact table — one row per metric (matches dtc aio.pine's
    // compactDashboard layout/theme instead of a single newline-joined cell).
    table.clear(compactTable, 0, 0, 0, 5)
    table.cell(compactTable, 0, 0, 'RS    - ' + rsValue,        text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left)
    table.cell(compactTable, 0, 1, 'RVol  - ' + rvolValue,      text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left)
    table.cell(compactTable, 0, 2, 'ADR   - ' + adrValue,       text_color=adrRowColor,    text_size=dashSz, text_halign=text.align_left)
    table.cell(compactTable, 0, 3, '3M%   - ' + threeMonthValue, text_color=mmRowColor,    text_size=dashSz, text_halign=text.align_left)
    table.cell(compactTable, 0, 4, 'Burst - ' + burstValue,     text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left)
    table.cell(compactTable, 0, 5, 'Float - ' + floatPctValue,  text_color=cleanTableText, text_size=dashSz, text_halign=text.align_left)

    // ── Earnings table ──
    if earningsTableEnabled
        table.clear(earningsTable, 0, 0, 9, 21)
        int firstDataRow = 1
        int qShow   = earningsQuarters
        int yCmp    = earningsPeriod == 'FY' ? 1 : 4
        string naStr = f_na_str()
        bool showQoQcols     = digitColQoQ and earningsPeriod == 'FQ' and not digitMsTable
        int  cEps    = 1
        int  cEpct   = digitColYoY ? 2 : -1
        int  cSal    = digitColYoY ? 3 : 2
        int  cSalpct = digitColYoY ? 4 : -1
        int  _nb     = digitColYoY ? 5 : 3
        int  cEqoq   = showQoQcols ? _nb     : -1
        int  cSqoq   = showQoQcols ? _nb + 1 : -1
        int  cEst    = -1
        int  cSurp   = -1
        if not earningsMiniMode
            string hdr0 = switch earningsTopLeft
                'Quarterly'  => 'Quarterly'
                'FF'         => validated_ff
                'Mcap'       => validated_mc
                'Float %'    => validated_float_pct
                'Avg $ Vol'  => validated_avg_dollar_vol
                =>              validated_mc
            ft(earningsTable, 0, 0, hdr0)
            if digitMsTable
                ft(earningsTable, cEps, 0, primaryIsPat ? 'PAT($Mil)' : 'EPS($)')
                if cEpct   >= 0
                    ft(earningsTable, cEpct,   0, '%Chg')
                ft(earningsTable, cSal, 0, 'Sales($Mil)')
                if cSalpct >= 0
                    ft(earningsTable, cSalpct, 0, '%Chg')
            else
                ft(earningsTable, cEps, 0, financial01)
                if cEpct   >= 0
                    ft(earningsTable, cEpct,   0, financial01 + ' YoY')
                ft(earningsTable, cSal, 0, 'Sales')
                if cSalpct >= 0
                    ft(earningsTable, cSalpct, 0, 'Sal YoY')
            if showQoQcols
                ft(earningsTable, cEqoq, 0, 'QoQ')
                ft(earningsTable, cSqoq, 0, 'QoQ')
            if cEst  >= 0
                ft(earningsTable, cEst,  0, 'Est')
            if cSurp >= 0
                ft(earningsTable, cSurp, 0, 'Surp%')
        else
            ft(earningsTable, 0,      0, '')
            ft(earningsTable, cEpct,  0, financial01 + ' YoY')
            ft(earningsTable, cSalpct,0, 'Sales YoY')
        for i = 0 to qShow - 1
            int    row     = i + firstDataRow
            int    dateVal = array.get(earningsDate, i)
            string dateStr = str.format('{0, date, MMM-yy}', dateVal)
            ftdate(earningsTable, 0, row, dateStr)
            if not earningsMiniMode
                fcell_eps_ms(earningsTable, cEps, row, arrayFinData1, i, yCmp)
                if digitColYoY
                    float eCur = array.get(arrayFinData1, i)
                    float ePrv = array.get(arrayFinData1, i + yCmp)
                    f_cell_pct_ms(earningsTable, cEpct, row, f_yoy_pct(eCur, ePrv), f_yoy_show_hash(eCur, ePrv, digitRemoveHash), naStr, i)
                if showQoQcols
                    f_cell_pct_ms(earningsTable, cEqoq, row, f_qoq_change(array.get(arrayFinData1, i), array.get(arrayFinData1, i + 1)), false, naStr, i)
                fcell_sales_ms(earningsTable, cSal, row, arrayFinData2, i, yCmp)
                if digitColYoY
                    float sCur = array.get(arrayFinData2, i)
                    float sPrv = array.get(arrayFinData2, i + yCmp)
                    f_cell_pct_ms(earningsTable, cSalpct, row, f_yoy_pct(sCur, sPrv), f_yoy_show_hash(sCur, sPrv, digitRemoveHash), naStr, i)
                if showQoQcols
                    f_cell_pct_ms(earningsTable, cSqoq, row, f_qoq_change(array.get(arrayFinData2, i), array.get(arrayFinData2, i + 1)), false, naStr, i)
                if cEst >= 0
                    float estVal = array.get(arrayEstimate, i)
                    table.cell(earningsTable, cEst, row, na(estVal) ? naStr : str.tostring(estVal, '0.##'), text_halign=text.align_center, text_color=cleanTableText, text_size=earnSz, bgcolor=f_table_row_bg(i))
                if cSurp >= 0
                    float estVal    = array.get(arrayEstimate, i)
                    float epsActual = array.get(arrayFinData1, i)
                    float surpPct   = not na(estVal) and estVal != 0 ? (epsActual - estVal) / math.abs(estVal) * 100 : na
                    string surpStr  = na(surpPct) ? naStr : (surpPct >= 0 ? '+' : '') + str.tostring(math.round(surpPct)) + '%'
                    table.cell(earningsTable, cSurp, row, surpStr, text_halign=text.align_center, text_color=f_pct_color(surpPct), text_size=earnSz, bgcolor=f_table_row_bg(i))
            else
                fyoy(earningsTable, cEpct,  row, arrayFinData1, i, yCmp)
                fyoy(earningsTable, cSalpct, row, arrayFinData2, i, yCmp)
        if digitShowGrossMargin
            int gmRow  = qShow + firstDataRow
            ft(earningsTable, 0, gmRow, 'GM%')
            for j = 0 to math.min(qShow, 4) - 1
                float gpVal = array.get(arrayGrossProfit, j)
                float salRaw = array.get(arrayFinData2, j) * 1000000.0
                float gmPct  = not na(gpVal) and salRaw > 0 ? gpVal / salRaw * 100 : na
                table.cell(earningsTable, j + 1, gmRow, na(gmPct) ? naStr : str.format('{0,number,0.0}%', gmPct), text_halign=text.align_center, text_color=cleanTableText, text_size=earnSz, bgcolor=f_table_row_bg(gmRow))
        if digitShowROE
            int roeRowIdx = qShow + firstDataRow + (digitShowGrossMargin ? 1 : 0)
            ft(earningsTable, 0, roeRowIdx, 'ROE%')
            for j = 0 to math.min(qShow, 4) - 1
                float roeVal = array.get(arrayROE, j)
                table.cell(earningsTable, j + 1, roeRowIdx, na(roeVal) ? naStr : str.format('{0,number,0.0}%', roeVal), text_halign=text.align_center, text_color=cleanTableText, text_size=earnSz, bgcolor=f_table_row_bg(roeRowIdx))
    else
        table.clear(earningsTable, 0, 0, 9, 21)

    // ── Watermark ──
    if showWatermark
        string wm_str1 = syminfo.basecurrency != '' ? syminfo.basecurrency + ' | ' + syminfo.currency : syminfo.ticker
        [wm_tfstr, wm_periodNum] = wm_getTimeFrame()
        float wm_chg = na(close[1]) or close[1] == 0 ? na : math.round((close / close[1] - 1) * 100, 2)
        string wm_chgStr = na(wm_chg) ? '' : str.format('{0,number,+0.##;-0.##}%', wm_chg)
        string wmSz = wmTextSize == 'Huge' ? size.huge : wmTextSize == 'Normal' ? size.normal : wmTextSize == 'Small' ? size.small : size.large
        table.cell(wm_table1, 0, 0, '',       text_color=cleanTableText, width=0, text_size=size.small)
        table.cell(wm_table1, 1, 0, wm_str1 + (wmShowTF ? ' ' + wm_periodNum + wm_tfstr : ''), width=0, text_color=cleanTableText, text_size=wmSz)
        table.cell(wm_table1, 2, 0, wmShowChange ? wm_chgStr : '', width=0, text_color=na(wm_chg) ? cleanTableText : wm_chg > 0 ? cleanTablePositive : cleanTableNegative, text_size=size.small)
        table.cell(wm_table1, 3, 0, wmSignature,  text_color=cleanTableText, width=0, text_size=size.small)
    else
        table.clear(wm_table1, 0, 0, 3, 0)

    // ── Peer table ──
    if showPeersTable
        table.clear(peersTable, 0, 0, 5, 22)

        // Industry name banner — strip __sector: prefix for sector-fallback entries
        string _rawName = not na(curInd) ? curInd.name : syminfo.industry != '' ? syminfo.industry : syminfo.sector
        string indName  = str.startswith(_rawName, '__sector:') ? str.replace(_rawName, '__sector:', '') : _rawName
        table.cell(peersTable, 0, 0, indName, bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_center)
        table.merge_cells(peersTable, 0, 0, 5, 0)

        // Fetch peers inside barstate.islast — dynamic_requests=true allows security calls in loops here too.
        // This avoids var-array state issues on historical bars.
        array<string> _pSym = array.new_string()
        array<float>  _pDay = array.new_float()
        array<float>  _p1M  = array.new_float()
        array<float>  _p3M  = array.new_float()
        array<float>  _pRV  = array.new_float()
        array<float>  _pRS  = array.new_float()
        
        // _peerSymbols is a var array<string> — always safe to iterate, never na
        // Profiler hotspot (~50% of total runtime): shrinking the
        // ta.percentrank() window (252 -> 63 bars) barely helped, because the
        // window length was never the cost driver. ANY ta.*() (stateful/
        // series) function used inside request.security() forces Pine to
        // walk that peer's ENTIRE available historical series just to
        // produce one merged value - a cost tied to how long the peer has
        // traded, not to the window you pass in. close/close[N]/volume are
        // cheap point-reads regardless of history length; ta.percentrank()
        // was the only thing forcing the expensive full-history replay.
        // Fix: drop it from the remote call entirely and rank peers locally
        // (below, after this loop) from the 3-month returns already being
        // fetched here - arguably more useful for a PEER table anyway, since
        // it ranks a stock against its own competitors instead of the whole
        // market.
        bool _needRVol = peersShowRVol or peersSortBy == 'RVol'
        int _fetchCount = 0
        for s in _peerSymbols
            if _fetchCount >= peersMaxShow + 1
                break
            [_c, _cp, _c1m, _c3m, _vol, _avg] = request.security(s, 'D',
                 [close, close[1], close[21], close[63], volume, _needRVol ? ta.sma(volume[1], 20) : na],
                 lookahead=barmerge.lookahead_on, ignore_invalid_symbol=true)
            float _dy  = na(_cp)  or _cp  == 0 ? na : (_c - _cp) / _cp * 100
            float _r1  = na(_c1m) or _c1m == 0 ? na : (_c - _c1m) / _c1m * 100
            float _r3  = na(_c3m) or _c3m == 0 ? na : (_c - _c3m) / _c3m * 100
            float _rv  = na(_avg) or _avg == 0 ? na : _vol / _avg * 100

            _pSym.push(s)
            _pDay.push(nz(_dy))
            _p1M.push(nz(_r1))
            _p3M.push(nz(_r3))
            _pRV.push(nz(_rv))
            _pRS.push(0.0)  // placeholder - overwritten by index below via .set()
            _fetchCount += 1

        // Local peer RS: percentile rank (0-100, same scale as before) of
        // each peer's 3-month return WITHIN the fetched peer group itself -
        // pure array math on data already fetched above, no remote stateful
        // function, so this costs essentially nothing.
        int _peerN = _p3M.size()
        if _peerN > 0
            array<int> _rsRankOrder = _p3M.sort_indices(order.ascending)
            for k = 0 to _peerN - 1
                int _origIdx = _rsRankOrder.get(k)
                float _pctRank = _peerN > 1 ? k / float(_peerN - 1) * 100.0 : 50.0
                _pRS.set(_origIdx, math.round(_pctRank))

        // Sort by selected option
        array<float> sortSrc = peersSortBy == 'Day%' ? _pDay : peersSortBy == '1M%' ? _p1M : peersSortBy == '3M%' ? _p3M : peersSortBy == 'RS' ? _pRS : _pRV
        array<int> ranked  = sortSrc.sort_indices(order.descending)

        // Calculate current symbol's own metrics
        float self_day_fixed = na(close[1])  or close[1]  == 0 ? na : (close - close[1])  / close[1]  * 100
        float self_1m_fixed  = na(close[21]) or close[21] == 0 ? na : (close - close[21]) / close[21] * 100
        float self_3m_fixed  = na(close[63]) or close[63] == 0 ? na : (close - close[63]) / close[63] * 100
        float self_rv_fixed  = swingRelVolume
        float self_rs_fixed  = math.round(rs_rating)

        // Sort markers
        string sortMarkDay = peersSortBy == 'Day%' ? ' ↓' : ''
        string sortMark1M  = peersSortBy == '1M%'  ? ' ↓' : ''
        string sortMark3M  = peersSortBy == '3M%'  ? ' ↓' : ''
        string sortMarkRV  = peersSortBy == 'RVol' ? ' ↓' : ''
        string sortMarkRS  = peersSortBy == 'RS'   ? ' ↓' : ''

        // Row 1: column headers
        table.cell(peersTable, 0, 1, 'Ticker',                                 bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_left)
        table.cell(peersTable, 1, 1, 'Day%' + sortMarkDay,                     bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_right)
        table.cell(peersTable, 2, 1, peersShow1M  ? '1M%'  + sortMark1M  : '', bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_right)
        table.cell(peersTable, 3, 1, peersShow3M  ? '3M%'  + sortMark3M  : '', bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_right)
        table.cell(peersTable, 4, 1, peersShowRVol ? 'RVol' + sortMarkRV : '', bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_right)
        table.cell(peersTable, 5, 1, peersShowRS   ? 'RS'   + sortMarkRS  : '', bgcolor=cleanTableHeaderBg, text_color=cleanTableHeaderText, text_size=earnSz, text_halign=text.align_right)

        // Row 2: current symbol (pinned, highlighted)
        f_peer_row(peersTable, 2, syminfo.ticker, self_day_fixed, self_1m_fixed, self_3m_fixed, self_rv_fixed, self_rs_fixed, true)

        // Rows 3+: sorted peers (skip current symbol to avoid duplication)
        int displayRow = 3
        int shown = 0
        for ri in ranked
            if shown >= peersMaxShow
                break
            string ticker = _pSym.get(ri)
            if ticker == syminfo.ticker
                continue
            float dv = _pDay.get(ri)
            float r1 = _p1M.get(ri)
            float r3 = _p3M.get(ri)
            float rv = _pRV.get(ri)
            float rs_val = _pRS.get(ri)
            f_peer_row(peersTable, displayRow, ticker, dv, r1, r3, rv, rs_val, false)
            displayRow += 1
            shown += 1
        // No peers found — self row is already pinned at row 2; nothing extra needed

// =============================================================================
// Earnings arrows
// =============================================================================
if enableArrowDisplay and isNewEarningsPrint
    float epsVal   = useQoQForArrow ? eps_qoq_q0 : eps_yoy_q0
    float salesVal = useQoQForArrow ? sales_qoq_q0 : sales_yoy_q0
    string displayText = financial01 + ' ' + (na(epsVal) ? 'N/A' : str.tostring(epsVal, '0') + '%') + (showSalesArrow ? '\nSales ' + (na(salesVal) ? 'N/A' : str.tostring(salesVal, '0') + '%') : '')
    color displayColor = na(epsVal) ? cleanTableText : epsVal >= 0 ? cleanTablePositive : cleanTableNegative
    label.new(bar_index, low, text=displayText, style=label.style_label_up, color=color.new(cleanTablePositive, 100), textcolor=displayColor, size=labelSz, xloc=xloc.bar_index, yloc=yloc.belowbar)

// =============================================================================
// Daily range label — fixed: security calls are top-level, not inside barstate.islast
// =============================================================================
var label dailyMoveLabel = na
if enableDailyMoveLabel and barstate.islast
    float curMove  = na(_dl_dl)  or _dl_dl  == 0 ? na : (_dl_dh  - _dl_dl)  / _dl_dl  * 100
    float prevMove = na(_dl_dl1) or _dl_dl1 == 0 ? na : (_dl_dh1 - _dl_dl1) / _dl_dl1 * 100
    string t1 = na(curMove)  ? 'DL N/A'  : str.format('DL {0,number,+0.00;-0.00}%',  curMove)
    string t2 = na(prevMove) ? 'PDL N/A' : str.format('PDL {0,number,+0.00;-0.00}%', prevMove)
    string labelText  = showPDL ? t1 + '\n' + t2 : t1
    color  dlColor    = na(curMove) ? cleanTableText : curMove > 0 ? cleanTablePositive : cleanTableNegative
    label.delete(dailyMoveLabel)
    dailyMoveLabel := label.new(bar_index, high, text=labelText, style=label.style_label_down, color=cleanTableBg, textcolor=dlColor, size=labelSz, xloc=xloc.bar_index, yloc=yloc.abovebar)

// =============================================================================
// Pivot high/low price points (Fred6724-style)
// =============================================================================
var pivotHighValues = array.new_float(0)
var pivotLowValues  = array.new_float(0)
string _hlSz = hlLabelSize == 'Tiny' ? size.tiny : hlLabelSize == 'Normal' ? size.normal : hlLabelSize == 'Large' ? size.large : size.small

if hlShowPoints and not timeframe.isweekly
    float pivotHigh = ta.pivothigh(high, hlPivotLen, hlPivotLen)
    float pivotLow  = ta.pivotlow(low,   hlPivotLen, hlPivotLen)
    // High Price Point
    if not na(pivotHigh)
        array.unshift(pivotHighValues, high[hlPivotLen])
        string textHigh = hlShowPct ? str.tostring(high[hlPivotLen], '0.00') + '\n' : str.tostring(high[hlPivotLen], '0.00')
        label.new(bar_index - hlPivotLen, array.get(pivotHighValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, text=textHigh, textcolor=hlLabelColor, size=_hlSz)
    // Low Price Point
    if not na(pivotLow)
        array.unshift(pivotLowValues, low[hlPivotLen])
        string textLow = '\n' + str.tostring(low[hlPivotLen], '0.00')
        label.new(bar_index - hlPivotLen, array.get(pivotLowValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, text=textLow, textcolor=hlLabelColor, color=color.rgb(0, 0, 0, 100), size=_hlSz)
    // Percentage Variation between last swing high and low
    float pHigh = array.size(pivotHighValues) > 0 ? array.get(pivotHighValues, 0) : na
    float pLow  = array.size(pivotLowValues)  > 0 ? array.get(pivotLowValues,  0) : na
    float prcVarHigh = not na(pHigh) and not na(pLow) and pLow != 0 ? (pHigh - pLow) / pLow * 100 : na
    float prcVarLow  = not na(pLow)  and not na(pHigh) and pHigh != 0 ? (pLow / pHigh - 1.0) * 100 : na
    if hlShowPct and not na(pivotHigh) and not na(prcVarHigh)
        string prcVarHighText = prcVarHigh >= 0 ? '+' + str.tostring(prcVarHigh, '0.0') + '%' : str.tostring(prcVarHigh, '0.0') + '%'
        color  colorPctUp     = prcVarHigh >= 0 ? hlPctPosColor : hlPctNegColor
        label.new(bar_index - hlPivotLen, array.get(pivotHighValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_none, text=prcVarHighText, textcolor=colorPctUp, size=_hlSz)
    if hlShowPct and not na(pivotLow) and not na(prcVarLow)
        string prcVarLowText = prcVarLow >= 0 ? '+' + str.tostring(prcVarLow, '0.0') + '%' : str.tostring(prcVarLow, '0.0') + '%'
        color  colorPctDn    = prcVarLow >= 0 ? hlPctPosColor : hlPctNegColor
        label.new(bar_index - hlPivotLen, array.get(pivotLowValues, 0), xloc=xloc.bar_index, yloc=yloc.price, style=label.style_label_center, text='\n\n\n' + prcVarLowText, textcolor=colorPctDn, color=color.rgb(0, 0, 0, 100), size=_hlSz)

// =============================================================================
// WEEKLY TIGHT CLOSES
// =============================================================================
var array<int> drawnWTCBars = array.new_int()

if wtcShow and timeframe.isweekly
    float WkO2  = open[2]
    float WkC   = close
    float WkC1  = close[1]
    float WkC2  = close[2]
    float WkH   = high
    float WkH1  = high[1]
    float WkH2  = high[2]
    float WkL   = low
    float WkL1  = low[1]
    float WkL2  = low[2]
    float atr   = ta.atr(14)

    bool condTightClose = WkC  < WkC1+(WkC1*atr/(close*2)) and WkC  > WkC1-(WkC1*atr/(close*2)) and WkC1 < WkC2+(WkC2*atr/(close*2)) and WkC1 > WkC2-(WkC2*atr/(close*2)) and WkC < WkC2+(WkC2*atr/(close*2)) and WkC > WkC2-(WkC2*atr/(close*2))
    bool condTightHigh  = WkH  < WkH1+(WkH1*atr/(close*2)) and WkH  > WkH1-(WkH1*atr/(close*2)) and WkH1 < WkH2+(WkH2*atr/(close*2)) and WkH1 > WkH2-(WkH2*atr/(close*2))
    bool condTightLow   = WkL  < WkL1+(WkL1*atr/(close*2)) and WkL  > WkL1-(WkL1*atr/(close*2)) and WkL1 < WkL2+(WkL2*atr/(close*2)) and WkL1 > WkL2-(WkL2*atr/(close*2))

    // First candle of the 3 must not be a wide body — wick total > 2× body, unless it's a tiny candle
    bool condFirstCandle = false
    if WkC2 >= WkO2
        condFirstCandle := WkH2 - WkC2 + WkO2 - WkL2 > 2*(WkC2 - WkO2) or (WkH2 - WkL2 < WkH1 - WkL1)
    if WkC2 < WkO2
        condFirstCandle := WkH2 - WkO2 + WkC2 - WkL2 > 2*(WkO2 - WkC2) or (WkH2 - WkL2 < WkH1 - WkL1)

    bool condWTC = condTightClose and (condTightHigh or condTightLow) and condFirstCandle

    if barstate.isconfirmed and condWTC and not array.includes(drawnWTCBars, bar_index)
        float boxHigh = math.max(WkH, math.max(WkH1, WkH2))
        float boxLow  = math.min(WkL, math.min(WkL1, WkL2))
        int leftBar   = bar_index[2]
        int rightBar  = bar_index
        box.new(leftBar, boxHigh, rightBar, boxLow, border_color=color.new(wtcColor, 20), border_width=1, border_style=line.style_dotted, bgcolor=color.new(wtcColor, 85))
        array.push(drawnWTCBars, bar_index)
````
