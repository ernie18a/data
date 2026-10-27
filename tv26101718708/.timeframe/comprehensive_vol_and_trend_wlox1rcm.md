# Comprehensive Vol and Trend

- url: https://www.tradingview.com/script/wlox1rCm-Comprehensive-Vol-and-Trend/
- type: indicator
- pine_id: PUB;ece49feb41624e24930c53aa7c9aba90
- version: 1.0

## Description

What it does:
A multi-metric dashboard panel that displays key volume, momentum, and relative strength data for any stock in a single customizable table — so you never have to hunt across multiple indicators.

---

Metrics (all toggleable)

Volume
$RVOL — Dollar volume today vs 21-day avg dollar volume. Captures large-cap stocks where share count alone is misleading
RVOL — Share volume today vs 21-day avg. Classic relative volume
Pace RVOL — Projects current volume to end of day at current pace, then vs 21-day avg. Shows true intensity regardless of time of day 

Price
Daily CHG% — Today's price change vs prior close

Market Context
QQQ Performance — QQQ's % change today. Quick read on broad market direction
Market Breadth — Ratio of new highs vs new lows (0–100 scale). >80 = strong tape, <20 = weak tape

Momentum & Relative Strength
RSI (14) — Standard momentum oscillator. >70 overbought, <30 oversold
RS Rating — Stock performance vs benchmark (SPY/QQQ/IWM) over your chosen lookback. 0–100 scale; >80 = strong outperformer
RS Trend — Direction RS is moving: ↑↑↑ accelerating, ↑ rising, ○ flat, ↓ weakening

---

Customization
Layout: Horizontal or Vertical
Table position: any corner
Font size: Tiny → Large
Color coding on/off (green/yellow/red thresholds)
Custom font color override
RS benchmark: SPY / QQQ / IWM
RS period: 10 / 21 / 42 / 63 / 126 / 189 / 252 days

---

Designed for
Pre-market prep and intraday monitoring. At a glance you can see: is this stock moving on real volume, is the tape strong, is it a relative strength leader or laggard — everything needed to qualify a SIP or EP candidate fast.

## Source Code

````pine


//@version=6
indicator('Comprehensive Vol and Trend', overlay=true)

// ─────────────────────────────────────────────────────────────────────────────
// DISPLAY SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
layoutMode     = input.string('Horizontal', 'Layout',         options=['Vertical', 'Horizontal'],                           group='Display')
tblPos         = input.string('Top Right',  'Table Position', options=['Top Right','Top Left','Bottom Right','Bottom Left'], group='Display')
fontSize       = input.string('Normal',     'Font Size',      options=['Tiny','Small','Normal','Large'],                    group='Display')
bgTransparency = input.int(10,              'Background Transparency (0=solid, 100=invisible)', minval=0, maxval=100,       group='Display')
useColorCoding = input.bool(true,           'Color Coding On/Off',  group='Display')
useCustomColor = input.bool(false,          'Override Font Color',  group='Display')
customColor    = input.color(color.white,   'Custom Font Color',    group='Display')
addEmptyRows   = input.bool(false,          'Add Empty Rows',       group='Display')
emptyRowPos    = input.string('Below',      'Empty Row Position',   options=['Above', 'Below'], group='Display')
emptyRowCount  = input.int(1,               'Number of Empty Rows', minval=1, maxval=5,         group='Display')

// ─────────────────────────────────────────────────────────────────────────────
// METRIC TOGGLES
// ─────────────────────────────────────────────────────────────────────────────
showDRVOL = input.bool(true, 'Show $ RVOL  ($vol / avg $vol)', group='Metrics')
showRVOL      = input.bool(true,  'Show RVOL   (vol / avg vol)',    group='Metrics')
showPaceRVOL  = input.bool(true,  'Show Pace RVOL (pace-adjusted)',  group='Metrics', tooltip='Projects current volume to end of day at current pace, then divides by 21-day avg. Shows true volume intensity regardless of time of day.')
showCHG    = input.bool(true,  'Show Daily Price Change %',   group='Metrics')
showQQQ  = input.bool(true,  'Show QQQ Performance',     group='Metrics')
showMKT  = input.bool(true,  'Show Market Breadth',       group='Metrics', tooltip='Ratio of new highs vs new lows (0-100). >80 = strong market, <20 = weak market. Provides market health context for individual stock analysis.')
showRSI  = input.bool(true,  'Show RSI (14)',             group='Metrics', tooltip='Relative Strength Index momentum oscillator. >70 = overbought, <30 = oversold. Different from Relative Strength (RS) rating.')
showRS   = input.bool(true,  'Show RS Rating',            group='Metrics', tooltip='Compares stock performance vs benchmark (SPY/QQQ/IWM) over selected timeframe. 0-100 scale where >80 = strong outperformer, <20 = weak underperformer.')
showRST  = input.bool(true,  'Show RS Trend',             group='Metrics')

