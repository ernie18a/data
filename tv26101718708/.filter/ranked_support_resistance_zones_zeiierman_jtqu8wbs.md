# Ranked Support & Resistance Zones (Zeiierman)

- url: https://www.tradingview.com/script/jTQU8WBS-Ranked-Support-Resistance-Zones-Zeiierman/
- type: indicator
- pine_id: PUB;85808ae2658545b5878a4ef7e56e4644
- version: 1.0

## Description

█ [b]Overview[/b]
[b]Ranked Support & Resistance Zones (Zeiierman)[/b] is an adaptive S/R engine that transforms traditional pivot-based support and resistance detection into a dynamic ranking, filtering, and prioritization system.

Instead of plotting every detected level equally, the script stores each support and resistance zone as a structured data object, evaluates its quality in real time using multiple market factors, and continuously ranks all active zones by relative strength.

The result is a cleaner, more intelligent support/resistance framework that focuses on the most relevant zones currently influencing price action.
[image]https://www.tradingview.com/x/sfmCmfPM/[/image]

█ [b]How It Works[/b]

⚪ [b]Structured S/R Zone Engine[/b]
Each detected support or resistance area is stored as a structured UDT object containing its price range, direction, midpoint, width, mitigation state, touch count, volume behavior, trend alignment, swing quality, internal strength, and overall ranking score.

This allows every zone to behave like an active market structure rather than a static horizontal level.

The script detects resistance from confirmed pivot highs and support from confirmed pivot lows. Each pivot is filtered using ATR-normalized swing quality, helping the system adapt across different assets, volatility conditions, and timeframes.

⚪ [b]Dynamic Quality Ranking[/b]
Every S/R zone receives a continuously updated quality score based on:

• Zone width relative to ATR
• Volume behavior
• EMA trend alignment
• Pivot swing quality
• Touch count
• Mitigation progress
• Zone age decay

All S/R zone objects are stored inside an array and ranked using Pine Script’s native UDT collection sorting:
[pine]srZones.sort(order.descending, sort_field = "score")[/pine]
This allows the script to dynamically reorder all active support and resistance zones in real time, prioritizing the strongest market structure while weaker or older zones gradually lose ranking.

⚪ [b]Smart Zone Management[/b]
After sorting, only the highest-ranked zones are displayed on the chart while lower-ranked zones remain internally tracked but hidden from view.

Similar zones of the same direction can be absorbed into an existing zone when they are close enough or meaningfully overlapping. This helps reduce clutter and creates cleaner support/resistance areas instead of stacking many nearby levels.

Each zone also tracks mitigation progress. As price trades deeper into a support or resistance zone, mitigation increases, and the zone’s quality score weakens. When the price closes beyond the ATR-based break buffer, the zone is marked as broken and converted into a broken-zone reference.

⚪ [b]Internal Strength Distribution[/b]
Every active zone contains bullish and bearish internal pressure components displayed as live strength bars inside the zone.

█ [b]How to Use[/b]

⚪ [b]Focus on Top-Ranked Zones[/b]
Only the strongest support and resistance zones are displayed based on current market conditions and quality ranking.
[image]https://www.tradingview.com/x/7g7yoGXY/[/image]

⚪ [b]Read Internal Strength Bars[/b]

• [b]Strong support strength →[/b] stronger demand-side defense
• [b]Strong resistance strength →[/b] stronger supply-side rejection
• [b]Balanced pressure →[/b] weaker or less decisive structure
• [b]Opposing pressure growth →[/b] increasing risk of mitigation or break
[image]https://www.tradingview.com/x/yljvmZSB/[/image]
⚪ [b]Watch for Retests and Mitigation[/b]
Support and resistance zones are most useful when the price revisits them after they form.

[b]Strong reactions often show:[/b]
• Immediate rejection or bounce from the zone
• Respect for the zone boundaries
• Continuation away from the level
• Internal strength remaining aligned with the zone direction

