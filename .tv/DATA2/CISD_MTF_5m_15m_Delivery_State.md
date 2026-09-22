<!-- tradingview-pine-id: PUB;5d92ebf0f7ef48888b6fcbdc3f74907d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# CISD MTF — 5m + 15m — Delivery State

Source: https://www.tradingview.com/script/l2fTYwtc-CISD-MTF-5m-15m/

## Description

CISD MTF is a multi-timeframe Change in State of Delivery (CISD) indicator designed to display the active 5-minute and 15-minute CISD reference levels directly on a lower-timeframe chart.

The indicator focuses on a simple question:

What level does price need to close through before the current delivery state can be considered changed?

[*]A Bull CISD is the reference level price must close above to confirm a bullish change in delivery. 

[*]A Bear CISD is the reference level price must close below to confirm a bearish change in delivery.

Unlike a simple candle-color or crossover signal, the indicator maintains the current delivery state until the relevant CISD level is actually confirmed. An opposite-colored candle, wick through the level, or temporary swing by itself does not automatically change the displayed direction.

Key features:

- Displays 5m and 15m CISD levels on lower-timeframe charts
- Tracks only the currently relevant CISD direction for each timeframe
- Uses confirmed higher-timeframe candle closes, not intrabar price
- A wick through a CISD level does not confirm a state change
- Bull CISD remains active during bearish delivery until price confirms above it
- Bear CISD remains active during bullish delivery until price confirms below it
- Automatically replaces the previous CISD reference when the delivery state changes
- Right-edge labels make the active levels easy to identify
- Includes alerts when active CISD references change

How I use it

I use CISD as confirmation/context rather than a standalone entry signal.

For example, during bearish delivery, the Bull CISD shows the level price would need to reclaim on a confirmed close before I consider evidence of a bullish character change. Likewise, during bullish delivery, the Bear CISD marks the level price would need to close below before bearish delivery is confirmed.

I typically combine CISD with market structure, EMA structure, liquidity, displacement, and pullback locations rather than entering immediately when a CISD occurs.

Important: This indicator is intended as a market-structure visualization and research tool. It does not provide financial advice or guarantee that a trend reversal or continuation will occur.

---

## Source Code

````pine
//@version=6
indicator("CISD MTF — 5m + 15m — Delivery State", shorttitle="CISD MTF", overlay=true, max_lines_count=10, max_labels_count=10)

//======================================================================
// INPUTS
//======================================================================

show5m = input.bool(true, "Show 5m CISD")
show15m = input.bool(true, "Show 15m CISD")

bull5Color = input.color(color.rgb(0, 190, 90), "5m Bull CISD")
bear5Color = input.color(color.rgb(230, 70, 70), "5m Bear CISD")

bull15Color = input.color(color.rgb(0, 130, 255), "15m Bull CISD")
bear15Color = input.color(color.rgb(255, 140, 0), "15m Bear CISD")

lineWidth = input.int(2, "Line Width", minval=1, maxval=4)
labelOffset = input.int(5, "Label Right Offset", minval=1, maxval=50)


//======================================================================
// CISD ENGINE
//
// CORE CONCEPT
//
// BEARISH DELIVERY:
//     Keep displaying BULL CISD.
//     BULL CISD = level price must CLOSE ABOVE to prove bullish change.
//
// BULLISH DELIVERY:
//     Keep displaying BEAR CISD.
//     BEAR CISD = level price must CLOSE BELOW to prove bearish change.
//
// IMPORTANT:
//
// A bullish candle during bearish delivery does NOT flip the state.
// A bearish candle during bullish delivery does NOT flip the state.
// A swing low/high by itself does NOT flip the state.
//
// Delivery flips ONLY after a confirmed HTF CLOSE through the active CISD.
//
// Existing mature level-selection logic is retained:
//
// potentialTopPrice    = BULL CISD candidate.
// potentialBottomPrice = BEAR CISD candidate.
//======================================================================

