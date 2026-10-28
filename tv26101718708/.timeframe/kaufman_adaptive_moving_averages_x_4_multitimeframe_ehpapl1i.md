# Kaufman Adaptive Moving Averages X 4 - Multi-timeframe

- url: https://www.tradingview.com/script/eHPapL1I-Kaufman-Adaptive-Moving-Averages-X-4-Multi-timeframe/
- type: indicator
- pine_id: PUB;6fecb76aa23746fba9eaf83786d83e3e
- version: 1.0

## Description

KAMA x 4 - MTF — Four adaptive momentum bands on one chart. A faster/slower Kaufman Adaptive Moving Average pair on your current timeframe and the same pair on a higher timeframe (HTF), each pair
tinted with a bull/bear fill so you read trend at a glance.

What you see - Chart-TF KAMA pair — short-term momentum read with a colored fill between the two lines.
- HTF KAMA pair — slower bias band defining the bigger-picture regime, with its own fill.
- Fills-only view — toggle either pair's lines off in the settings to keep just the colored bands. No need to touch the Style tab.

Presets
GOLD / METALS · FOREX · CRYPTO · INDICES · STOCKS · USER. Each preset tunes the four KAMAs to the volatility profile of that asset class. Pick USER to control every length manually.
HTF modes
- Auto — picks an HTF one step above your chart (1m → 5m, 5m → 15m, 15m → 1H, 30m → 2H, 1H → 4H, 4H → D, D → W).
- Custom — any timeframe you choose.

HTF data uses lookahead_off and gaps_off — no repaint.

Customisation
- Bullish / bearish colors for both KAMA pairs.
- Per-pair show toggles for both the lines and the fills.
- Optional bar-confirmation gate on color flips.
Alerts
- Slow / Fast KAMA color change (current TF)
- Fast × Slow bullish / bearish cross (current TF)
- HTF-aligned cross — fires only when the chart-TF cross agrees with the HTF KAMA slope. The highest-quality signal in the indicator.


Built for traders who want a clean MTF momentum view without stacking two copies of the same indicator on the chart.

## Source Code

