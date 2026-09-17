<!-- tradingview-pine-id: PUB;a62681ec9d914750b59ab107cd7cf7d8 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Delta by Price [SVP Style]

Source: https://www.tradingview.com/script/pFBYCDUA-Delta-by-Price-SVP-Style/

## Description

🔹 Introduction

This indicator, "Delta by Price", builds a session volume profile where each row shows net signed volume — estimated buying pressure minus estimated selling pressure — instead of total volume traded.

The idea is straightforward. A standard volume profile tells you where the market spent its activity. It cannot tell you who won at those prices. Two rows with identical volume can mean completely opposite things: one where aggressive buyers lifted offers and price left immediately, and one where aggressive buyers hit a wall of resting supply and went nowhere. Total volume is blind to the difference. Net delta is not.

Here is the honest part, stated up front: true delta requires knowing whether each trade executed at the bid or the ask, and TradingView does not expose that data to Pine. Every delta figure this script produces is an estimate derived from intrabar price direction. That estimate is defensible — it is essentially the tick rule, one of the oldest and best-studied trade classification methods in market microstructure — but it is an estimate, and I will be specific throughout about where it degrades.

🔹 The Premise

🔸 Every trade has two sides, but only one initiator

A trade happens when someone crosses the spread. A resting limit order sits passively; a market order comes and takes it. Both parties transact the same volume, but only one of them demanded immediacy. That asymmetry is the entire foundation of order flow analysis.

Delta is the running count of who demanded immediacy. If 10,000 contracts trade at a price and 7,000 of them were buyers lifting offers, delta at that price is +4,000. The other 3,000 buyers were filled passively by sellers who came to them.

Why does this matter? Because aggression that produces movement and aggression that produces nothing are two very different market states.

🔸 A worked example

Assume ES is trading at 5,000.00 and rotating into yesterday's value area low at 4,992.00.

Price arrives at 4,992.00. Over the next fifteen minutes, 40,000 contracts trade in a two-point band around that level. Delta over that window is −22,000 — heavily seller-initiated. Aggressive sellers are hitting the bid relentlessly.

Now ask the only question that matters: where is price?

Case one: price is at 4,986.00. Sellers pressed, and price gave way. The imbalance produced displacement. The level failed. Delta and price agree.

Case two: price is at 4,992.50. Sellers pressed 22,000 contracts of net aggression into that level and price is half a point higher than where they started. Every one of those market sell orders was filled by a passive buyer who was willing to stand there and take the other side. Nobody absorbs 22,000 contracts by accident.

The second case is the interesting one, and total volume cannot see it at all. Both cases print 40,000 contracts at 4,992.00. The volume profile draws an identical row. Only the sign and size of the delta, held against price's failure to move, separates a level that broke from a level that held.

This is the phenomenon usually called absorption, and it is the reason a delta profile exists.

🔸 Why the row matters more than the bar

Most delta tooling on TradingView plots delta per bar — one number per five-minute candle, or a cumulative line. That is useful, but it throws away the location information.

Consider a five-minute bar with a total delta of +200. Unremarkable. Now decompose it: +3,000 of net buying concentrated in the bottom three ticks of the bar's range, and −2,800 spread across the top. That is not a neutral bar. That is buyers being aggressive at the low and sellers being aggressive at the high — a violently two-sided bar that nets to nearly nothing.

Aggregating delta to the bar destroys exactly the information that makes delta actionable, because the level is the whole point. Order flow that is not anchored to a price you care about is noise. Order flow at a mapped level — a value area edge, a prior day's POC, an untested gap — is context.

Delta by Price exists to put the imbalance back where it happened.

🔸 What the research actually says about inferring direction from price

Since the classification is inferred rather than observed, it is worth knowing how good the inference is. This is well-studied.

Lee and Ready (1991) introduced the standard framework for classifying trades as buyer- or seller-initiated when the initiator is not recorded in the data. Ellis, Michaely, and O'Hara (2000) then tested those methods against a proprietary Nasdaq dataset that did record the true initiator, and found the quote rule, the tick rule, and the Lee-Ready rule correctly classified 76.4%, 77.66%, and 81.05% of trades respectively. Finucane (2000), testing the same question independently, found the tick test performed roughly as well as the more elaborate Lee-Ready algorithm — and that both performed worse than researchers had assumed.

