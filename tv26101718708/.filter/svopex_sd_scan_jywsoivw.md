# Svopex S&D Scan

- url: https://www.tradingview.com/script/Jywsoivw-Svopex-S-D-Scan/
- type: indicator
- pine_id: PUB;4877eafaa8124db7b8ea5bb7276e20d3
- version: 4.0

## Description

Svopex S&D Scan                                                                                                                                                        
                                                                                                                                                                         
  Multi-symbol Supply & Demand zone scanner that displays the status of up to 40 instruments in a single table. Built on the same detection logic as Svopex Supply &     
  Demand Zones (base + explosive ATR candle pattern), but extended to portfolio-wide screening with on-chart zone drawing for the active symbol.                         
                                                                                                                                                                         
  What it does                                                                                                                                                           
                                          
  For each of up to 40 user-defined symbols (default: NAS100, XAU, EURUSD, US30, SPX500, WTICO, XAG, BTC + 27 main and cross OANDA currency pairs), the scanner detects  
  supply and demand zones in real time and shows in the result table where price currently sits relative to those zones.                                                 
   
  Detected statuses (priority order: IN > NEAR > WAS_IN > none):                                                                                                         
                                                         
  - IN SUPPLY / IN DEMAND — price is currently inside an active zone                                                                                                     
  - NEAR SUPPLY / NEAR DEMAND — price is within nearMult × ATR of the zone edge                                                                                          
  - WAS IN SUPPLY / WAS IN DEMAND — price was inside a zone within the last N closed bars but is no longer in/near it (zone has been broken). Useful as a follow-up
  signal after price entered a zone and the zone was invalidated                                                                                                         
  - (blank) — no relevant state                          
                                                                                                                                                                         
  The table can be filtered to show only hits, and rows update as the chart timeframe changes — the scanner always operates on the chart's current TF.                   
                                                                                                                                                                         
  Zone detection logic (identical to Svopex Supply & Demand Zones):                                                                                                      
                                                                                                                                                                         
  - 1 to N "base" candles with body ≤ baseBodyPct × ATR
  - Followed by an explosive candle with body ≥ explMult × ATR                                                                                                           
  - The high/low of the base candles defines the zone boundaries
  - The zone is invalidated when price breaks through it according to breakPct threshold (with optional wick or body-only mode)                                          
                                                         
  On-chart zone drawing                                                                                                                                                  
                                                                                                                                                                         
  For the current chart symbol, the scanner also draws supply (red) and demand (green) boxes the same way as Svopex S&D Zones — so you can use it as a single-symbol     
  indicator and as a multi-symbol scanner in one. Switching the chart to any other symbol redraws the boxes for that symbol.                                             
                                                                                                                                                                         
  ---                                                                                                                                                                    
  Parameters                                             
                                                                                                                                                                         
  Symbols (1–40)                                         
  - Each slot accepts a BROKER:TICKER format (e.g. OANDA:EURUSD, BINANCE:BTCUSD). Empty slots are skipped (mapped to chart symbol internally and deduplicated by Pine).
                                                                                                                                                                       
  Zone detection                          
  - Max base candles (default 3, range 1–6) — maximum number of base candles that can precede the explosive move.                                                        
  - Base body ≤ ATR × (default 0.5) — the body of base candles must be at most this multiple of ATR.                                                                     
  - Explosive body ≥ ATR × (default 1.5) — the body of the explosive candle must be at least this multiple of ATR.                                                       
  - ATR length (default 14) — period for ATR calculation.                                                                                                                
  - Max active zones per side (default 20, range 1–100) — how many supply/demand zones to track per symbol; oldest are dropped when the limit is exceeded.               
                                                                                                                                                                         
  Zone Break                                                                                                                                                             
  - Include wicks (else body only) (default true) — when ON, the break check uses candle high/low (wicks); when OFF, only body (max/min of open, close).                 
  - Break threshold (%) (default 0, range 0–100) — how far price must penetrate the zone to invalidate it. 0 = zone breaks at first touch of the near edge, 50 = breaks  
  at midline, 100 = breaks only after fully crossing the zone.                                                                                                           
                                                                                                                                                                         
  Proximity                                                                                                                                                              
  - Near threshold (ATR ×) (default 1) — distance from zone edge (in ATR units) within which price counts as "NEAR".
                                                                                                                                                                         
  Was-in zone                                            
  - Bars back for 'was in zone' (default 10, range 1–50) — lookback window for the WAS_IN status. If price was inside a zone within the last N confirmed bars but is no  
  longer there, the symbol shows WAS IN SUPPLY / WAS IN DEMAND. Only triggers when no IN/NEAR status applies.                                                            
                                                                                                             
  Current-symbol zones                                                                                                                                                   
  - Draw zones for current chart symbol (default true) — toggles zone box rendering on the chart.                                                                        
  - Max drawn zones per side (default 20) — limit for boxes drawn on chart.                                                                                              
  - Supply fill / Demand fill (default red 80% / green 80%) — zone box colors.                                                                                           
                                                                                                                                                                         
  Table                                                                                                                                                                  
  - Position (default top_right) — top/bottom × left/right/middle.                                                                                                       
  - Show only hits (default true) — hides symbols with no signal.                                                                                                        
  - Text size (default normal) — tiny / small / normal / large / huge.                                                                                                   
  - Strip exchange prefix (default true) — shows EURUSD instead of OANDA:EURUSD.                                                                                         
                                                                                                                                                                         
  ---                                                                                                                                                                    
  Typical usage                                                                                                                                                          
                                                         
  - Open any chart and timeframe — the scanner immediately shows which symbols in your watchlist are in/near a zone.                                                     
  - When you change the chart timeframe, the scanner recomputes all symbols on the new TF.
  - When you switch the chart to a symbol from the list, you see its zones rendered as boxes directly on the chart.                                                      
                                                         
  Limitations                                                                                                                                                            
                                                                                                                                                                         
  - Pine Script enforces a hard limit of 40 unique request.security calls per indicator — hence the 40-symbol cap. Empty slots are mapped to the chart symbol and        
  deduplicated, so the actual call count depends on how many distinct tickers you populate.                                                                              
  - Zone boxes are drawn only for the active chart symbol (price-axis scaling makes cross-symbol overlay meaningless).                                                   
  - With breakPct=0 and useWicks=true, zones have a short life (a single wick touch invalidates them) — the WAS_IN status acts as a follow-up signal in that mode.       
                                              
  Tip: For longer-lived zones, raise breakPct to 50–100% — IN/NEAR statuses will then persist as long as price holds the zone. For a classic S&D screener, the           
  recommended combination is useWicks=true + breakPct=0 + wasInLookback=10.

## Source Code

````pine
//@version=5
// Svopex S&D Scan v1.1 (2026-05-10) — WAS IN status now overrides NEAR when zone was actually touched within wasInLookback bars
indicator("Svopex S&D Scan", "Svopex S&D Scan", overlay=true, max_boxes_count=500, max_labels_count=500)

