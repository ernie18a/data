# Trend Breath

- url: https://www.tradingview.com/script/suf743J1-Trend-Breath/
- type: indicator
- pine_id: PUB;554a1d9bbf934096bd5c6b00d8fc69a6
- version: 1.0

## Description

[b]OVERVIEW[/b]

Trend Breath first decides whether a trend is really there, using five independent checks. Inside a qualifying trend it reports the bar on which a pullback has ended and price has confirmed the trend's direction again. A rarer second event reports a confirmed reversal after price sat at an extreme for a long stretch while the trend was weak. Every report carries a stop and two targets drawn as reference lines.


[b]HOW IT WORKS[/b]

The indicator scores a trend on five checks: the slope of a long trend line, how long price has stayed on one side of it, a directional-strength reading, the direction of a line on a higher timeframe, and a slow range reading. At least three of five, with price on the right side of the line, qualify a trend. Inside it, a fast range reading measures where the close sits in a short window. When that reading leaves its far zone against the trend, a pullback is considered ended if a candle of the trend's colour closes within a couple of bars, unless a large recent counter-candle blocks that side. The same fast reading must have been back in its far zone before the next pullback can be reported. The rarer reversal needs both the fast and the slow reading to stay at an extreme for a minimum stretch, then leave it while trend strength is low, and price must close beyond the extreme bar's far edge within a few bars. Each side waits after a report, and a report on one side locks the other for a short while. Every report draws a stop beyond the latest swing and two targets as multiples of the stop distance, sized from the recent range.


[image]xDwSltLE[/image]
[i]The trend line and a pullback marker on a 1h Bitcoin chart. The marker sits on the bar where a pullback ended and price confirmed the direction.[/i]


[b]WHAT YOU'LL SEE ON THE CHART[/b]

[list]
[*][b]Pullback markers[/b] — a filled L or S label on the bar where a pullback has ended: below the bar for an up-trend, above the bar for a down-trend. State-change markers, not instructions.
[*][b]Trend line[/b] — a line coloured by the trend state: bullish, bearish, or grey when no trend qualifies.
[*][b]Reversal triangles[/b] — optional small triangles on the bars of the rarer exhaustion reversal. Off by default.
[*][b]Reference lines[/b] — four short lines drawn from the report bar: the stop, the close and two targets. Only the newest set is kept by default, and the stop line can move to the close when the first target is touched.
[/list]

[image]IVPjFo2T[/image]
[i]The same indicator on a 2h Bitcoin chart. The trend line colour shows the trend state, and markers are rare.[/i]


[b]WHERE IT FITS[/b]

Trend Breath reports only a handful of pullback ends per stretch of history, so no single market or timeframe is singled out. It was built around hourly charts. Expect long quiet stretches, and give it a long stretch of history.


[b]ALERTS[/b]

[list]
[*]Pullback ended ↑
[*]Pullback ended ↓
[*]Exhaustion reversal ↑
[*]Exhaustion reversal ↓
[*]First target reached
[/list]


[b]OPEN SOURCE[/b]

The source code is open and published under the Mozilla Public License 2.0, so it can be read, checked and reused under those terms.


[b]ACCESS[/b]

Free, open-source script.


[b]DISCLAIMER[/b]

[i]This indicator is a technical analysis tool, not investment advice. The author is not a registered investment adviser, broker or dealer. Nothing here is a recommendation to buy, sell or hold any instrument. What you see on the chart is the output of a calculation you configured. Any decision you take from it is yours. Past behaviour of an indicator — including anything you observe in historical bars or in a backtest, which is a simulation — does not indicate future results. Trading carries a real risk of loss, including your entire capital. Charting uses TradingView® technology. TradingView is unaffiliated with the author. For educational purposes only. Not investment advice.[/i]

## Source Code

````pine
//@version=6
indicator("Trend Breath", shorttitle="T-Breath", overlay=true, behind_chart=false, max_bars_back=300, max_lines_count=500)
C_UP       = #26A69A
C_DOWN     = #EF5350
C_NEUTRAL  = #787B86
C_TEXT     = #D1D4DC
G_CORE   = "◆━━━━━━━ Calculation ━━━━━━━◆"
G_FILTER = "◆━━━━━━━ Filters ━━━━━━━◆"
G_VISUAL = "◆━━━━━━━ Appearance ━━━━━━━◆"
G_ALERT  = "◆━━━━━━━ Alerts ━━━━━━━◆"
A_PB_UP    = "Pullback ended ↑"
A_PB_DOWN  = "Pullback ended ↓"
A_REV_UP   = "Exhaustion reversal ↑"
A_REV_DOWN = "Exhaustion reversal ↓"
A_T1       = "First target reached"
i_useHA = input.bool(false, "Use Heikin Ashi Candles", group = G_CORE,
     tooltip = "Feeds the whole engine with Heikin Ashi candles instead of regular ones, whatever candle type the chart itself shows. The trend line, the stop and the targets then sit at smoothed prices, not traded ones.")
