# Strong Volume Map | ProjectSyndicate

- url: https://www.tradingview.com/script/7HhUIYEa-Strong-Volume-Map-ProjectSyndicate/
- type: indicator
- pine_id: PUB;b56df288364f43febb0b0b7d11c2b11c
- version: 1.0

## Description

▪️Strong Volume Map takes the one thing every level on your chart is really made of — traded volume — and turns it into a readable map of price. Support and resistance drawn from swing highs and lows is a guess about where people care. Volume at price is the receipt. This indicator reads where business was actually done over your lookback, slices it into equal layers of participation, and lays them across the chart as flat horizontal strata so you can see, at a glance, which prices are solid rock and which are thin air.

▪️The range becomes ten stacked beds, each holding exactly the same slice of volume. Where trading was heavy the beds squeeze thin; where price travelled fast on light volume they stretch wide. Thin means dense means strong. Every layer is scored, graded and labelled with its own record, colored by whether it sits as support below price or resistance above it, and the whole map is rebuilt from the market's own order flow on each closed bar.

▪️Most volume-profile tools bolt a histogram onto the side of the chart and leave you to eyeball the fat part. This one spreads the profile flat across price as shaded zones you trade inside, ranks every layer against the others, marks the strongest and the weakest in plain language, and adds a contrarian exhaustion signal that fires only when price overstretches from fair value on a volume climax.

🗺️ The Volume Map (the core). The lookback window is scanned into a high-resolution volume-at-price profile, then divided into ten horizontal layers that each carry one tenth of the total traded volume. Because every layer holds the same volume, their thickness is the whole story: a thin layer is a price band where a lot of business was packed into a small range — a shelf price has defended — while a thick layer is a vacuum price slipped through. The layers draw behind the candles and extend a set number of bars into the future, so the levels sit waiting where price is heading.

⭐ Strength Score (0–10). Every layer is graded before it is drawn. The score blends two readings: how dense the layer is in absolute terms (how far below the average thickness it compresses) and how it ranks against the other nine layers right now. That mix keeps the scores honest and separated — a quiet range doesn't light up every layer, and a busy one still tells you which shelf is king. The score drives a four-tier grade, a star rating, and a slightly more solid fill on the layers that matter most.

🏛️ The Layer Record, Written On The Chart. Each layer carries its own label, not a shared legend: a star rating, its score out of ten, its tier — ELITE, STRONG, MODERATE, WEAK or THIN — the side it is working as, and its exact price range. ELITE and STRONG layers are the high-volume shelves to lean on; THIN layers are the gaps price tends to move through quickly. Labels that would collide are thinned automatically so only the stronger of two overlapping reads survives, and a minimum-score filter clears the clutter when you only want the shelves that count.

🎨 Support, Resistance & In-Play Coloring. The map reads price position live. Layers below the last close are tinted as support, layers above it as resistance, and the single layer price is trading inside is marked in-play, so the structure above and below you is color-separated the instant you look at it. The default palette is teal for support and magenta for resistance; every tone, the fill transparency, the borders and the base shading on each bed are adjustable.

🎯 Exhaustion Fades. A contrarian signal rides on top of the map. The engine tracks a volume-weighted fair value and its dispersion; when a bar stretches a set number of standard deviations past fair value on a volume climax and then rejects back with a tail, it prints a fade triangle — long on a stretched flush lower, short on a stretched spike higher. Wicks alone trigger nothing. Only a confirmed close fires a signal, and a cooldown keeps them from stacking, so what you see on history is what you would have traded live.

🔬 Volume-Weighted Fair Value. Rather than a plain moving average, the fade engine anchors to where volume actually transacted — a rolling volume-weighted mean and its spread. That is the line price is measured against, so "overstretched" means overstretched relative to where business was done, not relative to an arbitrary average.

🔔 Native Alerts. Exhaustion fade long, exhaustion fade short, and a test of a strong support or strong resistance layer, each firing only on confirmed conditions and naming the event and the price. Set the strong-layer threshold where you want the shelf alerts to trip.

🎯 Why this is different. A hand-drawn level treats every price the same. This one measures where volume actually sits, slices participation into equal layers so thickness alone tells you strength, scores and ranks every shelf against the rest, separates support from resistance on the fly, and layers a confirmed, non-repainting exhaustion signal on top — so the map in front of you is built from the market's own record, not from where a line happened to land.

