# Confirmed Close Flow

- url: https://www.tradingview.com/script/oQBXzrUZ-Confirmed-Close-Flow/
- type: indicator
- pine_id: PUB;54392f8ef79e4a9b96a7afad1ee00fc0
- version: 1.0

## Description

WHAT THIS IS

Confirmed Close Flow is a swing trading companion for the 4 hour chart. It puts a trend, a momentum read and market structure on one chart, and it only counts a signal once the candle has closed.

The main signal is simple. A Buy or Sell label appears when the 4H trend flips, and it is drawn in full colour only when the daily trend agrees. A flip against the daily trend is still shown, but small and grey, so you can see it without being tempted by it.

Around that core you get momentum diamonds, confluence stars, break of structure and change of character labels, order blocks, fair value gaps, equal highs and lows, previous day, week and month levels, and a small dashboard that tells you where things stand right now.

It was built for crypto on the 4H with a 1D filter. It runs on any market and timeframe, but that pairing is the one it was designed and tuned around.


WHY CONFIRMED CLOSE

A lot of chart tools look brilliant on history and behave differently live. The reason is usually the same: a signal is allowed to appear while the candle is still forming, and it can vanish again before the close. The history only keeps the versions that survived.

This script decides every signal on a closed bar. A label that prints stays printed. An alert set to "Once Per Bar Close" fires once, at the close, and the chart will still show the same thing after a reload.

The higher timeframe filter follows the same rule. It reads the daily trend from the last CLOSED daily candle, never from today's candle that is still moving. The previous day, week and month levels work the same way.

Two honest notes on timing:
- Market structure needs pivots, and a pivot can only be confirmed a few bars after it happens. The structure line is drawn back to the pivot, but the break itself is only known on the bar where the label appears.
- Execution is up to you. A signal on the close of one candle means the earliest realistic entry is the open of the next one.


HOW TO READ THE CHART

Trend line
A green line under price means the 4H trend is up. A red line above price means it is down. It is an ATR based trailing line, so it gives price room to breathe and only flips when a move is strong enough to matter.

Buy and Sell labels
- Full colour Buy: the 4H trend just flipped up and the daily trend is up.
- Full colour Sell: the 4H trend just flipped down and the daily trend is down.
- Small grey Buy or Sell: the 4H flipped against the daily trend. Worth knowing, not worth acting on by itself.
- Grey full size label: the flip happened while the market was choppy (see Choppiness below).

Background tint
A faint green or red wash shows the daily trend at a glance. When the tint and the trend line agree, the 4H and the daily are aligned.

Momentum diamonds
A small diamond under a candle marks a momentum turn up from a stretched low. A diamond above marks a turn down from a stretched high. They are early warnings, not trade signals on their own. The thin line through price is the momentum moving average, coloured by which side of it momentum sits.

Confluence stars
A star means a trend flip and a momentum diamond happened in the same direction within a few bars of each other. When a star lands on the same bar as a Buy or Sell, it is folded into the label ("Buy ★", "Sell ★"). Only one star is drawn per trend leg.

Structure
BOS (break of structure) marks a close through the last pivot in the direction of the current structure. CHoCH (change of character) marks a close through it in the other direction, the first sign that structure is turning. Internal structure (dashed) follows the short swings. Swing structure (solid, off by default) follows the big ones.

Order blocks
When structure breaks with a strong candle, the script marks the last opposite candle before the move as a zone. Green zones sit below price as possible support, red zones above as possible resistance. A zone stays live until a candle closes through its far side. After that it is cut off at the bar that broke it and faded, so you can still see where it was.

Fair value gaps (off by default)
A three candle imbalance where the first and third candles do not overlap. The box is removed once price fills it.

Equal highs and lows
Dotted lines marked EQH or EQL where two pivots formed at nearly the same price. These levels often attract price, because stops tend to sit just beyond them.

Dashboard
Bottom right by default. It shows the current 4H trend, the daily filter, whether they are aligned, the momentum value, internal and swing structure direction, and the Choppiness Index. It always describes the last closed bar.


HOW TO USE IT

A simple way to work with it:
1. Use the 4H chart with the daily filter (the default).
2. Take the full colour Buy and Sell labels as your primary signals. They are the trend flips that agree with the bigger picture.
3. Treat grey labels as information. A grey Sell inside a daily uptrend is often just a pullback.
4. Use structure and order blocks to plan the trade: where the idea is wrong (below the last higher low or the nearest bullish block for a long) and where price may react (the next bearish block or equal highs above).
5. Be careful when the Choppiness value is high. Trend signals in a sideways market cost money.
6. Set alerts with "Once Per Bar Close".

