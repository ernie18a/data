//+------------------------------------------------------------------+
//|                                                         Ivan.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.014"
#property description "EA Inav - is better than Ilan!"
//---
enum ENUM_FIND
  {
   MODE_LOW=0, // MODE_LOW 
   MODE_HIGH=1,// MODE_HIGH 
  };
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CMoneyFixedMargin m_money;
//--- input parameters
input bool     InpAveraging                  = true;  // Use averaging
input ushort   InpStopLossMaPeriod           = 36;    // Stop Loss (in pips) ma_period
input double   InpPercentRisk                = 10;    // % risk (from 1 to 90)
input bool     InpZeroBar                    = true;  // Zero bar or first bar
input double   Inp_CCI100_ReverseLevel       = 100.0; // Reverse Level CCI(100) (absolute values from 0 to 150)
input double   Inp_CCI100_GlobalSignalLevel  = 100.0; // Global Signal Level CCI(100) (absolute values from 0 to 150)
input ushort   InpMinDistancePriceStopLoss   = 50;    // Minimum distance from the price to stop loss (in pips)
input ushort   InpTrailingStep               = 10;    // Trailing Step (in pips)
input ushort   InpBreakEven                  = 5;     // Break-even ("0" - not use Break-even)
input double   InpCoefProtectionProfit       = 1.5;   // Coefficient of protection Profit
sinput string  InpStopLossComment            = "sl";  // Stop Loss Comment
sinput ulong   m_magic=3306518;// magic number
//---
int            handle_iCCI_100;              // variable for storing the handle of the iCCI indicator
int            handle_iCCI_13;               // variable for storing the handle of the iCCI indicator 
int            handle_iMA;                   // variable for storing the handle of the iMA indicator 
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
bool           bGlobalSellSignal = false;    // true -> You need to Sell!
bool           bGlobalBuySignal  = false;    // true -> You need to Buy!
bool           bCloseAll         = false;    // true -> You need to close the "Buy" and "Sell"!
//---
ulong          m_slippage=30;                // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   if(Inp_CCI100_ReverseLevel<0.0)
     {
      Print("The \"Inp_CCI100_ReverseLevel\" parameter can't be less than zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(Inp_CCI100_GlobalSignalLevel<0.0)
     {
      Print("The \"Inp_CCI100_GlobalSignalLevel\" parameter can't be less than zero");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetDeviationInPoints(m_slippage);
//---
   m_symbol.Name(Symbol());                  // sets symbol name
   RefreshRates();
   m_symbol.Refresh();
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
//---
   if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
      return(INIT_FAILED);
   m_money.Percent(InpPercentRisk); // 10% risk
//--- create handle of the indicator iCCI
   handle_iCCI_100=iCCI(m_symbol.Name(),Period(),100,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iCCI_100==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iCCI
   handle_iCCI_13=iCCI(m_symbol.Name(),Period(),13,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iCCI_13==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iCCI indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMA
   handle_iMA=iMA(m_symbol.Name(),Period(),InpStopLossMaPeriod,0,MODE_SMMA,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- init signals
   bGlobalSellSignal = false;             // true -> You need to Sell!
   bGlobalBuySignal  = false;             // true -> You need to Buy!
   bCloseAll         = false;             // true -> You need to close the "Buy" and "Sell"!
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string text="";
   switch(reason)
     {
      case  REASON_PROGRAM:
         text="REASON_PROGRAM";
         break;
      case  REASON_REMOVE:
         text="REASON_REMOVE";
         break;
      case  REASON_RECOMPILE:
         text="REASON_RECOMPILE";
         break;
      case  REASON_CHARTCHANGE:
         text="REASON_CHARTCHANGE";
         break;
      case  REASON_CHARTCLOSE:
         text="REASON_CHARTCLOSE";
         break;
      case  REASON_PARAMETERS:
         text="REASON_PARAMETERS";
         break;
      case  REASON_ACCOUNT:
         text="REASON_ACCOUNT";
         break;
      case  REASON_TEMPLATE:
         text="REASON_TEMPLATE";
         break;
      case  REASON_INITFAILED:
         text="REASON_INITFAILED";
         break;
      case  REASON_CLOSE:
         text="REASON_CLOSE";
         break;
      default:
         text="NON REASON";
         break;
     }
   SendNotification(text);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime dtPrevBars=0;
//--- protection of profit
   if(m_account.Equity()/m_account.Balance()>InpCoefProtectionProfit)
      bCloseAll=true;
//--- trailing stop (at every tick)
   if(!RefreshRates())
      return;
   TrailingStop();
//---
   datetime time_0=iTime(0);
   if(time_0==dtPrevBars)
      return;
   dtPrevBars=time_0;
//---
   int number_bar=0;
   if(!InpZeroBar)
      number_bar=1;
   double cci_100_1=iCCIGet(handle_iCCI_100,number_bar);
   double cci_100_2=iCCIGet(handle_iCCI_100,number_bar+1);
   double cci_13_1=iCCIGet(handle_iCCI_13,number_bar);
//--- check a signals 
   ENUM_DEAL_TYPE result=-1;
   result=IsSignal(cci_100_1,cci_100_2,cci_13_1);
   if(result==DEAL_TYPE_BUY)
     {
      if(!RefreshRates())
         return;
      OpenBuy();
      return;
     }
   else if(result==DEAL_TYPE_SELL)
     {
      if(!RefreshRates())
         return;
      OpenSell();
      return;
     }
//--- check to close the "buy" or "sell"
   if(bCloseAll)
     {
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
         if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
            if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
      bCloseAll=false;
     }
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//return;
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_entry        =0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      long     deal_magic        =0;
      if(HistoryDealSelect(trans.deal))
        {
         deal_entry=HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
        }
      else
         return;
      if(deal_symbol==m_symbol.Name() && deal_magic==m_magic)
         if(deal_entry==DEAL_ENTRY_OUT)
           {
            int find_sl=-1;
            find_sl=StringFind(deal_comment,InpStopLossComment,0);
            if(find_sl!=-1) // 
               bCloseAll=true;
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetMarginMode(void)
  {
   m_margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsHedging(void)
  {
   return(m_margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
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
//| Get Time for specified bar index                                 | 
//+------------------------------------------------------------------+ 
datetime iTime(const int index,string symbol=NULL,ENUM_TIMEFRAMES timeframe=PERIOD_CURRENT)
  {
   if(symbol==NULL)
      symbol=Symbol();
   if(timeframe==0)
      timeframe=Period();
   datetime Time[1];
   datetime time=0;
   int copied=CopyTime(symbol,timeframe,index,1,Time);
   if(copied>0) time=Time[0];
   return(time);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iCCI                                |
//+------------------------------------------------------------------+
double iCCIGet(int handle_iCCI,const int index)
  {
   double CCI[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iCCIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iCCI,0,index,1,CCI)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iCCI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(CCI[0]);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(const int index)
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
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_DEAL_TYPE IsSignal(const double cci_100_1,const double cci_100_2,const double cci_13_1)
  {
//--- reverse
   if((cci_100_2>Inp_CCI100_ReverseLevel && cci_100_1<Inp_CCI100_ReverseLevel) || 
      (cci_100_2<-Inp_CCI100_ReverseLevel && cci_100_1>-Inp_CCI100_ReverseLevel))
     {
      //Print("cci(100): reverse of the ",DoubleToString(Inp_CCI100_ReverseLevel,0)," value");
      bGlobalBuySignal=false;
      bGlobalSellSignal=false;
      bCloseAll=true;
      return(-1);
     }
//--- global signal of cci(100)
   if(cci_100_1>Inp_CCI100_GlobalSignalLevel && !bGlobalBuySignal)
     {
      //Print("cci(100): \"Global Buy Signal\"");
      bGlobalBuySignal=true;
      bGlobalSellSignal=false;
      bCloseAll=false;
      return(DEAL_TYPE_BUY);
     }
   else if(cci_100_1<-Inp_CCI100_GlobalSignalLevel && !bGlobalSellSignal)
     {
      //Print("cci(100): \"Global Sell Signal\"");
      bGlobalBuySignal=false;
      bGlobalSellSignal=true;
      bCloseAll=false;
      return(DEAL_TYPE_SELL);
     }
   if(InpAveraging)
     {
      if(bGlobalBuySignal && cci_13_1<-Inp_CCI100_GlobalSignalLevel)
        {
         //Print("Averaging==true, \"Global Buy Signal\"==true, signal of the cci(13): \"Buy\"");
         return(DEAL_TYPE_BUY);
        }
      //---
      if(bGlobalSellSignal && cci_13_1>Inp_CCI100_GlobalSignalLevel)
        {
         //Print("Averaging==true, \"Global Sell Signal\"==true, signal of the cci(13): \"Sell\"");
         return(DEAL_TYPE_SELL);
        }
     }
//---
   return(-1);
  }
//+------------------------------------------------------------------+
//| Подсчёт позиций Buy и Sell                                       |
//+------------------------------------------------------------------+
int CalculatePositions(void)
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
//| Трейлинг - стоп по iMA(36)                                       |
//+------------------------------------------------------------------+
void TrailingStop()
  {
   double sl=iMAGet(0);
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(sl>m_symbol.Bid())
                  continue;
               //--- Break-even
               if(InpBreakEven>0)
                  if(m_position.StopLoss()<m_position.PriceOpen())
                    {
                     if(m_position.PriceOpen()+m_adjusted_point*InpBreakEven<m_position.PriceCurrent())
                       {
                        if(m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()),m_position.TakeProfit()))
                          {
                           Print("Buy ",m_position.Ticket()," Break-even PositionModify -> true. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Buy ",m_position.Ticket()," Break-even PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                          }
                        continue;
                       }
                    }
               //--- TrailingStop  
               if(sl-InpTrailingStep*m_adjusted_point>m_position.StopLoss())
                 {
                  if(m_trade.PositionModify(m_position.Ticket(),m_symbol.NormalizePrice(sl),m_position.TakeProfit()))
                    {
                     Print("Buy ",m_position.Ticket()," TrailingStop PositionModify -> true. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                  else
                    {
                     Print("Buy ",m_position.Ticket()," TrailingStop PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
                 }
              }

            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(sl<m_symbol.Ask())
                  continue;
               //--- Break-even
               if(InpBreakEven>0)
                  if(m_position.StopLoss()>m_position.PriceOpen())
                    {
                     if(m_position.PriceOpen()-m_adjusted_point*InpBreakEven>m_position.PriceCurrent())
                       {
                        if(m_trade.PositionModify(m_position.Ticket(),
                           m_symbol.NormalizePrice(m_position.PriceOpen()),m_position.TakeProfit()))
                          {
                           Print("Sell ",m_position.Ticket()," Break-even PositionModify -> true. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                          }
                        else
                          {
                           Print("Sell ",m_position.Ticket()," Break-even PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                          }
                        continue;
                       }
                    }
               if(m_position.StopLoss()!=0.0)
                  if(sl+InpTrailingStep*m_adjusted_point<m_position.StopLoss())
                    {
                     if(m_trade.PositionModify(m_position.Ticket(),m_symbol.NormalizePrice(sl),m_position.TakeProfit()))
                       {
                        Print("Sell ",m_position.Ticket()," TrailingStop PositionModify -> true. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
                     else
                       {
                        Print("Sell ",m_position.Ticket()," TrailingStop PositionModify -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
                    }
              }
           }
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy()
  {
   double sl=iMAGet(0);
   if(sl>m_symbol.Bid())
     {
      //Print(__FUNCTION__,", sl>m_symbol.Bid() -> error sl");
      return;
     }
   double min_stops_level=InpMinDistancePriceStopLoss*m_adjusted_point;
   if(MathAbs(m_symbol.Bid()-sl<min_stops_level))
     {
      //Print(__FUNCTION__,", m_symbol.Bid()(",
      //      DoubleToString(m_symbol.Bid(),m_symbol.Digits()),")-sl(",
      //      DoubleToString(sl,m_symbol.Digits()),")<min_stops_level(",
      //      DoubleToString(min_stops_level,m_symbol.Digits()),") -> error sl");
      return;
     }
////--- the position of BUY can't be open below the lowest
//   double price_open_low=FindPosition(POSITION_TYPE_BUY,MODE_LOW);
//   if(price_open_low!=0)
//      if(price_open_low>m_symbol.Ask())
//         return;
//--- the last position of BUY can't be open below the lowest
   if(LastPosition(POSITION_TYPE_BUY)>m_symbol.Ask())
      return;

   sl=m_symbol.NormalizePrice(sl);
   double tp=0.0;

   double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_long_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_long_lot)
        {
         if(m_trade.Buy(check_open_long_lot,NULL,m_symbol.Ask(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
               Print("Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
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
void OpenSell()
  {
   double sl=iMAGet(0);
   if(sl<m_symbol.Ask())
     {
      //Print(__FUNCTION__,", sl<m_symbol.Ask() -> error sl");
      return;
     }
   double min_stops_level=InpMinDistancePriceStopLoss*m_adjusted_point;
   if(MathAbs(sl-m_symbol.Ask()<min_stops_level))
     {
      //Print(__FUNCTION__,", sl(",
      //      DoubleToString(sl,m_symbol.Digits()),")-m_symbol.Ask()(",
      //      DoubleToString(m_symbol.Ask(),m_symbol.Digits()),")<min_stops_level(",
      //      DoubleToString(min_stops_level,m_symbol.Digits()),") -> error sl");
      return;
     }
////--- the position of SELL can't be open above the highest
//   double price_open_low=FindPosition(POSITION_TYPE_SELL,MODE_HIGH);
//   if(price_open_low!=0)
//      if(price_open_low>m_symbol.Bid())
//         return;
//--- the last position of SELL can't be open below the lowest
   double price_open_last=LastPosition(POSITION_TYPE_SELL);
   if(price_open_last!=0 && price_open_last<m_symbol.Bid())
      return;

   sl=m_symbol.NormalizePrice(sl);
   double tp=0.0;

   double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
   if(check_open_short_lot==0.0)
      return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=check_open_short_lot)
        {
         if(m_trade.Sell(check_open_short_lot,NULL,m_symbol.Bid(),sl,tp))
           {
            if(m_trade.ResultDeal()==0)
              {
               Print("Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
              }
            else
               Print("Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
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
//| Search of the best/worst position of the set type                |
//|  MODE_LOW                                                        |
//|  MODE_HIGH                                                       |
//+------------------------------------------------------------------+
double FindPosition(const ENUM_POSITION_TYPE pos_type,const ENUM_FIND mode)
  {
   double price=0.0;
   switch(mode)
     {
      case MODE_HIGH:
         price=DBL_MIN;
         break;
      case MODE_LOW:
         price=DBL_MAX;
         break;
      default:
         return(price);
         break;
     }

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
              {
               if(mode==MODE_HIGH)
                 {
                  if(m_position.PriceOpen()>price)
                     price=m_position.PriceOpen();
                 }
               if(mode==MODE_LOW)
                 {
                  if(m_position.PriceOpen()<price)
                     price=m_position.PriceOpen();
                 }
              }
   if(price==DBL_MIN || price==DBL_MAX)
      price=0;
   return(price);
  }
//+------------------------------------------------------------------+
//| Search last position of the set type                             |
//+------------------------------------------------------------------+
double LastPosition(const ENUM_POSITION_TYPE pos_type)
  {
   double price=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
              {
               price=m_position.PriceOpen();
               break;
              }
   return(price);
  }
//+------------------------------------------------------------------+