g_sym = "Symbols"
sym1  = input.symbol("OANDA:NAS100USD", "Symbol 1",  group=g_sym)
sym2  = input.symbol("OANDA:XAUUSD",    "Symbol 2",  group=g_sym)
sym3  = input.symbol("OANDA:EURUSD",    "Symbol 3",  group=g_sym)
sym4  = input.symbol("OANDA:US30USD",   "Symbol 4",  group=g_sym)
sym5  = input.symbol("OANDA:SPX500USD", "Symbol 5",  group=g_sym)
sym6  = input.symbol("OANDA:US2000USD", "Symbol 6",  group=g_sym)
sym7  = input.symbol("OANDA:DE30EUR",   "Symbol 7",  group=g_sym)
sym8  = input.symbol("OANDA:WTICOUSD",  "Symbol 8",  group=g_sym)
sym9  = input.symbol("OANDA:XAGUSD",    "Symbol 9",  group=g_sym)
sym10 = input.symbol("BINANCE:BTCUSD",  "Symbol 10", group=g_sym)
sym11 = input.symbol("OANDA:GBPUSD",    "Symbol 11", group=g_sym)
sym12 = input.symbol("OANDA:USDJPY",    "Symbol 12", group=g_sym)
sym13 = input.symbol("OANDA:USDCHF",    "Symbol 13", group=g_sym)
sym14 = input.symbol("OANDA:AUDUSD",    "Symbol 14", group=g_sym)
sym15 = input.symbol("OANDA:USDCAD",    "Symbol 15", group=g_sym)
sym16 = input.symbol("OANDA:NZDUSD",    "Symbol 16", group=g_sym)
sym17 = input.symbol("OANDA:EURGBP",    "Symbol 17", group=g_sym)
sym18 = input.symbol("OANDA:EURJPY",    "Symbol 18", group=g_sym)
sym19 = input.symbol("OANDA:EURCHF",    "Symbol 19", group=g_sym)
sym20 = input.symbol("OANDA:EURAUD",    "Symbol 20", group=g_sym)
sym21 = input.symbol("OANDA:EURCAD",    "Symbol 21", group=g_sym)
sym22 = input.symbol("OANDA:EURNZD",    "Symbol 22", group=g_sym)
sym23 = input.symbol("OANDA:GBPJPY",    "Symbol 23", group=g_sym)
sym24 = input.symbol("OANDA:GBPCHF",    "Symbol 24", group=g_sym)
sym25 = input.symbol("OANDA:GBPAUD",    "Symbol 25", group=g_sym)
sym26 = input.symbol("OANDA:GBPCAD",    "Symbol 26", group=g_sym)
sym27 = input.symbol("OANDA:GBPNZD",    "Symbol 27", group=g_sym)
sym28 = input.symbol("OANDA:AUDJPY",    "Symbol 28", group=g_sym)
sym29 = input.symbol("OANDA:AUDCHF",    "Symbol 29", group=g_sym)
sym30 = input.symbol("OANDA:AUDCAD",    "Symbol 30", group=g_sym)
sym31 = input.symbol("OANDA:AUDNZD",    "Symbol 31", group=g_sym)
sym32 = input.symbol("OANDA:CADJPY",    "Symbol 32", group=g_sym)
sym33 = input.symbol("OANDA:CADCHF",    "Symbol 33", group=g_sym)
sym34 = input.symbol("OANDA:NZDJPY",    "Symbol 34", group=g_sym)
sym35 = input.symbol("OANDA:NZDCHF",    "Symbol 35", group=g_sym)
sym36 = input.symbol("OANDA:NZDCAD",    "Symbol 36", group=g_sym)
sym37 = input.symbol("OANDA:CHFJPY",    "Symbol 37", group=g_sym)
sym38 = input.symbol("",                "Symbol 38", group=g_sym)
sym39 = input.symbol("",                "Symbol 39", group=g_sym)
sym40 = input.symbol("",                "Symbol 40", group=g_sym)

selTF = timeframe.period

g_det = "Zone detection"
baseMax     = input.int(3, "Max base candles", minval=1, maxval=6, group=g_det)
baseBodyPct = input.float(0.5, "Base body ≤ ATR ×", step=0.1, minval=0.1, group=g_det)
explMult    = input.float(1.5, "Explosive body ≥ ATR ×", step=0.1, minval=0.5, group=g_det)
atrLen      = input.int(14, "ATR length", minval=2, group=g_det)
maxZonesPerSide = input.int(20, "Max active zones per side", minval=1, maxval=100, group=g_det)

g_brk = "Zone Break"
useWicks = input.bool(true, "Include wicks (else body only)", group=g_brk)
breakPct = input.int(0, "Break threshold (%)", minval=0, maxval=100, group=g_brk)

g_prox = "Proximity"
nearMult = input.float(1, "Near threshold (ATR ×)", step=0.1, minval=0, group=g_prox)

g_draw = "Current-symbol zones"
drawZones    = input.bool(true, "Draw zones for current chart symbol", group=g_draw)
maxDrawZones = input.int(20, "Max drawn zones per side", minval=1, maxval=100, group=g_draw)
supplyCol    = input.color(color.new(color.red,   80), "Supply fill", group=g_draw)
demandCol    = input.color(color.new(color.green, 80), "Demand fill", group=g_draw)

g_tbl = "Table"
tblPos = input.string("top_right", "Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right","middle_left"], group=g_tbl)
showOnlyHits = input.bool(true, "Show only hits", group=g_tbl)
tblSize = input.string("normal", "Text size", options=["tiny","small","normal","large","huge"], group=g_tbl)
shortNames = input.bool(true, "Strip exchange prefix", group=g_tbl)

g_was = "Was-in zone"
wasInLookback = input.int(10, "Bars back for 'was in zone'", minval=1, maxval=50, group=g_was, tooltip="If price WAS inside a supply/demand zone in the last N confirmed bars, show 'WAS IN' status. WAS IN also overrides NEAR so that a confirmed touch is not masked by current proximity.")

f_detect() =>
    atr  = ta.atr(atrLen)
    body = math.abs(close - open)
    isBase     = body < baseBodyPct * atr
    isExplUp   = (close - open) >  explMult * atr
    isExplDown = (open  - close) >  explMult * atr
    var int   baseCount = 0
    var float baseH     = na
    var float baseL     = na
    var int   baseT     = na
    int   sig = 0
    float zH  = na
    float zL  = na
    int   zT  = na
    if isBase
        if baseCount == 0
            baseH := high
            baseL := low
            baseT := time
        else
            baseH := math.max(baseH, high)
            baseL := math.min(baseL, low)
        baseCount += 1
    else if baseCount >= 1 and baseCount <= baseMax and isExplUp
        sig := 2
        zH  := baseH
        zL  := baseL
        zT  := baseT
        baseCount := 0
        baseH := na
        baseL := na
        baseT := na
    else if baseCount >= 1 and baseCount <= baseMax and isExplDown
        sig := 1
        zH  := baseH
        zL  := baseL
        zT  := baseT
        baseCount := 0
        baseH := na
        baseL := na
        baseT := na
    else
        baseCount := 0
        baseH := na
        baseL := na
        baseT := na
    [sig, zH, zL, zT]

