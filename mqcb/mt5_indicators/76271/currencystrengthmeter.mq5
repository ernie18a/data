//+------------------------------------------------------------------+
//|                                        CurrencyStrengthMeter.mq5 |
//|                        Copyright 2026, MQL5 Code Base Submission |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026"
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property description "Ranks the 8 major currencies by relative strength, derived from the "
#property description "average percentage change of every available cross pair, and displays "
#property description "them as a live ranked bar panel on the chart."
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//+------------------------------------------------------------------+
//| Input parameters                                                 |
//+------------------------------------------------------------------+
input group "=== Strength Calculation ==="
input ENUM_TIMEFRAMES InpCalcTimeframe    = PERIOD_H1;  // Timeframe Used to Measure Change
input int              InpLookbackBars    = 24;          // Lookback (bars back to compare against)
input bool              InpUpdateOnNewBarOnly = true;    // Recalculate Only on a New Chart Bar

input group "=== Panel Layout ==="
input ENUM_BASE_CORNER InpPanelCorner    = CORNER_LEFT_UPPER; // Panel Corner
input int               InpPanelXDistance = 12;   // Panel X Distance (pixels)
input int               InpPanelYDistance = 18;   // Panel Y Distance (pixels)
input int               InpBarMaxWidth    = 100;  // Max Bar Width (pixels, strongest currency)
input int               InpBarHeight      = 14;   // Bar Height (pixels)
input int               InpFontSize       = 8;    // Font Size

input group "=== Panel Colors ==="
input color  InpStrongColor  = clrLime;        // Bar Color — Above-Average Strength
input color  InpWeakColor    = clrRed;         // Bar Color — Below-Average Strength
input color  InpPanelTextColor = clrWhite;     // Text Color
input color  InpPanelBgColor   = C'20,20,20';  // Panel Background Color

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
#define CURRENCY_COUNT 8
string g_Currencies[CURRENCY_COUNT] = {"USD", "EUR", "GBP", "JPY", "CHF", "AUD", "CAD", "NZD"};

string g_Prefix = "CSM_";

//--- pre-validated pair list, built once in OnInit so OnCalculate never has
//--- to repeat SymbolInfoInteger() existence checks on every refresh
string g_PairName[CURRENCY_COUNT * (CURRENCY_COUNT - 1) / 2];
int    g_PairBaseIdx[CURRENCY_COUNT * (CURRENCY_COUNT - 1) / 2];
int    g_PairQuoteIdx[CURRENCY_COUNT * (CURRENCY_COUNT - 1) / 2];
int    g_PairCount = 0;

double   g_Strength[CURRENCY_COUNT];
datetime g_LastBarTime = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                        |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpLookbackBars < 1)
     {
      Alert("CurrencyStrengthMeter: 'Lookback' must be at least 1 bar.");
      return(INIT_PARAMETERS_INCORRECT);
     }

   IndicatorSetString(INDICATOR_SHORTNAME, "Currency Strength Meter");

   BuildPairList();
   CreatePanelSkeleton();

   g_LastBarTime = 0; // forces a full calculation on the very first OnCalculate call

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- remove every chart object this indicator has created, identified by its unique prefix
   ObjectsDeleteAll(0, g_Prefix);
   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                             |
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
   if(rates_total < 1)
      return(0);

//--- the strength calculation reads a small, fixed list of currency pairs, not
//--- the current chart's own history, so cost per refresh is constant either
//--- way; InpUpdateOnNewBarOnly simply throttles how often that refresh runs
   bool shouldUpdate = true;

   if(InpUpdateOnNewBarOnly)
     {
      datetime currentBarTime = time[rates_total - 1];
      shouldUpdate = (prev_calculated == 0 || currentBarTime != g_LastBarTime);
      g_LastBarTime = currentBarTime;
     }

   if(shouldUpdate)
     {
      CalculateStrength();
      UpdatePanel();
     }

   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Builds the list of currency-pair symbols that actually exist on  |
