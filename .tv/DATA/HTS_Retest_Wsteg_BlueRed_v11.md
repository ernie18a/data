<!-- tradingview-pine-id: PUB;6d14ac5aa8d64094a8e205567dd14be8 -->
<!-- tradingviewscripts-format: 1 -->
# HTS Retest Wstęg (Blue/Red) v11

Source: https://www.tradingview.com/script/ZJDOBejl-HTS-Retest-Wsteg-Blue-Red-v11/

## Description

HTS Retest dla BrothersTrade. Dziala na pierwsze odbicia, wykrywa duze momentum itd

---

## Source Code

````pine
// This Pine Script code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// Bazuje na wstęgach z "HTS - Wstęgi PRO 4 Alerty" (© xwaytheory)
// v11: naprawiono prawdziwą przyczynę powtarzających się znaczników ⚡. v10 porównywało
// ATR do jego poziomu sprzed alarmu, ale extensionAtr = wielkość_ruchu / ATR - gdy ATR
// samo z siebie się kurczy (co często dzieje się PO gwałtownym ruchu), ten sam,
// niezmieniony ruch cenowy staje się coraz WIĘKSZĄ wielokrotnością malejącego ATR.
// To powodowało błędne koło: spadek ATR jednocześnie spełniał warunek "uspokojenia"
// I podbijał extensionAtr ponad próg - więc znacznik strzelał wielokrotnie z rzędu
// (np. 30x, 43x, 62x ATR na kolejnych świecach), mimo że nic nowego się nie działo.
// Nowe podejście: NIE używamy już ATR do odblokowania. Znacznik może wystrzelić
// TYLKO RAZ na dany cross (do następnego prawdziwego rozejścia wstęg) + dodatkowy,
// prosty minimalny odstęp w świecach (bez sprzężenia z ATR) między kolejnymi alarmami
// z RÓŻNYCH crossów.

//@version=6
indicator(title = "HTS Retest Wstęg (Blue/Red) v11", overlay = true, max_labels_count = 500)

// ============================================================
// 0. MENU - włącz/wyłącz
// ============================================================
grpMenu = "0. MENU - włącz/wyłącz"
showBands = input.bool(true, "Pokaż wstęgi BLUE/RED", group = grpMenu)
showCrossMarks = input.bool(true, "Pokaż znaczniki rozejścia (cross)", group = grpMenu)
showRetestBlue = input.bool(true, "Pokaż retest BLUE (pierwszy powrót)", group = grpMenu)
showRetestRed = input.bool(true, "Pokaż retest RED (pierwszy powrót)", group = grpMenu)
useSteepFilter = input.bool(true, "Oznacz retest BLUE jako ryzykowny przy stromej wstędze", group = grpMenu)
useExtensionFilter = input.bool(true, "Filtr: wymagaj minimalnej WIELKOŚCI impulsu", group = grpMenu)
useVelocityFilter = input.bool(true, "Filtr: wymagaj minimalnej SZYBKOŚCI impulsu", group = grpMenu)
useBandSepFilter = input.bool(true, "Filtr: wymagaj minimalnego ROZSTĘPU wstęg przy retescie", group = grpMenu)
showVolatilitySpike = input.bool(true, "Pokaż znacznik ekstremalnej zmienności (⚡)", group = grpMenu)