f_cisd() =>

    //------------------------------------------------------------------
    // BODY HELPERS
    //------------------------------------------------------------------

    float bodyHigh0 = math.max(open, close)
    float bodyLow0 = math.min(open, close)

    float bodyHigh1 = math.max(open[1], close[1])
    float bodyLow1 = math.min(open[1], close[1])

    float bodySize1 = math.abs(close[1] - open[1])
    float bodySize2 = math.abs(close[2] - open[2])


    //------------------------------------------------------------------
    // MARKET STRUCTURE STATE
    //------------------------------------------------------------------

    var float topPrice = math.max(open, close)
    var float bottomPrice = math.min(open, close)

    var bool structureBullish = close >= open


    //------------------------------------------------------------------
    // PULLBACK STATE
    //------------------------------------------------------------------

    var bool isBullishPullback = false
    var bool isBearishPullback = false

    var float potentialTopPrice = na
    var float potentialBottomPrice = na

    var int bullishBreakIndex = na
    var int bearishBreakIndex = na


    //------------------------------------------------------------------
    // CISD CANDIDATES
    //
    // Bull candidate:
    // Price must close ABOVE this level.
    //
    // Bear candidate:
    // Price must close BELOW this level.
    //------------------------------------------------------------------

    var float bullCandidateLevel = na
    var int bullCandidateAnchorTime = na

    var float bearCandidateLevel = na
    var int bearCandidateAnchorTime = na


    //------------------------------------------------------------------
    // DELIVERY STATE
    //
    // -1 = bearish delivery
    //      therefore display BULL CISD
    //
    // +1 = bullish delivery
    //      therefore display BEAR CISD
    //
    //  0 = waiting for initial usable CISD candidate
    //------------------------------------------------------------------

    var int deliveryState = 0


    //------------------------------------------------------------------
    // ACTIVE DISPLAY STATE
    //
    // +1 = BULL CISD
    // -1 = BEAR CISD
    //  0 = none
    //------------------------------------------------------------------

    var int activeDirection = 0
    var float activeLevel = na
    var int activeAnchorTime = na
    var int activeEventId = 0


    //------------------------------------------------------------------
    // ONLY PROCESS CLOSED HTF CANDLES
    //------------------------------------------------------------------

    if barstate.isconfirmed

        //--------------------------------------------------------------
        // PULLBACK DETECTION
        //--------------------------------------------------------------

        float minPullbackRatio = 0.5

        bool validPullback = bodySize2 > 0 and bodySize1 >= minPullbackRatio * bodySize2
        bool bearishPullbackDetected = validPullback and close[1] > open[1]
        bool bullishPullbackDetected = validPullback and close[1] < open[1]


        //--------------------------------------------------------------
        // START BEARISH PULLBACK
        //--------------------------------------------------------------

        if bearishPullbackDetected and not isBearishPullback
            isBearishPullback := true
            potentialTopPrice := open[1]
            bullishBreakIndex := bar_index[1]


        //--------------------------------------------------------------
        // START BULLISH PULLBACK
        //--------------------------------------------------------------

        if bullishPullbackDetected and not isBullishPullback
            isBullishPullback := true
            potentialBottomPrice := open[1]
            bearishBreakIndex := bar_index[1]


        //--------------------------------------------------------------
        // UPDATE BULLISH-PULLBACK ANCHOR
        //--------------------------------------------------------------

        if isBullishPullback

            if na(potentialBottomPrice)
                potentialBottomPrice := open
                bearishBreakIndex := bar_index

            if not na(potentialBottomPrice) and open < potentialBottomPrice
                potentialBottomPrice := open
                bearishBreakIndex := bar_index

            if not na(potentialBottomPrice) and close < open and open > potentialBottomPrice
                potentialBottomPrice := open
                bearishBreakIndex := bar_index


        //--------------------------------------------------------------
        // UPDATE BEARISH-PULLBACK ANCHOR
        //--------------------------------------------------------------

        if isBearishPullback

            if na(potentialTopPrice)
                potentialTopPrice := open
                bullishBreakIndex := bar_index

            if not na(potentialTopPrice) and open > potentialTopPrice
                potentialTopPrice := open
                bullishBreakIndex := bar_index

            if not na(potentialTopPrice) and close > open and open < potentialTopPrice
                potentialTopPrice := open
                bullishBreakIndex := bar_index


        //--------------------------------------------------------------
        // CANDIDATE FLAGS
        //
        // IMPORTANT:
        //
        // Finding a candidate does NOT flip delivery state.
        // Finding a candidate does NOT automatically replace the
        // currently displayed CISD.
        //--------------------------------------------------------------

        bool foundBullCandidate = false
        bool foundBearCandidate = false

        float newBullCandidateLevel = na
        float newBearCandidateLevel = na

        int newBullCandidateAnchorTime = na
        int newBearCandidateAnchorTime = na


        //==============================================================
        // BEARISH STRUCTURE BREAK
        //
        // Mature engine:
        // potentialTopPrice becomes the BULL CISD candidate.
        //==============================================================

        if bodyLow0 < bottomPrice

            bottomPrice := bodyLow0
            structureBullish := false


            //----------------------------------------------------------
            // PULLBACK BRANCH
            //----------------------------------------------------------

            if isBearishPullback and not na(bullishBreakIndex) and bar_index - bullishBreakIndex != 0

                int idxBackBear = bar_index - bullishBreakIndex
                int idxBackBearPrev = idxBackBear + 1

                float top1 = math.max(open[idxBackBear], close[idxBackBear])
                float top2 = math.max(open[idxBackBearPrev], close[idxBackBearPrev])

                topPrice := math.max(top1, top2)

                isBearishPullback := false

                if not na(potentialTopPrice)

                    foundBullCandidate := true
                    newBullCandidateLevel := potentialTopPrice

                    int bullBarsBack = bar_index - bullishBreakIndex

                    if bullBarsBack >= 0
                        newBullCandidateAnchorTime := time[bullBarsBack]
                    else
                        newBullCandidateAnchorTime := time


            //----------------------------------------------------------
            // IMMEDIATE OPPOSITE-BODY BRANCH
            //----------------------------------------------------------

            else if close[1] > open[1] and close < open

                topPrice := bodyHigh1

                isBearishPullback := false

                if not na(potentialTopPrice)

                    foundBullCandidate := true
                    newBullCandidateLevel := potentialTopPrice

                    if not na(bullishBreakIndex)

                        int bullBarsBack2 = bar_index - bullishBreakIndex

                        if bullBarsBack2 >= 0
                            newBullCandidateAnchorTime := time[bullBarsBack2]
                        else
                            newBullCandidateAnchorTime := time

                    else
                        newBullCandidateAnchorTime := time


        //==============================================================
        // BULLISH STRUCTURE BREAK
        //
        // Mature engine:
        // potentialBottomPrice becomes the BEAR CISD candidate.
        //==============================================================

        if bodyHigh0 > topPrice

            topPrice := bodyHigh0
            structureBullish := true


            //----------------------------------------------------------
            // PULLBACK BRANCH
            //----------------------------------------------------------

            if isBullishPullback and not na(bearishBreakIndex) and bar_index - bearishBreakIndex != 0

                int idxBackBull = bar_index - bearishBreakIndex
                int idxBackBullPrev = idxBackBull + 1

                float bottom1 = math.min(open[idxBackBull], close[idxBackBull])
                float bottom2 = math.min(open[idxBackBullPrev], close[idxBackBullPrev])

                bottomPrice := math.min(bottom1, bottom2)

                isBullishPullback := false

                if not na(potentialBottomPrice)

                    foundBearCandidate := true
                    newBearCandidateLevel := potentialBottomPrice

                    int bearBarsBack = bar_index - bearishBreakIndex

                    if bearBarsBack >= 0
                        newBearCandidateAnchorTime := time[bearBarsBack]
                    else
                        newBearCandidateAnchorTime := time


            //----------------------------------------------------------
            // IMMEDIATE OPPOSITE-BODY BRANCH
            //----------------------------------------------------------

            else if close[1] < open[1] and close > open

                bottomPrice := bodyLow1

                isBullishPullback := false

                if not na(potentialBottomPrice)

                    foundBearCandidate := true
                    newBearCandidateLevel := potentialBottomPrice

                    if not na(bearishBreakIndex)

                        int bearBarsBack2 = bar_index - bearishBreakIndex

                        if bearBarsBack2 >= 0
                            newBearCandidateAnchorTime := time[bearBarsBack2]
                        else
                            newBearCandidateAnchorTime := time

                    else
                        newBearCandidateAnchorTime := time


        //==============================================================
        // STORE NEW CANDIDATES
        //
        // These are stored independently.
        //
        // They do NOT automatically become the displayed line.
        //==============================================================

        if foundBullCandidate and not na(newBullCandidateLevel)
            bullCandidateLevel := newBullCandidateLevel
            bullCandidateAnchorTime := newBullCandidateAnchorTime

        if foundBearCandidate and not na(newBearCandidateLevel)
            bearCandidateLevel := newBearCandidateLevel
            bearCandidateAnchorTime := newBearCandidateAnchorTime


        //==============================================================
        // INITIALISE DELIVERY STATE
        //
        // We need an initial active CISD.
        //
        // If bearish structure produces a Bull candidate first:
        //     delivery = bearish
        //     active line = Bull CISD
        //
        // If bullish structure produces a Bear candidate first:
        //     delivery = bullish
        //     active line = Bear CISD
        //==============================================================

        if deliveryState == 0

            if foundBullCandidate and not na(bullCandidateLevel)

                deliveryState := -1
                activeDirection := 1
                activeLevel := bullCandidateLevel
                activeAnchorTime := bullCandidateAnchorTime
                activeEventId += 1

            else if foundBearCandidate and not na(bearCandidateLevel)

                deliveryState := 1
                activeDirection := -1
                activeLevel := bearCandidateLevel
                activeAnchorTime := bearCandidateAnchorTime
                activeEventId += 1


        //==============================================================
        // BEARISH DELIVERY
        //
        // Keep showing BULL CISD.
        //
        // New Bear candidates are allowed to form internally,
        // but they DO NOT take over the display.
        //
        // A bullish candle does NOT flip delivery.
        // A swing low does NOT flip delivery.
        //
        // ONLY a confirmed close ABOVE active Bull CISD flips state.
        //==============================================================

        else if deliveryState == -1

            //----------------------------------------------------------
            // During bearish delivery, a newly calculated Bull CISD
            // may update the active bullish trigger.
            //
            // It remains the SAME direction: BULL CISD.
            //----------------------------------------------------------

            if foundBullCandidate and not na(bullCandidateLevel)

                bool bullLevelChanged = activeDirection != 1 or na(activeLevel) or activeLevel != bullCandidateLevel

                if bullLevelChanged
                    activeDirection := 1
                    activeLevel := bullCandidateLevel
                    activeAnchorTime := bullCandidateAnchorTime
                    activeEventId += 1


            //----------------------------------------------------------
            // CONFIRM BULL CISD
            //
            // CLOSED candle only.
            // Wick is not enough.
            //----------------------------------------------------------

            bool bullCisdConfirmed = activeDirection == 1 and not na(activeLevel) and close > activeLevel

            if bullCisdConfirmed

                //------------------------------------------------------
                // Delivery changes to bullish.
                //------------------------------------------------------

                deliveryState := 1


                //------------------------------------------------------
                // After bullish confirmation, show the Bear CISD
                // candidate built during the preceding move.
                //------------------------------------------------------

                if not na(bearCandidateLevel)

                    activeDirection := -1
                    activeLevel := bearCandidateLevel
                    activeAnchorTime := bearCandidateAnchorTime
                    activeEventId += 1

                else

                    //--------------------------------------------------
                    // No opposite candidate available yet.
                    // Do not keep pretending the old Bull trigger is
                    // still the current reference after confirmation.
                    //--------------------------------------------------

                    activeDirection := 0
                    activeLevel := na
                    activeAnchorTime := na
                    activeEventId += 1


        //==============================================================
        // BULLISH DELIVERY
        //
        // Keep showing BEAR CISD.
        //
        // New Bull candidates can form internally but do not take over.
        //
        // ONLY a confirmed close BELOW active Bear CISD flips state.
        //==============================================================

        else if deliveryState == 1

            //----------------------------------------------------------
            // During bullish delivery, a newly calculated Bear CISD
            // may update the active bearish trigger.
            //
            // It remains the SAME direction: BEAR CISD.
            //----------------------------------------------------------

            if foundBearCandidate and not na(bearCandidateLevel)

                bool bearLevelChanged = activeDirection != -1 or na(activeLevel) or activeLevel != bearCandidateLevel

                if bearLevelChanged
                    activeDirection := -1
                    activeLevel := bearCandidateLevel
                    activeAnchorTime := bearCandidateAnchorTime
                    activeEventId += 1


            //----------------------------------------------------------
            // CONFIRM BEAR CISD
            //----------------------------------------------------------

            bool bearCisdConfirmed = activeDirection == -1 and not na(activeLevel) and close < activeLevel

            if bearCisdConfirmed

                //------------------------------------------------------
                // Delivery changes to bearish.
                //------------------------------------------------------

                deliveryState := -1


                //------------------------------------------------------
                // After bearish confirmation, show the Bull CISD
                // candidate built during the preceding move.
                //------------------------------------------------------

                if not na(bullCandidateLevel)

                    activeDirection := 1
                    activeLevel := bullCandidateLevel
                    activeAnchorTime := bullCandidateAnchorTime
                    activeEventId += 1

                else

                    activeDirection := 0
                    activeLevel := na
                    activeAnchorTime := na
                    activeEventId += 1


    //------------------------------------------------------------------
    // RETURN ACTIVE STATE
    //
    // deliveryState is also returned for future Jev integration.
    //------------------------------------------------------------------

    [activeDirection, activeLevel, activeAnchorTime, activeEventId, deliveryState]


