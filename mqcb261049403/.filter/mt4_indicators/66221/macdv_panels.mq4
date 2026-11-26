//+------------------------------------------------------------------------------------------------------+
//|  MACD-v Panels for MT4                                                                               |
//|  Chart-window heat map and dashboard modes                                                           |
//|  https://www.tradingview.com/script/mMMHCZUx-AS-MACD-v-Hist-Alex-Spiroglou-S-M-A-R-T-TRADER-SYSTEMS/ |
//+------------------------------------------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.13"
#property strict
#property indicator_chart_window
#property indicator_buffers 1

enum ENUM_MACDV_DISPLAY_MODE
   {
   Heat_Map   = 0,
   Dashboard  = 1
   };

#define STATE_NONE      0
#define STATE_RANGE     1
#define STATE_RISK      2
#define STATE_RALLY     3
#define STATE_REBOUND   4
#define STATE_RETRACE   5
#define STATE_REVERSE   6

double dummyBuffer[];

extern string GeneralSection     = "===== General =====";
extern ENUM_MACDV_DISPLAY_MODE DisplayMode = Dashboard;
extern int    SourcePrice        = PRICE_CLOSE;

extern string OscillatorSection  = "===== MACD-v =====";
extern int    OscillatorTF       = 0;             // 0 = current chart timeframe
extern int    FastLen            = 12;
extern int    SlowLen            = 26;
extern int    SignalLen          = 9;
extern int    ATRPeriod          = 26;

extern string TimeframeSection   = "===== Heat Map / Dashboard Timeframes =====";
extern bool   UseTF1             = true;
extern int    TF1                = PERIOD_MN1;
extern bool   UseTF2             = true;
extern int    TF2                = PERIOD_W1;
extern bool   UseTF3             = true;
extern int    TF3                = PERIOD_D1;
extern bool   UseTF4             = false;
extern int    TF4                = PERIOD_H4;
extern bool   UseTF5             = false;
extern int    TF5                = PERIOD_H1;

extern string SymbolSection      = "===== Dashboard Symbols =====";
extern bool   UseSymbol1         = true;
extern string Symbol1            = "ES1!";
extern bool   UseSymbol2         = true;
extern string Symbol2            = "NQ1!";
extern bool   UseSymbol3         = true;
extern string Symbol3            = "DXY";
extern bool   UseSymbol4         = true;
extern string Symbol4            = "GOLD";
extern bool   UseSymbol5         = true;
extern string Symbol5            = "BTCUSD";
extern bool   UseSymbol6         = true;
extern string Symbol6            = "US02Y";
extern bool   UseSymbol7         = true;
extern string Symbol7            = "XLI";

extern string AliasSection       = "===== Symbol Aliases =====";
extern string SymbolAliasMap     = "ES1!=US500,SPX500,SP500;NQ1!=NAS100,USTEC,US100;DXY=USDX,DXY.cash;GOLD=XAUUSD,XAUUSDm,GOLDm;BTCUSD=BTCUSDm,BTCUSD.a,BTCUSD.;US02Y=UST02Y,US02Yr,US2Y;XLI=XLI.US";
extern string CommonSuffixes     = ".pro,.a,.fx,.raw,.m,.ecn,.sb,.i,.t,_sb,_i,+";
extern string CommonPrefixes     = "m.,fx.,forex.";

extern string PanelSection       = "===== Panel Placement =====";
extern int    PanelRefreshSeconds = 2;
extern int    PanelCorner        = 0;
extern int    PanelX             = 10;
extern int    PanelY             = 18;
extern int    PanelFontSize      = 10;
extern string PanelFontName      = "Arial";
extern color  PanelBackground    = C'30,34,45';
extern color  PanelText          = clrWhite;
extern color  PanelHeader        = clrGold;

int LastValidatedMode = -1;
datetime LastPanelRefresh = 0;
string ObjectPrefix = "MACDv_";
string ValidationSummary = "";
string LastPanelLayoutKey = "";
string BrokerSuffixList[];
string BrokerPrefixList[];
bool PanelNeedsRefresh = true;
int ActivePanelPassId = 0;

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

struct CachedSymbolResolution
   {
    string requested;
    string resolved;
    bool   valid;
   };

struct CachedPanelSnapshot
   {
    string        symbol;
    int           timeframe;
    int           passId;
    bool          available;
    string        reason;
    MacdvSnapshot snapshot;
   };

CachedSymbolResolution SymbolResolutionCache[];
CachedPanelSnapshot PanelSnapshotCache[];

bool ExtractSingleIndex(string objectName, string marker, int &index)
  {
   index = -1;

   string prefix = ObjectPrefix + marker;
   if(StringFind(objectName, prefix) != 0)
      return(false);

   string indexText = StringSubstr(objectName, StringLen(prefix));
   if(indexText == "")
      return(false);

   for(int i = 0; i < StringLen(indexText); i++)
     {
      ushort ch = StringGetCharacter(indexText, i);
      if(ch < '0' || ch > '9')
         return(false);
     }

   index = (int)StringToInteger(indexText);
   return(true);
  }

bool ExtractCellIndices(string objectName, string marker, int &rowIndex, int &colIndex)
  {
   rowIndex = -1;
   colIndex = -1;

   string prefix = ObjectPrefix + marker;
   if(StringFind(objectName, prefix) != 0)
      return(false);

   string pairText = StringSubstr(objectName, StringLen(prefix));
   string parts[];
   if(StringSplit(pairText, '_', parts) != 2)
      return(false);

   for(int i = 0; i < 2; i++)
     {
      if(parts[i] == "")
         return(false);

      for(int j = 0; j < StringLen(parts[i]); j++)
        {
         ushort ch = StringGetCharacter(parts[i], j);
         if(ch < '0' || ch > '9')
            return(false);
        }
     }

   rowIndex = (int)StringToInteger(parts[0]);
   colIndex = (int)StringToInteger(parts[1]);
   return(true);
  }

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

string TimeframeToLabel(int tf)
  {
   int resolved = ResolveTimeframe(tf);
   switch(resolved)
     {
      case PERIOD_M1:  return("1m");
      case PERIOD_M5:  return("5m");
      case PERIOD_M15: return("15m");
      case PERIOD_M30: return("30m");
      case PERIOD_H1:  return("1h");
      case PERIOD_H4:  return("4h");
      case PERIOD_D1:  return("1D");
      case PERIOD_W1:  return("1W");
      case PERIOD_MN1: return("1M");
     }
   return(IntegerToString(resolved));
  }

