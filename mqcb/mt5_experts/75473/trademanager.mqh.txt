//+------------------------------------------------------------------+
//|                                                 TradeManager.mqh |
//|                                      MMQ — Muhammad Minhas Qamar |
//|                                   www.mql5.com/en/articles/23693 |
//+------------------------------------------------------------------+
#property copyright "MMQ — Muhammad Minhas Qamar"
#property link      "https://www.mql5.com/en/articles/23693"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>
#include <RMA\RmaTypes.mqh>

//+------------------------------------------------------------------+
//| CTradeManager - everything the rules are not allowed to know.    |
//|                                                                  |
//|  The signal engine decides; this decides nothing. It turns an    |
//|  instruction into an order, keeps one position's worth of state, |
//|  and owns the three unglamorous problems that come with a live   |
//|  account: a close that the broker refuses, a position that       |
//|  disappears on its own stop, and a terminal that restarts while  |
//|  a trade is open.                                                |
//|                                                                  |
//|  Those are the reasons the tally is kept here rather than read   |
//|  back from the history at the end. A position can leave by four  |
//|  routes - a strategy close, a retried close, a stop, or an       |
//|  end-of-day flatten - and each of them has to arrive at the same |
//|  bookkeeping, which it does by going through one method.         |
//|                                                                  |
//|  Pip size is resolved from the symbol's digits rather than being |
//|  ten points by assumption. On a five-digit feed those agree; on  |
//|  a four-digit one the assumption reports every distance ten      |
//|  times too small, and stop distances along with it.              |
//+------------------------------------------------------------------+
class CTradeManager
  {
private:
   CTrade            m_trade;
   int               m_magic;
   double            m_lots;
   double            m_sl_pips;
   double            m_tp_pips;
   string            m_comment;
   double            m_pip;            // price distance one pip covers

//--- session filter
   bool              m_use_hours;
   int               m_start_hour;
   int               m_end_hour;
   bool              m_eod_close;

//--- the one position
   bool              m_open;
   int               m_type;           // 0 long, 1 short, -1 flat
   double            m_entry_price;
   datetime          m_entry_time;

//--- a close the broker would not take
   bool              m_pending;
   string            m_pending_reason;
   int               m_pending_tries;

//--- tally
   int               m_trades;
   int               m_wins;
   int               m_losses;
   double            m_net_pips;
   double            m_gross_win;
   double            m_gross_loss;

//--- last completed trade, for the display
   double            m_last_pips;
   double            m_last_price;
   string            m_last_reason;

//--- names of the terminal globals that carry state across a restart
   string            m_gv_state;
   string            m_gv_price;
   string            m_gv_time;
   string            m_gv_type;

   double            PipSize(void) const;
   ulong             FindTicket(void) const;
   void              RecordClose(const double price,const string reason,const int tries);
   bool              ClosingDeal(double &price) const;
   bool              EnoughMoney(const ENUM_ORDER_TYPE type,const double lots,
                                 const double price) const;

public:
                     CTradeManager(void);

   bool              Init(const int magic,const double lots,
                          const double sl_pips,const double tp_pips,
                          const string comment);
   void              SetSession(const bool use_hours,const int start_hour,
                                const int end_hour,const bool eod_close);

//--- session
   bool              SessionAllows(void) const;
   bool              AtSessionEnd(void) const;
   bool              ClosesAtSessionEnd(void) const { return m_eod_close; }

//--- position
   bool              Open(const ENUM_ORDER_TYPE type,const string reason);
   void              Close(const string reason);
   void              Sync(void);
   void              RetryPendingClose(void);

   bool              IsOpen(void)       const { return m_open;        }
   int               Type(void)         const { return m_type;        }
   double            EntryPrice(void)   const { return m_entry_price; }
   datetime          EntryTime(void)    const { return m_entry_time;  }
   bool              IsPending(void)    const { return m_pending;     }
   double            ProfitPips(void)   const;
   double            Pip(void)          const { return m_pip;         }

//--- state across a restart
   void              SaveState(const ENUM_RMA_CROSS_STATE state);
   bool              RestoreState(ENUM_RMA_CROSS_STATE &state);
   void              ClearState(void);

//--- tally
   int               Trades(void)       const { return m_trades;      }
   int               Wins(void)         const { return m_wins;        }
   int               Losses(void)       const { return m_losses;      }
   double            NetPips(void)      const { return m_net_pips;    }
   double            GrossWin(void)     const { return m_gross_win;   }
   double            GrossLoss(void)    const { return m_gross_loss;  }
   double            WinRate(void)      const;
   double            LastPips(void)     const { return m_last_pips;   }
   double            LastPrice(void)    const { return m_last_price;  }
   string            LastReason(void)   const { return m_last_reason; }
   double            Score(void)        const;
  };

