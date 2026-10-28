//+------------------------------------------------------------------+
//|                             MACD EA(barabashkakvn's edition).mq5 |
//|                                    Copyright © 2006-2007, Daniil |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006 Daniil"
#property link      "npplus@mail.ru"
#property link      "http://www.fxmts.ru"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
CAccountInfo   m_account;                    // account info wrapper
CDealInfo      m_deal;                       // deals object
CMoneyFixedMargin *m_money;
//--- input parameters
sinput string  rem0="Trading settings";      // --- Trading settings ---
input double   InpLots           = 1.0;      // Lots (use only if "Money Management" == false)
input ushort   InpStopLoss       = 80;       // Stop Loss (in pips)
input ushort   InpTakeProfit     = 500;      // Take Profit (in pips)
input ushort   InpProfitOne      = 70;       // Profit for closing half of the position (in pips)
input ushort   InpBreakeven      = 0;        // Breakeven (in pips)
sinput string  rem1="Money Management";      // --- Money Management ---
input bool     MM                = false;    // Money Management
input double   Risk              = 1.0;      // Risk in percent for a deal from a free margin
sinput string  rem3="Indicator parameters";  // Indicator parameters
input int      MAFast_ma_period      = 55;       // MA Fast: averaging period 
input int      MAFast_ma_shift       = 0;        // MA Fast: horizontal shift of the indicator
input ENUM_MA_METHOD MAFast_ma_method=MODE_EMA;  // MA Fast: smoothing type
input ENUM_APPLIED_PRICE MAFast_applied_price=PRICE_CLOSE;// MA Fast: type of price
input int      MASlow_ma_period      = 69;       // MA Slow: averaging period 
input int      MASlow_ma_shift       = 0;        // MA Slow: horizontal shift of the indicator
input ENUM_MA_METHOD MASlow_ma_method=MODE_SMA;  // MA Slow: smoothing type
input ENUM_APPLIED_PRICE MASlow_applied_price=PRICE_CLOSE;// MA Slow: type of price
input int      MAFilter_ma_period= 2;           // MA Filter: averaging period 
input int      MAFilter_ma_shift= 0;            // MA Filter: horizontal shift of the indicator
input ENUM_MA_METHOD MAFilter_ma_method=MODE_LWMA; // MA Filter: smoothing type
input ENUM_APPLIED_PRICE MAFilter_applied_price=PRICE_CLOSE;// MA Filter: type of price
input int      MACDfast_ema_period=120;     // MACD: period for Fast average calculation 
input int      MACDslow_ema_period=260;     // MACD: period for Slow average calculation 
input int      MACDsignal_period=90;       // MACD: period for their difference averaging 
input ulong    m_magic=336115454;               // magic number
//---
ulong          m_slippage=10;                   // slippage

double         ExtStopLoss=0.0;
double         ExtTakeProfit=0.0;
double         ExtProfitOne=0.0;
double         ExtBreakeven=0.0;

