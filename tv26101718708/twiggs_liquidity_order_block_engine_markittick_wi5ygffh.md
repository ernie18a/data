# Twiggs Liquidity & Order Block Engine [MarkitTick]

- url: https://www.tradingview.com/script/wi5ygfFH-Twiggs-Liquidity-Order-Block-Engine-MarkitTick/
- type: indicator
- pine_id: PUB;eb2d8745122a40edba489a31d4d5a170
- version: 1.0

## Description

💡 Hybrid technical indicator designed to synthesize volume-weighted momentum with structural price action analysis. By harmonizing a modernized Twiggs Money Flow (TMF) algorithm with an automated Smart Money Concepts (SMC) overlay, this script provides a multi-dimensional perspective on market dynamics. Traders can monitor underlying accumulation and distribution cycles while simultaneously visualizing critical market structure shifts and historically significant supply and demand zones, offering a comprehensive, all-in-one chart analysis environment.

[b]✨ Originality and Utility[/b]

[b]● A Unique Analytical Mashup[/b]
Most technical analysis tools isolate either volume momentum or price action structure. This script introduces a vital mashup by blending the quantitative rigor of the Twiggs Money Flow with the visual geometry of Smart Money Concepts (SMC). 

[list]
[*] The utility lies in cross-verification: an Order Block (structural support/resistance) becomes exponentially more actionable when validated by a corresponding surge or exhaustion in the TMF volume oscillator.
[*] This synthesis actively filters out false breakouts. A break of structure occurring on weak or divergent money flow can be flagged as a potential liquidity sweep rather than a genuine trend continuation.
[*] Additionally, the integration of a dynamic, real-time dashboard centralizes complex data, removing the need to manually cross-reference multiple traditional indicators, thereby saving screen space and enhancing cognitive focus during active chart analysis.
[/list]

[b]🔬 Methodology and Concepts[/b]

[b]● The Twiggs Money Flow (TMF) Engine[/b]
The oscillator component of this script is rooted in the Twiggs Money Flow, which serves as an evolution of traditional money flow calculations.

[list]
[*] [b]True Range Implementation:[/b] Rather than relying strictly on the high and low of the current candle, the engine calculates the True High (maximum of current high or previous close) and True Low (minimum of current low or previous close). This inherently factors in market gaps, preventing skewed volume data during highly volatile opens.
[*] [b]Volume Multiplier:[/b] A proprietary multiplier determines the placement of the close relative to the True Range. The multiplier forces a value between -1.0 and +1.0, dictating the proportion of trading volume classified as buying pressure (accumulation) versus selling pressure (distribution).
[*] [b]Exponential Smoothing:[/b] The raw money flow volume and the raw price volume are independently smoothed using an exponential moving average (EMA) system. The final TMF value is derived by dividing the smoothed money flow volume by the smoothed absolute volume.
[*] [b]Signal Line Construction:[/b] A secondary exponential moving average is applied directly to the finalized TMF output, creating a responsive signal line to identify momentum crossovers and track the expansion or contraction of volume momentum.
[/list]

[b]● Smart Money Concepts (SMC) Architecture[/b]
The structural overlay maps the fractal nature of market trends using strict geometric logic.

[list]
[*] [b]Swing Detection:[/b] The script scans historical data across a user-defined lookback period to pinpoint distinct Swing Highs and Swing Lows, creating the foundation of the market structure.
[*] [b]BOS and CHoCH Logic:[/b] When the closing price breaches an active Swing High or Swing Low, the engine dynamically labels the event as a Break of Structure (BOS) if it aligns with the prevailing trend, or a Change of Character (CHoCH) if it signifies a potential trend reversal.
[*] [b]Order Block Generation:[/b] Upon a confirmed structural break, the engine projects Order Blocks based on the origin of the impulse move. The depth and visual boundary of these blocks are calibrated using a localized Average True Range (ATR) calculation.
[*] [b]Mitigation Tracking:[/b] The script features a state-tracking algorithm that monitors price interaction with active Order Blocks. Once price re-enters and "mitigates" a block, the zone is visually dimmed or entirely hidden, keeping the chart completely focused on unmitigated liquidity zones.
[/list]

