# SMT Divergence 3-Way + Key Levels, Killzones & Structure

- url: https://www.tradingview.com/script/Q322Hy2o-SMT-Divergence-3-Way-Key-Levels-Killzones-Structure/
- type: indicator
- pine_id: PUB;1771e4567ec5467baa80a9b3db21a4d6
- version: 2.0

## Description

An ICT-oriented toolkit for index futures, built around three-way SMT divergence with the supporting context needed to act on it.

SMT Divergence Compares your chart against the other two legs of the ES/NQ/YM family, resolved automatically and matched micro to micro. On MES you get MNQ and MYM; on MNQ you get MES and MYM. Four divergence types, each independently toggleable:
    •    Internal SMT on minor swings
    •    External SMT on major structural swings
    •    Previous D/W/M candle sweep SMT, where your chart takes a prior period's high or low and a correlate fails to
    •    Asia/London session SMT on session extremes


Options for requiring one or both correlates to diverge, keeping only the most recent signal per type, and showing provisional divergence while a swing is still forming. On symbols outside the index futures family, SMT switches off rather than comparing unrelated markets.

[b]Correlation health[/b] A rolling correlation readout for each comparison leg, color-coded against adjustable thresholds. SMT between decoupled instruments is meaningless, so there is an optional setting to mute signals when both legs fall below a correlation floor.

[b]Key levels Previous day, [/b]week and month highs and lows plus their 50% equilibrium, drawn from higher-timeframe data so they appear on every chart timeframe. Lines anchor to the candle that printed the extreme and terminate at the bar that swept them, with equilibrium lines extending independently. Midnight Open and True Day Open included. Full per-tier control of color, style, width, extension and label placement.

Killzones Asia, London, NY AM and NY PM as shaded boxes with session high/low lines. Everything stays contained within the session rather than extending to the right edge.

[b]CISD Change in State of Delivery,[/b] anchored to the open of the first candle in the run that delivered the leg. Gated behind a liquidity sweep of a swing pivot or key level, with filters for minimum run length, consecutive closes beyond the level, ATR displacement, sweep-to-signal window, and one signal per sweep.

[b]CHoCH and BOS[/b] Swing-based structure breaks with running bias. Breaks against bias are marked CHoCH, breaks with bias are BOS, styled separately. Optional displacement requirement turns a plain structure break into an MSS.

Day separators Day-of-week markers on a flat label row, named from the session close so futures sessions label correctly rather than a day behind.

Alerts are available on every SMT type, CISD and CHoCH.

## Source Code

````pine
//@version=6
// SMT Divergence ‚Äî 3-Way (auto ES/NQ/YM family) + Key Levels + Day Separators
//   Section 1: SMT engine ‚Äî Internal, External, Prev D/W/M candle sweep, Asia/London session
//   Section 2: PDH/PDL, PWH/PWL, PMH/PML + 50% equilibrium, origin-anchored, sweep-aware
//   Section 3: Anchored SMT logic (needs the level tracking from Section 2)
//   Section 4: Day-of-week separators

indicator("SMT Divergence ‚Äî 3-Way", "SMT 3-Way", overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500,
     max_bars_back = 5000)

// Drawings can only reach back as far as the historical buffer allows. Monthly
// levels on a low timeframe can sit further back than that, so every bar index
// handed to a drawing is clamped into the safe window.
BARLIM = 4800
clampX(int x) =>
    math.max(nz(x, bar_index), bar_index - BARLIM)

// ‚ïê‚ïê‚ïê SECTION 1 ‚Äî SMT ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpS = "Correlated Symbols"
symMode = input.string("Auto (index futures)", "Symbol mode",
     options = ["Auto (index futures)", "Manual"], group = grpS,
     tooltip = "Auto resolves the other two legs of the ES/NQ/YM family and matches micro vs mini.")
mSymA = input.symbol("CME_MINI:MNQ1!",  "Manual ‚Äî Comparison A", group = grpS)
mSymB = input.symbol("CBOT_MINI:MYM1!", "Manual ‚Äî Comparison B", group = grpS)
useB  = input.bool(false, "Use Comparison B", group = grpS)

grpTy = "SMT Types"
useInternal = input.bool(true, "Show Internal SMT", group = grpTy,
     tooltip = "Divergence on minor swing points (short pivot length). Faster, noisier.")
useExternal = input.bool(true, "Show External SMT", group = grpTy,
     tooltip = "Divergence on major structural swing points (long pivot length).")
useCandle   = input.bool(false, "Show Previous D/W/M Candle Sweep SMT", group = grpTy,
     tooltip = "Chart sweeps PDH/PDL/PWH/PWL/PMH/PML but the correlated symbol fails to sweep its own.")
useSession  = input.bool(false, "Show Asia/London Session SMT", group = grpTy,
     tooltip = "Chart sweeps the Asia or London session high/low but the correlated symbol does not.")
onlyRecent  = input.bool(true, "Only show the most recent SMT", group = grpTy)
perType     = input.bool(false, "... for each type", group = grpTy)
showForming = input.bool(true, "Show SMT while forming", group = grpTy,
     tooltip = "Draws provisional divergence on the unconfirmed swing. Repaints until the pivot confirms.")

grpP = "Swing Detection"
intLeft   = input.int(2, "Internal ‚Äî Pivot Left",  minval = 1, group = grpP)
intRight  = input.int(2, "Internal ‚Äî Pivot Right", minval = 1, group = grpP)
extLeft   = input.int(7, "External ‚Äî Pivot Left",  minval = 1, group = grpP)
extRightP = input.int(7, "External ‚Äî Pivot Right", minval = 1, group = grpP)
mode = input.string("Any symbol", "Confirmation", options = ["Any symbol", "Both symbols"],
     group = grpP, tooltip = "Any = flag if either comparison diverges. Both = require both to diverge.")

grpT = "Sessions"
asiaSess   = input.session("2000-0000", "Asia session",   group = grpT)
londonSess = input.session("0200-0500", "London session", group = grpT)
nyAmSess   = input.session("0830-1100", "NY AM session",  group = grpT)
nyPmSess   = input.session("1330-1600", "NY PM session",  group = grpT)
useSessFilter = input.bool(false, "Filter swing SMT by session", group = grpT)
filterSess    = input.session("0700-1000", "Swing SMT session filter", group = grpT)

