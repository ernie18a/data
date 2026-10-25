//+------------------------------------------------------------------+
//|                                                      Version.mqh |
//|                             Copyright 2009-2017, Vasiliy Sokolov |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
/*
   HISTORY INFO
   Version 2.01 (2016.02.16):
      - Significantly increased the calculation speed of the indicator. In the previous version
        the operation slowdowns were observed on the smaller timeframes. 
      - Fixed indicator reset error after the terminal restarts. Now the restart of
        the terminal runs smoothly. 
      - Fixed the indicator operation in the strategy tester. Now the indicator is plotted
        dynamically in the visualization mode. 
      - Improved the indicator value update system. Now, if the reports are updated
        via CFTC Reports, the indicator automatically downloads the new values, and there will
        be no need to restart the indicator.
   Version 2.03 (2016.04.28):
      - Added new parameter: 'Release Day'. It takes two values: 'Release by Tuesday' - new values
        of the indicator appear every Tuesday, and 'Release by Friday' (default value), - new values
        of the indicator appear ever Friday.
      - Added new parameter: 'Data Type'. It allows to select the data source. At the value 
        'Contracts of Traders' the indicator downloads the information on the number of traders'
        contracts. At the value 'Number of Traders' the indicator downloads the information on
        the number of traders holding the corresponding position. 
      - Added an error message, displayed in the indicator window, if the data with the CFTC reports
        were not found or if 'MetaCOT CFTC Install Reports' is not installed. 
      - Fixed the indicator crash, which occurred when attempting to download a non-existing report. 
      - Now, the levels of threshold values of indicator can be modified in the "Levels" tab of
        the setting window.
   Version 2.04 (2016.05.18):
      - Normalized the indicator parameters. Now, the main parameters are at the top.
        Fine tuning and extra features parameters are at the bottom. These additional parameters
        form PROFESSIONAL SETTINGS group. 
      - Fixed internal array initialization. In previous versions, this sometimes caused errors hiding
        the indicators from a chart. 
      - Now, oscillators automatically scale within -10 to +110%. This helps to set up more correct view
        of the indicators right at the first start of the indicator since the lines do not cross the top
        and bottom window borders. 
      - Switched to classic display of the indicator levels. Now, it is possible to place them
        at arbitrary levels, as well as change their colors and line types.
   Version 2.12 (2017.04.04):
      - Fix wrong calculation of COT and Willco Indexies.
      - Fix wrong work in tester strategy.
      - Now all indicators and MetaCOT Toolbox have a common code base.
   Version 2.14 (2018.02.12):
      - Fix bag: in Saturday and Sunday in D1 timeframe and more, new CFTC dates
   Version 2.51 (2018.08.16)
      - Starting from this version, a new utility for downloading reports is available - MetaCOT Data Provider.
        This utility work as Win32 system tray appliacation and download CFTC reports in background mode. If you
        use this utility you can make auto update reports from MetaCOT indicators and don't use 'MetaCOT Install CFTC
        Reports'.
      - 'MetaCOT CFTC Install Reports' tool was upgraded. Now, it contain new help system. Its general window also was
        changed. Now this window contain information about status of connection, status of database (outdated or not) and
        status of MetaCOT Data Provider Win32 util (install or not). If this util avaliable 'MetaCOT CFTC Install Reports'
        load local files and parse it.
      - MetaCOT indicators and Toolbox Library began to contain inner COT data for the most basic symbols. This data can
        use if MetaCOT was't installed. This option is useful in the strategy tester if the installation was not performed.
      - All indicators began to contain system of update data (mini tool based on 'MetaCOT CFTC Install Reports').
        If you use MetaCOT Data Provider utility, you can update reports automatically and don't use 'MetaCOT Install CFTC
        Reports'. For this case you need switch on new parameter 'AutoUpdate' in position true.
      - Added parameter 'Not Show Continues Data'. If this flag is enable - last unknowing values is empty. Otherwise
        last unknowing values continues.
      - Added control for bad combination parameter. If you select nonreportable group of trades and also select Data Type
        as 'Number of Traders' you will see message 'Incorrect combination of parameters'.
      - Removed parameter 'Data Type' for Largest COT indicators group. This parameter not effect for largest traders. 
      - Fixed a bug in strategy tester. When any indiactors was started in strategy tester it's values was intermittent.
      - Fixed a bug that caused an error 'invalid pointer access' in some cases  
      - Now all MetaCOT indicators and ToolBox Library contain additional GUI forms and MessageBox for more user frendly.
        The work of indicators has become clearer.
*/

#define VERSION "2.12"                    // Current version of MetaCOT project
#define MC_LABEL ("MetaCOT " + VERSION)   // Label MetaCOT + Current version
#define METACOT_TOOLBOX                   // Using MetaCOT ToolBox assembly (always defined)
//+------------------------------------------------------------------+
//| Full version of MetaCOT 2                                        |
//+------------------------------------------------------------------+
double Version(void)
{
   double ver = StringToDouble(VERSION);
   return ver;
}