f_all() =>
    [sig, zH, zL, zT] = f_detect()
    [sig[1], zH[1], zL[1], zT[1], close, ta.atr(atrLen), useWicks ? high : math.max(open, close), useWicks ? low : math.min(open, close)]

u1  = sym1  == "" ? syminfo.tickerid : sym1
u2  = sym2  == "" ? syminfo.tickerid : sym2
u3  = sym3  == "" ? syminfo.tickerid : sym3
u4  = sym4  == "" ? syminfo.tickerid : sym4
u5  = sym5  == "" ? syminfo.tickerid : sym5
u6  = sym6  == "" ? syminfo.tickerid : sym6
u7  = sym7  == "" ? syminfo.tickerid : sym7
u8  = sym8  == "" ? syminfo.tickerid : sym8
u9  = sym9  == "" ? syminfo.tickerid : sym9
u10 = sym10 == "" ? syminfo.tickerid : sym10
u11 = sym11 == "" ? syminfo.tickerid : sym11
u12 = sym12 == "" ? syminfo.tickerid : sym12
u13 = sym13 == "" ? syminfo.tickerid : sym13
u14 = sym14 == "" ? syminfo.tickerid : sym14
u15 = sym15 == "" ? syminfo.tickerid : sym15
u16 = sym16 == "" ? syminfo.tickerid : sym16
u17 = sym17 == "" ? syminfo.tickerid : sym17
u18 = sym18 == "" ? syminfo.tickerid : sym18
u19 = sym19 == "" ? syminfo.tickerid : sym19
u20 = sym20 == "" ? syminfo.tickerid : sym20
u21 = sym21 == "" ? syminfo.tickerid : sym21
u22 = sym22 == "" ? syminfo.tickerid : sym22
u23 = sym23 == "" ? syminfo.tickerid : sym23
u24 = sym24 == "" ? syminfo.tickerid : sym24
u25 = sym25 == "" ? syminfo.tickerid : sym25
u26 = sym26 == "" ? syminfo.tickerid : sym26
u27 = sym27 == "" ? syminfo.tickerid : sym27
u28 = sym28 == "" ? syminfo.tickerid : sym28
u29 = sym29 == "" ? syminfo.tickerid : sym29
u30 = sym30 == "" ? syminfo.tickerid : sym30
u31 = sym31 == "" ? syminfo.tickerid : sym31
u32 = sym32 == "" ? syminfo.tickerid : sym32
u33 = sym33 == "" ? syminfo.tickerid : sym33
u34 = sym34 == "" ? syminfo.tickerid : sym34
u35 = sym35 == "" ? syminfo.tickerid : sym35
u36 = sym36 == "" ? syminfo.tickerid : sym36
u37 = sym37 == "" ? syminfo.tickerid : sym37
u38 = sym38 == "" ? syminfo.tickerid : sym38
u39 = sym39 == "" ? syminfo.tickerid : sym39
u40 = sym40 == "" ? syminfo.tickerid : sym40

[sig1,  zh1,  zl1,  zt1,  c1,  atr1,  h1,  l1]  = request.security(u1,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig2,  zh2,  zl2,  zt2,  c2,  atr2,  h2,  l2]  = request.security(u2,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig3,  zh3,  zl3,  zt3,  c3,  atr3,  h3,  l3]  = request.security(u3,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig4,  zh4,  zl4,  zt4,  c4,  atr4,  h4,  l4]  = request.security(u4,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig5,  zh5,  zl5,  zt5,  c5,  atr5,  h5,  l5]  = request.security(u5,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig6,  zh6,  zl6,  zt6,  c6,  atr6,  h6,  l6]  = request.security(u6,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig7,  zh7,  zl7,  zt7,  c7,  atr7,  h7,  l7]  = request.security(u7,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig8,  zh8,  zl8,  zt8,  c8,  atr8,  h8,  l8]  = request.security(u8,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig9,  zh9,  zl9,  zt9,  c9,  atr9,  h9,  l9]  = request.security(u9,  selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig10, zh10, zl10, zt10, c10, atr10, h10, l10] = request.security(u10, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig11, zh11, zl11, zt11, c11, atr11, h11, l11] = request.security(u11, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig12, zh12, zl12, zt12, c12, atr12, h12, l12] = request.security(u12, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig13, zh13, zl13, zt13, c13, atr13, h13, l13] = request.security(u13, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig14, zh14, zl14, zt14, c14, atr14, h14, l14] = request.security(u14, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig15, zh15, zl15, zt15, c15, atr15, h15, l15] = request.security(u15, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig16, zh16, zl16, zt16, c16, atr16, h16, l16] = request.security(u16, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig17, zh17, zl17, zt17, c17, atr17, h17, l17] = request.security(u17, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig18, zh18, zl18, zt18, c18, atr18, h18, l18] = request.security(u18, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig19, zh19, zl19, zt19, c19, atr19, h19, l19] = request.security(u19, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig20, zh20, zl20, zt20, c20, atr20, h20, l20] = request.security(u20, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig21, zh21, zl21, zt21, c21, atr21, h21, l21] = request.security(u21, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig22, zh22, zl22, zt22, c22, atr22, h22, l22] = request.security(u22, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig23, zh23, zl23, zt23, c23, atr23, h23, l23] = request.security(u23, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig24, zh24, zl24, zt24, c24, atr24, h24, l24] = request.security(u24, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig25, zh25, zl25, zt25, c25, atr25, h25, l25] = request.security(u25, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig26, zh26, zl26, zt26, c26, atr26, h26, l26] = request.security(u26, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig27, zh27, zl27, zt27, c27, atr27, h27, l27] = request.security(u27, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig28, zh28, zl28, zt28, c28, atr28, h28, l28] = request.security(u28, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig29, zh29, zl29, zt29, c29, atr29, h29, l29] = request.security(u29, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig30, zh30, zl30, zt30, c30, atr30, h30, l30] = request.security(u30, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig31, zh31, zl31, zt31, c31, atr31, h31, l31] = request.security(u31, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig32, zh32, zl32, zt32, c32, atr32, h32, l32] = request.security(u32, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig33, zh33, zl33, zt33, c33, atr33, h33, l33] = request.security(u33, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig34, zh34, zl34, zt34, c34, atr34, h34, l34] = request.security(u34, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig35, zh35, zl35, zt35, c35, atr35, h35, l35] = request.security(u35, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig36, zh36, zl36, zt36, c36, atr36, h36, l36] = request.security(u36, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig37, zh37, zl37, zt37, c37, atr37, h37, l37] = request.security(u37, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig38, zh38, zl38, zt38, c38, atr38, h38, l38] = request.security(u38, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig39, zh39, zl39, zt39, c39, atr39, h39, l39] = request.security(u39, selTF, f_all(), lookahead=barmerge.lookahead_off)
[sig40, zh40, zl40, zt40, c40, atr40, h40, l40] = request.security(u40, selTF, f_all(), lookahead=barmerge.lookahead_off)

