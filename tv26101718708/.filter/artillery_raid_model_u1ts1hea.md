# Artillery Raid Model

- url: https://www.tradingview.com/script/U1ts1hea-Artillery-Raid-Model/
- type: indicator
- pine_id: PUB;7ed5a39ee80b430b945a8a90f0e6e6b7
- version: 1.0

## Description

Artillery · Raid Model is an intraday liquidity tool for index futures (ES, NQ, MNQ) on 1–5 minute charts. It maps where resting liquidity sits, detects when that liquidity is raided during the New York morning, and only signals a trade after price confirms the reversal with a market-structure shift and a fair-value-gap retrace.

WHAT IT DRAWS
• Session ranges: Asia, London and NY AM boxes that build live as each session forms.
• Liquidity pools: Asia/London highs and lows, previous day high/low, previous week high/low, midnight open, and equal highs/lows (two swing points within a small ATR tolerance).
• Pool status: when price trades through a pool and closes back inside within N bars, the label flips to "RAIDED". If price closes through and stays there, it is marked "TAKEN" (a breakout, not a raid).
• Structure: BOS and CHoCH lines from confirmed pivots, plus a bold MSS line for the shift that follows a raid.
• Fair value gaps: three-candle imbalances shown as boxes that disappear once filled. The gap used by a setup is highlighted as ENTRY ZONE.
• Signals: BUY / SELL tags when the simulated limit order fills, target and stop boxes, and the result in R when the signal closes.
• Dashboard: 4H bias, current structure, active session, last raid, setup status, signals today, win rate, net R and a setup funnel (raids → MSS → orders → fills).

HOW A SIGNAL FORMS
1. During the NY AM window, a liquidity pool is raided (traded through, then reclaimed).
2. Within the next bars, a displacement candle (body ≥ a multiple of ATR) closes beyond the high/low of the leg that made the raid. This is the MSS.
3. A fair value gap that formed after the raid becomes the entry zone. A limit is placed at the gap's edge or 50% (consequent encroachment).
4. Stop goes beyond the raid extreme plus a tick buffer. Target is the nearest untouched opposite liquidity pool that offers at least the minimum R, otherwise a fixed R.
5. Unfilled orders cancel after N bars, if price invalidates the stop, or when the window closes. Open signals close at the end-of-day flatten time.

WHAT MAKES IT DIFFERENT
Most smart-money tools label every BOS and FVG on the chart. This script runs an ordered state machine: a setup can only arm after a raid, can only trigger after a displacement MSS, and only uses a gap formed after the raid. Raids are separated from breakouts with a reclaim window, and targets come from the same liquidity map that produced the raid. The built-in signal tracker scores every signal with the same rules (if stop and target are hit on the same bar it counts as a loss) so the dashboard numbers stay conservative.

HOW TO USE IT
• Apply to ES, NQ or MNQ on a 1m–5m chart. All session times are New York time and can be changed in the inputs.
• Tune "Raid must reclaim within N bars", "MSS displacement" and "Min R" to match your instrument and risk.
• Optional 4H EMA bias filter only allows signals in the direction of the higher-timeframe trend.
• Alerts are built in for raids, limit placements, fills and exits. Create an alert and choose "Any alert() function call".

NOTES
• Calculations use confirmed pivots and higher-timeframe data offset by one bar, so drawings do not repaint after the bar closes.
• The signal tracker is a simplified simulation without commissions or slippage. It is a study tool, not a backtest or a guarantee of future results.
• This script is for education and analysis only and is not financial advice. Always manage your own risk.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
//  ARTILLERY · RAID MODEL                                    © artillerytrades
//  Liquidity raid → market-structure shift (MSS) → fair-value-gap retrace.
//  Original code. Built for ES / NQ / MNQ on 1m–5m. Session times = New York.
//  Non-repainting: pivots confirm after `pivLen` bars, HTF data offset by [1].
// ─────────────────────────────────────────────────────────────────────────────
indicator("Artillery · Raid Model", shorttitle="ART Raid", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=500)

tz = "America/New_York"

