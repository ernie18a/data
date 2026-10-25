//+------------------------------------------------------------------------------------------------------+
//|  MACD-v Oscillator for MT4                                                                           |
//|  Separate-window oscillator, histogram, and combo modes                                              |
//|  https://www.tradingview.com/script/mMMHCZUx-AS-MACD-v-Hist-Alex-Spiroglou-S-M-A-R-T-TRADER-SYSTEMS/ |
//+------------------------------------------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.12"
#property strict
#property indicator_separate_window
#property indicator_buffers 9

enum ENUM_MACDV_DISPLAY_MODE
   {
   Oscillator = 0,
   Histogram  = 1,
   Oscillator_Histogram = 2
   };

#define STATE_NONE      0
#define STATE_RANGE     1
#define STATE_RISK      2
#define STATE_RALLY     3
#define STATE_REBOUND   4
#define STATE_RETRACE   5
#define STATE_REVERSE   6

#define LV_0       0.0
#define LV_40      40.0
#define LV_M40    -40.0
#define LV_50      50.0
#define LV_M50    -50.0
#define LV_100    100.0
#define LV_M100  -100.0
#define LV_150    150.0
#define LV_M150  -150.0

double signalBuffer[];
double macdRiskBuffer[];
double macdRallyBuffer[];
double macdReboundBuffer[];
double macdRetraceBuffer[];
double macdReverseBuffer[];
double macdRangeBuffer[];
double histUpBuffer[];
double histDownBuffer[];

extern string GeneralSection     = "===== General =====";
extern ENUM_MACDV_DISPLAY_MODE DisplayMode = Oscillator;
extern bool   ShowLevels         = true;
extern int    MaxBarsBack        = 5000;
extern int    SourcePrice        = PRICE_CLOSE;

extern string OscillatorSection  = "===== MACD-v =====";
extern int    OscillatorTF       = 0;             // 0 = current chart timeframe
extern int    FastLen            = 12;
extern int    SlowLen            = 26;
extern int    SignalLen          = 9;
extern int    ATRPeriod          = 26;

int ThisSubWindow = 1;
int LastValidatedMode = -1;
datetime LastBarTime = 0;
string ObjectPrefix = "MACDv_";
string ValidationSummary = "";

struct MacdvSnapshot
  {
   double val;
   double signal;
   double hist;
   int    state;
   color  stateColor;
   color  histColor;
   bool   valid;
  };

int ResolveTimeframe(int tf)
  {
   if(tf <= 0)
      return(Period());
   return(tf);
  }

int TimeframeToMinutes(int tf)
  {
   int resolved = ResolveTimeframe(tf);
   switch(resolved)
     {
      case PERIOD_M1:  return(1);
      case PERIOD_M5:  return(5);
      case PERIOD_M15: return(15);
      case PERIOD_M30: return(30);
      case PERIOD_H1:  return(60);
      case PERIOD_H4:  return(240);
      case PERIOD_D1:  return(1440);
      case PERIOD_W1:  return(10080);
      case PERIOD_MN1: return(43200);
     }
   return(resolved);
  }

bool IsOscillatorMode()
  {
    return(DisplayMode == Oscillator);
  }

bool IsHistogramMode()
  {
    return(DisplayMode == Histogram);
  }

bool IsOscillatorHistogramMode()
   {
      return(DisplayMode == Oscillator_Histogram);
   }

bool IsLineMode()
   {
    return(IsOscillatorMode() || IsOscillatorHistogramMode());
   }

bool IsHistogramVisible()
   {
    return(IsHistogramMode() || IsOscillatorHistogramMode());
   }

void SetMacdStateValue(int index, int state, double value)
   {
    switch(state)
     {
       case STATE_RISK:    macdRiskBuffer[index] = value; break;
       case STATE_RALLY:   macdRallyBuffer[index] = value; break;
       case STATE_REBOUND: macdReboundBuffer[index] = value; break;
       case STATE_RETRACE: macdRetraceBuffer[index] = value; break;
       case STATE_REVERSE: macdReverseBuffer[index] = value; break;
       case STATE_RANGE:   macdRangeBuffer[index] = value; break;
       default:            macdReboundBuffer[index] = value; break;
     }
   }