//======================================================================
// 5m CISD
//======================================================================

[dir5, level5, anchor5, event5, delivery5] = request.security(syminfo.tickerid, "5", f_cisd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)


//======================================================================
// 15m CISD
//======================================================================

[dir15, level15, anchor15, event15, delivery15] = request.security(syminfo.tickerid, "15", f_cisd(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)


//======================================================================
// DETECT STATE CHANGES
//======================================================================

bool new5 = event5 != nz(event5[1], 0)
bool new15 = event15 != nz(event15[1], 0)


//======================================================================
// DRAWING STATE
//
// EXACTLY ONE ACTIVE CISD LINE PER TIMEFRAME.
//======================================================================

var line line5 = na
var label label5 = na

var line line15 = na
var label label15 = na


//======================================================================
// UPDATE 5m DISPLAY
//======================================================================

if show5m and new5

    if not na(line5)
        line.delete(line5)
        line5 := na

    if not na(label5)
        label.delete(label5)
        label5 := na

    if dir5 != 0 and not na(level5)

        color c5 = dir5 == 1 ? bull5Color : bear5Color
        string text5 = dir5 == 1 ? "5m BULL CISD" : "5m BEAR CISD"
        int safeAnchor5 = na(anchor5) ? time : anchor5

        line5 := line.new(x1=safeAnchor5, y1=level5, x2=time, y2=level5, xloc=xloc.bar_time, extend=extend.right, color=c5, width=lineWidth, style=line.style_solid)
        label5 := label.new(x=bar_index + labelOffset, y=level5, text=text5, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.white, 100), textcolor=c5, size=size.small)


