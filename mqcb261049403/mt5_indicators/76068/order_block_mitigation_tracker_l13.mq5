//+------------------------------------------------------------------+
//|                               Order_Block_Mitigation_Tracker.mq5 |
//|                                                   Adeolu Gbadebo |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Adeolu Gbadebo"
#property link       ""
#property version    "1.00"
#property description "Detects institutional order blocks from ATR-filtered impulse moves and tracks their mitigation state live on the chart."

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Bullish Mitigation"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrLimeGreen
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID

#property indicator_label2  "Bearish Mitigation"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_width2  2
#property indicator_style2  STYLE_SOLID

//--- mitigation trigger method
enum ENUM_MITIGATION_MODE
  {
   MITIGATION_WICK = 0,   // Wick touch triggers mitigation
   MITIGATION_CLOSE = 1   // Candle close inside zone triggers mitigation
  };

//--- inputs
input group "=== Order Block Detection ==="
input int    InpLookbackBars        = 150;    // Bars scanned for new order blocks
input int    InpATRPeriod           = 14;     // ATR period used for impulse filtering
input double InpImpulseMultiplier   = 1.5;    // ATR multiplier required to qualify an impulse leg
input int    InpMaxActiveBlocks     = 12;     // Maximum concurrent order blocks tracked

input group "=== Mitigation Settings ==="
input ENUM_MITIGATION_MODE InpMitigationMode = MITIGATION_WICK; // Mitigation trigger method
input bool   InpExtendUnmitigated   = true;   // Extend unmitigated boxes to the current bar
input bool   InpKeepMitigatedBoxes  = true;   // Keep mitigated boxes visible, faded out
input int    InpMaxBarsToKeepMitigated = 300; // Bars to retain a mitigated box before deletion

input group "=== Visuals ==="
input color  InpBullishColor        = clrDodgerBlue;  // Bullish order block fill color
input color  InpBearishColor        = clrOrangeRed;    // Bearish order block fill color
input color  InpMitigatedColor      = clrSilver;       // Color once a block is mitigated
input string InpObjectPrefix        = "OBMT_";         // Prefix used for all chart object names

//--- indicator buffers
double BufferBullMit[];
double BufferBearMit[];

//--- order block record
struct OrderBlock
  {
   datetime          time1;      // candle open time of the OB candle
   datetime          time2;      // right edge time (extends while unmitigated)
   double            zoneHigh;
   double            zoneLow;
   bool              isBullish;
   bool              mitigated;
   datetime          mitigationTime;
   string            boxName;
   long              id;
  };

OrderBlock g_blocks[];
long       g_nextId   = 1;
int        g_atrHandle = INVALID_HANDLE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufferBullMit, INDICATOR_DATA);
   SetIndexBuffer(1, BufferBearMit, INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_ARROW, 233);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -15);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   PlotIndexSetInteger(1, PLOT_ARROW, 234);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 15);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);

   ArraySetAsSeries(BufferBullMit, false);
   ArraySetAsSeries(BufferBearMit, false);

   g_atrHandle = iATR(_Symbol, _Period, InpATRPeriod);
   if(g_atrHandle == INVALID_HANDLE)
     {
      Print("Order Block Mitigation Tracker: failed to create ATR handle, error ", GetLastError());
      return(INIT_FAILED);
     }

   ArrayResize(g_blocks, 0);
   IndicatorSetString(INDICATOR_SHORTNAME, "Order Block Mitigation Tracker");

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(g_atrHandle != INVALID_HANDLE)
      IndicatorRelease(g_atrHandle);

   ObjectsDeleteAll(0, InpObjectPrefix);
   ArrayFree(g_blocks);
  }

//+------------------------------------------------------------------+
//| Helper: create or update the rectangle box for a block           |
//+------------------------------------------------------------------+
void DrawBlockBox(OrderBlock &blk)
  {
   color clr = blk.mitigated ? InpMitigatedColor : (blk.isBullish ? InpBullishColor : InpBearishColor);

   if(ObjectFind(0, blk.boxName) < 0)
     {
      ObjectCreate(0, blk.boxName, OBJ_RECTANGLE, 0, blk.time1, blk.zoneHigh, blk.time2, blk.zoneLow);
      ObjectSetInteger(0, blk.boxName, OBJPROP_BACK, true);
      ObjectSetInteger(0, blk.boxName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, blk.boxName, OBJPROP_HIDDEN, true);
     }

   ObjectSetInteger(0, blk.boxName, OBJPROP_TIME, 0, blk.time1);
   ObjectSetDouble(0, blk.boxName, OBJPROP_PRICE, 0, blk.zoneHigh);
   ObjectSetInteger(0, blk.boxName, OBJPROP_TIME, 1, blk.time2);
   ObjectSetDouble(0, blk.boxName, OBJPROP_PRICE, 1, blk.zoneLow);
   ObjectSetInteger(0, blk.boxName, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, blk.boxName, OBJPROP_FILL, !blk.mitigated);
   ObjectSetInteger(0, blk.boxName, OBJPROP_STYLE, blk.mitigated ? STYLE_DOT : STYLE_SOLID);
  }

