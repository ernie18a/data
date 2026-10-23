//+------------------------------------------------------------------+
//|                                                  StockStruct.mqh |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property description "Project Stocks"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
struct SBackground
  {
   int      FontSizeV;                             // using font size for column
   int      FontSizeH;                             // using font size for column
   string   FontNameV;                             // using font name for column
   string   FontNameH;                             // using font name for column
   string   nPrefix;                               // common prefix name
   int      iStockCanvasH;                         // stock canvas Height
   int      iStockLabelIndH;                       // stock label indent height
   int      iStockLabelIndL;                       // stock label indent left
   int      iStockLabelIndW;                       // stock label indent width
   color    cFgTextActive;                         // FG active label color
   color    cFgTextSleep;                          // FG sleeping label color
   color    cBgRectActive;                         // BG active rectangle color
   color    cBgRectSleep;                          // BG sleeping rectangle color
  };
enum STOCK_NAME
  {
   Tokio=0,
   Singapore=1,
   Shanghai=2,
   Dubai=3,
   Moscow=4,
   London=5,
   Zurich=6,
   Frankfurt=7,
   Yohannensburg=8,
   Riyadh=9,
   NewYork=10,
   Toronto=11,
   Chicago=12,
   Wellington=13,
   Sidney=14
  };
