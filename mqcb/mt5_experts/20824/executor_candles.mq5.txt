//+------------------------------------------------------------------+
//|                                             Executor Candles.mq5 |
//|                           Copyright © 2006, Alex Sidd (Executer) |
//|                                           mailto:work_st@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, Alex Sidd (Executer)"
#property link      "mailto:work_st@mail.ru"
#property version   "1.002"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
CPositionInfo  m_position;                            // trade position object
CTrade         m_trade;                               // trading object
CSymbolInfo    m_symbol;                              // symbol info object
CAccountInfo   m_account;                             // account info wrapper
CMoneyFixedMargin *m_money;
//--- input parameters
input ushort   InpStopLossBuy          = 50;          // Stop Loss Buy (in pips)
input ushort   InpTakeProfitBuy        = 50;          // Take Profit Buy (in pips)
input ushort   InpTrailingStopBuy      = 15;          // Trailing Stop Buy (in pips)
input ushort   InpStopLossSell         = 50;          // Stop Loss Sell (in pips)
input ushort   InpTakeProfitSell       = 50;          // Take Profit Sell (in pips)
input ushort   InpTrailingStopSell     = 15;          // Trailing Stop Sell (in pips)
input ushort   InpTrailingStep         = 5;           // Trailing Step (in pips)
input double   InpLots                 = 0;           // Lots (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input double   Risk                    = 5;           // Risk (or "Lots">0 and "Risk"==0 or "Lots"==0 and "Risk">0)
input bool     InpMainTimeframeOff     = true;        // Off "Main timeframe"
input ENUM_TIMEFRAMES InpMainTimeframe = PERIOD_D1;   // Main timeframe (trend UP or DOWN)
input ulong    m_magic                 = 327692970;   // magic number
//---
ulong          m_slippage=10;                         // slippage

double         ExtStopLossBuy=0.0;
double         ExtTakeProfitBuy=0.0;
double         ExtTrailingStopBuy=0.0;
double         ExtStopLossSell=0.0;
double         ExtTakeProfitSell=0.0;
double         ExtTrailingStopSell=0.0;
double         ExtTrailingStep=0.0;

