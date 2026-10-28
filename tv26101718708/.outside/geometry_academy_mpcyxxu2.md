# Geometry Academy

- url: https://www.tradingview.com/script/MpCyxxU2-Geometry-Academy/
- type: indicator
- pine_id: PUB;7d7076167b244a3b908caead5f13cfe1
- version: 1.0

## Description

# geometry academy — projection, levels and market timing

geometry academy is an educational indicator dedicated to market geometry, price levels, projections and timing.

it combines several classical methods inside a single interface:

* fibonacci retracements and extensions
* golden pocket
* ab=cd projection
* double top and double bottom
* ichimoku system
* andrews pitchfork
* session vwap
* anchored vwap
* approximate volume profile
* poc, vah and val
* linear regression channel
* cycle interval estimation
* relative strength against a benchmark
* confluence scanner
* educational lessons
* reference curriculum
* built-in glossary

the objective is not to generate automatic entries or promise a result. the indicator is designed to explain where important zones are located, why they exist and how several independent methods can converge around the same area.

a single line represents one piece of information. several independent levels grouped in the same area form a confluence zone worth studying.

---

## general operation

geometry academy uses confirmed pivots to build its geometry.

a pivot high or pivot low becomes available only after the number of bars defined in the “swing · right bars” setting has closed.

this means a swing is never known exactly when it forms. it is confirmed several bars later and then displayed on its original bar.

this behavior prevents an unfinished high or low from being treated as a definitive pivot.

rolling tools such as vwap, volume profile, regression and relative strength naturally continue to update as new bars are added.

---

# indicator modules

## fibonacci retracement

the fibonacci module measures the retracement depth of the latest confirmed leg.

the available levels are:

* 0.0
* 0.236
* 0.382
* 0.5
* 0.618
* 0.786
* 1.0

on a bullish leg, the levels help study pullback zones below the latest high.

on a bearish leg, they help study rebound zones above the latest low.

the levels are not buy or sell signals. they only identify areas where a reaction may become relevant.

## golden pocket

the golden pocket is the zone between the 0.618 and 0.65 retracement levels.

it is displayed as a zone rather than a precise line because market reactions do not always occur at one exact price.

a trade should not be decided only because price touches this area. price reaction, structure and other nearby levels must also be studied.

## fibonacci extensions

the 1.272, 1.618 and 2.0 extensions project targets beyond the reference leg.

they are mainly intended for studying potential objectives after the original movement resumes.

an extension is generally more useful when it aligns with:

* a previous high or low
* a vah or val
* a poc
* a pitchfork median
* an ab=cd projection
* a regression band

## ab=cd projection

the ab=cd model studies symmetry between two price legs.

the distance from a to b is projected from point c to estimate a potential point d.

point d is a mathematical completion zone. it does not guarantee a reversal.

a projection becomes more relevant when:

* bc is a coherent retracement of ab
* cd moves in the same direction as ab
* point d aligns with another important zone
* the duration of cd remains close to the duration of ab
* price shows a confirmed reaction around d

## double top and double bottom

the module looks for structures such as:

* high, low, high for a double top
* low, high, low for a double bottom

the tolerance between the two highs or two lows is calculated with atr.

the second high or low only creates the initial structure.

a double top is confirmed when price closes below the neckline.

a double bottom is confirmed when price closes above the neckline.

before the neckline breaks, the pattern remains a possibility rather than a confirmed setup.

## ichimoku kinko hyo

the ichimoku system is displayed with:

* tenkan-sen
* kijun-sen
* senkou span a
* senkou span b
* kumo
* chikou span

simplified interpretation:

* price above the kumo: bullish regime
* price below the kumo: bearish regime
* price inside the kumo: neutral or uncertain regime
* tenkan above kijun: positive short-term momentum
* tenkan below kijun: negative short-term momentum

the cloud is intentionally projected forward. chikou is intentionally shifted backward. these displacements are part of the standard ichimoku construction.

a tenkan and kijun cross must always be interpreted within context. a bullish cross below a bearish cloud does not carry the same meaning as a bullish cross above a bullish cloud.

## andrews pitchfork

the pitchfork is built from three alternating confirmed pivots.

the median line begins at the first pivot and passes through the midpoint of the next two pivots.

the two outer lines are parallel to the median.

the pitchfork helps study:

* the geometric direction of the swing
* returns toward the median
* acceleration toward an outer line
* structural weakness after a breakout
* areas where the median aligns with another level

the pitchfork depends directly on the quality of the three selected pivots. when a new significant swing is confirmed, the geometry may be recalculated.

## session vwap

vwap represents the session’s volume-weighted average price.

simplified interpretation:

* price above a rising vwap: intraday advantage for buyers
* price below a falling vwap: intraday advantage for sellers
* return toward vwap: return toward the session’s weighted average
* loss and reclaim of vwap: potential intraday control change

vwap is especially useful on markets with meaningful volume data.

## anchored vwap

anchored vwap begins its calculation from the selected date.

it can be used to study the volume-weighted average price since a specific event:

* origin of a movement
* breakout
* important high or low
* monthly open
* asset launch
* fundamental event
* regime change

anchored vwap does not reveal the exact price paid by every market participant. it represents a weighted average from the selected anchor.

the quality of the level therefore depends directly on the relevance of the selected date.

## volume profile

the volume profile distributes the lookback volume across several price zones.

it provides:

* poc
* vah
* val
* an optional horizontal histogram

the poc represents the profile row that received the largest allocated volume.

the vah is the upper boundary of the value area.

the val is the lower boundary of the value area.

simplified interpretation:

* price near poc: potential high-acceptance zone
* price between vah and val: price located inside the value area
* price above vah: price above the studied value zone
* price below val: price below the studied value zone

this profile is an approximation calculated from the ohlcv data available on the chart. it does not replace a native profile built from more detailed intrabar data.

## linear regression channel

the center line represents the best-fit linear trend over the selected period.

the bands are calculated using the dispersion of residuals around that line.

the module helps study:

* the statistical direction of price
* the distance between price and its central trend
* periods of extension
* returns toward the mean
* slope changes

a band touch is not automatically a reversal signal.

in a strong trend, price may remain close to an outer band for several bars.

## cycle projection

the cycle module measures the intervals between several confirmed swing lows.

it uses their average spacing to project a potential future time window.

this projection represents an area of attention rather than a guaranteed reversal date.

cycles may contract, expand or disappear during a regime change.

price level must always be studied separately from timing.

## relative strength

relative strength compares the chart symbol with a benchmark.

it is calculated using the ratio:

asset divided by benchmark

simplified interpretation:

* rising ratio: the asset is outperforming the benchmark
* falling ratio: the asset is underperforming the benchmark
* bullish turn in the ratio: improving relative performance
* bearish turn in the ratio: weakening relative performance

this relative strength measure is not the rsi oscillator.

for an altcoin, btc may be used as the benchmark. for a stock, a sector index or broad market index may be more appropriate.

---

# explanation of every input

## anchors

### swing · left bars

defines the number of bars located to the left of the pivot.

a higher value selects more significant swings and reduces the number of detected pivots.

a lower value detects more minor movements.

### swing · right bars

defines the number of bars required after the pivot before it becomes confirmed.

a higher value produces more stable geometry but increases confirmation delay.

a lower value reacts faster but includes more market noise.

---

## fibonacci

### auto-fibonacci on the active leg

enables or disables the automatic fibonacci drawn on the latest confirmed leg.

### extension targets

enables the 1.272, 1.618 and 2.0 projections.

### highlight the golden pocket

displays the area between 0.618 and 0.65.

### 0.0

displays the reference end of the movement.

### 0.236

displays a shallow retracement, mainly useful in strong trends.

### 0.382

displays a moderate retracement.

### 0.5

displays the midpoint of the movement. this is not a pure fibonacci ratio, but it is widely used.

### 0.618

displays the retracement related to the inverse golden ratio.

### 0.786

displays a deep retracement near the full invalidation of the leg.

---

## ab=cd symmetry

### project the ab=cd completion

enables or disables the point d projection based on the latest compatible pivots.

---

## chart patterns

### detect double top / double bottom

enables the search for double top and double bottom structures.

### twin-peak tolerance

defines the maximum allowed distance between the two highs or two lows.

the tolerance is expressed as an atr multiple.

example:

* 0.3 atr: strict detection
* 0.6 atr: balanced setting
* 1.0 atr: more permissive detection

---

## ichimoku kinko hyo

### ichimoku cloud

enables the ichimoku system.

### tenkan-sen

defines the period of the fast conversion line.

the classical setting is 9.

### kijun-sen

defines the period of the base line.

the classical setting is 26.

### senkou span b

defines the period used for the second cloud boundary.

the classical setting is 52.

### cloud displacement

defines how far the cloud is projected into the future.

the classical setting is 26.

### chikou span

enables the current close displayed backward according to the ichimoku displacement.

---

## andrews pitchfork

### andrews pitchfork from last 3 anchors

enables the pitchfork built from the latest three confirmed alternating pivots.

---

## vwap

### session / rolling vwap

enables the standard session vwap.

### anchored vwap

enables the vwap calculated from a specific date.

### anchor date

defines the starting point of the anchored vwap.

it is better to choose a date linked to an event that had real importance on the chart.

---

## volume profile

### volume profile

enables the profile, poc, vah and val.

### profile lookback

defines the number of bars included in the calculation.

a short lookback follows recent structure.

a long lookback describes a broader market area but reacts more slowly.

### number of price bins

defines the vertical resolution of the profile.

fewer bins:

* simpler profile
* wider levels
* lighter calculation

more bins:

* more detailed profile
* more precise levels
* greater sensitivity to noise

### value area %

defines the percentage of allocated volume included around the poc.

the classical setting is 70%.

### draw the profile histogram

shows or hides the horizontal profile bars while keeping the main levels.

---

## regression channel

### linear regression channel

enables the regression channel.

### regression length

defines the number of bars used to calculate the linear trend.

a small value follows price quickly.

a large value represents a slower and more structural trend.

### channel width

multiplies the dispersion of residuals around the center line.

a low value produces a narrow channel.

a high value produces a wider channel.

---

## market cycles

### project the next cycle low

enables the projection of the next time window based on the average spacing between confirmed swing lows.

---

## relative strength

### benchmark symbol

selects the asset used as the reference.

examples:

* btc to compare an altcoin
* a broad market index to compare a stock
* a sector index to compare a company with its industry
* another currency pair to study relative rotation

### rs lookback

defines the period used to measure the change in the asset-to-benchmark ratio.

a low value reacts quickly.

a high value measures a more persistent relative trend.

---

## education ui

### panel · geometry dashboard

displays the main dashboard.

it summarizes:

* ichimoku regime
* tenkan and kijun relationship
* nearest fibonacci level
* poc
* vah and val
* price position inside the value area
* pitchfork median
* anchored vwap
* regression position
* ab=cd target
* relative strength

### dashboard position

defines the position of the main dashboard.

### panel · level-confluence scanner

enables the scanner that compares current price with the calculated levels.

### confluence position

defines the position of the confluence scanner.

### confluence cluster tolerance

defines the maximum distance between current price and a level for that level to be considered nearby.

the distance is expressed in atr.

example:

* 0.25 atr: very tight confluence
* 0.5 atr: precise confluence
* 0.75 atr: balanced setting
* 1.0 atr or more: wide zone

a tolerance that is too large may classify too many levels as nearby.

### panel · deep lesson

enables the panel containing a detailed educational lesson.

### lesson topic

allows the selection of one of twelve subjects:

1. fibonacci retracement
2. fibonacci extension
3. ab=cd and harmonic patterns
4. chart patterns
5. elliott wave
6. ichimoku
7. andrews pitchfork
8. vwap and anchored vwap
9. volume profile
10. regression channels
11. market cycles
12. relative strength

### panel · source curriculum

displays the main historical and methodological references associated with the modules.

### panel · glossary

displays quick definitions of the terms used in the indicator.

---

## style

### bull / support

defines the color used for bullish information and support areas.

### bear / resistance

defines the color used for bearish information and resistance areas.

### accent / value

defines the color used for value levels, poc, medians and important elements.

### geometry accent

defines the main color of the geometry tools and panel titles.

### secondary text

defines the color of secondary text and neutral information.

### panel background

defines the background color of the panels and selected labels.

---

# mini tutorial

## step 1 — begin with the default settings

keep the following values for a first use:

