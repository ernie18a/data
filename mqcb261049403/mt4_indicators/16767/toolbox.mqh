//+------------------------------------------------------------------+
//|                                       MetaCOT 2 CFTC ToolBox.mqh |
//|                                  Copyright 2018, Vasiliy Sokolov |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
#property strict
#include <MetaCOT\Enums.mqh>

//+------------------------------------------------------------------+
//| Cot base settings. This setting select COT report and config     |
//| it's subgroups types.                                            |
//+------------------------------------------------------------------+
struct CotBaseSettings
{
   string               report_name;         // Set name of COT report if you want set specific report.
   ENUM_COT_SOURCE      source;              // Source of report (Futures or Futures and Options)
   ENUM_COT_SUBGROUP    subgroup;            // Subgroup of traders (All, Old, Other)
   ENUM_COT_DATA_TYPE   date_type;           // You may set 'count of futures' or 'count of traders'
   ENUM_COT_RELEASE_DAY release_day;         // Release report by Friday or Monday
   CotBaseSettings(void); 
};
//+------------------------------------------------------------------+
//| This structure config by default for showing standard settings   |
//+------------------------------------------------------------------+
CotBaseSettings::CotBaseSettings(void)
{
   report_name = "# BRITISH POUND STERLING - CONCATENATE";
   source = FUTURES_AND_OPTIONS;
   subgroup = COT_SUBGROUP_ALL;
   date_type = COT_DATA_FUTURES;
   release_day = COT_RELEASE_FRIDAY;
}
//+------------------------------------------------------------------+
//| Report info struct                                               |
//+------------------------------------------------------------------+
struct CftcReportInfo
{
   bool reverse;           // True if instrument is the reverse rate futures
   string report_name;     // Report name
   string short_name;      // Short report name
};

#ifdef METACOT_TOOLBOX
//+------------------------------------------------------------------+
//| This function will be import from MetaCOT 2 ToolBox library      |
//+------------------------------------------------------------------+
#ifdef __MQL5__
   #ifdef METACOT_DEMO
      #import "..\\Scripts\\Market\\MetaCOT 2 CFTC ToolBox Demo MT5.ex5"
   #else
      #import "..\\Scripts\\Market\\MetaCOT 2 CFTC ToolBox MT5.ex5"
   #endif
#else
   #ifdef METACOT_DEMO
      #import "..\\Scripts\\Market\\MetaCOT 2 CFTC ToolBox Demo MT4.ex4"
   #else
      #import "..\\Scripts\\Market\\MetaCOT 2 CFTC ToolBox MT4.ex4"
   #endif
#endif
//+------------------------------------------------------------------+
//| Returns CFTC report info by symbol                               |
//| symbol - work symbol.                                            |
//| type - type of CFTC report                                       |
//| struct with info about report                                    |
//| Return true, if report was success find, otherwise false         |
//+------------------------------------------------------------------+
bool  GetCftcReportInfo(string symbol, ENUM_CFTC_REPORT report_type, CftcReportInfo& info);
//+------------------------------------------------------------------+
//| Get Absolute Values of COT report                                |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool  GetCotAbsoluteValues(CotBaseSettings& settings, ENUM_COT_GROUP group, datetime& times[], double& values[]);
//+------------------------------------------------------------------+
//| Get largest values of COT report                                 |
//| settings - base settings of cftc report                          |
//| group - group of largest trades                                  |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCotLargestValues(CotBaseSettings& settings, ENUM_LCOT_GROUP group, datetime& times[], double& values[]);
//+------------------------------------------------------------------+
//| Get absolute values of Disaggregated COT report                  |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetDCotAbsoluteValues(CotBaseSettings& settings, ENUM_DCOT_GROUP group, datetime& times[], double& values[]);
//+------------------------------------------------------------------+
//| Get absolute values of TFF reports                               |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetTffAbsoluteValues(CotBaseSettings& settings, ENUM_TFF_GROUP group, datetime& times[], double& values[]);
//+------------------------------------------------------------------+
//| Get absolute values of CIT reports                               |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCitAbsoluteValues(CotBaseSettings& settings, ENUM_CIT_GROUP group, datetime& times[], double& values[]);
//+------------------------------------------------------------------+
//| This function make auto update of CFTC reports. Its need call    |
//| from OnTimer(). It work if you use MetaCOT DataProvider win32    |
//| utility for Widows.                                              |
//+------------------------------------------------------------------+
void UpdateReportsByTimer(void);
//+------------------------------------------------------------------+
//| This function send chart event to toolbox library. It need using |
//| for user panel and dialog window of MetaCOT. The parameters of   | 
//| this function are similar of system OnChartEvent().              |
//+------------------------------------------------------------------+
void SendOnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam);
//+------------------------------------------------------------------+
//| This function need run in system OnInit function. It using for   |
//| inner initialization parameters and variables of MetaCOT library.|
//+------------------------------------------------------------------+
int SendOnInit(void);
#import
#else
#ifdef __MQL5__
   #include <..\\Experts\\MetaCOT\\MetaCOT 2 CFTC ToolBox MT5.mq5>
