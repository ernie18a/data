<!-- tradingview-pine-id: PUB;a2a130a78c014c7fbdba0434e7ccda8d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Strong Contrarian Zones

Source: https://www.tradingview.com/script/I6gfgjP6-Strong-Contrarian-Zones-ProjectSyndicate/

## Description

Strong Contrarian Zones maps the one thing a reversal trader actually wants to see — where the crowd is exhausted and about to be flushed — and grades it before price turns. Every meaningful swing high and low is a place a crowd committed; the indicator measures how stretched, how climactic and how one-sided that commitment was, and only the genuinely exhausted ones become zones. A weak, ordinary pivot prints nothing. A stretched, high-conviction extreme prints a graded, double-shaded zone — teal for a buy-dip, magenta for a sell-rip — with the whole read-out sitting inside the box. Then it waits for the tell: a liquidity grab beyond the zone that fails and reclaims. That sweep-and-reclaim is the contrarian trigger — the moment the trapped side gets taken and price snaps back.

Most reversal and support/resistance tools draw a level and leave you to guess which one matters. This one grades the exhaustion, ranks the zone, tells you which side is trapped, and confirms the turn only when a failed break proves it.

GBPUSD
[image]https://www.tradingview.com/x/LNYf6S5m/[/image]

🎯 The Contrarian Conviction Engine — the core. Every zone is born from a swing pivot, but a pivot alone is not a signal. At the moment each pivot confirms, the engine scores it 0–10 across seven contrarian factors and only draws the zone if the score clears your Min Conviction: RSI extreme (oversold into a low, overbought into a high), momentum divergence versus the prior same-side pivot (price makes the new extreme, RSI refuses), rejection wick (the candle spikes and slams the door), volume climax (capitulation / blow-off over an adaptive baseline), mean-reversion stretch (how many standard deviations price is from its mean), order-flow pressure (intrabar absorption — buyers stepping in at the low, sellers at the high) and a Bollinger-band pierce (price traded outside the band and rejected). Quiet, middling pivots are filtered out. Only real exhaustion becomes a zone.

🧭 Buy-Dip & Sell-Rip Zones — where the levels come from. A qualifying swing low prints a ▲ BUY-DIP zone (teal); a qualifying swing high prints a ▼ SELL-RIP zone (magenta). Every zone is normalised to one clean ATR-based thickness centred on the swing, so the map reads consistently instead of a mess of fat and thin boxes. Overlapping zones are suppressed, the oldest recycle past your cap, and each box is anchored where the exhaustion formed and extends to the live bar — so you can see when the crowd got trapped.

⚡ Sweep & Reclaim — the trigger that confirms the turn. A raw zone is a setup, not an entry. The engine watches each zone for the classic contrarian sequence: price sweeps beyond the border (a liquidity grab that runs the obvious stops), then fails and reclaims — closing back through the zone within your window. That failed break at an already-exhausted level is the highest-odds contrarian entry on the chart. Each reclaim is scored 0–10 on grab depth, reclaim speed, rejection wick, volume surge, the zone's own conviction and reclaim displacement, and the zone's state flips to ⚡RECLAIM with that score printed inside it. Accept decisively through the level instead, and it is not a reversal — it is a break.

🌡️ Live Strength & Decay — the zone earns or loses its grade. Birth conviction seeds a live 0–10 strength that keeps updating: defended retests and reclaimed-and-held sweeps push it up, and if price ignores a zone for long enough its strength decays toward a floor — an untended level quietly stops shouting. Strength drives both the label tier and the depth of the shading, so the heavy zones are visibly darker and always win your eye.

🏷️ In-Zone Strength Labels — the signature read, inside the box. Every zone carries its full read-out inside the shaded area, never jutting out to the side: the side and grade on line one (▲ BUY-DIP / ▼ SELL-RIP, ★ stars, an X/10 score and a tier — ELITE / STRONG / PRIMED / WEAK / FORMING); the birth conviction and a firing-factor fingerprint on line two (RSI · DIV · WICK · VOL · STR · PRS · BB — exactly which contrarian factors built this zone); the retest and defended-sweep counts plus the live state on line three (SWEEPING / ⚡RECLAIM x.x / BROKEN); and the anchor price on line four. One glance tells you what the zone is, why it exists and where it stands right now.

XTI Oil
[image]https://www.tradingview.com/x/MnCXGHXs/[/image]

🔄 Breakers — nothing is wasted on a real break. When a zone is genuinely accepted through rather than reclaimed, it does not just vanish. Optionally it flips side in place — a broken buy-dip becomes a fresh sell-rip and vice-versa — so a failed reversal is recycled into a break-and-retest level pointing the other way. The trapped side has been taken; the zone now works for the new direction.

🧼 Clean-Chart Discipline — zones and nothing else. No moving-average spaghetti, no oscillator sub-pane, no dashboard, no stat table. Just graded contrarian zones, their in-zone labels and a dotted midline. A tight set of controls — max live zones, overlap suppression, a strong-only filter and idle decay — keeps only the levels that matter on screen. Everything else lives in the alerts.

🎨 Fully Themed & Configurable. Custom bullish and bearish tones; gradient double-shading with adjustable transparency, borders and midline; normalised or raw zone height by ATR or percent. Tune the whole conviction engine — RSI length and oversold/overbought references, mean-reversion length and stretch reference, Bollinger length and pierce reference, volume baseline and climax reference, rejection-wick and order-flow references, divergence reference — and reweight all seven factors independently. Tune the trigger — sweep depth, reclaim window and confirmation depth, decisive-break acceptance, breaker flip — and the live-strength weights, decay length and floor. Labels are fully controllable: size, placement (inside-right, inside-centre or classic outside), background and text colour. The on-chart reclaim triangle is off by default and one click away.

