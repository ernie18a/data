# APEX Contra Flow | ProjectSyndicate

- url: https://www.tradingview.com/script/apImmcNh-APEX-Contra-Flow-ProjectSyndicate/
- type: indicator
- pine_id: PUB;7b3498f206784ed18082733c1b8fcc65
- version: 1.0

## Description

APEX Contra Flow rebuilds the order flow hidden inside every candle and reads it as an auction — then scores, bar by bar, whether that auction has finished and is ready to reverse. It drills into each bar with a lower-timeframe scan, distributes the intrabar volume across price by true overlap, splits it into graded buy/sell pressure, and renders it as a footprint anchored by POC, Delta POC, intrabar VWAP and the Value Area. On top of that it runs one idea from auction theory that conventional profile tools ignore: a market doesn't turn where volume is heavy — it turns where the auction runs out of business. The Contrarian Engine finds the bars where aggression achieved nothing, grades them 0–10, and fades them back toward value.

Most footprint tools describe. This one takes a side.

🌊 Intrabar Footprint Engine — the core. A lower-timeframe scan breaks each chart bar into its internal prints and rebuilds the auction that produced it. Granularity is adjustable (1 Tick / 1S / 5S / 15S / 1M / 5M) or Auto-scaled to your chart, with an automatic fallback resolution — if your plan or symbol won't serve the resolution you asked for, the engine silently drops to one that works instead of drawing a blank chart.

🧮 Overlap-Proportional Allocation — the accuracy differentiator. Conventional intrabar profiles smear each print's volume equally across every row it touches, which fattens the profile and drags the POC toward wide bars. APEX Contra Flow weights every row by the exact price overlap between the intrabar's range and that row. The shape you read is the shape that traded.

⚖️ Graded Buy/Sell Classification — not close >= open. On tick data the engine classifies against bid/ask (at-or-above ask = buy, at-or-below bid = sell, interpolated between). Off tick data it uses a tunable blend of close-location-in-range and body direction. Delta becomes a gradient, not a coin flip — so a bar that closed flat but was bought all the way up no longer reads as neutral.

🎯 POC · Delta POC · Intrabar VWAP — three separate reads on one candle. The Volume POC is where trade concentrated. The Delta POC is where the largest one-sided delta sits — the two diverging is a tell in itself. The intrabar VWAP marks the candle's true average traded price.

🧲 Value Area (VA) — computed by true value-area expansion outward from the POC at your chosen percentage, drawn as a clean outline with everything outside it dimmed back. Fair value framed; the rest fades.

🔺 Diagonal Imbalances & Stacked Runs — every row is tested diagonally: buy at a level against sell one level below, sell against buy one level above. Rows clearing your ratio are marked ◆ and coloured by side. Consecutive runs are counted — stacked imbalance sitting at the extreme is exhaustion evidence, not strength.

🕯️ Excess vs Unfinished Auction — the read almost nothing else surfaces. Thin single prints at a bar's extreme (·) are excess: the auction rejected that price and finished. Heavy volume parked at the extreme is unfinished business — an untested magnet price will likely come back for. One says reversal, the other says return.

🔠 Auction Shape Classification — P / b / D / B — real market-profile logic, applied per candle.
▪️ P — POC in the upper third, thin below: the rally was short covering, not fresh buying. Weak. Fade it.
▪️ b — POC in the lower third, thin above: long liquidation / capitulation. Fade it.
▪️ D — balanced auction, POC mid-range. Rotation back to the middle.
▪️ B — double distribution (two volume clusters split by a thin gap). This is a trending auction — and it vetoes the fade outright. The single most valuable filter in the tool is the one that tells you to stand down.

🏆 0–10 Contrarian Conviction Score — the power-ranking. Each fade candidate earns a live grade from seven weighted, principled factors, every one with a fixed directional sign:
▪️ Effort without result — heavy relative volume and delta that produced no body.
▪️ Trapped delta — delta pushing one way while the candle closes the other. Someone is offside.
▪️ Wick rejection — how violently the extreme was defended.
▪️ Excess — thin tail at the extreme being faded (finished auction).
▪️ Auction shape — P against a high, b against a low.
▪️ CVD divergence — a new price extreme that cumulative delta refused to confirm.
▪️ Stacked imbalance at the extreme — aggression stacking into a wall.
Resolved to a tier: WK → MOD → STRONG → V.STRONG → EXTREME.

🚪 Context Gates — why the signals stay rare. A score alone fires nothing. The bar must also print a new N-bar extreme, stretch a configurable ATR distance beyond its mean, clear a cooldown, and survive the B-shape veto. Fading strength in a trend is how contrarians die; these gates exist to stop it.

🎯 Fade Signals, Targets & Invalidation — one clean FADE ▲ / FADE ▼ label carrying the score. A dotted magnet line projects to the target: the nearest naked POC in the fade direction, or the candle's own POC if none is standing. A tick marks the invalidation extreme. Hover the label for the full read — score, tier, auction shape, value migration, delta, relative volume, POC, VWAP and the LTF actually used.

