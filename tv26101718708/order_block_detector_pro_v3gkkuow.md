# Order Block Detector Pro

- url: https://www.tradingview.com/script/V3gkkuow-Order-Block-Detector-Pro/
- type: indicator
- pine_id: PUB;f2cbbf73abb4483484434f3fc968699e
- version: 1.0

## Description

Order Block Detector Pro — FVG + Volume + Breaker Blocks

━━━━━━━━━━━━━━━━━━━━
CREDIT & OPEN-SOURCE STATEMENT
━━━━━━━━━━━━━━━━━━━━

Zone detection concept inspired by "Market Structure Break & Orderblock" by EmreKb (TradingView open-source). The codebase has been fully rewritten with significant original additions: Fair Value Gap overlap detection, volume confirmation filter, Breaker Block conversion logic, anti-clustering system, unrespected zone cancellation, and FVG-tagged labels. Published open-source in compliance with TradingView reuse rules.

━━━━━━━━━━━━━━━━━━━━
WHY THESE COMPONENTS WORK TOGETHER
━━━━━━━━━━━━━━━━━━━━

Order blocks identify WHERE institutional orders were placed. Volume confirms WHETHER those orders had genuine institutional size. Fair Value Gaps identify WHETHER an imbalance exists inside the zone that price is likely to return and fill. None of these three factors alone is sufficient — an order block without volume may be retail noise; volume without structure has no location context; FVGs without a structural anchor have no directional bias. Combined, they produce a filtered, high-probability zone with multiple layers of institutional confirmation.

━━━━━━━━━━━━━━━━━━━━
WHAT THIS INDICATOR DOES
━━━━━━━━━━━━━━━━━━━━

Detects four zone types based on market structure breaks:
- Bu OB — Bullish Order Block (demand)
- Be OB — Bearish Order Block (supply)
- Bu BB — Bullish Breaker Block (former supply flipped to demand)
- Be BB — Bearish Breaker Block (former demand flipped to supply)

Each zone is volume-confirmed, FVG-tagged when applicable, anti-clustered, and auto-mitigated when price returns.

━━━━━━━━━━━━━━━━━━━━
MARKET STRUCTURE — SWING PIVOTS + BOS
━━━━━━━━━━━━━━━━━━━━

Swing highs and lows detected using ta.pivothigh() and ta.pivotlow() with a configurable pivot length (default 5 bars each side).

Break of Structure (BOS) is confirmed when:
- BOS Up: close crosses above a previously unbroken swing high
- BOS Down: close crosses below a previously unbroken swing low

Each swing point is tracked in a typed array (Swing type: price, bar, broken flag). Once broken, the swing is marked and triggers order block search.

━━━━━━━━━━━━━━━━━━━━
ORDER BLOCK DETECTION
━━━━━━━━━━━━━━━━━━━━

On BOS Up: script searches backwards up to N bars (default 25) for the most recent bearish candle (close < open). That candle is the Bullish Order Block — the last point where sellers were active before institutional buyers took control.

On BOS Down: searches backwards for the most recent bullish candle (close > open). That candle is the Bearish Order Block.

Zone boundaries:
- Full Range mode: top = high, bottom = low of OB candle
- Body Only mode: top = max(open, close), bottom = min(open, close)

━━━━━━━━━━━━━━━━━━━━
VOLUME CONFIRMATION
━━━━━━━━━━━━━━━━━━━━

When enabled, an order block only forms if:
- volume[offset] > SMA(volume, 20) × multiplier (default 1.5×)

This filters out low-participation structural moves that are more likely to fail on retest. The volume is read at the OB candle's bar offset, not the current bar.

━━━━━━━━━━━━━━━━━━━━
FAIR VALUE GAP (FVG) DETECTION
━━━━━━━━━━━━━━━━━━━━

After an order block is identified, the script checks for a Fair Value Gap within the zone's price range.

Bullish FVG condition (within OB range):
- low[m−1] > high[m+1] — gap between candle m−1's low and candle m+1's high
- Both gap boundaries fall within the OB top/bottom range

Bearish FVG: inverse — high[m−1] < low[m+1].

When a FVG is detected inside the zone, a ★ symbol is appended to the zone label. These zones represent compounded institutional imbalances — price is statistically more likely to react at them.

━━━━━━━━━━━━━━━━━━━━
ANTI-CLUSTERING SYSTEM
━━━━━━━━━━━━━━━━━━━━

Prevents redundant overlapping zones using two filters:

