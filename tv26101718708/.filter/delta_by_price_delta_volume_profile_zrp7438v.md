# Delta by Price (Delta Volume Profile)

- url: https://www.tradingview.com/script/ZRP7438v-Delta-by-Price-Delta-Volume-Profile/
- type: indicator
- pine_id: PUB;9adcc239e9904537b7b4ae2ae551d12b
- version: 1.0

## Description

🔹 Introduction
This indicator, Delta by Price (Delta Volume Profile), takes the familiar concept of a volume profile and replaces raw traded volume with net directional volume (delta) at each price level. Instead of showing how much volume traded at a price, it shows which side was more aggressive at that price — buyers or sellers.
The idea is straightforward: if a price level absorbed significantly more aggressive buying than selling (or vice versa), that level likely represents a meaningful shift in who was in control of the auction at that point in the range.
One thing to be upfront about: true tick-by-tick delta isn't available to Pine scripts. This indicator approximates delta by pulling lower-timeframe bars within each higher-timeframe bar and classifying each LTF bar's volume as buy-side or sell-side based on whether it closed above or below its open. It's a proxy, not a recording of the actual order book — but it's the same proxy nearly all publicly available delta tools use, and it tends to track real aggressor flow reasonably well over meaningful sample sizes.
🔹 The Premise / Background Theory
🔸 Volume tells you "how much," delta tells you "who pushed"
A standard volume profile answers one question: how much volume traded at each price? It's useful for finding high-volume nodes (areas of acceptance) and low-volume nodes (areas of rejection), but it's directionally blind. A price level with 1,000 contracts could be 500 aggressive buys and 500 aggressive sells — pure equilibrium — or it could be 950 buys and 50 sells, meaning that level was overwhelmingly bought into.
Delta separates these two scenarios. A delta profile takes that same volume and splits it by aggressor side, then nets it. The result is a histogram that shows not just where volume concentrated, but which direction the pressure leaned at every price.
🔸 A concrete example
Assume price moves through a range from 5,000 to 5,010 over a session.
At the 5,002 level, three separate visits occur. On the first visit, an LTF bar closes higher than it opened with volume of 200 — classified as buy-side. On the second visit, another bar closes lower than it opened with volume of 150 — sell-side. On the third visit, a bar closes higher with volume of 300 — buy-side.
Net delta at 5,002 = +200 − 150 + 300 = +350.
Total volume at 5,002 = 200 + 150 + 300 = 650.
A standard volume profile would just show "650 contracts traded here." The delta profile shows +350 net buying — meaning roughly 54% more buy-side aggression than sell-side at that exact price. If you saw a level like this near the low of a range, it might suggest buyers stepped in there with conviction, not just that "a lot happened" there.
🔸 Why distribute delta across a bar's range instead of just its close
Each higher-timeframe bar has a high and a low, and the LTF bars that compose it trade across that entire range — not just at the close. This indicator takes each HTF bar's net delta and spreads it proportionally across every price bin the bar's high-to-low range touches.
This is an assumption, not a measurement. In reality, delta within a single bar isn't evenly distributed across its range — more of it likely occurred near where price spent the most time. But without LTF-by-LTF price-level tracking (which would be computationally heavy and hit Pine's lower-timeframe data limits quickly), even distribution across the bar's range is the most defensible simplification available. Wider bars contribute a thinner "smear" of delta per price bin; narrow bars concentrate their delta into fewer bins. Over a large enough sample, this tends to average out reasonably well.
🔹 How It Works
🔸 Profile Range: Session vs. Rolling Lookback
The indicator builds its profile from one of two data windows, selectable in settings.
Session mode mirrors how a session volume profile works — it resets at the start of each new session (defined by the session time input) and accumulates only the bars within that session. This is the natural choice if you want to see, for example, today's regular trading hours delta distribution reset cleanly each day, the same way you'd look at a daily session volume profile.
Rolling Lookback mode instead uses a fixed number of the most recent closed bars (configurable, default 200), regardless of session boundaries. This is useful for a continuously updating view of recent delta structure that isn't tied to calendar sessions — helpful for instruments or sessions that don't fit a clean daily reset (e.g. 24-hour futures markets).
There are limitations here worth noting. Session mode depends on the session time input matching how you actually think about your trading day. If you trade through multiple sessions (e.g. Asian, London, NY) and only select one as your "session," the profile will reset and rebuild only around that window — bars outside it are ignored entirely.
🔸 Number of Price Rows
This setting controls how finely the price range is divided into bins — effectively the "resolution" of the profile. A higher row count gives more granular price-level detail but spreads the available delta across more bins, making each individual bin's bar shorter and potentially noisier. A lower row count aggregates more price action into each bin, producing a smoother, more visually digestible profile but losing some precision about exactly where within a price cluster the delta concentrated.
This is a resolution-versus-noise tradeoff — there's no universally correct setting, and it's worth adjusting based on the instrument's typical range and tick size.
🔸 Extend Direction
The profile can be drawn extending to the right of the current bar (the default, useful when you want the profile visible without obscuring recent price action to the left) or to the left, anchored at the start of the lookback/session window — placing it where the data actually begins, similar to how some volume profile tools anchor to the left edge of the range being measured.
This is purely a visual/layout preference and doesn't change any underlying calculation — it only affects where the horizontal delta bars are drawn relative to price.
🔸 Point of Control (POC)
When enabled, a label marks the price bin with the highest total absolute volume (buy-side + sell-side combined, not net delta) — analogous to the POC on a standard volume profile. This identifies where the most total activity occurred, regardless of which direction it leaned. It's possible — and informative — for the POC bin to have a relatively small net delta despite high total volume, which would indicate that level saw heavy two-sided participation rather than one-sided conviction.
🔸 Custom Lower Timeframe
By default, the indicator automatically selects a lower timeframe for delta calculation based on your chart's timeframe (1-second charts use 1S, intraday charts use 1-minute, daily charts use 5-minute, and anything larger uses 60-minute). You can override this manually.
The tradeoff here is precision versus data availability. A finer LTF gives a more granular delta classification per HTF bar, but request.security_lower_tf() has practical limits on how many LTF bars it can return per HTF bar — on very large lookbacks with a very fine LTF relative to your chart timeframe, you may not get the full intrabar picture for older bars.
🔹 Closing Remarks
A delta-by-price profile doesn't tell you why buyers or sellers were more aggressive at a given level — only that they were, based on a reasonable proxy for aggressor classification. Large net-delta clusters don't guarantee future support or resistance. They're best treated as a layer of context: a way of seeing whether the volume that built a price level was directionally lopsided or balanced, which can complement (not replace) your read of structure, location, and broader order flow.
Used alongside the rest of your framework, it's another lens for asking the same underlying question every footprint-based approach asks: was this level built by conviction, or by indecision?

