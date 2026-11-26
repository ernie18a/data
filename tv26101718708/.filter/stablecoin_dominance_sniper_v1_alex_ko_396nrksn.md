# Stablecoin Dominance Sniper v1 [Alex Ko]

- url: https://www.tradingview.com/script/396nrKsn-stablecoin-dominance-sniper-v1-alex-ko/
- type: indicator
- pine_id: PUB;ae2543c8d2f0449aa4b69237eb436c92
- version: 3.0

## Description

[b]Stablecoin Dominance Sniper v1[/b]

Buy/Sell labels on any coin chart, driven by reversals of stablecoin dominance (CRYPTOCAP:USDT.D + USDC.D). Dominance turning up means money moving into cash — Sell; turning down means money leaving cash for risk — Buy.

The reversal is a trailing extreme with an ATR-sized threshold, not a moving-average crossover: while dominance rises, ext = max(ext, close) and a retracement of ext − close >= ATR × mult flips the phase (mirrored when it falls). Signal lag therefore equals the pullback itself rather than an averaging window, and the threshold rescales with volatility on its own.

One setting matters: Reversal threshold, ATR × (default 2.0, sensible range 1.0–3.5) — lower is earlier and noisier, higher is later and cleaner. Modes: sum of both indices, either one alone, or both with confirmation. The panel shows pullback maturity, so you watch a signal build before it prints; alerts fire at 80 % of the threshold and on the reversal itself.

Pine v6, two request.security calls, lookahead_off, no repainting. This is context, not a standalone entry — strongest on altcoins, 1H and above.

Not financial advice. Test on your own instruments and timeframes.

## Source Code

````pine
// ═══════════════════════════════════════════════════════════════════════════
//  Stablecoin Dominance Sniper v5 — ATR trailing from the dominance extreme
//  ---------------------------------------------------------------------
//  Buy/Sell labels on the coin's chart driven by reversals of the stablecoin
//  dominance indices (USDT.D / USDC.D). Dominance turns up (money moves into
//  cash) → Sell the coin; dominance turns down → Buy.
//
//  Detector — a trailing extreme with an ATR-sized threshold:
//    dominance rising:  ext = max(ext, close);  ext − close >= ATR*mult → turn down
//    dominance falling: ext = min(ext, close);  close − ext >= ATR*mult → turn up
//
//  Signal lag equals exactly the size of the pullback from the extreme — not the
//  length of an averaging window, as in the moving-average stack of v1. The ATR
//  threshold adapts to volatility on its own: in a quiet market a small pullback
//  counts as a reversal, in a violent one proportionally more is required.
//
//  v1.1 — customisable signal text, marker style (label / arrow / triangle / dot /
//  diamond / cross) and size; text sizes of labels and the panel are adjustable.

// ═══════════════════════════════════════════════════════════════════════════

//@version=6
indicator('Stablecoin Dominance Sniper v1.1 [Alex Ko]', overlay = true, max_bars_back = 1000, max_labels_count = 500)


// ═══════════════════════════════════════════════════════════════
//  DATA SOURCE
// ═══════════════════════════════════════════════════════════════
var string GRP_SRC = 'Source (dominance indices)'

symUsdt = input.symbol('CRYPTOCAP:USDT.D', 'USDT.D index', group = GRP_SRC,
     tooltip = 'Symbol used as the USDT dominance series.\n' +
               'Default CRYPTOCAP:USDT.D — share of total crypto market cap held in USDT.\n' +
               'Replace it only if you want to drive the detector with another index.')

symUsdc = input.symbol('CRYPTOCAP:USDC.D', 'USDC.D index', group = GRP_SRC,
     tooltip = 'Symbol used as the USDC dominance series.\n' +
               'Used in the "Sum", "USDC.D only" and "Confirmation" modes, and always\n' +
               'shown on the info panel.')

MODE_SUM  = 'Sum of USDT.D + USDC.D'
MODE_USDT = 'USDT.D only'
MODE_USDC = 'USDC.D only'
MODE_CONF = 'Both, with confirmation (signal when they agree)'

srcMode = input.string(MODE_SUM, 'Mode', options = [MODE_SUM, MODE_USDT, MODE_USDC, MODE_CONF], group = GRP_SRC,
     tooltip = 'Which series the reversal detector runs on.\n\n' +
               'Sum — total stablecoin dominance, the default and the most robust.\n' +
               'USDT.D only / USDC.D only — a single index, computed in its own context\n' +
               'on the native bars of that symbol.\n' +
               'Both with confirmation — the signal fires the moment both indices enter\n' +
               'the same phase for the first time: fewer signals, later, but cleaner.')