chSig = switch syminfo.tickerid
    u1  => sig1
    u2  => sig2
    u3  => sig3
    u4  => sig4
    u5  => sig5
    u6  => sig6
    u7  => sig7
    u8  => sig8
    u9  => sig9
    u10 => sig10
    u11 => sig11
    u12 => sig12
    u13 => sig13
    u14 => sig14
    u15 => sig15
    u16 => sig16
    u17 => sig17
    u18 => sig18
    u19 => sig19
    u20 => sig20
    u21 => sig21
    u22 => sig22
    u23 => sig23
    u24 => sig24
    u25 => sig25
    u26 => sig26
    u27 => sig27
    u28 => sig28
    u29 => sig29
    u30 => sig30
    u31 => sig31
    u32 => sig32
    u33 => sig33
    u34 => sig34
    u35 => sig35
    u36 => sig36
    u37 => sig37
    u38 => sig38
    u39 => sig39
    u40 => sig40
    => 0

chZH = switch syminfo.tickerid
    u1  => zh1
    u2  => zh2
    u3  => zh3
    u4  => zh4
    u5  => zh5
    u6  => zh6
    u7  => zh7
    u8  => zh8
    u9  => zh9
    u10 => zh10
    u11 => zh11
    u12 => zh12
    u13 => zh13
    u14 => zh14
    u15 => zh15
    u16 => zh16
    u17 => zh17
    u18 => zh18
    u19 => zh19
    u20 => zh20
    u21 => zh21
    u22 => zh22
    u23 => zh23
    u24 => zh24
    u25 => zh25
    u26 => zh26
    u27 => zh27
    u28 => zh28
    u29 => zh29
    u30 => zh30
    u31 => zh31
    u32 => zh32
    u33 => zh33
    u34 => zh34
    u35 => zh35
    u36 => zh36
    u37 => zh37
    u38 => zh38
    u39 => zh39
    u40 => zh40
    => float(na)

chZL = switch syminfo.tickerid
    u1  => zl1
    u2  => zl2
    u3  => zl3
    u4  => zl4
    u5  => zl5
    u6  => zl6
    u7  => zl7
    u8  => zl8
    u9  => zl9
    u10 => zl10
    u11 => zl11
    u12 => zl12
    u13 => zl13
    u14 => zl14
    u15 => zl15
    u16 => zl16
    u17 => zl17
    u18 => zl18
    u19 => zl19
    u20 => zl20
    u21 => zl21
    u22 => zl22
    u23 => zl23
    u24 => zl24
    u25 => zl25
    u26 => zl26
    u27 => zl27
    u28 => zl28
    u29 => zl29
    u30 => zl30
    u31 => zl31
    u32 => zl32
    u33 => zl33
    u34 => zl34
    u35 => zl35
    u36 => zl36
    u37 => zl37
    u38 => zl38
    u39 => zl39
    u40 => zl40
    => float(na)

chZT = switch syminfo.tickerid
    u1  => zt1
    u2  => zt2
    u3  => zt3
    u4  => zt4
    u5  => zt5
    u6  => zt6
    u7  => zt7
    u8  => zt8
    u9  => zt9
    u10 => zt10
    u11 => zt11
    u12 => zt12
    u13 => zt13
    u14 => zt14
    u15 => zt15
    u16 => zt16
    u17 => zt17
    u18 => zt18
    u19 => zt19
    u20 => zt20
    u21 => zt21
    u22 => zt22
    u23 => zt23
    u24 => zt24
    u25 => zt25
    u26 => zt26
    u27 => zt27
    u28 => zt28
    u29 => zt29
    u30 => zt30
    u31 => zt31
    u32 => zt32
    u33 => zt33
    u34 => zt34
    u35 => zt35
    u36 => zt36
    u37 => zt37
    u38 => zt38
    u39 => zt39
    u40 => zt40
    => int(na)

f_track(supT, supB, demT, demB, sig, zH, zL, zT, prevZT) =>
    fresh = sig != 0 and not na(zT) and nz(zT, 0) != nz(prevZT, 0)
    if fresh and sig == 1
        array.push(supT, zH)
        array.push(supB, zL)
        if array.size(supT) > maxZonesPerSide
            array.shift(supT)
            array.shift(supB)
    if fresh and sig == 2
        array.push(demT, zH)
        array.push(demB, zL)
        if array.size(demT) > maxZonesPerSide
            array.shift(demT)
            array.shift(demB)

f_status_calc(supT, supB, demT, demB, c, atr) =>
    near = nearMult * atr
    int s = 0
    i1 = 0
    while s == 0 and i1 < array.size(supT)
        if c >= array.get(supB, i1) and c <= array.get(supT, i1)
            s := 1
        i1 := i1 + 1
    i2 = 0
    while s == 0 and i2 < array.size(demT)
        if c >= array.get(demB, i2) and c <= array.get(demT, i2)
            s := 2
        i2 := i2 + 1
    i3 = 0
    while s == 0 and i3 < array.size(supB)
        sb = array.get(supB, i3)
        if c < sb and c >= sb - near
            s := 3
        i3 := i3 + 1
    i4 = 0
    while s == 0 and i4 < array.size(demT)
        dt = array.get(demT, i4)
        if c > dt and c <= dt + near
            s := 4
        i4 := i4 + 1
    s

f_break(supT, supB, demT, demB, hi, lo) =>
    if barstate.isconfirmed
        pct = breakPct / 100.0
        i = 0
        while i < array.size(supT)
            top = array.get(supT, i)
            bot = array.get(supB, i)
            hgt = top - bot
            thr = bot + hgt * pct
            if hi >= thr
                array.remove(supT, i)
                array.remove(supB, i)
            else
                i := i + 1
        i := 0
        while i < array.size(demT)
            top = array.get(demT, i)
            bot = array.get(demB, i)
            hgt = top - bot
            thr = top - hgt * pct
            if lo <= thr
                array.remove(demT, i)
                array.remove(demB, i)
            else
                i := i + 1

f_touched(supT, supB, demT, demB, hi, lo) =>
    bool tSup = false
    bool tDem = false
    i = 0
    while not tSup and i < array.size(supT)
        top = array.get(supT, i)
        bot = array.get(supB, i)
        if hi >= bot and lo <= top
            tSup := true
        i := i + 1
    i := 0
    while not tDem and i < array.size(demT)
        top = array.get(demT, i)
        bot = array.get(demB, i)
        if hi >= bot and lo <= top
            tDem := true
        i := i + 1
    [tSup, tDem]