color GetStateColor(int state)
  {
   switch(state)
     {
      case STATE_RANGE:   return(clrGray);
      case STATE_RISK:    return(clrBlue);
      case STATE_RALLY:   return((color)0x00576B0D);
      case STATE_REBOUND: return(clrLimeGreen);
      case STATE_RETRACE: return(clrOrange);
      case STATE_REVERSE: return(clrTomato);
     }
   return(clrSilver);
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

string TrimSpaces(string value)
   {
    int start = 0;
    int end = StringLen(value) - 1;

    while(start <= end)
       {
         ushort chStart = StringGetCharacter(value, start);
         if(chStart != ' ' && chStart != '\t' && chStart != '\r' && chStart != '\n')
             break;
         start++;
       }

    while(end >= start)
       {
         ushort chEnd = StringGetCharacter(value, end);
         if(chEnd != ' ' && chEnd != '\t' && chEnd != '\r' && chEnd != '\n')
             break;
         end--;
       }

    if(end < start)
         return("");
    return(StringSubstr(value, start, end - start + 1));
   }

string NormalizeSymbolKey(string value)
   {
    string cleaned = TrimSpaces(value);
    string normalized = "";
    int length = StringLen(cleaned);

    for(int i = 0; i < length; i++)
       {
         ushort ch = StringGetCharacter(cleaned, i);
         if(ch >= 'a' && ch <= 'z')
             ch = ch - 32;
         if((ch >= 'A' && ch <= 'Z') || (ch >= '0' && ch <= '9'))
          normalized = normalized + CharToString((uchar)ch);
       }

    return(normalized);
   }

bool StartsWithText(string value, string prefix)
   {
    int prefixLength = StringLen(prefix);
    if(prefixLength <= 0 || StringLen(value) < prefixLength)
         return(false);
    return(StringSubstr(value, 0, prefixLength) == prefix);
   }

bool EndsWithText(string value, string suffix)
   {
    int valueLength = StringLen(value);
    int suffixLength = StringLen(suffix);
    if(suffixLength <= 0 || valueLength < suffixLength)
         return(false);
    return(StringSubstr(value, valueLength - suffixLength) == suffix);
   }

void ParseDelimitedList(string source, string &items[])
   {
    ArrayResize(items, 0);
    string trimmedSource = TrimSpaces(source);
    if(trimmedSource == "")
         return;

    string tokens[];
    int tokenCount = StringSplit(trimmedSource, ',', tokens);
    for(int i = 0; i < tokenCount; i++)
         AddUniqueString(tokens[i], items);
   }

void InitializeSymbolAffixes()
   {
    ParseDelimitedList(CommonSuffixes, BrokerSuffixList);
    ParseDelimitedList(CommonPrefixes, BrokerPrefixList);
   }

string StripKnownAffixes(string symbol)
   {
    string core = TrimSpaces(symbol);

    for(int i = 0; i < ArraySize(BrokerPrefixList); i++)
       {
         if(StartsWithText(core, BrokerPrefixList[i]))
            {
             core = StringSubstr(core, StringLen(BrokerPrefixList[i]));
             break;
            }
       }

    for(int i = 0; i < ArraySize(BrokerSuffixList); i++)
       {
         if(EndsWithText(core, BrokerSuffixList[i]))
            {
             core = StringSubstr(core, 0, StringLen(core) - StringLen(BrokerSuffixList[i]));
             break;
            }
       }

    return(core);
   }

bool ContainsIgnoreCase(string haystack, string needle)
   {
    return(StringFind(NormalizeSymbolKey(haystack), NormalizeSymbolKey(needle)) >= 0);
   }

void AddUniqueString(string value, string &items[])
   {
    string trimmed = TrimSpaces(value);
    if(trimmed == "")
         return;

    int size = ArraySize(items);
    for(int i = 0; i < size; i++)
       {
         if(items[i] == trimmed)
             return;
       }

    ArrayResize(items, size + 1);
    items[size] = trimmed;
   }

void AddAliasCandidates(string requested, string &candidates[])
   {
    string mapText = TrimSpaces(SymbolAliasMap);
    if(mapText == "")
         return;

    string requestedKey = NormalizeSymbolKey(requested);
    string mappings[];
    int mappingCount = StringSplit(mapText, ';', mappings);
    for(int i = 0; i < mappingCount; i++)
       {
         string parts[];
         if(StringSplit(mappings[i], '=', parts) < 2)
             continue;

         string mappingKey = NormalizeSymbolKey(parts[0]);
         if(mappingKey != requestedKey)
             continue;

         string aliases[];
         int aliasCount = StringSplit(parts[1], ',', aliases);
         for(int j = 0; j < aliasCount; j++)
             AddUniqueString(aliases[j], candidates);
       }
   }

      void AddAffixCandidates(string requested, string &candidates[])
        {
         string trimmed = TrimSpaces(requested);
         if(trimmed == "")
            return;

         for(int i = 0; i < ArraySize(BrokerSuffixList); i++)
            AddUniqueString(trimmed + BrokerSuffixList[i], candidates);

         for(int i = 0; i < ArraySize(BrokerPrefixList); i++)
            AddUniqueString(BrokerPrefixList[i] + trimmed, candidates);

         for(int i = 0; i < ArraySize(BrokerPrefixList); i++)
           {
            for(int j = 0; j < ArraySize(BrokerSuffixList); j++)
               AddUniqueString(BrokerPrefixList[i] + trimmed + BrokerSuffixList[j], candidates);
           }
        }

string ResolveBrokerSymbol(string requested)
   {
    string trimmed = TrimSpaces(requested);
    if(trimmed == "")
         return("");

    string requestedKey = NormalizeSymbolKey(trimmed);
   string requestedCoreKey = NormalizeSymbolKey(StripKnownAffixes(trimmed));
    string candidates[];
    AddUniqueString(trimmed, candidates);
    AddAliasCandidates(trimmed, candidates);
   AddAffixCandidates(trimmed, candidates);

    int candidateCount = ArraySize(candidates);
    for(int i = 0; i < candidateCount; i++)
       {
         if(SymbolSelect(candidates[i], true))
             return(candidates[i]);
       }

    int totalSymbols = SymbolsTotal(false);
    bool selectedOnly = false;
    if(totalSymbols <= 0)
       {
         totalSymbols = SymbolsTotal(true);
         selectedOnly = true;
       }

    for(int i = 0; i < totalSymbols; i++)
       {
         string brokerSymbol = SymbolName(i, selectedOnly);
         string brokerKey = NormalizeSymbolKey(brokerSymbol);
         string brokerCoreKey = NormalizeSymbolKey(StripKnownAffixes(brokerSymbol));
         if(brokerKey == requestedKey || brokerCoreKey == requestedKey || brokerCoreKey == requestedCoreKey)
            {
             SymbolSelect(brokerSymbol, true);
             return(brokerSymbol);
            }
       }

    for(int i = 0; i < candidateCount; i++)
       {
         string candidateKey = NormalizeSymbolKey(candidates[i]);
         for(int j = 0; j < totalSymbols; j++)
            {
             string brokerSymbol = SymbolName(j, selectedOnly);
             string brokerKey = NormalizeSymbolKey(brokerSymbol);
             string brokerCoreKey = NormalizeSymbolKey(StripKnownAffixes(brokerSymbol));
             if(StringFind(brokerKey, candidateKey) >= 0 || StringFind(candidateKey, brokerKey) >= 0 ||
                  StringFind(brokerCoreKey, candidateKey) >= 0 || StringFind(candidateKey, brokerCoreKey) >= 0)
                {
                  SymbolSelect(brokerSymbol, true);
                  return(brokerSymbol);
                }
            }
       }

    return("");
   }

void ClearPanelCaches(bool clearSymbolCache = true)
   {
    ArrayResize(PanelSnapshotCache, 0);
    if(clearSymbolCache)
         ArrayResize(SymbolResolutionCache, 0);
   }

string BuildPanelLayoutKey()
   {
    string key = IntegerToString(DisplayMode) + "|" + Symbol() + "|" + IntegerToString(PanelCorner) + "|" +
                        IntegerToString(PanelX) + "|" + IntegerToString(PanelY) + "|" +
                        IntegerToString(PanelFontSize) + "|" + PanelFontName + "|" +
                        IntegerToString((int)PanelBackground) + "|" + IntegerToString((int)PanelText) + "|" +
                        IntegerToString((int)PanelHeader);

      if(DisplayMode == Heat_Map || DisplayMode == Dashboard)
       {
         int timeframes[];
         int totalTfs = GetEnabledTimeframes(timeframes);
         key = key + "|TF";
         for(int i = 0; i < totalTfs; i++)
             key = key + ":" + IntegerToString(timeframes[i]);
       }

      if(DisplayMode == Dashboard)
       {
         string symbols[];
         int totalSymbols = GetEnabledSymbols(symbols);
         key = key + "|SYM";
         for(int j = 0; j < totalSymbols; j++)
             key = key + ":" + symbols[j];
       }

    return(key);
   }

bool TryGetResolvedSymbolFromCache(string requested, string &resolvedSymbol, bool &isCached)
   {
   isCached = false;
    string trimmed = TrimSpaces(requested);
    for(int i = 0; i < ArraySize(SymbolResolutionCache); i++)
       {
         if(SymbolResolutionCache[i].requested != trimmed)
             continue;

      isCached = true;
         resolvedSymbol = SymbolResolutionCache[i].resolved;
         return(SymbolResolutionCache[i].valid);
       }

    return(false);
   }

void SaveResolvedSymbolToCache(string requested, string resolvedSymbol, bool valid)
   {
    string trimmed = TrimSpaces(requested);
    for(int i = 0; i < ArraySize(SymbolResolutionCache); i++)
       {
         if(SymbolResolutionCache[i].requested != trimmed)
             continue;

         SymbolResolutionCache[i].resolved = resolvedSymbol;
         SymbolResolutionCache[i].valid = valid;
         return;
       }

    int newIndex = ArraySize(SymbolResolutionCache);
    ArrayResize(SymbolResolutionCache, newIndex + 1);
    SymbolResolutionCache[newIndex].requested = trimmed;
    SymbolResolutionCache[newIndex].resolved = resolvedSymbol;
    SymbolResolutionCache[newIndex].valid = valid;
   }

bool TryGetPanelSnapshotFromCache(string symbol, int timeframe, MacdvSnapshot &snapshot, string &reason)
   {
    for(int i = 0; i < ArraySize(PanelSnapshotCache); i++)
       {
         if(PanelSnapshotCache[i].passId != ActivePanelPassId)
             continue;
         if(PanelSnapshotCache[i].symbol != symbol || PanelSnapshotCache[i].timeframe != timeframe)
             continue;

         if(PanelSnapshotCache[i].available)
            {
             snapshot = PanelSnapshotCache[i].snapshot;
             reason = "";
             return(true);
            }

         reason = PanelSnapshotCache[i].reason;
         return(false);
       }

    return(false);
   }

void SavePanelSnapshotToCache(string symbol, int timeframe, bool available, string reason, MacdvSnapshot &snapshot)
   {
    int newIndex = ArraySize(PanelSnapshotCache);
    ArrayResize(PanelSnapshotCache, newIndex + 1);
    PanelSnapshotCache[newIndex].symbol = symbol;
    PanelSnapshotCache[newIndex].timeframe = timeframe;
    PanelSnapshotCache[newIndex].passId = ActivePanelPassId;
    PanelSnapshotCache[newIndex].available = available;
    PanelSnapshotCache[newIndex].reason = reason;
    if(available)
         PanelSnapshotCache[newIndex].snapshot = snapshot;
   }

int GetRValueLocal(color clr)
   {
    return(((int)clr) & 0xFF);
   }

int GetGValueLocal(color clr)
   {
    return((((int)clr) >> 8) & 0xFF);
   }

int GetBValueLocal(color clr)
   {
    return((((int)clr) >> 16) & 0xFF);
   }

color MakeRgbColor(int red, int green, int blue)
   {
    red = MathMax(0, MathMin(255, red));
    green = MathMax(0, MathMin(255, green));
    blue = MathMax(0, MathMin(255, blue));
    return((color)(red | (green << 8) | (blue << 16)));
   }

color BlendColor(color baseColor, color targetColor, double ratio)
   {
    if(ratio < 0.0)
         ratio = 0.0;
    if(ratio > 1.0)
         ratio = 1.0;

    int baseRed = GetRValueLocal(baseColor);
    int baseGreen = GetGValueLocal(baseColor);
    int baseBlue = GetBValueLocal(baseColor);
    int targetRed = GetRValueLocal(targetColor);
    int targetGreen = GetGValueLocal(targetColor);
    int targetBlue = GetBValueLocal(targetColor);

    int mixedRed = (int)MathRound(baseRed + (targetRed - baseRed) * ratio);
    int mixedGreen = (int)MathRound(baseGreen + (targetGreen - baseGreen) * ratio);
    int mixedBlue = (int)MathRound(baseBlue + (targetBlue - baseBlue) * ratio);
    return(MakeRgbColor(mixedRed, mixedGreen, mixedBlue));
   }

color GetPanelCellColor(color stateColor)
   {
    return(BlendColor(PanelBackground, stateColor, 0.70));
   }

color GetHeaderCellColor()
   {
    return(BlendColor(PanelBackground, PanelHeader, 0.18));
   }

color GetHeaderBorderColor()
   {
    return(BlendColor(PanelBackground, PanelHeader, 0.45));
   }

color GetRowBaseColor(int rowIndex)
   {
    if((rowIndex % 2) == 0)
         return(BlendColor(PanelBackground, clrBlack, 0.08));
    return(BlendColor(PanelBackground, clrWhite, 0.04));
   }

color GetPanelBorderColor(color stateColor)
   {
    return(BlendColor(PanelBackground, stateColor, 0.90));
   }

double GetColorLuma(color clr)
   {
    return(GetRValueLocal(clr) * 0.299 + GetGValueLocal(clr) * 0.587 + GetBValueLocal(clr) * 0.114);
   }

color GetReadableTextColor(color bgColor)
   {
    if(GetColorLuma(bgColor) >= 150.0)
         return(BlendColor(clrBlack, bgColor, 0.18));
    return(BlendColor(clrWhite, bgColor, 0.10));
   }

color GetMutedReadableTextColor(color bgColor)
   {
    color baseText = GetReadableTextColor(bgColor);
    if(GetColorLuma(bgColor) >= 150.0)
         return(BlendColor(baseText, bgColor, 0.42));
    return(BlendColor(baseText, bgColor, 0.30));
   }

color GetDashboardBiasTextColor(color bgColor, color accentColor)
   {
    color readableBase = GetReadableTextColor(bgColor);
    return(BlendColor(readableBase, accentColor, 0.22));
   }

bool IsPanelConnected()
   {
    if(!IsConnected())
         return(false);
    if(!TerminalInfoInteger(TERMINAL_CONNECTED))
         return(false);
    return(true);
   }

int EstimateDashboardLabelCharLimit(int width, int fontSize, bool bold = false)
   {
    int usableWidth = MathMax(width - 16, 24);
    double charWidth = fontSize * (bold ? 0.68 : 0.60);
    if(charWidth < 1.0)
       charWidth = 1.0;
    return(MathMax(4, (int)MathFloor(usableWidth / charWidth)));
   }

string TruncateDashboardText(string text, int maxChars)
   {
    if(maxChars <= 0)
       return("");
    if(StringLen(text) <= maxChars)
       return(text);
    if(maxChars <= 3)
       return(StringSubstr(text, 0, maxChars));
    return(StringSubstr(text, 0, maxChars - 3) + "...");
   }

string FitDashboardLabelText(string text, int width, int fontSize, bool bold = false)
   {
    return(TruncateDashboardText(text, EstimateDashboardLabelCharLimit(width, fontSize, bold)));
   }

string GetDashboardStateText(int state)
   {
    switch(state)
    {
     case STATE_RANGE:   return("Range");
     case STATE_RISK:    return("Risk");
     case STATE_RALLY:   return("Rally");
     case STATE_REBOUND: return("Rebnd");
     case STATE_RETRACE: return("Retr");
     case STATE_REVERSE: return("Rev");
    }
    return("n/a");
   }

string GetDashboardReasonText(string reason)
   {
    if(reason == "symbol unavailable")
       return("No symbol");
    if(reason == "history unavailable")
       return("No history");
    if(reason == "insufficient history")
       return("Short history");
    if(reason == "")
       return("Waiting");
    return(reason);
   }

string GetOscillatorTimeframeLabel()
   {
    if(OscillatorTF <= 0)
         return(TimeframeToLabel(Period()));
    return(TimeframeToLabel(OscillatorTF));
   }

string GetResolvedSymbolCaption(string requested, string resolvedSymbol, bool isAvailable)
   {
    if(!isAvailable)
         return("Symbol unavailable");
    if(resolvedSymbol == "")
         return("Waiting for data");
    if(resolvedSymbol == requested)
         return("Live market symbol");
    return("Broker symbol: " + resolvedSymbol);
   }

string GetDashboardSymbolCaption(string requested, string resolvedSymbol, bool isAvailable)
   {
    if(!isAvailable)
         return("Unavailable");
    if(resolvedSymbol == "")
         return("Waiting");
    if(resolvedSymbol == requested)
         return("Live");
    return("Broker: " + resolvedSymbol);
   }

string GetHistogramStatusText(MacdvSnapshot &snapshot)
   {
    string signText = (snapshot.hist >= 0.0) ? "Hist +" : "Hist -";
    string slopeText = (snapshot.histColor == clrLimeGreen) ? "rising" : "falling";
    return(signText + " | " + slopeText);
   }

string GetDashboardHistogramStatusText(MacdvSnapshot &snapshot)
   {
    string signText = (snapshot.hist >= 0.0) ? "H+" : "H-";
    string slopeText = (snapshot.histColor == clrLimeGreen) ? "up" : "dn";
    return(signText + " " + slopeText);
   }

string BuildDashboardMetricSecondaryText(MacdvSnapshot &snapshot)
   {
    return(GetDashboardStateText(snapshot.state) + " | " + GetDashboardHistogramStatusText(snapshot));
   }

void CreateDashboardMetricCell(string key, string primary, string secondary, int x, int y, int width, int height,
                                              color bgColor, color borderColor, color primaryColor, color secondaryColor, bool clickable = false)
   {
      string rectName = key + "_Rect";
      int primaryFontSize = PanelFontSize + 1;
      int secondaryFontSize = MathMax(PanelFontSize - 2, 7);
      int primaryY = y + 3;
      int secondaryY = primaryY + primaryFontSize + 6;
      CreatePanelRect(rectName, x, y, width, height, bgColor, borderColor);
      if(clickable)
         {
          ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, true);
          ObjectSetInteger(0, rectName, OBJPROP_HIDDEN, false);
         }
      CreatePanelLabel(key + "_Primary", FitDashboardLabelText(primary, width, primaryFontSize, true), x + 8, primaryY, primaryColor, primaryFontSize, "Arial Bold", clickable);
      CreatePanelLabel(key + "_Secondary", FitDashboardLabelText(secondary, width, secondaryFontSize), x + 8, secondaryY, secondaryColor, secondaryFontSize, "", clickable);
   }