string GetStateText(int state)
  {
   switch(state)
     {
      case STATE_RANGE:   return("Range");
      case STATE_RISK:    return("Risk");
      case STATE_RALLY:   return("Rally");
      case STATE_REBOUND: return("Rebound");
      case STATE_RETRACE: return("Retrace");
      case STATE_REVERSE: return("Reverse");
     }
   return("n/a");
  }

int GetState(double val, double signal, int rangeBars)
  {
   bool inRange = (val < 50.0 && val > -50.0);

   if(inRange && rangeBars >= 19)
      return(STATE_RANGE);
   if(val >= 150.0 && val > signal)
      return(STATE_RISK);
   if(val <= -150.0 && val < signal)
      return(STATE_RISK);
   if(val < 150.0 && val >= 50.0 && val > signal)
      return(STATE_RALLY);
   if(val < 50.0 && val > -150.0 && val > signal)
      return(STATE_REBOUND);
   if(val > -50.0 && val < signal)
      return(STATE_RETRACE);
   if(val <= -50.0 && val > -150.0 && val < signal)
      return(STATE_REVERSE);

   return(STATE_NONE);
  }

bool BuildMacdvSeries(string symbol, int timeframe, int priceMode, int requestedCount,
                      double &vals[], double &signals[], double &hists[], int &states[])
  {
   string useSymbol = symbol;
   if(useSymbol == "")
      useSymbol = Symbol();

   int useTf = ResolveTimeframe(timeframe);
   int availableBars = iBars(useSymbol, useTf);
   int neededBars = MathMax(MathMax(FastLen, SlowLen), ATRPeriod) + SignalLen + 5;
   if(availableBars < neededBars)
      return(false);

   int count = requestedCount;
   if(count > availableBars)
      count = availableBars;
   if(count < neededBars)
      count = neededBars;

   ArrayResize(vals, count);
   ArrayResize(signals, count);
   ArrayResize(hists, count);
   ArrayResize(states, count);

   ArraySetAsSeries(vals, true);
   ArraySetAsSeries(signals, true);
   ArraySetAsSeries(hists, true);
   ArraySetAsSeries(states, true);

   for(int shift = count - 1; shift >= 0; shift--)
     {
      double fast = iMA(useSymbol, useTf, FastLen, 0, MODE_EMA, priceMode, shift);
      double slow = iMA(useSymbol, useTf, SlowLen, 0, MODE_EMA, priceMode, shift);
      double vola = iATR(useSymbol, useTf, ATRPeriod, shift);

      if(MathAbs(vola) > 1e-12)
         vals[shift] = NormalizeDouble((fast - slow) / vola * 100.0, 2);
      else
         vals[shift] = 0.0;
     }

   double alpha = 2.0 / (SignalLen + 1.0);
   for(int shift = count - 1; shift >= 0; shift--)
     {
      if(shift == count - 1)
         signals[shift] = vals[shift];
      else
         signals[shift] = NormalizeDouble(alpha * vals[shift] + (1.0 - alpha) * signals[shift + 1], 2);

      hists[shift] = NormalizeDouble(vals[shift] - signals[shift], 2);
     }

   int rangeBars = -1;
   bool previousInRange = false;
   for(int shift = count - 1; shift >= 0; shift--)
     {
      bool inRange = (vals[shift] < 50.0 && vals[shift] > -50.0);
      bool enteredRange = (inRange && !previousInRange);

      if(enteredRange)
         rangeBars = 0;
      else if(inRange && rangeBars >= 0)
         rangeBars++;
      else
         rangeBars = -1;

      states[shift] = GetState(vals[shift], signals[shift], rangeBars);
      previousInRange = inRange;
     }

   return(true);
  }

