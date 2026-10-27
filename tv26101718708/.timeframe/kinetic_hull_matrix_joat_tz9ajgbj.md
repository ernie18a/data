# Kinetic Hull Matrix [JOAT]

- url: https://www.tradingview.com/script/TZ9ajgbJ-Kinetic-Hull-Matrix-JOAT/
- type: indicator
- pine_id: PUB;247ed25bcb0f4ed789d9bf0eb24a4b4e
- version: 1.0

## Description

[b]Kinetic Hull Matrix [JOAT][/b]

[b]Overview[/b]

Kinetic Hull Matrix is an adaptive trend-following indicator centred on a Hull Moving Average cloud with ATR-proportional envelopes, a custom ADX engine, a 0–100 composite signal scoring system, and a multi-timeframe trend table — all rendered in a layered fill system that visually communicates trend strength and cloud penetration depth simultaneously. Retest signals fire when price touches the cloud boundary from within the trending direction, scored by four independent quality factors.

[image]https://www.tradingview.com/x/LGZe3npn/[/image]

[b]The Hull Moving Average — Why It Matters[/b]

The Hull Moving Average (HMA) was designed to reduce lag while maintaining smoothness. The calculation uses weighted moving averages at half-length and full-length, doubles the half-length result, subtracts the full-length result (creating a de-lagged series), then applies a final WMA at the square root of the length:

WMA(2 * WMA(src, n/2) - WMA(src, n), sqrt(n))

This produces a moving average that reacts significantly faster to price changes than a standard EMA or SMA of the same length, while filtering micro-noise through the final WMA pass. The result is a responsive midline that rarely produces whipsaws in trending markets.

[b]ATR-Adaptive Cloud Architecture[/b]

The HMA midline is expanded into a four-layer cloud using the current ATR:

- [b]Inner cloud (upper and lower bands):[/b] HullMid ± ATR × CloudMultiplier (default 1.0). This is the primary retest detection zone.
- [b]Outer bands:[/b] HullMid ± ATR × CloudMultiplier × OuterMultiplier (default 1.618, the golden ratio). These define the statistical extreme of the cloud envelope.

The cloud dynamically widens during volatile markets and contracts during compression — naturally adapting to market conditions without manual parameter changes.

Four fill layers are rendered between the bands using trend-coloured gradients: bright teal in uptrends, muted red in downtrends, creating an intuitive visual heat map of trend energy.

[b]Custom ADX Engine[/b]

Rather than relying on the built-in ta.dmi(), Kinetic Hull Matrix implements its own ADX from first principles:

1. Positive directional movement (plusDM) = max(high - high[1], 0) when high-to-high exceeds low-to-low
2. Negative directional movement (minusDM) = max(low[1] - low, 0) when low-to-low exceeds high-to-high
3. Both are smoothed via ta.rma() over the ADX length, then divided by the RMA of true range to produce +DI and -DI
4. The directional index DX = abs(+DI - -DI) / (+DI + -DI) * 100, finally smoothed via ta.rma() to produce ADX

This gives a transparent, auditable ADX implementation. Values above 25 indicate a trending regime; below 25 indicates ranging conditions. The dashboard and scoring system both use this value.

[b]Composite Signal Score (0–100)[/b]

A retest signal qualifies only when close price enters the inner cloud (touches upper cloud from above in a downtrend or lower cloud from below in an uptrend) while the candle closes back in the trend direction. The resulting signal is then scored:

- [b]Proximity score (up to 50):[/b] How deeply price penetrated into the cloud. Deeper retests score higher.
- [b]Volume score (up to 25):[/b] Current volume relative to its 20-bar SMA. Higher participation scores higher.
- [b]RSI score (up to 15):[/b] RSI directional headroom — long signals score better when RSI has room below 55, short signals when RSI has room above 45.
- [b]ADX score (up to 10):[/b] Raw ADX value × 0.4, capped at 10. Strong trends produce higher-quality retests.

Only signals meeting the configurable minimum score threshold (default 40) are displayed.

[b]S/R Line Stamping[/b]

Each confirmed retest signal stamps a horizontal dotted line at the close price, extending 60 bars forward. These lines serve as dynamic support (for bull retests) and resistance (for bear retests). Lines are automatically invalidated and deleted if price closes through them by more than 0.5 ATR — the indicator only keeps lines that have not been structurally broken.