🚀 Built to adapt. The lookback depth, the forward extension, the layer transparency and shading, the whole color palette, the label size and minimum score, and every threshold on the fade engine are inputs — so it fits indices, FX, futures or crypto on any timeframe, from a scalping chart to a swing map.

💡 Cleanest setup: pick a lookback that covers the structure you trade — a few hundred bars for intraday, more for swing — leave the layers drawing behind the candles, and let the strong layers and the fade triangles do the pointing.

🎯 How To Trade It: Two Approaches

Everything comes down to one question: is price sitting on solid rock or in thin air, and is it stretched far enough from fair value to snap back?

⚡ 1) Trade the Shelves: support and resistance from real volume

Use the ELITE and STRONG layers as your levels.

▪️Read the record. A high-scoring layer below price is a shelf buyers built and defended — a place to look for longs on a test and hold. A high-scoring layer above price is a ceiling sellers built — a place to lean short or to take profit into. The thin, low-score layers between them are travel space, not levels.
Trigger: price testing a strong layer and holding, in the direction of the surrounding structure.
Target: the next strong layer in the trade direction; the thin layers in between tend to be crossed quickly.
Invalidation: a decisive close through the shelf. A broken high-volume layer often flips role — former support becomes resistance.

🧱 2) Fade the Stretch: the exhaustion snap-back

Use this on a fade triangle.

▪️Read the record. You want price far from volume-weighted fair value, a volume climax on the rejection bar, and ideally a strong layer sitting behind the signal to catch it. A fade long into an ELITE support layer, or a fade short into an ELITE resistance layer, is the setup leaning on both the stretch and the shelf.
Trigger: the confirmed fade triangle.
Target: fair value, then the nearest strong layer on the way back.
Stop: beyond the rejection bar's extreme.
Watch: price accepting further past the layer instead of snapping back — the stretch kept going, so the fade is done.

✋ Stand down: when the map says wait

Price sitting in a thick, low-score layer with no shelf nearby — there is nothing to lean on.
A fade triangle with no strong layer behind it and price still accepting away from fair value.
Layers that all score alike — the range is balanced, with no dominant shelf to trade against.
Price mid-layer with no test in progress — wait for the touch and let the alert bring you in.

Rule of thumb: ⚡ Strong layer + hold on the test + structure aligned → trade the shelf toward the next strong layer. 🧱 Price overstretched from fair value + volume climax + a strong layer behind it → fade the stretch back toward fair value. ❄️ Thin layer, no nearby shelf, balanced scores → stand down until price reaches a level that means something.

▪️Honest measurement. This is a map of where volume has traded and where price stands relative to it, not a signal service and not a promise that any level will hold. The strength scores are the historical density of each price band over the lookback you set, on this market, in the bars the indicator can see. They describe where business was done, not where it must be done next. Fade signals are recorded on confirmed closes and a live bar can still change until it closes. Layers move as the lookback window rolls forward; a shelf is only as current as the window that built it.

## Source Code

````pine
//@version=6
indicator("Strong Volume Map", overlay = true, max_boxes_count = 40, max_lines_count = 10, max_labels_count = 20, max_bars_back = 1100, behind_chart = true)

const int K    = 10
const int BINS = 240