So the tick rule lands somewhere in the mid-to-high seventies for accuracy on equities. Not exact. Not noise either.

There is a more pointed finding for futures traders. Andersen and Bondarenko (2015) constructed an accurate trade classification benchmark specifically for E-mini S&P 500 futures, using quote and trade data, and compared it against the bulk-volume classification scheme of Easley, López de Prado, and O'Hara (2012). Two results are relevant here. First, the simple tick rule outperformed bulk-volume classification. Second — and this is the part worth internalizing — rising volatility systematically induces classification errors.

Read that again, because it is the single most important limitation of this tool. The delta estimate is least reliable precisely during the fast, volatile, high-participation moments you most want to read. No amount of code fixes this. It is a property of inferring intent from price when price is moving quickly.

And separately, order imbalance is not a curiosity — it is a documented driver of returns. Chordia, Roll, and Subrahmanyam (2002) found market-wide returns are strongly affected by contemporaneous and lagged order imbalance, and that returns reverse after large negative-imbalance days. Chordia and Subrahmanyam (2004) extended the result to individual names. Chan and Fong (2000) tied order imbalance directly to the volatility-volume relation.

The concept is sound and the measurement is approximate. Both of those things are true at once, and the second one is why this indicator is built as a context tool rather than a signal generator.

🔹 How It Works

🔸 Estimating delta

Show Image

The script requests lower-timeframe OHLCV data for every chart bar — automatically selecting 1-second intrabars on a seconds chart, 1-minute on intraday, and so on, or a timeframe you specify.

Each intrabar is classified by the tick rule: close above open, its volume counts as buy-initiated; close below open, sell-initiated; unchanged, discarded. That signed volume is then dropped into the price row containing the intrabar's close.

There are limitations and assumptions here. The classification is per intrabar, not per trade — a one-minute intrabar containing 4,000 contracts is treated as one directional unit, when in reality it contained thousands of individually classifiable transactions. And the entire intrabar's volume is assigned to a single row, even though the intrabar had a range. On a violent one-minute bar spanning fifteen ticks, that is a real distortion.

Choosing a finer lower timeframe reduces both problems — 1-second intrabars classify and locate far more precisely than 1-minute. The tradeoff is history: finer intrabars exhaust TradingView's intrabar data budget faster, so the profile reaches back over fewer sessions. That is the trade you are making with that setting, and it is worth making deliberately.

🔸 Tick-based rows

Most profile scripts ask for a row count and divide the range by it. That means the row height changes every session — a 40-point day and a 90-point day produce rows of different sizes, and a row never covers the same prices twice.

This one asks for a row size in ticks, and rows sit on a fixed grid anchored to the instrument's tick size. A 4-tick row on ES always spans the same four ticks, session after session. Profiles become directly comparable across days, and rows line up with the price levels you actually mark.

The constraint is Pine's 500-drawing-object ceiling, shared across every profile on screen. The script computes a per-session row budget, and if a session's range needs more rows than its budget allows, rows are merged automatically and the effective size is displayed in the stats table. Nothing is silently dropped — you are told when the resolution you asked for was not available. Fewer sessions displayed means a larger budget each and finer rows.

🔸 Multi-session profiles

Show Image

Each completed session is drawn once at its own anchor and frozen; the developing session redraws live on every tick. Closed sessions are faded so the current one reads clearly against its history, and profile width scales to each session's own bar span.

One structural limitation: historical profiles are constructed bar-by-bar as the script executes, which means they exist only for sessions inside the chart's loaded history. Scroll back far enough and they stop. TradingView's own Session Volume Profile behaves identically — it is a property of the platform, not a defect in the implementation.

🔸 POC and Value Area

The point of control marks the row with the highest concentration, and the value area expands outward from it until the chosen percentage of the session's activity is enclosed — the conventional 70% by default, which comes from treating the distribution as roughly normal and taking one standard deviation.

The POC / VA Source toggle is the interesting setting, and it changes what question the profile answers.

