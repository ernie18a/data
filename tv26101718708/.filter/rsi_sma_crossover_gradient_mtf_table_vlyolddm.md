# RSI + SMA Crossover Gradient MTF Table

- url: https://www.tradingview.com/script/vLyOldDm-RSI-SMA-Crossover-Gradient-MTF-Table/
- type: indicator
- pine_id: PUB;e6386cc1e3764999b4dd7b1844973359
- version: 1.0

## Description

A multi-timeframe RSI indicator with SMA smoothing, crossover gradient fill, and a live MTF table.

FEATURES:
- RSI with custom SMA smoothing line
- Crossover Gradient Fill — color darkens as RSI moves away from cross point (bullish/bearish)
- MTF Table showing 1m, 5m, 15m, 1H, 4H timeframes simultaneously
- Each row shows: RSI value, SMA value, Diff (RSI−SMA), Slope direction, and Market State
- Market States: H-Bull, Bull, Bear, H-Bear based on RSI/SMA position relative to 50
- Table size adjustable (tiny to huge) — mobile friendly
- Table position fully customizable

HOW TO USE:
- RSI above SMA = Bullish momentum (green gradient)
- RSI below SMA = Bearish momentum (red gradient)
- H-Bull = Strong bull (both RSI & SMA above 50)
- H-Bear = Strong bear (both RSI & SMA below 50)
- Use MTF table to confirm trend across timeframes before entering a trade

## Source Code

````pine
//@version=6
indicator(title = 'RSI + SMA Crossover Gradient + MTF Table', shorttitle = 'RSI MTF', format = format.price, precision = 2)

//=============================================================================
// RSI Settings
//=============================================================================
GRP_RSI = 'RSI Settings'
rsiLengthInput = input.int(14, minval = 1, title = 'RSI Length', group = GRP_RSI)
rsiSourceInput = input.source(close, 'Source', group = GRP_RSI)
rsiTfInput     = input.timeframe('', 'RSI Timeframe (MTF)', group = GRP_RSI, tooltip = 'Leave empty to use chart timeframe.')