i_trackUp   = input.bool(true, "Track Upside", group = G_FILTER,
     tooltip = "Reports upside events: a pullback ending inside an up-trend, and an upward reversal after exhaustion. Off, the upside is not evaluated at all and places no lock on the other side.")
i_trackDown = input.bool(true, "Track Downside", group = G_FILTER,
     tooltip = "Reports downside events: a pullback ending inside a down-trend, and a downward reversal after exhaustion. Off, the downside is not evaluated at all and places no lock on the other side.")
i_showMarkers   = input.bool(true, "Show Signal Markers", group = G_VISUAL,
     tooltip = "Draws the L / S label on the bar where a pullback inside the trend has ended.")
i_showSecondary = input.bool(false, "Show Secondary Events", group = G_VISUAL,
     tooltip = "Draws a small triangle on the bar of an exhaustion reversal — the rarer second event. Its stop and targets are drawn either way.")
i_showTrend     = input.bool(true, "Show Trend Line", group = G_VISUAL,
     tooltip = "Draws the trend line, coloured by the trend state: bullish, bearish, or grey when no trend qualifies.")
i_levels        = input.string("Last Signal", "Show Levels", group = G_VISUAL,
     options = ["Last Signal", "All", "Off"],
     tooltip = "Draws the stop, the reference price and the two targets of a report as short lines. Last Signal keeps only the newest set; All keeps every set until the chart's line limit.")
i_moveStop      = input.bool(true, "Move Stop Line on First Target", group = G_VISUAL,
     tooltip = "When the first target is touched, the stop line of the newest report is redrawn at the reference price. Visual only — Last Signal mode.")
i_colUp         = input.color(C_UP, "Bullish Color", group = G_VISUAL)
i_colDown       = input.color(C_DOWN, "Bearish Color", group = G_VISUAL)
i_alertOn = input.string("Bar Close", "Alert On", group = G_ALERT,
     options = ["Bar Close", "Intrabar"],
     tooltip = "Bar Close waits for the bar to finish and cannot change afterwards. Intrabar fires earlier and can revert before the bar closes.")