// ═════════════════════════════ INPUTS ═══════════════════════════════════════
g1 = "⏱ Sessions (New York time)"
asiaSess = input.session("2000-2359", "Asia",                group=g1)
lonSess  = input.session("0200-0500", "London",              group=g1)
nySess   = input.session("0930-1200", "NY AM · trade window", group=g1)
flatSess = input.session("1555-1600", "Flatten all",         group=g1)
showKZ   = input.bool(true, "Draw session range boxes",      group=g1)
showMid  = input.bool(true, "Midnight open line",            group=g1)

g2 = "💧 Liquidity pools"
useSess = input.bool(true, "Asia & London highs / lows", group=g2)
usePD   = input.bool(true, "Previous day high / low",    group=g2)
usePW   = input.bool(true, "Previous week high / low",   group=g2)
useEQ   = input.bool(true, "Equal highs / lows",         group=g2)
eqTol   = input.float(0.1, "Equal-level tolerance (× ATR)", step=0.05, group=g2)
reclaimBars = input.int(3, "Raid must reclaim within N bars (0 = same candle)", minval=0, group=g2)

g3 = "🏗 Structure"
pivLen   = input.int(3, "Swing pivot length", minval=1,                group=g3)
showMS   = input.bool(true, "Show BOS / CHoCH",                        group=g3)
dispMult = input.float(0.5, "MSS displacement: body ≥ ATR ×", step=0.1, group=g3)
armBars  = input.int(30, "Max bars from raid to MSS", minval=1,        group=g3)
mssLook  = input.int(8, "MSS reference: raid-leg lookback (bars)", minval=2, group=g3)

g4 = "⬛ Fair value gaps"
showFVG     = input.bool(true, "Show FVGs",                  group=g4)
hideFilled  = input.bool(true, "Hide filled FVGs",           group=g4)
minFvgTicks = input.int(2, "Min FVG size (ticks)", minval=1, group=g4)

g5 = "🎯 Entry & risk"
entryMode  = input.string("CE (50%)", "FVG entry", options=["Edge", "CE (50%)"], group=g5)
fvgExpiry  = input.int(20, "Cancel unfilled order after N bars", minval=1,      group=g5)
slBufTicks = input.int(4, "Stop buffer beyond raid (ticks)", minval=0,          group=g5)
tpMode     = input.string("Opposite liquidity", "Target", options=["Fixed R", "Opposite liquidity"], group=g5)
rr         = input.float(2.0, "Fixed R / fallback R", step=0.25,                group=g5)
minRR      = input.float(1.5, "Min R for a liquidity target", step=0.25,        group=g5)
maxTrades  = input.int(2, "Max trades per day", minval=1,                       group=g5)

g6 = "🧭 Bias"
biasMode = input.string("Off", "HTF bias filter", options=["Off", "4H EMA 50"], group=g6)

