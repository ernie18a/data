//+------------------------------------------------------------------+
//|                         OverHedgeV2(barabashkakvn's edition).mq5 |
//|                                                 Copyright © 2015 |
//|                                 http://www.strategtbuilderfx.com |
//| Written by MrPip (Robert Hill) for kmrunner                      |
//| 3/7/06  Added check of direction for first trade Buy or Sell     |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005"
#property link      "http://www.strategtbuilderfx.com"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//--- input parameters
input double   InpLots           = 0.1;      // Start Lots
input double   Base              = 1.2;      // Base (Lot=Start Lots * MathPow(Base,Number of open positions))
input bool     ShutdownGrid      = false;    // Shutdown Grid
input ushort   TunnelWidth       = 20;       // Tunnel width (in pips)
input ushort   ProfitTarget      = 10;       // Total Profit Target (in pips)
input ushort   MinProfitTarget   = 5;        // Minimal Profit Target (in pips)
input int      EMAShortPeriod    = 8;        // MA Short: averaging period
input int      EMALongPeriod     = 21;       // MA Long: averaging period
input ushort   MinDistanceMA     = 5;        // Minimum distance between MA's to determine the trend (in pips)
input ulong    m_magic           = 4676220;  // magic number
//---
ulong          m_slippage=10;                // slippage

double         ExtTunnelWidth=0.0;
double         ExtProfitTarget=0.0;
double         ExtMinProfitTarget=0.0;
double         ExtMinDistanceMA=0.0;

int            handle_iMA_Short;             // variable for storing the handle of the iMA indicator 
int            handle_iMA_Long;              // variable for storing the handle of the iMA indicator 

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//---
double TunnelSize=0.0;
string setup;
double startBuyRate,startSellRate;
int currentOpen;
int NumBuyTrades,NumSellTrades;              // Number of buy and sell trades
bool myWantLongs;
double lotMM;
double Profit;
bool OK2Buy,OK2Sell,FirstDirSell;

bool bln_trading_is_stopped=false;
bool bln_close_all=false;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

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
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtTunnelWidth    = TunnelWidth     * m_adjusted_point;
   ExtProfitTarget   = ProfitTarget    * m_adjusted_point;
   ExtMinProfitTarget= MinProfitTarget * m_adjusted_point;
   ExtMinDistanceMA  = MinDistanceMA   * m_adjusted_point;
