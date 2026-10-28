//+------------------------------------------------------------------+
//|                                                   OpenTime 2.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "2.007"
//+------------------------------------------------------------------+
//| version   "1.000" (Yuriy Tokman)                                 |
//|   https://www.mql5.com/ru/code/19089                             |
//+------------------------------------------------------------------+
//---
#define m_magic_one m_magic
#define m_magic_two m_magic_one+1
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
sinput string _____1_____="Positions closing options";            // --- Positions closing options ---
input bool           TimeCloseOne      = true;                    // Use closing time interval #1
input datetime       CloseStartOne     = D'1970.01.01 19:50:00';  // Closing time interval #1 (ONLY hour:minute!)
input bool           TimeCloseTwo      = true;                    // Use closing time interval #2
input datetime       CloseStartTwo     = D'1970.01.01 23:20:00';  // Closing time interval #2 (ONLY hour:minute!)
input ushort         InpTrailingStop   = 30;                      // Trailing stop ("0" -> trailing OFF) (in pips)
input ushort         InpTrailingStep   = 3;                       // Trailing step (in pips)
sinput string _____2_____="Positions opening settings";           // --- Positions opening settings ---
input bool           Monday            = false;                   // Trade on Monday
input bool           Tuesday           = false;                   // Trade on Tuesday
input bool           Wednesday         = false;                   // Trade on Wednesday
input bool           Thursday          = true;                    // Trade on Thursday
input bool           Friday            = false;                   // Trade on Friday
input datetime       OpenStartOne      = D'1970.01.01 09:30:00';  // Opening start time interval #1 (ONLY hour:minute!)
input datetime       OpenEndOne        = D'1970.01.01 14:00:00';  // Opening end time interval #1 (ONLY hour:minute!)
input datetime       OpenStartTwo      = D'1970.01.01 14:30:00';  // Opening start time interval #2 (ONLY hour:minute!)
input datetime       OpenEndTwo        = D'1970.01.01 19:00:00';  // Opening end time interval #2 (ONLY hour:minute!)
input uchar          Duration          = 30;                      // Duration in seconds
input bool           BuyOrSellOne      = true;                    // Type of trade in time interval #1 ("true" -> BUY, "false" -> SELL)
input bool           BuyOrSellTwo      = true;                    // Type of trade in time interval #2 ("true" -> BUY, "false" -> SELL)
input double         InpLots           = 0.1;                     // Volume transaction
input ushort         InpStopLossOne    = 30;                      // StopLoss time interval #1 (in pips)
input ushort         InpTakeProfitOne  = 90;                      // TakeProfit time interval #1 (in pips)
input ushort         InpStopLossTwo    = 10;                      // StopLoss time interval #2 (in pips)
input ushort         InpTakeProfitTwo  = 35;                      // TakeProfit time interval #2 (in pips)
sinput string _____3_____="Advisor Options";                      // --- Advisor Options ---
input ulong          m_magic=714479490;                           // MagicNumber time interval #1 (time interval #2 == MagicNumber+1)
//---
input ulong m_slippage=30;
//---

