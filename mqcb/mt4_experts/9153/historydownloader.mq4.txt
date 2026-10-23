// +——————————————————————————————————————————————————————————————————————————————————————————————————————+
// ¦     History Downloader Expert                                          HistoryDownloader.mq4         ¦
// ¦  EA for downloading quote history to the current chart.                                              ¦
// ¦  The idea is borrowed from the s-Downloader script (https://www.mql5.com/en/code/9099) of respected  ¦
// ¦ Talex.                                                                                               ¦
// ¦  The main difference from s-Downloader: ONLY the bars of the current timeframe are downloaded        ¦
// ¦ up to the specified time.                                                                            ¦
// ¦  Make sure to do the following before launching the EA                                               ¦
// ¦     •disable auto scroll;                                                                            ¦
// ¦     •check the maximum number of bars in the Options;                                                ¦
// ¦     •launch HistoryDownloaderI indicator on the chart.                                               ¦
// ¦ The attached indicator is necessary for receiving the Bars variable and Time[] time series.          ¦
// ¦ The EA operates on a single start() iteration, meaning that it does not                              ¦
// ¦ receive updated data from the pre-defined chart variables. The indicator creates and                 ¦
// ¦ updates the global variables using the data necessary to the EA. This is its only function.          ¦
// ¦------------------------------------------------------------------------------------------------------¦
// ¦     [release 1] 23.08.2009                                                                           ¦
// ¦ •The first release. Bug reports and suggestions for optimization are welcome ;)                      ¦
// ¦                                                            | © xp3rienced, Ekaterinburg 2009         ¦
// +——————————————————————————————————————————————————————————————————————————————————————————————————————+
#property copyright "© xp3rienced"
#property link      "no4ta[at]inbox.ru"

#import "user32.dll"
  int PostMessageA (int hWnd, int Msg, int wParam, int lParam);
#import

#define PAUSE_ON_UPDWAIT 0
#define KEYPRESS_REPEATS 2
#define WM_KEYDOWN 0x0100
#define WM_KEYUP 0x0101
#define VK_HOME 0x24
#define GVNAME_BAR_COUNT "BarOnChartCount"
#define GVNAME_FIRST_BAR_TIME "FirstBarDateTime"
#define DELIMITER_STR "————————————————————————————\n"
#define ERRSTR_CANT_RECV_HWND "Failed to obtain chart window descriptor (HWND).\nEA stopped"
#define ERRSTR_CANT_FIND_GV "Global variables not found. Make sure the indicator is connected to the chart.\nEA stopped"
#define ERRSTR_SUCCESS "Quotes downloaded successfully.\nDisable the EA and close the terminal leaving the chart window for writing history to disk\n(optional, although in my case, writing to disk happened only after these actions)\n"
#define ERRSTR_FAIL "Failed to download quotes.\nMake sure the auto scroll is disabled, while the Options have enough amount of \nbars in the window to hold the quote bars up to the specified date\n"

//====[ EA parameters ]====
extern string d1 = "Download limit. The date, up to which the history is downloaded";
extern datetime ToDate = D'01.01.2009';
extern string d2 = "Request timeout (ms). If no bars are added within the specified time, the bars download attempt is considered unsuccessful";
extern int Timeout = 1000;
extern string d3 = "Maximum allowed number of consecutive failed attempts. When reaching a specified number of failed attempts, the EA is stopped";
extern int MaxFailsInARow = 10;

//====[ global variables ]====
string CurrSymbol;                      // Current chart symbol
int CurrPeriod;                         // Current TF period
int ChartHWND;                          // Chart window descriptor
int BarsAtStart;                        // Number of bars on the chart before the launch
int ExecStartTime;                      // EA execution start time
int LastLatency;                        // Last chart update delay
string ErrorString;

//+------------------------------------------------------------------+
//|                  EA initialization function                      |
//+------------------------------------------------------------------+
int init()
{
//----
  CurrSymbol = Symbol();
  CurrPeriod = Period();
  ErrorString = "";
  GetLastError();           // Set last_error to zero
  ChartHWND = WindowHandle(CurrSymbol, CurrPeriod);
  if(ChartHWND == 0)
    ErrorString = StringConcatenate(ERRSTR_CANT_RECV_HWND, "\nError code: ", GetLastError(), "\n");
  if(!GlobalVariableCheck(GVNAME_BAR_COUNT) || !GlobalVariableCheck(GVNAME_FIRST_BAR_TIME))
    ErrorString = StringConcatenate(ErrorString, ERRSTR_CANT_FIND_GV);
  if(ErrorString != "")
  {
    Alert(ErrorString);
    return(0);
  }
  BarsAtStart = Bars;
  ExecStartTime = GetTickCount();
  start();                  // In case there are no incoming ticks. I know, this is not the most elegant solution :)
//----
  return(0);
}