* swing left: 8
* swing right: 8
* fibonacci enabled
* ichimoku enabled
* pitchfork enabled
* vwap enabled
* volume profile enabled
* regression length: 120
* confluence tolerance: 0.75 atr

these settings provide a balanced view of structure, levels and context.

## step 2 — identify the regime

begin by observing the kumo:

* above the cloud: mainly bullish context
* below the cloud: mainly bearish context
* inside the cloud: uncertain context

then check tenkan and kijun.

a bullish projection should not be interpreted the same way in a bearish regime.

## step 3 — locate price

observe:

* the active fibonacci retracement
* the golden pocket
* vah and val
* poc
* vwap
* anchored vwap
* pitchfork median
* regression bands

the objective is to determine whether price is:

* inside a value zone
* inside an extension zone
* near a potential reaction level
* in the middle of an area with no clear advantage

## step 4 — check confluence

open the confluence scanner.

several tools located near the same price may identify an area worth monitoring.

example:

* 0.618 fibonacci
* val
* anchored vwap
* lower regression band

this combination does not guarantee a bounce, but it describes a technically more important zone than a single isolated level.

## step 5 — wait for the reaction

then observe actual price behavior:

* wick rejection
* close above or below the level
* vwap reclaim
* neckline break
* structure change
* volatility expansion
* improvement or deterioration in relative strength

geometry provides the area. price provides the confirmation.

---

# use cases

## example 1 — pullback in a bullish trend

context:

* price above the kumo
* tenkan above kijun
* latest confirmed movement is bullish
* price is retracing

procedure:

1. identify the 0.382, 0.5, 0.618 and 0.786 levels
2. check whether the golden pocket aligns with val or anchored vwap
3. check the pitchfork median
4. consult the confluence scanner
5. wait for a bullish close or reaction around the zone

an entry in the middle of the movement generally provides less structure than an entry studied around a pullback into confluence.

## example 2 — range market

context:

* price inside the kumo
* nearly flat regression
* price between vah and val
* frequent returns toward poc

procedure:

1. treat poc as the center of rotation
2. observe vah as the upper value boundary
3. observe val as the lower value boundary
4. avoid interpreting every internal move as a new trend
5. wait for a close and acceptance outside the value area before considering a breakout

in this context, fibonacci extensions are often less useful than volume profile and regression.

## example 3 — double top

context:

* first confirmed high
* pullback toward a pivot low
* second high close to the first one

procedure:

1. confirm that both highs respect the atr tolerance
2. identify the neckline at the intermediate pivot low
3. do not treat the pattern as confirmed at the second high
4. wait for a close below the neckline
5. use the height of the structure as a theoretical projection
6. check whether the target aligns with val, an extension or previous support

## example 4 — studying an altcoin against btc

context:

* chart symbol: an altcoin
* benchmark: binance:btcusdt

procedure:

1. study the normal trend of the asset
2. study its relative strength against btc
3. favor assets that are also gaining against the benchmark
4. remain cautious when the asset rises in usd but underperforms btc
5. combine relative strength with structure, volume profile and ichimoku

## example 5 — projection target

context:

* valid ab=cd structure
* point d close to a 1.618 extension
* vah or a previous high in the same area
* upper regression band nearby

procedure:

1. treat the area as a potential objective
2. do not automatically assume a reversal
3. observe price reaction on arrival
4. distinguish a simple pause from a real structure break
5. use confluence to organize the analysis

---

# available alerts

## price entered bullish regime

triggers when price closes above the ichimoku cloud.

## price entered bearish regime

triggers when price closes below the ichimoku cloud.

## tenkan/kijun bullish cross

triggers when tenkan crosses above kijun.

## tenkan/kijun bearish cross

triggers when tenkan crosses below kijun.

## avwap reclaimed

triggers when price reclaims anchored vwap.

## avwap lost

triggers when price loses anchored vwap.

## relative strength turned up

triggers when relative strength begins rising again.

## relative strength turned down

triggers when relative strength begins falling again.

to reduce intrabar alerts, use a bar-close frequency in the tradingview alert settings.

---

# multi-timeframe use

a simple method is to separate context from execution.

swing example:

* daily chart: ichimoku regime, volume profile and relative strength
* 4-hour chart: fibonacci, pitchfork and regression
* 1-hour chart: price reaction and confirmation

intraday example:

* 1-hour chart: general structure
* 15-minute chart: value area, vwap and fibonacci levels
* 5-minute chart: reaction around the zone

pivot settings should be adapted to the timeframe.

on a low timeframe, slightly increasing the pivot values may reduce noise.

on a high timeframe, pivot settings that are too large may produce very few new structures.

---

# data behavior

pivots are confirmed only after several bars.

a pivot may therefore appear on an earlier bar only after its confirmation.

fibonacci levels, pitchfork and ab=cd projection change when a new confirmed pivot updates the active geometry.

volume profile, vwap, regression, cycles and relative strength are rolling calculations. their values change as each new bar is added.

no projection tool should be interpreted as certainty about the future.

---

# good practices

* begin with only a few visible modules
* add tools gradually
* do not use one line as a complete signal
* identify the regime before looking for an entry
* separate projection from confirmation
* adapt pivot settings to the timeframe
* choose a meaningful anchored vwap date
* choose a coherent benchmark
* keep a reasonable confluence tolerance
* study price reaction before making a decision
* use the lessons and glossary to understand each tool

geometry academy is designed as an educational and analytical environment. it helps connect structure, value, geometry, timing and relative strength inside an organized market-reading process.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Alpha_Wizard

//@version=6
indicator("Geometry Academy", "G-Academy", overlay = true, max_labels_count = 500, max_lines_count = 500, max_boxes_count = 500)


// ═══════════════════════════════════════════════════════════════════════════════
//  INPUT GROUPS
// ═══════════════════════════════════════════════════════════════════════════════
string G_ANC = "◆  ANCHORS  ·  swings that feed the geometry"
string G_FIB = "①②  FIBONACCI  ·  retracement & extension"
string G_ABC = "③  AB=CD SYMMETRY  ·  measured move"
string G_PAT = "④  CHART PATTERNS  ·  double top / bottom"
string G_ICH = "⑥  ICHIMOKU KINKO HYO"
string G_PF  = "⑦  ANDREWS PITCHFORK  ·  median line"
string G_VWP = "⑧  VWAP  ·  session & anchored"
string G_VP  = "⑨  VOLUME PROFILE  ·  value area"
string G_REG = "⑩  REGRESSION CHANNEL"
string G_CYC = "⑪  MARKET CYCLES  ·  timing"
string G_RS  = "⑫  RELATIVE STRENGTH  ·  vs benchmark"
string G_EDU = "★  EDUCATION UI"
string G_STY = "★  STYLE"

// ── Anchors
pivLeft  = input.int(8, "Swing · left bars",  minval = 1, group = G_ANC)
pivRight = input.int(8, "Swing · right bars", minval = 1, group = G_ANC, tooltip = "Geometry is only as honest as its anchors.\nA swing becomes an anchor only after N bars have CLOSED beyond it.\nLarger = fewer, more significant anchors and cleaner projections.")

// ── Fibonacci
showFib   = input.bool(true, "Auto-Fibonacci on the active leg", group = G_FIB)
showFibE  = input.bool(true, "Extension targets (1.272 / 1.618 / 2.0)", group = G_FIB)
showGP    = input.bool(true, "Highlight the Golden Pocket (0.618–0.65)", group = G_FIB, tooltip = "The Golden Pocket is the commonly watched 0.618–0.65 retracement band.\nIt is a reference zone, not a guaranteed reversal area. Price confirmation\nis still required.")
f0        = input.bool(true,  "0.0",   inline = "f1", group = G_FIB)
f236      = input.bool(true,  "0.236", inline = "f1", group = G_FIB)
f382      = input.bool(true,  "0.382", inline = "f1", group = G_FIB)
f5        = input.bool(true,  "0.5",   inline = "f2", group = G_FIB)
f618      = input.bool(true,  "0.618", inline = "f2", group = G_FIB)
f786      = input.bool(true,  "0.786", inline = "f2", group = G_FIB)

// ── AB=CD
showABCD  = input.bool(true, "Project the AB=CD completion (point D)", group = G_ABC, tooltip = "AB=CD is the simplest harmonic idea: the market moves in symmetric legs.\nIf A→B took X points, C→D often travels a similar X. D is where the two\nlegs are equal — a natural place to expect a reaction.")

// ── Chart patterns
showDT    = input.bool(true, "Detect double top / double bottom", group = G_PAT)
dtTol     = input.float(0.6, "Twin-peak tolerance (× ATR)", minval = 0.1, step = 0.1, group = G_PAT, tooltip = "How close the two peaks (or two valleys) must be to count as a 'double'.\nMeasured in ATR so it adapts to volatility automatically.")

// ── Ichimoku
showIch   = input.bool(true, "Ichimoku cloud (Kumo)", group = G_ICH)
tenkanLen = input.int(9,  "Tenkan-sen (conversion)", minval = 1, group = G_ICH)
kijunLen  = input.int(26, "Kijun-sen (base)", minval = 1, group = G_ICH)
senkouLen = input.int(52, "Senkou span B", minval = 1, group = G_ICH)
ichDisp   = input.int(26, "Cloud displacement (forward)", minval = 1, group = G_ICH, tooltip = "Ichimoku pushes the cloud INTO THE FUTURE on purpose. The displacement\nis the whole point: it gives you support/resistance before price arrives.\nThis is a feature, not repainting.")
showChikou= input.bool(true, "Chikou span (lagging line)", group = G_ICH)

// ── Pitchfork
showPF    = input.bool(true, "Andrews Pitchfork from last 3 anchors", group = G_PF, tooltip = "The standard fork uses three alternating pivots. The median line runs from\npivot 1 through the midpoint of pivots 2 and 3; the outer tines are parallel\nthrough pivots 2 and 3. It is geometric context, not a guaranteed path.")

// ── VWAP
showVWAP  = input.bool(true, "Session / rolling VWAP", group = G_VWP)
showAVWAP = input.bool(true, "Anchored VWAP", group = G_VWP)
avwapTime = input.time(timestamp("2024-01-01 00:00 +0000"), "Anchor date", group = G_VWP, tooltip = "Anchored VWAP calculates a volume-weighted average from the selected date.\nIt compares current price with that average; it does not reveal the exact\ncost basis or profit status of every participant.")

// ── Volume Profile
showVP    = input.bool(true, "Volume Profile (POC / VAH / VAL)", group = G_VP)
vpLook    = input.int(250, "Profile lookback (bars)", minval = 30, maxval = 1000, group = G_VP)
vpBins    = input.int(24,  "Number of price bins", minval = 6, maxval = 50, group = G_VP)
vpVA      = input.float(70, "Value Area %", minval = 50, maxval = 90, step = 5, group = G_VP, tooltip = "The Value Area is the price band containing the selected percentage of\nthe profile's allocated volume around the Point of Control. The default 70%\nrefers to volume, not time spent inside the area.")
showVPh   = input.bool(true, "Draw the profile histogram", group = G_VP)

// ── Regression
showReg   = input.bool(true, "Linear regression channel", group = G_REG)
regLen    = input.int(120, "Regression length", minval = 10, group = G_REG)
regMult   = input.float(2.0, "Channel width (± std-dev)", step = 0.5, group = G_REG, tooltip = "The centre line is the least-squares trend of best fit. The bands use the\nstandard deviation of residuals around that line. A band touch measures\ndistance from trend; it is not an automatic reversal probability.")

// ── Cycles
showCyc   = input.bool(true, "Project the next cycle low (timing)", group = G_CYC, tooltip = "Hurst's idea: price is the sum of overlapping cycles. The crudest, most\nhonest cycle estimate is the AVERAGE SPACING between recent swing lows.\nThis projects the next low WINDOW — a zone in TIME, not a prophecy.")

// ── Relative strength
benchSym  = input.symbol("BINANCE:BTCUSDT", "Benchmark symbol", group = G_RS, tooltip = "Relative strength compares the asset/benchmark ratio over the selected\nlookback. A rising ratio means outperformance and a falling ratio means\nunderperformance; it does not prove accumulation or distribution.")
rsLen     = input.int(50, "RS lookback", minval = 5, group = G_RS)

