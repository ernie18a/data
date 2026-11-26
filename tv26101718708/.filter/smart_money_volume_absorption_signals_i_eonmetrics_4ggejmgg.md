# Smart Money Volume Absorption Signals I EonMetrics

- url: https://www.tradingview.com/script/4ggEjmgG-Smart-Money-Volume-Absorption-Signals-I-EonMetrics/
- type: indicator
- pine_id: PUB;aa194e3cb70a4b19aa3cb7733c30dd24
- version: 1.0

## Description

Smart Money Volume Absorption Signals

Volume Absorption marks a specific situation as a LONG or SHORT setup, with an entry, a stop and two targets. But instead of only printing an arrow and leaving you to reconstruct what happened, it tracks that setup through four stages and shows you exactly how far along it is — how many conditions are met, which one is still missing, how many bars are left before the setup is discarded, and what the same sequence has already done on the history your chart has loaded.

https://www.tradingview.com/x/RWZui8W1/

🔶[b]THE SITUATION IT TRACKS[/b]

A bar trades far more volume than its own recent normal, and then closes at the wrong end of its own range. Heavy participation that failed to pay the side that pushed: effort without result. The direction is set against the side that was absorbed — a heavy bar closing in the bottom third of its range is a short premise, one closing in the top third is a long premise.

One thing has to be said plainly, because it decides how much weight this premise deserves: total volume cannot tell you who traded. It cannot separate buyers from sellers. What this gate actually measures is heavy participation combined with a failure to hold the direction the bar travelled. The absorption reading is an interpretation of that pattern, not a measurement of order flow. If you want that distinction to matter less, the remaining three gates are where the work is done.

Absorption on its own happens constantly and most of it leads nowhere. So the tool requires three further confirmations, in order, before it marks anything.

🔶[b]THE FOUR GATES[/b]

G1 · ABSORPTION — bar volume lands in an extreme percentile of its own recent history while the bar closes in the far third of its own range. This gate fixes the direction and nothing later can change it. It also plants the invalidation anchor at that bar's extreme. Optionally the direction must agree with a slow trend filter.

G2 · REACTION — a following bar closes in the direction G1 set. The absorption produced something instead of merely stalling.

G3 · EXPANSION — a candle body in the top percentile of its own recent history, pointing the setup's way. That candle's OPEN becomes the origin level, and the origin level is where entry would be.

G4 · HOLD — price returns to the origin level and closes without violating it. Only now does the signal print, on bar close.

This is a retest model, not a breakout model, and the consequence is worth stating before you use it. A setup whose expansion runs away and never comes back to the origin level will never complete, no matter how far the move goes. You will see setups sit at 3/4 while price travels past the drawn targets, and then expire. That is the design working as intended — the entry is the retest — but if you want a tool that chases the move instead, this is not that tool.

The dashboard reads: which stage the setup is in, the direction, which gate is being waited on, the expiry countdown, the entry and stop levels, and the record of every completed setup on the loaded history.

🔶[b]ORIGINALITY[/b]

Five design decisions separate this from a stack of conditions with an AND between them.

Percentiles instead of ATR multiples. A fixed "1.5 × ATR" or "2 × average volume" threshold means something different in a trending market than in a compressed one, so it has to be re-tuned per symbol and per period. Every threshold here is a percentile rank against the instrument's own recent history — "top 30% of the last 200 bars" keeps its meaning when volatility changes, without tuning.

Gates do not add up to a score. Each gate is a separate class of evidence and none substitutes for another. Three expansion bars in a row are still 1/4, not 3/4. A weighted-sum model can be outvoted by one loud condition repeating itself; this one cannot. There is deliberately no confidence percentage anywhere in this script — with four binary gates in a fixed sequence, the only honest information is how many of them have filled, and dressing that up as a percentage would add precision that does not exist.