double         m_adjusted_point;             // point value adjusted for 3 or 5 points
MqlRates       m_rates[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpTrailingStopBuy!=0 && InpTrailingStep==0)
     {
      Alert(__FUNCTION__," ERROR: Trailing BUY is not possible: the parameter \"Trailing Step Buy\" is zero!");
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(InpTrailingStopSell!=0 && InpTrailingStep==0)
     {
      Alert(__FUNCTION__," ERROR: Trailing SELL is not possible: the parameter \"Trailing Step Sell\" is zero!");
      return(INIT_PARAMETERS_INCORRECT);
     }
//---
   if(!m_symbol.Name(Symbol())) // sets symbol name
      return(INIT_FAILED);
   RefreshRates();
//---
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
//---
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStopLossBuy       = InpStopLossBuy     * m_adjusted_point;
   ExtTakeProfitBuy     = InpTakeProfitBuy   * m_adjusted_point;
   ExtTrailingStopBuy   = InpTrailingStopBuy * m_adjusted_point;
   ExtStopLossSell      = InpStopLossSell    * m_adjusted_point;
   ExtTakeProfitSell    = InpTakeProfitSell  * m_adjusted_point;
   ExtTrailingStopSell  = InpTrailingStopSell* m_adjusted_point;
   ExtTrailingStep      = InpTrailingStep    * m_adjusted_point;
//---
   if(!LotsOrRisk(InpLots,Risk,digits_adjust))
      return(INIT_PARAMETERS_INCORRECT);
//---
   ArraySetAsSeries(m_rates,true);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(!IsPositionExists())
     {
      MqlRates rates_main_trend[1];
      if(CopyRates(m_symbol.Name(),InpMainTimeframe,1,1,rates_main_trend)!=1)
         return;
      bool trend_up=(rates_main_trend[0].open<rates_main_trend[0].close)?false:true;
      if(InpMainTimeframeOff)
         trend_up=false;

      if(CopyRates(m_symbol.Name(),Period(),0,4,m_rates)!=4)
         return;
      if(IsHammer(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossBuy==0)?0.0:m_symbol.Ask()-ExtStopLossBuy;
         double tp=(InpTakeProfitBuy==0)?0.0:m_symbol.Ask()+ExtTakeProfitBuy;
         OpenBuy(sl,tp);
         return;
        }
      if(IsBull(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossBuy==0)?0.0:m_symbol.Ask()-ExtStopLossBuy;
         double tp=(InpTakeProfitBuy==0)?0.0:m_symbol.Ask()+ExtTakeProfitBuy;
         OpenBuy(sl,tp);
         return;
        }
      if(IsPiercing(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossBuy==0)?0.0:m_symbol.Ask()-ExtStopLossBuy;
         double tp=(InpTakeProfitBuy==0)?0.0:m_symbol.Ask()+ExtTakeProfitBuy;
         OpenBuy(sl,tp);
         return;
        }
      if(IsMorningStar(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossBuy==0)?0.0:m_symbol.Ask()-ExtStopLossBuy;
         double tp=(InpTakeProfitBuy==0)?0.0:m_symbol.Ask()+ExtTakeProfitBuy;
         OpenBuy(sl,tp);
         return;
        }
      if(IsMorningDodgiStar(m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossBuy==0)?0.0:m_symbol.Ask()-ExtStopLossBuy;
         double tp=(InpTakeProfitBuy==0)?0.0:m_symbol.Ask()+ExtTakeProfitBuy;
         OpenBuy(sl,tp);
         return;
        }
      if(IsHangingMan(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossSell==0)?0.0:m_symbol.Bid()+ExtStopLossSell;
         double tp=(InpTakeProfitSell==0)?0.0:m_symbol.Bid()-ExtTakeProfitSell;
         OpenSell(sl,tp);
         return;
        }
      if(IsBear(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossSell==0)?0.0:m_symbol.Bid()+ExtStopLossSell;
         double tp=(InpTakeProfitSell==0)?0.0:m_symbol.Bid()-ExtTakeProfitSell;
         OpenSell(sl,tp);
         return;
        }
      if(IsDarkCloudCover(trend_up,m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossSell==0)?0.0:m_symbol.Bid()+ExtStopLossSell;
         double tp=(InpTakeProfitSell==0)?0.0:m_symbol.Bid()-ExtTakeProfitSell;
         OpenSell(sl,tp);
         return;
        }

      if(IsEveningStar(m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossSell==0)?0.0:m_symbol.Bid()+ExtStopLossSell;
         double tp=(InpTakeProfitSell==0)?0.0:m_symbol.Bid()-ExtTakeProfitSell;
         OpenSell(sl,tp);
         return;
        }
      if(IsEveningDodgiStar(m_rates))
        {
         if(!RefreshRates())
            return;
         double sl=(InpStopLossSell==0)?0.0:m_symbol.Bid()+ExtStopLossSell;
         double tp=(InpTakeProfitSell==0)?0.0:m_symbol.Bid()-ExtTakeProfitSell;
         OpenSell(sl,tp);
         return;
        }
     }
//---
   Trailing();
//---

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
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CheckVolumeValue(double volume,string &error_description)
  {
//--- minimal allowed volume for trade operations
   double min_volume=m_symbol.LotsMin();
   if(volume<min_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем меньше минимально допустимого SYMBOL_VOLUME_MIN=%.2f",min_volume);
      else
         error_description=StringFormat("Volume is less than the minimal allowed SYMBOL_VOLUME_MIN=%.2f",min_volume);
      return(false);
     }
//--- maximal allowed volume of trade operations
   double max_volume=m_symbol.LotsMax();
   if(volume>max_volume)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем больше максимально допустимого SYMBOL_VOLUME_MAX=%.2f",max_volume);
      else
         error_description=StringFormat("Volume is greater than the maximal allowed SYMBOL_VOLUME_MAX=%.2f",max_volume);
      return(false);
     }
//--- get minimal step of volume changing
   double volume_step=m_symbol.LotsStep();
   int ratio=(int)MathRound(volume/volume_step);
   if(MathAbs(ratio*volume_step-volume)>0.0000001)
     {
      if(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian")
         error_description=StringFormat("Объем не кратен минимальному шагу SYMBOL_VOLUME_STEP=%.2f, ближайший правильный объем %.2f",
                                        volume_step,ratio*volume_step);
      else
         error_description=StringFormat("Volume is not a multiple of the minimal step SYMBOL_VOLUME_STEP=%.2f, the closest correct volume is %.2f",
                                        volume_step,ratio*volume_step);
      return(false);
     }
   error_description="Correct volume value";
   return(true);
  }
//+------------------------------------------------------------------+
//| Lots or risk in percent for a deal from a free margin            |
//+------------------------------------------------------------------+
bool LotsOrRisk(const double lots,const double risk,const int digits_adjust)
  {
   if(lots<0.0 && risk<0.0)
     {
      Print(__FUNCTION__,", ERROR: Parameter (\"lots\" or \"risk\") can't be less than zero");
      return(false);
     }
   if(lots==0.0 && risk==0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" == 0.0 and \"risk\" == 0.0");
      return(false);
     }
   if(lots>0.0 && risk>0.0)
     {
      Print(__FUNCTION__,", ERROR: Trade is impossible: You have set \"lots\" > 0.0 and \"risk\" > 0.0");
      return(false);
     }
   if(lots>0.0)
     {
      string err_text="";
      if(!CheckVolumeValue(lots,err_text))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(false);
        }
     }
   else if(risk>0.0)
     {
      if(m_money!=NULL)
         delete m_money;
      m_money=new CMoneyFixedMargin;
      if(m_money!=NULL)
        {
         if(!m_money.Init(GetPointer(m_symbol),Period(),m_symbol.Point()*digits_adjust))
            return(INIT_FAILED);
         m_money.Percent(risk);
        }
      else
        {
         Print(__FUNCTION__,", ERROR: Object CMoneyFixedMargin is NULL");
         return(INIT_FAILED);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
bool IsPositionExists(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CompareDoubles(double number1,double number2,int digits)
  {
   digits--;
   if(digits<0)
      digits=0;
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Hammer                                                           |
//+------------------------------------------------------------------+
bool IsHammer(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[1].close,rates[1].open,m_symbol.Digits()))
      return(false);
   if((!trend_up) && 
      ( rates[1].open - rates[1].close < 0) &&
      ((rates[1].high - rates[1].close)* 100.0 / (rates[1].close - rates[1].open)>200.0) &&
      ((rates[1].open - rates[1].low)  * 100.0 / (rates[1].close - rates[1].open)<15.0) &&
      ( rates[2].open - rates[2].close > 0))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Bull                                                             |
//+------------------------------------------------------------------+
bool IsBull(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[2].open,rates[2].close,m_symbol.Digits()))
      return(false);
   if((!trend_up) && 
      ( rates[1].open  -  rates[1].close  < 0) &&
      ( rates[2].open  -  rates[2].close  > 0) &&
      ( rates[1].close >= rates[2].open)  &&
      ( rates[1].open  <= rates[2].close) &&
      ((rates[1].close -  rates[1].open)  / (rates[2].open - rates[2].close)>1.5))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Piercing                                                         |
//+------------------------------------------------------------------+
bool IsPiercing(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[2].high,rates[2].low,m_symbol.Digits()))
      return(false);
   if((!trend_up) && 
      ( rates[1].open  -  rates[1].close<0) &&
      ( rates[2].open  -  rates[2].close>0) &&
      ((rates[2].open  -  rates[2].close)   / (rates[2].high - rates[2].low)>0.6) &&
      ( rates[1].open  <  rates[2].low)     &&
      ( rates[1].close > (rates[2].close+(rates[2].open-rates[2].close)/2.0)))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| MorningStar                                                      |
//+------------------------------------------------------------------+
bool IsMorningStar(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[3].open,rates[3].close,m_symbol.Digits()))
      return(false);
   if(CompareDoubles(rates[3].high,rates[3].low,m_symbol.Digits()))
      return(false);
   if(CompareDoubles(rates[2].high,rates[2].low,m_symbol.Digits()))
      return(false);
   if(CompareDoubles(rates[1].high,rates[1].low,m_symbol.Digits()))
      return(false);
   if(( rates[3].open  - rates[3].close>0) &&
      ( rates[2].close - rates[2].open>0)  &&
      ( rates[1].close - rates[1].open>0)  &&
      ( rates[2].close < rates[3].close)   &&
      ( rates[1].open  > rates[2].close)   &&
      (((MathAbs(rates[3].open-rates[1].close)+MathAbs(rates[1].open-rates[3].close))/
      ( rates[3].open  - rates[3].close))  <  0.1) &&
      ((rates[3].open  - rates[3].close)   /  (rates[3].high - rates[3].low)>0.8) && ((rates[2].close-rates[2].open) /
      ( rates[2].high  - rates[2].low)     <  0.3) &&
      ( rates[1].close - rates[1].open)    /  (rates[1].high - rates[1].low)>0.8)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| MorningDodgiStar                                                 |