void CreateDashboardSymbolCell(string key, string primary, string secondary, int x, int y, int width, int height,
                                              color bgColor, color borderColor, color primaryColor, color secondaryColor, bool clickable = false)
   {
      string rectName = key + "_Rect";
      int primaryFontSize = PanelFontSize + 1;
      int secondaryFontSize = MathMax(PanelFontSize - 2, 7);
      int primaryY = y + 3;
      int secondaryY = primaryY + primaryFontSize + 6;
      CreatePanelRect(rectName, x, y, width, height, bgColor, borderColor);
      if(clickable)
         {
          ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, true);
          ObjectSetInteger(0, rectName, OBJPROP_HIDDEN, false);
         }
      CreatePanelLabel(key + "_Primary", FitDashboardLabelText(primary, width, primaryFontSize, true), x + 8, primaryY, primaryColor, primaryFontSize, "Arial Bold", clickable);
      CreatePanelLabel(key + "_Secondary", FitDashboardLabelText(secondary, width, secondaryFontSize), x + 8, secondaryY, secondaryColor, secondaryFontSize, "", clickable);
   }

bool EnsureSymbolReady(string symbol, string &resolvedSymbol)
   {
    bool isCached = false;
    if(TryGetResolvedSymbolFromCache(symbol, resolvedSymbol, isCached))
       return(resolvedSymbol != "");
    if(isCached)
       return(false);

    resolvedSymbol = ResolveBrokerSymbol(symbol);
    SaveResolvedSymbolToCache(symbol, resolvedSymbol, resolvedSymbol != "");
    return(resolvedSymbol != "");
   }

