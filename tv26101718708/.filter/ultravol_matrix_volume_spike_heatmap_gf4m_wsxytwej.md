# Ultravol Matrix - volume spike heatmap [GF4M]

- url: https://www.tradingview.com/script/wSXYtWEj-Ultravol-Matrix-volume-spike-heatmap-GF4M/
- type: indicator
- pine_id: PUB;70e5e866517649cabae0a4119c3d8b1e
- version: 2.0

## Description

[b]Ultravol Matrix - cross-exchange volume spike heatmap [/b]

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


🔷 [b]Ultravol Core Engine: Processing Diagram [/b] 
[image]https://www.tradingview.com/x/HFTMZsyQ/[/image]
🟣 Full engine mechanics (Master GATE scheduling, coin-unit correction, per-exchange trust weighting, auto listing-join) are documented in the Appendix — see origin indicator [Ultravol].


───────────────────────────────────────────────
[b]Ultravol Matrix - cross-exchange volume spike heatmap [/b]



✨ Gives you an insight into hidden, cross-exchange volume spike flow — by color, instantly!

Across many crypto exchanges, Ultravol Matrix curates 12 pairs (spot + perp) — Each exchange's volume, reverted to native base. → normalized to its own signature. → Rendered on the same UV-defined color scale. → Spike flow patterns (not absolute volume) can be compared directly across history in one matrix.

📘 Strong trends begin with cascading vol spikes across all exchanges.

📗 A perp vol spike with no spot participation (all or a single perp pair) is often just a futures liquidation cascade.

📙 Track vol spike trends by exchange. Who is trending? Alone? User base? Region? Spot or Perp? All together?

📕 Trending vol spike sequence — drop to lower TF (1m or seconds) to read the order in detail.

✨ Ultravol Matrix Engine:
Its own unique method. 12-pair per-exchange UV-scaled color leveling is crypto-exclusive.



🔹 How to read it
[image]https://www.tradingview.com/x/FrUZ0oRs/[/image]
[image]https://www.tradingview.com/x/cvvmUprk/[/image]

🔗 The time-axis extension of Ultravol — same language by UV-scaled color: Ultravol Matrix reads history, Ultravol reads live.
[image]https://www.tradingview.com/x/aqHcueVf/[/image]

🔹 You can easily spot mass volume that's concentrated in a single exchange.
[image]https://www.tradingview.com/x/LLzmdJTi/[/image]

🔹 All together or single spike trending.
[image]https://www.tradingview.com/x/lnFY6Sm7/[/image]
[image]https://www.tradingview.com/x/X44gwpqQ/[/image]

🔹 For altcoins, even on the 5m and 15m timeframes, persistent long spikes tend to occur on only a few individual exchanges. This behavior is less frequent in major cryptocurrencies like BTC or ETH. (It is recommended to familiarize yourself with the volume spike patterns of your specific trading pairs in advance.)
[image]https://www.tradingview.com/x/btyBxC5k/[/image]

Setup Panel

☑ 📱   : Mobile friendly UI setup
• Source        : Ultravol (Auto) fixed
[image]https://www.tradingview.com/x/cSU1xyUK/[/image]

• Rescale      : Only for extremes, too 🔥 or too ⚫️
Especially for altcoins, the market heats up significantly during trending phases. Consequently, if the heatmap temperature rises to a point where chart variations become difficult to distinguish, lowering the rescale option by -1 or -2 makes it easier to discern the intensity differences on the screen. (In this case, the adjusted value is temporarily displayed in the bottom-right corner.)
[image]https://www.tradingview.com/x/r41WhAnb/[/image]
[image]https://www.tradingview.com/x/oiaDVo2r/[/image]

🔸 Hover over the nametag for symbol info.
[image]https://www.tradingview.com/x/KyOmBTgh/[/image]

🔸 Maximize the pane (or drag it taller) for detailed matrix flow.

Matrix's volume spectrum is compressed using a separate log-based clamp to fit within a low-height panel. Read it only as relative magnitude — judge volume spikes by color, not by bar height.
[image]https://www.tradingview.com/x/GzA8AP4Q/[/image]
[image]https://www.tradingview.com/x/bNuaGHmK/[/image]

⚠️ Required setting: In order to vertically align the Name tag (on matrix)
⚙︎ > Chart option > Canvas > Margins >  Top: 0%   Bottom: 0%   Rights: 50bars
[image]https://www.tradingview.com/x/dQHnF7Va/[/image]

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © GF4M
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-
//
// ⦧𝑮𝑭4🅼　Ultravol Matrix
// 
const string _VERSION_ = 'v1.79' 
//
//@version=6   
indicator("Ultravol Matrix - volume spike heatmap [GF4M]","⦧𝑮𝑭4🅼　Ultravol Matrix",format=format.volume, dynamic_requests=true, max_bars_back = 3000
             ,max_labels_count = 50, max_lines_count = 200 ,overlay=false, explicit_plot_zorder=true)// calc_bars_count=40000)   // ,max_bars_back=1000)
//─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────-