//| this broker, so later refreshes only ever touch valid symbols    |
//+------------------------------------------------------------------+
void BuildPairList()
  {
   g_PairCount = 0;

   for(int i = 0; i < CURRENCY_COUNT; i++)
     {
      for(int j = i + 1; j < CURRENCY_COUNT; j++)
        {
         string pairForward = g_Currencies[i] + g_Currencies[j];
         string pairReverse = g_Currencies[j] + g_Currencies[i];
         string chosen = "";

         if(SymbolInfoInteger(pairForward, SYMBOL_EXIST))
            chosen = pairForward;
         else
            if(SymbolInfoInteger(pairReverse, SYMBOL_EXIST))
               chosen = pairReverse;

         if(chosen == "")
            continue; // this cross is simply not offered by the broker, skip it

         SymbolSelect(chosen, true); // make sure it's in Market Watch so history loads

         g_PairName[g_PairCount]     = chosen;
         g_PairBaseIdx[g_PairCount]  = i;
         g_PairQuoteIdx[g_PairCount] = j;
         g_PairCount++;
        }
     }
  }

//+------------------------------------------------------------------+
//| Recomputes the 8 currency strength scores from the current       |
//| percentage change of every validated pair                        |
//+------------------------------------------------------------------+
void CalculateStrength()
  {
   double sumScore[CURRENCY_COUNT];
   int    countScore[CURRENCY_COUNT];
   ArrayInitialize(sumScore, 0.0);
   ArrayInitialize(countScore, 0);

   for(int p = 0; p < g_PairCount; p++)
     {
      double closeNow  = iClose(g_PairName[p], InpCalcTimeframe, 0);
      double closeBack = iClose(g_PairName[p], InpCalcTimeframe, InpLookbackBars);

      if(closeNow <= 0.0 || closeBack <= 0.0)
         continue; // history not ready yet for this symbol, skip this refresh

      double pctChange = (closeNow - closeBack) / closeBack * 100.0;

      //--- g_PairName[p] is stored as BaseQuote; the base currency gains what
      //--- the quote currency loses, so the contribution is symmetric
      int baseIdx  = g_PairBaseIdx[p];
      int quoteIdx = g_PairQuoteIdx[p];

      sumScore[baseIdx]  += pctChange;
      countScore[baseIdx]++;
      sumScore[quoteIdx] -= pctChange;
      countScore[quoteIdx]++;
     }

   for(int c = 0; c < CURRENCY_COUNT; c++)
      g_Strength[c] = (countScore[c] > 0) ? sumScore[c] / countScore[c] : 0.0;
  }

