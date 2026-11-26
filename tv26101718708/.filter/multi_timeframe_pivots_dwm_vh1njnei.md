# Multi Timeframe Pivots (D/W/M)

- url: https://www.tradingview.com/script/VH1njNEI/
- type: indicator
- pine_id: PUB;63deebdf38894bd19ae9b09ae3821050
- version: 1.0

## Description

Definit les points pivots journalier - hebdomadaire - mensuel avec label complet pour plus de visibilite avec changement de couleur etc

## Source Code

````pine
//@version=6
indicator("Multi Timeframe Pivots (D/W/M)", "MTF Pivots", overlay = true, max_lines_count = 500, max_labels_count = 500)

// =====================================================================================
// TYPE PIVOT GRAPHIC
// =====================================================================================
type pivotGraphic
    line  pivotLine
    label pivotLabel

method delete(pivotGraphic graphic) =>
    graphic.pivotLine.delete()
    graphic.pivotLabel.delete()

// =====================================================================================
// INPUTS GENERAUX
// =====================================================================================
string GRP_GEN = "Général"
string TT_DB = (
    "When not selected, the indicator uses intraday data instead of EOD data on intraday charts. If the chart includes "
    + "data from extended hours, the pivot level calculation takes that data into account. If intraday OHLC values "
    + "differ from EOD values (normal for stocks), the calculated pivot levels will also differ."
)
bool   showLabelsInput     = input.bool(true,  "Afficher labels",  group = GRP_GEN)
bool   showPricesInput     = input.bool(true,  "Afficher prix",    group = GRP_GEN)
string positionLabelsInput = input.string("Right", "Position labels", options = ["Left", "Right"], group = GRP_GEN)
int    maxHistoricalPivotsInput = input.int(10, "Nombre de pivots historiques", 1, 100, group = GRP_GEN)
string pivotTypeInput = input.string("Traditional", "Type de calcul", options = ["Traditional", "Fibonacci", "Classic", "Camarilla"], group = GRP_GEN)
bool   isDailyBasedInput = input.bool(true, "Use daily-based values", tooltip = TT_DB, group = GRP_GEN)

// =====================================================================================
// INPUTS DAILY
// =====================================================================================
string GRP_D = "Pivots Journaliers (Daily)"
bool  dEnable    = input.bool(true, "Activer Daily", group = GRP_D)
int   dWidth     = input.int(1, "Épaisseur ligne", 1, 10, group = GRP_D)
color dColorP    = input.color(color.yellow, "P",  inline = "d1", group = GRP_D)
color dColorR    = input.color(color.green,  "R",  inline = "d1", group = GRP_D)
color dColorS    = input.color(color.red,    "S",  inline = "d1", group = GRP_D)
bool  dShow1     = input.bool(true, "S1/R1", inline = "d2", group = GRP_D)
bool  dShow2     = input.bool(true, "S2/R2", inline = "d2", group = GRP_D)
bool  dShow3     = input.bool(false, "S3/R3", inline = "d2", group = GRP_D)

// =====================================================================================
// INPUTS WEEKLY
// =====================================================================================
string GRP_W = "Pivots Hebdomadaires (Weekly)"
bool  wEnable    = input.bool(true, "Activer Weekly", group = GRP_W)
int   wWidth     = input.int(2, "Épaisseur ligne", 1, 10, group = GRP_W)
color wColorP    = input.color(color.orange, "P",  inline = "w1", group = GRP_W)
color wColorR    = input.color(color.blue,   "R",  inline = "w1", group = GRP_W)
color wColorS    = input.color(color.purple, "S",  inline = "w1", group = GRP_W)
bool  wShow1     = input.bool(true, "S1/R1", inline = "w2", group = GRP_W)
bool  wShow2     = input.bool(true, "S2/R2", inline = "w2", group = GRP_W)
bool  wShow3     = input.bool(false, "S3/R3", inline = "w2", group = GRP_W)

// =====================================================================================
// INPUTS MONTHLY
// =====================================================================================
string GRP_M = "Pivots Mensuels (Monthly)"
bool  mEnable    = input.bool(true, "Activer Monthly", group = GRP_M)
int   mWidth     = input.int(3, "Épaisseur ligne", 1, 10, group = GRP_M)
color mColorP    = input.color(color.white,  "P",  inline = "m1", group = GRP_M)
color mColorR    = input.color(color.teal,   "R",  inline = "m1", group = GRP_M)
color mColorS    = input.color(color.maroon, "S",  inline = "m1", group = GRP_M)
bool  mShow1     = input.bool(true, "S1/R1", inline = "m2", group = GRP_M)
bool  mShow2     = input.bool(true, "S2/R2", inline = "m2", group = GRP_M)
bool  mShow3     = input.bool(false, "S3/R3", inline = "m2", group = GRP_M)

// =====================================================================================
// FONCTIONS COMMUNES
// =====================================================================================

// @function Construit le tableau des réglages (nom, couleur, show) pour un timeframe donné
buildSettings(string tfLabel, color colP, color colR, color colS, bool show1, bool show2, bool show3) =>
    array<string> names = array.from(
        "P " + tfLabel, "R1 " + tfLabel, "S1 " + tfLabel, "R2 " + tfLabel, "S2 " + tfLabel, "R3 " + tfLabel, "S3 " + tfLabel
    )
    array<color> colors = array.from(colP, colR, colS, colR, colS, colR, colS)
    array<bool>  shows  = array.from(true, show1, show1, show2, show2, show3, show3)
    [names, colors, shows]

// @function Compteur de changement de période
pivotChangeCounter(bool condition) =>
    var int count = 0
    if condition and bar_index > 0
        count += 1
    count