NVDA
[image]https://www.tradingview.com/x/taeh71ks/[/image]

🔒 Honest, Synthetic Core. This is a behavioural reversal-mapping tool, not a live order-book or positioning feed. It infers exhaustion from price, volume and momentum, so it runs on any market, but it does not read real order flow. Zones confirm a few bars after the swing (that is how pivots work), and a reclaim on the live bar can still change until the bar closes. A zone's price is fixed the moment its pivot confirms, but its relative strength and shading can re-rank as it is retested, decays while ignored, or is outshone by stronger new zones. It is a risk-awareness and attention tool for ranking where the crowd is trapped and flagging when a failed break confirms a turn — not a backtested edge and not a promise that price will react at any level.

🔔 Native Alerts. Bullish / Bearish Zone Proximity and their Strong variants fire as price closes in on a zone; Zone Touch / Retest, Zone Sweep (liquidity grab) and Zone Break (accepted) track the lifecycle; and Bullish Reclaim, Bearish Reclaim and Any Reclaim fire the moment a swept zone snaps back — the contrarian entry itself. Set the strength threshold once and let the chart stay silent until price is near real trapped size.

🎯 Why this is different. A raw support/resistance line is static and un-graded — you eyeball a touch and guess. A single oscillator screams oversold for a hundred bars in a trend and gets you run over. Strong Contrarian Zones fuses seven contrarian reads into one graded score, only marks the exhausted extremes, and refuses to call a reversal until a sweep-and-reclaim proves the trapped side is being taken — on any symbol, at any timeframe.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, Indices and Futures on any timeframe. Because conviction is volatility-normalised and the trigger is structural, the read travels across symbols without re-tuning; volume-weighted markets sharpen the climax and order-flow factors where the tape carries clean volume.

💡 Cleanest setup: raise Min Conviction so only the genuinely exhausted extremes print; lean on the Divergence weight — a failed-break reclaim that also carried divergence is the strongest read on the chart; turn on Only Alert Strong Reclaims to fire on top-tier triggers only; widen overlap suppression and cap max zones for a de-cluttered map; and keep decay on so ignored levels fade instead of cluttering price.

🎯 How To Trade It — Two Approaches

Everything hinges on one read: is the crowd exhausted here, and has the failed break confirmed the flush yet?

⚡ 1) Trade the reclaim — the confirmed reversal

Use when a high-conviction zone is swept and reclaims.

Wait for the tell — a ▲ BUY-DIP zone swept below then reclaimed is a long trigger; a ▼ SELL-RIP zone swept above then reclaimed is a short trigger. The zone state flips to ⚡RECLAIM with a 0–10 score.
Read the grade — ELITE / STRONG reclaims with a high conviction score and a DIV or WICK fingerprint are the ones to take; let LIGHT ones go.
Trigger: enter on the reclaim close, in the direction of the snap-back, with structure agreeing.
Target: the mean / opposite side of the range, or the next zone beyond.
Stop: on the far side of the sweep extreme — beyond where the grab already failed.

BTC
[image]https://www.tradingview.com/x/bTLrmWuL/[/image]

🧱 2) Fade the zone — the exhaustion barrier

Use on the first tap of a strong, untested zone while price arrives tired.

A dense ELITE / STRONG zone can repel price on first contact — the classic reversal-from-a-level. The Proximity alert flags the run-in.
Trigger: fade the first touch back toward the mean, ideally when price arrives over-extended into an ELITE-grade zone with conviction factors firing.
Invalidation: acceptance through the zone. Once price closes decisively beyond it (a Zone Break, not a reclaim), the trapped side is being taken — stand aside or flip with the breaker.

✋ Stand down — the map says wait
FORMING / WEAK zones are minor exhaustion, not walls. Nothing to lean on.
Decayed (faded) zones have been ignored too long — they carry far less fuel.
A zone that is swept but has not reclaimed is still in play — SWEEPING, not confirmed. Wait for the close.
No strong zone near price, or price mid-range between zones — wait for contact with a ranked zone and let the alert bring you in.

Rule of thumb: ⚡ High-conviction zone swept and reclaimed → trade the snap-back, target the mean. 🧱 Dense untested zone + tired arrival on first touch → fade back to the mean until acceptance proves otherwise. ❄️ Forming, weak or decayed zones, or no zone near price → stand down until the exhaustion lines up.

---

## Source Code

````pine
//@version=6
indicator("Strong Contrarian Zones", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 2000)

// ─────────────────────────────── Display ───────────────────────────────
gD = "═══ Display ═══"
mode         = input.string("Both", "Zone Side", options = ["Both", "Bullish Only", "Bearish Only"], group = gD)
showLabels   = input.bool(true, "Show In-Zone Labels", group = gD)
labSize      = input.string("Normal", "Label Size", options = ["Tiny", "Small", "Normal", "Large"], group = gD)
lookbackBars = input.int(2500, "Lookback (bars, 0 = all loaded)", minval = 0, group = gD, tooltip = "Only build zones within this many recent bars. 0 = everything loaded.")
maxZones     = input.int(30, "Max Live Zones", minval = 2, maxval = 120, group = gD, tooltip = "Oldest zones recycle past this so loading stays fast.")
hideOverlap  = input.bool(true, "Hide Overlapping Zones", group = gD)
overlapThr   = input.int(25, "Overlap Threshold (%)", minval = 1, maxval = 100, group = gD)

// ─────────────────────────────── Swing detection ───────────────────────────────
gS = "═══ Swing Detection ═══"
leftBars  = input.int(10, "Pivot Left",  minval = 1, group = gS)
rightBars = input.int(3,  "Pivot Right", minval = 1, group = gS)
maxLife   = input.int(700, "Max Zone Life (bars)", minval = 10, group = gS)