//  Pre-Define
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
const color COLOR_TRANSP        = color.new(#000000,100)                                                                        
const color COLOR_BLACK         = color.new(#000000,  0)
const string GR_ULTRAVOL  = '🟥🟧🟨⬜️🟦🟪　𝗥𝗘𝗪𝗜𝗥𝗘 𝗜𝗡𝗧𝗨𝗜𝗧𝗜𝗢𝗡　　　　　 𝖴𝖵𝖬𝖷 '+_VERSION_
const string GR_ULTRAVOL_ = "READ AS MARKET-WIDE SPIKE FLOW, NOT ALONE.       \n"
                          + '─────────────────────────────　　 \n'
const string GR_EXT_      = '─────────────────────────────　　 \n'
const string GR_TT_PB     = ' \n 🦕　Pair Begins  \n '  
const string GR_UV_ULTRAVOL_TT_VAL  = ' \n'
                         +'⦧𝑮𝑭4🅼　Ultravol Matrix\n'
                         +'────────────────────── \n'         
                         +"✨ Cross-exchange volume spike flow matrix.\n"
                         +'\n'
                         +"✨ Gives you an insight into hidden, per-exchange volume spike flow — by color, instantly!\n"
                         +'\n'
                         +"Across many crypto exchanges, Ultravol Matrix curates 12 (spot + perp) —  Each exchange's volume, normalized to its own signature.    → Rendered on the same UV-defined color scale.    → Spike flow patterns (not absolute volume) can be compared directly across history in one matrix.\n"
                         +'\n'
                         +'📘 Strong trends begin with cascading vol spikes across all exchanges.\n'
                         +'\n'
                         +'📗 A perp vol spike with no spot participation (all or a single perp pair) is often just a futures liquidation cascade.\n'
                         +'\n'
                         +"📙 Track vol spike trends by exchange. Who is trending? Alone? User base? Region? Spot or Perp? All together?\n"
                         +'\n'
                         +'📕 Trending vol spike sequence — drop to lower TF (1m or seconds) to read the order in detail.\n'
                         +'\n'
                         +"🔗 The time-axis extension of Ultravol — Use together Ultravol, Ultravol Matrix (same language): Matrix reads vol spike history, Ultravol reads live spike.\n"
                         +' \n\n' 
const string GR_UV_ULTRAVOL_TT2_VAL  = ' \n'
                         +'⦧𝑮𝑭4🅼　Ultravol Matrix\n'
                         +'────────────────────── \n' 
                         +' ☑ 📱           : Mobile friendly UI setup\n'
                         +'\n'
                         +' • Source        : Ultravol (Auto) fixed\n'    
                         +' • Rescale      : Only for extremes, too 🔥 or too ⚫️\n'                                     
                         +'\n'
                         +'🔸 Hover over the nametag for symbol info.\n' 
                         +'\n'                         
                         +'🔸 Maximize the pane (or drag it taller)\n'
                         +'      for detailed matrix flow.\n' 
                         +'\n'                         
                         +'────────────────────── \n' 
                         +'TradingView chart slows down? 🔸 Reopen it!\n'
                         +'\n'                         
                         +'⚠️ Required setting: \n'
                         +'     In order to vertically align the Name tag.\n'
                         +'     ⚙︎ > Chart option > Canvas > Margins > \n'        
                         +'     Top: 0%   Bottom: 0%   Rights: 50bars\n'
                         +' \n\n' 
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//  INPUT
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
var _input_c_act = false  // force input.color enable
mobile_friendly_flg        = input.bool  (false,'📱', inline='ultravol_rescale'  ,group=GR_ULTRAVOL)
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
enum uv_source_mode
    auto        = 'Ultravol (Auto)'
    chart_force = 'Chart Vol (Force) check raw'
ultravol_source_mode_selector = input.enum(uv_source_mode.auto, '', inline='ultravol_rescale',group=GR_ULTRAVOL,active=false)
var ultravol_force_chartvol_flg = ultravol_source_mode_selector == uv_source_mode.chart_force
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
enum uv_rescale_mode
    plus2   = '▲ +2'
    plus1   = '▲ +1'
    neutral = '🌡️'
    minus1  = '▽ -1'
    minus2  = '▽ -2'
ultravol_rescale_mode_selector = input.enum(uv_rescale_mode.neutral, '', inline='ultravol_rescale',group=GR_ULTRAVOL
                             ,tooltip=GR_UV_ULTRAVOL_TT_VAL)
var ultravol_rescale_step = switch ultravol_rescale_mode_selector
    uv_rescale_mode.plus2 => 2.0
    uv_rescale_mode.plus1 => 1.0
    uv_rescale_mode.minus1 => -1.0
    uv_rescale_mode.minus2 => -2.0
    => 0.0
var ultravol_rescale_ratio = math.pow(2, -ultravol_rescale_step)
var string ultravol_rescale_mode_text = switch ultravol_rescale_mode_selector
    uv_rescale_mode.plus2  => '▲+2'
    uv_rescale_mode.plus1  => '▲+1'
    uv_rescale_mode.minus1 => '▽-1'
    uv_rescale_mode.minus2 => '▽-2'
    => '🌡️'
//-----------------------------------------------------------------------------------------------------------------------
// UV Spectrum Color
uvmx_flg = input.bool  (true ,"Ultravol Matrix 　　　　　(by UV scale)", inline='uv_ref_c0'  ,group=GR_ULTRAVOL_
                             ,tooltip=GR_UV_ULTRAVOL_TT2_VAL)
//-----------------------------------------------------------------------------------------------------------------------
uvmx_nametag_flg       = input.bool  (true  ,"Nametag　　　  　"   , inline='ultravol_1'  ,group=GR_ULTRAVOL_)
uvmx_nametag_l_flg     = (input.bool (false ,"L "                 , inline='ultravol_1'  ,group=GR_ULTRAVOL_ ,active=uvmx_nametag_flg and not mobile_friendly_flg) or mobile_friendly_flg) and uvmx_nametag_flg
uvmx_nametag_c_flg     = (input.bool (true  ,"C "                 , inline='ultravol_1'  ,group=GR_ULTRAVOL_ ,active=uvmx_nametag_flg and not mobile_friendly_flg) and not mobile_friendly_flg) and uvmx_nametag_flg
uvmx_nametag_r_flg     = input.bool  (true  ,"R "                 , inline='ultravol_1'  ,group=GR_ULTRAVOL_ ,active=uvmx_nametag_flg) and uvmx_nametag_flg
//-----------------------------------------------------------------------------------------------------------------------
uv_spectrum_7_color     = input.color (#8400ff ,'　　  L7 ~ L4'  ,inline='uv_ref_c1', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_6_color     = input.color (#0048ff ,''              ,inline='uv_ref_c1', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_5_color     = input.color (#0b9ed0 ,''              ,inline='uv_ref_c1', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_4_color     = input.color (#c0ccff ,''              ,inline='uv_ref_c1', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_3_color     = input.color (#c0a000 ,'　　  L3 ~ L0'  ,inline='uv_ref_c2', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_2_color     = input.color (#c65d10 ,''              ,inline='uv_ref_c2', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_1_color     = input.color (#aa1913 ,''              ,inline='uv_ref_c2', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_reg_color   = input.color (#66001b ,''              ,inline='uv_ref_c2', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_low_color   = input.color (#30323a ,'　　  Sub ~ 0' ,inline='uv_ref_c3', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_sub_color   = input.color (#1e1a33 ,''        ,inline='uv_ref_c3', group=GR_ULTRAVOL_ ,active=_input_c_act)
uv_spectrum_zero_color  = input.color (#000000 ,''        ,inline='uv_ref_c3', group=GR_ULTRAVOL_ ,active=_input_c_act)
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
uvmx_bg_flg             = input.bool  (true ,"Background　   　　　　　　　", inline='ultravol_mm'           )
uvmx_pairbegins_flg     = input.bool  (true ,"🦕", inline='ultravol_mm'         , tooltip=GR_TT_PB           )
g1_fill_color_n = input.color (color.new(#0020f0,70) ,"　　　　　    　",   inline='ultravol_0'  ,active=_input_c_act )
g2_fill_color_n = input.color (color.new(#c80040,70) ,"",  inline='ultravol_0'     ,active=_input_c_act )
g3_fill_color_n = input.color (color.new(#00b000,70) ,"",  inline='ultravol_0'     ,active=_input_c_act )
g4_fill_color_n = input.color (color.new(#000000,70) ,"",  inline='ultravol_0'     ,active=_input_c_act )
var g1_fill_color     = color.new(g1_fill_color_n, 88) 
var g2_fill_color     = color.new(g2_fill_color_n, 90) 
var g3_fill_color     = color.new(g3_fill_color_n, 93) 
var g4_fill_color     = color.new(g4_fill_color_n,100) 
matrix_extension    = input.bool  (true  ,"Ultravol Matrix  -  Live guide meter", inline='ultravol_110'  ,group=GR_EXT_)
//-----------------------------------------------------------------------------------------------------------------------
uvmx_nametag2_flg    = input.bool  (true  ,"Nametag (for live guide meter)", inline='ultravol_111'  ,group=GR_EXT_ ,active=matrix_extension) and matrix_extension
// ultravol level ratio
const float ULTRAVOL_LEVEL_RATIO_G_VAL          = 55.0
const float ULTRAVOL_LEVEL_RATIO_F_VAL          = 34.0
const float ULTRAVOL_LEVEL_RATIO_E_VAL          = 19.0 
const float ULTRAVOL_LEVEL_RATIO_D_VAL          = 12.0
const float ULTRAVOL_LEVEL_RATIO_C_VAL          = 7.2
const float ULTRAVOL_LEVEL_RATIO_B_VAL          = 4.1
const float ULTRAVOL_LEVEL_RATIO_A_VAL          = 2.3
const float ULTRAVOL_LEVEL_RATIO_LOW_VAL        = 1.5
const float ULTRAVOL_LEVEL_RATIO_MEANLESS_VAL   = 0.725 
//--------------------------------------------------------------------------------------------------------------

























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
    if uv_volmode_ultravol_update_task_flg or uv_volmode_chartvol_task_flg
        uv_chartvol_accum    += nz(uv_chartvol)                           
        uv_chartvol_mrktmean := (uv_chartvol_accum/math.max(1,bar_index)) * ultravol_rescale_ratio 
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
        v_s1_mrktmean := (v_s1_accum/math.max(1,bar_index - v_s1_begin)) * ultravol_rescale_ratio   
        v_s2_mrktmean := (v_s2_accum/math.max(1,bar_index - v_s2_begin)) * ultravol_rescale_ratio   
        v_s3_mrktmean := (v_s3_accum/math.max(1,bar_index - v_s3_begin)) * ultravol_rescale_ratio   
        v_s4_mrktmean := (v_s4_accum/math.max(1,bar_index - v_s4_begin)) * ultravol_rescale_ratio   
        v_s5_mrktmean := (v_s5_accum/math.max(1,bar_index - v_s5_begin)) * ultravol_rescale_ratio   
        v_s6_mrktmean := (v_s6_accum/math.max(1,bar_index - v_s6_begin)) * ultravol_rescale_ratio   
        v_s7_mrktmean := (v_s7_accum/math.max(1,bar_index - v_s7_begin)) * ultravol_rescale_ratio   
        v_s8_mrktmean := (v_s8_accum/math.max(1,bar_index - v_s8_begin)) * ultravol_rescale_ratio   
        v_p1_mrktmean := (v_p1_accum/math.max(1,bar_index - v_p1_begin)) * ultravol_rescale_ratio   
        v_p2_mrktmean := (v_p2_accum/math.max(1,bar_index - v_p2_begin)) * ultravol_rescale_ratio   
        v_p3_mrktmean := (v_p3_accum/math.max(1,bar_index - v_p3_begin)) * ultravol_rescale_ratio   
        v_p4_mrktmean := (v_p4_accum/math.max(1,bar_index - v_p4_begin)) * ultravol_rescale_ratio   
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

 






































//🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪
//  DISPLAY
//🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪🟪


const bool _PANE_ = false
f_display(_bool_, _all_pane_sw = true) =>
    _result = _bool_ ? _all_pane_sw ? display.all:display.pane:display.none

f_display_fill(_bool_) =>
    _result = _bool_ ? display.all:display.none

// 🟩🟩🟩🟩🟩🟩🟩
//  UVMX
// 🟩🟩🟩🟩🟩🟩🟩

const bool UVMX_GAP_SW   = true 

const float UVMX_SLOT_HEIGHT    = 10
const float S1_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 1  : 1 )
const float S2_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 2  : 2 )
const float S3_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 3  : 3 )
const float S4_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 4  : 4 )
const float S5_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 6  : 5 )
const float S6_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 7  : 6 )
const float S7_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 8  : 7 )
const float S8_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 9  : 8 )
const float P1_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 11 : 9 )
const float P2_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 12 : 10)
const float P3_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 13 : 11)
const float P4_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 14 : 12)
const float CV_HISTBASE = -UVMX_SLOT_HEIGHT * (UVMX_GAP_SW ? 16 : 13)

