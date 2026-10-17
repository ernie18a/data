# Fibonacci Singularity

- url: https://www.tradingview.com/script/Re4Vmqvn-Fibonacci-Singularity/
- type: indicator
- pine_id: PUB;ef8fb3e0051b4ed1a883e11ff2fdb6e6
- version: 1.0

## Description

Fibonacci singularity is an advanced fibonacci confluence engine designed to find the price zones where multiple fibonacci levels from confirmed market legs collapse into the same area.

instead of drawing one simple fibonacci retracement, the script analyzes several confirmed swing legs, calculates multiple fibonacci retracement and extension levels, then groups the strongest overlapping levels into institutional confluence zones.

the goal is to give the trader a clean map of high-interest price areas where the market may react, reject, pause, break, or build a new directional move.

this tool is not a buy or sell signal system. it is a market structure and confluence map. it should be used with price action, trend context, volume, risk management, and personal confirmation.

main features

confirmed pivot-based fibonacci engine
clean zigzag swing logic
multi-leg fibonacci confluence
non-overlapping confluence zones
automatic merge of zones that touch or overlap
minimum block gap between zones
s-tier, a-tier, b-tier, and c-tier zone classification
walk-forward respect percentage
real volume micro profile inside each zone
right-side density micro profile
volume, touch density, reaction pressure, or composite profile source
volume delta in labels
zone pressure reading
dominant reference fibonacci
fibonacci time zones
magnet targets above and below price
institutional-style dashboard
sober visual style
price-in-zone alerts
upside magnet alerts
downside magnet alerts

how the script works

the script first detects confirmed pivots.

a confirmed pivot high or pivot low appears only after enough bars have closed on both sides of the pivot. this makes the structure cleaner and avoids using unconfirmed swing points.

after pivots are confirmed, the script builds several market legs from the most recent valid zigzag swings.

for each leg, the script calculates important fibonacci levels such as retracements and extensions.

then it groups nearby fibonacci levels into confluence zones.

when several fibonacci levels fall inside the same price area, the zone becomes stronger.

if two zones touch or overlap, the script merges them instead of stacking blocks on top of each other.

each final zone is displayed as a clean block with a center line, optional label, internal profile, and right-side density profile.

the strongest zones are ranked by overlap, strength, and tier.

important concept

a zone is not a guaranteed reversal point.

a zone means that several fibonacci levels are concentrated in the same price area.

the more confluence a zone has, the more important it can become as a decision area.

a trader can use these zones to prepare possible reactions, breakouts, retests, or profit-taking areas.

input guide

pivot strength

this controls how strong a pivot must be before it is accepted.

a higher value creates fewer but stronger swing points.

a lower value creates more swings and makes the engine more reactive.

for beginners:
use a higher value for cleaner zones.
use a lower value only if you want more sensitivity.

active legs

this controls how many confirmed swing legs are used by the confluence engine.

more legs create more historical fibonacci levels and more possible confluence.

fewer legs focus only on recent market structure.

for beginners:
use 4 to 6 legs for a balanced view.
use more legs if you want a wider historical confluence map.

min leg range

this filters out small swing legs.

the value is based on atr.

if a leg is too small, the script ignores it because small legs can create weak or noisy fibonacci levels.

for beginners:
increase this value if the chart has too much noise.
decrease it if the script finds too few zones.

zone width

this controls the width of each fibonacci confluence zone.

the value is based on atr.

a higher value creates wider zones and groups more levels together.

a lower value creates tighter zones and separates levels more aggressively.

for beginners:
use a moderate value to avoid zones that are too wide or too fragmented.

minimum block gap

this controls the minimum space between displayed blocks.

if two zones touch, overlap, or become too close, they are merged so the chart remains clean.

this is important because zones should not stack on top of each other.

for beginners:
increase this value if the zones look too close.
decrease it if you want more detailed separation.

max confluence zones

this controls how many confluence zones can be displayed.

a lower value gives a cleaner chart.

a higher value shows more market structure.

for beginners:
start with 4 to 6 zones.
increase only if you need more context.

min overlap to qualify

this defines how many fibonacci levels must overlap before a zone becomes valid.

a higher value makes zones more selective.

a lower value allows more zones to appear.

for beginners:
use a higher value for stronger zones.
use a lower value only if the market has too few visible zones.

atr length

this controls the atr calculation used for zone width, minimum range, and spacing.

a higher value makes the system smoother.

a lower value makes it react faster to recent volatility.

for beginners:
use 50 for stable behavior.
lower it if you want faster adaptation.

s-tier overlap

this defines the minimum overlap needed for a zone to become s-tier.

s-tier is the strongest classification.

these zones represent the highest fibonacci concentration.

a-tier overlap

this defines the minimum overlap needed for a zone to become a-tier.

a-tier zones are strong but not as extreme as s-tier zones.

b-tier overlap

this defines the minimum overlap needed for a zone to become b-tier.

b-tier zones are medium confluence areas.

c-tier zones

c-tier is used when a zone qualifies but does not reach b-tier, a-tier, or s-tier strength.

enable walk-forward respect percent

this enables the respect percentage calculation.

the script checks how price reacts after a zone exists.

this is cleaner than testing a current zone on old data before the zone was created.

respect window

this controls how many bars are used to measure zone respect.

a larger window gives more historical reaction data.

a smaller window focuses on recent behavior.

for beginners:
use 300 bars for a balanced reading.

min touches to score

this defines the minimum number of touches needed before the respect percentage is considered valid.

if a zone has too few touches, the statistic is not reliable.

for beginners:
keep this at 2 or higher.

show real volume micro profile

this displays a micro profile inside each zone.

the profile uses the real volume available from the chart and distributes it across the zone according to the candle overlap with the zone.

this is not tick-by-tick volume at price. it is the most realistic stable approximation available from regular candle volume in pine.

show right density micro profile

this displays a technical density profile on the right side of each zone.

it helps visualize which parts of the zone had more interaction, pressure, or volume.

right density source

this selects what the right-side density profile is based on.