bool IsSnapshotUsable(string symbol, int timeframe, MacdvSnapshot &snapshot, string &reason)
   {
    reason = "";
    if(TryGetPanelSnapshotFromCache(symbol, timeframe, snapshot, reason))
       return(true);
    if(reason != "")
       return(false);

    string resolvedSymbol;
    if(!EnsureSymbolReady(symbol, resolvedSymbol))
       {
         reason = "symbol unavailable";
         SavePanelSnapshotToCache(symbol, timeframe, false, reason, snapshot);
         return(false);
       }

    if(iBars(resolvedSymbol, ResolveTimeframe(timeframe)) <= 0)
       {
         reason = "history unavailable";
         SavePanelSnapshotToCache(symbol, timeframe, false, reason, snapshot);
         return(false);
       }

    if(!GetLatestSnapshot(resolvedSymbol, timeframe, snapshot))
       {
         reason = "insufficient history";
         SavePanelSnapshotToCache(symbol, timeframe, false, reason, snapshot);
         return(false);
       }

    SavePanelSnapshotToCache(symbol, timeframe, true, "", snapshot);
    return(true);
   }

string FormatSnapshotCell(MacdvSnapshot &snapshot)
   {
    return(DoubleToString(snapshot.val, 0) + "  " + GetStateText(snapshot.state));
   }