//- - - - - - - - - - - - - - - - - - - - 
const string CHART_MARK      = '🔹' 
const string CHART_MARK_NULL = ''   
//- - - - - - - - - - - - - - - - - - - - 

f_chartvol_mark(_tickerid) =>
    string _result = ''
    if _tickerid != '-' or _tickerid != ''
        string _up_sym_tickerid  = str.upper(_tickerid)
        if (uv_chart_tikerid_str == _up_sym_tickerid)  
           or ( syminfo.prefix == 'COINBASE'
                and str.substring(uv_chart_tikerid_str, 0 ,str.length(uv_chart_tikerid_str)-1) == _up_sym_tickerid )
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
    string _tkr_head_       = f_crypto_symbol_corekey(_tickerid, syminfo.basecurrency)      
    string _tkr_tails_      = str.replace(_SYMBOL_VAL_, _tkr_head_, '')                     
    string _tkr_head_1short = str.substring(_tkr_head_, 0 ,str.length(_tkr_head_)-1)        
    //
    string _result          = _SYMBOL_VAL_
    if _tkr_pre_ == 'COINBASE' and _tkr_head_ != 'USD' and _tkr_head_1short != 'USD'
        _result := switch 
            str.endswith(_tkr_tails_, 'USD')    => str.replace(_SYMBOL_VAL_, 'USD'  ,'USD (+C)')
            str.endswith(_tkr_tails_, 'USDC')   => str.replace(_SYMBOL_VAL_, 'USDC' ,'USD (+C)')
            => _SYMBOL_VAL_
    //
    _result := f_crypto_symbol_compact_10x(_result) + f_chartvol_mark(_tickerid)


f_chartvol_color(_sym_tickerid,_reg_color, _chartvol_color) =>
    color _result = na
    if _sym_tickerid != '-' 
        string _tkr_             = ticker.standard(syminfo.tickerid)
        string _up_sym_tickerid  = str.upper(_sym_tickerid)
        bool   _charvol_same = (_tkr_ == _up_sym_tickerid) 
                             or ( str.substring(_tkr_, 0 ,str.pos(_tkr_, ":"))     == 'COINBASE'
                                  and str.substring(_tkr_, 0 ,str.length(_tkr_)-1) == _up_sym_tickerid )        
        _result := _charvol_same ? _reg_color : _chartvol_color

f_str_trim_lastnewline(_strline) =>
    string _result = na
    if str.endswith(_strline,'\n')
        _result := str.substring(_strline, 0, str.length(_strline)-1) 
    else 
        _result := _strline
    _result

gf_uv_matrix(_active, _vol, _mean, _histbase) => 
    float _uvmx_high       = na
    float _uvmx_low        = na
    int _uv_level_state   = na
    //------------------------------------------
    if _active
        _uv_level_state := f_src_uv_leveling(_vol, _mean)            // UV level
        float _waveheight   = math.max(0.03, math.min(4.6, (math.pow( _vol / _mean , 0.6))*0.70) - 0.7)   // v1.72

        if _uv_level_state == -3        // volume 0
            if barstate.isconfirmed     
                _waveheight := 2        // bar confirmed
            else 
                _waveheight := 1        // bar realtime
        _uvmx_high   := _histbase + _waveheight 
        _uvmx_low    := _histbase - _waveheight   
    [_uv_level_state, _uvmx_high, _uvmx_low]



//🟪🟪🟪🟪🟪🟪🟪
//🟪 MATRIX
//🟪🟪🟪🟪🟪🟪🟪
//

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────
//🟪 UVMX vol bars  
varip color s1_color_x = na
varip color s2_color_x = na
varip color s3_color_x = na
varip color s4_color_x = na
varip color s5_color_x = na
varip color s6_color_x = na
varip color s7_color_x = na
varip color s8_color_x = na
varip color p1_color_x = na
varip color p2_color_x = na
varip color p3_color_x = na
varip color p4_color_x = na
varip color cv_color_x = na

[s1_uv_lv ,s1_h ,s1_l] = gf_uv_matrix(v_s1_works     ,v_s1.vol    ,v_s1_mrktmean         ,S1_HISTBASE)
[s2_uv_lv ,s2_h ,s2_l] = gf_uv_matrix(v_s2_works     ,v_s2.vol    ,v_s2_mrktmean         ,S2_HISTBASE)
[s3_uv_lv ,s3_h ,s3_l] = gf_uv_matrix(v_s3_works     ,v_s3.vol    ,v_s3_mrktmean         ,S3_HISTBASE)
[s4_uv_lv ,s4_h ,s4_l] = gf_uv_matrix(v_s4_works     ,v_s4.vol    ,v_s4_mrktmean         ,S4_HISTBASE)
[s5_uv_lv ,s5_h ,s5_l] = gf_uv_matrix(v_s5_works     ,v_s5.vol    ,v_s5_mrktmean         ,S5_HISTBASE)
[s6_uv_lv ,s6_h ,s6_l] = gf_uv_matrix(v_s6_works     ,v_s6.vol    ,v_s6_mrktmean         ,S6_HISTBASE)
[s7_uv_lv ,s7_h ,s7_l] = gf_uv_matrix(v_s7_works     ,v_s7.vol    ,v_s7_mrktmean         ,S7_HISTBASE)
[s8_uv_lv ,s8_h ,s8_l] = gf_uv_matrix(v_s8_works     ,v_s8.vol    ,v_s8_mrktmean         ,S8_HISTBASE)
[p1_uv_lv ,p1_h ,p1_l] = gf_uv_matrix(v_p1_works     ,v_p1.vol    ,v_p1_mrktmean         ,P1_HISTBASE)
[p2_uv_lv ,p2_h ,p2_l] = gf_uv_matrix(v_p2_works     ,v_p2.vol    ,v_p2_mrktmean         ,P2_HISTBASE)
[p3_uv_lv ,p3_h ,p3_l] = gf_uv_matrix(v_p3_works     ,v_p3.vol    ,v_p3_mrktmean         ,P3_HISTBASE)
[p4_uv_lv ,p4_h ,p4_l] = gf_uv_matrix(v_p4_works     ,v_p4.vol    ,v_p4_mrktmean         ,P4_HISTBASE)
[cv_uv_lv ,cv_h ,cv_l] = gf_uv_matrix(not uv_volmode_novol_task_flg and (chartvol_indi_in_panel_flg or uv_volmode_chartvol_task_flg)
                                                     ,uv_chartvol ,uv_chartvol_mrktmean  ,CV_HISTBASE)