[b]Multi-Timeframe Trend Table (Top Right)[/b]

Five user-configurable timeframes are assessed using the same dual-EMA logic (fast = HullLen/2, slow = HullLen). Each cell displays BULL or BEAR in the trend's colour. A "X/5 Bull" counter at the bottom summarises alignment. The table also shows current ADX value, RSI, and number of active S/R lines.

[b]Inputs Reference[/b]

[b]Hull Cloud[/b]
- Hull MA Length (21) — primary HMA period
- ATR Length (14) — period for ATR cloud width
- Cloud Width (1.0 ATR) — inner cloud half-width multiplier
- Outer Band Mult (1.618) — outer band golden-ratio expansion
- ADX Length (14) — custom ADX smoothing period
- Volume SMA Length (20) — reference for volume scoring
- RSI Length (14)

[b]Retest Detection[/b]
- Min Signal Score (40) — minimum composite score to display signal
- Max S/R Lines (8) — maximum simultaneous S/R lines on chart
- S/R Break Buffer (0.5 ATR) — tolerance before a line is considered broken
- Show Score Label / Show S/R Lines

[b]MTF Dashboard[/b]
- Show MTF Trend Table
- TF 1–5 — five independently configurable timeframes

[b]Visual[/b]
- Theme: Dark, Light, Auto

[b]How to Use[/b]

1. Apply to a liquid trending instrument. Allow warmup (roughly 3× Hull Length bars).
2. Identify the trend from cloud colour: teal fills = uptrend, red fills = downtrend.
3. Wait for price to dip into the inner cloud during an uptrend (or spike into it during a downtrend) and close back in the trend direction.
4. Check the score label — prefer grade 55+ (B or higher). Crosscheck with the MTF table: 4+ of 5 timeframes aligned significantly improves reliability.
5. The stamped S/R line from the retest level serves as a reference for re-entry if price pulls back again.

[b]Non-Repainting Design[/b]

All retest signals are gated by barstate.isconfirmed. MTF data uses lookahead_off. S/R line management runs only on confirmed bars. No visual element shifts position after the bar closes.

[b]Limitations[/b]

- In ranging, choppy markets, the cloud direction changes frequently and retest signals may have low predictive value. The ADX score component partially mitigates this, but consider increasing the minimum score threshold in low-trend environments.
- S/R lines accumulate during active trend periods. The max line count setting prevents chart clutter.
- MTF trend data requires request.security() calls per timeframe. On lower timeframes with very high bar counts, this may slightly affect indicator load time.

[b]Disclaimer[/b]

This indicator is for educational and informational purposes only. No signal scoring system guarantees future performance. Always use proper risk management and conduct independent analysis before trading.

Made with passion by officialjackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("Kinetic Hull Matrix [JOAT]", shorttitle="KHM [JOAT]", overlay=true,
          max_lines_count=200, max_labels_count=100)

// ─── INPUTS ──────────────────────────────────────────────────────────
var GRP_H = "Hull Cloud"
var GRP_R = "Retest Detection"
var GRP_M = "MTF Dashboard"
var GRP_V = "Visual"

i_hullLen   = input.int   (21,   "Hull MA Length",       group=GRP_H, minval=5)
i_atrLen    = input.int   (14,   "ATR Length",           group=GRP_H, minval=3)
i_cloudMult = input.float (1.0,  "Cloud Width (ATR x)",  group=GRP_H, minval=0.3, step=0.1)
i_outerMult = input.float (1.618,"Outer Band Mult",      group=GRP_H, minval=1.0, step=0.1)
i_adxLen    = input.int   (14,   "ADX Length",           group=GRP_H, minval=5)
i_volLen    = input.int   (20,   "Volume SMA Length",    group=GRP_H, minval=5)
i_rsiLen    = input.int   (14,   "RSI Length",           group=GRP_H, minval=2)

i_scoreMin  = input.int   (40,   "Min Signal Score",     group=GRP_R, minval=0, maxval=100)
i_maxSR     = input.int   (8,    "Max S/R Lines",        group=GRP_R, minval=2, maxval=20)
i_srBreak   = input.float (0.5,  "S/R Break Buffer (ATR x)", group=GRP_R, minval=0.1, step=0.1)
i_showScore = input.bool  (true, "Show Score Label",     group=GRP_R)
i_showSR    = input.bool  (true, "Show S/R Lines",       group=GRP_R)