//+------------------------------------------------------------------+
bool IsMorningDodgiStar(MqlRates &rates[])
  {
   if(CompareDoubles(rates[3].open,rates[3].close,m_symbol.Digits()))
      return(false);
   if(( rates[3].open-rates[3].close>0) && 
      (rates[2].close-rates[2].open==0) && 
      ( rates[1].close -  rates[1].open>0) &&
      ( rates[2].close <= rates[3].close) &&
      ( rates[1].open  >= rates[2].close) &&
      (((MathAbs(rates[3].open-rates[1].close)+MathAbs(rates[1].open-rates[3].close))/
      (rates[3].open-rates[3].close))<0.1))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| HangingMan                                                       |
//+------------------------------------------------------------------+
bool IsHangingMan(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[1].open,rates[1].close,m_symbol.Digits()))
      return(false);
   if(( trend_up) && 
      ( rates[1].open  - rates[1].close>0) &&
      ((rates[1].high  - rates[1].open)*100.0 / (rates[1].open - rates[1].close) < 15.0) &&
      ((rates[1].close - rates[1].low)*100.0 / (rates[1].open - rates[1].close) > 200.0) &&
      ( rates[2].open  - rates[2].close<0))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Bear                                                             |
//+------------------------------------------------------------------+
bool IsBear(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[2].close,rates[2].open,m_symbol.Digits()))
      return(false);
   if((  trend_up) && 
      (  rates[1].open  -  rates[1].close>0) &&
      (  rates[1].open  >= rates[2].close) &&
      (  rates[1].close <= rates[2].open) &&
      (  rates[2].open  -  rates[2].close<0) &&
      (( rates[1].open  -  rates[1].close)/(rates[2].close-rates[2].open)>1.5))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| DarkCloudCover                                                   |