gD = "═══ Display ═══"
lookbackIn = input.int(300, "Lookback (bars)", minval = 50, maxval = 1000, group = gD)
extendIn   = input.int(30, "Extend Right (bars)", minval = 0, maxval = 200, group = gD)
showInfo   = input.bool(true, "Show Strength Labels", group = gD)
labSizeS   = input.string("Small", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
labMinSc   = input.float(0.0, "Label Min Score", minval = 0, maxval = 10, step = 0.5, group = gD)

gF = "═══ Exhaustion Fades ═══"
showSig    = input.bool(true, "Show Fade Signals", group = gF)
sigLenIn   = input.int(100, "Fair Value Length", minval = 10, maxval = 500, group = gF)
sigBandIn  = input.float(2.0, "Stretch (σ)", minval = 0.5, maxval = 5.0, step = 0.1, group = gF)
sigVolZIn  = input.float(1.5, "Volume Climax (z)", minval = 0.0, maxval = 6.0, step = 0.1, group = gF)
sigWickIn  = input.float(0.30, "Min Rejection Wick", minval = 0.0, maxval = 0.9, step = 0.05, group = gF)
sigCoolIn  = input.int(5, "Cooldown Bars", minval = 0, maxval = 200, group = gF)

gC = "═══ Style ═══"
supCol     = input.color(#21c997, "Bullish Tone (Support)", group = gC)
resCol     = input.color(#cc24e2, "Bearish Tone (Resistance)", group = gC)
liveCol    = input.color(#9AA0A6, "In-Play Tone", group = gC)
fillTransp = input.int(84, "Layer Transparency", minval = 50, maxval = 96, group = gC)
showBord   = input.bool(true, "Show Layer Borders", group = gC)
bordTransp = input.int(35, "Border Transparency", minval = 0, maxval = 100, group = gC)
showShade  = input.bool(true, "Bed Shading", group = gC)

gA = "═══ Alerts ═══"
instThr    = input.float(7.0, "Strong Layer Score", minval = 0, maxval = 10, step = 0.5, group = gA)

TRANSP = color.new(#000000, 100)

f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.normal

f_stars(sc) => sc >= 8 ? "★★★★" : sc >= 6.5 ? "★★★" : sc >= 5 ? "★★" : sc >= 3 ? "★" : "·"
f_tier(sc)  => sc >= 8 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5 ? "MODERATE" : sc >= 3 ? "WEAK" : "THIN"

float vol    = nz(volume) > 0 ? volume : 1.0
float sumVol = math.sum(vol, sigLenIn)
float fv     = math.sum(hlc3 * vol, sigLenIn) / sumVol
float fv2    = math.sum(hlc3 * hlc3 * vol, sigLenIn) / sumVol
float fvSd   = math.sqrt(math.max(fv2 - fv * fv, 0.0))
float volSd  = ta.stdev(vol, 50)
float volZ   = volSd > 0 ? (vol - ta.sma(vol, 50)) / volSd : 0.0
float rngBar = high - low
float upWick = rngBar > 0 ? (high - math.max(open, close)) / rngBar : 0.0
float dnWick = rngBar > 0 ? (math.min(open, close) - low) / rngBar : 0.0
float clv    = rngBar > 0 ? (close - low) / rngBar : 0.5
float strUp  = fvSd > 0 ? (high - fv) / fvSd : 0.0
float strDn  = fvSd > 0 ? (fv - low) / fvSd : 0.0

var int lastSellBar = -100000
var int lastBuyBar  = -100000
bool sellSig = showSig and barstate.isconfirmed and strUp >= sigBandIn and volZ >= sigVolZIn and upWick >= sigWickIn and clv <= 0.6 and bar_index - lastSellBar > sigCoolIn
bool buySig  = showSig and barstate.isconfirmed and strDn >= sigBandIn and volZ >= sigVolZIn and dnWick >= sigWickIn and clv >= 0.4 and bar_index - lastBuyBar > sigCoolIn
if sellSig
    lastSellBar := bar_index
if buySig
    lastBuyBar := bar_index

plotshape(buySig, "Fade Long", shape.triangleup, location.belowbar, supCol, size = size.tiny)
plotshape(sellSig, "Fade Short", shape.triangledown, location.abovebar, resCol, size = size.tiny)

var array<box>   bedBx   = array.new<box>()
var array<box>   shadeBx = array.new<box>()
var array<label> tagLb   = array.new<label>()
var bool nearStrongSup = false
var bool nearStrongRes = false

if barstate.islast
    if bedBx.size() == 0
        for k = 0 to K - 1
            bedBx.push(box.new(bar_index, close, bar_index, close, border_color = TRANSP, border_width = 1, bgcolor = TRANSP))
            shadeBx.push(box.new(bar_index, close, bar_index, close, border_color = TRANSP, border_width = 0, bgcolor = TRANSP))
            tagLb.push(label.new(bar_index, close, "", style = label.style_label_left, color = TRANSP))
    nearStrongSup := false
    nearStrongRes := false

    int n = math.min(lookbackIn, bar_index + 1)
    float rHi = high
    float rLo = low
    for i = 0 to n - 1
        rHi := math.max(rHi, high[i])
        rLo := math.min(rLo, low[i])

    if n >= 20 and rHi > rLo
        float step = (rHi - rLo) / BINS
        array<float> pv = array.new<float>(BINS, 0.0)
        for i = 0 to n - 1
            float h = high[i]
            float l = low[i]
            float v = nz(volume[i]) > 0 ? volume[i] : 1.0
            float r = h - l
            int b0 = math.max(0, math.min(BINS - 1, int((l - rLo) / step)))
            int b1 = math.max(0, math.min(BINS - 1, int((h - rLo) / step)))
            for j = b0 to b1
                float bl = rLo + j * step
                float sh = r > 0 ? math.max(0.0, math.min(h, bl + step) - math.max(l, bl)) / r : 1.0 / (b1 - b0 + 1)
                pv.set(j, pv.get(j) + v * sh)

        float tot = pv.sum()
        array<float> edges = array.new<float>(K + 1, rLo)
        edges.set(K, rHi)
        float cum = 0.0
        int q = 1
        for j = 0 to BINS - 1
            float w = pv.get(j)
            while q < K and cum + w >= tot * q / K
                float frac = w > 0 ? (tot * q / K - cum) / w : 0.0
                edges.set(q, rLo + (j + frac) * step)
                q += 1
            cum += w

        float avgTh = (rHi - rLo) / K
        array<float> ths = array.new<float>(K, 0.0)
        for k = 0 to K - 1
            ths.set(k, math.max(edges.get(k + 1) - edges.get(k), syminfo.mintick))
        int x0 = bar_index - n + 1
        int x1 = bar_index + extendIn
        float minGap = (rHi - rLo) * 0.028
        float lastY = na
        float lastSc = na
        int lastK = -1
        for k = 0 to K - 1
            float bot = edges.get(k)
            float top = edges.get(k + 1)
            float th  = ths.get(k)
            int thicker = 0
            for m = 0 to K - 1
                if ths.get(m) > th
                    thicker += 1
            float absSc = math.min(10.0, math.max(0.0, (math.log(avgTh / th) / math.log(2.0) + 1.5) / 3.5 * 10.0))
            float sc  = 0.5 * absSc + 0.5 * 10.0 * thicker / (K - 1)
            bool isSup  = top < close
            bool isRes  = bot > close
            color tone  = isSup ? supCol : isRes ? resCol : liveCol
            string side = isSup ? "Support" : isRes ? "Resistance" : "In Play"
            int tr = int(math.max(50, math.min(96, fillTransp + 6 - sc * 1.2)))
            box b = bedBx.get(k)
            b.set_lefttop(x0, top)
            b.set_rightbottom(x1, bot)
            b.set_bgcolor(color.new(tone, tr))
            b.set_border_color(showBord ? color.new(tone, bordTransp) : TRANSP)
            box s = shadeBx.get(k)
            s.set_lefttop(x0, bot + (top - bot) * 0.18)
            s.set_rightbottom(x1, bot)
            s.set_bgcolor(showShade ? color.new(tone, math.max(tr - 8, 40)) : TRANSP)
            label t = tagLb.get(k)
            t.set_xy(x1 + 1, (top + bot) / 2)
            t.set_size(f_size(labSizeS))
            float ym = (top + bot) / 2
            bool show = showInfo and sc >= labMinSc
            if show and not na(lastY) and ym - lastY < minGap
                if sc > lastSc
                    tagLb.get(lastK).set_text("")
                else
                    show := false
            if show
                lastY := ym
                lastSc := sc
                lastK := k
                t.set_text(f_stars(sc) + "  " + str.tostring(sc, "#.0") + "/10  " + f_tier(sc) + "  ·  " + side + "  " + str.tostring(bot, format.mintick) + " – " + str.tostring(top, format.mintick))
                t.set_textcolor(tone)
                t.set_tooltip("Layer " + str.tostring(k + 1) + " of " + str.tostring(K) + " · holds 10% of traded volume\nThickness " + str.tostring(th, format.mintick) + " (average " + str.tostring(avgTh, format.mintick) + ")\nThinner layer = denser volume = stronger level")
            else
                t.set_text("")
            if sc >= instThr and low <= top and high >= bot
                if isSup or (not isRes and close >= (top + bot) / 2)
                    nearStrongSup := true
                else
                    nearStrongRes := true

alertcondition(buySig, "Fade Long", "Strong Volume Map: exhaustion fade LONG on {{ticker}} at {{close}}")
alertcondition(sellSig, "Fade Short", "Strong Volume Map: exhaustion fade SHORT on {{ticker}} at {{close}}")
alertcondition(nearStrongSup, "Strong Support Layer Test", "Strong Volume Map: price testing a strong support layer on {{ticker}}")
alertcondition(nearStrongRes, "Strong Resistance Layer Test", "Strong Volume Map: price testing a strong resistance layer on {{ticker}}")
````
