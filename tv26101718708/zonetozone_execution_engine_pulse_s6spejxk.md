# Zone-to-Zone Execution Engine + Pulse

- url: https://www.tradingview.com/script/S6sPeJxk-Zone-to-Zone-Execution-Engine-Pulse/
- type: indicator
- pine_id: PUB;7e86724bc09c48f98fbbde84bb14156f
- version: 2.0

## Description

It marks areas where price previously moved away strongly, and assumes price may react there again.

These are:

Demand zones (where buying previously started)
Supply zones (where selling previously started)

Think of them as:

“places where something unfinished happened”

🟦 Step 1 — Identify zones

When you see a blue box:

That is a reaction zone
Price left that area with strength before

You don’t predict anything yet.

You just mark:

“this is a decision area”

🧭 Step 2 — Wait for price to return

You do NOTHING until price comes back to a zone.

There are only 3 situations:

1. Price approaches zone

→ prepare

2. Price enters zone

→ watch reaction closely

3. Price leaves zone

→ decision happens here

⚡ Step 3 — Watch reaction (this is the entire strategy)

When price touches the zone, you look for ONE thing:

Does it reject or break?

🔵 Bullish zone (demand)
Good reaction:
price dips into zone
wick below / push into it
then closes back up

👉 Meaning:

buyers defended the area

Expectation:

move up toward next supply zone
Bad reaction:
price falls through and keeps going

👉 Meaning:

zone failed

Ignore it after break

🔴 Bearish zone (supply)
Good reaction:
price pushes into zone
wicks above
closes back down

👉 Meaning:

sellers defended the area

Expectation:

move down toward next demand zone
Bad reaction:
price breaks through and holds above

👉 Zone is dead

📊 Step 4 — The only real rule: zone-to-zone movement

You are not trading bounces.

You are trading movement between zones:

Demand → Supply
Supply → Demand

That’s it.

🧠 Simple mental model

Think of price like this:

It builds pressure at zones
It releases toward the next zone
It repeats

So your job is NOT prediction.

It’s:

“Which zone is price leaving, and which zone is it likely heading to next?”

⚠️ What NOT to do

Avoid:

trading every touch
entering before reaction
assuming every zone will hold
forcing reversals in strong trends
🔥 Beginner rule (most important)

Only act after:

price touches a zone AND shows rejection

Not before.

🧭 One-line summary

Zone-to-zone trading is:

“Wait for price to hit a zone, confirm rejection, then ride it toward the next opposite zone.”

## Source Code

````pine
//@version=5
indicator("Zone-to-Zone Execution Engine + Pulse", overlay=true, max_boxes_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atrLength     = input.int(14, "ATR Length")
mult          = input.float(1.2, "Displacement Mult")
minSpacingATR = input.float(1.5, "Min Zone Spacing (ATR)")
expireBars    = input.int(1500, "Expire Broken Zones (0 = off)")

showDemand    = input.bool(true)
showSupply    = input.bool(true)

// Zone compression
bodyPercent   = input.float(0.35, "Body Compression %", step=0.05, minval=0.1, maxval=1.0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STYLE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
demandZoneColor = input.color(color.green, "Demand Zone Color")
supplyZoneColor = input.color(color.red, "Supply Zone Color")

bullPulseColor  = input.color(color.lime, "Bull Pulse Color")
bearPulseColor  = input.color(color.red, "Bear Pulse Color")

zoneOpacity     = input.int(85, "Zone Opacity", minval=0, maxval=100)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLength)

// Displacement candles
bullDisplacement = (high - low) > atr * mult and close > open
bearDisplacement = (high - low) > atr * mult and close < open

// Base candle logic
bullBase = close[1] < open[1]
bearBase = close[1] > open[1]

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var box[] zones = array.new_box()
var int[] type  = array.new_int()
var int[] state = array.new_int()
var int[] born  = array.new_int()
var bool[] used = array.new_bool()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SAFE SPACING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_tooClose(_mid) =>
    float minDist = atr * minSpacingATR
    bool blocked = false

    if array.size(zones) > 0
        for i = 0 to array.size(zones) - 1
            z = array.get(zones, i)
            mid = (box.get_top(z) + box.get_bottom(z)) / 2

            if math.abs(mid - _mid) < minDist
                blocked := true

    blocked

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CREATE ZONE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_createZone(_top, _bot, _type) =>

    zoneColor = _type == 1
         ? color.new(demandZoneColor, zoneOpacity)
         : color.new(supplyZoneColor, zoneOpacity)

    b = box.new(
         left = bar_index,
         top = _top,
         right = bar_index,
         bottom = _bot,
         bgcolor = zoneColor,
         border_width = 0)

    array.push(zones, b)
    array.push(type, _type)
    array.push(state, 0)
    array.push(born, bar_index)
    array.push(used, false)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COMPRESSED BODY ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// Demand Zone
if showDemand and bullDisplacement and bullBase

    bodyTop = math.max(open[1], close[1])
    bodyBot = math.min(open[1], close[1])

    bodySize = bodyTop - bodyBot
    compressed = bodySize * bodyPercent

    dTop = bodyTop
    dBot = bodyTop - compressed

    dMid = (dTop + dBot) / 2

    if not f_tooClose(dMid)
        f_createZone(dTop, dBot, 1)

// Supply Zone
if showSupply and bearDisplacement and bearBase

    bodyTop = math.max(open[1], close[1])
    bodyBot = math.min(open[1], close[1])

    bodySize = bodyTop - bodyBot
    compressed = bodySize * bodyPercent

    sTop = bodyBot + compressed
    sBot = bodyBot

    sMid = (sTop + sBot) / 2

    if not f_tooClose(sMid)
        f_createZone(sTop, sBot, -1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// EXECUTION ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool bullPulse = false
bool bearPulse = false

int sz = array.size(zones)

if sz > 0
    for i = sz - 1 to 0

        if i < array.size(zones)

            z = array.get(zones, i)
            t = array.get(type, i)
            s = array.get(state, i)
            u = array.get(used, i)

            top = box.get_top(z)
            bot = box.get_bottom(z)
            mid = (top + bot) / 2

            box.set_right(z, bar_index)

            touched = high >= bot and low <= top

            sweepUp   = high > top and close < top
            sweepDown = low < bot and close > bot

            // Activate after first touch
            if touched and not u
                array.set(used, i, true)
                array.set(state, i, 1)

            // Bull pulse
            if t == 1 and s == 1 and sweepDown and close > mid
                bullPulse := true

            // Bear pulse
            if t == -1 and s == 1 and sweepUp and close < mid
                bearPulse := true

            // Expire old zones
            age = bar_index - array.get(born, i)

            if expireBars > 0 and age > expireBars
                box.delete(z)

                array.remove(zones, i)
                array.remove(type, i)
                array.remove(state, i)
                array.remove(born, i)
                array.remove(used, i)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// VISUAL OUTPUT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
plotshape(
     bullPulse,
     title="Bull Pulse",
     style=shape.circle,
     location=location.belowbar,
     size=size.tiny,
     color=bullPulseColor)

plotshape(
     bearPulse,
     title="Bear Pulse",
     style=shape.circle,
     location=location.abovebar,
     size=size.tiny,
     color=bearPulseColor)
````
