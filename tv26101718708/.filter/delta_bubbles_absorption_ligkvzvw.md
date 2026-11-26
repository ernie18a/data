# Delta Bubbles + Absorption

- url: https://www.tradingview.com/script/lIGKVzvw/
- type: indicator
- pine_id: PUB;a3086b4b2502485d81dd970b5aeed4b4
- version: 1.0

## Description

Delta Bubbles & Absorption highlights candles with unusually strong buying or selling and follows what happens next: do the traders behind a bubble defend their level, or do they get trapped? It also spots aggression that got absorbed at a swing high or low.

Only the top few percent of delta events are drawn, so the chart stays readable and every bubble is a real outlier.

HOW IT WORKS

Delta
For each candle the script pulls lower timeframe data (1m on charts up to 1H, 5m up to 4H, 15m up to 1D, 60m above that). Every intrabar candle counts its volume as buying or selling based on its direction, and the sum is the candle's delta. On 1m charts and below, the chart candles themselves are used. Where no intrabar data is available, for example deep in the history, delta is estimated from where the candle closed within its range.

Bubbles
The absolute delta of every candle is ranked against the last 500 candles. A bubble appears when:
- delta is above the Bubble Threshold (default 97th percentile, roughly the top 3 %)
- delta points the same way as the candle (buy delta on a green candle, sell delta on a red one)

There are three sizes. The biggest ones need delta above the Ray Threshold (default 99.5th percentile) and a net delta of at least 30 % of the candle's total volume. A minimum spacing between bubbles stops clusters from stacking up. Strong bubbles always show.

Defended or trapped
A big bubble means a lot of traders opened positions aggressively around that price. Their average entry sits close to the bubble, and that's what makes the level interesting later on.

As long as price stays on their side, those traders are in profit. When price comes back to their entry, they often step in again to protect their positions. That's why the level of a buy bubble can act as support and the level of a sell bubble as resistance.

If a candle closes through their entry, they're in loss and trapped. Their stops and exits are orders in the opposite direction, which can push the move further.

Rays
Strong bubbles project their entry area to the right as a zone (bubble price ± Width in ATR) with a dotted midline. As long as the ray is active, the level hasn't been broken. When price returns to it and holds, that's the defense. The ray ends when a candle closes through the zone, which is the moment the bubble traders get trapped. Broken rays can stay on the chart faded out or get removed.

Trapped mark ("−")
Every bubble, including the smaller ones, is also checked for a quick failure. If a candle closes against it within the next few candles (Window, default 10), past its price plus a small ATR buffer, the bubble gets a "−". Those traders got caught right away, and their exits can add fuel to the move against them. After the window the bubble isn't checked anymore, since a move against it much later says little about those traders.

Absorption
Absorption means heavy aggression that couldn't move price. A candle is flagged when all four are true:
1. strong delta
2. little progress: a small body compared to ATR, or the candle closed against its own delta
3. the candle printed the highest high (buy delta) or lowest low (sell delta) of the recent lookback
4. a rejection wick on that same side

Sensitivity (Low / Medium / High) adjusts all four thresholds together. Absorption bubbles sit on the wick where it happened. Colors follow the delta, so a green absorption bubble at a high means buyers got absorbed (bearish hint) and a red one at a low means sellers got absorbed (bullish hint). They use a different style than normal bubbles (white border by default).

HOW TO USE
- When price comes back to a ray and holds, the bubble side is defending its level. That retest can be a spot to look for entries in the bubble's direction.
- A close through a ray means the bubble traders are trapped. Watch for follow-through in the direction of the break.
- Absorption at a swing high or low can hint at a turn, more so when the following candles confirm it.

It works best as extra context next to your own levels and market structure.

SETTINGS
Bubbles: Show Bubbles, Bubble Threshold, Ray Threshold, Min Spacing, Colors, Mark Trapped + Window
Absorption: Show Absorption, Style, BG (only for the ring styles), Sensitivity
Rays: Show Rays, Width (x ATR), Keep Broken Rays

ALERTS
Strong Buy Bubble, Strong Sell Bubble, Bullish Absorption, Bearish Absorption, Trapped Buyers, Trapped Sellers. All alerts fire on candle close.

NOTES
- The script needs volume data. On feeds with tick volume only (many forex and CFD symbols), delta is less meaningful.
- Delta is built from intrabar candles, so it approximates order flow and is less precise than tick or footprint data.
- Bubbles and absorption on the live candle can still change until it closes. Rays and trapped marks are only created on closed candles.

This script is for educational purposes only and is not financial advice.

## Source Code

