# Equalhigh Perfect Channel V3.1

- url: https://www.tradingview.com/script/apVEz3Du/
- type: indicator
- pine_id: PUB;e018bdf189724ee09ffb9c24e67cfdbf
- version: 1.0

## Description

EQUALHIGH PERFECT CHANNEL V3.1
User Manual
============================================================

PURPOSE

Equalhigh Perfect Channel automatically detects geometrically clean
parallel price channels.

The indicator does NOT calculate two independent trendlines.

Instead, it:

1. Detects a valid directional trendline using significant price pivots.
2. Calculates its exact slope.
3. Translates this same line vertically toward the opposite price extreme.
4. Creates a second line with EXACTLY the same slope.
5. Scores the resulting channel according to contacts, cleanliness,
   duration and current relevance.

The result is a mathematically parallel channel similar to a manually
drawn "perfect channel".


============================================================
CHANNEL CONSTRUCTION
============================================================

The indicator can build channels in four different ways:

HIGH -> LOW
A resistance line is created from significant HIGH pivots.
The same line is then translated downward until it touches the most
extreme LOW.

CLOSE HIGH -> LOW
Same principle, but the upper directional line is constructed from
closing-price swing highs instead of candle wicks.

LOW -> HIGH
A support line is created from significant LOW pivots.
The same line is then translated upward until it reaches the most
extreme HIGH.

CLOSE LOW -> HIGH
Same principle, but the lower directional line is constructed from
closing-price swing lows.

AUTO
The indicator tests all four methods and keeps the highest-quality
valid channel.


============================================================
IMPORTANT GEOMETRIC PRINCIPLE
============================================================

A1 and A2 define the slope of the channel.

T defines only the vertical translation.

T NEVER changes the slope.

Therefore:

Upper Line Slope = Lower Line Slope

This is the core principle of the Equalhigh Perfect Channel.


============================================================
CHART LABELS
============================================================

A1
First anchor point used to define the directional trendline.

A2
Second anchor point used to define the directional trendline.

T
Translation / Tangency point.

For an upper-anchored channel, T is the LOW that determines the lower
parallel line.

For a lower-anchored channel, T is the HIGH that determines the upper
parallel line.


============================================================
INPUTS
============================================================

CONSTRUCTION

AUTO
Recommended default.
Tests all supported channel construction methods.

UPPER HIGH
Uses candle highs to construct the upper trendline.

UPPER CLOSE
Uses closing prices to construct the upper trendline.

LOWER LOW
Uses candle lows to construct the lower trendline.

LOWER CLOSE
Uses closing prices to construct the lower trendline.


PIVOT LEFT / PIVOT RIGHT

Controls how significant a swing point must be before it can be used
as a channel anchor.

Lower values:
- More sensitive
- More channels
- More short-term structures
- More noise

Higher values:
- Fewer pivots
- More important swing points
- Better suited to major channels


LOOKBACK

Defines how far back the algorithm searches for valid channel
structures.

Example:

100-150 bars:
Short-term structures

200-350 bars:
Medium-term structures

400+ bars:
Major long-term channels


PIVOTS TESTED

Defines the number of recent significant pivots used by the search
engine.

Increasing this value improves the search depth but also increases
calculation time.


============================================================
ATR TOLERANCES
============================================================

The indicator uses ATR instead of a fixed percentage so the detection
automatically adapts to market volatility.

DIRECTING LINE TOLERANCE

Defines how close price must be to the directional line to count as
a valid contact.

Default:
0.20 ATR


TRANSLATED LINE TOLERANCE

Defines how close price must be to the translated parallel line to
count as a valid contact.

Default:
0.25 ATR


BREAK TOLERANCE

Defines how far price may exceed the directional line before the event
is considered a violation.

Default:
0.30 ATR


============================================================
DISTINCT CONTACTS
============================================================

Several candles touching the same area must NOT automatically count as
several independent confirmations.

The "Minimum separation between contacts" parameter groups nearby
touches into one contact cluster.

