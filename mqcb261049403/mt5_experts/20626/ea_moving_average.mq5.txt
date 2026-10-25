//+------------------------------------------------------------------+
//|                   EA Moving Average(barabashkakvn's edition).mq5 |
//+------------------------------------------------------------------+
#property link      "http://automated-trading.narod.ru/"
#property version   "1.000"
//---
#include <Trade\Trade.mqh>
CTrade ExtTrade;
//--- input parameters
input double               MaximumRisk          = 0.02;        // Maximum Risk in percentage
input double               DecreaseFactor       = 3;           // Descrease factor
input int                  MovingPeriodBuyOpen  = 30;          // MA Buy Open: period
input int                  MovingShiftBuyOpen   = 3;           // MA Buy Open: shift
input ENUM_MA_METHOD       MovingMethodBuyOpen  = MODE_EMA;    // MA Buy Open: method
input ENUM_APPLIED_PRICE   MovingPriceBuyOpen   = PRICE_CLOSE; // MA Buy Open: price
input int                  MovingPeriodBuyClose = 14;          // MA Buy Close: period
input int                  MovingShiftBuyClose  = 3;           // MA Buy Close: shift
input ENUM_MA_METHOD       MovingMethodBuyClose = MODE_EMA;    // MA Buy Close: method
input ENUM_APPLIED_PRICE   MovingPriceBuyClose  = PRICE_CLOSE; // MA Buy Close: price
input int                  MovingPeriodSellOpen = 30;          // MA Sell Open: period
input int                  MovingShiftSellOpen  = 0;           // MA Sell Open: shift
input ENUM_MA_METHOD       MovingMethodSellOpen = MODE_EMA;    // MA Sell Open: method
input ENUM_APPLIED_PRICE   MovingPriceSellOpen  = PRICE_CLOSE; // MA Sell Open: price
input int                  MovingPeriodSellClose= 20;          // MA Sell Close: period
input int                  MovingShiftSellClose = 2;           // MA Sell Close: shift
input ENUM_MA_METHOD       MovingMethodSellClose= MODE_EMA;    // MA Sell Close: method
input ENUM_APPLIED_PRICE   MovingPriceSellClose = PRICE_CLOSE; // MA Sell Close: price
input bool                 UseBuy               = true;        // Use Buy positions
input bool                 UseSell              = true;        // Use Sell positions
input bool                 ConsiderPriceLastOut = true;        // Consider Price Last Out
input ulong                m_magic              = 15489;       // magic number
//---
int    ExtHandleBuyOpen=0;
int    ExtHandleBuyClose=0;
int    ExtHandleSellOpen=0;
int    ExtHandleSellClose=0;
bool   ExtHedging=false;

double m_price_last_deal_out=0.0;