//+------------------------------------------------------------------+
//| Helper: remove the oldest block to respect InpMaxActiveBlocks    |
//+------------------------------------------------------------------+
void EnforceMaxBlocks()
  {
   int total = ArraySize(g_blocks);
   while(total > InpMaxActiveBlocks)
     {
      ObjectDelete(0, g_blocks[0].boxName);
      for(int i = 0; i < total - 1; i++)
         g_blocks[i] = g_blocks[i + 1];
      total--;
      ArrayResize(g_blocks, total);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                 const int prev_calculated,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[])
  {
   if(rates_total < InpATRPeriod + 5)
      return(0);

   ArraySetAsSeries(time,  false);
   ArraySetAsSeries(open,  false);
   ArraySetAsSeries(high,  false);
   ArraySetAsSeries(low,   false);
   ArraySetAsSeries(close, false);

   double atr[];
   ArraySetAsSeries(atr, false);
   int atrCount = MathMin(rates_total, InpLookbackBars + InpATRPeriod + 5);
   if(CopyBuffer(g_atrHandle, 0, 0, rates_total, atr) <= 0)
      return(prev_calculated);

   int start;
   if(prev_calculated <= 1)
      start = MathMax(InpATRPeriod + 2, rates_total - InpLookbackBars);
   else
      start = MathMax(InpATRPeriod + 2, prev_calculated - 2);

   for(int i = start; i < rates_total; i++)
     {
      BufferBullMit[i] = EMPTY_VALUE;
      BufferBearMit[i] = EMPTY_VALUE;
     }

   //--- 1) Detect new order blocks on freshly closed bars
   for(int i = start; i < rates_total - 1; i++)
     {
      if(i - 1 < 0 || atr[i] <= 0)
         continue;

      double body = close[i] - open[i];

      //--- bullish impulse leg -> bearish candle immediately before it is the bullish OB
      if(body >= atr[i] * InpImpulseMultiplier)
        {
         int obIdx = i - 1;
         if(close[obIdx] < open[obIdx])
            RegisterBlock(true, time[obIdx], time[rates_total - 1], high[obIdx], low[obIdx]);
        }

      //--- bearish impulse leg -> bullish candle immediately before it is the bearish OB
      if(-body >= atr[i] * InpImpulseMultiplier)
        {
         int obIdx = i - 1;
         if(close[obIdx] > open[obIdx])
            RegisterBlock(false, time[obIdx], time[rates_total - 1], high[obIdx], low[obIdx]);
        }
     }

   //--- 2) Update mitigation state for every active block against the latest bars
   int checkFrom = MathMax(0, start - 1);
   for(int b = 0; b < ArraySize(g_blocks); b++)
     {
      if(g_blocks[b].mitigated)
         continue;

      for(int i = checkFrom; i < rates_total; i++)
        {
         if(time[i] <= g_blocks[b].time1)
            continue;

         bool hit = false;
         if(g_blocks[b].isBullish)
           {
            double trigger = (InpMitigationMode == MITIGATION_WICK) ? low[i] : MathMin(open[i], close[i]);
            if(trigger <= g_blocks[b].zoneHigh)
               hit = true;
           }
         else
           {
            double trigger = (InpMitigationMode == MITIGATION_WICK) ? high[i] : MathMax(open[i], close[i]);
            if(trigger >= g_blocks[b].zoneLow)
               hit = true;
           }

         if(hit)
           {
            g_blocks[b].mitigated      = true;
            g_blocks[b].mitigationTime = time[i];
            g_blocks[b].time2          = time[i];

            if(g_blocks[b].isBullish)
               BufferBullMit[i] = low[i];
            else
               BufferBearMit[i] = high[i];

            break;
           }
        }
     }

   //--- 3) Refresh visuals and prune stale mitigated boxes
   datetime lastTime = time[rates_total - 1];
   for(int b = ArraySize(g_blocks) - 1; b >= 0; b--)
     {
      if(!g_blocks[b].mitigated && InpExtendUnmitigated)
         g_blocks[b].time2 = lastTime;

      if(g_blocks[b].mitigated && !InpKeepMitigatedBoxes)
        {
         ObjectDelete(0, g_blocks[b].boxName);
         RemoveBlockAt(b);
         continue;
        }

      if(g_blocks[b].mitigated && InpMaxBarsToKeepMitigated > 0)
        {
         int barsSince = iBarShift(_Symbol, _Period, g_blocks[b].mitigationTime, true);
         if(barsSince >= 0 && barsSince > InpMaxBarsToKeepMitigated)
           {
            ObjectDelete(0, g_blocks[b].boxName);
            RemoveBlockAt(b);
            continue;
           }
        }

      DrawBlockBox(g_blocks[b]);
     }

   EnforceMaxBlocks();

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Register a new block if an equivalent one is not already tracked |
//+------------------------------------------------------------------+
void RegisterBlock(const bool isBullish, const datetime t1, const datetime t2,
                    const double zHigh, const double zLow)
  {
   for(int b = 0; b < ArraySize(g_blocks); b++)
     {
      if(g_blocks[b].time1 == t1 && g_blocks[b].isBullish == isBullish)
         return; // already tracked
     }

   int n = ArraySize(g_blocks);
   ArrayResize(g_blocks, n + 1);

   g_blocks[n].time1          = t1;
   g_blocks[n].time2          = t2;
   g_blocks[n].zoneHigh       = zHigh;
   g_blocks[n].zoneLow        = zLow;
   g_blocks[n].isBullish      = isBullish;
   g_blocks[n].mitigated      = false;
   g_blocks[n].mitigationTime = 0;
   g_blocks[n].id             = g_nextId++;
   g_blocks[n].boxName        = InpObjectPrefix + (isBullish ? "BULL_" : "BEAR_") + IntegerToString((int)g_blocks[n].id);
  }

//+------------------------------------------------------------------+
//| Remove a block record and its chart object by array index        |
//+------------------------------------------------------------------+
void RemoveBlockAt(const int idx)
  {
   int total = ArraySize(g_blocks);
   if(idx < 0 || idx >= total)
      return;

   for(int i = idx; i < total - 1; i++)
      g_blocks[i] = g_blocks[i + 1];

   ArrayResize(g_blocks, total - 1);
  }
//+------------------------------------------------------------------+