Example:

Five consecutive candles touching the same resistance area may count
as only ONE structural contact.

Three touches separated by several bars may count as THREE independent
contacts.

This prevents false high scores caused by price clustering around one
single pivot.


============================================================
MINIMUM DIRECTING CONTACTS
============================================================

Defines the minimum number of distinct contacts required on the
directional line.

Recommended:

2
Very permissive.
Useful for early channel detection.

3
Recommended default.
Good compromise between early detection and structural confirmation.

4+
Strong confirmation, but fewer channels will be detected.


============================================================
TRANSLATED LINE CONTACTS
============================================================

Defines how many independent contacts are required on the translated
parallel boundary.

A value of 1 allows the translation point T itself to validate the
opposite side.

Higher values require repeated interaction with both sides of the
channel.


============================================================
VIOLATIONS
============================================================

A violation occurs when price exceeds the directing line by more than
the ATR break tolerance.

Lower maximum violations:
Cleaner and more selective channels.

Higher maximum violations:
More tolerant channels.


Recommended default:
1


============================================================
CHANNEL WIDTH
============================================================

Minimum Channel Width is expressed in ATR.

This prevents extremely narrow structures from being classified as
meaningful price channels.

Example:

0.50 ATR
Allows relatively narrow channels.

1.00 ATR+
Requires broader structures.


============================================================
CHANNEL DIRECTION
============================================================

The indicator can independently search for:

UP channels
Ascending structures.

DOWN channels
Descending structures.

FLAT channels
Approximately horizontal structures.

The Flat Threshold defines when a slope is small enough to be
classified as horizontal.


============================================================
ONLY ACTIVE CHANNEL
============================================================

When disabled:

The algorithm may display the best historical structure even if price
has recently moved outside it.

When enabled:

Only channels that still contain the current market price within the
allowed tolerance are accepted.

Enable this option when using the indicator primarily for current
trading decisions.


============================================================
PERFECT CHANNEL SCORE
============================================================

Every candidate channel receives a score from 0 to 100.

The score considers:

- Number of independent contacts on the directing line
- Number of contacts on the translated line
- Channel duration
- Number of structural violations
- Whether price is still trading inside the channel

Higher scores generally represent cleaner and more statistically
convincing channel geometry.


GENERAL INTERPRETATION

Below 50
Weak or insufficient structure.

50-64
Acceptable channel.

65-79
Good structural channel.

80-89
Very strong channel.

90-100
Exceptional geometric structure.

The score is a structural quality measure.
It is NOT a prediction of future price direction.


============================================================
DISPLAY OPTIONS
============================================================

PROJECTION TO THE RIGHT

Extends both parallel boundaries into the future without modifying
their slope.

This is useful for identifying potential future support or resistance
areas.


MEDIAN LINE

Displays the exact midpoint of the channel.

The median can behave as:

- equilibrium area
- intermediate support
- intermediate resistance
- mean-reversion reference


CHANNEL FILL

Colors the area located between the two parallel boundaries.


ANCHORS

Displays:

A1 = First directing anchor
A2 = Second directing anchor
T  = Translation point


============================================================
RECOMMENDED DEFAULT SETTINGS
============================================================

Construction:
AUTO

Pivot Left:
5

Pivot Right:
5

Lookback:
300

Pivots Tested:
12

ATR:
14

Directing Line Tolerance:
0.20 ATR

Translated Line Tolerance:
0.25 ATR

Break Tolerance:
0.30 ATR

Minimum Separation Between Contacts:
6 bars

Minimum Directing Contacts:
3

Minimum Translated Contacts:
1

Maximum Violations:
1

Minimum Channel Width:
0.50 ATR

Minimum Score:
50


============================================================
TIMEFRAME GUIDELINES
============================================================

The indicator is timeframe-independent.

However, settings may need to be adapted to the market and timeframe.

Intraday:
Use smaller lookbacks and possibly smaller pivot values.