// ─────────────────────────────────────────────────────────────────────────────
// RS SETTINGS
// ─────────────────────────────────────────────────────────────────────────────
rsBenchmark     = input.string('QQQ', 'RS Benchmark',    options=['SPY','QQQ','IWM'],                    group='RS Settings')
rsTimeframeDays = input.string('21',  'RS Period (Days)', options=['10','21','42','63','126','189','252'], group='RS Settings')

// ─────────────────────────────────────────────────────────────────────────────
// THEME / COLORS
// ─────────────────────────────────────────────────────────────────────────────
bgCol    = color.new(#2e2e2e, bgTransparency)
clrGreen = color.new(#00ff7f, 0)
clrRed   = color.new(color.red, 0)
clrYellow= color.new(color.yellow, 0)

baseTxt  = useCustomColor ? customColor : color.new(#ffffff, 0)
labelCol = baseTxt

applyCC(c) =>
    useColorCoding ? c : baseTxt

tablePosition = switch tblPos
    'Top Right'    => position.top_right
    'Top Left'     => position.top_left
    'Bottom Right' => position.bottom_right
    => position.bottom_left

tblSize = switch fontSize
    'Tiny'  => size.tiny
    'Small' => size.small
    'Large' => size.large
    => size.normal

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
[dClose, dVol, avgVol21, prevClose] = request.security(syminfo.tickerid, 'D',
     [close, volume, ta.sma(volume, 21)[1], close[1]],
     lookahead=barmerge.lookahead_off)

[qqqClose, qqqPrevClose] = request.security('QQQ', 'D',
     [close, close[1]],
     lookahead=barmerge.lookahead_off)

// Avg $ volume: average of (daily close * daily volume) over 21 days
avgDollarVol = request.security(syminfo.tickerid, 'D',
     ta.sma(close * volume, 21)[1],
     lookahead=barmerge.lookahead_off)

newHighs = request.security('ATHI.US', 'D', close, ignore_invalid_symbol=true)
newLows  = request.security('ATLO.US', 'D', close, ignore_invalid_symbol=true)
rsi14    = ta.rsi(close, 14)

// ─────────────────────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────────────────────
dollarVol   = dVol * dClose
rvolAvg     = avgVol21
rvolDollar  = (not na(avgDollarVol) and avgDollarVol != 0) ? dollarVol / avgDollarVol : na
rvolShares  = (not na(rvolAvg) and rvolAvg != 0) ? dVol / rvolAvg : na

// ─────────────────────────────────────────────────────────────────────────────
// PACE-ADJUSTED RVOL
// Projects today's partial volume to a full 390-min day, then vs 21d avg.
// Capped at 390 min after close so it equals raw RVol when day is done.
// ─────────────────────────────────────────────────────────────────────────────
etHour      = hour(timenow, 'America/New_York')
etMinute    = minute(timenow, 'America/New_York')
minsIntoDay = etHour * 60 + etMinute
minsElapsed = math.max(1, math.min(390, minsIntoDay - (9 * 60 + 30)))
paceVol     = not na(dVol) ? dVol / minsElapsed * 390 : na
paceRvol    = not na(paceVol) and not na(avgVol21) and avgVol21 != 0 ? paceVol / avgVol21 : na
priceChange = (not na(prevClose) and prevClose != 0) ? (dClose - prevClose) / prevClose * 100 : na
qqqChange   = (not na(qqqPrevClose) and qqqPrevClose != 0) ? (qqqClose - qqqPrevClose) / qqqPrevClose * 100 : na
mktScore    = (not na(newHighs) and not na(newLows) and (newHighs + newLows) > 0)
             ? math.round(newHighs / (newHighs + newLows) * 100) : na

// ─────────────────────────────────────────────────────────────────────────────
// RS RATING
// ─────────────────────────────────────────────────────────────────────────────
calcRS() =>
    rsLB       = str.tonumber(rsTimeframeDays)
    stockClose = request.security(syminfo.tickerid, 'D', close, lookahead=barmerge.lookahead_off)
    benchClose = request.security(rsBenchmark,      'D', close, lookahead=barmerge.lookahead_off)
    if na(stockClose[rsLB]) or na(benchClose[rsLB])
        float(na)
    else
        recentLB    = math.round(rsLB * 0.4)
        stockRecent = (stockClose / stockClose[recentLB] - 1) * 100
        stockOlder  = (stockClose[recentLB] / stockClose[rsLB] - 1) * 100
        benchRecent = (benchClose / benchClose[recentLB] - 1) * 100
        benchOlder  = (benchClose[recentLB] / benchClose[rsLB] - 1) * 100
        relRecent   = stockRecent - benchRecent
        relOlder    = stockOlder  - benchOlder
        weightedRel = relRecent * 0.6 + relOlder * 0.4
        raw         = math.max(0.0, math.min(100.0, 50.0 + weightedRel * 1.25))
        r5          = (stockClose / stockClose[5]  - 1) - (benchClose / benchClose[5]  - 1)
        r10         = (stockClose / stockClose[10] - 1) - (benchClose / benchClose[10] - 1)
        boost       = r5 > r10 ? 5.0 : r5 < r10 ? -5.0 : 0.0
        float(math.round(math.max(0.0, math.min(100.0, raw + boost))))

rsValue = calcRS()

// ─────────────────────────────────────────────────────────────────────────────
// RS TREND
// ─────────────────────────────────────────────────────────────────────────────
calcRSTrend() =>
    if na(rsValue) or na(rsValue[5]) or na(rsValue[10])
        '○'
    else
        d5  = rsValue - rsValue[5]
        d10 = rsValue - rsValue[10]
        if d5 > 5 and d10 > 8
            '↑↑↑'
        else if d5 > 3 and d10 > 5
            '↑↑'
        else if d5 > 1
            '↑'
        else if d5 < -5 and d10 < -8
            '↓↓↓'
        else if d5 < -3 and d10 < -5
            '↓↓'
        else if d5 < -1
            '↓'
        else
            '○'

rsTrend = calcRSTrend()

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
formatBig(n) =>
    if n >= 1e9
        str.tostring(math.round(n / 1e9), '#') + 'B'
    else if n >= 1e6
        str.tostring(math.round(n / 1e6), '#') + 'M'
    else if n >= 1e3
        str.tostring(math.round(n / 1e3), '#') + 'K'
    else
        str.tostring(math.round(n), '#')

gyrColor(val, highThresh, lowThresh) =>
    if na(val)
        color.gray
    else if val >= highThresh
        clrGreen
    else if val <= lowThresh
        clrRed
    else
        clrYellow

// ─────────────────────────────────────────────────────────────────────────────
// TABLE
// ─────────────────────────────────────────────────────────────────────────────
type Row
    string lbl
    string val
    color  col

var Row[] rows = array.new<Row>()
var table t    = table.new(tablePosition, 30, 30, border_width=0, frame_width=0)

if barstate.islast
    array.clear(rows)

    if showDRVOL
        _dRvolVal = (na(dollarVol) or na(avgDollarVol)) ? 'NA' : '$' + formatBig(dollarVol) + ' / $' + formatBig(avgDollarVol)
        _dRvolC   = na(rvolDollar) ? color.gray : rvolDollar >= 2.0 ? clrGreen : rvolDollar < 1.0 ? clrRed : baseTxt
        array.push(rows, Row.new('$RVOL', _dRvolVal, applyCC(_dRvolC)))

    if showRVOL
        _rvolVal = (na(dVol) or na(rvolAvg)) ? 'NA' : formatBig(dVol) + ' / ' + formatBig(rvolAvg)
        _rvolC   = na(rvolShares) ? color.gray : rvolShares >= 2.0 ? clrGreen : rvolShares < 1.0 ? clrRed : baseTxt
        array.push(rows, Row.new('RVOL', _rvolVal, applyCC(_rvolC)))

    if showPaceRVOL
        _paceStr = na(paceRvol) ? 'NA' : str.tostring(paceRvol, '#.##') + 'x'
        _paceC   = na(paceRvol) ? color.gray : paceRvol >= 2.0 ? clrGreen : paceRvol >= 1.0 ? clrYellow : clrRed
        array.push(rows, Row.new('Pace RVol', _paceStr, applyCC(_paceC)))

    if showCHG
        chgStr = na(priceChange) ? 'NA' : (priceChange > 0 ? '+' : '') + str.tostring(priceChange, '#.##') + '%'
        chgC   = na(priceChange) ? color.gray : priceChange > 0 ? clrGreen : priceChange < 0 ? clrRed : color.gray
        array.push(rows, Row.new('CHG%', chgStr, applyCC(chgC)))


    if showQQQ
        qqqStr = na(qqqChange) ? 'NA' : (qqqChange > 0 ? '+' : '') + str.tostring(qqqChange, '#.##') + '%'
        qqqC   = na(qqqChange) ? color.gray : qqqChange > 0 ? clrGreen : qqqChange < 0 ? clrRed : color.gray
        array.push(rows, Row.new('QQQ', qqqStr, applyCC(qqqC)))

    if showMKT
        array.push(rows, Row.new('BREADTH',
             na(mktScore) ? 'NA' : str.tostring(mktScore),
             applyCC(gyrColor(mktScore, 80, 20))))

    if showRSI
        array.push(rows, Row.new('RSI(14)',
             na(rsi14) ? 'NA' : str.tostring(rsi14, '#.0'),
             applyCC(gyrColor(rsi14, 70, 30))))

    if showRS
        array.push(rows, Row.new('RS',
             na(rsValue) ? 'NA' : str.tostring(rsValue),
             applyCC(gyrColor(rsValue, 80, 20))))

    if showRST
        rstRaw = na(rsValue) ? color.gray :
                 (rsValue - nz(rsValue[5], rsValue)) > 3  ? clrGreen  :
                 (rsValue - nz(rsValue[5], rsValue)) > 1  ? color.new(color.blue,   0) :
                 (rsValue - nz(rsValue[5], rsValue)) < -3 ? clrRed    :
                 (rsValue - nz(rsValue[5], rsValue)) < -1 ? clrYellow : color.gray
        array.push(rows, Row.new('RS TREND', rsTrend, applyCC(rstRaw)))

    table.clear(t, 0, 0, 29, 29)
    rowCount   = array.size(rows)
    isVertical = layoutMode == 'Vertical'

    padBefore = addEmptyRows and emptyRowPos == 'Above' ? emptyRowCount : 0
    padAfter  = addEmptyRows and emptyRowPos == 'Below' ? emptyRowCount : 0

    for i = 0 to rowCount - 1
        row = array.get(rows, i)
        if isVertical
            table.cell(t, 0, i + padBefore, row.lbl, text_color=labelCol, bgcolor=bgCol, text_size=tblSize, text_halign=text.align_right)
            table.cell(t, 1, i + padBefore, row.val, text_color=row.col,  bgcolor=bgCol, text_size=tblSize, text_halign=text.align_left)
        else
            table.cell(t, i, 0 + padBefore, row.lbl, text_color=labelCol, bgcolor=bgCol, text_size=tblSize, text_halign=text.align_center)
            table.cell(t, i, 1 + padBefore, row.val, text_color=row.col,  bgcolor=bgCol, text_size=tblSize, text_halign=text.align_center)

    clrTransparent = color.new(color.black, 100)
    if addEmptyRows
        if emptyRowPos == 'Above'
            for r = 0 to padBefore - 1
                if isVertical
                    table.cell(t, 0, r, '', bgcolor=clrTransparent, text_size=tblSize)
                    table.cell(t, 1, r, '', bgcolor=clrTransparent, text_size=tblSize)
                else
                    for c = 0 to rowCount - 1
                        table.cell(t, c, r, '', bgcolor=clrTransparent, text_size=tblSize)
        else
            afterRow = isVertical ? rowCount + padBefore : 2
            for r = afterRow to afterRow + padAfter - 1
                if isVertical
                    table.cell(t, 0, r, '', bgcolor=clrTransparent, text_size=tblSize)
                    table.cell(t, 1, r, '', bgcolor=clrTransparent, text_size=tblSize)
                else
                    for c = 0 to rowCount - 1
                        table.cell(t, c, r, '', bgcolor=clrTransparent, text_size=tblSize)
````