[b]🎨 Visual Guide[/b]

[b]● Oscillator Pane Elements[/b]
[list]
[*] [b]TMF Histogram & Line:[/b] The primary TMF value is plotted as both a solid line and a supporting histogram. Values above the zero line utilize a Neon Violet color to indicate bullish money flow, while values below the zero line shift to a Neon Orange/Red to denote bearish flow.
[*] [b]Signal Line:[/b] Displayed as a dotted Gold/Yellow line tracking alongside the TMF. 
[*] [b]Overbought/Oversold Zones:[/b] Dashed horizontal thresholds exist at user-defined overbought (+0.20) and oversold (-0.20) levels. When the TMF breaches these extremes, the background of the oscillator pane fills with a semi-transparent red or green glow.
[*] [b]Alert Shapes:[/b] Small geometric shapes (triangles and circles) populate the oscillator pane to mark exact moments where the TMF crosses the zero line or breaches the outer extreme zones.
[/list]

[b]● Price Chart Overlay[/b]
[list]
[*] [b]Candle Coloring:[/b] If enabled, standard price candles are re-colored based on the relationship between the TMF and its Signal Line. Bright Violet implies expanding bullish momentum, while dimmed Violet indicates narrowing bullish momentum. Conversely, Bright Orange implies expanding bearish momentum, with dimmed Orange signifying fading bearish pressure.
[*] [b]Structure Labels:[/b] Dashed lines paired with small text labels (BOS / CHoCH) appear precisely where structural breaks are confirmed.
[*] [b]Order Blocks:[/b] Solid rectangular boxes project forward in time. Unmitigated bullish blocks are filled with semi-transparent Violet, while unmitigated bearish blocks are filled with semi-transparent Orange. Once price touches these zones, they transition to a muted Slate/Grey color to signify mitigation.
[/list]

[b]● Real-Time Dashboard[/b]
[list]
[*] Positioned in the top-right corner, this dark-themed data table provides a high-level summary of the current market state. It displays the numeric TMF and Signal values accompanied by 10-segment visual power bars. It also explicitly spells out the current Momentum Gap status, Overbought/Oversold Regime, Zero Cross Age (in bars), and the overarching Market Structure trend.
[/list]

[b]📖 How to Use[/b]

[b]● Analyzing Momentum Crossovers[/b]
[list]
[*] Primary trend confirmation is achieved by observing the TMF relative to the Zero Line. A sustained period above zero indicates healthy accumulation, whereas resting below zero signifies persistent distribution.
[*] Short-term entry triggers can be identified by the TMF crossing its dotted Gold Signal Line. An upward cross while below zero can signal an early mean-reversion opportunity, whereas an upward cross above zero confirms strong trend continuation.
[/list]

[b]● Exploiting the Mashup Confluence[/b]
[list]
[*] The most robust trading setups occur when both the oscillator and the price action overlay align perfectly.
[*] [b]Bullish Setup:[/b] Wait for the SMC engine to print a bullish Change of Character (CHoCH) followed by the generation of a fresh, Violet Order Block. As price retraces downward into this Order Block, look at the oscillator. If the TMF is rising, crossing its Signal Line, or rejecting the oversold threshold, the probability of a successful bounce increases significantly.
[*] [b]Bearish Setup:[/b] Observe price rallying into a pre-existing Orange bearish Order Block. If the dashboard simultaneously indicates that the TMF is in an "Overbought Regime" and the histogram begins crossing downward below the Signal Line, this provides confluence for a potential short entry or long exit.
[/list]

[b]⚙️ Inputs and Settings[/b]

[b]● Calculation Parameters[/b]
[list]
[*] [b]TMF Period:[/b] Determines the lookback length for the underlying money flow moving averages. Increasing this smooths the oscillator but introduces lag.
[*] [b]Signal Line Period:[/b] Adjusts the sensitivity of the dotted signal line tracking the TMF.
[*] [b]Overbought/Oversold Levels:[/b] Custom thresholds for extreme zones (default +/- 0.20), allowing traders to adapt the script to highly volatile or highly ranging assets.
[/list]

