# Time Acceptance Profile TPO Levels

- url: https://www.tradingview.com/script/XaIXwQ3h-Time-Acceptance-Profile-TPO-Levels/
- type: indicator
- pine_id: PUB;fd0ada905a614247a8660ce12520f76c
- version: 1.0

## Description

TIME ACCEPTANCE PROFILE — TPO-STYLE LEVELS THAT WORK WITHOUT VOLUME

Volume profile tools fail on index spot charts — NIFTY, BANKNIFTY and SENSEX spot have no volume data at all. This indicator solves that by profiling TIME instead of volume: it counts how many bars touched each price bin during the session. Where price spent the most time is where the market found acceptance — and those levels act as the day's strongest reference points.

WHAT IT PLOTS

- Time POC — the price row with the highest time count today (gold line)
- Value Area (VAH / VAL) — the price band containing ~70% of today's time, expanded outward from the POC (teal box)
- Time Histogram — the full time-at-price distribution drawn to the right of price, POC row highlighted
- Prior-Day POC / VAH / VAL — yesterday's completed levels, frozen at the day close and extended across today (dashed)

HOW IT WORKS

1. The day's range is divided into N price bins (default 24)
2. Every bar adds one time-unit to each bin its high-low range touched
3. The bin with the maximum count = Time POC
4. The Value Area expands outward from the POC, adding the larger neighbouring bin until 70% of total time is covered
5. At the session change, the completed profile is frozen into prior-day levels — these never repaint

HOW TRADERS USE IT

- Prior-day POC acts as a magnet/pivot — rejections and reclaims there are high-information events
- Open outside yesterday's Value Area = imbalance day; watch for continuation away from value or a rotation back to Y-POC
- Open inside the Value Area = balance day; VAH/VAL rotation setups become relevant
- Thin rows in the histogram (low time) mark prices the market rejected — price tends to move quickly through them

NOTES

- Designed for intraday timeframes; shows a warning otherwise
- Today's POC and Value Area update as the session develops (by design); prior-day levels are fixed and never repaint
- Alerts are available on prior-day POC / VAH / VAL crosses — static levels only, alert-safe
- Price labels round to integers by default (toggle off for low-priced symbols)
- No volume data is used anywhere — works identically on spot indices, futures, stocks and crypto

This is an original implementation in Pine Script v6. The time-binning, POC selection and value-area expansion logic are fully described above.

Educational tool for market context — not financial advice.

## Source Code

````pine
//@version=6
// ─────────────────────────────────────────────────────────────────────────────
// Time Acceptance Profile — TPO Levels (No Volume Needed)  🦚
// Builds a time-at-price profile for the current session. Where price SPENT
// the most time = acceptance (Time POC + Value Area). Works on index spot
// charts (NIFTY / BANKNIFTY / SENSEX) where volume-based profiles fail.
// Confirmed bars only · no lookahead · no repaint of completed-day levels.
// ─────────────────────────────────────────────────────────────────────────────
indicator("Time Acceptance Profile — TPO Levels (No Volume Needed)", shorttitle = "TAP 🦚", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 100)

// ── Inputs ───────────────────────────────────────────────────────────────────
grpP = "Profile"
binsInp   = input.int(24,   "Price Bins (Rows)",          minval = 8,  maxval = 50,  group = grpP)
vaPct     = input.float(70.0, "Value Area %",             minval = 50, maxval = 95, step = 5.0, group = grpP)
showHist  = input.bool(true, "Show Time Histogram",       group = grpP)
histWidth = input.int(30,   "Histogram Max Width (bars)", minval = 10, maxval = 100, group = grpP)

grpL = "Levels"
showToday = input.bool(true, "Today: Time POC + Value Area",  group = grpL)
showPrior = input.bool(true, "Prior Day: POC / VAH / VAL",    group = grpL)
roundInt  = input.bool(true, "Round Prices To Integers",      group = grpL)