Alerts
After adding the script, open Create Alert and choose Confirmed Close Flow as the condition. The conditions are:
- Buy (with filter), Sell (with filter): the main signals.
- Any trend flip up, Any trend flip down: every flip, aligned or not.
- Momentum buy, Momentum sell: the diamonds.
- Confluence buy, Confluence sell: the stars.
- Internal BOS, Swing BOS, Internal CHoCH, Swing CHoCH.
- Equal highs, Equal lows.
- Bullish FVG, Bearish FVG.
- Internal OB broken, Swing OB broken: a candle closed through a zone. A touch does not count.

TradingView stores the script settings when an alert is created. If you change a setting later, delete the alert and create it again.


SETTINGS

Trend
- ATR period (10) and Multiplier (3.0): the trailing trend line. A higher multiplier gives fewer, slower flips. A lower one reacts faster and gets shaken out more often.
- Higher timeframe filter (1D): the timeframe whose trend decides whether a flip is aligned. It is read from the last closed candle of that timeframe. Pick something 3 to 6 times your chart timeframe.
- Flips against the filter (Grey): Grey shows them small and grey, Hide removes them, Show draws them like aligned flips.
- Grey out flips in chop (on): a flip that happens while the Choppiness Index is above the limit is drawn grey.
- Choppiness length (14) and Choppiness limit (61.8): the Choppiness Index settings. Above the limit the market is treated as sideways.
- Tint background by filter trend (on).

Momentum
- MA type (SMA) and MA length (40): the average that momentum is measured against.
- Oscillator smoothing (15): smoothing of the momentum line.
- Threshold (0.5): how stretched momentum must be, in ATR units, before a diamond can print. Higher means fewer, more extreme diamonds.
- Show diamonds (on), Show MA line (on), Colour candles by momentum (off).

Confluence
- Show confluence stars (on).
- Window (3 bars): how close together a flip and a diamond must be to earn a star. 0 means the same bar only.

Structure
- Internal pivot length (5) and Swing pivot length (50): how many bars on each side a pivot needs. Larger values mean fewer, more significant pivots, and a longer wait before a pivot is confirmed.
- Show internal structure (on), Show swing structure (off).
- Structure labels (All): show all breaks, only BOS or only CHoCH.
- Structure mode (Present): Present keeps only the latest bullish and bearish break per scale for a clean chart. Historical keeps them all. This only changes the drawings. Alerts fire either way.

Order blocks
- Internal order blocks (on), Swing order blocks (off).
- Max blocks per side (5): how many live zones to keep.
- Mitigation (Close): Close means a candle must close through the far side of the zone to break it. High/Low means a wick is enough.
- Keep broken blocks (faded) (on): broken zones stay on the chart, faded, instead of disappearing.
- Require displacement (on) and Displacement (1.0 ATR): only mark a zone when the candle that broke structure is at least this big. This drops the weak zones left behind by slow drifts through a level.

Fair value gaps
- Show fair value gaps (off).
- Minimum gap (0.25 ATR): smaller gaps are ignored.
- Remove when (Full fill): Full fill waits for the whole gap to be traded through, Half fill removes it at the midpoint.
- Max gaps per side (10).

Equal highs and lows
- Show equal highs/lows (on).
- Pivot length (3).
- Tolerance (0.1 ATR): how close two pivots must be to count as equal.

Higher timeframe levels
- Previous day, week and month high and low (all off). Each uses the last closed period only.

Dashboard
- Show dashboard (on), Position (Bottom right), Text size (Small).

Colours
- Up, Down and Grey colours for every element.


ABOUT THE SETTINGS

The defaults are the ones the script was built and checked with on the 4H chart with a daily filter. They were not optimised bar by bar for any single market. If you change them, change one at a time and look at a long stretch of history, not the last few weeks.

Lower timeframes are a different game. On 1H and below the same logic produced many more flips, and fees and noise eat a much bigger share of each move. Use it there as a map of trend and structure rather than as a signal generator.


CREDIT

