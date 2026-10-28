//+------------------------------------------------------------------+
//|                                                       Moving.mqh |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.001"
//---
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\AccountInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMoving
  {
private:
   CPositionInfo     m_position;                   // trade position object
   CTrade            m_trade;                      // trading object
   CSymbolInfo       m_symbol;                     // symbol info object
   CAccountInfo      m_account;                    // account info wrapper
   CDealInfo         m_deal;                       // deals object
   COrderInfo        m_order;                      // pending orders object
   CMoneyFixedMargin *m_money;
   ulong             m_magic;
   ulong             m_slippage;
   bool              m_init;                       // initialization flag
   double            m_lots;                       // lots
   double            m_risk;                       // risk in percent for a deal from a free margin
   int               digits_adjust;
   double            m_adjusted_point;             // point value adjusted for 3 or 5 points
   int               handle_iMA;                   // variable for storing the handle of the iMA indicator 
   double            m_take_profit;                // take profit (in pips) (only if one position is open)
   double            m_multiplier;                 // lot multiplier for a series of Positions
   double            m_distance_MA;                // distance from Moving Average (in pips) 
   double            m_profit_plus;                // additive in the presence of the general profit (in pips)

public:
                     CMoving();
                    ~CMoving();
   //--- initialization
   bool              Initialization(const string symbol,const ulong magic,const ulong slippage);
   bool              GetFlag(void) const                    { return(m_init);                      }
   //--- lots or risk in percent for a deal from a free margin
   bool              LotsOrRisk(const double lots,const double risk);
   //--- create handle of the indicator iMA
   bool              CreateMA(const ENUM_TIMEFRAMES MA_period,
                              const int MA_ma_period,
                              const int MA_ma_shift,
                              const ENUM_MA_METHOD MA_ma_method,
                              const ENUM_APPLIED_PRICE MA_applied_price);
   //--- take profit (in pips) (only if one position is open)
   void              TakeProfit(const ushort take_profit) { m_take_profit=take_profit*m_adjusted_point;   }
   //--- lot multiplier for a series of Positions
   void              Multiplier(const double multiplier) { m_multiplier=multiplier;                      }
   //--- distance from Moving Average (in pips) 
   void              DistanceMA(const ushort distance_MA) { m_distance_MA=distance_MA*m_adjusted_point;   }
   //--- additive in the presence of the general profit (in pips) 
   void              ProfitPlus(const ushort profit_plus) { m_profit_plus=profit_plus*m_adjusted_point;   }
   //--- main function
   void              Processing(void);
   //--- calculate all positions                                          

protected:
   bool              RefreshRates(void);
   //-- check the correctness of the position volume
   bool              CheckVolumeValue(const double volume,string &error_description);
   //--- checks if the specified filling mode is allowed 
   bool              IsFillingTypeAllowed(const int fill_type);
   //--- get value of buffers for the iMA
   double            iMAGet(const int index);
   //--- calculate all positions   
   void              CalculateAllPositions(int &count_buys,double &price_highest_buy,double &price_lowest_buy,double &lot_highest_buy,double &lot_lowest_buy,double &total_lots_buy,
                                           int &count_sells,double &price_lowest_sell,double &price_highest_sell,double &lot_lowest_sell,double &lot_highest_sell,double &total_lots_sell);
   //--- prices for buy and sell positions
   void              Prices(double &price_for_buy,double &price_for_sell);
   //--- lot Check                                                        
   double            LotCheck(double lots);
   //--- open buy position                                                
   void              OpenBuy(double multiplier=0.0);
   //--- open sell position                                                
   void              OpenSell(double multiplier=0.0);
   //--- print CTrade result                                            
   void              PrintResult(CTrade &trade,CSymbolInfo &symbol);
   //--- set take profit
   void              SetTakeProfit(bool delete_take_profit=false);
   //--- compare doubles                                            
   bool              CompareDoubles(double number1,double number2,int digits);
   //--- 
   void              AwerageTakeProfit(const ENUM_POSITION_TYPE pos_type);
   //--- for debugging
   void              PrintPositons(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CMoving::CMoving(void) : m_init(false),
                         m_lots(0.0),
                         m_risk(0.0),
                         digits_adjust(1),
                         handle_iMA(INVALID_HANDLE),
                         m_take_profit(0),
                         m_multiplier(1),
                         m_distance_MA(200),
                         m_profit_plus(0)

  {
   Print(__FUNCTION__);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CMoving::~CMoving()
  {
   Print(__FUNCTION__);
   if(m_money!=NULL)
      delete m_money;
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CMoving::Initialization(const string symbol,const ulong magic,const ulong slippage)
  {
   if(!m_symbol.Name(symbol)) // sets symbol name
      return(false);
   RefreshRates();
   m_magic=magic;
   m_trade.SetExpertMagicNumber(m_magic);
//---
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
//---
   m_slippage=slippage;
   m_trade.SetDeviationInPoints(m_slippage);
//--- tuning for 3 or 5 digits
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   m_init=true;
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool CMoving::RefreshRates(void)
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
//| Lots or risk in percent for a deal from a free margin            |
//+------------------------------------------------------------------+
bool CMoving::LotsOrRisk(const double lots,const double risk)
  {
   if(!m_init)
     {
      Print(__FUNCTION__,", ERROR: It is necessary to cause the CMoving::Initialization method at first");
      return(false);
     }
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
      m_lots=lots;
      string err_text="";
      if(!CheckVolumeValue(lots,err_text))
        {
         Print(__FUNCTION__,", ERROR: ",err_text);
         return(false);
        }
     }
   else if(risk>0.0)
     {
      m_risk=risk;
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
//| Check the correctness of the position volume                     |
//+------------------------------------------------------------------+
bool CMoving::CheckVolumeValue(const double volume,string &error_description)
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
bool CMoving::IsFillingTypeAllowed(const int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=m_symbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//| Create handle of the indicator iMA                               |
//+------------------------------------------------------------------+
bool CMoving::CreateMA(const ENUM_TIMEFRAMES MA_period,
                       const int MA_ma_period,
                       const int MA_ma_shift,
                       const ENUM_MA_METHOD MA_ma_method,
                       const ENUM_APPLIED_PRICE MA_applied_price)
  {
   handle_iMA=iMA(m_symbol.Name(),MA_period,MA_ma_period,MA_ma_shift,MA_ma_method,MA_applied_price);
//--- if the handle is not created 
   if(handle_iMA==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  m_symbol.Name(),
                  EnumToString(MA_period),
                  GetLastError());
      //--- the indicator is stopped early 
      return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get value of buffers for the iMA                                 |
//+------------------------------------------------------------------+
double CMoving::iMAGet(const int index)
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
//| Calculate all positions                                          |
//+------------------------------------------------------------------+  
void CMoving::CalculateAllPositions(int &count_buys,double &price_highest_buy,double &price_lowest_buy,double &lot_highest_buy,double &lot_lowest_buy,double &total_lots_buy,
                                    int &count_sells,double &price_lowest_sell,double &price_highest_sell,double &lot_lowest_sell,double &lot_highest_sell,double &total_lots_sell)
  {
   count_buys  =0;   price_highest_buy =DBL_MIN;   price_lowest_buy     =DBL_MAX;   lot_highest_buy   =0.0; lot_lowest_buy=0.0;
   count_sells =0;   price_lowest_sell =DBL_MAX;   price_highest_sell   =DBL_MIN;   lot_lowest_sell   =0.0; lot_highest_sell=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               count_buys++;
               total_lots_buy+=m_position.Volume();
               if(m_position.PriceOpen()>price_highest_buy) // the highest position of "BUY" is found
                 {
                  price_highest_buy    =m_position.PriceOpen();
                  lot_highest_buy      =m_position.Volume();
                 }
               else if(m_position.PriceOpen()<price_lowest_buy) // the lowest position of "BUY" is found
                 {
                  price_lowest_buy     =m_position.PriceOpen();
                  lot_lowest_buy       =m_position.Volume();
                 }
               continue;
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               count_sells++;
               total_lots_sell+=m_position.Volume();
               if(m_position.PriceOpen()<price_lowest_sell) // the lowest position of "SELL" is found
                 {
                  price_lowest_sell    =m_position.PriceOpen();
                  lot_lowest_sell      =m_position.Volume();
                 }
               else if(m_position.PriceOpen()>price_highest_sell) // the highest position of "SELL" is found
                 {
                  price_highest_sell   =m_position.PriceOpen();
                  lot_highest_sell     =m_position.Volume();
                 }
               continue;
              }
           }
  }
//+------------------------------------------------------------------+
//| Processing                                                       |
//+------------------------------------------------------------------+
void CMoving::Processing(void)
  {
   int count_buys;double price_highest_buy;double price_lowest_buy;double lot_highest_buy;double lot_lowest_buy;double total_lots_buy;
   int count_sells;double price_lowest_sell;double price_highest_sell;double lot_lowest_sell;double lot_highest_sell;double total_lots_sell;
//---
   CalculateAllPositions(count_buys,price_highest_buy,price_lowest_buy,lot_highest_buy,lot_lowest_buy,total_lots_buy,
                         count_sells,price_lowest_sell,price_highest_sell,lot_lowest_sell,lot_highest_sell,total_lots_sell);
   if(!RefreshRates())
      return;
   double price_for_buy=0.0;  double price_for_sell=0.0;
   Prices(price_for_buy,price_for_sell);
//--- check of a condition for opening of buy of a position
   if((count_buys==0 && m_symbol.Ask()>=price_for_buy) || (count_buys>0 && m_symbol.Ask()>=(price_highest_buy+m_distance_MA)))
     {
      if(m_multiplier>1)
        {
         if(count_buys>0) // open buy a position, having caused a method from a class
            OpenBuy(m_multiplier); // if there are already positions that will increase lot by NNN times 
         else
            OpenBuy(); // open buy a position, volume m_lots
        }
      else
         OpenBuy(); // open buy a position, volume m_lots
      //---
      return;
     }
//--- check of a condition for opening of sell of a position
   if((count_sells==0 && m_symbol.Bid()<=price_for_sell) || (count_sells>0 && m_symbol.Bid()<=(price_lowest_sell-m_distance_MA)))
     {
      if(m_multiplier>1)
        {
         if(count_sells>0) // open sell a position, having caused a method from a class
            OpenSell(m_multiplier); // if there are already positions that will increase lot by NNN times 
         else
            OpenSell(); // open sell a position, volume m_lots
        }
      else
         OpenSell(); // open sell a position, volume m_lots
      //---
      return;
     }
//--- if there is one buy position or one sell position
   if((count_buys==1 && count_sells==0) || (count_buys==0 && count_sells==1))
     {
      SetTakeProfit();                 // set take profit
      return;
     }
//--- if positions equal quantity and their more than zero
   if(count_buys==count_sells && count_buys>0)
     {
      SetTakeProfit(true);             // delete take profit and stop loss
      return;
     }
   else if(count_buys>0 && count_sells>0)
     {
      if(!CompareDoubles(total_lots_buy,total_lots_sell,m_symbol.Digits()))
        {
         if(total_lots_buy>total_lots_sell)
            AwerageTakeProfit(POSITION_TYPE_BUY);  // if the lots of BUY are larger than the SELL lots, we will establish a single take profit
         if(total_lots_buy<total_lots_sell)
            AwerageTakeProfit(POSITION_TYPE_SELL); // if the lots of SELL are larger than the BUY lots, we will establish a single take profit
        }
     }
  }
//+------------------------------------------------------------------+
//| Prices for buy and sell positions                                |
//+------------------------------------------------------------------+
void CMoving::Prices(double &price_for_buy,double &price_for_sell)
  {
   price_for_buy=0.0;   price_for_sell=0.0;
   price_for_buy=iMAGet(1)+m_distance_MA;    // calculate the price for buy position
   price_for_sell=iMAGet(1)-m_distance_MA;   // calculate the price for sell position
  }
//+------------------------------------------------------------------+
//| Open Buy position                                                |
//+------------------------------------------------------------------+
void CMoving::OpenBuy(double multiplier=0.0)
  {
   double sl=0.0;
   double tp=0.0;

   double check_open_long_lot=0.0;
   if(m_risk>0.0)
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
      check_open_long_lot=m_lots;
//---
   if(multiplier>0.0)
      check_open_long_lot=LotCheck(check_open_long_lot*multiplier);
   if(check_open_long_lot==0.0)
     {
      Print(__FUNCTION__,", ERROR: method LotCheck returned the value of \"0.0\"");
      return;
     }
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
         if(m_risk>0.0)
            text="< method CheckOpenLong ("+DoubleToString(check_open_long_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(m_lots,2)+")";
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
void CMoving::OpenSell(double multiplier=0.0)
  {
   double sl=0.0;
   double tp=0.0;

   double check_open_short_lot=0.0;
   if(m_risk>0.0)
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
      check_open_short_lot=m_lots;
//---
   if(multiplier>0.0)
      check_open_short_lot=LotCheck(check_open_short_lot*multiplier);
   if(check_open_short_lot==0.0)
     {
      Print(__FUNCTION__,", ERROR: method LotCheck returned the value of \"0.0\"");
      return;
     }
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
         if(m_risk>0.0)
            text="< method CheckOpenShort ("+DoubleToString(check_open_short_lot,2)+")";
         else
            text="< Lots ("+DoubleToString(m_lots,2)+")";
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
//| Lot Check                                                        |
//+------------------------------------------------------------------+
double CMoving::LotCheck(double lots)
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
//| Print CTrade result                                              |
//+------------------------------------------------------------------+
void CMoving::PrintResult(CTrade &trade,CSymbolInfo &symbol)
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
   int d=0;
  }
//+------------------------------------------------------------------+
//| Set TakeProfit                                                   |
//+------------------------------------------------------------------+
void CMoving::SetTakeProfit(bool delete_take_profit=false)
  {
   if(m_take_profit==0.0)
      return;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // selects the position by index
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(delete_take_profit)
              {
               if(m_position.StopLoss()!=0.0 || m_position.TakeProfit()!=0.0)
                  if(!m_trade.PositionModify(m_position.Ticket(),
                     0.0,
                     0.0))
                     Print("Modify tp->0.0 sl->0.0 ",m_position.Ticket(),
                           " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                           ", description of result: ",m_trade.ResultRetcodeDescription());
               continue;
              }
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               double tp=m_position.PriceOpen()+m_take_profit; // preliminary take profit
               if(CompareDoubles(tp,m_position.TakeProfit(),m_symbol.Digits()))
                  continue;
               if(!m_trade.PositionModify(m_position.Ticket(),
                  m_position.StopLoss(),
                  m_symbol.NormalizePrice(tp)))
                  Print("Modify BUY ",m_position.Ticket(),
                        " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
               continue;
              }
            else
              {
               double tp=m_position.PriceOpen()-m_take_profit; // preliminary take profit
               if(CompareDoubles(tp,m_position.TakeProfit(),m_symbol.Digits()))
                  continue;
               if(!m_trade.PositionModify(m_position.Ticket(),
                  m_position.StopLoss(),
                  m_symbol.NormalizePrice(tp)))
                  Print("Modify SELL ",m_position.Ticket(),
                        " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
              }

           }
  }
//+------------------------------------------------------------------+
//| Compare doubles                                                  |
//+------------------------------------------------------------------+
bool CMoving::CompareDoubles(double number1,double number2,int digits)
  {
   if(NormalizeDouble(number1-number2,digits)==0)
      return(true);
   else
      return(false);
  }
//+------------------------------------------------------------------+
//| Awerage TakeProfit                                               |
//+------------------------------------------------------------------+
void CMoving::AwerageTakeProfit(const ENUM_POSITION_TYPE pos_type)
  {
   static long counter=0;
   counter++;
//--- create and initialize local variables
   double buy_price=0.0,buy_lot=0.0,sell_price=0.0,sell_lot=0.0,rez=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // selects the position by index
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               buy_price+=m_position.PriceOpen()*m_position.Volume();
               buy_lot+=m_position.Volume();
               continue;
              }
            else
              {
               sell_price+=m_position.PriceOpen()*m_position.Volume();
               sell_lot+=m_position.Volume();
              }
           }
//---
   if(pos_type==POSITION_TYPE_BUY)
      rez=(buy_price-sell_price)/(buy_lot-sell_lot)+m_profit_plus;
   else
      rez=(sell_price-buy_price)/(sell_lot-buy_lot)-m_profit_plus;
//---
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // selects the position by index
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            ulong ticket=m_position.Ticket();
            ENUM_POSITION_TYPE position_type=m_position.PositionType();
            //---
            if(m_position.PositionType()==POSITION_TYPE_BUY && pos_type==POSITION_TYPE_BUY)
              {
               if(CompareDoubles(rez,m_position.TakeProfit(),m_symbol.Digits()))
                  continue;
               if(!m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),m_symbol.NormalizePrice(rez)))
                 {
                  Print("Counter: ",counter,", Modify BUY ",m_position.Ticket(),
                        " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  Print("Info: ticket ",ticket,", PositionType ",EnumToString(position_type));
                  PrintPositons();
                 }
               else
                  Print("Counter: ",counter,", #",i," Modify BUY Ok: ",m_position.Symbol()," | ",m_position.Ticket()," | ",TimeToString(m_position.Time(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                        " | ",StringSubstr(EnumToString(m_position.PositionType()),14)," | ",DoubleToString(m_position.Volume(),2));
               continue;
              }
            else if(m_position.PositionType()==POSITION_TYPE_SELL && pos_type==POSITION_TYPE_SELL)
              {
               if(CompareDoubles(rez,m_position.TakeProfit(),m_symbol.Digits()))
                  continue;
               if(!m_trade.PositionModify(m_position.Ticket(),m_position.StopLoss(),m_symbol.NormalizePrice(rez)))
                 {
                  Print("Counter: ",counter,", Modify SELL ",m_position.Ticket(),
                        " Position -> false. Result Retcode: ",m_trade.ResultRetcode(),
                        ", description of result: ",m_trade.ResultRetcodeDescription());
                  Print("Info: ticket ",ticket,", PositionType ",EnumToString(position_type));
                  PrintPositons();
                 }
               else
                  Print("Counter: ",counter,", #",i," Modify SELL Ok: ",m_position.Symbol()," | ",m_position.Ticket()," | ",TimeToString(m_position.Time(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                        " | ",StringSubstr(EnumToString(m_position.PositionType()),14)," | ",DoubleToString(m_position.Volume(),2));

               continue;
              }
           }
  }
//+------------------------------------------------------------------+
//| Print positons                                                   |
//+------------------------------------------------------------------+
void CMoving::PrintPositons(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
      if(m_position.SelectByIndex(i)) // selects the position by index
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
           {
            Print("#",i,": ",m_position.Symbol()," | ",m_position.Ticket()," | ",TimeToString(m_position.Time(),TIME_DATE|TIME_MINUTES|TIME_SECONDS),
                  " | ",StringSubstr(EnumToString(m_position.PositionType()),14)," | ",DoubleToString(m_position.Volume(),2));
           }
  }
//+------------------------------------------------------------------+