## Source Code

````pine
//@version=6
indicator("Delta by Price (Delta Volume Profile)", overlay=true, max_bars_back=500)

// ── Inputs ──────────────────────────────────────────────────────────────
modeInput      = input.string("Session", "Profile Range", options=["Session", "Rolling Lookback"])
lookback       = input.int(200, "Lookback Bars (Rolling mode only)", minval=10, maxval=2000)
sessionInput   = input.session("0000-0000", "Session Time (Session mode only)")
numRows        = input.int(50, "Number of Price Rows", minval=10, maxval=200)
useCustomTF    = input.bool(false, "Use custom LTF for delta", tooltip="By default, automatically selects an appropriate lower timeframe for up/down volume.")
customTF       = input.timeframe("1", "Custom LTF", active=useCustomTF)
profileWidth   = input.float(30, "Profile Width (bars)", minval=5, maxval=100)
extendDirInput = input.string("Right", "Extend Direction", options=["Right", "Left"])
posDeltaColor  = input.color(color.new(color.teal, 0), "Positive Delta Color")
negDeltaColor  = input.color(color.new(color.red, 0), "Negative Delta Color")
showPOC        = input.bool(true, "Show Point of Control")

// ── Determine lower timeframe for delta ────────────────────────────────
lowerTimeframe = switch
    useCustomTF          => customTF
    timeframe.isseconds  => "1S"
    timeframe.isintraday => "1"
    timeframe.isdaily    => "5"
    => "60"

// ── Pull LTF OHLCV and compute per-bar delta ────────────────────────────
ltfClose  = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, close)
ltfOpen   = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, open)
ltfVolume = request.security_lower_tf(syminfo.tickerid, lowerTimeframe, volume)

getBarDelta() =>
    float d = 0.0
    if array.size(ltfClose) > 0
        for i = 0 to array.size(ltfClose) - 1
            c = array.get(ltfClose, i)
            o = array.get(ltfOpen, i)
            v = array.get(ltfVolume, i)
            if c > o
                d += v
            else if c < o
                d -= v
    d