f_was_status(touchedSup, touchedDem, s) =>
    var int barsAgoSup = -1
    var int barsAgoDem = -1
    if touchedSup
        barsAgoSup := 0
    else if barsAgoSup >= 0 and barstate.isconfirmed
        barsAgoSup := barsAgoSup + 1
    if touchedDem
        barsAgoDem := 0
    else if barsAgoDem >= 0 and barstate.isconfirmed
        barsAgoDem := barsAgoDem + 1
    supValid = barsAgoSup >= 0 and barsAgoSup <= wasInLookback
    demValid = barsAgoDem >= 0 and barsAgoDem <= wasInLookback
    int final = s
    if s == 0
        if supValid and (not demValid or barsAgoSup <= barsAgoDem)
            final := 5
        else if demValid
            final := 6
    else if s == 3 and supValid
        final := 5
    else if s == 4 and demValid
        final := 6
    final

var supT1 = array.new_float()
var supB1 = array.new_float()
var demT1 = array.new_float()
var demB1 = array.new_float()
f_track(supT1, supB1, demT1, demB1, sig1, zh1, zl1, zt1, zt1[1])
[t1s, t1d] = f_touched(supT1, supB1, demT1, demB1, h1, l1)
sRaw1 = f_status_calc(supT1, supB1, demT1, demB1, c1, atr1)
s1 = f_was_status(t1s, t1d, sRaw1)
f_break(supT1, supB1, demT1, demB1, h1, l1)

var supT2 = array.new_float()
var supB2 = array.new_float()
var demT2 = array.new_float()
var demB2 = array.new_float()
f_track(supT2, supB2, demT2, demB2, sig2, zh2, zl2, zt2, zt2[1])
[t2s, t2d] = f_touched(supT2, supB2, demT2, demB2, h2, l2)
sRaw2 = f_status_calc(supT2, supB2, demT2, demB2, c2, atr2)
s2 = f_was_status(t2s, t2d, sRaw2)
f_break(supT2, supB2, demT2, demB2, h2, l2)

var supT3 = array.new_float()
var supB3 = array.new_float()
var demT3 = array.new_float()
var demB3 = array.new_float()
f_track(supT3, supB3, demT3, demB3, sig3, zh3, zl3, zt3, zt3[1])
[t3s, t3d] = f_touched(supT3, supB3, demT3, demB3, h3, l3)
sRaw3 = f_status_calc(supT3, supB3, demT3, demB3, c3, atr3)
s3 = f_was_status(t3s, t3d, sRaw3)
f_break(supT3, supB3, demT3, demB3, h3, l3)

var supT4 = array.new_float()
var supB4 = array.new_float()
var demT4 = array.new_float()
var demB4 = array.new_float()
f_track(supT4, supB4, demT4, demB4, sig4, zh4, zl4, zt4, zt4[1])
[t4s, t4d] = f_touched(supT4, supB4, demT4, demB4, h4, l4)
sRaw4 = f_status_calc(supT4, supB4, demT4, demB4, c4, atr4)
s4 = f_was_status(t4s, t4d, sRaw4)
f_break(supT4, supB4, demT4, demB4, h4, l4)

var supT5 = array.new_float()
var supB5 = array.new_float()
var demT5 = array.new_float()
var demB5 = array.new_float()
f_track(supT5, supB5, demT5, demB5, sig5, zh5, zl5, zt5, zt5[1])
[t5s, t5d] = f_touched(supT5, supB5, demT5, demB5, h5, l5)
sRaw5 = f_status_calc(supT5, supB5, demT5, demB5, c5, atr5)
s5 = f_was_status(t5s, t5d, sRaw5)
f_break(supT5, supB5, demT5, demB5, h5, l5)

var supT6 = array.new_float()
var supB6 = array.new_float()
var demT6 = array.new_float()
var demB6 = array.new_float()
f_track(supT6, supB6, demT6, demB6, sig6, zh6, zl6, zt6, zt6[1])
[t6s, t6d] = f_touched(supT6, supB6, demT6, demB6, h6, l6)
sRaw6 = f_status_calc(supT6, supB6, demT6, demB6, c6, atr6)
s6 = f_was_status(t6s, t6d, sRaw6)
f_break(supT6, supB6, demT6, demB6, h6, l6)

var supT7 = array.new_float()
var supB7 = array.new_float()
var demT7 = array.new_float()
var demB7 = array.new_float()
f_track(supT7, supB7, demT7, demB7, sig7, zh7, zl7, zt7, zt7[1])
[t7s, t7d] = f_touched(supT7, supB7, demT7, demB7, h7, l7)
sRaw7 = f_status_calc(supT7, supB7, demT7, demB7, c7, atr7)
s7 = f_was_status(t7s, t7d, sRaw7)
f_break(supT7, supB7, demT7, demB7, h7, l7)

var supT8 = array.new_float()
var supB8 = array.new_float()
var demT8 = array.new_float()
var demB8 = array.new_float()
f_track(supT8, supB8, demT8, demB8, sig8, zh8, zl8, zt8, zt8[1])
[t8s, t8d] = f_touched(supT8, supB8, demT8, demB8, h8, l8)
sRaw8 = f_status_calc(supT8, supB8, demT8, demB8, c8, atr8)
s8 = f_was_status(t8s, t8d, sRaw8)
f_break(supT8, supB8, demT8, demB8, h8, l8)

var supT9 = array.new_float()
var supB9 = array.new_float()
var demT9 = array.new_float()
var demB9 = array.new_float()
f_track(supT9, supB9, demT9, demB9, sig9, zh9, zl9, zt9, zt9[1])
[t9s, t9d] = f_touched(supT9, supB9, demT9, demB9, h9, l9)
sRaw9 = f_status_calc(supT9, supB9, demT9, demB9, c9, atr9)
s9 = f_was_status(t9s, t9d, sRaw9)
f_break(supT9, supB9, demT9, demB9, h9, l9)

var supT10 = array.new_float()
var supB10 = array.new_float()
var demT10 = array.new_float()
var demB10 = array.new_float()
f_track(supT10, supB10, demT10, demB10, sig10, zh10, zl10, zt10, zt10[1])
[t10s, t10d] = f_touched(supT10, supB10, demT10, demB10, h10, l10)
sRaw10 = f_status_calc(supT10, supB10, demT10, demB10, c10, atr10)
s10 = f_was_status(t10s, t10d, sRaw10)
f_break(supT10, supB10, demT10, demB10, h10, l10)

var supT11 = array.new_float()
var supB11 = array.new_float()
var demT11 = array.new_float()
var demB11 = array.new_float()
f_track(supT11, supB11, demT11, demB11, sig11, zh11, zl11, zt11, zt11[1])
[t11s, t11d] = f_touched(supT11, supB11, demT11, demB11, h11, l11)
sRaw11 = f_status_calc(supT11, supB11, demT11, demB11, c11, atr11)
s11 = f_was_status(t11s, t11d, sRaw11)
f_break(supT11, supB11, demT11, demB11, h11, l11)

var supT12 = array.new_float()
var supB12 = array.new_float()
var demT12 = array.new_float()
var demB12 = array.new_float()
f_track(supT12, supB12, demT12, demB12, sig12, zh12, zl12, zt12, zt12[1])
[t12s, t12d] = f_touched(supT12, supB12, demT12, demB12, h12, l12)
sRaw12 = f_status_calc(supT12, supB12, demT12, demB12, c12, atr12)
s12 = f_was_status(t12s, t12d, sRaw12)
f_break(supT12, supB12, demT12, demB12, h12, l12)