//+------------------------------------------------------------------+
//| Creates the static parts of the panel (background + row objects) |
//| once; refreshes only move/re-color/re-label them afterwards      |
//+------------------------------------------------------------------+
void CreatePanelSkeleton()
  {
   string bgName = g_Prefix + "BG";
   int panelHeight = 20 + CURRENCY_COUNT * (InpBarHeight + 4) + 6;
   int panelWidth  = InpBarMaxWidth + 90;

   if(ObjectFind(0, bgName) < 0)
     {
      ObjectCreate(0, bgName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, bgName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, bgName, OBJPROP_XDISTANCE, InpPanelXDistance - 6);
      ObjectSetInteger(0, bgName, OBJPROP_YDISTANCE, InpPanelYDistance - 6);
      ObjectSetInteger(0, bgName, OBJPROP_XSIZE, panelWidth);
      ObjectSetInteger(0, bgName, OBJPROP_YSIZE, panelHeight);
      ObjectSetInteger(0, bgName, OBJPROP_BGCOLOR, InpPanelBgColor);
      ObjectSetInteger(0, bgName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, bgName, OBJPROP_COLOR, clrDimGray);
      ObjectSetInteger(0, bgName, OBJPROP_BACK, false);
      ObjectSetInteger(0, bgName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, bgName, OBJPROP_HIDDEN, true);
     }

   string titleName = g_Prefix + "Title";
   if(ObjectFind(0, titleName) < 0)
     {
      ObjectCreate(0, titleName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, titleName, OBJPROP_CORNER, InpPanelCorner);
      ObjectSetInteger(0, titleName, OBJPROP_XDISTANCE, InpPanelXDistance);
      ObjectSetInteger(0, titleName, OBJPROP_YDISTANCE, InpPanelYDistance);
      ObjectSetInteger(0, titleName, OBJPROP_COLOR, InpPanelTextColor);
      ObjectSetInteger(0, titleName, OBJPROP_FONTSIZE, InpFontSize + 1);
      ObjectSetString(0, titleName, OBJPROP_FONT, "Consolas Bold");
      ObjectSetString(0, titleName, OBJPROP_TEXT, "CURRENCY STRENGTH");
      ObjectSetInteger(0, titleName, OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, titleName, OBJPROP_HIDDEN, true);
     }

//--- one text label + one bar per rank position (rank, not currency, so the
//--- same 8 slots simply get relabeled as the ranking changes over time)
   for(int r = 0; r < CURRENCY_COUNT; r++)
     {
      int rowY = InpPanelYDistance + 18 + r * (InpBarHeight + 4);

      string textName = g_Prefix + "Row" + IntegerToString(r) + "_Text";
      if(ObjectFind(0, textName) < 0)
        {
         ObjectCreate(0, textName, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, textName, OBJPROP_CORNER, InpPanelCorner);
         ObjectSetInteger(0, textName, OBJPROP_XDISTANCE, InpPanelXDistance);
         ObjectSetInteger(0, textName, OBJPROP_YDISTANCE, rowY);
         ObjectSetInteger(0, textName, OBJPROP_COLOR, InpPanelTextColor);
         ObjectSetInteger(0, textName, OBJPROP_FONTSIZE, InpFontSize);
         ObjectSetString(0, textName, OBJPROP_FONT, "Consolas");
         ObjectSetInteger(0, textName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, textName, OBJPROP_HIDDEN, true);
        }

      string barName = g_Prefix + "Row" + IntegerToString(r) + "_Bar";
      if(ObjectFind(0, barName) < 0)
        {
         ObjectCreate(0, barName, OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, barName, OBJPROP_CORNER, InpPanelCorner);
         ObjectSetInteger(0, barName, OBJPROP_XDISTANCE, InpPanelXDistance + 60);
         ObjectSetInteger(0, barName, OBJPROP_YDISTANCE, rowY);
         ObjectSetInteger(0, barName, OBJPROP_XSIZE, 2);
         ObjectSetInteger(0, barName, OBJPROP_YSIZE, InpBarHeight);
         ObjectSetInteger(0, barName, OBJPROP_BGCOLOR, InpStrongColor);
         ObjectSetInteger(0, barName, OBJPROP_BORDER_TYPE, BORDER_FLAT);
         ObjectSetInteger(0, barName, OBJPROP_COLOR, clrDimGray);
         ObjectSetInteger(0, barName, OBJPROP_BACK, false);
         ObjectSetInteger(0, barName, OBJPROP_SELECTABLE, false);
         ObjectSetInteger(0, barName, OBJPROP_HIDDEN, true);
        }
     }
  }

//+------------------------------------------------------------------+
//| Ranks the 8 currencies by strength and refreshes each panel row  |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
//--- simple descending selection sort over just 8 elements — negligible cost
   int order[CURRENCY_COUNT];
   for(int i = 0; i < CURRENCY_COUNT; i++)
      order[i] = i;

   for(int i = 0; i < CURRENCY_COUNT - 1; i++)
     {
      int best = i;
      for(int j = i + 1; j < CURRENCY_COUNT; j++)
         if(g_Strength[order[j]] > g_Strength[order[best]])
            best = j;
      if(best != i)
        {
         int tmp = order[i];
         order[i] = order[best];
         order[best] = tmp;
        }
     }

   double maxAbs = 0.0;
   for(int c = 0; c < CURRENCY_COUNT; c++)
      maxAbs = MathMax(maxAbs, MathAbs(g_Strength[c]));

   for(int r = 0; r < CURRENCY_COUNT; r++)
     {
      int    curIdx = order[r];
      double value  = g_Strength[curIdx];

      string textName = g_Prefix + "Row" + IntegerToString(r) + "_Text";
      string barName  = g_Prefix + "Row" + IntegerToString(r) + "_Bar";

      string rowText = StringFormat("%d. %s %+.2f%%", r + 1, g_Currencies[curIdx], value);
      ObjectSetString(0, textName, OBJPROP_TEXT, rowText);
      ObjectSetInteger(0, textName, OBJPROP_COLOR, (value >= 0.0) ? InpStrongColor : InpWeakColor);

      int barWidth = (maxAbs > 0.0) ? (int)MathRound(MathAbs(value) / maxAbs * InpBarMaxWidth) : 0;
      barWidth = MathMax(2, barWidth);

      ObjectSetInteger(0, barName, OBJPROP_XSIZE, barWidth);
      ObjectSetInteger(0, barName, OBJPROP_BGCOLOR, (value >= 0.0) ? InpStrongColor : InpWeakColor);
     }

   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