calcTf = input.timeframe('', 'Calculation timeframe', group = GRP_SRC,
     tooltip = 'Empty — compute on the current chart timeframe.\n' +
               'You can pin a higher timeframe (60, 240): the ATR threshold is then taken\n' +
               'from that timeframe, so dominance signals stop twitching on lower ones.')

confirmClose = input.bool(true, 'Confirm signal on bar close', group = GRP_SRC,
     tooltip = 'ON: the label appears after the bar closes and is placed back on its own\n' +
               'bar (offset = -1). Nothing repaints.\n' +
               'OFF: the label appears intrabar and can disappear before the bar closes.')

invert = input.bool(true, 'Invert signals for the coin', group = GRP_SRC,
     tooltip = 'ON: rising stablecoin dominance = Sell on the coin (money leaving risk).\n' +
               'Turn it OFF to check the labels against the dominance index itself —\n' +
               'they must sit right after its own peaks and troughs.')


// ═══════════════════════════════════════════════════════════════
//  REVERSAL DETECTOR
// ═══════════════════════════════════════════════════════════════
var string GRP_DET = 'Reversal detector'

atrLen = input.int(14, 'Dominance ATR length', minval = 1, group = GRP_DET,
     tooltip = 'Window used to measure the typical move of dominance.\n' +
               'This is not a moving-average period: the signal is always read off the\n' +
               'latest bar, the window only sets the scale of the threshold.\n' +
               'Larger — a steadier threshold, slower to react to a change of volatility.')

atrMult = input.float(2.0, 'Reversal threshold, ATR x', minval = 0.1, step = 0.1, group = GRP_DET,
     tooltip = 'THE MAIN SETTING. How many ATRs dominance must retrace from its extreme\n' +
               'for a reversal to count. Lower — earlier and more frequent signals,\n' +
               'higher — rarer and more reliable. This is also the signal lag.\n' +
               'Sensible range is roughly 1.0–3.5; start at 2.0.')

minFlipPct = input.float(0.0, 'Minimum threshold, % of dominance level', minval = 0.0, step = 0.05, group = GRP_DET,
     tooltip = 'Safety net against a degenerate ATR: on lower timeframes CRYPTOCAP indices\n' +
               'stay flat for long stretches, ATR collapses, and any micro-move could count\n' +
               'as a reversal. The effective threshold becomes max(ATR x mult, this %).\n' +
               '0 — disabled. Reasonable values for low timeframes: 0.1–0.3.')


// ═══════════════════════════════════════════════════════════════
//  APPEARANCE
// ═══════════════════════════════════════════════════════════════
var string GRP_UI = 'Appearance'

showSignals = input.bool(true, 'Signal markers', group = GRP_UI,
     tooltip = 'Draw the Buy/Sell markers on the chart. Turn off to keep only the alerts\n' +
               'and the info panel.')

STY_LABEL = 'Label'
STY_ARROW = 'Arrow'
STY_TRI   = 'Triangle'
STY_DOT   = 'Dot'
STY_DIAM  = 'Diamond'
STY_CROSS = 'Cross'

markerStyle = input.string(STY_LABEL, 'Marker style',
     options = [STY_LABEL, STY_ARROW, STY_TRI, STY_DOT, STY_DIAM, STY_CROSS], group = GRP_UI,
     tooltip = 'Label — a coloured tag with the signal text inside (the classic look).\n' +
               'Arrow / Triangle / Dot / Diamond / Cross — a compact marker in the signal\n' +
               'colour: Buy below the bar, Sell above it. For a subtle look pick Dot or\n' +
               'Arrow and set "Label size" to Tiny or Small.')

lblSizeOpt = input.string('Normal', 'Label size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = GRP_UI,
     tooltip = 'Size of the signal markers and their text.')

txtBuy = input.string('Buy', 'Buy text', group = GRP_UI, inline = 'txt',
     tooltip = 'Text printed on the Buy / Sell markers — any word, ticker or emoji.\n' +
               'Type \\n to break the text into two lines. Leave empty for no text.')

txtSell = input.string('Sell', 'Sell text', group = GRP_UI, inline = 'txt')

showMarkerTxt = input.bool(false, 'Show text next to compact markers', group = GRP_UI,
     tooltip = 'Applies to every style except Label. OFF — a bare marker without text,\n' +
               'the most unobtrusive option. ON — the text is printed beside the marker.')