int            handle_iMAFast;               // variable for storing the handle of the iMA indicator 
int            handle_iMASlow;               // variable for storing the handle of the iMA indicator 
int            handle_iMAFilter;             // variable for storing the handle of the iMA indicator 
int            handle_iMACD;                 // variable for storing the handle of the iMACD indicator 
double         m_adjusted_point;             // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();

   if(!MM)
     {
      string err_text="";
      if(!CheckVolumeValue(InpLots,err_text))
        {
         Print(err_text);
         return(INIT_PARAMETERS_INCORRECT);
        }
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
   ExtProfitOne=InpProfitOne*m_adjusted_point;
   ExtBreakeven=InpBreakeven*m_adjusted_point;
//---
   if(MM)
     {
      if(m_money!=NULL)
         delete(m_money);
      m_money=new CMoneyFixedMargin;
      if(m_money!=NULL)
        {
         if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
            return(INIT_FAILED);
         m_money.Percent(Risk);
        }
      else
        {
         Print("Error create CMoneyFixedMargin object");
         return(INIT_FAILED);
        }
     }
//--- create handle of the indicator iMA
   handle_iMAFast=iMA(m_symbol.Name(),Period(),MAFast_ma_period,MAFast_ma_shift,MAFast_ma_method,MAFast_applied_price);
//--- if the handle is not created 
   if(handle_iMAFast==INVALID_HANDLE)
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
   handle_iMASlow=iMA(m_symbol.Name(),Period(),MASlow_ma_period,MASlow_ma_shift,MASlow_ma_method,MASlow_applied_price);
//--- if the handle is not created 
   if(handle_iMASlow==INVALID_HANDLE)
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
   handle_iMAFilter=iMA(m_symbol.Name(),Period(),MAFilter_ma_period,MAFilter_ma_shift,MAFilter_ma_method,MAFilter_applied_price);
//--- if the handle is not created 
   if(handle_iMAFilter==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator iMACD
   handle_iMACD=iMACD(m_symbol.Name(),Period(),MACDfast_ema_period,MACDslow_ema_period,MACDsignal_period,PRICE_CLOSE);
//--- if the handle is not created 
   if(handle_iMACD==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMACD indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(Period()),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(MM)
      if(m_money!=NULL)
         delete(m_money);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- we work only at the time of the birth of new bar
   static datetime PrevBars=0;
   datetime time_0=iTime(m_symbol.Name(),Period(),0);
   if(time_0==PrevBars)
      return;
   PrevBars=time_0;

   static bool count_error_bars=false;
   if(Bars(m_symbol.Name(),Period())<100) // print the error only once - do not litter the tab "Experts"
     {
      if(!count_error_bars)
         Print("bars less than 100");
      count_error_bars=true;
      return;
     }
   count_error_bars=0;
//---
   int total=0;

   double MAFast_0      = iMAGet(handle_iMAFast,0);
   double MASlow_0      = iMAGet(handle_iMASlow,0);

   double MAFilter_0    = iMAGet(handle_iMAFilter,0);
   double MAFilter_2    = iMAGet(handle_iMAFilter,2);

   double MACD_MAIN_2   = iMACDGet(MAIN_LINE,2);
   double MACD_MAIN_4   = iMACDGet(MAIN_LINE,4);

   double MACD_SIGNAL_2 = iMACDGet(SIGNAL_LINE,2);
   double MACD_SIGNAL_4 = iMACDGet(SIGNAL_LINE,4);
//--- main cycle
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            total++;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               //--- full closure
               if(MACD_MAIN_2<MACD_SIGNAL_2 && MACD_MAIN_4>MACD_SIGNAL_4)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  Print("Closed the BUY position on the opposite signal");
                  continue;
                 }
               //--- closing half
               if(InpProfitOne!=0)
                 {
                  if(m_position.PriceCurrent()>m_position.PriceOpen()+ExtProfitOne)
                    {
                     double half_lot=LotCheck(m_position.Volume()/2.0);
                     if(half_lot!=0.0)
                       {
                        m_trade.PositionClosePartial(m_position.Ticket(),half_lot);
                        Print("Half of the BUY position is closed");
                       }
                    }
                  continue;
                 }
               //--- breakeven
               if(InpBreakeven!=0)
                 {
                  if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtBreakeven)
                    {
                     double sl=m_position.StopLoss();
                     double po=m_position.PriceOpen();
                     double tp=m_position.TakeProfit();
                     if(sl==0.0 || (sl!=0.0 && (sl<po && !CompareDoubles(sl,po,m_symbol.Digits()))))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),po,tp))
                           Print("Modify Breakeven BUY ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
                    }
                  continue;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               //--- full closure
               if(MACD_MAIN_2>MACD_SIGNAL_2 && MACD_MAIN_4<MACD_SIGNAL_4)
                 {
                  m_trade.PositionClose(m_position.Ticket());
                  Print("Closed the SELL position on the opposite signal");
                  continue;
                 }
               //--- closing half
               if(InpProfitOne!=0)
                 {
                  if(m_position.PriceCurrent()<m_position.PriceOpen()-ExtProfitOne)
                    {
                     double half_lot=LotCheck(m_position.Volume()/2.0);
                     if(half_lot!=0.0)
                       {
                        m_trade.PositionClosePartial(m_position.Ticket(),half_lot);
                        Print("Half of the SELL position is closed");
                       }
                    }
                  continue;
                 }
               //--- breakeven
               if(InpBreakeven!=0)
                 {
                  if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtBreakeven)
                    {
                     double sl=m_position.StopLoss();
                     double po=m_position.PriceOpen();
                     double tp=m_position.TakeProfit();
                     if(sl==0.0 || (sl!=0.0 && (sl>po && !CompareDoubles(sl,po,m_symbol.Digits()))))
                       {
                        if(!m_trade.PositionModify(m_position.Ticket(),po,tp))
                           Print("Modify Breakeven SELL ",m_position.Ticket(),
                                 " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                                 ", description of result: ",m_trade.ResultRetcodeDescription());
                       }
                    }
                  continue;
                 }
              }
           }