[b]● Neon Colors[/b]
[list]
[*] Total control over the aesthetic theme, including individual hex color overrides for Bullish/Rising states, Bearish/Falling states, Histogram fills, and Candle coloring.
[/list]

[b]● SMC & Market Structure[/b]
[list]
[*] [b]Enable SMC Overlay:[/b] A master toggle to display or hide structural lines and Order Blocks.
[*] [b]Swing Length:[/b] Dictates the strictness of pivot high/low detection. A lower number reacts to micro-trends, while a higher number identifies macro-structural shifts.
[*] [b]Track / Hide Mitigated OBs:[/b] Toggles the visual state of Order Blocks after price interacts with them. Users can choose to leave them on the chart as dimmed boxes or delete them entirely for maximum chart cleanliness.
[/list]

[b]🔍 Deconstruction of the Underlying Scientific and Academic Framework[/b]

[b]● Volumetric Price Analysis Theory[/b]
The framework of this indicator is deeply anchored in auction market theory and the foundational work of Marc Chaikin, subsequently refined by Colin Twiggs. Traditional money flow indices often fail to capture the reality of market gaps, leading to incomplete volumetric profiles. By integrating the True Range calculation, the mathematics ensure that the proportional distance between the close and the absolute extreme of the session accurately reflects the terminal buying or selling pressure.

[b]● Exponential Smoothing Mechanics[/b]
The internal architecture relies on parallel exponential moving averages (EMA). Unlike simple averages, the EMA assigns mathematically weighted significance to the most recent data points via an alpha constant (1/N). By smoothing the price-volume product and the raw volume independently before division, the indicator mitigates the erratic noise inherent in isolated volume spikes, producing a normalized quotient that tracks the authentic underlying liquidity flow.

[b]● Fractal Market Structure & Geometric Support[/b]
The secondary framework relies on the premise that financial markets move in fractals, creating self-similar structures across all timeframes. By programmatically defining a "Swing" as a local extremum untouched over a specified sample size, the script mathematically formalizes the identification of supply and demand origin points. The dynamic projection of Order Blocks utilizes the Average True Range (ATR) as a standard deviation metric, recognizing that liquidity zones are not precise, one-dimensional price points, but rather two-dimensional areas defined by the asset's current historical volatility.

[b]⚠️ Disclaimer[/b]
All provided scripts and indicators are strictly for educational exploration and must not be interpreted as financial advice or a recommendation to execute trades. I expressly disclaim all liability for any financial losses or damages that may result, directly or indirectly, from the reliance on or application of these tools. Market participation carries inherent risk where past performance never guarantees future returns, leaving all investment decisions and due diligence solely at your own discretion.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © MarkitTick