#else
   #include <..\\Experts\\MetaCOT\\MetaCOT 2 CFTC ToolBox MT4.mq4>
#endif
//
#endif
//+------------------------------------------------------------------+
//| Convert  ENUM_COT_NETTO_GROUP to ENUM_COT_GROUP long and         |
//| short type.                                                      |
//+------------------------------------------------------------------+
void GetCotFromNetto(ENUM_COT_NETTO_GROUP ngroup, ENUM_COT_GROUP& lgroup, ENUM_COT_GROUP& sgroup)
{
   switch(ngroup)
   {
      case COT_NETTO_NCOMM:
         lgroup = COT_GROUP_NONCOMM_LONG;
         sgroup = COT_GROUP_NONCOMM_SHORT;
         break;
      case COT_NETTO_OPERATORS:
         lgroup = COT_GROUP_OPERATORS_LONG;
         sgroup = COT_GROUP_OPERATORS_SHORT;
         break;
      case COT_NETTO_NONREPORTABLE:
         lgroup = COT_GROUP_NONREP_LONG;
         sgroup = COT_GROUP_NONREP_SHORT;
         break;
   }
}
//+------------------------------------------------------------------+
//| Calculate COT index on double array 'src_values'                 |
//| period - Period of COT Index                                     |
//| src_values - Source double values                                |
//| ind_values - Values of COT Index                                 |
//+------------------------------------------------------------------+
bool GetIndexValues(int period, double& src_values[], double& ind_values[])
{
   double max, min, index, curr;
   int imax, imin, total = ArraySize(src_values);
   ArrayResize(ind_values, ArraySize(src_values)); 
   ArrayInitialize(ind_values, EMPTY_VALUE);
   for(int i = period-1; i < total; i++)
   {
      #ifdef __MQL5__
      imax = ArrayMaximum(src_values, i-period+1, period);
      imin = ArrayMinimum(src_values, i-period+1, period);
      #else
      imax = ArrayMaximum(src_values, period, i-period+1);
      imin = ArrayMinimum(src_values, period, i-period+1);
      #endif
      max = src_values[imax];
      min = src_values[imin];
      curr = src_values[i];
      if(max-min != 0.0)
         index = ((curr-min)/(max-min))*100.0;
      else
         index = 100.0;
      ind_values[i] = index;
   }
   return ArraySize(ind_values)>0;  
}
//+------------------------------------------------------------------+
//| Get ratio values for willco indicator                            |
//+------------------------------------------------------------------+
bool GetRatioValues(double& netto_values[], double& oi_values[], double& ratio_values[])
{
   ArrayResize(ratio_values, ArraySize(oi_values));
   for(int i = 0; i < ArraySize(ratio_values); i++)
   {
      if(oi_values[i] != 0.0)
         ratio_values[i] = netto_values[i] / oi_values[i];
      else
         ratio_values[i] = 1.0;
   }
   return ArraySize(ratio_values) > 0; 
}
//+------------------------------------------------------------------+
//| Get Diff values from src_values                                  |
//+------------------------------------------------------------------+
bool GetDiffValues(double& src_values[], double& diff_values[], ENUM_DIFF_TYPE diff_type = DIFF_ABS, int diff_lag=1)
{
   ArrayResize(diff_values, ArraySize(src_values));
   ArrayInitialize(diff_values, EMPTY_VALUE);
   for(int i = diff_lag; i < ArraySize(src_values); i++)
   {
      double delta = src_values[i] - src_values[i-diff_lag];
      if(diff_type == DIFF_PERCENT)
      {
         if(src_values[i-diff_lag] != 0.0)
            delta = delta/src_values[i-diff_lag]*100.0;
      }
      diff_values[i] = delta;
   }  
   return ArraySize(diff_values)>0;
}
//+------------------------------------------------------------------+
//| Get netto values group of traders                                |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCotNettoValues(CotBaseSettings& settings, ENUM_COT_NETTO_GROUP group, datetime& times[], double& values[])
{
   if(group == COT_NETTO_OI)
      return GetCotAbsoluteValues(settings, COT_GROUP_OI, times, values);
   ENUM_COT_GROUP long_group = COT_GROUP_OI;
   ENUM_COT_GROUP short_group = COT_GROUP_OI;
   GetCotFromNetto(group, long_group, short_group);
   double long_values[];
   double short_values[];
   GetCotAbsoluteValues(settings, long_group, times, long_values);
   GetCotAbsoluteValues(settings, short_group, times, short_values);
   ArrayResize(values, ArraySize(long_values));
   for(int i = 0; i < ArraySize(long_values); i++)
      values[i] = long_values[i]-short_values[i];   
   return ArraySize(values) > 0;
}
//+------------------------------------------------------------------+
//| Get COT-Index values of COT report                               |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCotIndexValues(CotBaseSettings& settings, int period, ENUM_COT_NETTO_GROUP group, datetime& times[], double& values[])
{
   // Get net positions from one of groups of traders
   double netto_values[];
   if(!GetCotNettoValues(settings, group, times, netto_values))
      return false;
   // Calculate universal COT-Index on clear positions
   return GetIndexValues(period, netto_values, values);
}
//+------------------------------------------------------------------+
//| Get Willco-Index values of COT report                            |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCotWillcoValues(CotBaseSettings& settings, int period, ENUM_COT_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   double oi_values[];
   if(!GetCotNettoValues(settings, group, times, netto_values))
      return false;
   if(!GetCotAbsoluteValues(settings, COT_GROUP_OI, times, oi_values))
      return false;
   double ratio_values[];
   GetRatioValues(netto_values, oi_values, ratio_values);
   return GetIndexValues(period, ratio_values, values);
}
//+------------------------------------------------------------------+
//| Get netto values of Disaggregated COT report                     |
//| settings - base settings of cftc report                          |
//| group - group of netto trades                                    |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetDCotNettoValues(CotBaseSettings& settings, ENUM_DCOT_NETTO_GROUP group, datetime& times[], double& values[])
{
   if(group == DCOT_NETTO_OI)
      return GetDCotAbsoluteValues(settings, DCOT_GROUP_OI, times, values);
   ENUM_DCOT_GROUP long_group = DCOT_GROUP_OI;
   ENUM_DCOT_GROUP short_group = DCOT_GROUP_OI;
   GetDCotFromNetto(group, long_group, short_group);
   double long_values[];
   double short_values[];
   GetDCotAbsoluteValues(settings, long_group, times, long_values);
   GetDCotAbsoluteValues(settings, short_group, times, short_values);
   ArrayResize(values, ArraySize(long_values));
   for(int i = 0; i < ArraySize(long_values); i++)
      values[i] = long_values[i]-short_values[i];   
   return ArraySize(values) > 0;
}
//+------------------------------------------------------------------+
//| Get values of DCOT index                                         |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
 bool GetDCotIndexValues(CotBaseSettings& settings, int period, ENUM_DCOT_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   if(!GetDCotNettoValues(settings, group, times, netto_values))
      return false;
   return GetIndexValues(period, netto_values, values);
}
//+------------------------------------------------------------------+
//| Get Willco values                                                |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetDCotWillcoValues(CotBaseSettings& settings, int period, ENUM_DCOT_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   double oi_values[];
   if(!GetDCotNettoValues(settings, group, times, netto_values))
      return false;
   if(!GetDCotAbsoluteValues(settings, DCOT_GROUP_OI, times, oi_values))
      return false;
   double ratio_values[];
   GetRatioValues(netto_values, oi_values, ratio_values);
   return GetIndexValues(period, netto_values, values);
}
//+------------------------------------------------------------------+
//| Convert  ENUM_DCOT_NETTO_GROUP to ENUM_DCOT_GROUP long and       |
//| short type.                                                      |
//+------------------------------------------------------------------+
void GetDCotFromNetto(ENUM_DCOT_NETTO_GROUP ngroup, ENUM_DCOT_GROUP& lgroup, ENUM_DCOT_GROUP& sgroup)
{
   switch(ngroup)
   {
      case DCOT_NETTO_DEALERS:
         lgroup = DCOT_GROUP_DEALERS_LONG;
         sgroup = DCOT_GROUP_DEALERS_SHORT;
         break;
      case DCOT_NETTO_MANAGED:
         lgroup = DCOT_GROUP_MANAGED_LONG;
         sgroup = DCOT_GROUP_MANAGED_SHORT;
         break;
      case DCOT_NETTO_NONREP:
         lgroup = DCOT_GROUP_NONREP_LONG;
         sgroup = DCOT_GROUP_NONREP_SHORT;
         break;
      case DCOT_NETTO_PRODUCER:
         lgroup = DCOT_GROUP_PRODUCER_LONG;
         sgroup = DCOT_GROUP_PRODUCER_SHORT;
         break;
      case DCOT_NETTO_TOTAL:
         lgroup = DCOT_GROUP_TOTAL_LONG;
         sgroup = DCOT_GROUP_TOTAL_SHORT;
         break;
      case DCOT_NETTO_REPORTABLE:
         lgroup = DCOT_GROUP_REPORTABLE_LONG;
         sgroup = DCOT_GROUP_REPORTABLE_SHORT;
         break;
   }
}
//+------------------------------------------------------------------+
//| Get nett values group of traders                                 |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetTffNettoValues(CotBaseSettings& settings, ENUM_TFF_NETTO_GROUP group, datetime& times[], double& values[])
{
   if(group == TFF_NETTO_OI)
      return GetTffAbsoluteValues(settings, TFF_GROUP_OI, times, values);
   ENUM_TFF_GROUP long_group = TFF_GROUP_OI;
   ENUM_TFF_GROUP short_group = TFF_GROUP_OI;
   GetTffFromNetto(group, long_group, short_group);
   double long_values[];
   double short_values[];
   GetTffAbsoluteValues(settings, long_group, times, long_values);
   GetTffAbsoluteValues(settings, short_group, times, short_values);
   ArrayResize(values, ArraySize(long_values));
   for(int i = 0; i < ArraySize(long_values); i++)
      values[i] = long_values[i]-short_values[i];   
   return ArraySize(values) > 0;
}
//+------------------------------------------------------------------+
//| Convert  ENUM_TFF_NETTO_GROUP to ENUM_TFF_GROUP long and         |
//| short type.                                                      |
//+------------------------------------------------------------------+
void GetTffFromNetto(ENUM_TFF_NETTO_GROUP ngroup, ENUM_TFF_GROUP& lgroup, ENUM_TFF_GROUP& sgroup)
{
   switch(ngroup)
   {
      case TFF_NETTO_DEALERS:
         lgroup = TFF_GROUP_DEALERS_LONG;
         sgroup = TFF_GROUP_DEALERS_SHORT;
         break;
      case TFF_NETTO_INSTITUTIONAL:
         lgroup = TFF_GROUP_INSTITUTIONAL_LONG;
         sgroup = TFF_GROUP_INSTITUTIONAL_SHORT;
         break;
      case TFF_NETTO_LEVERAGE:
         lgroup = TFF_GROUP_LEVERAGE_LONG;
         sgroup = TFF_GROUP_LEVERAGE_SHORT;
         break;
      case TFF_NETTO_REPORTABLE:
         lgroup = TFF_GROUP_OTHER_REP_LONG;
         sgroup = TFF_GROUP_OTHER_REP_SHORT;
         break;
      case TFF_NETTO_NONREPORT:
         lgroup = TFF_GROUP_NONREP_LONG;
         sgroup = TFF_GROUP_NONREP_SHORT;
         break;
   }
}
//+------------------------------------------------------------------+
//| Get TFF-Index values of TFF report                               |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetTffIndexValues(CotBaseSettings& settings, int period, ENUM_TFF_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   if(!GetTffNettoValues(settings, group, times, netto_values))
      return false;
   return GetIndexValues(period, netto_values, values);
}
//+------------------------------------------------------------------+
//| Get TFF-Willco values of TFF report                              |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetTffWillcoValues(CotBaseSettings& settings, int period, ENUM_TFF_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   double oi_values[];
   if(!GetTffNettoValues(settings, group, times, netto_values))
      return false;
   if(!GetTffAbsoluteValues(settings, TFF_GROUP_OI, times, oi_values))
      return false;
   double ratio_values[];
   GetRatioValues(netto_values, oi_values, ratio_values);
   return GetIndexValues(period, netto_values, values);
}
//+------------------------------------------------------------------+
//| Get nett values group of traders                                 |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCitNettoValues(CotBaseSettings& settings, ENUM_CIT_NETTO_GROUP group, datetime& times[], double& values[])
{
   if(group == CIT_NETTO_OI)
      return GetCitAbsoluteValues(settings, CIT_GROUP_OI, times, values);
   ENUM_CIT_GROUP long_group = CIT_GROUP_OI;
   ENUM_CIT_GROUP short_group = CIT_GROUP_OI;
   GetCitFromNetto(group, long_group, short_group);
   double long_values[];
   double short_values[];
   GetCitAbsoluteValues(settings, long_group, times, long_values);
   GetCitAbsoluteValues(settings, short_group, times, short_values);
   ArrayResize(values, ArraySize(long_values));
   for(int i = 0; i < ArraySize(long_values); i++)
      values[i] = long_values[i]-short_values[i];   
   return ArraySize(values) > 0;
}
//+------------------------------------------------------------------+
//| Convert  ENUM_TFF_NETTO_GROUP to ENUM_TFF_GROUP long and         |
//| short type.                                                      |
//+------------------------------------------------------------------+
void GetCitFromNetto(ENUM_CIT_NETTO_GROUP ngroup, ENUM_CIT_GROUP& lgroup, ENUM_CIT_GROUP& sgroup)
{
   switch(ngroup)
   {
      case CIT_NETTO_NONCOMM:
         lgroup = CIT_GROUP_NONCOMM_LONG;
         sgroup = CIT_GROUP_NONCOMM_SHORT;
         break;
      case CIT_NETTO_NONREP:
         lgroup = CIT_GROUP_NONREP_LONG;
         sgroup = CIT_GROUP_NONREP_SHORT;
         break;
      case CIT_NETTO_ALL:
         lgroup = CIT_GROUP_ALL_LONG;
         sgroup = CIT_GROUP_ALL_SHORT;
         break;
      case CIT_NETTO_OPERATORS:
         lgroup = CIT_GROUP_OPERATORS_LONG;
         sgroup = CIT_GROUP_OPERATORS_SHORT;
         break;
      case CIT_NETTO_REPORTABLE:
         lgroup = CIT_GROUP_REP_LONG;
         sgroup = CIT_GROUP_REP_SHORT;
         break;
   }
}
//+------------------------------------------------------------------+
//| Get CIT-Index values of TFF report                               |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCitIndexValues(CotBaseSettings& settings, int period, ENUM_CIT_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   if(!GetCitNettoValues(settings, group, times, netto_values))
      return false;
   return GetIndexValues(period, netto_values, values);
}

