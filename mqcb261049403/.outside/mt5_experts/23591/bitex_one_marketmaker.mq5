//+------------------------------------------------------------------+
//|                                            BITEX.ONE MarketMaker |
//|                                       Copyright 2018, Bitex1 Ltd |
//|                                            http://www.bitex.one/ |
//+------------------------------------------------------------------+
#property copyright "2018, Bitex1 Ltd"
#property link      "http://www.bitex.one/"
#property version   "1.01"
#property description "This is market-maker robot for the cryptocurrency exchange BITEX.ONE"
#property description "A robot with limit orders quotes the index or mark price, which is taken from several spot exchanges and earns on price inefficiencies and exchange rebates"
#property description "Full description: https://www.mql5.com/ru/code/22875"

input int price_type=2;             // 1 - book price, 2 - mark price, 3 - index price 
input double max_pos=1;             // volume on each price level
input double shift=0.001;           // price shift coefficient from order book center
input double vertical_shift=0;      // vertical price shift coefficient from order book center
input int level_count=1;            // price level count
input int desired_pos=0;            // position in which the trader wants to be

long magic_number=100;              // robot magic number. From version 1.01, magic_number is automatically assigned.
double symbol_tick_size=1;
int symbol_digits=0;
double symbol_volume_min=1;
bool this_is_bitex_one=false;

double lead_price;
string lead_symbol;
//+------------------------------------------------------------------+
//| Order class                                                      |
//+------------------------------------------------------------------+
class COrder
  {
public:
   int               m_index;
   bool              m_wait_reply;
   ulong             m_magic;
   ulong             m_ticket;
   double            m_price;
   double            m_volume;
   string            m_symbol;
   ENUM_ORDER_TYPE   m_type;
   ENUM_ORDER_STATE  m_state;

                     COrder()
     {
      m_wait_reply=false;
      m_ticket= 0;
      m_price = 0;
      m_volume = 0;
      m_symbol = "";
      m_type=0;
      m_state=0;
     }

   string toString()
     {
      return "m_index=" + IntegerToString(m_index) + " m_price=" + DoubleToString(m_price) + " m_volume=" + DoubleToString(m_volume) + " m_wait_reply"+ IntegerToString(m_wait_reply) + " m_magic=" + IntegerToString(m_magic) + " m_ticket=" + IntegerToString(m_ticket) + " m_state="+EnumToString(m_state);
     }
  };

COrder order_array[100];
int order_count=0;

COrder *order_buy_arr[50];
COrder *order_sell_arr[50];
//+------------------------------------------------------------------+
//| Convert order index to magic number function                     |
//+------------------------------------------------------------------+
ulong GetMagicFromIndex(int ind)
  {
   return (magic_number+(ulong)ind+1);
  }
//+------------------------------------------------------------------+
//| Convert magic number to order index function                     |
//+------------------------------------------------------------------+
short GetIndexFromMagic(ulong magic)
  {
   short res=(short)(magic-magic_number-1);
   if((res<0) || (res>=100))
      return -1;
   return res;
  }