string FormatHeatMapSnapshot(MacdvSnapshot &snapshot)
   {
    return("Value " + DoubleToString(snapshot.val, 2) +
           "   Signal " + DoubleToString(snapshot.signal, 2) +
           "   Histogram " + DoubleToString(snapshot.hist, 2) +
           "   State " + GetStateText(snapshot.state));
   }

void CreatePanelTextCell(string key, string text, int x, int y, int width, int height,
                                     color bgColor, color borderColor, color textColor, int fontSize,
                                     bool bold = false, bool clickable = false)
   {
    string rectName = key + "_Rect";
    string labelName = key + "_Label";
    CreatePanelRect(rectName, x, y, width, height, bgColor, borderColor);
    if(clickable)
      {
       ObjectSetInteger(0, rectName, OBJPROP_SELECTABLE, true);
       ObjectSetInteger(0, rectName, OBJPROP_HIDDEN, false);
      }
   CreatePanelLabel(labelName, text, x + 8, y + 4, textColor, fontSize, bold ? "Arial Bold" : PanelFontName, clickable);
   }

bool SwitchPanelChart(string requestedSymbol, int timeframe)
  {
   string resolvedSymbol = requestedSymbol;
   if(requestedSymbol != "")
     {
      if(!EnsureSymbolReady(requestedSymbol, resolvedSymbol))
        {
         Print("MACD-v Panels: symbol unavailable for navigation: ", requestedSymbol);
         return(false);
        }
     }
   else
      resolvedSymbol = Symbol();

   int targetTimeframe = ResolveTimeframe(timeframe);
   if(targetTimeframe <= 0)
      targetTimeframe = Period();

   if(Symbol() == resolvedSymbol && Period() == targetTimeframe)
      return(true);

   if(!ChartSetSymbolPeriod(0, resolvedSymbol, targetTimeframe))
     {
      Print("MACD-v Panels: failed to switch chart to ", resolvedSymbol, " (TF=", IntegerToString(targetTimeframe), ")");
      return(false);
     }

   return(true);
  }

void HandleHeatMapClick(string objectName)
  {
   int rowIndex;
   if(!ExtractSingleIndex(objectName, "HeatTf_", rowIndex) && !ExtractSingleIndex(objectName, "HeatVal_", rowIndex))
      return;

   int timeframes[];
   if(rowIndex < 0 || rowIndex >= GetEnabledTimeframes(timeframes))
      return;

   SwitchPanelChart(Symbol(), timeframes[rowIndex]);
  }

void HandleDashboardClick(string objectName)
  {
   int symbolIndex;
   if(ExtractSingleIndex(objectName, "DashS_", symbolIndex))
     {
      string symbols[];
      if(symbolIndex < 0 || symbolIndex >= GetEnabledSymbols(symbols))
         return;

      SwitchPanelChart(symbols[symbolIndex], Period());
      return;
     }

   int timeframeIndex;
   if(ExtractSingleIndex(objectName, "DashH_", timeframeIndex))
     {
      int timeframes[];
      if(timeframeIndex < 0 || timeframeIndex >= GetEnabledTimeframes(timeframes))
         return;

      SwitchPanelChart(Symbol(), timeframes[timeframeIndex]);
      return;
     }

   int rowIndex;
   int colIndex;
   if(!ExtractCellIndices(objectName, "DashCell_", rowIndex, colIndex))
      return;

   string symbols[];
   int timeframes[];
   int totalSymbols = GetEnabledSymbols(symbols);
   int totalTfs = GetEnabledTimeframes(timeframes);
   if(rowIndex < 0 || rowIndex >= totalSymbols || colIndex < 0 || colIndex >= totalTfs)
      return;

   SwitchPanelChart(symbols[rowIndex], timeframes[colIndex]);
  }

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id != CHARTEVENT_OBJECT_CLICK)
      return;

   if(StringFind(sparam, ObjectPrefix) != 0)
      return;

   string objectName = sparam;
   int suffixPos = StringFind(objectName, "_Rect");
   if(suffixPos > 0)
      objectName = StringSubstr(objectName, 0, suffixPos);
   suffixPos = StringFind(objectName, "_Label");
   if(suffixPos > 0)
      objectName = StringSubstr(objectName, 0, suffixPos);
   suffixPos = StringFind(objectName, "_Primary");
   if(suffixPos > 0)
      objectName = StringSubstr(objectName, 0, suffixPos);
   suffixPos = StringFind(objectName, "_Secondary");
   if(suffixPos > 0)
      objectName = StringSubstr(objectName, 0, suffixPos);

   if(StringFind(objectName, ObjectPrefix + "HeatTf_") == 0 || StringFind(objectName, ObjectPrefix + "HeatVal_") == 0)
     {
      HandleHeatMapClick(objectName);
      return;
     }

   if(StringFind(objectName, ObjectPrefix + "DashS_") == 0 ||
      StringFind(objectName, ObjectPrefix + "DashH_") == 0 ||
      StringFind(objectName, ObjectPrefix + "DashCell_") == 0)
      HandleDashboardClick(objectName);
  }

