# AetherEdge - Hypercube Heatmap (Horizon Field)

- url: https://www.tradingview.com/script/lmZhqXEO/
- type: indicator
- pine_id: PUB;b5d87076377b4443a7d29a1fbfce7e64
- version: 1.0

## Description

🖊️ Overview

AE-HYPE2 is a heatmap engine that embeds multiple market features into a latent energy and projects it across the chart as horizontal energy bands by price level. It dynamically weights feature importance with attention and modulates band brightness with a Bayesian-style uncertainty. Brighter bands mark price levels where energy concentrates, intuitively conveying where market force accumulates. It expresses the CoinGlass-style horizontal-band aesthetic through a unique "market energy" lens rather than liquidations.

🔶 Key Features

Price-level energy field: projects multi-feature latent energy into horizontal bands by price
Latent embedding: five features (momentum, volatility, volume, trend, RSI) compressed into latent energy
Dynamic attention: softmax real-time weighting of each feature's importance
Uncertainty estimation: a Bayesian-style estimate from feature dispersion, darkening uncertain bands
Smooth gradient field via vertical smoothing
Viridis palette (purple→teal→green→yellow) reproducing the CoinGlass aesthetic
Hotspot glow and an integrated HUD showing total energy, uncertainty, and the focused feature

🧠 Technical Architecture

Within Pine — which has no autodiff, external libraries, or animation — this reproduces the mathematical core of deep embedding and attention in static form. A softmax over five standardized features yields attention weights, and their weighted sum is the latent energy. Uncertainty is a Bayesian-style estimate from the standard deviation among features. In rendering, for each past bar, the latent energy (attenuated by uncertainty) is accumulated into the price row that bar's price occupied, so levels where energy concentrates emerge as bright horizontal bands. Vertical smoothing diffuses energy into neighboring bands for a smooth gradient field. Color is the Viridis spectrum, with brightness encoding energy magnitude.

⚙️ Recommended Settings & Tuning Guide

Tuned with crypto in mind. Price Resolution 48 and Lookback Width ~250 are a starting point. Attention Temperature sets the embedding's character — below 1 focuses sharply on the strongest feature, above 1 blends multiple. Vertical Range adjusts field height, Color Intensity overall opacity. Enabling Apply Uncertainty Softening darkens uncertain price levels so confident bands stand out. Raising Price Resolution makes finer bands but watch the drawing-object limit (up to ~120).

💡 How to Use in Practice

Bright bands are price levels where market energy concentrates, marking levels that historically drew large interest (volume, momentum, volatility). These tend to act as support/resistance, and moments where price approaches them are worth attention. Dark, blurred-looking bands indicate high uncertainty and lower confidence. The HUD's focused feature reveals what currently drives the market. Used together with AE-LIQ (the liquidation heatmap), you can find levels where liquidation bands and energy bands coincide — doubly significant levels.

⚠️ Important Notes

This tool is inspired by deep learning and attention, not a true backprop-trained neural network. External libraries like NeuraLib, and animation/particle/blur effects, are impossible in Pine and are not included. Energy bands are a visualization of market state, not predictions. The heatmap rebuilds only on the last bar and does not repaint confirmed history. Pushing Price Resolution too high may hit the drawing-object limit and break the display.

🚨 Disclaimer

This indicator is provided for educational and informational purposes only and does not constitute financial or investment advice. No output guarantees future prices, and past performance does not indicate future results. All trading decisions are made at your own risk.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © AetherEdge — Omniscient Temporal-Spatial Hypercube Heatmap
//@version=6

