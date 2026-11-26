//+------------------------------------------------------------------+
//|                          s-Downloader (SingleTF, AllSymbols).mq4 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description "The script downloads the historical quotes data of a single timeframe for all symbols in the market watch."
#property strict
#property script_show_inputs

input ENUM_TIMEFRAMES InpTimeFrame=PERIOD_M5; // Timeframe for all markwatch symbols
//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
void start()
  {
   if(TerminalInfoInteger(TERMINAL_CONNECTED)==false)
     {
      Alert("Error: no connection to the trade server.");
      return;
     }

   uint btime=GetTickCount();

   string symbol;
   int nSymbols=SymbolsTotal(true);
   for(int i=0; i<nSymbols && !IsStopped(); i++)
     {
      symbol=SymbolName(i,true);
      DownloadHistoryQuotes(symbol,InpTimeFrame);
     }

   Alert("download history for all symbols ",EnumToString(InpTimeFrame)," took ",(GetTickCount()-btime)/1000," seconds");
  }
//+------------------------------------------------------------------------------+
//| DownloadHistoryQuotes()                                                      |
//| Purpose:                                                                     |
//|    Download historical data for the specified symbol and timeframe           |
//+------------------------------------------------------------------------------+
void DownloadHistoryQuotes(string symbol,ENUM_TIMEFRAMES timeframe)
  {
//--- open chart for symbol & period
   long chartId=ChartOpen(symbol,timeframe);
   if(chartId==0)
     {
      Alert(symbol," ",EnumToString(timeframe)," chart didn't open, error: ",GetLastError());
      return;
     }
   Sleep(1000);
   ChartNavigate(chartId,CHART_END,0);
   ChartSetInteger(chartId,CHART_SCALE,0); // zoom out to zero
   ChartSetInteger(chartId,CHART_AUTOSCROLL,false); // disable scrolling

   long max_bars,init_bars,bars=0;
   datetime first_date,server_first_date;
   string strTF=StringSubstr(EnumToString(timeframe),7);

//--- max bars in chart from terminal options
   max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);

//--- load symbol history info
   init_bars=SeriesInfoInteger(symbol,timeframe,SERIES_BARS_COUNT);
   first_date=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_FIRSTDATE);
   server_first_date=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_SERVER_FIRSTDATE);

//--- output found dates to terminal log
   PrintFormat("------------------- %s,%s -------------------",symbol,strTF);
   Print("first date on server=",server_first_date);
   Print("first date on chart=",first_date);

//--- ask for first date
   if(first_date>0 && first_date<=server_first_date)
     {
      PrintFormat("History for '%s,%s' is up to date.",symbol,strTF);
      ChartClose(chartId);
      return;
     }

   PrintFormat("downloading history for '%s,%s'",symbol,strTF);

   string status_msg="";

   while(!IsStopped())
     {
      //--- check if data are present
      //		bars = iBars(symbol, timeframe);
      bars=SeriesInfoInteger(symbol,timeframe,SERIES_BARS_COUNT);
      if(bars>0)
        {
         //--- ask for first date
         first_date=(datetime)SeriesInfoInteger(symbol,timeframe,SERIES_FIRSTDATE);
         if(first_date>0 && first_date<=server_first_date)
           {
            status_msg=" (all server data is synchronized successfully)";
            break;
           }
         //--- check for max bars
         if(bars>=max_bars)
           {
            status_msg=" (Hint: Options -> Chart -> increase 'Max bars in chart', and restart terminal)";
            break;
           }
        }

      //--- data are not present, force data download
      ChartNavigate(chartId,CHART_CURRENT_POS,-100000);
      ChartNavigate(chartId,CHART_CURRENT_POS,-10000);
      ChartNavigate(chartId,CHART_CURRENT_POS,-1000);
      ChartNavigate(chartId,CHART_CURRENT_POS,-100);
      ChartNavigate(chartId,CHART_CURRENT_POS,-10);
      ChartNavigate(chartId,CHART_CURRENT_POS,-1);
      Sleep(10);
     }

   Sleep(200);
   ChartClose(chartId);

   Print(bars-init_bars," bars downloaded",status_msg);
  }
//+------------------------------------------------------------------+