//+------------------------------------------------------------------+
//| Get TFF-Willco values of TFF report                              |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetCitWillcoValues(CotBaseSettings& settings, int period, ENUM_CIT_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   double oi_values[];
   if(!GetCitNettoValues(settings, group, times, netto_values))
      return false;
   if(!GetCitAbsoluteValues(settings, CIT_GROUP_OI, times, oi_values))
      return false;
   double ratio_values[];
   GetRatioValues(netto_values, oi_values, ratio_values);
   return GetIndexValues(period, ratio_values, values);
}
//+------------------------------------------------------------------+
//| Convert  ENUM_TFF_NETTO_GROUP to ENUM_TFF_GROUP long and         |
//| short type.                                                      |
//+------------------------------------------------------------------+
void GetLCotFromNetto(ENUM_LCOT_NETTO_GROUP ngroup, ENUM_LCOT_GROUP& lgroup, ENUM_LCOT_GROUP& sgroup)
{
   switch(ngroup)
   {
      case LCOT_NETTO_4:
         lgroup = LCOT_GROSS_LONG_4;
         sgroup = LCOT_GROSS_SHORT_4;
         break;
      case LCOT_NETTO_8:
         lgroup = LCOT_GROSS_LONG_8;
         sgroup = LCOT_GROSS_SHORT_8;
         break;
      case LCOT_NETTO_NET_4:
         lgroup = LCOT_NET_LONG_4;
         sgroup = LCOT_NET_SHORT_4;
         break;
      case LCOT_NETTO_NET_8:
         lgroup = LCOT_NET_LONG_8;
         sgroup = LCOT_NET_SHORT_8;
         break;
   }
}
//+------------------------------------------------------------------+
//| Get COT nett  largest traders                                    |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetLCotNettoValues(CotBaseSettings& settings, ENUM_LCOT_NETTO_GROUP group, datetime& times[], double& values[])
{
   ENUM_LCOT_GROUP long_group = LCOT_GROSS_LONG_4;
   ENUM_LCOT_GROUP short_group = LCOT_GROSS_SHORT_4;
   GetLCotFromNetto(group, long_group, short_group);
   double long_values[];
   double short_values[];
   GetCotLargestValues(settings, long_group, times, long_values);
   GetCotLargestValues(settings, short_group, times, short_values);
   ArrayResize(values, ArraySize(long_values));
   for(int i = 0; i < ArraySize(long_values); i++)
      values[i] = long_values[i]-short_values[i];   
   return ArraySize(values) > 0;
}
//+------------------------------------------------------------------+
//| Get Largest COT-Index values of TFF report                       |
//| settings - base settings of cftc report                          |
//| group - group of trades                                          |
//| times - time values of data                                      |
//| values - group values                                            |
//+------------------------------------------------------------------+
bool GetLCotIndexValues(CotBaseSettings& settings, int period, ENUM_LCOT_NETTO_GROUP group, datetime& times[], double& values[])
{
   double netto_values[];
   if(!GetLCotNettoValues(settings, group, times, netto_values))
      return false;
   return GetIndexValues(period, netto_values, values);
}
//+------------------------------------------------------------------+
//| Return total group of indicator 'ind_type'                       |
//+------------------------------------------------------------------+
int GetCftcTotalGroupsOfInd(ENUM_CFTC_INDICATORS ind_type)
{
   switch(ind_type)
   {
      case CFTC_IND_COT_ABS_POS:
      case CFTC_IND_COT_ABS_CHANGES:
         return COT_GROUP_TOTAL;
      case CFTC_IND_COT_NETTO_POS:
      case CFTC_IND_COT_NETTO_CHANGES:
      case CFTC_IND_COT_INDEX:
      case CFTC_IND_COT_MOV_INDEX:
      case CFTC_IND_COT_WILLCO_INDEX:
         return COT_NETTO_TOTAL;
      case CFTC_IND_DCOT_ABS_POS:
      case CFTC_IND_DCOT_ABS_CHANGES:
         return DCOT_GROUP_TOTAL;
      case CFTC_IND_DCOT_NETTO_POS:
      case CFTC_IND_DCOT_NETTO_CHANGES:
      case CFTC_IND_DCOT_INDEX:
      case CFTC_IND_DCOT_WILLCO:
      case CFTC_IND_DCOT_MOV_INDEX:
         return DCOT_NETTO_GROUP_TOTAL;
      case CFTC_IND_TFF_ABS_POS:
      case CFTC_IND_TFF_ABS_CHANGES:
         return TFF_GROUP_TOTAL;
      case CFTC_IND_TFF_NETTO_POS:
      case CFTC_IND_TFF_NETTO_CHANGES:
      case CFTC_IND_TFF_INDEX:
      case CFTC_IND_TFF_MOV_INDEX:
      case CFTC_IND_TFF_WILLCO:
         return TFF_NETTO_TOTAL;
      case CFTC_IND_CIT_ABS_POS:
      case CFTC_IND_CIT_ABS_CHANGES:
         return CIT_GROUP_TOTAL;
      case CFTC_IND_CIT_NETTO_POS:
      case CFTC_IND_CIT_NETTO_CHANGES:
      case CFTC_IND_CIT_INDEX:
      case CFTC_IND_CIT_MOV_INDEX:
      case CFTC_IND_CIT_WILLCO:
         return CIT_NETTO_TOTAL;
      case CFTC_IND_LCOT_ABS_POS:
      case CFTC_IND_LCOT_ABS_CHANGES:
         return LCOT_GROUP_TOTAL;
      case CFTC_IND_LCOT_NETTO_POS:
      case CFTC_IND_LCOT_NETTO_CHANGES:
      case CFTC_IND_LCOT_MOV_INDEX:
      case CFTC_IND_LCOT_WILLCO:
         return LCOT_NETTO_TOTAL;
   }
   return 0;
}
//+------------------------------------------------------------------+
//| Return type of report from of indicator 'ind_type'               |
//+------------------------------------------------------------------+
ENUM_CFTC_REPORT GetCftcReportFromInd(ENUM_CFTC_INDICATORS ind_type)
{
   string s_ind = EnumToString(ind_type);
   if(StringFind(s_ind, "_COT_", 8)!=-1)
      return CFTC_COT;
   if(StringFind(s_ind, "_DCOT_", 8)!=-1)
      return CFTC_DCOT;
   if(StringFind(s_ind, "_CIT_", 8)!=-1)
      return CFTC_CIT;
   if(StringFind(s_ind, "_TFF_", 8)!=-1)
      return CFTC_TFF;
   if(StringFind(s_ind, "_LCOT_", 8)!=-1)
      return CFTC_LCOT;
   return -1;
}
//+------------------------------------------------------------------+
//| Universal parameters                                             |
//+------------------------------------------------------------------+
struct CftcIndParams
{
   ENUM_CFTC_INDICATORS ind_type;
   int            group_traders;
   string         name_group_traders;
   int            period;
   int            mov_period;
   int            mov_type;
};
//+------------------------------------------------------------------+
//| Universal interface for get values any CFTC indicator            |
//+------------------------------------------------------------------+
bool GetCftcValuesByIndType(CotBaseSettings& settings, CftcIndParams& ind_params, datetime& times[], double& values[])
{
   switch(ind_params.ind_type)
   {
      /* CFTFC COT REPORTS*/
      case CFTC_IND_COT_ABS_POS:
         ind_params.name_group_traders = EnumCotGroupToString((ENUM_COT_GROUP)ind_params.group_traders);
         return GetCotAbsoluteValues(settings, (ENUM_COT_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_COT_ABS_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumCotGroupToString((ENUM_COT_GROUP)ind_params.group_traders);
         GetCotAbsoluteValues(settings, (ENUM_COT_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_COT_NETTO_POS:
         ind_params.name_group_traders = EnumCotNetGroupToString((ENUM_COT_NETTO_GROUP)ind_params.group_traders);
         return GetCotNettoValues(settings, (ENUM_COT_NETTO_GROUP)ind_params.group_traders, times, values);      
      case CFTC_IND_COT_NETTO_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumCotNetGroupToString((ENUM_COT_NETTO_GROUP)ind_params.group_traders);
         GetCotNettoValues(settings, (ENUM_COT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_COT_INDEX:
         ind_params.name_group_traders = EnumCotNetGroupToString((ENUM_COT_NETTO_GROUP)ind_params.group_traders);
         return GetCotIndexValues(settings,ind_params.period, (ENUM_COT_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_COT_MOV_INDEX:
      {
         double src_values[];
         ind_params.name_group_traders = EnumCotNetGroupToString((ENUM_COT_NETTO_GROUP)ind_params.group_traders);
         if(ind_params.mov_type == MOVMENT_ON_COT_INDEX)
            GetCotIndexValues(settings, ind_params.period, (ENUM_COT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         else
            GetCotWillcoValues(settings, ind_params.period, (ENUM_COT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, DIFF_ABS, ind_params.mov_period);
      }
      case CFTC_IND_COT_WILLCO_INDEX:
         ind_params.name_group_traders = EnumCotNetGroupToString((ENUM_COT_NETTO_GROUP)ind_params.group_traders);
         return GetCotWillcoValues(settings, ind_params.period, (ENUM_COT_NETTO_GROUP)ind_params.group_traders, times, values);
      /* CFTFC D-COT REPORTS*/
      case CFTC_IND_DCOT_ABS_POS:
         ind_params.name_group_traders = EnumDCotGroupToString((ENUM_DCOT_GROUP)ind_params.group_traders);
         return GetDCotAbsoluteValues(settings, (ENUM_DCOT_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_DCOT_ABS_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumDCotGroupToString((ENUM_DCOT_GROUP)ind_params.group_traders);
         GetDCotAbsoluteValues(settings, (ENUM_DCOT_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_DCOT_NETTO_POS:
         ind_params.name_group_traders = EnumDCotNettoToString((ENUM_DCOT_NETTO_GROUP)ind_params.group_traders);
         return GetDCotNettoValues(settings, (ENUM_DCOT_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_DCOT_NETTO_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumDCotNettoToString((ENUM_DCOT_NETTO_GROUP)ind_params.group_traders);
         GetDCotNettoValues(settings, (ENUM_DCOT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_DCOT_INDEX:
         ind_params.name_group_traders = EnumDCotNettoToString((ENUM_DCOT_NETTO_GROUP)ind_params.group_traders);
         return GetDCotIndexValues(settings,ind_params.period, (ENUM_DCOT_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_DCOT_MOV_INDEX:
      {
         double src_values[];
         ind_params.name_group_traders = EnumDCotNettoToString((ENUM_DCOT_NETTO_GROUP)ind_params.group_traders);
         if(ind_params.mov_type == MOVMENT_ON_COT_INDEX)
            GetDCotIndexValues(settings, ind_params.period, (ENUM_DCOT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         else
            GetDCotWillcoValues(settings, ind_params.period, (ENUM_DCOT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, DIFF_ABS, ind_params.mov_period);
      }
      case CFTC_IND_DCOT_WILLCO:
         ind_params.name_group_traders = EnumDCotNettoToString((ENUM_DCOT_NETTO_GROUP)ind_params.group_traders);
         return GetDCotWillcoValues(settings, ind_params.period, (ENUM_DCOT_NETTO_GROUP)ind_params.group_traders, times, values);
      /* CFTFC TFF REPORTS*/
      case CFTC_IND_TFF_ABS_POS:
         ind_params.name_group_traders = EnumTffGroupToString((ENUM_TFF_GROUP)ind_params.group_traders);
         return GetTffAbsoluteValues(settings, (ENUM_TFF_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_TFF_ABS_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumTffGroupToString((ENUM_TFF_GROUP)ind_params.group_traders);
         GetTffAbsoluteValues(settings, (ENUM_TFF_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_TFF_NETTO_POS:
         ind_params.name_group_traders = EnumTffNettoGroupToString((ENUM_TFF_NETTO_GROUP)ind_params.group_traders);
         return GetTffNettoValues(settings, (ENUM_TFF_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_TFF_NETTO_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumTffNettoGroupToString((ENUM_TFF_NETTO_GROUP)ind_params.group_traders);
         GetTffNettoValues(settings, (ENUM_TFF_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_TFF_INDEX:
         ind_params.name_group_traders = EnumTffNettoGroupToString((ENUM_TFF_NETTO_GROUP)ind_params.group_traders);
         return GetTffIndexValues(settings,ind_params.period, (ENUM_TFF_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_TFF_MOV_INDEX:
      {
         double src_values[];
         ind_params.name_group_traders = EnumTffNettoGroupToString((ENUM_TFF_NETTO_GROUP)ind_params.group_traders);
         if(ind_params.mov_type == MOVMENT_ON_COT_INDEX)
            GetTffIndexValues(settings, ind_params.period, (ENUM_TFF_NETTO_GROUP)ind_params.group_traders, times, src_values);
         else
            GetTffWillcoValues(settings, ind_params.period, (ENUM_TFF_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, DIFF_ABS, ind_params.mov_period);
      }
      case CFTC_IND_TFF_WILLCO:
         ind_params.name_group_traders = EnumTffNettoGroupToString((ENUM_TFF_NETTO_GROUP)ind_params.group_traders);
         return GetTffWillcoValues(settings, ind_params.period, (ENUM_TFF_NETTO_GROUP)ind_params.group_traders, times, values);
      /* CFTFC CIT REPORTS*/
      case CFTC_IND_CIT_ABS_POS:
         ind_params.name_group_traders = EnumCitGroupToString((ENUM_CIT_GROUP)ind_params.group_traders);
         return GetCitAbsoluteValues(settings, (ENUM_CIT_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_CIT_ABS_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumCitGroupToString((ENUM_CIT_GROUP)ind_params.group_traders);
         GetCitAbsoluteValues(settings, (ENUM_CIT_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_CIT_NETTO_POS:
         ind_params.name_group_traders = EnumCitNettoGroupToString((ENUM_CIT_NETTO_GROUP)ind_params.group_traders);
         return GetCitNettoValues(settings, (ENUM_CIT_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_CIT_NETTO_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumCitNettoGroupToString((ENUM_CIT_NETTO_GROUP)ind_params.group_traders);
         GetCitNettoValues(settings, (ENUM_CIT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_CIT_INDEX:
         ind_params.name_group_traders = EnumCitNettoGroupToString((ENUM_CIT_NETTO_GROUP)ind_params.group_traders);
         return GetCitIndexValues(settings,ind_params.period, (ENUM_CIT_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_CIT_MOV_INDEX:
      {
         double src_values[];
         ind_params.name_group_traders = EnumCitNettoGroupToString((ENUM_CIT_NETTO_GROUP)ind_params.group_traders);
         if(ind_params.mov_type == MOVMENT_ON_COT_INDEX)
            GetCitIndexValues(settings, ind_params.period, (ENUM_CIT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         else
            GetCitWillcoValues(settings, ind_params.period, (ENUM_CIT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, DIFF_ABS, ind_params.mov_period);
      }
      case CFTC_IND_CIT_WILLCO:
         ind_params.name_group_traders = EnumCitNettoGroupToString((ENUM_CIT_NETTO_GROUP)ind_params.group_traders);
         return GetCitWillcoValues(settings,ind_params.period, (ENUM_CIT_NETTO_GROUP)ind_params.group_traders, times, values);
      /* CFTFC LARGEST*/
      case CFTC_IND_LCOT_ABS_POS:
         ind_params.name_group_traders = EnumLCotToString((ENUM_LCOT_GROUP)ind_params.group_traders);
         return GetCotLargestValues(settings, (ENUM_LCOT_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_LCOT_ABS_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumLCotToString((ENUM_LCOT_GROUP)ind_params.group_traders);
         GetCotLargestValues(settings, (ENUM_LCOT_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_LCOT_NETTO_POS:
         ind_params.name_group_traders = EnumLCotNettoToString((ENUM_LCOT_NETTO_GROUP)ind_params.group_traders);
         return GetLCotNettoValues(settings, (ENUM_LCOT_NETTO_GROUP)ind_params.group_traders, times, values);
      case CFTC_IND_LCOT_NETTO_CHANGES:
      {
         double src_values[];
         ind_params.name_group_traders = EnumLCotNettoToString((ENUM_LCOT_NETTO_GROUP)ind_params.group_traders);
         GetLCotNettoValues(settings, (ENUM_LCOT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, (ENUM_DIFF_TYPE)ind_params.mov_type, ind_params.mov_period);
      }
      case CFTC_IND_LCOT_MOV_INDEX:
      {
         double src_values[];
         ind_params.name_group_traders = EnumLCotNettoToString((ENUM_LCOT_NETTO_GROUP)ind_params.group_traders);
         GetLCotIndexValues(settings, ind_params.period, (ENUM_LCOT_NETTO_GROUP)ind_params.group_traders, times, src_values);
         return GetDiffValues(src_values, values, DIFF_ABS, ind_params.mov_period);
      }
      case CFTC_IND_LCOT_WILLCO:
         ind_params.name_group_traders = EnumLCotNettoToString((ENUM_LCOT_NETTO_GROUP)ind_params.group_traders);
         return GetLCotIndexValues(settings, ind_params.period, (ENUM_LCOT_NETTO_GROUP)ind_params.group_traders, times, values);
   }
   return true;
}

datetime LastKnowingDate()
{
   double var;
   if(!GlobalVariableGet("MetaCotLastDate", var))
      return 0;
   datetime time = (datetime)((long)var);
   return time; 
}