Daily:
The default configuration is a good starting point.

Weekly:
Use larger lookbacks and potentially larger pivot values to detect
major structural channels.


============================================================
HOW TO INTERPRET A CHANNEL
============================================================

A detected channel should be treated as a geometric market structure,
not as a standalone buy or sell signal.

Potential interpretations include:

Price near lower boundary:
Possible support / favorable risk-reward area in an ascending or flat
channel.

Price near upper boundary:
Possible resistance / stretched area.

Price near median:
Neutral or equilibrium zone.

Confirmed breakout above the channel:
The previous channel geometry may no longer be valid.

Confirmed breakdown below the channel:
The previous channel geometry may no longer be valid.


============================================================
HIGH vs CLOSE
============================================================

HIGH / LOW modes respect candle extremes and are useful when wicks
clearly define market structure.

CLOSE modes are useful when candle extremes are noisy but closing
prices repeatedly respect a cleaner trendline.

AUTO lets the algorithm decide which representation produces the
strongest valid channel.


============================================================
LIMITATIONS
============================================================

No automatically detected channel is guaranteed to remain valid.

A high score means the historical geometry is clean.
It does NOT guarantee that price will continue respecting the channel.

Channel quality may change after:

- earnings
- macroeconomic events
- gaps
- major news
- volatility regime changes
- structural trend breaks

Always combine channel analysis with price action, market structure,
volume, fundamentals or other confirmation tools when appropriate.


============================================================
DESIGN PHILOSOPHY
============================================================

Equalhigh Perfect Channel is based on one simple rule:

"Find the slope first. Translate it second."

The opposite side of the channel is never independently fitted.

This preserves perfect geometric parallelism and reproduces the way
high-quality manual price channels are traditionally constructed.


Equalhigh
Perfect Channel V3.1

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Stevesyl

//@version=6
indicator("Equalhigh Perfect Channel V3.1", overlay=true, max_lines_count=50, max_labels_count=50, max_bars_back=1500)

//=====================================================================
// 1. DETECTION
//=====================================================================

groupDetection = "1. Detection"

constructionMode = input.string("AUTO", "Construction", options=["AUTO", "UPPER HIGH", "UPPER CLOSE", "LOWER LOW", "LOWER CLOSE"], group=groupDetection)

pivotLeft = input.int(5, "Pivot gauche", minval=1, maxval=30, group=groupDetection)
pivotRight = input.int(5, "Pivot droit", minval=1, maxval=30, group=groupDetection)

lookback = input.int(300, "Lookback", minval=50, maxval=1000, group=groupDetection)
maxPivots = input.int(12, "Pivots testes", minval=4, maxval=25, group=groupDetection)
minChannelBars = input.int(35, "Longueur minimale", minval=10, maxval=500, group=groupDetection)

//=====================================================================
// 2. CONTACTS
//=====================================================================

groupContacts = "2. Contacts / precision"

atrLength = input.int(14, "ATR", minval=5, maxval=100, group=groupContacts)

anchorTouchATR = input.float(0.20, "Tolerance droite directrice (ATR)", minval=0.05, step=0.05, group=groupContacts)
translatedTouchATR = input.float(0.25, "Tolerance droite translatee (ATR)", minval=0.05, step=0.05, group=groupContacts)
breakATR = input.float(0.30, "Tolerance depassement (ATR)", minval=0.05, step=0.05, group=groupContacts)

minTouchGap = input.int(6, "Separation minimum entre 2 contacts", minval=1, maxval=50, group=groupContacts)

minAnchorTouches = input.int(3, "Contacts distincts directeurs minimum", minval=2, maxval=10, group=groupContacts)
minTranslatedTouches = input.int(1, "Contacts ligne translatee minimum", minval=1, maxval=10, group=groupContacts)

maxViolations = input.int(1, "Violations maximum", minval=0, maxval=10, group=groupContacts)

minWidthATR = input.float(0.50, "Largeur minimale canal (ATR)", minval=0.0, step=0.25, group=groupContacts)