if barstate.isnew
    s1_color_x  := COLOR_BLACK
    s2_color_x  := COLOR_BLACK
    s3_color_x  := COLOR_BLACK
    s4_color_x  := COLOR_BLACK
    s5_color_x  := COLOR_BLACK
    s6_color_x  := COLOR_BLACK
    s7_color_x  := COLOR_BLACK
    s8_color_x  := COLOR_BLACK
    p1_color_x  := COLOR_BLACK
    p2_color_x  := COLOR_BLACK
    p3_color_x  := COLOR_BLACK
    p4_color_x  := COLOR_BLACK
    if not uv_volmode_novol_task_flg and (chartvol_indi_in_panel_flg or uv_volmode_chartvol_task_flg)
        cv_color_x  := COLOR_BLACK

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
    if not uv_volmode_novol_task_flg and chartvol_indi_in_panel_flg
        cv_color_x  := f_src_uv_lv_coloring(cv_uv_lv)

if uv_MasterGATEopen_flg and uv_volmode_chartvol_task_flg
    if not uv_volmode_novol_task_flg
        cv_color_x  := f_src_uv_lv_coloring(cv_uv_lv)


//-----------------------------------------------------------------------------------------
const float G0_TOP =    0 //------------------ 
const float G1_H   =   -3
const float G1_L   =  -47
const float G12_C  =  -50 //------------------ 
const float G2_H   =  -53
const float G2_L   =  -97
const float G23_C  = -100 //------------------ 
const float G3_H   = -103
const float G3_L   = -147
const float G4_BTM = -150 //------------------ 
const float G4_H   = -153
const float G4_L   = -167  
const float G4_BTM_ALT = -170
//-----------------------------------------------------------------------------------------
// matrix BG
// var g0_hline_top = hline(G0_TOP   ,color=COLOR_TRANSP                         ,editable=false)
var g0_hline_top = plot (uv_volmode_ultravol_task_flg? G0_TOP:na   ,color=COLOR_TRANSP                         ,editable=false)
var g1_hline_h   = hline(G1_H     ,color=COLOR_TRANSP, display=display.none   ,editable=false)
var g1_hline_l   = hline(G1_L     ,color=COLOR_TRANSP, display=display.none   ,editable=false)
var g2_hline_h   = hline(G2_H     ,color=COLOR_TRANSP, display=display.none   ,editable=false)
var g2_hline_l   = hline(G2_L     ,color=COLOR_TRANSP, display=display.none   ,editable=false)
var g3_hline_h   = hline(G3_H     ,color=COLOR_TRANSP, display=display.none   ,editable=false)
var g3_hline_l   = hline(G3_L     ,color=COLOR_TRANSP, display=display.none   ,editable=false)
// edge case: indi_in_flg -> additional lane at bottom 
var g4_hline_h   = plot (chartvol_indi_in_panel_flg or (uv_volmode_chartvol_task_flg and not uv_volmode_ultravol_candidate_task_flg) ? G4_H:na   ,color=COLOR_TRANSP, display=display.none   ,editable=false)
var g4_hline_l   = plot (chartvol_indi_in_panel_flg or (uv_volmode_chartvol_task_flg and not uv_volmode_ultravol_candidate_task_flg) ? G4_L:na   ,color=COLOR_TRANSP, display=display.none   ,editable=false)
 
// BG fill
fill(g1_hline_h, g1_hline_l, color=uv_volmode_ultravol_task_flg? g1_fill_color:na, title='G1',editable=false ,display=f_display_fill(uvmx_bg_flg))
fill(g2_hline_h, g2_hline_l, color=uv_volmode_ultravol_task_flg? g2_fill_color:na, title='G2',editable=false ,display=f_display_fill(uvmx_bg_flg))
fill(g3_hline_h, g3_hline_l, color=uv_volmode_ultravol_task_flg? g3_fill_color:na, title='G3',editable=false ,display=f_display_fill(uvmx_bg_flg))
fill(g4_hline_h, g4_hline_l, color=chartvol_indi_in_panel_flg ? g4_fill_color :na, title='G4',editable=false ,display=f_display_fill(uvmx_bg_flg))

// BG BOTTOM limit 
float g4_btm_position = uv_volmode_chartvol_task_flg? G4_L : chartvol_indi_in_panel_flg ? G4_BTM_ALT : G4_BTM  // charvol : indi_in : ultravol
plot(g4_btm_position, 'BTM limit line', color=COLOR_TRANSP, editable=false, display=display.pane)

plot(s1_h ,'UV Bars' ,color=s1_color_x ,histbase=S1_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s2_h ,'UV Bars' ,color=s2_color_x ,histbase=S2_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s3_h ,'UV Bars' ,color=s3_color_x ,histbase=S3_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s4_h ,'UV Bars' ,color=s4_color_x ,histbase=S4_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s5_h ,'UV Bars' ,color=s5_color_x ,histbase=S5_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s6_h ,'UV Bars' ,color=s6_color_x ,histbase=S6_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s7_h ,'UV Bars' ,color=s7_color_x ,histbase=S7_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s8_h ,'UV Bars' ,color=s8_color_x ,histbase=S8_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p1_h ,'UV Bars' ,color=p1_color_x ,histbase=P1_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p2_h ,'UV Bars' ,color=p2_color_x ,histbase=P2_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p3_h ,'UV Bars' ,color=p3_color_x ,histbase=P3_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p4_h ,'UV Bars' ,color=p4_color_x ,histbase=P4_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))

plot(s1_l ,'UV Bars' ,color=s1_color_x ,histbase=S1_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s2_l ,'UV Bars' ,color=s2_color_x ,histbase=S2_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s3_l ,'UV Bars' ,color=s3_color_x ,histbase=S3_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s4_l ,'UV Bars' ,color=s4_color_x ,histbase=S4_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s5_l ,'UV Bars' ,color=s5_color_x ,histbase=S5_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s6_l ,'UV Bars' ,color=s6_color_x ,histbase=S6_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s7_l ,'UV Bars' ,color=s7_color_x ,histbase=S7_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(s8_l ,'UV Bars' ,color=s8_color_x ,histbase=S8_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p1_l ,'UV Bars' ,color=p1_color_x ,histbase=P1_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p2_l ,'UV Bars' ,color=p2_color_x ,histbase=P2_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p3_l ,'UV Bars' ,color=p3_color_x ,histbase=P3_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(p4_l ,'UV Bars' ,color=p4_color_x ,histbase=P4_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))

plot(cv_h ,'Chart vol UV Bars' ,color=cv_color_x ,histbase=CV_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))
plot(cv_l ,'Chart vol UV Bars' ,color=cv_color_x ,histbase=CV_HISTBASE ,linewidth=4 ,style=plot.style_histogram ,editable=false, display=f_display(uvmx_flg,_PANE_))


//🟪🟪🟪🟪🟪🟪🟪
//🟪 Extension
//🟪🟪🟪🟪🟪🟪🟪

// extension 
const int MATRIX_EXT_START      = 3
const int MATRIX_EXT_END        = MATRIX_EXT_START + 18
varip int matrix_ext_vol_start  = na
varip int matrix_ext_vol_end    = na

if barstate.islastconfirmedhistory or (barstate.islast and barstate.isnew)
    matrix_ext_vol_start    := bar_index + MATRIX_EXT_START
    matrix_ext_vol_end      := bar_index + MATRIX_EXT_END

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Extension S1 ~ P4
var line     line_s1_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s2_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s3_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s4_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s5_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s6_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s7_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s8_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p1_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p2_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p3_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p4_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)

