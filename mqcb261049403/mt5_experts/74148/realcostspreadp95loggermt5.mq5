//+------------------------------------------------------------------+
//|                                   RealCostSpreadP95LoggerMT5.mq5 |
//|                                Open source spread logger for MT5 |
//|                                                                  |
//| Samples the current chart spread, calculates average, p50, p90,  |
//| p95, p99 and maximum spread, shows a compact chart panel, and    |
//| optionally writes a local CSV file. It does not trade.           |
//+------------------------------------------------------------------+
#property copyright "RealCost"
#property link      ""
#property version   "1.00"
#property strict
#property description "Open source MT5 spread logger with average, p50, p90, p95, p99, maximum spread and CSV export."
#property description "This educational utility does not open, modify or close trades."

enum ENUM_RCP95_CORNER
  {
   RCP95_TOP_LEFT=CORNER_LEFT_UPPER,
   RCP95_TOP_RIGHT=CORNER_RIGHT_UPPER,
   RCP95_BOTTOM_LEFT=CORNER_LEFT_LOWER,
   RCP95_BOTTOM_RIGHT=CORNER_RIGHT_LOWER
  };

input int                 InpSampleSeconds        = 1;                         // Spread sample interval, seconds
input int                 InpMaxSamples           = 20000;                     // Samples kept in memory
input int                 InpAlertSpreadPoints    = 0;                         // Alert if spread exceeds points, 0=off
input int                 InpAlertCooldownSeconds = 60;                        // Minimum seconds between alerts
input bool                InpPopupAlerts          = true;                      // Show popup alerts
input bool                InpPushNotifications    = false;                     // Send mobile push notifications
input bool                InpWriteCsv             = true;                      // Write CSV log
input bool                InpUseCommonFilesFolder = false;                     // Write to common terminal files folder
input string              InpFilePrefix           = "RealCostSpreadP95Logger"; // CSV file prefix
input int                 InpCsvWriteSeconds      = 60;                        // CSV write interval, seconds
input bool                InpShowPanel            = true;                      // Show chart panel
input ENUM_RCP95_CORNER   InpPanelCorner          = RCP95_TOP_LEFT;            // Panel corner
input int                 InpPanelX               = 12;                        // Panel X offset
input int                 InpPanelY               = 18;                        // Panel Y offset
input color               InpPanelBackColor       = clrBlack;                  // Panel background color
input color               InpPanelTextColor       = clrWhite;                  // Panel text color
input color               InpPanelAccentColor     = clrDodgerBlue;             // Normal accent color
input color               InpPanelWarningColor    = clrTomato;                 // Alert color

#define RCP95_NO_VALUE 1.7e+308
#define RCP95_PANEL_PREFIX "RCP95_PANEL_"
#define RCP95_LINE_COUNT 11

