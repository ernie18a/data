//+------------------------------------------------------------------+
//|                    Deep Drawdown MA(barabashkakvn's edition).mq5 |
//|                                Copyright 2015, Vladimir V. Tkach |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Vladimir V. Tkach"
#property description "EA trades two MA crossing"
#property description "Noloss function with maximum deals limitation"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//---
//+------------------------------------------------------------------+
//| Struct Yes No                                                    |
//+------------------------------------------------------------------+
enum SYesNo
  {
   yes   = 0,  // yes
   no    = 1,  // no 
  };
//--- input parameters
input double   InpLots           = 0.1;      // Lots
input int      InpMaxPositions   = 5;        // Maximum positions
input SYesNo   InpLosses         = no;       // Close losses
//---
input int                  InpFast_ma_period       = 10;          // MA Fast: averaging period 
input int                  InpFast_ma_shift        = 3;           // MA Fast: horizontal shift 
input ENUM_APPLIED_PRICE   InpFast_applied_price   = PRICE_CLOSE; // MA Fast: type of price
input int                  InpSlow_ma_period       = 30;          // MA Slow: averaging period 
input int                  InpSlow_ma_shift        = 0;           // MA Slow: horizontal shift 
input ENUM_APPLIED_PRICE   InpSlow_applied_price   = PRICE_CLOSE; // MA Slow: type of price
input ENUM_MA_METHOD       InpFastSlow_ma_method   = MODE_SMA;    // MA Fast and Slow: smoothing type 
input ulong                m_magic                 = 458089;      // magic number
//---
ulong          m_slippage=10;                // slippage

int            handle_iMA_Fast;              // variable for storing the handle of the iMA indicator
int            handle_iMA_Slow;              // variable for storing the handle of the iMA indicator 
double         MA_Fast_1=0.0;
double         MA_Slow_1=0.0;
ENUM_POSITION_TYPE last_open_pos=-1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   string err_text="";
   if(!CheckVolumeValue(InpLots,err_text))
     {
      Print(__FUNCTION__,", ERROR: ",err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);
//--- create handle of the indicator iMA
   handle_iMA_Fast=iMA(m_symbol.Name(),Period(),InpFast_ma_period,InpFast_ma_shift,InpFastSlow_ma_method,InpFast_applied_price);
//--- if the handle is not created 
   if(handle_iMA_Fast==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator (Fast) for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Slow=iMA(m_symbol.Name(),Period(),InpSlow_ma_period,InpSlow_ma_shift,InpFastSlow_ma_method,InpSlow_applied_price);
//--- if the handle is not created 
   if(handle_iMA_Slow==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator (Slow) for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   MA_Fast_1=0.0;
   MA_Slow_1=0.0;
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
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   if(!RefreshRates())
     {
      PrevBars=0;
      return;
     }

   MA_Fast_1=iMAGet(handle_iMA_Fast,1);
   MA_Slow_1=iMAGet(handle_iMA_Slow,1);

   CheckForCloseMA();

   int positions=CalculateAllPositions();
   if(positions==0)
      CheckForOpen();
   else
     {
      if(positions<InpMaxPositions && InpLosses==no)
         CheckForOpen();
     }
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
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
        {
         if(deal_entry==DEAL_ENTRY_IN)
           {
            if(deal_type==DEAL_TYPE_BUY)
               last_open_pos=POSITION_TYPE_BUY;
            else if(deal_type==DEAL_TYPE_SELL)
               last_open_pos=POSITION_TYPE_SELL;
           }
         else
            last_open_pos=-1;
        }
     }
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
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=m_symbol.Name();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0; // datetime "0" -> D'1970.01.01 00:00:00'
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0)
      time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int handle_iMA,const int index)
  {
   double MA[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMA,0,index,1,MA)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MA[0]);
  }
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
void CheckForCloseMA()
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && MA_Fast_1<MA_Slow_1)
              {
               if(InpLosses==yes)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
               else
                 {
                  if(m_position.Commission()+m_position.Swap()+m_position.Profit()>0)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                  else if(m_position.Profit()<0 && m_position.TakeProfit()==0.0)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_position.StopLoss(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()+m_symbol.Spread()*m_symbol.Point())))
                        Print("Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }
            //---
            if(m_position.PositionType()==POSITION_TYPE_SELL && MA_Fast_1<MA_Slow_1)
              {
               if(InpLosses==yes)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                 }
               else
                 {
                  if(m_position.Commission()+m_position.Swap()+m_position.Profit()>0)
                    {
                     m_trade.PositionClose(m_position.Ticket());
                     continue;
                    }
                  else if(m_position.Profit()<0 && m_position.TakeProfit()==0.0)
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_position.StopLoss(),
                        m_symbol.NormalizePrice(m_position.PriceOpen()-m_symbol.Spread()*m_symbol.Point())))
                        Print("Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//| Calculate all positions                                          |
//+------------------------------------------------------------------+
int CalculateAllPositions()
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
void CheckForOpen()
  {
//--- buy conditions
   if(MA_Fast_1>MA_Slow_1 && last_open_pos!=POSITION_TYPE_BUY)
     {
      m_trade.Buy(InpLots,m_symbol.Name());
      return;
     }
//--- sell conditions
   if(MA_Fast_1<MA_Slow_1 && last_open_pos!=POSITION_TYPE_SELL)
     {
      m_trade.Sell(InpLots,m_symbol.Name());
      return;
     }
  }
//+------------------------------------------------------------------+
