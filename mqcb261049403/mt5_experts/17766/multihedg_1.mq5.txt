//+------------------------------------------------------------------+
//|                         MultiHedg_1(barabashkakvn's edition).mq5 |
//|                                                     Yuriy Tokman |
//|                                            yuriytokman@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Yuriy Tokman"
#property link      "yuriytokman@gmail.com"
#property version   "1.000"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
CPositionInfo  m_position;                   // trade position object
CTrade         m_trade;                      // trading object
CSymbolInfo    m_symbols0;                   // symbol info object
CSymbolInfo    m_symbols1;                   // symbol info object
CSymbolInfo    m_symbols2;                   // symbol info object
CSymbolInfo    m_symbols3;                   // symbol info object
CSymbolInfo    m_symbols4;                   // symbol info object
CSymbolInfo    m_symbols5;                   // symbol info object
CSymbolInfo    m_symbols6;                   // symbol info object
CSymbolInfo    m_symbols7;                   // symbol info object
CSymbolInfo    m_symbols8;                   // symbol info object
CSymbolInfo    m_symbols9;                   // symbol info object
CAccountInfo   m_account;                    // account info wrapper
//---
//-- 0
input bool      Use_Symbol0=true;
sinput string   Symbol0="EURUSD";
input double    Symbol0_Lot=0.1;
//-- 1
input bool      Use_Symbol1=true;
sinput string   Symbol1="GBPUSD";
input double    Symbol1_Lot=0.2;
//-- 2
input bool      Use_Symbol2=true;
sinput string   Symbol2="GBPJPY";
input double    Symbol2_Lot=0.3;
//-- 3
input bool      Use_Symbol3=true;
sinput string   Symbol3="EURCAD";
input double    Symbol3_Lot=0.4;
//-- 4
input bool      Use_Symbol4=true;
sinput string   Symbol4="USDCHF";
input double    Symbol4_Lot=0.5;
//-- 5
input bool      Use_Symbol5=true;
sinput string   Symbol5="USDJPY";
input double    Symbol5_Lot=0.6;
//-- 6
input bool      Use_Symbol6=false;
sinput string   Symbol6="USDCHF";
input double    Symbol6_Lot=0.7;
//-- 7
input bool      Use_Symbol7=false;
sinput string   Symbol7="GBPUSD";
input double    Symbol7_Lot=0.8;
//-- 8
input bool      Use_Symbol8=false;
sinput string   Symbol8="EURUSD";
input double    Symbol8_Lot=0.9;
//-- 9
input bool      Use_Symbol9=false;
sinput string   Symbol9="USDJPY";
input double    Symbol9_Lot=1;
//---
sinput string _____1_____     = "Настройки закрытия позиции";
input bool   TimeClose        = true;        // Время закрытия позиции позиции
input string CloseTime        = "20:50";     // Время закрытия позиции
input bool   ClosePercent     = true;        //закрытия позиции по процентам
input double PercentProfit    = 1.00;        // Процент профита
input double PercentLoss      = 55.00;       // Процент убытка
sinput string _____2_____     = "Настройки открытия позиции";
input ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;       //
input string TimeTrade        = "19:51";     // Время открытия позиции
input int    Duration         = 300;         // Продолжительность в секундах
//--- Параметры советника
ulong    m_magic        = 28081975;
bool     UseSound       = true;              // Использовать звуковой сигнал
string   NameFileSound  = "expert.wav";      // Наименование звукового файла
bool     ShowComment    = true;              // Показывать комментарий
ulong    m_slippage     = 30;                // Проскальзывание цены
//---Глобальные переменные советника 
bool  gbDisabled = false;         // Флаг блокировки советника
bool  gbNoInit   = false;         // Флаг неудачной инициализации
color clOpenBuy  = LightBlue;     // Цвет значка открытия покупки
color clOpenSell = LightCoral;    // Цвет значка открытия продажи
//---
ENUM_ACCOUNT_MARGIN_MODE m_margin_mode;
double         m_adjusted_point_arr[10];     // point value adjusted for 3 or 5 points
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetMarginMode();
   if(!IsHedging())
     {
      Print("Hedging only!");
      return(INIT_FAILED);
     }
//---
   IsTradeAllowed();
   if(!InitSymbols())
     {
      Print("Init Symbols failed");
      return(INIT_FAILED);
     }
//---
   int digits_adjust=1;

   m_symbols0.Name(Symbol0);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols0.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols0.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols0.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols0.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols0.Digits()==3 || m_symbols0.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[0]=m_symbols0.Point()*digits_adjust;