bool GetLatestSnapshot(string symbol, int timeframe, MacdvSnapshot &snapshot)
  {
   double vals[];
   double signals[];
   double hists[];
   int states[];

   snapshot.valid = false;
   if(!BuildMacdvSeries(symbol, timeframe, SourcePrice, 40, vals, signals, hists, states))
      return(false);

   snapshot.val = vals[0];
   snapshot.signal = signals[0];
   snapshot.hist = hists[0];
   snapshot.state = states[0];
   snapshot.histColor = (ArraySize(hists) > 1 && hists[0] > hists[1]) ? clrLimeGreen : (color)0x00674CED;
   snapshot.valid = true;
   return(true);
  }

void ClearBuffers(int totalBars)
  {
   for(int i = 0; i < totalBars; i++)
     {
      signalBuffer[i] = EMPTY_VALUE;
         macdRiskBuffer[i] = EMPTY_VALUE;
         macdRallyBuffer[i] = EMPTY_VALUE;
         macdReboundBuffer[i] = EMPTY_VALUE;
         macdRetraceBuffer[i] = EMPTY_VALUE;
         macdReverseBuffer[i] = EMPTY_VALUE;
         macdRangeBuffer[i] = EMPTY_VALUE;
      histUpBuffer[i] = EMPTY_VALUE;
      histDownBuffer[i] = EMPTY_VALUE;
     }
  }

void ApplyModeStyles()
  {
   bool oscillator = IsLineMode();
   bool histogram = IsHistogramVisible();

   SetIndexStyle(0, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 2, clrSilver);
   SetIndexStyle(1, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 3, clrBlue);
   SetIndexStyle(2, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 3, (color)0x00576B0D);
   SetIndexStyle(3, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 3, clrLimeGreen);
   SetIndexStyle(4, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 3, clrOrange);
   SetIndexStyle(5, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 3, clrTomato);
   SetIndexStyle(6, oscillator ? DRAW_LINE : DRAW_NONE, STYLE_SOLID, 3, clrGray);
   SetIndexStyle(7, histogram ? DRAW_HISTOGRAM : DRAW_NONE, STYLE_SOLID, 4, clrLimeGreen);
   SetIndexStyle(8, histogram ? DRAW_HISTOGRAM : DRAW_NONE, STYLE_SOLID, 4, (color)0x00674CED);

   if(IsOscillatorMode())
      IndicatorShortName("MACD-v Oscillator");
   else if(IsHistogramMode())
      IndicatorShortName("MACD-v Histogram");
   else
      IndicatorShortName("MACD-v Oscillator + Histogram");
  }

void CreateLevel(string name, double price, color clr, int style = STYLE_SOLID, int width = 1)
  {
   int currentWindow = ChartWindowFind();
   if(currentWindow < 0)
      currentWindow = ThisSubWindow;

   if(ObjectFind(0, name) < 0)
     {
      if(!ObjectCreate(0, name, OBJ_HLINE, currentWindow, Time[0], price))
         return;
     }

   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_RAY, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  }

void DeleteObjectIfExists(string name)
  {
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
  }

void DeleteAllManagedObjects()
  {
   int total = ObjectsTotal(0, 0, -1);
   for(int i = total - 1; i >= 0; i--)
     {
      string name = ObjectName(0, i, 0, -1);
      if(StringFind(name, ObjectPrefix) == 0)
         ObjectDelete(0, name);
     }
  }