//=====================================================================
// 3. GEOMETRIE
//=====================================================================

groupGeometry = "3. Geometrie"

allowUp = input.bool(true, "Canaux haussiers", group=groupGeometry)
allowDown = input.bool(true, "Canaux baissiers", group=groupGeometry)
allowFlat = input.bool(true, "Canaux horizontaux", group=groupGeometry)

flatATRper100 = input.float(0.50, "Seuil horizontal / 100 bougies (ATR)", minval=0.05, step=0.05, group=groupGeometry)

onlyActive = input.bool(false, "Uniquement canal encore actif", group=groupGeometry)

//=====================================================================
// 4. AFFICHAGE
//=====================================================================

groupDisplay = "4. Affichage"

projectionBars = input.int(60, "Projection a droite", minval=0, maxval=300, group=groupDisplay)

showMedian = input.bool(true, "Afficher mediane", group=groupDisplay)
showFill = input.bool(false, "Colorer interieur", group=groupDisplay)
showAnchors = input.bool(true, "Afficher A1 / A2 / T", group=groupDisplay)
showScore = input.bool(true, "Afficher score", group=groupDisplay)

scoreMinimum = input.float(50, "Score minimum", minval=0, maxval=100, step=5, group=groupDisplay)

//=====================================================================
// 5. ATR
//=====================================================================

atr = ta.atr(atrLength)

//=====================================================================
// 6. PIVOTS
//=====================================================================

phHigh = ta.pivothigh(high, pivotLeft, pivotRight)
phClose = ta.pivothigh(close, pivotLeft, pivotRight)

plLow = ta.pivotlow(low, pivotLeft, pivotRight)
plClose = ta.pivotlow(close, pivotLeft, pivotRight)

//=====================================================================
// 7. ARRAYS
//=====================================================================

var upHighX = array.new_int()
var upHighY = array.new_float()

var upCloseX = array.new_int()
var upCloseY = array.new_float()

var lowLowX = array.new_int()
var lowLowY = array.new_float()

var lowCloseX = array.new_int()
var lowCloseY = array.new_float()

//=====================================================================
// 8. ENREGISTREMENT PIVOTS
//=====================================================================

if not na(phHigh)
    int px = bar_index - pivotRight
    array.push(upHighX, px)
    array.push(upHighY, phHigh)
    if array.size(upHighX) > maxPivots
        array.shift(upHighX)
        array.shift(upHighY)

if not na(phClose)
    int px = bar_index - pivotRight
    array.push(upCloseX, px)
    array.push(upCloseY, phClose)
    if array.size(upCloseX) > maxPivots
        array.shift(upCloseX)
        array.shift(upCloseY)

if not na(plLow)
    int px = bar_index - pivotRight
    array.push(lowLowX, px)
    array.push(lowLowY, plLow)
    if array.size(lowLowX) > maxPivots
        array.shift(lowLowX)
        array.shift(lowLowY)

if not na(plClose)
    int px = bar_index - pivotRight
    array.push(lowCloseX, px)
    array.push(lowCloseY, plClose)
    if array.size(lowCloseX) > maxPivots
        array.shift(lowCloseX)
        array.shift(lowCloseY)

//=====================================================================
// 9. FONCTION DE RECHERCHE
//=====================================================================