var supT13 = array.new_float()
var supB13 = array.new_float()
var demT13 = array.new_float()
var demB13 = array.new_float()
f_track(supT13, supB13, demT13, demB13, sig13, zh13, zl13, zt13, zt13[1])
[t13s, t13d] = f_touched(supT13, supB13, demT13, demB13, h13, l13)
sRaw13 = f_status_calc(supT13, supB13, demT13, demB13, c13, atr13)
s13 = f_was_status(t13s, t13d, sRaw13)
f_break(supT13, supB13, demT13, demB13, h13, l13)

var supT14 = array.new_float()
var supB14 = array.new_float()
var demT14 = array.new_float()
var demB14 = array.new_float()
f_track(supT14, supB14, demT14, demB14, sig14, zh14, zl14, zt14, zt14[1])
[t14s, t14d] = f_touched(supT14, supB14, demT14, demB14, h14, l14)
sRaw14 = f_status_calc(supT14, supB14, demT14, demB14, c14, atr14)
s14 = f_was_status(t14s, t14d, sRaw14)
f_break(supT14, supB14, demT14, demB14, h14, l14)

var supT15 = array.new_float()
var supB15 = array.new_float()
var demT15 = array.new_float()
var demB15 = array.new_float()
f_track(supT15, supB15, demT15, demB15, sig15, zh15, zl15, zt15, zt15[1])
[t15s, t15d] = f_touched(supT15, supB15, demT15, demB15, h15, l15)
sRaw15 = f_status_calc(supT15, supB15, demT15, demB15, c15, atr15)
s15 = f_was_status(t15s, t15d, sRaw15)
f_break(supT15, supB15, demT15, demB15, h15, l15)

var supT16 = array.new_float()
var supB16 = array.new_float()
var demT16 = array.new_float()
var demB16 = array.new_float()
f_track(supT16, supB16, demT16, demB16, sig16, zh16, zl16, zt16, zt16[1])
[t16s, t16d] = f_touched(supT16, supB16, demT16, demB16, h16, l16)
sRaw16 = f_status_calc(supT16, supB16, demT16, demB16, c16, atr16)
s16 = f_was_status(t16s, t16d, sRaw16)
f_break(supT16, supB16, demT16, demB16, h16, l16)

var supT17 = array.new_float()
var supB17 = array.new_float()
var demT17 = array.new_float()
var demB17 = array.new_float()
f_track(supT17, supB17, demT17, demB17, sig17, zh17, zl17, zt17, zt17[1])
[t17s, t17d] = f_touched(supT17, supB17, demT17, demB17, h17, l17)
sRaw17 = f_status_calc(supT17, supB17, demT17, demB17, c17, atr17)
s17 = f_was_status(t17s, t17d, sRaw17)
f_break(supT17, supB17, demT17, demB17, h17, l17)

var supT18 = array.new_float()
var supB18 = array.new_float()
var demT18 = array.new_float()
var demB18 = array.new_float()
f_track(supT18, supB18, demT18, demB18, sig18, zh18, zl18, zt18, zt18[1])
[t18s, t18d] = f_touched(supT18, supB18, demT18, demB18, h18, l18)
sRaw18 = f_status_calc(supT18, supB18, demT18, demB18, c18, atr18)
s18 = f_was_status(t18s, t18d, sRaw18)
f_break(supT18, supB18, demT18, demB18, h18, l18)

var supT19 = array.new_float()
var supB19 = array.new_float()
var demT19 = array.new_float()
var demB19 = array.new_float()
f_track(supT19, supB19, demT19, demB19, sig19, zh19, zl19, zt19, zt19[1])
[t19s, t19d] = f_touched(supT19, supB19, demT19, demB19, h19, l19)
sRaw19 = f_status_calc(supT19, supB19, demT19, demB19, c19, atr19)
s19 = f_was_status(t19s, t19d, sRaw19)
f_break(supT19, supB19, demT19, demB19, h19, l19)

var supT20 = array.new_float()
var supB20 = array.new_float()
var demT20 = array.new_float()
var demB20 = array.new_float()
f_track(supT20, supB20, demT20, demB20, sig20, zh20, zl20, zt20, zt20[1])
[t20s, t20d] = f_touched(supT20, supB20, demT20, demB20, h20, l20)
sRaw20 = f_status_calc(supT20, supB20, demT20, demB20, c20, atr20)
s20 = f_was_status(t20s, t20d, sRaw20)
f_break(supT20, supB20, demT20, demB20, h20, l20)

var supT21 = array.new_float()
var supB21 = array.new_float()
var demT21 = array.new_float()
var demB21 = array.new_float()
f_track(supT21, supB21, demT21, demB21, sig21, zh21, zl21, zt21, zt21[1])
[t21s, t21d] = f_touched(supT21, supB21, demT21, demB21, h21, l21)
sRaw21 = f_status_calc(supT21, supB21, demT21, demB21, c21, atr21)
s21 = f_was_status(t21s, t21d, sRaw21)
f_break(supT21, supB21, demT21, demB21, h21, l21)

var supT22 = array.new_float()
var supB22 = array.new_float()
var demT22 = array.new_float()
var demB22 = array.new_float()
f_track(supT22, supB22, demT22, demB22, sig22, zh22, zl22, zt22, zt22[1])
[t22s, t22d] = f_touched(supT22, supB22, demT22, demB22, h22, l22)
sRaw22 = f_status_calc(supT22, supB22, demT22, demB22, c22, atr22)
s22 = f_was_status(t22s, t22d, sRaw22)
f_break(supT22, supB22, demT22, demB22, h22, l22)

var supT23 = array.new_float()
var supB23 = array.new_float()
var demT23 = array.new_float()
var demB23 = array.new_float()
f_track(supT23, supB23, demT23, demB23, sig23, zh23, zl23, zt23, zt23[1])
[t23s, t23d] = f_touched(supT23, supB23, demT23, demB23, h23, l23)
sRaw23 = f_status_calc(supT23, supB23, demT23, demB23, c23, atr23)
s23 = f_was_status(t23s, t23d, sRaw23)
f_break(supT23, supB23, demT23, demB23, h23, l23)

var supT24 = array.new_float()
var supB24 = array.new_float()
var demT24 = array.new_float()
var demB24 = array.new_float()
f_track(supT24, supB24, demT24, demB24, sig24, zh24, zl24, zt24, zt24[1])
[t24s, t24d] = f_touched(supT24, supB24, demT24, demB24, h24, l24)
sRaw24 = f_status_calc(supT24, supB24, demT24, demB24, c24, atr24)
s24 = f_was_status(t24s, t24d, sRaw24)
f_break(supT24, supB24, demT24, demB24, h24, l24)

