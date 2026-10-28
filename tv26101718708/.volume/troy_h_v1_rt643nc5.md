# Troy H v1

- url: https://www.tradingview.com/script/RT643NC5-Troy-H-v1/
- type: indicator
- pine_id: PUB;150e4da2520644bba4da8ba21c19febd
- version: 2.0

## Description

Troy H is a companion pane for the Troy accumulation model. It plots the internal readings that drive Troy's entries and exits, so you can see why a signal fired instead of only that it fired.

It must be run alongside the Troy overlay. Troy places its markers on price; Troy H shows the state underneath them. Neither is complete on its own — the overlay tells you what happened, this pane tells you what the model was reading at the time. This is why the published chart carries both.

What the pane shows

The histogram — volume-weighted spread. This is the distance between price and its own smoothed anchor, weighted by the volume that moved it. Amber columns above zero mean price is stretched above the anchor on real participation. Teal below zero means stretched below. Darker patches mark bars where the move happened on thin volume, which the model treats as less trustworthy than the same distance on heavy volume.

The point of weighting by volume is that a two percent move on quiet tape and a two percent move on heavy tape are not the same event, but a plain spread reading scores them identically.

The magenta line — the smoothed signal. A short moving average of the spread. Crossings between the histogram and this line are what the model reads as a turn in the stretch, rather than a fixed level being touched.

The horizontal levels. These are the model's current arming thresholds, drawn live. They are not fixed numbers. They are learned from this symbol's own recent distribution of spread readings, so the same code arms at different absolute values on a quiet stock and a volatile one. Watching them move is the clearest way to see the model recalibrating to the instrument.

The zero line is the anchor. Above it price is extended, below it price is discounted, relative to the model's own reference rather than to a fixed average.

The vertical bands mark bars where the model's gates were open. Teal for the accumulation side, magenta for the harvest side.

The triangles mirror the overlay's entries and exits, on the same bars, so you can line a marker up against the reading that produced it. They come from a shadow position tracker inside this pane that reproduces the overlay's position rules exactly. If a triangle here does not land on the same bar as the overlay, the two are out of sync and neither should be trusted until that is resolved.

The readings table

Regime — whether the model currently classifies the tape as trending up, trending down, or neither. Entries are only permitted outside an established uptrend.

Spread — the current volume-weighted distance from the anchor, in the same units as the histogram.

PnL Z — how unusual the shadow position's current profit or loss is against its own history, in standard deviations. This is a measure of the position, not of price. It is what lets the model tell an ordinary drawdown from an exceptional one on the same instrument.

VFI — the volume flow reading and the size multiplier it is currently contributing.

DMFI — a directional money-flow reading, centred at zero, and its current multiplier. Oversold readings increase conviction. Overbought readings do not reduce it below the base — the multiplier only ever adds.

Buy$ — the size the model would commit on an entry right now, given all the multipliers above. This is a relative figure showing how conviction stacks, not a recommendation of how much anyone should trade.

Zone — which arming zone, if any, the spread currently sits in. A dash means no zone is active.

How to read it

Watch three things together: where the histogram sits against the learned thresholds, whether the regime permits action, and what the position reading is doing. An entry marker appearing while the spread is deeply negative, the regime is not up, and the position reading is stretched is the model's clearest case. A marker appearing with only one of those in place is a weaker one, and the pane is what lets you tell them apart.

The size row is the other reason to run this pane. Troy does not commit the same amount to every entry. Watching Buy$ move as the multipliers change shows you how much the model actually thinks of a given setup, which the overlay's marker alone cannot tell you.

Limitations, and what this will not do

This pane does not trade and does not issue advice. It is a display of one model's internal state.

The position readings come from a hypothetical book held inside the script, not from any real account. It assumes fills at the close of the signal bar, with no slippage, spread, or commission. Real results will differ, and on thin instruments they will differ substantially.

The learned thresholds need history to settle. On a chart with few bars loaded, or immediately after adding the script, the levels will move around before stabilising. Give it a full data set before reading anything into them.

The volume-weighted components require meaningful volume data. On instruments where volume is synthetic, aggregated across venues, or simply absent, those readings degrade and the multipliers they feed will be less informative.

Nothing here is a forecast. The readings describe what has already happened. Past behaviour of any model, including this one, does not indicate what it will do next.

This is a decision-support display, not a system to follow. Use it to understand what a model is reading, and make your own decisions.

## Source Code