f_findBest(array<int> xs, array<float> ys, bool upperAnchored, bool anchorClose) =>

    float bScore = -1000000000.0

    float bSlope = na
    float bIntercept = na
    float bOffset = na

    int bStartX = na
    int bAnchor2X = na

    float bAnchor1Y = na
    float bAnchor2Y = na

    int bAnchorTouches = 0
    int bTranslatedTouches = 0
    int bViolations = 0

    int bTangentX = na
    float bTangentY = na

    int n = array.size(xs)

    if n >= 2

        for i = 0 to n - 2

            for j = i + 1 to n - 1

                int x1 = array.get(xs, i)
                float y1 = array.get(ys, i)

                int x2 = array.get(xs, j)
                float y2 = array.get(ys, j)

                int channelBars = bar_index - x1

                bool lengthOK = x2 > x1 and channelBars >= minChannelBars and channelBars <= lookback

                if lengthOK

                    // ------------------------------------------------
                    // DROITE DIRECTRICE
                    // ------------------------------------------------

                    float slope = (y2 - y1) / float(x2 - x1)
                    float intercept = y1 - slope * float(x1)

                    float atrNow = nz(atr, syminfo.mintick)

                    // ------------------------------------------------
                    // DIRECTION DU CANAL
                    // ------------------------------------------------

                    float slope100ATR = slope * 100.0 / atrNow

                    bool isFlat = math.abs(slope100ATR) < flatATRper100

                    bool directionOK = (isFlat and allowFlat) or (not isFlat and slope > 0 and allowUp) or (not isFlat and slope < 0 and allowDown)

                    if directionOK

                        int anchorTouches = 0
                        int violations = 0
                        int lastAnchorTouchX = na

                        float extremeResidual = upperAnchored ? 1000000000.0 : -1000000000.0

                        int localTangentX = na
                        float localTangentY = na

                        int scanBars = math.min(lookback, bar_index + 1)

                        // =================================================
                        // PREMIERE PASSE
                        // =================================================

                        for k = 0 to scanBars - 1

                            int bx = bar_index - k

                            if bx >= x1

                                float baseLine = slope * float(bx) + intercept

                                float atrK = nz(atr[k], atrNow)

                                float touchTol = atrK * anchorTouchATR
                                float violationTol = atrK * breakATR

                                // Prix utilise pour tester la droite directrice
                                float anchorPrice = anchorClose ? close[k] : upperAnchored ? high[k] : low[k]

                                // -----------------------------------------
                                // CONTACT DIRECTEUR AVEC CLUSTERING
                                // -----------------------------------------

                                bool touching = math.abs(anchorPrice - baseLine) <= touchTol

                                if touching

                                    bool newCluster = na(lastAnchorTouchX) or math.abs(lastAnchorTouchX - bx) >= minTouchGap

                                    if newCluster
                                        anchorTouches += 1
                                        lastAnchorTouchX := bx

                                // -----------------------------------------
                                // VIOLATION DE LA DROITE DIRECTRICE
                                // -----------------------------------------

                                bool violation = upperAnchored ? anchorPrice > baseLine + violationTol : anchorPrice < baseLine - violationTol

                                if violation
                                    violations += 1

                                // -----------------------------------------
                                // EXTREME OPPOSE POUR TRANSLATION
                                // -----------------------------------------

                                float oppositePrice = upperAnchored ? low[k] : high[k]
                                float residual = oppositePrice - baseLine

                                if upperAnchored

                                    if residual < extremeResidual
                                        extremeResidual := residual
                                        localTangentX := bx
                                        localTangentY := oppositePrice

                                else

                                    if residual > extremeResidual
                                        extremeResidual := residual
                                        localTangentX := bx
                                        localTangentY := oppositePrice

                        // =================================================
                        // TRANSLATION
                        // =================================================

                        float offset = extremeResidual

                        bool offsetDirectionOK = upperAnchored ? offset < 0 : offset > 0

                        float widthATR = math.abs(offset) / atrNow

                        bool widthOK = widthATR >= minWidthATR

                        // =================================================
                        // DEUXIEME PASSE
                        // =================================================

                        int translatedTouches = 0
                        int lastTranslatedTouchX = na

                        if offsetDirectionOK and widthOK

                            for k = 0 to scanBars - 1

                                int bx = bar_index - k

                                if bx >= x1

                                    float baseLine = slope * float(bx) + intercept
                                    float translatedLine = baseLine + offset

                                    float atrK = nz(atr[k], atrNow)
                                    float translatedTol = atrK * translatedTouchATR

                                    float translatedPrice = upperAnchored ? low[k] : high[k]

                                    bool touchingTranslated = math.abs(translatedPrice - translatedLine) <= translatedTol

                                    if touchingTranslated

                                        bool newCluster = na(lastTranslatedTouchX) or math.abs(lastTranslatedTouchX - bx) >= minTouchGap

                                        if newCluster
                                            translatedTouches += 1
                                            lastTranslatedTouchX := bx

                        // =================================================
                        // CANAL ACTUEL
                        // =================================================

                        float currentBase = slope * float(bar_index) + intercept

                        float currentUpper = upperAnchored ? currentBase : currentBase + offset
                        float currentLower = upperAnchored ? currentBase + offset : currentBase

                        bool inside = close <= currentUpper + atrNow * breakATR and close >= currentLower - atrNow * breakATR

                        // =================================================
                        // SCORE
                        // =================================================

                        float anchorScore = math.min(float(anchorTouches) / 5.0, 1.0) * 35.0

                        float translatedScore = math.min(float(translatedTouches) / 4.0, 1.0) * 25.0

                        float lengthScore = math.min(float(channelBars) / 200.0, 1.0) * 15.0

                        float cleanlinessScore = math.max(0.0, 15.0 - float(violations) * 5.0)

                        float activeScore = inside ? 10.0 : 0.0

                        float score = anchorScore + translatedScore + lengthScore + cleanlinessScore + activeScore

                        score := math.max(0.0, math.min(score, 100.0))

                        // =================================================
                        // VALIDATION
                        // =================================================

                        bool valid = anchorTouches >= minAnchorTouches and translatedTouches >= minTranslatedTouches and violations <= maxViolations and offsetDirectionOK and widthOK and (not onlyActive or inside)

                        if valid and score > bScore

                            bScore := score

                            bSlope := slope
                            bIntercept := intercept
                            bOffset := offset

                            bStartX := x1
                            bAnchor2X := x2

                            bAnchor1Y := y1
                            bAnchor2Y := y2

                            bAnchorTouches := anchorTouches
                            bTranslatedTouches := translatedTouches
                            bViolations := violations

                            bTangentX := localTangentX
                            bTangentY := localTangentY

    [bScore, bSlope, bIntercept, bOffset, bStartX, bAnchor2X, bAnchor1Y, bAnchor2Y, bAnchorTouches, bTranslatedTouches, bViolations, bTangentX, bTangentY]

