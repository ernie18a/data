//+------------------------------------------------------------------+
//|                                             MakeScreenshotTV.mq5 |
//|                                 Copyright 2026, Mykyta Samoiliuk |
//|                                                     www.mql5.com |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2026, Mykyta Samoiliuk"
#property link        "https://www.mql5.com"
#property version     "1.00"
#property description "Takes a Code Base compliant screenshot of SuperTrendTV:"
#property description "black and white candles on white, PNG, exactly 750x394."
#property script_show_inputs
//--- input parameters
input string          InpSymbol="XAUUSD";              // Symbol
input ENUM_TIMEFRAMES InpTimeframe=PERIOD_M5;          // Timeframe
input int             InpPeriod=10;                    // ATR period
input double          InpFactor=3.0;                   // Factor
input int             InpMinBars=110;                  // Bars to calculate before shooting
input string          InpFileName="supertrend_tv.png"; // File name
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- own chart, so the user's workspace stays untouched
   long chart=ChartOpen(InpSymbol,InpTimeframe);
   if(chart==0)
     {
      PrintFormat("Cannot open a chart for %s, error %d",InpSymbol,GetLastError());
      return;
     }
   Sleep(700);
//--- black on white, as the Code Base guidelines require, so the picture prints
   ChartSetInteger(chart,CHART_COLOR_BACKGROUND,clrWhite);
   ChartSetInteger(chart,CHART_COLOR_FOREGROUND,clrBlack);
   ChartSetInteger(chart,CHART_COLOR_GRID,clrWhite);
   ChartSetInteger(chart,CHART_COLOR_CANDLE_BULL,clrWhite);
   ChartSetInteger(chart,CHART_COLOR_CANDLE_BEAR,clrBlack);
   ChartSetInteger(chart,CHART_COLOR_CHART_UP,clrBlack);
   ChartSetInteger(chart,CHART_COLOR_CHART_DOWN,clrBlack);
   ChartSetInteger(chart,CHART_COLOR_CHART_LINE,clrBlack);
   ChartSetInteger(chart,CHART_COLOR_VOLUME,clrWhite);
   ChartSetInteger(chart,CHART_MODE,CHART_CANDLES);
   ChartSetInteger(chart,CHART_SHOW_GRID,false);
   ChartSetInteger(chart,CHART_SHOW_VOLUMES,CHART_VOLUME_HIDE);
   ChartSetInteger(chart,CHART_SHOW_PERIOD_SEP,false);
   ChartSetInteger(chart,CHART_SHOW_OBJECT_DESCR,false);
//--- price lines and trade levels are clutter, the guidelines ask for a clean figure
   ChartSetInteger(chart,CHART_SHOW_BID_LINE,false);
   ChartSetInteger(chart,CHART_SHOW_ASK_LINE,false);
   ChartSetInteger(chart,CHART_SHOW_LAST_LINE,false);
   ChartSetInteger(chart,CHART_SHOW_TRADE_LEVELS,false);
   ChartSetInteger(chart,CHART_SHOW_ONE_CLICK,false);
   ChartSetInteger(chart,CHART_AUTOSCROLL,true);
   ChartSetInteger(chart,CHART_SHIFT,false);
   ChartSetInteger(chart,CHART_SCALE,3);
//--- the indicator itself
   int handle=iCustom(InpSymbol,InpTimeframe,"SuperTrendTV",InpPeriod,InpFactor);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Cannot create SuperTrendTV, error %d",GetLastError());
      ChartClose(chart);
      return;
     }
   for(int attempt=0; attempt<100 && BarsCalculated(handle)<InpMinBars; attempt++)
      Sleep(50);

   if(!ChartIndicatorAdd(chart,0,handle))
     {
      PrintFormat("ChartIndicatorAdd failed, error %d",GetLastError());
      IndicatorRelease(handle);
      ChartClose(chart);
      return;
     }
//--- show a slice where the trend actually flips a few times
   ChartNavigate(chart,CHART_END,0);
   ChartRedraw(chart);
   Sleep(1500);
//--- 750x394 is the size the guidelines ask for, so no resizing afterwards
   if(ChartScreenShot(chart,InpFileName,750,394,ALIGN_RIGHT))
      PrintFormat("screenshot saved to MQL5\\Files\\%s",InpFileName);
   else
      PrintFormat("ChartScreenShot failed, error %d",GetLastError());

   Sleep(400);
   IndicatorRelease(handle);
   ChartClose(chart);
  }
//+------------------------------------------------------------------+