#define MA_MAGIC m_magic
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//--- prepare trade class to control positions if hedging mode is active
   ExtHedging=((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
   ExtTrade.SetExpertMagicNumber(MA_MAGIC);
   ExtTrade.SetMarginMode();
   ExtTrade.SetTypeFillingBySymbol(Symbol());
//--- Moving Average indicator Buy Open
   ExtHandleBuyOpen=iMA(Symbol(),Period(),MovingPeriodBuyOpen,MovingShiftBuyOpen,MovingMethodBuyOpen,MovingPriceBuyOpen);
   if(ExtHandleBuyOpen==INVALID_HANDLE)
     {
      printf("Error creating MA indicator \"Buy Open\"");
      return(INIT_FAILED);
     }
//--- Moving Average indicator Buy Close
   ExtHandleBuyClose=iMA(Symbol(),Period(),MovingPeriodBuyClose,MovingShiftBuyClose,MovingMethodBuyClose,MovingPriceBuyClose);
   if(ExtHandleBuyClose==INVALID_HANDLE)
     {
      printf("Error creating MA indicator \"Buy Close\"");
      return(INIT_FAILED);
     }
//--- Moving Average indicator Sell Open
   ExtHandleSellOpen=iMA(Symbol(),Period(),MovingPeriodSellOpen,MovingShiftSellOpen,MovingMethodSellOpen,MovingPriceSellOpen);
   if(ExtHandleSellOpen==INVALID_HANDLE)
     {
      printf("Error creating MA indicator \"Sell Open\"");
      return(INIT_FAILED);
     }
//--- Moving Average indicator Sell Close
   ExtHandleSellClose=iMA(Symbol(),Period(),MovingPeriodSellClose,MovingShiftSellClose,MovingMethodSellClose,MovingPriceSellClose);
   if(ExtHandleSellClose==INVALID_HANDLE)
     {
      printf("Error creating MA indicator \"Sell Close\"");
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
  {
//---
   if(SelectPosition())
      CheckForClose();
   else
      CheckForOpen();
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      long     deal_type         =-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);
        }
      else
         return;
      if(deal_reason!=-1)
         int d=0;
      if(deal_symbol==Symbol() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
            if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
               m_price_last_deal_out=deal_price;
     }
  }
//+------------------------------------------------------------------+
//| Calculate optimal lot size                                       |
//+------------------------------------------------------------------+
double TradeSizeOptimized(void)
  {
   double price=0.0;
   double margin=0.0;
//--- select lot size
   if(!SymbolInfoDouble(Symbol(),SYMBOL_ASK,price))
      return(0.0);
   if(!OrderCalcMargin(ORDER_TYPE_BUY,Symbol(),1.0,price,margin))
      return(0.0);
   if(margin<=0.0)
      return(0.0);

   double lot=NormalizeDouble(AccountInfoDouble(ACCOUNT_MARGIN_FREE)*MaximumRisk/margin,2);
//--- calculate number of losses orders without a break
   if(DecreaseFactor>0)
     {
      //--- select history for access
      HistorySelect(0,TimeCurrent());
      //---
      int    orders=HistoryDealsTotal();  // total history deals
      int    losses=0;                    // number of losses orders without a break

      for(int i=orders-1;i>=0;i--)
        {
         ulong ticket=HistoryDealGetTicket(i);
         if(ticket==0)
           {
            Print("HistoryDealGetTicket failed, no trade history");
            break;
           }
         //--- check symbol
         if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=Symbol())
            continue;
         //--- check Expert Magic number
         if(HistoryDealGetInteger(ticket,DEAL_MAGIC)!=MA_MAGIC)
            continue;
         //--- check profit
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         if(profit>0.0)
            break;
         if(profit<0.0)
            losses++;
        }
      //---
      if(losses>1)
         lot=NormalizeDouble(lot-lot*losses/DecreaseFactor,1);
     }
//--- normalize and check limits
   double stepvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   lot=stepvol*NormalizeDouble(lot/stepvol,0);

   double minvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(lot<minvol)
      lot=minvol;

   double maxvol=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(lot>maxvol)
      lot=maxvol;
//--- return trading volume
   return(lot);
  }
