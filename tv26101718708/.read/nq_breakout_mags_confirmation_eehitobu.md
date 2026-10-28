# NQ Breakout + MAGS Confirmation

- url: https://www.tradingview.com/script/eeHitobU/
- type: indicator
- pine_id: PUB;7ab92ad17ae240fa838f1eb215403f56
- version: 1.0

## Description

Here's a description of your NQ Breakout + MAGS Confirmation (v2) indicator. You can also use it as the description if you save or publish it on TradingView.

Purpose
It automates your Nasdaq futures breakout strategy on the 5-minute chart. It marks your key levels before the New York session, decides the day's direction, and flags breakout entries with a fixed 1:2 risk-reward. MAGS (the Magnificent Seven ETF) acts as a confirmation filter.

1. Level markup (08:30 ET, 1 hour before the NY open)
It draws the key levels of the day:

Previous week high and low (thicker lines)
Previous day high and low
The last 3 H1 swing highs and lows, which are your price reaction points

Levels closer than 15 points are merged into one. Red lines are resistance above price, and teal lines are support below.

2. Daily bias
It reads H1 market structure. Higher highs plus higher lows means longs only, lower highs plus lower lows means shorts only, and mixed structure allows both. You can also set the direction manually.

3. MAGS confirmation
It does the same structure reading on MAGS and maps MAGS's own levels (previous day H/L and H1 swings). Depending on the setting, a trade on NQ only fires if MAGS structure agrees, if MAGS has broken one of its levels in the same direction, or both. When NQ breaks a level but MAGS disagrees, the chart shows a gray "Filtered" tag.

4. Entry
A 5-minute candle must close more than 10 points beyond a marked level. Signals only trigger in the trading window (09:30–11:30 ET by default), with a maximum of 2 trades per day and one trade at a time.

5. Risk management
The stop goes beyond the breakout candle, capped at 35 points (or the trade is skipped, depending on the setting). The target is 2× the risk.

6. Visuals and alerts

Red and green boxes show the stop and target, and ✔ / ✖ marks show each result.
A stats table shows NQ and MAGS bias, the last MAGS break, trades taken, win rate, the 33% breakeven win rate, and net R.
Webhook-ready JSON alerts fire when levels are marked and on every entry and exit, for email or broker automation.

Main settings you can adjust
Markup time, trading window, breakout points, max stop, reward:risk, max trades per day, the MAGS filter mode, and which levels to include.

## Source Code

````pine
//@version=6
indicator("NQ Breakout + MAGS Confirmation", "NQ BO v2", overlay = true, max_lines_count = 300, max_labels_count = 300, max_boxes_count = 300)

// ─────────────────────────────────────────────────────────────
// NQ breakout system v2
// 1. 08:30 ET: marks NQ levels (PWH/PWL, PDH/PDL, H1 swings) and MAGS levels
// 2. Bias from H1 structure on NQ and on MAGS
// 3. NQ breakout = 5m close X points beyond a level
// 4. Optional MAGS filter: MAGS structure and/or a MAGS level breakout must agree
// 5. Stop beyond the breakout candle (capped), target = R multiple, JSON alerts
// Use on a 5-minute NQ1! / NAS100 chart.
// ─────────────────────────────────────────────────────────────

const string TZ = "America/New_York"

// ───── Inputs
grpS = "Session (New York time)"
markupHour   = input.int(8, "Level markup hour", 0, 23, group = grpS)
markupMinute = input.int(30, "Level markup minute", 0, 59, group = grpS)
tradeSess    = input.session("0930-1130", "Trading window", group = grpS)

grpL = "NQ levels"
useWeekly = input.bool(true, "Previous week high / low", group = grpL)
useDaily  = input.bool(true, "Previous day high / low", group = grpL)
useH1     = input.bool(true, "H1 reaction points (swing highs / lows)", group = grpL)
pivLen    = input.int(3, "H1 swing strength (bars each side)", 1, 10, group = grpL)
maxH1     = input.int(3, "Max H1 swings per side", 1, 8, group = grpL)
mergeDist = input.float(15.0, "Merge levels closer than (points)", 0, group = grpL)
maxDist   = input.float(400.0, "Ignore levels farther than (points)", 0, group = grpL)

