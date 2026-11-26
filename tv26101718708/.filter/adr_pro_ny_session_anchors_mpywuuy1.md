# ADR Pro - NY Session Anchors

- url: https://www.tradingview.com/script/Mpywuuy1/
- type: indicator
- pine_id: PUB;ed080fb36a4647748a88e71984ca9690
- version: 11.0

## Description

ADR Pro – NY Session Anchors projects Average Daily Range levels from selectable New York reference opens.

It displays customizable upper and lower ADR zones, optional secondary levels, and a visual history filter for current or previous sessions. Designed for intraday charts.

## Source Code

````pine
//@version=6
// ============================================================
// CHANGE LOG
// Generated: 2026-09-21 11:54:34 (UTC-3 / São Paulo)
// Changes:
// - Extended the optional 50% and 66% secondary zone levels across the complete
//   anchor-to-anchor period whenever Zone Fill Mode is set to Full Session.
// - Progressive mode and the independent ADR Lines layer remain unchanged.
// - Balanced line-object history between full-session secondary levels, ADR
//   lines and TD/MD Open to prevent TradingView object-limit errors.
// - Changed the default Zone Fill Mode from Progressive to Full Session.
// - Changed the default Zone History from All history to Current session only.
// - All alternative display and history options remain available.
// - Added "Zone Fill Mode" with Progressive (original behavior) and
//   Full Session display options.
// - Full Session pre-fills each upper and lower ADR zone from the selected
//   anchor through 5:59pm ET before the next 6pm ET anchor (or the equivalent
//   24-hour cycle when another anchor is selected).
// - Zone history, ADR calculations, projection modes, ADR lines, TD/MD Open,
//   status panel and alerts remain unchanged.
// - Added TD Open (6pm ET) and MD Open (12am ET) lines using the exact
//   1-minute opening price on every supported chart timeframe up to H4.
// - Added independent visibility, color, line width, right extension, label
//   offset, label visibility and history controls for TD/MD Open.
// - TD/MD lines start at their exact New York timestamps and advance with the
//   current chart while preserving the configured right-side extension.
// - Reserved line-object capacity for the TD/MD history without changing ADR
//   calculations, projections, zones, status panel or alerts.
// - Changed the ADR Status panel defaults to Bottom Left position and S text size.
// - Anchored ADR level labels to the left with a transparent label background,
//   so all text is rendered after the right endpoint instead of over the line.
// - Reordered the "Visibility" inputs to: Zone History, ADR Display Style,
//   then Show Secondary Levels.
// - Kept the directional +/- notation on every ADR level label.
// - Moved the "Style - ADR Lines" settings block directly below "Visibility".
// - This update changes only the settings-panel order; calculations, drawings
//   and alerts remain unchanged.
// - Added "Lines Only" and "Zones + Lines" ADR display styles.
// - Lines start at the active anchor and advance with the session, extending a
//   user-defined number of bars beyond the current candle.
// - Added configurable line color, right-side extension and level labels.
// - The line layer always shows +/-33% and +/-100%; +/-50% and +/-66% follow
//   the existing "Show Secondary Levels" setting.
// - The existing zones remain the default display style.
// - ADR calculations, anchors, projection values, status panel and alerts are unchanged.
// ============================================================
indicator("ADR Pro - NY Session Anchors", shorttitle="ADR Pro NY", overlay=true, max_lines_count=500, max_labels_count=50, max_boxes_count=500)
// ==========================================
// 0. CONTROLE SILENCIOSO DO TIMEFRAME
// ==========================================
// Em D, W e M, o indicador fica oculto sem gerar erro. Ao retornar para um
// timeframe intradiário de 1 minuto ou superior, ele reaparece normalmente.
bool supportedTimeframe = timeframe.isintraday and timeframe.in_seconds() >= 60
// ==========================================
// 1. CONFIGURAÇÕES
// ==========================================
string NY_TZ = "America/New_York"
int ONE_DAY_MS = 24 * 60 * 60 * 1000
openType = input.string(
    "06:00 PM ET (Futures Session)",
    title="Reference Anchor Time",
    options=[
        "12:00 AM ET (Midnight NY)",
        "06:00 AM ET (Pre-NY)",
        "06:00 PM ET (Futures Session)",
        "08:30 AM ET (News)",
        "09:30 AM ET (RTH)"
    ],
    group="Price Anchor"
)
length = input.int(5, title="ADR Period (Days)", minval=1, group="Basic Settings")
projectionMode = input.string(
    "Split ADR",
    title="Projection Mode",
    options=["Full ADR", "Split ADR"],
    tooltip="Full ADR projects 100% of the ADR above and below the anchor. Split ADR creates a symmetrical one-ADR envelope using 50% above and 50% below the anchor.",
    group="Basic Settings"
)
bool splitMode = projectionMode == "Split ADR"
showAdrStatus = input.bool(true, title="Show ADR Status Panel", group="ADR Status Panel")
adrStatusPosition = input.string(
    "Bottom Left",
    title="Panel Position",
    options=[
        "Top Left", "Top Center", "Top Right",
        "Middle Left", "Middle Center", "Middle Right",
        "Bottom Left", "Bottom Center", "Bottom Right"
    ],
    group="ADR Status Panel"
)
adrStatusTextSize = input.string(
    "S",
    title="Panel Text Size",
    options=["S", "M", "L"],
    group="ADR Status Panel"
)
historyMode = input.string(
    "Current session only",
    title="Zone History",
    options=[
        "Current session only",
        "Current + 1 previous session",
        "Current + 2 previous sessions",
        "Current + 3 previous sessions",
        "All history"
    ],
    group="Visibility"
)
displayStyle = input.string(
    "Zones",
    title="ADR Display Style",
    options=["Zones", "Lines Only", "Zones + Lines"],
    tooltip="Zones preserves the original filled areas. Lines Only draws horizontal ADR levels. Zones + Lines displays both layers simultaneously.",
    group="Visibility"
)
zoneFillMode = input.string(
    "Full Session",
    title="Zone Fill Mode",
    options=["Progressive", "Full Session"],
    tooltip="Progressive fills each zone as the chart advances. Full Session pre-fills the complete 24-hour session from the selected anchor to the next occurrence of that anchor.",
    group="Visibility"
)
showSecondary = input.bool(false, title="Show Secondary Levels (50% & 66%)?", tooltip="Displays the 50% and 66% levels of the selected projection mode. In Split ADR, all percentages are calculated from half of the full ADR.", group="Visibility")
bool showZoneLayer = displayStyle != "Lines Only"
bool showLineLayer = displayStyle != "Zones"
bool fullSessionZoneFill = zoneFillMode == "Full Session"
levelLineColor = input.color(color.black, title="ADR Line Color", group="Style - ADR Lines")
levelLineExtension = input.int(20, title="Right Extension (Bars)", minval=0, maxval=500, group="Style - ADR Lines")
showTDOpen = input.bool(true, title="Show TD Open", group="TD/MD Open")
showMDOpen = input.bool(true, title="Show MD Open", group="TD/MD Open")
tdOpenColor = input.color(color.black, title="TD Open Color", group="TD/MD Open")
mdOpenColor = input.color(color.black, title="MD Open Color", group="TD/MD Open")
openLineWidth = input.int(1, title="Line Width", minval=1, maxval=5, group="TD/MD Open")
openRightBars = input.int(20, title="Right Extension (Bars)", minval=0, maxval=200, group="TD/MD Open")
openTextOffset = input.int(0, title="Label Offset (Bars)", minval=0, maxval=20, group="TD/MD Open")
showOpenText = input.bool(true, title="Show TD/MD Open Labels", group="TD/MD Open")
openDays = input.int(1, title="Show Last X Days", minval=1, maxval=10, group="TD/MD Open")
colorUpper = input.color(color.red, title="Upper Zone Color", group="Style - Upper Zone")
transUpper = input.int(85, title="Upper Transparency (0=Opaque, 100=Invisible)", minval=0, maxval=100, group="Style - Upper Zone")
colorLower = input.color(color.green, title="Lower Zone Color", group="Style - Lower Zone")
transLower = input.int(85, title="Lower Transparency (0=Opaque, 100=Invisible)", minval=0, maxval=100, group="Style - Lower Zone")
enableAlerts = input.bool(false, title="Enable Alerts", tooltip="To receive notifications, first select the alert options below. Then open TradingView's Create Alert window, select ADR Pro NY, choose 'Any alert() function call' and create the alert. Only one TradingView alert is required.\n\nAlerts trigger immediately when the live price touches a selected projection. Each selected event triggers once per direction per session and resets at the next active anchor. Levels already reached when the TradingView alert is created are synchronized without a retrospective notification. If several events occur on the same update, they are combined into one notification.", group="Alerts")
alertAt33 = input.bool(false, title="Alert at 33% Projection", group="Alerts")
alertAt50 = input.bool(false, title="Alert at 50% Projection", group="Alerts")
alertAt66 = input.bool(false, title="Alert at 66% Projection", group="Alerts")
alertAt100 = input.bool(false, title="Alert at 100% Projection", group="Alerts")
alertAdrUsed80 = input.bool(false, title="Alert when ADR Used reaches 80%", group="Alerts")
alertAdrUsed100 = input.bool(false, title="Alert when ADR Used reaches 100%", group="Alerts")
// O seletor abaixo controla exclusivamente a quantidade de sessões desenhadas.
// Nenhuma destas variáveis participa do cálculo da âncora ou do ADR.
bool showAllHistory = historyMode == "All history"
int sessionsToKeep = switch historyMode
    "Current session only"             => 1
    "Current + 1 previous session"     => 2
    "Current + 2 previous sessions"    => 3
    "Current + 3 previous sessions"    => 4
    => 0