//=====================================================================
// 10. MEILLEUR CANAL GLOBAL
//=====================================================================

var float bestScore = na

var float bestSlope = na
var float bestIntercept = na
var float bestOffset = na

var int bestStartX = na
var int bestAnchor2X = na

var float bestAnchor1Y = na
var float bestAnchor2Y = na

var int bestAnchorTouches = 0
var int bestTranslatedTouches = 0
var int bestViolations = 0

var int bestTangentX = na
var float bestTangentY = na

var bool bestIsUpper = true

var string bestType = ""

//=====================================================================
// 11. RECHERCHE SUR DERNIERE BOUGIE
//=====================================================================

if barstate.islast

    bestScore := -1000000000.0

    bestSlope := na
    bestIntercept := na
    bestOffset := na

    bestStartX := na
    bestAnchor2X := na

    bestAnchor1Y := na
    bestAnchor2Y := na

    bestAnchorTouches := 0
    bestTranslatedTouches := 0
    bestViolations := 0

    bestTangentX := na
    bestTangentY := na

    bestType := ""

    // =============================================================
    // UPPER HIGH
    // =============================================================

    if constructionMode == "AUTO" or constructionMode == "UPPER HIGH"

        [s1, sl1, it1, of1, sx1, a2x1, a1y1, a2y1, at1, tt1, v1, tx1, ty1] = f_findBest(upHighX, upHighY, true, false)

        if s1 > bestScore
            bestScore := s1
            bestSlope := sl1
            bestIntercept := it1
            bestOffset := of1
            bestStartX := sx1
            bestAnchor2X := a2x1
            bestAnchor1Y := a1y1
            bestAnchor2Y := a2y1
            bestAnchorTouches := at1
            bestTranslatedTouches := tt1
            bestViolations := v1
            bestTangentX := tx1
            bestTangentY := ty1
            bestIsUpper := true
            bestType := "HIGH -> LOW"

    // =============================================================
    // UPPER CLOSE
    // =============================================================

    if constructionMode == "AUTO" or constructionMode == "UPPER CLOSE"

        [s2, sl2, it2, of2, sx2, a2x2, a1y2, a2y2, at2, tt2, v2, tx2, ty2] = f_findBest(upCloseX, upCloseY, true, true)

        if s2 > bestScore
            bestScore := s2
            bestSlope := sl2
            bestIntercept := it2
            bestOffset := of2
            bestStartX := sx2
            bestAnchor2X := a2x2
            bestAnchor1Y := a1y2
            bestAnchor2Y := a2y2
            bestAnchorTouches := at2
            bestTranslatedTouches := tt2
            bestViolations := v2
            bestTangentX := tx2
            bestTangentY := ty2
            bestIsUpper := true
            bestType := "CLOSE HIGH -> LOW"

    // =============================================================
    // LOWER LOW
    // =============================================================

    if constructionMode == "AUTO" or constructionMode == "LOWER LOW"

        [s3, sl3, it3, of3, sx3, a2x3, a1y3, a2y3, at3, tt3, v3, tx3, ty3] = f_findBest(lowLowX, lowLowY, false, false)

        if s3 > bestScore
            bestScore := s3
            bestSlope := sl3
            bestIntercept := it3
            bestOffset := of3
            bestStartX := sx3
            bestAnchor2X := a2x3
            bestAnchor1Y := a1y3
            bestAnchor2Y := a2y3
            bestAnchorTouches := at3
            bestTranslatedTouches := tt3
            bestViolations := v3
            bestTangentX := tx3
            bestTangentY := ty3
            bestIsUpper := false
            bestType := "LOW -> HIGH"

    // =============================================================
    // LOWER CLOSE
    // =============================================================

    if constructionMode == "AUTO" or constructionMode == "LOWER CLOSE"

        [s4, sl4, it4, of4, sx4, a2x4, a1y4, a2y4, at4, tt4, v4, tx4, ty4] = f_findBest(lowCloseX, lowCloseY, false, true)

        if s4 > bestScore
            bestScore := s4
            bestSlope := sl4
            bestIntercept := it4
            bestOffset := of4
            bestStartX := sx4
            bestAnchor2X := a2x4
            bestAnchor1Y := a1y4
            bestAnchor2Y := a2y4
            bestAnchorTouches := at4
            bestTranslatedTouches := tt4
            bestViolations := v4
            bestTangentX := tx4
            bestTangentY := ty4
            bestIsUpper := false
            bestType := "CLOSE LOW -> HIGH"