//---
   m_symbols1.Name(Symbol1);
   if(!RefreshRates(m_symbols1))
     {
      Print(m_symbols1.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols1.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols1.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols1.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols1.Digits()==3 || m_symbols1.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[1]=m_symbols1.Point()*digits_adjust;
//---
   m_symbols2.Name(Symbol2);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols2.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols2.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols2.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols2.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols2.Digits()==3 || m_symbols2.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[2]=m_symbols2.Point()*digits_adjust;
//---
   m_symbols3.Name(Symbol3);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols3.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols3.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols3.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols3.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols3.Digits()==3 || m_symbols3.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[3]=m_symbols3.Point()*digits_adjust;
//---
   m_symbols4.Name(Symbol4);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols4.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols4.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols4.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols4.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols4.Digits()==3 || m_symbols4.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[4]=m_symbols4.Point()*digits_adjust;
//---
   m_symbols5.Name(Symbol5);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols5.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols5.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols5.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols5.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols5.Digits()==3 || m_symbols5.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[5]=m_symbols5.Point()*digits_adjust;
//---
   m_symbols6.Name(Symbol6);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols6.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols6.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols6.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols6.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols6.Digits()==3 || m_symbols6.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[6]=m_symbols6.Point()*digits_adjust;
//---
   m_symbols7.Name(Symbol7);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols7.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols7.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols7.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols7.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols7.Digits()==3 || m_symbols7.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[7]=m_symbols7.Point()*digits_adjust;
//---
   m_symbols8.Name(Symbol8);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols8.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols8.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols8.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols8.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols8.Digits()==3 || m_symbols8.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[8]=m_symbols8.Point()*digits_adjust;
//---
   m_symbols9.Name(Symbol9);
   if(!RefreshRates(m_symbols0))
     {
      Print(m_symbols9.Name(),": error RefreshRates. Bid=",DoubleToString(m_symbols9.Bid(),Digits()),
            ", Ask=",DoubleToString(m_symbols9.Ask(),Digits()));
      return(INIT_FAILED);
     }
   m_symbols9.Refresh();
//--- tuning for 3 or 5 digits
   digits_adjust=1;
   if(m_symbols9.Digits()==3 || m_symbols9.Digits()==5)
      digits_adjust=10;
   m_adjusted_point_arr[9]=m_symbols9.Point()*digits_adjust;
//---
   m_trade.SetExpertMagicNumber(m_magic);
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
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(ShowComment)
     {
      string st="\nCurTime="+TimeToString(TimeCurrent(),TIME_MINUTES)+
                "  TimeTrade="+TimeTrade+(TimeClose?"  CloseTime="+CloseTime:"")+
                (ClosePercent?"  PercentProfit="+DoubleToString(PercentProfit,2)+"  PercentLoss="+DoubleToString(PercentLoss,2):"")+
                "  Позиция="+EnumToString(PosType)+
                (Use_Symbol0?"\n\nSymbo0 0 = "+Symbol0:"")+
                (Use_Symbol0?"  Lot= "+DoubleToString(Symbol0_Lot,2):"");
      string st1=(Use_Symbol1?"\nSymbol 1 = "+Symbol1:"")+
                 (Use_Symbol1?"  Lot= "+DoubleToString(Symbol1_Lot,2):"")+
                 (Use_Symbol2?"\nSymbol 2 = "+Symbol2:"")+
                 (Use_Symbol2?"  Lot= "+DoubleToString(Symbol2_Lot,2):"")+
                 (Use_Symbol3?"\nSymbol 3 = "+Symbol3:"")+
                 (Use_Symbol3?"  Lot= "+DoubleToString(Symbol3_Lot,2):"")+
                 (Use_Symbol4?"\nSymbol 4 = "+Symbol4:"");

      string st2=(Use_Symbol4?"  Lot= "+DoubleToString(Symbol4_Lot,2):"")+
                 (Use_Symbol5?"\nSymbol 5 = "+Symbol5:"")+
                 (Use_Symbol5?"  Lot= "+DoubleToString(Symbol5_Lot,2):"")+
                 (Use_Symbol6?"\nSymbol 6 = "+Symbol6:"")+
                 (Use_Symbol6?"  Lot= "+DoubleToString(Symbol6_Lot,2):"")+
                 (Use_Symbol7?"\nSymbol 7 = "+Symbol7:"")+
                 (Use_Symbol7?"  Lot= "+DoubleToString(Symbol7_Lot,2):"");

      string st3=(Use_Symbol8?"\nSymbol 8 = "+Symbol8:"")+
                 (Use_Symbol8?"  Lot= "+DoubleToString(Symbol8_Lot,2):"")+
                 (Use_Symbol9?"\nSymbol 9 = "+Symbol9:"")+
                 (Use_Symbol9?"  Lot= "+DoubleToString(Symbol9_Lot,2):"")+
                 "\n\nТекущие: Баланс="+DoubleToString(m_account.Balance(),2)+
                 "\n              Эквити="+DoubleToString(m_account.Equity(),2)+
                 "\n              Прибыль="+DoubleToString((m_account.Equity()/m_account.Balance()-1)*100,3)+" %";
      Comment(st+st1+st2+st3);
     }
   else Comment("");
//---
   if(ClosePercent)
     {
      if(m_account.Equity()>=m_account.Balance()*(1+PercentProfit/100)
         || m_account.Equity()<=m_account.Balance()*(1-PercentLoss/100))
        {
         CloseAllPositions();
         return;
        }
     }
//---
   if(TimeClose)
     {
      if(TimeCurrent()>=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+CloseTime)
         && TimeCurrent()<StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+CloseTime)+Duration)
        {
         CloseAllPositions();
         return;
        }
     }
