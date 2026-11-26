# Hawkes Branching [N4]

- url: https://www.tradingview.com/script/MVH7PoiQ-Hawkes-Branching-N4/
- type: indicator
- pine_id: PUB;feaa71b090184e818fc1c919691ab935
- version: 1.0

## Description

[b]hawkes branching [n4][/b] — the math under crashes.

every crash has the same internal shape. each large move increases the chance of the next, the kernel sustains itself, then it does not. this indicator plots the line.

[b]what it does[/b]

λ_t is the asset's own self-exciting intensity, recursive and bounded. when the kernel α·exp(-β·t) sustains itself, the branching ratio η = α/β crosses 1 — the regime moves from stable to explosive. plotted as a histogram + threshold band at η = 1 (the bifurcation line, dashed white).

multi-timeframe coupling on D / W / M, with the canonical non-repaint idiom (request.security on [1] offset, lookahead_on). most TV Hawkes scripts repaint the realtime higher-TF bar; this one does not.

[b]regime states[/b]
[list]
[*]ESPERAR / wait — η stable, λ low (secondary color)
[*]ATENCION / attention — λ rising, η near 1 (primary lighter)
[*]REGIMEN / regime — λ explosive OR η > 1 (primary intense)
[/list]

[b]inputs[/b]
[list]
[*]α (jump magnitude): default 0.6, sensible range 0.3 to 1.0
[*]β (decay rate): default 1.2, sensible range 0.5 to 3.0
[*]exceedance percentile: default 90, can tune to 95 for quieter assets
[*]lookback: 252 trading days
[*]idioma / language: es | en (deck labels toggle)
[/list]

[b]reference[/b]

Bacry, Mastromatteo, Muzy 2015 — "Hawkes processes in finance" (Market Microstructure & Liquidity vol. 1).

open source. educational. NFA. the code does not solve the risk, it names it.

## Source Code

````pine
// Hawkes Branching [N4] (self-exciting intensity, branching ratio, multi-TF)
//
// v1 — 2026-05-04. Hawkes self-exciting point process [Bacry-Mastromatteo-Muzy 2015].
//   The math under crashes. Self-exciting: each large move makes the next more
//   likely. Intensity λ(t) = μ + Σ α·exp(-β(t - tᵢ)) where tᵢ are exceedance
//   times (returns crossing the kᵗʰ percentile). When the kernel α·exp(-β·t)
//   sustains itself the branching ratio η = α/β crosses 1. η < 1 stable.
//   η ≥ 1 explosive. This indicator ranks where you are right now relative
//   to that bifurcation line.

//@version=6
indicator("Hawkes Branching [N4]", overlay=false, precision=3)

alpha            = input.float(0.6,  "α · jump magnitude",     minval=0.05, step=0.05, group="hawkes core")
beta             = input.float(1.2,  "β · decay rate",         minval=0.1,  step=0.1,  group="hawkes core")
mu               = input.float(0.0,  "μ · baseline intensity", minval=0.0,  step=0.05, group="hawkes core")
exceedThreshPct  = input.int(90,    "exceedance percentile",   minval=50, maxval=99,    group="hawkes core")
lookback         = input.int(252,   "lookback window",          minval=50,                group="hawkes core")
lambdaHotPct     = input.int(90,    "λ hot percentile (alert)", minval=50, maxval=99,    group="hawkes core")