//+------------------------------------------------------------------+
//| Check for open position conditions                               |
//+------------------------------------------------------------------+
void CheckForOpen(void)
  {
   MqlRates rt[2];
//--- go trading only for first ticks of new bar
   if(CopyRates(Symbol(),Period(),0,2,rt)!=2)
     {
      Print("CopyRates of ",Symbol()," failed, no history");
      return;
     }
   if(rt[1].tick_volume>1)
      return;
   MqlTick tick;
   if(!SymbolInfoTick(Symbol(),tick))
      return;
   if(tick.ask==0.0 || tick.bid==0.0)
      return;
//--- check signals
   ENUM_ORDER_TYPE signal=WRONG_VALUE;
//--- get current Moving Average Buy Open
   double   ma_buy_open[1];
   if(CopyBuffer(ExtHandleBuyOpen,0,0,1,ma_buy_open)!=1)
     {
      Print("CopyBuffer from iMA \"Buy Open\" failed, no data");
      return;
     }
   if(UseBuy)
     {
      if(((ConsiderPriceLastOut && ((m_price_last_deal_out!=0.0 && m_price_last_deal_out>=tick.ask) || m_price_last_deal_out==0.0)) || !ConsiderPriceLastOut) && rt[0].open<ma_buy_open[0] && rt[0].close>ma_buy_open[0])
        {
         signal=ORDER_TYPE_BUY;  // buy conditions
        }
     }
//--- get current Moving Average Sell Open
   double   ma_sell_open[1];
   if(CopyBuffer(ExtHandleSellOpen,0,0,1,ma_sell_open)!=1)
     {
      Print("CopyBuffer from iMA \"Sell Open\" failed, no data");
      return;
     }
   if(UseSell)
     {
      if(((ConsiderPriceLastOut && ((m_price_last_deal_out!=0.0 && m_price_last_deal_out<=tick.bid) || m_price_last_deal_out==0.0)) || !ConsiderPriceLastOut) && rt[0].open>ma_sell_open[0] && rt[0].close<ma_sell_open[0])
        {
         signal=ORDER_TYPE_SELL;    // sell conditions
        }
     }
//--- additional checking
   if(signal!=WRONG_VALUE)
     {
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && Bars(Symbol(),Period())>100)
         ExtTrade.PositionOpen(Symbol(),signal,TradeSizeOptimized(),(signal==ORDER_TYPE_SELL) ? tick.bid:tick.ask,0,0);
     }
//---
  }
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
void CheckForClose(void)
  {
   MqlRates rt[2];
//--- go trading only for first ticks of new bar
   if(CopyRates(Symbol(),Period(),0,2,rt)!=2)
     {
      Print("CopyRates of ",Symbol()," failed, no history");
      return;
     }
   if(rt[1].tick_volume>1)
      return;
//--- get current Moving Average Buy Close
   double   ma_buy_close[1];
   if(CopyBuffer(ExtHandleBuyClose,0,0,1,ma_buy_close)!=1)
     {
      Print("CopyBuffer from iMA \"Buy Close\"failed, no data");
      return;
     }
//--- get current Moving Average Sell Close
   double   ma_sell_close[1];
   if(CopyBuffer(ExtHandleSellClose,0,0,1,ma_sell_close)!=1)
     {
      Print("CopyBuffer from iMA \"Sell Close\"failed, no data");
      return;
     }
//--- positions already selected before
   bool signal=false;
   long type=PositionGetInteger(POSITION_TYPE);

   if(type==(long)POSITION_TYPE_BUY && rt[0].open>ma_buy_close[0] && rt[0].close<ma_buy_close[0])
      signal=true;
   if(type==(long)POSITION_TYPE_SELL && rt[0].open<ma_sell_close[0] && rt[0].close>ma_sell_close[0])
      signal=true;
//--- additional checking
   if(signal)
     {
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) && Bars(Symbol(),Period())>100)
         ExtTrade.PositionClose(Symbol(),3);
     }
//---
  }
//+------------------------------------------------------------------+
//| Position select depending on netting or hedging                  |
//+------------------------------------------------------------------+
bool SelectPosition()
  {
   bool res=false;
//--- check position in Hedging mode
   if(ExtHedging)
     {
      uint total=PositionsTotal();
      for(uint i=0; i<total; i++)
        {
         string position_symbol=PositionGetSymbol(i);
         if(Symbol()==position_symbol && MA_MAGIC==PositionGetInteger(POSITION_MAGIC))
           {
            res=true;
            break;
           }
        }
     }
//--- check position in Netting mode
   else
     {
      if(!PositionSelect(Symbol()))
         return(false);
      else
         return(PositionGetInteger(POSITION_MAGIC)==MA_MAGIC); //---check Magic number
     }
//--- result for Hedging mode
   return(res);
  }
//+------------------------------------------------------------------+
