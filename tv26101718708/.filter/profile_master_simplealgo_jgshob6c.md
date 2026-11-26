# Profile Master [SimpleAlgo]

- url: https://www.tradingview.com/script/JGShoB6C-Profile-Master-SimpleAlgo/
- type: indicator
- pine_id: PUB;e0cb9c2b3fc24d0c9725c10ab2c38896
- version: 1.0

## Description

█ [b]Introducing Profile Master[/b]

A volume profile answers one question: where has the market been doing business? The standard ways of showing it, a histogram pinned to the side of the chart or a stack of session boxes, answer it for one moment. You get the levels, but you never see how value moved while price moved.

[b]Profile Master[/b] draws the profile as a cloud that travels with the chart. The cloud is the value area: the range that holds 70% of the volume in the cluster the market is doing business in, built from the last 90 bars. The thin line inside it is the point of control, the price where the most volume changed hands. Both are rebuilt on every bar from lower timeframe volume at price, and older bars fade out of the profile gradually instead of dropping off a cliff, so the cloud bends with the market instead of jumping.

https://www.tradingview.com/x/hupGbEEI/

There are no labels on the chart. Price inside the cloud, outside it, or leaving it and coming back is the whole read, and the panel in the corner says it in words. The four things worth knowing about (price accepted above value, accepted below it, back into value from above, back into value from below) are alerts, and can be marked on the chart with small dots if you want them.

https://www.tradingview.com/x/aNuDZfrS/

⚪ [b]The cloud[/b]

The value area is drawn as fourteen slices of one colour, faint in the middle and densest at the edges. The edges are the levels you trade against, so they're the part you should see. The middle of the cloud is where price lives most of the time and needs no emphasis. While value is on the move from one cluster to another the whole cloud fades, and it comes back to full strength once it has arrived. A faint trail is value in transit. A bright cloud is value at rest.

⚪ [b]The point of control[/b]

The busiest price is drawn as horizontal level segments, mint while price is holding above it and pink while it's holding below. When the busiest price moves, the line restarts at the new level instead of drawing a staircase, and short-lived levels are left out. What's left is a handful of prices that mattered.

⚪ [b]What's different[/b]

Most rolling profiles treat every bar in the window the same until the bar leaves, and then the value area jumps. Profile Master weights bars by age, so a session leaves the profile over many bars and the value area drifts. The cloud describes the cluster the market is trading in: when a second cluster builds away from the first, the cloud stays with the busier one until the new one takes over, then travels there over a number of bars. It never stretches across both. The profile is built from where volume traded inside each bar, not from the bar's range. The control has stability rules so it doesn't flicker between two busy areas. And the events only count when price did the moving, never when the cloud drifted over to meet a sitting market.

█ [b]HOW IT WORKS[/b]

⚪ [b]1. Volume at price[/b]

For every bar on your chart the script reads the closes and volumes of a lower timeframe. The timeframe is picked automatically: 1-minute bars on charts up to 15 minutes, 5-minute bars up to 1 hour, 15-minute up to 4 hours, 1-hour up to daily, 4-hour above that. You can also set it by hand.

[pine]
[ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltfOK ? pickTF : timeframe.period, [close, volume])
[/pine]

Each lower timeframe close is sorted into one of eight price levels inside the bar, and its volume is added there.

[pine]
float p = math.min(hi, math.max(lo, array.get(ltfClose, i)))
int s = math.min(SLOTS - 1, math.max(0, int((p - lo) / rng * SLOTS)))
array.set(slot, s, array.get(slot, s) + v)
[/pine]