Set to Volume, POC and value area are computed on total volume. This reproduces a conventional volume profile's levels — the prices with the most transaction activity, the ones most traders are watching, the ones that function as reference points precisely because they are widely observed.

Set to Absolute Delta, POC and value area are computed on the magnitude of net imbalance instead. Now the POC marks the price with the largest one-sided commitment, which is not necessarily the price with the most volume. A row can carry enormous volume and near-zero delta — that is two-sided churn, and a volume POC will flag it while a delta POC will not.

When those two levels sit far apart, the session had heavy activity somewhere the participants were evenly matched, and heavy commitment somewhere else. That gap is often more informative than either level alone.

🔸 Reading it

Row length is the magnitude of net imbalance at that price; color is the sign. Long teal rows are net buying, long red rows are net selling, short rows are balance.

A few configurations worth recognising:

Large delta with no displacement. A long row at an extreme of the session, where price then reversed. The aggression was absorbed by passive size. This is the absorption signature from the worked example above.

Large delta with displacement. A long row that price left immediately and did not revisit. The aggression was rewarded — closer to initiative than absorption.

Delta sign flipping at a value area edge. Price retests the edge and the rows there change color from the prior test. Something about who is defending that level changed.

A stack of same-color rows away from the POC. Sustained one-sided commitment away from the balance area — usually where a trend leg was built.

None of these are signals. They are descriptions of what happened at a price, and they are only worth anything when the price already mattered to you before you looked at the profile. A large delta row in the middle of a featureless range is a statistic. The same row at yesterday's value area low, on a retest, in a session where you already had a directional thesis, is context.

🔹 Closing Remarks

Volume tells you where the market was busy. Delta attempts to tell you who was demanding immediacy while it was busy there — and the disagreement between heavy aggression and absent movement is one of the more reliable tells that passive size is defending a price.

That said, everything here rests on an inference. The classification is the tick rule applied to intrabar candles, not observed bid/ask execution data, and the research is clear that this approach is right somewhere in the high seventies percent of the time on individual trades and gets worse as volatility rises. Volume is assigned to rows at intrabar closes rather than at the price of each transaction. Row resolution is bounded by a hard platform limit.

Treat every level this draws as a probabilistic reading of what likely happened, not a record of what did. Large delta clusters do not guarantee that a level will hold, and a POC is not a magnet. Used as a layer of context over levels you mapped independently — and ignored when the profile disagrees with the rest of your read — it earns its place on the chart. Used as a standalone entry trigger, it will disappoint you, and the research above explains exactly why.

If you find configurations that read well on your instrument, or edge cases where the estimate breaks down in an interesting way, I would like to hear about them.

🔹 References

Trade classification and its accuracy

Lee, C. M. C., & Ready, M. J. (1991). Inferring Trade Direction from Intraday Data. The Journal of Finance, 46(2), 733–746.

Ellis, K., Michaely, R., & O'Hara, M. (2000). The Accuracy of Trade Classification Rules: Evidence from Nasdaq. Journal of Financial and Quantitative Analysis, 35(4), 529–551.

Finucane, T. J. (2000). A Direct Test of Methods for Inferring Trade Direction from Intra-Day Data. Journal of Financial and Quantitative Analysis, 35(4), 553–576.

Order flow classification in futures markets

Easley, D., López de Prado, M. M., & O'Hara, M. (2012). Flow Toxicity and Liquidity in a High-Frequency World. The Review of Financial Studies, 25(5), 1457–1493.

Andersen, T. G., & Bondarenko, O. (2015). Assessing Measures of Order Flow Toxicity and Early Warning Signals for Market Turbulence. Review of Finance, 19(1), 1–54.

Order imbalance and returns

Chordia, T., Roll, R., & Subrahmanyam, A. (2002). Order imbalance, liquidity, and market returns. Journal of Financial Economics, 65(1), 111–130.

Chordia, T., & Subrahmanyam, A. (2004). Order imbalance and individual stock returns: Theory and evidence. Journal of Financial Economics, 72(3), 485–518.

Chan, K., & Fong, W.-M. (2000). Trade size, order imbalance, and the volatility-volume relation. Journal of Financial Economics, 57(2), 247–273.

