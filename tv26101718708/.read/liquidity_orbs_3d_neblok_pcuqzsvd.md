# Liquidity Orbs 3D [Neblok]

- url: https://www.tradingview.com/script/PcuqZsvd-Liquidity-Orbs-3D-Neblok/
- type: indicator
- pine_id: PUB;37a78477deb8432dbede46cbf8c03124
- version: 1.0

## Description

Liquidity Orbs 3D [Neblok]

Liquidity Orbs 3D maps where resting liquidity is likely sitting on your chart — above swing highs and below swing lows — and shows how much money actually traded while each of those swings formed. Every level is drawn as a neon orb to the right of price, sized by its traded value, with a clear label showing the value, the price, and how far away it is. When price trades through a level, it is removed automatically and marked as swept.

This is a free, open-source script.

━━━━━━━━━━━━━━━━━━━━
WHAT IT SHOWS
━━━━━━━━━━━━━━━━━━━━

- Red orbs = liquidity levels ABOVE current price (built from swing highs)
- Green orbs = liquidity levels BELOW current price (built from swing lows)
- Cyan ring + solid line + "NEAREST" tag = the closest level on each side
- Orb size = how heavy that level is compared to the other visible levels. The largest orb on screen is the heaviest pool.
- Yellow "✕ SWEPT" marker = a level that price has already run through

Each label reads like this:
  ▲ NEAREST  $822.88M @ 24,987.00  +5.50
  → traded value, level price, distance from current price

━━━━━━━━━━━━━━━━━━━━
HOW THE LEVELS ARE BUILT
━━━━━━━━━━━━━━━━━━━━

1. The script finds confirmed swing highs and swing lows using pivot logic (left and right bars).
2. For each swing, it adds up the value traded across the bars that formed it. In "Notional $" mode this is volume × price × the contract's point value, so futures like MNQ, MES, NQ and ES show real dollar amounts. In "Contracts" mode it uses raw volume.
3. That value is compared to the recent average swing. Swings below the minimum strength are ignored, so only meaningful levels stay on the chart.
4. Levels on the same side that sit very close together are merged into a single pool. Their values are combined, and the level keeps the more extreme price. This prevents stacked, unreadable labels.
5. A level stays on the chart until price trades through it. Then it is deleted and a swept marker is left behind.

Note: a swing is only confirmed after the "Pivot right bars" number of bars has passed. New levels therefore appear a few bars after the actual high or low. This is normal and prevents levels from repainting.

━━━━━━━━━━━━━━━━━━━━
HOW TO USE IT
━━━━━━━━━━━━━━━━━━━━

- Targets: The nearest orb in the direction of your trade is a logical area where price may be drawn to. Large orbs are often the more meaningful magnets.

- Stop awareness: Avoid placing stops just beyond a heavy orb. Those areas are where resting stops tend to cluster and where sweeps commonly happen.

- Sweep reactions: When a large orb gets swept and price quickly returns back inside the range, that can signal a stop run rather than a true breakout. Use the yellow SWEPT markers to spot these.

- Imbalance: The HUD shows the total liquidity above vs. below price. A heavily one-sided reading tells you where the larger pool of resting orders sits.

- Confluence: This works best combined with your own structure, session levels, or entry model. It is a map of where liquidity sits, not a buy or sell signal on its own.

━━━━━━━━━━━━━━━━━━━━
THE HUD (TABLE)
━━━━━━━━━━━━━━━━━━━━

- Nearest ▲ / ▼ — price, distance, and value of the closest level on each side
- Pool ▲ / ▼ — total value of all active levels above and below price
- Heavier side — which side holds more liquidity, as a percentage

━━━━━━━━━━━━━━━━━━━━
SETTINGS GUIDE
━━━━━━━━━━━━━━━━━━━━

