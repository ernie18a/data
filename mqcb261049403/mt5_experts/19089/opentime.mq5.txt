//+------------------------------------------------------------------+
//|                            OpenTime(barabashkakvn's edition).mq5 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| ENUM HOURS                                                       |
//+------------------------------------------------------------------+
enum ENUM_HOURS
  {
   HOUR_00 = 0,         // 00
   HOUR_01 = 1,         // 01
   HOUR_02 = 2,         // 02
   HOUR_03 = 3,         // 03
   HOUR_04 = 4,         // 04
   HOUR_05 = 5,         // 05
   HOUR_06 = 6,         // 06
   HOUR_07 = 7,         // 07
   HOUR_08 = 8,         // 08
   HOUR_09 = 9,         // 09
   HOUR_10 = 10,        // 10
   HOUR_11 = 11,        // 11
   HOUR_12 = 12,        // 12
   HOUR_13 = 13,        // 13
   HOUR_14 = 14,        // 14
   HOUR_15 = 15,        // 15
   HOUR_16 = 16,        // 16
   HOUR_17 = 17,        // 17
   HOUR_18 = 48,        // 18
   HOUR_19 = 19,        // 19
   HOUR_20 = 20,        // 20
   HOUR_21 = 21,        // 21
   HOUR_22 = 22,        // 22
   HOUR_23 = 23,        // 23
   HOUR_24 = 24         // 24
  };
//+------------------------------------------------------------------+
//| ENUM MINUTES                                                     |
//+------------------------------------------------------------------+
enum ENUM_MINUTES
  {
   MINUTE_0 = 0 ,  // 0
   MINUTE_1 = 1 ,  // 1
   MINUTE_2 = 2 ,  // 2
   MINUTE_3 = 3 ,  // 3
   MINUTE_4 = 4 ,  // 4
   MINUTE_5 = 5 ,  // 5
   MINUTE_6 = 6 ,  // 6
   MINUTE_7 = 7 ,  // 7
   MINUTE_8 = 8 ,  // 8
   MINUTE_9 = 9 ,  // 9
   MINUTE_10 = 10 ,  // 10
   MINUTE_11 = 11 ,  // 11
   MINUTE_12 = 12 ,  // 12
   MINUTE_13 = 13 ,  // 13
   MINUTE_14 = 14 ,  // 14
   MINUTE_15 = 15 ,  // 15
   MINUTE_16 = 16 ,  // 16
   MINUTE_17 = 17 ,  // 17
   MINUTE_18 = 18 ,  // 18
   MINUTE_19 = 19 ,  // 19
   MINUTE_20 = 20 ,  // 20
   MINUTE_21 = 21 ,  // 21
   MINUTE_22 = 22 ,  // 22
   MINUTE_23 = 23 ,  // 23
   MINUTE_24 = 24 ,  // 24
   MINUTE_25 = 25 ,  // 25
   MINUTE_26 = 26 ,  // 26
   MINUTE_27 = 27 ,  // 27
   MINUTE_28 = 28 ,  // 28
   MINUTE_29 = 29 ,  // 29
   MINUTE_30 = 30 ,  // 30
   MINUTE_31 = 31 ,  // 31
   MINUTE_32 = 32 ,  // 32
   MINUTE_33 = 33 ,  // 33
   MINUTE_34 = 34 ,  // 34
   MINUTE_35 = 35 ,  // 35
   MINUTE_36 = 36 ,  // 36
   MINUTE_37 = 37 ,  // 37
   MINUTE_38 = 38 ,  // 38
   MINUTE_39 = 39 ,  // 39
   MINUTE_40 = 40 ,  // 40
   MINUTE_41 = 41 ,  // 41
   MINUTE_42 = 42 ,  // 42
   MINUTE_43 = 43 ,  // 43
   MINUTE_44 = 44 ,  // 44
   MINUTE_45 = 45 ,  // 45
   MINUTE_46 = 46 ,  // 46
   MINUTE_47 = 47 ,  // 47
   MINUTE_48 = 48 ,  // 48
   MINUTE_49 = 49 ,  // 49
   MINUTE_50 = 50 ,  // 50
   MINUTE_51 = 51 ,  // 51
   MINUTE_52 = 52 ,  // 52
   MINUTE_53 = 53 ,  // 53
   MINUTE_54 = 54 ,  // 54
   MINUTE_55 = 55 ,  // 55
   MINUTE_56 = 56 ,  // 56
   MINUTE_57 = 57 ,  // 57
   MINUTE_58 = 58 ,  // 58
   MINUTE_59 = 59    // 59
  };