volume:
uses chart volume.

touch density:
counts how often price interacts with each part of the zone.

reaction pressure:
measures candle reaction strength around the zone.

composite:
combines volume when available with interaction and reaction pressure.

for beginners:
use composite for the most balanced profile.

profile window

this controls how many bars are scanned to build the internal and right-side profiles.

a larger value gives more historical context.

a smaller value focuses on recent market behavior.

for beginners:
use 300 bars as a balanced default.

micro profile rows

this controls how many rows are displayed inside each zone.

more rows give more detail but use more drawing objects.

fewer rows are cleaner and lighter.

for beginners:
use 6 to 8 rows.

max internal profile length

this controls the maximum length of the internal micro profile bars inside each zone.

a higher value makes profile bars longer and more visible.

a lower value keeps the blocks cleaner.

minimum cell width

this ensures every profile row remains visible even when volume or density is low.

this helps every zone keep a technical structure instead of appearing empty.

show volume delta in labels

this adds bull and bear volume difference information into the zone label.

a positive delta means more bullish volume pressure.

a negative delta means more bearish volume pressure.

show confluence zones

this turns the main fibonacci confluence blocks on or off.

when disabled, the engine still calculates data, but the blocks are hidden.

zone history length

this controls how far the zone blocks extend into the past.

a higher value makes zones longer.

a lower value keeps the chart more compact.

show density profile right

this displays the right-side profile structure.

this is useful for quickly comparing zone strength and internal distribution.

profile max length

this controls the maximum visual length of the right-side density profile.

higher values make strong profiles longer.

lower values keep the profile compact.

show zone labels

this shows or hides zone labels.

labels can display the tier, overlap count, price level, respect percentage, delta, and pressure information.

show dominant reference fib

this displays the dominant reference fibonacci from the most important recent leg.

this helps the trader understand which recent swing is guiding the current fibonacci map.

show fibonacci time zones

this displays vertical fibonacci time projections from the latest confirmed pivot.

these are not price signals.

they are timing reference points where the trader can watch for possible market reaction.

show dashboard

this shows the institutional dashboard.

the dashboard summarizes bias, active legs, zones found, top zone, magnets, price position, respect information, and engine status.

dashboard position

this controls where the dashboard appears on the chart.

available positions:
top right
top left
bottom right
bottom left
middle right

bull / b-tier color

this controls the color used for bullish or b-tier visual elements.

bear / a-tier color

this controls the color used for bearish or a-tier visual elements.

singularity / s color

this controls the color used for the strongest s-tier zones.

neutral / c color

this controls the color used for lower-tier or neutral elements.

panel background

this controls the dashboard background color.

panel border

this controls the dashboard border color.

mini tutorial for beginners

step 1: start with clean settings

keep the default settings first.

do not change everything immediately.

the script is designed to find fibonacci confluence zones from confirmed swing legs, so you should first observe how the zones behave on your market and timeframe.

step 2: understand the zones

a zone is an area where several fibonacci levels overlap.

if a zone has a high tier, it means more fibonacci levels are concentrated there.

s-tier is the strongest.

a-tier is strong.

b-tier is medium.

c-tier is weaker but still qualified.

step 3: use zones as decision areas

do not buy or sell only because price touches a zone.

wait for confirmation.

possible confirmations:
wick rejection
strong candle close
breakout
retest
volume reaction
trend alignment
market structure shift

step 4: read the internal micro profile

inside each zone, the micro profile shows where volume or interaction is concentrated.

a larger internal bar means stronger activity in that part of the zone.

this can help identify whether price is reacting near the top, middle, or bottom of the zone.

step 5: read the right-side density profile

the right-side profile gives a fast technical view of the zone.

if the profile is strong and balanced, the zone has more structural importance.

if the profile is thin, the zone may be weaker or less tested.

step 6: use the respect percentage

respect percentage shows how often price reacted from a zone after the zone existed.

a high respect value can mean the zone has been historically reactive.

a low respect value can mean the zone has been ignored or broken often.

do not use respect percentage alone.

combine it with price action.

step 7: use the magnet targets

the up magnet is the nearest important zone above price.

the down magnet is the nearest important zone below price.

these can be used as possible target areas, resistance areas, support areas, or places where price may slow down.

step 8: use the dashboard

the dashboard gives a quick summary of the current state.

watch:
bias
active legs
zones found
top zone
up magnet
down magnet
price position
respect data
engine status

if the panel says waiting or no qualified zone, the script does not yet have enough valid confluence to display a strong zone.

step 9: choose the right timeframe

for intraday trading, use the script to locate major reaction areas.

for swing trading, use higher timeframes for stronger zones.

zones from higher timeframes often carry more weight than small lower timeframe zones.

step 10: build a simple trading plan

bullish example:
price pulls back into a strong confluence zone.
the zone has a good respect percentage.
the internal profile shows strong activity.
price prints a bullish rejection.
the trader can then watch for a possible long setup.

bearish example:
price rallies into a strong confluence zone.
the zone is a-tier or s-tier.
the right-side profile shows strong interaction.
price rejects with a bearish candle.
the trader can then watch for a possible short setup.

breakout example:
price reaches a strong zone but does not reject.
price closes strongly beyond the zone.
the trader can then watch for continuation or a retest.

best beginner settings

pivot strength:
8 to 12 for cleaner swings.

active legs:
4 to 6 for balanced confluence.

min leg range:
0.5 atr or higher to remove small noisy swings.

zone width:
0.5 to 0.8 atr for practical zone size.

minimum block gap:
increase if zones look too close.

micro profile rows:
6 to 8 for clean internal detail.

right density source:
composite for the most balanced view.

profile window:
300 bars for a balanced profile.

important note

this indicator does not guarantee profit.

fibonacci confluence zones can fail.

a strong zone can break.

a high respect percentage does not guarantee the next reaction.

always use stop loss, position sizing, risk management, and personal confirmation before entering a trade.