//+------------------------------------------------------------------+
//| Construct flat, with nothing traded and nothing pending.         |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager(void)
  {
   m_magic          =0;
   m_lots           =0.0;
   m_sl_pips        =0.0;
   m_tp_pips        =0.0;
   m_comment        ="";
   m_pip            =0.0;

   m_use_hours      =false;
   m_start_hour     =0;
   m_end_hour       =24;
   m_eod_close      =false;

   m_open           =false;
   m_type           =-1;
   m_entry_price    =0.0;
   m_entry_time     =0;

   m_pending        =false;
   m_pending_reason ="";
   m_pending_tries  =0;

   m_trades         =0;
   m_wins           =0;
   m_losses         =0;
   m_net_pips       =0.0;
   m_gross_win      =0.0;
   m_gross_loss     =0.0;

   m_last_pips      =0.0;
   m_last_price     =0.0;
   m_last_reason    ="";
  }

//+------------------------------------------------------------------+
//| One pip, in price units, for the symbol on the chart.            |
//|  Three- and five-digit quotes carry a fractional pip in their    |
//|  last place; two- and four-digit ones do not.                    |
//+------------------------------------------------------------------+
double CTradeManager::PipSize(void) const
  {
   double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   int    digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   if(digits==3 || digits==5)
      return point*10.0;
   return point;
  }

//+------------------------------------------------------------------+
//| Configure the account side and adopt whatever is already open.   |
//+------------------------------------------------------------------+
bool CTradeManager::Init(const int magic,const double lots,
                         const double sl_pips,const double tp_pips,
                         const string comment)
  {
   if(lots<=0.0)
     {
      Print("CTradeManager: lot size has to be positive");
      return false;
     }

   m_magic   =magic;
   m_lots    =lots;
   m_sl_pips =sl_pips;
   m_tp_pips =tp_pips;
   m_comment =comment;
   m_pip     =PipSize();

   m_trade.SetExpertMagicNumber(magic);
   m_trade.SetDeviationInPoints(10);
   m_trade.SetTypeFilling(ORDER_FILLING_IOC);

   string prefix="RMA_"+_Symbol+"_"+IntegerToString(magic)+"_";
   m_gv_state=prefix+"CrossState";
   m_gv_price=prefix+"EntryPrice";
   m_gv_time =prefix+"EntryTime";
   m_gv_type =prefix+"PosType";
   return true;
  }

//+------------------------------------------------------------------+
//| Store the trading-hours policy.                                  |
//+------------------------------------------------------------------+
void CTradeManager::SetSession(const bool use_hours,const int start_hour,
                               const int end_hour,const bool eod_close)
  {
   m_use_hours  =use_hours;
   m_start_hour =start_hour;
   m_end_hour   =end_hour;
   m_eod_close  =eod_close;
  }

//+------------------------------------------------------------------+
//| Is the clock inside the trading window?                          |
//|  A start hour later than the end hour describes a session that   |
//|  runs through midnight, which is the usual case for anything     |
//|  anchored to a non-local exchange.                               |
//+------------------------------------------------------------------+
bool CTradeManager::SessionAllows(void) const
  {
   if(!m_use_hours)
      return true;

   MqlDateTime dt;
   TimeCurrent(dt);
   if(m_start_hour<m_end_hour)
      return (dt.hour>=m_start_hour && dt.hour<m_end_hour);
   return (dt.hour>=m_start_hour || dt.hour<m_end_hour);
  }

//+------------------------------------------------------------------+
//| Has the session reached the hour positions are flattened at?     |
//+------------------------------------------------------------------+
bool CTradeManager::AtSessionEnd(void) const
  {
   if(!m_use_hours || !m_eod_close)
      return false;

   MqlDateTime dt;
   TimeCurrent(dt);
   return (dt.hour==m_end_hour);
  }

