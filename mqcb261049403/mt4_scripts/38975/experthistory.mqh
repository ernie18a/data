//+------------------------------------------------------------------+
//|                                                ExportHistory.mqh |
//|                                      Copyright 2021, Yuriy Bykov |
//|                               https://www.mql5.com/ru/code/37444 |
//|                               https://www.mql5.com/ru/code/38981 |
//|                               https://www.mql5.com/en/code/38938 |
//|                               https://www.mql5.com/en/code/38980 |
//+------------------------------------------------------------------+
#property description   "Save deals history and/or parameters of expert runs to common folder of terminal"
#property copyright     "Copyright 2021, Yuriy Bykov"
#property link          "https://www.mql5.com/ru/code/37444"
#property link          "https://www.mql5.com/ru/code/38981"
#property link          "https://www.mql5.com/en/code/38938"
#property link          "https://www.mql5.com/en/code/38980"
#property version       "1.79"

/**
// 0. Include library with CExpertHistory class
   [code]
      #include <ExpertHistory.mqh>
   [/code]

Base usage:

1. Create object instance in global scope:
   [code]
      CExpertHistory expertHistory();
   [/code]


2. Add in OnTester() function call of Export() method:
   [code]
      double OnTester(void) {
         ...

         expertHistory.Export();

         ...
      }
   [/code]

-----------------------------------------------------------------------

Advanced Usage:

1. Create object instance in global scope:
   [code]
      string expertName = "SomeExpert";
      string expertVersion = "1.00";      // Not required
      string dataSeparator = ",";         // Not required
      string decimalPoint = ".";          // Not required

      CExpertHistory expertHistory(expertName, expertVersion, dataSeparator, decimalPoint);
   [/code]

2. Add in OnInit() function any pairs of parameter's names and values:
   [code]
      input double SL = 500;
      input double TP = 1000;


      int OnInit() {
         ...

         expertHistory.AddParam("Symbol", Symbol());
         expertHistory.AddParam("TP", TP);
         expertHistory.AddParam("SL", SL);
         ...
      }
   [/code]

3. Add in OnTester() or in OnDeinit() function call of Export() method:
   [code]
      double OnTester(void) {
         ...

         if(!MQLInfoInteger(MQL_OPTIMIZATION)) {   // If you want save history only in single tester run
            expertHistory.Export();                // See parameters for Export() below
         }

         ...
      }
   [/code]
*/

enum ENUM_HISTORY_EXPORT_FORMAT {
   HEF_INI_FULL, // All info in INI-file format
   HEF_INI_DEALS, // Only deals in INI-file format
   HEF_CSV_DEALS, // Only deals in CSV-file format
};