var supT25 = array.new_float()
var supB25 = array.new_float()
var demT25 = array.new_float()
var demB25 = array.new_float()
f_track(supT25, supB25, demT25, demB25, sig25, zh25, zl25, zt25, zt25[1])
[t25s, t25d] = f_touched(supT25, supB25, demT25, demB25, h25, l25)
sRaw25 = f_status_calc(supT25, supB25, demT25, demB25, c25, atr25)
s25 = f_was_status(t25s, t25d, sRaw25)
f_break(supT25, supB25, demT25, demB25, h25, l25)

var supT26 = array.new_float()
var supB26 = array.new_float()
var demT26 = array.new_float()
var demB26 = array.new_float()
f_track(supT26, supB26, demT26, demB26, sig26, zh26, zl26, zt26, zt26[1])
[t26s, t26d] = f_touched(supT26, supB26, demT26, demB26, h26, l26)
sRaw26 = f_status_calc(supT26, supB26, demT26, demB26, c26, atr26)
s26 = f_was_status(t26s, t26d, sRaw26)
f_break(supT26, supB26, demT26, demB26, h26, l26)

var supT27 = array.new_float()
var supB27 = array.new_float()
var demT27 = array.new_float()
var demB27 = array.new_float()
f_track(supT27, supB27, demT27, demB27, sig27, zh27, zl27, zt27, zt27[1])
[t27s, t27d] = f_touched(supT27, supB27, demT27, demB27, h27, l27)
sRaw27 = f_status_calc(supT27, supB27, demT27, demB27, c27, atr27)
s27 = f_was_status(t27s, t27d, sRaw27)
f_break(supT27, supB27, demT27, demB27, h27, l27)

var supT28 = array.new_float()
var supB28 = array.new_float()
var demT28 = array.new_float()
var demB28 = array.new_float()
f_track(supT28, supB28, demT28, demB28, sig28, zh28, zl28, zt28, zt28[1])
[t28s, t28d] = f_touched(supT28, supB28, demT28, demB28, h28, l28)
sRaw28 = f_status_calc(supT28, supB28, demT28, demB28, c28, atr28)
s28 = f_was_status(t28s, t28d, sRaw28)
f_break(supT28, supB28, demT28, demB28, h28, l28)

var supT29 = array.new_float()
var supB29 = array.new_float()
var demT29 = array.new_float()
var demB29 = array.new_float()
f_track(supT29, supB29, demT29, demB29, sig29, zh29, zl29, zt29, zt29[1])
[t29s, t29d] = f_touched(supT29, supB29, demT29, demB29, h29, l29)
sRaw29 = f_status_calc(supT29, supB29, demT29, demB29, c29, atr29)
s29 = f_was_status(t29s, t29d, sRaw29)
f_break(supT29, supB29, demT29, demB29, h29, l29)

var supT30 = array.new_float()
var supB30 = array.new_float()
var demT30 = array.new_float()
var demB30 = array.new_float()
f_track(supT30, supB30, demT30, demB30, sig30, zh30, zl30, zt30, zt30[1])
[t30s, t30d] = f_touched(supT30, supB30, demT30, demB30, h30, l30)
sRaw30 = f_status_calc(supT30, supB30, demT30, demB30, c30, atr30)
s30 = f_was_status(t30s, t30d, sRaw30)
f_break(supT30, supB30, demT30, demB30, h30, l30)

var supT31 = array.new_float()
var supB31 = array.new_float()
var demT31 = array.new_float()
var demB31 = array.new_float()
f_track(supT31, supB31, demT31, demB31, sig31, zh31, zl31, zt31, zt31[1])
[t31s, t31d] = f_touched(supT31, supB31, demT31, demB31, h31, l31)
sRaw31 = f_status_calc(supT31, supB31, demT31, demB31, c31, atr31)
s31 = f_was_status(t31s, t31d, sRaw31)
f_break(supT31, supB31, demT31, demB31, h31, l31)

var supT32 = array.new_float()
var supB32 = array.new_float()
var demT32 = array.new_float()
var demB32 = array.new_float()
f_track(supT32, supB32, demT32, demB32, sig32, zh32, zl32, zt32, zt32[1])
[t32s, t32d] = f_touched(supT32, supB32, demT32, demB32, h32, l32)
sRaw32 = f_status_calc(supT32, supB32, demT32, demB32, c32, atr32)
s32 = f_was_status(t32s, t32d, sRaw32)
f_break(supT32, supB32, demT32, demB32, h32, l32)

var supT33 = array.new_float()
var supB33 = array.new_float()
var demT33 = array.new_float()
var demB33 = array.new_float()
f_track(supT33, supB33, demT33, demB33, sig33, zh33, zl33, zt33, zt33[1])
[t33s, t33d] = f_touched(supT33, supB33, demT33, demB33, h33, l33)
sRaw33 = f_status_calc(supT33, supB33, demT33, demB33, c33, atr33)
s33 = f_was_status(t33s, t33d, sRaw33)
f_break(supT33, supB33, demT33, demB33, h33, l33)

var supT34 = array.new_float()
var supB34 = array.new_float()
var demT34 = array.new_float()
var demB34 = array.new_float()
f_track(supT34, supB34, demT34, demB34, sig34, zh34, zl34, zt34, zt34[1])
[t34s, t34d] = f_touched(supT34, supB34, demT34, demB34, h34, l34)
sRaw34 = f_status_calc(supT34, supB34, demT34, demB34, c34, atr34)
s34 = f_was_status(t34s, t34d, sRaw34)
f_break(supT34, supB34, demT34, demB34, h34, l34)

var supT35 = array.new_float()
var supB35 = array.new_float()
var demT35 = array.new_float()
var demB35 = array.new_float()
f_track(supT35, supB35, demT35, demB35, sig35, zh35, zl35, zt35, zt35[1])
[t35s, t35d] = f_touched(supT35, supB35, demT35, demB35, h35, l35)
sRaw35 = f_status_calc(supT35, supB35, demT35, demB35, c35, atr35)
s35 = f_was_status(t35s, t35d, sRaw35)
f_break(supT35, supB35, demT35, demB35, h35, l35)

var supT36 = array.new_float()
var supB36 = array.new_float()
var demT36 = array.new_float()
var demB36 = array.new_float()
f_track(supT36, supB36, demT36, demB36, sig36, zh36, zl36, zt36, zt36[1])
[t36s, t36d] = f_touched(supT36, supB36, demT36, demB36, h36, l36)
sRaw36 = f_status_calc(supT36, supB36, demT36, demB36, c36, atr36)
s36 = f_was_status(t36s, t36d, sRaw36)
f_break(supT36, supB36, demT36, demB36, h36, l36)

var supT37 = array.new_float()
var supB37 = array.new_float()
var demT37 = array.new_float()
var demB37 = array.new_float()
f_track(supT37, supB37, demT37, demB37, sig37, zh37, zl37, zt37, zt37[1])
[t37s, t37d] = f_touched(supT37, supB37, demT37, demB37, h37, l37)
sRaw37 = f_status_calc(supT37, supB37, demT37, demB37, c37, atr37)
s37 = f_was_status(t37s, t37d, sRaw37)
f_break(supT37, supB37, demT37, demB37, h37, l37)