DETECTION
- Pivot left / right bars — Swing sensitivity. Higher values = fewer, more significant swings. Right bars also sets the confirmation delay.
- Size orbs by — Notional $ (volume × price × point value) or Contracts.
- Strength baseline length — How many swings are used to calculate the "average" swing value.
- Min strength (× baseline) — Filter. 1.0 keeps only above-average swings. Raise it for a cleaner chart; lower it to see more levels.
- Merge nearby levels (× ATR) — How close two levels must be to combine. Raise it if labels still overlap.
- Max levels kept in memory — Upper limit on stored levels.
- Expire levels after N bars — Removes old levels that were never swept. 0 = never expire.

DISPLAY
- Levels shown above / below price — How many of the nearest levels to draw on each side.
- Orb style — 3D (glow ring, drop shadow, highlight) or Flat.
- Orb distance right of last bar — How far into the future the orbs sit.
- 3D highlight lift — Moves the white highlight on each orb. Adjust this if it looks off-center at your zoom level.
- Draw level lines / Show value labels / Show distance from price — Turn each element on or off.
- Label text size / Label gap from orb — Readability controls.

NEON COLORS
- Separate colors for levels above, levels below, the nearest accent, swept markers, and the label/HUD background.

SWEEPS & ALERTS
- Sweep trigger — Wick (any trade through the level) or Close (a candle must close through it).
- Mark swept levels / Swept markers kept — Controls the yellow sweep markers.
- Alert only if strength ≥ — Only alert on sweeps of levels at or above this strength. 0 = alert on all sweeps.

HUD
- Show HUD, position, and text size.

━━━━━━━━━━━━━━━━━━━━
ALERTS
━━━━━━━━━━━━━━━━━━━━

Create an alert and choose one of these:
- "Any alert() function call" — detailed message with the symbol, level value, and price that was swept (fires on bar close)
- "Liquidity above swept"
- "Liquidity below swept"

━━━━━━━━━━━━━━━━━━━━
TIPS
━━━━━━━━━━━━━━━━━━━━

- Works on any symbol with volume data. On symbols without volume, orbs are still drawn but all have equal size.
- On 1–5 minute futures charts, the default settings are a good starting point. On higher timeframes, try raising the pivot bars.
- If the chart looks busy, raise "Min strength" or lower the number of levels shown per side.
- Hover over any orb or label to see a tooltip with its value, price, strength, and age.

━━━━━━━━━━━━━━━━━━━━
DISCLAIMER
━━━━━━━━━━━━━━━━━━━━

This script is provided for educational and informational purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any security, futures contract, or other financial instrument.

Liquidity levels show where orders may be resting based on past price and volume. They do not predict future price movement, and price can move through, ignore, or reverse at any level.

Trading futures, options, stocks, and other leveraged products involves substantial risk of loss and is not suitable for every investor. You can lose more than your initial investment. Past performance is not indicative of future results.

Always do your own research, test any tool before using it with real money, and consult a licensed financial professional before making trading decisions. The author is not responsible for any losses resulting from the use of this script.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NeBlok

//@version=6
// ════════════════════════════════════════════════════════════════════════════
//  Liquidity Orbs 3D [Neblok]
//  Resting liquidity above swing highs and below swing lows, sized by the
//  notional value (or contracts) traded while each swing formed.
//  • Side color: neon red above price, neon green below price
//  • Nearest level on each side gets a cyan ring + solid line + tag
//  • Levels auto-delete when swept (wick or close), with optional sweep markers
//  • Nearby levels merge into one pool so labels don't stack on top of each other
//  • HUD: nearest above/below, total pool above vs below
//  Free script by Neblok.
// ════════════════════════════════════════════════════════════════════════════
indicator("Liquidity Orbs 3D [Neblok]", shorttitle = "Liq Orbs 3D [Neblok]", overlay = true, max_labels_count = 500, max_lines_count = 500)