void RenderAlertBanner()
   {
    string bgName = ObjectPrefix + "AlertBg";
    string textName = ObjectPrefix + "AlertText";

    if(ValidationSummary == "" || ValidationSummary == "parity checks OK")
       {
         DeleteObjectIfExists(bgName);
         DeleteObjectIfExists(textName);
         return;
       }

    int bannerX = PanelX;
    int bannerY = 4;
    int bannerWidth = 520;
    int bannerHeight = PanelFontSize + 14;
    color bgColor = BlendColor(clrMaroon, clrOrangeRed, 0.45);
    color borderColor = BlendColor(bgColor, clrWhite, 0.15);
    CreatePanelRect(bgName, bannerX, bannerY, bannerWidth, bannerHeight, bgColor, borderColor);
    CreatePanelLabel(textName, "MACD-v warning: " + ValidationSummary, bannerX + 8, bannerY + 3, clrWhite, PanelFontSize, "Arial Bold");
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
   snapshot.stateColor = GetStateColor(snapshot.state);
   snapshot.histColor = (ArraySize(hists) > 1 && hists[0] > hists[1]) ? clrLimeGreen : (color)0x00674CED;
   snapshot.valid = true;
   return(true);
  }

void ApplyModeStyles()
  {
   SetIndexStyle(0, DRAW_NONE);

   if(DisplayMode == Heat_Map)
      IndicatorShortName("MACD-v Heat Map");
   else
      IndicatorShortName("MACD-v Dashboard");
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


void CreatePanelRect(string name, int x, int y, int width, int height, color bg, color border)
  {
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
  }

void CreatePanelLabel(string name, string text, int x, int y, color clr, int size, string font = "", bool clickable = false)
  {
   if(font == "")
      font = PanelFontName;
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, name, OBJPROP_CORNER, PanelCorner);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, font);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, clickable);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   if(clickable)
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
  }

bool ShouldRefreshPanel(bool forceRefresh = false)
  {
   string layoutKey = BuildPanelLayoutKey();
   if(forceRefresh || PanelNeedsRefresh || layoutKey != LastPanelLayoutKey)
      return(true);

   int refreshSeconds = MathMax(1, PanelRefreshSeconds);
   if(LastPanelRefresh == 0)
      return(true);

   return((TimeLocal() - LastPanelRefresh) >= refreshSeconds);
  }

void RefreshPanel(bool forceRefresh = false)
  {
   if(!ShouldRefreshPanel(forceRefresh))
      return;

   string layoutKey = BuildPanelLayoutKey();
   if(layoutKey != LastPanelLayoutKey)
     {
      DeleteAllManagedObjects();
      ClearPanelCaches();
      LastPanelLayoutKey = layoutKey;
     }
   else
      ClearPanelCaches(false);

   ActivePanelPassId++;
   ValidateConfiguration();

   if(DisplayMode == Heat_Map)
      RenderHeatMap();
   else
      RenderDashboard();

   ChartRedraw(0);
   LastPanelRefresh = TimeLocal();
   PanelNeedsRefresh = false;
  }

void OnTimer()
  {
   RefreshPanel(false);
  }

int GetEnabledTimeframes(int &timeframes[])
  {
   ArrayResize(timeframes, 0);
   if(UseTF1) { int size1 = ArraySize(timeframes); ArrayResize(timeframes, size1 + 1); timeframes[size1] = ResolveTimeframe(TF1); }
   if(UseTF2) { int size2 = ArraySize(timeframes); ArrayResize(timeframes, size2 + 1); timeframes[size2] = ResolveTimeframe(TF2); }
   if(UseTF3) { int size3 = ArraySize(timeframes); ArrayResize(timeframes, size3 + 1); timeframes[size3] = ResolveTimeframe(TF3); }
   if(UseTF4) { int size4 = ArraySize(timeframes); ArrayResize(timeframes, size4 + 1); timeframes[size4] = ResolveTimeframe(TF4); }
   if(UseTF5) { int size5 = ArraySize(timeframes); ArrayResize(timeframes, size5 + 1); timeframes[size5] = ResolveTimeframe(TF5); }
   return(ArraySize(timeframes));
  }

int GetEnabledSymbols(string &symbols[])
  {
   ArrayResize(symbols, 0);
   if(UseSymbol1 && Symbol1 != "") { int size1 = ArraySize(symbols); ArrayResize(symbols, size1 + 1); symbols[size1] = Symbol1; }
   if(UseSymbol2 && Symbol2 != "") { int size2 = ArraySize(symbols); ArrayResize(symbols, size2 + 1); symbols[size2] = Symbol2; }
   if(UseSymbol3 && Symbol3 != "") { int size3 = ArraySize(symbols); ArrayResize(symbols, size3 + 1); symbols[size3] = Symbol3; }
   if(UseSymbol4 && Symbol4 != "") { int size4 = ArraySize(symbols); ArrayResize(symbols, size4 + 1); symbols[size4] = Symbol4; }
   if(UseSymbol5 && Symbol5 != "") { int size5 = ArraySize(symbols); ArrayResize(symbols, size5 + 1); symbols[size5] = Symbol5; }
   if(UseSymbol6 && Symbol6 != "") { int size6 = ArraySize(symbols); ArrayResize(symbols, size6 + 1); symbols[size6] = Symbol6; }
   if(UseSymbol7 && Symbol7 != "") { int size7 = ArraySize(symbols); ArrayResize(symbols, size7 + 1); symbols[size7] = Symbol7; }
   return(ArraySize(symbols));
  }