var line     line_s1_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s2_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s3_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s4_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s5_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s6_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s7_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_s8_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p1_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p2_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p3_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_p4_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)

var linefill lf_s1 = linefill.new(line_s1_h ,line_s1_l ,color=COLOR_TRANSP)
var linefill lf_s2 = linefill.new(line_s2_h ,line_s2_l ,color=COLOR_TRANSP)
var linefill lf_s3 = linefill.new(line_s3_h ,line_s3_l ,color=COLOR_TRANSP)
var linefill lf_s4 = linefill.new(line_s4_h ,line_s4_l ,color=COLOR_TRANSP)
var linefill lf_s5 = linefill.new(line_s5_h ,line_s5_l ,color=COLOR_TRANSP)
var linefill lf_s6 = linefill.new(line_s6_h ,line_s6_l ,color=COLOR_TRANSP)
var linefill lf_s7 = linefill.new(line_s7_h ,line_s7_l ,color=COLOR_TRANSP)
var linefill lf_s8 = linefill.new(line_s8_h ,line_s8_l ,color=COLOR_TRANSP)
var linefill lf_p1 = linefill.new(line_p1_h ,line_p1_l ,color=COLOR_TRANSP)
var linefill lf_p2 = linefill.new(line_p2_h ,line_p2_l ,color=COLOR_TRANSP)
var linefill lf_p3 = linefill.new(line_p3_h ,line_p3_l ,color=COLOR_TRANSP)
var linefill lf_p4 = linefill.new(line_p4_h ,line_p4_l ,color=COLOR_TRANSP)

var line     line_cv_h = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var line     line_cv_l = line.new(bar_index ,na ,bar_index ,na, color=COLOR_TRANSP)
var linefill lf_cv = not chartvol_indi_in_panel_flg ? linefill.new(na,na,na) : linefill.new(line_cv_h ,line_cv_l ,color=COLOR_TRANSP)

const float _START_WT = 0.16
const float _END_WT   = 0.7
if matrix_extension and barstate.islast

    line.set_xy1(line_s1_h ,matrix_ext_vol_start ,s1_h-_START_WT), line.set_xy2(line_s1_h ,matrix_ext_vol_end ,s1_h+_END_WT)  
    line.set_xy1(line_s2_h ,matrix_ext_vol_start ,s2_h-_START_WT), line.set_xy2(line_s2_h ,matrix_ext_vol_end ,s2_h+_END_WT)  
    line.set_xy1(line_s3_h ,matrix_ext_vol_start ,s3_h-_START_WT), line.set_xy2(line_s3_h ,matrix_ext_vol_end ,s3_h+_END_WT)  
    line.set_xy1(line_s4_h ,matrix_ext_vol_start ,s4_h-_START_WT), line.set_xy2(line_s4_h ,matrix_ext_vol_end ,s4_h+_END_WT)  
    line.set_xy1(line_s5_h ,matrix_ext_vol_start ,s5_h-_START_WT), line.set_xy2(line_s5_h ,matrix_ext_vol_end ,s5_h+_END_WT)  
    line.set_xy1(line_s6_h ,matrix_ext_vol_start ,s6_h-_START_WT), line.set_xy2(line_s6_h ,matrix_ext_vol_end ,s6_h+_END_WT)  
    line.set_xy1(line_s7_h ,matrix_ext_vol_start ,s7_h-_START_WT), line.set_xy2(line_s7_h ,matrix_ext_vol_end ,s7_h+_END_WT)  
    line.set_xy1(line_s8_h ,matrix_ext_vol_start ,s8_h-_START_WT), line.set_xy2(line_s8_h ,matrix_ext_vol_end ,s8_h+_END_WT)  
    line.set_xy1(line_p1_h ,matrix_ext_vol_start ,p1_h-_START_WT), line.set_xy2(line_p1_h ,matrix_ext_vol_end ,p1_h+_END_WT)  
    line.set_xy1(line_p2_h ,matrix_ext_vol_start ,p2_h-_START_WT), line.set_xy2(line_p2_h ,matrix_ext_vol_end ,p2_h+_END_WT)  
    line.set_xy1(line_p3_h ,matrix_ext_vol_start ,p3_h-_START_WT), line.set_xy2(line_p3_h ,matrix_ext_vol_end ,p3_h+_END_WT)  
    line.set_xy1(line_p4_h ,matrix_ext_vol_start ,p4_h-_START_WT), line.set_xy2(line_p4_h ,matrix_ext_vol_end ,p4_h+_END_WT)  
    
    line.set_xy1(line_s1_l ,matrix_ext_vol_start ,s1_l+_START_WT), line.set_xy2(line_s1_l ,matrix_ext_vol_end ,s1_l-_END_WT)  
    line.set_xy1(line_s2_l ,matrix_ext_vol_start ,s2_l+_START_WT), line.set_xy2(line_s2_l ,matrix_ext_vol_end ,s2_l-_END_WT)  
    line.set_xy1(line_s3_l ,matrix_ext_vol_start ,s3_l+_START_WT), line.set_xy2(line_s3_l ,matrix_ext_vol_end ,s3_l-_END_WT)  
    line.set_xy1(line_s4_l ,matrix_ext_vol_start ,s4_l+_START_WT), line.set_xy2(line_s4_l ,matrix_ext_vol_end ,s4_l-_END_WT)  
    line.set_xy1(line_s5_l ,matrix_ext_vol_start ,s5_l+_START_WT), line.set_xy2(line_s5_l ,matrix_ext_vol_end ,s5_l-_END_WT)  
    line.set_xy1(line_s6_l ,matrix_ext_vol_start ,s6_l+_START_WT), line.set_xy2(line_s6_l ,matrix_ext_vol_end ,s6_l-_END_WT)  
    line.set_xy1(line_s7_l ,matrix_ext_vol_start ,s7_l+_START_WT), line.set_xy2(line_s7_l ,matrix_ext_vol_end ,s7_l-_END_WT)  
    line.set_xy1(line_s8_l ,matrix_ext_vol_start ,s8_l+_START_WT), line.set_xy2(line_s8_l ,matrix_ext_vol_end ,s8_l-_END_WT)  
    line.set_xy1(line_p1_l ,matrix_ext_vol_start ,p1_l+_START_WT), line.set_xy2(line_p1_l ,matrix_ext_vol_end ,p1_l-_END_WT)  
    line.set_xy1(line_p2_l ,matrix_ext_vol_start ,p2_l+_START_WT), line.set_xy2(line_p2_l ,matrix_ext_vol_end ,p2_l-_END_WT)  
    line.set_xy1(line_p3_l ,matrix_ext_vol_start ,p3_l+_START_WT), line.set_xy2(line_p3_l ,matrix_ext_vol_end ,p3_l-_END_WT)  
    line.set_xy1(line_p4_l ,matrix_ext_vol_start ,p4_l+_START_WT), line.set_xy2(line_p4_l ,matrix_ext_vol_end ,p4_l-_END_WT)  

    linefill.set_color(lf_s1 ,s1_color_x)
    linefill.set_color(lf_s2 ,s2_color_x)
    linefill.set_color(lf_s3 ,s3_color_x)
    linefill.set_color(lf_s4 ,s4_color_x)
    linefill.set_color(lf_s5 ,s5_color_x)
    linefill.set_color(lf_s6 ,s6_color_x)
    linefill.set_color(lf_s7 ,s7_color_x)
    linefill.set_color(lf_s8 ,s8_color_x)
    linefill.set_color(lf_p1 ,p1_color_x)
    linefill.set_color(lf_p2 ,p2_color_x)
    linefill.set_color(lf_p3 ,p3_color_x)
    linefill.set_color(lf_p4 ,p4_color_x)

    if chartvol_indi_in_panel_flg
        line.set_xy1(line_cv_h ,matrix_ext_vol_start ,cv_h-_START_WT), line.set_xy2(line_cv_h ,matrix_ext_vol_end ,cv_h+_END_WT)  
        line.set_xy1(line_cv_l ,matrix_ext_vol_start ,cv_l+_START_WT), line.set_xy2(line_cv_l ,matrix_ext_vol_end ,cv_l-_END_WT)  
        linefill.set_color(lf_cv ,cv_color_x)


