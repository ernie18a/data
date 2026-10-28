#ifndef TRADE_TRANSACTION_TRACE_CORE_MQH
#define TRADE_TRANSACTION_TRACE_CORE_MQH

enum ENUM_TT_SYMBOL_SCOPE
  {
   TT_CURRENT_SYMBOL=0,
   TT_ALL_SYMBOLS=1
  };

string TTResolveSymbol(const MqlTradeTransaction &trans,const MqlTradeRequest &request)
  {
   if(trans.symbol!="") return trans.symbol;
   if(request.symbol!="") return request.symbol;
   if(trans.order>0)
     {
      if(OrderSelect(trans.order)) return OrderGetString(ORDER_SYMBOL);
      if(HistoryOrderSelect(trans.order)) return HistoryOrderGetString(trans.order,ORDER_SYMBOL);
     }
   if(trans.deal>0 && HistoryDealSelect(trans.deal))
      return HistoryDealGetString(trans.deal,DEAL_SYMBOL);
   if(trans.position>0 && PositionSelectByTicket(trans.position))
      return PositionGetString(POSITION_SYMBOL);
   return "";
  }

long TTResolveMagic(const MqlTradeTransaction &trans,const MqlTradeRequest &request)
  {
   if(trans.type==TRADE_TRANSACTION_REQUEST) return (long)request.magic;
   if(trans.order>0)
     {
      if(OrderSelect(trans.order)) return OrderGetInteger(ORDER_MAGIC);
      if(HistoryOrderSelect(trans.order)) return HistoryOrderGetInteger(trans.order,ORDER_MAGIC);
     }
   if(trans.deal>0 && HistoryDealSelect(trans.deal))
      return HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
   if(trans.position>0 && PositionSelectByTicket(trans.position))
      return PositionGetInteger(POSITION_MAGIC);
   return -1;
  }

bool TTMatchesFilters(const MqlTradeTransaction &trans,
                      const MqlTradeRequest &request,
                      const ENUM_TT_SYMBOL_SCOPE scope,
                      const string chart_symbol,
                      const long magic_filter,
                      long &resolved_magic,
                      string &resolved_symbol)
  {
   resolved_symbol=TTResolveSymbol(trans,request);
   resolved_magic=TTResolveMagic(trans,request);
   if(scope==TT_CURRENT_SYMBOL && resolved_symbol!=chart_symbol) return false;
   if(magic_filter>=0 && resolved_magic!=magic_filter) return false;
   return true;
  }

int TTFileFlags(const bool common_folder)
  {
   int flags=FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI;
   if(common_folder) flags|=FILE_COMMON;
   return flags;
  }

bool TTWriteTransaction(const string filename,
                        const bool common_folder,
                        const ulong sequence,
                        const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result,
                        const long resolved_magic,
                        const string resolved_symbol)
  {
   ResetLastError();
   int handle=FileOpen(filename,TTFileFlags(common_folder),',');
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("TT_TRACE CSV open failed error=%d",GetLastError());
      return false;
     }
   if(FileSize(handle)==0)
      FileWrite(handle,"time","sequence","trans_type","symbol","magic","order","deal","position",
                "order_type","order_state","deal_type","price","price_trigger","sl","tp","volume",
                "request_action","request_order","request_price","request_sl","request_tp","request_comment",
                "result_retcode","result_order","result_deal","result_comment");
   FileSeek(handle,0,SEEK_END);
   int price_digits=(int)SymbolInfoInteger(resolved_symbol,SYMBOL_DIGITS);
   if(price_digits<0 || price_digits>8) price_digits=_Digits;
   uint written=FileWrite(handle,TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),sequence,EnumToString(trans.type),
                          resolved_symbol,resolved_magic,trans.order,trans.deal,trans.position,
                          EnumToString(trans.order_type),EnumToString(trans.order_state),EnumToString(trans.deal_type),
                          DoubleToString(trans.price,price_digits),DoubleToString(trans.price_trigger,price_digits),
                          DoubleToString(trans.price_sl,price_digits),DoubleToString(trans.price_tp,price_digits),
                          DoubleToString(trans.volume,8),EnumToString(request.action),request.order,
                          DoubleToString(request.price,price_digits),DoubleToString(request.sl,price_digits),
                          DoubleToString(request.tp,price_digits),request.comment,result.retcode,result.order,
                          result.deal,result.comment);
   FileClose(handle);
   if(written==0)
     {
      PrintFormat("TT_TRACE CSV write failed error=%d",GetLastError());
      return false;
     }
   return true;
  }

#endif