//--- create handle of the indicator iMA
   handle_iMA_Short=iMA(m_symbol.Name(),Period(),EMAShortPeriod,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Short==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA_Long=iMA(m_symbol.Name(),Period(),EMALongPeriod,0,MODE_EMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA_Long==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   bln_trading_is_stopped=false;
   bln_close_all=false;
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
   if(bln_trading_is_stopped)
      return;
//--- test if we want to shutdown
   if(ShutdownGrid) // close all positions. then exit.. there is nothing more to do
     {
      if(IsPositionExists())
         CloseAllPositions();
      else
         bln_trading_is_stopped=true;
      return;
     }
   if(bln_close_all)
     {
      if(IsPositionExists())
         CloseAllPositions();
      else
         bln_close_all=false;
      return;
     }
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;
//---
   if(!RefreshRates())
      return;
   TunnelSize=2.0*(m_symbol.Ask()-m_symbol.Bid())+ExtTunnelWidth;
//--- check for new trade cycle. First check if profit target is reached
//--- if yes then there will be no open positions. So a new trade cycle will begin
   if(CheckProfit())
     {
      bln_close_all=true;
      return;
     }
//---
   int count_buys=0;
   int count_sells=0;
   CalculateAllPositions(count_buys,count_sells);
   if(count_buys+count_sells==0)
     {
      int check_direction=CheckDirection();
      //--- Start trades based on confirmation direction, was daily
      if(check_direction==0)
         return;
      if(check_direction==1)
        {
         OK2Buy=true;
         OK2Sell=false;
         FirstDirSell=false;
        }
      if(check_direction==-1)
        {
         OK2Buy=false;
         OK2Sell=true;
         FirstDirSell=true;
        }
      if(OK2Buy)
        {
         startBuyRate=m_symbol.Bid();
         startSellRate=m_symbol.Bid()-TunnelSize;
        }
      if(OK2Sell)
        {
         startSellRate=m_symbol.Bid();
         startBuyRate=m_symbol.Bid()+TunnelSize;
        }
     }
   else
     {
      OK2Buy=true;
      OK2Sell=true;
     }
//--- determine how many lots for next trade based on current number of open positions
   lotMM=InpLots*MathPow(Base,count_buys+count_sells);
   if(lotMM==0.0)
      return;
   lotMM=LotCheck(lotMM);
   if(lotMM==0.0)
      return;
//--- determine if next trade should be long or short based on current number of open positions
   myWantLongs=true;
   if(count_buys+count_sells>2)
      myWantLongs=false;
   if(FirstDirSell)
      myWantLongs=!myWantLongs;   // added to match starting trade direction
   if(myWantLongs)
     {
      if(m_symbol.Ask()>=startBuyRate)
         OpenBuy(lotMM,0.0,0.0);
     }
   else
     {
      if(m_symbol.Ask()<=startSellRate)
         OpenSell(lotMM,0.0,0.0);
     }
//---
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

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
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| CheckProfit                                                      |
//+------------------------------------------------------------------+
bool CheckProfit()
  {
   double tota_profit=0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if((m_position.PriceCurrent()>m_position.PriceOpen()) &&
                  (m_position.PriceCurrent()-m_position.PriceOpen()<ExtMinProfitTarget))
                  return(false);
               else
                  tota_profit+=m_position.PriceCurrent()-m_position.PriceOpen();
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if((m_position.PriceOpen()>m_position.PriceCurrent()) &&
                  (m_position.PriceOpen()-m_position.PriceCurrent()<ExtMinProfitTarget))
                  return(false);
               else
                  tota_profit+=m_position.PriceOpen()-m_position.PriceCurrent();
              }
           }
//---
   if(tota_profit>=ExtProfitTarget)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Calculate all positions Buy and Sell                             |
//+------------------------------------------------------------------+
void CalculateAllPositions(int &count_buys,int &count_sells)
  {
   count_buys=0;
   count_sells=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               count_buys++;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               count_sells++;
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| CheckDirection                                                   |
//+------------------------------------------------------------------+
int CheckDirection()
  {
   double ma_Short  = iMAGet(handle_iMA_Short,1);
   double ma_Long   = iMAGet(handle_iMA_Long,1);

   if(ma_Short-ma_Long>ExtMinDistanceMA)
      return(1); // UP
   if(ma_Long-ma_Short>ExtMinDistanceMA)
      return(-1); // DOWN
//---
   return(0);
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(const double lot,double sl,double tp)
  {
//sl=m_symbol.NormalizePrice(sl);
//tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,m_symbol.Name(),m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< lot (",DoubleToString(lot,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(const double lot,double sl,double tp)
  {
//sl=m_symbol.NormalizePrice(sl);
//tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,m_symbol.Name(),m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print(__FUNCTION__,", #1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
            else
              {
               Print(__FUNCTION__,", #2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResultTrade(m_trade,m_symbol);
              }
           }
         else
           {
            Print(__FUNCTION__,", #3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResultTrade(m_trade,m_symbol);
           }
        }
      else
        {
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               "< lot (",DoubleToString(lot,2),")");
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
     }
//---
  }
//+------------------------------------------------------------------+
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void PrintResultTrade(CTrade &trade,CSymbolInfo &symbol)
  {
   Print("Code of request result: "+IntegerToString(trade.ResultRetcode()));
   Print("code of request result as a string: "+trade.ResultRetcodeDescription());
   Print("Deal ticket: "+IntegerToString(trade.ResultDeal()));
   Print("Order ticket: "+IntegerToString(trade.ResultOrder()));
   Print("Volume of deal or order: "+DoubleToString(trade.ResultVolume(),2));
   Print("Price, confirmed by broker: "+DoubleToString(trade.ResultPrice(),symbol.Digits()));
   Print("Current bid price: "+DoubleToString(symbol.Bid(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultBid(),symbol.Digits()));
   Print("Current ask price: "+DoubleToString(symbol.Ask(),symbol.Digits())+" (the requote): "+DoubleToString(trade.ResultAsk(),symbol.Digits()));
   Print("Broker comment: "+trade.ResultComment());
  }
//+------------------------------------------------------------------+