int fullZoneSecondarySessionsToKeep = showAllHistory ? (showLineLayer ? 50 : 110) : sessionsToKeep
int reservedFullZoneSecondaryLines = fullSessionZoneFill and showZoneLayer and showSecondary ? fullZoneSecondarySessionsToKeep * 4 : 0
string adrStatusTablePosition = switch adrStatusPosition
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right
string adrStatusTableTextSize = switch adrStatusTextSize
    "S" => size.small
    "L" => size.large
    => size.normal
string anchorStatusLabel = switch openType
    "06:00 AM ET (Pre-NY)"          => "6am ET"
    "06:00 PM ET (Futures Session)" => "6pm ET"
    "08:30 AM ET (News)"            => "8:30am ET"
    "09:30 AM ET (RTH)"             => "9:30am ET"
    => "12am ET"
// ==========================================
// 2. HORÁRIO DA ÂNCORA
// ==========================================
int targetHour = 0
int targetMin  = 0
if openType == "06:00 AM ET (Pre-NY)"
    targetHour := 6
else if openType == "06:00 PM ET (Futures Session)"
    targetHour := 18
else if openType == "08:30 AM ET (News)"
    targetHour := 8
    targetMin  := 30
else if openType == "09:30 AM ET (RTH)"
    targetHour := 9
    targetMin  := 30
// ==========================================
// 3. ADR DOS DIAS OFICIAIS CONCLUÍDOS
// ==========================================
// A âncora não participa desta média. O ADR permanece baseado exclusivamente
// nos últimos N candles diários oficiais já concluídos.
adrVal = request.security(
    syminfo.tickerid,
    "D",
    ta.sma(high - low, length)[1],
    gaps=barmerge.gaps_off,
    lookahead=barmerge.lookahead_on
)
// ==========================================
// 4. ÂNCORA E RANGE INTRABAR DESDE A ÂNCORA
// ==========================================
// Lê todos os candles de 1 minuto contidos em cada candle do gráfico. Assim,
// uma âncora às 08:30 em um gráfico de 1h começa a medir somente às 08:30,
// sem incorporar ao range os minutos de 08:00 a 08:29.
array<int> intrabarTimes = array.new_int()
array<float> intrabarOpens = array.new_float()
array<float> intrabarHighs = array.new_float()
array<float> intrabarLows = array.new_float()
// Evita solicitar e processar candles de 1 minuto quando o gráfico estiver
// em D, W ou M. Essa condição afeta somente a exibição fora do intraday.
if supportedTimeframe
    [ltfTimes, ltfOpens, ltfHighs, ltfLows] = request.security_lower_tf(
        syminfo.tickerid,
        "1",
        [time, open, high, low]
    )
    intrabarTimes := ltfTimes
    intrabarOpens := ltfOpens
    intrabarHighs := ltfHighs
    intrabarLows := ltfLows
