# Ultravol - correct market volume [GF4M]

- url: https://www.tradingview.com/script/H2spR9Ph-Ultravol-correct-market-volume-GF4M/
- type: indicator
- pine_id: PUB;2cd8be38d6bd49249d055bddb35c1365
- version: 3.0

## Description

[b]Ultravol - correct market volume [/b]

❗️Reason for displaying two indicators together on the main chart:
🔗 Use together for reading volume — Ultravol, Ultravol Matrix are originally built as one indicator, split in two due to Pine's 64-plot limit & multi-pane drawing limit. (same language by UV-scaled color): Ultravol Matrix reads vol spike history, Ultravol reads live.

❗️Per TradingView's policy that each script's description must be self-contained on its own, the Ultravol engine description common to both Ultravol and Ultravol Matrix is repeated across both indicators' descriptions.
───────────────────────────────────────────────
🔶 PROBLEM

  On a standard chart, volume is just numbers and bars, so to know how much weight is behind the current candle's move, you have to scan the whole chart yourself and judge relative size. Doing that instantly during live trading takes intuition built through long training. This problem is worse in crypto: since the same asset trades on dozens of exchanges at once, looking at a single exchange's volume alone doesn't show where the real volume spike actually is. I came to think there were two important points. 

1. (Common) How much does this volume mean in the market as a whole?

  Every asset has a normal, average scale at which it typically trades. If far more trading is happening than that, the asset is drawing attention right now. Conversely, even when candles look active and volume keeps increasing, if it stays below the whole-market average, it is actually a minor move. In other words, it should be readable instantly against the whole market — not against the immediately preceding period.

2. (Multi-exchange asset) Is this a market-wide event, or a local event on one exchange?

  For an asset traded on dozens of exchanges at once, as in crypto, even a very large exchange's volume spike alone won't move the price much — because the remaining exchanges still hold volume that can't be ignored. The same spike means something completely different depending on whether it happens across many exchanges at once or only locally — and neither a single exchange's volume, nor a simple aggregate of them, shows this difference clearly (it ends up buried under the pattern of whichever pair has overwhelming volume, like Binance).


🔷 SOLUTION

  1. (Common)  The whole chart's accumulated average volume is extracted as a base line, and each bar's ratio to it is standardized into a common UV-scaled color. For crypto, one step further — the volumes of 12 major exchange pairs are each weighted by importance and composited into one Final Synthetic UV volume, used as the main volume. This way, every visual element on the chart can be drawn based on one common scale. This is Ultravol.

  2. (Multi-exchange asset) The volume spike history of each of those same 12 sources, before Ultravol composites them into one, is decomposed along the time axis using the same UV-scaled color, so you can see at a glance whether the current spike spans the whole market or is local. This is Ultravol Matrix. (Originally one indicator, but split into two because the number of plots needed exceeded Pine's limit (64-plot) — the core engine is the same.)

  Volume can now be perceived instantly. Candles carrying below-average volume stay dark and featureless; candles carrying above-average energy render brighter and more intense. The screen looks quiet when the market is quiet, and busy when it is busy. And this color grammar reads the same way on any asset, any timeframe — because the reference is always that market's own whole-history average. This indicator set can fully replace ordinary candles and volume charts.


🔷 [b]Ultravol Engine: Processing Diagram [/b] 
[image]https://www.tradingview.com/x/HFTMZsyQ/[/image]
🟣 Check the  Appendix — (16 live feeds/candle · coin-unit correction (1000x-listed coins) · USDT/USDC reference price conversion · Master GATE calc scheduling · per-exchange trust weighting · auto listing-join. Full mechanics + reusable code.)

───────────────────────────────────────────────
[b]Ultravol - correct market volume [/b]


✨ Gives you a trained trader's sense for volume — by color, instantly!

📘 Reveal key market energy areas through volume-encoded candles, spectrum layer, v-ray, energy flux, and spike panel by color.  A full legacy candle & volume chart replacement.

📗 Final synthetic UV — Across many crypto exchanges, Ultravol curates 12 (spot + perp) — reverted to native base → normalized & weighted by custom criteria, spot summed and perp summed separately (used as Energy Flux source), then combined into one — to read the unified volume flow across the whole market.

📙 Per-exchange UV level on the panel — Each exchange's volume, normalized to its own signature. → Rendered on the same UV-defined color scale. → Current candle's volume spike level (not raw volume) can be compared across exchanges at a glance.

✨ Ultravol engine:
Its own unique method. Synthetic UV (12-pair fusion) and Per-exchange UV-scaled color mark are crypto-exclusive — UV-scaled coloring works on any chart.



🔷  How to read it

It is recommended to check the color reference scheme in the settings panel to understand how candle colors are represented. Once you are familiar with these patterns, you can instantly gauge the intensity of current movements during live trading.
[image]https://www.tradingview.com/x/pFyKo8f3/[/image]

Refer to the historical patterns where rare, massive volume occurred (indicated by sky blue, blue, and purple - When similar volume occurs later, frequently become the Top or Bottom.)
[image]https://www.tradingview.com/x/RLoYwthO/[/image]
[image]https://www.tradingview.com/x/F5Z86kjE/[/image]

Massive volume spike levels frequently act as strong S/R.
[image]https://www.tradingview.com/x/JAAaUbqk/[/image]
[image]https://www.tradingview.com/x/UsmpCBma/[/image]

🔷 Basic Screen - check volume by color.　　　 　　　
[image]https://www.tradingview.com/x/gVDyGIS0/[/image]

Spike Panel

This panel simultaneously displays the live candle volume in two ways: 1) as an absolute value in the base unit, and 2) as a UV-scaled mark. Users can quickly identify which exchange is experiencing a volume spike based solely on the colored emoji characters.
[image]https://www.tradingview.com/x/95CaRCRu/[/image]

Status Label

The working mode automatically adjusts based on the selected symbol type and information, with the current status displayed via the label in the bottom-right corner.　　　 
[image]https://www.tradingview.com/x/IEdHzzzJ/[/image]

Panel setup

☑ 📱   : Mobile friendly UI setup
• Source        : Use Ultravol (Auto) normally
• Rescale      : Only for extremes, too 🔥 or too ⚫️ 　　　　　　　 
[image]https://www.tradingview.com/x/1fpglOzS/[/image]

☑ V-Ray   : Vertical highlight marks on big spike.　　　　　
[image]https://www.tradingview.com/x/MJNLIwhu/[/image]

☑ Energy Flux  : 8 Spot(U), 4 Perp(L)
+ Trending energy balance (Spot vs Perp)　　　　　
[image]https://www.tradingview.com/x/vicOCAgH/[/image]

☑ Candles : Chart candle × UV fusion.
Each element—Volume, Volume-encoded Candlesticks (Up/Dn), and Ruler—features its own independent color scheme.　　　　
[image]https://www.tradingview.com/x/AIRbb87C/[/image]

No volume chart color　　　　
[image]https://www.tradingview.com/x/5REDIyfQ/[/image]

☑ Spectrum  : Synthetic UV from 12 vol src.
+ Instant energy read by UV-scaled color
+ [In pane] Max height. Move to a pane first.
[image]https://www.tradingview.com/x/2K4vr71T/[/image]