The trend line is the Supertrend method (Olivier Seban). The chop filter is the Choppiness Index (E.W. Dreiss). Break of structure, change of character, order blocks, fair value gaps and equal highs and lows are widely used price action concepts. The code, the higher timeframe alignment, the confirmed close handling and the way the parts are combined are original to this script.


LIMITATIONS

- No indicator knows the future. A full colour Buy is a trend flip that agrees with the daily trend, nothing more.
- Trend following loses in sideways markets. Expect a run of small losses before a trend pays for them.
- Structure labels depend on pivots that are confirmed a few bars late, as explained above.
- Order blocks, fair value gaps and equal highs and lows are areas of interest, not guaranteed turning points.
- A gap between one candle's close and the next candle's open can move price past any level before you can act.
- This is a charting tool for education and analysis. It is not financial advice and it does not place trades.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © JohnTRW

//@version=6
// Confirmed Close Flow
// A swing trading companion for the 4H chart. Trend flips, momentum diamonds, confluence stars,
// market structure, order blocks, fair value gaps and equal highs/lows.
// Every signal is decided on a CLOSED bar and nothing repaints.
indicator("Confirmed Close Flow", shorttitle = "CC Flow", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 1000)

// ============================================================ INPUTS
const string G_TR = "Trend"
atrLen   = input.int(10, "ATR period", minval = 1, group = G_TR)
stMult   = input.float(3.0, "Multiplier", minval = 0.1, step = 0.1, group = G_TR)
htfTf    = input.timeframe("1D", "Higher timeframe filter", group = G_TR, tooltip = "The same trend line read from this timeframe's last CLOSED bar. A flip that agrees with it is drawn in full colour. Built for a 4H chart with a 1D filter.")
ctMode   = input.string("Grey", "Flips against the filter", options = ["Grey", "Hide", "Show"], group = G_TR)
useChop  = input.bool(true, "Grey out flips in chop", group = G_TR, tooltip = "A flip while the Choppiness Index is above the limit is drawn grey.")
chopLen  = input.int(14, "Choppiness length", minval = 2, group = G_TR)
chopMax  = input.float(61.8, "Choppiness limit", step = 0.1, group = G_TR)
showTint = input.bool(true, "Tint background by filter trend", group = G_TR)

const string G_OS = "Momentum"
maType   = input.string("SMA", "MA type", options = ["SMA", "EMA", "WMA", "HMA", "RMA"], group = G_OS)
maLen    = input.int(40, "MA length", minval = 2, group = G_OS)
oscLen   = input.int(15, "Oscillator smoothing", minval = 1, group = G_OS)
oscThr   = input.float(0.5, "Threshold (ATR units)", minval = 0.0, step = 0.05, group = G_OS, tooltip = "Oscillator = EMA of (close minus MA) divided by ATR. A buy diamond needs the oscillator below minus this value and crossing above its own value two bars back.")
showDia  = input.bool(true, "Show diamonds", group = G_OS)
showBase = input.bool(true, "Show MA line", group = G_OS)
colBars  = input.bool(false, "Colour candles by momentum", group = G_OS)

const string G_CF = "Confluence"
showStar = input.bool(true, "Show confluence stars", group = G_CF)
confWin  = input.int(3, "Window (bars)", minval = 0, maxval = 20, group = G_CF, tooltip = "A star needs a trend flip and a momentum diamond in the same direction within this many bars. 0 = same bar only. One star per trend leg.")

const string G_ST = "Structure"
intLen   = input.int(5, "Internal pivot length", minval = 2, group = G_ST)
swLen    = input.int(50, "Swing pivot length", minval = 10, group = G_ST)
showInt  = input.bool(true, "Show internal structure", group = G_ST)
showSw   = input.bool(false, "Show swing structure", group = G_ST)
strShow  = input.string("All", "Structure labels", options = ["All", "BOS", "CHoCH"], group = G_ST)
strMode  = input.string("Present", "Structure mode", options = ["Historical", "Present"], group = G_ST, tooltip = "Present keeps only the latest bullish and bearish break per scale. Display only, alerts are not affected.")

