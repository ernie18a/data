//+------------------------------------------------------------------+
//|                                              CPartialClosing.mqh |
//|                              Copyright © 2016, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//| Class CPartialClosing.                                           |
//| Appointment: Class trade operations - Partial closing.           |
//|              Derives from class CTrade.                          |
//+------------------------------------------------------------------+
class CPartialClosing : public CTrade
  {
public:
                     CPartialClosing();
                    ~CPartialClosing();
   bool              PositionClose(const ulong ticket,const ulong deviation=ULONG_MAX,const double partial_volume=0);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPartialClosing::CPartialClosing()
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPartialClosing::~CPartialClosing()
  {
  }
//+------------------------------------------------------------------+
//| Close specified opened position                                  |
//+------------------------------------------------------------------+
bool CPartialClosing::PositionClose(const ulong ticket,const ulong deviation,const double partial_volume=0)
  {
//--- check stopped
   if(IsStopped(__FUNCTION__))
      return(false);
//--- check position existence
   if(!PositionSelectByTicket(ticket))
      return(false);
   string symbol=PositionGetString(POSITION_SYMBOL);
//--- clean
   ClearStructures();
//--- check
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
     {
      //--- prepare request for close BUY position
      m_request.type =ORDER_TYPE_SELL;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_BID);
     }
   else
     {
      //--- prepare request for close SELL position
      m_request.type =ORDER_TYPE_BUY;
      m_request.price=SymbolInfoDouble(symbol,SYMBOL_ASK);
     }
//--- setting request
   m_request.action   =TRADE_ACTION_DEAL;
   m_request.position =ticket;
   m_request.symbol   =symbol;
   m_request.volume   =(partial_volume==0) ? PositionGetDouble(POSITION_VOLUME) : partial_volume;
   m_request.magic    =m_magic;
   m_request.deviation=(deviation==ULONG_MAX) ? m_deviation : deviation;
//--- close position
   PrintFormat("PositionClose #%I64d %s %.2f",ticket,EnumToString((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)),m_request.volume);
   return(OrderSend(m_request,m_result));
  }
//+------------------------------------------------------------------+