//+------------------------------------------------------------------+
//|                 EA deinitialization function                     |
//+------------------------------------------------------------------+
int deinit()
{
//----
  UnpressHOME();            // (?) sometimes, it does not work for some reason
//----
  return(0);
}

//+------------------------------------------------------------------+
//|                    EA iteration function                         |
//+------------------------------------------------------------------+
int start()
{
  if(ErrorString != "") return(0);
//----
  bool success = DownloadHistory(ToDate);
  string s = StringConcatenate(DELIMITER_STR,
    "Downloaded bars: ", WindowFirstVisibleBar() - BarsAtStart + 1,
    "\nSpent time: ", FormatTime(GetTickCount() - ExecStartTime)
  );
  if(success) s = StringConcatenate(ERRSTR_SUCCESS, s);
  else s = StringConcatenate(ERRSTR_FAIL, s);
  Alert(s);
//----
  return(0);
}
//+----------------- Custom functions -----------------+

//+-----------------------------------------------------------------------------+
//|                 Function for downloading quote history                      |
//| Download by emulating pressing the HOME button in the chart                 |
//| window the EA is attached to. Only bars                                     |
//| of the current timeframe up to time set in the parameter are downloaded     |
//+-----------------------------------------------------------------------------+
bool DownloadHistory(datetime EndTime)
{
  int FailCount = 0;                                          // Counter of consecutive unsuccessful readings
  datetime FirstBarTime;
  while(!IsStopped())
  {
    PressHOME();                                              // Emulate pressing the HOME button
    if(WaitForChartUpdate())                                  // Wait for the chart update
      FailCount = 0;                                          // If we received quotes, set the error counter to zero
    else FailCount++;                                         // Failed, increase the error counter
    UnpressHOME();                                            // Release HOME
    FirstBarTime = GlobalVariableGet(GVNAME_FIRST_BAR_TIME);
    Comment(StringConcatenate("Downloading history up to ", TimeToStr(EndTime), "\nCurrent chart position: ",
      TimeToStr(FirstBarTime), "\nBars on the chart: ", GlobalVariableGet(GVNAME_BAR_COUNT),
      "\nLast chart update delay: ", LastLatency, "ms\nTime after launch: ",
      FormatTime(GetTickCount() - ExecStartTime)));
    if(FirstBarTime <= EndTime) return(true);
    if(FailCount >= MaxFailsInARow) return(false);
  }
}

//+------------------------------------------------------------------+
//|                 Function for waiting for chart update            |
//| The chart is updated by first visible bar index.                 |
//| Return values: true - chart updated (bars uploaded);             |
//| false - timeout expired, no update occurred.                     |
//| If the EA flow hinders the system for some reason(?),            |
//| change the PAUSE_ON_UPD_WAIT constant by setting the pause time  |
//| between the function loop iterations                             |
//+------------------------------------------------------------------+
bool WaitForChartUpdate()
{
  int FirstVisBar = WindowFirstVisibleBar();
  int Start = GetTickCount();
  while(true)
  {
    if(WindowFirstVisibleBar() > FirstVisBar) return(true);
    LastLatency = GetTickCount() - Start;                     // The last chart update delay value
    if(LastLatency >= Timeout) return(false);
    Sleep(PAUSE_ON_UPDWAIT);
  }
}

//+------------------------------------------------------------------+
//|              Function emulating pressing the HOME button         |
//| Emulate by sending a WM message to the chart window.             |
//| Use the KEYPRESS_REPEATS constant to define the number of        |
//| times the button is pressed. Range of values: 0..255             |
//+------------------------------------------------------------------+
void PressHOME()
{
  PostMessageA(ChartHWND, WM_KEYDOWN, VK_HOME, KEYPRESS_REPEATS);
}

//+------------------------------------------------------------------+
//|              Function emulating the HOME button release          |
//| Emulate by sending a WM message to the chart window.             |
//+------------------------------------------------------------------+
void UnpressHOME()
{
  PostMessageA(ChartHWND, WM_KEYUP, VK_HOME, 1);
}

//+------------------------------------------------------------------+
//|   Function for formatting milliseconds into time representation  |
//+------------------------------------------------------------------+
string FormatTime(int milliseconds)
{
  int seconds = milliseconds / 1000;
  return(StringConcatenate(TimeHour(seconds), "h ", TimeMinute(seconds), "m ", TimeSeconds(seconds), "s"));
}
//+------------------------------------------------------------------+