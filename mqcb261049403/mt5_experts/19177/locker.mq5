//+------------------------------------------------------------------+
//|                              Locker(barabashkakvn's edition).mq5 |
//|                     Copyright © 2008, Демёхин Виталий Евгеньевич |
//|                                             vitalya_1983@list.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2008, Демёхин Виталий Евгеньевич"
#property link      "vitalya_1983@list.ru"
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
//---
input double   NeedProfit  = 0.001;          // Profit percentage
input double   StartLot    = 0.5;            // Starting lot
input double   StepLot     = 0.2;            // Secondary lots
input ushort   InpStep     = 5;              // Steps between Locking
input bool     InpHelpMe   = true;           // Help me
//---
ulong          m_magic=15489;                // magic number
ulong          m_slippage=30;                // slippage
//---
string text="Locker.mq4";
double ChekPoint,Profit1,Profit2,HighBuy,LowSell;
bool mode_buy,mode_sell,Stop=false;
//---
double         ExtStep=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(m_account.MarginMode()!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   if(StartLot<=0.0 || StepLot<=0.0)
     {
      Print("The lot can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   string err_text="";
   if(!CheckVolumeValue(StartLot,err_text))
     {
      Print(err_text);
      return(INIT_PARAMETERS_INCORRECT);
     }
   err_text="";
   if(!CheckVolumeValue(StepLot,err_text))
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

   ExtStep=InpStep*m_adjusted_point;
//---
   double buy_profit=0;
   double sell_profit=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            double pos_full_profit=m_position.Commission()+m_position.Swap()+m_position.Profit();
            if(m_position.PositionType()==POSITION_TYPE_BUY)
               buy_profit+=pos_full_profit;

            if(m_position.PositionType()==POSITION_TYPE_SELL)
               sell_profit+=pos_full_profit;
           }
////----
//   for(i=OrdersTotal();i>=1;i--) //Сюда мы втыкае индикатора
//     {
//      OrderSelect(i-1,SELECT_BY_POS,MODE_TRADES);
//      if(OrderType()==OP_SELL && OrderSymbol()==Symbol())
//        {
//         sell_profit=sell_profit+OrderProfit();
//         StartLot=OrderLots();
//         StepLot=NormalizeDouble(StartLot/1.2,2);
//        }
//      if(OrderType()==OP_BUY && OrderSymbol()==Symbol())
//        {
//         buy_profit=buy_profit+OrderProfit();
//         StartLot=OrderLots();
//         StepLot=NormalizeDouble(StartLot/1.2,2);
//        }
   if(sell_profit<buy_profit)
      mode_buy=true;
   if(sell_profit>buy_profit)
      mode_sell=true;
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
   if((InpHelpMe && !Stop)/* || !InpHelpMe*/)
     {
      int total_positions=0;
      double current_profit=0.0;

      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name())
              {
               total_positions++;
               current_profit+=m_position.Commission()+m_position.Swap()+m_position.Profit();
              }

      if(total_positions==0 || mode_buy || mode_sell)
        {
         if(total_positions==0 && (!mode_buy && !mode_sell))
           {
            if(!RefreshRates())
               return;
            OpenBuy(StartLot,0.0,0.0);
            return;
           }
         if(mode_buy && !mode_sell)
           {
            if(!RefreshRates())
               return;
            if(OpenBuy(StepLot,0.0,0.0))
              {
               mode_buy=false;
               return;
              }
           }
         if(!mode_buy && mode_sell)
           {
            if(!RefreshRates())
               return;
            if(OpenSell(StepLot,0.0,0.0))
              {
               mode_sell=false;
               return;
              }
           }
        }
      if(total_positions>0)
        {
         if(total_positions>=8) // Trying to close positions
           {
            ulong ticket_buy=ULONG_MAX;
            ulong ticket_sell=ULONG_MAX;
            for(int i=0;i<PositionsTotal();i++) // ATTENTION! Here, specially began a detour with "0"
               if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
                  if(m_position.Symbol()==m_symbol.Name())
                    {
                     if(m_position.PositionType()==POSITION_TYPE_BUY && ticket_buy==ULONG_MAX)
                        ticket_buy=m_position.Ticket();

                     if(m_position.PositionType()==POSITION_TYPE_SELL && ticket_sell==ULONG_MAX)
                        ticket_sell=m_position.Ticket();
                    }
            if(ticket_buy!=ULONG_MAX && ticket_sell!=ULONG_MAX)
               m_trade.PositionCloseBy(ticket_buy,ticket_sell);
            //---
            return;
           }
         //---
         if(current_profit>=NeedProfit*m_account.Balance()) // We achieved the desired profit
           {
            CloseAllPositions();
            if(InpHelpMe)
               Stop=false;
           }
         if(current_profit<-1.0*NeedProfit*m_account.Balance()) // If there is a loss, we lock
           {
            double last_price=GetLastPositionsPriceOpen();
            if(last_price==0.0)
               return;
            if(!RefreshRates())
               return;
            if(m_symbol.Ask()>last_price+ExtStep)
               OpenSell(StepLot,0.0,0.0);
            else if(m_symbol.Bid()<last_price-ExtStep)
               OpenBuy(StepLot,0.0,0.0);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool RefreshRates()
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
bool OpenBuy(double lot,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Buy(lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //PrintResult(m_trade,m_symbol);
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
bool OpenSell(double lot,double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=lot)
        {
         if(m_trade.Sell(lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
               return(false);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               //PrintResult(m_trade,m_symbol);
               return(true);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            //PrintResult(m_trade,m_symbol);
            return(false);
           }
        }
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Returns the price of opening of the last position                |
//+------------------------------------------------------------------+
double GetLastPositionsPriceOpen()
  {
//--- the "total-1" element is the last open position
   double last_price=0.0;

   int total=PositionsTotal();
   for(int i=total-1;i>=0;i--)
     {
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            last_price=m_position.PriceOpen();
            break;
           }
     }
//---
   return(last_price);
  }
//+------------------------------------------------------------------+