double ExtStopLossOne=0.0;
double ExtTakeProfitOne=0.0;
double ExtStopLossTwo=0.0;
double ExtTakeProfitTwo=0.0;
double ExtTrailingStop=0.0;
double ExtTrailingStep=0.0;
double m_adjusted_point; // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!Monday && !Tuesday && !Wednesday && !Thursday && !Friday)
     {
      Print(__FUNCTION__," error: you have forbidden trade for all week :)");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   MqlDateTime SOpenStartOne;
   TimeToStruct(OpenStartOne,SOpenStartOne);
   int open_start_one=SOpenStartOne.hour*3600+SOpenStartOne.min*60;

   MqlDateTime SOpenEndOne;
   TimeToStruct(OpenEndOne,SOpenEndOne);
   int open_end_one=SOpenEndOne.hour*3600+SOpenEndOne.min*60;

   if(open_start_one>=open_end_one)
     {
      Print(__FUNCTION__," error: ",
            "\"Opening start time interval #1\" (",SOpenStartOne.hour,":",SOpenStartOne.min,") ",
            "can not be >= ",
            "\"Opening end time interval #1\" (",SOpenEndOne.hour,":",SOpenEndOne.min);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(CloseStartOne)
     {
      MqlDateTime SCloseStartOne;
      TimeToStruct(CloseStartOne,SCloseStartOne);
      int close_start_one=SCloseStartOne.hour*3600+SCloseStartOne.min*60;
      if(close_start_one>=open_start_one && close_start_one<=open_end_one)
        {
         Print(__FUNCTION__," error: ",
               "\"Closing time interval #1\" (",SCloseStartOne.hour,":",SCloseStartOne.min,") ",
               "can not be inside time interval #1 ",
               "(",SOpenStartOne.hour,":",SOpenStartOne.min,") - (",SOpenEndOne.hour,":",SOpenEndOne.min,")");
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//---
   MqlDateTime SOpenStartTwo;
   TimeToStruct(OpenStartTwo,SOpenStartTwo);
   int open_start_two=SOpenStartTwo.hour*3600+SOpenStartTwo.min*60;

   MqlDateTime SOpenEndTwo;
   TimeToStruct(OpenEndTwo,SOpenEndTwo);
   int open_end_two=SOpenEndTwo.hour*3600+SOpenEndTwo.min*60;
//---
   if(CloseStartTwo)
     {
      MqlDateTime SCloseStartTwo;
      TimeToStruct(CloseStartTwo,SCloseStartTwo);
      int close_start_two=SCloseStartTwo.hour*3600+SCloseStartTwo.min*60;
      if(close_start_two>=open_start_two && close_start_two<=open_end_two)
        {
         Print(__FUNCTION__," error: ",
               "\"Closing time interval #2\" (",SCloseStartTwo.hour,":",SCloseStartTwo.min,") ",
               "can not be inside time interval #2 ",
               "(",SOpenStartTwo.hour,":",SOpenStartTwo.min,") - (",SOpenEndTwo.hour,":",SOpenEndTwo.min,")");
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
//---
   if(open_start_two>=open_end_two)
     {
      Print(__FUNCTION__," error: ",
            "\"Opening start time interval #2\" (",SOpenStartTwo.hour,":",SOpenStartTwo.min,") ",
            "can not be >= ",
            "\"Opening end time interval #2\" (",SOpenStartTwo.hour,":",SOpenStartTwo.min);
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(InpTrailingStop>0 && InpTrailingStep==0)
     {
      Print(__FUNCTION__," error: \"Trailing step\" is zero!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(InpLots<=0.0)
     {
      Print(__FUNCTION__," error: the \"volume transaction\" can't be smaller or equal to zero");
      return(INIT_PARAMETERS_INCORRECT);
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

   ExtStopLossOne=InpStopLossOne*m_adjusted_point;
   ExtTakeProfitOne=InpTakeProfitOne*m_adjusted_point;
   ExtStopLossTwo=InpStopLossTwo*m_adjusted_point;
   ExtTakeProfitTwo=InpTakeProfitTwo*m_adjusted_point;
   ExtTrailingStop=InpTrailingStop*m_adjusted_point;
   ExtTrailingStep=InpTrailingStep*m_adjusted_point;
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
   if(TimeCloseOne || TimeCloseTwo)
     {
      MqlDateTime STimeCurrent;
      TimeToStruct(TimeCurrent(),STimeCurrent);
      int time_current=STimeCurrent.hour*3600+STimeCurrent.min*60+STimeCurrent.sec;
      if(TimeCloseOne)
        {
         MqlDateTime SCloseStartOne;
         TimeToStruct(CloseStartOne,SCloseStartOne);
         int close_start_one=SCloseStartOne.hour*3600+SCloseStartOne.min*60;
         if(time_current>=close_start_one && time_current<close_start_one+Duration)
            CloseAllPositions(m_magic_one);
        }
      if(CloseStartTwo)
        {
         MqlDateTime SCloseStartTwo;
         TimeToStruct(CloseStartTwo,SCloseStartTwo);
         int close_start_two=SCloseStartTwo.hour*3600+SCloseStartTwo.min*60;
         if(time_current>=close_start_two && time_current<close_start_two+Duration)
            CloseAllPositions(m_magic_two);
        }
     }
//---
   if(InpTrailingStop>0)
      Trailing();
//---
   MqlDateTime STimeCurrent;
   TimeToStruct(TimeCurrent(),STimeCurrent);
   int time_current=STimeCurrent.hour*3600+STimeCurrent.min*60+STimeCurrent.sec;
   if(!Monday && STimeCurrent.day_of_week==1)
      return;
   if(!Tuesday && STimeCurrent.day_of_week==2)
      return;
   if(!Wednesday && STimeCurrent.day_of_week==3)
      return;
   if(!Thursday && STimeCurrent.day_of_week==4)
      return;
   if(!Friday && STimeCurrent.day_of_week==5)
      return;
//---
   MqlDateTime SOpenStartOne;
   TimeToStruct(OpenStartOne,SOpenStartOne);
   int open_start_one=SOpenStartOne.hour*3600+SOpenStartOne.min*60;

   MqlDateTime SOpenEndOne;
   TimeToStruct(OpenEndOne,SOpenEndOne);
   int open_end_one=SOpenEndOne.hour*3600+SOpenEndOne.min*60;

   MqlDateTime SOpenStartTwo;
   TimeToStruct(OpenStartTwo,SOpenStartTwo);
   int open_start_two=SOpenStartTwo.hour*3600+SOpenStartTwo.min*60;

   MqlDateTime SOpenEndTwo;
   TimeToStruct(OpenEndTwo,SOpenEndTwo);
   int open_end_two=SOpenEndTwo.hour*3600+SOpenEndTwo.min*60;
//--- opening on time interval #1 or time interval #2
   if((time_current>=open_start_one && time_current<open_end_one+Duration) ||
      (time_current>=open_start_two && time_current<open_end_two+Duration))
     {
      int count_buys_one=0;
      int count_sells_one=0;
      int count_buys_two=0;
      int count_sells_two=0;
      CalculatePositions(count_buys_one,count_sells_one,count_buys_two,count_sells_two);
      if(!RefreshRates())
         return;
      //--- opening on time interval #1
      if(time_current>=open_start_one && time_current<open_end_one+Duration)
        {
         if(count_buys_one==0 && BuyOrSellOne)
           {
            double sl=(InpStopLossOne==0)?0.0:m_symbol.Ask()-ExtStopLossOne;
            double tp=(InpTakeProfitOne==0)?0.0:m_symbol.Ask()+ExtTakeProfitOne;
            OpenBuy(sl,tp,m_magic_one);
           }
         if(count_sells_one==0 && !BuyOrSellOne)
           {
            double sl=(InpStopLossOne==0)?0.0:m_symbol.Bid()+ExtStopLossOne;
            double tp=(InpTakeProfitOne==0)?0.0:m_symbol.Bid()-ExtTakeProfitOne;
            OpenSell(sl,tp,m_magic_one);
           }
        }
      if(time_current>=open_start_two && time_current<open_end_two+Duration)
        {
         //--- opening on time interval #2
         if(count_buys_two==0 && BuyOrSellTwo)
           {
            double sl=(InpStopLossTwo==0)?0.0:m_symbol.Ask()-ExtStopLossTwo;
            double tp=(InpTakeProfitTwo==0)?0.0:m_symbol.Ask()+ExtTakeProfitTwo;
            OpenBuy(sl,tp,m_magic_two);
           }
         if(count_sells_two==0 && !BuyOrSellTwo)
           {
            double sl=(InpStopLossTwo==0)?0.0:m_symbol.Bid()+ExtStopLossTwo;
            double tp=(InpTakeProfitTwo==0)?0.0:m_symbol.Bid()-ExtTakeProfitTwo;
            OpenSell(sl,tp,m_magic_two);
           }
        }
     }
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
//| Close all positions                                              |
//+------------------------------------------------------------------+
void CloseAllPositions(const ulong magic)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStop==0)
      return;
   if(InpTrailingStep==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && (m_position.Magic()==m_magic_one || m_position.Magic()==m_magic_two))
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify BUY ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }
            else
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStop+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStop+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify SELL ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }

           }
  }
//+------------------------------------------------------------------+
//| Calculate positions Buy and Sell                                 |
//+------------------------------------------------------------------+
void CalculatePositions(int &count_buys_one,int &count_sells_one,int &count_buys_two,int &count_sells_two)
  {
   count_buys_one=0;
   count_sells_one=0;
   count_buys_two=0;
   count_sells_two=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(m_position.Magic()==m_magic_one)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  count_buys_one++;
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  count_sells_one++;
              }
            else if(m_position.Magic()==m_magic_two)
              {
               if(m_position.PositionType()==POSITION_TYPE_BUY)
                  count_buys_two++;
               if(m_position.PositionType()==POSITION_TYPE_SELL)
                  count_sells_two++;
              }
           }
//---
   return;
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp,const ulong magic)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         m_trade.SetExpertMagicNumber(magic);
         if(m_trade.Buy(InpLots,m_symbol.Name(),m_symbol.Ask(),sl,tp,IntegerToString(magic)))
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
void OpenSell(double sl,double tp,const ulong magic)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         m_trade.SetExpertMagicNumber(magic);
         if(m_trade.Sell(InpLots,m_symbol.Name(),m_symbol.Bid(),sl,tp,IntegerToString(magic)))
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
