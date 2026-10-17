# ICTina [Anastasia]

- url: https://www.tradingview.com/script/1gEb0DrV-ICTina-Anastasia/
- type: indicator
- pine_id: PUB;5a6f5d0150ce498a9332e0fdc7eba4ba
- version: 4.0

## Description

A comprehensive price action indicator built on ICT (Inner Circle Trader) methodology with ICC (Indication, Correction, Continuation) framework integration. Designed for traders who analyze on the 1H, confirm on the 5M, and execute on the 1M.

## Source Code

````pine
//@version=6
indicator("ICT Liquidity Trade Assistant [Anastasia]", overlay=true,
          max_boxes_count=500, max_lines_count=500, max_labels_count=500,
          max_bars_back=500)
plot(na, title="Compile Anchor", display=display.none)
//
//  ICT LIQUIDITY TRADE ASSISTANT  v3.1
//  Full ICT Methodology + ICC Framework
//  Fixed: OB detection, BOS/CHoCH sequencing, CE references, session colors,
//         confirmed-bar guards, SMT divergence, HTF bias, static alerts,
//         instrument-aware price labels, zone pruning, confirmation modes,
//         setup quality grading, CE entry engine, guided bubbles,
//         golden-zone confluence, TP2 targeting, performance guards,
//         0-100 setup grading, risk-aware display, trade-plan presets,
//         FVG filters, TP3/status tracking, dollar-risk controls,
//         cockpit UI modes/themes, simplified school grades,
//         and setup safety gates
//
//
// INPUTS
//
grp1 = "Market Structure"
grp2 = "Order Blocks"
grp3 = "Fair Value Gaps"
grp4 = "Liquidity and Sweeps"
grp5 = "Sessions Hours UTC"
grp5c= "Sessions Colors"
grp5k= "ICT Killzones"
grp6 = "Daily and Weekly Levels"
grp7 = "Trade Setup Entry SL TP"
grp7r = "Risk Management"
grp8 = "Fib and Golden Zone"
grp9 = "Display"
grp9s = "Sniper Cockpit"
grp10 = "Zone Style"
grp11 = "Backtest Stats"
//    Structure
i_swingLen   = input.int  (5,    "Swing Pivot Length",               group=grp1, minval=2, maxval=20)
i_showLabels = input.bool (true, "Show HH / HL / LH / LL Labels",    group=grp1)
i_showZigZag = input.bool (true, "Show Structure ZigZag",             group=grp1)
i_msFibFactor = input.float(0.33, "MSB Fib Break Confirmation",       group=grp1, minval=0, maxval=1, step=0.01)
i_showBOS    = input.bool (true, "Show Break of Structure (BOS)",     group=grp1)
i_showCHoCH  = input.bool (true, "Show Change of Character (CHoCH)", group=grp1)
i_showICC    = input.bool (true, "Show ICC Phases I C D",             group=grp1)
i_htfTf      = input.timeframe("60", "Higher-Timeframe Bias",         group=grp1)
i_showHTF    = input.bool (true, "Show HTF Bias In Trend Label",      group=grp1)
i_useEMAFilter = input.bool(false, "Use EMA Bias Filter",             group=grp1)
i_useVWAPFilter = input.bool(false, "Use VWAP Bias Filter",           group=grp1)
i_emaFastLen = input.int(21, "EMA Fast Length",                       group=grp1, minval=1, maxval=200)
i_emaSlowLen = input.int(50, "EMA Slow Length",                       group=grp1, minval=2, maxval=300)
//    Order Blocks
i_showBullOB = input.bool (true,  "Show Bullish Order Blocks",        group=grp2)
i_showBearOB = input.bool (true,  "Show Bearish Order Blocks",        group=grp2)
i_showRej    = input.bool (true,  "Show Rejection Blocks",            group=grp2)
i_obExtend   = input.int  (40,    "OB Extend Right (bars)",           group=grp2, minval=5, maxval=200)
i_obUseWicks = input.bool (true,  "Use Full Candle OB Range",          group=grp2)
i_wickPct    = input.float(0.65,  "Rejection Wick Threshold 0 to 1",   group=grp2, minval=0.5, maxval=0.95, step=0.05)
//    FVG
i_showFVG    = input.bool (true,  "Show Fair Value Gaps",             group=grp3)
i_showIFVG   = input.bool (false, "Keep Filled FVGs as Inverse FVGs", group=grp3)
i_fvgExtend  = input.int  (80,    "FVG Extend Right (bars)",          group=grp3, minval=5, maxval=300)
i_minFVGTicks = input.int (0,     "Minimum FVG Size (ticks, 0 = off)", group=grp3, minval=0, maxval=500)
i_fvgThresholdPer = input.float(0.0, "FVG Threshold Percent",          group=grp3, minval=0, maxval=100, step=0.1)
i_fvgAutoThreshold = input.bool(false, "Auto FVG Threshold",           group=grp3)
i_fvgAfterDisplacement = input.bool(false, "Only Show FVGs After Displacement", group=grp3)
i_emphasizeQualityFVG = input.bool(true, "Gold Border on Sweep / Displacement FVGs", group=grp3)
i_fvgFillMethod = input.string("Wick Touch", "FVG Fill / Invalidation Method", options=["Wick Touch", "Close Through"], group=grp3)
i_showLatestOnlyFVG = input.bool(false, "Show Latest FVG Only",         group=grp3)
i_showFVGCE = input.bool(true, "Show FVG CE Guide Lines",               group=grp3)
i_showFVGMitigationLevels = input.bool(false, "Show FVG Mitigation Lines", group=grp3)
i_showLastUnmitigatedFVG = input.int(0, "Show Last Unmitigated FVG Levels", group=grp3, minval=0, maxval=20)
//    Liquidity
i_showEQL    = input.bool (true,  "Show Equal Highs and Lows",         group=grp4)
i_showBSL    = input.bool (true,  "Show BSL and SSL Labels on Swings", group=grp4)
i_showSweep  = input.bool (true,  "Show Liquidity Sweeps + CE Level", group=grp4)
i_showSMT    = input.bool (true,  "Show SMT Divergence",              group=grp4)
i_showLiquidityZones = input.bool(true, "Show Liquidity Wick Zones",  group=grp4)
i_liqAreaMode = input.string("Wick Extremity", "Liquidity Zone Area", options=["Wick Extremity", "Full Range"], group=grp4)
i_useSMTComparison = input.bool(false, "Use External SMT Symbol",      group=grp4)
i_smtSymbol  = input.symbol("CME_MINI:NQ1!", "SMT Comparison Symbol", group=grp4)
i_smtWindow  = input.int   (20,   "SMT Valid Window (bars)",          group=grp4, minval=1, maxval=200)
i_eqThresh   = input.float(0.05,  "EQL Sensitivity (%)",              group=grp4, minval=0.01, maxval=0.5, step=0.01)
//    Sessions Hours
i_showLondon = input.bool (true,  "Show London Session",              group=grp5)
i_lonOpen    = input.int  (7,     "London Open UTC Hour",             group=grp5, minval=0, maxval=23)
i_lonClose   = input.int  (16,    "London Close UTC Hour",            group=grp5, minval=0, maxval=23)
i_showNY     = input.bool (true,  "Show New York Session",            group=grp5)
i_nyOpen     = input.int  (13,    "NY Open UTC Hour",                 group=grp5, minval=0, maxval=23)
i_nyClose    = input.int  (21,    "NY Close UTC Hour",                group=grp5, minval=0, maxval=23)
i_showAsia   = input.bool (true,  "Show Asia Session",                group=grp5)
i_asOpen     = input.int  (0,     "Asia Open UTC Hour",               group=grp5, minval=0, maxval=23)
i_asClose    = input.int  (7,     "Asia Close UTC Hour",              group=grp5, minval=0, maxval=23)
````
