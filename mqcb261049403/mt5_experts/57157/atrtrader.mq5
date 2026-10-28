//+------------------------------------------------------------------+
//|                                                    atrTrader.mq5 |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://forge.mql5.io"
#property version   "1.00"


#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>

CPositionInfo m_position;
CTrade        m_trade;
CSymbolInfo   m_symbol;

input ulong    MagicNumber  = 123;   //  Магик ордера
input double   Lots         = 0.1;   //  Обьем сделки
input int      MaFast       = 70;    //  Период быстрой МА
input int      MaSlow       = 180;   //  Период медленной МА
input double   Step         = 4;     //  Шаг отката для входа в сделку в ATR
input double   Steps        = 2;     //  Шаг для открытия дополнительных сделок в ATR
input int      MPeriod      = 50;    //  Период за который МА не пересекаются в барах

double h_price = 0,
       l_price = 999;

double stp;
       
int    _atr, f_ma, s_ma;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
      if (!m_symbol.RefreshRates()) 
            return(INIT_FAILED);
      if (m_symbol.Ask() == 0 || m_symbol.Bid() == 0)
            return(INIT_FAILED);
            
      m_trade.SetExpertMagicNumber(MagicNumber);
      
      _atr = iATR(m_symbol.Name(), PERIOD_CURRENT, 100);
      if (_atr == INVALID_HANDLE)
      {
            Print("Не удалось получить хэндл ATR");
            return(INIT_FAILED);
      }
      f_ma = iMA(m_symbol.Name(), PERIOD_CURRENT, MaFast, 0, MODE_SMA, PRICE_CLOSE);
      if (f_ma == INVALID_HANDLE)
      {
            Print("Не удалось получить хэндл быстрой МА");
            return(INIT_FAILED);
      }
      s_ma = iMA(m_symbol.Name(), PERIOD_CURRENT, MaSlow, 0, MODE_SMA, PRICE_CLOSE);
      if (s_ma == INVALID_HANDLE)
      {
            Print("Не удалось получитьхэндл медленной МА");
            return(INIT_FAILED);
      }
      
      return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
      if(_atr != INVALID_HANDLE)
         IndicatorRelease(_atr);
      if(f_ma != INVALID_HANDLE)
         IndicatorRelease(f_ma);
      if(s_ma != INVALID_HANDLE)
         IndicatorRelease(s_ma);}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
      static datetime ltime = 0;
      datetime        ctime = iTime(m_symbol.Name(), PERIOD_CURRENT, 0);
      if (ctime == ltime)
            return;
      ltime = ctime;
      
      int        bufsize = 50;
      double     fma[];
      double     sma[];
      double     atr[];
      
      if (CopyBuffer(_atr, MAIN_LINE, 0, bufsize, atr) != bufsize)
      {
            Print("Не удалось скопировать данные хэндла ATR");
            ltime = 0;
      }
      if (CopyBuffer(f_ma, MAIN_LINE, 0, bufsize, fma) != bufsize)
      {
            Print("Не удалось скопировать данные хэндла быстрой МА");
            ltime = 0;
      }
      if (CopyBuffer(s_ma, MAIN_LINE, 0, bufsize, sma) != bufsize)
      {
            Print("Не удалось скопироавть данные хэндла медленной МА");
            ltime = 0;
      }
      
      ArraySetAsSeries(atr, true);
      ArraySetAsSeries(fma, true);
      ArraySetAsSeries(sma, true);
      
      if(CountDeals(POSITION_TYPE_BUY) == 0 && CountDeals(POSITION_TYPE_SELL) == 0)
      {
            m_symbol.RefreshRates();
            int m_period = 0;
            for (int i = 0; i < MPeriod; i++)
            {
                  if (fma[i] > sma[i]) m_period++;
            }
            if (m_period < MPeriod) m_period = 0;
            if (m_period == MPeriod && m_symbol.Ask() > sma[1])
            {
                  if (m_symbol.Ask() <= iHigh(_Symbol, PERIOD_CURRENT, iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, MPeriod, 0)) 
                           - Step * atr[iHighest(_Symbol, PERIOD_CURRENT, MODE_HIGH, MPeriod, 0)])
                  {
                        if (!CheckMoneyForTrade(_Symbol, GetLot(), ORDER_TYPE_BUY))
                        {
                              Print(GetLastError());
                              return;
                        }
                        if (!m_trade.Buy(NormalizeDouble(GetLot(), _Digits), _Symbol, m_symbol.Ask(), 0, 0))
                              Print("Не удалось открыть первый ордер на покупку");
                        m_period = 0;
                  }
            }
            m_period = 0;
            for(int i = 0; i < MPeriod; i++)
            {
                  if (fma[i] < sma[i]) m_period++;
            }
            if (m_period < MPeriod) m_period = 0;
            if (m_period == MPeriod && m_symbol.Bid() < sma[1])
            {
                  if (m_symbol.Bid() >= iLow(_Symbol, PERIOD_CURRENT, iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, MPeriod, 0)) 
                           + Step * atr[iLowest(_Symbol, PERIOD_CURRENT, MODE_LOW, MPeriod, 0)])
                  {
                        if (!CheckMoneyForTrade(_Symbol, GetLot(), ORDER_TYPE_SELL))
                        {
                              Print(GetLastError());
                              return;
                        }
                        if (!m_trade.Sell(NormalizeDouble(GetLot(), _Digits), _Symbol, m_symbol.Bid(), 0, 0))
                              Print("Не удалось открыть первую сделку на продажу");
                        m_period = 0;
                  }
            }
            h_price = 0;
            l_price = 999;
      }
      if (CountDeals(POSITION_TYPE_BUY) > 0 && CountDeals(POSITION_TYPE_BUY) < 3)
      {
            for(int i = PositionsTotal() - 1; i >= 0; i--)
            {
                  if (m_position.SelectByIndex(i))
                  {
                        if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber)
                        {
                              if (h_price <= m_position.PriceOpen()) h_price = m_position.PriceOpen();
                              if (l_price >= m_position.PriceOpen()) l_price = m_position.PriceOpen();
                        }
                  }
            }
            m_symbol.RefreshRates();
            if (m_symbol.Ask() >= h_price + Steps * atr[1])
            {
                        if (!CheckMoneyForTrade(_Symbol, GetLot(), ORDER_TYPE_BUY))
                        {
                              Print(GetLastError());
                              return;
                        }
                  if (!m_trade.Buy(NormalizeDouble(GetLot(), _Digits), _Symbol, m_symbol.Ask(), NormalizeDouble(m_symbol.Ask() - 3*Step * atr[1], _Digits), 0))
                        Print("Не удалось открыть добавочную позицию на покупку");
            }
            if (m_symbol.Ask() <= l_price - Steps * atr[1])
            {
                        if (!CheckMoneyForTrade(_Symbol, GetLot(), ORDER_TYPE_BUY))
                        {
                              Print(GetLastError());
                              return;
                        }
                  if (!m_trade.Buy(NormalizeDouble(GetLot(), _Digits), _Symbol, m_symbol.Ask(), NormalizeDouble(m_symbol.Bid() - 3*Step * atr[1], _Digits), 0))
                        Print("Не удалось открыть добавочную позицию на покупку");
            }
            h_price = 0;
            l_price = 999;
      }
      if (CountDeals(POSITION_TYPE_SELL) > 0 && CountDeals(POSITION_TYPE_SELL) < 3)
      {
            for(int i = PositionsTotal() - 1; i >= 0; i--)
            {
                  if (m_position.SelectByIndex(i))
                  {
                        if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber)
                        {
                              if (h_price <= m_position.PriceOpen()) h_price = m_position.PriceOpen();
                              if (l_price >= m_position.PriceOpen()) l_price = m_position.PriceOpen();
                        }
                  }
            }
            m_symbol.RefreshRates();
            if (m_symbol.Bid() >= h_price + Steps * atr[1])
            {
                        if (!CheckMoneyForTrade(_Symbol, GetLot(), ORDER_TYPE_SELL))
                        {
                              Print(GetLastError());
                              return;
                        }
                  if (!m_trade.Sell(NormalizeDouble(GetLot(), _Digits), _Symbol, m_symbol.Bid(), NormalizeDouble(m_symbol.Bid() + 3*Step * atr[1], _Digits), 0))
                        Print("Не удалось открыть добавочную позицию на продажу");
            }
            if (m_symbol.Bid() <= l_price - Steps * atr[1])
            {
                        if (!CheckMoneyForTrade(_Symbol, GetLot(), ORDER_TYPE_SELL))
                        {
                              Print(GetLastError());
                              return;
                        }
                  if (!m_trade.Sell(NormalizeDouble(GetLot(), _Digits), _Symbol, m_symbol.Bid(), NormalizeDouble(m_symbol.Bid() + 3*Step * atr[1], _Digits), 0))
                        Print("Не удалось открыть добавочную позицию на продажу");
            }
            h_price = 0;
            l_price = 999;
      }
      if (CountDeals(POSITION_TYPE_BUY) >= 3)
      {
            double last_sl = 0;
            double cur_sl  = 0;
            for(int i = PositionsTotal() - 1; i >= 0; i--)
            {
                  if (m_position.SelectByIndex(i))
                  {
                        if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber)
                        {
                              if (h_price <= m_position.PriceOpen()) h_price = m_position.PriceOpen();
                              if (l_price >= m_position.PriceOpen()) l_price = m_position.PriceOpen();
                              cur_sl = m_position.StopLoss();
                              if (cur_sl > last_sl) last_sl = cur_sl;
                        }
                  }
            }
            m_symbol.RefreshRates();
            if (m_symbol.Ask() > NormalizeDouble(last_sl + Step * atr[1], _Digits))
            {
                  for (int i = PositionsTotal() - 1; i >= 0; i--)
                  {
                        if (m_position.SelectByIndex(i))
                        {
                              if (last_sl != m_position.StopLoss())
                              if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber)
                              {
                                    if (m_position.StopLoss() != NormalizeDouble(last_sl - Step * atr[1], _Digits))
                                    if (!m_trade.PositionModify(m_position.Ticket(), NormalizeDouble(m_symbol.Ask() - Step * atr[1], _Digits),0))
                                          Print("Не удалось модифицировать стоплосс");
                                          Print(GetLastError());
                              }
                        }
                  }
            }
            if (m_symbol.Bid() <= NormalizeDouble(l_price - Steps * atr[1], _Digits))
            {
                  for (int i = PositionsTotal() - 1; i >= 0; i--)
                  {
                        if (m_position.SelectByIndex(i))
                        {
                              if (!m_trade.PositionClose(m_position.Ticket(), 20)) Print("Не удалось закрыть позицию");
                        }
                  }
            }
            
            h_price = 0;
            l_price = 999;
      }
      if (CountDeals(POSITION_TYPE_SELL) >= 3)
      {
            double last_sl = 99;
            double cur_sl  = 0;
            for(int i = PositionsTotal() - 1; i >= 0; i--)
            {
                  if (m_position.SelectByIndex(i))
                  {
                        if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber)
                        {
                              if (h_price <= m_position.PriceOpen()) h_price = m_position.PriceOpen();
                              if (l_price >= m_position.PriceOpen()) l_price = m_position.PriceOpen();
                              cur_sl = m_position.StopLoss();
                              if (cur_sl < last_sl && cur_sl > 0) last_sl = cur_sl;
                        }
                  }
            }
            m_symbol.RefreshRates();
            if (m_symbol.Bid() < last_sl - Step * atr[1])
            {
                  for (int i = PositionsTotal() - 1; i >= 0; i--)
                  {
                        if (m_position.SelectByIndex(i))
                        {
                              if (NormalizeDouble(m_symbol.Bid() + Step * atr[1], _Digits) - m_symbol.Ask() > 0.0010 &&
                                       NormalizeDouble(m_symbol.Bid() + Step * atr[1], _Digits) != last_sl)
                              if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber)
                              {
                                    if (!m_trade.PositionModify(m_position.Ticket(), NormalizeDouble(m_symbol.Bid() + Step * atr[1], _Digits),0))
                                          Print("Не удалось модифицировать стоплосс");
                                          Print(GetLastError());
                              }
                        }
                  }
            }
            if (m_symbol.Bid() >= h_price + Steps * atr[1])
            {
                  for (int i = PositionsTotal() - 1; i >= 0; i--)
                  {
                        if (m_position.SelectByIndex(i))
                        {
                              if (!m_trade.PositionClose(m_position.Ticket(), 20)) Print("Не удалось закрыть позицию");
                        }
                  }
            }
            
            h_price = 0;
            l_price = 999;
      }
}
//+------------------------------------------------------------------+
int CountDeals(ENUM_POSITION_TYPE pos_type)
{
      int count = 0;
      for (int i = PositionsTotal() - 1; i >= 0; i--)
      {
            if (m_position.SelectByIndex(i))
               {
                     if (m_position.Symbol() == _Symbol && m_position.Magic() == MagicNumber && m_position.PositionType() == pos_type)
                     {
                           count++;
                     }
               }
      }
      return(count);
}
//+------------------------------------------------------------------+
double GetLot()
{
      double lot = Lots; 
      double min_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN); 
      double max_volume = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      if(lot < min_volume) lot = min_volume;
      if(lot > max_volume) lot = max_volume;
      return(lot);
}
//+------------------------------------------------------------------+
bool CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- получим цену открытия
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- значения необходимой и свободной маржи
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   //--- вызовем функцию проверки
   if(!OrderCalcMargin(type,symb,lots,price,margin))
     {
      //--- что-то пошло не так, сообщим и вернем false
      Print("Error in ",__FUNCTION__," code=",GetLastError());
      return(false);
     }
   //--- если не хватает средств на проведение операции
   if(margin>free_margin)
     {
      //--- сообщим об ошибке и вернем false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- проверка прошла успешно
   return(true);
  }