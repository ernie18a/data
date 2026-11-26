//+------------------------------------------------------------------+
//|          Get_Rich_or_Die_Trying_GBP(barabashkakvn's edition).mq5 |
//|                                                     Carlos Gomes |
//+------------------------------------------------------------------+
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Expert\Money\MoneyFixedMargin.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CExpertMoney   *m_money;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//CMoneyFixedMargin m_money_fixed_margin;
//CMoneyFixedRisk m_money_fixed_risk;
//+------------------------------------------------------------------+
//| Enum Money Managemen                                             |
//+------------------------------------------------------------------+
enum ENUM_MM
  {
   fixed_margin   = 0,     // fixed margin
   fixed_risk     = 1,     // fixed risk
  };
//--- input parameters
input string   InpString_0="Trading";           // Trading
input ushort   InpStopLoss       = 100;         // Stop Loss (in pips)
input ushort   InpTakeProfit     = 100;         // Take Profit (in pips)
input ushort   InpTakeProfit2    = 40;          // Take Profit 2 (in pips)
input ushort   InpTrailingStop   = 30;          // Trailing Stop (in pips)
input ushort   InpTrailingStep   = 5;           // Trailing Step (in pips)
input string   InpString_1="Money Management";  // Money Management
input ENUM_MM  InpMM             = fixed_margin;// Money Management
input double   InpRisk           = 5;           // Risk for a deal (in percent)
input string   InpString_2="Another...";        // Another...
input uchar    InpCountBars      = 18;          // Count bars
input double   InpAdditionalHour = 2;           // Additional hour
input double   InpMaxPositions   = 1000;        // Max positions 
//---
ulong          m_magic=635643260;               // magic number
ulong          m_slippage=30;                   // slippage
double         ExtStopLoss=0;
double         ExtTakeProfit=0;
double         ExtTakeProfit2=0;
double         ExtTrailingStop=0;
double         ExtTrailingStep=0;
long           m_last_time_open=0;
double         m_adjusted_point;                // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Bars(Symbol(),Period())<InpCountBars+5)
     {
      Print("It is less bars than ",IntegerToString(InpCountBars+5));
      return(INIT_FAILED);
     }
   if(InpCountBars==0)
     {
      Print("\"Count bars\" can't be equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_symbol.Name(Symbol());                     // sets symbol name
   RefreshRates();
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
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
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
   m_last_time_open=0;
//---
   switch(InpMM)
     {
      case  fixed_margin:
         m_money=new CMoneyFixedMargin;
         break;
      default:
         m_money=new CMoneyFixedRisk;
         break;
     }
   if(m_money==NULL)
     {
      Print("Money Management Object Pointers is NULL");
      return(INIT_FAILED);
     }
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpRisk);
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
//--- trade not more often than once a minute
   if((long)TimeCurrent()-m_last_time_open<61)
      return;

   int up=0,down=0;
   if(!OpenCloseCount(up,down,InpCountBars))
      return;
//---
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total++;

            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>=ExtTakeProfit2)
                  m_trade.PositionClose(m_position.Ticket());

               else if(InpTrailingStop>0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                     if(m_position.StopLoss()<m_position.PriceCurrent()-ExtTrailingStop)
                       {
                        if(m_trade.PositionModify(m_position.Ticket(),
                           m_position.PriceCurrent()-ExtTrailingStop,
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>=ExtTakeProfit2)
                  m_trade.PositionClose(m_position.Ticket());

               else if(InpTrailingStop>0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop)
                     if(m_position.StopLoss()>(m_position.PriceCurrent()+ExtTrailingStop+ExtTrailingStep) || m_position.StopLoss()==0)
                        if(m_trade.PositionModify(m_position.Ticket(),
                           m_position.PriceCurrent()+ExtTrailingStop,
                           m_position.TakeProfit()))
                           Print("Modify ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
           }

   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);

   if(total<InpMaxPositions)
     {
      if(up>down && (22+InpAdditionalHour==str1.hour || 19+InpAdditionalHour==str1.hour) && str1.min<5)
        {
         if(RefreshRates())
            OpenBuy(m_symbol.Ask()-ExtStopLoss,m_symbol.Ask()+ExtTakeProfit);
        }
      else if(up<down && (22+InpAdditionalHour==str1.hour || 19+InpAdditionalHour==str1.hour) && str1.min<5)
        {
         if(RefreshRates())
            OpenSell(m_symbol.Bid()+ExtStopLoss,m_symbol.Bid()-ExtTakeProfit);
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
      return(false);
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
bool IsFillingTypeAllowed(string symbol,int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
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
      long     deal_entry        =0;
      double   deal_profit       =0.0;
      double   deal_volume       =0.0;
      string   deal_symbol       ="";
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_time         =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);
         deal_volume=HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason=HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
        }
      else
         return;

      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_IN)
            m_last_time_open=deal_time;
     }
  }
//+------------------------------------------------------------------+
//| Open Close Count                                                 |
//+------------------------------------------------------------------+
bool OpenCloseCount(int &bulls,int &bears,int count)
  {
   bool result=true;

   bulls=0;bears=0;

   double Close[];
   double Open[];
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true);

   int copy_close=CopyClose(m_symbol.Name(),PERIOD_M1,0,count,Close);
   int copy_open=CopyOpen(m_symbol.Name(),PERIOD_M1,0,count,Open);
   if(copy_close!=count || copy_open!=count)
      return(false);
   for(int i=0;i<count;i++)
     {
      if(Open[i]>Close[i])
         bulls++;
      else if(Open[i]<Close[i])
         bears++;
     }
//---
   return(result);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
//| Open Sell position                                               |
//+------------------------------------------------------------------+
void OpenSell(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
              {
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
           }
         else
           {
            Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
//---
  }
//+------------------------------------------------------------------+