// ───────────────────────────── Inputs: Detection ─────────────────────────────
grpD        = "Detection"
pivLeft     = input.int(5, "Pivot left bars", minval = 1, group = grpD)
pivRight    = input.int(5, "Pivot right bars (confirmation delay)", minval = 1, group = grpD)
valueMode   = input.string("Notional $", "Size orbs by", options = ["Notional $", "Contracts"], group = grpD, tooltip = "Notional $ = volume × price × point value, summed across the bars that built the swing.")
strengthLen = input.int(100, "Strength baseline length", minval = 10, group = grpD)
minStrength = input.float(1.0, "Min strength (× baseline)", minval = 0.0, step = 0.1, group = grpD, tooltip = "Only keep swings whose traded value is at least this multiple of the recent average swing value. Raise to show fewer, heavier levels.")
mergeATR    = input.float(0.35, "Merge nearby levels (× ATR)", minval = 0.0, step = 0.05, group = grpD, tooltip = "Same-side levels closer than this are combined into one pool. Stops overlapping labels.")
maxStored   = input.int(150, "Max levels kept in memory", minval = 10, maxval = 400, group = grpD)
maxAge      = input.int(0, "Expire levels after N bars (0 = never)", minval = 0, group = grpD)

// ───────────────────────────── Inputs: Display ───────────────────────────────
grpV        = "Display"
showAbove   = input.int(5, "Levels shown above price", minval = 0, maxval = 20, group = grpV)
showBelow   = input.int(5, "Levels shown below price", minval = 0, maxval = 20, group = grpV)
orbStyle    = input.string("3D", "Orb style", options = ["3D", "Flat"], group = grpV)
orbOffset   = input.int(10, "Orb distance right of last bar", minval = 2, maxval = 200, group = grpV)
specLiftATR = input.float(0.12, "3D highlight lift (× ATR)", minval = 0.0, step = 0.02, group = grpV, tooltip = "Moves the white highlight dot upward on each orb. Tune to your zoom level.")
showLines   = input.bool(true, "Draw level lines", group = grpV)
showPills   = input.bool(true, "Show value labels", group = grpV)
pillSize    = input.string("Large", "Label text size", options = ["Small", "Normal", "Large", "Huge"], group = grpV)
pillGap     = input.int(4, "Label gap from orb (bars)", minval = 1, maxval = 50, group = grpV)
showDist    = input.bool(true, "Show distance from price", group = grpV)