double   g_spread_samples[];
int      g_file_handle       = INVALID_HANDLE;
string   g_file_name         = "";
datetime g_last_sample_time  = 0;
datetime g_last_csv_time     = 0;
datetime g_last_alert_time   = 0;
double   g_last_spread       = RCP95_NO_VALUE;
double   g_spread_avg        = RCP95_NO_VALUE;
double   g_spread_p50        = RCP95_NO_VALUE;
double   g_spread_p90        = RCP95_NO_VALUE;
double   g_spread_p95        = RCP95_NO_VALUE;
double   g_spread_p99        = RCP95_NO_VALUE;
double   g_spread_max        = RCP95_NO_VALUE;
double   g_above_threshold   = RCP95_NO_VALUE;
bool     g_last_alert_state  = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpSampleSeconds < 1)
     {
      Print("RealCost Spread P95 Logger: InpSampleSeconds must be at least 1.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpMaxSamples < 100)
     {
      Print("RealCost Spread P95 Logger: InpMaxSamples must be at least 100.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpAlertCooldownSeconds < 10)
     {
      Print("RealCost Spread P95 Logger: InpAlertCooldownSeconds must be at least 10.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(InpCsvWriteSeconds < 1)
     {
      Print("RealCost Spread P95 Logger: InpCsvWriteSeconds must be at least 1.");
      return INIT_PARAMETERS_INCORRECT;
     }

   ArrayResize(g_spread_samples,0);

   if(InpWriteCsv && !OpenCsvFile())
      return INIT_FAILED;

   EventSetTimer(InpSampleSeconds);
   SampleSpread();

   if(InpShowPanel)
      CreatePanel();

   UpdatePanel();
   Print("RealCost Spread P95 Logger started on ",_Symbol,
         ". This utility samples spread only and does not trade.");
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();

   if(g_file_handle != INVALID_HANDLE)
     {
      FileFlush(g_file_handle);
      FileClose(g_file_handle);
      g_file_handle = INVALID_HANDLE;
     }

   DeletePanel();
   Print("RealCost Spread P95 Logger stopped. Reason: ",IntegerToString(reason));
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   TrySampleSpread();
   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Timer handler                                                    |
//+------------------------------------------------------------------+
void OnTimer()
  {
   TrySampleSpread();
   UpdatePanel();
  }

//+------------------------------------------------------------------+
//| Avoid duplicate samples from tick and timer in the same interval  |
//+------------------------------------------------------------------+
void TrySampleSpread()
  {
   if(TimeCurrent() - g_last_sample_time < InpSampleSeconds)
      return;

   SampleSpread();
  }

//+------------------------------------------------------------------+
//| Spread sampling                                                  |
//+------------------------------------------------------------------+
void SampleSpread()
  {
   double spread_points = GetCurrentSpreadPoints();
   if(spread_points == RCP95_NO_VALUE)
      return;

   g_last_sample_time = TimeCurrent();
   g_last_spread      = spread_points;
   AddSample(g_spread_samples,spread_points);
   UpdateStats();

   if(InpWriteCsv && TimeCurrent() - g_last_csv_time >= InpCsvWriteSeconds)
     {
      WriteCsvSample(spread_points);
      g_last_csv_time = TimeCurrent();
     }

   g_last_alert_state = (InpAlertSpreadPoints > 0 && spread_points >= InpAlertSpreadPoints);

   if(g_last_alert_state && TimeCurrent() - g_last_alert_time >= InpAlertCooldownSeconds)
     {
      string message = "RealCost Spread P95 Logger: spread on " + _Symbol +
                       " reached " + DoubleToString(spread_points,1) + " points.";
      if(InpPopupAlerts)
         Alert(message);
      if(InpPushNotifications)
         SendNotification(message);
      Print(message);
      g_last_alert_time = TimeCurrent();
     }
  }

//+------------------------------------------------------------------+
//| Current chart spread in points                                   |
//+------------------------------------------------------------------+
double GetCurrentSpreadPoints()
  {
   MqlTick tick;
   double point = SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   if(point <= 0.0)
      return RCP95_NO_VALUE;

   if(SymbolInfoTick(_Symbol,tick) && tick.ask > 0.0 && tick.bid > 0.0)
      return (tick.ask - tick.bid) / point;

   long raw_spread = SymbolInfoInteger(_Symbol,SYMBOL_SPREAD);
   if(raw_spread >= 0)
      return (double)raw_spread;

   return RCP95_NO_VALUE;
  }

//+------------------------------------------------------------------+
//| Keep a capped in-memory sample set                               |
//+------------------------------------------------------------------+
void AddSample(double &samples[],const double value)
  {
   if(value == RCP95_NO_VALUE || !MathIsValidNumber(value))
      return;

   int n = ArraySize(samples);
   if(n < InpMaxSamples)
     {
      ArrayResize(samples,n+1);
      samples[n] = value;
      return;
     }

   for(int i=1; i<n; i++)
      samples[i-1] = samples[i];

   if(n > 0)
      samples[n-1] = value;
  }

//+------------------------------------------------------------------+
//| Average                                                          |
//+------------------------------------------------------------------+
double Average(double &samples[])
  {
   int n = ArraySize(samples);
   if(n <= 0)
      return RCP95_NO_VALUE;

   double sum = 0.0;
   for(int i=0; i<n; i++)
      sum += samples[i];

   return sum / n;
  }

//+------------------------------------------------------------------+
//| Maximum                                                          |
//+------------------------------------------------------------------+
double Maximum(double &samples[])
  {
   int n = ArraySize(samples);
   if(n <= 0)
      return RCP95_NO_VALUE;

   double result = samples[0];
   for(int i=1; i<n; i++)
      if(samples[i] > result)
         result = samples[i];

   return result;
  }

//+------------------------------------------------------------------+
//| Percentile with linear interpolation                             |
//+------------------------------------------------------------------+
double Percentile(double &samples[],const double percentile)
  {
   int n = ArraySize(samples);
   if(n <= 0)
      return RCP95_NO_VALUE;

   double copy[];
   ArrayResize(copy,n);
   for(int i=0; i<n; i++)
      copy[i] = samples[i];

   ArraySort(copy);

   double rank = (percentile / 100.0) * (n - 1);
   int lower   = (int)MathFloor(rank);
   int upper   = (int)MathCeil(rank);
   lower       = MathMax(0,MathMin(n - 1,lower));
   upper       = MathMax(0,MathMin(n - 1,upper));

   if(lower == upper)
      return copy[lower];

   double fraction = rank - lower;
   return copy[lower] + (copy[upper] - copy[lower]) * fraction;
  }

//+------------------------------------------------------------------+
//| Percentage of samples above a threshold                          |
//+------------------------------------------------------------------+
double AboveThresholdPercent(double &samples[],const int threshold_points)
  {
   int n = ArraySize(samples);
   if(n <= 0 || threshold_points <= 0)
      return RCP95_NO_VALUE;

   int count = 0;
   for(int i=0; i<n; i++)
      if(samples[i] >= threshold_points)
         count++;

   return 100.0 * count / n;
  }

//+------------------------------------------------------------------+
//| Update cached statistics once per sample                         |
//+------------------------------------------------------------------+
void UpdateStats()
  {
   g_spread_avg      = Average(g_spread_samples);
   g_spread_p50      = Percentile(g_spread_samples,50.0);
   g_spread_p90      = Percentile(g_spread_samples,90.0);
   g_spread_p95      = Percentile(g_spread_samples,95.0);
   g_spread_p99      = Percentile(g_spread_samples,99.0);
   g_spread_max      = Maximum(g_spread_samples);
   g_above_threshold = AboveThresholdPercent(g_spread_samples,InpAlertSpreadPoints);
  }

//+------------------------------------------------------------------+
//| CSV handling                                                     |
//+------------------------------------------------------------------+
bool OpenCsvFile()
  {
   string date_part = DateForFile(TimeCurrent());
   string symbol    = SafeSymbolForFile(_Symbol);

   g_file_name = InpFilePrefix + "_" + symbol + "_" + date_part + ".csv";
   int flags = FILE_READ | FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_SHARE_READ;
   if(InpUseCommonFilesFolder)
      flags |= FILE_COMMON;

   g_file_handle = FileOpen(g_file_name,flags,',');
   if(g_file_handle == INVALID_HANDLE)
     {
      Print("RealCost Spread P95 Logger: unable to open CSV file. Error ",
            IntegerToString(GetLastError()));
      return false;
     }

   if(FileSize(g_file_handle) == 0)
     {
      FileWrite(g_file_handle,
                "time",
                "symbol",
                "bid",
                "ask",
                "spread_points",
                "sample_count",
                "avg_spread_points",
                "p50_spread_points",
                "p90_spread_points",
                "p95_spread_points",
                "p99_spread_points",
                "max_spread_points",
                "alert_threshold_points",
                "above_threshold_percent");
      FileFlush(g_file_handle);
     }

   FileSeek(g_file_handle,0,SEEK_END);
   return true;
  }

//+------------------------------------------------------------------+
//| Write spread sample to CSV                                       |
//+------------------------------------------------------------------+
void WriteCsvSample(const double spread_points)
  {
   if(g_file_handle == INVALID_HANDLE)
      return;

   MqlTick tick;
   SymbolInfoTick(_Symbol,tick);

   FileWrite(g_file_handle,
             TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
             _Symbol,
             DoubleToString(tick.bid,_Digits),
             DoubleToString(tick.ask,_Digits),
             DoubleToString(spread_points,1),
             IntegerToString(ArraySize(g_spread_samples)),
             FormatCsvNumber(g_spread_avg,1),
             FormatCsvNumber(g_spread_p50,1),
             FormatCsvNumber(g_spread_p90,1),
             FormatCsvNumber(g_spread_p95,1),
             FormatCsvNumber(g_spread_p99,1),
             FormatCsvNumber(g_spread_max,1),
             IntegerToString(InpAlertSpreadPoints),
             FormatCsvNumber(g_above_threshold,2));

   FileFlush(g_file_handle);
  }

//+------------------------------------------------------------------+
//| Panel creation                                                   |
//+------------------------------------------------------------------+
void CreatePanel()
  {
   DeletePanel();

   string bg = RCP95_PANEL_PREFIX + "BG";
   ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,bg,OBJPROP_CORNER,(int)InpPanelCorner);
   ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,InpPanelX);
   ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,InpPanelY);
   ObjectSetInteger(0,bg,OBJPROP_XSIZE,390);
   ObjectSetInteger(0,bg,OBJPROP_YSIZE,230);
   ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,InpPanelBackColor);
   ObjectSetInteger(0,bg,OBJPROP_COLOR,InpPanelAccentColor);
   ObjectSetInteger(0,bg,OBJPROP_BACK,false);
   ObjectSetInteger(0,bg,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,bg,OBJPROP_HIDDEN,true);

   for(int i=0; i<RCP95_LINE_COUNT; i++)
     {
      string name = PanelLineName(i);
      ObjectCreate(0,name,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,(int)InpPanelCorner);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,InpPanelX + 12);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,InpPanelY + 10 + i * 19);
      ObjectSetInteger(0,name,OBJPROP_COLOR,(i == 0 ? InpPanelAccentColor : InpPanelTextColor));
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(i == 0 ? 10 : 9));
      ObjectSetString(0,name,OBJPROP_FONT,"Consolas");
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
  }