//+------------------------------------------------------------------+
//| The ticket of this EA's position on this symbol, if any.         |
//+------------------------------------------------------------------+
ulong CTradeManager::FindTicket(void) const
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0)
         continue;
      if(PositionGetInteger(POSITION_MAGIC)==m_magic &&
         PositionGetString(POSITION_SYMBOL)==_Symbol)
         return ticket;
     }
   return 0;
  }

//+------------------------------------------------------------------+
//| Unrealised result of the open position, in pips.                 |
//+------------------------------------------------------------------+
double CTradeManager::ProfitPips(void) const
  {
   if(!m_open || m_entry_price==0.0 || m_pip<=0.0)
      return 0.0;

   if(m_type==0)
      return (SymbolInfoDouble(_Symbol,SYMBOL_BID)-m_entry_price)/m_pip;
   return (m_entry_price-SymbolInfoDouble(_Symbol,SYMBOL_ASK))/m_pip;
  }

//+------------------------------------------------------------------+
//| Fold one finished trade into the tally and go flat.              |
//|  Every exit route ends here, which is the only way the four of   |
//|  them can be guaranteed to agree on what a trade was.            |
//+------------------------------------------------------------------+
void CTradeManager::RecordClose(const double price,const string reason,const int tries)
  {
   double pips=(m_type==0)?(price-m_entry_price)/m_pip:(m_entry_price-price)/m_pip;

   m_trades++;
   m_net_pips+=pips;
   if(pips>0.0)
     {
      m_wins++;
      m_gross_win+=pips;
     }
   if(pips<=0.0)
     {
      m_losses++;
      m_gross_loss+=pips;
     }

   m_last_pips  =pips;
   m_last_price =price;
   m_last_reason=reason;

   string retried=(tries>0)?StringFormat(" after %d retries",tries):"";
   PrintFormat("[RMA] closed %s at %s%s | %.1f pips | %s",
               (m_type==0)?"long":"short",
               DoubleToString(price,(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)),
               retried,pips,reason);

   m_pending       =false;
   m_pending_reason="";
   m_pending_tries =0;

   m_open        =false;
   m_type        =-1;
   m_entry_price =0.0;
   ClearState();
  }