// ─────────────────────────────── Zone height ───────────────────────────────
gH = "═══ Zone Height ═══"
normHeight = input.bool(true, "Normalize All Zone Heights", group = gH, tooltip = "Force every zone to the same thickness, centered on the swing level.")
heightMode = input.string("ATR Based", "Height Method", options = ["ATR Based", "Fixed Percentage"], group = gH)
heightATR  = input.float(0.6, "Zone Height (ATR Mult)", minval = 0.05, maxval = 10.0, step = 0.05, group = gH)
heightPct  = input.float(0.30, "Zone Height (% of Price)", minval = 0.01, maxval = 5.0, step = 0.05, group = gH)
atrLen     = input.int(200, "ATR Length", minval = 1, maxval = 500, group = gH)

// ─────────────────────────────── Contrarian conviction (0–10) ───────────────────────────────
gCv = "═══ Contrarian Conviction ═══"
minConv   = input.float(4.5, "Min Conviction To Draw Zone", minval = 0, maxval = 10, step = 0.5, group = gCv, tooltip = "A swing pivot only becomes a zone when its birth conviction clears this. Higher = fewer, higher-odds contrarian zones.")
rsiLen    = input.int(14, "RSI Length", minval = 2, maxval = 100, group = gCv)
rsiBuyRef = input.int(42, "Oversold Reference (RSI ≤)", minval = 5, maxval = 50, group = gCv, tooltip = "RSI at/under this at a swing LOW = full oversold energy for a buy-dip.")
rsiSellRef= input.int(58, "Overbought Reference (RSI ≥)", minval = 50, maxval = 95, group = gCv, tooltip = "RSI at/over this at a swing HIGH = full overbought energy for a sell-rip.")
zLen      = input.int(50, "Mean-Reversion Length (z-score)", minval = 5, maxval = 400, group = gCv)
zRef      = input.float(2.2, "Stretch Reference (z σ)", minval = 0.5, maxval = 6.0, step = 0.1, group = gCv, tooltip = "How many σ from the mean counts as a full mean-reversion stretch.")
bbLenC    = input.int(20, "Bollinger Length", minval = 2, maxval = 200, group = gCv)
bbMultC   = input.float(2.0, "Bollinger StdDev", minval = 0.5, maxval = 5.0, step = 0.1, group = gCv)
bandRef   = input.float(0.5, "Band-Pierce Reference (ATR)", minval = 0.05, maxval = 4.0, step = 0.05, group = gCv, tooltip = "How far the wick must pierce beyond the band (in ATR) for full pierce energy.")
volLen    = input.int(20, "Volume Baseline Length", minval = 1, group = gCv)
volClimax = input.float(2.2, "Volume Climax Reference (x)", minval = 1.1, maxval = 8.0, step = 0.1, group = gCv, tooltip = "Volume this many times its baseline = full capitulation/blow-off energy.")
wickRef   = input.float(0.45, "Rejection Wick Reference", minval = 0.1, maxval = 1.0, step = 0.05, group = gCv, tooltip = "Rejection-wick fraction of the pivot candle for full wick energy.")
pressLen  = input.int(20, "Order-Flow Pressure Lookback", minval = 2, maxval = 200, group = gCv)
pressRef  = input.float(18.0, "Pressure Reference (% past 50)", minval = 2, maxval = 50, step = 1, group = gCv, tooltip = "Absorption: buying pressure this far above 50% at a LOW (or selling below 50% at a HIGH) = full pressure energy.")
divRef    = input.float(8.0, "Divergence Reference (RSI pts)", minval = 1, maxval = 40, step = 1, group = gCv, tooltip = "RSI improvement vs the prior same-side pivot for full divergence energy.")

gW = "═══ Conviction Weights ═══"
wRsi   = input.float(1.0, "Weight · RSI Extreme", minval = 0, maxval = 3, step = 0.1, group = gW)
wDiv   = input.float(1.3, "Weight · Momentum Divergence", minval = 0, maxval = 3, step = 0.1, group = gW)
wWick  = input.float(1.0, "Weight · Rejection Wick", minval = 0, maxval = 3, step = 0.1, group = gW)
wVolC  = input.float(1.0, "Weight · Volume Climax", minval = 0, maxval = 3, step = 0.1, group = gW)
wStr   = input.float(1.0, "Weight · Mean-Reversion Stretch", minval = 0, maxval = 3, step = 0.1, group = gW)
wPress = input.float(0.9, "Weight · Order-Flow Pressure", minval = 0, maxval = 3, step = 0.1, group = gW)
wBand  = input.float(0.9, "Weight · Bollinger Pierce", minval = 0, maxval = 3, step = 0.1, group = gW)

// ─────────────────────────────── Sweep & reclaim (the contrarian trigger) ───────────────────────────────
gSw = "═══ Sweep & Reclaim Trigger ═══"
alertRecl  = input.bool(true, "Fire Reclaim Alerts", group = gSw, tooltip = "Emit an alert when a zone is swept (liquidity grab) then reclaimed (failed break). The reclaim also strengthens the zone regardless of this toggle.")
minDepth   = input.float(0.15, "Min Sweep Depth (ATR)", minval = 0.02, maxval = 4.0, step = 0.01, group = gSw, tooltip = "A wick must pierce THIS far beyond a zone border to count as a sweep rather than a normal touch.")
reclaimWin = input.int(6, "Max Reclaim Window (bars)", minval = 1, maxval = 40, group = gSw, tooltip = "A swept zone must be reclaimed within this many bars. Longer = genuine acceptance (a real break).")
reclaimDpt = input.string("Border", "Reclaim Confirmation", options = ["Border", "Midline", "Far Border"], group = gSw, tooltip = "How far back through the zone price must CLOSE to confirm the reclaim. Deeper = stricter / fewer reclaims.")
breakAtr   = input.float(0.9, "Decisive Break Acceptance (ATR)", minval = 0.1, maxval = 8.0, step = 0.1, group = gSw, tooltip = "If a close accepts THIS far beyond the swept border, treat it as a genuine break immediately (no reclaim).")
flipBroken = input.bool(true, "Flip Broken Zones (breakers)", group = gSw, tooltip = "On a genuine break, keep the zone and flip its side in place for break-and-retest continuation.")
onlyStrongRec = input.bool(false, "Only Alert Strong Reclaims", group = gSw)
strongRecThr  = input.float(6.5, "Strong Reclaim Threshold", minval = 0, maxval = 10, step = 0.5, group = gSw)
showTrig   = input.bool(false, "Show Reclaim Triggers", group = gSw, tooltip = "Plot a small triangle on the reclaim bar. Off by default — enable here if you want the on-chart marker.")

