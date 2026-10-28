//+------------------------------------------------------------------+
//|                       VR---Overturn(barabashkakvn's edition).mq5 |
//|                              Copyright 2017, Trading-go Project. |
//|                                             http://trading-go.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, Trading-go Project."
#property link      "http://trading-go.ru"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
#property description " Principle trade with Martingale: Received TakeProfit opened an initial lot in that direction"
#property description " Received a stop loss opened reverse order with increased lot"
#property description " +------------------------------------------------------------------+ "
#property description " the Principle of trade in AntiMartingale: Received TakeProfit opened with increased lot in that direction"
#property description " Received a stop loss opened reverse order with an initial lot"

#define BUY 0 // create predetermined variable with a value of 0
#define SEL 1 // create predetermined variable with a value of 1
//+------------------------------------------------------------------+
//| Enum type of the first position                                  |
//+------------------------------------------------------------------+
enum ENUM_FIRST_POSITION
  {
   Buy=0,   // Buy
   Sell=1,  // Sell
  };
//+------------------------------------------------------------------+
//| Enum type of trading                                             |
//+------------------------------------------------------------------+
enum ENUM_TYPE_TRAIDING
  {
   Martingale=0,        // Martingale
   AntiMartingale=1,    // AntiMartingale
  };
//--- input parameters      
input ENUM_FIRST_POSITION  StartPoz       = Buy;         // start position: Buy or Sell                               
input ENUM_TYPE_TRAIDING   TypTrade       = Martingale;  // type of trade: Martingale or AntiMartingale
input double               InpLots        = 0.1;         // set the base lot
input ushort               InpStopLoss    = 30;          // set the value of stop loss (in pips)
input ushort               InpTakeProfit  = 90;          // set the value of TakeProfit(in pips)
input double               MultiplierLot  = 1.6;         // set the value of the multiplier lots
input ulong                m_magic        = 39164216;    // set the value MagicNumber
input bool                 InpAllMagic    = false;       // all magic; true -> all MagicNumber
ulong                      m_slippage=30;          // set the value of slippage
//--- initialize global variables
bool           m_need_modify=false;
bool           m_OnTradeTransaction=false;
long           m_last_closed_position_type=-1;
double         m_last_closed_position_volume=0.0;
double         m_last_closed_position_profit=0.0;
double         MLot=0.0,ALot=0.0;
//---
double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   Comment("");            // will be emptied technical comment
   if(TypTrade==Martingale)// if the Advisor works in a mode Martingale
     {
      MLot=MultiplierLot;  // MLot assign the value of the multiplier lot
      ALot=1;              // АLot assign a value of 1
     }
   else
     {
      MLot=1;              // МLot assign a value 1
      ALot=MultiplierLot;  // АLot assign the value of the multiplier lot
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLoss=InpStopLoss*m_adjusted_point;
   ExtTakeProfit=InpTakeProfit*m_adjusted_point;
//---
   LastClosedPosition(m_last_closed_position_type,m_last_closed_position_volume,m_last_closed_position_profit);
//---
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
void OnTick()
  {
//---
   if(m_need_modify)
      if(ModifyPosition())
        {
         m_need_modify=false;
         return;
        }
//---
   if(!SearchPositions() && !m_OnTradeTransaction) // check if is there positions Advisor, if not Buy's and no Sell's
     {
      if(!RefreshRates())
         return;
      //--- if the Advisor works in a mode of martingale and profit greater than zero
      //--- then the lot will equal start for a position in the same direction
      if(m_last_closed_position_profit>0.0 && TypTrade==Martingale)
         m_last_closed_position_volume=InpLots;

      //--- if the Advisor works in mode antimartingale and profit is less than zero
      //--- then the lot will equal start for a position in the same direction
      if(m_last_closed_position_profit<0 && TypTrade==AntiMartingale)
         m_last_closed_position_volume=InpLots;

      //--- for the first positions
      if(m_last_closed_position_type==-1 && m_last_closed_position_volume==0.0 && m_last_closed_position_profit==0.0)
        {
         //--- then you need to pen the first position
         if(OpenPosition(StartPoz,InpLots)) // if the first position is opened
           {
            m_need_modify=true;// ModifyPosition it and in case of a successful modification will give management terminal
            return;
           }
        }
      //--- if the last closed position was a buy and its profit is greater than zero
      if((ENUM_POSITION_TYPE)m_last_closed_position_type==POSITION_TYPE_BUY && m_last_closed_position_volume!=0.0 && m_last_closed_position_profit>0.0)
        {
         //--- open a buy a lot depending on the type of TypTrade
         double lot=LotCheck(m_last_closed_position_volume*ALot);
         if(lot!=0.0)
            if(OpenPosition(Buy,lot))
              {
               m_need_modify=true;// ModifyPosition it and in case of a successful modification will give management terminal
               return;
              }
        }
      //--- if the last closed position was a buy and its profit is less than zero
      if((ENUM_POSITION_TYPE)m_last_closed_position_type==POSITION_TYPE_BUY && m_last_closed_position_volume!=0.0 && m_last_closed_position_profit<0.0)
        {
         //--- open a sell a lot depending on the type of TypTrade
         double lot=LotCheck(m_last_closed_position_volume*MLot);
         if(lot!=0.0)
            if(OpenPosition(Sell,lot))
              {
               m_need_modify=true;// ModifyPosition it and in case of a successful modification will give management terminal
               return;
              }
        }
      //--- if the last closed positions was to sell and its profit is greater than zero
      if((ENUM_POSITION_TYPE)m_last_closed_position_type==POSITION_TYPE_SELL && m_last_closed_position_volume!=0.0 && m_last_closed_position_profit>0.0)
        {
         //---  open a sell a lot depending on the type of TypTrade
         double lot=LotCheck(m_last_closed_position_volume*ALot);
         if(lot!=0.0)
            if(OpenPosition(Sell,lot))
              {
               m_need_modify=true;// ModifyPosition it and in case of a successful modification will give management terminal
               return;
              }
        }
      //---  if the last closed positions was for sale and profit less than zero
      if((ENUM_POSITION_TYPE)m_last_closed_position_type==POSITION_TYPE_SELL && m_last_closed_position_volume!=0.0 && m_last_closed_position_profit<0.0)
        {
         //--- open a buy a lot depending on the type of TypTrade
         double lot=LotCheck(m_last_closed_position_volume*MLot);
         if(lot!=0.0)
            if(OpenPosition(Buy,lot))
              {
               m_need_modify=true;// ModifyPosition it and in case of a successful modification will give management terminal
               return;
              }
        }
     }
  }
//+------------------------------------------------------------------+
//| Search positions                                                 |
//+------------------------------------------------------------------+
bool SearchPositions()
  {
   bool result=false;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name()) // check the symbol, if our then continue on
            if((!InpAllMagic && m_position.Magic()==m_magic) || InpAllMagic) // check the part of the MagicNumber
               return(true);
   return(result); // if we didn't find the desired positions to quit the function with a failure
  }