grpB = "NQ bias"
biasMode = input.string("Auto (H1 structure)", "Direction", options = ["Auto (H1 structure)", "Long only", "Short only", "Both"], group = grpB)

grpM = "MAGS confirmation"
magsSym    = input.symbol("MAGS", "MAGS symbol", group = grpM)
magsMode   = input.string("Bias + breakout", "MAGS filter", options = ["Off", "Bias must agree", "Breakout must agree", "Bias + breakout"], group = grpM)
magsBrkPct = input.float(0.10, "MAGS breakout confirmation (%)", 0, step = 0.05, group = grpM)
magsExt    = input.bool(false, "Use MAGS extended hours (pre-market)", group = grpM)

grpE = "Entry & risk"
breakPts  = input.float(10.0, "Breakout confirmation (points beyond level)", 0, group = grpE)
useClose  = input.bool(true, "Require candle CLOSE beyond level (off = wick touch)", group = grpE)
maxSL     = input.float(35.0, "Max stop (points)", 1, group = grpE)
minSL     = input.float(8.0, "Min stop (points)", 0, group = grpE)
slMode    = input.string("Cap at max", "If candle stop > max", options = ["Cap at max", "Skip trade"], group = grpE)
rr        = input.float(2.0, "Reward : Risk", 0.5, step = 0.5, group = grpE)
maxTrades = input.int(2, "Max trades per day", 1, 10, group = grpE)

grpV = "Visuals"
colRes    = input.color(color.new(color.red, 0), "Resistance", group = grpV)
colSup    = input.color(color.new(color.teal, 0), "Support", group = grpV)
showTable = input.bool(true, "Show stats table", group = grpV)

// ───── Helpers
h1Swings() =>
    ph = ta.pivothigh(high, pivLen, pivLen)
    pl = ta.pivotlow(low, pivLen, pivLen)
    [ph[1], pl[1], time[pivLen + 1]]

structBias(array<float> hi, array<float> lo) =>
    int b = 0
    if hi.size() >= 2 and lo.size() >= 2
        bool hh = hi.get(0) > hi.get(1)
        bool hl = lo.get(0) > lo.get(1)
        if hh and hl
            b := 1
        else if not hh and not hl
            b := -1
    b

biasText(int b) =>
    b == 1 ? "LONG" : b == -1 ? "SHORT" : "BOTH"

pushSwing(array<float> arr, float v) =>
    arr.unshift(v)
    if arr.size() > 10
        arr.pop()