````pine
//@version=6
indicator("$$$ KAMA x 4 - MTF $$$", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
preset             = input.string("GOLD / METALS", "Preset:", group="⚙️ General Settings", options=["GOLD / METALS","FOREX","CRYPTO","INDICES","STOCKS","USER"])
showCTFKAMA        = input(true, title ="Show Chart TF KAMAs", group="⚙️ General Settings", display = display.none )
showFill           = input(true,  title="Fill between Chart TM KAMAs", group="⚙️ General Settings", display=display.none)
showHTFKAMA        = input(true, title="Show HTF KAMAs", group="⚙️ General Settings", display=display.none)
showFill2           = input(true,  title="Fill between HTF KAMAs", group="⚙️ General Settings", display=display.none)
htfMode            = input.string("Custom", title="HTF Mode", options=["Auto","Custom"], group="⚙️ General Settings", display=display.none, tooltip = "When in Auto mode, the script chooses the proper HTF accoring to your current chart.")
htfTimeframe       = input.timeframe("15", title="HTF Timeframe (used when HTF Mode = Custom)", group="⚙️ General Settings", display=display.none)

col_buy = input.color(color.green, title = "Bullish", group="🐇 Chart TF KAMAs", display=display.none, inline = "sl1")
col_sell = input.color(color.red, title = "Bearish", group="🐇 Chart TF KAMAs", display=display.none, inline = "sl1")
length             = input(14,    title="Length",           group="🐇 Chart TF KAMAs", display=display.none)
fastLength         = input(14,    title="Fast EMA Length",  group="🐇 Chart TF KAMAs", display=display.none)
slowLength         = input(30,    title="Slow EMA Length",  group="🐇 Chart TF KAMAs", display=display.none)
src                = input(close, title="Source",           group="🐇 Chart TF KAMAs", display=display.none)
highlight          = input(true,  title="Highlight ?",      group="🐇 Chart TF KAMAs", display=display.none, inline = "a1")
awaitBarConfirm    = input(true,  title="Await Bar Confirmation ?", group="🐇 Chart TF KAMAs", display=display.none, inline = "a1")


col_htfb            = input.color(color.new(#1f94a6, 0), title = "HTF KAMAs Bullish", group="🐢 HTF KAMAs", display=display.none, inline = "sl2")
col_htfs            = input.color(color.new(#d429ff, 0), title = "Bearish", group="🐢 HTF KAMAs", display=display.none, inline = "sl2")

length1            = input(14,    title="Length",           group="🐢 HTF KAMAs", display=display.none)
fastLength1        = input(50,    title="Fast EMA Length",  group="🐢 HTF KAMAs", display=display.none)
slowLength1        = input(100,   title="Slow EMA Length",  group="🐢 HTF KAMAs", display=display.none)
src1               = input(close, title="Source",           group="🐢 HTF KAMAs", display=display.none)
highlight1         = input(true,  title="Highlight ?",      group="🐢 HTF KAMAs", display=display.none, inline = "b2")
awaitBarConfirm1   = input(true,  title="Await Bar Confirmation ?", group="🐢 HTF KAMAs", display=display.none, inline = "b2")




// ─── PRESET OVERRIDES ─────────────────────────────────────────────────────────
color col_neu =  color.new(#000000, 0)
color col_htfn = color.new(#140284, 0)
color col_buy1 = color.new(#4fb252, 80)
color col_sell1 = color.new(#ff0000, 80)
color col_htfb1 = color.new(#00fff7, 80)
color col_htfs1 = color.new(#9329f0, 80) 

if not showCTFKAMA
    col_buy := color.new(#4fb252, 100)
    col_sell := color.new(#ffffff, 100)

if not showHTFKAMA
    col_htfb := color.new(#4fb252, 100)
    col_htfs := color.new(#ffffff, 100) 

if preset != "USER"
    highlight := true, highlight1 := true
    awaitBarConfirm := true, awaitBarConfirm1 := true
    if preset == "GOLD / METALS"
        length := 14, length1 := 14
        fastLength := 14, fastLength1 := 50
        slowLength := 30, slowLength1 := 100
    else if preset == "FOREX"
        length := 14, length1 := 14
        fastLength := 14, fastLength1 := 20
        slowLength := 30, slowLength1 := 100
    else if preset == "CRYPTO"
        length := 10, length1 := 10
        fastLength := 10, fastLength1 := 30
        slowLength := 40, slowLength1 := 80
    else if preset == "INDICES"
        length := 20, length1 := 20
        fastLength := 20, fastLength1 := 60
        slowLength := 50, slowLength1 := 120
    else if preset == "STOCKS"
        length := 14, length1 := 14
        fastLength := 20, fastLength1 := 40
        slowLength := 40, slowLength1 := 100



// ─── KAMA FUNCTION ────────────────────────────────────────────────────────────
// Encapsulating the calculation lets request.security() evaluate it on any TF
kamaCalc(s, len, fLen, sLen, doAwait, doHighlight, c1, c2, c3) =>
    m         = math.abs(ta.change(s, len))
    vol       = math.sum(math.abs(ta.change(s)), len)
    er        = vol != 0 ? m / vol : 0.0
    fAlpha    = 2.0 / (fLen + 1)
    sAlpha    = 2.0 / (sLen + 1)
    a         = math.pow(er * (fAlpha - sAlpha) + sAlpha, 2)
    k         = 0.0
    k         := a * s + (1 - a) * nz(k[1], s)
    confirmed = doAwait ? barstate.isconfirmed : true
    col       = doHighlight ? (k > k[1] and confirmed ? c1 :c2) : c3
    [k, col]

// ─── CURRENT TIMEFRAME ────────────────────────────────────────────────────────
[kama,  maColor]  = kamaCalc(src,  length,  fastLength,  slowLength,  awaitBarConfirm,  highlight, col_buy, col_sell, col_neu)
[kama1, maColor1] = kamaCalc(src1, length1, fastLength1, slowLength1, awaitBarConfirm1, highlight1, col_buy, col_sell, col_neu)

// ─── HTF RESOLUTION ───────────────────────────────────────────────────────────
htfAuto() =>
    int s = timeframe.in_seconds()
    if s <= 60
        "5"
    else if s <= 300
        "15"
    else if s <= 900
        "60"
    else if s <= 1800
        "120"
    else if s <= 3600
        "240"
    else if s <= 14400
        "D"
    else if s <= 86400
        "W"
    else
        "M"

htfTF = htfMode == "Auto" ? htfAuto() : htfTimeframe

// ─── HTF (e.g. 15m) ───────────────────────────────────────────────────────────
// gaps_off + lookahead_off → no repaint; HTF value updates only on HTF bar close
[kama_htf,  col_htf]  = request.security(syminfo.tickerid, htfTF,
     kamaCalc(src,  length,  fastLength,  slowLength,  awaitBarConfirm,  highlight, col_htfb, col_htfs, col_htfn),
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

[kama1_htf, col1_htf] = request.security(syminfo.tickerid, htfTF,
     kamaCalc(src1, length1, fastLength1, slowLength1, awaitBarConfirm1, highlight1, col_htfb, col_htfs, col_htfn),
     gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// ─── PLOTS ────────────────────────────────────────────────────────────────────
// Current TF lines (thinner)
p_slow = plot(kama,  title="Slow KAMA (current TF)", linewidth=1, color = maColor, editable = false)
p_fast = plot(kama1, title="Fast KAMA (current TF)", linewidth=1, color = maColor1, editable = false)

// Fill — bullish tint when fast above slow, bearish when below
fillCol = showFill ? (kama1 < kama ? color.new(col_buy1, 85) : color.new(col_sell1, 85)) : na
fill(p_slow, p_fast, color = fillCol, title = "KAMA Fill", editable = false)

// HTF lines (thicker so they stand out)
h_slow = plot(kama_htf ,  title="Slow KAMA (HTF)", linewidth=1, color = col_htf, editable = false)
h_fast = plot(kama1_htf, title="Fast KAMA (HTF)", linewidth=1, color = col1_htf, editable = false)

fillCol2 = showFill2 ? (kama1_htf < kama_htf ? color.new(col_htfb1, 85) : color.new(col_htfs1, 85)) : na
fill(h_slow, h_fast, color = fillCol2, title = "KAMA Fill2", editable = false)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
// Original color-change alerts
alertcondition(maColor  != maColor[1],  title="Slow KAMA Color Change", message="Slow KAMA changed color!")
alertcondition(maColor1 != maColor1[1], title="Fast KAMA Color Change", message="Fast KAMA changed color!")

// Fast × Slow cross alerts (current TF)
bullCross = ta.crossover(kama1,  kama)
bearCross = ta.crossunder(kama1, kama)
alertcondition(bullCross, title="Fast × Slow Bullish Cross", message="Fast KAMA crossed ABOVE Slow KAMA")
alertcondition(bearCross, title="Fast × Slow Bearish Cross", message="Fast KAMA crossed BELOW Slow KAMA")

// HTF-aligned cross alerts — fires only when HTF slow KAMA agrees with the cross direction
htfUp   = kama_htf > kama_htf[1]
htfDown = kama_htf < kama_htf[1]
alertcondition(bullCross and htfUp,   title="HTF-Aligned Bullish Cross", message="Fast × Slow bullish cross + HTF KAMA rising")
alertcondition(bearCross and htfDown, title="HTF-Aligned Bearish Cross", message="Fast × Slow bearish cross + HTF KAMA falling")
````
