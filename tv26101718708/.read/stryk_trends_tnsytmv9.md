# Stryk Trends

- url: https://www.tradingview.com/script/tNSYtmv9-Stryk-Trends/
- type: indicator
- pine_id: PUB;17be8e2fa7d349fb8f5f0228045a3099
- version: 1.0

## Description

Stryk: ATR Trends

Everything in this tool is measured in units of one master ATR. Change that one length and the whole indicator retunes together — the candle coloring, the compression reads, the reversal checks, and the trailing stop all use the same yardstick.

What it is 

At the center is a composite value line: a weighted blend of seven EMAs (8 through 144) and a rolling volume-weighted average. The VWMA leans the line toward where volume actually transacted, and its window can auto-size to your chart timeframe so it covers a similar span whether you're on the 1-minute or the daily. Price tends to return to this line, and the whole tool reads price against it.

Candles color by distance from that line. Near it, they're neutral. The further price stretches away, the deeper the up or down color gets, reaching full saturation at a set ATR distance. A signal can also flip the candles to a solid color temporarily, so you can run the tool with every line hidden and still get the read from the candles alone.

The engines

Compression coil. A dedicated ATR is ranked into a percentile. When it compresses into the bottom of its range, the market is coiled. When the coil releases and price is at the same time over-extended from the composite, a fade marker prints back toward the line. One fire per release, inside a short window. A second marker can print if volume steps up afterward.

Compression release. A separate lens using Donchian width (highest high minus lowest low) ranked in the same percentile framework. When the envelope tightens and then releases, a marker prints in the direction of an ATR-normalized momentum read. This is not a Bollinger-inside-Keltner squeeze — it's built entirely in percentile space.

Reversal engine. Once price has stretched a set number of ATRs from the composite, the engine watches for the turn. It counts four independent checks: an RSI rollover, a close back inside the band around the line, a confirmed pivot, and a volume climax. When enough agree, a reversal marker prints — once per leg, and it won't re-arm until price comes back near the line. Pivots confirm after their right-side bars complete, so that check is delayed by design rather than repainting.

Whale and spike. A per-bar order-flow estimate built from close location and volume. Two whale reads fire from it: a fade of a volume spike where the delta ran against the move, and absorption — heavy delta into a bar that barely moved. Both can be gated by trend so you don't fade into a strong stretch. Bars at the extreme relative-volume threshold print a spike marker instead; the whale band sits below that threshold, so the two never fire on the same bar. The spike is an attention marker, not a directional call.

ATR trailing stop. A ratcheting volatility stop, either always on or armed by a coil fire. The default runs a tight 3/3 configuration as the real line, with a wider manual configuration drawn faintly beside it as a reference. The stop's ATR can be pulled from a higher timeframe, lookahead-off.

Volume participation. A volume EMA normalized 0 to 100 against its own recent range. Fifty is average. The extremes tint the background and the value sits in the status box.

Status box. One table on the chart reports every active engine on the last bar — stop side and level, compression stage, last reversal with its confluence count, last release, whale scenario, last spike, and participation. Rows light up when fresh and dim after a few bars. Every row can be toggled and the layout can run stacked or horizontal.

How I use it

Candle color is the base read. The coil and release tell me volatility compressed and which way it resolved. The reversal and whale engines flag exhaustion at the stretched edges. The trailing stop manages the rest. Each engine is independent — turn off what you don't use.

Originality

The rolling VWMA is the plain public-domain construction, sum(price x volume) / sum(volume), implemented directly with no external library. The compression framework — ATR-percentile coil plus Donchian-width release, scored in one percentile system — is original construction. Native built-ins only. Non-repainting on closed bars: higher-timeframe requests are lookahead-off on confirmed values, and alerts are meant for once-per-bar-close.

Notes

Built for standard candles only. The volume engines need a symbol with real volume, and the whale delta is an estimate from bar structure, not exchange order-flow data. This is an analysis tool, not advice, and it doesn't predict anything.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Es-Sniper
//
// Stryk Trends. A single recursive volume-weighted moving average (eVWMA)
// is the reference line for the whole tool: the 3-color candle read, a compression
// coil + stretch fade, a consensus reversal engine, volume-confirm, an extreme-
// volume spike marker, an ATR trailing stop, and an ATR band-expansion read all
// measure distance off this one line in master-ATR units. Native built-ins only;
// non-repainting on closed bars. Built for STANDARD candles.
//
// eVWMA: ev = (1-w)*ev[1] + w*src, w = min(volume*gain/vsum, 1), floored by an
// EMA anchor: line = (1-floor)*ev + floor*ema(src, period). Original construction;
// no external library.

//@version=6
indicator("Stryk Trends", "Stryk: Trends", overlay = true, max_lines_count = 500, max_labels_count = 500, max_bars_back = 5000)

// ════════════════════════════════════════════════════════════════════════════
// 0 · MASTER SWITCHBOARD
// ════════════════════════════════════════════════════════════════════════════
g0 = "0 · Master switchboard"
mSigAll   = input.bool(true, "Signals — all markers", group = g0, tooltip = "Master hide for every emoji marker. Effects (candle colour, box, alerts) still fire.")
mSigCoil  = input.bool(true, "      Coil fade", group = g0, tooltip = "Hide the coil-fade marker on the chart only. The read still flips candles, drives the status box and fires alerts.")
mSigRev   = input.bool(true, "      Reversal", group = g0, tooltip = "Hide the reversal marker on the chart only. The read still flips candles, drives the box and fires alerts.")
mSigVol   = input.bool(true, "      Volume confirm", group = g0, tooltip = "Hide the volume-confirm marker on the chart only. The read still drives the box and alerts.")
mSigSpike = input.bool(true, "      Spike (extreme vol)", group = g0, tooltip = "Hide the extreme-volume spike marker on the chart only. The read still drives the box and its alert.")
mSigAtr   = input.bool(true, "      ATR band expansion", group = g0, tooltip = "Hide the ATR band-expansion marker on the chart only. The read still drives the box and its alert.")
mShowTrail = input.bool(true, "ATR trailing stop", group = g0, tooltip = "Hide the ATR trailing-stop line, caps, exit marks and price tags on the chart. The status box and alerts are unaffected.")

// ════════════════════════════════════════════════════════════════════════════
// 1 · MASTER ATR
// ════════════════════════════════════════════════════════════════════════════
gm = "1 · Master"
mAtrLen = input.int(14, "Master ATR length", minval = 1, maxval = 200, group = gm, tooltip = "One ATR drives every distance the tool measures: candle colour, the stretch fade, the reversal bands, and the trailing stop.")
mAtr = ta.atr(mAtrLen)

