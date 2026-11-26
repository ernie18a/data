//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                                 Copyright 2018, Vasiliy Sokolov. |
//|                                https://www.mql5.com/en/users/c-4 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| User event for check refresh of MetaCOT                          |
//+------------------------------------------------------------------+
#define METACOT_REFRESH 2382
//+------------------------------------------------------------------+
//| Type of data for calculation MovmentIndex (willco or COT-index)  |
//+------------------------------------------------------------------+
enum ENUM_MOVMENT_TYPE
{
   MOVMENT_ON_COT_INDEX,               // COT Index
   MOVMENT_ON_WILLCO                   // Willco Index
};
//+------------------------------------------------------------------+
//| Type of Different or type of lags                                |
//+------------------------------------------------------------------+
enum ENUM_DIFF_TYPE
{
   DIFF_ABS,         // Absolute values
   DIFF_PERCENT      // Percent values
};
//+------------------------------------------------------------------+
//| Type of CFTC report                                              |
//+------------------------------------------------------------------+
enum ENUM_CFTC_REPORT
{
   CFTC_COT,                           // Commitments of Traders
   CFTC_DCOT,                          // Disaggregated Commitments of Traders
   CFTC_TFF,                           // Traders in Financial Futures
   CFTC_CIT,                           // Commodity Index Trader Supplement
   CFTC_LCOT                           // Largest traders in COT
};
//+------------------------------------------------------------------+
//| Type of futures as source data                                   |
//+------------------------------------------------------------------+
enum ENUM_COT_SOURCE
{
   FUTURES_ONLY,                       // Futures Only 
   FUTURES_AND_OPTIONS,                // Futures And Options
};
//+------------------------------------------------------------------+
//| Type of group netto cot traders                                  |
//+------------------------------------------------------------------+
enum ENUM_COT_NETTO_GROUP
{
   COT_NETTO_OI,                       // Open Interest
   COT_NETTO_NCOMM,                    // Nett Noncomercial
   COT_NETTO_SPREAD,                   // Noncommercial Spread
   COT_NETTO_OPERATORS,                // Nett Operators
   COT_NETTO_NONREPORTABLE             // Nett Nonreportable
};
#define COT_NETTO_TOTAL 5
//+------------------------------------------------------------------+
//| The group of participants of the COT                             |
//+------------------------------------------------------------------+
enum ENUM_COT_GROUP
{
   COT_GROUP_OI,                       // Open Interest
   COT_GROUP_NONCOMM_LONG,             // Non-Commercial Long
   COT_GROUP_NONCOMM_SHORT,            // Non-Commercial Short
   COT_GROUP_NONCOMM_SPREAD,           // Non-Commercial Spread
   COT_GROUP_OPERATORS_LONG,           // Operators Long
   COT_GROUP_OPERATORS_SHORT,          // Operators Short
   COT_GROUP_NONREP_LONG = 8,          // Nonreportable Long
   COT_GROUP_NONREP_SHORT = 9,         // Nonreportable Short
};
#define COT_GROUP_TOTAL 10             // Count of COT group
//+------------------------------------------------------------------+
//| The group of participants of the Disaggregated (D-COT)           |
//+------------------------------------------------------------------+
enum ENUM_DCOT_GROUP
{
   DCOT_GROUP_OI,                      // Open Interest
   DCOT_GROUP_PRODUCER_LONG,           // Producer Long
   DCOT_GROUP_PRODUCER_SHORT,          // Producer Short
   DCOT_GROUP_DEALERS_LONG,            // Swap Dealers Long
   DCOT_GROUP_DEALERS_SHORT,           // Swap Dealers Short
   DCOT_GROUP_DEALERS_SPREAD,          // Swap Dealers Spread
   DCOT_GROUP_MANAGED_LONG,            // Managed Money Long
   DCOT_GROUP_MANAGED_SHORT,           // Managed Money Short
   DCOT_GROUP_MANAGED_SPREAD,          // Managed Money Spread
   DCOT_GROUP_REPORTABLE_LONG,         // Other Reportable Long
   DCOT_GROUP_REPORTABLE_SHORT,        // Other Reportable Short
   DCOT_GROUP_REPORTABLE_SPREAD,       // Other Reportable Spread
   DCOT_GROUP_TOTAL_LONG,              // Total Reportable Long
   DCOT_GROUP_TOTAL_SHORT,             // Total Reportable Short
   DCOT_GROUP_NONREP_LONG,             // Nonreportable Long
   DCOT_GROUP_NONREP_SHORT,            // Nonreportable Short
};
#define DCOT_GROUP_TOTAL 16            // Count of D-COT group
//+------------------------------------------------------------------+
//|Netto positions of participants Disaggregated COT (D-COT)         |
//+------------------------------------------------------------------+
enum ENUM_DCOT_NETTO_GROUP
{
   DCOT_NETTO_OI,                      // Open Interest
   DCOT_NETTO_PRODUCER,                // Nett Producer
   DCOT_NETTO_DEALERS,                 // Nett Dealers
   DCOT_NETTO_MANAGED,                 // Nett Manager
   DCOT_NETTO_REPORTABLE,              // Nett Other Reportable
   DCOT_NETTO_TOTAL,                   // Nett Total
   DCOT_NETTO_NONREP                   // Nett Nonrep
};
#define DCOT_NETTO_GROUP_TOTAL 7
//+------------------------------------------------------------------+
//| The group of Traders in Financial Futures (TFF)                  |
//+------------------------------------------------------------------+
enum ENUM_TFF_GROUP
{
   TFF_GROUP_OI,                       // Open Interest
   TFF_GROUP_DEALERS_LONG,             // Dealer Long
   TFF_GROUP_DEALERS_SHORT,            // Dealer Short
   TFF_GROUP_DEALERS_SPREAD,           // Dealer Spread
   TFF_GROUP_INSTITUTIONAL_LONG,       // Institutional Long
   TFF_GROUP_INSTITUTIONAL_SHORT,      // Institutional Short
   TFF_GROUP_INSTITUTIONAL_SPREAD,     // Institutional Spread
   TFF_GROUP_LEVERAGE_LONG,            // Leverage Found Long
   TFF_GROUP_LEVERAGE_SHORT,           // Leverage Found Short
   TFF_GROUP_LEVERAGE_FOUND_SPREAD,    // Leverage Found Spread
   TFF_GROUP_OTHER_REP_LONG,           // Other Reportable Long
   TFF_GROUP_OTHER_REP_SHORT,          // Other Reportable Short
   TFF_GROUP_OTHER_REP_SPREAD,         // Other Reportable Spread
   TFF_GROUP_TOTAL_REP_LONG,           // Total Reportable Long
   TFF_GROUP_TOTAL_REP_SHORT,          // Total Reportable Short
   TFF_GROUP_NONREP_LONG,              // Nonreportable Long
   TFF_GROUP_NONREP_SHORT,             // Nonreportable Short
};
#define TFF_GROUP_TOTAL 15             // Count of TFF group
//+------------------------------------------------------------------+
//| Netto group of TFF report                                        |
//+------------------------------------------------------------------+
enum ENUM_TFF_NETTO_GROUP
{
   TFF_NETTO_OI,                       // Open Interest
   TFF_NETTO_DEALERS,                  // Nett Dealers
   TFF_NETTO_INSTITUTIONAL,            // Nett Institutional
   TFF_NETTO_LEVERAGE,                 // Nett Leverage
   TFF_NETTO_REPORTABLE,               // Nett Reportable
   TFF_NETTO_NONREPORT                 // Nett Nonreportable
};
#define TFF_NETTO_TOTAL 6              // Count of TFF nett group
//+------------------------------------------------------------------+
//| Group of commodity index traders (CIT)                           |
//+------------------------------------------------------------------+
enum ENUM_CIT_GROUP
{
   CIT_GROUP_OI,                       // Open Interest
   CIT_GROUP_NONCOMM_LONG,             // Non-Commercial Long
   CIT_GROUP_NONCOMM_SHORT,            // Non-Commercial Short
   CIT_GROUP_NONCOMM_SPREAD,           // Non-Commercial Spread
   CIT_GROUP_OPERATORS_LONG,           // Operators Long
   CIT_GROUP_OPERATORS_SHORT,          // Operators Short
   CIT_GROUP_REP_LONG,                 // Total Reportable Long
   CIT_GROUP_REP_SHORT,                // Total Reportable Short
   CIT_GROUP_NONREP_LONG,              // Nonreportable Long
   CIT_GROUP_NONREP_SHORT,             // Nonreportable Short
   CIT_GROUP_ALL_LONG,                 // CIT Long All
   CIT_GROUP_ALL_SHORT                 // CIT Short All
};
#define CIT_GROUP_TOTAL 12             // Count of CIT group
//+------------------------------------------------------------------+
//| Netto group of commodity index traders (CIT)                     |
//+------------------------------------------------------------------+
enum ENUM_CIT_NETTO_GROUP
{
   CIT_NETTO_OI,                       // Open Interest
   CIT_NETTO_NONCOMM,                  // Nett Noncommercial
   CIT_NETTO_OPERATORS,                // Nett Operators
   CIT_NETTO_REPORTABLE,               // Nett Reportable
   CIT_NETTO_NONREP,                   // Nett Nonreportable
   CIT_NETTO_ALL                       // Nett CIT All
};
#define CIT_NETTO_TOTAL 6              // Count of CIT netto group
//+------------------------------------------------------------------+
//| Subgroup of CFTC report                                          |
//+------------------------------------------------------------------+
enum ENUM_COT_SUBGROUP
{
   COT_SUBGROUP_ALL,                   // All
   COT_SUBGROUP_OLD,                   // Old
   COT_SUBGROUP_OTHER,                 // Other
};
#define COT_SUBGROUP_TOTAL 3           // Count of subgroup nett group
//+------------------------------------------------------------------+
//| Type of data player (volumes or count)                           |
//+------------------------------------------------------------------+
enum ENUM_COT_DATA_TYPE
{
   COT_DATA_FUTURES,                   // Contracts of Traders
   COT_DATA_NUMBERS_TRADES,            // Number of Traders
};
//+------------------------------------------------------------------+
//| Availability type of the report                                  |
//+------------------------------------------------------------------+
enum ENUM_COT_RELEASE_DAY
{
   COT_RELEASE_TUESDAY,                // Release by Tuesday 
   COT_RELEASE_FRIDAY,                 // Release by Friday 
};
//+------------------------------------------------------------------+
//| Type of largest traders                                          |
//+------------------------------------------------------------------+
enum ENUM_LCOT_GROUP
{
      LCOT_GROSS_LONG_4,               // Largest Gross Long 4
      LCOT_GROSS_SHORT_4,              // Largest Gross Short 4
      LCOT_GROSS_LONG_8,               // Largest Gross Long 8
      LCOT_GROSS_SHORT_8,              // Largest Gross Short 8
      LCOT_NET_LONG_4,                 // Largest Net Long 4
      LCOT_NET_SHORT_4,                // Largest Net Short 4
      LCOT_NET_LONG_8,                 // Largest Net Long 8
      LCOT_NET_SHORT_8,                // Largest Net Short 8
};
#define LCOT_GROUP_TOTAL 8
//+------------------------------------------------------------------+
//| Type of netto largest traders                                    |
//+------------------------------------------------------------------+
enum ENUM_LCOT_NETTO_GROUP
{
      LCOT_NETTO_4,                    // Largest nett by gross  4
      LCOT_NETTO_8,                    // Largest nett by gross 8
      LCOT_NETTO_NET_4,                // Largest nett by net 4
      LCOT_NETTO_NET_8,                // Largest nett by net 8
};
#define LCOT_NETTO_TOTAL 4             // Count of Largest COT nett group
//+------------------------------------------------------------------+
//| All CFTC indicators                                              |
//+------------------------------------------------------------------+
enum ENUM_CFTC_INDICATORS
{
// Commitments of Traders (COT) group of indicators 
   CFTC_IND_COT_ABS_POS,               // COT Absolute Position
   CFTC_IND_COT_ABS_CHANGES,           // COT Absolute Changes
   CFTC_IND_COT_NETTO_POS,             // COT Nett Position
   CFTC_IND_COT_NETTO_CHANGES,         // COT Nett Changes
   CFTC_IND_COT_INDEX,                 // COT Index
   CFTC_IND_COT_WILLCO_INDEX,          // COT Willco
   CFTC_IND_COT_MOV_INDEX,             // COT Movement Index
// Disaggregated Commitments of Traders (D-COT) group of indicators 
   CFTC_IND_DCOT_ABS_POS,              // DCOT Absolute Position
   CFTC_IND_DCOT_ABS_CHANGES,          // DCOT Absolute Changes
   CFTC_IND_DCOT_NETTO_POS,            // DCOT Nett Position
   CFTC_IND_DCOT_NETTO_CHANGES,        // DCOT Nett Changes
   CFTC_IND_DCOT_INDEX,                // DCOT Index
   CFTC_IND_DCOT_WILLCO,               // DCOT Willco
   CFTC_IND_DCOT_MOV_INDEX,            // DCOT Movement Index
// Traders in Financial Futures (TFF) group of indicators 
   CFTC_IND_TFF_ABS_POS,               // TFF Absolute Position
   CFTC_IND_TFF_ABS_CHANGES,           // TFF Absolute Changes
   CFTC_IND_TFF_NETTO_POS,             // TFF Nett Position
   CFTC_IND_TFF_NETTO_CHANGES,         // TFF Nett Changes
   CFTC_IND_TFF_INDEX,                 // TFF Index
   CFTC_IND_TFF_WILLCO,                // TFF Willco
   CFTC_IND_TFF_MOV_INDEX,             // TFF Movement Index
// Commitments Index Traders (CIT) group of indicators 
   CFTC_IND_CIT_ABS_POS,               // CIT Absolute Position
   CFTC_IND_CIT_ABS_CHANGES,           // CIT Absolute Changes
   CFTC_IND_CIT_NETTO_POS,             // CIT Nett Position
   CFTC_IND_CIT_NETTO_CHANGES,         // CIT Nett Changes
   CFTC_IND_CIT_INDEX,                 // CIT Index
   CFTC_IND_CIT_WILLCO,                // CIT Willco
   CFTC_IND_CIT_MOV_INDEX,             // CIT Movement Index
// Largest Traders in COT (L-COT) group of indicators 
   CFTC_IND_LCOT_ABS_POS,              // LCOT Absolute Position
   CFTC_IND_LCOT_ABS_CHANGES,          // LCOT Absolute Changes
   CFTC_IND_LCOT_NETTO_POS,            // LCOT Nett Position
   CFTC_IND_LCOT_NETTO_CHANGES,        // LCOT Nett Changes
   CFTC_IND_LCOT_WILLCO,               // LCOT Willco
   CFTC_IND_LCOT_MOV_INDEX,            // LCOT Movement Index
};
#define CFTC_INDICATORS_TOTAL 34
//+------------------------------------------------------------------+
//| Convert string line to CFTC indicator ID                         |
//+------------------------------------------------------------------+
ENUM_CFTC_INDICATORS CftcIndTypeFromString(string ind)
{
   string ind_types[];
   ArrayResize(ind_types, CFTC_INDICATORS_TOTAL);
   for(int i = 0; i < CFTC_INDICATORS_TOTAL; i++)
   {
      if(EnumToString((ENUM_CFTC_INDICATORS)i) == ind)
         return (ENUM_CFTC_INDICATORS)i;
   }
   return false;   
}
//+------------------------------------------------------------------+
//| Convert string line to CFTC indicator ID                         |
//+------------------------------------------------------------------+
bool CftcIndTypeFromString(string ind, ENUM_CFTC_INDICATORS& ind_type)
{
   string ind_types[];
   ArrayResize(ind_types, CFTC_INDICATORS_TOTAL);
   for(int i = 0; i < CFTC_INDICATORS_TOTAL; i++)
   {
      if(EnumToString((ENUM_CFTC_INDICATORS)i) == ind)
      {
         ind_type = (ENUM_CFTC_INDICATORS)i;
         return true;
      }
   }
   return false;   
}
//+------------------------------------------------------------------+
//| String name of type largest traders                              |
//+------------------------------------------------------------------+
string EnumLCotToString(ENUM_LCOT_GROUP largest_type)
{
   switch(largest_type)
   {
      case LCOT_GROSS_LONG_4:
         return "Abs. Long 4";
      case LCOT_GROSS_SHORT_4:
         return "Abs. Short 4";
      case LCOT_GROSS_LONG_8:
         return "Abs. Long 8";
      case LCOT_NET_LONG_4:
         return "Net Long 4";
      case LCOT_NET_SHORT_4:
         return "Net Short 4";
      case LCOT_NET_LONG_8:
         return "Net Long 8";
   }
   return "";
}
//+------------------------------------------------------------------+
//| String name of type largest traders                              |
//+------------------------------------------------------------------+
string EnumLCotNettoToString(ENUM_LCOT_NETTO_GROUP largest_type)
{
   switch(largest_type)
   {
      case LCOT_NETTO_4:
         return "Gross Nett 4";
      case LCOT_NETTO_8:
         return "Gross Nett 8";
      case LCOT_NETTO_NET_4:
         return "Net Nett 4";
      case LCOT_NETTO_NET_8:
         return "Net Nett 8";
   }
   return "";
}
//+------------------------------------------------------------------+
//|Return string type of CFTC type report                            |
//+------------------------------------------------------------------+
string EnumCftcToString(ENUM_CFTC_REPORT report)
{
   string name = EnumToString(report);
   string arr[];
   StringSplit(name, '_', arr);
   if(ArraySize(arr) < 2)return "CFTC";
   return arr[1];
}
//+------------------------------------------------------------------+
//| Return string COT group                                          |
//+------------------------------------------------------------------+
string EnumCotGroupToString(ENUM_COT_GROUP cot_group)
{
   switch(cot_group)
   {
      case COT_GROUP_NONCOMM_LONG:
         return "Non-Comm. Long";
      case COT_GROUP_NONCOMM_SHORT:
         return "Non-Comm. Short";
      case COT_GROUP_OPERATORS_LONG:
         return "Operators Long";
      case COT_GROUP_OPERATORS_SHORT:
         return "Operators Short";
      case COT_GROUP_NONREP_LONG:
         return "Nonrep. Long";
      case COT_GROUP_NONREP_SHORT:
         return "Nonrep. Short";
      case COT_GROUP_OI:
         return "OI";
      case COT_GROUP_NONCOMM_SPREAD:
         return "Noncomm. Spread";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string net cot group                                      |
//+------------------------------------------------------------------+
string EnumCotNetGroupToString(ENUM_COT_NETTO_GROUP cot_group)
{
   switch(cot_group)
   {
      case COT_NETTO_OI:
         return "OI";
      case COT_NETTO_NCOMM:
         return "Nett Noncomm.";
      case COT_NETTO_SPREAD:
         return "Nett Noncomm. spread";
      case COT_NETTO_OPERATORS:
         return "Nett Operators";
      case COT_NETTO_NONREPORTABLE:
         return "Nett norep.";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string DCOT group                                         |
//+------------------------------------------------------------------+
string EnumDCotGroupToString(ENUM_DCOT_GROUP dcot_group)
{
   switch(dcot_group)
   {
      case DCOT_GROUP_OI:
         return "OI";
      case DCOT_GROUP_PRODUCER_LONG:
         return "Producer Long";
      case DCOT_GROUP_PRODUCER_SHORT:
         return "Producer Short";
      case DCOT_GROUP_DEALERS_LONG:
         return "Dealers Long";
      case DCOT_GROUP_DEALERS_SHORT:
         return "Dealers Short";
      case DCOT_GROUP_DEALERS_SPREAD:
         return "Dealers Spread";
      case DCOT_GROUP_MANAGED_LONG:
         return "Manager Long";
      case DCOT_GROUP_MANAGED_SHORT:
         return "Manager Short";
      case DCOT_GROUP_MANAGED_SPREAD:
         return "Manager Spread";
      case DCOT_GROUP_REPORTABLE_LONG:
         return "Reportable Long";
      case DCOT_GROUP_REPORTABLE_SHORT:
         return "Reportable Short";
      case DCOT_GROUP_REPORTABLE_SPREAD:
         return "Reportable Spread";
      case DCOT_GROUP_TOTAL_LONG:
         return "Total Rep. Long";
      case DCOT_GROUP_TOTAL_SHORT:
         return "Total Rep. Short";
      case DCOT_GROUP_NONREP_LONG:
         return "Nonrep. Long";
      case DCOT_GROUP_NONREP_SHORT:
         return "Nonrep. Short";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string nett DCOT group                                    |
//+------------------------------------------------------------------+
string EnumDCotNettoToString(ENUM_DCOT_NETTO_GROUP dcot_group)
{
   switch(dcot_group)
   {
      case DCOT_NETTO_OI:
         return "Nett OI";
      case DCOT_NETTO_MANAGED:
         return "Nett Managed";
      case DCOT_NETTO_NONREP:
         return "Nett Nonrep.";
      case DCOT_NETTO_DEALERS:
         return "Nett Dealers";
      case DCOT_NETTO_PRODUCER:
         return "Nett Producer";
      case DCOT_NETTO_REPORTABLE:
         return "Nett Reportable";
      case DCOT_NETTO_TOTAL:
         return "Nett Total";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string TFF group                                          |
//+------------------------------------------------------------------+
string EnumTffGroupToString(ENUM_TFF_GROUP tff_group)
{
   switch(tff_group)
   {
      case TFF_GROUP_OI:
         return "OI";
      case TFF_GROUP_DEALERS_LONG:
         return "Dealers Long";
      case TFF_GROUP_DEALERS_SHORT:
         return "Dealers Short";
      case TFF_GROUP_DEALERS_SPREAD:
         return "Dealers Spread";
      case TFF_GROUP_INSTITUTIONAL_LONG:
         return "Institutional Long";
      case TFF_GROUP_INSTITUTIONAL_SHORT:
         return "Institutional Short";
      case TFF_GROUP_INSTITUTIONAL_SPREAD:
         return "Institutional Spread";
      case TFF_GROUP_LEVERAGE_LONG:
         return "Found Long";
      case TFF_GROUP_LEVERAGE_SHORT:
         return "Found Short";
      case TFF_GROUP_LEVERAGE_FOUND_SPREAD:
         return "Leverage Found Spread";
      case TFF_GROUP_OTHER_REP_LONG:
         return "Other Rep. Long";
      case TFF_GROUP_OTHER_REP_SHORT:
         return "Other Rep. Short";
      case TFF_GROUP_OTHER_REP_SPREAD:
         return "Other Rep. Spread";
      case TFF_GROUP_NONREP_LONG:
         return "Nonrep. Long";
      case TFF_GROUP_NONREP_SHORT:
         return "Nonrep. Short";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string nett TFF group   	                                 |
//+------------------------------------------------------------------+
string EnumTffNettoGroupToString(ENUM_TFF_NETTO_GROUP tff_group)
{
   switch(tff_group)
   {
      case TFF_NETTO_OI:
         return "OI";
         break;
      case TFF_NETTO_DEALERS:
         return "Nett Dealers";
         break;
      case TFF_NETTO_INSTITUTIONAL:
         return "Nett Instit.";
         break;
      case TFF_NETTO_LEVERAGE:
         return "Nett Leverage";
         break;
      case TFF_NETTO_NONREPORT:
         return "Nett Nonrep.";
         break;
      case TFF_NETTO_REPORTABLE:
         return "Nett Reportable";
         break;
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string cit group                                          |
//+------------------------------------------------------------------+
string EnumCitGroupToString(ENUM_CIT_GROUP cit_group)
{
   switch(cit_group)
   {
      case CIT_GROUP_NONCOMM_LONG:
         return "Noncomm. Long";
      case CIT_GROUP_NONCOMM_SHORT:
         return "Noncomm. Short";
      case CIT_GROUP_NONCOMM_SPREAD:
         return "Noncomm. Spread";
      case CIT_GROUP_OI:
         return "OI";
      case CIT_GROUP_OPERATORS_LONG:
         return "Operators Long";
      case CIT_GROUP_OPERATORS_SHORT:
         return "Operators Short";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string nett CIT group                                     |
//+------------------------------------------------------------------+
string EnumCitNettoGroupToString(ENUM_CIT_NETTO_GROUP cit_group)
{
   switch(cit_group)
   {
      case CIT_NETTO_OI:
         return "OI";
      case CIT_NETTO_NONCOMM:
         return "Nett Noncomm.";
      case CIT_NETTO_OPERATORS:
         return "Nett Operators";
      case CIT_NETTO_NONREP:
         return "Nett Nonrep.";
      case CIT_NETTO_ALL:
         return "Nett CIT All";
      case CIT_NETTO_REPORTABLE:
         return "Nett Reportable";
   }
   return "";
}
//+------------------------------------------------------------------+
//| Return string source of report                                   |
//+------------------------------------------------------------------+
string EnumCotToString(ENUM_COT_SOURCE source)
{
   if(source == FUTURES_ONLY)
      return "Futures Only";
   return "Futures And Options";
}