var float capturedAnchorOpen = na
var int capturedAnchorTime   = na
var float capturedSessionAdr = na
var float rangeHigh          = na
var float rangeLow           = na
var bool rangeActive         = false
var int lastProcessedTime    = na
int intrabarCount = array.size(intrabarTimes)
int knownTime     = time
// Em gráficos acima de 1 minuto, processa cronologicamente todos os intrabars.
if supportedTimeframe and timeframe.in_seconds() > 60 and intrabarCount > 0
    knownTime := array.get(intrabarTimes, intrabarCount - 1)
    for intrabarIndex = 0 to intrabarCount - 1
        int intrabarTime = array.get(intrabarTimes, intrabarIndex)
        float intrabarOpen = array.get(intrabarOpens, intrabarIndex)
        float intrabarHigh = array.get(intrabarHighs, intrabarIndex)
        float intrabarLow = array.get(intrabarLows, intrabarIndex)
        bool reopenedAfterLongGap = not na(lastProcessedTime) and intrabarTime - lastProcessedTime > 6 * 60 * 60 * 1000
        bool isAnchorMinute = hour(intrabarTime, NY_TZ) == targetHour and minute(intrabarTime, NY_TZ) == targetMin
        // Impede qualquer continuidade entre o fechamento de sexta-feira e
        // a reabertura de domingo (ou após outro fechamento prolongado).
        if reopenedAfterLongGap
            capturedAnchorOpen := na
            capturedAnchorTime := na
            capturedSessionAdr := na
            rangeHigh := na
            rangeLow := na
            rangeActive := false
        if isAnchorMinute
            capturedAnchorOpen := intrabarOpen
            capturedAnchorTime := intrabarTime
            capturedSessionAdr := adrVal
            rangeHigh := intrabarHigh
            rangeLow := intrabarLow
            rangeActive := true
        else if rangeActive
            rangeHigh := math.max(rangeHigh, intrabarHigh)
            rangeLow := math.min(rangeLow, intrabarLow)
        lastProcessedTime := intrabarTime
// No gráfico de 1 minuto, usa diretamente o candle do próprio gráfico.
if supportedTimeframe and timeframe.in_seconds() == 60
    knownTime := time
    bool reopenedAfterLongGap = not na(time[1]) and time - time[1] > 6 * 60 * 60 * 1000
    bool isAnchorMinute = hour(time, NY_TZ) == targetHour and minute(time, NY_TZ) == targetMin
    if reopenedAfterLongGap
        capturedAnchorOpen := na
        capturedAnchorTime := na
        capturedSessionAdr := na
        rangeHigh := na
        rangeLow := na
        rangeActive := false
    if isAnchorMinute
        capturedAnchorOpen := open
        capturedAnchorTime := time
        capturedSessionAdr := adrVal
        rangeHigh := high
        rangeLow := low
        rangeActive := true
    else if rangeActive
        rangeHigh := math.max(rangeHigh, high)
        rangeLow := math.min(rangeLow, low)
    lastProcessedTime := time
