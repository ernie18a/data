//+------------------------------------------------------------------+
//|                           MetaCOT2 SaveIndicatorValuesInFile.mq5 |
//|                                 Copyright 2017, Vasiliy Sokolov. |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property copyright "MetaCOT® 2009-2017, Vasiliy Sokolov, St.-Petersburg, Russia"
#property link      "https://www.mql5.com/en/articles/1573"
#include <MetaCOT\Version.mqh>
#property version   VERSION
#property script_show_inputs
#property icon "\\Images\\MetaCOT\\MetaCOT_ToolBox.ico"
#property description "MetaCOT 2 is designed for analize CFTC reports, data mining and for fundamental analysis."
#property description "See article 'MetaCOT Project - New horizons for CFTC report analysis in MetaTrader 4'"
#property description "\nFor work this script need download and install 'MetaCOT -  Install CFTC reports' tool."
#include <MetaCOT\Enums.mqh>
#include <MetaCOT\ToolBox.mqh>
CftcReportInfo             ReportInfo;
input ENUM_CFTC_INDICATORS IndType;                               // Type of CFTC Indicator
input bool                 AdddPriceColumn = true;                // Add Price Column
input int                  IPeriod = 52;                          // Period (if used)
input int                  MovPeriod = 6;                         // Movement period (if used)
input ENUM_MOVMENT_TYPE    MovType;                               // Type of Mov.Index (if used)
input string               CsvDel = ";";                          // CSV Delimeter
input string               ProffSettings = "";                    // #      PROFESSIONAL SETTINGS:    #
input ENUM_COT_SOURCE      Source = FUTURES_AND_OPTIONS;          // Source of Report
input ENUM_COT_RELEASE_DAY ReleaseDay = COT_RELEASE_FRIDAY;       // Release Day
input ENUM_COT_DATA_TYPE   DateType = COT_DATA_FUTURES;           // Data Type
input ENUM_COT_SUBGROUP    SubGroup = COT_SUBGROUP_ALL;           // Subgroup of Traders
input bool                 AutoDetectReport = true;               // Auto Detect Report Name
input string               LoadReportName =                                
                           "WHEAT-SRW - CHICAGO BOARD OF TRADE";  // Report Name (If Auto Detect=false)
CotBaseSettings            CftcSet;
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{ 
   ENUM_CFTC_REPORT report_type = GetCftcReportFromInd(IndType);
   if(!AutoDetectReport || !GetCftcReportInfo(Symbol(), report_type, ReportInfo))
   {
      ReportInfo.reverse = false;
      ReportInfo.report_name = LoadReportName;
      ReportInfo.short_name = LoadReportName;
   }
   CftcIndParams params;
   params.ind_type = IndType;
   params.period = IPeriod;
   params.mov_period = MovPeriod;
   params.mov_type = MovType;
   CftcSet.source = Source;
   CftcSet.subgroup = SubGroup;
   CftcSet.report_name = ReportInfo.report_name;
   CftcSet.date_type = DateType;
   CftcSet.release_day = ReleaseDay;
   int group_total = GetCftcTotalGroupsOfInd(IndType);
   string lines[];
   
   for(int i = 0; i < group_total; i++)
   {
      params.group_traders = i;
      datetime times[];
      double values[];
      GetCftcValuesByIndType(CftcSet, params, times, values);
      if(ArraySize(lines)==0)
         ArrayResize(lines, ArraySize(times)+1);
      if(i == 0)
      {
         lines[0] = "Date"+CsvDel;
         AddTimes(lines, times);
         if(AdddPriceColumn)
         {
            lines[0] += "Price"+CsvDel;
            AddPrices(lines, times);
         }
      }
      lines[0] += params.name_group_traders + CsvDel;
      AddValues(lines, values);
   }
   SaveToFile(lines);
}
//+------------------------------------------------------------------+
//| Save to file lines                                               |
//+------------------------------------------------------------------+
void SaveToFile(string& lines[])
{
   string date = TimeToString(TimeCurrent(), TIME_DATE);
   string fn = "MetaCOT\\CsvReport\\" + date + " - " + ReportInfo.report_name + " - " + CotIndToString(IndType) + ".csv";
   int h = FileOpen(fn, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(h == INVALID_HANDLE)
   {
      printf("Failed open file " + fn + " Check permission.");
      return;
   }
   for(int i = 0; i < ArraySize(lines); i++)
      FileWriteString(h, lines[i] + "\n");
   FileClose(h);
}
//+------------------------------------------------------------------+
//| Add times in csv report                                          |
//+------------------------------------------------------------------+
void AddTimes(string& lines[], datetime& times[])
{
   for(int i = 0; i < ArraySize(times); i++)
      lines[i+1] = TimeToString(times[i], TIME_DATE)+CsvDel;
}

void AddPrices(string& lines[], datetime& times[])
{
   for(int i = 0; i < ArraySize(times); i++)
   {
      int index = iBarShift(Symbol(), PERIOD_W1, times[i], true);
      if(index != -1)
      {
         double close = iClose(Symbol(), PERIOD_W1,index);
         lines[i+1] += DoubleToString(close, Digits()) + CsvDel;
      }
      else
         lines[i+1] += CsvDel;
   }
}
//+------------------------------------------------------------------+
//| Add values in csv report                                         |
//+------------------------------------------------------------------+
void AddValues(string& lines[], double& values[])
{
   for(int i = 0; i < ArraySize(values); i++)
   {
      if(values[i] == EMPTY_VALUE)
         lines[i+1] += ""+CsvDel;
      else
         lines[i+1] += (DoubleToString(values[i], 1)+CsvDel);
   }
}
//+------------------------------------------------------------------+
//| Convert type indicator to name                                   |
//+------------------------------------------------------------------+
string CotIndToString(ENUM_CFTC_INDICATORS ind_type)
{
   string sname = EnumToString(ind_type);
   sname = StringSubstr(sname, 9);
   StringReplace(sname, "_", " ");
   return sname;
}

//+------------------------------------------------------------------+