the best use of this script is as a technical map of high-interest fibonacci zones, not as an automatic trading system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("FIBONACCI SINGULARITY", shorttitle="FIBS", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500, max_bars_back=5000)

gE = "═══ CONFLUENCE ENGINE (CONFIRMED) ═══"
pivLen     = input.int(8, "Pivot Strength (L/R)", minval=2, maxval=100, group=gE, tooltip="Confirmed swing detection. Pivots confirm after this many bars.")
nLegs      = input.int(6, "Active Legs", minval=2, maxval=20, group=gE, tooltip="How many confirmed zigzag legs feed the confluence engine.")
minRngMult = input.float(0.5, "Min Leg Range (× ATR)", minval=0.0, step=0.1, group=gE, tooltip="Ignore swing legs smaller than this ATR multiple.")
clusterMlt = input.float(0.6, "Zone Width (× ATR)", minval=0.05, step=0.05, group=gE, tooltip="Bandwidth used to group nearby fibonacci levels into one institutional zone.")
zoneGapMlt = input.float(0.05, "Minimum Block Gap (× ATR)", minval=0.0, step=0.01, group=gE, tooltip="Minimum space between rendered blocks. If candidate zones touch or overlap, they are merged into one block.")
maxZones   = input.int(6, "Max Confluence Zones", minval=1, maxval=12, group=gE)
minOverlap = input.int(2, "Min Overlap to Qualify", minval=2, maxval=10, group=gE, tooltip="A zone needs at least this many overlapping fibonacci levels to qualify.")
atrLen     = input.int(50, "ATR Length", minval=2, group=gE)

gT = "═══ CONFLUENCE TIERS ═══"
tierS = input.int(6, "S-Tier overlap ≥", minval=2, group=gT, tooltip="Highest confluence tier.")
tierA = input.int(4, "A-Tier overlap ≥", minval=2, group=gT)
tierB = input.int(3, "B-Tier overlap ≥", minval=2, group=gT)

gR = "═══ WALK-FORWARD RESPECT ═══"
showRespect = input.bool(true, "Enable Walk-Forward Respect %", group=gR, tooltip="Only counts touches and reactions after the zone birth bar, never before it.")
respectBars = input.int(300, "Respect Window (bars)", minval=20, maxval=1500, group=gR)
minTouch    = input.int(2, "Min Touches to Score", minval=1, group=gR)

gV = "═══ REAL MICRO PROFILE INSIDE BLOCKS ═══"
showBlockVolume = input.bool(true, "Show Real Volume Micro Profile", group=gV, tooltip="Draws a row-by-row micro volume profile inside every zone using real chart volume allocated by candle overlap inside the block.")
showRightMicroProfile = input.bool(true, "Show Right Density Micro Profile", group=gV, tooltip="Draws a technical profile on the right side of each zone using the selected real-data source.")
densitySource   = input.string("Composite", "Right Density Source", options=["Volume", "Touch Density", "Reaction Pressure", "Composite"], group=gV, tooltip="Volume uses real chart volume. Touch Density counts real price interaction. Reaction Pressure weights candle body strength. Composite combines volume when available with interaction pressure.")
volumeBars      = input.int(300, "Profile Window (bars)", minval=20, maxval=1500, group=gV)
profileRows     = input.int(20, "Micro Profile Rows", minval=3, maxval=20, group=gV, tooltip="Number of internal rows used inside each zone. Higher values are more detailed but use more drawing boxes.")
volBarMaxLen    = input.int(35, "Max Internal Profile Length", minval=5, maxval=120, group=gV)
microCellMinLen = input.int(1, "Minimum Cell Width", minval=1, maxval=5, group=gV, tooltip="Minimum visible width of each profile row, so every zone keeps a technical profile structure even when volume is limited or unavailable.")
showDeltaInLbl  = input.bool(true, "Show Volume Delta In Labels", group=gV)

gD = "═══ DISPLAY ═══"
showZones   = input.bool(true, "Show Confluence Zones", group=gD)
zoneBack    = input.int(180, "Zone History Length (bars)", minval=10, maxval=500, group=gD)
showProfile = input.bool(true, "Show Density Profile (right)", group=gD)
profileMax  = input.int(45, "Profile Max Length (bars)", minval=5, maxval=200, group=gD)
showZoneLbl = input.bool(true, "Show Zone Labels", group=gD)
showDom     = input.bool(true, "Show Dominant Reference Fib", group=gD)
showTZ      = input.bool(false, "Show Fibonacci Time Zones", group=gD)
showDash    = input.bool(true, "Show Dashboard", group=gD)
dashPos     = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=gD)