todayAnchorTime = timestamp(
    NY_TZ,
    year(knownTime, NY_TZ),
    month(knownTime, NY_TZ),
    dayofmonth(knownTime, NY_TZ),
    targetHour,
    targetMin,
    0
)
previousDayReference = knownTime - ONE_DAY_MS
previousDayAnchorTime = timestamp(
    NY_TZ,
    year(previousDayReference, NY_TZ),
    month(previousDayReference, NY_TZ),
    dayofmonth(previousDayReference, NY_TZ),
    targetHour,
    targetMin,
    0
)
expectedAnchorTime = knownTime >= todayAnchorTime ? todayAnchorTime : previousDayAnchorTime
anchorIsValid = supportedTimeframe and not na(capturedAnchorTime) and capturedAnchorTime == expectedAnchorTime
anchorOpen    = anchorIsValid ? capturedAnchorOpen : na
sessionAdr    = anchorIsValid ? capturedSessionAdr : na
// Estas métricas alimentam somente o painel informativo. Elas não alteram
// o ADR diário nem qualquer nível projetado.
anchorSessionRange = anchorIsValid and rangeActive ? rangeHigh - rangeLow : na
adrUsedPct = not na(anchorSessionRange) and not na(sessionAdr) and sessionAdr > 0 ? anchorSessionRange / sessionAdr * 100 : na
toAverage  = not na(anchorSessionRange) and not na(sessionAdr) ? math.max(sessionAdr - anchorSessionRange, 0) : na
// ==========================================
// 5. PROJEÇÕES DO ADR
// ==========================================
// O ADR oficial disponível na ocorrência da âncora fica congelado até a
// próxima âncora. Assim, o fechamento diário das 18:00 ET não desloca zonas
// que ainda pertencem, por exemplo, à âncora Midnight anterior.
// Full ADR usa o ADR diário integral como base. Split ADR usa metade do ADR
// como base de projeção. Todos os percentuais abaixo são frações dessa base:
// no Split, 33%, 50%, 66% e 100% equivalem, respectivamente, a
// 16,5%, 25%, 33% e 50% do ADR diário integral em cada direção.
projectionRange = sessionAdr * (splitMode ? 0.50 : 1.00)
adr100High = anchorOpen + projectionRange
adr66High  = anchorOpen + projectionRange * 0.66
adr50High  = anchorOpen + projectionRange * 0.50
adr33High  = anchorOpen + projectionRange * 0.33
adr33Low   = anchorOpen - projectionRange * 0.33
adr50Low   = anchorOpen - projectionRange * 0.50
adr66Low   = anchorOpen - projectionRange * 0.66
adr100Low  = anchorOpen - projectionRange
outerHigh = adr100High
outerLow  = adr100Low
// ==========================================
// 6. TODO O HISTÓRICO — PLOTS ORIGINAIS
// ==========================================
// Quando esta opção está ativa, o comportamento visual permanece exatamente
// igual ao da versão anterior.
plotHighOuter = showZoneLayer and showAllHistory ? outerHigh : na
plotHigh66  = showZoneLayer and showAllHistory and showSecondary and not fullSessionZoneFill ? adr66High : na
plotHighSecondary = showZoneLayer and showAllHistory and showSecondary and not fullSessionZoneFill ? adr50High : na
plotHigh33  = showZoneLayer and showAllHistory ? adr33High : na
plotLow33   = showZoneLayer and showAllHistory ? adr33Low : na
plotLowSecondary = showZoneLayer and showAllHistory and showSecondary and not fullSessionZoneFill ? adr50Low : na
plotLow66   = showZoneLayer and showAllHistory and showSecondary and not fullSessionZoneFill ? adr66Low : na
plotLowOuter = showZoneLayer and showAllHistory ? outerLow : na
pHighOuter = plot(plotHighOuter, title="Upper Zone Outer Boundary", color=color.new(colorUpper, transUpper), linewidth=1, style=plot.style_linebr)
pHigh33  = plot(plotHigh33, title="+33% Projection High Trigger", color=color.new(colorUpper, transUpper), linewidth=1, style=plot.style_linebr)
pLow33  = plot(plotLow33, title="-33% Projection Low Trigger", color=color.new(colorLower, transLower), linewidth=1, style=plot.style_linebr)
pLowOuter = plot(plotLowOuter, title="Lower Zone Outer Boundary", color=color.new(colorLower, transLower), linewidth=1, style=plot.style_linebr)
plot(plotHigh66, title="+66% Projection High", color=color.new(colorUpper, 60), linewidth=1, style=plot.style_linebr)
plot(plotHighSecondary, title="+50% Projection High", color=color.new(colorUpper, 75), linewidth=1, style=plot.style_linebr)
plot(plotLowSecondary, title="-50% Projection Low", color=color.new(colorLower, 75), linewidth=1, style=plot.style_linebr)
plot(plotLow66, title="-66% Projection Low", color=color.new(colorLower, 60), linewidth=1, style=plot.style_linebr)
fill(pHigh33, pHighOuter, color=showZoneLayer and showAllHistory and not fullSessionZoneFill ? color.new(colorUpper, transUpper) : na, title="Upper Action Zone")
fill(pLow33, pLowOuter, color=showZoneLayer and showAllHistory and not fullSessionZoneFill ? color.new(colorLower, transLower) : na, title="Lower Action Zone")
// ==========================================
// 7. HISTÓRICO LIMITADO — SOMENTE CAMADA VISUAL
// ==========================================
// Objetos gráficos permitem apagar sessões antigas sem recalcular ou alterar
// qualquer valor de ADR. Cada sessão usa 8 linhas e 2 preenchimentos.
var array<line> storedLines = array.new_line()
var array<linefill> storedFills = array.new_linefill()
var line activeHigh100Line = na
var line activeHigh66Line = na
var line activeHigh50Line = na
var line activeHigh33Line = na
var line activeLow33Line = na
var line activeLow50Line = na
var line activeLow66Line = na
var line activeLow100Line = na
// Cria a sessão no primeiro candle do gráfico em que a âncora se torna válida.
// Isso também cobre timeframes maiores quando a âncora ocorreu dentro do candle anterior.
bool newValidSession = anchorIsValid and (not anchorIsValid[1] or capturedAnchorTime != capturedAnchorTime[1])

// No modo Full Session, cada zona já nasce preenchida até a próxima ocorrência
// da âncora selecionada. O timestamp é calculado no fuso de Nova York para
// preservar corretamente as transições de horário de verão.
var array<box> fullSessionZoneBoxes = array.new_box()
var array<line> fullSessionSecondaryLines = array.new_line()
if showZoneLayer and fullSessionZoneFill and newValidSession
    int nextSessionAnchorTime = timestamp(
        NY_TZ,
        year(capturedAnchorTime, NY_TZ),
        month(capturedAnchorTime, NY_TZ),
        dayofmonth(capturedAnchorTime, NY_TZ) + 1,
        targetHour,
        targetMin,
        0
    )
    int fullZoneSessionsToKeep = showAllHistory ? 248 : sessionsToKeep
    while array.size(fullSessionZoneBoxes) > (fullZoneSessionsToKeep - 1) * 2
        box.delete(array.shift(fullSessionZoneBoxes))
    box upperFullSessionBox = box.new(left=capturedAnchorTime, top=outerHigh, right=nextSessionAnchorTime, bottom=adr33High, xloc=xloc.bar_time, border_color=color.new(colorUpper, transUpper), border_width=1, bgcolor=color.new(colorUpper, transUpper))
    box lowerFullSessionBox = box.new(left=capturedAnchorTime, top=adr33Low, right=nextSessionAnchorTime, bottom=outerLow, xloc=xloc.bar_time, border_color=color.new(colorLower, transLower), border_width=1, bgcolor=color.new(colorLower, transLower))
    array.push(fullSessionZoneBoxes, upperFullSessionBox)
    array.push(fullSessionZoneBoxes, lowerFullSessionBox)
    if showSecondary
        while array.size(fullSessionSecondaryLines) > (fullZoneSecondarySessionsToKeep - 1) * 4
            line.delete(array.shift(fullSessionSecondaryLines))
        line fullHigh66Line = line.new(capturedAnchorTime, adr66High, nextSessionAnchorTime, adr66High, xloc=xloc.bar_time, color=color.new(colorUpper, 60), width=1)
        line fullHigh50Line = line.new(capturedAnchorTime, adr50High, nextSessionAnchorTime, adr50High, xloc=xloc.bar_time, color=color.new(colorUpper, 75), width=1)
        line fullLow50Line = line.new(capturedAnchorTime, adr50Low, nextSessionAnchorTime, adr50Low, xloc=xloc.bar_time, color=color.new(colorLower, 75), width=1)
        line fullLow66Line = line.new(capturedAnchorTime, adr66Low, nextSessionAnchorTime, adr66Low, xloc=xloc.bar_time, color=color.new(colorLower, 60), width=1)
        array.push(fullSessionSecondaryLines, fullHigh66Line)
        array.push(fullSessionSecondaryLines, fullHigh50Line)
        array.push(fullSessionSecondaryLines, fullLow50Line)
        array.push(fullSessionSecondaryLines, fullLow66Line)

