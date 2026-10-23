//+------------------------------------------------------------------+
//|                                                   Morse code.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.008"
#property description "Bull candle - \"1\", bear candle - \"0\""
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//+------------------------------------------------------------------+
//| Enum pattern mask                                                |
//+------------------------------------------------------------------+
enum ENUM_PATTERN_MASK
  {
   _0    =   0    ,   // 0
   _1    =   1    ,   // 1

   _2    =   2    ,   // 00
   _3    =   3    ,   // 01
   _4    =   4    ,   // 10
   _5    =   5    ,   // 11

   _6    =   6    ,   // 000
   _7    =   7    ,   // 001
   _8    =   8    ,   // 010
   _9    =   9    ,   // 011
   _10   =   10   ,   // 100
   _11   =   11   ,   // 101
   _12   =   12   ,   // 110
   _13   =   13   ,   // 111

   _14   =   14   ,   // 0000
   _15   =   15   ,   // 0001
   _16   =   16   ,   // 0010
   _17   =   17   ,   // 0011
   _18   =   18   ,   // 0100
   _19   =   19   ,   // 0101
   _20   =   20   ,   // 0110
   _21   =   21   ,   // 0111
   _22   =   22   ,   // 1000
   _23   =   23   ,   // 1001
   _24   =   24   ,   // 1010
   _25   =   25   ,   // 1011
   _26   =   26   ,   // 1100
   _27   =   27   ,   // 1101
   _28   =   28   ,   // 1110
   _29   =   29   ,   // 1111

   _30   =   30   ,   // 00000
   _31   =   31   ,   // 00000
   _32   =   32   ,   // 00010
   _33   =   33   ,   // 00011
   _34   =   34   ,   // 00100
   _35   =   35   ,   // 00101
   _36   =   36   ,   // 00111
   _37   =   37   ,   // 00111
   _38   =   38   ,   // 01000
   _39   =   39   ,   // 01001
   _40   =   40   ,   // 01010
   _41   =   41   ,   // 01011
   _42   =   42   ,   // 01100
   _43   =   43   ,   // 01101
   _44   =   44   ,   // 01110
   _45   =   45   ,   // 01111
   _46   =   46   ,   // 10000
   _47   =   47   ,   // 10001
   _48   =   48   ,   // 10010
   _49   =   49   ,   // 10011
   _50   =   50   ,   // 10100
   _51   =   51   ,   // 10101
   _52   =   52   ,   // 10110
   _53   =   53   ,   // 10111
   _54   =   54   ,   // 11000
   _55   =   55   ,   // 11001
   _56   =   56   ,   // 11010
   _57   =   57   ,   // 11011
   _58   =   58   ,   // 11100
   _59   =   59   ,   // 11101
   _60   =   60   ,   // 11110
   _61   =   61   ,   // 11111
  };
