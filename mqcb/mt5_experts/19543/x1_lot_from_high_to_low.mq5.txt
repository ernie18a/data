//+------------------------------------------------------------------+
//|             x1 lot from high to low(barabashkakvn's edition).mq5 |
//|                                                            ЕВГЕН |
//|                                                  z_e_e_d@mail.ru |
//+------------------------------------------------------------------+
#property copyright "ЕВГЕН"
#property link      "z_e_e_d@mail.ru"
#property version   "1.001"
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
input uchar    InpLots           = 10;       // Lots (x Lots minimum)
input ushort   InpStopLoss       = 50;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 150;      // Take Profit (in pips)
input double   InpMinProfit      = 27.0;     // Minimum profit (in money)
input ulong    m_magic=15489;                // magic number
//---
ulong          m_slippage=30;                // slippage
double         m_lots=0.0;
double         m_balance=0.0;

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
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
   m_lots=LotCheck(m_symbol.LotsMin()*(double)InpLots);
   if(!CheckVolumeValue(m_lots,err_text))
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

   m_balance=0.0;
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
   if(m_balance==0.0)
      m_balance=m_account.Balance();
   if(m_lots<m_symbol.LotsMin())
      m_lots=LotCheck(m_symbol.LotsMin()*(double)InpLots);
   int count_buys=0;
   int count_sells=0;
   CalculatePositions(count_buys,count_sells);
//--- open new
   if(count_buys==0 && count_sells==0)
     {
      if(!RefreshRates())
         return;
      double sl=(InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Ask()-ExtStopLoss);
      double tp=(InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit);
      bool open_buy=m_trade.Buy(m_lots,m_symbol.Name(),m_symbol.Ask(),sl,tp);

      sl=(InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Bid()+ExtStopLoss);
      tp=(InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeProfit);
      bool open_sell=m_trade.Sell(m_lots,m_symbol.Name(),m_symbol.Bid(),sl,tp);

      if(open_buy && open_sell)
         m_lots=LotCheck(m_symbol.LotsMin()*(double)(InpLots-1));
     }
   else if(count_buys==1 && count_sells==0)
     {
      if(!RefreshRates())
         return;
      double sl=(InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Bid()+ExtStopLoss);
      double tp=(InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(m_symbol.Bid()-ExtTakeProfit);
      bool open_sell=m_trade.Sell(m_lots,m_symbol.Name(),m_symbol.Bid(),sl,tp);

      if(open_sell)
         m_lots=LotCheck(m_symbol.LotsMin()*(double)(InpLots-1));
     }
   else if(count_buys==0 && count_sells==1)
     {
      if(!RefreshRates())
         return;
      double sl=(InpStopLoss==0)?0.0:m_symbol.NormalizePrice(m_symbol.Ask()-ExtStopLoss);
      double tp=(InpTakeProfit==0)?0.0:m_symbol.NormalizePrice(m_symbol.Ask()+ExtTakeProfit);
      bool open_buy=m_trade.Buy(m_lots,m_symbol.Name(),m_symbol.Ask(),sl,tp);

      if(open_buy)
         m_lots=LotCheck(m_symbol.LotsMin()*(double)(InpLots-1));
     }
   else if(count_buys>1 || count_sells>1)
     {
      CloseAllPositions();
      m_balance=0.0;
      m_lots=0.0;
      return;
     }
//---
   if(m_account.Equity()-m_balance>=InpMinProfit)
     {
      CloseAllPositions();
      m_balance=0.0;
      m_lots=0.0;
     }
//---
   return;
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
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys,int &count_sells)
  {
   count_buys=0.0;
   count_sells=0.0;

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