---

## Source Code

````pine
//@version=6
indicator("Delta by Price [SVP Style]", "Delta by Price", overlay = true, max_bars_back = 500, max_boxes_count = 500, max_lines_count = 100, max_labels_count = 20)

// ═══════════════════════════════════════════════════════════════════════
//  Inputs
// ═══════════════════════════════════════════════════════════════════════
gP = "Profile"
modeInput    = input.string("Session", "Profile Range", options = ["Session", "Rolling Lookback"], group = gP)
sessionInput = input.session("0000-0000", "Session Time (Session mode)", group = gP)
sessionsShow = input.int(5, "Sessions to Show", minval = 1, maxval = 20, group = gP, tooltip = "Includes the developing session. More sessions means fewer rows available per profile (500 box limit is shared).")
lookback     = input.int(250, "Lookback Bars (Rolling mode)", minval = 10, maxval = 1000, group = gP)
rowTicks     = input.int(4, "Row Size (ticks)", minval = 1, maxval = 500, group = gP, tooltip = "Height of each profile row in ticks. If a session's range needs more rows than its box budget allows, rows are auto-merged and the effective size is shown in the stats table.")
useCustomTF  = input.bool(false, "Use custom LTF for delta", group = gP, tooltip = "By default an appropriate lower timeframe is selected automatically.")
customTF     = input.timeframe("1", "Custom LTF", active = useCustomTF, group = gP)

gL = "Layout"
anchorInput = input.string("Session Start (SVP)", "Profile Anchor", options = ["Session Start (SVP)", "Right of Last Bar"], group = gL, tooltip = "Right of Last Bar draws only the developing profile — historical sessions would stack on top of each other.")
widthPct    = input.float(30, "Profile Width (% of session)", minval = 5, maxval = 100, step = 5, group = gL)
widthBars   = input.int(40, "Profile Width (bars)", minval = 5, maxval = 200, group = gL, tooltip = "Used when anchored right of the last bar.")
rowGapPct   = input.float(12, "Row Gap (%)", minval = 0, maxval = 60, step = 2, group = gL)

gV = "Value Area & POC"
pocSource   = input.string("Volume", "POC / VA Source", options = ["Volume", "Absolute Delta"], group = gV)
showVA      = input.bool(true, "Highlight Value Area", group = gV)
vaPct       = input.float(70, "Value Area (%)", minval = 30, maxval = 95, step = 5, group = gV)
showPOC     = input.bool(true, "Show POC Line", group = gV)
showVALines = input.bool(true, "Show VAH / VAL Lines", group = gV)
extendLines = input.bool(true, "Extend Developing Lines to Current Bar", group = gV)
showLabels  = input.bool(true, "Show Level Labels (developing session only)", group = gV)

gS = "Style"
posDeltaColor = input.color(#26a69a, "Positive Delta", group = gS)
negDeltaColor = input.color(#ef5350, "Negative Delta", group = gS)
vaTransp      = input.int(25, "Value Area Transparency", minval = 0, maxval = 95, group = gS)
outTransp     = input.int(65, "Outside VA Transparency", minval = 0, maxval = 95, group = gS)
histFade      = input.int(20, "Extra Fade on Closed Sessions", minval = 0, maxval = 70, group = gS, tooltip = "Added to both transparency values for completed sessions so the developing profile stands out.")
pocColor      = input.color(#ff9800, "POC Color", group = gS)
vaLineColor   = input.color(#787b86, "VAH / VAL Color", group = gS)
showStats     = input.bool(true, "Show Stats Table", group = gS)

// ═══════════════════════════════════════════════════════════════════════
//  Grid + budgets
// ═══════════════════════════════════════════════════════════════════════
binSize   = rowTicks * syminfo.mintick
oneOnly   = anchorInput == "Right of Last Bar"
nProfiles = oneOnly or modeInput != "Session" ? 1 : sessionsShow
rowBudget = math.max(15, int(490 / nProfiles))
maxFinal  = oneOnly or modeInput != "Session" ? 0 : sessionsShow - 1

var table statsTbl = table.new(position.top_right, 2, 5, bgcolor = color.new(color.black, 20), border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 60), frame_width = 1)

// ═══════════════════════════════════════════════════════════════════════
//  Lower timeframe data
// ═══════════════════════════════════════════════════════════════════════
lowerTimeframe = switch
    useCustomTF          => customTF
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

ltfClose  = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, close)
ltfOpen   = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, open)
ltfVolume = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, volume)