//---
input ENUM_PATTERN_MASK    InpMask                 = _0;                   // pattern mask (bull candle - 1, bear candle - 0)
input ENUM_POSITION_TYPE   InpPosType              = POSITION_TYPE_BUY;    // posinion type
input double               InpLot                  = 0.1;                  // lot
input ushort               InpTakeProfit           = 50;                   // take profit (in pips)
input ushort               InpStopLoss             = 50;                   // stop loss (in pips)
sinput ulong               m_magic                 = 88430400;             // magic number
input ulong                m_slippage              = 30;                   // slippage
//---
string                     sExtMorseCode="";
double                     m_adjusted_point;                               // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!ConvertNumberToString(InpMask,sExtMorseCode))
     {
      Print("Error: Unknown mask");
      return(INIT_FAILED);
     }
   Print(__FUNCTION__,", pattern mask: ",sExtMorseCode);
   m_symbol.Name(Symbol());                  // sets symbol name
   if(!RefreshRates())
     {
      Print("Error RefreshRates. Bid=",DoubleToString(m_symbol.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbol.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbol.Refresh();
//---
   m_trade.SetExpertMagicNumber(m_magic);

   if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(Symbol(),SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);

   m_trade.SetDeviationInPoints(m_slippage);

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;
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

   int count=StringLen(sExtMorseCode);

   MqlRates rates[];
   int copied=CopyRates(NULL,0,1,count,rates);
//--- Example:
//--- rates[0].time -> D'2015.05.28 00:00:00'
//--- rates[2].time -> D'2015.06.01 00:00:00'
   if(copied<=0)
     {
      Print("Error copying price data ",GetLastError());
      return;
     }

   bool result=true;

//---  
   for(int i=0;i<StringLen(sExtMorseCode);i++)
     {
      if(sExtMorseCode[i]=='0')
        {
         if(rates[i].open<rates[i].close)
           {
            result=false;
            break;
           }
        }
      else  if(sExtMorseCode[i]=='1')
        {
         if(rates[i].open>rates[i].close)
           {
            result=false;
            break;
           }
        }
     }

   if(!result)
      return;
//--- 
   if(!RefreshRates())
     {
      PrevBars=iTime(1);
      return;
     }

   if(InpPosType==POSITION_TYPE_BUY)
      OpenBuy(m_symbol.Ask()-InpStopLoss*m_adjusted_point,m_symbol.Ask()+InpTakeProfit*m_adjusted_point);
   else
      OpenSell(m_symbol.Bid()+InpStopLoss*m_adjusted_point,m_symbol.Bid()-InpTakeProfit*m_adjusted_point);

   int d=0;
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
      return(false);
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
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
//|                                                                  |
//+------------------------------------------------------------------+
bool ConvertNumberToString(const ENUM_PATTERN_MASK num_mask,string &text)
  {
   bool result=true;
//---
   switch(num_mask)
     {
      case 0:  text="0"; break;
      case 1:  text="1"; break;
      case 2:  text="00"; break;
      case 3:  text="01"; break;
      case 4:  text="10"; break;
      case 5:  text="11"; break;
      case 6:  text="000"; break;
      case 7:  text="001"; break;
      case 8:  text="010"; break;
      case 9:  text="011"; break;
      case 10: text="100"; break;
      case 11: text="101"; break;
      case 12: text="110"; break;
      case 13: text="111"; break;
      case 14: text="0000"; break;
      case 15: text="0001"; break;
      case 16: text="0010"; break;
      case 17: text="0011"; break;
      case 18: text="0100"; break;
      case 19: text="0101"; break;
      case 20: text="0110"; break;
      case 21: text="0111"; break;
      case 22: text="1000"; break;
      case 23: text="1001"; break;
      case 24: text="1010"; break;
      case 25: text="1011"; break;
      case 26: text="1100"; break;
      case 27: text="1101"; break;
      case 28: text="1110"; break;
      case 29: text="1111"; break;
      case 30: text="00000"; break;
      case 31: text="00000"; break;
      case 32: text="00010"; break;
      case 33: text="00011"; break;
      case 34: text="00100"; break;
      case 35: text="00101"; break;
      case 36: text="00111"; break;
      case 37: text="00111"; break;
      case 38: text="01000"; break;
      case 39: text="01001"; break;
      case 40: text="01010"; break;
      case 41: text="01011"; break;
      case 42: text="01100"; break;
      case 43: text="01101"; break;
      case 44: text="01110"; break;
      case 45: text="01111"; break;
      case 46: text="10000"; break;
      case 47: text="10001"; break;
      case 48: text="10010"; break;
      case 49: text="10011"; break;
      case 50: text="10100"; break;
      case 51: text="10101"; break;
      case 52: text="10110"; break;
      case 53: text="10111"; break;
      case 54: text="11000"; break;
      case 55: text="11001"; break;
      case 56: text="11010"; break;
      case 57: text="11011"; break;
      case 58: text="11100"; break;
      case 59: text="11101"; break;
      case 60: text="11110"; break;
      case 61: text="11111"; break;
      default: text=""; return(false);
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

//double check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
//if(check_open_long_lot==0.0)
//   return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=InpLot)
        {
         if(m_trade.Buy(InpLot,NULL,m_symbol.Ask(),sl,tp))
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

//double check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
//Print("sl=",DoubleToString(sl,m_symbol.Digits()),
//      ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
//      ", Balance: ",    DoubleToString(m_account.Balance(),2),
//      ", Equity: ",     DoubleToString(m_account.Equity(),2),
//      ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
//if(check_open_short_lot==0.0)
//   return;

//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double chek_volime_lot=m_trade.CheckVolume(m_symbol.Name(),InpLot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(chek_volime_lot!=0.0)
      if(chek_volime_lot>=InpLot)
        {
         if(m_trade.Sell(InpLot,NULL,m_symbol.Bid(),sl,tp))
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