barDelta = getBarDelta()

// ── Session detection ────────────────────────────────────────────────────
inSession    = not na(time(timeframe.period, sessionInput))
sessionStart = inSession and not inSession[1]

// ── Arrays to store price/delta data ─────────────────────────────────────
var array<float> barHighs  = array.new<float>()
var array<float> barLows   = array.new<float>()
var array<float> barDeltas = array.new<float>()

if modeInput == "Session"
    if sessionStart
        array.clear(barHighs)
        array.clear(barLows)
        array.clear(barDeltas)
    if (barstate.isconfirmed or barstate.isrealtime) and inSession
        array.push(barHighs, high)
        array.push(barLows, low)
        array.push(barDeltas, barDelta)
        if barstate.isrealtime and array.size(barHighs) > 0
            array.set(barHighs, array.size(barHighs) - 1, high)
            array.set(barLows, array.size(barLows) - 1, low)
            array.set(barDeltas, array.size(barDeltas) - 1, barDelta)
else
    if barstate.isconfirmed
        array.push(barHighs, high)
        array.push(barLows, low)
        array.push(barDeltas, barDelta)
        if array.size(barHighs) > lookback
            array.shift(barHighs)
            array.shift(barLows)
            array.shift(barDeltas)

// ── Build delta-by-price profile on last bar ────────────────────────────
var line[]  profileLines = array.new<line>()
var label   pocLabel      = na

if barstate.islast
    for ln in profileLines
        line.delete(ln)
    array.clear(profileLines)
    if not na(pocLabel)
        label.delete(pocLabel)

    n = array.size(barHighs)
    if n > 1
        rangeHigh = array.max(barHighs)
        rangeLow  = array.min(barLows)
        binSize   = (rangeHigh - rangeLow) / numRows

        if binSize > 0
            var array<float> binDelta  = array.new<float>(numRows, 0.0)
            var array<float> binVolAbs = array.new<float>(numRows, 0.0)
            array.fill(binDelta, 0.0)
            array.fill(binVolAbs, 0.0)

            for i = 0 to n - 1
                bh = array.get(barHighs, i)
                bl = array.get(barLows, i)
                bd = array.get(barDeltas, i)

                startBin = int(math.max(0, math.floor((bl - rangeLow) / binSize)))
                endBin   = int(math.min(numRows - 1, math.floor((bh - rangeLow) / binSize)))
                if endBin < startBin
                    endBin := startBin

                spanCount   = endBin - startBin + 1
                deltaPerBin = bd / spanCount

                for b = startBin to endBin
                    array.set(binDelta, b, array.get(binDelta, b) + deltaPerBin)
                    array.set(binVolAbs, b, array.get(binVolAbs, b) + math.abs(deltaPerBin))

            maxAbsDelta = 0.0
            pocBin      = 0
            maxVolBin   = 0.0
            for b = 0 to numRows - 1
                ad = math.abs(array.get(binDelta, b))
                if ad > maxAbsDelta
                    maxAbsDelta := ad
                vb = array.get(binVolAbs, b)
                if vb > maxVolBin
                    maxVolBin := vb
                    pocBin    := b

            for b = 0 to numRows - 1
                d = array.get(binDelta, b)
                if maxAbsDelta > 0
                    priceLevel = rangeLow + (b + 0.5) * binSize
                    barLen     = (math.abs(d) / maxAbsDelta) * profileWidth
                    lineColor  = d >= 0 ? posDeltaColor : negDeltaColor

                    int x1 = na
                    int x2 = na
                    if extendDirInput == "Right"
                        x1 := bar_index + 1
                        x2 := bar_index + 1 + math.round(barLen)
                    else
                        x1 := bar_index - n
                        x2 := bar_index - n - math.round(barLen)

                    ln = line.new(x1, priceLevel, x2, priceLevel, xloc.bar_index, extend.none, lineColor, line.style_solid, 2)
                    array.push(profileLines, ln)

            if showPOC
                pocPrice = rangeLow + (pocBin + 0.5) * binSize
                int pocX = extendDirInput == "Right" ? bar_index + 1 : bar_index - n
                pocLabelStyle = extendDirInput == "Right" ? label.style_label_left : label.style_label_right
                pocLabel := label.new(pocX, pocPrice, "POC", xloc.bar_index, yloc.price, color.new(color.yellow, 0), pocLabelStyle, color.black, size.small)
````