i_showMTF   = input.bool  (true, "Show MTF Trend Table", group=GRP_M)
i_tf1       = input.string("1",  "TF 1",    group=GRP_M)
i_tf2       = input.string("5",  "TF 2",    group=GRP_M)
i_tf3       = input.string("15", "TF 3",    group=GRP_M)
i_tf4       = input.string("60", "TF 4",    group=GRP_M)
i_tf5       = input.string("240","TF 5",    group=GRP_M)

i_theme     = input.string("Auto","Theme",["Dark","Light","Auto"], group=GRP_V)

// ─── PALETTE ─────────────────────────────────────────────────────────
_isDark  = i_theme == "Auto" ? color.r(chart.bg_color) < 128 : i_theme == "Dark"
C_BULL   = color.rgb(0, 245, 212)
C_BEAR   = color.rgb(255, 68, 102)
C_GOLD   = color.rgb(255, 215, 0)
C_MIDL   = color.rgb(200, 130, 255)
C_SLATE  = color.rgb(96, 112, 128)
C_PANEL  = _isDark ? color.new(color.black, 80) : color.new(color.white, 75)
C_TXT    = _isDark ? color.white : color.black

// ─── HELPERS ─────────────────────────────────────────────────────────
safeDiv(float n, float d) =>
    d != 0.0 and not na(d) ? n / d : 0.0

f_hullMa(float src, simple int len) =>
    half  = int(len / 2)
    sqrtL = int(math.sqrt(float(len)))
    nz(ta.wma(ta.wma(src, half) * 2.0 - ta.wma(src, len), sqrtL), src)

f_adx(simple int len) =>
    plusDM  = high - high[1] > low[1] - low ? math.max(high - high[1], 0.0) : 0.0
    minusDM = low[1] - low > high - high[1] ? math.max(low[1] - low, 0.0)  : 0.0
    trueR   = ta.rma(ta.tr(true), len)
    pDI     = safeDiv(ta.rma(plusDM, len),  trueR) * 100.0
    mDI     = safeDiv(ta.rma(minusDM, len), trueR) * 100.0
    dxSum   = pDI + mDI
    dx      = dxSum > 0 ? math.abs(pDI - mDI) / dxSum * 100.0 : 0.0
    ta.rma(dx, len)

f_getTrend(simple string tf, simple int hLen) =>
    e1 = request.security(syminfo.tickerid, tf, ta.ema(close, hLen / 2),
          lookahead=barmerge.lookahead_off)
    e2 = request.security(syminfo.tickerid, tf, ta.ema(close, hLen),
          lookahead=barmerge.lookahead_off)
    e1 > e2 ? 1 : -1

// ─── CORE CALCULATIONS ───────────────────────────────────────────────
WARMUP   = math.max(i_hullLen * 3, 50)
isReady  = bar_index >= WARMUP

hullMid    = f_hullMa(close, i_hullLen)
atrVal     = ta.atr(i_atrLen)
cloudW     = atrVal * i_cloudMult
upperCloud = hullMid + cloudW
lowerCloud = hullMid - cloudW
outerU     = hullMid + cloudW * i_outerMult
outerL     = hullMid - cloudW * i_outerMult

fastEMA    = ta.ema(close, i_hullLen / 2)
slowEMA    = ta.ema(close, i_hullLen)
trendUp    = fastEMA > slowEMA
trendDn    = fastEMA < slowEMA

adxVal     = f_adx(i_adxLen)
rsiVal     = ta.rsi(close, i_rsiLen)
volSma     = ta.sma(volume, i_volLen)

// ─── RETEST DETECTION (confirmed) ────────────────────────────────────
retestBull = low  <= upperCloud and close > hullMid and close > open and trendUp  and isReady and barstate.isconfirmed
retestBear = high >= lowerCloud and close < hullMid and close < open and trendDn  and isReady and barstate.isconfirmed

// Composite Signal Score (0–100)
f_score(bool isBull) =>
    dep      = isBull ? math.max(upperCloud - low, 0.0)  : math.max(high - lowerCloud, 0.0)
    proxS    = math.min(safeDiv(dep, cloudW) * 50.0, 50.0)
    volS     = math.min(safeDiv(volume, math.max(volSma, 1.0)) * 15.0, 25.0)
    rsiS     = isBull ? math.min(math.max(55.0 - rsiVal, 0.0) * 0.5, 15.0) : math.min(math.max(rsiVal - 45.0, 0.0) * 0.5, 15.0)
    adxS     = math.min(adxVal * 0.4, 10.0)
    int(math.min(proxS + volS + rsiS + adxS, 100.0))