void SyncLevels()
  {
   DeleteObjectIfExists(ObjectPrefix + "Lv0");
   DeleteObjectIfExists(ObjectPrefix + "Lv40");
   DeleteObjectIfExists(ObjectPrefix + "LvM40");
   DeleteObjectIfExists(ObjectPrefix + "Lv50");
   DeleteObjectIfExists(ObjectPrefix + "LvM50");
   DeleteObjectIfExists(ObjectPrefix + "Lv100");
   DeleteObjectIfExists(ObjectPrefix + "LvM100");
   DeleteObjectIfExists(ObjectPrefix + "Lv150");
   DeleteObjectIfExists(ObjectPrefix + "LvM150");

   if(!ShowLevels)
      return;

   CreateLevel(ObjectPrefix + "Lv0", LV_0, clrSilver, STYLE_DOT, 1);

    if(IsHistogramMode())
     {
      CreateLevel(ObjectPrefix + "Lv40", LV_40, clrRed, STYLE_SOLID, 1);
      CreateLevel(ObjectPrefix + "LvM40", LV_M40, clrLimeGreen, STYLE_SOLID, 1);
      return;
     }

   CreateLevel(ObjectPrefix + "Lv50", LV_50, clrLightCoral, STYLE_SOLID, 1);
   CreateLevel(ObjectPrefix + "LvM50", LV_M50, clrLightBlue, STYLE_SOLID, 1);
   CreateLevel(ObjectPrefix + "Lv100", LV_100, clrTomato, STYLE_SOLID, 1);
   CreateLevel(ObjectPrefix + "LvM100", LV_M100, clrBlue, STYLE_SOLID, 1);
   CreateLevel(ObjectPrefix + "Lv150", LV_150, clrFireBrick, STYLE_SOLID, 1);
   CreateLevel(ObjectPrefix + "LvM150", LV_M150, clrDarkBlue, STYLE_SOLID, 1);
  }

void PopulatePlotBuffers()
  {
   int totalBars = Bars;
   int barsToMap = totalBars;
   if(MaxBarsBack > 0 && barsToMap > MaxBarsBack)
      barsToMap = MaxBarsBack;

   ClearBuffers(totalBars);

   int sourceTf = ResolveTimeframe(OscillatorTF);
   int maxMappedShift = 0;
   for(int i = barsToMap - 1; i >= 0; i--)
     {
      int tfShift = iBarShift(Symbol(), sourceTf, Time[i], false);
      if(tfShift > maxMappedShift)
         maxMappedShift = tfShift;
     }

   double vals[];
   double signals[];
   double hists[];
   int states[];
   if(!BuildMacdvSeries(Symbol(), sourceTf, SourcePrice, maxMappedShift + 3, vals, signals, hists, states))
      return;

   int previousState = STATE_NONE;
   int previousShift = -1;

   for(int i = barsToMap - 1; i >= 0; i--)
     {
      int tfShift = iBarShift(Symbol(), sourceTf, Time[i], false);
      if(tfShift < 0 || tfShift >= ArraySize(vals))
         continue;

      double val = vals[tfShift];
      double sig = signals[tfShift];
      double hist = hists[tfShift];
      int state = states[tfShift];

      signalBuffer[i] = sig;

      if(IsHistogramVisible())
        {
         if(tfShift + 1 < ArraySize(hists) && hist > hists[tfShift + 1])
            histUpBuffer[i] = hist;
         else
            histDownBuffer[i] = hist;
        }

      if(!IsLineMode())
         continue;

      SetMacdStateValue(i, state, val);

      if(previousShift >= 0 && previousShift != tfShift && previousState != STATE_NONE && previousState != state)
         SetMacdStateValue(i, previousState, val);

      previousState = state;
      previousShift = tfShift;
     }
  }