````pine
//@version=6
// TROY H | BUILD 1.02 | Aug 2 2026 - THE PANE COMPANION, REBUILT FOR PARITY.
// Built directly FROM troy_1_02 source: every line of the signal chain - regime,
// debounced maturity, spread, penetration learning, z-overrides, conviction,
// both adaptive throttles, cycle-close-before-buy, caps, full book - is the
// overlay's own text, untouched. Parity is a property of construction, not a
// port. Shared-stamp law: the pair moves as one number (1.02 / 1.02).
// Removed vs overlay (display only): price ribbon/band plots, price-located
// markers and divergence circles, the fleet perf table + grade (overlay owns
// it), the TR pain ruler + its exports, the SQS money export block and the
// legacy self-grade chain (duplicate column titles on one chart - the
// companion-collision law). Added: the pane instrument - spread oscillator
// (regime-tinted columns + line), z-override zone stripes, in-pane signal
// triangles, and the key/state table (Regime, Spread, PnL Z, VFI, DMFI,
// Buy$, Zone), Bottom Left per the H standard. Exports: TH Signal +
// TROY H BUILD only - distinct titles beside the overlay by design.
// 1.03 - Aug 2 2026: THE RECOVERED DISPLAY, VERBATIM. The true Troy H v1 pane
// source arrived; its entire display layer - histogram coloring (regime hue,
// dimmed 0->50 on reversal), Signal MA line (SMA-3 of spread), PnL-Z scaled
// area + threshold lines, band/z zone backgrounds with color inputs, signal
// triangles, divergence dots, and the 2x7 state table - is ported character
// for character. The recovered file's CHAIN is the old generation (hard-reset
// maturity, stub buy throttle, no buy cap in the signal) and is NOT used:
// this display rides the overlay-1.02 chain, which is the whole point of the
// sync. i_rsiOn restored (the divergence dots need it). My 1.021-1.024
// approximations are fully superseded.
// 1.031 - Aug 2 2026 (owner ruling): PnL-Z mountain colors swapped to speak
// the book's state - GREEN when unrealized profit is stretched fat, RED when
// the book is stretched underwater. The z-threshold lines and the table cell
// keep action-side coloring (green = buy line / buy-arm) by fleet convention.
// COMPILE FIX (same build): the overlay's vestigial dead i_showTable input
// (flagged in the batch-4 audit, nothing reads it) collided with the
// recovered display's input of the same name - the vestige is removed.
// 1.024 DISPLAY PATCH - Aug 2 2026: histogram to the owner's spec, verbatim:
// bars in all four states, same hue dimmed on reversal. Above zero: bright
// gold while rising, DARK GOLD once a bar prints lower. Below zero: bright
// blue while falling, DARK BLUE as bars shrink toward zero. The 1.021 PnL-Z
// area is removed (wrong guess - the shading is the histogram itself). For
// the record: the original pane's source has never been uploaded; a complete
// census of the provided file shows its first drawing statement at line 348
// and no spread plot anywhere. This render implements the described law and
// will be diffed against the true source when it is exported from the chart.
// 1.022 DISPLAY PATCH - Aug 2 2026: histogram styled to the original pane -
// thin dense histogram lines (style_histogram, solid) instead of fat columns;
// regime coloring unchanged (gold/red above zero for bull/bear, green/blue
// below). The PnL-Z area keeps drawing beneath. Note for the record: the
// original pane script was never in hand - the uploaded "troy_h" file is an
// old overlay copy that contains no spread plot at all (verified to its last
// line), so this look is matched from the chart itself.
// 1.021 DISPLAY PATCH - Aug 2 2026: (a) sigma symbols were shipped as a broken
// escape (Pine has no \u string escapes) - literal character now; (b) two pane
// layers missed in the rebuild restored: the PnL-Z area fill (red above zero,
// green below) and the z-threshold guide lines at Buy Z / Sell Z; (c) mult
// readouts always show one decimal; stripes slightly stronger. Chain untouched;
// parity to overlay 1.02 unchanged - patch digit is display-only.
// Supersedes the stale companion (an old pre-debounce Troy overlay copy was
// running in the pane: hard-reset maturity, no cycle-closing exemption, stub
// buy throttle - the three causes of the marker mismatch).
// ════════════════════════════════════════════════════════════════════════
//  Troy v1 — TheurgyLabs                                          BUILD 1.01
//  CHANGELOG
//   1.01  PIPELINE EXPORT WIRE (net-zero swap): SQS:Wins/SQS:Losses out,
//         SQS:TotPnL + Bars in; first BUILD export added (source file
//         carried no stamp — filename lineage v1). Zero signal-path,
//         config, or accounting changes.
// ════════════════════════════════════════════════════════════════════════
indicator("Troy H", shorttitle="TROY H", overlay=false, max_labels_count=500)

// -- VERSION - the one-constant law (FLEET_PERF_STANDARD.md). Bump V_TAG only.
string V_TAG   = "1.031"
float  V_BUILD = str.tonumber(V_TAG)