// ═══════════════════════════════════════════════════════════════════════
//  Types
// ═══════════════════════════════════════════════════════════════════════
type BarBins
    array<int>   bins
    array<float> dlt
    array<float> vol

type Drawn
    array<box>   boxes
    array<line>  lines
    array<label> labels

newDrawn() => Drawn.new(array.new<box>(), array.new<line>(), array.new<label>())

clearDrawn(Drawn d) =>
    if not na(d)
        for bx in d.boxes
            box.delete(bx)
        for ln in d.lines
            line.delete(ln)
        for lb in d.labels
            label.delete(lb)
        array.clear(d.boxes)
        array.clear(d.lines)
        array.clear(d.labels)

// ═══════════════════════════════════════════════════════════════════════
//  Per-bar binning — each intrabar's signed volume lands in the row that
//  holds its close (no smearing across the bar's range)
// ═══════════════════════════════════════════════════════════════════════
buildBins() =>
    BarBins b = BarBins.new(array.new<int>(), array.new<float>(), array.new<float>())
    int nLtf = array.size(ltfClose)
    if nLtf > 0
        for i = 0 to nLtf - 1
            c = array.get(ltfClose, i)
            o = array.get(ltfOpen, i)
            v = array.get(ltfVolume, i)
            if not na(c) and not na(o) and not na(v)
                int idx = int(math.floor(c / binSize))
                float d = c > o ? v : c < o ? -v : 0.0
                int p = array.indexof(b.bins, idx)
                if p == -1
                    array.push(b.bins, idx)
                    array.push(b.dlt, d)
                    array.push(b.vol, v)
                else
                    array.set(b.dlt, p, array.get(b.dlt, p) + d)
                    array.set(b.vol, p, array.get(b.vol, p) + v)
    else if not na(volume)
        array.push(b.bins, int(math.floor(close / binSize)))
        array.push(b.dlt, close > open ? volume : close < open ? -volume : 0.0)
        array.push(b.vol, volume)
    b

mergeBins(map<int, float> mD, map<int, float> mV, BarBins b) =>
    int nb = array.size(b.bins)
    if nb > 0
        for i = 0 to nb - 1
            int k = array.get(b.bins, i)
            map.put(mD, k, (map.contains(mD, k) ? map.get(mD, k) : 0.0) + array.get(b.dlt, i))
            map.put(mV, k, (map.contains(mV, k) ? map.get(mV, k) : 0.0) + array.get(b.vol, i))