//======================================================================
// UPDATE 15m DISPLAY
//======================================================================

if show15m and new15

    if not na(line15)
        line.delete(line15)
        line15 := na

    if not na(label15)
        label.delete(label15)
        label15 := na

    if dir15 != 0 and not na(level15)

        color c15 = dir15 == 1 ? bull15Color : bear15Color
        string text15 = dir15 == 1 ? "15m BULL CISD" : "15m BEAR CISD"
        int safeAnchor15 = na(anchor15) ? time : anchor15

        line15 := line.new(x1=safeAnchor15, y1=level15, x2=time, y2=level15, xloc=xloc.bar_time, extend=extend.right, color=c15, width=lineWidth, style=line.style_dashed)
        label15 := label.new(x=bar_index + labelOffset, y=level15, text=text15, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.white, 100), textcolor=c15, size=size.small)


//======================================================================
// INITIAL 5m DISPLAY
//======================================================================

if show5m and na(line5) and dir5 != 0 and not na(level5)

    color initC5 = dir5 == 1 ? bull5Color : bear5Color
    string initText5 = dir5 == 1 ? "5m BULL CISD" : "5m BEAR CISD"
    int initAnchor5 = na(anchor5) ? time : anchor5

    line5 := line.new(x1=initAnchor5, y1=level5, x2=time, y2=level5, xloc=xloc.bar_time, extend=extend.right, color=initC5, width=lineWidth, style=line.style_solid)
    label5 := label.new(x=bar_index + labelOffset, y=level5, text=initText5, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.white, 100), textcolor=initC5, size=size.small)