// @function Calcule les pivots sur un timeframe donné via request.security
calcPivots(string tf) =>
    bool change = timeframe.change(tf)
    [arrStatic, arrDeveloping, cnt] = request.security(
        ticker.modify(syminfo.tickerid, settlement_as_close = settlement_as_close.on),
        tf, [
            ta.pivot_point_levels(pivotTypeInput, change),
            ta.pivot_point_levels(pivotTypeInput, change, developing = true),
            pivotChangeCounter(change)
        ], lookahead = barmerge.lookahead_on
    )
    [arrStatic, arrDeveloping, cnt]

// @function Affixe (étire) les anciens pivots jusqu'au temps donné
affixOldPivots(matrix<pivotGraphic> graphicsMatrix, int endTime) =>
    int rows = graphicsMatrix.rows()
    if rows > 0
        array<pivotGraphic> lastGraphics = graphicsMatrix.row(rows - 1)
        for graphic in lastGraphics
            graphic.pivotLine.set_x2(endTime)
            if positionLabelsInput == "Right"
                graphic.pivotLabel.set_x(endTime)

// @function Dessine les nouveaux pivots pour un timeframe
drawNewPivots(matrix<pivotGraphic> graphicsMatrix, int startTime, string tf, array<float> pivotPointsArray,
              array<string> names, array<color> colors, array<bool> shows, int lineWidth, int maxHist) =>
    array<pivotGraphic> newGraphics = array.new<pivotGraphic>()
    int endTime = startTime + timeframe.in_seconds(tf) * 1000
    [labelPosition, labelStyle] = switch positionLabelsInput
        "Left"  => [startTime, label.style_label_right]
        "Right" => [endTime,   label.style_label_left]
    for i = 0 to math.min(pivotPointsArray.size(), names.size()) - 1
        float level = pivotPointsArray.get(i)
        if not na(level) and shows.get(i)
            line pivotLine = line.new(
                startTime, level, endTime, level, xloc = xloc.bar_time, color = colors.get(i), width = lineWidth
            )
            label pivotLabel = label.new(
                labelPosition, level,
                (showLabelsInput ? names.get(i) + " " : "")
                + (showPricesInput ? "(" + str.tostring(level, format.mintick) + ")" : ""),
                style = labelStyle, textcolor = colors.get(i), color = #00000000, xloc = xloc.bar_time
            )
            newGraphics.push(pivotGraphic.new(pivotLine, pivotLabel))
    if newGraphics.size() > 0
        graphicsMatrix.add_row(array_id = newGraphics)
        if graphicsMatrix.rows() > maxHist
            array<pivotGraphic> oldGraphics = graphicsMatrix.remove_row(0)
            for graphic in oldGraphics
                graphic.delete()

// @function Gère le cycle de vie complet (calcul + dessin) pour un timeframe
processTimeframe(bool enabled, string tf, string tfLabel, color colP, color colR, color colS,
                  bool show1, bool show2, bool show3, int lineWidth, int maxHist) =>
    var matrix<pivotGraphic> graphicsMatrix = matrix.new<pivotGraphic>()
    var int firstBarTime = time
    if enabled
        // Pour le Daily : si "Use daily-based values" est décoché et qu'on est sur un chart intraday,
        // on utilise les données intraday du chart (1440 = équivalent minute du jour) au lieu de l'EOD ("1D").
        string effectiveTf = tf == "1D" and not isDailyBasedInput ? "1440" : tf
        [names, colors, shows] = buildSettings(tfLabel, colP, colR, colS, show1, show2, show3)
        [pivotStatic, pivotDeveloping, pivotCount] = calcPivots(effectiveTf)

        var bool skipNextPivots = false
        if barstate.islast and barstate.isconfirmed
            int nextBarOpenTime = time("", bars_back = -1)
            int nextPivotStartTime = time(effectiveTf, timeframe_bars_back = -1)
            if nextBarOpenTime >= nextPivotStartTime
                affixOldPivots(graphicsMatrix, nextPivotStartTime)
                drawNewPivots(graphicsMatrix, nextPivotStartTime, effectiveTf, pivotDeveloping, names, colors, shows, lineWidth, maxHist)
                skipNextPivots := true

        if pivotCount != pivotCount[1]
            if skipNextPivots
                skipNextPivots := false
            else
                affixOldPivots(graphicsMatrix, time)
                drawNewPivots(graphicsMatrix, time, effectiveTf, pivotStatic, names, colors, shows, lineWidth, maxHist)
        else if graphicsMatrix.rows() > 0 and graphicsMatrix.row(graphicsMatrix.rows() - 1).last().pivotLine.get_x2() <= time[1]
            affixOldPivots(graphicsMatrix, time)

        if barstate.islastconfirmedhistory and graphicsMatrix.rows() == 0
            if pivotCount > 0 and not na(pivotStatic)
                drawNewPivots(graphicsMatrix, firstBarTime, effectiveTf, pivotStatic, names, colors, shows, lineWidth, maxHist)
            else if timeframe.isintraday and not isDailyBasedInput
                runtime.error(
                    "Not enough intraday data available for pivot point calculation. "
                    + "Try selecting the 'Use daily-based values' checkbox to request EOD data."
                )

// =====================================================================================
// EXECUTION POUR CHAQUE TIMEFRAME
// =====================================================================================
processTimeframe(dEnable, "1D", "Daily",   dColorP, dColorR, dColorS, dShow1, dShow2, dShow3, dWidth, maxHistoricalPivotsInput)
processTimeframe(wEnable, "1W", "Weekly",  wColorP, wColorR, wColorS, wShow1, wShow2, wShow3, wWidth, maxHistoricalPivotsInput)
processTimeframe(mEnable, "1M", "Monthly", mColorP, mColorR, mColorS, mShow1, mShow2, mShow3, mWidth, maxHistoricalPivotsInput)
````
