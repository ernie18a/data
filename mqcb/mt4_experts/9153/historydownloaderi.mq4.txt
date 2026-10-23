// +——————————————————————————————————————————————————————————————————————————————————————————————+
// ¦     History Downloader Indicator                                      HistoryDownloaderI.mq4 ¦
// ¦  Indicator for History Downloader EA.                                                        ¦
// ¦  The indicator's objective is setting and updating the global variables:                     ¦
// ¦     •BarOnChartCount - number of bars on the current chart;                                  ¦
// ¦     •FirstBarDateTime - date and time of the first bar on the chart.                         ¦
// ¦----------------------------------------------------------------------------------------------¦
// ¦     [release 1] 23.08.2009                                                                   ¦
// ¦ •The first release. Bug reports and suggestions for optimization are welcome ;)              ¦
// ¦                                                            | © xp3rienced, Ekaterinburg 2009 ¦
// +——————————————————————————————————————————————————————————————————————————————————————————————+
#property copyright "© xp3rienced"
#property link      "no4ta[at]inbox.ru"

#property indicator_separate_window

#define GVNAME_BAR_COUNT "BarOnChartCount"
#define GVNAME_FIRST_BAR_TIME "FirstBarDateTime"

//+------------------------------------------------------------------+
//|                Indicator deinitialization function               |
//+------------------------------------------------------------------+
int deinit()
{
//----
  GlobalVariableDel(GVNAME_BAR_COUNT);
  GlobalVariableDel(GVNAME_FIRST_BAR_TIME);
//----
  return(0);
}

//+------------------------------------------------------------------+
//|                   Indicator iteration function                   |
//+------------------------------------------------------------------+
int start()
{
//----
  GlobalVariableSet(GVNAME_BAR_COUNT, Bars);
  GlobalVariableSet(GVNAME_FIRST_BAR_TIME, Time[Bars-1]);
//----
  return(0);
}
//+------------------------------------------------------------------+