g7 = "🎨 Style"
bullCol  = input.color(#00E676, "Bullish",   group=g7)
bearCol  = input.color(#FF1744, "Bearish",   group=g7)
liqCol   = input.color(#FFC400, "Liquidity", group=g7)
asiaCol  = input.color(#7C4DFF, "Asia",      group=g7)
lonCol   = input.color(#2979FF, "London",    group=g7)
nyCol    = input.color(#FFAB00, "NY AM",     group=g7)
showDash = input.bool(true, "Dashboard",     group=g7)

// ═════════════════════════════ CORE ═════════════════════════════════════════
inS(string s) => not na(time(timeframe.period, s, tz))

inAsia = inS(asiaSess)
inLon  = inS(lonSess)
inNY   = inS(nySess)
inFlat = inS(flatSess)
tick   = syminfo.mintick
atrV   = ta.atr(14)
clear  = color.new(color.black, 100)

// ═════════════════════════ LIQUIDITY POOLS ══════════════════════════════════
type Pool
    float  price
    bool   isHigh
    string name
    int    created
    int    tStart
    bool   done = false
    line   ln
    label  lb
    bool   pend = false
    int    brk
    float  ext

var array<Pool> pools = array.new<Pool>()

addPool(float px, bool isHigh, string nm, int x1) =>
    if not na(px) and not na(x1)
        ln = line.new(x1, px, bar_index, px, color=liqCol, width=1)
        lb = label.new(bar_index, px, nm, style=label.style_label_left, color=clear, textcolor=liqCol, size=size.tiny)
        pools.push(Pool.new(price=px, isHigh=isHigh, name=nm, created=bar_index, tStart=time, done=false, ln=ln, lb=lb))
        if pools.size() > 80
            old = pools.shift()
            old.ln.delete()
            old.lb.delete()

// Session range tracker (+ live range box)
sessRange(bool on, color c, string nm, bool show) =>
    var float h  = na
    var float l  = na
    var int   hb = na
    var int   lb = na
    var box   bx = na
    if on and not on[1]
        h  := high
        l  := low
        hb := bar_index
        lb := bar_index
        if show
            bx := box.new(bar_index, high, bar_index, low, border_color=color.new(c, 55), bgcolor=color.new(c, 90),
                 text=nm, text_size=size.tiny, text_color=color.new(c, 15), text_halign=text.align_left, text_valign=text.align_top)
    else if on
        if high > h
            h  := high
            hb := bar_index
        if low < l
            l  := low
            lb := bar_index
        if show and not na(bx)
            bx.set_top(h)
            bx.set_bottom(l)
            bx.set_right(bar_index)
    [h, l, hb, lb, not on and on[1]]

[asH, asL, asHb, asLb, asEnd] = sessRange(inAsia, asiaCol, "ASIA",   showKZ)
[ldH, ldL, ldHb, ldLb, ldEnd] = sessRange(inLon,  lonCol,  "LONDON", showKZ)
[nyH, nyL, nyHb, nyLb, nyEnd] = sessRange(inNY,   nyCol,   "NY AM",  showKZ)

if useSess and asEnd
    addPool(asH, true,  "ASIA H", asHb)
    addPool(asL, false, "ASIA L", asLb)
if useSess and ldEnd
    addPool(ldH, true,  "LDN H", ldHb)
    addPool(ldL, false, "LDN L", ldLb)

pdh = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_on)
pdl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_on)
pwh = request.security(syminfo.tickerid, "W", high[1], lookahead=barmerge.lookahead_on)
pwl = request.security(syminfo.tickerid, "W", low[1],  lookahead=barmerge.lookahead_on)

if usePD and timeframe.change("D")
    addPool(pdh, true,  "PDH", bar_index)
    addPool(pdl, false, "PDL", bar_index)
if usePW and timeframe.change("W")
    addPool(pwh, true,  "PWH", bar_index)
    addPool(pwl, false, "PWL", bar_index)

// Midnight open
isMid = hour(time, tz) == 0 and minute(time, tz) == 0
var line midLn = na
if showMid and isMid
    midLn := line.new(bar_index, open, bar_index + 1, open, color=color.new(color.gray, 20), style=line.style_dotted)
    label.new(bar_index, open, "00:00 OPEN", style=label.style_label_right, color=clear, textcolor=color.new(color.gray, 10), size=size.tiny)
else if showMid and not na(midLn)
    midLn.set_x2(bar_index)

// ═════════════════════════ MARKET STRUCTURE ═════════════════════════════════
ph = ta.pivothigh(high, pivLen, pivLen)
pl = ta.pivotlow(low, pivLen, pivLen)

var float swH   = na
var int   swHb  = na
var bool  swHx  = true
var float swL   = na
var int   swLb  = na
var bool  swLx  = true
var int   trend = 0

if not na(ph)
    pb = bar_index - pivLen
    if useEQ and not swHx and not na(swH) and math.abs(ph - swH) <= eqTol * atrV
        addPool(math.max(ph, swH), true, "EQH", swHb)
    swH  := ph
    swHb := pb
    swHx := false

if not na(pl)
    pb = bar_index - pivLen
    if useEQ and not swLx and not na(swL) and math.abs(pl - swL) <= eqTol * atrV
        addPool(math.min(pl, swL), false, "EQL", swLb)
    swL  := pl
    swLb := pb
    swLx := false

if not swHx and close > swH
    swHx := true
    tagU = trend < 0 ? "CHoCH" : "BOS"
    trend := 1
    if showMS
        line.new(swHb, swH, bar_index, swH, color=color.new(bullCol, 30), style=line.style_dotted)
        label.new(int((swHb + bar_index) / 2), swH, tagU, style=label.style_label_down, color=clear, textcolor=bullCol, size=size.tiny)

if not swLx and close < swL
    swLx := true
    tagD = trend > 0 ? "CHoCH" : "BOS"
    trend := -1
    if showMS
        line.new(swLb, swL, bar_index, swL, color=color.new(bearCol, 30), style=line.style_dotted)
        label.new(int((swLb + bar_index) / 2), swL, tagD, style=label.style_label_up, color=clear, textcolor=bearCol, size=size.tiny)

// ═════════════════════════ FAIR VALUE GAPS ══════════════════════════════════
bullFVG = low > high[2] and (low - high[2]) >= minFvgTicks * tick
bearFVG = high < low[2] and (low[2] - high) >= minFvgTicks * tick

type Gap
    float top
    float bot
    bool  bull
    box   bx
    bool  done = false

var array<Gap> gaps = array.new<Gap>()

if showFVG and bullFVG
    bxU = box.new(bar_index - 2, low, bar_index + 3, high[2], border_color=color.new(bullCol, 75), bgcolor=color.new(bullCol, 88),
         text="FVG", text_size=size.tiny, text_color=color.new(bullCol, 30), text_halign=text.align_right)
    gaps.push(Gap.new(top=low, bot=high[2], bull=true, bx=bxU, done=false))
if showFVG and bearFVG
    bxD = box.new(bar_index - 2, low[2], bar_index + 3, high, border_color=color.new(bearCol, 75), bgcolor=color.new(bearCol, 88),
         text="FVG", text_size=size.tiny, text_color=color.new(bearCol, 30), text_halign=text.align_right)
    gaps.push(Gap.new(top=low[2], bot=high, bull=false, bx=bxD, done=false))
if gaps.size() > 50
    oldG = gaps.shift()
    oldG.bx.delete()

for g in gaps
    if not g.done
        filled = g.bull ? low <= g.bot : high >= g.top
        if filled
            g.done := true
            if hideFilled
                g.bx.delete()
            else
                gc = g.bull ? bullCol : bearCol
                g.bx.set_right(bar_index)
                g.bx.set_bgcolor(color.new(gc, 95))
                g.bx.set_border_color(color.new(gc, 90))
                g.bx.set_text("")
        else
            g.bx.set_right(bar_index + 3)

// ═════════════════════════ RAID DETECTION ═══════════════════════════════════
// A raid = price trades through a pool, then closes back inside within `reclaimBars`.
// No reclaim in time = the level was simply TAKEN (breakout), not raided.
bool   bslRaid = false
bool   sslRaid = false
string raidNm  = ""
float  raidExt = na
var string lastRaid = "—"

for p in pools
    if not p.done
        inside = p.isHigh ? close < p.price : close > p.price
        bool fire = false
        bool kill = false
        if p.pend
            p.ext := p.isHigh ? math.max(p.ext, high) : math.min(p.ext, low)
            if inside
                fire := true
            else if bar_index - p.brk >= reclaimBars
                kill := true
        else if time - p.tStart > 3 * 86400000
            p.done := true
            p.ln.set_style(line.style_dotted)
            p.ln.set_color(color.new(liqCol, 80))
            p.lb.delete()
        else if bar_index > p.created and (p.isHigh ? high > p.price : low < p.price)
            p.ext := p.isHigh ? high : low
            p.brk := bar_index
            if inside
                fire := true
            else if reclaimBars == 0
                kill := true
            else
                p.pend := true
        if fire or kill
            p.done := true
            p.pend := false
            p.ln.set_x2(bar_index)
            p.ln.set_style(line.style_dashed)
            p.ln.set_color(color.new(liqCol, 55))
            p.lb.set_x(bar_index)
            p.lb.set_text(p.name + (fire ? "  ✕ RAIDED" : "  ✓ TAKEN"))
            p.lb.set_textcolor(color.new(liqCol, fire ? 0 : 50))
            if fire
                lastRaid := p.name + " · " + str.format_time(time, "HH:mm", tz)
                if inNY
                    if p.isHigh
                        bslRaid := true
                        raidExt := na(raidExt) ? p.ext : math.max(raidExt, p.ext)
                    else
                        sslRaid := true
                        raidExt := na(raidExt) ? p.ext : math.min(raidExt, p.ext)
                    raidNm := p.name
        else if not p.done
            p.ln.set_x2(bar_index)
            p.lb.set_x(bar_index)

// MSS reference = the low/high of the leg that made the raid (closest of leg vs last swing)
legLow  = ta.lowest(low, mssLook)[1]
legHigh = ta.highest(high, mssLook)[1]

// ═════════════════════════ BIAS ═════════════════════════════════════════════
htfC = request.security(syminfo.tickerid, "240", close[1], lookahead=barmerge.lookahead_on)
htfE = request.security(syminfo.tickerid, "240", ta.ema(close, 50)[1], lookahead=barmerge.lookahead_on)
htfBull    = htfC > htfE
allowLong  = biasMode == "Off" or htfBull
allowShort = biasMode == "Off" or not htfBull

// ═════════════════════════ TARGETS ══════════════════════════════════════════
// Nearest untouched opposite pool that pays ≥ minRR, else fixed R
tgtFor(float e, float r, bool isLong) =>
    float best = na
    for p in pools
        if not p.done and p.isHigh == isLong
            d = isLong ? p.price - e : e - p.price
            if d > 0 and d / r >= minRR
                best := na(best) ? p.price : isLong ? math.min(best, p.price) : math.max(best, p.price)
    na(best) ? (isLong ? e + rr * r : e - rr * r) : best

// ═════════════════════════ SETUP STATE ══════════════════════════════════════
// 0 scanning · 1 raided, waiting MSS · 2 MSS, waiting FVG · 3 limit working
var int   sState = 0
var float sExt   = na
var int   sBar   = na
var float sBos   = na
var float sTop   = na
var float sBot   = na
var int   sFvgB  = na
var int   sBosB  = na
var int   sOrdB  = na
var float sStop  = na
var float sTp    = na
var float sEntry = na
var line  sLimLn = na
var label sLimLb = na

var int   lState = 0
var float lExt   = na
var int   lBar   = na
var float lBos   = na
var float lTop   = na
var float lBot   = na
var int   lFvgB  = na
var int   lBosB  = na
var int   lOrdB  = na
var float lStop  = na
var float lTp    = na
var float lEntry = na
var line  lLimLn = na
var label lLimLb = na

// Setup funnel counters (raid → MSS → order)
var int nRaid = 0
var int nMss  = 0
var int nOrd  = 0

// ═════════════════════════ SIGNAL ENGINE ════════════════════════════════════
// Simulates each signal bar-by-bar: limit fill → stop / target / EOD flat.
// Same-bar stop & target hit is scored as a loss (conservative).
var int tradesToday = 0
if inNY and not inNY[1]
    tradesToday := 0

var int   pos   = 0
var float posE  = na
var float posS  = na
var float posT  = na
var int   posB  = na
var box   tpBox = na
var box   slBox = na
var int   nFill = 0
var int   nWin  = 0
var int   nLoss = 0
var float sumR  = 0.0

drawTrade(bool isL, float ep, float st, float tg) =>
    sigC = isL ? bullCol : bearCol
    label.new(bar_index, isL ? low : high, (isL ? "▲ BUY" : "▼ SELL") + "\n" + str.tostring(ep, format.mintick),
         style=isL ? label.style_label_up : label.style_label_down, color=sigC, textcolor=color.black, size=size.normal)
    t = box.new(bar_index, math.max(tg, ep), bar_index + 1, math.min(tg, ep), border_color=color.new(bullCol, 55), bgcolor=color.new(bullCol, 82),
         text="TARGET", text_size=size.tiny, text_color=color.new(bullCol, 10), text_halign=text.align_right)
    b = box.new(bar_index, math.max(st, ep), bar_index + 1, math.min(st, ep), border_color=color.new(bearCol, 55), bgcolor=color.new(bearCol, 82),
         text="STOP", text_size=size.tiny, text_color=color.new(bearCol, 10), text_halign=text.align_right)
    [t, b]

// Exits for an open signal
if pos != 0 and bar_index > posB
    hitS = pos == 1 ? low <= posS : high >= posS
    hitT = pos == 1 ? high >= posT : low <= posT
    if hitS or hitT or inFlat
        xp  = hitS ? posS : hitT ? posT : close
        rsk = math.abs(posE - posS)
        rM  = rsk > 0 ? (xp - posE) * pos / rsk : 0.0
        win = rM > 0
        if win
            nWin += 1
        else
            nLoss += 1
        sumR += rM
        tpBox.set_right(bar_index)
        slBox.set_right(bar_index)
        label.new(bar_index, xp, (win ? "✔ +" : "✖ ") + str.tostring(rM, "#.##") + "R", style=label.style_label_left,
             color=clear, textcolor=win ? bullCol : bearCol, size=size.small)
        alert("ART Raid: " + (pos == 1 ? "BUY" : "SELL") + " closed " + str.tostring(rM, "#.##") + "R", alert.freq_once_per_bar_close)
        pos := 0
    else
        tpBox.set_right(bar_index + 1)
        slBox.set_right(bar_index + 1)

// ═════════════════════════ SHORT SETUP ══════════════════════════════════════
if bslRaid and sState <= 1 and allowShort and not na(legLow)
    sState := 1
    nRaid  += 1
    sExt   := na(raidExt) ? high : math.max(raidExt, high)
    sBar   := bar_index
    sBos   := na(swL) ? legLow : math.max(swL, legLow)
    sTop   := na
    sBot   := na
    label.new(bar_index, high, "⚡ RAID\n" + raidNm, style=label.style_label_down, color=color.new(bearCol, 25), textcolor=color.white, size=size.small)
    alert("ART Raid: buy-side raided (" + raidNm + ") — watching for bearish MSS", alert.freq_once_per_bar_close)

if sState == 1 or sState == 2
    sExt := math.max(sExt, high)
    if bearFVG and bar_index - 2 >= sBar
        sTop  := low[2]
        sBot  := high
        sFvgB := bar_index - 2

if sState == 1
    if bar_index - sBar > armBars
        sState := 0
    else if close < sBos and close < open and math.abs(close - open) >= atrV * dispMult
        sState := 2
        nMss   += 1
        sBosB  := bar_index
        line.new(sBar, sBos, bar_index, sBos, color=bearCol, width=2, style=line.style_dashed)
        label.new(bar_index, sBos, "MSS", style=label.style_label_up, color=bearCol, textcolor=color.white, size=size.tiny)

if sState == 2
    if not na(sTop)
        eS  = entryMode == "Edge" ? sBot : (sTop + sBot) / 2
        stS = sExt + slBufTicks * tick
        rS  = stS - eS
        if rS > 0 and tradesToday < maxTrades and pos == 0
            sStop  := stS
            sTp    := tpMode == "Fixed R" ? eS - rr * rS : tgtFor(eS, rS, false)
            sEntry := eS
            sState := 3
            nOrd   += 1
            sOrdB  := bar_index
            box.new(sFvgB, sTop, bar_index + fvgExpiry, sBot, border_color=bearCol, border_width=2, bgcolor=color.new(bearCol, 75),
                 text="ENTRY ZONE", text_size=size.tiny, text_color=color.white, text_halign=text.align_left)
            sLimLn := line.new(bar_index, eS, bar_index + 3, eS, color=bearCol, style=line.style_dashed)
            sLimLb := label.new(bar_index + 3, eS, "SELL LIMIT " + str.tostring(eS, format.mintick), style=label.style_label_left,
                 color=clear, textcolor=bearCol, size=size.tiny)
            alert("ART Raid: SELL limit " + str.tostring(eS, format.mintick) + " | SL " + str.tostring(sStop, format.mintick) +
                 " | TP " + str.tostring(sTp, format.mintick), alert.freq_once_per_bar_close)
        else
            sState := 0
    else if bar_index - sBosB > 3
        sState := 0

if sState == 3
    if pos == 0 and bar_index > sOrdB and high >= sEntry
        pos   := -1
        posE  := sEntry
        posS  := sStop
        posT  := sTp
        posB  := bar_index
        nFill += 1
        tradesToday += 1
        [t, b] = drawTrade(false, posE, posS, posT)
        tpBox := t
        slBox := b
        alert("ART Raid: SELL filled @ " + str.tostring(posE, format.mintick), alert.freq_once_per_bar_close)
        sState := 0
    else if bar_index - sOrdB > fvgExpiry or close > sStop or not inNY or pos != 0
        sState := 0

if sState != 3 and not na(sLimLn)
    sLimLn.delete()
    sLimLb.delete()
    sLimLn := na
    sLimLb := na
else if sState == 3 and not na(sLimLn)
    sLimLn.set_x2(bar_index + 3)
    sLimLb.set_x(bar_index + 3)

// ═════════════════════════ LONG SETUP ═══════════════════════════════════════
if sslRaid and lState <= 1 and allowLong and not na(legHigh)
    lState := 1
    nRaid  += 1
    lExt   := na(raidExt) ? low : math.min(raidExt, low)
    lBar   := bar_index
    lBos   := na(swH) ? legHigh : math.min(swH, legHigh)
    lTop   := na
    lBot   := na
    label.new(bar_index, low, "⚡ RAID\n" + raidNm, style=label.style_label_up, color=color.new(bullCol, 25), textcolor=color.black, size=size.small)
    alert("ART Raid: sell-side raided (" + raidNm + ") — watching for bullish MSS", alert.freq_once_per_bar_close)

if lState == 1 or lState == 2
    lExt := math.min(lExt, low)
    if bullFVG and bar_index - 2 >= lBar
        lTop  := low
        lBot  := high[2]
        lFvgB := bar_index - 2

if lState == 1
    if bar_index - lBar > armBars
        lState := 0
    else if close > lBos and close > open and math.abs(close - open) >= atrV * dispMult
        lState := 2
        nMss   += 1
        lBosB  := bar_index
        line.new(lBar, lBos, bar_index, lBos, color=bullCol, width=2, style=line.style_dashed)
        label.new(bar_index, lBos, "MSS", style=label.style_label_down, color=bullCol, textcolor=color.black, size=size.tiny)

if lState == 2
    if not na(lTop)
        eL  = entryMode == "Edge" ? lTop : (lTop + lBot) / 2
        stL = lExt - slBufTicks * tick
        rL  = eL - stL
        if rL > 0 and tradesToday < maxTrades and pos == 0
            lStop  := stL
            lTp    := tpMode == "Fixed R" ? eL + rr * rL : tgtFor(eL, rL, true)
            lEntry := eL
            lState := 3
            nOrd   += 1
            lOrdB  := bar_index
            box.new(lFvgB, lTop, bar_index + fvgExpiry, lBot, border_color=bullCol, border_width=2, bgcolor=color.new(bullCol, 75),
                 text="ENTRY ZONE", text_size=size.tiny, text_color=color.white, text_halign=text.align_left)
            lLimLn := line.new(bar_index, eL, bar_index + 3, eL, color=bullCol, style=line.style_dashed)
            lLimLb := label.new(bar_index + 3, eL, "BUY LIMIT " + str.tostring(eL, format.mintick), style=label.style_label_left,
                 color=clear, textcolor=bullCol, size=size.tiny)
            alert("ART Raid: BUY limit " + str.tostring(eL, format.mintick) + " | SL " + str.tostring(lStop, format.mintick) +
                 " | TP " + str.tostring(lTp, format.mintick), alert.freq_once_per_bar_close)
        else
            lState := 0
    else if bar_index - lBosB > 3
        lState := 0

if lState == 3
    if pos == 0 and bar_index > lOrdB and low <= lEntry
        pos   := 1
        posE  := lEntry
        posS  := lStop
        posT  := lTp
        posB  := bar_index
        nFill += 1
        tradesToday += 1
        [t, b] = drawTrade(true, posE, posS, posT)
        tpBox := t
        slBox := b
        alert("ART Raid: BUY filled @ " + str.tostring(posE, format.mintick), alert.freq_once_per_bar_close)
        lState := 0
    else if bar_index - lOrdB > fvgExpiry or close < lStop or not inNY or pos != 0
        lState := 0

if lState != 3 and not na(lLimLn)
    lLimLn.delete()
    lLimLb.delete()
    lLimLn := na
    lLimLb := na
else if lState == 3 and not na(lLimLn)
    lLimLn.set_x2(bar_index + 3)
    lLimLb.set_x(bar_index + 3)

// ═════════════════════════ HOUSEKEEPING ═════════════════════════════════════
if not inNY
    if sState == 1 or sState == 2
        sState := 0
    if lState == 1 or lState == 2
        lState := 0

// ═════════════════════════ DASHBOARD ════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 10, bgcolor=color.new(#0B0F17, 8), border_color=color.new(#262B36, 0),
     border_width=1, frame_color=color.new(liqCol, 30), frame_width=1)

dRow(int r, string k, string v, color vc) =>
    table.cell(dash, 0, r, k, text_color=color.new(color.white, 40), text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, r, v, text_color=vc, text_size=size.small, text_halign=text.align_right)

stTxt(int s, string side) =>
    s == 1 ? "Raid → waiting MSS" : s == 2 ? "MSS → waiting FVG" : side + " limit working"

if showDash and barstate.isfirst
    table.merge_cells(dash, 0, 0, 1, 0)

if showDash and barstate.islast
    table.cell(dash, 0, 0, "ARTILLERY · RAID MODEL", text_color=color.black, bgcolor=liqCol, text_size=size.small)
    dRow(1, "4H bias",   htfBull ? "Bullish ▲" : "Bearish ▼", htfBull ? bullCol : bearCol)
    dRow(2, "Structure", trend > 0 ? "Bullish ▲" : trend < 0 ? "Bearish ▼" : "—", trend > 0 ? bullCol : trend < 0 ? bearCol : color.gray)
    sessTxt = inAsia ? "Asia" : inLon ? "London" : inNY ? "NY AM ● LIVE" : "Off-window"
    dRow(3, "Session",   sessTxt, inNY ? nyCol : inLon ? lonCol : inAsia ? asiaCol : color.gray)
    dRow(4, "Last raid", lastRaid, liqCol)
    setupTxt = sState != 0 ? stTxt(sState, "SELL") : lState != 0 ? stTxt(lState, "BUY") : "Scanning…"
    dRow(5, "Setup",     setupTxt, sState != 0 ? bearCol : lState != 0 ? bullCol : color.white)
    dRow(6, "Trades today", str.tostring(tradesToday) + " / " + str.tostring(maxTrades), color.white)
    nDone = nWin + nLoss
    wr = nDone > 0 ? nWin * 100.0 / nDone : 0.0
    dRow(7, "Win rate",  str.tostring(wr, "#.#") + "%  (" + str.tostring(nDone) + " signals)", wr >= 50 ? bullCol : bearCol)
    dRow(8, "Net",       (sumR >= 0 ? "+" : "") + str.tostring(sumR, "#.##") + "R", sumR >= 0 ? bullCol : bearCol)
    dRow(9, "Funnel",    str.tostring(nRaid) + " raids › " + str.tostring(nMss) + " MSS › " + str.tostring(nOrd) + " orders › " +
         str.tostring(nFill) + " fills", color.new(color.white, 20))
````