if showZoneLayer and not showAllHistory and newValidSession
    // Se a âncora estiver no interior de um candle maior, começa a desenhar
    // na abertura do candle seguinte, preservando a exibição já adotada.
    int sessionVisualStart = capturedAnchorTime == time ? time : time_close
    activeHigh100Line := line.new(sessionVisualStart, outerHigh, time_close, outerHigh, xloc=xloc.bar_time, color=color.new(colorUpper, transUpper), width=1)
    activeHigh66Line  := line.new(sessionVisualStart, adr66High, time_close, adr66High, xloc=xloc.bar_time, color=showSecondary and not fullSessionZoneFill ? color.new(colorUpper, 60) : na, width=1)
    activeHigh50Line  := line.new(sessionVisualStart, adr50High, time_close, adr50High, xloc=xloc.bar_time, color=showSecondary and not fullSessionZoneFill ? color.new(colorUpper, 75) : na, width=1)
    activeHigh33Line  := line.new(sessionVisualStart, adr33High, time_close, adr33High, xloc=xloc.bar_time, color=color.new(colorUpper, transUpper), width=1)
    activeLow33Line   := line.new(sessionVisualStart, adr33Low, time_close, adr33Low, xloc=xloc.bar_time, color=color.new(colorLower, transLower), width=1)
    activeLow50Line   := line.new(sessionVisualStart, adr50Low, time_close, adr50Low, xloc=xloc.bar_time, color=showSecondary and not fullSessionZoneFill ? color.new(colorLower, 75) : na, width=1)
    activeLow66Line   := line.new(sessionVisualStart, adr66Low, time_close, adr66Low, xloc=xloc.bar_time, color=showSecondary and not fullSessionZoneFill ? color.new(colorLower, 60) : na, width=1)
    activeLow100Line  := line.new(sessionVisualStart, outerLow, time_close, outerLow, xloc=xloc.bar_time, color=color.new(colorLower, transLower), width=1)
    array.push(storedLines, activeHigh100Line)
    array.push(storedLines, activeHigh66Line)
    array.push(storedLines, activeHigh50Line)
    array.push(storedLines, activeHigh33Line)
    array.push(storedLines, activeLow33Line)
    array.push(storedLines, activeLow50Line)
    array.push(storedLines, activeLow66Line)
    array.push(storedLines, activeLow100Line)
    if not fullSessionZoneFill
        upperFill = linefill.new(activeHigh33Line, activeHigh100Line, color.new(colorUpper, transUpper))
        lowerFill = linefill.new(activeLow33Line, activeLow100Line, color.new(colorLower, transLower))
        array.push(storedFills, upperFill)
        array.push(storedFills, lowerFill)
    while array.size(storedFills) > sessionsToKeep * 2
        linefill.delete(array.shift(storedFills))
    while array.size(storedLines) > sessionsToKeep * 8
        line.delete(array.shift(storedLines))
// A sessão ativa é estendida somente enquanto sua âncora continua válida.
// Isso preserva as lacunas reais de mercado fechado ou de âncora ainda inexistente.
if showZoneLayer and not showAllHistory and anchorIsValid and not na(activeHigh100Line)
    line.set_x2(activeHigh100Line, time_close)
    line.set_x2(activeHigh66Line, time_close)
    line.set_x2(activeHigh50Line, time_close)
    line.set_x2(activeHigh33Line, time_close)
    line.set_x2(activeLow33Line, time_close)
    line.set_x2(activeLow50Line, time_close)
    line.set_x2(activeLow66Line, time_close)
    line.set_x2(activeLow100Line, time_close)
// ==========================================
// 7B. CAMADA VISUAL DE LINHAS
// ==========================================
// Cada linha começa no timestamp exato da âncora. Durante a sessão ativa, sua
// extremidade direita acompanha o gráfico e permanece o número configurado de
// barras à frente do candle atual. Ao nascer uma nova sessão, as linhas da
// sessão anterior são encerradas no último candle negociado e deixam de avançar.
var array<line> storedLevelLines = array.new_line()
var line levelHigh100Line = na
var line levelHigh66Line = na
var line levelHigh50Line = na
var line levelHigh33Line = na
var line levelLow33Line = na
var line levelLow50Line = na
var line levelLow66Line = na
var line levelLow100Line = na
var array<label> activeLevelLabels = array.new_label()

int chartBarDurationMs = supportedTimeframe ? int(timeframe.in_seconds() * 1000) : 0
int activeLineRightTime = time_close + chartBarDurationMs * levelLineExtension
int activeLabelTime = activeLineRightTime