var supT38 = array.new_float()
var supB38 = array.new_float()
var demT38 = array.new_float()
var demB38 = array.new_float()
f_track(supT38, supB38, demT38, demB38, sig38, zh38, zl38, zt38, zt38[1])
[t38s, t38d] = f_touched(supT38, supB38, demT38, demB38, h38, l38)
sRaw38 = f_status_calc(supT38, supB38, demT38, demB38, c38, atr38)
s38 = f_was_status(t38s, t38d, sRaw38)
f_break(supT38, supB38, demT38, demB38, h38, l38)

var supT39 = array.new_float()
var supB39 = array.new_float()
var demT39 = array.new_float()
var demB39 = array.new_float()
f_track(supT39, supB39, demT39, demB39, sig39, zh39, zl39, zt39, zt39[1])
[t39s, t39d] = f_touched(supT39, supB39, demT39, demB39, h39, l39)
sRaw39 = f_status_calc(supT39, supB39, demT39, demB39, c39, atr39)
s39 = f_was_status(t39s, t39d, sRaw39)
f_break(supT39, supB39, demT39, demB39, h39, l39)

var supT40 = array.new_float()
var supB40 = array.new_float()
var demT40 = array.new_float()
var demB40 = array.new_float()
f_track(supT40, supB40, demT40, demB40, sig40, zh40, zl40, zt40, zt40[1])
[t40s, t40d] = f_touched(supT40, supB40, demT40, demB40, h40, l40)
sRaw40 = f_status_calc(supT40, supB40, demT40, demB40, c40, atr40)
s40 = f_was_status(t40s, t40d, sRaw40)
f_break(supT40, supB40, demT40, demB40, h40, l40)

var box[] supplyBoxes = array.new<box>()
var box[] demandBoxes = array.new<box>()

freshSig = chSig != 0 and not na(chZT) and nz(chZT, 0) != nz(chZT[1], 0)

if drawZones and freshSig and chSig == 1
    b = box.new(chZT, chZH, time, chZL, border_color=na, border_width=0, bgcolor=supplyCol, extend=extend.right, xloc=xloc.bar_time)
    array.push(supplyBoxes, b)
    if array.size(supplyBoxes) > maxDrawZones
        box.delete(array.shift(supplyBoxes))

if drawZones and freshSig and chSig == 2
    b = box.new(chZT, chZH, time, chZL, border_color=na, border_width=0, bgcolor=demandCol, extend=extend.right, xloc=xloc.bar_time)
    array.push(demandBoxes, b)
    if array.size(demandBoxes) > maxDrawZones
        box.delete(array.shift(demandBoxes))

f_checkBreak(array<box> arr, bool isSupply) =>
    hiProbe = useWicks ? high : math.max(open, close)
    loProbe = useWicks ? low  : math.min(open, close)
    pct = breakPct / 100.0
    i = 0
    while i < array.size(arr)
        bx   = array.get(arr, i)
        top  = box.get_top(bx)
        bot  = box.get_bottom(bx)
        hgt  = top - bot
        broken = false
        if isSupply
            thr = bot + hgt * pct
            broken := hiProbe >= thr
        else
            thr = top - hgt * pct
            broken := loProbe <= thr
        if broken
            box.set_right(bx, time)
            box.set_extend(bx, extend.none)
            array.remove(arr, i)
            i := i
        else
            i := i + 1

if barstate.isconfirmed
    f_checkBreak(supplyBoxes, true)
    f_checkBreak(demandBoxes, false)

f_pos(p) =>
    p == "top_right"     ? position.top_right    :
     p == "top_left"      ? position.top_left     :
     p == "bottom_right"  ? position.bottom_right :
     p == "bottom_left"   ? position.bottom_left  :
     p == "middle_right"  ? position.middle_right :
     position.middle_left

f_size(s) =>
    s == "tiny"   ? size.tiny   :
     s == "small"  ? size.small  :
     s == "normal" ? size.normal :
     s == "large"  ? size.large  :
     size.huge

f_short(sym) =>
    if not shortNames
        sym
    else
        idx = str.pos(sym, ":")
        na(idx) ? sym : str.substring(sym, idx + 1)

f_label(st) =>
    st == 1 ? "IN SUPPLY"   :
     st == 2 ? "IN DEMAND"   :
     st == 3 ? "NEAR SUPPLY" :
     st == 4 ? "NEAR DEMAND" :
     st == 5 ? "WAS IN SUPPLY" :
     st == 6 ? "WAS IN DEMAND" :
     ""

f_bg(st) =>
    st == 1 ? color.new(color.red,   20) :
     st == 2 ? color.new(color.green, 20) :
     st == 3 ? color.new(color.red,   60) :
     st == 4 ? color.new(color.green, 60) :
     st == 5 ? color.new(color.orange, 50) :
     st == 6 ? color.new(color.aqua,   50) :
     color.new(color.gray,  70)

var table tbl = na

if barstate.islast
    if not na(tbl)
        table.delete(tbl)

    syms  = array.from(sym1, sym2, sym3, sym4, sym5, sym6, sym7, sym8, sym9, sym10, sym11, sym12, sym13, sym14, sym15, sym16, sym17, sym18, sym19, sym20, sym21, sym22, sym23, sym24, sym25, sym26, sym27, sym28, sym29, sym30, sym31, sym32, sym33, sym34, sym35, sym36, sym37, sym38, sym39, sym40)
    stats = array.from(s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18, s19, s20, s21, s22, s23, s24, s25, s26, s27, s28, s29, s30, s31, s32, s33, s34, s35, s36, s37, s38, s39, s40)

    int visible = 0
    for i = 0 to 39
        sym = array.get(syms, i)
        st  = array.get(stats, i)
        if sym != "" and (not showOnlyHits or st != 0)
            visible += 1

    rowCount = math.max(visible + 1, 2)
    tbl := table.new(f_pos(tblPos), columns=2, rows=rowCount, bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

    table.cell(tbl, 0, 0, "Symbol  (" + selTF + ")", text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=f_size(tblSize))
    table.cell(tbl, 1, 0, "Status",                  text_color=color.white, bgcolor=color.new(color.gray, 30), text_size=f_size(tblSize))

    int row = 1
    for i = 0 to 39
        sym = array.get(syms, i)
        st  = array.get(stats, i)
        if sym == ""
            continue
        if showOnlyHits and st == 0
            continue

        table.cell(tbl, 0, row, f_short(sym), text_color=color.white, bgcolor=color.new(color.black, 50), text_size=f_size(tblSize))
        table.cell(tbl, 1, row, f_label(st),  text_color=color.white, bgcolor=f_bg(st),                    text_size=f_size(tblSize))
        row += 1

    if row == 1
        table.cell(tbl, 0, 1, "No hits", text_color=color.gray, bgcolor=color.new(color.black, 50), text_size=f_size(tblSize))
        table.cell(tbl, 1, 1, "—",       text_color=color.gray, bgcolor=color.new(color.black, 50), text_size=f_size(tblSize))
````