// ── Education UI
showDash   = input.bool(true,  "Panel · Geometry dashboard", group = G_EDU)
dashPos    = input.string("Top Right", "Dashboard position", options = ["Top Right", "Top Left", "Middle Right", "Bottom Right"], group = G_EDU)
showConf   = input.bool(true,  "Panel · Level-confluence scanner", group = G_EDU)
confPos    = input.string("Bottom Right", "Confluence position", options = ["Top Right", "Top Left", "Middle Right", "Bottom Right", "Bottom Left"], group = G_EDU)
confTol    = input.float(0.75, "Confluence cluster tolerance (× ATR)", minval = 0.1, step = 0.05, group = G_EDU, tooltip = "How close two independent levels must be to count as agreeing.\nThe tighter this is, the rarer and stronger the clusters it reports.")
showLesson = input.bool(true,  "Panel · Deep lesson (select topic)", group = G_EDU)
lessonPick = input.string("① Fibonacci retracement — where pullbacks end", "Lesson topic", options = ["① Fibonacci retracement — where pullbacks end", "② Fibonacci extension & measured moves", "③ AB=CD symmetry & harmonic patterns", "④ Classical chart patterns & targets", "⑤ Elliott Wave — the honest version", "⑥ Ichimoku Kinko Hyo — the whole system", "⑦ Andrews Pitchfork & the median line", "⑧ VWAP & Anchored VWAP — the fair price", "⑨ Volume Profile & Value Area", "⑩ Regression channels & mean reversion", "⑪ Market cycles & timing (Hurst)", "⑫ Relative strength & stage analysis"], group = G_EDU)
showCurric = input.bool(false, "Panel · Source curriculum", group = G_EDU)
showGloss  = input.bool(false, "Panel · Glossary", group = G_EDU)