void ValidateConfiguration()
  {
   ValidationSummary = "";
   int chartMinutes = TimeframeToMinutes(Period());
   int targetTf = ResolveTimeframe(OscillatorTF);
   bool hasWarning = false;

      if(chartMinutes > TimeframeToMinutes(targetTf))
     {
      Print("MACD-v: chart timeframe should be less than or equal to the selected oscillator timeframe.");
      ValidationSummary = "chart TF > oscillator TF";
      hasWarning = true;
     }

    if(ArraySize(signalBuffer) > 0)
     {
      MacdvSnapshot snapshot;
      if(GetLatestSnapshot(Symbol(), ResolveTimeframe(OscillatorTF), snapshot))
        {
             if(IsLineMode())
           {
            double plottedValue = EMPTY_VALUE;
                  if(macdRiskBuffer[0] != EMPTY_VALUE) plottedValue = macdRiskBuffer[0];
                  else if(macdRallyBuffer[0] != EMPTY_VALUE) plottedValue = macdRallyBuffer[0];
                  else if(macdReboundBuffer[0] != EMPTY_VALUE) plottedValue = macdReboundBuffer[0];
                  else if(macdRetraceBuffer[0] != EMPTY_VALUE) plottedValue = macdRetraceBuffer[0];
                  else if(macdReverseBuffer[0] != EMPTY_VALUE) plottedValue = macdReverseBuffer[0];
                  else if(macdRangeBuffer[0] != EMPTY_VALUE) plottedValue = macdRangeBuffer[0];

            if(plottedValue != EMPTY_VALUE && MathAbs(plottedValue - snapshot.val) > 0.05)
              {
               if(ValidationSummary != "")
                  ValidationSummary = ValidationSummary + "; ";
               ValidationSummary = ValidationSummary + "plot/value parity drift";
               hasWarning = true;
              }
           }
         if(IsHistogramVisible())
           {
            double plottedHist = (histUpBuffer[0] != EMPTY_VALUE) ? histUpBuffer[0] : histDownBuffer[0];
            if(plottedHist != EMPTY_VALUE && MathAbs(plottedHist - snapshot.hist) > 0.05)
              {
               if(ValidationSummary != "")
                  ValidationSummary = ValidationSummary + "; ";
               ValidationSummary = ValidationSummary + "hist/value parity drift";
               hasWarning = true;
              }
           }
        }
     }

   if(!hasWarning)
      ValidationSummary = "parity checks OK";
  }

int init()
  {
   IndicatorBuffers(9);

   SetIndexBuffer(0, signalBuffer);
   SetIndexBuffer(1, macdRiskBuffer);
   SetIndexBuffer(2, macdRallyBuffer);
   SetIndexBuffer(3, macdReboundBuffer);
   SetIndexBuffer(4, macdRetraceBuffer);
   SetIndexBuffer(5, macdReverseBuffer);
   SetIndexBuffer(6, macdRangeBuffer);
   SetIndexBuffer(7, histUpBuffer);
   SetIndexBuffer(8, histDownBuffer);

   SetIndexLabel(0, "Signal");
   SetIndexLabel(1, "MACD-v Risk");
   SetIndexLabel(2, "MACD-v Rally");
   SetIndexLabel(3, "MACD-v Rebound");
   SetIndexLabel(4, "MACD-v Retrace");
   SetIndexLabel(5, "MACD-v Reverse");
   SetIndexLabel(6, "MACD-v Range");
   SetIndexLabel(7, "Histogram Up");
   SetIndexLabel(8, "Histogram Down");

   for(int i = 0; i < 9; i++)
      SetIndexEmptyValue(i, EMPTY_VALUE);

   ObjectPrefix = "MACDv_" + IntegerToString((int)ChartID()) + "_";
   ThisSubWindow = WindowOnDropped();
   if(ThisSubWindow < 0)
      ThisSubWindow = 1;

   ApplyModeStyles();
   ValidateConfiguration();
   SyncLevels();
   LastValidatedMode = DisplayMode;
   return(0);
  }

int deinit()
  {
   DeleteAllManagedObjects();
   Comment("");
   return(0);
  }

int start()
  {
    if(LastValidatedMode != DisplayMode)
     {
      ApplyModeStyles();
      DeleteAllManagedObjects();
      LastValidatedMode = DisplayMode;
     }

   PopulatePlotBuffers();
   ValidateConfiguration();
   SyncLevels();

   if(ValidationSummary != "" && ValidationSummary != "parity checks OK")
      Comment("MACD-v warning: " + ValidationSummary);
   else
      Comment("");

   if(Time[0] != LastBarTime)
      LastBarTime = Time[0];

   return(0);
  }