void RenderHeatMap()
  {
   int timeframes[];
   int totalTfs = GetEnabledTimeframes(timeframes);
   if(totalTfs <= 0)
      return;

   int titleHeight = PanelFontSize + 14;
   int statusHeight = PanelFontSize + 10;
   int headerHeight = PanelFontSize + 14;
   int rowHeight = PanelFontSize + 16;
   int footerHeight = PanelFontSize + 10;
   int colWidthTf = 72;
   int width = 760;
   int contentWidth = width - 26;
   int colWidthSnapshot = contentWidth - colWidthTf - 6;
   int height = titleHeight + statusHeight + headerHeight + (totalTfs * rowHeight) + footerHeight + 26;
   int tableTop = PanelY + titleHeight + statusHeight + 8;

   CreatePanelRect(ObjectPrefix + "HeatBg", PanelX, PanelY, width, height, PanelBackground, clrDimGray);
   CreatePanelLabel(ObjectPrefix + "HeatTitle", "MACD-v Heat Map", PanelX + 12, PanelY + 6, PanelHeader, PanelFontSize + 2, "Arial Bold");

   string heatConnText = IsPanelConnected() ? "Connected" : "Disconnected";
   color heatConnColor = IsPanelConnected() ? clrLimeGreen : clrOrangeRed;
   CreatePanelLabel(ObjectPrefix + "HeatConn", heatConnText, PanelX + width - 92, PanelY + 8, heatConnColor, PanelFontSize, "Arial Bold");

   string heatStatus = "Updated " + TimeToString(TimeLocal(), TIME_SECONDS) +
                       " | Chart " + Symbol() + " " + TimeframeToLabel(Period()) +
                       " | Osc TF " + GetOscillatorTimeframeLabel();
   CreatePanelLabel(ObjectPrefix + "HeatStatusTop", heatStatus, PanelX + 12, PanelY + titleHeight, BlendColor(PanelText, PanelBackground, 0.24), PanelFontSize);

   CreatePanelTextCell(ObjectPrefix + "HeatHdrTf", "TF", PanelX + 10, tableTop, colWidthTf, headerHeight, GetHeaderCellColor(), GetHeaderBorderColor(), PanelHeader, PanelFontSize + 1, true);
   CreatePanelTextCell(ObjectPrefix + "HeatHdrSnapshot", "Snapshot", PanelX + 16 + colWidthTf, tableTop, colWidthSnapshot, headerHeight, GetHeaderCellColor(), GetHeaderBorderColor(), PanelHeader, PanelFontSize + 1, true);

   int unavailableCount = 0;

   for(int i = 0; i < totalTfs; i++)
     {
      MacdvSnapshot snapshot;
      string reason;
      int rowY = tableTop + headerHeight + 4 + (i * rowHeight);
      color cellColor = BlendColor(PanelBackground, clrDimGray, 0.55);
      color borderColor = clrDimGray;
      string valueText = "Waiting for data";
      if(IsSnapshotUsable(Symbol(), timeframes[i], snapshot, reason))
        {
         cellColor = GetPanelCellColor(snapshot.stateColor);
         borderColor = GetPanelBorderColor(snapshot.stateColor);
         valueText = FormatHeatMapSnapshot(snapshot);
        }
      else
         unavailableCount++;

      CreatePanelTextCell(ObjectPrefix + "HeatTf_" + IntegerToString(i), TimeframeToLabel(timeframes[i]), PanelX + 10, rowY, colWidthTf, rowHeight - 2, GetRowBaseColor(i), BlendColor(GetRowBaseColor(i), clrDimGray, 0.60), PanelText, PanelFontSize + 1, true, true);
      CreatePanelTextCell(ObjectPrefix + "HeatVal_" + IntegerToString(i), valueText, PanelX + 16 + colWidthTf, rowY, colWidthSnapshot, rowHeight - 2, cellColor, borderColor, PanelText, PanelFontSize, false, true);
     }

   string statusText = "Rows: " + IntegerToString(totalTfs) + " | Missing: " + IntegerToString(unavailableCount) + " | Cells show value, signal, histogram, and state";
   if(ValidationSummary != "")
      statusText = statusText + " | " + ValidationSummary;
   CreatePanelLabel(ObjectPrefix + "HeatStatus", statusText, PanelX + 12, PanelY + height - footerHeight - 2, BlendColor(PanelText, PanelBackground, 0.30), PanelFontSize);
  }