// ═══════════════════════════════════════════════════════════════════════
//  Profile renderer — one aggregated map pair in, one Drawn out
// ═══════════════════════════════════════════════════════════════════════
drawProfile(map<int, float> mD, map<int, float> mV, int anchorBI, int endBI, int budget, bool isDev, int nBars) =>
    Drawn out = newDrawn()
    array<int> keys = map.keys(mD)
    if array.size(keys) > 0 and not na(anchorBI)
        int minIdx  = int(array.min(keys))
        int maxIdx  = int(array.max(keys))
        int rawRows = maxIdx - minIdx + 1
        int grp     = math.max(1, int(math.ceil(rawRows / float(budget))))
        int rows    = math.max(1, int(math.ceil(rawRows / float(grp))))

        array<float> dRow = array.new<float>(rows, 0.0)
        array<float> vRow = array.new<float>(rows, 0.0)
        for k in keys
            int r = math.max(0, math.min(rows - 1, int(math.floor((k - minIdx) / float(grp)))))
            array.set(dRow, r, array.get(dRow, r) + map.get(mD, k))
            array.set(vRow, r, array.get(vRow, r) + map.get(mV, k))

        // POC / VA source
        array<float> srcRow = array.new<float>(rows, 0.0)
        float totalSrc = 0.0
        float totalDlt = 0.0
        float maxAbsD  = 0.0
        int   pocRow   = 0
        float pocVal   = -1.0
        for r = 0 to rows - 1
            float dv = array.get(dRow, r)
            float sv = pocSource == "Volume" ? array.get(vRow, r) : math.abs(dv)
            array.set(srcRow, r, sv)
            totalSrc += sv
            totalDlt += dv
            maxAbsD  := math.max(maxAbsD, math.abs(dv))
            if sv > pocVal
                pocVal := sv
                pocRow := r

        // Value area expansion from POC
        int vaUp = rows - 1
        int vaDn = 0
        if showVA and totalSrc > 0
            vaUp := pocRow
            vaDn := pocRow
            float acc    = array.get(srcRow, pocRow)
            float target = totalSrc * vaPct / 100.0
            for i = 0 to rows * 2
                if acc >= target or (vaUp >= rows - 1 and vaDn <= 0)
                    break
                float upV = vaUp < rows - 1 ? array.get(srcRow, vaUp + 1) : -1.0
                float dnV = vaDn > 0 ? array.get(srcRow, vaDn - 1) : -1.0
                if upV >= dnV
                    vaUp += 1
                    acc  += upV
                else
                    vaDn -= 1
                    acc  += dnV

        // Placement
        int leftX   = 0
        int widthPx = 0
        if oneOnly
            widthPx := widthBars
            leftX   := bar_index + 2
        else
            int span = math.max(1, endBI - anchorBI)
            widthPx := math.max(3, int(math.round(span * widthPct / 100.0)))
            leftX   := anchorBI

        float rowH  = grp * binSize
        float gap   = rowH * rowGapPct / 200.0
        int   fade  = isDev ? 0 : histFade
        int   tIn   = math.min(95, vaTransp + fade)
        int   tOut  = math.min(95, outTransp + fade)

        for r = 0 to rows - 1
            float d = array.get(dRow, r)
            if d != 0 and maxAbsD > 0
                int len = math.max(1, int(math.round(math.abs(d) / maxAbsD * widthPx)))
                bool inVA = r >= vaDn and r <= vaUp
                color col = color.new(d > 0 ? posDeltaColor : negDeltaColor, inVA ? tIn : tOut)
                float rowLo = (minIdx + r * grp) * binSize
                array.push(out.boxes, box.new(leftX, rowLo + rowH - gap, leftX + len, rowLo + gap, border_color = color.new(color.black, 100), border_width = 0, bgcolor = col))

        // POC / VAH / VAL
        int rightX = isDev and extendLines and not oneOnly ? math.max(bar_index, leftX + widthPx) : oneOnly ? leftX + widthPx : math.max(endBI, leftX + widthPx)

        float pocPrice = (minIdx + pocRow * grp) * binSize + rowH / 2.0
        float vahPrice = (minIdx + vaUp * grp) * binSize + rowH
        float valPrice = (minIdx + vaDn * grp) * binSize

        if showPOC
            array.push(out.lines, line.new(leftX, pocPrice, rightX, pocPrice, xloc.bar_index, extend.none, color.new(pocColor, fade), line.style_solid, 2))
            if showLabels and isDev
                array.push(out.labels, label.new(rightX, pocPrice, "POC " + str.tostring(pocPrice, format.mintick), xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, pocColor, size.small))

        if showVALines and showVA
            array.push(out.lines, line.new(leftX, vahPrice, rightX, vahPrice, xloc.bar_index, extend.none, color.new(vaLineColor, fade), line.style_dashed, 1))
            array.push(out.lines, line.new(leftX, valPrice, rightX, valPrice, xloc.bar_index, extend.none, color.new(vaLineColor, fade), line.style_dashed, 1))
            if showLabels and isDev
                array.push(out.labels, label.new(rightX, vahPrice, "VAH " + str.tostring(vahPrice, format.mintick), xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, vaLineColor, size.small))
                array.push(out.labels, label.new(rightX, valPrice, "VAL " + str.tostring(valPrice, format.mintick), xloc.bar_index, yloc.price, color.new(color.black, 100), label.style_label_left, vaLineColor, size.small))

        // Stats (developing profile only)
        if showStats and isDev
            table.cell(statsTbl, 0, 0, "Total Δ", text_color = color.silver, text_size = size.small)
            table.cell(statsTbl, 1, 0, str.tostring(totalDlt, format.volume), text_color = totalDlt >= 0 ? posDeltaColor : negDeltaColor, text_size = size.small)
            table.cell(statsTbl, 0, 1, "POC", text_color = color.silver, text_size = size.small)
            table.cell(statsTbl, 1, 1, str.tostring(pocPrice, format.mintick), text_color = pocColor, text_size = size.small)
            table.cell(statsTbl, 0, 2, "VAH / VAL", text_color = color.silver, text_size = size.small)
            table.cell(statsTbl, 1, 2, str.tostring(vahPrice, format.mintick) + " / " + str.tostring(valPrice, format.mintick), text_color = color.white, text_size = size.small)
            table.cell(statsTbl, 0, 3, "Row Size", text_color = color.silver, text_size = size.small)
            table.cell(statsTbl, 1, 3, str.tostring(rowTicks * grp) + (rowTicks * grp == 1 ? " tick" : " ticks") + (grp > 1 ? " (auto)" : ""), text_color = grp > 1 ? color.orange : color.white, text_size = size.small)
            table.cell(statsTbl, 0, 4, "Rows / Bars", text_color = color.silver, text_size = size.small)
            table.cell(statsTbl, 1, 4, str.tostring(rows) + " / " + str.tostring(nBars), text_color = color.white, text_size = size.small)
    out