☑ Panel   : Exchange's raw vol (number)
+ Current UV-scaled spike (color mark)
☑ s Smaller UI ☑ ↓ Center-right
☑ ! Wait Long · Act Fast (#1 principle)

🔸 Hover over the panel for detailed info.
[image]https://www.tradingview.com/x/zqkMgBLm/[/image]
[image]https://www.tradingview.com/x/7mvGCfw3/[/image]

Vol src info. & current status notice
[image]https://www.tradingview.com/x/XZlfwvaS/[/image]

Volume spike marking by unique UV-scaled color
[image]https://www.tradingview.com/x/RlC6m3CO/[/image]

Works together as one.

You can see historical spike flow and current spike details at the same time.
🔗 Ultravol Matrix reads vol spike history, Ultravol reads live.　　　　　　
[image]https://www.tradingview.com/x/aqHcueVf/[/image]
[image]https://www.tradingview.com/x/jGbOstDV/[/image]

⚠️ Ultravol must be placed at the very front.
(To ensure the correct z-layer order of all graphics, including hybrid override candles, is displayed exactly as intended. )
[image]https://www.tradingview.com/x/1tOe5wB8/[/image]

HELP: Check a tooltip on the setup panel & spike panel.
[image]https://www.tradingview.com/x/Fnyd0ZnJ/[/image]



🟣[b] APPENDIX — A few notes on what happens inside UV engine.[/b]


💊 Master GATE (Calculation scheduling)

This indicator reads 16 external data sources in real time: the volumes of 12 exchange pairs, plus market cap, two stablecoin exchange rates, and the market average price. The computation that follows these calls is substantial. But volume is a simple cumulative value — I do not see immediate tick-by-tick recomputation as essential. So the work is divided into what happens when a candle opens (new), while it is in progress (realtime), and when it closes (confirmed) — and the heavy computation was judged reasonable to run only at fixed intervals during the candle. It is the internal scheduler that keeps the whole indicator responsive, and a precondition for this indicator to work at all.
[pine]
// 🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦
//   MASTER GATE - throttling setup 
var bool uv_throttleGATE_required   = uv_chart_symbol_crypto_basequotetickvol_flg
varip bool bar_NOTLIVE_flg          = false
varip bool bar_GATEbypass_flg       = false
bar_NOTLIVE_flg         := uv_throttleGATE_required 
                          and barstate.isrealtime and (timenow - (time_close + ((time_close - time)*2)) > 0)
bar_GATEbypass_flg      := not (uv_throttleGATE_required and barstate.isrealtime and not bar_NOTLIVE_flg)       
const int UV_MASTERGATE_RATE_T_VAL  = 160       // ms
varip int uv_MasterGATE_last_t      = na        // Last GATE Open time = LINUX time ms
varip bool uv_MasterGATEopen_flg    = false     
uv_MasterGATEopen_flg := bar_GATEbypass_flg 
                      or na(uv_MasterGATE_last_t) 
                      or (timenow - uv_MasterGATE_last_t >= UV_MASTERGATE_RATE_T_VAL) 
                      or barstate.isconfirmed
if not bar_GATEbypass_flg and uv_MasterGATEopen_flg  
    uv_MasterGATE_last_t := timenow
//   MASTER GATE - throttling setup End
// 🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦
[/pine]
You can make this simple throttling GATE. After configuring the GATE operating conditions as shown above, you can apply them to the actual indicator calculation section by utilizing uv_MasterGATEopen_flg like below. It is simple yet effective. (Caution: Given how Pine Script executes, this GATE mechanism provides reasonable computational savings rather than perfect scheduling. For precise control, use it alongside barstate.isnew / isrealtime / isconfirmed)
[pine]
if uv_MasterGATEopen_flg
    s1_color_x  := f_src_uv_lv_coloring(s1_uv_lv)
    s2_color_x  := f_src_uv_lv_coloring(s2_uv_lv)
    s3_color_x  := f_src_uv_lv_coloring(s3_uv_lv)
    s4_color_x  := f_src_uv_lv_coloring(s4_uv_lv)
    s5_color_x  := f_src_uv_lv_coloring(s5_uv_lv)
    s6_color_x  := f_src_uv_lv_coloring(s6_uv_lv)
    s7_color_x  := f_src_uv_lv_coloring(s7_uv_lv)
    s8_color_x  := f_src_uv_lv_coloring(s8_uv_lv)
    p1_color_x  := f_src_uv_lv_coloring(p1_uv_lv)
    p2_color_x  := f_src_uv_lv_coloring(p2_uv_lv)
    p3_color_x  := f_src_uv_lv_coloring(p3_uv_lv)
    p4_color_x  := f_src_uv_lv_coloring(p4_uv_lv)
[/pine]

🏁  Compositing the 12 exchange pairs

The volumes of 8 spot and 4 perpetual pairs are each converted into base-currency units, then merged into a single weighted volume. Ultravol shows the merged value; Ultravol Matrix shows the per-exchange values before merging, on the same color standard. The list stops at 12 because the volume figures of lower-ranked exchanges are often inflated, and would contaminate the result rather than improve it — the top 12 alone carry roughly 80% of real volume. This part is admittedly subjective; it was curated based on general exchange reputation in the market.


🏁  Unifying coin display units

Some coins — 1000PEPE, 1000SATS — are listed by different exchanges at 1000× or 10000× units (typically the case for extremely low-priced assets). Without reverting these to their original common unit, summing volumes across exchanges loses its meaning. There is no published reference for which exchange lists which coin at which multiple, so each case was verified one by one and built into an internal exception table, matched against the crypto name of the current chart. The symbol tickers used to call the 12 volumes are composed in two ways: (a) coins present in the low-volume table use the values defined there; (b) all other coins are composed per-symbol from 12 predefined symbol templates.

💊 This simple function extract crypto-name from any symbols with 1000x 1000000x
[pine]
f_crypto_symbol_corekey(_tickerid, _basecurrency) =>
    _tickerid_upper = str.upper(_tickerid)
    _key            = str.upper(_basecurrency)
    if str.contains(_tickerid_upper, ":1000000BOB")
        _key := '1000000BOB'
    else
        _prefix = str.match(_key, "^(?:1000000|10000|1000)")
        _suffix = str.match(_key, "(?:1000000|10000|1000)$")
        if _prefix != ''
            _key := str.substring(_key, str.length(_prefix))
        if _suffix != ''
            _key := str.substring(_key, 0, str.length(_key) - str.length(_suffix))
    _key
[/pine]
💊 This simple function extract the multiple number from symbol.
[pine]
f_crypto_symbol_multiple(_fullname, _corekey) =>
    _f              = str.upper(_fullname)
    _k              = str.upper(_corekey)
    _k_pos          = (na(_k) or _k == '') ? na : str.pos(_f, _k)
    _multiple       = 1.0
    if not na(_k_pos)
        _colon_pos    = str.pos(_f, ':')
        _prefix_start = na(_colon_pos) ? 0 : _colon_pos + 1
        _between      = str.substring(_f, _prefix_start, _k_pos)
        _after        = str.substring(_f, _k_pos + str.length(_k))
        _pre_num      = str.match(_between, "^(?:1000000|10000|1000)$")
        _suf_num      = str.match(_after,   "^(?:1000000|10000|1000)")
        _raw = _pre_num != '' ? str.tonumber(_pre_num) : _suf_num != '' ? str.tonumber(_suf_num) : 1
        _multiple := na(_raw) ? 1.0 : _raw
    _multiple
[/pine]

💊  Coin name exceptions

The crypto names used by TradingView's CRYPTO: and CRYPTOCAP: feeds quite often differ from the names exchanges actually use (this happens among smaller coins — SLC → SLCS, HYPE → HYPEH, and the like). Each time one was found, it was manually verified to be the same coin and added to an exception list. That exception table is pre-checked on the actual M.CAP and Avg. Price security calls.

This simple function maps standard exchange crypto names to TradingView's native CRYPTO: , CRYPTOCAP: chart names.
[pine]
f_crypto_cryptocap_tv_ticker(_uv_chart_crypto_tickerhead_str) =>
    // CRYPTO:   CRYPTOCAP:  
    //────────────────────────────────────────────---
    //   EXCHANGES  =>  CRYPTOCAP   // Cypto name  
    //────────────────────────────────────────────---
    result_ticker   = switch _uv_chart_crypto_tickerhead_str   
        'SLC'       =>  'SLCS'      // Silencio
        'BABY'      =>  'BABYL'     // Babylon
        'HYPER'     =>  'HYPERL'    // Hyperlane
        'HYPERL'    =>  'HYPERL'    //   〃
        'HYPE'      =>  'HYPEH'     // Hyperliquid
        'BOB'       =>  'BOBBUIL'   // Build On Bitcoin
        'BOBBOB'    =>  'BOBBUIL'   //   〃
        'TAG'       =>  'TAGG'      // Tagger
        'TAO'       =>  'TAOB'      // TAO
        'TOSHI'     =>  'TOSHI3'    // Toshi
        'NEIROCTO'  =>  'NEIROF'    // First Neiro On Ethereum
        'NEIRO'     =>  'NEIROF'    //   〃
        'NEX'       =>  'NEXUS5'    // Nexus
        'RATS'      =>  'RATS2'     // Rats
        'CHEEMS'    =>  'CHEEMSC'   // Cheems
        'SATS'      =>  'SATSO'     // SATS (Ordinals)
        'CAT'       =>  'CATSI'     // Simon's Cat
        'TRUMP'     =>  'TRUMPOF'   // Trump official
        'USDS'      =>  'USDS2'     // USDS
        'MOVE'      =>  'MOVEM'     // Movement
        'MOCA'      =>  'MOCAV'     // Mocaverse
        'ZORA'      =>  'ZORA2'     // Zora
        'BARD'      =>  'BARDL'     // Lombard
        'ATH'       =>  'ATHAE'     // Aethir
        'SONIC'     =>  'SONICSV'   // Sonic SVM
        'KNC'       =>  'KNC'       // Kyber Network
        'ZRO'       =>  'ZROL'      // LayerZero
        'AMP'       =>  'AMP2'      // AMP
        'CHIP'      =>  'CHIPUS'    // USD.AI
        'RAVE'      =>  'RAVED'     // RaveDAO
        'PROS'      =>  'PROSPH'    // Pharos
        => _uv_chart_crypto_tickerhead_str
    result_ticker
[/pine]

💊  G-Index px (Reference market price)

A mix of the current chart's price and the whole-market average price. It is a buffer that keeps the base line from being dragged around by a momentary price jump on a single exchange. G-Index Price operates only when the current chart uses USDT, USDC, or USD as its base unit. -> takes the avg. price provided by TV -> converts it to the current chart's unit by exchange rate.
[pine]
//⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜
// G-Index PX  
//
varip bool  g_index_px_works           = false      
varip float g_index_px                 = na         
var float chart_current_multiple = not uv_chart_symbol_crypto_basequotetickvol_flg ? 
                  1.0 : f_crypto_symbol_multiple(uv_chart_tikerid_str, uv_chart_crypto_tickerhead_str)
var string chart_current_currency = syminfo.currency
float USD2USDT_avg_rate = request.security("CRYPTO:USDTUSD", timeframe.period, ta.sma(hlc3, 3)) 
float USD2USDC_avg_rate = request.security("CRYPTO:USDCUSD", timeframe.period, ta.sma(hlc3, 3)) 
bool USDT_is_DEPEG      = math.abs(USD2USDT_avg_rate - 1.0) * 100 >= 0.1 
bool USDC_is_DEPEG      = math.abs(USD2USDC_avg_rate - 1.0) * 100 >= 0.2 
var int chart_currency_convert_mode = switch chart_current_currency
    'USD'   => 1
    'USDT'  => 2
    'USDC'  => 3
    => 0
float g_avg_chart_ratio = switch chart_currency_convert_mode
    1  => 1.0 
    2  => (1.0 / USD2USDT_avg_rate)
    3  => (1.0 / USD2USDC_avg_rate)
    0  => 0.0
var bool chart_currency_convert_no_need =  (uv_chart_crypto_tickerhead_str == 'USDT') 
                                       or  (uv_chart_crypto_tickerhead_str == 'USDC')
                                       or  (uv_chart_crypto_tickerhead_str == 'USDS')
                                       or  (uv_chart_crypto_tickerhead_str == 'PYUSD')
                                       or  (uv_chart_crypto_tickerhead_str == 'USDP')
var string g_index_px_crypto_ticker = 'CRYPTO:' + f_crypto_cryptocap_tv_ticker(uv_chart_crypto_tickerhead_str) + 'USD'
if chart_currency_convert_mode != 0 
    g_index_px  := (request.security(g_index_px_crypto_ticker,timeframe.period, close * g_avg_chart_ratio,gaps=barmerge.gaps_on, ignore_invalid_symbol=true) * chart_current_multiple )
if not g_index_px_works and not na(g_index_px) and uv_volmode_ultravol_task_flg and not chart_currency_convert_no_need
    g_index_px_works := true
if g_index_px_works and na(g_index_px) and na(g_index_px[1])
    g_index_px_works := false

//G-Index - end
//⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜
[/pine]

🏁 [b]Listing detection and exception reporting[/b]

An exchange that was absent early in the chart and began trading midway is automatically included in the calculation from that point on, and appears on the panel. The top-right panel shows the current bar's volume both as an absolute number (in base units) and as per-pair UV-scaled markings. When an exception occurs — some data not provided on a particular timeframe, for instance — you can hover over the panel to see exactly how the indicator is operating right now. Better to show what is happening than to behave strangely in silence.


🏁 [b] You can check the uv engine (marking area like below) inside code.[/b]
[pine]
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜  
// Ultravol Core Engine
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
[/pine]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © GF4M
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
//
// ⦧𝑮𝑭4🅼　Ultravol 
//
const string _VERSION_ = 'v1.90'
// 
//@version=6
indicator("Ultravol - correct market volume [GF4M]","⦧𝑮𝑭4🅼　Ultravol",format=format.volume, dynamic_requests=true
                   , max_bars_back=3000 ,max_labels_count=50 ,overlay=true, scale=scale.none, explicit_plot_zorder=true) 
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-








//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// PRE-DEFINE
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
const color COLOR_TRANSP        = color.new(#000000,100)                                                                        
const color COLOR_BLACK         = color.new(#000000,  0)
//------------------------------------------------------------------------------
const string GR_ULTRAVOL  = '🟥🟧🟨⬜️🟦🟪　𝗥𝗘𝗪𝗜𝗥𝗘 𝗜𝗡𝗧𝗨𝗜𝗧𝗜𝗢𝗡　　　　　　　𝖴𝖵 '+_VERSION_
const string GR_ULTRAVOL_ = "READ VOLUME AS RELATIVE FORCE, NOT AS A NUMBER.　 \n"
                          + '─────────────────────────────　　 \n'
const string GR_UV_ULTRAVOL_TT_VAL  = ' \n'
                         +'⦧𝑮𝑭4🅼　Ultravol\n'
                         +'────────────────────── \n' 
                         +"✨ Gives you a trained trader's sense for volume — by color, instantly!\n"
                         +'\n'
                         +'📘 Reveal key market energy areas through volume-encoded candles, spectrum layer, v-ray, energy flux, and spike panel by color. A full legacy candle & volume chart replacement.\n'
                         +'\n'
                         +"📗 Final synthetic UV — Across many crypto exchanges, Ultravol curates 12 (spot + perp) — reverted to native base, weighted, spot/perp summed into one — to read the unified volume flow across the whole market.\n"
                         +'\n'
                         +"📙 Per-exchange UV level on the panel — Each exchange's volume, normalized to its own signature.  → Rendered on the same UV-defined color scale.  → Current candle's volume spike level (not raw volume) can be compared across exchanges at a glance.\n"
                         +'\n'
                         +'📕 Ultravol engine: Its own unique method. Synthetic UV (12-pair fusion) is crypto-exclusive — UV-scaled coloring works on any chart.\n'
                         +'\n'
                         +"🔗 Use together Ultravol, Ultravol Matrix (same language): Ultravol Matrix reads vol spike history, Ultravol reads live spike.\n"
                         +' \n\n'
const string GR_UV_ULTRAVOL_T2_VAL  = ' \n'
                         +'\n'
                         +'⦧𝑮𝑭4🅼　Ultravol\n'
                         +'────────────────────── \n' 
                         +' ☑ 📱           : Mobile friendly UI setup\n'
                         +' • Source        : Use Ultravol (Auto) normally\n'    
                         +' • Rescale      : Only for extremes, too 🔥 or too ⚫️\n'  
                         +'\n'                    
                         +' ☑ V-Ray   : Vertical highlight marks on big spike.\n'
                         +' ☑ Energy Flux  : 8 Spot(U), 4 Perp(L)\n'      
                         +'       + Trending energy balance (Spot vs Perp)\n'                    
                         +'\n'                    
                         +' ☑ Candles    : Chart candle × UV fusion.\n' 
                         +' ☑ Spectrum  : Synthetic UV from 12 vol src.\n'   
                         +'       + Instant energy read by UV-scaled color\n'                    
                         +'       + [In pane] Max height. Move to a pane first.\n'
                         +'\n'                    
                         +" ☑ Panel          : Exchange's raw vol (number)\n"
                         +'       + Current UV-scaled spike (color mark)\n'
                         +'       ☑ s  Smaller UI      ☑ ↓  Center-right\n'
                         +'       ☑ !  Wait Long · Act Fast (#1 principle)\n'
                         +'\n'                    
                         +'       🔸 Hover over the panel for detailed info.\n' 
                         +'────────────────────── \n'    
                         +'TradingView chart slows down? 🔸 Reopen it!\n'
                         +'\n'                    
                         +'⚠️ Ultravol must be placed at the very front.\n'
                         +'(To ensure the correct z-layer order of all graphics, including hybrid override candles, is displayed exactly as intended. )\n'
                         +'🔸 Ultravol ⋯ > Visual order > Bring to front \n'        
                         +'\n'                    
                         +'⚠️ ⚙︎ > Chart option > Symbol > Uncheck! "Color bars based on previous close."\n'
                         +' \n\n' 
const string GR_UV_CUSTOM_C_TT  = ' \n'
                         +'\n'
                         +'Ultravol Color Scheme\n'
                         +'────────────────────── \n' 
                         +'\n'
                         +'Signature: Default color scheme.\n'
                         +'\n'
                         +'Customize: Enable Color Picker.\n'
                         +'\n'
                         +' • Price ruler indicator:  Neutral, Up, Down.\n'    
                         +' • No vol chart candle:  Up, Down. \n'    
                         +' • Volume encoded candle:  Full Spectrum.\n'    
                         +'\n'                        
                         +'⚠️ UV-scaled level color is fixed \n'
                         +'to ensure consistent visibility at all times.\n'
                         +'\n'                         
                         +'────────────────────── \n' 
                         +'\n'
                         +'\n'
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-



 



//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🌫️🌫️🌫️🌫️ INPUT
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
const bool _DEV_MODE_ = false               
const bool _INPUT_C_ACTIVE  = _DEV_MODE_   
const bool _INPUT_C_ACTIVE2 = true          // candle up/down only 
const bool _SECRET_KEY      = _DEV_MODE_    // Ultravol secret key #def0123,34%
//-----------------------------------------------
// 🌫️ INPUT: Mobile friendly UI
mobile_friendly_flg        = input.bool  (false,'📱', inline='ultravol_rescale'  ,group=GR_ULTRAVOL)

//-----------------------------------------------
// 🌫️ INPUT: foce Chart Vol 
enum uv_source_mode
    auto        = 'Ultravol (Auto)' 
    chart_force = 'Chart Vol (Force)'
ultravol_source_mode_selector = input.enum(uv_source_mode.auto, '', inline='ultravol_rescale',group=GR_ULTRAVOL)
var ultravol_force_chartvol_flg = ultravol_source_mode_selector == uv_source_mode.chart_force

//-----------------------------------------------
// ⬜ INPUT: rescaling
enum uv_rescale_mode
    plus2   = '▲ +2'
    plus1   = '▲ +1'
    neutral = '🌡️'
    minus1  = '▽ -1'
    minus2  = '▽ -2'
ultravol_rescale_mode_selector = input.enum(uv_rescale_mode.neutral, '', inline='ultravol_rescale',group=GR_ULTRAVOL
                             ,tooltip=GR_UV_ULTRAVOL_TT_VAL)
var ultravol_rescale_step = switch ultravol_rescale_mode_selector
    uv_rescale_mode.plus2   => 2.0
    uv_rescale_mode.plus1   => 1.0
    uv_rescale_mode.minus1  => -1.0
    uv_rescale_mode.minus2  => -2.0
    => 0.0
var ultravol_rescale_ratio = math.pow(2, -ultravol_rescale_step)
var string ultravol_rescale_mode_text = switch ultravol_rescale_mode_selector
    uv_rescale_mode.plus2   => '   ▲  +2  '
    uv_rescale_mode.plus1   => '   ▲  +1  '
    uv_rescale_mode.minus1  => '   ▽  -1  '
    uv_rescale_mode.minus2  => '   ▽  -2  '
    => '🌡️'

//-----------------------------------------------
// ⬜ INPUT: COLOR - V-Ray
ultravol_vray_flg           = input.bool  (true                       ,"Ultravol V-Ray ", inline='ultravol_0'  ,group=GR_ULTRAVOL_, tooltip=GR_UV_ULTRAVOL_T2_VAL)
ultravol_vray_color_1       = input.color (color.new(#b2b5be,50)    ,"",                inline='ultravol_0'  ,group=GR_ULTRAVOL_,active=false)
ultravol_vray_color_2       = input.color (color.new(#ffe900,50)    ,"",                inline='ultravol_0'  ,group=GR_ULTRAVOL_,active=false)
ultravol_vray_color_3       = input.color (color.new(#0087ff,50)    ,"",                inline='ultravol_0'  ,group=GR_ULTRAVOL_,active=false)
// ultravol_vray_bright_flg    = input.bool  (true                       ,"✴︎",            inline='ultravol_0'  ,group=GR_ULTRAVOL_,active=ultravol_vray_flg)
ultravol_vray_bright_flg    = true


//-----------------------------------------------
// ⬜ INPUT: COLOR - Energy Flux
// SPOT
ultravol_energyflux_flg   = input.bool  (true,"Ultravol Energy Flux"    ,inline='flux',group=GR_ULTRAVOL_)
color UV_SPOT_SS_COLOR_7  = input.color(color.new(#ff0000 ,0),'　 s   ', inline='_spot' ,group=GR_ULTRAVOL_ ,active=_INPUT_C_ACTIVE)
color UV_SPOT_SS_COLOR_6  = input.color(color.new(#ff9900 ,0),'', inline='_spot' ,group=GR_ULTRAVOL_ ,active=_INPUT_C_ACTIVE)
color UV_SPOT_SS_COLOR_5  = input.color(color.new(#00efff, 0),'', inline='_spot' ,group=GR_ULTRAVOL_ ,active=_INPUT_C_ACTIVE)
color UV_SPOT_SS_COLOR_4  = input.color(color.new(#0099cc, 0),'', inline='_spot' ,group=GR_ULTRAVOL_ ,active=_INPUT_C_ACTIVE)
color UV_SPOT_SS_COLOR_3  = input.color(color.new(#005999, 0),'', inline='_spot' ,group=GR_ULTRAVOL_ ,active=_INPUT_C_ACTIVE)
color UV_SPOT_SS_COLOR_2  = color.new(#004072, 0)
color UV_SPOT_SS_COLOR_1  = color.new(#002957, 0)
color UV_SPOT_SS_COLOR_0  = color.new(#001c39, 0)
// PERP
color UV_PERP_SS_COLOR_7  = input.color(color.new(#ff0000 ,0),'　 p   ', inline='_perp' ,group=GR_ULTRAVOL_ ,active=_INPUT_C_ACTIVE)
color UV_PERP_SS_COLOR_6  = input.color(color.new(#ff9900 ,0),'', inline='_perp' ,group=GR_ULTRAVOL_,active=_INPUT_C_ACTIVE)
color UV_PERP_SS_COLOR_5  = input.color(color.new(#7bfd00 ,0),'', inline='_perp' ,group=GR_ULTRAVOL_,active=_INPUT_C_ACTIVE)
color UV_PERP_SS_COLOR_4  = input.color(color.new(#09a132 ,0),'', inline='_perp' ,group=GR_ULTRAVOL_,active=_INPUT_C_ACTIVE)
color UV_PERP_SS_COLOR_3  = input.color(color.new(#096120 ,0),'', inline='_perp' ,group=GR_ULTRAVOL_,active=_INPUT_C_ACTIVE)
color UV_PERP_SS_COLOR_2  = color.new(#094522 ,0)
color UV_PERP_SS_COLOR_1  = color.new(#003030 ,0)
color UV_PERP_SS_COLOR_0  = color.new(#001e1e ,0)

//-----------------------------------------------
// ⬜ INPUT: Candles, Spectrum, Draw mode
ultravol_g_index_flg        = input.bool  (false,"Ultravol G-Index price (REF)　 ",inline='ultravol_px'   ,group=GR_ULTRAVOL_)
ultravol_g_index_color      = input.color (color.new(#32Deff,50),''             ,inline='ultravol_px'   ,group=GR_ULTRAVOL_)
ultravol_candles_flg        = input.bool  (true,"Ultravol Fusion Candles",     inline='ultravol1'   ,group=GR_ULTRAVOL_)
ultravol_spectrum_flg       = input.bool  (true,"Ultravol Spectrum         "    ,inline='ultravol_bar',group=GR_ULTRAVOL_)
enum uv_drawing_mode
    overlay = 'On chart mode'
    pane    = 'In pane mode'
ultravol_drawing_mode_select = input.enum(uv_drawing_mode.overlay, ''      ,inline='ultravol_bar',group=GR_ULTRAVOL_)
var ultravol_draw_inpane_flg = ultravol_drawing_mode_select == uv_drawing_mode.pane

//-----------------------------------------------
// ⬜ INPUT: Spike Panel
ultravol_panel_show_flg     = input.bool  (true,'Ultravol Spike Panel ',  inline='ultravol111' ,group=GR_ULTRAVOL_ )
ultravol_panel_small_flg    = input.bool  (false,'𝗌  ', inline='ultravol111' ,group=GR_ULTRAVOL_, active=ultravol_panel_show_flg and not mobile_friendly_flg) or mobile_friendly_flg
ultravol_panel_notice_flg   = input.bool  (true,'!  ', inline='ultravol111' ,group=GR_ULTRAVOL_, active=ultravol_panel_show_flg)
ultravol_panel_movedown_flg = input.bool  (false,'⬇︎',       inline='ultravol111' ,group=GR_ULTRAVOL_, active=ultravol_panel_show_flg)
ultravol_mark_show_flg      = input.bool  (true,'Ultravol Status Label    ',  inline='ultravolmark' ,group=GR_ULTRAVOL_ )
ultravol_mark_color1_nul    = input.color (#32Deff ,'' ,inline='ultravolmark' ,active=false,group=GR_ULTRAVOL_ )
ultravol_mark_color2_nul    = input.color (#b5e93f ,'' ,inline='ultravolmark' ,active=false,group=GR_ULTRAVOL_ )
 

//-----------------------------------------------
// ⬜ Color scheme
enum uv_color_scheme
    custom    = 'Customize'
    signature = '𝙎𝙞𝙜𝙣𝙖𝙩𝙪𝙧𝙚'
uv_color_scheme_selector       = input.enum(uv_color_scheme.signature, 'Ultravol Color Scheme　   ' ,inline='color_scheme',tooltip=GR_UV_CUSTOM_C_TT)
var uv_color_custom_active_flg = uv_color_scheme_selector == uv_color_scheme.custom


//-----------------------------------------------
// ⬜ INPUT: COLOR - Reference
uv_exchange_00_color        = input.color (#887788 ,'         　Direction  　' ,inline='uv_ref_cd' ,active=uv_color_custom_active_flg)
uv_exchange_up_color        = input.color (#2ebd85 ,'　' ,inline='uv_ref_cd' ,active=uv_color_custom_active_flg)
uv_exchange_dn_color        = input.color (#f6465d ,'　' ,inline='uv_ref_cd' ,active=uv_color_custom_active_flg)
var uv_direction_00_color   = color.new(uv_exchange_00_color,50)
var uv_direction_up_color   = color.new(uv_exchange_up_color,50)
var uv_direction_dn_color   = color.new(uv_exchange_dn_color,50)

//-----------------------------------------------
// ⬜ INPUT: COLOR - No Volume Data 
uv_secret_key           = input.color (#292929,'       　　No Vol     　', inline='uv_ref_c0', active=_SECRET_KEY)
uv_NoVolData_up_color   = input.color (#9d9d9f,'　' ,inline='uv_ref_c0' ,active=uv_color_custom_active_flg)
uv_NoVolData_dn_color   = input.color (#3b3b3f,'　' ,inline='uv_ref_c0' ,active=uv_color_custom_active_flg)
//  Secret Key   -   DEV Debug mode 
var uv_debuglabel_detailed_show_flg = uv_secret_key == color.new(#def012,66)

//-----------------------------------------------
// ⬜ INPUT: COLOR - Volume, Candle Up/Down 
//
// UV Spectrum Color
uv_spectrum_7_color     = input.color (#8400ff ,'       　　Level 7　' ,inline='uv_ref_c1' ,active=_INPUT_C_ACTIVE)
uv_spectrum_6_color     = input.color (#0048ff ,'       　　Level 6　' ,inline='uv_ref_c2' ,active=_INPUT_C_ACTIVE)
uv_spectrum_5_color     = input.color (#0b9ed0 ,'       　　Level 5　' ,inline='uv_ref_c3' ,active=_INPUT_C_ACTIVE)
uv_spectrum_4_color     = input.color (#c0ccff ,'       　　Level 4　' ,inline='uv_ref_c4' ,active=_INPUT_C_ACTIVE)
uv_spectrum_3_color     = input.color (#c0a000 ,'       　　Level 3　' ,inline='uv_ref_c5' ,active=_INPUT_C_ACTIVE)
uv_spectrum_2_color     = input.color (#c65d10 ,'       　　Level 2　' ,inline='uv_ref_c6' ,active=_INPUT_C_ACTIVE)
uv_spectrum_1_color     = input.color (#aa1913 ,'       　　Level 1　' ,inline='uv_ref_c7' ,active=_INPUT_C_ACTIVE)
uv_spectrum_reg_color   = input.color (#66001b ,'       　　Level 0　' ,inline='uv_ref_c8' ,active=_INPUT_C_ACTIVE)
uv_spectrum_low_color   = input.color (#30323a ,'       　　Level 1　' ,inline='uv_ref_c9' ,active=_INPUT_C_ACTIVE)
uv_spectrum_sub_color   = input.color (#1e1a33 ,'       　　Level 2　' ,inline='uv_ref_cA' ,active=_INPUT_C_ACTIVE)
 // UV Candle Up Color
uv_candle_up7_color     = input.color (#fff900 ,'　', inline='uv_ref_c1' ,active=uv_color_custom_active_flg)
uv_candle_up6_color     = input.color (#c0ff00 ,'　', inline='uv_ref_c2' ,active=uv_color_custom_active_flg)
uv_candle_up5_color     = input.color (#77f700 ,'　', inline='uv_ref_c3' ,active=uv_color_custom_active_flg)
uv_candle_up4_color     = input.color (#00fb39 ,'　', inline='uv_ref_c4' ,active=uv_color_custom_active_flg)
uv_candle_up3_color     = input.color (#00d55b ,'　', inline='uv_ref_c5' ,active=uv_color_custom_active_flg)
uv_candle_up2_color     = input.color (#00aa66 ,'　', inline='uv_ref_c6' ,active=uv_color_custom_active_flg)
uv_candle_up1_color     = input.color (#088480 ,'　', inline='uv_ref_c7' ,active=uv_color_custom_active_flg)
uv_candle_up_reg_color  = input.color (#156170 ,'　', inline='uv_ref_c8' ,active=uv_color_custom_active_flg)
uv_candle_up_low_color  = input.color (#2f446c ,'　', inline='uv_ref_c9' ,active=uv_color_custom_active_flg)
uv_candle_up_sub_color  = input.color (#242864 ,'　', inline='uv_ref_cA' ,active=uv_color_custom_active_flg)
// UV Candle Dn Color
uv_candle_dn7_color     = input.color (#ff8800 ,'　', inline='uv_ref_c1' ,active=uv_color_custom_active_flg)
uv_candle_dn6_color     = input.color (#ff5b00 ,'　', inline='uv_ref_c2' ,active=uv_color_custom_active_flg)
uv_candle_dn5_color     = input.color (#f73301 ,'　', inline='uv_ref_c3' ,active=uv_color_custom_active_flg)
uv_candle_dn4_color     = input.color (#f70101 ,'　', inline='uv_ref_c4' ,active=uv_color_custom_active_flg)
uv_candle_dn3_color     = input.color (#e2003d ,'　', inline='uv_ref_c5' ,active=uv_color_custom_active_flg)
uv_candle_dn2_color     = input.color (#b0004e ,'　', inline='uv_ref_c6' ,active=uv_color_custom_active_flg)
uv_candle_dn1_color     = input.color (#8f1d4f ,'　', inline='uv_ref_c7' ,active=uv_color_custom_active_flg)
uv_candle_dn_reg_color  = input.color (#7a285d ,'　', inline='uv_ref_c8' ,active=uv_color_custom_active_flg)
uv_candle_dn_low_color  = input.color (#6b346a ,'　', inline='uv_ref_c9' ,active=uv_color_custom_active_flg)
uv_candle_dn_sub_color  = input.color (#4b204f ,'　', inline='uv_ref_cA' ,active=uv_color_custom_active_flg)

//-----------------------------------------------
// ⬜ FIXED: Ultravol Level Scale  (Vol/Marketmean Vol)
const float ULTRAVOL_LEVEL_RATIO_G_VAL          = 55.0
const float ULTRAVOL_LEVEL_RATIO_F_VAL          = 34.0
const float ULTRAVOL_LEVEL_RATIO_E_VAL          = 19.0 
const float ULTRAVOL_LEVEL_RATIO_D_VAL          = 12.0
const float ULTRAVOL_LEVEL_RATIO_C_VAL          = 7.2
const float ULTRAVOL_LEVEL_RATIO_B_VAL          = 4.1
const float ULTRAVOL_LEVEL_RATIO_A_VAL          = 2.3
const float ULTRAVOL_LEVEL_RATIO_LOW_VAL        = 1.5
const float ULTRAVOL_LEVEL_RATIO_MEANLESS_VAL   = 0.725

//-----------------------------------------------
// ⬜ FIXED: Ultravol Energy Flux Level Scale
const float UV_SS_LEVEL_R_0     = 2.0
const float UV_SS_LEVEL_R_1     = 2.5
const float UV_SS_LEVEL_R_2     = 3.0
const float UV_SS_LEVEL_R_3     = 4.2
const float UV_SS_LEVEL_R_4     = 6.0
const float UV_SS_LEVEL_R_5     = 8.0
const float UV_SS_LEVEL_R_6     = 9.8
const float UV_SS_LEVEL_R_7     = 12.0

//-----------------------------------------------
// ⬜ INPUT: TV's Fast Calc force --> workaround Notice, currently Fast Calc rollback
// _xx_ = input.color(#ff0000,'─── 𝙉𝙀𝙑𝙀𝙍 𝘾𝙃𝘼𝙉𝙂𝙀 𝘽𝙀𝙇𝙊𝙒 ───     ', inline='1234' ,active=false)

//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🌫️🌫️🌫️🌫️ INPUT - END
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-











































// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
//
//   Ultravol Core Engine 
//
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜

// Chart OHLC
float uv_chartvol                           = volume
float uv_chart_px                           = close
float uv_chart_high                         = high
float uv_chart_low                          = low
float uv_chart_open                         = open
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦🟦 fn() Base
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
f_crypto_symbol_corekey(_tickerid, _basecurrency) =>
    _tickerid_upper = str.upper(_tickerid)
    _key            = str.upper(_basecurrency)
    if str.contains(_tickerid_upper, ":1000000BOB")
        _key := '1000000BOB'
    else
        _prefix = str.match(_key, "^(?:1000000|10000|1000)")
        _suffix = str.match(_key, "(?:1000000|10000|1000)$")
        if _prefix != ''
            _key := str.substring(_key, str.length(_prefix))
        if _suffix != ''
            _key := str.substring(_key, 0, str.length(_key) - str.length(_suffix))
    _key

f_crypto_symbol_multiple(_fullname, _corekey) =>
    _f              = str.upper(_fullname)
    _k              = str.upper(_corekey)
    _k_pos          = (na(_k) or _k == '') ? na : str.pos(_f, _k)
    _multiple       = 1.0
    if not na(_k_pos)
        _colon_pos    = str.pos(_f, ':')
        _prefix_start = na(_colon_pos) ? 0 : _colon_pos + 1
        _between      = str.substring(_f, _prefix_start, _k_pos)
        _after        = str.substring(_f, _k_pos + str.length(_k))
        _pre_num      = str.match(_between, "^(?:1000000|10000|1000)$")
        _suf_num      = str.match(_after,   "^(?:1000000|10000|1000)")
        _raw = _pre_num != '' ? str.tonumber(_pre_num) : _suf_num != '' ? str.tonumber(_suf_num) : 1
        _multiple := na(_raw) ? 1.0 : _raw
    _multiple

f_crypto_cryptocap_tv_ticker(_uv_chart_crypto_tickerhead_str) =>
    // CRYPTO:   CRYPTOCAP:  
    //────────────────────────────────────────────---
    //   EXCHANGES  =>  CRYPTOCAP   // Cypto name  
    //────────────────────────────────────────────---
    result_ticker   = switch _uv_chart_crypto_tickerhead_str   
        'SLC'       =>  'SLCS'      // Silencio
        'BABY'      =>  'BABYL'     // Babylon
        'HYPER'     =>  'HYPERL'    // Hyperlane
        'HYPERL'    =>  'HYPERL'    //   〃
        'HYPE'      =>  'HYPEH'     // Hyperliquid
        'BOB'       =>  'BOBBUIL'   // Build On Bitcoin
        'BOBBOB'    =>  'BOBBUIL'   //   〃
        'TAG'       =>  'TAGG'      // Tagger
        'TAO'       =>  'TAOB'      // TAO
        'TOSHI'     =>  'TOSHI3'    // Toshi
        'NEIROCTO'  =>  'NEIROF'    // First Neiro On Ethereum
        'NEIRO'     =>  'NEIROF'    //   〃
        'NEX'       =>  'NEXUS5'    // Nexus
        'RATS'      =>  'RATS2'     // Rats
        'CHEEMS'    =>  'CHEEMSC'   // Cheems
        'SATS'      =>  'SATSO'     // SATS (Ordinals)
        'CAT'       =>  'CATSI'     // Simon's Cat
        'TRUMP'     =>  'TRUMPOF'   // Trump official
        'USDS'      =>  'USDS2'     // USDS
        'MOVE'      =>  'MOVEM'     // Movement
        'MOCA'      =>  'MOCAV'     // Mocaverse
        'ZORA'      =>  'ZORA2'     // Zora
        'BARD'      =>  'BARDL'     // Lombard
        'ATH'       =>  'ATHAE'     // Aethir
        'SONIC'     =>  'SONICSV'   // Sonic SVM
        'KNC'       =>  'KNC'       // Kyber Network
        'ZRO'       =>  'ZROL'      // LayerZero
        'AMP'       =>  'AMP2'      // AMP
        'CHIP'      =>  'CHIPUS'    // USD.AI
        'RAVE'      =>  'RAVED'     // RaveDAO
        'PROS'      =>  'PROSPH'    // Pharos
        => _uv_chart_crypto_tickerhead_str
    result_ticker
   
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨🟨 Chart base info.
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
    
//-----------------------------------------------------------
// 🟨 Chart - symbol - Crypto with volume ? 
var bool   uv_chart_symbol_crypto_basequotetickvol_flg = syminfo.type == 'crypto' and syminfo.volumetype != 'n/a' 
var bool   uv_chart_symbol_nodata_flg = (syminfo.prefix == 'TVC' and syminfo.type == 'index') or syminfo.prefix == 'CRYPTOCAP'

//-----------------------------------------------------------
// 🟨 Chart - symbol ticker string
var string uv_chart_tikerid_str             = ticker.standard(syminfo.tickerid)
var string uv_chart_crypto_tickerhead_str   = uv_chart_symbol_crypto_basequotetickvol_flg ? f_crypto_symbol_corekey(uv_chart_tikerid_str, syminfo.basecurrency) : ''
// var string uv_chart_crypto_tickertail_str   = 

//-----------------------------------------------------------
// 🟨 edge case: Tradingview Crypto INDEX chart
if barstate.isfirst
    if uv_chart_tikerid_str == 'INDEX:BTCUSD' 
        uv_chart_symbol_crypto_basequotetickvol_flg := true
        uv_chart_crypto_tickerhead_str       := 'BTC'
    else if uv_chart_tikerid_str == 'INDEX:ETHUSD' 
        uv_chart_symbol_crypto_basequotetickvol_flg := true
        uv_chart_crypto_tickerhead_str       := 'ETH'

//-----------------------------------------------------------
// 🟨 Chart - volume - No Vol status check
var bool uv_chart_vol_unavailable_flg  = na(volume) or uv_chart_symbol_nodata_flg




// 🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧
//   MASTER GATE - throttling setup 
// 🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧
var bool uv_throttleGATE_required   = uv_chart_symbol_crypto_basequotetickvol_flg
varip bool bar_NOTLIVE_flg          = false
varip bool bar_GATEbypass_flg       = false
bar_NOTLIVE_flg         := uv_throttleGATE_required 
                          and barstate.isrealtime and (timenow - (time_close + ((time_close - time)*2)) > 0)
bar_GATEbypass_flg      := not (uv_throttleGATE_required and barstate.isrealtime and not bar_NOTLIVE_flg)       
const int UV_MASTERGATE_RATE_T_VAL  = 160       // ms
varip int uv_MasterGATE_last_t      = na        // Last GATE Open time = LINUX time ms
varip bool uv_MasterGATEopen_flg    = false     
uv_MasterGATEopen_flg := bar_GATEbypass_flg 
                      or na(uv_MasterGATE_last_t) 
                      or (timenow - uv_MasterGATE_last_t >= UV_MASTERGATE_RATE_T_VAL) 
                      or barstate.isconfirmed
if not bar_GATEbypass_flg and uv_MasterGATEopen_flg  
    uv_MasterGATE_last_t := timenow
// 🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧
//   MASTER GATE - throttling setup End
// 🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧




//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🟦🟦🟦🟦 fn() - UV engine
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
type cryptoVol
    float vol
    bool valid   
f_crypto_vol (_symbol, _multiple) =>
    _req_vol = request.security(_symbol, timeframe.period, (syminfo.volumetype=='quote'? (volume/hlc3) : volume) , gaps=barmerge.gaps_on, ignore_invalid_symbol=true)
    // OKX perp --> Volume = quote, USDT unit
    cryptoVol.new(nz(_req_vol, 0.0) * _multiple, not na(_req_vol))

f_smooth(_v) =>
    _x = ta.ema(_v,3), _result = nz(ta.ema(_v*_v,3)/_x,_x)
//--------------
// row layout: 0 corekey, 1 Binance, 2 Binance USDC 3 Coinbase, 4 Bybit, 5 OKX, 6 Upbit, 7 Kraken, 8 Bitget,  1 Binance.P, 2 Coinbase.P, 3 Bybit.P, 4 OKX.P
//---------------
const int CRYPTO_LP_ROW_SIZE_VAL = 13
const string[] crypto_lp_rows = array.from(
      'PEPE',     'Binance:PEPEUSDT',       'Binance:PEPEUSDC',       'Coinbase:PEPEUSD',   'Bybit:PEPEUSDT',     'OKX:PEPEUSDT',     'Upbit:PEPEKRW',  'Kraken:PEPEUSD',  'Bitget:PEPEUSDT'    ,'Binance:1000PEPEUSDT.P',   'Coinbase:1000PEPEUSDC.P',  'Bybit:1000PEPEUSDT.P'        ,'OKX:PEPEUSDT.P'
     ,'SHIB',     'Binance:SHIBUSDT',       'Binance:SHIBUSDC',       'Coinbase:SHIBUSD',   'Bybit:SHIBUSDT',     'OKX:SHIBUSDT',     'Upbit:SHIBKRW',  'Kraken:SHIBUSD',  'Bitget:SHIBUSDT'    ,'Binance:1000SHIBUSDT.P',   'Coinbase:1000SHIBUSDC.P',  'Bybit:SHIB1000USDT.P'        ,'OKX:SHIBUSDT.P'
     ,'BONK',     'Binance:BONKUSDT',       'Binance:BONKUSDC',       'Coinbase:BONKUSD',   'Bybit:BONKUSDT',     'OKX:BONKUSDT',     'Upbit:BONKKRW',  'Kraken:BONKUSD',  'Bitget:BONKUSDT'    ,'Binance:1000BONKUSDT.P',   'Coinbase:1000BONKUSDC.P',  'Bybit:1000BONKUSDT.P'        ,'OKX:BONKUSDT.P'
     ,'FLOKI',    'Binance:FLOKIUSDT',      'Binance:FLOKIUSDC',      'Coinbase:FLOKIUSD',  'Bybit:FLOKIUSDT',    'OKX:FLOKIUSDT',    '',               'Kraken:FLOKIUSD', 'Bitget:FLOKIUSDT'   ,'Binance:1000FLOKIUSDT.P',  'Coinbase:1000FLOKIUSDC.P', 'Bybit:1000FLOKIUSDT.P'       ,'OKX:FLOKIUSDT.P'
     ,'RATS',     '',                       '',                       '',                   'Bybit:RATSUSDT',     '',                 '',               '',                'Bitget:RATSUSDT'    ,'Binance:1000RATSUSDT.P',   '',                         'Bybit:1000RATSUSDT.P'        ,''
     ,'LUNC',     'Binance:LUNCUSDT',       'Binance:LUNCUSDC',       '',                   'Bybit:LUNCUSDT',     '',                 '',               '',                'Bitget:LUNCUSDT'    ,'Binance:1000LUNCUSDT.P',   '',                         'Bybit:1000LUNCUSDT.P'        ,''
     ,'XEC',      'Binance:XECUSDT',        '',                       '',                   '',                   '',                 'Upbit:XECKRW',   '',                ''                   ,'Binance:1000XECUSDT.P',    '',                         'Bybit:1000XECUSDT.P'         ,''
     ,'CAT',      'Binance:1000CATUSDT',    'Binance:1000CATUSDC',    '',                   'Bybit:CATUSDT',      'OKX:CATUSDT',      '',               'Kraken:CATUSD',   ''                   ,'Binance:1000CATUSDT.P',    '',                         'Bybit:1000CATUSDT.P'         ,''
     ,'SATS',     'Binance:1000SATSUSDT',   'Binance:1000SATSTRY',    '',                   'Bybit:SATSUSDT',     'OKX:SATSUSDT',     '',               '',                'Bitget:SATSUSDT'    ,'Binance:1000SATSUSDT.P',   '',                         'Bybit:10000SATSUSDT.P'       ,'OKX:SATSUSDT.P'
     ,'CHEEMS',   'Binance:1000CHEEMSUSDT', 'Binance:1000CHEEMSUSDC', '',                   '',                   '',                 '',               'Kraken:CHEEMSUSD','Bitget:CHEEMSUSDT'  ,'Binance:1000CHEEMSUSDT.P', '',                         'Bybit:1000000CHEEMSUSDT.P'   ,''
     ,'MOG',      '',                       '',                       'Coinbase:MOGUSD',    'Bybit:MOGUSDT',      '',                 '',               'Kraken:MOGUSD',   'Bitget:MOGUSDT'     ,'Binance:1000000MOGUSDT.P', 'Coinbase:1000MOGUSDC.P',   'Bybit:1000000MOGUSDT.P'      ,''
     ,'BOB',      '',                       '',                       'Coinbase:BOBBOBUSD', '',                   '',                 '',               'Kraken:BOBUSD',   ''                   ,'Binance:BOBUSDT.P',        '',                         'Bybit:BOBBOBUSDT.P'          ,''
     ,'BOBBOB',   '',                       '',                       'Coinbase:BOBBOBUSD', '',                   '',                 '',               'Kraken:BOBUSD',   ''                   ,'Binance:BOBUSDT.P',        '',                         'Bybit:BOBBOBUSDT.P'          ,''
     ,'BABYDOGE', '',                       '',                       '',                   'Bybit:BABYDOGEUSDT', 'OKX:BABYDOGEUSDT', '',               '',                'Bitget:BABYDOGEUSDT','',                         '',                         'Bybit:1000000BABYDOGEUSDT.P' ,''
     ,'BTT',      '',                       '',                       '',                   'Bybit:BTTUSDT',      '',                 'Upbit:BTTKRW',   'Kraken:BTTUSD',   'Bitget:BTTUSDT'     ,'',                         '',                         'Bybit:1000BTTUSDT.P'         ,''
     ,'QUBIC',    '',                       '',                       '',                   '',                   '',                 '',               '',                'Bitget:QUBICUSDT'   ,'',                         '',                         'Bybit:10000QUBICUSDT.P'      ,''
     ,'NEIROCTO', 'Binance:NEIROUSDT',      'Binance:NEIROUSDC',      '',                   'Bybit:NEIROCTOUSDT', 'OKX:NEIROUSDT',    '',               '',                'Bitget:NEIROCTOUSDT','Binance:NEIROUSDT.P',      '',                         'Bybit:1000NEIROCTOUSDT.P'    ,'OKX:NEIROUSDT.P'
     ,'NEIRO',    'Binance:NEIROUSDT',      'Binance:NEIROUSDC',      '',                   'Bybit:NEIROCTOUSDT', 'OKX:NEIROUSDT',    '',               '',                'Bitget:NEIROCTOUSDT','Binance:NEIROUSDT.P',      '',                         'Bybit:1000NEIROCTOUSDT.P'    ,'OKX:NEIROUSDT.P'
     ,'NEX',      '',                       '',                       'Coinbase:NEXUSD',    '',                   '',                 '',               'Kraken:NEXUSD',   'Bitget:NEXUSDT'     ,'',                         '',                         'Bybit:10000NEXUSDT.P'        ,''
     ,'TOSHI',    '',                       '',                       'Coinbase:TOSHIUSD',  'Bybit:TOSHIUSDT',    'OKX:TOSHIUSDT',    'Upbit:TOSHIKRW', 'Kraken:TOSHIUSD', 'Bitget:TOSHIUSDT'   ,'Binance:TOSHIUSDT.P',      'Coinbase:1000TOSHIUSDC.P', 'Bybit:1000TOSHIUSDT.P'       ,''
     ,'TURBO',    'Binance:TURBOUSDT',      'Binance:TURBOUSDC',      'Coinbase:TURBOUSD',  '',                   'OKX:TURBOUSDT',    '',               'Kraken:TURBOUSD', 'Bitget:TURBOUSDT'   ,'Binance:TURBOUSDT.P',      'Coinbase:TURBOUSDC.P',     'Bybit:1000TURBOUSDT.P'       ,'OKX:TURBOUSDT.P'
     ,'TAG',      '',                       '',                       '',                   '',                   '',                 '',               '',                'Bitget:TAGUSDT'     ,'Binance:TAGUSDT.P',        '',                         'Bybit:1000TAGUSDT.P'         ,''
     ,'USDT',     'Binance:USDTUSD',        'Binance:USDTUSDC',       'Coinbase:USDTUSD',   'Bybit:USDTUSD',      'OKX:USDTUSD',      'Upbit:USDTKRW',  'Kraken:USDTUSD',  'Bitget:USDTUSD'     ,'',                         '',                         ''                            ,''
     ,'USDC',     'Binance:USDCUSDT',       'Binance:USDCUSD',        'Coinbase:USDCEUR',   'Bybit:USDCUSDT',     'OKX:USDCUSDT',     'Upbit:USDCKRW',  'Kraken:USDCUSD',  'Bitget:USDCUSDT'    ,'Binance:USDCUSDT.P',       '',                         ''                            ,''
     ,'USDS',     'Binance:USDSUSDT',       'Binance:USDSUSDC',       'Coinbase:USDSUSD',   '',                   'OKX:USDSUSDT',     'Upbit:USDSKRW',  'Kraken:USDSUSD',  'Bitget:USDSUSDT'    ,'',                         '',                         ''                            ,''
     )

const int UV_VOL_SCALEDOWN_ROW_SIZE_VAL = 2
const string[] uv_vol_scaledown_rows = array.from(
      'PEPE',     '1000000'
     ,'SHIB',     '100000'
     ,'BONK',     '100000'
     ,'FLOKI',    '1000'
     ,'RATS',     '1000'
     ,'LUNC',     '1000'
     ,'XEC',      '1000'
     ,'CAT',      '100000'
     ,'SATS',     '1000000'
     ,'CHEEMS',   '100000'
     ,'MOG',      '1000000'
     ,'BOB',      '100'
     ,'BOBBOB',   '100'
     ,'BABYDOGE', '10000000'
     ,'BTT',      '100000'
     ,'QUBIC',    '10000'
     ,'NEIROCTO', '1000'
     ,'NEIRO',    '1000'
     ,'NEX',      '1000'
     ,'TOSHI',    '1000'
     ,'TURBO',    '100'
     ,'TAG',      '100'
     ,'────────-','---'
     ,'XRP',      '10'
     ,'SEI',      '10'
     ,'DOGE',     '100'
)

f_crypto_table_row_info(_corekey) =>
    string _s1 = na, string _s2 = na, string _s3 = na, string _s4 = na, string _s5 = na, string _s6 = na, string _s7 = na, string _s8 = na
    string _p1 = na, string _p2 = na, string _p3 = na, string _p4 = na
    const string _s1_EX_template = "Binance:_USDT"
    const string _s2_EX_template = "Binance:_USDC"
    const string _s3_EX_template = "Coinbase:_USD"
    const string _s4_EX_template = "Bybit:_USDT"
    const string _s5_EX_template = "OKX:_USDT"
    const string _s6_EX_template = "Upbit:_KRW"
    const string _s7_EX_template = "Kraken:_USD"
    const string _s8_EX_template = "Bitget:_USDT"
    const string _p1_EX_template = "Binance:_USDT.P"
    const string _p2_EX_template = "Coinbase:_USDC.P"
    const string _p3_EX_template = "Bybit:_USDT.P"
    const string _p4_EX_template = "OKX:_USDT.P"
    bool _valid = false 
    //
    _row_count = int(array.size(crypto_lp_rows) / CRYPTO_LP_ROW_SIZE_VAL)
    for _row = 0 to _row_count - 1
        _base = _row * CRYPTO_LP_ROW_SIZE_VAL
        if array.get(crypto_lp_rows, _base) == _corekey
            _s1 := array.get(crypto_lp_rows, _base + 1)
            _s2 := array.get(crypto_lp_rows, _base + 2)
            _s3 := array.get(crypto_lp_rows, _base + 3)
            _s4 := array.get(crypto_lp_rows, _base + 4)
            _s5 := array.get(crypto_lp_rows, _base + 5)
            _s6 := array.get(crypto_lp_rows, _base + 6)
            _s7 := array.get(crypto_lp_rows, _base + 7)
            _s8 := array.get(crypto_lp_rows, _base + 8)
            _p1 := array.get(crypto_lp_rows, _base + 9)
            _p2 := array.get(crypto_lp_rows, _base + 10)
            _p3 := array.get(crypto_lp_rows, _base + 11)
            _p4 := array.get(crypto_lp_rows, _base + 12)
            _valid := true
            break
    if not _valid
        _s1 := str.replace(_s1_EX_template,'_',_corekey)
        _s2 := str.replace(_s2_EX_template,'_',_corekey)
        _s3 := str.replace(_s3_EX_template,'_',_corekey)
        _s4 := str.replace(_s4_EX_template,'_',_corekey)
        _s5 := str.replace(_s5_EX_template,'_',_corekey)
        _s6 := str.replace(_s6_EX_template,'_',_corekey)
        _s7 := str.replace(_s7_EX_template,'_',_corekey)
        _s8 := str.replace(_s8_EX_template,'_',_corekey)
        _p1 := str.replace(_p1_EX_template,'_',_corekey)
        _p2 := str.replace(_p2_EX_template,'_',_corekey)
        _p3 := str.replace(_p3_EX_template,'_',_corekey)
        _p4 := str.replace(_p4_EX_template,'_',_corekey)
    [_s1, _s2, _s3, _s4, _s5, _s6, _s7, _s8, _p1, _p2, _p3, _p4]

f_uv_vol_scaledown_for_GF(_corekey) =>
    _scaledown = 1.0
    _row_count = int(array.size(uv_vol_scaledown_rows) / UV_VOL_SCALEDOWN_ROW_SIZE_VAL)
    for _row = 0 to _row_count - 1
        _base = _row * UV_VOL_SCALEDOWN_ROW_SIZE_VAL
        if array.get(uv_vol_scaledown_rows, _base) == _corekey
            string _scaledown_raw = array.get(uv_vol_scaledown_rows, _base + 1)
            _scaledown_num = str.tonumber(_scaledown_raw)
            _scaledown := na(_scaledown_num) ? 1 : _scaledown_num
            break
    _scaledown
 
f_src_uv_leveling(_vol_src, _vol_mrktmean) =>
    float _vol_meanX_ratio = _vol_src / _vol_mrktmean
    int _level_state = switch 
        _vol_src         == 0                                 => -3 // zero 
        _vol_meanX_ratio <= ULTRAVOL_LEVEL_RATIO_MEANLESS_VAL => -2 // sub 
        _vol_meanX_ratio <= ULTRAVOL_LEVEL_RATIO_LOW_VAL      => -1 // low
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_A_VAL        =>  0 // reg
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_B_VAL        =>  1 
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_C_VAL        =>  2   
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_D_VAL        =>  3   
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_E_VAL        =>  4   
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_F_VAL        =>  5   
        _vol_meanX_ratio <  ULTRAVOL_LEVEL_RATIO_G_VAL        =>  6    
        => 7
    _level_state

f_src_uv_lv_coloring(_level_state) =>
    color _spectrum_color = switch _level_state 
        -3 => COLOR_BLACK
        -2 => uv_spectrum_sub_color     
        -1 => uv_spectrum_low_color
        0 => uv_spectrum_reg_color    
        1  => uv_spectrum_1_color
        2  => uv_spectrum_2_color
        3  => uv_spectrum_3_color
        4  => uv_spectrum_4_color
        5  => uv_spectrum_5_color 
        6  => uv_spectrum_6_color
        7  => uv_spectrum_7_color
        => na 
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🟦🟦🟦🟦 fn() - UV engine 
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-






//🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩
// Ultravol 
//
var int UV_SPOTPERP_RATIO_VAL       = 7  
const float V_BINANCE_SP_VAL        = 0.7
const float V_COINBASE_SP_VAL       = 1.5
const float V_OKX_SP_VAL            = 0.8
const float V_KRAKEN_SP_VAL         = 4.0
//-----------------------------------------------------------------------
const int BINANCEBTC_0FEE_START_VAL = timestamp('08 JULY 2022 00:00:00 UTC+9') // Binance BTC spot free : 2022-07-08 ~  
const int BINANCEBTC_0FEE_END_VAL   = timestamp('24 MAR 2023 00:00:00 UTC+9')  // Binance BTC spot free : ~ 2023-03-24  
const int OKX_ETHSPOT_X_START_VAL   = timestamp('04 NOV 2023 00:00:00 UTC+9')  // ETHUSDT error (OKX Data works) 2023-11-4 0h~ 
const int OKX_ETHSPOT_X_END_VAL     = timestamp('20 NOV 2023 01:00:00 UTC+9')  // ETHUSDT error (OKX Data works) ~2023-11-20 01h
// const int BITGET_PERP_START_VAL     = timestamp('07 SEP 2021 19:00:00 UTC+9')  // BITGET perp base unit volume statrt (before, USD unit)
//────────────────────────────────────────────────────────────────────────────────────────────-
// volmode 
const int UV_VOLMODE_ULTRAVOL_CANDIDATE_VAL = 0  
const int UV_VOLMODE_NOVOL_VAL              = 1  
const int UV_VOLMODE_CHARTVOL_VAL           = 2  
const int UV_VOLMODE_ULTRAVOL_VAL           = 3  
varip int uv_volmode_state                  = na 
varip bool uv_volmode_ultravol_candidate_task_flg = false     
varip bool uv_volmode_ultravol_task_flg           = false     
varip bool uv_volmode_ultravol_update_task_flg    = false     
varip bool uv_volmode_chartvol_task_flg           = false
varip bool uv_volmode_novol_task_flg              = false
const string UV_VOLMODENAME_ULTRAVOL_VAL    = 'Ultravol'  
const string UV_VOLMODENAME_CHARTVOL_VAL    = 'Chart Vol' 
const string UV_VOLMODENAME_FORCE_VAL       = '! Chrt Vol'
const string UV_VOLMODENAME_NOVOL_VAL       = '  No Vol  '
varip string uv_volmode_name_remark         = ''          
//────────────────────────────────────────────────────────────────────────────────────────────-
var uv_s1_is_binance_btc                    = false
var uv_s5_is_okx_eth                        = false
//────────────────────────────────────────────────────────────────────────────────────────────-
// Symbol Lookup
var uv_sym_s1 = "",  var uv_sym_s1_valid = false
var uv_sym_s2 = "",  var uv_sym_s2_valid = false
var uv_sym_s3 = "",  var uv_sym_s3_valid = false
var uv_sym_s4 = "",  var uv_sym_s4_valid = false
var uv_sym_s5 = "",  var uv_sym_s5_valid = false
var uv_sym_s6 = "",  var uv_sym_s6_valid = false
var uv_sym_s7 = "",  var uv_sym_s7_valid = false
var uv_sym_s8 = "",  var uv_sym_s8_valid = false
var uv_sym_p1 = "",  var uv_sym_p1_valid = false
var uv_sym_p2 = "",  var uv_sym_p2_valid = false
var uv_sym_p3 = "",  var uv_sym_p3_valid = false
var uv_sym_p4 = "",  var uv_sym_p4_valid = false
var float multiple_s1 = 1
var float multiple_s2 = 1
var float multiple_p1 = 1
var float multiple_p2 = 1
var float multiple_p3 = 1
var float uv_vol_scaledown_for_GF = 1
//────────────────────────────────────────────────────────────────────────────────────────────-
varip float uv_chartvol_accum               = 0.0   
varip float uv_chartvol_mrktmean            = 0.0   
varip float uv_vol_UV_spot                  = 0.0 
varip float uv_vol_UV_perp                  = 0.0 
varip float uv_vol_UV_mixed                 = 0.0 
varip float uv_vol_raw                      = 0.0 
varip float uv_vol                          = 0.0   
varip float uv_vol_smoothed                 = 0.0   
varip float uv_vol_accum                    = 0.0   
varip float uv_vol_mrktmean                 = 0.0   
//────────────────────────────────────────────────────- 
varip float uv_vol_synth_spot_accum         = 0.0 
varip float uv_vol_synth_perp_accum         = 0.0 
varip float uv_vol_synth_spot_mrktmean      = 0.0 
varip float uv_vol_synth_perp_mrktmean      = 0.0 
varip float uv_vol_synth_spot_stdev_denom   = 0.0 
varip float uv_vol_synth_perp_stdev_denom   = 0.0 
varip float uv_vol_stdev_denom              = 0.0 
varip float uv_vol_synth_spot_smoothed      = 0.0 
varip float uv_vol_synth_perp_smoothed      = 0.0 
//────────────────────────────────────────────────────-
varip cryptoVol v_s1 = cryptoVol.new(0.0, false)
varip cryptoVol v_s2 = cryptoVol.new(0.0, false)
varip cryptoVol v_s3 = cryptoVol.new(0.0, false)
varip cryptoVol v_s4 = cryptoVol.new(0.0, false)
varip cryptoVol v_s5 = cryptoVol.new(0.0, false)
varip cryptoVol v_s6 = cryptoVol.new(0.0, false)
varip cryptoVol v_s7 = cryptoVol.new(0.0, false)
varip cryptoVol v_s8 = cryptoVol.new(0.0, false)
varip cryptoVol v_p1 = cryptoVol.new(0.0, false)
varip cryptoVol v_p2 = cryptoVol.new(0.0, false)
varip cryptoVol v_p3 = cryptoVol.new(0.0, false)
varip cryptoVol v_p4 = cryptoVol.new(0.0, false)
varip bool v_s1_works = false
varip bool v_s2_works = false
varip bool v_s3_works = false
varip bool v_s4_works = false
varip bool v_s5_works = false
varip bool v_s6_works = false
varip bool v_s7_works = false
varip bool v_s8_works = false
varip bool v_p1_works = false
varip bool v_p2_works = false
varip bool v_p3_works = false
varip bool v_p4_works = false
varip int v_s1_begin = na      
varip int v_s2_begin = na      
varip int v_s3_begin = na      
varip int v_s4_begin = na      
varip int v_s5_begin = na      
varip int v_s6_begin = na      
varip int v_s7_begin = na      
varip int v_s8_begin = na      
varip int v_p1_begin = na      
varip int v_p2_begin = na      
varip int v_p3_begin = na      
varip int v_p4_begin = na      
varip float v_s1_accum = 0.0   
varip float v_s2_accum = 0.0   
varip float v_s3_accum = 0.0   
varip float v_s4_accum = 0.0   
varip float v_s5_accum = 0.0   
varip float v_s6_accum = 0.0   
varip float v_s7_accum = 0.0   
varip float v_s8_accum = 0.0   
varip float v_p1_accum = 0.0   
varip float v_p2_accum = 0.0   
varip float v_p3_accum = 0.0   
varip float v_p4_accum = 0.0   
varip float v_s1_mrktmean = 0.0
varip float v_s2_mrktmean = 0.0
varip float v_s3_mrktmean = 0.0
varip float v_s4_mrktmean = 0.0
varip float v_s5_mrktmean = 0.0
varip float v_s6_mrktmean = 0.0
varip float v_s7_mrktmean = 0.0
varip float v_s8_mrktmean = 0.0
varip float v_p1_mrktmean = 0.0
varip float v_p2_mrktmean = 0.0
varip float v_p3_mrktmean = 0.0
varip float v_p4_mrktmean = 0.0


//🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
// INIT LOGIC
//🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥
if barstate.isfirst
    uv_vol_scaledown_for_GF := f_uv_vol_scaledown_for_GF(uv_chart_crypto_tickerhead_str)
    // 🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧
    if uv_chart_symbol_crypto_basequotetickvol_flg and not ultravol_force_chartvol_flg   
        [_T_s1, _T_s2, _T_s3, _T_s4, _T_s5, _T_s6, _T_s7, _T_s8, _T_p1, _T_p2, _T_p3, _T_p4] = f_crypto_table_row_info(uv_chart_crypto_tickerhead_str)
        multiple_s1 := f_crypto_symbol_multiple(_T_s1, uv_chart_crypto_tickerhead_str)
        multiple_s2 := f_crypto_symbol_multiple(_T_s2, uv_chart_crypto_tickerhead_str)
        multiple_p1 := f_crypto_symbol_multiple(_T_p1, uv_chart_crypto_tickerhead_str)
        multiple_p2 := f_crypto_symbol_multiple(_T_p2, uv_chart_crypto_tickerhead_str)
        multiple_p3 := f_crypto_symbol_multiple(_T_p3, uv_chart_crypto_tickerhead_str)
        uv_sym_s1 := _T_s1,           uv_sym_s1_valid := _T_s1 !=''         
        uv_sym_s2 := _T_s2,           uv_sym_s2_valid := _T_s2 !=''         
        uv_sym_s3 := _T_s3,           uv_sym_s3_valid := _T_s3 !=''         
        uv_sym_s4 := _T_s4,           uv_sym_s4_valid := _T_s4 !=''         
        uv_sym_s5 := _T_s5,           uv_sym_s5_valid := _T_s5 !=''         
        uv_sym_s6 := _T_s6,           uv_sym_s6_valid := _T_s6 !=''         
        uv_sym_s7 := _T_s7,           uv_sym_s7_valid := _T_s7 !=''         
        uv_sym_s8 := _T_s8,           uv_sym_s8_valid := _T_s8 !=''         
        uv_sym_p1 := _T_p1,           uv_sym_p1_valid := _T_p1 !=''         
        uv_sym_p2 := _T_p2,           uv_sym_p2_valid := _T_p2 !=''         
        uv_sym_p3 := _T_p3,           uv_sym_p3_valid := _T_p3 !=''         
        uv_sym_p4 := _T_p4,           uv_sym_p4_valid := _T_p4 !=''         
        uv_s1_is_binance_btc := str.upper(uv_sym_s1) == 'BINANCE:BTCUSDT'
        uv_s5_is_okx_eth     := str.upper(uv_sym_s5) == 'OKX:ETHUSDT'
    // 🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧
    //  Volmode No. Flag Settings 
    if ultravol_force_chartvol_flg                                  // force chart-vol
        if uv_chart_vol_unavailable_flg
            uv_volmode_state    := UV_VOLMODE_NOVOL_VAL             // 1 fixed
        else
            uv_volmode_state    := UV_VOLMODE_CHARTVOL_VAL          // 2 fixed
    //-------------------------------------------------------------------------------------
    else if uv_chart_symbol_crypto_basequotetickvol_flg             // ultravol candidate, keep trying
        uv_volmode_state        := UV_VOLMODE_ULTRAVOL_CANDIDATE_VAL// 0 unfixed
    else if not uv_chart_vol_unavailable_flg
        uv_volmode_state        := UV_VOLMODE_CHARTVOL_VAL          // 2 fixed
    else
        uv_volmode_state        := UV_VOLMODE_NOVOL_VAL             // 1 fixed
    //-------------------------------------------------------------------------------------
    uv_volmode_novol_task_flg              := uv_volmode_state == UV_VOLMODE_NOVOL_VAL
    uv_volmode_ultravol_candidate_task_flg := uv_volmode_state == UV_VOLMODE_ULTRAVOL_CANDIDATE_VAL 
    uv_volmode_chartvol_task_flg           := uv_volmode_state == UV_VOLMODE_CHARTVOL_VAL           
                                              or uv_volmode_ultravol_candidate_task_flg             
    uv_volmode_ultravol_task_flg           := false
    uv_volmode_ultravol_update_task_flg := uv_volmode_ultravol_task_flg or uv_volmode_ultravol_candidate_task_flg 
    uv_volmode_name_remark          := uv_volmode_novol_task_flg ? UV_VOLMODENAME_NOVOL_VAL 
                                     : ultravol_force_chartvol_flg ? UV_VOLMODENAME_FORCE_VAL 
                                     : UV_VOLMODENAME_CHARTVOL_VAL
//🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥🟥

//────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────--
// Synthetic source volume request throttle  : Security Call
//────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────--
const int ULTRAVOL_ENERGYFLUX_LENGTH_VAL     = 1111
const int ULTRAVOL_ENERGYFLUX_LENGTH_ALT_VAL =  200
if barstate.isnew 
    // 🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧
    if uv_volmode_ultravol_update_task_flg and uv_volmode_chartvol_task_flg
        uv_chartvol_accum    += nz(uv_chartvol)                           
        uv_chartvol_mrktmean := (uv_chartvol_accum/math.max(1,bar_index)) //* ultravol_rescale_ratio 
    if uv_volmode_ultravol_task_flg                           
        v_s1_accum += nz(v_s1.vol)                                       
        v_s2_accum += nz(v_s2.vol)                                       
        v_s3_accum += nz(v_s3.vol)                                       
        v_s4_accum += nz(v_s4.vol)                                       
        v_s5_accum += nz(v_s5.vol)                                       
        v_s6_accum += nz(v_s6.vol)                                       
        v_s7_accum += nz(v_s7.vol)                                       
        v_s8_accum += nz(v_s8.vol)                                       
        v_p1_accum += nz(v_p1.vol)                                       
        v_p2_accum += nz(v_p2.vol)                                       
        v_p3_accum += nz(v_p3.vol)                                       
        v_p4_accum += nz(v_p4.vol)                                       
        v_s1_mrktmean := (v_s1_accum/math.max(1,bar_index - v_s1_begin)) // * ultravol_rescale_ratio 
        v_s2_mrktmean := (v_s2_accum/math.max(1,bar_index - v_s2_begin)) // * ultravol_rescale_ratio 
        v_s3_mrktmean := (v_s3_accum/math.max(1,bar_index - v_s3_begin)) // * ultravol_rescale_ratio 
        v_s4_mrktmean := (v_s4_accum/math.max(1,bar_index - v_s4_begin)) // * ultravol_rescale_ratio 
        v_s5_mrktmean := (v_s5_accum/math.max(1,bar_index - v_s5_begin)) // * ultravol_rescale_ratio 
        v_s6_mrktmean := (v_s6_accum/math.max(1,bar_index - v_s6_begin)) // * ultravol_rescale_ratio 
        v_s7_mrktmean := (v_s7_accum/math.max(1,bar_index - v_s7_begin)) // * ultravol_rescale_ratio 
        v_s8_mrktmean := (v_s8_accum/math.max(1,bar_index - v_s8_begin)) // * ultravol_rescale_ratio 
        v_p1_mrktmean := (v_p1_accum/math.max(1,bar_index - v_p1_begin)) // * ultravol_rescale_ratio 
        v_p2_mrktmean := (v_p2_accum/math.max(1,bar_index - v_p2_begin)) // * ultravol_rescale_ratio 
        v_p3_mrktmean := (v_p3_accum/math.max(1,bar_index - v_p3_begin)) // * ultravol_rescale_ratio 
        v_p4_mrktmean := (v_p4_accum/math.max(1,bar_index - v_p4_begin)) // * ultravol_rescale_ratio 

        //------------------------------------------------------------------------------------------------------                        
        // UV Energy Flux - marketmean                                                                                                  
        //------------------------------------------------------------------------------------------------------                        
        uv_vol_synth_spot_accum += nz(uv_vol_UV_spot)                                                                                   
        uv_vol_synth_perp_accum += nz(uv_vol_UV_perp)                                                                                   
        uv_vol_synth_spot_mrktmean := (uv_vol_synth_spot_accum / math.max(1, bar_index)) * ultravol_rescale_ratio                       
        uv_vol_synth_perp_mrktmean := (uv_vol_synth_perp_accum / math.max(1, bar_index)) * ultravol_rescale_ratio                       
        uv_vol_synth_spot_stdev_denom := ta.rma(ta.stdev(uv_vol_synth_spot_smoothed, ULTRAVOL_ENERGYFLUX_LENGTH_VAL, true), 4)          
        uv_vol_synth_perp_stdev_denom := ta.rma(ta.stdev(uv_vol_synth_perp_smoothed, ULTRAVOL_ENERGYFLUX_LENGTH_VAL, true), 4)          
        if bar_index < ULTRAVOL_ENERGYFLUX_LENGTH_VAL                                                                                   
            uv_vol_synth_spot_stdev_denom := ta.rma(ta.stdev(uv_vol_synth_spot_smoothed, ULTRAVOL_ENERGYFLUX_LENGTH_ALT_VAL, true), 4)  
            uv_vol_synth_perp_stdev_denom := ta.rma(ta.stdev(uv_vol_synth_perp_smoothed, ULTRAVOL_ENERGYFLUX_LENGTH_ALT_VAL, true), 4)  
        uv_vol_synth_spot_smoothed := 0.0                                                                                               
        uv_vol_synth_perp_smoothed := 0.0                                                                                               
    //                                                                                                                                  
    else if uv_volmode_chartvol_task_flg                                                                                                
        uv_vol_stdev_denom := ta.rma(ta.stdev(uv_vol_smoothed, ULTRAVOL_ENERGYFLUX_LENGTH_VAL, true), 4)                                
        if bar_index < ULTRAVOL_ENERGYFLUX_LENGTH_VAL                                                                                   
            uv_vol_stdev_denom := ta.rma(ta.stdev(uv_vol_smoothed, ULTRAVOL_ENERGYFLUX_LENGTH_ALT_VAL, true), 4)                        
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────                      


    // 🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧🟧
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // UV Engine Core
    //────────────────────────────────────────
    uv_vol_accum            += nz(uv_vol)   
    uv_vol_mrktmean         := (uv_vol_accum / math.max(1, bar_index)) * ultravol_rescale_ratio
    if bar_index < ULTRAVOL_ENERGYFLUX_LENGTH_VAL * 2    
        uv_vol_mrktmean     := ta.sma(uv_vol_mrktmean, math.max(1, bar_index))                                                               
    //────────────────────────────────────────
    uv_vol := 0.0,  uv_vol_raw := 0.0,  uv_vol_smoothed := 0.0
    uv_vol_UV_mixed:= 0.0,  uv_vol_UV_spot := 0.0,  uv_vol_UV_perp := 0.0
    v_s1.vol := 0.0, v_s2.vol := 0.0, v_s3.vol := 0.0, v_s4.vol := 0.0, v_s5.vol := 0.0, v_s6.vol := 0.0, v_s7.vol := 0.0, v_s8.vol := 0.0
    v_p1.vol := 0.0, v_p2.vol := 0.0, v_p3.vol := 0.0, v_p4.vol := 0.0
    if uv_volmode_chartvol_task_flg  
        uv_vol_raw := uv_chartvol
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────


//
// Data Fetch
//
//🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦
//   MasterUPDATE gate  -  Throttling
//🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦
if uv_MasterGATEopen_flg 
    if uv_volmode_ultravol_update_task_flg   
        // data fetch
        if uv_sym_s1_valid  
            v_s1 := f_crypto_vol(uv_sym_s1, multiple_s1)  // 1 Binance USDT
            if uv_s1_is_binance_btc and (BINANCEBTC_0FEE_START_VAL <= time and time <= BINANCEBTC_0FEE_END_VAL)
                v_s1.vol := v_s1.vol * 0.3
        if uv_sym_s2_valid  
            v_s2 := f_crypto_vol(uv_sym_s2, multiple_s2)  // 2 Binance USDC 
        if uv_sym_s3_valid  
            v_s3 := f_crypto_vol(uv_sym_s3, 1)            // 3 Coinbase
        if uv_sym_s4_valid  
            v_s4 := f_crypto_vol(uv_sym_s4, 1)            // 4 Bybit
        if uv_sym_s5_valid  
            v_s5 := f_crypto_vol(uv_sym_s5, 1)            // 5 OKX
            if uv_s5_is_okx_eth and (OKX_ETHSPOT_X_START_VAL <= time and time <= OKX_ETHSPOT_X_END_VAL)
                v_s5.vol := v_s5.vol * 0.00005
        if uv_sym_s6_valid  
            v_s6 := f_crypto_vol(uv_sym_s6, 1)            // 6 Upbit 
        if uv_sym_s7_valid  
            v_s7 := f_crypto_vol(uv_sym_s7, 1)            // 7 Kraken
        if uv_sym_s8_valid  
            v_s8 := f_crypto_vol(uv_sym_s8, 1)            // 8 Bitget
        if uv_sym_p1_valid  
            v_p1 := f_crypto_vol(uv_sym_p1, multiple_p1)  // 1 Binance.P
        if uv_sym_p2_valid  
            v_p2 := f_crypto_vol(uv_sym_p2, multiple_p2)  // 2 Coinbase.P
        if uv_sym_p3_valid  
            v_p3 := f_crypto_vol(uv_sym_p3, multiple_p3)  // 3 Bybit.P
        if uv_sym_p4_valid
            v_p4 := f_crypto_vol(uv_sym_p4, 1)            // 4 OKX.P
         
        // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
        // SUMMING =>  spot, perp, final(mixed) 
        //--------------------------------------------------------------------------------------------------------------
        // 🟢 SPOT SUMING 🟢
        //----------------------
        if (v_s1_works or v_s2_works or v_s3_works or v_s4_works or v_s5_works or v_s6_works or v_s7_works or v_s8_works)
            uv_vol_UV_spot  := ((v_s1.vol * V_BINANCE_SP_VAL) + v_s2.vol + (v_s3.vol * V_COINBASE_SP_VAL) + v_s4.vol 
                  + (v_s5.vol * V_OKX_SP_VAL) + v_s6.vol + (v_s7.vol * V_KRAKEN_SP_VAL) + v_s8.vol ) / uv_vol_scaledown_for_GF
        else
            uv_vol_UV_spot  := float(na)
        //----------------------------------------------------------
        // 🟢 PERP SUMING 🟢
        //----------------------
        if (v_p1_works or v_p2_works or v_p3_works or v_p4_works)
            uv_vol_UV_perp  := (((v_p1.vol * V_BINANCE_SP_VAL) + v_p2.vol + v_p3.vol 
                             +   (v_p4.vol * V_OKX_SP_VAL)) / uv_vol_scaledown_for_GF)     / UV_SPOTPERP_RATIO_VAL
        else
            uv_vol_UV_perp  := float(na)
        //----------------------------------------------------------
        // 🟢 TOTAL SUMMING 🟢
        //----------------------
        if na(uv_vol_UV_perp) and na(uv_vol_UV_spot)
            uv_vol_UV_mixed := float(na)    
        else 
            uv_vol_UV_mixed := nz(uv_vol_UV_spot) + nz(uv_vol_UV_perp)
        // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
        if not v_s1_works and v_s1.valid
            v_s1_works := true          
            v_s1_begin := bar_index     
        if not v_s2_works and v_s2.valid
            v_s2_works := true
            v_s2_begin := bar_index     
        if not v_s3_works and v_s3.valid
            v_s3_works := true
            v_s3_begin := bar_index     
        if not v_s4_works and v_s4.valid
            v_s4_works := true
            v_s4_begin := bar_index     
        if not v_s5_works and v_s5.valid
            v_s5_works := true
            v_s5_begin := bar_index     
        if not v_s6_works and v_s6.valid
            v_s6_works := true
            v_s6_begin := bar_index     
        if not v_s7_works and v_s7.valid
            v_s7_works := true
            v_s7_begin := bar_index     
        if not v_s8_works and v_s8.valid
            v_s8_works := true
            v_s8_begin := bar_index     
        if not v_p1_works and v_p1.valid
            v_p1_works := true
            v_p1_begin := bar_index     
        if not v_p2_works and v_p2.valid
            v_p2_works := true
            v_p2_begin := bar_index     
        if not v_p3_works and v_p3.valid
            v_p3_works := true
            v_p3_begin := bar_index     
        if not v_p4_works and v_p4.valid
            v_p4_works := true
            v_p4_begin := bar_index     
        // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────
        if uv_volmode_ultravol_candidate_task_flg  
            if   v_s1_works or v_s2_works or v_s3_works or v_s4_works or v_s5_works or v_s6_works or v_s7_works or v_s8_works 
              or v_p1_works or v_p2_works or v_p3_works or v_p4_works
                uv_volmode_state                        := UV_VOLMODE_ULTRAVOL_VAL
                uv_volmode_ultravol_candidate_task_flg  := false    
                uv_volmode_ultravol_update_task_flg     := true     
                uv_volmode_ultravol_task_flg            := true     
                uv_volmode_chartvol_task_flg            := false    
                uv_volmode_novol_task_flg               := false    
                uv_volmode_name_remark                  := UV_VOLMODENAME_ULTRAVOL_VAL
    else
        uv_vol_UV_mixed     := float(na)

    //────────────────────────────────────────────────────────────────────────────────────────────────────────
    if uv_volmode_ultravol_task_flg                                             
        uv_vol_raw :=  uv_vol_UV_mixed * uv_vol_scaledown_for_GF                
        uv_vol     :=  uv_vol_UV_mixed                                          
        uv_vol_synth_spot_smoothed := f_smooth(uv_vol_UV_spot)           
        uv_vol_synth_perp_smoothed := f_smooth(uv_vol_UV_perp)           

    //────────────────────────────────────────────────────────────────────────────────────────────────────────
    if uv_volmode_chartvol_task_flg                                             
        uv_vol_raw :=  uv_chartvol
        uv_vol     :=  uv_chartvol / uv_vol_scaledown_for_GF                    
        if str.endswith(uv_chart_tikerid_str, '.P')
            uv_vol_UV_perp := uv_vol
        else
            uv_vol_UV_spot := uv_vol
    
    //
    uv_vol_smoothed     := f_smooth(uv_vol)       

//🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦
//   MasterUPDATE gate  -  Throttling - End
//🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦🟧🟦

bool uv_src_updated_now_flg = bar_index == v_s1_begin or bar_index == v_s2_begin or bar_index == v_s3_begin or bar_index == v_s4_begin 
      or bar_index == v_s5_begin or bar_index == v_s6_begin or bar_index == v_s7_begin or bar_index == v_s8_begin 
      or bar_index == v_p1_begin or bar_index == v_p2_begin or bar_index == v_p3_begin or bar_index == v_p4_begin 

var bool chart_not_included_in_pool_flg  = switch 
    uv_chart_tikerid_str == str.upper(uv_sym_s1) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s2) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s3) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s4) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s5) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s6) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s7) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_s8) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_p1) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_p2) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_p3) => false 
    uv_chart_tikerid_str == str.upper(uv_sym_p4) => false 
    syminfo.prefix == 'COINBASE' and str.endswith(uv_chart_tikerid_str,'USDC') and v_s3_works => false
    => true  

series bool chartvol_indi_in_panel_flg = (uv_volmode_ultravol_update_task_flg and chart_not_included_in_pool_flg)
                                      or (not chart_not_included_in_pool_flg and uv_volmode_ultravol_candidate_task_flg)
var int uv_works_spot_count = 0
var int uv_works_perp_count = 0
var int uv_works_total_count = 0
if barstate.isfirst or uv_src_updated_now_flg  
    uv_works_spot_count  := (v_s1_works?1:0)+(v_s2_works?1:0)+(v_s3_works?1:0)+(v_s4_works?1:0)+(v_s5_works?1:0)+(v_s6_works?1:0)+(v_s7_works?1:0)+(v_s8_works?1:0)
    uv_works_perp_count  := (v_p1_works?1:0)+(v_p2_works?1:0)+(v_p3_works?1:0)+(v_p4_works?1:0)
    uv_works_total_count := uv_works_spot_count + uv_works_perp_count

//
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
//
//   Ultravol Core Engine - End
//
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
// ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜

 




//⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜
//⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜
// G-Index PX  
//
varip bool  g_index_px_works           = false      
varip float g_index_px                 = na         
var float chart_current_multiple = not uv_chart_symbol_crypto_basequotetickvol_flg ? 
                  1.0 : f_crypto_symbol_multiple(uv_chart_tikerid_str, uv_chart_crypto_tickerhead_str)
var string chart_current_currency = syminfo.currency
float USD2USDT_avg_rate = request.security("CRYPTO:USDTUSD", timeframe.period, ta.sma(hlc3, 3)) 
float USD2USDC_avg_rate = request.security("CRYPTO:USDCUSD", timeframe.period, ta.sma(hlc3, 3)) 
bool USDT_is_DEPEG      = math.abs(USD2USDT_avg_rate - 1.0) * 100 >= 0.1 
bool USDC_is_DEPEG      = math.abs(USD2USDC_avg_rate - 1.0) * 100 >= 0.2 
var int chart_currency_convert_mode = switch chart_current_currency
    'USD'   => 1
    'USDT'  => 2
    'USDC'  => 3
    => 0
float g_avg_chart_ratio = switch chart_currency_convert_mode
    1  => 1.0 
    2  => (1.0 / USD2USDT_avg_rate)
    3  => (1.0 / USD2USDC_avg_rate)
    0  => 0.0
var bool chart_currency_convert_no_need =  (uv_chart_crypto_tickerhead_str == 'USDT') 
                                       or  (uv_chart_crypto_tickerhead_str == 'USDC')
                                       or  (uv_chart_crypto_tickerhead_str == 'USDS')
                                       or  (uv_chart_crypto_tickerhead_str == 'PYUSD')
                                       or  (uv_chart_crypto_tickerhead_str == 'USDP')
var string g_index_px_crypto_ticker = 'CRYPTO:' + f_crypto_cryptocap_tv_ticker(uv_chart_crypto_tickerhead_str) + 'USD'
if chart_currency_convert_mode != 0 
    g_index_px  := (request.security(g_index_px_crypto_ticker,timeframe.period, close * g_avg_chart_ratio,gaps=barmerge.gaps_on, ignore_invalid_symbol=true) * chart_current_multiple )
if not g_index_px_works and not na(g_index_px) and uv_volmode_ultravol_task_flg and not chart_currency_convert_no_need
    g_index_px_works := true
if g_index_px_works and na(g_index_px) and na(g_index_px[1])
    g_index_px_works := false

//G-Index - end
//⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜
//⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜🟥⬜
















//🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪
//  DISPLAY
//🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪





//🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 
float uv_candle_direction   = math.sign(uv_chart_px - uv_chart_open) 
varip color uv_ghost_candle_color = COLOR_TRANSP        
if barstate.islast 
    if not barstate.isconfirmed
        uv_ghost_candle_color := switch uv_candle_direction     
            +1 => uv_direction_up_color
            -1 => uv_direction_dn_color
            => uv_direction_00_color
    else 
        uv_ghost_candle_color := COLOR_TRANSP
    //------------------------------------------------------------------------------------        
barcolor(uv_ghost_candle_color,      title="Ultravol Candles" ,editable=false
          ,display=ultravol_candles_flg?display.all:display.none)  
//🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 🟪 




//  Ultravol Level 
//-----------------------------------------------------------------------------
// level no.flag: -2 sub, -1 low, 0 reg, 1~7 level
int  uv_level_state         = f_src_uv_leveling(uv_vol, uv_vol_mrktmean) 
bool uv_level_state_sub_flg = uv_level_state == -2

//🟪🟪🟪🟪🟪🟪🟪
//🟪 A  Ultravol Candle (override-fusion)
//🟪🟪🟪🟪🟪🟪🟪
 
const color COLOR_BLACK_WICK = color.new(COLOR_BLACK,50) 
color uv_candle_color = na
if not uv_volmode_novol_task_flg
    uv_candle_color := switch uv_level_state
        -2  => uv_candle_direction >= 0 ? uv_candle_up_sub_color : uv_candle_dn_sub_color      
        -1  => uv_candle_direction >= 0 ? uv_candle_up_low_color : uv_candle_dn_low_color      
        0   => uv_candle_direction >= 0 ? uv_candle_up_reg_color : uv_candle_dn_reg_color
        1   => uv_candle_direction >= 0 ? uv_candle_up1_color    : uv_candle_dn1_color      
        2   => uv_candle_direction >= 0 ? uv_candle_up2_color    : uv_candle_dn2_color      
        3   => uv_candle_direction >= 0 ? uv_candle_up3_color    : uv_candle_dn3_color      
        4   => uv_candle_direction >= 0 ? uv_candle_up4_color    : uv_candle_dn4_color      
        5   => uv_candle_direction >= 0 ? uv_candle_up5_color    : uv_candle_dn5_color      
        6   => uv_candle_direction >= 0 ? uv_candle_up6_color    : uv_candle_dn6_color      
        7   => uv_candle_direction >= 0 ? uv_candle_up7_color    : uv_candle_dn7_color      
        =>  na
else if uv_volmode_novol_task_flg
    uv_candle_color := uv_candle_direction >= 0 ? uv_NoVolData_up_color : uv_NoVolData_dn_color

// color == na ==> plot na
plotcandle(uv_chart_open,uv_chart_high,uv_chart_low,uv_chart_px,      title='UV Fusion Candle'
     ,color=uv_candle_color, wickcolor=uv_candle_color, bordercolor=uv_candle_color, force_overlay=true, editable=false
     ,display=ultravol_candles_flg?display.pane:display.none ,format=format.price)


//🟪🟪🟪🟪🟪🟪🟪
//🟪 A'   Ultravol G-Index px line
//🟪🟪🟪🟪🟪🟪🟪
 
plot(g_index_px_works ? g_index_px:na ,'UV G-Index Price', color=ultravol_g_index_color
          ,linestyle =plot.linestyle_dotted, style=plot.style_steplinebr
          ,force_overlay = true, trackprice=true, format=format.price
          ,display=ultravol_g_index_flg? display.all:display.data_window)


//🟪🟪🟪🟪🟪🟪🟪
//🟪 B  SPECTRUM = Vol Bar + guide + marketmean line + UV Energy flux
//🟪🟪🟪🟪🟪🟪🟪
// 
//────────────────────────────────────────────────────────────────────────────--
// init
const color UV_LEVEL_GUIDE_FILL_COLOR   = color.new(#1e201f,30) 
const color UV_LEVEL_GUIDE_MEAN_COLOR   = color.new(#ffffff,70)
const color UV_LEVEL_GUIDE_SHADOW_COLOR = color.new(#000000,40)

const float UV_VOL_ALT_PLUS_OFFSET_R    = 0.2     
const float UV_ENERGYFLUX_A_SLOT_H_GAP_R = 1      // slot gap
const float UV_ENERGYFLUX_A_SLOT_H_R     = 1.5    // 1 slot height
//
const float UV_ENERGYFLUX_SLOT1_HIGH_R   = (UV_ENERGYFLUX_A_SLOT_H_GAP_R*1) + (UV_ENERGYFLUX_A_SLOT_H_R*0)
const float UV_ENERGYFLUX_SLOT1_LOW_R    = (UV_ENERGYFLUX_A_SLOT_H_GAP_R*1) + (UV_ENERGYFLUX_A_SLOT_H_R*1)
const float UV_ENERGYFLUX_SLOT2_HIGH_R   = (UV_ENERGYFLUX_A_SLOT_H_GAP_R*2) + (UV_ENERGYFLUX_A_SLOT_H_R*1)
const float UV_ENERGYFLUX_SLOT2_LOW_R    = (UV_ENERGYFLUX_A_SLOT_H_GAP_R*2) + (UV_ENERGYFLUX_A_SLOT_H_R*2)
//
const float UV_SHADOW_HIGH_R            = ULTRAVOL_LEVEL_RATIO_C_VAL * 1.2   // SHADOW TOP position
const float UV_SHADOW_LOW_R_CHARTVOL    = UV_ENERGYFLUX_SLOT2_HIGH_R
const float UV_SHADOW_LOW_R_ULTRAVOL    = UV_ENERGYFLUX_SLOT2_LOW_R + UV_ENERGYFLUX_A_SLOT_H_GAP_R

//------------------------------------------
varip float uv_vol_plus_offset          = 0.0   // extreme low Vol -> marketmean ++offset 
varip float uv_shadow_h_value           = na    // Shadow
varip float uv_shadow_l_value           = na    // Shadow
varip float uv_guide_h_value            = na    // guide Stripe
varip float uv_guide_l_value            = na    // guide Stripe
varip float uv_guide_mm_line            = na    // guide Stripe
var color uv_spectrum_color             = na 
var uv_spectrum_GraphicVisualsOn_flg    = ultravol_spectrum_flg
//------------------------------------------------------------------------------------------------------
if not uv_volmode_novol_task_flg
    if barstate.isnew 
        uv_vol_plus_offset :=  uv_vol_mrktmean * UV_VOL_ALT_PLUS_OFFSET_R
        uv_guide_mm_line   :=  uv_vol_mrktmean + uv_vol_plus_offset
        uv_guide_h_value   := (uv_vol_mrktmean * ULTRAVOL_LEVEL_RATIO_C_VAL) + uv_vol_plus_offset
        uv_guide_l_value   := (uv_vol_mrktmean * ULTRAVOL_LEVEL_RATIO_B_VAL) + uv_vol_plus_offset
        uv_shadow_h_value  :=  uv_vol_mrktmean * UV_SHADOW_HIGH_R
        uv_shadow_l_value  := -uv_vol_mrktmean * (uv_volmode_chartvol_task_flg ? UV_SHADOW_LOW_R_CHARTVOL:UV_SHADOW_LOW_R_ULTRAVOL)
    
    uv_spectrum_color := f_src_uv_lv_coloring(uv_level_state)
   
//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪 Shadow
uv_shadow_h_plot = plot(uv_shadow_h_value,  'Level shadow high',display=display.none,   editable=false)
uv_shadow_l_plot = plot(uv_shadow_l_value,  'Level shadow low', display=display.none,   editable=false)
fill(uv_shadow_h_plot, uv_shadow_l_plot, color=UV_LEVEL_GUIDE_SHADOW_COLOR, title='UV Spectrum Shadow', editable = false
               ,display= uv_spectrum_GraphicVisualsOn_flg ? display.all:display.none)

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪 Level guide stripe
uv_LevelC_plot        = plot(uv_guide_h_value,   'Level Guide C',    display=display.none,   editable=false)
uv_LevelB_plot        = plot(uv_guide_l_value,   'Level Guide B',    display=display.none,   editable=false)
fill(uv_LevelC_plot,   uv_LevelB_plot,   color=UV_LEVEL_GUIDE_FILL_COLOR, title='UV Spectrum Guide',  editable = false
               ,display = uv_spectrum_GraphicVisualsOn_flg ? display.all:display.none)

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪 Ultravol bars  
plot(uv_vol + uv_vol_plus_offset ,title='UV Synthetic Volume' ,color=uv_spectrum_color ,linewidth=4  ,style=plot.style_histogram  
      ,editable=false ,display=uv_spectrum_GraphicVisualsOn_flg ? display.all:display.none, format=format.volume)

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪 Market mean line
plot(uv_guide_mm_line ,'Market Mean', color=UV_LEVEL_GUIDE_MEAN_COLOR, editable=false, linewidth=1
      ,display=uv_spectrum_GraphicVisualsOn_flg ? display.pane:display.none)

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪 UV Energy flux
varip float spot_ss_high = na
varip float spot_ss_low  = na
varip float perp_ss_high = na
varip float perp_ss_low  = na
varip color spot_bcolor  = na  
varip color perp_bcolor  = na
//-------------------------------------------------------------
f_uv_energyflux_levelcolor(_stdev_ratio ,_is_spot) =>          
    _result = switch
        na(_stdev_ratio) => na
        _stdev_ratio < UV_SS_LEVEL_R_0 => na
        _stdev_ratio < UV_SS_LEVEL_R_1 => _is_spot? UV_SPOT_SS_COLOR_0 : UV_PERP_SS_COLOR_0  
        _stdev_ratio < UV_SS_LEVEL_R_2 => _is_spot? UV_SPOT_SS_COLOR_1 : UV_PERP_SS_COLOR_1  
        _stdev_ratio < UV_SS_LEVEL_R_3 => _is_spot? UV_SPOT_SS_COLOR_2 : UV_PERP_SS_COLOR_2  
        _stdev_ratio < UV_SS_LEVEL_R_4 => _is_spot? UV_SPOT_SS_COLOR_3 : UV_PERP_SS_COLOR_3  
        _stdev_ratio < UV_SS_LEVEL_R_5 => _is_spot? UV_SPOT_SS_COLOR_4 : UV_PERP_SS_COLOR_4  
        _stdev_ratio < UV_SS_LEVEL_R_6 => _is_spot? UV_SPOT_SS_COLOR_5 : UV_PERP_SS_COLOR_5  
        _stdev_ratio < UV_SS_LEVEL_R_7 => _is_spot? UV_SPOT_SS_COLOR_6 : UV_PERP_SS_COLOR_6  
        => _is_spot? UV_SPOT_SS_COLOR_7 : UV_PERP_SS_COLOR_7
    _result
// -------DEV colorset comparasion
const bool _alt_spot_c = true 
//---------------------------------
if uv_volmode_ultravol_task_flg
    if barstate.isnew 
        spot_ss_high := -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT1_HIGH_R
        spot_ss_low  := -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT1_LOW_R 
        perp_ss_high := -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT2_HIGH_R
        perp_ss_low  := -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT2_LOW_R 
        spot_bcolor  := na  
        perp_bcolor  := na  
    if uv_MasterGATEopen_flg
        _ss_stdbar  = (uv_vol_synth_spot_smoothed - uv_vol_synth_spot_mrktmean) / uv_vol_synth_spot_stdev_denom
        _sp_stdbar  = (uv_vol_synth_perp_smoothed - uv_vol_synth_perp_mrktmean) / uv_vol_synth_perp_stdev_denom
        spot_bcolor := f_uv_energyflux_levelcolor(_ss_stdbar, _alt_spot_c)
        perp_bcolor := f_uv_energyflux_levelcolor(_sp_stdbar, false)

//---- CHART VOL        
else if uv_volmode_chartvol_task_flg
    if barstate.isnew 
        spot_ss_high := -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT1_HIGH_R
        spot_ss_low  := -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT1_LOW_R
        perp_ss_high := na
        perp_ss_low  := na
        spot_bcolor  := na  
        perp_bcolor  := na  
    if uv_MasterGATEopen_flg
        _cs_stdbar  = (uv_vol_smoothed - uv_vol_mrktmean) / uv_vol_stdev_denom
        spot_bcolor := f_uv_energyflux_levelcolor(_cs_stdbar, not str.endswith(uv_chart_tikerid_str, '.P'))

//-------------------
// bcolor == na ? --> plot na 
plotcandle(spot_ss_high, spot_ss_high, spot_ss_low, spot_ss_low
          ,'UV Spot - UV Energy flux', color=spot_bcolor, bordercolor=spot_bcolor, wickcolor=COLOR_TRANSP, editable=false
          ,display=uv_spectrum_GraphicVisualsOn_flg?display.pane:display.none)

plotcandle(perp_ss_high, perp_ss_high, perp_ss_low, perp_ss_low
          ,'UV Perp - UV Energy flux', color=perp_bcolor, bordercolor=perp_bcolor, wickcolor=COLOR_TRANSP, editable=false
          ,display=uv_spectrum_GraphicVisualsOn_flg?display.pane:display.none)


//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪🟪🟪  UV Energy flux - Slot guide name Label
//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
var label uv_spectrum_guide_label = label.new(bar_index, 0, ''
                                    ,textcolor=color.new(#777777,0), color=color.new(#ffffff,90) // COLOR_TRANSP
                                    ,size=11, textalign=text.align_left, text_font_family=font.family_monospace
                                    ,style=label.style_none)         
var string uv_spectrum_guide_name = ''
var string uv_guide_label_tooltip = ''
var float uv_spectrum_guide_y_anchor = na
var int   uv_spectrum_guide_x_index  = na

if uv_spectrum_GraphicVisualsOn_flg and (barstate.islastconfirmedhistory or uv_src_updated_now_flg)
    if (uv_volmode_ultravol_update_task_flg or uv_volmode_chartvol_task_flg)
        uv_spectrum_guide_name := switch
            uv_volmode_ultravol_task_flg => '  UV \n'
                                           +'  '+str.tostring(uv_works_spot_count)+' Spot \n'
                                           +'  '+str.tostring(uv_works_perp_count)+' Perp '        
            =>    'Chart\n Vol'
        uv_guide_label_tooltip := switch 
            uv_volmode_ultravol_task_flg =>   'Final synthetic UV\n'
                                             +'───────────\n'
                                             +'Energy Flux:  '+ str.tostring(uv_works_spot_count) +' Spot \n'
                                             +'Energy Flux:  '+ str.tostring(uv_works_perp_count) +' Perp \n'
            =>    'UV Level    :  Chart Vol\n'
                 +'────────────\n'
                 +'Energy Flux:  Chart Vol\n'
        label.set_text(uv_spectrum_guide_label, uv_spectrum_guide_name)  
        label.set_tooltip(uv_spectrum_guide_label, uv_guide_label_tooltip)  

if uv_spectrum_GraphicVisualsOn_flg and (barstate.islastconfirmedhistory or barstate.islast) 
    uv_spectrum_guide_y_anchor := switch
        uv_volmode_ultravol_task_flg => -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT2_LOW_R
        => -uv_vol_mrktmean * UV_ENERGYFLUX_SLOT1_LOW_R
    label.set_xy(uv_spectrum_guide_label, bar_index + 12, uv_spectrum_guide_y_anchor)
    




//🟪🟪🟪🟪🟪🟪🟪
//🟪 C  V-Ray
//🟪🟪🟪🟪🟪🟪🟪

varip color vray_base_c       = na
varip color vray_high_c       = na
varip color vray_xhigh_c      = na

if not uv_volmode_novol_task_flg and barstate.isnew
    vray_base_c       := na
    vray_high_c       := na
    vray_xhigh_c      := na

if not uv_volmode_novol_task_flg and uv_MasterGATEopen_flg      // master GATE
    // color.new => Transparent 100 over -> no error -> limited 100 internally 
    //────────────────────────────────────────────────────────────────────────────────────────────────────--
    // 🪙🪙 vray base color
    _uv_transp_ratio  = uv_vol_smoothed / uv_vol_mrktmean  
    _uv_vray_base_tr  = switch           // uv_vray_base_tr: VRAY only. na for none, 8 step active band    
        na(_uv_transp_ratio)    => na    // Division by zero -> na
        _uv_transp_ratio < 1.7  => na    // na
        _uv_transp_ratio < 2.4  => 99    // 1
        _uv_transp_ratio < 3.4  => 98    // 2
        _uv_transp_ratio < 4.5  => 97    // 3 
        _uv_transp_ratio < 5.5  => 96    // 4
        _uv_transp_ratio < 6.7  => 95    // 5
        _uv_transp_ratio < 8.0  => 94    // 6
        _uv_transp_ratio < 9.9  => 93    // 7
        => 92
    vray_base_c := color.new(ultravol_vray_color_1, _uv_vray_base_tr + (ultravol_vray_bright_flg?0:2))
    //────────────────────────────────────────────────────────────────────────────────────────────────────--
    // 🟡🟡 vray high color 
    if ta.sma(uv_vol_smoothed, 50) <= uv_vol
        _uv_vray_high_tr = switch uv_level_state 
            3 => 97
            4 => 96   
            => na     
        vray_high_c := color.new(ultravol_vray_color_2, _uv_vray_high_tr + (ultravol_vray_bright_flg?0:2))
    //────────────────────────────────────────────────────────────────────────────────────────────────────--
    //🔵🔵 vray xhigh color
    if ta.sma(uv_vol_smoothed, 20) <= uv_vol 
        _uv_vray_xhigh_tr = switch uv_level_state 
            5 => 92
            6 => 90
            7 => 89   
            => na     
        vray_xhigh_c := color.new(ultravol_vray_color_3, _uv_vray_xhigh_tr + (ultravol_vray_bright_flg?0:3))
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
bgcolor(vray_base_c,    title = 'V-Ray Base',    editable=false ,force_overlay=true, display=ultravol_vray_flg?display.all:display.none)
bgcolor(vray_high_c,    title = 'V-Ray High',    editable=false ,force_overlay=true, display=ultravol_vray_flg?display.all:display.none)
bgcolor(vray_xhigh_c,   title = 'V-Ray xHigh',   editable=false ,force_overlay=true, display=ultravol_vray_flg?display.all:display.none)



//🟪🟪🟪🟪🟪🟪🟪
//🟪 D Push Top
//🟪🟪🟪🟪🟪🟪🟪

//-----------------------------------------------
//🟪 Vol Spectrum display (Chart or Pane) - Push top feature
pushtop_criteria = ultravol_draw_inpane_flg ? math.max(uv_vol_mrktmean*13, uv_vol) * 1.05 : math.max(uv_vol_mrktmean*18, uv_vol) * 5.5
pl_pushtop_top = plot(pushtop_criteria ,title='Volume Push-Top ' ,color=COLOR_TRANSP ,editable=false ,display=display.none)
fill(pl_pushtop_top, pl_pushtop_top, color=COLOR_TRANSP, title='Push-top Fill', editable = false ,display=display.all)

//-----------------------------------------------
//🟪 Candle display (Overlay chart) - Push top feature
const float LIMIT_TOP_RATE      = 2.0  // main band dev ratio
const float LIMIT_BTM_RATE      = 10.0
const float LIMIT_BTM_RATE_EXT  = 18.0 // extreme big vol, bottom drop
bool _ext_dropdown  = (uv_vol > uv_vol_mrktmean * 10) 
float _dev_ = ta.atr(50) * 0.5
float chart_pushtop_criteria_top = uv_chart_high + (_dev_ * LIMIT_TOP_RATE)
float chart_pushtop_criteria_btm = uv_chart_low  - (_dev_ * (_ext_dropdown ? LIMIT_BTM_RATE_EXT : LIMIT_BTM_RATE) * 0.7) // ratio down
pl_chart_pushtop_top = plot(chart_pushtop_criteria_top ,title='Chart limit Top (for overlay mode)' ,color=COLOR_TRANSP ,editable=false ,display=display.none, force_overlay=true)
pl_chart_pushtop_btm = plot(chart_pushtop_criteria_btm ,title='Chart limit Btm (for overlay mode)' ,color=COLOR_TRANSP ,editable=false ,display=display.none, force_overlay=true)
fill(pl_chart_pushtop_top, pl_chart_pushtop_btm, color=COLOR_TRANSP, title='Push-top Fill', editable = false
          ,display=ultravol_draw_inpane_flg ? display.none:display.all)


//🟪🟪🟪🟪🟪🟪🟪
//🟪 E Panel - Vol Src 
//🟪🟪🟪🟪🟪🟪🟪
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🟦🟦🟦🟦 fn() DISPLAY 
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
f_tf_label() =>
    _p              = timeframe.period
    _n              = str.length(_p)
    _last           = _n > 0 ? str.substring(_p, _n - 1, _n) : ''
    _suffix         = str.upper(_last)
    _has_suffix     = _suffix == 'S' or _suffix == 'M' or _suffix == 'H' or _suffix == 'D' or _suffix == 'W'
    _mult           = _has_suffix ? str.substring(_p, 0, _n - 1) : _p
    _minutes        = str.tonumber(_p)
    _is_minute_tf   = not _has_suffix and not na(_minutes)
    _is_hour_tf     = _is_minute_tf and _minutes >= 60 and math.floor(_minutes / 60) == _minutes / 60
    _mult_out       = _is_hour_tf ? str.tostring(_minutes / 60, '#') : _mult
    _suffix_out     = _has_suffix ? str.lower(_suffix) : _is_hour_tf ? 'h' : 'm'
    _mult_out       + _suffix_out

//- - - - - - - - - - - - - - - - - - - - 
const string CHART_MARK      = '🔹' 
const string CHART_MARK_NULL = ''   
//- - - - - - - - - - - - - - - - - - - - 

f_chartvol_mark(_tickerid) =>
    string _result = ''
    if _tickerid != '-' or _tickerid != ''
        string _up_sym_tickerid  = str.upper(_tickerid)
        if (uv_chart_tikerid_str == _up_sym_tickerid)  // chart symbol == _tickerid 
           or ( syminfo.prefix == 'COINBASE'
                and str.substring(uv_chart_tikerid_str, 0 ,str.length(uv_chart_tikerid_str)-1) == _up_sym_tickerid )
                // coinbase USD, USDC pair -> share volume, so USDC -> USD
            _result := CHART_MARK    //'🧿' //🔹🔷
        else 
            _result := CHART_MARK_NULL

f_src_uv_spike_mark(_src, _src_mrktmean) =>
    string _result = switch f_src_uv_leveling(_src, _src_mrktmean )
        -3  => ''
        -2  => ''
        -1  => ''    
        0   => '⟡ ' 
        1   => '✦ '
        2   => '🔸' 
        3   => '🌗'
        4   => '🏐'
        5   => '🥶' 
        6   => '🔵' 
        7   => '🟣' 

f_crypto_symbol_compact_10x(_symbol)=>
    string _result = switch 
        str.contains(_symbol,"1000000") => str.replace(_symbol, "1000000",   "10⁶ ")  //  "1M " )    
        str.contains(_symbol,"10000")   => str.replace(_symbol, "10000",     "10⁴ ")  //  "10k ")   
        str.contains(_symbol,"1000")    => str.replace(_symbol, "1000",      "10³ ")  //  "1k " )    
        => _symbol

f_chartvol_mark_addon(_tickerid)=>
    string _SYMBOL_VAL_     = str.upper(_tickerid)
    string _tkr_pre_        = str.substring(_SYMBOL_VAL_, 0 ,str.pos(_SYMBOL_VAL_, ":"))
    string _tkr_head_       = f_crypto_symbol_corekey(_tickerid, syminfo.basecurrency)      // Header == USDT  
    string _tkr_tails_      = str.replace(_SYMBOL_VAL_, _tkr_head_, '')                     
    string _tkr_head_1short = str.substring(_tkr_head_, 0 ,str.length(_tkr_head_)-1)        // USD 
    //
    string _result          = _SYMBOL_VAL_
    if _tkr_pre_ == 'COINBASE' and _tkr_head_ != 'USD' and _tkr_head_1short != 'USD'
        _result := switch 
            str.endswith(_tkr_tails_, 'USD')    => str.replace(_SYMBOL_VAL_, 'USD'  ,'USD (+C)')
            str.endswith(_tkr_tails_, 'USDC')   => str.replace(_SYMBOL_VAL_, 'USDC' ,'USD (+C)')
            => _SYMBOL_VAL_
    _result := f_crypto_symbol_compact_10x(_result) + f_chartvol_mark(_tickerid)

f_str_trim_lastnewline(_strline) =>
    string _result = na
    if str.endswith(_strline,'\n')
        _result := str.substring(_strline, 0, str.length(_strline)-1) 
    else 
        _result := _strline
    _result
            
f_volstr(_vol_val) =>   
    _result = switch 
        _vol_val >= 1e12 => str.tostring(_vol_val / 1e12, "#.0") + "𝐓"
        _vol_val >= 1e9  => str.tostring(_vol_val / 1e9,  "#.0") + "𝗕"
        _vol_val >= 1e6  => str.tostring(_vol_val / 1e6,  "#.0") + "𝗠"
        _vol_val >= 1e3  => str.tostring(_vol_val / 1e3,  "#.0") + "𝗞"
        =>  str.tostring(_vol_val, "#.0")

f_mktcap_format_B(_val) =>
    _mcap_m = _val / 1000000.0
    _mcap_b = _val / 1000000000.0
    _mcap_t = _val / 1000000000000.0
    na(_val) ? '' : _mcap_b >= 1000 ? str.tostring(_mcap_t, '#,##0.00') + '𝐓'
      : _mcap_b >= 100     ? str.tostring(_mcap_b, '#,#00.0') + '𝗕'
      : _mcap_b >=  10     ? str.tostring(_mcap_b, '#,##0.00') + '𝗕'
      : _mcap_b >=   1     ? str.tostring(_mcap_b, '#,##0.000') + '𝗕'
      : _mcap_b >=   0.1   ? str.tostring(_mcap_b, '#,##0.000') + '𝗕'
      : _mcap_m >=      10 ? str.tostring(_mcap_m, '#,##0.00')  + '𝗠'
      : str.tostring(_mcap_m, '#.000') + '𝗠'

f_crypto_market_cap(_uv_chart_crypto_tickerhead_str) =>
    req = request.security('CRYPTOCAP:' + f_crypto_cryptocap_tv_ticker(_uv_chart_crypto_tickerhead_str), timeframe.period, open, ignore_invalid_symbol=true)

//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// 🟦🟦🟦🟦 fn() DISPLAY - END
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-





//──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//  TABLE - ultravol - raw vol details PANEL 
//──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
var int uv_tbl_head_t_size      = ultravol_panel_small_flg ? 15 : 22 // Crypto name
var int uv_tbl_mcap_t_size      = ultravol_panel_small_flg ? 14 : 19 // MCap 
var int uv_tbl_vol_t_size       = ultravol_panel_small_flg ? 13 : 19 // TF
var int uv_tbl_symbol_t_size    = ultravol_panel_small_flg ? 13 : 19 // symbol
var int uv_tbl_chartmark_t_size = ultravol_panel_small_flg ? 13 : 19 // txt
var int uv_tbl_wlafgf_size      = ultravol_panel_small_flg ? 12 : 17 // txt

const color UV_FRAME_C          = color.new(#999999,0) 
const color UV_HEAD_MCAP_TF_C   = color.new(#ffffff,0)
const color UV_WLAFGF_C         = color.new(#707070,0)
const color UV_SYM_SPOT_C1      = color.new(#8686b0,0)
const color UV_SYM_SPOT_C2      = color.new(#9a7080,0)
const color UV_SYM_PERP_C3      = color.new(#808059,0)
const color UV_SYM_UV_C4        = color.new(#88bb88,0)
const color UV_CHARTVOL_C       = color.new(#426b90,0)
const color UV_BG_C             = COLOR_TRANSP

const string UV_L_              = text.align_left
const string UV_R_              = text.align_right
const string UV_FONT_           = font.family_default

const float UV_TBL_HEIGHT_MIN   = 0.001     // 0.1%
const float UV_TBL_HEIGHT_AUTO  = 0.0       // 0 = Auto
varip float uv_tbl_3h           = 0.0       
varip float uv_tbl_4h           = 0.0       
varip float uv_tbl_5h           = 0.0       
varip float uv_tbl_6h           = 0.0       
varip float uv_tbl_7h           = 0.0       
varip string uv_panel_tooltip           = ''   // tooltip
varip string uv_tbl_ultravol_symtxt3    = ''   // symbol name group 
varip string uv_tbl_ultravol_symtxt4    = ''   // symbol name group 
varip string uv_tbl_ultravol_symtxt5    = ''   // symbol name group 
varip string uv_tbl_ultravol_txt3       = ''   // src vol group
varip string uv_tbl_ultravol_txt4       = ''   // src vol group
varip string uv_tbl_ultravol_txt5       = ''   // src vol group
varip string uv_tbl_ultravol_txt6       = ''   // src vol group
varip string uv_tbl_ultravol_txt7       = ''   // src vol group
 
//----------------------------------------------------------------------------------------------
// INIT 
//----------------------------------------------------------------------------------------------
var table uv_tbl_ = table.new(ultravol_panel_movedown_flg ? position.middle_right:position.top_right, 2, 9, bgcolor=COLOR_TRANSP
                         ,frame_color=UV_FRAME_C, frame_width=0, border_color=COLOR_TRANSP, border_width=0 ,force_overlay=true)
// TABLE INIT 
if ultravol_panel_show_flg and uv_volmode_ultravol_update_task_flg and (barstate.isfirst or barstate.islastconfirmedhistory)

    table.cell(uv_tbl_, 0, 0,text_halign=UV_R_, text_color=UV_SYM_SPOT_C1 ,bgcolor=COLOR_TRANSP, text_size=11 
                         ,text='               ' ) 
    table.cell(uv_tbl_, 1, 0,text_halign=UV_L_, text_color=UV_SYM_SPOT_C1 ,bgcolor=COLOR_TRANSP, text_size=11 
                         ,text='       '         )  
    //----------------------------------------                         
    table.cell(uv_tbl_, 0, 1,text_halign=UV_R_, text_color=UV_HEAD_MCAP_TF_C ,bgcolor=UV_BG_C, text_size=uv_tbl_mcap_t_size )
    table.cell(uv_tbl_, 1, 1,text_halign=UV_L_, text_color=UV_HEAD_MCAP_TF_C ,bgcolor=UV_BG_C, text_formatting=text.format_bold
                         ,text=f_tf_label() , text_size=uv_tbl_symbol_t_size )
    //----------------------------------------
    // binance stock perp -> basecurrency == na -> uv_chart_crypto_tickerhead_str =='' => so, needed workaround
    string _disp_ticker = syminfo.ticker
    if uv_chart_symbol_crypto_basequotetickvol_flg and uv_chart_crypto_tickerhead_str != ''
        _disp_ticker := uv_chart_crypto_tickerhead_str
    else if uv_chart_symbol_crypto_basequotetickvol_flg and str.endswith(str.upper(syminfo.ticker), 'USDT.P')
        _disp_ticker := str.substring(syminfo.ticker, 0, str.pos(str.upper(syminfo.ticker), 'USDT'))
    table.cell(uv_tbl_, 0, 2,text_halign=text.align_center, text_size=uv_tbl_head_t_size, text_color=UV_HEAD_MCAP_TF_C ,bgcolor=UV_BG_C
          ,text_formatting=text.format_bold,text_valign=text.align_bottom
          ,text=_disp_ticker) 
    table.merge_cells(uv_tbl_,0,2,1,2)
    //------------------------------------------------------------------------------------------------------------------
    table.cell(uv_tbl_, 0, 3,text_halign=UV_R_, text_size=uv_tbl_vol_t_size, text_color=UV_SYM_SPOT_C1 ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 0, 4,text_halign=UV_R_, text_size=uv_tbl_vol_t_size, text_color=UV_SYM_SPOT_C2 ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 0, 5,text_halign=UV_R_, text_size=uv_tbl_vol_t_size, text_color=UV_SYM_PERP_C3 ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 0, 6,text_halign=UV_R_, text_size=uv_tbl_vol_t_size, text_color=UV_CHARTVOL_C  ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 0, 7,text_halign=UV_R_, text_size=uv_tbl_vol_t_size, text_color=UV_SYM_UV_C4   ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    //----------------------------------------
    table.cell(uv_tbl_, 1, 3,text_halign=UV_L_, text_size=uv_tbl_symbol_t_size, text_color=UV_SYM_SPOT_C1 ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 1, 4,text_halign=UV_L_, text_size=uv_tbl_symbol_t_size, text_color=UV_SYM_SPOT_C2 ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 1, 5,text_halign=UV_L_, text_size=uv_tbl_symbol_t_size, text_color=UV_SYM_PERP_C3 ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_)
    table.cell(uv_tbl_, 1, 6,text_halign=UV_L_, text_size=uv_tbl_symbol_t_size, text_color=UV_CHARTVOL_C  ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_
              ,text= chartvol_indi_in_panel_flg ? CHART_MARK :'')
    table.cell(uv_tbl_, 1, 7,text_halign=UV_L_, text_size=uv_tbl_symbol_t_size, text_color=UV_SYM_UV_C4   ,bgcolor=UV_BG_C ,text_font_family=UV_FONT_
              ,text= '𝗨𝗩\n' + '𝘀𝗽𝗼𝘁\n' + '𝗽𝗲𝗿𝗽', tooltip=uv_panel_tooltip)   
    //------------------------------------------------------------------------------------------------------------------
    if ultravol_panel_notice_flg
        table.merge_cells(uv_tbl_,0,8,1,8)
        table.cell(uv_tbl_, 0, 8,text_halign=UV_R_, text_size=uv_tbl_wlafgf_size, text_color=UV_WLAFGF_C ,bgcolor=UV_BG_C
                                   ,text= '𝗪𝗟⋅𝗔𝗙'+(not chart_not_included_in_pool_flg ? '       ':' '))             
//---------------------------------------------------------------------------a-------------------------------------------    

//--------------------------------------------------------------------------------------------------------------------
// M.CAP update
//--------------------------------------------------------------------------------------------------------------------
// 
if ultravol_panel_show_flg and barstate.isnew and uv_volmode_ultravol_update_task_flg  // 4h, d 단위 REPLAY 시총 극적 변함
    _uv_crypto_mcap   = f_crypto_market_cap(uv_chart_crypto_tickerhead_str)
    _mcap_line  = (not na(_uv_crypto_mcap) ? '   ' + f_mktcap_format_B(_uv_crypto_mcap) : '-')
    table.cell_set_text(uv_tbl_, 0, 1, '  ' + _mcap_line )    

//---------------------------------------------------------------------------------------------------------------------
//  Table - Symbol column -> s1~p4 update time only
//---------------------------------------------------------------------------------------------------------------------
//  first bar update, next on condition
if (uv_src_updated_now_flg and ultravol_panel_show_flg and uv_volmode_ultravol_update_task_flg) or barstate.isfirst or barstate.islastconfirmedhistory 
    uv_panel_tooltip := '\nUV spike　⟡✦🔸🌗🏐🥶🔵🟣\n' 
          + '──────────────\n'
          + (v_s1_works ? f_chartvol_mark_addon(uv_sym_s1) + '\n'   :'') 
          + (v_s2_works ? f_chartvol_mark_addon(uv_sym_s2) + '\n'   :'') 
          + (v_s3_works ? f_chartvol_mark_addon(uv_sym_s3) + '\n'   :'') 
          + (v_s4_works ? f_chartvol_mark_addon(uv_sym_s4) + '\n'   :'') 
          + '\n' 
          + (v_s5_works ? f_chartvol_mark_addon(uv_sym_s5) + '\n'   :'') 
          + (v_s6_works ? f_chartvol_mark_addon(uv_sym_s6) + '\n'   :'') 
          + (v_s7_works ? f_chartvol_mark_addon(uv_sym_s7) + '\n'   :'') 
          + (v_s8_works ? f_chartvol_mark_addon(uv_sym_s8) + '\n'   :'') 
          + '\n'
          + (v_p1_works ? f_chartvol_mark_addon(uv_sym_p1) + '\n'   :'')
          + (v_p2_works ? f_chartvol_mark_addon(uv_sym_p2) + '\n'   :'')
          + (v_p3_works ? f_chartvol_mark_addon(uv_sym_p3) + '\n'   :'')
          + (v_p4_works ? f_chartvol_mark_addon(uv_sym_p4) + '\n'   :'') 
          + (chartvol_indi_in_panel_flg ? '──────────────\n' + ticker.standard(syminfo.tickerid) + CHART_MARK +'\n' : '')
          + '──────────────\n'
          + (uv_volmode_ultravol_candidate_task_flg and chart_not_included_in_pool_flg ? 
              '⚠️  Chart is not in vol-src pool\n'
             +'　 and no data across the pool\n'  
             +'➔ Fallback [Chart Vol] mode\n\n'  :'') 
          + (uv_volmode_ultravol_candidate_task_flg and not chart_not_included_in_pool_flg ? 
              '⚠️　Chart is in vol-src pool, but\n'
             +'  the pool has no data for the \n' 
             +'  current low TF at this position.\n'  
             +'➔ Fallback [Chart Vol] mode\n\n'   :'')
          + (uv_volmode_ultravol_task_flg and chart_not_included_in_pool_flg ? 
              'Chart is not in vol-src pool\n'
             +'But the pool data covers it\n\n'   :'')
          + (uv_volmode_ultravol_update_task_flg and uv_works_total_count != 0 ? 
              "✨ [Ultravol] synthesized.\n" : '')
          + (uv_volmode_ultravol_update_task_flg and uv_works_total_count != 0 ?
              '     [' + str.tostring(uv_works_spot_count) + ' Spot, ' + str.tostring(uv_works_perp_count) + ' Perp]' 
             + (chart_not_included_in_pool_flg ? ', excl.' + CHART_MARK :'')
             + '\n\n' :'')
          + (uv_volmode_ultravol_update_task_flg ?
              "Exchange's volume (number)\n"
             +"Converted raw to base unit.\n"
             +'\n'
             +"UV-scaled spike (color mark)\n"
             +"[Panel is fixed. Rescale N/A.]\n\n"
                 : '' )       
          + ''   
    table.cell_set_tooltip(uv_tbl_, 0, 2, uv_panel_tooltip)
    table.cell_set_tooltip(uv_tbl_, 0, 3, uv_panel_tooltip), table.cell_set_tooltip(uv_tbl_, 1, 3, uv_panel_tooltip)
    table.cell_set_tooltip(uv_tbl_, 0, 4, uv_panel_tooltip), table.cell_set_tooltip(uv_tbl_, 1, 4, uv_panel_tooltip)
    table.cell_set_tooltip(uv_tbl_, 0, 5, uv_panel_tooltip), table.cell_set_tooltip(uv_tbl_, 1, 5, uv_panel_tooltip)
    table.cell_set_tooltip(uv_tbl_, 0, 6, uv_panel_tooltip), table.cell_set_tooltip(uv_tbl_, 1, 6, uv_panel_tooltip)
    table.cell_set_tooltip(uv_tbl_, 0, 7, uv_panel_tooltip), table.cell_set_tooltip(uv_tbl_, 1, 7, uv_panel_tooltip)
    table.cell_set_tooltip(uv_tbl_, 0, 8, uv_panel_tooltip)
    //--------------------------------------------------------------------
    // table Symbol update
    s1cv_mark = f_chartvol_mark(uv_sym_s1)
    s2cv_mark = f_chartvol_mark(uv_sym_s2)
    s3cv_mark = f_chartvol_mark(uv_sym_s3)
    s4cv_mark = f_chartvol_mark(uv_sym_s4)
    s5cv_mark = f_chartvol_mark(uv_sym_s5)
    s6cv_mark = f_chartvol_mark(uv_sym_s6)
    s7cv_mark = f_chartvol_mark(uv_sym_s7)
    s8cv_mark = f_chartvol_mark(uv_sym_s8)
    p1cv_mark = f_chartvol_mark(uv_sym_p1)
    p2cv_mark = f_chartvol_mark(uv_sym_p2)
    p3cv_mark = f_chartvol_mark(uv_sym_p3)
    p4cv_mark = f_chartvol_mark(uv_sym_p4)
    uv_tbl_ultravol_symtxt3 := f_str_trim_lastnewline( 
                                (v_s1_works ? 'Bn' + s1cv_mark +'\n' : '')
                              + (v_s2_works ? 'Bn′'+ s2cv_mark +'\n' : '')
                              + (v_s3_works ? 'Co' + s3cv_mark +'\n' : '')
                              + (v_s4_works ? 'By' + s4cv_mark       : ''))
    uv_tbl_ultravol_symtxt4 := f_str_trim_lastnewline(  
                                (v_s5_works ? 'Ok' + s5cv_mark +'\n' : '')
                              + (v_s6_works ? 'Up' + s6cv_mark +'\n' : '')
                              + (v_s7_works ? 'Kk' + s7cv_mark +'\n' : '')
                              + (v_s8_works ? 'Bg' + s8cv_mark       : ''))
    uv_tbl_ultravol_symtxt5 := f_str_trim_lastnewline(
                                (v_p1_works ? 'Bnᴾ' + p1cv_mark +'\n' : '')
                              + (v_p2_works ? 'Coᴾ' + p2cv_mark +'\n' : '')
                              + (v_p3_works ? 'Byᴾ' + p3cv_mark +'\n' : '')
                              + (v_p4_works ? 'Okᴾ' + p4cv_mark       : ''))
    table.cell_set_text(uv_tbl_, 1, 3, uv_tbl_ultravol_symtxt3)
    table.cell_set_text(uv_tbl_, 1, 4, uv_tbl_ultravol_symtxt4)
    table.cell_set_text(uv_tbl_, 1, 5, uv_tbl_ultravol_symtxt5)
    // 6th cell (Chart vol not in pool) --> update @isfirst 
    if not uv_debuglabel_detailed_show_flg
        table.cell_set_text(uv_tbl_, 1, 7, '')
    //-------------------------------------------------------------------------------------------------
    // table height 0.01 => cell has no content 
    uv_tbl_3h := not (v_s1_works or v_s2_works or v_s3_works or v_s4_works) ? UV_TBL_HEIGHT_MIN : UV_TBL_HEIGHT_AUTO
    uv_tbl_4h := not (v_s5_works or v_s6_works or v_s7_works or v_s8_works) ? UV_TBL_HEIGHT_MIN : UV_TBL_HEIGHT_AUTO
    uv_tbl_5h := not (v_p1_works or v_p2_works or v_p3_works or v_p4_works) ? UV_TBL_HEIGHT_MIN : UV_TBL_HEIGHT_AUTO
    uv_tbl_6h := not chartvol_indi_in_panel_flg                             ? UV_TBL_HEIGHT_MIN : UV_TBL_HEIGHT_AUTO
    uv_tbl_7h := not uv_debuglabel_detailed_show_flg                        ? UV_TBL_HEIGHT_MIN : UV_TBL_HEIGHT_AUTO   
    table.cell_set_height(uv_tbl_,0,3,uv_tbl_3h), table.cell_set_height(uv_tbl_,1,3,uv_tbl_3h)
    table.cell_set_height(uv_tbl_,0,4,uv_tbl_4h), table.cell_set_height(uv_tbl_,1,4,uv_tbl_4h)
    table.cell_set_height(uv_tbl_,0,5,uv_tbl_5h), table.cell_set_height(uv_tbl_,1,5,uv_tbl_5h)
    table.cell_set_height(uv_tbl_,0,6,uv_tbl_6h), table.cell_set_height(uv_tbl_,1,6,uv_tbl_6h)
    table.cell_set_height(uv_tbl_,0,7,uv_tbl_7h), table.cell_set_height(uv_tbl_,1,7,uv_tbl_7h)
//----------------------------------------------------------------------------------------------------------------------



//----------------------------------------------------------------------------------------------------------------------
// Vol Panel - Raw src - Spike Leveling 
//----------------------------------------------------------------------------------------------
varip string v_s1_spike = ''
varip string v_s2_spike = ''
varip string v_s3_spike = ''
varip string v_s4_spike = ''
varip string v_s5_spike = ''
varip string v_s6_spike = ''
varip string v_s7_spike = ''
varip string v_s8_spike = ''
varip string v_p1_spike = ''
varip string v_p2_spike = ''
varip string v_p3_spike = ''
varip string v_p4_spike = ''
varip string v_chart_spike = ''
if barstate.islast and barstate.isnew and uv_volmode_ultravol_update_task_flg  // every candle init
    v_s1_spike := ''
    v_s2_spike := ''
    v_s3_spike := ''
    v_s4_spike := ''
    v_s5_spike := ''
    v_s6_spike := ''
    v_s7_spike := ''
    v_s8_spike := ''
    v_p1_spike := ''
    v_p2_spike := ''
    v_p3_spike := ''
    v_p4_spike := ''
    v_chart_spike := ''
if barstate.islast and uv_MasterGATEopen_flg and uv_volmode_ultravol_update_task_flg  // performance
    v_s1_spike := v_s1_works ? f_src_uv_spike_mark(v_s1.vol, v_s1_mrktmean) : ''
    v_s2_spike := v_s2_works ? f_src_uv_spike_mark(v_s2.vol, v_s2_mrktmean) : ''
    v_s3_spike := v_s3_works ? f_src_uv_spike_mark(v_s3.vol, v_s3_mrktmean) : ''
    v_s4_spike := v_s4_works ? f_src_uv_spike_mark(v_s4.vol, v_s4_mrktmean) : ''
    v_s5_spike := v_s5_works ? f_src_uv_spike_mark(v_s5.vol, v_s5_mrktmean) : ''
    v_s6_spike := v_s6_works ? f_src_uv_spike_mark(v_s6.vol, v_s6_mrktmean) : ''
    v_s7_spike := v_s7_works ? f_src_uv_spike_mark(v_s7.vol, v_s7_mrktmean) : ''
    v_s8_spike := v_s8_works ? f_src_uv_spike_mark(v_s8.vol, v_s8_mrktmean) : ''
    v_p1_spike := v_p1_works ? f_src_uv_spike_mark(v_p1.vol, v_p1_mrktmean) : ''
    v_p2_spike := v_p2_works ? f_src_uv_spike_mark(v_p2.vol, v_p2_mrktmean) : ''
    v_p3_spike := v_p3_works ? f_src_uv_spike_mark(v_p3.vol, v_p3_mrktmean) : ''
    v_p4_spike := v_p4_works ? f_src_uv_spike_mark(v_p4.vol, v_p4_mrktmean) : ''
    v_chart_spike := chartvol_indi_in_panel_flg ? f_src_uv_spike_mark(uv_chartvol, uv_chartvol_mrktmean) : ''


    
//----------------------------------------------------------------------------------------------
// Vol Panel - Volume update
//----------------------------------------------------------------------------------------------
if barstate.islast and ultravol_panel_show_flg and uv_volmode_ultravol_update_task_flg   
    // src volume update - MasterGATE
    if uv_MasterGATEopen_flg or barstate.isnew  // 🟥🟥  MasterGATE 🟥🟥 
        uv_tbl_ultravol_txt3:= str.trim(
                            (v_s1_works ? v_s1_spike + f_volstr(v_s1.vol) + '\n' : '')
                          + (v_s2_works ? v_s2_spike + f_volstr(v_s2.vol) + '\n' : '')
                          + (v_s3_works ? v_s3_spike + f_volstr(v_s3.vol) + '\n' : '') 
                          + (v_s4_works ? v_s4_spike + f_volstr(v_s4.vol)        : '') )
        uv_tbl_ultravol_txt4:= str.trim(
                            (v_s5_works ? v_s5_spike + f_volstr(v_s5.vol) + '\n' : '')
                          + (v_s6_works ? v_s6_spike + f_volstr(v_s6.vol) + '\n' : '') 
                          + (v_s7_works ? v_s7_spike + f_volstr(v_s7.vol) + '\n' : '')
                          + (v_s8_works ? v_s8_spike + f_volstr(v_s8.vol)        : '') )
        uv_tbl_ultravol_txt5:= str.trim(
                            (v_p1_works ? v_p1_spike + f_volstr(v_p1.vol) + '\n' : '')
                          + (v_p2_works ? v_p2_spike + f_volstr(v_p2.vol) + '\n' : '')
                          + (v_p3_works ? v_p3_spike + f_volstr(v_p3.vol) + '\n' : '')
                          + (v_p4_works ? v_p4_spike + f_volstr(v_p4.vol)        : '') )
        uv_tbl_ultravol_txt6:= chartvol_indi_in_panel_flg ? (not na(uv_chartvol) ? v_chart_spike + f_volstr(uv_chartvol) : '-'):''
        uv_tbl_ultravol_txt7:= not uv_debuglabel_detailed_show_flg ? '' : ''
                          + (not na(uv_vol)         ?   f_volstr(uv_vol)         : '-') + '\n'
                          + (not na(uv_vol_UV_spot) ?   f_volstr(uv_vol_UV_spot) : '-') + '\n'
                          + (not na(uv_vol_UV_perp) ?   f_volstr(uv_vol_UV_perp) : '-') 
    //---------------------------------------------------------
    // table volume + spike update
    table.cell_set_text(uv_tbl_, 0, 3, uv_tbl_ultravol_txt3)
    table.cell_set_text(uv_tbl_, 0, 4, uv_tbl_ultravol_txt4)
    table.cell_set_text(uv_tbl_, 0, 5, uv_tbl_ultravol_txt5)
    table.cell_set_text(uv_tbl_, 0, 6, uv_tbl_ultravol_txt6)
    table.cell_set_text(uv_tbl_, 0, 7, uv_tbl_ultravol_txt7)

//🟪 E Panel - Vol Src end
//🟪🟪🟪🟪🟪🟪🟪
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────



















//🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩🪩
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// DEV - volume mode panel - mini Table
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
var table uv_vol_mode_notice_tbl = table.new(position.bottom_right, 1, 7
                                ,bgcolor=COLOR_TRANSP, frame_color=COLOR_TRANSP, frame_width=0
                                ,border_color=COLOR_TRANSP, border_width=1, force_overlay=true) 
//────────────────────────────────────────────────────────────────────────────────────────────────────────────-
// cell #0,1   DEV CONSOLE  - NOTLIVE flg monitoring
//────────────────────────────────────────────────────────────────────────────────────────────────────────────-
if uv_debuglabel_detailed_show_flg and barstate.islast
    //─────────────────────────────────────────────────────────────────────────────────────────────────────────
    // cell #0  DEV = Crypto ??? flag
    //─────────────────────────────────────────────────────────────────────────────────────────────────────────
    _color_bg0    = uv_volmode_ultravol_task_flg ? color.new(#00cc44, 40) 
                  : uv_volmode_chartvol_task_flg ? color.new(#b7b7b1, 80) 
                  : uv_volmode_novol_task_flg    ? color.new(#ff4c57, 90) 
                  : color.new(#000000,20)
    _color_fg0    = uv_volmode_ultravol_task_flg ? color.new(#eeeeee, 0) 
                  : uv_volmode_chartvol_task_flg ? color.new(#eeeeee, 0) 
                  : uv_volmode_novol_task_flg    ? color.new(#ff4c57, 0) 
                  : color.green
    _volmode_name = switch uv_volmode_state 
        0   => '0 Ultravol unfixed'
        1   => '1 No Vol'
        2   => '2 Chart Vol'
        3   => '3 Ultravol fixed'
    _uv_dev_test0 = '=' + _volmode_name + '\n'
                  + '\n'
                  + 'ultravol_task ' + str.upper(str.tostring(uv_volmode_ultravol_task_flg)) + '\n'
                  + 'chartvol_task ' + str.upper(str.tostring(uv_volmode_chartvol_task_flg)) + '\n'
                  + 'novol_task    ' + str.upper(str.tostring(uv_volmode_novol_task_flg   )) + '\n'
                  + '\n'
                  + 'chartvol_indi ' + str.upper(str.tostring(chartvol_indi_in_panel_flg  )) + '\n'
                  + 'UV_updatetask ' + str.upper(str.tostring(uv_volmode_ultravol_update_task_flg  )) + '\n'
                  + 'c_not_in_pool ' + str.upper(str.tostring(chart_not_included_in_pool_flg  )) + '\n'
                  + 'USDT price    ' + str.upper(str.tostring(USD2USDT_avg_rate, '###,###.#####'  )) + '\n'
                  + 'USDC price    ' + str.upper(str.tostring(USD2USDC_avg_rate, '###,###.#####'  )) + '\n'
                  + '\n'
                  + 'UV_VOL 1/' + str.tostring(uv_vol_scaledown_for_GF, '###,###') // + '\n'
    table.cell(uv_vol_mode_notice_tbl, 0, 0, _uv_dev_test0,  height=0
              ,text_halign=text.align_left, text_valign=text.align_center
              ,text_size=13 ,text_color=_color_fg0 ,bgcolor=_color_bg0, text_font_family= font.family_monospace) 
    //─────────────────────────────────────────────────────────────────────────────────────────────────────────
    // cell #1  DEV = Live Chart flag
    //─────────────────────────────────────────────────────────────────────────────────────────────────────────
    _test1_on     = not bar_GATEbypass_flg 
    _color_bg1    = _test1_on ? color.new(#00bbff, 40) : color.new(#000000,20)
    _color_fg1    = _test1_on ? color.white            : color.green
    _uv_dev_test1 = 'GATE_required ' + str.upper(str.tostring(uv_throttleGATE_required)) + '\n'    
                  + 'GATE bypass   ' + str.upper(str.tostring(bar_GATEbypass_flg)) + '\n'                      
                  + 'GATE open     ' + str.upper(str.tostring(uv_MasterGATEopen_flg)) 
    table.cell(uv_vol_mode_notice_tbl, 0, 1, _uv_dev_test1,  height=0 
              ,text_halign=text.align_left, text_valign=text.align_center
              ,text_size=13 ,text_color=_color_fg1 ,bgcolor=_color_bg1, text_font_family= font.family_monospace) 
    //─────────────────────────────────────────────────────────────────────────────────────────────────────────
    // cell #2  DEV = NOTLIVE flag
    //─────────────────────────────────────────────────────────────────────────────────────────────────────────
    _test2_on     = bar_NOTLIVE_flg 
    _color_bg2    = _test2_on ? color.new(#ffbb00, 40) : color.new(#000000,20) 
    _color_fg2    = _test2_on ? color.white            : color.green           
    _timecheck    = timenow - (time_close + ((time_close - time)*2)) 
    _uv_dev_test2 = '_NOTLIVE_flg  ' + str.upper(str.tostring(bar_NOTLIVE_flg)) + '\n'
                  + '\n'                                                  
                  + '.isrealtime   ' + str.upper(str.tostring( barstate.isrealtime )) + '\n'
                  + '.islast       ' + str.upper(str.tostring( barstate.islast     )) + '\n'
                  + '+2close<now   ' + str.upper(str.tostring( _timecheck > 0      )) + '\n'
                  + '\n'                                                  
                  + 'delta 𝜟 '  + str.tostring( (_timecheck/1000),'###,###.0') + 'sec\n'    
                  + 'time    +' + str.tostring((time/1000) - 1777000000,'###,###.0') + 's\n'                      
                  + 't_close +' + str.tostring((time_close/1000) - 1777000000,'###,###.0') + 's\n'    
                  + 'timenow +' + str.tostring((timenow/1000) - 1777000000,'###,###.0') + 's'                      
    table.cell(uv_vol_mode_notice_tbl, 0, 2, _uv_dev_test2,  height=0
              ,text_halign=text.align_left, text_valign=text.align_center
              ,text_size=13 ,text_color=_color_fg2 ,bgcolor=_color_bg2, text_font_family= font.family_monospace) 
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// cell #3  end user - Bar NOTLIVE status
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
varip bool _NOTLIVE_mark_ON = false
if barstate.islast and bar_NOTLIVE_flg and not _NOTLIVE_mark_ON
    table.cell(uv_vol_mode_notice_tbl, 0, 3, '𝗡𝗢𝗧 𝗟𝗜𝗩𝗘',  height=0    // 𝗥𝗘𝗣𝗟𝗔𝗬
              ,text_halign=text.align_center, text_valign=text.align_center
              ,text_size=10 ,text_formatting=text.format_bold, text_color=color.new(#ffbb00,0), bgcolor=color.new(#333333,20) )                
    _NOTLIVE_mark_ON := true 
else if barstate.islast and not bar_NOTLIVE_flg and _NOTLIVE_mark_ON
    table.clear(uv_vol_mode_notice_tbl, 0,0,0,0)  
    _NOTLIVE_mark_ON := false

// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// cell #4,5,6   end user
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
const color uv_gfm4_off_fg_c             = #3c3c3c
const color uv_gfm4_on_index_c           = #eeeeee
const color uv_gfm4_on_scale_notice_gf_c = #bcbcbc,  const color uv_gfm4_on_scale_bg_c         = color.new(#000000,30)
const color uv_volmode_nodata_notice_fg_c= #ff4c57,  const color uv_volmode_nodata_notice_bg_c = color.new(#330e17,20)
const color uv_volmode_synth_notice_fg_c = #b5e99f,  const color uv_volmode_synth_notice_bg_c  = color.new(#1f2818,20)
const color uv_volmode_chart_notice_fg_c = #b7b7b1,  const color uv_volmode_chart_notice_bg_c  = color.new(#303030,20)
const color uv_volmode_index_notice_fg_c = #92Deff,  const color uv_volmode_index_notice_bg_c  = color.new(#141f44,20)
const color uv_volmode_forcechartvol_c   = #e7c751

varip string uv_gf4m_text = na
varip color  uv_gfm4_textcolor = na 
varip string uv_rescale_notice_text = na
varip color  uv_price_notice_tbl_c = na
varip color  uv_gfm4_on_scale_bg_select =na
varip color  uv_volmode_notice_tbl_c = na
varip color  uv_volmode_notice_tbl_bg_c = na

varip bool _volmode_ultravol_mark_fixed = false
if not _volmode_ultravol_mark_fixed and (barstate.islastconfirmedhistory or uv_src_updated_now_flg) and ultravol_mark_show_flg
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────-
    // cell #4   end user - Price Src
    uv_gf4m_text := switch 
        ultravol_rescale_mode_selector != uv_rescale_mode.neutral => ultravol_rescale_mode_text
        => '⦧𝑮𝑭4🅼 '
        //---------------------------------------------------------------
        // => '⦧𝑮𝑭4🅼 '+'\n'+chart_current_currency // DEV DEBUG CHECK 
    uv_gfm4_textcolor := switch 
        uv_volmode_novol_task_flg    => uv_gfm4_off_fg_c
        uv_volmode_ultravol_task_flg => uv_gfm4_on_scale_notice_gf_c // uv_gfm4_on_index_c
        => uv_gfm4_on_scale_notice_gf_c
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────-
    // cell #5   end user - Price Mode
    uv_price_notice_tbl_c := switch
        uv_volmode_novol_task_flg    => uv_volmode_chart_notice_fg_c
        uv_volmode_ultravol_task_flg and g_index_px_works => uv_volmode_index_notice_fg_c
        => uv_volmode_chart_notice_fg_c
    uv_rescale_notice_text := switch
        uv_volmode_novol_task_flg       => 'Chart  Px'
        uv_volmode_ultravol_task_flg and g_index_px_works      => 'G-Index'        
        uv_volmode_ultravol_task_flg and not g_index_px_works  => 'Chart Px' 
        => 'Chart  Px'
    uv_gfm4_on_scale_bg_select := switch
        uv_volmode_novol_task_flg       => uv_volmode_chart_notice_bg_c
        uv_volmode_ultravol_task_flg and g_index_px_works      => uv_volmode_index_notice_bg_c // uv_volmode_synth_notice_bg_c
        uv_volmode_ultravol_task_flg and not g_index_px_works  => uv_volmode_chart_notice_bg_c // uv_volmode_synth_notice_bg_c
        => uv_volmode_chart_notice_bg_c          
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────-
    // cell #6   end user - Vol Mode
    uv_volmode_notice_tbl_c := switch
        uv_volmode_novol_task_flg    => uv_volmode_nodata_notice_fg_c
        uv_volmode_ultravol_task_flg => uv_volmode_synth_notice_fg_c
        ultravol_force_chartvol_flg  => uv_volmode_forcechartvol_c
        => uv_volmode_chart_notice_fg_c
    uv_volmode_notice_tbl_bg_c := switch
        uv_volmode_novol_task_flg    => uv_volmode_nodata_notice_bg_c
        uv_volmode_ultravol_task_flg => uv_volmode_synth_notice_bg_c
        => uv_volmode_chart_notice_bg_c
    if uv_volmode_ultravol_task_flg or (uv_volmode_chartvol_task_flg and not uv_volmode_ultravol_candidate_task_flg)
        _volmode_ultravol_mark_fixed := true 

if barstate.islast and ultravol_mark_show_flg
    table.cell_set_text             (uv_vol_mode_notice_tbl, 0, 4, uv_gf4m_text)
    table.cell_set_text_size        (uv_vol_mode_notice_tbl, 0, 4, 11)
    table.cell_set_text_color       (uv_vol_mode_notice_tbl, 0, 4, uv_gfm4_textcolor)
    table.cell_set_bgcolor          (uv_vol_mode_notice_tbl, 0, 4, uv_gfm4_on_scale_bg_c)
    table.cell_set_text             (uv_vol_mode_notice_tbl, 0, 5, uv_rescale_notice_text)
    table.cell_set_text_size        (uv_vol_mode_notice_tbl, 0, 5, 10)
    table.cell_set_text_formatting  (uv_vol_mode_notice_tbl, 0, 5, text.format_bold)
    table.cell_set_text_color       (uv_vol_mode_notice_tbl, 0, 5, uv_price_notice_tbl_c)
    table.cell_set_bgcolor          (uv_vol_mode_notice_tbl, 0, 5, uv_gfm4_on_scale_bg_select)
    table.cell_set_text             (uv_vol_mode_notice_tbl, 0, 6, uv_volmode_name_remark)
    table.cell_set_text_size        (uv_vol_mode_notice_tbl, 0, 6, 10)
    table.cell_set_text_formatting  (uv_vol_mode_notice_tbl, 0, 6, text.format_bold)
    table.cell_set_text_color       (uv_vol_mode_notice_tbl, 0, 6, uv_volmode_notice_tbl_c)
    table.cell_set_bgcolor          (uv_vol_mode_notice_tbl, 0, 6, uv_volmode_notice_tbl_bg_c)
````