//+------------------------------------------------------------------+
//| Panel update                                                     |
//+------------------------------------------------------------------+
void UpdatePanel()
  {
   if(!InpShowPanel)
      return;

   if(ObjectFind(0,RCP95_PANEL_PREFIX + "BG") < 0)
      CreatePanel();

   color status_color = g_last_alert_state ? InpPanelWarningColor : InpPanelAccentColor;
   ObjectSetInteger(0,PanelLineName(0),OBJPROP_COLOR,status_color);
   ObjectSetInteger(0,RCP95_PANEL_PREFIX + "BG",OBJPROP_COLOR,status_color);

   SetPanelLine(0,"RealCost Spread P95 Logger");
   SetPanelLine(1,"Symbol: " + _Symbol);
   SetPanelLine(2,"Spread now: " + FormatPoints(g_last_spread));
   SetPanelLine(3,"Avg / p50: " + FormatPoints(g_spread_avg) + " / " + FormatPoints(g_spread_p50));
   SetPanelLine(4,"p90 / p95 / p99: " +
                  FormatPoints(g_spread_p90) + " / " +
                  FormatPoints(g_spread_p95) + " / " +
                  FormatPoints(g_spread_p99));
   SetPanelLine(5,"Max / samples: " + FormatPoints(g_spread_max) + " / " +
                  IntegerToString(ArraySize(g_spread_samples)));
   SetPanelLine(6,"Alert threshold: " +
                  (InpAlertSpreadPoints > 0 ? IntegerToString(InpAlertSpreadPoints) + " pt" : "off"));
   SetPanelLine(7,"Above threshold: " + FormatPercent(g_above_threshold));
   SetPanelLine(8,"Status: " + (g_last_alert_state ? "spread above threshold" : "normal"));
   SetPanelLine(9,"CSV: " + (InpWriteCsv ? g_file_name : "off"));
   SetPanelLine(10,"No trading actions. Local data only.");

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+
//| Delete chart objects                                             |
//+------------------------------------------------------------------+
void DeletePanel()
  {
   ObjectDelete(0,RCP95_PANEL_PREFIX + "BG");

   for(int i=0; i<RCP95_LINE_COUNT; i++)
      ObjectDelete(0,PanelLineName(i));
  }

//+------------------------------------------------------------------+
//| Utility helpers                                                  |
//+------------------------------------------------------------------+
void SetPanelLine(const int index,const string text)
  {
   if(index < 0 || index >= RCP95_LINE_COUNT)
      return;

   ObjectSetString(0,PanelLineName(index),OBJPROP_TEXT,text);
  }

string PanelLineName(const int index)
  {
   return RCP95_PANEL_PREFIX + "LINE_" + IntegerToString(index);
  }

string SafeSymbolForFile(const string raw_symbol)
  {
   string symbol = raw_symbol;
   StringReplace(symbol,"/","_");
   StringReplace(symbol,"\\","_");
   StringReplace(symbol,":","_");
   StringReplace(symbol,".","_");
   StringReplace(symbol," ","_");
   return symbol;
  }

string DateForFile(const datetime value)
  {
   MqlDateTime dt;
   TimeToStruct(value,dt);
   return StringFormat("%04d%02d%02d",dt.year,dt.mon,dt.day);
  }

string FormatPoints(const double value)
  {
   if(value == RCP95_NO_VALUE || !MathIsValidNumber(value))
      return "n/a";

   return DoubleToString(value,1) + " pt";
  }

string FormatPercent(const double value)
  {
   if(value == RCP95_NO_VALUE || !MathIsValidNumber(value))
      return "n/a";

   return DoubleToString(value,2) + "%";
  }

string FormatCsvNumber(const double value,const int digits)
  {
   if(value == RCP95_NO_VALUE || !MathIsValidNumber(value))
      return "";

   return DoubleToString(value,digits);
  }
//+------------------------------------------------------------------+