const string G_OB = "Order blocks"
showIOB  = input.bool(true, "Internal order blocks", group = G_OB)
showSOB  = input.bool(false, "Swing order blocks", group = G_OB)
maxOB    = input.int(5, "Max blocks per side", minval = 1, maxval = 50, group = G_OB)
obMit    = input.string("Close", "Mitigation", options = ["Close", "High/Low"], group = G_OB)
obKeep   = input.bool(true, "Keep broken blocks (faded)", group = G_OB, tooltip = "A broken block stays on the chart, faded and cut off at the bar that broke it, so older price history still shows its zones.")
reqDisp  = input.bool(true, "Require displacement", group = G_OB, tooltip = "Only draw a block when the breaking candle's range is at least this many ATR.")
dispMult = input.float(1.0, "Displacement (ATR)", minval = 0.1, step = 0.1, group = G_OB)

const string G_FV = "Fair value gaps"
showFVG  = input.bool(false, "Show fair value gaps", group = G_FV)
fvgMin   = input.float(0.25, "Minimum gap (ATR)", minval = 0.0, step = 0.05, group = G_FV)
fvgMit   = input.string("Full fill", "Remove when", options = ["Full fill", "Half fill"], group = G_FV)
maxFVG   = input.int(10, "Max gaps per side", minval = 1, maxval = 50, group = G_FV)

const string G_EQ = "Equal highs and lows"
showEQ   = input.bool(true, "Show equal highs/lows", group = G_EQ)
eqLen    = input.int(3, "Pivot length", minval = 1, group = G_EQ)
eqTol    = input.float(0.1, "Tolerance (ATR)", minval = 0.01, step = 0.01, group = G_EQ)

const string G_HT = "Higher timeframe levels"
showD    = input.bool(false, "Previous day high/low", group = G_HT)
showW    = input.bool(false, "Previous week high/low", group = G_HT)
showM    = input.bool(false, "Previous month high/low", group = G_HT)

const string G_DB = "Dashboard"
showTbl  = input.bool(true, "Show dashboard", group = G_DB)
tblPos   = input.string("Bottom right", "Position", options = ["Bottom right", "Bottom left", "Top right", "Top left", "Middle right"], group = G_DB)
tblTxt   = input.string("Small", "Text size", options = ["Tiny", "Small", "Normal"], group = G_DB)