// ── Style
cBull = input.color(#00FFD1, "Bull / Support",    group = G_STY)
cBear = input.color(#FF3B5C, "Bear / Resistance", group = G_STY)
cGold = input.color(#FFD23F, "Accent / Value",    group = G_STY)
cGeo  = input.color(#7B8CFF, "Geometry accent",   group = G_STY)
cNeut = input.color(#9AB0C7, "Secondary text",    group = G_STY)
cBg   = input.color(#0A0E14, "Panel background",  group = G_STY)


// ═══════════════════════════════════════════════════════════════════════════════
//  TOOLTIP LIBRARY  —  the teaching payload, boosted
// ═══════════════════════════════════════════════════════════════════════════════
string TIP_FIB = "FIBONACCI RETRACEMENT\n\nWHAT IT IS\nThe levels divide the distance between two confirmed extremes using common\nratios such as 0.236, 0.382, 0.5, 0.618 and 0.786.\n\nHOW TO READ IT\nThe lines are possible support or resistance references during a correction.\nTheir importance depends on trend, structure, volume and price reaction.\n\nWHAT TO OBSERVE\nA touch alone is not confirmation. Look for rejection, reclaim, momentum or\nsmaller-timeframe structure around the level."

string TIP_GP = "GOLDEN POCKET  (0.618 – 0.65)\n\nA commonly watched retracement band between 0.618 and 0.65.\nIt is a zone because orders rarely concentrate on one exact tick.\n\nWHAT TO OBSERVE\nTreat the pocket as location only. A rejection, reclaim, volume response,\nor smaller-timeframe structure change is still required."

string TIP_FIBE = "FIBONACCI EXTENSION  (targets)\n\nRetracements tell you where a pullback might END.\nExtensions tell you where the NEXT leg might reach: 1.272, 1.618, 2.0.\n\nHOW THEY ARE USED\nOnce a pullback holds, the resumed move is projected beyond the prior\nswing extreme by these ratios. 1.618 is the classic first target of a\ntrending leg; 2.0 and beyond appear in strong, news-driven runs.\n\nWHAT TO OBSERVE\nExtensions are TARGETS for taking profit, not triggers for entering.\nPair them with the volume-profile edges and prior structure: an extension\nthat lands exactly on an old high is a far better exit than one in space."

string TIP_ABCD = "AB=CD  MEASURED MOVE\n\nTHE PATTERN\nA→B is the first price leg. B→C must retrace part of that leg without fully\ninvalidating it. C→D projects a move equal in price to A→B.\n\nWHAT THIS SCRIPT VALIDATES\nThe last three anchors must alternate and C must remain inside the A–B range.\nThe projected D is a measured-move reference, not a guaranteed reversal.\n\nTime symmetry is displayed as an educational projection, not a requirement."

string TIP_DT = "DOUBLE TOP  (M)  /  DOUBLE BOTTOM  (W)\n\nWHAT IT IS\nTwo peaks (or two valleys) at nearly the same price, separated by a pullback.\nThe market tried the same extreme twice and failed twice.\n\nTHE TRIGGER IS THE NECKLINE\nThe pattern is NOT confirmed at the second peak. It confirms only when price\ncloses beyond the NECKLINE (the reaction low between two tops, or high\nbetween two bottoms). Until then it is just two bounces.\n\nMEASURED TARGET\nProject the height of the pattern from the neckline. Height = distance from\npeaks to neckline; target = neckline − height (top) or neckline + height (bottom).\n\nWHAT TO OBSERVE\nVolume should FALL on the second peak (less conviction) and EXPAND on the\nneckline break. A break on weak volume is the classic bull/bear trap."

string TIP_ICH = "ICHIMOKU KINKO HYO  (Hosoda)\n\n• TENKAN: midpoint of the selected short range.\n• KIJUN: midpoint of the selected base range.\n• SENKOU A: midpoint of Tenkan and Kijun, displaced forward.\n• SENKOU B: midpoint of the longer high/low range, displaced forward.\n• CHIKOU: current close displaced backward.\n\nHOW TO READ IT\nPrice above the displayed cloud is bullish context, below is bearish context,\nand inside is transitional context. The components should be read together;\nnone of them guarantees a trade outcome."

string TIP_PF = "ANDREWS PITCHFORK  (median line)\n\nDrawn from three alternating pivot anchors. The MEDIAN LINE runs from the\nfirst pivot through the midpoint of the next two. The outer tines are parallel\nand pass through pivots two and three.\n\nHOW TO READ IT\nThe fork defines a geometric trend channel. Price holding inside the tines\nsupports the active channel; a confirmed break can indicate that the selected\nfork is no longer describing the current swing.\n\nWHAT TO OBSERVE\nThe construction is only as relevant as its three confirmed anchors."

string TIP_VWAP = "VWAP  ·  Volume-Weighted Average Price\n\nThe average price of every share/coin traded in the session, weighted by\nvolume. It is the benchmark institutions are measured against — buying below\nVWAP and selling above it is, literally, their job.\n\nHOW TO READ IT\n• Price above a rising VWAP = buyers in control of the session.\n• Price snapping back to VWAP = the session's 'fair value' reasserting.\n• VWAP flips from support to resistance exactly like any level."

string TIP_AVWAP = "ANCHORED VWAP\n\nA volume-weighted average beginning at the selected date. It shows current\nprice relative to the average traded price calculated from that anchor.\n\nWHAT TO OBSERVE\nChoose a meaningful event as the anchor. Above or below the line does not mean\nevery participant is individually in profit or loss."

string TIP_VP = "VOLUME PROFILE  ·  VALUE AREA\n\nTradingView's native profiles use lower-timeframe data. This custom module\nestimates volume-at-price from the chart candles by allocating each candle's\nvolume across the price rows it overlaps.\n\nTHE THREE LEVELS\n• POC: row with the highest allocated volume.\n• VAH / VAL: boundaries containing the selected percentage around POC.\n\nThe result is an educational approximation, not tick-exact exchange volume."

string TIP_REG = "LINEAR REGRESSION CHANNEL\n\nThe centre line is the least-squares line of best fit through recent closes.\nThe channel bands use the standard deviation of residuals around that line.\n\nHOW TO READ IT\n• Slope describes the fitted trend direction.\n• Residual z-score measures distance from the fitted line.\n• A band touch is context, not an automatic mean-reversion signal."

string TIP_CYC = "MARKET CYCLES  ·  TIMING\n\nThis module is a simple swing-interval estimate, not a complete Hurst cycle\ndecomposition. It averages recent distances between confirmed swing lows and\nprojects the next observation window.\n\nWHAT TO OBSERVE\nTreat the marker as timing context only. It is not an exact reversal date."

string TIP_RS = "RELATIVE STRENGTH  ·  VS BENCHMARK\n\nRelative strength here means the asset/benchmark price ratio. It is not RSI.\nA rising ratio means the asset outperformed the benchmark over the lookback;\na falling ratio means it underperformed.\n\nThis calculation does not automatically classify Weinstein stages and does\nnot prove accumulation or distribution."

string TIP_CONF = "LEVEL CONFLUENCE\n\nThe scanner compares active references built from different methods. Its\nstrength count uses independent tool families so several levels from one\nmodule cannot inflate the result.\n\nConfluence identifies agreement near price; it is not a trade signal alone."


// ═══════════════════════════════════════════════════════════════════════════════
//  BASE  ·  ATR + swing anchors (silent; used only to feed geometry)
// ═══════════════════════════════════════════════════════════════════════════════
atr = ta.atr(14)

ph = ta.pivothigh(high, pivLeft, pivRight)
pl = ta.pivotlow(low,   pivLeft, pivRight)

newPH = not na(ph)
newPL = not na(pl)

// Rolling history of the last confirmed alternating anchors (chronological)
var array<int>   aBar = array.new_int()
var array<float> aPx  = array.new_float()
var array<bool>  aHi  = array.new_bool()

pushAnchor(int b, float p, bool isHi) =>
    bool changed = false
    int sz = array.size(aBar)

    if sz == 0
        array.push(aBar, b)
        array.push(aPx, p)
        array.push(aHi, isHi)
        changed := true
    else
        bool lastIsHi = array.get(aHi, sz - 1)
        if lastIsHi == isHi
            float oldP = array.get(aPx, sz - 1)
            bool replace = isHi ? p >= oldP : p <= oldP
            if replace
                array.set(aBar, sz - 1, b)
                array.set(aPx, sz - 1, p)
                array.set(aHi, sz - 1, isHi)
                changed := true
        else
            array.push(aBar, b)
            array.push(aPx, p)
            array.push(aHi, isHi)
            changed := true

            if array.size(aBar) > 8
                array.shift(aBar)
                array.shift(aPx)
                array.shift(aHi)

    changed

bool anchorChanged = false

if newPH and newPL
    int anchorCount = array.size(aBar)
    if anchorCount > 0
        bool lastWasHigh = array.get(aHi, anchorCount - 1)
        if lastWasHigh
            anchorChanged := pushAnchor(bar_index - pivRight, pl, false)
        else
            anchorChanged := pushAnchor(bar_index - pivRight, ph, true)
    else
        float pivotClose = close[pivRight]
        bool chooseHigh = math.abs(ph - pivotClose) >= math.abs(pivotClose - pl)
        if chooseHigh
            anchorChanged := pushAnchor(bar_index - pivRight, ph, true)
        else
            anchorChanged := pushAnchor(bar_index - pivRight, pl, false)
else if newPH
    anchorChanged := pushAnchor(bar_index - pivRight, ph, true)
else if newPL
    anchorChanged := pushAnchor(bar_index - pivRight, pl, false)

int nAnch = array.size(aBar)

// Convenience getters for the three most-recent anchors: C(newest), B, A
getBar(int fromEnd) => nAnch >= fromEnd ? array.get(aBar, nAnch - fromEnd) : na
getPx(int fromEnd)  => nAnch >= fromEnd ? array.get(aPx,  nAnch - fromEnd) : na
getHi(int fromEnd)  => nAnch >= fromEnd ? array.get(aHi,  nAnch - fromEnd) : false

// Cross-panel shared read-outs (set inside draw blocks, read by panels below)
var float sNearFib   = na
var string sNearFibN = "—"
var float sPOC = na
var float sVAH = na
var float sVAL = na
var float sMed = na
var float sTgtD = na
var float sRegMid = na
var float sRegZ = na


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑥  ICHIMOKU KINKO HYO   (top-level plots so the cloud can fill)
// ═══════════════════════════════════════════════════════════════════════════════
tenkan = math.avg(ta.highest(high, tenkanLen), ta.lowest(low, tenkanLen))
kijun  = math.avg(ta.highest(high, kijunLen),  ta.lowest(low, kijunLen))
senkA  = math.avg(tenkan, kijun)
senkB  = math.avg(ta.highest(high, senkouLen), ta.lowest(low, senkouLen))

plot(showIch ? tenkan : na, "Tenkan-sen", color.new(cGeo, 10), 1)
plot(showIch ? kijun  : na, "Kijun-sen",  color.new(cGold, 10), 2)
pSA = plot(showIch ? senkA : na, "Senkou A", color.new(cBull, 55), 1, offset = ichDisp)
pSB = plot(showIch ? senkB : na, "Senkou B", color.new(cBear, 55), 1, offset = ichDisp)
fill(pSA, pSB, showIch ? (senkA >= senkB ? color.new(cBull, 88) : color.new(cBear, 88)) : na, "Kumo")
plot(showIch and showChikou ? close : na, "Chikou", color.new(cNeut, 20), 1, offset = -ichDisp)

// Ichimoku read (current cloud = spans calculated `ichDisp` bars earlier)
ichCloudTop = math.max(senkA[ichDisp], senkB[ichDisp])
ichCloudBot = math.min(senkA[ichDisp], senkB[ichDisp])
ichReady = not na(ichCloudTop) and not na(ichCloudBot)
ichAbove = showIch and ichReady and close > ichCloudTop
ichBelow = showIch and ichReady and close < ichCloudBot
ichTxt = not showIch ? "OFF" : not ichReady ? "—" : ichAbove ? "ABOVE cloud · bullish" : ichBelow ? "BELOW cloud · bearish" : "INSIDE cloud · no-trade"
ichCol = not showIch or not ichReady ? cNeut : ichAbove ? cBull : ichBelow ? cBear : cGold
tkBull = tenkan > kijun
tkBear = tenkan < kijun


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑧  VWAP   (top-level so it plots every bar)
// ═══════════════════════════════════════════════════════════════════════════════
vwapSess = ta.vwap(hlc3)
plot(showVWAP ? vwapSess : na, "Session VWAP", color.new(cGold, 20), 1)

var float avPV = 0.0
var float avV  = 0.0
float avVol = nz(volume, 0.0)
bool avwapStart = time >= avwapTime and (na(time[1]) or time[1] < avwapTime)

if avwapStart
    avPV := hlc3 * avVol
    avV  := avVol
else if time >= avwapTime
    avPV := nz(avPV[1]) + hlc3 * avVol
    avV  := nz(avV[1]) + avVol
else
    avPV := 0.0
    avV  := 0.0

avwap = avV > 0 ? avPV / avV : na
plot(showAVWAP ? avwap : na, "Anchored VWAP", color.new(cGeo, 5), 2)


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑫  RELATIVE STRENGTH  vs benchmark
// ═══════════════════════════════════════════════════════════════════════════════
benchClose = request.security(benchSym, timeframe.period, close, gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
rs = benchClose > 0 ? close / benchClose : na
rsBase = not na(rs) ? rs[rsLen] : na
rsChange = not na(rsBase) and rsBase != 0 ? (rs / rsBase - 1.0) * 100.0 : na
rsUp = not na(rsChange) and rsChange > 0
rsDown = not na(rsChange) and rsChange < 0
rsTxt = na(rsChange) ? "—" : rsUp ? "LEADING the benchmark" : rsDown ? "LAGGING the benchmark" : "MATCHING the benchmark"
rsCol = na(rsChange) ? cNeut : rsUp ? cBull : rsDown ? cBear : cGold


// ═══════════════════════════════════════════════════════════════════════════════
//  ①②  AUTO-FIBONACCI  on the active leg
// ═══════════════════════════════════════════════════════════════════════════════
var array<line>  fibL  = array.new<line>()
var array<label> fibLb = array.new<label>()
var box gpBox = na

clearFibs() =>
    while array.size(fibL) > 0
        line.delete(array.pop(fibL))
    while array.size(fibLb) > 0
        label.delete(array.pop(fibLb))

drawFibLine(float px, string txt, color col, int lft, int rgt) =>
    array.push(fibL, line.new(lft, px, rgt, px, xloc.bar_index, extend.none, col, line.style_solid, 1))
    array.push(fibLb, label.new(rgt, px, txt, xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = col, size = size.tiny, tooltip = TIP_FIB))

fibLevel(float legHigh, float legLow, float ratio, bool legUp) =>
    legUp ? legHigh - (legHigh - legLow) * ratio : legLow + (legHigh - legLow) * ratio

if barstate.islast
    clearFibs()
    if not na(gpBox)
        box.delete(gpBox)
        gpBox := na

    sNearFib := na
    sNearFibN := "—"

    if showFib and nAnch >= 2
        int cB = getBar(1)
        float cP = getPx(1)
        int bB = getBar(2)
        float bP = getPx(2)
        bool upLeg = getHi(1) and not getHi(2)
        bool downLeg = not getHi(1) and getHi(2)
        float legHi = math.max(cP, bP)
        float legLo = math.min(cP, bP)
        float rng = legHi - legLo
        int lft = int(math.min(cB, bB))
        int rgt = bar_index + 12
        float bestD = 1e18

        if rng > 0 and (upLeg or downLeg)
            if f0
                float fibPx1 = upLeg ? legHi : legLo
                string fibNm1 = "1.0  " + str.tostring(fibPx1, format.mintick)
                drawFibLine(fibPx1, fibNm1, upLeg ? color.new(cBear, 30) : color.new(cBull, 30), lft, rgt)
                float fibD1 = math.abs(close - fibPx1)
                if fibD1 < bestD
                    bestD := fibD1
                    sNearFib := fibPx1
                    sNearFibN := fibNm1

                float fibPx2 = upLeg ? legLo : legHi
                string fibNm2 = "0.0  " + str.tostring(fibPx2, format.mintick)
                drawFibLine(fibPx2, fibNm2, upLeg ? color.new(cBull, 30) : color.new(cBear, 30), lft, rgt)
                float fibD2 = math.abs(close - fibPx2)
                if fibD2 < bestD
                    bestD := fibD2
                    sNearFib := fibPx2
                    sNearFibN := fibNm2

            if f236
                float fibPx3 = fibLevel(legHi, legLo, 0.236, upLeg)
                drawFibLine(fibPx3, "0.236", color.new(cNeut, 30), lft, rgt)
                float fibD3 = math.abs(close - fibPx3)
                if fibD3 < bestD
                    bestD := fibD3
                    sNearFib := fibPx3
                    sNearFibN := "0.236"

            if f382
                float fibPx4 = fibLevel(legHi, legLo, 0.382, upLeg)
                drawFibLine(fibPx4, "0.382", color.new(cNeut, 20), lft, rgt)
                float fibD4 = math.abs(close - fibPx4)
                if fibD4 < bestD
                    bestD := fibD4
                    sNearFib := fibPx4
                    sNearFibN := "0.382"

            if f5
                float fibPx5 = fibLevel(legHi, legLo, 0.5, upLeg)
                drawFibLine(fibPx5, "0.5", color.new(cGold, 25), lft, rgt)
                float fibD5 = math.abs(close - fibPx5)
                if fibD5 < bestD
                    bestD := fibD5
                    sNearFib := fibPx5
                    sNearFibN := "0.5"

            if f618
                float fibPx6 = fibLevel(legHi, legLo, 0.618, upLeg)
                drawFibLine(fibPx6, "0.618", color.new(cGold, 5), lft, rgt)
                float fibD6 = math.abs(close - fibPx6)
                if fibD6 < bestD
                    bestD := fibD6
                    sNearFib := fibPx6
                    sNearFibN := "0.618"

            if f786
                float fibPx7 = fibLevel(legHi, legLo, 0.786, upLeg)
                drawFibLine(fibPx7, "0.786", color.new(cNeut, 20), lft, rgt)
                float fibD7 = math.abs(close - fibPx7)
                if fibD7 < bestD
                    bestD := fibD7
                    sNearFib := fibPx7
                    sNearFibN := "0.786"

            if showGP
                float gpA = fibLevel(legHi, legLo, 0.618, upLeg)
                float gpB = fibLevel(legHi, legLo, 0.65, upLeg)
                gpBox := box.new(lft, math.max(gpA, gpB), rgt, math.min(gpA, gpB), xloc = xloc.bar_index, border_color = color.new(cGold, 40), border_width = 1, bgcolor = color.new(cGold, 85))

            if showFibE
                float fibPx8 = upLeg ? legLo + rng * 1.272 : legHi - rng * 1.272
                float fibPx9 = upLeg ? legLo + rng * 1.618 : legHi - rng * 1.618
                float fibPx10 = upLeg ? legLo + rng * 2.0 : legHi - rng * 2.0
                color extCol1 = upLeg ? color.new(cBull, 25) : color.new(cBear, 25)
                color extCol2 = upLeg ? color.new(cBull, 10) : color.new(cBear, 10)

                drawFibLine(fibPx8, "ext 1.272", extCol1, lft, rgt)
                float fibD8 = math.abs(close - fibPx8)
                if fibD8 < bestD
                    bestD := fibD8
                    sNearFib := fibPx8
                    sNearFibN := "ext 1.272"

                drawFibLine(fibPx9, "ext 1.618", extCol2, lft, rgt)
                float fibD9 = math.abs(close - fibPx9)
                if fibD9 < bestD
                    bestD := fibD9
                    sNearFib := fibPx9
                    sNearFibN := "ext 1.618"

                drawFibLine(fibPx10, "ext 2.0", extCol1, lft, rgt)
                float fibD10 = math.abs(close - fibPx10)
                if fibD10 < bestD
                    bestD := fibD10
                    sNearFib := fibPx10
                    sNearFibN := "ext 2.0"


// ═══════════════════════════════════════════════════════════════════════════════
//  ③  AB=CD  MEASURED MOVE  (project point D from last 3 anchors)
// ═══════════════════════════════════════════════════════════════════════════════
var line  abL1 = na
var line  abL2 = na
var line  cdL  = na
var label dLbl = na

if barstate.islast
    for ln in array.from(abL1, abL2, cdL)
        if not na(ln)
            line.delete(ln)
    if not na(dLbl)
        label.delete(dLbl)

    abL1 := na
    abL2 := na
    cdL := na
    dLbl := na
    sTgtD := na

    if showABCD and nAnch >= 3
        int aB = getBar(3)
        float aP = getPx(3)
        int bB = getBar(2)
        float bP = getPx(2)
        int cB = getBar(1)
        float cP = getPx(1)

        bool alternating = getHi(3) != getHi(2) and getHi(2) != getHi(1)
        float ab = bP - aP
        float bc = cP - bP
        float abSize = math.abs(ab)
        float retrace = abSize > syminfo.mintick ? math.abs(bc) / abSize : na
        bool oppositeDirection = ab * bc < 0
        bool cInsideAB = ab > 0 ? cP > aP and cP < bP : cP < aP and cP > bP
        bool validABCD = alternating and oppositeDirection and cInsideAB and not na(retrace) and retrace > 0 and retrace < 1

        if validABCD
            float dP = cP + ab
            int dB = math.min(cB + math.max(1, bB - aB), bar_index + 499)
            sTgtD := dP

            abL1 := line.new(aB, aP, bB, bP, xloc.bar_index, extend.none, color.new(cGeo, 45), line.style_solid, 1)
            abL2 := line.new(bB, bP, cB, cP, xloc.bar_index, extend.none, color.new(cGeo, 45), line.style_solid, 1)
            cdL  := line.new(cB, cP, dB, dP, xloc.bar_index, extend.none, color.new(cGeo, 10), line.style_dashed, 2)
            dLbl := label.new(dB, dP, "D  " + str.tostring(dP, format.mintick) + "  ·  AB=CD target", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 15), style = dP > cP ? label.style_label_down : label.style_label_up, textcolor = cGeo, size = size.tiny, tooltip = TIP_ABCD)


// ═══════════════════════════════════════════════════════════════════════════════
//  ④  DOUBLE TOP / DOUBLE BOTTOM  (confirmed by neckline break)
// ═══════════════════════════════════════════════════════════════════════════════
var bool  dtPending = false
var bool  dbPending = false
var float dtPeak1 = na
var float dtPeak2 = na
var float dtNeck = na
var float dtTarget = na
var int   dtBar1 = na
var int   dtBar2 = na
var int   dtNeckBar = na
var float dbValley1 = na
var float dbValley2 = na
var float dbNeck = na
var float dbTarget = na
var int   dbBar1 = na
var int   dbBar2 = na
var int   dbNeckBar = na

float dtTolV = nz(atr[pivRight], atr) * dtTol

if showDT and anchorChanged and nAnch >= 3
    bool topSequence = getHi(3) and not getHi(2) and getHi(1)
    bool bottomSequence = not getHi(3) and getHi(2) and not getHi(1)

    if topSequence
        float p1 = getPx(3)
        float neck = getPx(2)
        float p2 = getPx(1)
        bool validTop = math.abs(p2 - p1) <= dtTolV and neck < math.min(p1, p2)
        if validTop
            dtPeak1 := p1
            dtPeak2 := p2
            dtNeck := neck
            dtTarget := neck - (((p1 + p2) * 0.5) - neck)
            dtBar1 := getBar(3)
            dtNeckBar := getBar(2)
            dtBar2 := getBar(1)
            dtPending := true

    if bottomSequence
        float p1 = getPx(3)
        float neck = getPx(2)
        float p2 = getPx(1)
        bool validBottom = math.abs(p2 - p1) <= dtTolV and neck > math.max(p1, p2)
        if validBottom
            dbValley1 := p1
            dbValley2 := p2
            dbNeck := neck
            dbTarget := neck + (neck - ((p1 + p2) * 0.5))
            dbBar1 := getBar(3)
            dbNeckBar := getBar(2)
            dbBar2 := getBar(1)
            dbPending := true

bool dtNeckBreak = ta.crossunder(close, dtNeck)
bool dbNeckBreak = ta.crossover(close, dbNeck)
bool dtConfirmed = showDT and dtPending and barstate.isconfirmed and dtNeckBreak
bool dbConfirmed = showDT and dbPending and barstate.isconfirmed and dbNeckBreak

if dtConfirmed
    line.new(dtBar1, dtPeak1, dtBar2, dtPeak2, xloc.bar_index, extend.none, color.new(cBear, 20), line.style_dotted, 1)
    line.new(dtNeckBar, dtNeck, bar_index + 10, dtNeck, xloc.bar_index, extend.none, color.new(cBear, 30), line.style_dashed, 1)
    label.new(dtBar2, dtPeak2, "DOUBLE TOP", xloc = xloc.bar_index, yloc = yloc.abovebar, color = color.new(cBg, 15), style = label.style_label_down, textcolor = cBear, size = size.tiny, tooltip = TIP_DT)
    label.new(bar_index + 10, dtTarget, "target " + str.tostring(dtTarget, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cBear, size = size.tiny, tooltip = TIP_DT)
    dtPending := false

if dbConfirmed
    line.new(dbBar1, dbValley1, dbBar2, dbValley2, xloc.bar_index, extend.none, color.new(cBull, 20), line.style_dotted, 1)
    line.new(dbNeckBar, dbNeck, bar_index + 10, dbNeck, xloc.bar_index, extend.none, color.new(cBull, 30), line.style_dashed, 1)
    label.new(dbBar2, dbValley2, "DOUBLE BOTTOM", xloc = xloc.bar_index, yloc = yloc.belowbar, color = color.new(cBg, 15), style = label.style_label_up, textcolor = cBull, size = size.tiny, tooltip = TIP_DT)
    label.new(bar_index + 10, dbTarget, "target " + str.tostring(dbTarget, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cBull, size = size.tiny, tooltip = TIP_DT)
    dbPending := false

if dtPending and barstate.isconfirmed and close > math.max(dtPeak1, dtPeak2) + dtTolV
    dtPending := false

if dbPending and barstate.isconfirmed and close < math.min(dbValley1, dbValley2) - dtTolV
    dbPending := false

if not showDT
    dtPending := false
    dbPending := false


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑦  ANDREWS PITCHFORK  from last 3 anchors
// ═══════════════════════════════════════════════════════════════════════════════
var line pfMed = na
var line pfUp  = na
var line pfLo  = na
var label pfLbl = na

if barstate.islast
    for ln in array.from(pfMed, pfUp, pfLo)
        if not na(ln)
            line.delete(ln)
    if not na(pfLbl)
        label.delete(pfLbl)

    pfMed := na
    pfUp := na
    pfLo := na
    pfLbl := na
    sMed := na

    if showPF and nAnch >= 3
        int p0b = getBar(3)
        float p0p = getPx(3)
        int p1b = getBar(2)
        float p1p = getPx(2)
        int p2b = getBar(1)
        float p2p = getPx(1)
        bool alternating = getHi(3) != getHi(2) and getHi(2) != getHi(1)
        float midB = (p1b + p2b) / 2.0
        float midP = (p1p + p2p) / 2.0
        float denom = midB - p0b

        if alternating and denom != 0
            float slope = (midP - p0p) / denom
            int rgt = bar_index + 20
            float medEnd = midP + slope * (rgt - midB)
            float upEnd  = p1p + slope * (rgt - p1b)
            float loEnd  = p2p + slope * (rgt - p2b)

            pfMed := line.new(p0b, p0p, rgt, medEnd, xloc.bar_index, extend.none, color.new(cGold, 10), line.style_solid, 2)
            pfUp  := line.new(p1b, p1p, rgt, upEnd, xloc.bar_index, extend.none, color.new(cGeo, 40), line.style_solid, 1)
            pfLo  := line.new(p2b, p2p, rgt, loEnd, xloc.bar_index, extend.none, color.new(cGeo, 40), line.style_solid, 1)
            sMed := midP + slope * (bar_index - midB)
            pfLbl := label.new(rgt, medEnd, "median line", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cGold, size = size.tiny, tooltip = TIP_PF)


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑨  VOLUME PROFILE  ·  POC / VAH / VAL  (+ histogram)
// ═══════════════════════════════════════════════════════════════════════════════
var array<box>  vpBox = array.new<box>()
var line vpPocL = na
var line vpVahL = na
var line vpValL = na
var label vpPocLb = na
var label vpVahLb = na
var label vpValLb = na

float vpHiP = ta.highest(high, vpLook)
float vpLoP = ta.lowest(low, vpLook)

if barstate.islast
    while array.size(vpBox) > 0
        box.delete(array.pop(vpBox))
    for ln in array.from(vpPocL, vpVahL, vpValL)
        if not na(ln)
            line.delete(ln)
    for lb in array.from(vpPocLb, vpVahLb, vpValLb)
        if not na(lb)
            label.delete(lb)

    vpPocL := na
    vpVahL := na
    vpValL := na
    vpPocLb := na
    vpVahLb := na
    vpValLb := na
    sPOC := na
    sVAH := na
    sVAL := na

    if showVP and vpHiP > vpLoP
        float hiP = vpHiP
        float loP = vpLoP
        float step = (hiP - loP) / vpBins
        array<float> bins = array.new_float(vpBins, 0.0)

        for i = 0 to vpLook - 1
            float bh = high[i]
            float bl = low[i]
            float bv = nz(volume[i], 0.0)

            if bv > 0
                if bh > bl
                    int loBin = int(math.max(0, math.min(vpBins - 1, math.floor((bl - loP) / step))))
                    int hiBin = int(math.max(0, math.min(vpBins - 1, math.floor((bh - loP) / step))))
                    float barRange = bh - bl

                    for b = loBin to hiBin
                        float binLo = loP + b * step
                        float binHi = binLo + step
                        float overlap = math.max(0.0, math.min(bh, binHi) - math.max(bl, binLo))
                        float allocated = barRange > 0 ? bv * overlap / barRange : 0.0
                        array.set(bins, b, array.get(bins, b) + allocated)
                else
                    int oneBin = int(math.max(0, math.min(vpBins - 1, math.floor((close[i] - loP) / step))))
                    array.set(bins, oneBin, array.get(bins, oneBin) + bv)

        int pocBin = 0
        float pocVol = 0.0
        float total = 0.0
        float maxVol = 0.0

        for b = 0 to vpBins - 1
            float v = array.get(bins, b)
            total += v
            if v > pocVol
                pocVol := v
                pocBin := b
            if v > maxVol
                maxVol := v

        if total > 0
            float vaTarget = total * vpVA / 100.0
            float acc = array.get(bins, pocBin)
            int up = pocBin
            int dn = pocBin

            for _i = 0 to vpBins - 1
                if acc < vaTarget
                    float vUp = up < vpBins - 1 ? array.get(bins, up + 1) : -1.0
                    float vDn = dn > 0 ? array.get(bins, dn - 1) : -1.0
                    if vUp >= vDn and vUp >= 0
                        up += 1
                        acc += vUp
                    else if vDn >= 0
                        dn -= 1
                        acc += vDn

            sPOC := loP + (pocBin + 0.5) * step
            sVAH := loP + (up + 1) * step
            sVAL := loP + dn * step

            int lft = int(math.max(bar_index - vpLook + 1, 0))
            int rgt = bar_index + 6

            if showVPh and maxVol > 0
                int hgBase = bar_index + 8
                int hgMax = 60
                for b = 0 to vpBins - 1
                    float v = array.get(bins, b)
                    int w = int(math.round(v / maxVol * hgMax))
                    if w > 0
                        float yb = loP + b * step
                        float yt = loP + (b + 1) * step
                        bool inValueArea = b >= dn and b <= up
                        color bc = b == pocBin ? color.new(cGold, 25) : inValueArea ? color.new(cGeo, 55) : color.new(cNeut, 78)
                        array.push(vpBox, box.new(hgBase, yt, hgBase + w, yb, xloc = xloc.bar_index, border_color = color.new(cBg, 100), bgcolor = bc))

            vpPocL := line.new(lft, sPOC, rgt, sPOC, xloc.bar_index, extend.none, color.new(cGold, 5), line.style_solid, 2)
            vpVahL := line.new(lft, sVAH, rgt, sVAH, xloc.bar_index, extend.none, color.new(cGeo, 35), line.style_dashed, 1)
            vpValL := line.new(lft, sVAL, rgt, sVAL, xloc.bar_index, extend.none, color.new(cGeo, 35), line.style_dashed, 1)
            vpPocLb := label.new(rgt, sPOC, "POC " + str.tostring(sPOC, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cGold, size = size.tiny, tooltip = TIP_VP)
            vpVahLb := label.new(rgt, sVAH, "VAH " + str.tostring(sVAH, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cGeo, size = size.tiny, tooltip = TIP_VP)
            vpValLb := label.new(rgt, sVAL, "VAL " + str.tostring(sVAL, format.mintick), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cGeo, size = size.tiny, tooltip = TIP_VP)


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑩  LINEAR REGRESSION CHANNEL
// ═══════════════════════════════════════════════════════════════════════════════
regEnd = ta.linreg(close, regLen, 0)
regBeg = ta.linreg(close, regLen, regLen - 1)

float regDev = na
if not na(regEnd) and not na(regBeg) and regLen > 1
    float regSlope = (regEnd - regBeg) / (regLen - 1)
    float residualSq = 0.0
    for i = 0 to regLen - 1
        float fitted = regEnd - regSlope * i
        float residual = close[i] - fitted
        residualSq += residual * residual
    regDev := math.sqrt(residualSq / regLen)

sRegMid := showReg ? regEnd : na
sRegZ := showReg and not na(regDev) and regDev > 0 ? (close - regEnd) / regDev : na

var line rgMid = na
var line rgUp  = na
var line rgLo  = na
var label rgLbl = na

if barstate.islast
    for ln in array.from(rgMid, rgUp, rgLo)
        if not na(ln)
            line.delete(ln)
    if not na(rgLbl)
        label.delete(rgLbl)

    rgMid := na
    rgUp := na
    rgLo := na
    rgLbl := na

    if showReg and not na(regBeg) and not na(regEnd) and not na(regDev)
        int lft = bar_index - regLen + 1
        float band = regDev * regMult
        rgMid := line.new(lft, regBeg, bar_index, regEnd, xloc.bar_index, extend.right, color.new(cGeo, 10), line.style_solid, 1)
        rgUp  := line.new(lft, regBeg + band, bar_index, regEnd + band, xloc.bar_index, extend.right, color.new(cBear, 45), line.style_dashed, 1)
        rgLo  := line.new(lft, regBeg - band, bar_index, regEnd - band, xloc.bar_index, extend.right, color.new(cBull, 45), line.style_dashed, 1)
        rgLbl := label.new(bar_index, regEnd, "regression mean  ·  z " + (na(sRegZ) ? "—" : str.tostring(sRegZ, "#.##")), xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 100), style = label.style_label_left, textcolor = cGeo, size = size.tiny, tooltip = TIP_REG)


// ═══════════════════════════════════════════════════════════════════════════════
//  ⑪  CYCLE TIMING  ·  project the next swing-low window
// ═══════════════════════════════════════════════════════════════════════════════
var int prevLowBar = na
var int lastLowBar = na
var array<int> cycIntervals = array.new_int()

if newPL
    int thisLowBar = bar_index - pivRight
    if not na(prevLowBar)
        int interval = thisLowBar - prevLowBar
        if interval > 0
            array.push(cycIntervals, interval)
            if array.size(cycIntervals) > 6
                array.shift(cycIntervals)
    prevLowBar := thisLowBar
    lastLowBar := thisLowBar

float cycAvg = na
if array.size(cycIntervals) > 0
    float cycTotal = 0.0
    for i = 0 to array.size(cycIntervals) - 1
        cycTotal += array.get(cycIntervals, i)
    cycAvg := cycTotal / array.size(cycIntervals)

float cycYTop = ta.highest(high, 50)
float cycYBot = ta.lowest(low, 50)

var line  cycLn  = na
var label cycLbl = na

if barstate.islast
    if not na(cycLn)
        line.delete(cycLn)
    if not na(cycLbl)
        label.delete(cycLbl)

    cycLn := na
    cycLbl := na

    if showCyc and array.size(cycIntervals) >= 2 and not na(cycAvg) and not na(lastLowBar)
        int projBar = lastLowBar + int(math.round(cycAvg))
        int barsAway = projBar - bar_index
        cycLn := line.new(projBar, cycYBot, projBar, cycYTop, xloc.bar_index, extend.none, color.new(cGold, 40), line.style_dotted, 1)
        cycLbl := label.new(projBar, cycYTop, "cycle low window\n~" + str.tostring(barsAway) + " bars", xloc = xloc.bar_index, yloc = yloc.price, color = color.new(cBg, 20), style = label.style_label_down, textcolor = cGold, size = size.tiny, textalign = text.align_center, tooltip = TIP_CYC)


// ═══════════════════════════════════════════════════════════════════════════════
//  CONTEXTUAL COACH  (geometry-aware)
// ═══════════════════════════════════════════════════════════════════════════════
inVA = showVP and not na(sVAH) and not na(sVAL) and close <= sVAH and close >= sVAL
abovePrem = showVP and not na(sVAH) and close > sVAH
belowDisc = showVP and not na(sVAL) and close < sVAL
nearPOC = showVP and not na(sPOC) and not na(atr) and math.abs(close - sPOC) <= atr * 0.5
stretched = showReg and not na(sRegZ) and math.abs(sRegZ) >= regMult

coach = switch
    ichBelow and belowDisc          => "◆ DEEP DISCOUNT + BEARISH REGIME\nPrice is below the Value Area AND below the Ichimoku cloud.\nThis is where falling knives live. A discount is only a bargain once a\nbuyer shows up. OBSERVE: wait for price to reclaim VAL or the cloud base\nbefore treating cheap as opportunity."
    ichAbove and abovePrem and stretched => "⚑ PREMIUM + STRETCHED\nPrice trades above value, above the cloud, and " + str.tostring(math.abs(sRegZ), "#.#") + "σ from the\nregression mean. The trend is real but the location is poor for new longs.\nOBSERVE: let price rotate back toward VAH / the POC / the median line."
    nearPOC                         => "◎ AT THE POINT OF CONTROL\nPrice sits on the heaviest-traded price in the range — the market's centre\nof gravity. Expect chop and false moves here; the POC attracts, then repels.\nOBSERVE: trade the EXIT from the POC, not the magnet itself."
    not na(sNearFib) and not na(atr) and math.abs(close - sNearFib) <= atr * 0.4 => "◆ AT A FIBONACCI LEVEL (" + sNearFibN + ")\nPrice is reacting at a retracement level. This is a WHERE, not a WHEN.\nOBSERVE: a rejection candle, a volume shift, or a smaller-timeframe turn.\nCheck the confluence panel — is anything else stacked here?"
    inVA                            => "● INSIDE VALUE — ROTATION\nPrice is within the current estimated Value Area. Rotation is common but not\nguaranteed. OBSERVE: monitor VAH / VAL and wait for acceptance or rejection\nbefore treating either edge as support or resistance."
    ichAbove                        => "✓ BULLISH REGIME (above cloud)\nPlace new longs at LEVELS, not in space: a Fib pocket, the VAL, the median\nline, or a reclaimed AVWAP. Let the geometry bring price to you.\nOBSERVE: where do two or more of those levels stack? That is your zone."
    ichBelow                        => "✓ BEARISH REGIME (below cloud)\nLook for shorts at premium: VAH, a Fib level, the median line, or a lost\nAVWAP acting as resistance. OBSERVE: the confluence panel finds the price\nwhere several of these agree — that is the high-quality fade."
    =>                                 "■ NO CLEAR REGIME (in the cloud)\nIchimoku inside the cloud = the market has no equilibrium yet. Geometry\nstill works for LEVELS, but direction is unreliable. OBSERVE: mark the\nlevels, wait for price to leave the cloud, then act with the regime."


// ═══════════════════════════════════════════════════════════════════════════════
//  DEEP LESSON LIBRARY  (boosted)
// ═══════════════════════════════════════════════════════════════════════════════
lessonBody = switch lessonPick
    "① Fibonacci retracement — where pullbacks end" => "PILLAR ① · RETRACEMENT\n\nA trend does not move in a straight line; it advances, then gives some back.\nFibonacci retracements estimate HOW MUCH it gives back before resuming:\n0.382 (shallow), 0.5 (the midpoint, not strictly Fib but widely watched),\n0.618 and 0.786 (deep).\n\nWHY IT MATTERS TO A BEGINNER\nWithout these levels you enter pullbacks at random depths and your stops are\narbitrary. With them you have a MAP: a menu of prices where reactions cluster.\n\nHOW TO USE IT WELL\n• A 0.382 retracement is relatively shallow.\n• The 0.618–0.65 band is widely watched, but it is not inherently superior.\n• A close beyond 0.786 shows a deep retracement and increases invalidation risk;\n  structure must decide whether the original leg is still active.\n\nTHE DISCIPLINE\nThe level is the WHERE. It is never the trigger. You still need a reaction:\na rejection wick, a volume change, a turn on a lower timeframe. Buying a\nnaked level with no reaction is guessing dressed up as analysis.\n\nThese ratios are analytical references. Their usefulness comes from consistent\napplication and confirmation, not from a guaranteed mathematical market law."

    "② Fibonacci extension & measured moves" => "PILLAR ② · PROJECTION\n\nRetracements answer 'where does the pause end?'. Extensions answer 'where does\nthe next leg reach?'. Common targets: 1.272, 1.618, 2.0 (and 2.618 in strong\nruns), projected beyond the prior swing extreme.\n\nWHY YOU NEED TARGETS\nEntries are easy; EXITS are where accounts are made or ruined. Without a\ntarget you either sell winners too early out of fear or ride them into a\nreversal out of greed. Extensions give you pre-planned, unemotional exits.\n\nHOW TO USE IT WELL\n• 1.272, 1.618 and 2.0 are common projection references, not promised targets.\n• An extension aligned with prior structure or another independent reference\n  may deserve more attention than an isolated level.\n• Exit planning remains dependent on the trader's own risk rules.\n\nTHE DISCIPLINE\nA target is a PLAN, not a prediction. Price owes you nothing. If momentum\ndies before the target, the plan changes — that is management, not failure."

    "③ AB=CD symmetry & harmonic patterns" => "PILLAR ③ · SYMMETRY  (Gartley, Carney)\n\nAB=CD is the atom of harmonic trading. Four points: an impulse A→B, a\nretracement B→C, and a projected leg C→D of similar size to A→B. D is where\nthe two impulses are equal, and reactions cluster there.\n\nWHY SYMMETRY APPEARS\nAB=CD is a geometric symmetry model. Similar price legs can occur, but the\npattern does not identify who traded them or guarantee equal future behaviour.\n\nFROM AB=CD TO THE HARMONIC ZOO\nAdd specific Fibonacci constraints to the legs and you get named patterns:\n• GARTLEY — B at 0.618 of XA, D at 0.786 of XA.\n• BAT — D at 0.886 of XA (deeper, tighter risk).\n• BUTTERFLY — D beyond X, at 1.272–1.618 (an extension reversal).\n• CRAB — the extreme, D at 1.618 of XA.\nEach defines a Potential Reversal Zone (PRZ) where several ratios converge.\n\nTHE DISCIPLINE\nHarmonics are PROBABILISTIC reversal zones, not certainties. They require a\nconfirmation (candle, structure turn) inside the PRZ and a stop just beyond\nit. Traded mechanically without confirmation, they bleed."

    "④ Classical chart patterns & targets" => "PILLAR ④ · PATTERNS  (Edwards & Magee, Bulkowski)\n\nChart patterns are recurring shapes of crowd behaviour with MEASURABLE\ntargets. The two this script detects automatically:\n\nDOUBLE TOP (M) / DOUBLE BOTTOM (W)\nThe market tests an extreme twice and fails. Confirmation is the NECKLINE\nbreak, never the second peak. Target = pattern height projected from the\nneckline.\n\nOTHER PATTERNS YOU SHOULD LEARN TO DRAW BY HAND\n• HEAD & SHOULDERS — three peaks, the middle highest; neckline break confirms;\n  target = head-to-neckline height projected down.\n• TRIANGLES (asc/desc/sym) — compression before expansion; target ≈ the widest\n  part of the triangle projected from the break.\n• FLAGS & PENNANTS — brief consolidations in a strong move; target = the\n  'flagpole' height projected from the breakout.\n\nBULKOWSKI'S LESSON\nHe statistically catalogued these patterns. The takeaways: (1) the BREAK and\nits VOLUME matter more than the shape's prettiness; (2) throwbacks/pullbacks\nto the broken line are common and normal; (3) failure rates are real — a\npattern is an edge, not a promise.\n\nTHE DISCIPLINE\nNo pattern is valid until its trigger (neckline/trendline) breaks on a close,\nideally with expanding volume. A pattern you 'see coming' has not happened yet."

    "⑤ Elliott Wave — the honest version" => "PILLAR ⑤ · ELLIOTT WAVE  (Elliott; Frost & Prechter)\n\nTHE IDEA\nMarkets move in repeating 5-wave impulses (in the trend direction) followed by\n3-wave corrections (against it). Fractally, each wave subdivides into the same\npattern on a smaller scale.\n\nTHE THREE CORE RULES (never broken in a valid count)\n  1. Wave 2 never retraces more than 100% of wave 1.\n  2. Wave 3 is never the shortest of waves 1, 3, 5.\n  3. Wave 4 never enters the price territory of wave 1.\n\nWHY THIS SCRIPT DOES NOT AUTO-COUNT IT\nHonesty. Elliott counts are SUBJECTIVE — two skilled analysts routinely label\nthe same chart differently, and any 'automatic wave' indicator is really just\none opinion that silently relabels itself as price moves (repainting). Teaching\nyou to trust a black-box count would be doing you harm.\n\nHOW TO ACTUALLY USE IT\n• Use it as a FRAMEWORK for expectation, not a signal generator.\n• Third waves are the strongest, most tradable moves — learn to recognise the\n  impulsive character (gaps, expansion, breadth), not just the label.\n• Combine wave context with the OBJECTIVE tools here (Fib, VP, structure). If\n  your 'wave 3 target' also sits at a 1.618 extension and a Volume-Profile\n  gap, the framework has earned its place. Alone, it is a story."

    "⑥ Ichimoku Kinko Hyo — the whole system" => "PILLAR ⑥ · ICHIMOKU  (Hosoda)\n\nIchimoku combines several range midpoints and displaced plots in one framework.\nIt is designed to present trend, momentum and support/resistance context at a\nsingle glance.\n\nTHE FIVE COMPONENTS\n• Tenkan-sen (9): fast equilibrium — momentum.\n• Kijun-sen (26): the medium equilibrium — the magnet and a natural stop.\n• Senkou A & B: their midpoints, pushed 26 bars into the FUTURE, form the Kumo\n  (cloud) — support/resistance BEFORE price arrives.\n• Chikou span: today's close plotted 26 bars back — a clean momentum check\n  against past price.\n\nREADING IT AS A SYSTEM (this is the part beginners skip)\n• Regime context: above cloud = bullish, below = bearish, inside = transitional.\n• Cloud thickness shows distance between the two spans, not guaranteed strength.\n• A future Kumo twist means the projected spans crossed; it is not a prediction.\n• Alignment across components provides confirmation context.\n\nTHE DISCIPLINE\nNever trade a single Ichimoku line in isolation. A Tenkan/Kijun cross inside\nthe cloud is noise; the same cross with price already above a rising cloud is\na high-quality continuation. The system's power is in AGREEMENT."

    "⑦ Andrews Pitchfork & the median line" => "PILLAR ⑦ · PITCHFORK  (Alan Andrews)\n\nDrawn from three pivots. The median line runs from the first pivot through the\nmidpoint of the next two; parallel 'tines' run through those two pivots.\n\nANDREWS' CENTRAL CLAIM\nThe median line is the central geometric reference of the selected three-pivot\nstructure. It can act as a channel reference, but no universal return rate is\nguaranteed across symbols, settings, or market regimes.\n\nHOW TO READ IT\n• Price hugging the UPPER tine = strong; anticipate eventual reversion to the\n  median.\n• Price that CANNOT reach the median = the swing is weakening; the far tine\n  becomes the next objective.\n• A decisive break of the lower tine (in an up-fork) usually ends the fork —\n  time to re-anchor to newer pivots (which this script does automatically).\n\nTHE DISCIPLINE\nA pitchfork is only as good as its anchors. When a fresh significant swing\nprints, an old fork is a museum piece. Always ask: are these three pivots still\nthe relevant ones? If not, the lines they draw are decoration."

    "⑧ VWAP & Anchored VWAP — the fair price" => "PILLAR ⑧ · VWAP  (anchored VWAP — Paul Levine; popularised by Brian Shannon)\n\nVWAP is a cumulative typical price weighted by volume. It is commonly used as\nan execution and intraday trend benchmark, but its interpretation depends on\nthe selected session and market data.\n\nSESSION VWAP\nResets each session. Intraday, it provides a session-weighted reference. Price above or below it\nshows location relative to that average, not certainty about the next move.\n\nANCHORED VWAP — the upgrade\nStart the calculation from a SPECIFIC event: a major swing low, a breakout, a\nlisting or news candle. It reports the volume-weighted average calculated from\nthat point. Price above or below the line describes position relative to that\naverage; it does not reveal every participant's individual cost basis.\n\nTHE DISCIPLINE\nAn AVWAP is only as meaningful as its anchor. Anchor to events that MATTERED\nto participants, not to random bars. Anchored to the origin of the current\nmove, it is one of the cleanest levels you will ever plot."

    "⑨ Volume Profile & Value Area" => "PILLAR ⑨ · VOLUME PROFILE  (educational candle-based approximation)\n\nOrdinary volume bars answer 'how much traded per unit of TIME?'. Volume Profile\nanswers the better question: 'how much traded per unit of PRICE?'.\n\nTHE KEY LEVELS\n• POC: the row receiving the highest allocated volume in this approximation.\n• Value Area (VAH–VAL): rows containing the selected percentage of allocated\n  volume around POC.\n\nHIGH- vs LOW-VOLUME NODES\n• HVN: rows with relatively high allocated volume.\n• LVN: rows with relatively low allocated volume.\nThey describe the selected sample and do not guarantee future behaviour.\n\nHOW TO TRADE AROUND IT\n• Above VAH = premium (fade candidates in range; breakout fuel in trend).\n• Below VAL = discount. Inside VA = rotation, fade the edges.\n• Price leaving value and ACCEPTING outside it (building a new node) signals a\n  genuine range shift, not just a poke.\n\nTHE DISCIPLINE\nProfile describes where business was done; it does not predict. Pair a VA edge\nwith a Fib level or the pitchfork median and you have a reason, not a hunch."

    "⑩ Regression channels & mean reversion" => "PILLAR ⑩ · REGRESSION  (Raff; statistics)\n\nThe centre line is the least-squares line of best fit through recent price —\nthe trend distilled to pure statistics, without a moving average's lag. The\nbands are standard deviations of price around that line.\n\nWHAT IT GIVES YOU THAT AN AVERAGE DOES NOT\n• A QUANTIFIED slope: not 'it looks up' but a measurable angle.\n• A residual z-score: distance from the fitted line measured in residual\n  standard-deviation units. Market residuals are not guaranteed to be normal.\n\nHOW TO READ IT\n• Price at the upper band in an UPtrend = stretched, but strong trends ride it.\n  Do not short a band touch by itself.\n• Reversion to the CENTRE line is the base case in range-like conditions.\n• A change in the channel's SLOPE (flattening, rolling over) often precedes a\n  structural change in the market.\n\nTHE DISCIPLINE\nMean reversion is a tendency, not a rule. The band tells you about RISK and\nREWARD geometry — where a stop is small and a target is far — not about\ncertainty of a turn. It is a context tool, always paired, never solo."

    "⑪ Market cycles & timing (Hurst)" => "PILLAR ⑪ · CYCLES & TIMING  (J. M. Hurst)\n\nHurst cycle analysis is a broader framework involving overlapping periodic\ncomponents. This script does not perform a full Hurst decomposition.\n\nTHE HONEST, USABLE VERSION\nThe module simply averages the six most recent intervals between confirmed\nswing lows and projects the next observation marker. It is a descriptive\ninterval estimate, not a statistically validated due date.\n\nWHY A WINDOW, NEVER A DATE\nReal cycles breathe: they stretch and compress with volatility and news.\nTreating a projection as an exact appointment is how people fight the tape.\nTreat it as a zone of heightened attention.\n\nHOW TO USE IT\nThe magic is in COMBINATION. When price arrives at a strong LEVEL (a Fib\npocket, the VAL, an AVWAP) AND you are inside a projected TIMING window, the\nWHERE and the WHEN agree. Those are the setups worth waiting for.\n\nTHE DISCIPLINE\nNever trade time alone. A date with no level is a superstition. A level with a\nconfirming time window is a plan."

    "⑫ Relative strength & stage analysis" => "PILLAR ⑫ · RELATIVE STRENGTH & STAGES  (Stan Weinstein)\n\nRelative strength here = your asset ÷ a benchmark. It is NOT the RSI oscillator.\nThe script measures whether that ratio rose or fell over the selected lookback.\n\nWHY IT EXPOSES HIDDEN WEAKNESS\nAn asset can print a green candle while quietly LOSING ground to BTC. That is a\nlaggard — and in the next market pullback, laggards are sold first and hardest.\nConversely, an asset rising against a flat benchmark is outperforming it over\nthe measured period; the ratio alone does not prove accumulation.\n\nWEINSTEIN'S FOUR STAGES (education only — not auto-detected by this script)\n  1 · BASING     — a flattening phase after decline.\n  2 · ADVANCING  — a rising trend phase.\n  3 · TOPPING    — a flattening phase after advance.\n  4 · DECLINING  — a falling trend phase.\n\nHOW TO USE IT\nRising relative strength can confirm outperformance during an advancing phase.\nStage classification still requires separate trend and base analysis; this\nmodule does not calculate it automatically.\n\nTHE DISCIPLINE\nAlways know whether you own a leader or a laggard. Being right on direction and\nwrong on selection still underperforms."

    => "Select a lesson topic."


// ═══════════════════════════════════════════════════════════════════════════════
//  UI HELPERS
// ═══════════════════════════════════════════════════════════════════════════════
posOf(s) =>
    s == "Top Right" ? position.top_right : s == "Top Left" ? position.top_left : s == "Middle Right" ? position.middle_right : s == "Bottom Left" ? position.bottom_left : position.bottom_right

posTxt(float lvl) =>
    na(lvl) ? "—" : str.tostring(lvl, format.mintick)


// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL · GEOMETRY DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(posOf(dashPos), 2, 13, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 82), border_width = 1)

if barstate.islast and showDash
    table.cell(dash, 0, 0, "GEOMETRY  ACADEMY", text_color = cGeo, text_size = size.tiny, bgcolor = color.new(cGeo, 88))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "⑥ Ichimoku regime", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 1, ichTxt, text_color = ichCol, text_size = size.tiny, bgcolor = color.new(ichCol, 90), tooltip = TIP_ICH)

    table.cell(dash, 0, 2, "⑥ Tenkan / Kijun", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 2, not showIch ? "OFF" : tkBull ? "Tenkan > Kijun · up" : tkBear ? "Tenkan < Kijun · down" : "Tenkan = Kijun · flat", text_color = not showIch ? cNeut : tkBull ? cBull : tkBear ? cBear : cGold, text_size = size.tiny, tooltip = TIP_ICH)

    table.cell(dash, 0, 3, "① Nearest Fib", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 3, sNearFibN + (na(sNearFib) ? "" : "  " + posTxt(sNearFib)), text_color = cGold, text_size = size.tiny, tooltip = TIP_FIB)

    table.cell(dash, 0, 4, "⑨ Value: POC", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 4, posTxt(sPOC), text_color = cGold, text_size = size.tiny, tooltip = TIP_VP)

    table.cell(dash, 0, 5, "⑨ VAH / VAL", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 5, posTxt(sVAH) + "  /  " + posTxt(sVAL), text_color = cGeo, text_size = size.tiny, tooltip = TIP_VP)

    table.cell(dash, 0, 6, "⑨ Price vs Value", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 6, abovePrem ? "PREMIUM (above VAH)" : belowDisc ? "DISCOUNT (below VAL)" : inVA ? "FAIR (inside VA)" : "—", text_color = abovePrem ? cBear : belowDisc ? cBull : cGold, text_size = size.tiny, tooltip = TIP_VP)

    table.cell(dash, 0, 7, "⑦ Pitchfork median", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 7, na(sMed) ? "—" : (close > sMed ? "above " : "below ") + posTxt(sMed), text_color = na(sMed) ? cNeut : (close > sMed ? cBull : cBear), text_size = size.tiny, tooltip = TIP_PF)

    table.cell(dash, 0, 8, "⑧ Anchored VWAP", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 8, not showAVWAP or na(avwap) ? "—" : (close >= avwap ? "ABOVE " : "BELOW ") + posTxt(avwap), text_color = not showAVWAP or na(avwap) ? cNeut : (close >= avwap ? cBull : cBear), text_size = size.tiny, tooltip = TIP_AVWAP)

    table.cell(dash, 0, 9, "⑩ Regression z-score", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 9, na(sRegZ) ? "—" : str.tostring(sRegZ, "#.##") + "σ" + (stretched ? "  · STRETCHED" : ""), text_color = na(sRegZ) ? cNeut : stretched ? cGold : cNeut, text_size = size.tiny, tooltip = TIP_REG)

    table.cell(dash, 0, 10, "③ AB=CD target D", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 10, posTxt(sTgtD), text_color = cGeo, text_size = size.tiny, tooltip = TIP_ABCD)

    table.cell(dash, 0, 11, "⑫ Relative strength", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dash, 1, 11, rsTxt, text_color = rsCol, text_size = size.tiny, tooltip = TIP_RS)

    table.cell(dash, 0, 12, coach, text_color = ichCol, text_size = size.tiny, text_halign = text.align_left, bgcolor = color.new(cBg, 20))
    table.merge_cells(dash, 0, 12, 1, 12)


// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL · LEVEL-CONFLUENCE SCANNER
//  Counts how many independent levels sit within `confTol` of price.
// ═══════════════════════════════════════════════════════════════════════════════
var table conf = table.new(posOf(confPos), 3, 12, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 82), border_width = 1)

if barstate.islast and showConf
    float confBand = na(atr) ? 0.0 : atr * confTol

    array<string> lvlName = array.new_string()
    array<float> lvlPx = array.new_float()

    if showFib and not na(sNearFib)
        array.push(lvlName, "① Fib " + sNearFibN)
        array.push(lvlPx, sNearFib)
    if showVP and not na(sPOC)
        array.push(lvlName, "⑨ POC")
        array.push(lvlPx, sPOC)
    if showVP and not na(sVAH)
        array.push(lvlName, "⑨ VAH")
        array.push(lvlPx, sVAH)
    if showVP and not na(sVAL)
        array.push(lvlName, "⑨ VAL")
        array.push(lvlPx, sVAL)
    if showPF and not na(sMed)
        array.push(lvlName, "⑦ Median")
        array.push(lvlPx, sMed)
    if showAVWAP and not na(avwap)
        array.push(lvlName, "⑧ AVWAP")
        array.push(lvlPx, avwap)
    if showVWAP and not na(vwapSess)
        array.push(lvlName, "⑧ VWAP")
        array.push(lvlPx, vwapSess)
    if showReg and not na(sRegMid)
        array.push(lvlName, "⑩ Reg mean")
        array.push(lvlPx, sRegMid)
    if showIch and not na(kijun)
        array.push(lvlName, "⑥ Kijun")
        array.push(lvlPx, kijun)
    if showABCD and not na(sTgtD)
        array.push(lvlName, "③ AB=CD D")
        array.push(lvlPx, sTgtD)

    bool fibNear = showFib and not na(sNearFib) and math.abs(close - sNearFib) <= confBand
    bool vpNear = showVP and ((not na(sPOC) and math.abs(close - sPOC) <= confBand) or (not na(sVAH) and math.abs(close - sVAH) <= confBand) or (not na(sVAL) and math.abs(close - sVAL) <= confBand))
    bool pfNear = showPF and not na(sMed) and math.abs(close - sMed) <= confBand
    bool vwapNear = (showAVWAP and not na(avwap) and math.abs(close - avwap) <= confBand) or (showVWAP and not na(vwapSess) and math.abs(close - vwapSess) <= confBand)
    bool regNear = showReg and not na(sRegMid) and math.abs(close - sRegMid) <= confBand
    bool ichNear = showIch and not na(kijun) and math.abs(close - kijun) <= confBand
    bool abcdNear = showABCD and not na(sTgtD) and math.abs(close - sTgtD) <= confBand

    int nearCount = (fibNear ? 1 : 0) + (vpNear ? 1 : 0) + (pfNear ? 1 : 0) + (vwapNear ? 1 : 0) + (regNear ? 1 : 0) + (ichNear ? 1 : 0) + (abcdNear ? 1 : 0)

    string clText = nearCount >= 3 ? "STRONG CLUSTER" : nearCount == 2 ? "MINOR CLUSTER" : nearCount == 1 ? "single level" : "no level near price"
    color clCol  = nearCount >= 3 ? cBull : nearCount == 2 ? cGold : cNeut

    table.cell(conf, 0, 0, "LEVEL  CONFLUENCE  SCANNER", text_color = cGeo, text_size = size.tiny, bgcolor = color.new(cGeo, 88))
    table.merge_cells(conf, 0, 0, 2, 0)

    table.cell(conf, 0, 1, "Within " + str.tostring(confTol, "#.##") + "×ATR of price", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(conf, 1, 1, str.tostring(nearCount) + " tools", text_color = clCol, text_size = size.tiny)
    table.cell(conf, 2, 1, clText, text_color = clCol, text_size = size.tiny, bgcolor = color.new(clCol, 88), tooltip = TIP_CONF)

    table.cell(conf, 0, 2, "TOOL", text_color = cGold, text_size = size.tiny, text_halign = text.align_left, bgcolor = color.new(cGold, 92))
    table.cell(conf, 1, 2, "LEVEL", text_color = cGold, text_size = size.tiny, bgcolor = color.new(cGold, 92))
    table.cell(conf, 2, 2, "DIST (ATR)", text_color = cGold, text_size = size.tiny, bgcolor = color.new(cGold, 92))

    int n = array.size(lvlPx)
    array<bool> used = array.new_bool(n, false)
    int maxRows = 9

    for r = 0 to maxRows - 1
        int bestI = -1
        float bestD = 1e18

        if n > 0
            for i = 0 to n - 1
                if not array.get(used, i)
                    float d = math.abs(close - array.get(lvlPx, i))
                    if d < bestD
                        bestD := d
                        bestI := i

        if bestI >= 0
            array.set(used, bestI, true)
            float dAtr = na(atr) or atr == 0 ? na : bestD / atr
            bool near = not na(dAtr) and dAtr <= confTol
            color rc = near ? cBull : cNeut
            table.cell(conf, 0, 3 + r, array.get(lvlName, bestI), text_color = rc, text_size = size.tiny, text_halign = text.align_left)
            table.cell(conf, 1, 3 + r, posTxt(array.get(lvlPx, bestI)), text_color = rc, text_size = size.tiny)
            table.cell(conf, 2, 3 + r, na(dAtr) ? "—" : str.tostring(dAtr, "#.##"), text_color = rc, text_size = size.tiny)
        else
            table.cell(conf, 0, 3 + r, "", text_color = cNeut, text_size = size.tiny)
            table.cell(conf, 1, 3 + r, "", text_color = cNeut, text_size = size.tiny)
            table.cell(conf, 2, 3 + r, "", text_color = cNeut, text_size = size.tiny)


// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL · DEEP LESSON
// ═══════════════════════════════════════════════════════════════════════════════
var table les = table.new(position.bottom_left, 1, 2, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 85), border_width = 1)

if barstate.islast and showLesson
    table.cell(les, 0, 0, "LESSON  ·  " + lessonPick, text_color = cGeo, text_size = size.tiny, bgcolor = color.new(cGeo, 88))
    table.cell(les, 0, 1, lessonBody, text_color = cNeut, text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top)


// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL · SOURCE CURRICULUM
// ═══════════════════════════════════════════════════════════════════════════════
var table cur = table.new(position.middle_left, 3, 13, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 85), border_width = 1)

if barstate.islast and showCurric
    table.cell(cur, 0, 0, "SOURCE  CURRICULUM", text_color = cGeo, text_size = size.tiny, bgcolor = color.new(cGeo, 88))
    table.merge_cells(cur, 0, 0, 2, 0)
    table.cell(cur, 0, 1, "Fibonacci ratios", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 1, "0.382 / 0.5 / 0.618 / 0.786", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 1, "→ ① ②", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 2, "H. M. Gartley", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 2, "Profits in the Stock Market (1935)", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 2, "→ ③ harmonics", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 3, "Scott Carney", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 3, "Harmonic Trading", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 3, "→ ③ PRZ", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 4, "Edwards & Magee", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 4, "Technical Analysis of Stock Trends", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 4, "→ ④ patterns", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 5, "Thomas Bulkowski", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 5, "Encyclopedia of Chart Patterns", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 5, "→ ④ targets", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 6, "Frost & Prechter", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 6, "Elliott Wave Principle", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 6, "→ ⑤ waves", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 7, "Goichi Hosoda", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 7, "Ichimoku Kinko Hyo", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 7, "→ ⑥ cloud", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 8, "Alan Andrews", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 8, "Median-line / pitchfork method", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 8, "→ ⑦ fork", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 9, "Paul Levine / Brian Shannon", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 9, "AVWAP development / popularisation", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 9, "→ ⑧ AVWAP", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 10, "J. P. Steidlmayer", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 10, "Market Profile", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 10, "→ ⑨ value", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 11, "Raff / statistics", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 11, "Linear-regression channel", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 11, "→ ⑩ reg", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 0, 12, "Hurst · Weinstein", text_color = cGold, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 1, 12, "Cycles · Stage analysis", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(cur, 2, 12, "→ ⑪ ⑫", text_color = cBull, text_size = size.tiny, text_halign = text.align_left)


// ═══════════════════════════════════════════════════════════════════════════════
//  PANEL · GLOSSARY
// ═══════════════════════════════════════════════════════════════════════════════
var table glo = table.new(position.top_left, 2, 13, bgcolor = color.new(cBg, 6), frame_color = color.new(cNeut, 55), frame_width = 1, border_color = color.new(cNeut, 85), border_width = 1)

if barstate.islast and showGloss
    table.cell(glo, 0, 0, "GLOSSARY", text_color = cGeo, text_size = size.tiny, bgcolor = color.new(cGeo, 88))
    table.merge_cells(glo, 0, 0, 1, 0)
    table.cell(glo, 0, 1, "GOLDEN POCKET", text_color = cGold, text_size = size.tiny)
    table.cell(glo, 1, 1, "0.618–0.65 retracement — the deepest common pullback zone", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 2, "EXTENSION", text_color = cBull, text_size = size.tiny)
    table.cell(glo, 1, 2, "1.272 / 1.618 / 2.0 — projected targets of the next leg", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 3, "AB=CD", text_color = cGeo, text_size = size.tiny)
    table.cell(glo, 1, 3, "Two price legs of similar size; D is the completion point", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 4, "PRZ", text_color = cGeo, text_size = size.tiny)
    table.cell(glo, 1, 4, "Potential Reversal Zone — where harmonic ratios converge", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 5, "NECKLINE", text_color = cNeut, text_size = size.tiny)
    table.cell(glo, 1, 5, "The break level that confirms a double top/bottom or H&S", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 6, "KUMO", text_color = cBull, text_size = size.tiny)
    table.cell(glo, 1, 6, "Ichimoku cloud — forward-projected support/resistance", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 7, "MEDIAN LINE", text_color = cGold, text_size = size.tiny)
    table.cell(glo, 1, 7, "Centre tine of an Andrews pitchfork — the swing's magnet", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 8, "AVWAP", text_color = cGeo, text_size = size.tiny)
    table.cell(glo, 1, 8, "Anchored VWAP — avg price paid since a chosen event", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 9, "POC", text_color = cGold, text_size = size.tiny)
    table.cell(glo, 1, 9, "Point of Control — highest allocated-volume profile row", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 10, "VALUE AREA", text_color = cGeo, text_size = size.tiny)
    table.cell(glo, 1, 10, "VAH–VAL band holding ~70% of traded volume", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 11, "LVN / HVN", text_color = cNeut, text_size = size.tiny)
    table.cell(glo, 1, 11, "Low/High Volume Node — relatively low/high allocated volume", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)
    table.cell(glo, 0, 12, "REL. STRENGTH", text_color = cBull, text_size = size.tiny)
    table.cell(glo, 1, 12, "Asset ÷ benchmark — leadership, NOT the RSI oscillator", text_color = cNeut, text_size = size.tiny, text_halign = text.align_left)


// ═══════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
ichBullRaw = ta.crossover(close, ichCloudTop)
ichBearRaw = ta.crossunder(close, ichCloudBot)
tkCrossUpRaw = ta.crossover(tenkan, kijun)
tkCrossDnRaw = ta.crossunder(tenkan, kijun)
avwapCrossUpRaw = ta.crossover(close, avwap)
avwapCrossDnRaw = ta.crossunder(close, avwap)
rsTurnUpRaw = rsUp and not rsUp[1]
rsTurnDnRaw = rsDown and not rsDown[1]

ichBull = showIch and ichReady and barstate.isconfirmed and ichBullRaw
ichBearC = showIch and ichReady and barstate.isconfirmed and ichBearRaw
tkCrossUp = showIch and barstate.isconfirmed and tkCrossUpRaw
tkCrossDn = showIch and barstate.isconfirmed and tkCrossDnRaw
avwapCrossUp = showAVWAP and not na(avwap) and barstate.isconfirmed and avwapCrossUpRaw
avwapCrossDn = showAVWAP and not na(avwap) and barstate.isconfirmed and avwapCrossDnRaw
rsTurnUp = barstate.isconfirmed and rsTurnUpRaw
rsTurnDn = barstate.isconfirmed and rsTurnDnRaw

alertcondition(ichBull,    "Price entered bullish regime",  "GEOMETRY ACADEMY — price closed above the Ichimoku cloud")
alertcondition(ichBearC,   "Price entered bearish regime",  "GEOMETRY ACADEMY — price closed below the Ichimoku cloud")
alertcondition(tkCrossUp,  "Tenkan/Kijun bullish cross",    "GEOMETRY ACADEMY — Tenkan crossed above Kijun")
alertcondition(tkCrossDn,  "Tenkan/Kijun bearish cross",    "GEOMETRY ACADEMY — Tenkan crossed below Kijun")
alertcondition(avwapCrossUp, "AVWAP reclaimed", "GEOMETRY ACADEMY — price reclaimed the Anchored VWAP")
alertcondition(avwapCrossDn, "AVWAP lost",      "GEOMETRY ACADEMY — price lost the Anchored VWAP")
alertcondition(rsTurnUp, "Relative strength turned up",   "GEOMETRY ACADEMY — asset started leading the benchmark")
alertcondition(rsTurnDn, "Relative strength turned down", "GEOMETRY ACADEMY — asset started lagging the benchmark")
````