//---
   if(TimeCurrent()>=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeTrade)
      && TimeCurrent()<StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+TimeTrade)+Duration)
     {
      //----------------------------0
      if(Use_Symbol0 && !ExistPositions(m_symbols0.Name(),PosType))
         OpenPosition(m_symbols0.Name(),PosType,Symbol0_Lot);
      //----------------------------1     
      if(Use_Symbol1 && !ExistPositions(m_symbols1.Name(),PosType))
         OpenPosition(m_symbols1.Name(),PosType,Symbol1_Lot);
      //----------------------------2  
      if(Use_Symbol2 && !ExistPositions(m_symbols2.Name(),PosType))
         OpenPosition(m_symbols2.Name(),PosType,Symbol2_Lot);
      //----------------------------3  
      if(Use_Symbol3 && !ExistPositions(m_symbols3.Name(),PosType))
         OpenPosition(m_symbols3.Name(),PosType,Symbol3_Lot);
      //----------------------------4  
      if(Use_Symbol4 && !ExistPositions(m_symbols4.Name(),PosType))
         OpenPosition(m_symbols4.Name(),PosType,Symbol4_Lot);
      //----------------------------5  
      if(Use_Symbol5 && !ExistPositions(m_symbols5.Name(),PosType))
         OpenPosition(m_symbols5.Name(),PosType,Symbol5_Lot);
      //----------------------------6 
      if(Use_Symbol6 && !ExistPositions(m_symbols6.Name(),PosType))
         OpenPosition(m_symbols6.Name(),PosType,Symbol6_Lot);
      //----------------------------7   
      if(Use_Symbol7 && !ExistPositions(m_symbols7.Name(),PosType))
         OpenPosition(m_symbols7.Name(),PosType,Symbol7_Lot);
      //----------------------------8   
      if(Use_Symbol8 && !ExistPositions(m_symbols8.Name(),PosType))
         OpenPosition(m_symbols8.Name(),PosType,Symbol8_Lot);
      //----------------------------9   
      if(Use_Symbol9 && !ExistPositions(m_symbols9.Name(),PosType))
         OpenPosition(m_symbols9.Name(),PosType,Symbol9_Lot);
     }
  }
//+------------------------------------------------------------------+
//| Gets the information about permission to trade                   |
//+------------------------------------------------------------------+
bool IsTradeAllowed()
  {
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
     {
      Alert("Check if automated trading is allowed in the terminal settings!");
      return(false);
     }
   else
     {
      if(!MQLInfoInteger(MQL_TRADE_ALLOWED))
        {
         Alert("Automated trading is forbidden in the program settings for ",__FILE__);
         return(false);
        }
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))
     {
      Alert("Automated trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
            " at the trade server side");
      return(false);
     }
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))
     {
      Comment("Trading is forbidden for the account ",AccountInfoInteger(ACCOUNT_LOGIN),
              ".\n Perhaps an investor password has been used to connect to the trading account.",
              "\n Check the terminal journal for the following entry:",
              "\n\'",AccountInfoInteger(ACCOUNT_LOGIN),"\': trading has been disabled - investor mode.");
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Find symbols in MarketWatch                                      |
//+------------------------------------------------------------------+
bool InitSymbols(const string symbol0="EURUSD",const string symbol1="GBPUSD",const string symbol2="GBPJPY",
                 const string symbol3="EURCAD",const string symbol4="USDCHF",const string symbol5="USDJPY",
                 const string symbol6="USDCHF",const string symbol7="GBPUSD",const string symbol8="EURUSD",
                 const string symbol9="USDJPY")
  {
   bool result=true;
   int count=0;

   while(!result || count>3)
     {
      bool select0=SymbolSelect(symbol0,true);
      bool select1=SymbolSelect(symbol1,true);
      bool select2=SymbolSelect(symbol2,true);
      bool select3=SymbolSelect(symbol3,true);
      bool select4=SymbolSelect(symbol4,true);
      bool select5=SymbolSelect(symbol5,true);
      bool select6=SymbolSelect(symbol6,true);
      bool select7=SymbolSelect(symbol7,true);
      bool select8=SymbolSelect(symbol8,true);
      bool select9=SymbolSelect(symbol9,true);

      if(!select0 || !select1 || !select2 || 
         !select3 || !select4 || !select5 || 
         !select6 || !select7 || !select8 || 
         !select9)
        {
         result=false;
         Sleep(1000);
        }
      else
         result=true;

      count++;
     }

   return(result);
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
bool RefreshRates(CSymbolInfo  &m_symbol)
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
//| Close Positions                                                  |
//+------------------------------------------------------------------+
void CloseAllPositions()
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Magic()==m_magic)
            m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExistPositions(const string name,ENUM_POSITION_TYPE pos_type)
  {
   bool result=false;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==name && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               return(true);

   return(result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenPosition(const string name,ENUM_POSITION_TYPE pos_type,const double lot)
  {
   if(pos_type==POSITION_TYPE_BUY)
      m_trade.Buy(lot,name);
   else if(pos_type==POSITION_TYPE_SELL)
      m_trade.Sell(lot,name);
  }
//+------------------------------------------------------------------+