//+------------------------------------------------------------------+
//| Order initialization function                                    | 
//+------------------------------------------------------------------+
COrder *InitOrder(string symbol,ENUM_ORDER_TYPE type)
  {
   order_array[order_count].m_symbol=symbol;
   order_array[order_count].m_index=order_count;
   order_array[order_count].m_magic= GetMagicFromIndex(order_array[order_count].m_index);
   order_array[order_count].m_type = type;

   order_count++;
   return &order_array[order_count-1];
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   this_is_bitex_one=AccountInfoString(ACCOUNT_COMPANY)=="Bitex1 Ltd";
   if(!this_is_bitex_one)
     {
      Print("ERROR. This robot specialized on Bitex1 Ltd. It will not work properly on other brokers.");
      //return (INIT_FAILED);
     }

   magic_number=(ChartID()%0xFFFFFFFFFFFF)*100;

   for(int i=0;i<level_count;i++)
     {
      order_buy_arr[i]=InitOrder(_Symbol,ORDER_TYPE_BUY_LIMIT);
      order_sell_arr[i]=InitOrder(_Symbol,ORDER_TYPE_SELL_LIMIT);
     }
   symbol_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   symbol_digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   DeleteAllOrders();

   MarketBookAdd(_Symbol);

// lead symbol may be index price ("i" postfix) or mark price ("m" postfix)
   if(price_type == 1)
      lead_symbol= _Symbol;
   else
   if(price_type == 2)
      lead_symbol= _Symbol+"m";
   else
   if(price_type==3)
     {
      if(StringFind(_Symbol,"-",0)!=-1)
        {
         lead_symbol = _Symbol;
         lead_symbol = StringSubstr(_Symbol,0,StringFind(_Symbol,"-",0))+"i";
        }
      else
         lead_symbol=_Symbol+"i";
     }

   lead_price=SymbolInfoDouble(lead_symbol,SYMBOL_BID);
   symbol_volume_min=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);

   EventSetMillisecondTimer(1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Position getting function                                        |
//+------------------------------------------------------------------+
double GetPosition()
  {
   PositionSelect(_Symbol);
   if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
      return PositionGetDouble(POSITION_VOLUME);
   else return -PositionGetDouble(POSITION_VOLUME);
  }
//+------------------------------------------------------------------+
//| Order info getting function                                      |
//+------------------------------------------------------------------+
void GetOrderInfo(COrder &order)
  {
   uint total=OrdersTotal();
   for(uint i=0;i<total;i++)
      if((order.m_ticket=OrderGetTicket(i))>0)
         if(OrderGetInteger(ORDER_MAGIC)==order.m_magic)
           {
            order.m_price=OrderGetDouble(ORDER_PRICE_OPEN);
            order.m_volume=OrderGetDouble(ORDER_VOLUME_CURRENT);
            order.m_type=(ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
            order.m_state=(ENUM_ORDER_STATE)OrderGetInteger(ORDER_STATE);
            order.m_symbol=OrderGetString(ORDER_SYMBOL);
            return;
           }

   order.m_ticket=0;
  }
//+------------------------------------------------------------------+
//| Orders delete function                                           |
//+------------------------------------------------------------------+
void DeleteAllOrders()
  {
   ulong order_ticket;
   for(int i=OrdersTotal()-1;i>=0;i--)
      if((order_ticket=OrderGetTicket(i))>0)
         if((OrderGetInteger(ORDER_MAGIC)>magic_number) && (OrderGetInteger(ORDER_MAGIC)<(magic_number+100)))
           {
            MqlTradeResult result={0};
            MqlTradeRequest request={0};
            request.order=order_ticket;
            request.action=TRADE_ACTION_REMOVE;
            if(!OrderSend(request,result))
               Print(__FUNCTION__,": OrderSend = false");
           }
  }
//+------------------------------------------------------------------+
//| Order send async function                                        |
//+------------------------------------------------------------------+
void SendAsync(COrder &order,double price,double volume)
  {
   if(order.m_wait_reply)
      return;

   MqlTradeRequest req={0};
   req.magic       = order.m_magic;
   req.symbol      = order.m_symbol;
   req.type        = order.m_type;
   req.price       = price;
   req.volume      = volume;
   req.action      = TRADE_ACTION_PENDING;
   req.type_time   = ORDER_TIME_GTC;
   req.type_filling= ORDER_FILLING_RETURN;
   req.sl          = 0.0;
   req.tp          = 0.0;
   req.stoplimit   = 0.0;
   req.expiration  = 0.0;
   req.comment     = "";
   MqlTradeResult  res={0};

   if(!OrderSendAsync(req,res))
     {
      if(res.retcode==TRADE_RETCODE_TOO_MANY_REQUESTS)
         order.m_wait_reply=false;
      else
         Print(__FUNCTION__," :: ERROR res.retcod = "+(string)res.retcode);
     }
   else
     {
      order.m_wait_reply=true;
     }
  }
//+------------------------------------------------------------------+
//| Order modify async function                                      |
//+------------------------------------------------------------------+
void ModifyAsync(COrder &order,double price,double volume)
  {
   if(order.m_wait_reply)
      return;

   if((order.m_state==ORDER_STATE_PLACED) || (order.m_state==ORDER_STATE_PARTIAL))
     {
      MqlTradeRequest req={0};
      req.order       = order.m_ticket;
      req.magic       = order.m_magic;
      req.symbol      = order.m_symbol;
      req.type        = order.m_type;
      req.price       = price;
      req.action      = TRADE_ACTION_MODIFY;
      req.type_time   = ORDER_TIME_GTC;
      req.type_filling= ORDER_FILLING_RETURN;
      req.expiration  = 0.0;
      req.sl          = 0.0;
      req.tp          = 0.0;
      req.stoplimit   = 0.0;
      req.comment     = "";
      MqlTradeResult  res={0};

      if(!OrderSendAsync(req,res))
        {
         if(res.retcode==TRADE_RETCODE_TOO_MANY_REQUESTS)
            order.m_wait_reply=false;
         else
            Print(__FUNCTION__," :: ERROR res.retcod = "+(string)res.retcode);
        }
      else
        {
         order.m_wait_reply=true;
        }
     }
  }
//+------------------------------------------------------------------+
//| Order remove async function                                      |
//+------------------------------------------------------------------+
void RemoveOrderAsync(COrder &order)
  {
   if(order.m_wait_reply)
      return;

   if((order.m_state==ORDER_STATE_PLACED) || (order.m_state==ORDER_STATE_PARTIAL))
     {
      MqlTradeRequest req={0};
      req.order       = order.m_ticket;
      req.symbol      = order.m_symbol;
      req.action      = TRADE_ACTION_REMOVE;
      MqlTradeResult  res={0};

      if(!OrderSendAsync(req,res))
        {
         if(res.retcode==TRADE_RETCODE_TOO_MANY_REQUESTS)
            order.m_wait_reply=false;
         else
            Print(__FUNCTION__," :: ERROR res.retcod = "+(string)res.retcode);
        }
      else
        {
         order.m_wait_reply=true;
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert business logic                                            |
//+------------------------------------------------------------------+
void ProcessStrategy()
  {
   if(!this_is_bitex_one)
      return;

   lead_price=SymbolInfoDouble(lead_symbol,SYMBOL_BID);

   double shift_price=shift*lead_price;
   double vertical_shift_price=vertical_shift*lead_price;

   double res_volume_buy_sum=max_pos*level_count-GetPosition()+desired_pos;
   double res_volume_sell_sum=max_pos*level_count+GetPosition()-desired_pos;

   for(int level=level_count-1; level>=0; level--)
     {
      GetOrderInfo(order_buy_arr[level]);
      GetOrderInfo(order_sell_arr[level]);

      double res_price_buy=lead_price-shift_price*(level+1)+vertical_shift_price;
      double res_price_sell=lead_price+shift_price*(level+1)+vertical_shift_price;

      res_price_buy=NormalizeDouble(round(res_price_buy/symbol_tick_size)*symbol_tick_size,symbol_digits);
      res_price_sell=NormalizeDouble(round(res_price_sell/symbol_tick_size)*symbol_tick_size,symbol_digits);

      double res_volume_buy;
      double res_volume_sell;

      if(res_volume_buy_sum>=symbol_volume_min)
         res_volume_buy=MathMax(MathMin(res_volume_buy_sum,max_pos),symbol_volume_min);
      else
         res_volume_buy=0;

      if(res_volume_sell_sum>=symbol_volume_min)
         res_volume_sell=MathMax(MathMin(res_volume_sell_sum,max_pos),symbol_volume_min);
      else
         res_volume_sell=0;

      if(res_volume_buy>0)
        {
         if(!order_buy_arr[level].m_ticket)
           {
            SendAsync(order_buy_arr[level],res_price_buy,res_volume_buy);
           }
         else
           {
            if(order_buy_arr[level].m_volume!=res_volume_buy)
               RemoveOrderAsync(order_buy_arr[level]);
            else
            if(MathAbs(((double)(order_buy_arr[level].m_price-res_price_buy))/(lead_price))>0.005)
               ModifyAsync(order_buy_arr[level],res_price_buy,res_volume_buy);
           }
        }
      else
      if(order_buy_arr[level].m_ticket)
         RemoveOrderAsync(order_buy_arr[level]);

      if(res_volume_sell>0)
        {
         if(!order_sell_arr[level].m_ticket)
           {
            SendAsync(order_sell_arr[level],res_price_sell,res_volume_sell);
           }
         else
           {
            if(order_sell_arr[level].m_volume!=res_volume_sell)
               RemoveOrderAsync(order_sell_arr[level]);
            else
            if(MathAbs(((double)(order_sell_arr[level].m_price-res_price_sell))/(lead_price))>0.0005)
               ModifyAsync(order_sell_arr[level],res_price_sell,res_volume_sell);
           }
        }
      else
      if(order_sell_arr[level].m_ticket)
         RemoveOrderAsync(order_sell_arr[level]);

      res_volume_buy_sum-=res_volume_buy;
      res_volume_sell_sum-=res_volume_sell;

     }

//  Sleep(5000);
  }
//+------------------------------------------------------------------+
//| Expert OnBookEvent function                                      |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   if(symbol==_Symbol)
      ProcessStrategy();
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   MarketBookRelease(_Symbol);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert OnTick function                                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   ProcessStrategy();
  }
//+------------------------------------------------------------------+
//| Expert OnTimer function                                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(lead_price!=SymbolInfoDouble(lead_symbol,SYMBOL_BID))
      ProcessStrategy();
  }
//+------------------------------------------------------------------+
//| Expert OnTradeTransaction function                               |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,const MqlTradeRequest &request,const MqlTradeResult &result)
  {
   ulong magic=0;
   ulong order_ticket=0;

   if(trans.type==TRADE_TRANSACTION_REQUEST)
      order_ticket=request.order;
   else
      order_ticket=trans.order;

   if(OrderSelect(order_ticket))
      magic=OrderGetInteger(ORDER_MAGIC);
   else
   if(HistoryOrderSelect(order_ticket))
      magic=HistoryOrderGetInteger(order_ticket,ORDER_MAGIC);

   if(magic==0)
     {
      if(trans.type==TRADE_TRANSACTION_DEAL_ADD)
         if(HistoryDealSelect(trans.deal))
            magic=HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
      if(trans.type==TRADE_TRANSACTION_REQUEST)
         magic=request.magic;
     }

   short ord_ind=(short)GetIndexFromMagic(magic);

   if(ord_ind!=-1)
     {

      if(trans.symbol!="")
         if(trans.symbol!=_Symbol)
           {
            Print("ERROR! trans.symbol!=_Symbol ",trans.symbol,"!=",_Symbol,". Two or more robots have intersecting magic_number.");
            ExpertRemove();
           }

      switch(trans.type)
        {
         case TRADE_TRANSACTION_ORDER_UPDATE:
           {
            switch(trans.order_state)
              {
               case ORDER_STATE_PLACED:
                 {
                  order_array[ord_ind].m_wait_reply=0;
                  break;
                 }
               case ORDER_STATE_PARTIAL:
                 {
                  order_array[ord_ind].m_wait_reply=0;
                  break;
                 }
               break;
              }
           }

         case TRADE_TRANSACTION_HISTORY_ADD:
           {
            switch(trans.order_state)
              {
               case ORDER_STATE_CANCELED:
                 {
                  order_array[ord_ind].m_wait_reply=false;
                  break;
                 }
               case ORDER_STATE_FILLED:
                 {
                  order_array[ord_ind].m_wait_reply=false;
                  break;
                 }
              }
            break;
           }
        }

      if(trans.order_state==ORDER_STATE_REJECTED)
        {
         order_array[ord_ind].m_wait_reply=false;
        }

      if(trans.type==TRADE_TRANSACTION_REQUEST)
        {
         if(result.retcode==TRADE_RETCODE_DONE)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if(result.retcode==TRADE_RETCODE_TOO_MANY_REQUESTS)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if(result.retcode==TRADE_RETCODE_FROZEN)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if(result.retcode==TRADE_RETCODE_INVALID)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if(result.retcode==TRADE_RETCODE_REJECT)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if(result.retcode==TRADE_RETCODE_ERROR)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if(result.retcode==TRADE_RETCODE_INVALID)
           {
            order_array[ord_ind].m_wait_reply=false;
           }
         else
         if((result.retcode!=TRADE_RETCODE_PLACED) && (result.retcode!=TRADE_RETCODE_DONE))
                             Print(__FUNCTION__," :: trans.type==TRADE_TRANSACTION_REQUEST result.retcode="+(string)result.retcode);
        }
     }
  }
//+------------------------------------------------------------------+