````pine
//@version=6
indicator("Delta Bubbles + Absorption", shorttitle = "Delta Bubbles", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ═════════════════════════ SETTINGS ═════════════════════════
grpB = "Bubbles"
showBub   = input.bool(true, "Show Bubbles", group = grpB)
bubPct    = input.float(97.0, "Bubble Threshold", minval = 50.0, maxval = 99.9, step = 0.5, group = grpB,
     tooltip = "Percentile of |delta| over the last 500 bars. 97 = only the top 3 %.")
strongPct = input.float(99.5, "Ray Threshold", minval = 50.0, maxval = 99.99, step = 0.1, group = grpB,
     tooltip = "Bubbles above this percentile become strong bubbles and get a ray.")
bubGap    = input.int(5, "Min Spacing (bars)", minval = 0, group = grpB,
     tooltip = "Minimum bars between two bubbles. Strong bubbles are always shown.")
bullCol   = input.color(#00D6A3, "Colors", inline = "col", group = grpB)
bearCol   = input.color(#FF4D6D, "", inline = "col", group = grpB)
showTrap  = input.bool(true, "Mark Trapped", inline = "trap", group = grpB)
trapWin   = input.int(10, "Window", minval = 1, inline = "trap", group = grpB,
     tooltip = "A bubble gets a “−” when a candle closes against it within this many bars. Its traders are in loss (trapped).")

grpA = "Absorption"
showAbs  = input.bool(true, "Show Absorption", group = grpA,
     tooltip = "Strong delta at a swing high/low with a rejection wick while price barely moved: aggressive orders got absorbed by passive limit orders.")
absStyle = input.string("White Border", "Style", options = ["White Border", "Hollow Ring", "Ring + Dot", "Square"], inline = "st", group = grpA)
bgCol    = input.color(#070719, "BG", inline = "st", group = grpA,
     tooltip = "Only used by the ring styles. Must match your chart background.")
absSens  = input.string("Medium", "Sensitivity", options = ["Low", "Medium", "High"], group = grpA,
     tooltip = "High = more signals. Low = fewer, cleaner signals.")

grpR = "Rays"
showRays = input.bool(true, "Show Rays", group = grpR,
     tooltip = "Strong bubbles project a zone to the right until a candle closes through it.")
rayTol   = input.float(0.15, "Width (x ATR)", minval = 0.01, step = 0.01, group = grpR,
     tooltip = "The zone extends this far above and below the bubble price.")
rayKeep  = input.bool(true, "Keep Broken Rays", group = grpR)

// ═════════════════════════ FIXED PARAMETERS ═════════════════════════
LOOKBACK  = 500    // bars used for percentile ranking
DOMINANCE = 30.0   // strong bubble: min |delta| / volume in %
ABS_GAP   = 10     // min bars between absorption signals
TRAP_BUF  = 0.2    // trapped: buffer beyond bubble price (x ATR)
MAX_RAYS  = 30

float bigPct  = (bubPct + strongPct) / 2
float absPct  = absSens == "High" ? 90.0 : absSens == "Low" ? 97.5 : 95.0
float absBody = absSens == "High" ? 0.35 : absSens == "Low" ? 0.20 : 0.25
int   absLook = absSens == "High" ? 10   : absSens == "Low" ? 40   : 20
float absWick = absSens == "High" ? 0.15 : absSens == "Low" ? 0.30 : 0.20

// ═════════════════════════ DELTA ═════════════════════════
int    tfSec = timeframe.in_seconds()
string ltf   = tfSec <= 60 ? timeframe.period : tfSec <= 3600 ? "1" : tfSec <= 14400 ? "5" : tfSec <= 86400 ? "15" : "60"

f_ibDelta() =>
    float v = nz(volume)
    float d = close > open ? v : close < open ? -v : close > nz(close[1]) ? v : close < nz(close[1]) ? -v : 0.0
    d

float[] ibArr    = request.security_lower_tf(syminfo.tickerid, ltf, f_ibDelta())
float   ltfDelta = ibArr.size() > 0 ? ibArr.sum() : na

float rng      = high - low
float estDelta = rng > 0 ? nz(volume) * (2 * close - high - low) / rng : 0.0
float delta    = na(ltfDelta) ? estDelta : ltfDelta
float absD     = math.abs(delta)
float dom      = nz(volume) > 0 ? absD / volume * 100 : 0.0

float pBub    = ta.percentile_nearest_rank(absD, LOOKBACK, bubPct)
float pBig    = ta.percentile_nearest_rank(absD, LOOKBACK, bigPct)
float pStrong = ta.percentile_nearest_rank(absD, LOOKBACK, strongPct)
float pAbs    = ta.percentile_nearest_rank(absD, LOOKBACK, absPct)

float atr  = ta.atr(14)
float hiN  = ta.highest(high, absLook)
float loN  = ta.lowest(low, absLook)
float cumV = ta.cum(nz(volume))
if barstate.islast and cumV == 0
    runtime.error("This symbol has no volume data, delta can't be calculated.")

bool  dirAgree = (delta > 0 and close > open) or (delta < 0 and close < open)
float bTop     = math.max(open, close)
float bBot     = math.min(open, close)

// ═════════════════════════ ABSORPTION ═════════════════════════
// 1) strong delta  2) no price progress  3) at swing extreme  4) rejection wick
bool  c1     = absD >= nz(pAbs, 1e300)
bool  c2     = math.abs(close - open) <= absBody * nz(atr, rng) or not dirAgree
bool  c3     = delta > 0 ? high >= hiN : low <= loN
float wickR  = rng > 0 ? (delta > 0 ? (high - bTop) / rng : (bBot - low) / rng) : 0.0
bool  c4     = wickR >= absWick
bool  absRaw = showAbs and delta != 0 and c1 and c2 and c3 and c4

var int lastAbs = na
bool isAbs = absRaw and (na(lastAbs) or bar_index - lastAbs > ABS_GAP)
lastAbs := isAbs ? bar_index : lastAbs

int   absDir = delta > 0 ? -1 : 1        // buy absorbed → bearish, sell absorbed → bullish
float yAbs   = delta > 0 ? high : low

// ═════════════════════════ BUBBLES ═════════════════════════
bool normBase = showBub and delta != 0 and absD >= nz(pBub, 1e300) and dirAgree and not isAbs
bool isStrong = normBase and absD >= pStrong and dom >= DOMINANCE
int  cat      = isStrong ? 3 : absD >= pBig ? 2 : 1

var int lastBub = na
bool showN = normBase and (isStrong or na(lastBub) or bar_index - lastBub > bubGap)
lastBub := showN ? bar_index : lastBub

color bc = delta > 0 ? bullCol : bearCol

float y1 = showN and cat == 1 ? close : na
float y2 = showN and cat == 2 ? close : na
float y3 = showN and cat == 3 ? close : na
float yA = isAbs ? yAbs : na

// Normal
plotshape(y1, "Normal Glow", shape.circle, location.absolute, color.new(bc, 86), size = size.small, display = display.pane, editable = false)
plotshape(y1, "Normal Core", shape.circle, location.absolute, color.new(bc, 25), size = size.tiny,  display = display.pane, editable = false)
// Large
plotshape(y2, "Large Glow", shape.circle, location.absolute, color.new(bc, 87), size = size.normal, display = display.pane, editable = false)
plotshape(y2, "Large Core", shape.circle, location.absolute, color.new(bc, 10), size = size.small,  display = display.pane, editable = false)
// Strong
plotshape(y3, "Strong Glow Outer", shape.circle, location.absolute, color.new(bc, 90), size = size.huge,   display = display.pane, editable = false)
plotshape(y3, "Strong Glow Inner", shape.circle, location.absolute, color.new(bc, 72), size = size.large,  display = display.pane, editable = false)
plotshape(y3, "Strong Core",       shape.circle, location.absolute, color.new(bc, 0),  size = size.normal, display = display.pane, editable = false)
plotshape(y3, "Strong Shine",      shape.circle, location.absolute, color.new(color.white, 50), size = size.tiny, display = display.pane, editable = false)

// ═════════════════════════ ABSORPTION DISPLAY ═════════════════════════
// Same color as the delta, only the shape differs
bool  stBorder = absStyle == "White Border"
bool  stRing   = absStyle == "Hollow Ring" or absStyle == "Ring + Dot"
bool  stDot    = absStyle == "Ring + Dot"
bool  stSquare = absStyle == "Square"
float yAc      = stSquare ? na : yA

plotshape(yAc, "Absorption Glow", shape.circle, location.absolute, color.new(bc, 86), size = size.large, display = display.pane, editable = false)
// White Border
plotshape(stBorder ? yA : na, "Absorption Border",      shape.circle, location.absolute, color.new(color.white, 10), size = size.normal, display = display.pane, editable = false)
plotshape(stBorder ? yA : na, "Absorption Border Core", shape.circle, location.absolute, color.new(bc, 0),           size = size.small,  display = display.pane, editable = false)
// Hollow Ring / Ring + Dot
plotshape(stRing ? yA : na, "Absorption Ring", shape.circle, location.absolute, color.new(bc, 0), size = size.normal, display = display.pane, editable = false)
plotshape(stRing ? yA : na, "Absorption Hole", shape.circle, location.absolute, bgCol,            size = size.small,  display = display.pane, editable = false)
plotshape(stDot ? yA : na,  "Absorption Dot",  shape.circle, location.absolute, color.new(bc, 0), size = size.tiny,   display = display.pane, editable = false)
// Square
plotshape(stSquare ? yA : na, "Absorption Square Glow", shape.square, location.absolute, color.new(bc, 85), size = size.normal, display = display.pane, editable = false)
plotshape(stSquare ? yA : na, "Absorption Square",      shape.square, location.absolute, color.new(bc, 0),  size = size.small,  display = display.pane, editable = false)

// ═════════════════════════ TRAPPED BUBBLES ═════════════════════════
type Bub
    int   bar
    float y
    float lvl
    int   dir
    int   cat

var array<Bub> bubs = array.new<Bub>()
bool trapBuyNow  = false
bool trapSellNow = false

// Check open bubbles
if barstate.isconfirmed and showTrap and bubs.size() > 0
    for i = bubs.size() - 1 to 0
        Bub  u       = bubs.get(i)
        bool expired = bar_index - u.bar > trapWin
        bool inLoss  = u.dir == 1 ? close < u.lvl : close > u.lvl
        if inLoss and not expired
            string ms = u.cat == 3 ? size.large : u.cat == 2 ? size.normal : size.small
            label.new(u.bar, u.y, "−", style = label.style_label_center, color = color.new(color.white, 100),
                 textcolor = color.white, size = ms,
                 tooltip = u.dir == 1 ? "Buy bubble in loss – buyers trapped" : "Sell bubble in loss – sellers trapped")
            if u.dir == 1
                trapBuyNow := true
            else
                trapSellNow := true
        if inLoss or expired
            bubs.remove(i)

// Track new bubble
if barstate.isconfirmed and showTrap and showN
    int   d   = delta > 0 ? 1 : -1
    float buf = nz(atr, rng) * TRAP_BUF
    bubs.push(Bub.new(bar_index, close, d == 1 ? close - buf : close + buf, d, cat))

// ═════════════════════════ RAYS (strong bubbles only) ═════════════════════════
type Ray
    box   bx
    line  mid
    int   dir
    bool  active
    int   born
    color col

var array<Ray> rays = array.new<Ray>()

f_newRay(float y, int dir, color c) =>
    if rays.size() >= MAX_RAYS
        Ray old = rays.shift()
        old.bx.delete()
        old.mid.delete()
    float tol = math.max(nz(atr, high - low) * rayTol, syminfo.mintick)
    box  b = box.new(bar_index, y + tol, bar_index + 1, y - tol, border_color = color.new(c, 70), border_width = 1, bgcolor = color.new(c, 85), extend = extend.right)
    line m = line.new(bar_index, y, bar_index + 1, y, color = color.new(c, 35), style = line.style_dotted, width = 1, extend = extend.right)
    rays.push(Ray.new(b, m, dir, true, bar_index, c))

// Invalidation: candle closes through the zone
if barstate.isconfirmed and rays.size() > 0
    for i = rays.size() - 1 to 0
        Ray r = rays.get(i)
        if r.active and bar_index > r.born
            bool broken = r.dir == 1 ? close < r.bx.get_bottom() : close > r.bx.get_top()
            if broken
                r.active := false
                if rayKeep
                    r.bx.set_extend(extend.none)
                    r.bx.set_right(bar_index)
                    r.bx.set_bgcolor(color.new(r.col, 94))
                    r.bx.set_border_color(color.new(r.col, 90))
                    r.mid.set_extend(extend.none)
                    r.mid.set_x2(bar_index)
                    r.mid.set_color(color.new(r.col, 80))
                else
                    r.bx.delete()
                    r.mid.delete()
                    rays.remove(i)

// New ray
if barstate.isconfirmed and showRays and showN and isStrong
    f_newRay(close, delta > 0 ? 1 : -1, bc)

// ═════════════════════════ ALERTS ═════════════════════════
alertcondition(barstate.isconfirmed and showN and isStrong and delta > 0, "Strong Buy Bubble", "Strong buy delta bubble + ray")
alertcondition(barstate.isconfirmed and showN and isStrong and delta < 0, "Strong Sell Bubble", "Strong sell delta bubble + ray")
alertcondition(barstate.isconfirmed and isAbs and absDir == 1, "Bullish Absorption", "Sell delta absorbed at the low")
alertcondition(barstate.isconfirmed and isAbs and absDir == -1, "Bearish Absorption", "Buy delta absorbed at the high")
alertcondition(trapBuyNow,  "Trapped Buyers",  "Buy bubble in loss – buyers trapped")
alertcondition(trapSellNow, "Trapped Sellers", "Sell bubble in loss – sellers trapped")
````