//+------------------------------------------------------------------+
//| Can the account afford this order at all?                        |
//|  The market validator runs every EA on a one-unit balance, so a  |
//|  fixed lot that is fine on a real account asks for more margin   |
//|  than exists and the order is refused for "No money". Rather     |
//|  than fire it and fail, the margin is priced first with          |
//|  OrderCalcMargin and checked against free margin; a bar that     |
//|  cannot be afforded is simply skipped, which is the same answer  |
//|  the rest of the EA already gives to a bar it will not trade.    |
//+------------------------------------------------------------------+
bool CTradeManager::EnoughMoney(const ENUM_ORDER_TYPE type,const double lots,
                                const double price) const
  {
   double margin=0.0;
   if(!OrderCalcMargin(type,_Symbol,lots,price,margin))
     {
      PrintFormat("[RMA] margin check failed: error %d",GetLastError());
      return false;
     }

   double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(margin>free)
     {
      PrintFormat("[RMA] skipping %s %.2f %s: needs %.2f margin, %.2f free",
                  (type==ORDER_TYPE_BUY)?"buy":"sell",lots,_Symbol,margin,free);
      return false;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Open a position and adopt it.                                    |
//+------------------------------------------------------------------+
bool CTradeManager::Open(const ENUM_ORDER_TYPE type,const string reason)
  {
   if(m_open)
     {
      Print("[RMA] open refused: a position is already running");
      return false;
     }

   int    digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double min_lot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double max_lot=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step   =SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   double lots=MathMin(MathMax(m_lots,min_lot),max_lot);
   if(step>0.0)
      lots=MathFloor(lots/step)*step;
   lots=NormalizeDouble(lots,2);

   bool   buy=(type==ORDER_TYPE_BUY);
   double price=buy?SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID);

   if(!EnoughMoney(type,lots,price))
      return false;

   double sl=0.0;
   double tp=0.0;

   if(m_sl_pips>0.0)
     {
      double away=m_sl_pips*m_pip;
      sl=NormalizeDouble(buy?(price-away):(price+away),digits);
     }
   if(m_tp_pips>0.0)
     {
      double away=m_tp_pips*m_pip;
      tp=NormalizeDouble(buy?(price+away):(price-away),digits);
     }

   bool sent=buy?m_trade.Buy(lots,_Symbol,price,sl,tp,m_comment)
             :m_trade.Sell(lots,_Symbol,price,sl,tp,m_comment);

   if(!sent)
     {
      PrintFormat("[RMA] open failed: %d - %s",
                  m_trade.ResultRetcode(),m_trade.ResultRetcodeDescription());
      return false;
     }

//--- the requested price is what the order asked for; the result
//--- price is what it got, and a trade recorded against the request
//--- would carry the slippage into every pip figure that follows.
   double filled=m_trade.ResultPrice();
   m_open        =true;
   m_type        =buy?0:1;
   m_entry_price =(filled>0.0)?filled:price;
   m_entry_time  =TimeCurrent();

   PrintFormat("[RMA] opened %s at %s | %.2f lots | %s",
               buy?"long":"short",DoubleToString(m_entry_price,digits),lots,reason);
   return true;
  }

//+------------------------------------------------------------------+
//| Close the position, or remember that the broker would not.       |
//+------------------------------------------------------------------+
void CTradeManager::Close(const string reason)
  {
   if(!m_open)
      return;

   ulong ticket=FindTicket();
   if(ticket==0)
     {
      //--- gone already; Sync will find the deal and book it.
      return;
     }

   double quote=(m_type==0)?SymbolInfoDouble(_Symbol,SYMBOL_BID)
                :SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   if(!m_trade.PositionClose(ticket))
     {
      m_pending       =true;
      m_pending_reason=reason;
      m_pending_tries++;
      PrintFormat("[RMA] close refused: %d - %s | will retry",
                  m_trade.ResultRetcode(),m_trade.ResultRetcodeDescription());
      return;
     }

   double filled=m_trade.ResultPrice();
   RecordClose((filled>0.0)?filled:quote,reason,0);
  }

//+------------------------------------------------------------------+
//| Try again, on every tick, until the market takes the close.      |
//|  Quietly: a market that is shut will refuse thousands of times   |
//|  before it opens, and a journal full of that is a journal nobody |
//|  reads. One line every ten attempts is enough to show it is      |
//|  still trying.                                                   |
//+------------------------------------------------------------------+
void CTradeManager::RetryPendingClose(void)
  {
   if(!m_pending)
      return;
   if(!m_open)
     {
      m_pending=false;
      return;
     }

   ulong ticket=FindTicket();
   if(ticket==0)
      return;

   double quote=(m_type==0)?SymbolInfoDouble(_Symbol,SYMBOL_BID)
                :SymbolInfoDouble(_Symbol,SYMBOL_ASK);

   if(!m_trade.PositionClose(ticket))
     {
      m_pending_tries++;
      if((m_pending_tries%10)==0)
         PrintFormat("[RMA] still trying to close (%d attempts) | %s",
                     m_pending_tries,m_pending_reason);
      return;
     }

   double filled=m_trade.ResultPrice();
   RecordClose((filled>0.0)?filled:quote,m_pending_reason,m_pending_tries);
  }

//+------------------------------------------------------------------+
//| Price of the deal that took this EA's last position out.         |
//+------------------------------------------------------------------+
bool CTradeManager::ClosingDeal(double &price) const
  {
   if(!HistorySelect(m_entry_time,TimeCurrent()))
      return false;

   for(int i=HistoryDealsTotal()-1;i>=0;i--)
     {
      ulong deal=HistoryDealGetTicket(i);
      if(deal==0)
         continue;
      if(HistoryDealGetInteger(deal,DEAL_MAGIC)!=m_magic)
         continue;
      if(HistoryDealGetString(deal,DEAL_SYMBOL)!=_Symbol)
         continue;
      if(HistoryDealGetInteger(deal,DEAL_ENTRY)!=DEAL_ENTRY_OUT)
         continue;

      price=HistoryDealGetDouble(deal,DEAL_PRICE);
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//| Reconcile with the terminal before anything is decided.          |
//|  A stop or a take profit closes the position without asking, so  |
//|  the first thing each bar has to establish is whether the trade  |
//|  the EA thinks it holds still exists.                            |
//+------------------------------------------------------------------+
void CTradeManager::Sync(void)
  {
   ulong ticket=FindTicket();

   if(ticket>0)
     {
      m_open=true;
      m_type=(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)?0:1;
      if(m_entry_price==0.0)
        {
         m_entry_price=PositionGetDouble(POSITION_PRICE_OPEN);
         m_entry_time =(datetime)PositionGetInteger(POSITION_TIME);
        }
      return;
     }

   if(!m_open)
      return;

//--- it left without us. Price it from the deal rather than from the
//--- current quote, which may be several bars away by now.
   double price=(m_type==0)?SymbolInfoDouble(_Symbol,SYMBOL_BID)
                :SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double dealt=0.0;
   if(ClosingDeal(dealt))
      price=dealt;

   RecordClose(price,"closed by stop, target or hand",0);
  }

//+------------------------------------------------------------------+
//| Write the position's leg where a restart can find it again.      |
//+------------------------------------------------------------------+
void CTradeManager::SaveState(const ENUM_RMA_CROSS_STATE state)
  {
   GlobalVariableSet(m_gv_state,(double)state);
   GlobalVariableSet(m_gv_price,m_entry_price);
   GlobalVariableSet(m_gv_time,(double)m_entry_time);
   GlobalVariableSet(m_gv_type,(double)m_type);
  }

//+------------------------------------------------------------------+
//| Adopt a position that outlived the last run.                     |
//|  The position itself is the authority on whether there is        |
//|  anything to restore; the globals only supply the leg, which the |
//|  terminal has no way of knowing. Finding globals with no         |
//|  position behind them means the trade closed while the EA was    |
//|  not running, so they are thrown away rather than trusted.       |
//+------------------------------------------------------------------+
bool CTradeManager::RestoreState(ENUM_RMA_CROSS_STATE &state)
  {
   ulong ticket=FindTicket();
   if(ticket==0)
     {
      ClearState();
      return false;
     }

   m_open        =true;
   m_type        =(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)?0:1;
   m_entry_price =PositionGetDouble(POSITION_PRICE_OPEN);
   m_entry_time  =(datetime)PositionGetInteger(POSITION_TIME);

   if(!GlobalVariableCheck(m_gv_state))
     {
      state=RMA_STATE_NONE;
      return true;
     }

   state=(ENUM_RMA_CROSS_STATE)(int)GlobalVariableGet(m_gv_state);
   if(GlobalVariableCheck(m_gv_price))
      m_entry_price=GlobalVariableGet(m_gv_price);
   if(GlobalVariableCheck(m_gv_time))
      m_entry_time=(datetime)GlobalVariableGet(m_gv_time);

   PrintFormat("[RMA] resumed a %s opened at %s",
               (m_type==0)?"long":"short",
               DoubleToString(m_entry_price,(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)));
   return true;
  }

//+------------------------------------------------------------------+
//| Forget the saved leg.                                            |
//+------------------------------------------------------------------+
void CTradeManager::ClearState(void)
  {
   GlobalVariableDel(m_gv_state);
   GlobalVariableDel(m_gv_price);
   GlobalVariableDel(m_gv_time);
   GlobalVariableDel(m_gv_type);
  }

//+------------------------------------------------------------------+
//| Share of closed trades that made money, as a percentage.         |
//+------------------------------------------------------------------+
double CTradeManager::WinRate(void) const
  {
   if(m_trades<=0)
      return 0.0;
   return (double)m_wins/(double)m_trades*100.0;
  }

//+------------------------------------------------------------------+
//| Optimisation score: net pips, weighted by sample and accuracy.   |
//|  The square root is there so that a run of four hundred trades   |
//|  outranks one of forty at the same net result, without letting   |
//|  trade count dominate the number outright.                       |
//+------------------------------------------------------------------+
double CTradeManager::Score(void) const
  {
   if(m_trades<10)
      return 0.0;
   return m_net_pips*MathSqrt((double)m_trades)*(WinRate()/100.0);
  }
//+------------------------------------------------------------------+
