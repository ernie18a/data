//+------------------------------------------------------------------+
//|                                           N seconds N points.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbol;                     // symbol info object
//--- input parameters
input int      InpSeconds     = 40;          // Waiting for seconds
input ushort   InpTakeProfit  = 15;          // Take Profit (in pips)
//---
ulong          m_slippage=30;                // slippage
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   ResetLastError();
   if(!EventSetTimer(InpSeconds))
      Print(__FUNCTION__,", error create timer #",GetLastError());
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
//---
   m_trade.SetDeviationInPoints(m_slippage);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(TimeCurrent()-m_position.Time()>InpSeconds)
           {
            double ExtTakeProfit=0;
            double m_adjusted_point;               // point value adjusted for 3 or 5 points
            if(!InitTrade(m_position.Symbol(),m_position.Magic(),m_adjusted_point,ExtTakeProfit))
               continue;
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTakeProfit)
                  m_trade.PositionClose(m_position.Ticket());
               else
                 {
                  double tp=m_position.PriceOpen()+ExtTakeProfit;
                  if(CompareDoubles(tp,m_position.TakeProfit()))
                     continue;
                  if(tp-1.0*m_adjusted_point>m_position.PriceCurrent())
                     if(!m_trade.PositionModify(m_position.Ticket(),0.0,m_symbol.NormalizePrice(tp)))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTakeProfit)
                  m_trade.PositionClose(m_position.Ticket());
               else
                 {
                  double tp=m_position.PriceOpen()-ExtTakeProfit;
                  if(CompareDoubles(tp,m_position.TakeProfit()))
                     continue;
                  if(tp+1.0*m_adjusted_point<m_position.PriceCurrent())
                     if(!m_trade.PositionModify(m_position.Ticket(),0.0,m_symbol.NormalizePrice(tp)))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                 }
              }
           }
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2)
  {
   if(NormalizeDouble(number1-number2,Digits()-1)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Init trade object                                                |
//+------------------------------------------------------------------+
bool InitTrade(const string symbol,const ulong magic,double &adjusted_point,double &ext_take_profit)
  {
   if(!m_symbol.Name(symbol)) // sets symbol name
      return(false);

   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
   m_trade.SetExpertMagicNumber(magic);

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   adjusted_point=m_symbol.Point()*digits_adjust;

   ext_take_profit=InpTakeProfit*adjusted_point;
//---
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