//+------------------------------------------------------------------+
//| Last closed position                                             |
//+------------------------------------------------------------------+
void LastClosedPosition(long &pos_type,double &volume,double &profit) // function takes the link type, lot, and profit for their processing
  {
//--- request trade history
   datetime to_date=TimeCurrent()+60*60*24;
   datetime from_date=TimeCurrent()-5*60*60*24;
   HistorySelect(from_date,to_date);
//---
   uint     total=HistoryDealsTotal();
   ulong    ticket=0;
   long     position_id=0;
//---
   long     tim=0; // time value will be emptied
//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      //--- try to get deals ticket 
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         //--- get deals properties 
         long deal_time          =HistoryDealGetInteger(ticket,DEAL_TIME);
         long deal_type          =HistoryDealGetInteger(ticket,DEAL_TYPE);
         long deal_entry         =HistoryDealGetInteger(ticket,DEAL_ENTRY);
         long deal_magic         =HistoryDealGetInteger(ticket,DEAL_MAGIC);
         double deal_volume      =HistoryDealGetDouble(ticket,DEAL_VOLUME);
         double deal_commission  =HistoryDealGetDouble(ticket,DEAL_COMMISSION);
         double deal_swap        =HistoryDealGetDouble(ticket,DEAL_SWAP);
         double deal_profit      =HistoryDealGetDouble(ticket,DEAL_PROFIT);
         string deal_symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);

         if(deal_symbol==m_symbol.Name())// check the symbol, if our then continue on
            if((!InpAllMagic && deal_magic==m_magic) || InpAllMagic) // check the part of the MagicNumber
               if(deal_entry==DEAL_ENTRY_OUT)
                  if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
                     if(deal_time>tim)
                       {
                        tim=deal_time;
                        pos_type=(deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_SELL:POSITION_TYPE_BUY;
                        volume=deal_volume;
                        profit=deal_commission+deal_swap+deal_profit;
                       }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//| Open position                                                    |
//+------------------------------------------------------------------+
bool OpenPosition(ENUM_FIRST_POSITION type_pos,const double volume) // Function takes the type of position and the desired lot
  {
   if(IsTradeAllowed()) // check whether the quotes flow and can we open the order
     {
      if(type_pos==Buy)
         return(OpenBuy(0.0,0.0,volume));
      else if(type_pos==Sell)
         return(OpenSell(0.0,0.0,volume));
     }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Modify position                                                  |
//+------------------------------------------------------------------+
bool ModifyPosition() // function takes no values and processes ticket  that we remember in function OpenPosition()
  {
   if(!RefreshRates())
      return(false);
   double sl=0.0,tp=0.0; // will be emptied variables for stop loss and take profit
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name()) // check the symbol, if our then continue on
            if((!InpAllMagic && m_position.Magic()==m_magic) || InpAllMagic) // check the part of the MagicNumber
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY) // gets the position type
                 {
                  if(m_position.StopLoss()==0.0 && m_position.TakeProfit()==0.0)
                    {
                     sl=m_symbol.Bid()-ExtStopLoss;
                     tp=m_symbol.Ask()+ExtTakeProfit;
                     if(!m_trade.PositionModify(m_position.Ticket(),m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp)))
                       {
                        Print("Modify BUY, ticket #",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                        return(false);
                       }
                     else
                        return(true);
                    }
                 }
               else if(m_position.PositionType()==POSITION_TYPE_SELL) // gets the position type
                 {
                  if(m_position.StopLoss()==0.0 && m_position.TakeProfit()==0.0)
                    {
                     sl=m_symbol.Ask()+ExtStopLoss;
                     tp=m_symbol.Bid()-ExtTakeProfit;
                     if(!m_trade.PositionModify(m_position.Ticket(),m_symbol.NormalizePrice(sl),m_symbol.NormalizePrice(tp)))
                       {
                        Print("Modify BUY, ticket #",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                        return(false);
                       }
                     else
                        return(true);
                    }
                 }
              }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   double res=0.0;
   int losses=0.0;
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
      if(deal_symbol==m_symbol.Name())// check the symbol, if our then continue on
         if((!InpAllMagic && deal_magic==m_magic) || InpAllMagic) // check the part of the MagicNumber
           {
            if(deal_entry==DEAL_ENTRY_OUT)
              {
               if(deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL)
                 {
                  m_last_closed_position_type=(deal_type==DEAL_TYPE_BUY)?POSITION_TYPE_SELL:POSITION_TYPE_BUY;
                  m_last_closed_position_volume=deal_volume;
                  m_last_closed_position_profit=deal_commission+deal_swap+deal_profit;
                  m_OnTradeTransaction=false;
                  int d=0;
                 }
              }
            else if(deal_entry==DEAL_ENTRY_IN)
               m_OnTradeTransaction=true;
           }
     }
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the correctness of the order volume                        |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
// double min_volume=m_symbol.LotsMin();
   double min_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN);
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }

//--- maximal allowed volume of trade operations
// double max_volume=m_symbol.LotsMax();
   double max_volume=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX);
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }

//--- get minimal step of volume changing
// double volume_step=m_symbol.LotsStep();
   double volume_step=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);

   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                     volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double LotCheck(double lots)
  {
//--- calculate maximum volume
   double volume=NormalizeDouble(lots,2);
   double stepvol=m_symbol.LotsStep();
   if(stepvol>0.0)
      volume=stepvol*MathFloor(volume/stepvol);
//---
   double minvol=m_symbol.LotsMin();
   if(volume<minvol)
      volume=0.0;
//---
   double maxvol=m_symbol.LotsMax();
   if(volume>maxvol)
      volume=maxvol;
   return(volume);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double sl,double tp,const double volume)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),volume,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=volume)
        {
         if(m_trade.Buy(volume,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double sl,double tp,const double volume)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),volume,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=volume)
        {
         if(m_trade.Sell(volume,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResult(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result: "+trade.ResultRetcodeDescription());
   Print("deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("current bid price: "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("current ask price: "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("broker comment: "+trade.ResultComment());
//DebugBreak();
  }
//+------------------------------------------------------------------+