gT = "═══ Reclaim Trigger Scoring (0–10) ═══"
depthRef  = input.float(1.0, "Grab Depth Ref (ATR)", minval = 0.2, maxval = 6.0, step = 0.1, group = gT)
dispRef   = input.float(0.6, "Reclaim Displacement Ref (ATR)", minval = 0.1, maxval = 4.0, step = 0.1, group = gT)
volRef    = input.float(2.0, "Volume Surge Ref (x)", minval = 1.1, maxval = 8.0, step = 0.1, group = gT)
twDepth   = input.float(1.0, "Weight · Grab Depth", minval = 0, maxval = 3, step = 0.1, group = gT)
twSpeed   = input.float(1.0, "Weight · Reclaim Speed", minval = 0, maxval = 3, step = 0.1, group = gT)
twWick    = input.float(1.0, "Weight · Rejection Wick", minval = 0, maxval = 3, step = 0.1, group = gT)
twVol     = input.float(1.0, "Weight · Volume Surge", minval = 0, maxval = 3, step = 0.1, group = gT)
twConv    = input.float(1.2, "Weight · Zone Conviction", minval = 0, maxval = 3, step = 0.1, group = gT)
twDisp    = input.float(1.0, "Weight · Reclaim Displacement", minval = 0, maxval = 3, step = 0.1, group = gT)

// ─────────────────────────────── Live zone strength (0–10) ───────────────────────────────
gStr = "═══ Live Zone Strength ═══"
onlyStrong= input.bool(false, "Show Only Strong Zones", group = gStr)
strongThr = input.float(5.0, "Strong Threshold (score)", minval = 0, maxval = 10, step = 0.5, group = gStr)
touchNorm = input.float(4.0, "Retests For Full Score", minval = 1, step = 0.5, group = gStr)
defendNorm= input.float(2.0, "Defended Reclaims For Full Score", minval = 1, step = 0.5, group = gStr)
sWConv    = input.float(0.35, "Weight: Birth Conviction", minval = 0, maxval = 1, step = 0.05, group = gStr)
sWTouch   = input.float(0.25, "Weight: Retests", minval = 0, maxval = 1, step = 0.05, group = gStr)
sWDefend  = input.float(0.25, "Weight: Sweep Defense", minval = 0, maxval = 1, step = 0.05, group = gStr)
sWWick    = input.float(0.075, "Weight: Rejection Wick", minval = 0, maxval = 1, step = 0.025, group = gStr)
sWVol     = input.float(0.075, "Weight: Volume", minval = 0, maxval = 1, step = 0.025, group = gStr)
useDecay  = input.bool(true, "Decay Strength While Ignored", group = gStr)
decayBars = input.int(300, "Full Decay Over (idle bars)", minval = 20, maxval = 5000, group = gStr)
decayFloor= input.float(0.65, "Decay Floor", minval = 0.1, maxval = 1.0, step = 0.05, group = gStr)