// ════════════════════════════════════════════════════════════════════════════
// 2 · eVWMA LINE + 3-COLOR CANDLES
// ════════════════════════════════════════════════════════════════════════════
g1 = "2 · eVWMA line + candles"
showLine  = input.bool(true, "Show eVWMA line", group = g1, tooltip = "Draw the eVWMA line itself. Off keeps the candle colouring and every signal working - it only hides the line.")
evSrc     = input.source(hlc3, "eVWMA source", group = g1, tooltip = "Price fed to the volume-weighted average. Default hlc3.")
evPeriod  = input.int(60, "Volume window (period)", minval = 2, maxval = 500, group = g1, tooltip = "Bars in the trailing volume sum that sets the per-bar weight. Also the EMA-anchor length.")
evGain    = input.float(3.0, "Volume sensitivity (gain)", minval = 0.5, maxval = 10.0, step = 0.5, group = g1, tooltip = "Scales how hard each bar's volume pulls the line. Higher = faster / more reactive to volume. 3 tracks tightest in testing.")
evFloor   = input.float(0.5, "EMA floor mix", minval = 0.0, maxval = 1.0, step = 0.05, group = g1, tooltip = "Blends a plain EMA under the volume line: 0 = pure eVWMA (reactive), 0.5 = half-EMA (smoother, steadier), 1 = plain EMA. 0.5 is the calm-line default.")
lineW     = input.int(3, "Line width", minval = 1, maxval = 8, group = g1, tooltip = "Thickness of the eVWMA line, in pixels.")
priceFull = input.float(2.5, "Color: full saturation at (x ATR)", minval = 0.1, step = 0.1, group = g1, tooltip = "Candle/line colour reaches full green/red at this ATR distance from the eVWMA.")
priceFlat = input.float(1.0, "Color: flat under (x ATR)", minval = 0.0, step = 0.1, group = g1, tooltip = "Within this ATR distance the read is flat (teal).")
priceSmooth = input.int(2, "Color: distance smoothing", minval = 1, maxval = 50, group = g1, tooltip = "EMA smoothing on the price-vs-line distance. 1 = none.")
cGreen    = input.color(#00ff88, "Line up", inline = "lc", group = g1, tooltip = "Line colour when price is stretched ABOVE the eVWMA (up read).")
cTeal     = input.color(#00bcd4, "Line flat", inline = "lc", group = g1, tooltip = "Line colour when price sits within the flat band around the eVWMA (neutral).")
cRed      = input.color(#ff3355, "Line down", inline = "lc", group = g1, tooltip = "Line colour when price is stretched BELOW the eVWMA (down read). The line fades smoothly between these three by ATR distance.")
showCandles = input.bool(true, "Color the candles", group = g1, tooltip = "Paint candles by how far price is from the eVWMA - the same read as the line.")
bullCol   = input.color(#00ff88, "Candle up", inline = "cc", group = g1, tooltip = "Candle colour when price is stretched above the eVWMA.")
flatCol   = input.color(#00bcd4, "Candle flat", inline = "cc", group = g1, tooltip = "Candle colour when price is near the eVWMA (neutral).")
bearCol   = input.color(#ff3355, "Candle down", inline = "cc", group = g1, tooltip = "Candle colour when price is stretched below the eVWMA. Candles fade between these three, or snap to a solid colour on a signal flip.")

// ── eVWMA engine (recursive volume-weighted, EMA-floored) ──
vsum   = math.sum(volume, evPeriod)
wRaw   = vsum > 0 ? volume * evGain / vsum : na
wv     = na(wRaw) ? 0.0 : math.min(wRaw, 1.0)
evAnchor = ta.ema(evSrc, evPeriod)
var float ev = na
ev := na(ev[1]) ? evSrc : (1.0 - wv) * ev[1] + wv * evSrc
evLine = (1.0 - evFloor) * ev + evFloor * evAnchor

// ── 3-color read: price vs eVWMA in master ATR ──
dP    = mAtr > 0 ? (close - evLine) / mAtr : 0.0
dPs   = priceSmooth > 1 ? ta.ema(dP, priceSmooth) : dP
rampP = math.max(priceFull - priceFlat, 0.0001)
adjP  = dPs > priceFlat ? dPs - priceFlat : dPs < -priceFlat ? dPs + priceFlat : 0.0
fracP = math.min(math.abs(adjP) / rampP, 1.0) * (adjP >= 0 ? 1.0 : -1.0)
gposP = 0.5 + 0.5 * fracP
lineBase = gposP >= 0.5 ? color.from_gradient(gposP, 0.5, 1.0, cTeal, cGreen) : color.from_gradient(gposP, 0.0, 0.5, cRed, cTeal)
candBase = gposP >= 0.5 ? color.from_gradient(gposP, 0.5, 1.0, flatCol, bullCol) : color.from_gradient(gposP, 0.0, 0.5, bearCol, flatCol)

stretchATR = dP   // price distance from eVWMA in ATR units

// ════════════════════════════════════════════════════════════════════════════
// 3 · SIGNAL MARKERS (emoji + connectors + per-session fall-off)
// ════════════════════════════════════════════════════════════════════════════
g_sig = "3 · Signal markers"
sigDist    = input.float(1.0, "Marker distance from candle (x ATR)", minval = 0.0, step = 0.1, group = g_sig, tooltip = "How far each emoji marker sits off the wick, scaled by the master ATR so it stays proportional on any timeframe.")
sigGap     = input.float(0.5, "Wick gap (x ATR)", minval = 0.0, step = 0.05, group = g_sig, tooltip = "The connector line stops this far short of the wick (in ATR) so the wick tip stays visible.")
sigConnect = input.bool(true, "Connect markers to candle", group = g_sig, tooltip = "Draw a thin vertical line from each emoji to its candle.")
sigLineW   = input.int(1, "Connector width", minval = 1, maxval = 4, group = g_sig, tooltip = "Thickness of the emoji connector line, in pixels.")
labelMode  = input.string("Hover", "Emoji info label", options = ["Static", "Hover"], group = g_sig, tooltip = "Static = readable text on phone. Hover = tooltip on desktop, cleaner chart.")
sigInfoGap = input.float(0.9, "Info label gap (x ATR)", minval = 0.0, step = 0.1, group = g_sig, tooltip = "For the Static info label, how far beyond the emoji it sits, in ATR. Ignored in Hover mode.")
sigFalloff = input.bool(true, "Markers: current session only", group = g_sig, tooltip = "ON: clear all prior markers at the daily roll. OFF: keep through history (oldest drop at the 500 cap).")
sigEmojiCoil  = input.string("🚨", "Coil fade", group = g_sig, tooltip = "Emoji used for the coil-fade marker. Replace with any character.")
sigEmojiRev   = input.string("🔄", "Reversal", group = g_sig, tooltip = "Emoji used for the reversal marker. Replace with any character.")
sigEmojiVol   = input.string("💥", "Volume confirm", group = g_sig, tooltip = "Emoji used for the volume-confirm marker. Replace with any character.")
sigEmojiSpike = input.string("⚡", "Spike (extreme vol)", group = g_sig, tooltip = "Emoji used for the extreme-volume spike marker. Replace with any character.")
sigEmojiAtr   = input.string("🎯", "ATR expansion", group = g_sig, tooltip = "Emoji used for the ATR band-expansion marker. Replace with any character.")

var array<label> sigLabels = array.new<label>()
var array<line>  sigLines  = array.new<line>()

f_sigMark(bool fire, int dir, string emo, color col, string info) =>
    if fire and mSigAll
        yE = dir == 1 ? low - sigDist * mAtr : high + sigDist * mAtr
        yS = dir == 1 ? low - sigGap  * mAtr : high + sigGap  * mAtr
        tip = labelMode == "Hover" ? info : ""
        lb = label.new(bar_index, yE, emo, style = label.style_none, textcolor = col, size = size.normal, tooltip = tip)
        array.push(sigLabels, lb)
        if labelMode == "Static" and info != ""
            yI = dir == 1 ? low - (sigDist + sigInfoGap) * mAtr : high + (sigDist + sigInfoGap) * mAtr
            li = label.new(bar_index, yI, info, style = label.style_none, textcolor = col, size = size.small)
            array.push(sigLabels, li)
        if sigConnect
            ln = line.new(bar_index, yS, bar_index, yE, color = col, width = sigLineW)
            array.push(sigLines, ln)
    0

if sigFalloff and timeframe.change("D")
    while array.size(sigLabels) > 0
        label.delete(array.shift(sigLabels))
    while array.size(sigLines) > 0
        line.delete(array.shift(sigLines))

// ════════════════════════════════════════════════════════════════════════════
// 4 · CANDLE COLOR FLIP (which signals may recolor the candles)
// ════════════════════════════════════════════════════════════════════════════
g_flip = "4 · Candle color flip"
flipCoil  = input.bool(true,  "Coil fade flips candles", group = g_flip, tooltip = "Let a coil-fade fire recolour the candles green/red until price crosses back through the eVWMA or the flip hold runs out.")
flipRev   = input.bool(true,  "Reversal flips candles", group = g_flip, tooltip = "Let a reversal fire recolour the candles until price crosses back through the eVWMA or the flip hold runs out.")
flipVol   = input.bool(false, "Volume-confirm flips candles", group = g_flip, tooltip = "Largely redundant with the coil flip. Off by default.")
flipSpike = input.bool(false, "Spike flips candles", group = g_flip, tooltip = "Extreme-volume spike. Off by default - marker still shows.")
ovrHold   = input.int(5, "Flip hold (max bars)", minval = 1, maxval = 50, group = g_flip, tooltip = "A flip auto-clears once price crosses back through the eVWMA or this many bars pass.")

// ════════════════════════════════════════════════════════════════════════════
// 5 · COMPRESSION COIL + STRETCH FADE
// ════════════════════════════════════════════════════════════════════════════
g_coil = "5 · Coil fade"
showSignals = input.bool(true, "Enable coil fade arrows", group = g_coil, tooltip = "ATR-percentile compression (coil) + a fade arrow when price is over-extended from the eVWMA on the coil release. Fades back toward the line (BUY below / SELL above).")
coilAtrLen  = input.int(23, "Coil ATR length", minval = 1, maxval = 200, group = g_coil, tooltip = "Length of the ATR the coil measures. This ATR is ranked into a percentile to detect compression.")
rangeLook   = input.int(100, "Percentile lookback", minval = 10, maxval = 500, group = g_coil, tooltip = "Bars used to rank the ATR (coil) percentile.")
coilPct     = input.float(14.0, "Coil percentile (<= is coiled)", minval = 1.0, maxval = 50.0, step = 1.0, group = g_coil, tooltip = "Compression trigger. The coil is 'coiled' when its ATR percentile is at or below this. Lower = only the tightest ranges count.")
tightPct    = input.float(6.0, "Tight percentile", minval = 1.0, maxval = 50.0, step = 1.0, group = g_coil, tooltip = "A stricter percentile reported as TIGHTENING in the box - the deepest part of a coil, at or below this rank.")
stretchMin  = input.float(3.3, "Fade: min stretch (x ATR)", minval = 0.5, step = 0.1, group = g_coil, tooltip = "Fade fires only when price is at least this far from the eVWMA. Data on this line (floor 0.5): the 3.0-4.0 ATR band is where mean-reversion is strongest.")
stretchMax  = input.float(4.0, "Fade: max stretch ceiling (x ATR)", minval = 1.0, step = 0.1, group = g_coil, tooltip = "Hard ceiling — the fade is DISABLED beyond this distance. Held across both test windows: past ~4 ATR the stretch stops reverting and becomes continuation, so fading it loses. 0 disables the ceiling.")
fireWindow  = input.int(5, "Fire window after release (bars)", minval = 1, maxval = 50, group = g_coil, tooltip = "After a coil releases, the fade may fire only within this many bars. Outside the window the release is stale.")
sigBias     = input.string("Both", "Coil bias", options = ["Both", "Longs only", "Shorts only"], group = g_coil, tooltip = "Restrict coil-fade arrows to one side. Both = fade over-extensions up and down.")
sigAllowLong  = sigBias != "Shorts only"
sigAllowShort = sigBias != "Longs only"
arrowBull   = input.color(#00ff88, "Buy arrow", inline = "ar", group = g_coil, tooltip = "Colour of the buy (fade-up) coil arrow.")
arrowBear   = input.color(#ff3355, "Sell arrow", inline = "ar", group = g_coil, tooltip = "Colour of the sell (fade-down) coil arrow.")
useVolConfirm = input.bool(true, "Volume confirmation (2nd arrow)", group = g_coil, tooltip = "Adds a second arrow when volume surges after the first arrow. Bonus - does not block the first arrow.")
volThresh   = input.float(50.0, "Vol-confirm surge (%)", minval = 1.0, maxval = 500.0, step = 5.0, group = g_coil, tooltip = "How much recent volume must rise over the pre-fire baseline to print a volume-confirm arrow, as a percent.")
volLook     = input.int(2, "Vol-confirm recent length", minval = 1, maxval = 50, group = g_coil, tooltip = "Length of the 'recent volume' average compared against the baseline.")
coilVolLook = input.int(10, "Vol-confirm baseline length", minval = 1, maxval = 100, group = g_coil, tooltip = "Length of the volume baseline captured at the moment the coil fires.")
confirmWin  = input.int(10, "Vol-confirm window (bars)", minval = 1, maxval = 50, group = g_coil, tooltip = "How many bars after a coil fire the volume-confirm arrow may still appear.")
volConfCol  = input.color(#00e5ff, "Vol-confirm color", group = g_coil, tooltip = "Colour of the volume-confirm marker.")

tr0 = ta.tr(true)
catr = ta.sma(tr0, coilAtrLen)
atrMin = ta.lowest(catr, rangeLook)
atrMax = ta.highest(catr, rangeLook)
atrPct = atrMax > atrMin ? (catr - atrMin) / (atrMax - atrMin) * 100.0 : 50.0
coiled = atrPct <= coilPct
var int coilRun = 0
coilRun := coiled ? coilRun + 1 : 0
tight  = atrPct <= tightPct
released = coiled[1] and not coiled and nz(coilRun[1]) >= 1

var int sinceRelease = 9999
var bool firedThisRelease = false
if released
    sinceRelease := 0
    firedThisRelease := false
else
    sinceRelease := sinceRelease + 1
inFireWin = sinceRelease < fireWindow

// stretch band gate: fade only inside [stretchMin, stretchMax]; 0 ceiling = no upper bound
inBandLong  = stretchATR <= -stretchMin and (stretchMax <= 0 or stretchATR >= -stretchMax)
inBandShort = stretchATR >=  stretchMin and (stretchMax <= 0 or stretchATR <=  stretchMax)
fireLong  = showSignals and inFireWin and not firedThisRelease and inBandLong  and sigAllowLong
fireShort = showSignals and inFireWin and not firedThisRelease and inBandShort and sigAllowShort
if fireLong or fireShort
    firedThisRelease := true

lightState = (fireLong or fireShort) ? "FIRE" : tight ? "TIGHTENING" : coiled ? "COILING" : "OFF"

// ════════════════════════════════════════════════════════════════════════════
// 6 · REVERSAL ENGINE (consensus of 2)
// ════════════════════════════════════════════════════════════════════════════
g3 = "6 · Reversal engine"
showRev  = input.bool(true, "Enable reversal engine", group = g3, tooltip = "Turns a stretched leg (off the eVWMA) back the other way when at least two of: RSI rollover, band re-entry, pivot, volume climax agree.")
nStretch = input.float(2.5, "Reversal: leg stretch (x ATR)", minval = 0.5, step = 0.1, group = g3, tooltip = "How far a leg must stretch from the eVWMA (in ATR) before the reversal engine looks for a turn against it.")
nReset   = input.float(2.0, "Reversal: reset inside (x ATR)", minval = 0.1, step = 0.1, group = g3, tooltip = "When price returns within this ATR distance of the eVWMA, the reversal engine resets and re-arms for the next leg.")
rsiLen   = input.int(55, "Reversal RSI length", minval = 2, maxval = 200, group = g3, tooltip = "Length of the RSI used as one of the four reversal confluence checks.")
rsiOB    = input.int(60, "RSI overbought", minval = 50, maxval = 100, group = g3, tooltip = "RSI level that counts as overbought for the reversal rollover check (short side).")
rsiOS    = input.int(40, "RSI oversold", minval = 0, maxval = 50, group = g3, tooltip = "RSI level that counts as oversold for the reversal rollover check (long side).")
bandMult = input.float(2.5, "Reversal band (x ATR from line)", minval = 0.5, step = 0.1, group = g3, tooltip = "Distance of the reversal setup band from the eVWMA, in ATR. A close back inside the band is one confluence check.")
pvLeft   = input.int(3, "Pivot left", minval = 1, maxval = 20, group = g3, tooltip = "Bars to the left of a pivot for the reversal pivot check.")
pvRight  = input.int(3, "Pivot right", minval = 1, maxval = 20, group = g3, tooltip = "Bars to the right of a pivot. A pivot only confirms after this many bars - non-repainting but delayed.")
revVolLen  = input.int(50, "Reversal vol length", minval = 2, maxval = 200, group = g3, tooltip = "Length of the average volume used for the reversal volume-climax check.")
revVolMult = input.float(2.0, "Reversal vol climax (x avg)", minval = 1.0, step = 0.1, group = g3, tooltip = "Volume must exceed this multiple of its average to count as a climax (one confluence check).")
minConf  = input.int(2, "Min confluence (of 4)", minval = 1, maxval = 4, group = g3, tooltip = "How many of the four checks (RSI rollover, band re-entry, pivot, volume climax) must agree before a reversal prints. 2 is balanced.")

reset = math.abs(stretchATR) < nReset
var float peakUp = 0.0
var float peakDn = 0.0
var bool  firedShort = false
var bool  firedLong  = false
peakUp := reset ? 0.0 : math.max(nz(peakUp), stretchATR)
peakDn := reset ? 0.0 : math.min(nz(peakDn), stretchATR)
if reset
    firedShort := false
    firedLong  := false
upLeg = peakUp >=  nStretch
dnLeg = peakDn <= -nStretch

rsiV = ta.rsi(close, rsiLen)
ub = evLine + bandMult * mAtr
lb = evLine - bandMult * mAtr
phZ = ta.pivothigh(high, pvLeft, pvRight)
plZ = ta.pivotlow(low,  pvLeft, pvRight)
vSma = ta.sma(volume, revVolLen)
oscShort  = rsiV[1] >= rsiOB and rsiV < rsiV[1]
bandShort = high[1] >= ub[1] and close < ub
pivShort  = not na(phZ)
oscLong   = rsiV[1] <= rsiOS and rsiV > rsiV[1]
bandLong  = low[1] <= lb[1] and close > lb
pivLong   = not na(plZ)
volClim   = volume >= revVolMult * vSma
confShort = (oscShort ? 1 : 0) + (bandShort ? 1 : 0) + (pivShort ? 1 : 0) + (volClim ? 1 : 0)
confLong  = (oscLong  ? 1 : 0) + (bandLong  ? 1 : 0) + (pivLong  ? 1 : 0) + (volClim ? 1 : 0)
revShort = showRev and upLeg and confShort >= minConf and not firedShort
revLong  = showRev and dnLeg and confLong  >= minConf and not firedLong
if revShort
    firedShort := true
if revLong
    firedLong := true

// ════════════════════════════════════════════════════════════════════════════
// 7 · SPIKE (extreme volume)
// ════════════════════════════════════════════════════════════════════════════
g_spk = "7 · Spike (extreme vol)"
spkOn    = input.bool(true, "Enable spike marker", group = g_spk, tooltip = "Marks bars at or above the RVOL threshold, directioned by candle body. A marker for attention, not a directional signal - off by default for candle flips.")
spkRvolLen = input.int(20, "Volume average length", minval = 2, group = g_spk, tooltip = "Length of the average volume that RVOL is measured against.")
spkThresh  = input.float(5.0, "Spike threshold (x RVOL)", minval = 1.5, step = 0.5, group = g_spk, tooltip = "A bar is marked as a spike when its volume is at least this multiple of the average (RVOL).")
spkBullCol = input.color(#00e676, "Spike bull", inline = "spkc", group = g_spk, tooltip = "Spike colour when the bar closes up.")
spkBearCol = input.color(#ff1744, "Spike bear", inline = "spkc", group = g_spk, tooltip = "Spike colour when the bar closes down.")

spkAvgVol = ta.sma(volume, spkRvolLen)
spkRvol   = spkAvgVol > 0 ? volume / spkAvgVol : 0.0
spkExtreme = spkRvol >= spkThresh
spkBull = spkOn and spkExtreme and close >= open
spkBear = spkOn and spkExtreme and close <  open


// ════════════════════════════════════════════════════════════════════════════
// 9 · ATR TRAILING STOP + BAND EXPANSION
// ════════════════════════════════════════════════════════════════════════════
g_ts = "9 · ATR trailing stop"
tsOn = input.bool(true, "Enable ATR trailing stop", group = g_ts, tooltip = "A volatility trailing stop a number of ATRs behind price that ratchets in your favour.")
tsMode = input.string("Always on", "Trail mode", options = ["Always on", "On signals"], group = g_ts, tooltip = "Always on = continuous trail that flips with price. On signals = arms only on a coil fire.")
tsBias = input.string("Both", "Trail bias", options = ["Both", "Longs only", "Shorts only"], group = g_ts, tooltip = "Restrict the trailing stop to one side, or run both.")
tsAllowLong  = tsBias != "Shorts only"
tsAllowShort = tsBias != "Longs only"
tsOptimal = input.bool(true, "Optimal ATR (3/3)", group = g_ts, tooltip = "ON = length 3 / multiplier 3 (tighter, exits sooner). OFF = manual length/mult below.")
tsAtrLen = input.int(5, "Manual ATR length", minval = 1, maxval = 100, group = g_ts, tooltip = "ATR length for the manual (wider) trail. Used when Optimal 3/3 is off, and for the faded manual visual line.")
tsMult   = input.float(5.0, "Manual ATR multiplier", minval = 0.5, step = 0.5, group = g_ts, tooltip = "ATR multiplier for the manual trail. Higher = the stop sits further from price and flips less often.")
tsBoth   = input.bool(true, "Show both (3/3 real + manual visual)", group = g_ts, tooltip = "Draw the 3/3 trail as the real stop (tags/alerts follow it) plus the manual line as a faded visual reference.")
tsUseHtf = input.bool(true, "Use higher-timeframe ATR", group = g_ts, tooltip = "Size the trail from a higher-timeframe ATR while plotting on your chart. Lookahead-safe.")
tsHtfTf  = input.timeframe("", "ATR timeframe", group = g_ts, tooltip = "'Chart' = current. Raise it (e.g. 60) for a smoother trail.")
tsLongColor  = input.color(#ffffff, "Trail color (long)", group = g_ts, tooltip = "Colour of the trailing stop while it is below price (long).")
tsShortColor = input.color(#ffd700, "Trail color (short)", group = g_ts, tooltip = "Colour of the trailing stop while it is above price (short).")
tsExitColor  = input.color(#ff4d6d, "Exit marker (✕ / tag)", group = g_ts, tooltip = "Colour of the exit mark and the exit price tag.")
tsShowTags   = input.bool(true, "Show entry / exit price tags", group = g_ts, tooltip = "Print small entry and exit price tags at the trade points.")
atrTsOn      = input.bool(true, "ATR band-expansion signal", group = g_ts, tooltip = "Fires a marker + box row when a new trailing-stop band opens wider than the recent average gap between flips — volatility-expansion-at-trend-start. Does not recolour candles.")
atrTsN       = input.int(10, "Expansion lookback (flips)", minval = 2, maxval = 100, group = g_ts, tooltip = "How many recent band-opens feed the rolling average gap that expansion is measured against.")
atrTsWarmup  = input.int(3, "Warmup flips before firing", minval = 1, maxval = 50, group = g_ts, tooltip = "No expansion can fire until at least this many band gaps have been collected.")
atrTsThresh  = input.float(2.0, "Expansion threshold (x avg gap)", minval = 1.0, maxval = 5.0, step = 0.05, group = g_ts, tooltip = "A new band fires when its opening gap is at least this multiple of the recent average. ~2.0 isolates the standout opens.")
atrTsBuyCol  = input.color(#00e5ff, "Expansion marker / box (buy)", inline = "atrx", group = g_ts, tooltip = "Expansion marker and box colour when the new band opens on the long side.")
atrTsSellCol = input.color(#ff2bd6, "Expansion marker / box (sell)", inline = "atrx", group = g_ts, tooltip = "Expansion marker and box colour when the new band opens on the short side.")

// ── volume confirmation (computed here so it can drive the flip) ──
var float coilVol = na
var int   barsSinceFire = 9999
var int   pendingDir = 0
var bool  volConfirmed = false
var bool  fireActive = false
coilVolAvg = ta.sma(volume, coilVolLook)
if fireLong or fireShort
    coilVol := coilVolAvg[1]
    barsSinceFire := 0
    pendingDir := fireLong ? 1 : -1
    volConfirmed := false
    fireActive := true
else
    barsSinceFire := barsSinceFire + 1
if barsSinceFire > confirmWin
    pendingDir := 0
    fireActive := false
recentVol = ta.sma(volume, volLook)
volPickup = fireActive and not na(coilVol) and coilVol > 0 and recentVol >= coilVol * (1 + volThresh / 100.0)
volConfirmLong  = showSignals and useVolConfirm and fireActive and pendingDir ==  1 and volPickup and not volConfirmed and barsSinceFire >= 1 and barsSinceFire <= confirmWin
volConfirmShort = showSignals and useVolConfirm and fireActive and pendingDir == -1 and volPickup and not volConfirmed and barsSinceFire >= 1 and barsSinceFire <= confirmWin
if volConfirmLong or volConfirmShort
    volConfirmed := true

// ── candle flip override state machine ──
longOverrideTrig  = (flipCoil and fireLong) or (flipRev and revLong) or (flipSpike and spkBull) or (flipVol and volConfirmLong)
shortOverrideTrig = (flipCoil and fireShort) or (flipRev and revShort) or (flipSpike and spkBear) or (flipVol and volConfirmShort)
var int ovr = 0
var int ovrBars = 0
baseSign = adjP > 0 ? 1 : adjP < 0 ? -1 : 0
curSign  = ovr != 0 ? ovr : baseSign
longFlip  = longOverrideTrig  and curSign != 1
shortFlip = shortOverrideTrig and curSign != -1
freshSnap = longFlip or shortFlip
if longFlip
    ovr := 1
    ovrBars := 0
if shortFlip
    ovr := -1
    ovrBars := 0
if ovr != 0 and not freshSnap
    ovrBars := ovrBars + 1
    if ovr == 1 and (dP > 0 or ovrBars >= ovrHold)
        ovr := 0
    if ovr == -1 and (dP < 0 or ovrBars >= ovrHold)
        ovr := 0
useOvr    = ovr != 0
lineColor = lineBase
candTrend = useOvr ? (ovr == 1 ? bullCol : bearCol) : candBase
candleCol = showCandles ? candTrend : na

// ── trailing-stop core ──
tsAlwaysOn  = tsMode == "Always on"
tsUse33     = tsOptimal or tsBoth
tsAtrLenEff = tsUse33 ? 3 : tsAtrLen
tsMultEff   = tsUse33 ? 3.0 : tsMult
tsHtfTfEff  = tsHtfTf == "" ? timeframe.period : tsHtfTf
tsAtrHtf = request.security(syminfo.tickerid, tsHtfTfEff, ta.sma(ta.tr(true), tsAtrLenEff)[1], lookahead = barmerge.lookahead_off)
tsAtr  = tsUseHtf ? tsAtrHtf : ta.sma(ta.tr(true), tsAtrLenEff)
tsLoss = tsMultEff * tsAtr
var float tsLine  = na
var float tsEntry = na
var float tsExitPrice = na
var int   tsDir   = 0
var bool  tsArmed = false
if tsAlwaysOn
    float prevA = nz(tsLine[1], close)
    tsLine := close > prevA and close[1] > prevA ? math.max(prevA, close - tsLoss) : close < prevA and close[1] < prevA ? math.min(prevA, close + tsLoss) : close > prevA ? close - tsLoss : close + tsLoss
    newDir = close > tsLine ? 1 : -1
    if newDir != tsDir
        tsEntry := close
    tsDir  := newDir
    tsArmed := true
else
    if fireLong and tsAllowLong
        tsArmed := true
        tsDir   := 1
        tsLine  := close - tsLoss
        tsEntry := close
        tsExitPrice := na
    else if fireShort and tsAllowShort
        tsArmed := true
        tsDir   := -1
        tsLine  := close + tsLoss
        tsEntry := close
        tsExitPrice := na
    else if tsArmed
        if tsDir == 1
            stopWas = nz(tsLine[1])
            tsLine := math.max(stopWas, close - tsLoss)
            if close < stopWas
                tsArmed := false
                tsExitPrice := stopWas
        else
            stopWas = nz(tsLine[1])
            tsLine := math.min(stopWas, close + tsLoss)
            if close > stopWas
                tsArmed := false
                tsExitPrice := stopWas
tsDirOk  = (tsDir == 1 and tsAllowLong) or (tsDir == -1 and tsAllowShort)

// ── ATR band-expansion engine ──
var array<float> atrGaps = array.new<float>()
atrDirChg   = tsDir != nz(tsDir[1], 0)
atrReArm    = tsArmed and not tsArmed[1]
atrNewBand  = atrTsOn and tsOn and tsArmed and (atrDirChg or atrReArm)
atrGap      = atrNewBand and not na(tsLine[1]) ? math.abs(tsLine - tsLine[1]) : na
atrAvgPrev  = array.size(atrGaps) >= atrTsWarmup ? array.avg(atrGaps) : na
atrExpFired = atrNewBand and not na(atrGap) and not na(atrAvgPrev) and atrGap > atrAvgPrev * atrTsThresh
atrExpDir   = tsDir
atrRatio    = atrExpFired and atrAvgPrev > 0 ? atrGap / atrAvgPrev : na
if atrNewBand and not na(atrGap)
    array.push(atrGaps, atrGap)
    if array.size(atrGaps) > atrTsN
        array.shift(atrGaps)

// ════════════════════════════════════════════════════════════════════════════
// 10 · STATUS BOX
// ════════════════════════════════════════════════════════════════════════════
g_box = "10 · Status box"
showBox = input.bool(true, "Show status box", group = g_box, tooltip = "Show the on-chart status box that summarises every active engine on the last bar.")
boxPos  = input.string("Bottom Right", "Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group = g_box, tooltip = "Corner or edge of the chart where the status box sits.")
boxSize = input.string("Tiny", "Size", options = ["Tiny", "Small", "Normal", "Large"], group = g_box, tooltip = "Overall text size of the status box.")
boxLayout = input.string("Stacked", "Layout", options = ["Stacked", "Horizontal", "Mobile grid"], group = g_box, tooltip = "Stacked = vertical rows (dot - label - value). Horizontal = one strip. Mobile grid = compact colour-coded code+value cells sized for a phone.")
gridCols = input.int(4, "Mobile grid columns", minval = 2, maxval = 6, group = g_box, tooltip = "Columns in the Mobile grid layout. 4 fits most phones; drop to 3 on a narrow screen.")
showLabels = input.bool(true, "Show text labels", group = g_box, tooltip = "Show the text labels in Stacked / Horizontal layouts. The Mobile grid always uses short codes.")
bxTrail = input.bool(true, "Rows: trailing stop + expansion", group = g_box, tooltip = "Show the trailing-stop and ATR-expansion rows in the box.")
bxComp  = input.bool(true, "Rows: compression stage", group = g_box, tooltip = "Show the compression-stage row (COILING / TIGHTENING / FIRE / READY).")
bxTurn  = input.bool(true, "Rows: reversal / spike", group = g_box, tooltip = "Show the reversal and spike rows in the box.")
tighteningColor = input.color(#ffd700, "Tightening light", group = g_box, tooltip = "Box colour for the deepest compression stage (TIGHTENING).")
boxBg = input.color(color.new(#0a1a3a, 20), "Box background", group = g_box, tooltip = "Background colour of the status box.")
txtColor = input.color(#ffffff, "Box text", group = g_box, tooltip = "Default text colour inside the box.")
offColor = input.color(#2a2e39, "Box off / dim", group = g_box, tooltip = "Colour used for a dimmed / idle box row.")
boxBorder = input.color(#000000, "Box border", group = g_box, tooltip = "Colour of the box border.")

coilingColor = arrowBear
fireColor = arrowBull
posLookup = boxPos == "Top Right" ? position.top_right : boxPos == "Top Left" ? position.top_left : boxPos == "Bottom Right" ? position.bottom_right : boxPos == "Bottom Left" ? position.bottom_left : boxPos == "Middle Right" ? position.middle_right : position.middle_left
lightSize = boxSize == "Tiny" ? size.small : boxSize == "Small" ? size.normal : boxSize == "Large" ? size.huge : size.large
txtSize = boxSize == "Tiny" ? size.tiny : boxSize == "Small" ? size.small : boxSize == "Large" ? size.large : size.normal
pctSize = boxSize == "Tiny" ? size.tiny : boxSize == "Small" ? size.tiny : boxSize == "Large" ? size.normal : size.small

f_boxPut(table _t, int _i, string _short, string _mk, color _mkC, string _lb, color _lbC, string _vl, color _vlC) =>
    if boxLayout == "Mobile grid"
        _r = int(_i / gridCols)
        _c = _i % gridCols
        _txt = _short + (_vl != "" ? " " + _vl : "")
        table.cell(_t, _c, _r, _txt, text_color = _mkC, text_size = txtSize, bgcolor = boxBg)
    else if boxLayout == "Horizontal"
        _txt = _mk + (showLabels and _lb != "" ? " " + _lb : "") + (_vl != "" ? " " + _vl : "")
        table.cell(_t, _i, 0, _txt, text_color = _mkC, text_size = txtSize, bgcolor = boxBg)
    else
        table.cell(_t, 0, _i, _mk, text_color = _mkC, text_size = lightSize, bgcolor = boxBg)
        table.cell(_t, 1, _i, showLabels ? _lb : "", text_color = _lbC, text_size = txtSize, bgcolor = boxBg)
        table.cell(_t, 2, _i, _vl, text_color = _vlC, text_size = pctSize, bgcolor = boxBg)

// fire-and-fade box state
boxFresh = 8
var int bRevDir = 0
var int bRevConf = 0
var int bRevAge = 0
if revLong
    bRevDir := 1
    bRevConf := confLong
    bRevAge := 0
else if revShort
    bRevDir := -1
    bRevConf := confShort
    bRevAge := 0
else if bRevDir != 0
    bRevAge := bRevAge + 1
    if bRevAge > boxFresh
        bRevDir := 0
        bRevConf := 0
var int bSpkDir = 0
var float bSpkRvol = 0.0
var int bSpkAge = 0
if spkBull
    bSpkDir := 1
    bSpkRvol := spkRvol
    bSpkAge := 0
else if spkBear
    bSpkDir := -1
    bSpkRvol := spkRvol
    bSpkAge := 0
else if bSpkDir != 0
    bSpkAge := bSpkAge + 1
    if bSpkAge > boxFresh
        bSpkDir := 0
        bSpkRvol := 0.0
var int bAtrDir = 0
var float bAtrRatio = 0.0
var int bAtrAge = 0
if atrExpFired
    bAtrDir := atrExpDir
    bAtrRatio := atrRatio
    bAtrAge := 0
else if bAtrDir != 0
    bAtrAge := bAtrAge + 1
    if bAtrAge > boxFresh
        bAtrDir := 0
        bAtrRatio := 0.0

var table tl = na
var int    prevBoxRows = -1
var string prevLayout = ""
var int    prevCols = -1
nTrail = tsOn and bxTrail ? 1 : 0
nAtrExp = atrTsOn and bxTrail ? 1 : 0
nStage = bxComp ? 1 : 0
nRev   = showRev and bxTurn ? 1 : 0
nSpk   = spkOn and bxTurn ? 1 : 0
boxRows = nTrail + nAtrExp + nStage + nRev + nSpk
gridRows = boxRows > 0 ? int(math.ceil(boxRows / gridCols)) : 0
nCols = boxLayout == "Mobile grid" ? gridCols : boxLayout == "Horizontal" ? boxRows : 3
nRows = boxLayout == "Mobile grid" ? gridRows : boxLayout == "Horizontal" ? 1 : boxRows
if showBox and boxRows > 0
    if na(tl) or prevBoxRows != boxRows or prevLayout != boxLayout or prevCols != gridCols
        if not na(tl)
            table.delete(tl)
        tl := table.new(posLookup, nCols, nRows, bgcolor = boxBg, border_width = 2, border_color = color.new(boxBorder, 50))
        prevBoxRows := boxRows
        prevLayout := boxLayout
        prevCols := gridCols
    if barstate.islast
        coilOn  = lightState == "COILING"
        tightOn = lightState == "TIGHTENING"
        fireOn  = lightState == "FIRE"
        ci = 0
        if tsOn and bxTrail
            tsLive    = tsArmed and tsDirOk
            tsExited  = not tsArmed and not na(tsExitPrice)
            tsHasTrade = tsLive or tsExited
            tsSideCol = tsDir == 1 ? tsLongColor : tsShortColor
            tsOppCol  = tsDir == 1 ? tsShortColor : tsLongColor
            tsArrowTxt = tsDir == 1 ? "▲" : "▼"
            tsLblTxt = tsHasTrade ? ("TS " + tsArrowTxt + " " + str.tostring(tsEntry, format.mintick)) : "TS"
            tsValTxt = tsLive ? str.tostring(tsLine, format.mintick) : tsExited ? str.tostring(tsExitPrice, format.mintick) : "—"
            tsValCol = tsLive ? tsSideCol : tsExited ? tsOppCol : color.new(txtColor, 40)
            tsMkCol = tsHasTrade ? tsSideCol : offColor
            f_boxPut(tl, ci, "TS", "●", tsMkCol, tsLblTxt, tsMkCol, tsValTxt, tsValCol)
            ci += 1
        if atrTsOn and bxTrail
            atrRowActive = bAtrDir != 0
            atrRowCol = bAtrDir == 1 ? atrTsBuyCol : bAtrDir == -1 ? atrTsSellCol : offColor
            atrRowMk  = bAtrDir == 1 ? "▲" : bAtrDir == -1 ? "▼" : "●"
            atrRowTxtCol = atrRowActive ? atrRowCol : color.new(txtColor, 40)
            f_boxPut(tl, ci, "EXP", atrRowMk, atrRowCol, "EXPANSION", atrRowTxtCol, atrRowActive ? str.tostring(bAtrRatio, "#.0") + "x" : "—", atrRowTxtCol)
            ci += 1
        if bxComp
            stageCol = fireOn ? fireColor : tightOn ? tighteningColor : coilOn ? coilingColor : offColor
            stageTxt = fireOn ? (fireLong ? "FIRE ▲" : fireShort ? "FIRE ▼" : "FIRE") : tightOn ? "TIGHTENING" : coilOn ? "COILING" : "READY"
            stageVal = fireOn ? (str.tostring(math.abs(stretchATR), "#.0") + "x") : (coilOn or tightOn) ? (str.tostring(atrPct, "#") + "%") : "—"
            f_boxPut(tl, ci, "STG", "●", stageCol, stageTxt, stageCol, stageVal, color.new(txtColor, 40))
            ci += 1
        if showRev and bxTurn
            revRowActive = bRevDir != 0
            revRowCol = bRevDir == 1 ? cGreen : bRevDir == -1 ? cRed : offColor
            revRowMk  = bRevDir == 1 ? "▲" : bRevDir == -1 ? "▼" : "●"
            revRowTxtCol = revRowActive ? revRowCol : color.new(txtColor, 40)
            f_boxPut(tl, ci, "REV", revRowMk, revRowCol, "REVERSAL", revRowTxtCol, revRowActive ? str.tostring(bRevConf) + "/4" : "—", revRowTxtCol)
            ci += 1
        if spkOn and bxTurn
            spkRowActive = bSpkDir != 0
            spkRowCol = bSpkDir == 1 ? spkBullCol : bSpkDir == -1 ? spkBearCol : offColor
            spkRowMk  = bSpkDir == 1 ? "▲" : bSpkDir == -1 ? "▼" : "●"
            spkRowTxtCol = spkRowActive ? spkRowCol : color.new(txtColor, 40)
            f_boxPut(tl, ci, "SPK", spkRowMk, spkRowCol, "SPIKE", spkRowTxtCol, spkRowActive ? str.tostring(bSpkRvol, "#.0") + "x vol" : "—", spkRowTxtCol)
            ci += 1


// ════════════════════════════════════════════════════════════════════════════
// PLOTS: candles + eVWMA line
// ════════════════════════════════════════════════════════════════════════════
plotcandle(open, high, low, close, "Trend candles", color = candleCol, wickcolor = candleCol, bordercolor = candleCol)
plot(showLine ? evLine : na, "eVWMA line", color = lineColor, linewidth = lineW)

// ════════════════════════════════════════════════════════════════════════════
// SIGNAL MARKERS
// ════════════════════════════════════════════════════════════════════════════
f_sigMark(fireLong and mSigCoil, 1, sigEmojiCoil, arrowBull, "COIL FADE  stretched below to buy")
f_sigMark(fireShort and mSigCoil, -1, sigEmojiCoil, arrowBear, "COIL FADE  stretched above to sell")
f_sigMark(revLong and mSigRev, 1, sigEmojiRev, cGreen, "REVERSAL  turning up from stretched-below")
f_sigMark(revShort and mSigRev, -1, sigEmojiRev, cRed, "REVERSAL  turning down from stretched-above")
f_sigMark(volConfirmLong and mSigVol, 1, sigEmojiVol, volConfCol, "VOL CONFIRM  volume surged after the buy fade")
f_sigMark(volConfirmShort and mSigVol, -1, sigEmojiVol, volConfCol, "VOL CONFIRM  volume surged after the sell fade")
f_sigMark(spkBull and mSigSpike, 1, sigEmojiSpike, spkBullCol, "SPIKE up  " + str.tostring(spkRvol, "#.0") + "x vol")
f_sigMark(spkBear and mSigSpike, -1, sigEmojiSpike, spkBearCol, "SPIKE down  " + str.tostring(spkRvol, "#.0") + "x vol")
atrExpInfo = "EXPANSION  " + str.tostring(atrRatio, "#.0") + "x avg  " + str.tostring(atrGap, "#") + " pts"
f_sigMark(atrExpFired and atrExpDir ==  1 and mSigAtr,  1, sigEmojiAtr, atrTsBuyCol,  atrExpInfo)
f_sigMark(atrExpFired and atrExpDir == -1 and mSigAtr, -1, sigEmojiAtr, atrTsSellCol, atrExpInfo)

// ════════════════════════════════════════════════════════════════════════════
// ATR TRAILING STOP PLOTS
// ════════════════════════════════════════════════════════════════════════════
tsActive = tsOn and mShowTrail and tsArmed and tsDirOk
tsLongSeg  = tsActive and tsDir ==  1 ? tsLine : na
tsShortSeg = tsActive and tsDir == -1 ? tsLine : na
plot(tsLongSeg,  "ATR Trail (long)",  color = tsLongColor,  linewidth = 2, style = plot.style_linebr)
plot(tsShortSeg, "ATR Trail (short)", color = tsShortColor, linewidth = 2, style = plot.style_linebr)
tsSegStart = tsActive and (not tsActive[1] or tsDir != tsDir[1])
plotshape(tsSegStart and tsDir ==  1 ? tsLine : na, "TS cap (long)",  style = shape.diamond, location = location.absolute, color = tsLongColor,  size = size.tiny)
plotshape(tsSegStart and tsDir == -1 ? tsLine : na, "TS cap (short)", style = shape.diamond, location = location.absolute, color = tsShortColor, size = size.tiny)

f_trail(float _loss, bool _alwaysOn, bool _fireL, bool _fireS, bool _allowL, bool _allowS) =>
    var float _line  = na
    var float _entry = na
    var float _exitP = na
    var int   _dir   = 0
    var bool  _armed = false
    if _alwaysOn
        float prevA = nz(_line[1], close)
        _line := close > prevA and close[1] > prevA ? math.max(prevA, close - _loss) : close < prevA and close[1] < prevA ? math.min(prevA, close + _loss) : close > prevA ? close - _loss : close + _loss
        nd = close > _line ? 1 : -1
        if nd != _dir
            _entry := close
        _dir   := nd
        _armed := true
    else
        if _fireL and _allowL
            _armed := true
            _dir   := 1
            _line  := close - _loss
            _entry := close
            _exitP := na
        else if _fireS and _allowS
            _armed := true
            _dir   := -1
            _line  := close + _loss
            _entry := close
            _exitP := na
        else if _armed
            if _dir == 1
                sw = nz(_line[1])
                _line := math.max(sw, close - _loss)
                if close < sw
                    _armed := false
                    _exitP := sw
            else
                sw = nz(_line[1])
                _line := math.min(sw, close + _loss)
                if close > sw
                    _armed := false
                    _exitP := sw
    [_line, _dir, _armed, _entry, _exitP]
ts2Len  = tsAtrLen
ts2Mult = tsMult
ts2AtrHtf = request.security(syminfo.tickerid, tsHtfTfEff, ta.sma(ta.tr(true), ts2Len)[1], lookahead = barmerge.lookahead_off)
ts2Atr  = tsUseHtf ? ts2AtrHtf : ta.sma(ta.tr(true), ts2Len)
ts2Loss = ts2Mult * ts2Atr
[ts2Line, ts2Dir, ts2Armed, ts2Entry, ts2ExitPrice] = f_trail(ts2Loss, tsAlwaysOn, fireLong, fireShort, tsAllowLong, tsAllowShort)
ts2DirOk  = (ts2Dir == 1 and tsAllowLong) or (ts2Dir == -1 and tsAllowShort)
ts2Active = tsOn and mShowTrail and tsBoth and ts2Armed and ts2DirOk
ts2LongSeg  = ts2Active and ts2Dir ==  1 ? ts2Line : na
ts2ShortSeg = ts2Active and ts2Dir == -1 ? ts2Line : na
plot(ts2LongSeg,  "Manual Trail (visual, long)",  color = color.new(tsLongColor, 55), linewidth = 1, style = plot.style_linebr)
plot(ts2ShortSeg, "Manual Trail (visual, short)", color = color.new(tsShortColor, 55), linewidth = 1, style = plot.style_linebr)
ts2Exit = tsOn and tsBoth and not tsAlwaysOn and ts2Armed[1] and not ts2Armed
ts2Enter = tsOn and tsBoth and not tsAlwaysOn and ((fireLong and tsAllowLong) or (fireShort and tsAllowShort))
plotchar(ts2Exit and mShowTrail, "Manual trail exit (visual)", "✕", location.abovebar, color = color.new(tsExitColor, 35), size = size.tiny)
if tsShowTags and mShowTrail and ts2Enter
    label.new(bar_index, ts2Entry, "entry " + str.tostring(ts2Entry, format.mintick), yloc = yloc.price, style = label.style_none, textcolor = color.new(fireLong ? tsLongColor : tsShortColor, 35), size = size.small)
if tsShowTags and mShowTrail and ts2Exit
    label.new(bar_index, ts2ExitPrice, "exit " + str.tostring(ts2ExitPrice, format.mintick), yloc = yloc.price, style = label.style_none, textcolor = color.new(tsExitColor, 35), size = size.small)
tsExit = tsOn and not tsAlwaysOn and tsArmed[1] and not tsArmed
plotchar(tsExit and mShowTrail, "TS exit", "✕", location.abovebar, color = color.new(tsExitColor, 0), size = size.tiny)
if tsOn and tsShowTags and not tsAlwaysOn and ((fireLong and tsAllowLong) or (fireShort and tsAllowShort)) and mShowTrail
    label.new(bar_index, tsEntry, "entry " + str.tostring(tsEntry, format.mintick), yloc = yloc.price, style = label.style_none, textcolor = (fireLong ? tsLongColor : tsShortColor), size = size.small)
if tsOn and tsShowTags and mShowTrail and tsExit
    label.new(bar_index, tsExitPrice, "exit " + str.tostring(tsExitPrice, format.mintick), yloc = yloc.price, style = label.style_none, textcolor = tsExitColor, size = size.small)

var label tsTipDot = na
if barstate.islast
    label.delete(tsTipDot)
    tsTipDot := tsActive ? label.new(bar_index, tsLine, "", style = label.style_diamond, color = (tsDir == 1 ? tsLongColor : tsShortColor), textcolor = color.new(color.white, 100), size = size.tiny) : na

// ════════════════════════════════════════════════════════════════════════════
// ALERTS
// ════════════════════════════════════════════════════════════════════════════
alertcondition(fireLong or fireShort, "Coil fade", "Stryk Trends: coil fade on {{ticker}} ({{interval}})")
alertcondition(revLong or revShort, "Reversal", "Stryk Trends: reversal on {{ticker}} ({{interval}})")
alertcondition(atrExpFired, "ATR band expansion", "Stryk Trends: ATR trailing-stop band opened wide on {{ticker}} ({{interval}})")
alertcondition(tsExit, "ATR trail exit", "Stryk Trends: ATR trailing stop hit on {{ticker}} ({{interval}})")
````