// ───────────────────────────── Inputs: Neon colors ───────────────────────────
grpC        = "Neon Colors"
colAbove    = input.color(#FF1F57, "Levels above price", group = grpC)
colBelow    = input.color(#39FF14, "Levels below price", group = grpC)
colNear     = input.color(#00F0FF, "Nearest level accent", group = grpC)
colSwept    = input.color(#FFF01F, "Swept marker", group = grpC)
colPillBg   = input.color(#05050A, "Label / HUD background", group = grpC)

// ───────────────────────────── Inputs: Sweeps & alerts ───────────────────────
grpS        = "Sweeps & Alerts"
sweepSrc    = input.string("Wick", "Sweep trigger", options = ["Wick", "Close"], group = grpS)
showSwept   = input.bool(true, "Mark swept levels", group = grpS)
maxSwept    = input.int(15, "Swept markers kept on chart", minval = 1, maxval = 100, group = grpS)
alertMinStr = input.float(0.0, "Alert only if strength ≥ (× baseline)", minval = 0.0, step = 0.1, group = grpS)

// ───────────────────────────── Inputs: HUD ───────────────────────────────────
grpH        = "HUD"
showHud     = input.bool(true, "Show HUD", group = grpH)
hudPos      = input.string("Top Right", "HUD position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = grpH)
hudSize     = input.string("Normal", "HUD text size", options = ["Small", "Normal", "Large", "Huge"], group = grpH)

// ───────────────────────────── Types & helpers ───────────────────────────────
type Level
    float price
    float value
    float strength
    int   born
    int   bornTime
    bool  above

var array<string> SZ = array.from(size.tiny, size.small, size.normal, size.large, size.huge)

sz(int i) =>
    SZ.get(math.max(0, math.min(4, i)))

txtSize(string s) =>
    switch s
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.huge

fmtVal(float v) =>
    string out = ""
    if valueMode == "Contracts"
        out := v >= 1e6 ? str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? str.tostring(v / 1e3, "#.#") + "K" : str.tostring(v, "#")
    else
        out := v >= 1e9 ? "$" + str.tostring(v / 1e9, "#.##") + "B" : v >= 1e6 ? "$" + str.tostring(v / 1e6, "#.##") + "M" : v >= 1e3 ? "$" + str.tostring(v / 1e3, "#.#") + "K" : "$" + str.tostring(v, "#")
    out

fmtPx(float p) =>
    str.tostring(p, format.mintick)

// Adds a level, or merges it into an existing same-side level within tolerance
addLevel(array<Level> arr, float px, float val, float strg, int born, int bornT, bool isAbove, float tol) =>
    bool merged = false
    if arr.size() > 0
        for i = 0 to arr.size() - 1
            Level lv = arr.get(i)
            if lv.above == isAbove and math.abs(lv.price - px) <= tol
                lv.price    := isAbove ? math.max(lv.price, px) : math.min(lv.price, px)
                lv.value    := lv.value + val
                lv.strength := lv.strength + strg
                lv.born     := math.min(lv.born, born)
                lv.bornTime := math.min(lv.bornTime, bornT)
                merged      := true
                break
    if not merged
        arr.push(Level.new(px, val, strg, born, bornT, isAbove))
    merged

hudPosition = switch hudPos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

// ───────────────────────────── Core calculations ─────────────────────────────
float vol      = nz(volume)
float barVal   = valueMode == "Contracts" ? vol : vol * hlc3 * syminfo.pointvalue
int   win      = pivLeft + pivRight + 1
float winVal   = math.sum(barVal, win)
float baseline = ta.sma(winVal, strengthLen)
float atr      = ta.atr(14)
float strNow   = baseline > 0 ? winVal / baseline : 1.0

float ph = ta.pivothigh(high, pivLeft, pivRight)
float pl = ta.pivotlow(low, pivLeft, pivRight)
int   pivTime = time[pivRight]

var array<Level> levels     = array.new<Level>()
var array<label> sweptMarks = array.new<label>()

// ───────────────────────────── Sweep / auto-delete ───────────────────────────
float upTest = sweepSrc == "Wick" ? high : close
float dnTest = sweepSrc == "Wick" ? low  : close

bool   sweptUp  = false
bool   sweptDn  = false
string sweptMsg = ""

if levels.size() > 0
    for i = levels.size() - 1 to 0
        Level lv  = levels.get(i)
        bool  hit = lv.above ? upTest > lv.price : dnTest < lv.price
        bool  old = maxAge > 0 and bar_index - lv.born > maxAge
        if hit
            if showSwept
                label m = label.new(bar_index, lv.price, "✕ SWEPT " + fmtVal(lv.value) + " @ " + fmtPx(lv.price), color = colPillBg, textcolor = colSwept, style = lv.above ? label.style_label_down : label.style_label_up, size = txtSize(pillSize), text_font_family = font.family_monospace)
                sweptMarks.push(m)
                if sweptMarks.size() > maxSwept
                    label.delete(sweptMarks.shift())
            if lv.strength >= alertMinStr
                if lv.above
                    sweptUp := true
                else
                    sweptDn := true
                sweptMsg += (lv.above ? "▲ " : "▼ ") + syminfo.ticker + " swept " + fmtVal(lv.value) + " @ " + fmtPx(lv.price) + "\n"
            levels.remove(i)
        else if old
            levels.remove(i)

// ───────────────────────────── New levels ────────────────────────────────────
float tol = nz(atr) * mergeATR
if not na(ph) and strNow >= minStrength
    addLevel(levels, ph, winVal, strNow, bar_index - pivRight, pivTime, true, tol)
if not na(pl) and strNow >= minStrength
    addLevel(levels, pl, winVal, strNow, bar_index - pivRight, pivTime, false, tol)

while levels.size() > maxStored
    levels.shift()

// ───────────────────────────── Alerts ────────────────────────────────────────
if sweptUp or sweptDn
    alert("Liquidity Orbs 3D [Neblok]\n" + sweptMsg, alert.freq_once_per_bar_close)

alertcondition(sweptUp, "Liquidity above swept", "Liquidity Orbs 3D [Neblok]: a level above price was swept")
alertcondition(sweptDn, "Liquidity below swept", "Liquidity Orbs 3D [Neblok]: a level below price was swept")

// ───────────────────────────── Drawing (last bar only) ───────────────────────
var array<label> orbLabels = array.new<label>()
var array<line>  orbLines  = array.new<line>()
var table        hud       = table.new(hudPosition, 2, 5, bgcolor = colPillBg, frame_color = colNear, frame_width = 2, border_color = color.new(colNear, 70), border_width = 1)

if barstate.islast
    for l in orbLabels
        label.delete(l)
    orbLabels.clear()
    for ln in orbLines
        line.delete(ln)
    orbLines.clear()

    // Split levels by side and sort by distance from price
    array<float> dA = array.new<float>()
    array<int>   iA = array.new<int>()
    array<float> dB = array.new<float>()
    array<int>   iB = array.new<int>()
    for [i, lv] in levels
        if lv.above
            dA.push(lv.price - close)
            iA.push(i)
        else
            dB.push(close - lv.price)
            iB.push(i)
    array<int> oA = dA.sort_indices(order.ascending)
    array<int> oB = dB.sort_indices(order.ascending)
    int nA = math.min(showAbove, oA.size())
    int nB = math.min(showBelow, oB.size())

    array<int>  showIdx  = array.new<int>()
    array<bool> showNear = array.new<bool>()
    if nA > 0
        for k = 0 to nA - 1
            showIdx.push(iA.get(oA.get(k)))
            showNear.push(k == 0)
    if nB > 0
        for k = 0 to nB - 1
            showIdx.push(iB.get(oB.get(k)))
            showNear.push(k == 0)

    float maxV = 0.0
    for idx in showIdx
        maxV := math.max(maxV, levels.get(idx).value)

    int   orbX = bar_index + orbOffset
    float lift = nz(atr) * specLiftATR
    bool  is3D = orbStyle == "3D"

    for [k, idx] in showIdx
        Level lv   = levels.get(idx)
        bool  near = showNear.get(k)
        color c    = lv.above ? colAbove : colBelow
        float r    = maxV > 0 ? lv.value / maxV : 0.5
        int   ci   = r >= 0.75 ? 3 : r >= 0.45 ? 2 : r >= 0.2 ? 1 : 0
        string tip = "Value: " + fmtVal(lv.value) + "\nPrice: " + fmtPx(lv.price) + "\nStrength: " + str.tostring(lv.strength, "#.#") + "× baseline\nAge: " + str.tostring(bar_index - lv.born) + " bars"

        // Level line
        // Level line: historical part is anchored by TIME (no bar-offset lookback,
        // so it can start any distance back), then a short bar_index segment
        // bridges the last bar to the orb in the future.
        if showLines
            color lnCol   = color.new(near ? colNear : c, near ? 0 : 45)
            int   lnWidth = near ? 2 : 1
            string lnSty  = near ? line.style_solid : line.style_dotted
            orbLines.push(line.new(lv.bornTime, lv.price, time, lv.price, xloc = xloc.bar_time, color = lnCol, width = lnWidth, style = lnSty))
            orbLines.push(line.new(bar_index, lv.price, orbX, lv.price, xloc = xloc.bar_index, color = lnCol, width = lnWidth, style = lnSty))

        // Outer ring: neon glow (3D) or cyan nearest ring
        if is3D or near
            orbLabels.push(label.new(orbX, lv.price, "", color = color.new(near ? colNear : c, near ? 25 : 75), style = label.style_circle, size = sz(ci + 1)))
        // Drop shadow (3D)
        if is3D
            orbLabels.push(label.new(orbX + 1, lv.price, "", color = color.new(#000000, 10), style = label.style_circle, size = sz(ci)))
        // Core orb
        orbLabels.push(label.new(orbX, lv.price, "", color = c, style = label.style_circle, size = sz(ci), tooltip = tip))
        // Specular highlight (3D, bigger orbs only)
        if is3D and ci >= 2
            orbLabels.push(label.new(orbX, lv.price + lift, "", color = color.new(#FFFFFF, 15), style = label.style_circle, size = sz(ci - 2)))

        // Value label
        if showPills
            string dist = showDist ? "  " + (lv.above ? "+" : "-") + fmtPx(math.abs(lv.price - close)) : ""
            string tag  = near ? (lv.above ? "▲ NEAREST  " : "▼ NEAREST  ") : ""
            string txt  = tag + fmtVal(lv.value) + " @ " + fmtPx(lv.price) + dist
            orbLabels.push(label.new(orbX + pillGap, lv.price, txt, color = colPillBg, textcolor = near ? colNear : c, style = label.style_label_left, size = txtSize(pillSize), text_font_family = font.family_monospace, tooltip = tip))

    // HUD
    if showHud
        float totA = 0.0
        float totB = 0.0
        for lv in levels
            if lv.above
                totA += lv.value
            else
                totB += lv.value
        string ts = txtSize(hudSize)

        string aTxt = "none"
        if nA > 0
            Level a = levels.get(iA.get(oA.get(0)))
            aTxt := fmtPx(a.price) + "  +" + fmtPx(a.price - close) + "  " + fmtVal(a.value)
        string bTxt = "none"
        if nB > 0
            Level b = levels.get(iB.get(oB.get(0)))
            bTxt := fmtPx(b.price) + "  -" + fmtPx(close - b.price) + "  " + fmtVal(b.value)

        float  tot     = totA + totB
        string bias    = tot > 0 ? (totA >= totB ? "▲ Above " + str.tostring(100 * totA / tot, "#") + "%" : "▼ Below " + str.tostring(100 * totB / tot, "#") + "%") : "n/a"
        color  biasCol = tot > 0 ? (totA >= totB ? colAbove : colBelow) : color.gray

        table.cell(hud, 0, 0, "LIQUIDITY ORBS 3D", text_color = colNear, text_size = ts, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(hud, 1, 0, "[Neblok]", text_color = colNear, text_size = ts, text_halign = text.align_right, text_font_family = font.family_monospace)
        table.cell(hud, 0, 1, "Nearest ▲", text_color = colAbove, text_size = ts, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(hud, 1, 1, aTxt, text_color = colAbove, text_size = ts, text_halign = text.align_right, text_font_family = font.family_monospace)
        table.cell(hud, 0, 2, "Nearest ▼", text_color = colBelow, text_size = ts, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(hud, 1, 2, bTxt, text_color = colBelow, text_size = ts, text_halign = text.align_right, text_font_family = font.family_monospace)
        table.cell(hud, 0, 3, "Pool ▲ / ▼", text_color = color.white, text_size = ts, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(hud, 1, 3, fmtVal(totA) + " / " + fmtVal(totB), text_color = color.white, text_size = ts, text_halign = text.align_right, text_font_family = font.family_monospace)
        table.cell(hud, 0, 4, "Heavier side", text_color = color.white, text_size = ts, text_halign = text.align_left, text_font_family = font.family_monospace)
        table.cell(hud, 1, 4, bias, text_color = biasCol, text_size = ts, text_halign = text.align_right, text_font_family = font.family_monospace)
````