if showLineLayer and newValidSession
    // Finaliza a sessão anterior no fechamento do último candle negociado.
    // Assim, a linha não atravessa intervalos de mercado fechado ou fins de semana.
    if not na(levelHigh100Line)
        int previousSessionEndTime = time_close[1]
        line.set_x2(levelHigh100Line, previousSessionEndTime)
        line.set_x2(levelHigh33Line, previousSessionEndTime)
        line.set_x2(levelLow33Line, previousSessionEndTime)
        line.set_x2(levelLow100Line, previousSessionEndTime)
        if not na(levelHigh66Line)
            line.set_x2(levelHigh66Line, previousSessionEndTime)
        if not na(levelHigh50Line)
            line.set_x2(levelHigh50Line, previousSessionEndTime)
        if not na(levelLow50Line)
            line.set_x2(levelLow50Line, previousSessionEndTime)
        if not na(levelLow66Line)
            line.set_x2(levelLow66Line, previousSessionEndTime)

    // Somente a sessão ativa recebe textos. Os rótulos anteriores são removidos
    // para evitar poluição visual e respeitar o limite de objetos do TradingView.
    while array.size(activeLevelLabels) > 0
        label.delete(array.pop(activeLevelLabels))

    levelHigh100Line := line.new(capturedAnchorTime, outerHigh, activeLineRightTime, outerHigh, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
    levelHigh33Line  := line.new(capturedAnchorTime, adr33High, activeLineRightTime, adr33High, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
    levelLow33Line   := line.new(capturedAnchorTime, adr33Low, activeLineRightTime, adr33Low, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
    levelLow100Line  := line.new(capturedAnchorTime, outerLow, activeLineRightTime, outerLow, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
    array.push(storedLevelLines, levelHigh100Line)
    array.push(storedLevelLines, levelHigh33Line)
    array.push(storedLevelLines, levelLow33Line)
    array.push(storedLevelLines, levelLow100Line)

    if showSecondary
        levelHigh66Line := line.new(capturedAnchorTime, adr66High, activeLineRightTime, adr66High, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
        levelHigh50Line := line.new(capturedAnchorTime, adr50High, activeLineRightTime, adr50High, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
        levelLow50Line  := line.new(capturedAnchorTime, adr50Low, activeLineRightTime, adr50Low, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
        levelLow66Line  := line.new(capturedAnchorTime, adr66Low, activeLineRightTime, adr66Low, xloc=xloc.bar_time, color=levelLineColor, style=line.style_solid, width=1)
        array.push(storedLevelLines, levelHigh66Line)
        array.push(storedLevelLines, levelHigh50Line)
        array.push(storedLevelLines, levelLow50Line)
        array.push(storedLevelLines, levelLow66Line)
    else
        levelHigh66Line := na
        levelHigh50Line := na
        levelLow50Line := na
        levelLow66Line := na

    int linesPerSession = showSecondary ? 8 : 4
    int reservedOpenLineObjects = (showTDOpen ? openDays : 0) + (showMDOpen ? openDays : 0)
    int availableAdrLineObjects = 480 - reservedOpenLineObjects - reservedFullZoneSecondaryLines
    int lineSessionsToKeep = showAllHistory ? int(math.floor(availableAdrLineObjects / linesPerSession)) : sessionsToKeep
    while array.size(storedLevelLines) > lineSessionsToKeep * linesPerSession
        line.delete(array.shift(storedLevelLines))

    array.push(activeLevelLabels, label.new(activeLabelTime, outerHigh, "ADR +100%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
    array.push(activeLevelLabels, label.new(activeLabelTime, adr33High, "ADR +33%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
    array.push(activeLevelLabels, label.new(activeLabelTime, adr33Low, "ADR -33%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
    array.push(activeLevelLabels, label.new(activeLabelTime, outerLow, "ADR -100%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
    if showSecondary
        array.push(activeLevelLabels, label.new(activeLabelTime, adr66High, "ADR +66%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
        array.push(activeLevelLabels, label.new(activeLabelTime, adr50High, "ADR +50%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
        array.push(activeLevelLabels, label.new(activeLabelTime, adr50Low, "ADR -50%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))
        array.push(activeLevelLabels, label.new(activeLabelTime, adr66Low, "ADR -66%", xloc=xloc.bar_time, style=label.style_label_left, color=color.new(levelLineColor, 100), textcolor=levelLineColor, textalign=text.align_left, size=size.small))

if showLineLayer and anchorIsValid and not na(levelHigh100Line)
    line.set_x2(levelHigh100Line, activeLineRightTime)
    line.set_x2(levelHigh33Line, activeLineRightTime)
    line.set_x2(levelLow33Line, activeLineRightTime)
    line.set_x2(levelLow100Line, activeLineRightTime)
    if not na(levelHigh66Line)
        line.set_x2(levelHigh66Line, activeLineRightTime)
    if not na(levelHigh50Line)
        line.set_x2(levelHigh50Line, activeLineRightTime)
    if not na(levelLow50Line)
        line.set_x2(levelLow50Line, activeLineRightTime)
    if not na(levelLow66Line)
        line.set_x2(levelLow66Line, activeLineRightTime)
    for levelLabel in activeLevelLabels
        label.set_x(levelLabel, activeLabelTime)
// ==========================================
// 8. TD OPEN / MD OPEN
// ==========================================
// TD Open = 18:00 New York. MD Open = 00:00 New York.
// Em M1, usa diretamente o candle do gráfico. De M2 até H4, usa os mesmos
// intrabars de 1 minuto já carregados pelo ADR para capturar o preço exato.
// As linhas usam timestamps reais e são totalmente independentes da âncora ADR.
bool openTFAllowed = supportedTimeframe and timeframe.in_seconds() <= 4 * 60 * 60
int nyHour = hour(time, NY_TZ)
int nyMinute = minute(time, NY_TZ)

var array<line> tdOpenLines = array.new_line()
var array<line> mdOpenLines = array.new_line()
var array<label> tdOpenLabels = array.new_label()
var array<label> mdOpenLabels = array.new_label()
var int lastTDOpenTime = na
var int lastMDOpenTime = na

bool tdFound = false
bool mdFound = false
float tdOpenPrice = na
float mdOpenPrice = na
int tdOpenTime = na
int mdOpenTime = na
int tdLineStartTime = na
int mdLineStartTime = na

// M1: leitura direta do candle do gráfico.
if openTFAllowed and timeframe.in_seconds() == 60
    if nyHour == 18 and nyMinute == 0
        tdFound := true
        tdOpenPrice := open
        tdOpenTime := time
        tdLineStartTime := time
    if nyHour == 0 and nyMinute == 0
        mdFound := true
        mdOpenPrice := open
        mdOpenTime := time
        mdLineStartTime := time

// Acima de M1 até H4: localiza o candle interno de 1 minuto das 18:00/00:00 ET.
if openTFAllowed and timeframe.in_seconds() > 60 and intrabarCount > 0
    for openIntrabarIndex = 0 to intrabarCount - 1
        int openIntrabarTime = array.get(intrabarTimes, openIntrabarIndex)
        if hour(openIntrabarTime, NY_TZ) == 18 and minute(openIntrabarTime, NY_TZ) == 0
            tdFound := true
            tdOpenPrice := array.get(intrabarOpens, openIntrabarIndex)
            tdOpenTime := openIntrabarTime
            tdLineStartTime := openIntrabarTime
        if hour(openIntrabarTime, NY_TZ) == 0 and minute(openIntrabarTime, NY_TZ) == 0
            mdFound := true
            mdOpenPrice := array.get(intrabarOpens, openIntrabarIndex)
            mdOpenTime := openIntrabarTime
            mdLineStartTime := openIntrabarTime

if showTDOpen and tdFound and not na(tdOpenPrice) and not na(tdOpenTime) and not na(tdLineStartTime) and (na(lastTDOpenTime) or tdOpenTime != lastTDOpenTime)
    line tdLn = line.new(tdLineStartTime, tdOpenPrice, tdLineStartTime + openRightBars * chartBarDurationMs, tdOpenPrice, xloc=xloc.bar_time, color=tdOpenColor, width=openLineWidth, style=line.style_solid)
    array.push(tdOpenLines, tdLn)
    if showOpenText
        label tdLb = label.new(tdLineStartTime + (openRightBars + openTextOffset) * chartBarDurationMs, tdOpenPrice, "TD Open", xloc=xloc.bar_time, style=label.style_label_left, textcolor=tdOpenColor, color=color.new(color.white, 100), size=size.small, textalign=text.align_left)
        array.push(tdOpenLabels, tdLb)
    lastTDOpenTime := tdOpenTime
    if array.size(tdOpenLines) > openDays
        line.delete(array.shift(tdOpenLines))
    if array.size(tdOpenLabels) > openDays
        label.delete(array.shift(tdOpenLabels))

if showMDOpen and mdFound and not na(mdOpenPrice) and not na(mdOpenTime) and not na(mdLineStartTime) and (na(lastMDOpenTime) or mdOpenTime != lastMDOpenTime)
    line mdLn = line.new(mdLineStartTime, mdOpenPrice, mdLineStartTime + openRightBars * chartBarDurationMs, mdOpenPrice, xloc=xloc.bar_time, color=mdOpenColor, width=openLineWidth, style=line.style_solid)
    array.push(mdOpenLines, mdLn)
    if showOpenText
        label mdLb = label.new(mdLineStartTime + (openRightBars + openTextOffset) * chartBarDurationMs, mdOpenPrice, "MD Open", xloc=xloc.bar_time, style=label.style_label_left, textcolor=mdOpenColor, color=color.new(color.white, 100), size=size.small, textalign=text.align_left)
        array.push(mdOpenLabels, mdLb)
    lastMDOpenTime := mdOpenTime
    if array.size(mdOpenLines) > openDays
        line.delete(array.shift(mdOpenLines))
    if array.size(mdOpenLabels) > openDays
        label.delete(array.shift(mdOpenLabels))

if barstate.islast and openTFAllowed
    int openEndTime = time + openRightBars * chartBarDurationMs
    int openLabelTime = time + (openRightBars + openTextOffset) * chartBarDurationMs
    for tdLn in tdOpenLines
        line.set_x2(tdLn, openEndTime)
        line.set_color(tdLn, tdOpenColor)
        line.set_width(tdLn, openLineWidth)
    for mdLn in mdOpenLines
        line.set_x2(mdLn, openEndTime)
        line.set_color(mdLn, mdOpenColor)
        line.set_width(mdLn, openLineWidth)
    for tdLb in tdOpenLabels
        label.set_x(tdLb, openLabelTime)
        label.set_text(tdLb, showOpenText ? "TD Open" : "")
        label.set_textcolor(tdLb, tdOpenColor)
        label.set_style(tdLb, label.style_label_left)
        label.set_textalign(tdLb, text.align_left)
    for mdLb in mdOpenLabels
        label.set_x(mdLb, openLabelTime)
        label.set_text(mdLb, showOpenText ? "MD Open" : "")
        label.set_textcolor(mdLb, mdOpenColor)
        label.set_style(mdLb, label.style_label_left)
        label.set_textalign(mdLb, text.align_left)

// ==========================================
// 9. ALERTAS — NÃO ALTERAM CÁLCULOS OU DESENHOS
// ==========================================
// Cada evento dispara no máximo uma vez por sessão. Os níveis projetados são
// verificados contra o preço vivo (`close`), sem aguardar o fechamento do candle.
// O bloco só arma os estados no mercado em tempo real, evitando que um toque
// histórico anterior à criação do alerta seja marcado como já utilizado.
// Eventos simultâneos são reunidos em uma única chamada de `alert()`.
// `varip` preserves the alert state across realtime intrabar updates.
// Without it, Pine rollback can restore the flags on every tick and generate
// repeated notifications until TradingView stops the alert for excess triggers.
varip bool alertedUpper33 = false
varip bool alertedLower33 = false
varip bool alertedUpper50 = false
varip bool alertedLower50 = false
varip bool alertedUpper66 = false
varip bool alertedLower66 = false
varip bool alertedUpper100 = false
varip bool alertedLower100 = false
varip bool alertedAdrUsed80 = false
varip bool alertedAdrUsed100 = false
// Prevents retrospective notifications when a TradingView alert is first
// created while price or ADR Used is already beyond a selected threshold.
varip bool alertEngineInitialized = false
// Reset once — and only once — when the captured anchor session changes.
// `newValidSession` can remain true during every tick of the anchor chart bar,
// so it must not be used directly to reset `varip` alert flags.
varip int alertSessionTime = na
bool newAlertSession = anchorIsValid and (na(alertSessionTime) or capturedAnchorTime != alertSessionTime)
if newAlertSession
    alertSessionTime := capturedAnchorTime
    alertedUpper33 := false
    alertedLower33 := false
    alertedUpper50 := false
    alertedLower50 := false
    alertedUpper66 := false
    alertedLower66 := false
    alertedUpper100 := false
    alertedLower100 := false
    alertedAdrUsed80 := false
    alertedAdrUsed100 := false
string alertPrefix = "ADR Pro | " + syminfo.ticker + " | " + openType + " | " + projectionMode + " | "

// Inclui o preço vivo no range usado apenas pelos alertas percentuais. Isso
// elimina o atraso de até um intrabar de 1 minuto em gráficos maiores.
alertRangeHigh = anchorIsValid and rangeActive ? math.max(rangeHigh, close) : na
alertRangeLow = anchorIsValid and rangeActive ? math.min(rangeLow, close) : na
alertSessionRange = not na(alertRangeHigh) and not na(alertRangeLow) ? alertRangeHigh - alertRangeLow : na
alertAdrUsedPct = not na(alertSessionRange) and not na(sessionAdr) and sessionAdr > 0 ? alertSessionRange / sessionAdr * 100 : na

// On the first realtime evaluation, synchronize the flags with conditions that
// are already true. No notification is sent during this initialization pass.
bool initializeAlertEngine = enableAlerts and anchorIsValid and rangeActive and barstate.isrealtime and not alertEngineInitialized
if initializeAlertEngine
    alertSessionTime := capturedAnchorTime
    alertedUpper33 := close >= adr33High
    alertedLower33 := close <= adr33Low
    alertedUpper50 := close >= adr50High
    alertedLower50 := close <= adr50Low
    alertedUpper66 := close >= adr66High
    alertedLower66 := close <= adr66Low
    alertedUpper100 := close >= adr100High
    alertedLower100 := close <= adr100Low
    alertedAdrUsed80 := alertAdrUsedPct >= 80
    alertedAdrUsed100 := alertAdrUsedPct >= 100
    alertEngineInitialized := true
else if enableAlerts and anchorIsValid and rangeActive and barstate.isrealtime
    string alertEvents = ""

    if alertAt33 and not alertedUpper33 and close >= adr33High
        alertEvents := alertEvents == "" ? "Upper 33% projection reached." : alertEvents + " | Upper 33% projection reached."
        alertedUpper33 := true
    if alertAt33 and not alertedLower33 and close <= adr33Low
        alertEvents := alertEvents == "" ? "Lower 33% projection reached." : alertEvents + " | Lower 33% projection reached."
        alertedLower33 := true
    if alertAt50 and not alertedUpper50 and close >= adr50High
        alertEvents := alertEvents == "" ? "Upper 50% projection reached." : alertEvents + " | Upper 50% projection reached."
        alertedUpper50 := true
    if alertAt50 and not alertedLower50 and close <= adr50Low
        alertEvents := alertEvents == "" ? "Lower 50% projection reached." : alertEvents + " | Lower 50% projection reached."
        alertedLower50 := true
    if alertAt66 and not alertedUpper66 and close >= adr66High
        alertEvents := alertEvents == "" ? "Upper 66% projection reached." : alertEvents + " | Upper 66% projection reached."
        alertedUpper66 := true
    if alertAt66 and not alertedLower66 and close <= adr66Low
        alertEvents := alertEvents == "" ? "Lower 66% projection reached." : alertEvents + " | Lower 66% projection reached."
        alertedLower66 := true
    if alertAt100 and not alertedUpper100 and close >= adr100High
        alertEvents := alertEvents == "" ? "Upper 100% projection reached." : alertEvents + " | Upper 100% projection reached."
        alertedUpper100 := true
    if alertAt100 and not alertedLower100 and close <= adr100Low
        alertEvents := alertEvents == "" ? "Lower 100% projection reached." : alertEvents + " | Lower 100% projection reached."
        alertedLower100 := true
    if alertAdrUsed80 and not alertedAdrUsed80 and alertAdrUsedPct >= 80
        alertEvents := alertEvents == "" ? "ADR Used reached 80%." : alertEvents + " | ADR Used reached 80%."
        alertedAdrUsed80 := true
    if alertAdrUsed100 and not alertedAdrUsed100 and alertAdrUsedPct >= 100
        alertEvents := alertEvents == "" ? "ADR Used reached 100%." : alertEvents + " | ADR Used reached 100%."
        alertedAdrUsed100 := true

    if alertEvents != ""
        alert(alertPrefix + alertEvents, alert.freq_all)
// ==========================================
// 10. PAINEL DE STATUS DO ADR — SOMENTE INFORMATIVO
// ==========================================
// O painel é atualizado em tempo real, mas não interfere no ADR, nas âncoras
// ou nas zonas desenhadas no gráfico.
var table adrStatusTable = table.new(
    adrStatusTablePosition,
    2,
    5,
    bgcolor=chart.bg_color,
    frame_color=chart.fg_color,
    frame_width=1,
    border_width=0
)
if barstate.isfirst
    table.merge_cells(adrStatusTable, 0, 0, 1, 0)
if barstate.islast
    if showAdrStatus and supportedTimeframe
        table.cell(adrStatusTable, 0, 0, "ADR STATUS - " + (splitMode ? "SPLIT" : "FULL") + " - " + anchorStatusLabel, text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_left)
        table.cell(adrStatusTable, 0, 1, "ADR (" + str.tostring(length) + "D)", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_left)
        table.cell(adrStatusTable, 1, 1, str.tostring(sessionAdr, format.mintick) + " pts", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_right)
        table.cell(adrStatusTable, 0, 2, "Range Since Anchor", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_left)
        table.cell(adrStatusTable, 1, 2, str.tostring(anchorSessionRange, format.mintick) + " pts", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_right)
        table.cell(adrStatusTable, 0, 3, "ADR Used", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_left)
        table.cell(adrStatusTable, 1, 3, str.tostring(adrUsedPct, "#.0") + "%", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_right)
        table.cell(adrStatusTable, 0, 4, "To Average", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_left)
        table.cell(adrStatusTable, 1, 4, str.tostring(toAverage, format.mintick) + " pts", text_color=chart.fg_color, text_size=adrStatusTableTextSize, text_halign=text.align_right)
    else
        table.clear(adrStatusTable, 0, 0, 1, 4)
````