//🟪🟪🟪🟪🟪🟪🟪
//🟪 Exchange name - label
//🟪🟪🟪🟪🟪🟪🟪
//🟪
//🟪 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────

//──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
//  NAME TAG (pinned),  NAME TAG (extension),    PAIR BEGINS (raw vol src symbol start)
//──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

//-----------------------
// PAIR BEGINS setup
const int PAIRBEGINS_SIZE       = 15
const int PAIRBEGINS_X_OFFSET   = 5
const int PAIRBEGINS_Y_OFFSET   = -4
const string PAIRBEGINS_STYLE   = label.style_none

//-----------------------
// NAME TAG (pinned, for extension) setup
const color UVMX_CV_TAG     = color.new(#33a2ff,0)        // pinned Chartvol color
const color UVMX_C1_TAG     = color.new(#b6b6e0,0)        // pinned
const color UVMX_C2_TAG     = color.new(#caa0b0,0)        // pinned
const color UVMX_C3_TAG     = color.new(#b0b089,0)        // pinned
const color UVMX_BG_C       = color.new(#000000,20)       // pinned BLACK transp BG

const color UVMX_CV_lbl     = color.new(UVMX_CV_TAG,0)     // for extension lable Chartvol color
const color UVMX_C1_lbl     = color.new(UVMX_C1_TAG,20)     // for extension lable
const color UVMX_C2_lbl     = color.new(UVMX_C2_TAG,20)     // for extension lable
const color UVMX_C3_lbl     = color.new(UVMX_C3_TAG,20)     // for extension lable

const float UVMX_TAG_TOP_HEIGHT = 3.0                       //      //  5.5
const float UVMX_TAG_BTM_HEIGHT = 4.0                       //      //  6.0
const float UVMX_TAG_H15    = (10/150)*100 * (1.081)    //      // (10/150)*100 * 1.081
const float UVMX_TAG_H17    = (10/170)*100 * (1.081)    //      // (10/150)*100 * 1.081
float   uvmx_tag_height = chartvol_indi_in_panel_flg ? UVMX_TAG_H17 : UVMX_TAG_H15

const string UVMX_TAG_TXT_ALIGN = text.align_left           // pinned   
var int uvmx_tag_txt_size = 10                              // pinned text size

varip string s1_text = '',                                  // pinned, ext common 
varip string s2_text = '',  varip string s2_text_alt = ''   // pinned only, ext only
varip string s3_text = '',                                  // pinned, ext common 
varip string s4_text = '',                                  // pinned, ext common 
varip string s5_text = '',                                  // pinned, ext common 
varip string s6_text = '',                                  // pinned, ext common 
varip string s7_text = '',                                  // pinned, ext common 
varip string s8_text = '',                                  // pinned, ext common 
varip string p1_text = '',                                  // pinned, ext common 
varip string p2_text = '',                                  // pinned, ext common 
varip string p3_text = '',                                  // pinned, ext common 
varip string p4_text = '',                                  // pinned, ext common 
varip string uvmx_tooltip = ''

const string cv_text = CHART_MARK,                                  // pinned, ext common 

//----------------------------------------------------
// NAME TAG (for extension)     label setting
const color  MATRIX_LABEL_COLOR     = color.new(#666666,0)
const float  MATRIX_LABEL_Y         = -4
const int    MATRIX_LABEL_TXT_SIZE  = 10
const string MATRIX_LABEL_TXT_ALIGN = text.align_left
const string MATRIX_LABEL_STYLE     = label.style_none
//
var label matrix_label_s1 = label.new(na, S1_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C1_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s2 = label.new(na, S2_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C1_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s3 = label.new(na, S3_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C1_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s4 = label.new(na, S4_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C1_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s5 = label.new(na, S5_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C2_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s6 = label.new(na, S6_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C2_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s7 = label.new(na, S7_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C2_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_s8 = label.new(na, S8_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C2_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_p1 = label.new(na, P1_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C3_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_p2 = label.new(na, P2_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C3_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_p3 = label.new(na, P3_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C3_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_p4 = label.new(na, P4_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_C3_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)
var label matrix_label_cv = label.new(na, CV_HISTBASE+MATRIX_LABEL_Y,textcolor=UVMX_CV_lbl, color=COLOR_TRANSP
                              ,textalign=MATRIX_LABEL_TXT_ALIGN ,size=MATRIX_LABEL_TXT_SIZE ,style=MATRIX_LABEL_STYLE)

//----------------------------------------------------
// NAMETAG  (pinned)       table setting
var table uvmx_name_l  = table.new(position.middle_left  ,2, 18, bgcolor=COLOR_TRANSP, frame_color=COLOR_TRANSP, frame_width=0
                           ,border_color=COLOR_TRANSP, border_width=0)
var table uvmx_name_r  = table.new(position.middle_right ,1, 18, bgcolor=COLOR_TRANSP, frame_color=COLOR_TRANSP, frame_width=0
                           ,border_color=COLOR_TRANSP, border_width=0)
var table uvmx_name_c  = table.new(position.middle_center,1, 18, bgcolor=COLOR_TRANSP, frame_color=COLOR_TRANSP, frame_width=0
                           ,border_color=COLOR_TRANSP, border_width=0)
if barstate.isfirst and uv_volmode_ultravol_task_flg
    if uvmx_nametag_l_flg
        table.cell(uvmx_name_l, 0, 0, text='          '      ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT) 
        table.cell(uvmx_name_l, 0,15                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)
        table.cell(uvmx_name_l, 0,16                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
        table.cell(uvmx_name_l, 0,17                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
        //
        table.cell(uvmx_name_l, 1, 0                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT) 
        table.cell(uvmx_name_l, 1, 1, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 2, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 3, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 4, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 5                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 6, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 7, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 8, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1, 9, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,10                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,11, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,12, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,13, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,14, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,15                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)
        table.cell(uvmx_name_l, 1,16                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
        table.cell(uvmx_name_l, 1,17                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
    if uvmx_nametag_r_flg
        table.cell(uvmx_name_r, 0, 0                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT) 
        table.cell(uvmx_name_r, 0, 1, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 2, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 3, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 4, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 5                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 6, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 7, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 8, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0, 9, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,10                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,11, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,12, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,13, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,14, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,15                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)
        table.cell(uvmx_name_r, 0,16                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
        table.cell(uvmx_name_r, 0,17                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
    if uvmx_nametag_c_flg
        table.cell(uvmx_name_c, 0, 0                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT) 
        table.cell(uvmx_name_c, 0, 1, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 2, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 3, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 4, text_color=UVMX_C1_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 5                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 6, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 7, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 8, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0, 9, text_color=UVMX_C2_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,10                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,11, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,12, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,13, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,14, text_color=UVMX_C3_TAG ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,15                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)
        table.cell(uvmx_name_c, 0,16                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
        table.cell(uvmx_name_c, 0,17                         ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=0.0001)
//----------------------------------------------------------
if (uv_volmode_ultravol_task_flg and uv_src_updated_now_flg)    
  or ((chartvol_indi_in_panel_flg or uv_volmode_chartvol_task_flg) and (barstate.isfirst or barstate.islastconfirmedhistory))      
    uvmx_tooltip := '\nUV Matrix\n'     // ⟡✦🔸🌗🌖🍥🥶🔵🟣\n'   
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
          + (chartvol_indi_in_panel_flg ? '──────────────\n'+ticker.standard(syminfo.tickerid) + CHART_MARK +'\n':'')
          + '──────────────\n'
          + (uv_volmode_ultravol_candidate_task_flg and chart_not_included_in_pool_flg ? 
              '⚠️  Chart is not in vol-src pool\n'
             +'　 and no data across the pool\n'  
             +'➔ Fallback [Chart Vol] mode\n\n' :'') 
          + (uv_volmode_ultravol_candidate_task_flg and not chart_not_included_in_pool_flg ? 
              '⚠️　Chart is in vol-src pool, but\n'
             +'  the pool has no data for the \n' 
             +'  current low TF at this position.\n'  
             +'➔ Fallback [Chart Vol] mode\n\n'   :'')
          + (uv_volmode_ultravol_task_flg and chart_not_included_in_pool_flg ? 
              'Chart is not in vol-src pool\n'
             +'But the pool data covers it\n\n' 
                 : '')  
          + (uv_volmode_ultravol_task_flg ? 
              "✨ [UV Matrix] synthesized.\n"
             +'     [' + str.tostring(uv_works_spot_count) + ' Spot, ' + str.tostring(uv_works_perp_count) + ' Perp' 
             +(chart_not_included_in_pool_flg ? ', Chart' + CHART_MARK +']': ']')
             +'\n\n' 
             +'Spike flow patterns can be \ncompared across history.\n[Rescale to read extremes.]\n\n' 
                 : '')    
          + ''  

if (uv_volmode_ultravol_task_flg or uv_volmode_chartvol_task_flg) and (uv_src_updated_now_flg or barstate.isfirst or barstate.islastconfirmedhistory) 
    if bar_index == v_s1_begin
        s1_text := ' Bn'
        _tag_color = f_chartvol_color(uv_sym_s1, UVMX_CV_TAG, UVMX_C1_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s1, UVMX_CV_lbl, UVMX_C1_lbl)
        label.set_text(matrix_label_s1, s1_text), label.set_textcolor(matrix_label_s1, _lbl_color)
        var s1_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S1_HISTBASE +PAIRBEGINS_Y_OFFSET,'🐢' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 0, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT)
            table.cell(uvmx_name_l, 1, 1, text=s1_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 0, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT)
            table.cell(uvmx_name_r, 0, 1, text=s1_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 0, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_TOP_HEIGHT)
            table.cell(uvmx_name_c, 0, 1, text=s1_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s2_begin
        s2_text := ' Bn′',  s2_text_alt:= '  Bn′'
        _tag_color = f_chartvol_color(uv_sym_s2, UVMX_CV_TAG, UVMX_C1_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s2, UVMX_CV_lbl, UVMX_C1_lbl)
        // Bn 뒤쪽 문자때문에 수평 정렬 흐트러짐 -> alt text 사용
        label.set_text(matrix_label_s2, s2_text_alt), label.set_textcolor(matrix_label_s2, _lbl_color)
        var s2_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S2_HISTBASE +PAIRBEGINS_Y_OFFSET,'🐢' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 2, text=s2_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 2, text=s2_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 2, text=s2_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s3_begin
        s3_text := ' Co'
        _tag_color = f_chartvol_color(uv_sym_s3, UVMX_CV_TAG, UVMX_C1_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s3, UVMX_CV_lbl, UVMX_C1_lbl)
        label.set_text(matrix_label_s3, s3_text), label.set_textcolor(matrix_label_s3, _lbl_color)
        var s3_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S3_HISTBASE +PAIRBEGINS_Y_OFFSET,'🐢' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 3, text=s3_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 3, text=s3_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 3, text=s3_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s4_begin
        s4_text := ' By'   
        _tag_color = f_chartvol_color(uv_sym_s4, UVMX_CV_TAG, UVMX_C1_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s4, UVMX_CV_lbl, UVMX_C1_lbl)
        label.set_text(matrix_label_s4, s4_text), label.set_textcolor(matrix_label_s4, _lbl_color)
        var s4_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S4_HISTBASE +PAIRBEGINS_Y_OFFSET,'🐢' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 4, text=s4_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_l, 1, 5, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 4, text=s4_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_r, 0, 5, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 4, text=s4_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_c, 0, 5, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s5_begin
        s5_text := ' Ok'
        _tag_color = f_chartvol_color(uv_sym_s5, UVMX_CV_TAG, UVMX_C2_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s5, UVMX_CV_lbl, UVMX_C2_lbl)
        label.set_text(matrix_label_s5, s5_text), label.set_textcolor(matrix_label_s5, _lbl_color)
        var s5_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S5_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦕' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 6, text=s5_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 6, text=s5_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 6, text=s5_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s6_begin
        s6_text := ' Up'
        _tag_color = f_chartvol_color(uv_sym_s6, UVMX_CV_TAG, UVMX_C2_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s6, UVMX_CV_lbl, UVMX_C2_lbl)
        label.set_text(matrix_label_s6, s6_text), label.set_textcolor(matrix_label_s6, _lbl_color)
        var s6_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S6_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦕' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 7, text=s6_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 7, text=s6_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 7, text=s6_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s7_begin
        s7_text := ' Kk'
        _tag_color = f_chartvol_color(uv_sym_s7, UVMX_CV_TAG, UVMX_C2_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s7, UVMX_CV_lbl, UVMX_C2_lbl)
        label.set_text(matrix_label_s7, s7_text), label.set_textcolor(matrix_label_s7, _lbl_color)
        var s7_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S7_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦕' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 8, text=s7_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 8, text=s7_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 8, text=s7_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_s8_begin
        s8_text := ' Bg'
        _tag_color = f_chartvol_color(uv_sym_s8, UVMX_CV_TAG, UVMX_C2_TAG)
        _lbl_color = f_chartvol_color(uv_sym_s8, UVMX_CV_lbl, UVMX_C2_lbl)
        label.set_text(matrix_label_s8, s8_text), label.set_textcolor(matrix_label_s8, _lbl_color)    
        var s8_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,S8_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦕' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1, 9, text=s8_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_l, 1,10, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0, 9, text=s8_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_r, 0,10, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0, 9, text=s8_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_c, 0,10, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
    
    if bar_index == v_p1_begin
        p1_text := ' Bnᴾ'
        _tag_color = f_chartvol_color(uv_sym_p1, UVMX_CV_TAG, UVMX_C3_TAG)
        _lbl_color = f_chartvol_color(uv_sym_p1, UVMX_CV_lbl, UVMX_C3_lbl)
        label.set_text(matrix_label_p1, ' '+p1_text), label.set_textcolor(matrix_label_p1, _lbl_color)
        var p1_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,P1_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦖' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1,11, text=p1_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0,11, text=p1_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0,11, text=p1_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_p2_begin
        p2_text := ' Coᴾ'
        _tag_color = f_chartvol_color(uv_sym_p2, UVMX_CV_TAG, UVMX_C3_TAG)
        _lbl_color = f_chartvol_color(uv_sym_p2, UVMX_CV_lbl, UVMX_C3_lbl)
        label.set_text(matrix_label_p2, ' '+p2_text), label.set_textcolor(matrix_label_p2, _lbl_color)
        var p2_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,P2_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦖' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1,12, text=p2_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0,12, text=p2_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0,12, text=p2_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_p3_begin
        p3_text := ' Byᴾ'
        _tag_color = f_chartvol_color(uv_sym_p3, UVMX_CV_TAG, UVMX_C3_TAG)
        _lbl_color = f_chartvol_color(uv_sym_p3, UVMX_CV_lbl, UVMX_C3_lbl)
        label.set_text(matrix_label_p3, ' '+p3_text), label.set_textcolor(matrix_label_p3, _lbl_color)
        var p3_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,P3_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦖' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1,13, text=p3_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0,13, text=p3_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0,13, text=p3_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)

    if bar_index == v_p4_begin
        p4_text := ' Okᴾ'
        _tag_color = f_chartvol_color(uv_sym_p4, UVMX_CV_TAG, UVMX_C3_TAG)
        _lbl_color = f_chartvol_color(uv_sym_p4, UVMX_CV_lbl, UVMX_C3_lbl)
        label.set_text(matrix_label_p4, ' '+p4_text), label.set_textcolor(matrix_label_p4, _lbl_color)
        var p4_pairbeings = not uvmx_pairbegins_flg ? label(na):label.new(math.max(0,bar_index-PAIRBEGINS_X_OFFSET) ,P4_HISTBASE +PAIRBEGINS_Y_OFFSET,'🦖' ,color=COLOR_TRANSP, style=PAIRBEGINS_STYLE, size=PAIRBEGINS_SIZE)
        if uvmx_nametag_l_flg
            table.cell(uvmx_name_l, 1,14, text=p4_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_l, 1,15, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)    
        if uvmx_nametag_r_flg
            table.cell(uvmx_name_r, 0,14, text=p4_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_r, 0,15, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)
        if uvmx_nametag_c_flg
            table.cell(uvmx_name_c, 0,14, text=p4_text, bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
            table.cell(uvmx_name_c, 0,15, text=''     , bgcolor=UVMX_BG_C, text_color=_tag_color ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)
   
    //nametag(pinned)
    table.cell_set_tooltip(uvmx_name_l, 1, 0,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 1,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 2,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 3,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 4,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 5,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 6,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 7,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 8,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1, 9,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,10,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,11,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,12,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,13,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,14,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,15,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,16,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_l, 1,17,uvmx_tooltip)

    table.cell_set_tooltip(uvmx_name_c, 0, 0,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 1,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 2,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 3,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 4,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 5,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 6,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 7,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 8,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0, 9,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,10,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,11,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,12,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,13,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,14,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,15,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,16,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_c, 0,17,uvmx_tooltip)

    table.cell_set_tooltip(uvmx_name_r, 0, 0,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 1,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 2,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 3,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 4,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 5,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 6,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 7,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 8,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0, 9,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,10,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,11,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,12,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,13,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,14,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,15,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,16,uvmx_tooltip)
    table.cell_set_tooltip(uvmx_name_r, 0,17,uvmx_tooltip)

    //nametag(extension)
    label.set_tooltip(matrix_label_s1, uvmx_tooltip)
    label.set_tooltip(matrix_label_s2, uvmx_tooltip)
    label.set_tooltip(matrix_label_s3, uvmx_tooltip)
    label.set_tooltip(matrix_label_s4, uvmx_tooltip)
    label.set_tooltip(matrix_label_s5, uvmx_tooltip)
    label.set_tooltip(matrix_label_s6, uvmx_tooltip)
    label.set_tooltip(matrix_label_s7, uvmx_tooltip)
    label.set_tooltip(matrix_label_s8, uvmx_tooltip)
    label.set_tooltip(matrix_label_p1, uvmx_tooltip)
    label.set_tooltip(matrix_label_p2, uvmx_tooltip)
    label.set_tooltip(matrix_label_p3, uvmx_tooltip)
    label.set_tooltip(matrix_label_p4, uvmx_tooltip)

//------------------------------------------------------------------------------------------------------
if (uv_volmode_ultravol_update_task_flg or uv_volmode_chartvol_task_flg) and chartvol_indi_in_panel_flg and (uv_src_updated_now_flg or barstate.islastconfirmedhistory)      
// if uv_volmode_ultravol_task_flg and chartvol_indi_in_panel_flg and (uv_src_updated_now_flg or barstate.islastconfirmedhistory)      
    // nametag (extension)
    label.set_text(matrix_label_cv, cv_text), label.set_tooltip(matrix_label_cv, uvmx_tooltip)
    // nametag (pinned)
    if uvmx_nametag_l_flg 
        table.cell(uvmx_name_l, 0,15, text=''     ,tooltip=uvmx_tooltip ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height     )
        table.cell(uvmx_name_l, 0,16, text=''     ,tooltip=uvmx_tooltip ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height     )
        table.cell(uvmx_name_l, 0,17, text=''     ,tooltip=uvmx_tooltip ,text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT )   
        //
        table.cell(uvmx_name_l, 1,15, text=''     ,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height    )
        table.cell(uvmx_name_l, 1,16, text=' '+cv_text, bgcolor=UVMX_BG_C,tooltip=uvmx_tooltip , text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_l, 1,17, text=''     ,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)   
    if uvmx_nametag_c_flg
        table.cell(uvmx_name_c, 0,15, text=''     ,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,16, text=' '+cv_text, tooltip=uvmx_tooltip, bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_c, 0,17, text=''     ,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)   
    if uvmx_nametag_r_flg
        table.cell(uvmx_name_r, 0,15, text=''     ,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,16, text=' '+cv_text,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=uvmx_tag_height)
        table.cell(uvmx_name_r, 0,17, text=''     ,tooltip=uvmx_tooltip , bgcolor=UVMX_BG_C, text_halign=UVMX_TAG_TXT_ALIGN ,text_size=uvmx_tag_txt_size ,height=UVMX_TAG_BTM_HEIGHT)

//---------------------------------------------
// Nametag(extension) Label x 
if (barstate.islastconfirmedhistory or barstate.islast) and uvmx_nametag2_flg 
    int matrix_label_pos = matrix_ext_vol_end + 4 
    if uv_volmode_ultravol_task_flg
        label.set_x(matrix_label_s1, matrix_label_pos)
        label.set_x(matrix_label_s2, matrix_label_pos)
        label.set_x(matrix_label_s3, matrix_label_pos)
        label.set_x(matrix_label_s4, matrix_label_pos)
        label.set_x(matrix_label_s5, matrix_label_pos)
        label.set_x(matrix_label_s6, matrix_label_pos)
        label.set_x(matrix_label_s7, matrix_label_pos)
        label.set_x(matrix_label_s8, matrix_label_pos)
        label.set_x(matrix_label_p1, matrix_label_pos)
        label.set_x(matrix_label_p2, matrix_label_pos)
        label.set_x(matrix_label_p3, matrix_label_pos)
        label.set_x(matrix_label_p4, matrix_label_pos)
    if chartvol_indi_in_panel_flg or uv_volmode_chartvol_task_flg
        label.set_x(matrix_label_cv, matrix_label_pos)
        // solo chartvol fallback -> Y position compensation
        label.set_y(matrix_label_cv, CV_HISTBASE + (uv_volmode_chartvol_task_flg? -0.5:MATRIX_LABEL_Y))

// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
// Rescale
// ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
var table uv_vol_mode_notice_tbl = table.new(position.bottom_right, 2, 1
                                ,bgcolor=COLOR_TRANSP, frame_color=COLOR_TRANSP, frame_width=0
                                ,border_color=COLOR_TRANSP, border_width=0, force_overlay=false) 
varip bool _volmode_ultravol_mark_fixed = false
if not _volmode_ultravol_mark_fixed and uv_volmode_ultravol_task_flg and (barstate.islastconfirmedhistory or barstate.islast)
    const color uv_gfm4_off_fg_c             = #4c4c4c
    const color uv_gfm4_on_scale_notice_gf_c = #ffffff,  const color uv_gfm4_on_scale_bg_c         = color.new(#222222,0)
    const color uv_volmode_nodata_notice_fg_c= #ff4c57,  const color uv_volmode_nodata_notice_bg_c = color.new(#330e17,20)
    //────────────────────────────────────────────────────────────────────────────────────────────────────────────-
    bool uvmx_rescaled_flg = not (ultravol_rescale_mode_selector == uv_rescale_mode.neutral) 
    uv_rescale_notice_text       = uvmx_rescaled_flg ? ultravol_rescale_mode_text : na
    table.cell(uv_vol_mode_notice_tbl, 0, 0, uv_rescale_notice_text, height=0
              ,text_halign=text.align_center, text_valign=text.align_center 
              ,text_size=12 ,text_formatting=text.format_none
              ,text_color=uv_volmode_novol_task_flg ? uv_gfm4_off_fg_c : uv_gfm4_on_scale_notice_gf_c
              ,bgcolor=uvmx_rescaled_flg ? uv_gfm4_on_scale_bg_c: COLOR_TRANSP)
    table.cell(uv_vol_mode_notice_tbl, 1, 0, '       ', height=0
              ,text_halign=text.align_right, text_valign=text.align_center
              ,text_size=12 ,text_color=COLOR_TRANSP ,bgcolor=COLOR_TRANSP)
    _volmode_ultravol_mark_fixed := uv_volmode_ultravol_task_flg


//-------------------------------
// Total plot count = 63 plot
//-------------------------------
````
