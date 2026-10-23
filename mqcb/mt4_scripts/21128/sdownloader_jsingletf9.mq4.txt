//+------------------------------------------------------------------+
//|                                      s-Downloader (SingleTF).mq4 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description "The script downloads the historical quotes data of the current chart symbol and timeframe."
#property description "This is convenient to conduct more backtesting on a single TF that you usually work with."
#property description " "
#property description "How to use:"
#property description "- Launch the script on the target symbol and timeframe to download its historical data."
#property description "- When terminal is restarted later, historical data are automatically flushed to disk."
#property strict
#property script_show_inputs
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

   DownloadHomeKey();
  }
//+------------------------------------------------------------------------------+
//| DownloadHomeKey()                                                            |
//| Purpose:                                                                     |
//|    Download historical data for the current chart symbol and TF              |
//+------------------------------------------------------------------------------+
void DownloadHomeKey()
  {
   long max_bars,init_bars,bars=0;
   datetime first_date,server_first_date;
   string strTF=StringSubstr(EnumToString((ENUM_TIMEFRAMES)_Period),7);

//--- max bars in chart from terminal options
   max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);

//--- load symbol history info
   init_bars=SeriesInfoInteger(_Symbol,_Period,SERIES_BARS_COUNT);
   first_date=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_FIRSTDATE);
   server_first_date=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_SERVER_FIRSTDATE);

//--- output found dates to terminal log
   Print("first date on server=",server_first_date);
   Print("first date on chart=",first_date);

//--- ask for first date
   if(first_date>0 && first_date<=server_first_date)
     {
      Alert(StringFormat("history for '%s,%s' is up to date.",_Symbol,strTF));
      return;
     }

//+------------------------------------------------------------------+
//| https://docs.mql4.com/constants/chartconstants/charts_samples    |
//+------------------------------------------------------------------+
   ChartNavigate(0,CHART_END,0);
   ChartSetInteger(0,CHART_SCALE,0); // zoom out to zero
   ChartSetInteger(0,CHART_AUTOSCROLL,false); // disable scrolling

   string status_msg="";

   while(!IsStopped())
     {
      //--- check if data are present
      //		bars = iBars(_Symbol, _Period);
      bars=SeriesInfoInteger(_Symbol,_Period,SERIES_BARS_COUNT);
      if(bars>0)
        {
         //--- ask for first date
         first_date=(datetime)SeriesInfoInteger(_Symbol,_Period,SERIES_FIRSTDATE);
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
      ChartNavigate(0,CHART_CURRENT_POS,-100000);
      ChartNavigate(0,CHART_CURRENT_POS,-10000);
      ChartNavigate(0,CHART_CURRENT_POS,-1000);
      ChartNavigate(0,CHART_CURRENT_POS,-100);
      ChartNavigate(0,CHART_CURRENT_POS,-10);
      ChartNavigate(0,CHART_CURRENT_POS,-1);
      Sleep(10);
     }

   Alert(_Symbol,",",strTF,": first date on chart=",first_date,", downloaded ",bars-init_bars," bars",status_msg);
  }
//+------------------------------------------------------------------+