The setup dies on its own. Every tracked setup carries an invalidation anchor (a close beyond the absorption bar's extreme) and a bar countdown that resets at each gate advance. When either fires, the setup is discarded immediately — it does not linger until an opposite signal replaces it, and it does not quietly stay on the books.

One setup at a time. While a completed setup is still resolving toward its target or its stop, a new setup will not complete — it waits at 3/4 and may still fire later if the first one resolves in time, or expire if it does not. This exists so that what the dashboard counts is what a person following the tool could actually have taken, one position at a time, rather than an overlapping stack of positions nobody could hold.

It shows its own record. The last two rows of the dashboard walk every completed setup on the chart you are looking at, bar by bar, and count which level price reached first — Target 1 or the stop. The stop is checked before the target, so a bar that spans both counts against the setup, and the bar the signal prints on is not counted at all. That number is whatever it is. It is not a claim, it is not tuned to flatter, and it will read differently on every symbol and timeframe you load — which is exactly the point. You are meant to check it on YOUR instrument before deciding what the tool is worth to you, instead of taking anyone's word for it. Most signal tools do not show this. That is a choice they made, and this is a different one.

🔶[b]HOW IT IS CALCULATED[/b]

Both percentile ranks are ta.percentrank() over one configurable window — one on bar volume (G1), one on the absolute candle body (G3). The close position is (close − low) / (high − low), so it describes where the bar finished inside its own range rather than relative to any external level.

The optional trend filter is a plain exponential moving average of the closing price on the chart's own timeframe, used as a slow-trend proxy: long setups are only allowed above it, short setups only below it. Set its length to 0 to switch it off. There are no higher-timeframe data requests anywhere in this script.

Entry is the open of the expansion bar. The stop is the absorption bar's extreme, plus an optional buffer in ticks. Both targets are multiples of that entry-to-stop distance, so they scale with the setup instead of with a fixed price amount. Target 1 is the level the record row measures against; Target 2 is drawn for reference only.

Every gate is evaluated and latched on confirmed bars only. There is no lookahead and there are no forward-looking references. A filled gate is never un-filled retroactively; the live bar can only be rejected, never rewritten. A bar that would satisfy two gates at once advances the setup by exactly one step — each gate has to be paid for with its own bar.

The chart geometry is redrawn from scratch on the last bar rather than accumulated, so what you see on the chart is always the setup the dashboard is describing, and closed setups do not leave debris behind.

🔶[b]ALERTS[/b]

Six conditions: setup reached 2/4, setup reached 3/4, signal LONG, signal SHORT, setup expired, setup invalidated.

The staged alerts follow from the same idea as the meter: being told a setup is one gate away is more useful than only being told after it is over.

🔶[b]HOW TO USE[/b]

1. Read the record row before anything else. Load your instrument and your timeframe and see what it says there. If it does not convince you, that is the tool telling you honestly that it is not for that market.
2. Check the sample size in the same row. A run of ten or twenty setups is an anecdote. The row flags small samples for exactly this reason.
3. Watch the meter, not the arrows. Most of the information is in setups that reach 2/4 or 3/4 and then die — that tells you what the market is refusing to do.
4. The stop sits at the absorption bar's extreme by default, which is tight. On fast intraday charts try the Stop Buffer input and watch how the record row responds.
5. The trend filter changes the population of setups substantially. Check the record row with it on and with it off on your own market before deciding which you prefer.
6. Set the 3/4 alert if you want to be at the chart before a setup completes rather than after.

🔶[b]SETTINGS[/b]

Volume (percentile window) · Gate Thresholds (G1 volume percentile, G1 close position, G3 body percentile, trend filter length, setup TTL) · Trade Levels (draw toggle, stop buffer in ticks, two R-multiple targets) · Display (dashboard and position, current-signal marker, all-past-signals marker, colors).

🔶[b]HONEST LIMITATIONS[/b]

Volume alone cannot be attributed to buyers or sellers. This tool reads total bar volume against the bar's close position. It does not know who traded, and it is not order-flow data. Treat the absorption premise as a reading of effort against result, which is what it is.

The volume itself is only as good as the feed. On spot forex and CFDs the exchange reports TICK volume rather than real traded volume, so the percentile ranks describe activity rather than quantity. On symbols with no volume data at all the gates cannot fill, and the dashboard says so in its top-right corner.

The retest requirement will cost you moves. As described above, setups that never return to the origin level expire unfilled even when price travels well beyond the drawn targets. This is structural, not a bug, and on strongly trending stretches it happens often.

Percentiles are relative to their window. After an abrupt change of volatility regime the ranks need a few dozen bars to catch up, and during that stretch the thresholds are still measuring the old regime.

The record row is an honest count, not a backtest. It assumes a fill at the exact entry price and it ignores fees, spread and slippage — all of which work against you in reality, and all of which matter a great deal when the outcome is close to even. A record that looks positive before costs can be negative after them. It also covers only the setups on the history your chart has loaded, which on intraday timeframes is a small sample.

Results vary far more between markets than between settings. The same script on the same timeframe can produce a very different record on two different symbols, and there is no timeframe this tool is generally "best" on. Any suggestion otherwise would be an invention. Check your own market.

This tool describes a sequence of conditions in price and volume. It does not forecast anything, it makes no claim about how often the sequence resolves favourably, and the drawn levels are the geometry of the setup, not a recommendation. It is published for analysis and education, it is not financial advice, and past behaviour of a pattern does not guarantee its future behaviour. Check the record on your own market, manage your own risk, and decide for yourself.

Part of the EonMetrics toolset.

## Source Code

````pine
//@version=6
indicator('Smart Money Volume Absorption Signals EonMetrics', 'Smart Money Volume Absorption Signals', overlay=true, max_lines_count=100, max_labels_count=100, max_boxes_count=50)

// ═════════════════════════════════════════════════════════════════════════════
//  VOLUME
// ═════════════════════════════════════════════════════════════════════════════
grpFlow = 'Volume'

pctLen = input.int(200, 'Percentile Window', minval=30, maxval=1000, group=grpFlow,
  tooltip = 'How many bars each percentile rank is measured against. Longer = more stable definition of "extreme", slower to adapt after a regime change. 200 is a reasonable middle.')

// ═════════════════════════════════════════════════════════════════════════════
//  GATE THRESHOLDS
// ═════════════════════════════════════════════════════════════════════════════
grpGate = 'Gate Thresholds'

thrAbs = input.int(70, 'G1 · Volume Percentile', minval=50, maxval=99, group=grpGate,
  tooltip = 'How heavy the bar volume has to be to qualify as an absorption candidate. 70 = top 30% of the window. Higher = fewer, cleaner candidates.')

thrPos = input.float(0.33, 'G1 · Close Position', minval=0.05, maxval=0.49, step=0.01, group=grpGate,
  tooltip = 'How badly price has to fail to travel on that heavy volume. 0.33 means a heavy-volume bar must close in the bottom third of its own range to count as buyers-absorbed (a short premise), or the top third for sellers-absorbed (a long premise). Lower = stricter.')

thrExp = input.int(80, 'G3 · Body Percentile', minval=50, maxval=99, group=grpGate,
  tooltip = 'How large the expansion body has to be relative to its own recent history. 80 = top 20% of the window.')

htfLen = input.int(96, 'Trend Filter Length (0 = off)', minval=0, maxval=1000, group=grpGate,
  tooltip = 'Only allows setups pointing the same way as the slow trend, measured as price against an EMA of this many bars on the chart timeframe. No higher-timeframe data is requested. 0 disables the filter. Check the record row at the bottom of the dashboard with it on and off on YOUR market before deciding.')

ttlBars = input.int(50, 'Setup TTL (bars)', minval=3, maxval=500, group=grpGate,
  tooltip = 'How long a setup may stay alive without completing. The countdown starts when G1 fills and resets at every gate advance. When it runs out the setup is discarded.')

// ═════════════════════════════════════════════════════════════════════════════
//  TRADE LEVELS
// ═════════════════════════════════════════════════════════════════════════════
grpLvl = 'Trade Levels'

showLevels = input.bool(true, 'Draw Entry / Stop / Targets', group=grpLvl,
  tooltip = 'Draws the geometry of the setup that is live right now: stop beyond the absorption bar as soon as G1 fills, then entry at the origin level and two R-multiple targets from G3. Dashed while the fourth gate is still open, solid once it closes. Old setups are erased rather than left on the chart. Geometry, not advice — the levels are derived from the setup, not from any forecast.')

slBuf = input.float(0.0, 'Stop Buffer (ticks)', minval=0, maxval=1000, step=1, group=grpLvl,
  tooltip = 'Extra distance placed beyond the absorption bar extreme, in ticks. 0 puts the stop exactly at the extreme.')

tp1Mult = input.float(2.0, 'Target 1 (R)', minval=0.1, maxval=20, step=0.1, group=grpLvl)
tp2Mult = input.float(3.0, 'Target 2 (R)', minval=0.1, maxval=20, step=0.1, group=grpLvl,
  tooltip = 'Targets as multiples of the entry-to-stop distance. Target 1 is the level the record row at the bottom of the dashboard measures against — change it and the record recalculates for the new target.')

// ═════════════════════════════════════════════════════════════════════════════
//  DISPLAY
// ═════════════════════════════════════════════════════════════════════════════
grpDisp = 'Display'

showPanel = input.bool(true, 'Show Dashboard', group=grpDisp)
panelPos  = input.string('Top Right', 'Dashboard Position', options=['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left'], group=grpDisp)
showArrow = input.bool(true, 'Mark Current Signal', group=grpDisp,
  tooltip = 'Puts a BUY/SELL tag on the bar where the setup now on the chart completed. It is removed together with that setup, so only one is ever on screen.')

showPast  = input.bool(false, 'Mark All Past Signals', group=grpDisp,
  tooltip = 'Tags every completed setup on the whole history. Off by default because they pile up, but this is what the record row at the bottom of the dashboard is counting — turn it on when you want to check that number against the chart instead of taking it on trust.')

colLong  = input.color(#089981, 'Long',  inline='c', group=grpDisp)
colShort = input.color(#f23645, 'Short', inline='c', group=grpDisp)
colWarn  = input.color(#ffb300, 'Pending', inline='c', group=grpDisp)

// ═════════════════════════════════════════════════════════════════════════════
//  PERCENTILE RANKS
// ═════════════════════════════════════════════════════════════════════════════
rng       = high - low
rankVol   = ta.percentrank(nz(volume), pctLen)
body      = math.abs(close - open)
rankBody  = ta.percentrank(body, pctLen)

// ═════════════════════════════════════════════════════════════════════════════
//  GATE CONDITIONS
// ═════════════════════════════════════════════════════════════════════════════
closePos = rng > 0 ? (close - low) / rng : 0.5

htfEma   = htfLen > 0 ? ta.ema(close, htfLen) : na
trendUp  = htfLen == 0 or (not na(htfEma) and close > htfEma)
trendDn  = htfLen == 0 or (not na(htfEma) and close < htfEma)

g1Raw    = rankVol >= thrAbs and volume > 0
g1Short  = g1Raw and closePos <= thrPos and trendDn
g1Long   = g1Raw and closePos >= 1.0 - thrPos and trendUp
g1Hit    = g1Long or g1Short
g1DirNew = g1Long ? 1 : g1Short ? -1 : 0

expLong  = rankBody >= thrExp and close > open
expShort = rankBody >= thrExp and close < open

// ═════════════════════════════════════════════════════════════════════════════
//  STATE MACHINE
// ═════════════════════════════════════════════════════════════════════════════
var int   gState  = 0
var int   gDir    = 0
var float gAnchor = na
var float gOrigin = na
var int   gTtl    = 0
var int   gBar    = na
var float sigE    = na
var float sigSL   = na
var float sigTP1  = na
var float sigTP2  = na
var float sigR    = na

var bool  trOpen = false
var int   trDir  = 0
var float trE    = na
var float trSL   = na
var float trTP   = na
var int   trBar  = na
var int   nRes   = 0
var int   nWin   = 0

bool firedLong  = false
bool firedShort = false
bool expired    = false
bool killed     = false

if barstate.isconfirmed
    if trOpen
        bool slHit = trDir > 0 ? low  <= trSL : high >= trSL
        bool tpHit = trDir > 0 ? high >= trTP : low  <= trTP
        if slHit
            nRes   += 1
            trOpen := false
        else if tpHit
            nRes   += 1
            nWin   += 1
            trOpen := false

    if gState > 0 and gState < 4
        gTtl -= 1
        bool inval = gDir > 0 ? close < gAnchor : close > gAnchor
        if inval
            killed  := true
            gState  := 0
            gDir    := 0
            gAnchor := na
            gOrigin := na
        else if gTtl <= 0
            expired := true
            gState  := 0
            gDir    := 0
            gAnchor := na
            gOrigin := na

    if gState == 4
        gState  := 0
        gDir    := 0
        gAnchor := na
        gOrigin := na

    if gState == 3
        bool touched = gDir > 0 ? low <= gOrigin : high >= gOrigin
        bool heldOk  = gDir > 0 ? close > gOrigin : close < gOrigin
        if touched and heldOk and not trOpen
            gState := 4
            gTtl   := ttlBars
            sigE   := gOrigin
            sigSL  := gDir > 0 ? gAnchor - slBuf * syminfo.mintick : gAnchor + slBuf * syminfo.mintick
            float risk = math.abs(sigE - sigSL)
            sigR   := risk
            sigTP1 := gDir > 0 ? sigE + tp1Mult * risk : sigE - tp1Mult * risk
            sigTP2 := gDir > 0 ? sigE + tp2Mult * risk : sigE - tp2Mult * risk
            firedLong  := gDir > 0
            firedShort := gDir < 0

    if gState == 2
        bool expOk = gDir > 0 ? expLong : expShort
        if expOk
            gState  := 3
            gOrigin := open
            gTtl    := ttlBars

    if gState == 1
        bool reactOk = gDir > 0 ? close > open : close < open
        if reactOk
            gState := 2
            gTtl   := ttlBars

    if gState == 0 and g1Hit
        gState  := 1
        gDir    := g1DirNew
        gAnchor := g1DirNew > 0 ? low : high
        gOrigin := na
        gTtl    := ttlBars
        gBar    := bar_index

    if firedLong or firedShort
        trOpen := true
        trDir  := firedLong ? 1 : -1
        trE    := sigE
        trSL   := sigSL
        trTP   := sigTP1
        trBar  := bar_index

// ═════════════════════════════════════════════════════════════════════════════
//  DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════
f_pos(string p) =>
    p == 'Top Left' ? position.top_left : p == 'Bottom Right' ? position.bottom_right : p == 'Bottom Left' ? position.bottom_left : position.top_right

f_missing(int st) =>
    st == 0 ? 'G1 · absorption' : st == 1 ? 'G2 · reaction' : st == 2 ? 'G3 · expansion' : st == 3 ? 'G4 · hold' : '—'

f_stateTxt(int st, bool live) =>
    st >= 4 ? 'SIGNAL' : st == 3 ? 'READY' : st >= 1 ? 'FORMING' : live ? 'IN TRADE' : 'SCANNING'

f_dirTxt(int d) =>
    d > 0 ? 'LONG' : d < 0 ? 'SHORT' : '—'

f_meter(int st) =>
    string s = ''
    for i = 1 to 4
        s := s + (i <= st ? '█' : '░')
    s

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        panel := table.new(f_pos(panelPos), 2, 7, bgcolor=#0d1117, border_width=1, border_color=color.new(color.gray, 70))

    bool   live   = trOpen and gState == 0
    int    panDir = gState >= 1 ? gDir : live ? trDir : 0
    int    shown  = gState >= 1 ? math.min(gState, 4) : live ? 4 : 0
    color  stateC = (gState >= 4 or live) ? (panDir > 0 ? colLong : colShort) : gState == 3 ? colWarn : color.new(color.gray, 20)

    table.cell(panel, 0, 0, 'VOLUME ABSORPTION', text_color=color.white, text_size=size.small, text_halign=text.align_left, bgcolor=#0d1117)
    table.cell(panel, 1, 0, na(volume) or volume == 0 ? 'no volume data' : 'volume-based', text_color=na(volume) or volume == 0 ? colWarn : color.new(color.gray, 30), text_size=size.tiny, text_halign=text.align_right, bgcolor=#0d1117)

    table.cell(panel, 0, 1, f_stateTxt(gState, live) + '  ' + f_meter(shown) + '  ' + str.tostring(shown) + '/4', text_color=color.white, text_size=size.large, text_halign=text.align_left, bgcolor=color.new(stateC, 20))
    table.cell(panel, 1, 1, f_dirTxt(panDir), text_color=color.white, text_size=size.large, text_halign=text.align_right, bgcolor=color.new(stateC, 20))

    table.cell(panel, 0, 2, 'waiting for', text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left, bgcolor=#0d1117)
    table.cell(panel, 1, 2, live ? 'target or stop' : f_missing(gState), text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=#0d1117)

    table.cell(panel, 0, 3, 'expires in', text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left, bgcolor=#0d1117)
    table.cell(panel, 1, 3, gState > 0 and gState < 4 ? str.tostring(math.max(gTtl, 0)) + ' bars' : '—', text_color=color.white, text_size=size.small, text_halign=text.align_right, bgcolor=#0d1117)

    float rowE  = na
    float rowSL = na
    if gState >= 4
        rowE  := sigE
        rowSL := sigSL
    else if gState >= 1
        rowSL := gDir > 0 ? gAnchor - slBuf * syminfo.mintick : gAnchor + slBuf * syminfo.mintick
        rowE  := gState == 3 ? gOrigin : na
    else if live
        rowE  := trE
        rowSL := trSL

    bool   proj  = gState >= 1 and gState < 4
    string lvlTx = na(rowSL) ? '—' :
         (na(rowE) ? '—' : str.tostring(rowE, format.mintick)) + ' / ' + str.tostring(rowSL, format.mintick) + (proj ? '  · if it completes' : '')

    table.cell(panel, 0, 4, 'entry / stop', text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left, bgcolor=#0d1117)
    table.cell(panel, 1, 4, lvlTx, text_color=na(rowSL) ? color.new(color.gray, 30) : proj ? colWarn : color.white, text_size=size.small, text_halign=text.align_right, bgcolor=#0d1117)

    float expR = nRes > 0 ? (nWin * tp1Mult - (nRes - nWin)) / nRes : na
    string recTx = nRes == 0 ? 'no resolved setups yet' :
         str.tostring(nWin) + ' / ' + str.tostring(nRes) + ' reached ' + str.tostring(tp1Mult, '#.#') + 'R'
    string expTx = na(expR) ? '—' : (expR >= 0 ? '+' : '') + str.tostring(expR, '#.##') + 'R per setup' + (nRes < 30 ? '  · sample too small' : '')
    table.cell(panel, 0, 5, 'on this history', text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left, bgcolor=#0d1117)
    table.cell(panel, 1, 5, recTx, text_color=color.new(color.gray, 15), text_size=size.small, text_halign=text.align_right, bgcolor=#0d1117)
    table.cell(panel, 0, 6, 'per setup', text_color=color.new(color.gray, 30), text_size=size.small, text_halign=text.align_left, bgcolor=#0d1117)
    table.cell(panel, 1, 6, expTx, text_color=na(expR) ? color.new(color.gray, 30) : expR > 0 ? colLong : colShort, text_size=size.small, text_halign=text.align_right, bgcolor=#0d1117)

// ═════════════════════════════════════════════════════════════════════════════
//  CHART OBJECTS
// ═════════════════════════════════════════════════════════════════════════════
plotshape(showPast and firedLong,  'Signal Long',  style=shape.triangleup,   location=location.belowbar, color=colLong,  size=size.small, text='BUY',  textcolor=colLong)
plotshape(showPast and firedShort, 'Signal Short', style=shape.triangledown, location=location.abovebar, color=colShort, size=size.small, text='SELL', textcolor=colShort)

var line  lnE   = na
var line  lnSL  = na
var line  lnT1  = na
var line  lnT2  = na
var label lbE   = na
var label lbSL  = na
var label lbT1  = na
var label lbT2  = na
var label lbSig = na

if barstate.islast
    line.delete(lnE)
    line.delete(lnSL)
    line.delete(lnT1)
    line.delete(lnT2)
    label.delete(lbE)
    label.delete(lbSL)
    label.delete(lbT1)
    label.delete(lbT2)
    label.delete(lbSig)
    lnE  := na
    lnSL := na
    lnT1 := na
    lnT2 := na
    lbE  := na
    lbSL := na
    lbT1 := na
    lbT2 := na
    lbSig := na

    bool  inTrade = trOpen and gState == 0
    int   dspDir  = gState >= 1 ? gDir : inTrade ? trDir : 0
    bool  dspProj = gState >= 1 and gState < 4
    float dspE    = na
    float dspSL   = na
    int   dspX1   = na

    if gState >= 1
        dspSL := gDir > 0 ? gAnchor - slBuf * syminfo.mintick : gAnchor + slBuf * syminfo.mintick
        dspE  := gState >= 3 ? gOrigin : na
        dspX1 := gBar
    else if inTrade
        dspE  := trE
        dspSL := trSL
        dspX1 := trBar

    if not na(dspSL)
        color lc = dspDir > 0 ? colLong : colShort
        color ec = dspProj ? colWarn : lc
        int   x1 = na(dspX1) ? bar_index - 20 : dspX1
        int   x2 = bar_index + 10

        if showLevels
            lnSL := line.new(x1, dspSL, x2, dspSL, color=color.new(colShort, 20), width=1, style=line.style_dashed)
            lbSL := label.new(x2, dspSL, 'Stop ' + str.tostring(dspSL, format.mintick), style=label.style_label_left, color=color.new(colShort, 85), textcolor=chart.fg_color, size=size.small)

            if not na(dspE)
                float risk = math.abs(dspE - dspSL)
                float t1   = dspDir > 0 ? dspE + tp1Mult * risk : dspE - tp1Mult * risk
                float t2   = dspDir > 0 ? dspE + tp2Mult * risk : dspE - tp2Mult * risk
                lnE  := line.new(x1, dspE, x2, dspE, color=ec, width=2, style=dspProj ? line.style_dashed : line.style_solid)
                lnT1 := line.new(x1, t1,   x2, t1,   color=color.new(lc, 15), width=1, style=line.style_dotted)
                lnT2 := line.new(x1, t2,   x2, t2,   color=color.new(lc, 55), width=1, style=line.style_dotted)
                lbE  := label.new(x2, dspE, 'Entry ' + str.tostring(dspE, format.mintick), style=label.style_label_left, color=color.new(ec, 85), textcolor=chart.fg_color, size=size.small)
                lbT1 := label.new(x2, t1,   str.tostring(tp1Mult, '#.#') + 'R',            style=label.style_label_left, color=color.new(lc, 70), textcolor=chart.fg_color, size=size.small)
                lbT2 := label.new(x2, t2,   str.tostring(tp2Mult, '#.#') + 'R',            style=label.style_label_left, color=color.new(lc, 85), textcolor=chart.fg_color, size=size.small)

        if showArrow and (gState >= 4 or inTrade) and not na(trBar) and not na(dspE)
            lbSig := label.new(trBar, dspE, dspDir > 0 ? 'BUY' : 'SELL', style=dspDir > 0 ? label.style_label_up : label.style_label_down, color=color.new(lc, 25), textcolor=color.white, size=size.small)

// ═════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═════════════════════════════════════════════════════════════════════════════
stage2 = gState == 2 and gState[1] < 2
stage3 = gState == 3 and gState[1] < 3

alertcondition(stage2,     title='1. Setup reached 2/4', message='Volume Absorption: setup FORMING at 2/4 — absorption confirmed by a reaction bar.')
alertcondition(stage3,     title='2. Setup reached 3/4', message='Volume Absorption: setup READY at 3/4 — entry and stop are known, one gate left (hold at the origin level).')
alertcondition(firedLong,  title='3. Signal LONG',       message='Volume Absorption: all four gates filled — LONG setup completed on {{ticker}} at {{close}}.')
alertcondition(firedShort, title='4. Signal SHORT',      message='Volume Absorption: all four gates filled — SHORT setup completed on {{ticker}} at {{close}}.')
alertcondition(expired,    title='5. Setup expired',     message='Volume Absorption: the tracked setup expired without completing.')
alertcondition(killed,     title='6. Setup invalidated', message='Volume Absorption: the tracked setup was invalidated — price closed beyond the absorption bar.')

// ═════════════════════════════════════════════════════════════════════════════
//  STATE FEED
// ═════════════════════════════════════════════════════════════════════════════
VDA_SCHEMA = 11
feedState = math.min(gState, 4) * 1000 + (math.max(-1, math.min(1, gDir)) + 1) * 100 + VDA_SCHEMA

plot(feedState, 'F1 · VDA STATE [v1]',  display=display.data_window)
plot(sigE,      'F2 · VDA ENTRY [v1]',  display=display.data_window)
plot(sigSL,     'F3 · VDA STOP [v1]',   display=display.data_window)
plot(sigTP2,    'F4 · VDA TARGET [v1]', display=display.data_window)
````