grpS = "Style"
colPOC   = input.color(color.new(#FFD54F, 0),  "Today POC",        group = grpS)
colVA    = input.color(color.new(#26A69A, 82), "Value Area Fill",  group = grpS)
colVAln  = input.color(color.new(#26A69A, 25), "Value Area Border",group = grpS)
colHist  = input.color(color.new(#5C6BC0, 65), "Histogram",        group = grpS)
colHistP = input.color(color.new(#FFD54F, 35), "Histogram POC Row",group = grpS)
colPrior = input.color(color.new(#FF8A65, 0),  "Prior Day Levels", group = grpS)

// ── Helpers ──────────────────────────────────────────────────────────────────
f_px(float p) =>
    roundInt ? str.tostring(math.round(p)) : str.tostring(p, format.mintick)

// Time-at-price profile from arrays of bar highs/lows.
// Returns [poc, vah, val, counts, dayLo, dayHi]
f_profile(array<float> his, array<float> los, int nBins, float vaP) =>
    float poc = na
    float vah = na
    float val = na
    float dLo = na
    float dHi = na
    array<int> counts = array.new<int>()
    int n = array.size(his)
    if n > 0
        dHi := array.max(his)
        dLo := array.min(los)
        float rng = dHi - dLo
        if rng > 0
            float bs = rng / nBins
            counts := array.new<int>(nBins, 0)
            // count: each bar adds +1 time-unit to every bin its range touched
            for i = 0 to n - 1
                float bh = array.get(his, i)
                float bl = array.get(los, i)
                int b1 = math.max(0, math.min(nBins - 1, int(math.floor((bl - dLo) / bs))))
                int b2 = math.max(0, math.min(nBins - 1, int(math.floor((bh - dLo) / bs))))
                for b = b1 to b2
                    array.set(counts, b, array.get(counts, b) + 1)
            // Time POC = bin with max time count
            int pocIdx = 0
            int mx = -1
            int total = 0
            for b = 0 to nBins - 1
                int c = array.get(counts, b)
                total += c
                if c > mx
                    mx := c
                    pocIdx := b
            // Value Area: expand from POC, add the larger neighbour side
            int target = int(math.ceil(total * vaP / 100.0))
            int acc = mx
            int up = pocIdx + 1
            int dn = pocIdx - 1
            while acc < target and (up < nBins or dn >= 0)
                int cu = -1
                int cd = -1
                if up < nBins
                    cu := array.get(counts, up)
                if dn >= 0
                    cd := array.get(counts, dn)
                if cu >= cd
                    acc += cu
                    up  += 1
                else
                    acc += cd
                    dn  -= 1
            poc := dLo + (pocIdx + 0.5) * bs
            vah := dLo + up * bs
            val := dLo + (dn + 1) * bs
    [poc, vah, val, counts, dLo, dHi]

// ── Session data ─────────────────────────────────────────────────────────────
var array<float> hiArr = array.new<float>()
var array<float> loArr = array.new<float>()

var float pPOC = na   // prior-day levels (frozen at day close — never repaint)
var float pVAH = na
var float pVAL = na

bool newDay = timeframe.change("D")

// On the first bar of a new day, arrays still hold yesterday's bars:
// freeze yesterday's profile into prior-day levels, then reset.
if newDay and timeframe.isintraday
    [pp, pvh, pvl, _c, _l, _h] = f_profile(hiArr, loArr, binsInp, vaPct)
    pPOC := pp
    pVAH := pvh
    pVAL := pvl
    array.clear(hiArr)
    array.clear(loArr)

if timeframe.isintraday
    array.push(hiArr, high)
    array.push(loArr, low)

// ── Alerts (prior-day levels only — static, alert-safe) ─────────────────────
bool xPOC = ta.cross(close, pPOC)
bool xVAH = ta.cross(close, pVAH)
bool xVAL = ta.cross(close, pVAL)
alertcondition(xPOC, "Cross Prior-Day Time POC", "Price crossed prior-day Time POC")
alertcondition(xVAH, "Cross Prior-Day VAH",      "Price crossed prior-day Value Area High")
alertcondition(xVAL, "Cross Prior-Day VAL",      "Price crossed prior-day Value Area Low")

// ── Drawings (today only, rebuilt on last bar) ──────────────────────────────
var array<box>   bxs = array.new<box>()
var array<line>  lns = array.new<line>()
var array<label> lbs = array.new<label>()

if barstate.islast and timeframe.isintraday
    // wipe previous frame
    for b in bxs
        box.delete(b)
    array.clear(bxs)
    for l in lns
        line.delete(l)
    array.clear(lns)
    for lb in lbs
        label.delete(lb)
    array.clear(lbs)

    [poc, vah, val, counts, dLo, dHi] = f_profile(hiArr, loArr, binsInp, vaPct)
    int n        = array.size(hiArr)
    int startBar = bar_index - n + 1
    int rEdge    = bar_index + 1 + histWidth

    if not na(poc)
        float bs     = (dHi - dLo) / binsInp
        int   pocIdx = math.max(0, math.min(binsInp - 1, int(math.floor((poc - dLo) / bs))))
        int   maxCnt = array.get(counts, pocIdx)

        // ── Time histogram (right side of price)
        if showHist and maxCnt > 0
            for b = 0 to binsInp - 1
                int c = array.get(counts, b)
                if c > 0
                    int wd = math.max(1, math.round(c / maxCnt * histWidth))
                    array.push(bxs, box.new(bar_index + 1, dLo + (b + 1) * bs, bar_index + 1 + wd, dLo + b * bs, border_color = na, bgcolor = b == pocIdx ? colHistP : colHist))

        // ── Today's POC + Value Area
        if showToday
            array.push(bxs, box.new(startBar, vah, rEdge, val, border_color = colVAln, border_style = line.style_dotted, bgcolor = colVA))
            array.push(lns, line.new(startBar, poc, rEdge, poc, color = colPOC, width = 2))
            array.push(lbs, label.new(rEdge, poc, "T-POC " + f_px(poc), style = label.style_label_left, color = color.new(color.black, 100), textcolor = colPOC, size = size.small))
            array.push(lbs, label.new(rEdge, vah, "VAH " + f_px(vah),   style = label.style_label_left, color = color.new(color.black, 100), textcolor = colVAln, size = size.small))
            array.push(lbs, label.new(rEdge, val, "VAL " + f_px(val),   style = label.style_label_left, color = color.new(color.black, 100), textcolor = colVAln, size = size.small))

    // ── Prior-day frozen levels (extended across today)
    if showPrior and not na(pPOC)
        array.push(lns, line.new(startBar, pPOC, rEdge, pPOC, color = colPrior, width = 1, style = line.style_dashed))
        array.push(lns, line.new(startBar, pVAH, rEdge, pVAH, color = color.new(colPrior, 40), width = 1, style = line.style_dotted))
        array.push(lns, line.new(startBar, pVAL, rEdge, pVAL, color = color.new(colPrior, 40), width = 1, style = line.style_dotted))
        array.push(lbs, label.new(rEdge, pPOC, "Y-POC " + f_px(pPOC), style = label.style_label_left, color = color.new(color.black, 100), textcolor = colPrior, size = size.small))
        array.push(lbs, label.new(rEdge, pVAH, "Y-VAH " + f_px(pVAH), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(colPrior, 30), size = size.small))
        array.push(lbs, label.new(rEdge, pVAL, "Y-VAL " + f_px(pVAL), style = label.style_label_left, color = color.new(color.black, 100), textcolor = color.new(colPrior, 30), size = size.small))

// ── Timeframe guard ──────────────────────────────────────────────────────────
var label warnLb = na
if barstate.islast and not timeframe.isintraday
    if na(warnLb)
        warnLb := label.new(bar_index, close, "TAP works on intraday timeframes only", style = label.style_label_left, color = color.new(color.red, 70), textcolor = color.white)
    label.set_xy(warnLb, bar_index, close)
````