rsiLineColorInput = input.color(#7E57C2, 'RSI Line Color',    group = GRP_RSI)
maLineColorInput  = input.color(color.yellow, 'SMA Line Color', group = GRP_RSI)

upperBandInput = input.int(70, 'Upper Band',  group = GRP_RSI)
midBandInput   = input.int(50, 'Middle Band', group = GRP_RSI)
lowerBandInput = input.int(30, 'Lower Band',  group = GRP_RSI)

//=============================================================================
// SMA Smoothing
//=============================================================================
GRP_SMA = 'SMA Smoothing'
maLengthInput = input.int(14, 'SMA Length', minval = 1, group = GRP_SMA)

//=============================================================================
// Crossover Gradient
//=============================================================================
GRP_XG = 'Crossover Gradient'
startTranspInput = input.int(85, 'Start Transparency (Light)', minval = 0, maxval = 100, group = GRP_XG)
endTranspInput   = input.int(0,  'End Transparency (Dark)',    minval = 0, maxval = 100, group = GRP_XG)
capAt80          = input.bool(false, 'Cap Up Target at 80 (else 100)', group = GRP_XG)
resetOnReCross   = input.bool(true,  'Reset On Re-Cross', group = GRP_XG)
upGradColorInput = input.color(color.green, 'Bullish Gradient Color', group = GRP_XG)
dnGradColorInput = input.color(color.red,   'Bearish Gradient Color', group = GRP_XG)

//=============================================================================
// MTF Table
//=============================================================================
GRP_TBL = 'MTF Table'
showTable     = input.bool(true, 'Show MTF Table', group = GRP_TBL)
tablePosInput = input.string('middle_right', 'Table Position', options = ['top_right','middle_right','bottom_right','top_left','middle_left','bottom_left','top_center','middle_center','bottom_center'], group = GRP_TBL)
slopeLookback = input.int(3, 'Slope Lookback Bars', minval = 1, group = GRP_TBL)

// ── NEW: Size Controls ──────────────────────────────────────────────────────
tableFontSize = input.string('small', 'Table Font Size',
     options = ['tiny','small','normal','large','huge'],
     tooltip  = 'Mobile ke liye tiny ya small best hai.',
     group    = GRP_TBL)

tableCellPad  = input.string('Narrow', 'Table Cell Padding',
     options  = ['Narrow','Normal','Wide'],
     tooltip  = 'Narrow = chhoti cells, mobile ke liye theek hai.',
     group    = GRP_TBL)

showBorder    = input.bool(true, 'Show Table Border', group = GRP_TBL)
// ───────────────────────────────────────────────────────────────────────────

diffPosColor  = input.color(#089981, 'Diff Positive BG',  group = GRP_TBL)
diffNegColor  = input.color(#F23645, 'Diff Negative BG',  group = GRP_TBL)
slopePosColor = input.color(#089981, 'Slope Positive BG', group = GRP_TBL)
slopeNegColor = input.color(#F23645, 'Slope Negative BG', group = GRP_TBL)
neutralColor  = input.color(#787B86, 'Neutral BG',        group = GRP_TBL)

//=============================================================================
// Font size resolver
//=============================================================================
f_tsize(_s) =>
    _s == 'tiny'   ? size.tiny   :
     _s == 'small'  ? size.small  :
     _s == 'normal' ? size.normal :
     _s == 'large'  ? size.large  : size.huge

tSize = f_tsize(tableFontSize)

// Cell padding string (appended to values to fake width control)
// Pine has no direct cell-width API, so we pad text with spaces
padStr = tableCellPad == 'Wide' ? '  ' : tableCellPad == 'Normal' ? ' ' : ''

//=============================================================================
// RSI Core
//=============================================================================
f_rsi(_src, _len) =>
    _chg = ta.change(_src)
    _up  = ta.rma(math.max(_chg, 0.0), _len)
    _dn  = ta.rma(-math.min(_chg, 0.0), _len)
    _dn == 0.0 ? 100.0 : _up == 0.0 ? 0.0 : 100.0 - 100.0 / (1.0 + _up / _dn)

tfResolved = rsiTfInput != '' ? rsiTfInput : timeframe.period

rsi         = request.security(syminfo.tickerid, tfResolved, f_rsi(rsiSourceInput, rsiLengthInput),                       barmerge.gaps_off, barmerge.lookahead_off)
smoothingMA = request.security(syminfo.tickerid, tfResolved, ta.sma(f_rsi(rsiSourceInput, rsiLengthInput), maLengthInput), barmerge.gaps_off, barmerge.lookahead_off)

//=============================================================================
// Plot RSI, SMA, Bands, Background Fill
//=============================================================================
rsiPlot = plot(rsi,         'RSI',     color = rsiLineColorInput, editable = true)
maPlot  = plot(smoothingMA, 'RSI SMA', color = maLineColorInput,  editable = true)

rsiUpperBand = hline(upperBandInput, 'Upper Band',  color = #787B86)
midline      = hline(midBandInput,   'Middle Band', color = color.new(#787B86, 50))
rsiLowerBand = hline(lowerBandInput, 'Lower Band',  color = #787B86)

fill(rsiUpperBand, rsiLowerBand, color = color.rgb(126, 87, 194, 90), title = 'Band Background Fill')

//=============================================================================
// Crossover Gradient Fill (RSI x SMA)
//=============================================================================
crossUp = ta.crossover(rsi,  smoothingMA)
crossDn = ta.crossunder(rsi, smoothingMA)

var int   regime     = 0
var float crossLevel = na

if crossUp
    regime     := 1
    crossLevel := rsi
if crossDn
    regime     := -1
    crossLevel := rsi

if resetOnReCross
    if regime == 1 and rsi < smoothingMA
        regime     := 0
        crossLevel := na
    if regime == -1 and rsi > smoothingMA
        regime     := 0
        crossLevel := na

upTarget = capAt80 ? 80.0 : 100.0

float progress = 0.0
if regime == 1 and not na(crossLevel)
    denomUp = upTarget - crossLevel
    progress := denomUp != 0.0 ? (rsi - crossLevel) / denomUp : 1.0
else if regime == -1 and not na(crossLevel)
    denomDn = crossLevel
    progress := denomDn != 0.0 ? (crossLevel - rsi) / denomDn : 1.0

progress := math.max(0.0, math.min(1.0, progress))

tFloat = float(startTranspInput) - progress * float(startTranspInput - endTranspInput)
transp = math.max(0, math.min(100, int(math.round(tFloat))))

color xGradColor = na
if regime == 1
    xGradColor := color.new(upGradColorInput, transp)
else if regime == -1
    xGradColor := color.new(dnGradColorInput, transp)

fill(rsiPlot, maPlot, color = xGradColor, title = 'RSI x SMA Crossover Gradient')

//=============================================================================
// MTF Table
//=============================================================================
tblPos = tablePosInput == 'top_right'      ? position.top_right     :
         tablePosInput == 'middle_right'   ? position.middle_right  :
         tablePosInput == 'bottom_right'   ? position.bottom_right  :
         tablePosInput == 'top_left'       ? position.top_left      :
         tablePosInput == 'middle_left'    ? position.middle_left   :
         tablePosInput == 'bottom_left'    ? position.bottom_left   :
         tablePosInput == 'top_center'     ? position.top_center    :
         tablePosInput == 'middle_center'  ? position.middle_center :
                                             position.bottom_center

bWidth = showBorder ? 1 : 0
var table mtfTbl = table.new(tblPos, 6, 6, border_width = bWidth)

f_mtf_rsi(_tf) =>
    request.security(syminfo.tickerid, _tf, f_rsi(rsiSourceInput, rsiLengthInput), barmerge.gaps_off, barmerge.lookahead_off)

f_mtf_sma(_tf) =>
    request.security(syminfo.tickerid, _tf, ta.sma(f_rsi(rsiSourceInput, rsiLengthInput), maLengthInput), barmerge.gaps_off, barmerge.lookahead_off)

f_mtf_slope(_tf, _lb) =>
    request.security(syminfo.tickerid, _tf, ta.sma(f_rsi(rsiSourceInput, rsiLengthInput), maLengthInput) - ta.sma(f_rsi(rsiSourceInput, rsiLengthInput), maLengthInput)[_lb], barmerge.gaps_off, barmerge.lookahead_off)

f_state(_r, _s) =>
    string _st = ''
    if _r > _s
        _st := _r > 50 and _s > 50 ? 'H-Bull' : 'Bull'
    else if _s > _r
        _st := _r < 50 and _s < 50 ? 'H-Bear' : 'Bear'
    else
        _st := _r < 50 and _s < 50 ? 'H-Bear' : _r > 50 and _s > 50 ? 'H-Bull' : 'Bear'
    _st

f_state_bg(_st) =>
    _st == 'H-Bull' ? color.lime    :
     _st == 'Bull'   ? color.green   :
     _st == 'H-Bear' ? color.red     :
     _st == 'Bear'   ? color.maroon  : color.gray

f_slope_bg(_slope) =>
    _slope > 0 ? slopePosColor : _slope < 0 ? slopeNegColor : neutralColor

f_slope_arrow(_slope) =>
    _slope > 0 ? '▲ ' : _slope < 0 ? '▼ ' : '► '

f_diff_color(_d) =>
    _d > 0 ? diffPosColor : _d < 0 ? diffNegColor : neutralColor

r1   = f_mtf_rsi('1')
s1   = f_mtf_sma('1')
sl1  = f_mtf_slope('1', slopeLookback)
st1  = f_state(r1, s1)
d1   = r1 - s1

r5   = f_mtf_rsi('5')
s5   = f_mtf_sma('5')
sl5  = f_mtf_slope('5', slopeLookback)
st5  = f_state(r5, s5)
d5   = r5 - s5

r15  = f_mtf_rsi('15')
s15  = f_mtf_sma('15')
sl15 = f_mtf_slope('15', slopeLookback)
st15 = f_state(r15, s15)
d15  = r15 - s15

r60  = f_mtf_rsi('60')
s60  = f_mtf_sma('60')
sl60 = f_mtf_slope('60', slopeLookback)
st60 = f_state(r60, s60)
d60  = r60 - s60

r240 = f_mtf_rsi('240')
s240 = f_mtf_sma('240')
sl240= f_mtf_slope('240', slopeLookback)
st240= f_state(r240, s240)
d240 = r240 - s240

if barstate.islast
    if showTable
        table.cell(mtfTbl, 0, 0, padStr + 'TF'    + padStr, text_size = tSize, text_color = color.white, bgcolor = color.black)
        table.cell(mtfTbl, 1, 0, padStr + 'RSI'   + padStr, text_size = tSize, text_color = color.white, bgcolor = color.black)
        table.cell(mtfTbl, 2, 0, padStr + 'SMA'   + padStr, text_size = tSize, text_color = color.white, bgcolor = color.black)
        table.cell(mtfTbl, 3, 0, padStr + 'Diff'  + padStr, text_size = tSize, text_color = color.white, bgcolor = color.black)
        table.cell(mtfTbl, 4, 0, padStr + 'Slope' + padStr, text_size = tSize, text_color = color.white, bgcolor = color.black)
        table.cell(mtfTbl, 5, 0, padStr + 'ST'    + padStr, text_size = tSize, text_color = color.white, bgcolor = color.black)

        table.cell(mtfTbl, 0, 1, padStr + '1m'  + padStr, text_size = tSize)
        table.cell(mtfTbl, 1, 1, padStr + str.tostring(r1,  '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 2, 1, padStr + str.tostring(s1,  '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 3, 1, padStr + str.tostring(d1,  '+#.0;-#.0') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_diff_color(d1))
        table.cell(mtfTbl, 4, 1, padStr + f_slope_arrow(sl1) + str.tostring(sl1, '+#.00;-#.00') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_slope_bg(sl1))
        table.cell(mtfTbl, 5, 1, padStr + st1  + padStr, text_size = tSize, text_color = color.white, bgcolor = f_state_bg(st1))

        table.cell(mtfTbl, 0, 2, padStr + '5m'  + padStr, text_size = tSize)
        table.cell(mtfTbl, 1, 2, padStr + str.tostring(r5,  '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 2, 2, padStr + str.tostring(s5,  '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 3, 2, padStr + str.tostring(d5,  '+#.0;-#.0') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_diff_color(d5))
        table.cell(mtfTbl, 4, 2, padStr + f_slope_arrow(sl5) + str.tostring(sl5, '+#.00;-#.00') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_slope_bg(sl5))
        table.cell(mtfTbl, 5, 2, padStr + st5  + padStr, text_size = tSize, text_color = color.white, bgcolor = f_state_bg(st5))

        table.cell(mtfTbl, 0, 3, padStr + '15m' + padStr, text_size = tSize)
        table.cell(mtfTbl, 1, 3, padStr + str.tostring(r15, '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 2, 3, padStr + str.tostring(s15, '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 3, 3, padStr + str.tostring(d15, '+#.0;-#.0') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_diff_color(d15))
        table.cell(mtfTbl, 4, 3, padStr + f_slope_arrow(sl15) + str.tostring(sl15, '+#.00;-#.00') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_slope_bg(sl15))
        table.cell(mtfTbl, 5, 3, padStr + st15 + padStr, text_size = tSize, text_color = color.white, bgcolor = f_state_bg(st15))

        table.cell(mtfTbl, 0, 4, padStr + '1H'  + padStr, text_size = tSize)
        table.cell(mtfTbl, 1, 4, padStr + str.tostring(r60, '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 2, 4, padStr + str.tostring(s60, '#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 3, 4, padStr + str.tostring(d60, '+#.0;-#.0') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_diff_color(d60))
        table.cell(mtfTbl, 4, 4, padStr + f_slope_arrow(sl60) + str.tostring(sl60, '+#.00;-#.00') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_slope_bg(sl60))
        table.cell(mtfTbl, 5, 4, padStr + st60 + padStr, text_size = tSize, text_color = color.white, bgcolor = f_state_bg(st60))

        table.cell(mtfTbl, 0, 5, padStr + '4H'  + padStr, text_size = tSize)
        table.cell(mtfTbl, 1, 5, padStr + str.tostring(r240,'#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 2, 5, padStr + str.tostring(s240,'#.0') + padStr, text_size = tSize)
        table.cell(mtfTbl, 3, 5, padStr + str.tostring(d240,'+#.0;-#.0') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_diff_color(d240))
        table.cell(mtfTbl, 4, 5, padStr + f_slope_arrow(sl240) + str.tostring(sl240,'+#.00;-#.00') + padStr, text_size = tSize, text_color = color.white, bgcolor = f_slope_bg(sl240))
        table.cell(mtfTbl, 5, 5, padStr + st240 + padStr, text_size = tSize, text_color = color.white, bgcolor = f_state_bg(st240))
    else
        table.clear(mtfTbl, 0, 0, 5, 5)
````