// ═══════════════════════════════════════════════════════════════════════
//  Session accumulation
// ═══════════════════════════════════════════════════════════════════════
inSession    = not na(time(timeframe.period, sessionInput))
sessionStart = inSession and not inSession[1]

var map<int, float> sessD = map.new<int, float>()
var map<int, float> sessV = map.new<int, float>()
var int sessStartBI = na
var int sessEndBI   = na
var int sessBars    = 0

var array<Drawn> finished = array.new<Drawn>()
var Drawn devDrawn = na

// Rolling-mode history
var array<BarBins> hist   = array.new<BarBins>()
var int            lastBI = na

if modeInput == "Session"
    // A new session begins → the previous one is complete, freeze its drawing
    if sessionStart
        if map.size(sessD) > 0 and maxFinal > 0
            array.push(finished, drawProfile(sessD, sessV, sessStartBI, sessEndBI, rowBudget, false, sessBars))
            if array.size(finished) > maxFinal
                clearDrawn(array.shift(finished))
        map.clear(sessD)
        map.clear(sessV)
        sessStartBI := bar_index
        sessEndBI   := bar_index
        sessBars    := 0
    if inSession and barstate.isconfirmed
        mergeBins(sessD, sessV, buildBins())
        sessEndBI := bar_index
        sessBars  += 1
        if na(sessStartBI)
            sessStartBI := bar_index
else
    BarBins rb = buildBins()
    if na(lastBI) or lastBI != bar_index
        array.push(hist, rb)
        lastBI := bar_index
    else
        array.set(hist, array.size(hist) - 1, rb)
    if array.size(hist) > lookback
        array.shift(hist)

// ═══════════════════════════════════════════════════════════════════════
//  Developing profile — redrawn on every tick of the last bar
// ═══════════════════════════════════════════════════════════════════════
if barstate.islast
    clearDrawn(devDrawn)
    map<int, float> dD = map.new<int, float>()
    map<int, float> dV = map.new<int, float>()
    int   anchorBI = na
    int   nb       = 0

    if modeInput == "Session"
        dD := map.copy(sessD)
        dV := map.copy(sessV)
        nb := sessBars
        anchorBI := sessStartBI
        // current bar is not yet folded into the session maps
        if inSession and not barstate.isconfirmed
            mergeBins(dD, dV, buildBins())
            nb += 1
    else
        for bb in hist
            mergeBins(dD, dV, bb)
        nb := array.size(hist)
        anchorBI := bar_index - nb + 1

    devDrawn := drawProfile(dD, dV, anchorBI, bar_index, modeInput == "Session" ? rowBudget : 480, true, nb)
````