// ─────────────────────────────── Style ───────────────────────────────
gC = "═══ Style ═══"
supCol     = input.color(#21c997, "Bullish Zone Tone", group = gC)
resCol     = input.color(#cc24e2, "Bearish Zone Tone", group = gC)
gradFill   = input.bool(true, "Gradient (double-shaded) Fill", group = gC)
fillTransp = input.int(84, "Zone Transparency", minval = 50, maxval = 96, group = gC)
showBord   = input.bool(true, "Show Zone Borders", group = gC)
bordTransp = input.int(35, "Border Transparency", minval = 0, maxval = 100, group = gC)
showMid    = input.bool(true, "Show Zone Midline", group = gC)
labPlace   = input.string("Outside · Right", "Label Placement", options = ["Outside · Right", "Inside · Right", "Inside · Center"], group = gC, tooltip = "Outside · Right pushes the whole label off the right edge of the shaded zone (cleanest to read). Inside options keep it within the box.")
labGap     = input.int(3, "Label Gap From Zone (bars)", minval = 0, maxval = 50, group = gC, tooltip = "Empty space between the zone's right edge and the label when placed outside.")
labBgTransp= input.int(22, "Label Background Transparency", minval = 0, maxval = 100, group = gC)
labTxtCol  = input.color(#F2F7FF, "Label Text Colour", group = gC)

// ─────────────────────────────── Alerts ───────────────────────────────
gA = "═══ Alerts ═══"
alertProx = input.float(0.10, "Proximity (% of price)", minval = 0.0, step = 0.01, group = gA)
instThr   = input.float(7.0, "Strong / Institutional Score", minval = 0, maxval = 10, step = 0.5, group = gA)

// ═══════════════════════════════════ Helpers ═══════════════════════════════════
f_size(s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

clamp01(x) => math.min(math.max(x, 0.0), 1.0)

f_stars(sc) => sc >= 8 ? "★★★★★" : sc >= 6.5 ? "★★★★" : sc >= 5 ? "★★★" : sc >= 3 ? "★★" : sc >= 1.5 ? "★" : "·"
f_tier(sc)  => sc >= 8 ? "ELITE" : sc >= 6.5 ? "STRONG" : sc >= 5 ? "PRIMED" : sc >= 3 ? "WEAK" : "FORMING"
f_ageF(age) => not useDecay ? 1.0 : math.max(1.0 - (1.0 - decayFloor) * math.min(age / math.max(decayBars, 1), 1.0), decayFloor)
f_vis(sc)   => not onlyStrong or sc >= strongThr

labStyle = labPlace == "Inside · Center" ? label.style_label_center : labPlace == "Inside · Right" ? label.style_label_right : label.style_label_left

f_rangeOverlap(float t1, float b1, float t2, float b2) =>
    float ov   = math.min(t1, t2) - math.max(b1, b2)
    float minH = math.min(t1 - b1, t2 - b2)
    ov > 0 and minH > 0 and ov / minH >= overlapThr / 100.0

// ═══════════════════════════════════ Global calcs ═══════════════════════════════════
n        = bar_index
atrRaw   = math.max(nz(ta.atr(atrLen), ta.cum(high - low) / (n + 1)), syminfo.mintick)
volBase  = ta.sma(volume, volLen)
rsiV     = ta.rsi(close, rsiLen)

basisMA  = ta.sma(close, zLen)
sdV      = ta.stdev(close, zLen)
zScore   = sdV > 0 ? (close - basisMA) / sdV : 0.0

bbBasis  = ta.sma(close, bbLenC)
bbDev    = bbMultC * ta.stdev(close, bbLenC)
bbUpper  = bbBasis + bbDev
bbLower  = bbBasis - bbDev

relVol   = volBase > 0 ? volume / volBase : 1.0

bvBar    = high > low ? volume * (close - low) / (high - low) : volume * 0.5
svBar    = high > low ? volume * (high - close) / (high - low) : volume * 0.5
rollBuy  = math.sum(bvBar, pressLen)
rollSell = math.sum(svBar, pressLen)
buyPct   = (rollBuy + rollSell) > 0 ? rollBuy / (rollBuy + rollSell) * 100.0 : 50.0

ph       = ta.pivothigh(leftBars, rightBars)
pl       = ta.pivotlow(leftBars, rightBars)
inWindow = lookbackBars <= 0 or (last_bar_index - n) <= lookbackBars

zoneH    = heightMode == "ATR Based" ? atrRaw * heightATR : close * (heightPct / 100.0)
supOn    = mode == "Both" or mode == "Bullish Only"
resOn    = mode == "Both" or mode == "Bearish Only"

f_fill(int dir) => color.new(dir == 1 ? supCol : resCol, fillTransp)
f_bord(int dir) => showBord ? color.new(dir == 1 ? supCol : resCol, bordTransp) : color(na)
f_tone(int dir) => dir == 1 ? supCol : resCol

// ═══════════════════════════════════ Zone type ═══════════════════════════════════
type czone
    int    dir     = 1
    float  top     = na
    float  bot     = na
    float  mid     = na
    float  anchor  = na
    int    bornBar = na
    int    lastBar = na
    int    touches = 0
    int    defends = 0
    int    phase   = 0
    int    swBar   = na
    float  swExt   = na
    float  conv    = 0.0
    string convTxt = ""
    float  volSum  = 0.0
    int    volN    = 0
    float  wickSum = 0.0
    int    wickN   = 0
    float  trig    = 0.0
    int    state   = 0
    float  score   = 0.0
    box    bxOut   = na
    box    bxMid   = na
    box    bxCore  = na
    line   ln      = na
    label  tag     = na
    bool   dead    = false

var array<czone> zones = array.new<czone>()

// running divergence chain
var float lastPLp = na
var float lastPLr = na
var float lastPHp = na
var float lastPHr = na

f_zoneScore(czone z) =>
    tF   = math.min(z.touches / math.max(touchNorm, 1.0), 1.0)
    dF   = math.min(z.defends / math.max(defendNorm, 1.0), 1.0)
    wF   = z.wickN > 0 ? math.min((z.wickSum / z.wickN) / atrRaw, 1.0) : 0.0
    vF   = volBase > 0 and z.volN > 0 ? math.min((z.volSum / z.volN) / volBase, 1.0) : 0.0
    cF   = z.conv / 10.0
    wSum = sWConv + sWTouch + sWDefend + sWWick + sWVol
    raw  = wSum > 0 ? (cF * sWConv + tF * sWTouch + dF * sWDefend + wF * sWWick + vF * sWVol) / wSum : 0.0
    math.min(math.max(raw * 10.0 * f_ageF(n - z.lastBar), 0.0), 10.0)

f_trigScore(float depthAtr, int barsUsed, float wickFrac, float volSurge, float convSc, float dispAtr) =>
    sD  = clamp01(depthAtr / depthRef)
    sSp = clamp01((reclaimWin - barsUsed + 1.0) / reclaimWin)
    sW  = clamp01(wickFrac)
    sV  = clamp01((volSurge - 1.0) / math.max(volRef - 1.0, 0.1))
    sC  = clamp01(convSc / 10.0)
    sDp = clamp01(dispAtr / dispRef)
    wSum = twDepth + twSpeed + twWick + twVol + twConv + twDisp
    raw  = wSum > 0 ? (twDepth * sD + twSpeed * sSp + twWick * sW + twVol * sV + twConv * sC + twDisp * sDp) / wSum : 0.0
    math.min(math.max(raw * 10.0, 0.0), 10.0)

// ── conviction fingerprint text (only the factors that fired) ──
f_convTxt(float sR, float sDv, float sW, float sV, float sSt, float sP, float sB) =>
    string t = ""
    t := t + (sR  >= 0.5 ? "RSI "  : "")
    t := t + (sDv >= 0.5 ? "DIV "  : "")
    t := t + (sW  >= 0.5 ? "WICK " : "")
    t := t + (sV  >= 0.5 ? "VOL "  : "")
    t := t + (sSt >= 0.5 ? "STR "  : "")
    t := t + (sP  >= 0.5 ? "PRS "  : "")
    t := t + (sB  >= 0.5 ? "BB "   : "")
    t == "" ? "—" : str.trim(t)

// ═══════════════════════════════════ Zone methods ═══════════════════════════════════
method recolor(czone self, bool vis) =>
    color tone = f_tone(self.dir)
    int sInt   = int(math.round(self.score))
    int opOut  = gradFill ? math.max(fillTransp - 2, 62) : fillTransp
    int opMid  = gradFill ? math.max(fillTransp - 12 - sInt, 50) : fillTransp
    int opCor  = gradFill ? math.max(fillTransp - 24 - sInt * 2, 36) : fillTransp
    box.set_bgcolor(self.bxOut,  vis ? color.new(tone, opOut) : na)
    box.set_bgcolor(self.bxMid,  vis and gradFill ? color.new(tone, opMid) : na)
    box.set_bgcolor(self.bxCore, vis and gradFill ? color.new(tone, opCor) : na)
    box.set_border_color(self.bxOut, vis ? f_bord(self.dir) : na)
    line.set_color(self.ln, vis and showMid ? color.new(tone, 20) : na)

method killZone(czone self) =>
    box.delete(self.bxOut)
    box.delete(self.bxMid)
    box.delete(self.bxCore)
    line.delete(self.ln)
    label.delete(self.tag)
    self.dead := true

method refreshGeo(czone self) =>
    box.set_right(self.bxOut, n)
    box.set_right(self.bxMid, n)
    box.set_right(self.bxCore, n)
    line.set_x2(self.ln, n)

method refreshTag(czone self, bool vis) =>
    if showLabels
        if vis
            string dirTag  = self.dir == 1 ? "▲ BUY-DIP" : "▼ SELL-RIP"
            string stTag   = self.state == 1 ? "  · SWEEPING" : self.state == 2 ? "  · ⚡RECLAIM " + str.tostring(math.round(self.trig * 10) / 10) : self.state == 3 ? "  · BROKEN" : ""
            string l1 = dirTag + "  " + f_stars(self.score) + "  " + str.tostring(math.round(self.score * 10) / 10) + "/10  " + f_tier(self.score)
            string l2 = "Conv " + str.tostring(math.round(self.conv * 10) / 10) + "/10  ·  " + self.convTxt
            string l3 = "Retest " + str.tostring(self.touches) + "  ·  Defend " + str.tostring(self.defends) + (self.defends > 0 ? " ⚡" : "") + stTag
            string l4 = "@ " + str.tostring(self.anchor, format.mintick)
            string txt = l1 + "\n" + l2 + "\n" + l3 + "\n" + l4
            int lx = labStyle == label.style_label_center ? int(math.avg(self.bornBar, n)) : labStyle == label.style_label_left ? n + labGap : n
            if na(self.tag)
                self.tag := label.new(lx, self.mid, txt, style = labStyle, color = color.new(f_tone(self.dir), labBgTransp), textcolor = labTxtCol, size = f_size(labSize))
            else
                label.set_text(self.tag, txt)
                label.set_xy(self.tag, lx, self.mid)
            label.set_style(self.tag, labStyle)
            label.set_color(self.tag, color.new(f_tone(self.dir), labBgTransp))
            label.set_textcolor(self.tag, labTxtCol)
        else if not na(self.tag)
            label.set_text(self.tag, "")

f_overlapsActive(float t, float b) =>
    bool hit = false
    if array.size(zones) > 0
        for z in zones
            if not z.dead and z.phase != 1 and f_rangeOverlap(t, b, z.top, z.bot)
                hit := true
                break
    hit

// ═══════════════════════════════════ Genesis ═══════════════════════════════════
o = rightBars

// ── bullish (buy-dip) at a swing low ──
if not na(pl)
    float rsiP = rsiV[o]
    float lowP = low[o]
    float rngP = high[o] - low[o]
    // divergence measured BEFORE updating the chain
    bool  bullDiv = not na(lastPLp) and pl < lastPLp and rsiP > lastPLr
    float sDv = bullDiv ? clamp01((rsiP - lastPLr) / divRef) : 0.0
    float sR  = clamp01((rsiBuyRef - rsiP) / math.max(rsiBuyRef, 1))
    float sSt = clamp01(-zScore[o] / zRef)
    float sV  = clamp01((relVol[o] - 1.0) / math.max(volClimax - 1.0, 0.1))
    float wF  = rngP > 0 ? (math.min(open[o], close[o]) - lowP) / rngP : 0.0
    float sW  = clamp01(wF / wickRef)
    float sP  = clamp01((buyPct[o] - 50.0) / pressRef)
    float sB  = clamp01((bbLower[o] - lowP) / math.max(bandRef * atrRaw[o], syminfo.mintick))
    float wSum = wRsi + wDiv + wWick + wVolC + wStr + wPress + wBand
    float conv = wSum > 0 ? (sR * wRsi + sDv * wDiv + sW * wWick + sV * wVolC + sSt * wStr + sP * wPress + sB * wBand) / wSum * 10.0 : 0.0
    if supOn and inWindow and conv >= minConv
        float nTop = normHeight ? pl + zoneH / 2.0 : pl + zoneH
        float nBot = normHeight ? pl - zoneH / 2.0 : pl
        if not (hideOverlap and f_overlapsActive(nTop, nBot))
            czone z = czone.new()
            z.dir     := 1
            z.top     := nTop
            z.bot     := nBot
            z.mid     := (nTop + nBot) / 2.0
            z.anchor  := pl
            z.bornBar := n - o
            z.lastBar := n - o
            z.conv    := conv
            z.convTxt := f_convTxt(sR, sDv, sW, sV, sSt, sP, sB)
            z.volSum  := nz(volume[o])
            z.volN    := 1
            z.wickSum := math.max((math.min(open[o], close[o]) - lowP), 0)
            z.wickN   := 1
            z.bxOut   := box.new(n - o, nTop, n, nBot, border_width = 1)
            z.bxMid   := box.new(n - o, z.mid + (nTop - z.mid) * 0.5, n, z.mid + (nBot - z.mid) * 0.5, border_color = na, border_width = 0)
            z.bxCore  := box.new(n - o, z.mid + (nTop - z.mid) * 0.22, n, z.mid + (nBot - z.mid) * 0.22, border_color = na, border_width = 0)
            z.ln      := line.new(n - o, z.mid, n, z.mid, width = 1, style = line.style_dotted)
            z.score   := conv
            z.recolor(true)
            array.push(zones, z)
    // extend the chain on every confirmed low
    lastPLp := pl
    lastPLr := rsiP

// ── bearish (sell-rip) at a swing high ──
if not na(ph)
    float rsiP = rsiV[o]
    float highP= high[o]
    float rngP = high[o] - low[o]
    bool  bearDiv = not na(lastPHp) and ph > lastPHp and rsiP < lastPHr
    float sDv = bearDiv ? clamp01((lastPHr - rsiP) / divRef) : 0.0
    float sR  = clamp01((rsiP - rsiSellRef) / math.max(100 - rsiSellRef, 1))
    float sSt = clamp01(zScore[o] / zRef)
    float sV  = clamp01((relVol[o] - 1.0) / math.max(volClimax - 1.0, 0.1))
    float wF  = rngP > 0 ? (highP - math.max(open[o], close[o])) / rngP : 0.0
    float sW  = clamp01(wF / wickRef)
    float sP  = clamp01((50.0 - buyPct[o]) / pressRef)
    float sB  = clamp01((highP - bbUpper[o]) / math.max(bandRef * atrRaw[o], syminfo.mintick))
    float wSum = wRsi + wDiv + wWick + wVolC + wStr + wPress + wBand
    float conv = wSum > 0 ? (sR * wRsi + sDv * wDiv + sW * wWick + sV * wVolC + sSt * wStr + sP * wPress + sB * wBand) / wSum * 10.0 : 0.0
    if resOn and inWindow and conv >= minConv
        float nTop = normHeight ? ph + zoneH / 2.0 : ph
        float nBot = normHeight ? ph - zoneH / 2.0 : ph - zoneH
        if not (hideOverlap and f_overlapsActive(nTop, nBot))
            czone z = czone.new()
            z.dir     := -1
            z.top     := nTop
            z.bot     := nBot
            z.mid     := (nTop + nBot) / 2.0
            z.anchor  := ph
            z.bornBar := n - o
            z.lastBar := n - o
            z.conv    := conv
            z.convTxt := f_convTxt(sR, sDv, sW, sV, sSt, sP, sB)
            z.volSum  := nz(volume[o])
            z.volN    := 1
            z.wickSum := math.max((highP - math.max(open[o], close[o])), 0)
            z.wickN   := 1
            z.bxOut   := box.new(n - o, nTop, n, nBot, border_width = 1)
            z.bxMid   := box.new(n - o, z.mid + (nTop - z.mid) * 0.5, n, z.mid + (nBot - z.mid) * 0.5, border_color = na, border_width = 0)
            z.bxCore  := box.new(n - o, z.mid + (nTop - z.mid) * 0.22, n, z.mid + (nBot - z.mid) * 0.22, border_color = na, border_width = 0)
            z.ln      := line.new(n - o, z.mid, n, z.mid, width = 1, style = line.style_dotted)
            z.score   := conv
            z.recolor(true)
            array.push(zones, z)
    lastPHp := ph
    lastPHr := rsiP

// recycle oldest beyond cap
while array.size(zones) > maxZones
    array.shift(zones).killZone()

// ═══════════════════════════════════ Lifecycle ═══════════════════════════════════
bool evTouch = false
bool evSweep = false
bool evBreak = false
bool recBull = false
bool recBear = false
float lastRecScore = na

reclaimDepthMul = reclaimDpt == "Far Border" ? 1.0 : reclaimDpt == "Midline" ? 0.5 : 0.0

if array.size(zones) > 0
    for i = 0 to array.size(zones) - 1
        z = array.get(zones, i)
        if not z.dead
            z.refreshGeo()
            z.volSum += nz(volume)
            z.volN   += 1

            if n - z.bornBar >= maxLife
                z.killZone()
            else
                if z.dir == 1
                    if z.phase == 0
                        if low <= z.top and low >= z.bot and close > z.bot
                            z.touches += 1
                            z.wickSum += math.max(z.top - low, 0)
                            z.wickN   += 1
                            z.lastBar := n
                            z.state   := 0
                            evTouch   := true
                        else if low < z.bot - minDepth * atrRaw
                            z.phase := 1
                            z.swBar := n
                            z.swExt := low
                            z.state := 1
                            evSweep := true
                    else if z.phase == 1
                        z.swExt := math.min(z.swExt, low)
                        rcLvl    = z.bot + reclaimDepthMul * (z.top - z.bot)
                        accepted = close < z.bot - breakAtr * atrRaw or (n - z.swBar >= reclaimWin and close < z.bot)
                        if close > rcLvl
                            depthA   = (z.bot - z.swExt) / atrRaw
                            wickFr   = (math.min(open, close) - low) / math.max(high - low, syminfo.mintick)
                            volSurge = volume / math.max(nz(volBase, volume), 1)
                            dispA    = (close - z.bot) / atrRaw
                            rsc      = f_trigScore(depthA, n - z.swBar, wickFr, volSurge, z.conv, dispA)
                            if alertRecl and (not onlyStrongRec or rsc >= strongRecThr)
                                recBull      := true
                                lastRecScore := rsc
                            z.defends += 1
                            z.trig    := rsc
                            z.lastBar := n
                            z.phase   := 0
                            z.state   := 2
                        else if accepted
                            evBreak := true
                            if flipBroken
                                z.dir     := -1
                                z.touches := 0
                                z.defends := 0
                                z.wickSum := 0.0
                                z.wickN   := 0
                                z.phase   := 0
                                z.state   := 3
                                z.lastBar := n
                            else
                                z.killZone()
                else
                    if z.phase == 0
                        if high >= z.bot and high <= z.top and close < z.top
                            z.touches += 1
                            z.wickSum += math.max(high - z.bot, 0)
                            z.wickN   += 1
                            z.lastBar := n
                            z.state   := 0
                            evTouch   := true
                        else if high > z.top + minDepth * atrRaw
                            z.phase := 1
                            z.swBar := n
                            z.swExt := high
                            z.state := 1
                            evSweep := true
                    else if z.phase == 1
                        z.swExt := math.max(z.swExt, high)
                        rcLvl    = z.top - reclaimDepthMul * (z.top - z.bot)
                        accepted = close > z.top + breakAtr * atrRaw or (n - z.swBar >= reclaimWin and close > z.top)
                        if close < rcLvl
                            depthA   = (z.swExt - z.top) / atrRaw
                            wickFr   = (high - math.max(open, close)) / math.max(high - low, syminfo.mintick)
                            volSurge = volume / math.max(nz(volBase, volume), 1)
                            dispA    = (z.top - close) / atrRaw
                            rsc      = f_trigScore(depthA, n - z.swBar, wickFr, volSurge, z.conv, dispA)
                            if alertRecl and (not onlyStrongRec or rsc >= strongRecThr)
                                recBear      := true
                                lastRecScore := rsc
                            z.defends += 1
                            z.trig    := rsc
                            z.lastBar := n
                            z.phase   := 0
                            z.state   := 2
                        else if accepted
                            evBreak := true
                            if flipBroken
                                z.dir     := 1
                                z.touches := 0
                                z.defends := 0
                                z.wickSum := 0.0
                                z.wickN   := 0
                                z.phase   := 0
                                z.state   := 3
                                z.lastBar := n
                            else
                                z.killZone()

                if not z.dead
                    sc = f_zoneScore(z)
                    z.score := sc
                    vis = f_vis(sc) or z.phase == 1 or z.state == 2
                    box.set_top(z.bxOut, z.top)
                    box.set_bottom(z.bxOut, z.bot)
                    box.set_top(z.bxMid, z.mid + (z.top - z.mid) * 0.5)
                    box.set_bottom(z.bxMid, z.mid + (z.bot - z.mid) * 0.5)
                    box.set_top(z.bxCore, z.mid + (z.top - z.mid) * 0.22)
                    box.set_bottom(z.bxCore, z.mid + (z.bot - z.mid) * 0.22)
                    line.set_y1(z.ln, z.mid)
                    line.set_y2(z.ln, z.mid)
                    z.recolor(vis)
                    z.refreshTag(vis)

// clean up dead zones
if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        if array.get(zones, i).dead
            array.remove(zones, i)

// ═══════════════════════════════════ Proximity scan ═══════════════════════════════════
bool nearBull       = false
bool nearBear       = false
bool nearStrongBull = false
bool nearStrongBear = false
float prox = close * alertProx / 100.0

if array.size(zones) > 0
    for z in zones
        if not z.dead and (f_vis(z.score) or z.phase == 1) and math.abs(close - z.mid) <= prox
            if z.dir == 1
                nearBull := true
                nearStrongBull := nearStrongBull or z.score >= instThr
            else
                nearBear := true
                nearStrongBear := nearStrongBear or z.score >= instThr

// ═══════════════════════════════════ Triggers ═══════════════════════════════════
plotshape(showTrig and recBull, title = "Bullish Reclaim", style = shape.triangleup, location = location.belowbar, color = supCol, size = size.small, text = "RECLAIM", textcolor = supCol)
plotshape(showTrig and recBear, title = "Bearish Reclaim", style = shape.triangledown, location = location.abovebar, color = resCol, size = size.small, text = "RECLAIM", textcolor = resCol)

// ═══════════════════════════════════ Alerts ═══════════════════════════════════
alertcondition(nearBull,       "Bullish Zone Proximity",        "Price approaching a bullish contrarian zone.")
alertcondition(nearBear,       "Bearish Zone Proximity",        "Price approaching a bearish contrarian zone.")
alertcondition(nearStrongBull, "Strong Bullish Zone Proximity", "Price approaching a strong bullish contrarian zone.")
alertcondition(nearStrongBear, "Strong Bearish Zone Proximity", "Price approaching a strong bearish contrarian zone.")
alertcondition(evTouch,        "Zone Touch / Retest",           "Price tested and held a contrarian zone.")
alertcondition(evSweep,        "Zone Sweep (liquidity grab)",   "Price swept beyond a zone — watch for a reclaim.")
alertcondition(evBreak,        "Zone Break (accepted)",         "A zone was genuinely broken and flipped.")
alertcondition(recBull,        "Bullish Reclaim",               "Sweep below a contrarian zone was reclaimed — bullish reversal.")
alertcondition(recBear,        "Bearish Reclaim",               "Sweep above a contrarian zone was reclaimed — bearish reversal.")
alertcondition(recBull or recBear, "Any Reclaim",               "A contrarian sweep-and-reclaim fired.")
````