// ─────────────────────────────────────────────────────────────────────────────
//@version=6
indicator("Twiggs Liquidity & Order Block Engine [MarkitTick]", overlay=false, max_bars_back=500, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

i_len        = input.int  (21,    "TMF Period",         minval=1,  group="Calculation")
i_sigLen     = input.int  (9,     "Signal Line Period", minval=1,  group="Calculation")
i_showSig    = input.bool (true,  "Show Signal Line",              group="Calculation")
i_overbought = input.float(0.20,  "Overbought Level",  step=0.01, group="Calculation")
i_oversold   = input.float(-0.20, "Oversold Level",    step=0.01, group="Calculation")

i_colBull     = input.color(color.new(#7B61FF, 0),  "Bullish / Rising",       group="Neon Colors")
i_colBear     = input.color(color.new(#FF6B35, 0),  "Bearish / Falling",      group="Neon Colors")
i_colSig      = input.color(color.new(#F0C040, 0),  "Signal Line",            group="Neon Colors")
i_colOB       = input.color(color.new(#FF6B35, 25), "Overbought Line",        group="Neon Colors")
i_colOS       = input.color(color.new(#00E5A0, 25), "Oversold Line",          group="Neon Colors")
i_colZero     = input.color(color.new(#8888AA, 55), "Zero Line",              group="Neon Colors")
i_colFillOB   = input.color(color.new(#FF6B35, 88), "Fill — Overbought Zone", group="Neon Colors")
i_colFillOS   = input.color(color.new(#00E5A0, 88), "Fill — Oversold Zone",   group="Neon Colors")
i_colHistBull = input.color(color.new(#7B61FF, 30), "Histogram — Bull",       group="Neon Colors")
i_colHistBear = input.color(color.new(#FF6B35, 30), "Histogram — Bear",       group="Neon Colors")
i_showCandles = input.bool (true,                   "Color Price Candles",    group="Neon Colors")

i_alertCross = input.bool(true, "Alert: TMF crosses Zero",   group="Alerts")
i_alertOBOS  = input.bool(true, "Alert: OB/OS Level Breach", group="Alerts")

string GRP_DASH     = "📊 Dashboard Settings"
color  dash_bg_color  = input.color(color.rgb(14, 10, 28, 5),    "Background Color", group=GRP_DASH)
color  dash_txt_color = input.color(color.rgb(200, 195, 230, 0), "Text Color",       group=GRP_DASH)

string GRP_SMC      = "🏛 SMC — Market Structure & Order Blocks"
bool   smc_show     = input.bool(true,  "Enable SMC Overlay",    group=GRP_SMC)
int    smc_swing    = input.int (5,     "Swing Length",  minval=2, group=GRP_SMC)
color  smc_col_bull = input.color(color.new(#7B61FF, 0),  "BOS/CHoCH Bull Color",   group=GRP_SMC)
color  smc_col_bear = input.color(color.new(#FF6B35, 0),  "BOS/CHoCH Bear Color",   group=GRP_SMC)
color  smc_col_ob_bull = input.color(color.new(#7B61FF, 88), "Bull OB Fill",        group=GRP_SMC)
color  smc_col_ob_bear = input.color(color.new(#FF6B35, 88), "Bear OB Fill",        group=GRP_SMC)
bool   smc_show_mit = input.bool(true,  "Track OB Mitigation",   group=GRP_SMC)
bool   smc_hide_mit = input.bool(false, "Hide Mitigated OBs",    group=GRP_SMC)
color  smc_col_mit  = input.color(color.new(#4A4A6A, 82), "Mitigated OB Color",    group=GRP_SMC)

// ══════════════════════════════════════════════════════════════════════════════
// Visual Helpers
// ══════════════════════════════════════════════════════════════════════════════

f_blockBar(float score) =>
    int    n = math.min(math.max(math.round(score), 0), 10)
    string s = ''
    for i = 1 to 10
        s += i <= n ? '█' : '░'
    s

f_blockColor(float score) =>
    score >= 7.0 ? color.rgb(0, 229, 160) :
     score >= 4.0 ? color.rgb(123, 97, 255) :
     score >= 1.5 ? color.rgb(240, 192, 64) :
     color.rgb(80, 75, 110)

string clean_ticker = syminfo.tickerid

// ══════════════════════════════════════════════════════════════════════════════
// TMF LOGIC ENGINE 
// ══════════════════════════════════════════════════════════════════════════════

float th = math.max(high, close[1])
float tl = math.min(low,  close[1])
float tr = th - tl

float rawMult  = tr != 0.0 ? (2.0 * (close - tl) / tr) - 1.0 : 0.0
float mfVol    = rawMult * volume

float alpha    = 1.0 / i_len
var float emaVol   = na
var float emaMFVol = na
emaVol   := na(emaVol)   ? volume : (1.0 - alpha) * emaVol   + alpha * volume
emaMFVol := na(emaMFVol) ? mfVol  : (1.0 - alpha) * emaMFVol + alpha * mfVol

float tmf = emaVol != 0.0 ? emaMFVol / emaVol : 0.0

float alphaSig = 1.0 / i_sigLen
var float emaSig = na
emaSig := na(emaSig) ? tmf : (1.0 - alphaSig) * emaSig + alphaSig * tmf

bool  rising  = tmf[1] > tmf[2]  

bool crossUpZero = tmf[2] < 0.0          and tmf[1] >= 0.0
bool crossDnZero = tmf[2] >= 0.0         and tmf[1] <  0.0
bool crossUpOB   = tmf[2] < i_overbought and tmf[1] >= i_overbought
bool crossDnOS   = tmf[2] > i_oversold   and tmf[1] <= i_oversold

bool  sigBull     = tmf[1] >= emaSig[1]
bool  gapWidening = math.abs(tmf[1] - emaSig[1]) > math.abs(tmf[2] - emaSig[2])

var int barsSinceZero = 0
barsSinceZero := (crossUpZero or crossDnZero) ? 0 : barsSinceZero + 1

color histColorCalc = tmf >= 0.0
     ? (rising ? i_colHistBull : color.new(i_colHistBull, 60))
     : (rising ? color.new(i_colHistBear, 60) : i_colHistBear)

color candleCol = i_showCandles
     ? (sigBull
         ? (gapWidening ? i_colBull : color.new(i_colBull, 60))
         : (gapWidening ? i_colBear : color.new(i_colBear, 60)))
     : na

color tmfColor = rising ? i_colBull : i_colBear

// ══════════════════════════════════════════════════════════════════════════════
// SMC ENGINE
// ══════════════════════════════════════════════════════════════════════════════

// ── UDTs ──────────────────────────────────────────────────────────────────────
type SMCSwing
    int   idx
    float price
    bool  active

type SMCBlock
    int   left
    float top
    float bottom
    bool  is_bull
    bool  mitigated
    box   bx

var SMCSwing          smc_ph    = SMCSwing.new(0, 0.0, false)
var SMCSwing          smc_pl    = SMCSwing.new(0, 0.0, false)
var int               smc_trend = 0
var float             smc_last_high = 0.0
var float             smc_last_low  = 0.0
var array<SMCBlock>   smc_obs   = array.new<SMCBlock>()

f_smcPH(series float src, simple int len) =>
    float c = src[len]
    bool  v = true
    for i = 1 to len * 2
        if i != len and src[i] >= c
            v := false
    v ? c : na

f_smcPL(series float src, simple int len) =>
    float c = src[len]
    bool  v = true
    for i = 1 to len * 2
        if i != len and src[i] <= c
            v := false
    v ? c : na

float smc_raw_ph = f_smcPH(high, smc_swing)
float smc_raw_pl = f_smcPL(low,  smc_swing)

float smc_atr = ta.atr(14)

if not na(smc_raw_ph)
    smc_ph.idx    := bar_index[smc_swing]
    smc_ph.price  := smc_raw_ph
    smc_ph.active := true

if not na(smc_raw_pl)
    smc_pl.idx    := bar_index[smc_swing]
    smc_pl.price  := smc_raw_pl
    smc_pl.active := true

bool ms_bull_break = smc_ph.active and close[1] > smc_ph.price
bool ms_bear_break = smc_pl.active and close[1] < smc_pl.price

if smc_show and smc_show_mit
    int _sz = array.size(smc_obs)
    if _sz > 0
        for i = 0 to _sz - 1
            SMCBlock ob = array.get(smc_obs, i)
            if not ob.mitigated
                bool hit = ob.is_bull ? low[1] <= ob.bottom : high[1] >= ob.top
                if hit
                    ob.mitigated := true
                    if smc_hide_mit
                        box.delete(ob.bx)
                    else
                        box.set_bgcolor(ob.bx, smc_col_mit)
                    array.set(smc_obs, i, ob)

if array.size(smc_obs) > 40
    SMCBlock evicted = array.shift(smc_obs)
    box.delete(evicted.bx)

if smc_show and ms_bull_break
    string lbl_txt = smc_trend == 1 ? "BOS" : "CHoCH"
    int    lx1     = math.max(smc_ph.idx, bar_index - 499)
    int    mid_x   = math.round((lx1 + bar_index) / 2)

    line.new(lx1, smc_ph.price, bar_index, smc_ph.price,
         color=smc_col_bull, style=line.style_dashed, width=1,
         force_overlay=true)
    label.new(mid_x, smc_ph.price, lbl_txt,
         color=color.new(color.white, 100), textcolor=smc_col_bull,
         style=label.style_label_down, size=size.small,
         force_overlay=true)

    float ob_bottom = smc_pl.price
    float ob_top    = smc_pl.price + (smc_atr * 0.5)
    int   ob_left   = math.max(smc_pl.idx, bar_index - 499)
    box ob_bx = box.new(ob_left, ob_top, bar_index + 10, ob_bottom,
         border_color=na, bgcolor=smc_col_ob_bull,
         force_overlay=true)
    array.push(smc_obs, SMCBlock.new(ob_left, ob_top, ob_bottom, true, false, ob_bx))

    smc_trend     := 1
    smc_last_high := smc_ph.price
    smc_ph.active := false

if smc_show and ms_bear_break
    string lbl_txt = smc_trend == -1 ? "BOS" : "CHoCH"
    int    lx1     = math.max(smc_pl.idx, bar_index - 499)
    int    mid_x   = math.round((lx1 + bar_index) / 2)

    line.new(lx1, smc_pl.price, bar_index, smc_pl.price,
         color=smc_col_bear, style=line.style_dashed, width=1,
         force_overlay=true)
    label.new(mid_x, smc_pl.price, lbl_txt,
         color=color.new(color.white, 100), textcolor=smc_col_bear,
         style=label.style_label_up, size=size.small,
         force_overlay=true)

    float ob_top    = smc_ph.price
    float ob_bottom = smc_ph.price - (smc_atr * 0.5)
    int   ob_left   = math.max(smc_ph.idx, bar_index - 499)
    box ob_bx = box.new(ob_left, ob_top, bar_index + 10, ob_bottom,
         border_color=na, bgcolor=smc_col_ob_bear,
         force_overlay=true)
    array.push(smc_obs, SMCBlock.new(ob_left, ob_top, ob_bottom, false, false, ob_bx))

    smc_trend    := -1
    smc_last_low := smc_pl.price
    smc_pl.active := false

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ══════════════════════════════════════════════════════════════════════════════

float tmfScore   = (tmf + 1.0) / 2.0 * 10.0
string tmfPrefix = tmf >= 0.0 ? '▲ ' : '▼ '
string tmfBar    = tmfPrefix + f_blockBar(tmfScore) + '  ' + str.tostring(tmf, '#.###')
color  tmfBarCol = tmf >= 0.0 ? color.rgb(0, 229, 160) : color.rgb(255, 107, 53)

float  sigScore  = (emaSig + 1.0) / 2.0 * 10.0
string sigPrefix = emaSig >= 0.0 ? '▲ ' : '▼ '
string sigBar    = sigPrefix + f_blockBar(sigScore) + '  ' + str.tostring(emaSig, '#.###')
color  sigBarCol = emaSig >= 0.0 ? color.rgb(123, 97, 255) : color.rgb(255, 107, 53)

string sigStateStr = sigBull
     ? (gapWidening ? '▲ Bull  ·  Expanding' : '▲ Bull  ·  Narrowing')
     : (gapWidening ? '▼ Bear  ·  Expanding' : '▼ Bear  ·  Narrowing')
color  sigStateCol = sigBull ? color.rgb(0, 229, 160) : color.rgb(255, 107, 53)

string zeroRegimeStr = tmf >= 0.0
     ? (tmf >= i_overbought ? '📈 Bull · Overbought' : '📈 Bull · Trending')
     : (tmf <= i_oversold   ? '📉 Bear · Oversold'   : '📉 Bear · Trending')
color  zeroRegimeCol = tmf >= 0.0 ? color.rgb(0, 229, 160) : color.rgb(255, 107, 53)

float  gapRaw    = math.abs(tmf - emaSig)
float  gapScore  = math.min(gapRaw / 0.5 * 10.0, 10.0)
string gapPrefix = gapWidening ? '⚡ ' : '○  '
string gapBar    = gapPrefix + f_blockBar(gapScore) + '  ' + str.tostring(gapRaw, '#.####')
color  gapBarCol = f_blockColor(gapScore)

string zoneStr = tmf > i_overbought  ? '⚠  Overbought Zone' :
                 tmf < i_oversold    ? '⚠  Oversold Zone'   :
                 tmf >= 0.0          ? '⚖  Neutral Bull'    :
                                       '⚖  Neutral Bear'
color  zoneCol = tmf > i_overbought  ? color.rgb(255, 107, 53)  :
                 tmf < i_oversold    ? color.rgb(0, 229, 160)   :
                 tmf >= 0.0          ? color.rgb(123, 97, 255)  :
                                       color.rgb(255, 107, 53)

string barsStr = '⏳ ' + str.tostring(barsSinceZero) + ' Bars'
color  barsCol = color.rgb(150, 130, 255)

string smcTrendStr = smc_trend == 1  ? '▲ Bullish Structure' :
                     smc_trend == -1 ? '▼ Bearish Structure' :
                                       '— Undefined'
color  smcTrendCol = smc_trend == 1  ? color.rgb(0, 229, 160)  :
                     smc_trend == -1 ? color.rgb(255, 107, 53) :
                                       color.rgb(100, 90, 140)

// ══════════════════════════════════════════════════════════════════════════════
// Dashboard Table
// ══════════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 10,
     border_width  = 1,
     border_color  = color.rgb(80, 60, 120, 20),
     frame_width   = 1,
     frame_color   = color.rgb(100, 80, 160, 10),
     force_overlay = true)

color hdrBg = color.rgb(30, 20, 55, 10)
color altBg = color.rgb(18, 14, 35, 10)
color oddBg = dash_bg_color

table.cell(dash, 0, 0, '  TMF · SMC Dashboard',
     bgcolor=hdrBg, text_color=color.rgb(123, 97, 255, 0),
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 1, 0, clean_ticker + ' · ' + timeframe.period,
     bgcolor=hdrBg, text_color=color.rgb(160, 145, 200, 0),
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 1, '  TMF Value',
     bgcolor=altBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 1, tmfBar,
     bgcolor=altBg, text_color=tmfBarCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 2, '  Signal Value',
     bgcolor=oddBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 2, sigBar,
     bgcolor=oddBg, text_color=sigBarCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 3, '  TMF vs Signal',
     bgcolor=altBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 3, sigStateStr,
     bgcolor=altBg, text_color=sigStateCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 4, '  Bias Regime',
     bgcolor=oddBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 4, zeroRegimeStr,
     bgcolor=oddBg, text_color=zeroRegimeCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 5, '  Momentum Gap',
     bgcolor=altBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 5, gapBar,
     bgcolor=altBg, text_color=gapBarCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 6, '  Zone Status',
     bgcolor=oddBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 6, zoneStr,
     bgcolor=oddBg, text_color=zoneCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 7, '  Zero Cross Age',
     bgcolor=altBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 7, barsStr,
     bgcolor=altBg, text_color=barsCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 8, '  Market Structure',
     bgcolor=oddBg, text_color=dash_txt_color,
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.small)
table.cell(dash, 1, 8, smcTrendStr,
     bgcolor=oddBg, text_color=smcTrendCol,
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.small)

table.cell(dash, 0, 9, '  © MarkitTick',
     bgcolor=hdrBg, text_color=color.rgb(90, 70, 130, 0),
     text_halign=text.align_left, text_font_family=font.family_monospace, text_size=size.tiny)
table.cell(dash, 1, 9, 'Twiggs® v6 · SMC',
     bgcolor=hdrBg, text_color=color.rgb(90, 70, 130, 0),
     text_halign=text.align_right, text_font_family=font.family_monospace, text_size=size.tiny)

// ══════════════════════════════════════════════════════════════════════════════
// VISUALIZATION
// ══════════════════════════════════════════════════════════════════════════════

plotcandle(
     i_showCandles ? open  : na,
     i_showCandles ? high  : na,
     i_showCandles ? low   : na,
     i_showCandles ? close : na,
     title         = "Price Candles",
     color         = candleCol,
     wickcolor     = candleCol,
     bordercolor   = candleCol,
     display       = display.pane + display.price_scale,
     force_overlay = true)

plot(tmf,     "TMF Histogram", color=histColorCalc, style=plot.style_columns, linewidth=1, display=display.pane)
plot(tmf,     "TMF Glow",      color=color.new(tmfColor, 70), style=plot.style_line, linewidth=4, display=display.pane)
plot(tmf,     "TMF Line",      color=tmfColor,                style=plot.style_line, linewidth=2, display=display.pane)
plot(i_showSig ? emaSig : na, "Signal", color=i_colSig, style=plot.style_line, linewidth=1, linestyle=plot.linestyle_dotted, display=display.pane)

hline(i_overbought, "Overbought", color=i_colOB,   linestyle=hline.style_dashed, linewidth=1)
hline(i_oversold,   "Oversold",   color=i_colOS,   linestyle=hline.style_dashed, linewidth=1)
hline(0.0,          "Zero",       color=i_colZero, linestyle=hline.style_solid,  linewidth=1)

pOB  = plot(i_overbought, display=display.none)
pOS  = plot(i_oversold,   display=display.none)
pTMF = plot(tmf,          display=display.none)
fill(pTMF, pOB, color = tmf > i_overbought ? i_colFillOB : na, title="OB Fill")
fill(pTMF, pOS, color = tmf < i_oversold   ? i_colFillOS : na, title="OS Fill")

plotshape(crossUpZero, title="Zero Cross Up",   style=shape.triangleup,   location=location.bottom, color=i_colBull, size=size.tiny, display=display.pane + display.price_scale)
plotshape(crossDnZero, title="Zero Cross Down", style=shape.triangledown, location=location.top,    color=i_colBear, size=size.tiny, display=display.pane + display.price_scale)
plotshape(crossUpOB,   title="OB Breach",       style=shape.circle,       location=location.top,    color=i_colOB,   size=size.tiny, display=display.pane + display.price_scale)
plotshape(crossDnOS,   title="OS Breach",       style=shape.circle,       location=location.bottom, color=i_colOS,   size=size.tiny, display=display.pane + display.price_scale)

plotshape(crossUpZero, title="Chart: Zero Cross Up",   style=shape.labelup,   text="↑ Bull", textcolor=color.black, location=location.belowbar, color=i_colBull, size=size.small, force_overlay=true, display=display.pane + display.price_scale)
plotshape(crossDnZero, title="Chart: Zero Cross Down", style=shape.labeldown, text="↓ Bear", textcolor=color.white, location=location.abovebar, color=i_colBear, size=size.small, force_overlay=true, display=display.pane + display.price_scale)
plotshape(crossUpOB,   title="Chart: OB Breach",       style=shape.labeldown, text="OB ⚠",  textcolor=color.white, location=location.abovebar, color=i_colOB,   size=size.small, force_overlay=true, display=display.pane + display.price_scale)
plotshape(crossDnOS,   title="Chart: OS Breach",       style=shape.labelup,   text="OS ⚠",  textcolor=color.black, location=location.belowbar, color=i_colOS,   size=size.small, force_overlay=true, display=display.pane + display.price_scale)

bgcolor(tmf > i_overbought ? color.new(i_colOB, 92) : na, title="BG OB")
bgcolor(tmf < i_oversold   ? color.new(i_colOS, 92) : na, title="BG OS")
bgcolor(tmf > i_overbought ? color.new(i_colOB, 92) : na, title="Chart BG OB", force_overlay=true)
bgcolor(tmf < i_oversold   ? color.new(i_colOS, 92) : na, title="Chart BG OS", force_overlay=true)

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════


if i_alertCross and barstate.isconfirmed
    if crossUpZero
        alert(str.format("TMF crossed ABOVE Zero — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)
    if crossDnZero
        alert(str.format("TMF crossed BELOW Zero — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)

if i_alertOBOS and barstate.isconfirmed
    if crossUpOB
        alert(str.format("TMF breached OVERBOUGHT — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)
    if crossDnOS
        alert(str.format("TMF breached OVERSOLD — {0} [{1}]", syminfo.tickerid, timeframe.period), alert.freq_once_per_bar_close)
````