enum ENUM_HISTORY_FILENAME_FORMAT {
   HFF_EXPERT_NAME,           // Name.history.csv
   HFF_EXPERT_NAME_VERSION,   // Name.Version.history.csv
   HFF_FULL,                  // Name.Version [Period] [Balance] [Parameters].history.csv
   HFF_ACCOUNT_PERIOD,        // Account [Period].history.csv
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CExpertHistory {
private:
   string            m_expertName;
   string            m_expertVersion;
   string            m_sep;
   string            m_decimalPoint;

   datetime          m_startDate;
   ulong             m_startTestingTime;
   string            m_fileName;
   int               m_file;

   string            m_paramNames[];
   string            m_paramValues[];


   void              WriteTitle();
   void              WriteAccountInfo();
   void              WriteParams();
   void              WriteTesterResults();
   void              WriteDealsHistory(bool writeSectionName = true);
   string            ToString(double value, int digits = 2);

   void              SetStartDate();

public:
   CExpertHistory(string p_expertName = "SomeExpert", string p_expertVersion = "", string p_sep = ",", string p_decimalPoint = ".");
   void              Name(string p_expertName) {
      m_expertName = p_expertName;
   }
   void              Version(string p_expertVersion) {
      m_expertVersion = p_expertVersion;
   }

   ~CExpertHistory(void) {};
   string            ParamsToString(string sep = ", ", bool b_withNames = false);

   void              AddParam(string paramName, bool value) {
      AddParam(paramName, (value ? "True" : "False"));
   }

   void              AddParam(string paramName, int value) {
      AddParam(paramName, IntegerToString(value));
   }

   void              AddParam(string paramName, double value, int d = 2) {
      AddParam(paramName, ToString(value, d));
   }

   void              AddParam(string paramName, string value) {
      uint n = ArraySize(m_paramNames);
      ArrayResize(m_paramNames, n + 1);
      ArrayResize(m_paramValues, n + 1);
      m_paramNames[n] = paramName;
      m_paramValues[n] = value;
   }

   void              FileName(string p_fileName) {
      m_fileName = p_fileName;
   }

   void              Export(
      string exportFileName = "",                                    // The name of the file to export. If empty, it will be generated according to the exportFileNameFormat parameter
      ENUM_HISTORY_EXPORT_FORMAT exportFormat = HEF_INI_FULL,        // Export format. By default, in the file in addition to the transactions
      // account parameters are recorded, testing period, max. drawdown and so on.
      ENUM_HISTORY_FILENAME_FORMAT exportFileNameFormat = HFF_FULL,  // File name format. By default, the file name includes the server name, the testing period, max. drawdown and so on.
      int commonFlag = FILE_COMMON                                   // Save a file to a shared terminal folder. If it is equal to 0, then save to a non-shared folder.
   );
   string            GetHistoryFileName(ENUM_HISTORY_FILENAME_FORMAT format = HFF_FULL);

   bool              Deinit();

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::CExpertHistory(string p_expertName = "SomeExpert",
                                    string p_expertVersion = "",
                                    string p_sep = ",",
                                    string p_decimalPoint = ".") {
   m_expertName = p_expertName;
   m_expertVersion = p_expertVersion;
   m_startDate = TimeCurrent();
   m_sep = p_sep;
   m_decimalPoint = p_decimalPoint;

#ifdef __MQL5__
   m_startTestingTime = GetTickCount64();
#endif

#ifdef __MQL4__
   m_startTestingTime = GetMicrosecondCount();
#endif

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CExpertHistory::Deinit() {
   ArrayResize(m_paramNames, 0);
   ArrayResize(m_paramValues, 0);
   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::WriteTitle(void) {
   string s = "[Title]\n";

   if(m_expertName != "") {
      s += "Name=" + m_expertName + "\n";
   }

   if(m_expertVersion != "") {
      s += "Version=" + m_expertVersion + "\n";
   }
   s += "Period start=" + TimeToString(m_startDate, TIME_DATE) + "\n";
   s += "Period end=" + TimeToString(TimeCurrent(), TIME_DATE) + "\n";

   FileWrite(m_file, s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::WriteAccountInfo(void) {
   string s = "[Account]\n";
   s += "Server=" + AccountInfoString(ACCOUNT_SERVER) + "\n";
   s += "Leverage=1:" + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + "\n";
   FileWrite(m_file, s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::WriteTesterResults(void) {
   string s = "[TesterResults]\n";
   s += "Profit=" + ToString(TesterStatistics(STAT_PROFIT)) + "\n";
   s += "Max DD=" + ToString(TesterStatistics(STAT_EQUITYDD_PERCENT)) + "\n";
   s += "Relative DD=" + ToString(TesterStatistics(STAT_EQUITY_DDREL_PERCENT)) + "\n";
   s += "Min Margin Level=" + ToString(TesterStatistics(STAT_MIN_MARGINLEVEL)) + "\n";
   s += "Sharp Ratio=" + ToString(TesterStatistics(STAT_SHARPE_RATIO)) + "\n";
   s += "Recovery Factor=" + ToString(TesterStatistics(STAT_RECOVERY_FACTOR)) + "\n";

#ifdef __MQL5__
   ulong seconds = (GetTickCount64() - m_startTestingTime) / 1000;
#endif

#ifdef __MQL4__
   ulong seconds = (GetMicrosecondCount() - m_startTestingTime) / 1000;
#endif

   ulong h, m;
   h = seconds / 3600;
   m = seconds % 3600 / 60;
   seconds = seconds % 60;

   s += "Testing time=" + (h < 10 ? "0" : "") + IntegerToString(h) + ":"
        + (m < 10 ? "0" : "") + IntegerToString(m) + ":"
        + (seconds < 10 ? "0" : "") + IntegerToString(seconds)  + "\n";
   FileWrite(m_file, s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::WriteParams(void) {
   string s = "[Parameters]\n";
   s += ParamsToString("\n", true) + "\n";
   FileWrite(m_file, s);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::WriteDealsHistory(bool writeSectionName = true) {
   if(writeSectionName) {
      FileWrite(m_file, "[DealsHistory]");
   }
   FileWrite(m_file, "DATE" + m_sep + "TICKET" + m_sep + "TYPE" + m_sep + "SYMBOL" + m_sep +
             "VOLUME" + m_sep + "ENTRY" + m_sep + "PRICE" + m_sep + "STOPLOSS" + m_sep +
             "TAKEPROFIT" + m_sep + "PROFIT" + m_sep + "COMMISSION" + m_sep +
             "FEE" + m_sep + "SWAP" + m_sep + "MAGIC" + m_sep + "COMMENT");

   uint     total;
   ulong    ticket = 0;
   long     entry;
   double   price;
   double   sl, tp;
   double   profit, commission, fee, swap;
   double   volume;
   datetime time;
   string   symbol;
   long     type, magic;
   string   comment;

#ifdef __MQL5__
   HistorySelect(0, TimeCurrent());
   total = HistoryDealsTotal();

//--- for all deals
   for(uint i = 0; i < total; i++) {
      //--- try to get deals ticket
      if((ticket = HistoryDealGetTicket(i)) > 0) {
         time  = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         type  = HistoryDealGetInteger(ticket, DEAL_TYPE);
         symbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
         volume = HistoryDealGetDouble(ticket, DEAL_VOLUME);
         entry = HistoryDealGetInteger(ticket, DEAL_ENTRY);
         price = HistoryDealGetDouble(ticket, DEAL_PRICE);
         sl = HistoryDealGetDouble(ticket, DEAL_SL);
         tp = HistoryDealGetDouble(ticket, DEAL_TP);
         profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
         fee = HistoryDealGetDouble(ticket, DEAL_FEE);
         swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
         magic = HistoryDealGetInteger(ticket, DEAL_MAGIC);
         comment = HistoryDealGetString(ticket, DEAL_COMMENT);

         if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL || type == DEAL_TYPE_BALANCE) {
            FileWrite(m_file, TimeToString(time, TIME_DATE | TIME_MINUTES | TIME_SECONDS), ticket, type, symbol, ToString(volume), entry,
                      ToString(price, 5), ToString(sl, 5), ToString(tp, 5), ToString(profit),
                      ToString(commission), ToString(fee), ToString(swap), magic, comment);
         }
      }
   }
#endif

#ifdef __MQL4__
   total = OrdersHistoryTotal();

   if(total == 0) {
      return;
   }

   uint i;

   ulong O[][3];

   ArrayResize(O, 2 * total);
   ArrayInitialize(O, -1);

   for(i = 0; i < total; i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         type = OrderType();
         if(type == OP_BUY || type == OP_SELL || type == 6) {
            O[i][0] = OrderOpenTime();
            O[i][1] = 1;
            O[i][2] = OrderTicket();

            if(OrderCloseTime() > 0) {
               O[i + total][0] = OrderCloseTime();
            } else {
               O[i + total][0] = TimeCurrent();
            }
            O[i + total][1] = 0;
            O[i + total][2] = OrderTicket();
         }
      }
   }

   ArraySort(O);

   for(i = 0; i < (uint) ArrayRange(O, 0); i++) {
      if(OrderSelect((int) O[i][2], SELECT_BY_TICKET)) {
         time = (datetime) O[i][0];
         ticket = OrderTicket();
         type = OrderType();

         // If it's balance operation, don't write close record
         if(type == 6 && O[i][1] == 0) {
            continue;
         }

         // If it's close operation, swap order type
         if(type != 6 && O[i][1] == 0) {
            type = (type == OP_BUY ? OP_SELL : OP_BUY);
         }

         symbol = OrderSymbol();
         volume = OrderLots();
         entry = (O[i][1] == 1 ? 0 : 1);
         price = OrderOpenPrice();
         sl = OrderStopLoss();
         tp = OrderTakeProfit();
         profit = OrderProfit();
         commission = OrderCommission();
         fee = 0;
         swap = OrderSwap();
         magic = OrderMagicNumber();
         comment = OrderComment();

         if(type == OP_BUY || type == OP_SELL || type == 6) {
            FileWrite(m_file, TimeToString(time, TIME_DATE | TIME_MINUTES | TIME_SECONDS), ticket, type, symbol, ToString(volume), entry,
                      ToString(price, 5), ToString(sl, 5), ToString(tp, 5), ToString(profit),
                      ToString(commission), ToString(fee), ToString(swap), magic, comment);
         }
      } else {

      }
   }
#endif
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CExpertHistory::ParamsToString(string p_sep = ", ", bool b_withNames = false) {
   string res = "";
   int n = ArraySize(m_paramNames);

   for(int i = 0; i < n; i++) {
      if(b_withNames) {
         res += m_paramNames[i] + "=";
      }
      res += m_paramValues[i];
      if(i < n - 1) {
         res += p_sep;
      }
   }

   return res;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CExpertHistory::SetStartDate() {
   uint     total;

#ifdef __MQL5__
   HistorySelect(0, TimeCurrent());
   total = HistoryDealsTotal();
   ulong ticket;

   for(uint i = 0; i < total; i++) {
      //--- try to get deals ticket
      if((ticket = HistoryDealGetTicket(i)) > 0) {
         m_startDate = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME);
         break;
      }
   }
#endif

#ifdef __MQL4__
   total = OrdersHistoryTotal();

   if(total == 0) {
      return;
   }

   uint i;

   for(i = 0; i < total; i++) {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY)) {
         m_startDate = OrderOpenTime();
         break;
      }
   }
#endif

}

//+------------------------------------------------------------------+
//| Generate file name for export                                    |
//+------------------------------------------------------------------+
string CExpertHistory::GetHistoryFileName(ENUM_HISTORY_FILENAME_FORMAT format = HFF_FULL) {
   string fileName = m_expertName;

   SetStartDate();

   switch(format) {
   case HFF_EXPERT_NAME_VERSION :
      fileName += "." + m_expertVersion;
      break;
   case HFF_FULL:
      fileName += "." + m_expertVersion;

      fileName += " ";

      fileName += "[" + TimeToString(m_startDate, TIME_DATE);
      fileName += " - " + TimeToString(TimeCurrent(), TIME_DATE) + "]";

      fileName += " ";

      fileName += "[" + DoubleToString(TesterStatistics(STAT_INITIAL_DEPOSIT), 0);
      fileName += ", " + DoubleToString(TesterStatistics(STAT_INITIAL_DEPOSIT) + TesterStatistics(STAT_PROFIT), 0);
      fileName += ", " + DoubleToString(MathMax(TesterStatistics(STAT_EQUITYDD_PERCENT), TesterStatistics(STAT_EQUITY_DDREL_PERCENT)), 2);
      fileName += "]";

      fileName += " ";

      fileName += "[" + ParamsToString() + "]";
      break;
   case HFF_ACCOUNT_PERIOD:
      fileName = AccountInfoString(ACCOUNT_SERVER) + " " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
      fileName += " ";
      fileName += "[" + TimeToString(m_startDate, TIME_DATE);
      fileName += " - " + TimeToString(TimeCurrent(), TIME_DATE) + "]." + IntegerToString(TimeCurrent() % (24 * 3600));

      break;
   default:
      break;
   }

   if(StringLen(fileName) > 255) {
      fileName = StringSubstr(fileName, 0, 255 - 13);
   }

   fileName += ".history.csv";
   return fileName;
}

//+------------------------------------------------------------------+
//| Main method for export history and parameters                    |
//+------------------------------------------------------------------+
void CExpertHistory::Export(string exportFileName = "", ENUM_HISTORY_EXPORT_FORMAT exportFormat = HEF_INI_FULL, ENUM_HISTORY_FILENAME_FORMAT exportFileNameFormat = HFF_FULL, int commonFlag = FILE_COMMON) {
   if(exportFileName == "") {
      exportFileName = GetHistoryFileName(exportFileNameFormat);
   }

   m_file = FileOpen(exportFileName, commonFlag | FILE_WRITE | FILE_CSV | FILE_ANSI, m_sep);

   if(m_file > 0) {
      switch(exportFormat) {
      case HEF_INI_FULL :
         WriteTitle();
         WriteAccountInfo();
         WriteParams();
         WriteTesterResults();
         WriteDealsHistory();
         break;
      case HEF_INI_DEALS:
         WriteDealsHistory();
         break;
      case HEF_CSV_DEALS:
         WriteDealsHistory(false);
         break;
      default:
         break;
      }

      FileClose(m_file);
   } else {
      Print("Can't open file [" + exportFileName + "]: ", GetLastError());
   }
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CExpertHistory::ToString(double value, int digits) {
   string s = DoubleToString(value, digits);
   if(m_decimalPoint != ".") {
      StringReplace(s, ".", m_decimalPoint);
   }
   return s;
}
//+------------------------------------------------------------------+