colorPrimary     = input.color(#F4A261, "Color primary (explosive / regime)", group="colors")
colorSecondary   = input.color(#E5DCEF, "Color secondary (stable / wait)",    group="colors")

showLambda       = input.bool(true,  "λ histogram",                 group="display")
showEta          = input.bool(true,  "η · branching ratio line",    group="display")
showBifurcation  = input.bool(true,  "η = 1 bifurcation band",      group="display")
showMTF          = input.bool(true,  "multi-TF λ overlays",         group="display")
showDeck         = input.bool(true,  "floating deck (paper card)",  group="display")
deckPosition     = input.string("top_right", "deck position", options=["top_right","bottom_right","top_left","bottom_left"], group="display")
language         = input.string("es", "Idioma / Language", options=["es","en"], group="display")

deck_paper = #F5F1E8
deck_ink   = #1B1820
deck_hush  = #8A829A

logRet = math.log(close / close[1])
absRet = math.abs(logRet)

exceedThresh = ta.percentile_nearest_rank(absRet, lookback, exceedThreshPct)
isExceed = absRet > exceedThresh

decay = math.exp(-beta)

var float lambda = 0.0
lambda := mu + (nz(lambda[1], 0.0) - mu) * decay + (isExceed ? alpha : 0.0)

eta = alpha / beta

lambdaMid  = ta.percentile_nearest_rank(lambda, lookback, 50)
lambdaHot  = ta.percentile_nearest_rank(lambda, lookback, lambdaHotPct)

regimeState = (lambda > lambdaHot) or (eta >= 1.0) ? "REGIMEN" : (lambda > lambdaMid) ? "ATENCION" : "ESPERAR"

_hawkesTF() =>
    _lr = math.log(close / close[1])
    _ar = math.abs(_lr)
    _thr = ta.percentile_nearest_rank(_ar, lookback, exceedThreshPct)
    _exc = _ar > _thr
    var float _lam = 0.0
    _lam := mu + (nz(_lam[1], 0.0) - mu) * decay + (_exc ? alpha : 0.0)
    _lam

lamD = request.security(syminfo.tickerid, "D", _hawkesTF()[1], lookahead=barmerge.lookahead_on)
lamW = request.security(syminfo.tickerid, "W", _hawkesTF()[1], lookahead=barmerge.lookahead_on)
lamM = request.security(syminfo.tickerid, "M", _hawkesTF()[1], lookahead=barmerge.lookahead_on)

mtfMean = (nz(lamD) + nz(lamW) + nz(lamM)) / 3.0
mtfCouplingStd = not na(lamD) and not na(lamW) and not na(lamM) ? math.sqrt((math.pow(lamD - mtfMean, 2) + math.pow(lamW - mtfMean, 2) + math.pow(lamM - mtfMean, 2)) / 3.0) : na

mtfHot = ta.percentile_nearest_rank(lambda, lookback, 75)
allHot = not na(lamD) and not na(lamW) and not na(lamM) and lamD > mtfHot and lamW > mtfHot and lamM > mtfHot
mtfCoupSafe = nz(mtfCouplingStd, 0.0)
mtfCoupTightThr = ta.percentile_nearest_rank(mtfCoupSafe, lookback, 25)
tightCoupling = not na(mtfCouplingStd) and mtfCouplingStd < mtfCoupTightThr
coherentCrisis = allHot and tightCoupling

isEN = language == "en"
deckHeader     = isEN ? "the engine"          : "el motor"
deckEtaKey     = isEN ? "η · branching"        : "η · branching"
deckLambdaKey  = isEN ? "λ · intensity"        : "λ · intensidad"
deckRegimeKey  = isEN ? "regime"               : "régimen"
deckCoherentKey= isEN ? "mtf · coherent"       : "mtf · coherente"

regimeDisplay = isEN ? (regimeState == "REGIMEN" ? "regime" : regimeState == "ATENCION" ? "attention" : "wait") : (regimeState == "REGIMEN" ? "régimen" : regimeState == "ATENCION" ? "atención" : "esperar")
regimeColor   = regimeState == "REGIMEN" ? colorPrimary : regimeState == "ATENCION" ? color.new(colorPrimary, 50) : colorSecondary
coherentDisplay = isEN ? (coherentCrisis ? "yes" : "no") : (coherentCrisis ? "sí" : "no")

lambdaBarColor = regimeState == "REGIMEN" ? color.new(colorPrimary, 10) : regimeState == "ATENCION" ? color.new(colorPrimary, 50) : color.new(colorSecondary, 30)
plot(showLambda ? lambda : na, title="λ · intensity", color=lambdaBarColor, style=plot.style_histogram, linewidth=2)

plot(showMTF ? lamD : na, title="λ daily",   color=color.new(colorPrimary, 60), linewidth=1)
plot(showMTF ? lamW : na, title="λ weekly",  color=color.new(colorPrimary, 75), linewidth=1)
plot(showMTF ? lamM : na, title="λ monthly", color=color.new(colorPrimary, 85), linewidth=1)

plot(showEta ? eta : na, title="η · branching ratio", color=color.new(deck_ink, 30), linewidth=1, style=plot.style_line)
hline(showBifurcation ? 1.0 : na, "η = 1 (bifurcation)", color=color.new(color.white, 30), linestyle=hline.style_dashed, linewidth=1)

posDeck = deckPosition == "top_right" ? position.top_right : deckPosition == "bottom_right" ? position.bottom_right : deckPosition == "top_left" ? position.top_left : position.bottom_left

if showDeck and barstate.islast
    var table deck = table.new(posDeck, 2, 5, bgcolor=deck_paper, border_color=color.new(deck_hush, 40), border_width=1, frame_color=color.new(deck_hush, 30), frame_width=1)

    table.cell(deck, 0, 0, deckHeader, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 0, syminfo.ticker, text_color=deck_ink, text_size=size.tiny, text_halign=text.align_right)

    table.cell(deck, 0, 1, deckEtaKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 1, str.tostring(eta, "#.##"), text_color=eta >= 1.0 ? colorPrimary : deck_ink, text_size=size.normal, text_halign=text.align_right)

    table.cell(deck, 0, 2, deckLambdaKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 2, str.tostring(lambda, "#.###"), text_color=deck_ink, text_size=size.normal, text_halign=text.align_right)

    table.cell(deck, 0, 3, deckRegimeKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 3, regimeDisplay, text_color=regimeColor, text_size=size.large, text_halign=text.align_right)

    table.cell(deck, 0, 4, deckCoherentKey, text_color=deck_hush, text_size=size.tiny, text_halign=text.align_left)
    table.cell(deck, 1, 4, coherentDisplay, text_color=coherentCrisis ? colorPrimary : deck_hush, text_size=size.tiny, text_halign=text.align_right)

alertcondition(ta.crossover(lambda, lambdaHot), "Hawkes regime onset", "{{ticker}} — λ crossed above its hot percentile.")
alertcondition(eta >= 1.0 and eta[1] < 1.0, "Branching explosive", "{{ticker}} — η crossed above 1.0 (explosive regime).")
alertcondition(coherentCrisis and not coherentCrisis[1], "Multi-TF coherent crisis", "{{ticker}} — D/W/M λ all hot AND coupling tight.")
````