const string G_CO = "Colours"
bullCol  = input.color(#26a69a, "Up", group = G_CO)
bearCol  = input.color(#ef5350, "Down", group = G_CO)
chopCol  = input.color(#787b86, "Grey", group = G_CO)

// ============================================================ COMMON
conf  = barstate.isconfirmed
atrS  = ta.atr(50)
clear = #00000000

f_ma(float src, int len, string t) =>
    switch t
        "EMA" => ta.ema(src, len)
        "WMA" => ta.wma(src, len)
        "HMA" => ta.hma(src, len)
        "RMA" => ta.rma(src, len)
        => ta.sma(src, len)

// ============================================================ TREND
[stLine, stDir] = ta.supertrend(stMult, atrLen)
trendUp = stDir < 0
flipUp  = conf and stDir < 0 and stDir[1] > 0
flipDn  = conf and stDir > 0 and stDir[1] < 0

chop   = 100 * math.log10(math.sum(ta.atr(1), chopLen) / (ta.highest(chopLen) - ta.lowest(chopLen))) / math.log10(chopLen)
inChop = useChop and chop > chopMax

// higher timeframe trend: previous closed HTF bar only, so it cannot repaint
f_htfDir() =>
    [_l, _d] = ta.supertrend(stMult, atrLen)
    _d[1]
htfDir = request.security(syminfo.tickerid, htfTf, f_htfDir(), lookahead = barmerge.lookahead_on)
htfUp  = htfDir < 0
htfDn  = htfDir > 0
bgcolor(showTint ? (htfUp ? color.new(bullCol, 94) : htfDn ? color.new(bearCol, 94) : na) : na, title = "Filter trend tint")

// aligned flips are the main signal
buyA  = flipUp and htfUp
sellA = flipDn and htfDn
buyC  = flipUp and not htfUp
sellC = flipDn and not htfDn

plot(trendUp ? stLine : na, "Trend line up", bullCol, 2, plot.style_linebr)
plot(trendUp ? na : stLine, "Trend line down", bearCol, 2, plot.style_linebr)

// ============================================================ MOMENTUM
basis = f_ma(close, maLen, maType)
osc   = ta.ema((close - basis) / ta.atr(maLen), oscLen)
oscX  = ta.crossover(osc, osc[2])
oscY  = ta.crossunder(osc, osc[2])
oscUp = conf and oscX and osc < -oscThr
oscDn = conf and oscY and osc > oscThr

plot(showBase ? basis : na, "Momentum MA", osc > 0 ? color.new(bullCol, 30) : color.new(bearCol, 30), 1)
barcolor(colBars ? (osc > 0 ? bullCol : bearCol) : na)

// ============================================================ CONFLUENCE
bsOscUp  = ta.barssince(oscUp)
bsOscDn  = ta.barssince(oscDn)
bsFlipUp = ta.barssince(flipUp)
bsFlipDn = ta.barssince(flipDn)

var bool usedUp = false
var bool usedDn = false
if flipUp
    usedUp := false
if flipDn
    usedDn := false

bool starUp = false
bool starDn = false
if conf and trendUp and not usedUp and ((flipUp and bsOscUp <= confWin) or (oscUp and bsFlipUp <= confWin))
    starUp := true
    usedUp := true
if conf and not trendUp and not usedDn and ((flipDn and bsOscDn <= confWin) or (oscDn and bsFlipDn <= confWin))
    starDn := true
    usedDn := true

// ============================================================ LABELS
// One mark per bar and side: a star that lands on a flip goes inside the label,
// and a diamond is only drawn where no label or star already sits.
sU    = showStar and starUp
sD    = showStar and starDn
showC = ctMode != "Hide"
cColU = ctMode == "Show" and not inChop ? bullCol : color.new(chopCol, 30)
cColD = ctMode == "Show" and not inChop ? bearCol : color.new(chopCol, 30)
plotshape(buyA and not sU ? low - 1.0 * atrS : na, "Buy", shape.labelup, location.absolute, inChop ? chopCol : bullCol, text = "Buy", textcolor = color.white, size = size.small)
plotshape(buyA and sU ? low - 1.0 * atrS : na, "Buy with star", shape.labelup, location.absolute, inChop ? chopCol : bullCol, text = "Buy ★", textcolor = color.white, size = size.small)
plotshape(sellA and not sD ? high + 1.0 * atrS : na, "Sell", shape.labeldown, location.absolute, inChop ? chopCol : bearCol, text = "Sell", textcolor = color.white, size = size.small)
plotshape(sellA and sD ? high + 1.0 * atrS : na, "Sell with star", shape.labeldown, location.absolute, inChop ? chopCol : bearCol, text = "Sell ★", textcolor = color.white, size = size.small)
plotshape(showC and buyC and not sU ? low - 1.0 * atrS : na, "Buy against filter", shape.labelup, location.absolute, cColU, text = "Buy", textcolor = color.white, size = size.tiny)
plotshape(showC and buyC and sU ? low - 1.0 * atrS : na, "Buy against filter with star", shape.labelup, location.absolute, cColU, text = "Buy ★", textcolor = color.white, size = size.tiny)
plotshape(showC and sellC and not sD ? high + 1.0 * atrS : na, "Sell against filter", shape.labeldown, location.absolute, cColD, text = "Sell", textcolor = color.white, size = size.tiny)
plotshape(showC and sellC and sD ? high + 1.0 * atrS : na, "Sell against filter with star", shape.labeldown, location.absolute, cColD, text = "Sell ★", textcolor = color.white, size = size.tiny)
plotchar(sU and not (buyA or (showC and buyC)), "Confluence buy", "★", location.belowbar, bullCol, size = size.small)
plotchar(sD and not (sellA or (showC and sellC)), "Confluence sell", "★", location.abovebar, bearCol, size = size.small)
plotshape(showDia and oscUp and not (buyA or (showC and buyC)) and not sU, "Momentum buy", shape.diamond, location.belowbar, bullCol, size = size.tiny)
plotshape(showDia and oscDn and not (sellA or (showC and sellC)) and not sD, "Momentum sell", shape.diamond, location.abovebar, bearCol, size = size.tiny)

// ============================================================ STRUCTURE + ORDER BLOCKS
f_structure(int len, bool showS, bool showOB, string lStyle, string lSize) =>
    var float hiLvl = na
    var int hiBar = na
    var bool hiDone = true
    var float loLvl = na
    var int loBar = na
    var bool loDone = true
    var int dir = 0
    var line bLn = na
    var label bLb = na
    var line sLn = na
    var label sLb = na
    var array<box> bullOB = array.new<box>()
    var array<box> bearOB = array.new<box>()
    var array<box> brokenOB = array.new<box>()

    ph = ta.pivothigh(high, len, len)
    pl = ta.pivotlow(low, len, len)
    if not na(ph)
        hiLvl := ph
        hiBar := bar_index - len
        hiDone := false
    if not na(pl)
        loLvl := pl
        loBar := bar_index - len
        loDone := false

    bool bullBOS = false
    bool bullCH = false
    bool bearBOS = false
    bool bearCH = false
    bool bullOBx = false
    bool bearOBx = false
    bool disp = not reqDisp or (high - low) >= dispMult * atrS

    // bullish break of the last pivot high, on a closed candle
    if conf and not hiDone and not na(hiLvl) and close > hiLvl
        bool isCH = dir == -1
        bullCH := isCH
        bullBOS := not isCH
        dir := 1
        hiDone := true
        if showS and (strShow == "All" or (strShow == "CHoCH") == isCH)
            if strMode == "Present"
                line.delete(bLn)
                label.delete(bLb)
            bLn := line.new(hiBar, hiLvl, bar_index, hiLvl, color = bullCol, style = lStyle)
            bLb := label.new(int(math.avg(hiBar, bar_index)), hiLvl, isCH ? "CHoCH" : "BOS", style = label.style_label_down, color = clear, textcolor = bullCol, size = lSize)
        if showOB and disp
            int span = math.min(bar_index - hiBar, 300)
            float obLo = low[1]
            float obHi = high[1]
            int obBar = bar_index - 1
            for i = 1 to span
                if low[i] < obLo
                    obLo := low[i]
                    obHi := high[i]
                    obBar := bar_index - i
            bullOB.unshift(box.new(obBar, obHi, bar_index, obLo, border_color = clear, bgcolor = color.new(bullCol, 82), extend = extend.right))
            if bullOB.size() > maxOB
                box.delete(bullOB.pop())

    // bearish break of the last pivot low, on a closed candle
    if conf and not loDone and not na(loLvl) and close < loLvl
        bool isCH = dir == 1
        bearCH := isCH
        bearBOS := not isCH
        dir := -1
        loDone := true
        if showS and (strShow == "All" or (strShow == "CHoCH") == isCH)
            if strMode == "Present"
                line.delete(sLn)
                label.delete(sLb)
            sLn := line.new(loBar, loLvl, bar_index, loLvl, color = bearCol, style = lStyle)
            sLb := label.new(int(math.avg(loBar, bar_index)), loLvl, isCH ? "CHoCH" : "BOS", style = label.style_label_up, color = clear, textcolor = bearCol, size = lSize)
        if showOB and disp
            int span = math.min(bar_index - loBar, 300)
            float obLo = low[1]
            float obHi = high[1]
            int obBar = bar_index - 1
            for i = 1 to span
                if high[i] > obHi
                    obHi := high[i]
                    obLo := low[i]
                    obBar := bar_index - i
            bearOB.unshift(box.new(obBar, obHi, bar_index, obLo, border_color = clear, bgcolor = color.new(bearCol, 82), extend = extend.right))
            if bearOB.size() > maxOB
                box.delete(bearOB.pop())

    // mitigation: a block is gone once price closes (or wicks) through its far side
    if conf and bullOB.size() > 0
        float src = obMit == "Close" ? close : low
        for i = bullOB.size() - 1 to 0
            b = bullOB.get(i)
            if src < b.get_bottom()
                bullOBx := true
                bullOB.remove(i)
                if obKeep
                    b.set_extend(extend.none)
                    b.set_right(bar_index)
                    b.set_bgcolor(color.new(bullCol, 86))
                    brokenOB.unshift(b)
                    if brokenOB.size() > 150
                        box.delete(brokenOB.pop())
                else
                    b.delete()
    if conf and bearOB.size() > 0
        float src = obMit == "Close" ? close : high
        for i = bearOB.size() - 1 to 0
            b = bearOB.get(i)
            if src > b.get_top()
                bearOBx := true
                bearOB.remove(i)
                if obKeep
                    b.set_extend(extend.none)
                    b.set_right(bar_index)
                    b.set_bgcolor(color.new(bearCol, 86))
                    brokenOB.unshift(b)
                    if brokenOB.size() > 150
                        box.delete(brokenOB.pop())
                else
                    b.delete()

    [bullBOS, bullCH, bearBOS, bearCH, bullOBx, bearOBx, dir]

[iBullBOS, iBullCH, iBearBOS, iBearCH, iBullOBx, iBearOBx, iDir] = f_structure(intLen, showInt, showIOB, line.style_dashed, size.tiny)
[sBullBOS, sBullCH, sBearBOS, sBearCH, sBullOBx, sBearOBx, sDir] = f_structure(swLen, showSw, showSOB, line.style_solid, size.small)

// ============================================================ EQUAL HIGHS / LOWS
var float prevEH = na
var int prevEHBar = na
var float prevEL = na
var int prevELBar = na
bool eqh = false
bool eql = false
eph = ta.pivothigh(high, eqLen, eqLen)
epl = ta.pivotlow(low, eqLen, eqLen)
if conf and not na(eph)
    if not na(prevEH) and math.abs(eph - prevEH) < eqTol * atrS
        eqh := true
        if showEQ
            line.new(prevEHBar, prevEH, bar_index - eqLen, eph, color = bearCol, style = line.style_dotted)
            label.new(bar_index - eqLen, eph, "EQH", style = label.style_label_down, color = clear, textcolor = bearCol, size = size.tiny)
    prevEH := eph
    prevEHBar := bar_index - eqLen
if conf and not na(epl)
    if not na(prevEL) and math.abs(epl - prevEL) < eqTol * atrS
        eql := true
        if showEQ
            line.new(prevELBar, prevEL, bar_index - eqLen, epl, color = bullCol, style = line.style_dotted)
            label.new(bar_index - eqLen, epl, "EQL", style = label.style_label_up, color = clear, textcolor = bullCol, size = size.tiny)
    prevEL := epl
    prevELBar := bar_index - eqLen

// ============================================================ FAIR VALUE GAPS
bullFVG = conf and low > high[2] and close[1] > high[2] and (low - high[2]) >= fvgMin * atrS
bearFVG = conf and high < low[2] and close[1] < low[2] and (low[2] - high) >= fvgMin * atrS

var array<box> bullG = array.new<box>()
var array<box> bearG = array.new<box>()

if conf and bullG.size() > 0
    for i = bullG.size() - 1 to 0
        b = bullG.get(i)
        float lvl = fvgMit == "Full fill" ? b.get_bottom() : (b.get_top() + b.get_bottom()) / 2
        if low < lvl
            b.delete()
            bullG.remove(i)
if conf and bearG.size() > 0
    for i = bearG.size() - 1 to 0
        b = bearG.get(i)
        float lvl = fvgMit == "Full fill" ? b.get_top() : (b.get_top() + b.get_bottom()) / 2
        if high > lvl
            b.delete()
            bearG.remove(i)

if bullFVG and showFVG
    bullG.unshift(box.new(bar_index - 2, low, bar_index, high[2], border_color = clear, bgcolor = color.new(bullCol, 88), extend = extend.right))
    if bullG.size() > maxFVG
        box.delete(bullG.pop())
if bearFVG and showFVG
    bearG.unshift(box.new(bar_index - 2, low[2], bar_index, high, border_color = clear, bgcolor = color.new(bearCol, 88), extend = extend.right))
    if bearG.size() > maxFVG
        box.delete(bearG.pop())

// ============================================================ HIGHER TIMEFRAME LEVELS
// high[1]/low[1] with lookahead on = the previous CLOSED period only, no repaint
[dH, dL] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[wH, wL] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[mH, mL] = request.security(syminfo.tickerid, "M", [high[1], low[1]], lookahead = barmerge.lookahead_on)
plot(showD ? dH : na, "Prev day high", color.new(chopCol, 20), 1, plot.style_stepline)
plot(showD ? dL : na, "Prev day low", color.new(chopCol, 20), 1, plot.style_stepline)
plot(showW ? wH : na, "Prev week high", color.new(chopCol, 0), 2, plot.style_stepline)
plot(showW ? wL : na, "Prev week low", color.new(chopCol, 0), 2, plot.style_stepline)
plot(showM ? mH : na, "Prev month high", color.new(#b2b5be, 0), 2, plot.style_stepline)
plot(showM ? mL : na, "Prev month low", color.new(#b2b5be, 0), 2, plot.style_stepline)

// ============================================================ DASHBOARD
tPos = switch tblPos
    "Bottom left" => position.bottom_left
    "Top right" => position.top_right
    "Top left" => position.top_left
    "Middle right" => position.middle_right
    => position.bottom_right
tSize = switch tblTxt
    "Tiny" => size.tiny
    "Normal" => size.normal
    => size.small

var table tb = table.new(tPos, 2, 7, bgcolor = color.new(#131722, 8), border_color = #363a45, border_width = 1)

f_cell(int c, int r, string t, color tc) =>
    table.cell(tb, c, r, t, text_color = tc, text_size = tSize, text_halign = text.align_left)

if barstate.islast and showTbl
    string sIn = iDir == 1 ? "Up" : iDir == -1 ? "Down" : "None yet"
    string sSw = sDir == 1 ? "Up" : sDir == -1 ? "Down" : "None yet"
    bool aligned = (trendUp and htfUp) or (not trendUp and htfDn)
    f_cell(0, 0, "Confirmed Close Flow", color.white)
    f_cell(0, 1, "Trend", color.white)
    f_cell(1, 1, trendUp ? "Up" : "Down", trendUp ? bullCol : bearCol)
    f_cell(0, 2, "Filter " + htfTf, color.white)
    f_cell(1, 2, htfUp ? "Up" : htfDn ? "Down" : "n/a", htfUp ? bullCol : htfDn ? bearCol : chopCol)
    f_cell(0, 3, "Alignment", color.white)
    f_cell(1, 3, aligned ? "Aligned" : "Against filter", aligned ? (trendUp ? bullCol : bearCol) : chopCol)
    f_cell(0, 4, "Momentum", color.white)
    f_cell(1, 4, str.tostring(osc, "0.00"), osc > 0 ? bullCol : bearCol)
    f_cell(0, 5, "Internal / swing", color.white)
    f_cell(1, 5, sIn + " / " + sSw, color.white)
    f_cell(0, 6, "Choppiness", color.white)
    f_cell(1, 6, str.tostring(chop, "0.0"), chop > chopMax ? chopCol : color.white)

if barstate.isfirst and showTbl
    table.merge_cells(tb, 0, 0, 1, 0)

// ============================================================ ALERTS (all fire on bar close)
alertcondition(buyA, "Buy (with filter)", "CC Flow: Buy, trend flipped up with the higher timeframe on {{ticker}} {{interval}}")
alertcondition(sellA, "Sell (with filter)", "CC Flow: Sell, trend flipped down with the higher timeframe on {{ticker}} {{interval}}")
alertcondition(flipUp, "Any trend flip up", "CC Flow: trend flipped up on {{ticker}} {{interval}}")
alertcondition(flipDn, "Any trend flip down", "CC Flow: trend flipped down on {{ticker}} {{interval}}")
alertcondition(oscUp, "Momentum buy", "CC Flow: momentum buy diamond on {{ticker}} {{interval}}")
alertcondition(oscDn, "Momentum sell", "CC Flow: momentum sell diamond on {{ticker}} {{interval}}")
alertcondition(starUp, "Confluence buy", "CC Flow: confluence buy star on {{ticker}} {{interval}}")
alertcondition(starDn, "Confluence sell", "CC Flow: confluence sell star on {{ticker}} {{interval}}")
alertcondition(iBullBOS or iBearBOS, "Internal BOS", "CC Flow: internal BOS on {{ticker}} {{interval}}")
alertcondition(sBullBOS or sBearBOS, "Swing BOS", "CC Flow: swing BOS on {{ticker}} {{interval}}")
alertcondition(iBullCH or iBearCH, "Internal CHoCH", "CC Flow: internal CHoCH on {{ticker}} {{interval}}")
alertcondition(sBullCH or sBearCH, "Swing CHoCH", "CC Flow: swing CHoCH on {{ticker}} {{interval}}")
alertcondition(eqh, "Equal highs", "CC Flow: equal highs on {{ticker}} {{interval}}")
alertcondition(eql, "Equal lows", "CC Flow: equal lows on {{ticker}} {{interval}}")
alertcondition(bullFVG, "Bullish FVG", "CC Flow: bullish FVG on {{ticker}} {{interval}}")
alertcondition(bearFVG, "Bearish FVG", "CC Flow: bearish FVG on {{ticker}} {{interval}}")
alertcondition(iBullOBx or iBearOBx, "Internal OB broken", "CC Flow: internal order block broken on {{ticker}} {{interval}}")
alertcondition(sBullOBx or sBearOBx, "Swing OB broken", "CC Flow: swing order block broken on {{ticker}} {{interval}}")
````
