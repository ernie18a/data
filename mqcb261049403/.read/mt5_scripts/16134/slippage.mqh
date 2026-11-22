// MQL5-code

#include <BackTest.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PLUSMINUS
  {
   double            Plus;
   double            Minus;

   double Total(void) const
     {
      return(this.Plus + this.Minus);
     }

   const PLUSMINUS operator+(const PLUSMINUS &Value) const
     {
      PLUSMINUS Res=this;

      Res.Plus+=Value.Plus;
      Res.Minus+=Value.Minus;

      return(Res);
     }

   void operator+=(const PLUSMINUS &Value)
     {
      this=this+Value;

      return;
     }

   void operator+=(const double Value)
     {
      if(Value>0)
         this.Plus+=Value;
      else
         this.Minus+=Value;

      return;
     }

   const PLUSMINUS operator *(const double Value) const
     {
      PLUSMINUS Res=this;

      Res.Plus*=Value;
      Res.Minus*=Value;

      return(Res);
     }

   void operator=(const double Value)
     {
      this.Plus=Value;
      this.Minus=Value;

      return;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ORDERTYPE_PROFIT
  {
   PLUSMINUS         Profit;

   double            TurnOver;

   const ORDERTYPE_PROFIT operator+(const ORDERTYPE_PROFIT &Value) const
     {
      ORDERTYPE_PROFIT Res=this;

      Res.Profit+=Value.Profit;

      Res.TurnOver+=Value.TurnOver;

      return(Res);
     }

   string ToString(void) const
     {
      return("\tProfit = " + ::DoubleToString(this.Profit.Plus, 2) + "\tLoss = " + ::DoubleToString(this.Profit.Minus, 2) +
             "\tTotal = "+::DoubleToString(this.Profit.Total(),2)+"\t(TurnOver = "+::DoubleToString(TurnOver,2)+" lots/contracts)");
     }
  };

#define ORDER_TO_STRING(NAME) #NAME + NAME.ToString()

#define ORDERS_TO_STRING(NAME1,NAME2) ORDER_TO_STRING(NAME1) + "\n" + ORDER_TO_STRING(NAME2)

#define ORDERS2_TO_STRING(NAME1,NAME2) ORDERS_TO_STRING(NAME1,NAME2) + "\n" +               \
                                       ORDERS_TO_STRING(NAME1##Limit,NAME2##Limit) + "\n" + \
                                       ORDERS_TO_STRING(NAME1##Stop,NAME2##Stop)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ORDERTYPES_PROFIT
  {
   ORDERTYPE_PROFIT  Buy;
   ORDERTYPE_PROFIT  Sell;
   ORDERTYPE_PROFIT  BuyLimit;
   ORDERTYPE_PROFIT  SellLimit;
   ORDERTYPE_PROFIT  BuyStop;
   ORDERTYPE_PROFIT  SellStop;
   ORDERTYPE_PROFIT  TakeProfit;
   ORDERTYPE_PROFIT  StopLoss;

   const ORDERTYPE_PROFIT TotalProfits(void) const
     {
      return(this.Buy + this.Sell + this.BuyLimit + this.SellLimit + this.BuyStop + this.SellStop + this.TakeProfit + this.StopLoss);
     }

   string ToString(void) const
     {
      const ORDERTYPE_PROFIT Total=this.TotalProfits();

      return(ORDERS2_TO_STRING(Buy,Sell) + "\n" + ORDERS_TO_STRING(TakeProfit,StopLoss) + "\n\n" + ORDER_TO_STRING(Total));
     }
  };

#define ORDER_TYPE_ANY INT_MIN

#define ORDER_TYPE_TAKEPROFIT (-1)
#define ORDER_TYPE_STOPLOSS   (-2)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class SLIPPAGE
  {
private:
   static long       PositionsID[];
   static int        Amount;

   static bool IsMTHedge(void)
     {
      return(::AccountInfoInteger(ACCOUNT_MARGIN_MODE) == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
     }

   static void AddPositionID(const long PositionID,long &lPositionsID[],int &iAmount)
     {
      int i=0;

      while(i<iAmount)
        {
         if(PositionID==lPositionsID[i])
            break;

         i++;
        }

      if(i==iAmount)
        {
         lPositionsID[iAmount]=PositionID;

         iAmount++;
        }

      return;
     }

   static int SetPositionsID(const string Symb,long &lPositionsID[])
     {
      int iAmount=0;

      if(::HistorySelect(0,::TimeCurrent()))
        {
         const int DealsTotal=::HistoryDealsTotal();

         ::ArrayResize(lPositionsID,DealsTotal>>1); // идентификаторов позиций всегда не больше половины количества сделок

         for(int i=0; i<DealsTotal; i++)
           {
            const ulong DealTicket=::HistoryDealGetTicket(i);
            const ENUM_DEAL_TYPE DealType=(ENUM_DEAL_TYPE)::HistoryDealGetInteger(DealTicket,DEAL_TYPE);

            if(((DealType==DEAL_TYPE_BUY) || (DealType==DEAL_TYPE_SELL)) && ::HistoryDealGetString(DealTicket,DEAL_SYMBOL)==Symb)
               SLIPPAGE::AddPositionID(::HistoryDealGetInteger(DealTicket,DEAL_POSITION_ID),lPositionsID,iAmount);
           }
        }

      ::ArrayResize(lPositionsID,iAmount);

      return(iAmount);
     }

   static int GetOrderType(const ulong OrderTicket)
     {
      int OrderType=(int)::HistoryOrderGetInteger(OrderTicket,ORDER_TYPE);

      if((OrderType==ORDER_TYPE_BUY) || (OrderType==ORDER_TYPE_SELL))
        {
         const string OrderComment=HistoryOrderGetString(OrderTicket,ORDER_COMMENT);
         const string OrderPrice=::DoubleToString(::HistoryOrderGetDouble(OrderTicket,ORDER_PRICE_OPEN),
                                                  (int)::SymbolInfoInteger(HistoryOrderGetString(OrderTicket,ORDER_SYMBOL),SYMBOL_DIGITS));

         if(OrderComment=="tp "+OrderPrice)
            OrderType=ORDER_TYPE_TAKEPROFIT;
         else if(OrderComment=="sl "+OrderPrice)
            OrderType=ORDER_TYPE_STOPLOSS;
        }

      return(OrderType);
     }

   static double CalcHistorySlip(const string Symb,PLUSMINUS &TotalProfit,PLUSMINUS &TotalSlip,double &TickValue,const int OrderType=ORDER_TYPE_ANY)
     {
      double TurnOver=0;

      const bool AllTypes=(OrderType==ORDER_TYPE_ANY);

      double TotalVolume=0;
      double TotalDealPrice=0;

      const int DealsTotal=::HistoryDealsTotal();

      for(int i=0; i<DealsTotal; i++)
        {
         const ulong DealTicket=::HistoryDealGetTicket(i);
         const ENUM_DEAL_TYPE DealType=(ENUM_DEAL_TYPE)::HistoryDealGetInteger(DealTicket,DEAL_TYPE);

         if(((DealType==DEAL_TYPE_BUY) || (DealType==DEAL_TYPE_SELL)) && ::HistoryDealGetString(DealTicket,DEAL_SYMBOL)==Symb)
           {
            const double DealVolume=(DealType==DEAL_TYPE_BUY) ?
                                    ::HistoryDealGetDouble(DealTicket,DEAL_VOLUME) : -::HistoryDealGetDouble(DealTicket,DEAL_VOLUME);

            const double DealPrice=::HistoryDealGetDouble(DealTicket,DEAL_PRICE);

            if(TotalVolume*DealVolume>=0)
               TotalDealPrice=(TotalDealPrice*TotalVolume+DealPrice*DealVolume)/(TotalVolume+DealVolume);
            else
              {
               const bool InOutFlag=(::MathAbs(DealVolume)-::MathAbs(TotalVolume)>0.005);

               const double DealProfit=::HistoryDealGetDouble(DealTicket,DEAL_PROFIT);

               if((DealProfit!=0) && (DealPrice!=TotalDealPrice))
                  TickValue=DealProfit/(((InOutFlag) ? -TotalVolume : DealVolume) *(TotalDealPrice-DealPrice));

               if(InOutFlag)
                  TotalDealPrice=DealPrice;
              }

            TotalVolume=::NormalizeDouble(TotalVolume+DealVolume,2);

            const ulong OrderTicket=::HistoryDealGetInteger(DealTicket,DEAL_ORDER);

            if(AllTypes || (SLIPPAGE::GetOrderType(OrderTicket)==OrderType))
              {
               TotalSlip+=DealVolume *(::HistoryOrderGetDouble(OrderTicket,ORDER_PRICE_OPEN)-DealPrice);

               TurnOver+=(DealType==DEAL_TYPE_BUY) ? DealVolume : -DealVolume;
              }

            if(TickValue!=0)
              {
               TotalProfit+=TotalSlip*TickValue;

               TotalSlip=0;
              }
           }
        }

      return(TurnOver);
     }

public:
   static double GetProfitData(PLUSMINUS &TotalProfit,string Symb=NULL,const int OrderType=ORDER_TYPE_ANY,const bool FullCalc=true)
     {
      double TurnOver=0;

      PLUSMINUS TotalSlip={0};

      TotalProfit=0;

      if(Symb== NULL)
         Symb = ::Symbol();

      double TickValue=0;

      if(SLIPPAGE::IsMTHedge())
        {
         if(FullCalc)
            SLIPPAGE::Amount=SLIPPAGE::SetPositionsID(Symb,SLIPPAGE::PositionsID);

         for(int i=0; i<SLIPPAGE::Amount; i++)
            if(::HistorySelectByPosition(SLIPPAGE::PositionsID[i]))
               TurnOver+=SLIPPAGE::CalcHistorySlip(Symb,TotalProfit,TotalSlip,TickValue,OrderType);
        }
      else
        {
         const bool Flag=(FullCalc) ? ::HistorySelect(0,::TimeCurrent()) : true;

         if(Flag)
            TurnOver=SLIPPAGE::CalcHistorySlip(Symb,TotalProfit,TotalSlip,TickValue,OrderType);
        }

      return(TurnOver);
     }

   static void GetProfitData(ORDERTYPE_PROFIT &OrderType_Profit,const string Symb=NULL,const int OrderType=ORDER_TYPE_ANY,const bool FullCalc=true)
     {
      OrderType_Profit.TurnOver=SLIPPAGE::GetProfitData(OrderType_Profit.Profit,Symb,OrderType,FullCalc);

      return;
     }

   static ORDERTYPES_PROFIT GetProfitData(const string Symb=NULL)
     {
      ORDERTYPES_PROFIT Res={0};

      SLIPPAGE::GetProfitData(Res.Buy, Symb, ORDER_TYPE_BUY);
      SLIPPAGE::GetProfitData(Res.Sell, Symb, ORDER_TYPE_SELL, false);
      SLIPPAGE::GetProfitData(Res.BuyLimit, Symb, ORDER_TYPE_BUY_LIMIT, false);
      SLIPPAGE::GetProfitData(Res.SellLimit, Symb, ORDER_TYPE_SELL_LIMIT, false);
      SLIPPAGE::GetProfitData(Res.BuyStop, Symb, ORDER_TYPE_BUY_STOP, false);
      SLIPPAGE::GetProfitData(Res.SellStop, Symb, ORDER_TYPE_SELL_STOP, false);
      SLIPPAGE::GetProfitData(Res.TakeProfit, Symb, ORDER_TYPE_TAKEPROFIT, false);
      SLIPPAGE::GetProfitData(Res.StopLoss, Symb, ORDER_TYPE_STOPLOSS, false);

      return(Res);
     }

   static double GetLimitsTPProfit(void)
     {
      ORDERTYPE_PROFIT Total;

      SLIPPAGE::GetProfitData(Total);

      return(Total.Profit.Plus);
     }

   // Возвращает баланс тестера за вычетом положительных проскальзываний лимитных и TP-ордеров в тестере (запущенный инструмент)
   static double OnTesterBalance(void)
     {
      // Положительное проскальзывание тестер может дать только лимит-ордерам и TP-маркетам, отрицательное - стоп-ордерам и SL-маркетам (и MarginCall)
      return(MQLInfoInteger(MQL_TESTER) ? ::NormalizeDouble(BACKTEST::Balance() - SLIPPAGE::GetLimitsTPProfit(), 2) : 0);
     }

   // Вычитает из баланса бэктеста величину положительных проскальзываний лимитных и TP-ордеров (запущенный инструмент)
   static bool CorrectBackTestBalance(void)
     {
      return(BACKTEST::CorrectFinishBalance(BACKTEST::IsNotWithdrawalAfter() ? SLIPPAGE::GetLimitsTPProfit() : 0));
     }
  };

static long SLIPPAGE::PositionsID[];
static int SLIPPAGE::Amount;
//+------------------------------------------------------------------+