void RenderDashboard()
  {
   string symbols[];
   int timeframes[];
   int totalSymbols = GetEnabledSymbols(symbols);
   int totalTfs = GetEnabledTimeframes(timeframes);
   if(totalSymbols <= 0 || totalTfs <= 0)
      return;

   int titleHeight = PanelFontSize + 14;
   int statusHeight = PanelFontSize + 10;
   int summaryHeight = PanelFontSize + 10;
   int headerHeight = PanelFontSize + 14;
   int rowHeight = PanelFontSize + 30;
   int rowGap = 4;
   int footerHeight = PanelFontSize + 10;
   int cellWidth = 160;
   int headerWidth = 188;
   int width = headerWidth + (totalTfs * cellWidth) + 34;
   int height = titleHeight + statusHeight + summaryHeight + headerHeight + (totalSymbols * rowHeight) + (MathMax(totalSymbols - 1, 0) * rowGap) + footerHeight + 30;
   int tableTop = PanelY + titleHeight + statusHeight + summaryHeight + 6;

   CreatePanelRect(ObjectPrefix + "DashBg", PanelX, PanelY, width, height, PanelBackground, clrDimGray);
   CreatePanelLabel(ObjectPrefix + "DashTitle", "MACD-v Dashboard", PanelX + 12, PanelY + 6, PanelHeader, PanelFontSize + 2, "Arial Bold");

   string dashConnText = IsPanelConnected() ? "Connected" : "Disconnected";
   color dashConnColor = IsPanelConnected() ? clrLimeGreen : clrOrangeRed;
   CreatePanelLabel(ObjectPrefix + "DashConn", dashConnText, PanelX + width - 92, PanelY + 8, dashConnColor, PanelFontSize, "Arial Bold");

   string dashStatus = "Updated " + TimeToString(TimeLocal(), TIME_SECONDS) +
                       " | Chart " + Symbol() + " " + TimeframeToLabel(Period()) +
                       " | Osc TF " + GetOscillatorTimeframeLabel();
   CreatePanelLabel(ObjectPrefix + "DashStatus", dashStatus, PanelX + 12, PanelY + titleHeight, BlendColor(PanelText, PanelBackground, 0.24), PanelFontSize);

   string dashSummary = "Tracking " + IntegerToString(totalSymbols) + " symbol(s) across " + IntegerToString(totalTfs) +
                        " timeframe(s) | Cell color follows MACD-v state";
   if(ValidationSummary != "")
      dashSummary = dashSummary + " | " + ValidationSummary;
   CreatePanelLabel(ObjectPrefix + "DashSummary", dashSummary, PanelX + 12, PanelY + titleHeight + statusHeight, BlendColor(PanelText, PanelBackground, 0.30), PanelFontSize);

   int unavailableCount = 0;

   CreatePanelTextCell(ObjectPrefix + "DashHdrSymbol", "Symbol", PanelX + 10, tableTop, headerWidth - 10, headerHeight, GetHeaderCellColor(), GetHeaderBorderColor(), PanelHeader, PanelFontSize + 1, true);

   for(int col = 0; col < totalTfs; col++)
      CreatePanelTextCell(ObjectPrefix + "DashH_" + IntegerToString(col), TimeframeToLabel(timeframes[col]), PanelX + headerWidth + 6 + (col * cellWidth), tableTop, cellWidth - 6, headerHeight, GetHeaderCellColor(), GetHeaderBorderColor(), PanelHeader, PanelFontSize + 1, true, true);

   for(int row = 0; row < totalSymbols; row++)
     {
         int rowY = tableTop + headerHeight + 4 + (row * (rowHeight + rowGap));
      string resolvedSymbol;
      bool symbolReady = EnsureSymbolReady(symbols[row], resolvedSymbol);
         color symbolCellColor = GetRowBaseColor(row);
      color symbolBorder = symbolReady ? BlendColor(GetRowBaseColor(row), clrDimGray, 0.65) : clrOrange;
         color symbolPrimaryColor = symbolReady ? GetReadableTextColor(symbolCellColor) : clrOrange;
         color symbolNoteColor = symbolReady ? GetMutedReadableTextColor(symbolCellColor) : BlendColor(clrOrange, symbolCellColor, 0.18);
         CreateDashboardSymbolCell(ObjectPrefix + "DashS_" + IntegerToString(row), symbols[row], GetDashboardSymbolCaption(symbols[row], resolvedSymbol, symbolReady), PanelX + 10, rowY, headerWidth - 10, rowHeight - 2, symbolCellColor, symbolBorder, symbolPrimaryColor, symbolNoteColor, true);

      for(int col = 0; col < totalTfs; col++)
        {
         MacdvSnapshot snapshot;
         string reason;
         color cellColor = GetRowBaseColor(row);
         color borderColor = BlendColor(GetRowBaseColor(row), clrDimGray, 0.65);
         string primaryText = "--";
         string secondaryText = "Waiting for data";
         color secondaryColor = BlendColor(PanelText, PanelBackground, 0.36);

         if(IsSnapshotUsable(symbols[row], timeframes[col], snapshot, reason))
           {
            cellColor = GetPanelCellColor(snapshot.stateColor);
            borderColor = GetPanelBorderColor(snapshot.stateColor);
            primaryText = DoubleToString(snapshot.val, 1);
                  secondaryText = BuildDashboardMetricSecondaryText(snapshot);
            secondaryColor = GetDashboardBiasTextColor(cellColor, snapshot.histColor);
           }
         else
           {
            unavailableCount++;
            if(reason == "symbol unavailable")
               borderColor = clrOrange;
            else
               borderColor = clrFireBrick;

            if(reason != "")
               secondaryText = GetDashboardReasonText(reason);

            secondaryColor = GetMutedReadableTextColor(cellColor);
           }

         CreateDashboardMetricCell(ObjectPrefix + "DashCell_" + IntegerToString(row) + "_" + IntegerToString(col), primaryText, secondaryText,
                                   PanelX + headerWidth + 6 + (col * cellWidth), rowY, cellWidth - 6, rowHeight - 2,
                                   cellColor, borderColor, GetReadableTextColor(cellColor), secondaryColor, true);
        }
     }

   int totalCells = totalSymbols * totalTfs;
   string footerText = "Cells: " + IntegerToString(totalCells) + " | Missing: " + IntegerToString(unavailableCount) + " | Each cell shows MACD-v value with state and histogram bias";
   CreatePanelLabel(ObjectPrefix + "DashFooter", footerText, PanelX + 12, PanelY + height - footerHeight - 2, BlendColor(PanelText, PanelBackground, 0.30), PanelFontSize);
  }

void ValidateConfiguration()
  {
   ValidationSummary = "";
   int chartMinutes = TimeframeToMinutes(Period());
   bool hasWarning = false;

    {
         int timeframes[];
         int count = GetEnabledTimeframes(timeframes);
         int invalidTfCount = 0;
         for(int i = 0; i < count; i++)
            {
             if(chartMinutes > TimeframeToMinutes(timeframes[i]))
                {
                  Print("MACD-v: chart timeframe should be less than or equal to panel timeframe ", TimeframeToLabel(timeframes[i]), ".");
                  invalidTfCount++;
                }
            }

         if(invalidTfCount > 0)
            {
             ValidationSummary = "chart TF above " + IntegerToString(invalidTfCount) + " panel TF(s)";
             hasWarning = true;
            }

         string symbols[];
         int symbolCount = GetEnabledSymbols(symbols);
         int unavailableSymbols = 0;
         for(int j = 0; j < symbolCount; j++)
            {
             string resolvedSymbol;
             if(!EnsureSymbolReady(symbols[j], resolvedSymbol))
                  unavailableSymbols++;
            }

         if(unavailableSymbols > 0)
            {
             if(ValidationSummary != "")
                  ValidationSummary = ValidationSummary + "; ";
             ValidationSummary = ValidationSummary + IntegerToString(unavailableSymbols) + " symbol(s) unavailable";
             hasWarning = true;
            }
    }

    if(!hasWarning)
         ValidationSummary = "parity checks OK";
   }

int init()
     {
    IndicatorBuffers(1);

    SetIndexBuffer(0, dummyBuffer);
    SetIndexLabel(0, "");
    SetIndexEmptyValue(0, EMPTY_VALUE);

   ObjectPrefix = "MACDv_" + IntegerToString((int)ChartID()) + "_";
   InitializeSymbolAffixes();
    ClearPanelCaches();
    EventSetTimer(1);

   ApplyModeStyles();
    RefreshPanel(true);
   LastValidatedMode = DisplayMode;
   return(0);
  }

int deinit()
  {
    EventKillTimer();
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
         ClearPanelCaches();
         LastPanelLayoutKey = "";
         LastPanelRefresh = 0;
         PanelNeedsRefresh = true;
      LastValidatedMode = DisplayMode;
     }

    RefreshPanel(PanelNeedsRefresh);

   return(0);
  }