//--- input parameters
input string _____1_____="Position closing options";
input bool           TimeClose         = true;        // Use position closing time
input ENUM_HOURS     CloseTimeHour     = HOUR_20;     // Closing hour
input ENUM_MINUTES   CloseTimeMinute   = MINUTE_50;   // Minutes of position closing
input bool           InpTrailing       = false;       // Trailing
input ushort         InpTrailingStop   = 30;          // Trailing stop (in pips)
input ushort         InpTrailingStep   = 3;           // Trailing step (in pips)
input string _____2_____="Position opening settings";
input ENUM_HOURS     TimeTradeHour     = HOUR_18;     // Opening hour
input ENUM_MINUTES   TimeTradeMinute   = MINUTE_50;   // Minutes of position opening
input int            Duration          = 300;         // Duration in seconds
input bool           Sell              = true;        // Use Sell
input bool           Buy               = false;       // Use Buy
input double         InpLots           = 0.1;         // Volume transaction
input ushort         InpStopLoss       = 0;           // StopLoss (in pips)
input ushort         InpTakeProfit     = 0;           // TakeProfit (in pips)
input string _____3_____="Advisor Options";
input ulong          m_magic=54295502;                // MagicNumber
//---
input ulong m_slippage=30;
//---

double ExtStopLoss=0;
double ExtTakeProfit=0;
double ExtTrailingStop=0;
double ExtTrailingStep=0;
double m_adjusted_point; // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(InpLots<=0.0)
     {
      Print("The \"volume transaction\" can't be smaller or equal to zero");
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
   if(TimeClose)
     {
      MqlDateTime str1;
      TimeToStruct(TimeCurrent(),str1);
      str1.hour=CloseTimeHour;
      str1.min=CloseTimeMinute;
      datetime close_time=StructToTime(str1);
      if(TimeCurrent()>=close_time && TimeCurrent()<close_time+Duration)
        {
         CloseAllPositions();
         return;
        }
     }
//---
   if(InpTrailing)
      Trailing();
//---
   MqlDateTime str1;
   TimeToStruct(TimeCurrent(),str1);
   str1.hour=TimeTradeHour;
   str1.min=TimeTradeMinute;
   datetime time_trade=StructToTime(str1);
   if(TimeCurrent()>=time_trade && TimeCurrent()<time_trade+Duration)
     {
      int count_buys=0;
      int count_sells=0;
      CalculatePositions(count_buys,count_sells);
      if(!RefreshRates())
         return;
      if(count_buys==0 && Buy)
        {
         double sl=0.0,tp=0.0;
         if(InpStopLoss>0)
            sl=m_symbol.Ask()-ExtStopLoss;
         if(InpTakeProfit>0)
            tp=m_symbol.Ask()+ExtTakeProfit;
         OpenBuy(sl,tp);
        }
      if(count_sells==0 && Sell)
        {
         double sl=0.0,tp=0.0;
         if(InpStopLoss>0)
            sl=m_symbol.Bid()+ExtStopLoss;
         if(InpTakeProfit>0)
            tp=m_symbol.Bid()-ExtTakeProfit;
         OpenSell(sl,tp);
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
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(ExtTrailingStop==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStop+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStop+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStop),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
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
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     return;
                    }
              }

           }
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
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Buy(InpLots,NULL,m_symbol.Ask(),sl,tp))
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
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),InpLots,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
      if(check_volume_lot>=InpLots)
        {
         if(m_trade.Sell(InpLots,NULL,m_symbol.Bid(),sl,tp))
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