// ──── INPUTS ────
src       = input.source(hl2,  "Source",              group="Ribbon")
len1      = input.int(8,       "Fast SMMA",           group="Ribbon")
len2      = input.int(16,      "Mid SMMA",            group="Ribbon")
len3      = input.int(28,      "Slow SMMA",           group="Ribbon")
len4      = input.int(40,      "Anchor SMMA",         group="Ribbon")
volLen    = input.int(20,      "Volume SMA Len",      group="Ribbon")
atrLen    = input.int(14,      "ATR Length",           group="Signal")
smoothLen = input.int(5,       "VW Smooth Length",     group="Signal")
matBars   = input.int(12,     "Maturity Bars",       group="Signal")
i_matDebounce = input.bool(false, "Maturity Debounce", group="Signal", tooltip="OFF = legacy: a single bullish bar resets the bear-maturity counter to 0 (whippy on fast TFs — starves buys on 1h/30m). ON = a bullish bar only DECAYS the counter by Maturity Decay, so brief regime blips don't wipe an accumulated bear streak. Fixes the fast-TF buy suppression without touching slow-TF behavior.")
i_matDecay    = input.int(4, "Maturity Decay", group="Signal", minval=1, maxval=12, tooltip="When Debounce is ON, how much the maturity counter bleeds per bullish bar. 4 = a 3-4 bar bullish run still fully clears it, but 1-2 bar whipsaws only dent it. Higher = stricter (toward legacy reset).")
buySep    = input.float(1.5,  "Buy ATR Sep Mult",    group="Signal")
i_buyThrotOn    = input.bool(true,    "Adaptive Buy Throttle", group="Buy Throttle", tooltip="Scale ATR separation with bear spread depth. Deeper decline → wider spacing between buys.")
i_buyThrotScale = input.float(0.5,    "Buy Throttle Scale",    group="Buy Throttle", tooltip="Sep mult grows by this per -1 ATR of spread. mult = 1 + min(max-1, |spread| × scale)")
i_buyThrotMax   = input.float(3.0,    "Buy Throttle Max Mult", group="Buy Throttle")
i_donchLen     = input.int(14,     "Donchian Length",        group="Penetration Bands")
i_adaptLookback = input.int(100,   "Penetration Samples",   group="Penetration Bands", tooltip="Rolling window of wick penetration depths to learn from.")
i_minSamples   = input.int(22,     "Min Samples Required",  group="Penetration Bands")
i_defaultMult  = input.float(0.5,  "Default ATR Mult",      group="Penetration Bands", tooltip="Used before enough samples are collected.")
i_sensitivity  = input.float(0.8,  "Sensitivity Factor",    group="Penetration Bands", tooltip="Scales learned multiplier. Lower = more signals.")
i_minMult      = input.float(0.1,  "Min Multiplier",        group="Penetration Bands")
i_maxMult      = input.float(1.5,  "Max Multiplier",        group="Penetration Bands")
i_buySpreadGateOn  = input.bool(false,   "Buy Spread Gate",    group="Signal", tooltip="Require spread below threshold for buys. Filters shallow-dip band touches.")
i_buySpreadGate    = input.float(-0.5,  "Buy Spread Threshold", group="Signal")
i_sellSpreadGateOn = input.bool(true,   "Sell Spread Gate",   group="Signal", tooltip="Require spread above threshold for sells.")
i_sellSpreadGate   = input.float(0.5,   "Sell Spread Threshold", group="Signal")
i_sellThrotOn   = input.bool(true,   "Adaptive Sell Throttle", group="Sell Throttle", tooltip="Cooldown stretches when spread is extended. First sell of each cycle fires instantly.")
i_sellThrotBase = input.int(4,       "Throttle Base (bars)",   group="Sell Throttle")
i_sellThrotScale = input.float(1.0,  "Throttle Scale (per σ)", group="Sell Throttle", tooltip="Cooldown mult grows by this per +1 ATR of spread. mult = 1 + min(cap-1, spread × scale)")
i_sellThrotMax  = input.float(10.0,  "Throttle Max Mult",     group="Sell Throttle")
pnlLen    = input.int(24,      "PnL Lookback",        group="Z Override")
zLen      = input.int(100,     "Z Lookback",          group="Z Override")
buyZ      = input.float(-2.5,  "Buy Z Threshold",     group="Z Override")
sellZ     = input.float(2.75,  "Sell Z Threshold",    group="Z Override")
vfiLen    = input.int(130,     "VFI Length",          group="VFI")
vfiCoef   = input.float(0.2,  "VFI Coeff",           group="VFI")
vfiVCoef  = input.float(2.5,  "VFI Vol Cutoff",      group="VFI")
vfiScale  = input.float(10.0, "VFI Mult Scale",      group="VFI")
vfiCeil   = input.float(2.0,  "VFI Mult Ceiling",    group="VFI")
dmfiSmLen = input.int(3,      "DMFI Smooth Length",   group="DMFI")
dmfiScale = input.float(25.0, "DMFI Mult Scale",     group="DMFI")
dmfiCeil  = input.float(2.0,  "DMFI Mult Ceiling",   group="DMFI")
dmfiBuyOn = input.bool(true,  "DMFI Buy Mult ON",    group="DMFI")
convCeil  = input.float(3.0,  "Total Conv Ceiling",  group="DMFI")
eomOn     = input.bool(true,  "EOM Mult ON",         group="EOM")
eomSmLen  = input.int(14,     "EOM Smooth Length",   group="EOM")
eomZLen   = input.int(100,    "EOM Z Lookback",      group="EOM")
eomScale  = input.float(2.0,  "EOM Mult Scale",      group="EOM")
eomCeil   = input.float(1.5,  "EOM Mult Ceiling",    group="EOM")
i_rsiOn    = input.bool(true,  "Show RSI Divergence",  group="RSI Detection")
i_rsiLen   = input.int(14,     "RSI Length",           group="RSI Detection")
i_divLeft  = input.int(5,      "Pivot Left Bars",     group="RSI Detection")
i_divRight = input.int(3,      "Pivot Right Bars",    group="RSI Detection")
i_divMax   = input.int(24,     "Max Lookback Bars",   group="RSI Detection")
i_divBoostOn  = input.bool(true,  "Divergence Conv Boost", group="RSI Detection", tooltip="Boost conviction when signal fires within N bars of RSI divergence.")
i_divWindow   = input.int(3,      "Boost Window (bars)",   group="RSI Detection")
i_divBoostAmt = input.float(1.5,  "Boost Multiplier",      group="RSI Detection")
buyBase   = input.float(100,  "Buy Base $",          group="Sizing")
depthScale = input.float(2.0, "Depth Scale",         group="Sizing", tooltip="ATR units below buy band per 1.0× depth increase")
depthCeil = input.float(3.0,  "Depth Mult Ceiling",  group="Sizing")
sizeCeil  = input.float(600,  "Max Buy $ Ceiling",   group="Sizing")
sellPctIn = input.float(20.0, "Sell % of Remaining", group="Sizing")
sellDepthS = input.float(2.0, "Sell Depth Scale",    group="Sizing")
maxSellPct = input.float(50.0,"Max Sell %",           group="Sizing")
maxBuys   = input.int(16,     "Max Buys Per Cycle",  group="Sizing")