// ───── NQ higher-timeframe data (non-repainting)
[pdh, pdl] = request.security(syminfo.tickerid, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[h1ph, h1pl, h1pt] = request.security(syminfo.tickerid, "60", h1Swings(), lookahead = barmerge.lookahead_on)

// ───── MAGS data
magsTicker = magsExt ? ticker.modify(magsSym, session.extended) : magsSym
[mpdh, mpdl]    = request.security(magsTicker, "D", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[mph, mpl, mpt] = request.security(magsTicker, "60", h1Swings(), lookahead = barmerge.lookahead_on)
mClose          = request.security(magsTicker, timeframe.period, close)

// ───── Swing storage (newest first)
var array<float> swingHi  = array.new<float>()
var array<float> swingLo  = array.new<float>()
var array<float> mSwingHi = array.new<float>()
var array<float> mSwingLo = array.new<float>()
var int lastHiT  = 0
var int lastLoT  = 0
var int mLastHiT = 0
var int mLastLoT = 0

if not na(h1ph) and h1pt != lastHiT
    pushSwing(swingHi, h1ph)
    lastHiT := h1pt
if not na(h1pl) and h1pt != lastLoT
    pushSwing(swingLo, h1pl)
    lastLoT := h1pt
if not na(mph) and mpt != mLastHiT
    pushSwing(mSwingHi, mph)
    mLastHiT := mpt
if not na(mpl) and mpt != mLastLoT
    pushSwing(mSwingLo, mpl)
    mLastLoT := mpt

// ───── NQ levels
type Level
    float price
    string name
    bool  done = false
    line  ln
    label lb

var array<Level> levels = array.new<Level>()
var array<float> magsLv = array.new<float>()

addLevel(float p, string nm, float ref) =>
    if not na(p) and math.abs(p - ref) <= maxDist
        bool dup = false
        for lv in levels
            if math.abs(lv.price - p) <= mergeDist
                dup := true
                lv.name := lv.name + "/" + nm
                break
        if not dup
            levels.push(Level.new(p, nm))

addMagsLevel(float p, float ref) =>
    if not na(p) and not na(ref) and ref > 0 and math.abs(p - ref) / ref * 100 <= 3.0
        bool dup = false
        for q in magsLv
            if math.abs(q - p) <= ref * 0.001
                dup := true
                break
        if not dup
            magsLv.push(p)

// ───── Day state
nyDay   = dayofmonth(time, TZ)
newDay  = nyDay != nyDay[1]
markupT = timestamp(TZ, year(time, TZ), month(time, TZ), dayofmonth(time, TZ), markupHour, markupMinute)

var bool   marked      = false
var int    tradesToday = 0
var int    dayBias     = 0
var int    magsBias    = 0
var int    magsBrk     = 0
var string magsBrkTxt  = "—"

if newDay
    marked      := false
    tradesToday := 0
    magsBrk     := 0
    magsBrkTxt  := "—"

// ───── Markup 1h before NY open
if not marked and time >= markupT
    marked := true
    for lv in levels
        lv.ln.delete()
        lv.lb.delete()
    levels.clear()
    magsLv.clear()

    float ref = close
    if useWeekly
        addLevel(pwh, "PWH", ref)
        addLevel(pwl, "PWL", ref)
    if useDaily
        addLevel(pdh, "PDH", ref)
        addLevel(pdl, "PDL", ref)
    if useH1
        int nH = math.min(maxH1, swingHi.size())
        if nH > 0
            for i = 0 to nH - 1
                addLevel(swingHi.get(i), "H1 High", ref)
        int nL = math.min(maxH1, swingLo.size())
        if nL > 0
            for i = 0 to nL - 1
                addLevel(swingLo.get(i), "H1 Low", ref)

    // MAGS levels: previous day H/L + recent H1 swings
    addMagsLevel(mpdh, mClose)
    addMagsLevel(mpdl, mClose)
    int mH = math.min(maxH1, mSwingHi.size())
    if mH > 0
        for i = 0 to mH - 1
            addMagsLevel(mSwingHi.get(i), mClose)
    int mL = math.min(maxH1, mSwingLo.size())
    if mL > 0
        for i = 0 to mL - 1
            addMagsLevel(mSwingLo.get(i), mClose)

    dayBias  := biasMode == "Long only" ? 1 : biasMode == "Short only" ? -1 : biasMode == "Both" ? 0 : structBias(swingHi, swingLo)
    magsBias := structBias(mSwingHi, mSwingLo)

    string lvlList = ""
    for lv in levels
        color c = lv.price >= ref ? colRes : colSup
        int   w = str.contains(lv.name, "PW") ? 2 : 1
        lv.ln := line.new(time, lv.price, time + 60000, lv.price, xloc = xloc.bar_time, extend = extend.right, color = c, style = line.style_dashed, width = w)
        lv.lb := label.new(time, lv.price, lv.name + "  " + str.tostring(lv.price, format.mintick), xloc = xloc.bar_time, style = label.style_label_left, color = color(na), textcolor = c, size = size.small)
        lvlList += lv.name + " " + str.tostring(lv.price, format.mintick) + "; "

    label.new(time, high, "Levels set · NQ " + biasText(dayBias) + " · MAGS " + biasText(magsBias), xloc = xloc.bar_time, style = label.style_label_down, color = color.new(color.blue, 20), textcolor = color.white, size = size.small)
    alert('{"event":"levels","symbol":"' + syminfo.ticker + '","nq_bias":"' + biasText(dayBias) + '","mags_bias":"' + biasText(magsBias) + '","levels":"' + lvlList + '"}', alert.freq_once_per_bar)

// ───── MAGS breakout tracking (latest break direction wins)
if marked and magsLv.size() > 0 and not na(mClose) and not na(mClose[1])
    for p in magsLv
        float up = p * (1 + magsBrkPct / 100)
        float dn = p * (1 - magsBrkPct / 100)
        if mClose > up and mClose[1] <= up
            magsBrk    := 1
            magsBrkTxt := "UP " + str.tostring(p, "#.##")
        else if mClose < dn and mClose[1] >= dn
            magsBrk    := -1
            magsBrkTxt := "DOWN " + str.tostring(p, "#.##")

bool useMBias = magsMode == "Bias must agree" or magsMode == "Bias + breakout"
bool useMBrk  = magsMode == "Breakout must agree" or magsMode == "Bias + breakout"
bool longOK   = dayBias >= 0 and (not useMBias or magsBias >= 0) and (not useMBrk or magsBrk == 1)
bool shortOK  = dayBias <= 0 and (not useMBias or magsBias <= 0) and (not useMBrk or magsBrk == -1)

// ───── Trade management
inWindow = not na(time(timeframe.period, tradeSess, TZ))

var bool  inTrade = false
var int   dir     = 0
var float ePx     = na
var float slPx    = na
var float tpPx    = na
var box   rBox    = na
var box   tBox    = na
var int   wins    = 0
var int   losses  = 0
var float netR    = 0.0

if inTrade
    rBox.set_right(time)
    tBox.set_right(time)
    bool hitSL = dir == 1 ? low <= slPx : high >= slPx
    bool hitTP = dir == 1 ? high >= tpPx : low <= tpPx
    if hitSL or hitTP
        bool win = hitTP and not hitSL   // same-bar hit counted as loss (conservative)
        if win
            wins += 1
            netR += rr
        else
            losses += 1
            netR -= 1
        label.new(time, win ? tpPx : slPx, win ? "✔ +" + str.tostring(rr) + "R" : "✖ -1R", xloc = xloc.bar_time, style = label.style_label_left, color = color(na), textcolor = win ? color.green : color.red, size = size.small)
        alert('{"event":"exit","symbol":"' + syminfo.ticker + '","result":"' + (win ? "TP" : "SL") + '","price":' + str.tostring(win ? tpPx : slPx) + '}', alert.freq_once_per_bar)
        inTrade := false

// ───── Breakout entries
bool canEnter = marked and inWindow and not inTrade and tradesToday < maxTrades and (useClose ? barstate.isconfirmed : true)

if canEnter
    for lv in levels
        if lv.done
            continue
        float upT = lv.price + breakPts
        float dnT = lv.price - breakPts
        bool rawLong  = useClose ? (close > upT and close[1] <= upT) : (high > upT and high[1] <= upT)
        bool rawShort = useClose ? (close < dnT and close[1] >= dnT) : (low < dnT and low[1] >= dnT)
        bool longSig  = rawLong and longOK
        bool shortSig = rawShort and shortOK
        if (rawLong or rawShort) and not (longSig or shortSig)
            // Level broke but filters disagreed: mark it so you can see the missed/filtered break
            lv.done := true
            label.new(time, rawLong ? high : low, "Filtered · " + lv.name, xloc = xloc.bar_time, style = rawLong ? label.style_label_down : label.style_label_up, color = color.new(color.gray, 30), textcolor = color.white, size = size.tiny)
        else if longSig or shortSig
            lv.done := true
            int   d    = longSig ? 1 : -1
            float e    = useClose ? close : (d == 1 ? math.max(open, upT) : math.min(open, dnT))
            float risk = d == 1 ? e - low : high - e
            bool  skip = false
            if risk > maxSL
                if slMode == "Skip trade"
                    skip := true
                else
                    risk := maxSL
            risk := math.max(risk, minSL)

            if skip
                label.new(time, d == 1 ? high : low, "Skipped · stop > " + str.tostring(maxSL) + " pts", xloc = xloc.bar_time, style = d == 1 ? label.style_label_down : label.style_label_up, color = color.new(color.gray, 20), textcolor = color.white, size = size.tiny)
            else
                inTrade := true
                dir     := d
                ePx     := e
                slPx    := e - d * risk
                tpPx    := e + d * risk * rr
                tradesToday += 1
                rBox := box.new(time, math.max(ePx, slPx), time + 60000, math.min(ePx, slPx), xloc = xloc.bar_time, bgcolor = color.new(color.red, 82), border_color = color.new(color.red, 50))
                tBox := box.new(time, math.max(ePx, tpPx), time + 60000, math.min(ePx, tpPx), xloc = xloc.bar_time, bgcolor = color.new(color.green, 82), border_color = color.new(color.green, 50))
                string side = d == 1 ? "LONG" : "SHORT"
                string mTag = magsMode == "Off" ? "" : " · MAGS ✔"
                label.new(time, d == 1 ? low : high, side + " · " + lv.name + mTag + "\nE " + str.tostring(ePx, format.mintick) + "  SL " + str.tostring(slPx, format.mintick) + "  TP " + str.tostring(tpPx, format.mintick), xloc = xloc.bar_time, style = d == 1 ? label.style_label_up : label.style_label_down, color = d == 1 ? color.teal : color.red, textcolor = color.white, size = size.small)
                alert('{"event":"entry","symbol":"' + syminfo.ticker + '","side":"' + (d == 1 ? "buy" : "sell") + '","entry":' + str.tostring(ePx) + ',"sl":' + str.tostring(slPx) + ',"tp":' + str.tostring(tpPx) + ',"level":"' + lv.name + '","mags_bias":"' + biasText(magsBias) + '","mags_break":"' + magsBrkTxt + '"}', alert.freq_once_per_bar)
            break

// ───── Stats table
var table stats = table.new(position.top_right, 2, 10, bgcolor = color.new(color.black, 15), border_color = color.new(color.gray, 60), border_width = 1)

cellRow(int r, string k, string v, color vc) =>
    stats.cell(0, r, k, text_color = color.gray, text_size = size.small)
    stats.cell(1, r, v, text_color = vc, text_size = size.small)

biasColor(int b) =>
    b == 1 ? color.teal : b == -1 ? color.red : color.white

if showTable and barstate.islast
    int total = wins + losses
    float nearUp = na
    float nearDn = na
    for p in magsLv
        if p > mClose and (na(nearUp) or p < nearUp)
            nearUp := p
        if p < mClose and (na(nearDn) or p > nearDn)
            nearDn := p
    cellRow(0, "NQ bias", biasText(dayBias), biasColor(dayBias))
    cellRow(1, "MAGS bias", biasText(magsBias), biasColor(magsBias))
    cellRow(2, "MAGS last break", magsBrkTxt, biasColor(magsBrk))
    cellRow(3, "MAGS price", na(mClose) ? "—" : str.tostring(mClose, "#.##"), color.white)
    cellRow(4, "MAGS lvl above / below", (na(nearUp) ? "—" : str.tostring(nearUp, "#.##")) + " / " + (na(nearDn) ? "—" : str.tostring(nearDn, "#.##")), color.white)
    cellRow(5, "Trades", str.tostring(total), color.white)
    cellRow(6, "Win rate", total > 0 ? str.tostring(100.0 * wins / total, "#.#") + "%" : "—", color.white)
    cellRow(7, "Breakeven WR", str.tostring(100.0 / (1 + rr), "#.#") + "%", color.white)
    cellRow(8, "Net R", str.tostring(netR, "#.##") + "R", netR >= 0 ? color.green : color.red)
    cellRow(9, "Chart TF", timeframe.period == "5" ? "5m ✔" : timeframe.period + " (use 5m)", color.white)
````