//======================================================================
// INITIAL 15m DISPLAY
//======================================================================

if show15m and na(line15) and dir15 != 0 and not na(level15)

    color initC15 = dir15 == 1 ? bull15Color : bear15Color
    string initText15 = dir15 == 1 ? "15m BULL CISD" : "15m BEAR CISD"
    int initAnchor15 = na(anchor15) ? time : anchor15

    line15 := line.new(x1=initAnchor15, y1=level15, x2=time, y2=level15, xloc=xloc.bar_time, extend=extend.right, color=initC15, width=lineWidth, style=line.style_dashed)
    label15 := label.new(x=bar_index + labelOffset, y=level15, text=initText15, xloc=xloc.bar_index, style=label.style_label_left, color=color.new(color.white, 100), textcolor=initC15, size=size.small)


//======================================================================
// DISPLAY TOGGLES
//======================================================================

if not show5m

    if not na(line5)
        line.delete(line5)
        line5 := na

    if not na(label5)
        label.delete(label5)
        label5 := na


if not show15m

    if not na(line15)
        line.delete(line15)
        line15 := na

    if not na(label15)
        label.delete(label15)
        label15 := na


//======================================================================
// KEEP LABELS AT RIGHT EDGE
//======================================================================

if not na(label5) and not na(level5)
    label.set_x(label5, bar_index + labelOffset)
    label.set_y(label5, level5)


if not na(label15) and not na(level15)
    label.set_x(label15, bar_index + labelOffset)
    label.set_y(label15, level15)


//======================================================================
// ALERTS
//
// Alerts fire when the ACTIVE CISD reference changes.
//======================================================================

if new5 and dir5 != 0 and not na(level5)

    string alertDir5 = dir5 == 1 ? "BULL" : "BEAR"

    alert("5m " + alertDir5 + " CISD | " + syminfo.ticker + " | Level: " + str.tostring(level5, format.mintick), alert.freq_once_per_bar_close)


if new15 and dir15 != 0 and not na(level15)

    string alertDir15 = dir15 == 1 ? "BULL" : "BEAR"

    alert("15m " + alertDir15 + " CISD | " + syminfo.ticker + " | Level: " + str.tostring(level15, format.mintick), alert.freq_once_per_bar_close)
````