Spacing filter:
- New zone rejected if midpoint is within ATR(14) × spacing multiplier of any existing active zone of the same type

Max active cap:
- Each zone type (Bu OB, Be OB, Bu BB, Be BB) capped at N active zones (default 5)
- When exceeded, oldest zone of that type is removed first

━━━━━━━━━━━━━━━━━━━━
MITIGATION LOGIC
━━━━━━━━━━━━━━━━━━━━

Two mitigation modes:

Body Close (default):
- Bu OB mitigated when close < zone bottom
- Be OB mitigated when close > zone top

Wick Touch:
- Bu OB mitigated when low < zone bottom
- Be OB mitigated when high > zone top

━━━━━━━━━━━━━━━━━━━━
BREAKER BLOCK CONVERSION
━━━━━━━━━━━━━━━━━━━━

When a mitigated zone was previously touched (price entered the zone at least once before violation):
- Bu OB violated → converts to Be BB (Bearish Breaker Block)
- Be OB violated → converts to Bu BB (Bullish Breaker Block)

Breaker Blocks represent zones where institutional orders have been fully absorbed — price is expected to use them as opposition on return.

Unrespected zone cancellation: if a zone is violated without ever being touched (price skipped through it), it is removed entirely rather than converted. This avoids phantom breaker blocks from low-quality structural moves.

━━━━━━━━━━━━━━━━━━━━
ZONE RENDERING
━━━━━━━━━━━━━━━━━━━━

Each zone is drawn as a box extending N bars to the right (default 50, updated each bar via box.set_right). Zone type visual identifiers:

- Bu OB — teal fill, solid border
- Be OB — red fill, solid border
- Bu BB — blue fill, dashed border
- Be BB — orange fill, dashed border

Volume of the OB candle is displayed inside the box (formatted as K/M/B). Labels show zone type and FVG tag (★) when applicable.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE
━━━━━━━━━━━━━━━━━━━━

1. Wait for a fresh Bu OB or Be OB to form after a BOS
2. Prioritize zones marked with ★ (FVG overlap = stronger imbalance)
3. Enter when price returns to the zone on lower timeframe confirmation
4. Bu BB and Be BB are counter-trend zones — treat as resistance/support levels after a failed OB
5. Mitigated zones auto-remove — no manual cleanup needed

Entry logic suggestion:
- Long: price enters Bu OB zone → bullish rejection candle → entry above that candle
- Short: price enters Be OB zone → bearish rejection candle → entry below that candle

Stop loss: opposite side of the zone box
Target: next opposing zone or structural high/low

━━━━━━━━━━━━━━━━━━━━
RECOMMENDED SETTINGS
━━━━━━━━━━━━━━━━━━━━

- Scalping (1m–5m): Swing Length 3, OB Search 15, Volume ON 1.5×
- Intraday (15m–1H): Swing Length 5, OB Search 25, Volume ON 1.5×
- Swing (4H–Daily): Swing Length 7, OB Search 40, Volume OFF
- Forex/Gold: Volume OFF (broker tick volume unreliable)
- Stocks/Crypto/Futures: Volume ON

━━━━━━━━━━━━━━━━━━━━

No repainting. Pivot detection is inherently offset by pivot length bars by design. All zone creation and mitigation runs on confirmed price data only.

## Source Code

````pine
//@version=6
indicator("Order Block Detector Pro", "OB Pro", overlay = true, max_boxes_count = 500, max_labels_count = 500)

// ═════ Inputs ═════
swingLen   = input.int(5,     "Swing Pivot Length",              minval = 2,               group = "Structure")
obSearch   = input.int(25,    "OB Search Range",                 minval = 3, maxval = 100, group = "Order Blocks")
useBody    = input.bool(false,"Body Only (else Full Range)",                               group = "Order Blocks")
minDistATR = input.float(0.5, "Min Spacing (× ATR)",             minval = 0, step = 0.1,   group = "Anti-Cluster")
maxActive  = input.int(5,     "Max Active per Type",             minval = 1, maxval = 20,  group = "Anti-Cluster")
mitWick    = input.bool(false,"Mitigate by Wick",                                          group = "Mitigation")
killUnresp = input.bool(true, "Cancel Unrespected Zones",                                  group = "Mitigation")
useVol     = input.bool(true, "Volume Confirmation",                                       group = "Volume")
volMult    = input.float(1.5, "Min Volume × SMA(20)",            minval = 1.0, step = 0.1, group = "Volume")
useFVG     = input.bool(true, "Mark FVG Overlap (★)",                                      group = "FVG")
extendBars = input.int(50,    "Box Extension (bars)",            minval = 5,               group = "Visuals")
showLabels = input.bool(true, "Show Labels",                                               group = "Visuals")