//=====================================================================
// 12. OBJETS GRAPHIQUES
//=====================================================================

var line upperObject = na
var line lowerObject = na
var line medianObject = na

var linefill channelFill = na

var label infoLabel = na
var label anchor1Label = na
var label anchor2Label = na
var label tangentLabel = na

//=====================================================================
// 13. SUPPRESSION ANCIENS OBJETS
//=====================================================================

if barstate.islast

    if not na(upperObject)
        line.delete(upperObject)

    if not na(lowerObject)
        line.delete(lowerObject)

    if not na(medianObject)
        line.delete(medianObject)

    if not na(channelFill)
        linefill.delete(channelFill)

    if not na(infoLabel)
        label.delete(infoLabel)

    if not na(anchor1Label)
        label.delete(anchor1Label)

    if not na(anchor2Label)
        label.delete(anchor2Label)

    if not na(tangentLabel)
        label.delete(tangentLabel)

    upperObject := na
    lowerObject := na
    medianObject := na

    channelFill := na

    infoLabel := na
    anchor1Label := na
    anchor2Label := na
    tangentLabel := na

//=====================================================================
// 14. DESSIN
//=====================================================================

if barstate.islast and not na(bestSlope) and bestScore >= scoreMinimum

    int rightX = bar_index + projectionBars

    float baseStart = bestSlope * float(bestStartX) + bestIntercept
    float baseRight = bestSlope * float(rightX) + bestIntercept

    float upperStart = bestIsUpper ? baseStart : baseStart + bestOffset
    float upperRight = bestIsUpper ? baseRight : baseRight + bestOffset

    float lowerStart = bestIsUpper ? baseStart + bestOffset : baseStart
    float lowerRight = bestIsUpper ? baseRight + bestOffset : baseRight

    float medianStart = (upperStart + lowerStart) / 2.0
    float medianRight = (upperRight + lowerRight) / 2.0

    // -------------------------------------------------------------
    // CANAL
    // -------------------------------------------------------------

    upperObject := line.new(bestStartX, upperStart, rightX, upperRight, xloc=xloc.bar_index, extend=extend.none, color=color.orange, width=2)

    lowerObject := line.new(bestStartX, lowerStart, rightX, lowerRight, xloc=xloc.bar_index, extend=extend.none, color=color.orange, width=2)

    // -------------------------------------------------------------
    // MEDIANE
    // -------------------------------------------------------------

    if showMedian
        medianObject := line.new(bestStartX, medianStart, rightX, medianRight, xloc=xloc.bar_index, extend=extend.none, color=color.new(color.orange, 65), style=line.style_dashed, width=1)

    // -------------------------------------------------------------
    // REMPLISSAGE
    // -------------------------------------------------------------

    if showFill
        channelFill := linefill.new(upperObject, lowerObject, color.new(color.orange, 92))

    // -------------------------------------------------------------
    // A1 / A2 / T
    // -------------------------------------------------------------

    if showAnchors

        anchor1Label := label.new(bestStartX, bestAnchor1Y, "A1", xloc=xloc.bar_index, style=bestIsUpper ? label.style_label_down : label.style_label_up, color=color.orange, textcolor=color.white, size=size.tiny)

        anchor2Label := label.new(bestAnchor2X, bestAnchor2Y, "A2", xloc=xloc.bar_index, style=bestIsUpper ? label.style_label_down : label.style_label_up, color=color.orange, textcolor=color.white, size=size.tiny)

        if not na(bestTangentX)
            tangentLabel := label.new(bestTangentX, bestTangentY, "T", xloc=xloc.bar_index, style=bestIsUpper ? label.style_label_up : label.style_label_down, color=color.blue, textcolor=color.white, size=size.tiny)

    // -------------------------------------------------------------
    // INFORMATIONS
    // -------------------------------------------------------------

    if showScore

        float atrNow = nz(atr, syminfo.mintick)

        float normalizedSlope = bestSlope * 100.0 / atrNow

        string direction = math.abs(normalizedSlope) < flatATRper100 ? "FLAT" : bestSlope > 0 ? "UP" : "DOWN"

        float widthATR = math.abs(bestOffset) / atrNow

        string txt = "PERFECT CHANNEL V3.1"
        txt += "\n" + bestType + " | " + direction
        txt += "\nScore : " + str.tostring(bestScore, "#") + " / 100"
        txt += "\nContacts directeurs : " + str.tostring(bestAnchorTouches)
        txt += "\nContacts translation : " + str.tostring(bestTranslatedTouches)
        txt += "\nViolations : " + str.tostring(bestViolations)
        txt += "\nLargeur : " + str.tostring(widthATR, "#.00") + " ATR"

        float currentBase = bestSlope * float(bar_index) + bestIntercept

        float labelY = bestIsUpper ? currentBase : currentBase + bestOffset

        infoLabel := label.new(bar_index, labelY, txt, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.black, 15), textcolor=color.white, size=size.small)
````
