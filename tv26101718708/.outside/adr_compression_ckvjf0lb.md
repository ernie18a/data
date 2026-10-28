# ADR Compression

- url: https://www.tradingview.com/script/ckVjF0lB-ADR-Compression/
- type: indicator
- pine_id: PUB;2b6f8f6446554816a4b85e92a2ec5a4c
- version: 1.0

## Description

ADR based indicator to identify tight areas based on the difference between the MA of the ADR of the last 5 days divided by the last 20 days of ADR

## Source Code

````pine
// ADR Trend  (dedicated pane)
// ---------------------------------------------------------------------------
// Fast line (day-by-day, 5-day MA, or custom) vs the 20-day average range, plotted as REAL
// ADR% on the pane's own auto-scaled axis. Because the values are real and the pane scales
// to them, you see:
//   - the TREND:  the 20-MA line rising = the stock's range is structurally expanding
//                 (waking up); falling = contracting. Works on daily and weekly.
//   - the TIGHTEN: the fast line dipping under the 20-MA (green fill = above / expanding,
//                 red fill = below / tightening). Day-by-day reacts fastest; 5-day is smoother.
//
// Run your RS line on price separately (your existing RS Rating, or the RS+ADR file with
// its ADR turned off). This pane is ADR only, on purpose, so the percent scale is honest.
//
//@version=6
indicator(title='ADR Trend', shorttitle='ADR Trend', overlay=false)

// ---- inputs ----
fastMode  = input.string('5-day MA', title='Fast Line', options=['Day-by-day (1)', '5-day MA', 'Custom MA'], group='ADR', tooltip='Day-by-day = today\'s raw range (most responsive, noisier). 5-day MA = the smoothed 5/20 like before. Custom = your own length.')
fastCustom= input.int(5,  title='Custom Fast Length', minval=1, group='ADR', tooltip='Used only when Fast Line = Custom MA.')
maLen     = input.int(20, title='MA Length', minval=1, group='ADR', tooltip='The average-range trend line (Minervini-standard 20). Its slope IS the ADR trend.')
showTrend = input.bool(true,  title='Show Long Trend MA', group='ADR')
trendLen  = input.int(50, title='Long Trend MA Length', minval=1, group='ADR', tooltip='Slower baseline to read the bigger ADR trend.')
expCol    = input.color(color.rgb(0, 200, 90), title='Above MA (expanding)', group='ADR', inline='c')
compCol   = input.color(color.rgb(255, 70, 70), title='Below MA (tightening)', group='ADR', inline='c')
maCol     = input.color(color.new(color.white, 0), title='20-MA Line', group='ADR')
trendCol  = input.color(color.new(color.gray, 35), title='Long Trend Line', group='ADR')
markTight = input.bool(true, title='Mark Tightening Onset', group='ADR')

gateRS    = input.bool(true, title='Tightening alert requires RS leading', group='Alert', tooltip='RS = the stock vs the benchmark, above its own 50-trend. Tight + RS leading = setup.')
benchSym  = input.symbol('NASDAQ:QQQ', title='RS Benchmark (alert gate only)', group='Alert')

// ---- ADR% (real values) ----
fastLen = switch fastMode
    'Day-by-day (1)' => 1
    '5-day MA'       => 5
    => fastCustom

f_adr(int len) => 100.0 * (ta.sma(high / low, len) - 1.0)
adrFast  = f_adr(fastLen)
adrMA    = f_adr(maLen)
adrTrend = f_adr(trendLen)

aboveMA = adrFast >= adrMA
dCol    = aboveMA ? expCol : compCol

pTrend = plot(showTrend ? adrTrend : na, title='Long Trend ADR%', color=trendCol, linewidth=1)
pMA    = plot(adrMA,   title='20-MA ADR%', color=maCol, linewidth=2)
pFast  = plot(adrFast, title='Fast ADR%', color=dCol,  linewidth=1)
fill(pFast, pMA, color=color.new(dCol, 80), title='ADR State')

tighten = ta.crossunder(adrFast, adrMA)
expand  = ta.crossover(adrFast, adrMA)
plotshape(markTight and tighten, title='Tightening onset', location=location.bottom, style=shape.triangledown, color=compCol, size=size.tiny)

// ---- lightweight RS gate (self-contained, not plotted) ----
bench   = request.security(benchSym, timeframe.period, close)
rsCurve = close / bench
rsLead  = rsCurve > ta.ema(rsCurve, 50)
tightSignal = tighten and (not gateRS or rsLead)
alertcondition(tightSignal, title='ADR Tightening (RS leading)', message='{{ticker}} daily ADR dropped below its 20-MA with RS leading - tightening')
alertcondition(expand,      title='ADR Expansion',               message='{{ticker}} daily ADR pushed above its 20-MA - range opening up')

// ---- last-value readout ----
var label tag = na
if (barstate.islast)
    label.delete(tag)
    fastTxt = fastLen == 1 ? 'Daily' : str.tostring(fastLen) + '-MA'
    tag := label.new(bar_index, adrFast, text=fastTxt + ' ' + str.tostring(adrFast, '#.#') + '%  /  ' + str.tostring(maLen) + '-MA ' + str.tostring(adrMA, '#.#') + '%', color=color.new(color.black, 100), textcolor=dCol, style=label.style_label_left, size=size.small)
````