cBuOB = input.color(color.new(#26a69a, 80), "Bu OB", group = "Colors")
cBeOB = input.color(color.new(#ef5350, 80), "Be OB", group = "Colors")
cBuBB = input.color(color.new(#2962ff, 80), "Bu BB", group = "Colors")
cBeBB = input.color(color.new(#ff9100, 80), "Be BB", group = "Colors")
cBull = input.color(#00c853,                "Bull Text", group = "Colors")
cBear = input.color(#ff1744,                "Bear Text", group = "Colors")

// ═════ Series ═════
atrV   = ta.atr(14)
volSMA = ta.sma(volume, 20)

// ═════ Types ═════
type Swing
    float price
    int   bar
    bool  broken

type OB
    box   bx
    label lb
    float top
    float bot
    int   kind
    bool  mit
    int   flipTo
    int   bornBar
    bool  touched
    bool  fvg
    float vol

var array<Swing> highs = array.new<Swing>()
var array<Swing> lows  = array.new<Swing>()
var array<OB>    store = array.new<OB>()

// ═════ Helpers ═════
kindCol(int k)           => k == 1 ? cBuOB : k == 2 ? cBeOB : k == 3 ? cBuBB : cBeBB
kindTxtCol(int k)        => (k == 1 or k == 3) ? cBull : cBear
kindTxt(int k, bool fvg) => (k == 1 ? "Bu OB" : k == 2 ? "Be OB" : k == 3 ? "Bu BB" : "Be BB") + (fvg ? " ★" : "")
isBull(int k)            => k == 1 or k == 3

fmtVol(float v) =>
    result = ""
    if v >= 1.0e9
        result := str.tostring(v / 1.0e9, "#.##") + "B"
    else if v >= 1.0e6
        result := str.tostring(v / 1.0e6, "#.##") + "M"
    else if v >= 1.0e3
        result := str.tostring(v / 1.0e3, "#.##") + "K"
    else
        result := str.tostring(math.round(v))
    result

volOK(int off) =>
    not useVol or (not na(volume[off]) and not na(volSMA[off]) and volume[off] > volSMA[off] * volMult)

hasFVGBull(int off, float t, float b) =>
    found = false
    if useFVG and off >= 3
        for m = 1 to off - 2
            if low[m - 1] > high[m + 1]
                if low[m - 1] >= b and high[m + 1] <= t
                    found := true
                    break
    found

hasFVGBear(int off, float t, float b) =>
    found = false
    if useFVG and off >= 3
        for m = 1 to off - 2
            if high[m - 1] < low[m + 1]
                if low[m + 1] >= b and high[m - 1] <= t
                    found := true
                    break
    found

isCluster(float t, float b, int k) =>
    res = false
    n = array.size(store)
    if n > 0
        for i = 0 to n - 1
            o = array.get(store, i)
            if o.kind == k and not o.mit
                if math.abs((t + b) * 0.5 - (o.top + o.bot) * 0.5) < atrV * minDistATR
                    res := true
                    break
    res

createOB(int k, float t, float b, int barOrigin, bool fvg, float vol) =>
    if not isCluster(t, b, k)
        col    = kindCol(k)
        bs     = (k == 3 or k == 4) ? line.style_dashed : line.style_solid
        volTxt = not na(vol) and vol > 0 ? fmtVol(vol) : ""
        bx     = box.new(barOrigin, t, bar_index + extendBars, b,
                         bgcolor      = col,
                         border_color = color.new(col, 20),
                         border_width = 1,
                         border_style = bs,
                         text         = volTxt,
                         text_color   = kindTxtCol(k),
                         text_halign  = text.align_right,
                         text_valign  = text.align_center,
                         text_size    = size.small)
        lb = showLabels ? label.new(bar_index + extendBars, (t + b) * 0.5,
                         kindTxt(k, fvg),
                         color    = color.new(color.black, 100),
                         textcolor = kindTxtCol(k),
                         style    = label.style_label_left,
                         size     = size.small) : na
        array.push(store, OB.new(bx, lb, t, b, k, false, 0, barOrigin, false, fvg, vol))

trimKind(int k) =>
    cnt = 0
    s0  = array.size(store)
    if s0 > 0
        for i = 0 to s0 - 1
            o = array.get(store, i)
            if o.kind == k and not o.mit
                cnt += 1
    while cnt > maxActive
        s1 = array.size(store)
        if s1 == 0
            break
        removed = false
        for i = 0 to s1 - 1
            o = array.get(store, i)
            if o.kind == k and not o.mit
                box.delete(o.bx)
                if not na(o.lb)
                    label.delete(o.lb)
                array.remove(store, i)
                cnt -= 1
                removed := true
                break
        if not removed
            break

// ═════ Pivots ═════
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow (low,  swingLen, swingLen)
if not na(ph)
    array.push(highs, Swing.new(ph, bar_index - swingLen, false))
if not na(pl)
    array.push(lows, Swing.new(pl, bar_index - swingLen, false))
while array.size(highs) > 50
    array.shift(highs)
while array.size(lows) > 50
    array.shift(lows)

// ═════ BOS ═════
bosUp   = false
bosDown = false
nh = array.size(highs)
if nh > 0
    for i = 0 to nh - 1
        s = array.get(highs, i)
        if not s.broken and close > s.price
            s.broken := true
            bosUp    := true
nl = array.size(lows)
if nl > 0
    for i = 0 to nl - 1
        s = array.get(lows, i)
        if not s.broken and close < s.price
            s.broken := true
            bosDown  := true

// ═════ Create OBs ═════
if bosUp
    foundBar = -1
    for i = 1 to obSearch
        if close[i] < open[i]
            foundBar := bar_index - i
            break
    if foundBar > -1
        off = bar_index - foundBar
        if volOK(off)
            t   = useBody ? math.max(open[off], close[off]) : high[off]
            b   = useBody ? math.min(open[off], close[off]) : low[off]
            fvg = hasFVGBull(off, t, b)
            createOB(1, t, b, foundBar, fvg, volume[off])

if bosDown
    foundBar = -1
    for i = 1 to obSearch
        if close[i] > open[i]
            foundBar := bar_index - i
            break
    if foundBar > -1
        off = bar_index - foundBar
        if volOK(off)
            t   = useBody ? math.max(open[off], close[off]) : high[off]
            b   = useBody ? math.min(open[off], close[off]) : low[off]
            fvg = hasFVGBear(off, t, b)
            createOB(2, t, b, foundBar, fvg, volume[off])

// ═════ Pass 1: Touch + Mitigation ═════
szM = array.size(store)
if szM > 0
    for i = 0 to szM - 1
        o = array.get(store, i)
        if not o.mit
            if isBull(o.kind)
                if low <= o.top and low >= o.bot
                    o.touched := true
            else
                if high >= o.bot and high <= o.top
                    o.touched := true
            violated = false
            flip     = 0
            if o.kind == 1
                if (mitWick ? low < o.bot : close < o.bot)
                    violated := true
                    flip     := 4
            else if o.kind == 2
                if (mitWick ? high > o.top : close > o.top)
                    violated := true
                    flip     := 3
            else if o.kind == 3
                if (mitWick ? low < o.bot : close < o.bot)
                    violated := true
            else if o.kind == 4
                if (mitWick ? high > o.top : close > o.top)
                    violated := true
            if violated
                o.mit    := true
                o.flipTo := (killUnresp and not o.touched) ? 0 : flip

// ═════ Pass 2: Remove + Flip ═════
szC = array.size(store)
if szC > 0
    for i = szC - 1 to 0
        if i < array.size(store)
            o = array.get(store, i)
            if o.mit
                ft  = o.flipTo
                t   = o.top
                b   = o.bot
                bb  = o.bornBar
                fvg = o.fvg
                vol = o.vol
                box.delete(o.bx)
                if not na(o.lb)
                    label.delete(o.lb)
                array.remove(store, i)
                if ft > 0
                    createOB(ft, t, b, bb, fvg, vol)

trimKind(1)
trimKind(2)
trimKind(3)
trimKind(4)

// ═════ Extend ═════
szE = array.size(store)
if szE > 0
    for i = 0 to szE - 1
        o = array.get(store, i)
        if not o.mit
            box.set_right(o.bx, bar_index + extendBars)
            if not na(o.lb)
                label.set_x(o.lb, bar_index + extendBars)

alertcondition(bosUp,   "Bu OB", "Bullish Order Block formed")
alertcondition(bosDown, "Be OB", "Bearish Order Block formed")
````