Deeper or repeated retests can weaken the zone over time as mitigation increases and quality decays.
[image]https://www.tradingview.com/x/XMlPckte/[/image]
█ [b]Related Scripts[/b]
[url=https://www.tradingview.com/script/Z4h7vDqN-Ranked-FVG-Imbalance-Zones-Zeiierman/]Ranked FVG Imbalance Zones (Zeiierman)[/url]
[url=https://www.tradingview.com/script/Ce4kPpHV-Ranked-Order-Block-Zones-Zeiierman/]Ranked Order Block Zones (Zeiierman)[/url]

█ [b]Settings[/b]
[list]
[*][b]Show Top Zones:[/b] Controls how many of the highest-ranked support and resistance zones are displayed.
[*][b]Max Stored Zones:[/b] Controls the maximum number of S/R zones that can be tracked internally.
[*][b]Pivot Length:[/b] Defines how many candles are required on each side to confirm a pivot high or pivot low.
[*][b]Min Pivot ATR:[/b] Defines the minimum ATR-normalized pivot strength required for zone creation.
[*][b]Absorb Similar Zones:[/b] Controls how close or overlapping zones must be before they are absorbed into an existing zone.
[*][b]Zone Width ATR:[/b] Controls the thickness of each support/resistance zone.
[*][b]Volume MA Length:[/b] Defines the baseline used for volume behavior scoring.
[*][b]Trend EMA Length:[/b] Defines the EMA used for trend alignment scoring.
[*][b]Break Close Buffer ATR:[/b] Controls how far the price must close beyond a zone before it is considered broken.
[*][b]Keep Broken Zones:[/b] Controls how many broken zones remain visible after invalidation.
[*][b]Direction Filter:[/b] Allows displaying all zones, support-only, or resistance-only.
[*][b]Show Strength Bars:[/b] Shows or hides bullish and bearish internal strength bars inside each zone.
[*][b]Show Zone Text:[/b] Shows or hides smart zone labels such as Weak Support, Strong Resistance, or Mitigated Support.
[/list]
-----------------
Disclaimer

The content provided in my scripts, indicators, ideas, algorithms, and systems is for educational and informational purposes only. It does not constitute financial advice, investment recommendations, or a solicitation to buy or sell any financial instruments. I will not accept liability for any loss or damage, including without limitation any loss of profit, which may arise directly or indirectly from the use of or reliance on such information.

All investments involve risk, and the past performance of a security, industry, sector, market, financial product, trading strategy, backtest, or individual's trading does not guarantee future results or returns. Investors are fully responsible for any investment decisions they make. Such decisions should be based solely on an evaluation of their financial circumstances, investment objectives, risk tolerance, and liquidity needs.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman {
//@version=6
indicator("Ranked Support & Resistance Zones (Zeiierman)", shorttitle = "Ranked S/R Zones (Zeiierman)", overlay = true, max_lines_count = 500, max_boxes_count = 300, max_labels_count = 200)
//}

// ~~ Tooltips {
t1  = "Controls how many of the highest-ranked support and resistance zones are visible on the chart."
t2  = "Maximum number of S/R zones stored internally before the lowest-ranked zones are removed."
t3  = "Pivot confirmation length. Higher values create fewer but more confirmed levels."
t4  = "Minimum pivot displacement measured in ATR. Helps filter weak pivots."
t5  = "Zones closer than this ATR multiple can be absorbed into an existing zone instead of creating duplicates."
t6  = "Zone thickness measured in ATR."
t7  = "Length used to calculate the average volume baseline for the ranking engine."
t8  = "EMA length used to score trend alignment. Support above EMA and resistance below EMA receive stronger scores."
t9  = "Controls how much price must close beyond a zone before it is considered broken."
t10 = "Shows or hides the internal bullish and bearish strength bars inside each S/R zone."
t11 = "Shows or hides smart text inside each S/R zone."
t12 = "Optional filter for visible zones."
t13 = "Deletes zones after this many bars. Also contributes to ranking decay."
t14 = "Shows or hides the compact dashboard."
t15 = "Shows or hides labels when zones break."
t16 = "Controls text size used by strength percentage labels."
t17 = "Controls text size used by zone text labels."
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Inputs {
gRank     = "Ranking"
gDetect   = "Swing Detection"
gScore    = "Strength Engine"
gDisplay  = "Display"
gColors   = "Colors"
gBreaks   = "Breaks"

visibleLimit = input.int(8, "Show Top Zones", minval = 1, maxval = 30, tooltip = t1, group = gRank)
storedLimit  = input.int(60, "Max Stored Zones", minval = 10, maxval = 250, tooltip = t2, group = gRank)

pivotSpan      = input.int(5, "Pivot Length", minval = 2, maxval = 50, tooltip = t3, group = gDetect)
minSwingAtr    = input.float(0.15, "Min Pivot ATR", minval = 0.0, maxval = 5.0, step = 0.05, tooltip = t4, group = gDetect)
absorbAtr      = input.float(0.55, "Absorb Similar Zones", minval = 0.0, maxval = 3.0, step = 0.05, tooltip = t5, group = gDetect)
zoneAtrWidth   = input.float(0.40, "Zone Width ATR", minval = 0.05, maxval = 2.0, step = 0.05, tooltip = t6, group = gDetect)

volLen    = input.int(20, "Volume MA Length", minval = 1, tooltip = t7, group = gScore)
trendLen  = input.int(50, "Trend EMA Length", minval = 1, tooltip = t8, group = gScore)

breakAtr  = input.float(0.12, "Break Close Buffer ATR", minval = 0.0, maxval = 3.0, step = 0.05, tooltip = t9, group = gBreaks)
keepBrokenCount = input.int(4, "Keep Broken Zones", minval = 0, maxval = 30, group = gBreaks)

directionFilter = input.string("All", "Direction Filter", options = ["All", "Support Only", "Resistance Only"], tooltip = t12, group = gDisplay)
showStrengthBars = input.bool(true, "Show Strength Bars", tooltip = t10, group = gDisplay)
showZoneText     = input.bool(true, "Show Zone Text", tooltip = t11, group = gDisplay)
strengthTextSize = input.string("auto", "Strength Text Size", options = ["auto", "tiny", "small", "normal", "large", "huge"], tooltip = t16, group = gDisplay)
zoneTextSize     = input.string("auto", "Zone Text Size", options = ["auto", "tiny", "small", "normal", "large", "huge"], tooltip = t17, group = gDisplay)

supportColor    = input.color(color.rgb(26, 216, 194, 50), "Support", inline = "c", group = gColors)
resistanceColor = input.color(color.rgb(216, 76, 26, 50), "Resistance", inline = "c", group = gColors)
brokenColor     = input.color(color.rgb(148, 163, 184, 72), "Broken", group = gColors)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Core calculations {
atrRaw  = ta.atr(14)
atr     = na(atrRaw) or atrRaw == 0 ? syminfo.mintick * 10.0 : atrRaw
volBase = ta.sma(volume, volLen)
trendBase = ta.ema(close, trendLen)
barMs     = timeframe.in_seconds(timeframe.period) * 1000

pivotHigh = ta.pivothigh(high, pivotSpan, pivotSpan)
pivotLow = ta.pivotlow(low, pivotSpan, pivotSpan)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Zone type {
type RankedZone
    float score
    float top
    float bottom
    float mid
    int   dir
    int   bornBar
    int   leftTime
    float width
    float mitigation
    float touchCount
    float volScore
    float trendScore
    float swingScore
    int   bullStrength
    int   bearStrength
    bool  broken
    line  centerLine
    box   bodyBox
    box   bullBar
    box   bearBar
    label eventLabel

var array<RankedZone> srZones = array.new<RankedZone>()
var array<RankedZone> brokenZones = array.new<RankedZone>()
var string previousLeaderKey = ""
var string lastBreakSide = "None"
var int lastBreakIndex = na

newTopRankAlert = false

supportCreatedAlert = false
resistanceCreatedAlert = false

topSupportAlert = false
topResistanceAlert = false

supportBreakAlert = false
resistanceBreakAlert = false

supportTouchAlert = false
resistanceTouchAlert = false

supportMitigatedAlert = false
resistanceMitigatedAlert = false
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Methods {
method canDisplay(RankedZone z) =>
    directionFilter == "All" or directionFilter == "Support Only" and z.dir == -1 or directionFilter == "Resistance Only" and z.dir == 1

method overlaps(RankedZone z, float newTop, float newBottom, int newDir) =>
    float overlapTop = math.min(z.top, newTop)
    float overlapBottom = math.max(z.bottom, newBottom)
    float overlap = math.max(overlapTop - overlapBottom, 0)
    float smaller = math.min(math.max(z.top - z.bottom, syminfo.mintick), math.max(newTop - newBottom, syminfo.mintick))
    bool sameSide = z.dir == newDir
    bool closeMid = math.abs(z.mid - math.avg(newTop, newBottom)) <= absorbAtr * atr
    bool meaningfulOverlap = overlap / smaller >= 0.35
    sameSide and (closeMid or meaningfulOverlap)

method refreshGeometry(RankedZone z) =>
    line.set_y1(z.centerLine, z.mid)
    line.set_y2(z.centerLine, z.mid)
    line.set_x2(z.centerLine, bar_index + 1)
    box.set_top(z.bodyBox, z.top)
    box.set_bottom(z.bodyBox, z.bottom)
    box.set_right(z.bodyBox, time + barMs * 25)

method deleteZone(RankedZone z) =>
    line.delete(z.centerLine)
    box.delete(z.bodyBox)
    box.delete(z.bullBar)
    box.delete(z.bearBar)
    if not na(z.eventLabel)
        label.delete(z.eventLabel)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Scoring helpers {
swing_quality(float price, int dir) =>
    float quality = 0.0
    if dir == 1
        float localMax = math.max(high[pivotSpan - 1], high[pivotSpan + 1])
        quality := math.max((price - localMax) / atr, 0)
    else
        float localMin = math.min(low[pivotSpan - 1], low[pivotSpan + 1])
        quality := math.max((localMin - price) / atr, 0)
    quality

score(float width, float volScore, float trendScore, float swingScore, float mitigation, float touches, int age) =>
    float sizeNorm = math.min(width / atr, 1.0)
    float volNorm = math.min(volScore / 2.0, 1.0)
    float swingNorm = math.min(swingScore / 1.5, 1.0)
    float touchNorm = math.min(touches / 4.0, 1.0)
    float ageNorm = math.min(age / math.max(450, 1), 1.0)

    float raw = sizeNorm * 20.0 + volNorm * 18.0 + trendScore * 12.0 + swingNorm * 28.0 + touchNorm * 16.0 + 10.0
    float penalty = mitigation * 22.0 + ageNorm * 10.0
    math.max(math.min(raw - penalty, 100.0), 0.0)

strengths(int dir, float score, float trendScore, float mitigation) =>
    float scoreNorm = math.max(math.min(score, 100.0), 0.0)
    float zoneSide = scoreNorm

    if scoreNorm >= 75
        zoneSide := 72 + (scoreNorm - 75) * 1.12
    else if scoreNorm >= 45
        zoneSide := 48 + (scoreNorm - 45) * 0.75
    else
        zoneSide := scoreNorm * 1.05

    zoneSide += trendScore * 6.0
    zoneSide -= mitigation * 28.0
    zoneSide := math.max(math.min(zoneSide, 100.0), 0.0)

    float oppositeSide = 5.0 + mitigation * 65.0 + scoreNorm * 0.08
    oppositeSide := math.max(math.min(oppositeSide, 100.0), 0.0)

    int bull = dir == -1 ? int(zoneSide) : int(oppositeSide)
    int bear = dir == 1 ? int(zoneSide) : int(oppositeSide)
    [bull, bear]

zone_text(RankedZone z) =>
    string txt = ""
    if z.dir == -1
        txt := z.mitigation >= 0.75 ? "Mitigated Support" : z.bullStrength >= 70 ? "Strong Support" : z.bullStrength >= 45 ? "Support" : "Weak Support"
    else
        txt := z.mitigation >= 0.75 ? "Mitigated Resistance" : z.bearStrength >= 70 ? "Strong Resistance" : z.bearStrength >= 45 ? "Resistance" : "Weak Resistance"
    txt
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Create zones {
add_zone(float pivotPrice, int dir, int pivotBar, int pivotTime) =>
    float half = zoneAtrWidth * atr * 0.5
    float top = pivotPrice + half
    float bottom = pivotPrice - half
    float mid = pivotPrice
    float width = math.max(top - bottom, syminfo.mintick)
    float volScore = volBase != 0 ? volume[pivotSpan] / volBase : 1.0
    float trendScore = dir == -1 and pivotPrice > trendBase ? 1.0 : dir == 1 and pivotPrice < trendBase ? 1.0 : 0.0
    float swingScore = swing_quality(pivotPrice, dir)
    float mitigation = 0.0
    float touches = 0.0
    int age = bar_index - pivotBar
    float score = score(width, volScore, trendScore, swingScore, mitigation, touches, age)
    [bullStrength, bearStrength] = strengths(dir, score, trendScore, mitigation)

    bool absorbed = false
    bool created = false

    if srZones.size() > 0
        for i = 0 to srZones.size() - 1
            RankedZone old = srZones.get(i)
            if old.overlaps(top, bottom, dir) and not absorbed
                old.top := math.max(old.top, top)
                old.bottom := math.min(old.bottom, bottom)
                old.mid := math.avg(old.top, old.bottom)
                old.width := math.max(old.top - old.bottom, syminfo.mintick)
                old.bornBar := math.min(old.bornBar, pivotBar)
                old.leftTime := math.min(old.leftTime, pivotTime)
                old.volScore := math.max(old.volScore, volScore)
                old.trendScore := math.max(old.trendScore, trendScore)
                old.swingScore := math.max(old.swingScore, swingScore)
                old.mitigation := 0.0
                old.touchCount += 1.0
                old.score := math.max(old.score, score) + 3.0
                old.bullStrength := math.max(old.bullStrength, bullStrength)
                old.bearStrength := math.max(old.bearStrength, bearStrength)
                old.refreshGeometry()
                srZones.set(i, old)
                absorbed := true

    if not absorbed
        color baseColor = dir == -1 ? supportColor : resistanceColor
        line ln = line.new(pivotBar, mid, bar_index + 1, mid, extend = extend.right, color = color.new(baseColor, 100), width = 1)
        box bx = box.new(left = pivotTime, right = time + barMs * 5, top = top, bottom = bottom, xloc = xloc.bar_time, bgcolor = color.new(baseColor, 78), border_color = color.new(baseColor, 30))
        float zoneMid = math.avg(top, bottom)
        box bearBox = box.new(left = pivotTime, right = pivotTime, top = top, bottom = zoneMid, xloc = xloc.bar_time, bgcolor = resistanceColor, border_color = na)
        box bullBox = box.new(left = pivotTime, right = pivotTime, top = zoneMid, bottom = bottom, xloc = xloc.bar_time, bgcolor = supportColor, border_color = na)
        srZones.push(RankedZone.new(score, top, bottom, mid, dir, pivotBar, pivotTime, width, mitigation, touches, volScore, trendScore, swingScore, bullStrength, bearStrength, false, ln, bx, bullBox, bearBox, na))
        created := true

    created
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Add confirmed pivots {
if not na(pivotHigh)
    float sq = swing_quality(pivotHigh, 1)
    if sq >= minSwingAtr
        bool createdResistance = add_zone(pivotHigh, 1, bar_index - pivotSpan, time[pivotSpan])
        resistanceCreatedAlert := createdResistance

if not na(pivotLow)
    float sq = swing_quality(pivotLow, -1)
    if sq >= minSwingAtr
        bool createdSupport = add_zone(pivotLow, -1, bar_index - pivotSpan, time[pivotSpan])
        supportCreatedAlert := createdSupport
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Update zones {
if srZones.size() > 0
    for i = srZones.size() - 1 to 0
        RankedZone z = srZones.get(i)
        int age = bar_index - z.bornBar
        bool expired = age > 450
        bool touched = high >= z.bottom and low <= z.top
        bool brokenSupport = z.dir == -1 and close < z.bottom - breakAtr * atr
        bool brokenResistance = z.dir == 1 and close > z.top + breakAtr * atr

        if touched and not brokenSupport and not brokenResistance
            bool wasUnderMitigationThreshold = z.mitigation < 0.75

            supportTouchAlert := supportTouchAlert or z.dir == -1
            resistanceTouchAlert := resistanceTouchAlert or z.dir == 1

            z.touchCount += 0.20
            float fillDistance = z.dir == -1 ? z.top - low : high - z.bottom
            z.mitigation := math.min(math.max(fillDistance / math.max(z.width, syminfo.mintick), 0.0), 1.0)

            supportMitigatedAlert := supportMitigatedAlert or z.dir == -1 and wasUnderMitigationThreshold and z.mitigation >= 0.75
            resistanceMitigatedAlert := resistanceMitigatedAlert or z.dir == 1 and wasUnderMitigationThreshold and z.mitigation >= 0.75

        z.score := score(z.width, z.volScore, z.trendScore, z.swingScore, z.mitigation, z.touchCount, age)
        [newBull, newBear] = strengths(z.dir, z.score, z.trendScore, z.mitigation)
        z.bullStrength := newBull
        z.bearStrength := newBear

        if expired
            z.deleteZone()
            srZones.remove(i)
        else if brokenSupport or brokenResistance
            z.broken := true
            lastBreakSide := brokenResistance ? "Bullish Break" : "Bearish Break"
            lastBreakIndex := bar_index
            supportBreakAlert := supportBreakAlert or brokenSupport
            resistanceBreakAlert := resistanceBreakAlert or brokenResistance

            line.set_color(z.centerLine, color.new(brokenColor, 0))
            line.set_style(z.centerLine, line.style_dotted)
            line.set_extend(z.centerLine, extend.none)
            line.set_x2(z.centerLine, bar_index)
            box.set_bgcolor(z.bodyBox, color.new(brokenColor, 88))
            box.set_border_color(z.bodyBox, color.new(brokenColor, 100))
            box.set_right(z.bodyBox, time)
            box.set_bgcolor(z.bullBar, color.new(color.gray, 100))
            box.set_bgcolor(z.bearBar, color.new(color.gray, 100))
            box.set_text(z.bodyBox, "")
            box.set_text(z.bullBar, "")
            box.set_text(z.bearBar, "")

            if keepBrokenCount > 0
                brokenZones.push(z)
                while brokenZones.size() > keepBrokenCount
                    RankedZone oldBroken = brokenZones.shift()
                    oldBroken.deleteZone()
            else
                z.deleteZone()

            srZones.remove(i)
        else
            z.refreshGeometry()
            srZones.set(i, z)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Sort and limit zones {
srZones.sort(order.descending, sort_field = "score")

if srZones.size() > 0
    RankedZone leader = srZones.get(0)
    string leaderKey = str.tostring(leader.leftTime) + "_" + str.tostring(leader.dir)
    bool newLeader = leaderKey != previousLeaderKey

    newTopRankAlert := newLeader
    topSupportAlert := newLeader and leader.dir == -1
    topResistanceAlert := newLeader and leader.dir == 1

    previousLeaderKey := leaderKey

while srZones.size() > storedLimit
    RankedZone removed = srZones.pop()
    removed.deleteZone()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Display zones {
int visibleCount = 0
float nearestSupport = na
float nearestResistance = na

if srZones.size() > 0
    for i = 0 to srZones.size() - 1
        RankedZone z = srZones.get(i)
        bool pass = z.canDisplay()
        bool visible = pass and visibleCount < visibleLimit
        if visible
            visibleCount += 1

        color baseColor = z.dir == -1 ? supportColor : resistanceColor
        int left = z.leftTime
        int right = time + barMs * 25
        int maxBarWidth = int((right - left) * 0.82)
        int bullWidth = int(maxBarWidth * z.bullStrength / 100)
        int bearWidth = int(maxBarWidth * z.bearStrength / 100)
        float middle = math.avg(z.top, z.bottom)

        box.set_bgcolor(z.bodyBox, visible ? color.new(baseColor, 78) : color.new(color.gray, 100))
        box.set_border_color(z.bodyBox, visible ? color.new(baseColor, 25) : color.new(color.gray, 100))
        line.set_color(z.centerLine, color.new(baseColor, 100))
        line.set_width(z.centerLine, 1)

        if visible and showStrengthBars
            box.set_left(z.bearBar, left)
            box.set_right(z.bearBar, left + bearWidth)
            box.set_top(z.bearBar, z.top)
            box.set_bottom(z.bearBar, middle)
            box.set_bgcolor(z.bearBar, color.new(resistanceColor, 10))
            box.set_border_color(z.bearBar, na)
            box.set_text(z.bearBar, str.tostring(z.bearStrength) + "%")
            box.set_text_color(z.bearBar, color.white)
            box.set_text_halign(z.bearBar, text.align_center)
            box.set_text_valign(z.bearBar, text.align_center)
            box.set_text_size(z.bearBar, strengthTextSize)

            box.set_left(z.bullBar, left)
            box.set_right(z.bullBar, left + bullWidth)
            box.set_top(z.bullBar, middle)
            box.set_bottom(z.bullBar, z.bottom)
            box.set_bgcolor(z.bullBar, color.new(supportColor, 10))
            box.set_border_color(z.bullBar, na)
            box.set_text(z.bullBar, str.tostring(z.bullStrength) + "%")
            box.set_text_color(z.bullBar, color.white)
            box.set_text_halign(z.bullBar, text.align_center)
            box.set_text_valign(z.bullBar, text.align_center)
            box.set_text_size(z.bullBar, strengthTextSize)

            box.set_text(z.bodyBox, showZoneText ? zone_text(z) : "")
            box.set_text_halign(z.bodyBox, text.align_right)
            box.set_text_valign(z.bodyBox, text.align_center)
            box.set_text_color(z.bodyBox, chart.fg_color)
            box.set_text_size(z.bodyBox, zoneTextSize)
        else
            box.set_bgcolor(z.bullBar, color.new(color.gray, 100))
            box.set_bgcolor(z.bearBar, color.new(color.gray, 100))
            box.set_border_color(z.bullBar, color.new(color.gray, 100))
            box.set_border_color(z.bearBar, color.new(color.gray, 100))
            box.set_text(z.bullBar, "")
            box.set_text(z.bearBar, "")
            box.set_text(z.bodyBox, "")

        if z.dir == -1 and z.mid < close
            nearestSupport := na(nearestSupport) or z.mid > nearestSupport ? z.mid : nearestSupport
        if z.dir == 1 and z.mid > close
            nearestResistance := na(nearestResistance) or z.mid < nearestResistance ? z.mid : nearestResistance
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}

// ~~ Alerts {
alertcondition(supportCreatedAlert, "Support Created", "A new ranked support zone has been created.")
alertcondition(resistanceCreatedAlert, "Resistance Created", "A new ranked resistance zone has been created.")

alertcondition(topSupportAlert, "Top-Ranked Support Created", "A support zone has become the highest-ranked active zone.")
alertcondition(topResistanceAlert, "Top-Ranked Resistance Created", "A resistance zone has become the highest-ranked active zone.")
alertcondition(newTopRankAlert, "New Top-Ranked S/R Zone", "A support/resistance zone has become the highest-ranked active zone.")

alertcondition(supportBreakAlert, "Support Broken", "A ranked support zone has been broken by close.")
alertcondition(resistanceBreakAlert, "Resistance Broken", "A ranked resistance zone has been broken by close.")

alertcondition(supportTouchAlert, "Support Mitigation Started", "Price has touched or started mitigating a ranked support zone.")
alertcondition(resistanceTouchAlert, "Resistance Mitigation Started", "Price has touched or started mitigating a ranked resistance zone.")

alertcondition(supportMitigatedAlert, "Support Mitigated", "A ranked support zone has reached the mitigation threshold.")
alertcondition(resistanceMitigatedAlert, "Resistance Mitigated", "A ranked resistance zone has reached the mitigation threshold.")
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~}
````