gU = "═══ INSTITUTIONAL COLORS ═══"
colBull    = input.color(#2F8F83, "Bull / B-Tier", group=gU)
colBear    = input.color(#9A3D45, "Bear / A-Tier", group=gU)
colGold    = input.color(color.rgb(44, 133, 143), "Singularity / S", group=gU)
colNeutral = input.color(#6F7A86, "Neutral / C", group=gU)
colPanel   = input.color(#0E131B, "Panel Background", group=gU)
colGrid    = input.color(#1D2733, "Panel Border", group=gU)

f2s(float x) => na(x) ? "—" : str.tostring(x, format.mintick)
fVol(float x) => na(x) ? "—" : x >= 1000000000 ? str.tostring(x / 1000000000.0, "0.00") + "b" : x >= 1000000 ? str.tostring(x / 1000000.0, "0.00") + "m" : x >= 1000 ? str.tostring(x / 1000.0, "0.0") + "k" : str.tostring(x, "0")
ratioW(float r) => (r == 0.618 or r == 0.786) ? 1.60 : r == 0.705 ? 1.40 : r == 0.5 ? 1.25 : r == 1.0 ? 1.10 : r == 0.382 ? 1.00 : r == 0.886 ? 0.90 : r == 0.236 ? 0.70 : 0.85
tierOf(int c) => c >= tierS ? "S" : c >= tierA ? "A" : c >= tierB ? "B" : "C"
tierColOf(string t) => t == "S" ? colGold : t == "A" ? colBear : t == "B" ? colBull : colNeutral
tierTrOf(string t) => t == "S" ? 82 : t == "A" ? 86 : t == "B" ? 89 : 92
pushLvl(array<float> ap, array<float> aw, array<float> ar, array<int> ab, float price, float w, float ratio, int birthBar) =>
    array.push(ap, price)
    array.push(aw, w)
    array.push(ar, ratio)
    array.push(ab, birthBar)
clearBoxes(array<box> a) =>
    for x in a
        box.delete(x)
    array.clear(a)
clearLines(array<line> a) =>
    for x in a
        line.delete(x)
    array.clear(a)
clearLabels(array<label> a) =>
    for x in a
        label.delete(x)
    array.clear(a)
clearFloats(array<float> a) => array.clear(a)
clearStrs(array<string> a) => array.clear(a)
clearInts(array<int> a) => array.clear(a)

atr = ta.atr(atrLen)
ph = ta.pivothigh(pivLen, pivLen)
pl = ta.pivotlow(pivLen, pivLen)

var array<float> pvtP = array.new<float>()
var array<int> pvtB = array.new<int>()
var array<bool> pvtH = array.new<bool>()
maxPvt = (nLegs + 5) * 3

f_addPivot(float _p, int _b, bool _isHigh) =>
    int _sz = array.size(pvtP)
    if _sz == 0
        array.push(pvtP, _p)
        array.push(pvtB, _b)
        array.push(pvtH, _isHigh)
    else
        bool _lastH = array.get(pvtH, _sz - 1)
        float _lastP = array.get(pvtP, _sz - 1)
        if _lastH == _isHigh
            bool _replace = _isHigh ? _p > _lastP : _p < _lastP
            if _replace
                array.set(pvtP, _sz - 1, _p)
                array.set(pvtB, _sz - 1, _b)
                array.set(pvtH, _sz - 1, _isHigh)
        else
            array.push(pvtP, _p)
            array.push(pvtB, _b)
            array.push(pvtH, _isHigh)
    while array.size(pvtP) > maxPvt
        array.shift(pvtP)
        array.shift(pvtB)
        array.shift(pvtH)

if not na(ph)
    f_addPivot(ph, bar_index - pivLen, true)
if not na(pl)
    f_addPivot(pl, bar_index - pivLen, false)

var array<float> zCen = array.new<float>()
var array<float> zLo = array.new<float>()
var array<float> zHi = array.new<float>()
var array<int> zCnt = array.new<int>()
var array<string> zTier = array.new<string>()
var array<float> zResp = array.new<float>()
var array<float> zStr = array.new<float>()
var array<float> zVol = array.new<float>()
var array<float> zBullVol = array.new<float>()
var array<float> zBearVol = array.new<float>()
var array<float> zPressure = array.new<float>()
var array<int> zBirth = array.new<int>()

var int biasUp = na
var int legCount = na
var float upMagnet = na
var float dnMagnet = na
var float strongHi = na
var float strongLo = na
var float topZoneVol = na
var float topZoneResp = na
var float topZonePressure = na

var array<box> zoneBoxes = array.new<box>()
var array<box> profBoxes = array.new<box>()
var array<box> volBoxes = array.new<box>()
var array<line> zoneLines = array.new<line>()
var array<label> zoneLbls = array.new<label>()
var array<line> domLines = array.new<line>()
var array<label> domLbls = array.new<label>()
var array<line> tzLines = array.new<line>()

f_zoneMetrics(float _lo, float _hi, int _birth, int _bars) =>
    float _tot = 0.0
    float _bull = 0.0
    float _bear = 0.0
    int _touch = 0
    int _react = 0
    int _breaks = 0
    int _limRaw = math.min(_bars, bar_index - 1)
    int _lim = math.max(0, _limRaw)
    if _lim > 0
        for k = 0 to _lim - 1
            int _b = bar_index - k
            if _b > _birth
                float _rng = math.max(high[k] - low[k], syminfo.mintick)
                float _ov = math.max(0.0, math.min(high[k], _hi) - math.max(low[k], _lo))
                if _ov > 0.0
                    float _part = math.min(1.0, _ov / _rng)
                    float _v = nz(volume[k], 0.0) * _part
                    _tot += _v
                    if close[k] >= open[k]
                        _bull += _v
                    else
                        _bear += _v
                    _touch += 1
                    bool _bounceUp = low[k] <= _hi and close[k] > _hi and close[k] > open[k]
                    bool _bounceDn = high[k] >= _lo and close[k] < _lo and close[k] < open[k]
                    if _bounceUp or _bounceDn
                        _react += 1
                    if close[k] > _hi or close[k] < _lo
                        _breaks += 1
    [_tot, _bull, _bear, _touch, _react, _breaks]

f_fillZoneMicroProfile(float _lo, float _hi, int _birth, int _bars, int _rows, array<float> _rowVol, array<float> _rowBull, array<float> _rowBear, array<float> _rowDens) =>
    array.clear(_rowVol)
    array.clear(_rowBull)
    array.clear(_rowBear)
    array.clear(_rowDens)
    for r = 0 to _rows - 1
        array.push(_rowVol, 0.0)
        array.push(_rowBull, 0.0)
        array.push(_rowBear, 0.0)
        array.push(_rowDens, 0.0)
    float _zoneH = math.max(_hi - _lo, syminfo.mintick)
    float _tot = 0.0
    float _bull = 0.0
    float _bear = 0.0
    float _maxVol = 0.0
    float _maxDens = 0.0
    int _limRaw = math.min(_bars, bar_index - 1)
    int _lim = math.max(0, _limRaw)
    if _lim > 0
        for k = 0 to _lim - 1
            int _b = bar_index - k
            if _b > _birth
                float _rng = math.max(high[k] - low[k], syminfo.mintick)
                float _bodyPower = math.abs(close[k] - open[k]) / _rng
                bool _isBull = close[k] >= open[k]
                bool _bounceUp = low[k] <= _hi and close[k] > _hi and close[k] > open[k]
                bool _bounceDn = high[k] >= _lo and close[k] < _lo and close[k] < open[k]
                float _volBase = nz(volume[k], 0.0)
                for r = 0 to _rows - 1
                    float _rLo = _lo + _zoneH * r / _rows
                    float _rHi = _lo + _zoneH * (r + 1) / _rows
                    float _ov = math.max(0.0, math.min(high[k], _rHi) - math.max(low[k], _rLo))
                    if _ov > 0.0
                        float _part = math.min(1.0, _ov / _rng)
                        float _v = _volBase * _part
                        float _touchDensity = _part
                        float _reactionPressure = (_bounceUp or _bounceDn ? 1.0 : 0.35) * _bodyPower * _part
                        float _density = densitySource == "Volume" ? _v : densitySource == "Touch Density" ? _touchDensity : densitySource == "Reaction Pressure" ? _reactionPressure : (_volBase > 0.0 ? _v * (1.0 + _bodyPower) : _touchDensity + _reactionPressure)
                        float _oldV = array.get(_rowVol, r)
                        float _oldD = array.get(_rowDens, r)
                        array.set(_rowVol, r, _oldV + _v)
                        array.set(_rowDens, r, _oldD + _density)
                        if _isBull
                            array.set(_rowBull, r, array.get(_rowBull, r) + _v)
                            _bull += _v
                        else
                            array.set(_rowBear, r, array.get(_rowBear, r) + _v)
                            _bear += _v
                        _tot += _v
    if _tot == 0.0 and _lim > 0
        for k = 0 to _lim - 1
            float _rng = math.max(high[k] - low[k], syminfo.mintick)
            float _bodyPower = math.abs(close[k] - open[k]) / _rng
            bool _isBull = close[k] >= open[k]
            bool _bounceUp = low[k] <= _hi and close[k] > _hi and close[k] > open[k]
            bool _bounceDn = high[k] >= _lo and close[k] < _lo and close[k] < open[k]
            float _volBase = nz(volume[k], 0.0)
            for r = 0 to _rows - 1
                float _rLo = _lo + _zoneH * r / _rows
                float _rHi = _lo + _zoneH * (r + 1) / _rows
                float _ov = math.max(0.0, math.min(high[k], _rHi) - math.max(low[k], _rLo))
                if _ov > 0.0
                    float _part = math.min(1.0, _ov / _rng)
                    float _v = _volBase * _part
                    float _touchDensity = _part
                    float _reactionPressure = (_bounceUp or _bounceDn ? 1.0 : 0.35) * _bodyPower * _part
                    float _density = densitySource == "Volume" ? _v : densitySource == "Touch Density" ? _touchDensity : densitySource == "Reaction Pressure" ? _reactionPressure : (_volBase > 0.0 ? _v * (1.0 + _bodyPower) : _touchDensity + _reactionPressure)
                    array.set(_rowVol, r, array.get(_rowVol, r) + _v)
                    array.set(_rowDens, r, array.get(_rowDens, r) + _density)
                    if _isBull
                        array.set(_rowBull, r, array.get(_rowBull, r) + _v)
                        _bull += _v
                    else
                        array.set(_rowBear, r, array.get(_rowBear, r) + _v)
                        _bear += _v
                    _tot += _v
    for r = 0 to _rows - 1
        _maxVol := math.max(_maxVol, array.get(_rowVol, r))
        _maxDens := math.max(_maxDens, array.get(_rowDens, r))
    [_tot, _bull, _bear, _maxVol, _maxDens]

if barstate.islast
    clearBoxes(zoneBoxes)
    clearBoxes(profBoxes)
    clearBoxes(volBoxes)
    clearLines(zoneLines)
    clearLabels(zoneLbls)
    clearLines(domLines)
    clearLabels(domLbls)
    clearLines(tzLines)
    clearFloats(zCen)
    clearFloats(zLo)
    clearFloats(zHi)
    clearInts(zCnt)
    clearStrs(zTier)
    clearFloats(zResp)
    clearFloats(zStr)
    clearFloats(zVol)
    clearFloats(zBullVol)
    clearFloats(zBearVol)
    clearFloats(zPressure)
    clearInts(zBirth)
    biasUp := na
    legCount := na
    upMagnet := na
    dnMagnet := na
    strongHi := na
    strongLo := na
    topZoneVol := na
    topZoneResp := na
    topZonePressure := na

    float minRange = atr * minRngMult
    array<float> retrRatios = array.from(0.382, 0.5, 0.618, 0.705, 0.786, 0.886, 1.0)
    array<float> extRatios = array.from(1.272, 1.618)
    array<float> levP = array.new<float>()
    array<float> levW = array.new<float>()
    array<float> levR = array.new<float>()
    array<int> levB = array.new<int>()
    float domNP = na
    float domOP = na
    int domNB = na
    int domOB = na
    int np = array.size(pvtP)
    int legsBuilt = 0
    int i = np - 1
    while i >= 1 and legsBuilt < nLegs
        float pN = array.get(pvtP, i)
        int bN = array.get(pvtB, i)
        float pO = array.get(pvtP, i - 1)
        int bO = array.get(pvtB, i - 1)
        if math.abs(pN - pO) >= minRange
            float recW = 1.0 - 0.5 * (legsBuilt / math.max(1, nLegs - 1))
            float rng = pN - pO
            int birthB = bN + pivLen
            for r in retrRatios
                pushLvl(levP, levW, levR, levB, pN + (pO - pN) * r, ratioW(r) * recW, r, birthB)
            for e in extRatios
                pushLvl(levP, levW, levR, levB, pN + rng * (e - 1.0), ratioW(e) * recW, e, birthB)
            if legsBuilt == 0
                domNP := pN
                domOP := pO
                domNB := bN
                domOB := bO
            legsBuilt += 1
        i -= 1
    legCount := legsBuilt
    biasUp := na(domNP) ? na : domNP > domOP ? 1 : -1

    int n = array.size(levP)
    if n > 0
        array<int> idx = array.new<int>()
        for k = 0 to n - 1
            array.push(idx, k)
        if n > 1
            for a = 0 to n - 2
                int mn = a
                for b = a + 1 to n - 1
                    if array.get(levP, array.get(idx, b)) < array.get(levP, array.get(idx, mn))
                        mn := b
                if mn != a
                    int t = array.get(idx, a)
                    array.set(idx, a, array.get(idx, mn))
                    array.set(idx, mn, t)

        float bw = atr * clusterMlt
        float minBlockGap = atr * zoneGapMlt
        array<float> cCen = array.new<float>()
        array<float> cStr = array.new<float>()
        array<int> cCnt = array.new<int>()
        array<float> cLo = array.new<float>()
        array<float> cHi = array.new<float>()
        array<int> cBirth = array.new<int>()
        int ii = 0
        while ii < n
            float startP = array.get(levP, array.get(idx, ii))
            float sumW = 0.0
            float sumWP = 0.0
            int cnt = 0
            float lo = startP
            float hi = startP
            int birth = 0
            int jj = ii
            while jj < n
                int realIdx = array.get(idx, jj)
                float pj = array.get(levP, realIdx)
                if pj - startP <= bw
                    float wj = array.get(levW, realIdx)
                    sumW += wj
                    sumWP += wj * pj
                    cnt += 1
                    hi := pj
                    birth := math.max(birth, array.get(levB, realIdx))
                    jj += 1
                else
                    break
            if cnt >= minOverlap
                array.push(cCen, sumWP / sumW)
                array.push(cStr, sumW)
                array.push(cCnt, cnt)
                array.push(cLo, lo - bw * 0.15)
                array.push(cHi, hi + bw * 0.15)
                array.push(cBirth, birth)
            ii := jj

        array<float> mCen = array.new<float>()
        array<float> mStr = array.new<float>()
        array<int> mCnt = array.new<int>()
        array<float> mLo = array.new<float>()
        array<float> mHi = array.new<float>()
        array<int> mBirth = array.new<int>()
        int nc = array.size(cCen)
        if nc > 0
            for k = 0 to nc - 1
                float cen = array.get(cCen, k)
                float str = array.get(cStr, k)
                int cnt = array.get(cCnt, k)
                float lo = array.get(cLo, k)
                float hi = array.get(cHi, k)
                int birth = array.get(cBirth, k)
                int ms = array.size(mCen)
                if ms == 0
                    array.push(mCen, cen)
                    array.push(mStr, str)
                    array.push(mCnt, cnt)
                    array.push(mLo, lo)
                    array.push(mHi, hi)
                    array.push(mBirth, birth)
                else
                    int last = ms - 1
                    float lastHi = array.get(mHi, last)
                    if lo <= lastHi + minBlockGap
                        float oldC = array.get(mCen, last)
                        float oldS = array.get(mStr, last)
                        float newS = oldS + str
                        float newC = (oldC * oldS + cen * str) / newS
                        array.set(mCen, last, newC)
                        array.set(mStr, last, newS)
                        array.set(mCnt, last, array.get(mCnt, last) + cnt)
                        array.set(mLo, last, math.min(array.get(mLo, last), lo))
                        array.set(mHi, last, math.max(array.get(mHi, last), hi))
                        array.set(mBirth, last, math.max(array.get(mBirth, last), birth))
                    else
                        array.push(mCen, cen)
                        array.push(mStr, str)
                        array.push(mCnt, cnt)
                        array.push(mLo, lo)
                        array.push(mHi, hi)
                        array.push(mBirth, birth)

        int nm = array.size(mCen)
        array<int> mIdx = array.new<int>()
        if nm > 0
            for k = 0 to nm - 1
                array.push(mIdx, k)
        if nm > 1
            for a = 0 to nm - 2
                int mx = a
                for b = a + 1 to nm - 1
                    if array.get(mStr, array.get(mIdx, b)) > array.get(mStr, array.get(mIdx, mx))
                        mx := b
                if mx != a
                    int t = array.get(mIdx, a)
                    array.set(mIdx, a, array.get(mIdx, mx))
                    array.set(mIdx, mx, t)

        int keep = math.min(maxZones, array.size(mIdx))
        float maxStr = keep > 0 ? array.get(mStr, array.get(mIdx, 0)) : 1.0
        float maxVol = 1.0
        if keep > 0
            for z = 0 to keep - 1
                int mi = array.get(mIdx, z)
                float cen = array.get(mCen, mi)
                float lo = array.get(mLo, mi)
                float hi = array.get(mHi, mi)
                float str = array.get(mStr, mi)
                int cnt = array.get(mCnt, mi)
                int birth = array.get(mBirth, mi)
                [totV, bullV, bearV, touches, reacts, breaks] = f_zoneMetrics(lo, hi, birth, math.max(respectBars, volumeBars))
                float respPct = showRespect and touches >= minTouch ? (reacts / touches) * 100.0 : na
                array.push(zCen, cen)
                array.push(zLo, lo)
                array.push(zHi, hi)
                array.push(zCnt, cnt)
                array.push(zTier, tierOf(cnt))
                array.push(zResp, respPct)
                array.push(zStr, str)
                array.push(zVol, totV)
                array.push(zBullVol, bullV)
                array.push(zBearVol, bearV)
                array.push(zPressure, na)
                array.push(zBirth, birth)
                maxVol := math.max(maxVol, totV)

        if array.size(zCen) > 0
            int leftB = math.max(0, bar_index - zoneBack)
            for z = 0 to array.size(zCen) - 1
                float cen = array.get(zCen, z)
                float bLo = array.get(zLo, z)
                float bHi = array.get(zHi, z)
                int cnt = array.get(zCnt, z)
                float str = array.get(zStr, z)
                string tName = array.get(zTier, z)
                color tCol = tierColOf(tName)
                float respPct = array.get(zResp, z)
                float totV = array.get(zVol, z)
                float bullV = array.get(zBullVol, z)
                float bearV = array.get(zBearVol, z)
                float delta = totV > 0 ? (bullV - bearV) / totV * 100.0 : na
                if showZones
                    box bx = box.new(leftB, bHi, bar_index, bLo, xloc=xloc.bar_index, border_color=color.new(tCol, 35), border_width=1, bgcolor=color.new(tCol, tierTrOf(tName)))
                    array.push(zoneBoxes, bx)
                    line ln = line.new(leftB, cen, bar_index, cen, xloc=xloc.bar_index, color=color.new(tCol, 20), width=tName == "S" ? 2 : 1, style=tName == "S" ? line.style_solid : line.style_dotted)
                    array.push(zoneLines, ln)
                array<float> rowVol = array.new<float>()
                array<float> rowBull = array.new<float>()
                array<float> rowBear = array.new<float>()
                array<float> rowDens = array.new<float>()
                [microTot, microBull, microBear, rowMaxVol, rowMaxDens] = f_fillZoneMicroProfile(bLo, bHi, array.get(zBirth, z), volumeBars, profileRows, rowVol, rowBull, rowBear, rowDens)
                if microTot > 0.0
                    totV := microTot
                    bullV := microBull
                    bearV := microBear
                    array.set(zVol, z, totV)
                    array.set(zBullVol, z, bullV)
                    array.set(zBearVol, z, bearV)
                delta := totV > 0 ? (bullV - bearV) / totV * 100.0 : na
                float respVal = na(respPct) ? 0.0 : respPct
                float deltaAbs = na(delta) ? 0.0 : math.abs(delta)
                float zonePressure = math.min(100.0, (str / maxStr) * 35.0 + math.min(float(cnt) / math.max(float(tierS), 1.0), 1.0) * 25.0 + respVal * 0.25 + math.min(deltaAbs, 100.0) * 0.15)
                array.set(zPressure, z, zonePressure)
                float h = math.max(bHi - bLo, syminfo.mintick)
                if showBlockVolume
                    for r = 0 to profileRows - 1
                        float rLo = bLo + h * r / profileRows
                        float rHi = bLo + h * (r + 1) / profileRows
                        float rv = array.get(rowVol, r)
                        float rb = array.get(rowBull, r)
                        float rs = array.get(rowBear, r)
                        bool rowBullDom = rb >= rs
                        color rowCol = rv > 0 ? (rowBullDom ? colBull : colBear) : colNeutral
                        int rowLen = rowMaxVol > 0 ? math.max(microCellMinLen, math.round((rv / rowMaxVol) * volBarMaxLen)) : microCellMinLen
                        box vb = box.new(leftB + 1, rHi, leftB + 1 + rowLen, rLo, xloc=xloc.bar_index, border_color=color.new(rowCol, 70), bgcolor=color.new(rowCol, rv > 0 ? 38 : 82))
                        array.push(volBoxes, vb)
                if showProfile and showRightMicroProfile
                    for r = 0 to profileRows - 1
                        float rLo = bLo + h * r / profileRows
                        float rHi = bLo + h * (r + 1) / profileRows
                        float rd = array.get(rowDens, r)
                        float rb = array.get(rowBull, r)
                        float rs = array.get(rowBear, r)
                        bool rowBullDom = rb >= rs
                        color rowCol = (densitySource == "Volume" or densitySource == "Composite") ? (rowBullDom ? colBull : colBear) : tCol
                        int rowLen = rowMaxDens > 0 ? math.max(microCellMinLen, math.round((rd / rowMaxDens) * profileMax)) : microCellMinLen
                        box pb = box.new(bar_index + 2, rHi, bar_index + 2 + rowLen, rLo, xloc=xloc.bar_index, border_color=color.new(rowCol, 70), bgcolor=color.new(rowCol, rd > 0 ? 42 : 82))
                        array.push(profBoxes, pb)
                if showProfile and not showRightMicroProfile
                    int len = math.max(2, math.round((str / maxStr) * profileMax))
                    box pb = box.new(bar_index + 2, bHi, bar_index + 2 + len, bLo, xloc=xloc.bar_index, border_color=color.new(tCol, 35), border_width=1, bgcolor=color.new(tCol, 55))
                    array.push(profBoxes, pb)
                if showZoneLbl
                    string rTxt = na(respPct) ? "" : "  r " + str.tostring(respPct, "0") + "%"
                    string vTxt = showDeltaInLbl ? "  v " + fVol(totV) + (na(delta) ? "" : "  Δ " + str.tostring(delta, "0") + "%") : ""
                    string pTxt = "  p " + str.tostring(zonePressure, "0")
                    string txt = tName + " ×" + str.tostring(cnt) + "  " + f2s(cen) + rTxt + vTxt + pTxt
                    label lb = label.new(bar_index + 4 + (showProfile ? profileMax : 0), cen, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(tCol, 82), textcolor=tCol, size=size.tiny)
                    array.push(zoneLbls, lb)

            strongHi := array.get(zHi, 0)
            strongLo := array.get(zLo, 0)
            topZoneVol := array.get(zVol, 0)
            topZoneResp := array.get(zResp, 0)
            topZonePressure := array.get(zPressure, 0)
            for z = 0 to array.size(zCen) - 1
                float c = array.get(zCen, z)
                if c > close
                    upMagnet := na(upMagnet) ? c : math.min(upMagnet, c)
                if c < close
                    dnMagnet := na(dnMagnet) ? c : math.max(dnMagnet, c)

    if showDom and not na(domNP)
        for r in array.from(0.5, 0.618, 0.705, 0.786)
            float p = domNP + (domOP - domNP) * r
            line ln = line.new(math.min(domNB, domOB), p, bar_index, p, xloc=xloc.bar_index, color=color.new(colNeutral, 55), width=1, style=line.style_dashed, extend=extend.right)
            array.push(domLines, ln)
        line dl = line.new(domOB, domOP, domNB, domNP, xloc=xloc.bar_index, color=color.new(colGold, 45), width=1, style=line.style_dotted)
        array.push(domLines, dl)

    if showTZ and array.size(pvtB) > 0
        int baseB = array.get(pvtB, array.size(pvtB) - 1)
        for off in array.from(3, 5, 8, 13, 21, 34, 55)
            int xb = baseB + off
            if xb <= bar_index + 480
                line tl = line.new(xb, close, xb, close + syminfo.mintick, xloc=xloc.bar_index, color=color.new(colGold, 70), width=1, style=line.style_dotted, extend=extend.both)
                array.push(tzLines, tl)

inStrong = not na(strongHi) and close <= strongHi and close >= strongLo
nearUp = not na(upMagnet) and high >= upMagnet and high[1] < upMagnet
nearDn = not na(dnMagnet) and low <= dnMagnet and low[1] > dnMagnet
alertcondition(inStrong and not inStrong[1], "APEX • Enter Singularity Zone", "APEX FIB SINGULARITY — price entered strongest confluence zone")
alertcondition(nearUp, "APEX • Hit Upside Magnet", "APEX FIB SINGULARITY — upside magnet target reached")
alertcondition(nearDn, "APEX • Hit Downside Magnet", "APEX FIB SINGULARITY — downside magnet target reached")

posSel = dashPos == "Top Right" ? position.top_right : dashPos == "Top Left" ? position.top_left : dashPos == "Bottom Right" ? position.bottom_right : dashPos == "Bottom Left" ? position.bottom_left : position.middle_right
var table dash = table.new(posSel, 2, 13, bgcolor=color.new(colPanel, 4), frame_color=color.new(colGrid, 25), frame_width=1, border_color=color.new(colGrid, 40), border_width=1)
cell(int c, int r, string t, color tc, color bg) => table.cell(dash, c, r, t, text_color=tc, bgcolor=bg, text_size=size.small, text_halign=text.align_left)

if showDash and barstate.islast
    string biasTxt = na(biasUp) ? "—" : biasUp == 1 ? "🟢 bullish" : "🔴 bearish"
    color biasCol = na(biasUp) ? colNeutral : biasUp == 1 ? colBull : colBear
    string topTxt = array.size(zCen) > 0 ? "calibrating" : "no qualified zone"
    string upTxt = "—"
    string dnTxt = "—"
    string posTxt = array.size(zCen) > 0 ? "neutral" : "waiting"
    color topCol = colNeutral
    color posCol = colNeutral
    if array.size(zCen) > 0
        string tn = array.get(zTier, 0)
        topCol := tierColOf(tn)
        float rp = array.get(zResp, 0)
        topTxt := tn + " ×" + str.tostring(array.get(zCnt, 0)) + "  " + f2s(array.get(zCen, 0)) + (na(rp) ? "" : "  " + str.tostring(rp, "0") + "%")
        for z = 0 to array.size(zCen) - 1
            if close <= array.get(zHi, z) and close >= array.get(zLo, z)
                posTxt := "inside " + array.get(zTier, z) + " zone"
                posCol := tierColOf(array.get(zTier, z))
                break
    if not na(upMagnet)
        upTxt := f2s(upMagnet) + "  +" + str.tostring((upMagnet - close) / close * 100.0, "0.00") + "%"
    if not na(dnMagnet)
        dnTxt := f2s(dnMagnet) + "  " + str.tostring((dnMagnet - close) / close * 100.0, "0.00") + "%"
    color pressureCol = na(topZonePressure) ? colNeutral : topZonePressure >= 70 ? colGold : topZonePressure >= 45 ? colBull : colNeutral
    cell(0, 0, "🏛 fib singularity", colGold, color.new(colPanel, 0)), cell(1, 0, "institutional", color.new(colGold, 0), color.new(colPanel, 0))
    cell(0, 1, "🧭 bias", colNeutral, color.new(colGrid, 45)), cell(1, 1, biasTxt, biasCol, color.new(colGrid, 45))
    cell(0, 2, "🦵 active legs", colNeutral, color.new(colPanel, 10)), cell(1, 2, na(legCount) ? "—" : str.tostring(legCount), color.new(#C7D3E0, 0), color.new(colPanel, 10))
    cell(0, 3, "🧱 zones found", colNeutral, color.new(colGrid, 45)), cell(1, 3, str.tostring(array.size(zCen)), color.new(#C7D3E0, 0), color.new(colGrid, 45))
    cell(0, 4, "⭐ top zone", colNeutral, color.new(colPanel, 10)), cell(1, 4, topTxt, topCol, color.new(colPanel, 10))
    cell(0, 5, "🧲 up magnet", colNeutral, color.new(colGrid, 45)), cell(1, 5, upTxt, colBull, color.new(colGrid, 45))
    cell(0, 6, "🧲 down magnet", colNeutral, color.new(colPanel, 10)), cell(1, 6, dnTxt, colBear, color.new(colPanel, 10))
    cell(0, 7, "📍 price position", colNeutral, color.new(colGrid, 45)), cell(1, 7, posTxt, posCol, color.new(colGrid, 45))
    cell(0, 8, "📊 top volume", colNeutral, color.new(colPanel, 10)), cell(1, 8, fVol(topZoneVol), color.new(#C7D3E0, 0), color.new(colPanel, 10))
    cell(0, 9, "✅ respect", colNeutral, color.new(colGrid, 45)), cell(1, 9, na(topZoneResp) ? "—" : str.tostring(topZoneResp, "0") + "%", colGold, color.new(colGrid, 45))
    cell(0, 10, "🧪 pressure", colNeutral, color.new(colPanel, 10)), cell(1, 10, na(topZonePressure) ? "—" : str.tostring(topZonePressure, "0") + "/100", pressureCol, color.new(colPanel, 10))
    cell(0, 11, "📐 block rule", colNeutral, color.new(colGrid, 45)), cell(1, 11, "merged / no touch", colBull, color.new(colGrid, 45))
    cell(0, 12, "⚙ engine", colNeutral, color.new(colPanel, 10)), cell(1, 12, "confirmed zigzag", colBull, color.new(colPanel, 10))
````