bullScore = retestBull ? f_score(true)  : 0
bearScore = retestBear ? f_score(false) : 0

bullSig = retestBull and bullScore >= i_scoreMin
bearSig = retestBear and bearScore >= i_scoreMin

// ─── S/R LINE MANAGEMENT ─────────────────────────────────────────────
var array<line>  srLines  = array.new<line>()
var array<float> srLevels = array.new<float>()

// Invalidate S/R on close break
if array.size(srLines) > 0
    atrBuf = atrVal * i_srBreak
    for i = array.size(srLines) - 1 to 0
        lvl = array.get(srLevels, i)
        if not na(lvl)
            wasBull = lvl <= close[1]  // was below close = support
            broken  = wasBull ? close < lvl - atrBuf : close > lvl + atrBuf
            if broken
                line.delete(array.get(srLines, i))
                array.remove(srLines, i)
                array.remove(srLevels, i)

// Add new S/R on confirmed retest signal
if (bullSig or bearSig) and i_showSR
    lvl  = close
    lc   = bullSig ? C_BULL : C_BEAR
    ln   = line.new(bar_index - 5, lvl, bar_index + 60, lvl,
           color=color.new(lc, 45), width=1, style=line.style_dotted)
    array.push(srLines,  ln)
    array.push(srLevels, lvl)
    if array.size(srLines) > i_maxSR
        line.delete(array.shift(srLines))
        array.shift(srLevels)

// Extend S/R lines
if array.size(srLines) > 0
    for i = 0 to array.size(srLines) - 1
        line.set_x2(array.get(srLines, i), bar_index + 1)

// ─── SIGNAL LABELS ───────────────────────────────────────────────────
if bullSig and i_showScore
    sc  = bullScore
    txt = "RETEST+\n" + str.tostring(sc)
    label.new(bar_index, lowerCloud, txt,
         color=color.new(C_BULL, 55), textcolor=color.white,
         style=label.style_label_up, size=size.small)

if bearSig and i_showScore
    sc  = bearScore
    txt = "RETEST-\n" + str.tostring(sc)
    label.new(bar_index, upperCloud, txt,
         color=color.new(C_BEAR, 55), textcolor=color.white,
         style=label.style_label_down, size=size.small)

// ─── CLOUD PLOTS & FILLS ─────────────────────────────────────────────
cloudClr = trendUp ? C_BULL : C_BEAR

pHullMid  = plot(hullMid,    "Hull Midline",    color=color.new(C_MIDL, 20), linewidth=2)
pUpperCld = plot(upperCloud, "Upper Cloud",     color=color.new(cloudClr, 75), display=display.none)
pLowerCld = plot(lowerCloud, "Lower Cloud",     color=color.new(cloudClr, 75), display=display.none)
pOuterU   = plot(outerU,     "Outer Upper",     color=color.new(cloudClr, 90), linewidth=1, style=plot.style_stepline)
pOuterL   = plot(outerL,     "Outer Lower",     color=color.new(cloudClr, 90), linewidth=1, style=plot.style_stepline)

fill(pUpperCld, pHullMid,  color=trendUp ? color.new(C_BULL, 78) : color.new(C_BEAR, 78), title="Cloud Upper Fill")
fill(pHullMid,  pLowerCld, color=trendUp ? color.new(C_BULL, 82) : color.new(C_BEAR, 82), title="Cloud Lower Fill")
fill(pOuterU,   pUpperCld, color=trendUp ? color.new(C_BULL, 93) : color.new(C_BEAR, 93), title="Outer Upper Fill")
fill(pLowerCld, pOuterL,   color=trendUp ? color.new(C_BULL, 93) : color.new(C_BEAR, 93), title="Outer Lower Fill")

// EMA trend lines (subtle)
plot(fastEMA, "Fast EMA", color=color.new(cloudClr, 65), linewidth=1)
plot(slowEMA, "Slow EMA", color=color.new(cloudClr, 50), linewidth=1)

// ─── SIGNAL SHAPES ───────────────────────────────────────────────────
plotshape(bullSig, title="Bull Retest", style=shape.triangleup,
     location=location.belowbar, color=C_BULL, size=size.small)