📍 Naked POC Magnets — high-conviction candles leave their POC extended to the right until price trades back through it, then it's removed. Untested POCs are unfinished business — and they double as the fade target.

📖 Legend Key — a static, self-adapting key (bottom-right by default). It lists only the glyphs you have switched on, and reads your live settings — your imbalance ratio, your VA %, your score threshold — so it can never drift out of sync with the chart.

🎨 Nine Dark-Native Themes — Obsidian (default), Institutional, Aurora, Neon, Phantom, Solar, Ice, Plasma and Mono — every one tuned to read on a black background, plus full custom buy/sell/POC overrides.

🧹 Clean-Chart Discipline — no dashboard, by design. No panel, no stat block, no clutter competing with price. The profile is the interface; the score lives inside the candle that earned it, the reasoning lives in the tooltip. Bar delta, CVD, contrarian score and bar volume stream to the Data Window for anyone who wants the raw series.

🔒 Honest & Non-Repainting Core — fade signals fire on confirmed bars only and never repaint away once printed. No signal is ever hidden, deleted or de-rated to flatter the chart. The footprint of the live, forming candle naturally refreshes as it builds — that is inherent to reconstructing order flow in real time, not a defect — and every closed bar is fixed. The 0–10 score is a descriptive auction framework for ranking attention, not a backtested edge.

🔔 Native Alerts — Fade Long, Fade Short, and Any Fade.

🔧 Fully Customizable — profile basis (Volume / Delta), granularity, rows, bar length, classification method and blend weight, VA %, POC / Delta-POC / VWAP / imbalance / excess toggles, imbalance ratio, min score, extreme lookback, mean length and ATR extension, CVD divergence lookback, cooldown, target length, naked-POC threshold and cap, theme, out-of-value transparency, legend position and size.

🎯 Why this is different — profile tools show you where volume is and leave the conclusion to you. Footprint tools show you delta and leave the conclusion to you. APEX Contra Flow classifies the auction, tells you whether it finished or is still trending, refuses to fade the ones that are trending, and puts a graded 0–10 case for the reversal inside the candle that made it. You read where the auction broke, why it's exhausted, and where it should rotate back to — at a glance.

🚀 Apply to Gold (XAUUSD), Silver, Forex, Crypto, Indices and Futures on any intraday timeframe (volume-bearing symbols).

💡 Cleanest setup: an indicator cannot hide the chart's own candles — right-click the chart → Settings → Symbol → uncheck Body / Borders / Wick to let the footprint stand alone.

🎯 How To Trade It — Two Approaches

Everything hinges on one question the tool answers: has this auction finished, or is it still trending? Finished auctions rotate. Trending auctions run you over.

◾ 1) Fade the finished auction → rotate to value (the core thesis)

Use on STRONG / V.STRONG / EXTREME scores (≥7) where the grade is built on excess, trapped delta and CVD divergence — and the shape is P at a high or b at a low.

▪️ Wait for the FADE ▼ / FADE ▲ to print on the confirmed bar — the gates have already checked the new extreme, the ATR extension and the shape veto.
▪️ Entry: on the signal close, or on a shallow re-test of the faded extreme that fails to make a new one.
▪️ Stop: beyond the invalidation tick at the wick extreme. If price closes decisively through and accepts there, the auction wasn't finished — stand aside or flip to Approach 2.
▪️ Targets: the dotted magnet line — the nearest naked POC, else the candle's POC. The opposite Value-Area edge if rotation extends.

⚖️ The cleanest version: price spikes to a new 10-bar high, stretches beyond its mean, prints a long upper wick on heavy volume with positive delta but closes in the lower half (trapped buyers), the top rows are thin (excess), the POC sits high (P — short covering), and CVD refuses to confirm the new high. Score prints 8.4 EXT. That confluence is the exact move this tool was built to frame.

◾ 2) Stand down — and trade the other side

The tool tells you when not to fade, which is worth as much as the signal.

▪️ Shape = B (double distribution) — the auction is trending and building a second distribution. The veto fires. Do not fade; look for continuation on the pullback into the lower distribution instead.
▪️ No excess, heavy volume at the extreme — unfinished business. Price is likely to return to that price rather than reverse from it.
▪️ Signals fire and immediately fail, repeatedly — one-sided flow is expanding. Trade with it into the next naked POC.

Rule of thumb: ⭐ High score + excess + P/b shape + CVD divergence → expect rotation, fade toward the POC. ⭐ B shape, no excess, or price accepting beyond the level → expect follow-through, trade the break toward the next naked POC.

