//+------------------------------------------------------------------+
//| Trade Transaction Trace Logger MT5                               |
//| Read-only order/deal/position lifecycle diagnostics              |
//+------------------------------------------------------------------+
#property copyright "Usamah41"
#property version   "1.00"
#property strict
#property description "Read-only OnTradeTransaction trace logger for MT5 EA debugging"
#property description "Writes local CSV and Journal records; sends no trade requests"

#include "TradeTransactionTraceCore.mqh"

ulong trace_sequence=0;

input group "Trace scope"
input ENUM_TT_SYMBOL_SCOPE InpSymbolScope=TT_ALL_SYMBOLS;
input long InpMagicFilter=-1;

input group "Local output"
input string InpCSVFileName="TradeTransactionTrace.csv";
input bool InpUseCommonFolder=true;
input bool InpPrintJournal=true;

int OnInit()
  {
   if(InpMagicFilter<-1 || InpCSVFileName=="")
     {
      Print("TT_TRACE initialization failed: invalid magic filter or empty CSV filename");
      return INIT_PARAMETERS_INCORRECT;
     }
   PrintFormat("TT_TRACE initialized scope=%s magic=%I64d file=%s common=%s read_only=true",
               InpSymbolScope==TT_ALL_SYMBOLS?"ALL_SYMBOLS":"CURRENT_SYMBOL",InpMagicFilter,
               InpCSVFileName,InpUseCommonFolder?"true":"false");
   return INIT_SUCCEEDED;
  }

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   long magic;
   string symbol;
   if(!TTMatchesFilters(trans,request,InpSymbolScope,_Symbol,InpMagicFilter,magic,symbol)) return;
   trace_sequence++;
   bool written=TTWriteTransaction(InpCSVFileName,InpUseCommonFolder,trace_sequence,trans,request,result,magic,symbol);
   if(InpPrintJournal)
      PrintFormat("TT_TRACE seq=%I64u type=%s symbol=%s magic=%I64d order=%I64u deal=%I64u position=%I64u retcode=%u csv=%s",
                  trace_sequence,EnumToString(trans.type),symbol,magic,trans.order,trans.deal,trans.position,
                  result.retcode,written?"true":"false");
  }