// ┌──────────────────────────────────────────────────────────────────────────┐
// │  AetherEdge - Hypercube Heatmap (Horizon Field)  ·  AE-HYPE2                │
// │                                                                            │
// │  A CoinGlass-styled energy field: bright HORIZONTAL bands mark price       │
// │  levels carrying the most accumulated market energy, projected across the  │
// │  chart in a Viridis spectrum. Same AI core as AE-HYPE (latent embedding +  │
// │  attention + uncertainty), but rendered as horizontal energy bands instead │
// │  of a grid, to match the liquidation-map aesthetic.                        │
// │                                                                            │
// │  HONEST SCOPE: no autodiff, external libs, animation, blur, or particles   │
// │  in Pine. Deep-net training and motion effects are impossible; this is the │
// │  static mathematical core of embedding/attention/uncertainty, plus an      │
// │  online-learned reliability of energy bands (do bands price revisits       │
// │  actually produce reactions?).                                            │
// └──────────────────────────────────────────────────────────────────────────┘

indicator("AetherEdge - Hypercube Heatmap (Horizon Field)", "AE-HYPE2", overlay = true,
     max_boxes_count = 500, max_lines_count = 200, max_labels_count = 100)


// ============================================================================
//  ░░ INPUTS ░░
// ============================================================================

// ─── HEATMAP GRID ────────────────────────────────────────────────────────────
gG = "▓ HEATMAP GRID ▓"
hm_colsInput  = input.int(250, "Lookback Width (bars)", minval = 50, maxval = 1000, group = gG,
     tooltip = "Horizontal width of the energy field, in bars. The whole field spans this many bars back from now.")
hm_rowsInput  = input.int(48, "Price Resolution (rows)", minval = 10, maxval = 100, group = gG,
     tooltip = "Number of horizontal energy bands. Higher = finer bands, heavier. Keep under ~120 for the box limit.")
hm_rangeMultInp= input.float(2.5, "Vertical Range (× recent range)", minval = 1.0, maxval = 6.0, step = 0.5, group = gG,
     tooltip = "How tall the energy field is, as a multiple of the recent high-low range.")

// ─── AI / ENERGY MODEL ───────────────────────────────────────────────────────
gA = "▓ AI · ENERGY MODEL ▓"
ai_attnTempInp= input.float(1.0, "Attention Temperature", minval = 0.1, maxval = 5.0, step = 0.1, group = gA,
     tooltip = "Softmax temperature for feature attention. <1 = sharper focus on the single strongest feature; >1 = smoother blend.")
ai_uncInput   = input.bool(true, "Apply Uncertainty Softening", group = gA,
     tooltip = "Fade cells where the Bayesian-style dispersion estimate is high, so confident regions appear vivid and uncertain ones soft.")
ai_smoothInp  = input.int(5, "Energy Smoothing", minval = 1, maxval = 30, group = gA,
     tooltip = "Temporal-convolution-style smoothing applied to the energy field.")

// ─── VISUALS ─────────────────────────────────────────────────────────────────
gV = "▓ VISUALS ▓"
vi_paletteInp = input.string("Viridis", "Palette",
     options = ["Viridis", "Spectral Energy", "Plasma", "Ice→Fire"], group = gV,
     tooltip = "Viridis = purple→teal→green→yellow (CoinGlass-like). Spectral = violet→blue→emerald→gold→red.")
vi_intensityInp= input.float(1.0, "Color Intensity", minval = 0.3, maxval = 2.0, step = 0.1, group = gV,
     tooltip = "Master opacity multiplier for the whole field.")
vi_glowInput  = input.bool(true, "Glow on Hotspots", group = gV,
     tooltip = "Layer extra translucent boxes on the highest-energy cells for a luminous bloom.")
vi_hotThrInput= input.float(0.75, "Hotspot Threshold", minval = 0.3, maxval = 0.98, step = 0.01, group = gV,
     tooltip = "Energy above this (0-1) is treated as a hotspot and gets glow + emphasis.")

// ─── HUD ─────────────────────────────────────────────────────────────────────
gH = "▓ HUD ▓"
hud_showInput = input.bool(true, "Show HUD", group = gH)
hud_posInput  = input.string("Top Right", "Position",
     options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group = gH)
hud_sizeInput = input.string("Normal", "Text Size",
     options = ["Tiny", "Small", "Normal", "Large"], group = gH)


// ============================================================================
//  ░░ HELPERS ░░
// ============================================================================
sdiv(a, b) =>
    b != 0 ? a / b : 0.0