//---
   if(total==0)
     {
      if(!RefreshRates())
        {
         PrevBars=0;
         return;
        }
      //--- open BUY 
      if(MACD_MAIN_2>MACD_SIGNAL_2 && MACD_MAIN_4<MACD_SIGNAL_4)
        {
         double sl=(InpStopLoss!=0)?m_symbol.Ask()-ExtStopLoss:0.0;
         double tp=(InpTakeProfit!=0)?m_symbol.Ask()+ExtTakeProfit:0.0;
         OpenBuy(sl,tp);
         return;
        }
      //--- open SELL
      if(MACD_MAIN_2<MACD_SIGNAL_2 && MACD_MAIN_4>MACD_SIGNAL_4)
        {
         double sl=(InpStopLoss!=0)?m_symbol.Bid()+ExtStopLoss:0.0;
         double tp=(InpTakeProfit!=0)?m_symbol.Bid()-ExtTakeProfit:0.0;
         OpenSell(sl,tp);
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//| Расчет оптимальной величины лота                                 |
//+------------------------------------------------------------------+
double LotsOptimized()
  {
   double lot=InpLots;
   if(!MM)
      return(lot);
   int losses=0;                    // number of losses deals without a break
//--- calcuulate number of losses deals without a break
//--- request trade history for 30 days
   HistorySelect(TimeCurrent()-86400*30,TimeCurrent()+86400*30);
//--- 
   uint total=HistoryDealsTotal();
//--- for all deals 
   for(uint i=0;i<total;i++)
     {
      if(!m_deal.SelectByIndex(i))
        {
         Print("Error in history!");
         break;
        }
      if(m_deal.Symbol()!=m_symbol.Name() || m_deal.Entry()!=DEAL_ENTRY_OUT)
         continue;
      //---
      if(m_deal.Profit()>0)
         break;
      if(m_deal.Profit()<0)
         losses++;
     }
   if(losses>0)
     {
      switch(losses)
        {
         case 1: lot=lot*2.0;
         case 2: lot=lot*3.0;
         case 3: lot=lot*4.0;
         case 4: lot=lot*5.0;
         case 5: lot=lot*6.0;
         default: lot=lot*7.0;
        }
      lot=LotCheck(lot);
     }
//--- return lot size
   return(lot);
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
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
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
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double iMAGet(int handle_iMA,const int index)
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
//| Get value of buffers for the iMACD                               |
//|  the buffer numbers are the following:                           |
//|   0 - MAIN_LINE, 1 - SIGNAL_LINE                                 |
//+------------------------------------------------------------------+
double iMACDGet(const int buffer,const int index)
  {
   double MACD[1];
//--- reset error code 
   ResetLastError();
//--- fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(handle_iMACD,buffer,index,1,MACD)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(0.0);
     }
   return(MACD[0]);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=(!MM)?InpLots:m_money.CheckOpenLong(m_symbol.Ask(),sl);
   if(MM)
     {
      Print("sl= ",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
     }
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
               Print("#1 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Buy -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Buy -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
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

   double check_open_short_lot=(!MM)?InpLots:m_money.CheckOpenShort(m_symbol.Bid(),sl);
   if(MM)
     {
      Print("sl= ",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
     }
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
               Print("#1 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
            else
              {
               Print("#2 Sell -> true. Result Retcode: ",m_trade.ResultRetcode(),
                     ", description of result: ",m_trade.ResultRetcodeDescription());
               PrintResult(m_trade,m_symbol);
              }
           }
         else
           {
            Print("#3 Sell -> false. Result Retcode: ",m_trade.ResultRetcode(),
                  ", description of result: ",m_trade.ResultRetcodeDescription());
            PrintResult(m_trade,m_symbol);
           }
        }
//---
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
   DebugBreak();
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