colBuy = input.color(color.green, 'Buy', group = GRP_UI, inline = 'col',
     tooltip = 'Colour of the Buy marker (dominance turned down — risk-on).')

colSell = input.color(color.red, 'Sell', group = GRP_UI, inline = 'col',
     tooltip = 'Colour of the Sell marker (dominance turned up — risk-off).')

colLblTxt = input.color(color.white, 'Label text', group = GRP_UI, inline = 'col',
     tooltip = 'Text colour inside the Label style. Compact markers print their text\n' +
               'in the marker colour.')

showBg = input.bool(false, 'Highlight dominance phase', group = GRP_UI,
     tooltip = 'Tints the chart background with the current dominance phase.\n' +
               'Red — dominance rising (risk-off), green — falling (risk-on).')

showTable = input.bool(true, 'Info panel', group = GRP_UI,
     tooltip = 'Table with the level and phase of each index, the phase of the selected\n' +
               'mode, how mature the current pullback is, and the last signal.')

tablePos = input.string('Top right', 'Panel position',
     options = ['Top right', 'Top left', 'Bottom right', 'Bottom left'], group = GRP_UI,
     tooltip = 'Corner of the chart the info panel is anchored to.')

tblSizeOpt = input.string('Normal', 'Table text size',
     options = ['Tiny', 'Small', 'Normal', 'Large', 'Huge'], group = GRP_UI,
     tooltip = 'Text size of the info panel.')