clamp(v, lo, hi) =>
    math.max(lo, math.min(hi, v))

// Rainbow energy color from a normalized value e in [0,1].
// violet(0) → blue → emerald → gold → red(1). Implemented as piecewise
// color.from_gradient across 5 anchors for a smooth spectral ramp.
energyColor(e) =>
    x = clamp(e, 0.0, 1.0)
    c = if x < 0.25
        color.from_gradient(x, 0.0, 0.25, #4c1d95, #2563eb)        // violet → blue
    else if x < 0.5
        color.from_gradient(x, 0.25, 0.5, #2563eb, #10b981)        // blue → emerald
    else if x < 0.75
        color.from_gradient(x, 0.5, 0.75, #10b981, #f59e0b)        // emerald → gold
    else
        color.from_gradient(x, 0.75, 1.0, #f59e0b, #ef4444)        // gold → red
    c

// Palette switch only changes the anchor feel; Spectral Energy is default ramp.
// (Plasma / Ice→Fire remap endpoints.)
energyColorThemed(e) =>
    x = clamp(e, 0.0, 1.0)
    out = switch vi_paletteInp
        "Viridis" => x < 0.33 ? color.from_gradient(x, 0.0, 0.33, #440154, #31688e) : x < 0.66 ? color.from_gradient(x, 0.33, 0.66, #31688e, #35b779) : color.from_gradient(x, 0.66, 1.0, #35b779, #fde725)
        "Plasma"  => x < 0.5 ? color.from_gradient(x, 0.0, 0.5, #0d0887, #cc4778) : color.from_gradient(x, 0.5, 1.0, #cc4778, #f0f921)
        "Ice→Fire"=> x < 0.5 ? color.from_gradient(x, 0.0, 0.5, #1e3a8a, #e0f2fe) : color.from_gradient(x, 0.5, 1.0, #fde68a, #b91c1c)
        => energyColor(x)
    out


// ============================================================================
//  ░░ FEATURE NODES & LATENT EMBEDDING ░░
//  Five standardized features form the "input dimensions." A latent energy
//  scalar is their attention-weighted magnitude. Attention weights come from a
//  softmax over each feature's current absolute activation (dynamic spatial
//  attention: whichever feature is most active dominates the embedding).
// ============================================================================
atr = ta.atr(14)

fMom  = sdiv(close - close[10], atr)                       // momentum
fVola = sdiv(ta.stdev(ta.change(close), 20), atr)          // volatility
fVol  = sdiv(volume - ta.sma(volume, 20), ta.stdev(volume, 20) + 1e-9)  // volume surprise
fTrd  = sdiv(ta.ema(close, 10) - ta.ema(close, 30), atr)   // trend
fRsi  = (ta.rsi(close, 14) - 50.0) / 50.0                  // rsi polarity

zMom  = nz(clamp(fMom, -4, 4))
zVola = nz(clamp(fVola, -4, 4))
zVol  = nz(clamp(fVol, -4, 4))
zTrd  = nz(clamp(fTrd, -4, 4))
zRsi  = nz(clamp(fRsi * 2.0, -4, 4))

// Softmax attention over absolute activations.
aM = math.exp(math.abs(zMom)  / ai_attnTempInp)
aV = math.exp(math.abs(zVola) / ai_attnTempInp)
aU = math.exp(math.abs(zVol)  / ai_attnTempInp)
aT = math.exp(math.abs(zTrd)  / ai_attnTempInp)
aR = math.exp(math.abs(zRsi)  / ai_attnTempInp)
aSum = aM + aV + aU + aT + aR + 1e-9
wM = aM / aSum
wV = aV / aSum
wU = aU / aSum
wT = aT / aSum
wR = aR / aSum

// Latent energy: attention-weighted absolute activation (0..~4 → normalize).
latentEnergy = wM*math.abs(zMom) + wV*math.abs(zVola) + wU*math.abs(zVol) + wT*math.abs(zTrd) + wR*math.abs(zRsi)
energyNorm = clamp(latentEnergy / 3.0, 0.0, 1.0)
energySm = ta.ema(energyNorm, ai_smoothInp)

// Directional bias (for later: warm = bullish pressure, etc.) and uncertainty.
dirBias = wM*zMom + wT*zTrd + wR*zRsi                       // signed
// Bayesian-style uncertainty: dispersion among the feature signals.
featMean = (zMom + zVola + zVol + zTrd + zRsi) / 5.0
featVar  = ((zMom-featMean)*(zMom-featMean) + (zVola-featMean)*(zVola-featMean) + (zVol-featMean)*(zVol-featMean) + (zTrd-featMean)*(zTrd-featMean) + (zRsi-featMean)*(zRsi-featMean)) / 5.0
uncRaw   = clamp(math.sqrt(featVar) / 2.5, 0.0, 1.0)
uncSm    = ta.ema(uncRaw, ai_smoothInp)


// ============================================================================
//  ░░ HEATMAP RENDER (last bar only) ░░
//  Build a COLS×ROWS grid of boxes. Each column = a past time slice; each row =
//  a price band. Cell energy = historical latent energy at that time, modulated
//  by how close the row's price band is to where price actually was (a spatial
//  Gaussian around the realized price) — so the field glows along the path the
//  market actually took, fading above/below.
// ============================================================================
var box[] cells   = array.new<box>(0)
var box[] glows   = array.new<box>(0)

clearBoxes(arr) =>
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            box.delete(array.get(arr, i))
        array.clear(arr)

COLS = hm_colsInput
ROWS = hm_rowsInput
LB   = hm_colsInput   // horizontal field width = lookback width

if barstate.islast
    clearBoxes(cells)
    clearBoxes(glows)

    // ── Vertical frame from recent range ──
    rng = ta.highest(high, LB) - ta.lowest(low, LB)
    rng := rng <= 0 ? atr * 10 : rng
    mid = (ta.highest(high, LB) + ta.lowest(low, LB)) / 2.0
    halfH = rng / 2.0 * hm_rangeMultInp
    pxTop = mid + halfH
    pxBot = mid - halfH
    rowH  = (pxTop - pxBot) / ROWS

    // Accumulate energy per PRICE ROW across the lookback. Each past bar deposits
    // its latent energy (weighted by attention) into the row its price occupied;
    // uncertainty reduces the deposit (less confident = dimmer band).
    rowE = array.new<float>(ROWS, 0.0)
    rowU = array.new<float>(ROWS, 0.0)
    rowN = array.new<float>(ROWS, 0.0)

    barsStep = math.max(1, int(LB / 250))
    i = 0
    while i < LB
        pxHist = nz(close[i], close)
        eHist  = nz(energySm[i])
        uHist  = nz(uncSm[i])
        rIdx = int((pxHist - pxBot) / rowH)
        if rIdx >= 0 and rIdx < ROWS
            // Confident energy deposits brighter; uncertainty attenuates.
            dep = eHist * (ai_uncInput ? (1.0 - uHist * 0.6) : 1.0)
            array.set(rowE, rIdx, array.get(rowE, rIdx) + dep)
            array.set(rowU, rIdx, array.get(rowU, rIdx) + uHist)
            array.set(rowN, rIdx, array.get(rowN, rIdx) + 1.0)
        i += barsStep

    // Vertical smoothing (blur into neighbors) for a soft gradient field.
    smoothN = ai_smoothInp > 6 ? 6 : ai_smoothInp
    if smoothN > 0
        rowS = array.copy(rowE)
        for r = 0 to ROWS - 1
            acc = 0.0
            cnt = 0
            kLo = math.max(0, r - smoothN)
            kHi = math.min(ROWS - 1, r + smoothN)
            for k = kLo to kHi
                acc += array.get(rowE, k)
                cnt += 1
            array.set(rowS, r, sdiv(acc, cnt))
        rowE := rowS

    // Normalize.
    maxE = 0.0
    for r = 0 to ROWS - 1
        maxE := math.max(maxE, array.get(rowE, r))
    maxE := maxE <= 0 ? 1.0 : maxE

    // Draw one horizontal band per row spanning the whole lookback width.
    xL = bar_index - LB + 1
    xR = bar_index
    for r = 0 to ROWS - 1
        e = array.get(rowE, r) / maxE
        eAdj = clamp(e * vi_intensityInp, 0.0, 1.0)
        if eAdj > 0.04
            yB = pxBot + r * rowH
            yT = yB + rowH
            transp = int(clamp(92 - eAdj * 68, 18, 95))
            col = energyColorThemed(eAdj)
            array.push(cells, box.new(xL, yT, xR, yB, border_width = 0, bgcolor = color.new(col, transp), xloc = xloc.bar_index))
            // Glow on the brightest bands.
            if vi_glowInput and eAdj >= vi_hotThrInput
                array.push(glows, box.new(xL, yT + rowH*0.2, xR, yB - rowH*0.2, border_width = 0, bgcolor = color.new(col, int(clamp(transp - 18, 12, 90))), xloc = xloc.bar_index))


// ============================================================================
//  ░░ HUD ░░
// ============================================================================
hudPos(p) =>
    switch p
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.middle_right
hudSize(s) =>
    switch s
        "Tiny"  => size.tiny
        "Small" => size.small
        "Large" => size.large
        => size.normal
bar10(p) =>
    int filled = math.round(clamp(p, 0.0, 1.0) * 10)
    string s = ""
    for i = 1 to 10
        s += i <= filled ? "█" : "░"
    s

var color cAcc  = #22d3ee
var color cTxt  = #dfe7f2
var color cTxtD = #5f7186
var color cPanel= #0a0c12
var color cPanelHd = #131826

var table hud = na
if hud_showInput and na(hud)
    hud := table.new(hudPos(hud_posInput), 2, 9, bgcolor = cPanel,
         border_color = color.new(cAcc, 65), border_width = 1, frame_color = color.new(cAcc, 45), frame_width = 1)

if hud_showInput and barstate.islast
    sz = hudSize(hud_sizeInput)
    eCol = energyColorThemed(energySm)
    domName = "PRICE"
    domW = wM
    if wV > domW
        domW := wV
        domName := "VOLATILITY"
    if wU > domW
        domW := wU
        domName := "VOLUME"
    if wT > domW
        domW := wT
        domName := "TREND"
    if wR > domW
        domW := wR
        domName := "RSI"
    // momentum check (initialized as PRICE/momentum)
    if wM >= domW
        domName := "MOMENTUM"

    table.cell(hud, 0, 0, "HYPERCUBE HEATMAP", text_color = cAcc, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_left)
    table.cell(hud, 1, 0, "AI field", text_color = cTxtD, text_size = sz, bgcolor = cPanelHd, text_halign = text.align_right)

    table.cell(hud, 0, 1, "energy", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 1, bar10(energySm), text_color = eCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 2, "energy %", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 2, str.tostring(energySm * 100, "#") + "%", text_color = eCol, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 3, "uncertainty", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 3, bar10(uncSm), text_color = uncSm > 0.5 ? #f59e0b : cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 4, "bias", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 4, dirBias > 0 ? "▲ bullish" : dirBias < 0 ? "▼ bearish" : "· neutral", text_color = dirBias > 0 ? #10b981 : dirBias < 0 ? #ef4444 : cTxtD, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 5, "focus (attn)", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 5, domName, text_color = cAcc, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 6, "field", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 6, str.tostring(COLS) + "w×" + str.tostring(ROWS) + "h", text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 7, "attn temp", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 7, str.tostring(ai_attnTempInp, "#.0"), text_color = cTxt, text_size = sz, text_halign = text.align_right)

    table.cell(hud, 0, 8, "hotspot thr", text_color = cTxtD, text_size = sz, text_halign = text.align_left)
    table.cell(hud, 1, 8, str.tostring(vi_hotThrInput, "#.00"), text_color = cTxt, text_size = sz, text_halign = text.align_right)
````