plotshape(bearSig, title="Bear Retest", style=shape.triangledown,
     location=location.abovebar, color=C_BEAR, size=size.small)

// ─── MTF TREND DATA ──────────────────────────────────────────────────
t1 = f_getTrend(i_tf1, i_hullLen)
t2 = f_getTrend(i_tf2, i_hullLen)
t3 = f_getTrend(i_tf3, i_hullLen)
t4 = f_getTrend(i_tf4, i_hullLen)
t5 = f_getTrend(i_tf5, i_hullLen)

bullCount = (t1 == 1 ? 1 : 0) + (t2 == 1 ? 1 : 0) + (t3 == 1 ? 1 : 0) + (t4 == 1 ? 1 : 0) + (t5 == 1 ? 1 : 0)

// ─── ALERTS ──────────────────────────────────────────────────────────
alertcondition(bullSig, "KHM Bull Retest [JOAT]",
     "Kinetic Hull Matrix: Bullish cloud retest confirmed")
alertcondition(bearSig, "KHM Bear Retest [JOAT]",
     "Kinetic Hull Matrix: Bearish cloud retest confirmed")

// ─── MTF DASHBOARD ───────────────────────────────────────────────────
f_trendCell(t, col, row, tfStr, tr) =>
    clr = tr == 1 ? C_BULL : C_BEAR
    txt = tr == 1 ? "BULL" : "BEAR"
    table.cell(t, col, row, tfStr, text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(t, col+1, row, txt, text_color=clr,   text_size=size.small, bgcolor=C_PANEL)

var table dash = table.new(position.top_right, 3, 8,
     bgcolor=C_PANEL, border_width=1, border_color=color.new(color.gray, 55))

if i_showMTF and barstate.islast
    adxStr    = adxVal >= 25 ? "TRENDING" : "RANGING"
    adxClr    = adxVal >= 25 ? C_GOLD : C_SLATE
    scoreStr  = str.tostring(bullCount) + "/5 Bull"
    scoreClr  = bullCount >= 4 ? C_BULL : bullCount <= 1 ? C_BEAR : C_GOLD

    table.cell(dash, 0, 0, "KHM [JOAT]", bgcolor=color.new(C_MIDL, 35),
         text_color=color.white, text_size=size.small)
    table.cell(dash, 1, 0, "MTF Trend", bgcolor=color.new(C_MIDL, 35),
         text_color=color.white, text_size=size.small)
    table.cell(dash, 2, 0, "Status", bgcolor=color.new(C_MIDL, 35),
         text_color=color.white, text_size=size.small)

    f_trendCell(dash, 0, 1, i_tf1, t1)
    table.cell(dash, 2, 1, adxStr, text_color=adxClr, text_size=size.small, bgcolor=C_PANEL)
    f_trendCell(dash, 0, 2, i_tf2, t2)
    table.cell(dash, 2, 2, "ADX " + str.tostring(math.round(adxVal, 1)),
         text_color=adxVal >= 25 ? C_GOLD : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
    f_trendCell(dash, 0, 3, i_tf3, t3)
    table.cell(dash, 2, 3, "RSI " + str.tostring(math.round(rsiVal, 1)),
         text_color=rsiVal > 60 ? C_BEAR : rsiVal < 40 ? C_BULL : C_TXT,
         text_size=size.small, bgcolor=C_PANEL)
    f_trendCell(dash, 0, 4, i_tf4, t4)
    table.cell(dash, 2, 4, "Score", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    f_trendCell(dash, 0, 5, i_tf5, t5)
    table.cell(dash, 2, 5, scoreStr, text_color=scoreClr, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 6, "Cloud Dir", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 6, trendUp ? "BULL" : "BEAR",
         text_color=trendUp ? C_BULL : C_BEAR, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 2, 6, "S/R Lines", text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 0, 7, "Last Signal",text_color=C_TXT, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 1, 7, bullSig ? "BULL " + str.tostring(bullScore) : bearSig ? "BEAR " + str.tostring(bearScore) : "NONE",
         text_color=bullSig ? C_BULL : bearSig ? C_BEAR : C_SLATE, text_size=size.small, bgcolor=C_PANEL)
    table.cell(dash, 2, 7, str.tostring(array.size(srLines)),
         text_color=C_GOLD, text_size=size.small, bgcolor=C_PANEL)
````