// ──── VOLUME-WEIGHTED SMMA ────
f_vwSmma(float _src, int _len, float _vn) =>
    var float val = na
    if na(val)
        val := _src
    else
        val := (val * (_len - 1) + _src * _vn) / (_len - 1 + _vn)
    val

volNorm = nz(volume / ta.sma(volume, volLen), 1.0)

fast   = f_vwSmma(src, len1, volNorm)
slow   = f_vwSmma(src, len3, volNorm)
anchor = f_vwSmma(src, len4, volNorm)

// ──── REGIME ────
bullish    = fast > anchor
trendColor = bullish ? color.new(#FFD700, 0) : color.new(#1E90FF, 0)

// Maturity: count bars in bear regime
var int bearBars = 0
bearBars := not bullish ? bearBars + 1 : (i_matDebounce ? math.max(0, bearBars - i_matDecay) : 0)
maturityOK = bearBars >= matBars

// ──── SPREAD ────
atr       = ta.atr(atrLen)
rawSpread = (fast - anchor) / atr
spread    = f_vwSmma(rawSpread, smoothLen, volNorm)
sigMA     = ta.sma(spread, 3)

// ──── PENETRATION-LEARNING BANDS (Opus46 port) ────
float donchHi = ta.highest(high, i_donchLen)[1]
float donchLo = ta.lowest(low, i_donchLen)[1]

var array<float> buyPenetrations  = array.new_float()
var array<float> sellPenetrations = array.new_float()

bool touchedLower = low <= donchLo
bool touchedUpper = high >= donchHi

if touchedLower and atr > 0
    float pen = (donchLo - low) / atr
    if pen > 0
        array.push(buyPenetrations, pen)
        if array.size(buyPenetrations) > i_adaptLookback
            array.shift(buyPenetrations)

if touchedUpper and atr > 0
    float pen = (high - donchHi) / atr
    if pen > 0
        array.push(sellPenetrations, pen)
        if array.size(sellPenetrations) > i_adaptLookback
            array.shift(sellPenetrations)

var float buyMult  = i_defaultMult
var float sellMult = i_defaultMult

if array.size(buyPenetrations) >= i_minSamples
    float avgPen = array.avg(buyPenetrations) * i_sensitivity
    buyMult := math.max(i_minMult, math.min(i_maxMult, avgPen))

if array.size(sellPenetrations) >= i_minSamples
    float avgPen = array.avg(sellPenetrations) * i_sensitivity
    sellMult := math.max(i_minMult, math.min(i_maxMult, avgPen))

float buyBandLevel  = donchLo - (atr * buyMult)
float sellBandLevel = donchHi + (atr * sellMult)

// ──── BAND-TOUCH SIGNALS (spread-gated) ────
bool spreadBuyOK  = not i_buySpreadGateOn or spread <= i_buySpreadGate
bool spreadSellOK = not i_sellSpreadGateOn or spread >= i_sellSpreadGate
bool bandBuy  = low <= buyBandLevel and not bullish and maturityOK and spreadBuyOK and barstate.isconfirmed
bool bandSell = high >= sellBandLevel and bullish and spreadSellOK and barstate.isconfirmed

// ──── REALPNL Z-OVERRIDE ────
rawPnL  = (close - close[pnlLen]) / atr
pnlMean = ta.sma(rawPnL, zLen)
pnlStd  = ta.stdev(rawPnL, zLen)
pnlZ    = pnlStd > 0 ? (rawPnL - pnlMean) / pnlStd : 0.0

zBuyOvr  = pnlZ <= buyZ
zSellOvr = pnlZ >= sellZ

// ──── VFI CONVICTION MULTIPLIER ────
typical  = hlc3
inter    = math.log(typical) - math.log(nz(typical[1], typical))
vinter   = ta.stdev(inter, 30)
cutoff   = vfiCoef * vinter * close
vave     = nz(ta.sma(volume, vfiLen)[1], volume)
vmax     = vave * vfiVCoef
vc       = math.min(volume, vmax)
mf       = typical - nz(typical[1], typical)
vcp      = mf > cutoff ? vc : (mf < -cutoff ? -vc : 0.0)
vfi      = nz(ta.sma(vcp, vfiLen) * vfiLen / vave, 0.0)

// Buys: reward negative VFI (selling exhaustion → higher conviction)
// Sells: reward positive VFI (buying exhaustion → higher conviction)
// Floor 1.0 = reward-only, never penalize
vfiBuyMult  = math.min(vfiCeil, math.max(1.0, 1.0 + math.abs(math.min(vfi, 0.0)) / vfiScale))

// ──── DMFI CONVICTION MULTIPLIER ────
mfiRaw      = ta.mfi(hlc3, 14)
rsiMfi      = ta.rsi(mfiRaw, 14)
dmfiRaw     = 2 * mfiRaw - rsiMfi
dmfi        = ta.sma(dmfiRaw, dmfiSmLen)

// Buys: reward low DMFI (selling pressure = higher buy conviction)
// Sells: OFF by default (fleet standard — over-sells trending assets)
dmfiBuyMult  = dmfiBuyOn ? math.min(dmfiCeil, math.max(1.0, 1.0 + (50 - math.min(nz(dmfi, 50), 50)) / dmfiScale)) : 1.0

// ──── EOM CONVICTION MULTIPLIER ────
distMoved = (high + low) / 2.0 - (nz(high[1], high) + nz(low[1], low)) / 2.0
eomRange  = high - low
eomRaw    = eomRange > 0 ? distMoved * eomRange / nz(volume, 1) : 0.0
eom       = ta.sma(eomRaw, eomSmLen)

eomMean   = ta.sma(eom, eomZLen)
eomStd    = ta.stdev(eom, eomZLen)
eomZ      = nz(eomStd > 0 ? (eom - eomMean) / eomStd : 0.0, 0.0)

// Buys: reward deeply negative EOM z (price falling easily = structural extreme)
eomBuyMult = eomOn ? math.min(eomCeil, math.max(1.0, 1.0 + math.abs(math.min(eomZ, 0.0)) / eomScale)) : 1.0

// ──── RSI DIVERGENCE DETECTION ────
float rsiVal = ta.rsi(close, i_rsiLen)

// Pivot lows (bullish divergence: price lower low, RSI higher low)
float pricePivLo = ta.pivotlow(low, i_divLeft, i_divRight)
float rsiPivLo   = ta.pivotlow(rsiVal, i_divLeft, i_divRight)
var float prevPriceLo = na
var float prevRsiLo   = na
var int   prevLoBar   = na

bool bullDiv = false
if not na(pricePivLo) and not na(rsiPivLo)
    if not na(prevPriceLo) and not na(prevRsiLo) and (bar_index - prevLoBar) <= i_divMax
        if pricePivLo < prevPriceLo and rsiPivLo > prevRsiLo
            bullDiv := true
    prevPriceLo := pricePivLo
    prevRsiLo   := rsiPivLo
    prevLoBar   := bar_index

// Pivot highs (bearish divergence: price higher high, RSI lower high)
float pricePivHi = ta.pivothigh(high, i_divLeft, i_divRight)
float rsiPivHi   = ta.pivothigh(rsiVal, i_divLeft, i_divRight)
var float prevPriceHi = na
var float prevRsiHi   = na
var int   prevHiBar   = na

bool bearDiv = false
if not na(pricePivHi) and not na(rsiPivHi)
    if not na(prevPriceHi) and not na(prevRsiHi) and (bar_index - prevHiBar) <= i_divMax
        if pricePivHi > prevPriceHi and rsiPivHi < prevRsiHi
            bearDiv := true
    prevPriceHi := pricePivHi
    prevRsiHi   := rsiPivHi
    prevHiBar   := bar_index

// Track last divergence bars for conviction boost
var int lastBullDivBar = na
var int lastBearDivBar = na
if bullDiv
    lastBullDivBar := bar_index
if bearDiv
    lastBearDivBar := bar_index

bool  buyDivNear  = i_divBoostOn and not na(lastBullDivBar) and (bar_index - lastBullDivBar) <= i_divWindow
float divBuyBoost  = buyDivNear  ? i_divBoostAmt : 1.0

// Total conviction: VFI × DMFI × EOM × DivBoost, capped
totalBuyConv  = math.min(convCeil, vfiBuyMult * dmfiBuyMult * eomBuyMult * divBuyBoost)

// ──── POSITION TRACKING (vars declared early for throttle access) ────
var float posQty       = 0.0
var float posCost      = 0.0
var float avgEntry     = 0.0
var int   cycBuyLots   = 0
var int   cycSellLots  = 0
var float cycSellRev   = 0.0
var float cycSoldCost  = 0.0
var float totalReal    = 0.0
var int   totalCycles  = 0
var int   totalSignals = 0
var int   totalBuys    = 0
var int   totalSells   = 0
var float maxDD        = 0.0
var int   wins         = 0
var int   losses       = 0
var float grossWins    = 0.0
var float grossLosses  = 0.0
var float totalDeployed = 0.0
var float peakPosCost   = 0.0
var float peakEquity    = 0.0
// ── MaxDD AUDIT tracks (diagnostic only — do NOT feed SQS) ──
var float peakReal      = 0.0
var float maxDDClosed   = 0.0
var float maxOpenDD     = 0.0

// ──── ADAPTIVE SELL THROTTLE (KEEL port) ────
var int lastSellBar = 0
float sellThrotMult = 1.0 + math.min(i_sellThrotMax - 1.0, math.max(0.0, spread) * i_sellThrotScale)
int   sellThrotCD   = math.round(i_sellThrotBase * sellThrotMult)
bool  sellThrotOK   = not i_sellThrotOn or cycSellLots == 0 or lastSellBar == 0 or (bar_index - lastSellBar) >= sellThrotCD

// ──── ADAPTIVE BUY THROTTLE ────
var float lastBuyPrice = na
if bullish
    lastBuyPrice := na
float buyThrotMult = i_buyThrotOn ? 1.0 + math.min(i_buyThrotMax - 1.0, math.max(0.0, -spread) * i_buyThrotScale) : 1.0
float adaptiveSep  = buySep * buyThrotMult
buyThrotOK = not i_buyThrotOn or na(lastBuyPrice) or math.abs(low - lastBuyPrice) >= atr * adaptiveSep

// ──── SPREAD-DEPTH SIZING (distance from band) ────
buyDepth  = atr > 0 ? math.abs(math.min(low - buyBandLevel, 0.0)) / atr : 0.0
depthMult = math.min(depthCeil, 1.0 + buyDepth / depthScale)
buyDollar = math.min(sizeCeil, buyBase * totalBuyConv * depthMult)

// ──── COMBINED SIGNALS (REGIME-GATED) ────
sigBuyBase = (bandBuy or zBuyOvr) and not bullish and maturityOK and buyThrotOK
bool cycleClosing = sigBuyBase and cycSellLots > 0
buySignal  = sigBuyBase and (cycleClosing or cycBuyLots < maxBuys)
sellSignal = (bandSell or zSellOvr) and bullish and sellThrotOK and posQty > 0

// ──── CYCLE CLOSE (fires before buy exec; resets cycBuyLots so the opening buy of the new cycle isn't dropped at the cap) ────
if cycleClosing
    float cycReal = cycSellRev - cycSoldCost
    totalReal    := totalReal + cycReal
    totalCycles  := totalCycles + 1
    if cycReal >= 0
        wins      := wins + 1
        grossWins := grossWins + cycReal
    else
        losses      := losses + 1
        grossLosses := grossLosses + math.abs(cycReal)
    cycBuyLots   := 0
    cycSellLots  := 0
    cycSellRev   := 0.0
    cycSoldCost  := 0.0

// ──── BUY EXECUTION ────
if buySignal
    buyQty      = buyDollar / close
    posQty     := posQty + buyQty
    posCost    := posCost + buyDollar
    avgEntry   := posQty > 0 ? posCost / posQty : close
    cycBuyLots := cycBuyLots + 1
    totalSignals := totalSignals + 1
    totalBuys    := totalBuys + 1
    totalDeployed := totalDeployed + buyDollar
    lastBuyPrice := close

// ──── SELL EXECUTION ────
if sellSignal
    sellHt      = atr > 0 ? math.max(high - sellBandLevel, 0.0) / atr : 0.0
    sellDpMult  = math.min(depthCeil, 1.0 + sellHt / sellDepthS)
    dynSellPct  = math.min(maxSellPct, sellPctIn * sellDpMult)
    sellQty     = posQty * (dynSellPct / 100.0)
    sellRev     = sellQty * close
    posQty     := posQty - sellQty
    posCost    := posQty * avgEntry
    cycSellLots := cycSellLots + 1
    cycSellRev  := cycSellRev + sellRev
    cycSoldCost := cycSoldCost + sellQty * avgEntry
    totalSignals := totalSignals + 1
    totalSells   := totalSells + 1
    lastSellBar   := bar_index

// ──── DERIVED METRICS ────
peakPosCost := math.max(peakPosCost, posCost)
unrealPnL = posQty * close - posCost
totalPnL  = unrealPnL + totalReal
peakEquity := math.max(peakEquity, totalPnL)
maxDD      := math.max(maxDD, peakEquity - totalPnL)
// MaxDD AUDIT — maxDD above is the FULL equity curve (realized + open MTM).
// maxDDClosed = give-back of booked profit only; maxOpenDD = deepest the open
// position ever sat underwater. If maxDD ≈ maxDDClosed while maxOpenDD is large,
// a near-zero historical MaxDD was a closed-cycle-only artifact and MAR is overstated.
peakReal    := math.max(peakReal, totalReal)
maxDDClosed := math.max(maxDDClosed, peakReal - totalReal)
maxOpenDD   := math.max(maxOpenDD, math.max(0.0, -unrealPnL))


// ═══════════════════════════════════════════════════════════════════


// ──── RECOVERED TROY H DISPLAY (verbatim) ────
string G_TBL = "Table"
i_showTable = input.bool(true, "Show Table", group=G_TBL)
tPos = switch input.string("Bottom Right", "Position", options=["Top Left","Top Right","Bottom Left","Bottom Right"], group=G_TBL)
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    => position.bottom_right

string G_ZONE = "Zone Background"
i_buyZoneClr   = input.color(#00FFFF, "Buy Zone Color",    group=G_ZONE)
i_sellZoneClr  = input.color(#FF00FF, "Sell Zone Color",   group=G_ZONE)
i_zoneOpacity  = input.int(75, "Zone Opacity", minval=0, maxval=100, group=G_ZONE)
zScale    = input.float(1.0,   "Z Visual Scale",      group="Z Override")

// ──── HISTOGRAM COLORING ────
spreadDelta   = spread - spread[1]
spreadGrowing = (spread > 0 and spreadDelta > 0) or (spread < 0 and spreadDelta < 0)
dimAlpha      = spreadGrowing ? 0 : 50
barColor = bullish ? color.new(#FFD700, dimAlpha) : color.new(#1E90FF, dimAlpha)

// ──── ZONE DETECTION ────
inBuyZone  = bandBuy and not bullish
inSellZone = bandSell and bullish
inZOverBuy = pnlZ <= buyZ and not bullish
inZOverSel = pnlZ >= sellZ and bullish

// Spread histogram
plot(spread, "Spread", style=plot.style_columns, color=barColor, linewidth=2)

// Signal MA
plot(sigMA, "Signal MA", color=color.new(#FF00FF, 0), linewidth=2)

// Zero line
hline(0, "Zero", color=color.new(color.white, 80), linestyle=hline.style_solid)

// PnL z-score area overlay - scaled to fit spread range
float pnlScaled = pnlZ * zScale
color pnlAreaClr = pnlZ >= 0 ? color.new(#00FF88, 65) : color.new(#FF4444, 65)
color pnlLineClr = pnlZ >= 0 ? color.new(#00FF88, 30) : color.new(#FF4444, 30)
pPnl  = plot(pnlScaled, "PnL Z", color=pnlLineClr, linewidth=1)
pZero = plot(0.0, "PnL Zero", color=color.new(color.white, 100), display=display.none)
fill(pPnl, pZero, color=pnlAreaClr, title="PnL Z Fill")

// Z threshold lines
plot(buyZ * zScale,  "Buy Z Thr",  color=color.new(#00FF88, 60), linewidth=1, style=plot.style_line)
plot(sellZ * zScale, "Sell Z Thr", color=color.new(#FF4444, 60), linewidth=1, style=plot.style_line)

// Zone background
bgcolor(inBuyZone or inZOverBuy ? color.new(i_buyZoneClr, i_zoneOpacity) : inSellZone or inZOverSel ? color.new(i_sellZoneClr, i_zoneOpacity) : na, title="Zone BG")

// Signal markers
plotshape(buySignal  ? spread : na, "Buy",  shape.triangleup,   location.absolute, color.new(#00FFFF, 0), size=size.small)
plotshape(sellSignal ? spread : na, "Sell", shape.triangledown, location.absolute, color.new(#FF00FF, 0), size=size.small)

// RSI divergence dots on histogram (offset by pivot right bars)
plotshape(i_rsiOn and bullDiv ? spread[i_divRight] : na, "Bull Div", shape.circle, location.absolute, color.new(#00FF00, 0), size=size.tiny, offset=-i_divRight)
plotshape(i_rsiOn and bearDiv ? spread[i_divRight] : na, "Bear Div", shape.circle, location.absolute, color.new(#FF8C00, 0), size=size.tiny, offset=-i_divRight)

var table tbl = table.new(tPos, 2, 7, border_width=1, bgcolor=color.new(color.black, 80))
if i_showTable and barstate.islast
    string regStr = bullish ? "BULLISH" : "BEARISH"
    color regClr  = bullish ? #FFD700 : #1E90FF
    table.cell(tbl, 0, 0, "Regime",  text_color=color.white, bgcolor=color.new(color.gray, 50), text_size=size.small)
    table.cell(tbl, 1, 0, regStr,    text_color=color.black, bgcolor=regClr, text_size=size.small)
    table.cell(tbl, 0, 1, "Spread",  text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(tbl, 1, 1, str.tostring(spread, "#.##"), text_color=regClr, text_size=size.small)
    color pzClr = pnlZ <= buyZ ? #00FF88 : pnlZ >= sellZ ? #FF4444 : color.white
    table.cell(tbl, 0, 2, "PnL Z",  text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(tbl, 1, 2, str.tostring(pnlZ, "#.##") + "σ", text_color=pzClr, text_size=size.small)
    color vfiClr = vfi < -5 ? #00FF88 : vfi > 5 ? #FF4444 : color.white
    table.cell(tbl, 0, 3, "VFI",    text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(tbl, 1, 3, str.tostring(vfi, "#.#") + " (" + str.tostring(vfiBuyMult, "#.#") + "×)", text_color=vfiClr, text_size=size.small)
    color dmfiClr = nz(dmfi, 50) < 35 ? #00FF88 : nz(dmfi, 50) > 65 ? #FF4444 : color.white
    table.cell(tbl, 0, 4, "DMFI",   text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(tbl, 1, 4, str.tostring(nz(dmfi, 50), "#.#") + " (" + str.tostring(dmfiBuyMult, "#.#") + "×)", text_color=dmfiClr, text_size=size.small)
    color sizeClr = depthMult >= 2.0 ? #00FF88 : depthMult >= 1.5 ? #FFD700 : color.white
    table.cell(tbl, 0, 5, "Buy$",   text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(tbl, 1, 5, "$" + str.tostring(buyDollar, "#") + " (" + str.tostring(depthMult, "#.#") + "d)", text_color=sizeClr, text_size=size.small)
    string zoneStr = inBuyZone ? "BUY ZONE" : inSellZone ? "SELL ZONE" : inZOverBuy ? "Z-BUY" : inZOverSel ? "Z-SELL" : "—"
    color zoneClr = inBuyZone or inZOverBuy ? #00FFFF : inSellZone or inZOverSel ? #FF00FF : color.white
    table.cell(tbl, 0, 6, "Zone",   text_color=color.white, bgcolor=color.new(color.gray, 70), text_size=size.small)
    table.cell(tbl, 1, 6, zoneStr,  text_color=zoneClr, text_size=size.small)

plot(buySignal ? 1 : sellSignal ? -1 : 0, "TH Signal", display=display.status_line + display.data_window)

// ─── SQS EXPORTS (for SQS companion pane) ────────────
plot(V_BUILD,              "TROY H BUILD", display=display.data_window)

// ──── HELPER FUNCTIONS ────
````