⚠️ IMPORTANT NOTICE: APEX Contra Flow reconstructs estimated order flow from lower-timeframe data. Intrabar delta, absorption and buy/sell classification are an approximation of true tape, not exchange order-book data — off tick resolution the buy/sell split is inferred from price behaviour, not observed aggression. The 0–10 contrarian score is a descriptive auction framework — NOT a backtested signal and NOT a standalone trade trigger. Fading extremes is inherently a counter-trend activity and carries real risk of repeated stop-outs in a trending market; the shape veto reduces this but cannot eliminate it. The indicator requires a volume-bearing symbol. Always combine it with your own strategy, price-action analysis and risk management. Past behaviour does not guarantee future results.

## Source Code

````pine
//@version=6
indicator("APEX Contra Flow", overlay = true,
     max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, calc_bars_count = 500)

gP        = "◆ Footprint Engine"
profType  = input.string("Volume", "Profile Basis", options = ["Volume", "Delta"], group = gP, tooltip = "Volume: bar length = traded volume per level. Delta: bar length = |buy-sell| per level, colored by delta sign.")
granInput = input.string("Auto", "Intrabar Granularity", options = ["Auto", "1 Tick", "1 Second", "5 Second", "15 Second", "1 Minute", "5 Minute"], group = gP, tooltip = "Lower timeframe used to reconstruct each candle's internal order flow. Auto scales to the chart timeframe. If the selected resolution returns no data (plan limits), the engine falls back automatically.")
rows      = input.int(14, "Profile Rows", minval = 5, maxval = 60, group = gP)
maxBlocks = input.int(10, "Max Bar Length", minval = 5, maxval = 20, group = gP, tooltip = "Longest bar (block characters) for the highest-volume level.")
clsMode   = input.string("Auto", "Volume Classification", options = ["Auto", "Bid / Ask (Tick)", "Close Location", "Body Direction", "Blend"], group = gP, tooltip = "How each intrabar's volume is split into buy vs sell.\nAuto: bid/ask when on tick data, otherwise Blend.\nClose Location: buy share = where the intrabar closed inside its own range.\nBody Direction: classic binary up/down.\nBlend: weighted mix of the two.")
locBlend  = input.int(65, "Blend — Close Location %", minval = 0, maxval = 100, group = gP, tooltip = "Used by Auto/Blend. 100 = pure close-location weighting, 0 = pure body direction.")

gL        = "◆ Auction Levels"
showVA    = input.bool(true, "Value Area Highlight", group = gL, tooltip = "Colors value-area levels and dims the rest.")
vaPercent = input.float(70, "Value Area %", minval = 40, maxval = 95, step = 5, group = gL)
showVABox = input.bool(true, "Value Area Outline", group = gL)
showPOC   = input.bool(true, "Volume POC", group = gL)
showDPOC  = input.bool(true, "Delta POC Marker", group = gL, tooltip = "Marks the level holding the largest one-sided delta.")
showVWAP  = input.bool(false, "Intrabar VWAP Dot", group = gL)
showImb   = input.bool(true, "Diagonal Imbalance Marks", group = gL)
imbRatio  = input.float(3.0, "Imbalance Ratio", minval = 1.5, maxval = 10, step = 0.5, group = gL, tooltip = "Diagonal buy/sell ratio that counts as an imbalance. 3+ consecutive stacked = exhaustion evidence.")
showNodes = input.bool(true, "Excess / LVN Tail Marks", group = gL, tooltip = "Marks thin single-print rows at the bar extremes — the 'excess' that confirms a finished auction.")

gC        = "◆ Contrarian Engine"
showSig   = input.bool(true, "Fade Signals", group = gC, tooltip = "Fires FADE ▲ / FADE ▼ when the auction shows exhaustion against the immediate move.")
minScore  = input.float(6.0, "Min Conviction Score", minval = 0, maxval = 10, step = 0.5, group = gC)
extLen    = input.int(10, "Local Extreme Lookback", minval = 2, maxval = 100, group = gC, tooltip = "The bar must print a new high/low over this many bars to qualify as a fade candidate.")
reqExt    = input.bool(true, "Require Mean Extension", group = gC)
ctxLen    = input.int(34, "Mean Length (EMA)", minval = 5, maxval = 200, group = gC)
ctxMult   = input.float(1.0, "Extension (ATR)", minval = 0, maxval = 6, step = 0.25, group = gC, tooltip = "How far beyond the mean the extreme must reach before a fade is allowed.")
divLen    = input.int(14, "CVD Divergence Lookback", minval = 3, maxval = 100, group = gC)
showZoneText = input.bool(true, "Score Text In Fade Candles", group = gC)
showTgt   = input.bool(true, "Fade Target / Invalidation", group = gC, tooltip = "Dotted magnet line to the fade target (nearest naked POC, else this candle's POC) and a tick at the invalidation extreme.")
tgtBars   = input.int(12, "Target Line Length", minval = 2, maxval = 60, group = gC)
coolBars  = input.int(5, "Signal Cooldown (bars)", minval = 0, maxval = 50, group = gC)