grpV = "SMT Display"
showHi   = input.bool(true, "Bearish SMT (at highs)", group = grpV)
showLo   = input.bool(true, "Bullish SMT (at lows)",  group = grpV)
colHi    = input.color(color.new(#000000, 0), "Bearish", group = grpV)
colLo    = input.color(color.new(#000000, 0), "Bullish", group = grpV)
smtStyle = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpV)
lineW    = input.int(1, "Line width", minval = 1, maxval = 4, group = grpV)
showLbl  = input.bool(true, "Show Labels", group = grpV)
smtLblStyle = input.string("Text", "Label style", options = ["Text", "Callout"], group = grpV,
     tooltip = "Text = plain symbol text like the drawing tool. Callout = filled bubble.")
smtLblPos   = input.string("Middle", "Label position", options = ["Left", "Middle", "Right"], group = grpV)
smtLblVert  = input.string("Above line", "Label vertical",
     options = ["Above line", "On line", "Below line"], group = grpV)
lblFmt   = input.string("Root only", "Label text", options = ["Root only", "Full ticker"], group = grpV)
smtLblSz = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpV)

styleOf(simple string s) =>
    s == "Dashed" ? line.style_dashed : s == "Dotted" ? line.style_dotted : line.style_solid

smtIsText = smtLblStyle == "Text"

smtLblStyleFor(bool atHigh) =>
    smtIsText ? (smtLblVert == "Above line" ? label.style_label_down
                 : smtLblVert == "Below line" ? label.style_label_up : label.style_none)
              : (atHigh ? label.style_label_down : label.style_label_up)

smtSize = smtLblSz == "Tiny" ? size.tiny : smtLblSz == "Normal" ? size.normal : size.small

// ‚îÄ‚îÄ‚îÄ Auto symbol resolution ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
root  = syminfo.root
famES = root == "ES" or root == "MES"
famNQ = root == "NQ" or root == "MNQ"
famYM = root == "YM" or root == "MYM"
known = famES or famNQ or famYM
micro = root == "MES" or root == "MNQ" or root == "MYM"
pfx   = micro ? "M" : ""

rootA = famES ? pfx + "NQ" : famNQ ? pfx + "ES" : famYM ? pfx + "ES" : ""
rootB = famES ? pfx + "YM" : famNQ ? pfx + "YM" : famYM ? pfx + "NQ" : ""

venue(simple string r) =>
    r == "YM" or r == "MYM" ? "CBOT_MINI:" : "CME_MINI:"

useAuto = symMode == "Auto (index futures)" and known

// In Auto mode there is no valid correlated pair off the ES/NQ/YM family, so
// SMT is switched off entirely rather than comparing an unrelated symbol.
// Manual mode is an explicit choice and is always honoured.
smtActive = symMode == "Manual" or known

symA = useAuto ? venue(rootA) + rootA + "1!" : mSymA
symB = useAuto ? venue(rootB) + rootB + "1!" : mSymB

// Chart-level settings (B-ADJ back-adjustment, settlement-as-close, extended
// session) do not carry into request.security() when an explicit symbol is
// passed. Without this the comparison legs come back un-adjusted while the
// chart is adjusted, and every level shifts by the roll gap.
inheritChart = input.bool(true, "Inherit chart settings (B-ADJ, session)", group = grpS,
     tooltip = "Requests comparison symbols with the same back-adjustment and session settings as the chart. Turn off only to compare raw contract prices.")
symAtid = inheritChart ? ticker.inherit(syminfo.tickerid, symA) : symA
symBtid = inheritChart ? ticker.inherit(syminfo.tickerid, symB) : symB

tickerOf(simple string s) =>
    parts = str.split(s, ":")
    array.get(parts, array.size(parts) - 1)

fmtName(string t) =>
    lblFmt == "Root only" ? str.replace_all(t, "1!", "") : t

nameA = fmtName(tickerOf(symA))
nameB = fmtName(tickerOf(symB))

// ‚îÄ‚îÄ‚îÄ Comparison data ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
[aH, aL, aC] = request.security(symAtid, timeframe.period, [high, low, close],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
[bH, bL, bC] = request.security(symBtid, timeframe.period, [high, low, close],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)

// ‚îÄ‚îÄ‚îÄ Correlation health ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
grpC = "Correlation Health"
showCorr = input.bool(true, "Show correlation readout", group = grpC)
corrLen  = input.int(50, "Correlation length (bars)", minval = 5, group = grpC)
corrWarn = input.float(0.70, "Warn below", minval = 0, maxval = 1, step = 0.05, group = grpC)
corrBad  = input.float(0.40, "Alert below", minval = 0, maxval = 1, step = 0.05, group = grpC)
corrMute = input.float(0, "Mute SMT below correlation", minval = 0, maxval = 1, step = 0.05,
     group = grpC, tooltip = "0 disables muting. When set, SMT is suppressed while both legs are decoupled ‚Äî divergence between uncorrelated markets means nothing.")

corrA = ta.correlation(close, aC, corrLen)
corrB = ta.correlation(close, bC, corrLen)
corrBest = useB ? math.max(nz(corrA, 0), nz(corrB, 0)) : nz(corrA, 0)
corrOK = corrMute <= 0 or corrBest >= corrMute

corrCol(float v) =>
    na(v) ? color.gray : v < corrBad ? #ef5350 : v < corrWarn ? #ffa726 : #26a69a

[aPDH, aPDL] = request.security(symAtid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[bPDH, bPDL] = request.security(symBtid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[aPWH, aPWL] = request.security(symAtid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[bPWH, bPWL] = request.security(symBtid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[aPMH, aPML] = request.security(symAtid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[bPMH, bPML] = request.security(symBtid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

inFilter = not useSessFilter or not na(time(timeframe.period, filterSess))

// ‚îÄ‚îÄ‚îÄ Drawing registry (supports "only most recent") ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
var array<line>  smtLn = array.new<line>()
var array<label> smtLb = array.new<label>()
var array<int>   smtTy = array.new<int>()

recordSMTInner(int typeId, int x1, float y1, int x2, float y2, color c, string txt, bool atHigh) =>
    if onlyRecent
        i = 0
        while i < array.size(smtLn)
            if not perType or array.get(smtTy, i) == typeId
                line.delete(array.get(smtLn, i))
                label.delete(array.get(smtLb, i))
                array.remove(smtLn, i)
                array.remove(smtLb, i)
                array.remove(smtTy, i)
            else
                i += 1
    cx1 = clampX(x1)
    ln = line.new(cx1, y1, x2, y2, xloc.bar_index, color = c,
         style = styleOf(smtStyle), width = lineW)
    lx = smtLblPos == "Left" ? cx1 : smtLblPos == "Right" ? x2 : int(math.avg(cx1, x2))
    ly = smtLblPos == "Left" ? y1 : smtLblPos == "Right" ? y2 : math.avg(y1, y2)
    lb = label.new(lx, ly, showLbl ? txt : "", xloc.bar_index, yloc.price,
         style     = smtLblStyleFor(atHigh),
         color     = smtIsText or not showLbl ? color.new(c, 100) : color.new(c, 15),
         textcolor = showLbl ? (smtIsText ? c : color.white) : color.new(c, 100),
         size      = smtSize)
    array.push(smtLn, ln)
    array.push(smtLb, lb)
    array.push(smtTy, typeId)
    if array.size(smtLn) > 200
        array.shift(smtLn)
        array.shift(smtLb)
        array.shift(smtTy)

recordSMT(int typeId, int x1, float y1, int x2, float y2, color c, string txt, bool atHigh) =>
    if corrOK and smtActive
        recordSMTInner(typeId, x1, y1, x2, y2, c, txt, atHigh)

whoTxt(bool dA, bool dB) =>
    (dA ? nameA : "") + (dA and dB ? " / " : "") + (dB ? nameB : "")

// ‚îÄ‚îÄ‚îÄ Swing-based scan (used twice: Internal and External) ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
smtScan(simple int L, simple int R, simple int typeId, bool en) =>
    var float _pH = na
    var float _pHa = na
    var float _pHb = na
    var int   _pHx = na
    var float _pL = na
    var float _pLa = na
    var float _pLb = na
    var int   _pLx = na

    // running extremes since last confirmed pivot (for "while forming")
    var float _rH = na
    var float _rHa = na
    var float _rHb = na
    var int   _rHx = na
    var float _rL = na
    var float _rLa = na
    var float _rLb = na
    var int   _rLx = na

    ph = ta.pivothigh(high, L, R)
    pl = ta.pivotlow(low, L, R)

    if not na(ph)
        cBar = bar_index - R
        if not na(_pH) and en and showHi and inFilter[R]
            up   = ph > _pH
            dA   = not na(aH[R]) and not na(_pHa) and up != (aH[R] > _pHa)
            dB   = useB and not na(bH[R]) and not na(_pHb) and up != (bH[R] > _pHb)
            hit  = mode == "Any symbol" ? (dA or dB) : (useB ? (dA and dB) : dA)
            if hit
                recordSMT(typeId, _pHx, _pH, cBar, ph, colHi, whoTxt(dA, dB), true)
                alert("Bearish SMT vs " + whoTxt(dA, dB), alert.freq_once_per_bar)
        _pH  := ph
        _pHa := aH[R]
        _pHb := bH[R]
        _pHx := cBar
        _rH  := na

    if not na(pl)
        cBar = bar_index - R
        if not na(_pL) and en and showLo and inFilter[R]
            dn   = pl < _pL
            dA   = not na(aL[R]) and not na(_pLa) and dn != (aL[R] < _pLa)
            dB   = useB and not na(bL[R]) and not na(_pLb) and dn != (bL[R] < _pLb)
            hit  = mode == "Any symbol" ? (dA or dB) : (useB ? (dA and dB) : dA)
            if hit
                recordSMT(typeId, _pLx, _pL, cBar, pl, colLo, whoTxt(dA, dB), false)
                alert("Bullish SMT vs " + whoTxt(dA, dB), alert.freq_once_per_bar)
        _pL  := pl
        _pLa := aL[R]
        _pLb := bL[R]
        _pLx := cBar
        _rL  := na

    if na(_rH) or high > _rH
        _rH  := high
        _rHa := aH
        _rHb := bH
        _rHx := bar_index
    if na(_rL) or low < _rL
        _rL  := low
        _rLa := aL
        _rLb := bL
        _rLx := bar_index

    // provisional (unconfirmed) divergence
    var line  fLnH = na
    var label fLbH = na
    var line  fLnL = na
    var label fLbL = na
    if barstate.islast
        line.delete(fLnH)
        label.delete(fLbH)
        line.delete(fLnL)
        label.delete(fLbL)
        if en and showForming and showHi and not na(_pH) and not na(_rH)
            up  = _rH > _pH
            dA  = not na(_rHa) and not na(_pHa) and up != (_rHa > _pHa)
            dB  = useB and not na(_rHb) and not na(_pHb) and up != (_rHb > _pHb)
            hit = mode == "Any symbol" ? (dA or dB) : (useB ? (dA and dB) : dA)
            if hit
                fLnH := line.new(_pHx, _pH, _rHx, _rH, xloc.bar_index,
                     color = color.new(colHi, 40), style = line.style_dashed, width = lineW)
                if showLbl
                    fx = smtLblPos == "Left" ? _pHx : smtLblPos == "Right" ? _rHx : int(math.avg(_pHx, _rHx))
                    fy = smtLblPos == "Left" ? _pH  : smtLblPos == "Right" ? _rH  : math.avg(_pH, _rH)
                    fLbH := label.new(fx, fy, whoTxt(dA, dB) + " ?", xloc.bar_index, yloc.price,
                         style = smtLblStyleFor(true),
                         color = smtIsText ? color.new(colHi, 100) : color.new(colHi, 55),
                         textcolor = smtIsText ? color.new(colHi, 30) : color.white, size = smtSize)
        if en and showForming and showLo and not na(_pL) and not na(_rL)
            dn  = _rL < _pL
            dA  = not na(_rLa) and not na(_pLa) and dn != (_rLa < _pLa)
            dB  = useB and not na(_rLb) and not na(_pLb) and dn != (_rLb < _pLb)
            hit = mode == "Any symbol" ? (dA or dB) : (useB ? (dA and dB) : dA)
            if hit
                fLnL := line.new(_pLx, _pL, _rLx, _rL, xloc.bar_index,
                     color = color.new(colLo, 40), style = line.style_dashed, width = lineW)
                if showLbl
                    fx = smtLblPos == "Left" ? _pLx : smtLblPos == "Right" ? _rLx : int(math.avg(_pLx, _rLx))
                    fy = smtLblPos == "Left" ? _pL  : smtLblPos == "Right" ? _rL  : math.avg(_pL, _rL)
                    fLbL := label.new(fx, fy, whoTxt(dA, dB) + " ?", xloc.bar_index, yloc.price,
                         style = smtLblStyleFor(false),
                         color = smtIsText ? color.new(colLo, 100) : color.new(colLo, 55),
                         textcolor = smtIsText ? color.new(colLo, 30) : color.white, size = smtSize)

smtScan(intLeft, intRight, 0, useInternal and smtActive)
smtScan(extLeft, extRightP, 1, useExternal and smtActive)

// ‚ïê‚ïê‚ïê SECTION 2 ‚Äî KEY LEVELS ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpK = "Key Levels ‚Äî General"
anchorAt = input.string("Origin candle", "Draw from",
     options = ["Origin candle", "Period start", "Full chart"], group = grpK,
     tooltip = "Origin candle = the line starts at the exact bar that printed the high/low.")
extRight    = input.int(14, "Extend H/L right (bars)", minval = 0, group = grpK)
extRight50  = input.int(40, "Extend 50% right (bars)", minval = 0, group = grpK)
extInfHL    = input.bool(false, "Extend H/L to right edge", group = grpK)
extInf50    = input.bool(true, "Extend 50% to right edge", group = grpK,
     tooltip = "Runs the equilibrium lines off the right edge of the chart instead of stopping.")
lblPos      = input.string("Custom offset", "Label position",
     options = ["Right", "Middle", "Left", "Custom offset"], group = grpK)
lblOffset   = input.int(-5, "Custom offset (bars from right end)", group = grpK,
     tooltip = "Negative pulls the label left of the line end, positive pushes it further right.")
lblVert     = input.string("Above line", "Label vertical",
     options = ["Above line", "On line", "Below line"], group = grpK)
stopAtSweep = input.bool(true, "Stop H/L lines when swept", group = grpK)
sweep50     = input.bool(false, "Also stop 50% lines when swept", group = grpK)
pxMode      = input.string("50% only", "Show price in label",
     options = ["50% only", "All levels", "None"], group = grpK)
lvlSize     = input.string("Normal", "Label size", options = ["Tiny", "Small", "Normal"], group = grpK)

grpD = "Key Levels ‚Äî Previous Day"
showPD    = input.bool(true, "PDH / PDL", group = grpD)
colD      = input.color(color.new(#000000, 0), "Color", group = grpD)
styD      = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = grpD)
widD      = input.int(1, "Width", minval = 1, maxval = 4, group = grpD)
showPD50  = input.bool(true, "PD 50%", group = grpD)
colD50    = input.color(color.new(#000000, 0), "50% color", group = grpD)
styD50    = input.string("Dotted", "50% style", options = ["Solid", "Dashed", "Dotted"], group = grpD)
widD50    = input.int(1, "50% width", minval = 1, maxval = 4, group = grpD)

grpW = "Key Levels ‚Äî Previous Week"
showPW    = input.bool(true, "PWH / PWL", group = grpW)
colW      = input.color(color.new(#000000, 0), "Color", group = grpW)
styW      = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = grpW)
widW      = input.int(1, "Width", minval = 1, maxval = 4, group = grpW)
showPW50  = input.bool(true, "PW 50%", group = grpW)
colW50    = input.color(color.new(#000000, 0), "50% color", group = grpW)
styW50    = input.string("Dotted", "50% style", options = ["Solid", "Dashed", "Dotted"], group = grpW)
widW50    = input.int(1, "50% width", minval = 1, maxval = 4, group = grpW)

grpM = "Key Levels ‚Äî Previous Month"
showPM    = input.bool(true, "PMH / PML", group = grpM)
colM      = input.color(color.new(#000000, 0), "Color", group = grpM)
styM      = input.string("Solid", "Style", options = ["Solid", "Dashed", "Dotted"], group = grpM)
widM      = input.int(1, "Width", minval = 1, maxval = 4, group = grpM)
showPM50  = input.bool(false, "PM 50%", group = grpM)
colM50    = input.color(color.new(#787b86, 0), "50% color", group = grpM)
styM50    = input.string("Dotted", "50% style", options = ["Solid", "Dashed", "Dotted"], group = grpM)
widM50    = input.int(1, "50% width", minval = 1, maxval = 4, group = grpM)

type Rng
    float cH
    int   cHb
    float cL
    int   cLb
    float pH
    int   pHb
    float pL
    int   pLb
    int   pStart

// Local tracking is used ONLY to recover the origin candle of each extreme.
roll(Rng r, bool isNew) =>
    if na(r.cH) or isNew
        if isNew and not na(r.cH)
            r.pH  := r.cH
            r.pHb := r.cHb
            r.pL  := r.cL
            r.pLb := r.cLb
        r.cH     := high
        r.cHb    := bar_index
        r.cL     := low
        r.cLb    := bar_index
        r.pStart := bar_index
    else
        if high > r.cH
            r.cH  := high
            r.cHb := bar_index
        if low < r.cL
            r.cL  := low
            r.cLb := bar_index

var Rng rD = Rng.new()
var Rng rW = Rng.new()
var Rng rM = Rng.new()

newD = ta.change(time("D")) != 0
newW = ta.change(time("W")) != 0
newM = ta.change(time("M")) != 0

roll(rD, newD)
roll(rW, newW)
roll(rM, newM)

// Level VALUES come from the higher-timeframe series, so they exist on every
// chart timeframe even when the period boundary is not in the loaded history.
[cPDH, cPDL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[cPWH, cPWL] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[cPMH, cPML] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

cPD50 = (cPDH + cPDL) / 2
cPW50 = (cPWH + cPWL) / 2
cPM50 = (cPMH + cPML) / 2

// Period start + sweep bar, derived from the level value itself.
type Anch
    int start
    int sweep

track(Anch a, float v, simple string kind) =>
    ch = ta.change(v)
    if na(a.start) or ch != 0
        a.start := bar_index
        a.sweep := na
    if not na(v) and na(a.sweep)
        touched = kind == "high" ? high >= v : kind == "low" ? low <= v : (high >= v and low <= v)
        if touched
            a.sweep := bar_index

var Anch aPDHx = Anch.new()
var Anch aPDLx = Anch.new()
var Anch aPD5x = Anch.new()
var Anch aPWHx = Anch.new()
var Anch aPWLx = Anch.new()
var Anch aPW5x = Anch.new()
var Anch aPMHx = Anch.new()
var Anch aPMLx = Anch.new()
var Anch aPM5x = Anch.new()

track(aPDHx, cPDH,  "high")
track(aPDLx, cPDL,  "low")
track(aPD5x, cPD50, "mid")
track(aPWHx, cPWH,  "high")
track(aPWLx, cPWL,  "low")
track(aPW5x, cPW50, "mid")
track(aPMHx, cPMH,  "high")
track(aPMLx, cPML,  "low")
track(aPM5x, cPM50, "mid")

// Origin candle. The bar comes from local tracking; the price comes from the
// higher-timeframe series. Requiring the two to agree to the tick was too
// strict ‚Äî the longer the period, the more chance of a small aggregation
// difference, which is why weekly and monthly fell back to the period start
// while daily connected fine. Strict matching is now opt-in.
strictOrigin = input.bool(false, "Strict origin matching", group = grpK,
     tooltip = "Only anchor to the origin candle when the chart's own extreme matches the higher-timeframe value within the tolerance below. Off anchors to the chart's extreme regardless.")
originTol    = input.float(8, "Origin match tolerance (ticks)", minval = 0, step = 1, group = grpK)

originOf(float secVal, float locVal, int locBar) =>
    ok = not na(locVal) and not na(locBar) and (not strictOrigin
         or (not na(secVal) and math.abs(secVal - locVal) <= syminfo.mintick * originTol))
    ok ? locBar : int(na)

lblSize = lvlSize == "Tiny" ? size.tiny : lvlSize == "Normal" ? size.normal : size.small

type Lvl
    line  ln
    label lb

mkLvl() =>
    Lvl.new(
       line.new(bar_index, close, bar_index, close, xloc.bar_index,
            extend.none, color.new(color.gray, 100), line.style_solid, 1),
       label.new(bar_index, close, "", xloc.bar_index, yloc.price,
            color = color.new(color.gray, 100), style = label.style_none,
            textcolor = color.new(color.gray, 100), size = size.small))

px(float v, bool is50) =>
    show = pxMode == "All levels" or (pxMode == "50% only" and is50)
    show ? " (" + str.tostring(v, format.mintick) + ")" : ""

setLvl(Lvl l, bool on, float y, string tag, int originBar, int periodBar, int swBar,
       bool canStop, bool is50, color c, simple string sty, int wid) =>
    vis = on and not na(y)
    line.set_color(l.ln, vis ? c : color.new(c, 100))
    label.set_textcolor(l.lb, vis ? c : color.new(c, 100))
    if vis
        pb = nz(periodBar, 0)
        x1 = anchorAt == "Origin candle" ? nz(originBar, pb)
             : anchorAt == "Period start" ? pb : 0
        stopped = canStop and not na(swBar)
        eb = is50 ? extRight50 : extRight
        x2 = stopped ? swBar : bar_index + eb
        xa = clampX(math.min(x1, x2))
        line.set_xy1(l.ln, xa, y)
        line.set_xy2(l.ln, x2, y)
        line.set_style(l.ln, styleOf(sty))
        line.set_width(l.ln, wid)
        inf = not stopped and (is50 ? extInf50 : extInfHL)
        line.set_extend(l.ln, inf ? extend.right : extend.none)
        lx = lblPos == "Left"          ? xa
             : lblPos == "Middle"      ? int(math.avg(xa, x2))
             : lblPos == "Custom offset" ? x2 + lblOffset
             : x2
        label.set_xy(l.lb, lx, y)
        label.set_text(l.lb, tag + px(y, is50))
        label.set_size(l.lb, lblSize)
        label.set_style(l.lb, lblVert == "On line" ? label.style_none
             : lblVert == "Below line" ? label.style_label_up : label.style_label_down)
        label.set_color(l.lb, color.new(color.gray, 100))

var Lvl lPDH  = mkLvl()
var Lvl lPDL  = mkLvl()
var Lvl lPD50 = mkLvl()
var Lvl lPWH  = mkLvl()
var Lvl lPWL  = mkLvl()
var Lvl lPW50 = mkLvl()
var Lvl lPMH  = mkLvl()
var Lvl lPML  = mkLvl()
var Lvl lPM50 = mkLvl()

oPDH = originOf(cPDH, rD.pH, rD.pHb)
oPDL = originOf(cPDL, rD.pL, rD.pLb)
oPWH = originOf(cPWH, rW.pH, rW.pHb)
oPWL = originOf(cPWL, rW.pL, rW.pLb)
oPMH = originOf(cPMH, rM.pH, rM.pHb)
oPML = originOf(cPML, rM.pL, rM.pLb)

if barstate.islast
    oD50 = na(oPDH) or na(oPDL) ? int(na) : math.min(oPDH, oPDL)
    oW50 = na(oPWH) or na(oPWL) ? int(na) : math.min(oPWH, oPWL)
    oM50 = na(oPMH) or na(oPML) ? int(na) : math.min(oPMH, oPML)
    setLvl(lPDH,  showPD,   cPDH,  "PDH",   oPDH, aPDHx.start, aPDHx.sweep, stopAtSweep, false, colD,   styD,   widD)
    setLvl(lPDL,  showPD,   cPDL,  "PDL",   oPDL, aPDLx.start, aPDLx.sweep, stopAtSweep, false, colD,   styD,   widD)
    setLvl(lPD50, showPD50, cPD50, "PD50%", oD50, aPD5x.start, aPD5x.sweep, sweep50,     true,  colD50, styD50, widD50)
    setLvl(lPWH,  showPW,   cPWH,  "PWH",   oPWH, aPWHx.start, aPWHx.sweep, stopAtSweep, false, colW,   styW,   widW)
    setLvl(lPWL,  showPW,   cPWL,  "PWL",   oPWL, aPWLx.start, aPWLx.sweep, stopAtSweep, false, colW,   styW,   widW)
    setLvl(lPW50, showPW50, cPW50, "PW50%", oW50, aPW5x.start, aPW5x.sweep, sweep50,     true,  colW50, styW50, widW50)
    setLvl(lPMH,  showPM,   cPMH,  "PMH",   oPMH, aPMHx.start, aPMHx.sweep, stopAtSweep, false, colM,   styM,   widM)
    setLvl(lPML,  showPM,   cPML,  "PML",   oPML, aPMLx.start, aPMLx.sweep, stopAtSweep, false, colM,   styM,   widM)
    setLvl(lPM50, showPM50, cPM50, "PM50%", oM50, aPM5x.start, aPM5x.sweep, sweep50,     true,  colM50, styM50, widM50)

// ‚îÄ‚îÄ‚îÄ Midnight Open / True Day Open ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
grpO = "Key Levels ‚Äî Opens"
showMO   = input.bool(true, "Midnight Open", group = grpO)
showTDO  = input.bool(true, "True Day Open", group = grpO)
opTz     = input.string("America/New_York", "Timezone", group = grpO)
moHour   = input.int(0,  "Midnight Open hour",  minval = 0, maxval = 23, group = grpO)
tdoHour  = input.int(18, "True Day Open hour",  minval = 0, maxval = 23, group = grpO,
     tooltip = "18:00 ET is the CME session open. Requires a chart timeframe whose bars start on the hour.")
colMO    = input.color(color.new(#787b86, 0), "Midnight Open color", group = grpO)
styMO    = input.string("Dotted", "Midnight Open style", options = ["Solid", "Dashed", "Dotted"], group = grpO)
widMO    = input.int(1, "Midnight Open width", minval = 1, maxval = 4, group = grpO)
colTDO   = input.color(color.new(#787b86, 0), "True Day Open color", group = grpO)
styTDO   = input.string("Dotted", "True Day Open style", options = ["Solid", "Dashed", "Dotted"], group = grpO)
widTDO   = input.int(1, "True Day Open width", minval = 1, maxval = 4, group = grpO)

var float moV  = na
var int   moB  = na
var float tdoV = na
var int   tdoB = na

if hour(time, opTz) == moHour and minute(time, opTz) == 0
    moV := open
    moB := bar_index
if hour(time, opTz) == tdoHour and minute(time, opTz) == 0
    tdoV := open
    tdoB := bar_index

var Lvl lMO  = mkLvl()
var Lvl lTDO = mkLvl()

if barstate.islast
    setLvl(lMO,  showMO,  moV,  "MO",  moB,  moB,  int(na), false, false, colMO,  styMO,  widMO)
    setLvl(lTDO, showTDO, tdoV, "TDO", tdoB, tdoB, int(na), false, false, colTDO, styTDO, widTDO)

// ‚ïê‚ïê‚ïê SECTION 3 ‚Äî ANCHORED SMT (candle sweep + session) ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

// Chart sweeps the level; comparison fails to sweep its own ‚Üí divergence.
candleSMT(float lvl, float aLvl, float bLvl, int originBar, bool isHigh, bool reset, bool en) =>
    var bool done = false
    if reset
        done := false
    if not done and en and not na(lvl)
        swept = isHigh ? high >= lvl : low <= lvl
        if swept
            done := true
            aFail = not na(aLvl) and (isHigh ? aH < aLvl : aL > aLvl)
            bFail = useB and not na(bLvl) and (isHigh ? bH < bLvl : bL > bLvl)
            hit   = mode == "Any symbol" ? (aFail or bFail) : (useB ? (aFail and bFail) : aFail)
            ok    = isHigh ? showHi : showLo
            if hit and ok
                recordSMT(2, nz(originBar, bar_index), lvl, bar_index, lvl,
                     isHigh ? colHi : colLo, whoTxt(aFail, bFail), isHigh)
                alert((isHigh ? "Bearish" : "Bullish") + " candle-sweep SMT vs "
                     + whoTxt(aFail, bFail), alert.freq_once_per_bar)

candleSMT(cPDH, aPDH, bPDH, nz(oPDH, aPDHx.start), true,  newD, useCandle and smtActive)
candleSMT(cPDL, aPDL, bPDL, nz(oPDL, aPDLx.start), false, newD, useCandle and smtActive)
candleSMT(cPWH, aPWH, bPWH, nz(oPWH, aPWHx.start), true,  newW, useCandle and smtActive)
candleSMT(cPWL, aPWL, bPWL, nz(oPWL, aPWLx.start), false, newW, useCandle and smtActive)
candleSMT(cPMH, aPMH, bPMH, nz(oPMH, aPMHx.start), true,  newM, useCandle and smtActive)
candleSMT(cPML, aPML, bPML, nz(oPML, aPMLx.start), false, newM, useCandle and smtActive)

// Session high/low sweep SMT
sessionSMT(simple string sessStr, bool en) =>
    var float sH  = na
    var int   sHx = na
    var float sL  = na
    var int   sLx = na
    var float aSH = na
    var float aSL = na
    var float bSH = na
    var float bSL = na
    var bool  doneH = false
    var bool  doneL = false

    inS   = not na(time(timeframe.period, sessStr))
    start = inS and not inS[1]

    if start
        sH  := high
        sHx := bar_index
        sL  := low
        sLx := bar_index
        aSH := aH
        aSL := aL
        bSH := bH
        bSL := bL
        doneH := false
        doneL := false
    else if inS
        if high > sH
            sH  := high
            sHx := bar_index
        if low < sL
            sL  := low
            sLx := bar_index
        aSH := math.max(nz(aSH, aH), aH)
        aSL := math.min(nz(aSL, aL), aL)
        bSH := math.max(nz(bSH, bH), bH)
        bSL := math.min(nz(bSL, bL), bL)

    if not inS and en and not na(sH)
        if not doneH and showHi and high >= sH
            doneH := true
            aFail = not na(aSH) and aH < aSH
            bFail = useB and not na(bSH) and bH < bSH
            hit   = mode == "Any symbol" ? (aFail or bFail) : (useB ? (aFail and bFail) : aFail)
            if hit
                recordSMT(3, sHx, sH, bar_index, sH, colHi, whoTxt(aFail, bFail), true)
                alert("Bearish session SMT vs " + whoTxt(aFail, bFail), alert.freq_once_per_bar)
        if not doneL and showLo and low <= sL
            doneL := true
            aFail = not na(aSL) and aL > aSL
            bFail = useB and not na(bSL) and bL > bSL
            hit   = mode == "Any symbol" ? (aFail or bFail) : (useB ? (aFail and bFail) : aFail)
            if hit
                recordSMT(3, sLx, sL, bar_index, sL, colLo, whoTxt(aFail, bFail), false)
                alert("Bullish session SMT vs " + whoTxt(aFail, bFail), alert.freq_once_per_bar)

sessionSMT(asiaSess, useSession and smtActive)
sessionSMT(londonSess, useSession and smtActive)

// ‚ïê‚ïê‚ïê SECTION 4 ‚Äî DAY SEPARATORS ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpSep = "Day Separators"
showSep   = input.bool(true, "Show day separators", group = grpSep)
sepMaxTF  = input.string("4h", "Show up to timeframe",
     options = ["15m", "30m", "1h", "2h", "4h", "1D", "Always show"], group = grpSep,
     tooltip = "Separators hide on any chart timeframe larger than this.")
sepHist   = input.int(10, "History (days)", minval = 1, maxval = 200, group = grpSep)
sepCol    = input.color(color.new(#787b86, 100), "Line color", group = grpSep)
sepSty    = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpSep)
sepWid    = input.int(1, "Line width", minval = 1, maxval = 4, group = grpSep)
sepShowLb = input.bool(true, "Show day labels", group = grpSep)
sepLbPos  = input.string("Bottom", "Label position", options = ["Bottom", "Top"], group = grpSep)
sepLbGap  = input.float(2, "Label row offset (% of range)", minval = 0, maxval = 100, step = 1,
     group = grpSep, tooltip = "How far the flat label row sits below the lows (or above the highs).")
sepLbDays = input.int(14, "Label row lookback (days)", minval = 1, maxval = 120, group = grpSep,
     tooltip = "Measured in days, not bars, so the row sits in the same place on every timeframe.")
sepSpaced = input.bool(true, "Letter-spaced labels (M O N)", group = grpSep)
sepDaySrc = input.string("Session close", "Day name from", options = ["Session close", "Bar timestamp"],
     group = grpSep,
     tooltip = "Futures sessions open the prior evening, so the opening bar's calendar day is one behind the trading day. Session close names it correctly.")
sepDayShift = input.int(0, "Day label shift", minval = -1, maxval = 1, group = grpSep,
     tooltip = "Manual nudge if your session or timezone still lands a day off.")
sepTxtCol = input.color(color.new(#787b86, 0), "Label color", group = grpSep)
sepTxtSz  = input.string("Normal", "Label size", options = ["Tiny", "Small", "Normal"], group = grpSep)

maxSecs = sepMaxTF == "15m" ? 900 : sepMaxTF == "30m" ? 1800 : sepMaxTF == "1h" ? 3600 :
     sepMaxTF == "2h" ? 7200 : sepMaxTF == "4h" ? 14400 : sepMaxTF == "1D" ? 86400 : 999999999
sepTfOk = timeframe.in_seconds(timeframe.period) <= maxSecs
sepSize = sepTxtSz == "Tiny" ? size.tiny : sepTxtSz == "Normal" ? size.normal : size.small

dowName(int d) =>
    d == dayofweek.sunday     ? "SUN" :
     d == dayofweek.monday    ? "MON" :
     d == dayofweek.tuesday   ? "TUE" :
     d == dayofweek.wednesday ? "WED" :
     d == dayofweek.thursday  ? "THU" :
     d == dayofweek.friday    ? "FRI" : "SAT"

// Flat label row: one price for every label, offset from the recent range.
// The lookback is converted from days to bars so the row does not drift down
// as the chart timeframe grows (300 bars is a week on 30m but months on 8h).
sepLookBars = int(math.max(20, math.min(3000,
     math.round(sepLbDays * 86400 / timeframe.in_seconds(timeframe.period)))))
sepRowLo  = ta.lowest(low, sepLookBars)
sepRowHi  = ta.highest(high, sepLookBars)
sepRowRng = sepRowHi - sepRowLo
sepRowY   = sepLbPos == "Bottom" ? sepRowLo - sepRowRng * sepLbGap / 100
             : sepRowHi + sepRowRng * sepLbGap / 100

spaceOut(string t) =>
    out = ""
    nCh = str.length(t)
    if nCh > 0
        for i = 0 to nCh - 1
            out := out + (i > 0 ? " " : "") + str.substring(t, i, i + 1)
    out

var array<int>    sepBars  = array.new<int>()
var array<string> sepNames = array.new<string>()

// The CME trading day opens at 18:00 ET the previous calendar date, so the bar
// that starts a new daily period carries yesterday's weekday. Name the day from
// the session close instead.
sepDowRaw = dayofweek(sepDaySrc == "Bar timestamp" ? time : nz(time_close("D"), time), syminfo.timezone)
sepDow    = ((sepDowRaw - 1 + sepDayShift) % 7 + 7) % 7 + 1

if newD
    array.push(sepBars, bar_index)
    array.push(sepNames, dowName(sepDow))
    if array.size(sepBars) > 250
        array.shift(sepBars)
        array.shift(sepNames)

var array<line>  sepLines  = array.new<line>()
var array<label> sepLabels = array.new<label>()

if barstate.islast
    for ln in sepLines
        line.delete(ln)
    array.clear(sepLines)
    for lb in sepLabels
        label.delete(lb)
    array.clear(sepLabels)
    if showSep and sepTfOk
        n = array.size(sepBars)
        first = math.max(0, n - sepHist)
        if n > 0
            for i = first to n - 1
                b     = clampX(array.get(sepBars, i))
                nextB = i < n - 1 ? clampX(array.get(sepBars, i + 1)) : bar_index
                array.push(sepLines, line.new(b, low, b, high, xloc.bar_index, extend.both,
                     sepCol, styleOf(sepSty), sepWid))
                if sepShowLb
                    mid = math.round(math.avg(b, nextB))
                    raw = array.get(sepNames, i)
                    array.push(sepLabels, label.new(mid, nz(sepRowY, low),
                         sepSpaced ? spaceOut(raw) : raw, xloc.bar_index, yloc.price,
                         color = color.new(color.gray, 100), style = label.style_none,
                         textcolor = sepTxtCol, size = sepSize))

// ‚ïê‚ïê‚ïê SECTION 5 ‚Äî KILLZONES ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpKZ = "Killzones"
showKZ    = input.bool(false, "Show killzones", group = grpKZ)
kzMaxTF   = input.string("1h", "Show up to timeframe",
     options = ["5m", "15m", "30m", "1h", "2h", "4h", "Always show"], group = grpKZ)
kzHist    = input.int(5, "History (sessions each)", minval = 1, maxval = 40, group = grpKZ)
kzShade   = input.bool(false, "Shade the session box", group = grpKZ)
kzTrans   = input.int(90, "Fill transparency", minval = 0, maxval = 100, group = grpKZ)
kzBordW   = input.int(0, "Box border width", minval = 0, maxval = 3, group = grpKZ)
kzLines   = input.bool(false, "Draw session high/low lines", group = grpKZ)
kzLineSty = input.string("Solid", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpKZ)
kzLineW   = input.int(1, "Line width", minval = 1, maxval = 4, group = grpKZ)
kzExt     = input.int(0, "Extend past session (bars)", minval = 0, maxval = 300, group = grpKZ,
     tooltip = "0 keeps boxes and lines inside the session itself.")
kzLabel   = input.bool(false, "Show session labels", group = grpKZ)
kzLblSz   = input.string("Tiny", "Label size", options = ["Tiny", "Small", "Normal"], group = grpKZ)

showAsia   = input.bool(false, "Asia",   group = grpKZ, inline = "a")
colAsia    = input.color(#26a69a, "",   group = grpKZ, inline = "a")
showLondon = input.bool(false, "London", group = grpKZ, inline = "l")
colLondon  = input.color(#ffa726, "",   group = grpKZ, inline = "l")
showNyAm   = input.bool(false, "NY AM",  group = grpKZ, inline = "m")
colNyAm    = input.color(#2962ff, "",   group = grpKZ, inline = "m")
showNyPm   = input.bool(false, "NY PM",  group = grpKZ, inline = "p")
colNyPm    = input.color(#9c27b0, "",   group = grpKZ, inline = "p")

kzSecs = kzMaxTF == "5m" ? 300 : kzMaxTF == "15m" ? 900 : kzMaxTF == "30m" ? 1800 :
     kzMaxTF == "1h" ? 3600 : kzMaxTF == "2h" ? 7200 : kzMaxTF == "4h" ? 14400 : 999999999
kzTfOk  = timeframe.in_seconds(timeframe.period) <= kzSecs
kzLblSize = kzLblSz == "Tiny" ? size.tiny : kzLblSz == "Normal" ? size.normal : size.small

killzone(simple string sess, bool en, color c, simple string nm) =>
    var array<box>   bxs = array.new<box>()
    var array<line>  his = array.new<line>()
    var array<line>  los = array.new<line>()
    var array<label> lbs = array.new<label>()
    var box   cb  = na
    var line  ch  = na
    var line  cl  = na
    var label clb = na
    var float sh  = na
    var float sl  = na

    inS   = not na(time(timeframe.period, sess))
    start = inS and not inS[1]
    ended = not inS and inS[1]
    on    = en and showKZ and kzTfOk

    if on and start
        sh := high
        sl := low
        cb := box.new(bar_index, sh, bar_index, sl,
             border_color = kzBordW > 0 ? c : color.new(c, 100), border_width = kzBordW,
             bgcolor = kzShade ? color.new(c, kzTrans) : color.new(c, 100))
        array.push(bxs, cb)
        if array.size(bxs) > kzHist
            box.delete(array.shift(bxs))
        if kzLines
            ch := line.new(bar_index, sh, bar_index, sh, xloc.bar_index,
                 color = c, style = styleOf(kzLineSty), width = kzLineW)
            cl := line.new(bar_index, sl, bar_index, sl, xloc.bar_index,
                 color = c, style = styleOf(kzLineSty), width = kzLineW)
            array.push(his, ch)
            array.push(los, cl)
            if array.size(his) > kzHist
                line.delete(array.shift(his))
                line.delete(array.shift(los))
        if kzLabel
            clb := label.new(bar_index, sh, nm, xloc.bar_index, yloc.price,
                 style = label.style_none, color = color.new(color.gray, 100),
                 textcolor = c, size = kzLblSize)
            array.push(lbs, clb)
            if array.size(lbs) > kzHist
                label.delete(array.shift(lbs))
    else if on and inS and not na(cb)
        sh := math.max(sh, high)
        sl := math.min(sl, low)
        box.set_top(cb, sh)
        box.set_bottom(cb, sl)
        box.set_right(cb, bar_index)
        if not na(ch)
            line.set_y1(ch, sh)
            line.set_y2(ch, sh)
            line.set_x2(ch, bar_index)
            line.set_y1(cl, sl)
            line.set_y2(cl, sl)
            line.set_x2(cl, bar_index)
        if not na(clb)
            label.set_y(clb, sh)

    // Freeze at the close of the session; nothing runs to the right edge.
    if on and ended and not na(cb)
        endX = bar_index - 1 + kzExt
        box.set_right(cb, endX)
        if not na(ch)
            line.set_x2(ch, endX)
            line.set_x2(cl, endX)

killzone(asiaSess,   showAsia,   colAsia,   "ASIA")
killzone(londonSess, showLondon, colLondon, "LONDON")
killzone(nyAmSess,   showNyAm,   colNyAm,   "NY AM")
killzone(nyPmSess,   showNyPm,   colNyPm,   "NY PM")

// ‚ïê‚ïê‚ïê SECTION 6 ‚Äî CISD (Change in State of Delivery) ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpCI = "CISD"
showCISD  = input.bool(true, "Show CISD", group = grpCI)
ci30      = input.bool(true, "Enable on 30m", group = grpCI, inline = "tf")
ci60      = input.bool(true, "1h",  group = grpCI, inline = "tf")
ci240     = input.bool(true, "4h",  group = grpCI, inline = "tf")
ciAll     = input.bool(true, "Enable on every timeframe", group = grpCI)
ciSrc     = input.string("Pivots + key levels", "Sweep source",
     options = ["Any recent extreme", "Swing pivots only", "Key levels only", "Pivots + key levels"],
     group = grpCI,
     tooltip = "Any recent extreme re-fires on every bar of a trend. Pivots and key levels are real resting liquidity.")
ciPivLen  = input.int(5, "Swing pivot length", minval = 1, group = grpCI)
ciSwpLook = input.int(20, "Rolling extreme lookback", minval = 3, group = grpCI,
     tooltip = "Only used when sweep source includes Any recent extreme.")
ciWindow  = input.int(10, "Max bars from sweep to CISD", minval = 1, group = grpCI)
ciCloses  = input.int(2, "Closes beyond level to confirm", minval = 1, group = grpCI,
     tooltip = "Consecutive closes on the far side of the level before the CISD is confirmed. 1 confirms on the first close through.")
ciMinRun  = input.int(3, "Minimum candles in the run", minval = 1, group = grpCI,
     tooltip = "A one-candle run makes the CISD level the previous candle's open, which price clears constantly.")
ciHoldSwp = input.bool(true, "Sweep must occur inside the run", group = grpCI,
     tooltip = "The run being reversed has to be the one that delivered the low, not an earlier unrelated run.")
ciOnce    = input.bool(true, "One CISD per sweep", group = grpCI)
ciCool    = input.int(0, "Cooldown between signals (bars)", minval = 0, group = grpCI)
ciDispl   = input.float(0.5, "Displacement (x ATR)", minval = 0, step = 0.1, group = grpCI,
     tooltip = "Confirming candle body must exceed this multiple of ATR(14). 0 disables the filter.")
ciBeyond  = input.float(0, "Close beyond level (x ATR)", minval = 0, step = 0.1, group = grpCI,
     tooltip = "Require the close to clear the level by this much, not merely cross it.")
ciSessOn  = input.bool(false, "Restrict to a session", group = grpCI)
ciSess    = input.session("0830-1100", "CISD session", group = grpCI)
ciHist    = input.int(10, "History (signals)", minval = 1, maxval = 100, group = grpCI)
ciExt     = input.int(3, "Extend past confirmation (bars)", minval = 0, group = grpCI)
colCiUp   = input.color(#1b7a3d, "Bullish CISD", group = grpCI)
colCiDn   = input.color(#a32020, "Bearish CISD", group = grpCI)
ciSty     = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpCI)
ciWid     = input.int(1, "Line width", minval = 1, maxval = 4, group = grpCI)
ciShowLbl = input.bool(true, "Show CISD labels", group = grpCI)
ciLblPos  = input.string("Right", "Label position", options = ["Left", "Middle", "Right"], group = grpCI)
ciLblVert = input.string("Auto", "Label vertical",
     options = ["Auto", "Above line", "On line", "Below line"], group = grpCI,
     tooltip = "Auto puts bullish labels under the line and bearish labels above it.")
ciLblSz   = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpCI)

ciSecs  = timeframe.in_seconds(timeframe.period)
ciTfOk  = ciAll or (ci30 and ciSecs == 1800) or (ci60 and ciSecs == 3600) or (ci240 and ciSecs == 14400)
ciOn    = showCISD and ciTfOk
ciLblSize = ciLblSz == "Tiny" ? size.tiny : ciLblSz == "Normal" ? size.normal : size.small

// ‚îÄ‚îÄ‚îÄ Liquidity sweeps that arm a CISD ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
ciAtr = ta.atr(14)

useRoll = ciSrc == "Any recent extreme"
usePiv  = ciSrc == "Swing pivots only" or ciSrc == "Pivots + key levels"
useLvl  = ciSrc == "Key levels only"   or ciSrc == "Pivots + key levels"

ciPrevLow  = ta.lowest(low[1], ciSwpLook)
ciPrevHigh = ta.highest(high[1], ciSwpLook)
rollLowSwept  = not na(ciPrevLow)  and low  < ciPrevLow
rollHighSwept = not na(ciPrevHigh) and high > ciPrevHigh

// A pivot is consumed once taken, so a single swing low arms one sweep, not one per bar.
ciPL = ta.pivotlow(low, ciPivLen, ciPivLen)
ciPH = ta.pivothigh(high, ciPivLen, ciPivLen)
var float pivLowLvl  = na
var float pivHighLvl = na
pivLowSwept  = not na(pivLowLvl)  and low  < pivLowLvl
pivHighSwept = not na(pivHighLvl) and high > pivHighLvl
if not na(ciPL)
    pivLowLvl := ciPL
else if pivLowSwept
    pivLowLvl := na
if not na(ciPH)
    pivHighLvl := ciPH
else if pivHighSwept
    pivHighLvl := na

lvlLowSwept  = nz(aPDLx.sweep, -1) == bar_index or nz(aPWLx.sweep, -1) == bar_index
     or nz(aPMLx.sweep, -1) == bar_index
lvlHighSwept = nz(aPDHx.sweep, -1) == bar_index or nz(aPWHx.sweep, -1) == bar_index
     or nz(aPMHx.sweep, -1) == bar_index

lowSweepNow  = (useRoll and rollLowSwept)  or (usePiv and pivLowSwept)  or (useLvl and lvlLowSwept)
highSweepNow = (useRoll and rollHighSwept) or (usePiv and pivHighSwept) or (useLvl and lvlHighSwept)

var int lastLowSwp  = na
var int lastHighSwp = na
if lowSweepNow
    lastLowSwp := bar_index
if highSweepNow
    lastHighSwp := bar_index

// ‚îÄ‚îÄ‚îÄ Candle runs: the open of the first candle in the sequence ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
ciDn = close < open
ciUp = close > open

var float bearOpen  = na
var int   bearBar   = na
var bool  bearArmed = false
var float bullOpen  = na
var int   bullBar   = na
var bool  bullArmed = false

var int bearLen = 0
var int bullLen = 0

var int  bearCnt    = 0
var int  bearBreach = na
var bool bearDispl  = false
var int  bullCnt    = 0
var int  bullBreach = na
var bool bullDispl  = false

if ciDn and not ciDn[1]
    bearOpen   := open
    bearBar    := bar_index
    bearArmed  := true
    bearLen    := 1
    bearCnt    := 0
    bearBreach := na
    bearDispl  := false
else if ciDn
    bearLen := bearLen + 1
if ciUp and not ciUp[1]
    bullOpen   := open
    bullBar    := bar_index
    bullArmed  := true
    bullLen    := 1
    bullCnt    := 0
    bullBreach := na
    bullDispl  := false
else if ciUp
    bullLen := bullLen + 1

var array<line>  ciLines  = array.new<line>()
var array<label> ciLabels = array.new<label>()

drawCISD(int x1, float y, color c, bool bull) =>
    ln = line.new(clampX(x1), y, bar_index + ciExt, y, xloc.bar_index,
         color = c, style = styleOf(ciSty), width = ciWid)
    array.push(ciLines, ln)
    if array.size(ciLines) > ciHist
        line.delete(array.shift(ciLines))
    if ciShowLbl
        cx = clampX(x1)
        ex = bar_index + ciExt
        lx = ciLblPos == "Left" ? cx : ciLblPos == "Middle" ? int(math.avg(cx, ex)) : ex
        st = ciLblVert == "Above line" ? label.style_label_down
             : ciLblVert == "Below line" ? label.style_label_up
             : ciLblVert == "On line" ? label.style_none
             : (bull ? label.style_label_up : label.style_label_down)
        lb = label.new(lx, y, "CISD", xloc.bar_index, yloc.price,
             style = st, color = color.new(c, 100), textcolor = c, size = ciLblSize)
        array.push(ciLabels, lb)
        if array.size(ciLabels) > ciHist
            label.delete(array.shift(ciLabels))

ciBody   = math.abs(close - open)
ciDisplOk = ciDispl <= 0 or (not na(ciAtr) and ciBody >= ciAtr * ciDispl)

var int usedLowSwp  = na
var int usedHighSwp = na
var int lastCiBar   = na

ciInSess = not ciSessOn or not na(time(timeframe.period, ciSess))
ciCoolOk = na(lastCiBar) or bar_index - lastCiBar >= ciCool

// The level, plus any required margin beyond it.
bullLvl = bearOpen + (ciBeyond > 0 ? nz(ciAtr, 0) * ciBeyond : 0)
bearLvl = bullOpen - (ciBeyond > 0 ? nz(ciAtr, 0) * ciBeyond : 0)

// Count consecutive closes on the far side of the level. A close back inside
// resets the count, so a single poke through never accumulates toward a signal.
if bearArmed and not na(bearOpen)
    if close > bullLvl
        if bearCnt == 0
            bearBreach := bar_index
            bearDispl  := ciDisplOk
        else
            bearDispl := bearDispl or ciDisplOk
        bearCnt := bearCnt + 1
    else
        bearCnt    := 0
        bearBreach := na
        bearDispl  := false

if bullArmed and not na(bullOpen)
    if close < bearLvl
        if bullCnt == 0
            bullBreach := bar_index
            bullDispl  := ciDisplOk
        else
            bullDispl := bullDispl or ciDisplOk
        bullCnt := bullCnt + 1
    else
        bullCnt    := 0
        bullBreach := na
        bullDispl  := false

// Sweep freshness is measured to the FIRST close through, so requiring extra
// confirmation candles does not eat into the sweep window.
lowSwpFresh  = not na(lastLowSwp)  and not na(bearBreach) and bearBreach - lastLowSwp  <= ciWindow
highSwpFresh = not na(lastHighSwp) and not na(bullBreach) and bullBreach - lastHighSwp <= ciWindow
lowSwpUnused  = not ciOnce or nz(usedLowSwp, -1)  != nz(lastLowSwp, -2)
highSwpUnused = not ciOnce or nz(usedHighSwp, -1) != nz(lastHighSwp, -2)
lowInRun  = not ciHoldSwp or (not na(bearBar) and nz(lastLowSwp, -1)  >= bearBar)
highInRun = not ciHoldSwp or (not na(bullBar) and nz(lastHighSwp, -1) >= bullBar)

ciBase = ciOn and ciInSess and ciCoolOk

bullCISD = ciBase and bearArmed and bearCnt >= ciCloses and bearLen >= ciMinRun and bearDispl and lowSwpFresh and lowSwpUnused and lowInRun
bearCISD = ciBase and bullArmed and bullCnt >= ciCloses and bullLen >= ciMinRun and bullDispl and highSwpFresh and highSwpUnused and highInRun

if bullCISD
    bearArmed  := false
    usedLowSwp := lastLowSwp
    lastCiBar  := bar_index
    drawCISD(bearBar, bearOpen, colCiUp, true)
    alert("Bullish CISD on " + syminfo.ticker, alert.freq_once_per_bar)

if bearCISD
    bullArmed   := false
    usedHighSwp := lastHighSwp
    lastCiBar   := bar_index
    drawCISD(bullBar, bullOpen, colCiDn, false)
    alert("Bearish CISD on " + syminfo.ticker, alert.freq_once_per_bar)

// ‚ïê‚ïê‚ïê SECTION 7 ‚Äî CHoCH / MARKET STRUCTURE ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpCH = "CHoCH / Structure"
showCH   = input.bool(true, "Show CHoCH", group = grpCH)
chAll    = input.bool(true, "Enable on every timeframe", group = grpCH)
ch30     = input.bool(false, "30m", group = grpCH, inline = "chtf")
ch60     = input.bool(true, "1h",  group = grpCH, inline = "chtf")
ch240    = input.bool(true, "4h",  group = grpCH, inline = "chtf")
chPivLen = input.int(5, "Swing pivot length", minval = 1, group = grpCH,
     tooltip = "Larger values track only major structure. The level arms this many bars after the swing prints.")
chBreak  = input.string("Close", "Break confirmed by", options = ["Close", "Wick"], group = grpCH)
chDispl  = input.float(0.5, "Displacement (x ATR)", minval = 0, step = 0.1, group = grpCH,
     tooltip = "Require the breaking candle's body to exceed this multiple of ATR(14). This is what separates an ICT-style MSS from a bare structure break.")
showBOS  = input.bool(true, "Also mark BOS (continuation breaks)", group = grpCH)
colBosUp = input.color(#1b7a3d, "BOS bullish", group = grpCH)
colBosDn = input.color(#a32020, "BOS bearish", group = grpCH)
bosSty   = input.string("Dotted", "BOS line style", options = ["Solid", "Dashed", "Dotted"], group = grpCH)
bosWid   = input.int(1, "BOS line width", minval = 1, maxval = 4, group = grpCH)
chHist   = input.int(10, "History (signals)", minval = 1, maxval = 100, group = grpCH)
chExt    = input.int(0, "Extend past break (bars)", minval = 0, group = grpCH)
colChUp  = input.color(#2ea84f, "Bullish", group = grpCH)
colChDn  = input.color(#a32020, "Bearish", group = grpCH)
chSty    = input.string("Dotted", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpCH)
chWid    = input.int(1, "Line width", minval = 1, maxval = 4, group = grpCH)
chShowLb = input.bool(true, "Show labels", group = grpCH)
chLblPos = input.string("Middle", "Label position", options = ["Left", "Middle", "Right"], group = grpCH)
chLblVrt = input.string("Auto", "Label vertical",
     options = ["Auto", "Above line", "On line", "Below line"], group = grpCH,
     tooltip = "Auto puts bullish labels under the line and bearish labels above it.")
chLblSz  = input.string("Small", "Label size", options = ["Tiny", "Small", "Normal"], group = grpCH)

chSecs = timeframe.in_seconds(timeframe.period)
chTfOk = chAll or (ch30 and chSecs == 1800) or (ch60 and chSecs == 3600) or (ch240 and chSecs == 14400)
chOn   = showCH and chTfOk
chLblSize = chLblSz == "Tiny" ? size.tiny : chLblSz == "Normal" ? size.normal : size.small

// ‚îÄ‚îÄ‚îÄ Swing structure ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
chPH = ta.pivothigh(high, chPivLen, chPivLen)
chPL = ta.pivotlow(low, chPivLen, chPivLen)

var float swH  = na
var int   swHb = na
var float swL  = na
var int   swLb = na
var int   bias = 0

if not na(chPH)
    swH  := chPH
    swHb := bar_index - chPivLen
if not na(chPL)
    swL  := chPL
    swLb := bar_index - chPivLen

var array<line>  chLines  = array.new<line>()
var array<label> chLabels = array.new<label>()

drawCH(int x1, float y, color c, string txt, bool up, bool isBos) =>
    ln = line.new(clampX(x1), y, bar_index + chExt, y, xloc.bar_index,
         color = c, style = styleOf(isBos ? bosSty : chSty), width = isBos ? bosWid : chWid)
    array.push(chLines, ln)
    if array.size(chLines) > chHist
        line.delete(array.shift(chLines))
    if chShowLb
        cx = clampX(x1)
        ex = bar_index + chExt
        lx = chLblPos == "Left" ? cx : chLblPos == "Middle" ? int(math.avg(cx, ex)) : ex
        st = chLblVrt == "Above line" ? label.style_label_down
             : chLblVrt == "Below line" ? label.style_label_up
             : chLblVrt == "On line" ? label.style_none
             : (up ? label.style_label_up : label.style_label_down)
        lb = label.new(lx, y, txt, xloc.bar_index, yloc.price,
             style = st, color = color.new(c, 100), textcolor = c, size = chLblSize)
        array.push(chLabels, lb)
        if array.size(chLabels) > chHist
            label.delete(array.shift(chLabels))

chSrcUp = chBreak == "Close" ? close : high
chSrcDn = chBreak == "Close" ? close : low
chDisplOk = chDispl <= 0 or (not na(ciAtr) and math.abs(close - open) >= ciAtr * chDispl)

brokeUp = chOn and not na(swH) and chSrcUp > swH and chDisplOk
brokeDn = chOn and not na(swL) and chSrcDn < swL and chDisplOk

// A break against the prevailing bias is a CHoCH; with the bias it is a BOS.
// The very first break only establishes bias and is not labelled either way.
if brokeUp
    if bias == -1
        drawCH(swHb, swH, colChUp, "CHoCH", true, false)
        alert("Bullish CHoCH on " + syminfo.ticker, alert.freq_once_per_bar)
    else if bias == 1 and showBOS
        drawCH(swHb, swH, colBosUp, "BOS", true, true)
    bias := 1
    swH  := na

if brokeDn
    if bias == 1
        drawCH(swLb, swL, colChDn, "CHoCH", false, false)
        alert("Bearish CHoCH on " + syminfo.ticker, alert.freq_once_per_bar)
    else if bias == -1 and showBOS
        drawCH(swLb, swL, colBosDn, "BOS", false, true)
    bias := -1
    swL  := na

// ‚ïê‚ïê‚ïê SECTION 9 ‚Äî CONFIRMED SWING POINTS ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê
// A swing is the low (or high) of a three-candle fractal, marked only once N
// candles have closed back through it. Each confirmed swing draws a line from
// its origin candle that extends right until price sweeps it.

grpSW = "Swing Points"
showSW    = input.bool(true, "Show swing points", group = grpSW)
swLocal   = input.bool(true, "Current timeframe swings", group = grpSW)
swTF      = input.timeframe("", "Current layer timeframe", group = grpSW,
     tooltip = "Blank uses the chart timeframe. Never resolves lower than the chart.")
swCorr    = input.bool(true, "Correlated higher timeframe swings", group = grpSW,
     tooltip = "Daily on 4H ¬∑ Daily on 1H ¬∑ 8H on 30m ¬∑ 4H on 15m ¬∑ 2H on 10m ¬∑ 1H on 5m ¬∑ 30m on 3m ¬∑ 15m on 1m.")
swCorrOvr = input.timeframe("", "Correlated override", group = grpSW,
     tooltip = "Blank follows the pairing table. Set this when the chart timeframe is not in the table (45m, 90m, 2H‚Ä¶).")
swLows    = input.bool(true, "Swing lows",  group = grpSW, inline = "sd")
swHighs   = input.bool(true, "Swing highs", group = grpSW, inline = "sd")
swConfirm = input.int(3, "Confirmation candles", minval = 1, group = grpSW,
     tooltip = "How many candles must close beyond the swing candle before the swing is marked.")
swWindow  = input.int(5, "Within last N candles", minval = 1, group = grpSW,
     tooltip = "The window those confirmations must land in. 3 of the last 5 tolerates one stall candle; setting this equal to the confirmation count demands consecutive closes.")
swMode    = input.string("Swing candle high/low", "Must close beyond",
     options = ["Swing candle high/low", "Swing candle close", "Swing extreme price"], group = grpSW,
     tooltip = "For a swing low: the whole swing candle, its close, or just the low itself.")
swReqDir  = input.bool(true, "Confirming candles must be bullish / bearish", group = grpSW)
swAlt     = input.bool(true, "Enforce alternation (high ‚Üí low ‚Üí high)", group = grpSW,
     tooltip = "After a low confirms, the next swing must be a high. Keeps the output readable as structure instead of a cluster of same-side points.")
swHist    = input.int(20, "History (swings each side)", minval = 1, maxval = 50, group = grpSW)

swColLo   = input.color(#000000, "Swing low",  group = grpSW, inline = "c1")
swColHi   = input.color(#000000, "Swing high", group = grpSW, inline = "c1")
swColLoC  = input.color(#000000, "HTF low",    group = grpSW, inline = "c2")
swColHiC  = input.color(#000000, "HTF high",   group = grpSW, inline = "c2")
swCLine   = input.bool(true, "Draw HTF swings as lines", group = grpSW,
     tooltip = "The correlated layer extends right like PDH/PDL and terminates at the bar that sweeps it. The current-timeframe layer stays as plain markers.")
swCExt    = input.int(20, "HTF extend right (bars)", minval = 0, group = grpSW)
swCStop   = input.bool(true, "Stop HTF line when swept", group = grpSW)
swCSty    = input.string("Solid", "HTF line style", options = ["Solid", "Dashed", "Dotted"], group = grpSW, inline = "hl")
swCWid    = input.int(1, "width", minval = 1, maxval = 4, group = grpSW, inline = "hl")
swCSwSty  = input.string("Dotted", "HTF swept style", options = ["Solid", "Dashed", "Dotted"], group = grpSW)
swMerge   = input.bool(true, "Merge HTF swings sitting on a key level", group = grpSW,
     tooltip = "When an HTF swing matches PDH/PDL, PWH/PWL or PMH/PML, the swing's own line is hidden and its tag joins the key level's label. They separate again once the levels no longer agree.")
swMergeTk = input.float(4, "Merge tolerance (ticks)", minval = 0, step = 1, group = grpSW)
swMergeSep = input.string("    ", "Merge separator", group = grpSW)
swMarkSw  = input.bool(true, "Fade swept swings", group = grpSW,
     tooltip = "Once price trades through a swing, its marker fades so the remaining ones read as live liquidity.")
swKeepSw  = input.bool(true, "Keep swept markers on chart", group = grpSW)
swSwTr    = input.int(60, "Swept transparency", minval = 0, maxval = 100, group = grpSW)

swEqOn    = input.bool(true, "Tag equal highs / lows", group = grpSW)
swEqTicks = input.float(4, "Equal tolerance (ticks)", minval = 0, step = 1, group = grpSW,
     tooltip = "Two swings within this many ticks of each other are flagged as engineered liquidity.")
swEqCol   = input.color(#e91e63, "Equal liquidity color", group = grpSW)
swEqLo    = input.string("EQL", "Equal low label",  group = grpSW, inline = "eq")
swEqHi    = input.string("EQH", "Equal high label", group = grpSW, inline = "eq")

swTxtLo   = input.string("SL", "Low label",  group = grpSW, inline = "lb")
swTxtHi   = input.string("SH", "High label", group = grpSW, inline = "lb")
swSfxLoc  = input.bool(true, "Suffix current timeframe labels too", group = grpSW,
     tooltip = "Off gives plain SL / SH for the chart timeframe and SL-D / SH-D for the correlated one.")
swShowPx  = input.bool(false, "Show price in label", group = grpSW)
swLblSz   = input.string("Tiny", "Label size", options = ["Tiny", "Small", "Normal"], group = grpSW, inline = "sz")
swLblSzC  = input.string("Small", "HTF size", options = ["Tiny", "Small", "Normal"], group = grpSW, inline = "sz")

swLblSize  = swLblSz  == "Tiny" ? size.tiny : swLblSz  == "Normal" ? size.normal : size.small
swLblSizeC = swLblSzC == "Tiny" ? size.tiny : swLblSzC == "Normal" ? size.normal : size.small

// Chart timeframe ‚Üí the higher timeframe it pairs with.
corrOf(simple string tf) =>
    tf == "240" ? "D"   :
     tf == "60"  ? "D"   :
     tf == "30"  ? "480" :
     tf == "15"  ? "240" :
     tf == "10"  ? "120" :
     tf == "5"   ? "60"  :
     tf == "3"   ? "30"  :
     tf == "1"   ? "15"  : ""

swCorrTF = swCorrOvr != "" ? swCorrOvr : corrOf(timeframe.period)
swCorrOn = swCorr and swCorrTF != ""

// Display suffix for a timeframe string.
tfSfx(simple string tf) =>
    n = str.tonumber(tf)
    na(n) ? tf : (n >= 1440 ? str.tostring(n / 1440, "#") + "D"
         : n >= 60 ? str.tostring(n / 60, "#.##") + "H" : str.tostring(n, "#") + "M")
swTFeff = swTF == "" ? timeframe.period
     : (timeframe.in_seconds(swTF) < timeframe.in_seconds(timeframe.period) ? timeframe.period : swTF)

// Scans both sides together so alternation can be enforced between them.
swingScanAlt(simple int confirmN, simple int winN, simple string mode, simple bool reqDir, simple bool alt) =>
    // Rolling windows of qualifying closes, so one stall candle no longer
    // resets the count to zero the way a consecutive run did.
    var array<int> hitLo = array.new<int>()
    var array<int> hitHi = array.new<int>()
    win = math.max(winN, confirmN)
    var float pLo    = na
    var float pLoRef = na
    var int   pLoT   = na
    var int   cLo    = 0
    var float pHi    = na
    var float pHiRef = na
    var int   pHiT   = na
    var int   cHi    = 0
    var bool  armLo  = true
    var bool  armHi  = true
    var float oLo    = na
    var int   oLoT   = na
    var float oHi    = na
    var int   oHiT   = na

    fracLo = low[1]  < low[2]  and low[1]  < low[0]
    fracHi = high[1] > high[2] and high[1] > high[0]

    // While pending, a deeper fractal replaces the candidate.
    if fracLo and armLo and (na(pLo) or low[1] < pLo)
        pLo    := low[1]
        pLoRef := mode == "Swing candle close" ? close[1] : mode == "Swing extreme price" ? low[1] : high[1]
        pLoT   := time[1]
        cLo    := 0
        array.clear(hitLo)
    if fracHi and armHi and (na(pHi) or high[1] > pHi)
        pHi    := high[1]
        pHiRef := mode == "Swing candle close" ? close[1] : mode == "Swing extreme price" ? high[1] : low[1]
        pHiT   := time[1]
        cHi    := 0
        array.clear(hitHi)

    if not na(pLo) and armLo
        okLo = (not reqDir or close > open) and close > pLoRef
        array.push(hitLo, okLo ? 1 : 0)
        if array.size(hitLo) > win
            array.shift(hitLo)
        if array.sum(hitLo) >= confirmN
            oLo  := pLo
            oLoT := pLoT
            pLo  := na
            cLo  := 0
            array.clear(hitLo)
            if alt
                armLo := false
                armHi := true
                pHi   := na
                cHi   := 0
                array.clear(hitHi)

    if not na(pHi) and armHi
        okHi = (not reqDir or close < open) and close < pHiRef
        array.push(hitHi, okHi ? 1 : 0)
        if array.size(hitHi) > win
            array.shift(hitHi)
        if array.sum(hitHi) >= confirmN
            oHi  := pHi
            oHiT := pHiT
            pHi  := na
            cHi  := 0
            array.clear(hitHi)
            if alt
                armHi := false
                armLo := true
                pLo   := na
                cLo   := 0
                array.clear(hitLo)

    [oLo, oLoT, oHi, oHiT]

[swLoV, swLoT, swHiV, swHiT] = request.security(syminfo.tickerid, swTFeff,
     swingScanAlt(swConfirm, swWindow, swMode, swReqDir, swAlt), lookahead = barmerge.lookahead_off)

swCorrEff = swCorrTF == "" ? swTFeff : swCorrTF
[cLoV, cLoT, cHiV, cHiT] = request.security(syminfo.tickerid, swCorrEff,
     swingScanAlt(swConfirm, swWindow, swMode, swReqDir, swAlt), lookahead = barmerge.lookahead_off)

swLocSfx  = swSfxLoc ? "-" + tfSfx(swTFeff) : ""
swCorrSfx = "-" + tfSfx(swCorrEff)

// Markers placed by bar_time so an HTF swing lands on the right candle whatever
// the chart timeframe is. sSrc separates the two layers: 0 = chart timeframe,
// 1 = correlated higher timeframe.
var array<float> sVal   = array.new<float>()
var array<bool>  sIsLow = array.new<bool>()
var array<bool>  sSwept = array.new<bool>()
var array<bool>  sEq    = array.new<bool>()
var array<int>    sSrc  = array.new<int>()
var array<string> sSfx  = array.new<string>()
var array<label>  sLb   = array.new<label>()
var array<line>   sLn   = array.new<line>()

swBarMs = timeframe.in_seconds(timeframe.period) * 1000
swRight = time + swCExt * swBarMs

swBaseCol(bool isLow, bool htf) =>
    htf ? (isLow ? swColLoC : swColHiC) : (isLow ? swColLo : swColHi)

swText(bool isLow, bool eq, float v, string sfx) =>
    base = eq ? (isLow ? swEqLo : swEqHi) : (isLow ? swTxtLo : swTxtHi)
    base + sfx + (swShowPx ? " " + str.tostring(v, format.mintick) : "")

addSwing(int t0, float v, bool isLow, int src, string sfx) =>
    // Equal-liquidity check, compared only against live swings from the same
    // layer ‚Äî a daily high matching an intraday high is confluence, not an
    // equal-highs pair.
    eq = false
    if swEqOn and array.size(sVal) > 0
        tol = syminfo.mintick * swEqTicks
        for i = 0 to array.size(sVal) - 1
            sameSide  = array.get(sIsLow, i) == isLow
            sameLayer = array.get(sSrc, i) == src
            if sameSide and sameLayer and not array.get(sSwept, i)
                if math.abs(array.get(sVal, i) - v) <= tol
                    eq := true
                    array.set(sEq, i, true)
                    label.set_textcolor(array.get(sLb, i), swEqCol)
                    label.set_text(array.get(sLb, i), swText(isLow, true, array.get(sVal, i), sfx))

    c  = eq ? swEqCol : swBaseCol(isLow, src == 1)
    drawLine = src == 1 and swCLine
    lb = label.new(drawLine ? swRight : t0, v, swText(isLow, eq, v, sfx), xloc.bar_time, yloc.price,
         style     = isLow ? label.style_label_up : label.style_label_down,
         color     = color.new(c, 100),
         textcolor = c,
         size      = src == 1 ? swLblSizeC : swLblSize)
    ln = drawLine ? line.new(t0, v, swRight, v, xloc.bar_time,
         color = c, style = styleOf(swCSty), width = swCWid) : na

    array.push(sLn, ln)
    array.push(sSfx, sfx)
    array.push(sVal, v)
    array.push(sIsLow, isLow)
    array.push(sSwept, false)
    array.push(sEq, eq)
    array.push(sSrc, src)
    array.push(sLb, lb)

    if array.size(sVal) > swHist * 4
        label.delete(array.shift(sLb))
        line.delete(array.shift(sLn))
        array.shift(sSfx)
        array.shift(sVal)
        array.shift(sIsLow)
        array.shift(sSwept)
        array.shift(sEq)
        array.shift(sSrc)

locLo = showSW and swLocal and swLows  and not na(swLoT) and swLoT != swLoT[1]
locHi = showSW and swLocal and swHighs and not na(swHiT) and swHiT != swHiT[1]
htfLo = showSW and swCorrOn and swLows  and not na(cLoT) and cLoT != cLoT[1]
htfHi = showSW and swCorrOn and swHighs and not na(cHiT) and cHiT != cHiT[1]

if locLo
    addSwing(swLoT, swLoV, true,  0, swLocSfx)
if locHi
    addSwing(swHiT, swHiV, false, 0, swLocSfx)
if htfLo
    addSwing(cLoT, cLoV, true,  1, swCorrSfx)
if htfHi
    addSwing(cHiT, cHiV, false, 1, swCorrSfx)

// Mark swings as swept once price trades through them.
if array.size(sVal) > 0
    i = 0
    while i < array.size(sVal)
        if array.get(sSwept, i)
            i += 1
        else
            v     = array.get(sVal, i)
            isLow = array.get(sIsLow, i)
            hit   = isLow ? low <= v : high >= v
            ln    = array.get(sLn, i)
            if hit
                array.set(sSwept, i, true)
                if swKeepSw
                    base = array.get(sEq, i) ? swEqCol : swBaseCol(isLow, array.get(sSrc, i) == 1)
                    if swMarkSw
                        label.set_textcolor(array.get(sLb, i), color.new(base, swSwTr))
                    if not na(ln)
                        if swCStop
                            line.set_x2(ln, time)
                            label.set_x(array.get(sLb, i), time)
                        line.set_color(ln, color.new(base, swMarkSw ? swSwTr : 0))
                        line.set_style(ln, styleOf(swCSwSty))
                    i += 1
                else
                    label.delete(array.get(sLb, i))
                    if not na(ln)
                        line.delete(ln)
                    array.remove(sVal, i)
                    array.remove(sIsLow, i)
                    array.remove(sSwept, i)
                    array.remove(sEq, i)
                    array.remove(sSrc, i)
                    array.remove(sSfx, i)
                    array.remove(sLb, i)
                    array.remove(sLn, i)
            else
                // Live HTF levels keep reaching toward current price.
                if not na(ln)
                    line.set_x2(ln, swRight)
                    label.set_x(array.get(sLb, i), swRight)
                i += 1


// ‚îÄ‚îÄ‚îÄ Merge HTF swings that coincide with a key level ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ‚îÄ
// Checked every bar on the last bar, so the pair separates again the moment
// the key level rolls to a new period and the prices stop agreeing.
if swMerge and barstate.islast and array.size(sVal) > 0
    mTol = syminfo.mintick * swMergeTk
    kVal = array.from(cPDH, cPDL, cPWH, cPWL, cPMH, cPML)
    kLow = array.from(false, true, false, true, false, true)
    kOn  = array.from(showPD, showPD, showPW, showPW, showPM, showPM)
    kLbl = array.from(lPDH.lb, lPDL.lb, lPWH.lb, lPWL.lb, lPMH.lb, lPML.lb)
    kAdd = array.new<string>(6, "")

    for i = 0 to array.size(sVal) - 1
        isHtf = array.get(sSrc, i) == 1
        live  = not array.get(sSwept, i)
        if isHtf and live
            v     = array.get(sVal, i)
            isLow = array.get(sIsLow, i)
            lb    = array.get(sLb, i)
            ln    = array.get(sLn, i)
            base  = array.get(sEq, i) ? swEqCol : swBaseCol(isLow, true)

            hitIdx = -1
            for k = 0 to 5
                if hitIdx < 0 and array.get(kOn, k) and array.get(kLow, k) == isLow
                    kv = array.get(kVal, k)
                    if not na(kv) and math.abs(kv - v) <= mTol
                        hitIdx := k

            if hitIdx >= 0
                // Hand the tag to the key level and stand down.
                tag = (array.get(sEq, i) ? (isLow ? swEqLo : swEqHi) : (isLow ? swTxtLo : swTxtHi))
                     + array.get(sSfx, i)
                array.set(kAdd, hitIdx, array.get(kAdd, hitIdx) + swMergeSep + tag)
                label.set_text(lb, "")
                label.set_textcolor(lb, color.new(base, 100))
                if not na(ln)
                    line.set_color(ln, color.new(base, 100))
            else
                // No longer coincident ‚Äî restore the swing's own line and label.
                label.set_text(lb, swText(isLow, array.get(sEq, i), v, array.get(sSfx, i)))
                label.set_textcolor(lb, base)
                if not na(ln)
                    line.set_color(ln, base)

    for k = 0 to 5
        add = array.get(kAdd, k)
        if add != ""
            klb = array.get(kLbl, k)
            label.set_text(klb, label.get_text(klb) + add)

// ‚ïê‚ïê‚ïê SECTION 8 ‚Äî MTF STRUCTURE DASHBOARD ‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê‚ïê

grpDash = "Dashboard"
showDash  = input.bool(true, "Show dashboard", group = grpDash)
dashPos   = input.string("Bottom right", "Position",
     options = ["Top right", "Top center", "Top left", "Middle right", "Middle left",
                "Bottom right", "Bottom center", "Bottom left"], group = grpDash)
dashSize  = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal", "Large"], group = grpDash)
dashPiv   = input.int(5, "Structure pivot length", minval = 1, group = grpDash,
     tooltip = "Applied in each timeframe's own context, so 5 means five bars of that timeframe.")
dashShift = input.int(3, "Bars to still read as Shifting", minval = 0, group = grpDash,
     tooltip = "After structure flips, show Shifting for this many bars before settling into Bullish or Bearish.")
dashShDir = input.string("Word", "Shifting direction shown as",
     options = ["Arrow", "Word", "Both", "Off"], group = grpDash,
     tooltip = "Which way the structure just flipped. Arrow gives Shifting ‚ñ≤, Word gives Shifting Bullish.")
dashCorr  = input.bool(true, "Include correlation rows", group = grpDash)

dTf1En = input.bool(true,  "", group = grpDash, inline = "t1")
dTf1   = input.timeframe("D",   "Row 1", group = grpDash, inline = "t1")
dTf2En = input.bool(true,  "", group = grpDash, inline = "t2")
dTf2   = input.timeframe("480", "Row 2", group = grpDash, inline = "t2")
dTf3En = input.bool(true,  "", group = grpDash, inline = "t3")
dTf3   = input.timeframe("240", "Row 3", group = grpDash, inline = "t3")
dTf4En = input.bool(true,  "", group = grpDash, inline = "t4")
dTf4   = input.timeframe("60",  "Row 4", group = grpDash, inline = "t4")
dTf5En = input.bool(true,  "", group = grpDash, inline = "t5")
dTf5   = input.timeframe("30",  "Row 5", group = grpDash, inline = "t5")
dTf6En = input.bool(true,  "", group = grpDash, inline = "t6")
dTf6   = input.timeframe("15",  "Row 6", group = grpDash, inline = "t6")
dTf7En = input.bool(true,  "", group = grpDash, inline = "t7")
dTf7   = input.timeframe("5",   "Row 7", group = grpDash, inline = "t7")

dHdrBg  = input.color(#2a2e5a, "Header",     group = grpDash)
dCellBg = input.color(#131722, "Cell",       group = grpDash)
dTxt    = input.color(#d1d4dc, "Text",       group = grpDash)
dBull   = input.color(#26a69a, "Bullish",    group = grpDash)
dBear   = input.color(#ef5350, "Bearish",    group = grpDash)
dShift  = input.color(#ffa726, "Shifting",   group = grpDash)

dashPosV = dashPos == "Top right" ? position.top_right : dashPos == "Top center" ? position.top_center
     : dashPos == "Top left" ? position.top_left : dashPos == "Middle right" ? position.middle_right
     : dashPos == "Middle left" ? position.middle_left : dashPos == "Bottom center" ? position.bottom_center
     : dashPos == "Bottom left" ? position.bottom_left : position.bottom_right
dashSz = dashSize == "Tiny" ? size.tiny : dashSize == "Normal" ? size.normal
     : dashSize == "Large" ? size.large : size.small

// Structure state evaluated inside each requested timeframe's own context.
structState(simple int plen) =>
    ph = ta.pivothigh(high, plen, plen)
    pl = ta.pivotlow(low, plen, plen)
    var float h = na
    var float l = na
    var int   b = 0
    var int   ago = 99999
    ago := ago + 1
    if not na(ph)
        h := ph
    if not na(pl)
        l := pl
    if not na(h) and close > h
        if b != 1
            ago := 0
        b := 1
        h := na
    if not na(l) and close < l
        if b != -1
            ago := 0
        b := -1
        l := na
    [b, ago]

[b1, g1] = request.security(syminfo.tickerid, dTf1, structState(dashPiv), lookahead = barmerge.lookahead_off)
[b2, g2] = request.security(syminfo.tickerid, dTf2, structState(dashPiv), lookahead = barmerge.lookahead_off)
[b3, g3] = request.security(syminfo.tickerid, dTf3, structState(dashPiv), lookahead = barmerge.lookahead_off)
[b4, g4] = request.security(syminfo.tickerid, dTf4, structState(dashPiv), lookahead = barmerge.lookahead_off)
[b5, g5] = request.security(syminfo.tickerid, dTf5, structState(dashPiv), lookahead = barmerge.lookahead_off)
[b6, g6] = request.security(syminfo.tickerid, dTf6, structState(dashPiv), lookahead = barmerge.lookahead_off)
[b7, g7] = request.security(syminfo.tickerid, dTf7, structState(dashPiv), lookahead = barmerge.lookahead_off)

tfName(simple string t) =>
    n = str.tonumber(t)
    na(n) ? (t == "D" ? "Daily" : t == "W" ? "Weekly" : t == "M" ? "Monthly" : t)
     : (n >= 60 ? str.tostring(n / 60, "#.##") + "H" : str.tostring(n, "#") + "M")

var table dash = table.new(dashPosV, 2, 14, border_width = 1, border_color = #000000)

if barstate.islast and showDash
    table.clear(dash, 0, 0, 1, 13)

    names  = array.new<string>()
    biases = array.new<int>()
    agos   = array.new<int>()

    if dTf1En
        array.push(names, tfName(dTf1))
        array.push(biases, b1)
        array.push(agos, g1)
    if dTf2En
        array.push(names, tfName(dTf2))
        array.push(biases, b2)
        array.push(agos, g2)
    if dTf3En
        array.push(names, tfName(dTf3))
        array.push(biases, b3)
        array.push(agos, g3)
    if dTf4En
        array.push(names, tfName(dTf4))
        array.push(biases, b4)
        array.push(agos, g4)
    if dTf5En
        array.push(names, tfName(dTf5))
        array.push(biases, b5)
        array.push(agos, g5)
    if dTf6En
        array.push(names, tfName(dTf6))
        array.push(biases, b6)
        array.push(agos, g6)
    if dTf7En
        array.push(names, tfName(dTf7))
        array.push(biases, b7)
        array.push(agos, g7)

    table.cell(dash, 0, 0, "Timeframe", text_color = dTxt, bgcolor = dHdrBg, text_size = dashSz)
    table.cell(dash, 1, 0, "Structure", text_color = dTxt, bgcolor = dHdrBg, text_size = dashSz)

    nRows = array.size(names)
    if nRows > 0
        for i = 0 to nRows - 1
            b   = array.get(biases, i)
            ago = array.get(agos, i)
            shifting = b != 0 and ago <= dashShift
            dirWord = b == 1 ? "Bullish" : "Bearish"
            shTxt = dashShDir == "Arrow" ? "Shifting " + (b == 1 ? "‚ñ≤" : "‚ñº")
                 : dashShDir == "Word" ? "Shifting " + dirWord
                 : dashShDir == "Both" ? "Shifting " + dirWord + " " + (b == 1 ? "‚ñ≤" : "‚ñº")
                 : "Shifting"
            txt = b == 0 ? "Neutral" : shifting ? shTxt : dirWord
            c   = b == 0 ? dTxt : shifting ? dShift : b == 1 ? dBull : dBear
            table.cell(dash, 0, i + 1, array.get(names, i), text_color = dTxt, bgcolor = dCellBg, text_size = dashSz)
            table.cell(dash, 1, i + 1, txt, text_color = c, bgcolor = dCellBg, text_size = dashSz)

    if dashCorr
        base = array.size(names) + 1
        table.cell(dash, 0, base, "Correlation", text_color = dTxt, bgcolor = dHdrBg, text_size = dashSz)
        table.cell(dash, 1, base, smtActive ? "" : "SMT off", text_color = dTxt, bgcolor = dHdrBg, text_size = dashSz)
        if smtActive
            table.cell(dash, 0, base + 1, nameA, text_color = dTxt, bgcolor = dCellBg, text_size = dashSz)
            table.cell(dash, 1, base + 1, str.tostring(corrA, "#.00"), text_color = corrCol(corrA),
                 bgcolor = dCellBg, text_size = dashSz)
            if useB
                table.cell(dash, 0, base + 2, nameB, text_color = dTxt, bgcolor = dCellBg, text_size = dashSz)
                table.cell(dash, 1, base + 2, str.tostring(corrB, "#.00"), text_color = corrCol(corrB),
                     bgcolor = dCellBg, text_size = dashSz)
````