TREND_LEN     = 211
MIN_SCORE     = 3
SLOPE_BARS    = 30
MIN_SLOPE     = 1.3
PERSIST_BARS  = 21
ADX_TREND_MIN = 8.0
DMI_LEN       = 14
HTF_TF        = "240"
HTF_LEN       = 50
SHOCK_ATR     = 1.4
SHOCK_BARS    = 21
PB_CONF_BARS  = 2
FAST_LEN      = 11
FAST_SM       = 8
SLOW_LEN      = 58
SLOW_SM       = 7
PB_THR        = 20
EX_THR        = 7
MIN_ZONE      = 5
CONFIRM_BARS  = 3
ADX_MAX       = 28.0
COOLDOWN      = 11
OPP_LOCK      = 11
ATR_LEN       = 16
SWING_LEN     = 2
SL_ATR        = 0.3
MIN_STOP_ATR  = 1.5
RR1           = 1.0
RR2           = 2.0
LEVEL_LEN     = 9
srcTicker = i_useHA ? ticker.heikinashi(syminfo.tickerid) : syminfo.tickerid
[cO, cH, cL, cC] = request.security(srcTicker, timeframe.period, [open, high, low, close], lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
tr  = math.max(cH - cL, math.abs(cH - cC[1]), math.abs(cL - cC[1]))
atr = ta.rma(tr, ATR_LEN)
f_dmi(float h, float l, float trv, simple int len) =>
    float up   = h - h[1]
    float dn   = l[1] - l
    float pDM  = na(up) ? na : (up > dn and up > 0 ? up : 0.0)
    float mDM  = na(dn) ? na : (dn > up and dn > 0 ? dn : 0.0)
    float trur = ta.rma(trv, len)
    float plus = fixnan(100 * ta.rma(pDM, len) / trur)
    float minus = fixnan(100 * ta.rma(mDM, len) / trur)
    float sum  = plus + minus
    float adxv = 100 * ta.rma(math.abs(plus - minus) / (sum == 0 ? 1 : sum), len)
    [plus, minus, adxv]
[diP, diM, adx] = f_dmi(cH, cL, tr, DMI_LEN)
f_htfPack() =>
    int   o = barstate.isrealtime ? 1 : 0
    float e = ta.ema(close, HTF_LEN)
    [e[o], e[o + 1], close[o]]
[htfEmaRaw, htfEmaPrevRaw, htfCloseRaw] = request.security(srcTicker, HTF_TF, f_htfPack(), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
int   htfOff    = barstate.isrealtime ? 0 : 1
float htfEma     = htfEmaRaw[htfOff]
float htfEmaPrev = htfEmaPrevRaw[htfOff]
float htfClose   = htfCloseRaw[htfOff]
f_pr(simple int len) =>
    float hh = ta.highest(cH, len)
    float ll = ta.lowest(cL, len)
    hh == ll ? -50.0 : 100.0 * (cC - hh) / (hh - ll)
fastR = ta.ema(f_pr(FAST_LEN), FAST_SM)
slowR = ta.ema(f_pr(SLOW_LEN), SLOW_SM)
emaT = ta.ema(cC, TREND_LEN)
swLo = ta.lowest(cL, SWING_LEN)
swHi = ta.highest(cH, SWING_LEN)
bearBody = math.max(cO - cC, 0)
bullBody = math.max(cC - cO, 0)
shockBlocksL = ta.highest(bearBody, SHOCK_BARS) >= SHOCK_ATR * atr
shockBlocksS = ta.highest(bullBody, SHOCK_BARS) >= SHOCK_ATR * atr
confL = cC > cO
confS = cC < cO
confirmed = i_alertOn == "Bar Close" ? barstate.isconfirmed : true
sideUp = cC > emaT
sideDn = cC < emaT
var int s_upBars = 0
var int s_dnBars = 0
s_upBars := sideUp ? s_upBars + 1 : 0
s_dnBars := sideDn ? s_dnBars + 1 : 0
slopeAtr = atr > 0 ? (emaT - emaT[SLOPE_BARS]) / atr : 0.0
upScore = (slopeAtr >= MIN_SLOPE ? 1 : 0) + (s_upBars >= PERSIST_BARS ? 1 : 0) + (adx >= ADX_TREND_MIN and diP > diM ? 1 : 0) + (htfClose > htfEma and htfEma > htfEmaPrev ? 1 : 0) + (slowR > -50 ? 1 : 0)
dnScore = (slopeAtr <= -MIN_SLOPE ? 1 : 0) + (s_dnBars >= PERSIST_BARS ? 1 : 0) + (adx >= ADX_TREND_MIN and diM > diP ? 1 : 0) + (htfClose < htfEma and htfEma < htfEmaPrev ? 1 : 0) + (slowR < -50 ? 1 : 0)
upTrend = sideUp and upScore >= MIN_SCORE
dnTrend = sideDn and dnScore >= MIN_SCORE
fastOutOfOS = ta.crossover(fastR, -100 + PB_THR)
fastOutOfOB = ta.crossunder(fastR, -PB_THR)
var bool s_armL = true
var bool s_armS = true
if fastR >= -PB_THR
    s_armL := true
if fastR <= -100 + PB_THR
    s_armS := true
var bool s_pbPendL    = false
var int  s_pbPendLBar = na
var bool s_pbPendS    = false
var int  s_pbPendSBar = na
if fastOutOfOS and upTrend and s_armL
    s_pbPendL    := true
    s_pbPendLBar := bar_index
if fastOutOfOB and dnTrend and s_armS
    s_pbPendS    := true
    s_pbPendSBar := bar_index
bool pbLong  = false
bool pbShort = false
if s_pbPendL
    if bar_index - s_pbPendLBar > PB_CONF_BARS or not upTrend or fastR <= -100 + PB_THR
        s_pbPendL := false
    else if confL and not shockBlocksL
        pbLong    := true
        s_pbPendL := false
if s_pbPendS
    if bar_index - s_pbPendSBar > PB_CONF_BARS or not dnTrend or fastR >= -PB_THR
        s_pbPendS := false
    else if confS and not shockBlocksS
        pbShort   := true
        s_pbPendS := false
ob = fastR >= -EX_THR and slowR >= -EX_THR
os = fastR <= -100 + EX_THR and slowR <= -100 + EX_THR
var int   s_obCnt = 0
var int   s_osCnt = 0
var float s_obHi  = na
var float s_osLo  = na
s_obCnt := ob ? s_obCnt + 1 : 0
s_osCnt := os ? s_osCnt + 1 : 0
if ob
    s_obHi := s_obCnt == 1 ? cH : math.max(s_obHi, cH)
if os
    s_osLo := s_osCnt == 1 ? cL : math.min(s_osLo, cL)
obExit = not ob and ob[1]
osExit = not os and os[1]
adxOk  = adx < ADX_MAX
var bool  s_pendS    = false
var float s_trigS    = na
var float s_stopS    = na
var int   s_pendSBar = na
var bool  s_pendL    = false
var float s_trigL    = na
var float s_stopL    = na
var int   s_pendLBar = na
bool exShort = false
bool exLong  = false
if s_pendS
    if bar_index - s_pendSBar > CONFIRM_BARS or ob
        s_pendS := false
    else if cC < s_trigS and not shockBlocksS
        exShort := true
        s_pendS := false
if s_pendL
    if bar_index - s_pendLBar > CONFIRM_BARS or os
        s_pendL := false
    else if cC > s_trigL and not shockBlocksL
        exLong  := true
        s_pendL := false
if obExit and s_obCnt[1] >= MIN_ZONE and adxOk
    s_pendS    := true
    s_trigS    := cL
    s_stopS    := s_obHi
    s_pendSBar := bar_index
if osExit and s_osCnt[1] >= MIN_ZONE and adxOk
    s_pendL    := true
    s_trigL    := cH
    s_stopL    := s_osLo
    s_pendLBar := bar_index
var int s_lastL = na
var int s_lastS = na
okL = (na(s_lastL) or bar_index - s_lastL > COOLDOWN) and (na(s_lastS) or bar_index - s_lastS > OPP_LOCK)
okS = (na(s_lastS) or bar_index - s_lastS > COOLDOWN) and (na(s_lastL) or bar_index - s_lastL > OPP_LOCK)
bool longRaw  = (pbLong or exLong) and okL
bool shortRaw = (pbShort or exShort) and okS
if longRaw and shortRaw
    longRaw  := false
    shortRaw := false
longSig  = longRaw  and i_trackUp   and confirmed
shortSig = shortRaw and i_trackDown and confirmed
if longSig
    s_lastL := bar_index
    s_armL  := false
if shortSig
    s_lastS := bar_index
    s_armS  := false
longIsRev  = longSig  and not pbLong
shortIsRev = shortSig and not pbShort
float slL = na
float slS = na
if longSig
    float baseL = (longIsRev ? s_stopL : swLo) - atr * SL_ATR
    slL := math.min(baseL, cC - atr * MIN_STOP_ATR)
if shortSig
    float baseS = (shortIsRev ? s_stopS : swHi) + atr * SL_ATR
    slS := math.max(baseS, cC + atr * MIN_STOP_ATR)
var bool  s_open  = false
var bool  s_isUp  = true
var float s_entry = na
var float s_stop  = na
var float s_risk  = na
var bool  s_t1    = false
var int   s_bar   = na
bool  t1Event = false
bool  t1Up    = false
float t1Entry = na
float t1Tp2   = na
if s_open and bar_index > s_bar and confirmed
    float dir    = s_isUp ? 1.0 : -1.0
    float tp1    = s_entry + dir * s_risk * RR1
    float tp2    = s_entry + dir * s_risk * RR2
    bool  hitSL  = s_isUp ? cL <= s_stop  : cH >= s_stop
    bool  hitTp1 = s_isUp ? cH >= tp1     : cL <= tp1
    bool  hitTp2 = s_isUp ? cH >= tp2     : cL <= tp2
    bool  hitBE  = s_isUp ? cL <= s_entry : cH >= s_entry
    if not s_t1
        if hitSL
            s_open := false
        else if hitTp1
            s_t1    := true
            t1Event := true
            t1Up    := s_isUp
            t1Entry := s_entry
            t1Tp2   := tp2
            if hitTp2
                s_open := false
    else
        if hitBE or hitTp2
            s_open := false
if longSig or shortSig
    float s = longSig ? slL : slS
    float r = math.abs(cC - s)
    if r > 0
        s_open  := true
        s_isUp  := longSig
        s_entry := cC
        s_stop  := s
        s_risk  := r
        s_t1    := false
        s_bar   := bar_index
float tp1L = longSig  ? cC + (cC - slL) * RR1 : na
float tp2L = longSig  ? cC + (cC - slL) * RR2 : na
float tp1S = shortSig ? cC - (slS - cC) * RR1 : na
float tp2S = shortSig ? cC - (slS - cC) * RR2 : na
emaCol = upTrend ? color.new(i_colUp, 30) : dnTrend ? color.new(i_colDown, 30) : color.new(C_NEUTRAL, 60)
p_trend = plot(i_showTrend ? emaT : na, title = "Trend line", color = emaCol, linewidth = 2)
plotshape(i_showSecondary and longIsRev, title = A_REV_UP, style = shape.triangleup,
          location = location.belowbar, color = color.new(i_colUp, 50), size = size.tiny)
plotshape(i_showSecondary and shortIsRev, title = A_REV_DOWN, style = shape.triangledown,
          location = location.abovebar, color = color.new(i_colDown, 50), size = size.tiny)
plotshape(i_showMarkers and longSig and not longIsRev, title = A_PB_UP, style = shape.labelup,
          location = location.belowbar, color = i_colUp, textcolor = C_TEXT,
          text = "L", size = size.small)
plotshape(i_showMarkers and shortSig and not shortIsRev, title = A_PB_DOWN, style = shape.labeldown,
          location = location.abovebar, color = i_colDown, textcolor = C_TEXT,
          text = "S", size = size.small)
var array<line> s_lines = array.new_line()
f_levels(float ent, float stp, float t1, float t2, color sideCol) =>
    if i_levels == "Last Signal"
        while s_lines.size() > 0
            line.delete(s_lines.pop())
    if math.abs(ent - stp) > 0
        s_lines.push(line.new(bar_index, stp, bar_index + LEVEL_LEN, stp, color = C_DOWN, style = line.style_dashed, width = 1))
        s_lines.push(line.new(bar_index, ent, bar_index + LEVEL_LEN, ent, color = C_NEUTRAL, style = line.style_dotted, width = 1))
        s_lines.push(line.new(bar_index, t1, bar_index + LEVEL_LEN, t1, color = color.new(sideCol, 30), style = line.style_dashed, width = 1))
        s_lines.push(line.new(bar_index, t2, bar_index + LEVEL_LEN, t2, color = sideCol, style = line.style_dashed, width = 1))
if t1Event and i_moveStop and i_levels == "Last Signal" and s_lines.size() > 0
    line stopLine = s_lines.get(0)
    line.set_y1(stopLine, t1Entry)
    line.set_y2(stopLine, t1Entry)
    line.set_color(stopLine, C_NEUTRAL)
    line.set_style(stopLine, line.style_solid)
if i_levels != "Off"
    if longSig
        f_levels(cC, slL, tp1L, tp2L, i_colUp)
    if shortSig
        f_levels(cC, slS, tp1S, tp2S, i_colDown)
alertcondition(longSig and not longIsRev,   title = A_PB_UP,    message = "{{ticker}} {{interval}} — pullback ended, up")
alertcondition(shortSig and not shortIsRev, title = A_PB_DOWN,  message = "{{ticker}} {{interval}} — pullback ended, down")
alertcondition(longIsRev,                   title = A_REV_UP,   message = "{{ticker}} {{interval}} — exhaustion reversal, up")
alertcondition(shortIsRev,                  title = A_REV_DOWN, message = "{{ticker}} {{interval}} — exhaustion reversal, down")
alertcondition(t1Event,                     title = A_T1,       message = "{{ticker}} {{interval}} — target 1 reached, stop to reference price")
f_payload(string ev, string st, float stp, float t1, float t2) =>
    string j = '{"src":"tv","ind":"trend-breath","ver":"1.0.0"'
    j := j + ',"ev":"' + ev + '"'
    j := j + ',"sym":"' + syminfo.tickerid + '"'
    j := j + ',"tf":"' + timeframe.period + '"'
    j := j + ',"t":"' + str.tostring(time_close) + '"'
    j := j + ',"px":"' + str.tostring(close, format.mintick) + '"'
    j := j + ',"state":"' + st + '"'
    j := j + ',"vals":{"stop":"' + str.tostring(stp, format.mintick) + '","target1":"' + str.tostring(t1, format.mintick) + '","target2":"' + str.tostring(t2, format.mintick) + '"}}'
    j
alertFreq = i_alertOn == "Bar Close" ? alert.freq_once_per_bar_close : alert.freq_once_per_bar
if longSig
    alert(f_payload(longIsRev ? A_REV_UP : A_PB_UP, "up", slL, tp1L, tp2L), alertFreq)
if shortSig
    alert(f_payload(shortIsRev ? A_REV_DOWN : A_PB_DOWN, "down", slS, tp1S, tp2S), alertFreq)
if t1Event
    alert(f_payload(A_T1, t1Up ? "up" : "down", t1Entry, na, t1Tp2), alertFreq)
````