gN        = "◆ Naked POC Magnets"
showNaked = input.bool(true, "Track Untested POCs", group = gN, tooltip = "Extends a strong candle's POC to the right until price trades back through it, then removes it.")
nakedMin  = input.float(5.5, "Naked POC Min Score", minval = 0, maxval = 10, step = 0.5, group = gN)
nakedMax  = input.int(10, "Max Active Naked POCs", minval = 1, maxval = 30, group = gN)

gD         = "◆ Theme"
themeInput = input.string("Obsidian", "Color Theme", options = ["Obsidian", "Institutional", "Aurora", "Neon", "Phantom", "Solar", "Ice", "Plasma", "Mono"], group = gD, tooltip = "All themes are tuned for dark / black chart backgrounds.")
useCustom  = input.bool(false, "Use Custom Colors", group = gD)
cuBuy      = input.color(#00E5A0, "Custom Buy", group = gD, inline = "cc1")
cuSell     = input.color(#FF2D6F, "Custom Sell", group = gD, inline = "cc1")
cuPoc      = input.color(#FFD24A, "Custom POC", group = gD, inline = "cc2")
dimPct     = input.int(35, "Out-Of-Value Transparency", minval = 0, maxval = 90, group = gD, tooltip = "How far levels outside the value area fade back. Higher = dimmer.")

gLg        = "◆ Legend Key"
showLegend = input.bool(true, "Show Legend Key", group = gLg, tooltip = "A static key explaining the glyphs and level colors. Only rows for enabled features are listed.")
legPos     = input.string("Bottom Right", "Position", options = ["Bottom Right", "Bottom Left", "Middle Right", "Top Right", "Top Left"], group = gLg)
legSize    = input.string("Small", "Text Size", options = ["Tiny", "Small", "Normal"], group = gLg)

var color cBull = na
var color cBear = na
var color cPoc  = na
var color cNeut = na
var color cAcc  = na
if barstate.isfirst
    if themeInput == "Obsidian"
        cBull := #00E5A0
        cBear := #FF2D6F
        cPoc  := #FFD24A
        cNeut := #4A5262
        cAcc  := #7C5CFF
    else if themeInput == "Institutional"
        cBull := #17A98A
        cBear := #C0334D
        cPoc  := #D4E157
        cNeut := #606876
        cAcc  := #7458A6
    else if themeInput == "Aurora"
        cBull := #2DD4BF
        cBear := #F471B5
        cPoc  := #FFD166
        cNeut := #545C6A
        cAcc  := #A78BFA
    else if themeInput == "Neon"
        cBull := #00F5D4
        cBear := #FF4466
        cPoc  := #FFE066
        cNeut := #5A6472
        cAcc  := #6C63FF
    else if themeInput == "Phantom"
        cBull := #06B6D4
        cBear := #EC4899
        cPoc  := #FBBF24
        cNeut := #59606B
        cAcc  := #BB86FC
    else if themeInput == "Solar"
        cBull := #FF9800
        cBear := #42A5F5
        cPoc  := #FFEB3B
        cNeut := #5E5E5E
        cAcc  := #26C6DA
    else if themeInput == "Ice"
        cBull := #38BDF8
        cBear := #FB7185
        cPoc  := #E2E8F0
        cNeut := #57647A
        cAcc  := #818CF8
    else if themeInput == "Plasma"
        cBull := #00E5FF
        cBear := #FF3D71
        cPoc  := #FFC400
        cNeut := #5A6670
        cAcc  := #D500F9
    else
        cBull := #E6E6E6
        cBear := #8A9098
        cPoc  := #FFFFFF
        cNeut := #4A4A4A
        cAcc  := #B0B0B0

color BUY  = useCustom ? cuBuy : cBull
color SELL = useCustom ? cuSell : cBear
color POCC = useCustom ? cuPoc : cPoc
color NEUT = cNeut
color ACC  = cAcc

clamp(float v, float lo, float hi) => math.max(lo, math.min(hi, v))
safeDiv(float a, float b) => b == 0.0 ? 0.0 : a / b

tierShort(float sc) => sc >= 8.5 ? "EXT" : sc >= 7 ? "V.STR" : sc >= 5.5 ? "STR" : sc >= 4 ? "MOD" : "WK"

makeBlocks(int n) =>
    int c = math.max(1, math.min(n, maxBlocks))
    string s = ""
    for i = 1 to c
        s := s + "█"
    s

var string tfAuto = "1S"
var string tfFb   = "1"
if barstate.isfirst
    int cs = timeframe.in_seconds()
    tfAuto := cs >= 14400 ? "15" : cs >= 3600 ? "5" : cs >= 900 ? "1" : cs >= 300 ? "15S" : cs >= 60 ? "5S" : "1S"
    tfFb   := cs >= 60 ? "1" : timeframe.period

string tfPri = switch granInput
    "Auto"      => tfAuto
    "1 Tick"    => "1T"
    "1 Second"  => "1S"
    "5 Second"  => "5S"
    "15 Second" => "15S"
    "1 Minute"  => "1"
    "5 Minute"  => "5"
    => tfAuto

buyShare() =>
    float w = 0.5
    bool tickOk = not na(bid) and not na(ask) and ask > bid
    bool useQuote = tickOk and (clsMode == "Auto" or clsMode == "Bid / Ask (Tick)")
    if useQuote
        float mid = (bid + ask) * 0.5
        if close >= ask
            w := 1.0
        else if close <= bid
            w := 0.0
        else
            w := 0.5 + 0.5 * (close - mid) / math.max(ask - mid, syminfo.mintick)
    else
        float r   = math.max(high - low, syminfo.mintick)
        float loc = (close - low) / r
        float bs  = close > open ? 1.0 : close < open ? 0.0 : 0.5
        float k   = locBlend / 100.0
        w := switch clsMode
            "Close Location" => loc
            "Body Direction" => bs
            => k * loc + (1.0 - k) * bs
    clamp(w, 0.0, 1.0)

[pH, pL, pV, pB] = request.security_lower_tf("", tfPri, [high, low, volume, buyShare()], ignore_invalid_timeframe = true)
[fH, fL, fV, fB] = request.security_lower_tf("", tfFb,  [high, low, volume, buyShare()], ignore_invalid_timeframe = true)

int nPri = 0
if not na(pV)
    nPri := pV.size()
int nFb = 0
if not na(fV)
    nFb := fV.size()
bool usePri = nPri > 0

array<float> ltH = usePri ? pH : fH
array<float> ltL = usePri ? pL : fL
array<float> ltV = usePri ? pV : fV
array<float> ltB = usePri ? pB : fB
int nSub = usePri ? nPri : nFb
string tfUsed = usePri ? tfPri : tfFb

float barBuy  = 0.0
float barSell = 0.0
if nSub > 0
    for i = 0 to nSub - 1
        float v  = ltV.get(i)
        float bf = ltB.get(i)
        barBuy  := barBuy  + v * bf
        barSell := barSell + v * (1.0 - bf)
float barVol   = barBuy + barSell
float barDelta = barBuy - barSell

var float cvd = 0.0
cvd := (barstate.isfirst ? 0.0 : nz(cvd[1])) + barDelta

float avgVol = ta.sma(volume, 20)
float atr14  = ta.atr(14)
float emaCtx = ta.ema(close, ctxLen)
float hiPrev = ta.highest(high, extLen)[1]
float loPrev = ta.lowest(low, extLen)[1]
float cvdHiP = ta.highest(cvd, divLen)[1]
float cvdLoP = ta.lowest(cvd, divLen)[1]

type NakedPOC
    line ln
    float price
    int born
var array<NakedPOC> npocs = array.new<NakedPOC>()

var float prevPOC = na
var int   lastSig = -9999

float ccs      = 0.0
int   fadeDir  = 0
bool  fireLong = false
bool  fireShort = false

if nSub > 0 and high > low and barVol > 0
    float rng  = high - low
    float step = rng / rows
    array<float> vol  = array.new_float(rows, 0.0)
    array<float> buy  = array.new_float(rows, 0.0)
    array<float> sell = array.new_float(rows, 0.0)

    for i = 0 to nSub - 1
        float sh = ltH.get(i)
        float sl = ltL.get(i)
        float sv = ltV.get(i)
        float bf = ltB.get(i)
        int bot = int(clamp(math.floor((sl - low) / step), 0, rows - 1))
        int top = int(clamp(math.floor((sh - low) / step), 0, rows - 1))
        float sr = math.max(sh - sl, syminfo.mintick)
        for x = bot to top
            float rBot = low + step * x
            float rTop = rBot + step
            float w = 1.0
            if top > bot
                w := clamp(safeDiv(math.max(0.0, math.min(rTop, sh) - math.max(rBot, sl)), sr), 0.0, 1.0)
            if w > 0
                vol.set(x,  vol.get(x)  + sv * w)
                buy.set(x,  buy.get(x)  + sv * bf * w)
                sell.set(x, sell.get(x) + sv * (1.0 - bf) * w)

    float maxVol   = vol.max()
    float minVol   = vol.min()
    float totalVol = vol.sum()
    int   pocIdx   = vol.indexof(maxVol)
    float pocPrice = low + step * (pocIdx + 0.5)

    int   dpocIdx = 0
    float dpocAbs = -1.0
    float vwapNum = 0.0
    for i = 0 to rows - 1
        float ad = math.abs(buy.get(i) - sell.get(i))
        if ad > dpocAbs
            dpocAbs := ad
            dpocIdx := i
        vwapNum := vwapNum + (low + step * (i + 0.5)) * vol.get(i)
    float barVwap = safeDiv(vwapNum, totalVol)

    int vahIdx = pocIdx
    int valIdx = pocIdx
    float accum = maxVol
    float target = totalVol * (vaPercent / 100)
    int up = pocIdx + 1
    int dn = pocIdx - 1
    while accum < target and (up <= rows - 1 or dn >= 0)
        float uV = -1.0
        float dV = -1.0
        if up <= rows - 1
            uV := vol.get(up)
        if dn >= 0
            dV := vol.get(dn)
        if uV >= dV
            accum := accum + uV
            vahIdx := up
            up := up + 1
        else
            accum := accum + dV
            valIdx := dn
            dn := dn - 1
    float vah = low + step * (vahIdx + 1)
    float val = low + step * valIdx

    array<bool> bImbA = array.new_bool(rows, false)
    array<bool> sImbA = array.new_bool(rows, false)
    int curB = 0
    int curS = 0
    int maxStk = 0
    int stkDir = 0
    int stkTop = 0
    for i = 0 to rows - 1
        bool bImb = false
        bool sImb = false
        if i > 0
            float ps = sell.get(i - 1)
            if buy.get(i) > 0 and buy.get(i) > math.max(ps, 1e-9) * imbRatio
                bImb := true
        if i < rows - 1
            float nb = buy.get(i + 1)
            if sell.get(i) > 0 and sell.get(i) > math.max(nb, 1e-9) * imbRatio
                sImb := true
        bImbA.set(i, bImb)
        sImbA.set(i, sImb)
        if bImb
            curB := curB + 1
            curS := 0
        else if sImb
            curS := curS + 1
            curB := 0
        else
            curB := 0
            curS := 0
        if curB > maxStk
            maxStk := curB
            stkDir := 1
            stkTop := i
        if curS > maxStk
            maxStk := curS
            stkDir := -1
            stkTop := i

    float pocLoc = (pocIdx + 0.5) / rows
    int hvnFirst = -1
    int hvnLast  = -1
    for i = 0 to rows - 1
        if vol.get(i) >= 0.70 * maxVol
            if hvnFirst < 0
                hvnFirst := i
            hvnLast := i
    bool bimodal = false
    if hvnLast - hvnFirst >= 3
        int thin = 0
        for i = hvnFirst + 1 to hvnLast - 1
            if vol.get(i) < 0.35 * maxVol
                thin := thin + 1
        bimodal := thin >= 2
    string shape = bimodal ? "B" : pocLoc >= 0.62 ? "P" : pocLoc <= 0.38 ? "b" : "D"

    float expRow  = safeDiv(totalVol, rows)
    int   tIdx2   = int(math.max(rows - 2, 0))
    int   bIdx2   = int(math.min(1, rows - 1))
    float topTail = safeDiv(vol.get(rows - 1) + vol.get(tIdx2), 2)
    float botTail = safeDiv(vol.get(0) + vol.get(bIdx2), 2)
    float excessUp = clamp(1.0 - safeDiv(topTail, math.max(expRow, 1e-9)), 0.0, 1.0)
    float excessDn = clamp(1.0 - safeDiv(botTail, math.max(expRow, 1e-9)), 0.0, 1.0)

    float body   = math.abs(close - open)
    float upWick = high - math.max(open, close)
    float dnWick = math.min(open, close) - low
    float relVol = safeDiv(barVol, nz(avgVol, barVol))
    float dDom   = safeDiv(math.abs(barDelta), barVol)
    float mid    = (high + low) / 2

    bool newHi = not na(hiPrev) and high > hiPrev
    bool newLo = not na(loPrev) and low  < loPrev
    bool stretchUp = not reqExt or (not na(emaCtx) and not na(atr14) and high >= emaCtx + ctxMult * atr14)
    bool stretchDn = not reqExt or (not na(emaCtx) and not na(atr14) and low  <= emaCtx - ctxMult * atr14)

    bool candShort = newHi and stretchUp and upWick >= dnWick
    bool candLong  = newLo and stretchDn and dnWick >= upWick

    float cEffort = clamp((relVol - 1.0) / 1.5, 0, 1) * clamp(1.0 - safeDiv(body, rng), 0, 1)

    if candShort or candLong
        float cWick   = 0.0
        float cTrap   = 0.0
        float cExcess = 0.0
        float cShape  = 0.0
        float cDiv    = 0.0
        float cImb    = 0.0

        if candShort
            fadeDir := -1
            cWick   := clamp(safeDiv(upWick, rng) / 0.50, 0, 1)
            cTrap   := barDelta > 0 and close < mid ? clamp(dDom / 0.50, 0, 1) : 0.0
            cExcess := excessUp
            cShape  := shape == "P" ? clamp((pocLoc - 0.50) / 0.35, 0, 1) : 0.0
            cDiv    := not na(cvdHiP) and cvd < cvdHiP ? 1.0 : 0.0
            cImb    := stkDir == -1 and stkTop >= int(rows * 0.6) ? clamp(maxStk / 4.0, 0, 1) : 0.0
        else
            fadeDir := 1
            cWick   := clamp(safeDiv(dnWick, rng) / 0.50, 0, 1)
            cTrap   := barDelta < 0 and close > mid ? clamp(dDom / 0.50, 0, 1) : 0.0
            cExcess := excessDn
            cShape  := shape == "b" ? clamp((0.50 - pocLoc) / 0.35, 0, 1) : 0.0
            cDiv    := not na(cvdLoP) and cvd > cvdLoP ? 1.0 : 0.0
            cImb    := stkDir == 1 and stkTop <= int(rows * 0.4) ? clamp(maxStk / 4.0, 0, 1) : 0.0

        float raw = 1.6 * cWick + 1.8 * cEffort + 1.8 * cTrap + 1.4 * cExcess + 1.4 * cShape + 1.4 * cDiv + 0.6 * cImb
        ccs := clamp(raw * (shape == "B" ? 0.55 : 1.0), 0, 10)

    float amax = 0.0
    if profType == "Delta"
        for j = 0 to rows - 1
            amax := math.max(amax, math.abs(buy.get(j) - sell.get(j)))
    float metricMax = profType == "Delta" ? amax : maxVol
    float metricMin = profType == "Delta" ? 0.0 : minVol
    float mRange = metricMax - metricMin

    bool upCandle = close >= open
    color tint = upCandle ? BUY : SELL

    for i = 0 to rows - 1
        float lvlBot = low + step * i
        float lvlTop = lvlBot + step
        float metric = profType == "Delta" ? math.abs(buy.get(i) - sell.get(i)) : vol.get(i)
        int norm = mRange > 0 ? int(math.round(1 + (metric - metricMin) * (maxBlocks - 1) / mRange)) : 1
        string blocks = makeBlocks(norm)
        bool inVA = i >= valIdx and i <= vahIdx

        color col = na
        if profType == "Delta"
            float d = buy.get(i) - sell.get(i)
            color dt = d >= 0 ? BUY : SELL
            col := color.from_gradient(norm, 1, maxBlocks, color.new(dt, 60), dt)
        else
            col := color.from_gradient(norm, 1, maxBlocks, color.new(tint, 60), tint)
        if showVA and not inVA
            col := color.new(NEUT, dimPct)
        if showImb and (bImbA.get(i) or sImbA.get(i))
            col := bImbA.get(i) ? BUY : SELL
        if showDPOC and i == dpocIdx and i != pocIdx
            col := ACC
        if showPOC and i == pocIdx
            col := POCC

        string cellText = blocks
        if showImb and (bImbA.get(i) or sImbA.get(i))
            cellText := cellText + " ◆"
        if showNodes and vol.get(i) < 0.18 * maxVol and (i >= rows - 2 or i <= 1)
            cellText := cellText + " ·"
        if showVWAP and not na(barVwap) and barVwap >= lvlBot and barVwap < lvlTop
            cellText := cellText + " ◇"
        if showZoneText and i == pocIdx and ccs >= minScore and fadeDir != 0
            cellText := cellText + "  " + str.tostring(ccs, "#.0") + " " + tierShort(ccs) + " " + shape

        box.new(bar_index, lvlTop, bar_index + 1, lvlBot, text = cellText, text_halign = text.align_left, text_valign = text.align_center, bgcolor = #00000000, border_color = color(na), text_color = col, force_overlay = true)

    if showVA and showVABox
        box.new(bar_index, vah, bar_index + 1, val, bgcolor = color(na), border_color = color.new(NEUT, 50), border_width = 1, force_overlay = true)

    bool cool = bar_index - lastSig >= coolBars
    if showSig and barstate.isconfirmed and fadeDir != 0 and ccs >= minScore and shape != "B" and cool
        lastSig := bar_index
        color scol = fadeDir == 1 ? BUY : SELL
        string txt = (fadeDir == 1 ? "FADE ▲ " : "FADE ▼ ") + str.tostring(ccs, "#.0")
        string mig = na(prevPOC) ? "n/a" : pocPrice > prevPOC ? "value up" : pocPrice < prevPOC ? "value down" : "value flat"
        string tip = "Contrarian conviction " + str.tostring(ccs, "#.0") + "/10 · " + tierShort(ccs) +
             "\nAuction shape: " + shape + "  ·  " + mig +
             "\nDelta: " + str.tostring(barDelta, format.volume) + "  ·  Rel vol: " + str.tostring(relVol, "#.00") + "x" +
             "\nPOC: " + str.tostring(pocPrice, format.mintick) + "  ·  VWAP: " + str.tostring(barVwap, format.mintick) +
             "\nLTF: " + tfUsed
        label.new(bar_index, fadeDir == 1 ? low : high, txt, yloc = yloc.price,
             style = fadeDir == 1 ? label.style_label_up : label.style_label_down,
             color = color.new(scol, 12), textcolor = #FFFFFF, size = size.small, tooltip = tip, force_overlay = true)

        if fadeDir == 1
            fireLong := true
        else
            fireShort := true

        if showTgt
            float tgt = pocPrice
            float bestD = 1e12
            if npocs.size() > 0
                for k = 0 to npocs.size() - 1
                    NakedPOC nn = npocs.get(k)
                    bool okDir = fadeDir == 1 ? nn.price > close : nn.price < close
                    float dd = math.abs(nn.price - close)
                    if okDir and dd < bestD
                        bestD := dd
                        tgt := nn.price
            line.new(bar_index, tgt, bar_index + tgtBars, tgt, color = color.new(scol, 25), style = line.style_dotted, width = 1, force_overlay = true)
            line.new(bar_index, fadeDir == 1 ? low : high, bar_index + 2, fadeDir == 1 ? low : high, color = color.new(NEUT, 25), style = line.style_solid, width = 1, force_overlay = true)

    if showNaked and barstate.isconfirmed and ccs >= nakedMin and fadeDir != 0
        line nl = line.new(bar_index, pocPrice, bar_index + 1, pocPrice, color = color.new(POCC, 30), width = 2, force_overlay = true)
        npocs.push(NakedPOC.new(nl, pocPrice, bar_index))
        while npocs.size() > nakedMax
            NakedPOC old = npocs.shift()
            line.delete(old.ln)

    prevPOC := pocPrice

if showNaked and npocs.size() > 0
    for i = npocs.size() - 1 to 0
        if i < npocs.size()
            NakedPOC n = npocs.get(i)
            bool tested = bar_index > n.born and high >= n.price and low <= n.price
            if tested
                line.delete(n.ln)
                npocs.remove(i)
            else
                n.ln.set_x2(bar_index + 1)

var string lpos = switch legPos
    "Bottom Right"  => position.bottom_right
    "Bottom Left"   => position.bottom_left
    "Middle Right"  => position.middle_right
    "Top Right"     => position.top_right
    "Top Left"      => position.top_left
    => position.bottom_right
var string lsz = switch legSize
    "Tiny"   => size.tiny
    "Small"  => size.small
    "Normal" => size.normal
    => size.small

var table leg = table.new(lpos, 2, 10, bgcolor = color.new(#0B1220, 8), frame_color = color.new(ACC, 45), frame_width = 1, border_color = color.new(#0B1220, 45), border_width = 1, force_overlay = true)

legRow(int r, string glyph, color gcol, string meaning) =>
    table.cell(leg, 0, r, glyph, text_color = gcol, text_size = lsz, text_halign = text.align_center)
    table.cell(leg, 1, r, meaning, text_color = #C7D0DC, text_size = lsz, text_halign = text.align_left)

if barstate.islast and showLegend
    int r = 0
    table.merge_cells(leg, 0, 0, 1, 0)
    table.cell(leg, 0, 0, "APEX CONTRA — KEY", text_color = #E8EDF4, bgcolor = color.new(ACC, 74), text_size = lsz, text_halign = text.align_center)
    r := 1

    if showImb
        legRow(r, "◆", BUY,  "Buy imbalance — aggressive buying " + str.tostring(imbRatio, "#.#") + "× the sell side one level below")
        r := r + 1
        legRow(r, "◆", SELL, "Sell imbalance — aggressive selling " + str.tostring(imbRatio, "#.#") + "× the buy side one level above")
        r := r + 1
    if showVWAP
        legRow(r, "◇", #C7D0DC, "Intrabar VWAP — this candle's volume-weighted average price")
        r := r + 1
    if showNodes
        legRow(r, "·", NEUT, "Excess tail — thin single prints at the extreme (finished auction)")
        r := r + 1
    if showPOC
        legRow(r, "█", POCC, "POC — highest-volume level of the candle")
        r := r + 1
    if showDPOC
        legRow(r, "█", ACC, "Delta POC — level holding the largest one-sided delta")
        r := r + 1
    if showVA
        legRow(r, "█", color.new(NEUT, dimPct), "Outside value area (" + str.tostring(vaPercent, "#") + "%)")
        r := r + 1
    if showSig
        legRow(r, "▲▼", #E8EDF4, "Fade signal — contrarian score ≥ " + str.tostring(minScore, "#.0") + " (hover for detail)")
        r := r + 1

alertcondition(fireLong,  "APEX Contra — Fade Long",  "APEX CONTRA: exhaustion low, contrarian long fade.")
alertcondition(fireShort, "APEX Contra — Fade Short", "APEX CONTRA: exhaustion high, contrarian short fade.")
alertcondition(fireLong or fireShort, "APEX Contra — Any Fade", "APEX CONTRA: contrarian fade signal fired.")

plot(barDelta, "Bar Delta", color = barDelta >= 0 ? BUY : SELL, display = display.data_window)
plot(cvd, "CVD", color = cvd >= 0 ? BUY : SELL, display = display.data_window)
plot(ccs, "Contrarian Score", color = ACC, display = display.data_window)
plot(barVol, "Bar Volume", color = NEUT, display = display.data_window)
````