toSize(s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        'Huge'   => size.huge
        => size.normal

lblSize = toSize(lblSizeOpt)
tblSize = toSize(tblSizeOpt)


// ═══════════════════════════════════════════════════════════════
//  DEBUG
// ═══════════════════════════════════════════════════════════════
var string GRP_DBG = 'Debug'

showCurve = input.bool(false, 'Plot the dominance curve on the chart', group = GRP_DBG,
     tooltip = 'The curve is normalised into the price range of the last N bars and drawn\n' +
               'over the coin chart. Use it to see where every label came from: each one\n' +
               'must sit right after a local extreme of the curve.')

invertCurve = input.bool(true, 'Flip the curve', group = GRP_DBG,
     tooltip = 'Flipped dominance visually moves in the same direction as price, which\n' +
               'makes the comparison easier. Turn off to see the raw shape.')

normLen = input.int(200, 'Normalisation window, bars', minval = 10, group = GRP_DBG,
     tooltip = 'How many bars of price and dominance are used to scale the debug curve.\n' +
               'Affects the plot only — the detector never uses it.')


// ═══════════════════════════════════════════════════════════════
//  DETECTOR: TRAILING FROM THE EXTREME
// ═══════════════════════════════════════════════════════════════

// Returns: [turn up, turn down, direction (1/-1), pullback maturity 0..1]
//
// ATR is smoothed with SMA rather than RMA: in "Sum" mode the series is computed on
// the current chart's bars, and while the index has no history the true range is na.
// RMA is recursive — a single na stays in it forever and the detector would go silent
// over the whole history. SMA recovers atrLen bars after the data appears.
f_flip(float h, float l, float c) =>
    tr   = math.max(h - l, math.max(math.abs(h - nz(c[1], c)), math.abs(l - nz(c[1], c))))
    atrD = ta.sma(tr, atrLen)

    var bool  inited = false
    var int   dir    = 1
    var float ext    = 0.0

    thr = math.max(nz(atrD) * atrMult, nz(c) * minFlipPct / 100)

    bool flipUp = false
    bool flipDn = false

    if not inited
        // Starting direction is taken from the last step of the series; if it guesses
        // wrong, the detector corrects itself on the very first threshold-sized pullback
        if not na(atrD) and not na(c) and thr > 0
            inited := true
            dir    := c >= nz(c[1], c) ? 1 : -1
            ext    := c
    else if not na(c) and thr > 0
        // na bars (the index has no data) are simply skipped: the extreme and the
        // direction freeze until the next live bar
        if dir == 1
            ext := math.max(ext, c)
            if ext - c >= thr
                dir    := -1
                ext    := c
                flipDn := true
        else
            ext := math.min(ext, c)
            if c - ext >= thr
                dir    := 1
                ext    := c
                flipUp := true

    mat = inited and not na(c) and thr > 0 ? math.min(math.abs(c - ext) / thr, 1.0) : 0.0
    [flipUp, flipDn, dir, mat]

// Wrapper for request.security: signals plus the raw HLC in a single request
f_pack(float h, float l, float c) =>
    [fUp, fDn, d, m] = f_flip(h, l, c)
    [fUp, fDn, d, m, h, l, c]


// ═══════════════════════════════════════════════════════════════
//  LOADING THE INDICES
// ═══════════════════════════════════════════════════════════════
tfCalc = calcTf == '' ? timeframe.period : calcTf

// Single indices are computed in their own context — on their native bars
[usdtUp, usdtDn, usdtDir, usdtMat, hT, lT, cT] = request.security(symUsdt, tfCalc, f_pack(high, low, close), lookahead = barmerge.lookahead_off)
[usdcUp, usdcDn, usdcDir, usdcMat, hC, lC, cC] = request.security(symUsdc, tfCalc, f_pack(high, low, close), lookahead = barmerge.lookahead_off)

// The sum runs on the current chart's bars (two symbols cannot be added inside one request)
[sumUp, sumDn, sumDir, sumMat] = f_flip(hT + hC, lT + lC, cT + cC)

useUsdt = srcMode == MODE_USDT
useUsdc = srcMode == MODE_USDC
useConf = srcMode == MODE_CONF

// Confirmation: the moment both indices are in the same phase for the first time
bothUp = usdtDir == 1 and usdcDir == 1
bothDn = usdtDir == -1 and usdcDir == -1
confUp = bothUp and not bothUp[1]
confDn = bothDn and not bothDn[1]

domUpRaw = useUsdt ? usdtUp  : useUsdc ? usdcUp  : useConf ? confUp  : sumUp
domDnRaw = useUsdt ? usdtDn  : useUsdc ? usdcDn  : useConf ? confDn  : sumDn
domDir   = useUsdt ? usdtDir : useUsdc ? usdcDir : useConf ? (bothUp ? 1 : bothDn ? -1 : 0) : sumDir
domMat   = useUsdt ? usdtMat : useUsdc ? usdcMat : useConf ? math.min(usdtMat, usdcMat) : sumMat

// Strict alternation. Single detectors alternate by construction, but in confirmation
// mode two identical signals in a row are possible (the indices diverged and agreed
// again in the same direction) — suppressed here
var int lastSide = 0
domUp = domUpRaw and lastSide != 1
domDn = domDnRaw and lastSide != -1
if domUp
    lastSide := 1
if domDn
    lastSide := -1


// ═══════════════════════════════════════════════════════════════
//  SIGNALS ON THE COIN
// ═══════════════════════════════════════════════════════════════
// Inversion: rising stablecoin dominance = risk-off = bad for the coin
sigBuy  = invert ? domDn : domUp
sigSell = invert ? domUp : domDn

// Which signal is currently maturing (for the panel and the early alert)
matIsBuy = invert ? domDir == 1 : domDir == -1

buyDraw  = confirmClose ? sigBuy[1]  : sigBuy
sellDraw = confirmClose ? sigSell[1] : sigSell
offs     = confirmClose ? -1 : 0

// Markers are drawn with label.new rather than plotshape: plotshape only accepts
// constant text and size, so neither could be taken from the inputs
isLabelStyle = markerStyle == STY_LABEL

f_style(bool isBuy) =>
    switch markerStyle
        STY_ARROW => isBuy ? label.style_arrowup    : label.style_arrowdown
        STY_TRI   => isBuy ? label.style_triangleup : label.style_triangledown
        STY_DOT   => label.style_circle
        STY_DIAM  => label.style_diamond
        STY_CROSS => label.style_xcross
        =>           isBuy ? label.style_label_up   : label.style_label_down

f_text(string t) =>
    isLabelStyle or showMarkerTxt ? str.replace_all(t, '\\n', '\n') : ''

f_marker(bool isBuy) =>
    col = isBuy ? colBuy : colSell
    label.new(bar_index + offs, isBuy ? low : high, f_text(isBuy ? txtBuy : txtSell),
         yloc = isBuy ? yloc.belowbar : yloc.abovebar, style = f_style(isBuy),
         color = col, textcolor = isLabelStyle ? colLblTxt : col, size = lblSize)

if showSignals and buyDraw
    f_marker(true)
if showSignals and sellDraw
    f_marker(false)

bgcolor(showBg ? (domDir == 1 ? color.new(color.red, 92) : domDir == -1 ? color.new(color.green, 92) : na) : na, title = 'Dominance phase')

// Last signal — for the panel
var int lastSigBar = -1
var int lastSigDir = 0
if buyDraw
    lastSigBar := bar_index + offs
    lastSigDir := 1
if sellDraw
    lastSigBar := bar_index + offs
    lastSigDir := -1


// ═══════════════════════════════════════════════════════════════
//  DEBUG DOMINANCE CURVE
// ═══════════════════════════════════════════════════════════════
domClose = useUsdt ? cT : useUsdc ? cC : cT + cC

hiP  = ta.highest(high, normLen)
loP  = ta.lowest(low,  normLen)
hiD  = ta.highest(domClose, normLen)
loD  = ta.lowest(domClose,  normLen)
rngD = hiD - loD

normD    = rngD > 0 ? (domClose - loD) / rngD : 0.5
curveVal = invertCurve ? 1 - normD : normD
domCurve = loP + curveVal * (hiP - loP)

plot(showCurve ? domCurve : na, 'Dominance (normalised)', color = color.new(color.orange, 30), linewidth = 1)


// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
// Early alert: the pullback has covered 80 % of the threshold — a signal is close
readyBuy  = domDir != 0 and matIsBuy     and domMat >= 0.8
readySell = domDir != 0 and not matIsBuy and domMat >= 0.8

alertcondition(sigBuy,  'SDS v1.1: Buy',  'SDS v1.1: stablecoin dominance reversed — Buy the coin')
alertcondition(sigSell, 'SDS v1.1: Sell', 'SDS v1.1: stablecoin dominance reversed — Sell the coin')
alertcondition(readyBuy  and not readyBuy[1],  'SDS v1.1: Buy approaching (80 %)',  'SDS v1.1: dominance pullback passed 80 % of the threshold — Buy approaching')
alertcondition(readySell and not readySell[1], 'SDS v1.1: Sell approaching (80 %)', 'SDS v1.1: dominance pullback passed 80 % of the threshold — Sell approaching')


// ═══════════════════════════════════════════════════════════════
//  INFO PANEL
// ═══════════════════════════════════════════════════════════════
f_phase(int p) =>
    p == 1 ? 'Rising [^]' : p == -1 ? 'Falling [v]' : 'Neutral [~]'

f_phaseCol(int p) =>
    p == 1 ? color.red : p == -1 ? color.green : color.silver

posTable = switch tablePos
    'Top left'      => position.top_left
    'Bottom right'  => position.bottom_right
    'Bottom left'   => position.bottom_left
    =>                 position.top_right

var table infoTable = table.new(posTable, 2, 6, border_width = 1)

if showTable and barstate.islast
    matTxt = domDir == 0 ? '—' : str.tostring(domMat * 100, '#') + ' %   -> ' + (matIsBuy ? 'Buy' : 'Sell')
    lastTxt = lastSigDir == 0 ? '—' :
         (lastSigDir == 1 ? 'Buy, ' : 'Sell, ') + str.tostring(bar_index - lastSigBar) + ' bars ago'

    table.cell(infoTable, 0, 0, 'SDS v1.1',  text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = tblSize)
    table.cell(infoTable, 1, 0, tfCalc,    text_color = color.white, bgcolor = color.new(color.gray, 30), text_size = tblSize)

    table.cell(infoTable, 0, 1, 'USDT.D', text_color = color.silver, text_size = tblSize)
    table.cell(infoTable, 1, 1, str.tostring(cT, '#.###') + ' %  ' + f_phase(usdtDir), text_color = f_phaseCol(usdtDir), text_size = tblSize)

    table.cell(infoTable, 0, 2, 'USDC.D', text_color = color.silver, text_size = tblSize)
    table.cell(infoTable, 1, 2, str.tostring(cC, '#.###') + ' %  ' + f_phase(usdcDir), text_color = f_phaseCol(usdcDir), text_size = tblSize)

    table.cell(infoTable, 0, 3, 'Mode phase', text_color = color.silver, text_size = tblSize)
    table.cell(infoTable, 1, 3, f_phase(domDir) + (domDir == 1 ? '  risk-off' : domDir == -1 ? '  risk-on' : ''),
         text_color = f_phaseCol(domDir), text_size = tblSize)

    table.cell(infoTable, 0, 4, 'Pullback maturity', text_color = color.silver, text_size = tblSize)
    table.cell(infoTable, 1, 4, matTxt,
         text_color = domMat >= 0.8 ? color.orange : color.silver, text_size = tblSize)

    table.cell(infoTable, 0, 5, 'Last signal', text_color = color.silver, text_size = tblSize)
    table.cell(infoTable, 1, 5, lastTxt,
         text_color = lastSigDir == 1 ? color.green : lastSigDir == -1 ? color.red : color.silver, text_size = tblSize)
````