So a 1-hour candle isn't one block of volume smeared across its range. It's twelve 5-minute prints, each at the price where it happened. If no lower timeframe data is available for a bar (and on a 1-minute chart, where there's nothing lower to read), the bar's volume is spread across its range with the body weighted three to one over the wicks.

Two guards keep bad data out. A print further than three ATRs from the bar's body is treated as a bad tick rather than a trade, and is counted at the edge of that range, so one broken print from a data feed can't stretch the whole profile:

[pine]
float cap = nz(atr50, high - low) * 3
float lo = math.max(low, bodyLo - cap)
float hi = math.min(high, bodyHi + cap)
[/pine]

And a single print carrying many times the volume of the bar's typical print is capped at ten times the bar's median print. On stocks and cash indices that's the closing auction, which lands a block of the day's volume on one price in one minute. It still shows as a busy row, but it can't own the profile:

[pine]
float med = array.median(vols)
float vCap = med > 0 ? med * 10 : na
[/pine]

⚪ [b]2. The fading window[/b]

The profile is built from the last 90 bars, but they don't count equally. Each bar is weighted by its age:

[pine]
float w = fade ? math.pow(1.0 - (nb - 1 - i) / window, 1.5) : 1.0
[/pine]

The newest bar is at full weight, a bar halfway through the window counts for about a third, and the oldest bars count for almost nothing. This is the part that makes the cloud a cloud. In a plain rolling profile the value area can jump a hundred ticks the moment one big session leaves the window. Here, a session leaves slowly, so the value area drifts.

https://www.tradingview.com/x/0zsK9RQ6/

⚪ [b]3. The grid[/b]

The price range covered by the window is split into 48 rows, and the volume of every bar in the window is stacked into those rows at its weight. The range comes from where volume actually sat, not from the full extent of every wick, so one spike doesn't coarsen the resolution of the whole profile.

⚪ [b]4. The point of control[/b]

The busiest row is read off a copy of the profile smoothed across three rows, so a busy area beats a single busy row:

[pine]
array.set(dens, r, 0.5 * c + 0.25 * (u + d))
[/pine]

The control is sticky. The row that held it keeps it unless another area carries clearly more volume, about a quarter more:

[pine]
if pr >= 0 and pr < nRows and array.get(dens, pr) >= pocVol * 0.80
    pocRow := pr
[/pine]

Without this, the control flips between two clusters on every bar and the line turns into confetti.

⚪ [b]5. The value area[/b]

The cloud is the value area of the cluster the control sits in, not of everything in the window. First the cluster is found by walking out from the control in both directions while the profile stays busy. It ends where the next two rows average less than 15% of what the busiest row carries:

[pine]
float nxtUp = cHi < nRows - 2 ? (array.get(d, cHi + 1) + array.get(d, cHi + 2)) / 2 : array.get(d, cHi + 1)
if nxtUp < floorVol
    break
[/pine]

Then, starting at the control, the area grows one row at a time toward whichever side carries more volume in the next two rows, the way the classic profile does, until it holds 70% of the cluster's volume:

[pine]
while acc < target and (lo > cLo or hi < cHi)
    float up = hi < cHi ? array.get(d, hi + 1) + (hi < cHi - 1 ? array.get(d, hi + 2) : 0.0) : -1.0
    float dn = lo > cLo ? array.get(d, lo - 1) + (lo > cLo + 1 ? array.get(d, lo - 2) : 0.0) : -1.0
    if up >= dn
        hi += 1
        acc += array.get(d, hi)
    else
        lo -= 1
        acc += array.get(d, lo)
[/pine]

Why the cluster rule matters: after a fast move, the window holds two clusters with thin trading between them, the old one fading and the new one building. A plain 70% area has to reach across the thin stretch to the other cluster, and the cloud turns into a tall slab, or dives toward old prices while the market is trading somewhere else. Here the cloud stays with the cluster that holds the control until the other one takes it over, and then it travels there. The right-edge profile still shows both.

The edges then get a little hysteresis: an edge stays where it was while it's still inside the band between the 66% and 74% areas, and moves when it falls outside that band. That stops the edges from twitching when the volume split sits right at the threshold.

⚪ [b]6. From rows to cloud[/b]

The raw edges go through a 5-bar median, which deletes one and two bar jumps. Then each edge is allowed to move only so far in a single bar: half an ATR by default, or a tenth of what's left of a long trip, whichever is more.

[pine]
limited(float target, float prev) =>
    float gap = target - prev
    float step = math.min(math.abs(gap), math.max(maxStep, math.abs(gap) / 10))
    prev + math.sign(gap) * step
[/pine]

Ordinary drift is well under the limit and passes through untouched. A relocation of value, when the control moves to a new cluster and the whole value area is rebuilt around it, would otherwise draw a wall. With the limit it draws a slope that starts quickly and eases into the new level, and the cloud looks like it flows there, because it does. A short smoothing (4 bars by default) rounds the corners:

[pine]
float vah = ta.ema(vahL, smoothLen)
float val = ta.ema(valL, smoothLen)
[/pine]

While the drawn edges are still more than half an ATR from where they're going, the cloud fades in proportion to the distance left, and returns to full strength as it arrives:

[pine]
float travel = (math.abs(vahM - vah) + math.abs(valM - val)) / 2
[/pine]

So the trail the cloud leaves while it travels between two clusters is faint, and the cloud is bright only where value actually sits.

The space between the two edges is split into fourteen slices and each slice is filled at its own transparency, faint at the centre and densest at the edges.

⚪ [b]7. The control line[/b]

The drawn level is held until the busiest row has moved a full row away, so grid drift doesn't nudge the line:

[pine]
else if na(pocLevel) or math.abs(pocRaw - pocLevel) >= rowH
    pocLevel := pocRaw
[/pine]

Only horizontal segments are drawn, with a one-bar gap where the level changes, and any level that didn't last five bars is left out. The last five bars are drawn live, so the right end of the line is provisional until those bars close. The colour follows which side of the control price is holding, and needs two closes to flip.

When value relocates, the control gets there first, because it's a level and not a curve, and the cloud follows it over the next bars. A control segment sitting just outside the cloud is value on its way.

https://www.tradingview.com/x/9A0VXZxS/

⚪ [b]8. Events[/b]

Price is inside, above or below the cloud. A change counts after two closes on the new side, and only if price did the moving. Over the confirming bars, price has to have travelled at least as far as the edge it crossed moved toward it:

[pine]
float priceMove = (close - close[holdBars]) * dir
float edgeMove = (edgeThen - edgeNow) * dir
bool moved = priceMove > 0 and priceMove >= edgeMove
[/pine]

If the cloud moved to meet price, or moved away from it, the state changes quietly: nothing fires, nothing is marked, and the panel's Last event row says what happened instead (Value caught up to price, Value moved below price, Value moved above price). While a change is still being confirmed, the Price row says so too (Above value, close 1 of 2), and on the live bar that would complete it, it says the change confirms on close.

Four events come out of this: Accepted above value, Accepted below value, Back into value from above, Back into value from below. They show in the panel and the alert list, and as tiny marks on the chart if you turn that on.

⚪ [b]9. The profile at the right edge[/b]

A small histogram of the current window is drawn past the last bar: value rows in the cloud colour, the control row lit, everything else grey. It's the classic picture of the same data, for the people who want to see the rows, and it's where a second cluster shows up before the cloud moves to it.

⚪ [b]Repainting[/b]

Every bar of the cloud is built only from the bars before it, so the historical cloud doesn't change. The cloud and the control update on the live bar like any moving average does. Events are decided on closed bars and never move afterwards.

█ [b]HOW TO USE IT[/b]

⚪ [b]Read the cloud first[/b]

Inside the cloud, the market is doing business where it has been doing business. Expect rotation between the edges and around the control. Outside it, the market is away from value, and one of two things happens: it gets accepted there, a new cluster builds, the cloud travels to it; or it gets rejected and price comes back in. While that's being decided, the right-edge profile shows the new cluster growing in grey.

https://www.tradingview.com/x/d57fcKYk/

⚪ [b]The edges are the levels[/b]

The top of the cloud is where buyers have been paying up and the bottom is where sellers have been letting go. Price coming down to the bottom edge from inside is a pullback to the cheap end of value. Price pushing through the top edge and holding there is a market that has decided value is higher.

⚪ [b]The control is the fulcrum[/b]

The busiest price is where the two sides agreed the most. Mint segments mean price is holding above it, pink means below. A long pink segment under a rising market usually isn't a problem. A pink segment forming while price sits right on top of it, after a long run, is worth a second look.

⚪ [b]Acceptance and rotation[/b]

[b]Accepted above value[/b] (or below): price closed outside the cloud, stayed there, and got there under its own steam. This is the start of a move away from value. The cloud will follow if the move holds.

[b]Back into value from above[/b] (or below): price was out, and it came back and stayed. This is the old market profile idea: when a market re-enters value and holds, it tends to rotate across the whole value area to the other side. Tends. It's a tendency, not a rule, and it works best after a failed attempt to leave, not during a trend that has already moved the cloud.

https://www.tradingview.com/x/tLAveBi1/

⚪ [b]Timeframes[/b]

On 5 and 15-minute charts the window is a few hours and the cloud behaves like a session profile that never resets. On 1 and 4-hour charts it covers days, and the cloud is where swing traders find their levels. On daily charts it's a rolling four month profile with 1-hour volume inside it.

⚪ [b]If you're new to profiles[/b]

Three sentences. The cloud is where most of the recent trading happened; inside it the market is fair and chops between the edges, outside it the market is moving and you don't fight it. The line is the price everyone agreed on the most; mint means buyers are in charge of it, pink means sellers. Two things are worth waiting for: price leaves the cloud and stays out, which means a move is starting, or price pokes out and comes back in, which means the move failed and price tends to travel back across the cloud.

None of this predicts where price goes. The cloud is a map of where volume has been, not where it's going, and an event isn't a buy or sell signal. Use it with your own analysis and manage your risk.

█ [b]SETTINGS[/b]

⚪ [b]Profile[/b]

[list]
[*][b]Window (bars)[/b]: how many bars of volume go into the profile. 90 by default. Longer gives a slower, wider cloud; shorter hugs recent trading.
[*][b]Fade older bars[/b]: weights bars by age as described above. Turn it off for a plain rolling profile where every bar in the window counts the same.
[*][b]Value area %[/b]: the share of the cluster's volume the cloud has to contain. 70 by default, which is the convention. 60 gives a tighter core, 80 a wider one.
[*][b]Rows[/b]: the price resolution of the profile. 48 by default.
[*][b]Lower timeframe volume[/b]: reads where volume traded inside each bar. Off, each bar's volume is spread across its range.
[*][b]Lower timeframe[/b]: Auto picks the timeframe for your chart. Set it by hand if you prefer coarser or finer prints.
[*][b]Cloud smoothing[/b]: the smoothing applied to the edges after the median. 4 by default. Higher is rounder and later.
[*][b]Cloud speed limit[/b]: the furthest an edge can move in one bar, in ATRs. 0.5 by default. Over long distances it also covers at least a tenth of what's left each bar. This is what turns a relocation of value into a slope instead of a wall. Raise it if you'd rather the cloud move faster.
[*][b]History (bars)[/b]: how far back the cloud is drawn, 2,000 bars by default. The profile is rebuilt on every bar and this keeps the script quick on long charts.
[/list]

⚪ [b]Events[/b]

[list]
[*][b]Bars to confirm[/b]: closes needed on the other side of the cloud before an event counts. 2 by default.
[*][b]Mark events on the chart[/b]: small dots where price comes back into value and small triangles where it's accepted outside. Off by default to keep the chart clean. The panel and alerts report them either way.
[/list]

⚪ [b]Look[/b]

[list]
[*][b]Theme[/b]: Neon, Classic, Aurora, Ice, or Custom with your own cloud, up and down colours.
[*][b]Cloud strength[/b]: 1 to 5. Lighter or heavier fill for your screen and background.
[*][b]Point of control line[/b]: show or hide the control segments.
[*][b]Profile at the right edge[/b] and its width in bars.
[*][b]Panel[/b]: position and size.
[/list]

█ [b]ALERTS[/b]

[list]
[*]Accepted above value, Accepted below value.
[*]Back into value from above, Back into value from below.
[/list]

Set them to "Once per bar close". Events are only ever confirmed on a closed bar.

█ [b]NOTES AND LIMITS[/b]

[list]
[*]Volume is whatever your data feed gives you. On forex and CFDs that's tick volume, the count of price changes, not contracts. The profile still works because tick volume clusters where trading is busy, but it isn't the same thing as futures or stock volume.
[*]On symbols with no volume at all the profile is built from time at price, one count per lower timeframe bar, and the panel says so.
[*]TradingView limits how far back lower timeframe data goes. Deep in the history the script falls back to spreading each bar's volume across its range, so the oldest part of the cloud is a little coarser than the recent part.
[*]Value can move to meet price. When price sits at one level for long enough, the cloud will arrive there. That's the profile doing its job, not price doing anything, and it's why the events require price to have travelled.
[*]After a gap or a fast move the cloud stays at the old levels for a while, then travels to the new ones at the speed limit. In that window the panel will say price is above or below value, and it's right: value hasn't migrated yet. When it arrives, the panel says so (Value caught up to price).
[*]In a steady trend with no pauses the cloud gets tall, because the trading really is spread over the whole move with no thin stretch to end the cluster. Tall cloud, no cluster, is itself a read: nobody has agreed on a price yet.
[*]The value area is 70% of the cluster the control sits in, not 70% of everything in the window. When the window holds two clusters it's narrower than a classic profile's area would be, on purpose. The right-edge profile shows the whole window.
[*]In a tight range the cloud gets thin, because value is tight. It widens again as soon as the market starts rotating over a wider range.
[*]A cluster that only lasts a few hours can take the control for a while and then give it back. The cloud travels up to it and comes back, leaving a faint spike. That's a failed migration of value, and it's worth noticing: the market tried a new level and rejected it.
[/list]

https://www.tradingview.com/x/bNWEMJK3/

[list]
[*]Rotation back through value works best in balanced markets. In a strong trend price can hold outside the cloud for a long time while the cloud chases it.
[/list]

█ [b]DISCLAIMER[/b]

This script is for education and information. It isn't financial advice, a recommendation to buy or sell anything, or a promise about what any market will do. Past behaviour of a market, a method or an indicator doesn't guarantee future results, and nothing on this chart replaces your own judgement. Trading involves risk and you are responsible for your decisions.

## Source Code

````pine
//@version=6
// Profile Master
//
// A volume profile drawn as a cloud instead of a histogram. The cloud is the
// value area of the cluster the point of control sits in, built from lower
// timeframe volume at price over the last N bars. Older bars fade out of the
// profile gradually, so value drifts with the market instead of jumping every
// time a large bar leaves the window, and when value relocates to a new cluster
// the cloud travels there at a capped speed instead of jumping.

indicator("Profile Master [SimpleAlgo]", "Profile Master [SimpleAlgo]", overlay = true, max_boxes_count = 250)

// ───────────────────────── Settings ─────────────────────────

grpP = "Profile"
window    = input.int(90, "Window (bars)", minval = 20, maxval = 400, group = grpP, tooltip = "How many bars of volume go into the profile.")
fade      = input.bool(true, "Fade older bars", group = grpP, tooltip = "Volume counts for less the older it is. The value area then drifts with the market instead of jumping when a big bar drops out of the window.")
vaPct     = input.float(70, "Value area %", minval = 50, maxval = 95, step = 5, group = grpP, tooltip = "Share of the cluster's volume the cloud has to contain. The cluster is the run of busy rows around the point of control; it ends where the profile thins out.")
nRows     = input.int(48, "Rows", minval = 20, maxval = 120, group = grpP, tooltip = "Price resolution of the profile.")
useLTF    = input.bool(true, "Lower timeframe volume", group = grpP, tooltip = "Reads where volume traded inside each bar. Off, or where no lower timeframe data is available, each bar's volume is spread across its range.")
ltfIn     = input.string("Auto", "Lower timeframe", options = ["Auto", "1 minute", "5 minutes", "15 minutes", "1 hour"], group = grpP)
smoothLen = input.int(4, "Cloud smoothing", minval = 1, maxval = 20, group = grpP)
stepIn    = input.float(0.5, "Cloud speed limit", minval = 0.1, maxval = 10, step = 0.1, group = grpP, tooltip = "The furthest an edge of the cloud can move in one bar, in ATRs. Over long distances it also covers at least a tenth of what's left each bar. This is what turns a relocation of value into a slope instead of a wall.")
calcBars  = input.int(2000, "History (bars)", minval = 300, maxval = 5000, step = 100, group = grpP, tooltip = "How far back the cloud is drawn. Keeps the script quick on long charts.")

grpE = "Events"
holdBars  = input.int(2, "Bars to confirm", minval = 1, maxval = 5, group = grpE, tooltip = "Closes needed on the other side of the cloud before an event counts.")
showMarks = input.bool(false, "Mark events on the chart", group = grpE, tooltip = "Small dots where price comes back into value, small triangles where it is accepted outside. Off by default to keep the chart clean. Alerts and the panel still report them.")

grpL = "Look"
themeIn   = input.string("Neon", "Theme", options = ["Neon", "Classic", "Aurora", "Ice", "Custom"], group = grpL)
cloudIn   = input.color(#7B9CFF, "Cloud", group = grpL, inline = "c")
upIn      = input.color(#00FFA3, "Up", group = grpL, inline = "c")
dnIn      = input.color(#FF3D71, "Down", group = grpL, inline = "c")
strength  = input.int(3, "Cloud strength", minval = 1, maxval = 5, group = grpL)
showPoc   = input.bool(true, "Point of control line", group = grpL)
showSide  = input.bool(true, "Profile at the right edge", group = grpL)
sideWidth = input.int(30, "Profile width (bars)", minval = 10, maxval = 100, group = grpL)
showPanel = input.bool(true, "Panel", group = grpL, inline = "p")
panelPos  = input.string("Top right", "", options = ["Top left", "Top right", "Bottom left", "Bottom right"], group = grpL, inline = "p")
panelSize = input.string("Normal", "", options = ["Small", "Normal", "Large"], group = grpL, inline = "p")

[colCloud, colUp, colDn, colPanel] = switch themeIn
    "Neon"    => [#7B9CFF, #00FFA3, #FF3D71, #262B38]
    "Classic" => [#5B8DEF, #00FF31, #FF0013, #23262F]
    "Aurora"  => [#A78BFA, #34D399, #F472B6, #262B38]
    "Ice"     => [#67E8F9, #7DD3FC, #FDA4AF, #1E293B]
    => [cloudIn, upIn, dnIn, #262B38]

// ───────────────────────── Volume at price ─────────────────────────

int chartSec = timeframe.in_seconds()
string autoTF = chartSec <= 900 ? "1" : chartSec <= 3600 ? "5" : chartSec <= 14400 ? "15" : chartSec <= 86400 ? "60" : "240"
string pickTF = switch ltfIn
    "1 minute"   => "1"
    "5 minutes"  => "5"
    "15 minutes" => "15"
    "1 hour"     => "60"
    => autoTF
bool ltfOK = useLTF and timeframe.in_seconds(pickTF) < chartSec

[ltfClose, ltfVol] = request.security_lower_tf(syminfo.tickerid, ltfOK ? pickTF : timeframe.period, [close, volume])

var bool symbolHasVol = false
if not na(volume) and volume > 0
    symbolHasVol := true
var bool ltfSeen = false
if ltfOK and array.size(ltfClose) > 1
    ltfSeen := true

// Each bar is kept as a handful of price levels with the volume that traded there
int SLOTS = 8
float atr50 = ta.atr(50)

type BarVolume
    float lo
    float hi
    array<float> px
    array<float> vol

newBar() =>
    bool hasVol = not na(volume) and volume > 0
    int n = array.size(ltfClose)
    array<float> px = array.new<float>()
    array<float> vl = array.new<float>()
    // a print further than three ATRs from the bar's body is a bad tick, not a trade,
    // so the bar's range is capped there and anything beyond it counts at the edge
    float bodyLo = math.min(open, close)
    float bodyHi = math.max(open, close)
    float cap = nz(atr50, high - low) * 3
    float lo = math.max(low, bodyLo - cap)
    float hi = math.min(high, bodyHi + cap)
    float rng = hi - lo
    if ltfOK and n > 1 and rng > 0
        // one print carrying many times the volume of the bar's typical print (a closing
        // auction on a cash index or a stock, a feed glitch) is capped at ten times the
        // bar's median print, so a single print can't own the profile
        array<float> vols = array.new<float>()
        for i = 0 to n - 1
            array.push(vols, hasVol ? nz(array.get(ltfVol, i)) : 1.0)
        float med = array.median(vols)
        float vCap = med > 0 ? med * 10 : na
        array<float> slot = array.new<float>(SLOTS, 0.0)
        for i = 0 to n - 1
            float v = array.get(vols, i)
            if not na(vCap)
                v := math.min(v, vCap)
            float p = math.min(hi, math.max(lo, array.get(ltfClose, i)))
            int s = math.min(SLOTS - 1, math.max(0, int((p - lo) / rng * SLOTS)))
            array.set(slot, s, array.get(slot, s) + v)
        for s = 0 to SLOTS - 1
            float v = array.get(slot, s)
            if v > 0
                array.push(px, lo + rng * (s + 0.5) / SLOTS)
                array.push(vl, v)
    if array.size(px) == 0
        // no intrabar data: spread the bar's volume over its range, most of it in the body
        float v = hasVol ? volume : 1.0
        if hi > lo
            array<float> wt = array.new<float>(SLOTS, 0.0)
            float wsum = 0.0
            for s = 0 to SLOTS - 1
                float p = lo + (hi - lo) * (s + 0.5) / SLOTS
                float ws = p >= bodyLo and p <= bodyHi ? 3.0 : 1.0
                array.set(wt, s, ws)
                wsum += ws
            for s = 0 to SLOTS - 1
                array.push(px, lo + (hi - lo) * (s + 0.5) / SLOTS)
                array.push(vl, v * array.get(wt, s) / wsum)
        else
            array.push(px, close)
            array.push(vl, v)
    // the bar's reach on the grid is where its volume sits, not its full wick
    BarVolume.new(array.min(px), array.max(px), px, vl)

bool active = last_bar_index - bar_index <= calcBars

var array<BarVolume> bars = array.new<BarVolume>()
if last_bar_index - bar_index <= calcBars + window
    array.push(bars, newBar())
    if array.size(bars) > window
        array.shift(bars)

// ───────────────────────── Profile ─────────────────────────

// The value area of the cluster the control sits in. First walk out from the control
// while the profile stays busy: the cluster ends where the next two rows average less
// than the gap floor. Then grow from the control, one row at a time toward whichever
// side carries more volume in the next two rows, until the area holds the given share
// of the cluster's volume. A second cluster beyond a thin stretch is left out, so the
// cloud describes where business is being done now instead of stretching across both.
float gapFrac = 0.15
vaRows(array<float> d, int fromRow, float share, float floorVol) =>
    int cLo = fromRow
    int cHi = fromRow
    while cHi < nRows - 1
        float nxtUp = cHi < nRows - 2 ? (array.get(d, cHi + 1) + array.get(d, cHi + 2)) / 2 : array.get(d, cHi + 1)
        if nxtUp < floorVol
            break
        cHi += 1
    while cLo > 0
        float nxtDn = cLo > 1 ? (array.get(d, cLo - 1) + array.get(d, cLo - 2)) / 2 : array.get(d, cLo - 1)
        if nxtDn < floorVol
            break
        cLo -= 1
    float total = 0.0
    for r = cLo to cHi
        total += array.get(d, r)
    float target = total * share
    float acc = array.get(d, fromRow)
    int lo = fromRow
    int hi = fromRow
    while acc < target and (lo > cLo or hi < cHi)
        float up = hi < cHi ? array.get(d, hi + 1) + (hi < cHi - 1 ? array.get(d, hi + 2) : 0.0) : -1.0
        float dn = lo > cLo ? array.get(d, lo - 1) + (lo > cLo + 1 ? array.get(d, lo - 2) : 0.0) : -1.0
        if up >= dn
            hi += 1
            acc += array.get(d, hi)
        else
            lo -= 1
            acc += array.get(d, lo)
    [lo, hi]

int nb = array.size(bars)
float winLo = na
float winHi = na
float rowH = na
array<float> prof = array.new<float>(nRows, 0.0)
array<float> dens = array.new<float>(nRows, 0.0)
int pocRow = 0
int vaLo = 0
int vaHi = 0
float pocVol = 0.0
float rowMax = 0.0
var float pocPrev = na
var float vahPrev = na
var float valPrev = na

if active and nb > 0
    for i = 0 to nb - 1
        BarVolume bb = array.get(bars, i)
        winLo := na(winLo) ? bb.lo : math.min(winLo, bb.lo)
        winHi := na(winHi) ? bb.hi : math.max(winHi, bb.hi)
    rowH := (winHi - winLo) / nRows
    if rowH > 0
        // stack the bars into rows, newest bars at full weight
        for i = 0 to nb - 1
            BarVolume bb = array.get(bars, i)
            float w = fade ? math.pow(1.0 - (nb - 1 - i) / window, 1.5) : 1.0
            int np = array.size(bb.px)
            if np > 0
                for j = 0 to np - 1
                    int r = math.min(nRows - 1, math.max(0, int((array.get(bb.px, j) - winLo) / rowH)))
                    array.set(prof, r, array.get(prof, r) + array.get(bb.vol, j) * w)
        // control and value area are read off a 3-row smoothed profile, so a busy
        // area beats a single busy row and the control doesn't flip between clusters
        rowMax := array.max(prof)
        for r = 0 to nRows - 1
            float c = array.get(prof, r)
            float u = r < nRows - 1 ? array.get(prof, r + 1) : 0.0
            float d = r > 0 ? array.get(prof, r - 1) : 0.0
            array.set(dens, r, 0.5 * c + 0.25 * (u + d))
        // point of control, sticky: another area needs clearly more volume to take it over
        for r = 0 to nRows - 1
            float v = array.get(dens, r)
            if v > pocVol
                pocVol := v
                pocRow := r
        if not na(pocPrev)
            int pr = int((pocPrev - winLo) / rowH)
            if pr >= 0 and pr < nRows and array.get(dens, pr) >= pocVol * 0.80
                pocRow := pr
        // value area with hysteresis: an edge only moves once last bar's edge
        // has fallen outside the band between 4% less and 4% more volume
        float floorVol = pocVol * gapFrac
        [lo70, hi70] = vaRows(dens, pocRow, vaPct / 100, floorVol)
        [lo66, hi66] = vaRows(dens, pocRow, (vaPct - 4) / 100, floorVol)
        [lo74, hi74] = vaRows(dens, pocRow, (vaPct + 4) / 100, floorVol)
        vaLo := lo70
        vaHi := hi70
        if not na(vahPrev)
            int ph = math.round((vahPrev - winLo) / rowH) - 1
            if ph >= hi66 and ph <= hi74 and ph >= pocRow
                vaHi := ph
        if not na(valPrev)
            int pl = math.round((valPrev - winLo) / rowH)
            if pl >= lo74 and pl <= lo66 and pl <= pocRow
                vaLo := pl

float valRaw = rowH > 0 ? winLo + vaLo * rowH : na
float vahRaw = rowH > 0 ? winLo + (vaHi + 1) * rowH : na
float pocRaw = rowH > 0 ? winLo + (pocRow + 0.5) * rowH : na
pocPrev := pocRaw
vahPrev := vahRaw
valPrev := valRaw

// a short median takes out one and two bar jumps
float vahM = ta.median(vahRaw, 5)
float valM = ta.median(valRaw, 5)

// an edge can only move so far per bar (half an ATR by default), or a tenth of what's
// left of a long trip, whichever is more. A relocation of value is then a slope over
// several bars that eases into the new level instead of a wall.
float maxStep = nz(atr50, high - low) * stepIn
limited(float target, float prev) =>
    float gap = target - prev
    float step = math.min(math.abs(gap), math.max(maxStep, math.abs(gap) / 10))
    prev + math.sign(gap) * step
var float vahL = na
var float valL = na
if na(vahM) or na(valM) or na(vahL) or na(valL)
    vahL := vahM
    valL := valM
else
    vahL := limited(vahM, vahL)
    valL := limited(valM, valL)

// a short smoothing rounds the corners
float vah = ta.ema(vahL, smoothLen)
float val = ta.ema(valL, smoothLen)
float mid = (vah + val) / 2

// the control is held at one level until the busy row moves a full row away,
// so grid drift doesn't nudge the line
var float pocLevel = na
if na(pocRaw)
    pocLevel := na
else if na(pocLevel) or math.abs(pocRaw - pocLevel) >= rowH
    pocLevel := pocRaw

// which side of the control price is on, two closes to flip
var int pocSide = 0
var int sideRun = 0
int rawSide = close > pocLevel ? 1 : close < pocLevel ? -1 : pocSide
if rawSide == pocSide
    sideRun := 0
else
    sideRun += 1
    if sideRun >= 2 or pocSide == 0
        pocSide := rawSide
        sideRun := 0

// ───────────────────────── Events ─────────────────────────

int side = close > vah ? 1 : close < val ? -1 : 0
var int state = 0
var int cand = 0
var int hold = 0
int evt = 0     // 1 accepted above, -1 accepted below, 2 back in from above, -2 back in from below
int quiet = 0   // 3 value caught up to price, 4 value moved below price, 5 value moved above price
if side == state
    hold := 0
else
    hold := side == cand ? hold + 1 : 1
    if hold >= holdBars
        // only count it if price did the moving: over the confirming bars, price must have
        // travelled at least as far as the edge it crossed moved toward it
        int dir = side == 0 ? (state == 1 ? -1 : 1) : side
        bool useTop = side == 1 or (side == 0 and state == 1)
        float edgeNow = useTop ? vah : val
        float edgeThen = useTop ? vah[holdBars] : val[holdBars]
        float priceMove = (close - close[holdBars]) * dir
        float edgeMove = (edgeThen - edgeNow) * dir
        bool moved = priceMove > 0 and priceMove >= edgeMove
        if moved
            evt := side == 0 ? (state == 1 ? 2 : -2) : side
        else
            quiet := side == 0 ? 3 : side == 1 ? 4 : 5
        state := side
        hold := 0
cand := side

bool fire = evt != 0 and barstate.isconfirmed
var int lastEvt = 0
var int lastEvtBar = na
if fire
    lastEvt := evt
    lastEvtBar := bar_index
else if quiet != 0 and barstate.isconfirmed
    lastEvt := quiet
    lastEvtBar := bar_index

// ───────────────────────── Cloud ─────────────────────────

// while value is in transit the cloud fades, and comes back to full strength once it
// has arrived. A faint trail is value on the move, a bright cloud is value at rest.
float atrRef = nz(atr50, high - low)
float travel = (math.abs(vahM - vah) + math.abs(valM - val)) / 2
float transit = nz(ta.ema(math.min(1.0, math.max(0.0, (travel - atrRef * 0.5) / (atrRef * 2))), 10))

int tShift = (3 - strength) * 3
trans(int base) => int(math.round(math.min(99, math.max(10, base + tShift + transit * 18))))

pM  = plot(mid, "", color = na, display = display.none, editable = false)
pU1 = plot(mid + (vah - mid) * 1 / 7, "", color = na, display = display.none, editable = false)
pU2 = plot(mid + (vah - mid) * 2 / 7, "", color = na, display = display.none, editable = false)
pU3 = plot(mid + (vah - mid) * 3 / 7, "", color = na, display = display.none, editable = false)
pU4 = plot(mid + (vah - mid) * 4 / 7, "", color = na, display = display.none, editable = false)
pU5 = plot(mid + (vah - mid) * 5 / 7, "", color = na, display = display.none, editable = false)
pU6 = plot(mid + (vah - mid) * 6 / 7, "", color = na, display = display.none, editable = false)
pU7 = plot(vah, "", color = na, display = display.none, editable = false)
pL1 = plot(mid - (mid - val) * 1 / 7, "", color = na, display = display.none, editable = false)
pL2 = plot(mid - (mid - val) * 2 / 7, "", color = na, display = display.none, editable = false)
pL3 = plot(mid - (mid - val) * 3 / 7, "", color = na, display = display.none, editable = false)
pL4 = plot(mid - (mid - val) * 4 / 7, "", color = na, display = display.none, editable = false)
pL5 = plot(mid - (mid - val) * 5 / 7, "", color = na, display = display.none, editable = false)
pL6 = plot(mid - (mid - val) * 6 / 7, "", color = na, display = display.none, editable = false)
pL7 = plot(val, "", color = na, display = display.none, editable = false)

// faint in the middle, densest at the edges
fill(pM,  pU1, color = color.new(colCloud, trans(95)), title = "Cloud")
fill(pU1, pU2, color = color.new(colCloud, trans(93)), title = "Cloud")
fill(pU2, pU3, color = color.new(colCloud, trans(91)), title = "Cloud")
fill(pU3, pU4, color = color.new(colCloud, trans(88)), title = "Cloud")
fill(pU4, pU5, color = color.new(colCloud, trans(85)), title = "Cloud")
fill(pU5, pU6, color = color.new(colCloud, trans(81)), title = "Cloud")
fill(pU6, pU7, color = color.new(colCloud, trans(76)), title = "Cloud")
fill(pM,  pL1, color = color.new(colCloud, trans(95)), title = "Cloud")
fill(pL1, pL2, color = color.new(colCloud, trans(93)), title = "Cloud")
fill(pL2, pL3, color = color.new(colCloud, trans(91)), title = "Cloud")
fill(pL3, pL4, color = color.new(colCloud, trans(88)), title = "Cloud")
fill(pL4, pL5, color = color.new(colCloud, trans(85)), title = "Cloud")
fill(pL5, pL6, color = color.new(colCloud, trans(81)), title = "Cloud")
fill(pL6, pL7, color = color.new(colCloud, trans(76)), title = "Cloud")

// point of control as level segments. Drawn 5 bars behind so segments that
// didn't last 5 bars can be left out, and the last 5 bars are drawn live.
int minSeg = 5
color pocCol = pocSide == 1 ? colUp : colDn
float lvl = pocLevel[5]
bool segOk = false
if not na(lvl)
    int run = 1
    for j = 1 to 5
        if pocLevel[5 - j] == lvl
            run += 1
        else
            break
    for j = 1 to 5
        if pocLevel[5 + j] == lvl
            run += 1
        else
            break
    segOk := run >= minSeg
bool newSeg = na(pocLevel[6]) or pocLevel[5] != pocLevel[6]
plot(showPoc and segOk and not newSeg ? lvl : na, "Point of control", color = pocCol[5], linewidth = 1, style = plot.style_linebr, offset = -5, display = display.pane)
bool liveTail = last_bar_index - bar_index <= 5
plot(showPoc and liveTail and pocLevel == pocLevel[1] ? pocLevel : na, "Point of control (last bars)", color = pocCol, linewidth = 1, style = plot.style_linebr, display = display.pane)

plotshape(showMarks and fire and evt == -2, "Back into value from below", shape.circle, location.belowbar, color = colUp, size = size.tiny, display = display.pane)
plotshape(showMarks and fire and evt == 2, "Back into value from above", shape.circle, location.abovebar, color = colDn, size = size.tiny, display = display.pane)
plotshape(showMarks and fire and evt == 1, "Accepted above value", shape.triangleup, location.abovebar, color = colUp, size = size.tiny, display = display.pane)
plotshape(showMarks and fire and evt == -1, "Accepted below value", shape.triangledown, location.belowbar, color = colDn, size = size.tiny, display = display.pane)

// ───────────────────────── Profile at the right edge ─────────────────────────

var array<box> sideBoxes = array.new<box>()
if barstate.islast
    if array.size(sideBoxes) > 0
        for i = 0 to array.size(sideBoxes) - 1
            box.delete(array.get(sideBoxes, i))
        array.clear(sideBoxes)
    if showSide and rowH > 0 and rowMax > 0
        float gap = rowH * 0.08
        for r = 0 to nRows - 1
            float v = array.get(prof, r)
            if v > 0
                int len = math.max(1, math.round(sideWidth * v / rowMax))
                bool inVa = r >= vaLo and r <= vaHi
                color c = r == pocRow ? color.new(colCloud, 10) : inVa ? color.new(colCloud, 55) : color.new(#787B86, 78)
                array.push(sideBoxes, box.new(bar_index + 1, winLo + (r + 1) * rowH - gap, bar_index + 1 + len, winLo + r * rowH + gap, border_width = 0, bgcolor = c))

// ───────────────────────── Panel ─────────────────────────

eventName(int e) =>
    switch e
        1  => "Accepted above value"
        -1 => "Accepted below value"
        2  => "Back into value from above"
        -2 => "Back into value from below"
        3  => "Value caught up to price"
        4  => "Value moved below price"
        5  => "Value moved above price"
        => "None yet"

eventColor(int e, color up, color dn, color plain) =>
    e == 1 or e == -2 ? up : e == -1 or e == 2 ? dn : plain

fmtPrice(float x) =>
    x >= 100000 ? str.tostring(x, format.volume) : str.tostring(x, format.mintick)

var table panel = na
if showPanel and barstate.islast
    if na(panel)
        tablePos = switch panelPos
            "Top left"     => position.top_left
            "Bottom left"  => position.bottom_left
            "Bottom right" => position.bottom_right
            => position.top_right
        panel := table.new(tablePos, 2, 5, bgcolor = color.new(colPanel, 15), frame_color = color.new(colPanel, 0), frame_width = 1, border_width = 0)
    txtSize = panelSize == "Small" ? size.small : panelSize == "Large" ? size.large : size.normal
    color txt = #D1D4DC
    color dim = color.new(#D1D4DC, 40)
    string tfName = pickTF == "1" ? "1 minute" : pickTF == "5" ? "5 minute" : pickTF == "15" ? "15 minute" : pickTF == "60" ? "1 hour" : "4 hour"
    string volNote = not symbolHasVol ? "no volume, time at price" : ltfSeen ? tfName + " volume" : "bar volume"
    string sideTxt = side == 1 ? "Above value" : side == -1 ? "Below value" : "Inside value"
    bool pending = (evt != 0 or quiet != 0) and not barstate.isconfirmed
    string priceTxt = pending ? sideTxt + ", confirms on close" : side == state ? sideTxt : sideTxt + ", close " + str.tostring(hold) + " of " + str.tostring(holdBars)
    color priceCol = side == 1 ? colUp : side == -1 ? colDn : txt
    bool abovePoc = pocSide == 1
    int agoBars = na(lastEvtBar) ? 0 : bar_index - lastEvtBar
    string ago = na(lastEvtBar) ? "" : agoBars == 0 ? ", this bar" : agoBars == 1 ? ", 1 bar ago" : ", " + str.tostring(agoBars) + " bars ago"
    table.cell(panel, 0, 0, "PROFILE MASTER", text_color = txt, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 0, volNote, text_color = dim, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 1, "Price", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 1, priceTxt, text_color = priceCol, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 2, "Point of control", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 2, abovePoc ? "Price above it" : "Price below it", text_color = abovePoc ? colUp : colDn, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 3, "Value area", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 3, fmtPrice(val) + " to " + fmtPrice(vah), text_color = txt, text_size = txtSize, text_halign = text.align_right)
    table.cell(panel, 0, 4, "Last event", text_color = dim, text_size = txtSize, text_halign = text.align_left)
    table.cell(panel, 1, 4, eventName(lastEvt) + ago, text_color = eventColor(lastEvt, colUp, colDn, txt), text_size = txtSize, text_halign = text.align_right)

// ───────────────────────── Alerts ─────────────────────────

alertcondition(fire and evt == 1,  "Accepted above value", "Profile Master: price accepted above the value area")
alertcondition(fire and evt == -1, "Accepted below value", "Profile Master: price accepted below the value area")
alertcondition(fire and evt == 2,  "Back into value from above", "Profile Master: price is back inside the value area from above")
alertcondition(fire and evt == -2, "Back into value from below", "Profile Master: price is back inside the value area from below")
````