//+------------------------------------------------------------------+
bool IsDarkCloudCover(bool &trend_up,MqlRates &rates[])
  {
   if(CompareDoubles(rates[2].high,rates[2].low,m_symbol.Digits()))
      return(false);
   if(( trend_up) && 
      ( rates[1].open  -  rates[1].close>0) &&
      ( rates[2].open  -  rates[2].close<0) &&
      ((rates[2].close -  rates[2].open)/(rates[2].high-rates[2].low)>0.6) &&
      ( rates[1].open  >  rates[2].high) &&
      ( rates[1].close < (rates[2].open+(rates[2].close-rates[2].open)/2.0)))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| EveningStar                                                      |
//+------------------------------------------------------------------+
bool IsEveningStar(MqlRates &rates[])
  {
   if(CompareDoubles(rates[3].close,rates[3].open,m_symbol.Digits()))
      return(false);
   if(CompareDoubles(rates[3].high,rates[3].low,m_symbol.Digits()))
      return(false);
   if(CompareDoubles(rates[1].high,rates[1].low,m_symbol.Digits()))
      return(false);
   if((  rates[3].open  - rates[3].close<0) &&
      (  rates[2].close - rates[2].open<0) &&
      (  rates[1].close - rates[1].open<0) &&
      (  rates[2].close > rates[3].close) &&
      (  rates[1].open  < rates[2].close) &&
      (((MathAbs(rates[3].open-rates[1].close)+MathAbs(rates[1].open-rates[3].close))/
      (  rates[3].close - rates[3].open))<0.1) &&
      (( rates[3].close - rates[3].open)/(rates[3].high-rates[3].low)>0.8) && ((rates[2].open-rates[2].close)/
      (  rates[2].high  - rates[2].low)<0.3) &&
      (( rates[1].open  - rates[1].close)/(rates[1].high-rates[1].low)>0.8))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| EveningDodgiStar                                                 |
//+------------------------------------------------------------------+
bool IsEveningDodgiStar(MqlRates &rates[])
  {
   if(CompareDoubles(rates[3].open,rates[3].close,m_symbol.Digits()))
      return(false);
   if((rates[3].open-rates[3].close<0) && 
      (rates[2].close-rates[2].open==0) && 
      (rates[1].close -  rates[1].open<0) &&
      (rates[2].close >= rates[3].close) &&
      (rates[1].open  <= rates[2].close) &&
      (((MathAbs(rates[3].open-rates[1].close)+MathAbs(rates[1].open-rates[3].close))/
      (rates[3].open-rates[3].close))<0.1))
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void OpenBuy(double sl,double tp)
  {
   sl=m_symbol.NormalizePrice(sl);
   tp=m_symbol.NormalizePrice(tp);

   double check_open_long_lot=0.0;
   if(Risk>0.0)
     {
      check_open_long_lot=m_money.CheckOpenLong(m_symbol.Ask(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_long_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_long_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenLong returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_long_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_long_lot,m_symbol.Ask(),ORDER_TYPE_BUY);

   if(check_volume_lot!=0.0)
     {
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
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenLong ("+DoubleToString(check_open_long_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(check_volume_lot,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
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

   double check_open_short_lot=0.0;
   if(Risk>0.0)
     {
      check_open_short_lot=m_money.CheckOpenShort(m_symbol.Bid(),sl);
      Print("sl=",DoubleToString(sl,m_symbol.Digits()),
            ", CheckOpenLong: ",DoubleToString(check_open_short_lot,2),
            ", Balance: ",    DoubleToString(m_account.Balance(),2),
            ", Equity: ",     DoubleToString(m_account.Equity(),2),
            ", FreeMargin: ", DoubleToString(m_account.FreeMargin(),2));
      if(check_open_short_lot==0.0)
        {
         Print(__FUNCTION__,", ERROR: method CheckOpenShort returned the value of \"0.0\"");
         return;
        }
     }
   else
      check_open_short_lot=InpLots;
//--- check volume before OrderSend to avoid "not enough money" error (CTrade)
   double check_volume_lot=m_trade.CheckVolume(m_symbol.Name(),check_open_short_lot,m_symbol.Bid(),ORDER_TYPE_SELL);

   if(check_volume_lot!=0.0)
     {
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
      else
        {
         string text="";
         if(Risk>0.0)
            text="< method CheckOpenShort ("+DoubleToString(check_open_short_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(InpLots,2)+")";
         Print(__FUNCTION__,", ERROR: method CheckVolume (",DoubleToString(InpLots,2),") ",
               text);
         return;
        }
     }
   else
     {
      Print(__FUNCTION__,", ERROR: method CheckVolume returned the value of \"0.0\"");
      return;
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
//int d=0;
  }
//+------------------------------------------------------------------+
//| Trailing                                                         |
//+------------------------------------------------------------------+
void Trailing()
  {
   if(InpTrailingStopBuy==0 && InpTrailingStopSell==0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY && InpTrailingStopBuy>0)
              {
               if(m_position.PriceCurrent()-m_position.PriceOpen()>ExtTrailingStopBuy+ExtTrailingStep)
                  if(m_position.StopLoss()<m_position.PriceCurrent()-(ExtTrailingStopBuy+ExtTrailingStep))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()-ExtTrailingStopBuy),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                     continue;
                    }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL && InpTrailingStopSell>0)
              {
               if(m_position.PriceOpen()-m_position.PriceCurrent()>ExtTrailingStopSell+ExtTrailingStep)
                  if((m_position.StopLoss()>(m_position.PriceCurrent()+(ExtTrailingStopSell+ExtTrailingStep))) || 
                     (m_position.StopLoss()==0))
                    {
                     if(!m_trade.PositionModify(m_position.Ticket(),
                        m_symbol.NormalizePrice(m_position.PriceCurrent()+ExtTrailingStopSell),
                        m_position.TakeProfit()))
                        Print("Modify ",m_position.Ticket(),
                              " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                              ", description of result: ",m_trade.ResultRetcodeDescription());
                    }
              }

           }
  }
//+------------------------------------------------------------------+