// ============================================================
// 1. Wstęgi (ustawienia)
// ============================================================
grpBands = "1. Wstęgi (ustawienia)"
maMethod = input.string('EMA', "Metoda MA", options = ['RMA', 'EMA', 'SMA', 'WMA', 'VWMA'], group = grpBands)
lenFast = input.int(66, "Długość BLUE (szybka)", group = grpBands)
lenSlow = input.int(288, "Długość RED (wolna)", group = grpBands)
blueColor = input.color(#00bcd4, "Kolor BLUE", group = grpBands)
redColor = input.color(#f23645, "Kolor RED", group = grpBands)
bandLineWidth = input.int(1, "Grubość linii wstęg", group = grpBands, minval = 1, maxval = 10)
fillTransparency = input.int(90, "Przezroczystość wypełnienia (0=pełne, 100=niewidoczne)", group = grpBands, minval = 0, maxval = 100)

// ============================================================
// 2. Rozejście wstęg / Cross (ustawienia)
// ============================================================
grpCross = "2. Rozejście wstęg / Cross (ustawienia)"
crossUpColor = input.color(color.lime, "Kolor cross w górę (BLUE > RED)", group = grpCross)
crossDownColor = input.color(color.red, "Kolor cross w dół (RED > BLUE)", group = grpCross)

// ============================================================
// 3. Retest BLUE/RED - pierwszy powrót po crossie (ustawienia)
// ============================================================
grpRetest = "3. Retest BLUE/RED (ustawienia)"
retestBlueColor = input.color(#00bcd4, "Kolor retest BLUE", group = grpRetest)
retestBlueRiskyColor = input.color(color.orange, "Kolor retest BLUE (ryzykowny, stroma wstęga)", group = grpRetest)
retestRedColor = input.color(#f23645, "Kolor retest RED", group = grpRetest)

// ============================================================
// 4. Filtr stromizny wstęgi BLUE (ustawienia)
// ============================================================
grpSteep = "4. Filtr stromizny wstęgi BLUE (ustawienia)"
steepLookback = input.int(10, "Lookback nachylenia (świece)", group = grpSteep, minval = 2)
steepThreshold = input.float(0.6, "Próg stromizny (x ATR na świecę)", group = grpSteep, minval = 0.05, step = 0.05)
atrLenSteep = input.int(14, "ATR długość (wspólna dla wszystkich filtrów)", group = grpSteep)

// ============================================================
// 5. Filtr dynamiki: wielkość i szybkość impulsu (ustawienia)
// ============================================================
grpDyn = "5. Filtr dynamiki impulsu (ustawienia)"
minExtensionAtr = input.float(2.0, "Min. wielkość impulsu (x ATR)", group = grpDyn, minval = 0.1, step = 0.1)
minVelocityAtr = input.float(0.10, "Min. szybkość impulsu (x ATR / świecę)", group = grpDyn, minval = 0.01, step = 0.01)

// ============================================================
// 6. Filtr minimalnego rozstępu wstęg (ustawienia)
// ============================================================
grpSep = "6. Filtr minimalnego rozstępu wstęg (ustawienia)"
minBandSepAtr = input.float(0.3, "Min. rozstęp wstęg przy retescie (x ATR)", group = grpSep, minval = 0.0, step = 0.05)

// ============================================================
// 7. Znacznik ekstremalnej zmienności (ustawienia)
// Niezależny od retestu. Wystrzeliwuje NAJWYŻEJ RAZ na dany cross, gdy extensionAtr
// (odległość cross->ekstremum w ATR) przekroczy próg volatilitySpikeAtr. Kolejny
// znacznik może pojawić się dopiero przy NOWYM crossie (prawdziwym rozejściu wstęg
// po wcześniejszym styku) - to naturalnie ogranicza liczbę alarmów w trakcie jednego,
// ciągłego ruchu, niezależnie od tego jak długo trwa. Dodatkowo minCooldownBars
// wymusza minimalny odstęp w świecach między alarmami z RÓŻNYCH crossów, żeby seria
// szybkich, kolejnych po sobie crossów też nie zasypywała wykresu znacznikami.
// ============================================================
grpVol = "7. Znacznik ekstremalnej zmienności (ustawienia)"
volatilitySpikeAtr = input.float(5.0, "Próg ekstremalnego wybicia (x ATR)", group = grpVol, minval = 0.5, step = 0.5)
volatilitySpikeColor = input.color(color.purple, "Kolor znacznika zmienności", group = grpVol)
minCooldownBars = input.int(30, "Minimalny odstęp między znacznikami z różnych crossów (świece)", group = grpVol, minval = 1)

// ============ OBLICZENIA WSTĘG ============
maCalc(src, len, method) =>
    switch method
        'RMA' => ta.rma(src, len)
        'EMA' => ta.ema(src, len)
        'SMA' => ta.sma(src, len)
        'WMA' => ta.wma(src, len)
        'VWMA' => ta.vwma(src, len)

B_H = maCalc(high, lenFast, maMethod)
B_L = maCalc(low, lenFast, maMethod)
R_H = maCalc(high, lenSlow, maMethod)
R_L = maCalc(low, lenSlow, maMethod)

p_bh = plot(showBands ? B_H : na, "BLUE High", color = color.new(blueColor, 30), linewidth = bandLineWidth)
p_bl = plot(showBands ? B_L : na, "BLUE Low", color = color.new(blueColor, 30), linewidth = bandLineWidth)
fill(p_bh, p_bl, color = showBands ? color.new(blueColor, fillTransparency) : na, title = "BLUE Fill")

p_rh = plot(showBands ? R_H : na, "RED High", color = color.new(redColor, 30), linewidth = bandLineWidth)
p_rl = plot(showBands ? R_L : na, "RED Low", color = color.new(redColor, 30), linewidth = bandLineWidth)
fill(p_rh, p_rl, color = showBands ? color.new(redColor, fillTransparency) : na, title = "RED Fill")

// ============ CROSS: WSTĘGI ROZCHODZĄ SIĘ PO WCZEŚNIEJSZYM STYKU ============
bands_touch = B_L <= R_H and R_L <= B_H
bands_separation = not bands_touch and bands_touch[1]
blue_above_red = B_L > R_H
red_above_blue = R_L > B_H
crossUp = bands_separation and blue_above_red
crossDown = bands_separation and red_above_blue

if showCrossMarks and crossUp
    label.new(bar_index, low, "▲", style = label.style_label_up, color = color.new(crossUpColor, 0), textcolor = color.white, size = size.small)
if showCrossMarks and crossDown
    label.new(bar_index, high, "▼", style = label.style_label_down, color = color.new(crossDownColor, 0), textcolor = color.white, size = size.small)

// ============ ATR (wspólne dla wszystkich filtrów) ============
atrSteep = ta.atr(atrLenSteep)

// ============ STROMIZNA WSTĘGI BLUE (tempo zmiany względem ATR) ============
blueSlopePerBar = math.abs(B_H - B_H[steepLookback]) / steepLookback
isSteep = atrSteep > 0 and (blueSlopePerBar / atrSteep) > steepThreshold

// ============ RETEST: PIERWSZY POWRÓT DO BLUE / RED PO CROSSIE ============
var bool waitBlue = false
var bool waitRed = false
var int crossDir = 0
var float extremeSinceCross = na
var float crossAnchor = na
var int crossBarIdx = na
var int extremeBarIdx = na
var bool spikeFiredThisCross = false
var int lastSpikeBarIdx = na

if crossUp or crossDown
    waitBlue := true
    waitRed := true
    crossDir := crossUp ? 1 : -1
    extremeSinceCross := crossUp ? high : low
    crossAnchor := close
    crossBarIdx := bar_index
    extremeBarIdx := bar_index
    spikeFiredThisCross := false
else if bands_touch
    // wstęgi ponownie się zetknęły zanim doszło do retestu - układ nieważny
    waitBlue := false
    waitRed := false
else if crossDir == 1 and high > extremeSinceCross
    extremeSinceCross := high
    extremeBarIdx := bar_index
else if crossDir == -1 and low < extremeSinceCross
    extremeSinceCross := low
    extremeBarIdx := bar_index

extensionNow = crossDir == 1 ? extremeSinceCross - crossAnchor : crossDir == -1 ? crossAnchor - extremeSinceCross : 0.0
barsToExtreme = na(extremeBarIdx) or na(crossBarIdx) ? 0 : math.max(extremeBarIdx - crossBarIdx, 1)
velocityNow = extensionNow / barsToExtreme

extensionAtr = atrSteep > 0 ? extensionNow / atrSteep : 0.0
velocityAtr = atrSteep > 0 ? velocityNow / atrSteep : 0.0

// ============ ROZSTĘP WSTĘG TERAZ (od bliskich krawędzi, w kierunku crossu) ============
bandGapNow = crossDir == 1 ? (B_L - R_H) : crossDir == -1 ? (R_L - B_H) : 0.0
bandGapAtr = atrSteep > 0 ? bandGapNow / atrSteep : 0.0

bigEnough = extensionAtr >= minExtensionAtr
fastEnough = velocityAtr >= minVelocityAtr
sepEnough = bandGapAtr >= minBandSepAtr

dynamicOk = (not useExtensionFilter or bigEnough) and (not useVelocityFilter or fastEnough) and (not useBandSepFilter or sepEnough)

touch_b = high >= B_L and low <= B_H
touch_r = high >= R_L and low <= R_H

retestBlue = showRetestBlue and waitBlue and touch_b and dynamicOk
retestRed = showRetestRed and waitRed and touch_r and dynamicOk

if retestBlue
    riskyNow = useSteepFilter and isSteep
    lblColor = riskyNow ? retestBlueRiskyColor : retestBlueColor
    lblText = riskyNow ? "Blue ⚠" : "Blue"
    if crossDir == 1
        label.new(bar_index, low, lblText, style = label.style_label_up, color = color.new(lblColor, 0), textcolor = color.white, size = size.small)
    else if crossDir == -1
        label.new(bar_index, high, lblText, style = label.style_label_down, color = color.new(lblColor, 0), textcolor = color.white, size = size.small)
    waitBlue := false

if retestRed
    if crossDir == 1
        label.new(bar_index, low, "Red", style = label.style_label_up, color = color.new(retestRedColor, 0), textcolor = color.white, size = size.small)
    else if crossDir == -1
        label.new(bar_index, high, "Red", style = label.style_label_down, color = color.new(retestRedColor, 0), textcolor = color.white, size = size.small)
    waitRed := false

// ============ ZNACZNIK EKSTREMALNEJ ZMIENNOŚCI (max raz na cross + minimalny odstęp) ============
volatilitySpike = showVolatilitySpike and not spikeFiredThisCross and crossDir != 0 and extensionAtr >= volatilitySpikeAtr and (na(lastSpikeBarIdx) or (bar_index - lastSpikeBarIdx) >= minCooldownBars)
if volatilitySpike
    spikeTxt = "⚡ " + str.tostring(extensionAtr, "#.#") + "x ATR"
    if crossDir == 1
        label.new(bar_index, high, spikeTxt, style = label.style_label_down, color = color.new(volatilitySpikeColor, 0), textcolor = color.white, size = size.small)
    else if crossDir == -1
        label.new(bar_index, low, spikeTxt, style = label.style_label_up, color = color.new(volatilitySpikeColor, 0), textcolor = color.white, size = size.small)
    spikeFiredThisCross := true
    lastSpikeBarIdx := bar_index

alertcondition(crossUp, title = "Cross w górę (BLUE > RED)", message = "HTS Cross UP: {{ticker}}")
alertcondition(crossDown, title = "Cross w dół (RED > BLUE)", message = "HTS Cross DOWN: {{ticker}}")
alertcondition(retestBlue, title = "Retest BLUE", message = "HTS Retest BLUE: {{ticker}}")
alertcondition(retestRed, title = "Retest RED", message = "HTS Retest RED: {{ticker}}")
alertcondition(volatilitySpike, title = "Ekstremalna zmienność", message = "HTS Volatility Spike: {{ticker}}")
````
